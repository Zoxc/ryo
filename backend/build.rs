//! Bakes the backend's build ID into it (`RYO_BACKEND_ID`): a hash of everything the backend's
//! code comes from (its and `ryo_bytecode`'s sources and manifests, the lock file, the rustc
//! and the build's settings, and the ABI tag `y build` passes in `RYO_ABI`, which covers the
//! runtime crates, design/build.md#the-abi-tag). Incremental image reuse keys on it (design/backend.md#incremental),
//! so a running rustc never reads the backend's file, which a rebuild may have replaced.

use std::hash::Hasher;
use std::path::{Path, PathBuf};

fn main() {
    let dir = PathBuf::from(std::env::var_os("CARGO_MANIFEST_DIR").unwrap());
    let vm = dir.join("../vm");
    let inputs = [
        dir.join("src"),
        dir.join("build.rs"),
        dir.join("Cargo.toml"),
        dir.join("Cargo.lock"),
        vm.join("Cargo.toml"),
        vm.join("bytecode/Cargo.toml"),
        vm.join("bytecode/src"),
    ];
    let mut h = std::hash::DefaultHasher::new();
    for input in &inputs {
        println!("cargo:rerun-if-changed={}", input.display());
        hash_path(&mut h, &dir, input);
    }
    // The compiler and the settings the code is built with.
    let rustc = std::env::var("RUSTC").unwrap();
    let version = std::process::Command::new(&rustc).arg("-vV").output().expect("running rustc -vV").stdout;
    h.write(&version);
    for var in ["TARGET", "PROFILE", "OPT_LEVEL", "DEBUG", "CARGO_ENCODED_RUSTFLAGS", "CARGO_CFG_TARGET_FEATURE", "RYO_ABI"] {
        println!("cargo:rerun-if-env-changed={var}");
        h.write(var.as_bytes());
        h.write(std::env::var(var).unwrap_or_default().as_bytes());
    }
    println!("cargo:rustc-env=RYO_BACKEND_ID={:016x}", h.finish());
}

/// Hashes the file `path`, or each file under the directory `path` in name order, with its
/// path relative to the crate. Fails on one it can't read: a build ID that left it out could
/// reuse images across a change to it.
fn hash_path(h: &mut impl Hasher, root: &Path, path: &Path) {
    let fail = |e: std::io::Error| -> ! { panic!("reading {}: {e}", path.display()) };
    if path.is_dir() {
        let mut entries: Vec<_> = std::fs::read_dir(path).unwrap_or_else(|e| fail(e)).map(|e| e.unwrap_or_else(|e| fail(e)).path()).collect();
        entries.sort();
        for e in entries {
            hash_path(h, root, &e);
        }
    } else {
        let bytes = std::fs::read(path).unwrap_or_else(|e| fail(e));
        h.write(path.strip_prefix(root).unwrap_or(path).as_os_str().as_encoded_bytes());
        h.write_usize(bytes.len());
        h.write(&bytes);
    }
}
