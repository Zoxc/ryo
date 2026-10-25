//! Dead store elimination (design/jit.md, "The SSA tier"), per block, after value numbering
//! ([`super::lvn`]) forwarded what it could: a store to a memory alloca that no pointer
//! reaches (not escaped, not pinned, no [`Op::AllocaAddr`] of it) is dropped when later
//! stores of the block overwrite all its bytes before anything may read them. Only its own
//! loads, the handlers and islands that name it read such an alloca (a call can't), and an
//! island may read anything. At the block's end every byte counts as read.

use alloc::vec::Vec;

use crate::jit::ir::*;

pub fn dse(f: &mut Func) {
    let mut ok: Vec<bool> = f.allocas.iter().map(|a| a.kind == AllocaKind::Memory && !a.escaped && !a.pinned).collect();
    for id in &f.insts {
        if let Op::AllocaAddr(a, _) = id.op {
            ok[a.idx()] = false;
        }
    }
    if !ok.iter().any(|&x| x) {
        return;
    }
    // The byte ranges stores later in the block overwrite before any read.
    let mut dead: Vec<(AllocaId, i64, i64)> = Vec::new();
    for b in f.rpo() {
        dead.clear();
        let insts = core::mem::take(&mut f.blocks[b.idx()].insts);
        let mut kept = Vec::with_capacity(insts.len());
        for &i in insts.iter().rev() {
            match f.insts[i.idx()].op {
                Op::AStore(a, off, n) if ok[a.idx()] => {
                    let (lo, hi) = (off as i64, off as i64 + n as i64);
                    if (lo..hi).all(|x| dead.iter().any(|&(c, l, h)| c == a && l <= x && x < h)) {
                        continue;
                    }
                    dead.push((a, lo, hi));
                }
                Op::ALoad(a, off, w) => {
                    let (lo, hi) = (off as i64, off as i64 + w as i64);
                    dead.retain(|&(c, l, h)| c != a || h <= lo || l >= hi);
                }
                Op::HCall(ref h) => {
                    for s in h.regs.iter().flat_map(|r| r.1).flatten() {
                        if let SlotRef::Alloca(a, _) = s {
                            dead.retain(|&(c, ..)| c != a);
                        }
                    }
                }
                Op::Island(_) => dead.clear(),
                _ => {}
            }
            kept.push(i);
        }
        kept.reverse();
        f.blocks[b.idx()].insts = kept;
    }
}
