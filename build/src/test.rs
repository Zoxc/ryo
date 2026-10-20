//! `y test` (design/build.md#test-and-bench). For now: the smoke tests of `dist/`.

use std::fs;
use std::path::Path;

use crate::utils::{cmd, exe_name, output, root};

/// Programs in `tests/` built with `rustc-ryo` and with plain rustc; their outputs must match.
const CORPUS: &[&str] = &["hello"];

pub fn run() -> Result<(), String> {
    let root = root();
    let rustc_ryo = root.join("dist").join("bin").join(exe_name("rustc-ryo"));
    if !rustc_ryo.exists() {
        return Err("dist/ is missing; run `./y.sh build` first".to_owned());
    }
    let out = root.join("target").join("tests");
    fs::create_dir_all(&out).map_err(|e| format!("creating {}: {e}", out.display()))?;

    let mut failed = Vec::new();
    for name in CORPUS {
        let src = root.join("tests").join(format!("{name}.rs"));
        match diff_test(&rustc_ryo, &src, &out, name) {
            Ok(()) => eprintln!("[y] test {name}: ok"),
            Err(msg) => {
                eprintln!("[y] test {name}: FAILED: {msg}");
                failed.push(*name);
            }
        }
    }
    match reject_randomize_layout(&rustc_ryo, &root.join("tests").join("hello.rs"), &out) {
        Ok(()) => eprintln!("[y] test reject-randomize-layout: ok"),
        Err(msg) => {
            eprintln!("[y] test reject-randomize-layout: FAILED: {msg}");
            failed.push("reject-randomize-layout");
        }
    }
    match cargo_smoke(&root, &out) {
        Ok(()) => eprintln!("[y] test cargo-ryo: ok"),
        Err(msg) => {
            eprintln!("[y] test cargo-ryo: FAILED: {msg}");
            failed.push("cargo-ryo");
        }
    }
    if !failed.is_empty() {
        return Err(format!("failed tests: {}", failed.join(", ")));
    }
    eprintln!("[y] the full test corpus and the ABI sweep are not implemented yet");
    Ok(())
}

fn diff_test(rustc_ryo: &Path, src: &Path, out: &Path, name: &str) -> Result<(), String> {
    let ryo_exe = out.join(exe_name(&format!("{name}-ryo")));
    let llvm_exe = out.join(exe_name(&format!("{name}-llvm")));
    let res = cmd(rustc_ryo)
        .arg("--edition=2024")
        .arg(src)
        .arg("-o")
        .arg(&ryo_exe)
        .env("RYO_BACKEND_MARKER", "1")
        .output()
        .map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if !res.status.success() {
        return Err(format!("rustc-ryo failed:\n{stderr}"));
    }
    if !stderr.contains(BACKEND_MARKER) {
        return Err(format!("the ryo backend didn't run; stderr:\n{stderr}"));
    }
    output(cmd("rustc").args(["--edition=2024"]).arg(src).arg("-o").arg(&llvm_exe))?;
    let ryo = output(&mut cmd(&ryo_exe))?;
    let llvm = output(&mut cmd(&llvm_exe))?;
    if ryo != llvm {
        return Err(format!("output differs\n--- rustc ---\n{llvm}--- rustc-ryo ---\n{ryo}"));
    }
    Ok(())
}

/// `cargo-ryo run` on a one-file package wrapping `tests/hello.rs`.
fn cargo_smoke(root: &Path, out: &Path) -> Result<(), String> {
    let pkg = out.join("cargo-hello");
    fs::create_dir_all(&pkg).map_err(|e| format!("creating {}: {e}", pkg.display()))?;
    let manifest = format!(
        "[package]\nname = \"cargo-hello\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n\
         [[bin]]\nname = \"hello\"\npath = {:?}\n\n[workspace]\n",
        root.join("tests").join("hello.rs").to_str().ok_or("non-UTF-8 path")?,
    );
    fs::write(pkg.join("Cargo.toml"), manifest).map_err(|e| e.to_string())?;
    let cargo_ryo = root.join("dist").join("bin").join(exe_name("cargo-ryo"));
    let res = cmd(cargo_ryo)
        .args(["run", "--quiet", "--offline"])
        .current_dir(&pkg)
        .env("RYO_BACKEND_MARKER", "1")
        // Force a rebuild, so the marker is printed.
        .env("CARGO_TARGET_DIR", pkg.join("target"))
        .arg("--config")
        .arg("build.incremental=false")
        .output()
        .map_err(|e| e.to_string())?;
    let _ = fs::remove_dir_all(pkg.join("target"));
    let stdout = String::from_utf8_lossy(&res.stdout);
    let stderr = String::from_utf8_lossy(&res.stderr);
    if !res.status.success() || stdout != "Hello, world!\n" || !stderr.contains(BACKEND_MARKER) {
        return Err(format!("{}\nstdout:\n{stdout}\nstderr:\n{stderr}", res.status));
    }
    Ok(())
}

/// Printed by the backend's `init` when `RYO_BACKEND_MARKER` is set.
const BACKEND_MARKER: &str = "ryo backend: init";

fn reject_randomize_layout(rustc_ryo: &Path, src: &Path, out: &Path) -> Result<(), String> {
    let res = cmd(rustc_ryo)
        .arg(src)
        .arg("-Zrandomize-layout")
        .arg("-o")
        .arg(out.join(exe_name("randomized")))
        .output()
        .map_err(|e| e.to_string())?;
    let stderr = String::from_utf8_lossy(&res.stderr);
    if res.status.success() || !stderr.contains("-Zrandomize-layout") {
        return Err(format!("expected rustc-ryo to reject -Zrandomize-layout; stderr:\n{stderr}"));
    }
    Ok(())
}
