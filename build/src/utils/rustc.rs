//! The host rustc and its toolchain.

use std::path::{Path, PathBuf};

use super::{cmd, copy_dir, output};

/// The rustc version pinned in `rust-toolchain.toml` (design/build.md#toolchain).
pub const PINNED_VERSION: &str = "1.99.1";

/// What `y` needs to know about the host rustc.
pub struct RustcInfo {
    pub host: String,
    pub sysroot: PathBuf,
    /// The rustup toolchain the wrappers pin through `RUSTUP_TOOLCHAIN`.
    pub toolchain: String,
    /// The `rustc_driver` dylib the backend links against. The wrappers check that it still
    /// exists, which catches the toolchain being updated after `y build`.
    pub driver: PathBuf,
    /// `rustc -vV`'s output.
    pub version: String,
}

impl RustcInfo {
    pub fn get() -> Result<RustcInfo, String> {
        let vv = output(cmd("rustc").arg("-vV"))?;
        let release = field(&vv, "release").ok_or("`rustc -vV`: no release")?;
        if release != PINNED_VERSION {
            return Err(format!(
                "rustc is {release}, but ryo is pinned to {PINNED_VERSION}; \
                 run `y` from the repository so `rust-toolchain.toml` applies"
            ));
        }
        let host = field(&vv, "host").ok_or("`rustc -vV`: no host")?.to_owned();
        let sysroot: PathBuf = output(cmd("rustc").args(["--print", "sysroot"]))?.trim().into();
        let toolchain = match std::env::var("RUSTUP_TOOLCHAIN") {
            Ok(t) if !t.is_empty() => t,
            // `rust-toolchain.toml`'s channel.
            _ => format!("stable-{host}"),
        };
        let driver = find_driver(&sysroot)?;
        Ok(RustcInfo { host, sysroot, toolchain, driver, version: vv })
    }

    /// The toolchain's host tool `name`, e.g. from `llvm-tools`.
    pub fn tool(&self, name: &str) -> PathBuf {
        host_tool(&self.sysroot, &self.host, name)
    }

    /// `rust-src`'s `library/`.
    pub fn rust_src_library(&self) -> PathBuf {
        self.sysroot.join("lib").join("rustlib").join("src").join("rust").join("library")
    }
}

/// `<sysroot>/lib/rustlib/<triple>`, a target's directory in a rustc sysroot.
pub fn rustlib(sysroot: &Path, triple: &str) -> PathBuf {
    sysroot.join("lib").join("rustlib").join(triple)
}

/// The host tool `name` in `<sysroot>/lib/rustlib/<host>/bin`.
pub fn host_tool(sysroot: &Path, host: &str, name: &str) -> PathBuf {
    rustlib(sysroot, host).join("bin").join(exe_name(name))
}

/// Copies `<from>/lib/rustlib/<triple>/bin` (the self-contained linker) to the same place
/// under `to`, if the toolchain has one.
pub fn copy_target_bin(from: &Path, to: &Path, triple: &str) -> Result<(), String> {
    let src = rustlib(from, triple).join("bin");
    if src.is_dir() {
        copy_dir(&src, &rustlib(to, triple).join("bin"))?;
    }
    Ok(())
}

/// The toolchain's `librustc_driver-<hash>` dylib (in `lib/`, or `bin/` on Windows).
fn find_driver(sysroot: &Path) -> Result<PathBuf, String> {
    let prefix = format!("{}rustc_driver-", std::env::consts::DLL_PREFIX);
    for dir in [sysroot.join("lib"), sysroot.join("bin")] {
        let Ok(entries) = std::fs::read_dir(&dir) else { continue };
        for entry in entries.flatten() {
            let name = entry.file_name();
            let name = name.to_string_lossy();
            if name.starts_with(&prefix) && name.ends_with(std::env::consts::DLL_SUFFIX) {
                return Ok(entry.path());
            }
        }
    }
    Err(format!("no rustc_driver dylib in {}", sysroot.display()))
}

/// A `key: value` line from `rustc -vV`.
pub fn field<'a>(vv: &'a str, key: &str) -> Option<&'a str> {
    vv.lines().find_map(|l| l.strip_prefix(key)?.strip_prefix(": "))
}

/// The file name of the dynamic library `name` on the host.
pub fn dll_name(name: &str) -> String {
    format!("{}{name}{}", std::env::consts::DLL_PREFIX, std::env::consts::DLL_SUFFIX)
}

/// The file name of the executable `name` on the host.
pub fn exe_name(name: &str) -> String {
    format!("{name}{}", std::env::consts::EXE_SUFFIX)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rustc_vv_fields() {
        let vv = "rustc 1.99.1 (58cf8f9c3 2026-10-13)\nbinary: rustc\nhost: x86_64-unknown-linux-gnu\nrelease: 1.99.1\n";
        assert_eq!(field(vv, "host"), Some("x86_64-unknown-linux-gnu"));
        assert_eq!(field(vv, "release"), Some("1.99.1"));
        assert_eq!(field(vv, "commit-hash"), None);
    }
}
