//! Full code to the reduced set ([`crate::reduced`]), and the reduced instruction words both
//! [`reduce`] and [`super::decode_reduced`] build.

use alloc::vec::Vec;

use super::decode::Decoded;
use super::encode::{
    ArgVal, Asm, EncodeError, Encoded, Label, Opnd, Ref, RoReq, Rodata, Scope, ScopeKind, Unwind, case_elem, case_size, handler_args, operands,
    push_words, word_len,
};
use super::{Mode, has_handler};
use crate::full::{Elem, ElemKind, Opcode, OperandKind, Shape, insn_len};
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
        Ref::Handler(_) | Ref::RegHandler(_) | Ref::Probe | Ref::Func(_) | Ref::Rec | Ref::RecCtr => return None,
    })
}

/// The reduced instruction words of `insns`, with cleanup entries (instruction, landing pad
/// instruction or `None` to continue, catch), scopes by instruction index (the count for
/// the end) and the instructions whose store was dropped.
pub(super) fn words(
    insns: &[Insn],
    cleanup: &[(usize, Option<usize>, bool)],
    scopes: &[(usize, Scope)],
    dropped: &[usize],
    frame_size: u32,
) -> Decoded {
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
        .map(|&(i, pad, catch)| CleanupEntry { offset: wpos[i], target: pad.map_or(CONTINUE, |p| wpos[p] | if catch { CATCH } else { 0 }) })
        .collect();
    let scopes = scopes.iter().map(|&(i, sc)| Scope { code_offset: wpos[i], ..sc }).collect();
    let dropped = dropped.iter().map(|&i| wpos[i]).collect();
    // Loop heads: the targets of branches at or after them (single targets: a switch's
    // default, not its cases).
    let mut head = alloc::vec![false; insns.len()];
    for (k, i) in insns.iter().enumerate() {
        let single: Vec<u32> = match i {
            Insn::Native(_, ops) => ops.iter().filter_map(|o| if let Opnd::Target(t) = o { Some(*t) } else { None }).collect(),
            Insn::Handler(_, _, Then::Branch { target, .. }) => alloc::vec![*target],
            Insn::Handler(_, _, Then::Table(ts)) => ts.last().copied().into_iter().collect(),
            Insn::Handler(..) => Vec::new(),
        };
        for t in single {
            if t as usize <= k {
                head[t as usize] = true;
            }
        }
    }
    let heads = (0..insns.len()).filter(|&i| head[i]).map(|i| wpos[i]).collect();
    Decoded { words: out, frame_size, cleanup, scopes, dropped, heads }
}

/// The reduced form of a function given as full instruction words (slots already frame
/// offsets), with its cleanup entries, scopes and the word offsets of the instructions whose
/// store was dropped ([`Decoded::dropped`]), as [`super::encode`] encodes it in `mode`: case
/// value addresses are where its code constants put them.
pub fn reduce(
    code: &[u32],
    frame_size: u32,
    cleanup: &[CleanupEntry],
    scopes: &[Scope],
    dropped: &[u32],
    mode: Mode,
) -> Result<Decoded, EncodeError> {
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
        let pad =
            (e.target != CONTINUE).then(|| idx(e.target & !CATCH).map(|p| p as usize).map_err(|_| EncodeError::BadCleanup(e.offset))).transpose()?;
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
    let dropped = dropped.iter().map(|&w| idx(w).map(|i| i as usize)).collect::<Result<Vec<_>, _>>()?;
    Ok(words(&insns, &out, &scopes, &dropped, frame_size))
}

