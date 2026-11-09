//! The JIT thread (design/jit.md): compiles what the runtime queued, in trip order,
//! and reports each function. It sees the runtime only through the [`RtApi`] it starts with.

use core::cell::Cell;
use core::sync::atomic::AtomicPtr;
use core::sync::atomic::Ordering::{Acquire, Relaxed, Release};

use ryo_bytecode::image::JitRecord;
use ryo_bytecode::jit_abi::RtApi;

/// The JIT thread's name.
const NAME: &str = "ryo-jit";

use crate::install::Jit;
use crate::stats::{self, Fail, STATS};

std::thread_local! {
    /// Whether this is the JIT thread, for the hooks: `std::thread::current()` can panic
    /// (after the thread's TLS is gone) or allocate (no handle yet) there. A `const` `Cell`
    /// has no destructor, so it is readable at any time.
    static IS_JIT: core::cell::Cell<bool> = const { core::cell::Cell::new(false) };
}

/// Whether the current thread is the JIT thread.
fn is_jit() -> bool {
    IS_JIT.try_with(|c| c.get()).unwrap_or(false)
}

/// Starts the JIT thread. False if the thread didn't start. `child`: again, in a forked
/// child, which inherited the hooks, the `atexit` handlers and the start time, and gets its
/// own counters.
pub(crate) fn start(rt: &'static RtApi, child: bool) -> bool {
    RT.store(rt as *const RtApi as *mut RtApi, Release);
    if child {
        stats::STATS.reset();
    } else {
        quiet_panics(rt.settings.log);
        oom_panics();
        crate::sys::close_frame_registry_at_exit();
        let _ = stats::STARTED_AT.set(std::time::Instant::now());
    }
    // The thread starts with the asynchronous signals blocked: it inherits the mask from here.
    let spawn = || std::thread::Builder::new().name(NAME.into()).spawn(move || main(rt)).is_ok();
    #[cfg(unix)]
    let spawned = with_signals_blocked(spawn);
    #[cfg(not(unix))]
    let spawned = spawn();
    spawned
}

/// The runtime's interface, for [`quiesce`].
static RT: AtomicPtr<RtApi> = AtomicPtr::new(core::ptr::null_mut());

std::thread_local! {
    /// How many [`quiesce`] sections (and panics, [`quiet_panics`]) this thread is in: the
    /// outermost takes the runtime's quiesce lock.
    static QUIESCED: Cell<u32> = const { Cell::new(0) };
}

/// Holds the runtime's quiesce lock ([`RtApi::fork_enter`]) until dropped: a fork waits until
/// then, so that a forked child never inherits the section half done. Re-entrant per thread.
pub(crate) struct Quiesce(());

/// Enters a quiesced section, for what takes locks a forked child couldn't recover (the
/// unwinder's frame registry, the sealed std's mutexes) or publishes code.
pub(crate) fn quiesce() -> Quiesce {
    enter();
    Quiesce(())
}

impl Drop for Quiesce {
    fn drop(&mut self) {
        leave();
    }
}

/// The runtime, once the JIT started (not in unit tests that call into the JIT directly).
fn rt() -> Option<&'static RtApi> {
    // SAFETY: the runtime's `&'static RtApi`, or null.
    unsafe { RT.load(Acquire).as_ref() }
}

fn enter() {
    // Without TLS (the thread is exiting) nothing is taken, nor released.
    if QUIESCED.try_with(|c| c.replace(c.get() + 1)) == Ok(0)
        && let Some(rt) = rt()
    {
        (rt.fork_enter)();
    }
}

fn leave() {
    if QUIESCED.try_with(|c| {
        c.set(c.get().saturating_sub(1));
        c.get()
    }) == Ok(0)
        && let Some(rt) = rt()
    {
        (rt.fork_leave)();
    }
}

/// The current [`QUIESCED`] depth.
fn depth() -> u32 {
    QUIESCED.try_with(Cell::get).unwrap_or(0)
}

/// Leaves the sections entered since the depth was `d`: after a caught panic, whose hook
/// entered one ([`quiet_panics`]).
fn leave_to(d: u32) {
    while depth() > d {
        leave();
    }
}

/// `catch_unwind`, leaving the quiesced section a panic in `f` entered.
fn catch<R>(f: impl FnOnce() -> R) -> std::thread::Result<R> {
    let d = depth();
    let r = std::panic::catch_unwind(std::panic::AssertUnwindSafe(f));
    if r.is_err() {
        leave_to(d);
    }
    r
}

