//! The VM: entry from portals, the handlers, the registry and per-thread state. See
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
mod thread;

pub use registry::{Function, ImageRt};
pub use interp::{FP_ARG, MODE, h, handler, probe_stack};
pub use thread::VmThread;

use thread::Entry;

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

/// Pops an entry record. Runs on the normal return of `enter` and when a panic unwinds
/// through it, so the chain never points at a dead record. The same holds for forced
/// unwinding (`pthread_exit` from native code): it runs this guard like any other landing
/// pad, so each `enter` it passes is popped in order.
struct PopEntry {
    vm: *mut VmThread,
    rec: *mut Entry,
}

impl Drop for PopEntry {
    fn drop(&mut self) {
        // SAFETY: `rec` is the innermost record of this thread's `vm`, still alive (it is a
        // local of the `enter` frame this guard belongs to).
        unsafe { (*self.vm).entry = (*self.rec).prev };
    }
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
    let vm = thread::current();
    let f = registry::resolve_id(id);
    // SAFETY: `vm` is this thread's state, reached only through the raw pointer. `rec` lives
    // until `PopEntry` unlinks it at the end of this function.
    unsafe {
        let mut rec = Entry { prev: (*vm).entry, ret };
        let rec = &raw mut rec;
        (*vm).entry = rec;
        let _pop = PopEntry { vm, rec };
        ryo_asm_enter(f.entry, args, f.arg_size as usize);
    }
}

unsafe extern "Rust" {
    /// Calls the VM function at `entry` with the `size`-byte argument block at `args`
    /// (design/vm.md, "Entry"): reserves and copies the block, and calls it with `rbp = 0`,
    /// so its frame has a null caller fp and `ret` writes to the entry record. Panics unwind
    /// through it. The Rust ABI, so the call may unwind without being an FFI call.
    fn ryo_asm_enter(entry: *const u8, args: *const u8, size: usize);
}

// The frame of `ryo_asm_enter` is addressed through `rbx`: `rbp` is 0 while VM code runs
// (the null caller fp of the entry frame), and the reserved size is dynamic.
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
    "lea rcx, [rdx + 15]",
    "and rcx, -16",
    "sub rsp, 8",
    "sub rsp, rcx",
    "mov rax, rdi",
    "mov rdi, rsp",
    "mov rcx, rdx",
    "rep movsb",
    "xor ebp, ebp",
    "call rax",
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
    "lea rax, [r8 + 15]",
    "and rax, -16",
    "sub rsp, rax",
    "mov rax, rcx",
    "mov rsi, rdx",
    "mov rdi, rsp",
    "mov rcx, r8",
    "rep movsb",
    "xor ebp, ebp",
    "call rax",
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
