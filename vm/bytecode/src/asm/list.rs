//! A function's instruction list (design/vm.md, "Instruction list"): the side data the decoder
//! reads alongside the machine code, as one sparse stream of entries at byte positions.
//!
//! Each entry starts with a varint `v`: the position advances by `v >> 1` from the previous
//! entry's (from 0 for the first), and `v & 1` says what follows.
//!
//! - `0`, an instruction: the opcode and, plus one (wrapping), the register cache selector
//!   ([`super::inline::Cache::emit_sel`]) of an inline sequence the cache emitted other than
//!   plainly, starting here; or, with the selector [`HANDLER_SEL`] (stored as `0`), the
//!   opcode of the handler a `call` here calls. Every handler call has one: folded handlers
//!   (two opcodes' handlers at one address, by LLVM's MergeFunctions or a linker's ICF) leave
//!   the address alone ambiguous.
//! - `1`, a modifier: its kind, then its fields.
//!   - `0`, a branch target, where the register cache is cleared.
//!   - `1`, a dropped store ([`DroppedStore`]): the frame offset, then `size_log2 << 4 | reg`.
//!   - `2`, `3`, `4`, an escape, a storage end, an island operand ([`Scope`]): the frame
//!     offset and the size, then for an escape the alignment.
//!
//! Numbers are LEB128, frame offsets zigzag-encoded. At one position, the entries come in
//! the order target, scopes, dropped stores, instructions, each kind in its order (sequences
//! that leave no code share a position).
//!
//! The list is an index the decoder checks against the bytes, never trusted over them: the
//! targets must be exactly the branch targets, each instruction entry must decode to the
//! bytes there, each handler entry must be at a handler call whose target is (one of) the
//! opcode's handler addresses, and each dropped store and scope is checked as it is without
//! the list. An
//! inline sequence the cache emitted non-plainly without an entry is still found, by
//! searching the cache's candidates ([`super::inline::Cache::unemit`]).

#[cfg(feature = "alloc")]
use alloc::vec::Vec;

#[cfg(feature = "alloc")]
use super::encode::{DroppedStore, Scope, ScopeKind};
use super::leb::Reader;
#[cfg(feature = "alloc")]
use super::leb::{put, zigzag};
use crate::full::Opcode;

/// The selector of a handler entry: the `call` at its position calls `op`'s handler.
pub const HANDLER_SEL: u32 = u32::MAX;

/// An instruction entry: the inline sequence at byte position `at` is the instruction `op`,
/// emitted by the register cache with the selector `sel`; or with [`HANDLER_SEL`], the `call`
/// at `at` calls `op`'s handler.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Hint {
    pub at: u32,
    pub op: Opcode,
    pub sel: u32,
}

impl Hint {
    /// Whether it names a handler call ([`HANDLER_SEL`]), not an inline sequence.
    pub fn is_handler(&self) -> bool {
        self.sel == HANDLER_SEL
    }
}

/// An entry of the stream, as [`walk`] reads it.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Entry {
    Insn {
        op: Opcode,
        sel: u32,
    },
    Target,
    /// The frame offset, the size (1, 2, 4 or 8) and the register (x86 number, one the
    /// inline sequences compute in).
    Dropped {
        frame_offset: i32,
        size: u8,
        reg: u8,
    },
    /// `kind` 2 (escape, of alignment `align`), 3 (end) or 4 (lend; `align` 0 but for escapes).
    Scope {
        frame_offset: i32,
        size: u32,
        kind: u8,
        align: u32,
    },
}

/// A function's instruction list, its entries by kind, each sorted by position.
#[cfg(feature = "alloc")]
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct InsnList {
    /// The branch targets (byte positions), without duplicates.
    pub targets: Vec<u32>,
    pub hints: Vec<Hint>,
    pub dropped: Vec<DroppedStore>,
    pub scopes: Vec<Scope>,
}

