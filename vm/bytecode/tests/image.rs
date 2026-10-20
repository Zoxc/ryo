use ryo_bytecode::image::*;
use ryo_bytecode::insn::*;
use ryo_bytecode::{FORMAT_VERSION, Insn};

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

/// Links an image object the way the system linker would: places both sections and applies
/// every relocation, resolving symbols through `resolve`.
fn link(obj: &ImageObject, resolve: impl Fn(&SymbolDef) -> u64) -> (Buf, Buf) {
    let mut ro = Buf::new(&obj.rodata, obj.rodata_align);
    let mut data = Buf::new(&obj.data, obj.data_align);
    assert_eq!(ro.addr() % obj.rodata_align, 0);
    for r in &obj.relocs {
        let target = match r.target {
            RelocTarget::Symbol(s) => resolve(&obj.symbols[s.0 as usize]),
            RelocTarget::Section(Section::ReadOnly) => ro.addr(),
            RelocTarget::Section(Section::Writable) => data.addr(),
        };
        let v = target.wrapping_add(r.addend as u64);
        match r.section {
            Section::ReadOnly => ro.write_u64(r.offset, v),
            Section::Writable => data.write_u64(r.offset, v),
        }
    }
    (ro, data)
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

    // f0: calls f1 with a cleanup, then returns.
    let f0 = code(&[
        Insn::Call { d: Slot(16), f: Func(1), frame_size: 32 },
        Insn::Ret { s: Slot(16), len: 8 },
        Insn::Resume {},
    ]);
    w.add_function(FunctionDef {
        code: f0,
        frame_size: 32,
        max_outgoing: 48,
        arg_size: 8,
        ret_size: 8,
        cleanup: vec![CleanupEntry { offset: 0, target: 7 }],
        portal: None,
    });
    let t = list_words([Target(7)]);
    let ops = [16u32, 24];
    let f1 = code(&[
        Insn::CallExt { d: Slot(16), sym: puts, site, island },
        Insn::Island { sym: island, ops: List::from_words(&ops), targets: List::from_words(&t) },
        Insn::AddrK { d: Slot(16), k: vt },
        Insn::AddrData { d: Slot(24), off: fx },
        Insn::Ret { s: Slot(16), len: 8 },
    ]);
    w.add_function(FunctionDef {
        code: f1,
        frame_size: 48,
        cleanup: vec![CleanupEntry { offset: 5, target: TERMINATE }, CleanupEntry { offset: 0, target: TERMINATE }],
        portal: Some(portal1),
        ..Default::default()
    });
    w.add_function(FunctionDef { code: code(&[Insn::Abort {}]), frame_size: 16, ..Default::default() });
    w
}

