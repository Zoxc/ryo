//! Every handler against a Rust reference model: integer, float, conversion, atomic, enum,
//! branch, switch and data movement opcodes. Each handler is called directly on a buffer
//! frame, its operands placed in the argument registers by `asm::layout`.

#![cfg(target_arch = "x86_64")]

use ryo_bytecode::asm::layout;
use ryo_bytecode::{ALL_OPCODES, Opcode};
use ryo_rt::vm::{FP_ARG, MODE, handler};

/// Calls `f(a0..a5)` with `rbp = fp`, returning `rax`.
#[unsafe(naked)]
extern "sysv64" fn call_with_fp(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, fp: *mut u8, f: *const ()) -> u64 {
    core::arch::naked_asm!("push rbp", "mov rbp, [rsp + 16]", "call qword ptr [rsp + 24]", "pop rbp", "ret");
}

/// A VM frame: `fp` in the middle, so slots are at negative and positive offsets.
#[repr(C, align(16))]
struct Frame([u8; 1024]);

impl Frame {
    fn new() -> Box<Frame> {
        Box::new(Frame([0; 1024]))
    }
    fn fp(&mut self) -> *mut u8 {
        unsafe { self.0.as_mut_ptr().add(512) }
    }
}

const A: i32 = -48;
const B: i32 = 16;
const D: i32 = -96;
const O: i32 = 48;
const P: i32 = -16;
const OLD: i32 = -64;
const NEW: i32 = 80;

/// The operand value of slot `off`.
fn slot(off: i32) -> u128 {
    off as u32 as u128
}

fn put(fp: *mut u8, off: i32, v: u128) {
    unsafe { fp.offset(off as isize).cast::<u128>().write_unaligned(v) }
}

fn get(fp: *mut u8, off: i32) -> u128 {
    unsafe { fp.offset(off as isize).cast::<u128>().read_unaligned() }
}

fn put_bytes(fp: *mut u8, off: i32, b: &[u8]) {
    unsafe { std::ptr::copy_nonoverlapping(b.as_ptr(), fp.offset(off as isize), b.len()) }
}

fn get_bytes(fp: *mut u8, off: i32, n: usize) -> Vec<u8> {
    unsafe { std::slice::from_raw_parts(fp.offset(off as isize), n).to_vec() }
}

/// Calls `op`'s handler with `vals` (one per operand, in operand order) on frame `fp`.
fn call(op: Opcode, vals: &[u128], fp: *mut u8) -> u64 {
    assert_eq!(vals.len(), op.info().operands.len(), "{}", op.mnemonic());
    let l = layout(op, MODE);
    let mut r = [0u64; 6];
    if FP_ARG {
        r[0] = fp as u64;
    }
    for (loc, &v) in l.locs.iter().zip(vals) {
        let i = loc.reg as usize;
        match (loc.count, loc.shared) {
            (0, _) => {}
            (2, _) => (r[i], r[i + 1]) = (v as u64, (v >> 64) as u64),
            (_, true) => r[i] |= (v as u32 as u64) << loc.shift,
            _ => r[i] = v as u64,
        }
    }
    let f = handler(op).unwrap_or_else(|| panic!("{}: no handler", op.mnemonic()));
    call_with_fp(r[0], r[1], r[2], r[3], r[4], r[5], fp, f)
}

/// Calls `op` with each operand's value given by its name.
fn run(op: Opcode, fp: *mut u8, val: impl Fn(&str) -> u128) -> u64 {
    let vals: Vec<u128> = op.info().operands.iter().map(|o| val(o.name)).collect();
    call(op, &vals, fp)
}

fn width(parts: &[&str]) -> Option<u32> {
    parts.iter().rev().find_map(|p| p.strip_prefix('w').and_then(|n| n.parse().ok()))
}

fn mn_width(mn: &str) -> u32 {
    width(&mn.split('.').collect::<Vec<_>>()).unwrap()
}

fn mask(bits: u32) -> u128 {
    if bits >= 128 { u128::MAX } else { (1u128 << bits) - 1 }
}

