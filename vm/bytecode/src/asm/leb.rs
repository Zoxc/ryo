//! LEB128, as the instruction list stream, the LSDA and the unwind info use it.

#[cfg(feature = "alloc")]
use alloc::vec::Vec;

/// Appends `v` as ULEB128.
#[cfg(feature = "alloc")]
pub fn put(out: &mut Vec<u8>, mut v: u64) {
    loop {
        let b = (v & 0x7f) as u8;
        v >>= 7;
        if v == 0 {
            out.push(b);
            return;
        }
        out.push(b | 0x80);
    }
}

#[cfg(feature = "alloc")]
/// `v` zigzag-encoded, for [`put`] ([`Reader::zigzag_i32`] reads it).
pub fn zigzag(v: i32) -> u64 {
    ((v << 1) ^ (v >> 31)) as u32 as u64
}

/// A reader of ULEB128 values: `None` at the end or for a value that doesn't fit.
pub struct Reader<'a>(pub &'a [u8]);

impl Reader<'_> {
    pub fn u64(&mut self) -> Option<u64> {
        let mut v = 0u64;
        let mut shift = 0;
        while shift < 64 {
            let (&b, rest) = self.0.split_first()?;
            self.0 = rest;
            // The 10th byte holds only bit 63.
            if shift == 63 && b & 0x7e != 0 {
                return None;
            }
            v |= ((b & 0x7f) as u64) << shift;
            if b & 0x80 == 0 {
                return Some(v);
            }
            shift += 7;
        }
        None
    }

    pub fn u32(&mut self) -> Option<u32> {
        u32::try_from(self.u64()?).ok()
    }

    /// A `u32` in its shortest encoding (no trailing `0x80`-continued zero byte).
    pub fn minimal_u32(&mut self) -> Option<u32> {
        let before = self.0;
        let v = self.u32()?;
        let n = before.len() - self.0.len();
        (n == 1 || before.get(n - 1) != Some(&0)).then_some(v)
    }

    pub fn zigzag_i32(&mut self) -> Option<i32> {
        let v = self.u32()?;
        Some((v >> 1) as i32 ^ -((v & 1) as i32))
    }
}
