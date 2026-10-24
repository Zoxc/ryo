//! SSA construction (Braun et al., CC 2013) from decoded reduced code (design/jit.md, "The SSA
//! tier"): the promoted fields of the frame ([`super::alloca`]) are the variables; blocks are
//! filled in layout order and sealed once all their predecessors are filled. A read in an
//! OSR entry block, which has no predecessors, loads the variable from the AOT frame
//! ([`Op::OsrLoad`]), so exactly the variables something reads after the head are loaded.
//!
//! Block parameters are built phi-style: each has an operand row, one per predecessor,
//! written once; trivial ones become aliases; the edges' argument lists are written at the
//! end ([`Func::resolve_aliases`] then drops the aliases with their arguments).

use alloc::boxed::Box;
use alloc::vec::Vec;

use super::Unsupported;
use super::alloca::{Frame, Res};
use super::decode::{Code, Kind, Then, Unwind};
use super::ir::*;
use crate::reduced::Arg;

const NO: u32 = u32::MAX;

struct B<'a> {
    code: &'a Code,
    fr: &'a Frame,
    f: Func,
    /// The current definition of each variable, per block (`NO`: none yet), allocated when
    /// first used.
    defs: Vec<Vec<u32>>,
    sealed: Vec<bool>,
    filled: Vec<u32>,
    expected: Vec<u32>,
    /// Per block, the parameters made before it was sealed, with their variables.
    incomplete: Vec<Vec<(u32, Value)>>,
    /// Per parameter value: its variable and operand row (by predecessor), and the
    /// parameters whose rows use it.
    rows: Vec<(u32, Vec<Value>)>,
    row_of: Vec<u32>,
    users: Vec<Vec<Value>>,
    undef: [Option<Value>; 9],
    /// The IR block of each R block (`None` for an `lpad`'s).
    ir: Vec<Option<Block>>,
    scratch: u32,
    mode: crate::asm::Mode,
}

impl<'a> B<'a> {
    fn new_block(&mut self, kind: BlockKind, expected: u32) -> Block {
        let b = self.f.block(kind);
        self.defs.push(Vec::new());
        self.sealed.push(false);
        self.filled.push(0);
        self.expected.push(expected);
        self.incomplete.push(Vec::new());
        b
    }

    fn undef(&mut self, w: u8) -> Value {
        if let Some(v) = self.undef[w as usize] {
            return v;
        }
        let v = self.f.value(ValueDef::Undef, w);
        self.undef[w as usize] = Some(v);
        v
    }

    fn def_slot(&mut self, b: Block, var: u32) -> &mut u32 {
        let d = &mut self.defs[b.idx()];
        if d.is_empty() {
            d.resize(self.fr.vars.len(), NO);
        }
        &mut d[var as usize]
    }

    fn write_var(&mut self, var: u32, b: Block, v: Value) {
        *self.def_slot(b, var) = v.0;
    }

    fn new_param(&mut self, b: Block, var: u32) -> Value {
        let w = self.fr.vars[var as usize].w;
        let p = self.f.param(b, w);
        if self.row_of.len() <= p.idx() {
            self.row_of.resize(p.idx() + 1, NO);
        }
        self.row_of[p.idx()] = self.rows.len() as u32;
        self.rows.push((var, Vec::new()));
        self.users.push(Vec::new());
        p
    }

    fn read_var(&mut self, var: u32, b: Block) -> Value {
        let d = *self.def_slot(b, var);
        if d != NO {
            return self.f.resolve(Value(d));
        }
        let w = self.fr.vars[var as usize].w;
        let v = if !self.sealed[b.idx()] {
            let p = self.new_param(b, var);
            self.incomplete[b.idx()].push((var, p));
            p
        } else {
            let preds = self.f.blocks[b.idx()].preds.clone();
            match preds.len() {
                0 => match self.f.blocks[b.idx()].kind {
                    BlockKind::Entry if self.fr.vars[var as usize].incoming() => {
                        // At the entry's top: the first read may come after the entry ended
                        // (in a call with a landing pad, say), and nothing writes these bytes.
                        let x = self.fr.vars[var as usize];
                        let off = x.off - self.f.allocas[x.alloca.idx()].aot_off;
                        let i = self.f.inst(b, Op::ALoad(x.alloca, off, w), Vec::new(), &[w]);
                        let insts = &mut self.f.blocks[b.idx()].insts;
                        insts.pop();
                        insts.insert(0, i);
                        self.f.result(i)
                    }
                    BlockKind::Osr(_) => {
                        let off = self.fr.vars[var as usize].off;
                        let i = self.f.inst(b, Op::OsrLoad(off, w), Vec::new(), &[w]);
                        self.f.result(i)
                    }
                    _ => self.undef(w),
                },
                1 => self.read_var(var, preds[0].0),
                _ => {
                    let p = self.new_param(b, var);
                    self.write_var(var, b, p);
                    self.add_operands(var, p)
                }
            }
        };
        self.write_var(var, b, v);
        v
    }