fn ops_where(sel: impl Fn(Opcode) -> bool) -> Vec<Opcode> {
    ALL_OPCODES.iter().copied().filter(|&op| sel(op)).collect()
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
    "add",
    "sub",
    "mul",
    "div",
    "rem",
    "and",
    "or",
    "xor",
    "shl",
    "shr",
    "neg",
    "not",
    "eq",
    "ne",
    "lt",
    "le",
    "gt",
    "ge",
    "cmp3",
    "rotl",
    "rotr",
    "ctpop",
    "ctlz",
    "cttz",
    "bswap",
    "bitreverse",
];

/// The model's op name: the mnemonic without `br`, the width and `.imm`.
fn base(mn: &str) -> String {
    let mn = mn.strip_prefix("br.").unwrap_or(mn);
    mn.split('.').filter(|p| *p != "imm" && width(&[p]).is_none()).collect::<Vec<_>>().join(".")
}

fn int_ops(imm: bool) -> Vec<Opcode> {
    ops_where(|op| {
        let mn = op.mnemonic();
        INT_OPS.contains(&mn.split('.').next().unwrap())
            && mn.contains(".imm") == imm
            && op.info().operands.iter().all(|o| ["d", "o", "a", "b", "imm"].contains(&o.name))
    })
}

#[test]
fn integer_ops_all_widths() {
    let ops = int_ops(false);
    assert_eq!(ops.len(), 173);
    let mut f = Frame::new();
    let fp = f.fp();
    let mut checked = 0;
    for op in ops {
        let mn = op.mnemonic();
        let n = mn_width(mn);
        let name = base(mn);
        for &a in SAMPLES {
            for &b in SAMPLES {
                let Some((v, bytes, o)) = int_ref(&name, n, a, b) else { continue };
                put(fp, A, a);
                put(fp, B, b);
                put(fp, D, 0);
                put(fp, O, 0);
                run(op, fp, |n| {
                    slot(match n {
                        "d" => D,
                        "o" => O,
                        "a" => A,
                        "b" => B,
                        _ => unreachable!(),
                    })
                });
                assert_eq!(get(fp, D), v & mask(bytes * 8), "{mn} {a:#x} {b:#x}");
                if let Some(o) = o {
                    assert_eq!(get(fp, O), o as u128, "{mn} overflow flag {a:#x} {b:#x}");
                }
                checked += 1;
            }
        }
    }
    assert!(checked > 50_000);
}

