//! The SSA tier's front end (`ryo_bytecode::jit`): hand-written functions encoded, decoded
//! back to the reduced set as the JIT reads them, and built into the SSA IR, which must
//! verify; with checks of the frame's allocas, promotion, block parameters and OSR loads.

use ryo_bytecode::asm::{self, ArgReg, Decoded, Mode, Scope, ScopeKind};
use ryo_bytecode::full::*;
use ryo_bytecode::jit::ir::{AllocaKind, BlockKind, Edge, Func as IrFunc, Op, Term, ValueDef};

const MODE: Mode = Mode { fp_arg: true, frame_pointer: false, align_loops: true, pe: false, counters: true, far_rt: false };

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
    let f = ryo_bytecode::jit::ir_of(d, mode, None).unwrap_or_else(|e| panic!("{e:?}"));
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
    assert_eq!(f.def(parts[0]), ValueDef::Const(49), "{f}");

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

/// A block that ends in `unreachable` after calls is cold: laid out after the hot ones, and
/// the hot values it uses across its calls come in as its parameters, so that the linear
/// scan keeps them in caller-saved registers and saves no callee-saved one.
#[test]
fn cold_blocks_last() {
    let r = |s: i32| [s as u32, ArgReg { xmm: false, size: 8, index: 0 }.word()];
    let (a1, a2) = (r(-8), r(-40));
    let v = vec![
        arg(-8, 0),
        arg(-16, 1),
        arg(-24, 2),
        Insn::BrLtUW64 { a: Slot(-8), b: Slot(-16), neg: F, t: Target(7) },
        // 4: the hot path.
        Insn::AddW64 { d: Slot(-32), a: Slot(-8), b: Slot(-24) },
        Insn::Ret { s: Slot(-32), k: 8 },
        Insn::Ret { s: Slot(-32), k: 8 },
        // 7: cold.
        Insn::Call { d: Slot(-40), f: Func(0), k: 8, a: List::from_words(&a1) },
        Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-16) },
        Insn::AddW64 { d: Slot(-40), a: Slot(-40), b: Slot(-24) },
        Insn::Call { d: Slot(-48), f: Func(0), k: 8, a: List::from_words(&a2) },
        Insn::Unreachable {},
    ];
    let f = ir(&decoded(&v, 48, &[]));
    let last = *f.layout.last().unwrap();
    let lb = &f.blocks[last.idx()];
    assert!(lb.cold && matches!(lb.term, Term::Trap), "{f}");
    assert_eq!(f.layout[0].idx(), 0, "{f}");
    assert!(f.layout.iter().filter(|b| f.blocks[b.idx()].cold).count() == 1, "{f}");
    // y and z cross the first call.
    assert_eq!(lb.params.len(), 2, "{f}");
    let uses = ryo_bytecode::jit::regalloc::use_counts(&f);
    let al = ryo_bytecode::jit::regalloc::linear_scan(&f, &uses, false);
    ryo_bytecode::jit::regalloc::check(&f, &al, false).unwrap();
    assert!(al.saved.is_empty(), "{al:?}\n{f}");
}

/// Constant propagation over a loop head's parameters, ignoring the OSR entry's: `k` is 5
/// on every normal path into the head, so the branch on it folds, the code it skips goes, and
/// the OSR entry stops loading it.
#[test]
fn osr_transparent_constants() {
    let v = vec![
        arg(-24, 0),
        Insn::ImmW64 { d: Slot(-8), imm: 0 },
        Insn::ImmW64 { d: Slot(-32), imm: 5 },
        // 3: the head.
        Insn::BrLtUW64 { a: Slot(-8), b: Slot(-24), neg: F, t: Target(9) },
        Insn::BrEqImmW64 { a: Slot(-32), imm: 5, neg: T, t: Target(6) },
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 100 },
        // 6:
        Insn::ImmW64 { d: Slot(-32), imm: 5 },
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 },
        Insn::Jmp { t: Target(3) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let f = ir(&decoded(&v, 32, &[]));
    let o = f.osr.iter().flatten().next().copied().expect("an OSR entry");
    assert_eq!(f.blocks[o.idx()].insts.len(), 2, "{f}");
    let live = |b: &ryo_bytecode::jit::ir::Block| f.blocks[b.idx()].insts.iter().map(|i| f.insts[i.idx()].op.clone()).collect::<Vec<_>>();
    let ops: Vec<Op> = f.layout.iter().flat_map(live).collect();
    assert_eq!(ops.iter().filter(|o| matches!(o, Op::Bin(..))).count(), 1, "{f}");
    let branches = f.layout.iter().filter(|b| matches!(f.blocks[b.idx()].term, Term::Br { .. } | Term::BrCmp { .. })).count();
    assert_eq!(branches, 1, "{f}");
}

