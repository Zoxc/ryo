//! `y bench` (design/build.md#test-and-bench): each program under `tests/bench/` is compiled
//! and run with every [`Backend`], timing both, and the results are printed as tables.
//!
//! Timing uses hyperfine if it is on `PATH`, and otherwise a built-in timer (one warmup run,
//! then `runs` timed runs, mean and standard deviation of the wall time).

use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::Instant;

use crate::utils::{cmd, describe, exe_name, root};

pub const DEFAULT_RUNS: u32 = 5;

/// Programs `tests/bench/<name>.rs`. Each prints a result that must be the same for every
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
    name: &'static str,
    compiler: Compiler,
    flags: &'static [&'static str],
}

/// The first is the reference whose output the others must match.
const BACKENDS: &[Backend] = &[
    Backend { name: "llvm -O0", compiler: Compiler::Rustc, flags: &["-Copt-level=0"] },
    Backend { name: "llvm -O3", compiler: Compiler::Rustc, flags: &["-Copt-level=3"] },
    Backend { name: "clif", compiler: Compiler::Clif, flags: &[] },
    Backend { name: "ryo", compiler: Compiler::Ryo, flags: &[] },
];

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
}

impl Job {
    fn command(&self) -> Command {
        let mut c = cmd(&self.program);
        c.args(&self.args);
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
                    let status = c
                        .stdout(Stdio::null())
                        .stderr(Stdio::null())
                        .status()
                        .map_err(|e| format!("failed to run `{}`: {e}", describe(&c)))?;
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
                    std::iter::once(job.program.to_string_lossy().into_owned())
                        .chain(job.args.iter().cloned())
                        .map(|a| shell_quote(&a))
                        .collect();
                let mut c = cmd("hyperfine");
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
    let var = if times.len() > 1 {
        times.iter().map(|t| (t - mean) * (t - mean)).sum::<f64>() / (n - 1.0)
    } else {
        0.0
    };
    Stats { mean, stddev: var.sqrt() }
}

/// `mean` and `stddev` of the first result in hyperfine's `--export-json` output. A minimal
/// scan, not a JSON parser (`y` has no dependencies). `stddev` is `null` for a single run.
fn parse_hyperfine(json: &str) -> Option<Stats> {
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

/// A cell of the tables.
struct Cell {
    compile: Stats,
    run: Stats,
}

pub fn run(runs: u32) -> Result<(), String> {
    let root = root();
    let dist_bin = root.join("dist").join("bin");
    if !dist_bin.join(exe_name("rustc-ryo")).exists() {
        eprintln!("[y] bench: dist/ is missing, building it");
        crate::dist::build()?;
    }
    crate::clif::ensure()?;

    let out = root.join("target").join("bench");
    fs::create_dir_all(&out).map_err(|e| format!("creating {}: {e}", out.display()))?;
    let timer = if Command::new("hyperfine").arg("--version").output().is_ok_and(|o| o.status.success()) {
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
    let mut mismatches = Vec::new();
    for &program in PROGRAMS {
        let src = root.join("tests").join("bench").join(format!("{program}.rs"));
        let mut cells = Vec::new();
        let mut reference: Option<String> = None;
        for backend in BACKENDS {
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
            args.extend(backend.flags.iter().map(|f| f.to_string()));
            args.extend(["-o".to_owned(), path_str(&exe)?]);
            let compile = timer.measure(&Job { program: compiler, args }, runs)?;

            let output = run_once(&exe)?;
            match &reference {
                None => reference = Some(output),
                Some(r) if *r != output => mismatches.push(format!(
                    "{program} [{}] printed {output:?}, {} printed {r:?}",
                    backend.name, BACKENDS[0].name
                )),
                Some(_) => {}
            }
            let run = timer.measure(&Job { program: exe, args: Vec::new() }, runs)?;
            cells.push(Cell { compile, run });
        }
        rows.push((program, cells));
    }

    println!();
    print_table("compile time (ms, mean ± stddev)", &rows, |c| c.compile);
    println!();
    print_table("run time (ms, mean ± stddev)", &rows, |c| c.run);
    vm_benches();
    if !mismatches.is_empty() {
        return Err(format!("outputs differ:\n{}", mismatches.join("\n")));
    }
    Ok(())
}

/// Runs a benchmark binary once and returns its stdout.
fn run_once(exe: &Path) -> Result<String, String> {
    let res = Command::new(exe).output().map_err(|e| format!("failed to run {}: {e}", exe.display()))?;
    if !res.status.success() {
        return Err(format!("{} failed with {}", exe.display(), res.status));
    }
    Ok(String::from_utf8_lossy(&res.stdout).into_owned())
}

/// Hook for the VM dispatch microbenches (fib, sieve, sorting, hashmap run directly by the VM
/// interpreter), which need the VM.
fn vm_benches() {
    println!("\nVM dispatch benches: not available yet (they need the VM)");
}

fn path_str(p: &Path) -> Result<String, String> {
    p.to_str().map(str::to_owned).ok_or_else(|| format!("non-UTF-8 path {}", p.display()))
}

fn print_table(title: &str, rows: &[(&str, Vec<Cell>)], pick: impl Fn(&Cell) -> Stats) {
    print!("{}", table(title, rows, pick));
}

fn table(title: &str, rows: &[(&str, Vec<Cell>)], pick: impl Fn(&Cell) -> Stats) -> String {
    let mut lines: Vec<Vec<String>> = vec![
        std::iter::once("program".to_owned()).chain(BACKENDS.iter().map(|b| b.name.to_owned())).collect(),
    ];
    for (program, cells) in rows {
        let mut line = vec![program.to_string()];
        for cell in cells {
            let s = pick(cell);
            line.push(format!("{:.1} ± {:.1}", s.mean * 1e3, s.stddev * 1e3));
        }
        lines.push(line);
    }
    let cols = lines[0].len();
    let widths: Vec<usize> =
        (0..cols).map(|i| lines.iter().map(|l| l.get(i).map_or(0, |c| c.chars().count())).max().unwrap()).collect();
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
    }

    #[test]
    fn quoting() {
        assert_eq!(shell_quote("/a/b-c.rs"), "/a/b-c.rs");
        assert_eq!(shell_quote("a b"), "'a b'");
        assert_eq!(shell_quote("it's"), r"'it'\''s'");
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
        let cells = || (0..BACKENDS.len()).map(|i| Cell { compile: s(i as f64), run: s(0.0) }).collect();
        let t = table("t", &[("fib", cells()), ("hashmap", cells())], |c| c.compile);
        let lines: Vec<&str> = t.lines().collect();
        assert_eq!(lines[0], "t");
        assert!(lines[1].starts_with("program ") && lines[1].ends_with("  ryo"));
        assert!(lines[3].starts_with("fib      "));
        assert!(lines[4].ends_with("3000.0 ± 1.0"));
        assert_eq!(lines.len(), 5);
    }
}
