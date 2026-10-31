//! VM functions: `main`, which std's `lang_start` calls through its portal, and the small
//! functions it calls VM to VM, all bytecode (printing included).

fn answer() -> i32 {
    42
}

/// Arguments of mixed sizes, which the argument block reorders.
fn pick(_a: u8, b: u64, _c: i16) -> u64 {
    b
}

/// A VM → VM call.
fn twice() -> i32 {
    answer()
}

pub fn wide(x: u128) -> u128 {
    x
}

/// `LocalCopy`: its symbol gets the crate-unique suffix.
#[inline(always)]
fn always() -> u16 {
    7
}

fn main() {
    println!("{}", answer());
    // A portal reached through a fn pointer.
    let f: fn() -> i32 = answer;
    println!("{}", f());
    let g: fn(u8, u64, i16) -> u64 = pick;
    println!("{:x} {:x}", pick(1, 0x1234_5678_9abc_def0, -3), g(2, 5, 6));
    println!("{}", twice());
    println!("{:x}", wide(0x0123_4567_89ab_cdef_fedc_ba98_7654_3210));
    println!("{}", always());
}
