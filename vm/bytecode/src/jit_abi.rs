//! The interface between the runtime (`ryo_rt`) and the JIT (design/jit.md): what the
//! runtime gives the JIT when it starts it ([`RtApi`]), and the constants both sides use to
//! switch a function over to its JIT code. `core` only, so that neither crate depends on the
//! other.
//!
//! The JIT defines one C symbol, `ryo_jit_start_<tag>(rt: &'static RtApi, child: bool) ->
//! Option<extern "C" fn()>` (ABI-tagged, [`crate::tagged!`]),
//! which starts its thread and returns its exit report (`RYO_JIT_STATS`'s summary), or `None`
//! if the thread doesn't start. `child`: a restart in a forked child, whose JIT state (hooks,
//! `atexit` handlers, statics) the parent set up: only a new thread with a new compiler.
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
pub const JIT_ENTRY_PREFIX: usize = JIT_ENTRY_PREFIX_BYTES.len();

/// The entry prefix's bytes ([`JIT_ENTRY_PREFIX`]): `lea r11, [rip + 5]` (5: the length of
/// the two instructions after the `lea`), `mov [rsp], r11`, `ret`.
pub const JIT_ENTRY_PREFIX_BYTES: [u8; 12] = [0x4c, 0x8d, 0x1d, 5, 0, 0, 0, 0x4c, 0x89, 0x1c, 0x24, 0xc3];

/// How the JIT compiles (`RYO_JIT_OPT`, design/jit.md, "The SSA pipeline").
#[repr(u8)]
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum JitOpt {
    /// The SSA pipeline with every value in a stack slot (`ssa-naive`).
    SsaNaive,
    /// The SSA pipeline with its register allocator (`ssa`, the default).
    Ssa,
}

impl JitOpt {
    /// Its `RYO_JIT_OPT` value.
    #[inline]
    pub const fn name(self) -> &'static str {
        match self {
            JitOpt::SsaNaive => "ssa-naive",
            JitOpt::Ssa => "ssa",
        }
    }

    /// The tier a `RYO_JIT_OPT` value names, `None` for an unknown one. (Inline: `ryo_rt`
    /// calls it from `extern "C"` functions, where a call it can't see through would pull in
    /// core's panic path.)
    #[inline]
    pub fn parse(s: &[u8]) -> Option<JitOpt> {
        [JitOpt::SsaNaive, JitOpt::Ssa].into_iter().find(|o| o.name().as_bytes() == s)
    }
}

/// The settings the JIT gets from the runtime, which reads them from the environment
/// (design/jit.md, "Settings"). `RYO_JIT_DUMP`, a path, the JIT reads itself.
#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct JitSettings {
    /// A line on stderr per compiled or failed function (`RYO_JIT_LOG`).
    pub log: bool,
    /// A line per compiled function in `/tmp/perf-<pid>.map` (`RYO_JIT_PERFMAP`).
    pub perfmap: bool,
    /// Every compile panics, which must fail the function and nothing else
    /// (`RYO_JIT_TEST_PANIC`, tests).
    pub test_panic: bool,
    /// Every compile fails an allocation, which must fail the function and nothing else
    /// (`RYO_JIT_TEST_OOM`, tests).
    pub test_oom: bool,
    /// Run the SSA pipeline's checkers (`RYO_JIT_CHECK`).
    pub check: bool,
    /// How functions are compiled (`RYO_JIT_OPT`).
    pub opt: JitOpt,
    /// Only the first this many functions go to the SSA pipeline, the rest stay in their AOT
    /// code (`RYO_JIT_SSA_LIMIT`, debugging: bisects a miscompile); `u64::MAX` for all.
    pub ssa_limit: u64,
    /// General loop-invariant code motion in the SSA pipeline (`RYO_JIT_LICM`), off by default.
    pub licm: bool,
    /// `RYO_JIT_STATS`: 0 for nothing, 1 for a startup line and an exit summary, 2 also for
    /// progress lines from the JIT thread, at most one a minute.
    pub stats: u8,
    /// Whether the JIT thread times its compiles for the statistics (`RYO_JIT_STATS` set, or
    /// tests); its other counters always count.
    pub count: bool,
    /// Loop rotation in the SSA pipeline (`RYO_JIT_ROTATE=1`), off by default.
    pub rotate: bool,
}

