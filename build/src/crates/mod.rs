//! `y bench crates` (design/build.md#bench-crates): builds, tests and runs pinned crates.io
//! crates with LLVM, Cranelift and ryo in cargo's `dev` profile, and writes an HTML report.

mod html;
pub mod stats;
pub mod timing;

use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::sync::mpsc;
use std::time::{Duration, Instant};

use crate::utils::{RustcInfo, cmd, exe_name, output, root};
use timing::{Unit, WRAPPER_VAR};

/// A benchmarked crate: a crates.io release, pinned by version and checksum. The `.crate`
/// archive includes the `Cargo.lock` it was published with, which pins the dependencies; the
/// build uses `--locked`. `tests/crates/<name>.rs` is its workload, built as an example.
pub struct Crate {
    pub name: &'static str,
    pub version: &'static str,
    pub sha256: &'static str,
    /// Why it was picked.
    pub why: &'static str,
    /// Extra arguments for every test binary.
    pub test_args: &'static [&'static str],
}

/// What is benchmarked: a [`Crate`] from [`CRATES`], or a local workspace (`--path`), built
/// in place with `--workspace`: every member is the leaf, everything else a dependency. A
/// local workspace has no workload.
pub enum Target {
    Registry(&'static Crate),
    Local { name: String, dir: PathBuf },
}

impl Target {
    /// The local workspace at `path`, named after its directory.
    fn local(path: &Path) -> Result<Target, String> {
        let dir = fs::canonicalize(path).map_err(|e| format!("{}: {e}", path.display()))?;
        let name = dir.file_name().map(|n| n.to_string_lossy().into_owned()).ok_or("bad --path")?;
        Ok(Target::Local { name, dir })
    }

    pub fn name(&self) -> &str {
        match self {
            Target::Registry(c) => c.name,
            Target::Local { name, .. } => name,
        }
    }

    pub fn version(&self) -> &str {
        match self {
            Target::Registry(c) => c.version,
            Target::Local { .. } => "local",
        }
    }

    pub fn why(&self) -> String {
        match self {
            Target::Registry(c) => c.why.to_owned(),
            Target::Local { dir, .. } => format!("local workspace {}", dir.display()),
        }
    }

    /// Extra arguments for every test binary.
    pub fn test_args(&self) -> &'static [&'static str] {
        match self {
            Target::Registry(c) => c.test_args,
            Target::Local { .. } => &[],
        }
    }
}

pub const CRATES: &[Crate] = &[
    Crate {
        name: "semver",
        version: "1.0.28",
        sha256: "8a7852d02fc848982e0c167ef163aaff9cd91dc640ba85e263cb1ce46fae51cd",
        why: "parsing and ordering; no dependencies",
        test_args: &[],
    },
    Crate {
        name: "smallvec",
        version: "1.15.1",
        sha256: "67b1b7a3b5fe4f1376887184045fcf45c69e92af734b7aaddc05fb777b6fbd03",
        why: "unsafe container code, generic over arrays",
        test_args: &[],
    },
    Crate {
        name: "miniz_oxide",
        version: "0.9.1",
        sha256: "b63fbc4a50860e98e7b2aa7804ded1db5cbc3aff9193adaff57a6931bf7c4b4c",
        why: "deflate/inflate: tight integer loops",
        test_args: &[],
    },
    Crate {
        name: "memchr",
        version: "2.8.3",
        sha256: "cf8baf1c55e62ffcace7a9f06f4bd9cd3f0c4beb022d3b367256b91b87513d98",
        why: "SIMD intrinsics (islands) and runtime CPU feature detection",
        // Five exhaustive tests take 115 of the suite's 120 s with LLVM at opt-level 0.
        test_args: &["--skip", "forward_packedpair"],
    },
    Crate {
        name: "hashbrown",
        version: "0.17.1",
        sha256: "ed5909b6e89a2db4456e54cd5f673791d7eca6732202bbf2a9cc504fe2f9b84a",
        why: "std's HashMap; SSE2 group probing, heavy generics",
        test_args: &[],
    },
    Crate {
        name: "rand",
        version: "0.10.3",
        sha256: "65c9fb96cbc91e3478eaae79a69fcd3f1ae4ad052e471fe6732fff548984b4af",
        why: "ChaCha and xoshiro generators, getrandom (syscalls), traits",
        test_args: &[],
    },
    Crate {
        name: "regex-syntax",
        version: "0.8.11",
        sha256: "d6f6ff9a378485b298a5286656da665ba74413d36db0979633275d2e708145d4",
        why: "a parser with large Unicode tables; regex's front half",
        test_args: &[],
    },
    Crate {
        name: "unicode-segmentation",
        version: "1.13.3",
        sha256: "c6f5d3c3b1bf09027a88a6bc961fc00497d651009560b5463668dc81b0fa87a8",
        why: "table-driven state machines over UTF-8",
        test_args: &[],
    },
    Crate {
        name: "serde_json",
        version: "1.0.154",
        sha256: "e7e9cc8b1b85264074fbcc02a88680c4096b1e47df8f739dceb03bf482f04bd6",
        why: "serde's trait-heavy codegen, proc-macro dev-deps (serde_derive)",
        test_args: &[],
    },
];

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Backend {
    Llvm,
    Clif,
    Ryo,
}

pub const BACKENDS: &[Backend] = &[Backend::Llvm, Backend::Clif, Backend::Ryo];

impl Backend {
    pub fn name(self) -> &'static str {
        match self {
            Backend::Llvm => "llvm",
            Backend::Clif => "clif",
            Backend::Ryo => "ryo",
        }
    }

    pub fn parse(s: &str) -> Option<Backend> {
        BACKENDS.iter().copied().find(|b| b.name() == s)
    }

    pub fn rustc(self, root: &Path) -> PathBuf {
        match self {
            Backend::Llvm => "rustc".into(),
            Backend::Clif => crate::utils::dist_bin(root, "rustc-clif"),
            Backend::Ryo => crate::utils::dist_bin(root, "rustc-ryo"),
        }
    }
}

