//! Closures (Fn/FnMut/FnOnce, boxed, returned, fn pointers), iterator adapters, custom iterators.
fn make_adder(n: i32) -> impl Fn(i32) -> i32 {
    move |x| x + n
}

fn make_boxed(kind: u8) -> Box<dyn Fn(i32) -> i32> {
    match kind {
        0 => Box::new(|x| x * 2),
        _ => Box::new(move |x| x - kind as i32),
    }
}

fn apply_twice<F: FnMut()>(mut f: F) {
    f();
    f();
}

struct Fib(u64, u64);

impl Iterator for Fib {
    type Item = u64;
    fn next(&mut self) -> Option<u64> {
        let r = self.0;
        *self = Fib(self.1, self.0 + self.1);
        Some(r)
    }
}

fn main() {
    let add5 = make_adder(5);
    println!("{} {} {}", add5(1), make_boxed(0)(21), make_boxed(3)(10));
    let mut count = 0;
    apply_twice(|| count += 10);
    println!("{count}");
    let s = String::from("moved");
    let once = move || s.len();
    println!("{}", once());
    let fp: fn(i32) -> i32 = |x| x * x;
    println!("{}", [1, 2, 3].map(fp).iter().sum::<i32>());

    let v: Vec<u64> = Fib(0, 1).skip(5).step_by(2).take(6).collect();
    println!("{v:?}");
    let words = ["apple", "bob", "kayak", "zebra", "level"];
    let pal: Vec<_> = words.iter().filter(|w| w.chars().rev().eq(w.chars())).collect();
    println!("{pal:?}");
    let (even, odd): (Vec<i32>, Vec<i32>) = (1..=10).partition(|x| x % 2 == 0);
    println!("{even:?} {odd:?}");
    let rev: Vec<(usize, char)> = "héllo".char_indices().rev().collect();
    println!("{rev:?}");
    let folded = (1..=5).flat_map(|i| (0..i).map(move |j| i * j)).fold(0, |a, b| a + b);
    println!("{folded} {:?}", (1..100).find(|x| x * x > 500));
    let mut sorted = vec![5, 3, 8, 1, 9, 2];
    sorted.sort_by(|a, b| b.cmp(a));
    println!("{sorted:?} {:?}", sorted.iter().max_by_key(|&&x| (x as i32 - 4).abs()));
}
