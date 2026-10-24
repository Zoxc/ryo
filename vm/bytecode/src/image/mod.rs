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
//! | scopes | `[ScopeEntry]`, each function's in a run ([`FuncEntry::scopes`]) |
//! | call sites | `[CallSiteEntry]`, each function's in a run ([`FuncEntry::call_sites`]) |
//! | dropped stores | `[DroppedEntry]`, each function's in a run ([`FuncEntry::dropped`]) |
//! | code constants | what the machine code refers to: island operand arrays, switch values |
//! | fixups | `[FixupEntry]` (PE only, otherwise empty) |
//! | symbol flags | `[u8]`, one per symbol ([`SYM_INDIRECT`]) |
//! | symbols | `[u64]`: one pointer slot per symbol, filled by the linker |
//! | constants | the constant pool, aligned to its most aligned allocation |
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

use core::{fmt, mem, slice};

use crate::asm::Mode;

/// `Header::magic`.
pub const MAGIC: [u8; 8] = *b"RYOIMAGE";

/// Symbol flag: the slot holds the address of an import slot (`__imp_<sym>`, PE), and the
/// real address is loaded through it.
pub const SYM_INDIRECT: u8 = 1;

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

/// `Header::mode` of `mode`.
pub const fn mode_bits(mode: Mode) -> u32 {
    (mode.fp_arg as u32) * MODE_FP_ARG
        | (mode.frame_pointer as u32) * MODE_FRAME_POINTER
        | (mode.align_loops as u32) * MODE_ALIGN_LOOPS
        | (mode.pe as u32) * MODE_PE
        | (mode.counters as u32) * MODE_COUNTERS
}

/// A function's JIT record, in the writable section ([`Header::jit_records`], one per
/// function in function order): its counter, which the code's counter checks count down
/// ([`Mode::counters`]), the slots their stubs call through, and the JIT's state. One cache
/// line each, so that the counters of hot functions don't share one.
///
/// The writer sets `ctr` to [`JIT_THRESHOLD`], `entry` and `osr` to the runtime's
/// `ryo_jit_trip_entry` and `ryo_jit_trip_osr`, `func` to the function's index and `header`
/// to the image's header (relocated), the rest to 0.
/// The runtime's JIT (`ryo_rt`, design/jit.md) owns the record after that.
#[repr(C, align(64))]
#[derive(Debug)]
pub struct JitRecord {
    /// Counts down: a call subtracts [`crate::asm::ENTRY_COUNT`], a loop iteration 1, and
    /// a negative result takes the stub. Racy and lossy across threads, by design.
    pub ctr: i64,
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
    /// first instruction), and its length. 0 in the image.
    pub jit_code: *const u8,
    pub jit_len: u64,
}

/// The counter a JIT record starts at ([`JitRecord::ctr`]): about 600 calls or 10 000 loop
/// iterations.
pub const JIT_THRESHOLD: i64 = 10_000;
/// The offsets of [`JitRecord::entry`] and [`JitRecord::osr`], which the counter stubs call
/// through (`call [r11 + slot]`).
pub const JIT_ENTRY_SLOT: u8 = 8;
pub const JIT_OSR_SLOT: u8 = 16;
/// [`JitRecord::state`]s.
pub const JIT_COLD: u32 = 0;
pub const JIT_QUEUED: u32 = 1;
pub const JIT_DONE: u32 = 2;
pub const JIT_FAILED: u32 = 3;

const _: () = {
    assert!(mem::size_of::<JitRecord>() == 64);
    assert!(mem::offset_of!(JitRecord, entry) == JIT_ENTRY_SLOT as usize);
    assert!(mem::offset_of!(JitRecord, osr) == JIT_OSR_SLOT as usize);
    assert!(mem::offset_of!(JitRecord, func) == 36);
    assert!(mem::offset_of!(JitRecord, header) == 40);
};

