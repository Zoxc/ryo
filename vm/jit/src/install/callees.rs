//! What a function's calls call, by the form the region it is compiled for allows
//! (design/jit.md, "Calls"), and what the SSA tier's inliner and folds see of other functions
//! and images.

use super::*;

/// A callee a function's code calls other than directly as a function of its image:
/// operand `kind | k` of its `call`s and `tail_call`s ([`asm::FUNC_KINDS`]) names `ext[k]`.
#[derive(Clone, Copy)]
pub(super) struct Ext {
    /// [`FUNC_SLOT`], [`FUNC_NEAR`] or [`FUNC_FAR`].
    pub(super) kind: u32,
    /// The VM function (image header, function) a slot calls: its slot holds its AOT entry,
    /// then its JIT code once it is published.
    pub(super) vm: Option<(usize, u32)>,
    /// A known target's address, or a slot's callee's AOT entry.
    pub(super) addr: usize,
    /// How the caller names it, for `RYO_JIT_DUMP`: its function `fn<g>` or symbol `sym<s>`.
    pub(super) name: Name,
}

#[derive(Clone, Copy)]
pub(super) enum Name {
    Func(u32),
    Sym(u32),
    /// Another image's function or symbol (inlined code calls it).
    Other(u32),
    OtherSym(u32),
    /// A function by its entry's address: a call through a constant pointer
    /// ([`jit::inline::Env::direct`]).
    Addr(usize),
}

/// A callee by what decides how it is called: a VM function with a JIT record (header,
/// function), or a fixed address.
#[derive(Clone, Copy, PartialEq, Eq, Hash)]
pub(super) enum Callee {
    Vm(usize, u32),
    Addr(usize),
}

/// Callee IR for the inliner, built once per function ([`jit::inline::Env::ir`]).
pub(super) type IrCache = HashMap<(usize, u32), Option<std::rc::Rc<jit::ir::Func>>>;

/// At most this many functions' IR stay cached; the cache starts over past it.
pub(super) const IR_CACHE_MAX: usize = 4096;

/// What the inliner gets for a compilation: the cache, what decodes functions of any
/// registered image (images are never unregistered, so their headers stay valid), and what
/// retargets the unit's calls after inlining ([`callee`]): the region, and the callees.
pub(super) struct InlineEnv<'a> {
    pub(super) cache: &'a mut IrCache,
    pub(super) handlers: &'a [(usize, Opcode)],
    pub(super) probe: usize,
    pub(super) mode: Mode,
    pub(super) header: usize,
    pub(super) root: u32,
    pub(super) thresholds: [i64; 2],
    pub(super) rt: &'static RtApi,
    pub(super) place: Place,
    pub(super) ext: Vec<Ext>,
    pub(super) memo: HashMap<Callee, u32>,
    /// The VM function (image header, function) of each call form `kind | k` given.
    pub(super) ext_vm: HashMap<u32, (usize, u32)>,
}

/// The registered image whose header is at `header`.
pub(super) fn image_of(header: usize) -> Image<'static> {
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
        if jit_mode(&img, self.mode.far_rt) != self.mode {
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
            Some(Ok(d)) => jit::ir_of(&d, self.mode, Some(&PoolMem { header: g.img, rt: self.rt })).ok().map(std::rc::Rc::new),
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
            // A code constant (sparse switch cases).
            Ref::Ro(k) if (k as usize) < im.code_consts().len() => im.code_consts().as_ptr() as usize + k as usize,
            _ => return None,
        };
        Some(a as u64)
    }

    fn sym_value(&self, img: usize, s: Sym) -> Option<u64> {
        image_of(img).symbols().get(s.0 as usize).copied()
    }

    fn direct(&mut self, a: u64) -> Option<CallTarget> {
        let c @ Callee::Vm(h, g) = vm_callee(self.rt, usize::try_from(a).ok()?)? else { return None };
        if h == self.header {
            return Some(CallTarget::Func(Func(g)));
        }
        let op = callee(self.place, c, Name::Addr(a as usize), &mut self.ext, &mut self.memo);
        self.ext_vm.insert(op, (h, g));
        Some(CallTarget::Func(Func(op)))
    }
}

/// The constant pools the SSA tier folds loads from ([`jit::opt::ConstMem`]): those of the
/// image whose header is at `header` (the IR's), and through `image_at` every registered
/// image's. Registered images stay forever, and their pools are final once registered: the
/// loader applied their relocations before.
pub(super) struct PoolMem {
    pub(super) header: usize,
    pub(super) rt: &'static RtApi,
}

impl jit::opt::ConstMem for PoolMem {
    fn read(&self, a: jit::opt::ConstAt, w: u8) -> Option<jit::opt::PoolRead> {
        use jit::opt::{ConstAt, PoolRead};
        match a {
            ConstAt::Root(k) => image_of(self.header).read_pool(k as u64, w),
            ConstAt::Abs(addr) => {
                let header = (self.rt.image_at)(addr as usize);
                if header.is_null() {
                    return None;
                }
                let img = image_of(header as usize);
                let pool = img.consts().as_ptr() as u64;
                // Another image's pointer fields (or this one's, by address) as their bits:
                // the IR can't name another image's parts, and each part is exposed.
                let off = addr.checked_sub(pool)?;
                let read = img.read_pool(off, w)?;
                let bits = |a: u64| PoolRead::Bits(a);
                Some(match read {
                    PoolRead::Bits(b) => bits(b),
                    PoolRead::Const(t) => bits(pool + t as u64),
                    PoolRead::Data(t) => bits(img.fixup_area() as u64 + t as u64),
                })
            }
        }
    }

    fn relocs(&self, k: u32, len: u32) -> Vec<u32> {
        let rs = image_of(self.header).const_relocs();
        let lo = rs.partition_point(|&r| r as u64 + 8 <= k as u64);
        rs[lo..].iter().copied().take_while(|&r| (r as u64) < k as u64 + len as u64).collect()
    }
}

/// The VM function with a JIT record whose AOT entry is `addr`, of any registered image.
pub(super) fn vm_callee(rt: &RtApi, addr: usize) -> Option<Callee> {
    let header = (rt.image_at)(addr);
    if header.is_null() {
        return None;
    }
    // SAFETY: a registered image's header.
    let img = unsafe { Image::from_header(header) }.ok()?;
    let h = img.header();
    let off = u32::try_from(addr.checked_sub(h.text as usize)?).ok()?;
    let g = img.functions().binary_search_by_key(&off, |f| f.code_off).ok()? as u32;
    (g < h.jit_records.count).then_some(Callee::Vm(header as usize, g))
}

/// How code compiled for `place` calls `c` (named `name` by the caller): the operand of
/// its `call`s, `kind | k` for `ext[k]`.
pub(super) fn callee(place: Place, c: Callee, name: Name, ext: &mut Vec<Ext>, memo: &mut HashMap<Callee, u32>) -> u32 {
    if let Some(&op) = memo.get(&c) {
        return op;
    }
    let e = match c {
        Callee::Vm(header, g) => {
            // SAFETY: a registered image's header (`Callee::Vm` has a record).
            let img = unsafe { Image::from_header(header as *const u8) }.expect("a registered image");
            let r = img.jit_records().wrapping_add(g as usize);
            if JitRecord::state(r).load(Acquire) == JIT_DONE {
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
    /// Rewrites the `call`s, `call.sym`s and `tail_call`s of `words` (the code of `func` of
    /// `img`) to their callees' forms for `place` ([`callee`]): every call but a
    /// self-call, and those through a symbol whose slot holds no address.
    #[allow(clippy::too_many_arguments)]
    pub(super) fn retarget(
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
}
