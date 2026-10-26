//! The global simplifications (design/jit.md, "The SSA tier"), after local value numbering
//! ([`super::lvn`]) and before the folds ([`super::fold`]):
//! - **sparse conditional constant propagation** (Wegman and Zadeck) over the block
//!   parameters, with executable edges: values proven constant become constants, branches
//!   and switches on them become jumps, and the blocks no longer reachable go. Edges from OSR
//!   entries don't count for a head's parameters (design/jit.md, "OSR-transparent
//!   constants");
//! - the algebraic identities of [`super::lvn`], again, on what the constants reach;
//! - **parameter aliasing**: a parameter whose arguments are all one value (or itself) is
//!   that value; at a head with an OSR entry, a parameter equal to another on every normal
//!   edge is that one ([`super::osr`]);
//! - **block merging**: a block that only jumps to a block with no other predecessor takes
//!   that block's instructions and terminator.
//!
//! Iterated while the identities find new constants, at most [`MAX_ROUNDS`] times. Dead code
//! is left to [`super::dce`].

use alloc::vec::Vec;

use super::lvn::{Simp, eval_bin, simplify as simplify_inst};
use super::osr::{osr_edge, same_params};
use crate::jit::ir::*;

/// At most this many rounds of propagation, to keep compile time bounded.
const MAX_ROUNDS: usize = 3;

/// Runs the simplifications on `f`.
pub fn simplify(f: &mut Func) {
    for _ in 0..MAX_ROUNDS {
        let again = sccp(f);
        alias_params(f);
        merge_blocks(f);
        if !again {
            break;
        }
    }
}

/// What propagation knows of a value: nothing yet (it may still be anything, or never be
/// defined), its low bytes (masked to its width), or that it varies.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Lat {
    Top,
    C(u64),
    Bot,
}

fn meet(a: Lat, b: Lat) -> Lat {
    match (a, b) {
        (Lat::Top, x) | (x, Lat::Top) => x,
        (Lat::C(x), Lat::C(y)) if x == y => a,
        _ => Lat::Bot,
    }
}

/// The number of edges of `t` ([`Term::edges`], without allocating).
fn n_edges(t: &Term) -> usize {
    match t {
        Term::None | Term::Ret { .. } | Term::TailCall { .. } | Term::Trap => 0,
        Term::Jmp(_) => 1,
        Term::Br { .. } | Term::BrCmp { .. } | Term::BrOvf { .. } => 2,
        Term::Switch { targets, .. } => targets.len(),
        Term::Invoke { normal, .. } => 1 + normal.is_some() as usize,
    }
}

/// Edge `k` of `t` ([`Term::edges`], without allocating).
fn edge_at(t: &Term, k: usize) -> &Edge {
    match t {
        Term::Jmp(e) => e,
        Term::Br { t, f, .. } | Term::BrCmp { t, f, .. } | Term::BrOvf { t, f } => {
            if k == 0 {
                t
            } else {
                f
            }
        }
        Term::Switch { targets, .. } => &targets[k],
        Term::Invoke { normal: Some(e), .. } if k == 0 => e,
        Term::Invoke { pad, .. } => pad,
        _ => unreachable!("no edge {k}"),
    }
}

/// `a op b` at `w` bytes, signed or not, and whether it overflowed ([`Op::Ovf`]).
fn eval_ovf(op: BinOp, signed: bool, w: u8, a: u64, b: u64) -> (u64, bool) {
    let bits = 8 * w as u32;
    if signed {
        let (x, y) = (sext(a, w) as i128, sext(b, w) as i128);
        let r = match op {
            BinOp::Add => x + y,
            BinOp::Sub => x - y,
            _ => x * y,
        };
        let lim = 1i128 << (bits - 1);
        (mask(r as u64, w), r < -lim || r >= lim)
    } else {
        let (x, y) = (mask(a, w) as u128, mask(b, w) as u128);
        let (r, under) = match op {
            BinOp::Add => (x + y, false),
            BinOp::Sub => (x.wrapping_sub(y), x < y),
            _ => (x * y, false),
        };
        (mask(r as u64, w), under || r > mask(u64::MAX, w) as u128)
    }
}

