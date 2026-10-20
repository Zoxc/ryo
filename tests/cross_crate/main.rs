//! Uses the rlib `lib.rs` (crate `ccl`).
use ccl::{Describe, Stack};

#[derive(Debug, Clone)]
struct Local(u8);

impl Describe for Local {
    fn describe(&self) -> String {
        format!("local {}", self.0)
    }
}

fn main() {
    println!("{}", ccl::GREETING);
    let mut s: Stack<Local> = Stack::new();
    s.push(Local(1)).push(Local(2));
    println!("{} {:?}", s.len(), s.pop());
    let mut t: Stack<&str> = Stack::new();
    t.push("x");
    let ds: Vec<Box<dyn Describe>> =
        vec![Box::new(s), Box::new(t), Box::new(Local(9)), ccl::boxed_describer(3)];
    for d in &ds {
        println!("{}", d.describe());
    }
    println!("{} {}", ccl::sum_all(&[1.5f32, 2.25]), ccl::sum_all(&[7u128, 8]));
    println!("{} {}", ccl::inline_square(-12), ccl::non_generic(30));
}
