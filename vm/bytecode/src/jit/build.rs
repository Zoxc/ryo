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
use crate::asm::ArgReg;
use crate::reduced::Arg;

const NO: u32 = u32::MAX;

struct B<'a> {
    code: &'a Code,
    fr: &'a Frame,
    f: Func,
    /// Per block.
    blocks: Vec<BlockState>,
    /// The phi-style parameters, by value (`None`: not one, such as an entry argument).
    phis: Vec<Option<Phi>>,
    undef: [Option<Value>; 17],
    /// The IR block of each R block (`None` for an `lpad`'s).
    ir: Vec<Option<Block>>,
    entry: Block,
    /// The blocks in layout order, as filled.
    layout: Vec<Block>,
    scratch: u32,
    mode: crate::asm::Mode,
}

#[derive(Default)]
struct BlockState {
    /// The current definition of each variable, allocated when first used.
    defs: Vec<Option<Value>>,
    sealed: bool,
    /// Predecessors filled, and expected.
    filled: u32,
    expected: u32,
    /// The parameters made before it was sealed, with their variables.
    incomplete: Vec<(u32, Value)>,
}

/// A block parameter's operand row (by predecessor), and the parameters whose rows use it.
#[derive(Default)]
struct Phi {
    row: Vec<Value>,
    users: Vec<Value>,
}

impl<'a> B<'a> {
    fn new_block(&mut self, kind: BlockKind, expected: u32) -> Block {
        let b = self.f.block(kind);
        self.blocks.push(BlockState { expected, ..Default::default() });
        b
    }

    fn phi(&mut self, p: Value) -> &mut Phi {
        self.phis[p.idx()].as_mut().expect("a phi parameter")
    }

    fn undef(&mut self, w: u8) -> Value {
        if let Some(v) = self.undef[w as usize] {
            return v;
        }
        let v = self.f.value(ValueDef::Undef, w);
        self.undef[w as usize] = Some(v);
        v
    }

    fn def_slot(&mut self, b: Block, var: u32) -> &mut Option<Value> {
        let d = &mut self.blocks[b.idx()].defs;
        if d.is_empty() {
            d.resize(self.fr.vars.len(), None);
        }
        &mut d[var as usize]
    }

    fn write_var(&mut self, var: u32, b: Block, v: Value) {
        *self.def_slot(b, var) = Some(v);
    }

    fn new_param(&mut self, b: Block, var: u32) -> Value {
        let w = self.fr.vars[var as usize].w;
        let p = self.f.param(b, w);
        if self.phis.len() <= p.idx() {
            self.phis.resize_with(p.idx() + 1, || None);
        }
        self.phis[p.idx()] = Some(Phi::default());
        p
    }

