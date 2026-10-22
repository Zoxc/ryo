//! The reduced instruction set against the full one: the same instructions, the ones that
//! run as native code, and `handler`.

use ryo_bytecode::asm;
use ryo_bytecode::full;
use ryo_bytecode::full::{List, Neg, Target, list_words};
use ryo_bytecode::reduced::{self, Arg, Handler, Insn, Opcode};

#[test]
fn subset_of_the_full_set() {
    // Every reduced opcode but `handler` is a full one with the same mnemonic, shape and
    // operands, in the full list's order.
    let mut last = None;
    for &op in reduced::ALL_OPCODES {
        let info = op.info();
        let Some(f) = op.full() else {
            assert_eq!(op, Opcode::Handler);
            continue;
        };
        let fi = f.info();
        assert_eq!((info.mnemonic, info.shape, info.operands), (fi.mnemonic, fi.shape, fi.operands), "{op:?}");
        assert_eq!(format!("{op:?}"), format!("{f:?}"));
        assert_eq!(Opcode::of_full(f), Some(op));
        assert!(last < Some(f), "{op:?} out of the full list's order");
        last = Some(f);
    }
    // And they are exactly those that run as native code.
    for &f in full::ALL_OPCODES {
        assert_eq!(Opcode::of_full(f).is_some(), asm::has_inline(f) || !asm::has_handler(f), "{f:?}");
    }
}

#[test]
fn handler_round_trips() {
    let args = list_words([Arg::Fp, Arg::Imm(u64::MAX - 5), Arg::Const(full::Const(8)), Arg::Ro(16)]);
    let t = list_words([Target(-3)]);
    let insn = Insn::Handler { h: Handler(full::Opcode::DivSW32), args: List::from_words(&args), neg: Neg(true), t: List::from_words(&t) };
    let mut w = Vec::new();
    insn.encode(&mut w);
    assert_eq!(Insn::decode(&w), Ok((insn, w.len())));
    assert_eq!(insn.to_string(), "handler! div.s.w32, [fp, 0xfffffffffffffffa, k8, ro16], [@-3]");
    // Handlers only of full opcodes with one, and valid arguments.
    let mut bad = w.clone();
    bad[1] = full::Opcode::Jmp as u32;
    assert!(Insn::decode(&bad).is_err());
    let mut bad = w.clone();
    bad[3] = 8;
    assert!(Insn::decode(&bad).is_err());
}
