//! The backend's debugging switches (design/backend.md, "Debugging switches"): every
//! environment variable the backend reads. `init` reads them for the backend, and the partition
//! provider (a plain fn, which can't reach the backend) reads them again and threads them
//! through partitioning and lowering.

use std::ffi::OsString;
pub struct Switches {
    /// `RYO_STATS`: the statistics level, 0 for none.
    pub stats: u32,
    /// `RYO_DUMP`: where to write the image's dump.
    pub dump: Option<OsString>,
    /// `RYO_DUMP_CODE`: where to write the dump of the image's machine code.
    pub dump_code: Option<OsString>,
    /// `RYO_DUMP_NATIVE`: where to write the list of functions that stay native, and of the
    /// VM functions with islands.
    pub dump_native: Option<OsString>,
    /// `RYO_DUMP_LEAN`: the directory for the Lean dump, and whether to build the
    /// certificates it holds.
    pub dump_lean: Option<OsString>,
    /// `RYO_NO_VM`: compile nothing to the VM.
    pub no_vm: bool,
    /// `RYO_ASM_CHECK`: re-encode each function's code and check it.
    pub asm_check: bool,
    /// `RYO_ASM_ALIGN` (unless `0`): align loop heads.
    pub asm_align: bool,
    /// `RYO_BACKEND_MARKER`: print the init and partition markers.
    pub marker: bool,
}

impl Switches {
    pub fn from_env() -> Switches {
        let var = std::env::var_os;
        Switches {
            stats: std::env::var("RYO_STATS").ok().and_then(|v| v.parse().ok()).unwrap_or(0),
            dump: var("RYO_DUMP"),
            dump_code: var("RYO_DUMP_CODE"),
            dump_native: var("RYO_DUMP_NATIVE"),
            dump_lean: var("RYO_DUMP_LEAN"),
            no_vm: var("RYO_NO_VM").is_some(),
            asm_check: var("RYO_ASM_CHECK").is_some(),
            asm_align: var("RYO_ASM_ALIGN").is_none_or(|v| v != "0"),
            marker: var("RYO_BACKEND_MARKER").is_some(),
        }
    }
}
