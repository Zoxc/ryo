//! Box and Vec (the heap through `__rust_alloc` & co.): growth, insert/remove, nested
//! vectors, `String` building, `Box` of large values, linked lists.
include!("common/print.rs");
use std::hint::black_box;

enum List {
    Cons(u32, Box<List>),
    Nil,
}

fn list_sum(l: &List) -> u32 {
    match l {
        List::Cons(v, rest) => v + list_sum(rest),
        List::Nil => 0,
    }
}

fn main() {
    let b = Box::new(black_box(41u64));
    let c = *b + 1;
    out::u(c as u128);
    out::sp();
    let big = Box::new([7u8; 1000]);
    out::u(big.iter().map(|&x| x as u32).sum::<u32>() as u128);
    out::nl();
    let mut v: Vec<u32> = Vec::new();
    for i in 0..black_box(100) {
        v.push(i * 3);
    }
    out::us(&[v.len() as u128, v[99] as u128, v.capacity().min(128) as u128]);
    v.insert(0, 999);
    v.remove(50);
    v.retain(|x| x % 2 == 1);
    v.truncate(10);
    v.extend_from_slice(&[1, 2, 3]);
    out::us(&v.iter().map(|&x| x as u128).collect::<Vec<_>>());
    let mut vv: Vec<Vec<u8>> = Vec::with_capacity(2);
    for i in 0..5u8 {
        vv.push((0..i).collect());
    }
    let lens: Vec<u128> = vv.iter().map(|x| x.len() as u128).collect();
    out::us(&lens);
    let mut s = String::new();
    s.push_str("abc");
    s.push('é');
    s += "def";
    s.insert(1, '-');
    out::str(&s);
    out::sp();
    out::u(s.len() as u128);
    out::sp();
    let mut up = s;
    up.make_ascii_uppercase();
    out::str(&up);
    out::nl();
    let mut l = List::Nil;
    for i in 1..=10 {
        l = List::Cons(i, Box::new(l));
    }
    out::u(list_sum(&l) as u128);
    out::sp();
    let mut q = std::collections::VecDeque::new();
    for i in 0..6u16 {
        if i % 2 == 0 {
            q.push_back(i);
        } else {
            q.push_front(i);
        }
    }
    while let Some(x) = q.pop_front() {
        out::u(x as u128);
    }
    out::sp();
    let shrunk = {
        let mut w = vec![1u64; 50];
        w.truncate(3);
        w.shrink_to_fit();
        w
    };
    out::u(shrunk.capacity() as u128);
    out::nl();
}
