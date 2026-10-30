//! The handlers against the Lean operation semantics (`lean/Ryo/Vm/OpSem`, reduced.md
//! "Validating `opSem`"): every opcode with a Rust handler, on random canary frames and a
//! random memory buffer, run by `ryo-lean opsem` and then, unless Lean says the operation
//! has no next state (UB, a trap), by the handler. The frame, the memory and the returned
//! value must agree, and every frame byte the handler changed must be in the footprint's
//! writes.
//!
//! Skipped (with a message) without the `ryo-lean` binary: `RYO_LEAN`, else
//! `lean/.lake/build/bin/ryo-lean` (`cd lean && lake build`).

#![cfg(all(target_arch = "x86_64", any(target_os = "linux", target_vendor = "apple")))]

use std::io::{BufRead, BufReader, Write};
use std::process::{Child, ChildStdin, ChildStdout, Command, Stdio};

use ryo_bytecode::asm::layout;
use ryo_bytecode::full::{ElemKind, OperandKind};
use ryo_bytecode::{ALL_OPCODES, Opcode};
use ryo_rt::vm::{MODE, handler};

/// Calls `f(a0..a5)` with `rbp = fp`, returning `rax`.
#[cfg(not(windows))]
#[unsafe(naked)]
extern "sysv64" fn call_with_fp(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, fp: *mut u8, f: *const ()) -> u64 {
    core::arch::naked_asm!("push rbp", "mov rbp, [rsp + 16]", "call qword ptr [rsp + 24]", "pop rbp", "ret");
}

/// Calls the Win64 handler `f(a0..a5)` with `rbp = fp`, returning `rax`: `a4` and `a5` again
/// past the callee's shadow space.
#[cfg(windows)]
#[unsafe(naked)]
extern "win64" fn call_with_fp(a0: u64, a1: u64, a2: u64, a3: u64, a4: u64, a5: u64, fp: *mut u8, f: *const ()) -> u64 {
    core::arch::naked_asm!(
        "push rbp",
        "mov rbp, [rsp + 64]",
        "sub rsp, 48",
        "mov rax, [rsp + 96]",
        "mov [rsp + 32], rax",
        "mov rax, [rsp + 104]",
        "mov [rsp + 40], rax",
        "call qword ptr [rsp + 120]",
        "add rsp, 48",
        "pop rbp",
        "ret"
    );
}

