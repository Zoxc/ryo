//! Inlining in the SSA tier (design/jit.md, "Inlining"): calls of VM functions (of the
//! root's image directly, of any image through a symbol) are replaced by copies of their IR,
//! so that one JIT unit runs the root and the callees it decides on in one frame. Another
//! image's callee is first put in the root's image's terms ([`rebase`]).
//!
//! - **Exploration**: from the root, its direct calls by weight, each callee's optimized IR
//!   from the JIT's cache ([`Env::ir`]), to a depth and an IR budget, skipping what can't be
//!   inlined (recursion, tail calls, stack arguments, symbols, ...).
//! - **Clusters**: bottom-up, a node absorbs the child cluster with the best benefit per cost
//!   while that raises its own, and a cluster is inlined whole or not at all.
//! - **Selection**: clusters by benefit per cost against the budget; the children of an
//!   accepted cluster it didn't absorb become candidates.
//! - **Splice** ([`splice`]): IR to IR. The callee's allocas, values and blocks are copied
//!   with fresh ids; its entry parameters become the call's arguments, its returns jumps to
//!   the continuation, whose parameters are the call's results; a callee call that unwinds
//!   to its caller takes the call site's action (its landing pad, or none); its loop heads
//!   are ordinary blocks, without OSR entries.
//!
//! Weights are static: 1 per call site, 8 per loop level, 1/16 in cold blocks and for
//! `#[cold]` callees.
//!
//! The source attributes ([`Env::flags`]): an `#[inline(never)]` callee isn't inlined; a
//! `#[cold]` one is weighted as a cold block's call, and the profile doesn't raise it; an
//! `#[inline(always)]` one (not at a cold site) is selected ahead of the others and without
//! the ratio bar, still under the unit's cap and frame limit, and its edge doesn't count
//! toward [`Params::max_depth`] (up to [`Params::always_depth`] more). `#[inline]` is carried
//! but unused.

use alloc::collections::BTreeMap;
use alloc::rc::Rc;
use alloc::string::String;
use alloc::vec::Vec;
use core::fmt::Write;

use super::ir::*;
use crate::asm::Ref;
use crate::full::{Func as FuncIdx, Opcode, Sym};
use crate::image::{FUNC_COLD, FUNC_INLINE_ALWAYS, FUNC_INLINE_NEVER};
use crate::reduced::Arg;

/// An image, by its header's address: opaque to the inliner.
pub type ImageId = usize;

/// A VM function: its image and its index there.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct VmFunc {
    pub img: ImageId,
    pub func: FuncIdx,
}

impl VmFunc {
    fn key(self) -> (usize, u32) {
        (self.img, self.func.0)
    }
}

/// What the inliner needs from the JIT.
///
/// The unit's IR names functions, symbols, constants, data and site caches of the root's
/// image (or the JIT's call forms, [`Env::retarget`]); a callee of another image is
/// [`rebase`]d into those terms before it is explored.
pub trait Env {
    /// The root.
    fn root(&self) -> VmFunc;
    /// Function `g` as [`super::ir_of`] gives it in its image's terms, or `None` if it can't
    /// be built or its image's mode isn't the root's (the JIT caches them per image).
    fn ir(&mut self, g: VmFunc) -> Option<Rc<Func>>;
    /// The VM function a call of the unit with target `t` calls, if known: a function of the
    /// root's image, a symbol whose slot holds a VM function's entry (of any image), or a
    /// call form [`Env::retarget`] gave.
    fn callee(&mut self, t: CallTarget) -> Option<VmFunc>;
    /// The target to call `t` (a function of image `img` or one of its symbols) by in the
    /// unit: the JIT's call forms (a function operand with an [`crate::asm::FUNC_KINDS`] bit,
    /// through a call slot, directly, or through `r11`), or a call of the root itself. For
    /// the root's image, `None` keeps `t`, as for the root's calls of itself.
    fn retarget(&mut self, img: ImageId, t: CallTarget) -> Option<CallTarget>;
    /// The address of `r` (a constant, data area offset, symbol slot, site cache slot or code
    /// constant) of image `img`, and for a symbol the value its slot holds (filled before any
    /// VM code runs, and never again).
    fn addr(&self, img: ImageId, r: Ref) -> Option<u64>;
    fn sym_value(&self, img: ImageId, s: Sym) -> Option<u64>;
    /// How many times function `g`'s AOT code was called and how many loop iterations it
    /// ran (its JIT record's counters), if known.
    fn counts(&self, g: VmFunc) -> Option<(u64, u64)>;
    /// Function `g`'s flags ([`crate::image::FUNC_INLINE_ALWAYS`] etc.: its source
    /// attributes).
    fn flags(&self, g: VmFunc) -> u8;
    /// The target a call of the constant address `a` (in the unit's terms) calls it by, if
    /// `a` is a registered image's VM function's entry (its AOT entry: function pointers
    /// aren't re-linked): a function of the root's image, or another image's in the unit's
    /// call form ([`Env::retarget`]'s). `None` for anything else (a native, a stub, an
    /// interior address).
    fn direct(&mut self, a: u64) -> Option<CallTarget>;
}

/// The direct target of a call through the pointer `v` of `f`, if known: the symbol `s`
/// for its slot's value (`call [rip + slot]` reads the same slot), or what [`Env::direct`]
/// gives for a constant.
fn direct_target(f: &Func, v: Value, env: &mut dyn Env) -> Option<CallTarget> {
    let mut v = f.resolve(v);
    loop {
        match f.def(v) {
            ValueDef::Const(a) if f.w(v) == 8 => return env.direct(a),
            ValueDef::Inst(i, 0) => match f.insts[i.idx()].op {
                Op::RefAddr(Ref::Sym(s), false) => return Some(CallTarget::Sym(s)),
                // A rebased callee's symbol value, before the folds.
                Op::PtrAdd(0) => v = f.resolve(f.insts[i.idx()].args[0]),
                _ => return None,
            },
            _ => return None,
        }
    }
}

/// The calls and tail calls (by their block, for a tail call) through a pointer of `f`
/// that [`direct_target`] knows the targets of.
fn devirt_sites(f: &Func, env: &mut dyn Env) -> Vec<(Block, Option<Inst>, CallTarget)> {
    let mut v = Vec::new();
    for b in f.live_blocks() {
        let bd = &f.blocks[b.idx()];
        for &i in &bd.insts {
            if let Op::Call(c) = &f.insts[i.idx()].op
                && c.target == CallTarget::Ptr
                && let Some(t) = direct_target(f, f.insts[i.idx()].args[0], env)
            {
                v.push((b, Some(i), t));
            }
        }
        if let Term::TailCall { call, args } = &bd.term
            && call.target == CallTarget::Ptr
            && let Some(t) = direct_target(f, args[0], env)
        {
            v.push((b, None, t));
        }
    }
    v
}

