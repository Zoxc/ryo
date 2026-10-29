//! `y build` and `y clean`: the `dist/` sysroot (design/build.md#build).

use std::fs;
use std::path::{Path, PathBuf};

use crate::utils::{RustcInfo, build_wrapper, cmd, copy, dll_name, output, root, run};

/// Unstable features the backend may use, even though `RUSTC_BOOTSTRAP` allows all
/// (`macro_metavar_expr_concat`: `ryo_bytecode`'s opcode families).
const BACKEND_FEATURES: &str = "rustc_private,macro_metavar_expr_concat";

/// What `y build` builds; `y install` takes the same flags for its build.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct BuildOptions {
    pub sysroot: Sysroot,
    /// Extra targets (besides the host) to install std and `ryo_rt` for, for cross-compiling
    /// with `rustc-ryo --target` (their rust-std component must be installed).
    pub targets: Vec<String>,
}

#[derive(Debug, Clone, Copy, Default, PartialEq)]
pub enum Sysroot {
    #[default]
    Llvm,
    /// Also build std with the ryo backend into `dist/sysroot-ryo` (`--sysroot ryo`).
    Ryo,
}

impl BuildOptions {
    /// Takes `--sysroot` and `--target`; `false` for any other flag.
    pub fn parse_flag(&mut self, flag: &str, args: &mut crate::utils::Flags) -> Result<bool, String> {
        match flag {
            "--sysroot" => {
                self.sysroot = match args.value()? {
                    "llvm" => Sysroot::Llvm,
                    "ryo" => Sysroot::Ryo,
                    other => return Err(format!("unknown sysroot `{other}`")),
                }
            }
            "--target" => self.targets.push(args.value()?.to_owned()),
            _ => return Ok(false),
        }
        Ok(true)
    }
}

/// `y build`.
pub fn build(o: &BuildOptions) -> Result<(), String> {
    let root = root();
    // Tests build a second `dist/` of another ryo build elsewhere (`RYO_ABI_OVERRIDE`).
    let dir = |var: &str, default: &str| std::env::var_os(var).map_or_else(|| root.join(default), PathBuf::from);
    build_in(&dir(DIST_DIR_VAR, "dist"), &dir(TARGET_DIR_VAR, "target"), o).map(drop)
}

/// `y build`'s output directory instead of `dist/` (tests).
pub const DIST_DIR_VAR: &str = "RYO_Y_DIST_DIR";
/// `y build`'s cargo target directory instead of `target/` (tests).
pub const TARGET_DIR_VAR: &str = "RYO_Y_TARGET_DIR";

