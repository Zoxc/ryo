//! `y build --sysroot ryo`: std built from `rust-src` with the ryo backend
//! (design/build.md#build, "Sysroot").
//!
//! The library workspace is copied to `out/target/sysroot-ryo/library` and built with cargo, with
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

/// The sysroot directory inside `out/dist/` (`rustc-ryo --sysroot ryo` selects it).
pub const SYSROOT_DIR: &str = "sysroot-ryo";

/// The stamp of `out/dist/sysroot-ryo`'s inputs, next to it in `out/dist/` ([`ryo_sysroot_status`]).
pub const STAMP_FILE: &str = "sysroot-ryo.stamp";

/// Whether `out/dist/sysroot-ryo` is there and built from the current inputs.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SysrootStatus {
    Missing,
    /// Built from other inputs; the reason names the first one that differs.
    Stale(String),
    Current,
}

/// Checks `out/dist/sysroot-ryo` against its stamp: the backend in `out/dist/`, the runtime's sources
/// (`ryo_rt`, `ryo_bytecode` and the bundled JIT, as the ABI tag hashes them), the `rust-src` it is built from and how it
/// is patched, and the rustc version. Doesn't check that `out/dist/`'s backend is current.
pub fn ryo_sysroot_status(info: &RustcInfo, dist: &Path) -> SysrootStatus {
    if !dist.join(SYSROOT_DIR).is_dir() {
        return SysrootStatus::Missing;
    }
    let Ok(have) = fs::read_to_string(dist.join(STAMP_FILE)) else {
        return SysrootStatus::Stale(format!("no {STAMP_FILE}"));
    };
    let want = match stamp(info, &root(), dist) {
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

/// The inputs of the ryo sysroot, a `key=value` line each.
fn stamp(info: &RustcInfo, root: &Path, dist: &Path) -> Result<String, String> {
    use crate::utils::hash_bytes;
    // The runtime's sources even when `RYO_ABI_OVERRIDE` fixes `abi=`.
    let vm = crate::dist::runtime_hash(root)?;
    let src = info.rust_src_library();
    Ok(format!(
        "rustc={:x}\nrust-src={}\nbackend={:x}\nvm={:x}\ny={:x}\nabi={}\n",
        hash_bytes(info.version.as_bytes()),
        src.display(),
        backend_stamp(dist)?,
        vm,
        // `prepare_sources` (how the library is patched) and the build's flags are in this file.
        hash_bytes(include_str!("sysroot.rs").as_bytes()),
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
    let exit = |s: std::process::ExitStatus| std::process::ExitCode::from(s.code().and_then(|c| u8::try_from(c).ok()).unwrap_or(1));
    // `___` is cargo's target-info probe (`--print`), which compiles nothing.
    let (Some(name), Some(stats_dir)) = (name.filter(|&n| is_ryo_crate(n) && n != "___"), std::env::var_os(STATS_DIR_VAR)) else {
        let rustc = OsString::from("rustc");
        let program = if name.is_some_and(is_ryo_crate) { &rustc_ryo } else { &rustc };
        let mut c = cmd(program);
        c.args(&args);
        // The runtime crates' identity carries the ABI tag, as in `out/dist/`
        // (design/build.md#the-abi-tag).
        if let (Some(n), Ok(tag)) = (name, std::env::var(crate::dist::ABI_VAR))
            && crate::dist::RUNTIME_CRATES.contains(&n)
        {
            c.arg(crate::dist::runtime_metadata_flag(&tag));
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
/// `out/dist/sysroot-ryo` (with the toolchain's `bin/`, for `rust-lld`). `out/dist/` must already hold
/// the backend and `rustc-ryo`. `ryo_rt` bundles the release JIT of `jits`, as in
/// `out/dist/`: the JIT has a std of its own, the native one, so it never
/// enters this sysroot's VM code. The checked JIT is swapped into a copy of `ryo_rt` in
/// `sysroot-ryo/jit-checked/` as for `out/dist/`.
/// `target`: cargo's target directory (the work directory is `<target>/sysroot-ryo`).
pub fn build(info: &RustcInfo, dist: &Path, target: &Path, jits: &crate::jit::SealedJits) -> Result<(), String> {
    let (jit, checked) = (jits.release.as_path(), jits.checked.as_path());
    eprintln!("[y] sysroot: std with the ryo backend");
    let root = root();
    let work = target.join("sysroot-ryo");
    let lib_src = work.join("library");
    let inputs = stamp(info, &root, dist)?;
    prepare_sources(info, &root, &lib_src)?;

    let rustc_ryo = dist.join("bin").join(exe_name("rustc-ryo"));
    let me = std::env::current_exe().map_err(|e| format!("current_exe: {e}"))?;
    let target_dir = work.join("build");
    let stats_dir = work.join("stats");
    // Cargo doesn't fingerprint the backend: a new one rebuilds everything, from a clean
    // directory (old `ryo_rt`s next to the new one would make `--extern force:ryo_rt` ambiguous).
    // So does a change of `ryo_rt`'s features, which `RYO_ABI_OVERRIDE` keeps out of the backend.
    let stamp = format!("{} {:?}", backend_stamp(dist)?, crate::dist::rt_features());
    let stamp_file = work.join(".ryo-backend");
    if fs::read_to_string(&stamp_file).ok().as_deref() != Some(stamp.as_str()) {
        for dir in [&target_dir, &stats_dir] {
            crate::utils::remove_dir_if_exists(dir)?;
        }
    }
    let deps = target_dir.join(&info.host).join("release").join("deps");
    // `--extern force:ryo_rt` has no path: rustc looks for it in `crate` search paths, and
    // cargo's `-L dependency=` isn't one.
    let mut crate_path = String::from("-Lcrate=");
    crate_path.push_str(deps.to_str().ok_or("non-UTF-8 target path")?);
    let mut rustflags = vec![crate_path.as_str(), "-Zforce-unstable-if-unmarked", "--sysroot=/dev/null"];
    // Windows: no red zone in `ryo_rt`'s `sysv64` handlers, as in `out/dist/` (design/platforms.md);
    // the rest of std is Win64 code, which has none anyway.
    if crate::target::is_windows(&info.host) {
        rustflags.push(crate::jit::NO_REDZONE);
    }
    let mut cargo = cmd("cargo");
    cargo.env(crate::dist::JIT_LIB_DIR_VAR, jit);
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
    crate::utils::write(&stamp_file, &stamp)?;

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
        // `libsysroot` is the build's dummy root crate. Windows dylibs and their import
        // libraries have no `lib` prefix (`std-<hash>.dll`, `std-<hash>.dll.lib`).
        let windows = matches!(ext, "dll" | "lib") && !name.starts_with("sysroot-");
        if (windows || name.starts_with("lib"))
            && !name.starts_with("libsysroot-")
            && matches!(ext, "rlib" | "rmeta" | "so" | "dylib" | "dll" | "lib")
        {
            copy(&path, &dst_lib.join(name))?;
            if name.starts_with("libryo_rt-") && ext == "rlib" {
                crate::jit::swap_into_rlib(info, &dst_lib.join(name), checked, &sysroot.join(crate::jit::CHECKED_DIR))?;
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
/// survive rebuilds), and adds `ryo_rt` to it.
fn prepare_sources(info: &RustcInfo, root: &Path, dst: &Path) -> Result<(), String> {
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
             ryo_bytecode = {{ path = \"../ryo_bytecode\" }}\n\n[features]\npe-test = []\n",
            path(vm.join("rt").join("build.rs"))?,
            path(vm.join("rt").join("src").join("lib.rs"))?,
        ),
    )?;
    // The crates directly on `core` that the ryo backend builds depend on `ryo_rt` through
    // these two (everything else in the sysroot depends on one of them).
    // What `RYO_RT_FEATURES` adds, as in `out/dist/`'s `ryo_rt`.
    let features: Vec<String> = crate::dist::rt_features().iter().map(|f| format!("{f:?}")).collect();
    let dep = format!("ryo_rt = {{ path = \"../ryo_rt\", features = [{}] }}\n", features.join(", "));
    patch_backtrace(&src, dst)?;
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

/// Patches std's copy of backtrace-rs so that both the panic hook's backtraces and
/// `std::backtrace::Backtrace` ask `ryo_rt` first for the frames of VM code
/// (design/vm.md#source-locations): `resolve`/`resolve_frame` call `ryo_bt_resolve` (std
/// depends on `ryo_rt` through `alloc`, so it is always linked), and fall back to the
/// platform symbolizer (gimli, dbghelp) for addresses that aren't VM code. Each frame it
/// reports becomes a symbol of its own, innermost first, as the platform symbolizer reports
/// inlined frames; one without a name takes the symbol at its AOT address. The symbolizers'
/// own `Symbol` becomes `ImpSymbol`, which `Symbol` wraps.
fn patch_backtrace(src: &Path, dst: &Path) -> Result<(), String> {
    let dir = Path::new("backtrace").join("src").join("symbolize");
    let tag = std::env::var(crate::dist::ABI_VAR).unwrap_or_else(|_| "dev".to_owned());
    let edit = |text: &str, from: &str, to: &str, what: &str| -> Result<String, String> {
        if !text.contains(from) {
            return Err(format!("rust-src {what}: no `{from}` to patch"));
        }
        Ok(text.replace(from, to))
    };
    for imp in ["gimli.rs", "dbghelp.rs", "miri.rs", "noop.rs"] {
        let text = crate::utils::read(src.join(&dir).join(imp))?;
        // `super::Symbol` as a whole path (not `super::SymbolName`).
        let mut patched = String::with_capacity(text.len() + 64);
        let mut rest = text.as_str();
        while let Some(i) = rest.find("super::Symbol") {
            let end = i + "super::Symbol".len();
            let whole = !rest[end..].starts_with(|c: char| c.is_alphanumeric() || c == '_');
            patched.push_str(&rest[..i]);
            patched.push_str(if whole { "super::ImpSymbol" } else { "super::Symbol" });
            rest = &rest[end..];
        }
        patched.push_str(rest);
        write_if_changed(&dst.join(&dir).join(imp), &patched)?;
    }
    let mut text = crate::utils::read(src.join(&dir).join("mod.rs"))?;
    text = edit(
        &text,
        "unsafe { imp::resolve(ResolveWhat::Address(addr), &mut cb) }",
        "unsafe { ryo_resolve(ResolveWhat::Address(addr), &mut cb) }",
        "mod.rs",
    )?;
    text = edit(
        &text,
        "unsafe { imp::resolve(ResolveWhat::Frame(frame), &mut cb) }",
        "unsafe { ryo_resolve(ResolveWhat::Frame(frame), &mut cb) }",
        "mod.rs",
    )?;
    text = edit(
        &text,
        "    inner: imp::Symbol<'static>,\n}",
        "    inner: SymInner,\n}\n\n/// What the platform symbolizer reports.\npub struct ImpSymbol {\n    inner: imp::Symbol<'static>,\n}",
        "mod.rs",
    )?;
    text.push_str(&BACKTRACE_HOOK.replace("@TAG@", &tag));
    write_if_changed(&dst.join(&dir).join("mod.rs"), &text)?;
    // A JIT frame's symbol address is its root's AOT entry, which `Backtrace::capture`
    // compares with its own address to trim its frames.
    let frame = Path::new("backtrace").join("src").join("backtrace").join("mod.rs");
    let text = crate::utils::read(src.join(&frame))?;
    let patched = edit(
        &text,
        "        self.inner.symbol_address()\n",
        "        super::symbolize::ryo_symbol_address(self.inner.symbol_address())\n",
        "backtrace/mod.rs",
    )?;
    write_if_changed(&dst.join(&frame), &patched)
}

/// Appended to backtrace-rs's `symbolize/mod.rs` by [`patch_backtrace`] (`@TAG@`: the ABI tag).
const BACKTRACE_HOOK: &str = r#"
// ---- ryo: VM frames from `ryo_rt` (patched in by `y build --sysroot ryo`) ----

/// A symbol: the platform symbolizer's (valid during its callback), or a VM frame's.
enum SymInner {
    Imp(*const ImpSymbol),
    Ryo(RyoSymbol),
}

/// A VM frame `ryo_rt` reported.
struct RyoSymbol {
    name: Option<crate::vec::Vec<u8>>,
    file: Option<&'static [u8]>,
    line: u32,
    col: u32,
    addr: *mut c_void,
}

impl SymInner {
    fn imp(&self) -> Option<&imp::Symbol<'static>> {
        match self {
            // SAFETY: only handed out during the symbolizer's callback.
            SymInner::Imp(s) => Some(unsafe { &(**s).inner }),
            SymInner::Ryo(_) => None,
        }
    }
    fn ryo(&self) -> Option<&RyoSymbol> {
        match self {
            SymInner::Ryo(r) => Some(r),
            SymInner::Imp(_) => None,
        }
    }
    fn name(&self) -> Option<SymbolName<'_>> {
        match self.ryo() {
            Some(r) => r.name.as_deref().map(SymbolName::new),
            None => self.imp()?.name(),
        }
    }
    fn addr(&self) -> Option<*mut c_void> {
        match self.ryo() {
            Some(r) => Some(r.addr),
            None => self.imp()?.addr(),
        }
    }
    fn filename_raw(&self) -> Option<BytesOrWideString<'_>> {
        match self.ryo() {
            Some(r) => r.file.map(BytesOrWideString::Bytes),
            None => self.imp()?.filename_raw(),
        }
    }
    fn colno(&self) -> Option<u32> {
        match self.ryo() {
            Some(r) => r.file.and((r.col != 0).then_some(r.col)),
            None => self.imp()?.colno(),
        }
    }
    fn lineno(&self) -> Option<u32> {
        match self.ryo() {
            Some(r) => r.file.map(|_| r.line),
            None => self.imp()?.lineno(),
        }
    }
    #[cfg(feature = "std")]
    #[allow(unreachable_code)]
    fn filename(&self) -> Option<&Path> {
        match self.ryo() {
            Some(r) => r.file.and_then(|f| str::from_utf8(f).ok()).map(Path::new),
            None => self.imp()?.filename(),
        }
    }
}

/// `ryo_rt::vm::backtrace::RyoFrame`.
#[repr(C)]
#[derive(Clone, Copy)]
struct RyoFrame {
    name: *const u8,
    name_len: usize,
    file: *const u8,
    file_len: usize,
    line: u32,
    col: u32,
    aot_pc: usize,
}

// `C-unwind` on `ryo_rt`'s side, which never unwinds.
unsafe extern "C" {
    #[rustc_std_internal_symbol]
    #[link_name = "ryo_bt_resolve_@TAG@"]
    fn ryo_bt_resolve(ip: usize, cb: extern "C" fn(*mut c_void, &RyoFrame), data: *mut c_void) -> bool;
}

unsafe extern "C" {
    #[rustc_std_internal_symbol]
    #[link_name = "ryo_bt_entry_@TAG@"]
    fn ryo_bt_entry(addr: usize) -> usize;
}

/// The symbol address of a frame: for JIT code, its function's AOT entry.
pub(crate) fn ryo_symbol_address(a: *mut c_void) -> *mut c_void {
    // SAFETY: `ryo_bt_entry` reads only the runtime's published tables.
    unsafe { ryo_bt_entry(a as usize) as *mut c_void }
}

/// Collects the frames `ryo_bt_resolve` reports (its callback mustn't unwind).
extern "C" fn ryo_push(data: *mut c_void, f: &RyoFrame) {
    // SAFETY: `data` is the `Vec` `ryo_resolve` passes.
    unsafe { (*(data as *mut crate::vec::Vec<RyoFrame>)).push(*f) }
}

/// The symbols of `what`: `ryo_rt`'s frames if it is VM code, else the symbolizer's.
unsafe fn ryo_resolve(what: ResolveWhat<'_>, cb: &mut dyn FnMut(&Symbol)) {
    let ip = what.address_or_ip();
    let mut frames: crate::vec::Vec<RyoFrame> = crate::vec::Vec::new();
    // SAFETY: `ryo_push` takes `frames`.
    if !ip.is_null() && unsafe { ryo_bt_resolve(ip as usize, ryo_push, (&raw mut frames).cast()) } {
        for f in &frames {
            // SAFETY: `ryo_rt` reports image bytes, which stay mapped.
            let bytes = |p: *const u8, n: usize| (!p.is_null()).then(|| unsafe { core::slice::from_raw_parts(p, n) });
            let mut name = bytes(f.name, f.name_len).map(|n| n.to_vec());
            if name.is_none() {
                // The function's symbol (`Address` resolves one byte before).
                unsafe {
                    imp::resolve(ResolveWhat::Address((f.aot_pc + 1) as *mut c_void), &mut |s: &ImpSymbol| {
                        if name.is_none() {
                            name = s.inner.name().map(|n| n.as_bytes().to_vec());
                        }
                    })
                };
            }
            let file = bytes(f.file, f.file_len);
            cb(&Symbol { inner: SymInner::Ryo(RyoSymbol { name, file, line: f.line, col: f.col, addr: f.aot_pc as *mut c_void }) });
        }
        return;
    }
    unsafe { imp::resolve(what, &mut |s: &ImpSymbol| cb(&Symbol { inner: SymInner::Imp(s) })) }
}
"#;

/// A hash of `out/dist/`'s backend's contents (`y build` copies it fresh each time, so its
/// modification time always changes).
fn backend_stamp(dist: &Path) -> Result<u64, String> {
    crate::utils::hash_files(&[dist.join("lib").join(crate::utils::dll_name("rustc_codegen_ryo"))])
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
