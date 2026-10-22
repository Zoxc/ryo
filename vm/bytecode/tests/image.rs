use ryo_bytecode::asm::{self, Mode};
use ryo_bytecode::image::*;
use ryo_bytecode::insn::*;
use ryo_bytecode::{FORMAT_VERSION, Insn};

const ELF: Mode = Mode { fp_arg: false, frame_pointer: true, align_loops: true, pe: false };

fn code(insns: &[Insn<'_>]) -> Vec<u32> {
    let mut c = CodeBuf::new();
    for i in insns {
        c.emit(i);
    }
    c.words
}

/// An 8-aligned (or more) byte buffer.
struct Buf {
    mem: Vec<u128>,
    len: usize,
}
impl Buf {
    fn new(bytes: &[u8], align: u64) -> Buf {
        assert!(align <= 16);
        let mut mem = vec![0u128; bytes.len().div_ceil(16) + 1];
        let b = unsafe { std::slice::from_raw_parts_mut(mem.as_mut_ptr().cast::<u8>(), bytes.len()) };
        b.copy_from_slice(bytes);
        Buf { mem, len: bytes.len() }
    }
    fn addr(&self) -> u64 {
        self.mem.as_ptr() as u64
    }
    fn bytes(&self) -> &[u8] {
        unsafe { std::slice::from_raw_parts(self.mem.as_ptr().cast(), self.len) }
    }
    fn write_u64(&mut self, off: u64, v: u64) {
        unsafe { (self.mem.as_mut_ptr().cast::<u8>().add(off as usize) as *mut u64).write_unaligned(v) }
    }
    fn read_u64(&self, off: u64) -> u64 {
        u64::from_le_bytes(self.bytes()[off as usize..off as usize + 8].try_into().unwrap())
    }
}

/// A linked image: the read-only, writable and text sections.
struct Linked {
    ro: Buf,
    data: Buf,
    text: Buf,
}

/// Links an image object the way the system linker would: places the sections and applies
/// every relocation (the unwind sections' aren't), resolving symbols through `resolve` and
/// `ryo_rt`'s handlers to 0x7000 + the opcode.
fn link(obj: &ImageObject, resolve: impl Fn(&SymbolDef) -> u64) -> Linked {
    let mut l = Linked {
        ro: Buf::new(&obj.rodata, obj.rodata_align),
        data: Buf::new(&obj.data, obj.data_align),
        text: Buf::new(&obj.text, 16),
    };
    assert_eq!(l.ro.addr() % obj.rodata_align, 0);
    for r in &obj.relocs {
        let target = match r.target {
            RelocTarget::Symbol(s) => resolve(&obj.symbols[s.0 as usize]),
            RelocTarget::Section(Section::ReadOnly) => l.ro.addr(),
            RelocTarget::Section(Section::Writable) => l.data.addr(),
            RelocTarget::Section(Section::Text) => l.text.addr(),
            RelocTarget::Section(_) => continue,
            RelocTarget::Handler(op) => 0x7000 + op as u64,
            RelocTarget::Probe => 0x6000,
        };
        let v = target.wrapping_add(r.addend as u64);
        let buf = match r.section {
            Section::ReadOnly => &mut l.ro,
            Section::Writable => &mut l.data,
            Section::Text => &mut l.text,
            _ => continue,
        };
        match r.kind {
            RelocKind::Abs64 => buf.write_u64(r.offset, v),
            RelocKind::Pc32 | RelocKind::Call32 => {
                let field = buf.addr() + r.offset;
                let d = (v.wrapping_sub(field) as i64 as i32).to_le_bytes();
                unsafe { std::ptr::copy_nonoverlapping(d.as_ptr(), (buf.addr() + r.offset) as *mut u8, 4) };
            }
            RelocKind::Rva32 => unreachable!("ELF"),
        }
    }
    l
}

/// The i32 at `off` in `b`.
fn i32_at(b: &Buf, off: u64) -> i32 {
    i32::from_le_bytes(b.bytes()[off as usize..off as usize + 4].try_into().unwrap())
}

const SCID: u64 = 0x1234_5678_9abc_def0;

fn sample() -> ImageWriter {
    let mut w = ImageWriter::new(SCID);
    let puts = w.symbol("puts", 0);
    let imp = w.symbol("some_dll_static", SYM_INDIRECT);
    let island = w.symbol("_ZN6ryo_rt6island9call_ptr1", 0);
    let portal1 = w.symbol("_ZN4test3fooE", 0);
    let site = w.site();
    let _site2 = w.site();

    let s1 = w.add_const(b"hello\0", 1, &[]);
    let vt = w.add_const(&[0u8; 24], 8, &[
        AllocReloc { offset: 0, target: AllocTarget::Symbol(puts), addend: 0 },
        AllocReloc { offset: 8, target: AllocTarget::Const(s1), addend: 2 },
    ]);
    assert_eq!(vt.0 % 8, 0);
    let fx = w.add_data(&[7u8; 16], 8, &[AllocReloc { offset: 8, target: AllocTarget::Const(vt), addend: 0 }], &[AllocFixup { offset: 0, sym: imp, addend: 4 }]);

    // f0: calls f1 with a landing pad at 6 (`lpad; jmp`) whose block resumes, then returns.
    let f0 = code(&[
        Insn::Call { d: Slot(-8), f: Func(1) },
        Insn::Ret { s: Slot(-8), len: 8 },
        Insn::Lpad { x: Slot(-16) },
        Insn::Jmp { t: Target(2) },
        Insn::Resume { x: Slot(-16) },
    ]);
    w.add_function(FunctionDef {
        name: "f0".into(),
        code: f0,
        frame_size: 48,
        arg_size: 8,
        ret_size: 8,
        cleanup: vec![CleanupEntry { offset: 0, target: 6 }, CleanupEntry { offset: 10, target: CONTINUE }],
        portal: None,
    });
    let ops = [16u32, -24i32 as u32];
    let f1 = code(&[
        Insn::CallExt { d: Slot(-8), sym: puts, site, isl: island, f: Slot(-16) },
        Insn::Island { isl: island, ops: List::from_words(&ops) },
        Insn::AddrAbs { d: Slot(-8), a: Abs::Const(vt) },
        Insn::AddrAbs { d: Slot(-16), a: Abs::Data(fx) },
        Insn::Ret { s: Slot(-8), len: 8 },
    ]);
    w.add_function(FunctionDef {
        name: "f1".into(),
        code: f1,
        frame_size: 48,
        cleanup: vec![CleanupEntry { offset: 6, target: CONTINUE }, CleanupEntry { offset: 0, target: CONTINUE }],
        portal: Some(portal1),
        ..Default::default()
    });
    w.add_function(FunctionDef { name: String::new(), code: code(&[Insn::Abort {}]), frame_size: 16, ..Default::default() });
    w
}

#[test]
fn image_round_trip() {
    let obj = sample().finish(ELF).unwrap();
    // puts, some_dll_static, the island, f1's portal, rust_eh_personality.
    assert_eq!(obj.symbols.len(), 5);
    assert_eq!(obj.symbols[4].name, PERSONALITY);

    // Unlinked bytes parse too.
    let unlinked = Buf::new(&obj.rodata, obj.rodata_align);
    let img = Image::parse(unlinked.bytes()).unwrap();
    img.validate().unwrap();
    assert!(img.data_ptr().is_null() && img.text_ptr().is_null());

    let real_static: Box<u64> = Box::new(0x5000);
    let imp_cell: Box<u64> = Box::new(&*real_static as *const u64 as u64);
    let imp_addr = &*imp_cell as *const u64 as u64;
    let l = link(&obj, |s| match s.name.as_str() {
        "some_dll_static" => imp_addr,
        "puts" => 0x1000,
        n => 0x2000 + n.len() as u64,
    });
    let img = unsafe { Image::from_header(l.ro.bytes().as_ptr()) }.unwrap();
    img.validate().unwrap();
    let h = img.header();
    assert_eq!(h.magic, MAGIC);
    assert_eq!(h.version, FORMAT_VERSION);
    assert_eq!(h.stable_crate_id, SCID);
    assert_eq!(img.crate_hash(), crate_hash(SCID));
    assert_eq!(img.data_ptr() as u64, l.data.addr());
    assert_eq!(img.text_ptr() as u64, l.text.addr());
    assert_eq!(h.text_size as usize, obj.text.len());
    assert_eq!(h.site_count, 2);
    assert_eq!(h.fixup_area, 16);

    // Functions: machine code, each aligned to 16, in order.
    let fs = img.functions();
    assert_eq!(fs.len(), 3);
    assert_eq!(fs[0].code_off, 0);
    assert_eq!(fs[1].code_off, fs[0].code_len.next_multiple_of(16));
    assert_eq!((fs[0].arg_size, fs[0].ret_size, fs[1].arg_size), (8, 8, 0));
    assert_eq!(fs[0].portal(), None);
    assert_eq!(fs[1].portal(), Some(3));
    assert_eq!(img.symbols()[3], 0x2000 + "_ZN4test3fooE".len() as u64);
    assert_eq!(img.symbols()[0], 0x1000);
    assert_eq!(img.symbol_flags(), &[0, SYM_INDIRECT, 0, 0, 0]);
    assert_eq!(img.portal_id(1), portal_id(crate_hash(SCID), 1));
    assert_eq!(split_portal_id(img.portal_id(1)), (crate_hash(SCID), 1));
    assert_eq!(obj.functions.iter().map(|f| f.name.as_str()).collect::<Vec<_>>(), ["f0", "f1", ""]);
    assert_eq!(obj.functions[0].frame_size, 48);

    // f0's code: the prologue, then `call f1` resolved within the text, then the marker.
    let t = l.text.bytes();
    assert_eq!(&t[..8], [0x55, 0x48, 0x89, 0xe5, 0x48, 0x83, 0xec, 48]);
    assert_eq!(t[8], 0xe8);
    assert_eq!(9 + 4 + i32_at(&l.text, 9) as i64, fs[1].code_off as i64);
    assert_eq!(&t[13..16], asm::CALL_MARKER);
    assert_eq!(i32_at(&l.text, 16), 48 - 8); // the destination `fp - 8`, relative to `rsp`
    // f1's `call.ext`: `lea rdi, [rip + sym slot 0]` reaches the slot.
    let at = fs[1].code_off as u64 + 4 + 4; // after the prologue (`sub rsp, 48`)
    assert_eq!(&t[at as usize..at as usize + 3], [0x48, 0x8d, 0x3d]);
    let slot = (l.text.addr() + at + 7).wrapping_add(i32_at(&l.text, at + 3) as i64 as u64);
    assert_eq!(slot, img.symbols_ptr() as u64);

    // Unwind information: f0's call and resume are call sites, f0's to its landing pad.
    assert_eq!(obj.functions[0].call_sites.len(), 2);
    assert!(obj.functions[0].call_sites[0].pad.is_some() && obj.functions[0].call_sites[1].pad.is_none());
    assert_eq!(obj.functions[1].call_sites.len(), 3); // `call rax`, the island call, the island
    assert!(obj.functions[2].call_sites.is_empty());
    let secs: Vec<_> = obj.unwind.iter().map(|u| u.0).collect();
    assert_eq!(secs, [Section::EhFrame, Section::Lsda]);
    // One CIE, then one FDE per function, each pointing at its code and LSDA.
    let fdes = obj.relocs.iter().filter(|r| r.section == Section::EhFrame && r.target == RelocTarget::Section(Section::Text)).count();
    assert_eq!(fdes, 3);

    // pc → function.
    let c1 = fs[1].code_off;
    assert_eq!(img.function_at(0), Some((0, 0)));
    assert_eq!(img.function_at(c1 + 3), Some((1, 3)));
    assert_eq!(img.function_at(fs[2].code_off), Some((2, 0)));
    assert_eq!(img.function_at(h.text_size), None);

    // Constants, with relocated pointers.
    let k = img.consts();
    assert_eq!(&k[..6], b"hello\0");
    let vt_off = 8usize;
    let p0 = u64::from_le_bytes(k[vt_off..vt_off + 8].try_into().unwrap());
    let p1 = u64::from_le_bytes(k[vt_off + 8..vt_off + 16].try_into().unwrap());
    assert_eq!(p0, 0x1000);
    assert_eq!(p1, k.as_ptr() as u64 + 2);
    assert_eq!(k.as_ptr() as u64 % 8, 0);
    // The island operand arrays are code constants.
    assert!(!img.code_consts().is_empty());

    // Writable section: zeroed site cache, fixup area with an intra-image pointer, and the
    // PE fixup applied at registration.
    let data = &l.data;
    assert_eq!(data.read_u64(0), 0);
    assert_eq!(data.read_u64(8), 0);
    assert_eq!(data.read_u64(24), k.as_ptr() as u64 + vt_off as u64);
    assert_eq!(data.read_u64(16), 0x0707070707070707);
    unsafe { img.apply_fixups() };
    assert_eq!(data.read_u64(16), &*real_static as *const u64 as u64 + 4);
    assert_eq!(img.fixup_area() as u64, data.addr() + 16);
}

#[test]
fn elf_unwind_without_frame_pointer() {
    let obj = sample().finish(Mode { fp_arg: true, frame_pointer: false, ..ELF }).unwrap();
    // f0: `sub rsp, 56` (F + 8) is the whole prologue.
    assert_eq!(&obj.text[..4], [0x48, 0x83, 0xec, 56]);
    // Its FDE: after 4 bytes, CFA = rsp + 64 (F + 16).
    let eh = &obj.unwind[0].1;
    assert!(eh.windows(3).any(|w| w == [0x44, 0x0e, 64]), "{eh:02x?}");
    assert!(!eh.windows(2).any(|w| w == [0x0d, 6]), "a CFA in rbp: {eh:02x?}");
}

#[test]
fn pe_unwind_info() {
    let obj = sample().finish(Mode { pe: true, ..ELF }).unwrap();
    let secs: Vec<_> = obj.unwind.iter().map(|u| u.0).collect();
    assert_eq!(secs, [Section::Pdata, Section::Xdata]);
    assert_eq!(obj.unwind[0].1.len(), 3 * 12);
    // f0: version 1, prologue 8 bytes, 3 codes (alloc small 48, set fpreg, push rbp), rbp.
    assert_eq!(&obj.unwind[1].1[..10], [1, 8, 3, 5, 8, 2 | (48 / 8 - 1) << 4, 4, 3, 1, 5 << 4]);
    assert_eq!(obj.relocs.iter().filter(|r| r.kind == RelocKind::Rva32).count(), 9);
    // No personality on PE.
    assert_eq!(obj.symbols.len(), 4);
}

#[test]
fn empty_image() {
    let obj = ImageWriter::new(1).finish(ELF).unwrap();
    let b = Buf::new(&obj.rodata, obj.rodata_align);
    let img = Image::parse(b.bytes()).unwrap();
    img.validate().unwrap();
    assert!(img.functions().is_empty() && obj.text.is_empty() && img.consts().is_empty());
    assert_eq!(img.function_at(0), None);
    // `data`, `text`, the personality slot.
    assert_eq!(obj.relocs.iter().filter(|r| r.kind == RelocKind::Abs64).count(), 3);
}

#[test]
fn reader_rejects_bad_images() {
    let obj = sample().finish(ELF).unwrap();
    let patch = |off: usize, v: &[u8]| {
        let mut r = obj.rodata.clone();
        r[off..off + v.len()].copy_from_slice(v);
        Buf::new(&r, 8)
    };
    assert_eq!(Image::parse(patch(0, b"X").bytes()).unwrap_err(), ImageError::BadMagic);
    assert_eq!(Image::parse(patch(8, &99u32.to_le_bytes()).bytes()).unwrap_err(), ImageError::Version(99));
    let b = Buf::new(&obj.rodata, 8);
    assert_eq!(Image::parse(&b.bytes()[..50]).unwrap_err(), ImageError::Truncated);
    assert_eq!(Image::parse(&b.bytes()[..b.len - 1]).unwrap_err(), ImageError::Truncated);
    let shifted = Buf::new(&[&[0u8][..], &obj.rodata].concat(), 8);
    assert_eq!(Image::parse(&shifted.bytes()[1..]).unwrap_err(), ImageError::Misaligned);
    // Function count past the end.
    let fcount = std::mem::offset_of!(Header, functions) + 4;
    assert!(matches!(Image::parse(patch(fcount, &u32::MAX.to_le_bytes()).bytes()), Err(ImageError::OutOfBounds(_))));
    // Unsorted function table.
    let f1_code_off = Image::parse(b.bytes()).unwrap().header().functions.off as usize + std::mem::size_of::<FuncEntry>();
    let bad = patch(f1_code_off, &0u32.to_le_bytes());
    let img = Image::parse(bad.bytes()).unwrap();
    assert_eq!(img.validate(), Err(ImageError::BadFunction(1)));
}

#[test]
fn writer_rejects_bad_code() {
    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef { name: String::new(), code: code(&[Insn::Jmp { t: Target(1) }]), ..Default::default() });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { func: 0, offset: 0, error: CodeError::BadTarget })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef {
        code: code(&[Insn::Abort {}, Insn::Br { s: Slot(-1), neg: Neg(false), t: Target(-1) }]),
        ..Default::default()
    });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { error: CodeError::FallsOffEnd, .. })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef { name: String::new(), code: code(&[Insn::Call { d: Slot(-8), f: Func(5) }, Insn::Abort {}]), ..Default::default() });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { error: CodeError::FuncOutOfRange, .. })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef { name: String::new(), code: code(&[Insn::AddrSym { d: Slot(0), sym: Sym(5) }, Insn::Abort {}]), ..Default::default() });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { error: CodeError::SymOutOfRange, .. })));

    // Cleanup entries: not on an instruction start, not on a call, a landing pad that isn't
    // an `lpad`.
    for (offset, target) in [(1, CONTINUE), (3, CONTINUE), (0, 3)] {
        let mut w = ImageWriter::new(1);
        w.add_function(FunctionDef {
            code: code(&[Insn::Call { d: Slot(-8), f: Func(0) }, Insn::Abort {}, Insn::Lpad { x: Slot(-16) }, Insn::Abort {}]),
            cleanup: vec![CleanupEntry { offset, target }],
            ..Default::default()
        });
        assert_eq!(w.finish(ELF).unwrap_err(), WriteError::Cleanup(0), "{offset} {target}");
    }

    // Switch table target out of the function.
    let mut w = ImageWriter::new(1);
    let t = list_words([Target(0), Target(100)]);
    w.add_function(FunctionDef {
        code: code(&[Insn::SwitchDenseW32 { s: Slot(0), base: 0, default: Target(0), table: List::from_words(&t) }]),
        ..Default::default()
    });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { error: CodeError::BadTarget, .. })));

    // Fixups need an indirect symbol.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", 0);
    w.add_data(&[0; 8], 8, &[], &[AllocFixup { offset: 0, sym: s, addend: 0 }]);
    assert_eq!(w.finish(ELF).unwrap_err(), WriteError::AllocReloc);
}

