//! The bytecode format: opcodes, encoding, the argument block layout, and the image format.
//! Shared by the backend (writer) and the VM (reader).
//!
//! - [`full`]: the full instruction set: opcodes ([`Opcode`], [`OP_INFO`]), the decoded
//!   instruction type [`Insn`], decoder, encoder and disassembler. Generated from the opcode
//!   list in `src/isa/full_ops.rs`.
//! - [`abi`]: frame header constants and [`abi::check_arg_block`], the argument block check.
//! - [`asm`]: the machine-code form of instructions: handler register layouts, and (`alloc`)
//!   the x86-64 encoder and decoder, and the mapping to the reduced set ([`asm::reduce`]).
//! - [`reduced`]: the reduced instruction set, generated from `src/isa/reduced_ops.rs`: the
//!   instructions that run as native code, and one `handler` instruction for the rest. It
//!   shares [`full`]'s operand machinery (`define_ops!`), hence `full`'s `#[macro_use]`.
//! - [`image`]: the image format, its zero-copy reader, the writer (`alloc`), and the portal
//!   `ID` helpers.
//! - [`jit`]: the JIT's SSA tier: the handlers' frame effects, and (`alloc`) the SSA IR, its
//!   construction from decoded code and its code generation.
//! - [`jit_abi`]: the interface between the runtime and the JIT ([`jit_abi::RtApi`]).
//! - [`os`]: the other OS calls of the runtime and the JIT (a stderr write, `atexit`).
//! - [`rt_symbols`]: the names of `ryo_rt`'s entry points and of the symbols around images.
//! - [`vmem`]: virtual memory and code memory for the VM and the JIT, per OS.
//!
//! The decoder and the image reader use `core` only. The encoder and the image writer need
//! the `alloc` feature (on by default; `ryo_rt` disables it).

#![no_std]
#![feature(macro_metavar_expr_concat)]
// `define_ops!` takes the opcode list one entry per step.
#![recursion_limit = "512"]

#[cfg(feature = "alloc")]
extern crate alloc;

#[cfg(target_endian = "big")]
compile_error!("ryo_bytecode assumes a little-endian target");

/// The ABI tag of this ryo build (design/build.md#the-abi-tag): `RYO_ABI` as `y build` sets
/// it, `dev` without it (`vm/`'s own tests). Runtime symbols carry it as a suffix
/// (`ryo_h_<Opcode>_<tag>`; `ryo_rt`'s and `ryo_jit`'s build scripts pass the same variable),
/// as does the registration section, and images record its hash ([`ABI`]).
pub const ABI_TAG: &str = match option_env!("RYO_ABI") {
    Some(t) => t,
    None => "dev",
};

/// [`ABI_TAG`]'s 64-bit FNV-1a hash: `image::Header::abi`, which registration compares.
pub const ABI: u64 = image::fnv1a(ABI_TAG.as_bytes());

#[macro_use]
mod isa;
pub mod abi;
pub mod asm;
pub mod image;
pub mod jit;
pub mod jit_abi;
pub mod os;
pub mod rt_symbols;
pub mod vmem;

pub use full::{ALL_OPCODES, Insn, OP_INFO, OpInfo, Opcode};
pub use isa::{full, reduced};
