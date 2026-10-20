//! See design/vm.md and design/stubs.md.

/// Entry from portals. Returns 0 on success, 1 when unwinding (payload moved to `payload_out`).
///
/// # Safety
/// `args` points at the callee's argument block, whose values the VM takes ownership of. `ret`
/// is valid for writing the return value, and `payload_out` for writing a `RawPayload`.
#[allow(unused_variables)]
pub unsafe fn enter(
    id: u64,
    args: *const u8,
    ret: *mut u8,
    payload_out: *mut crate::unwind::RawPayload,
) -> u32 {
    unimplemented!()
}
