//! Register allocation for the SSA tier (design/jit.md, "The SSA tier"): every value gets a
//! location that holds it from its definition to its last use ([`Loc`]). [`naive`] puts every
//! value in a stack slot of its own: the correctness baseline (`RYO_JIT_OPT=ssa-naive`).
//!
//! Two register classes: 1 to 8-byte values take general-purpose registers, 16-byte vectors
//! `xmm` registers ([`xmm_registers`]). No `xmm` register is callee-saved for the SSA tier
//! (SysV has none; on PE the prologue saves the `xmm6`–`xmm15` it uses for its caller, but
//! values don't live in them across calls), so a vector live across a call lives in a
//! 16-byte spill slot (two 8-byte ones).

use alloc::vec::Vec;

use super::ir::{Block, Func, Op, Value, ValueDef};
use super::x86::R;

/// Where a value lives.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Loc {
    /// Nowhere: a constant, undefined, or unused.
    None,
    Reg(R),
    /// An `xmm` register (a vector).
    Xmm(u8),
    /// Spill slot `n` (8 bytes; a vector's takes `n` and `n + 1`).
    Spill(u32),
}

/// The allocatable `xmm` registers, and the emitter's two scratch ones: `xmm0`–`xmm13` and
/// `xmm14`, `xmm15`. The same on PE, where the prologue saves the callee-saved `xmm6`–`xmm15`
/// the code uses (the emit module's `xmm_saves`).
pub fn xmm_registers() -> (core::ops::Range<u8>, [u8; 2]) {
    (0..14, [14, 15])
}

/// The spill slots a value of `w` bytes takes.
fn slots(w: u8) -> u32 {
    if w == 16 { 2 } else { 1 }
}

#[derive(Clone, Debug)]
pub struct Alloc {
    pub loc: Vec<Loc>,
    pub spills: u32,
    /// The callee-saved registers the code uses, which the prologue saves.
    pub saved: Vec<R>,
}

/// Every value that needs a location in a stack slot of its own.
pub fn naive(f: &Func, uses: &[u32]) -> Alloc {
    let mut loc = alloc::vec![Loc::None; f.values.len()];
    let mut spills = 0;
    for (v, d) in f.values.iter().enumerate() {
        if needs_loc(f, v, uses, true) {
            loc[v] = Loc::Spill(spills);
            spills += slots(d.w);
        }
    }
    Alloc { loc, spills, saved: Vec::new() }
}

/// Whether value `v` needs a location: an instruction's result (but an OSR load's, which the
/// OSR entry stores) or a parameter, that is used; with `unused`, also an unused parameter or
/// impure instruction's result.
fn needs_loc(f: &Func, v: usize, uses: &[u32], unused: bool) -> bool {
    match f.values[v].def {
        ValueDef::Inst(i, _) => {
            let op = &f.insts[i.idx()].op;
            !matches!(op, Op::OsrLoad(..)) && (uses[v] > 0 || (unused && !op.pure()))
        }
        ValueDef::Param(..) => unused || uses[v] > 0,
        _ => false,
    }
}

/// The allocatable registers: caller-saved first, then callee-saved (`rbp` too without a
/// frame pointer). `r10` and `r11` are the emitter's scratch registers. On PE (Win64, the
/// handlers' convention too) `rsi` and `rdi` are callee-saved.
fn registers(frame_pointer: bool, pe: bool) -> (Vec<R>, Vec<R>) {
    let caller = caller_saved(pe).to_vec();
    let mut callee = alloc::vec![R::Rbx, R::R12, R::R13, R::R14, R::R15];
    if pe {
        callee.extend([R::Rsi, R::Rdi]);
    }
    if !frame_pointer {
        callee.push(R::Rbp);
    }
    (caller, callee)
}

/// Linear positions: block `b` starts at `start[b]` (its parameters are defined there),
/// instruction `k` of it is at `start[b] + 2 (k + 1)`, its terminator after the last one.
struct Positions {
    start: Vec<u32>,
    end: Vec<u32>,
}

fn positions(f: &Func) -> Positions {
    let mut start = alloc::vec![u32::MAX; f.blocks.len()];
    let mut end = alloc::vec![u32::MAX; f.blocks.len()];
    let mut p = 0;
    for &b in &f.layout {
        start[b.idx()] = p;
        p += 2 * (f.blocks[b.idx()].insts.len() as u32 + 1);
        end[b.idx()] = p;
        p += 2;
    }
    Positions { start, end }
}

