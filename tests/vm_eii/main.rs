//! EII implementations (`#[<decl>]`): cg_llvm defines the declaration's symbol as a forwarder
//! next to the implementation, so the implementations must stay native.
#![feature(extern_item_impls)]
#![allow(incomplete_features)]

#[vme::greet]
fn my_greet(x: u64) -> u64 {
    x + 1
}

#[vme::need]
fn my_need(x: u64) -> u64 {
    x + 2
}

/// Declared and implemented in this crate.
#[eii]
fn hello(x: u64) -> u64;

#[hello]
fn hello_impl(x: u64) -> u64 {
    x * 3
}

/// A local default.
#[eii(local)]
fn local_default(x: u64) -> u64 {
    x * 5
}

fn main() {
    println!("{}", vme::calls(1));
    println!("{} {}", vme::greet_default(5), my_greet(5));
    println!("{} {}", vme::other_default(6), vme::need(7));
    println!("{} {}", hello(4), hello_impl(4));
    println!("{}", local_default(8));
    let f: fn(u64) -> u64 = vme::greet_default;
    let g: fn(u64) -> u64 = hello;
    println!("{} {}", f(9), g(9));
}
