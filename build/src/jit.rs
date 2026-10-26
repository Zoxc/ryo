//! The sealed JIT (design/build.md#build, design/jit.md#packaging): `ryo_jit` built as a staticlib
//! with its own std, reduced to one object whose only global symbol is `ryo_jit_start`, which
//! `ryo_rt` bundles.

use std::fs;
use std::path::{Path, PathBuf};

use crate::utils::{RustcInfo, cmd, output, run};

/// The JIT's one global symbol.
pub const START: &str = "ryo_jit_start";

/// The sealed object's name, as a member of the library and of `ryo_rt`'s rlib.
pub const OBJECT: &str = "ryo_jit.o";

/// What COFF sealing prefixes the JIT's other external symbols with ([`build`]).
const COFF_PREFIX: &str = "__ryo_jit$";

/// The symbol `s` of an object for `triple` as its C or Rust name: without Mach-O's `_`.
pub fn unprefixed<'a>(triple: &str, s: &'a str) -> &'a str {
    if macho(triple) { s.strip_prefix('_').unwrap_or(s) } else { s }
}

/// Whether `ryo_rt` gets the JIT on `triple`: x86_64 Linux, windows-msvc and macOS
/// (design/jit.md#packaging). Elsewhere `ryo_rt` has no `jit` feature, and its trips are the
/// no-op JIT.
pub fn supported(triple: &str) -> bool {
    triple.starts_with("x86_64-") && (triple.contains("-linux-") || coff(triple) || macho(triple))
}

/// Whether `triple` is a Mach-O (Apple) target.
pub fn macho(triple: &str) -> bool {
    triple.contains("-apple-")
}

/// The object-file name of the C symbol `name` on `triple`: Mach-O prefixes an `_`.
pub fn symbol(triple: &str, name: &str) -> String {
    if macho(triple) { format!("_{name}") } else { name.to_owned() }
}

/// The flag that keeps `ryo_rt`'s and the JIT's code for Windows out of the memory below
/// `rsp`: LLVM gives `sysv64` functions a red zone by their convention, even on Windows,
/// where exception dispatch, APCs and debuggers may write there (design/platforms.md).
pub const NO_REDZONE: &str = "-Cno-redzone=yes";

/// Whether `triple` is a COFF (windows-msvc) target.
fn coff(triple: &str) -> bool {
    triple.ends_with("-windows-msvc")
}

/// The sealed library's file name for `triple`, as `-l static=ryo_jit` looks for it.
pub fn lib_name(triple: &str) -> &'static str {
    if coff(triple) { "ryo_jit.lib" } else { "libryo_jit.a" }
}

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
pub fn build(root: &Path, target: &Path, info: &RustcInfo, triple: &str, cross: Option<&str>) -> Result<PathBuf, String> {
    eprintln!("[y] jit: ryo_jit{}", cross.map(|t| format!(" for {t}")).unwrap_or_default());
    let target_dir = target.join("jit");
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
        // Its trips are `sysv64` code too: no red zone on Windows (design/platforms.md).
        .env("CARGO_ENCODED_RUSTFLAGS", if triple.contains("-windows") { NO_REDZONE } else { "" }))?;
    let mut built = target_dir.clone();
    if let Some(t) = cross {
        built.push(t);
    }
    let staticlib = built.join("release").join(lib_name(triple));
    let out = target_dir.join("sealed").join(triple);
    seal(info, &staticlib, &out, triple)?;
    Ok(out)
}

/// Seals `staticlib` into `out` (see [`build`]).
fn seal(info: &RustcInfo, staticlib: &Path, out: &Path, triple: &str) -> Result<(), String> {
    let ar = info.tool("llvm-ar");
    let objcopy = info.tool("llvm-objcopy");
    if out.exists() {
        fs::remove_dir_all(out).map_err(|e| format!("removing {}: {e}", out.display()))?;
    }
    fs::create_dir_all(out).map_err(|e| format!("creating {}: {e}", out.display()))?;
    let members = output(cmd(&ar).arg("t").arg(staticlib))?;
    let lto = lto_member(&members)?;
    run(cmd(&ar).arg("x").arg(staticlib).arg(&lto).arg("--output").arg(out))?;
    let obj = out.join(OBJECT);
    let lib = out.join(lib_name(triple));
    // Without debug information (std's, mostly), which would land in every binary; local
    // symbols stay, for profilers and backtraces of the JIT thread.
    let mut seal = cmd(&objcopy);
    seal.arg("--strip-debug");
    if coff(triple) {
        let nm = info.tool("llvm-nm");
        let defined = output(cmd(&nm).args(["--extern-only", "--defined-only", "--no-demangle", "-j"]).arg(out.join(&lto)))?;
        let renames: String = defined.lines().map(str::trim).filter(|s| coff_renamed(s)).map(|s| format!("{s} {COFF_PREFIX}{s}\n")).collect();
        let list = out.join("renames.txt");
        fs::write(&list, renames).map_err(|e| e.to_string())?;
        seal.arg(format!("--redefine-syms={}", list.display()));
    } else {
        seal.arg(format!("--keep-global-symbol={}", symbol(triple, START)));
    }
    run(seal.arg(out.join(&lto)).arg(&obj))?;
    fs::remove_file(out.join(&lto)).map_err(|e| e.to_string())?;
    if coff(triple) {
        // The staticlib without its objects: its import members, then the sealed object.
        crate::dist::copy(staticlib, &lib)?;
        let mut objects: Vec<&str> = members.lines().map(str::trim).filter(|m| !m.is_empty() && !m.ends_with(".dll")).collect();
        objects.sort_unstable();
        objects.dedup();
        run(cmd(&ar).arg("d").arg(&lib).args(&objects))?;
        run(cmd(&ar).arg("r").arg(&lib).arg(&obj))
    } else if macho(triple) {
        run(cmd(&ar).args(["rcs", "--format=darwin"]).arg(&lib).arg(&obj))
    } else {
        run(cmd(&ar).arg("rcs").arg(&lib).arg(&obj))
    }
}

