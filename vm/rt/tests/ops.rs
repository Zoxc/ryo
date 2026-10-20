//! Every integer, float, conversion and atomic opcode against a Rust reference model. Each
//! opcode gets its own function `zero d; op; ret d`, encoded generically from `OP_INFO`.

mod common;
use common::*;
use ryo_bytecode::ALL_OPCODES;

const A: u128 = 16;
const B: u128 = 32;
const D: u128 = 48;
const O: u128 = 64;
const FRAME: u32 = 80;

type Args = (u128, u128);
type Ret = [u128; 2];

fn width(parts: &[&str]) -> Option<u32> {
    parts.iter().rev().find_map(|p| p.strip_prefix('w').and_then(|n| n.parse().ok()))
}

/// Builds one image with a function per selected opcode. `operand` maps an operand name to
/// its value (or None to skip the opcode).
fn image_for(sel: impl Fn(Opcode) -> bool, operand: impl Fn(&str, Opcode) -> Option<u128>) -> (Linked, Vec<(Opcode, Func)>) {
    let mut w = ImageWriter::new(unique_scid());
    let mut fns = vec![];
    'ops: for &op in ALL_OPCODES {
        if !sel(op) {
            continue;
        }
        let mut vals = vec![];
        for o in op.info().operands {
            match operand(o.name, op) {
                Some(v) => vals.push(v),
                None => continue 'ops,
            }
        }
        let mut a = Asm::new();
        a.i(Insn::Zero { d: Slot(D as u32), len: 32 });
        a.raw(op, &vals);
        a.i(Insn::Ret { s: Slot(D as u32), len: 32 });
        fns.push((op, w.add_function(func(a.done(), FRAME, 0, 32, 32))));
    }
    (build(w, &[]), fns)
}

const SAMPLES: &[u128] = &[
    0,
    1,
    2,
    3,
    5,
    7,
    31,
    37,
    63,
    64,
    127,
    0x7f,
    0x80,
    0xff,
    0x7fff,
    0x8000,
    0xffff,
    0x1234_5678,
    0x7fff_ffff,
    0x8000_0000,
    0xffff_ffff,
    0xdead_beef_cafe_babe,
    0x7fff_ffff_ffff_ffff,
    0x8000_0000_0000_0000,
    0x0123_4567_89ab_cdef_fedc_ba98_7654_3210,
    1 << 127,
    u128::MAX >> 1,
    u128::MAX,
    u128::MAX - 1,
];

macro_rules! int_model {
    ($u:ty, $i:ty) => {
        |op: &str, a: u128, b: u128| -> Option<(u128, u32, Option<bool>)> {
            let (ua, ub) = (a as $u, b as $u);
            let (ia, ib) = (ua as $i, ub as $i);
            let n = <$u>::BITS;
            let w = |v: $u| (v as u128, n / 8, None);
            let bl = |v: bool| (v as u128, 1, None);
            let ov = |(v, o): ($u, bool)| (v as u128, n / 8, Some(o));
            let ovs = |(v, o): ($i, bool)| (v as $u as u128, n / 8, Some(o));
            Some(match op {
                "add" => w(ua.wrapping_add(ub)),
                "sub" => w(ua.wrapping_sub(ub)),
                "mul" => w(ua.wrapping_mul(ub)),
                "div.s" | "rem.s" if ib == 0 || (ia == <$i>::MIN && ib == -1) => return None,
                "div.u" | "rem.u" if ub == 0 => return None,
                "div.s" => w(ia.wrapping_div(ib) as $u),
                "div.u" => w(ua / ub),
                "rem.s" => w(ia.wrapping_rem(ib) as $u),
                "rem.u" => w(ua % ub),
                "and" => w(ua & ub),
                "or" => w(ua | ub),
                "xor" => w(ua ^ ub),
                "shl" => w(ua.wrapping_shl(ub as u32)),
                "shr.s" => w(ia.wrapping_shr(ub as u32) as $u),
                "shr.u" => w(ua.wrapping_shr(ub as u32)),
                "neg" => w(ua.wrapping_neg()),
                "not" => w(!ua),
                "eq" => bl(ua == ub),
                "ne" => bl(ua != ub),
                "lt.s" => bl(ia < ib),
                "lt.u" => bl(ua < ub),
                "le.s" => bl(ia <= ib),
                "le.u" => bl(ua <= ub),
                "gt.s" => bl(ia > ib),
                "gt.u" => bl(ua > ub),
                "ge.s" => bl(ia >= ib),
                "ge.u" => bl(ua >= ub),
                "cmp3.s" => (ia.cmp(&ib) as i8 as u8 as u128, 1, None),
                "cmp3.u" => (ua.cmp(&ub) as i8 as u8 as u128, 1, None),
                "rotl" => w(ua.rotate_left(b as u32)),
                "rotr" => w(ua.rotate_right(b as u32)),
                "ctpop" => (ua.count_ones() as u128, 4, None),
                "ctlz" => (ua.leading_zeros() as u128, 4, None),
                "cttz" => (ua.trailing_zeros() as u128, 4, None),
                "bswap" => w(ua.swap_bytes()),
                "bitreverse" => w(ua.reverse_bits()),
                "add.ovf.s" => ovs(ia.overflowing_add(ib)),
                "add.ovf.u" => ov(ua.overflowing_add(ub)),
                "sub.ovf.s" => ovs(ia.overflowing_sub(ib)),
                "sub.ovf.u" => ov(ua.overflowing_sub(ub)),
                "mul.ovf.s" => ovs(ia.overflowing_mul(ib)),
                "mul.ovf.u" => ov(ua.overflowing_mul(ub)),
                _ => panic!("no model for {op}"),
            })
        }
    };
}

