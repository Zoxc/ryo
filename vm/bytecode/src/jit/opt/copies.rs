//! Small block copies whose length the folds made constant: a `memcpy`, `memmove` or `memset`
//! handler call of at most [`MAX_COPY`] bytes, its operands all values, becomes plain loads
//! and stores (design/jit.md, "The SSA tier"). Every piece is loaded before any is stored, so
//! overlap is exact and `memmove` is one too. Through frame addresses, [`super::fold`] then
//! makes them alloca accesses, which promotion can turn into values.

use alloc::vec::Vec;

use crate::full::Opcode;
use crate::jit::decode::MAX_COPY;
use crate::jit::ir::*;

/// Rewrites the small constant-length copies; whether it changed anything.
pub fn copies(f: &mut Func) -> bool {
    let mut changed = false;
    for b in 0..f.blocks.len() {
        if !f.blocks[b].insts.iter().any(|&i| small(f, i).is_some()) {
            continue;
        }
        let blk = Block(b as u32);
        let insts = core::mem::take(&mut f.blocks[b].insts);
        for i in insts {
            let Some((set, len)) = small(f, i) else {
                f.blocks[b].insts.push(i);
                continue;
            };
            changed = true;
            let a = f.insts[i.idx()].args.clone();
            let (dp, x) = (a[0], a[1]);
            let mut pieces = Vec::new();
            let mut at = 0u32;
            while at < len {
                let n = 1u32 << (31 - (len - at).min(8).leading_zeros());
                pieces.push((at as i32, n as u8));
                at += n;
            }
            let vals: Vec<Value> = if set {
                // The byte in every byte of a word, truncated for the narrower pieces.
                let z = f.inst(blk, Op::Ext { from: 1, to: 8, sx: false }, alloc::vec![x], &[8]);
                let z = f.result(z);
                let k = f.konst(0x0101_0101_0101_0101, 8);
                let wd = f.inst(blk, Op::Bin(BinOp::Mul, 8), alloc::vec![z, k], &[8]);
                let wd = f.result(wd);
                pieces
                    .iter()
                    .map(|&(_, w)| {
                        if w == 8 {
                            wd
                        } else {
                            let t = f.inst(blk, Op::Ext { from: 8, to: w, sx: false }, alloc::vec![wd], &[w]);
                            f.result(t)
                        }
                    })
                    .collect()
            } else {
                pieces
                    .iter()
                    .map(|&(off, w)| {
                        let l = f.inst(blk, Op::Load(w, off), alloc::vec![x], &[w]);
                        f.result(l)
                    })
                    .collect()
            };
            for (&(off, w), v) in pieces.iter().zip(vals) {
                f.inst(blk, Op::Store(w, off), alloc::vec![dp, v], &[]);
            }
        }
    }
    changed
}

/// For a `memcpy`, `memmove` or `memset` call of a constant length up to [`MAX_COPY`] with
/// its operands (`dp`, `sp` or `b`, `n`) all values: whether it sets, and the length.
fn small(f: &Func, i: Inst) -> Option<(bool, u32)> {
    let id = &f.insts[i.idx()];
    let Op::HCall(h) = &id.op else { return None };
    let set = match h.h {
        Opcode::Memcpy | Opcode::Memmove => false,
        Opcode::Memset => true,
        _ => return None,
    };
    if id.args.len() != 3 || h.nout != 0 || h.ret || h.site != Site::None {
        return None;
    }
    if h.allocas().next().is_some() {
        return None;
    }
    let ValueDef::Const(n) = f.def(f.resolve(id.args[2])) else { return None };
    (n >= 1 && n <= MAX_COPY as u64).then_some((set, n as u32))
}