/// A set of values, one bit each.
type BitSet = super::bits::BitSet<Value>;

/// Whether liveness tracks `v`: an instruction result or a block parameter (constants and
/// undefined values need no location).
fn tracked(f: &Func, v: Value) -> bool {
    matches!(f.def(v), ValueDef::Inst(..) | ValueDef::Param(..))
}

/// Block `b`'s live-out set given each block's live-in set: its successors' live-ins (minus
/// their parameters) plus the edge arguments, plus its terminator's uses.
fn live_out(f: &Func, live: &[BitSet], b: Block) -> BitSet {
    let bd = &f.blocks[b.idx()];
    let mut cur = BitSet::new(f.values.len());
    for e in bd.term.edges() {
        // Remove the parameters from this successor's own live-in only: one may be live
        // into another successor.
        let mut l = live[e.to.idx()].clone();
        for &p in &f.blocks[e.to.idx()].params {
            l.remove(p);
        }
        cur.union_with(&l);
        for &a in &e.args {
            if tracked(f, a) {
                cur.insert(a);
            }
        }
    }
    for u in bd.term.uses() {
        if tracked(f, u) {
            cur.insert(u);
        }
    }
    cur
}

/// Walks block `b`'s instructions backward from its live-out set `cur`, which ends as its
/// live-in set: each instruction kills its results, then `at` sees it with what is live
/// after it (but for its results), then it gens its arguments.
fn walk_back(f: &Func, b: Block, cur: &mut BitSet, mut at: impl FnMut(&super::ir::InstData, &BitSet)) {
    let bd = &f.blocks[b.idx()];
    for &i in bd.insts.iter().rev() {
        let id = &f.insts[i.idx()];
        for r in id.results() {
            cur.remove(r);
        }
        at(id, cur);
        for &a in &id.args {
            if tracked(f, a) {
                cur.insert(a);
            }
        }
    }
    for &p in &bd.params {
        cur.remove(p);
    }
}

/// Live values at each block's entry, by an iterative backward dataflow over the blocks in
/// layout (block parameters are defined at their block's start, edge arguments used at the
/// predecessor's end).
fn live_in(f: &Func) -> Vec<BitSet> {
    let mut live = alloc::vec![BitSet::new(f.values.len()); f.blocks.len()];
    let mut changed = true;
    while changed {
        changed = false;
        for &b in f.layout.iter().rev() {
            let mut cur = live_out(f, &live, b);
            walk_back(f, b, &mut cur, |_, _| {});
            if cur != live[b.idx()] {
                live[b.idx()] = cur;
                changed = true;
            }
        }
    }
    live
}

/// The allocatable registers every call clobbers: SysV's, or on PE Win64's.
fn caller_saved(pe: bool) -> &'static [R] {
    if pe { &[R::Rax, R::Rcx, R::Rdx, R::R8, R::R9] } else { &[R::Rax, R::Rcx, R::Rdx, R::Rsi, R::Rdi, R::R8, R::R9] }
}

/// [`clobbers`]' bit for a call (which clobbers every caller-saved register).
const CALL: u32 = 1 << 16;

/// The registers instruction `id` clobbers (bit `r.num()`), which no value live across it may
/// be in, with [`CALL`] for a call: `rax`/`rdx` for `div`/`rem` and the unsigned 64-bit `mul`
/// with overflow, `rcx` for a shift by a variable.
pub fn clobbers(f: &Func, id: &super::ir::InstData) -> u32 {
    use super::ir::BinOp as B;
    let bit = |r: R| 1u32 << r.num();
    match id.op {
        _ if id.op.is_call() => CALL | caller_saved(f.pe).iter().fold(0, |m, &r| m | bit(r)),
        Op::Bin(B::DivS | B::DivU | B::RemS | B::RemU, _) | Op::Ovf(B::Mul, false, 8) => bit(R::Rax) | bit(R::Rdx),
        _ if shift_by_var(f, id) => bit(R::Rcx),
        _ => 0,
    }
}

