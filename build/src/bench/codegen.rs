//! `y bench codegen`: the backend's and the JIT's code for each bench program, as text under
//! `bench/codegen/` (the dumps renamed and the machine code disassembled).

use std::collections::HashMap;
use std::fmt::Write;
use std::fs;
use std::path::Path;
use std::process::Stdio;

use super::{PROGRAMS, path_str};
use crate::utils::{cmd, exe_name, root};

/// The header of `<program>.native.txt`.
const NATIVE_HEADER: &str = "\
# What stays native (compiled by cg_llvm) in the program's crate, and its VM functions' islands
# (RYO_DUMP_NATIVE). Only the program's crate is compiled by ryo here: std, core and alloc come
# precompiled from the LLVM sysroot, so their functions appear only as instances (generic or
# inline) codegened in the program's crate. `[local]` marks the program's own code.

";

/// `y bench codegen` (design/build.md#test-and-bench): compiles each program with `rustc-ryo`
/// and `RYO_DUMP`/`RYO_DUMP_CODE`, writing what the backend generated to
/// `bench/codegen/<name>.txt` (VM instructions), `bench/codegen/<name>.s` (x86) and, with
/// `RYO_DUMP_NATIVE`, `bench/codegen/<name>.native.txt` (what stays native), then runs
/// it, writing the JIT's code and IR ([`jit_dumps`]) to `bench/codegen/<name>.jit*`.
pub fn codegen() -> Result<(), String> {
    let root = root();
    let rustc_ryo = crate::utils::require_dist(&root)?;
    let dump_dir = root.join("bench").join("codegen");
    let out = root.join("target").join("bench-codegen");
    for dir in [&dump_dir, &out] {
        crate::utils::create_dir(dir)?;
    }
    for &program in PROGRAMS {
        let src = root.join("bench").join(format!("{program}.rs"));
        let dump = dump_dir.join(format!("{program}.txt"));
        let mut c = cmd(&rustc_ryo);
        c.args(["--edition=2024", &path_str(&src)?, "-o", &path_str(&out.join(exe_name(program)))?]);
        // One image, as the benchmarks build (`bench`'s `DEV_FLAGS`), whatever rustc's
        // default codegen units.
        c.arg("-Ccodegen-units=1");
        // Paths relative to the repository, so the dumps don't depend on where it is.
        c.arg(format!("--remap-path-prefix={}{}=", path_str(&root)?, std::path::MAIN_SEPARATOR));
        let code = out.join(format!("{program}.code"));
        c.env("RYO_DUMP", &dump);
        c.env("RYO_DUMP_CODE", &code);
        let native = out.join(format!("{program}.native"));
        c.env("RYO_DUMP_NATIVE", &native);
        eprintln!("[y] bench codegen {program}: {}", dump.display());
        crate::utils::run(&mut c)?;
        let native = crate::utils::read(&native)?;
        crate::utils::write(&dump_dir.join(format!("{program}.native.txt")), format!("{NATIVE_HEADER}{native}"))?;
        let code = crate::utils::read(&code)?;
        let s = dump_dir.join(format!("{program}.s"));
        crate::utils::write(&s, disassemble(&code)?)?;
        let jit = out.join(format!("{program}.jit"));
        eprintln!("[y] bench codegen {program}: JIT, {}", jit.display());
        for (name, text) in jit_dumps(&out.join(exe_name(program)), &jit, &code)? {
            let f = dump_dir.join(format!("{program}.{name}"));
            crate::utils::write(&f, text)?;
        }
    }
    Ok(())
}

/// The image references the JIT dumps name, as the SSA IR's Debug spelling and the name's
/// prefix (`Func(Func(8))`, `fn8`).
const IMAGE_REFS: [(&str, &str); 4] = [("Func(Func(", "fn"), ("Sym(Sym(", "sym"), ("Const(Const(", "k"), ("Data(Data(", "data")];

/// Whether `name` is an image reference as the code dumps name it (`fn8`, `sym2`, ..).
fn is_image_ref(name: &str) -> bool {
    IMAGE_REFS.iter().any(|(_, p)| name.strip_prefix(p).is_some_and(|n| !n.is_empty() && digits(n) == n.len()))
}