/// Encodes one function given in the reduced set (slots frame offsets), as
/// [`super::decode_reduced`] gives it, the exact inverse: with its frame size, cleanup entries,
/// scopes and dropped stores ([`Decoded`]), and the code constants its [`Arg::Ro`] arguments
/// index (the `rodata` it was decoded with, or [`super::Resolver::code_consts`]), it gives the
/// machine code, relocations, code constants, call sites, dropped stores and scopes
/// [`super::encode`] gave. Native instructions go through [`Asm::insn`]; a `handler` sets its
/// argument registers as given, calls the handler and ends in its shape's control flow. The
/// dead marks that dropped stores aren't in the decoded code, so it drops exactly the stores
/// of `dropped` ([`Asm::drop_exactly`]).
pub fn encode_reduced(
    code: &[u32],
    frame_size: u32,
    cleanup: &[CleanupEntry],
    scopes: &[Scope],
    dropped: &[u32],
    code_consts: &[u8],
    mode: Mode,
) -> Result<Encoded, EncodeError> {
    encode_reduced_at(code, frame_size, cleanup, scopes, dropped, code_consts, mode).map(|(e, _)| e)
}

/// [`encode_reduced`], and where each instruction starts in the code, by word offset (sorted
/// pairs): after a loop head's padding, where branches to it land.
pub fn encode_reduced_at(
    code: &[u32],
    frame_size: u32,
    cleanup: &[CleanupEntry],
    scopes: &[Scope],
    dropped: &[u32],
    code_consts: &[u8],
    mode: Mode,
) -> Result<(Encoded, Vec<(u32, u32)>), EncodeError> {
    let mut starts = Vec::new();
    let mut at = 0;
    while at < code.len() {
        reduced::Insn::decode(&code[at..]).map_err(EncodeError::Decode)?;
        starts.push(at as u32);
        at += reduced::insn_len(&code[at..]).map_err(EncodeError::Decode)?;
    }
    let idx = |w: u32| starts.binary_search(&w).map_err(|_| EncodeError::BadTarget(w));
    let label = |at: u32, t: u32| idx(at.wrapping_add(t)).map(|i| Label(i as u32));
    // The full opcode of each instruction (a handler's), for the unwind checks.
    let full_op = |at: u32| {
        let w = &code[at as usize..];
        let op = reduced::Opcode::from_u16(w[0] as u16).expect("decoded");
        op.full().unwrap_or_else(|| Opcode::from_u16(w[1] as u16).expect("decoded"))
    };

    let mut action: Vec<Option<Unwind>> = alloc::vec![None; starts.len()];
    for e in cleanup {
        let bad = EncodeError::BadCleanup(e.offset);
        let i = idx(e.offset).map_err(|_| bad)?;
        if !crate::image::op_may_unwind(full_op(e.offset)) || action[i].is_some() {
            return Err(bad);
        }
        action[i] = Some(if e.target == CONTINUE {
            Unwind::Continue
        } else {
            let p = idx(e.target & !CATCH).map_err(|_| bad)?;
            if full_op(starts[p]) != Opcode::Lpad {
                return Err(bad);
            }
            Unwind::Pad { pad: Label(p as u32), catch: e.target & CATCH != 0 }
        });
    }

    let mut asm = Asm::new(mode);
    asm.drop_exactly();
    for _ in 0..starts.len() {
        asm.label();
    }
    let mut scopes = scopes.iter().peekable();
    let mut scopes_at = |asm: &mut Asm, at: u32| -> Result<(), EncodeError> {
        while let Some(sc) = scopes.next_if(|sc| sc.code_offset <= at) {
            if sc.code_offset != at {
                return Err(EncodeError::BadTarget(sc.code_offset));
            }
            match sc.kind {
                ScopeKind::Escape { align } => asm.escape(sc.frame_offset as u32, sc.size, align),
                ScopeKind::End => asm.storage_end(sc.frame_offset as u32, sc.size),
                ScopeKind::Lend => asm.lend(sc.frame_offset as u32, sc.size),
            }
        }
        Ok(())
    };
    let mut dropped = dropped.iter().peekable();
    let mut full = Vec::new();
    for (i, &at) in starts.iter().enumerate() {
        asm.bind(Label(i as u32));
        scopes_at(&mut asm, at)?;
        let w = &code[at as usize..];
        let op = reduced::Opcode::from_u16(w[0] as u16).expect("decoded");
        let id = match op.full() {
            Some(f) => {
                // The full instruction's words, to read its operands.
                full.clear();
                full.extend_from_slice(&w[..reduced::insn_len(w).expect("decoded")]);
                full[0] = f as u32;
                if !super::return_ok(&full) {
                    return Err(EncodeError::BadReturn(at));
                }
                if f == Opcode::Arg && starts[..i].iter().any(|&a| full_op(a) != Opcode::Arg) {
                    return Err(EncodeError::ArgNotFirst(at));
                }
                let ops = operands(&full, 0).into_iter().map(|o| o.map_targets(|t| label(at, t))).collect::<Result<Vec<_>, _>>()?;
                asm.insn(f, &ops)
            }
            None => {
                let h = Opcode::from_u16(w[1] as u16).expect("decoded");
                let n = w[2] as usize;
                let args: Vec<Arg> = (0..n).map(|k| Arg::get(&w[3 + 3 * k..])).collect();
                let p = 3 + 3 * n;
                let neg = w[p] != 0;
                let ts = w[p + 2..][..w[p + 1] as usize].iter().map(|&t| label(at, t)).collect::<Result<Vec<_>, _>>()?;
                let bad = || EncodeError::BadHandler(at);
                let then = match h.info().shape {
                    Shape::Br if ts.len() == 1 => Then::Branch { neg, target: ts[0] },
                    Shape::Switch if !ts.is_empty() && !neg => Then::Table(ts),
                    Shape::Trap if ts.is_empty() && !neg => Then::Trap,
                    Shape::Op | Shape::Lpad if ts.is_empty() && !neg => Then::Next,
                    _ => return Err(bad()),
                };
                // The registers the handler's layout sets: `fp` and the exception object where
                // it takes them, and a switch's lists as its table has targets (an edited
                // table must keep them in step).
                let l = super::layout(h, mode);
                let info = h.info();
                if args.len() != l.regs as usize
                    || mode.fp_arg && args[0] != Arg::Fp
                    || info.shape == Shape::Lpad && args[l.first as usize - 1] != Arg::Exception
                {
                    return Err(bad());
                }
                let mut values: &[u8] = &[];
                let mut cases = 0;
                let mut ro_args = 0;
                for (k, o) in info.operands.iter().enumerate() {
                    let r = l.locs[k].reg as usize;
                    match o.kind {
                        OperandKind::List(ElemKind::Target) => match args[r] {
                            Arg::Imm(n) => cases += n,
                            _ => return Err(bad()),
                        },
                        OperandKind::List(e) if case_elem(h) == Some(e) => {
                            // A sparse switch's case values: as many as its cases, of its
                            // value size.
                            let (Arg::Ro(off), Arg::Imm(n)) = (args[r], args[r + 1]) else { return Err(bad()) };
                            let len = usize::try_from(n).ok().and_then(|n| n.checked_mul(case_size(e))).ok_or_else(bad)?;
                            values = code_consts.get(off as usize..).and_then(|b| b.get(..len)).ok_or_else(bad)?;
                            cases += n;
                            ro_args += 1;
                        }
                        _ => {}
                    }
                }
                if args.iter().filter(|a| matches!(a, Arg::Ro(_))).count() != ro_args
                    || matches!(&then, Then::Table(ts) if ts.len() as u64 != cases + 1)
                {
                    return Err(bad());
                }
                asm.handler(h, &args, values, then)
            }
        };
        if let Some(a) = action[i] {
            asm.set_unwind(id, a);
        }
        if dropped.next_if(|&&d| d == at).is_some() {
            if !asm.can_drop_store() {
                return Err(EncodeError::BadDropped(at));
            }
            asm.drop_store();
        }
    }
    scopes_at(&mut asm, code.len() as u32)?;
    if scopes.next().is_some() {
        return Err(EncodeError::BadTarget(code.len() as u32));
    }
    if let Some(&d) = dropped.next() {
        return Err(EncodeError::BadDropped(d));
    }
    let (e, at) = asm.finish_labels(frame_size, |s| s);
    Ok((e, starts.into_iter().zip(at).collect()))
}
