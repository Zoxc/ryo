//! The SSA tier's front end (`ryo_bytecode::jit`): hand-written functions encoded, decoded
//! back to the reduced set as the JIT reads them, and built into the SSA IR, which must
//! verify; with checks of the frame's allocas, promotion, block parameters and OSR loads.

use ryo_bytecode::asm::{self, ArgReg, Decoded, Mode, Scope, ScopeKind};
use ryo_bytecode::full::*;
use ryo_bytecode::jit::ir::{AllocaKind, BlockKind, Op, Term};

const MODE: Mode = Mode { fp_arg: true, frame_pointer: false, align_loops: true, pe: false, counters: true };

/// Encodes `insns` (targets as instruction indices, converted here) with frame `frame` and
/// decodes the machine code back to the reduced set.
fn decoded(insns: &[Insn<'_>], frame: u32, scopes: &[(usize, i32, u32, ScopeKind)]) -> Decoded {
    decoded_with_pads(insns, frame, scopes, &[])
}

/// [`decoded`], with cleanup entries: (call, landing pad), instruction indices.
fn decoded_with_pads(insns: &[Insn<'_>], frame: u32, scopes: &[(usize, i32, u32, ScopeKind)], pads: &[(usize, usize)]) -> Decoded {
    let mut words = Vec::new();
    let mut starts = Vec::new();
    for i in insns {
        starts.push(words.len() as u32);
        i.encode(&mut words);
    }
    // Targets were given as instruction indices: make them word offsets, relative.
    for (k, i) in insns.iter().enumerate() {
        let op = i.opcode();
        for (n, o) in op.info().operands.iter().enumerate() {
            if o.kind == OperandKind::Target {
                let at = starts[k] as usize + op.info().operand_offset(n).unwrap();
                let t = words[at] as usize;
                words[at] = starts[t].wrapping_sub(starts[k]);
            }
        }
    }
    let scopes: Vec<Scope> = scopes
        .iter()
        .map(|&(i, off, size, kind)| Scope { code_offset: starts.get(i).copied().unwrap_or(words.len() as u32), frame_offset: off, size, kind })
        .collect();
    let cleanup: Vec<ryo_bytecode::image::CleanupEntry> =
        pads.iter().map(|&(c, p)| ryo_bytecode::image::CleanupEntry { offset: starts[c], target: starts[p] }).collect();
    let enc = asm::encode(&words, frame, &cleanup, &scopes, MODE).expect("encodes");
    asm::decode_reduced(&enc.code, &enc.relocs, &enc.rodata, &enc.call_sites, &enc.dropped, &enc.scopes, MODE).expect("decodes")
}

fn ir(d: &Decoded) -> ryo_bytecode::jit::ir::Func {
    let mode = Mode { counters: false, ..MODE };
    let f = ryo_bytecode::jit::ir_of(d, mode).unwrap_or_else(|e| panic!("{e:?}"));
    if let Err(e) = f.verify() {
        panic!("{e}\n{f}");
    }
    f
}

fn arg(d: i32, i: u32) -> Insn<'static> {
    Insn::Arg { d: Slot(d), r: ArgReg { xmm: false, size: 8, index: i }.word() }
}

#[test]
fn arguments_promoted() {
    let mut v = vec![arg(-8, 0), arg(-16, 1)];
    for i in 0..2 {
        v.push(Insn::Arg { d: Slot(-24 - 8 * i), r: ArgReg { xmm: true, size: 8, index: i as u32 }.word() });
    }
    v.push(Insn::AddW64 { d: Slot(-48), a: Slot(-8), b: Slot(-16) });
    v.push(Insn::AddW64 { d: Slot(-48), a: Slot(-48), b: Slot(-24) });
    v.push(Insn::Ret { s: Slot(-48), k: 8 });
    let f = ir(&decoded(&v, 48, &[]));
    assert!(f.allocas.iter().all(|a| a.kind == AllocaKind::Promoted), "{f}");
    assert_eq!(f.blocks[0].params.len(), 4);
}

const T: Neg = Neg(false);
const F: Neg = Neg(true);

/// sum(n) = 0 + 1 + … + (n - 1): the loop variables become the head's parameters, and the
/// head (a cyclic one) gets an OSR entry that loads exactly what the loop reads.
#[test]
fn loop_parameters_and_osr_loads() {
    let v = vec![
        arg(-24, 0),
        Insn::ImmW64 { d: Slot(-8), imm: 0 },
        Insn::ImmW64 { d: Slot(-16), imm: 0 },
        // 3: the head.
        Insn::BrLtUW64 { a: Slot(-8), b: Slot(-24), neg: F, t: Target(7) },
        Insn::AddW64 { d: Slot(-16), a: Slot(-16), b: Slot(-8) },
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 },
        Insn::Jmp { t: Target(3) },
        Insn::Ret { s: Slot(-16), k: 8 },
    ];
    let f = ir(&decoded(&v, 32, &[]));
    assert!(f.allocas.iter().all(|a| a.kind == AllocaKind::Promoted), "{f}");
    let o = f.osr.iter().flatten().next().copied().expect("an OSR entry");
    let loads: Vec<_> = f.blocks[o.idx()].insts.iter().map(|i| f.insts[i.idx()].op.clone()).collect();
    assert_eq!(loads.len(), 3, "{f}");
    assert!(loads.iter().all(|op| matches!(op, Op::OsrLoad(_, 8))), "{f}");
    let Term::Jmp(e) = &f.blocks[o.idx()].term else { panic!("{f}") };
    assert_eq!(f.blocks[e.to.idx()].params.len(), 3, "{f}");
}