#[test]
fn writer_checks_symbol_indirection() {
    // Only `addr.sym.ind` and `call.ext.ind`'s `sym` load through the slot, and they need an
    // indirect one (design/platforms.md).
    let check = |indirect: u8, insn: fn(Sym, Sym, Site) -> Insn<'static>| {
        let mut w = ImageWriter::new(1);
        let s = w.symbol("x", indirect);
        let island = w.symbol("island", 0);
        let site = w.site();
        w.add_function(FunctionDef { name: String::new(), code: code(&[insn(s, island, site), Insn::Abort {}]), ..Default::default() });
        w.finish(ELF).map(drop)
    };
    let bad = Err(WriteError::Code { func: 0, offset: 0, error: CodeError::SymIndirection });
    let addr_ind: fn(Sym, Sym, Site) -> Insn<'static> = |s, _, _| Insn::AddrSymInd { d: Slot(0), sym: s };
    let addr: fn(Sym, Sym, Site) -> Insn<'static> = |s, _, _| Insn::AddrSym { d: Slot(0), sym: s };
    let ext_ind: fn(Sym, Sym, Site) -> Insn<'static> =
        |s, island, site| Insn::CallExtInd { d: Slot(0), sym: s, site, isl: island, f: Slot(-8) };
    let ext: fn(Sym, Sym, Site) -> Insn<'static> = |s, island, site| Insn::CallExt { d: Slot(0), sym: s, site, isl: island, f: Slot(-8) };
    // `x` as the island: islands are always direct.
    let island_ind: fn(Sym, Sym, Site) -> Insn<'static> =
        |s, island, site| Insn::CallExtInd { d: Slot(0), sym: island, site, isl: s, f: Slot(-8) };
    assert_eq!(check(SYM_INDIRECT, addr_ind), Ok(()));
    assert_eq!(check(SYM_INDIRECT, ext_ind), Ok(()));
    assert_eq!(check(0, addr), Ok(()));
    assert_eq!(check(0, ext), Ok(()));
    assert_eq!(check(0, addr_ind), bad);
    assert_eq!(check(0, ext_ind), bad);
    assert_eq!(check(SYM_INDIRECT, addr), bad);
    assert_eq!(check(SYM_INDIRECT, ext), bad);
    assert_eq!(check(SYM_INDIRECT, island_ind), bad);

    // One upstream function both called through its import slot and used as an island:
    // an indirect and a direct slot of the same name.
    let mut w = ImageWriter::new(1);
    let ind = w.symbol("f", SYM_INDIRECT);
    let dir = w.symbol("f", 0);
    assert_ne!(ind, dir);
    let site = w.site();
    w.add_function(FunctionDef {
        code: code(&[Insn::CallExtInd { d: Slot(0), sym: ind, site, isl: dir, f: Slot(-8) }, Insn::Abort {}]),
        ..Default::default()
    });
    let obj = w.finish(ELF).unwrap();
    assert_eq!(obj.symbols.iter().map(|s| (s.name.as_str(), s.flags)).collect::<Vec<_>>(), [("f", SYM_INDIRECT), ("f", 0), (PERSONALITY, 0)]);

    // Portals are local definitions: never indirect.
    let mut w = ImageWriter::new(1);
    let p = w.symbol("p", SYM_INDIRECT);
    w.add_function(FunctionDef { name: String::new(), code: code(&[Insn::Abort {}]), portal: Some(p), ..Default::default() });
    assert_eq!(w.finish(ELF).unwrap_err(), WriteError::Portal(0));
}

