//! The inline sequences against the handlers: every opcode with an inline form, in random
//! one-instruction functions, encoded with and without `Mode::inline`, run on the same
//! arguments and memory. The handlers are checked against a model in `ops.rs`.

#![cfg(all(target_arch = "x86_64", target_os = "linux"))]

mod common;
use common::*;

use ryo_bytecode::asm::has_inline;

struct Rng(u64);
impl Rng {
    fn next(&mut self) -> u64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0
    }
    fn below(&mut self, n: u64) -> u64 {
        self.next() % n
    }
    /// A value with the edge cases of every width likely.
    fn value(&mut self) -> u64 {
        let v = match self.below(8) {
            0 => 0,
            1 => self.below(4),
            2 => u64::MAX - self.below(2),
            3 => 0x80 << (8 * self.below(8)),
            4 => (0x7f << (8 * self.below(8))) | (u64::MAX >> (8 * self.below(8) + 1)),
            _ => self.next(),
        };
        if self.below(4) == 0 { v.rotate_left(self.below(64) as u32) } else { v }
    }
}

/// Argument slots: eight words at `fp + 16`, the last a pointer to a 64-byte buffer.
const ARGS: [i32; 7] = [16, 24, 32, 40, 48, 56, 64];
const PTR: i32 = 72;
/// The result area, returned whole.
const RES: i32 = -32;

/// An instruction of `op` on random operands, followed by `ret` (branches: setting the
/// result to 1 or 2, by the path taken).
fn function(op: Opcode, rng: &mut Rng, args: &[u64; 8]) -> Vec<u32> {
    let mut a = Asm::new();
    a.i(Insn::Zero { d: Slot(RES), len: 32 });
    let mut vals = Vec::new();
    let info = op.info();
    for o in info.operands {
        vals.push(match o.kind {
            OperandKind::Slot if o.name == "d" => (RES + rng.below(24) as i32) as u32 as u128,
            OperandKind::Slot => ARGS[rng.below(7) as usize] as u32 as u128,
            OperandKind::Mem => (PTR as u32 as u128) | (rng.below(57) as u128) << 32,
            OperandKind::U8 | OperandKind::U16 | OperandKind::U32 | OperandKind::U64 | OperandKind::I64 => {
                // Often an argument's value, for equal compares; small for shifts and strides.
                let v = match rng.below(4) {
                    0 => args[rng.below(7) as usize],
                    1 => rng.below(70),
                    2 => (rng.below(200) as i64 - 100) as u64,
                    _ => rng.value(),
                };
                let bits = match o.kind {
                    OperandKind::U8 => 8,
                    OperandKind::U16 => 16,
                    OperandKind::U32 => 32,
                    _ => 64,
                };
                (if bits == 64 { v } else { v & ((1 << bits) - 1) }) as u128
            }
            OperandKind::Neg => rng.below(2) as u128,
            OperandKind::Target => 0,
            k => panic!("{}: operand {k:?}", op.mnemonic()),
        });
    }
    let at = a.raw(op, &vals);
    if info.operand_index("t").is_some() {
        a.i(Insn::ImmW8 { d: Slot(RES), imm: 1 });
        a.i(Insn::Ret { s: Slot(RES), len: 32 });
        let l = a.pos();
        a.patch(at, "t", l);
        a.i(Insn::ImmW8 { d: Slot(RES), imm: 2 });
    }
    a.i(Insn::Ret { s: Slot(RES), len: 32 });
    a.done()
}

#[test]
fn inline_matches_handlers() {
    let mut rng = Rng(0xfeed_beef);
    let buf: *mut [u8; 64] = Box::into_raw(Box::new([0u8; 64]));
    let mut fresh = [0u8; 64];
    for &op in ALL_OPCODES {
        if !has_inline(op) {
            continue;
        }
        let mut code = Vec::new();
        let mut inputs = Vec::new();
        for _ in 0..32 {
            let mut args: [u64; 8] = std::array::from_fn(|_| rng.value());
            if rng.below(3) == 0 {
                args[1] = args[0];
            }
            code.push(function(op, &mut rng, &args));
            inputs.push(args);
        }
        let image = |inline: bool| {
            let mut w = ImageWriter::new(unique_scid());
            let fs: Vec<Func> = code.iter().map(|c| w.add_function(func(c.clone(), 32, 64, 32))).collect();
            let img = link(w.finish(Mode { inline, ..ENC }).expect("image"), &[]);
            register(&[&img]);
            (img, fs)
        };
        let (on, fs_on) = image(true);
        let (off, fs_off) = image(false);
        for (i, args) in inputs.iter().enumerate() {
            for (j, a) in fresh.iter_mut().enumerate() {
                *a = (rng.next() >> (j % 8)) as u8;
            }
            let mut args = *args;
            args[7] = buf as u64;
            unsafe { buf.write(fresh) };
            let r_on: [u8; 32] = ok(on.id(fs_on[i]), args);
            let m_on = unsafe { buf.read() };
            unsafe { buf.write(fresh) };
            let r_off: [u8; 32] = ok(off.id(fs_off[i]), args);
            let m_off = unsafe { buf.read() };
            let what = || format!("{}\n{}", op.mnemonic(), Disasm(&code[i]));
            assert_eq!(r_on, r_off, "result: {}\nargs {args:x?}", what());
            assert_eq!(m_on, m_off, "memory: {}", what());
        }
    }
}
