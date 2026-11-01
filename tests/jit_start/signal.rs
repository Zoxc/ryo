//! Trips in a signal handler, for the `jit-start` check: the first VM functions to reach the
//! JIT through `on_alarm` run in a `SIGALRM` handler while the main thread allocates and
//! frees, so the trip may interrupt it inside `malloc`. With `altstack` (Linux), the handler
//! runs on the signal stack, where a `RYO_JIT_SYNC` trip doesn't wait. It must not hang.
//! Unix only; elsewhere it prints what it would.

use std::hint::black_box;
use std::sync::atomic::{AtomicU64, Ordering};

static HITS: AtomicU64 = AtomicU64::new(0);
static SUM: AtomicU64 = AtomicU64::new(0);

/// Called only by the handler.
#[inline(never)]
fn tick(x: u64) -> u64 {
    x.wrapping_mul(2654435761).rotate_left(7)
}

extern "C" fn on_alarm(_sig: i32) {
    SUM.fetch_add(tick(HITS.fetch_add(1, Ordering::Relaxed)), Ordering::Relaxed);
}

#[cfg(unix)]
mod sys {
    unsafe extern "C" {
        pub fn signal(sig: i32, handler: extern "C" fn(i32)) -> usize;
        pub fn ualarm(usecs: u32, interval: u32) -> u32;
    }

    /// Installs `handler` for `sig` with `SA_ONSTACK` (glibc's `struct sigaction`).
    #[cfg(target_os = "linux")]
    pub fn on_signal_stack(sig: i32, handler: extern "C" fn(i32)) {
        #[repr(C)]
        struct SigAction {
            handler: usize,
            mask: [u64; 16],
            flags: i32,
            restorer: usize,
        }
        unsafe extern "C" {
            fn sigaction(sig: i32, act: *const SigAction, old: *mut SigAction) -> i32;
        }
        const SA_ONSTACK: i32 = 0x0800_0000;
        const SA_RESTART: i32 = 0x1000_0000;
        let act = SigAction { handler: handler as usize, mask: [0; 16], flags: SA_ONSTACK | SA_RESTART, restorer: 0 };
        // SAFETY: a valid `struct sigaction`; std installed the main thread's signal stack.
        assert_eq!(unsafe { sigaction(sig, &act, std::ptr::null_mut()) }, 0);
    }
}

fn main() {
    let altstack = std::env::args().nth(1).as_deref() == Some("altstack");
    #[cfg(unix)]
    {
        const SIGALRM: i32 = 14;
        #[cfg(target_os = "linux")]
        if altstack {
            sys::on_signal_stack(SIGALRM, on_alarm);
        }
        if !cfg!(target_os = "linux") || !altstack {
            // SAFETY: installs a handler that only touches atomics.
            unsafe { sys::signal(SIGALRM, on_alarm) };
        }
        // SAFETY: plain libc calls.
        unsafe { sys::ualarm(1000, 1000) };
        let mut i = 0usize;
        while HITS.load(Ordering::Relaxed) < 50 {
            let v: Vec<u8> = Vec::with_capacity(black_box(16 + i % 4000));
            black_box(&v);
            i += 1;
        }
        // SAFETY: as above.
        unsafe { sys::ualarm(0, 0) };
    }
    black_box(SUM.load(Ordering::Relaxed));
    println!("signals ok{}", if altstack { " (altstack)" } else { "" });
}
