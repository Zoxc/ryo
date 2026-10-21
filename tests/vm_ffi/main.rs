//! VM functions using a foreign static from a static library (`clib.rs`): on
//! PE the static is reached through an indirect slot plus a direct one (design/platforms.md).
//! And a libc function under a `\u{1}`-prefixed `link_name`, as bindgen writes for C++
//! methods: the prefix isn't part of the symbol.

#[link(name = "ryo_clib", kind = "static")]
unsafe extern "C" {
    static RYO_C_COUNTER: u32;
}

unsafe extern "C" {
    #[link_name = "\u{1}strlen"]
    fn c_strlen(s: *const std::ffi::c_char) -> usize;
}

fn read() -> u32 {
    unsafe { RYO_C_COUNTER }
}

fn add(x: u32) -> u32 {
    read().wrapping_add(x)
}

fn main() {
    println!("{} {} {}", read(), add(std::hint::black_box(1)), unsafe { c_strlen(std::hint::black_box(c"abc").as_ptr()) });
}
