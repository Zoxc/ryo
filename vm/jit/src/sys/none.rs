//! Not ported yet: `ryo_jit_start` fails, and the runtime acts as the no-op JIT.

use super::Unwind;

pub(crate) const SUPPORTED: bool = false;

pub(super) unsafe fn register(u: &Unwind<'_>) -> bool {
    let _ = u;
    false
}

/// Writes `b` to stderr.
pub(crate) fn write_stderr(b: &[u8]) {
    let _ = b;
}

/// Where `perf` looks for the process's JIT symbols: nowhere.
pub(crate) fn perfmap_path() -> Option<std::string::String> {
    None
}
