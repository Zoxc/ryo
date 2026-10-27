//! PE: the language handler of VM code, `ryo_seh_handler` (design/vm.md#unwinding), which
//! every VM function's `UNWIND_INFO` names, with its handler data
//! ([`ryo_bytecode::image::PeHandlerData`]): the offsets of the entry's range and of the pad
//! region from the function's start, and the function's LSDA (`asm::lsda`).
//!
//! Exceptions are dispatched in two phases. In the search phase, the handler acts only at
//! `Terminate` call sites, which catch every C++ exception (Rust panics of any std and
//! foreign ones alike), as rustc's catch-all terminate pads do: it unwinds to the site's
//! landing pad (a terminate stub) with `RtlUnwindEx`. At a pc without a call site it aborts,
//! as the ELF personality does. In the unwind phase (once something up the stack caught the
//! exception), it calls the landing pad of a cleanup call site, on the current stack, through
//! [`ryo_seh_call_pad`]: the pad region's entry allocates the pad's own frame, the cleanup
//! code addresses the VM frame's slots through `rbp`, and its `resume` returns. The unwind
//! then goes on to the next frame, still delivering the original exception: nothing is
//! copied, re-raised or caught on the way, so the panic count, the hook, `__except` filters
//! and foreign exceptions behave as through native frames.
//!
//! [`decide`] is the handler's logic, without the OS: tested on every host.

use ryo_bytecode::asm::lsda;
use ryo_bytecode::image::PeHandlerData;

/// `EXCEPTION_UNWINDING`: the record's flag in the unwind phase.
pub const EXCEPTION_UNWINDING: u32 = 0x2;
/// `EXCEPTION_EXIT_UNWIND`: an unwind without a target frame.
pub const EXCEPTION_EXIT_UNWIND: u32 = 0x4;
/// `EXCEPTION_TARGET_UNWIND`: the frame is the unwind's target.
pub const EXCEPTION_TARGET_UNWIND: u32 = 0x20;
/// The exception code of MSVC's C++ `throw` (`'msc' | 0xE0000000`), and of Rust panics.
pub const CXX_EXCEPTION: u32 = 0xE06D_7363;

/// Whether a record of `code` whose first parameter is `magic` (with `params` parameters) is
/// a C++ exception: `_CxxThrowException`'s, whose parameters start with one of the
/// `EH_MAGIC_NUMBER`s.
pub fn is_cxx(code: u32, params: u32, magic: usize) -> bool {
    code == CXX_EXCEPTION && params >= 3 && matches!(magic, 0x1993_0520..=0x1993_0522)
}

/// What the handler does for one VM frame.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Action {
    /// Nothing: `ExceptionContinueSearch`.
    Continue,
    /// Calls the cleanup landing pad at this offset from the function's start, then
    /// continues.
    CallPad(u32),
    /// Catches the exception for the terminate stub's landing pad at this offset:
    /// `RtlUnwindEx` to it.
    UnwindTo(u32),
    /// Aborts with this message.
    Abort(&'static str),
}

/// The handler's action for the frame of a VM function whose handler data is `data`, its
/// pc `pc` bytes past the function's start (a return address: the call before it is the call
/// site), for an exception record with `flags` that is ([`is_cxx`]) a C++ exception or not.
pub fn decide(flags: u32, cxx: bool, pc: u32, data: &PeHandlerData<'_>) -> Action {
    let unwinding = flags & (EXCEPTION_UNWINDING | EXCEPTION_EXIT_UNWIND) != 0;
    let Some(site) = lsda::find(data.lsda, pc.wrapping_sub(1)) else { return Action::Abort("a VM function's LSDA is invalid") };
    match site {
        // A call that can't unwind (as on ELF, where the personality finds no call site).
        None if cxx && !unwinding => Action::Abort("an exception unwinds out of a VM call that can't unwind"),
        None => Action::Continue,
        Some(s) => match (s.pad, s.catch) {
            (None, _) => Action::Continue,
            // A terminate stub's pad catches every C++ exception, as rustc's catch-all
            // terminate pads; non-C++ exceptions (`catch (...)` doesn't take them) pass.
            (Some(pad), true) if cxx && !unwinding => Action::UnwindTo(pad),
            (Some(_), true) => Action::Continue,
            // Cleanups run while the frame is unwound, for every exception (a C++ catch's
            // unwind is `STATUS_UNWIND_CONSOLIDATE`'s), but not in the frame the unwind
            // goes to.
            (Some(pad), false) if unwinding && flags & EXCEPTION_TARGET_UNWIND == 0 => Action::CallPad(pad),
            (Some(_), false) => Action::Continue,
        },
    }
}

