//! Check elimination (design/jit.md, "The SSA pipeline"): a walk of the dominator tree carrying
//! facts from the branch edges that dominate each block, plus value ranges computed from
//! constants, extensions, masks and non-wrapping arithmetic:
//! - an [`Op::Ovf`] that can't overflow becomes a plain [`Op::Bin`], its flag the constant
//!   0, and a [`Term::BrOvf`] on it a jump to its no-overflow edge;
//! - a compare or a compare-branch the facts decide becomes a constant or a jump.
//!
//! A fact comes from the edge into a block with that one predecessor, which then holds in
//! all the blocks it dominates: every path to them takes that edge, and the values in it are
//! SSA values, unchanged since. A fact at width `w` is about the low `w` bytes. Undefined
//! values never get facts (each read of one may see other bits). Only facts of the form
//! `v in [lo, hi]` (unsigned and signed) and `a < b`, `a <= b` are kept; no induction
//! variables yet (they need OSR-transparent loop facts). Every fold is a proof.

use alloc::vec::Vec;

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
    /// The low `w` bytes of `v` are in `r` (the latest such fact on `v` at `w` has all).
    In(Value, u8, Range),
    /// `a < b` (`strict`) or `a <= b` on the low `w` bytes, signed or not.
    Rel { a: Value, b: Value, w: u8, signed: bool, strict: bool },
}

struct Walk {
    facts: Vec<Fact>,
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
        // higher bytes are then zero, so the low `w` bytes are the value).
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
                    break;
                }
            }
        }
        if depth == 0 {
            return r;
        }
        let ValueDef::Inst(i, n) = def else { return r };
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
    fn edge_facts(&mut self, f: &Func, p: Block, k: u16) {
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

/// Runs check elimination on `f`.
pub fn checks(f: &mut Func) {
    let rpo = f.rpo();
    let idom = f.idoms(&rpo);
    let mut w = Walk { facts: Vec::new() };
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
            _ => {}
        }
    }
    // Compares made constants leave their blocks.
    let (insts, values) = (&f.insts, &f.values);
    f.blocks[b.idx()]
        .insts
        .retain(|&i| !(matches!(insts[i.idx()].op, Op::Cmp(..)) && matches!(values[insts[i.idx()].res as usize].def, ValueDef::Const(_))));
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
