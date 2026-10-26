//! The JIT thread (design/jit.md): compiles what the runtime queued, in trip order,
//! and reports each function. It sees the runtime only through the [`RtApi`] it starts with.

use ryo_bytecode::jit_abi::{JIT_LOG, RtApi};

/// The JIT thread's name.
const NAME: &str = "ryo-jit";

use crate::install::Jit;

/// Starts the JIT thread. False if the thread didn't start.
pub(crate) fn start(rt: &'static RtApi) -> bool {
    quiet_panics(rt.flags & JIT_LOG != 0);
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
            let res = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| jit.compile(rec)));
            let why = match res {
                Ok(Ok(())) => None,
                Ok(Err(why)) => Some(why),
                Err(_) => Some("panicked"),
            };
            if let Some(why) = why
                && rt.flags & JIT_LOG != 0
            {
                jit.log(rec, why);
            }
            (rt.done)(rec, why.is_none());
            if why.is_none() {
                recheck.push((rec, 0));
            }
        }
    }
}
