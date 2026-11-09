//! Frame slots of reduced code ([`crate::reduced`], as [`super::Decoded`] gives it): which
//! bytes each instruction reads and writes (the encoder's inline forms use [`Access`]), and
//! renaming slots to another frame layout ([`SlotMap`], [`remap_slots`], [`shuffle_map`]),
//! which the Lean decoder vectors use for code in frames of another size
//! (`tests/lean_reduced_vectors.rs`).
//!
//! Extents: inline instructions, calls, `ret` and `arg` access their operands at the widths
//! the opcode or the return kind gives. A handler's slot operands are taken to reach 16
//! bytes (the widest scalar, `w128`), or the length its `len` operands give if longer
//! (`copy`, `const`, `zero`, `load.copy`, `store.copy`, `fill`): an over-estimate, which liveness only reads
//! and never kills. An island's operands have extents only their template knows, and a call
//! may read the stack arguments in the outgoing area, which no operand names: both count as
//! reading every byte.

use alloc::vec::Vec;

use super::{ARG_ADDR, Decoded, Mode, ScopeKind, layout, param_reg, ret_parts};
use crate::full::{self, List, OperandKind, Shape};
use crate::reduced::{self, Arg};

/// How an instruction uses one of its frame operands.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Access {
    /// Reads `n` bytes from the offset (exactly, or at most for a handler's operand).
    Read(u32),
    /// Writes exactly `n` bytes from the offset.
    Write(u32),
    /// Writes at most `n` bytes from the offset (a handler's operand; liveness doesn't kill).
    Clobber(u32),
    /// Takes the offset's address (`addr`, a call argument passed by address).
    Addr,
    /// An island's operand: an extent its template gives (the island's `Lend` scope records it).
    Opaque,
}

/// A frame operand of an instruction: the word holding its offset (a signed 32-bit value)
/// and how it is used.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FrameOpnd {
    pub word: usize,
    pub access: Access,
}

/// Why reduced code can't be walked or renamed.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FrameError {
    /// Word offset of the instruction.
    pub at: u32,
    pub what: &'static str,
}

/// One reduced instruction's frame effects and control flow.
#[derive(Clone, Debug, Default)]
pub struct InsnFrame {
    /// Word offset and length.
    pub at: u32,
    pub len: u32,
    pub opnds: Vec<FrameOpnd>,
    /// It may read any frame byte (calls, islands).
    pub reads_all: bool,
    /// It falls through to the next instruction.
    pub next: bool,
    /// Branch targets, as word offsets.
    pub targets: Vec<u32>,
    /// The full opcode (a handler's for `handler`).
    pub op: Option<full::Opcode>,
}

/// Every instruction of `code` with its frame operands ([`InsnFrame`]), in order.
pub fn insns(code: &[u32], mode: Mode) -> Result<Vec<InsnFrame>, FrameError> {
    let mut out = Vec::new();
    let mut at = 0usize;
    while at < code.len() {
        let bad = |what| FrameError { at: at as u32, what };
        let (insn, len) = reduced::Insn::decode(&code[at..]).map_err(|_| bad("not a reduced instruction"))?;
        let w = &code[at..at + len];
        let mut f = InsnFrame { at: at as u32, len: len as u32, next: true, ..Default::default() };
        let rel = |t: u32| (at as u32).wrapping_add(t);
        match insn {
            reduced::Insn::Handler { h: reduced::Handler(h), args, t, .. } => {
                f.op = Some(h);
                handler(h, args, at, mode, &mut f).map_err(bad)?;
                f.targets.extend(t.iter().map(|t| rel(t.0 as u32)));
                f.next = matches!(h.info().shape, Shape::Op | Shape::Br | Shape::Lpad);
            }
            _ => {
                let fop = insn.opcode().full().expect("a native instruction");
                f.op = Some(fop);
                native(fop, w, at, &mut f).map_err(bad)?;
                let info = fop.info();
                for (o, ow) in info.operand_words(&w[1..]) {
                    if o.kind == OperandKind::Target {
                        f.targets.push(rel(ow[0]));
                    }
                }
                f.next = !matches!(info.shape, Shape::Jmp | Shape::Ret | Shape::TailCall | Shape::Trap);
                f.reads_all = matches!(info.shape, Shape::Call | Shape::TailCall | Shape::Island);
            }
        }
        out.push(f);
        at += len;
    }
    Ok(out)
}

