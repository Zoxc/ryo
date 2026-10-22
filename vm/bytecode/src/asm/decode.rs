//! Machine code back to instruction words: the encoder's test oracle. It accepts only the
//! canonical sequences ([`super::x86`]), with operand registers set in order, and recovers
//! every operand, the frame size and the unwind entries: in the full set ([`decode`]), or in
//! the reduced set ([`decode_reduced`]), which reads handler calls as their register values
//! without the handlers' operand lists. [`decode_linked`] reads linked code, as it sits in
//! memory, to the reduced set: a [`Resolver`] says what its resolved fields point at.

use alloc::vec;
use alloc::vec::Vec;

use super::encode::{
    CallSite, DroppedStore, Opnd, Ref, RegVal, Reloc, Scope, arg_store, case_size, epilogue, fp_item, int_arg, prologue, push_words, result_stores,
    ret_loads, word_len,
};
use super::inline::Cache;
use super::reduced::{self, Then, addr_arg};
use super::x86::{ARGS, BadItem, Cond, Cursor, Fields, Item, M, Reg, island_args};
use super::{ARG_ADDR, ArgReg, Mode, RetPart, has_handler, layout, ret_kind};
use crate::full::{ElemKind, Opcode, OperandKind, Shape, Sym};
use crate::image::{CATCH, CONTINUE, CleanupEntry, op_may_unwind};
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
}

impl Proto {
    fn new(op: Opcode, ops: Vec<Opnd>, pos: u32, sites: Vec<(u32, u32)>) -> Proto {
        Proto { op, ops, handler: None, pos, sites }
    }

    /// The branch targets (byte positions).
    fn targets(&self) -> Vec<u32> {
        let mut out: Vec<u32> = self.ops.iter().flat_map(op_targets).collect();
        match &self.handler {
            Some((_, Then::Branch { target, .. })) => out.push(*target),
            Some((_, Then::Table(ts))) => out.extend(ts),
            _ => {}
        }
        out
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
}

/// Decodes one function's machine code, with its relocations (sorted), rodata, call sites and
/// dropped stores ([`super::Encoded`]), to the full set.
pub fn decode(
    code: &[u8],
    relocs: &[Reloc],
    rodata: &[u8],
    call_sites: &[CallSite],
    dropped: &[DroppedStore],
    scopes: &[Scope],
    mode: Mode,
) -> Result<Decoded, AsmError> {
    let Read { protos, frame_size, actions, scopes } = read(code, Fields::Relocs(relocs), rodata, call_sites, dropped, scopes, mode, false)?;
    let err = |at: u32, what: &'static str| AsmError { at, what };
    let ipos: Vec<u32> = protos.iter().map(|p| p.pos).collect();
    let index = |at: u32, b: u32| ipos.binary_search(&b).map_err(|_| err(at, "target isn't an instruction"));
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
            let target = pad.map_or(CONTINUE, |j| wpos[j] | if catch { CATCH } else { 0 });
            Some(CleanupEntry { offset: wpos[i], target })
        })
        .collect();
    let mut words = Vec::with_capacity(w as usize);
    for (i, p) in protos.iter().enumerate() {
        let ops = p
            .ops
            .iter()
            .map(|o| o.clone().map_targets(|b| Ok::<_, AsmError>(wpos[index(p.pos, b)?].wrapping_sub(wpos[i]))))
            .collect::<Result<Vec<_>, _>>()?;
        push_words(p.op, &ops, &mut words);
    }
    wpos.push(w);
    let scopes = scopes.into_iter().map(|(i, sc)| Scope { code_offset: wpos[i], ..sc }).collect();
    Ok(Decoded { words, frame_size, cleanup, scopes })
}

