//! Register allocation for the SSA tier (design/jit.md, "The SSA tier"): every value gets a
//! location that holds it from its definition to its last use ([`Loc`]). [`naive`] puts every
//! value in a stack slot of its own: the correctness baseline (`RYO_JIT_OPT=ssa-naive`).

use alloc::vec::Vec;

pub use super::ir::use_counts;
use super::ir::{Func, Op, ValueDef};
use super::x86::R;

/// Where a value lives.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Loc {
    /// Nowhere: a constant, undefined, or unused.
    None,
    Reg(R),
    /// Spill slot `n` (8 bytes).
    Spill(u32),
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
        let needs = match d.def {
            ValueDef::Inst(i, _) => !matches!(f.insts[i.idx()].op, Op::OsrLoad(..)) && (uses[v] > 0 || !f.insts[i.idx()].op.pure()),
            ValueDef::Param(..) => true,
            _ => false,
        };
        if needs {
            loc[v] = Loc::Spill(spills);
            spills += 1;
        }
    }
    Alloc { loc, spills, saved: Vec::new() }
}

/// The allocatable registers: caller-saved first, then callee-saved (`rbp` too without a
/// frame pointer). `r10` and `r11` are the emitter's scratch registers.
fn registers(frame_pointer: bool) -> (Vec<R>, Vec<R>) {
    let caller = alloc::vec![R::Rax, R::Rcx, R::Rdx, R::Rsi, R::Rdi, R::R8, R::R9];
    let mut callee = alloc::vec![R::Rbx, R::R12, R::R13, R::R14, R::R15];
    if !frame_pointer {
        callee.push(R::Rbp);
    }
    (caller, callee)
}

/// Linear positions: block `b` starts at `start[b]` (its parameters are defined there),
/// instruction `k` of it is at `start[b] + 2 (k + 1)`, its terminator after the last one.
pub struct Positions {
    pub start: Vec<u32>,
    pub end: Vec<u32>,
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

/// Live values at each block's entry (bit sets by value), by an iterative backward dataflow
/// over the blocks in layout (block parameters are defined at their block's start, edge
/// arguments used at the predecessor's end).
fn live_in(f: &Func) -> Vec<Vec<u64>> {
    let nv = f.values.len();
    let words = nv.div_ceil(64);
    let nb = f.blocks.len();
    let mut live = alloc::vec![alloc::vec![0u64; words]; nb];
    let tracked = |v: super::ir::Value| matches!(f.values[v.idx()].def, ValueDef::Inst(..) | ValueDef::Param(..));
    let mut changed = true;
    while changed {
        changed = false;
        for &b in f.layout.iter().rev() {
            let bd = &f.blocks[b.idx()];
            let mut cur = alloc::vec![0u64; words];
            for e in bd.term.edges() {
                for (w, x) in cur.iter_mut().zip(&live[e.to.idx()]) {
                    *w |= x;
                }
                for &p in &f.blocks[e.to.idx()].params {
                    cur[p.idx() / 64] &= !(1 << (p.idx() % 64));
                }
                for &a in &e.args {
                    if tracked(a) {
                        cur[a.idx() / 64] |= 1 << (a.idx() % 64);
                    }
                }
            }
            for u in bd.term.uses() {
                if tracked(u) {
                    cur[u.idx() / 64] |= 1 << (u.idx() % 64);
                }
            }
            for &i in bd.insts.iter().rev() {
                let id = &f.insts[i.idx()];
                for r in id.results() {
                    cur[r.idx() / 64] &= !(1 << (r.idx() % 64));
                }
                for &a in &id.args {
                    if tracked(a) {
                        cur[a.idx() / 64] |= 1 << (a.idx() % 64);
                    }
                }
            }
            for &p in &bd.params {
                cur[p.idx() / 64] &= !(1 << (p.idx() % 64));
            }
            if cur != live[b.idx()] {
                live[b.idx()] = cur;
                changed = true;
            }
        }
    }
    live
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
        _ if id.op.is_call() => CALL | [R::Rax, R::Rcx, R::Rdx, R::Rsi, R::Rdi, R::R8, R::R9].iter().fold(0, |m, &r| m | bit(r)),
        Op::Bin(B::DivS | B::DivU | B::RemS | B::RemU, _) | Op::Ovf(B::Mul, false, 8) => bit(R::Rax) | bit(R::Rdx),
        Op::Bin(B::Shl | B::ShrS | B::ShrU, _) if !matches!(f.values[id.args[1].idx()].def, ValueDef::Const(_)) => bit(R::Rcx),
        _ => 0,
    }
}

