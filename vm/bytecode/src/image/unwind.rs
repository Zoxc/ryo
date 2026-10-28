//! Unwind information of VM code: `.eh_frame` CIEs and FDEs and PE `UNWIND_INFO`. The image
//! writer ([`ImageWriter::finish`]) and the JIT's installer share these encoders, which is
//! what keeps AOT and JIT unwind information consistent (design/platforms.md).

use alloc::vec;
use alloc::vec::Vec;

use super::*;
use crate::asm::{self, Mode};

/// `.eh_frame` and `.gcc_except_table`: one CIE naming `rust_eh_personality` (through the
/// symbol slot at `personality_slot` of the read-only section, `DW_EH_PE_indirect`), then per
/// function an FDE with the rules of [`eh_fde_rules`] and its LSDA ([`asm::lsda`]).
pub(super) fn unwind_elf(
    funcs: &[FuncCode],
    personality_slot: u64,
    mode: Mode,
    ptrs: EhPointers,
    relocs: &mut Vec<Reloc>,
) -> Vec<(Section, Vec<u8>)> {
    let pc = |offset, target, addend, kind| Reloc { section: Section::EhFrame, offset, target: RelocTarget::Section(target), addend, kind };
    let kind = match ptrs {
        EhPointers::Sdata4 => RelocKind::Pc32,
        EhPointers::Abs8 => RelocKind::Pc64,
    };
    let mut eh = Vec::new();
    let p = eh_cie_with(&mut eh, ptrs);
    // The personality field is 4 bytes in both encodings.
    relocs.push(pc(p as u64, Section::ReadOnly, personality_slot as i64, RelocKind::Pc32));
    let mut lsda = Vec::new();
    for f in funcs {
        let l = lsda.len() as u64;
        lsda.extend_from_slice(&asm::lsda::write(&f.call_sites));
        let ef = EhFunc { len: f.len, frame_size: f.frame_size, prologue: f.prologue, entry_stub: f.entry_stub };
        let fields = eh_fde_rows_with(&mut eh, 0, f.len, &eh_fde_rules(&ef, mode), ptrs);
        relocs.push(pc(fields.pc_begin as u64, Section::Text, f.start as i64, kind));
        relocs.push(pc(fields.lsda as u64, Section::Lsda, l as i64, kind));
    }
    vec![(Section::EhFrame, eh), (Section::Lsda, lsda)]
}

/// `DW_EH_PE_pcrel | DW_EH_PE_sdata4`: the encoding of every pointer [`eh_cie`] and
/// [`eh_fde`] write (the personality's with `DW_EH_PE_indirect` too).
const PCREL_SDATA4: u8 = 0x1b;
/// `DW_EH_PE_pcrel | DW_EH_PE_absptr`: the FDE pointers of [`EhPointers::Abs8`].
const PCREL_ABSPTR: u8 = 0x10;

/// Appends the CIE of VM code's `.eh_frame` to `eh`: augmentation `zPLR`, the personality
/// through a pointer-sized slot (`DW_EH_PE_indirect`), the LSDA and FDE pointers PC-relative
/// (32-bit), and the initial rules of a function entry (CFA `rsp + 8`, the return address at
/// CFA − 8). Returns the position in `eh` of the personality field, which holds the slot's
/// address less the field's own. The image writer and the JIT (`ryo_rt`) share it.
pub fn eh_cie(eh: &mut Vec<u8>) -> usize {
    eh_cie_with(eh, EhPointers::Sdata4)
}

/// [`eh_cie`] with the LSDA and FDE pointers encoded as `ptrs` says (the personality stays
/// `sdata4`, indirect).
fn eh_cie_with(eh: &mut Vec<u8>, ptrs: EhPointers) -> usize {
    let enc = match ptrs {
        EhPointers::Sdata4 => PCREL_SDATA4,
        EhPointers::Abs8 => PCREL_ABSPTR,
    };
    let mut cie = vec![0, 0, 0, 0, 1];
    cie.extend_from_slice(b"zPLR\0");
    cie.extend_from_slice(&[1, 0x78, 16]); // code align 1, data align -8, return address r16
    cie.extend_from_slice(&[7, 0x80 | PCREL_SDATA4]); // augmentation length, P encoding (indirect)
    let personality = eh.len() + 4 + cie.len();
    cie.extend_from_slice(&[0; 4]);
    cie.extend_from_slice(&[enc, enc]); // L, R encodings
    cie.extend_from_slice(&[0x0c, 7, 8, 0x90, 1]); // CFA = rsp + 8; return address at CFA - 8
    if ptrs == EhPointers::Abs8 {
        // Mach-O: the return address's rule once more, the idiom that keeps Apple's linkers
        // from converting the FDEs to compact unwind (ld64's `registerSavedTwiceInCIE`, which
        // silently encodes `UNWIND_X86_64_MODE_DWARF`). They convert from the rules at the
        // FDE's end, which are the entry's counter stub's (CFA `rsp + 8`), not the body's: the
        // frame would unwind wrongly and panics through it fail ("failed to initiate panic").
        // In the two bytes that were padding.
        cie.extend_from_slice(&[0x90, 1]);
    }
    while (cie.len() + 4) % 8 != 0 {
        cie.push(0); // DW_CFA_nop
    }
    eh.extend_from_slice(&(cie.len() as u32).to_le_bytes());
    eh.extend_from_slice(&cie);
    personality
}

