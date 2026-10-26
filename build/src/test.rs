//! `y test` (design/build.md#test-and-bench): the test corpus, diffed against plain rustc, and
//! the smoke tests of `dist/`.

use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Mutex;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Instant;

use crate::utils::{cmd, describe, dll_name, exe_name, output, root};

/// A test program: one or more crates under `tests/`, built in order. The binary crate runs,
/// or, for [`Program::c_main`], a C program linked against the last crate.
pub(crate) struct Program {
    pub(crate) name: &'static str,
    pub(crate) crates: &'static [Crate],
    /// Extra flags for every crate.
    pub(crate) flags: &'static [&'static str],
    /// Functions the ryo build must compile to bytecode (as `RYO_STATS` prints them).
    vm: &'static [&'static str],
    /// A C `main` (relative to `tests/`), compiled with `cc` (`cl` on MSVC) and linked against
    /// the last crate (a staticlib or cdylib). Skipped without that compiler.
    c_main: Option<&'static str>,
    /// A static library the crates link (`#[link(kind = "static")]`), built before them.
    pub native_lib: Option<NativeLib>,
}

impl Program {
    /// Whether the binary links a Rust dylib (LTO doesn't support that). A crate that is both
    /// an rlib and a dylib is linked as the rlib.
    pub(crate) fn has_dylib(&self) -> bool {
        self.flags.contains(&"-Cprefer-dynamic") || self.crates.iter().any(|c| c.kind == CrateKind::Dylib)
    }
}

/// A stand-in for a C static library: a `#![no_std]` Rust file without Rust symbol
/// dependencies, compiled to an object by plain rustc and archived with the toolchain's
/// `llvm-ar`, so it also builds for a cross target without a C compiler.
pub struct NativeLib {
    /// The library name (`#[link(name = …)]`).
    pub name: &'static str,
    /// Source path, relative to `tests/`.
    pub src: &'static str,
}

impl NativeLib {
    /// Builds the library into `dir`, for `target` (the host if `None`).
    pub fn build(&self, dir: &Path, target: Option<&str>) -> Result<(), String> {
        let info = crate::utils::RustcInfo::get()?;
        let obj = dir.join(format!("{}.o", self.name));
        let mut c = cmd("rustc");
        c.args(["--edition=2024", "--crate-type=lib", "--emit=obj", "-Cpanic=abort", "--crate-name", self.name])
            .arg(root().join("tests").join(self.src))
            .arg("-o")
            .arg(&obj);
        if let Some(t) = target {
            c.args(["--target", t]);
        }
        crate::utils::run(&mut c)?;
        let msvc = target.unwrap_or(&info.host).contains("msvc");
        let lib = if msvc { format!("{}.lib", self.name) } else { format!("lib{}.a", self.name) };
        let ar = info.sysroot.join("lib").join("rustlib").join(&info.host).join("bin").join(exe_name("llvm-ar"));
        crate::utils::run(cmd(ar).arg("rcs").arg(dir.join(lib)).arg(&obj))
    }
}

/// Defaults for [`Program`] fields.
const PROGRAM: Program = Program { name: "", crates: &[], flags: &[], vm: &[], c_main: None, native_lib: None };

pub(crate) struct Crate {
    /// The crate name, passed as `--crate-name`.
    pub(crate) name: &'static str,
    /// Source path, relative to `tests/`.
    pub(crate) src: &'static str,
    pub(crate) kind: CrateKind,
}

#[derive(Clone, Copy, PartialEq)]
pub(crate) enum CrateKind {
    Bin,
    Rlib,
    Dylib,
    /// Both an rlib and a dylib from one compilation (one link per crate type in the backend).
    RlibDylib,
    Staticlib,
    Cdylib,
}

impl CrateKind {
    pub(crate) fn flags(self) -> &'static [&'static str] {
        match self {
            CrateKind::Bin => &["--crate-type", "bin"],
            CrateKind::Rlib => &["--crate-type", "rlib"],
            CrateKind::Dylib => &["--crate-type", "dylib"],
            CrateKind::RlibDylib => &["--crate-type", "rlib", "--crate-type", "dylib"],
            // The native libraries a C link needs are printed as a note.
            CrateKind::Staticlib => &["--crate-type", "staticlib", "--print=native-static-libs"],
            CrateKind::Cdylib => &["--crate-type", "cdylib"],
        }
    }
}

const fn krate(name: &'static str, src: &'static str, kind: CrateKind) -> Crate {
    Crate { name, src, kind }
}

/// A one-file binary program `tests/<name>.rs`.
macro_rules! single {
    ($name:literal) => {
        Program { name: $name, crates: &[krate($name, concat!($name, ".rs"), CrateKind::Bin)], ..PROGRAM }
    };
    ($name:literal, vm: $vm:expr $(,)?) => {
        Program { name: $name, crates: &[krate($name, concat!($name, ".rs"), CrateKind::Bin)], vm: $vm, ..PROGRAM }
    };
}