/// The propagation's state.
struct Sccp {
    lat: Vec<Lat>,
    exec: Vec<bool>,
    /// Where each block's edges start in `edge`.
    base: Vec<usize>,
    edge: Vec<bool>,
    changed: bool,
    /// Heads found, at a fixpoint, to be reached only by their OSR edges: their OSR edges
    /// count (until then their parameters stay unknown, as a normal edge may still come).
    osr_only: Vec<bool>,
}

impl Sccp {
    fn set(&mut self, v: Value, l: Lat) {
        let n = meet(self.lat[v.idx()], l);
        if n != self.lat[v.idx()] {
            self.lat[v.idx()] = n;
            self.changed = true;
        }
    }

    /// The edge `k` of `b`, to `to`, is executable.
    fn mark(&mut self, b: usize, k: usize, to: Block) {
        if !self.edge[self.base[b] + k] {
            self.edge[self.base[b] + k] = true;
            self.exec[to.idx()] = true;
            self.changed = true;
        }
    }

    /// The low bytes `l` stands for, read at `w` bytes.
    fn at(&self, v: Value, w: u8) -> Lat {
        match self.lat[v.idx()] {
            Lat::C(c) => Lat::C(mask(c, w)),
            l => l,
        }
    }

    /// Evaluates instruction `i` on what is known of its operands.
    fn eval(&mut self, f: &Func, i: Inst) {
        let id = &f.insts[i.idx()];
        let r = Value(id.res);
        let arg = |n: usize, w: u8| self.at(id.args[n], w);
        let same = || id.args.len() == 2 && id.args[0] == id.args[1] && !matches!(f.def(id.args[0]), ValueDef::Undef);
        let l = match id.op {
            Op::Bin(o, w) => {
                let (x, y) = (arg(0, w), arg(1, w));
                let all = mask(u64::MAX, w);
                let zero = |l: Lat| l == Lat::C(0);
                match (x, y) {
                    (Lat::C(x), Lat::C(y)) => Lat::C(eval_bin(o, w, x, y)),
                    _ if matches!(o, BinOp::Mul | BinOp::And) && (zero(x) || zero(y)) => Lat::C(0),
                    _ if o == BinOp::Or && (x == Lat::C(all) || y == Lat::C(all)) => Lat::C(all),
                    _ if matches!(o, BinOp::Sub | BinOp::Xor) && same() => Lat::C(0),
                    (Lat::Top, _) | (_, Lat::Top) => Lat::Top,
                    _ => Lat::Bot,
                }
            }
            Op::Cmp(cc, w) => match (arg(0, w), arg(1, w)) {
                (Lat::C(x), Lat::C(y)) => Lat::C(cc.holds(w, x, y) as u64),
                _ if same() => Lat::C(matches!(cc, Cc::Eq | Cc::LeS | Cc::LeU | Cc::GeS | Cc::GeU) as u64),
                (Lat::Top, _) | (_, Lat::Top) => Lat::Top,
                _ => Lat::Bot,
            },
            Op::Ovf(o, signed, w) => {
                let (x, y) = (arg(0, w), arg(1, w));
                let (lr, lf) = match (x, y) {
                    (Lat::C(x), Lat::C(y)) => {
                        let (v, o) = eval_ovf(o, signed, w, x, y);
                        (Lat::C(v), Lat::C(o as u64))
                    }
                    (Lat::Top, _) | (_, Lat::Top) => (Lat::Top, Lat::Top),
                    _ => (Lat::Bot, Lat::Bot),
                };
                self.set(r, lr);
                self.set(Value(id.res + 1), lf);
                return;
            }
            Op::Ext { from, to, sx } => match arg(0, from) {
                Lat::C(x) => Lat::C(mask(if sx { sext(x, from) as u64 } else { x }, to)),
                l => l,
            },
            Op::PtrAdd(k) => match arg(0, 8) {
                Lat::C(x) => Lat::C(x.wrapping_add(k as u64)),
                l => l,
            },
            Op::PtrIndex(s) => match (arg(0, 8), arg(1, 8)) {
                (Lat::C(p), Lat::C(x)) => Lat::C(p.wrapping_add(x.wrapping_mul(s as u64))),
                (Lat::Top, _) | (_, Lat::Top) => Lat::Top,
                _ => Lat::Bot,
            },
            _ => {
                for r in id.results() {
                    self.set(r, Lat::Bot);
                }
                return;
            }
        };
        let l = match l {
            Lat::C(c) => Lat::C(mask(c, f.w(r))),
            l => l,
        };
        self.set(r, l);
    }