/// Devirtualization (design/jit.md, "Inlining"): the calls of `f` through a pointer whose
/// target is known ([`direct_target`]) become direct calls of it, with the same arguments,
/// results and unwinding. Returns the calls it changed, and how many tail calls. Only for the
/// unit's IR: the targets of other images are the unit's call forms, so a cached IR
/// ([`Env::ir`]) is never changed.
pub fn devirt(f: &mut Func, env: &mut dyn Env) -> (Vec<Inst>, usize) {
    let sites = devirt_sites(f, env);
    let calls = apply_devirt(f, &sites);
    let tails = sites.len() - calls.len();
    (calls, tails)
}

fn apply_devirt(f: &mut Func, sites: &[(Block, Option<Inst>, CallTarget)]) -> Vec<Inst> {
    let mut new = Vec::new();
    for &(b, i, t) in sites {
        match i {
            Some(i) => {
                let id = &mut f.insts[i.idx()];
                let Op::Call(c) = &mut id.op else { unreachable!() };
                c.target = t;
                id.args.remove(0);
                new.push(i);
            }
            None => {
                let Term::TailCall { call, args } = &mut f.blocks[b.idx()].term else { unreachable!() };
                call.target = t;
                args.remove(0);
            }
        }
    }
    new
}

/// `c`, a function of image `img`, in the terms of the root's image (design/jit.md,
/// "Inlining", across images): its constants', data's and site caches' addresses become constants, its
/// symbols' values constants (loaded through for an indirect one), its calls and islands the
/// JIT's call forms of their targets, a call through a symbol's pointer (PE) a call of the
/// loaded pointer, and code constant arguments (sparse switch cases) their addresses in the
/// callee's image. An error with what it can't express: tail calls.
pub fn rebase(c: &Func, img: ImageId, env: &mut dyn Env) -> Result<Func, &'static str> {
    let mut g = c.clone();
    for b in c.live_blocks() {
        if matches!(g.blocks[b.idx()].term, Term::TailCall { .. }) {
            return Err("a tail call");
        }
        // A `while`: a rebased call through a symbol's pointer adds a load before it.
        let mut k = 0;
        while k < g.blocks[b.idx()].insts.len() {
            let i = g.blocks[b.idx()].insts[k];
            k += 1;
            let op = g.insts[i.idx()].op.clone();
            match op {
                Op::RefAddr(Ref::Sym(s), ind) => {
                    let v = env.sym_value(img, s).ok_or("a symbol")?;
                    let k = g.konst(v, 8);
                    let id = &mut g.insts[i.idx()];
                    id.op = if ind { Op::Load(8, 0) } else { Op::PtrAdd(0) };
                    id.args = alloc::vec![k];
                }
                Op::RefAddr(r, _) => {
                    let a = env.addr(img, r).ok_or("an address")?;
                    let k = g.konst(a, 8);
                    let id = &mut g.insts[i.idx()];
                    id.op = Op::PtrAdd(0);
                    id.args = alloc::vec![k];
                }
                Op::HCall(mut h) => {
                    for (a, patch) in h.regs.iter_mut() {
                        let r = match *a {
                            Arg::Const(x) => Ref::Const(x),
                            Arg::Data(x) => Ref::Data(x),
                            Arg::Sym(x) => Ref::Sym(x),
                            Arg::Site(x) => Ref::Site(x),
                            // A sparse switch's case values: in the callee image's code
                            // constants, which stay mapped.
                            Arg::Ro(x) => Ref::Ro(x),
                            _ => continue,
                        };
                        *a = Arg::Imm(env.addr(img, r).ok_or("an address")?);
                        *patch = [None, None];
                    }
                    g.insts[i.idx()].op = Op::HCall(h);
                }
                Op::Call(mut x) => {
                    match x.target {
                        CallTarget::Func(_) | CallTarget::Sym(_) => x.target = env.retarget(img, x.target).ok_or("a call")?,
                        // PE's `__imp_` indirection: a call of the pointer the slot's value
                        // points at, loaded before the call (the loader fills it).
                        CallTarget::SymInd(s) => {
                            let v = env.sym_value(img, s).ok_or("a symbol")?;
                            let kv = g.konst(v, 8);
                            let ld = g.inst(b, Op::Load(8, 0), alloc::vec![kv], &[8]);
                            let insts = &mut g.blocks[b.idx()].insts;
                            insts.pop();
                            insts.insert(k - 1, ld);
                            k += 1;
                            let p = g.result(ld);
                            g.insts[i.idx()].args.insert(0, p);
                            x.target = CallTarget::Ptr;
                        }
                        CallTarget::Ptr => {}
                    }
                    g.insts[i.idx()].op = Op::Call(x);
                }
                // A native call with the island ABI (`fp`, the operand array), of the
                // island's address: its slot is filled before VM code runs.
                Op::Island(mut x) => {
                    x.isl = env.retarget(img, x.isl).ok_or("an island")?;
                    g.insts[i.idx()].op = Op::Island(x);
                }
                _ => {}
            }
        }
    }
    Ok(g)
}

/// The limits and constants of the heuristic.
#[derive(Clone, Copy, Debug)]
pub struct Params {
    /// How deep the exploration goes.
    pub max_depth: u32,
    /// How much deeper than `max_depth` `#[inline(always)]` edges, which don't count toward
    /// it, may take the exploration.
    pub always_depth: u32,
    /// The most IR (by cost) the exploration builds, all callees together.
    pub expand: f64,
    /// The largest unit, by cost.
    pub cap: f64,
    /// Always inlined at or below this cost.
    pub always: f64,
    /// The benefit per cost a cluster needs in an empty unit; it doubles every `scale` of
    /// unit size (the adaptive budget, Graal's incremental inliner, retuned).
    pub t1: f64,
    pub scale: f64,
    /// The largest unit of a root whose loops run at least `loopy` iterations per call.
    pub cap_loopy: f64,
    pub loopy: f64,
    /// Constant-specialized trials: for callees of at most this cost, at most `trials` per
    /// unit.
    pub trial_cost: f64,
    pub trials: usize,
    /// Root calls below which the profile isn't used.
    pub min_calls: u64,
    /// How far the profile may raise a site's weight above its static weight.
    pub raise: f64,
    /// The most frame bytes inlined allocas may add.
    pub frame: u32,
    /// The most nodes the exploration makes.
    pub nodes: usize,
    /// How many inlining rounds [`super::compile`] runs: each after the first explores only
    /// from the calls the round before made direct ([`devirt`]), against the unit as it is.
    pub rounds: u8,
}

pub const PARAMS: Params = Params {
    max_depth: 6,
    always_depth: 4,
    expand: 6000.0,
    cap: 2000.0,
    always: 12.0,
    t1: 0.303,
    scale: 400.0,
    cap_loopy: 3000.0,
    loopy: 100.0,
    trial_cost: 60.0,
    trials: 16,
    min_calls: 4,
    raise: 16.0,
    frame: 64 << 10,
    nodes: 400,
    rounds: 2,
};

