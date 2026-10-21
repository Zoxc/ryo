//! The LSDA (`.gcc_except_table`) of a function: the call-site table `rust_eh_personality`
//! reads. No type table and no actions: a landing pad is a cleanup, and a call outside every
//! call site terminates when it unwinds.
//!
//! Layout: `lpstart` omitted (`0xff`, landing pads are relative to the function start),
//! `ttype` omitted (`0xff`), call-site encoding `uleb128` (`0x01`), the table's length, then
//! per call site its start, length, landing pad (0: none, unwinding continues) and action
//! (0), all `uleb128`.

use alloc::vec::Vec;

use super::CallSite;

fn uleb(out: &mut Vec<u8>, mut v: u32) {
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

/// The LSDA of a function with these call sites (sorted by position).
pub fn write(sites: &[CallSite]) -> Vec<u8> {
    let mut table = Vec::new();
    for s in sites {
        uleb(&mut table, s.start);
        uleb(&mut table, s.len);
        uleb(&mut table, s.pad.unwrap_or(0));
        uleb(&mut table, 0);
    }
    let mut out = Vec::with_capacity(table.len() + 8);
    out.extend_from_slice(&[0xff, 0xff, 0x01]);
    uleb(&mut out, table.len() as u32);
    out.extend_from_slice(&table);
    out
}

/// Reads an LSDA written by [`write`] back. `None` if it isn't one.
pub fn parse(lsda: &[u8]) -> Option<Vec<CallSite>> {
    if lsda.get(..3)? != [0xff, 0xff, 0x01] {
        return None;
    }
    let mut pos = 3;
    let mut next = || -> Option<u32> {
        let mut v = 0u64;
        let mut shift = 0;
        loop {
            let b = *lsda.get(pos)?;
            pos += 1;
            v |= ((b & 0x7f) as u64) << shift;
            if b & 0x80 == 0 {
                return u32::try_from(v).ok();
            }
            shift += 7;
            if shift > 35 {
                return None;
            }
        }
    };
    let len = next()? as usize;
    // The bytes read so far: the header and the length.
    let mut read = 3 + uleb_len(len as u32);
    let end = read + len;
    let mut out = Vec::new();
    while read < end {
        let (start, l, pad, action) = (next()?, next()?, next()?, next()?);
        if action != 0 {
            return None;
        }
        read += [start, l, pad, action].iter().map(|&v| uleb_len(v)).sum::<usize>();
        out.push(CallSite { start, len: l, pad: (pad != 0).then_some(pad) });
    }
    (read == end && end == lsda.len()).then_some(out)
}

fn uleb_len(v: u32) -> usize {
    (32 - v.max(1).leading_zeros() as usize).div_ceil(7)
}
