//! The sealed JIT (design/build.md#build, design/jit.md#packaging): `ryo_jit` built as a staticlib
//! with its own std, reduced to one object whose only global symbol is `ryo_jit_start_<tag>`
//! (the ABI tag, design/build.md#the-abi-tag), which `ryo_rt` bundles.

use std::path::{Path, PathBuf};

use crate::target::{is_coff, is_macho, is_windows, static_lib_name, symbol};
use crate::utils::{RustcInfo, cmd, is_std_alloc_shim, nm_symbols, output, run};

/// The JIT's one global symbol, before the ABI tag: `ryo_jit_start_<tag>`.
pub const START: &str = "ryo_jit_start_";

/// The sealed object's name, as a member of the library and of `ryo_rt`'s rlib.
pub const OBJECT: &str = "ryo_jit.o";

/// What COFF sealing prefixes the JIT's other external symbols with ([`build`]), followed by
/// the tag and `$`, so that two ryo builds' sealed objects never define the same name.
const COFF_PREFIX: &str = "__ryo_jit$";

/// Whether `ryo_rt` gets the JIT on `triple`: x86_64 Linux, windows-msvc and macOS
/// (design/jit.md#packaging). Elsewhere `ryo_rt` has no `jit` feature, and its trips are the
/// no-op JIT.
pub fn supported(triple: &str) -> bool {
    triple.starts_with("x86_64-") && (triple.contains("-linux-") || is_coff(triple) || is_macho(triple))
}

/// The flag that keeps `ryo_rt`'s and the JIT's code for Windows out of the memory below
/// `rsp`: LLVM gives `sysv64` functions a red zone by their convention, even on Windows,
/// where exception dispatch, APCs and debuggers may write there (design/platforms.md).
pub const NO_REDZONE: &str = "-Cno-redzone=yes";

/// Builds `ryo_jit` for `triple` (`cross` unless it is the host) as a staticlib, with fat LTO
/// against the toolchain's std (the one `dist/` copies), and seals it into
/// `target/jit/sealed/<triple>/`, which it returns: the directory `ryo_rt`'s build script
/// takes the library from (`RYO_JIT_LIB_DIR`). Making a staticlib needs no linker, so this
/// works for a cross target too.
///
/// Sealing: fat LTO leaves one object with the JIT and all of std. The other members are
/// `compiler_builtins`, kept out of LTO, whose functions then bind to the program's copy, and
/// on windows-msvc the import members of std's `raw-dylib` imports. That object is extracted
/// and its globals but `ryo_jit_start` hidden, so that the JIT's std stays private: nothing
/// else binds to it, and its references bind only to C libraries, the OS and the unwinder.
/// - ELF and Mach-O: every other global becomes local (`llvm-objcopy --keep-global-symbol`,
///   with Mach-O's `_` prefix: `_ryo_jit_start`); the object is the library's only member,
///   archived in the BSD format on Mach-O, as rustc writes Apple archives.
/// - COFF, where llvm-objcopy can't localize: rustc's LTO already made almost everything
///   internal, and the few other external definitions are renamed to `__ryo_jit$<name>`,
///   which nothing else defines or references, but for LLVM's constants named by their
///   contents (`__xmm@…`, `__real@…`), which merge with the program's by content. The library
///   keeps its import members.
///
/// `checked`: with `-Cdebug-assertions=on -Coverflow-checks=on` on top of the release
/// optimizations, in `target/jit-checked/`: the JIT `y test` runs ([`CHECKED_DIR`]).
/// The host's sealed JIT directories ([`build`]): the release one bundled into `ryo_rt`, and
/// the checked one `y test` swaps in.
pub struct SealedJits {
    pub release: PathBuf,
    pub checked: PathBuf,
}

