//! The JIT's SSA pipeline (design/jit.md, "The SSA pipeline"): decoded reduced code
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
//! - `bits`: a dense bit set (liveness, escapes).
//! - `build`: SSA construction (Braun et al.).
//! - `opt`: the optimization passes on the IR: value numbering, the folds, DCE, jump
//!   threading and the promotion of allocas.
//! - `inline`: same-image inlining: the call tree, its clusters, and the IR splice.
//! - `regalloc`: register allocation (every value in a slot, or linear scan) and its checker.
//! - `emit`: instruction selection, the frame, OSR entries, call sites and unwind rows.
//! - `x86`: the x86-64 encoder, checked against `objdump` by `tests/jit_x86.rs`.

#[cfg(feature = "alloc")]
pub mod alloca;
#[cfg(feature = "alloc")]
pub mod bits;
#[cfg(feature = "alloc")]
pub mod build;
#[cfg(feature = "alloc")]
pub mod decode;
pub mod effects;
mod effects_table;
#[cfg(feature = "alloc")]
pub mod emit;
#[cfg(feature = "alloc")]
pub mod inline;
#[cfg(feature = "alloc")]
pub mod ir;
#[cfg(feature = "alloc")]
pub mod opt;
#[cfg(feature = "alloc")]
pub mod regalloc;
#[cfg(feature = "alloc")]
pub mod x86;

/// Why the SSA pipeline doesn't compile a function (it then goes through the re-encoding
/// pipeline).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Unsupported(pub &'static str);

#[cfg(feature = "alloc")]
pub use emit::Output;

/// How the SSA pipeline allocates registers.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Allocator {
    /// Every value in a stack slot of its own (`RYO_JIT_OPT=ssa-naive`).
    Naive,
    /// Linear scan (`RYO_JIT_OPT=ssa`).
    LinearScan,
}

/// The SSA pipeline's settings.
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
    /// General loop-invariant code motion (`RYO_JIT_LICM`), off by default.
    pub licm: bool,
    /// Loop rotation ([`opt::rotate`], `RYO_JIT_ROTATE=1`), off by default.
    pub rotate: bool,
}

