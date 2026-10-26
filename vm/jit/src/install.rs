//! The JIT thread's compiler: decodes a function from its image, encodes it again without
//! counters (in another frame layout with `RYO_JIT_SHUFFLE`), builds the OSR entries of its
//! loop heads, and installs the code near the image: code memory, relocation, unwind
//! information, the perf map, and the record's publication (design/jit.md, "Compiling and installing").

use core::ptr;
use core::sync::atomic::Ordering::{Acquire, Release, SeqCst};
use core::sync::atomic::{AtomicI64, AtomicPtr, AtomicU32, AtomicUsize};
use std::collections::HashMap;
use std::io::Write;
use std::vec::Vec;

use ryo_bytecode::asm::frame::{self, SlotMap};
use ryo_bytecode::asm::osr::OsrEntry;
use ryo_bytecode::asm::{self, FUNC_FAR, FUNC_KINDS, FUNC_NEAR, FUNC_SLOT, Mode, Ref};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};
use ryo_bytecode::image::{EhFunc, Image, ImageResolver, JIT_DONE, JitRecord, eh_cie, eh_fde, eh_fde_rows, jit_count, jit_settle, jit_unbiased};
use ryo_bytecode::jit;
use ryo_bytecode::jit::inline::VmFunc;
use ryo_bytecode::jit::ir::CallTarget;
use ryo_bytecode::jit_abi::{JIT_CHECK, JIT_ENTRY_PREFIX, JIT_LOG, JIT_OPT_SSA, JIT_OPT_SSA_NAIVE, JIT_TEST_PANIC, RtApi};
use ryo_bytecode::{Opcode, reduced, vmem};

/// The page size.
const PAGE: usize = vmem::PAGE;

/// The size of a code region: one mapping that code (from the start, in pages, made
/// executable once written) and unwind information (from the end, read-write) are taken from.
const REGION: usize = 32 << 20;
/// How far apart a 32-bit PC-relative field and its target may be, with a margin.
const REACH: usize = (1 << 31) - (1 << 20);
/// Where a function's code starts in its allocation: 16-aligned, after the entry prefix.
const CODE_AT: usize = 16;
const _: () = assert!(JIT_ENTRY_PREFIX <= CODE_AT);

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

impl Span {
    fn union(self, o: Span) -> Span {
        Span { lo: self.lo.min(o.lo), hi: self.hi.max(o.hi) }
    }
}

/// What the JIT knows about an image: its range, and its `rust_eh_personality` slot.
#[derive(Clone, Copy)]
struct ImageInfo {
    span: Span,
    personality: Option<usize>,
}

/// Returned by [`Jit::install`] when the region the code was encoded for filled up and was
/// retired: the calls' forms depend on the region, so the function is compiled again.
const RETRY: &str = "region full";

/// The region a function is compiled for: calls are encoded by whether it reaches their
/// targets.
#[derive(Clone, Copy)]
struct Place {
    start: usize,
    end: usize,
    /// The handlers and the probe are out of reach ([`Mode::far_rt`]).
    far_rt: bool,
}

impl Place {
    fn reaches(&self, addr: usize) -> bool {
        reaches(self.start, self.end, Span { lo: addr, hi: addr + 1 })
    }
}

/// A callee a function's code calls other than directly as a function of its image:
/// operand `kind | k` of its `call`s and `tail_call`s ([`asm::FUNC_KINDS`]) names `ext[k]`.
#[derive(Clone, Copy)]
struct Ext {
    /// [`FUNC_SLOT`], [`FUNC_NEAR`] or [`FUNC_FAR`].
    kind: u32,
    /// The VM function (image header, function) a slot calls: its slot holds its AOT entry,
    /// then its JIT code once it is published.
    vm: Option<(usize, u32)>,
    /// A known target's address, or a slot's callee's AOT entry.
    addr: usize,
    /// How the caller names it, for `RYO_JIT_DUMP`: its function `fn<g>` or symbol `sym<s>`.
    name: Name,
}

#[derive(Clone, Copy)]
enum Name {
    Func(u32),
    Sym(u32),
    /// Another image's function or symbol (inlined code calls it).
    Other(u32),
    OtherSym(u32),
}

