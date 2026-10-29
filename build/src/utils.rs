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

/// Whether `cmd` runs and exits successfully (with its output discarded): a probe for whether
/// a tool is usable.
pub fn succeeds(cmd: &mut Command) -> bool {
    cmd.output().is_ok_and(|o| o.status.success())
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

/// Removes `dir` if it exists and creates it empty.
pub fn fresh_dir(dir: impl AsRef<Path>) -> Result<(), String> {
    remove_dir_if_exists(&dir)?;
    create_dir(dir)
}

/// `fs::remove_file`, with the path in the error.
pub fn remove_file(path: impl AsRef<Path>) -> Result<(), String> {
    let path = path.as_ref();
    std::fs::remove_file(path).map_err(|e| format!("removing {}: {e}", path.display()))
}

/// `fs::read_to_string`, with the path in the error.
pub fn read(path: impl AsRef<Path>) -> Result<String, String> {
    let path = path.as_ref();
    std::fs::read_to_string(path).map_err(|e| format!("reading {}: {e}", path.display()))
}

/// `fs::read`, with the path in the error.
pub fn read_bytes(path: impl AsRef<Path>) -> Result<Vec<u8>, String> {
    let path = path.as_ref();
    std::fs::read(path).map_err(|e| format!("reading {}: {e}", path.display()))
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

/// Runs `cmd` with stdin closed and its stdout and stderr captured, killing it if it runs
/// longer than `limit`: then fails with what it printed so far, so a hang (a deadlock, a
/// read of stdin) fails the test instead of the CI job's timeout. The first line of an error
/// says what happened, the rest is the output.
pub fn output_timeout(cmd: &mut Command, limit: std::time::Duration) -> Result<std::process::Output, String> {
    use std::io::Read;
    let mut child = cmd
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    // The readers append to shared buffers, so what was read is there even if a descendant
    // that inherited the pipes keeps them open after the child exits.
    type Buf = std::sync::Arc<std::sync::Mutex<Vec<u8>>>;
    let pipe = |r: Option<Box<dyn Read + Send>>| {
        let buf = Buf::default();
        let b = buf.clone();
        let t = std::thread::spawn(move || {
            if let Some(mut r) = r {
                let mut chunk = [0u8; 8192];
                while let Ok(n @ 1..) = r.read(&mut chunk) {
                    b.lock().unwrap().extend_from_slice(&chunk[..n]);
                }
            }
        });
        (t, buf)
    };
    let out = pipe(child.stdout.take().map(|r| Box::new(r) as Box<dyn Read + Send>));
    let err = pipe(child.stderr.take().map(|r| Box::new(r) as Box<dyn Read + Send>));
    // Waits for both readers until `deadline`; false if a pipe is still held open then.
    let drained = |deadline: std::time::Instant| loop {
        if out.0.is_finished() && err.0.is_finished() {
            return true;
        }
        if std::time::Instant::now() >= deadline {
            return false;
        }
        std::thread::sleep(std::time::Duration::from_millis(10));
    };
    let take = |b: &Buf| std::mem::take(&mut *b.lock().unwrap());
    let start = std::time::Instant::now();
    let status = loop {
        match child.try_wait() {
            Ok(Some(status)) => break status,
            Ok(None) if start.elapsed() < limit => std::thread::sleep(std::time::Duration::from_millis(10)),
            Ok(None) => {
                // If `cmd` made the child a process group leader (`process_group(0)`), kill
                // the group, so the processes it started go too. Otherwise there is no such
                // group: the unreaped child's pid can't name another one.
                #[cfg(unix)]
                let _ = Command::new("kill").args(["-9", "--", &format!("-{}", child.id())]).stderr(Stdio::null()).status();
                let _ = child.kill();
                let _ = child.wait();
                // The pipes close with the process, unless it left descendants holding them.
                drained(std::time::Instant::now() + std::time::Duration::from_secs(1));
                return Err(format!(
                    "`{}` timed out after {}s, killed\nstdout:\n{}stderr:\n{}",
                    describe(cmd),
                    limit.as_secs(),
                    String::from_utf8_lossy(&take(&out.1)),
                    String::from_utf8_lossy(&take(&err.1))
                ));
            }
            Err(e) => return Err(format!("failed to wait for `{}`: {e}", describe(cmd))),
        }
    };
    if !drained((start + limit).max(std::time::Instant::now() + std::time::Duration::from_secs(1))) {
        return Err(format!(
            "`{}` exited ({status}) but left a process holding its stdout or stderr open\nstdout:\n{}stderr:\n{}",
            describe(cmd),
            String::from_utf8_lossy(&take(&out.1)),
            String::from_utf8_lossy(&take(&err.1))
        ));
    }
    Ok(std::process::Output { status, stdout: take(&out.1), stderr: take(&err.1) })
}

/// Runs `cmd` and returns its stdout, failing if it doesn't exit successfully.
/// Unlike [`capture_ok`], its stderr goes to y's, and its stdout must be UTF-8: for tool output
/// to parse, where diagnostics should reach the user as they come.
pub fn output(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.stderr(Stdio::inherit()).output().map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    if !out.status.success() {
        return Err(format!("`{}` failed with {}", describe(cmd), out.status));
    }
    String::from_utf8(out.stdout).map_err(|_| format!("`{}`: non-UTF-8 output", describe(cmd)))
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

/// Hashes the paths and contents of the files under `dir` (but `target/`), in a fixed order.
pub fn hash_tree(dir: &Path, rel: &Path, h: &mut std::hash::DefaultHasher) -> Result<(), String> {
    use std::hash::Hasher;
    let mut entries: Vec<_> = std::fs::read_dir(dir).map_err(|e| format!("{}: {e}", dir.display()))?.flatten().collect();
    entries.sort_by_key(|e| e.file_name());
    for entry in entries {
        let name = entry.file_name();
        let path = entry.path();
        let rel = rel.join(&name);
        if entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            if name != "target" {
                hash_tree(&path, &rel, h)?;
            }
        } else {
            h.write(rel.to_string_lossy().as_bytes());
            h.write_u8(0);
            hash_file(h, &path)?;
        }
    }
    Ok(())
}

/// A hash of `bytes`. `DefaultHasher::new` uses fixed keys, so it is stable across runs
/// (which stamps and build ids rely on).
pub fn hash_bytes(bytes: &[u8]) -> u64 {
    use std::hash::Hasher;
    let mut h = std::hash::DefaultHasher::new();
    h.write(bytes);
    h.finish()
}

/// A hash of the contents of `files`, in order.
pub fn hash_files(files: &[impl AsRef<Path>]) -> Result<u64, String> {
    use std::hash::Hasher;
    let mut h = std::hash::DefaultHasher::new();
    for f in files {
        hash_file(&mut h, f.as_ref())?;
    }
    Ok(h.finish())
}

/// Hashes the contents of `path`.
pub fn hash_file(h: &mut std::hash::DefaultHasher, path: &Path) -> Result<(), String> {
    use std::hash::Hasher;
    h.write(&std::fs::read(path).map_err(|e| format!("{}: {e}", path.display()))?);
    Ok(())
}

/// A `key: value` line from `rustc -vV`.
pub fn field<'a>(vv: &'a str, key: &str) -> Option<&'a str> {
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
