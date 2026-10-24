//! `y build --sysroot ryo`: std built from `rust-src` with the ryo backend
//! (design/build.md#build, "Sysroot").
//!
//! The library workspace is copied to `target/sysroot-ryo/library` and built with cargo, with
//! `y` itself as `RUSTC` ([`shim`]): it compiles `core`, `compiler_builtins`, `ryo_rt` and the
//! crates between them with plain rustc (LLVM), and everything else with `rustc-ryo`. `ryo_rt`
//! is part of that build (a `#![no_std]` crate on `core`), and the copy makes `alloc` and
//! `rustc-std-workspace-core` depend on it, so it is built before any crate that needs it and
//! `rustc-ryo`'s `--extern force:ryo_rt` finds it in cargo's `deps` directory.

use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};

use crate::dist::{copy, copy_dir};
use crate::utils::{RustcInfo, cmd, exe_name, root, run};

/// The environment variable that turns `y` into the `RUSTC` of the sysroot build. Its value is
/// the path of `rustc-ryo`.
pub const SHIM_VAR: &str = "RYO_Y_SYSROOT_SHIM";

/// Crates the sysroot build compiles with plain rustc: `ryo_rt` and everything it depends on
/// (they are below it in the crate graph, so they can't use it), the facade crate re-exporting
/// `core`, and build scripts.
const NATIVE_CRATES: &[&str] = &["core", "compiler_builtins", "rustc_std_workspace_core", "ryo_rt", "ryo_bytecode", "build_script_build"];

/// The sysroot directory inside `dist/` (`rustc-ryo --sysroot ryo` selects it).
pub const SYSROOT_DIR: &str = "sysroot-ryo";

/// Where the shim leaves each ryo-built crate's `RYO_STATS` summary (`<crate>.txt`).
pub const STATS_DIR_VAR: &str = "RYO_Y_SYSROOT_STATS";

/// `RUSTC` of the sysroot build: picks plain rustc or `rustc-ryo` by `--crate-name`. For
/// `rustc-ryo`, it collects the backend's `RYO_STATS=2` lines (design/backend.md#debugging-switches)
/// into a file per crate in [`STATS_DIR_VAR`], and passes everything else through.
pub fn shim(rustc_ryo: OsString) -> std::process::ExitCode {
    use std::io::{BufRead, Write};
    let args: Vec<OsString> = std::env::args_os().skip(1).collect();
    let name = args.iter().position(|a| a == "--crate-name").and_then(|i| args.get(i + 1)).and_then(|n| n.to_str());
    let fail = |program: &OsString, e: std::io::Error| {
        eprintln!("error: running {}: {e}", program.to_string_lossy());
        std::process::ExitCode::FAILURE
    };
    let exit = |s: std::process::ExitStatus| std::process::ExitCode::from(s.code().unwrap_or(1).clamp(0, 255) as u8);
    let (Some(name), Some(stats_dir)) = (name.filter(|n| is_ryo_crate(n)), std::env::var_os(STATS_DIR_VAR)) else {
        let rustc = OsString::from("rustc");
        let program = if name.is_some_and(is_ryo_crate) { &rustc_ryo } else { &rustc };
        return match cmd(program).args(&args).status() {
            Ok(s) => exit(s),
            Err(e) => fail(program, e),
        };
    };
    let mut child = match cmd(&rustc_ryo).args(&args).env("RYO_STATS", "2").stderr(std::process::Stdio::piped()).spawn() {
        Ok(c) => c,
        Err(e) => return fail(&rustc_ryo, e),
    };
    let mut stats = Vec::new();
    let stderr = std::io::stderr();
    for line in std::io::BufReader::new(child.stderr.take().unwrap()).split(b'\n') {
        let Ok(line) = line else { break };
        if line.starts_with(b"ryo: ") {
            stats.extend_from_slice(&line);
            stats.push(b'\n');
        } else {
            let mut e = stderr.lock();
            let _ = e.write_all(&line);
            let _ = e.write_all(b"\n");
        }
    }
    let status = match child.wait() {
        Ok(s) => s,
        Err(e) => return fail(&rustc_ryo, e),
    };
    // Each crate is compiled once per build (crate types share one compilation).
    let _ = fs::create_dir_all(&stats_dir);
    let _ = fs::write(Path::new(&stats_dir).join(format!("{name}.txt")), stats);
    exit(status)
}