/// Whether `id` is a shift or rotate by a variable amount (which must be in `cl`).
fn shift_by_var(f: &Func, id: &super::ir::InstData) -> bool {
    use super::ir::BinOp as B;
    matches!(id.op, Op::Bin(B::Shl | B::ShrS | B::ShrU | B::Rotl | B::Rotr, _)) && f.const_of(id.args[1]).is_none()
}

/// The registers each value is live across a clobber of ([`clobbers`]): live after it (but for
/// its results) by the exact liveness, walking each block backward from its live-out set. A
/// tail call needs nothing live after it, and a return only moves into its return registers
/// after the last use.
fn crossing(f: &Func, live: &[BitSet]) -> Vec<u32> {
    let mut cross = alloc::vec![0u32; f.values.len()];
    for &b in &f.layout {
        if !f.blocks[b.idx()].insts.iter().any(|i| clobbers(f, &f.insts[i.idx()]) != 0) {
            continue;
        }
        let mut cur = live_out(f, live, b);
        walk_back(f, b, &mut cur, |id, cur| {
            let m = clobbers(f, id);
            if m != 0 {
                cur.iter().for_each(|v| cross[v.idx()] |= m);
            }
        });
    }
    cross
}

/// Rematerialization (D3 O11a): an address that is cheap to recompute (`AllocaAddr`, a
/// `RefAddr` that loads at most once) and is live across a call is recomputed before its uses
/// after a call instead (one clone per stretch of a block between calls), so it never takes a
/// callee-saved register or a spill slot. Uses in a block's terminator get a clone at the
/// block's end (before a fused `Ovf`); an `Invoke`'s edges keep the original.
pub fn remat(f: &mut Func) {
    let live = live_in(f);
    let cross = crossing(f, &live);
    let cand = |f: &Func, v: Value| {
        cross.get(v.idx()).is_some_and(|c| c & CALL != 0)
            && matches!(f.def(v), ValueDef::Inst(i, _) if matches!(f.insts[i.idx()].op, Op::AllocaAddr(..) | Op::RefAddr(_, false)))
    };
    if !(0..f.values.len()).any(|v| cand(f, Value(v as u32))) {
        return;
    }
    // Per block: the clone of each candidate valid since the last call.
    let mut cur: Vec<(Value, Value)> = Vec::new();
    let (mut us, mut subst): (Vec<Value>, Vec<(Value, Value)>) = (Vec::new(), Vec::new());
    let clone = |f: &mut Func, b: Block, at: usize, v: Value| -> Value {
        let ValueDef::Inst(i, _) = f.def(v) else { unreachable!() };
        let op = f.insts[i.idx()].op.clone();
        let w = f.w(v);
        let n = f.inst(b, op, Vec::new(), &[w]);
        let k = f.blocks[b.idx()].insts.pop().unwrap();
        f.blocks[b.idx()].insts.insert(at, k);
        f.result(n)
    };
    for bi in 0..f.layout.len() {
        let b = f.layout[bi];
        cur.clear();
        let mut k = 0;
        while k < f.blocks[b.idx()].insts.len() {
            let i = f.blocks[b.idx()].insts[k];
            for n in 0..f.insts[i.idx()].args.len() {
                let a = f.insts[i.idx()].args[n];
                if !cand(f, a) {
                    continue;
                }
                let c = match cur.iter().find(|(o, _)| *o == a) {
                    Some(&(_, c)) => c,
                    None => {
                        let c = clone(f, b, k, a);
                        k += 1;
                        cur.push((a, c));
                        c
                    }
                };
                f.insts[i.idx()].args[n] = c;
            }
            let id = &f.insts[i.idx()];
            if id.op.is_call() {
                cur.clear();
            }
            // A candidate defined here is valid until the next call.
            for r in id.results() {
                if cand(f, r) {
                    cur.push((r, r));
                }
            }
            k += 1;
        }
        if matches!(f.blocks[b.idx()].term, super::ir::Term::Invoke { .. }) {
            continue;
        }
        let fused = matches!(f.blocks[b.idx()].term, super::ir::Term::BrOvf { .. });
        let mut term = core::mem::replace(&mut f.blocks[b.idx()].term, super::ir::Term::None);
        us.clear();
        us.extend(term.uses());
        for e in term.edges() {
            us.extend(&e.args);
        }
        subst.clear();
        for u in &mut us {
            if !cand(f, *u) {
                continue;
            }
            let c = match cur.iter().find(|(o, _)| *o == *u) {
                Some(&(_, c)) => c,
                None => {
                    let len = f.blocks[b.idx()].insts.len();
                    let c = clone(f, b, if fused { len - 1 } else { len }, *u);
                    cur.push((*u, c));
                    c
                }
            };
            subst.push((*u, c));
        }
        let sub = |v: &mut Value| {
            if let Some(&(_, c)) = subst.iter().find(|(o, _)| o == v) {
                *v = c;
            }
        };
        for u in term.uses_mut() {
            sub(u);
        }
        for e in term.edges_mut() {
            e.args.iter_mut().for_each(sub);
        }
        f.blocks[b.idx()].term = term;
    }
}

