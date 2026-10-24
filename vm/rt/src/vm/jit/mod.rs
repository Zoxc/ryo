//! The JIT (design/jit.md): recompiles hot functions on a background thread and
//! switches their entry over to the new code. This module is the runtime's side of it; the
//! JIT thread is the `ryo_jit` crate's, which sees the runtime only through the [`RtApi`]
//! that this side builds ([`ryo_bytecode::jit_abi`]), and starts with `ryo_jit_start`.
//!
//! - **Trips**: [`trip_entry`] and [`trip_osr`] are what a JIT record's `entry` and `osr`
//!   slots start at; a function's counter stub calls them when its counter runs out
//!   (design/vm.md, "JIT records and counters"). They queue the record if it is cold, reset
//!   the counter, and return into the AOT code; in a compiled function they continue into
//!   its JIT code instead (at a loop head through its OSR dispatcher). Lock-free: a CAS on
//!   the record's state, a push onto [`QUEUE`], and a futex wake if the JIT thread sleeps.
//!   They never compile or allocate, but the first push starts the JIT thread.
//! - **The JIT thread** takes the whole queue at once ([`next_batch`]), decodes each
//!   function from its image ([`ryo_bytecode::image::ImageResolver`]), encodes it again
//!   without counters, installs the code near the image with its unwind information, and
//!   publishes it in the record: `entry` (its [`JIT_ENTRY_PREFIX`]) and `osr` (its OSR
//!   dispatcher), then the state `Done`, then the counter [`REDIRECT`], so that every later
//!   call's and loop iteration's counter check takes its stub into the JIT code, a loop
//!   head's through an OSR entry that converts the AOT frame into the JIT one. It reports
//!   each record ([`done`]).
//!
//! This side uses `core` only, like the rest of the runtime (design/vm.md, "No re-entry"):
//! the settings come from the C runtime's `getenv`, and waiting is a futex (`WaitOnAddress`
//! on PE). Nothing on the trips'
//! path may unwind (the stubs aren't call sites), and nothing there does: the Rust parts
//! are `extern "C-unwind"` only so that the compiler adds no abort-on-unwind guard, which
//! would reach core's panic path (as for `ryo_vm_register`).

use core::cell::UnsafeCell;
use core::ffi::{CStr, c_char};
use core::mem::MaybeUninit;
use core::ptr;
use core::sync::atomic::Ordering::{AcqRel, Acquire, Relaxed, Release, SeqCst};
use core::sync::atomic::{AtomicBool, AtomicI64, AtomicPtr, AtomicU8, AtomicU32, AtomicUsize};

use ryo_bytecode::image::{Image, JIT_COLD, JIT_DONE, JIT_FAILED, JIT_QUEUED, JIT_THRESHOLD, JitRecord};
use ryo_bytecode::jit_abi::{JIT_ABI_VERSION, JIT_CHECK, JIT_LOG, JIT_OPT_SSA, JIT_OPT_SSA_NAIVE, JIT_PERFMAP, JIT_SYNC, JIT_TEST_PANIC, RtApi};

pub use ryo_bytecode::jit_abi::{JIT_ENTRY_PREFIX, REDIRECT};

use super::sys::fatal;

/// The settings, read once from the environment (or [`configure_jit`]).
struct Config {
    /// `RYO_JIT=off` turns the JIT into the no-op JIT.
    enabled: bool,
    /// `RYO_JIT_THRESHOLD`: what registration sets every counter to, and what a trip resets
    /// it to (default: the image's, [`JIT_THRESHOLD`]).
    threshold: Option<i64>,
    /// `RYO_JIT_SYNC=1`: a trip that queues a function waits until it is compiled (or failed)
    /// and continues in its JIT code, so threshold 0 runs every function's JIT code from its
    /// first call (tests).
    sync: bool,
    /// `RYO_JIT_PERFMAP=1`: a line per compiled function in `/tmp/perf-<pid>.map`.
    perfmap: bool,
    /// `RYO_JIT_LOG=1`: a line on stderr per compiled or failed function.
    log: bool,
    /// `RYO_JIT_SHUFFLE=1`: JIT code gets another frame layout than the AOT code's
    /// (`asm::frame::shuffle_map`), so that OSR entries convert frames (tests).
    shuffle: bool,
    /// `RYO_JIT_TEST_PANIC=1`: every compile panics (tests: the JIT catches its panics even in
    /// a `-Cpanic=abort` program).
    test_panic: bool,
    /// `RYO_JIT_OPT`: `reencode` (the default), `ssa-naive` or `ssa`: how the JIT compiles
    /// (design/jit.md, "The SSA tier"), as [`RtApi::flags`] bits.
    opt: u32,
    /// `RYO_JIT_CHECK=1`: the SSA tier's checkers.
    check: bool,
}

