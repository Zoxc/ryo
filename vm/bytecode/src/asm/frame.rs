//! Frame slots of reduced code ([`crate::reduced`], as [`super::Decoded`] gives it): which
//! bytes each instruction reads and writes, a liveness pass over frame bytes, and renaming
//! slots to another frame layout ([`SlotMap`], [`remap_slots`]), which the JIT's OSR entries
//! convert between (design/jit.md, "OSR").
//!
//! Extents: inline instructions, calls, `ret` and `arg` access their operands at the widths
//! the opcode or the return kind gives. A handler's slot operands are taken to reach 16
//! bytes (the widest scalar, `w128`), or the length its `len` operands give (`copy`, `const`,
//! `zero`, `load.copy`, `store.copy`, `fill`): an over-estimate, which liveness only reads
//! and never kills. An island's operands have extents only their template knows, and a call
//! may read the stack arguments in the outgoing area, which no operand names: both count as
//! reading every byte.

use alloc::vec::Vec;

use super::{ARG_ADDR, Decoded, Mode, ScopeKind, layout, param_reg, ret_parts};
use crate::full::{self, List, OperandKind, Shape};
use crate::image::Cleanup;
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
    /// An island's operand: an extent only its template knows.
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
                f.next = !matches!(info.shape, Shape::Jmp | Shape::Ret | Shape::TailCall);
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
        Ok(1 + info.operands[..k].iter().map(|o| o.kind.words().ok_or("operand after a list")).sum::<Result<usize, _>>()?)
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
            let mut pos = 1;
            for o in info.operands {
                match o.kind {
                    OperandKind::Slot | OperandKind::Mem => push(pos, accesses.next().ok_or("operand accesses")?),
                    OperandKind::List(_) => return Err("a list operand"),
                    _ => {}
                }
                pos += o.kind.words().expect("fixed");
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
    // The extent of the slot operands: the lengths the opcode gives, else at most 16 bytes.
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
        let access = match (o.kind, o.name) {
            (OperandKind::Mem, _) | (_, "p") => Access::Read(8),
            (_, "d") => Access::Clobber(ext),
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
/// that would straddle an escaped object and moved bytes pins its bytes too. Fails for an
/// address taken of bytes no escape covers, and for a function with islands once that
/// pinning went past the escapes (an island operand's extent isn't known, so its object
/// might be split).
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
    loop {
        let mut changed = false;
        for i in &insns {
            for o in &i.opnds {
                let off = d.words[o.word] as i32;
                let n = match o.access {
                    Access::Read(n) | Access::Write(n) | Access::Clobber(n) => n,
                    Access::Addr | Access::Opaque => 1,
                };
                if o.access == Access::Addr && (-f..0).contains(&(off as i64)) && !pinned.contains(off) {
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
    // An island operand's extent is its template's: an object the pinning above split (a
    // handler's operand taken at 16 bytes reaching an escaped neighbour, say) may be one,
    // and would then be read half moved.
    if pinned != escaped {
        for i in &insns {
            if i.opnds.iter().any(|o| o.access == Access::Opaque && (d.words[o.word] as i32) < 0) {
                return Err(FrameError { at: i.at, what: "an island operand beside split bytes" });
            }
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

    fn all(&mut self) {
        let f = self.frame_size;
        self.set(-(f as i32), f, true);
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

    /// Removes the bytes of `o`.
    fn subtract(&mut self, o: &Bytes) {
        for (a, b) in self.bits.iter_mut().zip(&o.bits) {
            *a &= !b;
        }
    }

    fn union(&mut self, o: &Bytes) -> bool {
        let mut changed = false;
        for (a, b) in self.bits.iter_mut().zip(&o.bits) {
            let n = *a | b;
            changed |= n != *a;
            *a = n;
        }
        changed
    }
}

/// The frame bytes (`-F .. 0`) live at each loop head of `d` ([`Decoded::heads`], in order):
/// those some path from the head may read before writing them, landing pads included. It
/// is conservative: handlers kill nothing, calls and islands read everything, and escaped
/// bytes are only as live as their accesses make them (the caller keeps them in place).
pub fn head_liveness(d: &Decoded, mode: Mode) -> Result<Vec<Bytes>, FrameError> {
    let insns = insns(&d.words, mode)?;
    let index = |w: u32| insns.binary_search_by_key(&w, |i| i.at).ok();
    let n = insns.len();
    let mut succ: Vec<Vec<usize>> = alloc::vec![Vec::new(); n];
    for (k, i) in insns.iter().enumerate() {
        if i.next && k + 1 < n {
            succ[k].push(k + 1);
        }
        for &t in &i.targets {
            succ[k].push(index(t).ok_or(FrameError { at: i.at, what: "a branch target" })?);
        }
    }
    // Unwinding edges: a call site to its landing pad, past nothing it writes.
    let mut pad: Vec<Option<usize>> = alloc::vec![None; n];
    for e in &d.cleanup {
        if let Cleanup::Pad(p, _) = e.action() {
            let at = index(e.offset).ok_or(FrameError { at: e.offset, what: "a cleanup entry" })?;
            pad[at] = Some(index(p).ok_or(FrameError { at: e.offset, what: "a landing pad" })?);
        }
    }
    let f = d.frame_size;
    // The bytes each instruction reads (`gen`) and writes for sure (`kill`).
    let mut gen_ = Vec::with_capacity(n);
    let mut kill = Vec::with_capacity(n);
    for i in &insns {
        let mut g = Bytes::new(f);
        let mut k = Bytes::new(f);
        if i.reads_all {
            g.all();
        }
        for o in &i.opnds {
            let off = d.words[o.word] as i32;
            match o.access {
                Access::Read(n) => g.set(off, n, true),
                Access::Write(n) => k.set(off, n, true),
                Access::Clobber(_) | Access::Addr => {}
                Access::Opaque => g.all(),
            }
        }
        // A byte read and written by the same instruction is read first.
        k.subtract(&g);
        gen_.push(g);
        kill.push(k);
    }
    let mut live_in: Vec<Bytes> = alloc::vec![Bytes::new(f); n];
    let mut changed = true;
    while changed {
        changed = false;
        for k in (0..n).rev() {
            let mut out = Bytes::new(f);
            for &s in &succ[k] {
                out.union(&live_in[s]);
            }
            out.subtract(&kill[k]);
            out.union(&gen_[k]);
            if let Some(p) = pad[k] {
                out.union(&live_in[p]);
            }
            changed |= live_in[k].union(&out);
        }
    }
    d.heads.iter().map(|&h| index(h).map(|i| live_in[i].clone()).ok_or(FrameError { at: h, what: "a loop head" })).collect()
}

/// The moves an OSR entry makes at a head from the AOT layout to `map`'s: the live bytes that
/// `map` moves, as runs `(from, to, len)` of AOT and new offsets.
pub fn osr_moves(live: &Bytes, map: &SlotMap) -> Vec<(i32, i32, u32)> {
    let mut out: Vec<(i32, i32, u32)> = Vec::new();
    let mut off = -(live.frame_size as i64);
    while off < 0 {
        let (d, end) = map.segment(off as i32);
        let end = end.min(0);
        if d != 0 {
            for (o, n) in live.runs(off as i32, (end - off) as u32, true) {
                match out.last_mut() {
                    Some((from, to, len)) if *from + *len as i32 == o && *to - *from == d => *len += n,
                    _ => out.push((o, o + d, n)),
                }
            }
        }
        off = end;
    }
    out
}
