//! Check elimination (design/jit.md, "The SSA pipeline"): a walk of the dominator tree carrying
//! facts from the branch edges that dominate each block, plus value ranges computed from
//! constants, extensions, masks and non-wrapping arithmetic:
//! - an [`Op::Ovf`] that can't overflow becomes a plain [`Op::Bin`], its flag the constant
//!   0, and a [`Term::BrOvf`] on it a jump to its no-overflow edge;
//! - a compare or a compare-branch the facts decide becomes a constant or a jump;
//! - a mask of a frame address's low bits ([`addr_facts`]) becomes a constant;
//! - a distance between a slot no other code can locate and a value not computed from its
//!   address ([`distances`]) is at least the slot's size, so `copy_nonoverlapping`'s
//!   `abs_diff(src, dst) >= n` against it holds.
//!
//! A fact comes from the edge into a block with that one predecessor, which then holds in
//! all the blocks it dominates: every path to them takes that edge, and the values in it are
//! SSA values, unchanged since. A fact at width `w` is about the low `w` bytes. Undefined
//! values never get facts (each read of one may see other bits). Only facts of the form
//! `v in [lo, hi]` (unsigned and signed) and `a < b`, `a <= b` are kept; no induction
//! variables yet (they need OSR-transparent loop facts). Every fold is a proof.

use alloc::vec::Vec;

use crate::asm::Ref;
use crate::jit::ir::*;

/// A value's possible low `w` bytes: unsigned and signed intervals, both holding.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct Range {
    ulo: u64,
    uhi: u64,
    slo: i64,
    shi: i64,
}

fn smax(w: u8) -> i64 {
    (mask(u64::MAX, w) >> 1) as i64
}

impl Range {
    fn full(w: u8) -> Range {
        Range { ulo: 0, uhi: mask(u64::MAX, w), slo: -smax(w) - 1, shi: smax(w) }
    }

    fn konst(c: u64, w: u8) -> Range {
        let c = mask(c, w);
        Range { ulo: c, uhi: c, slo: sext(c, w), shi: sext(c, w) }
    }

    fn unsigned(lo: u64, hi: u64, w: u8) -> Range {
        Range { ulo: lo, uhi: hi, ..Range::full(w) }.tighten(w)
    }

    fn empty(&self) -> bool {
        self.ulo > self.uhi || self.slo > self.shi
    }

    /// Each interval narrowed by what the other says.
    fn tighten(mut self, w: u8) -> Range {
        if self.empty() {
            return self;
        }
        let sm = smax(w) as u64;
        // An unsigned interval on one side of the sign boundary is a signed one.
        if self.uhi <= sm {
            self.slo = self.slo.max(self.ulo as i64);
            self.shi = self.shi.min(self.uhi as i64);
        } else if self.ulo > sm {
            self.slo = self.slo.max(sext(self.ulo, w));
            self.shi = self.shi.min(sext(self.uhi, w));
        }
        if self.empty() {
            return self;
        }
        if self.slo >= 0 {
            self.ulo = self.ulo.max(self.slo as u64);
            self.uhi = self.uhi.min(self.shi as u64);
        } else if self.shi < 0 {
            self.ulo = self.ulo.max(mask(self.slo as u64, w));
            self.uhi = self.uhi.min(mask(self.shi as u64, w));
        }
        self
    }

    fn meet(self, o: Range, w: u8) -> Range {
        Range { ulo: self.ulo.max(o.ulo), uhi: self.uhi.min(o.uhi), slo: self.slo.max(o.slo), shi: self.shi.min(o.shi) }.tighten(w)
    }
}

/// What the walk knows in the current dominator subtree.
#[derive(Clone, Copy, Debug)]
enum Fact {
    /// The low `w` bytes of `v` are in `r` (the latest such fact on `v` at `w` has all the
    /// facts on `v` before it at `w`, and at wider widths that fit in `w` bytes).
    In(Value, u8, Range),
    /// `a < b` (`strict`) or `a <= b` on the low `w` bytes, signed or not.
    Rel { a: Value, b: Value, w: u8, signed: bool, strict: bool },
}

struct Walk {
    facts: Vec<Fact>,
    /// By value: a lower bound on it as a distance from a placement-free slot ([`distances`]),
    /// 0 for none (empty: none at all).
    dist: Vec<u32>,
}

/// How deep [`Walk::range`] looks through definitions.
const DEPTH: u32 = 4;

