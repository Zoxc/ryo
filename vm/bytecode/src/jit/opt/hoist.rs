//! Loop-invariant code motion (design/jit.md, "Loop-invariant code motion"): a pure
//! operation, or a load nothing in its loop may write, whose operands are all defined outside
//! the loop (or are themselves hoisted) moves to the loop's preheader, innermost loops first,
//! so a value invariant in several levels moves out of each in turn.
//! Only with [`Func::licm`] (`RYO_JIT_LICM=1`); otherwise only `vsplat`s move, by the same
//! rules.
//!
//! - **Loops**: natural loops of the dominators without the OSR edges
//!   ([`super::osr::normal_idoms`]): a head, the normal predecessors it dominates (latches),
//!   and the blocks that reach them without passing the head. Only instructions in blocks no
//!   other head's OSR entry reaches without passing the head move: the values used there may
//!   come from that entry (an inner loop's), where nothing hoisted to the preheader exists.
//! - **Preheader**: the head's one entry predecessor if it ends in a jump, or a new block that
//!   the entry edges go to instead, with the head's parameters, jumping to the head.
//! - **Operands**: constants, values defined outside the loop, the results of instructions
//!   hoisted before, a head parameter with one value on every normal edge
//!   ([`super::osr::invariant`]: the preheader takes the value its edge passes), and frame and
//!   constant addresses (`AllocaAddr`, `RefAddr` without `ind`), which are recomputed rather
//!   than moved, being cheaper to recompute than to keep live (as `regalloc::remat` does).
//! - **OSR**: a head with an OSR entry may be entered at its start without passing the
//!   preheader. A hoisted value then becomes a new head parameter: the preheader passes it,
//!   each latch the parameter itself, and the OSR entry a copy computed from the entry's
//!   values of the head's parameters, in a *landing* block between the entry and the head
//!   ([`super::osr::osr_landing`]: the entry itself only loads from the AOT frame). That is
//!   the OSR-transparency rule ([`super::osr`]): an invariant head parameter is the value of
//!   its normal edges also when the head is entered by OSR, so the copy computes the same
//!   value, and a load nothing in the loop writes reads the same bytes at the head on every
//!   iteration.
//! - **Loads** (`Load`, `ALoad`) move when nothing in the loop may write their bytes (what
//!   [`super::lvn`] forgets them for: a pointer store but one through the same pointer to
//!   other bytes, a handler touching memory or naming the alloca, a call, an island). A load
//!   through a pointer, a division (it traps on 0) and an effect-free handler call (dce's
//!   `removable`) may fault, so they move only if they run whenever the head does: on every
//!   path from the head before any exit or latch, without a cycle or a call on the way.
//! - **Uses**: an instruction moves only if something in the loop uses it (a value only an
//!   exit or a cold path uses would just be live across the loop), or a hoisted one does.
//! - **Register pressure**: a hoisted value is live across the whole loop (the register
//!   allocator's intervals are hulls in the layout). The expensive operations (divisions,
//!   splats, handler calls, `RefAddr`s through two loads) always move. A cheap one moves only
//!   if it runs on every iteration, no call is laid out within the loop (one that would make
//!   the value live across it, in a callee-saved register or a spill slot), and it takes the
//!   register of an operand nothing else in the loop uses: then it costs the loop no register
//!   (a loop that runs once would pay for a new one). Cheap operations a moved one needs are
//!   copied out with it, and stay where they are for their other uses.

use alloc::vec::Vec;

use super::osr::{invariant, normal_idoms, normal_preds, osr_edge};
use crate::jit::ir::*;

pub fn hoist(f: &mut Func) {
    if !f.licm && !f.layout.iter().any(|b| f.blocks[b.idx()].insts.iter().any(|i| f.insts[i.idx()].op == Op::V(VOp::Splat))) {
        return;
    }
    // Without a backward edge in the layout there is no loop (a cycle has one).
    let mut at = alloc::vec![usize::MAX; f.blocks.len()];
    for (k, &b) in f.layout.iter().enumerate() {
        at[b.idx()] = k;
    }
    if !f.layout.iter().enumerate().any(|(k, &b)| f.blocks[b.idx()].term.edges().any(|e| at[e.to.idx()] <= k)) {
        return;
    }
    let mut done: Vec<Block> = Vec::new();
    let mut an = Analysis::new(f);
    loop {
        let Some(l) = an.loops.iter().filter(|l| !done.contains(&l.head)).min_by_key(|l| l.size) else { break };
        done.push(l.head);
        if licm(f, &an, l) {
            f.resolve_aliases();
            an = Analysis::new(f);
        }
    }
}

