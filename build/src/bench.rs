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

use crate::crates::Backend as Compiler;
use crate::crates::stats::Summary;
use crate::utils::{cmd, describe, exe_name, root};

mod codegen;
pub use codegen::codegen;

pub const DEFAULT_RUNS: u32 = 5;

/// Programs `bench/<name>.rs`. Each prints a result that must be the same for every
/// backend.
const PROGRAMS: &[&str] = &["fib", "sieve", "sort", "hashmap"];

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
    /// Instructions and estimated cycles of one run (cachegrind with cache and branch
    /// simulation); compile time isn't measured.
    Cachegrind,
}

/// A `-Copt-level` for plain rustc or cg_clif: `O0`..`O3`, a `d` suffix (`O2d`) turning on
/// debug assertions (and with them overflow checks, as at `O0`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct OptLevel {
    opt: u8,
    debug_assertions: bool,
}

impl OptLevel {
    fn parse(s: &str) -> Result<OptLevel, String> {
        let (level, debug_assertions) = s.strip_suffix('d').map_or((s, false), |l| (l, true));
        match level.strip_prefix('O').and_then(|n| n.parse().ok()).filter(|&n| n <= 3) {
            Some(opt) => Ok(OptLevel { opt, debug_assertions }),
            None => Err(format!("bad opt level `{s}` (expected O0..O3, optionally with a `d` suffix)")),
        }
    }
}

impl std::fmt::Display for OptLevel {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "O{}{}", self.opt, if self.debug_assertions { "d" } else { "" })
    }
}

/// How ryo runs the program: `aot` (`RYO_JIT=off`) or `jit` (`RYO_JIT_OPT=ssa`, plus
/// `RYO_JIT_SYNC=1` under cachegrind).
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum RyoMode {
    Aot,
    Jit,
}

/// `y bench [--runs N] [--llvm LEVELS] [--clif [LEVELS]] [--ryo MODES] [--metric time|cachegrind]`.
#[derive(Clone, Debug, PartialEq)]
pub struct Options {
    pub runs: u32,
    pub llvm: Vec<OptLevel>,
    /// cg_clif's levels; a bare `--clif` is `O0`.
    pub clif: Vec<OptLevel>,
    pub ryo: Vec<RyoMode>,
    pub metric: Metric,
}

impl Default for Options {
    /// The default columns: LLVM -O0 and -O1, cg_clif -O0 and ryo as it runs by default.
    fn default() -> Self {
        Options { runs: DEFAULT_RUNS, llvm: Vec::new(), clif: Vec::new(), ryo: Vec::new(), metric: Metric::Time }
    }
}

pub fn parse_options(args: &[&str]) -> Result<Options, String> {
    let mut o = Options::default();
    let mut args = crate::utils::Flags::new(args);
    while let Some(flag) = args.next()? {
        let list = |v: &str| v.split(',').filter(|s| !s.is_empty()).map(str::to_owned).collect::<Vec<_>>();
        match flag {
            "--runs" => {
                let n = args.value()?;
                o.runs = n.parse().ok().filter(|&r| r > 0).ok_or(format!("bad run count `{n}`"))?;
            }
            "--llvm" => {
                for l in list(args.value()?) {
                    o.llvm.push(OptLevel::parse(&l)?);
                }
            }
            "--clif" => match args.optional_value() {
                None => o.clif.push(OptLevel { opt: 0, debug_assertions: false }),
                Some(v) => {
                    for l in list(v) {
                        o.clif.push(OptLevel::parse(&l)?);
                    }
                }
            },
            "--ryo" => {
                for m in list(args.value()?) {
                    o.ryo.push(match m.as_str() {
                        "aot" => RyoMode::Aot,
                        "jit" => RyoMode::Jit,
                        _ => return Err(format!("bad ryo mode `{m}` (expected aot or jit)")),
                    });
                }
            }
            "--metric" => {
                o.metric = match args.value()? {
                    "time" => Metric::Time,
                    "cachegrind" => Metric::Cachegrind,
                    m => return Err(format!("unknown metric `{m}`")),
                }
            }
            _ => return Err(args.unexpected()),
        }
    }
    Ok(o)
}

