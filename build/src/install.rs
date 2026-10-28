//! `y install` and `y uninstall` (design/install.md): build ryo into the checkout's
//! `install/`, install the `scripts/` launchers with `cargo install`, and remove exactly that
//! again, together with what was added to rustup.

use std::fs;
use std::io::{IsTerminal, Write as _};
use std::path::{Path, PathBuf};
use std::process::ExitCode;

use crate::utils::{PINNED_VERSION, capture, cmd, copy_dir, create_dir, root, run, write};

/// The components ryo needs besides the minimal profile.
const COMPONENTS: [&str; 3] = ["rustc-dev", "rust-src", "llvm-tools"];

#[derive(Debug, Default, PartialEq)]
pub struct InstallOptions {
    /// Extra targets (besides the host), as for `y build --target`.
    pub targets: Vec<String>,
    /// `--sysroot ryo`.
    pub ryo_std: bool,
    pub no_toolchain_install: bool,
    pub yes: bool,
    pub dry_run: bool,
}

#[derive(Debug, Default, PartialEq)]
pub struct UninstallOptions {
    pub keep_toolchain: bool,
    pub yes: bool,
    pub dry_run: bool,
}

pub fn parse_install(rest: &[&str]) -> Result<InstallOptions, String> {
    let mut o = InstallOptions::default();
    let mut args = crate::utils::Flags::new(rest);
    while let Some(flag) = args.next()? {
        match flag {
            "--target" => o.targets.push(args.value()?.to_owned()),
            "--sysroot" => {
                o.ryo_std = match args.value()? {
                    "llvm" => false,
                    "ryo" => true,
                    other => return Err(format!("unknown sysroot `{other}`")),
                }
            }
            "--no-toolchain-install" => o.no_toolchain_install = true,
            "--yes" | "-y" => o.yes = true,
            "--dry-run" => o.dry_run = true,
            _ => return Err(args.unexpected()),
        }
    }
    Ok(o)
}

pub fn parse_uninstall(rest: &[&str]) -> Result<UninstallOptions, String> {
    let mut o = UninstallOptions::default();
    let mut args = crate::utils::Flags::new(rest);
    while let Some(flag) = args.next()? {
        match flag {
            "--keep-toolchain" => o.keep_toolchain = true,
            "--yes" | "-y" => o.yes = true,
            "--dry-run" => o.dry_run = true,
            _ => return Err(args.unexpected()),
        }
    }
    Ok(o)
}

// ---------------------------------------------------------------------------------------------
// Manifest

/// `install/manifest.toml`: what an install did; the only record `y uninstall` removes by.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct Manifest {
    /// The installed `<version>`; empty while the first install hasn't got that far.
    pub version: String,
    pub build_id: String,
    pub host: String,
    pub targets: Vec<String>,
    pub sysroots: Vec<String>,
    /// Where `cargo install` put the launchers.
    pub cargo_root: String,
    pub toolchain: ToolchainRecord,
}

#[derive(Debug, Clone, Default, PartialEq)]
pub struct ToolchainRecord {
    pub name: String,
    pub installed_by_ryo: bool,
    pub components_added: Vec<String>,
    pub targets_added: Vec<String>,
}

impl Manifest {
    pub fn to_toml(&self) -> String {
        let list = |l: &[String]| format!("[{}]", l.iter().map(|s| quote(s)).collect::<Vec<_>>().join(", "));
        let t = &self.toolchain;
        format!(
            "# Written by `y install`; `y uninstall` removes what it records.\n\
             format = 1\nversion = {}\nbuild_id = {}\nhost = {}\ntargets = {}\nsysroots = {}\ncargo_root = {}\n\n\
             [toolchain]\nname = {}\ninstalled_by_ryo = {}\ncomponents_added = {}\ntargets_added = {}\n",
            quote(&self.version),
            quote(&self.build_id),
            quote(&self.host),
            list(&self.targets),
            list(&self.sysroots),
            quote(&self.cargo_root),
            quote(&t.name),
            t.installed_by_ryo,
            list(&t.components_added),
            list(&t.targets_added),
        )
    }

    /// Parses what [`Manifest::to_toml`] writes (a TOML subset: strings, string arrays,
    /// booleans, one `[toolchain]` table).
    pub fn parse(text: &str) -> Result<Manifest, String> {
        let mut m = Manifest::default();
        let mut table = "";
        let mut format = None;
        for (n, line) in text.lines().enumerate() {
            let line = line.trim();
            if line.is_empty() || line.starts_with('#') {
                continue;
            }
            if let Some(t) = line.strip_prefix('[').and_then(|l| l.strip_suffix(']')) {
                table = if t == "toolchain" { "toolchain" } else { return Err(format!("line {}: unknown table `{t}`", n + 1)) };
                continue;
            }
            let err = |what: &str| format!("line {}: {what}", n + 1);
            let (key, value) = line.split_once('=').ok_or_else(|| err("expected `key = value`"))?;
            let (key, value) = (key.trim(), value.trim());
            let s = || unquote(value).ok_or_else(|| err("expected a string"));
            let l = || parse_list(value).ok_or_else(|| err("expected a list of strings"));
            let t = &mut m.toolchain;
            match (table, key) {
                ("", "format") => format = Some(value.to_owned()),
                ("", "version") => m.version = s()?,
                ("", "build_id") => m.build_id = s()?,
                ("", "host") => m.host = s()?,
                ("", "targets") => m.targets = l()?,
                ("", "sysroots") => m.sysroots = l()?,
                ("", "cargo_root") => m.cargo_root = s()?,
                ("toolchain", "name") => t.name = s()?,
                ("toolchain", "installed_by_ryo") => {
                    t.installed_by_ryo = match value {
                        "true" => true,
                        "false" => false,
                        _ => return Err(err("expected true or false")),
                    }
                }
                ("toolchain", "components_added") => t.components_added = l()?,
                ("toolchain", "targets_added") => t.targets_added = l()?,
                _ => return Err(err(&format!("unknown key `{key}`"))),
            }
        }
        if format.as_deref() != Some("1") {
            return Err("unsupported or missing `format`".to_owned());
        }
        Ok(m)
    }
}