/// Builds `dist/` if it is missing, and rustc-clif if a backend needs it.
pub fn ensure_tools(root: &Path, cmd: &str, mut backends: impl Iterator<Item = Backend>) -> Result<(), String> {
    if !Backend::Ryo.rustc(root).exists() {
        eprintln!("[y] {cmd}: dist/ is missing, building it");
        crate::dist::build(&Default::default())?;
    }
    if backends.any(|b| b == Backend::Clif) {
        crate::clif::ensure()?;
    }
    Ok(())
}

#[derive(Debug, PartialEq)]
pub struct Options {
    /// Builds from a clean target directory: the dependencies and the crate.
    pub dep_samples: u32,
    /// Builds of only the crate, its dependencies already built.
    pub leaf_samples: u32,
    /// 0 skips the tests and the workload.
    pub run_samples: u32,
    pub crates: Vec<String>,
    pub backends: Vec<Backend>,
    /// Per test binary or workload run, in seconds.
    pub timeout: u64,
    pub out: Option<PathBuf>,
    /// A local workspace to bench instead of `crates`.
    pub path: Option<PathBuf>,
    /// Cargo's and rustc's defaults: no `RUSTFLAGS`, profile, job or incremental settings;
    /// only the backend is changed (an unfair comparison).
    pub stock: bool,
}

/// Crates run without `--crates`: tight integer loops (miniz_oxide), generic hashing and
/// probing (hashbrown), and a large enum-heavy parser (regex-syntax).
pub const DEFAULT_CRATES: &[&str] = &["miniz_oxide", "hashbrown", "regex-syntax"];

pub const DEFAULT_DEP_SAMPLES: u32 = 5;
pub const DEFAULT_LEAF_SAMPLES: u32 = 5;
pub const DEFAULT_RUN_SAMPLES: u32 = 10;
pub const DEFAULT_TIMEOUT: u64 = 1800;

pub const USAGE: &str = "\
  bench crates [--dep-samples N] [--leaf-samples N] [--build-samples N (both)] [--run-samples N (0: no runs)] [--quick] [--crates a,b|all] [--backends llvm,clif,ryo]
               [--path DIR (a local workspace instead: members are the leaf)] [--timeout SECS] [--out FILE] [--stock (cargo/rustc defaults, only RUSTC changed)]
                               build, test and run pinned crates.io crates with each backend
                               (default llvm,ryo; dev profile); writes an HTML report";

pub fn parse_options(args: &[&str]) -> Result<Options, String> {
    let mut o = Options {
        dep_samples: DEFAULT_DEP_SAMPLES,
        leaf_samples: DEFAULT_LEAF_SAMPLES,
        run_samples: DEFAULT_RUN_SAMPLES,
        crates: DEFAULT_CRATES.iter().map(|c| c.to_string()).collect(),
        // cg_clif only when asked for (`--backends`), so the default needs no `build-clif`.
        backends: vec![Backend::Llvm, Backend::Ryo],
        timeout: DEFAULT_TIMEOUT,
        out: None,
        path: None,
        stock: false,
    };
    let mut args = crate::utils::Flags::new(args);
    while let Some(flag) = args.next()? {
        let count0 = |v: &str| v.parse::<u32>().map_err(|_| format!("bad count `{v}`"));
        let count = |v: &str| count0(v).ok().filter(|&n| n > 0).ok_or(format!("bad count `{v}`"));
        match flag {
            "--dep-samples" => o.dep_samples = count0(args.value()?)?,
            "--leaf-samples" => o.leaf_samples = count(args.value()?)?,
            "--build-samples" => o.dep_samples = count(args.value()?).inspect(|&n| o.leaf_samples = n)?,
            "--run-samples" => o.run_samples = count0(args.value()?)?,
            "--quick" => (o.dep_samples, o.leaf_samples, o.run_samples) = (1, 1, 1),
            "--timeout" => o.timeout = args.value()?.parse().ok().filter(|&n| n > 0).ok_or("bad timeout")?,
            "--out" => o.out = Some(args.value()?.into()),
            "--path" => o.path = Some(args.value()?.into()),
            "--stock" => o.stock = true,
            "--crates" => {
                o.crates.clear();
                let v = args.value()?;
                if v == "all" {
                    o.crates = CRATES.iter().map(|c| c.name.to_owned()).collect();
                    continue;
                }
                for c in v.split(',') {
                    if !CRATES.iter().any(|k| k.name == c) {
                        return Err(format!("unknown crate `{c}`"));
                    }
                    o.crates.push(c.to_owned());
                }
            }
            "--backends" => {
                o.backends.clear();
                for b in args.value()?.split(',') {
                    o.backends.push(Backend::parse(b).ok_or(format!("unknown backend `{b}`"))?);
                }
            }
            _ => return Err(args.unexpected()),
        }
    }
    Ok(o)
}

/// One timed `cargo build` step.
#[derive(Clone, Debug)]
pub struct Step {
    /// Wall time of the cargo invocation.
    pub wall: f64,
    pub units: Vec<Unit>,
}

/// One build sample's steps.
#[derive(Clone, Debug)]
pub struct BuildSteps {
    /// `cargo build --lib` (`cargo build --workspace` for a local workspace).
    pub lib: Step,
    /// `cargo build --tests`.
    pub tests: Step,
}

/// `cargo test` results of one backend, from its warm-up run.
#[derive(Clone, Debug, Default)]
pub struct TestOutcome {
    pub binaries: usize,
    pub passed: u64,
    pub failed: u64,
    pub ignored: u64,
    /// Failed binaries and tests (`binary: test`), or crashes and timeouts.
    pub failures: Vec<String>,
}

