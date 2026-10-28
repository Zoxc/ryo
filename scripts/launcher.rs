//! The launchers `cargo-ryo` and `rustc-ryo` that `y install` puts in cargo's bin dir with
//! `cargo install --path scripts` (design/install.md). Each runs the real wrapper of the
//! same name in the installed ryo: `$RYO_HOME/bin/<name>` if `RYO_HOME` is set (e.g. a
//! development `dist/`), else `<checkout>/install/<version>/bin/<name>`, where `<version>` is
//! the contents of `install/current` and the checkout is where this package was built from.
//! All logic stays in the real wrappers. Only std, no rustc-dev.

use std::env;
use std::path::PathBuf;
use std::process::Command;

pub fn run(name: &str) -> ! {
    let dir = match env::var_os("RYO_HOME").filter(|h| !h.is_empty()) {
        Some(home) => PathBuf::from(home),
        None => installed().unwrap_or_else(|install| fail(&format!("ryo is not installed in {}; run ./y.sh install there", install.display()))),
    };
    let exe = dir.join("bin").join(format!("{name}{}", env::consts::EXE_SUFFIX));
    if !exe.is_file() {
        fail(&format!("{} not found (RYO_HOME or the ryo install is incomplete)", exe.display()));
    }
    let mut cmd = Command::new(&exe);
    cmd.args(env::args_os().skip(1));
    #[cfg(unix)]
    let err = {
        use std::os::unix::process::CommandExt;
        cmd.exec()
    };
    #[cfg(not(unix))]
    let err = match cmd.status() {
        Ok(status) => std::process::exit(status.code().unwrap_or(1)),
        Err(err) => err,
    };
    fail(&format!("failed to run {}: {err}", exe.display()))
}

/// `<checkout>/install/<current>`, or `Err(<checkout>/install)` if there is none.
fn installed() -> Result<PathBuf, PathBuf> {
    let install = PathBuf::from(env!("CARGO_MANIFEST_DIR")).parent().expect("scripts/ has a parent").join("install");
    let version = std::fs::read_to_string(install.join("current")).map_err(|_| install.clone())?;
    let dir = install.join(version.trim());
    if version.trim().is_empty() || !dir.is_dir() {
        return Err(install);
    }
    Ok(dir)
}

fn fail(msg: &str) -> ! {
    eprintln!("error: {msg}");
    std::process::exit(1);
}