/// [`build`] with `dist` as the output directory (what `dist/` is for `y build`) and `target`
/// as cargo's target directory (`y install` uses `install/build/` and `install/target/`).
/// Returns the build id.
pub fn build_in(dist: &Path, target: &Path, o: &BuildOptions) -> Result<String, String> {
    let info = RustcInfo::get()?;
    let root = root();
    let (dist, target) = (dist.to_path_buf(), target.to_path_buf());
    // The ABI tag (design/build.md#the-abi-tag), for every cargo build below: the backend's
    // and the runtime's `ryo_bytecode`, `ryo_rt`'s and the JIT's build scripts.
    let tag = abi_tag(&root)?;
    eprintln!("[y] abi tag: {tag}");
    // SAFETY: `y` is single-threaded here.
    unsafe { std::env::set_var(ABI_VAR, &tag) };

    let backend = build_backend(&root, &target, &info)?;

    eprintln!("[y] sysroot: {}", dist.display());
    // Everything but the ryo sysroot and its stamp, which `y test` checks for staleness
    // ([`crate::sysroot::ryo_sysroot_status`]) instead of losing a slow build to each `y build`.
    if dist.exists() {
        for entry in fs::read_dir(&dist).map_err(|e| format!("{}: {e}", dist.display()))? {
            let entry = entry.map_err(|e| e.to_string())?;
            let name = entry.file_name();
            if name == crate::sysroot::SYSROOT_DIR || name == crate::sysroot::STAMP_FILE {
                continue;
            }
            let path = entry.path();
            let r = if entry.file_type().map_err(|e| e.to_string())?.is_dir() { fs::remove_dir_all(&path) } else { fs::remove_file(&path) };
            r.map_err(|e| format!("removing {}: {e}", path.display()))?;
        }
    }
    let dist_lib = dist.join("lib");
    let dist_bin = dist.join("bin");
    for dir in [&dist_lib, &dist_bin] {
        crate::utils::create_dir(dir)?;
    }
    copy(&backend, &dist_lib.join(dll_name("rustc_codegen_ryo")))?;
    crate::utils::write(dist.join(ABI_FILE), &tag)?;
    // What `rustc-ryo -vV` identifies the build by (design/build.md#the-y-build-tool).
    let mut build_files = vec![backend.clone()];
    let mut all = vec![info.host.clone()];
    all.extend(o.targets.iter().filter(|t| **t != info.host).cloned());
    let mut host_jit = None;
    let rb = RuntimeBuild { root: &root, target: &target, info: &info, tag: &tag };
    for triple in &all {
        let target_lib = crate::utils::rustlib(&dist, triple).join("lib");
        crate::utils::create_dir(&target_lib)?;
        install_llvm_sysroot(&info, &dist, triple)?;
        let cross = rb.cross(triple);
        let jit = if crate::jit::supported(triple) { Some(crate::jit::build(&rb, triple, false)?) } else { None };
        // For the host, also the checked JIT `y test` runs (design/build.md#build): `ryo_rt`
        // with it swapped in, in `dist/jit-checked/`.
        let checked = if cross.is_none() && jit.is_some() { Some(crate::jit::build(&rb, triple, true)?) } else { None };
        for (krate, rlib) in build_runtime(&rb, &dist, triple, jit.as_deref())? {
            copy(&rlib, &target_lib.join(format!("lib{krate}.rlib")))?;
            if krate == "ryo_rt"
                && let Some(sealed) = &checked
            {
                crate::jit::swap_into_rlib(&info, &target_lib.join("libryo_rt.rlib"), sealed, &dist.join(crate::jit::CHECKED_DIR))?;
            }
            build_files.push(rlib);
        }
        if cross.is_none()
            && let (Some(release), Some(checked)) = (jit, checked)
        {
            host_jit = Some(crate::jit::SealedJits { release, checked });
        }
    }

    let build_id = build_id(&build_files)?;
    build_wrappers(&root, &dist_bin, &info, &build_id)?;
    if o.sysroot == Sysroot::Ryo {
        crate::sysroot::build(&info, &dist, &target, host_jit.as_ref())?;
    }
    eprintln!("[y] done: {}", dist.display());
    Ok(build_id)
}

pub fn clean() -> Result<(), String> {
    let root = root();
    for dir in [root.join("dist"), root.join("target")] {
        if dir.exists() {
            eprintln!("[y] removing {}", dir.display());
            fs::remove_dir_all(&dir).map_err(|e| format!("removing {}: {e}", dir.display()))?;
        }
    }
    Ok(())
}

/// Builds `backend/` and returns the path of the dylib.
fn build_backend(root: &Path, target: &Path, info: &RustcInfo) -> Result<PathBuf, String> {
    eprintln!("[y] backend: rustc_codegen_ryo");
    let target_dir = target.join("backend");
    let mut rustflags = std::env::var("RUSTFLAGS").unwrap_or_default();
    if !rustflags.is_empty() {
        rustflags.push(' ');
    }
    rustflags.push_str(&format!("-Zallow-features={BACKEND_FEATURES}"));
    run(cmd("cargo")
        .args(["build", "--release", "-Zembed-metadata=no", "--manifest-path"])
        .arg(root.join("backend").join("Cargo.toml"))
        .arg("--target-dir")
        .arg(&target_dir)
        .env("RUSTFLAGS", rustflags)
        // Full optimization, independent of user settings: one codegen unit and fat LTO over
        // the backend's own crates (librustc_driver stays a dynamic dependency).
        .env("CARGO_PROFILE_RELEASE_CODEGEN_UNITS", "1")
        .env("CARGO_PROFILE_RELEASE_LTO", "fat")
        .env("RUSTUP_TOOLCHAIN", &info.toolchain))?;
    Ok(target_dir.join("release").join(dll_name("rustc_codegen_ryo")))
}

