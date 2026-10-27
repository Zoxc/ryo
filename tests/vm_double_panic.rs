//! A panic in a drop while a panic unwinds from a VM frame towards a `catch_unwind`: the drop
//! runs in the deeper VM frame's landing pad, its panic hits the cleanup's `Terminate`
//! action, and `panic_in_cleanup` aborts after the frames inside the drop unwound (the exit
//! status is compared too).
use std::hint::black_box;

struct Bomb(u32);

impl Drop for Bomb {
    fn drop(&mut self) {
        println!("drop bomb {} panicking={}", self.0, std::thread::panicking());
        if self.0 == 1 && std::thread::panicking() {
            let _inner = Noisy("inside the drop");
            panic!("bomb");
        }
    }
}

struct Noisy(&'static str);

impl Drop for Noisy {
    fn drop(&mut self) {
        println!("drop {}", self.0);
    }
}

#[inline(never)]
fn deep(n: u32) -> u32 {
    let _b = Bomb(1);
    let _g = Noisy("deep");
    if black_box(n) > 0 {
        panic!("first {n}");
    }
    n
}

#[inline(never)]
fn native_mid(n: u32) -> u32 {
    unsafe { std::arch::asm!("") };
    let _g = Noisy("native");
    deep(n) + 1
}

#[inline(never)]
fn top(n: u32) -> u32 {
    let _b = Bomb(2);
    native_mid(n) + 1
}

fn main() {
    // The default hook forces a backtrace for non-unwinding panics, and VM frames differ.
    std::panic::set_hook(Box::new(|i| println!("hook: {}", i.payload_as_str().unwrap_or(""))));
    println!("{}", top(black_box(0)));
    let r = std::panic::catch_unwind(|| top(black_box(3)));
    println!("not reached: {}", r.is_err());
}