/// The registers each value is live across a clobber of ([`clobbers`]): live after it (but for
/// its results) by the exact liveness, walking each block backward from its live-out set. A
/// tail call needs nothing live after it, and a return only moves into its return registers
/// after the last use.
fn crossing(f: &Func, live: &[Vec<u64>]) -> Vec<u32> {
    let words = f.values.len().div_ceil(64);
    let mut cross = alloc::vec![0u32; f.values.len()];
    let tracked = |v: super::ir::Value| matches!(f.values[v.idx()].def, ValueDef::Inst(..) | ValueDef::Param(..));
    let mut cur = alloc::vec![0u64; words];
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        if !bd.insts.iter().any(|i| clobbers(f, &f.insts[i.idx()]) != 0) {
            continue;
        }
        cur.fill(0);
        for e in bd.term.edges() {
            for (w, x) in cur.iter_mut().zip(&live[e.to.idx()]) {
                *w |= x;
            }
            for &p in &f.blocks[e.to.idx()].params {
                cur[p.idx() / 64] &= !(1 << (p.idx() % 64));
            }
            for &a in &e.args {
                if tracked(a) {
                    cur[a.idx() / 64] |= 1 << (a.idx() % 64);
                }
            }
        }
        for u in bd.term.uses() {
            if tracked(u) {
                cur[u.idx() / 64] |= 1 << (u.idx() % 64);
            }
        }
        for &i in bd.insts.iter().rev() {
            let id = &f.insts[i.idx()];
            for r in id.results() {
                cur[r.idx() / 64] &= !(1 << (r.idx() % 64));
            }
            let m = clobbers(f, id);
            if m != 0 {
                for (w, &bits) in cur.iter().enumerate() {
                    let mut x = bits;
                    while x != 0 {
                        cross[w * 64 + x.trailing_zeros() as usize] |= m;
                        x &= x - 1;
                    }
                }
            }
            for &a in &id.args {
                if tracked(a) {
                    cur[a.idx() / 64] |= 1 << (a.idx() % 64);
                }
            }
        }
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
    let cand = |f: &Func, v: super::ir::Value| {
        cross.get(v.idx()).is_some_and(|c| c & CALL != 0)
            && matches!(f.values[v.idx()].def, ValueDef::Inst(i, _) if matches!(f.insts[i.idx()].op, Op::AllocaAddr(..) | Op::RefAddr(_, false)))
    };
    if !(0..f.values.len()).any(|v| cand(f, super::ir::Value(v as u32))) {
        return;
    }
    // Per block: the clone of each candidate valid since the last call.
    let mut cur: Vec<(super::ir::Value, super::ir::Value)> = Vec::new();
    let clone = |f: &mut Func, b: super::ir::Block, at: usize, v: super::ir::Value| -> super::ir::Value {
        let ValueDef::Inst(i, _) = f.values[v.idx()].def else { unreachable!() };
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
        let mut us: Vec<super::ir::Value> = term.uses();
        for e in term.edges() {
            us.extend(&e.args);
        }
        let mut subst: Vec<(super::ir::Value, super::ir::Value)> = Vec::new();
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
        let sub = |v: &mut super::ir::Value| {
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

/// Linear scan on SSA without splitting (design/jit.md, "The SSA tier"): each value's
/// interval runs from its definition to its last use in the linear block order (holes
/// ignored), and lives in one register or one stack slot throughout. Values live across a call
/// (which clobbers every caller-saved register; [`crossing`], by the exact liveness, so a call
/// in a hole of the interval doesn't count) get callee-saved registers; when none is free, the
/// interval that ends last is spilled.
pub fn linear_scan(f: &Func, uses: &[u32], frame_pointer: bool) -> Alloc {
    let pos = positions(f);
    let live = live_in(f);
    let nv = f.values.len();
    let mut lo = alloc::vec![u32::MAX; nv];
    let mut hi = alloc::vec![0u32; nv];
    let mut ext = |v: usize, a: u32, b: u32| {
        lo[v] = lo[v].min(a);
        hi[v] = hi[v].max(b);
    };
    let tracked = |v: super::ir::Value| matches!(f.values[v.idx()].def, ValueDef::Inst(..) | ValueDef::Param(..));
    let cross = crossing(f, &live);
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        let (s, e) = (pos.start[b.idx()], pos.end[b.idx()]);
        // Live into the block: from its start.
        for (w, &bits) in live[b.idx()].iter().enumerate() {
            let mut x = bits;
            while x != 0 {
                let v = w * 64 + x.trailing_zeros() as usize;
                x &= x - 1;
                ext(v, s, s);
            }
        }
        for &p in &bd.params {
            ext(p.idx(), s, s);
        }
        let mut out = alloc::vec![0u64; live[b.idx()].len()];
        for ed in bd.term.edges() {
            for (w, x) in out.iter_mut().zip(&live[ed.to.idx()]) {
                *w |= x;
            }
            for &a in &ed.args {
                if tracked(a) {
                    ext(a.idx(), e, e + 1);
                }
            }
        }
        // Live out: to the end (a value live out is live in, or defined here).
        for (w, &bits) in out.iter().enumerate() {
            let mut x = bits;
            while x != 0 {
                let v = w * 64 + x.trailing_zeros() as usize;
                x &= x - 1;
                ext(v, e + 1, e + 1);
            }
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
    let mut order: Vec<usize> = (0..nv)
        .filter(|&v| {
            // Unused values need no location (their definitions write nowhere).
            lo[v] != u32::MAX
                && uses[v] > 0
                && match f.values[v].def {
                    ValueDef::Inst(i, _) => !matches!(f.insts[i.idx()].op, Op::OsrLoad(..)),
                    ValueDef::Param(..) => true,
                    _ => false,
                }
        })
        .collect();
    order.sort_by_key(|&v| (lo[v], v));
    // Hints from uses: a shift amount wants `rcx`, a call argument its register, a returned
    // value its return register (the first use in layout order wins).
    let mut want: Vec<Option<R>> = alloc::vec![None; nv];
    let mut var_shift = false;
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        for &i in &bd.insts {
            let id = &f.insts[i.idx()];
            if clobbers(f, id) == 1 << R::Rcx.num() {
                want[id.args[1].idx()].get_or_insert(R::Rcx);
                var_shift = true;
            }
            match &id.op {
                Op::Call(c) => {
                    let rest = if c.target == super::ir::CallTarget::Ptr { &id.args[1..] } else { &id.args[..] };
                    for (r, a) in c.regs.iter().zip(rest) {
                        if !r.xmm {
                            want[a.idx()].get_or_insert(super::emit::int_arg(f.pe, r.index));
                        }
                    }
                }
                Op::HCall(h) if h.reg => {
                    for (k, a) in id.args.iter().enumerate() {
                        want[a.idx()].get_or_insert([R::Rdi, R::Rsi, R::Rdx, R::Rcx, R::R8, R::R9][k]);
                    }
                }
                _ => {}
            }
        }
        match &bd.term {
            super::ir::Term::TailCall { call, args } => {
                let rest = if call.target == super::ir::CallTarget::Ptr { &args[1..] } else { &args[..] };
                for (r, a) in call.regs.iter().zip(rest) {
                    if !r.xmm {
                        want[a.idx()].get_or_insert(super::emit::int_arg(f.pe, r.index));
                    }
                }
            }
            super::ir::Term::Ret { k, parts } if *k != 0 => {
                let ps = crate::asm::ret_parts(*k, true).into_iter().flatten().flatten();
                let mut g = [R::Rax, R::Rdx].into_iter();
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
    let (mut caller, callee) = registers(frame_pointer);
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
    // Active intervals: (end, value, register).
    let mut active: Vec<(u32, usize, R)> = Vec::new();
    let mut free = [true; 16];
    let mut saved = Vec::new();
    for v in order {
        let (a, b) = (lo[v], hi[v]);
        active.retain(|&(end, _, r)| {
            if end <= a {
                free[r.num() as usize] = true;
                false
            } else {
                true
            }
        });
        let clob = cross[v];
        let cross = clob & CALL != 0;
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
                Op::Call(_) => [R::Rax, R::Rdx].get(n as usize).copied(),
                Op::LandingPad => Some(R::Rax),
                Op::HCall(h) if h.reg => [R::Rax, R::Rdx].get(n as usize).copied(),
                Op::HCall(h) if h.ret && n == h.nout => Some(R::Rax),
                _ => None,
            },
            ValueDef::Param(blk, n) => {
                if f.blocks[blk.idx()].kind == super::ir::BlockKind::Entry && (n as usize) < f.entry_regs.len() {
                    let r = f.entry_regs[n as usize];
                    (!r.xmm).then(|| super::emit::int_arg(f.pe, r.index))
                } else {
                    f.blocks[blk.idx()].preds.iter().find_map(|&(p, k)| {
                        let e = f.blocks[p.idx()].term.edges().into_iter().nth(k as usize)?.args.get(n as usize).copied()?;
                        match loc[e.idx()] {
                            Loc::Reg(r) => Some(r),
                            _ => None,
                        }
                    })
                }
            }
            _ => None,
        };
        let shifts_by_var = |v: usize| matches!(f.values[v].def, ValueDef::Inst(i, _) if clobbers(f, &f.insts[i.idx()]) == 1 << R::Rcx.num());
        let ok =
            |r: &R| free[r.num() as usize] && clob >> r.num() & 1 == 0 && (!cross || (callee.contains(r) && (!def_cold(v) || saved.contains(r))));
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
            None if cross && def_cold(v) => callee.iter().find(|r| free[r.num() as usize] && saved.contains(*r)),
            None if cross => callee.iter().find(|r| free[r.num() as usize]),
            None => caller.iter().chain(&callee).find(|r| ok(r) && !(**r == R::Rcx && shifts_by_var(v))).or_else(|| caller.iter().find(|r| ok(r))),
        };
        match pick {
            Some(&r) => {
                free[r.num() as usize] = false;
                active.push((b, v, r));
                loc[v] = Loc::Reg(r);
                if callee.contains(&r) && !saved.contains(&r) {
                    saved.push(r);
                }
            }
            None => {
                // Spill the active interval (that this one may use) ending last, if it ends
                // after this one.
                let cand = active
                    .iter()
                    .enumerate()
                    .filter(|(_, (_, _, r))| (!cross || callee.contains(r)) && clob >> r.num() & 1 == 0)
                    .max_by_key(|(_, (end, _, _))| *end)
                    .map(|(k, &x)| (k, x));
                match cand {
                    Some((k, (end, w, r))) if end > b && !(cross && def_cold(v) && !saved.contains(&r)) => {
                        loc[w] = Loc::Spill(spills);
                        spills += 1;
                        active.remove(k);
                        active.push((b, v, r));
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
    let slot = |l: Loc| -> Option<usize> {
        match l {
            Loc::None => None,
            Loc::Reg(r) => Some(r.num() as usize),
            Loc::Spill(n) => Some(16 + n as usize),
        }
    };
    let tracked = |v: super::ir::Value| matches!(f.values[v.idx()].def, ValueDef::Inst(..) | ValueDef::Param(..));
    let n = 16 + al.spills as usize;
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        let mut owner: Vec<Option<u32>> = alloc::vec![None; n];
        let claim = |owner: &mut Vec<Option<u32>>, v: super::ir::Value| -> Result<(), alloc::string::String> {
            if !tracked(v) {
                return Ok(());
            }
            let l = al.loc[v.idx()];
            if let Loc::Reg(R::R10 | R::R11 | R::Rsp) = l {
                return Err(format!("{v} is in a reserved register"));
            }
            if frame_pointer && l == Loc::Reg(R::Rbp) {
                return Err(format!("{v} is in rbp"));
            }
            let s = slot(l).ok_or_else(|| format!("{v} is used in {b} but has no location"))?;
            match owner[s] {
                Some(w) if w != v.0 => Err(format!("{v} and v{w} both live in {l:?} in {b}")),
                _ => {
                    owner[s] = Some(v.0);
                    Ok(())
                }
            }
        };
        let release = |owner: &mut Vec<Option<u32>>, v: super::ir::Value| -> Result<(), alloc::string::String> {
            if let Some(s) = slot(al.loc[v.idx()]) {
                match owner[s] {
                    Some(w) if w != v.0 => return Err(format!("{v}'s definition in {b} overwrites v{w}")),
                    _ => owner[s] = None,
                }
            }
            Ok(())
        };
        // Live out.
        for e in bd.term.edges() {
            for (w, &bits) in live[e.to.idx()].iter().enumerate() {
                let mut x = bits;
                while x != 0 {
                    let v = super::ir::Value((w * 64) as u32 + x.trailing_zeros());
                    x &= x - 1;
                    claim(&mut owner, v)?;
                }
            }
            for &a in &e.args {
                claim(&mut owner, a)?;
            }
        }
        for u in bd.term.uses() {
            claim(&mut owner, u)?;
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
                && live[b.idx()][*v as usize / 64] >> (*v % 64) & 1 == 0
            {
                return Err(format!("v{v} in location {s} at the start of {b} isn't live in"));
            }
        }
    }
    Ok(())
}
