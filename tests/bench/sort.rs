//! `y bench`: sorting, with std's sort and a hand-written merge sort.

/// A deterministic xorshift generator.
struct Rng(u64);

impl Rng {
    fn next(&mut self) -> u64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0
    }
}

fn merge_sort(v: &mut [u32], tmp: &mut Vec<u32>) {
    if v.len() <= 16 {
        for i in 1..v.len() {
            let mut j = i;
            while j > 0 && v[j - 1] > v[j] {
                v.swap(j - 1, j);
                j -= 1;
            }
        }
        return;
    }
    let mid = v.len() / 2;
    merge_sort(&mut v[..mid], tmp);
    merge_sort(&mut v[mid..], tmp);
    tmp.clear();
    let (mut i, mut j) = (0, mid);
    while i < mid && j < v.len() {
        if v[i] <= v[j] {
            tmp.push(v[i]);
            i += 1;
        } else {
            tmp.push(v[j]);
            j += 1;
        }
    }
    tmp.extend_from_slice(&v[i..mid]);
    tmp.extend_from_slice(&v[j..]);
    v.copy_from_slice(tmp);
}

fn checksum(v: &[u32]) -> u64 {
    v.iter().enumerate().fold(0u64, |acc, (i, &x)| acc.wrapping_mul(31).wrapping_add(x as u64 ^ i as u64))
}

fn main() {
    let n = std::hint::black_box(1_000_000);
    let mut rng = Rng(0x2545_f491_4f6c_dd1d);
    let data: Vec<u32> = (0..n).map(|_| rng.next() as u32).collect();

    let mut a = data.clone();
    a.sort_unstable();
    let mut b = data.clone();
    merge_sort(&mut b, &mut Vec::with_capacity(n));
    assert_eq!(a, b);
    let mut c: Vec<(u32, u32)> = data.iter().map(|&x| (x % 1000, x)).collect();
    c.sort_by_key(|&(k, _)| k);
    println!("sorted {n}: {:x} {:?} {:?}", checksum(&a), c[0], c[n - 1]);
}
