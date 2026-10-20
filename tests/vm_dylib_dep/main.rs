//! Calls into the dylib `vdd` (with std linked dynamically too), and uses a thread local of
//! its own.

thread_local! {
    static COUNT: std::cell::Cell<u32> = const { std::cell::Cell::new(0) };
}

fn bump() -> u32 {
    COUNT.with(|c| c.set(c.get() + 1));
    COUNT.get()
}

fn main() {
    println!("{} {} {}", vdd::g(), bump(), bump());
    println!("{:?}", std::thread::spawn(|| (vdd::g(), bump())).join().unwrap());
}
