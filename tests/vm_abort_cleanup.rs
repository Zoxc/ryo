//! Milestone 5: a panic in a drop while VM code unwinds calls `panic_in_cleanup` (the
//! terminate stub of the cleanup's `Terminate` action), which reports it and aborts.
struct P(u32);
impl Drop for P {
    fn drop(&mut self) {
        println!("drop {} panicking={}", self.0, std::thread::panicking());
        if self.0 == 1 {
            panic!("drop panic");
        }
    }
}

fn f(n: u32) {
    let _a = P(1);
    let _b = P(2);
    if n > 0 {
        panic!("outer {n}");
    }
}

fn main() {
    // The default hook forces a backtrace for non-unwinding panics, and VM frames differ.
    std::panic::set_hook(Box::new(|i| println!("hook: {} at line {}", i.payload_as_str().unwrap_or(""), i.location().unwrap().line())));
    f(std::hint::black_box(3));
}