fn int_ref(op: &str, n: u32, a: u128, b: u128) -> Option<(u128, u32, Option<bool>)> {
    match n {
        8 => int_model!(u8, i8)(op, a, b),
        16 => int_model!(u16, i16)(op, a, b),
        32 => int_model!(u32, i32)(op, a, b),
        64 => int_model!(u64, i64)(op, a, b),
        128 => int_model!(u128, i128)(op, a, b),
        _ => unreachable!(),
    }
}

const INT_OPS: &[&str] = &[
    "add", "sub", "mul", "div", "rem", "and", "or", "xor", "shl", "shr", "neg", "not", "eq", "ne", "lt", "le",
    "gt", "ge", "cmp3", "rotl", "rotr", "ctpop", "ctlz", "cttz", "bswap", "bitreverse",
];

/// The model's op name: the mnemonic without the width and `.imm`.
fn base(mn: &str) -> String {
    mn.split('.').filter(|p| *p != "imm" && width(&[p]).is_none()).collect::<Vec<_>>().join(".")
}

#[test]
fn integer_ops_all_widths() {
    let sel = |op: Opcode| {
        let p: Vec<&str> = op.mnemonic().split('.').collect();
        INT_OPS.contains(&p[0]) && op.info().operands.iter().all(|o| ["d", "o", "a", "b", "imm"].contains(&o.name))
    };
    // The immediate is filled in per sample below, so encode a placeholder and patch it.
    let (img, fns) = image_for(sel, |n, _| Some(match n {
        "d" => D,
        "o" => O,
        "a" => A,
        "b" => B,
        _ => 0,
    }));
    assert_eq!(fns.len(), 267);
    // Imm forms: rebuild per sample is costly, so instead run them through a second image
    // per immediate value. Register-form ops are checked here.
    let mut checked = 0;
    for &(op, f) in &fns {
        let mn = op.mnemonic();
        if mn.contains(".imm") {
            continue;
        }
        let n = width(&mn.split('.').collect::<Vec<_>>()).unwrap();
        let b_name = base(mn);
        for &a in SAMPLES {
            for &b in SAMPLES {
                let Some((v, bytes, o)) = int_ref(&b_name, n, a, b) else { continue };
                let mask = if bytes == 16 { u128::MAX } else { (1u128 << (bytes * 8)) - 1 };
                let r: Ret = ok(img.id(f), (a, b) as Args);
                assert_eq!(r[0], v & mask, "{mn} {a:#x} {b:#x}");
                if let Some(o) = o {
                    assert_eq!(r[1], o as u128, "{mn} overflow flag {a:#x} {b:#x}");
                }
                checked += 1;
            }
        }
    }
    assert!(checked > 50_000);
}