/// Why [`compile`] gave no code.
#[cfg(feature = "alloc")]
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Error {
    /// The function uses something the SSA pipeline doesn't handle.
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
/// without counters) through the SSA pipeline, folding loads from `mem` (the constant pools,
/// [`opt::ConstMem`]), with `env` inlining the image's functions it calls ([`inline`]).
#[cfg(feature = "alloc")]
pub fn compile(
    d: &crate::asm::Decoded,
    code_consts: &[u8],
    mode: crate::asm::Mode,
    opts: &Options,
    mem: Option<&dyn opt::ConstMem>,
    mut env: Option<&mut dyn inline::Env>,
) -> Result<Output, Error> {
    // PE: cleanup landing pads run in a pad region (design/vm.md#unwinding), which this pipeline
    // doesn't lay out; re-encoding does.
    let pe_cleanup = |sites: &[crate::asm::CallSite]| mode.pe && sites.iter().any(|cs| cs.pad.is_some() && !cs.catch);
    if mode.pe && crate::asm::pe_region_start(&d.cleanup).is_some() {
        return Err(Error::Unsupported(Unsupported("PE cleanup landing pads")));
    }
    let mut f = built(d, mode, mem)?;
    f.licm = opts.licm;
    // The IR as construction leaves it, before value numbering and the folds (`RYO_JIT_DUMP`).
    let built_ir = opts.dump.then(|| alloc::format!("{f}"));
    opt::run(&mut f, mem);
    let mut decisions = opts.dump.then(alloc::string::String::new);
    let mut inlined_ir = None;
    let (devirt, inlined) = match env.as_deref_mut() {
        Some(env) => inline_rounds(&mut f, env, mem, opts, &mut decisions, &mut inlined_ir)?,
        None => (0, 0),
    };
    let before = (opts.check && opts.dump).then(|| alloc::format!("{f}"));
    if opt::promote::promote(&mut f) {
        if opts.check {
            // With `RYO_JIT_DUMP`, the IR before and after, for the log.
            let ir = |f: &ir::Func| before.as_ref().map(|b| alloc::format!("\n; before\n{b}\n; after\n{f}")).unwrap_or_default();
            f.verify().map_err(|e| Error::Check(alloc::format!("IR after promotion: {e}{}", ir(&f))))?;
        }
        opt::run(&mut f, mem);
    }
    if opts.rotate {
        opt::rotate::rotate(&mut f);
    }
    if let Some(env) = env {
        inline::retarget(&mut f, env);
    }
    if opts.check {
        f.verify().map_err(|e| Error::Check(alloc::format!("IR: {e}")))?;
    }
    if mode.pe {
        emit::check_pe(&f)?;
    }
    if opts.alloc == Allocator::LinearScan {
        regalloc::remat(&mut f);
    }
    let uses = ir::use_counts(&f);
    let al = match opts.alloc {
        Allocator::Naive => regalloc::naive(&f, &uses),
        Allocator::LinearScan => regalloc::linear_scan(&f, &uses, mode.frame_pointer),
    };
    if opts.check {
        regalloc::check(&f, &al, mode.frame_pointer).map_err(|e| Error::Check(alloc::format!("allocation: {e}")))?;
    }
    let mut out = emit::emit(&f, &al, &uses, mode, code_consts, emit::Opts { stress: opts.stress })?;
    // An inlined callee's.
    if pe_cleanup(&out.call_sites) {
        return Err(Error::Unsupported(Unsupported("PE cleanup landing pads")));
    }
    out.devirt = devirt;
    out.inlined = inlined;
    if opts.dump {
        let dump = dump_text(d, built_ir, decisions, inlined_ir, &f, &al, &out);
        out.dump = Some(dump);
    }
    Ok(out)
}

/// Calls through constant pointers become direct before and after inlining (the inlined
/// code's constants can be the callers'). Each round after the first inlines only from the
/// calls the one before made direct. Records the decisions and the IR after the last
/// inlining for the dump, and returns how many calls became direct and were inlined.
#[cfg(feature = "alloc")]
fn inline_rounds(
    f: &mut ir::Func,
    env: &mut dyn inline::Env,
    mem: Option<&dyn opt::ConstMem>,
    opts: &Options,
    decisions: &mut Option<alloc::string::String>,
    inlined_ir: &mut Option<alloc::string::String>,
) -> Result<(usize, usize), Error> {
    let (calls, tails) = inline::devirt(f, env);
    let mut devirt = calls.len() + tails;
    let mut inlined = 0;
    let mut dirty = devirt > 0;
    let mut only: Option<alloc::vec::Vec<ir::Inst>> = None;
    for round in 0..inline::PARAMS.rounds {
        if opts.check {
            f.verify().map_err(|e| Error::Check(alloc::format!("IR before inlining: {e}")))?;
        }
        if let (Some(d), true) = (decisions.as_mut(), round > 0) {
            d.push_str(&alloc::format!(";   round {}\n", round + 1));
        }
        let n = inline::inline(f, env, mem, &inline::PARAMS, only.as_deref(), opts.check, decisions.as_mut()).map_err(Error::Check)?;
        inlined += n;
        if n > 0 {
            *inlined_ir = opts.dump.then(|| alloc::format!("{f}"));
        }
        if n > 0 || dirty {
            opt::run(f, mem);
        }
        let (calls, tails) = inline::devirt(f, env);
        devirt += calls.len() + tails;
        dirty = calls.len() + tails > 0;
        if calls.is_empty() {
            break;
        }
        only = Some(calls);
    }
    if dirty {
        opt::run(f, mem);
    }
    Ok((devirt, inlined))
}

/// `RYO_JIT_DUMP`'s description of a compilation: the reduced code, the IR as built, after
/// inlining (with the decisions) and as allocated, the locations and the emitted code.
#[cfg(feature = "alloc")]
fn dump_text(
    d: &crate::asm::Decoded,
    built_ir: Option<alloc::string::String>,
    decisions: Option<alloc::string::String>,
    inlined_ir: Option<alloc::string::String>,
    f: &ir::Func,
    al: &regalloc::Alloc,
    out: &Output,
) -> alloc::string::String {
    use core::fmt::Write;
    let mut s = alloc::string::String::new();
    let _ = writeln!(s, "; reduced code (frame {})\n{}", d.frame_size, crate::reduced::Disasm(&d.words));
    let _ = writeln!(s, "; IR before value numbering and the folds\n{}", built_ir.unwrap_or_default());
    if let Some(d) = decisions.filter(|d| !d.is_empty()) {
        let _ = writeln!(s, "; inlining\n{d}");
    }
    if let Some(ir) = inlined_ir {
        let _ = writeln!(s, "; IR after inlining\n{ir}");
    }
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
    s
}

/// The SSA IR of the decoded function `d` after construction and one [`opt::run`], with the
/// loads from `mem` (its image's constant pool and the others) folded. Unlike [`compile`]'s,
/// it is not inlined, devirtualized, promoted or rotated.
#[cfg(feature = "alloc")]
pub fn ir_of(d: &crate::asm::Decoded, mode: crate::asm::Mode, mem: Option<&dyn opt::ConstMem>) -> Result<ir::Func, Unsupported> {
    let mut f = built(d, mode, mem)?;
    opt::run(&mut f, mem);
    Ok(f)
}

/// The SSA IR of the decoded function `d` as construction leaves it, before the folds.
#[cfg(feature = "alloc")]
fn built(d: &crate::asm::Decoded, mode: crate::asm::Mode, mem: Option<&dyn opt::ConstMem>) -> Result<ir::Func, Unsupported> {
    if mode.counters || !mode.valid() {
        return Err(Unsupported("mode"));
    }
    let code = decode::decode(d, mode, mem)?;
    let fr = alloca::analyze(&code, d.frame_size)?;
    build::build(&code, &fr, d.frame_size, mode)
}
