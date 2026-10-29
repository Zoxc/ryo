//! Helpers shared by `y`'s commands, re-exported from the submodules by concern.

mod args;
mod fs;
mod proc;
mod rustc;

use std::path::{Path, PathBuf};

pub use args::*;
pub use fs::*;
pub use proc::*;
pub use rustc::*;

/// Repository root (the parent of `build/`).
pub fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).parent().unwrap().to_path_buf()
}

/// The variable the dynamic loader searches for shared libraries.
pub const LIB_PATH_VAR: &str = if cfg!(windows) {
    "PATH"
} else if cfg!(target_vendor = "apple") {
    "DYLD_LIBRARY_PATH"
} else {
    "LD_LIBRARY_PATH"
};

/// The PATH-like variable `var` with `dirs` prepended.
pub fn prepend_paths(var: &str, dirs: impl IntoIterator<Item = PathBuf>) -> Result<std::ffi::OsString, String> {
    let mut paths: Vec<PathBuf> = dirs.into_iter().collect();
    paths.extend(std::env::split_paths(&std::env::var_os(var).unwrap_or_default()));
    std::env::join_paths(paths).map_err(|e| format!("{var}: {e}"))
}

/// Compiles `scripts/<name>.rs` into `dist/bin/<name>` with plain rustc.
pub fn build_wrapper(root: &Path, dist_bin: &Path, info: &RustcInfo, name: &str, build_id: &str) -> Result<(), String> {
    eprintln!("[y] wrapper: {name}");
    run(cmd("rustc")
        .args(["--edition=2024", "-Copt-level=1", "-o"])
        .arg(dist_bin.join(exe_name(name)))
        .arg(root.join("scripts").join(format!("{name}.rs")))
        .env("RYO_TOOLCHAIN", &info.toolchain)
        .env("RYO_RUSTC_DRIVER", &info.driver)
        .env("RYO_RUSTC_RELEASE", PINNED_VERSION)
        .env("RYO_BUILD_ID", build_id))
}

/// The symbols `llvm-nm <args> -j` lists for `file`, an object or archive for `triple`:
/// trimmed, without Mach-O's `_` prefix, and without empty lines.
pub fn nm_symbols(info: &RustcInfo, args: &[&str], file: &Path, triple: &str) -> Result<Vec<String>, String> {
    let out = output(cmd(info.tool("llvm-nm")).args(args).arg("-j").arg(file))?;
    Ok(out.lines().map(|l| crate::target::unprefixed(triple, l.trim())).filter(|l| !l.is_empty()).map(str::to_owned).collect())
}

/// Whether `s` is a symbol of std's allocator shim (`__rust_*`, `__rdl_*`, `__rg_*`).
pub fn is_std_alloc_shim(s: &str) -> bool {
    ["__rust", "__rdl", "__rg_"].iter().any(|p| s.starts_with(p))
}

/// `dist/bin/<name>` (an executable).
pub fn dist_bin(root: &Path, name: &str) -> PathBuf {
    root.join("dist").join("bin").join(exe_name(name))
}

/// `dist/bin/rustc-ryo`, or an error if `dist/` hasn't been built.
pub fn require_dist(root: &Path) -> Result<PathBuf, String> {
    let rustc_ryo = dist_bin(root, "rustc-ryo");
    if !rustc_ryo.exists() {
        return Err("dist/ is missing; run `./y.sh build` first".to_owned());
    }
    Ok(rustc_ryo)
}

/// `dist/`'s `ryo_rt` rlib for `triple`.
pub fn ryo_rt_rlib(root: &Path, triple: &str) -> PathBuf {
    rustlib(&root.join("dist"), triple).join("lib").join("libryo_rt.rlib")
}

/// Plain-text table of `lines` (the first is the header, optionally followed by a dashed
/// rule): the first column left-aligned, the others right-aligned, two spaces apart.
pub fn text_table(lines: &[Vec<String>], rule: bool) -> String {
    let cols = lines[0].len();
    let widths: Vec<usize> = (0..cols).map(|i| lines.iter().map(|l| l.get(i).map_or(0, |c| c.chars().count())).max().unwrap()).collect();
    let mut out = String::new();
    for (n, line) in lines.iter().enumerate() {
        let mut text = String::new();
        for (i, cell) in line.iter().enumerate() {
            let pad = " ".repeat(widths[i] - cell.chars().count());
            if i == 0 {
                text.push_str(&format!("{cell}{pad}"));
            } else {
                text.push_str(&format!("  {pad}{cell}"));
            }
        }
        out.push_str(text.trim_end());
        out.push('\n');
        if n == 0 && rule {
            out.push_str(&"-".repeat(widths.iter().sum::<usize>() + 2 * (cols - 1)));
            out.push('\n');
        }
    }
    out
}