fn is_ryo_crate(name: &str) -> bool {
    !NATIVE_CRATES.contains(&name) && !name.starts_with("build_script_")
}

/// Builds std with the ryo backend for the host and installs it, with `ryo_rt`, into
/// `dist/sysroot-ryo` (with the toolchain's `bin/`, for `rust-lld`). `dist/` must already hold
/// the backend and `rustc-ryo`. With `jit`, the sealed JIT's directory
/// ([`crate::jit::build`]), `ryo_rt` gets its `jit` feature and bundles it, as in `dist/`: the
/// JIT has a std of its own, the native one, so it never enters this sysroot's VM code.
pub fn build(info: &RustcInfo, dist: &Path, jit: Option<&Path>) -> Result<(), String> {
    eprintln!("[y] sysroot: std with the ryo backend");
    let root = root();
    let work = root.join("target").join("sysroot-ryo");
    let lib_src = work.join("library");
    prepare_sources(info, &root, &lib_src, jit.is_some())?;

    let rustc_ryo = dist.join("bin").join(exe_name("rustc-ryo"));
    let me = std::env::current_exe().map_err(|e| format!("current_exe: {e}"))?;
    let target_dir = work.join("build");
    let stats_dir = work.join("stats");
    // Cargo doesn't fingerprint the backend: a new one rebuilds everything, from a clean
    // directory (old `ryo_rt`s next to the new one would make `--extern force:ryo_rt` ambiguous).
    let stamp = backend_stamp(dist)?;
    let stamp_file = work.join(".ryo-backend");
    if fs::read_to_string(&stamp_file).ok() != Some(stamp.to_string()) {
        for dir in [&target_dir, &stats_dir] {
            if dir.exists() {
                fs::remove_dir_all(dir).map_err(|e| format!("removing {}: {e}", dir.display()))?;
            }
        }
    }
    let deps = target_dir.join(&info.host).join("release").join("deps");
    // `--extern force:ryo_rt` has no path: rustc looks for it in `crate` search paths, and
    // cargo's `-L dependency=` isn't one.
    let mut crate_path = String::from("-Lcrate=");
    crate_path.push_str(deps.to_str().ok_or("non-UTF-8 target path")?);
    let rustflags = [
        crate_path.as_str(),
        "-Zforce-unstable-if-unmarked",
        "--sysroot=/dev/null",
        // Like the prebuilt std, for users' `-Clto`.
        "-Cembed-bitcode=yes",
    ];
    let mut cargo = cmd("cargo");
    if let Some(dir) = jit {
        cargo.env("RYO_JIT_LIB_DIR", dir);
    }
    run(cargo
        .current_dir(&lib_src)
        .args(["build", "--release", "--offline", "-p", "sysroot", "--features", "backtrace panic-unwind"])
        .args(["--target", &info.host])
        .arg("--target-dir")
        .arg(&target_dir)
        .env("RUSTC", &me)
        .env(SHIM_VAR, &rustc_ryo)
        .env(STATS_DIR_VAR, &stats_dir)
        .env_remove("RUSTC_WRAPPER")
        .env_remove("RUSTFLAGS")
        .env("CARGO_ENCODED_RUSTFLAGS", rustflags.join("\x1f"))
        .env("CARGO_PROFILE_RELEASE_DEBUG", "0")
        .env("CARGO_BUILD_INCREMENTAL", "false")
        // Stable `-Cmetadata` hashes, distinct from the prebuilt std's (as cg_clif does).
        .env("__CARGO_DEFAULT_LIB_METADATA", "ryo")
        .env("RUSTUP_TOOLCHAIN", &info.toolchain))?;
    fs::write(&stamp_file, stamp.to_string()).map_err(|e| e.to_string())?;

    let sysroot = dist.join(SYSROOT_DIR);
    if sysroot.exists() {
        fs::remove_dir_all(&sysroot).map_err(|e| format!("removing {}: {e}", sysroot.display()))?;
    }
    let rel = Path::new("lib").join("rustlib").join(&info.host);
    let dst_lib = sysroot.join(&rel).join("lib");
    fs::create_dir_all(&dst_lib).map_err(|e| format!("creating {}: {e}", dst_lib.display()))?;
    let mut n = 0;
    for entry in fs::read_dir(&deps).map_err(|e| format!("{}: {e}", deps.display()))? {
        let path = entry.map_err(|e| e.to_string())?.path();
        let name = path.file_name().and_then(|n| n.to_str()).unwrap_or("");
        let ext = path.extension().and_then(|e| e.to_str()).unwrap_or("");
        // `libsysroot` is the build's dummy root crate.
        if name.starts_with("lib") && !name.starts_with("libsysroot-") && matches!(ext, "rlib" | "rmeta" | "so" | "dll" | "lib") {
            copy(&path, &dst_lib.join(name))?;
            n += 1;
        }
    }
    let src_bin = info.sysroot.join(&rel).join("bin");
    if src_bin.is_dir() {
        copy_dir(&src_bin, &sysroot.join(&rel).join("bin"))?;
    }
    eprintln!("[y] sysroot: {n} files in {}", sysroot.display());
    print_coverage(&stats_dir)
}