/// Each block's loop depth, the loops approximated as the layout ranges from a head to its
/// last predecessor at or after it.
pub(crate) fn loop_depth(f: &Func) -> Vec<u32> {
    let mut at = alloc::vec![usize::MAX; f.blocks.len()];
    for (k, &b) in f.layout.iter().enumerate() {
        at[b.idx()] = k;
    }
    // `+1` at each head, `-1` after its latch, summed along the layout.
    let mut delta = alloc::vec![0i32; f.layout.len() + 1];
    for (h, &b) in f.layout.iter().enumerate() {
        if let Some(latch) = f.blocks[b.idx()].preds.iter().map(|&(p, _)| at[p.idx()]).filter(|&p| p != usize::MAX && p >= h).max() {
            delta[h] += 1;
            delta[latch + 1] -= 1;
        }
    }
    let mut depth = alloc::vec![0u32; f.blocks.len()];
    let mut d = 0i32;
    for (k, &b) in f.layout.iter().enumerate() {
        d += delta[k];
        depth[b.idx()] = d.max(0) as u32;
    }
    depth
}

/// Each value's spill weight (D3 O11a): its definition and uses, each counting `8^depth`
/// ([`loop_depth`], capped at 3); in cold blocks 1.
fn weights(f: &Func) -> Vec<u64> {
    let depth = loop_depth(f);
    let mut w = alloc::vec![0u64; f.values.len()];
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        let c = if bd.cold { 1 } else { 8u64.pow(depth[b.idx()].min(3)) };
        for &p in &bd.params {
            w[p.idx()] += c;
        }
        for &i in &bd.insts {
            let id = &f.insts[i.idx()];
            for a in id.args.iter().copied().chain(id.results()) {
                w[a.idx()] += c;
            }
        }
        for u in bd.term.uses() {
            w[u.idx()] += c;
        }
        for e in bd.term.edges() {
            for a in &e.args {
                w[a.idx()] += c;
            }
        }
    }
    w
}

/// Each value's interval for [`linear_scan`]: from its first to its last position in the
/// linear block order (`u32::MAX`, 0 for one never seen).
fn intervals(f: &Func, pos: &Positions, live: &[BitSet]) -> (Vec<u32>, Vec<u32>) {
    let nv = f.values.len();
    let mut lo = alloc::vec![u32::MAX; nv];
    let mut hi = alloc::vec![0u32; nv];
    let mut ext = |v: usize, a: u32, b: u32| {
        lo[v] = lo[v].min(a);
        hi[v] = hi[v].max(b);
    };
    let tracked = |v: Value| tracked(f, v);
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        let (s, e) = (pos.start[b.idx()], pos.end[b.idx()]);
        // Live into the block: from its start.
        for v in live[b.idx()].iter() {
            ext(v.idx(), s, s);
        }
        for &p in &bd.params {
            ext(p.idx(), s, s);
        }
        let mut out = BitSet::new(f.values.len());
        for ed in bd.term.edges() {
            out.union_with(&live[ed.to.idx()]);
            for &a in &ed.args {
                if tracked(a) {
                    ext(a.idx(), e, e + 1);
                }
            }
        }
        // Live out: to the end (a value live out is live in, or defined here).
        for v in out.iter() {
            ext(v.idx(), e + 1, e + 1);
        }
        for (k, &i) in bd.insts.iter().enumerate() {
            let p = s + 2 * (k as u32 + 1);
            let id = &f.insts[i.idx()];
            for &a in &id.args {
                if tracked(a) {
                    ext(a.idx(), p, p);
                }
            }
            for r in id.results() {
                ext(r.idx(), p, p);
            }
        }
        for u in bd.term.uses() {
            if tracked(u) {
                ext(u.idx(), e, e);
            }
        }
    }
    (lo, hi)
}

