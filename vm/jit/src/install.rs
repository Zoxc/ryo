//! The JIT thread's compiler: decodes a function from its image, encodes it again without
//! counters (in another frame layout with `RYO_JIT_SHUFFLE`), builds the OSR entries of its
//! loop heads, and installs the code near the image: code memory, relocation, unwind
//! information, the perf map, and the record's publication (design/jit.md, "Compiling and installing").

use core::ptr;
use core::sync::atomic::AtomicUsize;
use core::sync::atomic::Ordering::{Acquire, Relaxed, Release, SeqCst};
use std::collections::HashMap;
use std::io::Write;
use std::vec::Vec;

use ryo_bytecode::asm::frame::{self, SlotMap};
use ryo_bytecode::asm::osr::OsrEntry;
use ryo_bytecode::asm::{self, FUNC_FAR, FUNC_KINDS, FUNC_NEAR, FUNC_SLOT, Mode, Ref};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};
use ryo_bytecode::image::{
    EhFunc, Image, ImageResolver, JIT_DONE, JitRecord, eh_cie, eh_fde, eh_fde_rows, jit_count, jit_unbiased, pe_handler_data, pe_region_unwind_info,
    pe_unwind_info, pe_with_handler,
};
use ryo_bytecode::jit;
use ryo_bytecode::jit::inline::VmFunc;
use ryo_bytecode::jit::ir::CallTarget;
use ryo_bytecode::jit_abi::{JIT_ENTRY_PREFIX, JitOpt, RtApi};
use ryo_bytecode::{Opcode, reduced, vmem};

mod callees;
mod dump;
mod region;

use callees::{Ext, InlineEnv, IrCache, Name, PoolMem};
use region::{Place, REGION, Region, Span};

/// The page size.
const PAGE: usize = vmem::PAGE;

/// Where a function's code starts in its allocation: 16-aligned, after the entry prefix.
pub(crate) const CODE_AT: usize = 16;
const _: () = assert!(JIT_ENTRY_PREFIX <= CODE_AT);
/// Where the allocation holds the code's length, a `u32` ([`crate::code_len`]): before the
/// entry prefix.
pub(crate) const CODE_LEN_AT: usize = 0;
const _: () = assert!(CODE_LEN_AT + 4 <= CODE_AT - JIT_ENTRY_PREFIX);

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
    Counts { calls: n(JitRecord::ctr_e(rec).load(Acquire), thresholds[0]), iters: n(JitRecord::ctr_l(rec).load(Acquire), thresholds[1]) }
}

/// Whether a compiled record's counters both have its bias (a racing AOT increment can erase
/// it: [`crate::thread`] re-checks).
pub(crate) fn settled(rec: *mut JitRecord) -> bool {
    [JitRecord::ctr_e(rec), JitRecord::ctr_l(rec)].iter().all(|c| {
        let v = c.load(SeqCst);
        v != jit_unbiased(v) && v > 0
    })
}

/// How many functions the SSA tier compiled, and how many it left to the re-encoding
/// pipeline ([`crate::ssa_stats`]).
pub(crate) static SSA_COMPILED: core::sync::atomic::AtomicUsize = core::sync::atomic::AtomicUsize::new(0);
pub(crate) static SSA_FALLBACK: core::sync::atomic::AtomicUsize = core::sync::atomic::AtomicUsize::new(0);
/// How many of the SSA tier's roots' calls through constant pointers became direct
/// ([`crate::ssa_devirt`]).
pub(crate) static SSA_DEVIRT: core::sync::atomic::AtomicUsize = core::sync::atomic::AtomicUsize::new(0);

/// A function's machine code, from either pipeline, before it is installed.
struct Gen {
    code: Vec<u8>,
    relocs: Vec<asm::Reloc>,
    rodata: Vec<u8>,
    call_sites: Vec<asm::CallSite>,
    body: Body,
    osr: Option<asm::osr::OsrCode>,
    osr_at: usize,
    /// PE: where the pad region starts (`code.len()` if there is none, as for the SSA tier's code).
    region: usize,
}

