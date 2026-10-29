//! Full code to the reduced set ([`crate::reduced`]), and the reduced instruction words both
//! [`reduce`] and [`super::decode_reduced`] build.

use alloc::vec::Vec;

use super::decode::Decoded;
use super::encode::{
    ArgVal, Asm, EncodeError, Encoded, Label, Opnd, Ref, RoReq, Rodata, Scope, ScopeKind, Unwind, check_region, handler_args, operands, opnd_labels,
    pe_region_start, push_words, word_len,
};
use super::{Mode, has_handler};
use crate::full::{ElemKind, Opcode, OperandKind, Shape, insn_len};
use crate::image::{Cleanup, CleanupEntry};
use crate::reduced::{self, Arg};

/// Whether the full instruction `op` with operands `ops` is in the reduced set: it has no
/// handler, or it is inlined ([`super::has_inline`] with operands it inlines).
pub fn is_native<T>(op: Opcode, ops: &[Opnd<T>]) -> bool {
    !has_handler(op) || super::inline::sequence(op, ops).is_some()
}

/// The reduced instruction words of a handler call doing the native instruction `words` (a
/// reduced one, of an opcode without targets or code constants) in `mode`.
pub fn as_handler(words: &[u32], mode: Mode) -> Vec<u32> {
    let mut full = words.to_vec();
    let op = reduced::Opcode::from_u16(words[0] as u16).and_then(|op| op.full()).expect("a native instruction");
    full[0] = op as u32;
    let ops: Vec<Opnd> = operands(&full, 0);
    let args: Vec<Arg> =
        handler_args(op, &ops, mode, |_| unreachable!("no code constants")).into_iter().map(|v| v.to_arg().expect("a handler argument")).collect();
    let mut out = Vec::with_capacity(handler_words(args.len(), 0));
    push_handler(op, &args, false, &[], &mut out);
    out
}

/// The length in words of a reduced `handler` with `nargs` arguments and `ntargets` targets.
fn handler_words(nargs: usize, ntargets: usize) -> usize {
    3 + ElemKind::Arg.words() * nargs + 2 + ntargets
}

/// Appends a reduced `handler` calling `op`'s handler with `args`, then `neg` and the
/// (relative) targets `targets`.
fn push_handler(op: Opcode, args: &[Arg], neg: bool, targets: &[u32], out: &mut Vec<u32>) {
    out.extend([reduced::Opcode::Handler as u32, op as u32, args.len() as u32]);
    for a in args {
        crate::full::Elem::put(a, out);
    }
    out.extend([neg as u32, targets.len() as u32]);
    out.extend_from_slice(targets);
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

impl<T: Copy> Then<T> {
    /// All its targets: the branch's, or the table's (the default last).
    pub(super) fn targets(&self) -> &[T] {
        match self {
            Then::Branch { target, .. } => core::slice::from_ref(target),
            Then::Table(ts) => ts,
            Then::Next | Then::Trap => &[],
        }
    }

    /// Its single target, which can make a loop head: the branch's, or the table's default.
    pub(super) fn loop_target(&self) -> Option<T> {
        match self {
            Then::Branch { target, .. } => Some(*target),
            Then::Table(ts) => ts.last().copied(),
            Then::Next | Then::Trap => None,
        }
    }
}

/// The jump table targets of the `switch`-shaped `op` with operands `ops`: its targets or
/// cases' targets, then the default.
pub(super) fn switch_targets<T: Copy>(op: Opcode, ops: &[Opnd<T>]) -> Vec<T> {
    let mut ts: Vec<T> = ops
        .iter()
        .flat_map(|o| match o {
            Opnd::Targets(t) | Opnd::Cases(_, t) => &t[..],
            _ => &[],
        })
        .copied()
        .collect();
    let Opnd::Target(d) = ops[op.info().operand_index("default").expect("operand")] else { unreachable!("a switch's default") };
    ts.push(d);
    ts
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
        Ref::Ro(o) => Arg::Ro(o),
        Ref::Handler(_) | Ref::RegHandler(_) | Ref::Probe | Ref::Func(_) | Ref::Rec | Ref::RecLoopCtr => return None,
    })
}

