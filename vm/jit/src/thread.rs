//! The JIT thread (design/jit.md): compiles what the runtime queued, in trip order,
//! and reports each function. It sees the runtime only through the [`RtApi`] it starts with.

use core::sync::atomic::AtomicPtr;
use core::sync::atomic::Ordering::Relaxed;

use ryo_bytecode::jit_abi::RtApi;

/// The JIT thread's name.
const NAME: &str = "ryo-jit";

use crate::install::Jit;

/// Starts the JIT thread. False if the thread didn't start.
pub(crate) fn start(rt: &'static RtApi) -> bool {
    quiet_panics(rt.settings.log);
    oom_panics();
    crate::sys::close_frame_registry_at_exit();
    std::thread::Builder::new().name(NAME.into()).spawn(move || main(rt)).is_ok()
}

/// Keeps the JIT thread's panics, which fail a function and nothing else, off stderr but
/// with `RYO_JIT_LOG`. Other threads' panics go to the hook before: in the sealed JIT, whose
/// std is its own, there are none; linked as an rlib (tests), the program's.
fn quiet_panics(log: bool) {
    let prev = std::panic::take_hook();
    std::panic::set_hook(Box::new(move |info| {
        if std::thread::current().name() != Some(NAME) {
            prev(info);
        } else if log {
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
    if std::thread::current().name() == Some(NAME) {
        panic!("memory allocation of {} bytes failed", layout.size());
    }
    // SAFETY: stored by `oom_panics` from a `fn(Layout)` before this hook was set.
    let prev: fn(std::alloc::Layout) = unsafe { core::mem::transmute(PREV_OOM_HOOK.load(Relaxed)) };
    prev(layout);
}

fn main(rt: &'static RtApi) {
    let mut jit = Jit::new(rt);
    // Records published lately, whose counters' bias a racing AOT increment may have erased
    // (`JitRecord`): re-checked after each batch and, while there are any, after a pause
    // without one, until they are seen settled twice.
    let mut recheck: Vec<(*mut ryo_bytecode::image::JitRecord, u8)> = Vec::new();
    loop {
        let mut list = (rt.next_batch)(recheck.is_empty());
        if list.is_null() {
            std::thread::sleep(std::time::Duration::from_millis(1));
            list = (rt.next_batch)(false);
        }
        recheck.retain_mut(|(rec, seen)| {
            ryo_bytecode::image::JitRecord::settle(*rec);
            *seen = if crate::install::settled(*rec) { *seen + 1 } else { 0 };
            *seen < 2
        });
        while !list.is_null() {
            let rec = list;
            // SAFETY: the records of a batch are this thread's until it reports them.
            unsafe {
                list = (*rec).next;
                (*rec).next = core::ptr::null_mut();
            }
            // Everything that may allocate, and so panic (`oom_panics`), is inside the
            // `catch_unwind`s: a panic out of this loop would end the thread with records
            // unreported. The room for `recheck` is made before the compile, so that a
            // published record is always reported compiled.
            let res = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                recheck.reserve(1);
                jit.compile(rec)
            }));
            let why = match res {
                Ok(Ok(())) => None,
                Ok(Err(why)) => Some(why),
                Err(_) => Some("panicked"),
            };
            if let Some(why) = why
                && rt.settings.log
            {
                let _ = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| jit.log(rec, why)));
            }
            (rt.done)(rec, why.is_none());
            if why.is_none() {
                recheck.push((rec, 0));
            }
        }
    }
}