impl Walk {
    /// What is known of the low `w` bytes of `v`.
    fn range(&self, f: &Func, v: Value, w: u8, depth: u32) -> Range {
        let def = f.def(v);
        let mut r = match def {
            ValueDef::Const(c) => return Range::konst(c, w),
            ValueDef::Undef | ValueDef::Alias(_) => return Range::full(w),
            _ if w > f.w(v) => return Range::full(w),
            _ => Range::full(w),
        };
        // From the facts: at `w`, or at a wider width when the value fits in `w` bytes (its
        // higher bytes are then zero, so the low `w` bytes are the value). The latest at `w`
        // has all before it, but a wider one doesn't have the narrower ones: look past it.
        for fact in self.facts.iter().rev() {
            if let Fact::In(u, fw, fr) = *fact
                && u == v
            {
                if fw == w {
                    r = r.meet(fr, w);
                    break;
                }
                if fw > w && fr.uhi <= mask(u64::MAX, w) {
                    r = r.meet(Range::unsigned(fr.ulo, fr.uhi, w), w);
                }
            }
        }
        if depth == 0 {
            return r;
        }
        let ValueDef::Inst(i, n) = def else { return r };
        // A frame or image address is never null, nor are its low bytes when its known low
        // bits aren't all zero.
        if n == 0
            && let Some(a) = addr_facts(f, v, DEPTH)
            && (a.nonnull && w == 8 || a.bits != 0)
        {
            r = r.meet(Range::unsigned(1, mask(u64::MAX, w), w), w);
        }
        let id = &f.insts[i.idx()];
        let d = match (&id.op, n) {
            (Op::Cmp(..), 0) | (Op::Ovf(..), 1) => Some(Range::unsigned(0, 1, w)),
            (&Op::Ext { from, sx: false, .. }, 0) => {
                let s = self.range(f, id.args[0], from, depth - 1);
                (from <= w).then(|| Range::unsigned(s.ulo, s.uhi, w))
            }
            (&Op::Ext { from, sx: true, .. }, 0) if from <= w => {
                let s = self.range(f, id.args[0], from, depth - 1);
                let r = Range { slo: s.slo, shi: s.shi, ..Range::full(w) }.tighten(w);
                Some(r)
            }
            (&Op::Bin(o, bw), 0) | (&Op::Ovf(o, _, bw), 0) if bw == w => self.bin_range(f, o, w, id.args[0], id.args[1], depth - 1),
            _ => None,
        };
        match d {
            Some(d) if !d.empty() => r.meet(d, w),
            _ => r,
        }
    }

    /// The range of `a op b` at `w` bytes, where it can be told.
    fn bin_range(&self, f: &Func, o: BinOp, w: u8, a: Value, b: Value, depth: u32) -> Option<Range> {
        let all = mask(u64::MAX, w);
        let kb = f.const_at(b, w);
        match o {
            BinOp::And => {
                let (x, y) = (self.range(f, a, w, depth), self.range(f, b, w, depth));
                Some(Range::unsigned(0, x.uhi.min(y.uhi), w))
            }
            BinOp::ShrU => {
                let s = kb?;
                let x = self.range(f, a, w, depth);
                (s < 8 * w as u64).then(|| Range::unsigned(x.ulo >> s, x.uhi >> s, w))
            }
            BinOp::Add | BinOp::Sub | BinOp::Mul => {
                let (x, y) = (self.range(f, a, w, depth), self.range(f, b, w, depth));
                // Empty under contradictory facts (a dead block): nothing to tell.
                if x.empty() || y.empty() {
                    return None;
                }
                let (lo, hi) = match o {
                    BinOp::Add => (x.ulo as u128 + y.ulo as u128, x.uhi as u128 + y.uhi as u128),
                    BinOp::Sub if x.ulo >= y.uhi => ((x.ulo - y.uhi) as u128, (x.uhi - y.ulo) as u128),
                    BinOp::Mul => (x.ulo as u128 * y.ulo as u128, x.uhi as u128 * y.uhi as u128),
                    _ => return None,
                };
                // Exact when nothing wraps.
                (hi <= all as u128).then(|| Range::unsigned(lo as u64, hi as u64, w))
            }
            _ => None,
        }
    }

    /// Whether `a < b` (`strict`) or `a <= b` is known on the low `w` bytes.
    fn rel(&self, a: Value, b: Value, w: u8, signed: bool, strict: bool) -> bool {
        self.has_rel(Some(a), Some(b), w, signed, strict)
    }