/// The part of a crate's measurement an error happened in.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Phase {
    Prepare,
    Build,
    Test,
    Workload,
}

impl Phase {
    pub fn name(self) -> &'static str {
        match self {
            Phase::Prepare => "prepare",
            Phase::Build => "build",
            Phase::Test => "test",
            Phase::Workload => "workload",
        }
    }
}

/// A build or run error of a [`Cell`]; displays as `<phase>: <message>`.
pub struct CellError {
    pub phase: Phase,
    pub msg: String,
}

impl CellError {
    pub fn new(phase: Phase, msg: impl Into<String>) -> Self {
        CellError { phase, msg: msg.into() }
    }
}

impl std::fmt::Display for CellError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.phase.name(), self.msg)
    }
}

/// Everything measured for one crate and backend.
#[derive(Default)]
pub struct Cell {
    /// Build or run errors. A failed build stops the backend for this crate.
    pub errors: Vec<CellError>,
    pub build_failed: bool,
    /// `cargo build --lib` from a clean target directory.
    pub dep_build: Vec<Step>,
    /// `cargo build --lib` of only the crate.
    pub build: Vec<Step>,
    /// `cargo build --tests`, after `build` in the same target directory.
    pub test_build: Vec<Step>,
    /// The warm-up's steps (ryo's ran with `RYO_STATS=1`).
    pub warmup: Option<BuildSteps>,
    /// Sum over the test binaries, per sample.
    pub test_run: Vec<f64>,
    pub workload: Vec<f64>,
    pub tests: Option<TestOutcome>,
    pub workload_output: Option<String>,
    pub workload_size: Option<u64>,
    pub tests_size: Option<u64>,
}

pub struct CrateResult {
    pub krate: Target,
    /// Indexed like `Report::backends`.
    pub cells: Vec<Cell>,
}

pub struct Report {
    pub backends: Vec<Backend>,
    pub crates: Vec<CrateResult>,
    /// `(key, value)` lines for the header: toolchain, flags, machine, date.
    pub header: Vec<(String, String)>,
    pub total_time: f64,
}

/// `RUSTFLAGS` for every backend and every crate (dependencies, build scripts and proc macros
/// included, since no `--target` is passed).
pub const RUSTFLAGS: &str = "-Cdebuginfo=0 -Ccodegen-units=1 -Zthreads=1";

/// The `dev` profile (and `test`, which inherits it, but some crates override it, e.g.
/// memchr's `opt-level = 3`) pinned, so a crate's own `[profile]` can't change it: cargo's
/// `dev` defaults, except no debuginfo, one codegen unit and no incremental compilation
/// (matching [`RUSTFLAGS`]).
const PROFILE_ENV: &[(&str, &str)] = &[
    ("OPT_LEVEL", "0"),
    ("DEBUG", "0"),
    ("DEBUG_ASSERTIONS", "true"),
    ("OVERFLOW_CHECKS", "true"),
    ("CODEGEN_UNITS", "1"),
    ("LTO", "false"),
    ("PANIC", "unwind"),
    ("INCREMENTAL", "false"),
];

/// Variables that would change what is measured if inherited.
const CLEARED_ENV: &[&str] = &[
    "RUSTFLAGS",
    "CARGO_ENCODED_RUSTFLAGS",
    "CARGO_BUILD_RUSTFLAGS",
    "RUSTC_WRAPPER",
    "RUSTC_WORKSPACE_WRAPPER",
    "CARGO_BUILD_TARGET",
    "CARGO_BUILD_RUSTC_WRAPPER",
    "RYO_STATS",
    "RYO_NO_VM",
    "RUST_TEST_THREADS",
    "RUST_BACKTRACE",
];

pub fn run(opts: Options) -> Result<(), String> {
    let started = Instant::now();
    let info = RustcInfo::get()?;
    let root = root();
    ensure_tools(&root, "bench crates", opts.backends.iter().copied())?;
    let base = root.join("target").join("bench-crates");
    let selected: Vec<Target> = match &opts.path {
        Some(path) => vec![Target::local(path)?],
        None => CRATES.iter().filter(|c| opts.crates.iter().any(|n| n == c.name)).map(Target::Registry).collect(),
    };
    let y = std::env::current_exe().map_err(|e| format!("current_exe: {e}"))?;
    let header = header(&info, &root, &opts);
    let ctx = Ctx { info: &info, root: &root, y: &y, base: &base, opts: &opts };

    let mut results = Vec::new();
    for krate in selected {
        let mut cells: Vec<Cell> = opts.backends.iter().map(|_| Cell::default()).collect();
        let prepared = match &krate {
            Target::Local { dir, .. } => prepare_local(dir),
            Target::Registry(c) => prepare(&root, &base, c),
        };
        match prepared {
            Ok(sources) => {
                let artifacts = build_phase(&ctx, &krate, &sources, &mut cells);
                run_phase(&ctx, &krate, &sources, &artifacts, &mut cells);
                check_workload_outputs(&mut cells, &opts.backends);
            }
            Err(e) => {
                eprintln!("[y] {}: preparing the sources FAILED: {e}", krate.name());
                for cell in &mut cells {
                    cell.errors.push(CellError::new(Phase::Prepare, e.to_string()));
                    cell.build_failed = true;
                }
            }
        }
        results.push(CrateResult { krate, cells });
    }

    let report = Report { backends: opts.backends.clone(), crates: results, header, total_time: started.elapsed().as_secs_f64() };
    let out = opts.out.clone().unwrap_or_else(|| base.join("report.html"));
    crate::utils::write(&out, html::render(&report))?;
    print!("{}", html::text_summary(&report));
    println!("\nreport: {}", out.display());
    Ok(())
}

/// What every crate's measurement needs.
struct Ctx<'a> {
    info: &'a RustcInfo,
    root: &'a Path,
    /// This executable, the `RUSTC_WRAPPER`.
    y: &'a Path,
    /// `target/bench-crates`.
    base: &'a Path,
    opts: &'a Options,
}