/// Decodes one function's machine code, as [`decode`], to the reduced set
/// ([`crate::reduced`]): handler calls are read from their argument registers, without their
/// operand lists, so it doesn't check that they are of operands that aren't inlined.
pub fn decode_reduced(
    code: &[u8],
    relocs: &[Reloc],
    rodata: &[u8],
    call_sites: &[CallSite],
    dropped: &[DroppedStore],
    scopes: &[Scope],
    mode: Mode,
) -> Result<Decoded, AsmError> {
    reduced_of(read(code, Fields::Relocs(relocs), rodata, call_sites, dropped, scopes, mode, true)?)
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
/// first byte) is a branch or jump table within it, any other is the reference `resolver`
/// gives. The dropped stores aren't in the code or the image; until they are, they must be
/// given ([`super::Encoded::dropped`]).
pub fn decode_linked(
    code: &[u8],
    code_addr: u64,
    resolver: &dyn Resolver,
    call_sites: &[CallSite],
    dropped: &[DroppedStore],
    scopes: &[Scope],
    mode: Mode,
) -> Result<Decoded, AsmError> {
    let fields = Fields::Linked { addr: code_addr, resolver };
    reduced_of(read(code, fields, resolver.code_consts(), call_sites, dropped, scopes, mode, true)?)
}

/// The reduced instruction words of a function read with handler calls in the reduced form.
fn reduced_of(r: Read) -> Result<Decoded, AsmError> {
    let Read { protos, frame_size, actions, scopes } = r;
    let ipos: Vec<u32> = protos.iter().map(|p| p.pos).collect();
    let index = |at: u32, b: u32| ipos.binary_search(&b).map(|i| i as u32).map_err(|_| AsmError { at, what: "target isn't an instruction" });
    let cleanup: Vec<_> = actions.iter().enumerate().filter_map(|(i, a)| a.map(|(pad, catch)| (i, pad, catch))).collect();
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
    Ok(reduced::words(&insns, &cleanup, &scopes, frame_size))
}

/// Reads one function's machine code ([`decode`]), handler calls in the reduced form with
/// `reduced`.
fn read(
    code: &[u8],
    fields: Fields<'_>,
    rodata: &[u8],
    call_sites: &[CallSite],
    dropped: &[DroppedStore],
    scopes: &[Scope],
    mode: Mode,
    reduced: bool,
) -> Result<Read, AsmError> {
    let mut c = Cursor::new(code, fields);
    let err = |at: u32, what: &'static str| AsmError { at, what };
    // Prologue: the frame size is its `sub`'s (less the 8 bytes in place of the saved `rbp`
    // without a frame pointer), and the prologue must be that size's.
    if !mode.valid() {
        return Err(err(0, "unsupported mode"));
    }
    let mut alloc = 0;
    loop {
        match c.item() {
            Ok(Item::SubRsp(n)) => alloc = n,
            Ok(Item::PushRbp | Item::WinPrologue | Item::Mov(Reg::Rbp, Reg::Rsp) | Item::SetReg(Reg::Rax, _) | Item::Call(Ref::Probe)) => continue,
            _ => {}
        }
        break;
    }
    let frame_size = if mode.pe {
        alloc + 16
    } else if mode.frame_pointer {
        alloc
    } else {
        alloc.wrapping_sub(8)
    };
    if frame_size % 16 != 0 {
        return Err(err(0, "frame size not a multiple of 16"));
    }
    c.pos = 0;
    for want in prologue(frame_size, mode) {
        let at = c.pos;
        if c.item().ok() != Some(want) {
            return Err(err(at, "not the prologue of the frame size"));
        }
    }
    if !mode.frame_pointer {
        c.sp_frame = Some(frame_size);
    }
    let fr = Frame { size: frame_size, mode, reduced };

    // Twice: the register cache is cleared at branch targets, which are only known once the
    // whole function is read. The first pass only finds the instructions and targets; the
    // second decodes them, with the cache cleared at the targets of the first.
    let body = c.pos;
    let (protos, _) = instructions(&mut c, &fr, rodata, dropped, None)?;
    let mut targets: Vec<u32> = protos.iter().flat_map(Proto::targets).collect();
    targets.sort_unstable();
    c.pos = body;
    let (protos, padded) = instructions(&mut c, &fr, rodata, dropped, Some(&targets))?;

    // Instruction positions → indices.
    let ipos: Vec<u32> = protos.iter().map(|p| p.pos).collect();
    let index = |at: u32, b: u32| ipos.binary_search(&b).map_err(|_| err(at, "target isn't an instruction"));
    // When aligning, loop heads start at multiples of 16, and only they are padded. Only
    // single branch targets make loop heads, not jump tables.
    let mut head = vec![false; protos.len()];
    for (i, p) in protos.iter().enumerate() {
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
            if j <= i {
                head[j] = true;
            }
        }
    }
    for i in 0..protos.len() {
        if (padded[i] && !head[i]) || (mode.align_loops && head[i] && ipos[i] % 16 != 0) {
            return Err(err(ipos[i], "loop head padding"));
        }
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
            None => {}
        }
    }
    if used != call_sites.len() {
        return Err(err(0, "call site outside every call"));
    }
    // Scopes: before the first instruction at or after their position.
    let scopes = scopes.iter().map(|sc| (ipos.partition_point(|&p| p < sc.code_offset), *sc)).collect();
    Ok(Read { protos, frame_size, actions, scopes })
}

