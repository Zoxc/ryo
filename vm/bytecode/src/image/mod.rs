//! The image format (design/vm.md, "Image format") and its zero-copy reader.
//!
//! An image is two sections:
//!
//! **Read-only** (starts with [`Header`], aligned to at least 8; byte offsets below are
//! from the header):
//!
//! | Part | Contents |
//! |---|---|
//! | header | [`Header`] |
//! | functions | `[FuncEntry]`, sorted by code offset; index = [`Func`](crate::insn::Func) |
//! | code | `[u32]`: every function's instruction words |
//! | cleanup | `[CleanupEntry]`: each function's entries, contiguous, sorted by code offset |
//! | fixups | `[FixupEntry]` (PE only, otherwise empty) |
//! | symbol flags | `[u8]`, one per symbol ([`SYM_INDIRECT`]) |
//! | symbols | `[u64]`: one pointer slot per symbol, filled by the linker |
//! | constants | the constant pool, aligned to its most aligned allocation |
//!
//! **Writable**: the site cache (`site_count` pointer-sized zeroed slots), then the fixup
//! area at `Header::fixup_area` (constant allocations patched at registration, PE only).
//!
//! The header's `data` field is a pointer to the writable section, filled by a relocation.
//!
//! All code positions are in words: a function's `code_off` indexes the code array, and
//! cleanup offsets and targets are relative to the function's first word.
//!
//! The reader works on `core` only. [`Image::parse`] checks the header and that every part
//! is in bounds and aligned (cheap, O(1)); [`Image::validate`] also checks every function and
//! cleanup table (O(size)).

#[cfg(feature = "alloc")]
mod writer;
#[cfg(feature = "alloc")]
pub use writer::*;

use core::{fmt, mem, slice};

/// `Header::magic`.
pub const MAGIC: [u8; 8] = *b"RYOIMAGE";

/// Symbol flag: the slot holds the address of an import slot (`__imp_<sym>`, PE), and the
/// real address is loaded through it.
pub const SYM_INDIRECT: u8 = 1;

/// `FuncEntry::portal` for functions without a portal.
pub const NO_PORTAL: u32 = u32::MAX;

/// `CleanupEntry::target` for a terminate entry (abort).
pub const TERMINATE: u32 = u32::MAX;

/// Builds a portal `ID` (design/stubs.md): crate hash in the high 32 bits, function index in
/// the low 32.
pub const fn portal_id(crate_hash: u32, func: u32) -> u64 {
    (crate_hash as u64) << 32 | func as u64
}

/// Splits a portal `ID` into (crate hash, function index).
pub const fn split_portal_id(id: u64) -> (u32, u32) {
    ((id >> 32) as u32, id as u32)
}

/// The 32-bit crate hash used in portal IDs and the registry, folded from the crate's
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
    /// `[u32]` code words.
    pub code: Span,
    /// `[CleanupEntry]`.
    pub cleanup: Span,
    /// `[FixupEntry]`.
    pub fixups: Span,
    /// `[u8]` symbol flags (same count as `symbols`).
    pub sym_flags: Span,
    /// `[u64]` symbol slots.
    pub symbols: Span,
    /// Constant pool bytes.
    pub consts: Span,
    /// Number of site cache slots at the start of the writable section.
    pub site_count: u32,
    /// Byte offset of the fixup area in the writable section (after the site cache).
    pub fixup_area: u32,
}

/// A function table entry.
#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct FuncEntry {
    /// First word in the code array.
    pub code_off: u32,
    /// Length in words.
    pub code_len: u32,
    pub frame_size: u32,
    /// Bytes above `frame_size` the function may write: H plus its largest outgoing argument
    /// block, or 0 if it makes no calls. The stack check on entry covers
    /// `fp + frame_size + max_outgoing`.
    pub max_outgoing: u32,
    /// Size of the argument block (`ArgBlock::size`): the bytes `vm::enter` copies from the
    /// portal's args and `tail_call` moves down to `fp + H`.
    pub arg_size: u32,
    /// Size of the return value: what a native `tail_call.ind` target returns.
    pub ret_size: u32,
    /// First entry of this function's cleanup table.
    pub cleanup_off: u32,
    /// Number of cleanup entries.
    pub cleanup_len: u32,
    /// Symbol index of the function's portal, or [`NO_PORTAL`].
    pub portal: u32,
}

impl FuncEntry {
    pub fn portal(&self) -> Option<u32> {
        (self.portal != NO_PORTAL).then_some(self.portal)
    }
}

/// A cleanup table entry: a call-like instruction at `offset` unwinds to `target`.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct CleanupEntry {
    /// Word offset of the call-like instruction, from the function start.
    pub offset: u32,
    /// Word offset of the cleanup block, or [`TERMINATE`].
    pub target: u32,
}

