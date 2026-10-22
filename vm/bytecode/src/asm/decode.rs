//! Machine code back to instruction words: the encoder's test oracle. It accepts only the
//! canonical sequences ([`super::x86`]), with operand registers set in order, and recovers
//! every operand, the frame size and the unwind entries.

use alloc::vec;
use alloc::vec::Vec;

use super::encode::{CallSite, DroppedStore, Opnd, Ref, RegVal, Reloc, case_size, epilogue, fp_item, prologue, push_words, ret_parts, word_len};
use super::inline::Cache;
use super::x86::{ARGS, BadItem, Cond, Cursor, Item, M, Reg, island_args};
use super::{Mode, has_handler, layout};
use crate::image::{CATCH, CONTINUE, CleanupEntry, op_may_unwind};
use crate::insn::{ElemKind, Opcode, OperandKind, Shape};

/// A function decoded from machine code.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Decoded {
    pub words: Vec<u32>,
    pub frame_size: u32,
    /// Sorted by offset.
    pub cleanup: Vec<CleanupEntry>,
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
    ops: Vec<Opnd>,
    /// Position of the instruction (after padding).
    pos: u32,
    sites: Vec<(u32, u32)>,
}

/// Decodes one function's machine code, with its relocations (sorted), rodata, call sites and
/// dropped stores ([`super::Encoded`]).
pub fn decode(
    code: &[u8],
    relocs: &[Reloc],
    rodata: &[u8],
    call_sites: &[CallSite],
    dropped: &[DroppedStore],
    mode: Mode,
) -> Result<Decoded, AsmError> {
    let mut c = Cursor::new(code, relocs);
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
            Ok(Item::PushRbp | Item::Mov(Reg::Rbp, Reg::Rsp) | Item::SetReg(Reg::Rax, _) | Item::Call(Ref::Probe)) => continue,
            _ => {}
        }
        break;
    }
    let frame_size = if mode.frame_pointer { alloc } else { alloc.wrapping_sub(8) };
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
    let fr = Frame { size: frame_size, mode };
    let argblk = (frame_size as i32).wrapping_neg() as u32;

    // Twice: the register cache is cleared at branch targets, which are only known once the
    // whole function is read. The first pass only finds the instructions and targets; the
    // second decodes them, with the cache cleared at the targets of the first.
    let body = c.pos;
    let (protos, _) = instructions(&mut c, &fr, rodata, argblk, dropped, None)?;
    let mut targets: Vec<u32> = protos.iter().flat_map(|p| p.ops.iter()).flat_map(op_targets).collect();
    targets.sort_unstable();
    c.pos = body;
    let (protos, padded) = instructions(&mut c, &fr, rodata, argblk, dropped, Some(&targets))?;

    // Instruction positions → indices and word offsets.
    let ipos: Vec<u32> = protos.iter().map(|p| p.pos).collect();
    let index = |at: u32, b: u32| ipos.binary_search(&b).map_err(|_| err(at, "target isn't an instruction"));
    let mut wpos = Vec::with_capacity(protos.len());
    let mut w = 0u32;
    for p in &protos {
        wpos.push(w);
        w += word_len(p.op, &p.ops) as u32;
    }
    // When aligning, loop heads start at multiples of 16, and only they are padded.
    let mut head = vec![false; protos.len()];
    for (i, p) in protos.iter().enumerate() {
        for o in &p.ops {
            if let Opnd::Target(t) = o {
                let j = index(p.pos, *t)?;
                if j <= i {
                    head[j] = true;
                }
            }
        }
    }
    for i in 0..protos.len() {
        if (padded[i] && !head[i]) || (mode.align_loops && head[i] && ipos[i] % 16 != 0) {
            return Err(err(ipos[i], "loop head padding"));
        }
    }

    // Unwind entries from the call sites.
    let mut cleanup = Vec::new();
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
                let target = match pad {
                    None => CONTINUE,
                    Some(b) => {
                        let j = index(ipos[i], b)?;
                        if protos[j].op != Opcode::Lpad {
                            return Err(err(b, "landing pad isn't an lpad"));
                        }
                        wpos[j] | if catch { CATCH } else { 0 }
                    }
                };
                cleanup.push(CleanupEntry { offset: wpos[i], target });
            }
            None => {}
        }
    }
    if used != call_sites.len() {
        return Err(err(0, "call site outside every call"));
    }

    // Words.
    let mut words = Vec::with_capacity(w as usize);
    for (i, p) in protos.iter().enumerate() {
        let ops = p
            .ops
            .iter()
            .map(|o| o.clone().map_targets(|b| Ok::<_, AsmError>(wpos[index(p.pos, b)?].wrapping_sub(wpos[i]))))
            .collect::<Result<Vec<_>, _>>()?;
        push_words(p.op, &ops, &mut words);
    }
    Ok(Decoded { words, frame_size, cleanup })
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
    argblk: u32,
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
        let p = match inline_insn(c, &mut cache, &mut dropped, targets.is_some()) {
            Some(p) => p,
            None => {
                cache = Cache::default();
                insn(c, fr, ro, argblk)?
            }
        };
        protos.push(p);
    }
    if let Some(d) = dropped.first() {
        return Err(AsmError { at: d.at, what: "dropped store not at the end of a sequence" });
    }
    Ok((protos, padded))
}

