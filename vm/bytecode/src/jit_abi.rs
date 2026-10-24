//! The interface between the runtime (`ryo_rt`) and the JIT (design/jit.md): what the
//! runtime gives the JIT when it starts it ([`RtApi`]), and the constants both sides use to
//! switch a function over to its JIT code. `core` only, so that neither crate depends on the
//! other.
//!
//! The JIT defines one C symbol, `ryo_jit_start(rt: &'static RtApi) -> bool`, which starts
//! its thread (false if it can't: [`RtApi::compatible`] fails, or the thread doesn't start).
//! Everything else goes through the [`RtApi`]: the JIT reads the handlers' addresses from
//! it, takes queued records with [`RtApi::next_batch`], and reports each with
//! [`RtApi::done`]. Records, images and code are shared memory in the layout of
//! [`crate::image`]. Nothing crosses the interface by unwinding: `ryo_jit_start` is
//! `extern "C"`, and the runtime's callbacks never unwind. They are `extern "C-unwind"` only
//! so that the compiler adds no abort-on-unwind guard to them, which would reference core's
//! panic path from the runtime (design/vm.md, "No re-entry").

use crate::Opcode;
use crate::image::JitRecord;

/// The version of [`RtApi`] and of the protocol around it. Bumped on every incompatible
/// change; the JIT refuses to start on a mismatch ([`RtApi::compatible`]).
pub const JIT_ABI_VERSION: u32 = 1;

/// The counter of a compiled function ([`JitRecord::ctr`]): far enough below 0 that the
/// counter checks' `sub`s keep it negative (every check takes its stub) for 2^58 calls. Not
/// `i64::MIN`, from which the next `sub` would wrap to a large positive count.
pub const REDIRECT: i64 = i64::MIN / 2;

/// The bytes before a JIT function's first instruction that its record's `entry` points at:
/// `lea r11, [rip + code]; mov [rsp], r11; ret`, which replaces the return address of the
/// counter stub's `call [r11 + 8]` with the code and returns to it, so that the function
/// starts with its caller's return address on top, as if called directly. Returning rather
/// than dropping the address (`pop`) keeps the return stack buffer balanced: the `ret`
/// mispredicts once, but the function's own `ret` and its callers' don't.
pub const JIT_ENTRY_PREFIX: usize = 12;

/// [`RtApi::flags`]: a trip that queues a function waits until it is compiled
/// (`RYO_JIT_SYNC`). The runtime does the waiting and the waking; for the JIT's information.
pub const JIT_SYNC: u32 = 1;
/// [`RtApi::flags`]: a line on stderr per compiled or failed function (`RYO_JIT_LOG`).
pub const JIT_LOG: u32 = 2;
/// [`RtApi::flags`]: a line per compiled function in `/tmp/perf-<pid>.map`
/// (`RYO_JIT_PERFMAP`).
pub const JIT_PERFMAP: u32 = 4;
/// [`RtApi::flags`]: every compile panics, which must fail the function and nothing else
/// (`RYO_JIT_TEST_PANIC`, tests).
pub const JIT_TEST_PANIC: u32 = 8;

/// What the runtime gives the JIT: built once, before the JIT starts, and never changed.
#[repr(C)]
pub struct RtApi {
    /// [`JIT_ABI_VERSION`].
    pub abi: u32,
    /// [`crate::FORMAT_VERSION`]: both sides read images with their own copy of this crate.
    pub format: u32,
    /// `size_of::<RtApi>()`.
    pub size: u32,
    /// [`JIT_SYNC`], [`JIT_LOG`], [`JIT_PERFMAP`], [`JIT_TEST_PANIC`].
    pub flags: u32,
    /// `ryo_probe_stack`'s address.
    pub probe: *const (),
    /// The program's `rust_eh_personality`: the JIT finds an image's personality slot, which
    /// its unwind information names, by this address. (The JIT's own `rust_eh_personality`,
    /// if it has a std of its own, is another function.)
    pub personality: *const (),
    /// Takes the queued records, in the order they were queued, linked through
    /// [`JitRecord::next`], and sleeps while there are none: never null. The records are
    /// the JIT's until it reports them with [`RtApi::done`]. Only the JIT's thread calls it.
    pub next_batch: extern "C-unwind" fn() -> *mut JitRecord,
    /// Reports a record: compiled (`true`, after the JIT published it: `Done`) or not
    /// (`false`: the runtime marks it `Failed`). Wakes the threads waiting for it.
    pub done: extern "C-unwind" fn(rec: *mut JitRecord, ok: bool),
    /// Whether the functions of the image with this header get another frame layout than
    /// their AOT code's (`RYO_JIT_SHUFFLE`, or per image in tests).
    pub shuffled: extern "C-unwind" fn(header: *const u8) -> bool,
    /// Every opcode's handler address by opcode, null for opcodes without a handler.
    pub handlers: [*const (); Opcode::COUNT],
}

// SAFETY: immutable once built; the pointers are code addresses.
unsafe impl Sync for RtApi {}

impl RtApi {
    /// Whether this side can use `self`: the same interface and format versions. Reads only
    /// the first three fields, which every version keeps.
    pub fn compatible(&self) -> bool {
        self.abi == JIT_ABI_VERSION && self.format == crate::FORMAT_VERSION && self.size as usize == core::mem::size_of::<RtApi>()
    }
}

/// The name of the JIT's one exported symbol.
pub const START_SYMBOL: &str = "ryo_jit_start";
