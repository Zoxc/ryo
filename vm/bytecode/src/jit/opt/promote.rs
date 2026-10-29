//! Promotion of memory allocas that nothing reaches through a pointer any more (design/jit.md,
//! "Inlining"): construction makes an alloca memory when its address escapes, into a call
//! say; once the call is inlined and the folds turned the accesses through the address into
//! accesses of the alloca ([`super::fold::fold_addr`]), its address may have no use left. An
//! alloca is promoted when it isn't pinned, nothing takes its address (no
//! [`Op::AllocaAddr`] of it is left), no handler or island names it, and its accesses
//! ([`Op::ALoad`], [`Op::AStore`]) cut it into pieces of power-of-two widths (scalar
//! replacement: an access covering several pieces is split into one per piece, a `u64` read
//! of two `u32` stores becomes two field reads put together, a vector read or written as two
//! 8-byte halves their pair or its halves). Its fields become SSA values (Braun et al. again, on the IR): a load is replaced
//! by the value the last store to its field on each path left, through new block parameters
//! where paths meet; a field nothing stored is undefined, but at an OSR entry, where a field
//! of the AOT frame's alloca is loaded from it ([`Op::OsrLoad`]).

use alloc::collections::BTreeMap;
use alloc::vec::Vec;

use crate::jit::ir::*;

/// A field of a promoted alloca: its alloca, offset and width.
type Field = (AllocaId, i32, u8);

struct P<'a> {
    f: &'a mut Func,
    fields: Vec<Field>,
    /// Per block, the value its last store to each field leaves, if it stores it.
    last: Vec<BTreeMap<u32, Value>>,
    /// Per block and field, the value at the block's start, once known.
    entry: BTreeMap<(u32, u32), Value>,
    /// New block parameters: their block, field and operands (one per predecessor).
    params: Vec<(Block, u32, Value, Vec<Value>)>,
    osr_loads: Vec<(Block, u32, Value)>,
    /// A field needed a parameter on a landing pad stub, whose edges move nothing (a stub of
    /// several invokes, after inlining): its alloca can't be promoted.
    stuck: Option<AllocaId>,
}

impl P<'_> {
    fn at_end(&mut self, b: Block, field: u32) -> Value {
        match self.last[b.idx()].get(&field) {
            Some(&v) => v,
            None => self.at_start(b, field),
        }
    }

    fn at_start(&mut self, b: Block, field: u32) -> Value {
        if let Some(&v) = self.entry.get(&(b.0, field)) {
            return v;
        }
        let (a, off, w) = self.fields[field as usize];
        let preds: Vec<Block> = self.f.blocks[b.idx()].preds.iter().map(|p| p.0).collect();
        let v = match (self.f.blocks[b.idx()].kind, preds.len()) {
            (BlockKind::Osr(_), _) if !self.f.allocas[a.idx()].inlined => {
                // The AOT frame's bytes, as OSR entries load promoted fields.
                let at = self.f.allocas[a.idx()].aot_off + off;
                let v = self.f.value(ValueDef::Undef, w);
                self.osr_loads.push((b, at as u32, v));
                v
            }
            (_, 0) => self.f.value(ValueDef::Undef, w),
            (_, 1) => self.at_end(preds[0], field),
            (BlockKind::Stub, _) => {
                self.stuck = Some(a);
                self.f.value(ValueDef::Undef, w)
            }
            _ => {
                // A parameter, known before its operands so that loops find it.
                let p = self.f.value(ValueDef::Undef, w);
                self.entry.insert((b.0, field), p);
                let ops: Vec<Value> = preds.iter().map(|&q| self.at_end(q, field)).collect();
                self.params.push((b, field, p, ops));
                return p;
            }
        };
        self.entry.insert((b.0, field), v);
        v
    }
}