fn quote(s: &str) -> String {
    let mut out = String::from('"');
    for c in s.chars() {
        if c == '"' || c == '\\' {
            out.push('\\');
        }
        out.push(c);
    }
    out.push('"');
    out
}

fn unquote(s: &str) -> Option<String> {
    let inner = s.strip_prefix('"')?.strip_suffix('"')?;
    let mut out = String::new();
    let mut chars = inner.chars();
    while let Some(c) = chars.next() {
        match c {
            '\\' => out.push(chars.next()?),
            '"' => return None,
            c => out.push(c),
        }
    }
    Some(out)
}

fn parse_list(s: &str) -> Option<Vec<String>> {
    let inner = s.strip_prefix('[')?.strip_suffix(']')?.trim();
    if inner.is_empty() {
        return Some(Vec::new());
    }
    // Items are plain names and paths: no `,` inside strings.
    inner.split(',').map(|i| unquote(i.trim())).collect()
}

// ---------------------------------------------------------------------------------------------
// The environment: rustup, cargo, the checkout

/// `install/` of this checkout.
fn install_dir() -> PathBuf {
    root().join("install")
}

fn read_manifest(install: &Path) -> Result<Option<Manifest>, String> {
    let path = install.join("manifest.toml");
    match fs::read_to_string(&path) {
        Ok(text) => Manifest::parse(&text).map(Some).map_err(|e| format!("{}: {e}", path.display())),
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(None),
        Err(e) => Err(format!("{}: {e}", path.display())),
    }
}

/// The installed `<version>` (`install/current`).
fn current_version(install: &Path) -> Option<String> {
    let v = fs::read_to_string(install.join("current")).ok()?;
    let v = v.trim();
    (!v.is_empty() && install.join(v).is_dir()).then(|| v.to_owned())
}

/// Stdout of a successful `rustup <args>`.
fn rustup(args: &[&str]) -> Result<String, String> {
    let out = capture(cmd("rustup").args(args))?;
    if !out.status.success() {
        return Err(format!("`rustup {}` failed: {}", args.join(" "), out.stderr.trim()));
    }
    Ok(out.stdout)
}

/// rustup's `Default host:` (from `rustup show`).
fn rustup_host() -> Result<String, String> {
    if capture(cmd("rustup").arg("--version")).is_err() {
        return Err("ryo needs rustup to manage its pinned toolchain (1.99.1 with rustc-dev); install it from https://rustup.rs and rerun".to_owned());
    }
    let show = rustup(&["show"])?;
    show.lines()
        .find_map(|l| l.strip_prefix("Default host:"))
        .map(|h| h.trim().to_owned())
        .ok_or_else(|| "`rustup show`: no `Default host`".to_owned())
}

/// The first word of each line: names from `rustup toolchain list`, `rustup component list
/// --installed`, `rustup target list --installed`.
fn names(out: &str) -> Vec<String> {
    out.lines().filter_map(|l| l.split_whitespace().next()).map(str::to_owned).collect()
}

/// Whether `component` is in `rustup component list --installed`'s `installed` (which names
/// host components with the host suffix, e.g. `rustc-dev-x86_64-unknown-linux-gnu`; older
/// rustups call `llvm-tools` `llvm-tools-preview`).
fn has_component(installed: &[String], component: &str, host: &str) -> bool {
    installed.iter().any(|c| {
        let c = c.strip_suffix(&format!("-{host}")).unwrap_or(c);
        c == component || c.strip_suffix("-preview") == Some(component)
    })
}

/// What rustup has of `toolchain`: `None` if it isn't installed, else its components and
/// targets.
fn toolchain_state(toolchain: &str) -> Result<Option<(Vec<String>, Vec<String>)>, String> {
    if !names(&rustup(&["toolchain", "list"])?).iter().any(|t| t == toolchain) {
        return Ok(None);
    }
    let components = names(&rustup(&["component", "list", "--installed", "--toolchain", toolchain])?);
    let targets = names(&rustup(&["target", "list", "--installed", "--toolchain", toolchain])?);
    Ok(Some((components, targets)))
}

/// Why rustup's `toolchain` must stay even though ryo installed it, if it must.
fn toolchain_in_use(toolchain: &str) -> Result<Option<String>, String> {
    if names(&rustup(&["default"]).unwrap_or_default()).iter().any(|t| t == toolchain) {
        return Ok(Some("it is rustup's default toolchain".to_owned()));
    }
    let overrides = rustup(&["override", "list"]).unwrap_or_default();
    let short = toolchain.split_once('-').map_or(toolchain, |(v, _)| v);
    if overrides.lines().any(|l| l.split_whitespace().last().is_some_and(|t| t == toolchain || t == short)) {
        return Ok(Some("`rustup override list` names it".to_owned()));
    }
    Ok(None)
}

