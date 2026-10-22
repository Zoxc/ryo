//! Full code to the reduced set ([`crate::reduced`]), and the reduced instruction words both
//! [`reduce`] and [`super::decode_reduced`] build.

use alloc::vec::Vec;

use super::decode::Decoded;
use super::encode::{ArgVal, EncodeError, Opnd, Ref, RoReq, Rodata, Scope, handler_args, operands, push_words, word_len};
use super::{Mode, has_handler};
use crate::full::{Opcode, Shape, insn_len};
use crate::image::{CATCH, CONTINUE, CleanupEntry};
use crate::reduced::{self, Arg};

/// Whether the full instruction `op` with operands `ops` is in the reduced set: it has no
/// handler, or it is inlined ([`super::has_inline`] with operands it inlines).
pub fn is_native<T>(op: Opcode, ops: &[Opnd<T>]) -> bool {
    !has_handler(op) || super::inline::sequence(op, ops).is_some()
}

/// What follows a handler call: its shape's control flow, with targets `T`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub(super) enum Then<T = u32> {
    /// The next instruction (`op`, `lpad`).
    Next,
    /// A branch on the returned `bool`, taken when it is true, or with `neg` false (`br`).
    Branch { neg: bool, target: T },
    /// A jump through the table on the returned index, the default last (`switch`).
    Table(Vec<T>),
    /// Nothing: the handler doesn't return (`trap`).
    Trap,
}

/// A reduced instruction being built, targets instruction indices: one of the full set
/// that is in the reduced set, or a handler call.
pub(super) enum Insn {
    Native(Opcode, Vec<Opnd>),
    Handler(Opcode, Vec<Arg>, Then),
}

/// The argument value of the address of `r`, if a handler can take it.
pub(super) fn addr_arg(r: Ref) -> Option<Arg> {
    Some(match r {
        Ref::Const(k) => Arg::Const(k),
        Ref::Data(d) => Arg::Data(d),
        Ref::Sym(s) => Arg::Sym(s),
        Ref::Site(s) => Arg::Site(s),
        Ref::Ro(o) => Arg::Ro(o),
        Ref::Handler(_) | Ref::Probe | Ref::Func(_) => return None,
    })
}

/// The reduced instruction words of `insns`, with cleanup entries (instruction, landing pad
/// instruction or `None` to continue, catch) and scopes by instruction index (the count for
/// the end).
pub(super) fn words(insns: &[Insn], cleanup: &[(usize, Option<usize>, bool)], scopes: &[(usize, Scope)], frame_size: u32) -> Decoded {
    let len = |i: &Insn| match i {
        Insn::Native(op, ops) => word_len(*op, ops),
        Insn::Handler(_, args, then) => {
            let n = match then {
                Then::Branch { .. } => 1,
                Then::Table(t) => t.len(),
                Then::Next | Then::Trap => 0,
            };
            4 + 3 * args.len() + 1 + n
        }
    };
    let mut wpos = Vec::with_capacity(insns.len() + 1);
    let mut w = 0u32;
    for i in insns {
        wpos.push(w);
        w += len(i) as u32;
    }
    wpos.push(w);
    let mut out = Vec::with_capacity(w as usize);
    for (k, i) in insns.iter().enumerate() {
        let rel = |t: u32| wpos[t as usize].wrapping_sub(wpos[k]);
        match i {
            Insn::Native(op, ops) => {
                let at = out.len();
                let ops: Vec<Opnd> = ops.iter().map(|o| o.clone().map_targets(|t| Ok::<_, ()>(rel(t))).unwrap()).collect();
                push_words(*op, &ops, &mut out);
                out[at] = reduced::Opcode::of_full(*op).expect("in the reduced set") as u32;
            }
            Insn::Handler(op, args, then) => {
                let (neg, ts) = match then {
                    Then::Branch { neg, target } => (*neg, alloc::vec![*target]),
                    Then::Table(t) => (false, t.clone()),
                    Then::Next | Then::Trap => (false, Vec::new()),
                };
                out.extend([reduced::Opcode::Handler as u32, *op as u32, args.len() as u32]);
                for a in args {
                    crate::full::Elem::put(a, &mut out);
                }
                out.extend([neg as u32, ts.len() as u32]);
                out.extend(ts.into_iter().map(rel));
            }
        }
    }
    let cleanup = cleanup
        .iter()
        .map(|&(i, pad, catch)| CleanupEntry {
            offset: wpos[i],
            target: pad.map_or(CONTINUE, |p| wpos[p] | if catch { CATCH } else { 0 }),
        })
        .collect();
    let scopes = scopes.iter().map(|&(i, sc)| Scope { code_offset: wpos[i], ..sc }).collect();
    Decoded { words: out, frame_size, cleanup, scopes }
}

/// The reduced form of a function given as full instruction words (slots already frame
/// offsets), with its cleanup entries and scopes, as [`super::encode`] encodes it in `mode`:
/// case value addresses are where its code constants put them. Returns the reduced words,
/// cleanup entries and scopes.
pub fn reduce(code: &[u32], frame_size: u32, cleanup: &[CleanupEntry], scopes: &[Scope], mode: Mode) -> Result<Decoded, EncodeError> {
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
            insns.push(Insn::Native(op, ops));
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
            ArgVal::Addr(r) => addr_arg(r).expect("a handler argument"),
            ArgVal::Ro(off) => Arg::Ro(off),
        })
        .collect();
        let named = |name: &str| ops[op.info().operand_index(name).expect("operand")].clone();
        let then = match op.info().shape {
            Shape::Br => {
                let (Opnd::Neg(neg), Opnd::Target(target)) = (named("neg"), named("t")) else { unreachable!() };
                Then::Branch { neg, target }
            }
            Shape::Switch => {
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
            Shape::Trap => Then::Trap,
            _ => Then::Next,
        };
        insns.push(Insn::Handler(op, args, then));
    }
    let mut out = Vec::with_capacity(cleanup.len());
    for e in cleanup {
        let at = idx(e.offset).map_err(|_| EncodeError::BadCleanup(e.offset))? as usize;
        let pad = (e.target != CONTINUE)
            .then(|| idx(e.target & !CATCH).map(|p| p as usize).map_err(|_| EncodeError::BadCleanup(e.offset)))
            .transpose()?;
        out.push((at, pad, pad.is_some() && e.target & CATCH != 0));
    }
    out.sort();
    let scopes = scopes
        .iter()
        .map(|sc| {
            let i = if sc.code_offset as usize == code.len() { Ok(starts.len() as u32) } else { idx(sc.code_offset) };
            Ok((i? as usize, *sc))
        })
        .collect::<Result<Vec<_>, EncodeError>>()?;
    Ok(words(&insns, &out, &scopes, frame_size))
}
