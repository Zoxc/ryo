//! `y test`'s standalone checks of `dist/`, besides the corpus.

use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::utils::{Captured, capture, capture_ok, cmd, dll_name, exe_name, output};

/// `cargo-ryo run` on a one-file package wrapping `tests/hello.rs`, then `cargo ryo build`
/// (cargo's subcommand lookup, with `dist/bin` on `PATH`) between plain `cargo build`s in one
/// target directory: plain, ryo (rebuilds), ryo again (fresh), plain again (fresh).
pub(super) fn cargo_smoke(info: &crate::utils::RustcInfo, root: &Path, out: &Path) -> Result<(), String> {
    let pkg = out.join("cargo-hello");
    crate::utils::create_dir(&pkg)?;
    let manifest = format!(
        "[package]\nname = \"cargo-hello\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n\
         [[bin]]\nname = \"hello\"\npath = {:?}\n\n[workspace]\n",
        root.join("tests").join("hello.rs").to_str().ok_or("non-UTF-8 path")?,
    );
    crate::utils::write(pkg.join("Cargo.toml"), manifest)?;
    let cargo_ryo = crate::utils::dist_bin(&root, "cargo-ryo");
    let res = capture(
        cmd(&cargo_ryo)
            .args(["run", "--quiet", "--offline"])
            .current_dir(&pkg)
            .env("RYO_BACKEND_MARKER", "1")
            // Force a rebuild, so the marker is printed. The dev profile compiles incrementally.
            .env("CARGO_TARGET_DIR", pkg.join("target"))
            .env_remove("CARGO_INCREMENTAL"),
    )?;
    let Captured { status, stdout, stderr } = res;
    if !status.success() || stdout != "Hello, world!\n" || !stderr.contains(BACKEND_MARKER) || !stderr.contains(PARTITION_MARKER) {
        let _ = fs::remove_dir_all(pkg.join("target"));
        return Err(format!("{status}\nstdout:\n{stdout}\nstderr:\n{stderr}"));
    }
    // As a cargo subcommand, cargo runs `cargo-ryo ryo build`, which must not recurse.
    let bin = cargo_ryo.parent().ok_or("dist/bin")?.to_path_buf();
    let mut paths = vec![bin];
    paths.extend(std::env::split_paths(&std::env::var_os("PATH").unwrap_or_default()));
    let path = std::env::join_paths(paths).map_err(|e| e.to_string())?;
    let target_sub = pkg.join("target-sub");
    let toolchain = &info.toolchain;
    // Plain cargo (LLVM) and `cargo ryo` in one target directory: `rustc-ryo -vV` names the
    // ryo build, so cargo tells their artifacts apart (design/build.md#the-y-build-tool).
    let build = |ryo: bool| -> Result<(bool, String), String> {
        let mut c = cmd("cargo");
        if ryo {
            c.arg("ryo");
        } else {
            c.env_remove("RUSTC").env("RUSTUP_TOOLCHAIN", &toolchain);
        }
        let res = capture(
            c.args(["build", "--verbose", "--offline"])
                .current_dir(&pkg)
                .env("PATH", &path)
                .env("RYO_BACKEND_MARKER", "1")
                .env("CARGO_TARGET_DIR", &target_sub)
                .env_remove("CARGO_INCREMENTAL"),
        )?;
        let stderr = res.stderr;
        let what = if ryo { "cargo ryo build" } else { "cargo build" };
        if !res.status.success() {
            return Err(format!("{what}: {}\nstderr:\n{stderr}", res.status));
        }
        let fresh = stderr.contains("Fresh cargo-hello") && !stderr.contains("Compiling cargo-hello");
        Ok((fresh, stderr))
    };
    let steps = [(false, None), (true, Some(false)), (true, Some(true)), (false, Some(true))];
    let mut result = Ok(());
    for (i, (ryo, want_fresh)) in steps.into_iter().enumerate() {
        let (fresh, stderr) = match build(ryo) {
            Ok(r) => r,
            Err(e) => {
                result = Err(e);
                break;
            }
        };
        let marker = stderr.contains(BACKEND_MARKER);
        if want_fresh.is_some_and(|w| w != fresh) || (ryo && !fresh && !marker) || (!ryo && marker) {
            let what = if ryo { "cargo ryo build" } else { "cargo build" };
            let want = if want_fresh == Some(true) { "fresh" } else { "a rebuild" };
            result = Err(format!("step {}: {what}: expected {want}\nstderr:\n{stderr}", i + 1));
            break;
        }
    }
    let _ = fs::remove_dir_all(pkg.join("target"));
    let _ = fs::remove_dir_all(&target_sub);
    result
}

