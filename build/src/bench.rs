//! `y bench` (design/build.md#test-and-bench): each program under `bench/` is compiled
//! and run with every [`Backend`], timing both, and the results are printed as tables.
//!
//! Timing uses hyperfine if it is on `PATH`, and otherwise a built-in timer (one warmup run,
//! then `runs` timed runs, mean and standard deviation of the wall time).

use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::Instant;

use crate::utils::{cmd, describe, exe_name, root};

pub const DEFAULT_RUNS: u32 = 5;

/// Programs `bench/<name>.rs`. Each prints a result that must be the same for every
/// backend.
const PROGRAMS: &[&str] = &["fib", "sieve", "sort", "hashmap"];

#[derive(Clone, Copy)]
enum Compiler {
    Rustc,
    Clif,
    Ryo,
}

/// A column of the tables.
struct Backend {
    name: String,
    compiler: Compiler,
    flags: Vec<String>,
    /// The environment the program runs with.
    env: Vec<(&'static str, &'static str)>,
}

/// Flags every backend gets, so compile times compare one codegen unit on one thread.
const COMMON_FLAGS: &[&str] = &["-Ccodegen-units=1", "-Zthreads=1"];

/// What `y bench` measures of the programs' runs.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Metric {
    /// Compile and run time (hyperfine or the built-in timer).
    Time,
    /// Instructions executed by one run (cachegrind's `I refs`); compile time isn't measured.
    Cachegrind,
}

/// `y bench [--runs N] [--llvm LEVELS] [--clif] [--ryo MODES] [--metric time|cachegrind]`.
#[derive(Clone, Debug, PartialEq)]
pub struct Options {
    pub runs: u32,
    /// `-Copt-level`s for plain rustc: `O0`..`O3`, a `d` suffix (`O2d`) turning on debug
    /// assertions (and with them overflow checks, as at `O0`).
    pub llvm: Vec<String>,
    pub clif: bool,
    /// `aot` (`RYO_JIT=off`) and `jit` (`RYO_JIT_OPT=ssa`).
    pub ryo: Vec<String>,
    pub metric: Metric,
}

impl Default for Options {
    /// The default columns: LLVM -O0 and -O3, cg_clif and ryo as it runs by default.
    fn default() -> Self {
        Options { runs: DEFAULT_RUNS, llvm: Vec::new(), clif: false, ryo: Vec::new(), metric: Metric::Time }
    }
}

pub fn parse_options(args: &[&str]) -> Result<Options, String> {
    let mut o = Options::default();
    let mut args = args.iter().copied();
    while let Some(arg) = args.next() {
        let (flag, value) = match arg.split_once('=') {
            Some((f, v)) if f.starts_with("--") => (f, Some(v)),
            _ => (arg, None),
        };
        let mut value = || value.or_else(|| args.next()).ok_or(format!("`{flag}` needs a value"));
        let list = |v: &str| v.split(',').filter(|s| !s.is_empty()).map(str::to_owned).collect::<Vec<_>>();
        match flag {
            "--runs" => {
                let n = value()?;
                o.runs = n.parse().ok().filter(|&r| r > 0).ok_or(format!("bad run count `{n}`"))?;
            }
            "--llvm" => {
                for l in list(value()?) {
                    let level = l.strip_suffix('d').unwrap_or(&l);
                    if !matches!(level, "O0" | "O1" | "O2" | "O3") {
                        return Err(format!("bad LLVM level `{l}` (expected O0..O3, optionally with a `d` suffix)"));
                    }
                    o.llvm.push(l);
                }
            }
            "--clif" => o.clif = true,
            "--ryo" => {
                for m in list(value()?) {
                    if !matches!(m.as_str(), "aot" | "jit") {
                        return Err(format!("bad ryo mode `{m}` (expected aot or jit)"));
                    }
                    o.ryo.push(m);
                }
            }
            "--metric" => {
                o.metric = match value()? {
                    "time" => Metric::Time,
                    "cachegrind" => Metric::Cachegrind,
                    m => return Err(format!("unknown metric `{m}`")),
                }
            }
            _ => return Err(format!("unexpected argument `{arg}`")),
        }
    }
    Ok(o)
}