    fn add_operands(&mut self, var: u32, p: Value) -> Value {
        let ValueDef::Param(b, _) = self.f.def(p) else { unreachable!() };
        let preds = self.f.blocks[b.idx()].preds.clone();
        let mut row = Vec::with_capacity(preds.len());
        for (q, _) in preds {
            let v = self.read_var(var, q);
            row.push(v);
        }
        for &v in &row {
            if let ValueDef::Param(..) = self.f.def(v)
                && self.row_of.get(v.idx()).is_some_and(|&r| r != NO)
            {
                let r = self.row_of[v.idx()] as usize;
                self.users[r].push(p);
            }
        }
        let r = self.row_of[p.idx()] as usize;
        self.rows[r].1 = row;
        self.try_remove_trivial(p)
    }

    fn try_remove_trivial(&mut self, p: Value) -> Value {
        let r = self.row_of[p.idx()] as usize;
        let mut same: Option<Value> = None;
        for k in 0..self.rows[r].1.len() {
            let op = self.f.resolve(self.rows[r].1[k]);
            if Some(op) == same || op == p {
                continue;
            }
            if same.is_some() {
                return p;
            }
            same = Some(op);
        }
        let w = self.f.w(p);
        let same = match same {
            Some(s) => s,
            None => self.undef(w),
        };
        self.f.values[p.idx()].def = ValueDef::Alias(same);
        let users = core::mem::take(&mut self.users[r]);
        for u in users {
            if u != p && matches!(self.f.def(u), ValueDef::Param(..)) {
                self.try_remove_trivial(u);
            }
        }
        same
    }

    fn seal(&mut self, b: Block) {
        let inc = core::mem::take(&mut self.incomplete[b.idx()]);
        for (var, p) in inc {
            self.add_operands(var, p);
        }
        self.sealed[b.idx()] = true;
    }

    /// Ends `b` with `t`, and seals the successors whose predecessors are all filled.
    fn finish_block(&mut self, b: Block, t: Term) {
        let succ: Vec<Block> = t.edges().iter().map(|e| e.to).collect();
        self.f.terminate(b, t);
        for s in succ {
            self.filled[s.idx()] += 1;
            if self.filled[s.idx()] == self.expected[s.idx()] && !self.sealed[s.idx()] {
                self.seal(s);
            }
        }
    }

    /// The value access `k` of instruction `i` reads, at `w` bytes.
    fn read(&mut self, b: Block, i: usize, k: usize, w: u8) -> Value {
        match self.fr.res[i][k] {
            Res::Var(v) => self.read_var(v, b),
            Res::Undef => self.undef(w.max(1).min(8).next_power_of_two()),
            Res::Mem(a, off) => {
                let n = self.f.inst(b, Op::ALoad(a, off, w), Vec::new(), &[w]);
                self.f.result(n)
            }
        }
    }

    /// Writes `v` to the bytes of access `k` of instruction `i`.
    fn write(&mut self, b: Block, i: usize, k: usize, v: Value) {
        match self.fr.res[i][k] {
            Res::Mem(a, off) => {
                let n = self.code.insns[i].accs[k].size as u8;
                self.f.inst(b, Op::AStore(a, off, n), alloc::vec![v], &[]);
            }
            _ => {
                let var = self.fr.wvars[i][k];
                debug_assert_ne!(var, NO);
                self.write_var(var, b, v);
            }
        }
    }

