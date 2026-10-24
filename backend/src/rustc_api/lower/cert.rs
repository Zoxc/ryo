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

use std::fmt::Write as _;

use rustc_middle::mir::{Local, UnwindTerminateReason};
use ryo_bytecode::asm::InsnId;

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
}

/// The certificate being recorded for one function.
#[derive(Default)]
pub struct Recorder {
    prologue: Range,
    blocks: Vec<BlockCert>,
    /// Terminate stubs: the reason, the range.
    stubs: Vec<(UnwindTerminateReason, Range)>,
    /// Landing pads: the range, the MIR block they continue at (`None`: a terminate stub).
    pads: Vec<(Range, Option<u32>)>,
    /// Call instructions: id, kind, the callee's plan, its return kind and return value size.
    calls: Vec<(u32, CallKind, Option<ArgPlan>, u32, u64)>,
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

    /// Starts a block (blocks are lowered in index order).
    pub fn cert_block(&mut self, fused: bool) {
        if let Some(c) = &mut self.cert {
            c.blocks.push(BlockCert { fused, ..BlockCert::default() });
        }
    }

    /// Records the statement lowered from `start` on.
    pub fn cert_stmt(&mut self, start: u32) {
        let n = self.next_insn();
        if let Some(c) = &mut self.cert {
            c.blocks.last_mut().expect("a block").stmts.push((start, n));
        }
    }

    /// Records the terminator lowered from `start` on.
    pub fn cert_term(&mut self, start: u32) {
        let n = self.next_insn();
        if let Some(c) = &mut self.cert {
            c.blocks.last_mut().expect("a block").term = (start, n);
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
            c.pads.push(((start, n), block));
        }
    }

    /// Records the call instruction `at`, of `kind`, passing its arguments as `plan` says
    /// and returning a value of `ret_size` bytes as `ret_kind` says.
    pub fn cert_call(&mut self, at: InsnId, kind: CallKind, plan: Option<&ArgPlan>, ret_kind: u32, ret_size: u64) {
        if let Some(c) = &mut self.cert {
            c.calls.push((at.0, kind, plan.cloned(), ret_kind, ret_size));
        }
    }

    /// The certificate as a JSON object, once the frame size `frame_size` is known.
    pub fn cert_json(&self, frame_size: u32, plan: Option<&ArgPlan>) -> Option<String> {
        let c = self.cert.as_deref()?;
        let off = |s: u32| frame_offset(s, frame_size);
        let mut o = String::new();
        let range = |o: &mut String, r: Range| {
            let _ = write!(o, "[{},{}]", r.0, r.1);
        };
        let _ =
            write!(o, "{{\"frameSize\":{frame_size},\"outgoing\":{},\"argSize\":{},\"retKind\":{}", self.max_outgoing, self.arg_size, self.ret_kind);
        // The frame map.
        o.push_str(",\"locals\":[");
        for (i, l) in self.frame.locals.iter().enumerate() {
            let sep = if i > 0 { "," } else { "" };
            let _ = write!(o, "{sep}{{\"off\":{},\"size\":{}}}", off(l.off), l.layout.size.bytes());
        }
        let (locals_end, high) = self.frame.extent();
        let _ = write!(o, "],\"localsEnd\":{locals_end},\"tempsEnd\":{high}");
        let opt = |v: Option<u32>| v.map_or("null".to_owned(), |s| off(s).to_string());
        let _ = write!(o, ",\"exception\":{},\"sret\":{}", opt(self.frame.exception), opt(self.frame.sret));
        let list = |xs: &mut dyn Iterator<Item = String>| xs.collect::<Vec<_>>().join(",");
        let _ = write!(o, ",\"argHomes\":[{}]", list(&mut self.frame.arg_homes.iter().map(|&s| off(s).to_string())));
        let _ = write!(o, ",\"argPtrs\":[{}]", list(&mut self.frame.arg_ptrs.iter().map(|&s| opt(s))));
        let _ = write!(o, ",\"callerLocation\":{}", opt(self.caller_location));
        let _ = write!(o, ",\"spreadArg\":{}", self.body.spread_arg.map_or("null".to_owned(), |l: Local| l.as_usize().to_string()));
        o.push_str(",\"plan\":");
        plan_json(&mut o, plan);
        // The instruction ranges.
        o.push_str(",\"prologue\":");
        range(&mut o, c.prologue);
        o.push_str(",\"blocks\":[");
        for (i, b) in c.blocks.iter().enumerate() {
            o.push_str(if i > 0 { ",{\"stmts\":[" } else { "{\"stmts\":[" });
            for (j, &r) in b.stmts.iter().enumerate() {
                if j > 0 {
                    o.push(',');
                }
                range(&mut o, r);
            }
            o.push_str("],\"term\":");
            range(&mut o, b.term);
            let _ = write!(o, ",\"fused\":{}}}", b.fused);
        }
        o.push_str("],\"stubs\":[");
        for (i, &(reason, r)) in c.stubs.iter().enumerate() {
            let sep = if i > 0 { "," } else { "" };
            let _ = write!(o, "{sep}{{\"reason\":\"{}\",\"insns\":", terminate_reason(reason));
            range(&mut o, r);
            o.push('}');
        }
        o.push_str("],\"pads\":[");
        for (i, &(r, bb)) in c.pads.iter().enumerate() {
            let sep = if i > 0 { "," } else { "" };
            let _ = write!(o, "{sep}{{\"insns\":");
            range(&mut o, r);
            let _ = write!(o, ",\"block\":{}}}", bb.map_or("null".to_owned(), |b| b.to_string()));
        }
        o.push_str("],\"calls\":[");
        for (i, (at, kind, plan, k, size)) in c.calls.iter().enumerate() {
            let sep = if i > 0 { "," } else { "" };
            let _ = write!(o, "{sep}{{\"insn\":{at},\"kind\":\"{}\",\"retKind\":{k},\"retSize\":{size},\"plan\":", kind.name());
            plan_json(&mut o, plan.as_ref());
            o.push('}');
        }
        o.push_str("]}");
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
fn plan_json(o: &mut String, plan: Option<&ArgPlan>) {
    let Some(p) = plan else {
        o.push_str("null");
        return;
    };
    let _ = write!(o, "{{\"stackSize\":{},\"locs\":[", p.stack_size);
    for (i, locs) in p.locs.iter().enumerate() {
        o.push_str(if i > 0 { ",[" } else { "[" });
        for (j, l) in locs.iter().enumerate() {
            if j > 0 {
                o.push(',');
            }
            let _ = match *l {
                ArgLoc::Reg { reg, off } => {
                    write!(o, "{{\"reg\":{{\"xmm\":{},\"size\":{},\"index\":{}}},\"off\":{off}}}", reg.xmm, reg.size, reg.index)
                }
                ArgLoc::Stack { at, off, size } => write!(o, "{{\"stack\":{at},\"off\":{off},\"size\":{size}}}"),
                ArgLoc::PtrReg(i) => write!(o, "{{\"ptrReg\":{i}}}"),
                ArgLoc::PtrStack(at) => write!(o, "{{\"ptrStack\":{at}}}"),
            };
        }
        o.push(']');
    }
    o.push_str("]}");
}
