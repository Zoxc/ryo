//! Forked children of a JIT process (design/jit.md#forked-children), for the `jit-start`
//! check: `fork` (a child, and its child, compile functions of their own), `inflight` (a fork
//! while a compile is pending: the child compiles the record again), `quiesce` (forks while
//! the JIT installs code or unwinds its panics: every child can still unwind), `spawn`
//! (`Command`s start no JIT). Unix only; elsewhere it prints what it would.

use std::hint::black_box;
use std::sync::atomic::{AtomicBool, Ordering};

/// Called by the parent only.
#[inline(never)]
fn hot(n: u64) -> u64 {
    (0..n).fold(1u64, |a, i| a.wrapping_mul(31).wrapping_add(i))
}

/// First called in the child.
#[inline(never)]
fn fresh(x: u64) -> u64 {
    x.wrapping_mul(3).wrapping_add(1)
}

/// First called in the grandchild.
#[inline(never)]
fn fresher(x: u64) -> u64 {
    x.wrapping_mul(5).wrapping_add(2)
}

/// A loop long enough to reach the `inflight` case's loop threshold.
#[inline(never)]
fn long_loop(n: u64) -> u64 {
    let mut a = 0u64;
    for i in 0..n {
        a = black_box(a.wrapping_mul(7).wrapping_add(i));
    }
    a
}

/// One of many functions to compile.
#[inline(never)]
fn work<const N: u64>(x: u64) -> u64 {
    x.wrapping_mul(N | 1).rotate_left((N % 64) as u32) ^ N
}

macro_rules! works {
    ($($n:literal)*) => { [$(work::<$n> as fn(u64) -> u64),*] };
}

static WORKS: [fn(u64) -> u64; 256] = works!(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255);

#[cfg(unix)]
mod sys {
    unsafe extern "C" {
        pub fn fork() -> i32;
        pub fn waitpid(pid: i32, status: *mut i32, options: i32) -> i32;
    }
}

/// Forks; the child runs `child` and exits with its result (through `exit`, so that its
/// `atexit` handlers, the JIT's summary among them, run). The parent gets the child's pid.
#[cfg(unix)]
fn spawn_child(child: impl FnOnce() -> bool) -> i32 {
    // SAFETY: `fork`; the child only runs `child` and exits.
    let pid = unsafe { sys::fork() };
    assert!(pid >= 0, "fork failed");
    if pid == 0 {
        std::process::exit(if child() { 0 } else { 1 });
    }
    pid
}

/// Whether the child `pid` exited with 0.
#[cfg(unix)]
fn reap(pid: i32) -> bool {
    let mut status = 0;
    // SAFETY: waits for our own child.
    let r = unsafe { sys::waitpid(pid, &mut status, 0) };
    r == pid && status == 0
}

/// A thread that calls the [`WORKS`] functions in a loop until `stop`: each first call queues
/// one (with `RYO_JIT_THRESHOLD=0`).
fn worker(stop: &'static AtomicBool) -> std::thread::JoinHandle<u64> {
    std::thread::spawn(move || {
        let mut a = 0u64;
        while !stop.load(Ordering::Relaxed) {
            for f in &WORKS {
                a = f(black_box(a));
            }
        }
        a
    })
}

#[cfg(unix)]
fn case_fork() -> bool {
    static STOP: AtomicBool = AtomicBool::new(false);
    let mut ok = hot(black_box(100)) != 0;
    let w = worker(&STOP);
    let child = spawn_child(|| {
        if fresh(black_box(5)) != 16 || hot(black_box(10)) == 0 {
            return false;
        }
        // The child's own child restarts a JIT again.
        let grandchild = spawn_child(|| fresher(black_box(5)) == 27);
        reap(grandchild)
    });
    ok &= reap(child);
    STOP.store(true, Ordering::Relaxed);
    black_box(w.join().unwrap());
    ok
}

#[cfg(unix)]
fn case_inflight() -> bool {
    // A thread trips `long_loop`'s loop and waits (`RYO_JIT_SYNC`) while the JIT delays its
    // compile (`RYO_JIT_TEST_SLOW`); the fork lands meanwhile.
    let t = std::thread::spawn(|| long_loop(black_box(3_000_000)));
    std::thread::sleep(std::time::Duration::from_millis(150));
    let child = spawn_child(|| long_loop(black_box(3_000_000)) == long_loop_ref(3_000_000));
    let ok = reap(child);
    ok & (t.join().unwrap() == long_loop_ref(3_000_000))
}

/// [`long_loop`]'s value, computed apart.
fn long_loop_ref(n: u64) -> u64 {
    let mut a = 0u64;
    let mut i = 0;
    while i < n {
        a = a.wrapping_mul(7).wrapping_add(i);
        i += 1;
    }
    a
}

#[cfg(unix)]
fn case_quiesce() -> bool {
    static STOP: AtomicBool = AtomicBool::new(false);
    let w = worker(&STOP);
    let mut ok = true;
    for _ in 0..20 {
        let child = spawn_child(|| {
            std::panic::set_hook(Box::new(|_| {}));
            std::panic::catch_unwind(|| panic!("in the child")).is_err() && fresh(black_box(1)) == 4
        });
        ok &= reap(child);
    }
    STOP.store(true, Ordering::Relaxed);
    black_box(w.join().unwrap());
    ok
}

#[cfg(unix)]
fn case_spawn() -> bool {
    (0..20).all(|_| std::process::Command::new("true").status().is_ok_and(|s| s.success()))
}

fn main() {
    let case = std::env::args().nth(1).unwrap_or_default();
    #[cfg(unix)]
    let ok = match case.as_str() {
        "fork" => case_fork(),
        "inflight" => case_inflight(),
        "quiesce" => case_quiesce(),
        "spawn" => case_spawn(),
        _ => panic!("unknown case {case:?}"),
    };
    #[cfg(not(unix))]
    let ok = true;
    println!("{case} {}", if ok { "ok" } else { "FAILED" });
}