/// `RUST_BACKTRACE=1` through VM frames: a panic two VM calls deep, caught by
/// `catch_unwind`, prints a backtrace naming the VM functions (by their symbols) and the
/// native frames around them, and the cleanup and the catch still run. PE differs (see below).
pub(super) fn backtrace(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let exe = out.join(exe_name("vm_backtrace"));
    crate::utils::run(cmd(rustc_ryo).arg("--edition=2024").arg(src).arg("-o").arg(&exe))?;
    // Without the JIT, whose code has no symbols (and with `RYO_JIT_THRESHOLD=0` would run
    // every frame).
    let Captured { status, stdout, stderr } = capture(Command::new(&exe).env("RUST_BACKTRACE", "1").env("RYO_JIT", "off"))?;
    // On PE the walk goes through the VM frames, but without their landing pads (no "guard
    // dropped"), and the frames of functions with internal linkage, VM or native (`inner`,
    // `outer`, `__rust_try`), are named after the nearest external symbol before them: the
    // PDB lists only external symbols, and neither VM code nor a build without `-g` has
    // CodeView records (design/platforms.md). Reaching `lang_start_internal` shows that the
    // walk got through.
    let (want, want_stdout): (&[&str], &str) = if MSVC {
        (&["deep 7", "vm_backtrace::main", "std::rt::lang_start_internal"], "caught: true\n")
    } else {
        (&["vm_backtrace::inner", "vm_backtrace::outer", "__rust_try", "vm_backtrace::main"], "guard dropped\ncaught: true\n")
    };
    let mut missing: Vec<_> = want.iter().filter(|w| !stderr.contains(*w)).collect();
    // The backtrace the guard's drop captures in the landing pad walks out of it, through
    // `outer`, into `main`.
    if !MSVC {
        let in_drop = stderr.split_once("drop backtrace:").map_or("", |(_, b)| b);
        missing.extend(["vm_backtrace::outer", "vm_backtrace::main"].iter().filter(|w| !in_drop.contains(*w)));
    }
    if !status.success() || stdout != want_stdout || !missing.is_empty() {
        return Err(format!("{status}, missing frames {missing:?}\nstdout:\n{stdout}stderr:\n{stderr}"));
    }
    Ok(())
}

/// Printed by the backend's `init` when `RYO_BACKEND_MARKER` is set.
pub(super) const BACKEND_MARKER: &str = "ryo backend: init";

/// Printed by the backend's `collect_and_partition_mono_items` override when
/// `RYO_BACKEND_MARKER` is set: the override, not cg_llvm's default, partitioned the crate.
pub(super) const PARTITION_MARKER: &str = "ryo backend: partition";

/// The functions a `RYO_STATS=1` build reports as compiled to bytecode:
/// `ryo: vm fn <path>[ (global)]`.
pub(crate) fn vm_functions(stderr: &str) -> Vec<String> {
    stderr.lines().filter_map(|l| l.strip_prefix("ryo: vm fn ")).map(|f| f.strip_suffix(" (global)").unwrap_or(f).to_owned()).collect()
}

/// Whether the host is windows-msvc: C programs are built with `cl`, and the staticlib and
/// the cdylib's import library are `<name>.lib` and `<name>.dll.lib`.
pub(super) const MSVC: bool = cfg!(target_env = "msvc");

/// The C compiler for the [`Program::c_main`] programs, and the C++ compiler for those in
/// C++ (`.cpp`): `cl` compiles both.
pub(super) fn c_compiler_name(cxx: bool) -> &'static str {
    match (MSVC, cxx) {
        (true, _) => "cl",
        (false, false) => "cc",
        (false, true) => "c++",
    }
}

/// Whether the [`Program::c_main`] `path` is C++.
pub(super) fn is_cxx(path: &str) -> bool {
    path.ends_with(".cpp")
}

