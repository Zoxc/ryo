//! The image format (design/vm.md, "Image format") and its zero-copy reader.
//!
//! An image is three sections:
//!
//! **Read-only** (starts with [`Header`], aligned to at least 8; byte offsets below are
//! from the header):
//!
//! | Part | Contents |
//! |---|---|
//! | header | [`Header`] |
//! | functions | `[FuncEntry]`, sorted by code offset; index = [`Func`](crate::full::Func) |
//! | instruction lists | bytes: each function's instruction list ([`crate::asm::list`], [`FuncEntry::list`]) |
//! | call sites | `[CallSiteEntry]`, each function's in a run ([`FuncEntry::call_sites`]) |
//! | code constants | what the machine code refers to: island operand arrays, switch values |
//! | fixups | `[FixupEntry]` (PE only, otherwise empty) |
//! | symbol flags | `[u8]`, one per symbol ([`SYM_INDIRECT`]) |
//! | function flags | `[u8]`, one per function ([`FUNC_INLINE_ALWAYS`] etc.) |
//! | symbols | `[u64]`: one pointer slot per symbol, filled by the linker |
//! | constants | the constant pool, aligned to its most aligned allocation |
//! | constant relocations | `[u32]`, sorted: the pool offset of every relocated (pointer) field in the pool |
//!
//! **Writable**: the site cache (`site_count` pointer-sized zeroed slots), then the fixup
//! area at `Header::fixup_area` (constant allocations patched at registration, PE only),
//! then with [`Mode::counters`] one [`JitRecord`] per function at `Header::jit_records`.
//!
//! The header's `data` field is a pointer to the writable section, filled by a relocation.
//!
//! **Text** (executable): every function's machine code ([`crate::asm`]), in function table
//! order, each aligned to 16. The header's `text` field points at it (a relocation), and a
//! function's `code_off` is its byte offset there. Unwinding information (CFI and the LSDA
//! call-site tables, or PE unwind info) is emitted with the text by the backend.
//!
//! The reader works on `core` only. [`Image::parse`] checks the header and that every part
//! is in bounds and aligned (cheap, O(1)); [`Image::validate`] also checks every function and
//! fixups (O(size)).

#[cfg(feature = "alloc")]
mod writer;
#[cfg(feature = "alloc")]
pub use writer::*;
#[cfg(feature = "alloc")]
mod resolve;
#[cfg(feature = "alloc")]
pub use resolve::ImageResolver;

use core::{fmt, mem, slice};

use crate::asm::Mode;

/// `pe_handler_data` read back: the handler data of a VM function's PE `UNWIND_INFO`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct PeHandlerData<'a> {
    /// The offset of the `RUNTIME_FUNCTION`'s range from the function's start.
    pub begin: u32,
    /// The pad region's offset from the function's start, 0 if there is none.
    pub region: u32,
    pub lsda: &'a [u8],
}

impl<'a> PeHandlerData<'a> {
    /// The handler data at the start of `data`. `None` if it doesn't fit.
    pub fn parse(data: &'a [u8]) -> Option<PeHandlerData<'a>> {
        let word = |i: usize| Some(u32::from_le_bytes(data.get(4 * i..4 * i + 4)?.try_into().ok()?));
        let (begin, region, len) = (word(0)?, word(1)?, word(2)?);
        Some(PeHandlerData { begin, region, lsda: data.get(12..)?.get(..len as usize)? })
    }

    /// The handler data at `data`, whose length is in its header.
    ///
    /// # Safety
    /// `data` must point at handler data [`pe_handler_data`] wrote.
    pub unsafe fn from_ptr(data: *const u8) -> Option<PeHandlerData<'a>> {
        // SAFETY: the header's 12 bytes, then the LSDA's length.
        unsafe {
            let len = u32::from_le_bytes(core::slice::from_raw_parts(data.add(8), 4).try_into().ok()?);
            PeHandlerData::parse(core::slice::from_raw_parts(data, 12 + len as usize))
        }
    }
}

/// `Header::magic`.
pub const MAGIC: [u8; 8] = *b"RYOIMAGE";

/// Symbol flag: the slot holds the address of an import slot (`__imp_<sym>`, PE), and the
/// real address is loaded through it.
pub const SYM_INDIRECT: u8 = 1;

/// Function flag: `#[inline(always)]` (or `#[rustc_force_inline]`).
pub const FUNC_INLINE_ALWAYS: u8 = 1;
/// Function flag: `#[inline(never)]`.
pub const FUNC_INLINE_NEVER: u8 = 2;
/// Function flag: `#[cold]`.
pub const FUNC_COLD: u8 = 4;
/// Function flag: `#[inline]`.
pub const FUNC_INLINE_HINT: u8 = 8;
/// Every defined function flag bit.
pub const FUNC_FLAGS: u8 = FUNC_INLINE_ALWAYS | FUNC_INLINE_NEVER | FUNC_COLD | FUNC_INLINE_HINT;

