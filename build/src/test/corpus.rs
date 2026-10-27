//! The test corpus: the programs under `tests/` and how to build them.

use std::path::Path;
use std::process::Command;

use crate::utils::{cmd, root};

/// A test program: one or more crates under `tests/`, built in order. The binary crate runs,
/// or, for [`Program::c_main`], a C program linked against its staticlib and cdylib crates.
pub(crate) struct Program {
    pub(crate) name: &'static str,
    pub(crate) crates: &'static [Crate],
    /// Extra flags for every crate.
    pub(crate) flags: &'static [&'static str],
    /// Functions the ryo build must compile to bytecode (as `RYO_STATS` prints them).
    pub(super) vm: &'static [&'static str],
    /// Functions the ryo build must not compile to bytecode.
    pub(super) native: &'static [&'static str],
    /// A C `main` (relative to `tests/`), compiled with `cc` (`cl` on MSVC) and linked against
    /// the staticlib and cdylib crates, in order, or a C++ one (`.cpp`), compiled with `c++`
    /// (`cl /EHs`). Skipped without that compiler, but a failure on windows-msvc hosts.
    pub(super) c_main: Option<&'static str>,
    /// Built and run on windows-msvc hosts only (a C `main` using SEH).
    pub(super) msvc_only: bool,
    /// Unwinds a foreign exception (C++, SEH) through Rust frames: not built with
    /// `-Cpanic=abort`, where the unwind enters Rust-ABI calls that can't unwind (undefined
    /// behavior: LLVM's functions without landing pads let it pass, VM functions abort).
    pub(super) foreign_unwind: bool,
    /// A static library the crates link (`#[link(kind = "static")]`), built before them.
    pub native_lib: Option<NativeLib>,
}

impl Program {
    /// Whether the binary links a Rust dylib (LTO doesn't support that). A crate that is both
    /// an rlib and a dylib is linked as the rlib.
    pub(crate) fn has_dylib(&self) -> bool {
        self.flags.contains(&"-Cprefer-dynamic") || self.crates.iter().any(|c| c.kind == CrateKind::Dylib)
    }

    /// Checks the functions the ryo build compiled to bytecode (`vm_fns`, as `RYO_STATS` prints
    /// them): every one of [`Program::vm`] (unless not `all_vm`), and none of
    /// [`Program::native`].
    pub(crate) fn check_vm(&self, vm_fns: &[String], all_vm: bool) -> Result<(), String> {
        let names: Vec<&str> = vm_fns.iter().map(String::as_str).collect();
        let missing: Vec<_> = self.vm.iter().filter(|f| !names.contains(f)).collect();
        if all_vm && !missing.is_empty() {
            return Err(format!("not compiled to bytecode: {missing:?}; VM functions: {names:?}"));
        }
        let wrong: Vec<_> = self.native.iter().filter(|f| names.contains(f)).collect();
        if !wrong.is_empty() {
            return Err(format!("compiled to bytecode, but must stay native: {wrong:?}"));
        }
        Ok(())
    }

