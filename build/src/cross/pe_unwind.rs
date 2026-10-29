//! The Win64 unwind information checker of `y test --cross` for windows-msvc ([`pe_unwind`]).

use std::fs;
use std::path::{Path, PathBuf};

use crate::utils::{RustcInfo, cmd};

/// Checks the Win64 unwind information of the PE outputs in `dir` (each with the
/// `<output>.map` lld wrote): in the code of the VM images (`.text$ryo_image`) and of
/// `ryo_rt`, every instruction that moves `rsp` (but `call` and `ret`) lies in a
/// `RUNTIME_FUNCTION`, or the unwinder takes its function for a leaf and reads the return
/// address from `[rsp]`; and the unwind codes of every such entry are those of the
/// instructions of its prologue; and the VM code's epilogues free the prologue's allocation.
/// Returns how many entries it checked.
pub(super) fn pe_unwind(info: &RustcInfo, dir: &Path) -> Result<usize, String> {
    let mut n = 0;
    for e in fs::read_dir(dir).map_err(|e| e.to_string())? {
        let map = e.map_err(|e| e.to_string())?.path();
        let Some(file) = map.to_str().and_then(|m| m.strip_suffix(".map")) else { continue };
        let file = PathBuf::from(file);
        if !file.exists() {
            return Err(format!("{} has no output {}", map.display(), file.display()));
        }
        n += pe_unwind_file(info, &file, &crate::utils::read(&map)?).map_err(|e| format!("{}: {e}", file.file_name().unwrap().to_string_lossy()))?;
    }
    Ok(n)
}

/// [`pe_unwind`] of one output, `file`, with lld's map `map`.
fn pe_unwind_file(info: &RustcInfo, file: &Path, map: &str) -> Result<usize, String> {
    let headers = crate::utils::output(cmd(info.tool("llvm-readobj")).arg("--file-headers").arg(file))?;
    let base = headers
        .lines()
        .find_map(|l| l.trim().strip_prefix("ImageBase: "))
        .and_then(|v| u64::from_str_radix(v.trim_start_matches("0x"), 16).ok())
        .ok_or("no ImageBase")?;
    let units = pe_units(map, base);
    if !units.iter().any(|u| u.2) {
        return Err("no VM image code in the map".to_owned());
    }
    let funcs = pe_runtime_functions(&crate::utils::output(cmd(info.tool("llvm-readobj")).arg("--unwind").arg(file))?)?;
    let dis = crate::utils::output(cmd(info.tool("llvm-objdump")).args(["-d", "--no-show-raw-insn", "--x86-asm-syntax=att"]).arg(file))?;
    let insns = pe_instructions(&dis);
    let in_units = |a: u64| units.iter().any(|&(b, e, _)| (b..e).contains(&a));
    let mut bad = Vec::new();
    // Every `rsp` move in the units is covered.
    for insn in &insns {
        if in_units(insn.addr) && moves_rsp(insn) {
            // `funcs` is sorted by start.
            let k = funcs.partition_point(|f| f.begin <= insn.addr);
            if k == 0 || funcs[k - 1].end <= insn.addr {
                bad.push(format!("{:#x}: `{} {}` moves rsp outside any RUNTIME_FUNCTION", insn.addr, insn.op, insn.args));
            }
        }
    }
    // The epilogues of VM code (`add rsp, F; pop rbp`) free what the prologue allocated: Win64
    // takes `add rsp` as undoing the prologue's `ALLOC`, and the code relies on `rsp == rbp -
    // F` there (design/vm.md#frames).
    let covering = |a: u64| {
        let k = funcs.partition_point(|f| f.begin <= a);
        (k > 0 && a < funcs[k - 1].end).then(|| &funcs[k - 1])
    };
    for w in insns.windows(2) {
        if w[1].op == "popq"
            && w[1].args == "%rbp"
            && w[0].op == "addq"
            && w[0].args.ends_with(", %rsp")
            && units.iter().any(|&(b, e, image)| image && (b..e).contains(&w[0].addr))
        {
            let alloc: u64 =
                covering(w[0].addr).map_or(0, |f| f.codes.iter().filter_map(|(_, c)| c.strip_prefix("alloc ")?.parse::<u64>().ok()).sum());
            if parse_imm(w[0].args.split(',').next().unwrap()) != Some(alloc) {
                bad.push(format!("{:#x}: epilogue `addq {}` doesn't free the prologue's {alloc} bytes", w[0].addr, w[0].args));
            }
        }
    }
    let mut n = 0;
    for f in funcs.iter().filter(|f| in_units(f.begin) && !f.chained) {
        n += 1;
        let start = insns.partition_point(|i| i.addr < f.begin);
        let mut want = Vec::new();
        let mut eax = None;
        for (k, insn) in insns[start..].iter().enumerate() {
            if insn.addr >= f.begin + u64::from(f.prolog) {
                break;
            }
            let Some(next) = insns.get(start + k + 1) else { break };
            let off = (next.addr - f.begin) as u32;
            if insn.op.starts_with("movl") && insn.args.ends_with(", %eax") {
                eax = parse_imm(insn.args.split(',').next().unwrap());
            }
            if let Some(code) = prologue_code(insn, eax) {
                want.push((off, code));
            }
        }
        let mut got = f.codes.clone();
        want.sort();
        got.sort();
        if want != got {
            bad.push(format!("{:#x}: unwind codes {got:?}, but the prologue is {want:?}", f.begin));
        }
    }
    if !bad.is_empty() {
        bad.truncate(20);
        return Err(format!("unwind information:\n{}", bad.join("\n")));
    }
    Ok(n)
}

