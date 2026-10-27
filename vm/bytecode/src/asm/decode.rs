//! Machine code back to instruction words: the encoder's test oracle. It accepts only the
//! canonical sequences ([`super::x86`]), with operand registers set in order, and recovers
//! every operand, the frame size and the unwind entries: in the full set ([`decode`]), or in
//! the reduced set ([`decode_reduced`]), which reads handler calls as their register values
//! without the handlers' operand lists. [`decode_linked`] reads linked code, as it sits in
//! memory, to the reduced set: a [`Resolver`] says what its resolved fields point at.

use alloc::vec;
use alloc::vec::Vec;

use super::encode::{
    ArgVal, CallSite, DroppedStore, Encoded, Opnd, Ref, Scope, arg_store, epilogue, fp_item, int_arg, prologue, push_words, result_stores, ret_loads,
    word_len,
};
use super::inline::Cache;
use super::list::{Hint, InsnList};
use super::reduced::{self, Then, addr_arg};
use super::x86::{BadItem, Cond, Cursor, Fields, Item, M, Reg, STACK_ARG, W, handler_reg, island_args};
use super::{ARG_ADDR, ArgReg, Mode, RetPart, has_handler, layout, ret_kind};
use crate::full::{ElemKind, Opcode, OperandKind, Shape, Sym};
use crate::image::{Cleanup, CleanupEntry, op_may_unwind};
use crate::reduced::Arg;

/// A function decoded from machine code.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Decoded {
    pub words: Vec<u32>,
    pub frame_size: u32,
    /// Sorted by offset.
    pub cleanup: Vec<CleanupEntry>,
    /// Sorted, at word offsets ([`Scope`]).
    pub scopes: Vec<Scope>,
    /// The word offsets of the inline instructions whose store the encoder dropped as dead
    /// ([`super::Encoded::dropped`]), sorted: what [`super::encode_reduced`] drops again.
    pub dropped: Vec<u32>,
    /// The word offsets of the loop heads (the targets of backward branches), in order: with
    /// [`Mode::counters`], loop head `n`'s counter stub passes `n` (the OSR entry it asks for).
    pub heads: Vec<u32>,
}

/// Why machine code isn't the canonical form of any function: a description, and the byte
/// position.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct AsmError {
    pub at: u32,
    pub what: &'static str,
}

impl From<BadItem> for AsmError {
    fn from(b: BadItem) -> Self {
        AsmError { at: b.0, what: "not a canonical instruction" }
    }
}

/// An instruction being decoded: operands with byte-position targets, and the positions of
/// its calls that may be call sites.
struct Proto {
    op: Opcode,
    /// Empty for a reduced handler call.
    ops: Vec<Opnd>,
    /// A reduced handler call: its argument registers and its control flow.
    handler: Option<(Vec<Arg>, Then)>,
    /// Position of the instruction (after padding).
    pos: u32,
    sites: Vec<(u32, u32)>,
    /// An inline instruction whose store was dropped.
    dropped: bool,
    /// With counters, a loop head's counter check before it: its stub's position and the
    /// position after the check, where the stub returns to.
    counter: Option<(u32, u32)>,
    /// Its last item is its call (a call storing no result, an island in the pad region),
    /// which on PE a `nop` follows if it has a landing pad (`encode::Asm::bare_calls`).
    bare: bool,
}

impl Proto {
    fn new(op: Opcode, ops: Vec<Opnd>, pos: u32, sites: Vec<(u32, u32)>) -> Proto {
        Proto { op, ops, handler: None, pos, sites, dropped: false, counter: None, bare: false }
    }

    /// The branch targets (byte positions).
    fn targets(&self) -> impl Iterator<Item = u32> + '_ {
        let handler: &[u32] = match &self.handler {
            Some((_, Then::Branch { target, .. })) => core::slice::from_ref(target),
            Some((_, Then::Table(ts))) => ts,
            _ => &[],
        };
        self.ops.iter().flat_map(op_targets).chain(handler).copied()
    }
}

/// A function read from machine code: its instructions, frame size, and the unwind action of
/// each that has one (the landing pad's instruction index, and whether it catches).
struct Read {
    protos: Vec<Proto>,
    frame_size: u32,
    actions: Vec<Option<(Option<usize>, bool)>>,
    /// The scopes, each with the index of the instruction it comes before (the count for
    /// the end).
    scopes: Vec<(usize, Scope)>,
    /// The loop heads' instruction indices, in order.
    heads: Vec<usize>,
    /// Each instruction's byte position, in order.
    ipos: Vec<u32>,
}

/// The index of the instruction at byte position `b` of `ipos` ([`Read::ipos`]), for a
/// target of the instruction at `at`.
fn insn_index(ipos: &[u32], at: u32, b: u32) -> Result<usize, AsmError> {
    ipos.binary_search(&b).map_err(|_| AsmError { at, what: "target isn't an instruction" })
}

/// The side data the decoder reads alongside a function's machine code: its call sites, and
/// the instruction list's dropped stores and scopes, with `index` its branch targets (sorted)
/// and instruction entries (without, the decoder finds the targets in a first pass).
#[derive(Clone, Copy)]
struct Side<'a> {
    call_sites: &'a [CallSite],
    dropped: &'a [DroppedStore],
    scopes: &'a [Scope],
    index: Option<(&'a [u32], &'a [Hint])>,
}

impl<'a> Side<'a> {
    /// `enc`'s side data, without the index.
    fn unindexed(enc: &'a Encoded) -> Side<'a> {
        Side { call_sites: &enc.call_sites, dropped: &enc.dropped, scopes: &enc.scopes, index: None }
    }

    fn of_list(call_sites: &'a [CallSite], list: &'a InsnList) -> Side<'a> {
        Side { call_sites, dropped: &list.dropped, scopes: &list.scopes, index: Some((&list.targets, &list.hints)) }
    }
}

/// Decodes one function's machine code, with its relocations (sorted), rodata, call sites,
/// dropped stores and scopes ([`Encoded`]; not its targets and hints), to the full set.
pub fn decode(enc: &Encoded, mode: Mode) -> Result<Decoded, AsmError> {
    let Read { protos, frame_size, actions, scopes, heads, ipos } =
        read(&enc.code, Fields::Relocs(&enc.relocs), &enc.rodata, Side::unindexed(enc), mode, false)?;
    let mut wpos = Vec::with_capacity(protos.len());
    let mut w = 0u32;
    for p in &protos {
        wpos.push(w);
        w += word_len(p.op, &p.ops) as u32;
    }
    let cleanup = actions
        .iter()
        .enumerate()
        .filter_map(|(i, a)| {
            let (pad, catch) = (*a)?;
            let target = Cleanup::new(pad.map(|j| wpos[j]), catch).to_word();
            Some(CleanupEntry { offset: wpos[i], target })
        })
        .collect();
    let mut words = Vec::with_capacity(w as usize);
    for (i, p) in protos.iter().enumerate() {
        let ops = p
            .ops
            .iter()
            .map(|o| o.clone().map_targets(|b| Ok::<_, AsmError>(wpos[insn_index(&ipos, p.pos, b)?].wrapping_sub(wpos[i]))))
            .collect::<Result<Vec<_>, _>>()?;
        push_words(p.op, &ops, &mut words);
    }
    wpos.push(w);
    let scopes = scopes.into_iter().map(|(i, sc)| Scope { code_offset: wpos[i], ..sc }).collect();
    let dropped = protos.iter().zip(&wpos).filter(|(p, _)| p.dropped).map(|(_, &w)| w).collect();
    let heads = heads.iter().map(|&i| wpos[i]).collect();
    Ok(Decoded { words, frame_size, cleanup, scopes, dropped, heads })
}

/// Decodes one function's machine code, as [`decode`], to the reduced set
/// ([`crate::reduced`]): handler calls are read from their argument registers, without their
/// operand lists, so it doesn't check that they are of operands that aren't inlined.
pub fn decode_reduced(enc: &Encoded, mode: Mode) -> Result<Decoded, AsmError> {
    reduced_of(read(&enc.code, Fields::Relocs(&enc.relocs), &enc.rodata, Side::unindexed(enc), mode, true)?, mode.pe)
}

