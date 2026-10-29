//! Several ryo runtimes in one link or process (design/vm.md#several-ryo-runtimes-in-one-process):
//! `tests/multi_ryo/` linked and loaded in the ways the design supports. Linux (GNU ld and lld
//! for the C links); hosts with the JIT only.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use super::{JIT_OFF, JIT_SYNC};
use crate::utils::{RustcInfo, capture, capture_ok, cmd, run};

/// The C link's native libraries for a Rust staticlib on Linux (`--print=native-static-libs`).
const NATIVE_LIBS: &[&str] = &["-lgcc_s", "-lutil", "-lrt", "-lpthread", "-lm", "-ldl", "-lc"];

fn applies(info: &RustcInfo) -> bool {
    cfg!(target_os = "linux") && crate::jit::supported(&info.host)
}

/// Runs `exe` (with `env`), failing unless it succeeds; its stdout.
fn run_out(exe: &Path, args: &[&str], env: &[(&str, &str)]) -> Result<String, String> {
    Ok(capture_ok(Command::new(exe).args(args).envs(env.iter().copied()))?.stdout)
}

/// The output of `run` without the JIT, then with it ([`JIT_OFF`], [`JIT_SYNC`]).
fn plain_and_jit(run: impl Fn(&[(&str, &str)]) -> Result<String, String>) -> Result<(String, String), String> {
    Ok((run(JIT_OFF)?, run(JIT_SYNC)?))
}

/// The first line of `s`, or `""`.
fn first_line(s: &str) -> &str {
    s.lines().next().unwrap_or("")
}

/// `cc` with GNU ld or lld (the toolchain's, through its `gcc-ld` wrapper).
fn cc(info: &RustcInfo, lld: bool) -> Command {
    let mut c = cmd("cc");
    if lld {
        c.arg("-fuse-ld=lld").arg("-B").arg(crate::utils::rustlib(&info.sysroot, &info.host).join("bin").join("gcc-ld"));
    } else {
        c.arg("-fuse-ld=bfd");
    }
    c
}

