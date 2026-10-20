//! `y test --cross <target>` (design/platforms.md): builds the test corpus for another target
//! (windows-msvc) with plain rustc and with `rustc-ryo`, and links it with the sysroot's
//! `rust-lld` (lld-link flavor) against empty stand-in import libraries, with
//! `/force:unresolved`. Nothing runs. The check: every symbol the ryo build leaves unresolved
//! is also unresolved in plain rustc's build of the same program, or is one of the CRT/SDK
//! symbols `ryo_rt` itself uses ([`RT_IMPORTS`]), i.e. comes from the missing
//! CRT/SDK libraries. A missing ryo symbol (an image, a portal, an `__imp_` slot, the
//! registry) shows up as a difference.

use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};

use crate::test::{CORPUS, CrateKind, Program};
use crate::utils::{RustcInfo, cmd, describe, exe_name, root};

/// Import libraries std, `ryo_rt` and the corpus name on windows-msvc, replaced by empty
/// archives. A library missing here fails the link with "could not open"; add it.
const STUB_LIBS: &[&str] = &[
    "kernel32", "ntdll", "userenv", "ws2_32", "dbghelp", "msvcrt", "synchronization", "bcryptprimitives",
    "advapi32", "ucrt", "vcruntime", "legacy_stdio_definitions",
];

/// CRT and SDK symbols `ryo_rt` uses that a plain rustc build of a program may not: its
/// kernel32 imports (`vm/rt/src/vm/sys.rs`, as lld names their `__imp_` references) and the
/// C runtime functions its code needs. The only unresolved symbols allowed besides plain
/// rustc's.
const RT_IMPORTS: &[&str] = &[
    "__declspec(dllimport) VirtualAlloc",
    "__declspec(dllimport) VirtualFree",
    "__declspec(dllimport) VirtualProtect",
    "__declspec(dllimport) GetStdHandle",
    "__declspec(dllimport) WriteFile",
    "__declspec(dllimport) FlsAlloc",
    "__declspec(dllimport) FlsSetValue",
    "__declspec(dllimport) GetEnvironmentVariableA",
    "memcmp",
    "memcpy",
    "memmove",
    "memset",
    "fmod",
    "fmodf",
    "_fltused",
    "_tls_index",
    "const type_info::`vftable'",
];

pub fn run(target: &str) -> Result<(), String> {
    let root = root();
    let info = RustcInfo::get()?;
    let dist = root.join("dist");
    let rustc_ryo = dist.join("bin").join(exe_name("rustc-ryo"));
    if !dist.join("lib").join("rustlib").join(target).join("lib").join("libryo_rt.rlib").exists() {
        return Err(format!("dist/ has no ryo_rt for {target}; run `./y.sh build --target {target}` first"));
    }
    let lld = dist.join("lib").join("rustlib").join(&info.host).join("bin").join(exe_name("rust-lld"));
    if !lld.exists() {
        eprintln!("[y] test --cross {target}: skipped (no rust-lld at {})", lld.display());
        return Ok(());
    }
    let out = root.join("target").join("tests-cross").join(target);
    let _ = fs::remove_dir_all(&out);
    let stubs = out.join("stub-libs");
    fs::create_dir_all(&stubs).map_err(|e| format!("creating {}: {e}", stubs.display()))?;
    for lib in STUB_LIBS {
        fs::write(stubs.join(format!("{lib}.lib")), b"!<arch>\n").map_err(|e| e.to_string())?;
    }
    let link = Link { target, lld, stubs };

    let mut failed = Vec::new();
    for program in CORPUS {
        let res = (|| {
            let reference = link.build(&cmd("rustc"), program, &out.join(program.name).join("rustc"), &[])?;
            let mut builds = vec![("ryo", &[][..])];
            // `-Clto` on the last crate, as cargo passes it (no Rust dylibs).
            if !program.has_dylib() {
                builds.push(("ryo-lto", &["-Clto=fat"][..]));
            }
            for (name, final_flags) in builds {
                let ryo = link.build(&cmd(&rustc_ryo), program, &out.join(program.name).join(name), final_flags)?;
                // The image refers to a DLL function both through its `__imp_` slot and directly
                // (design/platforms.md); with the real import library the direct reference
                // resolves to the import thunk, so it is fine wherever the import itself is.
                let extra: Vec<&String> = ryo
                    .difference(&reference)
                    .filter(|s| !RT_IMPORTS.contains(&s.as_str()))
                    .filter(|s| !reference.contains(&format!("__declspec(dllimport) {s}")))
                    // The other way round: the image loads a foreign function's address through
                    // `__imp_` where plain rustc calls it directly (`abs` from the CRT). An
                    // import library defines both; for a static one the linker synthesizes it.
                    .filter(|s| {
                        s.strip_prefix("__declspec(dllimport) ").is_none_or(|plain| !reference.contains(plain))
                    })
                    .collect();
                if !extra.is_empty() {
                    return Err(format!("unresolved only in the {name} build: {extra:?}"));
                }
            }
            Ok(())
        })();
        match res {
            Ok(()) => eprintln!("[y] test --cross {target} {}: ok", program.name),
            Err(msg) => {
                eprintln!("[y] test --cross {target} {}: FAILED: {msg}", program.name);
                failed.push(program.name);
            }
        }
    }
    if !failed.is_empty() {
        return Err(format!("failed cross tests: {}", failed.join(", ")));
    }
    Ok(())
}

