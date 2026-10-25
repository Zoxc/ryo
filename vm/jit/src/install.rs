//! The JIT thread's compiler: decodes a function from its image, encodes it again without
//! counters (in another frame layout with `RYO_JIT_SHUFFLE`), builds the OSR entries of its
//! loop heads, and installs the code near the image: code memory, relocation, unwind
//! information, the perf map, and the record's publication (design/jit.md, "Compiling and installing").

use core::ffi::{c_int, c_void};
use core::ptr;
use core::sync::atomic::Ordering::{Acquire, Release, SeqCst};
use core::sync::atomic::{AtomicI64, AtomicPtr, AtomicU32};
use std::collections::HashMap;
use std::io::Write;
use std::vec::Vec;

use ryo_bytecode::asm::frame::{self, SlotMap};
use ryo_bytecode::asm::osr::OsrEntry;
use ryo_bytecode::asm::{self, Mode, Ref};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};
use ryo_bytecode::image::{EhFunc, Image, ImageResolver, JIT_DONE, JitRecord, eh_cie, eh_fde, eh_fde_rows, jit_count, jit_settle, jit_unbiased};
use ryo_bytecode::jit;
use ryo_bytecode::jit_abi::{JIT_CHECK, JIT_ENTRY_PREFIX, JIT_LOG, JIT_OPT_SSA, JIT_OPT_SSA_NAIVE, JIT_TEST_PANIC, RtApi};
use ryo_bytecode::{Opcode, reduced};

/// The page size (x86_64).
const PAGE: usize = 4096;

/// The size of a code region: one mapping that code (from the start, in pages, made
/// executable once written) and unwind information (from the end, read-write) are taken from.
const REGION: usize = 32 << 20;
/// How far apart a 32-bit PC-relative field and its target may be, with a margin.
const REACH: usize = (1 << 31) - (1 << 20);
/// Where a function's code starts in its allocation: 16-aligned, after the entry prefix.
const CODE_AT: usize = 16;
const _: () = assert!(JIT_ENTRY_PREFIX <= CODE_AT);

const PROT_READ: c_int = 1;
const PROT_WRITE: c_int = 2;
const PROT_EXEC: c_int = 4;
const MAP_PRIVATE: c_int = 0x02;
const MAP_ANONYMOUS: c_int = 0x20;
const MAP_NORESERVE: c_int = 0x4000;
const MAP_FIXED_NOREPLACE: c_int = 0x10_0000;
const MAP_FAILED: *mut c_void = !0usize as *mut c_void;

unsafe extern "C" {
    fn mmap(addr: *mut c_void, len: usize, prot: c_int, flags: c_int, fd: c_int, off: i64) -> *mut c_void;
    fn munmap(addr: *mut c_void, len: usize) -> c_int;
    fn mprotect(addr: *mut c_void, len: usize, prot: c_int) -> c_int;
    fn getpid() -> c_int;
    fn write(fd: c_int, buf: *const c_void, n: usize) -> isize;
    /// libgcc's: registers an `.eh_frame` (terminated by a zero word) with the unwinder.
    fn __register_frame(begin: *const u8);
}

// The record's fields the JIT shares with the trips and the counter checks, which read and
// write them with plain instructions: atomics of their size.
fn ctr_e(r: *mut JitRecord) -> &'static AtomicI64 {
    // SAFETY: records live in images' writable sections forever; the counters are 8-aligned.
    unsafe { AtomicI64::from_ptr(&raw mut (*r).ctr_e) }
}
fn ctr_l(r: *mut JitRecord) -> &'static AtomicI64 {
    // SAFETY: as for `ctr_e`.
    unsafe { AtomicI64::from_ptr(&raw mut (*r).ctr_l) }
}
fn entry(r: *mut JitRecord) -> &'static AtomicPtr<u8> {
    // SAFETY: as for `ctr_e`.
    unsafe { AtomicPtr::from_ptr((&raw mut (*r).entry).cast::<*mut u8>()) }
}
fn osr_slot(r: *mut JitRecord) -> &'static AtomicPtr<u8> {
    // SAFETY: as for `ctr_e`.
    unsafe { AtomicPtr::from_ptr((&raw mut (*r).osr).cast::<*mut u8>()) }
}
fn state(r: *mut JitRecord) -> &'static AtomicU32 {
    // SAFETY: as for `ctr_e`.
    unsafe { &(*r).state }
}