/// [`decode_reduced`] with all of the instruction list's side data ([`InsnList`]: also
/// `enc`'s targets and hints), which it reads in one pass, using the list's targets and
/// instruction entries as an index that it checks against the code.
pub fn decode_reduced_indexed(enc: &Encoded, mode: Mode) -> Result<Decoded, AsmError> {
    let side = Side { index: Some((&enc.targets, &enc.hints)), ..Side::unindexed(enc) };
    reduced_of(read(&enc.code, Fields::Relocs(&enc.relocs), &enc.rodata, side, mode, true)?, mode.pe)
}

/// What the `rel32` fields of linked code point at, for [`decode_linked`].
pub trait Resolver {
    /// The reference at the absolute address `addr`, the target of a `call`/`jmp rel32` or of
    /// a `[rip + x]` field outside the function: a handler, `ryo_probe_stack`, a function of
    /// the image (by its first byte), a symbol slot, a site cache slot, a constant, a data
    /// offset, or a code constant ([`Ref::Ro`], an offset in [`Resolver::code_consts`]).
    /// `None` if it is none of them.
    fn resolve(&self, addr: u64) -> Option<Ref>;
    /// The bytes [`Ref::Ro`] offsets index: the island operand arrays and switch values the
    /// decoder reads.
    fn code_consts(&self) -> &[u8];
}

/// Decodes one function's linked machine code at address `code_addr` to the reduced set, as
/// [`decode_reduced`], with the references recovered from the resolved fields by `resolver`
/// instead of a relocation list: a field whose target lies inside the function (past its
/// first byte) is a branch or jump table within it, one to `record` is the function's JIT
/// record ([`Ref::Rec`]; `None` without [`Mode::counters`]), any other is the reference
/// `resolver` gives. The dropped stores, scopes and branch targets aren't in the code: they
/// come from the function's instruction list ([`InsnList`], in the image), read as
/// [`decode_reduced_indexed`] does.
pub fn decode_linked(
    code: &[u8],
    code_addr: u64,
    record: Option<u64>,
    resolver: &dyn Resolver,
    call_sites: &[CallSite],
    list: &InsnList,
    mode: Mode,
) -> Result<Decoded, AsmError> {
    let fields = Fields::Linked { addr: code_addr, record, resolver };
    reduced_of(read(code, fields, resolver.code_consts(), Side::of_list(call_sites, list), mode, true)?, mode.pe)
}

/// The reduced instruction words of a function read with handler calls in the reduced form.
fn reduced_of(r: Read, pe: bool) -> Result<Decoded, AsmError> {
    let Read { protos, frame_size, actions, scopes, heads, ipos } = r;
    let index = |at: u32, b: u32| insn_index(&ipos, at, b).map(|i| i as u32);
    let cleanup: Vec<_> = actions.iter().enumerate().filter_map(|(i, a)| a.map(|(pad, catch)| (i, pad, catch))).collect();
    let dropped: Vec<usize> = protos.iter().enumerate().filter(|(_, p)| p.dropped).map(|(i, _)| i).collect();
    let mut insns = Vec::with_capacity(protos.len());
    for p in protos {
        let at = p.pos;
        insns.push(match p.handler {
            Some((args, then)) => {
                let then = match then {
                    Then::Next => Then::Next,
                    Then::Branch { neg, target } => Then::Branch { neg, target: index(at, target)? },
                    Then::Table(ts) => Then::Table(ts.into_iter().map(|t| index(at, t)).collect::<Result<_, _>>()?),
                    Then::Trap => Then::Trap,
                };
                reduced::Insn::Handler(p.op, args, then)
            }
            None => {
                let ops = p.ops.into_iter().map(|o| o.map_targets(|b| index(at, b))).collect::<Result<_, _>>()?;
                reduced::Insn::Native(p.op, ops)
            }
        });
    }
    let d = reduced::words(&insns, &cleanup, &scopes, &dropped, frame_size, pe);
    debug_assert_eq!(d.heads.len(), heads.len());
    Ok(d)
}