/// What an FDE of [`eh_fde`] describes: a function's code length, frame size, and where its
/// prologue and its entry's counter stub start ([`Encoded::prologue`],
/// [`Encoded::entry_stub`]).
#[derive(Clone, Copy, Debug)]
pub struct EhFunc {
    pub len: u32,
    pub frame_size: u32,
    pub prologue: u32,
    pub entry_stub: u32,
}

/// The positions in `.eh_frame` of an FDE's PC-relative fields ([`eh_fde`]): its first
/// address and its LSDA pointer, each the target's address less the field's own.
#[derive(Clone, Copy, Debug)]
pub struct EhFields {
    pub pc_begin: usize,
    pub lsda: usize,
}

/// Appends to `eh` the FDE of a function encoded in `mode`, for the CIE at position `cie` of
/// `eh` ([`eh_cie`]), with the rules of [`eh_fde_rules`].
pub fn eh_fde(eh: &mut Vec<u8>, cie: usize, f: &EhFunc, mode: Mode) -> EhFields {
    eh_fde_rows(eh, cie, f.len, &eh_fde_rules(f, mode))
}

/// The CFA rows of a function encoded in `mode`, for [`eh_fde_rows`]. With a frame pointer,
/// every function has the same rules (`push rbp; mov rbp, rsp`, after which the CFA is
/// `rbp + 16`); without, the CFA is `rsp + F + 16` after the prologue's `sub rsp, F + 8`.
/// Epilogues have no rules: they make no calls, so only asynchronous unwinding could stop
/// there. The counter check before the prologue moves nothing, and the entry's counter stub
/// at the end of the code runs before the prologue: there the CFA is `rsp + 8` again.
fn eh_fde_rules(f: &EhFunc, mode: Mode) -> Vec<(u32, Vec<u8>)> {
    let mut rows = Vec::new();
    if mode.frame_pointer {
        // After `push rbp`: CFA = rsp + 16, rbp at CFA - 16; after `mov rbp, rsp`: CFA = rbp + 16.
        rows.push((f.prologue + 1, vec![0x0e, 16, 0x86, 2]));
        rows.push((f.prologue + 4, vec![0x0d, 6]));
    } else {
        // After the prologue: CFA = rsp + F + 16 (`DW_CFA_def_cfa_offset`).
        let mut r = vec![0x0e];
        asm::leb::put(&mut r, (f.frame_size + 16).into());
        rows.push((f.prologue + asm::prologue_len(f.frame_size, mode), r));
    }
    if f.entry_stub < f.len {
        // The entry's stub: CFA = rsp + 8 (`DW_CFA_def_cfa`), and `rbp` not saved yet
        // (`DW_CFA_restore`).
        let mut r = vec![0x0c, 7, 8];
        if mode.frame_pointer {
            r.push(0xc6);
        }
        rows.push((f.entry_stub, r));
    }
    rows
}

/// Appends to `eh` an FDE for the CIE at `cie` ([`eh_cie`]) of `len` bytes of code whose
/// rules are `rows`: at each code offset (ascending), call frame instructions on top of the
/// CIE's initial `CFA = rsp + 8`. Its LSDA pointer is 0 until relocated (the JIT's OSR
/// entries ([`crate::asm::osr`]) leave it 0: their code has no call sites).
pub fn eh_fde_rows(eh: &mut Vec<u8>, cie: usize, len: u32, rows: &[(u32, Vec<u8>)]) -> EhFields {
    eh_fde_rows_with(eh, cie, len, rows, EhPointers::Sdata4)
}