fn read_u32(ro: &[u8], at: u32) -> Option<u32> {
    let b = ro.get(at as usize..)?.get(..4)?;
    Some(u32::from_le_bytes(b.try_into().unwrap()))
}

/// The operand array at `at` in the rodata (its count is the word before).
fn ops_array(ro: &[u8], at: u32) -> Option<Vec<u32>> {
    let n = read_u32(ro, at.checked_sub(4)?)?;
    (0..n).map(|i| read_u32(ro, at + 4 * i)).collect()
}

/// The branch targets of an operand (byte positions).
fn op_targets(o: &Opnd) -> Vec<u32> {
    match o {
        Opnd::Target(t) => vec![*t],
        Opnd::Targets(ts) | Opnd::Cases(_, ts) => ts.clone(),
        _ => Vec::new(),
    }
}

/// The instructions from the cursor to the end, and whether each is padded. With `targets`
/// (sorted), the register cache is cleared at them and every inline sequence must be exactly
/// as the cache emits it; without, inline sequences are only delimited ([`inline_insn`]).
fn instructions(
    c: &mut Cursor<'_>,
    fr: &Frame,
    ro: &[u8],
    mut dropped: &[DroppedStore],
    targets: Option<&[u32]>,
) -> Result<(Vec<Proto>, Vec<bool>), AsmError> {
    let mut protos: Vec<Proto> = Vec::new();
    let mut padded = Vec::new();
    let mut cache = Cache::default();
    while !c.at_end() {
        let pad = c.padding();
        if pad != 0 && (!fr.mode.align_loops || pad >= 16 || c.pos % 16 != 0) {
            return Err(AsmError { at: c.pos, what: "padding" });
        }
        padded.push(pad != 0);
        if targets.is_some_and(|t| t.binary_search(&c.pos).is_ok()) {
            cache = Cache::default();
        }
        // `arg`s come first.
        if protos.iter().all(|p| p.op == Opcode::Arg)
            && let Some(p) = arg(c, fr.mode)
        {
            protos.push(p);
            continue;
        }
        if let Some(p) = call_insn(c, fr, dropped) {
            cache = Cache::default();
            protos.push(p);
            continue;
        }
        let p = match inline_insn(c, &mut cache, &mut dropped, targets.is_some()) {
            Some(p) => p,
            None => {
                cache = Cache::default();
                insn(c, fr, ro)?
            }
        };
        protos.push(p);
    }
    if let Some(d) = dropped.first() {
        return Err(AsmError { at: d.at, what: "dropped store not at the end of a sequence" });
    }
    Ok((protos, padded))
}

/// The frame size and the mode, which the prologue, the epilogue and `fp` depend on, and
/// whether handler calls are read in the reduced form.
struct Frame {
    size: u32,
    mode: Mode,
    reduced: bool,
}