#[cfg(windows)]
#[cfg_attr(not(feature = "jit"), allow(unused_imports))]
pub(crate) use win::handler;

#[cfg(windows)]
mod win {
    use core::ffi::c_void;

    use ryo_bytecode::image::PeHandlerData;

    use super::{Action, decide, is_cxx};
    use crate::vm::sys::fatal;

    /// `EXCEPTION_RECORD` (x64).
    #[repr(C)]
    pub struct ExceptionRecord {
        code: u32,
        flags: u32,
        record: *mut ExceptionRecord,
        address: *mut c_void,
        params: u32,
        info: [usize; 15],
    }

    /// `RUNTIME_FUNCTION`.
    #[repr(C)]
    struct RuntimeFunction {
        begin: u32,
        end: u32,
        unwind: u32,
    }

    /// `DISPATCHER_CONTEXT` (x64).
    #[repr(C)]
    pub struct DispatcherContext {
        control_pc: u64,
        image_base: u64,
        function_entry: *const RuntimeFunction,
        establisher_frame: u64,
        target_ip: u64,
        context: *mut Context,
        language_handler: *const c_void,
        handler_data: *const u8,
        history_table: *mut c_void,
        scope_index: u32,
        fill0: u32,
    }

    /// `CONTEXT` (x64): only its size and alignment matter here; [`ryo_seh_call_pad`] reads
    /// the nonvolatile registers at their offsets.
    #[repr(C, align(16))]
    pub struct Context([u8; 0x4d0]);

    const EXCEPTION_CONTINUE_SEARCH: u32 = 1;

    #[link(name = "kernel32")]
    unsafe extern "system" {
        /// Unwinds to `target_ip` in the frame `target_frame`, delivering `rec`, with `ret`
        /// in `rax` there; `ctx` is scratch for the unwind. Doesn't return.
        fn RtlUnwindEx(
            target_frame: *mut c_void,
            target_ip: *mut c_void,
            rec: *mut ExceptionRecord,
            ret: *mut c_void,
            ctx: *mut Context,
            history: *mut c_void,
        );
    }

    unsafe extern "system" {
        /// Calls the landing pad `pad` through the pad region's entry `region`, with the
        /// nonvolatile registers of the VM frame (`ctx`, the context the unwinder unwound into
        /// it) and the exception object `obj` in `rax`, on the current stack (below this
        /// handler), and returns once the pad's `resume` does (`global_asm!` below).
        fn ryo_seh_call_pad(ctx: *const Context, region: usize, pad: usize, obj: *mut ExceptionRecord);
    }

    /// The language handler of every VM function's `UNWIND_INFO` on PE ([`super::decide`]).
    ///
    /// # Safety
    /// Called by the system's exception dispatcher, with the handler data the image writer
    /// put after the `UNWIND_INFO`.
    #[rustc_std_internal_symbol]
    #[unsafe(export_name = "ryo_seh_handler")]
    pub unsafe extern "system-unwind" fn handler(
        rec: *mut ExceptionRecord,
        establisher: *mut c_void,
        _ctx: *mut Context,
        dc: *mut DispatcherContext,
    ) -> u32 {
        // SAFETY: the dispatcher's arguments, valid for the call; the handler data is the
        // image writer's (or the JIT's) `pe_handler_data`.
        unsafe {
            let dc = &*dc;
            let Some(data) = PeHandlerData::from_ptr(dc.handler_data) else { fatal("a VM function's handler data is invalid") };
            let begin = dc.image_base.wrapping_add((*dc.function_entry).begin as u64);
            let func = begin.wrapping_sub(data.begin as u64);
            let pc = dc.control_pc.wrapping_sub(func) as u32;
            let r = &*rec;
            let cxx = is_cxx(r.code, r.params, r.info[0]);
            match decide(r.flags, cxx, pc, &data) {
                Action::Continue => {}
                Action::CallPad(pad) => {
                    ryo_seh_call_pad(dc.context, (func + data.region as u64) as usize, (func + pad as u64) as usize, rec);
                }
                Action::UnwindTo(pad) => {
                    let mut scratch = Context([0; 0x4d0]);
                    RtlUnwindEx(establisher, (func + pad as u64) as *mut c_void, rec, rec.cast(), &mut scratch, dc.history_table);
                    fatal("RtlUnwindEx returned");
                }
                Action::Abort(msg) => fatal(msg),
            }
            EXCEPTION_CONTINUE_SEARCH
        }
    }
}

