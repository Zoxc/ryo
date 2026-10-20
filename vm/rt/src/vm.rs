//! See design/vm.md and design/stubs.md.

/// Entry from portals. Returns 0 on success, 1 when unwinding (payload moved to `payload_out`).
#[allow(unused_variables)]
pub unsafe fn enter(id: u64, args: *const u8, ret: *mut u8, payload_out: *mut crate::unwind::RawPayload) -> u32 { unimplemented!() }
