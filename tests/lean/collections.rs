//! Generic std collections with MIR: BTreeMap, BTreeSet, BinaryHeap, Rc/RefCell, Cell.
include!("common/print.rs");
use std::cell::{Cell, RefCell};
use std::collections::{BTreeMap, BTreeSet, BinaryHeap};
use std::hint::black_box;
use std::rc::Rc;

struct Node {
    val: u32,
    children: Vec<Rc<RefCell<Node>>>,
}

fn sum(n: &Rc<RefCell<Node>>) -> u32 {
    let b = n.borrow();
    b.val + b.children.iter().map(sum).sum::<u32>()
}

fn main() {
    let mut m = BTreeMap::new();
    for i in 0..black_box(40u32) {
        *m.entry(i % 7).or_insert(0u32) += i;
    }
    m.remove(&3);
    for (k, v) in &m {
        out::u(*k as u128);
        out::str("=");
        out::u(*v as u128);
        out::sp();
    }
    out::nl();
    let s: BTreeSet<i32> = [5, -1, 9, 5, 0, -7].into_iter().collect();
    let r: Vec<i128> = s.range(-1..=5).map(|&x| x as i128).collect();
    out::is(&r);
    let mut h = BinaryHeap::new();
    for x in [3u8, 9, 1, 7, 7, 2] {
        h.push(x);
    }
    let mut sorted = Vec::new();
    while let Some(x) = h.pop() {
        sorted.push(x as u128);
    }
    out::us(&sorted);
    let leaf = Rc::new(RefCell::new(Node { val: 3, children: vec![] }));
    let root = Rc::new(RefCell::new(Node { val: 1, children: vec![leaf.clone(), Rc::new(RefCell::new(Node { val: 5, children: vec![] }))] }));
    leaf.borrow_mut().val = 30;
    out::us(&[sum(&root) as u128, Rc::strong_count(&leaf) as u128]);
    let c = Cell::new(black_box(4));
    c.set(c.get() * c.get());
    let old = c.replace(1);
    out::us(&[old as u128, c.get() as u128]);
    let shared = RefCell::new(vec![1u8]);
    {
        let mut w = shared.borrow_mut();
        w.push(2);
    }
    out::b(shared.try_borrow_mut().is_ok());
    out::sp();
    let r1 = shared.borrow();
    out::b(shared.try_borrow_mut().is_err());
    out::sp();
    out::u(r1.len() as u128);
    out::nl();
}
