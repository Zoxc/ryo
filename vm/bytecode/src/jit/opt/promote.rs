//! Promotion of memory allocas that nothing reaches through a pointer any more (design/jit.md,
//! "Inlining"): construction makes an alloca memory when its address escapes, into a call
//! say; once the call is inlined and the folds turned the accesses through the address into
//! accesses of the alloca ([`super::fold::fold_addr`]), its address may have no use left. An
//! alloca is promoted when it isn't pinned, nothing takes its address (no
//! [`Op::AllocaAddr`] of it is left), no handler or island names it, and its accesses
//! ([`Op::ALoad`], [`Op::AStore`]) are at power-of-two widths to fields that are equal or
//! disjoint. Its fields become SSA values (Braun et al. again, on the IR): a load is replaced
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
    let mut live: Vec<Block> = f.layout.clone();
    live.extend(f.osr.iter().flatten().copied());
    let mut acc: Vec<Vec<(i32, u8)>> = alloc::vec![Vec::new(); na];
    for &b in &live {
        for &i in &f.blocks[b.idx()].insts {
            match &f.insts[i.idx()].op {
                Op::AllocaAddr(a, _) => ok[a.idx()] = false,
                Op::ALoad(a, o, w) | Op::AStore(a, o, w) => {
                    if w.is_power_of_two() && *w <= 8 && *o >= 0 && (*o as u32 + *w as u32) <= f.allocas[a.idx()].size {
                        acc[a.idx()].push((*o, *w));
                    } else {
                        ok[a.idx()] = false;
                    }
                }
                Op::HCall(h) => {
                    for r in &h.regs {
                        for s in r.1.iter().flatten() {
                            if let SlotRef::Alloca(a, _) = s {
                                ok[a.idx()] = false;
                            }
                        }
                    }
                }
                Op::Island(isl) => {
                    for s in &isl.ops {
                        if let SlotRef::Alloca(a, _) = s {
                            ok[a.idx()] = false;
                        }
                    }
                }
                _ => {}
            }
        }
    }
    // Fields: equal or disjoint.
    let mut fields: Vec<Field> = Vec::new();
    let mut field_of: BTreeMap<(u32, i32, u8), u32> = BTreeMap::new();
    for a in 0..na {
        if !ok[a] {
            continue;
        }
        let mut fs = core::mem::take(&mut acc[a]);
        fs.sort_unstable();
        fs.dedup();
        if fs.windows(2).any(|p| p[0].0 + p[0].1 as i32 > p[1].0) {
            ok[a] = false;
            continue;
        }
        for (o, w) in fs {
            field_of.insert((a as u32, o, w), fields.len() as u32);
            fields.push((AllocaId(a as u32), o, w));
        }
    }
    if !ok.iter().any(|&x| x) {
        return Ok(false);
    }
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
    super::super::inline::rebuild_preds(f);
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
        let insts = p.f.blocks[b.idx()].insts.clone();
        for i in insts {
            let op = p.f.insts[i.idx()].op.clone();
            let Some(k) = field(&op) else { continue };
            match op {
                Op::AStore(..) => {
                    cur.insert(k, p.f.insts[i.idx()].args[0]);
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
            let mut same = None;
            let mut many = false;
            for &o in ops {
                let o = f.resolve(o);
                if o == p || Some(o) == same {
                    continue;
                }
                if same.is_some() {
                    many = true;
                    break;
                }
                same = Some(o);
            }
            if !many {
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
        let preds = f.blocks[b.idx()].preds.clone();
        for (j, (q, e)) in preds.into_iter().enumerate() {
            let mut t = core::mem::replace(&mut f.blocks[q.idx()].term, Term::None);
            t.edges_mut()[e as usize].args.push(ops[j]);
            f.blocks[q.idx()].term = t;
        }
    }
    for i in dead {
        let b = f.insts[i.idx()].block;
        f.blocks[b.idx()].insts.retain(|&x| x != i);
    }
    f.resolve_aliases();
    for a in 0..na {
        if ok[a] {
            f.allocas[a].kind = AllocaKind::Promoted;
        }
    }
    Ok(true)
}
