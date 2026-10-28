//! Random test cases: an item (or a short straight-line run of items) in the JSON form of
//! Lean's `Item`, a random initial state, and the constraints that keep every access inside
//! the data region and every control transfer on a landing pad.

use crate::cpu::{DATA_LEN, POS};

/// splitmix64.
pub struct Rng(u64);

impl Rng {
    pub fn new(seed: u64) -> Rng {
        Rng(seed)
    }
    pub fn next(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9e3779b97f4a7c15);
        let mut z = self.0;
        z = (z ^ (z >> 30)).wrapping_mul(0xbf58476d1ce4e5b9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94d049bb133111eb);
        z ^ (z >> 31)
    }
    pub fn below(&mut self, n: usize) -> usize {
        (self.next() % n as u64) as usize
    }
    pub fn pick<'a, T>(&mut self, xs: &'a [T]) -> &'a T {
        &xs[self.below(xs.len())]
    }
    pub fn chance(&mut self, num: usize, den: usize) -> bool {
        self.below(den) < num
    }
}

pub const REGS: [&str; 11] = ["rax", "rcx", "rdx", "rsp", "rbp", "rsi", "rdi", "r8", "r9", "r10", "r11"];
/// `Reg.usable`: not `rsp` or `rbp`.
pub const USABLE: [&str; 9] = ["rax", "rcx", "rdx", "rsi", "rdi", "r8", "r9", "r10", "r11"];
const ALU: [&str; 6] = ["add", "or", "and", "sub", "xor", "cmp"];
const SH: [&str; 3] = ["shl", "shr", "sar"];
/// `shiftCl`'s operations: the shifts and the rotates.
const SH_CL: [&str; 5] = ["shl", "shr", "sar", "rol", "ror"];
pub const CONDS: [&str; 12] = ["z", "nz", "l", "ge", "le", "g", "b", "ae", "be", "a", "s", "ns"];
const WIDTHS: [&str; 4] = ["b", "w", "d", "q"];

pub fn reg_num(r: &str) -> usize {
    match r {
        "rax" => 0,
        "rcx" => 1,
        "rdx" => 2,
        "rsp" => 4,
        "rbp" => 5,
        "rsi" => 6,
        "rdi" => 7,
        "r8" => 8,
        "r9" => 9,
        "r10" => 10,
        "r11" => 11,
        _ => panic!("register {r}"),
    }
}

fn bits(w: &str) -> u32 {
    match w {
        "b" => 8,
        "w" => 16,
        "d" => 32,
        _ => 64,
    }
}

/// The low `n` bits.
fn mask(n: u32) -> u64 {
    if n >= 64 { u64::MAX } else { (1 << n) - 1 }
}

/// The `n`-bit value `v` sign-extended.
fn sext(v: u64, n: u32) -> i128 {
    ((v << (64 - n)) as i64 >> (64 - n)) as i128
}

/// Whether `div`/`idiv` at width `n` of `hi:lo` by `d` doesn't fault (`#DE`): `d` is
/// nonzero and the quotient fits.
fn div_ok(signed: bool, n: u32, hi: u64, lo: u64, d: u64) -> bool {
    let (hi, lo, d) = (hi & mask(n), lo & mask(n), d & mask(n));
    if d == 0 {
        return false;
    }
    if signed {
        let x = (sext(hi, n) << n) | lo as i128;
        match x.checked_div(sext(d, n)) {
            Some(q) => q >= -(1i128 << (n - 1)) && q < 1i128 << (n - 1),
            None => false,
        }
    } else {
        (((hi as u128) << n) | lo as u128) / d as u128 >> n == 0
    }
}

fn fits_signed(v: i64, n: u32) -> bool {
    let lo = -(1i64 << (n - 1));
    v >= lo && v < -lo
}

const EDGES: [u64; 22] = [
    0,
    1,
    2,
    3,
    0x7f,
    0x80,
    0xfe,
    0xff,
    0x100,
    0x7fff,
    0x8000,
    0xffff,
    0x7fff_ffff,
    0x8000_0000,
    0xffff_ffff,
    0x1_0000_0000,
    0x7fff_ffff_ffff_ffff,
    0x8000_0000_0000_0000,
    0xffff_ffff_ffff_fffe,
    u64::MAX,
    0xffff_ff80,
    0xffff_ffff_ffff_ff80,
];