/// Calls `op`'s handler with `vals` (one per operand, in operand order; a memory operand
/// `slot | k << 64`) on frame `fp`, with `exception` in the register before the operands.
fn call(op: Opcode, vals: &[u128], fp: *mut u8, exception: u64) -> u64 {
    let l = layout(op, MODE);
    let mut r = [0u64; 6];
    if op.info().shape == ryo_bytecode::full::Shape::Lpad {
        r[l.first as usize - 1] = exception;
    }
    if MODE.fp_arg {
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
    fn wide(&mut self) -> u128 {
        self.next() as u128 | (self.next() as u128) << 64
    }
}

// ---- a minimal JSON reader for `ryo-lean opsem`'s output ----

#[derive(Debug, Clone)]
enum J {
    Null,
    Bool(bool),
    Num(i128),
    Str(String),
    Arr(Vec<J>),
    Obj(Vec<(String, J)>),
}

impl J {
    fn get(&self, k: &str) -> Option<&J> {
        match self {
            J::Obj(fs) => fs.iter().find(|(n, _)| n == k).map(|(_, v)| v),
            _ => None,
        }
    }
    fn arr(&self) -> &[J] {
        match self {
            J::Arr(a) => a,
            _ => panic!("not an array: {self:?}"),
        }
    }
    fn num(&self) -> i128 {
        match self {
            J::Num(n) => *n,
            _ => panic!("not a number: {self:?}"),
        }
    }
    /// A frame or memory byte: its data (a provenance fragment ignored), `None` for `Uninit`.
    fn byte(&self) -> Option<u8> {
        match self {
            J::Null => None,
            J::Num(n) => Some(*n as u8),
            J::Arr(a) => Some(a[0].num() as u8),
            _ => panic!("not a byte: {self:?}"),
        }
    }
}

fn parse(s: &[u8], i: &mut usize) -> J {
    while s[*i] == b' ' {
        *i += 1;
    }
    match s[*i] {
        b'n' => {
            *i += 4;
            J::Null
        }
        b't' => {
            *i += 4;
            J::Bool(true)
        }
        b'f' => {
            *i += 5;
            J::Bool(false)
        }
        b'"' => {
            *i += 1;
            let start = *i;
            while s[*i] != b'"' {
                *i += if s[*i] == b'\\' { 2 } else { 1 };
            }
            *i += 1;
            J::Str(String::from_utf8_lossy(&s[start..*i - 1]).into_owned())
        }
        b'[' => {
            *i += 1;
            let mut v = Vec::new();
            loop {
                if s[*i] == b']' {
                    *i += 1;
                    return J::Arr(v);
                }
                v.push(parse(s, i));
                if s[*i] == b',' {
                    *i += 1;
                }
            }
        }
        b'{' => {
            *i += 1;
            let mut v = Vec::new();
            loop {
                if s[*i] == b'}' {
                    *i += 1;
                    return J::Obj(v);
                }
                let J::Str(k) = parse(s, i) else { panic!("object key") };
                assert_eq!(s[*i], b':');
                *i += 1;
                v.push((k, parse(s, i)));
                if s[*i] == b',' {
                    *i += 1;
                }
            }
        }
        _ => {
            let start = *i;
            while *i < s.len() && (s[*i] == b'-' || s[*i].is_ascii_digit()) {
                *i += 1;
            }
            J::Num(std::str::from_utf8(&s[start..*i]).unwrap().parse().unwrap())
        }
    }
}

struct Lean {
    _child: Child,
    stdin: ChildStdin,
    stdout: BufReader<ChildStdout>,
}

impl Lean {
    fn start() -> Option<Lean> {
        let path =
            std::env::var("RYO_LEAN").unwrap_or_else(|_| concat!(env!("CARGO_MANIFEST_DIR"), "/../../lean/.lake/build/bin/ryo-lean").to_string());
        if !std::path::Path::new(&path).exists() {
            eprintln!("lean_opsem: skipped, no ryo-lean binary at {path} (set RYO_LEAN or `lake build` in lean/)");
            return None;
        }
        let mut child = Command::new(&path).arg("opsem").stdin(Stdio::piped()).stdout(Stdio::piped()).spawn().expect("ryo-lean opsem");
        let stdin = child.stdin.take().unwrap();
        let stdout = BufReader::new(child.stdout.take().unwrap());
        Some(Lean { _child: child, stdin, stdout })
    }
    fn ask(&mut self, req: &str) -> J {
        writeln!(self.stdin, "{req}").unwrap();
        self.stdin.flush().unwrap();
        let mut line = String::new();
        self.stdout.read_line(&mut line).unwrap();
        let mut i = 0;
        parse(line.trim().as_bytes(), &mut i)
    }
}

fn bytes_json(b: &[u8]) -> String {
    let v: Vec<String> = b.iter().map(|x| x.to_string()).collect();
    format!("[{}]", v.join(","))
}

/// The frame: `fp` at `FP` of `FRAME` bytes; slots in `[-224, -32]`.
const FRAME: usize = 512;
const FP: usize = 256;
/// The memory buffer pointers point into.
const MEM: usize = 256;

#[repr(C, align(16))]
struct Buf<const N: usize>([u8; N]);

/// The width of a mnemonic's `wN` part, or of its last `fN` part.
fn mn_width(mn: &str) -> usize {
    let parts: Vec<&str> = mn.split('.').collect();
    if let Some(w) = parts.iter().find_map(|p| p.strip_prefix('w').and_then(|n| n.parse::<usize>().ok())) {
        return w / 8;
    }
    parts.iter().rev().find_map(|p| p.strip_prefix('f').and_then(|n| n.parse::<usize>().ok())).map_or(8, |w| w / 8)
}

/// One random case of `op`: returns whether the handler ran.
fn case(lean: &mut Lean, op: Opcode, rng: &mut Rng) -> bool {
    let info = op.info();
    let mn = op.mnemonic();
    let w = mn_width(mn);
    let mut frame = Box::new(Buf::<FRAME>([0; FRAME]));
    let mut mem = Box::new(Buf::<MEM>([0; MEM]));
    for b in frame.0.iter_mut() {
        *b = rng.next() as u8;
    }
    for b in mem.0.iter_mut() {
        *b = rng.next() as u8;
    }
    let fp = unsafe { frame.0.as_mut_ptr().add(FP) };
    let mbase = mem.0.as_mut_ptr() as u64;
    // A pointer into the buffer, aligned to `align`, with `room` bytes after it.
    let ptr_into = |rng: &mut Rng, align: u64, room: u64| mbase + rng.below((MEM as u64 - room) / align) * align;
    let mut vals: Vec<u128> = Vec::new();
    let mut lean_ops: Vec<String> = Vec::new();
    // Slots: pointer slots in distinct 16-byte cells, the others anywhere in the slot area.
    let mut cells: Vec<i32> = (2..=14).map(|c| -16 * c).collect();
    let mut ptr_slots: Vec<(i32, u64)> = Vec::new();
    let atomic = mn.starts_with("atomic.");
    for o in info.operands {
        let (v, j) = match o.kind {
            OperandKind::Slot | OperandKind::Mem => {
                let is_ptr = o.kind == OperandKind::Mem || matches!(o.name, "p" | "dp" | "sp");
                let s = if is_ptr || o.name == "n" {
                    let c = rng.below(cells.len() as u64) as usize;
                    cells.remove(c)
                } else {
                    -32 - rng.below(193) as i32
                };
                if is_ptr {
                    let align = if atomic { w as u64 } else { 1 };
                    ptr_slots.push((s, ptr_into(rng, align, 32)));
                }
                if o.name == "n" {
                    ptr_slots.push((s, rng.below(33)));
                }
                if o.kind == OperandKind::Mem {
                    let k = rng.below(17) as i32 - 8;
                    // The pointer points 8 bytes in, so `[p + k]` stays in the buffer.
                    ptr_slots.last_mut().unwrap().1 += 8;
                    ((s as u32 as u128) | (k as u32 as u128) << 64, format!("{{\"mem\":[{s},{k}]}}"))
                } else {
                    (s as u32 as u128, format!("{{\"slot\":{s}}}"))
                }
            }
            OperandKind::U8 | OperandKind::U16 | OperandKind::U32 | OperandKind::U64 | OperandKind::I64 | OperandKind::U128 => {
                let bits = match o.kind {
                    OperandKind::U8 => 8,
                    OperandKind::U16 => 16,
                    OperandKind::U32 => 32,
                    OperandKind::U128 => 128,
                    _ => 64,
                };
                let v = match o.name {
                    "len" => rng.below(17) as u128,
                    "elem_size" => rng.below(9) as u128,
                    "count" => rng.below(5) as u128,
                    "variants_start" | "variants_end" | "variant" | "untagged" => rng.below(6) as u128,
                    _ if rng.below(4) == 0 => rng.below(8) as u128,
                    _ => rng.wide(),
                };
                let v = if bits == 128 { v } else { v & ((1u128 << bits) - 1) };
                (v, format!("{{\"imm\":\"{v}\"}}"))
            }
            OperandKind::Const | OperandKind::Abs | OperandKind::Sym => {
                let p = ptr_into(rng, 8, 40);
                (p as u128, format!("{{\"addr\":{p}}}"))
            }
            OperandKind::List(ElemKind::Target) => {
                let n = rng.below(6);
                (n as u128, format!("{{\"targets\":{n}}}"))
            }
            OperandKind::List(_) => {
                let n = rng.below(7);
                let p = ptr_into(rng, 16, 16 * 7);
                (p as u128 | (n as u128) << 64, format!("{{\"cases\":[{p},{n}]}}"))
            }
            _ => (0, "null".to_string()),
        };
        vals.push(v);
        lean_ops.push(j);
    }
    for &(s, p) in &ptr_slots {
        unsafe { fp.offset(s as isize).cast::<u64>().write_unaligned(p) };
    }
    // A compare-exchange's `old`: half the time the value in memory.
    if mn.starts_with("atomic.cxchg") && rng.below(2) == 0 {
        let p = ptr_slots[0].1 as *const u8;
        let old = info.operand_index("old").unwrap();
        let s = vals[old] as u32 as i32;
        unsafe { std::ptr::copy_nonoverlapping(p, fp.offset(s as isize), w) };
    }
    let exception = rng.next();
    let frame0 = frame.0;
    let mem0 = mem.0;
    let frame_addr = frame.0.as_ptr() as u64;
    let escape = rng.below(2) == 0 || mn == "addr";
    let (allocs, escaped) = if escape {
        (
            format!(",{{\"addr\":{frame_addr},\"bytes\":{}}}", bytes_json(&frame0)),
            format!(",\"escaped\":[{{\"off\":-{FP},\"size\":{FRAME},\"alloc\":1}}]"),
        )
    } else {
        (String::new(), String::new())
    };
    let req = |choice: &str| {
        format!(
            "{{\"op\":\"{mn}\",\"ops\":[{}],\"frame\":{{\"base\":-{FP},\"bytes\":{}}},\"allocs\":[{{\"addr\":{mbase},\"bytes\":{}}}{allocs}]{escaped},\"exception\":{exception}{choice}}}",
            lean_ops.join(","),
            bytes_json(&frame0),
            bytes_json(&mem0)
        )
    };
    let r = lean.ask(&req(""));
    if r.get("error").is_some() {
        panic!("{mn}: ryo-lean: {r:?}\n{}", req(""));
    }
    if let Some(stop) = r.get("stop") {
        let J::Str(stop) = stop else { panic!() };
        assert!(matches!(stop.as_str(), "ub" | "unreachable" | "abort"), "{mn}: {r:?}\n{}", req(""));
        return false;
    }
    let ret = call(op, &vals, fp, exception);
    // Compare with Lean's result; for a float result also under the handler's NaN bits and
    // either zero sign.
    let check = |r: &J| -> Result<(), String> {
        let ok = r.get("ok").ok_or_else(|| format!("{r:?}"))?;
        let lf = ok.get("frame").unwrap().arr();
        for (i, b) in lf.iter().enumerate() {
            if b.byte() != Some(frame.0[i]) {
                return Err(format!("frame byte at {}: lean {:?}, handler {}", i as i64 - FP as i64, b.byte(), frame.0[i]));
            }
        }
        let lm = ok.get("allocs").unwrap().arr()[0].arr();
        for (i, b) in lm.iter().enumerate() {
            if b.byte() != Some(mem.0[i]) {
                return Err(format!("memory byte {i}: lean {:?}, handler {}", b.byte(), mem.0[i]));
            }
        }
        match ok.get("control").unwrap() {
            J::Str(s) if s == "next" => {}
            c => {
                if let Some(J::Bool(b)) = c.get("branch") {
                    if (ret as u8 != 0) != *b {
                        return Err(format!("branch: lean {b}, handler {}", ret as u8));
                    }
                } else if let Some(J::Num(i)) = c.get("index") {
                    if ret as i128 != *i {
                        return Err(format!("index: lean {i}, handler {ret}"));
                    }
                } else {
                    return Err(format!("control {c:?}"));
                }
            }
        }
        Ok(())
    };
    let mut res = check(&r);
    if res.is_err() && (mn.starts_with('f') || mn.starts_with("copysign") || mn.starts_with("cvt.f2f") || mn.starts_with("cvt.i2f")) {
        let d = vals[info.operand_index("d").unwrap()] as u32 as i32;
        let mut bits = [0u8; 8];
        bits[..w.min(8)].copy_from_slice(&frame.0[(FP as i32 + d) as usize..][..w.min(8)]);
        let nan = u64::from_le_bytes(bits);
        for pick_y in [false, true] {
            let r2 = lean.ask(&req(&format!(",\"choice\":{{\"nan\":{nan},\"pick_y\":{pick_y}}}")));
            if r2.get("ok").is_some() && check(&r2).is_ok() {
                res = Ok(());
                break;
            }
        }
    }
    if let Err(e) = res {
        panic!("{mn}: {e}\nrequest: {}\nlean: {r:?}", req(""));
    }
    // Every frame byte the handler changed is in the footprint's writes.
    let writes: Vec<(i128, i128)> = r.get("writes").unwrap().arr().iter().map(|w| (w.arr()[0].num(), w.arr()[1].num())).collect();
    for i in 0..FRAME {
        if frame.0[i] != frame0[i] {
            let o = i as i128 - FP as i128;
            assert!(writes.iter().any(|&(s, n)| s <= o && o < s + n), "{mn}: wrote frame byte {o} outside its footprint {writes:?}");
        }
    }
    true
}

#[test]
fn handlers_match_lean_opsem() {
    let Some(mut lean) = Lean::start() else { return };
    let mut rng = Rng(0x9e37_79b9_7f4a_7c15);
    let iters: usize = std::env::var("RYO_LEAN_OPSEM_ITERS").ok().and_then(|s| s.parse().ok()).unwrap_or(24);
    let mut never = Vec::new();
    let (mut ops, mut total) = (0, 0);
    for &op in ALL_OPCODES.iter() {
        if handler(op).is_none() || matches!(op, Opcode::Resume | Opcode::Abort) {
            continue;
        }
        let ran = (0..iters).filter(|_| case(&mut lean, op, &mut rng)).count();
        if ran == 0 {
            never.push(op.mnemonic());
        }
        ops += 1;
        total += ran;
    }
    eprintln!("lean_opsem: {ops} opcodes, {total} of {} cases ran the handler", ops * iters);
    // Lean finds UB in every random case of these (e.g. `addr.sym.ind` through a random
    // pointer); everything else ran.
    assert!(never.iter().all(|m| ["addr.sym.ind"].contains(m)), "never ran: {never:?}");
}
