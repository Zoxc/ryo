//! Overrides `vlk`'s weak `vml_weak`: every caller, VM or native, must reach this one.

#[unsafe(no_mangle)]
pub fn vml_weak(x: u32) -> u32 {
    x + 1
}

fn main() {
    println!("{}", vlk::callers(1));
    println!("{}", vlk::vml_weak(2) + vlk::vml_weak_kept(2));
    println!("{:?}", vlk::pointers().map(|f| f(3)));
}
