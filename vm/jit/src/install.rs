//! The JIT thread's compiler: decodes a function from its image, compiles it with the SSA
//! pipeline (`RYO_JIT_OPT=ssa` or `ssa-naive`), and installs the code near the image: code
//! memory, relocation, unwind information, the perf map, and the record's publication
//! (design/jit.md, "Compiling and installing"). A function the SSA pipeline declines stays in
//! its AOT code.

use core::ptr;
use core::sync::atomic::AtomicUsize;
use core::sync::atomic::Ordering::{Acquire, Relaxed, Release};
use std::collections::HashMap;
use std::io::Write;
use std::vec::Vec;

use ryo_bytecode::asm::{self, FUNC_FAR, FUNC_KINDS, FUNC_NEAR, FUNC_SLOT, Mode, Ref};
use ryo_bytecode::full::{Const, Data, Func, Sym};
use ryo_bytecode::image::{
    Image, ImageResolver, JIT_DONE, JitRecord, eh_cie, eh_fde_rows, jit_count, jit_unbiased, pe_handler_data, pe_osr_unwind_info, pe_with_handler,
};
use ryo_bytecode::jit;
use ryo_bytecode::jit::inline::VmFunc;
use ryo_bytecode::jit::ir::CallTarget;
use ryo_bytecode::jit_abi::{JIT_ENTRY_PREFIX, JIT_ENTRY_PREFIX_BYTES, JitOpt, RtApi, RtCode};
use ryo_bytecode::{Opcode, reduced, vmem};

use crate::stats::{self, Decline, Fail, STATS};

mod callees;
mod dump;
mod region;

pub(crate) use callees::init_tls;
use callees::{Calls, Copies, Ext, InlineEnv, IrCache, Name, PoolMem};
use region::{Place, REGION, Region, Span};

/// The page size.
const PAGE: usize = vmem::PAGE;

/// Where a function's code starts in its allocation: 16-aligned, after the entry prefix.
const CODE_AT: usize = 16;
const _: () = assert!(JIT_ENTRY_PREFIX <= CODE_AT);
/// Where the allocation holds the code's length, a `u32` ([`installed_len`]): before the
/// entry prefix.
const CODE_LEN_AT: usize = 0;
const _: () = assert!(CODE_LEN_AT + 4 <= CODE_AT - JIT_ENTRY_PREFIX);

/// The length of the code the JIT installed for the record at `rec`, 0 if none.
pub(crate) fn installed_len(rec: *const JitRecord) -> usize {
    // SAFETY: a live record; its JIT code, once published, starts `CODE_AT` bytes into its
    // allocation, which holds the length at `CODE_LEN_AT`.
    unsafe {
        let code = (*rec).jit_code;
        if code.is_null() {
            return 0;
        }
        code.sub(CODE_AT - CODE_LEN_AT).cast::<u32>().read_unaligned() as usize
    }
}

/// The profile of a function: how many times its AOT code was called, and how many loop
/// iterations it ran, from its record's counters ([`JitRecord`]).
#[derive(Clone, Copy, Debug, Default)]
pub(crate) struct Counts {
    pub(crate) calls: u64,
    pub(crate) iters: u64,
}

/// [`Counts`] of `rec`, with `thresholds` the counters' ([`RtApi::thresholds`]).
pub(crate) fn counts(rec: *mut JitRecord, thresholds: [i64; 2]) -> Counts {
    let n = |v: i64, t: i64| jit_count(v, t).max(0) as u64;
    Counts { calls: n(JitRecord::ctr_e(rec).load(Relaxed), thresholds[0]), iters: n(JitRecord::ctr_l(rec).load(Relaxed), thresholds[1]) }
}

/// Whether a compiled record's counters both have its bias (a racing AOT increment can erase
/// it: [`crate::thread`] re-checks).
pub(crate) fn settled(rec: *mut JitRecord) -> bool {
    [JitRecord::ctr_e(rec), JitRecord::ctr_l(rec)].iter().all(|c| {
        // Relaxed: only the counter's own value matters, nothing is published through it.
        let v = c.load(Relaxed);
        v != jit_unbiased(v) && v > 0
    })
}

/// A function's machine code, from the SSA pipeline, before it is installed.
struct Gen {
    code: Vec<u8>,
    relocs: Vec<asm::Reloc>,
    rodata: Vec<u8>,
    call_sites: Vec<asm::CallSite>,
    body: Body,
    osr: Option<asm::osr::OsrCode>,
    osr_at: usize,
    /// The call map for backtraces ([`jit::Output::calls`], `chains`).
    calls: Vec<(u32, u32)>,
    chains: Vec<jit::ir::ChainLink>,
}

