//! Machine code back to instruction words: the encoder's test oracle. It accepts only the
//! canonical sequences ([`super::x86`]), with operand registers set in order, and recovers
//! every operand, the frame size and the unwind entries.

use alloc::vec;
use alloc::vec::Vec;

use super::encode::{CallSite, Opnd, PROBE_FROM, Ref, RegVal, Reloc, case_size, push_words, word_len};
use super::inline::Cache;
use super::x86::{ARGS, BadItem, Cond, Cursor, Item, Reg, island_args};
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

/// Decodes one function's machine code, with its relocations (sorted), rodata and call
/// sites.
pub fn decode(code: &[u8], relocs: &[Reloc], rodata: &[u8], call_sites: &[CallSite], mode: Mode) -> Result<Decoded, AsmError> {
    let mut c = Cursor::new(code, relocs);
    let err = |at: u32, what: &'static str| AsmError { at, what };
    // Prologue.
    if c.item()? != Item::PushRbp || c.item()? != Item::Mov(Reg::Rbp, Reg::Rsp) {
        return Err(err(0, "no prologue"));
    }
    let mut frame_size = 0;
    let save = c.pos;
    match c.item() {
        Ok(Item::SetReg(Reg::Rax, f)) => {
            if c.item()? != Item::Call(Ref::Probe) {
                return Err(err(c.pos, "no stack probe"));
            }
            match c.item()? {
                Item::SubRsp(g) if g as u64 == f && g >= PROBE_FROM => frame_size = g,
                _ => return Err(err(c.pos, "probe size isn't the frame size")),
            }
        }
        Ok(Item::SubRsp(f)) if f < PROBE_FROM && f != 0 => frame_size = f,
        _ => c.pos = save,
    }
    if frame_size % 16 != 0 {
        return Err(err(save, "frame size not a multiple of 16"));
    }
    let argblk = (frame_size as i32).wrapping_neg() as u32;

    // Twice: the register cache is cleared at branch targets, which are only known once the
    // whole function is decoded. The first pass takes every inline sequence that is right
    // with the cache or without it; the second is exact, with the targets of the first.
    let body = c.pos;
    let (protos, _) = instructions(&mut c, mode, rodata, argblk, None)?;
    let mut targets: Vec<u32> = protos.iter().flat_map(|p| p.ops.iter()).flat_map(op_targets).collect();
    targets.sort_unstable();
    c.pos = body;
    let (protos, padded) = instructions(&mut c, mode, rodata, argblk, Some(&targets))?;

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
/// as the cache emits it; without, a sequence may also be one emitted with an empty cache.
fn instructions(
    c: &mut Cursor<'_>,
    mode: Mode,
    ro: &[u8],
    argblk: u32,
    targets: Option<&[u32]>,
) -> Result<(Vec<Proto>, Vec<bool>), AsmError> {
    let mut protos: Vec<Proto> = Vec::new();
    let mut padded = Vec::new();
    let mut cache = Cache::default();
    while !c.at_end() {
        let pad = c.padding();
        if pad != 0 && (!mode.align_loops || pad >= 16 || c.pos % 16 != 0) {
            return Err(AsmError { at: c.pos, what: "padding" });
        }
        padded.push(pad != 0);
        if targets.is_some_and(|t| t.binary_search(&c.pos).is_ok()) {
            cache = Cache::default();
        }
        let p = match inline_insn(c, &mut cache, targets.is_some()) {
            Some(p) => p,
            None => {
                cache = Cache::default();
                insn(c, mode, ro, argblk)?
            }
        };
        protos.push(p);
    }
    Ok((protos, padded))
}

/// Reads one instruction that isn't inline.
fn insn(c: &mut Cursor<'_>, mode: Mode, ro: &[u8], argblk: u32) -> Result<Proto, AsmError> {
    let pos = c.pos;
    let err = |at: u32, what: &'static str| AsmError { at, what };
    let mut setup = Vec::new();
    let head = loop {
        let at = c.pos;
        match c.item()? {
            it @ (Item::SetReg(..) | Item::Lea(..) | Item::Mov(..)) => setup.push((at, it)),
            it => break (at, it),
        }
    };
    let (hat, head) = head;
    let mut sites = Vec::new();
    let ops = match head {
        Item::Call(Ref::Handler(op)) if has_handler(op) => {
            let mut ops = handler_operands(op, &setup, mode, ro, pos)?;
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
                Shape::Ret => {
                    fixed(c, Item::Leave)?;
                    fixed(c, Item::Ret)?;
                }
                Shape::CallExt | Shape::CallInd => {
                    fixed(c, Item::TestRax)?;
                    fixed(c, Item::Branch { cond: Cond::Z, target: c.pos + 2 + 2 + 7 + 2, long: false })?;
                    sites.push((c.pos, 2));
                    fixed(c, Item::CallRax)?;
                    let at = c.pos;
                    let Item::Marker(d) = c.item()? else { return Err(err(at, "no call marker")) };
                    let island_len = if mode.pe { 24 } else { 16 };
                    fixed(c, Item::Branch { cond: Cond::Always, target: c.pos + 2 + island_len, long: false })?;
                    let (isl, ops_ro, site) = island_call(c, mode)?;
                    sites.push(site);
                    let fnp = if info.shape == Shape::CallExt { "f" } else { "p" };
                    let Opnd::Slot(f) = ops[info.operand_index(fnp).unwrap()] else { unreachable!() };
                    if ops_array(ro, ops_ro) != Some(vec![argblk, d as u32, f as u32]) {
                        return Err(err(at, "native path operands"));
                    }
                    set(&mut ops, "d", Opnd::Slot(d));
                    set(&mut ops, "isl", Opnd::Sym(isl));
                }
                Shape::TailCall => {
                    fixed(c, Item::Leave)?;
                    let at = c.pos;
                    let Item::Jmp(Ref::Func(f)) = c.item()? else { return Err(err(at, "no tail jump")) };
                    set(&mut ops, "f", Opnd::Func(f));
                }
                Shape::TailCallInd => {
                    fixed(c, Item::TestRax)?;
                    fixed(c, Item::Branch { cond: Cond::Z, target: c.pos + 2 + 1 + 2, long: false })?;
                    fixed(c, Item::Leave)?;
                    fixed(c, Item::JmpRax)?;
                    let at = c.pos;
                    let (isl, ops_ro, site) = island_call(c, mode)?;
                    sites.push(site);
                    // Then `ret s, len`.
                    let mut rsetup = Vec::new();
                    let ret = loop {
                        let a = c.pos;
                        match c.item()? {
                            it @ (Item::SetReg(..) | Item::Mov(..)) => rsetup.push((a, it)),
                            it => break it,
                        }
                    };
                    if ret != Item::Call(Ref::Handler(Opcode::Ret)) {
                        return Err(err(at, "no return"));
                    }
                    let r = handler_operands(Opcode::Ret, &rsetup, mode, ro, at)?;
                    fixed(c, Item::Leave)?;
                    fixed(c, Item::Ret)?;
                    let (Opnd::Slot(s), Opnd::Slot(p)) = (&r[0], &ops[0]) else { unreachable!() };
                    if ops_array(ro, ops_ro) != Some(vec![argblk, *s as u32, *p as u32]) {
                        return Err(err(at, "native path operands"));
                    }
                    set(&mut ops, "isl", Opnd::Sym(isl));
                    set(&mut ops, "s", r[0].clone());
                    set(&mut ops, "len", r[1].clone());
                }
                Shape::Jmp | Shape::Call | Shape::Island => unreachable!(),
            }
            if super::inline::sequence(op, &ops).is_some() {
                return Err(err(hat, "handler call of an inlined instruction"));
            }
            Proto { op, ops, pos, sites }
        }
        Item::Call(Ref::Func(f)) if setup.is_empty() => {
            sites.push((hat, 5));
            let at = c.pos;
            let Item::Marker(d) = c.item()? else { return Err(err(at, "no call marker")) };
            Proto { op: Opcode::Call, ops: vec![Opnd::Slot(d), Opnd::Func(f)], pos, sites }
        }
        Item::Branch { cond: Cond::Always, target, .. } if setup.is_empty() => {
            Proto { op: Opcode::Jmp, ops: vec![Opnd::Target(target)], pos, sites }
        }
        Item::CallMem(_) | Item::SubRsp(32) => {
            // An island: `fp`, `ops`, (PE) shadow space, the call through the slot.
            c.pos = pos;
            let (isl, ops_ro, site) = island_call(c, mode)?;
            sites.push(site);
            let ws = ops_array(ro, ops_ro).ok_or(err(pos, "island operands"))?;
            Proto { op: Opcode::Island, ops: vec![Opnd::Sym(isl), Opnd::Words(ws)], pos, sites }
        }
        _ => return Err(err(hat, "not an instruction")),
    };
    Ok(ops)
}