/// Programs built with plain rustc and with every [`Variant`]; their outputs must match.
pub(crate) const CORPUS: &[Program] = &[
    single!("hello"),
    single!("arith"),
    single!("structs_enums"),
    single!("generics_traits"),
    single!("closures_iters"),
    single!("collections"),
    single!("panics"),
    single!("exit_code"),
    single!("end_ptrs"),
    Program {
        name: "cross_crate",
        crates: &[krate("ccl", "cross_crate/lib.rs", CrateKind::Rlib), krate("main", "cross_crate/main.rs", CrateKind::Bin)],
        ..PROGRAM
    },
    Program {
        name: "dylib",
        crates: &[krate("rdy", "dylib/lib.rs", CrateKind::Dylib), krate("main", "dylib/main.rs", CrateKind::Bin)],
        // Both link std's dylib, so std shows up once.
        flags: &["-Cprefer-dynamic"],
        ..PROGRAM
    },
    // VM functions called from native code, a VM `main`, and across crates. Local items are
    // printed without their crate name.
    single!(
        "vm_answer",
        vm: &["main", "answer", "pick", "twice", "wide", "always"]
    ),
    single!(
        "vm_main",
        vm: &["main", "answer"]
    ),
    single!(
        "vm_refs",
        vm: &["main", "from_static", "<S as Get>::get", "from_const"]
    ),
    // Milestone 4 (design/lowering.md): each feature's functions must be bytecode.
    single!(
        "vm_ints",
        vm: &["main", "ops32", "ops_u8", "wide", "casts", "float_casts", "floats", "checked", "chars", "bits", "neg", "cmp"]
    ),
    single!(
        "vm_control",
        vm: &["main", "collatz", "dense", "sparse", "area", "discr", "niches", "make", "labeled", "switch128", "mid", "mid_index"]
    ),
    single!(
        "vm_calls",
        vm: &["main", "add", "swap", "bump", "sum", "fib", "talk", "<Dog as Speak>::speak", "constants", "apply", "double", "closures", "may_panic", "<Noisy as std::ops::Drop>::drop"],
        // `speak` is a `call.ind` through the vtable; `P`'s `Debug` impl is called through a
        // vtable by native `fmt` code.
    ),
    // Milestone 5 (design/lowering.md#calls).
    single!(
        "vm_dyn",
        vm: &[
            "main", "shapes", "upcast", "closures", "shims", "apply", "apply_mut", "apply_once",
            "<Circle as Shape>::mixed", "<Rect as Shape>::boxed", "<Circle as Shape>::pinned",
            "<dyn Step as Step>::step - shim(reify)", "call_once::<fn(u32) -> u32>"
        ]
    ),
    single!(
        "vm_intrinsics",
        vm: &["main", "atomics", "atomic_ptrs", "unwinding", "misc", "dst", "direct", "contention"]
    ),
    single!(
        "vm_lowerings",
        vm: &["main", "offsets", "by_one", "small_div", "rotates", "copies"]
    ),
    // The ABI sweep (design/build.md#test-and-bench).
    single!(
        "vm_abi",
        vm: &[
            "main", "track_caller_vm", "shapes_vm", "<VmShape as Shape>::big", "<VmShape as Shape>::small", "c_calls",
            "unit::vm", "unit::vm_to_native", "unit::vm_to_vm", "unit::vm_ptrs", "ints::vm", "ints::vm_to_native", "ints::vm_ptrs",
            "narrow::vm", "narrow::vm_to_native", "wide::vm", "wide::vm_to_native", "wide_late::vm", "wide_late::vm_to_native",
            "floats::vm", "floats::vm_to_native", "float_pair::vm", "mixed_pair::vm", "xmm_gpr::vm", "many_f64::vm",
            "many_f64::vm_to_native", "many_u64::vm", "many_u64::vm_to_native", "interleaved::vm", "interleaved::vm_to_native", "interleaved::vm_ptrs",
            "pair_split::vm", "pair_split::vm_to_native", "slices::vm", "bytes3::vm", "bytes3::vm_to_native", "bytes5::vm",
            "bytes6::vm", "bytes7::vm", "bytes7::vm_ptrs", "three_u32::vm", "three_u32::vm_to_native", "quad_f32::vm",
            "big::vm", "big::vm_to_native", "big::vm_ptrs", "big_late::vm", "big_late::vm_to_native", "opt_wide::vm",
            "niches::vm", "enums::vm", "enums::vm_to_native", "zsts::vm", "f16s::vm", "f16s::vm_to_native", "f128s::vm",
            "f128s::vm_to_native",
        ]
    ),
    single!(
        "vm_tail",
        vm: &["main", "count", "even", "odd", "big", "big2", "via_ptr", "to_upstream", "to_native", "virt", "panicky"]
    ),
    // Milestone 5: `#[track_caller]` and unwinding. The panic hook is a VM closure that the
    // native panic machinery calls.
    single!(
        "vm_unwind",
        vm: &[
            "main", "here", "nested", "with_args", "tc_many", "generic::<std::vec::Vec<u8>>", "checked_div",
            "tc_closure", "tc_closure::{closure#0}", "S::loc", "deep", "<D as std::ops::Drop>::drop", "idx",
            "sort_panics", "sort_panics::{closure#0}", "call_ptr", "tc_panic", "tc_panic - shim(reify)", "rethrow",
            "compares", "tc_nine", "<S as Loc>::at", "dyn_locs", "dyn_locs::{closure#0}"
        ],
        // `tc_nine` is called from the native `native_caller`.
    ),
    // The terminate stubs: both programs abort (the exit status is compared too).
    single!("vm_abort_cleanup", vm: &["main", "f", "<P as std::ops::Drop>::drop"]),
    single!("vm_abort_nounwind", vm: &["main", "no_unwind"]),
    single!(
        "vm_aggregates",
        vm: &["main", "tail", "nested", "rcs", "coerce_ref", "coerce_pin", "coerce_tail", "repeat", "wide_cmp", "arith128", "ovf128", "half", "scopes", "half_size", "borrow_loop", "unwind_live", "relive", "packed", "min128"]
    ),
    Program {
        name: "vm_ffi",
        crates: &[krate("main", "vm_ffi/main.rs", CrateKind::Bin)],
        vm: &["main", "read", "add"],
        native_lib: Some(NativeLib { name: "ryo_clib", src: "vm_ffi/clib.rs" }),
        ..PROGRAM
    },
    Program {
        name: "vm_cross",
        crates: &[
            krate("vml", "vm_cross/lib.rs", CrateKind::Rlib),
            krate("vml2", "vm_cross/lib2.rs", CrateKind::Rlib),
            krate("main", "vm_cross/main.rs", CrateKind::Bin),
        ],
        vm: &["answer", "calls_answer", "generic::<u16>", "vml::always", "vml::generic::<u8>", "vml::inl", "own"],
        ..PROGRAM
    },
    Program {
        name: "vm_dylib",
        crates: &[krate("vmd", "vm_dylib/lib.rs", CrateKind::RlibDylib), krate("main", "vm_dylib/main.rs", CrateKind::Bin)],
        flags: &["-Cprefer-dynamic"],
        vm: &["answer", "vmd::generic::<i8>", "local"],
        ..PROGRAM
    },
    // Constants and statics (design/lowering.md#constants): type ids, thread locals through
    // the `ThreadLocal` shim, constants pointing at statics, functions and vtables.
    single!(
        "vm_statics",
        vm: &["main", "bump", "nested", "table", "atomics", "type_ids", "type_id_bits", "downcast", "tls", "tls_key"]
    ),
    Program {
        name: "vm_statics_cross",
        crates: &[krate("vsl", "vm_statics_cross/lib.rs", CrateKind::Rlib), krate("main", "vm_statics_cross/main.rs", CrateKind::Bin)],
        vm: &["main", "statics", "fns", "dyns", "tls", "local", "f", "bump_tl", "<T as Shape>::area"],
        ..PROGRAM
    },
    // An rlib linked into a Rust dylib: its image's symbols (foreign, other crates') must not
    // reach the dylib's export list. std is a dylib too, with thread locals on both sides.
    Program {
        name: "vm_dylib_dep",
        crates: &[
            krate("vda", "vm_dylib_dep/a.rs", CrateKind::Rlib),
            krate("vdd", "vm_dylib_dep/d.rs", CrateKind::Dylib),
            krate("main", "vm_dylib_dep/main.rs", CrateKind::Bin),
        ],
        flags: &["-Cprefer-dynamic"],
        vm: &["main", "bump", "f", "g"],
        ..PROGRAM
    },
    // `-Clto` (the LTO variants) downstream of a crate built as rlib and dylib.
    Program {
        name: "vm_lto_dep",
        crates: &[krate("vla", "vm_lto_dep/a.rs", CrateKind::RlibDylib), krate("main", "vm_lto_dep/main.rs", CrateKind::Bin)],
        vm: &["main", "f", "h"],
        ..PROGRAM
    },
    // Found building std with ryo (`--sysroot ryo`): a constructor entering the VM before
    // `main`, unsized arguments, `extern_weak` statics, LLVM intrinsics of local copies.
    single!(
        "vm_sysroot",
        vm: &["main", "ctor_value", "xgetbv_x87"]
    ),
    single!(
        "vm_fn_items",
        vm: &[
            "main", "upstream_ctors", "local_ctors", "results", "native_item", "std::option::Option::<Local>::Some",
            "<fn(u32) -> u32 {with_asm} as std::ops::FnMut<(u32,)>>::call_mut - shim(fn(u32) -> u32 {with_asm})"
        ]
    ),
    // Externally implementable items: the implementations stay native (cg_llvm defines the
    // declarations' symbols next to them); their callers are VM functions.
    Program {
        name: "vm_eii",
        crates: &[krate("vme", "vm_eii/decl.rs", CrateKind::Rlib), krate("main", "vm_eii/main.rs", CrateKind::Bin)],
        vm: &["main", "calls"],
        ..PROGRAM
    },
    // Functions with an interposable `#[linkage]` stay native, so a strong definition in
    // another crate replaces a weak one for VM callers too.
    Program {
        name: "vm_linkage",
        crates: &[krate("vlk", "vm_linkage/lib.rs", CrateKind::Rlib), krate("main", "vm_linkage/main.rs", CrateKind::Bin)],
        vm: &["main", "callers", "pointers"],
        ..PROGRAM
    },
    Program {
        name: "vm_staticlib",
        crates: &[krate("vmc", "vm_c/lib.rs", CrateKind::Staticlib)],
        vm: &["answer"],
        c_main: Some("vm_c/main.c"),
        ..PROGRAM
    },
    Program { name: "vm_cdylib", crates: &[krate("vmc", "vm_c/lib.rs", CrateKind::Cdylib)], vm: &["answer"], c_main: Some("vm_c/main.c"), ..PROGRAM },
];

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