/// The unwind rules of a function's body.
enum Body {
    /// The SSA pipeline's rows.
    Rows(Vec<(u32, Vec<u8>)>),
    /// The SSA pipeline's PE `UNWIND_INFO`.
    Pe(Vec<u8>),
}

/// What the JIT knows about an image: its range, and its `rust_eh_personality` slot.
#[derive(Clone, Copy)]
struct ImageInfo {
    span: Span,
    personality: Option<usize>,
}

/// Why a compilation didn't install code.
enum CompileError {
    /// The region the code was encoded for filled up and was retired ([`Jit::install`]):
    /// the calls' forms depend on the region, so the function is compiled again.
    Retry,
    /// It failed, for this reason.
    Fail(Fail),
}

impl From<&'static str> for CompileError {
    fn from(why: &'static str) -> CompileError {
        CompileError::Fail(Fail::Other(why))
    }
}

pub(crate) struct Jit {
    rt: &'static RtApi,
    /// The handlers each image's code calls, for [`ImageResolver`].
    copies: Copies,
    /// The handlers' and the probe's range.
    rt_span: Span,
    regions: Vec<Region>,
    images: HashMap<usize, ImageInfo>,
    perfmap: Option<std::fs::File>,
    /// Call slots: JIT code calls (and tail-calls) a VM function, of any image, that wasn't
    /// compiled yet through an 8-byte slot in its region's read-write end (`call [rip +
    /// slot]`), which holds the function's AOT entry and then its JIT code. By (region index,
    /// image header, function).
    slots: HashMap<(usize, usize, u32), usize>,
    /// The slots by (image header, function), which its publication updates.
    slots_of: HashMap<(usize, u32), Vec<usize>>,
    /// `RYO_JIT_DUMP`: the directory the SSA pipeline writes a description of each compilation
    /// to.
    dump: Option<String>,
    /// How many functions went to the SSA pipeline so far ([`ryo_bytecode::jit_abi::JitSettings::ssa_limit`]).
    ssa_tried: u64,
    /// The statistics of the compile in progress that count only once it is published: the
    /// SSA pipeline's direct and inlined calls.
    pending: Pending,
    /// The inliner's callee IR, by (image header, function) ([`InlineEnv`]).
    ir_cache: IrCache,
}

impl Jit {
    pub(crate) fn new(rt: &'static RtApi) -> Jit {
        // The JIT's code calls this copy's handlers and probe.
        let Calls { handlers, probe } = Calls::new(rt.code);
        let lo = handlers.first().map_or(probe, |h| h.0).min(probe);
        let hi = handlers.last().map_or(probe, |h| h.0).max(probe) + PAGE;
        let perfmap = rt
            .settings
            .perfmap
            .then(crate::sys::perfmap_path)
            .flatten()
            .and_then(|path| std::fs::OpenOptions::new().create(true).append(true).open(path).ok());
        let dump = std::env::var("RYO_JIT_DUMP").ok().filter(|d| !d.is_empty());
        Jit {
            rt,
            copies: Copies::new(rt),
            rt_span: Span { lo, hi },
            regions: Vec::new(),
            images: HashMap::new(),
            perfmap,
            slots: HashMap::new(),
            slots_of: HashMap::new(),
            dump,
            ssa_tried: 0,
            pending: Pending::default(),
            ir_cache: HashMap::new(),
        }
    }

    fn image(&mut self, img: &Image<'_>) -> ImageInfo {
        let p = self.rt.personality as u64;
        *self.images.entry(img.header() as *const _ as usize).or_insert_with(|| {
            let h = img.header();
            let ro = img.bytes().as_ptr() as usize;
            let ends = [(ro, h.size as usize), (h.data as usize, h.data_size as usize), (h.text as usize, h.text_size as usize)];
            let span = Span { lo: ends.iter().map(|e| e.0).min().unwrap_or(0), hi: ends.iter().map(|e| e.0 + e.1).max().unwrap_or(0) };
            let personality = img.symbols().iter().position(|&s| s == p).and_then(|i| image_ref_addr(img, Ref::Sym(Sym(i as u32))));
            ImageInfo { span, personality }
        })
    }

    /// Compiles the function of `rec` and publishes its code.
    pub(crate) fn compile(&mut self, rec: *mut JitRecord) -> Result<(), Fail> {
        if self.rt.settings.test_panic {
            panic!("RYO_JIT_TEST_PANIC");
        }
        if self.rt.settings.test_oom {
            // `isize::MAX` bytes: a valid layout no allocator can serve.
            let v = Vec::<u8>::with_capacity(std::hint::black_box(usize::MAX / 2));
            std::hint::black_box(&v);
        }
        // `RYO_JIT_SSA_LIMIT=n` (debugging: bisects a miscompile): only the first `n` functions
        // are compiled, the rest stay in their AOT code. Counted once, not again on a retry.
        if self.ssa_tried >= self.rt.settings.ssa_limit {
            return Err(Fail::Declined(Decline::SsaLimit));
        }
        self.ssa_tried += 1;
        self.pending = Pending::default();
        // Again in another region if the one it was compiled for filled up. That one may be a
        // used region reaching the image, so it can be full as well (each retry retires one);
        // a newly mapped region is empty, and the function fits half of one.
        let mut r = self.compile_once(rec, false);
        for _ in 0..4 {
            if !matches!(r, Err(CompileError::Retry)) {
                break;
            }
            stats::add(&STATS.region_retries, 1);
            r = self.compile_once(rec, true);
        }
        r.map_err(|e| match e {
            CompileError::Retry => Fail::RegionFull,
            CompileError::Fail(why) => why,
        })
    }

