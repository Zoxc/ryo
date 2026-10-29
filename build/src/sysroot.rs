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

use crate::utils::{RustcInfo, cmd, exe_name, root, run};
use crate::utils::{copy, copy_dir};

/// The environment variable that turns `y` into the `RUSTC` of the sysroot build. Its value is
/// the path of `rustc-ryo`.
pub const SHIM_VAR: &str = "RYO_Y_SYSROOT_SHIM";

/// Crates the sysroot build compiles with plain rustc: `ryo_rt` and everything it depends on
/// (they are below it in the crate graph, so they can't use it), the facade crate re-exporting
/// `core`, `windows_link` (a `no_core` crate of macros, which depends on nothing, so not on
/// `ryo_rt` either), and build scripts.
const NATIVE_CRATES: &[&str] =
    &["core", "compiler_builtins", "rustc_std_workspace_core", "windows_link", "ryo_rt", "ryo_bytecode", "build_script_build"];

/// The sysroot directory inside `dist/` (`rustc-ryo --sysroot ryo` selects it).
pub const SYSROOT_DIR: &str = "sysroot-ryo";

/// The stamp of `dist/sysroot-ryo`'s inputs, next to it in `dist/` ([`ryo_sysroot_status`]).
pub const STAMP_FILE: &str = "sysroot-ryo.stamp";

/// Whether `dist/sysroot-ryo` is there and built from the current inputs.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SysrootStatus {
    Missing,
    /// Built from other inputs; the reason names the first one that differs.
    Stale(String),
    Current,
}

/// Checks `dist/sysroot-ryo` against its stamp: the backend in `dist/`, the runtime's sources
/// (`ryo_rt`, `ryo_bytecode` and the bundled JIT, as the ABI tag hashes them), the `rust-src` it is built from and how it
/// is patched, and the rustc version. Doesn't check that `dist/`'s backend is current.
pub fn ryo_sysroot_status(info: &RustcInfo, dist: &Path) -> SysrootStatus {
    if !dist.join(SYSROOT_DIR).is_dir() {
        return SysrootStatus::Missing;
    }
    let Ok(have) = fs::read_to_string(dist.join(STAMP_FILE)) else {
        return SysrootStatus::Stale(format!("no {STAMP_FILE}"));
    };
    let want = match stamp(info, &root(), dist, crate::jit::supported(&info.host)) {
        Ok(s) => s,
        Err(e) => return SysrootStatus::Stale(e),
    };
    for line in want.lines() {
        let key = line.split_once('=').map_or(line, |(k, _)| k);
        if !have.lines().any(|l| l == line) {
            return SysrootStatus::Stale(format!("{key} changed"));
        }
    }
    if have.lines().count() != want.lines().count() { SysrootStatus::Stale("stamp format changed".to_owned()) } else { SysrootStatus::Current }
}

/// The inputs of the ryo sysroot, a `key=value` line each. `jit`: whether `ryo_rt` bundles
/// the JIT (as [`build`] gets it).
fn stamp(info: &RustcInfo, root: &Path, dist: &Path, jit: bool) -> Result<String, String> {
    use std::hash::Hasher;
    // The runtime's sources even when `RYO_ABI_OVERRIDE` fixes `abi=`.
    let vm = crate::dist::runtime_hash(root)?;
    // `prepare_sources` (how the library is patched) and the build's flags are in this file.
    let mut y = std::hash::DefaultHasher::new();
    y.write(include_str!("sysroot.rs").as_bytes());
    let src = info.rust_src_library();
    Ok(format!(
        "rustc={:x}\nrust-src={}\nbackend={:x}\nvm={:x}\ny={:x}\njit={jit}\nabi={}\n",
        {
            let mut h = std::hash::DefaultHasher::new();
            h.write(info.version.as_bytes());
            h.finish()
        },
        src.display(),
        backend_stamp(dist)?,
        vm,
        y.finish(),
        crate::dist::dist_abi_tag(dist)?,
    ))
}

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
        let mut c = cmd(program);
        c.args(&args);
        // The runtime crates' identity carries the ABI tag, as in `dist/`
        // (design/build.md#the-abi-tag).
        if let (Some("ryo_rt" | "ryo_bytecode"), Ok(tag)) = (name, std::env::var(crate::dist::ABI_VAR)) {
            c.arg(format!("-Cmetadata={tag}"));
        }
        return match c.status() {
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
/// JIT has a std of its own, the native one, so it never enters this sysroot's VM code. The
/// second directory is the checked JIT's, swapped into a copy of `ryo_rt` in
/// `sysroot-ryo/jit-checked/` as for `dist/`.
/// `target`: cargo's target directory (the work directory is `<target>/sysroot-ryo`).
pub fn build(info: &RustcInfo, dist: &Path, target: &Path, jit: Option<(&Path, &Path)>) -> Result<(), String> {
    let (jit, checked) = (jit.map(|j| j.0), jit.map(|j| j.1));
    eprintln!("[y] sysroot: std with the ryo backend");
    let root = root();
    let work = target.join("sysroot-ryo");
    let lib_src = work.join("library");
    let inputs = stamp(info, &root, dist, jit.is_some())?;
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
            crate::utils::remove_dir_if_exists(dir)?;
        }
    }
    let deps = target_dir.join(&info.host).join("release").join("deps");
    // `--extern force:ryo_rt` has no path: rustc looks for it in `crate` search paths, and
    // cargo's `-L dependency=` isn't one.
    let mut crate_path = String::from("-Lcrate=");
    crate_path.push_str(deps.to_str().ok_or("non-UTF-8 target path")?);
    let rustflags = [crate_path.as_str(), "-Zforce-unstable-if-unmarked", "--sysroot=/dev/null"];
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
    crate::utils::write(&stamp_file, stamp.to_string())?;

    let sysroot = dist.join(SYSROOT_DIR);
    // No stamp while the sysroot is replaced; `inputs` was taken before the build, so input
    // changes during it leave the result stale.
    let _ = fs::remove_file(dist.join(STAMP_FILE));
    crate::utils::remove_dir_if_exists(&sysroot)?;
    let dst_lib = crate::utils::rustlib(&sysroot, &info.host).join("lib");
    crate::utils::create_dir(&dst_lib)?;
    let mut n = 0;
    for entry in fs::read_dir(&deps).map_err(|e| format!("{}: {e}", deps.display()))? {
        let path = entry.map_err(|e| e.to_string())?.path();
        let name = path.file_name().and_then(|n| n.to_str()).unwrap_or("");
        let ext = path.extension().and_then(|e| e.to_str()).unwrap_or("");
        // `libsysroot` is the build's dummy root crate.
        if name.starts_with("lib") && !name.starts_with("libsysroot-") && matches!(ext, "rlib" | "rmeta" | "so" | "dll" | "lib") {
            copy(&path, &dst_lib.join(name))?;
            if let Some(sealed) = checked
                && name.starts_with("libryo_rt-")
                && ext == "rlib"
            {
                crate::jit::swap_into_rlib(info, &dst_lib.join(name), sealed, &sysroot.join(crate::jit::CHECKED_DIR))?;
            }
            n += 1;
        }
    }
    crate::utils::copy_target_bin(&info.sysroot, &sysroot, &info.host)?;
    crate::utils::write(dist.join(STAMP_FILE), &inputs)?;
    eprintln!("[y] sysroot: {n} files in {}", sysroot.display());
    print_coverage(&stats_dir)
}

