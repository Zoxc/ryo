//! VM functions using a foreign static from a static library (`clib.rs`): on
//! PE the static is reached through an indirect slot plus a direct one (design/platforms.md).

#[link(name = "ryo_clib", kind = "static")]
unsafe extern "C" {
    static RYO_C_COUNTER: u32;
}

fn read() -> u32 {
    unsafe { RYO_C_COUNTER }
}

fn add(x: u32) -> u32 {
    read().wrapping_add(x)
}

fn main() {
    println!("{} {}", read(), add(std::hint::black_box(1)));
}
