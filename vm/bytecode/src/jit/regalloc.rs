//! Register allocation for the SSA tier (design/jit.md, "The SSA tier"): every value gets a
//! location that holds it from its definition to its last use ([`Loc`]). [`naive`] puts every
//! value in a stack slot of its own: the correctness baseline (`RYO_JIT_OPT=ssa-naive`).

use alloc::vec::Vec;

pub use super::ir::use_counts;
use super::ir::{Func, Op, Term, ValueDef};
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

/// Linear scan on SSA without splitting (design/jit.md, "The SSA tier"): each value's
/// interval runs from its definition to its last use in the linear block order (holes
/// ignored), and lives in one register or one stack slot throughout. Intervals that cross a
/// call (which clobbers every caller-saved register) get callee-saved registers; when none is
/// free, the interval that ends last is spilled.
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
    let mut calls: Vec<u32> = Vec::new();
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
            if id.op.is_call() {
                calls.push(p);
            }
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
        // A tail call clobbers like a call (the callee-saved registers are restored before
        // it); a return only moves into its return registers after the last use.
        if matches!(bd.term, Term::TailCall { .. }) {
            calls.push(e);
        }
    }
    calls.sort_unstable();
    let crosses = |a: u32, b: u32| {
        let i = calls.partition_point(|&c| c <= a);
        i < calls.len() && calls[i] < b
    };
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
    let (caller, callee) = registers(frame_pointer);
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
        let cross = crosses(a, b);
        // A hint: the register of the first operand (two-address forms), of an argument for a
        // parameter, or the fixed register the value comes in.
        let hint: Option<R> = match f.values[v].def {
            ValueDef::Inst(i, n) => match &f.insts[i.idx()].op {
                Op::Ovf(..) if n != 0 => None,
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
                    (!r.xmm).then(|| [R::Rdi, R::Rsi, R::Rdx, R::Rcx, R::R8, R::R9][r.index as usize])
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
        let ok = |r: &R| free[r.num() as usize] && (!cross || callee.contains(r));
        let pick = match hint.filter(|r| ok(r) && (caller.contains(r) || callee.contains(r))) {
            Some(h) => Some(caller.iter().chain(&callee).find(|&&r| r == h).unwrap()),
            None if cross => callee.iter().find(|r| free[r.num() as usize]),
            None => caller.iter().chain(&callee).find(|r| free[r.num() as usize]),
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
                    .filter(|(_, (_, _, r))| !cross || callee.contains(r))
                    .max_by_key(|(_, (end, _, _))| *end)
                    .map(|(k, &x)| (k, x));
                match cand {
                    Some((k, (end, w, r))) if end > b => {
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
    let (caller, _) = registers(frame_pointer);
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
            if id.op.is_call() {
                for &r in &caller {
                    if let Some(w) = owner[r.num() as usize] {
                        return Err(format!("v{w} lives across the call {i} in {r:?}"));
                    }
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
