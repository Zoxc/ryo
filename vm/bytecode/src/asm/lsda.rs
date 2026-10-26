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
use super::leb::{self, Reader};

fn uleb(out: &mut Vec<u8>, v: u32) {
    leb::put(out, v.into());
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

/// Reads an LSDA written by [`write`] back. `None` if it isn't one (also for a value not in
/// its shortest encoding, as [`write`] never writes one).
pub fn parse(lsda: &[u8]) -> Option<Vec<CallSite>> {
    if lsda.get(..3)? != [0xff, 0xff, 0x01] {
        return None;
    }
    let mut r = Reader(&lsda[3..]);
    let len = r.minimal_u32()? as usize;
    let (mut table, actions) = (Reader(r.0.get(..len)?), &r.0[len..]);
    let mut out = Vec::new();
    while !table.0.is_empty() {
        let (start, l, pad, action) = (table.minimal_u32()?, table.minimal_u32()?, table.minimal_u32()?, table.minimal_u32()?);
        if action > 1 || (action == 1 && pad == 0) {
            return None;
        }
        out.push(CallSite { start, len: l, pad: (pad != 0).then_some(pad), catch: action == 1 });
    }
    let want: &[u8] = if out.iter().any(|s| s.catch) { &[1, 0] } else { &[] };
    (actions == want).then_some(out)
}
