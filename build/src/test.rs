//! `y test` (design/build.md#test-and-bench): the test corpus, diffed against plain rustc, and
//! the smoke tests of `dist/`.

use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::utils::{cmd, describe, dll_name, exe_name, output, root};

/// A test program: one or more crates under `tests/`, built in order. The binary crate runs,
/// or, for [`Program::c_main`], a C program linked against the last crate.
struct Program {
    name: &'static str,
    crates: &'static [Crate],
    /// Extra flags for every crate.
    flags: &'static [&'static str],
    /// Functions the ryo build must compile to bytecode (as `RYO_STATS` prints them).
    vm: &'static [&'static str],
    /// Functions that must be entered through `vm::enter` (portals), checked by running the
    /// ryo build again with `RYO_VM_TRACE` and mapping the reported IDs to the `RYO_STATS` names.
    entered: &'static [&'static str],
    /// A C `main` (relative to `tests/`), compiled with `cc` and linked against the last crate
    /// (a staticlib or cdylib). Skipped if there is no `cc`.
    c_main: Option<&'static str>,
}

/// Defaults for [`Program`] fields.
const PROGRAM: Program = Program { name: "", crates: &[], flags: &[], vm: &[], entered: &[], c_main: None };

struct Crate {
    /// The crate name, passed as `--crate-name`.
    name: &'static str,
    /// Source path, relative to `tests/`.
    src: &'static str,
    kind: CrateKind,
}

#[derive(Clone, Copy, PartialEq)]
enum CrateKind {
    Bin,
    Rlib,
    Dylib,
    /// Both an rlib and a dylib from one compilation (one link per crate type in the backend).
    RlibDylib,
    Staticlib,
    Cdylib,
}

impl CrateKind {
    fn flags(self) -> &'static [&'static str] {
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
    ($name:literal, vm: $vm:expr, entered: $entered:expr) => {
        Program {
            name: $name,
            crates: &[krate($name, concat!($name, ".rs"), CrateKind::Bin)],
            vm: $vm,
            entered: $entered,
            ..PROGRAM
        }
    };
}

/// Programs built with plain rustc and with every [`Variant`]; their outputs must match.
const CORPUS: &[Program] = &[
    single!("hello"),
    single!("arith"),
    single!("structs_enums"),
    single!("generics_traits"),
    single!("closures_iters"),
    single!("collections"),
    single!("panics"),
    single!("exit_code"),
    Program {
        name: "cross_crate",
        crates: &[
            krate("ccl", "cross_crate/lib.rs", CrateKind::Rlib),
            krate("main", "cross_crate/main.rs", CrateKind::Bin),
        ],
        ..PROGRAM
    },
    Program {
        name: "dylib",
        crates: &[
            krate("rdy", "dylib/lib.rs", CrateKind::Dylib),
            krate("main", "dylib/main.rs", CrateKind::Bin),
        ],
        // Both link std's dylib, so std shows up once.
        flags: &["-Cprefer-dynamic"],
        ..PROGRAM
    },
    // Milestone 3: VM functions behind portals, a VM `main`, and across crates. Local items are
    // printed without their crate name.
    single!(
        "vm_answer",
        vm: &["answer", "pick", "twice", "wide", "always"],
        entered: &["answer", "pick", "twice", "wide", "always"]
    ),
    single!("vm_main", vm: &["main", "answer"], entered: &["main"]),
    single!("vm_refs", vm: &["from_static", "<S as Get>::get", "from_const"], entered: &[
        "from_static",
        "<S as Get>::get",
        "from_const"
    ]),
    Program {
        name: "vm_cross",
        crates: &[
            krate("vml", "vm_cross/lib.rs", CrateKind::Rlib),
            krate("vml2", "vm_cross/lib2.rs", CrateKind::Rlib),
            krate("main", "vm_cross/main.rs", CrateKind::Bin),
        ],
        vm: &["answer", "calls_answer", "generic::<u16>", "vml::always", "vml::generic::<u8>", "vml::inl", "own"],
        entered: &["answer", "calls_answer", "generic::<u16>", "vml::always", "vml::generic::<u8>", "own"],
        ..PROGRAM
    },
    Program {
        name: "vm_dylib",
        crates: &[
            krate("vmd", "vm_dylib/lib.rs", CrateKind::RlibDylib),
            krate("main", "vm_dylib/main.rs", CrateKind::Bin),
        ],
        flags: &["-Cprefer-dynamic"],
        vm: &["answer", "vmd::generic::<i8>", "local"],
        entered: &["answer", "vmd::generic::<i8>", "local"],
        ..PROGRAM
    },
    Program {
        name: "vm_staticlib",
        crates: &[krate("vmc", "vm_c/lib.rs", CrateKind::Staticlib)],
        vm: &["answer"],
        entered: &["answer"],
        c_main: Some("vm_c/main.c"),
        ..PROGRAM
    },
    Program {
        name: "vm_cdylib",
        crates: &[krate("vmc", "vm_c/lib.rs", CrateKind::Cdylib)],
        vm: &["answer"],
        entered: &["answer"],
        c_main: Some("vm_c/main.c"),
        ..PROGRAM
    },
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
    /// Only for programs that list VM functions. Their `vm`/`entered` lists aren't checked
    /// (MIR inlining at `-O` removes some functions), only that tracing changes nothing else.
    vm_only: bool,
}