/// [`eh_fde_rows`] with the first address, range and LSDA pointer of size `ptrs`.
fn eh_fde_rows_with(eh: &mut Vec<u8>, cie: usize, len: u32, rows: &[(u32, Vec<u8>)], ptrs: EhPointers) -> EhFields {
    let at = eh.len();
    let mut fde = Vec::new();
    fde.extend_from_slice(&((at + 4 - cie) as u32).to_le_bytes()); // back to the CIE
    let size = match ptrs {
        EhPointers::Sdata4 => 4,
        EhPointers::Abs8 => 8,
    };
    let pc_begin = at + 4 + fde.len();
    fde.extend_from_slice(&[0; 8][..size]);
    fde.extend_from_slice(&u64::from(len).to_le_bytes()[..size]);
    fde.push(size as u8); // augmentation length: the LSDA pointer
    let lsda = at + 4 + fde.len();
    fde.extend_from_slice(&[0; 8][..size]);
    let mut loc = 0;
    for (to, insns) in rows {
        if *to > loc {
            advance(&mut fde, &mut loc, *to);
        }
        fde.extend_from_slice(insns);
    }
    while (fde.len() + 4) % 8 != 0 {
        fde.push(0);
    }
    eh.extend_from_slice(&(fde.len() as u32).to_le_bytes());
    eh.extend_from_slice(&fde);
    EhFields { pc_begin, lsda }
}

/// A CFA instruction moving the location from `*loc` to `to`, in the shortest of
/// `DW_CFA_advance_loc`, `advance_loc1`, `advance_loc2` and `advance_loc4`.
fn advance(fde: &mut Vec<u8>, loc: &mut u32, to: u32) {
    let d = to - *loc;
    *loc = to;
    if d < 64 {
        fde.push(0x40 | d as u8);
    } else if d < 1 << 8 {
        fde.extend_from_slice(&[0x02, d as u8]);
    } else if d < 1 << 16 {
        fde.push(0x03);
        fde.extend_from_slice(&(d as u16).to_le_bytes());
    } else {
        fde.push(0x04);
        fde.extend_from_slice(&d.to_le_bytes());
    }
}

/// `.pdata` and `.xdata`: per function, its range and unwind info ([`pe_unwind_info`]), with
/// `ryo_seh_handler` as the language handler of both phases and its handler data
/// ([`pe_handler_data`]: the function's LSDA), so that its landing pads run
/// (design/vm.md#unwinding). The counter check before the prologue counts as part of it (it
/// moves nothing). The entry's counter stub after the code, which runs before the prologue
/// and calls nothing that unwinds, has an entry of its own without unwind codes or a handler,
/// as a leaf ([`PE_LEAF_UNWIND`]); the pad region after it has one with the handler
/// ([`pe_region_unwind_info`]).
pub(super) fn unwind_pe(funcs: &[FuncCode], mode: Mode, relocs: &mut Vec<Reloc>) -> Vec<(Section, Vec<u8>)> {
    let rva = |section, offset, target, addend| Reloc { section, offset, target, addend, kind: RelocKind::Rva32 };
    let (mut pdata, mut xdata) = (Vec::new(), Vec::new());
    let entry = |pdata: &mut Vec<u8>, relocs: &mut Vec<Reloc>, start: u32, end: u32, x: i64| {
        let p = pdata.len() as u64;
        relocs.push(rva(Section::Pdata, p, RelocTarget::Section(Section::Text), start as i64));
        relocs.push(rva(Section::Pdata, p + 4, RelocTarget::Section(Section::Text), end as i64));
        relocs.push(rva(Section::Pdata, p + 8, RelocTarget::Section(Section::Xdata), x));
        pdata.extend_from_slice(&[0; 12]);
    };
    // `info` with the handler and its data, the relocation of its RVA.
    let with_handler = |xdata: &mut Vec<u8>, relocs: &mut Vec<Reloc>, info: &[u8], data: &[u8]| {
        let (bytes, field) = pe_with_handler(info, data);
        relocs.push(rva(Section::Xdata, (xdata.len() + field) as u64, RelocTarget::SehHandler, 0));
        xdata.extend_from_slice(&bytes);
    };
    for f in funcs {
        let lsda = asm::lsda::write(&f.call_sites);
        let region = if f.region < f.len { f.region } else { 0 };
        entry(&mut pdata, relocs, f.start, f.start + f.entry_stub, xdata.len() as i64);
        let ef = EhFunc { len: f.len, frame_size: f.frame_size, prologue: f.prologue, entry_stub: f.entry_stub };
        with_handler(&mut xdata, relocs, &pe_unwind_info(&ef, mode), &pe_handler_data(0, region, &lsda));
        if f.entry_stub < f.region {
            entry(&mut pdata, relocs, f.start + f.entry_stub, f.start + f.region, xdata.len() as i64);
            xdata.extend_from_slice(&PE_LEAF_UNWIND);
        }
        if region != 0 {
            entry(&mut pdata, relocs, f.start + region, f.start + f.len, xdata.len() as i64);
            with_handler(&mut xdata, relocs, &pe_region_unwind_info(), &pe_handler_data(region, region, &lsda));
        }
    }
    vec![(Section::Pdata, pdata), (Section::Xdata, xdata)]
}