/// The length of each installed function's code, by record address ([`crate::code_len`]).
pub(crate) static CODE_LEN: std::sync::Mutex<Option<HashMap<usize, usize>>> = std::sync::Mutex::new(None);

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
    Counts { calls: n(ctr_e(rec).load(Acquire), thresholds[0]), iters: n(ctr_l(rec).load(Acquire), thresholds[1]) }
}

/// Moves `rec`'s counters to its state's bias ([`jit_settle`]).
pub(crate) fn settle(rec: *mut JitRecord) {
    for c in [ctr_e(rec), ctr_l(rec)] {
        jit_settle(c, || state(rec).load(SeqCst));
    }
}

/// Whether a compiled record's counters both have its bias (a racing AOT increment can erase
/// it: [`crate::thread`] re-checks).
pub(crate) fn settled(rec: *mut JitRecord) -> bool {
    [ctr_e(rec), ctr_l(rec)].iter().all(|c| {
        let v = c.load(SeqCst);
        v != jit_unbiased(v) && v > 0
    })
}

/// How many functions the SSA tier compiled, and how many it left to the re-encoding
/// pipeline ([`crate::ssa_stats`]).
pub(crate) static SSA_COMPILED: core::sync::atomic::AtomicUsize = core::sync::atomic::AtomicUsize::new(0);
pub(crate) static SSA_FALLBACK: core::sync::atomic::AtomicUsize = core::sync::atomic::AtomicUsize::new(0);

/// A function's machine code, from either pipeline, before it is installed.
struct Gen {
    len: usize,
    code: Vec<u8>,
    relocs: Vec<asm::Reloc>,
    rodata: Vec<u8>,
    call_sites: Vec<asm::CallSite>,
    body: Body,
    osr: Option<asm::osr::OsrCode>,
    osr_at: usize,
}

/// The unwind rules of a function's body.
enum Body {
    /// As the encoder lays out frames.
    Aot(EhFunc),
    /// The SSA tier's rows.
    Rows(Vec<(u32, Vec<u8>)>),
}

/// An address range `lo..hi` that code must reach with 32-bit PC-relative fields.
#[derive(Clone, Copy)]
struct Span {
    lo: usize,
    hi: usize,
}

/// A mapping near some images ([`REGION`]): code is taken from `code` up, unwind
/// information from `data` down.
struct Region {
    start: usize,
    end: usize,
    code: usize,
    data: usize,
}

impl Region {
    /// Whether all of the region reaches all of `s`.
    fn reaches(&self, s: Span) -> bool {
        reaches(self.start, self.end, s)
    }
}

fn reaches(start: usize, end: usize, s: Span) -> bool {
    s.hi.saturating_sub(start) <= REACH && end.saturating_sub(s.lo) <= REACH
}

/// What the JIT knows about an image: its range, and its `rust_eh_personality` slot.
#[derive(Clone, Copy)]
struct ImageInfo {
    span: Span,
    personality: Option<usize>,
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
    /// Call slots: JIT code calls a function of its image that wasn't compiled yet through an
    /// 8-byte slot in its region's read-write end (`call [rip + slot]`), which holds the
    /// function's AOT entry and then its JIT code. By (region start, image header, function).
    slots: HashMap<(usize, usize, u32), usize>,
    /// `RYO_JIT_DUMP`: the directory the SSA tier writes a description of each compilation
    /// to.
    dump: Option<String>,
    /// `RYO_JIT_SSA_LIMIT`, and how many functions went to the SSA tier so far.
    ssa_limit: Option<usize>,
    ssa_tried: usize,
    /// The inliner's callee IR, by (image header, function) ([`InlineEnv`]).
    ir_cache: IrCache,
}

/// Callee IR for the inliner, built once per function ([`jit::inline::Env::ir`]).
type IrCache = HashMap<(usize, u32), Option<std::rc::Rc<jit::ir::Func>>>;

/// At most this many functions' IR stay cached; the cache starts over past it.
const IR_CACHE_MAX: usize = 4096;

/// What the inliner gets for a compilation: the cache, the image's decoder, and the call
/// slots the unit's calls go through (`callees`, symbols from `nsyms`).
struct InlineEnv<'a, 'b> {
    cache: &'a mut IrCache,
    res: &'a ImageResolver<'b>,
    text: &'a [u8],
    mode: Mode,
    header: usize,
    root: u32,
    recs: *mut JitRecord,
    nrecs: u32,
    nsyms: u32,
    callees: Vec<u32>,
}