/// `RYO_JIT_OPT`'s flag bits.
fn opt_flags() -> u32 {
    match var(c"RYO_JIT_OPT") {
        Some(b"ssa-naive") => JIT_OPT_SSA_NAIVE,
        Some(b"ssa") => JIT_OPT_SSA,
        _ => 0,
    }
}

/// A static written once, before [`READY`] is published.
struct Once<T>(UnsafeCell<MaybeUninit<T>>);

// SAFETY: written by one thread before a release store that every reader acquires.
unsafe impl<T> Sync for Once<T> {}

const UNINIT: u8 = 0;
const BUSY: u8 = 1;
const READY: u8 = 2;

/// [`CONFIG`]'s state: [`UNINIT`], then [`BUSY`] while one thread writes it, then [`READY`].
static CONFIG_STATE: AtomicU8 = AtomicU8::new(UNINIT);
static CONFIG: Once<Config> = Once(UnsafeCell::new(MaybeUninit::uninit()));

fn config() -> &'static Config {
    loop {
        match CONFIG_STATE.load(Acquire) {
            // SAFETY: written before `READY` was published, never again.
            READY => return unsafe { (*CONFIG.0.get()).assume_init_ref() },
            UNINIT => {
                set_config(from_env);
            }
            // Another thread reads the environment: a few `getenv`s.
            _ => core::hint::spin_loop(),
        }
    }
}

/// Sets the settings to `make()` unless something else set them first. False if it did.
fn set_config(make: impl FnOnce() -> Config) -> bool {
    if CONFIG_STATE.compare_exchange(UNINIT, BUSY, Acquire, Relaxed).is_err() {
        return false;
    }
    // SAFETY: only the thread that moved the state to `BUSY` writes, and nothing reads until
    // `READY`.
    unsafe { (*CONFIG.0.get()).write(make()) };
    CONFIG_STATE.store(READY, Release);
    true
}

unsafe extern "C" {
    fn getenv(name: *const c_char) -> *const c_char;
}

/// The environment variable `name`'s value, if it is set.
fn var(name: &CStr) -> Option<&'static [u8]> {
    // SAFETY: a NUL-terminated name; the value stays valid unless the program changes the
    // environment, which it may not while other threads read it (as for std's `env::var`).
    unsafe {
        let v = getenv(name.as_ptr());
        (!v.is_null()).then(|| CStr::from_ptr(v).to_bytes())
    }
}

/// A decimal `i64`, with an optional sign; `None` if it isn't one or doesn't fit.
fn parse_i64(s: &[u8]) -> Option<i64> {
    let (neg, digits) = match s {
        [b'-', rest @ ..] => (true, rest),
        [b'+', rest @ ..] => (false, rest),
        _ => (false, s),
    };
    if digits.is_empty() {
        return None;
    }
    let mut n: i64 = 0;
    for &d in digits {
        if !d.is_ascii_digit() {
            return None;
        }
        let d = (d - b'0') as i64;
        n = n.checked_mul(10)?;
        n = if neg { n.checked_sub(d)? } else { n.checked_add(d)? };
    }
    Some(n)
}

fn from_env() -> Config {
    let flag = |name: &CStr| var(name) == Some(b"1");
    Config {
        enabled: var(c"RYO_JIT") != Some(b"off"),
        threshold: var(c"RYO_JIT_THRESHOLD").and_then(parse_i64).map(|t| t.max(0)),
        sync: flag(c"RYO_JIT_SYNC"),
        perfmap: flag(c"RYO_JIT_PERFMAP"),
        log: flag(c"RYO_JIT_LOG"),
        shuffle: flag(c"RYO_JIT_SHUFFLE"),
        test_panic: flag(c"RYO_JIT_TEST_PANIC"),
        opt: opt_flags(),
        check: flag(c"RYO_JIT_CHECK"),
    }
}

impl Config {
    fn threshold(&self) -> i64 {
        self.threshold.unwrap_or(JIT_THRESHOLD)
    }
}