pub(super) struct Loop {
    pub(super) head: Block,
    pub(super) latches: Vec<Block>,
    /// By block, whether it is in the loop.
    pub(super) body: Vec<bool>,
    size: usize,
}

pub(super) struct Analysis {
    rpo: Vec<Block>,
    /// By block, its index in reverse postorder (`u32::MAX` if unreachable).
    ord: Vec<u32>,
    /// Without the OSR edges.
    ndom: Dom,
    pub(super) loops: Vec<Loop>,
}

/// Immediate dominators, `None` for the roots and unreachable blocks.
#[derive(Clone)]
pub(super) struct Dom(pub(super) Vec<Option<Block>>);

impl Dom {
    pub(super) fn dominates(&self, a: Block, b: Block) -> bool {
        let mut x = Some(b);
        while let Some(y) = x {
            if y == a {
                return true;
            }
            x = self.0[y.idx()];
        }
        false
    }
}

impl Analysis {
    pub(super) fn new(f: &Func) -> Analysis {
        let rpo = f.rpo();
        let mut ord = alloc::vec![u32::MAX; f.blocks.len()];
        for (k, b) in rpo.iter().enumerate() {
            ord[b.idx()] = k as u32;
        }
        let ndom = Dom(if f.osr.iter().any(Option::is_some) { normal_idoms(f, &rpo) } else { f.idoms(&rpo) });
        let mut loops = Vec::new();
        for &h in &rpo {
            if f.blocks[h.idx()].kind != BlockKind::Body {
                continue;
            }
            // Only a retreating edge can be a back edge.
            let latches: Vec<Block> = normal_preds(f, h)
                .map(|(p, _)| p)
                .filter(|&p| ord[p.idx()] >= ord[h.idx()] && ord[p.idx()] != u32::MAX && ndom.dominates(h, p))
                .collect();
            if latches.is_empty() {
                continue;
            }
            let mut body = alloc::vec![false; f.blocks.len()];
            body[h.idx()] = true;
            let mut size = 1;
            let mut stack = latches.clone();
            while let Some(b) = stack.pop() {
                if body[b.idx()] || !ndom.dominates(h, b) {
                    continue;
                }
                body[b.idx()] = true;
                size += 1;
                stack.extend(normal_preds(f, b).map(|(p, _)| p));
            }
            loops.push(Loop { head: h, latches, body, size });
        }
        Analysis { rpo, ord, ndom, loops }
    }
}

/// What moving an instruction needs.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Class {
    /// An address: recomputed where a hoisted instruction needs it, never moved.
    Remat,
    /// Pure and can't fault.
    Pure,
    /// Pure but may fault: it must run whenever the head does.
    Faults,
    /// A load through a pointer: unwritten in the loop, and as [`Class::Faults`].
    Load,
    /// A load of an alloca: unwritten in the loop.
    ALoad,
}

fn class(f: &Func, op: &Op) -> Option<Class> {
    if !f.licm {
        // Only splats (hashbrown's probe loop splats its tag once).
        return match op {
            Op::V(VOp::Splat) => Some(Class::Pure),
            Op::AllocaAddr(..) | Op::RefAddr(_, false) => Some(Class::Remat),
            _ => None,
        };
    }
    Some(match op {
        Op::AllocaAddr(..) | Op::RefAddr(_, false) => Class::Remat,
        Op::Bin(BinOp::DivS | BinOp::DivU | BinOp::RemS | BinOp::RemU, _) => Class::Faults,
        // Its flag feeds the branch it is fused with, or the checks left it.
        Op::Ovf(..) | Op::OsrLoad(..) | Op::LandingPad => return None,
        Op::Load(..) => Class::Load,
        Op::ALoad(..) => Class::ALoad,
        Op::HCall(h) if super::dce::removable(op) && h.regs.iter().all(|r| r.1.iter().all(Option::is_none)) => Class::Faults,
        op if op.pure() => Class::Pure,
        _ => return None,
    })
}