/// The 32-bit crate hash the registry uses, folded from the crate's
/// `StableCrateId` (its `u64` value).
pub const fn crate_hash(stable_crate_id: u64) -> u32 {
    (stable_crate_id ^ (stable_crate_id >> 32)) as u32
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
    /// [`FORMAT_VERSION`](crate::FORMAT_VERSION).
    pub version: u32,
    /// [`crate_hash`] of `stable_crate_id`.
    pub crate_hash: u32,
    pub stable_crate_id: u64,
    /// Address of the writable section (relocated; 0 in the unlinked bytes).
    pub data: u64,
    /// Size of the read-only section in bytes.
    pub size: u32,
    /// Size of the writable section in bytes.
    pub data_size: u32,
    /// `[FuncEntry]`.
    pub functions: Span,
    /// Address of the text section (relocated; 0 in the unlinked bytes).
    pub text: u64,
    /// Size of the text section in bytes.
    pub text_size: u32,
    /// The code constants (bytes).
    pub code_consts: Span,
    /// `[FixupEntry]`.
    pub fixups: Span,
    /// `[u8]` symbol flags (same count as `symbols`).
    pub sym_flags: Span,
    /// `[u64]` symbol slots.
    pub symbols: Span,
    /// Constant pool bytes.
    pub consts: Span,
    /// `[ScopeEntry]`.
    pub scopes: Span,
    /// `[CallSiteEntry]`.
    pub call_sites: Span,
    /// `[DroppedEntry]`.
    pub dropped: Span,
    /// Number of site cache slots at the start of the writable section.
    pub site_count: u32,
    /// Byte offset of the fixup area in the writable section (after the site cache).
    pub fixup_area: u32,
    /// The [`Mode`] the code was encoded in ([`mode_bits`]).
    pub mode: u32,
    /// The [`JitRecord`]s: their byte offset in the writable section (64-aligned) and count
    /// (the function count with [`Mode::counters`], else 0).
    pub jit_records: Span,
}

/// A function table entry.
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct FuncEntry {
    /// Byte offset of the machine code in the text section.
    pub code_off: u32,
    /// Length in bytes.
    pub code_len: u32,
    /// Size of the stack argument area (informative: VM functions are called natively).
    pub arg_size: u32,
    /// Size of the return value.
    pub ret_size: u32,
    /// How the function returns its value ([`crate::asm::RET_SRET`], exact sizes): how
    /// a caller collects it (informative).
    pub ret_kind: u32,
    /// The function's scopes: a run of the scope table (`off` is an index), sorted by
    /// position.
    pub scopes: Span,
    /// The function's call sites: a run of the call-site table (`off` is an index), sorted
    /// by position.
    pub call_sites: Span,
    /// The function's dropped stores: a run of the dropped-store table (`off` is an index),
    /// sorted by position.
    pub dropped: Span,
}

/// A dropped-store table entry: a store of an inline sequence the encoder dropped as dead
/// (`asm::DroppedStore`, for the decoder; the machine code doesn't show it).
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct DroppedEntry {
    /// Byte offset in the function's code where the store would have been.
    pub code_offset: u32,
    /// Signed byte offset from `fp` of the slot it would have written.
    pub frame_offset: i32,
    /// Its size in bytes: 1, 2, 4 or 8.
    pub size: u8,
    /// The register it would have stored, by its x86 number: one the inline sequences
    /// compute in (`rax`, `rdx`, `rsi`, `rdi`, `r8`–`r11`).
    pub reg: u8,
    /// 0.
    pub reserved: u16,
}

impl DroppedEntry {
    fn valid(&self, code_len: u32) -> bool {
        self.code_offset <= code_len && matches!(self.size, 1 | 2 | 4 | 8) && matches!(self.reg, 0 | 2 | 6..=11) && self.reserved == 0
    }
}

