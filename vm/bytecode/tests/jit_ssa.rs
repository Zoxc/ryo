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
    ryo_bytecode::jit::opt::run(&mut f);
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