/// What the runtime gives the JIT: built once, before the JIT starts, and never changed.
#[repr(C)]
pub struct RtApi {
    /// The settings.
    pub settings: JitSettings,
    /// The program's `rust_eh_personality`: the JIT finds an image's personality slot, which
    /// its unwind information names, by this address. (The JIT's own `rust_eh_personality`,
    /// if it has a std of its own, is another function.)
    pub personality: *const (),
    /// PE: `ryo_seh_handler`, the language handler VM code's unwind info names
    /// (design/vm.md#unwinding), which the JIT's code reaches through a thunk of its own
    /// (null off Windows).
    pub seh_handler: *const (),
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
    /// This copy's handlers and probe, which the JIT's code calls.
    pub code: &'static RtCode,
    /// The handlers and probe that the code of the registered image with this header calls:
    /// those of the runtime copy that linked it, another copy's for an image that copy
    /// forwarded when it merged into this one (design/vm.md#several-ryo-runtimes-in-one-process);
    /// null for this copy's own ([`RtApi::code`]).
    pub code_of: extern "C-unwind" fn(header: *const u8) -> *const RtCode,
    /// Publishes the call map of installed JIT code for backtraces ([`BtRegion`]), before
    /// the code can run. The region and its tables are the runtime's from then on, and stay
    /// for the rest of the process. Only the JIT's thread calls it.
    pub bt_publish: extern "C-unwind" fn(region: *mut BtRegion),
    /// Takes and releases the quiesce lock, which a fork waits for (`pthread_atfork`): the
    /// JIT's thread holds it around what a forked child couldn't recover from if the fork
    /// landed in the middle (registering unwind information and publishing code, unwinding a
    /// panic). Not re-entrant; held for microseconds, never across a compile.
    pub fork_enter: extern "C-unwind" fn(),
    pub fork_leave: extern "C-unwind" fn(),
}

/// The call map of one compilation's code, for backtraces (design/vm.md#source-locations):
/// for each call in `[start, start + len)`, by the offset of its last byte (the return
/// address minus one), the chain of AOT positions its frame stands for, innermost first: the
/// call in the innermost inlined callee, then the calls the inliner replaced around it,
/// ending at the root's.
#[repr(C)]
pub struct BtRegion {
    /// The next region published before this one (the runtime's list).
    pub next: *mut BtRegion,
    pub start: usize,
    pub len: usize,
    /// The root's image (its header's address) and function index: a call without an entry
    /// is named after it.
    pub root_img: usize,
    pub root_func: u32,
    /// The entries: `[offset, chain]`, sorted by offset.
    pub npc: u32,
    pub pcmap: *const [u32; 2],
    pub nchain: u32,
    pub chains: *const BtChain,
}

/// A link of a [`BtRegion`] chain: the call at byte `pos` of function `func`'s AOT code in
/// the image with header `img`, inlined into the call `parent` ([`BT_ROOT`]: none).
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct BtChain {
    pub img: usize,
    pub func: u32,
    pub pos: u32,
    pub parent: u32,
    pub pad: u32,
}

/// A runtime copy's handler entry points: what its images' AOT code calls, which the JIT
/// recognizes when it decodes that code. Copies of one build have the same handlers, which
/// keep no state, so the JIT's code calls its own copy's ([`RtApi::code`]) for any image.
#[repr(C)]
pub struct RtCode {
    /// `ryo_probe_stack`'s address.
    pub probe: *const (),
    /// Every opcode's handler address by opcode, null for opcodes without a handler.
    pub handlers: [*const (); Opcode::COUNT],
    /// Every opcode's register entry (design/jit.md, "Register entries"), null for opcodes
    /// without one: [`crate::jit::effects::reg_entry`] says which have one, and how they take
    /// their operands.
    pub reg_handlers: [*const (); Opcode::COUNT],
    /// Tests off Windows only (`ryo_rt`'s `pe-test`): the handlers and register entries of
    /// PE code (Win64, `Mode::pe`), as [`RtCode::handlers`] and [`RtCode::reg_handlers`]; null
    /// without them, when PE code uses those (on Windows they are the PE form's).
    pub pe_handlers: *const [*const (); Opcode::COUNT],
    pub pe_reg_handlers: *const [*const (); Opcode::COUNT],
    /// The frame-pointer set's handlers and register entries (`ryo_hf_<Opcode>`, for code of
    /// a mode with [`crate::asm::Mode::rbp_set`]), as [`RtCode::handlers`]; null where the
    /// runtime has none (PE, Apple).
    pub fp_handlers: *const [*const (); Opcode::COUNT],
    pub fp_reg_handlers: *const [*const (); Opcode::COUNT],
}

// SAFETY: immutable once built; the pointers are code addresses, and the PE and frame-pointer
// ones the copy's tables, written once before it is built and never again.
unsafe impl Sync for RtCode {}

/// No parent ([`BtChain::parent`]).
pub const BT_ROOT: u32 = u32::MAX;

// SAFETY: immutable once built; the pointers are code addresses, and `code` is an immutable
// `RtCode`.
unsafe impl Sync for RtApi {}