/// Prints the coverage of the ryo-built sysroot crates from their `RYO_STATS` summaries: VM
/// and native functions and islands per crate, then the island templates and native reasons
/// over all of them.
fn print_coverage(stats_dir: &Path) -> Result<(), String> {
    use crate::crates::ryo_stats::{Coverage, coverage_of_lines};
    let Ok(entries) = fs::read_dir(stats_dir) else {
        eprintln!("[y] sysroot: no coverage statistics (every crate was up to date)");
        return Ok(());
    };
    let mut files: Vec<PathBuf> = entries.flatten().map(|e| e.path()).collect();
    files.sort();
    let mut texts = Vec::new();
    for f in &files {
        texts.push((f.file_stem().and_then(|s| s.to_str()).unwrap_or("?"), crate::utils::read(f)?));
    }
    let row = |name: &str, c: &Coverage| eprintln!("    {name:<28} {:>8} {:>8} {:>7.1}% {:>8}", c.vm, c.native, c.vm_percent(), c.islands);
    eprintln!("[y] sysroot coverage (RYO_STATS):");
    eprintln!("    {:<28} {:>8} {:>8} {:>8} {:>8}", "crate", "vm fns", "native", "vm %", "islands");
    let mut all: Vec<&str> = Vec::new();
    for (krate, text) in &texts {
        let lines: Vec<&str> = text.lines().filter_map(|l| l.strip_prefix("ryo: ")).collect();
        row(krate, &coverage_of_lines(lines.iter().copied()));
        all.extend(lines);
    }
    let total = coverage_of_lines(all);
    row("total", &total);
    eprintln!("    island instructions by template:");
    for (t, n) in &total.templates {
        eprintln!("      {n:>8} {t}");
    }
    eprintln!("    native functions by reason:");
    for (why, n) in &total.reasons {
        eprintln!("      {n:>8} {why}");
    }
    Ok(())
}

/// Copies `rust-src`'s `library/` to `dst` (once per toolchain and version, so cargo's fingerprints
/// survive rebuilds), and adds `ryo_rt` to it, with its `jit` feature if `jit`.
fn prepare_sources(info: &RustcInfo, root: &Path, dst: &Path, jit: bool) -> Result<(), String> {
    let src = info.rust_src_library();
    if !src.is_dir() {
        return Err("no `rust-src` in the toolchain; run `rustup component add rust-src`".to_owned());
    }
    let stamp = dst.join(".ryo-source");
    // The rustc version too: updating a channel toolchain in place keeps the path.
    let want = format!("{}\n{}", src.to_string_lossy(), info.version);
    if fs::read_to_string(&stamp).ok().as_deref() != Some(want.as_str()) {
        crate::utils::remove_dir_if_exists(dst)?;
        copy_dir(&src, dst)?;
        crate::utils::write(&stamp, &want)?;
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
        let text = crate::utils::read(src.join(krate).join("Cargo.toml"))?;
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
        crate::utils::create_dir(dir)?;
    }
    crate::utils::write(path, text)
}