impl ArgVal {
    /// The reduced `handler`'s argument of this value, if a handler can take it (the
    /// reverse of `From<Arg>`).
    pub(super) fn to_arg(self) -> Option<Arg> {
        Some(match self {
            ArgVal::Fp => Arg::Fp,
            ArgVal::Exception => Arg::Exception,
            ArgVal::Imm(v, _) => Arg::Imm(v),
            ArgVal::Addr(r) => return addr_arg(r),
            ArgVal::Ro(off) => Arg::Ro(off),
        })
    }
}

/// The single branch targets of an instruction with operands `ops` and, for a handler call,
/// control flow `then`, which can make loop heads: its `Target` operands, a handler call's
/// branch or its table's default (not a jump table's cases).
pub(super) fn single_targets<'a, T: Copy>(ops: &'a [Opnd<T>], then: Option<&'a Then<T>>) -> impl Iterator<Item = T> + 'a {
    let ops = ops.iter().filter_map(|o| if let Opnd::Target(t) = o { Some(*t) } else { None });
    ops.chain(then.and_then(Then::loop_target))
}

/// Whether a single branch at instruction `k` to instruction `t` makes `t` a loop head: it
/// is at or before the branch, and before the pad region's start `region`.
pub(super) fn makes_head(k: usize, t: usize, region: usize) -> bool {
    t <= k && t < region
}

/// The reduced instruction words of `insns` (or the full words, with `full`: then they are
/// all [`Insn::Native`]), with cleanup entries (instruction, landing pad instruction or
/// `None` to continue, catch), scopes by instruction index (the count for the end), the
/// instructions whose store was dropped and the loop heads' instructions, in order.
pub(super) fn words(
    insns: &[Insn],
    cleanup: &[(usize, Option<usize>, bool)],
    scopes: &[(usize, Scope)],
    dropped: &[usize],
    heads: &[usize],
    frame_size: u32,
    full: bool,
) -> Decoded {
    let len = |i: &Insn| match i {
        Insn::Native(op, ops) => word_len(*op, ops),
        Insn::Handler(_, args, then) => handler_words(args.len(), then.targets().len()),
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
                if !full {
                    out[at] = reduced::Opcode::of_full(*op).expect("in the reduced set") as u32;
                }
            }
            Insn::Handler(op, args, then) => {
                let neg = matches!(then, Then::Branch { neg: true, .. });
                let ts: Vec<u32> = then.targets().iter().map(|&t| rel(t)).collect();
                push_handler(*op, args, neg, &ts, &mut out);
            }
        }
    }
    let cleanup = cleanup
        .iter()
        .map(|&(i, pad, catch)| CleanupEntry { offset: wpos[i], target: Cleanup::new(pad.map(|p| wpos[p]), catch).to_word() })
        .collect();
    let scopes = scopes.iter().map(|&(i, sc)| Scope { code_offset: wpos[i], ..sc }).collect();
    let dropped = dropped.iter().map(|&i| wpos[i]).collect();
    let heads = heads.iter().map(|&i| wpos[i]).collect();
    Decoded { words: out, frame_size, cleanup, scopes, dropped, heads }
}