/// A callee by what decides how it is called: a VM function with a JIT record (header,
/// function), or a fixed address.
#[derive(Clone, Copy, PartialEq, Eq, Hash)]
enum Callee {
    Vm(usize, u32),
    Addr(usize),
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

/// What the inliner gets for a compilation: the cache, what decodes functions of any
/// registered image (images are never unregistered, so their headers stay valid), and what
/// retargets the unit's calls after inlining ([`callee`]): the region, and the callees.
struct InlineEnv<'a> {
    cache: &'a mut IrCache,
    handlers: &'a [(usize, Opcode)],
    probe: usize,
    mode: Mode,
    header: usize,
    root: u32,
    thresholds: [i64; 2],
    rt: &'static RtApi,
    place: Place,
    ext: Vec<Ext>,
    memo: HashMap<Callee, u32>,
    /// The VM function (image header, function) of each call form `kind | k` given.
    ext_vm: HashMap<u32, (usize, u32)>,
}

/// The registered image whose header is at `header`.
fn image_of(header: usize) -> Image<'static> {
    // SAFETY: a registered image's header: registered images stay forever.
    unsafe { Image::from_header(header as *const u8) }.expect("a registered image")
}

impl jit::inline::Env for InlineEnv<'_> {
    fn root(&self) -> VmFunc {
        VmFunc { img: self.header, func: Func(self.root) }
    }

    fn ir(&mut self, g: VmFunc) -> Option<std::rc::Rc<jit::ir::Func>> {
        let img = image_of(g.img);
        // Another image's code is inlined only if it was encoded as the root's.
        if (Mode { counters: false, far_rt: self.mode.far_rt, ..img.mode() }) != self.mode {
            return None;
        }
        if let Some(f) = self.cache.get(&(g.img, g.func.0)) {
            return f.clone();
        }
        if self.cache.len() >= IR_CACHE_MAX {
            self.cache.clear();
        }
        let h = img.header();
        // SAFETY: a registered image's text section.
        let text = unsafe { core::slice::from_raw_parts(h.text as usize as *const u8, h.text_size as usize) };
        let res = ImageResolver { image: img, handlers: self.handlers, probe: self.probe };
        let f = match res.decode(g.func.0, text) {
            Some(Ok(d)) => jit::ir_of(&d, self.mode).ok().map(std::rc::Rc::new),
            _ => None,
        };
        self.cache.insert((g.img, g.func.0), f.clone());
        f
    }

    fn flags(&self, g: VmFunc) -> u8 {
        image_of(g.img).func_flags().get(g.func.0 as usize).copied().unwrap_or(0)
    }

    fn counts(&self, g: VmFunc) -> Option<(u64, u64)> {
        let img = image_of(g.img);
        (g.func.0 < img.header().jit_records.count).then(|| {
            let c = counts(img.jit_records().wrapping_add(g.func.0 as usize), self.thresholds);
            (c.calls, c.iters)
        })
    }

    fn callee(&mut self, t: CallTarget) -> Option<VmFunc> {
        let c = match t {
            CallTarget::Func(g) if g.0 & FUNC_KINDS != 0 => {
                let &(h, g) = self.ext_vm.get(&g.0)?;
                Callee::Vm(h, g)
            }
            CallTarget::Func(g) => Callee::Vm(self.header, g.0),
            CallTarget::Sym(Sym(s)) => {
                let a = image_of(self.header).symbols().get(s as usize).copied().unwrap_or(0) as usize;
                if a == 0 {
                    return None;
                }
                vm_callee(self.rt, a)?
            }
            _ => return None,
        };
        let Callee::Vm(h, g) = c else { return None };
        (g < image_of(h).functions().len() as u32).then_some(VmFunc { img: h, func: Func(g) })
    }

    fn retarget(&mut self, img: usize, t: CallTarget) -> Option<CallTarget> {
        let im = image_of(img);
        let (c, name) = match t {
            CallTarget::Func(g) if g.0 < im.functions().len() as u32 => {
                (Callee::Vm(img, g.0), if img == self.header { Name::Func(g.0) } else { Name::Other(g.0) })
            }
            CallTarget::Sym(Sym(s)) => {
                let a = im.symbols().get(s as usize).copied().unwrap_or(0) as usize;
                if a == 0 {
                    return None;
                }
                (vm_callee(self.rt, a).unwrap_or(Callee::Addr(a)), if img == self.header { Name::Sym(s) } else { Name::OtherSym(s) })
            }
            _ => return None,
        };
        if c == Callee::Vm(self.header, self.root) {
            // The root's own calls of itself stay; another image's become direct ones.
            return (img != self.header).then_some(CallTarget::Func(Func(self.root)));
        }
        let op = callee(self.place, c, name, &mut self.ext, &mut self.memo);
        if let Callee::Vm(h, g) = c {
            self.ext_vm.insert(op, (h, g));
        }
        Some(CallTarget::Func(Func(op)))
    }

    fn addr(&self, img: usize, r: Ref) -> Option<u64> {
        // As `Jit::install` relocates them.
        let im = image_of(img);
        let h = im.header();
        let ro = im.bytes().as_ptr() as usize;
        let a = match r {
            Ref::Sym(Sym(s)) if (s as usize) < im.symbols().len() => ro + h.symbols.off as usize + 8 * s as usize,
            Ref::Site(Site(s)) => h.data as usize + 8 * s as usize,
            Ref::Const(Const(k)) => ro + h.consts.off as usize + k as usize,
            Ref::Data(Data(k)) => h.data as usize + h.fixup_area as usize + k as usize,
            _ => return None,
        };
        Some(a as u64)
    }

    fn sym_value(&self, img: usize, s: Sym) -> Option<u64> {
        image_of(img).symbols().get(s.0 as usize).copied()
    }
}