/// `CleanupEntry::target` of a call whose unwinding continues in the caller (in the
/// writer's function definitions; images carry LSDAs instead).
pub const CONTINUE: u32 = u32::MAX;

/// Set in `CleanupEntry::target` (with a landing pad) when the landing pad catches every
/// exception instead of being a cleanup: a `Terminate` action, whose pad must be found by
/// the unwinder's search phase even if nothing up the stack catches the panic.
pub const CATCH: u32 = 1 << 31;

/// `Header::mode` bits: the fields of [`Mode`].
pub const MODE_FP_ARG: u32 = 1;
pub const MODE_FRAME_POINTER: u32 = 2;
pub const MODE_ALIGN_LOOPS: u32 = 4;
pub const MODE_PE: u32 = 8;
pub const MODE_COUNTERS: u32 = 16;
/// Every defined `Header::mode` bit.
pub const MODE_ALL: u32 = MODE_FP_ARG | MODE_FRAME_POINTER | MODE_ALIGN_LOOPS | MODE_PE | MODE_COUNTERS;

impl Mode {
    /// `Header::mode` of the mode. [`Mode::far_rt`] has no bit: it is never an image's.
    pub const fn to_header_bits(self) -> u32 {
        (self.fp_arg as u32) * MODE_FP_ARG
            | (self.frame_pointer as u32) * MODE_FRAME_POINTER
            | (self.align_loops as u32) * MODE_ALIGN_LOOPS
            | (self.pe as u32) * MODE_PE
            | (self.counters as u32) * MODE_COUNTERS
    }

    /// The mode a `Header::mode` says, `None` if it has unknown bits or isn't
    /// [`valid`](Mode::valid).
    pub const fn from_header_bits(m: u32) -> Option<Mode> {
        let mode = Mode {
            fp_arg: m & MODE_FP_ARG != 0,
            frame_pointer: m & MODE_FRAME_POINTER != 0,
            align_loops: m & MODE_ALIGN_LOOPS != 0,
            pe: m & MODE_PE != 0,
            counters: m & MODE_COUNTERS != 0,
            far_rt: false,
        };
        if m & !MODE_ALL != 0 || !mode.valid() { None } else { Some(mode) }
    }
}

/// A function's JIT record, in the writable section ([`Header::jit_records`], one per
/// function in function order): its two counters, which the code's counter checks count up
/// ([`Mode::counters`]), the slots their stubs call through, and the JIT's state. One cache
/// line each, so that the counters of hot functions don't share one.
///
/// The writer sets `ctr_e` to `-`[`JIT_ENTRY_THRESHOLD`], `ctr_l` to `-`[`JIT_THRESHOLD`],
/// `entry` and `osr` to the runtime's `ryo_jit_trip_entry` and `ryo_jit_trip_osr`, `func`
/// to the function's index and `header` to the image's header (relocated), the rest to 0.
/// The runtime's JIT (`ryo_rt`, design/jit.md) owns the record after that.
///
/// **Counters.** Each counter is the count of its events (calls, loop iterations) less its
/// threshold, plus a bias the runtime moves with the record's state: none while it is
/// [`JIT_COLD`], `-`[`JIT_BIAS`] while it is [`JIT_QUEUED`] or [`JIT_FAILED`] (so no check
/// trips again), and `+`[`JIT_BIAS`] once it is [`JIT_DONE`] (so every check takes its stub
/// into the JIT code). The count is therefore readable from the value alone
/// ([`jit_count`]).
#[repr(C, align(64))]
#[derive(Debug)]
pub struct JitRecord {
    /// The call counter: the entry's check increments it and takes the stub once it isn't
    /// negative. Racy and lossy across threads, by design.
    pub ctr_e: i64,
    /// What the entry's stub calls ([`JIT_ENTRY_SLOT`]), with `r11` the record and the
    /// return address the continuation after the check, before the prologue.
    pub entry: *const u8,
    /// What a loop head's stub calls ([`JIT_OSR_SLOT`]), with `r11` the record, `eax` the
    /// head's index and the return address the continuation after the head's check.
    pub osr: *const u8,
    /// The JIT queue's link.
    pub next: *mut JitRecord,
    /// [`JIT_COLD`], [`JIT_QUEUED`], [`JIT_DONE`] or [`JIT_FAILED`].
    pub state: core::sync::atomic::AtomicU32,
    /// The function's index in the image.
    pub func: u32,
    /// The image's header.
    pub header: *const Header,
    /// The runtime's: where the JIT put the function's code once it is [`JIT_DONE`] (its
    /// first instruction). 0 in the image.
    pub jit_code: *const u8,
    /// The loop counter ([`JIT_LOOP_CTR`]): every loop head's check increments it, as the
    /// entry's does `ctr_e`.
    pub ctr_l: i64,
}