#[test]
fn integer_imm_ops_all_widths() {
    let ops = int_ops(true);
    assert_eq!(ops.len(), 94);
    let mut f = Frame::new();
    let fp = f.fp();
    for op in ops {
        let mn = op.mnemonic();
        let n = mn_width(mn);
        for &b in SAMPLES {
            let imm = b & mask(n);
            for &a in SAMPLES {
                let Some((v, bytes, _)) = int_ref(&base(mn), n, a, imm) else { continue };
                put(fp, A, a);
                put(fp, D, 0);
                run(op, fp, |n| match n {
                    "d" => slot(D),
                    "a" => slot(A),
                    "imm" => imm,
                    _ => unreachable!(),
                });
                assert_eq!(get(fp, D), v & mask(bytes * 8), "{mn} {a:#x} imm {b:#x}");
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

fn same_float(bytes: u32, x: u128, y: u128) -> bool {
    x == y
        || match bytes {
            8 => f64::from_bits(x as u64).is_nan() && f64::from_bits(y as u64).is_nan(),
            4 => f32::from_bits(x as u32).is_nan() && f32::from_bits(y as u32).is_nan(),
            _ => false,
        }
}

/// `d = op a, b` on slots, returning `d`.
fn dab(op: Opcode, fp: *mut u8, a: u128, b: u128) -> u128 {
    put(fp, A, a);
    put(fp, B, b);
    put(fp, D, 0);
    run(op, fp, |n| {
        slot(match n {
            "d" => D,
            "a" => A,
            "b" => B,
            _ => unreachable!(),
        })
    });
    get(fp, D)
}

#[test]
fn float_ops() {
    const FOPS: &[&str] = &["fadd", "fsub", "fmul", "fdiv", "frem", "fneg", "fabs", "feq", "fne", "flt", "fle", "fmin", "fmax", "copysign"];
    let ops = ops_where(|op| FOPS.contains(&op.mnemonic().split('.').next().unwrap()));
    assert_eq!(ops.len(), FOPS.len() * 2);
    let mut f = Frame::new();
    let fp = f.fp();
    for op in ops {
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
                let r = dab(op, fp, args.0, args.1);
                assert!(same_float(bytes, r, v & mask(bytes * 8)), "{mn} {a} {b}: {r:#x} vs {v:#x}");
            }
        }
    }
}

/// fmin/fmax/frem special cases against hand-written expected values (not the std calls
/// the model above uses).
#[test]
fn float_special_values() {
    let ops64 = [Opcode::FminF64, Opcode::FmaxF64, Opcode::FremF64];
    let ops32 = [Opcode::FminF32, Opcode::FmaxF32, Opcode::FremF32];
    let mut f = Frame::new();
    let fp = f.fp();
    let nan = f64::NAN;
    let inf = f64::INFINITY;
    // (op index, a, b, expected; NaN means "any NaN").
    let cases: &[(usize, f64, f64, f64)] = &[
        (0, nan, 1.0, 1.0),
        (0, 1.0, nan, 1.0),
        (0, -2.0, 3.0, -2.0),
        (0, nan, nan, nan),
        (1, nan, -1.0, -1.0),
        (1, -1.0, nan, -1.0),
        (1, -2.0, 3.0, 3.0),
        (1, nan, nan, nan),
        (2, 5.5, 2.0, 1.5),
        (2, -5.5, 2.0, -1.5),
        (2, 5.5, -2.0, 1.5),
        (2, 1.0, 0.0, nan),
        (2, inf, 1.0, nan),
        (2, 1.0, inf, 1.0),
        (2, nan, 1.0, nan),
    ];
    for &(i, a, b, want) in cases {
        let got = f64::from_bits(dab(ops64[i], fp, a.to_bits() as u128, b.to_bits() as u128) as u64);
        assert!(if want.is_nan() { got.is_nan() } else { got == want }, "f64 op {i}: {a} {b} → {got}");
        let r = dab(ops32[i], fp, (a as f32).to_bits() as u128, (b as f32).to_bits() as u128);
        let got = f32::from_bits(r as u32);
        let want = want as f32;
        assert!(if want.is_nan() { got.is_nan() } else { got == want }, "f32 op {i}: {a} {b} → {got}");
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
    let mask = mask(n);
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
    let mask = mask(n);
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
    let ops = ops_where(|op| cvt_types(op.mnemonic()).is_some());
    assert_eq!(ops.len(), 72);
    let mut inputs: Vec<u128> = SAMPLES.to_vec();
    for &f in F64S {
        inputs.push(f.to_bits() as u128);
        inputs.push((f as f32).to_bits() as u128);
    }
    let mut f = Frame::new();
    let fp = f.fp();
    for op in ops {
        let (s, d) = cvt_types(op.mnemonic()).unwrap();
        for &x in &inputs {
            let want = dst_bits(&d, src_val(&s, x));
            put(fp, A, x);
            put(fp, D, 0);
            run(op, fp, |n| {
                slot(match n {
                    "d" => D,
                    "s" => A,
                    _ => unreachable!(),
                })
            });
            assert_eq!(get(fp, D), want, "{} {x:#x}", op.mnemonic());
        }
    }
}

#[test]
fn atomics() {
    let ops = ops_where(|op| op.mnemonic().starts_with("atomic."));
    // Four integer widths, and the pointer forms (no `nand`, `min`, `max`, `umin`, `umax`).
    assert_eq!(ops.len(), 4 * (3 + 3 + 11 * 5 + 2 * 15) + (3 + 3 + 6 * 5 + 2 * 15));
    let mut f = Frame::new();
    let fp = f.fp();
    for op in ops {
        let mn = op.mnemonic();
        let p: Vec<&str> = mn.split('.').collect();
        // `ptr`: a 64-bit value; the arithmetic is on its address.
        let n = width(&p).unwrap_or_else(|| {
            assert!(p.contains(&"ptr"), "{mn}");
            64
        });
        let mask = mask(n);
        let sx = |v: u128| ((v << (128 - n)) as i128) >> (128 - n);
        for &(init, v, old) in &[(5u128, 9u128, 5u128), (0xff, 0x80, 1), (0x8000_0000_0000_0001, 3, 7), (u128::MAX, 1, u128::MAX)] {
            let (init, v, old) = (init & mask, v & mask, old & mask);
            let mut cell = [0u64; 2];
            unsafe { std::ptr::copy_nonoverlapping((&raw const init).cast::<u8>(), cell.as_mut_ptr().cast(), (n / 8) as usize) };
            put(fp, P, cell.as_mut_ptr() as u128);
            put(fp, B, v);
            put(fp, OLD, old);
            put(fp, NEW, 0x77 & mask);
            put(fp, D, 0);
            put(fp, O, 0);
            run(op, fp, |n| {
                slot(match n {
                    "p" => P,
                    "s" => B,
                    "old" => OLD,
                    "new" => NEW,
                    "d" => D,
                    "o" => O,
                    n => panic!("{n}"),
                })
            });
            let (d, o) = (get(fp, D), get(fp, O));
            let mem = (cell[0] as u128 | (cell[1] as u128) << 64) & mask;
            let (want_d, want_mem, want_o) = match p[1] {
                "load" => (init, init, None),
                "store" => (0, v, None),
                "cxchg" => {
                    // `weak` may fail spuriously; accept that only if memory is unchanged.
                    let ok = init == old;
                    if p[2] == "weak" && ok && o == 0 {
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
                        "min" => {
                            if sx(init) <= sx(v) {
                                init
                            } else {
                                v
                            }
                        }
                        "max" => {
                            if sx(init) >= sx(v) {
                                init
                            } else {
                                v
                            }
                        }
                        "umin" => init.min(v),
                        "umax" => init.max(v),
                        _ => panic!("{rmw}"),
                    };
                    (init, new & mask, None)
                }
            };
            assert_eq!(mem, want_mem, "{mn} memory, init {init:#x} v {v:#x}");
            assert_eq!(d, want_d, "{mn} result");
            if let Some(ok) = want_o {
                assert_eq!(o, ok as u128, "{mn} success flag");
            }
        }
    }
    // Fences have no observable single-thread effect; check they execute.
    for op in ops_where(|op| op.mnemonic().contains("fence")) {
        run(op, fp, |_| unreachable!());
    }
}

#[test]
fn branches() {
    let mut f = Frame::new();
    let fp = f.fp();
    for b in [0u8, 1, 2, 0x80, 0xff] {
        put(fp, A, 0xff00 | b as u128);
        let taken = call(Opcode::Br, &[slot(A), 0, 0], fp) as u8 != 0;
        assert_eq!(taken, b != 0, "br {b:#x}");
    }
    let ops = ops_where(|op| op.mnemonic().starts_with("br."));
    assert_eq!(ops.len(), 5 * 8);
    let mut seen = [0; 2];
    for op in ops {
        let mn = op.mnemonic();
        let n = mn_width(mn);
        let imm = mn.contains(".imm");
        for &a in SAMPLES {
            for &b in SAMPLES {
                let b = b & mask(n);
                let want = int_ref(&base(mn), n, a, b).unwrap().0 != 0;
                put(fp, A, a);
                put(fp, B, if imm { !0 } else { b });
                let taken = run(op, fp, |name| match name {
                    "a" => slot(A),
                    "b" => slot(B),
                    "imm" => b,
                    _ => 0,
                }) as u8
                    != 0;
                assert_eq!(taken, want, "{mn} {a:#x} {b:#x}");
                seen[want as usize] += 1;
            }
        }
    }
    assert!(seen[0] > 0 && seen[1] > 0);
}

#[test]
fn switches() {
    let mut f = Frame::new();
    let fp = f.fp();
    let dense = ops_where(|op| op.mnemonic().starts_with("switch.dense."));
    assert_eq!(dense.len(), 5);
    for op in dense {
        let n = mn_width(op.mnemonic());
        let m = mask(n);
        for &base in SAMPLES {
            let base = base & m;
            for len in [0u128, 1, 3, 256] {
                let ss = SAMPLES.iter().copied().chain((0..5).map(|k| base.wrapping_add(k)));
                for s in ss {
                    let i = s.wrapping_sub(base) & m;
                    let want = if i < len { i } else { len };
                    put(fp, A, s);
                    let got = run(op, fp, |name| match name {
                        "s" => slot(A),
                        "base" => base,
                        "table" => len,
                        _ => 0,
                    });
                    assert_eq!(got as u128, want, "{} s {s:#x} base {base:#x} len {len}", op.mnemonic());
                }
            }
        }
    }
    let sparse = ops_where(|op| op.mnemonic().starts_with("switch.sparse."));
    assert_eq!(sparse.len(), 5);
    for op in sparse {
        let n = mn_width(op.mnemonic());
        let bytes = (n / 8) as usize;
        let mut all: Vec<u128> = SAMPLES.iter().map(|&v| v & mask(n)).collect();
        all.sort();
        all.dedup();
        for step in [1, 2, 3] {
            for len in [0, 1, 2, 4, 5, 8, all.len()] {
                let vals: Vec<u128> = all.iter().copied().step_by(step).take(len).collect();
                let mut arr = vec![0u128; vals.len() + 1];
                for (i, v) in vals.iter().enumerate() {
                    let p = unsafe { arr.as_mut_ptr().cast::<u8>().add(i * bytes) };
                    unsafe { std::ptr::copy_nonoverlapping((&raw const *v).cast::<u8>(), p, bytes) };
                }
                let cases = arr.as_ptr() as u128 | (vals.len() as u128) << 64;
                for &s in &all {
                    let want = vals.iter().position(|&v| v == s).unwrap_or(vals.len());
                    put(fp, A, s);
                    let got = run(op, fp, |name| match name {
                        "s" => slot(A),
                        "cases" => cases,
                        _ => 0,
                    });
                    assert_eq!(got as usize, want, "{} s {s:#x} cases {vals:x?}", op.mnemonic());
                }
            }
        }
    }
}

#[test]
fn niche_discriminants() {
    let mut f = Frame::new();
    let fp = f.fp();
    let ranges: &[(u32, u32, u32)] = &[(3, 7, 1), (0, 0, 9), (1, 254, 0), (0xffff_fff0, 0xffff_fff5, 2)];
    let discr = ops_where(|op| op.mnemonic().starts_with("discr.niche."));
    let set = ops_where(|op| op.mnemonic().starts_with("set_discr.niche."));
    assert_eq!((discr.len(), set.len()), (5, 5));
    for (op, set_op) in discr.into_iter().zip(set) {
        let n = mn_width(op.mnemonic());
        let m = mask(n);
        for &ns in SAMPLES {
            let ns = ns & m;
            for &(vs, ve, untagged) in ranges {
                let tags = SAMPLES.iter().map(|&t| t & m).chain((0..300).map(|k| ns.wrapping_add(k) & m));
                for tag in tags {
                    let rel = tag.wrapping_sub(ns) & m;
                    let want = if rel <= ve.wrapping_sub(vs) as u128 { vs.wrapping_add(rel as u32) } else { untagged };
                    put(fp, A, tag | !m);
                    put(fp, D, 0);
                    run(op, fp, |name| match name {
                        "d" => slot(D),
                        "s" => slot(A),
                        "niche_start" => ns,
                        "variants_start" => vs as u128,
                        "variants_end" => ve as u128,
                        "untagged" => untagged as u128,
                        _ => unreachable!(),
                    });
                    assert_eq!(get(fp, D), want as u128, "{} tag {tag:#x} ns {ns:#x} {vs}..={ve}", op.mnemonic());
                }
                for variant in (vs..=vs.wrapping_add(4)).chain([untagged]) {
                    const FILL: u128 = 0xa5a5_a5a5_a5a5_a5a5_a5a5_a5a5_a5a5_a5a5;
                    put(fp, D, FILL);
                    run(set_op, fp, |name| match name {
                        "d" => slot(D),
                        "variant" => variant as u128,
                        "niche_start" => ns,
                        "variants_start" => vs as u128,
                        "untagged" => untagged as u128,
                        _ => unreachable!(),
                    });
                    let want = if variant == untagged {
                        FILL
                    } else {
                        let tag = (variant.wrapping_sub(vs) as u128 & m).wrapping_add(ns) & m;
                        FILL & !m | tag
                    };
                    assert_eq!(get(fp, D), want, "{} variant {variant} ns {ns:#x} vs {vs}", set_op.mnemonic());
                }
            }
        }
    }
}

const PAT: u128 = 0x0f1e_2d3c_4b5a_6978_8796_a5b4_c3d2_e1f0;

fn pattern(n: usize, seed: u8) -> Vec<u8> {
    (0..n).map(|i| (i as u8).wrapping_mul(7).wrapping_add(seed)).collect()
}

#[test]
fn data_movement() {
    let mut f = Frame::new();
    let fp = f.fp();
    let width_ops = |prefix: &str| {
        let ops = ops_where(|op| op.mnemonic().strip_prefix(prefix).is_some_and(|r| r.starts_with(".w")));
        assert_eq!(ops.len(), 5, "{prefix}");
        ops
    };
    for op in width_ops("mov") {
        let m = mask(mn_width(op.mnemonic()));
        put(fp, A, PAT);
        put(fp, D, 0);
        call(op, &[slot(D), slot(A)], fp);
        assert_eq!(get(fp, D), PAT & m, "{}", op.mnemonic());
    }
    for op in width_ops("imm") {
        let m = mask(mn_width(op.mnemonic()));
        put(fp, D, 0);
        call(op, &[slot(D), PAT & m], fp);
        assert_eq!(get(fp, D), PAT & m, "{}", op.mnemonic());
    }
    // Memory operands: `p` holds a pointer into `mem`, and `k` is a signed offset from it.
    #[repr(align(16))]
    struct Mem([u8; 64]);
    let mut mem = Mem([0; 64]);
    let base = unsafe { mem.0.as_mut_ptr().add(32) };
    put(fp, P, base as u128);
    let at = |k: i32| unsafe { base.offset(k as isize) };
    let m_op = |k: i32| slot(P) | (k as u32 as u128) << 64;
    for op in width_ops("load") {
        let bytes = mn_width(op.mnemonic()) / 8;
        for k in [-13, 0, 5] {
            mem.0 = pattern(64, k as u8).try_into().unwrap();
            put(fp, D, 0);
            call(op, &[slot(D), m_op(k)], fp);
            let want = unsafe { at(k).cast::<u128>().read_unaligned() } & mask(bytes * 8);
            assert_eq!(get(fp, D), want, "{} k {k}", op.mnemonic());
        }
    }
    for op in width_ops("store") {
        let bytes = mn_width(op.mnemonic()) as usize / 8;
        for k in [-13, 0, 5] {
            mem.0 = [0; 64];
            put(fp, A, PAT);
            call(op, &[m_op(k), slot(A)], fp);
            let mut want = [0u8; 64];
            want[(32 + k) as usize..][..bytes].copy_from_slice(&PAT.to_le_bytes()[..bytes]);
            assert_eq!(mem.0, want, "{} k {k}", op.mnemonic());
        }
    }
    for len in [0, 1, 7, 16, 23] {
        mem.0 = pattern(64, 3).try_into().unwrap();
        put_bytes(fp, -200, &[0xee; 32]);
        call(Opcode::LoadCopy, &[slot(-200), m_op(-9), len as u128], fp);
        let mut want = vec![0xee; 32];
        want[..len].copy_from_slice(&mem.0[23..][..len]);
        assert_eq!(get_bytes(fp, -200, 32), want, "load.copy {len}");

        mem.0 = [0xee; 64];
        put_bytes(fp, 200, &pattern(32, 9));
        call(Opcode::StoreCopy, &[m_op(4), slot(200), len as u128], fp);
        let mut want = [0xee; 64];
        want[36..][..len].copy_from_slice(&pattern(len, 9));
        assert_eq!(mem.0, want, "store.copy {len}");

        put_bytes(fp, -300, &pattern(32, 1));
        put_bytes(fp, 300, &[0xee; 32]);
        call(Opcode::Copy, &[slot(300), slot(-300), len as u128], fp);
        let mut want = vec![0xee; 32];
        want[..len].copy_from_slice(&pattern(len, 1));
        assert_eq!(get_bytes(fp, 300, 32), want, "copy {len}");

        static K: [u8; 32] = [0x5a; 32];
        put_bytes(fp, 300, &[0xee; 32]);
        call(Opcode::Const, &[slot(300), K.as_ptr() as u128, len as u128], fp);
        assert_eq!(get_bytes(fp, 300, 32), [vec![0x5a; len], vec![0xee; 32 - len]].concat(), "const {len}");

        put_bytes(fp, 300, &[0xee; 32]);
        call(Opcode::Zero, &[slot(300), len as u128], fp);
        assert_eq!(get_bytes(fp, 300, 32), [vec![0; len], vec![0xee; 32 - len]].concat(), "zero {len}");

        // memcpy/memmove/memset take pointers and the length in slots.
        mem.0 = pattern(64, 2).try_into().unwrap();
        put(fp, A, at(-20) as u128);
        put(fp, B, at(8) as u128);
        put(fp, O, len as u128);
        call(Opcode::Memcpy, &[slot(A), slot(B), slot(O)], fp);
        let mut want: [u8; 64] = pattern(64, 2).try_into().unwrap();
        want.copy_within(40..40 + len, 12);
        assert_eq!(mem.0, want, "memcpy {len}");

        for (dk, sk) in [(-20, -17), (-17, -20)] {
            mem.0 = pattern(64, 4).try_into().unwrap();
            put(fp, A, at(dk) as u128);
            put(fp, B, at(sk) as u128);
            call(Opcode::Memmove, &[slot(A), slot(B), slot(O)], fp);
            let mut want: [u8; 64] = pattern(64, 4).try_into().unwrap();
            want.copy_within((32 + sk) as usize..(32 + sk) as usize + len, (32 + dk) as usize);
            assert_eq!(mem.0, want, "memmove {dk} {sk} {len}");
        }

        mem.0 = [0xee; 64];
        put(fp, A, at(-3) as u128);
        put(fp, B, 0xff42);
        call(Opcode::Memset, &[slot(A), slot(B), slot(O)], fp);
        let mut want = [0xee; 64];
        want[29..29 + len].fill(0x42);
        assert_eq!(mem.0, want, "memset {len}");
    }
    for (es, count) in [(0usize, 3usize), (1, 0), (3, 5), (8, 2)] {
        static K: [u8; 8] = [1, 2, 3, 4, 5, 6, 7, 8];
        put_bytes(fp, -400, &[0xee; 32]);
        call(Opcode::Fill, &[slot(-400), K.as_ptr() as u128, es as u128, count as u128], fp);
        let mut want = vec![0xee; 32];
        for i in 0..count {
            want[i * es..][..es].copy_from_slice(&K[..es]);
        }
        assert_eq!(get_bytes(fp, -400, 32), want, "fill {es} x {count}");
    }
}

#[test]
fn addresses() {
    let mut f = Frame::new();
    let fp = f.fp();
    put(fp, D, 0);
    call(Opcode::Addr, &[slot(D), slot(-200)], fp);
    assert_eq!(get(fp, D), unsafe { fp.offset(-200) } as u128);
    call(Opcode::AddrAbs, &[slot(D), 0x1234_5678_9abc], fp);
    assert_eq!(get(fp, D), 0x1234_5678_9abc);
    // `sym` is the address of a cell holding the symbol's address; `.ind` loads through it.
    let target = 0xdead_beef_usize;
    let cell = &raw const target as usize;
    let sym = &raw const cell as u128;
    call(Opcode::AddrSym, &[slot(D), sym], fp);
    assert_eq!(get(fp, D), cell as u128);
    call(Opcode::AddrSymInd, &[slot(D), sym], fp);
    assert_eq!(get(fp, D), target as u128);
    for imm in [0i64, 1, -5, 1 << 40, i64::MIN] {
        put(fp, A, 0x1000_0000);
        call(Opcode::PtrAdd, &[slot(D), slot(A), imm as u64 as u128], fp);
        assert_eq!(get(fp, D), 0x1000_0000u64.wrapping_add(imm as u64) as u128, "ptr.add {imm}");
    }
    for (i, stride) in [(0u64, 8u32), (3, 16), (u64::MAX, 4), (7, 0), (5, u32::MAX)] {
        put(fp, A, 0x1000_0000);
        put(fp, B, i as u128);
        call(Opcode::PtrIndex, &[slot(D), slot(A), slot(B), stride as u128], fp);
        let want = 0x1000_0000u64.wrapping_add(i.wrapping_mul(stride as u64));
        assert_eq!(get(fp, D), want as u128, "ptr.index {i} {stride}");
    }
}

/// The handlers' frame effects (`ryo_bytecode::jit::effects`, which the JIT's SSA tier
/// promotes frame slots by) are exact: run on a frame filled with a pattern, each handler
/// writes only the bytes its table entry says it writes, all of them, and what it writes
/// (and returns) depends only on the bytes the entry says it reads. Handlers with memory
/// effects, lengths given by their operands, or no return are left out.
#[test]
fn handler_effects_are_exact() {
    use ryo_bytecode::full::{OperandKind, Shape};
    use ryo_bytecode::jit::effects::{Effect, effects};
    let mut checked = 0;
    for &op in ALL_OPCODES {
        let Some(e) = effects(op) else { continue };
        let info = op.info();
        let opaque = e.opnds.iter().any(|x| matches!(x, Some(Effect::Block | Effect::Addr)));
        if e.memory || opaque || matches!(info.shape, Shape::Trap) || matches!(op, Opcode::AddrSym | Opcode::AddrSymInd) {
            continue;
        }
        // Operand `i`'s slot at `-480 + 48 i`; immediates from the samples.
        let off = |i: usize| -480 + 48 * i as i32;
        let mn = op.mnemonic();
        let divides = ["div.", "rem."].iter().any(|p| mn.starts_with(p));
        let vals: Vec<u128> = info
            .operands
            .iter()
            .enumerate()
            .map(|(i, o)| match o.kind {
                OperandKind::Slot | OperandKind::Mem => slot(off(i)),
                // A sparse switch's cases: none.
                OperandKind::List(_) => 0,
                _ => SAMPLES[(i * 7 + mn.len()) % SAMPLES.len()],
            })
            .collect();
        // The bytes each effect covers, by kind.
        let mut reads = vec![false; 1024];
        let mut writes = vec![false; 1024];
        let idx = |o: i32| (512 + o) as usize;
        for (i, x) in e.opnds.iter().enumerate() {
            let (r, w) = match *x {
                Some(Effect::Read(n)) => (n, 0),
                Some(Effect::Write(n)) => (0, n),
                Some(Effect::Update(n)) => (n, n),
                None => continue,
                Some(_) => unreachable!(),
            };
            (0..r).for_each(|b| reads[idx(off(i)) + b as usize] = true);
            (0..w).for_each(|b| writes[idx(off(i)) + b as usize] = true);
        }
        // Two frames that agree on the bytes read and differ everywhere else. A divisor reads
        // 1 (no division by zero, no overflow).
        let mut p1 = pattern(1024, op as u8);
        if divides {
            let b = info.operand_index("b").unwrap();
            let n = mn_width(mn) as usize / 8;
            p1[idx(off(b))..][..n].fill(0);
            p1[idx(off(b))] = 1;
        }
        let p2: Vec<u8> = p1.iter().zip(&reads).map(|(&b, &r)| if r { b } else { !b }).collect();
        let mut runs = Vec::new();
        for p in [&p1, &p2] {
            let mut f = Frame::new();
            f.0.copy_from_slice(p);
            let fp = f.fp();
            let ret = call(op, &vals, fp);
            let ret = match info.shape {
                Shape::Br => ret & 0xff,
                Shape::Switch => ret,
                _ => 0,
            };
            for (b, (&now, &was)) in f.0.iter().zip(p.iter()).enumerate() {
                assert!(now == was || writes[b], "{mn}: wrote byte {} that its effects don't", b as i32 - 512);
            }
            let written: Vec<u8> = f.0.iter().zip(&writes).filter(|(_, w)| **w).map(|(&b, _)| b).collect();
            runs.push((written, ret));
        }
        assert_eq!(runs[0], runs[1], "{mn}: the result depends on bytes its effects don't read, or not every byte it writes is written");
        checked += 1;
    }
    assert!(checked > 400, "{checked} handlers checked");
}