/// Sets the JIT's settings instead of the environment, before anything reads them (tests):
/// on, with `sync` ([`Config::sync`]) and `threshold` (as `RYO_JIT_THRESHOLD`), and
/// `RYO_JIT_LOG`, `RYO_JIT_OPT` and `RYO_JIT_CHECK` from the environment. False if they were
/// read already.
#[doc(hidden)]
pub fn configure_jit(sync: bool, threshold: Option<i64>) -> bool {
    set_config(|| Config {
        enabled: true,
        threshold,
        sync,
        perfmap: false,
        log: var(c"RYO_JIT_LOG").is_some(),
        shuffle: false,
        test_panic: false,
        opt: opt_flags(),
        check: var(c"RYO_JIT_CHECK") == Some(b"1"),
    })
}

/// The images whose functions the JIT compiles with another frame layout, as with
/// `RYO_JIT_SHUFFLE` (tests), by header address; 0 for a free entry.
static SHUFFLED: [AtomicUsize; 256] = [const { AtomicUsize::new(0) }; 256];

/// Compiles the functions of the image with header `header` with another frame layout than
/// their AOT code's, as `RYO_JIT_SHUFFLE=1` does for all (tests).
#[doc(hidden)]
pub fn jit_shuffle_image(header: *const u8) {
    if !SHUFFLED.iter().any(|s| s.compare_exchange(0, header as usize, SeqCst, SeqCst).is_ok()) {
        fatal("jit_shuffle_image: too many images");
    }
}

/// [`RtApi::shuffled`]: whether the image with header `header` gets shuffled frames.
extern "C-unwind" fn shuffled(header: *const u8) -> bool {
    config().shuffle || SHUFFLED.iter().any(|s| s.load(SeqCst) == header as usize)
}

/// How many functions the JIT compiled, and how many it failed to (tests).
#[doc(hidden)]
pub fn jit_stats() -> (usize, usize) {
    (COMPILED.load(Relaxed), FAILED.load(Relaxed))
}

static COMPILED: AtomicUsize = AtomicUsize::new(0);
static FAILED: AtomicUsize = AtomicUsize::new(0);

/// The queue of records to compile: a Treiber stack linked through [`JitRecord::next`]. Only
/// a trip that moved a record from `Cold` to `Queued` pushes it, so each record is pushed at
/// most once, and the JIT thread, the only consumer, takes the whole stack at once: no ABA.
static QUEUE: AtomicPtr<JitRecord> = AtomicPtr::new(ptr::null_mut());
/// Bumped after every push; the JIT thread sleeps on it (futex).
static WAKE: AtomicU32 = AtomicU32::new(0);
/// The JIT thread is asleep or about to be: a push must wake it.
static SLEEPING: AtomicBool = AtomicBool::new(false);
/// The first push started the JIT thread.
static STARTED: AtomicBool = AtomicBool::new(false);
/// The JIT thread couldn't be started: the trips act as the no-op JIT.
static DISABLED: AtomicBool = AtomicBool::new(false);

// The record's fields the trips and the JIT thread share with the counter checks, which read
// and write them with plain instructions: atomics of their size.
fn ctr(r: *mut JitRecord) -> &'static AtomicI64 {
    // SAFETY: records live in images' writable sections forever; `ctr` is 8-aligned.
    unsafe { AtomicI64::from_ptr(&raw mut (*r).ctr) }
}
fn entry(r: *mut JitRecord) -> &'static AtomicPtr<u8> {
    // SAFETY: as for `ctr`.
    unsafe { AtomicPtr::from_ptr((&raw mut (*r).entry).cast::<*mut u8>()) }
}
fn osr_slot(r: *mut JitRecord) -> &'static AtomicPtr<u8> {
    // SAFETY: as for `ctr`.
    unsafe { AtomicPtr::from_ptr((&raw mut (*r).osr).cast::<*mut u8>()) }
}
fn state(r: *mut JitRecord) -> &'static AtomicU32 {
    // SAFETY: as for `ctr`.
    unsafe { &(*r).state }
}