/// cargo's install root: `$CARGO_INSTALL_ROOT`, else `$CARGO_HOME`, else `~/.cargo`.
fn cargo_root() -> Result<PathBuf, String> {
    for var in ["CARGO_INSTALL_ROOT", "CARGO_HOME"] {
        if let Some(v) = std::env::var_os(var).filter(|v| !v.is_empty()) {
            return Ok(PathBuf::from(v));
        }
    }
    let home = std::env::var_os(if cfg!(windows) { "USERPROFILE" } else { "HOME" }).ok_or("no home directory to find ~/.cargo in")?;
    Ok(Path::new(&home).join(".cargo"))
}

/// Who installed the `cargo-ryo` package in a cargo root.
#[derive(Debug, PartialEq)]
enum Launchers {
    None,
    /// From this checkout's `scripts/`.
    Ours,
    /// From elsewhere: the source cargo lists (another checkout's `scripts/`, a registry, git).
    Other(String),
}

/// The source of the `cargo-ryo` package in `cargo install --list` (`cargo-ryo v0.1.0
/// (/path/scripts):`); `Some("")` if it has none (a registry package).
fn cargo_ryo_source(list: &str) -> Option<String> {
    let line = list.lines().find(|l| !l.starts_with(char::is_whitespace) && l.split_whitespace().next() == Some("cargo-ryo"))?;
    let line = line.trim_end().trim_end_matches(':');
    Some(line.split_once(" (").and_then(|(_, s)| s.strip_suffix(')')).unwrap_or("").to_owned())
}

fn launchers(root_dir: &Path) -> Result<Launchers, String> {
    let out = capture(cmd("cargo").args(["install", "--list", "--root"]).arg(root_dir))?;
    if !out.status.success() {
        // An empty root that doesn't exist yet.
        return Ok(Launchers::None);
    }
    let Some(source) = cargo_ryo_source(&out.stdout) else { return Ok(Launchers::None) };
    let ours = root().join("scripts");
    let same = |a: &Path, b: &Path| a == b || a.canonicalize().ok().zip(b.canonicalize().ok()).is_some_and(|(a, b)| a == b);
    if !source.is_empty() && same(Path::new(&source), &ours) {
        return Ok(Launchers::Ours);
    }
    Ok(Launchers::Other(if source.is_empty() { "a registry".to_owned() } else { source }))
}

/// The refusal for launchers from elsewhere ([`Launchers::Other`]).
fn other_launchers_error(source: &str, root_dir: &Path) -> String {
    let checkout = Path::new(source).parent().filter(|_| Path::new(source).file_name().is_some_and(|n| n == "scripts"));
    let how = match checkout {
        Some(c) => format!("run `./y.sh uninstall` in {} first (or `cargo uninstall --root {} cargo-ryo`)", c.display(), root_dir.display()),
        None => format!("remove it first with `cargo uninstall --root {} cargo-ryo`", root_dir.display()),
    };
    format!("the cargo-ryo launchers in {} come from {source}, not this checkout; {how}", root_dir.join("bin").display())
}

/// `git describe --always --dirty` of the checkout.
fn version() -> String {
    let out = capture(cmd("git").args(["describe", "--always", "--dirty"]).current_dir(root()));
    match out {
        Ok(o) if o.status.success() && !o.stdout.trim().is_empty() => o.stdout.trim().to_owned(),
        _ => "local".to_owned(),
    }
}

// ---------------------------------------------------------------------------------------------
// Confirmation and the lock

/// Asks `Proceed? [y/N]` after the plan (design/install.md). `None`: go on.
fn confirm(what: &str, yes: bool, dry_run: bool) -> Option<ExitCode> {
    if dry_run {
        return Some(ExitCode::SUCCESS);
    }
    if yes {
        eprintln!("[y] proceeding (--yes)");
        return None;
    }
    if !std::io::stdin().is_terminal() {
        let git_bash =
            if cfg!(windows) && std::env::var_os("MSYSTEM").is_some() { " (Git Bash: run from PowerShell or cmd, or pass --yes)" } else { "" };
        eprintln!("error: y {what} needs confirmation; rerun with --yes (or --dry-run to only see the plan){git_bash}");
        return Some(ExitCode::from(2));
    }
    eprint!("Proceed? [y/N] ");
    let _ = std::io::stderr().flush();
    let mut answer = String::new();
    let ok = std::io::stdin().read_line(&mut answer).is_ok_and(|n| n > 0);
    if ok && matches!(answer.trim().to_ascii_lowercase().as_str(), "y" | "yes") {
        return None;
    }
    eprintln!("[y] aborted; nothing was changed");
    Some(ExitCode::FAILURE)
}

/// `install/.lock`, held while `y install`/`uninstall` run: created exclusively, holding the
/// pid; a lock of a dead process is taken over.
struct Lock(PathBuf);

impl Lock {
    fn take(install: &Path) -> Result<Lock, String> {
        create_dir(install)?;
        let path = install.join(".lock");
        for _ in 0..2 {
            match fs::OpenOptions::new().write(true).create_new(true).open(&path) {
                Ok(mut f) => {
                    let _ = write!(f, "{}", std::process::id());
                    return Ok(Lock(path));
                }
                Err(e) if e.kind() == std::io::ErrorKind::AlreadyExists => {
                    let pid = fs::read_to_string(&path).ok().and_then(|p| p.trim().parse::<u32>().ok());
                    if let Some(pid) = pid
                        && process_alive(pid)
                    {
                        return Err(format!("another `y install`/`y uninstall` (pid {pid}) is running ({})", path.display()));
                    }
                    let _ = fs::remove_file(&path);
                }
                Err(e) => return Err(format!("creating {}: {e}", path.display())),
            }
        }
        Err(format!("couldn't take {}", path.display()))
    }
}

