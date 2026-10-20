use ryo_bytecode::insn::*;

/// A small deterministic generator (xorshift).
struct Rng(u64);
impl Rng {
    fn next(&mut self) -> u32 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0 as u32
    }
}

/// Builds the words of an instruction of `op` from its operand table, with random operand
/// values and `n` elements in every list.
fn sample(op: Opcode, rng: &mut Rng, n: usize) -> Vec<u32> {
    let mut w = vec![op as u32];
    for o in op.info().operands {
        match o.kind {
            OperandKind::List(e) => {
                w.push(n as u32);
                for _ in 0..n * e.words() {
                    w.push(rng.next());
                }
            }
            k => {
                for _ in 0..k.words().unwrap() {
                    w.push(rng.next());
                }
            }
        }
    }
    w
}

#[test]
fn every_opcode_round_trips() {
    let mut rng = Rng(0x9e3779b97f4a7c15);
    for &op in ALL_OPCODES {
        for n in [0, 1, 5] {
            let words = sample(op, &mut rng, n);
            let (insn, len) = Insn::decode(&words).unwrap_or_else(|e| panic!("{op:?}: {e}"));
            assert_eq!(len, words.len(), "{op:?}");
            assert_eq!(insn.opcode(), op);
            assert_eq!(insn_len(&words), Ok(len), "{op:?}");
            if let Some(f) = op.fixed_len() {
                assert_eq!(f, len, "{op:?}");
            }
            let mut out = Vec::new();
            insn.encode(&mut out);
            assert_eq!(out, words, "{op:?}");
            // Disassembly starts with the mnemonic and lists every operand.
            let text = insn.to_string();
            assert!(text.starts_with(op.mnemonic()), "{text}");
            let ops = op.info().operands.len();
            assert_eq!(text.matches(", ").count() >= ops.saturating_sub(1), true, "{text}");
            // Truncation is detected at every length.
            for cut in 0..words.len() {
                assert!(Insn::decode(&words[..cut]).is_err(), "{op:?} cut at {cut}");
            }
        }
    }
}

#[test]
fn opcode_numbering() {
    assert!(Opcode::COUNT < u16::MAX as usize);
    for (i, &op) in ALL_OPCODES.iter().enumerate() {
        assert_eq!(op as usize, i);
        assert_eq!(Opcode::from_u16(i as u16), Some(op));
        assert_eq!(OP_INFO[i].opcode, op);
    }
    assert_eq!(Opcode::from_u16(Opcode::COUNT as u16), None);
    assert_eq!(Insn::decode(&[Opcode::COUNT as u32]), Err(DecodeError::UnknownOpcode(Opcode::COUNT as u16)));
    assert_eq!(Insn::decode(&[Opcode::Abort as u32 | 1 << 16]), Err(DecodeError::ReservedBits(Opcode::Abort as u32 | 1 << 16)));
}

#[test]
fn mnemonics_unique_up_to_deref_forms() {
    let mut seen = std::collections::HashMap::new();
    for info in &OP_INFO {
        let has_deref = info.operands.iter().any(|o| o.kind == OperandKind::Deref);
        let has_mem = info.operands.iter().any(|o| o.kind == OperandKind::Mem);
        let key = (info.mnemonic, has_deref && !info.mnemonic.starts_with("atomic"), has_mem);
        assert!(seen.insert(key, info.opcode).is_none(), "duplicate {}", info.mnemonic);
    }
}

#[test]
fn variable_length_opcodes() {
    let var: Vec<_> = ALL_OPCODES.iter().filter(|o| o.fixed_len().is_none()).map(|o| o.mnemonic()).collect();
    for m in &var {
        assert!(m.starts_with("switch.") || m.starts_with("island"), "{m}");
    }
    assert_eq!(var.len(), 12);
}

/// `ret` finds the destination in word 1 of the caller's call instruction.
#[test]
fn call_destination_in_word_1() {
    for op in [Opcode::Call, Opcode::CallExt, Opcode::CallExtInd, Opcode::CallInd] {
        let i = op.info();
        assert_eq!(i.operands[0].name, "d");
        assert_eq!(i.operands[0].kind, OperandKind::Slot);
        assert_eq!(i.operand_offset(0), Some(1));
        assert!(i.fixed_len.is_some());
    }
}