/// The trip of a function's entry: `r11` is its JIT record, `rsp` 16-aligned (the caller's
/// and the stub's return addresses are on it), the argument registers live. Saves them,
/// calls [`entry_trip`], restores them, and returns into the AOT code, or jumps to the JIT
/// entry [`entry_trip`] gives, which drops the stub's return address
/// ([`JIT_ENTRY_PREFIX`]). Clobbers `rax` and `r11`, which carry nothing at an entry. On PE
/// it also saves `xmm8`–`xmm15`, callee-saved on Win64 but not for the `sysv64` Rust code
/// it calls (`rdi`, `rsi`, `xmm6` and `xmm7` are among the argument registers it saves
/// anyway), in a 320-byte area instead of 192.
#[cfg(not(windows))]
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = "ryo_jit_trip_entry")]
pub unsafe extern "sysv64" fn trip_entry() {
    core::arch::naked_asm!(
        ".cfi_startproc",
        "sub rsp, 192",
        ".cfi_adjust_cfa_offset 192",
        "mov [rsp], rdi",
        "mov [rsp + 8], rsi",
        "mov [rsp + 16], rdx",
        "mov [rsp + 24], rcx",
        "mov [rsp + 32], r8",
        "mov [rsp + 40], r9",
        "movaps [rsp + 48], xmm0",
        "movaps [rsp + 64], xmm1",
        "movaps [rsp + 80], xmm2",
        "movaps [rsp + 96], xmm3",
        "movaps [rsp + 112], xmm4",
        "movaps [rsp + 128], xmm5",
        "movaps [rsp + 144], xmm6",
        "movaps [rsp + 160], xmm7",
        "mov rdi, r11",
        "call {trip}",
        "mov r11, rax",
        "mov rdi, [rsp]",
        "mov rsi, [rsp + 8]",
        "mov rdx, [rsp + 16]",
        "mov rcx, [rsp + 24]",
        "mov r8, [rsp + 32]",
        "mov r9, [rsp + 40]",
        "movaps xmm0, [rsp + 48]",
        "movaps xmm1, [rsp + 64]",
        "movaps xmm2, [rsp + 80]",
        "movaps xmm3, [rsp + 96]",
        "movaps xmm4, [rsp + 112]",
        "movaps xmm5, [rsp + 128]",
        "movaps xmm6, [rsp + 144]",
        "movaps xmm7, [rsp + 160]",
        "add rsp, 192",
        ".cfi_adjust_cfa_offset -192",
        "test r11, r11",
        "jz 2f",
        "jmp r11",
        "2:",
        "ret",
        ".cfi_endproc",
        trip = sym entry_trip,
    );
}
#[cfg(windows)]
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = "ryo_jit_trip_entry")]
pub unsafe extern "sysv64" fn trip_entry() {
    core::arch::naked_asm!(
        ".cfi_startproc",
        "sub rsp, 320",
        ".cfi_adjust_cfa_offset 320",
        "mov [rsp], rdi",
        "mov [rsp + 8], rsi",
        "mov [rsp + 16], rdx",
        "mov [rsp + 24], rcx",
        "mov [rsp + 32], r8",
        "mov [rsp + 40], r9",
        "movaps [rsp + 48], xmm0",
        "movaps [rsp + 64], xmm1",
        "movaps [rsp + 80], xmm2",
        "movaps [rsp + 96], xmm3",
        "movaps [rsp + 112], xmm4",
        "movaps [rsp + 128], xmm5",
        "movaps [rsp + 144], xmm6",
        "movaps [rsp + 160], xmm7",
        "movaps [rsp + 176], xmm8",
        "movaps [rsp + 192], xmm9",
        "movaps [rsp + 208], xmm10",
        "movaps [rsp + 224], xmm11",
        "movaps [rsp + 240], xmm12",
        "movaps [rsp + 256], xmm13",
        "movaps [rsp + 272], xmm14",
        "movaps [rsp + 288], xmm15",
        "mov rdi, r11",
        "call {trip}",
        "mov r11, rax",
        "mov rdi, [rsp]",
        "mov rsi, [rsp + 8]",
        "mov rdx, [rsp + 16]",
        "mov rcx, [rsp + 24]",
        "mov r8, [rsp + 32]",
        "mov r9, [rsp + 40]",
        "movaps xmm0, [rsp + 48]",
        "movaps xmm1, [rsp + 64]",
        "movaps xmm2, [rsp + 80]",
        "movaps xmm3, [rsp + 96]",
        "movaps xmm4, [rsp + 112]",
        "movaps xmm5, [rsp + 128]",
        "movaps xmm6, [rsp + 144]",
        "movaps xmm7, [rsp + 160]",
        "movaps xmm8, [rsp + 176]",
        "movaps xmm9, [rsp + 192]",
        "movaps xmm10, [rsp + 208]",
        "movaps xmm11, [rsp + 224]",
        "movaps xmm12, [rsp + 240]",
        "movaps xmm13, [rsp + 256]",
        "movaps xmm14, [rsp + 272]",
        "movaps xmm15, [rsp + 288]",
        "add rsp, 320",
        ".cfi_adjust_cfa_offset -320",
        "test r11, r11",
        "jz 2f",
        "jmp r11",
        "2:",
        "ret",
        ".cfi_endproc",
        trip = sym entry_trip,
    );
}

