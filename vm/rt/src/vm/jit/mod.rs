//! The JIT (design/vm.md, "JIT"): recompiles hot functions on a background thread and
//! switches their entry over to the new code.
//!
//! - **Trips**: [`trip_entry`] and [`trip_osr`] are what a JIT record's `entry` and `osr`
//!   slots start at; a function's counter stub calls them when its counter runs out
//!   (design/vm.md, "JIT records and counters"). They queue the record if it is cold, reset
//!   the counter, and return into the AOT code; at the entry of a compiled function they
//!   continue into its JIT code instead. Lock-free: a CAS on the record's state, a push onto
//!   [`QUEUE`], and a futex wake if the JIT thread sleeps. They never compile or allocate,
//!   but the first push starts the JIT thread.
//! - **The JIT thread** (`install`) takes the whole queue at once, decodes each function from
//!   its image ([`ryo_bytecode::image::ImageResolver`]), encodes it again without counters,
//!   installs the code near the image with its unwind information, and publishes it in the
//!   record: `entry` (its [`JIT_ENTRY_PREFIX`]), then the state `Done`, then the counter
//!   [`REDIRECT`], so that every later call's counter check takes the stub into the JIT code.
//!
//! This is the only module of `ryo_rt` that uses std: the native one (the `jit` feature is
//! only on for the native sysroot), so it never enters VM code (design/vm.md, "No re-entry").
//! Nothing on the trips' path may unwind (the stubs aren't call sites); the Rust parts are
//! `extern "C"`, which aborts if they did, and the JIT thread catches its panics per function.

mod install;

use core::cell::Cell;
use core::ffi::{c_long, c_void};
use core::ptr;
use core::sync::atomic::Ordering::{AcqRel, Acquire, Relaxed, Release, SeqCst};
use core::sync::atomic::{AtomicBool, AtomicI64, AtomicPtr, AtomicU32, AtomicUsize};
use std::sync::OnceLock;

use ryo_bytecode::image::{Image, JIT_COLD, JIT_DONE, JIT_FAILED, JIT_QUEUED, JIT_THRESHOLD, JitRecord};

/// The counter of a compiled function ([`JitRecord::ctr`]): far enough below 0 that the
/// counter checks' `sub`s keep it negative (every check takes its stub) for 2^58 calls. Not
/// `i64::MIN`, from which the next `sub` would wrap to a large positive count.
pub const REDIRECT: i64 = i64::MIN / 2;

/// The bytes before a JIT function's first instruction that its record's `entry` points at:
/// `pop r11`, which drops the return address of the counter stub's `call [r11 + 8]`, so that
/// the function starts with its caller's return address on top, as if called directly.
pub const JIT_ENTRY_PREFIX: usize = 2;

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
}

static CONFIG: OnceLock<Config> = OnceLock::new();

fn config() -> &'static Config {
    CONFIG.get_or_init(|| {
        let var = |name: &str| std::env::var_os(name);
        let flag = |name: &str| var(name).is_some_and(|v| v == "1");
        Config {
            enabled: var("RYO_JIT").is_none_or(|v| v != "off"),
            threshold: var("RYO_JIT_THRESHOLD").and_then(|v| v.to_str()?.parse::<i64>().ok()).map(|t| t.max(0)),
            sync: flag("RYO_JIT_SYNC"),
            perfmap: flag("RYO_JIT_PERFMAP"),
            log: flag("RYO_JIT_LOG"),
        }
    })
}

impl Config {
    fn threshold(&self) -> i64 {
        self.threshold.unwrap_or(JIT_THRESHOLD)
    }
}

/// Sets the JIT's settings instead of the environment, before anything reads them (tests):
/// on, with `sync` ([`Config::sync`]) and `threshold` (as `RYO_JIT_THRESHOLD`). False if they
/// were read already.
#[doc(hidden)]
pub fn configure_jit(sync: bool, threshold: Option<i64>) -> bool {
    CONFIG.set(Config { enabled: true, threshold, sync, perfmap: false, log: false }).is_ok()
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

std::thread_local! {
    /// The thread is in a trip, or is the JIT thread: a nested trip (VM code that the trip's
    /// own calls run, such as a VM global allocator under the thread spawn) never waits.
    static NO_WAIT: Cell<bool> = const { Cell::new(false) };
}

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
fn state(r: *mut JitRecord) -> &'static AtomicU32 {
    // SAFETY: as for `ctr`.
    unsafe { &(*r).state }
}

/// The trip of a function's entry: `r11` is its JIT record, `rsp` 16-aligned (the caller's
/// and the stub's return addresses are on it), the argument registers live. Saves them,
/// calls [`entry_trip`], restores them, and returns into the AOT code, or jumps to the JIT
/// entry [`entry_trip`] gives, which drops the stub's return address
/// ([`JIT_ENTRY_PREFIX`]). Clobbers `rax` and `r11`, which carry nothing at an entry.
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

