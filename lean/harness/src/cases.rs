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
        let disp = self.disp();
        let off = self.off(n);
        let a = (self.data + off as u64).wrapping_sub(disp as u64);
        self.set(base, a);
        format!(r#"{{"base":"{base}","disp":{disp}}}"#)
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
        match self.rng.below(21) {
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
            _ => {
                // sse: frame operands only (`[rbp + d]`).
                let (st, size, x) = (self.rng.chance(1, 2), *self.rng.pick(&[4usize, 8, 16]), self.rng.below(8));
                let m = if fixed { self.mem_rbp_fixed(size) } else { self.mem_on("rbp", size) };
                self.item(format!(r#"{{"sse":{{"st":{st},"size":{size},"x":{x},"m":{m}}}}}"#));
                format!("sse.{}{size}", if st { "st" } else { "ld" })
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
                stack(self);
                self.item(r#""winPrologue""#.into());
                "winPrologue".into()
            }
            3 => {
                let off = 16 + self.off(24);
                self.set("rbp", self.data + off as u64);
                self.item(r#""winEpilogue""#.into());
                "winEpilogue".into()
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
                let k = if call { "callRax" } else { "jmpRax" };
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
                let k = self.imm32() as i8;
                self.c.refs.push((r#""recordCtr""#.into(), (self.data + off as u64).wrapping_sub(1)));
                self.item(format!(r#"{{"ctrSub":{{"k":{k}}}}}"#));
                "ctrSub".into()
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