    /// Compiles `rec`'s function with the SSA pipeline and installs it; `retry` for any attempt
    /// after the first, whose logs and dumps the first one already wrote.
    fn compile_once(&mut self, rec: *mut JitRecord, retry: bool) -> Result<(), CompileError> {
        // SAFETY: a record of a linked image, whose header it points at.
        let (func, img) = unsafe { ((*rec).func, Image::from_header((*rec).header.cast()).map_err(|_| "invalid image")?) };
        let h = img.header();
        let info = self.image(&img);
        // PE code has no personality: its unwind info names `ryo_seh_handler` instead, as the
        // AOT code's (design/vm.md#pe-seh).
        let personality = if img.mode().pe { 0 } else { info.personality.ok_or(CompileError::Fail(Fail::NoPersonality))? };
        let place = self.place(info.span).ok_or("no code memory near the image")?;
        let d = callees::decode(img, &mut self.copies, func).ok_or("no such function")?.map_err(|e| e.what)?;
        let mode = jit_mode(&img, place.far_rt);
        let shuffled = (self.rt.shuffled)(h as *const _ as *const u8);
        let job = Job { rec, func, img: &img, d: &d, mode, shuffled, place, personality, retry };

        let (out, ext) = self.compile_ssa(&job)?;
        self.install(&job, &ext, out)
    }

    /// Compiles `job`'s function through the SSA pipeline: its code and callees.
    /// [`Decline::Unsupported`] where the pipeline doesn't handle it: it stays in its AOT code.
    fn compile_ssa(&mut self, job: &Job<'_>) -> Result<(Gen, Vec<Ext>), CompileError> {
        let Job { rec, func, img, d, mode, shuffled, place, .. } = *job;
        let h = img.header();
        let opts = jit::Options {
            alloc: if self.rt.settings.opt == JitOpt::Ssa { jit::Allocator::LinearScan } else { jit::Allocator::Naive },
            stress: shuffled,
            check: self.rt.settings.check,
            dump: self.dump.is_some(),
            licm: self.rt.settings.licm,
            rotate: self.rt.settings.rotate,
        };
        let header = h as *const _ as usize;
        let mut env = InlineEnv {
            cache: &mut self.ir_cache,
            copies: &mut self.copies,
            mode,
            header,
            root: func,
            thresholds: self.rt.thresholds,
            rt: self.rt,
            place,
            ext: Vec::new(),
            memo: HashMap::new(),
            ext_vm: HashMap::new(),
        };
        let mem = PoolMem { header, rt: self.rt };
        let r = jit::compile(d, img.code_consts(), mode, &opts, Some(&mem), Some(&mut env));
        let ssa_ext = env.ext;
        match r {
            Ok(mut o) => {
                if let (Some(dir), Some(text)) = (&self.dump, o.dump.take()) {
                    let _ = std::fs::write(dump::dump_path(dir, func, h as *const _ as usize, "txt"), text);
                }
                let out = Gen {
                    code: o.code,
                    relocs: o.relocs,
                    rodata: o.rodata,
                    call_sites: o.call_sites,
                    body: if mode.pe { Body::Pe(o.pe_unwind) } else { Body::Rows(o.cfi) },
                    osr: o.osr,
                    osr_at: o.osr_at as usize,
                    calls: o.calls,
                    chains: o.chains,
                };
                self.pending.devirt = o.devirt as u64;
                self.pending.inlined = o.inlined as u64;
                Ok((out, ssa_ext))
            }
            // Logged as the record fails ([`crate::thread`]).
            Err(jit::Error::Unsupported(u)) => {
                if let Some(dir) = self.dump.as_ref().filter(|_| !job.retry) {
                    let text = std::format!("; unsupported: {}\n{}", u.0, reduced::Disasm(&d.words));
                    let _ = std::fs::write(dump::dump_path(dir, func, h as *const _ as usize, "txt"), text);
                }
                Err(CompileError::Fail(Fail::Declined(Decline::Unsupported(u.0))))
            }
            // A checker found a bug: always on stderr, so that tests see it, and the function
            // stays in its AOT code (`Failed`), which tests that expect JIT code notice.
            Err(jit::Error::Check(why)) => {
                self.log(rec, &std::format!("ssa: check failed: {why}"));
                Err(CompileError::Fail(Fail::SsaCheck))
            }
        }
    }

