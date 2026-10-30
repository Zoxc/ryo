//! The SSA pipeline's PE frames (`ryo_bytecode::jit`, PE mode): each function's prologue is run
//! symbolically and unwound at every step by its `UNWIND_INFO`, as the Win64 unwinder does
//! (`RtlVirtualUnwind`), which must give back the caller's `rsp` and every callee-saved
//! register (and `xmm6`–`xmm15`, saved to 16-byte aligned slots); its epilogues must restore
//! them in the form the unwinder recognizes; and every `xmm6`–`xmm15` the code names has a
//! save. The functions take callee-saved registers across calls, with saves
//! pushed and, below a pinned alloca, stored; a frame that probes the stack; tail calls.

use std::collections::HashMap;

use ryo_bytecode::asm::{self, ArgReg, Mode, Scope, ScopeKind};
use ryo_bytecode::full::*;
use ryo_bytecode::jit::{self, Allocator, Options, Output};

const PE: Mode = Mode { fp_arg: false, frame_pointer: true, align_loops: true, pe: true, counters: false, far_rt: false };

/// Encodes `insns` (targets as instruction indices) with frame `frame` in PE mode and
/// compiles them through the SSA pipeline, its checkers on.
fn compile(insns: &[Insn<'_>], frame: u32, scopes: &[(usize, i32, u32, ScopeKind)], alloc: Allocator, stress: bool) -> Result<Output, jit::Error> {
    let mut words = Vec::new();
    let mut starts = Vec::new();
    for i in insns {
        starts.push(words.len() as u32);
        i.encode(&mut words);
    }
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
    let enc = asm::encode(&words, frame, &[], &scopes, PE).expect("encodes");
    let d = asm::decode_reduced(&enc, PE).expect("decodes");
    jit::compile(&d, &[], PE, &Options { alloc, stress, check: true, dump: false, licm: false, rotate: false }, None, None)
}

fn arg(d: i32, i: u32) -> Insn<'static> {
    Insn::Arg { d: Slot(d), r: ArgReg { xmm: false, size: 8, index: i }.word() }
}

fn param(s: i32, i: u32) -> [u32; 2] {
    [s as u32, ArgReg { xmm: false, size: 8, index: i }.word()]
}

/// The callee-saved registers of Win64 (x86 numbers): `rbx rbp rsi rdi r12`–`r15`.
const CALLEE_SAVED: [u8; 8] = [3, 5, 6, 7, 12, 13, 14, 15];

/// A machine state with symbolic values: the caller's registers are `0x1000 + n`, the stack
/// is addressed from the entry's `rsp` (0, the return address's slot, which holds `RET`).
#[derive(Clone, Debug)]
struct State {
    regs: [u64; 16],
    /// The `xmm` registers, one symbolic value each (`0x2000 + n` in the caller).
    xmm: [u64; 16],
    mem: HashMap<i64, u64>,
}

const RET: u64 = 0xdead;
const T: Neg = Neg(false);
const RSP: usize = 4;
const RBP: usize = 5;

impl State {
    fn entry() -> State {
        let mut regs: [u64; 16] = std::array::from_fn(|n| 0x1000 + n as u64);
        regs[RSP] = 0;
        State { regs, xmm: std::array::from_fn(|n| 0x2000 + n as u64), mem: HashMap::from([(0, RET)]) }
    }
    fn rsp(&self) -> i64 {
        self.regs[RSP] as i64
    }
    fn load(&self, a: i64) -> u64 {
        *self.mem.get(&a).unwrap_or_else(|| panic!("a load from {a} that nothing wrote"))
    }
}

fn i8_at(c: &[u8], k: usize) -> i64 {
    c[k] as i8 as i64
}

fn i32_at(c: &[u8], k: usize) -> i64 {
    i32::from_le_bytes(c[k..k + 4].try_into().unwrap()) as i64
}