#[test]
fn integer_imm_ops_all_widths() {
    let imm_ops: Vec<Opcode> = ALL_OPCODES
        .iter()
        .copied()
        .filter(|op| op.mnemonic().contains(".imm") && INT_OPS.contains(&op.mnemonic().split('.').next().unwrap()))
        .filter(|op| op.info().operand_index("d").is_some())
        .collect();
    assert!(imm_ops.len() > 80);
    for &b in &SAMPLES[..SAMPLES.len()] {
        let (img, fns) = image_for(|op| imm_ops.contains(&op), |n, _| Some(match n {
            "d" => D,
            "a" => A,
            "imm" => b,
            _ => unreachable!(),
        }));
        for &(op, f) in &fns {
            let mn = op.mnemonic();
            let n = width(&mn.split('.').collect::<Vec<_>>()).unwrap();
            for &a in SAMPLES {
                let Some((v, bytes, _)) = int_ref(&base(mn), n, a, b) else { continue };
                let mask = if bytes == 16 { u128::MAX } else { (1u128 << (bytes * 8)) - 1 };
                let r: Ret = ok(img.id(f), (a, 0u128) as Args);
                assert_eq!(r[0], v & mask, "{mn} {a:#x} imm {b:#x}");
            }
        }
    }
}

const F64S: &[f64] = &[
    0.0,
    -0.0,
    1.0,
    -1.5,
    2.5,
    3.0,
    1e300,
    -1e-300,
    f64::MAX,
    f64::MIN_POSITIVE,
    f64::INFINITY,
    f64::NEG_INFINITY,
    f64::NAN,
    -f64::NAN,
    7.25,
    1e10,
    -3e9,
    4294967296.5,
    1.8446744073709552e19,
    -9.3e18,
    300.7,
    -129.0,
];

fn float_ref64(op: &str, a: f64, b: f64) -> (u128, u32) {
    let f = |v: f64| (v.to_bits() as u128, 8);
    let bl = |v: bool| (v as u128, 1);
    match op {
        "fadd" => f(a + b),
        "fsub" => f(a - b),
        "fmul" => f(a * b),
        "fdiv" => f(a / b),
        "frem" => f(a % b),
        "fneg" => f(-a),
        "fabs" => f(a.abs()),
        "feq" => bl(a == b),
        "fne" => bl(a != b),
        "flt" => bl(a < b),
        "fle" => bl(a <= b),
        "fmin" => f(a.min(b)),
        "fmax" => f(a.max(b)),
        "copysign" => f(a.copysign(b)),
        _ => panic!("{op}"),
    }
}

fn float_ref32(op: &str, a: f32, b: f32) -> (u128, u32) {
    let f = |v: f32| (v.to_bits() as u128, 4);
    let bl = |v: bool| (v as u128, 1);
    match op {
        "fadd" => f(a + b),
        "fsub" => f(a - b),
        "fmul" => f(a * b),
        "fdiv" => f(a / b),
        "frem" => f(a % b),
        "fneg" => f(-a),
        "fabs" => f(a.abs()),
        "feq" => bl(a == b),
        "fne" => bl(a != b),
        "flt" => bl(a < b),
        "fle" => bl(a <= b),
        "fmin" => f(a.min(b)),
        "fmax" => f(a.max(b)),
        "copysign" => f(a.copysign(b)),
        _ => panic!("{op}"),
    }
}

fn same_float(bits: u32, x: u128, y: u128) -> bool {
    x == y
        || match bits {
            8 => f64::from_bits(x as u64).is_nan() && f64::from_bits(y as u64).is_nan(),
            4 => f32::from_bits(x as u32).is_nan() && f32::from_bits(y as u32).is_nan(),
            _ => false,
        }
}