impl Drop for Lock {
    fn drop(&mut self) {
        let _ = fs::remove_file(&self.0);
    }
}

fn process_alive(pid: u32) -> bool {
    if cfg!(windows) {
        let out = capture(std::process::Command::new("tasklist").args(["/FI", &format!("PID eq {pid}"), "/NH"]));
        out.is_ok_and(|o| o.stdout.split_whitespace().any(|w| w == pid.to_string()))
    } else {
        capture(std::process::Command::new("kill").args(["-0", &pid.to_string()])).is_ok_and(|o| o.status.success())
    }
}

/// Removes `dir`; if that fails (on Windows, a running `.exe`/`.dll` in it), renames it to
/// `<dir>.old`, which the next run deletes.
fn remove_or_rename(dir: &Path) -> Result<(), String> {
    if !dir.exists() || fs::remove_dir_all(dir).is_ok() {
        return Ok(());
    }
    let mut old = dir.as_os_str().to_owned();
    old.push(".old");
    let old = PathBuf::from(old);
    let _ = fs::remove_dir_all(&old);
    fs::rename(dir, &old).map_err(|e| format!("removing {}: {e}", dir.display()))?;
    eprintln!("[y] {} is in use; renamed it to {} (deleted on the next run)", dir.display(), old.display());
    Ok(())
}

/// Deletes the `*.partial` and `*.old` leftovers of earlier runs in `install/`.
fn remove_leftovers(install: &Path) {
    let Ok(entries) = fs::read_dir(install) else { return };
    for entry in entries.flatten() {
        let name = entry.file_name();
        let name = name.to_string_lossy();
        if name.ends_with(".partial") || name.ends_with(".old") {
            let _ = fs::remove_dir_all(entry.path());
        }
    }
}

fn list(items: &[String]) -> String {
    items.join(", ")
}

// ---------------------------------------------------------------------------------------------
// y install

/// What `y install` will do, computed read-only.
#[derive(Debug)]
struct InstallPlan {
    version: String,
    host: String,
    toolchain: String,
    /// Whether rustup has the toolchain.
    toolchain_present: bool,
    /// All targets (the host first).
    targets: Vec<String>,
    /// Components and targets to add.
    add_components: Vec<String>,
    add_targets: Vec<String>,
    /// Components and targets already there: the user's, or recorded by an earlier install.
    have_components: Vec<(String, bool)>,
    have_targets: Vec<(String, bool)>,
    ryo_std: bool,
    install: PathBuf,
    scripts: PathBuf,
    cargo_root: PathBuf,
    previous: Option<Manifest>,
    previous_version: Option<String>,
    /// Targets an earlier install added that this one doesn't need: removed at the end.
    remove_targets: Vec<String>,
    /// The record after this install.
    record: ToolchainRecord,
}

impl InstallPlan {
    fn render(&self) -> String {
        let mut s = format!("ryo install plan (ryo {})\n\n", self.version);
        let p = |s: &mut String, line: String| {
            s.push_str(&line);
            s.push('\n');
        };
        if let Some(prev) = &self.previous_version {
            if *prev == self.version {
                p(&mut s, format!("  0. Reinstall ryo {prev} (replaces the installed copy)"));
            } else {
                p(&mut s, format!("  0. Replace ryo {prev}"));
            }
            for t in &self.remove_targets {
                p(&mut s, format!("     - remove target {t} from toolchain {} (added by ryo, no longer needed)", self.toolchain));
            }
            s.push('\n');
        }
        p(&mut s, "  1. Rust toolchain (via rustup)".to_owned());
        let owner = |by_ryo: bool| if by_ryo { "added by ryo earlier" } else { "yours" };
        if !self.toolchain_present {
            p(&mut s, format!("     - install toolchain {} (--profile minimal)", self.toolchain));
        } else if self.record.installed_by_ryo {
            p(&mut s, format!("     - toolchain {PINNED_VERSION}: already installed (by ryo, removed on uninstall)"));
        } else {
            p(&mut s, format!("     - toolchain {PINNED_VERSION}: already installed (yours, kept on uninstall)"));
        }
        let have = |items: &[(String, bool)]| items.iter().map(|(c, r)| format!("{c}: {}", owner(*r))).collect::<Vec<_>>().join(", ");
        match (self.add_components.is_empty(), self.have_components.is_empty()) {
            (false, true) => p(&mut s, format!("     - add components {}", list(&self.add_components))),
            (false, false) => p(&mut s, format!("     - add components {} ({})", list(&self.add_components), have(&self.have_components))),
            (true, _) => p(&mut s, format!("     - components {}", have(&self.have_components))),
        }
        for t in &self.add_targets {
            p(&mut s, format!("     - add target {t}"));
        }
        for (t, r) in self.have_targets.iter().filter(|(t, _)| *t != self.host) {
            p(&mut s, format!("     - target {t}: {}", owner(*r)));
        }
        p(&mut s, "     Your default toolchain is not changed.".to_owned());
        s.push('\n');
        p(&mut s, format!("  2. Build and install, all in {}", dir_display(&self.install)));
        p(&mut s, "     (separate from dist/ and target/; your development builds are not affected)".to_owned());
        p(&mut s, "     - target/              cargo build output: backend, runtime, JIT".to_owned());
        p(&mut s, format!("     - build/               the built ryo: backend, wrappers, std for {}", list(&self.targets)));
        if self.ryo_std {
            p(&mut s, "                            and std compiled by ryo".to_owned());
        }
        p(&mut s, format!("     - {:<20} the installed copy; current names it", format!("{}/", self.version)));
        p(&mut s, "     - manifest.toml        what this install added, so uninstall removes exactly that".to_owned());
        s.push('\n');
        p(&mut s, "  3. Launchers".to_owned());
        p(&mut s, format!("     - cargo +{} install --path {}", self.toolchain, self.scripts.display()));
        p(&mut s, format!("       installs cargo-ryo and rustc-ryo into {}", self.cargo_root.join("bin").display()));
        s.push('\n');
        p(&mut s, "  Nothing else is changed: no shell profiles, PATH or cargo config.".to_owned());
        s.push('\n');
        p(&mut s, "  To undo: ./y.sh uninstall".to_owned());
        let mut undo = String::from("runs cargo uninstall cargo-ryo, removes from rustup only what step 1 added");
        let r = &self.record;
        if r.installed_by_ryo {
            undo.push_str(&format!(" (here: the {PINNED_VERSION} toolchain)"));
        } else if r.components_added.is_empty() && r.targets_added.is_empty() {
            undo.push_str(" (here: nothing)");
        } else {
            let all: Vec<String> = r.components_added.iter().chain(&r.targets_added).cloned().collect();
            undo.push_str(&format!(" (here: {})", list(&all)));
        }
        undo.push_str(", and deletes install/.");
        p(&mut s, format!("     {undo}"));
        s
    }
}