// The record's fields the trips, the JIT thread and the counter checks share; the checks read
// and write them with plain instructions: atomics of their size. Records live in images'
// writable sections forever, so each view is `'static`.
impl JitRecord {
    /// The record of function `func` as the writer stores it, before relocation (see
    /// [`JitRecord`]): the counters at their thresholds, `func` set, the rest 0.
    pub const fn image_bytes(func: u32) -> [u8; 64] {
        const fn put<const N: usize>(r: &mut [u8; 64], at: usize, v: [u8; N]) {
            let mut i = 0;
            while i < N {
                r[at + i] = v[i];
                i += 1;
            }
        }
        let mut r = [0u8; 64];
        put(&mut r, mem::offset_of!(JitRecord, ctr_e), (-JIT_ENTRY_THRESHOLD).to_le_bytes());
        put(&mut r, mem::offset_of!(JitRecord, ctr_l), (-JIT_THRESHOLD).to_le_bytes());
        put(&mut r, mem::offset_of!(JitRecord, func), func.to_le_bytes());
        r
    }

    pub fn ctr_e(r: *mut Self) -> &'static core::sync::atomic::AtomicI64 {
        // SAFETY: records live forever; the counters are 8-aligned.
        unsafe { core::sync::atomic::AtomicI64::from_ptr(&raw mut (*r).ctr_e) }
    }
    pub fn ctr_l(r: *mut Self) -> &'static core::sync::atomic::AtomicI64 {
        // SAFETY: as for `ctr_e`.
        unsafe { core::sync::atomic::AtomicI64::from_ptr(&raw mut (*r).ctr_l) }
    }
    pub fn entry_slot(r: *mut Self) -> &'static core::sync::atomic::AtomicPtr<u8> {
        // SAFETY: as for `ctr_e`.
        unsafe { core::sync::atomic::AtomicPtr::from_ptr((&raw mut (*r).entry).cast::<*mut u8>()) }
    }
    pub fn osr_slot(r: *mut Self) -> &'static core::sync::atomic::AtomicPtr<u8> {
        // SAFETY: as for `ctr_e`.
        unsafe { core::sync::atomic::AtomicPtr::from_ptr((&raw mut (*r).osr).cast::<*mut u8>()) }
    }
    pub fn state(r: *mut Self) -> &'static core::sync::atomic::AtomicU32 {
        // SAFETY: as for `ctr_e`.
        unsafe { &(*r).state }
    }

    /// Moves both counters of `r` to the bias of its state ([`jit_settle`]), keeping their
    /// counts.
    pub fn settle(r: *mut Self) {
        for c in [Self::ctr_e(r), Self::ctr_l(r)] {
            jit_settle(c, || Self::state(r).load(core::sync::atomic::Ordering::SeqCst));
        }
    }

    /// Leaves `r` in AOT code for good: [`JIT_FAILED`], then its counters' bias.
    pub fn fail(r: *mut Self) {
        Self::state(r).store(JIT_FAILED, core::sync::atomic::Ordering::SeqCst);
        Self::settle(r);
    }

    /// Publishes `r`'s JIT code (design/jit.md, "Publishing"): the code's start, the entry
    /// its stub calls, the OSR dispatcher if any, the state [`JIT_DONE`], then the counters'
    /// bias that takes every check's stub.
    ///
    /// # Safety
    /// The caller is the JIT thread that owns `r` (it is [`JIT_QUEUED`]).
    pub unsafe fn publish(r: *mut Self, code: *const u8, entry: *mut u8, osr: Option<*mut u8>) {
        use core::sync::atomic::Ordering::{Release, SeqCst};
        // SAFETY: the record is the caller's to write until `Done`.
        unsafe { (*r).jit_code = code };
        Self::entry_slot(r).store(entry, Release);
        if let Some(osr) = osr {
            Self::osr_slot(r).store(osr, Release);
        }
        Self::state(r).store(JIT_DONE, SeqCst);
        Self::settle(r);
    }
}

/// The loop counter a JIT record starts at, negated ([`JitRecord::ctr_l`]): 10 000 loop
/// iterations.
pub const JIT_THRESHOLD: i64 = 10_000;
/// The call counter a JIT record starts at, negated ([`JitRecord::ctr_e`]): 625 calls.
pub const JIT_ENTRY_THRESHOLD: i64 = JIT_THRESHOLD / 16;
/// The bias of a queued or failed record's counters (negative) and of a compiled one's
/// (positive): 2^62.
pub const JIT_BIAS: i64 = 1 << 62;
/// The offsets of [`JitRecord::entry`] and [`JitRecord::osr`], which the counter stubs call
/// through (`call [r11 + slot]`).
pub const JIT_ENTRY_SLOT: u8 = 8;
pub const JIT_OSR_SLOT: u8 = 16;
/// The offset of [`JitRecord::ctr_l`].
pub const JIT_LOOP_CTR: u8 = 56;
/// [`JitRecord::state`]s.
pub const JIT_COLD: u32 = 0;
pub const JIT_QUEUED: u32 = 1;
pub const JIT_DONE: u32 = 2;
pub const JIT_FAILED: u32 = 3;

/// The count of events a counter of a JIT record with threshold `threshold` holds as
/// `value`, whatever its bias ([`JitRecord`]). Exact unless counts went past 2^61.
pub const fn jit_count(value: i64, threshold: i64) -> i64 {
    jit_unbiased(value) + threshold
}