/// The VM function with a JIT record whose AOT entry is `addr`, of any registered image.
fn vm_callee(rt: &RtApi, addr: usize) -> Option<Callee> {
    let header = (rt.image_at)(addr);
    if header.is_null() {
        return None;
    }
    // SAFETY: a registered image's header.
    let img = unsafe { Image::from_header(header) }.ok()?;
    let h = img.header();
    let off = u32::try_from(addr - h.text as usize).ok()?;
    let g = img.functions().binary_search_by_key(&off, |f| f.code_off).ok()? as u32;
    (g < h.jit_records.count).then_some(Callee::Vm(header as usize, g))
}

/// How code compiled for `place` calls `c` (named `name` by the caller): the operand of
/// its `call`s, `kind | k` for `ext[k]`.
fn callee(place: Place, c: Callee, name: Name, ext: &mut Vec<Ext>, memo: &mut HashMap<Callee, u32>) -> u32 {
    if let Some(&op) = memo.get(&c) {
        return op;
    }
    let e = match c {
        Callee::Vm(header, g) => {
            // SAFETY: a registered image's header (`Callee::Vm` has a record).
            let img = unsafe { Image::from_header(header as *const u8) }.expect("a registered image");
            let r = img.jit_records().wrapping_add(g as usize);
            if state(r).load(Acquire) == JIT_DONE {
                // SAFETY: published before `Done`.
                let code = unsafe { (*r).jit_code as usize };
                Ext { kind: if place.reaches(code) { FUNC_NEAR } else { FUNC_FAR }, vm: None, addr: code, name }
            } else {
                let h = img.header();
                let entry = h.text as usize + img.functions()[g as usize].code_off as usize;
                Ext { kind: FUNC_SLOT, vm: Some((header, g)), addr: entry, name }
            }
        }
        Callee::Addr(a) => Ext { kind: if place.reaches(a) { FUNC_NEAR } else { FUNC_FAR }, vm: None, addr: a, name },
    };
    let op = e.kind | ext.len() as u32;
    ext.push(e);
    memo.insert(c, op);
    op
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
            .then(crate::sys::perfmap_path)
            .flatten()
            .and_then(|path| std::fs::OpenOptions::new().create(true).append(true).open(path).ok());
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
            slots_of: HashMap::new(),
            dump,
            ssa_limit,
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

    /// The region to compile code of an image of span `s` for: one that also reaches the
    /// handlers and the probe if there is one (mapping it if need be), else one that reaches
    /// the image only, whose code calls them through `r11` ([`Mode::far_rt`]): an image far
    /// from a shared `ryo_rt`.
    fn place(&mut self, s: Span) -> Option<Place> {
        let rt = self.rt_span;
        let r = match self.region(s.union(rt)) {
            Some(r) => r,
            None => self.region(s)?,
        };
        let far_rt = !r.reaches(rt);
        Some(Place { start: r.start, end: r.end, far_rt })
    }

    /// A region that reaches `s`, mapping a new one if none does.
    fn region(&mut self, s: Span) -> Option<&mut Region> {
        if s.hi - s.lo > REACH {
            return None;
        }
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
                let Some(p) = vmem::reserve_code(hint, REGION) else { continue };
                let p = p as usize;
                // Linux before 4.17 (no `MAP_FIXED_NOREPLACE`) and Apple take the address as a
                // hint only.
                if !reaches(p, p + REGION, s) {
                    // SAFETY: the mapping just made.
                    unsafe { vmem::release(p as *mut u8, REGION) };
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
        // Again in a new region if the one it was compiled for filled up (once is enough: the
        // new one is empty, and the function fits half of one).
        match self.compile_once(rec) {
            Err(RETRY) => self.compile_once(rec),
            r => r,
        }
    }

    /// Rewrites the `call`s, `call.sym`s and `tail_call`s of `words` (the code of `func` of
    /// `img`) to their callees' forms for `place` ([`callee`]): every call but a
    /// self-call, and those through a symbol whose slot holds no address.
    #[allow(clippy::too_many_arguments)]
    fn retarget(
        &self,
        words: &mut [u32],
        func: u32,
        img: &Image<'_>,
        place: Place,
        ext: &mut Vec<Ext>,
        memo: &mut HashMap<Callee, u32>,
    ) -> Result<(), &'static str> {
        let h = img.header();
        let header = h as *const _ as usize;
        let syms = img.symbols();
        let mut at = 0;
        while at < words.len() {
            let op = reduced::Opcode::from_u16(words[at] as u16);
            let (field, c, name) = match op {
                Some(reduced::Opcode::Call) => (at + 2, Callee::Vm(header, words[at + 2]), Name::Func(words[at + 2])),
                Some(reduced::Opcode::TailCall) => (at + 1, Callee::Vm(header, words[at + 1]), Name::Func(words[at + 1])),
                Some(reduced::Opcode::CallSym) => {
                    let s = words[at + 2];
                    let a = syms.get(s as usize).copied().unwrap_or(0) as usize;
                    if a == 0 { (0, Callee::Addr(0), Name::Sym(s)) } else { (at + 2, vm_callee(self.rt, a).unwrap_or(Callee::Addr(a)), Name::Sym(s)) }
                }
                _ => (0, Callee::Addr(0), Name::Sym(0)),
            };
            let is_self = c == Callee::Vm(header, func);
            if field != 0 && !is_self {
                // Of the callee's image: a symbol may name another image's function.
                if let Callee::Vm(hd, g) = c
                    && g >= image_of(hd).functions().len() as u32
                {
                    return Err("function out of range");
                }
                words[field] = callee(place, c, name, ext, memo);
                if op == Some(reduced::Opcode::CallSym) {
                    words[at] = reduced::Opcode::Call as u32;
                }
            }
            at += reduced::insn_len(&words[at..]).map_err(|_| "reduced code")?;
        }
        Ok(())
    }

    fn compile_once(&mut self, rec: *mut JitRecord) -> Result<(), &'static str> {
        // SAFETY: a record of a linked image, whose header it points at.
        let (func, img) = unsafe { ((*rec).func, Image::from_header((*rec).header.cast()).map_err(|_| "invalid image")?) };
        let h = img.header();
        if img.mode().pe {
            return Err("PE");
        }
        let info = self.image(&img);
        let personality = info.personality.ok_or("no personality slot")?;
        let place = self.place(info.span).ok_or("no code memory near the image")?;
        // SAFETY: a linked image's text section.
        let text = unsafe { core::slice::from_raw_parts(h.text as usize as *const u8, h.text_size as usize) };
        let res = ImageResolver { image: img, handlers: &self.handlers, probe: self.rt.probe as usize };
        let d = res.decode(func, text).ok_or("no such function")?.map_err(|e| e.what)?;
        let mode = Mode { counters: false, far_rt: place.far_rt, ..img.mode() };

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
            // The AOT layout's words (the SSA tier lays out its own frame); the calls are
            // retargeted as above after inlining, by the same rules.
            let ds = &d;
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
            let r = jit::compile(ds, img.code_consts(), mode, &opts, Some(&mut env));
            let ssa_ext = env.ext;
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
                    return self.install(rec, func, &img, place, personality, &ssa_ext, out, "compiled (ssa)");
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
        self.install(rec, func, &img, place, personality, &ext, out, "compiled")
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
        what: &str,
    ) -> Result<(), &'static str> {
        let h = img.header();
        let mode = Mode { counters: false, far_rt: place.far_rt, ..img.mode() };
        let Gen { len: code_len, code: enc_code, relocs, rodata, call_sites, body, osr, osr_at } = out;
        let osr_len = osr.as_ref().map_or(0, |o| o.code.len());

        // Unwind information: the CIE, the FDE, the OSR code's FDE, the terminator, then the
        // LSDA.
        let mut eh = Vec::new();
        let pers_field = eh_cie(&mut eh);
        let mut fdes = std::vec![eh.len()];
        let fields = match &body {
            Body::Aot(ef) => eh_fde(&mut eh, 0, ef, mode),
            Body::Rows(rows) => eh_fde_rows(&mut eh, 0, code_len as u32, rows),
        };
        if osr.is_some() {
            fdes.push(eh.len());
        }
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
        let region = self.regions.iter_mut().find(|r| r.start == start).ok_or(RETRY)?;
        if region.code + size + eh_size + 8 * new_slots > region.data {
            // Full: retire it (it reaches nothing any more), and compile again for another.
            region.data = region.code;
            region.start = usize::MAX;
            region.end = usize::MAX;
            return Err(RETRY);
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
                let target = if state(gr).load(Acquire) == JIT_DONE {
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
        code[CODE_AT - JIT_ENTRY_PREFIX..CODE_AT].copy_from_slice(&prefix);
        code[CODE_AT..][..code_len].copy_from_slice(&enc_code);
        if let Some(o) = &osr {
            code[CODE_AT + osr_at..][..o.code.len()].copy_from_slice(&o.code);
        }
        code[ro_at..][..rodata.len()].copy_from_slice(&rodata);
        let jit_f = base + CODE_AT;
        let ro = img.bytes().as_ptr() as usize;
        let fs = img.functions();
        for r in &relocs {
            let field = jit_f + r.at as usize;
            // Fields of 8 bytes: an `imm64` of a call through `r11`.
            let abs = match r.to {
                Ref::Handler(_) | Ref::RegHandler(_) | Ref::Probe => place.far_rt,
                Ref::Func(Func(g)) => g & FUNC_KINDS == FUNC_FAR,
                _ => false,
            };
            let target = match r.to {
                Ref::Handler(op) => Some(self.rt.handlers[op as usize]).filter(|h| !h.is_null()).ok_or("no handler")? as usize,
                Ref::RegHandler(op) => Some(self.rt.reg_handlers[op as usize]).filter(|h| !h.is_null()).ok_or("no register entry")? as usize,
                Ref::Probe => self.rt.probe as usize,
                Ref::Func(Func(g)) if g == func => jit_f,
                Ref::Func(Func(g)) if g & FUNC_KINDS != 0 => {
                    let k = (g & !FUNC_KINDS) as usize;
                    if g & FUNC_KINDS == FUNC_SLOT { slot_of[k] } else { ext[k].addr }
                }
                // Every other call was retargeted.
                Ref::Func(_) => return Err("an unexpected call"),
                Ref::Sym(Sym(s)) => ro + h.symbols.off as usize + 8 * s as usize,
                Ref::Site(Site(s)) => h.data as usize + 8 * s as usize,
                Ref::Const(Const(k)) => ro + h.consts.off as usize + k as usize,
                Ref::Data(Data(k)) => h.data as usize + h.fixup_area as usize + k as usize,
                Ref::Ro(o) => base + ro_at + o as usize,
                Ref::Rec => rec as usize,
                Ref::RecLoopCtr => rec as usize + ryo_bytecode::image::JIT_LOOP_CTR as usize,
            };
            if abs {
                code[field - base..][..8].copy_from_slice(&(target as u64).to_le_bytes());
                continue;
            }
            let d = i32::try_from((target as i64).wrapping_sub(field as i64 + 4)).map_err(|_| "out of reach")?;
            code[field - base..][..4].copy_from_slice(&d.to_le_bytes());
        }
        if let Some(o) = &osr {
            let probe = self.rt.probe as usize;
            for &p in &o.probes {
                let field = jit_f + osr_at + p as usize;
                if place.far_rt {
                    code[field - base..][..8].copy_from_slice(&(probe as u64).to_le_bytes());
                    continue;
                }
                let d = i32::try_from((probe as i64).wrapping_sub(field as i64 + 4)).map_err(|_| "out of reach")?;
                code[field - base..][..4].copy_from_slice(&d.to_le_bytes());
            }
        }
        if let Some(dir) = &self.dump {
            self.dump_code(dir, func, header, ext, &enc_code, &relocs, osr.as_ref().map(|o| (osr_at, o)), what);
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
            if !vmem::make_executable(base as *mut u8, size) {
                return Err("make_executable");
            }
            // Unregistered, the code must not run: nothing could unwind through it. At exit
            // it isn't needed.
            let unwind = crate::sys::Unwind { eh: eh_base as *const u8, fdes: &fdes, code: (base, base + size) };
            if !crate::sys::register_unwind(&unwind) {
                return Err("exiting");
            }
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
        // Calls of this function from JIT code compiled before it, of any image, go straight
        // to it now.
        for &slot in self.slots_of.get(&(header, func)).map_or(&[][..], |v| &v[..]) {
            // SAFETY: a call slot, 8-aligned, which JIT code reads with plain loads (an atomic
            // store of its size).
            unsafe { AtomicUsize::from_ptr(slot as *mut usize).store(jit_f, Release) };
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
    /// `ryo_h_AddOvf`), and per retargeted callee `ext fn<operand> <form> <name>`: the code
    /// and the IR call it as function `operand` ([`asm::FUNC_KINDS`]), which is the caller's
    /// function or symbol `name`, through a call slot (`slot`), directly (`near`) or through
    /// `r11` (`far`).
    #[allow(clippy::too_many_arguments)]
    fn dump_code(
        &self,
        dir: &str,
        func: u32,
        header: usize,
        ext: &[Ext],
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
        // The retargeted callees, which the code and the IR name.
        for (k, e) in ext.iter().enumerate() {
            let form = match e.kind {
                FUNC_SLOT => "slot",
                FUNC_NEAR => "near",
                _ => "far",
            };
            let name = match e.name {
                Name::Func(g) => Func(g).to_string(),
                Name::Sym(x) => Sym(x).to_string(),
                Name::Other(g) => std::format!("{}@other", Func(g)),
                Name::OtherSym(x) => std::format!("{}@other", Sym(x)),
            };
            let _ = writeln!(s, "ext {} {form} {name}", Func(e.kind | k as u32));
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
    crate::sys::write_stderr(line.as_bytes());
}

#[cfg(test)]
mod tests {
    #[test]
    fn no_frame_registration_once_exiting() {
        crate::sys::close_frame_registry();
        // Not a valid `.eh_frame`: once closed, it must not reach the unwinder.
        let u = crate::sys::Unwind { eh: core::ptr::dangling(), fdes: &[0], code: (0, 0) };
        assert!(!unsafe { crate::sys::register_unwind(&u) });
        crate::sys::reopen_frame_registry();
    }
}