/// The code ranges [`pe_unwind`] checks, as virtual addresses, from lld's map (`/lldmap`:
/// `<rva> <size> <align>` and the output section, then its input sections, `<file>:(<name>)`,
/// then their symbols), with whether each is a VM image's.
fn pe_units(map: &str, base: u64) -> Vec<(u64, u64, bool)> {
    let mut units = Vec::new();
    for l in map.lines().skip(1) {
        let mut it = l.split_whitespace();
        let (Some(addr), Some(size), Some(_), Some(input), None) = (it.next(), it.next(), it.next(), it.next(), it.next()) else { continue };
        let Some((path, section)) = input.rsplit_once(":(") else { continue };
        let (Ok(addr), Ok(size)) = (u64::from_str_radix(addr, 16), u64::from_str_radix(size, 16)) else { continue };
        let section = section.trim_end_matches(')');
        let name = path.rsplit(['/', '\\']).next().unwrap_or(path);
        let image = section == ".text$ryo_image";
        if size > 0 && (image || (section.starts_with(".text") && name.starts_with("ryo_rt-"))) {
            units.push((base + addr, base + addr + size, image));
        }
    }
    units
}

/// One `RUNTIME_FUNCTION` with its `UNWIND_INFO`, the codes as [`prologue_code`] names them.
struct RuntimeFunction {
    begin: u64,
    end: u64,
    prolog: u8,
    chained: bool,
    codes: Vec<(u32, String)>,
}

/// The entries `llvm-readobj --unwind` prints, sorted by start.
fn pe_runtime_functions(dump: &str) -> Result<Vec<RuntimeFunction>, String> {
    let addr = |l: &str| l.rsplit_once("(0x").and_then(|(_, a)| u64::from_str_radix(a.trim_end_matches(')'), 16).ok());
    let mut funcs: Vec<RuntimeFunction> = Vec::new();
    for l in dump.lines().map(str::trim) {
        if l.starts_with("RuntimeFunction {") {
            funcs.push(RuntimeFunction { begin: 0, end: 0, prolog: 0, chained: false, codes: Vec::new() });
        }
        let Some(f) = funcs.last_mut() else { continue };
        if let Some(v) = l.strip_prefix("StartAddress: ") {
            f.begin = addr(v).ok_or_else(|| format!("bad line `{l}`"))?;
        } else if let Some(v) = l.strip_prefix("EndAddress: ") {
            f.end = addr(v).ok_or_else(|| format!("bad line `{l}`"))?;
        } else if let Some(v) = l.strip_prefix("PrologSize: ") {
            f.prolog = v.parse().map_err(|_| format!("bad line `{l}`"))?;
        } else if l.starts_with("ChainInfo") {
            f.chained = true;
        } else if let Some((off, code)) = l.split_once(": ")
            && let Some(off) = off.strip_prefix("0x").and_then(|o| u32::from_str_radix(o, 16).ok())
        {
            f.codes.push((off, unwind_code(code)));
        }
    }
    funcs.sort_by_key(|f| f.begin);
    Ok(funcs)
}