/// A slot reused at another width splits into two variables; one read whose bytes two
/// shapes wrote keeps the alloca in memory.
#[test]
fn reaching_shapes() {
    let v = vec![
        arg(-8, 0),
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 },
        Insn::MovW64 { d: Slot(-24), s: Slot(-8) },
        Insn::ImmW8 { d: Slot(-8), imm: 3 },
        Insn::AddW8 { d: Slot(-16), a: Slot(-8), b: Slot(-8) },
        Insn::Ret { s: Slot(-24), k: 8 },
    ];
    let f = ir(&decoded(&v, 32, &[]));
    assert!(f.allocas.iter().all(|a| a.kind == AllocaKind::Promoted), "{f}");
    let v = vec![
        arg(-8, 0),
        Insn::BrEqImmW64 { a: Slot(-8), imm: 0, neg: T, t: Target(3) },
        Insn::ImmW8 { d: Slot(-8), imm: 3 },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let f = ir(&decoded(&v, 16, &[]));
    assert_eq!(f.allocas[0].kind, AllocaKind::Memory, "{f}");
}

/// A local whose address escapes before a loop is memory, and pinned to its AOT offset (it
/// is escaped at the OSR entry); one that escapes only after the loop moves.
#[test]
fn escapes_pin_at_heads() {
    let v = vec![
        arg(-8, 0),
        Insn::ImmW64 { d: Slot(-16), imm: 5 },
        Insn::Addr { d: Slot(-24), s: Slot(-16) },
        // 3: the head.
        Insn::BrEqImmW64 { a: Slot(-8), imm: 0, neg: T, t: Target(8) },
        Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-24), k: 0 } },
        Insn::AddImmW64 { d: Slot(-32), a: Slot(-32), imm: 1 },
        Insn::StoreW64 { m: Mem { p: Slot(-24), k: 0 }, s: Slot(-32) },
        Insn::SubImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 },
        // 8:
        Insn::Addr { d: Slot(-48), s: Slot(-40) },
        Insn::Ret { s: Slot(-16), k: 8 },
    ];
    // Instruction 7 falls through to 8: make the loop jump back.
    let mut v = v;
    v.insert(8, Insn::Jmp { t: Target(3) });
    let v: Vec<Insn> = v
        .into_iter()
        .map(|i| match i {
            Insn::BrEqImmW64 { a, imm, neg, t: Target(8) } => Insn::BrEqImmW64 { a, imm, neg, t: Target(9) },
            i => i,
        })
        .collect();
    let d = decoded(&v, 48, &[(2, -16, 8, ScopeKind::Escape { align: 8 }), (9, -40, 8, ScopeKind::Escape { align: 8 })]);
    let f = ir(&d);
    let a16 = f.allocas.iter().find(|a| a.aot_off == -16).unwrap();
    assert!(a16.kind == AllocaKind::Memory && a16.pinned, "{f}");
    let a40 = f.allocas.iter().find(|a| a.aot_off == -40).unwrap();
    assert!(a40.kind == AllocaKind::Memory && !a40.pinned, "{f}");
    assert!(f.blocks.iter().any(|b| matches!(b.kind, BlockKind::Osr(_))));
}

