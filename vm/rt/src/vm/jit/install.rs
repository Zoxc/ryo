//! The JIT thread's compiler: decodes a function from its image, encodes it again without
//! counters, and installs the code near the image: code memory, relocation, unwind
//! information, the perf map, and the record's publication (design/vm.md, "JIT").

use core::ffi::{c_int, c_void};
use core::ptr;
use core::sync::atomic::Ordering::{Acquire, Release, SeqCst};
use std::collections::HashMap;
use std::io::Write;
use std::vec::Vec;

use ryo_bytecode::Opcode;
use ryo_bytecode::asm::{self, Mode, Ref};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};
use ryo_bytecode::image::{EhFunc, Image, ImageResolver, JIT_DONE, JitRecord, eh_cie, eh_fde};

use super::super::interp::{handler, probe_stack};
use super::super::sys::PAGE;
use super::{JIT_ENTRY_PREFIX, REDIRECT, ctr, entry, state};

/// The size of a code region: one mapping that code (from the start, in pages, made
/// executable once written) and unwind information (from the end, read-write) are taken from.
const REGION: usize = 32 << 20;
/// How far apart a 32-bit PC-relative field and its target may be, with a margin.
const REACH: usize = (1 << 31) - (1 << 20);
/// Where a function's code starts in its allocation: 16-aligned, after the entry prefix.
const CODE_AT: usize = 16;

const PROT_READ: c_int = 1;
const PROT_WRITE: c_int = 2;
const PROT_EXEC: c_int = 4;
const MAP_PRIVATE: c_int = 0x02;
const MAP_ANONYMOUS: c_int = 0x20;
const MAP_NORESERVE: c_int = 0x4000;
const MAP_FIXED_NOREPLACE: c_int = 0x10_0000;
const MAP_FAILED: *mut c_void = !0usize as *mut c_void;

unsafe extern "C" {
    fn mmap(addr: *mut c_void, len: usize, prot: c_int, flags: c_int, fd: c_int, off: i64) -> *mut c_void;
    fn munmap(addr: *mut c_void, len: usize) -> c_int;
    fn mprotect(addr: *mut c_void, len: usize, prot: c_int) -> c_int;
    fn getpid() -> c_int;
    fn write(fd: c_int, buf: *const c_void, n: usize) -> isize;
    /// libgcc's: registers an `.eh_frame` (terminated by a zero word) with the unwinder.
    fn __register_frame(begin: *const u8);
    /// std's personality routine, which VM code's CIEs name through a symbol slot.
    fn rust_eh_personality();
}

/// An address range `lo..hi` that code must reach with 32-bit PC-relative fields.
#[derive(Clone, Copy)]
struct Span {
    lo: usize,
    hi: usize,
}

/// A mapping near some images ([`REGION`]): code is taken from `code` up, unwind
/// information from `data` down.
struct Region {
    start: usize,
    end: usize,
    code: usize,
    data: usize,
}

impl Region {
    /// Whether all of the region reaches all of `s`.
    fn reaches(&self, s: Span) -> bool {
        reaches(self.start, self.end, s)
    }
}

fn reaches(start: usize, end: usize, s: Span) -> bool {
    s.hi.saturating_sub(start) <= REACH && end.saturating_sub(s.lo) <= REACH
}

/// What the JIT knows about an image: its range, and its `rust_eh_personality` slot.
#[derive(Clone, Copy)]
struct ImageInfo {
    span: Span,
    personality: Option<usize>,
}

pub(super) struct Jit {
    /// The handlers' addresses and opcodes, sorted, for [`ImageResolver`].
    handlers: Vec<(usize, Opcode)>,
    /// The handlers' and the probe's range.
    rt: Span,
    regions: Vec<Region>,
    images: HashMap<usize, ImageInfo>,
    perfmap: Option<std::fs::File>,
}

impl Jit {
    pub(super) fn new(perfmap: bool) -> Jit {
        let mut handlers: Vec<(usize, Opcode)> = ryo_bytecode::ALL_OPCODES.iter().filter_map(|&op| Some((handler(op)? as usize, op))).collect();
        handlers.sort_unstable_by_key(|h| h.0);
        let probe = probe_stack as *const () as usize;
        let lo = handlers.first().map_or(probe, |h| h.0).min(probe);
        let hi = handlers.last().map_or(probe, |h| h.0).max(probe) + PAGE;
        let perfmap = perfmap
            .then(|| {
                // SAFETY: always safe to call.
                let pid = unsafe { getpid() };
                std::fs::OpenOptions::new().create(true).append(true).open(std::format!("/tmp/perf-{pid}.map")).ok()
            })
            .flatten();
        Jit { handlers, rt: Span { lo, hi }, regions: Vec::new(), images: HashMap::new(), perfmap }
    }

