// staticlib C: floats, sorting, Box<dyn>, Rc, fmt with floats, i128
use std::rc::Rc;
trait F { fn f(&self, x: f64) -> f64; }
struct Sq; impl F for Sq { fn f(&self, x: f64) -> f64 { x * x } }
fn work_c(n: u64) -> u64 {
    let b: Box<dyn F> = Box::new(Sq);
    let mut v: Vec<f64> = (0..n).map(|i| b.f(i as f64).sqrt()).collect();
    v.sort_by(|a, b| b.partial_cmp(a).unwrap());
    let r = Rc::new(v); let x: i128 = (r.len() as i128) << 70;
    (r.iter().sum::<f64>() as u64) + (x >> 70) as u64 + format!("{:.3}", r[0]).len() as u64
}
#[unsafe(no_mangle)] pub extern "C" fn c_run(n: u64) -> u64 { work_c(n) }