/// Promotes what it can of `f`'s memory allocas. Whether it promoted any.
pub fn promote(f: &mut Func) -> bool {
    let mut ok: Vec<bool> = f.allocas.iter().map(|a| a.kind == AllocaKind::Memory && !a.pinned).collect();
    // An alloca whose field would need a parameter on a landing pad stub is left out, and
    // the promotion redone on the original.
    loop {
        if !ok.iter().any(|&x| x) {
            return false;
        }
        let mut g = f.clone();
        match try_promote(&mut g, ok.clone()) {
            Ok(changed) => {
                if changed {
                    *f = g;
                    super::osr::through_landings(f);
                }
                return changed;
            }
            Err(a) => ok[a.idx()] = false,
        }
    }
}

/// [`promote`] of the allocas `ok` allows, or the alloca that got stuck at a stub.
fn try_promote(f: &mut Func, mut ok: Vec<bool>) -> Result<bool, AllocaId> {
    let na = f.allocas.len();
    let mut live: Vec<Block> = f.live_blocks();
    let mut acc: Vec<Vec<(i32, u8)>> = alloc::vec![Vec::new(); na];
    for &b in &live {
        for &i in &f.blocks[b.idx()].insts {
            match &f.insts[i.idx()].op {
                Op::AllocaAddr(a, _) => ok[a.idx()] = false,
                Op::ALoad(a, o, w) | Op::AStore(a, o, w) => {
                    if matches!(w, 1..=8 | 16) && *o >= 0 && (*o as u32 + *w as u32) <= f.allocas[a.idx()].size {
                        acc[a.idx()].push((*o, *w));
                    } else {
                        ok[a.idx()] = false;
                    }
                }
                op @ (Op::HCall(_) | Op::Island(_)) => {
                    for a in op.named_allocas() {
                        ok[a.idx()] = false;
                    }
                }
                _ => {}
            }
        }
    }
    // Fields: the pieces the accesses' bounds cut each alloca into (scalar replacement), at
    // power-of-two widths. An access covering several is split into one per piece.
    let mut fields: Vec<Field> = Vec::new();
    let mut field_of: BTreeMap<(u32, i32, u8), u32> = BTreeMap::new();
    let mut split = alloc::vec![false; na];
    for a in 0..na {
        if !ok[a] {
            continue;
        }
        let mut fs = core::mem::take(&mut acc[a]);
        fs.sort_unstable();
        fs.dedup();
        let mut cuts: Vec<i32> = fs.iter().flat_map(|&(o, w)| [o, o + w as i32]).collect();
        cuts.sort_unstable();
        cuts.dedup();
        let pieces: Vec<(i32, u8)> =
            cuts.windows(2).filter(|c| fs.iter().any(|&(o, w)| o <= c[0] && c[1] <= o + w as i32)).map(|c| (c[0], (c[1] - c[0]) as u8)).collect();
        // A vector access split only into its two 8-byte halves.
        let halves =
            |&(o, w): &(i32, u8)| w != 16 || pieces.binary_search(&(o, 16)).is_ok() || (pieces.contains(&(o, 8)) && pieces.contains(&(o + 8, 8)));
        if pieces.iter().any(|p| !p.1.is_power_of_two()) || !fs.iter().all(halves) {
            ok[a] = false;
            continue;
        }
        split[a] = fs.iter().any(|x| pieces.binary_search(x).is_err());
        for (o, w) in pieces {
            field_of.insert((a as u32, o, w), fields.len() as u32);
            fields.push((AllocaId(a as u32), o, w));
        }
    }
    if !ok.iter().any(|&x| x) {
        return Ok(false);
    }
    let exts = if split.iter().any(|&x| x) { split_accesses(f, &live, &split, &fields) } else { Vec::new() };
    // Invoke edges move no arguments: give a normal successor that would need parameters a
    // block of its own.
    for &b in &live.clone() {
        let Term::Invoke { normal: Some(e), .. } = &f.blocks[b.idx()].term else { continue };
        let (to, args) = (e.to, e.args.clone());
        if f.blocks[to.idx()].preds.len() > 1 {
            let mid = f.block(BlockKind::Body);
            f.blocks[mid.idx()].term = Term::Jmp(Edge { to, args });
            if let Term::Invoke { normal: Some(e), .. } = &mut f.blocks[b.idx()].term {
                *e = Edge::to(mid);
            }
            let at = f.layout.iter().position(|&x| x == b).unwrap();
            f.layout.insert(at + 1, mid);
            live.push(mid);
        }
    }
    f.rebuild_preds();
    let field = |op: &Op| -> Option<u32> {
        match op {
            Op::ALoad(a, o, w) | Op::AStore(a, o, w) => field_of.get(&(a.0, *o, *w)).copied(),
            _ => None,
        }
    };
    let mut last: Vec<BTreeMap<u32, Value>> = alloc::vec![BTreeMap::new(); f.blocks.len()];
    for &b in &live {
        for &i in &f.blocks[b.idx()].insts {
            let id = &f.insts[i.idx()];
            if let (Op::AStore(..), Some(k)) = (&id.op, field(&id.op)) {
                last[b.idx()].insert(k, id.args[0]);
            }
        }
    }
    let mut p = P { f, fields, last, entry: BTreeMap::new(), params: Vec::new(), osr_loads: Vec::new(), stuck: None };
    let mut dead: Vec<Inst> = Vec::new();
    for &b in &live {
        let mut cur: BTreeMap<u32, Value> = BTreeMap::new();
        for n in 0..p.f.blocks[b.idx()].insts.len() {
            let i = p.f.blocks[b.idx()].insts[n];
            let id = &p.f.insts[i.idx()];
            let Some(k) = field(&id.op) else { continue };
            match id.op {
                Op::AStore(..) => {
                    cur.insert(k, id.args[0]);
                }
                _ => {
                    let v = match cur.get(&k) {
                        Some(&v) => v,
                        None => p.at_start(b, k),
                    };
                    let r = p.f.result(i);
                    p.f.values[r.idx()].def = ValueDef::Alias(v);
                }
            }
            dead.push(i);
        }
    }
    if let Some(a) = p.stuck {
        return Err(a);
    }
    let P { f, params, osr_loads, .. } = p;
    for (b, at, v) in osr_loads {
        let w = f.w(v);
        let i = f.inst(b, Op::OsrLoad(at as i32, w), Vec::new(), &[w]);
        f.values[v.idx()].def = ValueDef::Alias(f.result(i));
    }
    // Parameters whose operands are all one value (or itself) stand for that value.
    let mut gone = alloc::vec![false; params.len()];
    loop {
        let mut changed = false;
        for (k, (_, _, p, ops)) in params.iter().enumerate() {
            if gone[k] {
                continue;
            }
            let p = *p;
            if let Ok(same) = super::unique_operand(p, ops.iter().map(|&o| f.resolve(o))) {
                let w = f.w(p);
                let to = same.unwrap_or_else(|| f.value(ValueDef::Undef, w));
                f.values[p.idx()].def = ValueDef::Alias(to);
                gone[k] = true;
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }
    for (k, (b, _, p, ops)) in params.into_iter().enumerate() {
        if gone[k] {
            continue;
        }
        let n = f.blocks[b.idx()].params.len() as u16;
        f.values[p.idx()].def = ValueDef::Param(b, n);
        f.blocks[b.idx()].params.push(p);
        for j in 0..f.blocks[b.idx()].preds.len() {
            let (q, e) = f.blocks[b.idx()].preds[j];
            f.blocks[q.idx()].term.edge_mut(e as usize).args.push(ops[j]);
        }
    }
    for i in dead {
        let b = f.insts[i.idx()].block;
        f.blocks[b.idx()].insts.retain(|&x| x != i);
    }
    f.resolve_aliases();
    // A split load's field nothing stored is undefined, but its other fields' bits aren't:
    // its extension (which would leave a register's garbage, all 64 bits) reads a zero.
    for (i, w) in exts {
        let v = f.insts[i.idx()].args[0];
        if matches!(f.def(v), ValueDef::Undef) {
            f.insts[i.idx()].args[0] = f.konst(0, w);
        }
    }
    for a in 0..na {
        if ok[a] {
            f.allocas[a].kind = AllocaKind::Promoted;
        }
    }
    Ok(true)
}

/// Splits the accesses of the allocas `split` marks that cover several of their `fields`
/// into one access per field: a store stores each field's bytes of its value (shifted down),
/// a load loads each field and puts the value together (zero-extended, shifted up, or'ed).
/// The extensions, with their fields' widths.
fn split_accesses(f: &mut Func, live: &[Block], split: &[bool], fields: &[Field]) -> Vec<(Inst, u8)> {
    let mut exts = Vec::new();
    for &b in live {
        let insts = core::mem::take(&mut f.blocks[b.idx()].insts);
        let mut out: Vec<Inst> = Vec::with_capacity(insts.len());
        for i in insts {
            let (a, o, w, store) = match f.insts[i.idx()].op {
                Op::ALoad(a, o, w) => (a, o, w, false),
                Op::AStore(a, o, w) => (a, o, w, true),
                _ => {
                    out.push(i);
                    continue;
                }
            };
            let end = o + w as i32;
            let mine: Vec<(i32, u8)> = fields.iter().filter(|x| x.0 == a && o <= x.1 && x.1 + x.2 as i32 <= end).map(|x| (x.1, x.2)).collect();
            if !split[a.idx()] || mine == [(o, w)] {
                out.push(i);
                continue;
            }
            let mut emit = |f: &mut Func, op: Op, args: Vec<Value>, ws: &[u8]| -> Option<Value> {
                let k = f.new_inst(b, op, args, ws);
                out.push(k);
                (!ws.is_empty()).then(|| f.result(k))
            };
            if w == 16 {
                // A vector over its two halves.
                if store {
                    let v = f.insts[i.idx()].args[0];
                    for (n, (po, pw)) in mine.into_iter().enumerate() {
                        let h = emit(f, Op::V(VOp::Half(n as u8)), alloc::vec![v], &[8]).unwrap();
                        emit(f, Op::AStore(a, po, pw), alloc::vec![h], &[]);
                    }
                } else {
                    let lo = emit(f, Op::ALoad(a, o, 8), Vec::new(), &[8]).unwrap();
                    let hi = emit(f, Op::ALoad(a, o + 8, 8), Vec::new(), &[8]).unwrap();
                    let x = emit(f, Op::V(VOp::Pair), alloc::vec![lo, hi], &[16]).unwrap();
                    let r = f.result(i);
                    f.values[r.idx()].def = ValueDef::Alias(x);
                }
                continue;
            }
            if store {
                let v = f.insts[i.idx()].args[0];
                // The width the store reads its value at.
                let vw = if w.is_power_of_two() { w } else { 8 };
                for (po, pw) in mine {
                    let piece = if po == o {
                        v
                    } else {
                        let sh = f.konst(8 * (po - o) as u64, vw);
                        emit(f, Op::Bin(BinOp::ShrU, vw), alloc::vec![v, sh], &[vw]).unwrap()
                    };
                    emit(f, Op::AStore(a, po, pw), alloc::vec![piece], &[]);
                }
            } else {
                let mut acc: Option<Value> = None;
                for (po, pw) in mine {
                    let x = emit(f, Op::ALoad(a, po, pw), Vec::new(), &[pw]).unwrap();
                    let mut x = emit(f, Op::Ext { from: pw, to: w, sx: false }, alloc::vec![x], &[w]).unwrap();
                    if let ValueDef::Inst(e, _) = f.def(x) {
                        exts.push((e, pw));
                    }
                    if po != o {
                        let sh = f.konst(8 * (po - o) as u64, w);
                        x = emit(f, Op::Bin(BinOp::Shl, w), alloc::vec![x, sh], &[w]).unwrap();
                    }
                    acc = Some(match acc {
                        None => x,
                        Some(y) => emit(f, Op::Bin(BinOp::Or, w), alloc::vec![y, x], &[w]).unwrap(),
                    });
                }
                let r = f.result(i);
                f.values[r.idx()].def = ValueDef::Alias(acc.unwrap());
            }
        }
        f.blocks[b.idx()].insts = out;
    }
    exts
}