/// Reads one function's machine code ([`decode`]), handler calls in the reduced form with
/// `reduced`. With the side data's index, in one pass.
fn read(code: &[u8], fields: Fields<'_>, rodata: &[u8], side: Side<'_>, mode: Mode, reduced: bool) -> Result<Read, AsmError> {
    let Side { call_sites, dropped, scopes, index } = side;
    let mut c = Cursor::new(code, fields);
    let err = |at: u32, what: &'static str| AsmError { at, what };
    // Prologue: the frame size is its `sub`'s (less the 8 bytes in place of the saved `rbp`
    // without a frame pointer), and the prologue must be that size's.
    if !mode.valid() {
        return Err(err(0, "unsupported mode"));
    }
    // With counters, the entry's check comes first: its stub's position, and where the stub
    // returns to.
    let entry = if mode.counters {
        match (c.item(), c.item()) {
            (Ok(Item::CtrInc(false)), Ok(Item::Branch { cond: Cond::Ns, target, .. })) => Some((target, c.pos)),
            _ => return Err(err(0, "no counter check at the entry")),
        }
    } else {
        None
    };
    let start = c.pos;
    let mut alloc = 0;
    loop {
        match c.item() {
            Ok(Item::SubRsp(n)) => alloc = n,
            Ok(Item::PushRbp | Item::Mov(Reg::Rbp, Reg::Rsp) | Item::SetReg(Reg::Rax, _) | Item::Call(Ref::Probe)) => continue,
            _ => {}
        }
        break;
    }
    let frame_size = if mode.frame_pointer { alloc } else { alloc.wrapping_sub(8) };
    if frame_size % 16 != 0 {
        return Err(err(0, "frame size not a multiple of 16"));
    }
    c.pos = start;
    for want in prologue(frame_size, mode) {
        let at = c.pos;
        if c.item().ok() != Some(want) {
            return Err(err(at, "not the prologue of the frame size"));
        }
    }
    if !mode.frame_pointer {
        c.sp_frame = Some(frame_size);
    }
    let fr = Frame { size: frame_size, mode, reduced, region: false };
    let fr_region = Frame { region: true, ..fr };

    // PE: the pad region's entry, `sub rsp, PE_REGION_ALLOC; jmp r11`, right before the first
    // cleanup landing pad (`encode::pe_region_start`); the body (and the counter stubs) end
    // there.
    const ENTRY_LEN: u32 = 7;
    let region_at = match call_sites.iter().filter(|cs| !cs.catch).filter_map(|cs| cs.pad).min() {
        Some(p) if mode.pe => Some(p.checked_sub(ENTRY_LEN).ok_or(err(p, "no pad region entry"))?),
        _ => None,
    };
    let limit = region_at.unwrap_or(code.len() as u32);
    // The side data of each part (all the body's without a region, where what is left over
    // is an error).
    let split = region_at.unwrap_or(u32::MAX);
    let (dropped_body, dropped_region) = dropped.split_at(dropped.partition_point(|d| d.at < split));
    let index_hints = index.map_or(&[][..], |(_, h)| h);
    let (hints_body, hints_region) = index_hints.split_at(index_hints.partition_point(|h| h.at < split));

    // The register cache is cleared at branch targets. With the instruction list, they are
    // known up front, and checked once the function is read. Without, they are only known
    // once the whole function is read, so twice: the first pass only finds the instructions
    // and targets; the second decodes them, with the cache cleared at the targets of the
    // first.
    let body = c.pos;
    let stubs = entry.map(|e| e.0);
    // The body's instructions, and the region's (from its first instruction), read with the
    // targets `targets`; and where the body ends (the counter stubs start).
    let read_parts = |c: &mut Cursor<'_>, targets: Option<&[u32]>, hints: [&[Hint]; 2]| -> Result<(Vec<Proto>, Vec<bool>, u32), AsmError> {
        c.pos = body;
        let (mut protos, mut padded) = instructions(c, &fr, rodata, dropped_body, targets, hints[0], stubs, limit, call_sites)?;
        let body_end = c.pos;
        if !mode.counters && body_end != limit {
            return Err(err(body_end, "an instruction across the pad region's entry"));
        }
        let Some(r) = region_at else { return Ok((protos, padded, body_end)) };
        // The counter stubs come between, checked below.
        c.pos = r;
        if c.item()? != Item::SubRsp(super::PE_REGION_ALLOC) || c.item()? != Item::JmpR11 {
            return Err(err(r, "not the pad region's entry"));
        }
        let (rp, rpad) = instructions(c, &fr_region, rodata, dropped_region, targets, hints[1], None, code.len() as u32, call_sites)?;
        protos.extend(rp);
        padded.extend(rpad);
        Ok((protos, padded, body_end))
    };
    let region_pos = region_at.map_or(u32::MAX, |r| r + ENTRY_LEN);
    let (protos, padded, body_end) = match index {
        Some((targets, _)) => {
            let (protos, padded, rp) = read_parts(&mut c, Some(targets), [hints_body, hints_region])?;
            let mut actual: Vec<u32> = protos.iter().flat_map(Proto::targets).collect();
            actual.sort_unstable();
            actual.dedup();
            if actual != targets {
                let at = actual.iter().zip(targets).find(|(a, t)| a != t).map_or(body, |(&a, &t)| a.min(t));
                return Err(err(at, "branch targets aren't the instruction list's"));
            }
            (protos, padded, rp)
        }
        None => {
            let (protos, _, _) = read_parts(&mut c, None, [&[], &[]])?;
            let mut targets: Vec<u32> = protos.iter().flat_map(Proto::targets).collect();
            targets.sort_unstable();
            read_parts(&mut c, Some(&targets), [&[], &[]])?
        }
    };
    // The index of the region's first instruction (the count without one).
    let rs = if region_at.is_some() { protos.partition_point(|p| p.pos < region_pos) } else { protos.len() };
    if region_at.is_some() && protos.get(rs).is_none_or(|p| p.pos != region_pos) {
        return Err(err(region_pos, "pad region without instructions"));
    }

    // Instruction positions → indices.
    let ipos: Vec<u32> = protos.iter().map(|p| p.pos).collect();
    let index = |at: u32, b: u32| insn_index(&ipos, at, b);
    // When aligning, loop heads start at multiples of 16, and only they are padded. Only
    // single branch targets make loop heads, not jump tables. The pad region has none, and
    // no branch crosses its start.
    let mut head = vec![false; protos.len()];
    for (i, p) in protos.iter().enumerate() {
        for t in p.targets() {
            if (index(p.pos, t)? >= rs) != (i >= rs) {
                return Err(err(p.pos, "a branch across the pad region's start"));
            }
        }
        let single = p.ops.iter().filter_map(|o| match o {
            Opnd::Target(t) => Some(*t),
            _ => None,
        });
        // A handler call's branch, or its table's default (an operand of its own).
        let br = match &p.handler {
            Some((_, Then::Branch { target, .. })) => Some(*target),
            Some((_, Then::Table(ts))) => ts.last().copied(),
            _ => None,
        };
        for t in single.chain(br) {
            let j = index(p.pos, t)?;
            if j <= i && j < rs {
                head[j] = true;
            }
        }
    }
    for i in 0..protos.len() {
        if (padded[i] && !head[i]) || (mode.align_loops && head[i] && ipos[i] % 16 != 0) {
            return Err(err(ipos[i], "loop head padding"));
        }
        if protos[i].counter.is_some() != (mode.counters && head[i]) {
            return Err(err(ipos[i], "counter check not at a loop head"));
        }
    }
    let heads: Vec<usize> = (0..protos.len()).filter(|&i| head[i]).collect();
    // The counter stubs after the body: the loop heads' in order, then the entry's.
    if let Some((entry_stub, entry_back)) = entry {
        c.pos = body_end;
        let checks = heads.iter().map(|&i| protos[i].counter.unwrap());
        for (n, (stub, back)) in checks.chain([(entry_stub, entry_back)]).enumerate() {
            let at = c.pos;
            let bad = err(at, "counter stub");
            if at != stub || c.item()? != Item::Lea(Reg::R11, Ref::Rec) {
                return Err(bad);
            }
            if n < heads.len() {
                if c.item()? != Item::SetReg(Reg::Rax, n as u64) || c.item()? != Item::CallR11(crate::image::JIT_OSR_SLOT) {
                    return Err(bad);
                }
            } else if c.item()? != Item::CallR11(crate::image::JIT_ENTRY_SLOT) {
                return Err(bad);
            }
            match c.item()? {
                Item::Branch { cond: Cond::Always, target, .. } if target == back => {}
                _ => return Err(bad),
            }
        }
        if c.pos != limit {
            return Err(err(c.pos, "code after the counter stubs"));
        }
    }
    // `resume` in the pad region takes the landing pads' exception slot.
    let mut protos = protos;
    if rs < protos.len() {
        resume_slots(&mut protos[..], rs, fr.mode, reduced).map_err(|at| err(at, "resume without a landing pad"))?;
    }

    // Unwind actions from the call sites.
    let mut actions = vec![None; protos.len()];
    let mut used = 0;
    for (i, p) in protos.iter().enumerate() {
        let mut action: Option<(Option<u32>, bool)> = None;
        let mut missing = false;
        for &(s, l) in &p.sites {
            match call_sites.iter().find(|cs| cs.start == s) {
                Some(cs) if cs.len == l => {
                    used += 1;
                    if action.is_some_and(|a| a != (cs.pad, cs.catch)) || (cs.catch && cs.pad.is_none()) {
                        return Err(err(s, "call sites of one instruction disagree"));
                    }
                    action = Some((cs.pad, cs.catch));
                }
                Some(_) => return Err(err(s, "call site length")),
                None => missing = true,
            }
        }
        match action {
            Some(_) if missing => return Err(err(ipos[i], "call sites of one instruction disagree")),
            Some((pad, catch)) => {
                if !op_may_unwind(p.op) {
                    return Err(err(ipos[i], "call site of an instruction that can't unwind"));
                }
                let pad = match pad {
                    None => None,
                    Some(b) => {
                        let j = index(ipos[i], b)?;
                        if protos[j].op != Opcode::Lpad {
                            return Err(err(b, "landing pad isn't an lpad"));
                        }
                        Some(j)
                    }
                };
                actions[i] = Some((pad, catch));
            }
            // The pad region's `resume`, a return with no call site, continues unwinding.
            None if p.op == Opcode::Resume && i >= rs => actions[i] = Some((None, false)),
            None => {}
        }
    }
    if used != call_sites.len() {
        return Err(err(0, "call site outside every call"));
    }
    // Scopes: before the first instruction at or after their position.
    let scopes = scopes.iter().map(|sc| (ipos.partition_point(|&p| p < sc.code_offset), *sc)).collect();
    Ok(Read { protos, frame_size, actions, scopes, heads, ipos })
}

/// Gives each `resume` of the pad region (from instruction `rs` on), which its return doesn't
/// show, the exception slot of the function's landing pads: every `lpad` and `resume` of a
/// function has the same. `Err` with a `resume`'s position if there is no `lpad`.
fn resume_slots(protos: &mut [Proto], rs: usize, mode: Mode, reduced: bool) -> Result<(), u32> {
    let slot = protos.iter().find(|p| p.op == Opcode::Lpad).and_then(|p| match &p.handler {
        // The slot is the lpad's last argument, after `fp` and the exception object.
        Some((args, _)) => match args.last() {
            Some(Arg::Imm(v)) => Some(*v as u32 as i32),
            _ => None,
        },
        None => match p.ops.first() {
            Some(Opnd::Slot(s)) => Some(*s),
            _ => None,
        },
    });
    for p in protos[rs..].iter_mut().filter(|p| p.op == Opcode::Resume) {
        let x = slot.ok_or(p.pos)?;
        if reduced {
            let args = super::encode::handler_args(Opcode::Resume, &[Opnd::<u32>::Slot(x)], mode, |_| 0)
                .into_iter()
                .map(|v| match v {
                    ArgVal::Fp => Arg::Fp,
                    ArgVal::Imm(v, _) => Arg::Imm(v),
                    _ => unreachable!("resume takes fp and a slot"),
                })
                .collect();
            p.handler = Some((args, Then::Trap));
        } else {
            p.ops = vec![Opnd::Slot(x)];
        }
    }
    Ok(())
}