/// The fast suite's corpus (notes/fast-tests.md): each program with the variants it runs under.
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
    ("vm_unwind", &["ryo", "ryo-jit-ssa"]),
    ("vm_aggregates", &["ryo", "ryo-jit-ssa"]),
    ("vm_statics_cross", &["ryo", "ryo-jit-ssa"]),
    ("vm_dylib", &["ryo", "ryo-jit-ssa"]),
    ("vm_ffi", &["ryo", "ryo-jit-ssa"]),
    ("vm_cdylib", &["ryo"]),
    ("vm_lto_dep", &["ryo-lto"]),
    ("vm_abort_cleanup", &["ryo-abort"]),
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
                "reject-randomize-layout" | "reject-codegen-units" | "reject-incremental" | "metadata-only" | "dump" | "exports" | "backtrace" => {
                    self.fast
                }
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

/// Whether the ryo sysroot can be tested against: `Err` with the reason if not.
fn ryo_sysroot_usable(root: &Path) -> Result<(), String> {
    let dir = root.join("dist").join(crate::sysroot::SYSROOT_DIR);
    if dir.is_dir() { Ok(()) } else { Err(format!("no ryo sysroot at {} (`./y.sh build --sysroot ryo`)", dir.display())) }
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
    let rustc_ryo = root.join("dist").join("bin").join(exe_name("rustc-ryo"));
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
    let wants_std = sel.full || sel.std || (sel.fast && FAST.iter().any(|(_, vs)| vs.iter().any(|v| v.starts_with("ryo-std"))));
    if wants_std && let Err(why) = ryo_sysroot_usable(&root) {
        if sel.full || opts.only == Some(Area::Std) || opts.variants.iter().any(|v| v.starts_with("ryo-std")) {
            return Err(format!("the ryo-std variants can't run: {why}"));
        }
        eprintln!("[y] WARNING: the ryo-std variants are SKIPPED: {why}");
        variants.retain(|v| !v.ryo_std);
    }
    variants.retain(|v| opts.variants.is_empty() || opts.variants.iter().any(|n| n == v.name));
    let corpus_only = !opts.programs.is_empty() || !opts.variants.is_empty();

    let out = root.join("target").join("tests");
    fs::create_dir_all(&out).map_err(|e| format!("creating {}: {e}", out.display()))?;
    let ctx = Ctx { tests: root.join("tests"), out: out.clone(), rustc_ryo: rustc_ryo.clone(), rustc_clif: crate::clif::rustc_clif(&root) };
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
    let cc = have_cc();
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
            ("rt-core-only", Box::new(|| rt_core_only(&root))),
            ("jit-sealed", Box::new(|| jit_sealed(&root, &out))),
            ("jit-private-std", Box::new(|| jit_private_std(&rustc_ryo, &root.join("tests").join("vm_jit_private.rs"), &out))),
            ("reject-randomize-layout", Box::new(|| reject_randomize_layout(&rustc_ryo, &hello, &out))),
            ("reject-codegen-units", Box::new(|| reject_codegen_units(&rustc_ryo, &hello, &out))),
            ("reject-incremental", Box::new(|| reject_incremental(&rustc_ryo, &hello, &out))),
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
    fn compare(&self, reference: &RunResult) -> Result<(), String> {
        if self == reference {
            return Ok(());
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
            let names: Vec<&str> = vm_fns.iter().map(String::as_str).collect();
            let missing: Vec<_> = program.vm.iter().filter(|f| !names.contains(f)).collect();
            if !variant.vm_only && !missing.is_empty() {
                return Err(format!("not compiled to bytecode: {missing:?}; VM functions: {names:?}"));
            }
        }
        Ok(result)
    }

    /// Compiles and links the C program `c_main` against `lib` (a staticlib or cdylib in `dir`),
    /// with `cc`, or `cl` on MSVC hosts.
    fn link_c(&self, dir: &Path, c_main: &str, lib: &Crate, native_libs: &[String]) -> Result<PathBuf, String> {
        let exe = dir.join(exe_name("c_main"));
        let mut c = Command::new(C_COMPILER);
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
        let lib_path_var = if cfg!(windows) { "PATH" } else { "LD_LIBRARY_PATH" };
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
    fn normalizes_thread_ids() {
        let s = "x\nthread 'main' (1234) panicked at a.rs:1:2:\nthread 'a' (b) c\n";
        let want = "x\nthread 'main' (N) panicked at a.rs:1:2:\nthread 'a' (b) c\n";
        assert_eq!(super::normalize_thread_ids(s), want);
    }
}

/// `cargo-ryo run` on a one-file package wrapping `tests/hello.rs`.
fn cargo_smoke(root: &Path, out: &Path) -> Result<(), String> {
    let pkg = out.join("cargo-hello");
    fs::create_dir_all(&pkg).map_err(|e| format!("creating {}: {e}", pkg.display()))?;
    let manifest = format!(
        "[package]\nname = \"cargo-hello\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n\
         [[bin]]\nname = \"hello\"\npath = {:?}\n\n[workspace]\n",
        root.join("tests").join("hello.rs").to_str().ok_or("non-UTF-8 path")?,
    );
    fs::write(pkg.join("Cargo.toml"), manifest).map_err(|e| e.to_string())?;
    let cargo_ryo = root.join("dist").join("bin").join(exe_name("cargo-ryo"));
    let res = cmd(cargo_ryo)
        .args(["run", "--quiet", "--offline"])
        .current_dir(&pkg)
        .env("RYO_BACKEND_MARKER", "1")
        // Force a rebuild, so the marker is printed. The dev profile turns on incremental
        // compilation, which `cargo-ryo` must turn off again.
        .env("CARGO_TARGET_DIR", pkg.join("target"))
        .env_remove("CARGO_INCREMENTAL")
        .output()
        .map_err(|e| e.to_string())?;
    let _ = fs::remove_dir_all(pkg.join("target"));
    let stdout = String::from_utf8_lossy(&res.stdout);
    let stderr = String::from_utf8_lossy(&res.stderr);
    if !res.status.success() || stdout != "Hello, world!\n" || !stderr.contains(BACKEND_MARKER) || !stderr.contains(PARTITION_MARKER) {
        return Err(format!("{}\nstdout:\n{stdout}\nstderr:\n{stderr}", res.status));
    }
    Ok(())
}

/// `RUST_BACKTRACE=1` through VM frames: a panic two VM calls deep, caught by
/// `catch_unwind`, prints a backtrace naming the VM functions (by their symbols) and the
/// native frames around them, and the cleanup and the catch still run.
fn backtrace(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let exe = out.join(exe_name("vm_backtrace"));
    crate::utils::run(cmd(rustc_ryo).arg("--edition=2024").arg(src).arg("-o").arg(&exe))?;
    // Without the JIT, whose code has no symbols (and with `RYO_JIT_THRESHOLD=0` would run
    // every frame).
    let res = Command::new(&exe).env("RUST_BACKTRACE", "1").env("RYO_JIT", "off").output().map_err(|e| e.to_string())?;
    let stdout = String::from_utf8_lossy(&res.stdout);
    let stderr = String::from_utf8_lossy(&res.stderr);
    let want = ["vm_backtrace::inner", "vm_backtrace::outer", "__rust_try", "vm_backtrace::main"];
    let missing: Vec<_> = want.iter().filter(|w| !stderr.contains(*w)).collect();
    if !res.status.success() || stdout != "guard dropped\ncaught: true\n" || !missing.is_empty() {
        return Err(format!("{}, missing frames {missing:?}\nstdout:\n{stdout}stderr:\n{stderr}", res.status));
    }
    Ok(())
}

/// Printed by the backend's `init` when `RYO_BACKEND_MARKER` is set.
const BACKEND_MARKER: &str = "ryo backend: init";

/// Printed by the backend's `collect_and_partition_mono_items` override when
/// `RYO_BACKEND_MARKER` is set: the override, not cg_llvm's default, partitioned the crate.
const PARTITION_MARKER: &str = "ryo backend: partition";

/// The functions a `RYO_STATS=1` build reports as compiled to bytecode:
/// `ryo: vm fn <path>[ (global)]`.
fn vm_functions(stderr: &str) -> Vec<String> {
    stderr.lines().filter_map(|l| l.strip_prefix("ryo: vm fn ")).map(|f| f.strip_suffix(" (global)").unwrap_or(f).to_owned()).collect()
}

/// Whether the host is windows-msvc: C programs are built with `cl`, and the staticlib and
/// the cdylib's import library are `<name>.lib` and `<name>.dll.lib`.
const MSVC: bool = cfg!(target_env = "msvc");

/// The C compiler for the [`Program::c_main`] programs.
const C_COMPILER: &str = if MSVC { "cl" } else { "cc" };

/// Whether [`C_COMPILER`] is available (`cl` is only on `PATH` in a Visual Studio developer
/// environment).
fn have_cc() -> bool {
    if MSVC {
        // `cl` without arguments prints its banner; starting at all is enough.
        return Command::new("cl").output().is_ok();
    }
    Command::new("cc").arg("--version").output().is_ok_and(|o| o.status.success())
}

/// Incremental compilation is a non-goal; the backend rejects it (design/README.md).
fn reject_incremental(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let res = cmd(rustc_ryo)
        .arg(src)
        .arg(format!("-Cincremental={}", out.join("incr").display()))
        .arg("-o")
        .arg(out.join(exe_name("incremental")))
        .output()
        .map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if res.status.success() || !stderr.contains("incremental compilation") {
        return Err(format!("expected rustc-ryo to reject -Cincremental; stderr:\n{stderr}"));
    }
    Ok(())
}

/// The dynamic symbols a ryo Rust dylib, cdylib, and an executable with `-Zexport-executable-symbols`,
/// export are exactly plain rustc's (plus the runtime's own), with and without
/// `-Clto`: the image's symbols are listed
/// as exports for LTO, and `link` must remove those, and only those
/// (design/backend.md#query-overrides). ELF only (`llvm-nm -D`).
fn same_exports(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if cfg!(windows) {
        return Ok(());
    }
    let info = crate::utils::RustcInfo::get()?;
    let nm = info.sysroot.join("lib").join("rustlib").join(&info.host).join("bin").join("llvm-nm");
    let dir = out.join("exports");
    fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
    let cases: [(&str, &[&str]); 5] = [
        ("dylib", &["--crate-type=dylib", "-Cprefer-dynamic"]),
        ("cdylib", &["--crate-type=cdylib"]),
        ("cdylib-lto", &["--crate-type=cdylib", "-Clto=fat"]),
        ("exe", &["--crate-type=bin", "-Zexport-executable-symbols"]),
        ("exe-lto", &["--crate-type=bin", "-Zexport-executable-symbols", "-Clto=fat"]),
    ];
    for (name, flags) in cases {
        let mut lists = Vec::new();
        for (who, compiler) in [("rustc", Path::new("rustc")), ("ryo", rustc_ryo)] {
            let o = dir.join(format!("{name}-{who}"));
            crate::utils::run(cmd(compiler).arg("--edition=2024").arg(src).args(flags).arg("-o").arg(&o))?;
            let syms = output(cmd(&nm).args(["-D", "--defined-only", "-j"]).arg(&o))?;
            // The runtime's own symbols, which every ryo output links: `ryo_vm_register`
            // (C level), and in a Rust dylib everything of `ryo_rt` and `ryo_bytecode`,
            // the handlers included.
            let runtime = |s: &str| s == "ryo_vm_register" || s.contains("6ryo_rt") || s.contains("12ryo_bytecode") || is_rt_internal(s);
            let mut syms: Vec<String> = syms.lines().filter(|s| !runtime(s)).map(str::to_owned).collect();
            syms.sort();
            lists.push(syms);
        }
        if lists[0] != lists[1] {
            return Err(format!("{name}: rustc exports {:?}, ryo exports {:?}", lists[0], lists[1]));
        }
    }
    Ok(())
}

/// Whether `s` is one of `ryo_rt`'s own `#[rustc_std_internal_symbol]`s (mangled under the
/// `__rustc` root): the handlers `ryo_h_*`, `ryo_probe_stack` and the JIT's trip entry points
/// `ryo_jit_trip_*`.
fn is_rt_internal(s: &str) -> bool {
    s.starts_with("_R") && s.contains("7___rustc") && (s.contains("ryo_h_") || s.ends_with("15ryo_probe_stack") || s.contains("ryo_jit_trip_"))
}

/// v0 crate roots (`C<disambiguator>_<len><name>`) `ryo_rt` may use.
const CRATES: [&str; 4] = ["4core", "17compiler_builtins", "12ryo_bytecode", "6ryo_rt"];

/// Whether `s` is a Rust symbol of a crate outside [`CRATES`] (std's), or std's allocator
/// shim (`__rust_*`, `__rdl_*`, `__rg_*`).
fn outside(s: &str) -> bool {
    if s.starts_with("__rust") || s.starts_with("__rdl") || s.starts_with("__rg_") {
        return true;
    }
    s.starts_with("_R") && !is_rt_internal(s) && crate_roots(s).iter().any(|c| !CRATES.contains(&c.as_str()))
}

/// `ryo_rt` must use only `core`, its own crates, libc, and the panic runtime's two entry
/// points (native: a panic runtime is never VM code): with `--sysroot ryo`, std's allocator,
/// locks and TLS may be VM functions, which the runtime must not call while it switches VM
/// state (design/vm.md, "No re-entry into the VM from the runtime"). Checked on the undefined
/// symbols of every sysroot's `ryo_rt` rlib, by crate in their v0 mangled names. ELF only.
/// The JIT's trips are part of it; the JIT thread, which uses std, is the sealed object that
/// the rlib bundles (design/jit.md#packaging), which `ryo_rt` reaches only through `ryo_jit_start`
/// and `jit-sealed` checks: this check skips it.
fn rt_core_only(root: &Path) -> Result<(), String> {
    if cfg!(windows) {
        return Ok(());
    }
    let info = crate::utils::RustcInfo::get()?;
    let nm = info.sysroot.join("lib").join("rustlib").join(&info.host).join("bin").join("llvm-nm");
    let dist = root.join("dist");
    let mut libs = Vec::new();
    for sysroot in [dist.clone(), dist.join(crate::sysroot::SYSROOT_DIR)] {
        let dir = sysroot.join("lib").join("rustlib").join(&info.host).join("lib");
        let Ok(entries) = fs::read_dir(&dir) else { continue };
        for e in entries.flatten() {
            let name = e.file_name().to_string_lossy().into_owned();
            if name.starts_with("libryo_rt") && name.ends_with(".rlib") {
                libs.push(e.path());
            }
        }
    }
    if libs.is_empty() {
        return Err("no ryo_rt rlib in dist/".to_owned());
    }
    const PANIC_RUNTIME: [&str; 3] = ["18___rust_start_panic", "20___rust_panic_cleanup", "rust_eh_personality"];
    for lib in libs {
        let syms = output(cmd(&nm).args(["-u", "--no-demangle", "-j"]).arg(&lib))?;
        // Per member, after a `<member>:` line.
        let mut in_jit = false;
        let bad: Vec<&str> = syms
            .lines()
            .map(str::trim)
            .filter(|s| {
                if let Some(member) = s.strip_suffix(':') {
                    in_jit = member == crate::jit::OBJECT;
                }
                !s.is_empty() && !s.ends_with(':') && !in_jit
            })
            .filter(|s| !PANIC_RUNTIME.iter().any(|p| s.ends_with(p)))
            // Rust symbols must name only allowed crates, and no allocator shim (std's).
            .filter(|s| outside(s))
            .collect();
        if !bad.is_empty() {
            return Err(format!("{} uses symbols outside core: {bad:?}", lib.display()));
        }
        let objdump = nm.with_file_name("llvm-objdump");
        let dir = lib.parent().unwrap();
        let bytecode = fs::read_dir(dir)
            .map_err(|e| e.to_string())?
            .flatten()
            .map(|e| e.path())
            .find(|p| {
                let n = p.file_name().unwrap_or_default().to_string_lossy();
                n.starts_with("libryo_bytecode") && n.ends_with(".rlib")
            })
            .ok_or_else(|| format!("no ryo_bytecode rlib in {}", dir.display()))?;
        if let Some(path) = panic_path(&objdump, &lib, &bytecode)? {
            return Err(format!("{} reaches core's panic path: {}", lib.display(), path.join(" <- ")));
        }
    }
    Ok(())
}

/// The sealed JIT that the native sysroot's `ryo_rt` bundles keeps its std to itself
/// ([`crate::jit::check_sealed`]). Hosts with the JIT only; `test --cross` checks a cross
/// target's.
fn jit_sealed(root: &Path, out: &Path) -> Result<(), String> {
    let info = crate::utils::RustcInfo::get()?;
    if !crate::jit::supported(&info.host) {
        return Ok(());
    }
    let lib = root.join("dist").join("lib").join("rustlib").join(&info.host).join("lib").join("libryo_rt.rlib");
    crate::jit::check_sealed(&info, &lib, &out.join("jit-sealed"), &info.host)
}

/// The JIT's std is its own (design/jit.md#packaging), so the program's can't get in its way:
/// `tests/vm_jit_private.rs`, with every function compiled at its first call and waited for,
/// has a VM global allocator that trips while it holds its lock (the JIT would deadlock
/// allocating through it), and built with `-Cpanic=abort` and run with `RYO_JIT_TEST_PANIC`
/// it must still run as without the JIT: every compile panics, which fails the function
/// instead of aborting. Hosts with the JIT only.
fn jit_private_std(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if !crate::jit::supported(&crate::utils::RustcInfo::get()?.host) {
        return Ok(());
    }
    let want = "sum 499500 words w0,w97,w194,w291,w388,w485,w582,w679,w776,w873,w970\n";
    let sync = [("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1")];
    let cases: [(&str, &[&str], &[(&str, &str)]); 2] =
        [("jit_private", &[], &[]), ("jit_private_abort", &["-Cpanic=abort"], &[("RYO_JIT_TEST_PANIC", "1"), ("RYO_JIT_LOG", "1")])];
    for (name, flags, env) in cases {
        let exe = out.join(exe_name(name));
        crate::utils::run(cmd(rustc_ryo).arg("--edition=2024").arg(src).args(flags).arg("-o").arg(&exe))?;
        // Into files, which never block the program as a full pipe would.
        let (out_file, err_file) = (out.join(format!("{name}.stdout")), out.join(format!("{name}.stderr")));
        let file = |p: &Path| fs::File::create(p).map_err(|e| format!("{}: {e}", p.display()));
        let mut child = Command::new(&exe)
            .envs(sync)
            .envs(env.iter().copied())
            .stdout(file(&out_file)?)
            .stderr(file(&err_file)?)
            .spawn()
            .map_err(|e| e.to_string())?;
        // A deadlock shows as a hang.
        let deadline = std::time::Instant::now() + std::time::Duration::from_secs(60);
        while child.try_wait().map_err(|e| e.to_string())?.is_none() {
            if std::time::Instant::now() > deadline {
                let _ = child.kill();
                return Err(format!("{name}: no exit within 60 s (deadlock?)"));
            }
            std::thread::sleep(std::time::Duration::from_millis(50));
        }
        let status = child.wait().map_err(|e| e.to_string())?;
        let stdout = fs::read_to_string(&out_file).unwrap_or_default();
        let stderr = fs::read_to_string(&err_file).unwrap_or_default();
        let panicked = !env.is_empty();
        if !status.success() || stdout != want || (panicked && !stderr.contains("RYO_JIT_TEST_PANIC")) {
            return Err(format!("{name}: {status}\nstdout:\n{stdout}stderr:\n{}", stderr.lines().take(20).collect::<Vec<_>>().join("\n")));
        }
    }
    Ok(())
}

/// A call path from `ryo_rt`'s own code to core's panic machinery, through `ryo_bytecode`, if
/// there is one. Under `--sysroot ryo` the panic handler is std's (VM code), so a panic in the
/// runtime would enter the VM while it switches state. Everything `ryo_rt`'s rlib defines
/// counts as runtime: the templates are generic and instantiated in the program's crates,
/// which may panic like any program code. The edges are the relocations in each function
/// (`llvm-objdump -dr`), which cover calls and taken addresses.
fn panic_path(objdump: &Path, rt: &Path, bytecode: &Path) -> Result<Option<Vec<String>>, String> {
    use std::collections::HashMap;
    let mut edges: HashMap<String, Vec<String>> = HashMap::new();
    let mut roots = Vec::new();
    for (lib, is_rt) in [(rt, true), (bytecode, false)] {
        let dis = output(cmd(objdump).args(["-dr", "--no-show-raw-insn"]).arg(lib))?;
        let mut cur: Option<String> = None;
        // In the sealed JIT, after a `<lib>(<member>):  file format …` line.
        let mut in_jit = false;
        for line in dis.lines() {
            if line.contains(":\tfile format ") || line.contains(": file format ") {
                in_jit = line.contains(&format!("({}):", crate::jit::OBJECT));
                cur = None;
                continue;
            }
            if in_jit {
                continue;
            }
            if let Some((_, name)) = line.strip_suffix(">:").and_then(|l| l.split_once(" <")) {
                let name = name.to_owned();
                if is_rt {
                    roots.push(name.clone());
                }
                edges.entry(name.clone()).or_default();
                cur = Some(name);
            } else if let (Some(f), Some(i)) = (&cur, line.find("R_X86_64_")) {
                let target = line[i..].split_whitespace().nth(1).unwrap_or("");
                let target = target.split(['+', '-']).next().unwrap_or("").to_owned();
                edges.entry(f.clone()).or_default().push(target);
            }
        }
    }
    // core's panic entry points: `core::panicking::*`, and the `#[cold]` `*_fail`/`*_failed`
    // helpers (slice indexing, `unwrap`, sort's `panic_on_ord_violation`).
    let panics = |s: &str| {
        crate_roots(s).first().is_some_and(|c| c == "4core")
            && (s.contains("9panicking") || s.contains("_fail") || s.contains("panic_on_ord_violation"))
    };
    let mut from: HashMap<String, Option<String>> = HashMap::new();
    let mut stack: Vec<(String, Option<String>)> = roots.into_iter().map(|r| (r, None)).collect();
    while let Some((f, parent)) = stack.pop() {
        if from.contains_key(&f) {
            continue;
        }
        from.insert(f.clone(), parent);
        if panics(&f) {
            let mut path = vec![f.clone()];
            while let Some(Some(p)) = from.get(path.last().unwrap()) {
                path.push(p.clone());
            }
            return Ok(Some(path));
        }
        for c in edges.get(&f).into_iter().flatten() {
            stack.push((c.clone(), Some(f.clone())));
        }
    }
    Ok(None)
}

/// The crate roots (`<len><name>` after `Cs<disambiguator>_`) in a v0 symbol.
fn crate_roots(sym: &str) -> Vec<String> {
    let b = sym.as_bytes();
    let mut out = Vec::new();
    let mut i = 0;
    while i < b.len() {
        if b[i] == b'C' && b.get(i + 1) == Some(&b's') {
            let mut j = i + 2;
            while j < b.len() && b[j].is_ascii_alphanumeric() {
                j += 1;
            }
            if b.get(j) != Some(&b'_') {
                i += 1;
                continue;
            }
            j += 1;
            let start = j;
            while j < b.len() && b[j].is_ascii_digit() {
                j += 1;
            }
            if j > start
                && let Ok(n) = sym[start..j].parse::<usize>()
                && j + n <= b.len()
            {
                out.push(sym[start..j + n].to_owned());
                i = j + n;
                continue;
            }
        }
        i += 1;
    }
    out
}

/// `--emit=metadata` must not run the partitioning (no codegen, so no image).
fn metadata_only(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let res = cmd(rustc_ryo)
        .arg(src)
        .args(["--crate-type=rlib", "--emit=metadata", "--crate-name=meta_only"])
        .arg("--out-dir")
        .arg(out)
        .env("RYO_BACKEND_MARKER", "1")
        .output()
        .map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if !res.status.success() || stderr.contains(PARTITION_MARKER) {
        return Err(format!("expected a metadata-only build without partitioning; stderr:\n{stderr}"));
    }
    Ok(())
}

/// `RYO_DUMP` of a program whose VM code names statics must build cleanly: printing a path
/// with trimmed paths outside a diagnostic made rustc panic as the session ended.
fn dump(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let dump = out.join("dump.txt");
    let res = cmd(rustc_ryo)
        .args(["--edition=2024", "-O"])
        .arg(src)
        .arg("-o")
        .arg(out.join(exe_name("dump")))
        .env("RYO_DUMP", &dump)
        .output()
        .map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if !res.status.success() {
        return Err(format!("RYO_DUMP build failed; stderr:\n{stderr}"));
    }
    let text = fs::read_to_string(&dump).map_err(|e| format!("reading {}: {e}", dump.display()))?;
    if !text.contains(" = static ") {
        return Err(format!("{} names no static", dump.display()));
    }
    Ok(())
}

fn reject_randomize_layout(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let res =
        cmd(rustc_ryo).arg(src).arg("-Zrandomize-layout").arg("-o").arg(out.join(exe_name("randomized"))).output().map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if res.status.success() || !stderr.contains("-Zrandomize-layout") {
        return Err(format!("expected rustc-ryo to reject -Zrandomize-layout; stderr:\n{stderr}"));
    }
    Ok(())
}

/// The backend itself rejects more than one codegen unit (design/backend.md#pipeline). `rustc-ryo`
/// always appends `-Ccodegen-units=1`, so this runs plain rustc with the backend.
fn reject_codegen_units(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let dist = rustc_ryo.parent().and_then(Path::parent).ok_or("bad dist path")?;
    let mut backend = OsString::from("-Zcodegen-backend=");
    backend.push(dist.join("lib").join(dll_name("rustc_codegen_ryo")));
    let res =
        cmd("rustc").arg(backend).arg(src).arg("-Ccodegen-units=4").arg("-o").arg(out.join(exe_name("cgu4"))).output().map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if res.status.success() || !stderr.contains("-Ccodegen-units=1") {
        return Err(format!("expected the backend to reject 4 codegen units; stderr:\n{stderr}"));
    }
    Ok(())
}