/// A command running [`c_compiler_name`], or `None` if there is none. On MSVC, `cl` from `PATH`
/// in a Visual Studio developer environment, else from the newest Visual Studio with the C++
/// tools, with the environment ([`msvc_env`]) its `vcvars64.bat` sets up.
pub(super) fn c_compiler(cxx: bool) -> Option<Command> {
    if !MSVC {
        let name = c_compiler_name(cxx);
        return Command::new(name).arg("--version").output().is_ok_and(|o| o.status.success()).then(|| Command::new(name));
    }
    // `cl` without arguments prints its banner; starting at all is enough.
    if Command::new("cl").output().is_ok() {
        return Some(Command::new("cl"));
    }
    let env = msvc_env()?;
    let path = env.iter().find(|(k, _)| k.eq_ignore_ascii_case("PATH"))?;
    let cl = std::env::split_paths(&path.1).map(|d| d.join("cl.exe")).find(|p| p.is_file())?;
    let mut c = Command::new(cl);
    c.envs(env.iter().map(|(k, v)| (k, v)));
    Some(c)
}

/// The environment of a Visual Studio developer shell, without needing one: `vswhere` (at its
/// fixed place) finds the newest installation with the x64 C++ tools, and `cmd` runs its
/// `vcvars64.bat` and prints the result with `set`. Computed once.
#[cfg(windows)]
fn msvc_env() -> Option<&'static [(String, String)]> {
    use std::os::windows::process::CommandExt;
    static ENV: std::sync::OnceLock<Option<Vec<(String, String)>>> = std::sync::OnceLock::new();
    ENV.get_or_init(|| {
        let pf = std::env::var_os("ProgramFiles(x86)")?;
        let vswhere = Path::new(&pf).join("Microsoft Visual Studio").join("Installer").join("vswhere.exe");
        let o = Command::new(vswhere)
            .args(["-latest", "-products", "*", "-requires", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", "-property", "installationPath"])
            .output()
            .ok()?;
        let install = String::from_utf8_lossy(&o.stdout).lines().next()?.trim().to_owned();
        let bat = Path::new(&install).join("VC").join("Auxiliary").join("Build").join("vcvars64.bat");
        if !o.status.success() || !bat.is_file() {
            return None;
        }
        // `cmd /s /c "<line>"` takes the line between the outer quotes as is.
        let o = Command::new("cmd").raw_arg(format!("/d /s /c \"\"{}\" >nul && set\"", bat.display())).output().ok()?;
        if !o.status.success() {
            return None;
        }
        let vars = String::from_utf8_lossy(&o.stdout).lines().filter_map(|l| l.split_once('=')).map(|(k, v)| (k.to_owned(), v.to_owned())).collect();
        Some(vars)
    })
    .as_deref()
}

#[cfg(not(windows))]
fn msvc_env() -> Option<&'static [(String, String)]> {
    None
}