struct Link<'a> {
    target: &'a str,
    lld: PathBuf,
    stubs: PathBuf,
}

impl Link<'_> {
    /// Builds and links every crate of `program` with `compiler` into `dir`, and returns the
    /// symbols the links left unresolved.
    fn build(
        &self,
        compiler: &std::process::Command,
        program: &Program,
        dir: &Path,
        final_flags: &[&str],
    ) -> Result<BTreeSet<String>, String> {
        fs::create_dir_all(dir).map_err(|e| format!("creating {}: {e}", dir.display()))?;
        let tests = root().join("tests");
        let mut undefined = BTreeSet::new();
        if let Some(lib) = &program.native_lib {
            lib.build(dir, Some(self.target))?;
        }
        for krate in program.crates {
            let mut c = cmd(compiler.get_program());
            c.arg("--edition=2024")
                .arg(tests.join(krate.src))
                .args(krate.kind.flags())
                .args(["--crate-name", krate.name, "--target", self.target])
                .arg("--out-dir")
                .arg(dir)
                .arg("-L")
                .arg(dir)
                .args(program.flags)
                .arg(format!("-Clinker={}", self.lld.display()))
                .args(["-Clinker-flavor=lld-link", "-Clink-arg=/force:unresolved", "-Clink-arg=/DEBUG:NONE"])
                .arg("-L")
                .arg(&self.stubs);
            if std::ptr::eq(krate, program.crates.last().unwrap()) {
                c.args(final_flags);
            }
            if krate.kind == CrateKind::Bin {
                // There is no CRT to provide the default entry point.
                c.arg("-Clink-arg=/entry:mainCRTStartup");
            }
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
            undefined.extend(undefined_symbols(&stderr));
        }
        Ok(undefined)
    }
}

/// The symbols in lld's `undefined symbol: <name>` warnings.
fn undefined_symbols(stderr: &str) -> impl Iterator<Item = String> + '_ {
    stderr.lines().filter_map(|l| Some(l.split_once("undefined symbol: ")?.1.trim().to_owned()))
}

#[cfg(test)]
mod tests {
    #[test]
    fn parses_undefined_symbols() {
        let s = "  = note: rust-lld: warning: <root>: undefined symbol: mainCRTStartup\n          \
                 rust-lld: warning: undefined symbol: __declspec(dllimport) CloseHandle\n          \
                 >>> referenced by x.o\n";
        let got: Vec<String> = super::undefined_symbols(s).collect();
        assert_eq!(got, ["mainCRTStartup", "__declspec(dllimport) CloseHandle"]);
    }
}