/// A scope table entry: where a frame object escapes or its storage ends (`asm::Scope`, for
/// the decoder; the machine code doesn't show them).
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct ScopeEntry {
    /// Byte offset in the function's code.
    pub code_offset: u32,
    /// Signed byte offset from `fp` of the object.
    pub frame_offset: i32,
    /// Size of the object in bytes.
    pub size: u32,
    /// An escape: the object's alignment (a power of two, at most 16); 0 for a storage end.
    pub align: u32,
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
        if self.pad == CONTINUE { Cleanup::Continue } else { Cleanup::Pad(self.pad & !CATCH, self.pad & CATCH != 0) }
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
        if self.target == CONTINUE { Cleanup::Continue } else { Cleanup::Pad(self.target & !CATCH, self.target & CATCH != 0) }
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
    /// The image was written for another format version.
    Version(u32),
    /// A part lies outside the read-only section.
    OutOfBounds(&'static str),
    /// The function table isn't sorted, or a function's code is out of range.
    BadFunction(u32),
    /// A fixup is out of range of the writable section or the symbol table.
    BadFixup(u32),
    /// A symbol flag byte has unknown bits.
    BadSymbolFlags(u32),
    /// `Header::mode` has unknown bits or a combination the encoder doesn't support.
    BadMode,
    /// A scope table entry (index) is out of range of its function, out of order or
    /// malformed.
    BadScope(u32),
    /// A call-site table entry (index) is out of range of its function or overlaps the one
    /// before.
    BadCallSite(u32),
    /// A dropped-store table entry (index) is out of range of its function, out of order or
    /// malformed.
    BadDropped(u32),
    /// The writable section layout is inconsistent.
    BadData,
}

impl fmt::Display for ImageError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

/// A zero-copy view of an image's read-only section.
#[derive(Clone, Copy)]
pub struct Image<'a> {
    bytes: &'a [u8],
    header: &'a Header,
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
        if header.version != crate::FORMAT_VERSION {
            return Err(ImageError::Version(header.version));
        }
        if (header.size as usize) > bytes.len() {
            return Err(ImageError::Truncated);
        }
        let bytes = &bytes[..header.size as usize];
        let img = Image { bytes, header };
        cast::<FuncEntry>(bytes, header.functions, "functions")?;
        cast::<u8>(bytes, header.code_consts, "code constants")?;
        cast::<FixupEntry>(bytes, header.fixups, "fixups")?;
        cast::<u8>(bytes, header.sym_flags, "symbol flags")?;
        cast::<u64>(bytes, header.symbols, "symbols")?;
        cast::<u8>(bytes, header.consts, "constants")?;
        cast::<ScopeEntry>(bytes, header.scopes, "scopes")?;
        cast::<CallSiteEntry>(bytes, header.call_sites, "call sites")?;
        cast::<DroppedEntry>(bytes, header.dropped, "dropped stores")?;
        let mode = MODE_FP_ARG | MODE_FRAME_POINTER | MODE_ALIGN_LOOPS | MODE_PE | MODE_COUNTERS;
        if header.mode & !mode != 0 || !Self::mode_of(header.mode).valid() {
            return Err(ImageError::BadMode);
        }
        if header.sym_flags.count != header.symbols.count {
            return Err(ImageError::OutOfBounds("symbol flags"));
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
    /// sites), fixups and symbol flags.
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
            if !run(f.scopes, self.header.scopes.count)
                || !run(f.call_sites, self.header.call_sites.count)
                || !run(f.dropped, self.header.dropped.count)
            {
                return Err(ImageError::BadFunction(i));
            }
            let mut prev = 0;
            for (j, s) in self.scopes(i).iter().enumerate() {
                let sorted = s.code_offset >= prev;
                prev = s.code_offset;
                if !sorted || s.code_offset > f.code_len || (s.align != 0 && (!s.align.is_power_of_two() || s.align > 16)) {
                    return Err(ImageError::BadScope(f.scopes.off + j as u32));
                }
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
            let mut prev = 0;
            for (j, d) in self.dropped(i).iter().enumerate() {
                let sorted = d.code_offset >= prev;
                prev = d.code_offset;
                if !sorted || !d.valid(f.code_len) {
                    return Err(ImageError::BadDropped(f.dropped.off + j as u32));
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
        Self::mode_of(self.header.mode)
    }

    fn mode_of(m: u32) -> Mode {
        Mode {
            fp_arg: m & MODE_FP_ARG != 0,
            frame_pointer: m & MODE_FRAME_POINTER != 0,
            align_loops: m & MODE_ALIGN_LOOPS != 0,
            pe: m & MODE_PE != 0,
            counters: m & MODE_COUNTERS != 0,
        }
    }

    /// The run of `entries` of `table` that `run` (an index range) names, empty if out of
    /// range (only [`Self::validate`] checks the runs).
    fn run<T>(&self, table: Span, run: Span) -> &'a [T] {
        let all = self.part::<T>(table);
        all.get(run.off as usize..).and_then(|s| s.get(..run.count as usize)).unwrap_or(&[])
    }

    /// Function `func`'s scopes, sorted by position (empty for an unknown function).
    pub fn scopes(&self, func: u32) -> &'a [ScopeEntry] {
        let Some(f) = self.functions().get(func as usize) else { return &[] };
        self.run(self.header.scopes, f.scopes)
    }

    /// Function `func`'s call sites, sorted by position (empty for an unknown function).
    pub fn call_sites(&self, func: u32) -> &'a [CallSiteEntry] {
        let Some(f) = self.functions().get(func as usize) else { return &[] };
        self.run(self.header.call_sites, f.call_sites)
    }

    /// Function `func`'s dropped stores, sorted by position (empty for an unknown function).
    pub fn dropped(&self, func: u32) -> &'a [DroppedEntry] {
        let Some(f) = self.functions().get(func as usize) else { return &[] };
        self.run(self.header.dropped, f.dropped)
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

/// Classifies the addresses an image's linked code refers to ([`crate::asm::Resolver`]), by
/// the image's header ranges, for decoding its functions at run time
/// ([`crate::asm::decode_linked`]). The handlers aren't in the image: `handlers` gives their
/// addresses (sorted; an address shared by several opcodes resolves to none of them), `probe`
/// that of `ryo_probe_stack`.
#[cfg(feature = "alloc")]
#[derive(Clone, Copy)]
pub struct ImageResolver<'a> {
    pub image: Image<'a>,
    pub handlers: &'a [(usize, crate::full::Opcode)],
    pub probe: usize,
}