fn read_u32(ro: &[u8], at: u32) -> Option<u32> {
    let b = ro.get(at as usize..)?.get(..4)?;
    Some(u32::from_le_bytes(b.try_into().unwrap()))
}

/// The operand array at `at` in the rodata (its count is the word before).
fn ops_array(ro: &[u8], at: u32) -> Option<Vec<u32>> {
    let n = read_u32(ro, at.checked_sub(4)?)?;
    (0..n).map(|i| read_u32(ro, at.checked_add(i.checked_mul(4)?)?)).collect()
}

/// The branch targets of an operand (byte positions).
fn op_targets(o: &Opnd) -> &[u32] {
    match o {
        Opnd::Target(t) => core::slice::from_ref(t),
        Opnd::Targets(ts) | Opnd::Cases(_, ts) => ts,
        _ => &[],
    }
}

/// The instructions from the cursor to `limit`, and whether each is padded. With `targets`
/// (sorted), the register cache is cleared at them and every inline sequence must be exactly
/// as the cache emits it; without, inline sequences are only delimited ([`inline_insn`]).
/// With counters, the code ends at the counter stubs: at the first loop head's, or without
/// loop heads at the entry's, `entry_stub`. `hints` are the instruction list's instruction
/// entries, each of which must be taken by an inline sequence.
#[allow(clippy::too_many_arguments)]
fn instructions(
    c: &mut Cursor<'_>,
    fr: &Frame,
    ro: &[u8],
    mut dropped: &[DroppedStore],
    targets: Option<&[u32]>,
    mut hints: &[Hint],
    entry_stub: Option<u32>,
    limit: u32,
    call_sites: &[CallSite],
) -> Result<(Vec<Proto>, Vec<bool>), AsmError> {
    let mut protos: Vec<Proto> = Vec::new();
    let mut padded = Vec::new();
    let mut cache = Cache::new(fr.mode.pe);
    let mut end = entry_stub;
    // Whether a loop head's counter check was read.
    let mut counted = false;
    while c.pos < limit && Some(c.pos) != end {
        // A sequence that left no code (its reload hit the cache, its store was dropped) ends
        // the block before a loop head's padding and counter check: none can start at a
        // target, where the cache is empty.
        if dropped.first().is_some_and(|d| d.at == c.pos) {
            let pos = c.pos;
            if let Some(p) = inline_insn(c, &mut cache, &mut dropped, &mut hints, targets.is_some()) {
                padded.push(false);
                protos.push(Proto { pos, ..p });
                continue;
            }
        }
        let pad = c.padding();
        if pad != 0 && (fr.region || !fr.mode.align_loops || pad >= 16 || c.pos % 16 != 0) {
            return Err(AsmError { at: c.pos, what: "padding" });
        }
        padded.push(pad != 0);
        if targets.is_some_and(|t| t.binary_search(&c.pos).is_ok()) {
            cache = Cache::new(fr.mode.pe);
        }
        // A loop head's counter check.
        let pos = c.pos;
        let mut counter = None;
        if fr.mode.counters && !fr.region {
            let at = c.pos;
            match (c.item(), c.item()) {
                (Ok(Item::CtrInc(true)), Ok(Item::Branch { cond: Cond::Ns, target, .. })) => {
                    counter = Some((target, c.pos));
                    if !counted {
                        end = Some(target);
                        counted = true;
                    }
                }
                _ => c.pos = at,
            }
        }
        let p = 'p: {
            // `arg`s come first.
            if protos.iter().all(|p| p.op == Opcode::Arg)
                && let Some(p) = arg(c, fr.mode)
            {
                break 'p p;
            }
            if let Some(p) = call_insn(c, fr, dropped) {
                cache = Cache::new(fr.mode.pe);
                break 'p p;
            }
            match inline_insn(c, &mut cache, &mut dropped, &mut hints, targets.is_some()) {
                Some(p) => p,
                None => {
                    cache = Cache::new(fr.mode.pe);
                    insn(c, fr, ro)?
                }
            }
        };
        // PE: the `nop` after a call with a landing pad that ends its instruction.
        if fr.mode.pe && p.bare && p.sites.iter().any(|&(at, _)| call_sites.iter().any(|cs| cs.start == at && cs.pad.is_some())) {
            if !c.nop1() {
                return Err(AsmError { at: c.pos, what: "no nop after a call with a landing pad" });
            }
        }
        protos.push(Proto { pos, counter, ..p });
    }
    if let Some(d) = dropped.first() {
        return Err(AsmError { at: d.at, what: "dropped store not at the end of a sequence" });
    }
    if let Some(h) = hints.first() {
        return Err(AsmError { at: h.at, what: "instruction list entry not at its inline sequence" });
    }
    Ok((protos, padded))
}

/// The frame size and the mode, which the prologue, the epilogue and `fp` depend on, and
/// whether handler calls are read in the reduced form.
struct Frame {
    size: u32,
    mode: Mode,
    reduced: bool,
    /// In the pad region (PE, design/vm.md#unwinding).
    region: bool,
}

impl Frame {
    fn epilogue(&self) -> Vec<Item> {
        epilogue(self.size, self.mode)
    }

    /// Reads the epilogue at the cursor (the cursor after it), or `None` (the cursor moved).
    fn read_epilogue(&self, c: &mut Cursor<'_>) -> Option<()> {
        for want in self.epilogue() {
            if c.item().ok()? != want {
                return None;
            }
        }
        Some(())
    }

    /// `reg = fp`, as [`Cursor::item`] returns it: without a frame pointer, `lea reg,
    /// [rsp + F]` is `lea reg, [rbp + 0]`.
    fn fp(&self, reg: Reg) -> Item {
        match fp_item(reg, self.size, self.mode) {
            Item::LeaM { dst, .. } => Item::LeaM { dst, m: M::frame(0) },
            it => it,
        }
    }
}