    fn read_var(&mut self, var: u32, b: Block) -> Value {
        if let Some(d) = *self.def_slot(b, var) {
            return self.f.resolve(d);
        }
        let w = self.fr.vars[var as usize].w;
        let v = if !self.blocks[b.idx()].sealed {
            let p = self.new_param(b, var);
            self.blocks[b.idx()].incomplete.push((var, p));
            p
        } else {
            match self.f.blocks[b.idx()].preds.len() {
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
                1 => self.read_var(var, self.f.blocks[b.idx()].preds[0].0),
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
        // `b` is sealed: its predecessors stay as they are.
        let n = self.f.blocks[b.idx()].preds.len();
        let mut row = Vec::with_capacity(n);
        for k in 0..n {
            let v = self.read_var(var, self.f.blocks[b.idx()].preds[k].0);
            row.push(v);
        }
        for &v in &row {
            if let ValueDef::Param(..) = self.f.def(v)
                && let Some(Some(u)) = self.phis.get_mut(v.idx())
            {
                u.users.push(p);
            }
        }
        self.phi(p).row = row;
        self.try_remove_trivial(p)
    }

    fn try_remove_trivial(&mut self, p: Value) -> Value {
        let mut same: Option<Value> = None;
        for k in 0..self.phi(p).row.len() {
            let v = self.phi(p).row[k];
            let op = self.f.resolve(v);
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
        let users = core::mem::take(&mut self.phi(p).users);
        for u in users {
            if u != p && matches!(self.f.def(u), ValueDef::Param(..)) {
                self.try_remove_trivial(u);
            }
        }
        same
    }

    fn seal(&mut self, b: Block) {
        let inc = core::mem::take(&mut self.blocks[b.idx()].incomplete);
        for (var, p) in inc {
            self.add_operands(var, p);
        }
        self.blocks[b.idx()].sealed = true;
    }

    /// Ends `b` with `t`, and seals the successors whose predecessors are all filled.
    fn finish_block(&mut self, b: Block, t: Term) {
        let succ: Vec<Block> = t.edges().map(|e| e.to).collect();
        self.f.terminate(b, t);
        for s in succ {
            let st = &mut self.blocks[s.idx()];
            st.filled += 1;
            if st.filled == st.expected && !st.sealed {
                self.seal(s);
            }
        }
    }

    /// The value access `k` of instruction `i` reads, at `w` bytes.
    fn read(&mut self, b: Block, i: usize, k: usize, w: u8) -> Value {
        match self.fr.res[i][k] {
            Res::Var(v) => self.read_var(v, b),
            Res::Undef if w == 16 => self.undef(16),
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

    /// The arguments of call instruction `i` in `cur`: the callee pointer (for `Ptr`), then
    /// each register's value (an address for one passed by address); and the index of the
    /// accesses after them (the results').
    fn call_args(&mut self, cur: Block, i: usize, target: CallTarget, regs: &[ArgReg]) -> Result<(Vec<Value>, usize), Unsupported> {
        let mut args = Vec::new();
        let mut k = 0;
        if target == CallTarget::Ptr {
            args.push(self.read(cur, i, 0, 8));
            k = 1;
        }
        for r in regs {
            let v = if self.code.insns[i].accs[k].how == super::decode::How::Addr {
                let Res::Mem(a, off) = self.fr.res[i][k] else { return Err(Unsupported("an address of a promoted alloca")) };
                let l = self.f.inst(cur, Op::AllocaAddr(a, off), Vec::new(), &[8]);
                self.f.result(l)
            } else {
                self.read(cur, i, k, r.size as u8)
            };
            args.push(v);
            k += 1;
        }
        Ok((args, k))
    }

    /// Ends `cur`, whose instruction `i` is a call site unwinding to the `lpad` at `pad`, with
    /// an invoke: when it returns (`normal`: its results, written to the accesses from the
    /// given index), to a new block that goes on after `i`. The new blocks, for the layout.
    fn invoke(&mut self, cur: Block, i: usize, pad: u32, normal: Option<(&[Value], usize)>) -> Result<Vec<Block>, Unsupported> {
        let cont = normal.map(|_| self.new_block(BlockKind::Body, 1));
        let stub = self.new_block(BlockKind::Stub, 1);
        self.finish_block(cur, Term::Invoke { normal: cont.map(Edge::to), pad: Edge::to(stub) });
        // The stub: the exception object into the `lpad`'s slot, then to the code after it.
        let l = self.f.inst(stub, Op::LandingPad, Vec::new(), &[8]);
        let exc = self.f.result(l);
        self.write(stub, pad as usize, 0, exc);
        let e = self.edge(s_next(self.code, pad as usize)?);
        self.finish_block(stub, Term::Jmp(e));
        let (Some(cont), Some((results, k))) = (cont, normal) else { return Ok(alloc::vec![stub]) };
        for (n, &v) in results.iter().enumerate() {
            self.write(cont, i, k + n, v);
        }
        let e = self.edge(s_next(self.code, i)?);
        self.finish_block(cont, Term::Jmp(e));
        Ok(alloc::vec![cont, stub])
    }
}

/// How an instruction leaves its block.
enum Flow {
    /// It goes on to the next instruction (or falls through into the next block).
    Next,
    /// It ends the block with the terminator.
    End(Term),
    /// It ended the block itself (an invoke), making the blocks, for the layout.
    Ended(Vec<Block>),
}

impl<'a> B<'a> {
    fn new(code: &'a Code, fr: &'a Frame, frame_size: u32, mode: crate::asm::Mode) -> Result<Self, Unsupported> {
        let nb = code.blocks.len();
        if fr.vars.len().saturating_mul(nb) > 8 << 20 {
            return Err(Unsupported("too many variables and blocks"));
        }
        let mut s = B {
            code,
            fr,
            f: Func {
                allocas: fr.allocas.clone(),
                aot_frame: frame_size,
                pe: mode.pe,
                osr: alloc::vec![None; code.enterable.len()],
                ..Default::default()
            },
            blocks: Vec::new(),
            phis: Vec::new(),
            undef: [None; 17],
            ir: alloc::vec![None; nb],
            entry: Block(0),
            layout: Vec::new(),
            scratch: 0,
            mode,
        };
        s.entry = s.new_block(BlockKind::Entry, 0);
        Ok(s)
    }

    fn is_lpad(&self, b: usize) -> bool {
        self.code.insns[self.code.blocks[b].start as usize].kind == Kind::Lpad
    }

    /// Makes the IR blocks of the R blocks and the OSR entries, with their expected
    /// predecessors, and fills the entry and OSR blocks.
    fn layout_blocks(&mut self) -> Result<(), Unsupported> {
        let code = self.code;
        let nb = code.blocks.len();
        let entry = self.entry;
        // The entry block: R block 0 itself unless something branches back to it.
        let separate = !code.blocks.is_empty() && !code.blocks[0].preds.is_empty();
        for b in 0..nb {
            if self.is_lpad(b) {
                continue;
            }
            self.ir[b] = Some(if b == 0 && !separate { entry } else { self.new_block(BlockKind::Body, 0) });
            self.f.blocks[self.ir[b].unwrap().idx()].head = code.blocks[b].head;
        }
        // Expected predecessors: the R edges, with landing pads' through their stubs to the
        // block after the `lpad`.
        for b in 0..nb {
            if self.is_lpad(b) {
                continue;
            }
            for &t in &code.blocks[b].succ {
                let t = t as usize;
                let to = if self.is_lpad(t) { code.blocks[t].succ[0] as usize } else { t };
                let to = self.ir[to].ok_or(Unsupported("an lpad after an lpad"))?;
                self.blocks[to.idx()].expected += 1;
            }
        }
        if separate {
            let first = self.ir[0].unwrap();
            self.blocks[first.idx()].expected += 1;
        }
        self.seal(entry);
        // OSR entries, filled first.
        for (b, bl) in code.blocks.iter().enumerate() {
            if let Some(h) = bl.head
                && code.enterable[h as usize]
            {
                let o = self.new_block(BlockKind::Osr(h), 0);
                self.seal(o);
                self.f.osr[h as usize] = Some(o);
                let head = self.ir[b].unwrap();
                self.blocks[head.idx()].expected += 1;
                self.finish_block(o, Term::Jmp(Edge::to(head)));
            }
        }
        for b in 0..nb {
            if let Some(x) = self.ir[b]
                && self.blocks[x.idx()].expected == 0
                && !self.blocks[x.idx()].sealed
            {
                self.seal(x);
            }
        }
        if separate {
            if matches!(code.insns.first().map(|i| &i.kind), Some(Kind::Arg(_))) {
                return Err(Unsupported("arguments in a loop"));
            }
            self.layout.push(entry);
            let first = self.ir[0].unwrap();
            self.finish_block(entry, Term::Jmp(Edge::to(first)));
        }
        Ok(())
    }

    /// Fills `cur`, the IR block of R block `rb`.
    fn lower_block(&mut self, rb: usize, cur: Block) -> Result<(), Unsupported> {
        self.layout.push(cur);
        let bl = &self.code.blocks[rb];
        for i in bl.start as usize..bl.end as usize {
            match self.lower_insn(cur, i)? {
                Flow::Next => {}
                Flow::End(t) => {
                    debug_assert_eq!(i + 1, bl.end as usize, "a terminator inside a block");
                    self.finish_block(cur, t);
                    return Ok(());
                }
                Flow::Ended(extra) => {
                    debug_assert_eq!(i + 1, bl.end as usize, "an invoke inside a block");
                    self.layout.extend(extra);
                    return Ok(());
                }
            }
        }
        // Falls through into the next block.
        let e = self.edge(s_next(self.code, bl.end as usize - 1)?);
        self.finish_block(cur, Term::Jmp(e));
        Ok(())
    }

    /// Lowers instruction `i` into `cur`.
    fn lower_insn(&mut self, cur: Block, i: usize) -> Result<Flow, Unsupported> {
        let code = self.code;
        let ri = &code.insns[i];
        let next = || s_next(code, i);
        let site = match ri.unwind {
            Unwind::None => Site::None,
            Unwind::Continue => Site::Continue,
            Unwind::Pad { catch, .. } => Site::Pad { catch },
        };
        match &ri.kind {
            Kind::Mov(w) => {
                let v = self.read(cur, i, 0, *w);
                self.write(cur, i, 1, v);
            }
            Kind::Copy { dst, src, pieces, .. } => {
                use super::decode::Side;
                let mem = matches!(dst, Side::Mem(_)) || matches!(src, Side::Mem(_));
                let p = if mem {
                    Some(self.read(cur, i, 0, 8))
                } else if let Side::Pool(k) = src {
                    let a = self.f.inst(cur, Op::RefAddr(crate::asm::Ref::Const(crate::full::Const(*k)), false), Vec::new(), &[8]);
                    Some(self.f.result(a))
                } else {
                    None
                };
                let mut k = mem as usize;
                // Every piece read first, then written: exact when the two overlap.
                let mut vals = Vec::with_capacity(pieces.len());
                for &(off, w) in pieces {
                    vals.push(match src {
                        Side::Frame(_) => {
                            k += 1;
                            self.read(cur, i, k - 1, w)
                        }
                        Side::Mem(d) => {
                            let l = self.f.inst(cur, Op::Load(w, d + off as i32), alloc::vec![p.unwrap()], &[w]);
                            self.f.result(l)
                        }
                        Side::Zero => self.f.konst(0, w),
                        Side::Pool(_) => {
                            let l = self.f.inst(cur, Op::Load(w, off as i32), alloc::vec![p.unwrap()], &[w]);
                            self.f.result(l)
                        }
                    });
                }
                for (&(off, w), v) in pieces.iter().zip(vals) {
                    match dst {
                        Side::Frame(_) => {
                            self.write(cur, i, k, v);
                            k += 1;
                        }
                        Side::Mem(d) => {
                            self.f.inst(cur, Op::Store(w, d + off as i32), alloc::vec![p.unwrap(), v], &[]);
                        }
                        Side::Zero | Side::Pool(_) => unreachable!("a source-only side"),
                    }
                }
            }
            Kind::Imm(w, v) => {
                let c = self.f.konst(*v, *w);
                self.write(cur, i, 0, c);
            }
            Kind::Load(w, k) => {
                let p = self.read(cur, i, 0, 8);
                let l = self.f.inst(cur, Op::Load(*w, *k), alloc::vec![p], &[*w]);
                let v = self.f.result(l);
                self.write(cur, i, 1, v);
            }
            Kind::Store(w, k) => {
                let p = self.read(cur, i, 0, 8);
                let v = self.read(cur, i, 1, *w);
                self.f.inst(cur, Op::Store(*w, *k), alloc::vec![p, v], &[]);
            }
            Kind::Addr => {
                let Res::Mem(a, off) = self.fr.res[i][0] else { return Err(Unsupported("an address of a promoted alloca")) };
                let l = self.f.inst(cur, Op::AllocaAddr(a, off), Vec::new(), &[8]);
                let v = self.f.result(l);
                self.write(cur, i, 1, v);
            }
            Kind::RefAddr { to, ind } => {
                let l = self.f.inst(cur, Op::RefAddr(*to, *ind), Vec::new(), &[8]);
                let v = self.f.result(l);
                self.write(cur, i, 0, v);
            }
            Kind::PtrAdd(imm) => {
                let p = self.read(cur, i, 0, 8);
                let l = self.f.inst(cur, Op::PtrAdd(*imm), alloc::vec![p], &[8]);
                let v = self.f.result(l);
                self.write(cur, i, 1, v);
            }
            Kind::PtrIndex(stride) => {
                let p = self.read(cur, i, 0, 8);
                let x = self.read(cur, i, 1, 8);
                let l = self.f.inst(cur, Op::PtrIndex(*stride), alloc::vec![p, x], &[8]);
                let v = self.f.result(l);
                self.write(cur, i, 2, v);
            }
            Kind::Bin(op, w, imm) => {
                let a = self.read(cur, i, 0, *w);
                let shift = matches!(*op, BinOp::Shl | BinOp::ShrS | BinOp::ShrU);
                let b = match imm {
                    Some(v) if shift => self.f.konst(v & (8 * *w as u64 - 1), *w),
                    Some(v) => self.f.konst(mask(*v, *w), *w),
                    None => self.read(cur, i, 1, *w),
                };
                let l = self.f.inst(cur, Op::Bin(*op, *w), alloc::vec![a, b], &[*w]);
                let v = self.f.result(l);
                self.write(cur, i, ri.accs.len() - 1, v);
            }
            Kind::Cmp(cc, w, imm) => {
                let a = self.read(cur, i, 0, *w);
                let b = match imm {
                    Some(v) => self.f.konst(mask(*v, *w), *w),
                    None => self.read(cur, i, 1, *w),
                };
                let l = self.f.inst(cur, Op::Cmp(*cc, *w), alloc::vec![a, b], &[1]);
                let v = self.f.result(l);
                self.write(cur, i, ri.accs.len() - 1, v);
            }
            Kind::Ovf(op, signed, w) => {
                let a = self.read(cur, i, 0, *w);
                let b = self.read(cur, i, 1, *w);
                let l = self.f.inst(cur, Op::Ovf(*op, *signed, *w), alloc::vec![a, b], &[*w, 1]);
                let r = self.f.insts[l.idx()].res;
                self.write(cur, i, 2, Value(r));
                self.write(cur, i, 3, Value(r + 1));
            }
            Kind::Pure { op, ws, out } => {
                let args = ws.iter().enumerate().map(|(k, &w)| self.read(cur, i, k, w)).collect();
                let l = self.f.inst(cur, op.clone(), args, &[*out]);
                let v = self.f.result(l);
                self.write(cur, i, ws.len(), v);
            }
            Kind::Ext { from, to, sx } => {
                let a = self.read(cur, i, 0, *from);
                let l = self.f.inst(cur, Op::Ext { from: *from, to: *to, sx: *sx }, alloc::vec![a], &[*to]);
                let v = self.f.result(l);
                self.write(cur, i, 1, v);
            }
            Kind::Jmp(t) => return Ok(Flow::End(Term::Jmp(self.edge(*t)))),
            Kind::Br { cmp, neg, t } => {
                let (tt, ff) = (self.edge(*t), self.edge(next()?));
                let (tt, ff) = if *neg { (ff, tt) } else { (tt, ff) };
                return Ok(Flow::End(match cmp {
                    None => Term::Br { cond: self.read(cur, i, 0, 1), t: tt, f: ff },
                    Some((cc, w, imm)) => {
                        let a = self.read(cur, i, 0, *w);
                        let b = match imm {
                            Some(v) => self.f.konst(mask(*v, *w), *w),
                            None => self.read(cur, i, 1, *w),
                        };
                        Term::BrCmp { cc: *cc, w: *w, a, b, t: tt, f: ff }
                    }
                }));
            }
            Kind::Call { target, regs, parts, .. } => {
                let (args, k) = self.call_args(cur, i, *target, regs)?;
                let ws: Vec<u8> = parts.iter().map(|p| if matches!(p.size, 1 | 2 | 4 | 8) { p.size as u8 } else { 8 }).collect();
                let call = Call { target: *target, regs: regs.clone(), parts: parts.clone(), site };
                let ci = self.f.inst(cur, Op::Call(Box::new(call)), args, &ws);
                let results: Vec<Value> = self.f.insts[ci.idx()].results().collect();
                if let Unwind::Pad { pad, .. } = ri.unwind {
                    return Ok(Flow::Ended(self.invoke(cur, i, pad, Some((&results, k)))?));
                }
                for (n, v) in results.into_iter().enumerate() {
                    self.write(cur, i, k + n, v);
                }
            }
            Kind::TailCall { target, regs } => {
                let (args, _) = self.call_args(cur, i, *target, regs)?;
                return Ok(Flow::End(Term::TailCall {
                    call: Box::new(Call { target: *target, regs: regs.clone(), parts: Vec::new(), site: Site::None }),
                    args,
                }));
            }
            Kind::Ret { k, parts } => {
                let vs = (0..parts.len()).map(|n| self.read(cur, i, n, parts[n].size as u8)).collect();
                return Ok(Flow::End(Term::Ret { k: *k, parts: vs }));
            }
            Kind::Arg(r) => {
                if cur != self.entry {
                    return Err(Unsupported("an arg outside the entry"));
                }
                let w = if matches!(r.size, 1 | 2 | 4 | 8) { r.size as u8 } else { 8 };
                let v = self.f.param(self.entry, w);
                self.f.entry_regs.push(*r);
                self.write(cur, i, 0, v);
            }
            Kind::Island { isl } => {
                let mut refs = Vec::with_capacity(ri.accs.len());
                for k in 0..ri.accs.len() {
                    // A zero-sized operand: any frame address (it is never accessed).
                    let r = if ri.accs[k].size == 0 { Some(SlotRef::Scratch(0)) } else { self.slot_ref(i, k) };
                    refs.push(r.ok_or(Unsupported("a promoted island operand"))?);
                }
                let isl = Island { isl: CallTarget::Sym(*isl), ops: refs, site };
                self.f.inst(cur, Op::Island(Box::new(isl)), Vec::new(), &[]);
                if let Unwind::Pad { pad, .. } = ri.unwind {
                    return Ok(Flow::Ended(self.invoke(cur, i, pad, Some((&[], 0)))?));
                }
            }
            Kind::Handler { h, then: Then::Next, .. } if let Some((op, w)) = native_bin(*h) => {
                // `d, a, b`: a native operation (fixed registers, not a call).
                let a = self.read(cur, i, 1, w);
                let b = if matches!(op, BinOp::Rotl | BinOp::Rotr) && w != 4 {
                    // A rotate's amount is 4 bytes, extended or truncated to the width:
                    // only its low bits count.
                    let b = self.read(cur, i, 2, 4);
                    let l = self.f.inst(cur, Op::Ext { from: 4, to: w, sx: false }, alloc::vec![b], &[w]);
                    self.f.result(l)
                } else {
                    self.read(cur, i, 2, w)
                };
                let l = self.f.inst(cur, Op::Bin(op, w), alloc::vec![a, b], &[w]);
                let v = self.f.result(l);
                self.write(cur, i, 0, v);
            }
            Kind::Handler { h, then: Then::Next, .. } if let Some(op) = super::decode::vector_op(*h) => {
                // `d` and its operands: a native vector operation.
                let ws: &[u8] = match &op {
                    Op::V(o) => o.widths().0,
                    _ => &[16, 16],
                };
                let args = ws.iter().enumerate().map(|(k, &w)| self.read(cur, i, k + 1, w)).collect();
                let rw = match &op {
                    Op::V(o) => o.widths().1,
                    _ => 16,
                };
                let l = self.f.inst(cur, op, args, &[rw]);
                let v = self.f.result(l);
                self.write(cur, i, 0, v);
            }
            // A dense switch's index computed in place of its handler call.
            Kind::Handler { h, args, then: Then::Table(ts), .. } if let Some((w, base, n)) = dense_switch(*h, args, self.mode) => {
                let v = self.read(cur, i, 0, w);
                let l = self.f.inst(cur, Op::SwitchIdx { w, base, n }, alloc::vec![v], &[8]);
                let idx = self.f.result(l);
                let targets = ts.iter().map(|&t| self.edge(t)).collect();
                return Ok(Flow::End(Term::Switch { idx, targets }));
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
                let reg = super::effects::reg_entry(*h, self.mode).is_some() && (0..slots.len()).all(|k| self.slot_ref(i, k).is_none());
                for (k, &(reg, half)) in slots.iter().enumerate() {
                    let a = ri.accs[k];
                    let r = match self.slot_ref(i, k) {
                        Some(r) => r,
                        None => {
                            let at = sc;
                            sc += 8;
                            if matches!(a.how, super::decode::How::Read | super::decode::How::Update) {
                                in_vals.push(self.read(cur, i, k, a.size as u8));
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
                    self.scratch = self.scratch.max(sc);
                }
                let ret = matches!(then, Then::Branch { .. } | Then::Table(_));
                let mut ws = out_ws.clone();
                match then {
                    Then::Branch { .. } => ws.push(1),
                    Then::Table(_) => ws.push(8),
                    _ => {}
                }
                let hc = HCall { h: *h, regs, ins, outs, nout: out_ws.len() as u8, ret, reg, site };
                let hi = self.f.inst(cur, Op::HCall(Box::new(hc)), in_vals, &ws);
                let results: Vec<Value> = self.f.insts[hi.idx()].results().collect();
                for (n, &k) in out_acc.iter().enumerate() {
                    self.write(cur, i, k, results[n]);
                }
                match then {
                    Then::Next => {}
                    Then::Branch { neg, t } => {
                        let (tt, ff) = (self.edge(*t), self.edge(next()?));
                        let (tt, ff) = if *neg { (ff, tt) } else { (tt, ff) };
                        return Ok(Flow::End(Term::Br { cond: *results.last().unwrap(), t: tt, f: ff }));
                    }
                    Then::Table(ts) => {
                        let targets = ts.iter().map(|&t| self.edge(t)).collect();
                        return Ok(Flow::End(Term::Switch { idx: *results.last().unwrap(), targets }));
                    }
                    Then::Trap => {
                        if let Unwind::Pad { pad, .. } = ri.unwind {
                            return Ok(Flow::Ended(self.invoke(cur, i, pad, None)?));
                        }
                        return Ok(Flow::End(Term::Trap));
                    }
                }
            }
            Kind::Unreachable => return Ok(Flow::End(Term::Trap)),
            Kind::Lpad => return Err(Unsupported("an lpad in a block")),
        }
        Ok(Flow::Next)
    }

    /// The edges' arguments, from the operand rows.
    fn write_edge_args(&mut self) {
        for b in 0..self.f.blocks.len() {
            let params = self.f.blocks[b].params.clone();
            if params.is_empty() {
                continue;
            }
            let preds = self.f.blocks[b].preds.clone();
            for (j, &(p, k)) in preds.iter().enumerate() {
                let args: Vec<Value> = params
                    .iter()
                    .map(|&x| match self.phis.get(x.idx()) {
                        Some(Some(phi)) => phi.row[j],
                        // An entry argument.
                        _ => x,
                    })
                    .collect();
                let mut t = core::mem::replace(&mut self.f.blocks[p.idx()].term, Term::None);
                t.edge_mut(k as usize).args = args;
                self.f.blocks[p.idx()].term = t;
            }
        }
    }
}

/// The IR of `code` with frame `fr`, before the optimizations ([`super::opt::run`]).
pub fn build(code: &Code, fr: &Frame, frame_size: u32, mode: crate::asm::Mode) -> Result<Func, Unsupported> {
    let mut s = B::new(code, fr, frame_size, mode)?;
    s.layout_blocks()?;
    for rb in 0..code.blocks.len() {
        if let Some(cur) = s.ir[rb] {
            s.lower_block(rb, cur)?;
        }
    }
    // Parameters left incomplete belong to blocks never sealed: unreachable ones.
    for b in 0..s.f.blocks.len() {
        if !s.blocks[b].sealed {
            s.seal(Block(b as u32));
        }
    }
    s.write_edge_args();
    s.f.resolve_aliases();
    s.f.scratch = s.scratch;
    s.f.layout = s.layout;
    Ok(s.f)
}

/// The instruction index after `i`.
fn s_next(code: &Code, i: usize) -> Result<u32, Unsupported> {
    if i + 1 < code.insns.len() { Ok(i as u32 + 1) } else { Err(Unsupported("falls off the end")) }
}

/// For a `switch.dense.w8`-`w64` handler call, its width, base and case count (from the
/// arguments its layout gives them in), as [`Op::SwitchIdx`] takes them.
fn dense_switch(h: crate::full::Opcode, args: &[Arg], mode: crate::asm::Mode) -> Option<(u8, u64, u32)> {
    use crate::full::Opcode as O;
    let w = match h {
        O::SwitchDenseW8 => 1,
        O::SwitchDenseW16 => 2,
        O::SwitchDenseW32 => 4,
        O::SwitchDenseW64 => 8,
        _ => return None,
    };
    let l = crate::asm::layout(h, mode);
    let arg = |name: &str| match args.get(l.locs[h.info().operand_index(name)?].reg as usize) {
        Some(Arg::Imm(v)) => Some(*v),
        _ => None,
    };
    Some((w, arg("base")?, u32::try_from(arg("table")?).ok().filter(|&n| n < 1 << 31)?))
}

/// The handlers that are native binary operations in the SSA tier: shifts and rotates by a
/// variable, division and remainder (`d, a, b`, all of width `w` but a rotate's 4-byte `b`).
fn native_bin(h: crate::full::Opcode) -> Option<(BinOp, u8)> {
    let segs: Vec<&str> = h.mnemonic().split('.').collect();
    let (op, w) = match segs[..] {
        ["shl", w] => (BinOp::Shl, w),
        ["shr", "s", w] => (BinOp::ShrS, w),
        ["shr", "u", w] => (BinOp::ShrU, w),
        ["rotl", w] => (BinOp::Rotl, w),
        ["rotr", w] => (BinOp::Rotr, w),
        ["div", "s", w] => (BinOp::DivS, w),
        ["div", "u", w] => (BinOp::DivU, w),
        ["rem", "s", w] => (BinOp::RemS, w),
        ["rem", "u", w] => (BinOp::RemU, w),
        _ => return None,
    };
    let w = match w {
        "w8" => 1,
        "w16" => 2,
        "w32" => 4,
        "w64" => 8,
        _ => return None,
    };
    Some((op, w))
}