#[test]
fn float_ops() {
    const FOPS: &[&str] =
        &["fadd", "fsub", "fmul", "fdiv", "frem", "fneg", "fabs", "feq", "fne", "flt", "fle", "fmin", "fmax", "copysign"];
    let sel = |op: Opcode| FOPS.contains(&op.mnemonic().split('.').next().unwrap());
    let (img, fns) = image_for(sel, |n, _| Some(match n {
        "d" => D,
        "a" => A,
        "b" => B,
        _ => unreachable!(),
    }));
    assert_eq!(fns.len(), FOPS.len() * 2);
    for &(op, f) in &fns {
        let mn = op.mnemonic();
        let (name, fmt) = mn.split_once('.').unwrap();
        for &a in F64S {
            for &b in F64S {
                let (args, (v, bytes)) = if fmt == "f64" {
                    ((a.to_bits() as u128, b.to_bits() as u128), float_ref64(name, a, b))
                } else {
                    let (a, b) = (a as f32, b as f32);
                    ((a.to_bits() as u128, b.to_bits() as u128), float_ref32(name, a, b))
                };
                let r: Ret = ok(img.id(f), args);
                let mask = (1u128 << (bytes * 8)) - 1;
                assert!(same_float(bytes, r[0], v & mask), "{mn} {a} {b}: {:#x} vs {v:#x}", r[0]);
            }
        }
    }
}

/// A value of a scalar type, as the reference model sees it.
#[derive(Clone, Copy, Debug)]
enum Val {
    U(u128),
    I(i128),
    F(f64),
}

fn src_val(ty: &str, bits: u128) -> Val {
    let n: u32 = ty[1..].parse().unwrap();
    let mask = if n == 128 { u128::MAX } else { (1 << n) - 1 };
    match &ty[..1] {
        "u" => Val::U(bits & mask),
        "i" => Val::I(((bits & mask) << (128 - n)) as i128 >> (128 - n)),
        "f" if n == 32 => Val::F(f32::from_bits(bits as u32) as f64),
        "f" => Val::F(f64::from_bits(bits as u64)),
        _ => unreachable!(),
    }
}

fn dst_bits(ty: &str, v: Val) -> u128 {
    let n: u32 = ty[1..].parse().unwrap();
    let mask = if n == 128 { u128::MAX } else { (1 << n) - 1 };
    match (&ty[..1], v) {
        ("f", Val::U(u)) if n == 32 => (u as f32).to_bits() as u128,
        ("f", Val::I(i)) if n == 32 => (i as f32).to_bits() as u128,
        ("f", Val::F(f)) if n == 32 => (f as f32).to_bits() as u128,
        ("f", Val::U(u)) => (u as f64).to_bits() as u128,
        ("f", Val::I(i)) => (i as f64).to_bits() as u128,
        ("f", Val::F(f)) => f.to_bits() as u128,
        (_, Val::U(u)) => u & mask,
        (_, Val::I(i)) => i as u128 & mask,
        ("i", Val::F(f)) => {
            let hi = (mask >> 1) as i128;
            (f as i128).clamp(-hi - 1, hi) as u128 & mask
        }
        ("u", Val::F(f)) => (f as u128).min(mask),
        _ => unreachable!(),
    }
}

/// (source type, destination type) of a conversion mnemonic.
fn cvt_types(mn: &str) -> Option<(String, String)> {
    let p: Vec<&str> = mn.split('.').collect();
    let int = |s: &str, w: &str| format!("{s}{}", &w[1..]);
    Some(match p[0] {
        "zext" | "trunc" => (int("u", p[1]), int("u", p[2])),
        "sext" => (int("i", p[1]), int("i", p[2])),
        "cvt" => match p[1] {
            "f2i" => (p[4].into(), int(if p[3] == "s" { "i" } else { "u" }, p[5])),
            "i2f" => (int(if p[2] == "s" { "i" } else { "u" }, p[3]), p[4].into()),
            "f2f" => (p[2].into(), p[3].into()),
            _ => return None,
        },
        _ => return None,
    })
}

#[test]
fn conversions() {
    let (img, fns) = image_for(|op| cvt_types(op.mnemonic()).is_some(), |n, _| Some(match n {
        "d" => D,
        "s" => A,
        _ => unreachable!(),
    }));
    assert_eq!(fns.len(), 72);
    let mut inputs: Vec<u128> = SAMPLES.to_vec();
    for &f in F64S {
        inputs.push(f.to_bits() as u128);
        inputs.push((f as f32).to_bits() as u128);
    }
    for &(op, f) in &fns {
        let (s, d) = cvt_types(op.mnemonic()).unwrap();
        for &x in &inputs {
            let want = dst_bits(&d, src_val(&s, x));
            let r: Ret = ok(img.id(f), (x, 0u128));
            assert_eq!(r[0], want, "{} {x:#x}", op.mnemonic());
        }
    }
}

