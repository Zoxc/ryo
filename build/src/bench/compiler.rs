//! The compilers `y bench` and `y bench crates` compare, and the tools they need.

use std::path::{Path, PathBuf};

/// A codegen backend: plain rustc (LLVM), cg_clif or ryo.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Compiler {
    Llvm,
    Clif,
    Ryo,
}

pub const COMPILERS: &[Compiler] = &[Compiler::Llvm, Compiler::Clif, Compiler::Ryo];

impl Compiler {
    pub fn name(self) -> &'static str {
        match self {
            Compiler::Llvm => "llvm",
            Compiler::Clif => "clif",
            Compiler::Ryo => "ryo",
        }
    }

    pub fn parse(s: &str) -> Option<Compiler> {
        COMPILERS.iter().copied().find(|b| b.name() == s)
    }

    pub fn rustc(self, root: &Path) -> PathBuf {
        match self {
            Compiler::Llvm => "rustc".into(),
            Compiler::Clif => crate::utils::dist_bin(root, "rustc-clif"),
            Compiler::Ryo => crate::utils::dist_bin(root, "rustc-ryo"),
        }
    }
}

/// Builds `out/dist/` if it is missing, and rustc-clif if a backend needs it.
pub fn ensure_tools(root: &Path, cmd: &str, mut backends: impl Iterator<Item = Compiler>) -> Result<(), String> {
    if !Compiler::Ryo.rustc(root).exists() {
        eprintln!("[y] {cmd}: out/dist/ is missing, building it");
        // Into `out/dist/` itself (not `RYO_Y_DIST_DIR`): that is where the bench runs it from.
        crate::dist::build_in(&crate::utils::out_dir(root).join("dist"), &crate::utils::out_dir(root).join("target"), &Default::default())?;
    }
    if backends.any(|b| b == Compiler::Clif) {
        crate::clif::ensure()?;
    }
    Ok(())
}