/// Rebuild after edits (design/README.md#goals): `tests/incremental/edits.rs`, built with
/// `-Cincremental -Zincremental-verify-ich` once per revision in one incremental directory,
/// each revision an edit of the previous. Each build's output must equal plain rustc's (also
/// with the JIT compiling every function), and its executable must be byte-identical to a
/// clean incremental build's. At opt-level 0, at opt-level 2 with thin LTO, and with
/// `RYO_NO_VM` at 16 codegen units, where rustc checks which units are reused. Then a proc
/// macro (no VM code, any number of codegen units) rebuilt after an edit, and used.
pub(super) fn incremental(rustc_ryo: &Path, dir_in: &Path, out: &Path) -> Result<(), String> {
    const REVISIONS: u32 = 9;
    let src = dir_in.join("edits.rs");
    let dir = out.join("incremental");
    let _ = fs::remove_dir_all(&dir);
    let run = |exe: &Path, env: &[(&str, &str)]| -> Result<String, String> {
        let res = Command::new(exe).envs(env.iter().copied()).output().map_err(|e| format!("running {}: {e}", exe.display()))?;
        if !res.status.success() {
            return Err(format!("{}: {}\nstderr:\n{}", exe.display(), res.status, String::from_utf8_lossy(&res.stderr)));
        }
        Ok(String::from_utf8_lossy(&res.stdout).into_owned())
    };
    let reuse = &["--cfg", "reuse", "-Zquery-dep-graph"][..];
    // Name, flags, flags for the incremental chain only, environment.
    // `O0` gets incremental's default of 256 codegen units, so one image per CGU.
    let configs: [(&str, &[&str], &[&str], &[(&str, &str)]); 4] = [
        ("O0", &[], &[], &[]),
        ("vm-16", &["-Ccodegen-units=16"], &[], &[]),
        ("O2-thin", &["-Copt-level=2", "-Clto=thin"], &[], &[]),
        ("no-vm-16", &["-Ccodegen-units=16"], reuse, &[("RYO_NO_VM", "1")]),
    ];
    for (config, flags, chain_flags, env) in configs {
        let incr = dir.join(config).join("incr");
        for rev in 1..=REVISIONS {
            let cfg = format!("rev{rev}");
            let build = |rustc: &Path, incr: Option<&Path>, extra: &[&str], sub: &str| -> Result<PathBuf, String> {
                // The chain's output path stays the same: it is part of the session.
                let d = if sub == "incr" { dir.join(config).join("chain") } else { dir.join(config).join(&cfg).join(sub) };
                crate::utils::create_dir(&d)?;
                let exe = d.join(exe_name("edits"));
                let mut c = cmd(rustc);
                c.arg("--edition=2024").arg(&src).args(["--cfg", &cfg]).arg("-o").arg(&exe);
                if let Some(incr) = incr {
                    c.args(flags).args(extra).envs(env.iter().copied());
                    c.arg(format!("-Cincremental={}", incr.display())).arg("-Zincremental-verify-ich");
                }
                crate::utils::run(&mut c).map_err(|e| format!("{config} {cfg} {sub}: {e}"))?;
                Ok(exe)
            };
            let reference = run(&build(Path::new("rustc"), None, &[], "rustc")?, &[])?;
            let exe = build(rustc_ryo, Some(&incr), chain_flags, "incr")?;
            // Image reuse (design/backend.md#incremental): the same revision again reuses
            // every image, and gives the same executable.
            if env.is_empty() {
                let read = |p: &Path| fs::read(p).map_err(|e| format!("reading {}: {e}", p.display()));
                let first = read(&exe)?;
                let mut c = cmd(rustc_ryo);
                c.arg("--edition=2024").arg(&src).args(["--cfg", &cfg]).arg("-o").arg(&exe).args(flags).args(chain_flags);
                c.arg(format!("-Cincremental={}", incr.display())).arg("-Zincremental-verify-ich").env("RYO_STATS", "1");
                let res = c.output().map_err(|e| format!("{config} {cfg} again: {e}"))?;
                let stderr = String::from_utf8_lossy(&res.stderr);
                if !res.status.success() {
                    return Err(format!("{config} {cfg} again: {}\n{stderr}", res.status));
                }
                let reused = stderr.lines().find_map(|l| l.strip_prefix("ryo: ")?.strip_suffix(" images reused"));
                match reused.and_then(|r| r.split_once(" of ")) {
                    Some((r, n)) if r == n && n != "0" => {}
                    r => return Err(format!("{config} {cfg}: rebuilt unchanged, reused {r:?} images, expected all")),
                }
                if read(&exe)? != first {
                    return Err(format!("{config} {cfg}: rebuilt unchanged, {} differs", exe.display()));
                }
            }
            for env in [&[][..], super::JIT_SYNC] {
                let got = run(&exe, env)?;
                if got != reference {
                    return Err(format!("{config} {cfg} {env:?}: output {got:?}, plain rustc's {reference:?}"));
                }
            }
            let clean = build(rustc_ryo, Some(&dir.join(config).join(&cfg).join("clean-incr")), &[], "clean")?;
            let read = |p: &Path| fs::read(p).map_err(|e| format!("reading {}: {e}", p.display()));
            if read(&exe)? != read(&clean)? {
                return Err(format!("{config} {cfg}: {} differs from the clean build {}", exe.display(), clean.display()));
            }
        }
    }

    let pm_dir = dir.join("pm");
    crate::utils::create_dir(&pm_dir)?;
    for (rev, want) in [("rev1", "41\n"), ("rev2", "42\n")] {
        let mut c = cmd(rustc_ryo);
        c.arg("--edition=2024").arg(dir_in.join("pm.rs")).args(["--crate-type", "proc-macro", "--crate-name", "pm", "--cfg", rev]);
        c.arg(format!("-Cincremental={}", pm_dir.join("incr").display())).args(["-Zincremental-verify-ich", "-Zquery-dep-graph", "--out-dir"]);
        crate::utils::run(c.arg(&pm_dir)).map_err(|e| format!("proc macro {rev}: {e}"))?;
        let exe = pm_dir.join(exe_name("pm_user"));
        let mut extern_pm = OsString::from("pm=");
        extern_pm.push(pm_dir.join(dll_name("pm")));
        crate::utils::run(cmd(rustc_ryo).arg("--edition=2024").arg(dir_in.join("pm_user.rs")).arg("--extern").arg(extern_pm).arg("-o").arg(&exe))
            .map_err(|e| format!("proc macro user {rev}: {e}"))?;
        let got = run(&exe, &[])?;
        if got != want {
            return Err(format!("proc macro {rev}: output {got:?}, expected {want:?}"));
        }
    }
    let _ = fs::remove_dir_all(&dir);
    Ok(())
}

