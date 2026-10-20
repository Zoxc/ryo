//! Fn items as values (`map(Some)`): the `Fn*` shims of a fn item type are VM functions, and
//! so are upstream enum constructors. A native fn item called from its own shims must not go
//! through the `call` template, which would come back to the shim.

#[derive(Debug, Clone, Copy)]
enum Local {
    X(u32),
    Y,
}

/// Native as a whole (inline asm).
fn with_asm(x: u32) -> u32 {
    let y: u32;
    unsafe { std::arch::asm!("lea {0:e}, [{1:e} + 1]", out(reg) y, in(reg) x) };
    y
}

fn upstream_ctors() -> Vec<Option<Local>> {
    [Local::X(1), Local::Y].into_iter().map(Some).collect()
}

fn local_ctors() -> Vec<Local> {
    [3u32, 4].into_iter().map(Local::X).collect()
}

fn results() -> Vec<Result<u8, String>> {
    let mut v: Vec<Result<u8, String>> = [5u8, 6].into_iter().map(Ok).collect();
    v.extend(["e".to_string()].into_iter().map(Err));
    v
}

fn native_item() -> Vec<u32> {
    [10u32, 20].into_iter().map(with_asm).collect()
}

fn apply<F: FnOnce(u32) -> u32>(f: F, x: u32) -> u32 {
    f(x)
}

fn main() {
    println!("{:?}", upstream_ctors());
    println!("{:?}", local_ctors());
    println!("{:?}", results());
    println!("{:?}", native_item());
    println!("{}", apply(with_asm, 41));
}