/// Reads one instruction that isn't inline.
fn insn(c: &mut Cursor<'_>, fr: &Frame, ro: &[u8]) -> Result<Proto, AsmError> {
    let pos = c.pos;
    let err = |at: u32, what: &'static str| AsmError { at, what };
    if let Some(p) = dense_switch(c, fr)? {
        return Ok(p);
    }
    let mut setup = Vec::new();
    let head = loop {
        let at = c.pos;
        match c.item()? {
            it @ (Item::SetReg(..) | Item::Lea(..) | Item::Mov(..) | Item::LeaM { .. }) => setup.push((at, it)),
            it @ Item::StImm { w: W::D, m: STACK_ARG, .. } if fr.mode.pe => setup.push((at, it)),
            it => break (at, it),
        }
    };
    let (hat, head) = head;
    let mut sites = Vec::new();
    let ops = match head {
        Item::Call(Ref::Handler(op)) if has_handler(op) && fr.reduced => {
            let args = handler_args(&setup, fr, pos)?;
            // A switch's table has an entry per case, from the register its handler takes the
            // count in, and the default.
            let l = layout(op, fr.mode);
            let n = op.info().operands.iter().zip(l.locs).find_map(|(o, loc)| match o.kind {
                OperandKind::List(ElemKind::Target) => Some(loc.reg),
                OperandKind::List(e) if e.is_case() => Some(loc.reg + 1),
                _ => None,
            });
            let n = match n.map(|r| args.get(r as usize)) {
                None => 0,
                Some(Some(Arg::Imm(n))) if *n < 1 << 31 => *n as usize,
                Some(_) => return Err(err(pos, "case count")),
            };
            let then = then(c, op, n, hat, &mut sites)?;
            Proto { op, ops: Vec::new(), handler: Some((args, then)), pos, sites, dropped: false, counter: None, bare: false }
        }
        Item::Call(Ref::Handler(op)) if has_handler(op) => {
            let mut ops = handler_operands(op, &setup, fr, ro, c.code.len(), pos)?;
            let info = op.info();
            let set = |ops: &mut Vec<Opnd>, name: &str, v: Opnd| ops[info.operand_index(name).unwrap()] = v;
            let n = ops.iter().find_map(|o| match o {
                Opnd::Targets(t) | Opnd::Cases(_, t) => Some(t.len()),
                _ => None,
            });
            match then(c, op, n.unwrap_or(0), hat, &mut sites)? {
                Then::Next | Then::Trap => {}
                Then::Branch { neg, target } => {
                    set(&mut ops, "neg", Opnd::Neg(neg));
                    set(&mut ops, "t", Opnd::Target(target));
                }
                Then::Table(mut t) => {
                    set(&mut ops, "default", Opnd::Target(t.pop().unwrap()));
                    for o in &mut ops {
                        if let Opnd::Targets(ts) | Opnd::Cases(_, ts) = o {
                            *ts = t.clone();
                        }
                    }
                }
            }
            if super::inline::sequence(op, &ops).is_some() {
                return Err(err(hat, "handler call of an inlined instruction"));
            }
            Proto::new(op, ops, pos, sites)
        }
        // `resume` in the pad region: its slot is the landing pads' ([`resume_slots`]).
        Item::AddRsp(super::PE_REGION_ALLOC) if fr.region && setup.is_empty() => {
            let at = c.pos;
            if c.item()? != Item::Ret {
                return Err(err(at, "not the pad region's return"));
            }
            let mut p = Proto::new(Opcode::Resume, vec![Opnd::Slot(0)], pos, sites);
            if fr.reduced {
                p.ops.clear();
                p.handler = Some((Vec::new(), Then::Trap));
            }
            p
        }
        Item::Ld { .. } | Item::Sse { .. } | Item::Leave | Item::PopRbp | Item::AddRsp(_) if setup.is_empty() => {
            c.pos = pos;
            let (s, k) = ret(c, fr)?;
            Proto::new(Opcode::Ret, vec![Opnd::Slot(s), Opnd::Imm(k as u64)], pos, sites)
        }
        // A handler call's `ud2` is read with it (`then`): a bare one is `unreachable`.
        Item::Ud2 if setup.is_empty() => Proto::new(Opcode::Unreachable, Vec::new(), pos, sites),
        Item::Branch { cond: Cond::Always, target, .. } if setup.is_empty() => Proto::new(Opcode::Jmp, vec![Opnd::Target(target)], pos, sites),
        Item::CallMem(_) => {
            // An island: `fp`, `ops`, the call through the slot.
            c.pos = pos;
            let (isl, ops_ro, site) = island_call(c, fr)?;
            sites.push(site);
            let ws = ops_array(ro, ops_ro).ok_or(err(pos, "island operands"))?;
            Proto { bare: fr.mode.pe, ..Proto::new(Opcode::Island, vec![Opnd::Sym(isl), Opnd::Words(ws)], pos, sites) }
        }
        _ => return Err(err(hat, "not an instruction")),
    };
    Ok(ops)
}

/// The items at the cursor while `f` takes them (the cursor after the last one taken).
fn take(c: &mut Cursor<'_>, mut f: impl FnMut(&Item) -> bool) -> Vec<Item> {
    let mut out = Vec::new();
    loop {
        let a = c.pos;
        match c.item() {
            Ok(it) if f(&it) => out.push(it),
            _ => {
                c.pos = a;
                return out;
            }
        }
    }
}

/// The register parts the loads (`ret`) or stores (a call's result) `items` move, relative to
/// the slot of the first: the slot and the parts, or `None` if they aren't parts. Integer
/// parts take the sizes of their pieces together.
fn parts_of(items: &[Item]) -> Option<(i32, Vec<RetPart>)> {
    let mut parts: Vec<RetPart> = Vec::new();
    let mut base = None;
    let mut it = items.iter().peekable();
    // The offset of the frame slot `m` from the first part's.
    let mut off = |m: M| -> Option<u32> {
        let b = *base.get_or_insert(m.disp);
        (m.base == Reg::Rbp).then_some(m.disp.wrapping_sub(b) as u32)
    };
    let mut last_int = None;
    while let Some(&x) = it.next() {
        match x {
            Item::Ld { sx: false, dst: Reg::Rax | Reg::Rdx, w, m } => {
                parts.push(RetPart { xmm: false, size: w.bytes(), off: off(m)? });
            }
            Item::St { src: r @ (Reg::Rax | Reg::Rdx), w, m } => {
                let o = off(m)?;
                match parts.last_mut() {
                    // The next piece of the same register, after its shift.
                    Some(p) if !p.xmm && last_int == Some(r) && p.off.checked_add(p.size) == Some(o) => p.size += w.bytes(),
                    _ => parts.push(RetPart { xmm: false, size: w.bytes(), off: o }),
                }
                last_int = Some(r);
                continue;
            }
            Item::Shift { reg, .. } if last_int == Some(reg) => continue,
            Item::Sse { size, m, .. } => parts.push(RetPart { xmm: true, size: size as u32, off: off(m)? }),
            Item::Ld { w: super::x86::W::W, sx: false, dst: Reg::R11, m } => {
                it.next()?;
                parts.push(RetPart { xmm: true, size: 2, off: off(m)? });
            }
            Item::Movd { to_xmm: false, .. } => {
                let Some(&&Item::St { m, .. }) = it.peek() else { return None };
                it.next();
                parts.push(RetPart { xmm: true, size: 2, off: off(m)? });
            }
            _ => return None,
        }
        last_int = None;
    }
    Some((base.unwrap_or(0), parts))
}

/// `ret`'s sequence at the cursor: the loads of the value into the return registers, the
/// epilogue and `ret`. Returns the slot and the kind (slot 0 for nothing returned).
fn ret(c: &mut Cursor<'_>, fr: &Frame) -> Result<(i32, u32), AsmError> {
    let at = c.pos;
    let bad = AsmError { at, what: "return value loads" };
    let items = take(c, |it| matches!(it, Item::Ld { .. } | Item::Sse { st: false, .. } | Item::Movd { to_xmm: true, .. }));
    let (s, parts) = parts_of(&items).filter(|(_, p)| p.len() <= 2).ok_or(bad)?;
    let k = ret_kind(&parts);
    if ret_loads(k, s) != items || super::ret_parts(k, true).is_none() && k != 0 {
        return Err(bad);
    }
    for want in fr.epilogue().into_iter().chain([Item::Ret]) {
        let a = c.pos;
        if c.item()? != want {
            return Err(AsmError { at: a, what: "not the return sequence" });
        }
    }
    Ok((s, k))
}

/// A call's result stores from the return registers at the cursor, if any: the destination
/// and the kind (slot 0 for none).
fn result(c: &mut Cursor<'_>) -> (i32, u32) {
    let at = c.pos;
    let items = take(c, |it| {
        matches!(
            it,
            Item::St { src: Reg::Rax | Reg::Rdx | Reg::R11, .. }
                | Item::Shift { reg: Reg::Rax | Reg::Rdx, .. }
                | Item::Sse { st: true, .. }
                | Item::Movd { to_xmm: false, .. }
        )
    });
    if let Some((d, parts)) = parts_of(&items).filter(|(_, p)| p.len() <= 2) {
        let k = ret_kind(&parts);
        if super::ret_parts(k, false).is_some() && result_stores(k, d) == items {
            return (d, k);
        }
    }
    c.pos = at;
    (0, 0)
}

