//! Frame layout constants and the argument block layout.
//!
//! # Why `arg_block` takes offsets instead of computing them
//!
//! The argument block has the layout of the tuple of the callee's ABI argument types, as
//! rustc's `tcx.layout_of` computes it (design/lowering.md, "Frame slots"). rustc's tuple
//! layout (`rustc_abi::layout::univariant`) reorders fields, and the order depends on more
//! than each field's size and alignment: it also depends on where the fields' niches are
//! (the largest niche is moved to the start or end of the struct). For example, on 1.99.1,
//! `(u32, u8, bool, u8)` puts the `bool` at offset 4 and the first `u8` at 5, while
//! `(u32, u8, u8, u8)`, with the same sizes and alignments, keeps source order. The
//! algorithm also changes between releases, and `-Zrandomize-layout` would change it again.
//!
//! So this crate doesn't replicate it. The backend gets the offsets from
//! `tcx.layout_of(tuple)` and passes them to [`arg_block`], which checks that they form a
//! valid block and describes where each argument lives in the frame. The VM and the
//! templates never need the computation: they either run bytecode that already contains the
//! offsets, or use the real Rust tuple type.

/// Size of the frame header (caller fp, return pc). The argument block starts at `fp + H`.
pub const HEADER_SIZE: u32 = 16;

/// Alignment of every frame (`fp`), and of `frame_size`.
pub const FRAME_ALIGN: u32 = 16;

/// Byte offset of the caller fp in the frame header.
pub const CALLER_FP_OFFSET: u32 = 0;

/// Byte offset of the return pc in the frame header.
pub const RETURN_PC_OFFSET: u32 = 8;

/// `frame_size` for a frame whose locals end at `end` bytes from `fp` (header included):
/// `end` rounded up to [`FRAME_ALIGN`].
pub const fn frame_size(end: u32) -> u32 {
    (end + FRAME_ALIGN - 1) & !(FRAME_ALIGN - 1)
}

/// One argument's place in the block, as rustc laid it out.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct ArgField {
    /// Offset in the tuple (`layout.fields.offset(i)`).
    pub offset: u32,
    /// `layout.size` of the argument type.
    pub size: u32,
    /// `layout.align.abi` of the argument type.
    pub align: u32,
}

/// Why a layout was rejected.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ArgBlockError {
    /// An alignment isn't a power of two.
    BadAlign,
    /// The block's size isn't a multiple of its alignment.
    SizeNotAligned,
    /// The field at this index isn't aligned to its own alignment.
    FieldMisaligned(usize),
    /// The field's alignment exceeds the block's.
    FieldOverAligned(usize),
    /// The field extends past the block's size.
    FieldOutOfBounds(usize),
    /// These two non-ZST fields overlap.
    Overlap(usize, usize),
    /// The block needs more than [`FRAME_ALIGN`] alignment, which a frame can't provide.
    /// The backend keeps such functions native.
    BlockOverAligned,
}

/// A validated argument block layout. Field `i` is the `i`-th ABI argument.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ArgBlock<'a> {
    fields: &'a [ArgField],
    size: u32,
    align: u32,
}

/// Checks and describes an argument block layout: the fields and the total `size`/`align`
/// of the tuple of the ABI argument types, all taken from `tcx.layout_of` by the backend.
///
/// Checks: power-of-two alignments, `size` a multiple of `align`, every field aligned and in
/// bounds, no field more aligned than the block, no overlap between non-ZST fields, and
/// `align <= FRAME_ALIGN`.
pub fn arg_block(fields: &[ArgField], size: u32, align: u32) -> Result<ArgBlock<'_>, ArgBlockError> {
    if !align.is_power_of_two() {
        return Err(ArgBlockError::BadAlign);
    }
    if size % align != 0 {
        return Err(ArgBlockError::SizeNotAligned);
    }
    for (i, f) in fields.iter().enumerate() {
        if !f.align.is_power_of_two() {
            return Err(ArgBlockError::BadAlign);
        }
        if f.align > align {
            return Err(ArgBlockError::FieldOverAligned(i));
        }
        if f.offset % f.align != 0 {
            return Err(ArgBlockError::FieldMisaligned(i));
        }
        if f.offset as u64 + f.size as u64 > size as u64 {
            return Err(ArgBlockError::FieldOutOfBounds(i));
        }
    }
    for (i, a) in fields.iter().enumerate() {
        for (j, b) in fields.iter().enumerate().skip(i + 1) {
            if a.size != 0 && b.size != 0 && a.offset < b.offset + b.size && b.offset < a.offset + a.size {
                return Err(ArgBlockError::Overlap(i, j));
            }
        }
    }
    if align > FRAME_ALIGN {
        return Err(ArgBlockError::BlockOverAligned);
    }
    Ok(ArgBlock { fields, size, align })
}

impl<'a> ArgBlock<'a> {
    pub fn fields(&self) -> &'a [ArgField] {
        self.fields
    }

    pub fn size(&self) -> u32 {
        self.size
    }

    pub fn align(&self) -> u32 {
        self.align
    }

    /// Offset of argument `i` from the callee's `fp` (`H + offset`).
    pub fn frame_offset(&self, i: usize) -> u32 {
        HEADER_SIZE + self.fields[i].offset
    }

    /// Offset of argument `i` from the *caller's* `fp`, for a caller with `frame_size`
    /// writing its outgoing block (design/lowering.md, "Calls").
    pub fn outgoing_offset(&self, caller_frame_size: u32, i: usize) -> u32 {
        caller_frame_size + self.frame_offset(i)
    }

    /// First frame offset after the block, where the other locals may start.
    pub fn end(&self) -> u32 {
        HEADER_SIZE + self.size
    }
}
