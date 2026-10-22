//! The VM: entry from portals, the handlers and the registry. See
//! design/vm.md.
//!
//! - [`enter`]: entry from portals.
//! - [`ryo_vm_register`]: image registration, called by the registry object's constructor.
//! - [`lookup_addr`]: portal address → VM function.
//!
//! Everything reachable from these uses `core` and OS calls only (no std allocator, locks or
//! TLS), so it never re-enters the VM (design/vm.md, "No re-entry into the VM from the
//! runtime").

mod interp;
mod registry;
mod sys;

use core::ptr;

use ryo_bytecode::asm;

pub use registry::{Function, ImageRt};
pub use interp::{FP_ARG, MODE, h, handler, probe_stack};

/// Registers `n` images. `images[i]` is the address of an image header
/// (`__ryo_image_<StableCrateId>`). Called by each link unit's registry object constructor,
/// including for shared objects loaded at run time. Images already registered are skipped.
/// Aborts on an invalid image or a crate hash collision.
///
/// # Safety
/// `images` must point at `n` pointers to linked images that stay mapped and unchanged for the
/// rest of the process (images are never unregistered).
///
/// `C-unwind`, so the compiler adds no abort-on-unwind guard, which would reference core's
/// panic path (design/vm.md, "No re-entry"); nothing in it panics (`y test`'s `rt-core-only`).
#[unsafe(no_mangle)]
pub unsafe extern "C-unwind" fn ryo_vm_register(images: *const *const u8, n: usize) {
    // SAFETY: per the caller.
    unsafe { registry::register(images, n) }
}

/// Maps the address of a VM function's portal to its function record, or `None` if `addr`
/// isn't the portal of a registered VM function.
pub fn lookup_addr(addr: *const ()) -> Option<&'static Function> {
    registry::lookup_addr(addr)
}

#[cfg(feature = "registry-anchor")]
unsafe extern "C" {
    /// Defined by the registry object of each final link (design/backend.md).
    static __ryo_registry_anchor: u8;
}

/// Entry from portals: runs the VM function `id` (crate hash, function index) with the
/// argument block at `args`, and writes its return value to `ret`. A panic unwinds out of
/// it natively.
///
/// Works re-entrantly: the new frame goes on the native stack, below the caller's.
///
/// # Safety
/// `args` points at the callee's argument block, whose values the VM takes ownership of, and
/// `ret` is valid for writing the return value.
#[inline(never)]
pub unsafe fn enter(id: u64, args: *const u8, ret: *mut u8) {
    #[cfg(feature = "registry-anchor")]
    core::hint::black_box(&raw const __ryo_registry_anchor);

    if sys::trace_enabled() {
        sys::trace_enter(id);
    }
    sys::count(&sys::RUN_STATS.enters);
    let f = registry::resolve_id(id);
    // A value that doesn't return in registers comes back at the start of the block.
    let regs = asm::ret_in_regs(f.ret_size);
    let mem_len = if regs { 0 } else { f.ret_size as usize };
    let mut call = EnterCall {
        args,
        arg_size: f.arg_size as usize,
        reserve: (f.arg_size as usize).max(mem_len).next_multiple_of(16),
        regs: [0; 2],
        mem: ret,
        mem_len,
    };
    // SAFETY: per the caller; `ret` takes `ret_size` bytes.
    unsafe {
        ryo_asm_enter(f.entry, &mut call);
        if regs {
            ptr::copy_nonoverlapping(call.regs.as_ptr().cast::<u8>(), ret, f.ret_size as usize);
        }
    }
}

/// [`ryo_asm_enter`]'s operands and results (`repr(C)`: the assembly uses the offsets).
#[repr(C)]
struct EnterCall {
    /// The argument block, `arg_size` bytes.
    args: *const u8,
    arg_size: usize,
    /// The bytes to reserve for the block, a multiple of 16 of at least `arg_size` and the
    /// size of a value returned in the block.
    reserve: usize,
    /// `rax` and `rdx` after the call.
    regs: [u64; 2],
    /// Where to copy `mem_len` bytes from the block after the call.
    mem: *mut u8,
    mem_len: usize,
}