/// The trip of a loop head: `r11` is the JIT record, `eax` the head's index, `rsp + 8`
/// 16-aligned, nothing live but `rsp` and `rbp`. A compiled function's head jumps to its OSR
/// dispatcher, in the record's `osr` slot since before it was `Done` (the stubs call it
/// directly then, so this is only for a stub that read the slot before). Else
/// [`osr_trip`], keeping `eax`, and on to the dispatcher if that compiled it (`RYO_JIT_SYNC`),
/// else back to the AOT code. On PE it also saves `xmm6`–`xmm15`, which VM code leaves to its
/// caller (design/platforms.md) and the `sysv64` Rust code may clobber; `rdi` and `rsi` the
/// prologue saved.
#[cfg(not(windows))]
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = "ryo_jit_trip_osr")]
pub unsafe extern "sysv64" fn trip_osr() {
    core::arch::naked_asm!(
        ".cfi_startproc",
        "cmp dword ptr [r11 + {state}], {done}",
        "jne 2f",
        "jmp qword ptr [r11 + {osr}]",
        "2:",
        "push rax",
        ".cfi_adjust_cfa_offset 8",
        "mov rdi, r11",
        "call {trip}",
        "mov r11, rax",
        "pop rax",
        ".cfi_adjust_cfa_offset -8",
        "test r11, r11",
        "jz 3f",
        "jmp r11",
        "3:",
        "ret",
        ".cfi_endproc",
        state = const core::mem::offset_of!(JitRecord, state),
        done = const JIT_DONE,
        osr = const core::mem::offset_of!(JitRecord, osr),
        trip = sym osr_trip,
    );
}
#[cfg(windows)]
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = "ryo_jit_trip_osr")]
pub unsafe extern "sysv64" fn trip_osr() {
    core::arch::naked_asm!(
        ".cfi_startproc",
        "cmp dword ptr [r11 + {state}], {done}",
        "jne 2f",
        "jmp qword ptr [r11 + {osr}]",
        "2:",
        "push rax",
        ".cfi_adjust_cfa_offset 8",
        "sub rsp, 160",
        ".cfi_adjust_cfa_offset 160",
        "movaps [rsp + 0], xmm6",
        "movaps [rsp + 16], xmm7",
        "movaps [rsp + 32], xmm8",
        "movaps [rsp + 48], xmm9",
        "movaps [rsp + 64], xmm10",
        "movaps [rsp + 80], xmm11",
        "movaps [rsp + 96], xmm12",
        "movaps [rsp + 112], xmm13",
        "movaps [rsp + 128], xmm14",
        "movaps [rsp + 144], xmm15",
        "mov rdi, r11",
        "call {trip}",
        "mov r11, rax",
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
        "add rsp, 160",
        ".cfi_adjust_cfa_offset -160",
        "pop rax",
        ".cfi_adjust_cfa_offset -8",
        "test r11, r11",
        "jz 3f",
        "jmp r11",
        "3:",
        "ret",
        ".cfi_endproc",
        state = const core::mem::offset_of!(JitRecord, state),
        done = const JIT_DONE,
        osr = const core::mem::offset_of!(JitRecord, osr),
        trip = sym osr_trip,
    );
}

/// [`trip_entry`]'s work: the JIT entry to continue at, or null to continue in AOT code.
extern "sysv64-unwind" fn entry_trip(rec: *mut JitRecord) -> *const u8 {
    if trip(rec) == JIT_DONE {
        ctr(rec).store(REDIRECT, Relaxed);
        return entry(rec).load(Acquire);
    }
    ptr::null()
}

/// [`trip_osr`]'s work: the OSR dispatcher to continue at, or null to continue in AOT code.
extern "sysv64-unwind" fn osr_trip(rec: *mut JitRecord) -> *const u8 {
    if trip(rec) == JIT_DONE {
        return osr_slot(rec).load(Acquire);
    }
    ptr::null()
}