#[test]
fn image_round_trip() {
    let obj = sample().finish().unwrap();
    assert_eq!(obj.symbols.len(), 4);
    assert_eq!(obj.relocs.iter().filter(|r| r.target == RelocTarget::Section(Section::Writable)).count(), 1);

    // Unlinked bytes parse too.
    let unlinked = Buf::new(&obj.rodata, obj.rodata_align);
    let img = Image::parse(unlinked.bytes()).unwrap();
    img.validate().unwrap();
    assert!(img.data_ptr().is_null());

    let real_static: Box<u64> = Box::new(0x5000);
    let imp_cell: Box<u64> = Box::new(&*real_static as *const u64 as u64);
    let imp_addr = &*imp_cell as *const u64 as u64;
    let (ro, data) = link(&obj, |s| match s.name.as_str() {
        "some_dll_static" => imp_addr,
        "puts" => 0x1000,
        n => 0x2000 + n.len() as u64,
    });
    let img = unsafe { Image::from_header(ro.bytes().as_ptr()) }.unwrap();
    img.validate().unwrap();
    let h = img.header();
    assert_eq!(h.magic, MAGIC);
    assert_eq!(h.version, FORMAT_VERSION);
    assert_eq!(h.stable_crate_id, SCID);
    assert_eq!(img.crate_hash(), crate_hash(SCID));
    assert_eq!(img.data_ptr() as u64, data.addr());
    assert_eq!(h.site_count, 2);
    assert_eq!(h.fixup_area, 16);

    // Functions.
    let fs = img.functions();
    assert_eq!(fs.len(), 3);
    assert_eq!(fs[0].code_off, 0);
    assert_eq!(fs[1].code_off, fs[0].code_len);
    assert_eq!(fs[1].frame_size, 48);
    assert_eq!((fs[0].max_outgoing, fs[1].max_outgoing), (48, 0));
    assert_eq!((fs[0].arg_size, fs[0].ret_size, fs[1].arg_size), (8, 8, 0));
    assert_eq!(fs[0].portal(), None);
    assert_eq!(fs[1].portal(), Some(3));
    assert_eq!(img.symbols()[3], 0x2000 + "_ZN4test3fooE".len() as u64);
    assert_eq!(img.symbols()[0], 0x1000);
    assert_eq!(img.symbol_flags(), &[0, SYM_INDIRECT, 0, 0]);
    assert_eq!(img.portal_id(1), portal_id(crate_hash(SCID), 1));
    assert_eq!(split_portal_id(img.portal_id(1)), (crate_hash(SCID), 1));

    // Code decodes back.
    let f1: Vec<_> = Decoder::new(img.function_code(1).unwrap()).map(|r| r.unwrap().1).collect();
    assert!(matches!(f1[0], Insn::CallExt { d: Slot(16), sym: Sym(0), site: Site(0), island: Sym(2) }));
    assert_eq!(f1.len(), 5);

    // Cleanup tables (sorted by the writer).
    assert_eq!(img.cleanup(1).unwrap(), &[CleanupEntry { offset: 0, target: TERMINATE }, CleanupEntry { offset: 5, target: TERMINATE }]);
    assert_eq!(img.cleanup_at(0, 0), Some(Cleanup::Jump(7)));
    assert_eq!(img.cleanup_at(1, 5), Some(Cleanup::Terminate));
    assert_eq!(img.cleanup_at(1, 13), None);
    assert_eq!(img.cleanup_at(2, 0), None);

    // pc → function.
    let c1 = fs[1].code_off;
    assert_eq!(img.function_at(0), Some((0, 0)));
    assert_eq!(img.function_at(c1 + 3), Some((1, 3)));
    assert_eq!(img.function_at(fs[2].code_off), Some((2, 0)));
    assert_eq!(img.function_at(img.code().len() as u32), None);

    // Constants, with relocated pointers.
    let k = img.consts();
    assert_eq!(&k[..6], b"hello\0");
    let vt_off = 8usize;
    let p0 = u64::from_le_bytes(k[vt_off..vt_off + 8].try_into().unwrap());
    let p1 = u64::from_le_bytes(k[vt_off + 8..vt_off + 16].try_into().unwrap());
    assert_eq!(p0, 0x1000);
    assert_eq!(p1, k.as_ptr() as u64 + 2);
    assert_eq!(k.as_ptr() as u64 % 8, 0);

    // Writable section: zeroed site cache, fixup area with an intra-image pointer, and the
    // PE fixup applied at registration.
    assert_eq!(data.read_u64(0), 0);
    assert_eq!(data.read_u64(8), 0);
    assert_eq!(data.read_u64(24), k.as_ptr() as u64 + vt_off as u64);
    assert_eq!(data.read_u64(16), 0x0707070707070707);
    unsafe { img.apply_fixups() };
    assert_eq!(data.read_u64(16), &*real_static as *const u64 as u64 + 4);
    assert_eq!(img.fixup_area() as u64, data.addr() + 16);
}

#[test]
fn empty_image() {
    let obj = ImageWriter::new(1).finish().unwrap();
    let b = Buf::new(&obj.rodata, obj.rodata_align);
    let img = Image::parse(b.bytes()).unwrap();
    img.validate().unwrap();
    assert!(img.functions().is_empty() && img.code().is_empty() && img.consts().is_empty());
    assert_eq!(img.function_at(0), None);
    assert_eq!(obj.relocs.len(), 1);
}