/// The executables a backend's last build sample produced.
#[derive(Default)]
struct Artifacts {
    test_exes: Vec<PathBuf>,
    /// The workload, if the target has one.
    example: Option<PathBuf>,
}

/// Builds, backends interleaved: one warm-up from a clean target directory (ryo's collects
/// RYO_STATS), the dependency samples (clean too), then the leaf samples, each rebuilding only
/// the crate itself. Records the samples and executable sizes in `cells`; returns each
/// backend's executables.
fn build_phase(ctx: &Ctx, krate: &Target, sources: &Sources, cells: &mut [Cell]) -> Vec<Artifacts> {
    let opts = ctx.opts;
    let mut artifacts: Vec<Artifacts> = cells.iter().map(|_| Artifacts::default()).collect();
    for i in 0..=opts.dep_samples + opts.leaf_samples {
        let clean = i <= opts.dep_samples;
        for (bi, &backend) in opts.backends.iter().enumerate() {
            let cell = &mut cells[bi];
            if cell.build_failed {
                continue;
            }
            let label = match i {
                0 => "warm-up".to_owned(),
                _ if clean => format!("clean {i}/{}", opts.dep_samples),
                _ => format!("leaf {}/{}", i - opts.dep_samples, opts.leaf_samples),
            };
            let target = ctx.base.join("target").join(krate.name()).join(backend.name());
            let env = Env {
                info: ctx.info,
                root: ctx.root,
                y: ctx.y,
                backend,
                target: &target,
                src: &sources.dir,
                stock: opts.stock,
                overrides: &sources.overrides,
            };
            let t = Instant::now();
            match build_sample(&env, sources, &ctx.base.join("logs"), clean, i == 0 && backend == Backend::Ryo) {
                Ok(sample) => {
                    eprintln!("[y] {} build {label} [{}]: {:.1}s", krate.name(), backend.name(), t.elapsed().as_secs_f64());
                    artifacts[bi] = sample.artifacts;
                    if i == 0 {
                        cell.warmup = Some(sample.steps);
                    } else if clean {
                        cell.dep_build.push(sample.steps.lib);
                    } else {
                        cell.build.push(sample.steps.lib);
                        cell.test_build.push(sample.steps.tests);
                    }
                }
                Err(e) => {
                    eprintln!("[y] {} build {label} [{}]: FAILED", krate.name(), backend.name());
                    cell.errors.push(CellError::new(Phase::Build, e.to_string()));
                    cell.build_failed = true;
                }
            }
        }
    }
    let size = |e: &PathBuf| fs::metadata(e).ok().map(|m| m.len());
    for (cell, a) in cells.iter_mut().zip(&artifacts) {
        cell.tests_size = (!a.test_exes.is_empty()).then(|| a.test_exes.iter().filter_map(size).sum());
        cell.workload_size = a.example.as_ref().and_then(size);
    }
    artifacts
}

/// Runs: one warm-up (which records the test results and the workload's output), then the
/// samples, backends interleaved.
fn run_phase(ctx: &Ctx, krate: &Target, sources: &Sources, artifacts: &[Artifacts], cells: &mut [Cell]) {
    let opts = ctx.opts;
    for i in (0..=opts.run_samples).filter(|_| opts.run_samples > 0) {
        for (bi, &backend) in opts.backends.iter().enumerate() {
            let (cell, a) = (&mut cells[bi], &artifacts[bi]);
            if cell.build_failed {
                continue;
            }
            let label = if i == 0 { "warm-up".to_owned() } else { format!("{i}/{}", opts.run_samples) };
            let (time, outcome) = run_tests(&sources.dir, krate, &a.test_exes, opts.timeout);
            let tests = if outcome.failures.is_empty() { format!("{time:.2}s") } else { format!("{time:.2}s (failed)") };
            if i == 0 {
                cell.errors.extend(outcome.failures.iter().map(|f| CellError::new(Phase::Test, f.clone())));
                cell.tests = Some(outcome);
            } else if outcome.failures.is_empty() {
                cell.test_run.push(time);
            } else {
                // A failed or timed-out binary makes the sum meaningless: drop the sample.
                cell.errors.push(CellError::new(Phase::Test, format!("run sample {i} dropped: {}", outcome.failures.join("; "))));
            }
            let w = a.example.as_ref().map(|e| run_timed(Command::new(e).current_dir(&sources.dir), opts.timeout));
            let workload = match &w {
                None => "-".to_owned(),
                Some(Ok((t, _))) => format!("{t:.3}s"),
                Some(Err(_)) => "FAILED".to_owned(),
            };
            match w {
                None => {}
                Some(Ok((_, out))) if i == 0 => cell.workload_output = Some(out),
                Some(Ok((t, _))) => cell.workload.push(t),
                Some(Err(e)) if i == 0 => cell.errors.push(CellError::new(Phase::Workload, e.to_string())),
                Some(Err(e)) => cell.errors.push(CellError::new(Phase::Workload, format!("run sample {i} dropped: {e}"))),
            }
            eprintln!("[y] {} run {label} [{}]: tests {tests}, workload {workload}", krate.name(), backend.name());
        }
    }
}

/// The workload prints a checksum that must not depend on the backend: records an error in
/// each cell whose output differs from the first backend's that has one.
fn check_workload_outputs(cells: &mut [Cell], backends: &[Backend]) {
    let reference = cells.iter().zip(backends).find_map(|(c, b)| Some((c.workload_output.clone()?, *b)));
    for cell in cells {
        if let (Some((r, rb)), Some(o)) = (&reference, &cell.workload_output)
            && r != o
        {
            cell.errors.push(CellError::new(Phase::Workload, format!("output differs from {}'s: {:?} vs {:?}", rb.name(), o.trim(), r.trim())));
        }
    }
}