    /// [`Self::rel`] with `None` for a side that may be any value.
    fn has_rel(&self, a: Option<Value>, b: Option<Value>, w: u8, signed: bool, strict: bool) -> bool {
        self.facts.iter().any(|fact| match *fact {
            Fact::Rel { a: x, b: y, w: fw, signed: s, strict: st } => {
                a.is_none_or(|a| x == a) && b.is_none_or(|b| y == b) && fw == w && s == signed && (st || !strict)
            }
            _ => false,
        })
    }

    /// Whether `a cc b` at `w` bytes is decided, and how.
    fn decide(&self, f: &Func, cc: Cc, w: u8, a: Value, b: Value) -> Option<bool> {
        if let Some(r) = dist_decide(f, &self.dist, cc, w, a, b) {
            return Some(r);
        }
        if let Some(r) = self.decide_rel(cc, w, a, b) {
            return Some(r);
        }
        let (x, y) = (self.range(f, a, w, DEPTH), self.range(f, b, w, DEPTH));
        if x.empty() || y.empty() {
            return None;
        }
        match cc {
            Cc::Eq | Cc::Ne => {
                let disjoint = x.uhi < y.ulo || y.uhi < x.ulo;
                let same = x.ulo == x.uhi && y.ulo == y.uhi && x.ulo == y.ulo;
                let eq = if disjoint {
                    Some(false)
                } else if same {
                    Some(true)
                } else {
                    None
                };
                eq.map(|e| e == (cc == Cc::Eq))
            }
            Cc::GtU | Cc::GtS | Cc::GeU | Cc::GeS => decide_ranges(cc.swap(), y, x),
            _ => decide_ranges(cc, x, y),
        }
    }

    /// `a cc b` from the relational facts.
    fn decide_rel(&self, cc: Cc, w: u8, a: Value, b: Value) -> Option<bool> {
        let s = cc.signed();
        if let Some((a, b, strict)) = as_lt(cc, a, b) {
            // `a < b` is refuted by `b <= a`, `a <= b` by `b < a`.
            if self.rel(a, b, w, s, strict) {
                Some(true)
            } else if self.rel(b, a, w, s, !strict) {
                Some(false)
            } else {
                None
            }
        } else {
            let ne =
                self.rel(a, b, w, false, true) || self.rel(b, a, w, false, true) || self.rel(a, b, w, true, true) || self.rel(b, a, w, true, true);
            ne.then_some(cc == Cc::Ne)
        }
    }

    /// Whether `a op b` at `w` bytes, signed or not, can't overflow.
    fn no_overflow(&self, f: &Func, o: BinOp, signed: bool, w: u8, a: Value, b: Value) -> bool {
        let one = |v: Value| f.const_at(v, w) == Some(1);
        // Relational: `x + 1` with `x < z`, and `x - y` with `y <= x`.
        match (o, signed) {
            (BinOp::Add, s) if one(b) && self.has_rel(Some(a), None, w, s, true) => return true,
            (BinOp::Add, s) if one(a) && self.has_rel(Some(b), None, w, s, true) => return true,
            (BinOp::Sub, false) if self.rel(b, a, w, false, false) => return true,
            (BinOp::Sub, true) if one(b) && self.has_rel(None, Some(a), w, true, true) => return true,
            _ => {}
        }
        let (x, y) = (self.range(f, a, w, DEPTH), self.range(f, b, w, DEPTH));
        if x.empty() || y.empty() {
            return false;
        }
        if signed {
            let (lo, hi) = (-(smax(w) as i128) - 1, smax(w) as i128);
            let (xl, xh, yl, yh) = (x.slo as i128, x.shi as i128, y.slo as i128, y.shi as i128);
            let (rl, rh) = match o {
                BinOp::Add => (xl + yl, xh + yh),
                BinOp::Sub => (xl - yh, xh - yl),
                BinOp::Mul => {
                    let c = [xl * yl, xl * yh, xh * yl, xh * yh];
                    (*c.iter().min().unwrap(), *c.iter().max().unwrap())
                }
                _ => return false,
            };
            rl >= lo && rh <= hi
        } else {
            let all = mask(u64::MAX, w) as u128;
            match o {
                BinOp::Add => x.uhi as u128 + y.uhi as u128 <= all,
                BinOp::Sub => x.ulo >= y.uhi,
                BinOp::Mul => x.uhi as u128 * y.uhi as u128 <= all,
                _ => false,
            }
        }
    }

