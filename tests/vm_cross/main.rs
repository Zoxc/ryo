//! Calls the VM functions of the rlibs `vml` and `vml2`.

fn main() {
    println!("{}", vml::answer());
    println!("{}", vml::generic::<u8>());
    println!("{} {}", vml::generic::<u16>(), vml::generic_u16());
    println!("{}", vml::always());
    let f: fn() -> i32 = vml::always;
    println!("{} {}", f(), vml2::always_ptr()());
    println!("{}", vml::inl());
    println!("{}", vml::calls_answer());
    println!("{}", vml::native_caller());
    println!("{}", vml2::own());
}