fn dir_display(dir: &Path) -> String {
    format!("{}{}", dir.display(), std::path::MAIN_SEPARATOR)
}

fn plan_install(o: &InstallOptions) -> Result<InstallPlan, String> {
    let host = rustup_host()?;
    if !host.starts_with("x86_64-") {
        if host.starts_with("aarch64-apple-") {
            return Err("ryo targets x86_64; run under Rosetta with an x86_64 rustup: arch -x86_64 ./y.sh install".to_owned());
        }
        return Err(format!("ryo targets x86_64 only, but rustup's host is {host}"));
    }
    if capture(cmd("cargo").arg("--version")).is_err() {
        return Err("cargo is not on PATH".to_owned());
    }
    let toolchain = format!("{PINNED_VERSION}-{host}");
    let install = install_dir();
    let previous = read_manifest(&install)?;
    let prev_record = previous.as_ref().map(|m| m.toolchain.clone()).filter(|r| r.name == toolchain).unwrap_or_default();
    let mut targets = vec![host.clone()];
    for t in &o.targets {
        if !targets.contains(t) {
            targets.push(t.clone());
        }
    }

    let state = toolchain_state(&toolchain)?;
    let toolchain_present = state.is_some();
    let (components, installed_targets) = state.unwrap_or_default();
    let mut record = ToolchainRecord { name: toolchain.clone(), installed_by_ryo: prev_record.installed_by_ryo, ..Default::default() };
    let (mut add_components, mut have_components) = (Vec::new(), Vec::new());
    for c in COMPONENTS {
        if toolchain_present && has_component(&components, c, &host) {
            let by_ryo = prev_record.components_added.iter().any(|r| r == c);
            if by_ryo {
                record.components_added.push(c.to_owned());
            }
            have_components.push((c.to_owned(), by_ryo));
        } else {
            add_components.push(c.to_owned());
            record.components_added.push(c.to_owned());
        }
    }
    let (mut add_targets, mut have_targets) = (Vec::new(), Vec::new());
    for t in &targets {
        if toolchain_present && installed_targets.contains(t) {
            let by_ryo = prev_record.targets_added.contains(t);
            if by_ryo {
                record.targets_added.push(t.clone());
            }
            have_targets.push((t.clone(), by_ryo));
        } else if *t != host || toolchain_present {
            add_targets.push(t.clone());
            record.targets_added.push(t.clone());
        }
    }
    if !toolchain_present {
        record.installed_by_ryo = true;
    }
    let remove_targets: Vec<String> = prev_record.targets_added.iter().filter(|t| !targets.contains(t)).cloned().collect();
    if o.no_toolchain_install && (!toolchain_present || !add_components.is_empty() || !add_targets.is_empty()) {
        let mut cmds = Vec::new();
        if !toolchain_present {
            cmds.push(format!("rustup toolchain install {PINNED_VERSION} --profile minimal"));
        }
        if !add_components.is_empty() {
            cmds.push(format!("rustup component add --toolchain {toolchain} {}", add_components.join(" ")));
        }
        if !add_targets.is_empty() {
            cmds.push(format!("rustup target add --toolchain {toolchain} {}", add_targets.join(" ")));
        }
        return Err(format!("the toolchain is incomplete and --no-toolchain-install was given; run:\n  {}", cmds.join("\n  ")));
    }

    let cargo_root = cargo_root()?;
    if let Launchers::Other(source) = launchers(&cargo_root)? {
        return Err(other_launchers_error(&source, &cargo_root));
    }
    Ok(InstallPlan {
        version: version(),
        host,
        toolchain,
        toolchain_present,
        targets,
        add_components,
        add_targets,
        have_components,
        have_targets,
        ryo_std: o.ryo_std,
        previous_version: current_version(&install),
        install,
        scripts: root().join("scripts"),
        cargo_root,
        previous,
        remove_targets,
        record,
    })
}