    /// Records that `a cc b` holds on the low `w` bytes.
    fn assume(&mut self, f: &Func, cc: Cc, w: u8, a: Value, b: Value) {
        let undef = |v: Value| matches!(f.def(v), ValueDef::Undef | ValueDef::Alias(_));
        if undef(a) || undef(b) {
            return;
        }
        let konst = |v: Value| f.const_at(v, w);
        // Constant on the right.
        let (cc, a, b) = if konst(a).is_some() && konst(b).is_none() { (cc.swap(), b, a) } else { (cc, a, b) };
        if let Some(c) = konst(b) {
            if konst(a).is_some() {
                return;
            }
            let full = Range::full(w);
            let sc = sext(c, w);
            let r = match cc {
                Cc::Eq => Range::konst(c, w),
                Cc::Ne => {
                    let cur = self.range(f, a, w, DEPTH);
                    let mut r = full;
                    if cur.ulo == c && c < full.uhi {
                        r.ulo = c + 1;
                    } else if cur.uhi == c && c > 0 {
                        r.uhi = c - 1;
                    } else {
                        return;
                    }
                    r
                }
                Cc::LtU if c == 0 => return,
                Cc::LtU => Range { uhi: c - 1, ..full },
                Cc::LeU => Range { uhi: c, ..full },
                Cc::GtU if c == full.uhi => return,
                Cc::GtU => Range { ulo: c + 1, ..full },
                Cc::GeU => Range { ulo: c, ..full },
                Cc::LtS if sc == full.slo => return,
                Cc::LtS => Range { shi: sc - 1, ..full },
                Cc::LeS => Range { shi: sc, ..full },
                Cc::GtS if sc == full.shi => return,
                Cc::GtS => Range { slo: sc + 1, ..full },
                Cc::GeS => Range { slo: sc, ..full },
            };
            let r = self.range(f, a, w, DEPTH).meet(r.tighten(w), w);
            self.facts.push(Fact::In(a, w, r));
            return;
        }
        if let Some((a, b, strict)) = as_lt(cc, a, b) {
            self.facts.push(Fact::Rel { a, b, w, signed: cc.signed(), strict });
        }
    }

    /// The facts the edge `k` of `p`'s terminator brings.
    fn edge_facts(&mut self, f: &Func, p: Block, k: u32) {
        let taken = k == 0;
        match f.blocks[p.idx()].term {
            Term::BrCmp { cc, w, a, b, .. } => self.assume(f, if taken { cc } else { cc.negate() }, w, a, b),
            Term::Br { cond, .. } => {
                if let ValueDef::Inst(i, 0) = f.def(cond)
                    && let Op::Cmp(cc, w) = f.insts[i.idx()].op
                {
                    let (a, b) = (f.insts[i.idx()].args[0], f.insts[i.idx()].args[1]);
                    self.assume(f, if taken { cc } else { cc.negate() }, w, a, b);
                }
            }
            _ => {}
        }
    }
}

/// What is known of an address from its provenance.
#[derive(Clone, Copy, Debug)]
pub struct AddrFacts {
    /// Its low `known` bits are `bits`.
    pub known: u32,
    pub bits: u64,
    /// It is never 0.
    pub nonnull: bool,
}

