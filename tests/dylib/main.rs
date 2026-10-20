//! Uses the Rust dylib `lib.rs` (crate `rdy`).
fn main() {
    println!("{}", rdy::shout("from a dylib"));
    println!("{:?}", rdy::map_all(vec![1, 2, 3], |x| x as f64 / 2.0));
    let mut c = rdy::Counter { n: 40 };
    c.bump();
    println!("{}", c.bump());
}
