//! The lowering's certificate for the Lean lowering check C1' (lean/docs/aot.md §C1),
//! recorded while lowering when `RYO_DUMP_LEAN` is set ([`LowerCx::cert`]) and written next
//! to the MIR dump (`dump_lean.rs`).
//!
//! It is untrusted: the Lean side checks what it uses against the decoded code and the dump.
//! Per VM function: its frame map, the instruction ranges each MIR statement and terminator
//! produced (`InsnId`s, which are the indices of the decoded R instructions: one
//! [`Asm::insn`](ryo_bytecode::asm::Asm::insn) is one R instruction), its own [`ArgPlan`],
//! and per call instruction its kind and the callee signature's [`ArgPlan`]. Recording only
//! reads the lowering's state, so the generated code is the same with or without it.
//!
//! [`LowerCx::cert`]: super::LowerCx::cert

use rustc_middle::mir::{Local, UnwindTerminateReason};
use ryo_bytecode::asm::InsnId;

use super::super::json::{J, num, obj, opt, tag};
use super::FnCx;
use super::frame::frame_offset;
use super::sig::{ArgLoc, ArgPlan};

/// What a call instruction calls (`kind` in the JSON).
#[derive(Clone, Copy)]
pub enum CallKind {
    /// `call fn` of a resolved callee.
    Vm,
    /// `call.sym` / `call.sym.ind` of a resolved callee.
    Sym,
    /// `call.ptr`: a fn pointer or a virtual call.
    Ptr,
    /// `call fn` of drop glue.
    DropVm,
    /// `call.ptr` of a vtable's `drop_in_place` entry, with the data pointer.
    VirtualDrop,
    /// `call.sym` of a thread local's shim, without arguments.
    ThreadLocal,
    /// `tail_call fn`.
    TailVm,
    /// `tail_call.ptr`.
    TailPtr,
}

impl CallKind {
    fn name(self) -> &'static str {
        match self {
            CallKind::Vm => "vm",
            CallKind::Sym => "sym",
            CallKind::Ptr => "ptr",
            CallKind::DropVm => "dropVm",
            CallKind::VirtualDrop => "virtualDrop",
            CallKind::ThreadLocal => "threadLocal",
            CallKind::TailVm => "tailVm",
            CallKind::TailPtr => "tailPtr",
        }
    }
}

/// A half-open range of instruction ids.
type Range = (u32, u32);

/// One block's ranges.
#[derive(Default)]
struct BlockCert {
    /// Per statement lowered on its own (the fused compare is lowered with the terminator).
    stmts: Vec<Range>,
    term: Range,
    /// Whether the last statement is a compare fused into the terminator.
    fused: bool,
    /// Unreachable after monomorphization: lowered as a lone `unreachable` (its `term`), with
    /// no statement ranges.
    dead: bool,
}

/// The certificate being recorded for one function.
#[derive(Default)]
pub struct Recorder {
    prologue: Range,
    /// By block index.
    blocks: Vec<BlockCert>,
    /// The block being lowered.
    cur: usize,
    /// Terminate stubs: the reason, the range.
    stubs: Vec<(UnwindTerminateReason, Range)>,
    pads: Vec<PadCert>,
    calls: Vec<CallCert>,
}

/// A landing pad.
struct PadCert {
    insns: Range,
    /// The MIR block it continues at (`None`: a terminate stub).
    block: Option<u32>,
}

/// A call instruction.
struct CallCert {
    insn: u32,
    kind: CallKind,
    /// The callee's argument plan.
    plan: Option<ArgPlan>,
    ret_kind: u32,
    /// The return value's size.
    ret_size: u64,
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// The id the next instruction will get.
    fn next_insn(&self) -> u32 {
        self.insns
    }

    /// Records that the prologue is the instructions so far.
    pub fn cert_prologue(&mut self) {
        let n = self.next_insn();
        if let Some(c) = &mut self.cert {
            c.prologue = (0, n);
        }
    }

    /// Starts block `bb` (blocks are lowered in index order, but on PE the cleanup blocks
    /// last).
    pub fn cert_block(&mut self, bb: usize, fused: bool) {
        if let Some(c) = &mut self.cert {
            if c.blocks.len() <= bb {
                c.blocks.resize_with(bb + 1, BlockCert::default);
            }
            c.blocks[bb] = BlockCert { fused, ..BlockCert::default() };
            c.cur = bb;
        }
    }

    /// Records that the current block is unreachable after monomorphization.
    pub fn cert_dead(&mut self) {
        if let Some(c) = &mut self.cert {
            let b = c.cur;
            c.blocks[b].dead = true;
        }
    }

    /// Records the statement lowered from `start` on.
    pub fn cert_stmt(&mut self, start: u32) {
        let n = self.next_insn();
        if let Some(c) = &mut self.cert {
            let b = c.cur;
            c.blocks[b].stmts.push((start, n));
        }
    }

    /// Records the terminator lowered from `start` on.
    pub fn cert_term(&mut self, start: u32) {
        let n = self.next_insn();
        if let Some(c) = &mut self.cert {
            let b = c.cur;
            c.blocks[b].term = (start, n);
        }
    }

    /// Records the terminate stub lowered from `start` on.
    pub fn cert_stub(&mut self, reason: UnwindTerminateReason, start: u32) {
        let n = self.next_insn();
        if let Some(c) = &mut self.cert {
            c.stubs.push((reason, (start, n)));
        }
    }