    /// Installs the code `out` of `job`'s function, with the callees `ext`: code memory,
    /// relocation, unwind information, the perf map and the publication.
    fn install(&mut self, job: &Job<'_>, ext: &[Ext], out: Gen) -> Result<(), CompileError> {
        let mode = job.mode;
        let Gen { code: enc_code, mut relocs, rodata, call_sites, body, osr, osr_at, calls, chains } = out;
        let code_len = enc_code.len();
        // The OSR code's stack probes, relocated as the body's.
        if let Some(o) = &osr {
            relocs.extend(o.probes.iter().map(|&p| asm::Reloc { at: (osr_at + p as usize) as u32, to: Ref::Probe }));
        }
        let osr_len = osr.as_ref().map_or(0, |o| o.code.len());
        let mut eh = Eh::build(&body, osr.as_ref(), osr_at, &call_sites, code_len, mode)?;

        // Code memory: the entry prefix, the code, the OSR code, on PE the handler's thunk
        // (`jmp [rip]; .quad ryo_seh_handler`), then its code constants.
        let thunk_at = (CODE_AT + osr_at + osr_len).next_multiple_of(16);
        let ro_at = if mode.pe { thunk_at + 16 } else { thunk_at };
        let size = (ro_at + rodata.len()).next_multiple_of(PAGE);
        let eh_size = eh.bytes().len().next_multiple_of(16);
        if size + eh_size > REGION / 2 {
            return Err("too large".into());
        }
        let (base, eh_base, slot_of) = self.alloc(job.place, ext, &relocs, size, eh_size)?;
        let mut code = assemble(&enc_code, osr.as_ref().map(|o| (osr_at, &o.code[..])), &rodata, size, ro_at);
        let jit_f = base + CODE_AT;
        self.relocate(job, ext, &mut code, base, ro_at, &relocs, &slot_of)?;
        if self.dump.is_some() {
            self.dump_code(job, ext, &enc_code, &relocs, osr.as_ref().map(|o| (osr_at, o)));
        }
        eh.patch(eh_base, job.personality, jit_f, osr.is_some().then_some(osr_at), base, base + thunk_at)?;
        if mode.pe {
            code[thunk_at..][..6].copy_from_slice(&[0xff, 0x25, 0, 0, 0, 0]);
            code[thunk_at + 6..][..8].copy_from_slice(&(self.rt.seh_handler as u64).to_le_bytes());
        }
        // Registration and publication: a fork waits for them (`thread::quiesce`), so that a
        // child never inherits the unwinder's lock taken or a record half published.
        let _q = crate::thread::quiesce();
        map_and_register(&code, &eh, base, eh_base, mode)?;
        self.publish_calls(job, jit_f, code_len, &calls, &chains);
        self.publish(job, jit_f, osr.is_some().then(|| jit_f + osr_at), code_len, osr_len, ro_at + rodata.len());
        Ok(())
    }

    /// Publishes the call map of `job`'s code at `jit_f` (`code_len` bytes) for backtraces,
    /// before the code can run (design/vm.md#source-locations): `calls` and `chains` as the
    /// SSA pipeline gives them, the root's links naming `job`'s function. Leaked: the
    /// runtime keeps it, as the code, for the rest of the process.
    fn publish_calls(&self, job: &Job<'_>, jit_f: usize, code_len: usize, calls: &[(u32, u32)], chains: &[jit::ir::ChainLink]) {
        use ryo_bytecode::jit_abi::{BT_ROOT, BtChain, BtRegion};
        let root_img = job.img.header() as *const _ as usize;
        let links: Vec<BtChain> = chains
            .iter()
            .map(|c| {
                let (img, func) = c.func.map_or((root_img, job.func), |g| (g.img, g.func.0));
                BtChain { img, func, pos: c.pos, parent: c.parent.checked_sub(1).unwrap_or(BT_ROOT), pad: 0 }
            })
            .collect();
        let pcmap: Vec<[u32; 2]> = calls.iter().filter(|c| c.1 != 0).map(|&(at, loc)| [at, loc - 1]).collect();
        let (npc, nchain) = (pcmap.len() as u32, links.len() as u32);
        let pcmap: &'static [[u32; 2]] = Vec::leak(pcmap);
        let links: &'static [BtChain] = Vec::leak(links);
        let r = Box::leak(Box::new(BtRegion {
            next: ptr::null_mut(),
            start: jit_f,
            len: code_len,
            root_img,
            root_func: job.func,
            npc,
            pcmap: pcmap.as_ptr(),
            nchain,
            chains: links.as_ptr(),
        }));
        (self.rt.bt_publish)(r);
    }