/// Worth keeping live across a call rather than recomputing.
fn expensive(op: &Op) -> bool {
    matches!(op, Op::Bin(BinOp::DivS | BinOp::DivU | BinOp::RemS | BinOp::RemU, _) | Op::V(VOp::Splat) | Op::HCall(_) | Op::RefAddr(_, true))
}

/// What the instructions of a loop may write.
#[derive(Default)]
struct Writes {
    /// Anything (an island, an instruction of unknown effect).
    all: bool,
    /// Any memory through a pointer.
    ptr: bool,
    /// The escaped and pinned allocas.
    aliasable: bool,
    /// A call: also the allocas that aren't memory or incoming.
    call: bool,
    stores: Vec<(Value, i64, i64)>,
    astores: Vec<(AllocaId, i64, i64)>,
    named: Vec<AllocaId>,
}

impl Writes {
    fn of(f: &Func, l: &Loop) -> Writes {
        let mut w = Writes::default();
        let aliasable = |a: AllocaId| f.allocas[a.idx()].escaped || f.allocas[a.idx()].pinned;
        for (b, _) in l.body.iter().enumerate().filter(|x| *x.1) {
            for &i in &f.blocks[b].insts {
                let id = &f.insts[i.idx()];
                match id.op {
                    Op::Load(..) | Op::ALoad(..) => {}
                    ref op if op.pure() => {}
                    Op::Store(n, k) => {
                        w.stores.push((id.args[0], k as i64, k as i64 + n as i64));
                        w.aliasable = true;
                    }
                    Op::AStore(a, k, n) => {
                        w.astores.push((a, k as i64, k as i64 + n as i64));
                        w.ptr |= aliasable(a);
                    }
                    Op::HCall(ref h) => {
                        w.named.extend(
                            h.regs.iter().flat_map(|r| r.1).flatten().filter_map(|s| if let SlotRef::Alloca(a, _) = s { Some(a) } else { None }),
                        );
                        if crate::jit::effects::effects(h.h).is_none_or(|e| e.memory) {
                            w.ptr = true;
                            w.aliasable = true;
                        }
                    }
                    Op::Call(_) => {
                        w.ptr = true;
                        w.aliasable = true;
                        w.call = true;
                    }
                    _ => w.all = true,
                }
            }
        }
        w
    }

    /// Whether the loop may write what `i` (a load) reads.
    fn clobbers(&self, f: &Func, i: Inst) -> bool {
        let id = &f.insts[i.idx()];
        let over = |lo: i64, hi: i64, a: i64, b: i64| lo < b && a < hi;
        self.all
            || match id.op {
                Op::Load(n, k) => {
                    let (p, lo, hi) = (id.args[0], k as i64, k as i64 + n as i64);
                    self.ptr || self.stores.iter().any(|&(q, a, b)| q != p || over(lo, hi, a, b))
                }
                Op::ALoad(a, k, n) => {
                    let (lo, hi) = (k as i64, k as i64 + n as i64);
                    let al = &f.allocas[a.idx()];
                    self.astores.iter().any(|&(x, s, e)| x == a && over(lo, hi, s, e))
                        || ((al.escaped || al.pinned) && self.aliasable)
                        || self.named.contains(&a)
                        || (self.call && !matches!(al.kind, AllocaKind::Memory | AllocaKind::Incoming))
                }
                _ => true,
            }
    }
}

/// Whether `b` runs whenever `l`'s head does, before the loop is left or goes around: every
/// path from the head reaches it without a cycle, an exit, a latch or a call.
fn runs(f: &Func, an: &Analysis, l: &Loop, b: Block) -> bool {
    let h = l.head;
    let mut seen = alloc::vec![false; f.blocks.len()];
    let mut stack = alloc::vec![h];
    while let Some(c) = stack.pop() {
        if c == b || core::mem::replace(&mut seen[c.idx()], true) {
            continue;
        }
        if f.blocks[c.idx()].insts.iter().any(|i| f.insts[i.idx()].op.is_call()) {
            return false;
        }
        for e in f.blocks[c.idx()].term.edges() {
            let d = e.to;
            // An exit, a latch, or an edge back in reverse postorder (a cycle may run forever).
            if !l.body[d.idx()] || d == h || an.ord[d.idx()] <= an.ord[c.idx()] {
                return false;
            }
            stack.push(d);
        }
    }
    true
}