/// `value` without its bias: the count less the threshold.
pub const fn jit_unbiased(value: i64) -> i64 {
    if value < -JIT_BIAS / 2 {
        value.wrapping_add(JIT_BIAS)
    } else if value > JIT_BIAS / 2 {
        value.wrapping_sub(JIT_BIAS)
    } else {
        value
    }
}

/// The bias of a record's counters in state `state`.
pub const fn jit_bias(state: u32) -> i64 {
    match state {
        JIT_QUEUED | JIT_FAILED => -JIT_BIAS,
        JIT_DONE => JIT_BIAS,
        _ => 0,
    }
}

/// Moves a counter of a record to the bias of the record's state, `state()` (read again
/// after the change: another thread changing the state settles the counter too, after the
/// change, so that whichever is last leaves the final state's bias), keeping its count.
pub fn jit_settle(c: &core::sync::atomic::AtomicI64, state: impl Fn() -> u32) {
    use core::sync::atomic::Ordering::{Relaxed, SeqCst};
    loop {
        let st = state();
        let v = c.load(SeqCst);
        let want = jit_unbiased(v).wrapping_add(jit_bias(st));
        if v == want {
            return;
        }
        // An AOT increment racing the exchange makes it fail; one racing it the other way
        // erases the bias, as with any write (the JIT thread re-checks compiled records).
        if c.compare_exchange(v, want, SeqCst, Relaxed).is_ok() && state() == st {
            return;
        }
    }
}

const _: () = {
    assert!(mem::size_of::<JitRecord>() == 64);
    assert!(mem::offset_of!(JitRecord, entry) == JIT_ENTRY_SLOT as usize);
    assert!(mem::offset_of!(JitRecord, osr) == JIT_OSR_SLOT as usize);
    assert!(mem::offset_of!(JitRecord, func) == 36);
    assert!(mem::offset_of!(JitRecord, header) == 40);
    assert!(mem::offset_of!(JitRecord, ctr_l) == JIT_LOOP_CTR as usize);
};

/// The 32-bit crate hash the registry uses, folded from the crate's
/// `StableCrateId` (its `u64` value).
pub const fn crate_hash(stable_crate_id: u64) -> u32 {
    (stable_crate_id ^ (stable_crate_id >> 32)) as u32
}

/// The 64-bit hash of a codegen unit name (FNV-1a) the image header and symbol carry. CGU
/// names are stable across sessions, so is the hash.
pub const fn cgu_hash(name: &[u8]) -> u64 {
    let mut h: u64 = 0xcbf2_9ce4_8422_2325;
    let mut i = 0;
    while i < name.len() {
        h ^= name[i] as u64;
        h = h.wrapping_mul(0x0000_0100_0000_01b3);
        i += 1;
    }
    h
}

/// A byte range within the read-only section: offset and element count.
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct Span {
    pub off: u32,
    pub count: u32,
}

/// The image header, at the start of the read-only section.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Header {
    pub magic: [u8; 8],
    /// [`crate_hash`] of `stable_crate_id`.
    pub crate_hash: u32,
    /// Size of the read-only section in bytes.
    pub size: u32,
    pub stable_crate_id: u64,
    /// Address of the writable section (relocated; 0 in the unlinked bytes).
    pub data: u64,
    /// Size of the writable section in bytes.
    pub data_size: u32,
    /// Size of the text section in bytes.
    pub text_size: u32,
    /// Address of the text section (relocated; 0 in the unlinked bytes).
    pub text: u64,
    /// `[FuncEntry]`.
    pub functions: Span,
    /// The code constants (bytes).
    pub code_consts: Span,
    /// `[FixupEntry]`.
    pub fixups: Span,
    /// `[u8]` symbol flags (same count as `symbols`).
    pub sym_flags: Span,
    /// `[u8]` function flags (same count as `functions`; [`FUNC_INLINE_ALWAYS`] etc.).
    pub func_flags: Span,
    /// `[u64]` symbol slots.
    pub symbols: Span,
    /// Constant pool bytes.
    pub consts: Span,
    /// The functions' instruction lists (bytes).
    pub lists: Span,
    /// `[CallSiteEntry]`.
    pub call_sites: Span,
    /// Number of site cache slots at the start of the writable section.
    pub site_count: u32,
    /// Byte offset of the fixup area in the writable section (after the site cache).
    pub fixup_area: u32,
    /// The [`Mode`] the code was encoded in ([`Mode::to_header_bits`]).
    pub mode: u32,
    /// The [`JitRecord`]s: their byte offset in the writable section (64-aligned) and count
    /// (the function count with [`Mode::counters`], else 0).
    pub jit_records: Span,
    /// `[u32]`, strictly increasing: the offset in the constant pool of every 8-byte field
    /// the linker relocates (a pointer to a symbol, the pool or the data area). The JIT reads
    /// it to tell pointer fields from integers when it folds loads from the pool.
    pub const_relocs: Span,
    /// Identifies the image among its crate's: a hash of rustc's codegen unit name
    /// ([`cgu_hash`]). The registry rejects two images with the same crate and CGU hashes.
    pub cgu_hash: u64,
}