/// The dynamic symbols a ryo Rust dylib, cdylib, and an executable with `-Zexport-executable-symbols`,
/// export are exactly plain rustc's (plus the runtime's own), with and without
/// `-Clto`: the image's symbols are listed
/// as exports for LTO, and `link` must remove those, and only those
/// (design/backend.md#query-overrides). ELF and Mach-O (`llvm-nm -D`).
pub(super) fn same_exports(info: &crate::utils::RustcInfo, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if cfg!(windows) {
        return Ok(());
    }
    let nm = info.tool("llvm-nm");
    let dir = out.join("exports");
    crate::utils::create_dir(&dir)?;
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
            let mut syms: Vec<String> =
                syms.lines().map(|s| crate::jit::unprefixed(&info.host, s)).filter(|s| !runtime(s)).map(str::to_owned).collect();
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
pub(super) fn is_rt_internal(s: &str) -> bool {
    s.starts_with("_R") && s.contains("7___rustc") && (s.contains("ryo_h_") || s.ends_with("15ryo_probe_stack") || s.contains("ryo_jit_trip_"))
}

/// v0 crate roots (`C<disambiguator>_<len><name>`) `ryo_rt` may use.
pub(super) const CRATES: [&str; 4] = ["4core", "17compiler_builtins", "12ryo_bytecode", "6ryo_rt"];

/// Whether `s` is a Rust symbol of a crate outside [`CRATES`] (std's), or std's allocator
/// shim (`__rust_*`, `__rdl_*`, `__rg_*`).
pub(super) fn outside(s: &str) -> bool {
    if s.starts_with("__rust") || s.starts_with("__rdl") || s.starts_with("__rg_") {
        return true;
    }
    s.starts_with("_R") && !is_rt_internal(s) && crate_roots(s).iter().any(|c| !CRATES.contains(&c.as_str()))
}

/// `ryo_rt` must use only `core`, its own crates, libc, and the panic runtime's two entry
/// points (native: a panic runtime is never VM code): with `--sysroot ryo`, std's allocator,
/// locks and TLS may be VM functions, which the runtime must not call while it switches VM
/// state (design/vm.md, "No re-entry into the VM from the runtime"). Checked on the undefined
/// symbols of every sysroot's `ryo_rt` rlib for `triple`, by crate in their v0 mangled names.
/// ELF and Mach-O (`test --cross` checks a Mach-O target's). The JIT's trips are part of it; the JIT thread, which uses std, is the sealed object that
/// the rlib bundles (design/jit.md#packaging), which `ryo_rt` reaches only through `ryo_jit_start`
/// and `jit-sealed` checks: this check skips it.
pub(crate) fn rt_core_only(info: &crate::utils::RustcInfo, root: &Path, triple: &str) -> Result<(), String> {
    if triple.contains("-windows-") {
        return Ok(());
    }
    let nm = info.tool("llvm-nm");
    let dist = root.join("dist");
    let mut libs = Vec::new();
    for sysroot in [dist.clone(), dist.join(crate::sysroot::SYSROOT_DIR)] {
        let dir = sysroot.join("lib").join("rustlib").join(triple).join("lib");
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
            .map(|s| crate::jit::unprefixed(triple, s))
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
        let objdump = info.tool("llvm-objdump");
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
        if let Some(path) = panic_path(&objdump, &lib, &bytecode, triple)? {
            return Err(format!("{} reaches core's panic path: {}", lib.display(), path.join(" <- ")));
        }
    }
    Ok(())
}

/// The sealed JIT that the native sysroot's `ryo_rt` bundles keeps its std to itself
/// ([`crate::jit::check_sealed`]). Hosts with the JIT only; `test --cross` checks a cross
/// target's.
pub(super) fn jit_sealed(info: &crate::utils::RustcInfo, root: &Path, out: &Path) -> Result<(), String> {
    if !crate::jit::supported(&info.host) {
        return Ok(());
    }
    let lib = crate::utils::ryo_rt_rlib(root, &info.host);
    crate::jit::check_sealed(info, &lib, &out.join("jit-sealed"), &info.host)
}

/// The JIT's std is its own (design/jit.md#packaging), so the program's can't get in its way:
/// `tests/vm_jit_private.rs`, with every function compiled at its first call and waited for,
/// has a VM global allocator that trips while it holds its lock (the JIT would deadlock
/// allocating through it), and built with `-Cpanic=abort` and run with `RYO_JIT_TEST_PANIC`
/// it must still run as without the JIT: every compile panics, which fails the function
/// instead of aborting. Hosts with the JIT only.
pub(super) fn jit_private_std(info: &crate::utils::RustcInfo, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if !crate::jit::supported(&info.host) {
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
pub(super) fn panic_path(objdump: &Path, rt: &Path, bytecode: &Path, triple: &str) -> Result<Option<Vec<String>>, String> {
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
                let name = crate::jit::unprefixed(triple, name).to_owned();
                if is_rt {
                    roots.push(name.clone());
                }
                edges.entry(name.clone()).or_default();
                cur = Some(name);
            } else if let (Some(f), Some(i)) = (&cur, line.find("R_X86_64_").or_else(|| line.find("X86_64_RELOC_"))) {
                let target = line[i..].split_whitespace().nth(1).unwrap_or("");
                let target = crate::jit::unprefixed(triple, target.split(['+', '-']).next().unwrap_or("")).to_owned();
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
pub(super) fn crate_roots(sym: &str) -> Vec<String> {
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
pub(super) fn metadata_only(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let stderr = capture_ok(
        cmd(rustc_ryo)
            .arg(src)
            .args(["--crate-type=rlib", "--emit=metadata", "--crate-name=meta_only"])
            .arg("--out-dir")
            .arg(out)
            .env("RYO_BACKEND_MARKER", "1"),
    )?
    .stderr;
    if stderr.contains(PARTITION_MARKER) {
        return Err(format!("expected a metadata-only build without partitioning; stderr:\n{stderr}"));
    }
    Ok(())
}

/// `RYO_DUMP` of a program whose VM code names statics must build cleanly: printing a path
/// with trimmed paths outside a diagnostic made rustc panic as the session ended.
pub(super) fn dump(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let dump = out.join("dump.txt");
    capture_ok(cmd(rustc_ryo).args(["--edition=2024", "-O"]).arg(src).arg("-o").arg(out.join(exe_name("dump"))).env("RYO_DUMP", &dump))?;
    let text = fs::read_to_string(&dump).map_err(|e| format!("reading {}: {e}", dump.display()))?;
    if !text.contains(" = static ") {
        return Err(format!("{} names no static", dump.display()));
    }
    Ok(())
}

pub(super) fn reject_randomize_layout(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    expect_reject(cmd(rustc_ryo).arg(src).arg("-Zrandomize-layout").arg("-o").arg(out.join(exe_name("randomized"))), "-Zrandomize-layout")
}

/// Runs `c`, which must fail with `needle` in its stderr.
fn expect_reject(c: &mut Command, needle: &str) -> Result<(), String> {
    let res = capture(c)?;
    if res.status.success() || !res.stderr.contains(needle) {
        return Err(format!("expected `{}` to fail mentioning {needle}; stderr:\n{}", crate::utils::describe(c), res.stderr));
    }
    Ok(())
}

/// Two builds of a program split over 16 codegen units give byte-identical image objects,
/// several of them (one per CGU with VM code, design/backend.md#pipeline).
pub(super) fn cgu_deterministic(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let build = |name: &str| -> Result<Vec<(String, Vec<u8>)>, String> {
        let dir = out.join(name);
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
        capture_ok(
            cmd(rustc_ryo).args(["--edition=2024", "-Ccodegen-units=16", "-Csave-temps", "--crate-name", "vm_cgu", "--out-dir"]).arg(&dir).arg(src),
        )?;
        let mut images = Vec::new();
        for e in std::fs::read_dir(&dir).map_err(|e| e.to_string())? {
            let p = e.map_err(|e| e.to_string())?.path();
            let name = p.file_name().unwrap_or_default().to_string_lossy().into_owned();
            if name.contains(".ryo_image") {
                images.push((name, std::fs::read(&p).map_err(|e| e.to_string())?));
            }
        }
        images.sort();
        Ok(images)
    };
    let (a, b) = (build("cgu-a")?, build("cgu-b")?);
    if a.len() < 2 {
        return Err(format!("expected several image objects at 16 codegen units, got {}", a.len()));
    }
    if a != b {
        let names = |v: &[(String, Vec<u8>)]| v.iter().map(|(n, _)| n.clone()).collect::<Vec<_>>();
        return Err(format!("two builds gave different image objects: {:?} vs {:?}", names(&a), names(&b)));
    }
    Ok(())
}