/// Keeps the JIT thread's panics, which fail a function and nothing else, off stderr but
/// with `RYO_JIT_LOG`. Other threads' panics go to the hook before: in the sealed JIT, whose
/// std is its own, there are none; linked as an rlib (tests), the program's. On the JIT
/// thread the unwind that follows is quiesced ([`quiesce`]), until [`catch`] ends it: it
/// takes the unwinder's locks.
fn quiet_panics(log: bool) {
    let prev = std::panic::take_hook();
    std::panic::set_hook(Box::new(move |info| {
        if !is_jit() {
            prev(info);
            return;
        }
        enter();
        if log {
            crate::install::log_line(&format!("ryo-jit: {info}\n"));
        }
    }));
}

/// The allocation error hook before [`oom_panics`]'s (a `fn(Layout)`).
static PREV_OOM_HOOK: AtomicPtr<()> = AtomicPtr::new(core::ptr::null_mut());

/// Makes an allocation failure on the JIT thread a panic, which fails the function being
/// compiled (`main`'s `catch_unwind`), rather than std's default abort of the whole program.
/// On other threads the hook before decides: in the sealed JIT, whose std is its own, std's
/// default (abort); linked as an rlib (tests), the program's.
fn oom_panics() {
    PREV_OOM_HOOK.store(std::alloc::take_alloc_error_hook() as *mut (), Relaxed);
    std::alloc::set_alloc_error_hook(oom_hook);
}

fn oom_hook(layout: std::alloc::Layout) {
    if is_jit() {
        panic!("memory allocation of {} bytes failed", layout.size());
    }
    // SAFETY: stored by `oom_panics` from a `fn(Layout)` before this hook was set.
    let prev: fn(std::alloc::Layout) = unsafe { core::mem::transmute(PREV_OOM_HOOK.load(Relaxed)) };
    prev(layout);
}

/// Published records awaiting their re-check, each with how many times it was seen settled (`main`).
type Recheck = Vec<(*mut JitRecord, u8)>;

/// Releases the quiesce lock if the JIT thread ends holding it (a panic outside [`catch`]),
/// so that forks don't wait for it forever.
struct LeaveAll;

impl Drop for LeaveAll {
    fn drop(&mut self) {
        leave_to(0);
    }
}

/// Runs `f` (the JIT thread's spawn) with the asynchronous signals blocked on this thread, then
/// restores its mask: the JIT thread inherits the mask, so they are blocked there from its
/// first instruction. A process-directed signal (`SIGALRM`, `SIGCHLD`, ...) whose handler is
/// VM code would otherwise trip on the JIT thread and, with `RYO_JIT_SYNC`, wait for its own
/// compile. The synchronous ones (faults) stay.
#[cfg(unix)]
fn with_signals_blocked<R>(f: impl FnOnce() -> R) -> R {
    use core::ffi::c_int;
    unsafe extern "C" {
        fn sigfillset(set: *mut u64) -> c_int;
        fn sigdelset(set: *mut u64, sig: c_int) -> c_int;
        fn pthread_sigmask(how: c_int, set: *const u64, old: *mut u64) -> c_int;
    }
    // Large enough for every `sigset_t` (glibc's is 128 bytes, Apple's 4).
    let mut set = [0u64; 16];
    let mut old = [0u64; 16];
    #[cfg(target_vendor = "apple")]
    const SIGS: [c_int; 5] = [4, 5, 8, 10, 11]; // SIGILL, SIGTRAP, SIGFPE, SIGBUS, SIGSEGV
    #[cfg(not(target_vendor = "apple"))]
    const SIGS: [c_int; 5] = [4, 5, 8, 7, 11];
    #[cfg(target_vendor = "apple")]
    const SIG_BLOCK: c_int = 1;
    #[cfg(not(target_vendor = "apple"))]
    const SIG_BLOCK: c_int = 0;
    #[cfg(target_vendor = "apple")]
    const SIG_SETMASK: c_int = 3;
    #[cfg(not(target_vendor = "apple"))]
    const SIG_SETMASK: c_int = 2;
    // SAFETY: plain libc calls on buffers at least as large as a `sigset_t`.
    let blocked = unsafe {
        sigfillset(set.as_mut_ptr());
        for s in SIGS {
            sigdelset(set.as_mut_ptr(), s);
        }
        pthread_sigmask(SIG_BLOCK, set.as_ptr(), old.as_mut_ptr()) == 0
    };
    let r = f();
    if blocked {
        // SAFETY: as above; `old` is the mask `pthread_sigmask` returned.
        unsafe { pthread_sigmask(SIG_SETMASK, old.as_ptr(), core::ptr::null_mut()) };
    }
    r
}

