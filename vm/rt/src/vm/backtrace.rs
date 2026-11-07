//! Source locations of VM frames for std's backtraces (design/vm.md#source-locations):
//! [`ryo_bt_resolve`], which the ryo sysroot's std asks before its own symbolizer.
//!
//! An AOT frame's return address finds its function in the registry, and in the function's
//! instruction list the location run at or before it. A JIT frame's finds its compilation's
//! call map ([`BtRegion`], published by the JIT before the code runs) and the chain of AOT
//! calls it stands for, each expanded as an AOT frame's would be. Lock-free and
//! allocation-free: the registry's snapshots and the call maps are append-only, and the
//! JIT thread may publish while another thread resolves.

use core::ffi::c_void;
use core::ptr;
use core::sync::atomic::{AtomicPtr, Ordering};

use ryo_bytecode::asm::list::{Entry, walk};
use ryo_bytecode::image::Image;
use ryo_bytecode::jit_abi::{BT_ROOT, BtChain, BtRegion};
use ryo_bytecode::tagged;

use super::registry;

/// A frame [`ryo_bt_resolve`] reports: a function and where in its source. Null `name`: the
/// function whose code holds `aot_pc` (the caller looks up its symbol); null `file`: no
/// location (`line` and `col` 0). `col` 0 is no column.
#[repr(C)]
pub struct RyoFrame {
    pub name: *const u8,
    pub name_len: usize,
    pub file: *const u8,
    pub file_len: usize,
    pub line: u32,
    pub col: u32,
    /// An address in the function's AOT code, for the caller to find its symbol by: for AOT
    /// code the `ip` resolved (a return address minus one), for JIT code the start of the
    /// call's AOT instruction, or the root's AOT entry where there is no call map entry (0 if
    /// that isn't found either).
    pub aot_pc: usize,
}

/// The callback [`ryo_bt_resolve`] reports each frame to, with the caller's `data`.
pub type FrameCb = extern "C" fn(data: *mut c_void, frame: &RyoFrame);

/// Resolves `ip` (a return address minus one) if it is in VM code, AOT or JIT: calls `cb`
/// for each frame it stands for, innermost first (the frames inlined into the call, by
/// rustc's MIR inliner or the JIT's, then the function's own), and returns true. Returns
/// false, calling nothing, for any other address.
///
/// Internal and tagged like [`super::ryo_vm_register`]; `C-unwind` so that the compiler adds
/// no abort-on-unwind guard. Nothing in it panics.
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(ryo_bytecode::rt_sym!(bt_resolve)))]
pub extern "C-unwind" fn ryo_bt_resolve(ip: usize, cb: FrameCb, data: *mut c_void) -> bool {
    if let Some((img, func, off)) = registry::text_at(ip) {
        expand(img, func, off, ip, cb, data);
        return true;
    }
    jit_resolve(ip, cb, data)
}

/// The address std takes as the start of the function a frame is in (the symbol address)
/// for `addr`, as the unwinder found it: for JIT code, the AOT entry of its root, whose
/// address a function pointer to it still is (`Backtrace::capture` finds its own frame by
/// it); any other address unchanged.
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(ryo_bytecode::rt_sym!(bt_entry)))]
pub extern "C-unwind" fn ryo_bt_entry(addr: usize) -> usize {
    let mut r = REGIONS.load(Ordering::Acquire);
    // SAFETY: as in `jit_resolve`.
    while let Some(reg) = unsafe { r.as_ref() } {
        if addr.wrapping_sub(reg.start) < reg.len {
            return registry::image(reg.root_img).and_then(|img| entry(img, reg.root_func)).unwrap_or(addr);
        }
        r = reg.next;
    }
    addr
}