/// What both trips do: queues the record if it is cold, and resets its counter: to the
/// threshold while it is queued, out of reach (`i64::MAX`) once it failed or without a JIT,
/// and not at all once it is compiled. With [`Config::sync`], waits for a queued record to
/// be compiled. Returns the record's state.
fn trip(rec: *mut JitRecord) -> u32 {
    let cfg = config();
    if !cfg.enabled || DISABLED.load(Relaxed) {
        ctr(rec).store(i64::MAX, Relaxed);
        return JIT_COLD;
    }
    let mut st = state(rec).load(Acquire);
    if st == JIT_COLD && state(rec).compare_exchange(JIT_COLD, JIT_QUEUED, AcqRel, Acquire).is_ok() {
        push(rec);
    }
    st = state(rec).load(SeqCst);
    if st == JIT_QUEUED {
        ctr(rec).store(cfg.threshold(), SeqCst);
        if cfg.sync {
            while state(rec).load(SeqCst) == JIT_QUEUED && !DISABLED.load(SeqCst) {
                futex_wait(state(rec), JIT_QUEUED);
            }
        }
        // Compiled meanwhile: don't leave the reset counter, which would delay the entry's
        // redirection by a threshold.
        st = state(rec).load(SeqCst);
        if st == JIT_DONE {
            ctr(rec).store(REDIRECT, SeqCst);
        }
    } else if st == JIT_FAILED {
        ctr(rec).store(i64::MAX, Relaxed);
    }
    st
}

/// Pushes a record that just became `Queued`, starts the JIT thread with the first push, and
/// wakes it if it sleeps.
fn push(rec: *mut JitRecord) {
    let mut head = QUEUE.load(Relaxed);
    loop {
        // SAFETY: only this thread writes `next` of a record it moved to `Queued`, until the
        // JIT thread pops it.
        unsafe { (*rec).next = head };
        match QUEUE.compare_exchange_weak(head, rec, SeqCst, Relaxed) {
            Ok(_) => break,
            Err(h) => head = h,
        }
    }
    if !STARTED.load(Relaxed) && !STARTED.swap(true, AcqRel) && !start() {
        // Fail everything queued so far, this record included, and wake its waiters
        // (`RYO_JIT_SYNC`). A push racing this one either precedes the swap, or its
        // pusher sees `DISABLED` before it would wait.
        DISABLED.store(true, SeqCst);
        let mut list = QUEUE.swap(ptr::null_mut(), SeqCst);
        while !list.is_null() {
            let r = list;
            // SAFETY: popped records are this thread's, as the JIT thread's.
            list = unsafe { (*r).next };
            fail(r);
            futex_wake(state(r), i32::MAX);
        }
        return;
    }
    WAKE.fetch_add(1, SeqCst);
    if SLEEPING.load(SeqCst) {
        futex_wake(&WAKE, 1);
    }
}

/// What the JIT gets: built by the first push, before the JIT starts.
static RT_API: Once<RtApi> = Once(UnsafeCell::new(MaybeUninit::uninit()));

unsafe extern "C" {
    /// The program's personality routine, which VM code's CIEs name through a symbol slot.
    fn rust_eh_personality();
}

/// Builds [`RT_API`] and starts the JIT thread. Called once, by the first push. False if the
/// thread couldn't start.
fn start() -> bool {
    let cfg = config();
    let flags = (cfg.sync as u32) * JIT_SYNC
        | (cfg.log as u32) * JIT_LOG
        | (cfg.perfmap as u32) * JIT_PERFMAP
        | (cfg.test_panic as u32) * JIT_TEST_PANIC
        | cfg.opt
        | (cfg.check as u32) * JIT_CHECK;
    let mut handlers = [ptr::null(); ryo_bytecode::Opcode::COUNT];
    for (h, &op) in handlers.iter_mut().zip(ryo_bytecode::ALL_OPCODES.iter()) {
        *h = super::interp::handler(op).unwrap_or(ptr::null());
    }
    let api = RtApi {
        abi: JIT_ABI_VERSION,
        format: ryo_bytecode::FORMAT_VERSION,
        size: size_of::<RtApi>() as u32,
        flags,
        probe: super::interp::probe_stack as *const (),
        personality: rust_eh_personality as *const (),
        next_batch,
        done,
        shuffled,
        handlers,
    };
    // SAFETY: only the first push gets here, once; the JIT reads it only after the start.
    unsafe { ryo_jit_start((*RT_API.0.get()).write(api)) }
}