/// `c` with its entry parameters given constants (`None`: unknown) replaced by them, after
/// [`super::opt::run`]: the trial of §5. The parameters stay, unused.
pub fn specialize(c: &Func, consts: &[Option<(u64, u8)>], mem: Option<&dyn super::opt::ConstMem>) -> Func {
    let mut g = c.clone();
    let Some(entry) = g.entry() else { return g };
    let params = g.blocks[entry].params.clone();
    let mut to: Vec<Option<Value>> = alloc::vec![None; g.values.len()];
    for (n, &p) in params.iter().enumerate() {
        if let Some(Some((bits, _))) = consts.get(n) {
            let w = g.w(p);
            to[p.idx()] = Some(g.konst(mask(*bits, w), w));
        }
    }
    let sub = |v: &mut Value| {
        if let Some(Some(x)) = to.get(v.idx()) {
            *v = *x;
        }
    };
    for id in g.insts.iter_mut() {
        id.args.iter_mut().for_each(sub);
    }
    for bd in g.blocks.iter_mut() {
        let mut t = core::mem::replace(&mut bd.term, Term::None);
        t.uses_mut().into_iter().for_each(sub);
        for e in t.edges_mut() {
            e.args.iter_mut().for_each(sub);
        }
        bd.term = t;
    }
    super::opt::run(&mut g, mem);
    g
}

/// A block's static frequency relative to the function's entry: 8 per loop level (counted
/// up to 4 levels), 1/16 in cold blocks: landing pad stubs, blocks that trap, and blocks all
/// of whose successors are cold.
pub struct Shape {
    pub weight: Vec<f64>,
    pub cold: Vec<bool>,
}

/// The successors of a block that its normal execution reaches (not a landing pad).
fn normal_succs(t: &Term) -> Vec<Block> {
    match t {
        Term::Invoke { normal, .. } => normal.iter().map(|e| e.to).collect(),
        t => t.edges().map(|e| e.to).collect(),
    }
}