    fn slot_ref(&self, i: usize, k: usize) -> Option<SlotRef> {
        match self.fr.res[i][k] {
            Res::Mem(a, off) => Some(SlotRef::Alloca(a, off)),
            _ => None,
        }
    }

    fn edge(&self, rinsn: u32) -> Edge {
        let rb = self.code.block_of[rinsn as usize] as usize;
        Edge::to(self.ir[rb].expect("not an lpad"))
    }
}

/// The IR of `code` with frame `fr`, before the optimizations ([`super::opt::run`]).
pub fn build(code: &Code, fr: &Frame, frame_size: u32, mode: crate::asm::Mode) -> Result<Func, Unsupported> {
    let nb = code.blocks.len();
    if fr.vars.len().saturating_mul(nb) > 8 << 20 {
        return Err(Unsupported("too many variables and blocks"));
    }
    let mut s = B {
        code,
        fr,
        f: Func { allocas: fr.allocas.clone(), aot_frame: frame_size, osr: alloc::vec![None; code.enterable.len()], ..Default::default() },
        defs: Vec::new(),
        sealed: Vec::new(),
        filled: Vec::new(),
        expected: Vec::new(),
        incomplete: Vec::new(),
        rows: Vec::new(),
        row_of: Vec::new(),
        users: Vec::new(),
        undef: [None; 9],
        ir: alloc::vec![None; nb],
        scratch: 0,
        mode,
    };
    let is_lpad = |b: usize| code.insns[code.blocks[b].start as usize].kind == Kind::Lpad;
    // The entry block: R block 0 itself unless something branches back to it.
    let entry = s.new_block(BlockKind::Entry, 0);
    let mut layout = Vec::new();
    let separate = !code.blocks.is_empty() && !code.blocks[0].preds.is_empty();
    for b in 0..nb {
        if is_lpad(b) {
            continue;
        }
        s.ir[b] = Some(if b == 0 && !separate { entry } else { s.new_block(BlockKind::Body, 0) });
        s.f.blocks[s.ir[b].unwrap().idx()].head = code.blocks[b].head;
    }
    // Expected predecessors: the R edges, with landing pads' through their stubs to the
    // block after the `lpad`.
    for b in 0..nb {
        if is_lpad(b) {
            continue;
        }
        for &t in &code.blocks[b].succ {
            let t = t as usize;
            let to = if is_lpad(t) { code.blocks[t].succ[0] as usize } else { t };
            let to = s.ir[to].ok_or(Unsupported("an lpad after an lpad"))?;
            s.expected[to.idx()] += 1;
        }
    }
    if separate {
        let first = s.ir[0].unwrap();
        s.expected[first.idx()] += 1;
    }
    s.seal(entry);
    // OSR entries, filled first.
    for (b, bl) in code.blocks.iter().enumerate() {
        if let Some(h) = bl.head
            && code.enterable[h as usize]
        {
            let o = s.new_block(BlockKind::Osr(h), 0);
            s.seal(o);
            s.f.osr[h as usize] = Some(o);
            let head = s.ir[b].unwrap();
            s.expected[head.idx()] += 1;
            s.finish_block(o, Term::Jmp(Edge::to(head)));
        }
    }
    for b in 0..nb {
        if let Some(x) = s.ir[b]
            && s.expected[x.idx()] == 0
            && !s.sealed[x.idx()]
        {
            s.seal(x);
        }
    }
    if separate {
        if matches!(code.insns.first().map(|i| &i.kind), Some(Kind::Arg(_))) {
            return Err(Unsupported("arguments in a loop"));
        }
        layout.push(entry);
        let first = s.ir[0].unwrap();
        s.finish_block(entry, Term::Jmp(Edge::to(first)));
    }

    for rb in 0..nb {
        let Some(cur) = s.ir[rb] else { continue };
        layout.push(cur);
        let bl = &code.blocks[rb];
        let mut term = None;
        let mut extra: Vec<Block> = Vec::new();
        for i in bl.start as usize..bl.end as usize {
            let ri = &code.insns[i];
            let last = i + 1 == bl.end as usize;
            let next = || s_next(code, i);
            let site = match ri.unwind {
                Unwind::None => Site::None,
                Unwind::Continue => Site::Continue,
                Unwind::Pad { catch, .. } => Site::Pad { catch },
            };
            match &ri.kind {
                Kind::Mov(w) => {
                    let v = s.read(cur, i, 0, *w);
                    s.write(cur, i, 1, v);
                }
                Kind::Mov128 => {
                    let (Res::Mem(sa, so), Res::Mem(da, dof)) = (fr.res[i][0], fr.res[i][1]) else {
                        return Err(Unsupported("mov.w128 of promoted bytes"));
                    };
                    for h in [0, 8] {
                        let l = s.f.inst(cur, Op::ALoad(sa, so + h, 8), Vec::new(), &[8]);
                        let v = s.f.result(l);
                        s.f.inst(cur, Op::AStore(da, dof + h, 8), alloc::vec![v], &[]);
                    }
                }
                Kind::Imm(w, v) => {
                    let c = s.f.konst(*v, *w);
                    s.write(cur, i, 0, c);
                }
                Kind::Load(w, k) => {
                    let p = s.read(cur, i, 0, 8);
                    let l = s.f.inst(cur, Op::Load(*w, *k), alloc::vec![p], &[*w]);
                    let v = s.f.result(l);
                    s.write(cur, i, 1, v);
                }
                Kind::Store(w, k) => {
                    let p = s.read(cur, i, 0, 8);
                    let v = s.read(cur, i, 1, *w);
                    s.f.inst(cur, Op::Store(*w, *k), alloc::vec![p, v], &[]);
                }
                Kind::Addr => {
                    let Res::Mem(a, off) = fr.res[i][0] else { return Err(Unsupported("an address of a promoted alloca")) };
                    let l = s.f.inst(cur, Op::AllocaAddr(a, off), Vec::new(), &[8]);
                    let v = s.f.result(l);
                    s.write(cur, i, 1, v);
                }
                Kind::PtrAdd(imm) => {
                    let p = s.read(cur, i, 0, 8);
                    let l = s.f.inst(cur, Op::PtrAdd(*imm), alloc::vec![p], &[8]);
                    let v = s.f.result(l);
                    s.write(cur, i, 1, v);
                }
                Kind::PtrIndex(stride) => {
                    let p = s.read(cur, i, 0, 8);
                    let x = s.read(cur, i, 1, 8);
                    let l = s.f.inst(cur, Op::PtrIndex(*stride), alloc::vec![p, x], &[8]);
                    let v = s.f.result(l);
                    s.write(cur, i, 2, v);
                }
                Kind::Bin(op, w, imm) => {
                    let a = s.read(cur, i, 0, *w);
                    let op = match op {
                        super::decode::Bin::Add => BinOp::Add,
                        super::decode::Bin::Sub => BinOp::Sub,
                        super::decode::Bin::Mul => BinOp::Mul,
                        super::decode::Bin::And => BinOp::And,
                        super::decode::Bin::Or => BinOp::Or,
                        super::decode::Bin::Xor => BinOp::Xor,
                        super::decode::Bin::Shl => BinOp::Shl,
                        super::decode::Bin::ShrS => BinOp::ShrS,
                        super::decode::Bin::ShrU => BinOp::ShrU,
                    };
                    let shift = matches!(op, BinOp::Shl | BinOp::ShrS | BinOp::ShrU);
                    let b = match imm {
                        Some(v) if shift => s.f.konst(v & (8 * *w as u64 - 1), *w),
                        Some(v) => s.f.konst(mask(*v, *w), *w),
                        None if shift => return Err(Unsupported("a shift by a slot")),
                        None => s.read(cur, i, 1, *w),
                    };
                    let l = s.f.inst(cur, Op::Bin(op, *w), alloc::vec![a, b], &[*w]);
                    let v = s.f.result(l);
                    s.write(cur, i, ri.accs.len() - 1, v);
                }
                Kind::Cmp(cc, w, imm) => {
                    let a = s.read(cur, i, 0, *w);
                    let b = match imm {
                        Some(v) => s.f.konst(mask(*v, *w), *w),
                        None => s.read(cur, i, 1, *w),
                    };
                    let l = s.f.inst(cur, Op::Cmp(*cc, *w), alloc::vec![a, b], &[1]);
                    let v = s.f.result(l);
                    s.write(cur, i, ri.accs.len() - 1, v);
                }
                Kind::Ovf(op, signed, w) => {
                    let a = s.read(cur, i, 0, *w);
                    let b = s.read(cur, i, 1, *w);
                    let op = match op {
                        super::decode::Bin::Add => BinOp::Add,
                        super::decode::Bin::Sub => BinOp::Sub,
                        _ => BinOp::Mul,
                    };
                    let l = s.f.inst(cur, Op::Ovf(op, *signed, *w), alloc::vec![a, b], &[*w, 1]);
                    let r = s.f.insts[l.idx()].res;
                    s.write(cur, i, 2, Value(r));
                    s.write(cur, i, 3, Value(r + 1));
                }
                Kind::Ext { from, to, sx } => {
                    let a = s.read(cur, i, 0, *from);
                    let l = s.f.inst(cur, Op::Ext { from: *from, to: *to, sx: *sx }, alloc::vec![a], &[*to]);
                    let v = s.f.result(l);
                    s.write(cur, i, 1, v);
                }
                Kind::Jmp(t) => term = Some(Term::Jmp(s.edge(*t))),
                Kind::Br { cmp, neg, t } => {
                    let (tt, ff) = (s.edge(*t), s.edge(next()?));
                    let (tt, ff) = if *neg { (ff, tt) } else { (tt, ff) };
                    term = Some(match cmp {
                        None => Term::Br { cond: s.read(cur, i, 0, 1), t: tt, f: ff },
                        Some((cc, w, imm)) => {
                            let a = s.read(cur, i, 0, *w);
                            let b = match imm {
                                Some(v) => s.f.konst(mask(*v, *w), *w),
                                None => s.read(cur, i, 1, *w),
                            };
                            Term::BrCmp { cc: *cc, w: *w, a, b, t: tt, f: ff }
                        }
                    });
                }
                Kind::Call { target, regs, parts, .. } => {
                    let mut args = Vec::new();
                    let mut k = 0;
                    if *target == CallTarget::Ptr {
                        args.push(s.read(cur, i, 0, 8));
                        k = 1;
                    }
                    for r in regs {
                        let v = if ri.accs[k].how == super::decode::How::Addr {
                            let Res::Mem(a, off) = fr.res[i][k] else { return Err(Unsupported("an address of a promoted alloca")) };
                            let l = s.f.inst(cur, Op::AllocaAddr(a, off), Vec::new(), &[8]);
                            s.f.result(l)
                        } else {
                            s.read(cur, i, k, r.size as u8)
                        };
                        args.push(v);
                        k += 1;
                    }
                    let ws: Vec<u8> = parts.iter().map(|p| if matches!(p.size, 1 | 2 | 4 | 8) { p.size as u8 } else { 8 }).collect();
                    let call = Call { target: *target, regs: regs.clone(), parts: parts.clone(), site };
                    let ci = s.f.inst(cur, Op::Call(Box::new(call)), args, &ws);
                    let results: Vec<Value> = s.f.insts[ci.idx()].results().collect();
                    if let Unwind::Pad { pad, .. } = ri.unwind {
                        let cont = s.new_block(BlockKind::Body, 1);
                        let stub = stub_block(&mut s, pad)?;
                        s.finish_block(cur, Term::Invoke { normal: Some(Edge::to(cont)), pad: Edge::to(stub.0) });
                        fill_stub(&mut s, stub)?;
                        for (n, v) in results.into_iter().enumerate() {
                            s.write(cont, i, k + n, v);
                        }
                        let e = s.edge(next()?);
                        s.finish_block(cont, Term::Jmp(e));
                        extra.extend([cont, stub.0]);
                        term = None;
                        debug_assert!(last);
                        break;
                    }
                    for (n, v) in results.into_iter().enumerate() {
                        s.write(cur, i, k + n, v);
                    }
                }
                Kind::TailCall { target, regs } => {
                    let mut args = Vec::new();
                    let mut k = 0;
                    if *target == CallTarget::Ptr {
                        args.push(s.read(cur, i, 0, 8));
                        k = 1;
                    }
                    for r in regs {
                        let v = if ri.accs[k].how == super::decode::How::Addr {
                            let Res::Mem(a, off) = fr.res[i][k] else { return Err(Unsupported("an address of a promoted alloca")) };
                            let l = s.f.inst(cur, Op::AllocaAddr(a, off), Vec::new(), &[8]);
                            s.f.result(l)
                        } else {
                            s.read(cur, i, k, r.size as u8)
                        };
                        args.push(v);
                        k += 1;
                    }
                    term = Some(Term::TailCall {
                        call: Box::new(Call { target: *target, regs: regs.clone(), parts: Vec::new(), site: Site::None }),
                        args,
                    });
                }
                Kind::Ret { k, parts } => {
                    let vs = (0..parts.len()).map(|n| s.read(cur, i, n, parts[n].size as u8)).collect();
                    term = Some(Term::Ret { k: *k, parts: vs });
                }
                Kind::Arg(r) => {
                    if cur != entry {
                        return Err(Unsupported("an arg outside the entry"));
                    }
                    let w = if matches!(r.size, 1 | 2 | 4 | 8) { r.size as u8 } else { 8 };
                    let v = s.f.param(entry, w);
                    s.f.entry_regs.push(*r);
                    s.write(cur, i, 0, v);
                }
                Kind::Island { isl, ops } => {
                    let mut refs = Vec::with_capacity(ops.len());
                    for k in 0..ops.len() {
                        // A zero-sized operand: any frame address (it is never accessed).
                        let r = if ri.accs[k].size == 0 { Some(SlotRef::Scratch(0)) } else { s.slot_ref(i, k) };
                        refs.push(r.ok_or(Unsupported("a promoted island operand"))?);
                    }
                    let isl = Island { isl: *isl, ops: refs, site };
                    s.f.inst(cur, Op::Island(Box::new(isl)), Vec::new(), &[]);
                    if let Unwind::Pad { pad, .. } = ri.unwind {
                        let cont = s.new_block(BlockKind::Body, 1);
                        let stub = stub_block(&mut s, pad)?;
                        s.finish_block(cur, Term::Invoke { normal: Some(Edge::to(cont)), pad: Edge::to(stub.0) });
                        fill_stub(&mut s, stub)?;
                        let e = s.edge(next()?);
                        s.finish_block(cont, Term::Jmp(e));
                        extra.extend([cont, stub.0]);
                        term = None;
                        break;
                    }
                }
                Kind::Handler { h, args, slots, then } => {
                    let mut regs: Vec<(Arg, [Option<SlotRef>; 2])> = args.iter().map(|&a| (a, [None, None])).collect();
                    let mut ins = Vec::new();
                    let mut outs = Vec::new();
                    let mut in_vals = Vec::new();
                    let mut out_ws = Vec::new();
                    // The outputs' accesses, in order.
                    let mut out_acc = Vec::new();
                    let mut sc = 0u32;
                    // Through the register entry when it has one and every frame operand is
                    // a variable: the values go in registers, and the scratch area isn't used.
                    let reg = super::effects::reg_entry(*h, s.mode).is_some() && (0..slots.len()).all(|k| s.slot_ref(i, k).is_none());
                    for (k, &(reg, half)) in slots.iter().enumerate() {
                        let a = ri.accs[k];
                        let r = match s.slot_ref(i, k) {
                            Some(r) => r,
                            None => {
                                let at = sc;
                                sc += 8;
                                if matches!(a.how, super::decode::How::Read | super::decode::How::Update) {
                                    in_vals.push(s.read(cur, i, k, a.size as u8));
                                    ins.push(at);
                                }
                                if matches!(a.how, super::decode::How::Write | super::decode::How::Update) {
                                    outs.push(at);
                                    out_ws.push(a.size as u8);
                                    out_acc.push(k);
                                }
                                SlotRef::Scratch(at)
                            }
                        };
                        regs[reg as usize].1[half as usize] = Some(r);
                    }
                    if reg {
                        ins.clear();
                        outs.clear();
                    } else {
                        s.scratch = s.scratch.max(sc);
                    }
                    let ret = matches!(then, Then::Branch { .. } | Then::Table(_));
                    let mut ws = out_ws.clone();
                    match then {
                        Then::Branch { .. } => ws.push(1),
                        Then::Table(_) => ws.push(8),
                        _ => {}
                    }
                    let hc = HCall { h: *h, regs, ins, outs, nout: out_ws.len() as u8, ret, reg, site };
                    let hi = s.f.inst(cur, Op::HCall(Box::new(hc)), in_vals, &ws);
                    let results: Vec<Value> = s.f.insts[hi.idx()].results().collect();
                    for (n, &k) in out_acc.iter().enumerate() {
                        s.write(cur, i, k, results[n]);
                    }
                    match then {
                        Then::Next => {}
                        Then::Branch { neg, t } => {
                            let (tt, ff) = (s.edge(*t), s.edge(next()?));
                            let (tt, ff) = if *neg { (ff, tt) } else { (tt, ff) };
                            term = Some(Term::Br { cond: *results.last().unwrap(), t: tt, f: ff });
                        }
                        Then::Table(ts) => {
                            let targets = ts.iter().map(|&t| s.edge(t)).collect();
                            term = Some(Term::Switch { idx: *results.last().unwrap(), targets });
                        }
                        Then::Trap => {
                            if let Unwind::Pad { pad, .. } = ri.unwind {
                                let stub = stub_block(&mut s, pad)?;
                                s.finish_block(cur, Term::Invoke { normal: None, pad: Edge::to(stub.0) });
                                fill_stub(&mut s, stub)?;
                                extra.push(stub.0);
                                term = None;
                                break;
                            }
                            term = Some(Term::Trap);
                        }
                    }
                }
                Kind::Unreachable => term = Some(Term::Trap),
                Kind::Lpad => return Err(Unsupported("an lpad in a block")),
            }
            if last && term.is_none() && extra.is_empty() && !matches!(s.f.blocks[cur.idx()].term, Term::Invoke { .. }) {
                // Falls through into the next block.
                term = Some(Term::Jmp(s.edge(next()?)));
            }
        }
        if let Some(t) = term {
            s.finish_block(cur, t);
        }
        layout.extend(extra);
    }
    // Parameters left incomplete belong to blocks never sealed: unreachable ones.
    for b in 0..s.f.blocks.len() {
        if !s.sealed[b] {
            s.seal(Block(b as u32));
        }
    }
    // The edges' arguments, from the operand rows.
    for b in 0..s.f.blocks.len() {
        let params = s.f.blocks[b].params.clone();
        if params.is_empty() {
            continue;
        }
        let preds = s.f.blocks[b].preds.clone();
        for (j, &(p, k)) in preds.iter().enumerate() {
            let args: Vec<Value> = params
                .iter()
                .map(|&x| {
                    if s.f.blocks[b].kind == BlockKind::Entry {
                        return x;
                    }
                    let r = s.row_of[x.idx()] as usize;
                    s.rows[r].1[j]
                })
                .collect();
            let mut t = core::mem::replace(&mut s.f.blocks[p.idx()].term, Term::None);
            t.edges_mut()[k as usize].args = args;
            s.f.blocks[p.idx()].term = t;
        }
    }
    s.f.resolve_aliases();
    s.f.scratch = s.scratch;
    s.f.layout = layout;
    Ok(s.f)
}

/// The instruction index after `i`.
fn s_next(code: &Code, i: usize) -> Result<u32, Unsupported> {
    if i + 1 < code.insns.len() { Ok(i as u32 + 1) } else { Err(Unsupported("falls off the end")) }
}

/// A landing pad stub for the `lpad` at instruction `pad`: the block, and the `lpad`.
fn stub_block(s: &mut B<'_>, pad: u32) -> Result<(Block, u32), Unsupported> {
    let b = s.new_block(BlockKind::Stub, 1);
    Ok((b, pad))
}

/// The stub's body: the exception object into the `lpad`'s slot, then to the code after it.
fn fill_stub(s: &mut B<'_>, (b, pad): (Block, u32)) -> Result<(), Unsupported> {
    let l = s.f.inst(b, Op::LandingPad, Vec::new(), &[8]);
    let exc = s.f.result(l);
    s.write(b, pad as usize, 0, exc);
    let e = s.edge(s_next(s.code, pad as usize)?);
    s.finish_block(b, Term::Jmp(e));
    Ok(())
}