/// The loop heads of `insns` with cleanup entries `cleanup` (as [`words`] takes them), in
/// order. With `pe`, from the first cleanup landing pad on is the pad region, which has none.
fn loop_heads(insns: &[Insn], cleanup: &[(usize, Option<usize>, bool)], pe: bool) -> Vec<usize> {
    let region = if pe { cleanup.iter().filter(|c| !c.2).filter_map(|c| c.1).min().unwrap_or(usize::MAX) } else { usize::MAX };
    let mut head = alloc::vec![false; insns.len()];
    for (k, i) in insns.iter().enumerate() {
        let single: Vec<u32> = match i {
            Insn::Native(_, ops) => single_targets(ops, None).collect(),
            Insn::Handler(_, _, then) => single_targets(&[], Some(then)).collect(),
        };
        for t in single {
            if makes_head(k, t as usize, region) {
                head[t as usize] = true;
            }
        }
    }
    (0..insns.len()).filter(|&i| head[i]).collect()
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
        let args = handler_args(op, &ops, mode, |r| match r {
            RoReq::Bytes { bytes, align } => rodata.add(bytes, align),
            RoReq::Ops(_) => unreachable!("handlers take no operand arrays"),
        })
        .into_iter()
        .map(|v| v.to_arg().expect("a handler argument"))
        .collect();
        let named = |name: &str| ops[op.info().operand_index(name).expect("operand")].clone();
        let then = match op.info().shape {
            Shape::Br => {
                let (Opnd::Neg(neg), Opnd::Target(target)) = (named("neg"), named("t")) else { unreachable!() };
                Then::Branch { neg, target }
            }
            Shape::Switch => Then::Table(switch_targets(op, &ops)),
            Shape::Trap => Then::Trap,
            _ => Then::Next,
        };
        insns.push(Insn::Handler(op, args, then));
    }
    let mut out = Vec::with_capacity(cleanup.len());
    for e in cleanup {
        let at = idx(e.offset).map_err(|_| EncodeError::BadCleanup(e.offset))? as usize;
        let (pad, catch) = match e.action() {
            Cleanup::Pad(p, catch) => (Some(idx(p).map_err(|_| EncodeError::BadCleanup(e.offset))? as usize), catch),
            Cleanup::Continue => (None, false),
        };
        out.push((at, pad, catch));
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
    let heads = loop_heads(&insns, &out, mode.pe);
    Ok(words(&insns, &out, &scopes, &dropped, &heads, frame_size, false))
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

/// Checks a reduced `handler` of the handler `h` against what [`reduce`] gives for it, with
/// arguments `args`, polarity `neg` and targets `ts`: its control flow (returned as the
/// [`Then`]) by `h`'s shape, the registers `h`'s layout sets in `mode`, and a switch's lists
/// against its targets, its case values taken from `code_consts` (returned).
fn check_handler<'c>(h: Opcode, args: &[Arg], neg: bool, ts: Vec<Label>, code_consts: &'c [u8], mode: Mode) -> Result<(Then<Label>, &'c [u8]), ()> {
    let then = match h.info().shape {
        Shape::Br if ts.len() == 1 => Then::Branch { neg, target: ts[0] },
        Shape::Switch if !ts.is_empty() && !neg => Then::Table(ts),
        Shape::Trap if ts.is_empty() && !neg => Then::Trap,
        Shape::Op | Shape::Lpad if ts.is_empty() && !neg => Then::Next,
        _ => return Err(()),
    };
    // The registers the handler's layout sets: `fp` and the exception object where
    // it takes them, and a switch's lists as its table has targets (an edited
    // table must keep them in step).
    let l = super::layout(h, mode);
    let info = h.info();
    if args.len() != l.regs as usize || mode.fp_arg && args[0] != Arg::Fp || info.shape == Shape::Lpad && args[l.first as usize - 1] != Arg::Exception
    {
        return Err(());
    }
    let mut values: &[u8] = &[];
    let mut cases = 0;
    let mut ro_args = 0;
    for (k, o) in info.operands.iter().enumerate() {
        let r = l.locs[k].reg as usize;
        match o.kind {
            OperandKind::List(ElemKind::Target) => match args[r] {
                Arg::Imm(n) => cases += n,
                _ => return Err(()),
            },
            OperandKind::List(e) if let Some(size) = e.case_bytes() => {
                // A sparse switch's case values: as many as its cases, of its
                // value size.
                let (Arg::Ro(off), Arg::Imm(n)) = (args[r], args[r + 1]) else { return Err(()) };
                let len = usize::try_from(n).ok().and_then(|n| n.checked_mul(size)).ok_or(())?;
                values = code_consts.get(off as usize..).and_then(|b| b.get(..len)).ok_or(())?;
                cases += n;
                ro_args += 1;
            }
            _ => {}
        }
    }
    if args.iter().filter(|a| matches!(a, Arg::Ro(_))).count() != ro_args || matches!(&then, Then::Table(ts) if ts.len() as u64 != cases + 1) {
        return Err(());
    }
    Ok((then, values))
}