    fn image(&mut self, img: &Image<'_>) -> ImageInfo {
        let rt = self.rt;
        *self.images.entry(img.header() as *const _ as usize).or_insert_with(|| {
            let h = img.header();
            let ro = img.bytes().as_ptr() as usize;
            let ends =
                [(ro, h.size as usize), (h.data as usize, h.data_size as usize), (h.text as usize, h.text_size as usize), (rt.lo, rt.hi - rt.lo)];
            let span = Span { lo: ends.iter().map(|e| e.0).min().unwrap_or(0), hi: ends.iter().map(|e| e.0 + e.1).max().unwrap_or(0) };
            let p = rust_eh_personality as *const () as u64;
            let personality = img.symbols().iter().position(|&s| s == p).map(|i| ro + h.symbols.off as usize + 8 * i);
            ImageInfo { span, personality }
        })
    }

    /// A region that reaches `s`, mapping a new one if none does.
    fn region(&mut self, s: Span) -> Option<&mut Region> {
        if let Some(i) = self.regions.iter().position(|r| r.reaches(s)) {
            return Some(&mut self.regions[i]);
        }
        const STEP: usize = 2 << 20;
        let above = s.hi.next_multiple_of(STEP);
        let below = (s.lo & !(STEP - 1)).checked_sub(REGION);
        for k in 0..(REACH / REGION) {
            for hint in [above.checked_add(k * REGION), below.and_then(|b| b.checked_sub(k * REGION))].into_iter().flatten() {
                if !reaches(hint, hint + REGION, s) {
                    continue;
                }
                // SAFETY: a new private mapping, never over an existing one (`NOREPLACE`).
                let p = unsafe {
                    mmap(
                        hint as *mut c_void,
                        REGION,
                        PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE | MAP_FIXED_NOREPLACE,
                        -1,
                        0,
                    )
                };
                if p == MAP_FAILED {
                    continue;
                }
                let p = p as usize;
                // A kernel without `MAP_FIXED_NOREPLACE` takes the address as a hint only.
                if !reaches(p, p + REGION, s) {
                    // SAFETY: the mapping just made.
                    unsafe { munmap(p as *mut c_void, REGION) };
                    continue;
                }
                self.regions.push(Region { start: p, end: p + REGION, code: p, data: p + REGION });
                return self.regions.last_mut();
            }
        }
        None
    }

    /// Compiles the function of `rec` and publishes its code.
    pub(super) fn compile(&mut self, rec: *mut JitRecord) -> Result<(), &'static str> {
        // SAFETY: a record of a linked image, whose header it points at.
        let (func, img) = unsafe { ((*rec).func, Image::from_header((*rec).header.cast()).map_err(|_| "invalid image")?) };
        let h = img.header();
        if img.mode().pe {
            return Err("PE");
        }
        let info = self.image(&img);
        let personality = info.personality.ok_or("no personality slot")?;
        // SAFETY: a linked image's text section.
        let text = unsafe { core::slice::from_raw_parts(h.text as usize as *const u8, h.text_size as usize) };
        let res = ImageResolver { image: img, handlers: &self.handlers, probe: probe_stack as *const () as usize };
        let d = res.decode(func, text).ok_or("no such function")?.map_err(|e| e.what)?;
        let mode = Mode { counters: false, ..img.mode() };
        let enc = asm::encode_reduced(&d.words, d.frame_size, &d.cleanup, &d.scopes, &d.dropped, img.code_consts(), mode).map_err(|_| "encode")?;

        // Unwind information: the CIE, the FDE, the terminator, then the LSDA.
        let mut eh = Vec::new();
        let pers_field = eh_cie(&mut eh);
        let ef = EhFunc { len: enc.code.len() as u32, frame_size: d.frame_size, prologue: enc.prologue, entry_stub: enc.entry_stub };
        let fields = eh_fde(&mut eh, 0, &ef, mode);
        eh.extend_from_slice(&[0; 4]);
        let lsda_at = eh.len();
        eh.extend_from_slice(&asm::lsda::write(&enc.call_sites));

        // Code memory: the entry prefix, the code, then its code constants.
        let ro_at = (CODE_AT + enc.code.len()).next_multiple_of(16);
        let size = (ro_at + enc.rodata.len()).next_multiple_of(PAGE);
        let eh_size = eh.len().next_multiple_of(16);
        if size + eh_size > REGION / 2 {
            return Err("too large");
        }
        let region = self.region(info.span).ok_or("no code memory near the image")?;
        if region.code + size + eh_size > region.data {
            // Full: retire it (it reaches nothing any more) and map another.
            region.data = region.code;
            region.start = usize::MAX;
            region.end = usize::MAX;
            return self.compile(rec);
        }
        let base = region.code;
        region.code += size;
        region.data -= eh_size;
        let eh_base = region.data;

