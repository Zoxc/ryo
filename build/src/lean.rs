//! `y lean`: the Lean verification project in `lean/` (lean/README.md). Checks that the
//! generated tables (`lean/Ryo/Vm/Generated`) match the Rust ones, then runs `lake build` and
//! `lake test`; `y lean --proofs` also builds the slow proofs (`lake build RyoProofs`).
//! `y lean gen` regenerates the tables. Both go through the generating tests
//! `vm/bytecode/tests/lean_*.rs` (the tables, the x86, decoder, view and unwind-table test
//! vectors), which `y test` also runs. The other way, the JIT's handler effect table
//! (`vm/bytecode/src/jit/effects_table.rs`) is generated from the Lean footprints by
//! `ryo-lean effects`: `y lean gen` builds `ryo-lean` and rewrites it, `y lean` fails if it
//! is out of date.

use std::path::PathBuf;

use crate::utils::{cmd, exe_name, root, run};

/// Runs the generating tests, rewriting their files with `regen`.
fn tables(regen: bool) -> Result<(), String> {
    let mut c = cmd("cargo");
    c.current_dir(root().join("vm")).args([
        "test",
        "-p",
        "ryo_bytecode",
        "--test",
        "lean_tables",
        "--test",
        "lean_x86_vectors",
        "--test",
        "lean_reduced_vectors",
        "--test",
        "lean_unwind_vectors",
        "--test",
        "lean_view_vectors",
    ]);
    if regen {
        c.env("RYO_LEAN_GEN", "1");
    }
    run(&mut c)
}

/// `lake`: on `PATH`, or where elan installs it.
fn lake() -> PathBuf {
    let name = exe_name("lake");
    let on_path = std::env::var_os("PATH").and_then(|p| std::env::split_paths(&p).map(|d| d.join(&name)).find(|p| p.is_file()));
    let home = std::env::var_os(if cfg!(windows) { "USERPROFILE" } else { "HOME" });
    on_path.or_else(|| home.map(|h| PathBuf::from(h).join(".elan").join("bin").join(&name))).unwrap_or_else(|| name.into())
}

/// Whether `lake` is installed.
pub fn have_lake() -> bool {
    cmd(lake()).arg("--version").output().is_ok_and(|o| o.status.success())
}

/// The generated JIT effect table, and what `ryo-lean effects` (built) gives.
fn effects_table() -> Result<(PathBuf, String), String> {
    let path = root().join("vm/bytecode/src/jit/effects_table.rs");
    let exe = root().join("lean/.lake/build/bin").join(exe_name("ryo-lean"));
    Ok((path, crate::utils::capture_ok(cmd(&exe).arg("effects"))?.stdout))
}

/// `y lean gen`.
pub fn generate() -> Result<(), String> {
    tables(true)?;
    run(cmd(lake()).current_dir(root().join("lean")).arg("build"))?;
    let (path, want) = effects_table()?;
    crate::utils::write(&path, want)
}

/// `y lean`, and with `proofs` `y lean --proofs`.
pub fn check(proofs: bool) -> Result<(), String> {
    tables(false)?;
    let lake = lake();
    let dir = root().join("lean");
    run(cmd(&lake).current_dir(&dir).arg("build"))?;
    let (path, want) = effects_table()?;
    if std::fs::read_to_string(&path).ok().as_deref() != Some(want.as_str()) {
        return Err(format!("{} is out of date with the Lean footprints: run `./y.sh lean gen`", path.display()));
    }
    run(cmd(&lake).current_dir(&dir).arg("test"))?;
    if proofs {
        run(cmd(&lake).current_dir(&dir).args(["build", "RyoProofs"]))?;
    }
    Ok(())
}