#[test]
fn reader_rejects_bad_images() {
    let obj = sample().finish().unwrap();
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
    w.add_function(FunctionDef { code: code(&[Insn::Jmp { t: Target(1) }]), ..Default::default() });
    assert!(matches!(w.finish(), Err(WriteError::Code { func: 0, offset: 0, error: CodeError::BadTarget })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef { code: code(&[Insn::Abort {}, Insn::BrIf { s: Slot(0), t: Target(-1) }]), ..Default::default() });
    assert!(matches!(w.finish(), Err(WriteError::Code { error: CodeError::FallsOffEnd, .. })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef { code: code(&[Insn::Call { d: Slot(0), f: Func(5), frame_size: 0 }, Insn::Abort {}]), ..Default::default() });
    assert!(matches!(w.finish(), Err(WriteError::Code { error: CodeError::FuncOutOfRange, .. })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef { code: code(&[Insn::AddrSym { d: Slot(0), sym: Sym(0) }, Insn::Abort {}]), ..Default::default() });
    assert!(matches!(w.finish(), Err(WriteError::Code { error: CodeError::SymOutOfRange, .. })));

    // Cleanup entry not on an instruction start.
    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef {
        code: code(&[Insn::Call { d: Slot(0), f: Func(0), frame_size: 16 }, Insn::Abort {}]),
        cleanup: vec![CleanupEntry { offset: 1, target: TERMINATE }],
        ..Default::default()
    });
    assert_eq!(w.finish().unwrap_err(), WriteError::Cleanup(0));

    // Switch table target out of the function.
    let mut w = ImageWriter::new(1);
    let t = list_words([Target(0), Target(100)]);
    w.add_function(FunctionDef {
        code: code(&[Insn::SwitchDenseW32 { s: Slot(0), base: 0, default: Target(0), table: List::from_words(&t) }]),
        ..Default::default()
    });
    assert!(matches!(w.finish(), Err(WriteError::Code { error: CodeError::BadTarget, .. })));

    // Fixups need an indirect symbol.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", 0);
    w.add_data(&[0; 8], 8, &[], &[AllocFixup { offset: 0, sym: s, addend: 0 }]);
    assert_eq!(w.finish().unwrap_err(), WriteError::AllocReloc);
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
        w.add_function(FunctionDef { code: code(&[insn(s, island, site), Insn::Abort {}]), ..Default::default() });
        w.finish().map(drop)
    };
    let bad = Err(WriteError::Code { func: 0, offset: 0, error: CodeError::SymIndirection });
    let addr_ind: fn(Sym, Sym, Site) -> Insn<'static> = |s, _, _| Insn::AddrSymInd { d: Slot(0), sym: s };
    let addr: fn(Sym, Sym, Site) -> Insn<'static> = |s, _, _| Insn::AddrSym { d: Slot(0), sym: s };
    let ext_ind: fn(Sym, Sym, Site) -> Insn<'static> =
        |s, island, site| Insn::CallExtInd { d: Slot(0), sym: s, site, island };
    let ext: fn(Sym, Sym, Site) -> Insn<'static> = |s, island, site| Insn::CallExt { d: Slot(0), sym: s, site, island };
    // `x` as the island: islands are always direct.
    let island_ind: fn(Sym, Sym, Site) -> Insn<'static> =
        |s, island, site| Insn::CallExtInd { d: Slot(0), sym: island, site, island: s };
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
        code: code(&[Insn::CallExtInd { d: Slot(0), sym: ind, site, island: dir }, Insn::Abort {}]),
        ..Default::default()
    });
    let obj = w.finish().unwrap();
    assert_eq!(obj.symbols.iter().map(|s| (s.name.as_str(), s.flags)).collect::<Vec<_>>(), [("f", SYM_INDIRECT), ("f", 0)]);

    // Portals are local definitions: never indirect.
    let mut w = ImageWriter::new(1);
    let p = w.symbol("p", SYM_INDIRECT);
    w.add_function(FunctionDef { code: code(&[Insn::Abort {}]), portal: Some(p), ..Default::default() });
    assert_eq!(w.finish().unwrap_err(), WriteError::Portal(0));
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
    let obj = sample().finish().unwrap();
    let fe = |h: &Header, i: usize, field: usize| h.functions.off as usize + i * size_of::<FuncEntry>() + field;
    // Cleanup entry offset past the function.
    assert_eq!(validate_edited(&obj, |r, h| put32(r, h.cleanup.off as usize, 1000)), Err(ImageError::BadCleanup(0)));
    // Cleanup entries out of order (f1's second entry).
    assert_eq!(validate_edited(&obj, |r, h| put32(r, h.cleanup.off as usize + 16, 0)), Err(ImageError::BadCleanup(1)));
    // Cleanup range past the table.
    assert_eq!(
        validate_edited(&obj, |r, h| put32(r, fe(h, 2, offset_of!(FuncEntry, cleanup_len)), 9)),
        Err(ImageError::BadCleanup(2))
    );
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
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fx(h) + 4, 4)), Err(ImageError::BadFixup(0)));
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
    assert_eq!(w.finish().unwrap_err(), WriteError::AllocReloc);
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
    assert_eq!(w.finish().unwrap_err(), WriteError::AllocReloc);
    // A pointer to an indirect symbol's target must be a fixup, not a relocation.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", SYM_INDIRECT);
    w.add_const(&[0; 8], 8, &[AllocReloc { offset: 0, target: AllocTarget::Symbol(s), addend: 0 }]);
    assert_eq!(w.finish().unwrap_err(), WriteError::AllocReloc);
    // The fixup area is 8-aligned even after an odd number of sites and 1-aligned data.
    let mut w = ImageWriter::new(1);
    w.site();
    w.site();
    w.site();
    let d = w.add_data(&[1], 1, &[], &[]);
    let obj = w.finish().unwrap();
    let b = Buf::new(&obj.rodata, 8);
    assert_eq!(Image::parse(b.bytes()).unwrap().header().fixup_area, 24);
    assert_eq!(d, Data(0));
    assert_eq!(obj.data_align, 8);
}