    /// Records the landing pad lowered from `start` on, continuing at `block`.
    pub fn cert_pad(&mut self, start: u32, block: Option<u32>) {
        let n = self.next_insn();
        if let Some(c) = &mut self.cert {
            c.pads.push(PadCert { insns: (start, n), block });
        }
    }

    /// Records the call instruction `at`, of `kind`, passing its arguments as `plan` says
    /// and returning a value of `ret_size` bytes as `ret_kind` says.
    pub fn cert_call(&mut self, at: InsnId, kind: CallKind, plan: Option<&ArgPlan>, ret_kind: u32, ret_size: u64) {
        if let Some(c) = &mut self.cert {
            c.calls.push(CallCert { insn: at.0, kind, plan: plan.cloned(), ret_kind, ret_size });
        }
    }

    /// The certificate as a JSON object, once the frame size `frame_size` is known.
    pub fn cert_json(&self, frame_size: u32, plan: Option<&ArgPlan>) -> Option<String> {
        let c = self.cert.as_deref()?;
        let off = |s: u32| num(frame_offset(s, frame_size));
        let opt_off = |v: Option<u32>| opt(v.map(off));
        let range = |r: Range| J::Arr(vec![num(r.0), num(r.1)]);
        let (locals_end, high) = self.frame.extent();
        let locals = self.frame.locals.iter().map(|l| obj(vec![("off", off(l.off)), ("size", num(l.layout.size.bytes()))]));
        let blocks = c.blocks.iter().map(|b| {
            obj(vec![
                ("stmts", J::Arr(b.stmts.iter().map(|&r| range(r)).collect())),
                ("term", range(b.term)),
                ("fused", J::Bool(b.fused)),
                ("dead", J::Bool(b.dead)),
            ])
        });
        let stubs = c.stubs.iter().map(|&(reason, r)| obj(vec![("reason", tag(terminate_reason(reason))), ("insns", range(r))]));
        let pads = c.pads.iter().map(|p| obj(vec![("insns", range(p.insns)), ("block", opt(p.block.map(num)))]));
        let calls = c.calls.iter().map(|c| {
            obj(vec![
                ("insn", num(c.insn)),
                ("kind", tag(c.kind.name())),
                ("retKind", num(c.ret_kind)),
                ("retSize", num(c.ret_size)),
                ("plan", plan_json(c.plan.as_ref())),
            ])
        });
        let j = obj(vec![
            ("frameSize", num(frame_size)),
            ("outgoing", num(self.max_outgoing)),
            ("argSize", num(self.arg_size)),
            ("retKind", num(self.ret_kind)),
            // The frame map.
            ("locals", J::Arr(locals.collect())),
            ("localsEnd", num(locals_end)),
            ("tempsEnd", num(high)),
            ("exception", opt_off(self.frame.exception)),
            ("sret", opt_off(self.frame.sret)),
            ("argHomes", J::Arr(self.frame.arg_homes.iter().map(|&s| off(s)).collect())),
            ("argPtrs", J::Arr(self.frame.arg_ptrs.iter().map(|&s| opt_off(s)).collect())),
            ("callerLocation", opt_off(self.caller_location)),
            ("spreadArg", opt(self.body.spread_arg.map(|l: Local| num(l.as_usize())))),
            ("plan", plan_json(plan)),
            // The instruction ranges.
            ("prologue", range(c.prologue)),
            ("blocks", J::Arr(blocks.collect())),
            ("stubs", J::Arr(stubs.collect())),
            ("pads", J::Arr(pads.collect())),
            ("calls", J::Arr(calls.collect())),
        ]);
        let mut o = String::new();
        j.write(&mut o);
        Some(o)
    }
}

/// `UnwindTerminateReason` as the MIR dump names it.
fn terminate_reason(r: UnwindTerminateReason) -> &'static str {
    match r {
        UnwindTerminateReason::Abi => "abi",
        UnwindTerminateReason::InCleanup => "inCleanup",
    }
}

/// An [`ArgPlan`]: `{"stackSize", "locs"}`, each input's pieces as `{"reg": {xmm, size,
/// index}, "off"}`, `{"stack", "off", "size"}`, `{"ptrReg"}` or `{"ptrStack"}`.
fn plan_json(plan: Option<&ArgPlan>) -> J {
    let Some(p) = plan else { return J::Null };
    let loc = |l: &ArgLoc| match *l {
        ArgLoc::Reg { reg, off } => {
            obj(vec![("reg", obj(vec![("xmm", J::Bool(reg.xmm)), ("size", num(reg.size)), ("index", num(reg.index))])), ("off", num(off))])
        }
        ArgLoc::Stack { at, off, size } => obj(vec![("stack", num(at)), ("off", num(off)), ("size", num(size))]),
        ArgLoc::PtrReg(i) => obj(vec![("ptrReg", num(i))]),
        ArgLoc::PtrStack(at) => obj(vec![("ptrStack", num(at))]),
    };
    let locs = p.locs.iter().map(|locs| J::Arr(locs.iter().map(loc).collect()));
    obj(vec![("stackSize", num(p.stack_size)), ("locs", J::Arr(locs.collect()))])
}
