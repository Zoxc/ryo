//! Same-image inlining in the SSA tier (design/jit.md, "Inlining"): direct calls of
//! functions of the root's image are replaced by copies of their IR, so that one JIT unit
//! runs the root and the callees it decides on in one frame.
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
//! Weights are static: 1 per call site, 8 per loop level, 1/16 in cold blocks.

use alloc::collections::BTreeMap;
use alloc::rc::Rc;
use alloc::string::String;
use alloc::vec::Vec;
use core::fmt::Write;

use super::ir::*;
use crate::full::{Func as FuncIdx, Opcode, Sym};

/// What the inliner needs from the JIT.
pub trait Env {
    /// The root's index in its image.
    fn root(&self) -> FuncIdx;
    /// Function `g` of the root's image as [`super::ir_of`] gives it, or `None` if it can't
    /// be built (the JIT caches them).
    fn ir(&mut self, g: FuncIdx) -> Option<Rc<Func>>;
    /// The symbol to call function `g` through instead of directly, if any (the JIT's call
    /// slots, for functions not compiled yet).
    fn retarget(&mut self, g: FuncIdx) -> Option<Sym>;
    /// How many times function `g`'s AOT code was called and how many loop iterations it
    /// ran (its JIT record's counters), if known.
    fn counts(&self, g: FuncIdx) -> Option<(u64, u64)>;
}

/// The limits and constants of the heuristic.
#[derive(Clone, Copy, Debug)]
pub struct Params {
    /// How deep the exploration goes.
    pub max_depth: u32,
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
}

pub const PARAMS: Params = Params {
    max_depth: 6,
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
};

/// `c` with its entry parameters given constants (`None`: unknown) replaced by them, after
/// [`super::opt::run`]: the trial of §5. The parameters stay, unused.
pub fn specialize(c: &Func, consts: &[Option<(u64, u8)>]) -> Func {
    let mut g = c.clone();
    let Some(entry) = g.blocks.iter().position(|b| b.kind == BlockKind::Entry) else { return g };
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
    super::opt::run(&mut g);
    g
}

/// A block's static frequency relative to the function's entry: 8 per loop level (counted
/// up to 4 levels), 1/16 in cold blocks: landing pad stubs, blocks that trap, and blocks all
/// of whose successors are cold.
pub struct Shape {
    pub weight: Vec<f64>,
    pub cold: Vec<bool>,
}

/// The blocks of `f` that can run: its layout and its OSR entries.
fn live_blocks(f: &Func) -> Vec<Block> {
    let mut v = f.layout.clone();
    v.extend(f.osr.iter().flatten().copied());
    v
}

/// The successors of a block that its normal execution reaches (not a landing pad).
fn normal_succs(t: &Term) -> Vec<Block> {
    match t {
        Term::Invoke { normal, .. } => normal.iter().map(|e| e.to).collect(),
        t => t.edges().iter().map(|e| e.to).collect(),
    }
}