/// The columns `o` selects; the first is the reference whose output the others must match.
/// Without `--llvm`, `--clif` or `--ryo`, the default columns.
fn backends(o: &Options) -> Vec<Backend> {
    let with = |compiler: Compiler, name: &str, level: OptLevel| {
        let mut flags = vec![format!("-Copt-level={}", level.opt)];
        if level.debug_assertions {
            flags.push("-Cdebug-assertions=on".to_owned());
        }
        Backend { name: format!("{name} -{level}"), compiler, flags, env: Vec::new() }
    };
    let rustc = |level| with(Compiler::Llvm, "llvm", level);
    let clif = |level| with(Compiler::Clif, "clif", level);
    if o.llvm.is_empty() && o.clif.is_empty() && o.ryo.is_empty() {
        // Under cachegrind the counts depend on when a background JIT thread finishes.
        let env = if o.metric == Metric::Cachegrind { vec![("RYO_JIT_OPT", "ssa"), ("RYO_JIT_SYNC", "1")] } else { Vec::new() };
        let ryo = Backend { name: "ryo".to_owned(), compiler: Compiler::Ryo, flags: Vec::new(), env };
        let level = |opt| OptLevel { opt, debug_assertions: false };
        return vec![rustc(level(0)), rustc(level(1)), clif(level(0)), ryo];
    }
    let mut v: Vec<Backend> = o.llvm.iter().map(|&l| rustc(l)).chain(o.clif.iter().map(|&l| clif(l))).collect();
    for &m in &o.ryo {
        let (name, env) = match m {
            RyoMode::Aot => ("aot", vec![("RYO_JIT", "off")]),
            // Under cachegrind the counts depend on when a background JIT thread finishes.
            RyoMode::Jit if o.metric == Metric::Cachegrind => ("jit", vec![("RYO_JIT_OPT", "ssa"), ("RYO_JIT_SYNC", "1")]),
            RyoMode::Jit => ("jit", vec![("RYO_JIT_OPT", "ssa")]),
        };
        v.push(Backend { name: format!("ryo {name}"), compiler: Compiler::Ryo, flags: Vec::new(), env });
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

/// How a benchmark is measured: timed (hyperfine or the built-in timer), or one run's
/// instructions and estimated cycles counted (`Metric::Cachegrind`, compilation untimed).
enum Timer {
    Hyperfine { json: PathBuf },
    Builtin,
    Cachegrind,
}

impl Timer {
    /// Compiles with `job`, filling `cell.compile` if timed.
    fn compile(&self, job: &Job, runs: u32, cell: &mut Cell) -> Result<(), String> {
        match self {
            Timer::Cachegrind => crate::utils::run(&mut job.command()),
            _ => {
                cell.compile = Some(self.measure(job, runs)?);
                Ok(())
            }
        }
    }

    /// Runs the program with `job`, filling `cell.run` or `cell.ir`. Errors are prefixed by
    /// what failed.
    fn run(&self, job: &Job, runs: u32, cell: &mut Cell) -> Result<(), String> {
        match self {
            Timer::Cachegrind => {
                cell.ir = Some(cachegrind(job).map_err(|e| format!("cachegrind: {e}"))?);
                Ok(())
            }
            _ => {
                cell.run = Some(self.measure(job, runs).map_err(|e| format!("run: {e}"))?);
                Ok(())
            }
        }
    }

    fn measure(&self, job: &Job, runs: u32) -> Result<Stats, String> {
        match self {
            Timer::Cachegrind => unreachable!("cachegrind doesn't time"),
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
                // `runs` is at least 1.
                let s = Summary::of(&times).unwrap();
                Ok(Stats { mean: s.mean, stddev: s.stddev })
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

/// A cell of the tables. `None` where building or running failed (or wasn't measured).
#[derive(Default)]
struct Cell {
    compile: Option<Stats>,
    run: Option<Stats>,
    /// Cachegrind counts of one run (`Metric::Cachegrind`).
    ir: Option<Counts>,
}

pub fn run(opts: &Options) -> Result<(), String> {
    let root = root();
    let backends = backends(opts);
    crate::crates::ensure_tools(&root, "bench", backends.iter().map(|b| b.compiler))?;
    let runs = opts.runs;

    let out = root.join("target").join("bench");
    crate::utils::create_dir(&out)?;
    let timer = if opts.metric == Metric::Cachegrind {
        eprintln!("[y] bench: counting instructions and est. cycles of one run with cachegrind (cache and branch simulation)");
        Timer::Cachegrind
    } else if Command::new("hyperfine").arg("--version").output().is_ok_and(|o| o.status.success()) {
        eprintln!("[y] bench: timing with hyperfine, {runs} runs after 1 warmup");
        Timer::Hyperfine { json: out.join("hyperfine.json") }
    } else {
        eprintln!(
            "[y] bench: hyperfine is not installed; timing with the built-in timer \
             ({runs} runs after 1 warmup, mean and standard deviation of wall time)"
        );
        Timer::Builtin
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
            crate::utils::create_dir(&dir)?;
            let exe = dir.join(exe_name(program));
            let compiler = backend.compiler.rustc(&root);
            let mut args = vec!["--edition=2024".to_owned(), path_str(&src)?];
            args.extend(COMMON_FLAGS.iter().map(|f| f.to_string()).chain(backend.flags.iter().cloned()));
            args.extend(["-o".to_owned(), path_str(&exe)?]);
            let _ = fs::remove_file(&exe);
            let name = format!("{program} [{}]", backend.name);
            let mut failed = |what: &str, e: String| failures.push(format!("{name}: {what}: {e}"));
            let compile_job = Job { program: compiler, args, env: Vec::new() };
            let mut cell = Cell::default();
            let built = timer.compile(&compile_job, runs, &mut cell).map_err(|e| failed("compile", e)).is_ok();
            let output = if built { run_once(&exe, &backend.env).map_err(|e| failed("run", e)).ok() } else { None };
            if let Some(output) = output {
                match &reference {
                    None => reference = Some(output),
                    Some(r) if *r != output => failures.push(format!("{name} printed {output:?}, {} printed {r:?}", backends[0].name)),
                    Some(_) => {}
                }
                let job = Job { program: exe, args: Vec::new(), env: backend.env.clone() };
                if let Err(e) = timer.run(&job, runs, &mut cell) {
                    failures.push(format!("{name}: {e}"));
                }
            }
            cells.push(cell);
        }
        rows.push((program, cells));
    }

    let header: Vec<&str> = backends.iter().map(|b| b.name.as_str()).collect();
    println!();
    match timer {
        Timer::Hyperfine { .. } | Timer::Builtin => {
            print!("{}", table("compile time (ms, mean ± stddev)", &header, &rows, |c| c.compile.map(ms)));
            println!();
            print!("{}", table("run time (ms, mean ± stddev)", &header, &rows, |c| c.run.map(ms)));
        }
        Timer::Cachegrind => {
            let millions = |n: u64| format!("{:.1}", n as f64 / 1e6);
            print!("{}", table("run instructions (cachegrind Ir, millions)", &header, &rows, |c| c.ir.map(|n| millions(n.instructions))));
            println!();
            print!("{}", table("run est. cycles (millions)", &header, &rows, |c| c.ir.map(|n| millions(n.est_cycles()))));
            for (what, get) in [("instructions", Counts::instructions as fn(&Counts) -> u64), ("est. cycles", Counts::est_cycles)] {
                println!();
                let title = format!("run {what} relative to {}", header[0]);
                let base: HashMap<&str, Option<u64>> = rows.iter().map(|(p, c)| (*p, c[0].ir.as_ref().map(get))).collect();
                let ratio_rows: Vec<(&str, Vec<Option<String>>)> = rows
                    .iter()
                    .map(|(p, cells)| (*p, cells.iter().map(|c| Some(format!("{:.2}x", get(c.ir.as_ref()?) as f64 / base[p]? as f64))).collect()))
                    .collect();
                print!("{}", grid(&title, &header, &ratio_rows));
            }
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

/// The cachegrind counts of one run, summed over its processes.
#[derive(Clone, Copy, Debug, Default, PartialEq)]
struct Counts {
    instructions: u64,
    i1_misses: u64,
    d1_misses: u64,
    ll_misses: u64,
    mispredicts: u64,
}

// Weights of the cycle estimate: callgrind's usual heuristic (KCachegrind's "Cycle
// Estimation"), not a model of any real CPU. Keep in sync with `est_cycles` in
// scripts/compare-branches.py, so both tools report the same numbers.
const L1_MISS_CYCLES: u64 = 10;
const LL_MISS_CYCLES: u64 = 100;
const MISPREDICT_CYCLES: u64 = 10;

impl Counts {
    fn instructions(&self) -> u64 {
        self.instructions
    }

    /// Instructions plus weighted I1/D1 misses, LL misses and branch mispredictions.
    fn est_cycles(&self) -> u64 {
        self.instructions
            + L1_MISS_CYCLES * (self.i1_misses + self.d1_misses)
            + LL_MISS_CYCLES * self.ll_misses
            + MISPREDICT_CYCLES * self.mispredicts
    }
}

/// The counts of `job`'s run, its children included, with cachegrind's cache and branch
/// simulation (as `compare-branches.py --metric cachegrind`).
fn cachegrind(job: &Job) -> Result<Counts, String> {
    let mut c = cmd("valgrind");
    c.args(["--tool=cachegrind", "--vgdb=no", "--cache-sim=yes", "--branch-sim=yes", "--trace-children=yes", "--cachegrind-out-file=/dev/null"])
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

/// The sums of the summary lines (`==pid== I refs:  1,234`, `==pid== Mispredicts:  56 (..)`)
/// of every process; `None` without an `I refs:` line.
fn parse_cachegrind(stderr: &str) -> Option<Counts> {
    let mut c = Counts::default();
    let mut found = false;
    for line in stderr.lines().filter(|l| l.starts_with("==")) {
        let fields: [(&str, &mut u64); 5] = [
            ("I refs:", &mut c.instructions),
            ("I1  misses:", &mut c.i1_misses),
            ("D1  misses:", &mut c.d1_misses),
            ("LL misses:", &mut c.ll_misses),
            ("Mispredicts:", &mut c.mispredicts),
        ];
        for (key, field) in fields {
            if let Some((_, rest)) = line.split_once(key)
                && let Some(n) = rest.split_whitespace().next().and_then(|n| n.replace(',', "").parse::<u64>().ok())
            {
                *field += n;
                found |= key == "I refs:";
            }
        }
    }
    found.then_some(c)
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
    format!("{title}\n{}", crate::utils::text_table(&lines, true))
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
        assert_eq!(backends(&o).iter().map(|b| b.name.as_str()).collect::<Vec<_>>(), ["llvm -O0", "llvm -O1", "clif -O0", "ryo"]);
        let o = parse_options(&["--llvm", "O2d,O0", "--clif", "--ryo=aot,jit", "--metric", "cachegrind", "--runs=2"]).unwrap();
        assert_eq!((o.runs, o.metric), (2, Metric::Cachegrind));
        let b = backends(&o);
        assert_eq!(b.iter().map(|b| b.name.as_str()).collect::<Vec<_>>(), ["llvm -O2d", "llvm -O0", "clif -O0", "ryo aot", "ryo jit"]);
        assert_eq!(b[0].flags, ["-Copt-level=2", "-Cdebug-assertions=on"]);
        assert_eq!(b[3].env, [("RYO_JIT", "off")]);
        let o = parse_options(&["--clif", "O0,O3d", "--clif=O1", "--clif", "--runs", "1"]).unwrap();
        let b = backends(&o);
        assert_eq!(b.iter().map(|b| b.name.as_str()).collect::<Vec<_>>(), ["clif -O0", "clif -O3d", "clif -O1", "clif -O0"]);
        assert_eq!(b[1].flags, ["-Copt-level=3", "-Cdebug-assertions=on"]);
        assert!(parse_options(&["--clif", "O4"]).is_err());
        assert!(parse_options(&["--llvm", "O4"]).is_err());
        let o = parse_options(&["--metric", "cachegrind"]).unwrap();
        assert_eq!(backends(&o)[3].env, [("RYO_JIT_OPT", "ssa"), ("RYO_JIT_SYNC", "1")]);
        assert!(parse_options(&["--ryo", "x"]).is_err());
        assert!(parse_options(&["--runs", "0"]).is_err());
    }

    #[test]
    fn cachegrind_summary() {
        let e = "==1== I refs:        1,234\n==2== I refs: 10\n==1== I1  misses: 5\n==1== LLi misses: 7\n\
                 ==1== D1  misses: 3 ( 2 rd + 1 wr)\n==1== LL misses: 2 ( 1 rd + 1 wr)\n==1== Mispredicts: 1,000 ( 900 cond + 100 ind)\n";
        let c = Counts { instructions: 1244, i1_misses: 5, d1_misses: 3, ll_misses: 2, mispredicts: 1000 };
        assert_eq!(parse_cachegrind(e), Some(c));
        assert_eq!(c.est_cycles(), 1244 + 80 + 200 + 10000);
        assert_eq!(parse_cachegrind("nothing"), None);
    }

    #[test]
    fn table_layout() {
        let s = |m| Stats { mean: m, stddev: 0.001 };
        let header = ["llvm -O0", "llvm -O1", "clif -O0", "ryo"];
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
