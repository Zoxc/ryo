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
//! portal, an `__imp_` slot, the registry) shows up as a difference. The ryo builds must also compile the functions each
//! program lists to bytecode (`Program::check_vm`), so a silent fallback to LLVM fails.

use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

mod pe_unwind;

use crate::test::{CORPUS, Crate, CrateKind, Program};
use crate::utils::{RustcInfo, cmd, dist_bin, exe_name, root, ryo_rt_rlib};
use pe_unwind::pe_unwind;

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
/// kernel32 imports (`vm/rt/src/vm/sys.rs`, `seh.rs`, `jit/merge.rs`, `vm/bytecode/src/vmem.rs`, as lld names their `__imp_` references) and the
/// C runtime functions its code needs. The only unresolved symbols allowed besides plain
/// rustc's.
const RT_IMPORTS: &[&str] = &[
    "__declspec(dllimport) VirtualAlloc",
    "__declspec(dllimport) VirtualFree",
    "__declspec(dllimport) VirtualProtect",
    "__declspec(dllimport) GetStdHandle",
    "__declspec(dllimport) FlushInstructionCache",
    "__declspec(dllimport) WriteFile",
    "__declspec(dllimport) FlsAlloc",
    "__declspec(dllimport) FlsSetValue",
    "__declspec(dllimport) GetEnvironmentVariableA",
    // The run-time merge's rendezvous and module pinning (`vm/rt/src/vm/jit/merge.rs`, `sys.rs`).
    "__declspec(dllimport) ReadProcessMemory",
    "__declspec(dllimport) GetModuleHandleExW",
    // The PE exception handler's unwind to a terminate stub (`vm/rt/src/vm/seh.rs`).
    "__declspec(dllimport) RtlUnwindEx",
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
/// `vmem`, `jit/merge.rs`) and the unwinder's `_Unwind_Resume`, which `resume` jumps to.
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
    // Module pinning (`vm/rt/src/vm/sys.rs`) and the run-time merge's rendezvous page
    // (`vm/rt/src/vm/jit/merge.rs`).
    "_dladdr",
    "_dlopen",
    "_mach_task_self_",
    "_mach_vm_allocate",
    "_mach_vm_read_overwrite",
];

