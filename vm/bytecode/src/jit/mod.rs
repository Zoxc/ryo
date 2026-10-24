//! The JIT's optimizing tier (design/jit.md, "The SSA tier"): decoded reduced code
//! ([`crate::asm::Decoded`]) to an SSA IR whose frame slots are allocas with provenance,
//! promoted to SSA values where nothing can reach them through a pointer, and back to x86-64
//! with a register allocator.
//!
//! - [`effects`]: the handlers' exact frame effects.

pub mod effects;
