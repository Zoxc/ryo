//! The bytecode format: opcodes, encoding, the argument block layout, and the image format.
//! Shared by the backend (writer) and the VM (reader).
//!
//! - [`insn`]: opcodes ([`Opcode`], [`OP_INFO`]), the decoded instruction type [`Insn`],
//!   decoder, encoder and disassembler. Generated from the opcode list in `src/ops.rs`.
//! - [`abi`]: frame header constants and [`abi::arg_block`], the argument block layout.
//! - [`image`]: the image format, its zero-copy reader, the writer (`alloc`), and the portal
//!   `ID` helpers.
//!
//! The decoder and the image reader use `core` only. The encoder and the image writer need
//! the `alloc` feature (on by default; `ryo_rt` disables it).

#![no_std]

#[cfg(feature = "alloc")]
extern crate alloc;

#[cfg(target_endian = "big")]
compile_error!("ryo_bytecode assumes a little-endian target");

pub mod abi;
pub mod image;
pub mod insn;

pub use insn::{ALL_OPCODES, Insn, OP_INFO, OpInfo, Opcode};

/// Version of the bytecode and image format. Bumped on every incompatible change, including
/// any change to the opcode list. Stored in each image header and checked at registration.
pub const FORMAT_VERSION: u32 = 1;
