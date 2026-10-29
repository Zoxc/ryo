//! A dense bit set over indices (values, allocas), one bit each.

use alloc::vec::Vec;
use core::marker::PhantomData;

use super::ir::Value;

/// What a [`BitSet`] holds: a dense index.
pub trait Idx: Copy {
    fn idx(self) -> usize;
    fn at(k: usize) -> Self;
}

impl Idx for usize {
    fn idx(self) -> usize {
        self
    }
    fn at(k: usize) -> Self {
        k
    }
}

impl Idx for Value {
    fn idx(self) -> usize {
        self.0 as usize
    }
    fn at(k: usize) -> Self {
        Value(k as u32)
    }
}

/// A set of the indices below its length.
#[derive(Clone, PartialEq, Eq)]
pub struct BitSet<T = usize>(Vec<u64>, PhantomData<T>);

impl<T: Idx> BitSet<T> {
    /// The empty set of indices below `n`.
    pub fn new(n: usize) -> Self {
        BitSet(alloc::vec![0; n.div_ceil(64)], PhantomData)
    }
    pub fn insert(&mut self, v: T) {
        self.0[v.idx() / 64] |= 1 << (v.idx() % 64);
    }
    pub fn remove(&mut self, v: T) {
        self.0[v.idx() / 64] &= !(1 << (v.idx() % 64));
    }
    pub fn contains(&self, v: T) -> bool {
        self.0[v.idx() / 64] >> (v.idx() % 64) & 1 != 0
    }
    /// Adds `o`'s members. Whether that added any.
    pub fn union_with(&mut self, o: &BitSet<T>) -> bool {
        let mut changed = false;
        for (w, x) in self.0.iter_mut().zip(&o.0) {
            changed |= *w | x != *w;
            *w |= x;
        }
        changed
    }
    pub fn iter(&self) -> impl Iterator<Item = T> + '_ {
        self.0.iter().enumerate().flat_map(|(w, &bits)| {
            let mut x = bits;
            core::iter::from_fn(move || {
                (x != 0).then(|| {
                    let v = T::at(w * 64 + x.trailing_zeros() as usize);
                    x &= x - 1;
                    v
                })
            })
        })
    }
}