unsafe extern "C" {
    /// The JIT's (`ryo_jit`): starts its thread, false if it can't.
    fn ryo_jit_start(rt: &'static RtApi) -> bool;
}

/// [`RtApi::next_batch`]: the queue, in trip order, once it isn't empty.
extern "C-unwind" fn next_batch() -> *mut JitRecord {
    loop {
        let mut list = QUEUE.swap(ptr::null_mut(), Acquire);
        if list.is_null() {
            // Re-check after announcing the sleep: a push after that wakes us (or changes
            // `WAKE`, so that the wait returns at once).
            SLEEPING.store(true, SeqCst);
            let w = WAKE.load(SeqCst);
            if QUEUE.load(SeqCst).is_null() {
                futex_wait(&WAKE, w);
            }
            SLEEPING.store(false, SeqCst);
            continue;
        }
        let mut order = ptr::null_mut();
        while !list.is_null() {
            // SAFETY: popped records are the JIT thread's until it reports them.
            unsafe {
                let next = (*list).next;
                (*list).next = order;
                order = list;
                list = next;
            }
        }
        return order;
    }
}

/// [`RtApi::done`]: counts a compiled record, or fails it, and wakes its waiters.
extern "C-unwind" fn done(rec: *mut JitRecord, ok: bool) {
    if ok {
        COMPILED.fetch_add(1, Relaxed);
    } else {
        fail(rec);
    }
    if config().sync {
        futex_wake(state(rec), i32::MAX);
    }
}

/// Leaves a record in AOT code for good.
fn fail(rec: *mut JitRecord) {
    FAILED.fetch_add(1, Relaxed);
    state(rec).store(JIT_FAILED, SeqCst);
    ctr(rec).store(i64::MAX, SeqCst);
}

/// Called for every newly registered image: with `RYO_JIT_THRESHOLD`, sets its counters to
/// it, and without a JIT (`RYO_JIT=off`) out of reach.
#[inline(never)]
pub(crate) fn registered(img: &Image<'_>) {
    let cfg = config();
    let v = match (cfg.enabled, cfg.threshold) {
        (false, _) => i64::MAX,
        (true, Some(t)) => t,
        (true, None) => return,
    };
    for i in 0..img.header().jit_records.count as usize {
        ctr(img.jit_records().wrapping_add(i)).store(v, Relaxed);
    }
}

#[cfg(not(windows))]
mod futex {
    use core::ffi::{c_long, c_void};
    use core::ptr;
    use core::sync::atomic::AtomicU32;

    const SYS_FUTEX: c_long = 202;
    const FUTEX_WAIT_PRIVATE: i32 = 128;
    const FUTEX_WAKE_PRIVATE: i32 = 129;

    unsafe extern "C" {
        fn syscall(n: c_long, ...) -> c_long;
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a futex wait on a live atomic, without a timeout.
        unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAIT_PRIVATE, v, ptr::null::<c_void>()) };
    }

    /// Wakes up to `n` threads waiting on `a`.
    pub fn wake(a: &AtomicU32, n: i32) {
        // SAFETY: a futex wake on a live atomic.
        unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAKE_PRIVATE, n) };
    }
}

/// PE: `WaitOnAddress`, imported as std imports it (`raw-dylib`, no import library needed).
#[cfg(windows)]
mod futex {
    use core::ffi::c_void;
    use core::sync::atomic::AtomicU32;

    #[link(name = "api-ms-win-core-synch-l1-2-0", kind = "raw-dylib")]
    unsafe extern "system" {
        fn WaitOnAddress(addr: *const c_void, compare: *const c_void, size: usize, ms: u32) -> i32;
        fn WakeByAddressSingle(addr: *const c_void);
        fn WakeByAddressAll(addr: *const c_void);
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a wait on a live atomic of 4 bytes, compared with `v`, without a timeout.
        unsafe { WaitOnAddress(a.as_ptr().cast(), (&raw const v).cast(), 4, u32::MAX) };
    }

    /// Wakes one thread waiting on `a`, or all of them.
    pub fn wake(a: &AtomicU32, n: i32) {
        // SAFETY: a wake on a live atomic.
        unsafe { if n == 1 { WakeByAddressSingle(a.as_ptr().cast()) } else { WakeByAddressAll(a.as_ptr().cast()) } }
    }
}

use futex::{wait as futex_wait, wake as futex_wake};