/// Same-version ryo staticlibs in one C program: two and three of them, in both orders, with
/// GNU ld and lld, each running correctly with and without the JIT. These links happen to pull
/// only one archive's runtime members today; that isn't guaranteed (design/vm.md, "Several
/// runtimes"), and a link that pulls two fails on duplicate symbols. That failure is asserted
/// only with `--whole-archive`, which pulls every member (the users' std and the runtime
/// collide: the documented limitation). Staticlibs each
/// combined into one object with their std localized (`ld -r` + `objcopy
/// --keep-global-symbol`) link and run as two runtimes, each registering its own images
/// (anchor ownership).
pub(super) fn multi_staticlib(info: &RustcInfo, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if !applies(info) {
        return Ok(());
    }
    let dir = out.join("multi-staticlib");
    crate::utils::create_dir(&dir)?;
    let lib = |name: &str| -> Result<PathBuf, String> {
        let a = dir.join(format!("lib{name}.a"));
        run(cmd(rustc_ryo)
            .args(["--edition=2024", "-Copt-level=1", "--crate-type=staticlib", "--crate-name", name])
            .arg(src.join(format!("{name}.rs")))
            .arg("-o")
            .arg(&a))?;
        Ok(a)
    };
    let (a, b, c) = (lib("a")?, lib("b")?, lib("c")?);
    let link = |name: &str, lld: bool, main: &str, libs: &[&Path], whole: bool| -> Result<(PathBuf, crate::utils::Captured), String> {
        let exe = dir.join(name);
        let mut l = cc(info, lld);
        l.arg(src.join(main)).arg("-o").arg(&exe);
        if whole {
            l.arg("-Wl,--whole-archive");
        }
        l.args(libs);
        if whole {
            l.arg("-Wl,--no-whole-archive");
        }
        Ok((exe, capture(l.args(NATIVE_LIBS))?))
    };
    // The first output of each `main`, which the other links of it must match.
    let mut wants: Vec<(&str, String)> = Vec::new();
    for lld in [false, true] {
        let ld = if lld { "lld" } else { "bfd" };
        for (main, libs) in [("main2.c", vec![&a, &b]), ("main2.c", vec![&b, &a]), ("main3.c", vec![&a, &b, &c]), ("main3.c", vec![&c, &b, &a])] {
            let names: Vec<String> = libs.iter().map(|l| l.file_stem().unwrap().to_string_lossy().into_owned()).collect();
            let name = format!("{}-{ld}", names.join("-"));
            let libs: Vec<&Path> = libs.iter().map(|p| p.as_path()).collect();
            let (exe, res) = link(&name, lld, main, &libs, false)?;
            if !res.status.success() {
                return Err(format!("{name}: the link failed:\n{}", res.stderr));
            }
            let (plain, jit) = plain_and_jit(|env| run_out(&exe, &[], env))?;
            match wants.iter().find(|w| w.0 == main) {
                Some((_, want)) if plain != *want => return Err(format!("{name}: {plain:?}, expected {want:?}")),
                Some(_) => {}
                None => wants.push((main, plain.clone())),
            }
            if jit != plain {
                return Err(format!("{name}: with the JIT {jit:?}, without {plain:?}"));
            }
        }
    }
    // Every member pulled: the users' std and the runtimes collide (unsupported).
    let (_, res) = link("whole-bfd", false, "main2.c", &[&a, &b], true)?;
    if res.status.success() || !res.stderr.contains("multiple definition") {
        return Err(format!("--whole-archive: expected duplicate symbols, got {}:\n{}", res.status, res.stderr));
    }
    // Each staticlib with its std hidden: two runtimes, each registering only its own images.
    let mut blobs = Vec::new();
    for (lib, keep) in [(&a, &["a_run"][..]), (&b, &["b_run", "b_count"][..])] {
        let stem = lib.file_stem().unwrap().to_string_lossy().into_owned();
        let blob = dir.join(format!("{stem}-blob.o"));
        run(cmd("ld.bfd").arg("-r").arg("--whole-archive").arg(lib).arg("-o").arg(&blob))?;
        let hidden = dir.join(format!("{stem}-hidden.o"));
        let mut oc = cmd("objcopy");
        for k in keep {
            oc.arg(format!("--keep-global-symbol={k}"));
        }
        run(oc.arg(&blob).arg(&hidden))?;
        let ar = dir.join(format!("{stem}-hidden.a"));
        let _ = fs::remove_file(&ar);
        run(cmd("ar").arg("rcs").arg(&ar).arg(&hidden))?;
        blobs.push(ar);
    }
    let (exe, res) = link("hidden-bfd", false, "main2.c", &[&blobs[0], &blobs[1]], false)?;
    if !res.status.success() {
        return Err(format!("hidden std: the link failed:\n{}", res.stderr));
    }
    let (plain, jit) = plain_and_jit(|env| run_out(&exe, &[], env))?;
    let want = wants.into_iter().find(|w| w.0 == "main2.c").map(|w| w.1).unwrap_or_default();
    if plain != want || jit != want {
        return Err(format!("hidden std: {plain:?} / with the JIT {jit:?}, expected {want:?}"));
    }
    Ok(())
}

/// The ryo symbols a shared object exports (`llvm-nm -D`): the runtime's own (`ryo_rt`,
/// `ryo_bytecode`, its tagged entry points) must stay private to every module.
fn exported_runtime(info: &RustcInfo, so: &Path) -> Result<Vec<String>, String> {
    let mut syms = crate::utils::nm_symbols(info, &["-D", "--defined-only"], so, &info.host)?;
    syms.retain(|s| s.contains("ryo_vm_register") || super::is_runtime_symbol(s));
    Ok(syms)
}

/// The `jit threads: <n>` line of `tests/multi_ryo`'s programs.
fn jit_threads(stdout: &str) -> Option<usize> {
    stdout.lines().find_map(|l| l.strip_prefix("jit threads: ")).and_then(|n| n.trim().parse().ok())
}