/// The PE `UNWIND_INFO` of code without a frame: version 1, no prologue, no codes, so the
/// return address is at `rsp` (a leaf).
pub const PE_LEAF_UNWIND: [u8; 4] = [1, 0, 0, 0];

/// The PE `UNWIND_INFO` (x64, version 1, no handler, 4-byte aligned) of a function encoded in
/// PE `mode` with the shared prologue at `f.prologue`: `push rbp; mov rbp, rsp`, then for
/// frames from [`asm::PROBE_FROM`] the probe (`mov eax, F; call` it, through `r11` with
/// [`Mode::far_rt`]), then `sub rsp, F` unless 0. `rbp` is the frame register, at `rsp` once
/// set (frame offset 0), so past the prologue `rsp` may move freely (the JIT's OSR entries).
/// The unwind codes, last operation first: the allocation (`UWOP_ALLOC_SMALL`, or
/// `UWOP_ALLOC_LARGE` with a 16-bit or 32-bit size), `UWOP_SET_FPREG`, `UWOP_PUSH_NONVOL` of
/// `rbp`.
pub fn pe_unwind_info(f: &EhFunc, mode: Mode) -> Vec<u8> {
    debug_assert!(mode.pe);
    let p = f.prologue;
    let sub_end = p + asm::prologue_len(f.frame_size, mode);
    let mut ops = vec![(p + 1, PeUnwindOp::Push(5)), (p + 4, PeUnwindOp::SetFpreg)];
    if f.frame_size != 0 {
        ops.push((sub_end, PeUnwindOp::Alloc(f.frame_size)));
    }
    pe_unwind_codes(sub_end, 0, &ops)
}

/// An operation of a PE prologue ([`pe_unwind_codes`]); registers by their x86 number.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum PeUnwindOp {
    /// `push reg` (`UWOP_PUSH_NONVOL`).
    Push(u8),
    /// `sub rsp, n` (`UWOP_ALLOC_SMALL` or `UWOP_ALLOC_LARGE`), `n` a multiple of 8.
    Alloc(u32),
    /// The frame register's `lea rbp, [rsp + 16 * offset]` (`UWOP_SET_FPREG`).
    SetFpreg,
    /// `mov [frame + off], reg` (`UWOP_SAVE_NONVOL`), `off` from the frame base (`rbp - 16 *
    /// offset` once set), a multiple of 8.
    Save(u8, u32),
    /// `movaps [frame + off], xmm` (`UWOP_SAVE_XMM128`), `off` a multiple of 16.
    SaveXmm(u8, u32),
}

/// The PE `UNWIND_INFO` (x64, version 1, no handler, 4-byte aligned) of a prologue of
/// `prologue_len` bytes whose operations `ops` end at the given offsets, in code order, with
/// `rbp` as the frame register at `rsp + 16 * fp_offset` (scaled, at most 15).
pub fn pe_unwind_codes(prologue_len: u32, fp_offset: u32, ops: &[(u32, PeUnwindOp)]) -> Vec<u8> {
    assert!(fp_offset < 16, "the frame register within 240 bytes of rsp");
    unwind_codes(prologue_len, 5 | (fp_offset as u8) << 4, ops)
}

/// The PE `UNWIND_INFO` (as [`pe_unwind_codes`]) of a VM function's pad region
/// (design/vm.md#unwinding): its entry `sub rsp, PE_REGION_ALLOC` is the whole prologue, and
/// there is no frame register (`rbp` is the function's `fp`, not the region's frame).
pub fn pe_region_unwind_info() -> Vec<u8> {
    let sub = asm::x86::Item::SubRsp(asm::PE_REGION_ALLOC).len();
    unwind_codes(sub, 0, &[(sub, PeUnwindOp::Alloc(asm::PE_REGION_ALLOC))])
}