/// The same after another loop, whose exit edge propagation finds executable only on a later
/// pass: the second head's parameters wait for it instead of taking the OSR entry's loads.
#[test]
fn osr_transparent_constants_after_a_loop() {
    let v = vec![
        arg(-24, 0),
        Insn::ImmW64 { d: Slot(-8), imm: 0 },
        // 2: a first loop, counting to 10.
        Insn::BrLtUImmW64 { a: Slot(-8), imm: 10, neg: F, t: Target(5) },
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 },
        Insn::Jmp { t: Target(2) },
        // 5:
        Insn::ImmW64 { d: Slot(-32), imm: 5 },
        // 6: the second head.
        Insn::BrLtUW64 { a: Slot(-8), b: Slot(-24), neg: F, t: Target(12) },
        Insn::BrEqImmW64 { a: Slot(-32), imm: 5, neg: T, t: Target(9) },
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 100 },
        // 9:
        Insn::ImmW64 { d: Slot(-32), imm: 5 },
        Insn::AddImmW64 { d: Slot(-8), a: Slot(-8), imm: 1 },
        Insn::Jmp { t: Target(6) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let f = ir(&decoded(&v, 32, &[]));
    let adds = f.layout.iter().flat_map(|b| f.blocks[b.idx()].insts.iter()).filter(|i| matches!(f.insts[i.idx()].op, Op::Bin(..))).count();
    assert_eq!(adds, 2, "{f}");
}

/// A handler call through its register entry whose result only dead code reads goes.
#[test]
fn dead_handler_call() {
    let v = vec![
        arg(-16, 0),
        Insn::CtpopW64 { d: Slot(-20), a: Slot(-16) },
        Insn::AddW32 { d: Slot(-20), a: Slot(-20), b: Slot(-20) },
        Insn::Ret { s: Slot(-16), k: 8 },
    ];
    let f = ir(&decoded(&v, 32, &[]));
    assert!(
        f.insts.iter().enumerate().all(|(k, i)| !matches!(i.op, Op::HCall(_)) || !f.blocks[i.block.idx()].insts.iter().any(|j| j.idx() == k)),
        "{f}"
    );
}

fn opt(mut f: IrFunc) -> IrFunc {
    f.verify().unwrap_or_else(|e| panic!("{e}\n{f}"));
    ryo_bytecode::jit::opt::run(&mut f, None);
    f.verify().unwrap_or_else(|e| panic!("{e}\n{f}"));
    f
}

/// A switch on a constant becomes a jump, and its target, left with one predecessor, merges
/// into the entry.
#[test]
fn switch_on_constant() {
    let mut f = IrFunc::default();
    let (b0, b1, b2) = (f.block(BlockKind::Entry), f.block(BlockKind::Body), f.block(BlockKind::Body));
    let p = f.param(b0, 8);
    let q = f.param(b2, 8);
    let one = f.konst(1, 8);
    f.terminate(b0, Term::Switch { idx: one, targets: vec![Edge::to(b1), Edge { to: b2, args: vec![p] }] });
    let z = f.konst(0, 8);
    f.terminate(b1, Term::Ret { k: 8, parts: vec![z] });
    f.terminate(b2, Term::Ret { k: 8, parts: vec![q] });
    f.layout = vec![b0, b1, b2];
    let f = opt(f);
    assert_eq!(f.layout, vec![b0], "{f}");
    let Term::Ret { parts, .. } = &f.blocks[0].term else { panic!("{f}") };
    assert_eq!(parts, &vec![p], "{f}");
}

