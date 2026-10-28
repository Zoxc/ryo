//! `y test` (design/build.md#test-and-bench): the test corpus, diffed against plain rustc, and
//! the smoke tests of `dist/`.

use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Mutex;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Instant;

use crate::utils::{cmd, exe_name, output, root};

mod checks;
mod corpus;
mod multi;

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
    /// Extra flags for the last crate only (as cargo passes `-Clto`, which ryo rejects; none
    /// now). Programs with a Rust dylib are skipped when this is set.
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
    /// A variant of the JIT, run by [`Sel::jit`].
    jit: bool,
}

const VARIANT: Variant = Variant {
    name: "",
    compiler: Compiler::Ryo,
    flags: &[],
    final_flags: &[],
    vm_only: false,
    ryo_std: false,
    abort: false,
    no_vm: false,
    env: &[],
    jit: false,
};

const REFERENCE: Variant = Variant { name: "rustc", compiler: Compiler::Rustc, ..VARIANT };

/// The reference of the [`Variant::abort`] variants.
const REFERENCE_ABORT: Variant = Variant { name: "rustc-abort", compiler: Compiler::Rustc, flags: &["-Cpanic=abort"], ..VARIANT };

const VARIANTS: &[Variant] = &[
    Variant { name: "ryo-novm", no_vm: true, ..VARIANT },
    Variant { name: "ryo", ..VARIANT },
    Variant { name: "ryo-threads8", flags: &["-Zthreads=8"], ..VARIANT },
    Variant { name: "ryo-O3", flags: &["-Copt-level=3"], vm_only: true, ..VARIANT },
    // `-Cpanic=abort` without a ryo sysroot: the terminate stubs and abort paths of VM code.
    Variant { name: "ryo-abort", flags: &["-Cpanic=abort"], abort: true, ..VARIANT },
    // std itself in the VM (design/build.md#build, `--sysroot ryo`).
    Variant { name: "ryo-std", ryo_std: true, ..VARIANT },
    Variant { name: "ryo-std-O3", flags: &["-Copt-level=3"], vm_only: true, ryo_std: true, ..VARIANT },
    Variant { name: "ryo-std-abort", flags: &["-Cpanic=abort"], ryo_std: true, abort: true, ..VARIANT },
    // Every VM function, std's included, runs its JIT code from its first call
    // (design/jit.md#testing), also with frames the JIT lays out differently.
    Variant { name: "ryo-std-jit", ryo_std: true, env: JIT_SYNC, jit: true, ..VARIANT },
    Variant { name: "ryo-std-jit-shuffle", ryo_std: true, env: JIT_SHUFFLE, jit: true, ..VARIANT },
    Variant { name: "ryo-std-jit-reencode", ryo_std: true, env: JIT_REENCODE, jit: true, ..VARIANT },
    // The JIT's SSA tier (design/jit.md#the-ssa-tier), with its checkers, on the corpus's
    // own VM functions: from their first call, and entered by OSR at the first loop head.
    Variant { name: "ryo-jit-ssa", env: JIT_SSA, jit: true, ..VARIANT },
    Variant { name: "ryo-jit-ssa-osr", env: JIT_SSA_OSR, jit: true, ..VARIANT },
    Variant { name: "ryo-jit-ssa-shuffle", env: JIT_SSA_SHUFFLE, jit: true, ..VARIANT },
    // One image per codegen unit (design/backend.md#pipeline): rustc's default merges the
    // corpus's small crates into one CGU, these ask for many, so calls, fn pointers, vtables
    // and statics cross images, and `#[inline]` functions get a copy per image.
    Variant { name: "ryo-cgu1", flags: &["-Ccodegen-units=1"], ..VARIANT },
    Variant { name: "ryo-cgu16", flags: &["-Ccodegen-units=16"], ..VARIANT },
    Variant { name: "ryo-cgu256", flags: &["-Ccodegen-units=256"], ..VARIANT },
    Variant { name: "ryo-cgu16-share-generics", flags: &["-Ccodegen-units=16", "-Zshare-generics=yes"], ..VARIANT },
    // Where rustc would run crate-local ThinLTO, which the backend turns off
    // (design/backend.md#unsupported-options).
    Variant { name: "ryo-cgu16-O3", flags: &["-Ccodegen-units=16", "-Copt-level=3"], vm_only: true, ..VARIANT },
    Variant { name: "ryo-cgu16-jit-ssa", flags: &["-Ccodegen-units=16"], env: JIT_SSA, jit: true, ..VARIANT },
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

/// The variants to build: [`VARIANTS`], plus [`CLIF`] for `test --clif`.
fn variants(clif: bool) -> Vec<&'static Variant> {
    VARIANTS.iter().chain(clif.then_some(&CLIF)).collect()
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
    ("vm_calls", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle", "ryo-cgu16"]),
    ("vm_tail", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle"]),
    ("vm_cross", &["ryo", "ryo-jit-ssa", "ryo-cgu16"]),
    ("vm_cgu", &["ryo", "ryo-cgu1", "ryo-cgu16", "ryo-cgu256", "ryo-cgu16-share-generics", "ryo-cgu16-O3", "ryo-cgu16-jit-ssa"]),
    ("vm_intrinsics", &["ryo"]),
    ("vm_lowerings", &["ryo", "ryo-jit-ssa"]),
    ("vm_simd", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-jit-ssa-shuffle"]),
    ("vm_unwind", &["ryo", "ryo-jit-ssa"]),
    ("vm_aggregates", &["ryo", "ryo-jit-ssa"]),
    ("vm_statics_cross", &["ryo", "ryo-jit-ssa", "ryo-cgu16"]),
    ("vm_dylib", &["ryo", "ryo-jit-ssa", "ryo-cgu16"]),
    ("vm_ffi", &["ryo", "ryo-jit-ssa"]),
    ("vm_cdylib", &["ryo"]),
    ("vm_staticlib2", &["ryo", "ryo-jit-ssa"]),
    ("vm_abort_cleanup", &["ryo-abort"]),
    ("end_ptrs", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-shuffle"]),
    ("vm_unwind_chain", &["ryo", "ryo-jit-ssa", "ryo-jit-ssa-osr", "ryo-abort"]),
    ("vm_double_panic", &["ryo", "ryo-jit-ssa"]),
    ("vm_cxx", &["ryo", "ryo-jit-ssa"]),
    ("vm_cxx_terminate", &["ryo"]),
    ("vm_cxx_nested_panic", &["ryo"]),
    ("vm_seh_av", &["ryo", "ryo-jit-ssa"]),
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
    ("vm_uncaught", "an uncaught panic on a foreign thread; rarely touched"),
    ("vm_longjmp", "longjmp over VM frames without drops; rarely touched"),
];

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
    /// All six `ryo_jit` runs, the corpus under the [`Variant::jit`] variants, jit-private-std.
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
    checks: Vec<Check>,
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
fn test_targets(rel: &str) -> Option<(Vec<&'static str>, Vec<Check>)> {
    let first = |p: &str| p.split('/').next().unwrap_or(p).to_owned();
    let hit = |src: &str| src == rel || (src.contains('/') && first(src) == first(rel));
    let programs: Vec<&str> = CORPUS
        .iter()
        .filter(|p| p.crates.iter().any(|c| hit(c.src)) || p.c_main.is_some_and(hit) || p.native_lib.as_ref().is_some_and(|l| hit(l.src)))
        .map(|p| p.name)
        .collect();
    let checks = match rel {
        "hello.rs" => vec![Check::CargoRyo],
        "vm_backtrace.rs" => vec![Check::Backtrace],
        "vm_exports.rs" => vec![Check::Exports],
        "vm_statics.rs" => vec![Check::Dump],
        "pe_imports/up.rs" | "pe_imports/dy.rs" | "pe_imports/pe_imports.rs" => vec![Check::PeImports],
        "vm_cgu_owner.rs" => vec![Check::CguOwnership],
        "vm_jit_private.rs" => vec![Check::JitPrivateStd],
        "vm_jit_atomics.rs" => vec![Check::JitAtomics],
        "incremental/edits.rs" | "incremental/pm.rs" | "incremental/pm_user.rs" => vec![Check::Incremental],
        _ if rel.starts_with("multi_ryo/") => vec![Check::MultiStaticlib, Check::MultiDylib, Check::MultiVersion],
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

    fn cargo_run(&self, run: &CargoRun) -> bool {
        self.full || (run.selected)(self)
    }

    fn corpus(&self, program: &Program, variant: &Variant) -> bool {
        self.full
            || variant.compiler == Compiler::Clif
            || self.programs.contains(&program.name)
            || (self.fast && FAST.iter().any(|(p, vs)| *p == program.name && vs.contains(&variant.name)))
            || (self.ryo_corpus && variant.name == "ryo")
            || (self.jit && variant.jit)
            || (self.backend && !variant.ryo_std)
            || (self.std && variant.ryo_std)
    }

    fn check(&self, check: Check) -> bool {
        self.full || self.backend || self.checks.contains(&check) || check.selected(self)
    }
}

/// A cargo run of the `vm` workspace.
struct CargoRun {
    name: &'static str,
    args: &'static [&'static str],
    env: &'static [(&'static str, &'static str)],
    /// Whether the selection runs it (besides `--full`).
    selected: fn(&Sel) -> bool,
    /// Its own target directory under `vm/target/features/`, so the ryo_rt feature sets don't
    /// rebuild each other.
    target_subdir: Option<&'static str>,
    /// It runs vm/rt/tests/codegen.rs ([`CODEGEN_TESTS`], skipped unless [`Sel::codegen`]).
    codegen_tests: bool,
    /// It runs [`SLOW_VM_TESTS`] (skipped unless [`Sel::slow_vm`]).
    slow_tests: bool,
}

const CARGO_RUN: CargoRun =
    CargoRun { name: "", args: &[], env: &[], selected: |s| s.jit, target_subdir: None, codegen_tests: false, slow_tests: false };

const JIT_SSA_RUN: &[(&str, &str)] = &[("RYO_JIT_OPT", "ssa"), ("RYO_JIT_CHECK", "1")];
const JIT_REENCODE_RUN: &[(&str, &str)] = &[("RYO_JIT_OPT", "reencode"), ("RYO_JIT_CHECK", "1")];
const JIT_NAIVE_RUN: &[(&str, &str)] = &[("RYO_JIT_OPT", "ssa-naive"), ("RYO_JIT_CHECK", "1")];

/// The runtime once more with handlers that read `fp` from `rbp`, so VM code keeps the frame
/// pointer (design/vm.md#handlers). And the JIT's tests, through the runtime's trips, also with
/// `fp-rbp` (design/jit.md#testing); the other runtime tests run without the JIT: with it, the
/// `jit` feature would unify into `ryo_rt`. The JIT's tests run through its SSA tier (the
/// default) with its checkers, through the naive allocator, and through the re-encoding
/// pipeline.
const CARGO_RUNS: &[CargoRun] = &[
    CargoRun {
        name: "vm",
        args: &["test", "--workspace", "--exclude", "ryo_jit"],
        selected: |s| s.fast || s.rt,
        codegen_tests: true,
        slow_tests: true,
        ..CARGO_RUN
    },
    CargoRun {
        name: "vm fp-rbp",
        args: &["test", "-p", "ryo_rt", "--features", "fp-rbp"],
        selected: |s| s.fp_rbp,
        target_subdir: Some("fp-rbp"),
        codegen_tests: true,
        ..CARGO_RUN
    },
    CargoRun {
        name: "vm jit",
        args: &["test", "-p", "ryo_jit"],
        env: JIT_SSA_RUN,
        selected: |s| s.fast || s.jit,
        target_subdir: Some("jit"),
        ..CARGO_RUN
    },
    // The runtime's own unit tests of its JIT side (`vm::jit`: the merge rendezvous etc.),
    // which the `vm` run builds without the `jit` feature.
    CargoRun {
        name: "vm rt jit",
        args: &["test", "-p", "ryo_rt", "--features", "jit", "--lib"],
        selected: |s| s.fast || s.rt,
        target_subdir: Some("jit"),
        ..CARGO_RUN
    },
    CargoRun {
        name: "vm jit fp-rbp",
        args: &["test", "-p", "ryo_jit", "--features", "ryo_rt/fp-rbp"],
        env: JIT_SSA_RUN,
        selected: |s| s.jit || s.fp_rbp,
        target_subdir: Some("jit-fp-rbp"),
        ..CARGO_RUN
    },
    CargoRun { name: "vm jit reencode", args: &["test", "-p", "ryo_jit"], env: JIT_REENCODE_RUN, target_subdir: Some("jit"), ..CARGO_RUN },
    CargoRun {
        name: "vm jit reencode fp-rbp",
        args: &["test", "-p", "ryo_jit", "--features", "ryo_rt/fp-rbp"],
        env: JIT_REENCODE_RUN,
        target_subdir: Some("jit-fp-rbp"),
        ..CARGO_RUN
    },
    CargoRun { name: "vm jit ssa-naive", args: &["test", "-p", "ryo_jit"], env: JIT_NAIVE_RUN, target_subdir: Some("jit"), ..CARGO_RUN },
    CargoRun {
        name: "vm jit ssa-naive fp-rbp",
        args: &["test", "-p", "ryo_jit", "--features", "ryo_rt/fp-rbp"],
        env: JIT_NAIVE_RUN,
        target_subdir: Some("jit-fp-rbp"),
        ..CARGO_RUN
    },
];

/// The checks besides the corpus and the cargo runs.
#[derive(Clone, Copy, Debug, PartialEq)]
enum Check {
    RtCoreOnly,
    JitSealed,
    JitPrivateStd,
    JitAtomics,
    RejectUnsupported,
    CguDeterministic,
    CguOwnership,
    Incremental,
    MetadataOnly,
    Dump,
    Exports,
    Backtrace,
    MultiStaticlib,
    MultiDylib,
    /// A second full `y build`, of another ABI tag.
    MultiVersion,
    PeImports,
    /// It runs the program it builds.
    CargoRyo,
}

impl Check {
    const ALL: [Check; 17] = [
        Check::RtCoreOnly,
        Check::JitSealed,
        Check::JitPrivateStd,
        Check::JitAtomics,
        Check::RejectUnsupported,
        Check::CguDeterministic,
        Check::CguOwnership,
        Check::Incremental,
        Check::MetadataOnly,
        Check::Dump,
        Check::Exports,
        Check::Backtrace,
        Check::MultiStaticlib,
        Check::MultiDylib,
        Check::MultiVersion,
        Check::PeImports,
        Check::CargoRyo,
    ];

    fn name(self) -> &'static str {
        match self {
            Check::RtCoreOnly => "rt-core-only",
            Check::JitSealed => "jit-sealed",
            Check::JitPrivateStd => "jit-private-std",
            Check::JitAtomics => "jit-atomics",
            Check::RejectUnsupported => "reject-unsupported",
            Check::CguDeterministic => "cgu-deterministic",
            Check::CguOwnership => "cgu-ownership",
            Check::Incremental => "incremental",
            Check::MetadataOnly => "metadata-only",
            Check::Dump => "dump",
            Check::Exports => "exports",
            Check::Backtrace => "backtrace",
            Check::MultiStaticlib => "multi-staticlib",
            Check::MultiDylib => "multi-dylib",
            Check::MultiVersion => "multi-version",
            Check::PeImports => "pe-imports",
            Check::CargoRyo => "cargo-ryo",
        }
    }

    /// Whether `sel`'s groups run it; `--full`, `--only backend` and a change to its test
    /// run every check.
    fn selected(self, sel: &Sel) -> bool {
        match self {
            Check::RejectUnsupported
            | Check::CguDeterministic
            | Check::CguOwnership
            | Check::MetadataOnly
            | Check::Dump
            | Check::Exports
            | Check::Backtrace
            | Check::PeImports => sel.fast,
            Check::RtCoreOnly | Check::JitSealed | Check::MultiStaticlib | Check::MultiDylib => sel.rt,
            Check::JitPrivateStd | Check::JitAtomics => sel.jit,
            Check::Incremental | Check::CargoRyo | Check::MultiVersion => false,
        }
    }

    fn run(self, info: &crate::utils::RustcInfo, root: &Path, rustc_ryo: &Path, out: &Path) -> Result<(), String> {
        let tests = root.join("tests");
        let hello = tests.join("hello.rs");
        match self {
            Check::RtCoreOnly => rt_core_only(info, root, &info.host),
            Check::JitSealed => jit_sealed(info, root, out),
            Check::JitPrivateStd => jit_private_std(info, rustc_ryo, &tests.join("vm_jit_private.rs"), out),
            Check::JitAtomics => jit_atomics(info, rustc_ryo, &tests.join("vm_jit_atomics.rs"), out),
            Check::RejectUnsupported => reject_unsupported(rustc_ryo, &hello, out),
            Check::CguDeterministic => cgu_deterministic(rustc_ryo, &tests.join("vm_cgu.rs"), out),
            Check::CguOwnership => cgu_ownership(info, rustc_ryo, &tests.join("vm_cgu_owner.rs"), out),
            Check::Incremental => incremental(rustc_ryo, &tests.join("incremental"), out),
            Check::MetadataOnly => metadata_only(rustc_ryo, &hello, out),
            Check::Dump => dump(rustc_ryo, &tests.join("vm_statics.rs"), out),
            Check::Exports => same_exports(info, rustc_ryo, &tests.join("vm_exports.rs"), out),
            Check::Backtrace => backtrace(rustc_ryo, &tests.join("vm_backtrace.rs"), out),
            Check::MultiStaticlib => multi::multi_staticlib(info, rustc_ryo, &tests.join("multi_ryo"), out),
            Check::MultiDylib => multi::multi_dylib(info, root, rustc_ryo, &tests.join("multi_ryo"), out),
            Check::MultiVersion => multi::multi_version(info, root, rustc_ryo, &tests.join("multi_ryo"), out),
            Check::PeImports => pe_imports(info, root, rustc_ryo, &tests.join("pe_imports"), out),
            Check::CargoRyo => cargo_smoke(info, root, out),
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
fn ryo_sysroot_usable(info: &crate::utils::RustcInfo, root: &Path) -> Result<(), String> {
    use crate::sysroot::{SYSROOT_DIR, SysrootStatus, ryo_sysroot_status};
    let dist = root.join("dist");
    match ryo_sysroot_status(info, &dist) {
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

/// Tests of the `vm` run that only `--full` and changes to the bytecode encoder or the backend
/// run: every opcode in every mode through the encoder, which takes about 5 min in a debug build.
/// (`--skip` matches by name, so vm/bytecode/tests/full.rs's cheap test of that name is skipped too.)
const SLOW_VM_TESTS: [&str; 1] = ["every_opcode_round_trips"];

/// The tests in vm/rt/tests/codegen.rs (skipped unless [`Sel::codegen`]).
const CODEGEN_TESTS: [&str; 2] = ["win64_handlers_preserve_xmm6_to_15", "handlers_read_rbp_first_and_hot_ones_have_no_prologue"];

pub fn run(opts: &Options) -> Result<(), String> {
    let start = Instant::now();
    let root = root();
    let rustc_ryo = crate::utils::require_dist(&root)?;
    let info = crate::utils::RustcInfo::get()?;
    // The checked JIT (debug assertions, overflow checks; design/build.md#build) unless the
    // caller set `RYO_JIT_CHECKED`; `rustc-ryo` reads it, for host compilations.
    if std::env::var_os("RYO_JIT_CHECKED").is_none() {
        // SAFETY: no other thread runs yet.
        unsafe { std::env::set_var("RYO_JIT_CHECKED", "1") };
    }
    let checked = std::env::var_os("RYO_JIT_CHECKED").is_some_and(|v| !v.is_empty() && v != "0");
    if checked && !root.join("dist").join(crate::jit::CHECKED_DIR).is_dir() {
        return Err("dist/jit-checked/ is missing; run `./y.sh build`".to_owned());
    }
    eprintln!(
        "[y] test: JIT: {}",
        if checked { "checked (debug assertions, overflow checks; dist/jit-checked/)" } else { "release (RYO_JIT_CHECKED=0)" }
    );
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
    if wants_std && let Err(why) = ryo_sysroot_usable(&info, &root) {
        // Only an explicit request fails; the fast suite and an escalation to `--full` from
        // the changed paths skip them.
        if opts.full || opts.only == Some(Area::Std) || opts.variants.iter().any(|n| VARIANTS.iter().any(|v| v.ryo_std && v.name == n)) {
            return Err(format!("the ryo-std variants can't run: {why}"));
        }
        eprintln!("[y] WARNING: the ryo-std variants are SKIPPED: {why}");
        variants.retain(|v| !v.ryo_std);
    }
    variants.retain(|v| opts.variants.is_empty() || opts.variants.iter().any(|n| n == v.name));
    let corpus_only = !opts.programs.is_empty() || !opts.variants.is_empty();

    let out = root.join("target").join("tests");
    crate::utils::create_dir(&out)?;
    let ctx = Ctx {
        tests: root.join("tests"),
        out: out.clone(),
        rustc_ryo: rustc_ryo.clone(),
        rustc_clif: crate::utils::dist_bin(&root, "rustc-clif"),
        info: &info,
    };
    let failed = Mutex::new(Vec::new());

    for run in CARGO_RUNS {
        if corpus_only || !sel.cargo_run(run) {
            continue;
        }
        let t = Instant::now();
        let mut c = cmd("cargo");
        c.current_dir(root.join("vm")).args(run.args).envs(run.env.iter().copied());
        if let Some(sub) = run.target_subdir {
            c.arg("--target-dir").arg(root.join("vm").join("target").join("features").join(sub));
        }
        let mut skip: Vec<&str> = Vec::new();
        if !(sel.full || sel.codegen) && run.codegen_tests {
            skip.extend(CODEGEN_TESTS);
        }
        if !(sel.full || sel.slow_vm) && run.slow_tests {
            skip.extend(SLOW_VM_TESTS);
        }
        if !skip.is_empty() {
            c.arg("--");
            for t in skip {
                c.args(["--skip", t]);
            }
        }
        report(run.name, t, crate::utils::run(&mut c), &failed);
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
    let cc = [c_compiler(false).is_some(), c_compiler(true).is_some()];
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
            .filter(|v| !(v.abort && program.foreign_unwind))
            // Two LTO'd (or abort) staticlibs each carry all of std: one C link can't take both.
            .filter(|v| !((!v.final_flags.is_empty() || v.abort) && program.crates.iter().filter(|c| c.kind == CrateKind::Staticlib).count() > 1))
            .collect();
        if vs.is_empty() {
            continue;
        }
        if program.msvc_only && !MSVC {
            continue;
        }
        if let Some(c_main) = program.c_main
            && !cc[usize::from(is_cxx(c_main))]
        {
            // On Windows the SEH and C++ exception tests are C mains: a missing `cl` must not
            // let the run pass without them.
            let msg = format!("no `{}`", c_compiler_name(is_cxx(c_main)));
            if MSVC {
                report(
                    program.name,
                    Instant::now(),
                    Err(format!("{msg} (run from a Visual Studio developer shell, or install the C++ tools)")),
                    &failed,
                );
            } else {
                eprintln!("[y] test {}: skipped ({msg})", program.name);
            }
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
        for check in Check::ALL {
            if sel.check(check) {
                let t = Instant::now();
                report(check.name(), t, check.run(&info, &root, &rustc_ryo, &out), &failed);
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

struct Ctx<'a> {
    tests: PathBuf,
    out: PathBuf,
    rustc_ryo: PathBuf,
    rustc_clif: PathBuf,
    info: &'a crate::utils::RustcInfo,
}

/// What a test program did when run.
#[derive(PartialEq)]
struct RunResult {
    code: Option<i32>,
    stdout: String,
    stderr: String,
}

impl RunResult {
    /// Compares with `reference`, without the `[ryo] jit` lines of `RYO_JIT_STATS` in this
    /// run's stderr.
    fn compare(&self, reference: &RunResult) -> Result<(), String> {
        let stderr: String = self.stderr.split_inclusive('\n').filter(|l| !l.starts_with("[ryo] jit")).collect();
        if self.code == reference.code && self.stdout == reference.stdout && stderr == reference.stderr {
            return Ok(());
        }
        Err(format!(
            "output differs\n--- rustc: exit {:?} ---\nstdout:\n{}stderr:\n{}\
             --- this: exit {:?} ---\nstdout:\n{}stderr:\n{}",
            reference.code, reference.stdout, reference.stderr, self.code, self.stdout, self.stderr
        ))
    }
}

impl Ctx<'_> {
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
            report(&name, t, self.build_and_run(program, variant).and_then(|r| r.compare(reference)), failed);
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
        crate::utils::create_dir(&dir)?;
        if let Some(lib) = &program.native_lib {
            lib.build(self.info, &dir, None)?;
        }
        let mut exe = None;
        let mut vm_fns = Vec::new();
        let mut native_libs = Vec::new();
        let stderrs = program.compile(
            &self.tests,
            &dir,
            || self.compiler(variant),
            |_, c| {
                c.args(variant.flags);
            },
            variant.final_flags,
        )?;
        for (krate, stderr) in stderrs {
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
            let libs: Vec<&Crate> = program.crates.iter().filter(|c| matches!(c.kind, CrateKind::Staticlib | CrateKind::Cdylib)).collect();
            exe = Some(self.link_c(&dir, c_main, &libs, &native_libs)?);
        }
        let exe = exe.ok_or_else(|| format!("{}: no binary crate", program.name))?;
        let result = self.run(&dir, &exe, variant)?;
        if variant.compiler == Compiler::Ryo && !variant.no_vm && !program.vm.is_empty() {
            program.check_vm(&vm_fns, !variant.vm_only)?;
        }
        Ok(result)
    }

    /// Compiles and links the C or C++ program `c_main` against `libs` (staticlibs or cdylibs
    /// in `dir`), with `cc` or `c++`, or `cl` on MSVC hosts (for C++ with `/EHs`: C++
    /// exceptions, which may come out of `extern "C"` functions, the Rust ones).
    fn link_c(&self, dir: &Path, c_main: &str, libs: &[&Crate], native_libs: &[String]) -> Result<PathBuf, String> {
        let exe = dir.join(exe_name("c_main"));
        let cxx = is_cxx(c_main);
        let mut c = c_compiler(cxx).ok_or_else(|| format!("no `{}`", c_compiler_name(cxx)))?;
        if MSVC {
            // Everything after `/link` goes to link.exe, including the `/defaultlib:` options
            // in `native-static-libs`.
            let mut fe = OsString::from("/Fe:");
            fe.push(&exe);
            if cxx {
                c.arg("/EHs");
            }
            c.current_dir(dir).arg("/nologo").arg(self.tests.join(c_main)).arg(fe).arg("/link");
            for lib in libs {
                match lib.kind {
                    CrateKind::Staticlib => c.arg(dir.join(format!("{}.lib", lib.name))),
                    _ => c.arg(dir.join(format!("{}.dll.lib", lib.name))),
                };
            }
        } else {
            c.arg(self.tests.join(c_main)).arg("-o").arg(&exe);
            for lib in libs {
                match lib.kind {
                    CrateKind::Staticlib => c.arg(dir.join(format!("lib{}.a", lib.name))),
                    _ => c.arg("-L").arg(dir).arg(format!("-l{}", lib.name)),
                };
            }
        }
        if libs.is_empty() {
            return Err("c_main needs a staticlib or cdylib".to_owned());
        }
        if libs.iter().any(|l| l.kind == CrateKind::Staticlib) {
            c.args(native_libs);
        }
        // cl reports errors on stdout, which `capture_ok` includes.
        crate::utils::capture_ok(&mut c)?;
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
        // Far above any program's run time, even with the JIT checkers on.
        let res = crate::utils::output_timeout(&mut run, std::time::Duration::from_secs(300))?;
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
        let all = names(false);
        assert!(!all.contains(&"clif"));
        assert_eq!(names(true), [&all[..], &["clif"]].concat());
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

    /// Every RULES prefix matches some tracked file: a rule whose path was renamed or removed
    /// would stop matching and leave its changes to a later, broader rule. `notes/` is the
    /// local, untracked notes directory.
    #[test]
    fn every_rule_matches_a_file() {
        let files = crate::utils::output(crate::utils::cmd("git").current_dir(crate::utils::root()).arg("ls-files")).unwrap();
        let dead: Vec<&str> = super::RULES.iter().map(|(p, _)| *p).filter(|p| *p != "notes/" && !files.lines().any(|f| f.starts_with(p))).collect();
        assert!(dead.is_empty(), "RULES prefixes that match no file: {dead:?}");
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
        assert_eq!(sel.checks, [super::Check::JitPrivateStd]);
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
    fn normalizes_thread_ids() {
        let s = "x\nthread 'main' (1234) panicked at a.rs:1:2:\nthread 'a' (b) c\n";
        let want = "x\nthread 'main' (N) panicked at a.rs:1:2:\nthread 'a' (b) c\n";
        assert_eq!(super::normalize_thread_ids(s), want);
    }
}