#[cfg(feature = "alloc")]
impl ImageResolver<'_> {
    /// Decodes function `func` to the reduced set, from the image's linked text section
    /// `text` (`Header::text_size` bytes at `Header::text`), with its scopes, call sites and
    /// dropped stores. `None` for an unknown function or a malformed dropped store (which
    /// [`Image::validate`] rejects).
    pub fn decode(&self, func: u32, text: &[u8]) -> Option<Result<crate::asm::Decoded, crate::asm::AsmError>> {
        use alloc::vec::Vec;
        let f = self.image.functions().get(func as usize)?;
        let code = text.get(f.code_off as usize..)?.get(..f.code_len as usize)?;
        let sites: Vec<_> = self.image.call_sites(func).iter().map(crate::asm::CallSite::from).collect();
        let scopes: Vec<_> = self.image.scopes(func).iter().map(crate::asm::Scope::from).collect();
        let dropped = self
            .image
            .dropped(func)
            .iter()
            .map(|d| crate::asm::DroppedStore::from_parts(d.code_offset, d.frame_offset, d.size, d.reg))
            .collect::<Option<Vec<_>>>()?;
        let addr = self.image.header().text.wrapping_add(f.code_off as u64);
        let record = self.image.jit_records().wrapping_add(func as usize) as u64;
        Some(crate::asm::decode_linked(code, addr, record, self, &sites, &dropped, &scopes, self.image.mode()))
    }
}

#[cfg(feature = "alloc")]
impl crate::asm::Resolver for ImageResolver<'_> {
    fn resolve(&self, addr: u64) -> Option<crate::asm::Ref> {
        use crate::asm::Ref;
        use crate::full::{Const, Data, Func, Site, Sym};
        // A handler address shared by several opcodes (folded handlers) is ambiguous.
        let lo = self.handlers.partition_point(|h| (h.0 as u64) < addr);
        let hi = self.handlers.partition_point(|h| (h.0 as u64) <= addr);
        if hi - lo == 1 {
            return Some(Ref::Handler(self.handlers[lo].1));
        }
        if hi > lo {
            return None;
        }
        if addr == self.probe as u64 {
            return Some(Ref::Probe);
        }
        let h = self.image.header();
        // The offset of `addr` in the `len` bytes at `base` (one past the end with `end`).
        let within = |base: u64, len: u64, end: bool| {
            addr.checked_sub(base).filter(|&o| o < len.saturating_add(end as u64)).and_then(|o| u32::try_from(o).ok())
        };
        let ro = self.image.bytes().as_ptr() as u64;
        let consts = (ro.wrapping_add(h.consts.off as u64), h.consts.count as u64);
        // The fixup area ends where the JIT records start.
        let data_end = if h.jit_records.count != 0 { h.jit_records.off } else { h.data_size };
        let data = (h.data.wrapping_add(h.fixup_area as u64), data_end.saturating_sub(h.fixup_area) as u64);
        if let Some(o) = within(h.text, h.text_size as u64, false) {
            let fs = self.image.functions();
            return fs.binary_search_by_key(&o, |f| f.code_off).ok().map(|i| Ref::Func(Func(i as u32)));
        }
        if let Some(o) = within(ro.wrapping_add(h.symbols.off as u64), h.symbols.count as u64 * 8, false) {
            return (o % 8 == 0).then_some(Ref::Sym(Sym(o / 8)));
        }
        if let Some(o) = within(ro.wrapping_add(h.code_consts.off as u64), h.code_consts.count as u64, false) {
            return Some(Ref::Ro(o));
        }
        if let Some(o) = within(consts.0, consts.1, false) {
            return Some(Ref::Const(Const(o)));
        }
        if let Some(o) = within(h.data, h.site_count as u64 * 8, false) {
            return (o % 8 == 0).then_some(Ref::Site(Site(o / 8)));
        }
        if let Some(o) = within(data.0, data.1, false) {
            return Some(Ref::Data(Data(o)));
        }
        // One past the end of the constants or the data, only once no range holds `addr`
        // (sections may be adjacent).
        if let Some(o) = within(consts.0, consts.1, true) {
            return Some(Ref::Const(Const(o)));
        }
        within(data.0, data.1, true).map(|o| Ref::Data(Data(o)))
    }

    fn code_consts(&self) -> &[u8] {
        self.image.code_consts()
    }
}

impl fmt::Debug for Image<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("Image").field("header", self.header).finish()
    }
}