pub fn run(target: &str) -> Result<(), String> {
    let root = root();
    let info = RustcInfo::get()?;
    let dist = root.join("dist");
    let rustc_ryo = dist_bin(&root, "rustc-ryo");
    let rlib = ryo_rt_rlib(&root, target);
    if !rlib.exists() {
        return Err(format!("dist/ has no ryo_rt for {target}; run `./y.sh build --target {target}` first"));
    }
    let lld = dist.join("lib").join("rustlib").join(&info.host).join("bin").join(exe_name("rust-lld"));
    if !lld.exists() {
        return Err(format!("test --cross {target}: no rust-lld at {} (`./y.sh build` copies it)", lld.display()));
    }
    let out = root.join("target").join("tests-cross").join(target);
    let _ = fs::remove_dir_all(&out);
    let stubs = out.join("stub-libs");
    crate::utils::create_dir(&stubs)?;
    let macho = crate::target::is_macho(target);
    if macho {
        for lib in STUB_LIBS_MACHO {
            crate::utils::write(stubs.join(crate::target::static_lib_name(target, lib)), b"!<arch>\n")?;
        }
        // std's dylib loads libSystem by its install name, which lld looks up as a text stub
        // under the SDK root (`SDKROOT`, below): one that exports nothing.
        let usr_lib = stubs.join("usr").join("lib");
        crate::utils::create_dir(&usr_lib)?;
        crate::utils::write(usr_lib.join("libSystem.B.tbd"), LIBSYSTEM_TBD)?;
    } else {
        for lib in STUB_LIBS {
            crate::utils::write(stubs.join(crate::target::static_lib_name(target, lib)), b"!<arch>\n")?;
        }
    }
    let rt_imports = if macho { RT_IMPORTS_MACHO } else { RT_IMPORTS };
    let std_dir = dist.join("lib").join("rustlib").join(target).join("lib");
    let link = Link { info: &info, target, lld, stubs, macho, std_dir };

    let mut failed = Vec::new();
    // The sealed JIT bundled into this target's `ryo_rt` (design/jit.md#packaging), and its
    // undefined symbols, as lld names them.
    let mut jit_imports = BTreeSet::new();
    if crate::jit::supported(target) {
        let dir = out.join("jit-sealed");
        // As lld names them: ld64.lld with Mach-O's `_`, lld-link imports as dllimport. They
        // are C symbols (`check_sealed` rejects Rust ones), so need no demangling.
        let res = crate::jit::check_sealed(&info, &rlib, &dir, target).map(|undefined| {
            jit_imports = undefined
                .iter()
                .map(|s| match s.strip_prefix("__imp_") {
                    Some(f) => format!("__declspec(dllimport) {f}"),
                    None => crate::target::symbol(target, s),
                })
                .collect();
            String::new()
        });
        report(target, &mut failed, "jit-sealed", res);
    }
    // `ryo_rt` keeps to `core` (`y test` checks the host's).
    report(target, &mut failed, "rt-core-only", crate::test::rt_core_only(&info, &root, target).map(|()| String::new()));
    if !macho {
        report(target, &mut failed, "win64-i128", win64_i128(&info, target, &out.join("win64-i128")).map(|()| String::new()));
        report(target, &mut failed, "red-zone", no_red_zone(&info, &rlib, &out.join("red-zone")).map(|n| format!("{n} objects")));
    }
    for program in CORPUS {
        let res = (|| {
            let (reference, _) = link.build(&cmd("rustc"), program, &out.join(program.name).join("rustc"), &[])?;
            let mut unwind = 0;
            let builds = [("ryo", &[][..])];
            for (name, final_flags) in builds {
                let dir = out.join(program.name).join(name);
                let (ryo, vm_fns) = link.build(&cmd(&rustc_ryo), program, &dir, final_flags)?;
                program.check_vm(&vm_fns, true).map_err(|e| format!("{name}: {e}"))?;
                if !macho {
                    unwind += pe_unwind(&info, &dir).map_err(|e| format!("{name}: {e}"))?;
                }
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
            Ok(unwind)
        })();
        report(target, &mut failed, program.name, res.map(|n| if n == 0 { String::new() } else { format!("{n} unwind entries checked") }));
    }
    // Mach-O has no constructor priorities: the registry's must come first in input order.
    if macho && !failed.contains(&"vm_sysroot") {
        let exe = out.join("vm_sysroot").join("ryo").join("vm_sysroot");
        report(target, &mut failed, "registry-first", registry_first(&info, &exe).map(|()| String::new()));
    }
    if !failed.is_empty() {
        return Err(format!("failed cross tests: {}", failed.join(", ")));
    }
    Ok(())
}

/// Prints the outcome of the check `name` (`Ok` holds a note such as "3 objects", or nothing)
/// and records a failure in `failed`.
fn report(target: &str, failed: &mut Vec<&'static str>, name: &'static str, res: Result<String, String>) {
    match res {
        Ok(note) if note.is_empty() => eprintln!("[y] test --cross {target} {name}: ok"),
        Ok(note) => eprintln!("[y] test --cross {target} {name}: ok ({note})"),
        Err(msg) => {
            eprintln!("[y] test --cross {target} {name}: FAILED: {msg}");
            failed.push(name);
        }
    }
}

/// The initializers of the linked Mach-O program `exe` run the registry constructor first and
/// the program's own (`tests/vm_sysroot.rs`'s `ctor`, which enters the VM) second
/// (design/platforms.md). The initializers come from `__mod_init_func` (pointers: plain, as
/// lld writes them, or chained-fixup rebases, as ld64 and ld-prime do with chained fixups) or
/// from `__init_offsets` (4-byte offsets from the Mach-O header, ld-prime's). The registry's
/// is recognized by its `jmp` to `ryo_vm_register_<tag>` (or a stub for it), the program's by the
/// symbol at its address.
fn registry_first(info: &RustcInfo, exe: &Path) -> Result<(), String> {
    let objdump = info.tool("llvm-objdump");
    let nm = crate::utils::output(cmd(info.tool("llvm-nm")).args(["--defined-only", "--no-demangle"]).arg(exe))?;
    let mut syms: Vec<(u64, &str)> = nm
        .lines()
        .filter_map(|l| {
            let mut it = l.split_whitespace();
            let (a, _, name) = (it.next()?, it.next()?, it.next()?);
            Some((u64::from_str_radix(a, 16).ok()?, name))
        })
        .collect();
    syms.sort();
    let base = syms.iter().find(|s| s.1 == "__mh_execute_header").map(|s| s.0).ok_or("no __mh_execute_header symbol")?;
    let headers = crate::utils::output(cmd(&objdump).arg("-h").arg(exe))?;
    let section = |name: &str| -> Result<Vec<u8>, String> {
        if !headers.split_whitespace().any(|w| w == name) {
            return Ok(Vec::new());
        }
        let dump = crate::utils::output(cmd(&objdump).args(["-s", "-j", name]).arg(exe))?;
        // ` <address> <word> <word> <word> <word>  <ascii>` lines, words in memory order.
        let hex: String = dump
            .lines()
            .filter(|l| l.starts_with(' '))
            .flat_map(|l| {
                l.split_whitespace().skip(1).take(4).filter(|w| w.len() <= 8 && w.len() % 2 == 0 && w.chars().all(|c| c.is_ascii_hexdigit()))
            })
            .collect();
        Ok((0..hex.len() / 2).map(|i| u8::from_str_radix(&hex[2 * i..2 * i + 2], 16).unwrap()).collect())
    };
    let ptrs = section("__mod_init_func")?;
    let offsets = section("__init_offsets")?;
    let inits: Vec<u64> = if !ptrs.is_empty() {
        ptrs.chunks_exact(8)
            .map(|c| {
                let v = u64::from_le_bytes(c.try_into().unwrap());
                // A chained-fixup rebase (bit 63 clear) keeps its target in the low 36 bits:
                // a vmaddr (`DYLD_CHAINED_PTR_64`) or an offset from the header
                // (`DYLD_CHAINED_PTR_64_OFFSET`). A plain pointer is a vmaddr below 2^36.
                let t = v & ((1 << 36) - 1);
                if t < base { base + t } else { t }
            })
            .collect()
    } else {
        offsets.chunks_exact(4).map(|c| base + u64::from(u32::from_le_bytes(c.try_into().unwrap()))).collect()
    };
    let [registry, program, ..] = inits[..] else {
        return Err(format!("{} has {} initializers, expected the registry's and the program's", exe.display(), inits.len()));
    };
    let dis = crate::utils::output(
        cmd(&objdump).arg("-d").arg(format!("--start-address={registry:#x}")).arg(format!("--stop-address={:#x}", registry + 26)).arg(exe),
    )?;
    if !dis.lines().any(|l| l.contains("jmp") && l.contains("ryo_vm_register")) {
        return Err(format!("the first initializer of {} (at {registry:#x}) isn't the registry's:\n{dis}", exe.display()));
    }
    let names: Vec<&str> = syms.iter().filter(|s| s.0 == program).map(|s| s.1).collect();
    // `_RNvCs<hash>_10vm_sysroot4ctor` (v0) or `__ZN10vm_sysroot4ctor17h<hash>E` (legacy).
    if !names.iter().any(|n| n.contains("10vm_sysroot4ctor")) {
        return Err(format!("the second initializer of {} (at {program:#x}) isn't the program's `ctor`: {names:?}", exe.display()));
    }
    Ok(())
}

struct Link<'a> {
    info: &'a RustcInfo,
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
    /// symbols the links left unresolved and the functions compiled to bytecode (`RYO_STATS`).
    fn build(
        &self,
        compiler: &std::process::Command,
        program: &Program,
        dir: &Path,
        final_flags: &[&str],
    ) -> Result<(BTreeSet<String>, Vec<String>), String> {
        crate::utils::create_dir(dir)?;
        let tests = root().join("tests");
        let mut undefined = BTreeSet::new();
        let mut vm_fns = Vec::new();
        if let Some(lib) = &program.native_lib {
            lib.build(self.info, dir, Some(self.target))?;
        }
        let extra = |krate: &Crate, c: &mut Command| {
            c.env("RYO_STATS", "1").args(["--target", self.target]).arg(format!("-Clinker={}", self.lld.display())).arg("-L").arg(&self.stubs);
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
            if krate.kind == CrateKind::Bin && !self.macho {
                // There is no CRT to provide the default entry point.
                c.arg("-Clink-arg=/entry:mainCRTStartup");
            }
            // The map [`pe_unwind`] reads: `<output>.map`.
            let ext = match krate.kind {
                CrateKind::Bin => Some("exe"),
                CrateKind::Dylib | CrateKind::RlibDylib | CrateKind::Cdylib => Some("dll"),
                CrateKind::Rlib | CrateKind::Staticlib => None,
            };
            if let Some(ext) = ext
                && !self.macho
            {
                c.arg(format!("-Clink-arg=/lldmap:{}", dir.join(format!("{}.{ext}.map", krate.name)).display()));
            }
        };
        for (_, stderr) in program.compile(&tests, dir, || cmd(compiler.get_program()), extra, final_flags)? {
            undefined.extend(undefined_symbols(&stderr));
            vm_fns.extend(crate::test::vm_functions(&stderr));
        }
        Ok((undefined, vm_fns))
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

/// Checks that no code in `rlib` (`ryo_rt`, with the sealed JIT it bundles) accesses memory
/// below `rsp`: on Windows, exception dispatch, APCs and debuggers may write there, and LLVM
/// gives `sysv64` functions a red zone unless built with [`crate::jit::NO_REDZONE`]
/// (design/platforms.md). Returns how many objects it checked.
fn no_red_zone(info: &RustcInfo, rlib: &Path, dir: &Path) -> Result<usize, String> {
    let _ = fs::remove_dir_all(dir);
    crate::utils::create_dir(dir)?;
    crate::utils::run(cmd(info.tool("llvm-ar")).arg("x").arg(rlib).arg("--output").arg(dir))?;
    let objdump = info.tool("llvm-objdump");
    let mut n = 0;
    let mut bad = Vec::new();
    for e in fs::read_dir(dir).map_err(|e| e.to_string())? {
        let p = e.map_err(|e| e.to_string())?.path();
        if !p.extension().is_some_and(|x| x == "o" || x == "obj") {
            continue;
        }
        n += 1;
        let asm = crate::utils::output(cmd(&objdump).args(["-d", "--no-show-raw-insn", "--x86-asm-syntax=att"]).arg(&p))?;
        let mut func = "";
        for l in asm.lines() {
            if l.ends_with(">:") {
                func = l;
            }
            // A negative displacement off `rsp` (AT&T: `-0x40(%rsp)`), with or without an index.
            // The mnemonic is followed by a tab; `lea` computes an address without accessing it.
            if let Some(k) = l.find("(%rsp") {
                let lea = l.split_whitespace().nth(1).is_some_and(|w| w.starts_with("lea"));
                if !lea && l[..k].rsplit([' ', '\t', ',', '*']).next().is_some_and(|d| d.starts_with('-')) {
                    bad.push(format!("{}: {func} {}", p.file_name().unwrap().to_string_lossy(), l.trim()));
                }
            }
        }
    }
    if n == 0 {
        return Err(format!("no objects in {}", rlib.display()));
    }
    if !bad.is_empty() {
        return Err(format!("accesses below rsp:\n{}", bad.join("\n")));
    }
    Ok(n)
}

/// Functions of the Rust ABI with `i128`s, each moving one argument (or half) to `rax` or
/// building an `i128` return, and the code LLVM gives them on windows-msvc: the placement
/// `backend/src/lower/sig.rs` assumes (`arg_plan`, `ret_kind`).
const WIN64_I128: &[(&str, &str, &[&str])] = &[
    ("lo1", "(a: u128) -> u64 { a as u64 }", &["mov rax, rcx"]),
    ("hi1", "(a: u128) -> u64 { (a >> 64) as u64 }", &["mov rax, rdx"]),
    // Two positions, straddling `r9` and the first stack slot (past return address and shadow
    // space).
    ("lo4", "(_: u64, _: u64, _: u64, d: u128) -> u64 { d as u64 }", &["mov rax, r9"]),
    ("hi4", "(_: u64, _: u64, _: u64, d: u128) -> u64 { (d >> 64) as u64 }", &["mov rax, qword ptr [rsp + 0x28]"]),
    ("after", "(_: u64, _: u128, e: u64) -> u64 { e }", &["mov rax, r9"]),
    ("after4", "(_: u64, _: u64, _: u64, _: u128, e: u64) -> u64 { e }", &["mov rax, qword ptr [rsp + 0x30]"]),
    // `rax:rdx`, not `xmm0` (`extern "C"`'s).
    ("ret", "(a: u64, b: u64) -> u128 { ((b as u128) << 64) | a as u128 }", &["mov rax, rcx"]),
];

/// The Win64 `i128` placement of the Rust ABI ([`WIN64_I128`]): plain rustc's code for the
/// target, so an LLVM or rustc change to it shows here, from any host.
fn win64_i128(info: &RustcInfo, target: &str, dir: &Path) -> Result<(), String> {
    crate::utils::create_dir(dir)?;
    let mut src = String::from("#![no_std]\n");
    for (name, sig, _) in WIN64_I128 {
        src += &format!("#[unsafe(no_mangle)]\n#[inline(never)]\npub fn {name}{sig}\n");
    }
    let (rs, obj) = (dir.join("i128.rs"), dir.join("i128.obj"));
    crate::utils::write(&rs, src)?;
    crate::utils::run(
        cmd("rustc").args(["--edition=2024", "--crate-type=lib", "--emit=obj", "-Copt-level=3", "--target", target]).arg(&rs).arg("-o").arg(&obj),
    )?;
    let dis = crate::utils::output(cmd(info.tool("llvm-objdump")).args(["-d", "--no-show-raw-insn", "-M", "intel"]).arg(&obj))?;
    let mut bad = Vec::new();
    for (name, sig, want) in WIN64_I128 {
        let start = format!("<{name}>:");
        let body: Vec<String> = dis
            .lines()
            .skip_while(|l| !l.ends_with(&start))
            .skip(1)
            .take_while(|l| !l.trim().is_empty() && !l.ends_with(">:"))
            .filter_map(|l| {
                l.split_once(":\t")
                    .or_else(|| l.split_once(": "))
                    .map(|(_, i)| i.split('#').next().unwrap().split_whitespace().collect::<Vec<_>>().join(" "))
            })
            .filter(|i| !i.is_empty() && i != "ret")
            .collect();
        if body != *want {
            bad.push(format!("fn {name}{sig}: LLVM emits {body:?}, ryo assumes {want:?}"));
        }
    }
    if !bad.is_empty() {
        return Err(bad.join("\n"));
    }
    Ok(())
}