/// The number of ASCII digits `s` starts with.
fn digits(s: &str) -> usize {
    s.bytes().take_while(u8::is_ascii_digit).count()
}

/// `ir` with the image's references that the IR prints as `Func(Func(8))` named as the
/// function's code names them (`local("fn8")`, `fn2`).
fn local_names(ir: &str, local: &dyn Fn(&str) -> String) -> String {
    let mut out = String::new();
    let mut rest = ir;
    'scan: while !rest.is_empty() {
        for (debug, name) in IMAGE_REFS {
            if let Some(after) = rest.strip_prefix(debug) {
                let n = digits(after);
                if n > 0 && after[n..].starts_with("))") {
                    out.push_str(&local(&format!("{name}{}", &after[..n])));
                    rest = &after[n + 2..];
                    continue 'scan;
                }
            }
        }
        let c = rest.chars().next().unwrap();
        out.push(c);
        rest = &rest[c.len_utf8()..];
    }
    out
}

/// Runs `exe` with the JIT compiling synchronously at its default threshold, so that what it
/// compiles doesn't depend on timing, and its code dumped to `dir` (`RYO_JIT_DUMP`), and
/// gives the dump files' names and contents from the `RYO_JIT_DUMP` files and the image's
/// names in `RYO_DUMP_CODE`'s text `aot`: `jit.s`, the code of each function the JIT
/// compiled (by path, as the AOT code), its references named as there; `jit-ssa-pre.txt` and
/// `jit-ssa-post.txt`, the SSA tier's IR as construction leaves it and as register
/// allocation gets it, after the folds.
fn jit_dumps(exe: &Path, dir: &Path, aot: &str) -> Result<Vec<(&'static str, String)>, String> {
    crate::utils::remove_dir_if_exists(dir)?;
    crate::utils::create_dir(dir)?;
    let mut c = cmd(exe);
    for (k, _) in std::env::vars_os() {
        if k.to_string_lossy().starts_with("RYO_JIT") {
            c.env_remove(k);
        }
    }
    c.env("RYO_JIT_SYNC", "1").env("RYO_JIT_OPT", "ssa").env("RYO_JIT_DUMP", dir).stdout(Stdio::null());
    crate::utils::run(&mut c)?;

    let names = AotNames::parse(aot)?;
    let read = |f: &str| crate::utils::read(dir.join(f));
    let (mut code, mut pre, mut post) = (String::new(), String::new(), String::new());
    for (path, f, stem) in &jit_functions(dir, &names)? {
        let text = read(&format!("{stem}.code"))?;
        let local_ref = |g: &str| names.local(*f, g);
        // The retargeted callees, by the function operands the code and the IR call them by:
        // the caller's name, `.slot` through a call slot and `.far` through `r11`.
        let exts: HashMap<&str, String> = text
            .lines()
            .filter_map(|l| {
                let mut w = l.strip_prefix("ext ")?.split(' ');
                let (op, form, name) = (w.next()?, w.next()?, w.next()?);
                let suffix = match form {
                    "slot" => ".slot",
                    "far" => ".far",
                    _ => "",
                };
                Some((op, format!("{}{suffix}", local_ref(name))))
            })
            .collect();
        let local = |g: &str| exts.get(g).cloned().unwrap_or_else(|| local_ref(g));
        rewrite_code(&mut code, &text, path, &local)?;
        // The SSA tier's description: the IR before value numbering and the folds, then after them.
        let desc = if dir.join(format!("{stem}.txt")).exists() { read(&format!("{stem}.txt"))? } else { String::new() };
        for (out, name) in [(&mut pre, "IR before value numbering and the folds"), (&mut post, "IR")] {
            writeln!(out, "fn {path}").unwrap();
            match ir_section(&desc, name) {
                Some(ir) => writeln!(out, "{}", local_names(ir, &local)).unwrap(),
                None => {
                    let why = desc.lines().next().and_then(|l| l.strip_prefix("; unsupported: ")).unwrap_or("not compiled by the SSA tier");
                    writeln!(out, "; {why}").unwrap()
                }
            }
            out.push('\n');
        }
    }
    Ok(vec![("jit.s", disassemble(&code)?), ("jit-ssa-pre.txt", pre), ("jit-ssa-post.txt", post)])
}