pub fn install(o: &InstallOptions) -> ExitCode {
    let plan = match plan_install(o) {
        Ok(plan) => plan,
        Err(e) => {
            eprintln!("error: {e}");
            return ExitCode::FAILURE;
        }
    };
    println!("{}", plan.render());
    if let Some(code) = confirm("install", o.yes, o.dry_run) {
        return code;
    }
    match do_install(&plan) {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("error: {e}");
            eprintln!("[y] the previous install (if any) still works; rerun ./y.sh install");
            ExitCode::FAILURE
        }
    }
}

fn do_install(plan: &InstallPlan) -> Result<(), String> {
    let install = &plan.install;
    let _lock = Lock::take(install)?;
    remove_leftovers(install);
    let t = &plan.toolchain;

    // 2. Toolchain.
    if !plan.toolchain_present {
        run(cmd("rustup").args(["toolchain", "install", PINNED_VERSION, "--profile", "minimal"]))?;
    }
    if !plan.add_components.is_empty() {
        run(cmd("rustup").args(["component", "add", "--toolchain", t]).args(&plan.add_components))?;
    }
    if !plan.add_targets.is_empty() {
        run(cmd("rustup").args(["target", "add", "--toolchain", t]).args(&plan.add_targets))?;
    }
    // From here on a failure leaves the additions recorded, so `y uninstall` removes them.
    let mut manifest = plan.previous.clone().unwrap_or_default();
    manifest.host = plan.host.clone();
    manifest.cargo_root = plan.cargo_root.display().to_string();
    let mut record = plan.record.clone();
    // Targets still to be removed (step 7) stay recorded until they are.
    record.targets_added.extend(plan.remove_targets.iter().cloned());
    manifest.toolchain = record;
    write(install.join("manifest.toml"), manifest.to_toml())?;
    let vv = crate::utils::output(cmd("rustc").arg(format!("+{t}")).arg("-vV"))?;
    let release = vv.lines().find_map(|l| l.strip_prefix("release: ")).unwrap_or("?");
    if release != PINNED_VERSION {
        return Err(format!("toolchain {t} reports release {release}"));
    }

    // 3. Build, with the pinned toolchain for everything `y` spawns.
    // SAFETY: `y` is single-threaded here.
    unsafe { std::env::set_var("RUSTUP_TOOLCHAIN", t) };
    let build = install.join("build");
    let build_id = crate::dist::build_in(&build, &install.join("target"), &plan.targets[1..], plan.ryo_std)?;

    // 4. Copy to `install/<version>/` (fresh mtimes, a new wrapper path), switch `current`.
    let partial = install.join(format!("{}.partial", plan.version));
    crate::utils::remove_dir_if_exists(&partial)?;
    eprintln!("[y] install: copying to {}", install.join(&plan.version).display());
    copy_dir(&build, &partial)?;
    let dest = install.join(&plan.version);
    remove_or_rename(&dest)?;
    fs::rename(&partial, &dest).map_err(|e| format!("renaming {} to {}: {e}", partial.display(), dest.display()))?;
    write(install.join("current"), format!("{}\n", plan.version))?;
    manifest.version = plan.version.clone();
    manifest.build_id = build_id;
    manifest.targets = plan.targets.clone();
    manifest.sysroots = if plan.ryo_std { vec!["llvm".into(), "ryo".into()] } else { vec!["llvm".into()] };
    write(install.join("manifest.toml"), manifest.to_toml())?;

    // 5. Launchers.
    run(cmd("cargo")
        .arg(format!("+{t}"))
        .args(["install", "--locked", "--force", "--path"])
        .arg(&plan.scripts)
        .arg("--root")
        .arg(&plan.cargo_root)
        .env_remove("RUSTC_BOOTSTRAP"))
    .map_err(|e| format!("{e}\nryo {} is installed, but its launchers weren't updated; rerun ./y.sh install", plan.version))?;

    // 7. The previous version and what only it needed.
    if let Some(prev) = &plan.previous_version
        && *prev != plan.version
    {
        remove_or_rename(&install.join(prev))?;
    }
    if !plan.remove_targets.is_empty() {
        run(cmd("rustup").args(["target", "remove", "--toolchain", t]).args(&plan.remove_targets))?;
        manifest.toolchain.targets_added.retain(|x| !plan.remove_targets.contains(x));
        write(install.join("manifest.toml"), manifest.to_toml())?;
    }

    // 8. Report.
    let bin = plan.cargo_root.join("bin");
    println!("[y] installed ryo {} in {}", plan.version, install.display());
    println!("[y]   cargo-ryo, rustc-ryo: {} (cargo install)", bin.display());
    let r = &manifest.toolchain;
    if r.installed_by_ryo {
        println!("[y]   toolchain {PINNED_VERSION}: installed by ryo (removed again by ./y.sh uninstall)");
    } else if !r.components_added.is_empty() || !r.targets_added.is_empty() {
        let all: Vec<String> = r.components_added.iter().chain(&r.targets_added).cloned().collect();
        println!("[y]   toolchain {PINNED_VERSION}: yours; ryo added {} (removed again by ./y.sh uninstall)", list(&all));
    } else {
        println!("[y]   toolchain {PINNED_VERSION}: yours, nothing added");
    }
    let on_path = std::env::var_os("PATH").is_some_and(|p| std::env::split_paths(&p).any(|d| d == bin));
    if !on_path {
        if cfg!(windows) {
            println!("[y] note: {} is not on PATH; add it to your user PATH", bin.display());
        } else {
            println!("[y] note: {} is not on PATH; add to your shell profile: export PATH=\"{}:$PATH\"", bin.display(), bin.display());
        }
    }
    println!("[y] try: cargo ryo build   (in any Cargo project)");
    Ok(())
}

// ---------------------------------------------------------------------------------------------
// y uninstall