/// Whether COFF sealing renames the JIT's external definition `s`: all but `ryo_jit_start`
/// and LLVM's constants named by their contents.
fn coff_renamed(s: &str) -> bool {
    !s.is_empty() && s != START && !["__xmm@", "__ymm@", "__zmm@", "__real@"].iter().any(|p| s.starts_with(p))
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
/// compared without Mach-O's `_` prefix.
pub fn check_sealed(info: &RustcInfo, rlib: &Path, dir: &Path, triple: &str) -> Result<(), String> {
    let _ = fs::remove_dir_all(dir);
    fs::create_dir_all(dir).map_err(|e| e.to_string())?;
    let ar = info.tool("llvm-ar");
    let nm = info.tool("llvm-nm");
    run(cmd(&ar).arg("x").arg(rlib).arg(OBJECT).arg("--output").arg(dir)).map_err(|e| format!("no sealed JIT in {}: {e}", rlib.display()))?;
    let obj = dir.join(OBJECT);
    let names = |args: &[&str]| -> Result<Vec<String>, String> {
        Ok(output(cmd(&nm).args(args).args(["--no-demangle", "-j"]).arg(&obj))?
            .lines()
            .map(|l| l.trim())
            .map(|l| unprefixed(triple, l).to_owned())
            .filter(|l| !l.is_empty())
            .collect())
    };
    let globals = names(&["--extern-only", "--defined-only"])?;
    let bad: Vec<&String> = globals.iter().filter(|s| *s != START && (!coff(triple) || (coff_renamed(s) && !s.starts_with(COFF_PREFIX)))).collect();
    if !bad.is_empty() || !globals.iter().any(|s| s == START) {
        return Err(format!("{} defines globals {bad:?} (and must define {START})", obj.display()));
    }
    let rust = |s: &str| s.starts_with("_R") || s.starts_with("_ZN") || s.starts_with("__rust") || s.starts_with("__rdl") || s.starts_with("__rg_");
    let bad: Vec<String> = names(&["-u"])?.into_iter().filter(|s| rust(s)).collect();
    if !bad.is_empty() {
        return Err(format!("{} references Rust symbols {bad:?}", obj.display()));
    }
    let unwinder: Vec<String> = names(&["--defined-only"])?.into_iter().filter(|s| s.starts_with("_Unwind_") || s == "__register_frame").collect();
    if !unwinder.is_empty() {
        return Err(format!("{} defines the unwinder's {unwinder:?}", obj.display()));
    }
    if coff(triple) {
        let sections = output(cmd(info.tool("llvm-objdump")).arg("-h").arg(&obj))?;
        if let Some(s) = sections.lines().find(|l| l.contains(".drectve") || l.contains(".CRT$X")) {
            return Err(format!("{} has the section {}", obj.display(), s.trim()));
        }
    }
    if macho(triple) {
        let sections = output(cmd(info.tool("llvm-objdump")).arg("-h").arg(&obj))?;
        if let Some(s) = sections.lines().find(|l| l.contains("__mod_init_func") || l.contains("__init_offsets") || l.contains("__mod_term_func")) {
            return Err(format!("{} has the section {}", obj.display(), s.trim()));
        }
        let commands = output(cmd(info.tool("llvm-objdump")).arg("--private-headers").arg(&obj))?;
        if commands.contains("LC_LINKER_OPTION") {
            return Err(format!("{} has linker options (LC_LINKER_OPTION)", obj.display()));
        }
    }
    Ok(())
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
        assert!(!super::coff_renamed("ryo_jit_start"));
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
        assert_eq!(super::symbol("x86_64-apple-darwin", "ryo_jit_start"), "_ryo_jit_start");
        assert_eq!(super::symbol("x86_64-unknown-linux-gnu", "ryo_jit_start"), "ryo_jit_start");
    }
}