/// A function table entry.
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct FuncEntry {
    /// Byte offset of the machine code in the text section.
    pub code_off: u32,
    /// Length in bytes.
    pub code_len: u32,
    /// Size of the stack argument area. Like `ret_size` and `ret_kind`, nothing at run time
    /// reads it (VM functions are called natively): the Lean image checks
    /// (`lean/Ryo/Check/Image/Funcs.lean`) check the code against these signature fields.
    pub arg_size: u32,
    /// Size of the return value.
    pub ret_size: u32,
    /// How the function returns its value ([`crate::asm::RET_SRET`], exact sizes): how
    /// a caller collects it.
    pub ret_kind: u32,
    /// The function's instruction list ([`crate::asm::list`]: branch targets, scopes,
    /// dropped stores and the inline sequences the register cache emitted non-plainly): a
    /// run of the instruction list bytes.
    pub list: Span,
    /// The function's call sites: a run of the call-site table (`off` is an index), sorted
    /// by position.
    pub call_sites: Span,
}

/// A call-site table entry: a call-like instruction's range and what unwinding out of it
/// does (`asm::CallSite`, the same as the LSDA's records).
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct CallSiteEntry {
    /// Byte offset in the function's code.
    pub start: u32,
    /// Length in bytes.
    pub len: u32,
    /// Byte offset of the landing pad in the function's code, with [`CATCH`] for a
    /// catch-all one, or [`CONTINUE`].
    pub pad: u32,
}

impl CallSiteEntry {
    /// The landing pad's byte offset and whether it catches, or `Continue`.
    pub fn action(&self) -> Cleanup {
        Cleanup::from_word(self.pad)
    }
}

/// A cleanup table entry: unwinding out of the call-like instruction at `offset` goes to
/// `target`.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct CleanupEntry {
    /// Word offset of the call-like instruction, from the function start.
    pub offset: u32,
    /// Word offset of its landing pad (an `lpad` instruction), with [`CATCH`] for a
    /// catch-all one, or [`CONTINUE`].
    pub target: u32,
}

/// What unwinding out of a call-like instruction does.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cleanup {
    /// Enter the landing pad at this word offset in the function, catching the exception if
    /// `catch`.
    Pad(u32, bool),
    /// Leave the frame, and continue in the caller.
    Continue,
}

impl CleanupEntry {
    pub fn action(&self) -> Cleanup {
        Cleanup::from_word(self.target)
    }
}

impl Cleanup {
    /// The landing pad `pad` (catching if `catch`), or `Continue` if there is none.
    pub const fn new(pad: Option<u32>, catch: bool) -> Cleanup {
        match pad {
            Some(p) => Cleanup::Pad(p, catch),
            None => Cleanup::Continue,
        }
    }

    /// The action a packed pad word says ([`CleanupEntry::target`], [`CallSiteEntry::pad`]):
    /// [`CONTINUE`], or the pad's offset with [`CATCH`] for a catch-all one.
    pub const fn from_word(w: u32) -> Cleanup {
        if w == CONTINUE { Cleanup::Continue } else { Cleanup::Pad(w & !CATCH, w & CATCH != 0) }
    }

    /// The packed pad word of the action ([`Cleanup::from_word`]).
    pub const fn to_word(self) -> u32 {
        match self {
            Cleanup::Pad(p, catch) => p | if catch { CATCH } else { 0 },
            Cleanup::Continue => CONTINUE,
        }
    }
}

/// A PE fixup: at registration, `*(data + offset) = *syms[sym] + addend`. The symbol slot
/// is indirect: it holds the address of the import slot, which holds the real address.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FixupEntry {
    /// Byte offset in the writable section (8-aligned).
    pub offset: u32,
    pub sym: u32,
    pub addend: i64,
}

/// Why an image was rejected.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ImageError {
    /// The bytes are shorter than the header or `Header::size`.
    Truncated,
    /// The image or one of its parts is misaligned.
    Misaligned,
    BadMagic,
    /// A part lies outside the read-only section.
    OutOfBounds(&'static str),
    /// The function table isn't sorted, or a function's code is out of range.
    BadFunction(u32),
    /// A fixup is out of range of the writable section or the symbol table.
    BadFixup(u32),
    /// A symbol flag byte has unknown bits.
    BadSymbolFlags(u32),
    /// A function flag byte (function index) has unknown bits.
    BadFuncFlags(u32),
    /// `Header::mode` has unknown bits or a combination the encoder doesn't support.
    BadMode,
    /// A function's instruction list (function index) is malformed.
    BadList(u32),
    /// A call-site table entry (index) is out of range of its function or overlaps the one
    /// before.
    BadCallSite(u32),
    /// The writable section layout is inconsistent.
    BadData,
    /// A constant relocation (index) is out of the pool, misaligned or out of order.
    BadConstReloc(u32),
}