/// Downloads (once) and verifies the `.crate` archive, and extracts a fresh copy with the
/// workload added as the `ryo_bench` example.
fn prepare(root: &Path, base: &Path, krate: &Crate) -> Result<Sources, String> {
    let id = format!("{}-{}", krate.name, krate.version);
    let cache = base.join("cache");
    crate::utils::create_dir(&cache)?;
    let archive = cache.join(format!("{id}.crate"));
    if !archive.exists() || sha256(&archive)? != krate.sha256 {
        let url = format!("https://static.crates.io/crates/{}/{id}.crate", krate.name);
        eprintln!("[y] bench crates: downloading {url}");
        let part = archive.with_extension("part");
        crate::utils::run(Command::new("curl").args(["-sSfL", "-o"]).arg(&part).arg(&url))?;
        let sum = sha256(&part)?;
        if sum != krate.sha256 {
            return Err(format!("{url}: sha256 is {sum}, expected {}", krate.sha256));
        }
        fs::rename(&part, &archive).map_err(|e| e.to_string())?;
    }
    let src_root = base.join("src");
    let dir = src_root.join(&id);
    crate::utils::remove_dir_if_exists(&dir)?;
    crate::utils::create_dir(&src_root)?;
    crate::utils::run(Command::new("tar").arg("xzf").arg(&archive).arg("-C").arg(&src_root))?;
    if !dir.join("Cargo.lock").exists() {
        return Err(format!("{id} has no Cargo.lock"));
    }
    // Everything the builds need, so they can run `--offline`.
    crate::utils::run(cmd("cargo").current_dir(&dir).args(["fetch", "--locked"]))?;
    let workload = root.join("tests").join("crates").join(format!("{}.rs", krate.name));
    crate::utils::create_dir(dir.join("examples"))?;
    fs::copy(&workload, dir.join("examples").join("ryo_bench.rs")).map_err(|e| format!("copying {}: {e}", workload.display()))?;
    // Published manifests set `autoexamples = false`. `[workspace]` keeps cargo from looking
    // for one in the parent directories.
    let manifest = dir.join("Cargo.toml");
    let mut text = crate::utils::read(&manifest)?;
    // `CARGO_PROFILE_*` restates the profiles (see `PROFILE_ENV`) but can't reach per-package
    // overrides, so a crate with any is rejected rather than measured with other settings.
    if let Some(l) = text.lines().find(|l| l.starts_with("[profile.") && l.contains(".package.")) {
        return Err(format!("{id}'s manifest has a per-package profile override `{l}`"));
    }
    text.push_str("\n[[example]]\nname = \"ryo_bench\"\npath = \"examples/ryo_bench.rs\"\n\n[workspace]\n");
    crate::utils::write(&manifest, text)?;
    Ok(Sources { dir, members: vec![krate.name.to_owned()], overrides: Vec::new(), workload: true })
}

/// A [`Target`]'s prepared sources.
struct Sources {
    /// The package or workspace directory the builds run in.
    dir: PathBuf,
    /// The leaf packages: cleaned between leaf samples.
    members: Vec<String>,
    /// A local workspace's per-package profile overrides (`prepare_local`).
    overrides: Vec<String>,
    /// Whether there is a `ryo_bench` workload example; if not (a local workspace), the
    /// builds use `--workspace`.
    workload: bool,
}

/// Fetches a local workspace's dependencies and lists its members' package names and its
/// per-package profile overrides (`profile.dev.package."*"`, see [`override_configs`]). The
/// sources are used in place (nothing is written to them; the target directory is the
/// bench's).
fn prepare_local(dir: &Path) -> Result<Sources, String> {
    let text = crate::utils::read(dir.join("Cargo.toml"))?;
    let overrides = text
        .lines()
        .filter_map(|l| l.trim().strip_prefix('[')?.strip_suffix(']'))
        .filter(|l| l.starts_with("profile.") && l.contains(".package."))
        .map(str::to_owned)
        .collect();
    crate::utils::run(cmd("cargo").current_dir(dir).args(["fetch", "--locked"]))?;
    // `viewer v0.1.0 (/path)`, one line per member.
    let tree = output(cmd("cargo").current_dir(dir).args(["tree", "--offline", "--workspace", "--depth", "0", "--prefix", "none"]))?;
    let mut members: Vec<String> = tree.lines().filter_map(|l| l.split_whitespace().next()).map(str::to_owned).collect();
    members.sort();
    members.dedup();
    Ok(Sources { dir: dir.to_owned(), members, overrides, workload: false })
}

/// `--config` values restating `PROFILE_ENV` in each per-package override section, which
/// `CARGO_PROFILE_*` can't reach. Only the keys a package override may set.
fn override_configs(overrides: &[String]) -> Vec<String> {
    const KEYS: &[(&str, &str)] =
        &[("opt-level", "0"), ("debug", "0"), ("debug-assertions", "true"), ("overflow-checks", "true"), ("codegen-units", "1")];
    overrides.iter().flat_map(|o| KEYS.iter().map(move |(k, v)| format!("{o}.{k}={v}"))).collect()
}

fn sha256(path: &Path) -> Result<String, String> {
    let out = output(Command::new("sha256sum").arg(path))?;
    Ok(out.split_whitespace().next().unwrap_or("").to_owned())
}

/// What a cargo invocation of a build sample needs.
struct Env<'a> {
    info: &'a RustcInfo,
    root: &'a Path,
    y: &'a Path,
    backend: Backend,
    target: &'a Path,
    src: &'a Path,
    stock: bool,
    /// A local workspace's per-package profile overrides (`prepare_local`).
    overrides: &'a [String],
}