/// A loop parameter whose arguments are one value and itself is that value; then the
/// constant condition folds and the exit merges.
#[test]
fn self_loop_parameter_aliases() {
    let mut f = IrFunc::default();
    let (b0, b1, b2) = (f.block(BlockKind::Entry), f.block(BlockKind::Body), f.block(BlockKind::Body));
    let a = f.param(b0, 8);
    let c = f.param(b0, 1);
    let x = f.param(b1, 8);
    f.terminate(b0, Term::Jmp(Edge { to: b1, args: vec![a] }));
    f.terminate(b1, Term::Br { cond: c, t: Edge { to: b1, args: vec![x] }, f: Edge::to(b2) });
    f.terminate(b2, Term::Ret { k: 8, parts: vec![x] });
    f.layout = vec![b0, b1, b2];
    let f = opt(f);
    assert!(f.blocks[b1.idx()].params.is_empty(), "{f}");
    let Term::Ret { parts, .. } = &f.blocks[b2.idx()].term else { panic!("{f}") };
    assert_eq!(parts, &vec![a], "{f}");
}

/// Propagation through a loop: `x` stays 0 around it (`x * 1`, `x + 0`), so the exit test
/// on it is decided and the loop never exits by it.
#[test]
fn constant_around_a_loop() {
    let mut f = IrFunc::default();
    let (b0, b1, b2, b3) = (f.block(BlockKind::Entry), f.block(BlockKind::Body), f.block(BlockKind::Body), f.block(BlockKind::Body));
    let n = f.param(b0, 8);
    let x = f.param(b1, 8);
    let i = f.param(b1, 8);
    let (z, one) = (f.konst(0, 8), f.konst(1, 8));
    f.terminate(b0, Term::Jmp(Edge { to: b1, args: vec![z, z] }));
    let m = f.inst(b1, Op::Bin(ryo_bytecode::jit::ir::BinOp::Mul, 8), vec![x, one], &[8]);
    let m = f.result(m);
    let c = f.inst(b1, Op::Cmp(ryo_bytecode::jit::ir::Cc::Eq, 8), vec![m, z], &[1]);
    let c = f.result(c);
    f.terminate(b1, Term::Br { cond: c, t: Edge::to(b2), f: Edge::to(b3) });
    let i2 = f.inst(b2, Op::Bin(ryo_bytecode::jit::ir::BinOp::Add, 8), vec![i, one], &[8]);
    let i2 = f.result(i2);
    let c2 = f.inst(b2, Op::Cmp(ryo_bytecode::jit::ir::Cc::LtU, 8), vec![i2, n], &[1]);
    let c2 = f.result(c2);
    f.terminate(b2, Term::Br { cond: c2, t: Edge { to: b1, args: vec![m, i2] }, f: Edge::to(b3) });
    f.terminate(b3, Term::Ret { k: 8, parts: vec![i] });
    f.layout = vec![b0, b1, b2, b3];
    let f = opt(f);
    assert!(
        f.layout
            .iter()
            .all(|b| f.blocks[b.idx()].insts.iter().all(|i| !matches!(f.insts[i.idx()].op, Op::Bin(ryo_bytecode::jit::ir::BinOp::Mul, _)))),
        "{f}"
    );
    assert_eq!(f.blocks[b1.idx()].params.len(), 1, "{f}");
}

/// Two parameters of a head with an OSR entry, equal on every normal edge, are one: the OSR
/// entry's loads differ, but the AOT frame holds the same value in both slots there.
#[test]
fn osr_transparent_duplicate_parameters() {
    use ryo_bytecode::jit::ir::{BinOp, Cc};
    let mut f = IrFunc::default();
    let (b0, b1, b2, b3) = (f.block(BlockKind::Entry), f.block(BlockKind::Body), f.block(BlockKind::Body), f.block(BlockKind::Body));
    let bo = f.block(BlockKind::Osr(0));
    f.blocks[b1.idx()].head = Some(0);
    f.osr = vec![Some(bo)];
    let a = f.param(b0, 8);
    let (x, y) = (f.param(b1, 8), f.param(b1, 8));
    f.terminate(b0, Term::Jmp(Edge { to: b1, args: vec![a, a] }));
    let l1 = f.inst(bo, Op::OsrLoad(-8, 8), vec![], &[8]);
    let l2 = f.inst(bo, Op::OsrLoad(-16, 8), vec![], &[8]);
    let (l1, l2) = (f.result(l1), f.result(l2));
    f.terminate(bo, Term::Jmp(Edge { to: b1, args: vec![l1, l2] }));
    let s = f.inst(b1, Op::Bin(BinOp::Sub, 8), vec![x, y], &[8]);
    let s = f.result(s);
    let hundred = f.konst(100, 8);
    let c = f.inst(b1, Op::Cmp(Cc::LtU, 8), vec![s, hundred], &[1]);
    let c = f.result(c);
    f.terminate(b1, Term::Br { cond: c, t: Edge::to(b2), f: Edge::to(b3) });
    f.terminate(b2, Term::Jmp(Edge { to: b1, args: vec![x, y] }));
    f.terminate(b3, Term::Ret { k: 8, parts: vec![s] });
    f.layout = vec![b0, b1, b2, b3];
    let f = opt(f);
    assert_eq!(f.blocks[b1.idx()].params.len(), 1, "{f}");
    assert_eq!(f.blocks[bo.idx()].insts.len(), 1, "{f}");
}