#[test]
fn symbols_are_interned() {
    let mut w = ImageWriter::new(1);
    assert_eq!(w.symbol("a", 0), Sym(0));
    assert_eq!(w.symbol("b", SYM_INDIRECT), Sym(1));
    assert_eq!(w.symbol("a", 0), Sym(0));
    // The same symbol direct and indirect: two slots.
    assert_eq!(w.symbol("b", 0), Sym(2));
    assert_eq!(w.symbol("a", SYM_INDIRECT), Sym(3));
    assert_eq!(w.symbol("b", SYM_INDIRECT), Sym(1));
}

#[test]
fn portal_ids() {
    assert_eq!(portal_id(0xdead_beef, 7), 0xdead_beef_0000_0007);
    assert_eq!(split_portal_id(0xdead_beef_0000_0007), (0xdead_beef, 7));
    assert_eq!(crate_hash(0x1111_1111_0000_0001), 0x1111_1110);
}

/// Parses `obj` after applying `edit` to its read-only bytes, and runs `validate`.
fn validate_edited(obj: &ImageObject, edit: impl FnOnce(&mut Vec<u8>, &Header)) -> Result<(), ImageError> {
    let h = *Image::parse(Buf::new(&obj.rodata, 8).bytes()).unwrap().header();
    let mut r = obj.rodata.clone();
    edit(&mut r, &h);
    let b = Buf::new(&r, 8);
    Image::parse(b.bytes())?.validate()
}

