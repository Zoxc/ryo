//! `y test` (design/build.md#test-and-bench): the test corpus, diffed against plain rustc, and
//! the smoke tests of `dist/`.

use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Mutex;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Instant;

use crate::utils::{cmd, describe, exe_name, output, root};

mod checks;
mod corpus;

use checks::*;
pub(crate) use checks::{rt_core_only, vm_functions};
pub(crate) use corpus::*;

/// Which compiler builds a program.
#[derive(Clone, Copy, PartialEq)]
enum Compiler {
    /// Plain `rustc`: the reference.
    Rustc,
    /// `dist/bin/rustc-ryo`.
    Ryo,
    /// `dist/bin/rustc-clif`.
    Clif,
}

/// A way of building the corpus. Each variant's output is compared with [`REFERENCE`]'s.
struct Variant {
    name: &'static str,
    compiler: Compiler,
    /// Extra flags for every crate.
    flags: &'static [&'static str],
    /// Extra flags for the last crate only, as cargo passes `-Clto`. Programs with a Rust
    /// dylib are skipped when this is set: LTO doesn't support them.
    final_flags: &'static [&'static str],
    /// Only for programs that list VM functions. Their `vm` lists aren't checked (MIR inlining
    /// at `-O` removes some functions).
    vm_only: bool,
    /// Built against the ryo-compiled std (`--sysroot ryo`, after `y build --sysroot ryo`).
    /// Skipped without it.
    ryo_std: bool,
    /// `-Cpanic=abort`, compared with plain rustc's output with the same flag ([`REFERENCE_ABORT`]).
    /// Programs with a Rust dylib are skipped: std's dylib unwinds.
    abort: bool,
    /// With `RYO_NO_VM`: every function stays native, so the `vm` lists aren't checked.
    no_vm: bool,
    /// The environment the program runs with, such as the JIT's settings.
    env: &'static [(&'static str, &'static str)],
}

const VARIANT: Variant =
    Variant { name: "", compiler: Compiler::Ryo, flags: &[], final_flags: &[], vm_only: false, ryo_std: false, abort: false, no_vm: false, env: &[] };

const REFERENCE: Variant = Variant { name: "rustc", compiler: Compiler::Rustc, ..VARIANT };

/// The reference of the [`Variant::abort`] variants.
const REFERENCE_ABORT: Variant = Variant { name: "rustc-abort", compiler: Compiler::Rustc, flags: &["-Cpanic=abort"], ..VARIANT };

const VARIANTS: &[Variant] = &[
    Variant { name: "ryo-novm", no_vm: true, ..VARIANT },
    Variant { name: "ryo", ..VARIANT },
    Variant { name: "ryo-threads8", flags: &["-Zthreads=8"], ..VARIANT },
    Variant { name: "ryo-O3", flags: &["-Copt-level=3"], vm_only: true, ..VARIANT },
    // The image is outside LTO's view: the symbols it refers to must survive internalization,
    // also those of upstream rlibs built without LTO (design/backend.md#query-overrides).
    Variant { name: "ryo-lto", final_flags: &["-Clto=fat"], ..VARIANT },
    Variant { name: "ryo-thinlto-O3", flags: &["-Copt-level=3"], final_flags: &["-Clto=thin"], vm_only: true, ..VARIANT },
    // `-Cpanic=abort` without a ryo sysroot: the terminate stubs and abort paths of VM code.
    Variant { name: "ryo-abort", flags: &["-Cpanic=abort"], abort: true, ..VARIANT },
    // std itself in the VM (design/build.md#build, `--sysroot ryo`).
    Variant { name: "ryo-std", ryo_std: true, ..VARIANT },
    Variant { name: "ryo-std-O3", flags: &["-Copt-level=3"], vm_only: true, ryo_std: true, ..VARIANT },
    Variant { name: "ryo-std-lto", final_flags: &["-Clto=fat"], ryo_std: true, ..VARIANT },
    Variant { name: "ryo-std-abort", flags: &["-Cpanic=abort"], ryo_std: true, abort: true, ..VARIANT },
    // Every VM function, std's included, runs its JIT code from its first call
    // (design/jit.md#testing), also with frames the JIT lays out differently.
    Variant { name: "ryo-std-jit", ryo_std: true, env: JIT_SYNC, ..VARIANT },
    Variant { name: "ryo-std-jit-shuffle", ryo_std: true, env: JIT_SHUFFLE, ..VARIANT },
    Variant { name: "ryo-std-jit-reencode", ryo_std: true, env: JIT_REENCODE, ..VARIANT },
    // The JIT's SSA tier (design/jit.md#the-ssa-tier), with its checkers, on the corpus's
    // own VM functions: from their first call, and entered by OSR at the first loop head.
    Variant { name: "ryo-jit-ssa", env: JIT_SSA, ..VARIANT },
    Variant { name: "ryo-jit-ssa-osr", env: JIT_SSA_OSR, ..VARIANT },
    Variant { name: "ryo-jit-ssa-shuffle", env: JIT_SSA_SHUFFLE, ..VARIANT },
];

/// The JIT's settings for [`Variant::env`]: compile every function at its first call, and
/// wait for it.
const JIT_SYNC: &[(&str, &str)] = &[("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1")];
/// [`JIT_SYNC`], with shuffled JIT frames.
const JIT_SHUFFLE: &[(&str, &str)] = &[("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1"), ("RYO_JIT_SHUFFLE", "1")];
/// [`JIT_SYNC`], through the re-encoding pipeline instead of the SSA tier.
const JIT_REENCODE: &[(&str, &str)] = &[("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1"), ("RYO_JIT_OPT", "reencode")];
/// [`JIT_SYNC`], through the SSA tier with its checkers.
const JIT_SSA: &[(&str, &str)] = &[("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1"), ("RYO_JIT_OPT", "ssa"), ("RYO_JIT_CHECK", "1")];
/// The SSA tier entered by OSR at the first loop head pass of each function's first call
/// (whose entry check doesn't trip: the second call's does).
const JIT_SSA_OSR: &[(&str, &str)] = &[("RYO_JIT_THRESHOLD", "2,0"), ("RYO_JIT_SYNC", "1"), ("RYO_JIT_OPT", "ssa"), ("RYO_JIT_CHECK", "1")];

