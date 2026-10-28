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
    // On PE the frames of functions with internal linkage, VM or native (`inner`, `outer`,
    // `__rust_try`), are named after the nearest external symbol before them: the PDB lists
    // only external symbols, and neither VM code nor a build without `-g` has CodeView
    // records (design/platforms.md). Reaching `lang_start_internal` shows that the walk got
    // through.
    let (want, in_drop_want): (&[&str], &[&str]) = if MSVC {
        (&["deep 7", "vm_backtrace::main", "std::rt::lang_start_internal"], &["std::rt::lang_start_internal"])
    } else {
        (&["vm_backtrace::inner", "vm_backtrace::outer", "__rust_try", "vm_backtrace::main"], &["vm_backtrace::outer", "vm_backtrace::main"])
    };
    let want_stdout = "guard dropped\ncaught: true\n";
    let mut missing: Vec<_> = want.iter().filter(|w| !stderr.contains(*w)).collect();
    // The backtrace the guard's drop captures in the landing pad walks out of it, through
    // `outer` (on PE through the pad region, the trampoline and the unwinder's frames), into
    // `main`.
    let in_drop = stderr.split_once("drop backtrace:").map_or("", |(_, b)| b);
    missing.extend(in_drop_want.iter().filter(|w| !in_drop.contains(*w)));
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
/// clean incremental build's. At opt-level 0, at opt-level 2 (where rustc would run
/// crate-local ThinLTO), and with `RYO_NO_VM` at 16 codegen units, where rustc checks which units are reused. Then a proc
/// macro (no VM code, any number of codegen units) rebuilt after an edit, and used.
pub(super) fn incremental(rustc_ryo: &Path, dir_in: &Path, out: &Path) -> Result<(), String> {
    const REVISIONS: u32 = 11;
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
        ("O2", &["-Copt-level=2"], &[], &[]),
        ("no-vm-16", &["-Ccodegen-units=16"], reuse, &[("RYO_NO_VM", "1")]),
    ];
    // Set for the rebuild after corrupting side data, which reuses all but that image.
    let corrupted = std::cell::Cell::new(false);
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
                // rev11 only shifts `main`'s `DefIndex`: the chain must reuse every image.
                let check_reuse = sub == "incr" && rev == 11 && env.is_empty() && !corrupted.get();
                if check_reuse {
                    c.env("RYO_STATS", "1");
                }
                let res = capture(&mut c).map_err(|e| format!("{config} {cfg} {sub}: {e}"))?;
                if !res.status.success() {
                    return Err(format!("{config} {cfg} {sub}: {}\nstderr:\n{}", res.status, res.stderr));
                }
                if check_reuse {
                    let reused = res.stderr.lines().find_map(|l| l.strip_prefix("ryo: ")?.strip_suffix(" images reused"));
                    match reused.and_then(|r| r.split_once(" of ")) {
                        Some((r, n)) if r == n && n != "0" => {}
                        r => return Err(format!("{config} {cfg}: an unused item ahead of `main` re-lowered images: reused {r:?}")),
                    }
                }
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
            // Corrupt side data with an intact footer: the image is rebuilt, not an ICE.
            if config == "O0" && rev == REVISIONS {
                corrupt_side_data(&incr)?;
                corrupted.set(true);
                let exe = build(rustc_ryo, Some(&incr), chain_flags, "incr").map_err(|e| format!("after corrupting side data: {e}"))?;
                let got = run(&exe, &[])?;
                if got != reference {
                    return Err(format!("{config} {cfg} after corrupting side data: output {got:?}, plain rustc's {reference:?}"));
                }
                corrupted.set(false);
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
/// export are exactly plain rustc's (plus the runtime's own) (design/backend.md#query-overrides).
/// ELF and Mach-O (`llvm-nm -D`). On Linux, the cdylib's registry constructor doesn't bind
/// `ryo_vm_register` dynamically.
pub(super) fn same_exports(info: &crate::utils::RustcInfo, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if cfg!(windows) {
        return Ok(());
    }
    let dir = out.join("exports");
    crate::utils::create_dir(&dir)?;
    let cases: [(&str, &[&str]); 3] = [
        ("dylib", &["--crate-type=dylib", "-Cprefer-dynamic"]),
        ("cdylib", &["--crate-type=cdylib"]),
        ("exe", &["--crate-type=bin", "-Zexport-executable-symbols"]),
    ];
    for (name, flags) in cases {
        let mut lists = Vec::new();
        for (who, compiler) in [("rustc", Path::new("rustc")), ("ryo", rustc_ryo)] {
            let o = dir.join(format!("{name}-{who}"));
            crate::utils::run(cmd(compiler).arg("--edition=2024").arg(src).args(flags).arg("-o").arg(&o))?;
            // The registry constructor binds its own `ryo_rt`'s `ryo_vm_register` at link
            // time: through a dynamic relocation, another ryo shared object loaded first
            // would get this one's images.
            if who == "ryo" && name == "cdylib" && cfg!(target_os = "linux") {
                let relocs = output(cmd(info.tool("llvm-objdump")).arg("--dynamic-reloc").arg(&o))?;
                if let Some(line) = relocs.lines().find(|l| l.contains("ryo_vm_register")) {
                    return Err(format!("{}: `ryo_vm_register` is bound dynamically: {line}", o.display()));
                }
            }
            // The runtime's own symbols: in a Rust dylib everything of `ryo_rt` and
            // `ryo_bytecode`, the handlers included. A cdylib and an executable export none.
            let runtime = |s: &str| s.contains("6ryo_rt") || s.contains("12ryo_bytecode") || is_rt_internal(s);
            let mut syms = crate::utils::nm_symbols(info, &["-D", "--defined-only"], &o, &info.host)?;
            syms.retain(|s| !runtime(s));
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
/// `__rustc` root, with the ABI tag): the handlers `ryo_h_*`, `ryo_probe_stack`,
/// `ryo_vm_register`, `ryo_seh_handler` and the JIT's trip entry points `ryo_jit_trip_*`.
pub(super) fn is_rt_internal(s: &str) -> bool {
    s.starts_with("_R")
        && s.contains("7___rustc")
        && ["ryo_h_", "ryo_probe_stack_", "ryo_jit_trip_", "ryo_vm_register_", "ryo_seh_handler_"].iter().any(|p| s.contains(p))
}

/// v0 crate roots (`C<disambiguator>_<len><name>`) `ryo_rt` may use.
pub(super) const CRATES: [&str; 4] = ["4core", "17compiler_builtins", "12ryo_bytecode", "6ryo_rt"];

/// Whether `s` is a Rust symbol of a crate outside [`CRATES`] (std's), or std's allocator
/// shim (`__rust_*`, `__rdl_*`, `__rg_*`).
pub(super) fn outside(s: &str) -> bool {
    if crate::utils::is_std_alloc_shim(s) {
        return true;
    }
    s.starts_with("_R") && !is_rt_internal(s) && crate_roots(s).iter().any(|c| !CRATES.contains(&c.as_str()))
}

/// `ryo_rt` must use only `core`, its own crates, libc, and the panic runtime's two entry
/// points (native: a panic runtime is never VM code): with `--sysroot ryo`, std's allocator,
/// locks and TLS may be VM functions, which the runtime must not call while it switches VM
/// state (design/vm.md, "No re-entry into the VM from the runtime"). Checked on the undefined
/// symbols of every sysroot's `ryo_rt` rlib for `triple`, by crate in their v0 mangled names.
/// ELF, PE and Mach-O (`test --cross` checks a cross target's). The JIT's trips are part of it; the JIT thread, which uses std, is the sealed object that
/// the rlib bundles (design/jit.md#packaging), which `ryo_rt` reaches only through `ryo_jit_start`
/// and `jit-sealed` checks: this check skips it.
pub(crate) fn rt_core_only(info: &crate::utils::RustcInfo, root: &Path, triple: &str) -> Result<(), String> {
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
        let syms = crate::utils::nm_symbols(info, &["-u", "--no-demangle"], &lib, triple)?;
        // Per member, after a `<member>:` line.
        let mut in_jit = false;
        let bad: Vec<&str> = syms
            .iter()
            .map(String::as_str)
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
    crate::jit::check_sealed(info, &lib, &out.join("jit-sealed"), &info.host).map(drop)
}

/// The JIT's std is its own (design/jit.md#packaging), so the program's can't get in its way:
/// `tests/vm_jit_private.rs`, with every function compiled at its first call and waited for,
/// has a VM global allocator that trips while it holds its lock (the JIT would deadlock
/// allocating through it), and built with `-Cpanic=abort` and run with `RYO_JIT_TEST_PANIC`
/// it must still run as without the JIT: every compile panics, which fails the function
/// instead of aborting; so must it with `RYO_JIT_TEST_OOM`, where every compile fails an
/// allocation (the JIT's allocation error hook panics). Hosts with the JIT only.
pub(super) fn jit_private_std(info: &crate::utils::RustcInfo, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if !crate::jit::supported(&info.host) {
        return Ok(());
    }
    let want = "sum 499500 words w0,w97,w194,w291,w388,w485,w582,w679,w776,w873,w970\n";
    let sync = [("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1")];
    // Each case: the name, the flags, the environment, and what stderr must contain.
    let cases: [(&str, &[&str], &[(&str, &str)], &str); 3] = [
        ("jit_private", &[], &[], ""),
        ("jit_private_abort", &["-Cpanic=abort"], &[("RYO_JIT_TEST_PANIC", "1"), ("RYO_JIT_LOG", "1")], "RYO_JIT_TEST_PANIC"),
        ("jit_private_oom", &["-Cpanic=abort"], &[("RYO_JIT_TEST_OOM", "1"), ("RYO_JIT_LOG", "1")], "bytes failed"),
    ];
    for (name, flags, env, want_err) in cases {
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
        // The compiles failed: the log says why and that the functions stayed on AOT code.
        let failed = want_err.is_empty() || (stderr.contains(want_err) && stderr.contains(": panicked\n"));
        if !status.success() || stdout != want || !failed {
            return Err(format!("{name}: {status}\nstdout:\n{stdout}stderr:\n{}", stderr.lines().take(20).collect::<Vec<_>>().join("\n")));
        }
    }
    Ok(())
}

/// The atomics on pointers and 64-bit integers, whose handlers MergeFunctions folds in pairs
/// (`ptr` and `w64`), compiled by the JIT at their first call: every function must compile,
/// none fail to decode (`RYO_JIT_STATS`'s exit summary).
pub(super) fn jit_atomics(info: &crate::utils::RustcInfo, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if !crate::jit::supported(&info.host) {
        return Ok(());
    }
    let exe = out.join(exe_name("jit_atomics"));
    crate::utils::run(cmd(rustc_ryo).arg("--edition=2024").arg(src).arg("-o").arg(&exe))?;
    let env = [("RYO_JIT_THRESHOLD", "0"), ("RYO_JIT_SYNC", "1"), ("RYO_JIT_STATS", "1"), ("RYO_JIT_LOG", "1")];
    let r = capture(Command::new(&exe).envs(env))?;
    // The summary's `compiled` and `failed` counts.
    let count = |what: &str| {
        let line = r.stderr.lines().find(|l| l.starts_with("[ryo] jit stats:") && l.split_whitespace().nth(3) == Some(what))?;
        line.split_whitespace().nth(4)?.trim_end_matches(':').parse::<u64>().ok()
    };
    let (compiled, failed) = (count("compiled"), count("failed"));
    if !r.status.success() || r.stdout != "ptrs 314 u64s 6145 usizes 82\n" || failed != Some(0) || !compiled.is_some_and(|c| c >= 3) {
        let failing: Vec<&str> = r.stderr.lines().filter(|l| l.starts_with("ryo-jit:") && !l.contains(": compiled")).take(10).collect();
        return Err(format!("jit-atomics: {}, compiled {compiled:?}, failed {failed:?}\nstdout:\n{}{}", r.status, r.stdout, failing.join("\n")));
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
                let name = crate::target::unprefixed(triple, name).to_owned();
                if is_rt {
                    roots.push(name.clone());
                }
                edges.entry(name.clone()).or_default();
                cur = Some(name);
            } else if let (Some(f), Some(i)) =
                (&cur, line.find("R_X86_64_").or_else(|| line.find("X86_64_RELOC_")).or_else(|| line.find("IMAGE_REL_AMD64_")))
            {
                let target = line[i..].split_whitespace().nth(1).unwrap_or("");
                let target = crate::target::unprefixed(triple, target.split(['+', '-']).next().unwrap_or("")).to_owned();
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
/// with trimmed paths outside a diagnostic made rustc panic as the session ended. And what
/// must stay native has no VM code (design/lowering.md, design/backend.md#pipeline): a
/// `#[link_section]` function, and a runtime-internal crate (`#![no_builtins]`).
pub(super) fn dump(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let dump = out.join("dump.txt");
    capture_ok(cmd(rustc_ryo).args(["--edition=2024", "-O"]).arg(src).arg("-o").arg(out.join(exe_name("dump"))).env("RYO_DUMP", &dump))?;
    let text = fs::read_to_string(&dump).map_err(|e| format!("reading {}: {e}", dump.display()))?;
    if !text.contains(" = static ") {
        return Err(format!("{} names no static", dump.display()));
    }
    let lib = |name: &str, src: &str| -> Result<String, String> {
        let rs = out.join(format!("{name}.rs"));
        let dump = out.join(format!("{name}.dump.txt"));
        let _ = fs::remove_file(&dump);
        fs::write(&rs, src).map_err(|e| format!("writing {}: {e}", rs.display()))?;
        capture_ok(cmd(rustc_ryo).args(["--edition=2024", "--crate-type=rlib", "--out-dir"]).arg(out).arg(&rs).env("RYO_DUMP", &dump))?;
        Ok(fs::read_to_string(&dump).unwrap_or_default())
    };
    let sectioned = "#[unsafe(link_section = \".text.ryo_sectioned\")]\npub fn sectioned(x: u64) -> u64 {\n    x * 3 + 1\n}\n\npub fn plain(x: u64) -> u64 {\n    x * 5 + 2\n}\n";
    let text = lib("dump_sectioned", sectioned)?;
    if !text.contains("fn plain") || text.contains("fn sectioned") {
        return Err(format!("dump_sectioned: want `plain` as VM code and `sectioned` native, got:\n{text}"));
    }
    let text = lib("dump_no_builtins", "#![no_builtins]\npub fn f(x: u64) -> u64 {\n    x * 3 + 1\n}\n")?;
    if text.contains("fn ") {
        return Err(format!("dump_no_builtins: a `#![no_builtins]` crate has VM code:\n{text}"));
    }
    Ok(())
}

/// On PE, references go through `__imp_` exactly where plain rustc's do (design/platforms.md):
/// [`tests/pe_imports`](../../../tests/pe_imports) built for `x86_64-pc-windows-msvc` as an
/// rlib, by ryo and by plain rustc, refers to each upstream and foreign item with the same
/// indirection (`llvm-objdump -r` of its objects). Skipped when `dist/` has no std for that
/// target (`./y.sh build --target x86_64-pc-windows-msvc`).
pub(super) fn pe_imports(info: &crate::utils::RustcInfo, root: &Path, rustc_ryo: &Path, dir_in: &Path, out: &Path) -> Result<(), String> {
    const TARGET: &str = "x86_64-pc-windows-msvc";
    if !root.join("dist/lib/rustlib").join(TARGET).join("lib").exists() {
        eprintln!("[y] pe-imports: skipped, dist/ has no {TARGET} (`./y.sh build --target {TARGET}`)");
        return Ok(());
    }
    // The items, by a unique part of their (mangled) name.
    const ITEMS: [&str; 12] =
        ["5up_fn", "6up_gen", "5dy_fn", "9UP_STATIC", "S_NONE", "S_STATIC", "S_DYLIB", "S_UNSP", "f_none", "f_static", "f_dylib", "f_unsp"];
    let dir = out.join("pe-imports");
    let _ = fs::remove_dir_all(&dir);
    crate::utils::create_dir(&dir)?;
    // The `kind = "static"` library must exist to build the rlib.
    crate::utils::run(cmd(info.tool("llvm-ar")).arg("rc").arg(dir.join("pe_static.lib")))?;
    let mut found = Vec::new();
    for (who, compiler) in [("rustc", Path::new("rustc")), ("ryo", rustc_ryo)] {
        let d = dir.join(who);
        crate::utils::create_dir(&d)?;
        let rustc = |src: &str, args: &[&str]| {
            let mut c = cmd(compiler);
            c.args(["--edition=2024", "-Zshare-generics=yes", "-Cprefer-dynamic", &format!("--target={TARGET}")]).arg(dir_in.join(src));
            c.args(args).arg("-L").arg(&d).arg("-L").arg(&dir).arg("--out-dir").arg(&d);
            crate::utils::run(&mut c).map_err(|e| format!("{who} {src}: {e}"))
        };
        rustc("up.rs", &["--crate-type=rlib"])?;
        // Only the metadata: linking a dylib needs the target's linker and libraries.
        rustc("dy.rs", &["--crate-type=dylib", "--emit=metadata", "-Zalways-encode-mir"])?;
        let dy = format!("dy={}", d.join("libdy.rmeta").display());
        rustc("pe_imports.rs", &["--crate-type=rlib", "--extern", "up", "--extern", &dy])?;
        let members = d.join("members");
        crate::utils::create_dir(&members)?;
        crate::utils::run(cmd(info.tool("llvm-ar")).current_dir(&members).arg("x").arg(d.join("libpe_imports.rlib")))?;
        let mut refs = std::collections::BTreeSet::new();
        for e in fs::read_dir(&members).map_err(|e| e.to_string())?.flatten() {
            if e.path().extension().is_none_or(|x| x != "o") {
                continue;
            }
            for line in output(cmd(info.tool("llvm-objdump")).arg("-r").arg(e.path()))?.lines() {
                let Some(sym) = line.split_whitespace().nth(2) else { continue };
                let sym = sym.split(['+', '-']).next().unwrap_or(sym);
                let (imp, name) = sym.strip_prefix("__imp_").map_or((false, sym), |n| (true, n));
                if let Some(item) = ITEMS.iter().find(|i| if i.starts_with(|c: char| c.is_ascii_digit()) { name.contains(*i) } else { name == **i }) {
                    refs.insert((*item, imp));
                }
            }
        }
        found.push(refs);
    }
    for item in ITEMS {
        let of = |refs: &std::collections::BTreeSet<(&str, bool)>| [false, true].map(|imp| refs.contains(&(item, imp)));
        let (want, got) = (of(&found[0]), of(&found[1]));
        if want == [false, false] {
            return Err(format!("pe-imports: plain rustc's object doesn't refer to `{item}`"));
        }
        if got != want {
            return Err(format!("pe-imports: `{item}` referred to (direct, `__imp_`) {got:?}, plain rustc {want:?}"));
        }
    }
    Ok(())
}

/// Flips a byte in the middle of the largest saved image side data (`*.ryo`) under the
/// incremental directory `incr`, leaving its end marker intact.
fn corrupt_side_data(incr: &Path) -> Result<(), String> {
    fn walk(dir: &Path, found: &mut Vec<(u64, PathBuf)>) {
        for e in fs::read_dir(dir).into_iter().flatten().flatten() {
            let p = e.path();
            if p.is_dir() {
                walk(&p, found);
            } else if p.extension().is_some_and(|x| x == "ryo") {
                found.push((e.metadata().map_or(0, |m| m.len()), p));
            }
        }
    }
    let mut found = Vec::new();
    walk(incr, &mut found);
    let Some((_, path)) = found.into_iter().max() else { return Err(format!("no saved side data under {}", incr.display())) };
    let mut bytes = fs::read(&path).map_err(|e| format!("reading {}: {e}", path.display()))?;
    let mid = bytes.len() / 2;
    bytes[mid] ^= 0xff;
    fs::write(&path, bytes).map_err(|e| format!("writing {}: {e}", path.display()))
}

/// The backend fails with a clear error, naming the option, where VM code can't honour it
/// (design/backend.md#unsupported-options): LTO in any form; sanitizers, control-flow
/// protection and other hardening, instrumentation and profiling, which VM code would
/// silently lack, including a target's default sanitizers; `-Zrandomize-layout` (also
/// through an `@argfile`, past the wrapper); `-Zautodiff`, `-Zoffload`, a code model
/// other than `small` (also a target JSON's); unsupported targets (also MinGW), soft-float ones and `+soft-float`/`-sse2`; outputs without the images (`--emit=obj`, `bc`, an rlib without
/// `link`, `-o -`); and the options that bypass ryo's link step.
pub(super) fn reject_unsupported(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let dir = out.join("reject");
    crate::utils::create_dir(&dir)?;
    let o = dir.join(exe_name("rejected"));
    let argfile = dir.join("args");
    fs::write(&argfile, "-Zrandomize-layout\n").map_err(|e| format!("writing {}: {e}", argfile.display()))?;
    let at_argfile = format!("@{}", argfile.display());
    let cases: &[(&[&str], &str)] = &[
        (&["-Zrandomize-layout"], "-Zrandomize-layout"),
        (&[&at_argfile], "-Zrandomize-layout"),
        (&["--emit=obj"], "--emit=obj"),
        (&["--emit=link,llvm-bc"], "--emit=llvm-bc"),
        (&["-Zno-link"], "-Zno-link"),
        (&["-Zlink-only"], "-Zlink-only"),
        (&["--crate-type=staticlib", "-Zstaticlib-rename-internal-symbols"], "-Zstaticlib-rename-internal-symbols"),
        (&["--crate-type=staticlib", "-Zstaticlib-hide-internal-symbols"], "-Zstaticlib-hide-internal-symbols"),
        (&["-Clto"], "-Clto"),
        (&["-Clto=fat"], "-Clto"),
        (&["-Clto=thin"], "-Clto"),
        (&["-Clto=yes"], "-Clto"),
        (&["-Clinker-plugin-lto"], "-Clinker-plugin-lto"),
        (&["--crate-type=dylib", "-Zdylib-lto"], "-Zdylib-lto"),
        (&["-Zsanitizer=address"], "sanitizer"),
        (&["-Zsanitizer=kcfi"], "sanitizer"),
        (&["-Zsanitizer=cfi", "-Ccodegen-units=1"], "sanitizer"),
        (&["-Zsanitizer=memory"], "sanitizer"),
        (&["-Zsanitizer=thread"], "sanitizer"),
        (&["-Zcf-protection=full"], "-Zcf-protection"),
        (&["-Ccontrol-flow-guard"], "-Ccontrol-flow-guard"),
        (&["-Zehcont-guard"], "-Zehcont-guard"),
        (&["-Cinstrument-coverage"], "-Cinstrument-coverage"),
        (&["-Cprofile-generate"], "-Cprofile-generate"),
        (&["-Zinstrument-xray"], "-Zinstrument-xray"),
        (&["-Zinstrument-mcount"], "-Zinstrument-mcount"),
        (&["-Zpatchable-function-entry=4"], "-Zpatchable-function-entry"),
        (&["-Zmin-function-alignment=64"], "-Zmin-function-alignment"),
        (&["-Zstack-protector=strong"], "-Zstack-protector"),
        (&["-Zretpoline"], "-Zretpoline"),
        (&["-Zretpoline-external-thunk"], "-Zretpoline-external-thunk"),
        (&["-Zfunction-return=thunk-extern"], "-Zfunction-return"),
        (&["-Zindirect-branch-cs-prefix"], "-Zindirect-branch-cs-prefix"),
        (&["--target=aarch64-unknown-linux-gnu"], "x86_64"),
        (&["--target=x86_64-unknown-linux-gnux32"], "x86_64"),
        // Soft-float: floats in GPRs, and no SSE for the handlers.
        (&["-Ctarget-feature=+soft-float"], "soft-float"),
        (&["-Ctarget-feature=-sse2"], "sse2"),
        // Autodiff (Enzyme) and offload run in cg_llvm on its own modules only.
        (&["-Zautodiff=Enable"], "-Zautodiff"),
        (&["-Zoffload=Test"], "-Zoffload"),
        (&["-Ccode-model=large"], "code model"),
        (&["-Ccode-model=medium"], "code model"),
        (&["-Ccode-model=kernel"], "code model"),
    ];
    for &(flags, needle) in cases {
        expect_reject(cmd(rustc_ryo).arg("--edition=2024").arg(src).args(flags).arg("-o").arg(&o), needle)?;
    }
    // Targets without an installed std, checked on a `#![no_core]` crate (`init` runs before
    // crates are loaded): soft-float, and sanitizers the target enables by default.
    let no_core = dir.join("no_core.rs");
    fs::write(&no_core, "#![feature(no_core)]\n#![no_core]\n").map_err(|e| format!("writing {}: {e}", no_core.display()))?;
    for (target, needle) in
        [("x86_64-unknown-none", "soft-float"), ("x86_64-unknown-uefi", "soft-float"), ("x86_64-unknown-linux-gnuasan", "sanitizer")]
    {
        expect_reject(cmd(rustc_ryo).arg("--crate-type=lib").arg(format!("--target={target}")).arg(&no_core).arg("--out-dir").arg(&dir), needle)?;
    }
    // PE for MinGW (the import rules assume MSVC's linkers).
    for target in ["x86_64-pc-windows-gnu", "x86_64-pc-windows-gnullvm"] {
        expect_reject(
            cmd(rustc_ryo).arg("--crate-type=lib").arg(format!("--target={target}")).arg(&no_core).arg("--out-dir").arg(&dir),
            "windows-msvc",
        )?;
    }
    // A target JSON's code model, with no `-Ccode-model`.
    let spec = output(cmd("rustc").args(["-Zunstable-options", "--print=target-spec-json", "--target=x86_64-unknown-linux-gnu"]))?;
    let Some(spec) = spec.trim_start().strip_prefix('{') else { return Err(format!("unexpected target spec: {spec}")) };
    let json = dir.join("x86_64-large.json");
    fs::write(&json, format!("{{\n  \"code-model\": \"large\",{spec}")).map_err(|e| format!("writing {}: {e}", json.display()))?;
    expect_reject(
        cmd(rustc_ryo)
            .args(["--crate-type=lib", "-Zunstable-options"])
            .arg(format!("--target={}", json.display()))
            .arg(&no_core)
            .arg("--out-dir")
            .arg(&dir),
        "code model",
    )?;
    // A library with VM code (`hello.rs`'s `main` is dead code in an rlib). An rlib is
    // written only with `link`, and one written to stdout can't have the images appended.
    let lib = dir.join("reject_lib.rs");
    fs::write(&lib, "pub fn f(x: u64) -> u64 {\n    x * 3 + 1\n}\n").map_err(|e| format!("writing {}: {e}", lib.display()))?;
    let rlib = |flags: &[&str]| {
        let mut c = cmd(rustc_ryo);
        c.arg("--edition=2024").arg(&lib).arg("--crate-type=rlib").arg("--out-dir").arg(&dir).args(flags);
        c
    };
    crate::utils::run(&mut rlib(&[]))?;
    for emit in ["--emit=asm", "--emit=llvm-ir", "--emit=mir"] {
        expect_reject(&mut rlib(&[emit]), "without `link`")?;
    }
    expect_reject(&mut rlib(&["-o", "-"]), "-o -")?;
    Ok(())
}

/// [`tests/vm_cgu_owner.rs`](../../../tests/vm_cgu_owner.rs) at 16 codegen units: it prints
/// what plain rustc's build prints, defines its static `b::COUNTER` once, and doesn't define
/// `b::helper`, which only a block unreachable after monomorphization calls (ELF and Mach-O,
/// `llvm-nm`).
pub(super) fn cgu_ownership(info: &crate::utils::RustcInfo, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let dir = out.join("cgu-ownership");
    crate::utils::create_dir(&dir)?;
    let mut outputs = Vec::new();
    for (who, compiler) in [("rustc", Path::new("rustc")), ("ryo", rustc_ryo)] {
        let exe = dir.join(exe_name(who));
        crate::utils::run(cmd(compiler).args(["--edition=2024", "-Ccodegen-units=16", "--crate-name=vm_cgu_owner"]).arg(src).arg("-o").arg(&exe))?;
        outputs.push(output(&mut cmd(&exe))?);
        if who == "ryo" && !cfg!(windows) {
            let syms = output(cmd(info.tool("llvm-nm")).args(["--defined-only", "-j"]).arg(&exe))?;
            let count = |name: &str| syms.lines().filter(|s| s.ends_with(name) && s.contains("12vm_cgu_owner")).count();
            let (counter, helper) = (count("1b7COUNTER"), count("1b6helper"));
            if counter != 1 || helper != 0 {
                return Err(format!("{}: b::COUNTER defined {counter} times (want 1), b::helper {helper} times (want 0)", exe.display()));
            }
        }
    }
    if outputs[0] != outputs[1] {
        return Err(format!("output {:?}, plain rustc's {:?}", outputs[1], outputs[0]));
    }
    Ok(())
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
