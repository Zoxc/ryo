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
    let out = cmd.stderr(Stdio::inherit()).output().map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
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
    /// The `rustc_driver` dylib the backend links against. The wrappers check that it still
    /// exists, which catches the toolchain being updated after `y build`.
    pub driver: PathBuf,
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
        Ok(RustcInfo { host, sysroot, toolchain, driver })
    }
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

/// A `--flag value` / `--flag=value` command line parser.
pub struct Flags<'a> {
    args: std::slice::Iter<'a, &'a str>,
    /// The current argument, its flag part and its unconsumed `=value` part.
    arg: &'a str,
    flag: &'a str,
    inline: Option<&'a str>,
}

impl<'a> Flags<'a> {
    pub fn new(args: &'a [&'a str]) -> Self {
        Flags { args: args.iter(), arg: "", flag: "", inline: None }
    }

    /// The next flag, erroring if the previous one was given an `=value` it doesn't take.
    pub fn next(&mut self) -> Result<Option<&'a str>, String> {
        if self.inline.is_some() {
            return Err(format!("`{}` takes no value", self.flag));
        }
        let Some(&arg) = self.args.next() else { return Ok(None) };
        (self.arg, self.flag, self.inline) = match arg.split_once('=') {
            Some((f, v)) if f.starts_with("--") => (arg, f, Some(v)),
            _ => (arg, arg, None),
        };
        Ok(Some(self.flag))
    }

    /// The current flag's value: inline or the next argument.
    pub fn value(&mut self) -> Result<&'a str, String> {
        self.inline.take().or_else(|| self.args.next().copied()).ok_or(format!("`{}` needs a value", self.flag))
    }

    /// The error for an unknown current argument.
    pub fn unexpected(&self) -> String {
        format!("unexpected argument `{}`", self.arg)
    }
}