fn main(rt: &'static RtApi) {
    IS_JIT.set(true);
    let _leave = LeaveAll;
    // `RYO_JIT_TEST_SLOW=<ms>` (tests): every compile starts that late, so that a test can
    // fork while one is pending.
    let slow = std::env::var("RYO_JIT_TEST_SLOW").ok().and_then(|v| v.parse().ok()).map(std::time::Duration::from_millis);
    // Before the first `next_batch`, which tells the runtime the thread is set up.
    crate::install::init_tls();
    let mut jit = Jit::new(rt);
    // Records published lately, whose counters' bias a racing AOT increment may have erased
    // (`JitRecord`): re-checked after each batch and, while there are any, after a pause
    // without one, until they are seen settled twice.
    let mut recheck: Recheck = Vec::new();
    // `RYO_JIT_STATS=2`: when the last progress line went out.
    let mut last_progress = std::time::Instant::now();
    loop {
        let mut list = (rt.next_batch)(recheck.is_empty());
        if list.is_null() {
            std::thread::sleep(std::time::Duration::from_millis(1));
            list = (rt.next_batch)(false);
        }
        recheck_pass(&mut recheck);
        if !list.is_null() {
            // Counted as taken before any is compiled: before the first leaves `Queued`.
            let mut n = 0;
            let mut rec = list;
            while !rec.is_null() {
                n += 1;
                // SAFETY: as below.
                rec = unsafe { (*rec).next };
            }
            stats::add(&STATS.batches, 1);
            stats::add(&STATS.queued, n);
            stats::max(&STATS.largest_batch, n);
        }
        while !list.is_null() {
            let rec = list;
            // SAFETY: the records of a batch are this thread's until it reports them. Their
            // links stay: the runtime walks the rest of the batch from a reported record
            // (`IN_FLIGHT`).
            list = unsafe { (*rec).next };
            if let Some(d) = slow {
                std::thread::sleep(d);
            }
            compile_one(&mut jit, rt, rec, &mut recheck);
        }
        if rt.settings.stats >= 2 && last_progress.elapsed() >= std::time::Duration::from_secs(60) {
            last_progress = std::time::Instant::now();
            stats::write_progress();
        }
    }
}

/// Re-checks the records of `recheck`: settles each that isn't, and drops those seen settled
/// in two passes in a row. A pass that settles a record doesn't count: an AOT increment can
/// still erase what its compare-exchange wrote, after this thread reads it back.
fn recheck_pass(recheck: &mut Recheck) {
    recheck.retain_mut(|(rec, seen)| {
        if crate::install::settled(*rec) {
            *seen += 1;
        } else {
            JitRecord::settle(*rec);
            *seen = 0;
        }
        *seen < 2
    });
}

/// Compiles `rec`, counts and logs the outcome, and reports it to the runtime; a published
/// record goes on `recheck`.
fn compile_one(jit: &mut Jit, rt: &RtApi, rec: *mut JitRecord, recheck: &mut Recheck) {
    let t0 = rt.settings.count.then(std::time::Instant::now);
    // Everything that may allocate, and so panic (`oom_panics`), is inside the
    // `catch_unwind`s: a panic out of here would end the thread with records unreported.
    // The room for `recheck` is made before the compile, so that a published record is
    // always reported compiled.
    let res = catch(|| {
        recheck.reserve(1);
        jit.compile(rec)
    });
    let why = match res {
        Ok(Ok(())) => None,
        Ok(Err(why)) => Some(why),
        Err(_) => Some(Fail::Panicked),
    };
    if let Some(t0) = t0 {
        let ns = t0.elapsed().as_nanos() as u64;
        stats::add(&STATS.timed, 1);
        stats::add(&STATS.compile_ns, ns);
        stats::max(&STATS.compile_max_ns, ns);
    }
    if let Some(why) = why {
        // Before `done` fails the record: its `SeqCst` store of `Failed` makes the count
        // visible to a `RYO_JIT_SYNC` waiter (stats.rs).
        STATS.fail(why);
        if rt.settings.log {
            let _ = catch(|| jit.log(rec, &why.message()));
        }
    }
    (rt.done)(rec, why.is_none());
    if why.is_none() {
        recheck.push((rec, 0));
    }
}