/// Runs the one instruction at `c[k..]` of the forms a PE prologue or epilogue has, and
/// returns its length, or `None` for anything else.
fn step(s: &mut State, c: &[u8], k: usize) -> Option<usize> {
    if c[k] == 0x66 {
        return step_xmm(s, c, k);
    }
    let (rex, o) = if c[k] & 0xf0 == 0x40 { (c[k], k + 1) } else { (0, k) };
    let (b, r) = ((rex & 1) << 3, (rex & 4) << 1);
    let op = c[o];
    match op {
        0x50..=0x57 => {
            s.regs[RSP] = s.regs[RSP].wrapping_sub(8);
            let v = s.regs[((op & 7) | b) as usize];
            s.mem.insert(s.rsp(), v);
            Some(o + 1 - k)
        }
        0x58..=0x5f => {
            let v = s.load(s.rsp());
            s.regs[((op & 7) | b) as usize] = v;
            s.regs[RSP] = s.regs[RSP].wrapping_add(8);
            Some(o + 1 - k)
        }
        // `sub rsp, imm`.
        0x83 | 0x81 if rex == 0x48 && c[o + 1] == 0xec => {
            let (n, len) = if op == 0x83 { (i8_at(c, o + 2), 3) } else { (i32_at(c, o + 2), 6) };
            s.regs[RSP] = (s.rsp() - n) as u64;
            Some(o + len - k)
        }
        // `mov eax, imm32`: the probe's size.
        0xb8 => {
            s.regs[0] = i32_at(c, o + 1) as u32 as u64;
            Some(o + 5 - k)
        }
        // `call rel32`: the probe, which keeps every register.
        0xe8 => Some(o + 5 - k),
        // `lea r, [base + disp]`, `mov [rbp + disp], r` and `mov r, [rbp + disp]`.
        0x8d | 0x89 | 0x8b if rex & 8 != 0 => {
            let m = c[o + 1];
            let (md, reg, rm) = (m >> 6, ((m >> 3) & 7) | r, (m & 7) | b);
            let (base, at) = if rm & 7 == 4 {
                assert_eq!(c[o + 2], 0x24, "a SIB of `[rsp]` only");
                (RSP, o + 3)
            } else {
                (rm as usize, o + 2)
            };
            let (disp, end) = match md {
                0 if rm & 7 != 5 => (0, at),
                1 => (i8_at(c, at), at + 1),
                2 => (i32_at(c, at), at + 4),
                _ => return None,
            };
            let a = s.regs[base] as i64 + disp;
            match op {
                0x8d => s.regs[reg as usize] = a as u64,
                0x89 => {
                    s.mem.insert(a, s.regs[reg as usize]);
                }
                _ => s.regs[reg as usize] = s.load(a),
            }
            Some(end - k)
        }
        _ => None,
    }
}

/// `movdqa [rbp + disp], x` or `movdqa x, [rbp + disp]`, its slot 16-byte aligned (the
/// entry's `rsp`, 0 here, is 8 modulo 16).
fn step_xmm(s: &mut State, c: &[u8], k: usize) -> Option<usize> {
    let (rex, o) = if c[k + 1] & 0xf0 == 0x40 { (c[k + 1], k + 2) } else { (0, k + 1) };
    if c[o] != 0x0f || !matches!(c[o + 1], 0x6f | 0x7f) || rex & 0xb != 0 {
        return None;
    }
    let m = c[o + 2];
    let (md, x, rm) = (m >> 6, ((m >> 3) & 7) | (rex & 4) << 1, m & 7);
    if rm != 5 {
        return None;
    }
    let (disp, end) = match md {
        1 => (i8_at(c, o + 3), o + 4),
        2 => (i32_at(c, o + 3), o + 7),
        _ => return None,
    };
    let a = s.regs[RBP] as i64 + disp;
    assert_eq!(a.rem_euclid(16), 8, "an xmm slot at {a}, not 16-byte aligned");
    if c[o + 1] == 0x7f {
        s.mem.insert(a, s.xmm[x as usize]);
    } else {
        s.xmm[x as usize] = s.load(a);
    }
    Some(end - k)
}

/// The length of the `movdqa x, [rbp + disp]` ending at `c[..b]`, if one does.
fn xmm_restore_before(c: &[u8], b: usize) -> Option<usize> {
    [5, 6, 8, 9].into_iter().find(|&n| {
        let Some(i) = b.checked_sub(n).map(|a| &c[a..b]) else { return false };
        let rex = n % 3 == 0;
        let i = if rex && i[1] == 0x44 {
            &i[2..]
        } else if !rex {
            &i[1..]
        } else {
            return false;
        };
        i[..2] == [0x0f, 0x6f] && i[2] & 0xc7 == if n < 8 { 0x45 } else { 0x85 } && c[b - n] == 0x66
    })
}