const REFERENCE: Variant = Variant { name: "rustc", compiler: Compiler::Rustc, flags: &[], vm_only: false };

const VARIANTS: &[Variant] = &[
    Variant { name: "ryo", compiler: Compiler::Ryo, flags: &[], vm_only: false },
    Variant { name: "ryo-threads8", compiler: Compiler::Ryo, flags: &["-Zthreads=8"], vm_only: false },
    Variant { name: "ryo-O3", compiler: Compiler::Ryo, flags: &["-Copt-level=3"], vm_only: true },
];

/// Added by `test --clif`.
const CLIF: Variant = Variant { name: "clif", compiler: Compiler::Clif, flags: &[], vm_only: false };

/// The variants to build: [`VARIANTS`], plus [`CLIF`] for `test --clif`.
fn variants(clif: bool) -> Vec<&'static Variant> {
    VARIANTS.iter().chain(clif.then_some(&CLIF)).collect()
}

/// `vm/`'s own tests run once per VM dispatch strategy (design/vm.md, "Dispatch"): the
/// strategy and the `ryo_rt` feature selecting it. `vm/test-dispatch.sh` runs the same matrix
/// without `dist/`.
const VM_STRATEGIES: [(&str, Option<&str>); 3] =
    [("tail", None), ("loop_match", Some("ryo_rt/dispatch-loop-match")), ("match", Some("ryo_rt/dispatch-match"))];