/// The PE `UNWIND_INFO` (as [`pe_unwind_codes`]) of the SSA tier's OSR code up to where an
/// entry has stored the callee-saved registers' saves (design/jit.md, "Unwinding and
/// profiling"): the AOT frame's, `rbp` saved at `fp` and the frame register at offset 0, no
/// prologue; the caller's other registers are still in place.
pub fn pe_osr_unwind_info() -> Vec<u8> {
    pe_unwind_codes(0, 0, &[(0, PeUnwindOp::Push(5)), (0, PeUnwindOp::SetFpreg)])
}

/// The flags of an `UNWIND_INFO` with a language handler that both phases call
/// (`UNW_FLAG_EHANDLER | UNW_FLAG_UHANDLER`), in place in its first byte.
pub const PE_HANDLER_FLAGS: u8 = (1 | 2) << 3;

/// `info`, an `UNWIND_INFO` without a handler ([`pe_unwind_codes`]), with the language
/// handler both phases call ([`PE_HANDLER_FLAGS`]): after the codes (whose array is padded to
/// an even count) the handler's RVA, 0 here, then the handler data `data`, padded to 4. Also
/// returns the RVA field's offset, which the caller relocates.
pub fn pe_with_handler(info: &[u8], data: &[u8]) -> (Vec<u8>, usize) {
    debug_assert!(info.len() % 4 == 0 && info[0] & 0xf8 == 0, "an UNWIND_INFO without flags");
    let mut out = info.to_vec();
    out[0] |= PE_HANDLER_FLAGS;
    let rva = out.len();
    out.extend_from_slice(&[0; 4]);
    out.extend_from_slice(data);
    while out.len() % 4 != 0 {
        out.push(0);
    }
    (out, rva)
}

/// The handler data of a VM function's `UNWIND_INFO` on PE, which `ryo_seh_handler` reads
/// ([`PeHandlerData`]): the offset of the entry's range from the function's start, the pad
/// region's offset (0 if there is none), the LSDA's length, then the LSDA ([`asm::lsda`],
/// offsets from the function's start), all `u32`s little-endian.
pub fn pe_handler_data(begin: u32, region: u32, lsda: &[u8]) -> Vec<u8> {
    let mut out = Vec::with_capacity(12 + lsda.len());
    for v in [begin, region, lsda.len() as u32] {
        out.extend_from_slice(&v.to_le_bytes());
    }
    out.extend_from_slice(lsda);
    out
}

/// [`pe_unwind_codes`] with the frame register byte `frame` (0 for none).
fn unwind_codes(prologue_len: u32, frame: u8, ops: &[(u32, PeUnwindOp)]) -> Vec<u8> {
    assert!(prologue_len < 256, "a PE prologue ends within 255 bytes");
    // Unwind codes, last operation first: (offset after the operation, op | info << 4, extra
    // slots).
    let mut codes: Vec<u8> = Vec::new();
    for &(at, op) in ops.iter().rev() {
        debug_assert!(at <= prologue_len);
        let at = at as u8;
        match op {
            PeUnwindOp::Push(r) => codes.extend_from_slice(&[at, r << 4]),
            PeUnwindOp::Alloc(n) => {
                debug_assert!(n % 8 == 0 && n != 0);
                if n <= 128 {
                    codes.extend_from_slice(&[at, 2 | (((n / 8 - 1) as u8) << 4)]);
                } else if n <= 512 * 1024 - 8 {
                    codes.extend_from_slice(&[at, 1]);
                    codes.extend_from_slice(&((n / 8) as u16).to_le_bytes());
                } else {
                    codes.extend_from_slice(&[at, 1 | 1 << 4]);
                    codes.extend_from_slice(&n.to_le_bytes());
                }
            }
            PeUnwindOp::SetFpreg => codes.extend_from_slice(&[at, 3]),
            PeUnwindOp::Save(r, off) | PeUnwindOp::SaveXmm(r, off) => {
                let (scale, near, far) = if matches!(op, PeUnwindOp::Save(..)) { (8, 4, 5) } else { (16, 8, 9) };
                debug_assert!(off % scale == 0);
                if off / scale <= 0xffff {
                    codes.extend_from_slice(&[at, near | r << 4]);
                    codes.extend_from_slice(&((off / scale) as u16).to_le_bytes());
                } else {
                    codes.extend_from_slice(&[at, far | r << 4]);
                    codes.extend_from_slice(&off.to_le_bytes());
                }
            }
        }
    }
    let slots = codes.len() / 2;
    // Version 1, no flags; the frame register.
    let mut out = vec![1, prologue_len as u8, slots as u8, frame];
    out.extend_from_slice(&codes);
    while out.len() % 4 != 0 {
        out.push(0);
    }
    out
}
