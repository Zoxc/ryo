//! The exact frame effects of the handlers (design/jit.md, "The SSA tier"): for each operand
//! of a handler that names a frame slot, how many bytes the handler reads or writes there.
//! `asm::frame` over-estimates them (16 bytes, never killing); the SSA tier needs them exact
//! to keep frame slots in registers across handler calls.
//!
//! The table (`effects_table.rs`) is generated from the Lean model's footprints of the
//! handlers (`lean/Ryo/Vm/OpSem/JitEffects.lean`, `ryo-lean effects`; regenerate with
//! `./y.sh lean gen`, which `y lean` checks was done). `vm/rt/tests/ops.rs` checks it against the handlers themselves: each handler run on a
//! frame filled with a pattern writes only the bytes the table says, and depends only on the
//! bytes it says it reads.

use crate::asm::{ARG_REGS, Mode};
use crate::full::{Opcode, OperandKind, Shape};

/// How a handler uses one of its frame operands (`Slot`, or the pointer slot of a `Mem`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Effect {
    /// Reads exactly `n` bytes at the slot.
    Read(u8),
    /// Writes exactly `n` bytes at the slot, whatever was there.
    Write(u8),
    /// May write `n` bytes at the slot, or leave them: a read and a write. No handler has
    /// this effect at the moment.
    Update(u8),
    /// Takes the slot's address (`addr`): the object escapes.
    Addr,
    /// Reads or writes a length the operands give (`copy`, `const`, `zero`, `fill`,
    /// `load.copy`, `store.copy`): its object can't be promoted.
    Block,
}

/// A handler's effects: per operand index, the frame effect of a frame operand (`None` for
/// the others), and whether it reads or writes memory through a pointer, or orders memory
/// accesses (loads, stores, atomics, fences).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Effects {
    pub opnds: [Option<Effect>; crate::asm::MAX_OPERANDS],
    pub memory: bool,
}

/// The effects of `op`'s handler. `None` for opcodes without one. A `const fn`, so that
/// `ryo_rt` generates the register entries from it ([`reg_entry`]).
pub const fn effects(op: Opcode) -> Option<Effects> {
    super::effects_table::TABLE[op as usize]
}

/// An entry of the generated table: `opnds`, padded with `None`.
pub(super) const fn e(opnds: &[Option<Effect>], memory: bool) -> Option<Effects> {
    let mut out = Effects { opnds: [None; crate::asm::MAX_OPERANDS], memory };
    let mut k = 0;
    while k < opnds.len() {
        out.opnds[k] = opnds[k];
        k += 1;
    }
    Some(out)
}

/// A handler's register entry (design/jit.md, "Register entries"): the handler body with its
/// frame operands in registers instead of frame slots, for the SSA tier. Like the frame entry
/// it is `extern "sysv64-unwind" fn(a0, …, a5: u64)`, and it returns `(u64, u64)` in
/// `rax`, `rdx`. It takes, in `rdi`, `rsi`, … in this order:
/// - the values of the frame operands it reads ([`RegEntry::ins`], by operand index, in operand
///   order), each in the low bytes of its register;
/// - then whole the frame entry's argument registers that hold anything but slot offsets
///   ([`RegEntry::data`], by register index from `rdi`, the frame entry's `fp` excluded):
///   immediates, addresses, a `Mem` operand's displacement. Their slot offset halves, if any,
///   are ignored.
///
/// It returns the values of the frame operands it writes ([`RegEntry::outs`], in operand
/// order), then with [`RegEntry::ret`] the frame entry's return value (`br`, `switch`), in
/// `rax`, then `rdx`: a value's low bytes, the rest unspecified. It takes no `fp`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct RegEntry {
    pub ins: [u8; ARG_REGS],
    pub nin: u8,
    pub data: [u8; ARG_REGS],
    pub ndata: u8,
    pub outs: [u8; 2],
    pub nout: u8,
    pub ret: bool,
}

impl RegEntry {
    /// No register entry.
    pub const NONE: RegEntry = RegEntry { ins: [0; ARG_REGS], nin: 0, data: [0; ARG_REGS], ndata: 0, outs: [0; 2], nout: 0, ret: false };
}

/// The handlers that write `xmm6`–`xmm15`, callee-saved on Win64 but not in `sysv64` code:
/// their `i128` result stays in `xmm6` across a call. The lowering calls the `as_cast` island
/// instead on PE, and the SSA tier doesn't compile them there; `vm/rt/tests/codegen.rs`
/// checks that no other handler (or register entry) writes those registers.
pub const PE_XMM_CLOBBERS: [Opcode; 4] = [Opcode::CvtF2iSatSF32W128, Opcode::CvtF2iSatUF32W128, Opcode::CvtF2iSatSF64W128, Opcode::CvtF2iSatUF64W128];

/// `op`'s register entry in `mode` (whose register layout gives the data registers), if it
/// has one: a handler that returns (`op`, `br` and `switch` shapes; not `resume`), whose frame
/// operands are all read, written or updated at 1 to 8 bytes (no `addr`, no blocks, no
/// `w128`), whose inputs and data registers fit the six argument registers and whose outputs
/// and return value fit `rax` and `rdx`. Others keep only their frame entry.
pub const fn reg_entry(op: Opcode, mode: Mode) -> Option<RegEntry> {
    let info = op.info();
    if !matches!(info.shape, Shape::Op | Shape::Br | Shape::Switch) || matches!(op, Opcode::Resume) {
        return None;
    }
    let Some(e) = effects(op) else { return None };
    let l = crate::asm::layout(op, mode);
    let mut r = RegEntry::NONE;
    r.ret = !matches!(info.shape, Shape::Op);
    let mut data = [false; ARG_REGS];
    let mut nout = r.ret as usize;
    let mut k = 0;
    while k < info.operands.len() {
        let o = info.operands[k];
        let loc = l.locs[k];
        let (reads, writes) = match (o.kind, e.opnds[k]) {
            (OperandKind::Slot | OperandKind::Mem, Some(Effect::Read(n))) if n <= 8 => (true, false),
            (OperandKind::Slot | OperandKind::Mem, Some(Effect::Write(n))) if n <= 8 => (false, true),
            (OperandKind::Slot | OperandKind::Mem, Some(Effect::Update(n))) if n <= 8 => (true, true),
            (OperandKind::Slot | OperandKind::Mem, _) => return None,
            _ => (false, false),
        };
        if reads {
            if r.nin as usize == ARG_REGS {
                return None;
            }
            r.ins[r.nin as usize] = k as u8;
            r.nin += 1;
        }
        if writes {
            if nout == 2 {
                return None;
            }
            r.outs[r.nout as usize] = k as u8;
            r.nout += 1;
            nout += 1;
        }
        // The registers holding anything but a slot offset: a `Mem` operand's displacement
        // register, every register of the other operands.
        let mut p = 0;
        while p < loc.count {
            if !matches!(o.kind, OperandKind::Slot) && !(matches!(o.kind, OperandKind::Mem) && p == 0) {
                data[(loc.reg + p) as usize] = true;
            }
            p += 1;
        }
        k += 1;
    }
    let mut g = 0;
    while g < ARG_REGS {
        if data[g] {
            if (r.nin + r.ndata) as usize == ARG_REGS {
                return None;
            }
            r.data[r.ndata as usize] = g as u8;
            r.ndata += 1;
        }
        g += 1;
    }
    Some(r)
}