/// Copies the toolchain's prebuilt std for `triple` into `dist/`, skipping the rustc-dev and
/// LLVM libraries, as cg_clif does. Also copies the target's `bin/` (the self-contained linker).
fn install_llvm_sysroot(info: &RustcInfo, dist: &Path, triple: &str) -> Result<(), String> {
    let src_lib = crate::utils::rustlib(&info.sysroot, triple).join("lib");
    if !src_lib.is_dir() {
        return Err(format!("no std for {triple} in the toolchain; run `rustup target add {triple}`"));
    }
    let dst_lib = crate::utils::rustlib(dist, triple).join("lib");
    for entry in fs::read_dir(&src_lib).map_err(|e| format!("{}: {e}", src_lib.display()))? {
        let entry = entry.map_err(|e| e.to_string())?;
        if entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            continue;
        }
        let name = entry.file_name();
        if is_std_lib(&name.to_string_lossy()) {
            copy(&entry.path(), &dst_lib.join(&name))?;
        }
    }
    crate::utils::copy_target_bin(&info.sysroot, dist, triple)
}

/// Whether to copy a file from the toolchain's `lib/rustlib/<target>/lib`. This is the same
/// coarse filter as cg_clif's `build_llvm_sysroot_for_triple`: it skips the `rustc_*` and LLVM
/// libraries, but still lets through the `.rmeta`s and proc-macro dylibs of rustc-dev's
/// third-party dependencies (unused, but harmless).
fn is_std_lib(file_name: &str) -> bool {
    let rustc_dev = file_name.contains("rustc_")
        && !file_name.contains("rustc_std_workspace_")
        && !file_name.contains("rustc_demangle")
        && !file_name.contains("rustc_literal_escaper");
    !rustc_dev && !file_name.contains("LLVM")
}

/// What every runtime build of a `y build` (the JIT's, `ryo_rt`'s) shares: the repository,
/// cargo's target directory, the toolchain and the ABI tag.
pub struct RuntimeBuild<'a> {
    pub root: &'a Path,
    pub target: &'a Path,
    pub info: &'a RustcInfo,
    pub tag: &'a str,
}

impl RuntimeBuild<'_> {
    /// `triple` if it is a cross target (cargo's `--target`), `None` for the host.
    pub fn cross<'t>(&self, triple: &'t str) -> Option<&'t str> {
        (triple != self.info.host).then_some(triple)
    }
}

/// The features `RYO_RT_FEATURES` adds to `ryo_rt` (split on commas and spaces, sorted), such
/// as `fp-rbp` for measurements (design/build.md#test-and-bench).
fn rt_features() -> Vec<String> {
    let mut features: Vec<String> =
        std::env::var("RYO_RT_FEATURES").unwrap_or_default().split([',', ' ']).filter(|f| !f.is_empty()).map(str::to_owned).collect();
    features.sort();
    features.dedup();
    features
}

/// Builds `ryo_rt` (and `ryo_bytecode`) with the stock LLVM backend against `dist/`'s std, for
/// `triple`, and returns their crate names and rlibs. With `jit`, the
/// directory of the sealed JIT ([`crate::jit::build`]), `ryo_rt` gets its `jit` feature and
/// bundles it.
fn build_runtime(rb: &RuntimeBuild, dist: &Path, triple: &str, jit: Option<&Path>) -> Result<Vec<(&'static str, PathBuf)>, String> {
    let (root, target, tag, cross) = (rb.root, rb.target, rb.tag, rb.cross(triple));
    eprintln!("[y] runtime: ryo_rt{}", cross.map(|t| format!(" for {t}")).unwrap_or_default());
    let mut sysroot_flag = String::from("--sysroot=");
    sysroot_flag.push_str(dist.to_str().ok_or("dist/ path is not UTF-8")?);
    let metadata = runtime_metadata_flag(tag);
    let mut rustflags = vec![sysroot_flag.as_str(), "-Ccodegen-units=1", "-Cpanic=unwind", metadata.as_str()];
    // Windows: no red zone in the `sysv64` handlers either (design/platforms.md).
    if cross.map_or(cfg!(windows), crate::target::is_windows) {
        rustflags.push(crate::jit::NO_REDZONE);
    }
    let mut cargo = cmd("cargo");
    // The JIT (design/jit.md), and what `RYO_RT_FEATURES` adds.
    let mut features = rt_features();
    if let Some(dir) = jit {
        cargo.env(JIT_LIB_DIR_VAR, dir);
        features.insert(0, "jit".to_owned());
    }
    let features = features.join(",");
    cargo.args(["build", "--release", "-p", "ryo_rt", "--features", &features]);
    if let Some(t) = cross {
        cargo.args(["--target", t]);
    }
    let out = output(
        cargo
            .arg("--message-format=json-render-diagnostics")
            .arg("--manifest-path")
            .arg(root.join("vm").join("Cargo.toml"))
            .arg("--target-dir")
            .arg(target.join("vm"))
            // Independent of the user's profile settings and RUSTFLAGS.
            .env("CARGO_PROFILE_RELEASE_OPT_LEVEL", "3")
            .env("CARGO_PROFILE_RELEASE_CODEGEN_UNITS", "1")
            .env("CARGO_PROFILE_RELEASE_PANIC", "unwind")
            .env_remove("RUSTFLAGS")
            .env("CARGO_ENCODED_RUSTFLAGS", rustflags.join("\x1f")),
    )?;
    let rlibs = artifact_rlibs(&out);
    RUNTIME_CRATES
        .into_iter()
        .map(|krate| match rlibs.iter().find(|p| rlib_crate(p) == Some(krate)) {
            Some(rlib) => Ok((krate, rlib.clone())),
            None => Err(format!("cargo did not report an rlib for {krate}")),
        })
        .collect()
}