impl jit::inline::Env for InlineEnv<'_, '_> {
    fn root(&self) -> Func {
        Func(self.root)
    }

    fn ir(&mut self, g: Func) -> Option<std::rc::Rc<jit::ir::Func>> {
        if let Some(f) = self.cache.get(&(self.header, g.0)) {
            return f.clone();
        }
        if self.cache.len() >= IR_CACHE_MAX {
            self.cache.clear();
        }
        let f = match self.res.decode(g.0, self.text) {
            Some(Ok(d)) => jit::ir_of(&d, self.mode).ok().map(std::rc::Rc::new),
            _ => None,
        };
        self.cache.insert((self.header, g.0), f.clone());
        f
    }

    fn retarget(&mut self, g: Func) -> Option<Sym> {
        let done = g.0 < self.nrecs && state(self.recs.wrapping_add(g.0 as usize)).load(Acquire) == JIT_DONE;
        if done {
            return None;
        }
        let k = self.callees.iter().position(|&c| c == g.0).unwrap_or_else(|| {
            self.callees.push(g.0);
            self.callees.len() - 1
        });
        Some(Sym(self.nsyms + k as u32))
    }
}

impl Jit {
    pub(crate) fn new(rt: &'static RtApi) -> Jit {
        let mut handlers: Vec<(usize, Opcode)> =
            rt.handlers.iter().zip(ryo_bytecode::ALL_OPCODES).filter(|(h, _)| !h.is_null()).map(|(&h, &op)| (h as usize, op)).collect();
        handlers.sort_unstable_by_key(|h| h.0);
        let probe = rt.probe as usize;
        let lo = handlers.first().map_or(probe, |h| h.0).min(probe);
        let hi = handlers.last().map_or(probe, |h| h.0).max(probe) + PAGE;
        let perfmap = (rt.flags & ryo_bytecode::jit_abi::JIT_PERFMAP != 0)
            .then(|| {
                // SAFETY: always safe to call.
                let pid = unsafe { getpid() };
                std::fs::OpenOptions::new().create(true).append(true).open(std::format!("/tmp/perf-{pid}.map")).ok()
            })
            .flatten();
        let dump = std::env::var("RYO_JIT_DUMP").ok().filter(|d| !d.is_empty());
        let ssa_limit = std::env::var("RYO_JIT_SSA_LIMIT").ok().and_then(|n| n.parse().ok());
        Jit {
            rt,
            handlers,
            rt_span: Span { lo, hi },
            regions: Vec::new(),
            images: HashMap::new(),
            perfmap,
            slots: HashMap::new(),
            dump,
            ssa_limit,
            ssa_tried: 0,
            ir_cache: HashMap::new(),
        }
    }

    fn image(&mut self, img: &Image<'_>) -> ImageInfo {
        let rt = self.rt_span;
        let p = self.rt.personality as u64;
        *self.images.entry(img.header() as *const _ as usize).or_insert_with(|| {
            let h = img.header();
            let ro = img.bytes().as_ptr() as usize;
            let ends =
                [(ro, h.size as usize), (h.data as usize, h.data_size as usize), (h.text as usize, h.text_size as usize), (rt.lo, rt.hi - rt.lo)];
            let span = Span { lo: ends.iter().map(|e| e.0).min().unwrap_or(0), hi: ends.iter().map(|e| e.0 + e.1).max().unwrap_or(0) };
            let personality = img.symbols().iter().position(|&s| s == p).map(|i| ro + h.symbols.off as usize + 8 * i);
            ImageInfo { span, personality }
        })
    }

    /// A region that reaches `s`, mapping a new one if none does.
    fn region(&mut self, s: Span) -> Option<&mut Region> {
        if let Some(i) = self.regions.iter().position(|r| r.reaches(s)) {
            return Some(&mut self.regions[i]);
        }
        const STEP: usize = 2 << 20;
        let above = s.hi.next_multiple_of(STEP);
        let below = (s.lo & !(STEP - 1)).checked_sub(REGION);
        for k in 0..(REACH / REGION) {
            for hint in [above.checked_add(k * REGION), below.and_then(|b| b.checked_sub(k * REGION))].into_iter().flatten() {
                if !reaches(hint, hint + REGION, s) {
                    continue;
                }
                // SAFETY: a new private mapping, never over an existing one (`NOREPLACE`).
                let p = unsafe {
                    mmap(
                        hint as *mut c_void,
                        REGION,
                        PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE | MAP_FIXED_NOREPLACE,
                        -1,
                        0,
                    )
                };
                if p == MAP_FAILED {
                    continue;
                }
                let p = p as usize;
                // A kernel without `MAP_FIXED_NOREPLACE` takes the address as a hint only.
                if !reaches(p, p + REGION, s) {
                    // SAFETY: the mapping just made.
                    unsafe { munmap(p as *mut c_void, REGION) };
                    continue;
                }
                self.regions.push(Region { start: p, end: p + REGION, code: p, data: p + REGION });
                return self.regions.last_mut();
            }
        }
        None
    }