/// The frame operands of the native instruction `w` (opcode `op`) at word `at`.
fn native(op: full::Opcode, w: &[u32], at: usize, f: &mut InsnFrame) -> Result<(), &'static str> {
    let info = op.info();
    // The word of the operand `name`, which the shape gives.
    let named = |name: &str| -> Result<usize, &'static str> {
        let k = info.operand_index(name).ok_or("operand name")?;
        info.operand_offset(k).ok_or("operand after a list")
    };
    let mut push = |word: usize, access| f.opnds.push(FrameOpnd { word: at + word, access });
    match info.shape {
        Shape::Call | Shape::TailCall => {
            if info.operand_index("p").is_some() {
                push(named("p")?, Access::Read(8));
            }
            if info.shape == Shape::Call {
                let k = w[named("k")?];
                if k != 0 {
                    // The result's stores: an exact write of the parts if they are
                    // contiguous, else a clobber of their whole extent (so that a layout moves
                    // it as one; the call reads every byte anyway).
                    let access = match ret_parts(k, false).ok_or("return kind")? {
                        [Some(a), Some(b)] if b.off == a.size => Access::Write(a.size + b.size),
                        [Some(_), Some(b)] => Access::Clobber(b.off + b.size),
                        [Some(a), None] => Access::Write(a.size),
                        _ => Access::Write(0),
                    };
                    push(named("d")?, access);
                }
            }
            let a = named("a")?;
            // A count of words, then (slot, register) pairs.
            let cnt = w[a] as usize / 2;
            for i in 0..cnt {
                let (s, r) = (a + 1 + 2 * i, w[a + 2 + 2 * i]);
                let reg = param_reg(r).ok_or("argument register")?;
                push(s, if r & ARG_ADDR != 0 { Access::Addr } else { Access::Read(reg.size) });
            }
        }
        Shape::Ret => {
            let k = w[named("k")?];
            if k != 0 {
                let parts = ret_parts(k, true).ok_or("return kind")?;
                let hi = parts.into_iter().flatten().map(|p| p.off + p.size).max().unwrap_or(0);
                push(named("s")?, Access::Read(hi));
            }
        }
        Shape::Arg => {
            let reg = super::ArgReg::of(w[named("r")?], true).ok_or("argument register")?;
            push(named("d")?, Access::Write(reg.size));
        }
        Shape::Island => {
            let o = named("ops")?;
            for i in 0..w[o] as usize {
                push(o + 1 + i, Access::Opaque);
            }
        }
        _ => {
            // Inline instructions (and `jmp`, `unreachable`, which have no slots).
            let mut accesses = super::inline::frame_access(op).unwrap_or_default().into_iter();
            for (k, o) in info.operands.iter().enumerate() {
                match o.kind {
                    OperandKind::Slot | OperandKind::Mem => {
                        // No list before it: the arm below returns at the first one.
                        push(info.operand_offset(k).expect("fixed"), accesses.next().ok_or("operand accesses")?)
                    }
                    OperandKind::List(_) => return Err("a list operand"),
                    _ => {}
                }
            }
            if accesses.next().is_some() {
                return Err("operand accesses");
            }
        }
    }
    Ok(())
}

/// The frame operands of the reduced `handler` of the handler `h` with arguments `args` at
/// word `at`: its slot operands' register values, by `h`'s layout.
fn handler(h: full::Opcode, args: List<Arg>, at: usize, mode: Mode, f: &mut InsnFrame) -> Result<(), &'static str> {
    let l = layout(h, mode);
    let info = h.info();
    if args.len() != l.regs as usize {
        return Err("handler arguments");
    }
    let arg = |reg: u8| args.get(reg as usize).expect("as many as registers");
    let imm = |k: usize| -> Result<u64, &'static str> {
        let loc = l.locs[k];
        match arg(loc.reg) {
            Arg::Imm(v) => Ok(loc.field(v)),
            _ => Err("handler argument"),
        }
    };
    let index = |name: &str| info.operand_index(name);
    // The extent of the slot operands: 16 bytes, or the lengths the opcode gives if longer.
    let mut ext = 16u64;
    if let Some(k) = index("len") {
        ext = ext.max(imm(k)?);
    }
    if let (Some(e), Some(c)) = (index("elem_size"), index("count")) {
        ext = ext.max(imm(e)?.saturating_mul(imm(c)?));
    }
    // Past the frame either way.
    let ext = u32::try_from(ext).unwrap_or(u32::MAX);
    for (k, o) in info.operands.iter().enumerate() {
        let loc = l.locs[k];
        if loc.count == 0 || !matches!(o.kind, OperandKind::Slot | OperandKind::Mem) {
            continue;
        }
        if !matches!(arg(loc.reg), Arg::Imm(_)) {
            return Err("a slot operand that isn't an immediate");
        }
        // A slot is the argument value's low half, or its high one in a shared register.
        let word = at + reduced::handler_arg_value_word(loc.reg as usize, loc.half());
        // Pointers and lengths are 8 bytes; `d`, `o` (the overflow and exchange flags) and
        // `lpad`'s `x` are the outputs.
        let access = match (o.kind, o.name) {
            (OperandKind::Mem, _) | (_, "p" | "dp" | "sp" | "n") => Access::Read(8),
            (_, "d" | "o") => Access::Clobber(ext),
            (_, "x") if info.shape == Shape::Lpad => Access::Clobber(ext),
            _ => Access::Read(ext),
        };
        f.opnds.push(FrameOpnd { word, access });
    }
    Ok(())
}

