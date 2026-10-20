//! Milestone 5: `#[track_caller]` functions in the VM and caller locations, `Assert` panics,
//! unwinding through VM frames and across VM/native boundaries (`catch_unwind`, native
//! callbacks, threads), `panicking()` during VM cleanup, and fused compare-and-branch.
#![feature(closure_track_caller, stmt_expr_attributes)]
use std::cell::{Cell, RefCell};
use std::hint::black_box;
use std::panic::{self, AssertUnwindSafe, Location};

thread_local! { static LOG: Cell<u32> = const { Cell::new(0) }; }

fn line(l: &Location<'_>) -> String {
    format!("{}:{}", l.line(), l.column())
}

#[track_caller]
fn here() -> &'static Location<'static> {
    Location::caller()
}

#[track_caller]
fn nested() -> &'static Location<'static> {
    here()
}

#[track_caller]
fn with_args(a: u32, b: &str, c: (u8, u64)) -> String {
    format!("{a} {b} {c:?} at {}", line(Location::caller()))
}

#[track_caller]
fn tc_many(a: u8, b: u16, c: u32, d: u64, e: u128, f: i8, g: (u8, u8), h: &str) -> String {
    format!("{a}{b}{c}{d}{e}{f}{g:?}{h} {}", Location::caller().line())
}

#[track_caller]
fn generic<X: std::fmt::Debug>(x: X) -> String {
    format!("{x:?} {}", line(Location::caller()))
}

#[track_caller]
fn checked_div(a: i32, b: i32) -> i32 {
    if b == 0 {
        panic!("div by zero");
    }
    a / b
}

#[track_caller]
fn tc_closure() -> u32 {
    let f = #[track_caller] || Location::caller().line();
    f()
}

#[track_caller]
fn tc_nine(a: u8, b: u16, c: u32, d: u64, e: i8, f: i16, g: i32, h: i64, i: &str) -> String {
    format!("{a}{b}{c}{d}{e}{f}{g}{h}{i} {}", line(Location::caller()))
}

/// Native (`#[target_feature]` functions stay native), so it calls `tc_nine` through its
/// `portal_tc9`, which passes this call site's location to the VM.
#[target_feature(enable = "sse2")]
fn native_caller() -> String {
    tc_nine(1, 2, 3, 4, -5, -6, -7, -8, "nine")
}

trait Loc {
    #[track_caller]
    fn at(&self) -> u32;
}
impl Loc for S {
    #[track_caller]
    fn at(&self) -> u32 {
        self.0 * 1000 + Location::caller().line()
    }
}

struct S(u32);
impl S {
    #[track_caller]
    fn loc(&self) -> (u32, u32) {
        (self.0, Location::caller().line())
    }
}

struct D(u32);
impl Drop for D {
    fn drop(&mut self) {
        LOG.with(|l| l.set(l.get() * 10 + self.0));
        println!("drop {} panicking={}", self.0, std::thread::panicking());
    }
}

fn deep(n: u32) -> u32 {
    let _d = D(n % 10);
    if n == 0 {
        panic!("bottom");
    }
    deep(n - 1) + 1
}

fn idx(v: &[u32], i: usize) -> u32 {
    v[i]
}

/// VM → native (`sort_by`) → VM closure that panics.
fn sort_panics(v: &mut [i32]) {
    let _g = D(7);
    v.sort_by(|a, b| {
        if *a == 3 || *b == 3 {
            panic!("three");
        }
        a.cmp(b)
    });
}

fn call_ptr(f: fn(u32) -> u32, x: u32) -> u32 {
    let _d = D(8);
    f(x)
}

#[track_caller]
fn tc_panic(x: u32) -> u32 {
    if x > 1 {
        panic!("tc {x}");
    }
    x
}

fn rethrow() {
    if let Err(e) = panic::catch_unwind(|| deep(2)) {
        println!("rethrowing");
        panic::resume_unwind(e);
    }
}