/// Several ryo modules in one process:
/// - a ryo cdylib `dlopen`ed by a ryo executable, `RTLD_LOCAL` and `RTLD_GLOBAL`, and by one
///   exporting its symbols (`-Zexport-executable-symbols`): two instances (the cdylib has its
///   own std), and the cdylib exports nothing of the runtime, so no module captures another's
///   registration;
/// - sibling Rust dylibs (neither depends on the other) under an executable, with
///   `-Cprefer-dynamic`: they build (each module links a private runtime copy), export
///   nothing of the runtime, and merge into one instance (one JIT thread), or stay three with
///   `RYO_JIT_MERGE=0`; `dlclose`d by a C program after merging, they stay loaded.
pub(super) fn multi_dylib(info: &RustcInfo, root: &Path, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if !applies(info) {
        return Ok(());
    }
    let dir = out.join("multi-dylib");
    crate::utils::create_dir(&dir)?;
    let rustc = |args: &[&str], file: &str, o: &Path| {
        run(cmd(rustc_ryo).arg("--edition=2024").arg("-Copt-level=1").args(args).arg(src.join(file)).arg("-o").arg(o))
    };

    let plugin = dir.join("libplugin.so");
    rustc(&["--crate-type=cdylib"], "plugin.rs", &plugin)?;
    if let bad @ [_, ..] = &exported_runtime(info, &plugin)?[..] {
        return Err(format!("the cdylib exports runtime symbols {bad:?}"));
    }
    for (name, flags) in [("host", &[][..]), ("host-export", &["-Zexport-executable-symbols"][..])] {
        let host = dir.join(name);
        rustc(flags, "host.rs", &host)?;
        let plugin = plugin.to_str().ok_or("non-UTF-8 path")?;
        for mode in ["local", "global"] {
            let (plain, jit) = plain_and_jit(|env| run_out(&host, &[plugin, mode], env))?;
            if first_line(&jit) != first_line(&plain) || jit_threads(&jit) != Some(2) {
                return Err(format!("{name} {mode}: with the JIT {jit:?}, without {plain:?} (expected two JIT threads)"));
            }
        }
    }

    let dy = ["--crate-type=dylib", "-Cprefer-dynamic"];
    rustc(&[&dy[..], &["--crate-name", "da"]].concat(), "da.rs", &dir.join("libda.so"))?;
    rustc(&[&dy[..], &["--crate-name", "db"]].concat(), "db.rs", &dir.join("libdb.so"))?;
    for so in ["libda.so", "libdb.so"] {
        if let bad @ [_, ..] = &exported_runtime(info, &dir.join(so))?[..] {
            return Err(format!("{so} exports runtime symbols {bad:?}"));
        }
    }
    let exe = dir.join("dexe");
    let ext = |n: &str| format!("{n}={}", dir.join(format!("lib{n}.so")).display());
    rustc(&["-Cprefer-dynamic", "--extern", &ext("da"), "--extern", &ext("db"), "-L", dir.to_str().ok_or("non-UTF-8 path")?], "dexe.rs", &exe)?;
    let std_dir = crate::utils::rustlib(&root.join("dist"), &info.host).join("lib");
    let lib_path = crate::utils::prepend_paths("LD_LIBRARY_PATH", [dir.clone(), std_dir])?;
    // `run_out` with the libraries' directories on the search path.
    let run_libs = |exe: &Path, args: &[&str], env: &[(&str, &str)]| -> Result<String, String> {
        Ok(capture_ok(Command::new(exe).args(args).env("LD_LIBRARY_PATH", &lib_path).envs(env.iter().copied()))?.stdout)
    };
    let plain = run_libs(&exe, &[], JIT_OFF)?;
    for (merge, threads) in [("1", 1), ("0", 3)] {
        let jit = run_libs(&exe, &[], &[&[("RYO_JIT_MERGE", merge)], JIT_SYNC].concat())?;
        if first_line(&jit) != first_line(&plain) || jit_threads(&jit) != Some(threads) {
            return Err(format!("sibling dylibs, RYO_JIT_MERGE={merge}: with the JIT {jit:?}, without {plain:?} (expected {threads} JIT threads)"));
        }
    }
    // Merged copies closed again: both the winner (closed before its JIT starts) and a joiner
    // stay loaded.
    let host = dir.join("dlhost");
    run(cc(info, false).arg(src.join("dlhost.c")).arg("-o").arg(&host).arg("-ldl"))?;
    let (da, db) = (dir.join("libda.so"), dir.join("libdb.so"));
    let args = [da.to_str().ok_or("non-UTF-8 path")?, db.to_str().ok_or("non-UTF-8 path")?];
    let out = run_libs(&host, &args, JIT_SYNC)?;
    if out != "990000\nloaded after dlclose: 1 1\n" {
        return Err(format!("dlclose of merged dylibs: {out:?}, expected both pinned"));
    }
    Ok(())
}

