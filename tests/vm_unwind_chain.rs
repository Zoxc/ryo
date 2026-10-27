//! Panics unwinding through chains of VM and native frames into `catch_unwind`: guards in
//! every frame, several landing pads per VM frame (nested scopes, early drops, `?` returns, a
//! moved-out value), `resume_unwind` of a caught payload, the panic count and
//! `thread::panicking()` in drops, a panic in a loop (an OSR-entered frame with the JIT), a
//! spawned thread's panic, and last one that only `lang_start` catches (exit status 101). The
//! drops run in the native order.
use std::hint::black_box;
use std::panic::{self, AssertUnwindSafe, catch_unwind, resume_unwind};

struct G(&'static str, u32);

impl Drop for G {
    fn drop(&mut self) {
        println!("drop {} {} panicking={}", self.0, self.1, std::thread::panicking());
    }
}

/// Native: inline assembly keeps a function out of the VM.
macro_rules! native {
    () => {
        unsafe { std::arch::asm!("") }
    };
}

#[inline(never)]
fn consume(g: G) -> u32 {
    g.1 + 1
}

#[inline(never)]
fn vm3(n: u32) -> u32 {
    let _g = G("vm3", n);
    if black_box(n) % 2 == 1 {
        panic!("odd {n}");
    }
    n * 10
}

#[inline(never)]
fn native2(n: u32) -> u32 {
    native!();
    let _g = G("native2", n);
    vm3(n) + 1
}

#[inline(never)]
fn check(n: u32) -> Result<u32, String> {
    if black_box(n) == 4 { Err(format!("four {n}")) } else { Ok(n) }
}

#[inline(never)]
fn vm2(n: u32) -> Result<u32, String> {
    let a = G("vm2 a", n);
    let m = check(n)?;
    let r = {
        let _b = G("vm2 b", n);
        native2(m)
    };
    drop(a);
    let _c = G("vm2 c", n);
    Ok(r + native2(m + 2))
}

#[inline(never)]
fn native1(n: u32) -> u32 {
    native!();
    let _g = G("native1", n);
    match vm2(n) {
        Ok(r) => r,
        Err(e) => {
            println!("early: {e}");
            0
        }
    }
}

#[inline(never)]
fn vm1(n: u32) -> u32 {
    let a = G("vm1 a", n);
    let moved = G("vm1 moved", n);
    let k = consume(moved);
    let r = native1(n);
    let _b = G("vm1 b", n);
    drop(a);
    r + k + native1(n + 1)
}

#[inline(never)]
fn step(i: u32, stop: u32) -> u32 {
    if black_box(i) == stop {
        panic!("stop at {i}");
    }
    i * 3
}

/// Panics on the iteration `stop`: with the JIT's OSR variant, from the frame entered at the
/// loop head.
#[inline(never)]
fn vm_loop(n: u32, stop: u32) -> u32 {
    let _g = G("loop", n);
    let mut acc = 0;
    for i in 0..n {
        let _it = G("iter", i);
        acc += step(i, stop);
    }
    acc
}

#[inline(never)]
fn native_resume(p: Box<dyn std::any::Any + Send>) -> u32 {
    native!();
    let _g = G("native resume", 0);
    resume_unwind(p)
}

#[inline(never)]
fn vm_resume(p: Box<dyn std::any::Any + Send>) -> u32 {
    let _g = G("vm resume", 0);
    native_resume(p) + 1
}

fn msg(e: &(dyn std::any::Any + Send)) -> String {
    e.downcast_ref::<String>().cloned().or_else(|| e.downcast_ref::<&str>().map(|s| s.to_string())).unwrap_or_default()
}

fn main() {
    panic::set_hook(Box::new(|info| println!("hook: {}", info.payload_as_str().unwrap_or(""))));
    for n in [0, 4, 1, 2] {
        match catch_unwind(|| vm1(black_box(n))) {
            Ok(r) => println!("vm1({n}) = {r}"),
            Err(e) => println!("vm1({n}) panicked: {}", msg(&*e)),
        }
        println!("panicking after: {}", std::thread::panicking());
    }
    match catch_unwind(|| vm_loop(black_box(10), black_box(7))) {
        Ok(r) => println!("loop = {r}"),
        Err(e) => println!("loop panicked: {}", msg(&*e)),
    }
    println!("loop again = {}", vm_loop(black_box(5), black_box(99)));

    // A caught payload, unwound again through VM frames and caught outside.
    let p = catch_unwind(|| vm3(black_box(5))).unwrap_err();
    let again = catch_unwind(AssertUnwindSafe(|| vm_resume(p)));
    println!("resumed: {}", again.map_err(|e| msg(&*e)).unwrap_err());

    let t = std::thread::spawn(|| vm1(black_box(3)));
    match t.join() {
        Ok(r) => println!("thread = {r}"),
        Err(e) => println!("thread panicked: {}", msg(&*e)),
    }
    println!("end: {}", vm1(black_box(0)));
}