/// A handler's slot operands sharing a register (two 32-bit halves): each is patched to
/// its own scratch slot, or (here) the call goes through the register entry.
#[test]
fn handler_shared_register_slots() {
    let v =
        vec![arg(-16, 0), Insn::CtpopW64 { d: Slot(-20), a: Slot(-16) }, Insn::MovW32 { d: Slot(-4), s: Slot(-20) }, Insn::Ret { s: Slot(-4), k: 4 }];
    let f = ir(&decoded(&v, 32, &[]));
    assert!(f.allocas.iter().all(|a| a.kind == AllocaKind::Promoted), "{f}");
    let h = f.insts.iter().find_map(|i| if let Op::HCall(h) = &i.op { Some(h.clone()) } else { None }).expect("an hcall");
    // Through the register entry: no scratch slots.
    assert!(h.reg && h.ins.is_empty() && h.outs.is_empty() && h.nout == 1, "{f}");
    let Term::Ret { parts, .. } = &f.blocks[0].term else { panic!("{f}") };
    assert_eq!(parts.len(), 1);
}

/// A stack argument read only after a call with a landing pad that ends the entry block,
/// on both paths: its load is at the entry's top, before the call.
#[test]
fn incoming_loads_before_the_entry_call() {
    let v = vec![
        Insn::Call { d: Slot(-8), f: Func(0), k: 8, a: List::from_words(&[]) },
        // 1: the normal path.
        Insn::AddW64 { d: Slot(-8), a: Slot(-8), b: Slot(16) },
        Insn::Ret { s: Slot(-8), k: 8 },
        // 3: the landing pad.
        Insn::Lpad { x: Slot(-16) },
        Insn::StoreW64 { m: Mem { p: Slot(16), k: 0 }, s: Slot(-16) },
        Insn::Resume { x: Slot(-16) },
    ];
    let f = ir(&decoded_with_pads(&v, 16, &[], &[(0, 3)]));
    let entry = &f.blocks[0];
    assert!(matches!(entry.term, Term::Invoke { .. }), "{f}");
    assert!(matches!(f.insts[entry.insts[0].idx()].op, Op::ALoad(..)), "{f}");
}

/// Local value numbering: arithmetic on constants folds, a second load of the same pointer
/// is the first's value, a load after a store through the same pointer is the stored value,
/// and a store through another pointer forgets both.
#[test]
fn value_numbering() {
    let v = vec![
        Insn::ImmW64 { d: Slot(-8), imm: 3 },
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 4 },
        Insn::MulW64 { d: Slot(-8), a: Slot(-8), b: Slot(-8) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let f = ir(&decoded(&v, 16, &[]));
    assert!(f.blocks.iter().all(|b| b.insts.is_empty()), "{f}");
    let Term::Ret { parts, .. } = &f.blocks[0].term else { panic!("{f}") };
    assert_eq!(f.def(parts[0]), ryo_bytecode::jit::ir::ValueDef::Const(49), "{f}");

    let v = vec![
        arg(-8, 0),
        arg(-16, 1),
        Insn::LoadW64 { d: Slot(-24), m: Mem { p: Slot(-8), k: 8 } },
        Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-8), k: 8 } },
        Insn::AddW64 { d: Slot(-24), a: Slot(-24), b: Slot(-32) },
        Insn::StoreW64 { m: Mem { p: Slot(-8), k: 0 }, s: Slot(-24) },
        Insn::LoadW64 { d: Slot(-32), m: Mem { p: Slot(-8), k: 0 } },
        Insn::LoadW64 { d: Slot(-40), m: Mem { p: Slot(-8), k: 8 } },
        Insn::StoreW64 { m: Mem { p: Slot(-16), k: 0 }, s: Slot(-32) },
        Insn::LoadW64 { d: Slot(-48), m: Mem { p: Slot(-8), k: 8 } },
        Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-40) },
        Insn::AddW64 { d: Slot(-32), a: Slot(-32), b: Slot(-48) },
        Insn::Ret { s: Slot(-32), k: 8 },
    ];
    let f = ir(&decoded(&v, 48, &[]));
    let loads = f.blocks[0].insts.iter().filter(|i| matches!(f.insts[i.idx()].op, Op::Load(..))).count();
    assert_eq!(loads, 2, "{f}");
}
