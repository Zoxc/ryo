//! The names of `ryo_rt`'s entry points that the backend and the JIT reference (before the
//! ABI tag and mangling), and of the symbols around images: the one definition `ryo_rt`'s
//! `export_name`s, the backend's objects and the JIT's dumps share. `build`'s
//! `rt-core-only` check (`build/src/test/checks.rs`, zero deps) keeps its own copy.

use core::fmt;

use crate::asm::Mode;
use crate::full::Opcode;

/// The name literals, for attributes that need one (`ryo_rt`'s
/// `export_name = tagged!(rt_sym!(probe))`): `handler` and `reg_handler` are the prefixes of
/// [`handler`] and [`reg_handler`], `fp_handler` and `fp_reg_handler` those of the frame-pointer
/// set ([`Mode::rbp_set`]).
#[macro_export]
macro_rules! rt_sym {
    (handler) => {
        "ryo_h_"
    };
    (reg_handler) => {
        "ryo_hr_"
    };
    (fp_handler) => {
        "ryo_hf_"
    };
    (fp_reg_handler) => {
        "ryo_hrf_"
    };
    (probe) => {
        "ryo_probe_stack"
    };
    (register) => {
        "ryo_vm_register"
    };
    (seh_handler) => {
        "ryo_seh_handler"
    };
    (trip_entry) => {
        "ryo_jit_trip_entry"
    };
    (trip_osr) => {
        "ryo_jit_trip_osr"
    };
    (jit_start) => {
        "ryo_jit_start"
    };
}

/// `$name` with the ABI tag as a suffix, `<name>_<tag>`: the symbol names of the runtime's
/// entry points and of the JIT's `ryo_jit_start`, so that two ryo builds never share a name
/// (design/build.md#the-abi-tag, [`crate::ABI_TAG`]). Reads `RYO_ABI` from the calling crate's
/// environment, which `ryo_rt`'s and `ryo_jit`'s build scripts set.
#[macro_export]
macro_rules! tagged {
    ($name:expr) => {
        concat!($name, "_", env!("RYO_ABI"))
    };
}

/// The stack probe of large frames.
pub const PROBE: &str = rt_sym!(probe);
/// The registration entry point.
pub const REGISTER: &str = rt_sym!(register);
/// The language handler of VM code's PE unwind info (design/vm.md#unwinding).
pub const SEH_HANDLER: &str = rt_sym!(seh_handler);
/// The JIT's trip entry points, which the JIT records' slots start at.
pub const TRIP_ENTRY: &str = rt_sym!(trip_entry);
pub const TRIP_OSR: &str = rt_sym!(trip_osr);
/// The JIT's one exported symbol (`ryo_jit`), which `ryo_rt` calls to start the JIT thread.
pub const JIT_START: &str = rt_sym!(jit_start);

/// The pointer slot `ryo_rt::entry::c_main` loads the entry fn's address from (untagged).
pub const MAIN_SLOT: &str = "__ryo_main";

/// A symbol name with an opcode: `ryo_h_AddW32`.
#[derive(Clone, Copy, Debug)]
pub struct OpSymbol(&'static str, Opcode);

impl fmt::Display for OpSymbol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}{:?}", self.0, self.1)
    }
}

/// The name of opcode `op`'s handler for code of `mode`: `ryo_h_<op>`, or of the frame-pointer
/// set `ryo_hf_<op>` ([`Mode::rbp_set`]).
pub fn handler(op: Opcode, mode: Mode) -> OpSymbol {
    OpSymbol(if mode.rbp_set() { rt_sym!(fp_handler) } else { rt_sym!(handler) }, op)
}

/// The name of opcode `op`'s register entry for code of `mode` (JIT code only, which has no
/// symbol: the dumps' name).
pub fn reg_handler(op: Opcode, mode: Mode) -> OpSymbol {
    OpSymbol(if mode.rbp_set() { rt_sym!(fp_reg_handler) } else { rt_sym!(reg_handler) }, op)
}