pub fn build(rb: &crate::dist::RuntimeBuild, triple: &str, checked: bool) -> Result<PathBuf, String> {
    let (root, info, cross) = (rb.root, rb.info, rb.cross(triple));
    eprintln!("[y] jit: ryo_jit{}{}", if checked { " (checked)" } else { "" }, cross.map(|t| format!(" for {t}")).unwrap_or_default());
    let target_dir = rb.target.join(if checked { CHECKED_DIR } else { "jit" });
    let mut rustflags: Vec<&str> = Vec::new();
    // Its trips are `sysv64` code too: no red zone on Windows (design/platforms.md).
    if is_windows(triple) {
        rustflags.push(NO_REDZONE);
    }
    if checked {
        rustflags.extend(["-Cdebug-assertions=on", "-Coverflow-checks=on"]);
    }
    let mut cargo = cmd("cargo");
    cargo.args(["rustc", "--release", "-p", "ryo_jit", "--crate-type", "staticlib"]);
    if let Some(t) = cross {
        cargo.args(["--target", t]);
    }
    run(cargo
        .arg("--manifest-path")
        .arg(root.join("vm").join("Cargo.toml"))
        .arg("--target-dir")
        .arg(&target_dir)
        // Independent of the user's profile settings and RUSTFLAGS. Its own cargo invocation:
        // with `ryo_rt`'s, `ryo_bytecode`'s `alloc` would be unified into `ryo_rt`'s copy.
        .env("CARGO_PROFILE_RELEASE_OPT_LEVEL", "3")
        .env("CARGO_PROFILE_RELEASE_CODEGEN_UNITS", "1")
        .env("CARGO_PROFILE_RELEASE_LTO", "fat")
        .env("CARGO_PROFILE_RELEASE_PANIC", "unwind")
        .env("CARGO_PROFILE_RELEASE_DEBUG", "0")
        .env_remove("RUSTFLAGS")
        .env("CARGO_ENCODED_RUSTFLAGS", rustflags.join("\x1f")))?;
    let mut built = target_dir.clone();
    if let Some(t) = cross {
        built.push(t);
    }
    let staticlib = built.join("release").join(static_lib_name(triple, "ryo_jit"));
    let out = target_dir.join("sealed").join(triple);
    seal(info, &staticlib, &out, triple, rb.tag)?;
    Ok(out)
}

/// Where a sysroot (`dist/`, `dist/sysroot-ryo/`) keeps its host `ryo_rt` with the checked
/// JIT ([`build`]'s `checked`), which `rustc-ryo` links instead under `RYO_JIT_CHECKED=1`.
pub const CHECKED_DIR: &str = crate::wrapper_common::JIT_CHECKED_DIR;

/// Writes `dst_dir/<rlib's name>`: the `ryo_rt` `rlib` with its bundled JIT object replaced by
/// the one in `sealed` (a [`build`] output). The rest, metadata included, stays as is, so
/// crates built against either link with either.
pub fn swap_into_rlib(info: &RustcInfo, rlib: &Path, sealed: &Path, dst_dir: &Path) -> Result<(), String> {
    let ar = info.tool("llvm-ar");
    let members = output(cmd(&ar).arg("t").arg(rlib))?;
    if !members.lines().any(|m| m.trim() == OBJECT) {
        return Err(format!("{} has no {OBJECT} member", rlib.display()));
    }
    crate::utils::fresh_dir(dst_dir)?;
    let dst = dst_dir.join(rlib.file_name().ok_or("rlib path without a name")?);
    crate::utils::copy(rlib, &dst)?;
    run(cmd(&ar).arg("r").arg(&dst).arg(sealed.join(OBJECT)))
}

