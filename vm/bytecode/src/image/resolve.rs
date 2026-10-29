//! Decoding an image's linked functions at run time: [`ImageResolver`] classifies the
//! addresses the code refers to (including handler calls through PLT stubs).

use alloc::vec::Vec;

use super::{Image, PoolRead, SYM_SLOT};

/// Classifies the addresses an image's linked code refers to ([`crate::asm::Resolver`]), by
/// the image's header ranges, for decoding its functions at run time
/// ([`crate::asm::decode_linked`]). The handlers aren't in the image: `handlers` gives their
/// addresses (sorted; an address may be shared by several opcodes, folded handlers, where the
/// call's instruction list entry tells which one it calls), `probe` that of `ryo_probe_stack`.
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
        let record = mode.counters.then(|| self.image.jit_record(func) as u64);
        Some(crate::asm::decode_linked(code, addr, record, self, &sites, &list, mode))
    }

    /// The handler table entries at `addr` (several for folded handlers).
    fn table(&self, addr: u64) -> &[(usize, crate::full::Opcode)] {
        let lo = self.handlers.partition_point(|h| (h.0 as u64) < addr);
        let hi = self.handlers.partition_point(|h| (h.0 as u64) <= addr);
        &self.handlers[lo..hi]
    }

    /// `addr` as a reference into the image's ranges, `Err(())` if none holds it.
    fn in_image(&self, addr: u64) -> Result<Option<crate::asm::Ref>, ()> {
        use crate::asm::Ref;
        use crate::full::{Const, Data, Func, Sym};
        let h = self.image.header();
        // The offset of `addr` in the `len` bytes at `base` (one past the end with `end`).
        let within = |base: u64, len: u64, end: bool| {
            addr.checked_sub(base).filter(|&o| o < len.saturating_add(end as u64)).and_then(|o| u32::try_from(o).ok())
        };
        let ro = self.image.bytes().as_ptr() as u64;
        if let Some(o) = within(h.text, h.text_size as u64, false) {
            return Ok(self.image.func_at_entry(o).map(|g| Ref::Func(Func(g))));
        }
        if let Some(o) = within(ro.wrapping_add(h.symbols.off as u64), h.symbols.count as u64 * SYM_SLOT as u64, false) {
            return Ok((o % SYM_SLOT == 0).then_some(Ref::Sym(Sym(o / SYM_SLOT))));
        }
        if let Some(o) = within(ro.wrapping_add(h.code_consts.off as u64), h.code_consts.count as u64, false) {
            return Ok(Some(Ref::Ro(o)));
        }
        match self.image.classify_intra(addr) {
            Some(PoolRead::Const(o)) => Ok(Some(Ref::Const(Const(o)))),
            Some(PoolRead::Data(o)) => Ok(Some(Ref::Data(Data(o)))),
            Some(PoolRead::Bits(_)) | None => Err(()),
        }
    }

    /// Where the PLT stub or import thunk at `addr` jumps, if it is one, `addr` being outside
    /// the image (and no handler or the probe).
    fn through_stub(&self, addr: u64) -> Option<u64> {
        // A call of a handler or the probe through a PLT stub, as code linked against a shared
        // `ryo_rt` (an executable or library with `-Cprefer-dynamic`) has them.
        // SAFETY: no range of the image holds `addr`, so a canonical image only calls it, and
        // a call's target is mapped code. (Bytes of a non-canonical image's target that
        // aren't mapped would fault; the decoder rejects such code later anyway.)
        let slot = unsafe { plt_slot(addr) }?;
        // SAFETY: a PLT stub's GOT slot, which the dynamic linker filled (`BIND_NOW`: a
        // lazily bound slot still points into the PLT, which resolves to nothing).
        Some(unsafe { (slot as *const u64).read_unaligned() })
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
        if addr == self.probe as u64 {
            return Some(Ref::Probe);
        }
        if !self.table(addr).is_empty() {
            return None;
        }
        if let Ok(r) = self.in_image(addr) {
            return r;
        }
        (self.through_stub(addr)? == self.probe as u64).then_some(Ref::Probe)
    }

    fn handlers(&self, addr: u64) -> &[(usize, crate::full::Opcode)] {
        let t = self.table(addr);
        if !t.is_empty() || addr == self.probe as u64 || self.in_image(addr).is_ok() {
            return t;
        }
        self.through_stub(addr).map_or(&[], |to| self.table(to))
    }

    fn code_consts(&self) -> &[u8] {
        self.image.code_consts()
    }
}