/// The frame size and the mode, which the prologue, the epilogue and `fp` depend on.
struct Frame {
    size: u32,
    mode: Mode,
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
fn insn(c: &mut Cursor<'_>, fr: &Frame, ro: &[u8], argblk: u32) -> Result<Proto, AsmError> {
    let mode = fr.mode;
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
        Item::Call(Ref::Handler(op)) if has_handler(op) => {
            let mut ops = handler_operands(op, &setup, fr, ro, pos)?;
            let info = op.info();
            let set = |ops: &mut Vec<Opnd>, name: &str, v: Opnd| ops[info.operand_index(name).unwrap()] = v;
            let fixed = |c: &mut Cursor<'_>, want: Item| -> Result<(), AsmError> {
                let at = c.pos;
                if c.item()? != want { Err(err(at, "not the instruction's canonical sequence")) } else { Ok(()) }
            };
            match info.shape {
                Shape::Op | Shape::Lpad => {}
                Shape::Br => {
                    fixed(c, Item::TestAl)?;
                    let at = c.pos;
                    let Item::Branch { cond: cond @ (Cond::Z | Cond::Nz), target, .. } = c.item()? else {
                        return Err(err(at, "branch"));
                    };
                    set(&mut ops, "neg", Opnd::Neg(cond == Cond::Z));
                    set(&mut ops, "t", Opnd::Target(target));
                }
                Shape::Switch => {
                    let n = ops.iter().find_map(|o| match o {
                        Opnd::Targets(t) | Opnd::Cases(_, t) => Some(t.len()),
                        _ => None,
                    });
                    let mut t = table(c, n.unwrap() + 1)?;
                    set(&mut ops, "default", Opnd::Target(t.pop().unwrap()));
                    for o in &mut ops {
                        if let Opnd::Targets(ts) | Opnd::Cases(_, ts) = o {
                            *ts = t.clone();
                        }
                    }
                }
                Shape::Trap => {
                    if op == Opcode::Resume {
                        sites.push((hat, 5));
                    }
                    fixed(c, Item::Ud2)?;
                }
                Shape::CallExt | Shape::CallInd => {
                    fixed(c, Item::TestRax)?;
                    let at = c.pos;
                    let Item::Branch { cond: Cond::Z, target: native, long: false } = c.item()? else {
                        return Err(err(at, "no native path branch"));
                    };
                    sites.push((c.pos, 2));
                    fixed(c, Item::CallRax)?;
                    let (rd, len) = result(c);
                    let island_len = fp_item(island_args(mode.pe)[0], fr.size, mode).len() + if mode.pe { 7 + 4 + 6 + 4 } else { 7 + 6 };
                    fixed(c, Item::Branch { cond: Cond::Always, target: c.pos + 2 + island_len, long: false })?;
                    if native != c.pos {
                        return Err(err(at, "native path branch"));
                    }
                    let (isl, ops_ro, site) = island_call(c, fr)?;
                    sites.push(site);
                    let fnp = if info.shape == Shape::CallExt { "f" } else { "p" };
                    let Opnd::Slot(f) = ops[info.operand_index(fnp).unwrap()] else { unreachable!() };
                    let Some([_, d, _]) = ops_array(ro, ops_ro).and_then(|w| <[u32; 3]>::try_from(w).ok()) else {
                        return Err(err(at, "native path operands"));
                    };
                    if ops_array(ro, ops_ro) != Some(vec![argblk, d, f as u32]) || (len != 0 && rd != d as i32) {
                        return Err(err(at, "native path operands"));
                    }
                    set(&mut ops, "d", Opnd::Slot(d as i32));
                    set(&mut ops, "isl", Opnd::Sym(isl));
                    set(&mut ops, "len", Opnd::Imm(len as u64));
                }
                Shape::TailCall => {
                    fixed(c, fr.epilogue())?;
                    let at = c.pos;
                    let Item::Jmp(Ref::Func(f)) = c.item()? else { return Err(err(at, "no tail jump")) };
                    set(&mut ops, "f", Opnd::Func(f));
                }
                Shape::TailCallInd => {
                    fixed(c, Item::TestRax)?;
                    fixed(c, Item::Branch { cond: Cond::Z, target: c.pos + 2 + fr.epilogue().len() + 2, long: false })?;
                    fixed(c, fr.epilogue())?;
                    fixed(c, Item::JmpRax)?;
                    let at = c.pos;
                    let (isl, ops_ro, site) = island_call(c, fr)?;
                    sites.push(site);
                    // Then `ret s, len`.
                    let (rs, len) = ret(c, fr)?;
                    let Opnd::Slot(p) = ops[0] else { unreachable!() };
                    let Some([_, s, _]) = ops_array(ro, ops_ro).and_then(|w| <[u32; 3]>::try_from(w).ok()) else {
                        return Err(err(at, "native path operands"));
                    };
                    if ops_array(ro, ops_ro) != Some(vec![argblk, s, p as u32]) || (len != 0 && rs != s as i32) {
                        return Err(err(at, "native path operands"));
                    }
                    set(&mut ops, "isl", Opnd::Sym(isl));
                    set(&mut ops, "s", Opnd::Slot(s as i32));
                    set(&mut ops, "len", Opnd::Imm(len as u64));
                }
                Shape::Jmp | Shape::Call | Shape::Ret | Shape::Island => unreachable!(),
            }
            if super::inline::sequence(op, &ops).is_some() {
                return Err(err(hat, "handler call of an inlined instruction"));
            }
            Proto { op, ops, pos, sites }
        }
        Item::Call(Ref::Func(f)) if setup.is_empty() => {
            sites.push((hat, 5));
            let (d, len) = result(c);
            Proto { op: Opcode::Call, ops: vec![Opnd::Slot(d), Opnd::Func(f), Opnd::Imm(len as u64)], pos, sites }
        }
        Item::Ld { .. } | Item::Leave | Item::AddRsp(_) if setup.is_empty() => {
            c.pos = pos;
            let (s, len) = ret(c, fr)?;
            Proto { op: Opcode::Ret, ops: vec![Opnd::Slot(s), Opnd::Imm(len as u64)], pos, sites }
        }
        Item::Branch { cond: Cond::Always, target, .. } if setup.is_empty() => {
            Proto { op: Opcode::Jmp, ops: vec![Opnd::Target(target)], pos, sites }
        }
        Item::CallMem(_) | Item::SubRsp(32) => {
            // An island: `fp`, `ops`, (PE) shadow space, the call through the slot.
            c.pos = pos;
            let (isl, ops_ro, site) = island_call(c, fr)?;
            sites.push(site);
            let ws = ops_array(ro, ops_ro).ok_or(err(pos, "island operands"))?;
            Proto { op: Opcode::Island, ops: vec![Opnd::Sym(isl), Opnd::Words(ws)], pos, sites }
        }
        _ => return Err(err(hat, "not an instruction")),
    };
    Ok(ops)
}