/// Seals `staticlib` into `out` (see [`build`]).
fn seal(info: &RustcInfo, staticlib: &Path, out: &Path, triple: &str, tag: &str) -> Result<(), String> {
    let ar = info.tool("llvm-ar");
    let objcopy = info.tool("llvm-objcopy");
    crate::utils::fresh_dir(out)?;
    let members = output(cmd(&ar).arg("t").arg(staticlib))?;
    let lto = lto_member(&members)?;
    run(cmd(&ar).arg("x").arg(staticlib).arg(&lto).arg("--output").arg(out))?;
    let obj = out.join(OBJECT);
    let lib = out.join(static_lib_name(triple, "ryo_jit"));
    // Without debug information (std's, mostly), which would land in every binary; local
    // symbols stay, for profilers and backtraces of the JIT thread.
    let mut seal = cmd(&objcopy);
    seal.arg("--strip-debug");
    if is_coff(triple) {
        let nm = info.tool("llvm-nm");
        let defined = output(cmd(&nm).args(["--extern-only", "--defined-only", "--no-demangle", "-j"]).arg(out.join(&lto)))?;
        let renames: String = defined.lines().map(str::trim).filter(|s| coff_renamed(s)).map(|s| format!("{s} {COFF_PREFIX}{tag}${s}\n")).collect();
        let list = out.join("renames.txt");
        crate::utils::write(&list, renames)?;
        seal.arg(format!("--redefine-syms={}", list.display()));
    } else {
        seal.arg(format!("--keep-global-symbol={}", symbol(triple, &format!("{START}{tag}"))));
    }
    run(seal.arg(out.join(&lto)).arg(&obj))?;
    crate::utils::remove_file(out.join(&lto))?;
    if is_coff(triple) {
        // The staticlib without its objects: its import members, then the sealed object.
        crate::utils::copy(staticlib, &lib)?;
        let mut objects: Vec<&str> = members.lines().map(str::trim).filter(|m| !m.is_empty() && !m.ends_with(".dll")).collect();
        objects.sort_unstable();
        objects.dedup();
        run(cmd(&ar).arg("d").arg(&lib).args(&objects))?;
        run(cmd(&ar).arg("r").arg(&lib).arg(&obj))
    } else if is_macho(triple) {
        run(cmd(&ar).args(["rcs", "--format=darwin"]).arg(&lib).arg(&obj))
    } else {
        run(cmd(&ar).arg("rcs").arg(&lib).arg(&obj))
    }
}

/// Whether COFF sealing renames the JIT's external definition `s`: all but `ryo_jit_start_<tag>`
/// and LLVM's constants named by their contents.
fn coff_renamed(s: &str) -> bool {
    !s.is_empty() && !s.starts_with(START) && !["__xmm@", "__ymm@", "__zmm@", "__real@"].iter().any(|p| s.starts_with(p))
}

/// The one Rust member of a fat-LTO staticlib (`llvm-ar t`'s listing): the `.rcgu.o` that
/// isn't `compiler_builtins`'.
fn lto_member(members: &str) -> Result<String, String> {
    let rust: Vec<&str> = members.lines().map(str::trim).filter(|m| m.ends_with(".rcgu.o") && !m.starts_with("compiler_builtins-")).collect();
    match rust[..] {
        [m] => Ok(m.to_owned()),
        _ => Err(format!("expected one LTO object in the JIT's staticlib, found {rust:?}")),
    }
}

