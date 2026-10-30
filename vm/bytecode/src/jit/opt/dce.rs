use alloc::vec::Vec;

use crate::full::Opcode;
use crate::jit::ir::*;

/// Whether `op` has no effect but its results: a pure operation, or a call of a handler's
/// register entry ([`crate::jit::effects::RegEntry`]) that touches no memory and can't unwind:
/// its frame operands are values then, and it only computes.
pub(super) fn removable(op: &Op) -> bool {
    match op {
        Op::HCall(h) => h.reg && h.site == Site::None && h.h != Opcode::Lpad && !super::mem::touches_memory(h),
        op => op.pure(),
    }
}

/// Dead code elimination by mark and sweep (design/jit.md, "The SSA pipeline"): a value is live
/// if an effect, a terminator, or a live value's definition reads it; a block parameter's
/// arguments are read only when the parameter is live. Pure instructions with no live result
/// (and effect-free handler calls, [`removable`]) are dropped, and so are dead block
/// parameters (but the entry's, which are its argument registers) with their edges'
/// arguments, which removes dead loop-carried values too.
pub fn dce(f: &mut Func) {
    let mut live = alloc::vec![false; f.values.len()];
    let mut work: Vec<Value> = Vec::new();
    let mark = |v: Value, live: &mut Vec<bool>, work: &mut Vec<Value>| {
        if !live[v.idx()] {
            live[v.idx()] = true;
            work.push(v);
        }
    };
    for bd in &f.blocks {
        let fused = matches!(bd.term, Term::BrOvf { .. }).then(|| bd.insts.last().copied()).flatten();
        for &i in &bd.insts {
            let id = &f.insts[i.idx()];
            if !removable(&id.op) || Some(i) == fused {
                for &a in &id.args {
                    mark(a, &mut live, &mut work);
                }
                // Its results are kept as they are: mark them so their uses stay defined.
                for r in id.results() {
                    mark(r, &mut live, &mut work);
                }
            }
        }
        for u in bd.term.uses() {
            mark(u, &mut live, &mut work);
        }
        if bd.kind == BlockKind::Entry {
            for &p in &bd.params {
                mark(p, &mut live, &mut work);
            }
        }
    }
    while let Some(v) = work.pop() {
        match f.values[v.idx()].def {
            ValueDef::Inst(i, _) => {
                for &a in &f.insts[i.idx()].args {
                    mark(a, &mut live, &mut work);
                }
            }
            ValueDef::Param(b, n) => {
                for &(p, k) in &f.blocks[b.idx()].preds {
                    let e = f.blocks[p.idx()].term.edge(k as usize);
                    mark(e.args[n as usize], &mut live, &mut work);
                }
            }
            _ => {}
        }
    }
    for b in 0..f.blocks.len() {
        let insts = &f.insts;
        f.blocks[b].insts.retain(|&i| insts[i.idx()].results().any(|r| live[r.idx()]) || !removable(&insts[i.idx()].op));
    }
    for b in 0..f.blocks.len() {
        let keep: Vec<bool> = f.blocks[b].params.iter().map(|&p| live[p.idx()]).collect();
        if keep.iter().all(|&k| k) {
            continue;
        }
        let params: Vec<Value> = f.blocks[b].params.iter().zip(&keep).filter(|(_, k)| **k).map(|(&p, _)| p).collect();
        for &p in f.blocks[b].params.iter().filter(|p| !live[p.idx()]) {
            f.values[p.idx()].def = ValueDef::Undef;
        }
        for (n, &p) in params.iter().enumerate() {
            f.values[p.idx()].def = ValueDef::Param(Block(b as u32), n as u16);
        }
        f.blocks[b].params = params;
        for j in 0..f.blocks[b].preds.len() {
            let (p, k) = f.blocks[b].preds[j];
            let e = f.blocks[p.idx()].term.edge_mut(k as usize);
            e.args = e.args.iter().zip(&keep).filter(|(_, k)| **k).map(|(&a, _)| a).collect();
        }
    }
}