/// The trip of a loop head: `r11` is the JIT record, `eax` the head's index, `rsp + 8`
/// 16-aligned, nothing live but `rsp` and `rbp`. A compiled function's head returns at once:
/// the counter must stay negative for the entry's redirection (there is no OSR yet, so
/// each iteration of a loop that started in AOT code comes here). Else [`osr_trip`].
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = "ryo_jit_trip_osr")]
pub unsafe extern "sysv64" fn trip_osr() {
    core::arch::naked_asm!(
        ".cfi_startproc",
        "cmp dword ptr [r11 + {state}], {done}",
        "je 2f",
        "sub rsp, 8",
        ".cfi_adjust_cfa_offset 8",
        "mov rdi, r11",
        "call {trip}",
        "add rsp, 8",
        ".cfi_adjust_cfa_offset -8",
        "2:",
        "ret",
        ".cfi_endproc",
        state = const core::mem::offset_of!(JitRecord, state),
        done = const JIT_DONE,
        trip = sym osr_trip,
    );
}

/// [`trip_entry`]'s work: the JIT entry to continue at, or null to continue in AOT code.
extern "C" fn entry_trip(rec: *mut JitRecord) -> *const u8 {
    if trip(rec) == JIT_DONE {
        ctr(rec).store(REDIRECT, Relaxed);
        return entry(rec).load(Acquire);
    }
    ptr::null()
}

/// [`trip_osr`]'s work.
extern "C" fn osr_trip(rec: *mut JitRecord) {
    trip(rec);
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
    // Outside of any trip on this thread (an accessor failing in TLS teardown counts as
    // inside).
    let outer = NO_WAIT.try_with(|w| !w.replace(true)).unwrap_or(false);
    let mut st = state(rec).load(Acquire);
    if st == JIT_COLD && state(rec).compare_exchange(JIT_COLD, JIT_QUEUED, AcqRel, Acquire).is_ok() {
        push(rec);
    }
    st = state(rec).load(SeqCst);
    if st == JIT_QUEUED {
        ctr(rec).store(cfg.threshold(), SeqCst);
        if cfg.sync && outer {
            while state(rec).load(Acquire) == JIT_QUEUED && !DISABLED.load(Acquire) {
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
    if outer {
        let _ = NO_WAIT.try_with(|w| w.set(false));
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
    if !STARTED.load(Relaxed) && !STARTED.swap(true, AcqRel) {
        let spawned = std::thread::Builder::new().name("ryo-jit".into()).spawn(thread_main);
        if spawned.is_err() {
            DISABLED.store(true, Release);
            fail(rec);
            return;
        }
    }
    WAKE.fetch_add(1, SeqCst);
    if SLEEPING.load(SeqCst) {
        futex_wake(&WAKE, 1);
    }
}

/// The JIT thread: compiles what is queued, in trip order, and sleeps while nothing is.
fn thread_main() {
    let _ = NO_WAIT.try_with(|w| w.set(true));
    let cfg = config();
    let mut jit = install::Jit::new(cfg.perfmap);
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
            // SAFETY: popped records are this thread's until it publishes them.
            unsafe {
                let next = (*list).next;
                (*list).next = order;
                order = list;
                list = next;
            }
        }
        while !order.is_null() {
            let rec = order;
            // SAFETY: as above.
            unsafe {
                order = (*rec).next;
                (*rec).next = ptr::null_mut();
            }
            let res = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| jit.compile(rec)));
            let why = match res {
                Ok(Ok(())) => None,
                Ok(Err(why)) => Some(why),
                Err(_) => Some("panicked"),
            };
            match why {
                None => {
                    COMPILED.fetch_add(1, Relaxed);
                }
                Some(why) => {
                    if cfg.log {
                        jit.log(rec, why);
                    }
                    fail(rec);
                }
            }
            if cfg.sync {
                futex_wake(state(rec), i32::MAX);
            }
        }
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

const SYS_FUTEX: c_long = 202;
const FUTEX_WAIT_PRIVATE: i32 = 128;
const FUTEX_WAKE_PRIVATE: i32 = 129;

unsafe extern "C" {
    fn syscall(n: c_long, ...) -> c_long;
}

/// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
fn futex_wait(a: &AtomicU32, v: u32) {
    // SAFETY: a futex wait on a live atomic, without a timeout.
    unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAIT_PRIVATE, v, ptr::null::<c_void>()) };
}

/// Wakes up to `n` threads waiting on `a`.
fn futex_wake(a: &AtomicU32, n: i32) {
    // SAFETY: a futex wake on a live atomic.
    unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAKE_PRIVATE, n) };
}