/// The integer argument register index of `r` in the mode's convention.
fn int_index(r: Reg, mode: Mode) -> Option<u32> {
    (0..if mode.pe { 4 } else { 6 }).find(|&i| int_arg(mode.pe, i) == r)
}

/// A call's argument registers' loads at the cursor ([`super::params_ok`]): (slot, register)
/// pairs.
fn params(c: &mut Cursor<'_>, mode: Mode) -> Vec<u32> {
    let mut out = Vec::new();
    loop {
        let at = c.pos;
        let (s, w) = match c.item() {
            Ok(Item::Ld { w, sx: false, dst, m }) if m.base == Reg::Rbp && int_index(dst, mode).is_some() => {
                (m.disp, ArgReg { xmm: false, size: w.bytes(), index: int_index(dst, mode).unwrap() }.word())
            }
            Ok(Item::LeaM { dst, m }) if m.base == Reg::Rbp && int_index(dst, mode).is_some() => {
                (m.disp, ArgReg { xmm: false, size: 8, index: int_index(dst, mode).unwrap() }.word() | ARG_ADDR)
            }
            Ok(Item::Sse { st: false, size, x, m }) => (m.disp, ArgReg { xmm: true, size: size as u32, index: x as u32 }.word()),
            Ok(Item::Ld { w: super::x86::W::W, sx: false, dst: Reg::R11, m }) if m.base == Reg::Rbp => match c.item() {
                Ok(Item::Movd { to_xmm: true, x, r: Reg::R11 }) => (m.disp, ArgReg { xmm: true, size: 2, index: x as u32 }.word()),
                _ => {
                    c.pos = at;
                    return out;
                }
            },
            _ => {
                c.pos = at;
                return out;
            }
        };
        out.extend([s as u32, w]);
    }
}

/// A call or tail call at the cursor, which have no handler: the callee's address (`call.ptr`,
/// `call.sym.ind`, `tail_call.ptr`), the argument registers' loads, then the call and the
/// result's stores, or the epilogue and the jump. `None`, with the cursor unmoved, if there
/// is none, or if a dropped store of an inline sequence lies within it (that sequence's
/// loads aren't arguments).
fn call_insn(c: &mut Cursor<'_>, fr: &Frame, dropped: &[DroppedStore]) -> Option<Proto> {
    enum Pre {
        None,
        Sym(Sym),
        Ptr(i32),
    }
    let pos = c.pos;
    let a = c.pos;
    let pre = match c.item() {
        Ok(Item::LoadRip(Reg::Rax, Ref::Sym(s))) => Pre::Sym(s),
        Ok(Item::Ld { w: super::x86::W::Q, sx: false, dst: Reg::Rax, m }) if m.base == Reg::Rbp => Pre::Ptr(m.disp),
        _ => {
            c.pos = a;
            Pre::None
        }
    };
    let ps = params(c, fr.mode);
    let call_at = c.pos;
    let fail = |c: &mut Cursor<'_>| {
        c.pos = pos;
        None
    };
    if dropped.first().is_some_and(|d| d.at < call_at) {
        return fail(c);
    }
    let a_op = Opnd::Words(ps);
    let item = c.item();
    let (op, mut ops, call) = match (item, &pre) {
        (Ok(Item::Call(Ref::Func(f))), Pre::None) => (Opcode::Call, vec![Opnd::Func(f)], true),
        (Ok(Item::CallMem(Ref::Sym(s))), Pre::None) => (Opcode::CallSym, vec![Opnd::Sym(s)], true),
        (Ok(Item::CallMemRax), Pre::Sym(s)) => (Opcode::CallSymInd, vec![Opnd::Sym(*s)], true),
        (Ok(Item::CallRax), Pre::Ptr(p)) => (Opcode::CallPtr, vec![Opnd::Slot(*p)], true),
        _ => {
            // A tail call: the epilogue and the jump.
            c.pos = call_at;
            if fr.read_epilogue(c).is_none() {
                return fail(c);
            }
            match (c.item(), &pre) {
                (Ok(Item::Jmp(Ref::Func(f))), Pre::None) => (Opcode::TailCall, vec![Opnd::Func(f), a_op.clone()], false),
                (Ok(Item::JmpRax), Pre::Ptr(p)) => (Opcode::TailCallPtr, vec![Opnd::Slot(*p), a_op.clone()], false),
                _ => return fail(c),
            }
        }
    };
    let mut sites = Vec::new();
    let mut bare = false;
    if call {
        sites.push((call_at, c.pos - call_at));
        let (d, k) = result(c);
        bare = k == 0;
        ops.insert(0, Opnd::Slot(d));
        ops.extend([Opnd::Imm(k as u64), a_op]);
    }
    Some(Proto { bare, ..Proto::new(op, ops, pos, sites) })
}

/// An `arg` at the cursor: the store of an argument register to its slot.
fn arg(c: &mut Cursor<'_>, mode: Mode) -> Option<Proto> {
    let pos = c.pos;
    let (a, m) = match c.item().ok()? {
        Item::St { w, src, m } => {
            // An integer of 3, 5, 6 or 7 bytes: its pieces, shifting the register down.
            let mut size = w.bytes();
            loop {
                let at = c.pos;
                match (c.item(), c.item()) {
                    (Ok(Item::Shift { reg, .. }), Ok(Item::St { w, src: s, m: m2 }))
                        if reg == src && s == src && m2.disp == m.disp.wrapping_add(size as i32) =>
                    {
                        size += w.bytes()
                    }
                    _ => {
                        c.pos = at;
                        break;
                    }
                }
            }
            (int_index(src, mode).map(|index| ArgReg { xmm: false, size, index }), m)
        }
        Item::Sse { st: true, size, x, m } => (Some(ArgReg { xmm: true, size: size as u32, index: x as u32 }), m),
        Item::Movd { to_xmm: false, x, r: Reg::R11 } => match c.item().ok()? {
            Item::St { m, .. } => (Some(ArgReg { xmm: true, size: 2, index: x as u32 }), m),
            _ => (None, M::frame(0)),
        },
        _ => (None, M::frame(0)),
    };
    let end = c.pos;
    c.pos = pos;
    let a = a.filter(|a| ArgReg::of(a.word(), true).is_some() && m.base == Reg::Rbp)?;
    for w in arg_store(a, m.disp, mode.pe) {
        if c.item().ok() != Some(w) {
            c.pos = pos;
            return None;
        }
    }
    if c.pos != end {
        c.pos = pos;
        return None;
    }
    Some(Proto::new(Opcode::Arg, vec![Opnd::Slot(m.disp), Opnd::Imm(a.word() as u64)], pos, Vec::new()))
}

