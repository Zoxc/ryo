//! Milestone 5: a panic escaping a function that can't unwind calls `panic_cannot_unwind`
//! (the terminate stub of its calls' `Terminate` actions), which reports it and aborts.
#![feature(rustc_attrs)]
#![allow(internal_features)]

#[rustc_nounwind]
fn no_unwind(x: u32) -> u32 {
    if x > 2 {
        panic!("escapes {x}");
    }
    x
}

fn main() {
    // The default hook forces a backtrace for non-unwinding panics, and VM frames differ.
    std::panic::set_hook(Box::new(|i| println!("hook: {} at line {}", i.payload_as_str().unwrap_or(""), i.location().unwrap().line())));
    println!("{}", no_unwind(std::hint::black_box(1)));
    println!("{}", no_unwind(std::hint::black_box(5)));
}