/// Scalar replacement: an alloca written as two `u32`s and read as a `u64` (then written as
/// a `u64` and its high half read) is promoted, its accesses split into the two fields.
#[test]
fn mixed_width_alloca_promoted() {
    use ryo_bytecode::jit::ir::{Alloca, AllocaId, BinOp};
    let mut f = IrFunc::default();
    f.allocas.push(Alloca { aot_off: -8, size: 8, kind: AllocaKind::Memory, pinned: false, escaped: true, inlined: false });
    let a = AllocaId(0);
    let b0 = f.block(BlockKind::Entry);
    let (p, q) = (f.param(b0, 8), f.param(b0, 8));
    f.inst(b0, Op::AStore(a, 0, 4), vec![p], &[]);
    f.inst(b0, Op::AStore(a, 4, 4), vec![q], &[]);
    let x = f.inst(b0, Op::ALoad(a, 0, 8), vec![], &[8]);
    let x = f.result(x);
    let s = f.inst(b0, Op::Bin(BinOp::Add, 8), vec![x, p], &[8]);
    let s = f.result(s);
    f.inst(b0, Op::AStore(a, 0, 8), vec![s], &[]);
    let y = f.inst(b0, Op::ALoad(a, 4, 4), vec![], &[4]);
    let y = f.result(y);
    let r = f.inst(b0, Op::Ext { from: 4, to: 8, sx: false }, vec![y], &[8]);
    let r = f.result(r);
    f.terminate(b0, Term::Ret { k: 8, parts: vec![r] });
    f.layout = vec![b0];
    let mut f = opt(f);
    assert!(ryo_bytecode::jit::opt::promote::promote(&mut f), "{f}");
    let f = opt(f);
    assert_eq!(f.allocas[0].kind, AllocaKind::Promoted, "{f}");
    assert!(f.blocks[0].insts.iter().all(|&i| !matches!(f.insts[i.idx()].op, Op::ALoad(..) | Op::AStore(..))), "{f}");
}

/// Value numbering over the dominator tree: a block with a single predecessor reuses the
/// load and the sum its dominator computed; and a store to a memory alloca that the next
/// store overwrites goes.
#[test]
fn dominator_value_numbering_and_dead_stores() {
    use ryo_bytecode::jit::ir::{Alloca, AllocaId, BinOp};
    let mut f = IrFunc::default();
    let (b0, b1, b2) = (f.block(BlockKind::Entry), f.block(BlockKind::Body), f.block(BlockKind::Body));
    let p = f.param(b0, 8);
    let c = f.param(b0, 1);
    let i = f.inst(b0, Op::Load(8, 0), vec![p], &[8]);
    let x = f.result(i);
    let i = f.inst(b0, Op::Bin(BinOp::Add, 8), vec![x, p], &[8]);
    let s = f.result(i);
    f.terminate(b0, Term::Br { cond: c, t: Edge::to(b1), f: Edge { to: b2, args: vec![] } });
    let i = f.inst(b1, Op::Load(8, 0), vec![p], &[8]);
    let x1 = f.result(i);
    let i = f.inst(b1, Op::Bin(BinOp::Add, 8), vec![x1, p], &[8]);
    let s1 = f.result(i);
    f.terminate(b1, Term::Ret { k: 8, parts: vec![s1] });
    f.allocas.push(Alloca { aot_off: -8, size: 8, kind: AllocaKind::Memory, pinned: false, escaped: false, inlined: false });
    let a = AllocaId(0);
    f.inst(b2, Op::AStore(a, 0, 8), vec![s], &[]);
    f.inst(b2, Op::AStore(a, 0, 8), vec![x], &[]);
    let i = f.inst(b2, Op::ALoad(a, 0, 8), vec![], &[8]);
    let r = f.result(i);
    f.terminate(b2, Term::Ret { k: 8, parts: vec![r] });
    f.layout = vec![b0, b1, b2];
    ryo_bytecode::jit::opt::lvn::lvn(&mut f, None);
    ryo_bytecode::jit::opt::dse::dse(&mut f);
    f.verify().unwrap_or_else(|e| panic!("{e}\n{f}"));
    assert!(f.blocks[b1.idx()].insts.is_empty(), "{f}");
    let Term::Ret { parts, .. } = &f.blocks[b1.idx()].term else { panic!("{f}") };
    assert_eq!(parts, &vec![s], "{f}");
    let Term::Ret { parts, .. } = &f.blocks[b2.idx()].term else { panic!("{f}") };
    assert_eq!(parts, &vec![x], "{f}");
    let stores = f.blocks[b2.idx()].insts.iter().filter(|i| matches!(f.insts[i.idx()].op, Op::AStore(..))).count();
    assert_eq!(stores, 1, "{f}");
}