unsafe extern "Rust" {
    /// Calls the VM function at `entry` (design/vm.md, "Entry"): reserves and copies the
    /// argument block, and calls it with `rbp = 0`, so a frame-pointer chain ends at the
    /// entry frame. Afterwards it stores `rax` and `rdx`, and copies the start of the block,
    /// as `call` says. Panics unwind through it. The Rust ABI, so the call may unwind without
    /// being an FFI call.
    fn ryo_asm_enter(entry: *const u8, call: *mut EnterCall);
}

// The frame of `ryo_asm_enter` is addressed through `rbx`: `rbp` is 0 while VM code runs
// (the end of the frame-pointer chain), and the reserved size is dynamic.
#[cfg(not(windows))]
core::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".globl ryo_asm_enter",
    ".hidden ryo_asm_enter",
    ".type ryo_asm_enter, @function",
    "ryo_asm_enter:",
    ".cfi_startproc",
    "push rbp",
    ".cfi_def_cfa_offset 16",
    ".cfi_offset rbp, -16",
    "push rbx",
    ".cfi_def_cfa_offset 24",
    ".cfi_offset rbx, -24",
    "mov rbx, rsp",
    ".cfi_def_cfa_register rbx",
    "push rsi",
    "sub rsp, [rsi + 16]",
    "mov rax, rdi",
    "mov rdi, rsp",
    "mov rcx, [rsi + 8]",
    "mov rsi, [rsi]",
    "rep movsb",
    "xor ebp, ebp",
    "call rax",
    "mov rcx, [rbx - 8]",
    "mov [rcx + 24], rax",
    "mov [rcx + 32], rdx",
    "mov rdi, [rcx + 40]",
    "mov rsi, rsp",
    "mov rcx, [rcx + 48]",
    "rep movsb",
    "mov rsp, rbx",
    "pop rbx",
    ".cfi_def_cfa rsp, 16",
    "pop rbp",
    ".cfi_def_cfa_offset 8",
    "ret",
    ".cfi_endproc",
    ".size ryo_asm_enter, . - ryo_asm_enter",
);

// Win64: `rcx`, `rdx`, `r8`, and `rdi`, `rsi`, `xmm6`–`xmm15` are callee-saved here but not
// in the `sysv64` handlers, so they are saved too.
#[cfg(windows)]
core::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".globl ryo_asm_enter",
    ".def ryo_asm_enter; .scl 2; .type 32; .endef",
    "ryo_asm_enter:",
    ".seh_proc ryo_asm_enter",
    "push rbp",
    ".seh_pushreg rbp",
    "push rbx",
    ".seh_pushreg rbx",
    "push rdi",
    ".seh_pushreg rdi",
    "push rsi",
    ".seh_pushreg rsi",
    "sub rsp, 168",
    ".seh_stackalloc 168",
    "movaps [rsp + 0], xmm6",
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
    "lea rbx, [rsp + 160]",
    ".seh_setframe rbx, 160",
    ".seh_endprologue",
    "mov [rbx], rdx",
    "sub rsp, [rdx + 16]",
    "mov rax, rcx",
    "mov rsi, [rdx]",
    "mov rdi, rsp",
    "mov rcx, [rdx + 8]",
    "rep movsb",
    "xor ebp, ebp",
    "call rax",
    "mov rcx, [rbx]",
    "mov [rcx + 24], rax",
    "mov [rcx + 32], rdx",
    "mov rdi, [rcx + 40]",
    "mov rsi, rsp",
    "mov rcx, [rcx + 48]",
    "rep movsb",
    "lea rsp, [rbx - 160]",
    "movaps xmm6, [rsp + 0]",
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
    "pop rsi",
    "pop rdi",
    "pop rbx",
    "pop rbp",
    "ret",
    ".seh_endproc",
);