/// The unwind rules of a function's body.
enum Body {
    /// As the encoder lays out frames.
    Aot(EhFunc),
    /// The SSA tier's rows.
    Rows(Vec<(u32, Vec<u8>)>),
    /// The SSA tier's PE `UNWIND_INFO`.
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
    Fail(&'static str),
}

impl From<&'static str> for CompileError {
    fn from(why: &'static str) -> CompileError {
        CompileError::Fail(why)
    }
}

/// Which pipeline compiled a function.
#[derive(Clone, Copy)]
enum Tier {
    Ssa,
    Reencode,
}

impl Tier {
    /// Its name in `RYO_JIT_DUMP`'s `.code` files.
    fn name(self) -> &'static str {
        match self {
            Tier::Ssa => "ssa",
            Tier::Reencode => "reencode",
        }
    }
}

pub(crate) struct Jit {
    rt: &'static RtApi,
    /// The handlers' addresses and opcodes, sorted, for [`ImageResolver`].
    handlers: Vec<(usize, Opcode)>,
    /// The handlers' and the probe's range.
    rt_span: Span,
    regions: Vec<Region>,
    images: HashMap<usize, ImageInfo>,
    perfmap: Option<std::fs::File>,
    /// Call slots: JIT code calls (and tail-calls) a VM function, of any image, that wasn't
    /// compiled yet through an 8-byte slot in its region's read-write end (`call [rip +
    /// slot]`), which holds the function's AOT entry and then its JIT code. By (region start,
    /// image header, function).
    slots: HashMap<(usize, usize, u32), usize>,
    /// The slots by (image header, function), which its publication updates.
    slots_of: HashMap<(usize, u32), Vec<usize>>,
    /// `RYO_JIT_DUMP`: the directory the SSA tier writes a description of each compilation
    /// to.
    dump: Option<String>,
    /// How many functions went to the SSA tier so far ([`ryo_bytecode::jit_abi::JitSettings::ssa_limit`]).
    ssa_tried: u64,
    /// The inliner's callee IR, by (image header, function) ([`InlineEnv`]).
    ir_cache: IrCache,
}

