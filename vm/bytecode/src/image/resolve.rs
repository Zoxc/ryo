//! Decoding an image's linked functions at run time: [`ImageResolver`] classifies the
//! addresses the code refers to (including handler calls through PLT stubs).

use alloc::vec::Vec;

use super::Image;

/// Classifies the addresses an image's linked code refers to ([`crate::asm::Resolver`]), by
/// the image's header ranges, for decoding its functions at run time
/// ([`crate::asm::decode_linked`]). The handlers aren't in the image: `handlers` gives their
/// addresses (sorted; an address shared by several opcodes resolves to none of them), `probe`
/// that of `ryo_probe_stack`.
#[derive(Clone, Copy)]
pub struct ImageResolver<'a> {
    pub image: Image<'a>,
    pub handlers: &'a [(usize, crate::full::Opcode)],
    pub probe: usize,
}

impl ImageResolver<'_> {
    /// Decodes function `func` to the reduced set, from the image's linked text section
    /// `text` (`Header::text_size` bytes at `Header::text`), with its call sites and
    /// instruction list. `None` for an unknown function or a malformed instruction list
    /// (which [`Image::validate`] rejects).
    pub fn decode(&self, func: u32, text: &[u8]) -> Option<Result<crate::asm::Decoded, crate::asm::AsmError>> {
        let f = self.image.functions().get(func as usize)?;
        let code = text.get(f.code_off as usize..)?.get(..f.code_len as usize)?;
        let sites: Vec<_> = self.image.call_sites(func).iter().map(crate::asm::CallSite::from).collect();
        let list = crate::asm::InsnList::read(self.image.list(func), f.code_len)?;
        let addr = self.image.header().text.wrapping_add(f.code_off as u64);
        // Only with counters has the function a JIT record.
        let mode = self.image.mode();
        let record = mode.counters.then(|| self.image.jit_records().wrapping_add(func as usize) as u64);
        Some(crate::asm::decode_linked(code, addr, record, self, &sites, &list, mode))
    }

    /// `addr` as a handler or the probe: `Some(None)` for a handler address shared by several
    /// opcodes (folded handlers), which is ambiguous.
    fn runtime(&self, addr: u64) -> Option<Option<crate::asm::Ref>> {
        let lo = self.handlers.partition_point(|h| (h.0 as u64) < addr);
        let hi = self.handlers.partition_point(|h| (h.0 as u64) <= addr);
        if hi - lo == 1 {
            return Some(Some(crate::asm::Ref::Handler(self.handlers[lo].1)));
        }
        if hi > lo {
            return Some(None);
        }
        (addr == self.probe as u64).then_some(Some(crate::asm::Ref::Probe))
    }
}

/// The GOT slot the PLT stub at `addr` jumps through, if `addr` holds one: `jmp [rip +
/// disp32]`, after an `endbr64` and with a `bnd` prefix in `.plt.sec`.
///
/// # Safety
/// `addr` must be the address of at least 11 readable bytes.
unsafe fn plt_slot(addr: u64) -> Option<u64> {
    // SAFETY: per the caller.
    let b = unsafe { core::slice::from_raw_parts(addr as *const u8, 11) };
    let at = if b.starts_with(&[0xf3, 0x0f, 0x1e, 0xfa]) { 4 } else { 0 };
    let at = if b[at] == 0xf2 { at + 1 } else { at };
    if b[at..at + 2] != [0xff, 0x25] {
        return None;
    }
    let d = i32::from_le_bytes(b[at + 2..at + 6].try_into().ok()?);
    Some(addr.wrapping_add((at + 6) as u64).wrapping_add(d as i64 as u64))
}

impl crate::asm::Resolver for ImageResolver<'_> {
    fn resolve(&self, addr: u64) -> Option<crate::asm::Ref> {
        use crate::asm::Ref;
        use crate::full::{Const, Data, Func, Site, Sym};
        if let Some(r) = self.runtime(addr) {
            return r;
        }
        let h = self.image.header();
        // The offset of `addr` in the `len` bytes at `base` (one past the end with `end`).
        let within = |base: u64, len: u64, end: bool| {
            addr.checked_sub(base).filter(|&o| o < len.saturating_add(end as u64)).and_then(|o| u32::try_from(o).ok())
        };
        let ro = self.image.bytes().as_ptr() as u64;
        let consts = (ro.wrapping_add(h.consts.off as u64), h.consts.count as u64);
        // The fixup area ends where the JIT records start.
        let data_end = if h.jit_records.count != 0 { h.jit_records.off } else { h.data_size };
        let data = (h.data.wrapping_add(h.fixup_area as u64), data_end.saturating_sub(h.fixup_area) as u64);
        if let Some(o) = within(h.text, h.text_size as u64, false) {
            let fs = self.image.functions();
            return fs.binary_search_by_key(&o, |f| f.code_off).ok().map(|i| Ref::Func(Func(i as u32)));
        }
        if let Some(o) = within(ro.wrapping_add(h.symbols.off as u64), h.symbols.count as u64 * 8, false) {
            return (o % 8 == 0).then_some(Ref::Sym(Sym(o / 8)));
        }
        if let Some(o) = within(ro.wrapping_add(h.code_consts.off as u64), h.code_consts.count as u64, false) {
            return Some(Ref::Ro(o));
        }
        if let Some(o) = within(consts.0, consts.1, false) {
            return Some(Ref::Const(Const(o)));
        }
        if let Some(o) = within(h.data, h.site_count as u64 * 8, false) {
            return (o % 8 == 0).then_some(Ref::Site(Site(o / 8)));
        }
        if let Some(o) = within(data.0, data.1, false) {
            return Some(Ref::Data(Data(o)));
        }
        // One past the end of the constants or the data, only once no range holds `addr`
        // (sections may be adjacent).
        if let Some(o) = within(consts.0, consts.1, true) {
            return Some(Ref::Const(Const(o)));
        }
        if let Some(o) = within(data.0, data.1, true) {
            return Some(Ref::Data(Data(o)));
        }
        // A call of a handler or the probe through a PLT stub, as code linked against a shared
        // `ryo_rt` (an executable or library with `-Cprefer-dynamic`) has them.
        // SAFETY: no range of the image holds `addr`, so a canonical image only calls it, and
        // a call's target is mapped code. (Bytes of a non-canonical image's target that
        // aren't mapped would fault; the decoder rejects such code later anyway.)
        let slot = unsafe { plt_slot(addr) }?;
        // SAFETY: a PLT stub's GOT slot, which the dynamic linker filled (`BIND_NOW`: a
        // lazily bound slot still points into the PLT, which resolves to nothing).
        let to = unsafe { (slot as *const u64).read_unaligned() };
        self.runtime(to).flatten()
    }

    fn code_consts(&self) -> &[u8] {
        self.image.code_consts()
    }
}