/// An unwind code as `llvm-readobj` prints it (`PUSH_NONVOL reg=RBP`), in [`prologue_code`]'s
/// form; an unknown one as it is.
fn unwind_code(code: &str) -> String {
    let field = |k: &str| code.split([' ', ',']).find_map(|w| w.strip_prefix(k)).unwrap_or("");
    let num = |v: &str| v.strip_prefix("0x").map_or_else(|| v.parse().ok(), |h| u64::from_str_radix(h, 16).ok()).unwrap_or(u64::MAX);
    let reg = field("reg=").to_ascii_lowercase();
    match code.split_whitespace().next().unwrap_or("") {
        "PUSH_NONVOL" => format!("push {reg}"),
        "ALLOC_SMALL" | "ALLOC_LARGE" => format!("alloc {}", num(field("size="))),
        "SET_FPREG" => format!("setfp {reg} {}", num(field("offset="))),
        "SAVE_NONVOL" | "SAVE_NONVOL_FAR" => format!("save {reg} {}", num(field("offset="))),
        "SAVE_XMM128" | "SAVE_XMM128_FAR" => format!("savexmm {reg} {}", num(field("offset="))),
        _ => code.to_owned(),
    }
}

/// An instruction of `llvm-objdump -d --no-show-raw-insn` (AT&T).
struct Insn<'a> {
    addr: u64,
    op: &'a str,
    args: &'a str,
}

fn pe_instructions(dis: &str) -> Vec<Insn<'_>> {
    dis.lines()
        .filter_map(|l| {
            let (addr, rest) = l.trim_start().split_once(':')?;
            let addr = u64::from_str_radix(addr, 16).ok()?;
            let rest = rest.trim();
            let (op, args) = rest.split_once(char::is_whitespace).unwrap_or((rest, ""));
            Some(Insn { addr, op, args: args.split('#').next().unwrap().trim() })
        })
        .collect()
}

/// Whether `insn` writes `rsp`, other than as a call or a return does.
fn moves_rsp(insn: &Insn<'_>) -> bool {
    insn.op.starts_with("push")
        || (insn.op.starts_with("pop") && !insn.op.starts_with("popcnt"))
        || (insn.args.ends_with("%rsp") && !insn.op.starts_with("cmp") && !insn.op.starts_with("test"))
}

/// The registers Win64 callee-saved.
const NONVOLATILE: [&str; 8] = ["rbx", "rbp", "rdi", "rsi", "r12", "r13", "r14", "r15"];

/// `$0x28` or `0x28(...)` / `-0x10(...)`.
fn parse_imm(s: &str) -> Option<u64> {
    let s = s.trim().trim_start_matches('$');
    let s = s.split('(').next()?;
    if s.is_empty() {
        return Some(0);
    }
    let (neg, s) = s.strip_prefix('-').map_or((false, s), |s| (true, s));
    let v = s.strip_prefix("0x").map_or_else(|| s.parse().ok(), |h| u64::from_str_radix(h, 16).ok())?;
    Some(if neg { v.wrapping_neg() } else { v })
}