impl fmt::Display for ImageError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

/// What a read of the constant pool gives ([`Image::read_pool`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum PoolRead {
    /// Plain bytes, zero-extended.
    Bits(u64),
    /// A pointer field into the image's pool, at this offset.
    Const(u32),
    /// A pointer field into the image's data area, at this offset from the fixup area.
    Data(u32),
}

/// A zero-copy view of an image's read-only section.
#[derive(Clone, Copy)]
pub struct Image<'a> {
    bytes: &'a [u8],
    header: &'a Header,
    /// `header.mode`, decoded.
    mode: Mode,
}

/// Casts `count` elements of `T` at byte offset `span.off`. `T` must be a plain-data type
/// (any bit pattern valid).
fn cast<'a, T>(bytes: &'a [u8], span: Span, what: &'static str) -> Result<&'a [T], ImageError> {
    let len = (span.count as usize).checked_mul(mem::size_of::<T>()).ok_or(ImageError::OutOfBounds(what))?;
    let b = bytes.get(span.off as usize..).and_then(|b| b.get(..len)).ok_or(ImageError::OutOfBounds(what))?;
    if b.as_ptr() as usize % mem::align_of::<T>() != 0 {
        return Err(ImageError::Misaligned);
    }
    // SAFETY: in bounds and aligned; T is plain data.
    Ok(unsafe { slice::from_raw_parts(b.as_ptr().cast::<T>(), span.count as usize) })
}

impl<'a> Image<'a> {
    /// Views `bytes` (the whole read-only section, 8-aligned) as an image. Checks the header
    /// and that every part is in bounds and aligned.
    pub fn parse(bytes: &'a [u8]) -> Result<Self, ImageError> {
        if bytes.len() < mem::size_of::<Header>() {
            return Err(ImageError::Truncated);
        }
        if bytes.as_ptr() as usize % 8 != 0 {
            return Err(ImageError::Misaligned);
        }
        // SAFETY: in bounds, aligned, plain data.
        let header = unsafe { &*bytes.as_ptr().cast::<Header>() };
        if header.magic != MAGIC {
            return Err(ImageError::BadMagic);
        }
        if (header.size as usize) > bytes.len() {
            return Err(ImageError::Truncated);
        }
        let bytes = &bytes[..header.size as usize];
        let mode = Mode::from_header_bits(header.mode).ok_or(ImageError::BadMode)?;
        let img = Image { bytes, header, mode };
        cast::<FuncEntry>(bytes, header.functions, "functions")?;
        cast::<u8>(bytes, header.code_consts, "code constants")?;
        cast::<FixupEntry>(bytes, header.fixups, "fixups")?;
        cast::<u8>(bytes, header.sym_flags, "symbol flags")?;
        cast::<u8>(bytes, header.func_flags, "function flags")?;
        cast::<u64>(bytes, header.symbols, "symbols")?;
        cast::<u8>(bytes, header.consts, "constants")?;
        cast::<u8>(bytes, header.lists, "instruction lists")?;
        cast::<CallSiteEntry>(bytes, header.call_sites, "call sites")?;
        cast::<u32>(bytes, header.const_relocs, "constant relocations")?;
        if header.sym_flags.count != header.symbols.count {
            return Err(ImageError::OutOfBounds("symbol flags"));
        }
        if header.func_flags.count != header.functions.count {
            return Err(ImageError::OutOfBounds("function flags"));
        }
        let sites_end = header.site_count as u64 * 8;
        if sites_end > header.fixup_area as u64 || header.fixup_area > header.data_size {
            return Err(ImageError::BadData);
        }
        let r = header.jit_records;
        let records = if img.mode().counters { header.functions.count } else { 0 };
        if r.count != records || r.off % 64 != 0 || r.off as u64 + 64 * r.count as u64 > header.data_size as u64 {
            return Err(ImageError::BadData);
        }
        Ok(img)
    }

    /// Views the image whose header is at `header`.
    ///
    /// # Safety
    /// `header` must point at a linked image's read-only section, valid for `'a` and for its
    /// `Header::size` bytes.
    pub unsafe fn from_header(header: *const u8) -> Result<Self, ImageError> {
        if header as usize % 8 != 0 {
            return Err(ImageError::Misaligned);
        }
        // SAFETY: caller guarantees a readable header.
        let size = unsafe { (*header.cast::<Header>()).size } as usize;
        if size < mem::size_of::<Header>() {
            return Err(ImageError::Truncated);
        }
        // SAFETY: caller guarantees `size` readable bytes.
        Self::parse(unsafe { slice::from_raw_parts(header, size) })
    }