pub fn run(clif: bool) -> Result<(), String> {
    let root = root();
    let rustc_ryo = root.join("dist").join("bin").join(exe_name("rustc-ryo"));
    if !rustc_ryo.exists() {
        return Err("dist/ is missing; run `./y.sh build` first".to_owned());
    }
    if clif {
        crate::clif::ensure()?;
    }
    let variants = variants(clif);
    let out = root.join("target").join("tests");
    fs::create_dir_all(&out).map_err(|e| format!("creating {}: {e}", out.display()))?;
    let ctx = Ctx {
        tests: root.join("tests"),
        out: out.clone(),
        rustc_ryo: rustc_ryo.clone(),
        rustc_clif: crate::clif::rustc_clif(&root),
    };

    let mut failed = Vec::new();
    for (strategy, feature) in VM_STRATEGIES {
        let name = format!("vm [{strategy}]");
        let mut c = cmd("cargo");
        c.current_dir(root.join("vm")).args(["test", "--workspace"]);
        if let Some(f) = feature {
            c.args(["--features", f]);
        }
        match crate::utils::run(&mut c) {
            Ok(()) => eprintln!("[y] test {name}: ok"),
            Err(msg) => {
                eprintln!("[y] test {name}: FAILED: {msg}");
                failed.push(name);
            }
        }
    }
    let cc = have_cc();
    for program in CORPUS {
        if program.c_main.is_some() && !cc {
            eprintln!("[y] test {}: skipped (no `cc`)", program.name);
            continue;
        }
        let reference = match ctx.build_and_run(program, &REFERENCE) {
            Ok(r) => r,
            Err(msg) => {
                eprintln!("[y] test {}: FAILED with plain rustc: {msg}", program.name);
                failed.push(program.name.to_owned());
                continue;
            }
        };
        for variant in &variants {
            if variant.vm_only && program.vm.is_empty() {
                continue;
            }
            let name = format!("{} [{}]", program.name, variant.name);
            match ctx.build_and_run(program, variant).and_then(|r| r.compare(&reference)) {
                Ok(()) => eprintln!("[y] test {name}: ok"),
                Err(msg) => {
                    eprintln!("[y] test {name}: FAILED: {msg}");
                    failed.push(name);
                }
            }
        }
    }
    let hello = root.join("tests").join("hello.rs");
    let checks: [(&str, Result<(), String>); 4] = [
        ("reject-randomize-layout", reject_randomize_layout(&rustc_ryo, &hello, &out)),
        ("reject-codegen-units", reject_codegen_units(&rustc_ryo, &hello, &out)),
        ("reject-incremental", reject_incremental(&rustc_ryo, &hello, &out)),
        ("cargo-ryo", cargo_smoke(&root, &out)),
    ];
    for (name, res) in checks {
        match res {
            Ok(()) => eprintln!("[y] test {name}: ok"),
            Err(msg) => {
                eprintln!("[y] test {name}: FAILED: {msg}");
                failed.push(name.to_owned());
            }
        }
    }
    if !failed.is_empty() {
        return Err(format!("failed tests: {}", failed.join(", ")));
    }
    eprintln!("[y] the ABI sweep is not implemented yet");
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
    fn compiler(&self, compiler: Compiler) -> Command {
        match compiler {
            Compiler::Rustc => cmd("rustc"),
            Compiler::Ryo => {
                let mut c = cmd(&self.rustc_ryo);
                c.env("RYO_BACKEND_MARKER", "1").env("RYO_STATS", "1");
                c
            }
            Compiler::Clif => cmd(&self.rustc_clif),
        }
    }

    /// The compiler's sysroot `lib/rustlib/<target>/lib`, where std's dylib is.
    fn target_libdir(&self, compiler: Compiler) -> Result<PathBuf, String> {
        let mut c = self.compiler(compiler);
        let libdir =
            output(c.env_remove("RYO_BACKEND_MARKER").env_remove("RYO_STATS").args(["--print", "target-libdir"]))?;
        Ok(PathBuf::from(libdir.trim()))
    }

    /// Builds every crate of `program` into `target/tests/<program>/<variant>/` and runs the
    /// binary there.
    fn build_and_run(&self, program: &Program, variant: &Variant) -> Result<RunResult, String> {
        let dir = self.out.join(program.name).join(variant.name);
        let _ = fs::remove_dir_all(&dir);
        fs::create_dir_all(&dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
        let mut exe = None;
        let mut vm_fns = Vec::new();
        let mut native_libs = Vec::new();
        for krate in program.crates {
            let mut c = self.compiler(variant.compiler);
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
        let result = self.run(&dir, &exe, variant, false)?;
        if variant.compiler == Compiler::Ryo && !program.vm.is_empty() {
            let names: Vec<&str> = vm_fns.iter().map(|(n, _)| n.as_str()).collect();
            let missing: Vec<_> = program.vm.iter().filter(|f| !names.contains(f)).collect();
            if !variant.vm_only && !missing.is_empty() {
                return Err(format!("not compiled to bytecode: {missing:?}; VM functions: {names:?}"));
            }
            // The same run with `RYO_VM_TRACE`: it must enter the expected functions, and
            // otherwise behave the same.
            let traced = self.run(&dir, &exe, variant, true)?;
            let (entries, rest): (Vec<&str>, Vec<&str>) =
                traced.stderr.split_inclusive('\n').partition(|l| l.starts_with("ryo-vm: enter "));
            let entered: Vec<&str> = entries
                .iter()
                .map(|l| l.trim_end().trim_start_matches("ryo-vm: enter "))
                .map(|id| vm_fns.iter().find(|(_, i)| i == id).map_or("?", |(n, _)| n.as_str()))
                .collect();
            let not_entered: Vec<_> = program.entered.iter().filter(|f| !entered.contains(f)).collect();
            if !variant.vm_only && !not_entered.is_empty() {
                return Err(format!("not entered through vm::enter: {not_entered:?}; entered: {entered:?}"));
            }
            let untraced = RunResult { stderr: rest.concat(), ..traced };
            if untraced != result {
                return Err("the run with RYO_VM_TRACE behaved differently".to_owned());
            }
        }
        Ok(result)
    }

    /// Compiles and links the C program `c_main` against `lib` (a staticlib or cdylib in `dir`).
    fn link_c(&self, dir: &Path, c_main: &str, lib: &Crate, native_libs: &[String]) -> Result<PathBuf, String> {
        let exe = dir.join(exe_name("c_main"));
        let mut c = Command::new("cc");
        c.arg(self.tests.join(c_main)).arg("-o").arg(&exe);
        match lib.kind {
            CrateKind::Staticlib => {
                c.arg(dir.join(format!("lib{}.a", lib.name))).args(native_libs);
            }
            CrateKind::Cdylib => {
                c.arg("-L").arg(dir).arg(format!("-l{}", lib.name));
            }
            _ => return Err("c_main needs a staticlib or cdylib".to_owned()),
        }
        let res = c.output().map_err(|e| format!("failed to run `{}`: {e}", describe(&c)))?;
        if !res.status.success() {
            return Err(format!("`{}` failed:\n{}", describe(&c), String::from_utf8_lossy(&res.stderr)));
        }
        Ok(exe)
    }

    /// Runs a built program in `dir`, with `RYO_VM_TRACE` if `trace`.
    fn run(&self, dir: &Path, exe: &Path, variant: &Variant, trace: bool) -> Result<RunResult, String> {
        let mut run = Command::new(exe);
        if trace {
            run.env("RYO_VM_TRACE", "1");
        } else {
            run.env_remove("RYO_VM_TRACE");
        }
        run.env_remove("RUST_BACKTRACE").env_remove("RUST_LIB_BACKTRACE").current_dir(dir);
        // Dylibs are found next to the binary, and std's in the sysroot that built it.
        let lib_path_var = if cfg!(windows) { "PATH" } else { "LD_LIBRARY_PATH" };
        let mut paths = vec![dir.to_path_buf(), self.target_libdir(variant.compiler)?];
        paths.extend(std::env::split_paths(&std::env::var_os(lib_path_var).unwrap_or_default()));
        run.env(lib_path_var, std::env::join_paths(paths).map_err(|e| e.to_string())?);
        let res = run.output().map_err(|e| format!("failed to run {}: {e}", exe.display()))?;
        // Panic messages name the source path, which is the same for every variant.
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
        assert_eq!(names(false), ["ryo", "ryo-threads8", "ryo-O3"]);
        assert_eq!(names(true), ["ryo", "ryo-threads8", "ryo-O3", "clif"]);
        assert!(super::variants(true).last().unwrap().compiler == super::Compiler::Clif);
    }

    #[test]
    fn parses_vm_functions() {
        let s = "ryo backend: init\nryo: vm fn answer (portal) id=0000abcd:00000001\n\
                 ryo: vm fn a::b::<u8> id=0000abcd:00000000\nryo: 2 VM functions\n";
        let want = [("answer", "0000abcd:00000001"), ("a::b::<u8>", "0000abcd:00000000")];
        let want: Vec<_> = want.iter().map(|(a, b)| (a.to_string(), b.to_string())).collect();
        assert_eq!(super::vm_functions(s), want);
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
    if !res.status.success()
        || stdout != "Hello, world!\n"
        || !stderr.contains(BACKEND_MARKER)
        || !stderr.contains(PARTITION_MARKER)
    {
        return Err(format!("{}\nstdout:\n{stdout}\nstderr:\n{stderr}", res.status));
    }
    Ok(())
}

/// Printed by the backend's `init` when `RYO_BACKEND_MARKER` is set.
const BACKEND_MARKER: &str = "ryo backend: init";

/// Printed by the backend's `collect_and_partition_mono_items` override when
/// `RYO_BACKEND_MARKER` is set: the override, not cg_llvm's default, partitioned the crate.
const PARTITION_MARKER: &str = "ryo backend: partition";

/// The functions a `RYO_STATS=1` build reports as compiled to bytecode, with their IDs as
/// `RYO_VM_TRACE` prints them: `ryo: vm fn <path>[ (portal)] id=<hash>:<index>`.
fn vm_functions(stderr: &str) -> Vec<(String, String)> {
    stderr
        .lines()
        .filter_map(|l| l.strip_prefix("ryo: vm fn "))
        .filter_map(|l| l.rsplit_once(" id="))
        .map(|(f, id)| (f.strip_suffix(" (portal)").unwrap_or(f).to_owned(), id.to_owned()))
        .collect()
}

/// Whether a C compiler (`cc`) is available for the [`Program::c_main`] programs.
fn have_cc() -> bool {
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

fn reject_randomize_layout(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let res = cmd(rustc_ryo)
        .arg(src)
        .arg("-Zrandomize-layout")
        .arg("-o")
        .arg(out.join(exe_name("randomized")))
        .output()
        .map_err(|e| e.to_string())?;
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
    let res = cmd("rustc")
        .arg(backend)
        .arg(src)
        .arg("-Ccodegen-units=4")
        .arg("-o")
        .arg(out.join(exe_name("cgu4")))
        .output()
        .map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if res.status.success() || !stderr.contains("-Ccodegen-units=1") {
        return Err(format!("expected the backend to reject 4 codegen units; stderr:\n{stderr}"));
    }
    Ok(())
}
