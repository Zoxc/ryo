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

/// `fs::create_dir_all`, with the path in the error.
pub fn create_dir(dir: impl AsRef<Path>) -> Result<(), String> {
    let dir = dir.as_ref();
    std::fs::create_dir_all(dir).map_err(|e| format!("creating {}: {e}", dir.display()))
}

/// Removes `dir` and its contents, if it exists.
pub fn remove_dir_if_exists(dir: impl AsRef<Path>) -> Result<(), String> {
    let dir = dir.as_ref();
    if dir.exists() {
        std::fs::remove_dir_all(dir).map_err(|e| format!("removing {}: {e}", dir.display()))?;
    }
    Ok(())
}

/// `fs::write`, with the path in the error.
pub fn write(path: impl AsRef<Path>, contents: impl AsRef<[u8]>) -> Result<(), String> {
    let path = path.as_ref();
    std::fs::write(path, contents).map_err(|e| format!("writing {}: {e}", path.display()))
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

/// Copies `from` to `to` through a temporary file renamed into place, so a process that has
/// `to` mapped (a rustc running the backend dylib) keeps the old file instead of seeing it
/// overwritten (design/build.md).
pub fn copy(from: &Path, to: &Path) -> Result<(), String> {
    let err = |e: std::io::Error| format!("copying {} to {}: {e}", from.display(), to.display());
    let mut tmp = to.as_os_str().to_owned();
    tmp.push(format!(".tmp{}", std::process::id()));
    let tmp = PathBuf::from(tmp);
    std::fs::copy(from, &tmp).map_err(err)?;
    std::fs::rename(&tmp, to).map_err(|e| {
        let _ = std::fs::remove_file(&tmp);
        err(e)
    })
}

pub fn copy_dir(from: &Path, to: &Path) -> Result<(), String> {
    create_dir(to)?;
    for entry in std::fs::read_dir(from).map_err(|e| format!("{}: {e}", from.display()))? {
        let entry = entry.map_err(|e| e.to_string())?;
        let dst = to.join(entry.file_name());
        if entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            copy_dir(&entry.path(), &dst)?;
        } else {
            copy(&entry.path(), &dst)?;
        }
    }
    Ok(())
}

/// What a [`capture`]d command did.
pub struct Captured {
    pub status: std::process::ExitStatus,
    pub stdout: String,
    pub stderr: String,
}

/// Runs `cmd` with its stdout and stderr captured (lossily decoded), failing only if it can't
/// be spawned.
pub fn capture(cmd: &mut Command) -> Result<Captured, String> {
    let out = cmd.output().map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    Ok(Captured {
        status: out.status,
        stdout: String::from_utf8_lossy(&out.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
    })
}

/// [`capture`], failing with the output if `cmd` doesn't exit successfully.
pub fn capture_ok(cmd: &mut Command) -> Result<Captured, String> {
    let res = capture(cmd)?;
    if !res.status.success() {
        return Err(format!("`{}` failed with {}:\n{}{}", describe(cmd), res.status, res.stdout, res.stderr));
    }
    Ok(res)
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
        self.sysroot.join("lib").join("rustlib").join(&self.host).join("bin").join(exe_name(name))
    }

    /// `rust-src`'s `library/`.
    pub fn rust_src_library(&self) -> PathBuf {
        self.sysroot.join("lib").join("rustlib").join("src").join("rust").join("library")
    }
}

/// `dist/bin/<name>` (an executable).
pub fn dist_bin(root: &Path, name: &str) -> PathBuf {
    root.join("dist").join("bin").join(exe_name(name))
}

/// `dist/`'s `ryo_rt` rlib for `triple`.
pub fn ryo_rt_rlib(root: &Path, triple: &str) -> PathBuf {
    root.join("dist").join("lib").join("rustlib").join(triple).join("lib").join("libryo_rt.rlib")
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

    /// The current flag's optional value: inline, or the next argument unless it is a flag
    /// (starts with `-`).
    pub fn optional_value(&mut self) -> Option<&'a str> {
        self.inline.take().or_else(|| {
            let next = self.args.clone().next().copied().filter(|a| !a.starts_with('-'))?;
            self.args.next();
            Some(next)
        })
    }

    /// The error for an unknown current argument.
    pub fn unexpected(&self) -> String {
        format!("unexpected argument `{}`", self.arg)
    }
}