fn put32(r: &mut [u8], off: usize, v: u32) {
    r[off..off + 4].copy_from_slice(&v.to_le_bytes());
}

#[test]
fn validate_rejects_bad_tables() {
    use std::mem::{offset_of, size_of};
    let obj = sample().finish(ELF).unwrap();
    let fe = |h: &Header, i: usize, field: usize| h.functions.off as usize + i * size_of::<FuncEntry>() + field;
    // Portal symbol out of range.
    assert_eq!(
        validate_edited(&obj, |r, h| put32(r, fe(h, 1, offset_of!(FuncEntry, portal)), 77)),
        Err(ImageError::BadFunction(1))
    );
    // Code past the end.
    assert_eq!(
        validate_edited(&obj, |r, h| put32(r, fe(h, 2, offset_of!(FuncEntry, code_len)), 1000)),
        Err(ImageError::BadFunction(2))
    );
    // Fixups: unaligned, out of range, inside the site cache, bad symbol.
    let fx = |h: &Header| h.fixups.off as usize;
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fx(h), 17)), Err(ImageError::BadFixup(0)));
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fx(h), 4096)), Err(ImageError::BadFixup(0)));
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fx(h), 8)), Err(ImageError::BadFixup(0)));
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fx(h) + 4, 5)), Err(ImageError::BadFixup(0)));
    // Unknown symbol flag bits.
    assert_eq!(validate_edited(&obj, |r, h| r[h.sym_flags.off as usize + 2] = 0x80), Err(ImageError::BadSymbolFlags(2)));
    assert_eq!(validate_edited(&obj, |_, _| ()), Ok(()));
}