/// The columns `o` selects; the first is the reference whose output the others must match.
/// Without `--llvm`, `--clif` or `--ryo`, the default columns.
fn backends(o: &Options) -> Vec<Backend> {
    let rustc = |level: &str| {
        let (l, checks) = match level.strip_suffix('d') {
            Some(l) => (l, true),
            None => (level, false),
        };
        let mut flags = vec![format!("-Copt-level={}", &l[1..])];
        if checks {
            flags.push("-Cdebug-assertions=on".to_owned());
        }
        Backend { name: format!("llvm -{level}"), compiler: Compiler::Rustc, flags, env: Vec::new() }
    };
    let clif = || Backend { name: "clif".to_owned(), compiler: Compiler::Clif, flags: Vec::new(), env: Vec::new() };
    if o.llvm.is_empty() && !o.clif && o.ryo.is_empty() {
        let ryo = Backend { name: "ryo".to_owned(), compiler: Compiler::Ryo, flags: Vec::new(), env: Vec::new() };
        return vec![rustc("O0"), rustc("O3"), clif(), ryo];
    }
    let mut v: Vec<Backend> = o.llvm.iter().map(|l| rustc(l)).collect();
    if o.clif {
        v.push(clif());
    }
    for m in &o.ryo {
        let env = if m == "aot" { vec![("RYO_JIT", "off")] } else { vec![("RYO_JIT_OPT", "ssa")] };
        v.push(Backend { name: format!("ryo {m}"), compiler: Compiler::Ryo, flags: Vec::new(), env });
    }
    v
}

/// Mean and standard deviation, in seconds.
#[derive(Clone, Copy, Debug, PartialEq)]
struct Stats {
    mean: f64,
    stddev: f64,
}

/// One timed command: a program, its arguments and the environment `cmd` gives it.
struct Job {
    program: PathBuf,
    args: Vec<String>,
    env: Vec<(&'static str, &'static str)>,
}

impl Job {
    fn command(&self) -> Command {
        let mut c = cmd(&self.program);
        c.args(&self.args).envs(self.env.iter().copied());
        c
    }
}

enum Timer {
    Hyperfine { json: PathBuf },
    Builtin,
}

impl Timer {
    fn measure(&self, job: &Job, runs: u32) -> Result<Stats, String> {
        match self {
            Timer::Builtin => {
                let mut times = Vec::new();
                for i in 0..=runs {
                    let mut c = job.command();
                    let start = Instant::now();
                    let status =
                        c.stdout(Stdio::null()).stderr(Stdio::null()).status().map_err(|e| format!("failed to run `{}`: {e}", describe(&c)))?;
                    let elapsed = start.elapsed().as_secs_f64();
                    if !status.success() {
                        return Err(format!("`{}` failed with {status}", describe(&c)));
                    }
                    // The first run is a warmup.
                    if i > 0 {
                        times.push(elapsed);
                    }
                }
                Ok(stats(&times))
            }
            Timer::Hyperfine { json } => {
                let line: Vec<String> =
                    std::iter::once(job.program.to_string_lossy().into_owned()).chain(job.args.iter().cloned()).map(|a| shell_quote(&a)).collect();
                let mut c = cmd("hyperfine");
                c.envs(job.env.iter().copied());
                c.args(["-N", "--style", "none", "--warmup", "1", "--runs"])
                    .arg(runs.to_string())
                    .arg("--export-json")
                    .arg(json)
                    .arg(line.join(" "))
                    .stdout(Stdio::null());
                let status = c.status().map_err(|e| format!("failed to run hyperfine: {e}"))?;
                if !status.success() {
                    return Err(format!("`{}` failed with {status}", describe(&c)));
                }
                let text = fs::read_to_string(json).map_err(|e| format!("{}: {e}", json.display()))?;
                parse_hyperfine(&text).ok_or_else(|| format!("can't parse {}", json.display()))
            }
        }
    }
}

fn stats(times: &[f64]) -> Stats {
    let n = times.len() as f64;
    let mean = times.iter().sum::<f64>() / n;
    let var = if times.len() > 1 { times.iter().map(|t| (t - mean) * (t - mean)).sum::<f64>() / (n - 1.0) } else { 0.0 };
    Stats { mean, stddev: var.sqrt() }
}