/// An inline sequence at the cursor, or `None` (the cursor unmoved) if there is none: native
/// items up to the one that writes the result, or up to a conditional branch. They must be
/// the sequence as the register cache `cache` emits it (updated to after it), or, unless
/// `exact`, the sequence as emitted with an empty cache.
fn inline_insn(c: &mut Cursor<'_>, cache: &mut Cache, exact: bool) -> Option<Proto> {
    let pos = c.pos;
    let mut items = Vec::new();
    let mut branch = None;
    loop {
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
                return None;
            }
        }
    }
    let mut cands = cache.unrewrite(&items);
    cands.insert(0, items.clone());
    for cand in cands {
        let Some((op, ops)) = super::inline::decode(&cand, branch) else { continue };
        let mut after = *cache;
        if after.emit(&cand) == items {
            *cache = after;
        } else if !exact && cand == items {
            *cache = Cache::default();
            cache.emit(&cand);
        } else {
            continue;
        }
        return Some(Proto { op, ops, pos, sites: Vec::new() });
    }
    c.pos = pos;
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
fn island_call(c: &mut Cursor<'_>, mode: Mode) -> Result<(crate::insn::Sym, u32, (u32, u32)), AsmError> {
    let at = c.pos;
    let bad = AsmError { at, what: "island call" };
    let [fp, opsr] = island_args(mode.pe);
    if c.item()? != Item::Mov(fp, Reg::Rbp) {
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
fn handler_operands(op: Opcode, setup: &[(u32, Item)], mode: Mode, ro: &[u8], pos: u32) -> Result<Vec<Opnd>, AsmError> {
    let err = |what: &'static str| AsmError { at: pos, what };
    let l = layout(op, mode);
    let info = op.info();
    let mut it = setup.iter().map(|s| s.1);
    if mode.fp_arg && it.next() != Some(Item::Mov(ARGS[0], Reg::Rbp)) {
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