impl Env<'_> {
    fn cargo(&self, log_dir: &Path, stats: bool) -> Command {
        let mut c = cmd("cargo");
        c.current_dir(self.src);
        for o in override_configs(self.overrides).iter().filter(|_| !self.stock) {
            c.args(["--config", o]);
        }
        for v in CLEARED_ENV {
            c.env_remove(v);
        }
        for (k, v) in PROFILE_ENV.iter().filter(|_| !self.stock) {
            for p in ["DEV", "TEST", "DEV_BUILD_OVERRIDE", "TEST_BUILD_OVERRIDE"] {
                // Build overrides can't set `lto`, `panic` or `incremental`.
                if p.ends_with("OVERRIDE") && matches!(*k, "LTO" | "PANIC" | "INCREMENTAL") {
                    continue;
                }
                c.env(format!("CARGO_PROFILE_{p}_{k}"), v);
            }
        }
        c.env("RUSTUP_TOOLCHAIN", &self.info.toolchain)
            .env("RUSTC", self.backend.rustc(self.root))
            .env("RUSTC_WRAPPER", self.y)
            .env(WRAPPER_VAR, log_dir)
            .env("CARGO_TARGET_DIR", self.target);
        if !self.stock {
            c.env("RUSTFLAGS", RUSTFLAGS).env("CARGO_INCREMENTAL", "0").env("CARGO_BUILD_JOBS", "1");
        }
        if stats {
            c.env("RYO_STATS", "1");
        }
        c
    }
}

/// The last `n` lines of `stderr` that `keep` accepts, joined by `sep`.
fn stderr_tail(stderr: &[u8], n: usize, sep: &str, keep: impl Fn(&str) -> bool) -> String {
    let err = String::from_utf8_lossy(stderr);
    let lines: Vec<&str> = err.lines().filter(|l| keep(l)).collect();
    lines[lines.len().saturating_sub(n)..].join(sep)
}

struct BuildSample {
    steps: BuildSteps,
    artifacts: Artifacts,
}

/// Builds the crate: library, tests, then the workload. `clean` starts from a clean target
/// directory; otherwise only the crate's own artifacts are cleaned (`cargo clean -p`), so
/// the dependencies aren't rebuilt, and a rebuilt one is an error.
fn build_sample(env: &Env, sources: &Sources, logs: &Path, clean: bool, stats: bool) -> Result<BuildSample, String> {
    if clean {
        crate::utils::remove_dir_if_exists(env.target)?;
    } else {
        let mut c = env.cargo(logs, false);
        c.args(["clean", "--offline"]);
        for m in &sources.members {
            c.args(["-p", m]);
        }
        crate::utils::run(&mut c)?;
    }
    let step = |args: &[&str]| -> Result<(Step, String), String> {
        crate::utils::remove_dir_if_exists(logs)?;
        let mut c = env.cargo(logs, stats);
        c.args(["build", "--locked", "--offline", "-Zsection-timings", "--timings"]).args(args);
        let start = Instant::now();
        let out = c.output().map_err(|e| format!("running cargo: {e}"))?;
        let wall = start.elapsed().as_secs_f64();
        if !out.status.success() {
            let tail = stderr_tail(&out.stderr, 30, "\n", |l| !l.trim_start().starts_with("Compiling"));
            return Err(format!("`cargo build {}` failed with {}:\n{tail}", args.join(" "), out.status));
        }
        Ok((Step { wall, units: timing::read_units(logs)? }, String::from_utf8_lossy(&out.stdout).into_owned()))
    };
    let local = !sources.workload;
    let (lib, _) = step(if local { &["--workspace"] } else { &["--lib"] })?;
    let test_args: &[&str] = &["--workspace", "--tests", "--message-format=json-render-diagnostics"];
    let (tests, json) = step(if local { test_args } else { &test_args[1..] })?;
    // Built for the workload; its timing isn't reported.
    let example = if local { None } else { Some(step(&["--example", "ryo_bench"])?.0) };
    if !clean && let Some(u) = [&lib, &tests].into_iter().chain(&example).flat_map(|s| &s.units).find(|u| !u.primary) {
        return Err(format!("dependency `{}` was rebuilt in a sample", u.krate));
    }
    let test_exes = test_executables(&json);
    let example_exe = (!local).then(|| env.target.join("debug").join("examples").join(exe_name("ryo_bench")));
    Ok(BuildSample { steps: BuildSteps { lib, tests }, artifacts: Artifacts { test_exes, example: example_exe } })
}

/// The test binaries in cargo's `--message-format=json` output: `compiler-artifact` messages
/// with `"test":true` in their profile and an executable.
fn test_executables(json: &str) -> Vec<PathBuf> {
    let mut exes = Vec::new();
    for line in json.lines() {
        if !line.contains(r#""reason":"compiler-artifact""#) || !line.contains(r#""test":true"#) {
            continue;
        }
        let pat = r#""executable":""#;
        let Some(at) = line.find(pat) else { continue };
        let rest = &line[at + pat.len()..];
        let mut path = String::new();
        let mut chars = rest.chars();
        while let Some(c) = chars.next() {
            match c {
                '"' => break,
                '\\' => path.extend(chars.next()),
                c => path.push(c),
            }
        }
        if !exes.iter().any(|e: &PathBuf| e.as_os_str() == path.as_str()) {
            exes.push(PathBuf::from(path));
        }
    }
    exes
}

/// Runs `c` with a timeout, returning its wall time and stdout. Fails on a non-zero exit.
fn run_timed(c: &mut Command, timeout: u64) -> Result<(f64, String), String> {
    let (t, out) = run_raw(c, timeout)?;
    if !out.status.success() {
        return Err(format!("exited with {}: {}", out.status, stderr_tail(&out.stderr, 10, "\n", |_| true)));
    }
    Ok((t, String::from_utf8_lossy(&out.stdout).into_owned()))
}