/// The unwind codes of `info`: (offset after the operation, op, info, operand).
fn codes(info: &[u8]) -> Vec<(u8, u8, u8, u32)> {
    let n = info[2] as usize;
    let slot = |k: usize| u16::from_le_bytes([info[4 + 2 * k], info[5 + 2 * k]]) as u32;
    let mut out = Vec::new();
    let mut k = 0;
    while k < n {
        let (at, op, i) = (info[4 + 2 * k], info[5 + 2 * k] & 15, info[5 + 2 * k] >> 4);
        let (arg, len) = match (op, i) {
            (0 | 3, _) => (0, 1),
            (2, _) => (8 * i as u32 + 8, 1),
            (1, 0) => (8 * slot(k + 1), 2),
            (1, _) => (slot(k + 1) | slot(k + 2) << 16, 3),
            (4, _) => (8 * slot(k + 1), 2),
            (8, _) => (16 * slot(k + 1), 2),
            (5 | 9, _) => (slot(k + 1) | slot(k + 2) << 16, 3),
            _ => panic!("unwind code {op}"),
        };
        out.push((at, op, i, arg));
        k += len;
    }
    out
}

/// Unwinds the frame in state `s` stopped at code offset `at` (`None`: in the body) by
/// `info`, as `RtlVirtualUnwind` does outside an epilogue: returns the caller's state
/// (`rsp` past the return address, which must be `RET`).
fn unwind(info: &[u8], at: Option<u32>, s: &State) -> State {
    let mut u = s.clone();
    let fp_off = 16 * (info[3] >> 4) as i64;
    let at = at.unwrap_or(u32::MAX);
    let cs = codes(info);
    let fp_set = cs.iter().any(|c| c.1 == 3 && c.0 as u32 <= at);
    let frame = if fp_set { u.regs[(info[3] & 15) as usize] as i64 - fp_off } else { u.rsp() };
    for (off, op, i, arg) in cs {
        if off as u32 > at {
            continue;
        }
        match op {
            0 => {
                u.regs[i as usize] = u.load(u.rsp());
                u.regs[RSP] = u.regs[RSP].wrapping_add(8);
            }
            1 | 2 => u.regs[RSP] = (u.rsp() + arg as i64) as u64,
            3 => u.regs[RSP] = frame as u64,
            4 | 5 => u.regs[i as usize] = u.load(frame + arg as i64),
            8 | 9 => u.xmm[i as usize] = u.load(frame + arg as i64),
            _ => panic!("unwind code {op}"),
        }
    }
    assert_eq!(u.load(u.rsp()), RET, "the return address");
    u.regs[RSP] = u.regs[RSP].wrapping_add(8);
    u
}

/// Checks that unwinding `s` gives the caller's `rsp` (8) and callee-saved registers.
fn check_caller(u: &State, what: &str) {
    assert_eq!(u.rsp(), 8, "{what}: rsp");
    for r in CALLEE_SAVED.iter().filter(|&&r| r as usize != RSP) {
        assert_eq!(u.regs[*r as usize], 0x1000 + *r as u64, "{what}: register {r}");
    }
    for x in 6..16 {
        assert_eq!(u.xmm[x], 0x2000 + x as u64, "{what}: xmm{x}");
    }
}

/// What [`check_frames`] found.
struct Found {
    /// The saves the unwind codes describe (beyond `rbp`, `rdi`, `rsi`).
    saves: usize,
    /// Whether some are stored rather than pushed.
    stored: bool,
    epilogues: usize,
    probe: bool,
    /// Whether some are in the home space above the return address.
    home: bool,
    /// The `xmm` saves the unwind codes describe.
    xsaves: usize,
}

