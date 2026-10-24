//! The JIT thread (design/jit.md): compiles what the runtime queued, in trip order,
//! and reports each function. It sees the runtime only through the [`RtApi`] it starts with.

use ryo_bytecode::jit_abi::{JIT_LOG, RtApi};

/// The JIT thread's name.
const NAME: &str = "ryo-jit";

use crate::install::Jit;

/// Starts the JIT thread. False if `rt` isn't of this JIT's version, or the thread didn't
/// start.
pub(crate) fn start(rt: &'static RtApi) -> bool {
    if !rt.compatible() {
        return false;
    }
    quiet_panics(rt.flags & JIT_LOG != 0);
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
    loop {
        let mut list = (rt.next_batch)();
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
        }
    }
}