        let mut code = std::vec![0xccu8; size];
        code[CODE_AT - JIT_ENTRY_PREFIX..CODE_AT].copy_from_slice(&[0x41, 0x5b]); // pop r11
        code[CODE_AT..][..enc.code.len()].copy_from_slice(&enc.code);
        code[ro_at..][..enc.rodata.len()].copy_from_slice(&enc.rodata);
        let jit_f = base + CODE_AT;
        let ro = img.bytes().as_ptr() as usize;
        let recs = img.jit_records();
        let fs = img.functions();
        for r in &enc.relocs {
            let field = jit_f + r.at as usize;
            let target = match r.to {
                Ref::Handler(op) => handler(op).ok_or("no handler")? as usize,
                Ref::Probe => probe_stack as *const () as usize,
                Ref::Func(Func(g)) if g == func => jit_f,
                Ref::Func(Func(g)) => {
                    let f = fs.get(g as usize).ok_or("function out of range")?;
                    let gr = recs.wrapping_add(g as usize);
                    // A compiled callee directly, else its AOT entry, whose counter check
                    // redirects once it is compiled.
                    if g < h.jit_records.count && state(gr).load(Acquire) == JIT_DONE {
                        // SAFETY: published before `Done`.
                        unsafe { (*gr).jit_code as usize }
                    } else {
                        h.text as usize + f.code_off as usize
                    }
                }
                Ref::Sym(Sym(s)) => ro + h.symbols.off as usize + 8 * s as usize,
                Ref::Site(Site(s)) => h.data as usize + 8 * s as usize,
                Ref::Const(Const(k)) => ro + h.consts.off as usize + k as usize,
                Ref::Data(Data(k)) => h.data as usize + h.fixup_area as usize + k as usize,
                Ref::Ro(o) => base + ro_at + o as usize,
                Ref::Rec => rec as usize,
                Ref::RecCtr => rec as usize - 1,
            };
            let d = i32::try_from((target as i64).wrapping_sub(field as i64 + 4)).map_err(|_| "out of reach")?;
            code[field - base..][..4].copy_from_slice(&d.to_le_bytes());
        }
        let pc = |eh: &mut Vec<u8>, at: usize, target: usize| -> Result<(), &'static str> {
            let d = i32::try_from((target as i64).wrapping_sub((eh_base + at) as i64)).map_err(|_| "out of reach")?;
            eh[at..at + 4].copy_from_slice(&d.to_le_bytes());
            Ok(())
        };
        pc(&mut eh, pers_field, personality)?;
        pc(&mut eh, fields.pc_begin, jit_f)?;
        pc(&mut eh, fields.lsda, eh_base + lsda_at)?;

        // SAFETY: fresh read-write memory of the region, `size` and `eh.len()` bytes, which
        // nothing else uses; the code pages become executable only once written, and are
        // never written again.
        unsafe {
            ptr::copy_nonoverlapping(code.as_ptr(), base as *mut u8, size);
            ptr::copy_nonoverlapping(eh.as_ptr(), eh_base as *mut u8, eh.len());
            if mprotect(base as *mut c_void, size, PROT_READ | PROT_EXEC) != 0 {
                return Err("mprotect");
            }
            __register_frame(eh_base as *const u8);
        }
        if let Some(m) = &mut self.perfmap {
            let aot = h.text as usize + fs[func as usize].code_off as usize;
            let _ = writeln!(m, "{jit_f:x} {:x} ryo-jit:f{func}@{aot:x}", enc.code.len());
        }

        // Publish: the code's range, the entry, the state, then the counter that takes every
        // entry's stub (design/vm.md, "JIT").
        // SAFETY: the record is this thread's to write until `Done`; the AOT code reads
        // `entry` with plain loads (an atomic store of its size).
        unsafe {
            (*rec).jit_code = jit_f as *const u8;
            (*rec).jit_len = enc.code.len() as u64;
        }
        entry(rec).store((jit_f - JIT_ENTRY_PREFIX) as *mut u8, Release);
        state(rec).store(JIT_DONE, SeqCst);
        ctr(rec).store(REDIRECT, SeqCst);
        if super::config().log {
            self.log(rec, "compiled");
        }
        Ok(())
    }

    /// A line on stderr about `rec` (`RYO_JIT_LOG`).
    pub(super) fn log(&self, rec: *mut JitRecord, what: &str) {
        // SAFETY: a record of a linked image.
        let (func, header) = unsafe { ((*rec).func, (*rec).header) };
        // Straight to the file descriptor, not through std's `Stderr`, whose lock a program
        // thread may hold while it waits for this one (`RYO_JIT_SYNC`).
        let line = std::format!("ryo-jit: f{func} of image {header:p}: {what}\n");
        // SAFETY: a write of a live buffer.
        unsafe { write(2, line.as_ptr().cast(), line.len()) };
    }
}