/// The checks of the module documentation on `o`.
fn check_frames(o: &Output, what: &str) -> Found {
    let info = &o.pe_unwind;
    assert!(!info.is_empty() && o.cfi.is_empty(), "{what}: PE unwind info only");
    assert_eq!(info[0], 1, "{what}: version 1, no handler");
    let prologue = info[1] as usize;
    let c = &o.code;
    // The prologue, step by step: unwound before each instruction, and in the body.
    let mut s = State::entry();
    let mut k = 0;
    while k < prologue {
        check_caller(&unwind(info, Some(k as u32), &s), &format!("{what}: at {k}"));
        k += step(&mut s, c, k).unwrap_or_else(|| panic!("{what}: not a prologue instruction at {k}: {:02x?}", &c[k..prologue]));
    }
    assert_eq!(k, prologue, "{what}: the prologue's length");
    check_caller(&unwind(info, None, &s), &format!("{what}: in the body"));
    // The body may move `rsp` (OSR entries do), never `rbp`.
    let mut moved = s.clone();
    moved.regs[RSP] = moved.regs[RSP].wrapping_sub(4096);
    check_caller(&unwind(info, None, &moved), &format!("{what}: rsp moved"));
    // The frame base the stored saves are addressed from is within the frame.
    assert!(s.regs[RBP] as i64 - 16 * (info[3] >> 4) as i64 >= s.rsp(), "{what}: the frame offset");
    let cs = codes(info);
    let saves = cs.iter().filter(|x| (x.1 == 0 && ![5, 6, 7].contains(&x.2)) || x.1 == 4).count();
    let stored = cs.iter().any(|x| x.1 == 4);
    let k = 16 * (info[3] >> 4) as u32;
    let home = cs.iter().any(|x| x.1 == 4 && x.3 >= k + 16);
    let xsaved: Vec<u8> = cs.iter().filter(|x| x.1 == 8 || x.1 == 9).map(|x| x.2).collect();
    // Epilogues: `lea rsp, [rbp + d]` (with a register restore by `mov`s before it, body
    // code), only pops after it, then `ret`, a `jmp rel32`, `jmp [rip + d]` or `rex.w jmp r`.
    let mut epilogues = 0;
    for e in prologue..c.len().saturating_sub(4) {
        if !(c[e..].starts_with(&[0x48, 0x8d, 0x65]) || c[e..].starts_with(&[0x48, 0x8d, 0xa5])) {
            continue;
        }
        let mut t = s.clone();
        // The body may have changed the saved `xmm` registers.
        for &x in &xsaved {
            t.xmm[x as usize] = 0;
        }
        // The restores before it, as the code has them.
        let mut b = e;
        let restore = |b: usize| {
            let reg = (c[b - 2] >> 3) & 7 | (c[b - 4] & 4) << 1;
            c[b - 4] & 0xf8 == 0x48 && c[b - 3] == 0x8b && c[b - 2] & 0xc7 == 0x45 && CALLEE_SAVED.contains(&reg)
        };
        loop {
            if b >= 4 && restore(b) {
                b -= 4;
            } else if let Some(n) = xmm_restore_before(c, b) {
                b -= n;
            } else {
                break;
            }
        }
        let mut k = b;
        while k < e {
            k += step(&mut t, c, k).unwrap();
        }
        k += step(&mut t, c, k).unwrap();
        while c[k] & 0xf8 == 0x58 || (c[k] == 0x41 && c[k + 1] & 0xf8 == 0x58) {
            k += step(&mut t, c, k).unwrap();
        }
        let end = &c[k..];
        // A `jmp rel32` within the function isn't an epilogue's end (to the unwinder either):
        // an OSR entry's post part (`lea rsp, [rbp - F]; jmp head`).
        if end[0] == 0xe9 && !o.relocs.iter().any(|r| r.at as usize == k + 1) {
            continue;
        }
        let ok =
            end[0] == 0xc3 || end[0] == 0xe9 || end.starts_with(&[0xff, 0x25]) || (end[0] & 0xf8 == 0x48 && end[1] == 0xff && end[2] & 0xf8 == 0xe0);
        assert!(ok, "{what}: the epilogue at {e} ends in {:02x?}", &end[..3.min(end.len())]);
        assert_eq!(t.load(t.rsp()), RET, "{what}: the epilogue at {e}: return address");
        t.regs[RSP] = t.regs[RSP].wrapping_add(8);
        check_caller(&t, &format!("{what}: the epilogue at {e}"));
        epilogues += 1;
    }
    xmm_saved(c, &xsaved, what);
    Found { saves, stored, home, epilogues, xsaves: xsaved.len(), probe: prologue >= 10 && c[..prologue].windows(1).any(|w| w[0] == 0xe8) }
}