    /// Full consistency check of the function table (with each function's scopes and call
    /// sites), fixups, symbol and function flags.
    pub fn validate(&self) -> Result<(), ImageError> {
        let text = self.header.text_size as u64;
        let mut prev_end = 0u64;
        for (i, f) in self.functions().iter().enumerate() {
            let i = i as u32;
            let end = f.code_off as u64 + f.code_len as u64;
            if (f.code_off as u64) < prev_end || end > text {
                return Err(ImageError::BadFunction(i));
            }
            prev_end = end;
            let run = |s: Span, n: u32| s.off as u64 + s.count as u64 <= n as u64;
            if !run(f.list, self.header.lists.count) || !run(f.call_sites, self.header.call_sites.count) {
                return Err(ImageError::BadFunction(i));
            }
            if crate::asm::list::walk(self.list(i), f.code_len, |_, _| {}).is_none() {
                return Err(ImageError::BadList(i));
            }
            let mut prev = 0u64;
            for (j, c) in self.call_sites(i).iter().enumerate() {
                let pad_ok = match c.action() {
                    Cleanup::Pad(p, _) => p < f.code_len,
                    Cleanup::Continue => true,
                };
                let end = c.start as u64 + c.len as u64;
                let sorted = c.start as u64 >= prev;
                prev = end;
                if !sorted || end > f.code_len as u64 || !pad_ok {
                    return Err(ImageError::BadCallSite(f.call_sites.off + j as u32));
                }
            }
        }
        for (i, x) in self.fixups().iter().enumerate() {
            if x.sym >= self.header.symbols.count
                || x.offset % 8 != 0
                || x.offset < self.header.fixup_area
                || x.offset as u64 + 8 > self.header.data_size as u64
            {
                return Err(ImageError::BadFixup(i as u32));
            }
        }
        for (i, &fl) in self.symbol_flags().iter().enumerate() {
            if fl & !SYM_INDIRECT != 0 {
                return Err(ImageError::BadSymbolFlags(i as u32));
            }
        }
        for (i, &fl) in self.func_flags().iter().enumerate() {
            if fl & !FUNC_FLAGS != 0 {
                return Err(ImageError::BadFuncFlags(i as u32));
            }
        }
        // Each field 8-aligned in the section, inside the pool, after the one before.
        let mut next = 0u64;
        for (i, &o) in self.const_relocs().iter().enumerate() {
            let at = self.header.consts.off as u64 + o as u64;
            if (o as u64) < next || at % 8 != 0 || o as u64 + 8 > self.header.consts.count as u64 {
                return Err(ImageError::BadConstReloc(i as u32));
            }
            next = o as u64 + 8;
        }
        Ok(())
    }

