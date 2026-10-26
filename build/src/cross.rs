//! `y test --cross <target>` (design/platforms.md): builds the test corpus for another target
//! (windows-msvc or x86_64 macOS) with plain rustc and with `rustc-ryo`, and links it with the
//! sysroot's `rust-lld` against empty stand-in libraries, leaving symbols unresolved: the
//! lld-link flavor with `/force:unresolved` for windows-msvc, the ld64 flavor with
//! `-flat_namespace -undefined warning` for macOS (there is no SDK: `libSystem` is an empty
//! archive). Nothing runs. The check: every symbol the ryo build leaves unresolved
//! is also unresolved in plain rustc's build of the same program, or is one of the CRT/SDK
//! symbols `ryo_rt` itself uses ([`RT_IMPORTS`], [`RT_IMPORTS_MACHO`]) or its sealed JIT does
//! (in a Rust dylib, which plain rustc links to std's DLL, the JIT's private std brings its own
//! imports), i.e. comes from the missing system libraries. A missing ryo symbol (an image, a
//! portal, an `__imp_` slot, the registry) shows up as a difference.

use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};

use crate::test::{CORPUS, CrateKind, Program};
use crate::utils::{RustcInfo, cmd, describe, exe_name, root};

/// Import libraries std, `ryo_rt` and the corpus name on windows-msvc, replaced by empty
/// archives. A library missing here fails the link with "could not open"; add it.
const STUB_LIBS: &[&str] = &[
    "kernel32",
    "ntdll",
    "userenv",
    "ws2_32",
    "dbghelp",
    "msvcrt",
    "synchronization",
    "bcryptprimitives",
    "advapi32",
    "ucrt",
    "vcruntime",
    "legacy_stdio_definitions",
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
    "atexit",
    "memcmp",
    "memcpy",
    "memmove",
    "memset",
    "getenv",
    "strlen",
    "fmod",
    "fmodf",
    "_fltused",
    "_tls_index",
    "const type_info::`vftable'",
];

/// The libraries std and `ryo_rt` name on macOS, replaced by empty archives (`lib<name>.a`).
const STUB_LIBS_MACHO: &[&str] = &["System", "c", "m", "iconv", "resolv"];

/// An empty libSystem, as a text-based stub.
const LIBSYSTEM_TBD: &str = "--- !tapi-tbd\ntbd-version: 4\ntargets: [ x86_64-macos ]\ninstall-name: '/usr/lib/libSystem.B.dylib'\n...\n";

/// [`RT_IMPORTS`] on macOS, as lld names them (Mach-O's `_` prefix): libSystem's functions
/// `ryo_rt` and `ryo_bytecode` call (`vm/rt/src/vm/sys.rs`, the trips' `__ulock` waits,
/// `vmem`) and the unwinder's `_Unwind_Resume`, which `resume` jumps to.
const RT_IMPORTS_MACHO: &[&str] = &[
    "__Unwind_Resume",
    "___ulock_wait",
    "___ulock_wake",
    "_abort",
    "_getenv",
    "_memcmp",
    "_memcpy",
    "_memmove",
    "_memset",
    "_strlen",
    "_write",
    "_mmap",
    "_mprotect",
    "_munmap",
    "_atexit",
    "_fmod",
    "_fmodf",
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
    let macho = crate::jit::macho(target);
    if macho {
        for lib in STUB_LIBS_MACHO {
            fs::write(stubs.join(format!("lib{lib}.a")), b"!<arch>\n").map_err(|e| e.to_string())?;
        }
        // std's dylib loads libSystem by its install name, which lld looks up as a text stub
        // under the SDK root (`SDKROOT`, below): one that exports nothing.
        let usr_lib = stubs.join("usr").join("lib");
        fs::create_dir_all(&usr_lib).map_err(|e| e.to_string())?;
        fs::write(usr_lib.join("libSystem.B.tbd"), LIBSYSTEM_TBD).map_err(|e| e.to_string())?;
    } else {
        for lib in STUB_LIBS {
            fs::write(stubs.join(format!("{lib}.lib")), b"!<arch>\n").map_err(|e| e.to_string())?;
        }
    }
    let rt_imports = if macho { RT_IMPORTS_MACHO } else { RT_IMPORTS };
    let std_dir = dist.join("lib").join("rustlib").join(target).join("lib");
    let link = Link { target, lld, stubs, macho, std_dir };

    let mut failed = Vec::new();
    // The sealed JIT bundled into this target's `ryo_rt` (design/jit.md#packaging), and its
    // undefined symbols, as lld names them.
    let mut jit_imports = BTreeSet::new();
    if crate::jit::supported(target) {
        let rlib = dist.join("lib").join("rustlib").join(target).join("lib").join("libryo_rt.rlib");
        let dir = out.join("jit-sealed");
        let res = crate::jit::check_sealed(&info, &rlib, &dir, target).and_then(|()| {
            let nm = crate::jit::llvm_tool(&info, "llvm-nm");
            // Demangled as lld-link prints them; ld64.lld prints raw names.
            let demangle = if macho { "--no-demangle" } else { "-C" };
            let syms = crate::utils::output(cmd(nm).args(["-u", demangle, "-j"]).arg(dir.join(crate::jit::OBJECT)))?;
            jit_imports = syms
                .lines()
                .map(|s| match s.trim().strip_prefix("__imp_") {
                    Some(f) => format!("__declspec(dllimport) {f}"),
                    None => s.trim().to_owned(),
                })
                .collect();
            Ok(())
        });
        match res {
            Ok(()) => eprintln!("[y] test --cross {target} jit-sealed: ok"),
            Err(msg) => {
                eprintln!("[y] test --cross {target} jit-sealed: FAILED: {msg}");
                failed.push("jit-sealed");
            }
        }
    }
    // `ryo_rt` keeps to `core` (ELF and Mach-O; `y test` checks the host's).
    if macho {
        match crate::test::rt_core_only(&root, target) {
            Ok(()) => eprintln!("[y] test --cross {target} rt-core-only: ok"),
            Err(msg) => {
                eprintln!("[y] test --cross {target} rt-core-only: FAILED: {msg}");
                failed.push("rt-core-only");
            }
        }
    }
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
                    .filter(|s| !rt_imports.contains(&s.as_str()) && !jit_imports.contains(*s))
                    .filter(|s| !reference.contains(&format!("__declspec(dllimport) {s}")))
                    // The other way round: the image loads a foreign function's address through
                    // `__imp_` where plain rustc calls it directly (`abs` from the CRT). An
                    // import library defines both; for a static one the linker synthesizes it.
                    .filter(|s| s.strip_prefix("__declspec(dllimport) ").is_none_or(|plain| !reference.contains(plain)))
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
    // Mach-O has no constructor priorities: the registry's must come first in input order.
    if macho && !failed.contains(&"vm_sysroot") {
        let exe = out.join("vm_sysroot").join("ryo").join("vm_sysroot");
        match registry_first(&info, &exe) {
            Ok(()) => eprintln!("[y] test --cross {target} registry-first: ok"),
            Err(msg) => {
                eprintln!("[y] test --cross {target} registry-first: FAILED: {msg}");
                failed.push("registry-first");
            }
        }
    }
    if !failed.is_empty() {
        return Err(format!("failed cross tests: {}", failed.join(", ")));
    }
    Ok(())
}