    /// The edge `b`'s terminator takes, if propagation knows it is exactly one.
    fn taken(&self, f: &Func, b: usize) -> Option<usize> {
        let bd = &f.blocks[b];
        match &bd.term {
            Term::Br { cond, .. } => match self.at(*cond, 1) {
                Lat::C(c) => Some((c == 0) as usize),
                _ => None,
            },
            Term::BrCmp { cc, w, a, b, .. } => match (self.at(*a, *w), self.at(*b, *w)) {
                (Lat::C(x), Lat::C(y)) => Some(!cc.holds(*w, x, y) as usize),
                _ => None,
            },
            Term::BrOvf { .. } => {
                let i = *bd.insts.last()?;
                match self.at(Value(f.insts[i.idx()].res + 1), 1) {
                    Lat::C(c) => Some((c == 0) as usize),
                    _ => None,
                }
            }
            Term::Switch { idx, targets } => match self.lat[idx.idx()] {
                Lat::C(c) if (c as usize as u64) == c && (c as usize) < targets.len() => Some(c as usize),
                _ => None,
            },
            _ => None,
        }
    }

    /// Whether the condition of `b`'s terminator is still unknown (no edge is executable yet).
    fn undecided(&self, f: &Func, b: usize) -> bool {
        let bd = &f.blocks[b];
        let top = |v: Value| self.lat[v.idx()] == Lat::Top;
        match &bd.term {
            Term::Br { cond, .. } => top(*cond),
            Term::BrCmp { a, b, .. } => top(*a) || top(*b),
            Term::BrOvf { .. } => bd.insts.last().is_some_and(|i| top(Value(f.insts[i.idx()].res + 1))),
            Term::Switch { idx, .. } => top(*idx),
            _ => false,
        }
    }

    fn visit(&mut self, f: &Func, b: usize) {
        let bd = &f.blocks[b];
        match bd.kind {
            BlockKind::Entry | BlockKind::Osr(_) => {
                for &p in &bd.params {
                    self.set(p, Lat::Bot);
                }
            }
            _ => {
                for (n, &p) in bd.params.iter().enumerate() {
                    // The OSR edges don't count, unless they are all there is.
                    let (mut l, mut normal, mut osr) = (Lat::Top, false, false);
                    for &(pb, k) in &bd.preds {
                        if !self.edge[self.base[pb.idx()] + k as usize] {
                            continue;
                        }
                        if osr_edge(f, pb) {
                            osr = true;
                            continue;
                        }
                        normal = true;
                        let a = edge_at(&f.blocks[pb.idx()].term, k as usize).args[n];
                        l = meet(l, self.at(a, f.w(p)));
                    }
                    if osr && !normal && self.osr_only[b] {
                        l = Lat::Bot;
                    }
                    self.set(p, l);
                }
            }
        }
        for &i in &bd.insts {
            self.eval(f, i);
        }
        match self.taken(f, b) {
            Some(k) => self.mark(b, k, edge_at(&bd.term, k).to),
            None if self.undecided(f, b) => {}
            None => {
                for k in 0..n_edges(&bd.term) {
                    self.mark(b, k, edge_at(&bd.term, k).to);
                }
            }
        }
    }
}