/// `mean` and `stddev` of the first entry of the `results` array in hyperfine's
/// `--export-json` output. A minimal scan, not a JSON parser (`y` has no dependencies).
/// `stddev` is `null` for a single run.
fn parse_hyperfine(json: &str) -> Option<Stats> {
    let start = json.find("\"results\"")?;
    let json = &json[start..];
    let json = &json[..json.find(']').unwrap_or(json.len())];
    fn number(json: &str, key: &str) -> Option<f64> {
        let rest = &json[json.find(&format!("\"{key}\":"))? + key.len() + 3..];
        let end = rest.find([',', '}', '\n']).unwrap_or(rest.len());
        rest[..end].trim().parse().ok()
    }
    Some(Stats { mean: number(json, "mean")?, stddev: number(json, "stddev").unwrap_or(0.0) })
}

/// Quotes `s` for hyperfine's command line, which is split like a POSIX shell's.
fn shell_quote(s: &str) -> String {
    if !s.is_empty() && s.bytes().all(|b| b.is_ascii_alphanumeric() || b"-_=./:,+@%".contains(&b)) {
        s.to_owned()
    } else {
        format!("'{}'", s.replace('\'', r"'\''"))
    }
}

/// `y bench codegen` (design/build.md#test-and-bench): compiles each program with `rustc-ryo`
/// and `RYO_DUMP`/`RYO_DUMP_CODE`, writing what the backend generated to
/// `bench/codegen/<name>.txt` (VM instructions) and `bench/codegen/<name>.s` (x86), then runs
/// it, writing the JIT's code and IR ([`jit_dumps`]) to `bench/codegen/<name>.jit*`.
pub fn codegen() -> Result<(), String> {
    let root = root();
    let rustc_ryo = root.join("dist").join("bin").join(exe_name("rustc-ryo"));
    if !rustc_ryo.exists() {
        return Err("dist/ is missing; run `./y.sh build` first".to_owned());
    }
    let dump_dir = root.join("bench").join("codegen");
    let out = root.join("target").join("bench-codegen");
    for dir in [&dump_dir, &out] {
        fs::create_dir_all(dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
    }
    for &program in PROGRAMS {
        let src = root.join("bench").join(format!("{program}.rs"));
        let dump = dump_dir.join(format!("{program}.txt"));
        let mut c = cmd(&rustc_ryo);
        c.args(["--edition=2024", &path_str(&src)?, "-o", &path_str(&out.join(exe_name(program)))?]);
        // Paths relative to the repository, so the dumps don't depend on where it is.
        c.arg(format!("--remap-path-prefix={}{}=", path_str(&root)?, std::path::MAIN_SEPARATOR));
        let code = out.join(format!("{program}.code"));
        c.env("RYO_DUMP", &dump);
        c.env("RYO_DUMP_CODE", &code);
        eprintln!("[y] bench codegen {program}: {}", dump.display());
        crate::utils::run(&mut c)?;
        let code = fs::read_to_string(&code).map_err(|e| format!("reading {}: {e}", code.display()))?;
        let s = dump_dir.join(format!("{program}.s"));
        fs::write(&s, disassemble(&code)?).map_err(|e| format!("writing {}: {e}", s.display()))?;
        let jit = out.join(format!("{program}.jit"));
        eprintln!("[y] bench codegen {program}: JIT, {}", jit.display());
        for (name, text) in jit_dumps(&out.join(exe_name(program)), &jit, &code)? {
            let f = dump_dir.join(format!("{program}.{name}"));
            fs::write(&f, text).map_err(|e| format!("writing {}: {e}", f.display()))?;
        }
    }
    Ok(())
}

/// `ir` with the image's references that the IR prints as `Func(Func(8))` named as the
/// function's code names them (`local("fn8")`, `fn2`).
fn local_names(ir: &str, local: &dyn Fn(&str) -> String) -> String {
    let mut out = String::new();
    let mut rest = ir;
    'scan: while !rest.is_empty() {
        for (debug, name) in [("Func(Func(", "fn"), ("Sym(Sym(", "sym"), ("Site(Site(", "site"), ("Const(Const(", "k"), ("Data(Data(", "data")] {
            if let Some(after) = rest.strip_prefix(debug) {
                let n = after.bytes().take_while(u8::is_ascii_digit).count();
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
    use std::fmt::Write;
    if dir.exists() {
        fs::remove_dir_all(dir).map_err(|e| format!("removing {}: {e}", dir.display()))?;
    }
    fs::create_dir_all(dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
    let mut c = cmd(exe);
    for (k, _) in std::env::vars_os() {
        if k.to_string_lossy().starts_with("RYO_JIT") {
            c.env_remove(k);
        }
    }
    c.env("RYO_JIT_SYNC", "1").env("RYO_JIT_OPT", "ssa").env("RYO_JIT_DUMP", dir).stdout(Stdio::null());
    crate::utils::run(&mut c)?;

    // The image's names: per function its path, and per (function, image reference) the
    // function's own name for it, as in the AOT dumps.
    let mut paths = HashMap::new();
    let mut refs = HashMap::new();
    for line in aot.lines() {
        let mut w = line.split(' ');
        match w.next() {
            Some("image") => {
                let mut p = line.splitn(3, ' ').skip(1);
                let (Some(i), Some(path)) = (p.next(), p.next()) else { return Err(format!("RYO_DUMP_CODE: bad line {line:?}")) };
                paths.insert(i.to_owned(), path.to_owned());
            }
            Some("ref") => {
                let (Some(i), Some(g), Some(l)) = (w.next(), w.next(), w.next()) else { return Err(format!("RYO_DUMP_CODE: bad line {line:?}")) };
                refs.entry((i.to_owned(), g.to_owned())).or_insert_with(|| l.to_owned());
            }
            _ => {}
        }
    }

    // `f<func>-<image header>.code` and `.txt`, of the program's one image.
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
        let path = paths.get(f).ok_or_else(|| format!("RYO_JIT_DUMP: function {f} isn't in RYO_DUMP_CODE"))?;
        funcs.push((path.clone(), f.parse::<u32>().map_err(|e| e.to_string())?, stem.to_owned()));
    }
    funcs.sort();

    let read = |f: &str| fs::read_to_string(dir.join(f)).map_err(|e| format!("reading {f}: {e}"));
    let (mut code, mut pre, mut post) = (String::new(), String::new(), String::new());
    for (path, f, stem) in &funcs {
        let text = read(&format!("{stem}.code"))?;
        let local_ref = |g: &str| refs.get(&(f.to_string(), g.to_owned())).cloned().unwrap_or_else(|| format!("image.{g}"));
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
        for line in text.lines() {
            if line.starts_with("ext ") {
                continue;
            }
            if let Some(tier) = line.strip_prefix("tier ") {
                // The AOT dumps' `fn <path>`, the tier if it isn't the SSA tier.
                if tier == "ssa" {
                    writeln!(code, "fn {path}").unwrap();
                } else {
                    writeln!(code, "fn {path} ({tier})").unwrap();
                }
            } else if let Some(r) = line.strip_prefix("reloc ") {
                let (at, to) = r.split_once(' ').ok_or("RYO_JIT_DUMP: bad reloc")?;
                // The image's functions (and retargeted callees), symbols, sites, constants and
                // data.
                let image_ref = ["fn", "sym", "site", "k", "data"]
                    .iter()
                    .any(|p| to.strip_prefix(p).is_some_and(|n| !n.is_empty() && n.bytes().all(|b| b.is_ascii_digit())));
                let to = if image_ref { local(to) } else { to.to_owned() };
                writeln!(code, "reloc {at} {to}").unwrap();
            } else {
                writeln!(code, "{line}").unwrap();
            }
        }
        // The SSA tier's description: the IR before value numbering and the folds, then after them.
        let desc = if dir.join(format!("{stem}.txt")).exists() { read(&format!("{stem}.txt"))? } else { String::new() };
        let section = |name: &str| -> Option<&str> {
            let start = desc
                .find(&format!("\n; {name}\n"))
                .map(|k| k + name.len() + 4)
                .or_else(|| desc.starts_with(&format!("; {name}\n")).then(|| name.len() + 3))?;
            let rest = &desc[start..];
            Some(rest[..rest.find("\n; ").map_or(rest.len(), |k| k + 1)].trim_end())
        };
        for (out, name) in [(&mut pre, "IR before value numbering and the folds"), (&mut post, "IR")] {
            writeln!(out, "fn {path}").unwrap();
            match section(name) {
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

/// The `RYO_DUMP_CODE` text as x86 assembly: per function, its instructions at offsets from
/// the function start, with relocated operands named by their targets.
fn disassemble(dump: &str) -> Result<String, String> {
    use iced_x86::{Decoder, DecoderOptions, Formatter, IntelFormatter};
    use std::fmt::Write;
    let mut out = String::new();
    // `osr`: where the body ends and the OSR code starts (JIT code), which gets a comment
    // line; the padding between them isn't printed.
    let flush = |out: &mut String, code: &[u8], relocs: &[(u32, String)], osr: Option<(usize, usize)>| {
        // First pass: the instructions and jump-table entries, and the positions they refer to
        // within the function, which get labels.
        enum Item {
            Insn(iced_x86::Instruction),
            Long(usize),
            Osr,
        }
        let mut osr = osr;
        let mut items = Vec::new();
        let mut targets = std::collections::BTreeSet::new();
        let reloc_in = |insn: &iced_x86::Instruction| relocs.iter().any(|(at, _)| (insn.ip() as u32..insn.next_ip() as u32).contains(at));
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
            // switches).
            let r = insn.op0_register();
            if insn.mnemonic() == iced_x86::Mnemonic::Lea
                && (r == iced_x86::Register::RCX || (r == iced_x86::Register::R11 && !reloc_in(&insn)))
                && insn.is_ip_rel_memory_operand()
            {
                table = Some(insn.ip_rel_memory_address() as usize);
            }
            if !reloc_in(&insn) {
                if insn
                    .op_kinds()
                    .any(|k| matches!(k, iced_x86::OpKind::NearBranch16 | iced_x86::OpKind::NearBranch32 | iced_x86::OpKind::NearBranch64))
                {
                    targets.insert(insn.near_branch_target());
                }
                if insn.is_ip_rel_memory_operand() && (insn.ip_rel_memory_address() as usize) < code.len() {
                    targets.insert(insn.ip_rel_memory_address());
                }
            }
            items.push((at, Item::Insn(insn)));
        }
        let labels: HashMap<u64, String> = targets.iter().enumerate().map(|(i, &t)| (t, format!("L{i}"))).collect();
        let mut fmt = IntelFormatter::with_options(Some(Box::new(Relocs(relocs.to_vec(), labels.clone()))), None);
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
    };
    let mut code = Vec::new();
    let mut relocs = Vec::new();
    let mut osr = None;
    let bytes = |hex: &str| -> Result<Vec<u8>, String> {
        (0..hex.len()).step_by(2).map(|i| u8::from_str_radix(&hex[i..i + 2], 16)).collect::<Result<_, _>>().map_err(|e| format!("RYO_DUMP_CODE: {e}"))
    };
    for line in dump.lines() {
        if let Some(name) = line.strip_prefix("fn ") {
            if !out.is_empty() || !code.is_empty() {
                flush(&mut out, &code, &relocs, osr.take());
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
        flush(&mut out, &code, &relocs, osr);
    }
    Ok(out)
}

/// Names the relocated operands of one function's instructions: each relocated field is a
/// 4-byte branch or RIP-relative displacement within its instruction, or the `imm64` of a
/// call through `r11`.
/// Other operands that name a position in the function (branch targets, a jump table) are
/// named by its label.
struct Relocs(Vec<(u32, String)>, HashMap<u64, String>);

impl iced_x86::SymbolResolver for Relocs {
    fn symbol(
        &mut self,
        insn: &iced_x86::Instruction,
        _operand: u32,
        _insn_operand: Option<u32>,
        address: u64,
        _address_size: u32,
    ) -> Option<iced_x86::SymbolResult<'_>> {
        let (start, end) = (insn.ip() as u32, insn.next_ip() as u32);
        let near =
            insn.op_kinds().any(|k| matches!(k, iced_x86::OpKind::NearBranch16 | iced_x86::OpKind::NearBranch32 | iced_x86::OpKind::NearBranch64));
        // The relocated operand only, not an immediate of the same instruction.
        // (Or the `imm64` of a `mov r11, imm64` before a call through `r11`.)
        let imm64 = insn.op_kinds().any(|k| k == iced_x86::OpKind::Immediate64) && insn.immediate64() == address;
        let relocated =
            (near && insn.near_branch_target() == address) || (insn.is_ip_rel_memory_operand() && insn.ip_rel_memory_address() == address) || imm64;
        if let Some((_, to)) = self.0.iter().find(|(at, _)| (start..end).contains(at))
            && relocated
        {
            return Some(iced_x86::SymbolResult::with_str(address, to.as_str()));
        }
        if (near && insn.near_branch_target() == address) || (insn.is_ip_rel_memory_operand() && insn.ip_rel_memory_address() == address) {
            return self.1.get(&address).map(|l| iced_x86::SymbolResult::with_str(address, l.as_str()));
        }
        None
    }
}

/// A cell of the tables. `None` where building or running failed (or wasn't measured).
#[derive(Default)]
struct Cell {
    compile: Option<Stats>,
    run: Option<Stats>,
    /// Instructions of one run (`Metric::Cachegrind`).
    ir: Option<u64>,
}

pub fn run(opts: &Options) -> Result<(), String> {
    let root = root();
    let dist_bin = root.join("dist").join("bin");
    if !dist_bin.join(exe_name("rustc-ryo")).exists() {
        eprintln!("[y] bench: dist/ is missing, building it");
        crate::dist::build(&[], false)?;
    }
    let backends = backends(opts);
    if backends.iter().any(|b| matches!(b.compiler, Compiler::Clif)) {
        crate::clif::ensure()?;
    }
    let runs = opts.runs;

    let out = root.join("target").join("bench");
    fs::create_dir_all(&out).map_err(|e| format!("creating {}: {e}", out.display()))?;
    let timer = if opts.metric == Metric::Cachegrind {
        eprintln!("[y] bench: counting instructions of one run with cachegrind");
        None
    } else if Command::new("hyperfine").arg("--version").output().is_ok_and(|o| o.status.success()) {
        eprintln!("[y] bench: timing with hyperfine, {runs} runs after 1 warmup");
        Some(Timer::Hyperfine { json: out.join("hyperfine.json") })
    } else {
        eprintln!(
            "[y] bench: hyperfine is not installed; timing with the built-in timer \
             ({runs} runs after 1 warmup, mean and standard deviation of wall time)"
        );
        Some(Timer::Builtin)
    };

    let mut rows = Vec::new();
    // Output mismatches and failed builds or runs, reported at the end.
    let mut failures = Vec::new();
    for &program in PROGRAMS {
        let src = root.join("bench").join(format!("{program}.rs"));
        let mut cells = Vec::new();
        let mut reference: Option<String> = None;
        for backend in &backends {
            eprintln!("[y] bench {program} [{}]", backend.name);
            let dir = out.join(program).join(backend.name.replace([' ', '-'], ""));
            fs::create_dir_all(&dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
            let exe = dir.join(exe_name(program));
            let compiler = match backend.compiler {
                Compiler::Rustc => PathBuf::from("rustc"),
                Compiler::Clif => crate::clif::rustc_clif(&root),
                Compiler::Ryo => dist_bin.join(exe_name("rustc-ryo")),
            };
            let mut args = vec!["--edition=2024".to_owned(), path_str(&src)?];
            args.extend(COMMON_FLAGS.iter().map(|f| f.to_string()).chain(backend.flags.iter().cloned()));
            args.extend(["-o".to_owned(), path_str(&exe)?]);
            let _ = fs::remove_file(&exe);
            let name = format!("{program} [{}]", backend.name);
            let mut failed = |what: &str, e: String| failures.push(format!("{name}: {what}: {e}"));
            let compile_job = Job { program: compiler, args, env: Vec::new() };
            let mut cell = Cell::default();
            let built = match &timer {
                Some(timer) => {
                    cell.compile = timer.measure(&compile_job, runs).map_err(|e| failed("compile", e)).ok();
                    cell.compile.is_some()
                }
                None => crate::utils::run(&mut compile_job.command()).map_err(|e| failed("compile", e)).is_ok(),
            };
            let output = if built { run_once(&exe, &backend.env).map_err(|e| failed("run", e)).ok() } else { None };
            if let Some(output) = output {
                match &reference {
                    None => reference = Some(output),
                    Some(r) if *r != output => failures.push(format!("{name} printed {output:?}, {} printed {r:?}", backends[0].name)),
                    Some(_) => {}
                }
                let job = Job { program: exe, args: Vec::new(), env: backend.env.clone() };
                match &timer {
                    Some(timer) => cell.run = timer.measure(&job, runs).map_err(|e| failures.push(format!("{name}: run: {e}"))).ok(),
                    None => cell.ir = cachegrind(&job).map_err(|e| failures.push(format!("{name}: cachegrind: {e}"))).ok(),
                }
            }
            cells.push(cell);
        }
        rows.push((program, cells));
    }

    let header: Vec<&str> = backends.iter().map(|b| b.name.as_str()).collect();
    println!();
    match timer {
        Some(_) => {
            print!("{}", table("compile time (ms, mean ± stddev)", &header, &rows, |c| c.compile.map(ms)));
            println!();
            print!("{}", table("run time (ms, mean ± stddev)", &header, &rows, |c| c.run.map(ms)));
        }
        None => {
            print!("{}", table("run instructions (cachegrind Ir, millions)", &header, &rows, |c| c.ir.map(|n| format!("{:.1}", n as f64 / 1e6))));
            println!();
            let title = format!("run instructions relative to {}", header[0]);
            let base: HashMap<&str, Option<u64>> = rows.iter().map(|(p, c)| (*p, c[0].ir)).collect();
            let ratio_rows: Vec<(&str, Vec<Option<String>>)> =
                rows.iter().map(|(p, cells)| (*p, cells.iter().map(|c| Some(format!("{:.2}x", c.ir? as f64 / base[p]? as f64))).collect())).collect();
            print!("{}", grid(&title, &header, &ratio_rows));
        }
    }
    if !failures.is_empty() {
        return Err(format!("benchmarks failed:\n{}", failures.join("\n")));
    }
    Ok(())
}

fn ms(s: Stats) -> String {
    format!("{:.1} ± {:.1}", s.mean * 1e3, s.stddev * 1e3)
}

/// The instructions `job` executes, its children included (cachegrind's `I refs`).
fn cachegrind(job: &Job) -> Result<u64, String> {
    let mut c = cmd("valgrind");
    c.args(["--tool=cachegrind", "--cache-sim=no", "--trace-children=yes", "--cachegrind-out-file=/dev/null"])
        .arg(&job.program)
        .args(&job.args)
        .envs(job.env.iter().copied())
        .stdout(Stdio::null());
    let res = c.output().map_err(|e| format!("failed to run valgrind: {e}"))?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if !res.status.success() {
        return Err(format!("`{}` failed with {}:\n{stderr}", describe(&c), res.status));
    }
    parse_cachegrind(&stderr).ok_or_else(|| format!("no cachegrind summary in:\n{stderr}"))
}

/// The sum of the `I refs:` summary lines (`==pid== I refs:  1,234`) of every process.
fn parse_cachegrind(stderr: &str) -> Option<u64> {
    let counts: Vec<u64> = stderr.lines().filter_map(|l| l.split_once("I refs:").and_then(|(_, n)| n.trim().replace(',', "").parse().ok())).collect();
    (!counts.is_empty()).then(|| counts.iter().sum())
}

/// Runs a benchmark binary once and returns its stdout.
fn run_once(exe: &Path, env: &[(&str, &str)]) -> Result<String, String> {
    let res = Command::new(exe).envs(env.iter().copied()).output().map_err(|e| format!("failed to run {}: {e}", exe.display()))?;
    if !res.status.success() {
        return Err(format!("{} failed with {}", exe.display(), res.status));
    }
    Ok(String::from_utf8_lossy(&res.stdout).into_owned())
}

fn path_str(p: &Path) -> Result<String, String> {
    p.to_str().map(str::to_owned).ok_or_else(|| format!("non-UTF-8 path {}", p.display()))
}

fn table(title: &str, header: &[&str], rows: &[(&str, Vec<Cell>)], pick: impl Fn(&Cell) -> Option<String>) -> String {
    let rows: Vec<(&str, Vec<Option<String>>)> = rows.iter().map(|(program, cells)| (*program, cells.iter().map(&pick).collect())).collect();
    grid(title, header, &rows)
}

/// A table with a `program` column and one column per `header` entry; `None` cells are
/// `failed`.
fn grid(title: &str, header: &[&str], rows: &[(&str, Vec<Option<String>>)]) -> String {
    let mut lines: Vec<Vec<String>> = vec![std::iter::once("program").chain(header.iter().copied()).map(str::to_owned).collect()];
    for (program, cells) in rows {
        let mut line = vec![program.to_string()];
        for cell in cells {
            line.push(cell.clone().unwrap_or_else(|| "failed".to_owned()));
        }
        lines.push(line);
    }
    let cols = lines[0].len();
    let widths: Vec<usize> = (0..cols).map(|i| lines.iter().map(|l| l.get(i).map_or(0, |c| c.chars().count())).max().unwrap()).collect();
    let mut out = format!("{title}\n");
    for (n, line) in lines.iter().enumerate() {
        let mut text = String::new();
        for (i, cell) in line.iter().enumerate() {
            let pad = widths[i] - cell.chars().count();
            if i == 0 {
                text.push_str(&format!("{cell}{}", " ".repeat(pad)));
            } else {
                text.push_str(&format!("  {}{cell}", " ".repeat(pad)));
            }
        }
        out.push_str(text.trim_end());
        out.push('\n');
        if n == 0 {
            out.push_str(&"-".repeat(widths.iter().sum::<usize>() + 2 * (cols - 1)));
            out.push('\n');
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hyperfine_json() {
        let json = r#"{"results":[{"command":"x","mean":0.5,"stddev":0.25,"median":0.5}]}"#;
        assert_eq!(parse_hyperfine(json), Some(Stats { mean: 0.5, stddev: 0.25 }));
        let json = "{\n  \"results\": [\n    {\n      \"mean\": 1.5e-3,\n      \"stddev\": null,\n";
        assert_eq!(parse_hyperfine(json), Some(Stats { mean: 1.5e-3, stddev: 0.0 }));
        assert_eq!(parse_hyperfine("{}"), None);
        // Keys outside `results` don't count.
        assert_eq!(parse_hyperfine(r#"{"mean":1,"results":[]}"#), None);
    }

    #[test]
    fn quoting() {
        assert_eq!(shell_quote("/a/b-c.rs"), "/a/b-c.rs");
        assert_eq!(shell_quote("a b"), "'a b'");
        assert_eq!(shell_quote("it's"), r"'it'\''s'");
    }

    #[test]
    fn options() {
        let o = parse_options(&[]).unwrap();
        assert_eq!(backends(&o).iter().map(|b| b.name.as_str()).collect::<Vec<_>>(), ["llvm -O0", "llvm -O3", "clif", "ryo"]);
        let o = parse_options(&["--llvm", "O2d,O0", "--clif", "--ryo=aot,jit", "--metric", "cachegrind", "--runs=2"]).unwrap();
        assert_eq!((o.runs, o.metric), (2, Metric::Cachegrind));
        let b = backends(&o);
        assert_eq!(b.iter().map(|b| b.name.as_str()).collect::<Vec<_>>(), ["llvm -O2d", "llvm -O0", "clif", "ryo aot", "ryo jit"]);
        assert_eq!(b[0].flags, ["-Copt-level=2", "-Cdebug-assertions=on"]);
        assert_eq!(b[3].env, [("RYO_JIT", "off")]);
        assert!(parse_options(&["--llvm", "O4"]).is_err());
        assert!(parse_options(&["--ryo", "x"]).is_err());
        assert!(parse_options(&["--runs", "0"]).is_err());
    }

    #[test]
    fn cachegrind_summary() {
        let e = "==1== I refs:        1,234\n==2== I refs: 10\n==1== I1  misses: 5\n";
        assert_eq!(parse_cachegrind(e), Some(1244));
        assert_eq!(parse_cachegrind("nothing"), None);
    }

    #[test]
    fn mean_and_stddev() {
        let s = stats(&[1.0, 2.0, 3.0]);
        assert_eq!(s, Stats { mean: 2.0, stddev: 1.0 });
        assert_eq!(stats(&[4.0]), Stats { mean: 4.0, stddev: 0.0 });
    }

    #[test]
    fn table_layout() {
        let s = |m| Stats { mean: m, stddev: 0.001 };
        let header = ["llvm -O0", "llvm -O3", "clif", "ryo"];
        let cells = || (0..header.len()).map(|i| Cell { compile: Some(s(i as f64)), ..Cell::default() }).collect();
        let t = table("t", &header, &[("fib", cells()), ("hashmap", cells())], |c| c.compile.map(ms));
        let lines: Vec<&str> = t.lines().collect();
        assert_eq!(lines[0], "t");
        assert!(lines[1].starts_with("program ") && lines[1].ends_with("  ryo"));
        assert!(lines[3].starts_with("fib      "));
        assert!(lines[4].ends_with("3000.0 ± 1.0"));
        assert_eq!(lines.len(), 5);
        let t = table("t", &header, &[("fib", cells())], |c| c.run.map(ms));
        assert!(t.lines().nth(3).unwrap().ends_with("  failed"));
    }
}