/// Hints from uses for [`linear_scan`]: a shift amount wants `rcx`, a call argument its
/// register, a returned value its return register (the first use in layout order wins). Also
/// whether there is a shift by a variable amount.
fn use_hints(f: &Func) -> (Vec<Option<R>>, bool) {
    let nv = f.values.len();
    let mut want: Vec<Option<R>> = alloc::vec![None; nv];
    let mut var_shift = false;
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        for &i in &bd.insts {
            let id = &f.insts[i.idx()];
            if shift_by_var(f, id) {
                want[id.args[1].idx()].get_or_insert(R::Rcx);
                var_shift = true;
            }
            match &id.op {
                Op::Call(c) => {
                    call_hints(f, &mut want, c, &id.args);
                }
                Op::HCall(h) if h.reg => {
                    for (k, a) in id.args.iter().enumerate() {
                        want[a.idx()].get_or_insert(super::emit::handler_arg_reg(f.pe, k).expect("a register entry's argument register"));
                    }
                }
                _ => {}
            }
        }
        match &bd.term {
            super::ir::Term::TailCall { call, args } => {
                call_hints(f, &mut want, call, args);
            }
            super::ir::Term::Ret { k, parts } if *k != 0 => {
                let ps = crate::asm::ret_parts(*k, true).into_iter().flatten().flatten();
                let mut g = R::RETS.into_iter();
                for (p, a) in ps.zip(parts) {
                    if !p.xmm
                        && let Some(r) = g.next()
                    {
                        want[a.idx()].get_or_insert(r);
                    }
                }
            }
            _ => {}
        }
    }
    (want, var_shift)
}

/// The integer argument registers a call's arguments want.
fn call_hints(f: &Func, want: &mut [Option<R>], c: &super::ir::Call, args: &[Value]) {
    let (_, rest) = c.split_args(args);
    for (r, a) in c.regs.iter().zip(rest) {
        if !r.xmm {
            want[a.idx()].get_or_insert(super::emit::int_arg(f.pe, r.index));
        }
    }
}

/// The values the predecessors of `blk` pass for its parameter `n`, in `preds` order.
fn pred_args(f: &Func, blk: Block, n: u16) -> impl Iterator<Item = Value> + '_ {
    f.blocks[blk.idx()].preds.iter().filter_map(move |&(p, k)| f.blocks[p.idx()].term.edges().nth(k as usize)?.args.get(n as usize).copied())
}

/// A register's index in [`Bank::free`].
trait RegIdx: Copy {
    fn idx(self) -> usize;
}

impl RegIdx for R {
    fn idx(self) -> usize {
        self.num() as usize
    }
}

impl RegIdx for u8 {
    fn idx(self) -> usize {
        self as usize
    }
}

/// One register file's state in [`linear_scan`]: general-purpose or `xmm`.
struct Bank<Reg> {
    /// Active intervals: (end, value, register).
    active: Vec<(u32, usize, Reg)>,
    free: [bool; 16],
}

impl<Reg> Default for Bank<Reg> {
    fn default() -> Self {
        Bank { active: Vec::new(), free: [true; 16] }
    }
}

impl<Reg: RegIdx> Bank<Reg> {
    /// Frees the registers of the intervals ending by `at`.
    fn expire(&mut self, at: u32) {
        let free = &mut self.free;
        self.active.retain(|&(end, _, r)| {
            if end <= at {
                free[r.idx()] = true;
                false
            } else {
                true
            }
        });
    }

    /// Gives the free register `r` to value `v`, live until `end`.
    fn take(&mut self, r: Reg, end: u32, v: usize) {
        self.free[r.idx()] = false;
        self.active.push((end, v, r));
    }

    /// The active interval in a register `ok` accepts that is first to spill by `key` (the
    /// first of equal ones): its index in `active` and itself.
    fn cheapest<K: Ord>(&self, ok: impl Fn(Reg) -> bool, key: impl Fn(usize, u32) -> K) -> Option<(usize, (u32, usize, Reg))> {
        self.active.iter().enumerate().filter(|(_, x)| ok(x.2)).min_by_key(|(_, x)| key(x.1, x.0)).map(|(k, &x)| (k, x))
    }

