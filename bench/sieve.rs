//! `y bench`: loops over a bit vector.

fn sieve(limit: usize) -> Vec<bool> {
    let mut prime = vec![true; limit + 1];
    prime[0] = false;
    prime[1] = false;
    let mut i = 2;
    while i * i <= limit {
        if prime[i] {
            let mut j = i * i;
            while j <= limit {
                prime[j] = false;
                j += i;
            }
        }
        i += 1;
    }
    prime
}

fn main() {
    let limit = std::hint::black_box(13_000_000);
    let prime = sieve(limit);
    let count = prime.iter().filter(|&&p| p).count();
    let last = (0..=limit).rev().find(|&i| prime[i]).unwrap();
    println!("{count} primes up to {limit}, the largest is {last}");
}
