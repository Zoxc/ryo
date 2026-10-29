//! The memory-effect model the passes share: which bytes an instruction may write. Value
//! numbering ([`super::lvn`]) forgets the loads an instruction may write, loop-invariant code
//! motion ([`super::hoist`]) keeps a load in its loop if anything there may write it.
//!
//! - A pointer store writes the bytes it stores to and anything another pointer or an
//!   aliasable alloca ([`Alloca::aliasable`]) may be, but not other bytes through the same pointer.
//! - An alloca store writes its own bytes, and what pointers may reach if the alloca is
//!   aliasable.
//! - A handler call writes the allocas it names, and if it touches memory
//!   ([`touches_memory`]) every pointer and aliasable alloca.
//! - A call writes every pointer and aliasable alloca, and the allocas that aren't memory or
//!   incoming (they live in registers or slots a call may clobber).
//! - An island or an instruction of unknown effect writes everything; pure operations and
//!   loads nothing.

use crate::jit::ir::*;

/// Some bytes of memory: at an alloca offset, or at a pointer value plus an offset.
#[derive(Clone, Copy, PartialEq, Eq)]
pub enum Loc {
    A(AllocaId, i32),
    P(Value, i32),
}

fn aliasable(f: &Func, a: AllocaId) -> bool {
    f.allocas[a.idx()].aliasable()
}

/// Whether the handler call `h` may read or write memory beyond the allocas it names.
pub fn touches_memory(h: &HCall) -> bool {
    crate::jit::effects::effects(h.h).is_none_or(|e| e.memory)
}

/// Whether `i` may write any of the `w` bytes at `l`.
pub fn may_write(f: &Func, i: Inst, l: Loc, w: u8) -> bool {
    let id = &f.insts[i.idx()];
    let over = |o: i32, n: u8, k: i32, m: u8| (k as i64) < o as i64 + n as i64 && (o as i64) < k as i64 + m as i64;
    match id.op {
        Op::Load(..) | Op::ALoad(..) => false,
        ref op if op.pure() => false,
        Op::Store(n, k) => match l {
            Loc::A(b, _) => aliasable(f, b),
            Loc::P(q, o) => q != id.args[0] || over(o, w, k, n),
        },
        Op::AStore(a, k, n) => match l {
            Loc::A(b, o) => b == a && over(o, w, k, n),
            Loc::P(..) => aliasable(f, a),
        },
        Op::HCall(ref h) => {
            let memory = touches_memory(h);
            match l {
                Loc::A(b, _) => h.allocas().any(|a| a == b) || (memory && aliasable(f, b)),
                Loc::P(..) => memory,
            }
        }
        Op::Call(_) => match l {
            Loc::A(b, _) => aliasable(f, b) || !matches!(f.allocas[b.idx()].kind, AllocaKind::Memory | AllocaKind::Incoming),
            Loc::P(..) => true,
        },
        _ => true,
    }
}