fn run_raw(c: &mut Command, timeout: u64) -> Result<(f64, std::process::Output), String> {
    for v in CLEARED_ENV {
        c.env_remove(v);
    }
    c.env("RUST_TEST_THREADS", "1").stdin(Stdio::null()).stdout(Stdio::piped()).stderr(Stdio::piped());
    // Its own process group, so a timeout also kills the processes it starts (which would keep
    // the pipes open).
    #[cfg(unix)]
    std::os::unix::process::CommandExt::process_group(c, 0);
    let start = Instant::now();
    let child = c.spawn().map_err(|e| format!("running {}: {e}", c.get_program().to_string_lossy()))?;
    let pid = child.id();
    let (done, wait) = mpsc::channel::<()>();
    let watchdog = std::thread::spawn(move || {
        if wait.recv_timeout(Duration::from_secs(timeout)) == Err(mpsc::RecvTimeoutError::Timeout) {
            // The group outlives the child's reaping while any member lives, and with none
            // left the kill is a no-op (barring pid reuse within the window).
            let _ = Command::new("kill").args(["-9", "--", &format!("-{pid}")]).status();
            return true;
        }
        false
    });
    let out = child.wait_with_output().map_err(|e| e.to_string());
    let t = start.elapsed().as_secs_f64();
    let _ = done.send(());
    // A kill that came after the child exited on its own isn't a timeout.
    #[cfg(unix)]
    let killed = |o: &std::process::Output| std::os::unix::process::ExitStatusExt::signal(&o.status) == Some(9);
    #[cfg(not(unix))]
    let killed = |o: &std::process::Output| !o.status.success();
    if watchdog.join().unwrap_or(false) && out.as_ref().map_or(true, killed) {
        return Err(format!("timed out after {timeout}s"));
    }
    Ok((t, out?))
}

/// Runs every test binary once, single-threaded, from the package directory (like `cargo
/// test`). Returns the summed wall time and the results.
fn run_tests(src: &Path, krate: &Target, exes: &[PathBuf], timeout: u64) -> (f64, TestOutcome) {
    let mut total = 0.0;
    let mut o = TestOutcome { binaries: exes.len(), ..TestOutcome::default() };
    for exe in exes {
        let name = exe.file_name().map_or_else(String::new, |n| n.to_string_lossy().into_owned());
        let mut c = Command::new(exe);
        c.args(krate.test_args())
            .current_dir(src)
            .env("CARGO_MANIFEST_DIR", src)
            .env("CARGO_PKG_NAME", krate.name())
            .env("CARGO_PKG_VERSION", krate.version());
        match run_raw(&mut c, timeout) {
            Ok((t, out)) => {
                total += t;
                let stdout = String::from_utf8_lossy(&out.stdout);
                let (p, f, i) = parse_test_output(&stdout);
                (o.passed, o.failed, o.ignored) = (o.passed + p, o.failed + f, o.ignored + i);
                for l in stdout.lines() {
                    if let Some(t) = l.strip_prefix("test ").and_then(|l| l.strip_suffix(" ... FAILED")) {
                        o.failures.push(format!("{name}: {t}"));
                    }
                }
                if !out.status.success() && f == 0 {
                    o.failures.push(format!("{name}: exited with {}: {}", out.status, stderr_tail(&out.stderr, 5, " | ", |_| true)));
                }
            }
            Err(e) => o.failures.push(format!("{name}: {e}")),
        }
    }
    (total, o)
}

/// Sums the `test result:` lines of libtest's output: (passed, failed, ignored).
fn parse_test_output(out: &str) -> (u64, u64, u64) {
    let (mut p, mut f, mut i) = (0, 0, 0);
    for line in out.lines() {
        let Some(rest) = line.strip_prefix("test result: ") else { continue };
        for part in rest.split(['.', ';']) {
            let mut w = part.split_whitespace();
            if let (Some(n), Some(what)) = (w.next(), w.next())
                && let Ok(n) = n.parse::<u64>()
            {
                match what {
                    "passed" => p += n,
                    "failed" => f += n,
                    "ignored" => i += n,
                    _ => {}
                }
            }
        }
    }
    (p, f, i)
}