/// Reports the location run of function `func` of `img` at or before byte `pos`, each
/// element as a frame at `aot_pc`; one frame without a location if there is none.
fn expand(img: &'static Image<'static>, func: u32, pos: u32, aot_pc: usize, cb: FrameCb, data: *mut c_void) {
    let list = img.list(func);
    let code_len = img.functions().get(func as usize).map_or(0, |f| f.code_len);
    let mut best = None;
    let _ = walk(list, code_len, |at, e| {
        if matches!(e, Entry::Loc { .. }) && at <= pos {
            best = Some(at);
        }
    });
    let mut any = false;
    if let Some(b) = best {
        let _ = walk(list, code_len, |at, e| {
            let Entry::Loc { file, line, col, name } = e else { return };
            if at != b || file == 0 {
                return;
            }
            let Some(file) = img.string(file) else { return };
            let name = if name != 0 { img.string(name) } else { None };
            any = true;
            let (name, name_len) = name.map_or((ptr::null(), 0), |n| (n.as_ptr(), n.len()));
            cb(data, &RyoFrame { name, name_len, file: file.as_ptr(), file_len: file.len(), line, col, aot_pc });
        });
    }
    if !any {
        cb(data, &RyoFrame { name: ptr::null(), name_len: 0, file: ptr::null(), file_len: 0, line: 0, col: 0, aot_pc });
    }
}

/// The published call maps, newest first.
static REGIONS: AtomicPtr<BtRegion> = AtomicPtr::new(ptr::null_mut());

/// [`ryo_bytecode::jit_abi::RtApi::bt_publish`].
pub(super) extern "C-unwind" fn bt_publish(r: *mut BtRegion) {
    let mut head = REGIONS.load(Ordering::Acquire);
    loop {
        // SAFETY: the JIT hands over a valid region that nothing else references yet.
        unsafe { (*r).next = head };
        match REGIONS.compare_exchange_weak(head, r, Ordering::Release, Ordering::Acquire) {
            Ok(_) => return,
            Err(h) => head = h,
        }
    }
}

/// [`ryo_bt_resolve`] for JIT code.
fn jit_resolve(ip: usize, cb: FrameCb, data: *mut c_void) -> bool {
    let mut r = REGIONS.load(Ordering::Acquire);
    // SAFETY: published regions are complete before their Release store and live forever.
    while let Some(reg) = unsafe { r.as_ref() } {
        r = reg.next;
        if ip.wrapping_sub(reg.start) >= reg.len {
            continue;
        }
        let off = (ip - reg.start) as u32;
        // SAFETY: as above; the tables have `npc` and `nchain` entries.
        let (pcs, chains) = unsafe {
            (
                core::slice::from_raw_parts(if reg.npc == 0 { ptr::dangling() } else { reg.pcmap }, reg.npc as usize),
                core::slice::from_raw_parts(if reg.nchain == 0 { ptr::dangling() } else { reg.chains }, reg.nchain as usize),
            )
        };
        let (mut lo, mut hi) = (0, pcs.len());
        while lo < hi {
            let mid = lo + (hi - lo) / 2;
            if pcs.get(mid).is_some_and(|p| p[0] < off) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        let mut link = pcs.get(lo).filter(|p| p[0] == off).map(|p| p[1]);
        let mut any = false;
        while let Some(c) = link {
            let Some(&BtChain { img, func, pos, parent, .. }) = chains.get(c as usize) else { break };
            let Some(img) = registry::image(img) else { break };
            let Some(entry) = entry(img, func) else { break };
            expand(img, func, pos, entry.wrapping_add(pos as usize), cb, data);
            any = true;
            link = (parent != BT_ROOT).then_some(parent);
        }
        if !any {
            // No call map entry: the root, by name.
            let at = registry::image(reg.root_img).and_then(|img| entry(img, reg.root_func)).unwrap_or(0);
            cb(data, &RyoFrame { name: ptr::null(), name_len: 0, file: ptr::null(), file_len: 0, line: 0, col: 0, aot_pc: at });
        }
        return true;
    }
    false
}

/// The address of function `g`'s AOT code.
fn entry(img: &Image<'_>, g: u32) -> Option<usize> {
    let f = img.functions().get(g as usize)?;
    Some((img.header().text as usize).wrapping_add(f.code_off as usize))
}