/// The unwind code a prologue instruction needs, in [`unwind_code`]'s form, or `None` if it
/// needs none. `eax` is the value last moved to `eax` (`__chkstk`'s size, for a `sub rsp, rax`).
fn prologue_code(insn: &Insn<'_>, eax: Option<u64>) -> Option<String> {
    let (src, dst) = insn.args.rsplit_once(", ").unwrap_or((insn.args, ""));
    let reg = |r: &str| r.strip_prefix('%').map(str::to_owned);
    match insn.op {
        "pushq" => {
            let r = reg(src)?;
            Some(if NONVOLATILE.contains(&r.as_str()) { format!("push {r}") } else { "alloc 8".to_owned() })
        }
        "subq" if dst == "%rsp" => Some(format!("alloc {}", if src == "%rax" { eax? } else { parse_imm(src)? })),
        "movq" if src == "%rsp" && dst == "%rbp" => Some("setfp rbp 0".to_owned()),
        "leaq" if dst == "%rbp" && src.ends_with("(%rsp)") => Some(format!("setfp rbp {}", parse_imm(src)?)),
        "movq" if dst.ends_with("(%rsp)") => {
            let r = reg(src)?;
            NONVOLATILE.contains(&r.as_str()).then(|| format!("save {r} {}", parse_imm(dst).unwrap_or(u64::MAX)))
        }
        "movaps" | "movups" | "movdqa" | "movdqu" if dst.ends_with("(%rsp)") => {
            let r = reg(src)?;
            let n: u32 = r.strip_prefix("xmm")?.parse().ok()?;
            (n >= 6).then(|| format!("savexmm {r} {}", parse_imm(dst).unwrap_or(u64::MAX)))
        }
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    /// [`super::pe_unwind_file`]'s parts on excerpts of lld's map, `llvm-readobj --unwind` and
    /// `llvm-objdump -d`: a VM function whose codes match its prologue, a stub that pushes
    /// without an entry (as `ryo_probe_stack` once did), and an entry whose codes don't match.
    #[test]
    fn checks_pe_unwind() {
        use super::*;
        let map = "Address  Size     Align Out     In      Symbol\n\
                   00001000 00000100  4096 .text\n\
                   00001000 00000020    16         ryo_rt-1.ryo_rt.0-cgu.0.rcgu.o:(.text)\n\
                   00001000 00000000     0                 __rustc::ryo_probe_stack\n\
                   00001040 00000040    16         /x/a.ryo_image.rcgu.o:(.text$ryo_image)\n\
                   00001080 00000040    16         /x/std.o:(.text)\n";
        let units = pe_units(map, 0x1_4000_0000);
        assert_eq!(units, [(0x1_4000_1000, 0x1_4000_1020, false), (0x1_4000_1040, 0x1_4000_1080, true)]);
        let dis = "0000000140001000 <.text>:\n\
                   140001000:     \tpushq\t%rax\n\
                   140001001:     \ttestq\t%r11, (%r11)\n\
                   140001004:     \tpopq\t%rax\n\
                   140001005:     \tretq\n\
                   140001040:     \tpushq\t%rbp\n\
                   140001041:     \tmovq\t%rsp, %rbp\n\
                   140001044:     \tmovl\t$0x1000, %eax\n\
                   140001049:     \tcallq\t0x140001000 <.text>\n\
                   14000104e:     \tsubq\t$0x70, %rsp\n\
                   140001052:     \tmovaps\t%xmm6, 0x10(%rsp)\n\
                   140001057:     \tmovq\t%rcx, -0x40(%rbp)\n\
                   14000105b:     \taddq\t$0x70, %rsp\n\
                   14000105f:     \tpopq\t%rbp\n\
                   140001060:     \tretq\n";
        let insns = pe_instructions(dis);
        assert_eq!(insns.len(), 14);
        assert!(moves_rsp(&insns[0]) && !moves_rsp(&insns[1]) && moves_rsp(&insns[8]) && !moves_rsp(&insns[7]));
        let codes: Vec<_> = insns[4..10].iter().filter_map(|i| prologue_code(i, None)).collect();
        assert_eq!(codes, ["push rbp", "setfp rbp 0", "alloc 112", "savexmm xmm6 16"]);
        let unwind = "UnwindInformation [\n  RuntimeFunction {\n    StartAddress: (0x140001040)\n    EndAddress: (0x140001061)\n\
                      UnwindInfo {\n      PrologSize: 23\n      UnwindCodes [\n        0x17: SAVE_XMM128 reg=XMM6, offset=0x10\n\
                      0x12: ALLOC_SMALL size=112\n        0x04: SET_FPREG reg=RBP, offset=0x0\n        0x01: PUSH_NONVOL reg=RBP\n      ]\n    }\n  }\n]\n";
        let funcs = pe_runtime_functions(unwind).unwrap();
        assert_eq!(funcs.len(), 1);
        assert_eq!((funcs[0].begin, funcs[0].end, funcs[0].prolog), (0x1_4000_1040, 0x1_4000_1061, 23));
        let mut got = funcs[0].codes.clone();
        got.sort();
        let want: Vec<(u32, String)> =
            [(1, "push rbp"), (4, "setfp rbp 0"), (0x12, "alloc 112"), (0x17, "savexmm xmm6 16")].map(|(o, c)| (o, c.to_owned())).into();
        assert_eq!(got, want);
        assert_eq!(unwind_code("SAVE_NONVOL reg=RSI, offset=0x8"), "save rsi 8");
        assert_eq!(prologue_code(&Insn { addr: 0, op: "subq", args: "%rax, %rsp" }, Some(0x2000)).as_deref(), Some("alloc 8192"));
        assert_eq!(prologue_code(&Insn { addr: 0, op: "pushq", args: "%rax" }, None).as_deref(), Some("alloc 8"));
        assert_eq!(prologue_code(&Insn { addr: 0, op: "movq", args: "%rcx, 0x8(%rsp)" }, None), None);
    }
}