/// One item of the uninstall plan.
#[derive(Debug, PartialEq)]
enum Step {
    /// `cargo uninstall cargo-ryo` from that root.
    Launchers(PathBuf),
    /// Launchers kept, with the reason.
    KeepLaunchers(String),
    RemoveToolchain(String),
    RemoveComponents(String, Vec<String>),
    RemoveTargets(String, Vec<String>),
    /// Toolchain pieces kept, with the reason.
    Keep(String),
    /// Delete `install/`.
    RemoveInstall(PathBuf),
}

impl Step {
    fn describe(&self) -> String {
        match self {
            Step::Launchers(root) => {
                format!("cargo uninstall --root {} cargo-ryo (cargo-ryo, rustc-ryo in {})", root.display(), root.join("bin").display())
            }
            Step::KeepLaunchers(why) => format!("launchers: kept ({why})"),
            Step::RemoveToolchain(t) => format!("rustup toolchain uninstall {t} (installed by ryo; its components go with it)"),
            Step::RemoveComponents(t, c) => format!("rustup component remove --toolchain {t} {} (added by ryo)", c.join(" ")),
            Step::RemoveTargets(t, c) => format!("rustup target remove --toolchain {t} {} (added by ryo)", c.join(" ")),
            Step::Keep(why) => format!("keep {why}"),
            Step::RemoveInstall(dir) => format!("delete {} (build output, installed versions, manifest)", dir_display(dir)),
        }
    }
}

fn plan_uninstall(o: &UninstallOptions, manifest: Option<&Manifest>) -> Result<Vec<Step>, String> {
    let install = install_dir();
    let cargo_root = match manifest {
        Some(m) if !m.cargo_root.is_empty() => PathBuf::from(&m.cargo_root),
        _ => cargo_root()?,
    };
    let mut steps = Vec::new();
    let launchers = launchers(&cargo_root)?;
    let other_owner = match &launchers {
        Launchers::Ours => {
            steps.push(Step::Launchers(cargo_root.clone()));
            None
        }
        Launchers::None => {
            steps.push(Step::KeepLaunchers("already gone".to_owned()));
            None
        }
        Launchers::Other(source) => {
            steps.push(Step::KeepLaunchers(format!("not ours: installed from {source}")));
            Some(source.clone())
        }
    };
    let Some(m) = manifest else {
        steps.push(Step::Keep("rustup as it is: there is no manifest, so what ryo added to it is unknown".to_owned()));
        return Ok(steps);
    };
    let r = &m.toolchain;
    let nothing = !r.installed_by_ryo && r.components_added.is_empty() && r.targets_added.is_empty();
    if o.keep_toolchain {
        steps.push(Step::Keep(format!("toolchain {} and what ryo added to it (--keep-toolchain)", r.name)));
    } else if nothing {
        steps.push(Step::Keep(format!("toolchain {}: yours, ryo added nothing", r.name)));
    } else if let Some(source) = other_owner {
        steps.push(Step::Keep(format!("what ryo added to toolchain {}: the launchers from {source} may still use it", r.name)));
    } else {
        match toolchain_state(&r.name)? {
            None => steps.push(Step::Keep(format!("toolchain {}: already removed", r.name))),
            Some(_) if r.installed_by_ryo => match toolchain_in_use(&r.name)? {
                Some(why) => steps.push(Step::Keep(format!("toolchain {} (installed by ryo, but {why})", r.name))),
                None => steps.push(Step::RemoveToolchain(r.name.clone())),
            },
            Some((components, targets)) => {
                let c: Vec<String> = r.components_added.iter().filter(|c| has_component(&components, c, &m.host)).cloned().collect();
                let t: Vec<String> = r.targets_added.iter().filter(|t| targets.contains(t)).cloned().collect();
                if !c.is_empty() {
                    steps.push(Step::RemoveComponents(r.name.clone(), c));
                }
                if !t.is_empty() {
                    steps.push(Step::RemoveTargets(r.name.clone(), t));
                }
                steps.push(Step::Keep(format!("toolchain {}: yours", r.name)));
            }
        }
    }
    steps.push(Step::RemoveInstall(install));
    Ok(steps)
}