/// Reads the stream `bytes` of a function of `code_len` bytes, calling `f` with each entry
/// and its position. `None` if it isn't well formed: every position within the code (the end
/// included), every field valid, the entries at one position in order (a target once).
pub fn walk(bytes: &[u8], code_len: u32, mut f: impl FnMut(u32, Entry)) -> Option<()> {
    let mut b = Reader(bytes);
    let mut pos = 0u32;
    // The kind order of the last entry at `pos`.
    let mut last: Option<u8> = None;
    while !b.0.is_empty() {
        let v = b.u64()?;
        let delta = u32::try_from(v >> 1).ok()?;
        pos = pos.checked_add(delta).filter(|&p| p <= code_len)?;
        if delta != 0 {
            last = None;
        }
        let (order, e) = if v & 1 == 0 {
            let op = Opcode::from_u16(u16::try_from(b.u64()?).ok()?)?;
            (3, Entry::Insn { op, sel: b.u32()?.wrapping_sub(1) })
        } else {
            match b.u64()? {
                0 => (0, Entry::Target),
                1 => {
                    let frame_offset = b.zigzag_i32()?;
                    let sr = b.u64()?;
                    let size = match sr >> 4 {
                        l @ 0..=3 => 1u8 << l,
                        _ => return None,
                    };
                    let reg = (sr & 0xf) as u8;
                    if !matches!(reg, 0 | 2 | 6..=11) {
                        return None;
                    }
                    (2, Entry::Dropped { frame_offset, size, reg })
                }
                k @ 2..=4 => {
                    let frame_offset = b.zigzag_i32()?;
                    let size = b.u32()?;
                    let align = if k == 2 { b.u32().filter(|a| a.is_power_of_two() && *a <= 16)? } else { 0 };
                    (1, Entry::Scope { frame_offset, size, kind: k as u8, align })
                }
                _ => return None,
            }
        };
        if last.is_some_and(|l| order < l || (order == l && order == 0)) {
            return None;
        }
        last = Some(order);
        f(pos, e);
    }
    Some(())
}

#[cfg(feature = "alloc")]
impl InsnList {
    /// Whether the list has no entries.
    pub fn is_empty(&self) -> bool {
        self.targets.is_empty() && self.hints.is_empty() && self.dropped.is_empty() && self.scopes.is_empty()
    }

    /// The stream.
    pub fn write(&self) -> Vec<u8> {
        // (position, kind order, index in its list)
        let mut es: Vec<(u32, u8, usize)> = Vec::new();
        es.extend(self.targets.iter().enumerate().map(|(i, &t)| (t, 0, i)));
        es.extend(self.scopes.iter().enumerate().map(|(i, s)| (s.code_offset, 1, i)));
        es.extend(self.dropped.iter().enumerate().map(|(i, d)| (d.at, 2, i)));
        es.extend(self.hints.iter().enumerate().map(|(i, h)| (h.at, 3, i)));
        es.sort_unstable();
        let mut out = Vec::new();
        let mut pos = 0;
        for (at, k, i) in es {
            let delta = (at - pos) as u64;
            pos = at;
            put(&mut out, delta << 1 | (k != 3) as u64);
            match k {
                0 => put(&mut out, 0),
                1 => {
                    let s = &self.scopes[i];
                    let kind = match s.kind {
                        ScopeKind::Escape { .. } => 2,
                        ScopeKind::End => 3,
                        ScopeKind::Lend => 4,
                    };
                    put(&mut out, kind);
                    put(&mut out, zigzag(s.frame_offset));
                    put(&mut out, s.size as u64);
                    if let ScopeKind::Escape { align } = s.kind {
                        put(&mut out, align as u64);
                    }
                }
                2 => {
                    let (off, size, reg) = self.dropped[i].parts();
                    put(&mut out, 1);
                    put(&mut out, zigzag(off));
                    put(&mut out, ((size.trailing_zeros() as u64) << 4) | reg as u64);
                }
                _ => {
                    let h = self.hints[i];
                    put(&mut out, h.op as u64);
                    put(&mut out, h.sel.wrapping_add(1) as u64);
                }
            }
        }
        out
    }

    /// The list a stream holds, if it is well formed ([`walk`]).
    pub fn read(bytes: &[u8], code_len: u32) -> Option<InsnList> {
        let mut l = InsnList::default();
        let mut ok = true;
        walk(bytes, code_len, |at, e| match e {
            Entry::Insn { op, sel } => l.hints.push(Hint { at, op, sel }),
            Entry::Target => l.targets.push(at),
            Entry::Dropped { frame_offset, size, reg } => match DroppedStore::from_parts(at, frame_offset, size, reg) {
                Some(d) => l.dropped.push(d),
                None => ok = false,
            },
            Entry::Scope { frame_offset, size, kind, align } => {
                let kind = match kind {
                    2 => ScopeKind::Escape { align },
                    3 => ScopeKind::End,
                    _ => ScopeKind::Lend,
                };
                l.scopes.push(Scope { code_offset: at, frame_offset, size, kind });
            }
        })?;
        ok.then_some(l)
    }
}