/// The unwind action of each instruction of `insns` (starting at the word offsets `starts`)
/// by the cleanup entries: only instructions that may unwind have one, at most one each, and
/// a landing pad is an `lpad`.
fn cleanup_actions(cleanup: &[CleanupEntry], starts: &[u32], insns: &[reduced::Insn]) -> Result<Vec<Option<Unwind>>, EncodeError> {
    let idx = |w: u32| starts.binary_search(&w).map_err(|_| EncodeError::BadTarget(w));
    let mut action: Vec<Option<Unwind>> = alloc::vec![None; starts.len()];
    for e in cleanup {
        let bad = EncodeError::BadCleanup(e.offset);
        let i = idx(e.offset).map_err(|_| bad)?;
        if !insns[i].full_opcode().may_unwind() || action[i].is_some() {
            return Err(bad);
        }
        action[i] = Some(match e.action() {
            Cleanup::Continue => Unwind::Continue,
            Cleanup::Pad(p, catch) => {
                let p = idx(p).map_err(|_| bad)?;
                if insns[p].full_opcode() != Opcode::Lpad {
                    return Err(bad);
                }
                Unwind::Pad { pad: Label(p as u32), catch }
            }
        });
    }
    Ok(action)
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
    let mut insns = Vec::new();
    let mut at = 0;
    while at < code.len() {
        let (insn, len) = reduced::Insn::decode(&code[at..]).map_err(EncodeError::Decode)?;
        starts.push(at as u32);
        insns.push(insn);
        at += len;
    }
    let idx = |w: u32| starts.binary_search(&w).map_err(|_| EncodeError::BadTarget(w));
    let label = |at: u32, t: u32| idx(at.wrapping_add(t)).map(|i| Label(i as u32));

    let action = cleanup_actions(cleanup, &starts, &insns)?;

    let mut asm = Asm::new(mode);
    asm.drop_exactly();
    for _ in 0..starts.len() {
        asm.label();
    }
    let region = if mode.pe { pe_region_start(cleanup).map(idx).transpose().map_err(|_| EncodeError::BadRegion(0))? } else { None };
    let mut flow = Vec::with_capacity(if region.is_some() { starts.len() } else { 0 });
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
        if region == Some(i) {
            asm.begin_region();
        }
        asm.bind(Label(i as u32));
        scopes_at(&mut asm, at)?;
        let id = match insns[i] {
            reduced::Insn::Handler { h: reduced::Handler(h), args, neg, t } => {
                let args: Vec<Arg> = args.iter().collect();
                let neg = neg.0;
                let ts = t.iter().map(|t| label(at, t.0 as u32)).collect::<Result<Vec<_>, _>>()?;
                let (then, values) = check_handler(h, &args, neg, ts, code_consts, mode).map_err(|()| EncodeError::BadHandler(at))?;
                if region.is_some() {
                    let (falls, ts) = match &then {
                        Then::Next => (true, Vec::new()),
                        Then::Branch { target, .. } => (true, alloc::vec![target.0 as usize]),
                        Then::Table(ts) => (false, ts.iter().map(|t| t.0 as usize).collect()),
                        Then::Trap => (false, Vec::new()),
                    };
                    flow.push((falls, ts));
                }
                asm.handler(h, &args, values, then)
            }
            ref insn => {
                let f = insn.full_opcode();
                // The full instruction's words, to read its operands.
                full.clear();
                full.extend_from_slice(&code[at as usize..starts.get(i + 1).map_or(code.len(), |&e| e as usize)]);
                full[0] = f as u32;
                if !super::return_ok(&full) || (mode.pe && !super::pe_regs_ok(&full)) {
                    return Err(EncodeError::BadReturn(at));
                }
                if f == Opcode::Arg && insns[..i].iter().any(|a| a.full_opcode() != Opcode::Arg) {
                    return Err(EncodeError::ArgNotFirst(at));
                }
                let ops = operands(&full, 0).into_iter().map(|o| o.map_targets(|t| label(at, t))).collect::<Result<Vec<_>, _>>()?;
                if region.is_some() {
                    let falls = f.info().shape.falls_through();
                    flow.push((falls, ops.iter().flat_map(opnd_labels).collect::<Vec<_>>()));
                }
                asm.insn(f, &ops)
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
    if let Some(r) = region {
        check_region(r, &starts, &flow, &action)?;
    }
    let (e, at) = asm.finish_labels(frame_size, |s| s);
    Ok((e, starts.into_iter().zip(at).collect()))
}