/// A new block with `h`'s parameters that `edges` (into `h`) go to instead, jumping on to `h`
/// with them.
fn split_edges(f: &mut Func, h: Block, edges: &[(Block, u16)]) -> Block {
    let p = f.block(BlockKind::Body);
    let ws: Vec<u8> = f.blocks[h.idx()].params.iter().map(|&v| f.w(v)).collect();
    let args: Vec<Value> = ws.iter().map(|&w| f.param(p, w)).collect();
    for &(e, k) in edges {
        let mut t = core::mem::replace(&mut f.blocks[e.idx()].term, Term::None);
        t.edge_mut(k as usize).to = p;
        f.blocks[e.idx()].term = t;
    }
    f.blocks[p.idx()].term = Term::Jmp(Edge { to: h, args });
    p
}

/// The arguments block `b`'s jump to the head passes.
fn jmp_args(f: &Func, b: Block) -> &[Value] {
    let Term::Jmp(e) = &f.blocks[b.idx()].term else { unreachable!("a preheader or landing ends in a jump") };
    &e.args
}

/// Hoists `l`'s invariants. Whether anything moved.
fn licm(f: &mut Func, an: &Analysis, l: &Loop) -> bool {
    let h = l.head;
    let osr = f.blocks[h.idx()].preds.iter().map(|&(p, _)| p).find(|&p| osr_edge(f, p));
    let entries: Vec<(Block, u16)> = normal_preds(f, h).filter(|&(p, _)| !l.body[p.idx()]).collect();
    if entries.is_empty() {
        return false;
    }
    let inv: Vec<bool> = (0..f.blocks[h.idx()].params.len()).map(|n| invariant(f, h, n).is_some()).collect();
    let in_loop = |f: &Func, v: Value| match f.def(v) {
        ValueDef::Inst(j, _) => l.body[f.insts[j.idx()].block.idx()],
        ValueDef::Param(b, _) => l.body[b.idx()],
        _ => false,
    };
    let writes = Writes::of(f, l);
    // The blocks another head's OSR entry reaches without passing this head: the values
    // there may come from that entry instead (the head doesn't dominate them).
    let mut other_osr = Vec::new();
    if f.osr.iter().flatten().count() > 1 {
        other_osr = alloc::vec![false; f.blocks.len()];
        let mut stack: Vec<Block> = f.osr.iter().flatten().copied().collect();
        while let Some(b) = stack.pop() {
            if b == h || core::mem::replace(&mut other_osr[b.idx()], true) {
                continue;
            }
            stack.extend(f.blocks[b.idx()].term.edges().map(|e| e.to));
        }
    }
    let mut cand: Vec<Inst> = Vec::new();
    let mut is_cand = alloc::vec![false; f.values.len()];
    // In reverse postorder, so that operands come first.
    for &b in an.rpo.iter().filter(|b| l.body[b.idx()]) {
        let bi = b.idx();
        if other_osr.get(bi).copied().unwrap_or(false) {
            continue;
        }
        let mut runs_b = None;
        let mut call = false;
        for &i in &f.blocks[bi].insts {
            let id = &f.insts[i.idx()];
            let Some(c) = class(f, &id.op).filter(|&c| c != Class::Remat) else {
                call |= id.op.is_call();
                continue;
            };
            let ok = id.args.iter().all(|&a| match f.def(a) {
                ValueDef::Const(_) => true,
                ValueDef::Param(p, n) if p == h => inv[n as usize],
                ValueDef::Inst(j, _) if in_loop(f, a) => {
                    is_cand[a.idx()] || (class(f, &f.insts[j.idx()].op) == Some(Class::Remat) && f.insts[j.idx()].args.is_empty())
                }
                // Defined before the loop: not where an OSR entry lands.
                ValueDef::Inst(..) | ValueDef::Param(..) => osr.is_none() && !in_loop(f, a),
                _ => false,
            });
            let ok = ok
                && match c {
                    Class::Pure => true,
                    // An OSR entry doesn't convert an inlined callee's allocas.
                    Class::ALoad => !writes.clobbers(f, i) && !(osr.is_some() && matches!(id.op, Op::ALoad(a, ..) if f.allocas[a.idx()].inlined)),
                    Class::Load => !writes.clobbers(f, i) && !call && *runs_b.get_or_insert_with(|| runs(f, an, l, b)),
                    _ => !call && *runs_b.get_or_insert_with(|| runs(f, an, l, b)),
                };
            call |= id.op.is_call();
            if ok {
                cand.push(i);
                for r in id.results() {
                    is_cand[r.idx()] = true;
                }
            }
        }
    }
    if cand.is_empty() {
        return false;
    }
    // The values the loop uses but for the candidates' operands (and a head parameter passed
    // on unchanged).
    let mut used = alloc::vec![false; f.values.len()];
    // A call where the loop is laid out (the register allocator's intervals are hulls in the
    // layout, so the hoisted values would cross it), but on paths that end in a trap (cold).
    let pos: Vec<usize> = f.layout.iter().enumerate().filter(|x| l.body[x.1.idx()]).map(|x| x.0).collect();
    let (lo, hi) = (pos.iter().copied().min().unwrap_or(0), pos.iter().copied().max().unwrap_or(0));
    let has_call = f.layout[lo..=hi].iter().any(|&b| {
        let bd = &f.blocks[b.idx()];
        !matches!(bd.term, Term::Trap | Term::Invoke { normal: None, .. }) && bd.insts.iter().any(|&i| f.insts[i.idx()].op.is_call())
    });
    for (bi, _) in l.body.iter().enumerate().filter(|x| *x.1) {
        let bd = &f.blocks[bi];
        for &i in &bd.insts {
            let id = &f.insts[i.idx()];
            if !id.results().any(|r| is_cand[r.idx()]) {
                id.args.iter().for_each(|a| used[a.idx()] = true);
            }
        }
        bd.term.uses().iter().for_each(|a| used[a.idx()] = true);
        for e in bd.term.edges().filter(|e| l.body[e.to.idx()]) {
            for (n, &a) in e.args.iter().enumerate() {
                if e.to != h || f.blocks[h.idx()].params.get(n) != Some(&a) {
                    used[a.idx()] = true;
                }
            }
        }
    }
    // Moved (the loop uses the hoisted value), or copied (only hoisted ones do). A cheap one
    // only if it ran on every iteration, the loop has no call, and it takes the register of an
    // operand that nothing else in the loop needs: it then costs no register there (a loop
    // that runs once would pay for a new one, a callee-saved register's save and restore say).
    let moved: Vec<bool> = cand
        .iter()
        .map(|&i| {
            let id = &f.insts[i.idx()];
            let every = || l.latches.iter().all(|&p| an.ndom.dominates(id.block, p));
            let frees = || {
                id.args.iter().any(|&a| match f.def(a) {
                    ValueDef::Inst(j, _) => !used[a.idx()] && class(f, &f.insts[j.idx()].op) != Some(Class::Remat),
                    ValueDef::Param(..) => !used[a.idx()],
                    _ => false,
                })
            };
            id.results().any(|r| used[r.idx()]) && (expensive(&id.op) || (!has_call && every() && frees()))
        })
        .collect();
    let mut want = alloc::vec![false; f.values.len()];
    let mut copied = alloc::vec![false; cand.len()];
    for k in (0..cand.len()).rev() {
        let id = &f.insts[cand[k].idx()];
        if !moved[k] && !id.results().any(|r| want[r.idx()]) {
            continue;
        }
        copied[k] = !moved[k];
        id.args.iter().for_each(|a| want[a.idx()] = true);
    }
    if !moved.iter().any(|&m| m) {
        return false;
    }

    // The preheader, and the OSR entry's landing.
    let (pre, new_pre) = match entries[..] {
        [(e, _)] if matches!(f.blocks[e.idx()].term, Term::Jmp(_)) && matches!(f.blocks[e.idx()].kind, BlockKind::Entry | BlockKind::Body) => {
            (e, false)
        }
        _ => {
            let p = split_edges(f, h, &entries);
            let at = f.layout.iter().position(|&b| b == h).unwrap();
            f.layout.insert(at, p);
            (p, true)
        }
    };
    let land = osr.map(|o| {
        if !matches!(f.blocks[o.idx()].kind, BlockKind::Osr(_)) {
            return o;
        }
        let t = split_edges(f, h, &[(o, 0)]);
        // Before the head (and a new preheader, which falls through to it), not before the
        // entry. Laid out after the head, its jump would count as a latch.
        let at = f.layout.iter().position(|&b| b == h).unwrap() - new_pre as usize;
        f.layout.insert(at, t);
        t
    });
    f.rebuild_preds();

    // Per context (the preheader, the landing), the hoisted values.
    let ctxs: Vec<Block> = core::iter::once(pre).chain(land).collect();
    let mut map: Vec<Vec<(Value, Value)>> = alloc::vec![Vec::new(); ctxs.len()];
    let nparams = inv.len();
    // The instructions hoisted to the preheader, and what the loop uses for each result (its
    // head parameter with an OSR entry); per context, the instructions made there.
    let mut made: Vec<Vec<Inst>> = alloc::vec![Vec::new(); ctxs.len()];
    let mut to_of: Vec<(Inst, Vec<Value>)> = Vec::new();
    for (k, &i) in cand.iter().enumerate() {
        if !moved[k] && !copied[k] {
            continue;
        }
        let (op, args) = (f.insts[i.idx()].op.clone(), f.insts[i.idx()].args.clone());
        let res: Vec<Value> = f.insts[i.idx()].results().collect();
        let ws: Vec<u8> = res.iter().map(|&r| f.w(r)).collect();
        let mut outs: Vec<Vec<Value>> = Vec::new();
        let mut ins: Vec<Inst> = Vec::new();
        for (c, &cb) in ctxs.iter().enumerate() {
            let mut xs = Vec::with_capacity(args.len());
            for &a in &args {
                let x = match f.def(a) {
                    ValueDef::Param(p, n) if p == h && (n as usize) < nparams => jmp_args(f, cb)[n as usize],
                    ValueDef::Inst(j, _) if in_loop(f, a) && !is_cand[a.idx()] => {
                        // An address, recomputed here.
                        match map[c].iter().find(|m| m.0 == a) {
                            Some(m) => m.1,
                            None => {
                                let op = f.insts[j.idx()].op.clone();
                                let n = f.inst(cb, op, Vec::new(), &[f.w(a)]);
                                let v = f.result(n);
                                map[c].push((a, v));
                                v
                            }
                        }
                    }
                    _ => map[c].iter().find(|m| m.0 == a).map_or(a, |m| m.1),
                };
                xs.push(x);
            }
            // The same operation on the same operands, hoisted from elsewhere in the loop.
            let eq = |a: Value, b: Value| {
                a == b || (matches!((f.def(a), f.def(b)), (ValueDef::Const(x), ValueDef::Const(y)) if x == y) && f.w(a) == f.w(b))
            };
            let same = made[c].iter().copied().find(|&j| f.insts[j.idx()].op == op && f.insts[j.idx()].args.iter().zip(&xs).all(|(&a, &b)| eq(a, b)));
            let n = same.unwrap_or_else(|| f.inst(cb, op.clone(), xs, &ws));
            made[c].push(n);
            ins.push(n);
            let vs: Vec<Value> = f.insts[n.idx()].results().collect();
            for (&r, &v) in res.iter().zip(&vs) {
                map[c].push((r, v));
            }
            outs.push(vs);
        }
        if !moved[k] {
            continue;
        }
        let b = f.insts[i.idx()].block;
        f.blocks[b.idx()].insts.retain(|&x| x != i);
        if let Some((_, to)) = to_of.iter().find(|t| t.0 == ins[0]) {
            for (&r, &v) in res.iter().zip(to) {
                f.values[r.idx()].def = ValueDef::Alias(v);
            }
            continue;
        }
        let mut tos = Vec::new();
        for (n, &r) in res.iter().enumerate() {
            let to = match land {
                None => outs[0][n],
                Some(t) => {
                    let ph = f.param(h, ws[n]);
                    for (q, e) in f.blocks[h.idx()].preds.clone() {
                        let a = if q == pre {
                            outs[0][n]
                        } else if q == t {
                            outs[1][n]
                        } else {
                            ph
                        };
                        let mut term = core::mem::replace(&mut f.blocks[q.idx()].term, Term::None);
                        term.edge_mut(e as usize).args.push(a);
                        f.blocks[q.idx()].term = term;
                    }
                    ph
                }
            };
            f.values[r.idx()].def = ValueDef::Alias(to);
            tos.push(to);
        }
        to_of.push((ins[0], tos));
    }
    true
}