/// `ret`'s sequence at the cursor: the loads of the value into `rax`/`rdx`, the epilogue and
/// `ret`. Returns the slot and the length (slot 0 for nothing returned).
fn ret(c: &mut Cursor<'_>, fr: &Frame) -> Result<(i32, u32), AsmError> {
    let at = c.pos;
    let mut parts = Vec::new();
    loop {
        let a = c.pos;
        match c.item()? {
            Item::Ld { w, sx: false, dst, m } if m.base == Reg::Rbp => parts.push((w, m.disp as u32, dst)),
            _ => {
                c.pos = a;
                break;
            }
        }
    }
    let (s, len) = match parts.first() {
        None => (0, 0),
        Some(&(_, s, _)) => {
            let len = [1, 2, 4, 8, 16].into_iter().find(|&l| {
                ret_parts(l).into_iter().map(|(w, off, r)| (w, s.wrapping_add(off), r)).eq(parts.iter().copied())
            });
            (s as i32, len.ok_or(AsmError { at, what: "return value loads" })?)
        }
    };
    for want in [fr.epilogue(), Item::Ret] {
        let a = c.pos;
        if c.item()? != want {
            return Err(AsmError { at: a, what: "not the return sequence" });
        }
    }
    Ok((s, len))
}

/// A call's result stores from `rax`/`rdx` at the cursor, if any: the destination and the
/// length (slot 0 for none).
fn result(c: &mut Cursor<'_>) -> (i32, u32) {
    let at = c.pos;
    let mut parts = Vec::new();
    loop {
        let a = c.pos;
        match c.item() {
            Ok(Item::St { w, src: src @ (Reg::Rax | Reg::Rdx), m }) if m.base == Reg::Rbp && parts.len() < 2 => {
                parts.push((w, m.disp as u32, src))
            }
            _ => {
                c.pos = a;
                break;
            }
        }
    }
    let Some(&(_, d, _)) = parts.first() else { return (0, 0) };
    // The longest form the stores begin with.
    for l in [16, 8, 4, 2, 1] {
        let want: Vec<_> = ret_parts(l).into_iter().map(|(w, off, r)| (w, d.wrapping_add(off), r)).collect();
        if parts.starts_with(&want) {
            c.pos = at;
            for _ in 0..want.len() {
                let _ = c.item();
            }
            return (d as i32, l);
        }
    }
    c.pos = at;
    (0, 0)
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
        return Some(Proto { op, ops, pos, sites: Vec::new() });
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
        return Some(Proto { op, ops, pos, sites: Vec::new() });
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
fn island_call(c: &mut Cursor<'_>, fr: &Frame) -> Result<(crate::insn::Sym, u32, (u32, u32)), AsmError> {
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
                OperandKind::Func => Opnd::Func(crate::insn::Func(0)),
                OperandKind::Sym => Opnd::Sym(crate::insn::Sym(0)),
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
                let vals = b
                    .chunks(size)
                    .map(|c| c.iter().rev().fold(0u128, |v, &x| v << 8 | x as u128))
                    .collect();
                Opnd::Cases(vals, vec![0; n])
            }
            OperandKind::Func | OperandKind::Target | OperandKind::Neg | OperandKind::List(ElemKind::Word) => {
                return Err(err("operand in a register"));
            }
        });
    }
    // A shared register holds exactly its two halves (checked by `narrow`); an unshared one
    // was range-checked above.
    Ok(ops)
}