    /// Patches the fields `relocs` of `code`, to be at `base`, with its code constants at
    /// `ro_at` and the call slots `slot_of` of `ext`.
    #[allow(clippy::too_many_arguments)]
    fn relocate(
        &self,
        job: &Job<'_>,
        ext: &[Ext],
        code: &mut [u8],
        base: usize,
        ro_at: usize,
        relocs: &[asm::Reloc],
        slot_of: &[usize],
    ) -> Result<(), CompileError> {
        let jit_f = base + CODE_AT;
        let rec = job.rec as usize;
        // The handlers of the image's form: the frame-pointer set for code that leaves `fp` in
        // `rbp` off PE, PE code's own set if the runtime has one.
        let mode = job.img.mode();
        let (hs, rhs) = if mode.rbp_set() {
            if self.rt.code.fp_handlers.is_null() {
                return Err("no frame-pointer handler set".into());
            }
            // SAFETY: the runtime's tables, non-null.
            unsafe { (&*self.rt.code.fp_handlers, &*self.rt.code.fp_reg_handlers) }
        } else if mode.pe && !self.rt.code.pe_handlers.is_null() {
            // SAFETY: as above.
            unsafe { (&*self.rt.code.pe_handlers, &*self.rt.code.pe_reg_handlers) }
        } else {
            (&self.rt.code.handlers, &self.rt.code.reg_handlers)
        };
        for r in relocs {
            let field = jit_f + r.at as usize;
            // Fields of 8 bytes: an `imm64` of a call through `r11`.
            let abs = match r.to {
                Ref::Handler(_) | Ref::RegHandler(_) | Ref::Probe => job.place.far_rt,
                Ref::Func(Func(g)) => g & FUNC_KINDS == FUNC_FAR,
                _ => false,
            };
            let target = match r.to {
                Ref::Handler(op) => Some(hs[op as usize]).filter(|h| !h.is_null()).ok_or("no handler")? as usize,
                Ref::RegHandler(op) => Some(rhs[op as usize]).filter(|h| !h.is_null()).ok_or("no register entry")? as usize,
                Ref::Probe => self.rt.code.probe as usize,
                Ref::Func(Func(g)) if g == job.func => jit_f,
                Ref::Func(Func(g)) if g & FUNC_KINDS != 0 => {
                    let k = (g & !FUNC_KINDS) as usize;
                    if g & FUNC_KINDS == FUNC_SLOT { slot_of[k] } else { ext[k].addr }
                }
                // Every other call was retargeted.
                Ref::Func(_) => return Err("an unexpected call".into()),
                Ref::Sym(_) | Ref::Const(_) | Ref::Data(_) => image_ref_addr(job.img, r.to).ok_or("no such symbol")?,
                Ref::Ro(o) => base + ro_at + o as usize,
                Ref::Rec => rec,
                Ref::RecLoopCtr => rec + ryo_bytecode::image::JIT_LOOP_CTR as usize,
            };
            if abs {
                code[field - base..][..8].copy_from_slice(&(target as u64).to_le_bytes());
            } else {
                patch_rel32(&mut code[field - base..], field + 4, target)?;
            }
        }
        Ok(())
    }

    /// Publishes the installed code of `job`'s function at `jit_f` with its OSR dispatcher at
    /// `osr_entry`: the perf map (the `code_len` bytes of code and the `osr_len` of OSR code),
    /// the record, the call slots of it, and the log. `bytes` is
    /// the size of its code memory, for the statistics.
    fn publish(&mut self, job: &Job<'_>, jit_f: usize, osr_entry: Option<usize>, code_len: usize, osr_len: usize, bytes: usize) {
        let (rec, func) = (job.rec, job.func);
        let h = job.img.header();
        if let Some(m) = &mut self.perfmap {
            let aot = job.img.entry(func);
            let _ = writeln!(m, "{jit_f:x} {code_len:x} ryo-jit:f{func}@{aot:x}");
            if let Some(osr) = osr_entry {
                let _ = writeln!(m, "{osr:x} {osr_len:x} ryo-jit:f{func}@{aot:x}:osr");
            }
        }

        // Nothing allocates from the publication on: a panic past it (an allocation failure,
        // `thread::oom_panics`) would report a published record as failed.
        let line = self.rt.settings.log.then(|| {
            let c = counts(rec, self.rt.thresholds);
            self.log_text(rec, &std::format!("compiled ({}, {} calls, {} loop iterations)", self.rt.settings.opt.name(), c.calls, c.iters))
        });
        // Counted before the record's `Done`, whose `SeqCst` store makes the counts visible
        // to a `RYO_JIT_SYNC` waiter (stats.rs); after it, a test could miss them.
        stats::add(&STATS.compiled, 1);
        stats::add(&STATS.code, bytes as u64);
        let p = std::mem::take(&mut self.pending);
        stats::add(&STATS.devirt, p.devirt);
        stats::add(&STATS.inlined, p.inlined);
        // The dispatcher, at the start of the OSR code: every head's stub calls it from now.
        // SAFETY: the record is this thread's until `Done`.
        unsafe { JitRecord::publish(rec, jit_f as *const u8, (jit_f - JIT_ENTRY_PREFIX) as *mut u8, osr_entry.map(|a| a as *mut u8)) };
        // Calls of this function from JIT code compiled before it, of any image, go straight
        // to it now.
        for &slot in self.slots_of.get(&(h as *const _ as usize, func)).map_or(&[][..], |v| &v[..]) {
            // SAFETY: a call slot, 8-aligned, which JIT code reads with plain loads (an atomic
            // store of its size).
            unsafe { AtomicUsize::from_ptr(slot as *mut usize).store(jit_f, Release) };
        }
        if let Some(line) = line {
            log_line(&line);
        }
    }