#[test]
fn widths_complete() {
    let has = |m: &str| OP_INFO.iter().any(|i| i.mnemonic == m);
    for w in [8, 16, 32, 64, 128] {
        for o in ["mov", "imm", "load", "store", "add", "sub", "and", "shl", "shr.s", "eq", "lt.u", "cmp3.s", "rotl", "ctpop", "bswap", "neg", "add.ovf.s", "br.cmp.le.s", "switch.dense", "switch.sparse", "discr.niche"] {
            assert!(has(&format!("{o}.w{w}")), "{o}.w{w}");
        }
        let at128 = w != 128;
        assert_eq!(has(&format!("mul.w{w}")), at128);
        assert_eq!(has(&format!("div.s.w{w}")), at128);
        assert_eq!(has(&format!("mul.ovf.u.w{w}")), at128);
    }
    assert!(has("atomic.cxchg.weak.w64.acqrel.acquire"));
    assert!(has("atomic.umax.w8.seqcst"));
    assert!(!has("atomic.load.w128.seqcst"));
    assert!(has("cvt.f2i.sat.u.f64.w128"));
    assert!(has("cvt.i2f.s.w8.f32"));
    assert!(has("zext.w8.w128") && has("trunc.w128.w8") && !has("zext.w32.w32"));
}

#[test]
fn typed_encoding_and_display() {
    let table = list_words([Target(5), Target(-2)]);
    let cases = list_words([Case64 { value: 1 << 40, target: Target(7) }]);
    let island_ops = [16u32, 24];
    let island_t = list_words([Target(4)]);
    let insns = [
        Insn::AddImmW64 { d: Slot(16), a: Slot(24), imm: u64::MAX },
        Insn::LoadW32 { d: Slot(8), m: Mem { p: Slot(32), k: -4 } },
        Insn::LoadW32Z { d: Slot(8), m: Deref(Slot(32)) },
        Insn::SwitchDenseW8 { s: Slot(0), base: 3, default: Target(9), table: List::from_words(&table) },
        Insn::SwitchSparseW64 { s: Slot(0), default: Target(9), cases: List::from_words(&cases) },
        Insn::Island { sym: Sym(2), ops: List::from_words(&island_ops), targets: List::from_words(&island_t) },
        Insn::CallExt { d: Slot(48), sym: Sym(1), site: Site(0), island: Sym(3) },
        Insn::ImmW128 { d: Slot(0), imm: u128::MAX - 1 },
        Insn::Resume {},
    ];
    let text = [
        "add.imm.w64 $16, $24, 18446744073709551615",
        "load.w32 $8, [$32 - 4]",
        "load.w32 $8, [$32]",
        "switch.dense.w8 $0, 3, @+9, [@+5, @-2]",
        "switch.sparse.w64 $0, @+9, [1099511627776 => @+7]",
        "island sym2, [16, 24], [@+4]",
        "call.ext $48, sym1, site0, sym3",
        "imm.w128 $0, 340282366920938463463374607431768211454",
        "resume",
    ];
    let mut code = Vec::new();
    for (i, t) in insns.iter().zip(text) {
        assert_eq!(i.to_string(), t);
        i.encode(&mut code);
    }
    // Exact words of a few.
    let mut w = Vec::new();
    insns[3].encode(&mut w);
    assert_eq!(w, [Opcode::SwitchDenseW8 as u32, 0, 3, 9, 2, 5, (-2i32) as u32]);
    w.clear();
    insns[5].encode(&mut w);
    assert_eq!(w, [Opcode::Island as u32, 2, 2, 16, 24, 1, 4]);

    let decoded: Vec<_> = Decoder::new(&code).map(|r| r.unwrap().1).collect();
    assert_eq!(decoded, insns);
    let dis = Disasm(&code).to_string();
    assert_eq!(dis.lines().count(), insns.len());
    assert!(dis.lines().nth(1).unwrap().ends_with("load.w32 $8, [$32 - 4]"));
}