/// The image's names in `RYO_DUMP_CODE`: per function its path, and per (function, image
/// reference) the function's own name for it, as in the AOT dumps.
struct AotNames {
    paths: HashMap<String, String>,
    refs: HashMap<(String, String), String>,
}

impl AotNames {
    fn parse(aot: &str) -> Result<AotNames, String> {
        let mut names = AotNames { paths: HashMap::new(), refs: HashMap::new() };
        for line in aot.lines() {
            let bad = || format!("RYO_DUMP_CODE: bad line {line:?}");
            let mut w = line.split(' ');
            match w.next() {
                Some("image") => {
                    let mut p = line.splitn(3, ' ').skip(1);
                    let (Some(i), Some(path)) = (p.next(), p.next()) else { return Err(bad()) };
                    names.paths.insert(i.to_owned(), path.to_owned());
                }
                Some("ref") => {
                    let (Some(i), Some(g), Some(l)) = (w.next(), w.next(), w.next()) else { return Err(bad()) };
                    names.refs.entry((i.to_owned(), g.to_owned())).or_insert_with(|| l.to_owned());
                }
                _ => {}
            }
        }
        Ok(names)
    }

    /// Function `func`'s name for the image reference `g` (`image.<g>` if it has none).
    fn local(&self, func: u32, g: &str) -> String {
        self.refs.get(&(func.to_string(), g.to_owned())).cloned().unwrap_or_else(|| format!("image.{g}"))
    }
}

/// The functions `RYO_JIT_DUMP` wrote to `dir` (`f<func>-<image header>.code` and `.txt`, of
/// the program's one image), sorted: (path, function, file stem).
fn jit_functions(dir: &Path, names: &AotNames) -> Result<Vec<(String, u32, String)>, String> {
    let mut funcs = Vec::new();
    let mut header = None;
    for e in fs::read_dir(dir).map_err(|e| format!("reading {}: {e}", dir.display()))? {
        let e = e.map_err(|e| e.to_string())?;
        let file = e.file_name().to_string_lossy().into_owned();
        let Some(stem) = file.strip_suffix(".code") else { continue };
        let (f, h) = stem.strip_prefix('f').and_then(|s| s.split_once('-')).ok_or_else(|| format!("RYO_JIT_DUMP: unexpected file {file}"))?;
        if header.get_or_insert_with(|| h.to_owned()) != h {
            return Err("RYO_JIT_DUMP: functions of more than one image".to_owned());
        }
        let path = names.paths.get(f).ok_or_else(|| format!("RYO_JIT_DUMP: function {f} isn't in RYO_DUMP_CODE"))?;
        funcs.push((path.clone(), f.parse::<u32>().map_err(|e| e.to_string())?, stem.to_owned()));
    }
    funcs.sort();
    Ok(funcs)
}

/// Appends a JIT code dump `text` of the function `path` to `code` in the AOT dumps' form:
/// `ext` lines dropped, `tier` as `fn <path>` (with the tier if it isn't the SSA tier), and
/// image references in `reloc` lines named by `local`.
fn rewrite_code(code: &mut String, text: &str, path: &str, local: &dyn Fn(&str) -> String) -> Result<(), String> {
    for line in text.lines() {
        if line.starts_with("ext ") {
            continue;
        }
        if let Some(tier) = line.strip_prefix("tier ") {
            if tier == "ssa" {
                writeln!(code, "fn {path}").unwrap();
            } else {
                writeln!(code, "fn {path} ({tier})").unwrap();
            }
        } else if let Some(r) = line.strip_prefix("reloc ") {
            let (at, to) = r.split_once(' ').ok_or("RYO_JIT_DUMP: bad reloc")?;
            // The image's functions (and retargeted callees), symbols, constants and data.
            let to = if is_image_ref(to) { local(to) } else { to.to_owned() };
            writeln!(code, "reloc {at} {to}").unwrap();
        } else {
            writeln!(code, "{line}").unwrap();
        }
    }
    Ok(())
}

/// The section `; <name>` of an SSA description, up to the next `; ` line.
fn ir_section<'a>(desc: &'a str, name: &str) -> Option<&'a str> {
    let start = desc
        .find(&format!("\n; {name}\n"))
        .map(|k| k + name.len() + 4)
        .or_else(|| desc.starts_with(&format!("; {name}\n")).then(|| name.len() + 3))?;
    let rest = &desc[start..];
    Some(rest[..rest.find("\n; ").map_or(rest.len(), |k| k + 1)].trim_end())
}

