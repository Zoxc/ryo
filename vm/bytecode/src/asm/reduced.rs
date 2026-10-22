//! The reduced instruction set (design/vm.md, "Reduced instructions"): the subset of the full
//! set ([`crate::full`]) that runs as native code, the inline instructions and the shapes
//! without a handler, and one `handler` instruction for every handler call: the handler, the
//! values of its argument registers and the control flow after it.
//!
//! [`reduce`] maps a function in the full set to the reduced set, and
//! [`decode_reduced`](super::decode_reduced) reads one from machine code without the
//! handlers' operand lists, only their register values. Both give the same [`Function`] for
//! the same code (`vm/bytecode/tests/asm.rs`).

use alloc::vec::Vec;

use super::encode::{ArgVal, EncodeError, Opnd, Ref, RoReq, Rodata, handler_args, operands};
use super::{Mode, has_handler};
use crate::full::{Opcode, insn_len};
use crate::image::{CATCH, CONTINUE, CleanupEntry};

/// A handler argument register's value.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Arg {
    /// `fp`.
    Fp,
    /// The exception object of a landing pad (`rax`).
    Exception,
    Imm(u64),
    /// The address of a [`Ref`]: a constant, data, a symbol slot, a site, or a code constant
    /// ([`Ref::Ro`], case values).
    Addr(Ref),
}

/// What follows a handler call: its shape's control flow. Targets are `T`, instruction
/// indices in a [`Function`].
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Then<T = u32> {
    /// The next instruction (`op`, `lpad`).
    Next,
    /// A branch on the returned `bool`, taken when it is true, or with `neg` false (`br`).
    Branch { neg: bool, target: T },
    /// A jump through the table on the returned index, the default last (`switch`).
    Table(Vec<T>),
    /// Nothing: the handler doesn't return (`trap`).
    Trap,
}

/// An instruction of the reduced set. Targets are `T`, instruction indices in a [`Function`].
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Insn<T = u32> {
    /// An instruction of the full set that runs as native code ([`is_native`]).
    Native { op: Opcode, ops: Vec<Opnd<T>> },
    /// A call of the handler `ryo_h_<op>` with its argument registers, `rdi` first, then
    /// `then`.
    Handler { op: Opcode, args: Vec<Arg>, then: Then<T> },
}

/// Where unwinding out of instruction `at` goes: to the caller, or to the `lpad` at `pad`
/// (instruction indices), catching every exception with `catch`.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Cleanup {
    pub at: u32,
    pub pad: Option<u32>,
    pub catch: bool,
}

/// A function in the reduced set.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Function {
    pub insns: Vec<Insn>,
    pub frame_size: u32,
    /// Sorted by instruction.
    pub cleanup: Vec<Cleanup>,
}

/// Whether the full instruction `op` with operands `ops` is in the reduced set: it has no
/// handler, or it is inlined ([`super::has_inline`] with operands it inlines).
pub fn is_native<T>(op: Opcode, ops: &[Opnd<T>]) -> bool {
    !has_handler(op) || super::inline::sequence(op, ops).is_some()
}

/// The reduced form of a function given as full instruction words (slots already frame
/// offsets), with its cleanup entries, as [`super::encode`] encodes it in `mode`: case value
/// addresses are where its code constants put them.
pub fn reduce(code: &[u32], frame_size: u32, cleanup: &[CleanupEntry], mode: Mode) -> Result<Function, EncodeError> {
    let mut starts = Vec::new();
    let mut at = 0;
    while at < code.len() {
        starts.push(at as u32);
        at += insn_len(&code[at..]).map_err(EncodeError::Decode)?;
    }
    let idx = |w: u32| starts.binary_search(&w).map(|i| i as u32).map_err(|_| EncodeError::BadTarget(w));
    // The code constants, in the encoder's order.
    let mut rodata = Rodata::default();
    let mut insns = Vec::with_capacity(starts.len());
    for &at in &starts {
        let op = Opcode::from_u16(code[at as usize] as u16).expect("insn_len read it");
        let ops = operands(code, at as usize).into_iter().map(|o| o.map_targets(idx)).collect::<Result<Vec<_>, _>>()?;
        if is_native(op, &ops) {
            if let (Opcode::Island, Some(Opnd::Words(w))) = (op, ops.get(1)) {
                rodata.ops(w);
            }
            insns.push(Insn::Native { op, ops });
            continue;
        }
        let args = handler_args(op, &ops, mode.fp_arg, |r| match r {
            RoReq::Bytes(b, align) => rodata.add(b, align),
            RoReq::Ops(_) => unreachable!("handlers take no operand arrays"),
        })
        .into_iter()
        .map(|v| match v {
            ArgVal::Fp => Arg::Fp,
            ArgVal::Exception => Arg::Exception,
            ArgVal::Imm(v, _) => Arg::Imm(v),
            ArgVal::Addr(r) => Arg::Addr(r),
            ArgVal::Ro(off) => Arg::Addr(Ref::Ro(off)),
        })
        .collect();
        let named = |name: &str| ops[op.info().operand_index(name).expect("operand")].clone();
        let then = match op.info().shape {
            crate::full::Shape::Br => {
                let (Opnd::Neg(neg), Opnd::Target(target)) = (named("neg"), named("t")) else { unreachable!() };
                Then::Branch { neg, target }
            }
            crate::full::Shape::Switch => {
                let mut ts: Vec<u32> = ops
                    .iter()
                    .flat_map(|o| match o {
                        Opnd::Targets(t) | Opnd::Cases(_, t) => t.clone(),
                        _ => Vec::new(),
                    })
                    .collect();
                let Opnd::Target(d) = named("default") else { unreachable!() };
                ts.push(d);
                Then::Table(ts)
            }
            crate::full::Shape::Trap => Then::Trap,
            _ => Then::Next,
        };
        insns.push(Insn::Handler { op, args, then });
    }
    let mut out = Vec::with_capacity(cleanup.len());
    for e in cleanup {
        let at = idx(e.offset).map_err(|_| EncodeError::BadCleanup(e.offset))?;
        let pad = (e.target != CONTINUE)
            .then(|| idx(e.target & !CATCH).map_err(|_| EncodeError::BadCleanup(e.offset)))
            .transpose()?;
        out.push(Cleanup { at, pad, catch: pad.is_some() && e.target & CATCH != 0 });
    }
    out.sort();
    Ok(Function { insns, frame_size, cleanup: out })
}