/// Prints the coverage of the ryo-built sysroot crates from their `RYO_STATS` summaries: VM
/// and native functions and islands per crate, then the island templates and native reasons
/// over all of them.
fn print_coverage(stats_dir: &Path) -> Result<(), String> {
    let Ok(entries) = fs::read_dir(stats_dir) else {
        eprintln!("[y] sysroot: no coverage statistics (every crate was up to date)");
        return Ok(());
    };
    let mut files: Vec<PathBuf> = entries.flatten().map(|e| e.path()).collect();
    files.sort();
    let mut templates: Vec<(String, u64)> = Vec::new();
    let mut reasons: Vec<(String, u64)> = Vec::new();
    let add = |list: &mut Vec<(String, u64)>, key: &str, n: u64| match list.iter_mut().find(|(k, _)| k == key) {
        Some(e) => e.1 += n,
        None => list.push((key.to_owned(), n)),
    };
    let (mut vm, mut native, mut islands) = (0u64, 0u64, 0u64);
    eprintln!("[y] sysroot coverage (RYO_STATS):");
    eprintln!("    {:<28} {:>8} {:>8} {:>8} {:>8}", "crate", "vm fns", "native", "vm %", "islands");
    for f in &files {
        let text = fs::read_to_string(f).map_err(|e| e.to_string())?;
        let krate = f.file_stem().and_then(|s| s.to_str()).unwrap_or("?");
        for line in text.lines() {
            if let Some(rest) = line.strip_prefix("ryo: ")
                && let Some((v, rest)) = rest.split_once(" VM functions, ")
                && let Some((n, rest)) = rest.split_once(" native functions, ")
                && let Some((i, _)) = rest.split_once(" islands")
            {
                let (v, n, i): (u64, u64, u64) = (v.parse().unwrap_or(0), n.parse().unwrap_or(0), i.parse().unwrap_or(0));
                vm += v;
                native += n;
                islands += i;
                eprintln!("    {krate:<28} {v:>8} {n:>8} {:>7.1}% {i:>8}", percent(v, v + n));
            } else if let Some(rest) = line.strip_prefix("ryo: island ")
                && let Some((t, rest)) = rest.split_once(": ")
                && let Some((n, _)) = rest.split_once(' ')
            {
                add(&mut templates, t, n.parse().unwrap_or(0));
            } else if let Some(rest) = line.strip_prefix("ryo: native reason: ")
                && let Some((n, why)) = rest.split_once(' ')
            {
                add(&mut reasons, why, n.parse().unwrap_or(0));
            }
        }
    }
    eprintln!("    {:<28} {vm:>8} {native:>8} {:>7.1}% {islands:>8}", "total", percent(vm, vm + native));
    templates.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    reasons.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    eprintln!("    island instructions by template:");
    for (t, n) in &templates {
        eprintln!("      {n:>8} {t}");
    }
    eprintln!("    native functions by reason:");
    for (why, n) in &reasons {
        eprintln!("      {n:>8} {why}");
    }
    Ok(())
}

fn percent(part: u64, whole: u64) -> f64 {
    if whole == 0 { 0.0 } else { 100.0 * part as f64 / whole as f64 }
}