// `ryo_seh_call_pad(ctx, region, pad, obj)` (Win64): saves its own nonvolatile registers
// (`rbx`, `rbp`, `rdi`, `rsi`, `r12`–`r15`, `xmm6`–`xmm15`), loads the VM frame's from the
// `CONTEXT` at `rcx` (`rbp` its `fp`, the rest what the JIT's SSA tier may keep there), puts
// the exception object in `rax` and the pad in `r11`, and calls the pad region's entry, which
// allocates the region's frame below and jumps to the pad. `rsp` is 16-aligned at the call. Its
// own unwind information makes the frames of the region and of the code it calls walk back
// through it into the handler and the unwinder's frames.
#[cfg(windows)]
core::arch::global_asm!(
    ".text",
    ".globl ryo_seh_call_pad",
    ".p2align 4",
    "ryo_seh_call_pad:",
    ".seh_proc ryo_seh_call_pad",
    "push rbp",
    ".seh_pushreg rbp",
    "push rbx",
    ".seh_pushreg rbx",
    "push rdi",
    ".seh_pushreg rdi",
    "push rsi",
    ".seh_pushreg rsi",
    "push r12",
    ".seh_pushreg r12",
    "push r13",
    ".seh_pushreg r13",
    "push r14",
    ".seh_pushreg r14",
    "push r15",
    ".seh_pushreg r15",
    "sub rsp, 168",
    ".seh_stackalloc 168",
    "movaps [rsp], xmm6",
    ".seh_savexmm xmm6, 0",
    "movaps [rsp + 16], xmm7",
    ".seh_savexmm xmm7, 16",
    "movaps [rsp + 32], xmm8",
    ".seh_savexmm xmm8, 32",
    "movaps [rsp + 48], xmm9",
    ".seh_savexmm xmm9, 48",
    "movaps [rsp + 64], xmm10",
    ".seh_savexmm xmm10, 64",
    "movaps [rsp + 80], xmm11",
    ".seh_savexmm xmm11, 80",
    "movaps [rsp + 96], xmm12",
    ".seh_savexmm xmm12, 96",
    "movaps [rsp + 112], xmm13",
    ".seh_savexmm xmm13, 112",
    "movaps [rsp + 128], xmm14",
    ".seh_savexmm xmm14, 128",
    "movaps [rsp + 144], xmm15",
    ".seh_savexmm xmm15, 144",
    ".seh_endprologue",
    "mov rax, r9",
    "mov r11, r8",
    "mov rbx, [rcx + 0x90]",
    "mov rbp, [rcx + 0xa0]",
    "mov rsi, [rcx + 0xa8]",
    "mov rdi, [rcx + 0xb0]",
    "mov r12, [rcx + 0xd8]",
    "mov r13, [rcx + 0xe0]",
    "mov r14, [rcx + 0xe8]",
    "mov r15, [rcx + 0xf0]",
    "movaps xmm6, [rcx + 0x200]",
    "movaps xmm7, [rcx + 0x210]",
    "movaps xmm8, [rcx + 0x220]",
    "movaps xmm9, [rcx + 0x230]",
    "movaps xmm10, [rcx + 0x240]",
    "movaps xmm11, [rcx + 0x250]",
    "movaps xmm12, [rcx + 0x260]",
    "movaps xmm13, [rcx + 0x270]",
    "movaps xmm14, [rcx + 0x280]",
    "movaps xmm15, [rcx + 0x290]",
    "call rdx",
    "movaps xmm6, [rsp]",
    "movaps xmm7, [rsp + 16]",
    "movaps xmm8, [rsp + 32]",
    "movaps xmm9, [rsp + 48]",
    "movaps xmm10, [rsp + 64]",
    "movaps xmm11, [rsp + 80]",
    "movaps xmm12, [rsp + 96]",
    "movaps xmm13, [rsp + 112]",
    "movaps xmm14, [rsp + 128]",
    "movaps xmm15, [rsp + 144]",
    "add rsp, 168",
    "pop r15",
    "pop r14",
    "pop r13",
    "pop r12",
    "pop rsi",
    "pop rdi",
    "pop rbx",
    "pop rbp",
    "ret",
    ".seh_endproc",
);

