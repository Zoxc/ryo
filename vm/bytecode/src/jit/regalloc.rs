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