/// The facts on the address `v` (depth: how deep to look through `PtrAdd`/`PtrIndex`):
/// - an [`Op::AllocaAddr`] of a memory or incoming alloca is `fp` plus an offset congruent
///   to the AOT one modulo 16 (`emit::layout` keeps that; pinned and incoming ones keep the
///   offset), and `fp` is 16-aligned (design/vm.md, "Frames": in the JIT frame too, OSR
///   entries don't move it): its low 4 bits are `aot_off + k`'s. In bounds it isn't null
///   (the stack is nowhere near 0);
/// - an [`Op::RefAddr`] of a constant, data area or function (not a slot's value) isn't null;
/// - `p + k` has `p`'s known low bits plus `k`'s; `p + i * s` those of `p` below `s`'s
///   lowest set bit. Neither is non-null (they may wrap).
pub fn addr_facts(f: &Func, v: Value, depth: u32) -> Option<AddrFacts> {
    let i = f.def_inst(v)?;
    let id = &f.insts[i.idx()];
    match id.op {
        Op::AllocaAddr(a, k) => {
            let al = &f.allocas[a.idx()];
            if !matches!(al.kind, AllocaKind::Memory | AllocaKind::Incoming) {
                return None;
            }
            let bits = (al.aot_off as i64 + k as i64) as u64 & 15;
            Some(AddrFacts { known: 4, bits, nonnull: (0..=al.size as i64).contains(&(k as i64)) })
        }
        Op::RefAddr(Ref::Const(_) | Ref::Data(_) | Ref::Func(_), false) => Some(AddrFacts { known: 0, bits: 0, nonnull: true }),
        Op::PtrAdd(k) if depth > 0 => {
            let p = addr_facts(f, id.args[0], depth - 1)?;
            let m = (1u64 << p.known) - 1;
            Some(AddrFacts { known: p.known, bits: p.bits.wrapping_add(k as u64) & m, nonnull: false })
        }
        Op::PtrIndex(s) if depth > 0 => {
            let p = addr_facts(f, id.args[0], depth - 1)?;
            let known = p.known.min(s.trailing_zeros());
            Some(AddrFacts { known, bits: p.bits & ((1u64 << known) - 1), nonnull: false })
        }
        _ => None,
    }
}

/// `a & c` where `c` covers only known low bits of the address `a`: those bits.
fn masked_addr(f: &Func, a: Value, c: Value, w: u8) -> Option<u64> {
    let c = f.const_at(c, w)?;
    let k = addr_facts(f, a, DEPTH)?;
    (k.known < 64 && c >> k.known == 0).then_some(k.bits & c)
}

/// `a cc b` as `a' < b'` (`strict`) or `a' <= b'`: `(a', b', strict)`, `None` for `==`/`!=`.
fn as_lt(cc: Cc, a: Value, b: Value) -> Option<(Value, Value, bool)> {
    match cc {
        Cc::LtU | Cc::LtS => Some((a, b, true)),
        Cc::LeU | Cc::LeS => Some((a, b, false)),
        Cc::GtU | Cc::GtS => Some((b, a, true)),
        Cc::GeU | Cc::GeS => Some((b, a, false)),
        Cc::Eq | Cc::Ne => None,
    }
}

/// `x cc y` for `cc` one of `<` and `<=`, from the ranges, if decided.
fn decide_ranges(cc: Cc, x: Range, y: Range) -> Option<bool> {
    let (yes, no) = match cc {
        Cc::LtS => (x.shi < y.slo, x.slo >= y.shi),
        Cc::LtU => (x.uhi < y.ulo, x.ulo >= y.uhi),
        Cc::LeS => (x.shi <= y.slo, x.slo > y.shi),
        Cc::LeU => (x.uhi <= y.ulo, x.ulo > y.uhi),
        _ => return None,
    };
    if yes {
        Some(true)
    } else if no {
        Some(false)
    } else {
        None
    }
}

/// `a cc b` at `w` bytes decided by a distance bound ([`distances`]): `d >= c` and its
/// variants for a distance `d` with the bound `L` and a constant `c <= L` (`< L` for `>`).
fn dist_decide(f: &Func, dist: &[u32], cc: Cc, w: u8, a: Value, b: Value) -> Option<bool> {
    if w != 8 || dist.is_empty() {
        return None;
    }
    let (cc, d, c) = match (f.const_at(a, 8), f.const_at(b, 8)) {
        (None, Some(c)) => (cc, a, c),
        (Some(c), None) => (cc.swap(), b, c),
        _ => return None,
    };
    let l = dist[d.idx()] as u64;
    match cc {
        _ if l == 0 => None,
        Cc::GeU if c <= l => Some(true),
        Cc::LtU if c <= l => Some(false),
        Cc::GtU if c < l => Some(true),
        Cc::LeU if c < l => Some(false),
        _ => None,
    }
}

/// A read of a value.
#[derive(Clone, Copy)]
enum Use {
    Inst(Inst),
    /// By the block's terminator, not as an edge argument.
    Term(Block),
    /// As argument `j` of edge `k` of the block's terminator.
    Edge(Block, u32, u32),
}

/// What a value in a slot's address set ([`placement_free`]) is.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Taint {
    No,
    /// `AllocaAddr(a, k)`.
    Addr(i32),
    /// A difference or a parameter computed from one.
    Int,
}