/// Two ryo builds: a second `dist/` built with another ABI tag (`RYO_ABI_OVERRIDE`, in
/// `target/abi-alt/`; a full `y build`):
/// - a staticlib of each in one C program links (disjoint names) and runs, the JIT on, as two
///   runtimes;
/// - an executable of one dlopening a cdylib of the other runs;
/// - a crate of one against an rlib of the other is rustc's error (`ryo_rt`'s crate hash).
pub(super) fn multi_version(info: &RustcInfo, root: &Path, rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    if !applies(info) {
        return Ok(());
    }
    let alt = root.join("target").join("abi-alt");
    let alt_dist = alt.join("dist");
    let y = std::env::current_exe().map_err(|e| e.to_string())?;
    run(cmd(&y)
        .arg("build")
        .env(crate::dist::ABI_OVERRIDE_VAR, "alt")
        .env(crate::dist::DIST_DIR_VAR, &alt_dist)
        .env(crate::dist::TARGET_DIR_VAR, alt.join("target")))?;
    // Only the alt `dist/` is used from here on; its build tree is several GB, enough to fill a
    // CI runner's disk.
    crate::utils::remove_dir_if_exists(alt.join("target"))?;
    let alt_rustc = alt_dist.join("bin").join(crate::utils::exe_name("rustc-ryo"));
    let dir = out.join("multi-version");
    crate::utils::create_dir(&dir)?;
    let build = |rustc: &Path, args: &[&str], file: &str, o: &Path| {
        run(cmd(rustc).args(["--edition=2024", "-Copt-level=1"]).args(args).arg(src.join(file)).arg("-o").arg(o))
    };
    let (a, b) = (dir.join("liba.a"), dir.join("libb.a"));
    build(rustc_ryo, &["--crate-type=staticlib", "--crate-name", "a"], "a.rs", &a)?;
    build(&alt_rustc, &["--crate-type=staticlib", "--crate-name", "b"], "b.rs", &b)?;
    for lld in [false, true] {
        let exe = dir.join(if lld { "ab-lld" } else { "ab-bfd" });
        let res = capture(cc(info, lld).arg(src.join("main2.c")).arg("-o").arg(&exe).arg(&a).arg(&b).args(NATIVE_LIBS))?;
        // The two builds' runtimes have disjoint names; the users' two stds are the same.
        if !res.status.success() {
            return Err(format!("two ryo builds' staticlibs: the link failed:\n{}", res.stderr));
        }
        let (plain, jit) = plain_and_jit(|env| run_out(&exe, &[], env))?;
        if plain != jit {
            return Err(format!("two ryo builds' staticlibs: with the JIT {jit:?}, without {plain:?}"));
        }
    }
    let plugin = dir.join("libplugin.so");
    build(&alt_rustc, &["--crate-type=cdylib"], "plugin.rs", &plugin)?;
    let host = dir.join("host");
    build(rustc_ryo, &[], "host.rs", &host)?;
    let p = plugin.to_str().ok_or("non-UTF-8 path")?;
    let (plain, jit) = plain_and_jit(|env| run_out(&host, &[p], env))?;
    if first_line(&plain) != first_line(&jit) || jit_threads(&jit) != Some(2) {
        return Err(format!("a cdylib of another ryo build: with the JIT {jit:?}, without {plain:?}"));
    }
    let rlib = dir.join("libda.rlib");
    build(&alt_rustc, &["--crate-type=rlib", "--crate-name", "da"], "da.rs", &rlib)?;
    let user = dir.join("user.rs");
    crate::utils::write(&user, "pub fn f() -> u64 { da::da_work(3) }\n")?;
    let res = capture(
        cmd(rustc_ryo)
            .args(["--edition=2024", "--crate-type=rlib"])
            .arg("--extern")
            .arg(format!("da={}", rlib.display()))
            .arg(&user)
            .arg("-o")
            .arg(dir.join("libuser.rlib")),
    )?;
    if res.status.success() || !res.stderr.contains("ryo_rt") {
        return Err(format!("an rlib of another ryo build: expected rustc's error about `ryo_rt`, got {}:\n{}", res.status, res.stderr));
    }
    Ok(())
}
