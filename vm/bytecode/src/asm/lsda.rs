//! The LSDA (`.gcc_except_table`) of a function: the call-site table `rust_eh_personality`
//! reads. A landing pad is a cleanup (action 0), or catches everything (action 1, the one
//! action record: type filter 1, which the Rust personality takes as a catch without reading
//! a type table). A call outside every call site terminates when it unwinds.
//!
//! Layout: `lpstart` omitted (`0xff`, landing pads are relative to the function start),
//! `ttype` omitted (`0xff`), call-site encoding `uleb128` (`0x01`), the table's length, then
//! per call site its start, length, landing pad (0: none, unwinding continues) and action,
//! all `uleb128`; then, if a call site catches, the action record `01 00`.

#[cfg(feature = "alloc")]
use alloc::vec::Vec;

#[cfg(feature = "alloc")]
use super::leb;
use super::leb::Reader;

#[cfg(feature = "alloc")]
fn uleb(out: &mut Vec<u8>, v: u32) {
    leb::put(out, v.into());
}

/// A call that may unwind: the call instruction's bytes, and its landing pad (the position
/// of an `lpad`), or `None` if unwinding continues in the caller. Calls without a call site
/// can't unwind (the unwinder aborts if they do).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct CallSite {
    pub start: u32,
    pub len: u32,
    pub pad: Option<u32>,
    /// The landing pad catches every exception, rather than being a cleanup
    /// ([`crate::image::CATCH`]).
    pub catch: bool,
}

/// The LSDA of a function with these call sites (sorted by position).
#[cfg(feature = "alloc")]
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

/// The call-site table of the LSDA `lsda` (written by [`write`]), yielding `None` for a
/// malformed record (and then ending), and the bytes after it (the action records). `None`
/// if `lsda` has no valid header and table length. Without allocating or panicking.
fn sites(lsda: &[u8]) -> Option<(impl Iterator<Item = Option<CallSite>> + '_, &[u8])> {
    if lsda.get(..3)? != [0xff, 0xff, 0x01] {
        return None;
    }
    let mut r = Reader(lsda.get(3..)?);
    let len = r.minimal_u32()? as usize;
    let (mut table, actions) = (Reader(r.0.get(..len)?), r.0.get(len..)?);
    let mut bad = false;
    let iter = core::iter::from_fn(move || {
        if bad || table.0.is_empty() {
            return None;
        }
        let mut record = || {
            let (start, len, pad, action) = (table.minimal_u32()?, table.minimal_u32()?, table.minimal_u32()?, table.minimal_u32()?);
            if action > 1 || (action == 1 && pad == 0) {
                return None;
            }
            Some(CallSite { start, len, pad: (pad != 0).then_some(pad), catch: action == 1 })
        };
        let site = record();
        bad = site.is_none();
        Some(site)
    });
    Some((iter, actions))
}

/// The call site of the LSDA `lsda` (written by [`write`]) that contains the code offset
/// `pc`: `Some(None)` if none does, `None` if `lsda` isn't one. Without allocating or
/// panicking, for the runtime's PE exception handler.
pub fn find(lsda: &[u8], pc: u32) -> Option<Option<CallSite>> {
    for site in sites(lsda)?.0 {
        let site = site?;
        if pc.wrapping_sub(site.start) < site.len {
            return Some(Some(site));
        }
    }
    Some(None)
}

/// Reads an LSDA written by [`write`] back. `None` if it isn't one (also for a value not in
/// its shortest encoding, as [`write`] never writes one).
#[cfg(feature = "alloc")]
pub fn parse(lsda: &[u8]) -> Option<Vec<CallSite>> {
    let (sites, actions) = sites(lsda)?;
    let out = sites.collect::<Option<Vec<_>>>()?;
    let want: &[u8] = if out.iter().any(|s| s.catch) { &[1, 0] } else { &[] };
    (actions == want).then_some(out)
}