/// The `RYO_DUMP_CODE` text as x86 assembly: per function, its instructions at offsets from
/// the function start, with relocated operands named by their targets.
fn disassemble(dump: &str) -> Result<String, String> {
    let mut out = String::new();
    let mut code = Vec::new();
    let mut relocs = Vec::new();
    let mut osr = None;
    let bytes = |hex: &str| -> Result<Vec<u8>, String> {
        (0..hex.len()).step_by(2).map(|i| u8::from_str_radix(&hex[i..i + 2], 16)).collect::<Result<_, _>>().map_err(|e| format!("RYO_DUMP_CODE: {e}"))
    };
    for line in dump.lines() {
        if let Some(name) = line.strip_prefix("fn ") {
            if !out.is_empty() || !code.is_empty() {
                disassemble_function(&mut out, &code, &relocs, osr.take());
            }
            writeln!(out, "fn {name}").unwrap();
            code.clear();
            relocs.clear();
        } else if let Some(hex) = line.strip_prefix("code ") {
            code = bytes(hex)?;
        } else if let Some(o) = line.strip_prefix("osr ") {
            // The OSR code (`RYO_JIT_DUMP`), at an offset past the body.
            let (at, hex) = o.split_once(' ').ok_or("RYO_JIT_DUMP: bad osr")?;
            let at: usize = at.parse().map_err(|e| format!("RYO_JIT_DUMP: {e}"))?;
            osr = Some((code.len(), at));
            code.resize(at, 0xcc);
            code.extend(bytes(hex)?);
        } else if let Some(r) = line.strip_prefix("reloc ") {
            let (at, to) = r.split_once(' ').ok_or("RYO_DUMP_CODE: bad reloc")?;
            relocs.push((at.parse::<u32>().map_err(|e| format!("RYO_DUMP_CODE: {e}"))?, to.to_owned()));
        }
    }
    if !code.is_empty() {
        disassemble_function(&mut out, &code, &relocs, osr);
    }
    Ok(out)
}

/// One function of the dump, appended to `out`. `osr`: where the body ends and the OSR code
/// starts (JIT code), which gets a comment line; the padding between them isn't printed.
fn disassemble_function(out: &mut String, code: &[u8], relocs: &[(u32, String)], osr: Option<(usize, usize)>) {
    use iced_x86::{Decoder, DecoderOptions, Formatter, IntelFormatter};
    // First pass: the instructions and jump-table entries, and the positions they refer to
    // within the function, which get labels.
    let mut osr = osr;
    let mut items = Vec::new();
    let mut targets = std::collections::BTreeSet::new();
    let mut d = Decoder::with_ip(64, code, 0, DecoderOptions::NONE);
    // A jump table's position: the `lea rcx, [rip + T]` of the switch sequence.
    let mut table = None;
    while d.can_decode() {
        let at = d.ip() as usize;
        if let Some((end, osr_at)) = osr
            && at == end
        {
            osr = None;
            items.push((osr_at, Item::Osr));
            d.set_position(osr_at).unwrap();
            d.set_ip(osr_at as u64);
            continue;
        }
        if table == Some(at) {
            // `i32` offsets from the table to its targets. The table ends at the first
            // target after it, or (all targets before it) at an offset out of the function.
            // In that case, code after the table whose 4-byte groups land in the function
            // would be read as entries; no dump has such a table today.
            let mut end = code.len();
            let mut pos = at;
            while pos + 4 <= end {
                let e = i32::from_le_bytes(code[pos..pos + 4].try_into().unwrap()) as i64;
                let to = at as i64 + e;
                if !(0..code.len() as i64).contains(&to) {
                    break;
                }
                if to as usize >= pos + 4 {
                    end = end.min(to as usize);
                }
                targets.insert(to as u64);
                items.push((pos, Item::Long(to as usize)));
                pos += 4;
            }
            table = None;
            d.set_position(pos).unwrap();
            d.set_ip(pos as u64);
            continue;
        }
        let insn = d.decode();
        // The JIT's tables: `lea r11, [rip + T]` (its OSR dispatcher and the SSA tier's
        // switches). A relocated operand (`lea rcx, [image.kN]`) is no table.
        let r = insn.op0_register();
        if insn.mnemonic() == iced_x86::Mnemonic::Lea
            && (r == iced_x86::Register::RCX || r == iced_x86::Register::R11)
            && insn.is_ip_rel_memory_operand()
            && reloc_at(relocs, &insn).is_none()
        {
            table = Some(insn.ip_rel_memory_address() as usize);
        }
        if reloc_at(relocs, &insn).is_none() {
            if is_near_branch(&insn) {
                targets.insert(insn.near_branch_target());
            }
            if insn.is_ip_rel_memory_operand() && (insn.ip_rel_memory_address() as usize) < code.len() {
                targets.insert(insn.ip_rel_memory_address());
            }
        }
        items.push((at, Item::Insn(insn)));
    }
    let labels: HashMap<u64, String> = targets.iter().enumerate().map(|(i, &t)| (t, format!("L{i}"))).collect();
    let mut fmt = IntelFormatter::with_options(Some(Box::new(Relocs { relocs: relocs.to_vec(), labels: labels.clone() })), None);
    let o = fmt.options_mut();
    o.set_first_operand_char_index(8);
    o.set_branch_leading_zeros(false);
    o.set_show_branch_size(false);
    let mut text = String::new();
    for (at, item) in &items {
        if let Some(l) = labels.get(&(*at as u64)) {
            writeln!(out, "{l}:").unwrap();
        }
        match item {
            Item::Osr => writeln!(out, "  ; OSR entries").unwrap(),
            Item::Long(to) => writeln!(out, "    .long   {}", labels[&(*to as u64)]).unwrap(),
            Item::Insn(insn) => {
                text.clear();
                fmt.format(insn, &mut text);
                writeln!(out, "    {text}").unwrap();
            }
        }
    }
    out.push('\n');
}