    /// A line on stderr about `rec` (`RYO_JIT_LOG`).
    pub(crate) fn log(&self, rec: *mut JitRecord, what: &str) {
        log_line(&self.log_text(rec, what));
    }

    /// The line [`Jit::log`] writes.
    fn log_text(&self, rec: *mut JitRecord, what: &str) -> String {
        // SAFETY: a record of a linked image.
        let (func, header) = unsafe { ((*rec).func, (*rec).header) };
        std::format!("ryo-jit: f{func} of image {header:p}: {what}\n")
    }
}

/// [`Jit::pending`].
#[derive(Default)]
struct Pending {
    devirt: u64,
    inlined: u64,
}

/// A function being compiled: the function `func` of `img` (record `rec`), decoded as `d`, to
/// be compiled in `mode` (`shuffled`: `RYO_JIT_SHUFFLE`) for the region `place`, and its
/// image's personality slot.
#[derive(Clone, Copy)]
struct Job<'a> {
    rec: *mut JitRecord,
    func: u32,
    img: &'a Image<'a>,
    d: &'a asm::Decoded,
    mode: Mode,
    shuffled: bool,
    place: Place,
    personality: usize,
    /// An attempt after the first, after [`CompileError::Retry`]: the first wrote the logs and
    /// dumps.
    retry: bool,
}

/// A function's unwind information, before its PC-relative fields are patched
/// ([`Eh::patch`]). ELF: the CIE, the FDE, the OSR code's FDE, the terminator, then the
/// LSDA. PE: the `RUNTIME_FUNCTION`s, then their `UNWIND_INFO`s: the body's (the SSA
/// pipeline's, `pe_unwind_codes`), which names `ryo_seh_handler` through a thunk after the code,
/// with the LSDA as its handler data, and the OSR code's (`pe_osr_unwind_info`)
/// (design/jit.md, "Unwinding and profiling").
enum Eh {
    Elf(ElfEh),
    Pe(PeEh),
}

/// ELF (and Mach-O) unwind information: an `.eh_frame` and the LSDA.
struct ElfEh {
    bytes: Vec<u8>,
    /// The FDEs' offsets.
    fdes: Vec<usize>,
    pers_field: usize,
    fields: ryo_bytecode::image::EhFields,
    osr_fields: Option<ryo_bytecode::image::EhFields>,
    lsda_at: usize,
}

/// PE unwind information: a function table and its `UNWIND_INFO`s.
struct PeEh {
    bytes: Vec<u8>,
    /// The entries' ranges in the code and their `UNWIND_INFO`s' offsets in `bytes`.
    rfs: Vec<(usize, usize, usize)>,
    /// The handler RVA fields.
    handlers: Vec<usize>,
}

impl Eh {
    /// The information of `body` (`code_len` bytes) and its OSR code `osr` at `osr_at`.
    fn build(
        body: &Body,
        osr: Option<&asm::osr::OsrCode>,
        osr_at: usize,
        call_sites: &[asm::CallSite],
        code_len: usize,
        mode: Mode,
    ) -> Result<Eh, CompileError> {
        Ok(if mode.pe {
            Eh::Pe(PeEh::build(body, osr, osr_at, call_sites, code_len)?)
        } else {
            Eh::Elf(ElfEh::build(body, osr, call_sites, code_len)?)
        })
    }

    fn bytes(&self) -> &[u8] {
        match self {
            Eh::Elf(e) => &e.bytes,
            Eh::Pe(e) => &e.bytes,
        }
    }