/// An inline sequence at the cursor, or `None` (the cursor unmoved) if there is none: native
/// items up to the one that writes the result (or its dropped store, taken from `dropped`),
/// or up to a conditional branch, which must be the sequence as the register cache `cache`
/// emits it (updated to after it). Unless `exact`, they are only read for their extent and
/// branch target, as a `jmp` or an `abort`. An instruction list entry at the sequence
/// (the first of `hints`, which it takes) names its instruction and how the cache emitted it.
fn inline_insn(c: &mut Cursor<'_>, cache: &mut Cache, dropped: &mut &[DroppedStore], hints: &mut &[Hint], exact: bool) -> Option<Proto> {
    let pos = c.pos;
    let left = *dropped;
    let mut items = Vec::new();
    let mut branch = None;
    let mut was_dropped = false;
    loop {
        // A dropped store ends the sequence where it would have been, but for an overflow
        // op's result store, which its flag follows.
        if let Some(d) = dropped.first()
            && d.at == c.pos
        {
            items.push(d.item);
            was_dropped = true;
            *dropped = &dropped[1..];
            let next = c.item().ok();
            c.pos = d.at;
            if !matches!(next, Some(Item::SetccCl(_))) {
                break;
            }
            continue;
        }
        match c.item() {
            Ok(it) if it.is_inline() => {
                let at = c.pos;
                let next = c.item().ok();
                c.pos = at;
                let ended = it.ends_inline_at(items.last(), next.as_ref());
                items.push(it);
                if ended {
                    break;
                }
            }
            Ok(Item::Branch { cond, target, .. }) if cond != Cond::Always && !items.is_empty() => {
                branch = Some((cond, target));
                break;
            }
            _ => {
                c.pos = pos;
                *dropped = left;
                return None;
            }
        }
    }
    if !exact {
        // Only its extent and its branch target matter.
        let (op, ops) = match branch {
            Some((_, t)) => (Opcode::Jmp, vec![Opnd::Target(t)]),
            None => (Opcode::Abort, Vec::new()),
        };
        return Some(Proto::new(op, ops, pos, Vec::new()));
    }
    // The sequence the instruction list names, and only it.
    if let Some(h) = hints.first().filter(|h| h.at == pos) {
        let cand = cache.invert(&items, h.sel).and_then(|cand| Some((super::inline::decode_op(h.op, &cand, branch)?, cand)));
        if let Some(((op, ops), cand)) = cand {
            let mut after = *cache;
            if after.emit(&cand) == items {
                *cache = after;
                *hints = &hints[1..];
                return Some(Proto { dropped: was_dropped, ..Proto::new(op, ops, pos, Vec::new()) });
            }
        }
        c.pos = pos;
        *dropped = left;
        return None;
    }
    // As emitted with an empty cache, the common case, else the sequences the cache may
    // have emitted this from.
    // (`None`: `items` itself.)
    let plain = super::inline::decode(&items, branch).map(|d| (d, None));
    let cands = plain.into_iter().chain(cache.unemit(&items).into_iter().filter_map(|c| Some((super::inline::decode(&c, branch)?, Some(c)))));
    for ((op, ops), cand) in cands {
        let mut after = *cache;
        if after.emit(cand.as_deref().unwrap_or(&items)) != items {
            continue;
        }
        *cache = after;
        return Some(Proto { dropped: was_dropped, ..Proto::new(op, ops, pos, Vec::new()) });
    }
    c.pos = pos;
    *dropped = left;
    None
}

/// A dense switch whose index computation ([`super::inline::dense_index`]) stands in for its
/// handler call, with its jump table, or `None` (the cursor unmoved) if there is none at the
/// cursor.
fn dense_switch(c: &mut Cursor<'_>, fr: &Frame) -> Result<Option<Proto>, AsmError> {
    use super::x86::{Alu, Rm, W};
    let pos = c.pos;
    let mut items = Vec::new();
    // The items up to the table's `lea`: at most six.
    loop {
        let at = c.pos;
        match c.item() {
            Ok(Item::LeaTable(_)) if !items.is_empty() => {
                c.pos = at;
                break;
            }
            Ok(it @ (Item::Ld { .. } | Item::AluImm { .. } | Item::SetReg(..) | Item::Alu { .. } | Item::Cmov { .. })) if items.len() < 6 => {
                items.push(it)
            }
            _ => {
                c.pos = pos;
                return Ok(None);
            }
        }
    }
    let none = |c: &mut Cursor<'_>| {
        c.pos = pos;
        Ok(None)
    };
    let (Some(&Item::Ld { w, m, .. }), Some(&Item::Cmov { .. })) = (items.first(), items.last()) else { return none(c) };
    let op = match w {
        W::B => Opcode::SwitchDenseW8,
        W::W => Opcode::SwitchDenseW16,
        W::D => Opcode::SwitchDenseW32,
        W::Q => Opcode::SwitchDenseW64,
    };
    let base = match items[1] {
        Item::AluImm { op: Alu::Sub, imm, .. } => match w {
            W::B => imm as u8 as u64,
            W::W => imm as u16 as u64,
            W::D => imm as u32 as u64,
            W::Q => imm as i64 as u64,
        },
        Item::SetReg(Reg::Rcx, v) if matches!(items[2], Item::Alu { op: Alu::Sub, rm: Rm::Reg(Reg::Rcx), .. }) => v,
        _ => 0,
    };
    let Some(&Item::SetReg(Reg::Rcx, n)) = items.get(items.len().wrapping_sub(3)) else { return none(c) };
    if super::inline::dense_index(op, m.disp, base, n).as_deref() != Some(&items[..]) || m.base != Reg::Rbp {
        return none(c);
    }
    let mut ts = table(c, n as usize + 1)?;
    Ok(Some(if fr.reduced {
        let l = layout(op, fr.mode);
        let mut args = vec![Arg::Imm(0); l.regs as usize];
        if fr.mode.fp_arg {
            args[0] = Arg::Fp;
        }
        for (k, o) in op.info().operands.iter().enumerate() {
            let v = match o.name {
                "s" => m.disp as u32 as u64,
                "base" => base,
                "table" => n,
                _ => continue,
            };
            args[l.locs[k].reg as usize] = Arg::Imm(v);
        }
        Proto { op, ops: Vec::new(), handler: Some((args, Then::Table(ts))), pos, sites: Vec::new(), dropped: false, counter: None, bare: false }
    } else {
        let default = ts.pop().expect("a default");
        Proto::new(op, vec![Opnd::Slot(m.disp), Opnd::Imm(base), Opnd::Target(default), Opnd::Targets(ts)], pos, Vec::new())
    }))
}

/// The jump table sequence and its `n` entries.
fn table(c: &mut Cursor<'_>, n: usize) -> Result<Vec<u32>, AsmError> {
    let at = c.pos;
    let bad = AsmError { at, what: "jump table" };
    let Item::LeaTable(t) = c.item()? else { return Err(bad) };
    if c.item()? != Item::LoadTableEntry || c.item()? != Item::AddRaxRcx || c.item()? != Item::JmpRax {
        return Err(bad);
    }
    c.table_padding()?;
    if c.pos != t {
        return Err(bad);
    }
    (0..n).map(|_| Ok(c.table_entry(t)?)).collect()
}

/// An island call sequence: its symbol slot, the rodata offset of its operands, and the call
/// site (position, length).
fn island_call(c: &mut Cursor<'_>, fr: &Frame) -> Result<(crate::full::Sym, u32, (u32, u32)), AsmError> {
    let mode = fr.mode;
    let at = c.pos;
    let bad = AsmError { at, what: "island call" };
    let [fp, opsr] = island_args(mode.pe);
    if c.item()? != fr.fp(fp) {
        return Err(bad);
    }
    let Item::Lea(r, Ref::Ro(ops)) = c.item()? else { return Err(bad) };
    if r != opsr {
        return Err(bad);
    }
    let site = c.pos;
    let Item::CallMem(Ref::Sym(isl)) = c.item()? else { return Err(bad) };
    Ok((isl, ops, (site, 6)))
}

/// The control flow after `op`'s handler call at the cursor, its shape's: for a switch, a
/// table of `n` cases and the default. `hat` is the call's position, a call site for
/// `resume`.
fn then(c: &mut Cursor<'_>, op: Opcode, n: usize, hat: u32, sites: &mut Vec<(u32, u32)>) -> Result<Then, AsmError> {
    let err = |at: u32, what: &'static str| AsmError { at, what };
    let fixed = |c: &mut Cursor<'_>, want: Item| -> Result<(), AsmError> {
        let at = c.pos;
        if c.item()? != want { Err(err(at, "not the instruction's canonical sequence")) } else { Ok(()) }
    };
    Ok(match op.info().shape {
        Shape::Op | Shape::Lpad => Then::Next,
        Shape::Br => {
            fixed(c, Item::TestAl)?;
            let at = c.pos;
            let Item::Branch { cond: cond @ (Cond::Z | Cond::Nz), target, .. } = c.item()? else {
                return Err(err(at, "branch"));
            };
            Then::Branch { neg: cond == Cond::Z, target }
        }
        Shape::Switch => Then::Table(table(c, n + 1)?),
        Shape::Trap => {
            if op == Opcode::Resume {
                sites.push((hat, 5));
            }
            fixed(c, Item::Ud2)?;
            Then::Trap
        }
        Shape::Jmp | Shape::Call | Shape::TailCall | Shape::Ret | Shape::Island | Shape::Arg => unreachable!(),
    })
}