    pub fn header(&self) -> &'a Header {
        self.header
    }

    /// The read-only section's bytes.
    pub fn bytes(&self) -> &'a [u8] {
        self.bytes
    }

    pub fn crate_hash(&self) -> u32 {
        self.header.crate_hash
    }

    // The parts were checked by `parse`, so these casts can't fail. No panic either way: the
    // VM runtime reads images, and must not reach core's panic path (whose handler may be VM
    // code under `--sysroot ryo`, design/vm.md).
    fn part<T>(&self, span: Span) -> &'a [T] {
        cast(self.bytes, span, "").unwrap_or(&[])
    }

    /// The function table, sorted by code offset.
    pub fn functions(&self) -> &'a [FuncEntry] {
        self.part(self.header.functions)
    }

    /// The [`Mode`] the code was encoded in.
    pub fn mode(&self) -> Mode {
        self.mode
    }

    /// The run of `entries` of `table` that `run` (an index range) names, empty if out of
    /// range (only [`Self::validate`] checks the runs).
    fn run<T>(&self, table: Span, run: Span) -> &'a [T] {
        let all = self.part::<T>(table);
        all.get(run.off as usize..).and_then(|s| s.get(..run.count as usize)).unwrap_or(&[])
    }

    /// Function `func`'s instruction list bytes ([`crate::asm::list`]; empty for an unknown
    /// function).
    pub fn list(&self, func: u32) -> &'a [u8] {
        let Some(f) = self.functions().get(func as usize) else { return &[] };
        self.run(self.header.lists, f.list)
    }

    /// Function `func`'s call sites, sorted by position (empty for an unknown function).
    pub fn call_sites(&self, func: u32) -> &'a [CallSiteEntry] {
        let Some(f) = self.functions().get(func as usize) else { return &[] };
        self.run(self.header.call_sites, f.call_sites)
    }

    /// The text section (from the relocated header field; null before linking).
    pub fn text_ptr(&self) -> *const u8 {
        self.header.text as usize as *const u8
    }

    /// The code constants.
    pub fn code_consts(&self) -> &'a [u8] {
        self.part(self.header.code_consts)
    }

    /// The function whose code contains text byte `off`, and the offset within it.
    pub fn function_at(&self, off: u32) -> Option<(u32, u32)> {
        let fs = self.functions();
        let i = fs.partition_point(|f| f.code_off <= off).checked_sub(1)?;
        let f = fs.get(i)?;
        (off.wrapping_sub(f.code_off) < f.code_len).then_some((i as u32, off - f.code_off))
    }

    pub fn fixups(&self) -> &'a [FixupEntry] {
        self.part(self.header.fixups)
    }

    pub fn symbol_flags(&self) -> &'a [u8] {
        self.part(self.header.sym_flags)
    }

    /// One flag byte per function ([`FUNC_INLINE_ALWAYS`] etc.).
    pub fn func_flags(&self) -> &'a [u8] {
        self.part(self.header.func_flags)
    }

    /// The symbol slots, as a raw pointer (what the VM keeps as `syms`).
    pub fn symbols_ptr(&self) -> *const *const () {
        self.part::<u64>(self.header.symbols).as_ptr().cast()
    }

    /// The symbol slot values (addresses after linking).
    pub fn symbols(&self) -> &'a [u64] {
        self.part(self.header.symbols)
    }

    /// The constant pool (what the VM keeps as `consts`).
    pub fn consts(&self) -> &'a [u8] {
        self.part(self.header.consts)
    }

    /// The pool offsets of the relocated fields in the constant pool, sorted.
    pub fn const_relocs(&self) -> &'a [u32] {
        self.part(self.header.const_relocs)
    }

    /// Whether the 8-byte field at pool offset `off` is relocated, and else whether any
    /// relocated field overlaps `[off, off + len)`: `Some(true)` for exactly a field,
    /// `Some(false)` for no overlap, `None` for a partial one.
    pub fn const_reloc_at(&self, off: u32, len: u32) -> Option<bool> {
        let rs = self.const_relocs();
        // The first field that ends after `off`.
        let i = rs.partition_point(|&r| r as u64 + 8 <= off as u64);
        match rs.get(i) {
            Some(&r) if (r as u64) < off as u64 + len as u64 => (r == off && len == 8).then_some(true),
            _ => Some(false),
        }
    }

    /// The `w` (1 to 8) bytes at pool offset `off`, little-endian, as the JIT folds a load
    /// of them: `None` if they aren't all in the pool or read a relocated field partly. A
    /// relocated field read whole is classified by its linked value: into this image's pool
    /// or data area (one past the end included), or anything else (a function, a native
    /// symbol: plain bits).
    pub fn read_pool(&self, off: u64, w: u8) -> Option<PoolRead> {
        let b = self.consts().get(usize::try_from(off).ok()?..)?.get(..w as usize)?;
        let mut v = [0u8; 8];
        v.get_mut(..b.len())?.copy_from_slice(b);
        let v = u64::from_le_bytes(v);
        if !self.const_reloc_at(off as u32, w as u32)? {
            return Some(PoolRead::Bits(v));
        }
        let h = self.header;
        let pool = (self.consts().as_ptr() as u64, h.consts.count as u64);
        let data_end = if h.jit_records.count != 0 { h.jit_records.off } else { h.data_size };
        let data = (h.data.wrapping_add(h.fixup_area as u64), data_end.saturating_sub(h.fixup_area) as u64);
        let within = |r: (u64, u64), end: bool| v.checked_sub(r.0).filter(|&o| o < r.1 + end as u64).map(|o| o as u32);
        Some(if let Some(o) = within(pool, false) {
            PoolRead::Const(o)
        } else if let Some(o) = within(data, false) {
            PoolRead::Data(o)
        } else if let Some(o) = within(pool, true) {
            PoolRead::Const(o)
        } else if let Some(o) = within(data, true) {
            PoolRead::Data(o)
        } else {
            PoolRead::Bits(v)
        })
    }

    /// The writable section (from the relocated header field; null before linking).
    pub fn data_ptr(&self) -> *mut u8 {
        self.header.data as usize as *mut u8
    }

    /// The site cache: `site_count` pointer-sized slots at the start of the writable section.
    pub fn site_cache(&self) -> *mut *const () {
        self.data_ptr().cast()
    }

    /// The JIT records, one per function ([`Header::jit_records`]; empty without counters).
    pub fn jit_records(&self) -> *mut JitRecord {
        self.data_ptr().wrapping_add(self.header.jit_records.off as usize).cast()
    }

    /// The fixup area, base of [`Data`](crate::full::Data) offsets.
    pub fn fixup_area(&self) -> *mut u8 {
        self.data_ptr().wrapping_add(self.header.fixup_area as usize)
    }

    /// Applies the PE fixups.
    ///
    /// # Safety
    /// [`Self::validate`] must have succeeded on this image (it checks the fixup offsets and
    /// symbol indices). The image must be linked, its writable section writable and not in
    /// use by other threads, and every fixup's symbol slot must point at a readable import
    /// slot.
    pub unsafe fn apply_fixups(&self) {
        let syms = self.symbols();
        for x in self.fixups() {
            // `validate` checked the index; no panic on the runtime's path (see `part`).
            let Some(&slot) = syms.get(x.sym as usize) else { continue };
            // SAFETY: per the caller; `validate` checked the offsets.
            unsafe {
                let target = *(slot as usize as *const u64);
                let at = self.data_ptr().add(x.offset as usize).cast::<u64>();
                at.write(target.wrapping_add(x.addend as u64));
            }
        }
    }
}

impl fmt::Debug for Image<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("Image").field("header", self.header).finish()
    }
}
