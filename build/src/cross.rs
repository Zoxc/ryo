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

use crate::test::{CORPUS, Crate, CrateKind, Program};
use crate::utils::{RustcInfo, cmd, dist_bin, exe_name, root, ryo_rt_rlib};

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
/// kernel32 imports (`vm/rt/src/vm/sys.rs`, `seh.rs`, `vm/bytecode/src/vmem.rs`, as lld names their `__imp_` references) and the
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
    let macho = crate::jit::macho(target);
    if macho {
        for lib in STUB_LIBS_MACHO {
            crate::utils::write(stubs.join(format!("lib{lib}.a")), b"!<arch>\n")?;
        }
        // std's dylib loads libSystem by its install name, which lld looks up as a text stub
        // under the SDK root (`SDKROOT`, below): one that exports nothing.
        let usr_lib = stubs.join("usr").join("lib");
        crate::utils::create_dir(&usr_lib)?;
        crate::utils::write(usr_lib.join("libSystem.B.tbd"), LIBSYSTEM_TBD)?;
    } else {
        for lib in STUB_LIBS {
            crate::utils::write(stubs.join(format!("{lib}.lib")), b"!<arch>\n")?;
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
        let res = crate::jit::check_sealed(&info, &rlib, &dir, target).and_then(|()| {
            let nm = info.tool("llvm-nm");
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
    // `ryo_rt` keeps to `core` (`y test` checks the host's).
    match crate::test::rt_core_only(&info, &root, target) {
        Ok(()) => eprintln!("[y] test --cross {target} rt-core-only: ok"),
        Err(msg) => {
            eprintln!("[y] test --cross {target} rt-core-only: FAILED: {msg}");
            failed.push("rt-core-only");
        }
    }
    if !macho {
        match win64_i128(&info, target, &out.join("win64-i128")) {
            Ok(()) => eprintln!("[y] test --cross {target} win64-i128: ok"),
            Err(msg) => {
                eprintln!("[y] test --cross {target} win64-i128: FAILED: {msg}");
                failed.push("win64-i128");
            }
        }
        match no_red_zone(&info, &rlib, &out.join("red-zone")) {
            Ok(n) => eprintln!("[y] test --cross {target} red-zone: ok ({n} objects)"),
            Err(msg) => {
                eprintln!("[y] test --cross {target} red-zone: FAILED: {msg}");
                failed.push("red-zone");
            }
        }
    }
    for program in CORPUS {
        let res = (|| {
            let (reference, _) = link.build(&cmd("rustc"), program, &out.join(program.name).join("rustc"), &[])?;
            let mut unwind = 0;
            let mut builds = vec![("ryo", &[][..])];
            // `-Clto` on the last crate, as cargo passes it (no Rust dylibs).
            if !program.has_dylib() {
                builds.push(("ryo-lto", &["-Clto=fat"][..]));
            }
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
        match res {
            Ok(0) => eprintln!("[y] test --cross {target} {}: ok", program.name),
            Ok(n) => eprintln!("[y] test --cross {target} {}: ok ({n} unwind entries checked)", program.name),
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

/// The initializers of the linked Mach-O program `exe` run the registry constructor first and
/// the program's own (`tests/vm_sysroot.rs`'s `ctor`, which enters the VM) second
/// (design/platforms.md). The initializers come from `__mod_init_func` (pointers: plain, as
/// lld writes them, or chained-fixup rebases, as ld64 and ld-prime do with chained fixups) or
/// from `__init_offsets` (4-byte offsets from the Mach-O header, ld-prime's). The registry's
/// is recognized by its `jmp` to `_ryo_vm_register` (or a stub for it), the program's by the
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
        cmd(&objdump).arg("-d").arg(format!("--start-address={registry:#x}")).arg(format!("--stop-address={:#x}", registry + 19)).arg(exe),
    )?;
    if !dis.lines().any(|l| l.contains("jmp") && l.contains("_ryo_vm_register")) {
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
    /// [`super::pe_unwind_file`]'s parts on excerpts of lld's map, `llvm-readobj --unwind` and
    /// `llvm-objdump -d`: a VM function whose codes match its prologue, a stub that pushes
    /// without an entry (as `ryo_probe_stack` once did), and an entry whose codes don't match.
    #[test]
    fn checks_pe_unwind() {
        use super::*;
        let map = "Address  Size     Align Out     In      Symbol\n\
                   00001000 00000100  4096 .text\n\
                   00001000 00000020    16         ryo_rt-1.ryo_rt.0-cgu.0.rcgu.o:(.text)\n\
                   00001000 00000000     0                 __rustc::ryo_probe_stack\n\
                   00001040 00000040    16         /x/a.ryo_image.rcgu.o:(.text$ryo_image)\n\
                   00001080 00000040    16         /x/std.o:(.text)\n";
        let units = pe_units(map, 0x1_4000_0000);
        assert_eq!(units, [(0x1_4000_1000, 0x1_4000_1020, false), (0x1_4000_1040, 0x1_4000_1080, true)]);
        let dis = "0000000140001000 <.text>:\n\
                   140001000:     \tpushq\t%rax\n\
                   140001001:     \ttestq\t%r11, (%r11)\n\
                   140001004:     \tpopq\t%rax\n\
                   140001005:     \tretq\n\
                   140001040:     \tpushq\t%rbp\n\
                   140001041:     \tmovq\t%rsp, %rbp\n\
                   140001044:     \tmovl\t$0x1000, %eax\n\
                   140001049:     \tcallq\t0x140001000 <.text>\n\
                   14000104e:     \tsubq\t$0x70, %rsp\n\
                   140001052:     \tmovaps\t%xmm6, 0x10(%rsp)\n\
                   140001057:     \tmovq\t%rcx, -0x40(%rbp)\n\
                   14000105b:     \taddq\t$0x70, %rsp\n\
                   14000105f:     \tpopq\t%rbp\n\
                   140001060:     \tretq\n";
        let insns = pe_instructions(dis);
        assert_eq!(insns.len(), 14);
        assert!(moves_rsp(&insns[0]) && !moves_rsp(&insns[1]) && moves_rsp(&insns[8]) && !moves_rsp(&insns[7]));
        let codes: Vec<_> = insns[4..10].iter().filter_map(|i| prologue_code(i, None)).collect();
        assert_eq!(codes, ["push rbp", "setfp rbp 0", "alloc 112", "savexmm xmm6 16"]);
        let unwind = "UnwindInformation [\n  RuntimeFunction {\n    StartAddress: (0x140001040)\n    EndAddress: (0x140001061)\n\
                      UnwindInfo {\n      PrologSize: 23\n      UnwindCodes [\n        0x17: SAVE_XMM128 reg=XMM6, offset=0x10\n\
                      0x12: ALLOC_SMALL size=112\n        0x04: SET_FPREG reg=RBP, offset=0x0\n        0x01: PUSH_NONVOL reg=RBP\n      ]\n    }\n  }\n]\n";
        let funcs = pe_runtime_functions(unwind).unwrap();
        assert_eq!(funcs.len(), 1);
        assert_eq!((funcs[0].begin, funcs[0].end, funcs[0].prolog), (0x1_4000_1040, 0x1_4000_1061, 23));
        let mut got = funcs[0].codes.clone();
        got.sort();
        let want: Vec<(u32, String)> =
            [(1, "push rbp"), (4, "setfp rbp 0"), (0x12, "alloc 112"), (0x17, "savexmm xmm6 16")].map(|(o, c)| (o, c.to_owned())).into();
        assert_eq!(got, want);
        assert_eq!(unwind_code("SAVE_NONVOL reg=RSI, offset=0x8"), "save rsi 8");
        assert_eq!(prologue_code(&Insn { addr: 0, op: "subq", args: "%rax, %rsp" }, Some(0x2000)).as_deref(), Some("alloc 8192"));
        assert_eq!(prologue_code(&Insn { addr: 0, op: "pushq", args: "%rax" }, None).as_deref(), Some("alloc 8"));
        assert_eq!(prologue_code(&Insn { addr: 0, op: "movq", args: "%rcx, 0x8(%rsp)" }, None), None);
    }

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
            if let Some(k) = l.find("(%rsp") {
                if l[..k].rsplit([' ', ',', '*']).next().is_some_and(|d| d.starts_with('-')) {
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

/// Checks the Win64 unwind information of the PE outputs in `dir` (each with the
/// `<output>.map` lld wrote): in the code of the VM images (`.text$ryo_image`) and of
/// `ryo_rt`, every instruction that moves `rsp` (but `call` and `ret`) lies in a
/// `RUNTIME_FUNCTION`, or the unwinder takes its function for a leaf and reads the return
/// address from `[rsp]`; and the unwind codes of every such entry are those of the
/// instructions of its prologue; and the VM code's epilogues free the prologue's allocation.
/// Returns how many entries it checked.
fn pe_unwind(info: &RustcInfo, dir: &Path) -> Result<usize, String> {
    let mut n = 0;
    for e in fs::read_dir(dir).map_err(|e| e.to_string())? {
        let map = e.map_err(|e| e.to_string())?.path();
        let Some(file) = map.to_str().and_then(|m| m.strip_suffix(".map")) else { continue };
        let file = PathBuf::from(file);
        if !file.exists() {
            return Err(format!("{} has no output {}", map.display(), file.display()));
        }
        n += pe_unwind_file(info, &file, &fs::read_to_string(&map).map_err(|e| e.to_string())?)
            .map_err(|e| format!("{}: {e}", file.file_name().unwrap().to_string_lossy()))?;
    }
    Ok(n)
}

/// [`pe_unwind`] of one output, `file`, with lld's map `map`.
fn pe_unwind_file(info: &RustcInfo, file: &Path, map: &str) -> Result<usize, String> {
    let headers = crate::utils::output(cmd(info.tool("llvm-readobj")).arg("--file-headers").arg(file))?;
    let base = headers
        .lines()
        .find_map(|l| l.trim().strip_prefix("ImageBase: "))
        .and_then(|v| u64::from_str_radix(v.trim_start_matches("0x"), 16).ok())
        .ok_or("no ImageBase")?;
    let units = pe_units(map, base);
    if !units.iter().any(|u| u.2) {
        return Err("no VM image code in the map".to_owned());
    }
    let funcs = pe_runtime_functions(&crate::utils::output(cmd(info.tool("llvm-readobj")).arg("--unwind").arg(file))?)?;
    let dis = crate::utils::output(cmd(info.tool("llvm-objdump")).args(["-d", "--no-show-raw-insn", "--x86-asm-syntax=att"]).arg(file))?;
    let insns = pe_instructions(&dis);
    let in_units = |a: u64| units.iter().any(|&(b, e, _)| (b..e).contains(&a));
    let mut bad = Vec::new();
    // Every `rsp` move in the units is covered.
    for insn in &insns {
        if in_units(insn.addr) && moves_rsp(insn) {
            // `funcs` is sorted by start.
            let k = funcs.partition_point(|f| f.begin <= insn.addr);
            if k == 0 || funcs[k - 1].end <= insn.addr {
                bad.push(format!("{:#x}: `{} {}` moves rsp outside any RUNTIME_FUNCTION", insn.addr, insn.op, insn.args));
            }
        }
    }
    // The epilogues of VM code (`add rsp, F; pop rbp`) free what the prologue allocated: Win64
    // takes `add rsp` as undoing the prologue's `ALLOC`, and the code relies on `rsp == rbp -
    // F` there (design/vm.md#frames).
    let covering = |a: u64| {
        let k = funcs.partition_point(|f| f.begin <= a);
        (k > 0 && a < funcs[k - 1].end).then(|| &funcs[k - 1])
    };
    for w in insns.windows(2) {
        if w[1].op == "popq"
            && w[1].args == "%rbp"
            && w[0].op == "addq"
            && w[0].args.ends_with(", %rsp")
            && units.iter().any(|&(b, e, image)| image && (b..e).contains(&w[0].addr))
        {
            let alloc: u64 =
                covering(w[0].addr).map_or(0, |f| f.codes.iter().filter_map(|(_, c)| c.strip_prefix("alloc ")?.parse::<u64>().ok()).sum());
            if parse_imm(w[0].args.split(',').next().unwrap()) != Some(alloc) {
                bad.push(format!("{:#x}: epilogue `addq {}` doesn't free the prologue's {alloc} bytes", w[0].addr, w[0].args));
            }
        }
    }
    let mut n = 0;
    for f in funcs.iter().filter(|f| in_units(f.begin) && !f.chained) {
        n += 1;
        let start = insns.partition_point(|i| i.addr < f.begin);
        let mut want = Vec::new();
        let mut eax = None;
        for (k, insn) in insns[start..].iter().enumerate() {
            if insn.addr >= f.begin + u64::from(f.prolog) {
                break;
            }
            let Some(next) = insns.get(start + k + 1) else { break };
            let off = (next.addr - f.begin) as u32;
            if insn.op.starts_with("movl") && insn.args.ends_with(", %eax") {
                eax = parse_imm(insn.args.split(',').next().unwrap());
            }
            if let Some(code) = prologue_code(insn, eax) {
                want.push((off, code));
            }
        }
        let mut got = f.codes.clone();
        want.sort();
        got.sort();
        if want != got {
            bad.push(format!("{:#x}: unwind codes {got:?}, but the prologue is {want:?}", f.begin));
        }
    }
    if !bad.is_empty() {
        bad.truncate(20);
        return Err(format!("unwind information:\n{}", bad.join("\n")));
    }
    Ok(n)
}

/// The code ranges [`pe_unwind`] checks, as virtual addresses, from lld's map (`/lldmap`:
/// `<rva> <size> <align>` and the output section, then its input sections, `<file>:(<name>)`,
/// then their symbols), with whether each is a VM image's.
fn pe_units(map: &str, base: u64) -> Vec<(u64, u64, bool)> {
    let mut units = Vec::new();
    for l in map.lines().skip(1) {
        let mut it = l.split_whitespace();
        let (Some(addr), Some(size), Some(_), Some(input), None) = (it.next(), it.next(), it.next(), it.next(), it.next()) else { continue };
        let Some((path, section)) = input.rsplit_once(":(") else { continue };
        let (Ok(addr), Ok(size)) = (u64::from_str_radix(addr, 16), u64::from_str_radix(size, 16)) else { continue };
        let section = section.trim_end_matches(')');
        let name = path.rsplit(['/', '\\']).next().unwrap_or(path);
        let image = section == ".text$ryo_image";
        if size > 0 && (image || (section.starts_with(".text") && name.starts_with("ryo_rt-"))) {
            units.push((base + addr, base + addr + size, image));
        }
    }
    units
}

/// One `RUNTIME_FUNCTION` with its `UNWIND_INFO`, the codes as [`prologue_code`] names them.
struct RuntimeFunction {
    begin: u64,
    end: u64,
    prolog: u8,
    chained: bool,
    codes: Vec<(u32, String)>,
}

/// The entries `llvm-readobj --unwind` prints, sorted by start.
fn pe_runtime_functions(dump: &str) -> Result<Vec<RuntimeFunction>, String> {
    let addr = |l: &str| l.rsplit_once("(0x").and_then(|(_, a)| u64::from_str_radix(a.trim_end_matches(')'), 16).ok());
    let mut funcs: Vec<RuntimeFunction> = Vec::new();
    for l in dump.lines().map(str::trim) {
        if l.starts_with("RuntimeFunction {") {
            funcs.push(RuntimeFunction { begin: 0, end: 0, prolog: 0, chained: false, codes: Vec::new() });
        }
        let Some(f) = funcs.last_mut() else { continue };
        if let Some(v) = l.strip_prefix("StartAddress: ") {
            f.begin = addr(v).ok_or_else(|| format!("bad line `{l}`"))?;
        } else if let Some(v) = l.strip_prefix("EndAddress: ") {
            f.end = addr(v).ok_or_else(|| format!("bad line `{l}`"))?;
        } else if let Some(v) = l.strip_prefix("PrologSize: ") {
            f.prolog = v.parse().map_err(|_| format!("bad line `{l}`"))?;
        } else if l.starts_with("ChainInfo") {
            f.chained = true;
        } else if let Some((off, code)) = l.split_once(": ")
            && let Some(off) = off.strip_prefix("0x").and_then(|o| u32::from_str_radix(o, 16).ok())
        {
            f.codes.push((off, unwind_code(code)));
        }
    }
    funcs.sort_by_key(|f| f.begin);
    Ok(funcs)
}

/// An unwind code as `llvm-readobj` prints it (`PUSH_NONVOL reg=RBP`), in [`prologue_code`]'s
/// form; an unknown one as it is.
fn unwind_code(code: &str) -> String {
    let field = |k: &str| code.split([' ', ',']).find_map(|w| w.strip_prefix(k)).unwrap_or("");
    let num = |v: &str| v.strip_prefix("0x").map_or_else(|| v.parse().ok(), |h| u64::from_str_radix(h, 16).ok()).unwrap_or(u64::MAX);
    let reg = field("reg=").to_ascii_lowercase();
    match code.split_whitespace().next().unwrap_or("") {
        "PUSH_NONVOL" => format!("push {reg}"),
        "ALLOC_SMALL" | "ALLOC_LARGE" => format!("alloc {}", num(field("size="))),
        "SET_FPREG" => format!("setfp {reg} {}", num(field("offset="))),
        "SAVE_NONVOL" | "SAVE_NONVOL_FAR" => format!("save {reg} {}", num(field("offset="))),
        "SAVE_XMM128" | "SAVE_XMM128_FAR" => format!("savexmm {reg} {}", num(field("offset="))),
        _ => code.to_owned(),
    }
}

/// An instruction of `llvm-objdump -d --no-show-raw-insn` (AT&T).
struct Insn<'a> {
    addr: u64,
    op: &'a str,
    args: &'a str,
}

fn pe_instructions(dis: &str) -> Vec<Insn<'_>> {
    dis.lines()
        .filter_map(|l| {
            let (addr, rest) = l.trim_start().split_once(':')?;
            let addr = u64::from_str_radix(addr, 16).ok()?;
            let rest = rest.trim();
            let (op, args) = rest.split_once(char::is_whitespace).unwrap_or((rest, ""));
            Some(Insn { addr, op, args: args.split('#').next().unwrap().trim() })
        })
        .collect()
}

/// Whether `insn` writes `rsp`, other than as a call or a return does.
fn moves_rsp(insn: &Insn<'_>) -> bool {
    insn.op.starts_with("push")
        || insn.op.starts_with("pop")
        || (insn.args.ends_with("%rsp") && !insn.op.starts_with("cmp") && !insn.op.starts_with("test"))
}

/// The registers Win64 callee-saved.
const NONVOLATILE: [&str; 8] = ["rbx", "rbp", "rdi", "rsi", "r12", "r13", "r14", "r15"];

/// `$0x28` or `0x28(...)` / `-0x10(...)`.
fn parse_imm(s: &str) -> Option<u64> {
    let s = s.trim().trim_start_matches('$');
    let s = s.split('(').next()?;
    if s.is_empty() {
        return Some(0);
    }
    let (neg, s) = s.strip_prefix('-').map_or((false, s), |s| (true, s));
    let v = s.strip_prefix("0x").map_or_else(|| s.parse().ok(), |h| u64::from_str_radix(h, 16).ok())?;
    Some(if neg { v.wrapping_neg() } else { v })
}

/// The unwind code a prologue instruction needs, in [`unwind_code`]'s form, or `None` if it
/// needs none. `eax` is the value last moved to `eax` (`__chkstk`'s size, for a `sub rsp, rax`).
fn prologue_code(insn: &Insn<'_>, eax: Option<u64>) -> Option<String> {
    let (src, dst) = insn.args.rsplit_once(", ").unwrap_or((insn.args, ""));
    let reg = |r: &str| r.strip_prefix('%').map(str::to_owned);
    match insn.op {
        "pushq" => {
            let r = reg(src)?;
            Some(if NONVOLATILE.contains(&r.as_str()) { format!("push {r}") } else { "alloc 8".to_owned() })
        }
        "subq" if dst == "%rsp" => Some(format!("alloc {}", if src == "%rax" { eax? } else { parse_imm(src)? })),
        "movq" if src == "%rsp" && dst == "%rbp" => Some("setfp rbp 0".to_owned()),
        "leaq" if dst == "%rbp" && src.ends_with("(%rsp)") => Some(format!("setfp rbp {}", parse_imm(src)?)),
        "movq" if dst.ends_with("(%rsp)") => {
            let r = reg(src)?;
            NONVOLATILE.contains(&r.as_str()).then(|| format!("save {r} {}", parse_imm(dst).unwrap_or(u64::MAX)))
        }
        "movaps" | "movups" | "movdqa" | "movdqu" if dst.ends_with("(%rsp)") => {
            let r = reg(src)?;
            let n: u32 = r.strip_prefix("xmm")?.parse().ok()?;
            (n >= 6).then(|| format!("savexmm {r} {}", parse_imm(dst).unwrap_or(u64::MAX)))
        }
        _ => None,
    }
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
