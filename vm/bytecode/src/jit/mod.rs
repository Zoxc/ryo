//! The JIT's SSA tier (design/jit.md, "The SSA tier"): decoded reduced code
//! ([`crate::asm::Decoded`]) to an SSA IR whose frame slots are allocas with provenance,
//! promoted to SSA values where nothing can reach them through a pointer ([`ir_of`]), and
//! (later) back to x86-64 with a register allocator.
//!
//! - [`effects`]: the handlers' exact frame effects.
//! - `decode` (`alloc`): the decoded code's instructions, their exact frame accesses, blocks,
//!   the CFG and its cyclic loop heads.
//! - `alloca`: the frame as allocas: which are promoted, memory, the outgoing and incoming
//!   areas, which are pinned at OSR entries, and the variable each access names.
//! - `ir`: the IR, its printer and verifier.
//! - `build`: SSA construction (Braun et al.) and the folds.
//! - `x86`: the x86-64 encoder, checked against `objdump` by `tests/jit_x86.rs`.

#[cfg(feature = "alloc")]
pub mod alloca;
#[cfg(feature = "alloc")]
pub mod build;
#[cfg(feature = "alloc")]
pub mod decode;
pub mod effects;
#[cfg(feature = "alloc")]
pub mod ir;
#[cfg(feature = "alloc")]
pub mod x86;

/// Why the SSA tier doesn't compile a function (it then goes through the re-encoding
/// pipeline).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Unsupported(pub &'static str);

/// The SSA IR of the decoded function `d`.
#[cfg(feature = "alloc")]
pub fn ir_of(d: &crate::asm::Decoded, mode: crate::asm::Mode) -> Result<ir::Func, Unsupported> {
    if mode.pe || mode.counters || !mode.valid() {
        return Err(Unsupported("mode"));
    }
    let code = decode::decode(d, mode)?;
    let fr = alloca::analyze(&code, d.frame_size)?;
    build::build(&code, &fr, d.frame_size)
}