enum Item {
    Insn(iced_x86::Instruction),
    Long(usize),
    Osr,
}

fn is_near_branch(insn: &iced_x86::Instruction) -> bool {
    insn.op_kinds().any(|k| matches!(k, iced_x86::OpKind::NearBranch16 | iced_x86::OpKind::NearBranch32 | iced_x86::OpKind::NearBranch64))
}

/// The target of the relocation inside `insn`, if any.
fn reloc_at<'a>(relocs: &'a [(u32, String)], insn: &iced_x86::Instruction) -> Option<&'a str> {
    relocs.iter().find(|(at, _)| (insn.ip() as u32..insn.next_ip() as u32).contains(at)).map(|(_, to)| to.as_str())
}

/// Whether `address` is `insn`'s branch target or RIP-relative address.
fn refers_to(insn: &iced_x86::Instruction, address: u64) -> bool {
    (is_near_branch(insn) && insn.near_branch_target() == address) || (insn.is_ip_rel_memory_operand() && insn.ip_rel_memory_address() == address)
}

/// Names the relocated operands of one function's instructions: each relocated field is a
/// 4-byte branch or RIP-relative displacement within its instruction, or the `imm64` of a
/// call through `r11`.
/// Other operands that name a position in the function (branch targets, a jump table) are
/// named by its label.
struct Relocs {
    relocs: Vec<(u32, String)>,
    labels: HashMap<u64, String>,
}

impl iced_x86::SymbolResolver for Relocs {
    fn symbol(
        &mut self,
        insn: &iced_x86::Instruction,
        _operand: u32,
        _insn_operand: Option<u32>,
        address: u64,
        _address_size: u32,
    ) -> Option<iced_x86::SymbolResult<'_>> {
        // The relocated operand only, not an immediate of the same instruction.
        // (Or the `imm64` of a `mov r11, imm64` before a call through `r11`.)
        let imm64 = insn.op_kinds().any(|k| k == iced_x86::OpKind::Immediate64) && insn.immediate64() == address;
        let refers = refers_to(insn, address);
        if refers || imm64 {
            if let Some(to) = reloc_at(&self.relocs, insn) {
                return Some(iced_x86::SymbolResult::with_str(address, to));
            }
        }
        if refers {
            return self.labels.get(&address).map(|l| iced_x86::SymbolResult::with_str(address, l.as_str()));
        }
        None
    }
}
