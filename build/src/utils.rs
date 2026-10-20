use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

/// The rustc version pinned in `rust-toolchain.toml` (design/build.md#toolchain).
pub const PINNED_VERSION: &str = "1.99.1";

/// Repository root (the parent of `build/`).
pub fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).parent().unwrap().to_path_buf()
}

/// A command with `RUSTC_BOOTSTRAP=1`, as `y` uses for everything it spawns.
pub fn cmd(program: impl AsRef<std::ffi::OsStr>) -> Command {
    let mut cmd = Command::new(program);
    cmd.env("RUSTC_BOOTSTRAP", "1");
    cmd
}

pub fn describe(cmd: &Command) -> String {
    let mut s = cmd.get_program().to_string_lossy().into_owned();
    for arg in cmd.get_args() {
        s.push(' ');
        s.push_str(&arg.to_string_lossy());
    }
    s
}

/// Runs `cmd`, failing if it doesn't exit successfully.
pub fn run(cmd: &mut Command) -> Result<(), String> {
    let status = cmd.status().map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    if !status.success() {
        return Err(format!("`{}` failed with {status}", describe(cmd)));
    }
    Ok(())
}

/// Runs `cmd` and returns its stdout, failing if it doesn't exit successfully.
pub fn output(cmd: &mut Command) -> Result<String, String> {
    let out = cmd
        .stderr(Stdio::inherit())
        .output()
        .map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    if !out.status.success() {
        return Err(format!("`{}` failed with {}", describe(cmd), out.status));
    }
    String::from_utf8(out.stdout).map_err(|_| format!("`{}`: non-UTF-8 output", describe(cmd)))
}

/// What `y` needs to know about the host rustc.
pub struct RustcInfo {
    pub host: String,
    pub sysroot: PathBuf,
    /// The rustup toolchain the wrappers pin through `RUSTUP_TOOLCHAIN`.
    pub toolchain: String,
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
        let sysroot = output(cmd("rustc").args(["--print", "sysroot"]))?.trim().into();
        let toolchain = match std::env::var("RUSTUP_TOOLCHAIN") {
            Ok(t) if !t.is_empty() => t,
            _ => format!("{PINNED_VERSION}-{host}"),
        };
        Ok(RustcInfo { host, sysroot, toolchain })
    }
}

/// A `key: value` line from `rustc -vV`.
fn field<'a>(vv: &'a str, key: &str) -> Option<&'a str> {
    vv.lines().find_map(|l| l.strip_prefix(key)?.strip_prefix(": "))
}

pub fn dll_name(name: &str) -> String {
    format!("{}{name}{}", std::env::consts::DLL_PREFIX, std::env::consts::DLL_SUFFIX)
}

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