/// Where the slots of a function's frame go in another layout: AOT frame offsets to the new
/// ones, byte by byte, as translations of ranges. Offsets in no range (the incoming
/// arguments, the return address, and whatever stays) keep their offset. The map is
/// injective, so a parallel move between the layouts never overwrites a byte it still reads.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SlotMap {
    /// The new frame size.
    pub frame_size: u32,
    /// Disjoint ranges of old offsets `lo .. lo + len`, sorted, each moved by `delta`.
    pub ranges: Vec<(i32, u32, i32)>,
}

impl SlotMap {
    /// Every slot where it was, in a frame of `frame_size`.
    pub fn identity(frame_size: u32) -> SlotMap {
        SlotMap { frame_size, ranges: Vec::new() }
    }

    /// Whether the map moves nothing (the frame size aside).
    pub fn is_identity(&self) -> bool {
        self.ranges.iter().all(|r| r.2 == 0)
    }

    /// How far the byte at `off` moves.
    pub fn delta(&self, off: i32) -> i32 {
        self.segment(off).0
    }

    /// How far the byte at `off` moves, and the end of the bytes from `off` that move with it
    /// (as far as the range or gap holding `off` reaches).
    fn segment(&self, off: i32) -> (i32, i64) {
        let i = self.ranges.partition_point(|r| r.0 <= off);
        match i.checked_sub(1).map(|i| self.ranges[i]) {
            Some((lo, len, d)) if (off as i64) < lo as i64 + len as i64 => (d, lo as i64 + len as i64),
            _ => (0, self.ranges.get(i).map_or(i64::MAX, |r| r.0 as i64)),
        }
    }

    pub fn map(&self, off: i32) -> i32 {
        off.wrapping_add(self.delta(off))
    }

    /// Where the bytes `off .. off + len` go, if they move together.
    pub fn map_range(&self, off: i32, len: u32) -> Option<i32> {
        let (d, mut o) = self.segment(off);
        let end = off as i64 + len as i64;
        while o < end {
            let (e, next) = self.segment(o as i32);
            if e != d {
                return None;
            }
            o = next;
        }
        Some(off.wrapping_add(d))
    }
}

/// `code` (reduced) with every frame operand renamed by `map`: the slots and memory pointers
/// of native instructions, call argument lists, island operands and the slot operands among
/// handler arguments. Word positions don't change, so targets, cleanup entries, dropped
/// stores and loop heads stay valid. Extents aren't checked: the map must move every access
/// as a whole ([`shuffle_map`] makes sure).
pub fn remap_slots(code: &[u32], mode: Mode, map: &SlotMap) -> Result<Vec<u32>, FrameError> {
    let mut out = code.to_vec();
    for i in insns(code, mode)? {
        for o in &i.opnds {
            out[o.word] = map.map(code[o.word] as i32) as u32;
        }
    }
    Ok(out)
}

