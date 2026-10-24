//! The JIT's SSA tier (design/jit.md, "The SSA tier"): decoded reduced code
//! ([`crate::asm::Decoded`]) to an SSA IR whose frame slots are allocas with provenance,
//! promoted to SSA values where nothing can reach them through a pointer, and back to x86-64
//! with a register allocator ([`compile`]).
//!
//! - [`effects`]: the handlers' exact frame effects.
//! - `decode` (`alloc`): the decoded code's instructions, their exact frame accesses, blocks,
//!   the CFG and its cyclic loop heads.
//! - `alloca`: the frame as allocas: which are promoted, memory, the outgoing and incoming
//!   areas, which are pinned at OSR entries, and the variable each access names.
//! - `ir`: the IR, its printer and verifier.
//! - `build`: SSA construction (Braun et al.) and the folds.
//! - `regalloc`: register allocation (every value in a slot, or linear scan) and its checker.
//! - `emit`: instruction selection, the frame, OSR entries, call sites and unwind rows.
//! - `x86`: the x86-64 encoder, checked against `objdump` by `tests/jit_x86.rs`.

#[cfg(feature = "alloc")]
pub mod alloca;
#[cfg(feature = "alloc")]
pub mod build;
#[cfg(feature = "alloc")]
pub mod decode;
pub mod effects;
#[cfg(feature = "alloc")]
pub mod emit;
#[cfg(feature = "alloc")]
pub mod ir;
#[cfg(feature = "alloc")]
pub mod regalloc;
#[cfg(feature = "alloc")]
pub mod x86;

/// Why the SSA tier doesn't compile a function (it then goes through the re-encoding
/// pipeline).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Unsupported(pub &'static str);

#[cfg(feature = "alloc")]
pub use emit::Output;

/// How the SSA tier allocates registers.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Allocator {
    /// Every value in a stack slot of its own (`RYO_JIT_OPT=ssa-naive`).
    Naive,
    /// Linear scan (`RYO_JIT_OPT=ssa`).
    LinearScan,
}

/// The SSA tier's settings.
#[derive(Clone, Copy, Debug)]
pub struct Options {
    pub alloc: Allocator,
    /// Frames laid out differently on purpose (allocas reversed, with gaps), as
    /// `RYO_JIT_SHUFFLE` does for the re-encoding pipeline.
    pub stress: bool,
    /// Check the IR and the allocation (`RYO_JIT_CHECK`).
    pub check: bool,
    /// Describe the compilation in [`Output::dump`] (`RYO_JIT_DUMP`).
    pub dump: bool,
}

/// Why [`compile`] gave no code.
#[cfg(feature = "alloc")]
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Error {
    /// The function uses something the SSA tier doesn't handle.
    Unsupported(Unsupported),
    /// A checker (`RYO_JIT_CHECK`) found a bug: what, and where.
    Check(alloc::string::String),
}

#[cfg(feature = "alloc")]
impl From<Unsupported> for Error {
    fn from(u: Unsupported) -> Error {
        Error::Unsupported(u)
    }
}

/// Compiles the decoded function `d` (its code constants `code_consts`, encoded in `mode`
/// without counters) through the SSA tier.
#[cfg(feature = "alloc")]
pub fn compile(d: &crate::asm::Decoded, code_consts: &[u8], mode: crate::asm::Mode, opts: &Options) -> Result<Output, Error> {
    let f = ir_of(d, mode)?;
    if opts.check {
        f.verify().map_err(|e| Error::Check(alloc::format!("IR: {e}")))?;
    }
    let uses = regalloc::use_counts(&f);
    let al = match opts.alloc {
        Allocator::Naive => regalloc::naive(&f, &uses),
        Allocator::LinearScan => regalloc::linear_scan(&f, &uses, mode.frame_pointer),
    };
    if opts.check {
        regalloc::check(&f, &al, mode.frame_pointer).map_err(|e| Error::Check(alloc::format!("allocation: {e}")))?;
    }
    let mut out = emit::emit(&f, &al, mode, code_consts, emit::Opts { stress: opts.stress })?;
    if opts.dump {
        use core::fmt::Write;
        let mut s = alloc::string::String::new();
        let _ = writeln!(s, "; reduced code (frame {})\n{}", d.frame_size, crate::reduced::Disasm(&d.words));
        let _ = writeln!(s, "; IR\n{f}");
        let _ = writeln!(s, "; locations ({} spill slots, saved {:?})", al.spills, al.saved);
        for (v, l) in al.loc.iter().enumerate() {
            if *l != regalloc::Loc::None {
                let _ = writeln!(s, "v{v}: {l:?}");
            }
        }
        let _ = writeln!(s, "; frame {} bytes, code {} bytes, OSR code at {}", out.frame_size, out.code.len(), out.osr_at);
        for (k, b) in out.code.iter().enumerate() {
            let _ = write!(s, "{b:02x}{}", if k % 32 == 31 { "\n" } else { " " });
        }
        let _ = writeln!(s, "\n; call sites {:?}\n; cfi {:?}", out.call_sites, out.cfi);
        out.dump = Some(s);
    }
    Ok(out)
}

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