/// Checks the sealed JIT that the `ryo_rt` rlib `rlib` for `triple` bundles, extracted into
/// `dir`: it keeps its std to itself. Its only global definition is `ryo_jit_start` (on COFF
/// also the renamed `__ryo_jit$…` symbols and LLVM's constants; on ELF a linker could merge a
/// global such as `DW.ref.rust_eh_personality`'s COMDAT group with the program's), it
/// references no Rust symbol and no allocator shim (which would bind to the program's std),
/// and it doesn't define the unwinder, which it must share with the program (`__register_frame`
/// registers JIT code with the program's). On COFF it also has no linker directives
/// (`.drectve`) and no CRT initializers (`.CRT$X*`), on Mach-O no initializers
/// (`__mod_init_func`, `__init_offsets`) or linker options (`LC_LINKER_OPTION`, the
/// counterpart of `.drectve`, which would add `-l` libraries to every link). Names are
/// compared without Mach-O's `_` prefix. Returns the object's undefined symbols, so named.
pub fn check_sealed(info: &RustcInfo, rlib: &Path, dir: &Path, triple: &str) -> Result<Vec<String>, String> {
    crate::utils::fresh_dir(dir)?;
    let ar = info.tool("llvm-ar");
    run(cmd(&ar).arg("x").arg(rlib).arg(OBJECT).arg("--output").arg(dir)).map_err(|e| format!("no sealed JIT in {}: {e}", rlib.display()))?;
    let obj = dir.join(OBJECT);
    let globals = nm_symbols(info, &["--extern-only", "--defined-only", "--no-demangle"], &obj, triple)?;
    let bad: Vec<&String> =
        globals.iter().filter(|s| !s.starts_with(START) && (!is_coff(triple) || (coff_renamed(s) && !s.starts_with(COFF_PREFIX)))).collect();
    if !bad.is_empty() || globals.iter().filter(|s| s.starts_with(START)).count() != 1 {
        return Err(format!("{} defines globals {bad:?} (and must define one {START}<tag>)", obj.display()));
    }
    let undefined = nm_symbols(info, &["-u", "--no-demangle"], &obj, triple)?;
    let bad: Vec<&String> = undefined.iter().filter(|s| s.starts_with("_R") || s.starts_with("_ZN") || is_std_alloc_shim(s)).collect();
    if !bad.is_empty() {
        return Err(format!("{} references Rust symbols {bad:?}", obj.display()));
    }
    let unwinder: Vec<String> = nm_symbols(info, &["--defined-only", "--no-demangle"], &obj, triple)?
        .into_iter()
        .filter(|s| s.starts_with("_Unwind_") || s == "__register_frame")
        .collect();
    if !unwinder.is_empty() {
        return Err(format!("{} defines the unwinder's {unwinder:?}", obj.display()));
    }
    if is_coff(triple) {
        let sections = output(cmd(info.tool("llvm-objdump")).arg("-h").arg(&obj))?;
        if let Some(s) = sections.lines().find(|l| l.contains(".drectve") || l.contains(".CRT$X")) {
            return Err(format!("{} has the section {}", obj.display(), s.trim()));
        }
    }
    if is_macho(triple) {
        let sections = output(cmd(info.tool("llvm-objdump")).arg("-h").arg(&obj))?;
        if let Some(s) = sections.lines().find(|l| l.contains("__mod_init_func") || l.contains("__init_offsets") || l.contains("__mod_term_func")) {
            return Err(format!("{} has the section {}", obj.display(), s.trim()));
        }
        let commands = output(cmd(info.tool("llvm-objdump")).arg("--private-headers").arg(&obj))?;
        if commands.contains("LC_LINKER_OPTION") {
            return Err(format!("{} has linker options (LC_LINKER_OPTION)", obj.display()));
        }
    }
    Ok(undefined)
}

#[cfg(test)]
mod tests {
    #[test]
    fn finds_the_lto_member() {
        let ls = "compiler_builtins-0a.compiler_builtins.ab-cgu.000.rcgu.o\nryo_jit-12.ryo_jit.cd-cgu.0.rcgu.o\ncompiler_builtins-0a.compiler_builtins.ab-cgu.001.rcgu.o\n";
        assert_eq!(super::lto_member(ls).unwrap(), "ryo_jit-12.ryo_jit.cd-cgu.0.rcgu.o");
        assert!(super::lto_member("compiler_builtins-0a.x-cgu.0.rcgu.o\n").is_err());
    }

    #[test]
    fn coff_renames() {
        assert!(super::coff_renamed("rust_eh_personality"));
        assert!(super::coff_renamed("_RNvNtCs1_3std9panicking11EMPTY_PANIC"));
        assert!(!super::coff_renamed("ryo_jit_start_0123456789abcdef"));
        assert!(!super::coff_renamed("__xmm@00000000000000010000000000000001"));
    }

    #[test]
    fn jit_targets() {
        assert!(super::supported("x86_64-unknown-linux-gnu"));
        assert!(super::supported("x86_64-pc-windows-msvc"));
        assert!(!super::supported("aarch64-unknown-linux-gnu"));
        assert!(super::supported("x86_64-apple-darwin"));
        assert!(!super::supported("aarch64-apple-darwin"));
        assert!(!super::supported("x86_64-pc-windows-gnu"));
    }
}