    /// Gives active interval `k`'s register to value `v`, live until `end` (`k` is spilled).
    fn replace(&mut self, k: usize, end: u32, v: usize) {
        let (_, _, r) = self.active.remove(k);
        self.active.push((end, v, r));
    }
}

/// Linear scan on SSA without splitting (design/jit.md, "The SSA tier"): each value's
/// interval runs from its definition to its last use in the linear block order (holes
/// ignored), and lives in one register or one stack slot throughout. Values live across a call
/// (which clobbers every caller-saved register; [`crossing`], by the exact liveness, so a call
/// in a hole of the interval doesn't count) get callee-saved registers; when none is free, the
/// interval with the least spill weight per position ([`weights`] over its length; of equal
/// ones, the one ending last) is spilled.
pub fn linear_scan(f: &Func, uses: &[u32], frame_pointer: bool) -> Alloc {
    let pos = positions(f);
    let live = live_in(f);
    let nv = f.values.len();
    let (lo, hi) = intervals(f, &pos, &live);
    let cross = crossing(f, &live);
    let weight = weights(f);
    // Weight per position from `a` on: what spilling saves for the register it frees.
    let density = |w: usize, end: u32| weight[w] * 256 / (end.saturating_sub(lo[w]) as u64 + 2);
    // The spill order: by density, then the one ending last first.
    let key = |w: usize, end: u32| (density(w, end), u32::MAX - end);
    // Unused values need no location (their definitions write nowhere).
    let mut order: Vec<usize> = (0..nv).filter(|&v| lo[v] != u32::MAX && needs_loc(f, v, uses, false)).collect();
    order.sort_by_key(|&v| (lo[v], v));
    let (want, var_shift) = use_hints(f);
    let (mut caller, callee) = registers(frame_pointer, f.pe);
    if var_shift {
        // Keep `rcx` for the shift amounts.
        caller.retain(|&r| r != R::Rcx);
        caller.push(R::Rcx);
    }
    let def_cold = |v: usize| match f.values[v].def {
        ValueDef::Inst(i, _) => f.blocks[f.insts[i.idx()].block.idx()].cold,
        ValueDef::Param(b, _) => f.blocks[b.idx()].cold,
        _ => false,
    };
    let mut loc = alloc::vec![Loc::None; nv];
    let mut spills = 0u32;
    let mut gp = Bank::<R>::default();
    let mut saved = Vec::new();
    // The vectors' `xmm` registers.
    let (xregs, _) = xmm_registers();
    let mut xb = Bank::<u8>::default();
    for v in order {
        let (a, b) = (lo[v], hi[v]);
        gp.expire(a);
        xb.expire(a);
        let clob = cross[v];
        let cross = clob & CALL != 0;
        if f.values[v].w == 16 {
            // Across a call: memory (no `xmm` register survives one).
            if cross {
                loc[v] = Loc::Spill(spills);
                spills += 2;
                continue;
            }
            let xmm_of = |x: Value| match loc[x.idx()] {
                Loc::Xmm(r) => Some(r),
                _ => None,
            };
            // A hint: the first operand's register (two-address forms), an argument's for a
            // parameter.
            let hint = match f.values[v].def {
                ValueDef::Inst(i, _) => f.insts[i.idx()].args.first().and_then(|&x| xmm_of(x)),
                ValueDef::Param(blk, n) => pred_args(f, blk, n).find_map(xmm_of),
                _ => None,
            };
            let pick = hint.filter(|&r| xb.free[r as usize] && xregs.contains(&r)).or_else(|| xregs.clone().find(|&r| xb.free[r as usize]));
            match pick {
                Some(r) => {
                    xb.take(r, b, v);
                    loc[v] = Loc::Xmm(r);
                }
                None => match xb.cheapest(|_| true, key) {
                    Some((k, (end, w, r))) if key(w, end) < key(v, b) => {
                        loc[w] = Loc::Spill(spills);
                        spills += 2;
                        xb.replace(k, b, v);
                        loc[v] = Loc::Xmm(r);
                    }
                    _ => {
                        loc[v] = Loc::Spill(spills);
                        spills += 2;
                    }
                },
            }
            continue;
        }
        // A hint: the register of the first operand (two-address forms), of an argument for a
        // parameter, or the fixed register the value comes in.
        let hint: Option<R> = match f.values[v].def {
            ValueDef::Inst(i, n) => match &f.insts[i.idx()].op {
                Op::Ovf(..) if n != 0 => None,
                Op::Bin(super::ir::BinOp::DivS | super::ir::BinOp::DivU, _) | Op::Ovf(super::ir::BinOp::Mul, false, 8) => Some(R::Rax),
                Op::Bin(super::ir::BinOp::RemS | super::ir::BinOp::RemU, _) => Some(R::Rdx),
                Op::Bin(..) | Op::Ovf(..) | Op::Ext { .. } | Op::PtrAdd(_) | Op::PtrIndex(_) => {
                    match f.insts[i.idx()].args.first().map(|a| loc[a.idx()]) {
                        Some(Loc::Reg(r)) => Some(r),
                        _ => None,
                    }
                }
                Op::Call(_) => R::RETS.get(n as usize).copied(),
                Op::LandingPad => Some(R::Rax),
                Op::HCall(h) if h.reg => R::RETS.get(n as usize).copied(),
                Op::HCall(h) if h.ret && n == h.nout => Some(R::Rax),
                _ => None,
            },
            ValueDef::Param(blk, n) => {
                if f.blocks[blk.idx()].kind == super::ir::BlockKind::Entry && (n as usize) < f.entry_regs.len() {
                    let r = f.entry_regs[n as usize];
                    (!r.xmm).then(|| super::emit::int_arg(f.pe, r.index))
                } else {
                    pred_args(f, blk, n).find_map(|e| match loc[e.idx()] {
                        Loc::Reg(r) => Some(r),
                        _ => None,
                    })
                }
            }
            _ => None,
        };
        let shifts_by_var = |v: usize| matches!(f.values[v].def, ValueDef::Inst(i, _) if shift_by_var(f, &f.insts[i.idx()]));
        let ok =
            |r: &R| gp.free[r.num() as usize] && clob >> r.num() & 1 == 0 && (!cross || (callee.contains(r) && (!def_cold(v) || saved.contains(r))));
        // A use's hint before an operand's, not before a register the value comes in.
        let soft = match f.values[v].def {
            ValueDef::Inst(i, _) => {
                matches!(f.insts[i.idx()].op, Op::Bin(..) | Op::Ovf(..) | Op::Ext { .. } | Op::PtrAdd(_) | Op::PtrIndex(_)) || hint.is_none()
            }
            _ => hint.is_none(),
        };
        let hint = match want[v] {
            Some(r) if ok(&r) && (soft || !hint.is_some_and(|h| ok(&h))) => Some(r),
            _ => hint.filter(|&r| clob >> r.num() & 1 == 0 && !(r == R::Rcx && shifts_by_var(v))),
        };
        let pick = match hint.filter(|r| ok(r) && (caller.contains(r) || callee.contains(r))) {
            Some(h) => Some(caller.iter().chain(&callee).find(|&&r| r == h).unwrap()),
            // A value of cold code crossing a call takes a callee-saved register only if the
            // prologue saves it anyway: otherwise a spill slot, off the hot path.
            None if cross && def_cold(v) => callee.iter().find(|r| gp.free[r.num() as usize] && saved.contains(*r)),
            None if cross => callee.iter().find(|r| gp.free[r.num() as usize]),
            None => caller.iter().chain(&callee).find(|r| ok(r) && !(**r == R::Rcx && shifts_by_var(v))).or_else(|| caller.iter().find(|r| ok(r))),
        };
        match pick {
            Some(&r) => {
                gp.take(r, b, v);
                loc[v] = Loc::Reg(r);
                if callee.contains(&r) && !saved.contains(&r) {
                    saved.push(r);
                }
            }
            None => {
                // Spill the active interval (that this one may use) with the lowest spill
                // density (ending last on ties), if that is lower than this one's.
                match gp.cheapest(|r| (!cross || callee.contains(&r)) && clob >> r.num() & 1 == 0, key) {
                    Some((k, (end, w, r))) if key(w, end) < key(v, b) && !(cross && def_cold(v) && !saved.contains(&r)) => {
                        loc[w] = Loc::Spill(spills);
                        spills += 1;
                        gp.replace(k, b, v);
                        loc[v] = Loc::Reg(r);
                    }
                    _ => {
                        loc[v] = Loc::Spill(spills);
                        spills += 1;
                    }
                }
            }
        }
    }
    Alloc { loc, spills, saved }
}