#[test]
fn code_buf_patches_targets() {
    let mut c = CodeBuf::new();
    let br = c.emit(&Insn::BrIf { s: Slot(8), t: Target(0) });
    let table = list_words([Target(0), Target(0)]);
    let sw = c.emit(&Insn::SwitchDenseW32 { s: Slot(8), base: 0, default: Target(0), table: List::from_words(&table) });
    let end = c.emit(&Insn::Abort {});
    c.set_target(br, 1, end);
    c.set_target(sw, 2, br);
    c.set_list_target(sw, 3, 1, end);
    let insns: Vec<_> = Decoder::new(&c.words).map(|r| r.unwrap()).collect();
    assert_eq!(insns[0].1, Insn::BrIf { s: Slot(8), t: Target(end as i32) });
    match insns[1].1 {
        Insn::SwitchDenseW32 { default, table, .. } => {
            assert_eq!(default, Target(-(sw as i32)));
            assert_eq!(table.iter().collect::<Vec<_>>(), [Target(0), Target((end - sw) as i32)]);
        }
        _ => panic!(),
    }
}

/// Pins the encoding: any change to the opcode list (order, mnemonics, operand names or
/// kinds) changes this hash. When it fails, bump `FORMAT_VERSION` and update both values.
#[test]
fn opcode_table_is_pinned_to_format_version() {
    let mut h: u64 = 0xcbf29ce484222325; // FNV-1a
    let mut eat = |s: &str| {
        for b in s.bytes().chain([0]) {
            h = (h ^ b as u64).wrapping_mul(0x100000001b3);
        }
    };
    for info in &OP_INFO {
        eat(info.mnemonic);
        for o in info.operands {
            eat(o.name);
            eat(&format!("{:?}", o.kind));
        }
    }
    assert_eq!((ryo_bytecode::FORMAT_VERSION, h), (3, 0xbcc1699064bd4540), "opcode table hash {h:#x}");
}

/// Pins the image table layouts to the format version: any change to a table entry's size or
/// field offsets fails here. When it fails, bump `FORMAT_VERSION` and update the values.
#[test]
fn image_layouts_are_pinned_to_format_version() {
    use ryo_bytecode::image::*;
    use std::mem::{offset_of, size_of};
    let layout = (
        (size_of::<Header>(), offset_of!(Header, data), offset_of!(Header, functions), offset_of!(Header, fixup_area)),
        (
            size_of::<FuncEntry>(),
            offset_of!(FuncEntry, max_outgoing),
            offset_of!(FuncEntry, arg_size),
            offset_of!(FuncEntry, ret_size),
            offset_of!(FuncEntry, portal),
        ),
        (size_of::<CleanupEntry>(), size_of::<FixupEntry>(), size_of::<Span>()),
    );
    assert_eq!(ryo_bytecode::FORMAT_VERSION, 3);
    assert_eq!(layout, ((104, 24, 40, 100), (36, 12, 16, 20, 32), (8, 16, 8)), "{layout:?}");
}

/// Decoding arbitrary words never panics, and whatever decodes re-encodes to the same words.
#[test]
fn decoder_on_random_words() {
    let mut rng = Rng(0x2545f4914f6cdd1d);
    let mut ok = 0;
    for i in 0..200_000 {
        let n = 1 + (rng.next() % 12) as usize;
        let m = [8, 64, 1 << 16, u32::MAX][i % 4];
        let mut w: Vec<u32> = (0..n).map(|_| rng.next() % m).collect();
        // Mostly valid opcodes, so the operand decoders are exercised.
        if i % 2 == 0 {
            w[0] = rng.next() % Opcode::COUNT as u32;
        }
        if let Ok((insn, len)) = Insn::decode(&w) {
            ok += 1;
            let mut out = Vec::new();
            insn.encode(&mut out);
            assert_eq!(out, w[..len]);
            assert_eq!(insn_len(&w), Ok(len));
            let _ = insn.to_string();
        }
        let _ = Disasm(&w).to_string();
    }
    assert!(ok > 10_000, "{ok}");
}

#[test]
fn named_operand_offsets() {
    assert_eq!(off::AddW32::d, 1);
    assert_eq!(off::AddW32::b, 3);
    assert_eq!(off::LoadW32::m, 2);
    assert_eq!(off::StoreW64::s, 3);
    assert_eq!(off::CallExt::island, 4);
    assert_eq!(off::SwitchDenseW64::default, 4);
    assert_eq!(off::SwitchDenseW64::table, 5);
    assert_eq!(off::Island::sym, 1);
    assert_eq!(off::Island::ops, 2);
    assert_eq!(off::Island::targets, usize::MAX);
    for op in [Opcode::Call, Opcode::CallExt, Opcode::CallExtInd, Opcode::CallInd] {
        assert_eq!(operand_word(op, "d"), 1);
    }
}