/// [`JIT_SSA`], with shuffled JIT frames.
const JIT_SSA_SHUFFLE: &[(&str, &str)] =
    &[("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1"), ("RYO_JIT_OPT", "ssa"), ("RYO_JIT_CHECK", "1"), ("RYO_JIT_SHUFFLE", "1")];

/// Added by `test --clif`.
const CLIF: Variant = Variant { name: "clif", compiler: Compiler::Clif, ..VARIANT };

/// Whether the VM variants and the checks that run VM code are run. Without them, only the
/// variants without VM code ([`Variant::no_vm`], plain rustc, Cranelift) are.
const VM_RUNS: bool = true;

/// The variants to build: [`VARIANTS`], plus [`CLIF`] for `test --clif`.
fn variants(clif: bool) -> Vec<&'static Variant> {
    VARIANTS.iter().chain(clif.then_some(&CLIF)).filter(|v| VM_RUNS || v.no_vm || v.compiler != Compiler::Ryo).collect()
}

/// The fast suite's corpus: each program with the variants it runs under.
/// Every other [`CORPUS`] program is on [`FULL_ONLY`]. The ryo-std variants run only with a ryo
/// sysroot.
const FAST: &[(&str, &[&str])] = &[
    ("hello", &["ryo"]),
    ("arith", &["ryo"]),
    ("collections", &["ryo", "ryo-std", "ryo-std-jit"]),
    ("panics", &["ryo"]),
    ("generics_traits", &["ryo"]),
    ("vm_abi", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle"]),
    ("vm_control", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle"]),
    ("vm_calls", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle"]),
    ("vm_tail", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle"]),
    ("vm_cross", &["ryo", "ryo-jit-ssa"]),
    ("vm_intrinsics", &["ryo"]),
    ("vm_lowerings", &["ryo", "ryo-jit-ssa"]),
    ("vm_simd", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle"]),
    ("vm_unwind", &["ryo", "ryo-jit-ssa"]),
    ("vm_aggregates", &["ryo", "ryo-jit-ssa"]),
    ("vm_statics_cross", &["ryo", "ryo-jit-ssa"]),
    ("vm_dylib", &["ryo", "ryo-jit-ssa"]),
    ("vm_ffi", &["ryo", "ryo-jit-ssa"]),
    ("vm_cdylib", &["ryo"]),
    ("vm_lto_dep", &["ryo-lto"]),
    ("vm_abort_cleanup", &["ryo-abort"]),
    ("end_ptrs", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-shuffle"]),
];

/// The [`CORPUS`] programs only `--full` (or a change to them) runs, with the reason.
#[cfg_attr(not(test), expect(dead_code, reason = "a list for readers, checked by `fast_set_covers_corpus`"))]
const FULL_ONLY: &[(&str, &str)] = &[
    ("structs_enums", "native lowering only; covered by generics_traits and collections"),
    ("closures_iters", "native lowering only; covered by generics_traits and collections"),
    ("exit_code", "process exit status only; rarely touched"),
    ("cross_crate", "native cross-crate linking; vm_cross covers it with VM code"),
    ("dylib", "native dylib; vm_dylib covers dylibs with VM code"),
    ("vm_answer", "early milestone; vm_calls and vm_abi cover its calls"),
    ("vm_main", "a VM main; every VM program in the fast set has one"),
    ("vm_refs", "statics and consts; vm_statics_cross covers them"),
    ("vm_ints", "integer ops; vm_abi and vm_aggregates cover most of them"),
    ("vm_dyn", "vtables and shims; vm_calls covers call.ind"),
    ("vm_abort_nounwind", "terminate stubs; vm_abort_cleanup covers abort"),
    ("vm_statics", "local statics and TLS; vm_statics_cross covers them across crates"),
    ("vm_dylib_dep", "dylib export lists; vm_dylib and the exports check cover dylibs"),
    ("vm_sysroot", "std-build regressions; mostly matters with --sysroot ryo"),
    ("vm_fn_items", "fn item shims; vm_calls covers calls through pointers"),
    ("vm_eii", "externally implementable items; rarely touched"),
    ("vm_linkage", "#[linkage] items stay native; rarely touched"),
    ("vm_staticlib", "a C main on a staticlib; vm_cdylib covers the C main"),
];

/// The variants of the JIT ([`Sel::jit`]).
const JIT_VARIANTS: &[&str] =
    &["ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle", "ryo-std-jit", "ryo-std-jit-shuffle", "ryo-std-jit-reencode"];

/// The areas of `test --only`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Area {
    Jit,
    Backend,
    Lean,
    Std,
    Rt,
}

impl Area {
    pub fn parse(s: &str) -> Result<Area, String> {
        Ok(match s {
            "jit" => Area::Jit,
            "backend" => Area::Backend,
            "lean" => Area::Lean,
            "std" => Area::Std,
            "rt" => Area::Rt,
            _ => return Err(format!("unknown area `{s}` (jit, backend, lean, std, rt)")),
        })
    }
}

/// `y test`'s options.
#[derive(Debug, Default, PartialEq)]
pub struct Options {
    pub clif: bool,
    /// Today's whole suite, plus `y lean`; fails without a ryo sysroot.
    pub full: bool,
    pub only: Option<Area>,
    /// Only these programs and variants of the corpus (all of the other if one is empty).
    pub programs: Vec<String>,
    pub variants: Vec<String>,
    /// The fixed fast set, without the tests chosen from the changed paths.
    pub no_changed: bool,
}

/// What a run covers: the fast set and the extras of the changed paths or of `--only`.
#[derive(Default)]
struct Sel {
    full: bool,
    /// The fast set: two cargo runs, [`FAST`] and the cheap checks.
    fast: bool,
    lean: bool,
    /// All six `ryo_jit` runs, the corpus under [`JIT_VARIANTS`], jit-private-std.
    jit: bool,
    /// The corpus under `ryo`.
    ryo_corpus: bool,
    /// The `fp-rbp` cargo runs.
    fp_rbp: bool,
    /// vm/rt/tests/codegen.rs.
    codegen: bool,
    /// [`SLOW_VM_TESTS`].
    slow_vm: bool,
    /// The workspace cargo run, rt-core-only and jit-sealed.
    rt: bool,
    /// The corpus under every variant without a ryo std, and every check.
    backend: bool,
    /// The corpus under the ryo-std variants.
    std: bool,
    /// These programs under every variant.
    programs: Vec<&'static str>,
    checks: Vec<&'static str>,
}

/// What a changed path adds to the fast set.
#[derive(Clone, Copy, Debug, PartialEq)]
enum Rule {
    Nothing,
    Full,
    Lean,
    /// The encoder, decoder and ABI of the bytecode.
    Bytecode,
    /// vm/rt/src/vm/handlers.rs, which the Lean tables include.
    Handlers,
    Rt,
    Jit,
    Backend,
    /// `tests/<program>…`: that program.
    Tests,
}

/// Path prefixes and their rules; the first match wins, and a path without one escalates to
/// `--full`. `*.md` outside `lean/` and `Cargo.lock` are handled before.
const RULES: &[(&str, Rule)] = &[
    ("notes/", Rule::Nothing),
    ("design/", Rule::Nothing),
    (".github/", Rule::Nothing),
    ("lean/", Rule::Lean),
    ("tests/lean/", Rule::Lean),
    ("vm/bytecode/src/asm/", Rule::Bytecode),
    ("vm/bytecode/src/asm.rs", Rule::Bytecode),
    ("vm/bytecode/src/full.rs", Rule::Bytecode),
    ("vm/bytecode/src/reduced.rs", Rule::Bytecode),
    ("vm/bytecode/src/abi.rs", Rule::Bytecode),
    ("vm/bytecode/src/jit", Rule::Jit),
    // The workspace run (the fast set) runs them.
    ("vm/bytecode/tests/", Rule::Nothing),
    ("vm/rt/src/vm/handlers.rs", Rule::Handlers),
    ("vm/rt/src/", Rule::Rt),
    ("vm/rt/tests/", Rule::Rt),
    ("vm/rt/build.rs", Rule::Rt),
    ("vm/jit/", Rule::Jit),
    ("backend/", Rule::Backend),
    ("tests/", Rule::Tests),
    ("build/", Rule::Full),
    ("rust-toolchain", Rule::Full),
    // Generated dumps (`y bench codegen`).
    ("bench/codegen/", Rule::Nothing),
    ("bench/", Rule::Full),
    ("scripts/", Rule::Full),
];

/// The rule of `path` (relative to the root, with `/`), `None` if none matches.
fn rule(path: &str) -> Option<Rule> {
    let file = path.rsplit('/').next().unwrap_or(path);
    if file == "Cargo.lock" {
        return Some(Rule::Full);
    }
    if path.ends_with(".md") && !path.starts_with("lean/") {
        return Some(Rule::Nothing);
    }
    RULES.iter().find(|(prefix, _)| path.starts_with(prefix)).map(|&(_, r)| r)
}

/// The programs and checks a changed `tests/` file belongs to; `None` if none.
fn test_targets(rel: &str) -> Option<(Vec<&'static str>, Vec<&'static str>)> {
    let first = |p: &str| p.split('/').next().unwrap_or(p).to_owned();
    let hit = |src: &str| src == rel || (src.contains('/') && first(src) == first(rel));
    let programs: Vec<&str> = CORPUS
        .iter()
        .filter(|p| p.crates.iter().any(|c| hit(c.src)) || p.c_main.is_some_and(hit) || p.native_lib.as_ref().is_some_and(|l| hit(l.src)))
        .map(|p| p.name)
        .collect();
    let checks: Vec<&str> = match rel {
        "hello.rs" => vec!["cargo-ryo"],
        "vm_backtrace.rs" => vec!["backtrace"],
        "vm_exports.rs" => vec!["exports"],
        "vm_statics.rs" => vec!["dump"],
        "vm_jit_private.rs" => vec!["jit-private-std"],
        "incremental/edits.rs" | "incremental/pm.rs" | "incremental/pm_user.rs" => vec!["incremental"],
        _ => vec![],
    };
    (!programs.is_empty() || !checks.is_empty()).then_some((programs, checks))
}

impl Sel {
    fn fast() -> Sel {
        Sel { fast: true, ..Sel::default() }
    }

    fn area(&mut self, area: Area) {
        match area {
            Area::Jit => self.jit = true,
            Area::Backend => {
                self.backend = true;
                self.slow_vm = true;
                self.jit = true;
            }
            Area::Lean => self.lean = true,
            Area::Std => self.std = true,
            Area::Rt => {
                self.rt = true;
                self.fp_rbp = true;
                self.codegen = true;
            }
        }
    }

    /// Adds `path`'s tests; `Err` with the reason to escalate to `--full`.
    fn add_path(&mut self, path: &str) -> Result<&'static str, String> {
        let Some(rule) = rule(path) else { return Err(format!("{path} (no rule)")) };
        Ok(match rule {
            Rule::Nothing => "",
            Rule::Full => return Err(path.to_owned()),
            Rule::Lean => {
                self.lean = true;
                "lean"
            }
            Rule::Bytecode => {
                self.ryo_corpus = true;
                self.jit = true;
                self.lean = true;
                self.slow_vm = true;
                "bytecode (corpus under ryo and the JIT, all ryo_jit runs, lean)"
            }
            Rule::Handlers => {
                self.area(Area::Rt);
                self.lean = true;
                "handlers (rt, lean)"
            }
            Rule::Rt => {
                self.area(Area::Rt);
                "rt (fp-rbp runs, codegen.rs, rt-core-only, jit-sealed)"
            }
            Rule::Jit => {
                self.jit = true;
                "jit (all ryo_jit runs, corpus under the JIT variants)"
            }
            Rule::Backend => {
                self.area(Area::Backend);
                self.std = true;
                "backend (corpus under every variant, every check)"
            }
            Rule::Tests => {
                let rel = &path["tests/".len()..];
                let Some((programs, checks)) = test_targets(rel) else { return Err(format!("{path} (no test uses it)")) };
                self.programs.extend(programs);
                self.checks.extend(checks);
                "tests (these programs under every variant)"
            }
        })
    }

    fn cargo_run(&self, name: &str) -> bool {
        self.full
            || match name {
                "vm" => self.fast || self.rt,
                "vm fp-rbp" => self.fp_rbp,
                "vm jit" => self.fast || self.jit,
                "vm jit fp-rbp" => self.jit || self.fp_rbp,
                _ => self.jit,
            }
    }

    fn corpus(&self, program: &Program, variant: &Variant) -> bool {
        self.full
            || variant.compiler == Compiler::Clif
            || self.programs.contains(&program.name)
            || (self.fast && FAST.iter().any(|(p, vs)| *p == program.name && vs.contains(&variant.name)))
            || (self.ryo_corpus && variant.name == "ryo")
            || (self.jit && JIT_VARIANTS.contains(&variant.name))
            || (self.backend && !variant.ryo_std)
            || (self.std && variant.ryo_std)
    }

    fn check(&self, name: &str) -> bool {
        self.full
            || self.backend
            || self.checks.contains(&name)
            || match name {
                "reject-randomize-layout" | "reject-codegen-units" | "metadata-only" | "dump" | "exports" | "backtrace" => self.fast,
                "rt-core-only" | "jit-sealed" => self.rt,
                "jit-private-std" => self.jit,
                _ => false,
            }
    }
}

/// The paths changed since the merge base with `main`, committed or not, untracked included.
fn changed_paths(root: &Path) -> Result<Vec<String>, String> {
    let git = |args: &[&str]| output(cmd("git").current_dir(root).args(args));
    let base = git(&["merge-base", "HEAD", "main"])?;
    let mut paths: Vec<String> = git(&["diff", "--name-only", base.trim()])?.lines().map(str::to_owned).collect();
    paths.extend(git(&["ls-files", "--others", "--exclude-standard"])?.lines().map(str::to_owned));
    paths.sort();
    paths.dedup();
    Ok(paths)
}

/// Whether the ryo sysroot can be tested against, i.e. is there and built from the current
/// inputs: `Err` with the reason if not.
fn ryo_sysroot_usable(root: &Path) -> Result<(), String> {
    use crate::sysroot::{SYSROOT_DIR, SysrootStatus, ryo_sysroot_status};
    let dist = root.join("dist");
    match ryo_sysroot_status(&crate::utils::RustcInfo::get()?, &dist) {
        SysrootStatus::Current => Ok(()),
        SysrootStatus::Missing => Err(format!("no ryo sysroot at {} (`./y.sh build --sysroot ryo`)", dist.join(SYSROOT_DIR).display())),
        SysrootStatus::Stale(why) => Err(format!("the ryo sysroot is stale: {why} (`./y.sh build --sysroot ryo`)")),
    }
}

/// The selection for `opts`, with the extras of the changed paths printed with their reasons.
fn select(root: &Path, opts: &Options) -> Result<Sel, String> {
    if opts.full {
        return Ok(Sel { full: true, ..Sel::default() });
    }
    if !opts.programs.is_empty() || !opts.variants.is_empty() {
        // The filters apply to the whole matrix; no cargo runs or checks.
        return Ok(Sel { backend: true, std: true, ..Sel::default() });
    }
    if let Some(area) = opts.only {
        let mut sel = Sel::default();
        sel.area(area);
        return Ok(sel);
    }
    let mut sel = Sel::fast();
    if opts.no_changed {
        return Ok(sel);
    }
    let paths = match changed_paths(root) {
        Ok(p) => p,
        Err(e) => {
            eprintln!("[y] escalating to --full: can't list the changed paths: {e}");
            return Ok(Sel { full: true, ..Sel::default() });
        }
    };
    let mut reasons: Vec<(&str, &str)> = Vec::new();
    for path in &paths {
        match sel.add_path(path) {
            Ok("") => {}
            Ok(label) => {
                if !reasons.iter().any(|(l, _)| *l == label) {
                    reasons.push((label, path));
                }
            }
            Err(why) => {
                eprintln!("[y] escalating to --full: {why}");
                return Ok(Sel { full: true, ..Sel::default() });
            }
        }
    }
    for (label, path) in reasons {
        eprintln!("[y] extra: {label} ({path} changed)");
    }
    Ok(sel)
}

/// One `[y] test …` line, with the time it took.
fn report(name: &str, start: Instant, res: Result<(), String>, failed: &Mutex<Vec<String>>) {
    let secs = start.elapsed().as_secs_f64();
    match res {
        Ok(()) => eprintln!("[y] test {name}: ok ({secs:.1}s)"),
        Err(msg) => {
            eprintln!("[y] test {name}: FAILED ({secs:.1}s): {msg}");
            failed.lock().unwrap().push(name.to_owned());
        }
    }
}

/// The ryo_rt feature sets get their own target directories, so they don't rebuild each other.
fn cargo_target_dir(root: &Path, name: &str) -> Option<PathBuf> {
    let sub = match name {
        "vm" => return None,
        "vm fp-rbp" => "fp-rbp",
        n if n.ends_with("fp-rbp") => "jit-fp-rbp",
        _ => "jit",
    };
    Some(root.join("vm").join("target").join("features").join(sub))
}

/// Tests of the `vm` run that only `--full` and changes to the bytecode encoder or the backend
/// run: every opcode in every mode through the encoder, which takes about 5 min in a debug build.
/// (`--skip` matches by name, so vm/bytecode/tests/full.rs's cheap test of that name is skipped too.)
const SLOW_VM_TESTS: [&str; 1] = ["every_opcode_round_trips"];

/// The tests in vm/rt/tests/codegen.rs (skipped unless [`Sel::codegen`]).
const CODEGEN_TESTS: [&str; 2] = ["win64_handlers_preserve_xmm6_to_15", "handlers_read_rbp_first_and_hot_ones_have_no_prologue"];

pub fn run(opts: &Options) -> Result<(), String> {
    let start = Instant::now();
    let root = root();
    let rustc_ryo = crate::utils::dist_bin(&root, "rustc-ryo");
    if !rustc_ryo.exists() {
        return Err("dist/ is missing; run `./y.sh build` first".to_owned());
    }
    if opts.clif {
        crate::clif::ensure()?;
    }
    let mut variants = variants(opts.clif);
    for v in &opts.variants {
        if !variants.iter().any(|x| x.name == v) {
            return Err(format!("unknown variant `{v}`"));
        }
    }
    for p in &opts.programs {
        if !CORPUS.iter().any(|x| x.name == p) {
            return Err(format!("unknown program `{p}`"));
        }
    }
    let sel = select(&root, opts)?;
    // Whether any ryo-std variant is selected (also through `--only jit`, the JIT variants, or
    // a changed test program, which runs under every variant).
    let wants_std = variants.iter().any(|v| v.ryo_std && CORPUS.iter().any(|p| sel.corpus(p, v)));
    if wants_std && let Err(why) = ryo_sysroot_usable(&root) {
        // Only an explicit request fails; the fast suite and an escalation to `--full` from
        // the changed paths skip them.
        if opts.full || opts.only == Some(Area::Std) || opts.variants.iter().any(|v| v.starts_with("ryo-std")) {
            return Err(format!("the ryo-std variants can't run: {why}"));
        }
        eprintln!("[y] WARNING: the ryo-std variants are SKIPPED: {why}");
        variants.retain(|v| !v.ryo_std);
    }
    variants.retain(|v| opts.variants.is_empty() || opts.variants.iter().any(|n| n == v.name));
    let corpus_only = !opts.programs.is_empty() || !opts.variants.is_empty();

    let out = root.join("target").join("tests");
    fs::create_dir_all(&out).map_err(|e| format!("creating {}: {e}", out.display()))?;
    let ctx =
        Ctx { tests: root.join("tests"), out: out.clone(), rustc_ryo: rustc_ryo.clone(), rustc_clif: crate::utils::dist_bin(&root, "rustc-clif") };
    let failed = Mutex::new(Vec::new());

    // The runtime once more with handlers that read `fp` from `rbp`, so VM code keeps the
    // frame pointer (design/vm.md#handlers).
    // And the JIT's tests, through the runtime's trips, also with `fp-rbp` (design/jit.md#testing);
    // the other runtime tests run without the JIT: with it, the `jit` feature would unify into
    // `ryo_rt`.
    // The JIT's tests run through its SSA tier (the default) with its checkers, through the
    // naive allocator, and through the re-encoding pipeline.
    let opt = |opt| [("RYO_JIT_OPT", opt), ("RYO_JIT_CHECK", "1")];
    let vm_runs: [(&str, &[&str], &[(&str, &str)]); 8] = [
        ("vm", &["test", "--workspace", "--exclude", "ryo_jit"], &[]),
        ("vm fp-rbp", &["test", "-p", "ryo_rt", "--features", "fp-rbp"], &[]),
        ("vm jit", &["test", "-p", "ryo_jit"], &opt("ssa")),
        ("vm jit fp-rbp", &["test", "-p", "ryo_jit", "--features", "ryo_rt/fp-rbp"], &opt("ssa")),
        ("vm jit reencode", &["test", "-p", "ryo_jit"], &opt("reencode")),
        ("vm jit reencode fp-rbp", &["test", "-p", "ryo_jit", "--features", "ryo_rt/fp-rbp"], &opt("reencode")),
        ("vm jit ssa-naive", &["test", "-p", "ryo_jit"], &opt("ssa-naive")),
        ("vm jit ssa-naive fp-rbp", &["test", "-p", "ryo_jit", "--features", "ryo_rt/fp-rbp"], &opt("ssa-naive")),
    ];
    for (name, args, env) in vm_runs {
        if corpus_only || !sel.cargo_run(name) {
            continue;
        }
        let t = Instant::now();
        let mut c = cmd("cargo");
        c.current_dir(root.join("vm")).args(args).envs(env.iter().copied());
        if let Some(dir) = cargo_target_dir(&root, name) {
            c.arg("--target-dir").arg(dir);
        }
        let mut skip: Vec<&str> = Vec::new();
        if !(sel.full || sel.codegen) && (name == "vm" || name == "vm fp-rbp") {
            skip.extend(CODEGEN_TESTS);
        }
        if !(sel.full || sel.slow_vm) && name == "vm" {
            skip.extend(SLOW_VM_TESTS);
        }
        if !skip.is_empty() {
            c.arg("--");
            for t in skip {
                c.args(["--skip", t]);
            }
        }
        report(name, t, crate::utils::run(&mut c), &failed);
    }
    if !corpus_only && (sel.full || sel.lean) {
        if crate::lean::have_lake() {
            let t = Instant::now();
            report("lean", t, crate::lean::check(false), &failed);
        } else if sel.lean {
            eprintln!("[y] test lean: skipped (no `lake`)");
        }
    }

    // The corpus, one program per job; each builds its references and variants in its own
    // directories.
    let cc = c_compiler().is_some();
    let mut work: Vec<(&Program, Vec<&Variant>)> = Vec::new();
    for program in CORPUS {
        if !opts.programs.is_empty() && !opts.programs.iter().any(|p| p == program.name) {
            continue;
        }
        let vs: Vec<&Variant> = variants
            .iter()
            .copied()
            .filter(|v| sel.corpus(program, v))
            .filter(|v| !(v.vm_only && program.vm.is_empty()))
            .filter(|v| !((!v.final_flags.is_empty() || v.abort) && program.has_dylib()))
            .collect();
        if vs.is_empty() {
            continue;
        }
        if program.c_main.is_some() && !cc {
            eprintln!("[y] test {}: skipped (no `{C_COMPILER}`)", program.name);
            continue;
        }
        work.push((program, vs));
    }
    let jobs = std::thread::available_parallelism().map_or(1, |n| (n.get() / 2).max(1));
    let next = AtomicUsize::new(0);
    std::thread::scope(|s| {
        for _ in 0..jobs.min(work.len()) {
            s.spawn(|| {
                while let Some((program, vs)) = work.get(next.fetch_add(1, Ordering::Relaxed)) {
                    ctx.test_program(program, vs, &failed);
                }
            });
        }
    });

    if !corpus_only {
        let hello = root.join("tests").join("hello.rs");
        type Check<'a> = Box<dyn Fn() -> Result<(), String> + 'a>;
        let checks: [(&str, Check); 11] = [
            ("rt-core-only", Box::new(|| rt_core_only(&root, &crate::utils::RustcInfo::get()?.host))),
            ("jit-sealed", Box::new(|| jit_sealed(&root, &out))),
            ("jit-private-std", Box::new(|| jit_private_std(&rustc_ryo, &root.join("tests").join("vm_jit_private.rs"), &out))),
            ("reject-randomize-layout", Box::new(|| reject_randomize_layout(&rustc_ryo, &hello, &out))),
            ("reject-codegen-units", Box::new(|| reject_codegen_units(&rustc_ryo, &hello, &out))),
            ("incremental", Box::new(|| incremental(&rustc_ryo, &root.join("tests").join("incremental"), &out))),
            ("metadata-only", Box::new(|| metadata_only(&rustc_ryo, &hello, &out))),
            ("dump", Box::new(|| dump(&rustc_ryo, &root.join("tests").join("vm_statics.rs"), &out))),
            ("exports", Box::new(|| same_exports(&rustc_ryo, &root.join("tests").join("vm_exports.rs"), &out))),
            ("backtrace", Box::new(|| backtrace(&rustc_ryo, &root.join("tests").join("vm_backtrace.rs"), &out))),
            // It runs the program it builds.
            ("cargo-ryo", Box::new(|| if VM_RUNS { cargo_smoke(&root, &out) } else { Ok(()) })),
        ];
        for (name, check) in checks {
            if sel.check(name) {
                let t = Instant::now();
                report(name, t, check(), &failed);
            }
        }
    }
    let failed = failed.into_inner().unwrap();
    eprintln!("[y] test: {} in {:.1}s", if sel.full { "full suite" } else { "fast suite" }, start.elapsed().as_secs_f64());
    if !failed.is_empty() {
        return Err(format!("failed tests: {}", failed.join(", ")));
    }
    Ok(())
}

struct Ctx {
    tests: PathBuf,
    out: PathBuf,
    rustc_ryo: PathBuf,
    rustc_clif: PathBuf,
}

/// What a test program did when run.
#[derive(PartialEq)]
struct RunResult {
    code: Option<i32>,
    stdout: String,
    stderr: String,
}

impl RunResult {
    /// Compares with `reference`, which may print the `lost` lines (in order) that this run
    /// doesn't ([`Program::pe_lost_cleanups`]).
    fn compare(&self, reference: &RunResult, lost: &[&str]) -> Result<(), String> {
        if self == reference {
            return Ok(());
        }
        if !lost.is_empty() && self.code == reference.code && self.stderr == reference.stderr {
            // Match this run's lines in the reference's in order; the reference's leftovers
            // must be `lost`.
            let mut have = self.stdout.lines().peekable();
            let mut extra = Vec::new();
            for line in reference.stdout.lines() {
                if have.peek() == Some(&line) {
                    have.next();
                } else {
                    extra.push(line);
                }
            }
            if have.next().is_none() && extra == lost && self.stdout.ends_with('\n') == reference.stdout.ends_with('\n') {
                return Ok(());
            }
        }
        Err(format!(
            "output differs\n--- rustc: exit {:?} ---\nstdout:\n{}stderr:\n{}\
             --- this: exit {:?} ---\nstdout:\n{}stderr:\n{}",
            reference.code, reference.stdout, reference.stderr, self.code, self.stdout, self.stderr
        ))
    }
}

impl Ctx {
    /// Builds and runs `program` with plain rustc and under each of `variants`, and compares.
    fn test_program(&self, program: &Program, variants: &[&Variant], failed: &Mutex<Vec<String>>) {
        let t = Instant::now();
        let reference = match self.build_and_run(program, &REFERENCE) {
            Ok(r) => r,
            Err(msg) => {
                report(&format!("{} [rustc]", program.name), t, Err(msg), failed);
                return;
            }
        };
        let mut reference_abort = None;
        for variant in variants {
            let t = Instant::now();
            let name = format!("{} [{}]", program.name, variant.name);
            let reference = if variant.abort {
                match reference_abort.get_or_insert_with(|| self.build_and_run(program, &REFERENCE_ABORT)) {
                    Ok(r) => &*r,
                    Err(msg) => {
                        report(&name, t, Err(format!("with plain rustc -Cpanic=abort: {msg}")), failed);
                        continue;
                    }
                }
            } else {
                &reference
            };
            // PE runs no landing pads in VM frames (design/platforms.md).
            let lost = if MSVC && variant.compiler == Compiler::Ryo && !variant.no_vm { program.pe_lost_cleanups } else { &[] };
            report(&name, t, self.build_and_run(program, variant).and_then(|r| r.compare(reference, lost)), failed);
        }
    }

    fn compiler(&self, variant: &Variant) -> Command {
        match variant.compiler {
            Compiler::Rustc => cmd("rustc"),
            Compiler::Ryo => {
                let mut c = cmd(&self.rustc_ryo);
                // Every function's machine code is decoded back and compared with its
                // instructions (design/backend.md#debugging-switches).
                c.env("RYO_BACKEND_MARKER", "1").env("RYO_STATS", "1");
                if variant.ryo_std {
                    c.args(["--sysroot", "ryo"]);
                }
                if variant.no_vm {
                    c.env("RYO_NO_VM", "1");
                }
                c
            }
            Compiler::Clif => cmd(&self.rustc_clif),
        }
    }

    /// The compiler's sysroot `lib/rustlib/<target>/lib`, where std's dylib is.
    fn target_libdir(&self, variant: &Variant) -> Result<PathBuf, String> {
        let mut c = self.compiler(variant);
        let libdir = output(c.env_remove("RYO_BACKEND_MARKER").env_remove("RYO_STATS").args(["--print", "target-libdir"]))?;
        Ok(PathBuf::from(libdir.trim()))
    }

    /// Builds every crate of `program` into `target/tests/<program>/<variant>/` and runs the
    /// binary there.
    fn build_and_run(&self, program: &Program, variant: &Variant) -> Result<RunResult, String> {
        let dir = self.out.join(program.name).join(variant.name);
        let _ = fs::remove_dir_all(&dir);
        fs::create_dir_all(&dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
        if let Some(lib) = &program.native_lib {
            lib.build(&dir, None)?;
        }
        let mut exe = None;
        let mut vm_fns = Vec::new();
        let mut native_libs = Vec::new();
        for krate in program.crates {
            let mut c = self.compiler(variant);
            c.arg("--edition=2024")
                .arg(self.tests.join(krate.src))
                .args(krate.kind.flags())
                .args(["--crate-name", krate.name])
                .arg("--out-dir")
                .arg(&dir)
                .arg("-L")
                .arg(&dir)
                .args(program.flags)
                .args(variant.flags);
            if std::ptr::eq(krate, program.crates.last().unwrap()) {
                c.args(variant.final_flags);
            }
            // Every library crate is a dependency of the crates after it.
            for dep in program.crates.iter().take_while(|d| d.name != krate.name) {
                if dep.kind != CrateKind::Bin {
                    c.args(["--extern", dep.name]);
                }
            }
            let res = c.output().map_err(|e| format!("failed to run `{}`: {e}", describe(&c)))?;
            let stderr = String::from_utf8_lossy(&res.stderr);
            if !res.status.success() {
                return Err(format!("`{}` failed:\n{stderr}", describe(&c)));
            }
            if variant.compiler == Compiler::Ryo {
                if !stderr.contains(BACKEND_MARKER) || !stderr.contains(PARTITION_MARKER) {
                    return Err(format!("the ryo backend didn't build {}; stderr:\n{stderr}", krate.name));
                }
                vm_fns.extend(vm_functions(&stderr));
            }
            if let Some(libs) = stderr.lines().find_map(|l| l.strip_prefix("note: native-static-libs: ")) {
                native_libs = libs.split_whitespace().map(str::to_owned).collect();
            }
            if krate.kind == CrateKind::Bin {
                exe = Some(dir.join(exe_name(krate.name)));
            }
        }
        if let Some(c_main) = program.c_main {
            exe = Some(self.link_c(&dir, c_main, program.crates.last().unwrap(), &native_libs)?);
        }
        let exe = exe.ok_or_else(|| format!("{}: no binary crate", program.name))?;
        let result = self.run(&dir, &exe, variant)?;
        if variant.compiler == Compiler::Ryo && !variant.no_vm && !program.vm.is_empty() {
            program.check_vm(&vm_fns, MSVC, !variant.vm_only)?;
        }
        Ok(result)
    }

    /// Compiles and links the C program `c_main` against `lib` (a staticlib or cdylib in `dir`),
    /// with `cc`, or `cl` on MSVC hosts.
    fn link_c(&self, dir: &Path, c_main: &str, lib: &Crate, native_libs: &[String]) -> Result<PathBuf, String> {
        let exe = dir.join(exe_name("c_main"));
        let mut c = c_compiler().ok_or_else(|| format!("no `{C_COMPILER}`"))?;
        if MSVC {
            // Everything after `/link` goes to link.exe, including the `/defaultlib:` options
            // in `native-static-libs`.
            let mut fe = OsString::from("/Fe:");
            fe.push(&exe);
            c.current_dir(dir).arg("/nologo").arg(self.tests.join(c_main)).arg(fe).arg("/link");
            match lib.kind {
                CrateKind::Staticlib => c.arg(dir.join(format!("{}.lib", lib.name))).args(native_libs),
                CrateKind::Cdylib => c.arg(dir.join(format!("{}.dll.lib", lib.name))),
                _ => return Err("c_main needs a staticlib or cdylib".to_owned()),
            };
        } else {
            c.arg(self.tests.join(c_main)).arg("-o").arg(&exe);
            match lib.kind {
                CrateKind::Staticlib => c.arg(dir.join(format!("lib{}.a", lib.name))).args(native_libs),
                CrateKind::Cdylib => c.arg("-L").arg(dir).arg(format!("-l{}", lib.name)),
                _ => return Err("c_main needs a staticlib or cdylib".to_owned()),
            };
        }
        let res = c.output().map_err(|e| format!("failed to run `{}`: {e}", describe(&c)))?;
        if !res.status.success() {
            // cl reports errors on stdout.
            return Err(format!("`{}` failed:\n{}{}", describe(&c), String::from_utf8_lossy(&res.stdout), String::from_utf8_lossy(&res.stderr)));
        }
        Ok(exe)
    }

    /// Runs a built program in `dir`.
    fn run(&self, dir: &Path, exe: &Path, variant: &Variant) -> Result<RunResult, String> {
        let mut run = Command::new(exe);
        run.env_remove("RUST_BACKTRACE").env_remove("RUST_LIB_BACKTRACE").current_dir(dir);
        run.envs(variant.env.iter().copied());
        // Dylibs are found next to the binary, and std's in the sysroot that built it.
        let lib_path_var = if cfg!(windows) {
            "PATH"
        } else if cfg!(target_vendor = "apple") {
            "DYLD_LIBRARY_PATH"
        } else {
            "LD_LIBRARY_PATH"
        };
        let mut paths = vec![dir.to_path_buf(), self.target_libdir(variant)?];
        paths.extend(std::env::split_paths(&std::env::var_os(lib_path_var).unwrap_or_default()));
        run.env(lib_path_var, std::env::join_paths(paths).map_err(|e| e.to_string())?);
        let res = run.output().map_err(|e| format!("failed to run {}: {e}", exe.display()))?;
        // Panic messages name the source path, which is the same for every variant. Thread ids
        // differ between runs.
        Ok(RunResult {
            code: res.status.code(),
            stdout: String::from_utf8_lossy(&res.stdout).into_owned(),
            stderr: normalize_thread_ids(&String::from_utf8_lossy(&res.stderr)),
        })
    }
}

/// Panic messages say `thread 'main' (<os thread id>) panicked`; the id differs between runs.
fn normalize_thread_ids(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for line in s.split_inclusive('\n') {
        if let Some(rest) = line.strip_prefix("thread '")
            && let Some(q) = rest.find("' (")
            && let Some(close) = rest[q + 3..].find(')')
            && rest[q + 3..q + 3 + close].bytes().all(|b| b.is_ascii_digit())
        {
            out.push_str("thread '");
            out.push_str(&rest[..q]);
            out.push_str("' (N");
            out.push_str(&rest[q + 3 + close..]);
        } else {
            out.push_str(line);
        }
    }
    out
}

#[cfg(test)]
mod tests {
    #[test]
    fn clif_variant_only_with_flag() {
        let names = |clif| super::variants(clif).iter().map(|v| v.name).collect::<Vec<_>>();
        let all = [
            "ryo-novm",
            "ryo",
            "ryo-threads8",
            "ryo-O3",
            "ryo-lto",
            "ryo-thinlto-O3",
            "ryo-abort",
            "ryo-std",
            "ryo-std-O3",
            "ryo-std-lto",
            "ryo-std-abort",
            "ryo-std-jit",
            "ryo-std-jit-shuffle",
            "ryo-std-jit-reencode",
            "ryo-jit-ssa",
            "ryo-jit-ssa-osr",
            "ryo-jit-ssa-shuffle",
        ];
        let ryo: Vec<&str> = all.into_iter().filter(|n| super::VM_RUNS || *n == "ryo-novm").collect();
        assert_eq!(names(false), ryo);
        assert_eq!(names(true), [&ryo[..], &["clif"]].concat());
        assert!(super::variants(true).last().unwrap().compiler == super::Compiler::Clif);
    }

    #[test]
    fn fast_set_covers_corpus() {
        use super::{CORPUS, FAST, FULL_ONLY, VARIANTS};
        for p in CORPUS {
            let fast = FAST.iter().filter(|(n, _)| *n == p.name).count();
            let full = FULL_ONLY.iter().filter(|(n, r)| *n == p.name && !r.is_empty()).count();
            assert_eq!(fast + full, 1, "{} must be in FAST or on FULL_ONLY (with a reason), once", p.name);
        }
        for (name, vs) in FAST {
            assert!(CORPUS.iter().any(|p| p.name == *name), "FAST: unknown program {name}");
            for v in *vs {
                assert!(VARIANTS.iter().any(|x| x.name == *v), "FAST: unknown variant {v}");
            }
        }
        for (name, _) in FULL_ONLY {
            assert!(CORPUS.iter().any(|p| p.name == *name), "FULL_ONLY: unknown program {name}");
        }
        for v in super::JIT_VARIANTS {
            assert!(VARIANTS.iter().any(|x| x.name == *v), "JIT_VARIANTS: unknown variant {v}");
        }
    }

    /// Every top- and second-level directory git tracks has a rule, so a new directory can't
    /// drop out of the change-based selection unnoticed.
    #[test]
    fn every_directory_has_a_rule() {
        let files = crate::utils::output(crate::utils::cmd("git").current_dir(crate::utils::root()).arg("ls-files")).unwrap();
        let mut missing = Vec::new();
        for f in files.lines() {
            let parts: Vec<&str> = f.split('/').collect();
            for depth in 1..=2.min(parts.len() - 1) {
                let dir = format!("{}/", parts[..depth].join("/"));
                let covered = super::RULES.iter().any(|(p, _)| p.starts_with(&dir) || dir.starts_with(p));
                if !covered && !missing.contains(&dir) {
                    missing.push(dir);
                }
            }
        }
        assert!(missing.is_empty(), "directories without a rule in RULES: {missing:?}");
    }

    #[test]
    fn path_rules() {
        use super::{Rule, rule};
        assert_eq!(rule("notes/x.md"), Some(Rule::Nothing));
        assert_eq!(rule("AGENTS.md"), Some(Rule::Nothing));
        assert_eq!(rule("lean/README.md"), Some(Rule::Lean));
        assert_eq!(rule("vm/bytecode/src/full.rs"), Some(Rule::Bytecode));
        assert_eq!(rule("vm/bytecode/src/jit/ssa.rs"), Some(Rule::Jit));
        assert_eq!(rule("vm/rt/src/vm/handlers.rs"), Some(Rule::Handlers));
        assert_eq!(rule("vm/rt/src/vm/interp.rs"), Some(Rule::Rt));
        assert_eq!(rule("vm/Cargo.lock"), Some(Rule::Full));
        assert_eq!(rule("bench/codegen/x.txt"), Some(Rule::Nothing));
        assert_eq!(rule("bench/x.rs"), Some(Rule::Full));
        assert_eq!(rule("vm/bytecode/src/ops.rs"), None);
        let mut sel = super::Sel::fast();
        assert!(sel.add_path("tests/vm_cross/lib2.rs").is_ok());
        assert!(sel.add_path("tests/vm_c/main.c").is_ok());
        assert!(sel.add_path("tests/vm_jit_private.rs").is_ok());
        assert!(sel.add_path("tests/nothing.rs").is_err());
        assert_eq!(sel.programs, ["vm_cross", "vm_staticlib", "vm_cdylib"]);
        assert_eq!(sel.checks, ["jit-private-std"]);
    }

    #[test]
    fn parses_vm_functions() {
        let s = "ryo backend: init\nryo: vm fn answer (global)\nryo: vm fn a::b::<u8>\nryo: 2 VM functions\n";
        assert_eq!(super::vm_functions(s), ["answer", "a::b::<u8>"]);
    }

    #[test]
    fn v0_crate_roots() {
        let roots = super::crate_roots("_RNvNtNtCs1xp9oXn4fDY_6ryo_rt2vm3sys5fatal");
        assert_eq!(roots, ["6ryo_rt"]);
        let roots = super::crate_roots("_RINvNtCsabc_4core3ptr13drop_in_placeNtCsdef_3std6ThreadE");
        assert_eq!(roots, ["4core", "3std"]);
    }

    #[test]
    fn compares_with_lost_cleanups() {
        let run = |stdout: &str| super::RunResult { code: Some(0), stdout: stdout.to_owned(), stderr: String::new() };
        let reference = run("drop a\n2\ndrop a\ncaught\n");
        assert!(run("drop a\n2\ncaught\n").compare(&reference, &["drop a"]).is_ok());
        assert!(run("drop a\n2\ncaught\n").compare(&reference, &[]).is_err());
        assert!(run("2\ncaught\n").compare(&reference, &["drop a"]).is_err());
        assert!(run("drop a\n2\ndrop a\ncaught\n").compare(&reference, &["drop a"]).is_ok());
        assert!(run("drop a\n2\ncaught\nmore\n").compare(&reference, &["drop a"]).is_err());
    }

    #[test]
    fn normalizes_thread_ids() {
        let s = "x\nthread 'main' (1234) panicked at a.rs:1:2:\nthread 'a' (b) c\n";
        let want = "x\nthread 'main' (N) panicked at a.rs:1:2:\nthread 'a' (b) c\n";
        assert_eq!(super::normalize_thread_ids(s), want);
    }
}