/// Every `xmm6`–`xmm15` an instruction of `code` names is among `saved` (GNU objdump, if
/// there is one).
fn xmm_saved(code: &[u8], saved: &[u8], what: &str) {
    const OBJDUMP: &str = "/usr/bin/objdump";
    if !gnu_objdump() {
        return;
    }
    let dir = std::env::temp_dir().join(format!("ryo-jit-pe-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let f = dir.join(format!("{:x}.bin", what.len() as u64 ^ code.len() as u64 * 31 ^ code.iter().map(|&b| b as u64).sum::<u64>()));
    std::fs::write(&f, code).unwrap();
    let out = std::process::Command::new(OBJDUMP).args(["-D", "-b", "binary", "-m", "i386:x86-64"]).arg(&f).output().unwrap();
    let text = String::from_utf8_lossy(&out.stdout);
    for x in 6..16u8 {
        assert!(saved.contains(&x) || !text.contains(&format!("%xmm{x}")), "{what}: uses xmm{x} without saving it\n{text}");
    }
}

/// The OSR code (GNU objdump, if there is one), which `pe_osr_unwind_info` describes: the AOT
/// frame's `rbp`, nothing else saved. So no instruction there writes `rbp` or another
/// callee-saved register (`xmm6`–`xmm15` included), each entry stores every save `info`
/// describes at its slot before it jumps to its post part in the body (`jmp r11`, after which
/// the body's information holds), and nothing there is an epilogue's end to the unwinder
/// (`ret` only where an entry returns to the stub). Returns the entries checked.
fn check_osr(o: &Output, info: &[u8], what: &str) -> usize {
    const OBJDUMP: &str = "/usr/bin/objdump";
    let Some(osr) = &o.osr else { return 0 };
    if !gnu_objdump() {
        return 0;
    }
    // The saves: pushed ones at `rbp - 8n` (`rbp` is `fp`), stored ones from `rbp - K`.
    let k = 16 * (info[3] >> 4) as i64;
    let mut want: Vec<(String, i64)> = Vec::new();
    let mut pushed = 0;
    const NAMES: [&str; 16] = ["rax", "rcx", "rdx", "rbx", "rsp", "rbp", "rsi", "rdi", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"];
    for (_, op, i, arg) in codes(info).into_iter().rev() {
        match op {
            0 if i != 5 => {
                pushed += 1;
                want.push((format!("%{}", NAMES[i as usize]), -8 * pushed));
            }
            4 => want.push((format!("%{}", NAMES[i as usize]), arg as i64 - k)),
            8 => want.push((format!("%xmm{i}"), arg as i64 - k)),
            _ => {}
        }
    }
    let mut code = o.code.clone();
    code.resize(o.osr_at as usize, 0xcc);
    code.extend_from_slice(&osr.code);
    let dir = std::env::temp_dir().join(format!("ryo-jit-pe-osr-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let f = dir.join(format!("{:x}.bin", what.len() as u64 ^ code.len() as u64 * 31 ^ code.iter().map(|&b| b as u64).sum::<u64>()));
    std::fs::write(&f, &code).unwrap();
    let start = format!("--start-address={}", o.osr_at);
    let out = std::process::Command::new(OBJDUMP).args(["-D", "-b", "binary", "-m", "i386:x86-64", &start]).arg(&f).output().unwrap();
    let text = String::from_utf8_lossy(&out.stdout);
    let saved_regs: Vec<String> = ["bx", "bp", "si", "di"]
        .iter()
        .flat_map(|r| [format!("%r{r}"), format!("%e{r}"), format!("%{r}"), format!("%{r}l")])
        .chain((12..16).flat_map(|n| [format!("%r{n}"), format!("%r{n}d"), format!("%r{n}w"), format!("%r{n}b")]))
        .chain((6..16).map(|n| format!("%xmm{n}")))
        .collect();
    let (mut stored, mut entries) = (Vec::<(String, i64)>::new(), 0);
    for line in text.lines() {
        let parts: Vec<&str> = line.split('\t').collect();
        if parts.len() < 3 || !parts[0].trim_end().ends_with(':') {
            continue;
        }
        let insn = parts[2].trim();
        let (mn, ops) = insn.split_once(' ').map(|(m, o)| (m, o.trim())).unwrap_or((insn, ""));
        if mn == "int3" || mn.starts_with("(bad)") || mn == ".byte" {
            continue;
        }
        let dst = ops.rsplit(',').next().unwrap_or("");
        assert!(!saved_regs.iter().any(|r| r == dst), "{what}: the OSR code writes {dst}: {insn}");
        if mn.starts_with("jmp") {
            assert!(ops == "*%rax" || ops == "*%r11", "{what}: a jump the unwinder may take for an epilogue's end: {insn}");
            if ops == "*%r11" {
                for w in &want {
                    assert!(stored.contains(w), "{what}: an OSR entry leaves without storing {w:?}: {stored:?}");
                }
                stored.clear();
                entries += 1;
            }
        } else if mn == "ret" {
            stored.clear();
        } else if let Some((src, m)) = ops.split_once(',')
            && let Some(d) = m.strip_suffix("(%rbp)")
        {
            let d = if let Some(h) = d.strip_prefix("-0x") {
                -i64::from_str_radix(h, 16).unwrap()
            } else {
                i64::from_str_radix(d.trim_start_matches("0x"), 16).unwrap_or(0)
            };
            stored.push((src.to_string(), d));
        }
    }
    entries
}

fn each(insns: &[Insn<'_>], frame: u32, scopes: &[(usize, i32, u32, ScopeKind)], what: &str, mut check: impl FnMut(&Found, &str)) {
    for alloc in [Allocator::LinearScan, Allocator::Naive] {
        for stress in [false, true] {
            let what = format!("{what} ({alloc:?}, stress {stress})");
            let o = compile(insns, frame, scopes, alloc, stress).unwrap_or_else(|e| panic!("{what}: {e:?}"));
            let found = check_frames(&o, &what);
            if o.osr.is_some() {
                assert!(check_osr(&o, &o.pe_unwind, &what) > 0 || !gnu_objdump(), "{what}: no OSR entry");
            }
            check(&found, &what);
        }
    }
}

/// Sixteen values live across a call (callee-saved registers, pushed) and the Win64
/// argument registers: `f(x) = sum of (x * (i + 1) + i) * (2i + 1)`, with a call between.
#[test]
fn callee_saved_across_a_call() {
    let mut v = vec![arg(-24, 0)];
    for i in 0..16i32 {
        v.push(Insn::MulImmW64 { d: Slot(-32 - 8 * i), a: Slot(-24), imm: i as u64 + 1 });
        v.push(Insn::AddImmW64 { d: Slot(-32 - 8 * i), a: Slot(-32 - 8 * i), imm: i as u64 });
    }
    let p = [param(-24, 0), param(-32, 1), param(-40, 2), param(-48, 3)].concat();
    v.push(Insn::Call { d: Slot(-160), f: Func(0), k: 8, a: List::from_words(&p) });
    v.push(Insn::ImmW64 { d: Slot(-168), imm: 0 });
    for i in 0..16i32 {
        v.push(Insn::MulImmW64 { d: Slot(-176), a: Slot(-32 - 8 * i), imm: 2 * i as u64 + 1 });
        v.push(Insn::AddW64 { d: Slot(-168), a: Slot(-168), b: Slot(-176) });
    }
    v.push(Insn::AddW64 { d: Slot(-168), a: Slot(-168), b: Slot(-160) });
    v.push(Insn::Ret { s: Slot(-168), k: 8 });
    let mut linear = false;
    each(&v, 176, &[], "callee-saved", |f, what| {
        assert!(f.epilogues >= 1, "{what}");
        linear |= f.saves > 0 && !f.stored;
    });
    assert!(linear, "no pushed saves");
}

/// A frame of 8 KiB (a memory alloca at its bottom, escaped): the prologue probes it.
#[test]
fn probed_frame() {
    let p = param(-32, 0);
    let v = vec![
        arg(-24, 0),
        Insn::Addr { d: Slot(-32), s: Slot(-8192) },
        Insn::StoreW64 { m: Mem { p: Slot(-32), k: 0 }, s: Slot(-24) },
        Insn::Call { d: Slot(-40), f: Func(0), k: 8, a: List::from_words(&p) },
        Insn::LoadW64 { d: Slot(-48), m: Mem { p: Slot(-32), k: 0 } },
        Insn::AddW64 { d: Slot(-48), a: Slot(-48), b: Slot(-40) },
        Insn::Ret { s: Slot(-48), k: 8 },
    ];
    each(&v, 8192 + 16, &[(1, -8192, 8000, ScopeKind::Escape { align: 8 })], "probed", |f, what| {
        assert!(f.probe && f.epilogues >= 1, "{what}");
    });
}

/// A loop whose local (`size` bytes at `lo`) escapes before its head, pinned at its AOT
/// place, with a call in it: the callee-saved registers the counter and the pointer take are
/// stored, addressed from the frame base: into the caller's home space, or with a stack
/// argument read there (`home_arg`), into the slots below `rdi`'s and `rsi`'s that the
/// pinned alloca leaves free.
fn pinned_loop(lo: i32, size: u32, home_arg: bool) -> (Vec<Insn<'static>>, u32, Vec<(usize, i32, u32, ScopeKind)>) {
    let (n, pp, r, t) = (lo - 8, lo - 16, lo - 24, lo - 32);
    let frame = ((-t) as u32 + 8).next_multiple_of(16);
    let mut v = vec![
        // 0
        arg(n, 0),
        Insn::ImmW64 { d: Slot(lo), imm: 5 },
        Insn::Addr { d: Slot(pp), s: Slot(lo) },
        // 3: the head.
        Insn::BrEqImmW64 { a: Slot(n), imm: 0, neg: T, t: Target(10) },
        Insn::Call { d: Slot(r), f: Func(0), k: 8, a: List::from_words(&[]) },
        Insn::LoadW64 { d: Slot(t), m: Mem { p: Slot(pp), k: 0 } },
        Insn::AddW64 { d: Slot(t), a: Slot(t), b: Slot(r) },
        Insn::StoreW64 { m: Mem { p: Slot(pp), k: 0 }, s: Slot(t) },
        Insn::SubImmW64 { d: Slot(n), a: Slot(n), imm: 1 },
        Insn::Jmp { t: Target(3) },
        // 10
        Insn::Ret { s: Slot(lo), k: 8 },
    ];
    if home_arg {
        v[1] = Insn::MovW64 { d: Slot(lo), s: Slot(16) };
    }
    (v, frame, vec![(2, lo, size, ScopeKind::Escape { align: 8 })])
}

#[test]
fn saves_below_a_pinned_alloca() {
    for (lo, size, home_arg, want) in [(-24, 8, false, "home"), (-24, 8, true, "gap"), (-200, 184, true, "gap"), (-1000, 984, false, "home")] {
        let (v, frame, sc) = pinned_loop(lo, size, home_arg);
        let (mut stored, mut home) = (false, false);
        each(&v, frame, &sc, &format!("pinned at {lo}, home argument {home_arg}"), |f, what| {
            assert!(f.epilogues >= 1, "{what}");
            stored |= f.stored;
            home |= f.home;
        });
        assert!(stored && home == (want == "home"), "pinned at {lo}: stored {stored}, home {home}");
    }
    // Neither the home space nor two free slots below `rbp`: re-encoded.
    let (v, frame, sc) = pinned_loop(-1000, 992, true);
    let r = compile(&v, frame, &sc, Allocator::LinearScan, false);
    assert!(matches!(&r, Err(jit::Error::Unsupported(u)) if u.0.contains("room")), "{r:?}");
}

/// A tail call, after the epilogue's pops.
#[test]
fn tail_call() {
    let p = param(-24, 0);
    let v = vec![
        arg(-24, 0),
        arg(-32, 1),
        Insn::AddW64 { d: Slot(-24), a: Slot(-24), b: Slot(-32) },
        Insn::TailCall { f: Func(0), a: List::from_words(&p) },
    ];
    each(&v, 32, &[], "tail call", |f, what| assert!(f.epilogues >= 1, "{what}"));
}

/// The handlers that use `xmm6`–`xmm15` (the `i128` saturating casts) are Win64 functions,
/// which preserve them: compiled on PE like the others.
#[test]
fn xmm6_using_handlers_compiled() {
    let v = vec![arg(-24, 0), Insn::CvtF2iSatSF64W128 { d: Slot(-48), s: Slot(-24) }, Insn::Ret { s: Slot(-48), k: 8 }];
    let r = compile(&v, 48, &[], Allocator::LinearScan, false);
    assert!(r.is_ok(), "{r:?}");
}

/// Eight vectors live at once and across a call: on PE the SSA pipeline takes the SysV set,
/// `xmm0`–`xmm13` (scratch `xmm14`, `xmm15`), saving the callee-saved ones it names.
#[test]
fn vectors_save_xmm6_to_15() {
    let mut v = vec![arg(-8, 0)];
    for i in 0..8i32 {
        v.push(Insn::LoadCopy { d: Slot(-32 - 16 * i), m: Mem { p: Slot(-8), k: 16 * i }, len: 16 });
    }
    for i in 0..8i32 {
        v.push(Insn::VeqI8x16 { d: Slot(-32 - 16 * i), a: Slot(-32 - 16 * i), b: Slot(-32 - 16 * ((i + 1) % 8)) });
    }
    let p = param(-8, 0);
    v.push(Insn::Call { d: Slot(-168), f: Func(0), k: 8, a: List::from_words(&p) });
    for i in 1..8i32 {
        v.push(Insn::XorW128 { d: Slot(-32), a: Slot(-32), b: Slot(-32 - 16 * i) });
    }
    v.push(Insn::VmsbI8x16 { d: Slot(-176), a: Slot(-32) });
    v.push(Insn::ZextW16W64 { d: Slot(-184), s: Slot(-176) });
    v.push(Insn::Ret { s: Slot(-184), k: 8 });
    each(&v, 192, &[], "vectors", |f, what| assert!(f.xsaves >= 2 && f.epilogues >= 1, "{what}"));
}

/// Vectors below a pinned alloca: the `xmm` saves are stored into the 16-byte aligned slots
/// within the frame offset that the alloca leaves free.
#[test]
fn vectors_below_a_pinned_alloca() {
    let (mut v, frame, sc) = pinned_loop(-24, 8, false);
    let ret = v.pop().unwrap();
    let base = -(frame as i32) - 8;
    v.push(Insn::LoadCopy { d: Slot(base - 16), m: Mem { p: Slot(-40), k: 0 }, len: 16 });
    v.push(Insn::LoadCopy { d: Slot(base - 32), m: Mem { p: Slot(-40), k: 0 }, len: 16 });
    v.push(Insn::XorW128 { d: Slot(base - 16), a: Slot(base - 16), b: Slot(base - 32) });
    v.push(Insn::StoreCopy { m: Mem { p: Slot(-40), k: 0 }, s: Slot(base - 16), len: 16 });
    v.push(ret);
    let frame = ((-base) as u32 + 32).next_multiple_of(16);
    let mut stored = false;
    each(&v, frame, &sc, "pinned vectors", |f, what| {
        assert!(f.xsaves >= 2 && f.epilogues >= 1, "{what}");
        stored |= f.stored;
    });
    assert!(stored, "no stored saves");
}

/// The SSA pipeline doesn't lay out PE pad regions (design/vm.md#pe-seh): a function with a
/// cleanup landing pad is left to re-encoding (`Unsupported`), one with only a terminate
/// stub's (a catching pad, entered by `RtlUnwindEx` with the frame's `rsp`) compiles.
#[test]
fn cleanup_pads_go_to_reencoding() {
    use ryo_bytecode::image::{CATCH, CONTINUE, CleanupEntry};
    for catch in [false, true] {
        // 0: the call, 1: ret, 2: its landing pad, 3: resume, or a terminate stub's abort.
        let insns = [
            Insn::CallSym { d: Slot(0), sym: Sym(0), k: 0, a: List::from_words(&[]) },
            Insn::Ret { s: Slot(0), k: 0 },
            Insn::Lpad { x: Slot(-24) },
            if catch { Insn::Abort {} } else { Insn::Resume { x: Slot(-24) } },
        ];
        let mut words = Vec::new();
        let mut starts = Vec::new();
        for i in &insns {
            starts.push(words.len() as u32);
            i.encode(&mut words);
        }
        let mut cleanup = vec![CleanupEntry { offset: starts[0], target: starts[2] | if catch { CATCH } else { 0 } }];
        if !catch {
            cleanup.push(CleanupEntry { offset: starts[3], target: CONTINUE });
        }
        let enc = asm::encode(&words, 32, &cleanup, &[], PE).expect("encodes");
        assert_eq!(enc.region < enc.code.len() as u32, !catch, "a pad region");
        let d = asm::decode_reduced(&enc, PE).expect("decodes");
        let r = jit::compile(
            &d,
            &[],
            PE,
            &Options { alloc: Allocator::LinearScan, stress: false, check: true, dump: false, licm: false, rotate: false },
            None,
            None,
        );
        if catch {
            assert!(r.is_ok(), "a terminate pad compiles");
        } else {
            assert!(matches!(r, Err(jit::Error::Unsupported(ref u)) if u.0 == "PE cleanup landing pads"), "a cleanup pad doesn't");
        }
    }
}

/// Whether `/usr/bin/objdump` is GNU objdump (macOS's is LLVM's, without `-b binary`).
fn gnu_objdump() -> bool {
    static GNU: std::sync::OnceLock<bool> = std::sync::OnceLock::new();
    *GNU.get_or_init(|| {
        std::process::Command::new("/usr/bin/objdump")
            .arg("--version")
            .output()
            .is_ok_and(|o| String::from_utf8_lossy(&o.stdout).starts_with("GNU objdump"))
    })
}
