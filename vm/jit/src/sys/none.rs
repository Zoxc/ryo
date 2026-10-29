//! Not ported yet: `ryo_jit_start` fails, and the runtime acts as the no-op JIT.

use super::Unwind;

pub(crate) const SUPPORTED: bool = false;

pub(super) unsafe fn register(u: &Unwind<'_>) -> bool {
    let _ = u;
    false
}
