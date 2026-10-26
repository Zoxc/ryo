//! The interface between the runtime (`ryo_rt`) and the JIT (design/jit.md): what the
//! runtime gives the JIT when it starts it ([`RtApi`]), and the constants both sides use to
//! switch a function over to its JIT code. `core` only, so that neither crate depends on the
//! other.
//!
//! The JIT defines one C symbol, `ryo_jit_start(rt: &'static RtApi) -> bool`, which starts
//! its thread (false if the thread doesn't start).
//! Everything else goes through the [`RtApi`]: the JIT reads the handlers' addresses from
//! it, takes queued records with [`RtApi::next_batch`], and reports each with
//! [`RtApi::done`]. Records, images and code are shared memory in the layout of
//! [`crate::image`]. Nothing crosses the interface by unwinding: `ryo_jit_start` is
//! `extern "C"`, and the runtime's callbacks never unwind. They are `extern "C-unwind"` only
//! so that the compiler adds no abort-on-unwind guard to them, which would reference core's
//! panic path from the runtime (design/vm.md, "No re-entry").

use crate::Opcode;
use crate::image::JitRecord;

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

/// [`RtApi::flags`]: compile through the SSA tier with every value in a stack slot
/// (`RYO_JIT_OPT=ssa-naive`).
pub const JIT_OPT_SSA_NAIVE: u32 = 16;
/// [`RtApi::flags`]: compile through the SSA tier with its register allocator
/// (`RYO_JIT_OPT=ssa`).
pub const JIT_OPT_SSA: u32 = 32;
/// [`RtApi::flags`]: run the SSA tier's checkers (`RYO_JIT_CHECK`).
pub const JIT_CHECK: u32 = 64;

/// What the runtime gives the JIT: built once, before the JIT starts, and never changed.
#[repr(C)]
pub struct RtApi {
    /// [`JIT_SYNC`], [`JIT_LOG`], [`JIT_PERFMAP`], [`JIT_TEST_PANIC`], [`JIT_OPT_SSA_NAIVE`],
    /// [`JIT_OPT_SSA`], [`JIT_CHECK`].
    pub flags: u32,
    /// `ryo_probe_stack`'s address.
    pub probe: *const (),
    /// The program's `rust_eh_personality`: the JIT finds an image's personality slot, which
    /// its unwind information names, by this address. (The JIT's own `rust_eh_personality`,
    /// if it has a std of its own, is another function.)
    pub personality: *const (),
    /// The thresholds the records' counters started at, as counts: calls
    /// ([`JitRecord::ctr_e`]) and loop iterations ([`JitRecord::ctr_l`]), for
    /// [`crate::image::jit_count`].
    pub thresholds: [i64; 2],
    /// Takes the queued records, in the order they were queued, linked through
    /// [`JitRecord::next`]. With `wait`, sleeps while there are none and never returns
    /// null; without, returns null if there are none. The records are the JIT's until it
    /// reports them with [`RtApi::done`]. Only the JIT's thread calls it.
    pub next_batch: extern "C-unwind" fn(wait: bool) -> *mut JitRecord,
    /// Reports a record: compiled (`true`, after the JIT published it: `Done`) or not
    /// (`false`: the runtime marks it `Failed`). Wakes the threads waiting for it.
    pub done: extern "C-unwind" fn(rec: *mut JitRecord, ok: bool),
    /// Whether the functions of the image with this header get another frame layout than
    /// their AOT code's (`RYO_JIT_SHUFFLE`, or per image in tests).
    pub shuffled: extern "C-unwind" fn(header: *const u8) -> bool,
    /// The header of the registered image whose text or read-only section holds `addr`, or
    /// null: the JIT calls a VM function of another image at its JIT code once it is
    /// compiled, rather than through its AOT entry, and finds it by the address its caller's
    /// symbol slot holds; and it folds loads from the constant pool a constant address points
    /// into.
    pub image_at: extern "C-unwind" fn(addr: usize) -> *const u8,
    /// Every opcode's handler address by opcode, null for opcodes without a handler.
    pub handlers: [*const (); Opcode::COUNT],
    /// Every opcode's register entry (design/jit.md, "Register entries"), null for opcodes
    /// without one: [`crate::jit::effects::reg_entry`] says which have one, and how they take
    /// their operands.
    pub reg_handlers: [*const (); Opcode::COUNT],
}

// SAFETY: immutable once built; the pointers are code addresses.
unsafe impl Sync for RtApi {}

/// The name of the JIT's one exported symbol.
pub const START_SYMBOL: &str = "ryo_jit_start";