/// Checks an allocation (`RYO_JIT_CHECK`), independently of how it was made: walking each
/// block backward from its exact live-out set, no location holds two live values at once
/// (checked at every definition and use), no value lives across a call in a caller-saved
/// register, `r10`/`r11` are never allocated, and every value used has a location. A
/// description of the first problem.
pub fn check(f: &Func, al: &Alloc, frame_pointer: bool) -> Result<(), alloc::string::String> {
    use alloc::format;
    let live = live_in(f);
    let (xregs, _) = xmm_registers();
    // A location's numbers: registers, `xmm` registers from 16, spill slots from 32 (two for
    // a vector).
    let slot = |v: Value| -> Option<(usize, usize)> {
        match al.loc[v.idx()] {
            Loc::None => None,
            Loc::Reg(r) => Some((r.num() as usize, 1)),
            Loc::Xmm(x) => Some((16 + x as usize, 1)),
            Loc::Spill(n) => Some((32 + n as usize, slots(f.w(v)) as usize)),
        }
    };
    let n = 32 + al.spills as usize + 1;
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        let mut owner: Vec<Option<u32>> = alloc::vec![None; n];
        let claim = |owner: &mut Vec<Option<u32>>, v: Value| -> Result<(), alloc::string::String> {
            if !tracked(f, v) {
                return Ok(());
            }
            let l = al.loc[v.idx()];
            if let Loc::Reg(R::R10 | R::R11 | R::Rsp) = l {
                return Err(format!("{v} is in a reserved register"));
            }
            if frame_pointer && l == Loc::Reg(R::Rbp) {
                return Err(format!("{v} is in rbp"));
            }
            if let Loc::Xmm(x) = l
                && !xregs.contains(&x)
            {
                return Err(format!("{v} is in a reserved xmm{x}"));
            }
            if matches!(l, Loc::Xmm(_)) && f.w(v) != 16 || matches!(l, Loc::Reg(_)) && f.w(v) == 16 {
                return Err(format!("{v} ({} bytes) is in {l:?}", f.w(v)));
            }
            let (s, k) = slot(v).ok_or_else(|| format!("{v} is used in {b} but has no location"))?;
            for s in s..s + k {
                match owner[s] {
                    Some(w) if w != v.0 => return Err(format!("{v} and v{w} both live in {l:?} in {b}")),
                    _ => owner[s] = Some(v.0),
                }
            }
            Ok(())
        };
        let release = |owner: &mut Vec<Option<u32>>, v: Value| -> Result<(), alloc::string::String> {
            if let Some((s, k)) = slot(v) {
                for s in s..s + k {
                    match owner[s] {
                        Some(w) if w != v.0 => return Err(format!("{v}'s definition in {b} overwrites v{w}")),
                        _ => owner[s] = None,
                    }
                }
            }
            Ok(())
        };
        for v in live_out(f, &live, b).iter() {
            claim(&mut owner, v)?;
        }
        for &i in bd.insts.iter().rev() {
            let id = &f.insts[i.idx()];
            for r in id.results() {
                release(&mut owner, r)?;
            }
            let m = clobbers(f, id);
            for r in (0..16).filter(|&r| m >> r & 1 != 0) {
                if let Some(w) = owner[r] {
                    return Err(format!("v{w} lives across {i}, which clobbers it, in {:?}", R::from_num(r as u8)));
                }
            }
            if m & CALL != 0
                && let Some(w) = owner[16..32].iter().flatten().next()
            {
                return Err(format!("v{w} lives across {i}, a call, in an xmm register"));
            }
            for &a in &id.args {
                claim(&mut owner, a)?;
            }
        }
        for &p in &bd.params {
            release(&mut owner, p)?;
        }
        // What is left must be live in.
        for (s, o) in owner.iter().enumerate() {
            if let Some(v) = o
                && !live[b.idx()].contains(Value(*v))
            {
                return Err(format!("v{v} in location {s} at the start of {b} isn't live in"));
            }
        }
    }
    Ok(())
}