/// A test case: the items, references, initial state and extra landing pads (absolute).
pub struct Case {
    pub form: String,
    pub items: Vec<String>,
    pub refs: Vec<(String, u64)>,
    pub regs: [u64; 16],
    pub rflags: u64,
    pub xmm: [u128; 16],
    pub mem: Vec<u8>,
    pub pads: Vec<u64>,
}

/// Builds one case; `func` and `data` are the addresses of the function and the data region.
pub struct Gen<'a> {
    pub rng: &'a mut Rng,
    pub func: u64,
    pub data: u64,
    pub c: Case,
}

impl Gen<'_> {
    /// A value with edge cases at every width (possibly with random upper bits).
    pub fn val(&mut self) -> u64 {
        match self.rng.below(10) {
            0..=3 => self.rng.next(),
            4 | 5 => *self.rng.pick(&EDGES),
            6 => {
                let w = *self.rng.pick(&[8u32, 16, 32]);
                let mask = (1u64 << w) - 1;
                (self.rng.next() & !mask) | (self.rng.pick(&EDGES) & mask)
            }
            7 => self.rng.below(16) as u64,
            8 => self.rng.next() as i8 as i64 as u64,
            _ => self.rng.next() as u32 as u64,
        }
    }

    /// A signed 32-bit immediate.
    pub fn imm32(&mut self) -> i64 {
        match self.rng.below(6) {
            0 => *self.rng.pick(&[
                0i64,
                1,
                -1,
                2,
                127,
                128,
                -128,
                -129,
                255,
                256,
                0x7fff,
                0x8000,
                -0x8000,
                -0x8001,
                0xffff,
                i32::MAX as i64,
                i32::MIN as i64,
            ]),
            1 => self.rng.next() as i8 as i64,
            2 => self.rng.next() as i16 as i64,
            _ => self.rng.next() as i32 as i64,
        }
    }

    fn imm_for(&mut self, w: &str) -> i64 {
        loop {
            let v = self.imm32();
            if bits(w) >= 32 || fits_signed(v, bits(w)) {
                return v;
            }
        }
    }

    pub fn set(&mut self, r: &str, v: u64) {
        self.c.regs[reg_num(r)] = v;
    }

    fn get(&self, r: &str) -> u64 {
        self.c.regs[reg_num(r)]
    }

    /// An offset in the data region with room for `n` bytes.
    fn off(&mut self, n: usize) -> usize {
        self.rng.below(DATA_LEN - n + 1)
    }

    fn disp(&mut self) -> i64 {
        match self.rng.below(4) {
            0 => 0,
            1 => self.rng.next() as i8 as i64,
            2 => *self.rng.pick(&[127i64, -128, 128, -129, i32::MAX as i64, i32::MIN as i64]),
            _ => self.rng.next() as i32 as i64,
        }
    }

    /// A memory operand `[base + disp]` for an `n`-byte access in the data region; sets `base`.
    fn mem_on(&mut self, base: &str, n: usize) -> String {
        self.mem_on_off(base, n).0
    }

    /// `mem_on`, also returning the operand's offset in the data region.
    fn mem_on_off(&mut self, base: &str, n: usize) -> (String, usize) {
        let disp = self.disp();
        let off = self.off(n);
        let a = (self.data + off as u64).wrapping_sub(disp as u64);
        self.set(base, a);
        (format!(r#"{{"base":"{base}","disp":{disp}}}"#), off)
    }

    fn mem(&mut self, n: usize) -> String {
        let base = *self.rng.pick(&USABLE[..]);
        let base = if self.rng.chance(1, 10) { "rbp" } else { base };
        self.mem_on(base, n)
    }

    /// A memory operand off `rbp`, which an inline run never writes: `rbp` must already point
    /// into the data region.
    fn mem_rbp_fixed(&mut self, n: usize) -> String {
        let rbp = self.get("rbp");
        let off = self.off(n) as u64;
        let disp = (self.data + off).wrapping_sub(rbp) as i64;
        format!(r#"{{"base":"rbp","disp":{disp}}}"#)
    }

    /// A memory operand for an `n`-byte access as `mem` (or `mem_rbp_fixed` in an inline run)
    /// whose base is not in `avoid`, and its offset in the data region (single items only: an
    /// inline run's earlier items may store over it).
    fn mem_avoid(&mut self, n: usize, fixed: bool, avoid: &[&str]) -> (String, Option<usize>) {
        if fixed {
            return (self.mem_rbp_fixed(n), None);
        }
        let base = if self.rng.chance(1, 10) {
            "rbp"
        } else {
            loop {
                let b = *self.rng.pick(&USABLE);
                if !avoid.contains(&b) {
                    break b;
                }
            }
        };
        let (m, off) = self.mem_on_off(base, n);
        (m, Some(off))
    }

    /// A nonzero `n`-bit value, often a single bit.
    fn nonzero(&mut self, n: u32) -> u64 {
        let v = match self.rng.below(3) {
            0 => 1 << self.rng.below(n as usize),
            1 => self.val(),
            _ => self.rng.next(),
        } & mask(n);
        if v == 0 { 1 << self.rng.below(n as usize) } else { v }
    }

    /// Makes the `n`-bit register-or-memory source `rm` (a memory operand at `off`, `None` in
    /// an inline run) hold `v`: in the initial state for a single item, by a `setReg` or
    /// `stImm` item just before for an inline run (`v` must then be a sign-extended `imm32`
    /// for memory). The upper bits of a register are random.
    fn put_src(&mut self, n: u32, rm: &Result<&str, (String, Option<usize>)>, v: u64, fixed: bool) {
        match rm {
            Ok(r) => {
                let full = (self.rng.next() & !mask(n)) | (v & mask(n));
                if fixed {
                    self.item(format!(r#"{{"setReg":{{"r":"{r}","v":{full}}}}}"#));
                } else {
                    self.set(r, full);
                }
            }
            Err((m, off)) => match off {
                Some(off) => {
                    let nb = (n / 8) as usize;
                    self.c.mem[*off..*off + nb].copy_from_slice(&v.to_le_bytes()[..nb]);
                }
                None => {
                    let w = if n == 32 { "d" } else { "q" };
                    let imm = v as i64;
                    assert!(fits_signed(imm, 32) && v & mask(n) == (imm as u64) & mask(n));
                    self.item(format!(r#"{{"stImm":{{"w":"{w}","m":{m},"imm":{imm}}}}}"#));
                }
            },
        }
    }

    /// `rdx:rax` (`hi`, `lo`, as `n`-bit values) that `div`/`idiv` by `d` (nonzero) at width `n`
    /// takes without faulting; `lo_is_d`: the divisor is `rax` itself.
    fn div_vals(&mut self, signed: bool, n: u32, d: u64, lo_is_d: bool) -> (u64, u64) {
        let m = mask(n);
        // `hi` the extension of `lo`, as after `cdq`/`cqo` or `xor edx, edx`.
        let ext = |lo: u64| if signed && sext(lo, n) < 0 { m } else { 0 };
        let (hi, lo) = if lo_is_d {
            // A random `hi` mostly overflows; then the extension (quotient 1).
            let hi = if self.rng.chance(1, 2) { self.val() & m } else { ext(d) };
            if div_ok(signed, n, hi, d, d) { (hi, d) } else { (ext(d), d) }
        } else if self.rng.chance(1, 3) {
            let lo = self.val() & m;
            if div_ok(signed, n, ext(lo), lo, d) {
                (ext(lo), lo)
            } else {
                // `MIN / -1`: the dividend `MIN + 1` instead.
                (ext(lo), lo.wrapping_add(1) & m)
            }
        } else if signed {
            // `q * d + r`, `q` an `n`-bit quotient, `|r| < |d|` with the dividend's sign.
            let (q, dd) = (sext(self.val() & m, n), sext(d, n));
            let r = (self.rng.next() as u128 % dd.unsigned_abs()) as i128;
            let p = q * dd;
            let r = if p < 0 || (p == 0 && self.rng.chance(1, 2)) { -r } else { r };
            let x = p + r;
            ((x >> n) as u64 & m, x as u64 & m)
        } else {
            let q = self.val() & m;
            let x = q as u128 * d as u128 + self.rng.next() as u128 % d as u128;
            ((x >> n) as u64 & m, x as u64 & m)
        };
        assert!(div_ok(signed, n, hi, lo, d), "div case {signed} {n} {hi:#x}:{lo:#x} / {d:#x}");
        (hi, lo)
    }

    /// Puts a 64-bit value in the data region at `off`.
    fn put64(&mut self, off: usize, v: u64) {
        self.c.mem[off..off + 8].copy_from_slice(&v.to_le_bytes());
    }

    /// A landing pad away from the item (absolute address).
    fn pad(&mut self) -> u64 {
        let p = self.func + 0x800 + 16 * self.rng.below(64) as u64;
        self.c.pads.push(p);
        p
    }

    fn reg_or_mem(&mut self, w: &str, fixed: bool) -> (String, &'static str) {
        if self.rng.chance(1, 2) {
            (format!(r#"{{"reg":{{"r":"{}"}}}}"#, self.rng.pick(&USABLE)), "reg")
        } else {
            let n = (bits(w) / 8) as usize;
            let m = if fixed { self.mem_rbp_fixed(n) } else { self.mem(n) };
            (format!(r#"{{"mem":{{"m":{m}}}}}"#), "mem")
        }
    }

    fn a_ref(&mut self) -> String {
        match self.rng.below(5) {
            0 => format!(r#"{{"handler":{{"op":{}}}}}"#, self.rng.below(300)),
            1 => r#""probe""#.to_string(),
            2 => format!(r#"{{"func":{{"f":{}}}}}"#, self.rng.below(100)),
            3 => format!(r#"{{"sym":{{"s":{}}}}}"#, self.rng.below(100)),
            _ => format!(r#"{{"site":{{"s":{}}}}}"#, self.rng.below(100)),
        }
    }

    fn data_ref(&mut self) -> String {
        match self.rng.below(3) {
            0 => format!(r#"{{"const":{{"k":{}}}}}"#, self.rng.below(1000)),
            1 => format!(r#"{{"data":{{"d":{}}}}}"#, self.rng.below(1000)),
            _ => format!(r#"{{"ro":{{"off":{}}}}}"#, self.rng.below(1000)),
        }
    }

    fn item(&mut self, s: String) {
        self.c.items.push(s);
    }

    /// One straight-line item (no control flow); in an inline run (`fixed`), memory operands
    /// are off `rbp` and no item writes `rbp` or `rsp`. Returns its form name.
    fn straight(&mut self, fixed: bool) -> String {
        let r = |g: &mut Self| *g.rng.pick(&USABLE);
        let mem = |g: &mut Self, n: usize| if fixed { g.mem_rbp_fixed(n) } else { g.mem(n) };
        match self.rng.below(29) {
            0..=2 => {
                let (op, w, reg) = (*self.rng.pick(&ALU), *self.rng.pick(&WIDTHS), r(self));
                let (rm, k) = self.reg_or_mem(w, fixed);
                self.item(format!(r#"{{"alu":{{"op":"{op}","w":"{w}","reg":"{reg}","rm":{rm}}}}}"#));
                format!("alu.{w}.{k}")
            }
            3..=5 => {
                let (op, w) = (*self.rng.pick(&ALU), *self.rng.pick(&WIDTHS));
                let (rm, k) = self.reg_or_mem(w, fixed);
                let imm = self.imm_for(w);
                self.item(format!(r#"{{"aluImm":{{"op":"{op}","w":"{w}","rm":{rm},"imm":{imm}}}}}"#));
                format!("aluImm.{w}.{k}")
            }
            6 => {
                let (w, reg) = (*self.rng.pick(&["d", "q"]), r(self));
                let (rm, k) = self.reg_or_mem(w, fixed);
                self.item(format!(r#"{{"imul":{{"w":"{w}","reg":"{reg}","rm":{rm}}}}}"#));
                format!("imul.{w}.{k}")
            }
            7 => {
                let (w, reg) = (*self.rng.pick(&["d", "q"]), r(self));
                let (rm, k) = self.reg_or_mem(w, fixed);
                let imm = self.imm32();
                self.item(format!(r#"{{"imulImm":{{"w":"{w}","reg":"{reg}","rm":{rm},"imm":{imm}}}}}"#));
                format!("imulImm.{w}.{k}")
            }
            8 | 9 => {
                let (op, w, reg) = (*self.rng.pick(&SH), *self.rng.pick(&["d", "q"]), r(self));
                let n = bits(w) as usize;
                let amt = match self.rng.below(3) {
                    0 => *self.rng.pick(&[0, 1, 2, n - 1, n, n + 1, 31, 32, 33, 63, 64, 65, 127, 128, 255]),
                    _ => self.rng.below(256),
                };
                self.item(format!(r#"{{"shift":{{"op":"{op}","w":"{w}","reg":"{reg}","amt":{amt}}}}}"#));
                format!("shift.{op}.{w}")
            }
            10 => {
                let w = *self.rng.pick(&WIDTHS);
                let sx = (w == "b" || w == "w") && self.rng.chance(1, 2);
                let (dst, m) = (r(self), mem(self, (bits(w) / 8) as usize));
                self.item(format!(r#"{{"ld":{{"w":"{w}","sx":{sx},"dst":"{dst}","m":{m}}}}}"#));
                format!("ld.{w}{}", if sx { "sx" } else { "" })
            }
            11 => {
                let w = *self.rng.pick(&WIDTHS);
                let src = r(self);
                let m = mem(self, (bits(w) / 8) as usize);
                self.item(format!(r#"{{"st":{{"w":"{w}","src":"{src}","m":{m}}}}}"#));
                format!("st.{w}")
            }
            12 => {
                let w = *self.rng.pick(&WIDTHS);
                let m = mem(self, (bits(w) / 8) as usize);
                let imm = self.imm_for(w);
                self.item(format!(r#"{{"stImm":{{"w":"{w}","m":{m},"imm":{imm}}}}}"#));
                format!("stImm.{w}")
            }
            13 => {
                let c = *self.rng.pick(&CONDS);
                let m = mem(self, 1);
                self.item(format!(r#"{{"setcc":{{"cond":"{c}","m":{m}}}}}"#));
                format!("setcc.{c}")
            }
            14 => {
                let m = mem(self, 1);
                self.item(format!(r#"{{"testM8":{{"m":{m}}}}}"#));
                "testM8".into()
            }
            15 => {
                let (to, x, r) = (self.rng.chance(1, 2), self.rng.below(8), r(self));
                self.item(format!(r#"{{"movd":{{"toXmm":{to},"x":{x},"r":"{r}"}}}}"#));
                format!("movd.{}", if to { "toXmm" } else { "fromXmm" })
            }
            16 => {
                let k = *self.rng.pick(&["testAl", "testRax", "addRaxRcx"]);
                self.item(format!(r#""{k}""#));
                k.into()
            }
            17 => {
                // setReg: every form (xor, mov r32, mov r64 simm32, movabs).
                let r = if fixed { r(self) } else { *self.rng.pick(&REGS) };
                let v = match self.rng.below(4) {
                    0 => 0,
                    1 => self.rng.next() as u32 as u64,
                    2 => self.rng.next() as i32 as i64 as u64 | 0xffff_ffff_8000_0000,
                    _ => self.val(),
                };
                self.item(format!(r#"{{"setReg":{{"r":"{r}","v":{v}}}}}"#));
                "setReg".into()
            }
            18 => {
                let (d, s) = if fixed { (r(self), *self.rng.pick(&REGS)) } else { (*self.rng.pick(&REGS), *self.rng.pick(&REGS)) };
                self.item(format!(r#"{{"mov":{{"dst":"{d}","src":"{s}"}}}}"#));
                "mov".into()
            }
            19 => {
                let (d, m) = (r(self), mem(self, 1));
                self.item(format!(r#"{{"leaM":{{"dst":"{d}","m":{m}}}}}"#));
                "leaM".into()
            }
            20 => {
                // sse: frame operands only (`[rbp + d]`).
                let (st, size, x) = (self.rng.chance(1, 2), *self.rng.pick(&[4usize, 8, 16]), self.rng.below(8));
                let m = if fixed { self.mem_rbp_fixed(size) } else { self.mem_on("rbp", size) };
                self.item(format!(r#"{{"sse":{{"st":{st},"size":{size},"x":{x},"m":{m}}}}}"#));
                format!("sse.{}{size}", if st { "st" } else { "ld" })
            }
            21 => {
                // shiftCl: by `cl`, often an edge count in a single item.
                let (op, w, reg) = (*self.rng.pick(&SH_CL), *self.rng.pick(&WIDTHS), r(self));
                if !fixed && self.rng.chance(2, 3) {
                    let n = bits(w) as u64;
                    let amt = *self.rng.pick(&[0, 1, 2, 7, 8, 9, 15, 16, 17, n - 1, n, n + 1, 31, 32, 33, 63, 64, 65, 0x80, 0xff]);
                    self.set("rcx", (self.get("rcx") & !0xff) | amt);
                }
                self.item(format!(r#"{{"shiftCl":{{"op":"{op}","w":"{w}","reg":"{reg}"}}}}"#));
                format!("shiftCl.{op}.{w}")
            }
            22 => {
                let (w, reg) = (*self.rng.pick(&["d", "q"]), r(self));
                self.item(format!(r#"{{"bswap":{{"w":"{w}","reg":"{reg}"}}}}"#));
                format!("bswap.{w}")
            }
            23 => {
                let w = *self.rng.pick(&["d", "q"]);
                self.item(format!(r#"{{"cdq":{{"w":"{w}"}}}}"#));
                format!("cdq.{w}")
            }
            24 | 25 => {
                // bsf/bsr, a quarter of them of zero: the destination is unmodified (the model's
                // default `Ctx`; a processor that clears its upper half at 32 bits, SDM
                // footnote 1, shows as mismatches in `bsf.d.*.zero`/`bsr.d.*.zero`).
                let (k, w, reg) = (*self.rng.pick(&["bsf", "bsr"]), *self.rng.pick(&["d", "q"]), r(self));
                let n = bits(w);
                let src = if self.rng.chance(1, 2) { Ok(r(self)) } else { Err(self.mem_avoid((n / 8) as usize, fixed, &[])) };
                let zero = self.rng.chance(1, 4);
                let v = if zero {
                    0
                } else if fixed && src.is_err() {
                    // An `stImm` puts it: a sign-extended `imm32`.
                    let v = self.imm32();
                    (if v == 0 { 1 << self.rng.below(31) } else { v }) as u64
                } else {
                    self.nonzero(n)
                };
                self.put_src(n, &src, v, fixed);
                let (rm, kind) = match &src {
                    Ok(r) => (format!(r#"{{"reg":{{"r":"{r}"}}}}"#), "reg"),
                    Err((m, _)) => (format!(r#"{{"mem":{{"m":{m}}}}}"#), "mem"),
                };
                self.item(format!(r#"{{"{k}":{{"w":"{w}","reg":"{reg}","rm":{rm}}}}}"#));
                format!("{k}.{w}.{kind}{}", if zero { ".zero" } else { "" })
            }
            26 => {
                // div/idiv: a nonzero divisor and a quotient that fits (no `#DE`). The divisor
                // is not `rdx` (its own dividend's high half) and a memory divisor's base is
                // neither `rax` nor `rdx`; in an inline run, items just before set the operands.
                let (signed, w) = (self.rng.chance(1, 2), *self.rng.pick(&["d", "q"]));
                let n = bits(w);
                let src = if self.rng.chance(1, 2) {
                    Ok(loop {
                        let d = r(self);
                        if d != "rdx" {
                            break d;
                        }
                    })
                } else {
                    Err(self.mem_avoid((n / 8) as usize, fixed, &["rax", "rdx"]))
                };
                let d = if fixed && src.is_err() {
                    let v = self.imm32();
                    (if v == 0 { -1 } else { v }) as u64 & mask(n)
                } else {
                    loop {
                        let v = self.val() & mask(n);
                        if v != 0 {
                            break v;
                        }
                    }
                };
                let (hi, lo) = self.div_vals(signed, n, d, src == Ok("rax"));
                if src != Ok("rax") {
                    let dv = if fixed && src.is_err() { sext(d, n) as u64 } else { d };
                    self.put_src(n, &src, dv, fixed);
                }
                self.put_src(n, &Ok("rax"), lo, fixed);
                self.put_src(n, &Ok("rdx"), hi, fixed);
                let (rm, kind) = match &src {
                    Ok(r) => (format!(r#"{{"reg":{{"r":"{r}"}}}}"#), "reg"),
                    Err((m, _)) => (format!(r#"{{"mem":{{"m":{m}}}}}"#), "mem"),
                };
                self.item(format!(r#"{{"div":{{"signed":{signed},"w":"{w}","rm":{rm}}}}}"#));
                format!("{}.{w}.{kind}", if signed { "idiv" } else { "div" })
            }
            27 => {
                let (c, reg) = (*self.rng.pick(&CONDS), r(self));
                let (rm, k) = self.reg_or_mem("d", fixed);
                self.item(format!(r#"{{"cmov":{{"cond":"{c}","w":"d","reg":"{reg}","rm":{rm}}}}}"#));
                format!("cmov.{k}")
            }
            _ => {
                // setcc r8: not `cl` (`setccCl`).
                let c = *self.rng.pick(&CONDS);
                let reg = loop {
                    let x = r(self);
                    if x != "rcx" {
                        break x;
                    }
                };
                self.item(format!(r#"{{"setccR":{{"cond":"{c}","reg":"{reg}"}}}}"#));
                format!("setccR.{c}")
            }
        }
    }

    /// The other forms: stack, control flow, references.
    fn other(&mut self) -> String {
        let stack = |g: &mut Self| {
            let off = 64 + 8 * g.rng.below((DATA_LEN - 128) / 8) + if g.rng.chance(1, 8) { g.rng.below(8) } else { 0 };
            let a = g.data + off as u64;
            g.set("rsp", a);
            off
        };
        match self.rng.below(24) {
            0 => {
                let k = self.rng.below(10);
                let i = if k == 0 { r#""loadTableEntry""#.to_string() } else { format!(r#"{{"nop":{{"n":{k}}}}}"#) };
                if k == 0 {
                    let idx = self.val();
                    let off = self.off(4) as u64;
                    self.set("rax", idx);
                    self.set("rcx", (self.data + off).wrapping_sub(idx << 2));
                }
                self.item(i);
                if k == 0 { "loadTableEntry".into() } else { "nop".into() }
            }
            1 => {
                stack(self);
                self.item(r#""pushRbp""#.into());
                "pushRbp".into()
            }
            2 => {
                // PE's epilogue's last item.
                stack(self);
                self.item(r#""popRbp""#.into());
                "popRbp".into()
            }
            3 => {
                // PE's pad region's entry.
                let p = self.pad();
                self.set("r11", p);
                self.item(r#""jmpR11""#.into());
                "jmpR11".into()
            }
            4 => {
                let off = self.off(8);
                self.set("rbp", self.data + off as u64);
                self.item(r#""leave""#.into());
                "leave".into()
            }
            5 | 6 => {
                let k = if self.rng.chance(1, 2) { "subRsp" } else { "addRsp" };
                let v = if self.rng.chance(1, 2) { self.rng.below(256) as u64 } else { self.imm32() as u32 as u64 };
                if self.rng.chance(1, 2) {
                    stack(self);
                }
                self.item(format!(r#"{{"{k}":{{"v":{v}}}}}"#));
                k.into()
            }
            7 => {
                let (r, to) = (*self.rng.pick(&REGS), if self.rng.chance(1, 2) { self.a_ref() } else { self.data_ref() });
                let a = self.data + self.rng.below(0x8000) as u64;
                self.c.refs.push((to.clone(), a));
                self.item(format!(r#"{{"lea":{{"r":"{r}","to":{to}}}}}"#));
                "lea".into()
            }
            8 => {
                let t = self.rng.below(0x7fff_0000);
                self.item(format!(r#"{{"leaTable":{{"t":{t}}}}}"#));
                "leaTable".into()
            }
            9 | 10 => {
                let to = self.a_ref();
                let p = self.pad();
                self.c.refs.push((to.clone(), p));
                let call = self.rng.chance(1, 2);
                if call {
                    stack(self);
                }
                let k = if call { "call" } else { "jmp" };
                self.item(format!(r#"{{"{k}":{{"to":{to}}}}}"#));
                k.into()
            }
            11 => {
                let to = self.data_ref();
                let off = self.off(8);
                let p = self.pad();
                self.put64(off, p);
                self.c.refs.push((to.clone(), self.data + off as u64));
                stack(self);
                self.item(format!(r#"{{"callMem":{{"to":{to}}}}}"#));
                "callMem".into()
            }
            12 => {
                let p = self.pad();
                self.set("rax", p);
                let call = self.rng.chance(1, 2);
                if call {
                    stack(self);
                }
                let k = if call {
                    "callRax"
                } else if self.rng.chance(1, 2) {
                    "jmpRax"
                } else {
                    "jmpRaxW"
                };
                self.item(format!(r#""{k}""#));
                k.into()
            }
            13 => {
                let d = self.rng.next() as i8 as i64;
                let off = self.off(8);
                let p = self.pad();
                self.put64(off, p);
                self.set("r11", (self.data + off as u64).wrapping_sub(d as u64));
                stack(self);
                self.item(format!(r#"{{"callR11":{{"d":{d}}}}}"#));
                "callR11".into()
            }
            14 => {
                let off = self.off(8);
                let p = self.pad();
                self.put64(off, p);
                self.set("rax", self.data + off as u64);
                stack(self);
                self.item(r#""callMemRax""#.into());
                "callMemRax".into()
            }
            15 => {
                let (r, to) = (*self.rng.pick(&REGS), self.data_ref());
                let off = self.off(8);
                self.c.refs.push((to.clone(), self.data + off as u64));
                self.item(format!(r#"{{"loadRip":{{"dst":"{r}","to":{to}}}}}"#));
                "loadRip".into()
            }
            16 => {
                let off = self.off(8);
                if self.rng.chance(1, 2) {
                    let v = self.val();
                    self.put64(off, v);
                }
                // `inc qword [rip + record]` or `[rip + record + 56]` (the loop counter).
                let lp = self.rng.chance(1, 2);
                let a = self.data + off as u64;
                if lp {
                    self.c.refs.push((r#""record""#.into(), a.wrapping_sub(56)));
                    self.c.refs.push((r#""recordLoopCtr""#.into(), a));
                } else {
                    self.c.refs.push((r#""record""#.into(), a));
                }
                self.item(format!(r#"{{"ctrInc":{{"loop":{lp}}}}}"#));
                format!("ctrInc.{}", if lp { "loop" } else { "entry" })
            }
            17 => {
                let p = self.pad();
                let off = stack(self);
                self.put64(off, p);
                self.item(r#""ret""#.into());
                "ret".into()
            }
            _ => {
                // A branch: target the fall-through, a nearby pad (rel8 range) or a far one.
                let cond = *self.rng.pick(&["always", "z", "nz", "l", "ge", "le", "g", "b", "ae", "be", "a", "s", "ns"]);
                let long = self.rng.chance(1, 3);
                let len: i64 = if !long {
                    2
                } else if cond == "always" {
                    5
                } else {
                    6
                };
                let pos = POS as i64;
                let t = match self.rng.below(4) {
                    0 => pos + len,
                    1 => pos + len + 5 + self.rng.below(100) as i64,
                    2 => pos - 5 - self.rng.below(100) as i64,
                    _ if long => 0x800 + 16 * self.rng.below(64) as i64,
                    _ => pos + len + 5 + self.rng.below(100) as i64,
                };
                if t != pos + len {
                    self.c.pads.push(self.func + t as u64);
                }
                self.item(format!(r#"{{"branch":{{"cond":"{cond}","target":{t},"long":{long}}}}}"#));
                format!("branch.{}", if long { "long" } else { "short" })
            }
        }
    }
}

/// A random case. `kind`: 0 a straight-line item, 1 another item (stack, control flow,
/// references), 2 an inline run of 2 to 6 straight-line items, half of them followed by a
/// `jcc rel32`.
pub fn case(rng: &mut Rng, func: u64, data: u64, kind: usize) -> Case {
    let mut g = Gen {
        rng,
        func,
        data,
        c: Case { form: String::new(), items: vec![], refs: vec![], regs: [0; 16], rflags: 0, xmm: [0; 16], mem: vec![0; DATA_LEN], pads: vec![] },
    };
    for i in 0..16 {
        g.c.regs[i] = g.val();
    }
    for x in 0..16 {
        g.c.xmm[x] = (g.val() as u128) << 64 | g.val() as u128;
    }
    for b in g.c.mem.iter_mut() {
        *b = g.rng.next() as u8;
    }
    // CF PF AF ZF SF OF at random, IF set.
    let mut fl = 0x202;
    for bit in [0, 2, 4, 6, 7, 11] {
        if g.rng.chance(1, 2) {
            fl |= 1 << bit;
        }
    }
    g.c.rflags = fl;
    // A stack in the data region (forms that use it set it again).
    g.c.regs[4] = data + 512;
    g.c.form = match kind {
        0 => g.straight(false),
        1 => g.other(),
        _ => {
            let off = 64 + g.rng.below(DATA_LEN - 128);
            g.set("rbp", data + off as u64);
            let n = 2 + g.rng.below(5);
            for _ in 0..n {
                g.straight(true);
            }
            if g.rng.chance(1, 2) {
                // Then a branch on the flags the run left (`rel32`: its position is unknown here).
                let cond = *g.rng.pick(&CONDS);
                let t = 0x800 + 16 * g.rng.below(64);
                g.c.pads.push(func + t as u64);
                g.item(format!(r#"{{"branch":{{"cond":"{cond}","target":{t},"long":true}}}}"#));
                format!("run{n}+jcc")
            } else {
                format!("run{n}")
            }
        }
    };
    g.c
}