/// Distance bounds by value (design/jit.md, "Check elimination"): for each placement-free
/// slot `A` of `size` bytes ([`placement_free`]), `Sub(A + k, x)` and `Sub(x, A + k)` with
/// `x` not computed from `A`'s address are at least `size - k`, and so is a parameter all of
/// whose arguments are. Empty if there are none.
///
/// Why that holds: nothing but these compares observes where `A` is, and they all fold, so
/// the frame may as well have put `A` (it is the abstract machine's choice where a fresh
/// allocation goes) at least `size - k` bytes from every such `x` around the address
/// space; then `A + k - x` and `x - A - k` wrap to no less. A real run agrees whenever `x`
/// is valid for the `c <= size - k` bytes the compare checks and points to another object
/// (a pointer can't reach into `A` without its address): `[x, x + c)` and `[A, A + size)`
/// are disjoint then. So the fold only differs where `x` is invalid for `c` bytes (dangling,
/// one past the end, made up from an integer), and there it picks a placement too.
fn distances(f: &Func, rpo: &[Block]) -> Vec<u32> {
    let mut cand: Vec<bool> = f.allocas.iter().map(|a| a.kind == AllocaKind::Memory && !a.pinned).collect();
    let mut addrs: Vec<(AllocaId, Value)> = Vec::new();
    for &b in rpo {
        for &i in &f.blocks[b.idx()].insts {
            let op = &f.insts[i.idx()].op;
            for a in op.named_allocas() {
                cand[a.idx()] = false;
            }
            if let Op::AllocaAddr(a, _) = *op {
                addrs.push((a, f.result(i)));
            }
        }
    }
    addrs.retain(|&(a, _)| cand[a.idx()]);
    if addrs.is_empty() {
        return Vec::new();
    }
    addrs.sort_unstable_by_key(|&(a, v)| (a.0, v.0));
    // The uses of every value.
    let mut uses: Vec<Vec<Use>> = alloc::vec![Vec::new(); f.values.len()];
    for &b in rpo {
        let bd = &f.blocks[b.idx()];
        for &i in &bd.insts {
            for &a in &f.insts[i.idx()].args {
                uses[a.idx()].push(Use::Inst(i));
            }
        }
        for u in bd.term.uses() {
            uses[u.idx()].push(Use::Term(b));
        }
        for (k, e) in bd.term.edges().enumerate() {
            for (j, &a) in e.args.iter().enumerate() {
                uses[a.idx()].push(Use::Edge(b, k as u32, j as u32));
            }
        }
    }
    let mut dist = alloc::vec![0u32; f.values.len()];
    let mut taint = alloc::vec![Taint::No; f.values.len()];
    for group in addrs.chunk_by(|x, y| x.0 == y.0) {
        let a = group[0].0;
        let set = placement_free(f, &uses, &mut taint, a, group);
        if let Some(set) = &set
            && set.iter().all(|&(v, _)| dist[v.idx()] == 0)
        {
            for &(v, l) in set {
                dist[v.idx()] = l;
            }
        }
    }
    dist
}

/// If nothing observes `a`'s address `addrs` but compares that fold, the distance bounds
/// they rely on ([`distances`]). The address set `T`: the addresses, then the `Sub`s and the
/// parameters reading a member (no other use: no store, call, return, access through it,
/// handler or island operand, which would let other values depend on where `a` is). Its
/// compares (64-bit) must each be decided, by non-null (an address against 0) or by a
/// distance bound against a constant, or be a select diamond: a branch to two blocks only
/// it reaches, holding only `Sub`s of `T`, jumping to one join with the same arguments
/// where they aren't members. Then where `a` is only decides which arm computes a member,
/// and no value outside `T` depends on it.
fn placement_free(f: &Func, uses: &[Vec<Use>], taint: &mut [Taint], a: AllocaId, addrs: &[(AllocaId, Value)]) -> Option<Vec<(Value, u32)>> {
    let size = f.allocas[a.idx()].size;
    let mut set: Vec<Value> = Vec::new();
    for &(_, v) in addrs {
        let Some(&Op::AllocaAddr(_, k)) = f.def_op(v) else { unreachable!() };
        taint[v.idx()] = Taint::Addr(k);
        set.push(v);
    }
    let r = placement_free_in(f, uses, taint, size, &mut set);
    for v in set {
        taint[v.idx()] = Taint::No;
    }
    r
}