    /// Compiles the function of `rec` and publishes its code.
    pub(crate) fn compile(&mut self, rec: *mut JitRecord) -> Result<(), &'static str> {
        if self.rt.flags & JIT_TEST_PANIC != 0 {
            panic!("RYO_JIT_TEST_PANIC");
        }
        // SAFETY: a record of a linked image, whose header it points at.
        let (func, img) = unsafe { ((*rec).func, Image::from_header((*rec).header.cast()).map_err(|_| "invalid image")?) };
        let h = img.header();
        if img.mode().pe {
            return Err("PE");
        }
        let info = self.image(&img);
        let personality = info.personality.ok_or("no personality slot")?;
        // SAFETY: a linked image's text section.
        let text = unsafe { core::slice::from_raw_parts(h.text as usize as *const u8, h.text_size as usize) };
        let res = ImageResolver { image: img, handlers: &self.handlers, probe: self.rt.probe as usize };
        let d = res.decode(func, text).ok_or("no such function")?.map_err(|e| e.what)?;
        let mode = Mode { counters: false, ..img.mode() };

        // The JIT frame layout: the AOT one, or with `RYO_JIT_SHUFFLE` one that moves every
        // slot it can (frame::shuffle_map), to catch reliance on matching frames.
        let mut map = SlotMap::identity(d.frame_size);
        let mut words = None;
        if (self.rt.shuffled)(h as *const _ as *const u8) {
            match frame::shuffle_map(&d, mode).and_then(|m| Ok((frame::remap_slots(&d.words, mode, &m)?, m))) {
                Ok((w, m)) => {
                    words = Some(w);
                    map = m;
                }
                Err(e) => {
                    if self.rt.flags & JIT_LOG != 0 {
                        self.log(rec, e.what);
                    }
                }
            }
        }
        let mut words = words.unwrap_or_else(|| d.words.clone());
        // Calls of functions of the image that aren't compiled yet go through call slots, as
        // `call.sym`s of symbols past the image's, which hold their JIT code once they are:
        // through their AOT entries, every call would pass the counter check and its stub,
        // and mispredict the entry prefix's `ret`.
        let nsyms = h.symbols.count;
        let recs = img.jit_records();
        let mut callees: Vec<u32> = Vec::new();
        let mut at = 0;
        while at < words.len() {
            if words[at] == reduced::Opcode::Call as u32 {
                let g = words[at + 2];
                let done = g < h.jit_records.count && state(recs.wrapping_add(g as usize)).load(Acquire) == JIT_DONE;
                if g != func && !done {
                    let k = callees.iter().position(|&c| c == g).unwrap_or_else(|| {
                        callees.push(g);
                        callees.len() - 1
                    });
                    words[at] = reduced::Opcode::CallSym as u32;
                    words[at + 2] = nsyms + k as u32;
                }
            }
            at += reduced::insn_len(&words[at..]).map_err(|_| "reduced code")?;
        }
        // The SSA tier (`RYO_JIT_OPT`), else, or where it doesn't compile the function, the
        // re-encoding pipeline.
        let flags = self.rt.flags;
        // `RYO_JIT_SSA_LIMIT=n` (debugging: bisects a miscompile): only the first `n`
        // functions go through the SSA tier.
        let within_limit = self.ssa_limit.is_none_or(|n| self.ssa_tried < n);
        if flags & (JIT_OPT_SSA | JIT_OPT_SSA_NAIVE) != 0 && within_limit {
            self.ssa_tried += 1;
            let opts = jit::Options {
                alloc: if flags & JIT_OPT_SSA != 0 { jit::Allocator::LinearScan } else { jit::Allocator::Naive },
                stress: (self.rt.shuffled)(h as *const _ as *const u8),
                check: flags & JIT_CHECK != 0,
                dump: self.dump.is_some(),
            };
            // The AOT layout's words (the SSA tier lays out its own frame); calls of functions
            // not compiled yet go through call slots as above, retargeted after inlining.
            let ds = &d;
            let header = h as *const _ as usize;
            let mut env = InlineEnv {
                cache: &mut self.ir_cache,
                res: &res,
                text,
                mode,
                header,
                root: func,
                recs,
                nrecs: h.jit_records.count,
                nsyms,
                callees: Vec::new(),
            };
            let r = jit::compile(ds, img.code_consts(), mode, &opts, Some(&mut env));
            let ssa_callees = env.callees;
            match r {
                Ok(mut o) => {
                    if let (Some(dir), Some(text)) = (&self.dump, o.dump.take()) {
                        let _ = std::fs::write(std::format!("{dir}/f{func}-{:x}.txt", h as *const _ as usize), text);
                    }
                    let out = Gen {
                        len: o.code.len(),
                        code: o.code,
                        relocs: o.relocs,
                        rodata: o.rodata,
                        call_sites: o.call_sites,
                        body: Body::Rows(o.cfi),
                        osr: o.osr,
                        osr_at: o.osr_at as usize,
                    };
                    SSA_COMPILED.fetch_add(1, SeqCst);
                    return self.install(rec, func, &img, info, personality, &ssa_callees, out, "compiled (ssa)");
                }
                Err(jit::Error::Unsupported(u)) => {
                    SSA_FALLBACK.fetch_add(1, SeqCst);
                    if let Some(dir) = &self.dump {
                        let text = std::format!("; unsupported: {}\n{}", u.0, reduced::Disasm(&ds.words));
                        let _ = std::fs::write(std::format!("{dir}/f{func}-{:x}.txt", h as *const _ as usize), text);
                    }
                    if flags & JIT_LOG != 0 {
                        self.log(rec, &std::format!("ssa: {}", u.0));
                    }
                }
                // A checker found a bug: always on stderr, so that tests see it, and the function
                // stays in its AOT code (`Failed`), which tests that expect JIT code notice.
                Err(jit::Error::Check(why)) => {
                    SSA_FALLBACK.fetch_add(1, SeqCst);
                    self.log(rec, &std::format!("ssa: check failed: {why}"));
                    return Err("the SSA tier's checkers failed");
                }
            }
        }
        let words = &words[..];
        // Scopes keep their bytes' new offsets; an end over bytes that move apart only ends
        // escapes, which stay, so it is dropped (scopes are side data, not code).
        let scopes: Vec<asm::Scope> =
            d.scopes.iter().filter_map(|sc| Some(asm::Scope { frame_offset: map.map_range(sc.frame_offset, sc.size)?, ..*sc })).collect();
        let (enc, starts) =
            asm::encode_reduced_at(words, map.frame_size, &d.cleanup, &scopes, &d.dropped, img.code_consts(), mode).map_err(|_| "encode")?;