#[cfg(test)]
mod tests {
    use ryo_bytecode::asm::{CallSite, lsda};
    use ryo_bytecode::image::{PeHandlerData, pe_handler_data};

    use super::*;

    /// Synthetic call sites: a call that continues at 0, one with a cleanup pad at 10, a
    /// terminate pad's at 20 (the body's), and in the pad region from 96 a call with the
    /// region's terminate pad at 110.
    fn data() -> Vec<u8> {
        let sites = [
            CallSite { start: 0, len: 5, pad: None, catch: false },
            CallSite { start: 10, len: 5, pad: Some(103), catch: false },
            CallSite { start: 20, len: 6, pad: Some(80), catch: true },
            CallSite { start: 110, len: 5, pad: Some(140), catch: true },
        ];
        pe_handler_data(0, 96, &lsda::write(&sites))
    }

    #[test]
    fn decides() {
        let bytes = data();
        let d = PeHandlerData::parse(&bytes).unwrap();
        let (search, unwind, target) = (0, EXCEPTION_UNWINDING, EXCEPTION_UNWINDING | EXCEPTION_TARGET_UNWIND);
        // `pc` is a return address: the call ends there.
        let cases = [
            // Continue sites: nothing, in both phases.
            (search, true, 5, Action::Continue),
            (unwind, true, 5, Action::Continue),
            // A cleanup pad runs in the unwind phase only (for every exception), not in the
            // unwind's target frame.
            (search, true, 15, Action::Continue),
            (unwind, true, 15, Action::CallPad(103)),
            (unwind, false, 15, Action::CallPad(103)),
            (EXCEPTION_EXIT_UNWIND, false, 15, Action::CallPad(103)),
            (target, true, 15, Action::Continue),
            // A terminate pad catches C++ exceptions in the search phase.
            (search, true, 26, Action::UnwindTo(80)),
            (search, false, 26, Action::Continue),
            (unwind, true, 26, Action::Continue),
            (target, true, 26, Action::Continue),
            // The region's call site, the same.
            (search, true, 115, Action::UnwindTo(140)),
            (unwind, true, 115, Action::Continue),
            // No call site: a C++ exception aborts in the search phase, others pass.
            (search, true, 9, Action::Abort("an exception unwinds out of a VM call that can't unwind")),
            (search, false, 9, Action::Continue),
            (unwind, true, 9, Action::Continue),
            // The pc right after a call isn't in the next one.
            (search, true, 10, Action::Abort("an exception unwinds out of a VM call that can't unwind")),
        ];
        for (flags, cxx, pc, want) in cases {
            assert_eq!(decide(flags, cxx, pc, &d), want, "flags {flags:#x} cxx {cxx} pc {pc}");
        }
        let bad = PeHandlerData { lsda: &[1, 2, 3], ..d };
        assert_eq!(decide(search, true, 15, &bad), Action::Abort("a VM function's LSDA is invalid"));
    }

    #[test]
    fn classifies() {
        assert!(is_cxx(CXX_EXCEPTION, 4, 0x1993_0520));
        assert!(is_cxx(CXX_EXCEPTION, 3, 0x1993_0522));
        assert!(!is_cxx(CXX_EXCEPTION, 4, 0x1993_0523));
        assert!(!is_cxx(CXX_EXCEPTION, 2, 0x1993_0520));
        // An access violation.
        assert!(!is_cxx(0xC000_0005, 2, 0));
    }
}