pub fn uninstall(o: &UninstallOptions) -> ExitCode {
    let install = install_dir();
    let result = (|| -> Result<Option<ExitCode>, String> {
        let manifest = read_manifest(&install)?;
        let steps = plan_uninstall(o, manifest.as_ref())?;
        let acts = steps.iter().any(|s| !matches!(s, Step::KeepLaunchers(_) | Step::Keep(_)));
        if manifest.is_none() && !acts {
            println!("[y] ryo is not installed in this checkout");
            return Ok(None);
        }
        let version = manifest.as_ref().map_or("(unknown version)".to_owned(), |m| m.version.clone());
        let mut plan = format!("ryo uninstall plan (ryo {version})\n\n");
        for (n, s) in steps.iter().enumerate() {
            plan.push_str(&format!("  {}. {}\n", n + 1, s.describe()));
        }
        plan.push_str(
            "\n  Not touched: cargo's download cache, development builds (dist/, target/), your\n  \
             projects' target/ dirs, and any .cargo/config.toml, rust-toolchain.toml or rustup\n  \
             override selecting ryo.\n",
        );
        println!("{plan}");
        if let Some(code) = confirm("uninstall", o.yes, o.dry_run) {
            return Ok(Some(code));
        }
        let lock = if install.exists() { Some(Lock::take(&install)?) } else { None };
        for s in &steps {
            match s {
                Step::Launchers(root) => run(cmd("cargo").args(["uninstall", "--root"]).arg(root).arg("cargo-ryo"))?,
                Step::RemoveToolchain(t) => run(cmd("rustup").args(["toolchain", "uninstall", t]))?,
                Step::RemoveComponents(t, c) => run(cmd("rustup").args(["component", "remove", "--toolchain", t]).args(c))?,
                Step::RemoveTargets(t, c) => run(cmd("rustup").args(["target", "remove", "--toolchain", t]).args(c))?,
                Step::KeepLaunchers(_) | Step::Keep(_) => {}
                Step::RemoveInstall(dir) => {
                    drop(lock);
                    crate::utils::remove_dir_if_exists(dir)?;
                    break;
                }
            }
            println!("[y]   {}", s.describe());
        }
        println!("[y] removed ryo {version}");
        Ok(None)
    })();
    match result {
        Ok(code) => code.unwrap_or(ExitCode::SUCCESS),
        Err(e) => {
            eprintln!("error: {e}");
            ExitCode::FAILURE
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn manifest_round_trip() {
        let m = Manifest {
            version: "0.3.0-41-g7654b22".into(),
            build_id: "9f2c".into(),
            host: "x86_64-unknown-linux-gnu".into(),
            targets: vec!["x86_64-unknown-linux-gnu".into(), "x86_64-pc-windows-msvc".into()],
            sysroots: vec!["llvm".into()],
            cargo_root: r#"C:\Users\a "b"\.cargo"#.into(),
            toolchain: ToolchainRecord {
                name: "1.99.1-x86_64-unknown-linux-gnu".into(),
                installed_by_ryo: true,
                components_added: vec!["rustc-dev".into(), "rust-src".into()],
                targets_added: vec![],
            },
        };
        assert_eq!(Manifest::parse(&m.to_toml()), Ok(m));
        assert!(Manifest::parse("format = 2\n").is_err());
        assert!(Manifest::parse("format = 1\nfrob = \"x\"\n").is_err());
        assert!(Manifest::parse("format = 1\n[toolchain]\ninstalled_by_ryo = maybe\n").is_err());
    }

    #[test]
    fn cargo_install_list() {
        let list = "cargo-fuzz v0.13.1:\n    cargo-fuzz\ncargo-ryo v0.1.0 (/home/a/ryo/scripts):\n    cargo-ryo\n    rustc-ryo\n";
        assert_eq!(cargo_ryo_source(list), Some("/home/a/ryo/scripts".into()));
        assert_eq!(cargo_ryo_source("cargo-ryo v1.0.0:\n    cargo-ryo\n"), Some(String::new()));
        assert_eq!(cargo_ryo_source("cargo-ryo-x v1.0.0:\n    cargo-ryo\n"), None);
        let err = other_launchers_error("/home/b/ryo/scripts", Path::new("/c"));
        assert!(err.contains("./y.sh uninstall` in /home/b/ryo"), "{err}");
    }

    #[test]
    fn rustup_components() {
        let installed =
            names("cargo-x86_64-unknown-linux-gnu\nllvm-tools-preview-x86_64-unknown-linux-gnu\nrust-src\nrustc-dev-x86_64-unknown-linux-gnu\n");
        let host = "x86_64-unknown-linux-gnu";
        assert!(has_component(&installed, "rustc-dev", host));
        assert!(has_component(&installed, "rust-src", host));
        assert!(has_component(&installed, "llvm-tools", host));
        assert!(!has_component(&installed, "rustfmt", host));
        assert_eq!(names("stable-x86_64-unknown-linux-gnu (active)\n1.99.1-x86_64-unknown-linux-gnu\n")[1], "1.99.1-x86_64-unknown-linux-gnu");
    }

    #[test]
    fn options() {
        assert_eq!(
            parse_install(&["--target", "a", "--sysroot=ryo", "-y", "--dry-run"]),
            Ok(InstallOptions { targets: vec!["a".into()], ryo_std: true, yes: true, dry_run: true, ..Default::default() })
        );
        assert!(parse_install(&["--force"]).is_err());
        assert_eq!(parse_uninstall(&["--keep-toolchain", "--yes"]), Ok(UninstallOptions { keep_toolchain: true, yes: true, dry_run: false }));
        assert!(parse_uninstall(&["--keep-cache"]).is_err());
    }

    #[test]
    fn install_plan_text() {
        let plan = InstallPlan {
            version: "0.3.0-41-g7654b22".into(),
            host: "x86_64-unknown-linux-gnu".into(),
            toolchain: "1.99.1-x86_64-unknown-linux-gnu".into(),
            toolchain_present: false,
            targets: vec!["x86_64-unknown-linux-gnu".into()],
            add_components: COMPONENTS.map(String::from).to_vec(),
            add_targets: vec![],
            have_components: vec![],
            have_targets: vec![],
            ryo_std: false,
            install: "/r/install".into(),
            scripts: "/r/scripts".into(),
            cargo_root: "/h/.cargo".into(),
            previous: None,
            previous_version: None,
            remove_targets: vec![],
            record: ToolchainRecord { installed_by_ryo: true, ..Default::default() },
        };
        let text = plan.render();
        assert!(text.contains("install toolchain 1.99.1-x86_64-unknown-linux-gnu (--profile minimal)"), "{text}");
        assert!(text.contains("add components rustc-dev, rust-src, llvm-tools"), "{text}");
        assert!(text.contains("(here: the 1.99.1 toolchain)"), "{text}");
        assert!(!text.contains("  0."), "{text}");
    }
}
