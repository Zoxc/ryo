//! The sealed JIT (design/build.md#build, design/vm.md#jit): `ryo_jit` built as a staticlib
//! with its own std, reduced to one object whose only global symbol is `ryo_jit_start`, which
//! `ryo_rt` bundles.

use std::fs;
use std::path::{Path, PathBuf};

use crate::utils::{RustcInfo, cmd, output, run};

/// The JIT's one global symbol.
pub const START: &str = "ryo_jit_start";

/// The sealed object's name, as a member of the library and of `ryo_rt`'s rlib.
pub const OBJECT: &str = "ryo_jit.o";

/// Whether `ryo_rt` has a JIT on `triple`: elsewhere its trips are the no-op JIT.
pub fn supported(triple: &str) -> bool {
    triple.starts_with("x86_64-") && triple.contains("-linux-")
}

/// The sealed library's file name for `triple`, as `-l static=ryo_jit` looks for it.
pub fn lib_name(triple: &str) -> &'static str {
    if triple.contains("-msvc") { "ryo_jit.lib" } else { "libryo_jit.a" }
}

/// The toolchain's LLVM tool `name` (`llvm-tools`).
pub fn llvm_tool(info: &RustcInfo, name: &str) -> PathBuf {
    info.sysroot.join("lib").join("rustlib").join(&info.host).join("bin").join(crate::utils::exe_name(name))
}

/// Builds `ryo_jit` for `triple` (`cross` unless it is the host) as a staticlib, with fat LTO
/// against the toolchain's std (the one `dist/` copies), and seals it into
/// `target/jit/sealed/<triple>/`, which it returns: the directory `ryo_rt`'s build script
/// takes the library from (`RYO_JIT_LIB_DIR`).
///
/// Sealing: fat LTO leaves one object with the JIT and all of std (the other members are
/// `compiler_builtins`, kept out of LTO, whose functions then bind to the program's copy).
/// That object is extracted, and every global it defines but `ryo_jit_start` made local, so
/// that the JIT's std stays private: nothing else can bind to it, and its references bind
/// only to C libraries and the unwinder. Then it is the library's only member.
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
        .env_remove("CARGO_ENCODED_RUSTFLAGS"))?;
    let mut built = target_dir.clone();
    if let Some(t) = cross {
        built.push(t);
    }
    let staticlib = built.join("release").join(lib_name(triple));
    let out = target_dir.join("sealed").join(triple);
    seal(info, &staticlib, &out)?;
    Ok(out)
}

/// Seals `staticlib` into `out` (ELF; see [`build`]).
fn seal(info: &RustcInfo, staticlib: &Path, out: &Path) -> Result<(), String> {
    let ar = llvm_tool(info, "llvm-ar");
    let objcopy = llvm_tool(info, "llvm-objcopy");
    if out.exists() {
        fs::remove_dir_all(out).map_err(|e| format!("removing {}: {e}", out.display()))?;
    }
    fs::create_dir_all(out).map_err(|e| format!("creating {}: {e}", out.display()))?;
    let lto = lto_member(&output(cmd(&ar).arg("t").arg(staticlib))?)?;
    run(cmd(&ar).arg("x").arg(staticlib).arg(&lto).arg("--output").arg(out))?;
    let obj = out.join(OBJECT);
    // Without debug information (std's, mostly), which would land in every binary; local
    // symbols stay, for profilers and backtraces of the JIT thread.
    run(cmd(&objcopy).arg(format!("--keep-global-symbol={START}")).arg("--strip-debug").arg(out.join(&lto)).arg(&obj))?;
    fs::remove_file(out.join(&lto)).map_err(|e| e.to_string())?;
    run(cmd(&ar).arg("rcs").arg(out.join("libryo_jit.a")).arg(&obj))
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

#[cfg(test)]
mod tests {
    #[test]
    fn finds_the_lto_member() {
        let ls = "compiler_builtins-0a.compiler_builtins.ab-cgu.000.rcgu.o\nryo_jit-12.ryo_jit.cd-cgu.0.rcgu.o\ncompiler_builtins-0a.compiler_builtins.ab-cgu.001.rcgu.o\n";
        assert_eq!(super::lto_member(ls).unwrap(), "ryo_jit-12.ryo_jit.cd-cgu.0.rcgu.o");
        assert!(super::lto_member("compiler_builtins-0a.x-cgu.0.rcgu.o\n").is_err());
    }
}