/// Compare-and-branch at every width, signed and unsigned, against registers and immediates.
fn compares(xs: &[i64]) -> u64 {
    let mut h = 0u64;
    for &x in xs {
        for &y in xs {
            let bits = [
                (x as i8) < (y as i8),
                (x as u8) <= (y as u8),
                (x as i16) > (y as i16),
                (x as u16) >= (y as u16),
                (x as i32) == (y as i32),
                (x as u32) != (y as u32),
                x < y,
                (x as u64) > (y as u64),
                (x as i128) <= (y as i128) << 70,
                (x as u128) >= (y as u128),
                x > -3,
                (x as u32) < 7,
                (x as u8) >= 200,
            ];
            for b in bits {
                h = h.wrapping_mul(3) + if b { 1 } else { 2 };
            }
        }
    }
    h
}

fn main() {
    panic::set_hook(Box::new(|info| {
        let msg = info
            .payload()
            .downcast_ref::<&str>()
            .map(|s| s.to_string())
            .or_else(|| info.payload().downcast_ref::<String>().cloned())
            .unwrap_or_default();
        println!("panic at {}: {msg}", line(info.location().unwrap()));
    }));
    println!("{}", line(here()));
    println!("{}", line(nested()));
    println!("{}", with_args(1, "x", (2, 3)));
    println!("{}", tc_many(1, 2, 3, 4, 5, -6, (7, 8), "h"));
    println!("{}", generic(vec![1u8]));
    println!("{:?}", S(5).loc());
    println!("{}", tc_closure());
    println!("{}", unsafe { native_caller() });
    let d: &dyn Loc = &S(3);
    println!("{}", d.at());
    let b: Box<dyn FnOnce() -> u32> = Box::new(#[track_caller] || Location::caller().line());
    println!("{}", b());
    let f: fn() -> &'static Location<'static> = here;
    println!("{}", f().line());

    println!("{}", panic::catch_unwind(|| checked_div(4, 0)).is_err());
    println!("{}", panic::catch_unwind(|| idx(&[1, 2], black_box(5))).is_err());
    println!("{}", panic::catch_unwind(|| deep(4)).is_err());
    println!("log {}", LOG.with(|l| l.replace(0)));
    let mut v = vec![5, 1, 4, 3, 2];
    println!("{}", panic::catch_unwind(AssertUnwindSafe(|| sort_panics(&mut v))).is_err());
    println!("{}", panic::catch_unwind(|| call_ptr(tc_panic, 5)).is_err());
    println!("{}", panic::catch_unwind(|| call_ptr(|x| tc_panic(x), 6)).is_err());
    println!("{}", panic::catch_unwind(rethrow).is_err());
    let r: Result<u32, &str> = Err("e");
    println!("{}", panic::catch_unwind(|| r.unwrap()).is_err());
    let o: Option<u32> = None;
    println!("{}", panic::catch_unwind(|| o.expect("none!")).is_err());
    let s = "héllo";
    println!("{}", panic::catch_unwind(|| s[0..black_box(2)].len()).is_err());
    println!("{}", panic::catch_unwind(|| black_box(1i32) / black_box(0)).is_err());
    println!("{}", panic::catch_unwind(|| black_box(i32::MIN) / black_box(-1)).is_err());
    let cell = RefCell::new(1);
    let _b = cell.borrow_mut();
    println!("{}", panic::catch_unwind(AssertUnwindSafe(|| *cell.borrow())).is_err());
    let m = std::sync::Mutex::new(1);
    let _ = panic::catch_unwind(AssertUnwindSafe(|| {
        let _g = m.lock().unwrap();
        panic!("poison");
    }));
    println!("poisoned {}", m.is_poisoned());
    let h = std::thread::spawn(|| deep(1));
    println!("thread err {}", h.join().is_err());
    println!("panicking={}", std::thread::panicking());
    println!("{}", compares(&[i64::MIN, -300, -1, 0, 1, 7, 255, 1 << 40, i64::MAX]));
    // Overflow checks depend on the opt-level, which the variants differ in, so `Assert`s
    // that always run are used: bounds checks above, division here. Uncaught: exit code 101.
    deep(2);
}