/// A test layout (`RYO_JIT_SHUFFLE`): every frame byte below `fp` that is never escaped moves
/// down by `F + 64`, into a frame of `2F + 64`, and the escaped objects stay (as they must:
/// pointers to them may be anywhere). So the moved bytes land below every old one, the
/// outgoing area is at `rsp` again, and accesses keep their relative positions. An access
/// that would straddle an escaped object and moved bytes pins its bytes too; an island
/// operand's access is its `Lend` scope's extent. Fails for an address taken of bytes no
/// escape covers, and for an island operand without a `Lend` scope.
pub fn shuffle_map(d: &Decoded, mode: Mode) -> Result<SlotMap, FrameError> {
    let f = d.frame_size as i64;
    let insns = insns(&d.words, mode)?;
    let mut pinned = Bytes::new(d.frame_size);
    for sc in &d.scopes {
        if let ScopeKind::Escape { .. } = sc.kind {
            pinned.set(sc.frame_offset, sc.size, true);
        }
    }
    let escaped = pinned.clone();
    // An island operand's extent is its `Lend` scope's (the operand array has offsets only).
    let lends: Vec<(i32, u32)> = d.scopes.iter().filter(|sc| sc.kind == ScopeKind::Lend).map(|sc| (sc.frame_offset, sc.size)).collect();
    for i in &insns {
        for o in &i.opnds {
            let off = d.words[o.word] as i32;
            if o.access == Access::Opaque && off < 0 && !lends.iter().any(|l| l.0 == off) {
                return Err(FrameError { at: i.at, what: "an island operand without an extent" });
            }
        }
    }
    loop {
        let mut changed = false;
        for &(off, n) in &lends {
            if pinned.any_in(off, n) && !pinned.all_in(off, n) {
                pinned.set(off, n, true);
                changed = true;
            }
        }
        for i in &insns {
            for o in &i.opnds {
                let off = d.words[o.word] as i32;
                let n = match o.access {
                    Access::Read(n) | Access::Write(n) | Access::Clobber(n) => n,
                    Access::Addr | Access::Opaque => 1,
                };
                if o.access == Access::Addr && (-f..0).contains(&(off as i64)) && !escaped.contains(off) {
                    return Err(FrameError { at: i.at, what: "an address of bytes that don't escape" });
                }
                if pinned.any_in(off, n) && !pinned.all_in(off, n) {
                    pinned.set(off, n, true);
                    changed = true;
                }
            }
        }
        if !changed {
            break;
        }
    }
    let delta = -(f as i32 + 64);
    let ranges = pinned.runs(-(f as i32), f as u32, false).map(|(lo, len)| (lo, len, delta)).collect();
    Ok(SlotMap { frame_size: 2 * d.frame_size + 64, ranges })
}

/// A set of frame bytes `-F .. 0`, bit `F + off`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Bytes {
    pub frame_size: u32,
    bits: Vec<u64>,
}

impl Bytes {
    fn new(frame_size: u32) -> Bytes {
        Bytes { frame_size, bits: alloc::vec![0; (frame_size as usize).div_ceil(64)] }
    }

    fn range(&self, off: i32, n: u32) -> core::ops::Range<usize> {
        let f = self.frame_size as i64;
        let lo = (off as i64).clamp(-f, 0) + f;
        let hi = (off as i64 + n as i64).clamp(-f, 0) + f;
        lo as usize..hi.max(lo) as usize
    }

    fn set(&mut self, off: i32, n: u32, v: bool) {
        for b in self.range(off, n) {
            if v {
                self.bits[b / 64] |= 1 << (b % 64);
            } else {
                self.bits[b / 64] &= !(1 << (b % 64));
            }
        }
    }

    fn get(&self, b: usize) -> bool {
        self.bits[b / 64] >> (b % 64) & 1 != 0
    }

    /// Whether the byte at `off` is in the set.
    pub fn contains(&self, off: i32) -> bool {
        self.range(off, 1).any(|b| self.get(b))
    }

    /// Whether any of the bytes `off .. off + n` in the frame is in the set.
    fn any_in(&self, off: i32, n: u32) -> bool {
        self.range(off, n).any(|b| self.get(b))
    }

    /// Whether all of the bytes `off .. off + n` in the frame are in the set.
    fn all_in(&self, off: i32, n: u32) -> bool {
        self.range(off, n).all(|b| self.get(b))
    }

    /// The maximal runs `(off, len)` of bytes in `off .. off + n` (in the frame) whose
    /// membership is `v`.
    fn runs(&self, off: i32, n: u32, v: bool) -> impl Iterator<Item = (i32, u32)> + '_ {
        let f = self.frame_size as i64;
        let r = self.range(off, n);
        let mut b = r.start;
        core::iter::from_fn(move || {
            while b < r.end && self.get(b) != v {
                b += 1;
            }
            let lo = b;
            while b < r.end && self.get(b) == v {
                b += 1;
            }
            (b > lo).then(|| ((lo as i64 - f) as i32, (b - lo) as u32))
        })
    }
}