/// The argument registers of a handler call from the register setup before it (positions
/// and items): each sets the next position ([`super::handler_arg`]), to `fp`, the exception
/// object, a value or an address; PE's stack argument to a 32-bit value.
fn handler_args(setup: &[(u32, Item)], fr: &Frame, pos: u32) -> Result<Vec<Arg>, AsmError> {
    let mut out = Vec::with_capacity(setup.len());
    let max = if fr.mode.pe { super::PE_ARG_REGS + 1 } else { super::ARG_REGS };
    for (i, &(at, it)) in setup.iter().enumerate() {
        if i >= max {
            return Err(AsmError { at, what: "too many argument registers" });
        }
        let Some(r) = handler_reg(fr.mode.pe, i as u8) else {
            let Item::StImm { w: W::D, m: STACK_ARG, imm } = it else { return Err(AsmError { at: pos, what: "operand registers out of order" }) };
            out.push(Arg::Imm(imm as u32 as u64));
            continue;
        };
        out.push(match it {
            it if it == fr.fp(r) => Arg::Fp,
            Item::Mov(g, Reg::Rax) if g == r => Arg::Exception,
            Item::SetReg(g, v) if g == r => Arg::Imm(v),
            Item::Lea(g, to) if g == r && addr_arg(to).is_some() => addr_arg(to).unwrap(),
            _ => return Err(AsmError { at: pos, what: "operand registers out of order" }),
        });
    }
    Ok(out)
}

/// The operands of `op`'s handler call from the register setup before it (positions and
/// items), in a function of `code_len` bytes; operands handlers don't receive are left as
/// placeholders.
fn handler_operands(op: Opcode, setup: &[(u32, Item)], fr: &Frame, ro: &[u8], code_len: usize, pos: u32) -> Result<Vec<Opnd>, AsmError> {
    let mode = fr.mode;
    let err = |what: &'static str| AsmError { at: pos, what };
    let l = layout(op, mode);
    let info = op.info();
    let mut it = setup.iter().map(|s| s.1);
    let reg = |i: u8| handler_reg(mode.pe, i);
    if mode.fp_arg && it.next() != reg(0).map(|r| fr.fp(r)) {
        return Err(err("no fp argument"));
    }
    if info.shape == Shape::Lpad && it.next() != reg(l.first - 1).map(|r| Item::Mov(r, Reg::Rax)) {
        return Err(err("no exception object"));
    }
    let mut regs: Vec<Option<ArgVal>> = vec![None; l.regs as usize];
    for r in l.first..l.regs {
        regs[r as usize] = Some(match (it.next(), reg(r)) {
            (Some(Item::SetReg(g, v)), Some(want)) if g == want => ArgVal::Imm(v, 0),
            (Some(Item::Lea(g, to)), Some(want)) if g == want => ArgVal::Addr(to),
            // PE's stack argument, a 32-bit operand.
            (Some(Item::StImm { w: W::D, m: STACK_ARG, imm }), None) => ArgVal::Imm(imm as u32 as u64, 0),
            _ => return Err(err("operand registers out of order")),
        });
    }
    if it.next().is_some() {
        return Err(err("extra operand registers"));
    }
    let imm = |r: u8| match regs[r as usize] {
        Some(ArgVal::Imm(v, _)) => Ok(v),
        _ => Err(err("an address where a value belongs")),
    };
    let addr = |r: u8| match regs[r as usize] {
        Some(ArgVal::Addr(to)) => Ok(to),
        _ => Err(err("a value where an address belongs")),
    };
    // A shared register: the other half must belong to the paired operand, which reads it.
    let mut ops = Vec::with_capacity(info.operands.len());
    for (i, o) in info.operands.iter().enumerate() {
        let loc = l.locs[i];
        let narrow = |v: u64, bits: u32| -> Result<u64, AsmError> {
            let v = loc.field(v);
            if bits < 64 && v >> bits != 0 { Err(err("immediate out of range")) } else { Ok(v) }
        };
        if loc.count == 0 {
            ops.push(match o.kind {
                OperandKind::Slot => Opnd::Slot(0),
                OperandKind::Func => Opnd::Func(crate::full::Func(0)),
                OperandKind::Sym => Opnd::Sym(crate::full::Sym(0)),
                OperandKind::U32 => Opnd::Imm(0),
                OperandKind::Target => Opnd::Target(0),
                OperandKind::Neg => Opnd::Neg(false),
                OperandKind::List(ElemKind::Target) => Opnd::Targets(Vec::new()),
                _ => return Err(err("operand without a register")),
            });
            continue;
        }
        ops.push(match o.kind {
            OperandKind::Slot => Opnd::Slot(narrow(imm(loc.reg)?, 32)? as u32 as i32),
            OperandKind::U8 => Opnd::Imm(narrow(imm(loc.reg)?, 8)?),
            OperandKind::U16 => Opnd::Imm(narrow(imm(loc.reg)?, 16)?),
            OperandKind::U32 => Opnd::Imm(narrow(imm(loc.reg)?, 32)?),
            OperandKind::U64 | OperandKind::I64 => Opnd::Imm(imm(loc.reg)?),
            OperandKind::U128 => Opnd::Imm128(imm(loc.reg)? as u128 | (imm(loc.reg + 1)? as u128) << 64),
            OperandKind::Mem => {
                let (p, k) = (narrow(imm(loc.reg)?, 32)?, imm(loc.reg + 1)?);
                if k >> 32 != 0 {
                    return Err(err("immediate out of range"));
                }
                Opnd::Mem(p as u32 as i32, k as u32 as i32)
            }
            OperandKind::Const => match addr(loc.reg)? {
                Ref::Const(k) => Opnd::Const(k),
                _ => return Err(err("not a constant")),
            },
            OperandKind::Abs => match addr(loc.reg)? {
                Ref::Const(k) => Opnd::Const(k),
                Ref::Data(d) => Opnd::Data(d),
                _ => return Err(err("not a constant or data address")),
            },
            OperandKind::Sym => match addr(loc.reg)? {
                Ref::Sym(s) => Opnd::Sym(s),
                _ => return Err(err("not a symbol slot")),
            },
            OperandKind::Site => match addr(loc.reg)? {
                Ref::Site(s) => Opnd::Site(s),
                _ => return Err(err("not a site")),
            },
            // A table of `n` entries and the default, 4 bytes each, must fit in the code.
            OperandKind::List(ElemKind::Target) => {
                let n = usize::try_from(imm(loc.reg)?).ok().filter(|&n| n < code_len / 4).ok_or(err("case count"))?;
                Opnd::Targets(vec![0; n])
            }
            OperandKind::List(e) if let Some(size) = e.case_bytes() => {
                let Ref::Ro(at) = addr(loc.reg)? else { return Err(err("case values")) };
                let n = usize::try_from(imm(loc.reg + 1)?).map_err(|_| err("case values"))?;
                let len = n.checked_mul(size).ok_or(err("case values"))?;
                let b = ro.get(at as usize..).and_then(|b| b.get(..len)).ok_or(err("case values"))?;
                let vals = b.chunks(size).map(|c| c.iter().rev().fold(0u128, |v, &x| v << 8 | x as u128)).collect();
                Opnd::Cases(vals, vec![0; n])
            }
            OperandKind::Func | OperandKind::Target | OperandKind::Neg | OperandKind::List(_) | OperandKind::Handler => {
                return Err(err("operand in a register"));
            }
        });
    }
    // A shared register holds exactly its two halves (checked by `narrow`); an unshared one
    // was range-checked above.
    Ok(ops)
}