#[test]
fn atomics() {
    // Frame: p@16, v@32, old@48, new@64, d@80, o@96.
    let sel = |op: Opcode| op.mnemonic().starts_with("atomic.");
    let mut w = ImageWriter::new(unique_scid());
    let mut fns = vec![];
    for &op in ALL_OPCODES.iter().filter(|&&op| sel(op)) {
        let vals: Vec<u128> = op
            .info()
            .operands
            .iter()
            .map(|o| match o.name {
                "m" => 16,
                "s" => 32,
                "old" => 48,
                "new" => 64,
                "d" => 80,
                "o" => 96,
                n => panic!("{n}"),
            })
            .collect();
        let mut a = Asm::new();
        a.i(Insn::Zero { d: Slot(80), len: 32 });
        a.raw(op, &vals);
        a.i(Insn::Ret { s: Slot(80), len: 32 });
        fns.push((op, w.add_function(func(a.done(), 112, 0, 64, 32))));
    }
    let img = build(w, &[]);
    assert!(fns.len() >= 4 * (3 + 3 + 11 * 5 + 2 * 15));
    for &(op, f) in &fns {
        let mn = op.mnemonic();
        let p: Vec<&str> = mn.split('.').collect();
        let n = width(&p).unwrap();
        let mask = (1u128 << n) - 1;
        let sx = |v: u128| ((v << (128 - n)) as i128) >> (128 - n);
        for &(init, v, old) in &[(5u128, 9u128, 5u128), (0xff, 0x80, 1), (0x8000_0000_0000_0001, 3, 7), (u128::MAX, 1, u128::MAX)] {
            let (init, v, old) = (init & mask, v & mask, old & mask);
            let mut cell = [0u64; 2];
            unsafe { std::ptr::copy_nonoverlapping((&raw const init).cast::<u8>(), cell.as_mut_ptr().cast(), (n / 8) as usize) };
            let ptr = cell.as_mut_ptr() as u128;
            let r: Ret = ok(img.id(f), (ptr, v, old, 0x77u128 & mask));
            let mem = (cell[0] as u128 | (cell[1] as u128) << 64) & mask;
            let (want_d, want_mem, want_o) = match p[1] {
                "load" => (init, init, None),
                "store" => (0, v, None),
                "cxchg" => {
                    // `weak` may fail spuriously; accept that only if memory is unchanged.
                    let ok = init == old;
                    if p[2] == "weak" && ok && r[1] == 0 {
                        assert_eq!(mem, init, "{mn}");
                        continue;
                    }
                    (init, if ok { 0x77 & mask } else { init }, Some(ok))
                }
                rmw => {
                    let new = match rmw {
                        "xchg" => v,
                        "add" => init.wrapping_add(v),
                        "sub" => init.wrapping_sub(v),
                        "and" => init & v,
                        "or" => init | v,
                        "xor" => init ^ v,
                        "nand" => !(init & v),
                        "min" => if sx(init) <= sx(v) { init } else { v },
                        "max" => if sx(init) >= sx(v) { init } else { v },
                        "umin" => init.min(v),
                        "umax" => init.max(v),
                        _ => panic!("{rmw}"),
                    };
                    (init, new & mask, None)
                }
            };
            assert_eq!(mem, want_mem, "{mn} memory, init {init:#x} v {v:#x}");
            if p[1] != "store" {
                assert_eq!(r[0], want_d, "{mn} result");
            }
            if let Some(o) = want_o {
                assert_eq!(r[1], o as u128, "{mn} success flag");
            }
        }
    }
    // Fences have no observable single-thread effect; check they execute.
    let mut w = ImageWriter::new(unique_scid());
    let mut a = Asm::new();
    for &op in ALL_OPCODES.iter().filter(|op| op.mnemonic().contains("fence")) {
        a.raw(op, &[]);
    }
    a.i(Insn::ImmW32 { d: Slot(16), imm: 42 });
    a.i(Insn::Ret { s: Slot(16), len: 4 });
    let f = w.add_function(func(a.done(), 32, 0, 0, 4));
    let img = build(w, &[]);
    assert_eq!(ok::<(), u32>(img.id(f), ()), 42);
}