/// Copies `rust-src`'s `library/` to `dst` (once per toolchain, so cargo's fingerprints
/// survive rebuilds), and adds `ryo_rt` to it, with its `jit` feature if `jit`.
fn prepare_sources(info: &RustcInfo, root: &Path, dst: &Path, jit: bool) -> Result<(), String> {
    let src = info.sysroot.join("lib").join("rustlib").join("src").join("rust").join("library");
    if !src.is_dir() {
        return Err("no `rust-src` in the toolchain; run `rustup component add rust-src`".to_owned());
    }
    let stamp = dst.join(".ryo-source");
    let want = src.to_string_lossy().into_owned();
    if fs::read_to_string(&stamp).ok().as_deref() != Some(want.as_str()) {
        if dst.exists() {
            fs::remove_dir_all(dst).map_err(|e| format!("removing {}: {e}", dst.display()))?;
        }
        copy_dir(&src, dst)?;
        fs::write(&stamp, &want).map_err(|e| e.to_string())?;
    }
    // `ryo_rt` and `ryo_bytecode` as members of the library workspace, on its `core`.
    let vm = root.join("vm");
    let path = |p: PathBuf| p.to_str().map(|s| format!("{s:?}")).ok_or("non-UTF-8 path".to_owned());
    write_if_changed(
        &dst.join("ryo_bytecode").join("Cargo.toml"),
        &format!(
            "[package]\nname = \"ryo_bytecode\"\nversion = \"0.1.0\"\nedition = \"2024\"\n\n\
             [lib]\npath = {}\ntest = false\nbench = false\ndoc = false\n\n\
             [dependencies]\ncore = {{ path = \"../core\" }}\ncompiler_builtins = {{ path = \"../compiler-builtins/compiler-builtins\", features = [\"compiler-builtins\"] }}\n\n[features]\nalloc = []\n",
            path(vm.join("bytecode").join("src").join("lib.rs"))?,
        ),
    )?;
    write_if_changed(
        &dst.join("ryo_rt").join("Cargo.toml"),
        &format!(
            "[package]\nname = \"ryo_rt\"\nversion = \"0.1.0\"\nedition = \"2024\"\nbuild = {}\n\n\
             [lib]\npath = {}\ntest = false\nbench = false\ndoc = false\n\n\
             [dependencies]\ncore = {{ path = \"../core\" }}\ncompiler_builtins = {{ path = \"../compiler-builtins/compiler-builtins\", features = [\"compiler-builtins\"] }}\n\
             ryo_bytecode = {{ path = \"../ryo_bytecode\" }}\n\n[features]\njit = []\n",
            path(vm.join("rt").join("build.rs"))?,
            path(vm.join("rt").join("src").join("lib.rs"))?,
        ),
    )?;
    // The crates directly on `core` that the ryo backend builds depend on `ryo_rt` through
    // these two (everything else in the sysroot depends on one of them).
    let dep = if jit { "ryo_rt = { path = \"../ryo_rt\", features = [\"jit\"] }\n" } else { "ryo_rt = { path = \"../ryo_rt\" }\n" };
    for krate in ["alloc", "rustc-std-workspace-core"] {
        let manifest = dst.join(krate).join("Cargo.toml");
        let text = fs::read_to_string(src.join(krate).join("Cargo.toml")).map_err(|e| e.to_string())?;
        let patched = text.replacen("[dependencies]\n", &format!("[dependencies]\n{dep}"), 1);
        if patched == text {
            return Err(format!("{}: no [dependencies] section", manifest.display()));
        }
        write_if_changed(&manifest, &patched)?;
    }
    Ok(())
}

/// A hash of `dist/`'s backend's contents (`y build` copies it fresh each time, so its
/// modification time always changes).
fn backend_stamp(dist: &Path) -> Result<u64, String> {
    use std::hash::Hasher;
    let backend = dist.join("lib").join(crate::utils::dll_name("rustc_codegen_ryo"));
    let bytes = fs::read(&backend).map_err(|e| format!("{}: {e}", backend.display()))?;
    // `DefaultHasher::new` uses fixed keys, so the hash is stable across runs.
    let mut h = std::hash::DefaultHasher::new();
    h.write(&bytes);
    Ok(h.finish())
}

fn write_if_changed(path: &Path, text: &str) -> Result<(), String> {
    if fs::read_to_string(path).ok().as_deref() == Some(text) {
        return Ok(());
    }
    if let Some(dir) = path.parent() {
        fs::create_dir_all(dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
    }
    fs::write(path, text).map_err(|e| format!("writing {}: {e}", path.display()))
}