    /// Patches the fields for the information at `eh_base` of code at `jit_f`, its OSR code
    /// at `osr_at` past it, with `personality` the personality slot (ELF); on PE `base` is
    /// the code's allocation and `thunk` the handler's thunk.
    fn patch(
        &mut self,
        eh_base: usize,
        personality: usize,
        jit_f: usize,
        osr_at: Option<usize>,
        base: usize,
        thunk: usize,
    ) -> Result<(), &'static str> {
        match self {
            Eh::Elf(e) => e.patch(eh_base, personality, jit_f, osr_at),
            Eh::Pe(e) => e.patch(eh_base, jit_f, base, thunk),
        }
    }

    /// What the unwinder is told of the information, at `eh_base`, for code at `base`.
    fn unwind(&self, eh_base: usize, base: usize) -> crate::sys::Unwind<'_> {
        match self {
            Eh::Elf(e) => crate::sys::Unwind::Eh { eh: eh_base as *const u8, fdes: &e.fdes },
            Eh::Pe(e) => crate::sys::Unwind::Pe { base, table: eh_base as *const u8, count: e.rfs.len() as u32 },
        }
    }
}

impl ElfEh {
    fn build(body: &Body, osr: Option<&asm::osr::OsrCode>, call_sites: &[asm::CallSite], code_len: usize) -> Result<ElfEh, CompileError> {
        let mut b = Vec::new();
        let pers_field = eh_cie(&mut b);
        let mut fdes = std::vec![b.len()];
        let fields = match body {
            Body::Rows(rows) => eh_fde_rows(&mut b, 0, code_len as u32, rows),
            Body::Pe(_) => return Err("PE unwind info off PE".into()),
        };
        if osr.is_some() {
            fdes.push(b.len());
        }
        let osr_fields = osr.map(|o| eh_fde_rows(&mut b, 0, o.code.len() as u32, &o.cfi));
        b.extend_from_slice(&[0; 4]);
        let lsda_at = b.len();
        b.extend_from_slice(&asm::lsda::write(call_sites));
        Ok(ElfEh { bytes: b, fdes, pers_field, fields, osr_fields, lsda_at })
    }

    /// `.eh_frame`'s PC-relative fields: relative to the field itself.
    fn patch(&mut self, eh_base: usize, personality: usize, jit_f: usize, osr_at: Option<usize>) -> Result<(), &'static str> {
        let eh = &mut self.bytes;
        let mut pc = |at: usize, target: usize| patch_rel32(&mut eh[at..], eh_base + at, target);
        pc(self.pers_field, personality)?;
        pc(self.fields.pc_begin, jit_f)?;
        pc(self.fields.lsda, eh_base + self.lsda_at)?;
        if let (Some(f), Some(at)) = (self.osr_fields, osr_at) {
            pc(f.pc_begin, jit_f + at)?;
        }
        Ok(())
    }
}

impl PeEh {
    fn build(
        body: &Body,
        osr: Option<&asm::osr::OsrCode>,
        osr_at: usize,
        call_sites: &[asm::CallSite],
        code_len: usize,
    ) -> Result<PeEh, CompileError> {
        let info = match body {
            Body::Pe(info) => info.clone(),
            Body::Rows(_) => return Err("DWARF rows on PE".into()),
        };
        let lsda = asm::lsda::write(call_sites);
        // The entries: their ranges in the code, `UNWIND_INFO`s and handler data. The OSR code
        // has its own ([`pe_osr_unwind_info`]); the entries' post parts are in the body's code.
        let mut entries: Vec<((usize, usize), Vec<u8>, Option<Vec<u8>>)> = std::vec![((0, code_len), info, Some(pe_handler_data(0, 0, &lsda)))];
        if let Some(o) = osr {
            entries.push(((osr_at, osr_at + o.code.len()), pe_osr_unwind_info(), None));
        }
        // The `RUNTIME_FUNCTION`s (patched later), then the `UNWIND_INFO`s.
        let mut eh = PeEh { bytes: std::vec![0; 12 * entries.len()], rfs: Vec::new(), handlers: Vec::new() };
        for (range, info, data) in entries {
            let at = eh.bytes.len();
            match data {
                Some(d) => {
                    let (bytes, field) = pe_with_handler(&info, &d);
                    eh.handlers.push(at + field);
                    eh.bytes.extend_from_slice(&bytes);
                }
                None => eh.bytes.extend_from_slice(&info),
            }
            eh.rfs.push((range.0, range.1, at));
        }
        Ok(eh)
    }

    /// The `RUNTIME_FUNCTION`s and the handler fields: offsets from `base`, below the
    /// region's read-write end.
    fn patch(&mut self, eh_base: usize, jit_f: usize, base: usize, thunk: usize) -> Result<(), &'static str> {
        let eh = &mut self.bytes;
        let rva = |a: usize| u32::try_from(a - base).map_err(|_| "out of reach");
        for (k, &(begin, end, at)) in self.rfs.iter().enumerate() {
            for (j, v) in [rva(jit_f + begin)?, rva(jit_f + end)?, rva(eh_base + at)?].iter().enumerate() {
                eh[12 * k + 4 * j..][..4].copy_from_slice(&v.to_le_bytes());
            }
        }
        for &f in &self.handlers {
            eh[f..f + 4].copy_from_slice(&rva(thunk)?.to_le_bytes());
        }
        Ok(())
    }
}