/// Propagates constants, rewrites what they decide and prunes the blocks no longer reached.
/// Whether the identities found new constants (another round may find more).
fn sccp(f: &mut Func) -> bool {
    let n = f.blocks.len();
    let mut base = Vec::with_capacity(n + 1);
    let mut ne = 0;
    for bd in &f.blocks {
        base.push(ne);
        ne += n_edges(&bd.term);
    }
    let lat = f
        .values
        .iter()
        .map(|v| match v.def {
            ValueDef::Const(c) => Lat::C(mask(c, v.w)),
            ValueDef::Undef => Lat::Bot,
            _ => Lat::Top,
        })
        .collect();
    let exec = f.blocks.iter().map(|b| matches!(b.kind, BlockKind::Entry | BlockKind::Osr(_))).collect();
    let mut s = Sccp { lat, exec, base, edge: alloc::vec![false; ne], changed: true, osr_only: alloc::vec![false; n] };
    let rpo = f.rpo();
    while s.changed {
        s.changed = false;
        for &b in &rpo {
            if s.exec[b.idx()] {
                s.visit(f, b.idx());
            }
        }
        if !s.changed {
            for &b in &rpo {
                let bd = &f.blocks[b.idx()];
                if !s.exec[b.idx()] || s.osr_only[b.idx()] || bd.params.is_empty() || matches!(bd.kind, BlockKind::Entry | BlockKind::Osr(_)) {
                    continue;
                }
                let normal = bd.preds.iter().any(|&(p, k)| s.edge[s.base[p.idx()] + k as usize] && !osr_edge(f, p));
                if !normal {
                    s.osr_only[b.idx()] = true;
                    s.changed = true;
                }
            }
        }
    }

    // Constants for the values proven constant.
    let mut found = false;
    for &b in &rpo {
        if !s.exec[b.idx()] {
            continue;
        }
        let bd = &f.blocks[b.idx()];
        let defs: Vec<Value> = bd
            .params
            .iter()
            .copied()
            .chain(bd.insts.iter().filter(|i| f.insts[i.idx()].op.pure()).flat_map(|i| f.insts[i.idx()].results()))
            .collect();
        for v in defs {
            if let Lat::C(c) = s.lat[v.idx()]
                && !matches!(f.def(v), ValueDef::Alias(_))
            {
                let w = f.w(v);
                let k = f.konst(mask(c, w), w);
                f.values[v.idx()].def = ValueDef::Alias(k);
                found = true;
            }
        }
    }
    // The branches they decide.
    let mut folded = false;
    for &b in &rpo {
        if !s.exec[b.idx()] || matches!(f.blocks[b.idx()].term, Term::Jmp(_)) {
            continue;
        }
        if let Some(k) = s.taken(f, b.idx()) {
            let e = edge_at(&f.blocks[b.idx()].term, k).clone();
            super::fold::set_term(f, b.idx(), Term::Jmp(e));
            folded = true;
        }
    }
    if !found && !folded {
        return false;
    }
    // The identities, on what the constants reach.
    let mut again = false;
    if found {
        for &b in &rpo {
            if !s.exec[b.idx()] {
                continue;
            }
            let insts = core::mem::take(&mut f.blocks[b.idx()].insts);
            let mut kept = Vec::with_capacity(insts.len());
            for i in insts {
                for k in 0..f.insts[i.idx()].args.len() {
                    f.insts[i.idx()].args[k] = f.resolve(f.insts[i.idx()].args[k]);
                }
                let res = Value(f.insts[i.idx()].res);
                if f.insts[i.idx()].op.pure() && !matches!(f.def(res), ValueDef::Alias(_)) {
                    match simplify_inst(f, i) {
                        Simp::Value(v) => {
                            f.values[res.idx()].def = ValueDef::Alias(v);
                            continue;
                        }
                        Simp::Const(c) => {
                            let w = f.w(res);
                            let k = f.konst(mask(c, w), w);
                            f.values[res.idx()].def = ValueDef::Alias(k);
                            again = true;
                            continue;
                        }
                        Simp::Keep => {}
                    }
                }
                kept.push(i);
            }
            f.blocks[b.idx()].insts = kept;
        }
    }
    f.resolve_aliases();
    if folded {
        f.prune(false);
    }
    again
}