impl Jit {
    pub(crate) fn new(rt: &'static RtApi) -> Jit {
        // The PE form's handlers too, if the runtime has a set of its own (tests off Windows).
        // SAFETY: `pe_handlers` is null or points at the runtime's table.
        let pe = unsafe { rt.pe_handlers.as_ref() };
        let mut handlers: Vec<(usize, Opcode)> = [Some(&rt.handlers), pe]
            .into_iter()
            .flatten()
            .flat_map(|t| t.iter().zip(ryo_bytecode::ALL_OPCODES))
            .filter(|(h, _)| !h.is_null())
            .map(|(&h, &op)| (h as usize, op))
            .collect();
        handlers.sort_unstable();
        // The sets share `resume`.
        handlers.dedup();
        let probe = rt.probe as usize;
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
            handlers,
            rt_span: Span { lo, hi },
            regions: Vec::new(),
            images: HashMap::new(),
            perfmap,
            slots: HashMap::new(),
            slots_of: HashMap::new(),
            dump,
            ssa_tried: 0,
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
            let personality = img.symbols().iter().position(|&s| s == p).map(|i| ro + h.symbols.off as usize + 8 * i);
            ImageInfo { span, personality }
        })
    }

    /// Compiles the function of `rec` and publishes its code.
    pub(crate) fn compile(&mut self, rec: *mut JitRecord) -> Result<(), &'static str> {
        if self.rt.settings.test_panic {
            panic!("RYO_JIT_TEST_PANIC");
        }
        if self.rt.settings.test_oom {
            // `isize::MAX` bytes: a valid layout no allocator can serve.
            let v = Vec::<u8>::with_capacity(std::hint::black_box(usize::MAX / 2));
            std::hint::black_box(&v);
        }
        // Again in a new region if the one it was compiled for filled up (once is enough: the
        // new one is empty, and the function fits half of one).
        let r = match self.compile_once(rec) {
            Err(CompileError::Retry) => self.compile_once(rec),
            r => r,
        };
        r.map_err(|e| match e {
            CompileError::Retry => "region full",
            CompileError::Fail(why) => why,
        })
    }

    fn compile_once(&mut self, rec: *mut JitRecord) -> Result<(), CompileError> {
        // SAFETY: a record of a linked image, whose header it points at.
        let (func, img) = unsafe { ((*rec).func, Image::from_header((*rec).header.cast()).map_err(|_| "invalid image")?) };
        let h = img.header();
        let info = self.image(&img);
        // PE code has no personality: its unwind info names `ryo_seh_handler` instead, as the
        // AOT code's (design/vm.md#pe-seh).
        let personality = if img.mode().pe { 0 } else { info.personality.ok_or("no personality slot")? };
        let place = self.place(info.span).ok_or("no code memory near the image")?;
        // SAFETY: a linked image's text section.
        let text = unsafe { core::slice::from_raw_parts(h.text as usize as *const u8, h.text_size as usize) };
        let res = ImageResolver { image: img, handlers: &self.handlers, probe: self.rt.probe as usize };
        let d = res.decode(func, text).ok_or("no such function")?.map_err(|e| e.what)?;
        let mode = jit_mode(&img, place.far_rt);
        let shuffled = (self.rt.shuffled)(h as *const _ as *const u8);

        // The JIT frame layout: the AOT one, or with `RYO_JIT_SHUFFLE` one that moves every
        // slot it can (frame::shuffle_map), to catch reliance on matching frames.
        let mut map = SlotMap::identity(d.frame_size);
        let mut words = None;
        if shuffled {
            match frame::shuffle_map(&d, mode).and_then(|m| Ok((frame::remap_slots(&d.words, mode, &m)?, m))) {
                Ok((w, m)) => {
                    words = Some(w);
                    map = m;
                }
                Err(e) => {
                    if self.rt.settings.log {
                        self.log(rec, e.what);
                    }
                }
            }
        }
        let mut words = words.unwrap_or_else(|| d.words.clone());
        // Every call but a self-call by its callee's form for the region (design/jit.md,
        // "Calls"): a VM function not compiled yet through a call slot, which holds its JIT
        // code once it is (through its AOT entry, every call would pass the counter check and
        // its stub, and mispredict the entry prefix's `ret`); a known address (compiled JIT
        // code, native code) directly, or through `r11` out of reach.
        let mut ext = Vec::new();
        let mut memo = HashMap::new();
        self.retarget(&mut words, func, &img, place, &mut ext, &mut memo)?;
        // The SSA tier (`RYO_JIT_OPT`), else, or where it doesn't compile the function, the
        // re-encoding pipeline.
        let settings = self.rt.settings;
        // `RYO_JIT_SSA_LIMIT=n` (debugging: bisects a miscompile): only the first `n`
        // functions go through the SSA tier.
        let within_limit = self.ssa_tried < settings.ssa_limit;
        if settings.opt != JitOpt::Reencode && within_limit {
            self.ssa_tried += 1;
            // The AOT layout's words (the SSA tier lays out its own frame); the calls are
            // retargeted as above after inlining, by the same rules.
            if let Some((out, ssa_ext)) = self.compile_ssa(rec, func, &img, &d, mode, shuffled, place)? {
                return self.install(rec, func, &img, place, personality, &ssa_ext, out, Tier::Ssa);
            }
        }
        let out = compile_reencode(&d, &words, &map, &img, mode)?;
        self.install(rec, func, &img, place, personality, &ext, out, Tier::Reencode)
    }

    /// Compiles `d`, the function `func` of `img` (record `rec`), for `place` through the SSA
    /// tier: its code and callees, or `None` where the tier doesn't handle it (the
    /// re-encoding pipeline does).
    #[allow(clippy::too_many_arguments)]
    fn compile_ssa(
        &mut self,
        rec: *mut JitRecord,
        func: u32,
        img: &Image<'_>,
        d: &asm::Decoded,
        mode: Mode,
        shuffled: bool,
        place: Place,
    ) -> Result<Option<(Gen, Vec<Ext>)>, CompileError> {
        let h = img.header();
        let opts = jit::Options {
            alloc: if self.rt.settings.opt == JitOpt::Ssa { jit::Allocator::LinearScan } else { jit::Allocator::Naive },
            stress: shuffled,
            check: self.rt.settings.check,
            dump: self.dump.is_some(),
        };
        let header = h as *const _ as usize;
        let mut env = InlineEnv {
            cache: &mut self.ir_cache,
            handlers: &self.handlers,
            probe: self.rt.probe as usize,
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
                    let _ = std::fs::write(std::format!("{dir}/f{func}-{:x}.txt", h as *const _ as usize), text);
                }
                let len = o.code.len();
                let out = Gen {
                    code: o.code,
                    relocs: o.relocs,
                    rodata: o.rodata,
                    call_sites: o.call_sites,
                    body: if mode.pe { Body::Pe(o.pe_unwind) } else { Body::Rows(o.cfi) },
                    osr: o.osr,
                    osr_at: o.osr_at as usize,
                    region: len,
                };
                SSA_COMPILED.fetch_add(1, Relaxed);
                SSA_DEVIRT.fetch_add(o.devirt, Relaxed);
                Ok(Some((out, ssa_ext)))
            }
            Err(jit::Error::Unsupported(u)) => {
                SSA_FALLBACK.fetch_add(1, Relaxed);
                if let Some(dir) = &self.dump {
                    let text = std::format!("; unsupported: {}\n{}", u.0, reduced::Disasm(&d.words));
                    let _ = std::fs::write(std::format!("{dir}/f{func}-{:x}.txt", h as *const _ as usize), text);
                }
                if self.rt.settings.log {
                    self.log(rec, &std::format!("ssa: {}", u.0));
                }
                Ok(None)
            }
            // A checker found a bug: always on stderr, so that tests see it, and the function
            // stays in its AOT code (`Failed`), which tests that expect JIT code notice.
            Err(jit::Error::Check(why)) => {
                SSA_FALLBACK.fetch_add(1, Relaxed);
                self.log(rec, &std::format!("ssa: check failed: {why}"));
                Err("the SSA tier's checkers failed".into())
            }
        }
    }

    /// Installs the code `out` of the function `func` of `img` (record `rec`), compiled for
    /// the region `place` with the callees `ext`: code memory, relocation, unwind
    /// information, the perf map and the publication.
    #[allow(clippy::too_many_arguments)]
    fn install(
        &mut self,
        rec: *mut JitRecord,
        func: u32,
        img: &Image<'_>,
        place: Place,
        personality: usize,
        ext: &[Ext],
        out: Gen,
        tier: Tier,
    ) -> Result<(), CompileError> {
        let h = img.header();
        let mode = jit_mode(img, place.far_rt);
        let Gen { code: enc_code, mut relocs, rodata, call_sites, body, osr, osr_at, region } = out;
        let code_len = enc_code.len();
        // The OSR code's stack probes, relocated as the body's.
        if let Some(o) = &osr {
            relocs.extend(o.probes.iter().map(|&p| asm::Reloc { at: (osr_at + p as usize) as u32, to: Ref::Probe }));
        }
        let osr_len = osr.as_ref().map_or(0, |o| o.code.len());

        // Unwind information. ELF: the CIE, the FDE, the OSR code's FDE, the terminator, then
        // the LSDA. PE: the `RUNTIME_FUNCTION`s, then their `UNWIND_INFO`s: the body's
        // (`pe_unwind_info`, the AOT code's form, or the SSA tier's own, from the same encoder,
        // `pe_unwind_codes`), over the OSR code too unless a pad region lies between: past the
        // prologue every `rsp` is described by `rbp`, the OSR code's included, which keeps the
        // AOT frame's `rbp`; the pad region's; and if apart, the OSR
        // code's (the body's, all of it past the prologue). The body's and the region's name
        // `ryo_seh_handler` through a thunk after the code, with the LSDA as their handler
        // data (design/jit.md, "Unwinding and profiling"). `pe_rfs`: the entries' ranges in
        // the code and their `UNWIND_INFO`s' offsets in `eh`; `pe_handlers`: the handler RVA
        // fields.
        let mut eh = Vec::new();
        let mut fdes = Vec::new();
        let (mut pers_field, mut fields, mut osr_fields, mut lsda_at) = (0, None, None, 0);
        let mut pe_rfs: Vec<(usize, usize, usize)> = Vec::new();
        let mut pe_handlers = Vec::new();
        if mode.pe {
            let info = match &body {
                Body::Aot(ef) => {
                    if ef.prologue != 0 || ef.entry_stub as usize != region {
                        return Err("PE code with a counter check".into());
                    }
                    pe_unwind_info(ef, mode)
                }
                Body::Pe(info) => info.clone(),
                Body::Rows(_) => return Err("DWARF rows on PE".into()),
            };
            let lsda = asm::lsda::write(&call_sites);
            let has_region = region < code_len;
            let r = if has_region { region as u32 } else { 0 };
            eh.resize(12 * (1 + usize::from(has_region) * (1 + usize::from(osr.is_some()))), 0);
            let mut add = |eh: &mut Vec<u8>, range: (usize, usize), info: &[u8], data: Option<Vec<u8>>| {
                let at = eh.len();
                match data {
                    Some(d) => {
                        let (bytes, field) = pe_with_handler(info, &d);
                        pe_handlers.push(at + field);
                        eh.extend_from_slice(&bytes);
                    }
                    None => eh.extend_from_slice(info),
                }
                pe_rfs.push((range.0, range.1, at));
            };
            let body_end = if has_region {
                region
            } else if osr.is_some() {
                osr_at + osr_len
            } else {
                code_len
            };
            add(&mut eh, (0, body_end), &info, Some(pe_handler_data(0, r, &lsda)));
            if has_region {
                add(&mut eh, (region, code_len), &pe_region_unwind_info(), Some(pe_handler_data(r, r, &lsda)));
                if osr.is_some() {
                    // Never in its prologue: the codes apply from its first byte.
                    let mut past = info.clone();
                    past[1] = 0;
                    add(&mut eh, (osr_at, osr_at + osr_len), &past, None);
                }
            }
        } else {
            pers_field = eh_cie(&mut eh);
            fdes.push(eh.len());
            fields = Some(match &body {
                Body::Aot(ef) => eh_fde(&mut eh, 0, ef, mode),
                Body::Rows(rows) => eh_fde_rows(&mut eh, 0, code_len as u32, rows),
                Body::Pe(_) => return Err("PE unwind info off PE".into()),
            });
            if osr.is_some() {
                fdes.push(eh.len());
            }
            osr_fields = osr.as_ref().map(|o| eh_fde_rows(&mut eh, 0, o.code.len() as u32, &o.cfi));
            eh.extend_from_slice(&[0; 4]);
            lsda_at = eh.len();
            eh.extend_from_slice(&asm::lsda::write(&call_sites));
        }

        // Code memory: the entry prefix, the code, the OSR code, on PE the handler's thunk
        // (`jmp [rip]; .quad ryo_seh_handler`), then its code constants.
        let thunk_at = (CODE_AT + osr_at + osr_len).next_multiple_of(16);
        let ro_at = if mode.pe { thunk_at + 16 } else { thunk_at };
        let size = (ro_at + rodata.len()).next_multiple_of(PAGE);
        let eh_size = eh.len().next_multiple_of(16);
        if size + eh_size > REGION / 2 {
            return Err("too large".into());
        }
        let header = h as *const _ as usize;
        let start = place.start;
        // The callees the code calls: the inliner may have given call forms to calls it then
        // inlined, or of callees it explored only.
        let mut used = std::vec![false; ext.len()];
        for r in &relocs {
            if let Ref::Func(Func(g)) = r.to
                && g & FUNC_KINDS != 0
                && let Some(u) = used.get_mut((g & !FUNC_KINDS) as usize)
            {
                *u = true;
            }
        }
        let new_slots =
            ext.iter().zip(&used).filter_map(|(e, &u)| e.vm.filter(|_| u)).filter(|&(hd, g)| !self.slots.contains_key(&(start, hd, g))).count();
        let region = self.regions.iter_mut().find(|r| r.start == start).ok_or(CompileError::Retry)?;
        if region.code + size + eh_size + 8 * new_slots > region.data {
            // Full: retire it (it reaches nothing any more), and compile again for another.
            region.data = region.code;
            region.start = usize::MAX;
            region.end = usize::MAX;
            return Err(CompileError::Retry);
        }
        let base = region.code;
        region.code += size;
        region.data -= eh_size;
        let eh_base = region.data;
        // The call slots, from the region's end too: the callee's JIT code if it was compiled
        // meanwhile (publication is this thread's), else its AOT entry.
        let mut slot_of = std::vec![0; ext.len()];
        for (k, e) in ext.iter().enumerate() {
            let Some((hd, g)) = e.vm.filter(|_| used[k]) else { continue };
            slot_of[k] = *self.slots.entry((start, hd, g)).or_insert_with(|| {
                region.data -= 8;
                debug_assert!(region.data % 8 == 0, "call slots are 8-aligned (atomic stores)");
                // SAFETY: `Ext::vm` names a registered image's function with a record.
                let gr = unsafe { Image::from_header(hd as *const u8) }.expect("a registered image").jit_records().wrapping_add(g as usize);
                let target = if JitRecord::state(gr).load(Acquire) == JIT_DONE {
                    // SAFETY: published before `Done`.
                    unsafe { (*gr).jit_code as usize }
                } else {
                    e.addr
                };
                // SAFETY: the region's read-write end, which nothing else uses.
                unsafe { (region.data as *mut usize).write(target) };
                self.slots_of.entry((hd, g)).or_default().push(region.data);
                region.data
            });
        }

        let mut code = std::vec![0xccu8; size];
        // `lea r11, [rip + code]; mov [rsp], r11; ret` (JIT_ENTRY_PREFIX).
        let lea = (JIT_ENTRY_PREFIX - 7) as i32;
        let mut prefix = std::vec![0x4c, 0x8d, 0x1d];
        prefix.extend(lea.to_le_bytes());
        prefix.extend([0x4c, 0x89, 0x1c, 0x24, 0xc3]);
        code[CODE_LEN_AT..][..4].copy_from_slice(&(code_len as u32).to_le_bytes());
        code[CODE_AT - JIT_ENTRY_PREFIX..CODE_AT].copy_from_slice(&prefix);
        code[CODE_AT..][..code_len].copy_from_slice(&enc_code);
        if let Some(o) = &osr {
            code[CODE_AT + osr_at..][..o.code.len()].copy_from_slice(&o.code);
        }
        code[ro_at..][..rodata.len()].copy_from_slice(&rodata);
        let jit_f = base + CODE_AT;
        let fs = img.functions();
        // The handlers of the image's form: PE code's own set if the runtime has one.
        let (hs, rhs) = match (img.mode().pe, self.rt.pe_handlers.is_null()) {
            // SAFETY: the runtime's tables, non-null.
            (true, false) => unsafe { (&*self.rt.pe_handlers, &*self.rt.pe_reg_handlers) },
            _ => (&self.rt.handlers, &self.rt.reg_handlers),
        };
        for r in &relocs {
            let field = jit_f + r.at as usize;
            // Fields of 8 bytes: an `imm64` of a call through `r11`.
            let abs = match r.to {
                Ref::Handler(_) | Ref::RegHandler(_) | Ref::Probe => place.far_rt,
                Ref::Func(Func(g)) => g & FUNC_KINDS == FUNC_FAR,
                _ => false,
            };
            let target = match r.to {
                Ref::Handler(op) => Some(hs[op as usize]).filter(|h| !h.is_null()).ok_or("no handler")? as usize,
                Ref::RegHandler(op) => Some(rhs[op as usize]).filter(|h| !h.is_null()).ok_or("no register entry")? as usize,
                Ref::Probe => self.rt.probe as usize,
                Ref::Func(Func(g)) if g == func => jit_f,
                Ref::Func(Func(g)) if g & FUNC_KINDS != 0 => {
                    let k = (g & !FUNC_KINDS) as usize;
                    if g & FUNC_KINDS == FUNC_SLOT { slot_of[k] } else { ext[k].addr }
                }
                // Every other call was retargeted.
                Ref::Func(_) => return Err("an unexpected call".into()),
                Ref::Sym(_) | Ref::Site(_) | Ref::Const(_) | Ref::Data(_) => image_ref_addr(img, r.to).ok_or("no such symbol")?,
                Ref::Ro(o) => base + ro_at + o as usize,
                Ref::Rec => rec as usize,
                Ref::RecLoopCtr => rec as usize + ryo_bytecode::image::JIT_LOOP_CTR as usize,
            };
            if abs {
                code[field - base..][..8].copy_from_slice(&(target as u64).to_le_bytes());
            } else {
                patch_rel32(&mut code[field - base..], field + 4, target)?;
            }
        }
        if let Some(dir) = &self.dump {
            self.dump_code(dir, func, header, ext, &enc_code, &relocs, osr.as_ref().map(|o| (osr_at, o)), tier);
        }
        // `.eh_frame`'s PC-relative fields: relative to the field itself.
        let pc = |eh: &mut Vec<u8>, at: usize, target: usize| patch_rel32(&mut eh[at..], eh_base + at, target);
        if let Some(fields) = fields {
            pc(&mut eh, pers_field, personality)?;
            pc(&mut eh, fields.pc_begin, jit_f)?;
            pc(&mut eh, fields.lsda, eh_base + lsda_at)?;
        }
        if let Some(f) = osr_fields {
            pc(&mut eh, f.pc_begin, jit_f + osr_at)?;
        }
        if mode.pe {
            // The `RUNTIME_FUNCTION`s and the handler fields: offsets from `base`, below the
            // region's read-write end.
            let rva = |a: usize| u32::try_from(a - base).map_err(|_| "out of reach");
            for (k, &(begin, end, at)) in pe_rfs.iter().enumerate() {
                for (j, v) in [rva(jit_f + begin)?, rva(jit_f + end)?, rva(eh_base + at)?].iter().enumerate() {
                    eh[12 * k + 4 * j..][..4].copy_from_slice(&v.to_le_bytes());
                }
            }
            let thunk = base + thunk_at;
            for &f in &pe_handlers {
                eh[f..f + 4].copy_from_slice(&rva(thunk)?.to_le_bytes());
            }
            code[thunk_at..][..6].copy_from_slice(&[0xff, 0x25, 0, 0, 0, 0]);
            code[thunk_at + 6..][..8].copy_from_slice(&(self.rt.seh_handler as u64).to_le_bytes());
        }

        // SAFETY: fresh read-write memory of the region, `size` and `eh.len()` bytes, which
        // nothing else uses; the code pages become executable only once written, and are
        // never written again.
        unsafe {
            ptr::copy_nonoverlapping(code.as_ptr(), base as *mut u8, size);
            ptr::copy_nonoverlapping(eh.as_ptr(), eh_base as *mut u8, eh.len());
            if !vmem::make_executable(base as *mut u8, size) {
                return Err("make_executable".into());
            }
            // Unregistered, the code must not run: nothing could unwind through it. At exit
            // it isn't needed.
            let unwind = if mode.pe {
                crate::sys::Unwind { eh: ptr::null(), fdes: &[], code: (base, base + size), pdata: (eh_base as *const u8, pe_rfs.len() as u32) }
            } else {
                crate::sys::Unwind { eh: eh_base as *const u8, fdes: &fdes, code: (base, base + size), pdata: (ptr::null(), 0) }
            };
            // PE code off Windows (tests, which run PE images' VM code on Linux): there is
            // no unwinder to tell, and nothing unwinds through it.
            if (cfg!(windows) || !mode.pe) && !crate::sys::register_unwind(&unwind) {
                return Err("exiting".into());
            }
        }
        if let Some(m) = &mut self.perfmap {
            let aot = h.text as usize + fs[func as usize].code_off as usize;
            let _ = writeln!(m, "{jit_f:x} {:x} ryo-jit:f{func}@{aot:x}", code_len);
        }

        // Nothing allocates from the publication on: a panic past it (an allocation failure,
        // `thread::oom_panics`) would report a published record as failed.
        let line = self.rt.settings.log.then(|| {
            let c = counts(rec, self.rt.thresholds);
            self.log_text(rec, &std::format!("compiled ({}, {} calls, {} loop iterations)", tier.name(), c.calls, c.iters))
        });
        // The dispatcher, at the start of the OSR code: every head's stub calls it from now.
        let osr_entry = osr.as_ref().map(|_| (jit_f + osr_at) as *mut u8);
        // SAFETY: the record is this thread's until `Done`.
        unsafe { JitRecord::publish(rec, jit_f as *const u8, (jit_f - JIT_ENTRY_PREFIX) as *mut u8, osr_entry) };
        // Calls of this function from JIT code compiled before it, of any image, go straight
        // to it now.
        for &slot in self.slots_of.get(&(header, func)).map_or(&[][..], |v| &v[..]) {
            // SAFETY: a call slot, 8-aligned, which JIT code reads with plain loads (an atomic
            // store of its size).
            unsafe { AtomicUsize::from_ptr(slot as *mut usize).store(jit_f, Release) };
        }
        if let Some(line) = line {
            log_line(&line);
        }
        Ok(())
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

/// The address of an image part `r` refers to (`Sym`, `Site`, `Const`, `Data`), as installed
/// code relocates it and the SSA tier bakes it in ([`InlineEnv`]'s `addr`); `None` for other
/// references and symbols out of range.
fn image_ref_addr(img: &Image<'_>, r: Ref) -> Option<usize> {
    let h = img.header();
    let ro = img.bytes().as_ptr() as usize;
    Some(match r {
        Ref::Sym(Sym(s)) if (s as usize) < img.symbols().len() => ro + h.symbols.off as usize + 8 * s as usize,
        Ref::Site(Site(s)) => h.data as usize + 8 * s as usize,
        Ref::Const(Const(k)) => ro + h.consts.off as usize + k as usize,
        Ref::Data(Data(k)) => h.data as usize + h.fixup_area as usize + k as usize,
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

/// The re-encoding pipeline: `d`'s reduced code `words`, retargeted and in the frame layout
/// `map`, encoded again without counters, with OSR entries for its loop heads.
fn compile_reencode(d: &asm::Decoded, words: &[u32], map: &SlotMap, img: &Image<'_>, mode: Mode) -> Result<Gen, CompileError> {
    // Scopes keep their bytes' new offsets; an end over bytes that move apart only ends
    // escapes, which stay, so it is dropped (scopes are side data, not code).
    let scopes: Vec<asm::Scope> =
        d.scopes.iter().filter_map(|sc| Some(asm::Scope { frame_offset: map.map_range(sc.frame_offset, sc.size)?, ..*sc })).collect();
    let (enc, starts) =
        asm::encode_reduced_at(words, map.frame_size, &d.cleanup, &scopes, &d.dropped, img.code_consts(), mode).map_err(|_| "encode")?;

    // OSR entries, one per AOT loop head, landing at the head in the JIT code. Values
    // move where the layouts differ and the head's liveness says they matter.
    let live = if map.is_identity() { Vec::new() } else { frame::head_liveness(d, mode).map_err(|e| e.what)? };
    let mut entries = Vec::with_capacity(d.heads.len());
    for (n, &hd) in d.heads.iter().enumerate() {
        // An `arg` reads an argument register and an `lpad` the exception object in
        // `rax`, which a head's stub doesn't keep: no entry there.
        let w = &words[hd as usize..];
        let enterable = match reduced::Opcode::from_u16(w[0] as u16) {
            Some(reduced::Opcode::Arg) => false,
            Some(reduced::Opcode::Handler) => w[1] != Opcode::Lpad as u32,
            _ => true,
        };
        let landing = starts.binary_search_by_key(&hd, |s| s.0).map(|i| starts[i].1).map_err(|_| "loop head")?;
        entries.push(enterable.then(|| OsrEntry { landing, moves: live.get(n).map(|l| frame::osr_moves(l, map)).unwrap_or_default() }));
    }
    let osr_at = enc.code.len().next_multiple_of(16);
    let osr = (!entries.is_empty()).then(|| asm::osr::osr_code(&entries, d.frame_size, map.frame_size, mode, osr_at as u32));
    let ef = EhFunc { len: enc.code.len() as u32, frame_size: map.frame_size, prologue: enc.prologue, entry_stub: enc.entry_stub };
    Ok(Gen {
        code: enc.code,
        relocs: enc.relocs,
        rodata: enc.rodata,
        call_sites: enc.call_sites,
        body: Body::Aot(ef),
        osr,
        osr_at,
        region: enc.region as usize,
    })
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
        let u = crate::sys::Unwind { eh: core::ptr::dangling(), fdes: &[0], code: (0, 0), pdata: (core::ptr::dangling(), 1) };
        assert!(!unsafe { crate::sys::register_unwind(&u) });
        crate::sys::reopen_frame_registry();
    }
}