/// The `.rlib` paths in the `compiler-artifact` messages of cargo's JSON output. A minimal
/// scan, not a JSON parser (`y` has no dependencies): paths containing `,`, `]` or escaped
/// quotes are not supported.
fn artifact_rlibs(json: &str) -> Vec<PathBuf> {
    let mut rlibs = Vec::new();
    for line in json.lines().filter(|l| l.contains(r#""reason":"compiler-artifact""#)) {
        let Some(start) = line.find(r#""filenames":["#) else { continue };
        let rest = &line[start + r#""filenames":["#.len()..];
        let list = &rest[..rest.find(']').unwrap_or(rest.len())];
        for item in list.split(',') {
            let path = item.trim().trim_matches('"').replace(r"\\", r"\");
            if path.ends_with(".rlib") {
                rlibs.push(PathBuf::from(path));
            }
        }
    }
    rlibs
}

/// `libfoo-<hash>.rlib` or `libfoo.rlib` -> `foo`.
fn rlib_crate(path: &Path) -> Option<&str> {
    let stem = path.file_stem()?.to_str()?.strip_prefix("lib")?;
    Some(stem.split_once('-').map_or(stem, |(name, _)| name))
}

/// The environment variable `ryo_rt`'s build script takes the sealed JIT's directory from.
pub const JIT_LIB_DIR_VAR: &str = "RYO_JIT_LIB_DIR";

/// The runtime crates [`build_runtime`] builds, whose identity carries the ABI tag
/// ([`runtime_metadata_flag`]).
pub const RUNTIME_CRATES: [&str; 2] = ["ryo_rt", "ryo_bytecode"];

/// The `-Cmetadata` flag that puts the ABI tag `tag` in the runtime crates' identity: their
/// symbols differ between tags, and their crate hashes, which every ryo-built crate records
/// (design/build.md#the-abi-tag).
pub fn runtime_metadata_flag(tag: &str) -> String {
    format!("-Cmetadata={tag}")
}

/// The environment variable the ABI tag reaches the cargo builds in (`ryo_bytecode::ABI_TAG`,
/// `ryo_rt`'s and `ryo_jit`'s build scripts).
pub const ABI_VAR: &str = "RYO_ABI";

/// Overrides the computed ABI tag (tests: a second `dist/` of another ryo build).
pub const ABI_OVERRIDE_VAR: &str = "RYO_ABI_OVERRIDE";

/// The file in `dist/` holding the tag it was built with.
pub const ABI_FILE: &str = "abi-tag";

/// The ABI tag (design/build.md#the-abi-tag): 16 hex digits of a hash of everything that
/// defines the contract between images, handlers, registry, JIT records and the JIT: the
/// `vm/` crates' sources and manifests, `vm/Cargo.lock` and `RYO_RT_FEATURES`. Or
/// `RYO_ABI_OVERRIDE`, which must be a C identifier part (alphanumeric or `_`).
pub fn abi_tag(root: &Path) -> Result<String, String> {
    if let Ok(t) = std::env::var(ABI_OVERRIDE_VAR) {
        if t.is_empty() || !t.bytes().all(|b| b.is_ascii_alphanumeric() || b == b'_') {
            return Err(format!("{ABI_OVERRIDE_VAR}={t:?}: not a C identifier part"));
        }
        return Ok(t);
    }
    Ok(format!("{:016x}", runtime_hash(root)?))
}

/// The hash behind the computed ABI tag: what the runtime is built from (the `vm/` crates'
/// sources, manifests and build scripts, `vm/Cargo.{toml,lock}`, `RYO_RT_FEATURES`). Also
/// the ryo sysroot's stamp of the runtime.
pub fn runtime_hash(root: &Path) -> Result<u64, String> {
    use crate::utils::{hash_file, hash_tree};
    use std::hash::Hasher;
    let vm = root.join("vm");
    let mut h = std::hash::DefaultHasher::new();
    for krate in ["bytecode", "rt", "jit"] {
        hash_tree(&vm.join(krate).join("src"), Path::new(krate), &mut h)?;
        hash_file(&mut h, &vm.join(krate).join("Cargo.toml"))?;
        let build = vm.join(krate).join("build.rs");
        if build.exists() {
            hash_file(&mut h, &build)?;
        }
    }
    for f in ["Cargo.toml", "Cargo.lock"] {
        hash_file(&mut h, &vm.join(f))?;
    }
    // Parsed, so that spellings of the same features give the same tag.
    h.write(rt_features().join(",").as_bytes());
    Ok(h.finish())
}

/// The tag `dist` was built with ([`ABI_FILE`]).
pub fn dist_abi_tag(dist: &Path) -> Result<String, String> {
    fs::read_to_string(dist.join(ABI_FILE))
        .map(|s| s.trim().to_owned())
        .map_err(|e| format!("{}: {e} (run `./y.sh build`)", dist.join(ABI_FILE).display()))
}

/// A hash of `files`' contents: the backend dylib and the runtime rlibs.
fn build_id(files: &[PathBuf]) -> Result<String, String> {
    Ok(format!("{:016x}", crate::utils::hash_files(files)?))
}

fn build_wrappers(root: &Path, dist_bin: &Path, info: &RustcInfo, build_id: &str) -> Result<(), String> {
    for name in ["rustc-ryo", "cargo-ryo"] {
        build_wrapper(root, dist_bin, info, name, build_id)?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn std_lib_filter() {
        assert!(is_std_lib("libstd-0123abcd.rlib"));
        assert!(is_std_lib("libstd-0123abcd.so"));
        assert!(is_std_lib("librustc_std_workspace_core-01.rlib"));
        assert!(is_std_lib("librustc_demangle-01.rlib"));
        assert!(is_std_lib("librustc_literal_escaper-01.rlib"));
        assert!(!is_std_lib("librustc_driver-01.so"));
        assert!(!is_std_lib("librustc_middle-01.rmeta"));
        assert!(!is_std_lib("libLLVM.so.21.1-rust-1.99.1-stable"));
    }

    #[test]
    fn rlibs_from_cargo_json() {
        let json = concat!(
            r#"{"reason":"compiler-artifact","target":{"name":"ryo_bytecode"},"filenames":["/t/release/deps/libryo_bytecode-ab12.rlib","/t/release/deps/libryo_bytecode-ab12.rmeta"],"fresh":true}"#,
            "\n",
            r#"{"reason":"compiler-artifact","filenames":["C:\\t\\release\\libryo_rt.rlib"]}"#,
            "\n",
            r#"{"reason":"build-finished","success":true}"#,
        );
        let rlibs = artifact_rlibs(json);
        assert_eq!(rlibs, [PathBuf::from("/t/release/deps/libryo_bytecode-ab12.rlib"), PathBuf::from(r"C:\t\release\libryo_rt.rlib")]);
        assert_eq!(rlib_crate(&rlibs[0]), Some("ryo_bytecode"));
        assert_eq!(rlib_crate(Path::new("libryo_rt.rlib")), Some("ryo_rt"));
    }
}