/// Replaces each block parameter whose arguments are all one value, but for the parameter
/// itself, by that value: the value then dominates every predecessor, so the block too. Not
/// at heads with an OSR entry: there, a parameter equal to an earlier one on every normal
/// edge ([`same_params`]) is that one instead, OSR-transparently. Whether any was.
fn alias_params(f: &mut Func) -> bool {
    let mut any = false;
    let mut changed = true;
    while changed {
        changed = false;
        for b in 0..f.blocks.len() {
            let bd = &f.blocks[b];
            if bd.kind == BlockKind::Entry || bd.preds.is_empty() {
                continue;
            }
            // A head's OSR entry sets its parameters from the AOT frame, and nothing else
            // may stand for them there (the entry's loads have no locations of their own),
            // but another of its parameters.
            if bd.preds.iter().any(|&(p, _)| osr_edge(f, p)) {
                let blk = Block(b as u32);
                for m in 1..f.blocks[b].params.len() {
                    let pm = f.blocks[b].params[m];
                    if matches!(f.def(pm), ValueDef::Alias(_)) {
                        continue;
                    }
                    let n = (0..m).find(|&n| !matches!(f.def(f.blocks[b].params[n]), ValueDef::Alias(_)) && same_params(f, blk, n, m));
                    if let Some(n) = n {
                        f.values[pm.idx()].def = ValueDef::Alias(f.blocks[b].params[n]);
                        changed = true;
                        any = true;
                    }
                }
                continue;
            }
            for (n, &p) in bd.params.iter().enumerate() {
                if matches!(f.def(p), ValueDef::Alias(_)) {
                    continue;
                }
                let mut same = None;
                let mut ok = true;
                for &(pb, k) in &bd.preds {
                    let a = f.resolve(edge_at(&f.blocks[pb.idx()].term, k as usize).args[n]);
                    if a == p {
                        continue;
                    }
                    match same {
                        None => same = Some(a),
                        Some(x) if x == a => {}
                        _ => {
                            ok = false;
                            break;
                        }
                    }
                }
                if let (true, Some(x)) = (ok, same)
                    && !matches!(f.def(x), ValueDef::Undef)
                {
                    f.values[p.idx()].def = ValueDef::Alias(x);
                    changed = true;
                    any = true;
                }
            }
        }
    }
    if any {
        f.resolve_aliases();
    }
    any
}

/// Merges each block that ends in a jump into its target when that is the target's only
/// predecessor, but for AOT loop heads (whose OSR entries land on them), the entries and
/// landing pad stubs. Whether any was.
fn merge_blocks(f: &mut Func) -> bool {
    let n = f.blocks.len();
    let mut gone = alloc::vec![false; n];
    let mut any = false;
    for b in 0..n {
        if f.blocks[b].kind == BlockKind::Stub {
            continue;
        }
        loop {
            let Term::Jmp(e) = &f.blocks[b].term else { break };
            let s = e.to.idx();
            let sd = &f.blocks[s];
            if s == b || sd.preds.len() != 1 || sd.kind != BlockKind::Body || sd.head.is_some() {
                break;
            }
            let Term::Jmp(e) = core::mem::replace(&mut f.blocks[b].term, Term::None) else { unreachable!() };
            let params = core::mem::take(&mut f.blocks[s].params);
            for (&p, &a) in params.iter().zip(&e.args) {
                let a = f.resolve(a);
                f.values[p.idx()].def = ValueDef::Alias(a);
            }
            let insts = core::mem::take(&mut f.blocks[s].insts);
            for &i in &insts {
                f.insts[i.idx()].block = Block(b as u32);
            }
            f.blocks[b].insts.extend(insts);
            let t = core::mem::replace(&mut f.blocks[s].term, Term::Trap);
            for k in 0..n_edges(&t) {
                let to = edge_at(&t, k).to.idx();
                for pr in f.blocks[to].preds.iter_mut() {
                    if *pr == (Block(s as u32), k as u16) {
                        *pr = (Block(b as u32), k as u16);
                    }
                }
            }
            f.blocks[b].term = t;
            f.blocks[s].preds.clear();
            gone[s] = true;
            any = true;
        }
    }
    if any {
        f.layout.retain(|b| !gone[b.idx()]);
        f.resolve_aliases();
    }
    any
}