        // OSR entries, one per AOT loop head, landing at the head in the JIT code. Values
        // move where the layouts differ and the head's liveness says they matter.
        let live = if map.is_identity() { Vec::new() } else { frame::head_liveness(&d, mode).map_err(|e| e.what)? };
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
            entries.push(enterable.then(|| OsrEntry { landing, moves: live.get(n).map(|l| frame::osr_moves(l, &map)).unwrap_or_default() }));
        }
        let osr_at = enc.code.len().next_multiple_of(16);
        let osr = (!entries.is_empty()).then(|| asm::osr::osr_code(&entries, d.frame_size, map.frame_size, mode, osr_at as u32));
        let ef = EhFunc { len: enc.code.len() as u32, frame_size: map.frame_size, prologue: enc.prologue, entry_stub: enc.entry_stub };
        let out = Gen {
            len: enc.code.len(),
            code: enc.code,
            relocs: enc.relocs,
            rodata: enc.rodata,
            call_sites: enc.call_sites,
            body: Body::Aot(ef),
            osr,
            osr_at,
        };
        self.install(rec, func, &img, info, personality, &callees, out, "compiled")
    }

    /// Installs the code `out` of the function `func` of `img` (record `rec`): code memory,
    /// relocation, unwind information, the perf map and the publication.
    #[allow(clippy::too_many_arguments)]
    fn install(
        &mut self,
        rec: *mut JitRecord,
        func: u32,
        img: &Image<'_>,
        info: ImageInfo,
        personality: usize,
        callees: &[u32],
        out: Gen,
        what: &str,
    ) -> Result<(), &'static str> {
        let h = img.header();
        let mode = Mode { counters: false, ..img.mode() };
        let nsyms = h.symbols.count;
        let recs = img.jit_records();
        let Gen { len: code_len, code: enc_code, relocs, rodata, call_sites, body, osr, osr_at } = out;
        let osr_len = osr.as_ref().map_or(0, |o| o.code.len());

        // Unwind information: the CIE, the FDE, the OSR code's FDE, the terminator, then the
        // LSDA.
        let mut eh = Vec::new();
        let pers_field = eh_cie(&mut eh);
        let fields = match &body {
            Body::Aot(ef) => eh_fde(&mut eh, 0, ef, mode),
            Body::Rows(rows) => eh_fde_rows(&mut eh, 0, code_len as u32, rows),
        };
        let osr_fields = osr.as_ref().map(|o| eh_fde_rows(&mut eh, 0, o.code.len() as u32, &o.cfi));
        eh.extend_from_slice(&[0; 4]);
        let lsda_at = eh.len();
        eh.extend_from_slice(&asm::lsda::write(&call_sites));

        // Code memory: the entry prefix, the code, the OSR code, then its code constants.
        let ro_at = (CODE_AT + osr_at + osr_len).next_multiple_of(16);
        let size = (ro_at + rodata.len()).next_multiple_of(PAGE);
        let eh_size = eh.len().next_multiple_of(16);
        if size + eh_size > REGION / 2 {
            return Err("too large");
        }
        let header = h as *const _ as usize;
        let region = self.region(info.span).ok_or("no code memory near the image")?;
        let start = region.start;
        let new_slots = callees.iter().filter(|&&g| !self.slots.contains_key(&(start, header, g))).count();
        let region = self.regions.iter_mut().find(|r| r.start == start).expect("the region");
        if region.code + size + eh_size + 8 * new_slots > region.data {
            // Full: retire it (it reaches nothing any more) and map another.
            region.data = region.code;
            region.start = usize::MAX;
            region.end = usize::MAX;
            let out = Gen { len: code_len, code: enc_code, relocs, rodata, call_sites, body, osr, osr_at };
            return self.install(rec, func, img, info, personality, callees, out, what);
        }
        let base = region.code;
        region.code += size;
        region.data -= eh_size;
        let eh_base = region.data;
        // The call slots, from the region's end too: the callee's JIT code if it was compiled
        // meanwhile (publication is this thread's), else its AOT entry.
        let fs = img.functions();
        let mut slot_of = Vec::with_capacity(callees.len());
        for &g in callees {
            let f = fs.get(g as usize).ok_or("function out of range")?;
            let slot = *self.slots.entry((start, header, g)).or_insert_with(|| {
                region.data -= 8;
                let gr = recs.wrapping_add(g as usize);
                let target = if g < h.jit_records.count && state(gr).load(Acquire) == JIT_DONE {
                    // SAFETY: published before `Done`.
                    unsafe { (*gr).jit_code as usize }
                } else {
                    h.text as usize + f.code_off as usize
                };
                // SAFETY: the region's read-write end, which nothing else uses.
                unsafe { (region.data as *mut usize).write(target) };
                region.data
            });
            slot_of.push(slot);
        }

        let mut code = std::vec![0xccu8; size];
        // `lea r11, [rip + code]; mov [rsp], r11; ret` (JIT_ENTRY_PREFIX).
        let lea = (JIT_ENTRY_PREFIX - 7) as i32;
        let mut prefix = std::vec![0x4c, 0x8d, 0x1d];
        prefix.extend(lea.to_le_bytes());
        prefix.extend([0x4c, 0x89, 0x1c, 0x24, 0xc3]);
        code[CODE_AT - JIT_ENTRY_PREFIX..CODE_AT].copy_from_slice(&prefix);
        code[CODE_AT..][..code_len].copy_from_slice(&enc_code);
        if let Some(o) = &osr {
            code[CODE_AT + osr_at..][..o.code.len()].copy_from_slice(&o.code);
        }
        code[ro_at..][..rodata.len()].copy_from_slice(&rodata);
        let jit_f = base + CODE_AT;
        let ro = img.bytes().as_ptr() as usize;
        for r in &relocs {
            let field = jit_f + r.at as usize;
            let target = match r.to {
                Ref::Handler(op) => Some(self.rt.handlers[op as usize]).filter(|h| !h.is_null()).ok_or("no handler")? as usize,
                Ref::RegHandler(op) => Some(self.rt.reg_handlers[op as usize]).filter(|h| !h.is_null()).ok_or("no register entry")? as usize,
                Ref::Probe => self.rt.probe as usize,
                Ref::Func(Func(g)) if g == func => jit_f,
                Ref::Func(Func(g)) => {
                    let f = fs.get(g as usize).ok_or("function out of range")?;
                    let gr = recs.wrapping_add(g as usize);
                    // A compiled callee directly, else its AOT entry, whose counter check
                    // redirects once it is compiled.
                    if g < h.jit_records.count && state(gr).load(Acquire) == JIT_DONE {
                        // SAFETY: published before `Done`.
                        unsafe { (*gr).jit_code as usize }
                    } else {
                        h.text as usize + f.code_off as usize
                    }
                }
                Ref::Sym(Sym(s)) if s >= nsyms => slot_of[(s - nsyms) as usize],
                Ref::Sym(Sym(s)) => ro + h.symbols.off as usize + 8 * s as usize,
                Ref::Site(Site(s)) => h.data as usize + 8 * s as usize,
                Ref::Const(Const(k)) => ro + h.consts.off as usize + k as usize,
                Ref::Data(Data(k)) => h.data as usize + h.fixup_area as usize + k as usize,
                Ref::Ro(o) => base + ro_at + o as usize,
                Ref::Rec => rec as usize,
                Ref::RecLoopCtr => rec as usize + ryo_bytecode::image::JIT_LOOP_CTR as usize,
            };
            let d = i32::try_from((target as i64).wrapping_sub(field as i64 + 4)).map_err(|_| "out of reach")?;
            code[field - base..][..4].copy_from_slice(&d.to_le_bytes());
        }
        if let Some(o) = &osr {
            let probe = self.rt.probe as usize;
            for &p in &o.probes {
                let field = jit_f + osr_at + p as usize;
                let d = i32::try_from((probe as i64).wrapping_sub(field as i64 + 4)).map_err(|_| "out of reach")?;
                code[field - base..][..4].copy_from_slice(&d.to_le_bytes());
            }
        }
        if let Some(dir) = &self.dump {
            self.dump_code(dir, func, header, nsyms, callees, &enc_code, &relocs, osr.as_ref().map(|o| (osr_at, o)), what);
        }
        let pc = |eh: &mut Vec<u8>, at: usize, target: usize| -> Result<(), &'static str> {
            let d = i32::try_from((target as i64).wrapping_sub((eh_base + at) as i64)).map_err(|_| "out of reach")?;
            eh[at..at + 4].copy_from_slice(&d.to_le_bytes());
            Ok(())
        };
        pc(&mut eh, pers_field, personality)?;
        pc(&mut eh, fields.pc_begin, jit_f)?;
        pc(&mut eh, fields.lsda, eh_base + lsda_at)?;
        if let Some(f) = osr_fields {
            pc(&mut eh, f.pc_begin, jit_f + osr_at)?;
        }

        // SAFETY: fresh read-write memory of the region, `size` and `eh.len()` bytes, which
        // nothing else uses; the code pages become executable only once written, and are
        // never written again.
        unsafe {
            ptr::copy_nonoverlapping(code.as_ptr(), base as *mut u8, size);
            ptr::copy_nonoverlapping(eh.as_ptr(), eh_base as *mut u8, eh.len());
            if mprotect(base as *mut c_void, size, PROT_READ | PROT_EXEC) != 0 {
                return Err("mprotect");
            }
            __register_frame(eh_base as *const u8);
        }
        if let Some(m) = &mut self.perfmap {
            let aot = h.text as usize + fs[func as usize].code_off as usize;
            let _ = writeln!(m, "{jit_f:x} {:x} ryo-jit:f{func}@{aot:x}", code_len);
        }

        // Publish: the code's range, the entry, the state, then the counters' bias that takes
        // every check's stub (design/jit.md, "Publishing").
        // SAFETY: the record is this thread's to write until `Done`; the AOT code reads
        // `entry` with plain loads (an atomic store of its size).
        unsafe {
            (*rec).jit_code = jit_f as *const u8;
        }
        CODE_LEN.lock().unwrap_or_else(|e| e.into_inner()).get_or_insert_with(HashMap::new).insert(rec as usize, code_len);
        entry(rec).store((jit_f - JIT_ENTRY_PREFIX) as *mut u8, Release);
        if osr.is_some() {
            // The dispatcher, at the start of the OSR code: every head's stub calls it from now.
            osr_slot(rec).store((jit_f + osr_at) as *mut u8, Release);
        }
        state(rec).store(JIT_DONE, SeqCst);
        settle(rec);
        // Calls of this function from JIT code compiled before it go straight to it now.
        for (&(_, hd, g), &slot) in &self.slots {
            if hd == header && g == func {
                // SAFETY: a call slot, which JIT code reads with plain loads (an atomic store of
                // its size).
                unsafe { core::sync::atomic::AtomicUsize::from_ptr(slot as *mut usize).store(jit_f, Release) };
            }
        }
        if self.rt.flags & JIT_LOG != 0 {
            let c = counts(rec, self.rt.thresholds);
            self.log(rec, &std::format!("{what} ({} calls, {} loop iterations)", c.calls, c.iters));
        }
        Ok(())
    }

    /// `RYO_JIT_DUMP`: the installed code of `func` as `dir/f<func>-<header>.code`, for `y
    /// bench codegen` to disassemble: `tier`, `code <hex>` (the body, then from `osr <offset>`
    /// the OSR code) and a `reloc <offset> <target>` per relocated field, the targets by
    /// image index as the backend's `RYO_DUMP_CODE` names them (`fn3`, `sym2`, `k16`,
    /// `ryo_h_AddOvf`), a call slot as `slot fn3`, and per call slot `slot <symbol> <function>`:
    /// the IR calls it as a symbol past the image's.
    #[allow(clippy::too_many_arguments)]
    fn dump_code(
        &self,
        dir: &str,
        func: u32,
        header: usize,
        nsyms: u32,
        callees: &[u32],
        code: &[u8],
        relocs: &[asm::Reloc],
        osr: Option<(usize, &asm::osr::OsrCode)>,
        what: &str,
    ) {
        use core::fmt::Write as _;
        let mut s = std::format!("tier {}\ncode ", if what.contains("ssa") { "ssa" } else { "reencode" });
        let hex = |s: &mut std::string::String, bytes: &[u8]| {
            for b in bytes {
                let _ = write!(s, "{b:02x}");
            }
            s.push('\n');
        };
        hex(&mut s, code);
        if let Some((at, o)) = osr {
            let _ = write!(s, "osr {at} ");
            hex(&mut s, &o.code);
        }
        for r in relocs {
            let to = match r.to {
                Ref::Handler(op) => std::format!("ryo_h_{op:?}"),
                Ref::RegHandler(op) => std::format!("ryo_hr_{op:?}"),
                Ref::Probe => "ryo_probe_stack".into(),
                Ref::Func(g) => g.to_string(),
                Ref::Sym(Sym(s)) if s >= nsyms => std::format!("slot {}", Func(callees[(s - nsyms) as usize])),
                Ref::Sym(x) => x.to_string(),
                Ref::Site(x) => x.to_string(),
                Ref::Const(x) => x.to_string(),
                Ref::Data(x) => x.to_string(),
                Ref::Ro(o) => std::format!("ro+{o}"),
                Ref::Rec => "jit_record".into(),
                Ref::RecLoopCtr => "jit_record.ctr_l".into(),
            };
            let _ = writeln!(s, "reloc {} {to}", r.at);
        }
        // The call slots' symbols, which the IR names.
        for (k, &g) in callees.iter().enumerate() {
            let _ = writeln!(s, "slot {} {}", Sym(nsyms + k as u32), Func(g));
        }
        if let Some((at, o)) = osr {
            for &p in &o.probes {
                let _ = writeln!(s, "reloc {} ryo_probe_stack", at + p as usize);
            }
        }
        let _ = std::fs::write(std::format!("{dir}/f{func}-{header:x}.code"), s);
    }

    /// A line on stderr about `rec` (`RYO_JIT_LOG`).
    pub(crate) fn log(&self, rec: *mut JitRecord, what: &str) {
        // SAFETY: a record of a linked image.
        let (func, header) = unsafe { ((*rec).func, (*rec).header) };
        log_line(&std::format!("ryo-jit: f{func} of image {header:p}: {what}\n"));
    }
}

/// Writes `line` to stderr, straight to the file descriptor rather than through std's
/// `Stderr`: linked as an rlib (tests), the JIT shares the program's, whose lock a program
/// thread may hold while it waits for this one (`RYO_JIT_SYNC`).
pub(crate) fn log_line(line: &str) {
    // SAFETY: a write of a live buffer.
    unsafe { write(2, line.as_ptr().cast(), line.len()) };
}
