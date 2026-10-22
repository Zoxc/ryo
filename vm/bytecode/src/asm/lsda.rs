//! The LSDA (`.gcc_except_table`) of a function: the call-site table `rust_eh_personality`
//! reads. A landing pad is a cleanup (action 0), or catches everything (action 1, the one
//! action record: type filter 1, which the Rust personality takes as a catch without reading
//! a type table). A call outside every call site terminates when it unwinds.
//!
//! Layout: `lpstart` omitted (`0xff`, landing pads are relative to the function start),
//! `ttype` omitted (`0xff`), call-site encoding `uleb128` (`0x01`), the table's length, then
//! per call site its start, length, landing pad (0: none, unwinding continues) and action,
//! all `uleb128`; then, if a call site catches, the action record `01 00`.

use alloc::vec::Vec;

use super::CallSite;

pub(crate) fn uleb(out: &mut Vec<u8>, mut v: u32) {
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
        uleb(&mut table, s.catch as u32);
    }
    let mut out = Vec::with_capacity(table.len() + 8);
    out.extend_from_slice(&[0xff, 0xff, 0x01]);
    uleb(&mut out, table.len() as u32);
    out.extend_from_slice(&table);
    if sites.iter().any(|s| s.catch) {
        out.extend_from_slice(&[1, 0]);
    }
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
        if action > 1 || (action == 1 && pad == 0) {
            return None;
        }
        read += [start, l, pad, action].iter().map(|&v| uleb_len(v)).sum::<usize>();
        out.push(CallSite { start, len: l, pad: (pad != 0).then_some(pad), catch: action == 1 });
    }
    let actions: &[u8] = if out.iter().any(|s| s.catch) { &[1, 0] } else { &[] };
    (read == end && lsda.get(end..) == Some(actions)).then_some(out)
}

fn uleb_len(v: u32) -> usize {
    (32 - v.max(1).leading_zeros() as usize).div_ceil(7)
}