pub fn shape(f: &Func) -> Shape {
    let n = f.blocks.len();
    let live = live_blocks(f);
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

/// A node of the call tree: a call site and its callee.
struct Node {
    func: FuncIdx,
    ir: Option<Rc<Func>>,
    /// The call, in the parent's IR.
    site: Inst,
    parent: usize,
    depth: u32,
    /// The site's frequency relative to the root's entry.
    weight: f64,
    cost: f64,
    benefit: f64,
    /// The site is in a cold block of its caller.
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
    let Some(entry) = c.blocks.iter().position(|b| b.kind == BlockKind::Entry) else { return Some("no entry") };
    if c.blocks[entry].params.len() != c.entry_regs.len() {
        return Some("entry parameters");
    }
    for r in &c.entry_regs {
        if !size_ok(r.size) || !call.regs.iter().any(|x| x.xmm == r.xmm && x.index == r.index) {
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
            Term::Ret { parts, .. } if parts.len() != call.parts.len() => return Some("return parts"),
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

/// The direct calls of functions of the image in `f`: the call, its callee, its block.
fn calls(f: &Func) -> Vec<(Inst, FuncIdx, Block)> {
    let mut v = Vec::new();
    for &b in &f.layout {
        for &i in &f.blocks[b.idx()].insts {
            if let Op::Call(c) = &f.insts[i.idx()].op
                && let CallTarget::Func(g) = c.target
            {
                v.push((i, g, b));
            }
        }
    }
    v
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

/// Inlines into `f` (its IR after [`super::opt::run`]) what the heuristic decides, and
/// with `check` verifies the IR after each splice. Notes the decisions in `dump`. Returns
/// how many calls it inlined.
pub fn inline(f: &mut Func, env: &mut dyn Env, p: &Params, check: bool, mut dump: Option<&mut String>) -> Result<usize, String> {
    let root_shape = shape(f);
    let root_cost = cost(f, &root_shape);
    let mut nodes = alloc::vec![Node {
        func: env.root(),
        ir: None,
        site: Inst(u32::MAX),
        parent: usize::MAX,
        depth: 0,
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
    let mut pending: Vec<(f64, usize, Inst, FuncIdx, bool)> = Vec::new();
    let push_sites = |pending: &mut Vec<(f64, usize, Inst, FuncIdx, bool)>, nodes: &[Node], k: usize, g: &Func, sh: &Shape| {
        for (i, callee, b) in calls(g) {
            pending.push((nodes[k].weight * sh.weight[b.idx()], k, i, callee, sh.cold[b.idx()]));
        }
    };
    push_sites(&mut pending, &nodes, 0, f, &root_shape);
    let mut expanded = 0.0;
    let mut trials: Vec<((FuncIdx, Vec<Option<(u64, u8)>>), Rc<Func>)> = Vec::new();
    while !pending.is_empty() && nodes.len() < p.nodes {
        let at = (0..pending.len()).max_by(|&a, &b| pending[a].0.total_cmp(&pending[b].0)).unwrap();
        let (weight, parent, site, g, cold) = pending.swap_remove(at);
        let depth = nodes[parent].depth + 1;
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
        if depth > p.max_depth {
            why = why.or(Some("too deep"));
        }
        let unwind = match call.site {
            Site::Continue => nodes[parent].unwind,
            s => s,
        };
        let waiting = nodes[parent].pending || outgoing_pending(pf, site);
        let ir = if why.is_none() { env.ir(g) } else { None };
        if why.is_none() && ir.is_none() {
            why = Some("no IR");
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
                    let _ = writeln!(d, ";   {g} at {site} (depth {depth}): not inlinable: {}", w.unwrap_or("?"));
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
                    let ai = call.regs.iter().position(|x| x.xmm == r.xmm && x.index == r.index)?;
                    let v = pf.insts[site.idx()].args[ai];
                    // The call zero-extends past its register's size and the value's width.
                    let w = pf.w(v).min((call.regs[ai].size as u8).min(8));
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
                        let s = Rc::new(specialize(&c, &consts));
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
        if expanded + k_cost > p.expand {
            if let Some(d) = dump.as_deref_mut() {
                let _ = writeln!(d, ";   {g} at {site} (depth {depth}): over the exploration budget");
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
            weight,
            cost: k_cost,
            benefit: weight * (protocol(&call) + folded),
            cold,
            unwind,
            pending: waiting,
            frame,
            children: Vec::new(),
        });
        nodes[parent].children.push(k);
        push_sites(&mut pending, &nodes, k, &c, &sh);
    }

    // The profile raises weights (§2): a callee's share of the root's calls, split over
    // the unit's sites of it by their static weights (there are no samples of call sites).
    let root_counts = env.counts(env.root());
    if let Some((rc, _)) = root_counts.filter(|c| c.0 >= p.min_calls) {
        let mut sites: BTreeMap<u32, f64> = BTreeMap::new();
        for n in &nodes[1..] {
            *sites.entry(n.func.0).or_default() += n.weight;
        }
        for k in 1..nodes.len() {
            let Some((gc, _)) = env.counts(nodes[k].func) else { continue };
            let w = nodes[k].weight;
            let prof = gc as f64 / rc as f64 * w / sites[&nodes[k].func.0];
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
    while !queue.is_empty() {
        let at = (0..queue.len()).max_by(|&a, &b| clusters[queue[a]].ratio().total_cmp(&clusters[queue[b]].ratio())).unwrap();
        let k = queue.swap_remove(at);
        let cl = &clusters[k];
        let always = cl.cost <= p.always;
        let bar = p.t1 * libm_exp2((unit + cl.cost) / p.scale);
        let ok = frame + cl.frame <= p.frame && (always || (!nodes[k].cold && cl.ratio() >= bar && unit + cl.cost <= cap));
        if let Some(d) = dump.as_deref_mut() {
            let names: Vec<String> = cl.members.iter().map(|&m| alloc::format!("{}@{}", nodes[m].func, nodes[m].site)).collect();
            let _ = writeln!(
                d,
                ";   cluster [{}]: benefit {:.1}, cost {:.1}, ratio {:.2}{}: {}",
                names.join(" "),
                cl.benefit,
                cl.cost,
                cl.ratio(),
                if nodes[k].cold { ", cold" } else { "" },
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
            if accepted[ch] {
                let sub = build(nodes, accepted, ch, check)?;
                let before = check.then(|| alloc::format!("; callee\n{sub}\n; caller\n{g}"));
                splice(&mut g, nodes[ch].site, &sub);
                if check {
                    g.verify().map_err(|e| {
                        alloc::format!(
                            "IR after inlining {} into {}: {e}\n{}\n; after\n{g}",
                            nodes[ch].func,
                            nodes[k].func,
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
        if accepted[ch] {
            let sub = build(&nodes, &accepted, ch, check)?;
            let before = check.then(|| alloc::format!("; callee\n{sub}\n; caller\n{f}"));
            splice(f, nodes[ch].site, &sub);
            if check {
                f.verify().map_err(|e| {
                    alloc::format!("IR after inlining {} into the root: {e}\n{}\n; after\n{f}", nodes[ch].func, before.unwrap_or_default())
                })?;
            }
        }
    }
    for a in &accepted {
        n += *a as usize;
    }
    Ok(n)
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
    let entry = c.blocks.iter().position(|b| b.kind == BlockKind::Entry).expect("an entry");
    let mut bmap: Vec<Option<Block>> = alloc::vec![None; c.blocks.len()];
    for &cb in &c.layout {
        let kind = if c.blocks[cb.idx()].kind == BlockKind::Stub { BlockKind::Stub } else { BlockKind::Body };
        bmap[cb.idx()] = Some(f.block(kind));
    }
    let mut vmap: Vec<Option<Value>> = alloc::vec![None; c.values.len()];
    // The entry's parameters: the arguments, widened where the callee reads more bytes.
    for (n, &p) in c.blocks[entry].params.iter().enumerate() {
        let r = c.entry_regs[n];
        let a = cl.regs.iter().position(|x| x.xmm == r.xmm && x.index == r.index).expect("checked");
        // The call zero-extends an argument to its register's size; past that, the
        // register's bytes are unspecified.
        let size = (cl.regs[a].size as u8).min(8);
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
                let mut args = Vec::with_capacity(parts.len());
                for (n, &v) in parts.iter().enumerate() {
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
    prune(f);
    rebuild_preds(f);
}

/// Drops the blocks nothing reaches from the entry and the OSR entries any more (the code
/// after a landing pad stub no copied call unwinds to, say): emptied, trapping, out of the
/// layout.
fn prune(f: &mut Func) {
    let n = f.blocks.len();
    let mut seen = alloc::vec![false; n];
    let mut stack: Vec<Block> = f.layout.iter().copied().filter(|b| f.blocks[b.idx()].kind == BlockKind::Entry).collect();
    stack.extend(f.osr.iter().flatten().copied());
    while let Some(b) = stack.pop() {
        if core::mem::replace(&mut seen[b.idx()], true) {
            continue;
        }
        stack.extend(f.blocks[b.idx()].term.edges().iter().map(|e| e.to));
    }
    for b in 0..n {
        if !seen[b] {
            let bd = &mut f.blocks[b];
            bd.insts.clear();
            bd.params.clear();
            bd.term = Term::Trap;
            bd.kind = if bd.kind == BlockKind::Stub { BlockKind::Body } else { bd.kind };
        }
    }
    f.layout.retain(|b| seen[b.idx()]);
}

/// Recomputes every block's predecessors from the terminators of the blocks that can run.
pub fn rebuild_preds(f: &mut Func) {
    for bd in &mut f.blocks {
        bd.preds.clear();
    }
    for b in live_blocks(f) {
        let tos: Vec<Block> = f.blocks[b.idx()].term.edges().iter().map(|e| e.to).collect();
        for (k, to) in tos.into_iter().enumerate() {
            f.blocks[to.idx()].preds.push((b, k as u16));
        }
    }
}

/// Calls of functions `env` says to call through a symbol go through it.
pub fn retarget(f: &mut Func, env: &mut dyn Env) {
    let root = env.root();
    for b in live_blocks(f) {
        for k in 0..f.blocks[b.idx()].insts.len() {
            let i = f.blocks[b.idx()].insts[k];
            if let Op::Call(c) = &mut f.insts[i.idx()].op
                && let CallTarget::Func(g) = c.target
                && g != root
                && let Some(s) = env.retarget(g)
            {
                c.target = CallTarget::Sym(s);
            }
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
