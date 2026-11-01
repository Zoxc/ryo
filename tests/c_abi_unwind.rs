//! `extern "C-unwind"`: panics unwinding through VM-compiled `C-unwind` functions and out of
//! native `C-unwind` callees through VM frames (with cleanups on the way), caught by
//! `catch_unwind` in VM and native callers, directly and through fn pointers.
use std::arch::asm;
use std::cell::Cell;
use std::hint::black_box;
use std::panic::{self, AssertUnwindSafe};

/// Keeps the function it is in native: the VM doesn't run inline asm.
macro_rules! native {
    () => {
        unsafe { asm!("", options(nomem, nostack, preserves_flags)) }
    };
}

thread_local! { static DROPS: Cell<u32> = const { Cell::new(0) }; }

/// Counts its drops: a cleanup in the frame it lives in.
struct Guard(u32);

impl Drop for Guard {
    fn drop(&mut self) {
        DROPS.with(|d| d.set(d.get() + self.0));
    }
}

fn drops() -> u32 {
    DROPS.with(|d| d.replace(0))
}

/// A VM `C-unwind` fn that panics for negative inputs, with a guard to drop on the way out.
#[inline(never)]
extern "C-unwind" fn vm_checked(x: i32, y: f64) -> f64 {
    let _g = Guard(1);
    if x < 0 {
        panic!("negative {x}");
    }
    x as f64 * y
}

/// A native `C-unwind` fn that panics for negative inputs.
#[inline(never)]
extern "C-unwind" fn native_checked(x: i64) -> i64 {
    native!();
    let _g = Guard(10);
    if x < 0 {
        panic!("native negative {x}");
    }
    x * 3
}

/// A VM fn calling the native one, with a cleanup in its frame.
#[inline(never)]
fn vm_through_native(x: i64) -> i64 {
    let _g = Guard(100);
    native_checked(black_box(x)) + 1
}

/// A VM `C-unwind` fn calling the native one: unwinds through a C-unwind VM frame.
#[inline(never)]
extern "C-unwind" fn vm_c_through_native(x: i64) -> i64 {
    let _g = Guard(1000);
    let f: extern "C-unwind" fn(i64) -> i64 = black_box(native_checked);
    f(x) - 1
}

/// A native caller of the VM `C-unwind` fn.
#[inline(never)]
fn native_caller(x: i32) -> Result<f64, String> {
    native!();
    catch(|| vm_checked(black_box(x), 1.5))
}

/// A native `C-unwind` fn calling back into VM code that panics: native, VM, native frames.
#[inline(never)]
extern "C-unwind" fn native_calls_vm(x: i32) -> f64 {
    native!();
    let _g = Guard(10000);
    vm_checked(black_box(x), 2.0) + 0.5
}

fn catch<R>(f: impl FnOnce() -> R) -> Result<R, String> {
    panic::catch_unwind(AssertUnwindSafe(f)).map_err(|e| match e.downcast::<String>() {
        Ok(s) => *s,
        Err(e) => e.downcast::<&str>().map(|s| s.to_string()).unwrap_or_default(),
    })
}

#[inline(never)]
fn vm_callers() {
    for x in [3, -2] {
        println!("direct {x}: {:?} drops {}", catch(|| vm_checked(black_box(x), 2.5)), drops());
        let f: extern "C-unwind" fn(i32, f64) -> f64 = black_box(vm_checked);
        println!("ptr {x}: {:?} drops {}", catch(|| f(x, 0.5)), drops());
    }
    for x in [4, -7] {
        println!("through native {x}: {:?} drops {}", catch(|| vm_through_native(x)), drops());
        println!("c through native {x}: {:?} drops {}", catch(|| vm_c_through_native(x)), drops());
        println!("native calls vm {x}: {:?} drops {}", catch(|| native_calls_vm(x as i32)), drops());
    }
}

#[inline(never)]
fn native_callers() {
    native!();
    for x in [5, -1] {
        println!("native caller {x}: {:?} drops {}", native_caller(x), drops());
    }
}

fn main() {
    panic::set_hook(Box::new(|_| {}));
    vm_callers();
    native_callers();
    // A hot loop, for the JIT and OSR.
    let mut caught = 0;
    for i in 0..2000 {
        if catch(|| vm_through_native(if i % 7 == 0 { -1 } else { i })).is_err() {
            caught += 1;
        }
    }
    println!("caught {caught} drops {}", drops());
}
