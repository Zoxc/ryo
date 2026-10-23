//! The JIT thread (design/vm.md, "JIT"): compiles what the runtime queued, in trip order,
//! and reports each function. It sees the runtime only through the [`RtApi`] it starts with.

use ryo_bytecode::jit_abi::{JIT_LOG, RtApi};

use crate::install::Jit;

/// Starts the JIT thread. False if `rt` isn't of this JIT's version, or the thread didn't
/// start.
pub(crate) fn start(rt: &'static RtApi) -> bool {
    if !rt.compatible() {
        return false;
    }
    std::thread::Builder::new().name("ryo-jit".into()).spawn(move || main(rt)).is_ok()
}

fn main(rt: &'static RtApi) {
    // Before anything else: it marks this thread as the JIT's for the runtime's trips.
    let mut list = (rt.next_batch)();
    let mut jit = Jit::new(rt);
    loop {
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
        list = (rt.next_batch)();
    }
}
