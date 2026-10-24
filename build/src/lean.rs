//! `y lean`: the Lean verification project in `lean/` (lean/README.md). Checks that the
//! generated tables (`lean/Ryo/Vm/Generated`) match the Rust ones, then runs `lake build` and
//! `lake test`. `y lean gen` regenerates the tables. Both go through the generating tests
//! `vm/bytecode/tests/lean_*.rs` (the tables, the x86, decoder and unwind-table test vectors, the JIT's effect table), which `y test` also runs.

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
        "lean_effects",
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

/// `y lean gen`.
pub fn generate() -> Result<(), String> {
    tables(true)
}

/// `y lean`.
pub fn check() -> Result<(), String> {
    tables(false)?;
    let lake = lake();
    let dir = root().join("lean");
    run(cmd(&lake).current_dir(&dir).arg("build"))?;
    run(cmd(&lake).current_dir(&dir).arg("test"))
}
