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
        cleanup: vec![CleanupEntry { offset: 0, target: 7 }],
        portal: None,
    });
    let t = list_words([Target(8)]);
    let ops = [16u32, 24];
    let f1 = code(&[
        Insn::CallExt { d: Slot(16), sym: puts, site, island },
        Insn::Island { d: Slot(24), sym: island, ops: List::from_words(&ops), targets: List::from_words(&t) },
        Insn::AddrK { d: Slot(16), k: vt },
        Insn::AddrData { d: Slot(24), off: fx },
        Insn::Ret { s: Slot(16), len: 8 },
    ]);
    w.add_function(FunctionDef {
        code: f1,
        frame_size: 48,
        cleanup: vec![CleanupEntry { offset: 5, target: TERMINATE }, CleanupEntry { offset: 0, target: TERMINATE }],
        portal: Some(portal1),
    });
    w.add_function(FunctionDef { code: code(&[Insn::Abort {}]), frame_size: 16, cleanup: vec![], portal: None });
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
    let f1_code_off = Image::parse(b.bytes()).unwrap().header().functions.off as usize + 24;
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
fn symbols_are_interned() {
    let mut w = ImageWriter::new(1);
    assert_eq!(w.symbol("a", 0), Sym(0));
    assert_eq!(w.symbol("b", SYM_INDIRECT), Sym(1));
    assert_eq!(w.symbol("a", 0), Sym(0));
}

#[test]
fn portal_ids() {
    assert_eq!(portal_id(0xdead_beef, 7), 0xdead_beef_0000_0007);
    assert_eq!(split_portal_id(0xdead_beef_0000_0007), (0xdead_beef, 7));
    assert_eq!(crate_hash(0x1111_1111_0000_0001), 0x1111_1110);
}