pub fn shape(f: &Func) -> Shape {
    let n = f.blocks.len();
    let live = f.live_blocks();
    let rpo = f.rpo();
    let idom = f.idoms(&rpo);
    let dominates = |a: Block, mut b: Block| -> bool {
        loop {
            if a == b {
                return true;
            }
            match idom[b.idx()] {
                Some(d) => b = d,
                None => return false,
            }
        }
    };
    // Loops: the blocks that reach a back edge's source without passing its header.
    let mut bodies: BTreeMap<u32, Vec<bool>> = BTreeMap::new();
    for &b in &live {
        for e in f.blocks[b.idx()].term.edges() {
            let h = e.to;
            if !dominates(h, b) {
                continue;
            }
            let body = bodies.entry(h.0).or_insert_with(|| alloc::vec![false; n]);
            body[h.idx()] = true;
            let mut stack = alloc::vec![b];
            while let Some(x) = stack.pop() {
                if core::mem::replace(&mut body[x.idx()], true) {
                    continue;
                }
                stack.extend(f.blocks[x.idx()].preds.iter().map(|p| p.0));
            }
        }
    }
    let mut depth = alloc::vec![0u32; n];
    for body in bodies.values() {
        for (x, &inside) in body.iter().enumerate() {
            depth[x] += inside as u32;
        }
    }
    let mut cold = alloc::vec![false; n];
    for &b in &live {
        let bd = &f.blocks[b.idx()];
        cold[b.idx()] = bd.kind == BlockKind::Stub || matches!(bd.term, Term::Trap | Term::Invoke { normal: None, .. });
    }
    loop {
        let mut changed = false;
        for &b in &live {
            if cold[b.idx()] {
                continue;
            }
            let s = normal_succs(&f.blocks[b.idx()].term);
            if !s.is_empty() && s.iter().all(|x| cold[x.idx()]) {
                cold[b.idx()] = true;
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }
    let weight = (0..n).map(|b| [1.0, 8.0, 64.0, 512.0, 4096.0][depth[b].min(4) as usize] * if cold[b] { 1.0 / 16.0 } else { 1.0 }).collect();
    Shape { weight, cold }
}

/// What an instruction costs in the unit (§6): a handler call through the scratch area 4,
/// through its register entry 2, a call or an island 4, anything else 1.
fn inst_cost(op: &Op) -> f64 {
    match op {
        Op::HCall(h) if h.reg => 2.0,
        Op::HCall(_) | Op::Call(_) | Op::Island(_) => 4.0,
        Op::OsrLoad(..) => 0.0,
        _ => 1.0,
    }
}

/// The cost of `f`'s code: its instructions and branches, those in cold blocks at a
/// quarter (they are placed out of line). OSR entries aren't copied, so they don't count.
pub fn cost(f: &Func, sh: &Shape) -> f64 {
    let mut c = 0.0;
    for &b in &f.layout {
        let bd = &f.blocks[b.idx()];
        let mut k: f64 = bd.insts.iter().map(|&i| inst_cost(&f.insts[i.idx()].op)).sum();
        k += match &bd.term {
            Term::Br { .. } | Term::BrCmp { .. } | Term::BrOvf { .. } | Term::Trap => 1.0,
            Term::Switch { .. } => 2.0,
            Term::TailCall { .. } => 4.0,
            _ => 0.0,
        };
        c += if sh.cold[b.idx()] { k / 4.0 } else { k };
    }
    c
}

/// What a call costs beyond the callee's body: argument moves, the call and the return, the
/// prologue and the epilogue, and the AOT callee's counter check (jit-inlining.md §1).
fn protocol(c: &Call) -> f64 {
    2.0 * c.regs.len() as f64 + 8.0 + if c.parts.is_empty() { 0.0 } else { 1.0 }
}

/// The values of `g` derived from the pointers `roots` by constant or indexed offsets.
fn derived(g: &Func, roots: &[Value]) -> Vec<bool> {
    let mut d = alloc::vec![false; g.values.len()];
    for &r in roots {
        d[g.resolve(r).idx()] = true;
    }
    loop {
        let mut changed = false;
        for &b in &g.layout {
            for &i in &g.blocks[b.idx()].insts {
                let id = &g.insts[i.idx()];
                if matches!(id.op, Op::PtrAdd(_) | Op::PtrIndex(_)) && d[g.resolve(id.args[0]).idx()] {
                    let r = g.result(i);
                    if !d[r.idx()] {
                        d[r.idx()] = true;
                        changed = true;
                    }
                }
            }
        }
        if !changed {
            return d;
        }
    }
}

/// The accesses through the pointers `d` ([`derived`]) in `g`, by block weight, if nothing
/// but loads, stores (as their address) and VM calls uses them: then promotion could make
/// them values once the memory they point at is the caller's and the calls are inlined.
/// `None` if they escape any other way.
fn promotable_accesses(g: &Func, sh: Option<&Shape>, d: &[bool]) -> Option<f64> {
    let is = |v: Value| d[g.resolve(v).idx()];
    let mut n = 0.0;
    for &b in &g.layout {
        let bd = &g.blocks[b.idx()];
        for &i in &bd.insts {
            let id = &g.insts[i.idx()];
            match &id.op {
                Op::Load(..) | Op::Store(..) if is(id.args[0]) => {
                    if id.args[1..].iter().any(|&v| is(v)) {
                        return None;
                    }
                    n += sh.map_or(1.0, |s| s.weight[b.idx()]);
                }
                Op::PtrAdd(_) | Op::PtrIndex(_) if is(id.args[0]) => {
                    if id.args[1..].iter().any(|&v| is(v)) {
                        return None;
                    }
                }
                Op::Call(_) => {}
                _ if id.args.iter().any(|&v| is(v)) => return None,
                _ => {}
            }
        }
        let in_term = match &bd.term {
            Term::Br { cond, .. } => is(*cond),
            Term::BrCmp { a, b, .. } => is(*a) || is(*b),
            Term::Switch { idx, .. } => is(*idx),
            Term::Ret { parts, .. } => parts.iter().any(|&v| is(v)),
            Term::TailCall { args, .. } => args.iter().any(|&v| is(v)),
            _ => false,
        };
        if in_term || bd.term.edges().any(|e| e.args.iter().any(|&v| is(v))) {
            return None;
        }
    }
    Some(n)
}

/// Whether the pointer `v` of node `k`'s IR `g` points into a memory alloca of the root or
/// an inlined ancestor that only loads, stores and VM calls reach ([`promotable_accesses`]),
/// following entry parameters up to the call sites that pass them.
fn local_alloca(nodes: &[Node], root: &Func, memo: &mut BTreeMap<(usize, u32), bool>, mut k: usize, mut v: Value) -> bool {
    loop {
        let g: &Func = nodes[k].ir.as_deref().unwrap_or(root);
        v = g.resolve(v);
        let mut p = v;
        while let ValueDef::Inst(i, 0) = g.def(p) {
            match g.insts[i.idx()].op {
                Op::PtrAdd(_) | Op::PtrIndex(_) => p = g.resolve(g.insts[i.idx()].args[0]),
                Op::AllocaAddr(a, _) => {
                    if let Some(&m) = memo.get(&(k, a.0)) {
                        return m;
                    }
                    let al = &g.allocas[a.idx()];
                    let ok = al.kind == AllocaKind::Memory && !al.pinned && !named(g, a) && {
                        let addrs: Vec<Value> = (0..g.insts.len())
                            .filter(|&j| matches!(g.insts[j].op, Op::AllocaAddr(b, _) if b == a) && g.insts[j].nres == 1)
                            .map(|j| g.result(Inst(j as u32)))
                            .collect();
                        promotable_accesses(g, None, &derived(g, &addrs)).is_some()
                    };
                    memo.insert((k, a.0), ok);
                    return ok;
                }
                _ => return false,
            }
        }
        let ValueDef::Param(b, n) = g.def(p) else { return false };
        if k == 0 || g.blocks[b.idx()].kind != BlockKind::Entry {
            return false;
        }
        // The argument the call site passes in this parameter's register.
        let r = g.entry_regs[n as usize];
        let parent = nodes[k].parent;
        let pf: &Func = nodes[parent].ir.as_deref().unwrap_or(root);
        let site = &pf.insts[nodes[k].site.idx()];
        let Op::Call(call) = &site.op else { return false };
        let Some(ai) = call.arg_for(&r) else { return false };
        v = site.args[ai];
        k = parent;
    }
}

/// Whether a handler call or an island of `g` names the alloca `a`: promotion can't take it.
fn named(g: &Func, a: AllocaId) -> bool {
    g.insts.iter().any(|id| id.op.named_allocas().any(|b| b == a))
}

/// The promotion benefit of inlining `c` at the call `site` of node `parent` (design/jit.md,
/// "Inlining"): a pointer argument into a caller's memory alloca that only loads, stores and calls
/// reach ([`local_alloca`]) leaves the callee's accesses through it (by block weight) to
/// promotion once inlined, each a memory access saved. Callee parameters that escape any
/// other way (a handler, a store of the pointer, a return) get nothing.
fn promotion(
    nodes: &[Node],
    root: &Func,
    memo: &mut BTreeMap<(usize, u32), bool>,
    parent: usize,
    site: Inst,
    call: &Call,
    c: &Func,
    sh: &Shape,
) -> f64 {
    let Some(entry) = c.entry() else { return 0.0 };
    let pf: &Func = nodes[parent].ir.as_deref().unwrap_or(root);
    let mut total = 0.0;
    for (n, r) in c.entry_regs.iter().enumerate() {
        if r.xmm || r.size != 8 {
            continue;
        }
        let Some(ai) = call.arg_for(r) else { continue };
        if !local_alloca(nodes, root, memo, parent, pf.insts[site.idx()].args[ai]) {
            continue;
        }
        let param = c.blocks[entry].params[n];
        total += promotable_accesses(c, Some(sh), &derived(c, &[param])).unwrap_or(0.0);
    }
    total
}

/// A node of the call tree: a call site and its callee.
struct Node {
    func: VmFunc,
    ir: Option<Rc<Func>>,
    /// The call, in the parent's IR.
    site: Inst,
    parent: usize,
    depth: u32,
    /// The depth without `#[inline(always)]` edges.
    soft_depth: u32,
    /// The callee's [`Env::flags`].
    flags: u8,
    /// The site's frequency relative to the root's entry.
    weight: f64,
    cost: f64,
    benefit: f64,
    /// The site is in a cold block of its caller, or the callee is `#[cold]`.
    cold: bool,
    /// What unwinding out of a call in the callee that continues to its caller does once
    /// inlined: the site's action, or its ancestors' if it continues there too.
    unwind: Site,
    /// Stores to the root's outgoing area (or an ancestor's merged into it) may wait for
    /// their call at the site or an ancestor's ([`outgoing_pending`]): the callee and its
    /// descendants mustn't write theirs.
    pending: bool,
    frame: u32,
    children: Vec<usize>,
}

/// Why the callee `c` can't be inlined at the call `call`, whose unwinding does `unwind`.
fn blocker(c: &Func, call: &Call, unwind: Site) -> Option<&'static str> {
    let size_ok = |s: u32| matches!(s, 1 | 2 | 4 | 8);
    if !call.regs.iter().all(|r| size_ok(r.size)) || !call.parts.iter().all(|p| size_ok(p.size)) {
        return Some("argument or result sizes");
    }
    let Some(entry) = c.entry() else { return Some("no entry") };
    if c.blocks[entry].params.len() != c.entry_regs.len() {
        return Some("entry parameters");
    }
    for r in &c.entry_regs {
        if !size_ok(r.size) || !call.arg_for(r).is_some() {
            return Some("an argument register the call doesn't set");
        }
    }
    if c.allocas.iter().any(|a| a.kind == AllocaKind::Incoming) {
        return Some("stack arguments");
    }
    for &b in &c.layout {
        let bd = &c.blocks[b.idx()];
        match &bd.term {
            Term::TailCall { .. } => return Some("a tail call"),
            // Parts past the call's are dropped (a callee returning its sret pointer to a site
            // that doesn't use it).
            Term::Ret { parts, .. } if parts.len() < call.parts.len() => return Some("return parts"),
            _ => {}
        }
        if let Site::Pad { catch } = unwind {
            if catch && bd.kind == BlockKind::Stub {
                return Some("a landing pad at a catching site");
            }
            for &i in &bd.insts {
                if let Op::HCall(h) = &c.insts[i.idx()].op
                    && h.h == Opcode::Resume
                {
                    return Some("a resume at a site with a landing pad");
                }
            }
        }
    }
    None
}

/// Whether stores to `f`'s outgoing area may still wait for their call at the call `site`.
///
/// A callee's outgoing area is merged into its caller's (§7). That is safe only because the
/// backend stores a call's stack arguments right before it (lower/call.rs `pass_args`), so no
/// other call runs between them: an inlined callee can't clobber stack arguments still waiting
/// for their call. This checks that `f` keeps to that, so that a backend or pass that moved
/// the stores can't silently miscompile: an outgoing store is taken to wait until the next
/// call in its block, and one left at the end of a block to wait anywhere in `f`.
fn outgoing_pending(f: &Func, site: Inst) -> bool {
    let out = |i: Inst| match f.insts[i.idx()].op {
        Op::AStore(a, ..) => f.allocas[a.idx()].kind == AllocaKind::Outgoing,
        _ => false,
    };
    let mut at_site = false;
    for &b in &f.layout {
        let mut waiting = false;
        for &i in &f.blocks[b.idx()].insts {
            if i == site {
                at_site = waiting;
            }
            if f.insts[i.idx()].op.is_call() {
                waiting = false;
            } else if out(i) {
                waiting = true;
            }
        }
        if waiting {
            return true;
        }
    }
    at_site
}

/// The calls of VM functions in `f` (in the root's image's terms): the call, its callee, its
/// block.
fn calls(f: &Func, env: &mut dyn Env) -> Vec<(Inst, VmFunc, Block)> {
    let mut v = Vec::new();
    for &b in &f.layout {
        for &i in &f.blocks[b.idx()].insts {
            if let Op::Call(c) = &f.insts[i.idx()].op
                && let Some(g) = env.callee(c.target)
            {
                v.push((i, g, b));
            }
        }
    }
    v
}

/// How the dump names `g`: its index, and its image's for another image's.
fn name(g: VmFunc, root: VmFunc) -> String {
    if g.img == root.img { alloc::format!("{}", g.func) } else { alloc::format!("{}@{:x}", g.func, g.img) }
}

/// A cluster: nodes inlined together.
#[derive(Clone)]
struct Cluster {
    benefit: f64,
    cost: f64,
    frame: u32,
    members: Vec<usize>,
    /// The child nodes hanging off it, each the head of a cluster of its own.
    frontier: Vec<usize>,
}

impl Cluster {
    fn ratio(&self) -> f64 {
        self.benefit / self.cost.max(1.0)
    }
}

/// Inlines into `f` (its IR after [`super::opt::run`]) what the heuristic decides, from
/// its calls `only` or all of them, and with `check` verifies the IR after each splice.
/// Notes the decisions in `dump`. Returns how many calls it inlined.
pub fn inline(
    f: &mut Func,
    env: &mut dyn Env,
    mem: Option<&dyn super::opt::ConstMem>,
    p: &Params,
    only: Option<&[Inst]>,
    check: bool,
    mut dump: Option<&mut String>,
) -> Result<usize, String> {
    let root_shape = shape(f);
    let root_cost = cost(f, &root_shape);
    let mut nodes = alloc::vec![Node {
        func: env.root(),
        ir: None,
        site: Inst(u32::MAX),
        parent: usize::MAX,
        depth: 0,
        soft_depth: 0,
        flags: 0,
        weight: 1.0,
        cost: root_cost,
        benefit: 0.0,
        cold: false,
        unwind: Site::Continue,
        pending: false,
        frame: 0,
        children: Vec::new(),
    }];
    // Exploration: the pending sites by weight, heaviest first.
    let root = env.root();
    let mut pending: Vec<(f64, usize, Inst, VmFunc, bool)> = Vec::new();
    let push_sites = |pending: &mut Vec<(f64, usize, Inst, VmFunc, bool)>, env: &mut dyn Env, nodes: &[Node], k: usize, g: &Func, sh: &Shape| {
        for (i, callee, b) in calls(g, env) {
            pending.push((nodes[k].weight * sh.weight[b.idx()], k, i, callee, sh.cold[b.idx()]));
        }
    };
    push_sites(&mut pending, env, &nodes, 0, f, &root_shape);
    if let Some(only) = only {
        pending.retain(|s| only.contains(&s.2));
    }
    let mut expanded = 0.0;
    let mut promo_memo = BTreeMap::new();
    let mut trials: Vec<((VmFunc, Vec<Option<(u64, u8)>>), Rc<Func>)> = Vec::new();
    while !pending.is_empty() && nodes.len() < p.nodes {
        let at = (0..pending.len()).max_by(|&a, &b| pending[a].0.total_cmp(&pending[b].0)).unwrap();
        let (mut weight, parent, site, g, mut cold) = pending.swap_remove(at);
        let flags = env.flags(g);
        let always = flags & FUNC_INLINE_ALWAYS != 0;
        let depth = nodes[parent].depth + 1;
        let soft_depth = nodes[parent].soft_depth + !always as u32;
        if flags & FUNC_COLD != 0 && !cold {
            weight /= 16.0;
            cold = true;
        }
        let pf: &Func = match &nodes[parent].ir {
            Some(ir) => ir,
            None => f,
        };
        let Op::Call(call) = &pf.insts[site.idx()].op else { unreachable!() };
        let call = call.clone();
        let mut why = None;
        let mut anc = parent;
        loop {
            if nodes[anc].func == g {
                why = Some("recursion");
                break;
            }
            if anc == 0 {
                break;
            }
            anc = nodes[anc].parent;
        }
        if flags & FUNC_INLINE_NEVER != 0 {
            why = why.or(Some("inline(never)"));
        }
        if soft_depth > p.max_depth || depth > p.max_depth + p.always_depth {
            why = why.or(Some("too deep"));
        }
        let unwind = match call.site {
            Site::Continue => nodes[parent].unwind,
            s => s,
        };
        let waiting = nodes[parent].pending || outgoing_pending(pf, site);
        let mut ir = if why.is_none() { env.ir(g) } else { None };
        if why.is_none() && ir.is_none() {
            why = Some("no IR");
        }
        // Another image's callee, in the root's image's terms.
        if let (None, Some(c)) = (why, &ir)
            && g.img != root.img
        {
            match rebase(c, g.img, env) {
                Ok(r) => ir = Some(Rc::new(r)),
                Err(w) => why = Some(w),
            }
        }
        // Its calls through constant pointers, made direct in the unit's copy.
        if let (None, Some(c)) = (why, &mut ir) {
            let sites = devirt_sites(c, env);
            if !sites.is_empty() {
                apply_devirt(Rc::make_mut(c), &sites);
            }
        }
        if let (None, Some(c)) = (why, &ir) {
            why = blocker(c, &call, unwind);
            if why.is_none() && waiting && c.allocas.iter().any(|a| a.kind == AllocaKind::Outgoing) {
                why = Some("an outgoing area while the caller's stack arguments wait for their call");
            }
        }
        let (c, sh) = match (why, ir) {
            (None, Some(c)) => {
                let sh = shape(&c);
                (c, sh)
            }
            (w, _) => {
                if let Some(d) = dump.as_deref_mut() {
                    let a = if always { " [always]" } else { "" };
                    let _ = writeln!(d, ";   {}{a} at {site} (depth {depth}): not inlinable: {}", name(g, root), w.unwrap_or("?"));
                }
                continue;
            }
        };
        let mut k_cost = cost(&c, &sh);
        // A trial: the callee specialized to the call's constant arguments, memoized.
        let mut folded = 0.0;
        let (c, sh) = {
            let consts: Vec<Option<(u64, u8)>> = c
                .entry_regs
                .iter()
                .map(|r| {
                    let ai = call.arg_for(r)?;
                    let v = pf.insts[site.idx()].args[ai];
                    // The call zero-extends past its register's size and the value's width.
                    let w = pf.w(v).min(call.arg_width(ai));
                    match pf.def(v) {
                        ValueDef::Const(bits) => Some((mask(bits, w), w)),
                        _ => None,
                    }
                })
                .collect();
            if k_cost <= p.trial_cost && consts.iter().any(|x| x.is_some()) {
                let key = (g, consts.clone());
                let spec = match trials.iter().find(|t| t.0 == key) {
                    Some(t) => Some(t.1.clone()),
                    None if trials.len() < p.trials => {
                        let s = Rc::new(specialize(&c, &consts, mem));
                        trials.push((key, s.clone()));
                        Some(s)
                    }
                    None => None,
                };
                match spec {
                    Some(s) => {
                        let ssh = shape(&s);
                        let sc = cost(&s, &ssh);
                        folded = (k_cost - sc).max(0.0);
                        k_cost = sc;
                        (s, ssh)
                    }
                    None => (c, sh),
                }
            } else {
                (c, sh)
            }
        };
        let promoted = promotion(&nodes, f, &mut promo_memo, parent, site, &call, &c, &sh);
        if expanded + k_cost > p.expand {
            if let Some(d) = dump.as_deref_mut() {
                let _ = writeln!(d, ";   {} at {site} (depth {depth}): over the exploration budget", name(g, root));
            }
            continue;
        }
        expanded += k_cost;
        let frame = c.allocas.iter().filter(|a| matches!(a.kind, AllocaKind::Memory | AllocaKind::Outgoing)).map(|a| a.size).sum();
        let k = nodes.len();
        nodes.push(Node {
            func: g,
            ir: Some(c.clone()),
            site,
            parent,
            depth,
            soft_depth,
            flags,
            weight,
            cost: k_cost,
            benefit: weight * (protocol(&call) + folded + promoted),
            cold,
            unwind,
            pending: waiting,
            frame,
            children: Vec::new(),
        });
        nodes[parent].children.push(k);
        push_sites(&mut pending, env, &nodes, k, &c, &sh);
    }

    // The profile raises weights (§2): a callee's share of the root's calls, split over
    // the unit's sites of it by their static weights (there are no samples of call sites).
    let root_counts = env.counts(env.root());
    if let Some((rc, _)) = root_counts.filter(|c| c.0 >= p.min_calls) {
        let mut sites: BTreeMap<(usize, u32), f64> = BTreeMap::new();
        for n in &nodes[1..] {
            *sites.entry(n.func.key()).or_default() += n.weight;
        }
        for k in 1..nodes.len() {
            if nodes[k].flags & FUNC_COLD != 0 {
                continue;
            }
            let Some((gc, _)) = env.counts(nodes[k].func) else { continue };
            let w = nodes[k].weight;
            let prof = gc as f64 / rc as f64 * w / sites[&nodes[k].func.key()];
            let raised = prof.min(w * p.raise);
            if raised > w {
                nodes[k].benefit *= raised / w;
                nodes[k].weight = raised;
            }
        }
    }
    let cap = match root_counts {
        Some((c, i)) if i as f64 >= p.loopy * c.max(1) as f64 => p.cap_loopy,
        _ => p.cap,
    };

    // Clusters, bottom-up: children have larger indices than their parents.
    let mut clusters: Vec<Cluster> = nodes
        .iter()
        .enumerate()
        .map(|(k, n)| Cluster { benefit: n.benefit, cost: n.cost, frame: n.frame, members: alloc::vec![k], frontier: n.children.clone() })
        .collect();
    for k in (1..nodes.len()).rev() {
        loop {
            let cl = &clusters[k];
            let best = cl.frontier.iter().copied().max_by(|&a, &b| clusters[a].ratio().total_cmp(&clusters[b].ratio()));
            let Some(ch) = best else { break };
            let c = &clusters[ch];
            let merged = (cl.benefit + c.benefit) / (cl.cost + c.cost).max(1.0);
            if merged <= cl.ratio() {
                break;
            }
            let c = clusters[ch].clone();
            let cl = &mut clusters[k];
            cl.benefit += c.benefit;
            cl.cost += c.cost;
            cl.frame += c.frame;
            cl.members.extend(c.members);
            cl.frontier.retain(|&x| x != ch);
            cl.frontier.extend(c.frontier);
        }
    }

    // Selection.
    let mut accepted = alloc::vec![false; nodes.len()];
    let mut queue: Vec<usize> = nodes[0].children.clone();
    let mut unit = root_cost;
    let mut frame = 0u32;
    // A cluster headed by an `#[inline(always)]` callee, not at a cold site: first, and
    // without the bar.
    let forced = |k: usize| nodes[k].flags & FUNC_INLINE_ALWAYS != 0 && !nodes[k].cold;
    while !queue.is_empty() {
        let key = |k: usize| (forced(k), clusters[k].ratio());
        let at = (0..queue.len())
            .max_by(|&a, &b| {
                let (x, y) = (key(queue[a]), key(queue[b]));
                x.0.cmp(&y.0).then(x.1.total_cmp(&y.1))
            })
            .unwrap();
        let k = queue.swap_remove(at);
        let cl = &clusters[k];
        let small = cl.cost <= p.always;
        let bar = p.t1 * libm_exp2((unit + cl.cost) / p.scale);
        let fits = unit + cl.cost <= cap;
        let ok = frame + cl.frame <= p.frame && (small || (forced(k) && fits) || (!nodes[k].cold && cl.ratio() >= bar && fits));
        if let Some(d) = dump.as_deref_mut() {
            let names: Vec<String> = cl.members.iter().map(|&m| alloc::format!("{}@{}", name(nodes[m].func, root), nodes[m].site)).collect();
            let _ = writeln!(
                d,
                ";   cluster [{}]: benefit {:.1}, cost {:.1}, ratio {:.2}{}{}: {}",
                names.join(" "),
                cl.benefit,
                cl.cost,
                cl.ratio(),
                if nodes[k].cold { ", cold" } else { "" },
                if forced(k) { ", always" } else { "" },
                if ok { "inlined" } else { "not inlined" }
            );
        }
        if ok {
            unit += cl.cost;
            frame += cl.frame;
            for &m in &cl.members {
                accepted[m] = true;
            }
            queue.extend(cl.frontier.iter().copied());
        }
    }

    // The splices, each callee with its own accepted callees spliced in first.
    fn build(nodes: &[Node], accepted: &[bool], k: usize, check: bool) -> Result<Func, String> {
        let mut g = (**nodes[k].ir.as_ref().unwrap()).clone();
        for &ch in &nodes[k].children {
            if accepted[ch] && live(&g, nodes[ch].site) {
                let sub = build(nodes, accepted, ch, check)?;
                let before = check.then(|| alloc::format!("; callee\n{sub}\n; caller\n{g}"));
                splice(&mut g, nodes[ch].site, &sub);
                if check {
                    g.verify().map_err(|e| {
                        alloc::format!(
                            "IR after inlining {} into {}: {e}\n{}\n; after\n{g}",
                            name(nodes[ch].func, nodes[0].func),
                            name(nodes[k].func, nodes[0].func),
                            before.unwrap_or_default()
                        )
                    })?;
                }
            }
        }
        Ok(g)
    }
    let mut n = 0;
    for &ch in &nodes[0].children.clone() {
        if accepted[ch] && live(f, nodes[ch].site) {
            let sub = build(&nodes, &accepted, ch, check)?;
            let before = check.then(|| alloc::format!("; callee\n{sub}\n; caller\n{f}"));
            splice(f, nodes[ch].site, &sub);
            if check {
                f.verify().map_err(|e| {
                    alloc::format!(
                        "IR after inlining {} into the root: {e}\n{}\n; after\n{f}",
                        name(nodes[ch].func, root),
                        before.unwrap_or_default()
                    )
                })?;
            }
        }
    }
    for a in &accepted {
        n += *a as usize;
    }
    Ok(n)
}

/// Whether the call `site` is still in `f`: a splice prunes the code that became
/// unreachable (after a callee that never returns, or a landing pad no copied call unwinds
/// to), and a call there needs no inlining.
fn live(f: &Func, site: Inst) -> bool {
    f.blocks[f.insts[site.idx()].block.idx()].insts.contains(&site)
}

/// Replaces the call `call` in `f` by the body of `c`, the callee's IR (§7).
pub fn splice(f: &mut Func, call: Inst, c: &Func) {
    let b = f.insts[call.idx()].block;
    let pos = f.blocks[b.idx()].insts.iter().position(|&i| i == call).expect("the call in its block");
    let id = f.insts[call.idx()].clone();
    let Op::Call(cl) = &id.op else { panic!("not a call") };
    let site = cl.site;
    let results: Vec<Value> = id.results().collect();
    let invoke = pos + 1 == f.blocks[b.idx()].insts.len() && matches!(f.blocks[b.idx()].term, Term::Invoke { .. });
    // The landing pad a callee call that unwinds to its caller goes to.
    let root_pad = match (&f.blocks[b.idx()].term, invoke) {
        (Term::Invoke { pad, .. }, true) => Some(pad.clone()),
        _ => None,
    };

    // Allocas. The outgoing areas are one: the bottom of the frame.
    let mut out = f.allocas.iter().position(|a| a.kind == AllocaKind::Outgoing).map(|k| AllocaId(k as u32));
    let amap: Vec<AllocaId> = c
        .allocas
        .iter()
        .map(|a| {
            if a.kind == AllocaKind::Outgoing {
                if let Some(o) = out {
                    let size = f.allocas[o.idx()].size.max(a.size);
                    f.allocas[o.idx()].size = size;
                    return o;
                }
            }
            f.allocas.push(Alloca { pinned: false, inlined: true, ..*a });
            let id = AllocaId(f.allocas.len() as u32 - 1);
            if a.kind == AllocaKind::Outgoing {
                out = Some(id);
            }
            id
        })
        .collect();
    f.scratch = f.scratch.max(c.scratch);
    let slot = |r: SlotRef| match r {
        SlotRef::Alloca(a, o) => SlotRef::Alloca(amap[a.idx()], o),
        s => s,
    };

    // The continuation: the instructions after the call, with the results as its
    // parameters.
    let k = f.block(BlockKind::Body);
    for (n, &r) in results.iter().enumerate() {
        f.values[r.idx()].def = ValueDef::Param(k, n as u16);
        f.blocks[k.idx()].params.push(r);
    }
    let rest: Vec<Inst> = f.blocks[b.idx()].insts.split_off(pos + 1);
    f.blocks[b.idx()].insts.pop();
    for &i in &rest {
        f.insts[i.idx()].block = k;
    }
    f.blocks[k.idx()].insts = rest;
    let old = core::mem::replace(&mut f.blocks[b.idx()].term, Term::None);
    let old_stub = match &old {
        Term::Invoke { pad, .. } if invoke => Some(pad.to),
        _ => None,
    };
    f.blocks[k.idx()].term = match old {
        Term::Invoke { normal: Some(e), .. } if invoke => Term::Jmp(e),
        Term::Invoke { normal: None, .. } if invoke => Term::Trap,
        t => t,
    };

    // Blocks and values.
    let entry = c.entry().expect("an entry");
    let mut bmap: Vec<Option<Block>> = alloc::vec![None; c.blocks.len()];
    for &cb in &c.layout {
        let kind = if c.blocks[cb.idx()].kind == BlockKind::Stub { BlockKind::Stub } else { BlockKind::Body };
        bmap[cb.idx()] = Some(f.block(kind));
    }
    let mut vmap: Vec<Option<Value>> = alloc::vec![None; c.values.len()];
    // The entry's parameters: the arguments, widened where the callee reads more bytes.
    for (n, &p) in c.blocks[entry].params.iter().enumerate() {
        let r = c.entry_regs[n];
        let a = cl.arg_for(&r).expect("checked");
        let size = cl.arg_width(a);
        let a = id.args[a];
        let from = f.w(a).min(size);
        let v = if from < c.w(p) && !matches!(f.def(a), ValueDef::Undef) {
            let e = f.inst(b, Op::Ext { from, to: c.w(p), sx: false }, alloc::vec![a], &[c.w(p)]);
            f.result(e)
        } else {
            a
        };
        vmap[p.idx()] = Some(v);
    }
    // Parameters and instructions, splitting blocks after calls that now unwind to the
    // site's landing pad. `tail[cb]` is the block the callee block's terminator ends.
    let mut tail: Vec<Option<Block>> = alloc::vec![None; c.blocks.len()];
    let mut order: Vec<Block> = Vec::new();
    let mut copied: Vec<(Inst, Inst)> = Vec::new();
    let mut invokes = 0;
    for &cb in &c.layout {
        let cbd = &c.blocks[cb.idx()];
        let mut cur = bmap[cb.idx()].unwrap();
        order.push(cur);
        if cb.idx() != entry {
            for &p in &cbd.params {
                let v = f.param(cur, c.w(p));
                vmap[p.idx()] = Some(v);
            }
        }
        let n = cbd.insts.len();
        for (j, &ci) in cbd.insts.iter().enumerate() {
            let cid = &c.insts[ci.idx()];
            let mut op = match &cid.op {
                Op::AllocaAddr(a, o) => Op::AllocaAddr(amap[a.idx()], *o),
                Op::ALoad(a, o, w) => Op::ALoad(amap[a.idx()], *o, *w),
                Op::AStore(a, o, w) => Op::AStore(amap[a.idx()], *o, *w),
                Op::HCall(h) => {
                    let mut h = h.clone();
                    for r in h.regs.iter_mut() {
                        r.1 = [r.1[0].map(slot), r.1[1].map(slot)];
                    }
                    Op::HCall(h)
                }
                Op::Island(isl) => {
                    let mut isl = isl.clone();
                    isl.ops = isl.ops.iter().map(|&r| slot(r)).collect();
                    Op::Island(isl)
                }
                op => op.clone(),
            };
            // Action substitution: a call that unwinds to the callee's caller unwinds as the
            // site does.
            let unwinds_out = op.site() == Site::Continue;
            if unwinds_out {
                let s = site;
                assert!(!matches!(s, Site::Pad { .. }) || root_pad.is_some(), "a site with a pad that doesn't invoke");
                match &mut op {
                    Op::HCall(h) => h.site = s,
                    Op::Call(x) => x.site = s,
                    Op::Island(x) => x.site = s,
                    _ => {}
                }
            }
            let ws: Vec<u8> = cid.results().map(|r| c.w(r)).collect();
            let ni = f.inst(cur, op, Vec::new(), &ws);
            for (r, nr) in cid.results().zip(f.insts[ni.idx()].results()) {
                vmap[r.idx()] = Some(nr);
            }
            copied.push((ci, ni));
            if unwinds_out && let (Site::Pad { .. }, Some(pad)) = (site, &root_pad) {
                invokes += 1;
                let last = j + 1 == n;
                if last && matches!(cbd.term, Term::Trap) {
                    f.blocks[cur.idx()].term = Term::Invoke { normal: None, pad: pad.clone() };
                    tail[cb.idx()] = None;
                    cur = Block(u32::MAX);
                    break;
                }
                let next = f.block(BlockKind::Body);
                f.blocks[cur.idx()].term = Term::Invoke { normal: Some(Edge::to(next)), pad: pad.clone() };
                order.push(next);
                cur = next;
            }
        }
        if cur.0 != u32::MAX {
            tail[cb.idx()] = Some(cur);
        }
    }
    let map = |vmap: &mut Vec<Option<Value>>, f: &mut Func, v: Value| -> Value {
        if let Some(x) = vmap[v.idx()] {
            return x;
        }
        let x = match c.def(v) {
            ValueDef::Const(bits) => f.konst(bits, c.w(v)),
            ValueDef::Undef => f.value(ValueDef::Undef, c.w(v)),
            d => panic!("{v} ({d:?}) used before its definition was copied"),
        };
        vmap[v.idx()] = Some(x);
        x
    };
    for (ci, ni) in copied {
        let args: Vec<Value> = c.insts[ci.idx()].args.iter().map(|&a| map(&mut vmap, f, a)).collect();
        f.insts[ni.idx()].args = args;
    }
    // Terminators.
    for &cb in &c.layout {
        let Some(cur) = tail[cb.idx()] else { continue };
        let edge = |vmap: &mut Vec<Option<Value>>, f: &mut Func, e: &Edge| -> Edge {
            Edge { to: bmap[e.to.idx()].expect("an edge to a live block"), args: e.args.iter().map(|&a| map(vmap, f, a)).collect() }
        };
        let t = match &c.blocks[cb.idx()].term {
            Term::None => panic!("an unterminated callee block"),
            Term::Jmp(e) => Term::Jmp(edge(&mut vmap, f, e)),
            Term::Br { cond, t, f: e } => {
                let cond = map(&mut vmap, f, *cond);
                Term::Br { cond, t: edge(&mut vmap, f, t), f: edge(&mut vmap, f, e) }
            }
            Term::BrOvf { t, f: e } => Term::BrOvf { t: edge(&mut vmap, f, t), f: edge(&mut vmap, f, e) },
            Term::BrCmp { cc, w, a, b: bb, t, f: e } => {
                let (a, bb) = (map(&mut vmap, f, *a), map(&mut vmap, f, *bb));
                Term::BrCmp { cc: *cc, w: *w, a, b: bb, t: edge(&mut vmap, f, t), f: edge(&mut vmap, f, e) }
            }
            Term::Switch { idx, targets } => {
                let idx = map(&mut vmap, f, *idx);
                Term::Switch { idx, targets: targets.iter().map(|e| edge(&mut vmap, f, e)).collect() }
            }
            Term::Ret { parts, .. } => {
                let mut args = Vec::with_capacity(results.len());
                for (n, &v) in parts.iter().take(results.len()).enumerate() {
                    let v = map(&mut vmap, f, v);
                    let w = f.w(results[n]);
                    args.push(if f.w(v) < w && !matches!(f.def(v), ValueDef::Const(_) | ValueDef::Undef) {
                        let e = f.inst(cur, Op::Ext { from: f.w(v), to: w, sx: false }, alloc::vec![v], &[w]);
                        f.result(e)
                    } else {
                        v
                    });
                }
                Term::Jmp(Edge { to: k, args })
            }
            Term::TailCall { .. } => panic!("a tail call in an inlined callee"),
            Term::Trap => Term::Trap,
            Term::Invoke { normal, pad } => {
                let normal = normal.as_ref().map(|e| edge(&mut vmap, f, e));
                Term::Invoke { normal, pad: edge(&mut vmap, f, pad) }
            }
        };
        f.blocks[cur.idx()].term = t;
    }
    f.blocks[b.idx()].term = Term::Jmp(Edge::to(bmap[entry].unwrap()));
    // The call's own landing pad stub, if no copied call unwinds to it.
    if let Some(s) = old_stub
        && invokes == 0
    {
        let sd = &mut f.blocks[s.idx()];
        sd.kind = BlockKind::Body;
        sd.insts.clear();
        sd.params.clear();
        sd.term = Term::Trap;
        f.layout.retain(|&x| x != s);
    }
    let at = f.layout.iter().position(|&x| x == b).expect("the call's block in the layout");
    order.push(k);
    f.layout.splice(at + 1..at + 1, order);
    // The code after a landing pad stub no copied call unwinds to, say.
    f.prune(false);
    f.rebuild_preds();
}

/// Calls and tail calls of functions and symbols get the targets `env` gives them
/// ([`Env::retarget`]).
pub fn retarget(f: &mut Func, env: &mut dyn Env) {
    let root = env.root();
    let mut new = |t: CallTarget| match t {
        CallTarget::Func(g) if g == root.func => None,
        CallTarget::Func(_) | CallTarget::Sym(_) => env.retarget(root.img, t),
        _ => None,
    };
    for b in f.live_blocks() {
        for k in 0..f.blocks[b.idx()].insts.len() {
            let i = f.blocks[b.idx()].insts[k];
            if let Op::Call(c) = &mut f.insts[i.idx()].op
                && let Some(t) = new(c.target)
            {
                c.target = t;
            }
        }
        if let Term::TailCall { call, .. } = &mut f.blocks[b.idx()].term
            && let Some(t) = new(call.target)
        {
            call.target = t;
        }
    }
}

/// `2^x` for the budget, without `std` (`x` between 0 and about 10).
fn libm_exp2(x: f64) -> f64 {
    let n = x as i32;
    let f = x - n as f64;
    // 2^f on [0, 1), a truncated series, to within 2e-3: enough for a threshold.
    let e = 1.0 + f * (0.693147 + f * (0.240227 + f * (0.0555041 + f * 0.0096181)));
    let mut r = e;
    for _ in 0..n.clamp(0, 60) {
        r *= 2.0;
    }
    r
}