fn placement_free_in(f: &Func, uses: &[Vec<Use>], taint: &mut [Taint], size: u32, set: &mut Vec<Value>) -> Option<Vec<(Value, u32)>> {
    // The closure.
    let mut n = 0;
    while n < set.len() {
        let v = set[n];
        n += 1;
        for &u in &uses[v.idx()] {
            let add = match u {
                Use::Inst(i) => match f.insts[i.idx()].op {
                    Op::Bin(BinOp::Sub, 8) => Some(f.result(i)),
                    Op::Cmp(_, 8) => None,
                    Op::Bin(BinOp::And, w @ 1..=8) if matches!(taint[v.idx()], Taint::Addr(_)) => {
                        let [x, y] = f.insts[i.idx()].args2();
                        masked_addr(f, x, y, w).or_else(|| masked_addr(f, y, x, w))?;
                        None
                    }
                    _ => return None,
                },
                Use::Term(b) => match f.blocks[b.idx()].term {
                    Term::BrCmp { w: 8, .. } => None,
                    _ => return None,
                },
                Use::Edge(b, k, j) => {
                    if taint[v.idx()] != Taint::Int {
                        return None;
                    }
                    let to = f.blocks[b.idx()].term.edge(k as usize).to;
                    Some(f.blocks[to.idx()].params[j as usize])
                }
            };
            if let Some(r) = add
                && taint[r.idx()] == Taint::No
            {
                taint[r.idx()] = Taint::Int;
                set.push(r);
            }
        }
    }
    // The bounds: differences with outside values, then parameters, to a fixed point.
    let mut lb: Vec<(Value, u32)> = Vec::new();
    let bound = |lb: &[(Value, u32)], v: Value| lb.iter().find(|x| x.0 == v).map_or(0, |x| x.1);
    for &v in set.iter() {
        if let Some(i) = f.def_inst(v)
            && let Op::Bin(BinOp::Sub, 8) = f.insts[i.idx()].op
        {
            let [x, y] = f.insts[i.idx()].args2();
            let l = match (taint[x.idx()], taint[y.idx()]) {
                (Taint::Addr(k), Taint::No) | (Taint::No, Taint::Addr(k)) if (0..size as i64).contains(&(k as i64)) => size - k as u32,
                _ => 0,
            };
            if l > 0 {
                lb.push((v, l));
            }
        }
    }
    loop {
        let mut changed = false;
        for &v in set.iter() {
            let ValueDef::Param(b, j) = f.def(v) else { continue };
            if bound(&lb, v) > 0 {
                continue;
            }
            let preds = &f.blocks[b.idx()].preds;
            let l = preds.iter().map(|&(p, k)| bound(&lb, f.blocks[p.idx()].term.edge(k as usize).args[j as usize])).min().unwrap_or(0);
            if l > 0 {
                lb.push((v, l));
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }
    // Every compare decided, or a diamond.
    let dist = |v: Value| bound(&lb, v);
    let decided = |cc: Cc, x: Value, y: Value| {
        let k = |v: Value| f.const_at(v, 8);
        let nonnull =
            |p: Value, z: Value| matches!(taint[p.idx()], Taint::Addr(_)) && k(z) == Some(0) && addr_facts(f, p, DEPTH).is_some_and(|a| a.nonnull);
        if matches!(cc, Cc::Eq | Cc::Ne) && (nonnull(x, y) || nonnull(y, x)) {
            return true;
        }
        let (cc, d, c) = match (k(x), k(y)) {
            (None, Some(c)) => (cc, x, c),
            (Some(c), None) => (cc.swap(), y, c),
            _ => return false,
        };
        let l = dist(d) as u64;
        l > 0
            && match cc {
                Cc::GeU | Cc::LtU => c <= l,
                Cc::GtU | Cc::LeU => c < l,
                _ => false,
            }
    };
    let diamond = |p: Block| -> bool {
        let (t, e) = match &f.blocks[p.idx()].term {
            Term::Br { t, f, .. } | Term::BrCmp { t, f, .. } => (t, f),
            _ => return false,
        };
        if t.to == e.to || !t.args.is_empty() || !e.args.is_empty() {
            return false;
        }
        let arm = |s: Block| -> Option<&Edge> {
            let sd = &f.blocks[s.idx()];
            let pure = sd.insts.iter().all(|&i| matches!(f.insts[i.idx()].op, Op::Bin(BinOp::Sub, 8)) && taint[f.result(i).idx()] == Taint::Int);
            match &sd.term {
                Term::Jmp(j) if sd.preds.len() == 1 && sd.params.is_empty() && pure => Some(j),
                _ => None,
            }
        };
        let (Some(x), Some(y)) = (arm(t.to), arm(e.to)) else { return false };
        x.to == y.to && x.args.iter().zip(&y.args).all(|(&u, &v)| u == v || taint[u.idx()] == Taint::Int && taint[v.idx()] == Taint::Int)
    };
    for &v in set.iter() {
        for &u in &uses[v.idx()] {
            let ok = match u {
                Use::Inst(i) => match f.insts[i.idx()].op {
                    Op::Cmp(cc, 8) => {
                        let [x, y] = f.insts[i.idx()].args2();
                        decided(cc, x, y)
                            || uses[f.result(i).idx()]
                                .iter()
                                .all(|&u| matches!(u, Use::Term(b) if matches!(f.blocks[b.idx()].term, Term::Br { .. }) && diamond(b)))
                    }
                    _ => true,
                },
                Use::Term(b) => match f.blocks[b.idx()].term {
                    Term::BrCmp { cc, a: x, b: y, .. } => decided(cc, x, y) || diamond(b),
                    _ => false,
                },
                Use::Edge(..) => true,
            };
            if !ok {
                return None;
            }
        }
    }
    Some(lb)
}

/// Runs check elimination on `f`.
pub fn checks(f: &mut Func) {
    let rpo = f.rpo();
    let idom = f.idoms(&rpo);
    let mut w = Walk { facts: Vec::new(), dist: distances(f, &rpo) };
    let mut changed = false;
    let mut marks: Vec<usize> = Vec::new();
    for e in super::DomWalk::new(&idom, &rpo) {
        let super::Dom::Enter(b) = e else {
            w.facts.truncate(marks.pop().expect("a mark"));
            continue;
        };
        marks.push(w.facts.len());
        let bd = &f.blocks[b.idx()];
        if let [(p, k)] = bd.preds[..]
            && idom[b.idx()] == Some(p)
        {
            w.edge_facts(f, p, k);
        }
        changed |= block(f, &mut w, b);
    }
    if changed {
        f.prune(false);
    }
}

/// Simplifies the checks of `b`; whether a branch became a jump.
fn block(f: &mut Func, w: &mut Walk, b: Block) -> bool {
    for k in 0..f.blocks[b.idx()].insts.len() {
        let i = f.blocks[b.idx()].insts[k];
        let args = f.insts[i.idx()].args2();
        match f.insts[i.idx()].op {
            Op::Ovf(o, signed, ow) if w.no_overflow(f, o, signed, ow, args[0], args[1]) => {
                let flag = Value(f.insts[i.idx()].res + 1);
                f.insts[i.idx()].op = Op::Bin(o, ow);
                f.insts[i.idx()].nres = 1;
                f.values[flag.idx()].def = ValueDef::Const(0);
            }
            Op::Cmp(cc, cw) => {
                if let Some(r) = w.decide(f, cc, cw, args[0], args[1]) {
                    let v = Value(f.insts[i.idx()].res);
                    f.values[v.idx()].def = ValueDef::Const(r as u64);
                }
            }
            Op::Bin(BinOp::And, aw) if aw <= 8 => {
                if let Some(r) = masked_addr(f, args[0], args[1], aw).or_else(|| masked_addr(f, args[1], args[0], aw)) {
                    let v = Value(f.insts[i.idx()].res);
                    f.values[v.idx()].def = ValueDef::Const(r);
                }
            }
            _ => {}
        }
    }
    // Compares and masks made constants leave their blocks.
    let (insts, values) = (&f.insts, &f.values);
    f.blocks[b.idx()].insts.retain(|&i| {
        !(matches!(insts[i.idx()].op, Op::Cmp(..) | Op::Bin(BinOp::And, 1..=8))
            && matches!(values[insts[i.idx()].res as usize].def, ValueDef::Const(_)))
    });
    let k = match &f.blocks[b.idx()].term {
        Term::BrOvf { .. } if !matches!(f.blocks[b.idx()].insts.last().map(|&i| &f.insts[i.idx()].op), Some(Op::Ovf(..))) => Some(1),
        Term::BrCmp { cc, w: cw, a, b: bb, .. } => w.decide(f, *cc, *cw, *a, *bb).map(|r| !r as usize),
        t => t.taken_on(|v, w| f.const_at(v, w)),
    };
    match k {
        Some(k) => {
            f.fold_branch(b, k);
            true
        }
        None => false,
    }
}