/// A function's code memory, `size` bytes: its length, the entry prefix, the code `body`,
/// the OSR code at its offset past the body, and the code constants `rodata` at `ro_at`.
fn assemble(body: &[u8], osr: Option<(usize, &[u8])>, rodata: &[u8], size: usize, ro_at: usize) -> Vec<u8> {
    let mut code = std::vec![0xccu8; size];
    code[CODE_LEN_AT..][..4].copy_from_slice(&(body.len() as u32).to_le_bytes());
    code[CODE_AT - JIT_ENTRY_PREFIX..CODE_AT].copy_from_slice(&JIT_ENTRY_PREFIX_BYTES);
    code[CODE_AT..][..body.len()].copy_from_slice(body);
    if let Some((at, o)) = osr {
        code[CODE_AT + at..][..o.len()].copy_from_slice(o);
    }
    code[ro_at..][..rodata.len()].copy_from_slice(rodata);
    code
}

/// Copies `code` and the patched `eh` to their memory at `base` and `eh_base`, makes the code
/// executable and registers its unwind information.
fn map_and_register(code: &[u8], eh: &Eh, base: usize, eh_base: usize, mode: Mode) -> Result<(), CompileError> {
    let size = code.len();
    // SAFETY: fresh read-write memory of the region, `size` and `eh.len()` bytes, which
    // nothing else uses; the code pages become executable only once written, and are
    // never written again.
    unsafe {
        ptr::copy_nonoverlapping(code.as_ptr(), base as *mut u8, size);
        ptr::copy_nonoverlapping(eh.bytes().as_ptr(), eh_base as *mut u8, eh.bytes().len());
        if !vmem::make_executable(base as *mut u8, size) {
            return Err("make_executable".into());
        }
        // Unregistered, the code must not run: nothing could unwind through it. At exit
        // it isn't needed.
        let unwind = eh.unwind(eh_base, base);
        // PE code off Windows (tests, which run PE images' VM code on Linux): there is
        // no unwinder to tell, and nothing unwinds through it.
        if (cfg!(windows) || !mode.pe) && !crate::sys::register_unwind(&unwind) {
            return Err("exiting".into());
        }
    }
    Ok(())
}

/// The address of an image part `r` refers to (`Sym`, `Const`, `Data`), as installed
/// code relocates it and the SSA pipeline bakes it in ([`InlineEnv`]'s `addr`); `None` for other
/// references and symbols out of range.
fn image_ref_addr(img: &Image<'_>, r: Ref) -> Option<usize> {
    let h = img.header();
    let ro = img.bytes().as_ptr() as usize;
    Some(match r {
        Ref::Sym(Sym(s)) if (s as usize) < img.symbols().len() => ro + h.sym_slot(s) as usize,
        Ref::Const(Const(k)) => ro + h.consts.off as usize + k as usize,
        Ref::Data(Data(k)) => h.data as usize + k as usize,
        _ => return None,
    })
}

/// Writes the 32-bit field at the start of `field` as `target` relative to `from`.
fn patch_rel32(field: &mut [u8], from: usize, target: usize) -> Result<(), &'static str> {
    let d = i32::try_from((target as i64).wrapping_sub(from as i64)).map_err(|_| "out of reach")?;
    field[..4].copy_from_slice(&d.to_le_bytes());
    Ok(())
}

/// The mode JIT code of `img` is encoded in: without counters, calling the handlers through
/// `r11` if `far_rt`.
fn jit_mode(img: &Image<'_>, far_rt: bool) -> Mode {
    Mode { counters: false, far_rt, ..img.mode() }
}

/// Writes `line` to stderr, straight to the file descriptor rather than through std's
/// `Stderr`: linked as an rlib (tests), the JIT shares the program's, whose lock a program
/// thread may hold while it waits for this one (`RYO_JIT_SYNC`).
pub(crate) fn log_line(line: &str) {
    crate::sys::write_stderr(line.as_bytes());
}

#[cfg(test)]
mod tests {
    #[test]
    fn no_frame_registration_once_exiting() {
        crate::sys::close_frame_registry();
        // Not a valid `.eh_frame`: once closed, it must not reach the unwinder.
        let u = crate::sys::Unwind::Eh { eh: core::ptr::dangling(), fdes: &[0] };
        assert!(!unsafe { crate::sys::register_unwind(&u) });
        crate::sys::reopen_frame_registry();
    }
}