fn live_ops(f: &IrFunc) -> Vec<Op> {
    f.layout.iter().flat_map(|b| f.blocks[b.idx()].insts.iter()).map(|i| f.insts[i.idx()].op.clone()).collect()
}

/// A `memmove` whose length the folds make 12 becomes loads (8 and 4 bytes), all before the
/// stores; one of a length only known at run time stays a handler call.
#[test]
fn constant_memmove_as_loads_and_stores() {
    let v = vec![
        arg(-8, 0),
        arg(-16, 1),
        arg(-24, 2),
        Insn::ImmW64 { d: Slot(-32), imm: 12 },
        Insn::MulImmW64 { d: Slot(-40), a: Slot(-32), imm: 1 },
        Insn::Memmove { dp: Slot(-8), sp: Slot(-16), n: Slot(-40) },
        Insn::Memcpy { dp: Slot(-8), sp: Slot(-16), n: Slot(-24) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let f = ir(&decoded(&v, 48, &[]));
    let ops = live_ops(&f);
    let hcalls = ops.iter().filter(|o| matches!(o, Op::HCall(_))).count();
    assert_eq!(hcalls, 1, "{f}");
    let mem: Vec<&Op> = ops.iter().filter(|o| matches!(o, Op::Load(..) | Op::Store(..))).collect();
    assert_eq!(mem, [&Op::Load(8, 0), &Op::Load(4, 8), &Op::Store(8, 0), &Op::Store(4, 8)], "{f}");
}

/// A 3-byte `memset` becomes stores of the byte spread over a word.
#[test]
fn constant_memset_as_stores() {
    let v = vec![
        arg(-8, 0),
        arg(-16, 1),
        Insn::ImmW64 { d: Slot(-24), imm: 3 },
        Insn::Memset { dp: Slot(-8), b: Slot(-16), n: Slot(-24) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let f = ir(&decoded(&v, 32, &[]));
    let ops = live_ops(&f);
    assert!(!ops.iter().any(|o| matches!(o, Op::HCall(_))), "{f}");
    let st: Vec<&Op> = ops.iter().filter(|o| matches!(o, Op::Store(..))).collect();
    assert_eq!(st, [&Op::Store(2, 0), &Op::Store(1, 2)], "{f}");
}

/// A `memcpy` out of a local through its address: the loads become alloca accesses, the
/// address goes, and the local promotes.
#[test]
fn constant_memcpy_from_a_local_promotes() {
    let v = vec![
        arg(-8, 0),
        Insn::ImmW64 { d: Slot(-32), imm: 1 },
        Insn::ImmW64 { d: Slot(-24), imm: 2 },
        Insn::Addr { d: Slot(-40), s: Slot(-32) },
        Insn::ImmW64 { d: Slot(-48), imm: 16 },
        Insn::Memcpy { dp: Slot(-8), sp: Slot(-40), n: Slot(-48) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let d = decoded(&v, 48, &[(3, -32, 16, ScopeKind::Escape { align: 8 })]);
    let mut f = ir(&d);
    assert!(ryo_bytecode::jit::opt::promote::promote(&mut f), "{f}");
    let f = opt(f);
    let ops = live_ops(&f);
    assert!(!ops.iter().any(|o| matches!(o, Op::HCall(_) | Op::ALoad(..) | Op::AStore(..) | Op::AllocaAddr(..))), "{f}");
    assert_eq!(ops.iter().filter(|o| matches!(o, Op::Store(8, _))).count(), 2, "{f}");
}

/// `ctpop`, `ctlz` and `cttz` of a constant fold to the handler's count at every width (of 0,
/// `ctlz`/`cttz` give the width); of a run-time value they stay handler calls.
#[test]
fn bit_counts_of_constants_fold() {
    type Mk = fn(Slot, Slot) -> Insn<'static>;
    let ops: [(u32, [Mk; 3]); 4] = [
        (8, [|d, a| Insn::CtpopW8 { d, a }, |d, a| Insn::CtlzW8 { d, a }, |d, a| Insn::CttzW8 { d, a }]),
        (16, [|d, a| Insn::CtpopW16 { d, a }, |d, a| Insn::CtlzW16 { d, a }, |d, a| Insn::CttzW16 { d, a }]),
        (32, [|d, a| Insn::CtpopW32 { d, a }, |d, a| Insn::CtlzW32 { d, a }, |d, a| Insn::CttzW32 { d, a }]),
        (64, [|d, a| Insn::CtpopW64 { d, a }, |d, a| Insn::CtlzW64 { d, a }, |d, a| Insn::CttzW64 { d, a }]),
    ];
    for (bits, mk) in ops {
        let all = u64::MAX >> (64 - bits);
        // The bits above the width are ignored.
        for x in [0, all, 1, 4, 0x50, 1 << (bits - 1), all ^ 1, 0xff00_0000_0000_0010] {
            let lo = x & all;
            let want = [lo.count_ones(), lo.leading_zeros() - (64 - bits), if lo == 0 { bits } else { lo.trailing_zeros() }];
            for (k, mk) in mk.iter().enumerate() {
                let v = vec![Insn::ImmW64 { d: Slot(-8), imm: x }, mk(Slot(-16), Slot(-8)), Insn::Ret { s: Slot(-16), k: 4 }];
                let f = ir(&decoded(&v, 16, &[]));
                assert!(!live_ops(&f).iter().any(|o| matches!(o, Op::HCall(_))), "{bits} {k} {x:#x}\n{f}");
                let Term::Ret { parts, .. } = &f.blocks[0].term else { panic!("{f}") };
                assert_eq!(f.def(parts[0]), ValueDef::Const(want[k] as u64), "{bits} {k} {x:#x}\n{f}");
            }
        }
        for mk in mk {
            let v = vec![arg(-8, 0), mk(Slot(-16), Slot(-8)), Insn::Ret { s: Slot(-16), k: 4 }];
            let f = ir(&decoded(&v, 16, &[]));
            assert_eq!(live_ops(&f).iter().filter(|o| matches!(o, Op::HCall(_))).count(), 1, "{f}");
        }
    }
}

/// `count_ones() == 1` of a constant alignment (`is_aligned_to`'s check): the count, the
/// compare and the branch fold, and the panic path goes.
#[test]
fn power_of_two_check_folds() {
    let v = vec![
        arg(-8, 0),
        Insn::ImmW64 { d: Slot(-16), imm: 4 },
        Insn::CtpopW64 { d: Slot(-24), a: Slot(-16) },
        Insn::BrEqImmW32 { a: Slot(-24), imm: 1, neg: T, t: Target(5) },
        Insn::Unreachable {},
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let f = opt(ir(&decoded(&v, 32, &[])));
    assert!(live_ops(&f).is_empty(), "{f}");
    assert!(f.layout.iter().all(|b| !matches!(f.blocks[b.idx()].term, Term::Trap)), "{f}");
}

/// A constant pool for the fold: `bytes` at pool offset 0 (or, by address, at `BASE`), with
/// relocated fields at the offsets `relocs` gives, each read whole as its `PoolRead`.
struct Pool {
    bytes: Vec<u8>,
    relocs: Vec<(u32, ryo_bytecode::image::PoolRead)>,
}

const BASE: u64 = 0x7000_0000;

impl ryo_bytecode::jit::opt::ConstMem for Pool {
    fn read(&self, a: ryo_bytecode::jit::opt::ConstAt, w: u8) -> Option<ryo_bytecode::image::PoolRead> {
        use ryo_bytecode::image::PoolRead;
        use ryo_bytecode::jit::opt::ConstAt;
        let (off, abs) = match a {
            ConstAt::Root(k) => (k as u64, false),
            ConstAt::Abs(x) => (x.checked_sub(BASE)?, true),
        };
        let b = self.bytes.get(off as usize..)?.get(..w as usize)?;
        let mut v = [0u8; 8];
        v[..b.len()].copy_from_slice(b);
        let bits = u64::from_le_bytes(v);
        for &(r, to) in &self.relocs {
            let r = r as u64;
            if r < off + w as u64 && off < r + 8 {
                if r != off || w != 8 {
                    return None;
                }
                return Some(match (to, abs) {
                    (PoolRead::Const(t), true) => PoolRead::Bits(BASE + t as u64),
                    (to, _) => to,
                });
            }
        }
        Some(PoolRead::Bits(bits))
    }

    fn relocs(&self, k: u32, len: u32) -> Vec<u32> {
        self.relocs.iter().map(|r| r.0).filter(|&r| r + 8 > k && r < k + len).collect()
    }
}

fn ir_with(d: &Decoded, pool: &Pool) -> IrFunc {
    let mode = Mode { counters: false, ..MODE };
    let f = ryo_bytecode::jit::ir_of(d, mode, Some(pool)).unwrap_or_else(|e| panic!("{e:?}"));
    f.verify().unwrap_or_else(|e| panic!("{e}\n{f}"));
    f
}

/// The pool of the fold tests: 0..16 plain bytes, at 16 a pointer to offset 4, at 24 a
/// function pointer (bits), at 32 a pointer into the data area, then 4 plain bytes.
fn pool() -> Pool {
    use ryo_bytecode::image::PoolRead;
    let mut bytes: Vec<u8> = (1..=44).collect();
    bytes[24..32].copy_from_slice(&0x4000_1234u64.to_le_bytes());
    Pool { bytes, relocs: vec![(16, PoolRead::Const(4)), (24, PoolRead::Bits(0x4000_1234)), (32, PoolRead::Data(8))] }
}

/// The function `ret load.w<w> [addr.const k0 + off]`.
fn const_load(w: u8, off: i32) -> Decoded {
    let load = |m| match w {
        1 => Insn::LoadW8 { d: Slot(-16), m },
        2 => Insn::LoadW16 { d: Slot(-16), m },
        4 => Insn::LoadW32 { d: Slot(-16), m },
        _ => Insn::LoadW64 { d: Slot(-16), m },
    };
    let v =
        vec![Insn::AddrConst { d: Slot(-8), a: Abs::Const(Const(0)) }, load(Mem { p: Slot(-8), k: off }), Insn::Ret { s: Slot(-16), k: w as u32 }];
    decoded(&v, 16, &[])
}

fn loads(f: &IrFunc) -> usize {
    live_ops(f).iter().filter(|o| matches!(o, Op::Load(..))).count()
}

/// The constant returned, if the function returns one.
fn ret_const(f: &IrFunc) -> Option<u64> {
    f.layout.iter().find_map(|b| match &f.blocks[b.idx()].term {
        Term::Ret { parts, .. } => match f.def(parts[0]) {
            ValueDef::Const(c) => Some(c),
            _ => None,
        },
        _ => None,
    })
}

/// Plain reads of the pool fold to their bytes, at any width and offset, up to the pool's
/// last byte; reads spanning its end, a relocated field partly, or nothing known stay loads.
#[test]
fn constant_pool_loads_fold() {
    let p = pool();
    let le = |o: usize, w: usize| {
        let mut v = [0u8; 8];
        v[..w].copy_from_slice(&p.bytes[o..o + w]);
        u64::from_le_bytes(v)
    };
    for (w, off) in [(1u8, 0i32), (2, 3), (4, 5), (8, 1), (8, 8), (4, 40), (1, 43)] {
        let f = ir_with(&const_load(w, off), &p);
        assert_eq!(loads(&f), 0, "w{w} at {off}: {f}");
        assert_eq!(ret_const(&f), Some(le(off as usize, w as usize)), "w{w} at {off}: {f}");
    }
    // The function pointer field: its bits.
    let f = ir_with(&const_load(8, 24), &p);
    assert_eq!(ret_const(&f), Some(0x4000_1234), "{f}");
    // Partial reads of a pointer field, spanning the end, or with no pool given: loads.
    for (w, off) in [(4u8, 16i32), (8, 20), (8, 12), (2, 43), (8, 40), (4, 36)] {
        let f = ir_with(&const_load(w, off), &p);
        assert_eq!(loads(&f), 1, "w{w} at {off}: {f}");
    }
    assert_eq!(loads(&ir(&const_load(8, 0))), 1);
}

/// A whole pointer field into the pool becomes the `RefAddr` of its target, and a load
/// through it folds again; one into the data area becomes a data `RefAddr`, and a load
/// through that stays.
#[test]
fn constant_pool_pointer_fields() {
    use ryo_bytecode::asm::Ref;
    let p = pool();
    let chase = |off: i32| {
        let v = vec![
            Insn::AddrConst { d: Slot(-8), a: Abs::Const(Const(0)) },
            Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(-8), k: off } },
            Insn::LoadW32 { d: Slot(-24), m: Mem { p: Slot(-16), k: 0 } },
            Insn::Ret { s: Slot(-24), k: 4 },
        ];
        ir_with(&decoded(&v, 32, &[]), &p)
    };
    let f = chase(16);
    assert_eq!(loads(&f), 0, "{f}");
    assert_eq!(ret_const(&f), Some(u32::from_le_bytes(p.bytes[4..8].try_into().unwrap()) as u64), "{f}");
    let f = chase(32);
    assert_eq!(loads(&f), 1, "{f}");
    assert!(live_ops(&f).contains(&Op::RefAddr(Ref::Data(Data(8)), false)), "{f}");
    // Nothing is folded from the data area itself.
    let v = vec![
        Insn::AddrConst { d: Slot(-8), a: Abs::Data(Data(0)) },
        Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(-8), k: 0 } },
        Insn::Ret { s: Slot(-16), k: 8 },
    ];
    assert_eq!(loads(&ir_with(&decoded(&v, 16, &[]), &p)), 1);
}

/// A constant address (a rebased callee's pool) reads as bits, its pointer fields as their
/// targets' addresses.
#[test]
fn constant_pool_loads_by_address() {
    let p = pool();
    let at = |a: u64| {
        let v = vec![
            Insn::ImmW64 { d: Slot(-8), imm: a },
            Insn::LoadW64 { d: Slot(-16), m: Mem { p: Slot(-8), k: 0 } },
            Insn::Ret { s: Slot(-16), k: 8 },
        ];
        ir_with(&decoded(&v, 16, &[]), &p)
    };
    assert_eq!(ret_const(&at(BASE + 8)), Some(u64::from_le_bytes(p.bytes[8..16].try_into().unwrap())));
    assert_eq!(ret_const(&at(BASE + 16)), Some(BASE + 4));
    assert_eq!(loads(&at(BASE + 20)), 1);
    assert_eq!(loads(&at(BASE - 8)), 1);
}

/// `const` of 24 bytes from offset 8: pieces cut at the relocated field at 16, which becomes
/// a `RefAddr`, the others immediates; with no pool given, it stays a handler call.
#[test]
fn const_copy_from_the_pool() {
    use ryo_bytecode::asm::Ref;
    let p = pool();
    let v = vec![
        arg(-8, 0),
        Insn::Const { d: Slot(-32), k: Const(8), len: 24 },
        Insn::StoreW64 { m: Mem { p: Slot(-8), k: 0 }, s: Slot(-32) },
        Insn::StoreW64 { m: Mem { p: Slot(-8), k: 8 }, s: Slot(-24) },
        Insn::StoreW64 { m: Mem { p: Slot(-8), k: 16 }, s: Slot(-16) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ];
    let d = decoded(&v, 32, &[]);
    let f = ir_with(&d, &p);
    let ops = live_ops(&f);
    assert!(!ops.iter().any(|o| matches!(o, Op::HCall(_) | Op::Load(..))), "{f}");
    assert!(ops.contains(&Op::RefAddr(Ref::Const(Const(4)), false)), "{f}");
    let f = ir(&d);
    assert!(live_ops(&f).iter().any(|o| matches!(o, Op::HCall(_))), "{f}");
}