#[test]
fn writer_rejects_bad_alloc_relocs() {
    // Unaligned pointer in a constant.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", 0);
    w.add_const(&[0; 16], 8, &[AllocReloc { offset: 4, target: AllocTarget::Symbol(s), addend: 0 }]);
    assert_eq!(w.finish(ELF).unwrap_err(), WriteError::AllocReloc);
    // A fixup and a relocation at the same place.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", SYM_INDIRECT);
    let t = w.symbol("y", 0);
    w.add_data(
        &[0; 8],
        8,
        &[AllocReloc { offset: 0, target: AllocTarget::Symbol(t), addend: 0 }],
        &[AllocFixup { offset: 0, sym: s, addend: 0 }],
    );
    assert_eq!(w.finish(ELF).unwrap_err(), WriteError::AllocReloc);
    // A pointer to an indirect symbol's target must be a fixup, not a relocation.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", SYM_INDIRECT);
    w.add_const(&[0; 8], 8, &[AllocReloc { offset: 0, target: AllocTarget::Symbol(s), addend: 0 }]);
    assert_eq!(w.finish(ELF).unwrap_err(), WriteError::AllocReloc);
    // The fixup area is 8-aligned even after an odd number of sites and 1-aligned data.
    let mut w = ImageWriter::new(1);
    w.site();
    w.site();
    w.site();
    let d = w.add_data(&[1], 1, &[], &[]);
    let obj = w.finish(ELF).unwrap();
    let b = Buf::new(&obj.rodata, 8);
    assert_eq!(Image::parse(b.bytes()).unwrap().header().fixup_area, 24);
    assert_eq!(d, Data(0));
    assert_eq!(obj.data_align, 8);
}