fn header(info: &RustcInfo, root: &Path, opts: &Options) -> Vec<(String, String)> {
    let sh = |c: &mut Command| output(c.stderr(Stdio::null())).map(|s| s.trim().to_owned()).unwrap_or_default();
    let read = |p: &str| fs::read_to_string(p).unwrap_or_default();
    let cpuinfo = read("/proc/cpuinfo");
    let cpu = cpuinfo.lines().find_map(|l| l.strip_prefix("model name")).map(|l| l.trim_start_matches([' ', '\t', ':']));
    let mem = read("/proc/meminfo");
    let mem = mem.lines().find_map(|l| l.strip_prefix("MemTotal:")).map(|m| m.trim().to_owned()).unwrap_or_default();
    let logical = cpuinfo.lines().filter(|l| l.starts_with("processor")).count();
    let affinity = std::thread::available_parallelism().map_or(0, |n| n.get());
    let governor = read("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor");
    let commit = sh(Command::new("git").current_dir(root).args(["rev-parse", "--short", "HEAD"]));
    let dirty = !sh(Command::new("git").current_dir(root).args(["status", "--porcelain", "--untracked-files=no"])).is_empty();
    let rustc = sh(cmd("rustc").arg("-V"));
    let cargo = sh(cmd("cargo").arg("-V"));
    let mut h: Vec<(String, String)> = vec![
        ("date".into(), sh(Command::new("date").args(["-u", "+%Y-%m-%d %H:%M:%S UTC"]))),
        ("ryo".into(), format!("{commit}{}", if dirty { " (with uncommitted changes)" } else { "" })),
        ("rustc".into(), format!("{rustc} ({}), host {}", info.toolchain, info.host)),
        ("cargo".into(), cargo),
        ("backends".into(), "llvm: plain rustc; clif: rustc_codegen_cranelift from the toolchain's rustc-dev sources (y build-clif); ryo: dist/bin/rustc-ryo, default sysroot (prebuilt LLVM std)".into()),
        ("profile".into(), "cargo dev: opt-level 0, debug-assertions and overflow-checks on, panic=unwind, no LTO, incremental off (restated for the test profile too)".into()),
        ("RUSTFLAGS".into(), format!("{RUSTFLAGS} (all crates: deps, build scripts, proc macros, leaf)")),
        ("environment".into(), "CARGO_BUILD_JOBS=1 CARGO_INCREMENTAL=0 RUST_TEST_THREADS=1 RUSTC_BOOTSTRAP=1; no target-cpu, default linker for all".into()),
        ("notes".into(), "rustc-ryo forces -Ccodegen-units=1 (here every backend gets it). rustc-clif and rustc-ryo are wrapper executables: one extra exec per rustc invocation that plain rustc doesn't have (included in the rustc wall times). Build-override profiles are forced the same; crates with per-package profile overrides are rejected, except in a local workspace (--path), where --config restates the defaults in them. No MIR optimization flags are added for any backend. Doc tests are not run.".into()),
        ("timing".into(), "frontend/backend/link from rustc's --json=timings section records (cargo -Zsection-timings), captured by a RUSTC_WRAPPER; other = rustc wall - the three".into()),
        ("samples".into(), format!(
            "{} clean build samples (dependencies metrics), {} leaf build samples (the crate only, dependencies already built; all other build metrics), {} run samples, after one discarded warm-up each; backends interleaved; noisy = stddev > {:.0}% of median",
            opts.dep_samples, opts.leaf_samples, opts.run_samples, stats::NOISY * 100.0
        )),
        ("machine".into(), format!("{} ({logical} logical CPUs, {affinity} available to y), {mem}, Linux {}", cpu.unwrap_or("?"), read("/proc/sys/kernel/osrelease").trim())),
    ];
    if opts.stock {
        h.retain(|(k, _)| !matches!(k.as_str(), "profile" | "RUSTFLAGS" | "environment"));
        h.push(("stock".into(), "cargo's and rustc's defaults (crate profiles, jobs, codegen units, incremental, debuginfo as cargo sets them); only RUSTC is changed. Not a fair comparison.".into()));
    }
    if !governor.is_empty() {
        h.push(("cpufreq governor".into(), governor.trim().to_owned()));
    }
    h
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn options() {
        let o = parse_options(&[]).unwrap();
        assert_eq!(
            (o.dep_samples, o.leaf_samples, o.run_samples, o.backends.as_slice()),
            (DEFAULT_DEP_SAMPLES, DEFAULT_LEAF_SAMPLES, DEFAULT_RUN_SAMPLES, [Backend::Llvm, Backend::Ryo].as_slice())
        );
        let o = parse_options(&["--quick", "--crates", "semver,memchr", "--backends=ryo"]).unwrap();
        assert_eq!((o.dep_samples, o.leaf_samples, o.run_samples), (1, 1, 1));
        assert_eq!(o.crates, ["semver", "memchr"]);
        assert_eq!(parse_options(&[]).unwrap().crates, DEFAULT_CRATES);
        assert_eq!(parse_options(&["--crates", "all"]).unwrap().crates.len(), CRATES.len());
        assert_eq!(o.backends, [Backend::Ryo]);
        let o = parse_options(&["--build-samples", "3", "--run-samples=7", "--timeout", "60"]).unwrap();
        assert_eq!((o.dep_samples, o.leaf_samples, o.run_samples, o.timeout), (3, 3, 7, 60));
        let o = parse_options(&["--dep-samples", "0", "--leaf-samples=16", "--run-samples", "0"]).unwrap();
        assert_eq!((o.dep_samples, o.leaf_samples, o.run_samples), (0, 16, 0));
        assert!(parse_options(&["--leaf-samples", "0"]).is_err());
        assert!(parse_options(&["--stock"]).unwrap().stock && !parse_options(&[]).unwrap().stock);
        assert!(parse_options(&["--crates", "nope"]).is_err());
        assert!(parse_options(&["--backends", "gcc"]).is_err());
        assert!(parse_options(&["--build-samples", "0"]).is_err());
        assert!(parse_options(&["--run-samples"]).is_err());
        assert!(parse_options(&["x"]).is_err());
    }

    #[test]
    fn test_results() {
        let out = "running 2 tests\ntest a ... ok\ntest b ... FAILED\n\n\
                   test result: FAILED. 1 passed; 1 failed; 3 ignored; 0 measured; 0 filtered out; finished in 0.01s\n\
                   test result: ok. 10 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 1.5s\n";
        assert_eq!(parse_test_output(out), (11, 1, 3));
        assert_eq!(parse_test_output(""), (0, 0, 0));
    }

    #[test]
    fn executables() {
        let json = concat!(
            r#"{"reason":"compiler-artifact","target":{"name":"t"},"profile":{"opt_level":"0","test":true},"executable":"/a/deps/t-1"}"#,
            "\n",
            r#"{"reason":"compiler-artifact","profile":{"test":false},"executable":"/a/deps/bin"}"#,
            "\n",
            r#"{"reason":"compiler-artifact","profile":{"test":true},"executable":null}"#,
            "\n",
            r#"{"reason":"compiler-artifact","profile":{"test":true},"executable":"/a/b\\\"c"}"#,
            "\n",
            r#"{"reason":"build-finished","success":true}"#,
        );
        assert_eq!(test_executables(json), [PathBuf::from("/a/deps/t-1"), PathBuf::from("/a/b\\\"c")]);
    }

    #[test]
    fn workloads_exist() {
        for c in CRATES {
            assert!(root().join("tests/crates").join(format!("{}.rs", c.name)).exists(), "{}", c.name);
            assert_eq!(c.sha256.len(), 64);
        }
    }
}
