//! Vec, String, HashMap, BTreeMap, HashSet, VecDeque, Rc/RefCell.
use std::cell::RefCell;
use std::collections::{BTreeMap, HashMap, HashSet, VecDeque};
use std::rc::Rc;

fn main() {
    let mut v: Vec<i64> = (0..20).map(|x| x * x - 50).collect();
    v.retain(|x| x % 3 != 0);
    v.dedup();
    v.insert(2, 1000);
    println!("{v:?} {}", v.capacity() >= v.len());

    let mut s = String::new();
    for (i, w) in "the quick brown fox".split_whitespace().enumerate() {
        if i > 0 {
            s.push('-');
        }
        s.push_str(&w.to_uppercase());
    }
    println!("{s} {} {:?}", s.len(), s.find("BROWN"));
    println!("{:>8}|{:<6}|{:^7}|{:08.3}", "r", "l", "c", 3.14159);

    let text = "a b c a b a d e e e e";
    let mut counts: HashMap<&str, usize> = HashMap::new();
    for w in text.split(' ') {
        *counts.entry(w).or_default() += 1;
    }
    let mut sorted: Vec<_> = counts.into_iter().collect();
    sorted.sort();
    println!("{sorted:?}");

    let mut bt = BTreeMap::new();
    for i in [5, 1, 9, 3] {
        bt.insert(i, i.to_string().repeat(i));
    }
    println!("{bt:?} {:?}", bt.range(2..6).map(|(k, _)| k).collect::<Vec<_>>());

    let set: HashSet<u32> = (0..50).filter(|x| x % 7 == 0).collect();
    let mut sv: Vec<_> = set.iter().copied().collect();
    sv.sort_unstable();
    println!("{sv:?} {}", set.contains(&21));

    let mut dq: VecDeque<i32> = VecDeque::new();
    dq.push_back(1);
    dq.push_front(0);
    dq.push_back(2);
    dq.rotate_left(1);
    println!("{dq:?}");

    let shared = Rc::new(RefCell::new(vec![1]));
    let other = Rc::clone(&shared);
    other.borrow_mut().push(2);
    println!("{:?} {}", shared.borrow(), Rc::strong_count(&shared));
}