/// What unwinding does at a code offset.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cleanup {
    /// Jump to this word offset in the function.
    Jump(u32),
    /// Abort.
    Terminate,
}

impl CleanupEntry {
    pub fn action(&self) -> Cleanup {
        if self.target == TERMINATE { Cleanup::Terminate } else { Cleanup::Jump(self.target) }
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
    /// A cleanup table is unsorted, out of range, or targets past the function.
    BadCleanup(u32),
    /// A fixup is out of range of the writable section or the symbol table.
    BadFixup(u32),
    /// A symbol flag byte has unknown bits.
    BadSymbolFlags(u32),
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
        cast::<u32>(bytes, header.code, "code")?;
        cast::<CleanupEntry>(bytes, header.cleanup, "cleanup")?;
        cast::<FixupEntry>(bytes, header.fixups, "fixups")?;
        cast::<u8>(bytes, header.sym_flags, "symbol flags")?;
        cast::<u64>(bytes, header.symbols, "symbols")?;
        cast::<u8>(bytes, header.consts, "constants")?;
        if header.sym_flags.count != header.symbols.count {
            return Err(ImageError::OutOfBounds("symbol flags"));
        }
        let sites_end = header.site_count as u64 * 8;
        if sites_end > header.fixup_area as u64 || header.fixup_area > header.data_size {
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

    /// Full consistency check of the function table, cleanup tables, fixups and symbol
    /// flags. Doesn't decode the code (see [`crate::image::validate_code`] with `alloc`).
    pub fn validate(&self) -> Result<(), ImageError> {
        let code_len = self.code().len() as u64;
        let mut prev_end = 0u64;
        let cleanup = self.all_cleanup();
        for (i, f) in self.functions().iter().enumerate() {
            let i = i as u32;
            let end = f.code_off as u64 + f.code_len as u64;
            if (f.code_off as u64) < prev_end || end > code_len {
                return Err(ImageError::BadFunction(i));
            }
            prev_end = end;
            if f.portal != NO_PORTAL && f.portal >= self.header.symbols.count {
                return Err(ImageError::BadFunction(i));
            }
            let entries = cleanup
                .get(f.cleanup_off as usize..)
                .and_then(|c| c.get(..f.cleanup_len as usize))
                .ok_or(ImageError::BadCleanup(i))?;
            let mut prev: Option<u32> = None;
            for e in entries {
                if e.offset >= f.code_len
                    || (e.target != TERMINATE && e.target >= f.code_len)
                    || prev.is_some_and(|p| p >= e.offset)
                {
                    return Err(ImageError::BadCleanup(i));
                }
                prev = Some(e.offset);
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

    /// All code words.
    pub fn code(&self) -> &'a [u32] {
        self.part(self.header.code)
    }

    /// Code words of function `f`.
    pub fn function_code(&self, f: u32) -> Option<&'a [u32]> {
        let e = self.functions().get(f as usize)?;
        self.code().get(e.code_off as usize..)?.get(..e.code_len as usize)
    }

    fn all_cleanup(&self) -> &'a [CleanupEntry] {
        self.part(self.header.cleanup)
    }

    /// Cleanup table of function `f`, sorted by offset.
    pub fn cleanup(&self, f: u32) -> Option<&'a [CleanupEntry]> {
        let e = self.functions().get(f as usize)?;
        self.all_cleanup().get(e.cleanup_off as usize..)?.get(..e.cleanup_len as usize)
    }

    /// The unwind action of function `f` at word offset `offset` (a call-like instruction),
    /// or `None` if unwinding leaves the frame.
    pub fn cleanup_at(&self, f: u32, offset: u32) -> Option<Cleanup> {
        let t = self.cleanup(f)?;
        t.binary_search_by_key(&offset, |e| e.offset).ok().and_then(|i| t.get(i)).map(|e| e.action())
    }

    /// The function containing code word `word` (an index into [`Self::code`]), and the
    /// offset within it.
    pub fn function_at(&self, word: u32) -> Option<(u32, u32)> {
        let fs = self.functions();
        let i = fs.partition_point(|f| f.code_off <= word).checked_sub(1)?;
        let f = fs.get(i)?;
        (word.wrapping_sub(f.code_off) < f.code_len).then_some((i as u32, word - f.code_off))
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

    /// The fixup area, base of [`Data`](crate::insn::Data) offsets.
    pub fn fixup_area(&self) -> *mut u8 {
        self.data_ptr().wrapping_add(self.header.fixup_area as usize)
    }

    /// The portal `ID` of function `f`.
    pub fn portal_id(&self, f: u32) -> u64 {
        portal_id(self.header.crate_hash, f)
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
