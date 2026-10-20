//! Calls the VM functions of the dylib `vmd`, and has a VM function of its own.

fn local() -> i32 {
    1
}

fn main() {
    println!("{}", vmd::answer());
    println!("{}", vmd::generic::<i8>());
    println!("{}", vmd::native_caller());
    println!("{}", local());
}