impl Frame {
    fn epilogue(&self) -> Item {
        epilogue(self.size, self.mode)
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
    let mut setup = Vec::new();
    let head = loop {
        let at = c.pos;
        match c.item()? {
            it @ (Item::SetReg(..) | Item::Lea(..) | Item::Mov(..) | Item::LeaM { .. }) => setup.push((at, it)),
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
                OperandKind::List(ElemKind::Case8 | ElemKind::Case16 | ElemKind::Case32 | ElemKind::Case64 | ElemKind::Case128) => Some(loc.reg + 1),
                _ => None,
            });
            let n = match n.map(|r| args.get(r as usize)) {
                None => 0,
                Some(Some(Arg::Imm(n))) if *n < 1 << 31 => *n as usize,
                Some(_) => return Err(err(pos, "case count")),
            };
            let then = then(c, op, n, hat, &mut sites)?;
            Proto { op, ops: Vec::new(), handler: Some((args, then)), pos, sites }
        }
        Item::Call(Ref::Handler(op)) if has_handler(op) => {
            let mut ops = handler_operands(op, &setup, fr, ro, pos)?;
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
        Item::Ld { .. } | Item::Sse { .. } | Item::Leave | Item::WinEpilogue | Item::AddRsp(_) if setup.is_empty() => {
            c.pos = pos;
            let (s, k) = ret(c, fr)?;
            Proto::new(Opcode::Ret, vec![Opnd::Slot(s), Opnd::Imm(k as u64)], pos, sites)
        }
        Item::Branch { cond: Cond::Always, target, .. } if setup.is_empty() => Proto::new(Opcode::Jmp, vec![Opnd::Target(target)], pos, sites),
        Item::CallMem(_) | Item::SubRsp(32) => {
            // An island: `fp`, `ops`, (PE) shadow space, the call through the slot.
            c.pos = pos;
            let (isl, ops_ro, site) = island_call(c, fr)?;
            sites.push(site);
            let ws = ops_array(ro, ops_ro).ok_or(err(pos, "island operands"))?;
            Proto::new(Opcode::Island, vec![Opnd::Sym(isl), Opnd::Words(ws)], pos, sites)
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
                parts.push(RetPart { xmm: false, size: w.bits() / 8, off: off(m)? });
            }
            Item::St { src: r @ (Reg::Rax | Reg::Rdx), w, m } => {
                let o = off(m)?;
                match parts.last_mut() {
                    // The next piece of the same register, after its shift.
                    Some(p) if !p.xmm && last_int == Some(r) && o == p.off + p.size => p.size += w.bits() / 8,
                    _ => parts.push(RetPart { xmm: false, size: w.bits() / 8, off: o }),
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
    for want in [fr.epilogue(), Item::Ret] {
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
                (m.disp, ArgReg { xmm: false, size: w.bits() / 8, index: int_index(dst, mode).unwrap() }.word())
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
        Ok(Item::LoadRip(Ref::Sym(s))) => Pre::Sym(s),
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
        (Ok(it), _) if it == fr.epilogue() => match (c.item(), &pre) {
            (Ok(Item::Jmp(Ref::Func(f))), Pre::None) => (Opcode::TailCall, vec![Opnd::Func(f), a_op.clone()], false),
            (Ok(Item::JmpRax), Pre::Ptr(p)) => (Opcode::TailCallPtr, vec![Opnd::Slot(*p), a_op.clone()], false),
            _ => return fail(c),
        },
        _ => return fail(c),
    };
    let mut sites = Vec::new();
    if call {
        sites.push((call_at, c.pos - call_at));
        let (d, k) = result(c);
        ops.insert(0, Opnd::Slot(d));
        ops.extend([Opnd::Imm(k as u64), a_op]);
    }
    Some(Proto::new(op, ops, pos, sites))
}

/// An `arg` at the cursor: the store of an argument register to its slot.
fn arg(c: &mut Cursor<'_>, mode: Mode) -> Option<Proto> {
    let pos = c.pos;
    let (a, m) = match c.item().ok()? {
        Item::St { w, src, m } => {
            // An integer of 3, 5, 6 or 7 bytes: its pieces, shifting the register down.
            let mut size = w.bits() / 8;
            loop {
                let at = c.pos;
                match (c.item(), c.item()) {
                    (Ok(Item::Shift { reg, .. }), Ok(Item::St { w, src: s, m: m2 }))
                        if reg == src && s == src && m2.disp == m.disp.wrapping_add(size as i32) =>
                    {
                        size += w.bits() / 8
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
/// branch target, as a `jmp` or an `abort`.
fn inline_insn(c: &mut Cursor<'_>, cache: &mut Cache, dropped: &mut &[DroppedStore], exact: bool) -> Option<Proto> {
    let pos = c.pos;
    let left = *dropped;
    let mut items = Vec::new();
    let mut branch = None;
    loop {
        // A dropped store ends the sequence where it would have been.
        if let Some(d) = dropped.first()
            && d.at == c.pos
        {
            items.push(d.item);
            *dropped = &dropped[1..];
            break;
        }
        match c.item() {
            Ok(it) if it.is_inline() => {
                items.push(it);
                if it.ends_inline() {
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
    // As emitted with an empty cache, the common case, else the sequences the cache may
    // have emitted this from.
    let plain = super::inline::decode(&items, branch).map(|d| (d, items.clone()));
    let cands = plain.into_iter().chain(cache.unemit(&items).into_iter().filter_map(|c| Some((super::inline::decode(&c, branch)?, c))));
    for ((op, ops), cand) in cands {
        let mut after = *cache;
        if after.emit(&cand) != items {
            continue;
        }
        *cache = after;
        return Some(Proto::new(op, ops, pos, Vec::new()));
    }
    c.pos = pos;
    *dropped = left;
    None
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
    if r != opsr || (mode.pe && c.item()? != Item::SubRsp(32)) {
        return Err(bad);
    }
    let site = c.pos;
    let Item::CallMem(Ref::Sym(isl)) = c.item()? else { return Err(bad) };
    if mode.pe && c.item()? != Item::AddRsp(32) {
        return Err(bad);
    }
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
/// and items): each sets the next register from `rdi`, to `fp`, the exception object, a
/// value or an address.
fn handler_args(setup: &[(u32, Item)], fr: &Frame, pos: u32) -> Result<Vec<Arg>, AsmError> {
    let mut out = Vec::with_capacity(setup.len());
    for (i, &(at, it)) in setup.iter().enumerate() {
        let r = *ARGS.get(i).ok_or(AsmError { at, what: "too many argument registers" })?;
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
/// items); operands handlers don't receive are left as placeholders.
fn handler_operands(op: Opcode, setup: &[(u32, Item)], fr: &Frame, ro: &[u8], pos: u32) -> Result<Vec<Opnd>, AsmError> {
    let mode = fr.mode;
    let err = |what: &'static str| AsmError { at: pos, what };
    let l = layout(op, mode);
    let info = op.info();
    let mut it = setup.iter().map(|s| s.1);
    if mode.fp_arg && it.next() != Some(fr.fp(ARGS[0])) {
        return Err(err("no fp argument"));
    }
    if info.shape == Shape::Lpad && it.next() != Some(Item::Mov(ARGS[l.first as usize - 1], Reg::Rax)) {
        return Err(err("no exception object"));
    }
    let mut regs: Vec<Option<RegVal>> = vec![None; l.regs as usize];
    for r in l.first..l.regs {
        regs[r as usize] = Some(match it.next() {
            Some(Item::SetReg(g, v)) if g == ARGS[r as usize] => RegVal::Imm(v),
            Some(Item::Lea(g, to)) if g == ARGS[r as usize] => RegVal::Addr(to),
            _ => return Err(err("operand registers out of order")),
        });
    }
    if it.next().is_some() {
        return Err(err("extra operand registers"));
    }
    let imm = |r: u8| match regs[r as usize] {
        Some(RegVal::Imm(v)) => Ok(v),
        _ => Err(err("an address where a value belongs")),
    };
    let addr = |r: u8| match regs[r as usize] {
        Some(RegVal::Addr(to)) => Ok(to),
        _ => Err(err("a value where an address belongs")),
    };
    // A shared register: the other half must belong to the paired operand, which reads it.
    let mut ops = Vec::with_capacity(info.operands.len());
    for (i, o) in info.operands.iter().enumerate() {
        let loc = l.locs[i];
        let narrow = |v: u64, bits: u32| -> Result<u64, AsmError> {
            let v = if loc.shared { (v >> loc.shift) & 0xffff_ffff } else { v };
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
            OperandKind::List(ElemKind::Target) => Opnd::Targets(vec![0; imm(loc.reg)? as usize]),
            OperandKind::List(e @ (ElemKind::Case8 | ElemKind::Case16 | ElemKind::Case32 | ElemKind::Case64 | ElemKind::Case128)) => {
                let Ref::Ro(at) = addr(loc.reg)? else { return Err(err("case values")) };
                let n = imm(loc.reg + 1)? as usize;
                let size = case_size(e);
                let b = ro.get(at as usize..).and_then(|b| b.get(..n * size)).ok_or(err("case values"))?;
                let vals = b.chunks(size).map(|c| c.iter().rev().fold(0u128, |v, &x| v << 8 | x as u128)).collect();
                Opnd::Cases(vals, vec![0; n])
            }
            OperandKind::Func | OperandKind::Target | OperandKind::Neg | OperandKind::List(ElemKind::Word | ElemKind::Arg) | OperandKind::Handler => {
                return Err(err("operand in a register"));
            }
        });
    }
    // A shared register holds exactly its two halves (checked by `narrow`); an unshared one
    // was range-checked above.
    Ok(ops)
}