    /// Compiles each crate, in order, from `tests` into `dir` with `compiler()`: the common
    /// flags, then `extra(krate, cmd)`'s, then `final_flags` on the last crate. Every library
    /// crate is an `--extern` of the crates after it. Returns each crate's stderr.
    pub(crate) fn compile(
        &self,
        tests: &Path,
        dir: &Path,
        compiler: impl Fn() -> Command,
        extra: impl Fn(&Crate, &mut Command),
        final_flags: &[&str],
    ) -> Result<Vec<(&'static Crate, String)>, String> {
        let mut stderrs = Vec::new();
        for (i, krate) in self.crates.iter().enumerate() {
            let mut c = compiler();
            c.arg("--edition=2024")
                .arg(tests.join(krate.src))
                .args(krate.kind.flags())
                .args(["--crate-name", krate.name])
                .arg("--out-dir")
                .arg(dir)
                .arg("-L")
                .arg(dir)
                .args(self.flags);
            extra(krate, &mut c);
            if i + 1 == self.crates.len() {
                c.args(final_flags);
            }
            for dep in &self.crates[..i] {
                if !matches!(dep.kind, CrateKind::Bin | CrateKind::Staticlib | CrateKind::Cdylib) {
                    c.args(["--extern", dep.name]);
                }
            }
            stderrs.push((krate, crate::utils::capture_ok(&mut c)?.stderr));
        }
        Ok(stderrs)
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
    pub fn build(&self, info: &crate::utils::RustcInfo, dir: &Path, target: Option<&str>) -> Result<(), String> {
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
        let ar = info.tool("llvm-ar");
        crate::utils::run(cmd(ar).arg("rcs").arg(dir.join(lib)).arg(&obj))
    }
}

/// Defaults for [`Program`] fields.
pub(super) const PROGRAM: Program =
    Program { name: "", crates: &[], flags: &[], vm: &[], native: &[], c_main: None, msvc_only: false, foreign_unwind: false, native_lib: None };

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

pub(super) const fn krate(name: &'static str, src: &'static str, kind: CrateKind) -> Crate {
    Crate { name, src, kind }
}

/// A one-file binary program `tests/<name>.rs`.
macro_rules! single {
    ($name:literal) => {
        Program { name: $name, crates: &[krate($name, concat!($name, ".rs"), CrateKind::Bin)], ..PROGRAM }
    };
    ($name:literal, $($field:ident: $value:expr),+ $(,)?) => {
        Program { name: $name, crates: &[krate($name, concat!($name, ".rs"), CrateKind::Bin)], $($field: $value,)+ ..PROGRAM }
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
        vm: &["main", "answer", "pick", "twice", "wide", "always"],
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
        vm: &["main", "ops32", "ops_u8", "wide", "casts", "float_casts", "floats", "checked", "chars", "bits", "neg", "cmp"],
    ),
    single!(
        "vm_control",
        vm: &["main", "collatz", "dense", "sparse", "area", "discr", "niches", "make", "labeled", "switch128", "mid", "mid_index"],
    ),
    single!("vm_cgu", vm: &["main", "even::is_even", "odd::is_odd", "leaf::add", "leaf::twice", "<shapes::Square as shapes::Shape>::area", "table::mul"]),
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
        vm: &["main", "atomics", "atomic_ptrs", "unwinding", "misc", "dst", "direct", "contention"],
    ),
    single!(
        "vm_lowerings",
        vm: &["main", "pressure", "bump", "remat", "leaf_args", "leaf_heavy", "offsets", "forms", "fixed_regs", "wide", "known_zero", "by_one", "small_div", "rotates", "copies"]
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
            "f128s::vm_to_native", "wide_split::vm", "wide_split::vm_to_native", "floats_late::vm", "floats_late::vm_to_native",
        ],
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
        vm: &["main", "tail", "nested", "rcs", "coerce_ref", "coerce_pin", "coerce_tail", "repeat", "wide_cmp", "arith128", "ovf128", "half", "scopes", "half_size", "borrow_loop", "unwind_live", "relive", "packed", "min128"],
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
    // SIMD: the `simd_*` intrinsics with an instruction (`lower/simd.rs`) and the SSE2
    // `_mm_*` functions, hashbrown, `is_ascii` and `str::contains` built on them.
    // `#[target_feature]` functions are VM code if the crate enables their features and their
    // bodies map.
    Program {
        name: "vm_simd",
        crates: &[krate("vm_simd", "vm_simd.rs", CrateKind::Bin)],
        vm: &[
            "main",
            "sse2_fns",
            "direct",
            "live_across",
            "probe",
            "core::core_arch::simd::Simd::<i8, 16>::splat",
            "std::simd::Simd::<u8, 16>::splat",
            "std::arch::x86_64::_mm_cmpeq_epi8",
            "std::arch::x86_64::_mm_movemask_epi8",
            "std::arch::x86_64::_mm_set1_epi8",
            "std::arch::x86_64::_mm_loadu_si128",
            "std::arch::x86_64::_mm_cmpgt_epi8",
            "std::arch::x86_64::_mm_or_si128",
            "std::arch::x86_64::_mm_setzero_si128",
            "sse2_mapped",
            "sse2_plain",
            "find_sse2",
            "find",
        ],
        native: &["std::arch::x86_64::_mm_shuffle_epi32::<27>", "sse2_shuffle", "sse2_llvm", "sse2_asm", "avx2_sum", "find_avx2"],
        ..PROGRAM
    },
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
    // Two ryo staticlibs in one C program: each brings a registry stub defining the (weak)
    // anchor, and one stub registers both images (with the JIT on, each image's function is
    // compiled).
    Program {
        name: "vm_staticlib2",
        crates: &[krate("vma", "vm_c2/a.rs", CrateKind::Staticlib), krate("vmb", "vm_c2/b.rs", CrateKind::Staticlib)],
        vm: &["answer_a", "answer_b"],
        c_main: Some("vm_c2/main.c"),
        ..PROGRAM
    },
    Program { name: "vm_cdylib", crates: &[krate("vmc", "vm_c/lib.rs", CrateKind::Cdylib)], vm: &["answer"], c_main: Some("vm_c/main.c"), ..PROGRAM },
    // Unwinding through VM frames (design/vm.md#unwinding): chains of VM and native frames
    // into `catch_unwind`, a panic in a drop during unwinding, a panic nothing catches.
    single!(
        "vm_unwind_chain",
        vm: &["main", "vm1", "vm2", "vm3", "consume", "check", "step", "vm_loop", "vm_resume", "<G as std::ops::Drop>::drop"],
        native: &["native1", "native2", "native_resume"],
    ),
    single!("vm_double_panic", vm: &["main", "deep", "top", "<Bomb as std::ops::Drop>::drop"], native: &["native_mid"]),
    single!("vm_uncaught", vm: &["main", "raise", "vm_entry", "run"]),
    // C++ exceptions through VM frames: to a C++ catch, into a function that can't unwind,
    // and through a drop that panics.
    Program {
        name: "vm_cxx",
        crates: &[krate("vcx", "vm_cxx/lib.rs", CrateKind::Staticlib)],
        vm: &["outer", "mid", "step", "with_catcher", "<Catcher as std::ops::Drop>::drop"],
        native: &["native"],
        c_main: Some("vm_cxx/through.cpp"),
        foreign_unwind: true,
        ..PROGRAM
    },
    Program {
        name: "vm_cxx_terminate",
        crates: &[krate("vcx", "vm_cxx/lib.rs", CrateKind::Staticlib)],
        vm: &["nounwind", "mid"],
        c_main: Some("vm_cxx/terminate.cpp"),
        foreign_unwind: true,
        ..PROGRAM
    },
    Program {
        name: "vm_cxx_nested_panic",
        crates: &[krate("vcx", "vm_cxx/lib.rs", CrateKind::Staticlib)],
        vm: &["with_bomb", "mid", "<Bomb as std::ops::Drop>::drop"],
        c_main: Some("vm_cxx/nested.cpp"),
        foreign_unwind: true,
        ..PROGRAM
    },
    // SEH exceptions and `longjmp` through VM frames from C.
    Program {
        name: "vm_seh_av",
        crates: &[krate("vse", "vm_seh/lib.rs", CrateKind::Staticlib)],
        vm: &["guarded", "inner"],
        c_main: Some("vm_seh/av.c"),
        foreign_unwind: true,
        msvc_only: true,
        ..PROGRAM
    },
    Program {
        name: "vm_longjmp",
        crates: &[krate("vse", "vm_seh/lib.rs", CrateKind::Staticlib)],
        vm: &["plain", "plain_inner"],
        c_main: Some("vm_seh/longjmp.c"),
        ..PROGRAM
    },
];