/// The first entry of the linked Mach-O program `exe`'s `__mod_init_func` is the registry
/// constructor (it jumps to `_ryo_vm_register`), and another one, the program's own
/// (`tests/vm_sysroot.rs`'s, which enters the VM), follows it (design/platforms.md).
fn registry_first(info: &RustcInfo, exe: &Path) -> Result<(), String> {
    let objdump = crate::jit::llvm_tool(info, "llvm-objdump");
    let dump = crate::utils::output(cmd(&objdump).args(["-s", "-j", "__mod_init_func"]).arg(exe))?;
    // ` <address> <word> <word> <word> <word>  <ascii>` lines: little-endian 8-byte pointers.
    let hex: String = dump
        .lines()
        .filter(|l| l.starts_with(' '))
        .flat_map(|l| l.split_whitespace().skip(1).take(4).filter(|w| w.len() == 8 && w.chars().all(|c| c.is_ascii_hexdigit())))
        .collect();
    let bytes: Vec<u8> = (0..hex.len() / 2).map(|i| u8::from_str_radix(&hex[2 * i..2 * i + 2], 16).unwrap()).collect();
    let ptrs: Vec<u64> = bytes.chunks_exact(8).map(|c| u64::from_le_bytes(c.try_into().unwrap())).collect();
    let [first, _, ..] = ptrs[..] else {
        return Err(format!("{} has {} initializers, expected the registry's and the program's", exe.display(), ptrs.len()));
    };
    let dis = crate::utils::output(
        cmd(&objdump).arg("-d").arg(format!("--start-address={first:#x}")).arg(format!("--stop-address={:#x}", first + 18)).arg(exe),
    )?;
    if !dis.contains("<_ryo_vm_register>") {
        return Err(format!("the first initializer of {} (at {first:#x}) isn't the registry's:\n{dis}", exe.display()));
    }
    Ok(())
}

struct Link<'a> {
    target: &'a str,
    lld: PathBuf,
    stubs: PathBuf,
    /// The ld64 flavor (macOS) rather than lld-link.
    macho: bool,
    /// `dist/`'s std for the target.
    std_dir: PathBuf,
}

impl Link<'_> {
    /// Builds and links every crate of `program` with `compiler` into `dir`, and returns the
    /// symbols the links left unresolved.
    fn build(&self, compiler: &std::process::Command, program: &Program, dir: &Path, final_flags: &[&str]) -> Result<BTreeSet<String>, String> {
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
                .arg("-L")
                .arg(&self.stubs);
            if self.macho {
                // rustc asks `xcrun` for the SDK unless `SDKROOT` names one; the stand-ins are
                // all the SDK there is.
                c.args(["-Clinker-flavor=ld64.lld", "-Clink-arg=-flat_namespace", "-Clink-arg=-undefined", "-Clink-arg=warning"])
                    .env("SDKROOT", &self.stubs);
                // A flat namespace makes lld load the dependencies of dylibs too, std's among
                // them by `@rpath`: the same file in the toolchain's sysroot and in `dist/`.
                c.arg("-Clink-arg=-rpath").arg(format!("-Clink-arg={}", self.std_dir.display()));
            } else {
                c.args(["-Clinker-flavor=lld-link", "-Clink-arg=/force:unresolved", "-Clink-arg=/DEBUG:NONE"]);
            }
            if std::ptr::eq(krate, program.crates.last().unwrap()) {
                c.args(final_flags);
            }
            if krate.kind == CrateKind::Bin && !self.macho {
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
