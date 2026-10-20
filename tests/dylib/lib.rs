//! A Rust dylib (crate `rdy`) used by `main.rs`.
pub fn shout(s: &str) -> String {
    format!("{}!", s.to_uppercase())
}

pub fn map_all<T, U>(xs: Vec<T>, f: impl Fn(T) -> U) -> Vec<U> {
    xs.into_iter().map(f).collect()
}

pub struct Counter {
    pub n: u32,
}

impl Counter {
    pub fn bump(&mut self) -> u32 {
        self.n += 1;
        self.n
    }
}
