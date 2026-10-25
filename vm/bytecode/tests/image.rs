use ryo_bytecode::Insn;
use ryo_bytecode::asm::{self, CallSite, Mode, Scope, ScopeKind};
use ryo_bytecode::full::*;
use ryo_bytecode::image::*;

const ELF: Mode = Mode { fp_arg: false, frame_pointer: true, align_loops: true, pe: false, counters: false };
/// As the backend encodes: with counters.
const AOT: Mode = Mode { counters: true, ..ELF };

fn code(insns: &[Insn<'_>]) -> Vec<u32> {
    let mut c = CodeBuf::new();
    for i in insns {
        c.emit(i);
    }
    c.words
}

/// A 16-aligned byte buffer (leaked: tests only).
struct Buf {
    ptr: *mut u8,
    len: usize,
}
impl Buf {
    fn new(bytes: &[u8], align: u64) -> Buf {
        Buf::several(&[(bytes, align)]).pop().unwrap()
    }
    /// Buffers in one allocation, so that `rel32` fields reach across them.
    fn several(parts: &[(&[u8], u64)]) -> Vec<Buf> {
        let n: usize = parts.iter().map(|p| p.0.len().div_ceil(16) + 1 + 4).sum();
        let mem: &mut [u128] = Vec::leak(vec![0u128; n]);
        let mut at = mem.as_mut_ptr();
        parts
            .iter()
            .map(|&(bytes, align)| {
                assert!(align <= 64);
                while at as u64 % align != 0 {
                    at = unsafe { at.add(1) };
                }
                let b = Buf { ptr: at.cast(), len: bytes.len() };
                unsafe { std::slice::from_raw_parts_mut(b.ptr, b.len) }.copy_from_slice(bytes);
                at = unsafe { at.add(bytes.len().div_ceil(16) + 1) };
                b
            })
            .collect()
    }
    fn addr(&self) -> u64 {
        self.ptr as u64
    }
    fn bytes(&self) -> &[u8] {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len) }
    }
    fn write_u64(&mut self, off: u64, v: u64) {
        unsafe { (self.ptr.add(off as usize) as *mut u64).write_unaligned(v) }
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
/// `ryo_rt`'s handlers to [`handler_addr`] and `ryo_probe_stack` to [`probe_addr`], past the
/// text section.
fn link(obj: &ImageObject, resolve: impl Fn(&SymbolDef) -> u64) -> Linked {
    let [ro, data, text] = Buf::several(&[(&obj.rodata, obj.rodata_align), (&obj.data, obj.data_align), (&obj.text, 16)]).try_into().ok().unwrap();
    let mut l = Linked { ro, data, text };
    assert_eq!(l.ro.addr() % obj.rodata_align, 0);
    for r in &obj.relocs {
        let target = match r.target {
            RelocTarget::Symbol(s) => resolve(&obj.symbols[s.0 as usize]),
            RelocTarget::Section(Section::ReadOnly) => l.ro.addr(),
            RelocTarget::Section(Section::Writable) => l.data.addr(),
            RelocTarget::Section(Section::Text) => l.text.addr(),
            RelocTarget::Section(_) => continue,
            RelocTarget::Handler(op) => handler_addr(&l.text, op),
            RelocTarget::Probe => probe_addr(&l.text),
            RelocTarget::TripEntry => trip_addr(&l.text, false),
            RelocTarget::TripOsr => trip_addr(&l.text, true),
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

/// Where [`link`] puts the handler of `op`: in reach of `text`'s `rel32` calls.
fn handler_addr(text: &Buf, op: Opcode) -> u64 {
    text.addr() + 0x10_0000 + 16 * op as u64
}

fn probe_addr(text: &Buf) -> u64 {
    text.addr() + 0x8_0000
}

/// Where [`link`] puts `ryo_jit_trip_entry` and (`osr`) `ryo_jit_trip_osr`.
fn trip_addr(text: &Buf, osr: bool) -> u64 {
    text.addr() + 0x9_0000 + 16 * osr as u64
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
    let island = w.symbol("_ZN6ryo_rt6island5call_c1", 0);
    let _other = w.symbol("_ZN4test3fooE", 0);
    let _site = w.site();
    let _site2 = w.site();

    let s1 = w.add_const(b"hello\0", 1, &[]);
    let vt = w.add_const(
        &[0u8; 24],
        8,
        &[
            AllocReloc { offset: 0, target: AllocTarget::Symbol(puts), addend: 0 },
            AllocReloc { offset: 8, target: AllocTarget::Const(s1), addend: 2 },
        ],
    );
    assert_eq!(vt.0 % 8, 0);
    let fx = w.add_data(
        &[7u8; 16],
        8,
        &[AllocReloc { offset: 8, target: AllocTarget::Const(vt), addend: 0 }],
        &[AllocFixup { offset: 0, sym: imp, addend: 4 }],
    );

    // f0: calls f1 with a landing pad at 8 (`lpad; jmp`) whose block resumes, then returns.
    let f0 = code(&[
        Insn::Call { d: Slot(-8), f: Func(1), k: 8, a: List::from_words(&[]) },
        Insn::Ret { s: Slot(-8), k: 8 },
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
        ret_kind: 8,
        cleanup: vec![CleanupEntry { offset: 0, target: 8 }, CleanupEntry { offset: 12, target: CONTINUE }],
        symbol: None,
    });
    let ops = [16u32, -24i32 as u32];
    let f1 = code(&[
        Insn::CallSym { d: Slot(-8), sym: puts, k: 8, a: List::from_words(&[]) },
        Insn::Island { isl: island, ops: List::from_words(&ops) },
        Insn::AddrConst { d: Slot(-8), a: Abs::Const(vt) },
        Insn::AddrConst { d: Slot(-16), a: Abs::Data(fx) },
        Insn::Ret { s: Slot(-8), k: 8 },
    ]);
    w.add_function(FunctionDef {
        name: "f1".into(),
        code: f1,
        frame_size: 48,
        cleanup: vec![CleanupEntry { offset: 5, target: CONTINUE }, CleanupEntry { offset: 0, target: CONTINUE }],
        symbol: Some(FuncSymbol { visibility: SymVisibility::Default, weak: false }),
        ..Default::default()
    });
    w.add_function(FunctionDef { name: String::new(), code: code(&[Insn::Abort {}]), frame_size: 16, ..Default::default() });
    w
}

#[test]
fn image_round_trip() {
    let obj = sample().finish(ELF).unwrap();
    // puts, some_dll_static, the island, another, rust_eh_personality.
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
    assert_eq!(img.symbols()[3], 0x2000 + "_ZN4test3fooE".len() as u64);
    assert_eq!(img.symbols()[0], 0x1000);
    assert_eq!(img.symbol_flags(), &[0, SYM_INDIRECT, 0, 0, 0]);
    assert_eq!(obj.functions[1].symbol, Some(FuncSymbol { visibility: SymVisibility::Default, weak: false }));
    assert_eq!(obj.functions.iter().map(|f| f.name.as_str()).collect::<Vec<_>>(), ["f0", "f1", ""]);
    assert_eq!(obj.functions[0].frame_size, 48);

    // f0's code: the prologue, then `call f1` resolved within the text, then the result's
    // store.
    let t = l.text.bytes();
    assert_eq!(&t[..8], [0x55, 0x48, 0x89, 0xe5, 0x48, 0x83, 0xec, 48]);
    assert_eq!(t[8], 0xe8);
    assert_eq!(9 + 4 + i32_at(&l.text, 9) as i64, fs[1].code_off as i64);
    assert_eq!(&t[13..17], [0x48, 0x89, 0x45, 0xf8]); // `mov [rbp - 8], rax`
    // f1's `call.sym`: `call [rip + sym slot 0]` reaches the slot.
    let at = fs[1].code_off as u64 + 4 + 4; // after the prologue (`sub rsp, 48`)
    assert_eq!(&t[at as usize..at as usize + 2], [0xff, 0x15]);
    let slot = (l.text.addr() + at + 6).wrapping_add(i32_at(&l.text, at + 2) as i64 as u64);
    assert_eq!(slot, img.symbols_ptr() as u64);

    // Unwind information: f0's call and resume are call sites, f0's to its landing pad.
    assert_eq!(obj.functions[0].call_sites.len(), 2);
    assert!(obj.functions[0].call_sites[0].pad.is_some() && obj.functions[0].call_sites[1].pad.is_none());
    assert_eq!(obj.functions[1].call_sites.len(), 2); // `call [rip + slot]`, the island
    assert!(obj.functions[2].call_sites.is_empty());
    let secs: Vec<_> = obj.unwind.iter().map(|u| u.0).collect();
    assert_eq!(secs, [Section::EhFrame, Section::Lsda]);
    // One CIE, then one FDE per function, each pointing at its code and LSDA.
    let fdes = obj.relocs.iter().filter(|r| r.section == Section::EhFrame && r.target == RelocTarget::Section(Section::Text)).count();
    assert_eq!(fdes, 3);

    // The same call sites in the read-only section, and the mode in the header.
    for (i, f) in obj.functions.iter().enumerate() {
        let read: Vec<CallSite> = img.call_sites(i as u32).iter().map(CallSite::from).collect();
        assert_eq!(read, f.call_sites);
    }
    assert_eq!(img.call_sites(0)[0].action(), Cleanup::Pad(obj.functions[0].call_sites[0].pad.unwrap(), false));
    assert_eq!(img.call_sites(3), &[]);
    assert_eq!(img.mode(), ELF);
    assert_eq!(h.mode, MODE_FRAME_POINTER | MODE_ALIGN_LOOPS);

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
    // f0: version 1, prologue 12 bytes, 5 codes (alloc small 48 - 16, set fpreg, push rsi,
    // push rdi, push rbp), rbp at rsp + 16.
    assert_eq!(&obj.unwind[1].1[..14], [1, 12, 5, 5 | 1 << 4, 12, 2 | (32 / 8 - 1) << 4, 8, 3, 3, 6 << 4, 2, 7 << 4, 1, 5 << 4]);
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
    w.add_function(FunctionDef { code: code(&[Insn::Abort {}, Insn::Br { s: Slot(-1), neg: Neg(false), t: Target(-1) }]), ..Default::default() });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { error: CodeError::FallsOffEnd, .. })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef {
        name: String::new(),
        code: code(&[Insn::Call { d: Slot(0), f: Func(5), k: 0, a: List::from_words(&[]) }, Insn::Abort {}]),
        ..Default::default()
    });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { error: CodeError::FuncOutOfRange, .. })));

    let mut w = ImageWriter::new(1);
    w.add_function(FunctionDef {
        name: String::new(),
        code: code(&[Insn::AddrSym { d: Slot(0), sym: Sym(5) }, Insn::Abort {}]),
        ..Default::default()
    });
    assert!(matches!(w.finish(ELF), Err(WriteError::Code { error: CodeError::SymOutOfRange, .. })));

    // Cleanup entries: not on an instruction start, not on a call, a landing pad that isn't
    // an `lpad`.
    for (offset, target) in [(1, CONTINUE), (5, CONTINUE), (0, 5)] {
        let mut w = ImageWriter::new(1);
        w.add_function(FunctionDef {
            code: code(&[
                Insn::Call { d: Slot(0), f: Func(0), k: 0, a: List::from_words(&[]) },
                Insn::Abort {},
                Insn::Lpad { x: Slot(-16) },
                Insn::Abort {},
            ]),
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
    // Only `addr.sym.ind` and `call.sym.ind` load through the slot, and they need an
    // indirect one (design/platforms.md).
    let check = |indirect: u8, insn: fn(Sym) -> Insn<'static>| {
        let mut w = ImageWriter::new(1);
        let s = w.symbol("x", indirect);
        w.add_function(FunctionDef { name: String::new(), code: code(&[insn(s), Insn::Abort {}]), ..Default::default() });
        w.finish(ELF).map(drop)
    };
    let bad = Err(WriteError::Code { func: 0, offset: 0, error: CodeError::SymIndirection });
    let addr_ind: fn(Sym) -> Insn<'static> = |s| Insn::AddrSymInd { d: Slot(0), sym: s };
    let addr: fn(Sym) -> Insn<'static> = |s| Insn::AddrSym { d: Slot(0), sym: s };
    let call_ind: fn(Sym) -> Insn<'static> = |s| Insn::CallSymInd { d: Slot(0), sym: s, k: 0, a: List::from_words(&[]) };
    let call: fn(Sym) -> Insn<'static> = |s| Insn::CallSym { d: Slot(0), sym: s, k: 0, a: List::from_words(&[]) };
    // `x` as an island: islands are always direct.
    let island: fn(Sym) -> Insn<'static> = |s| Insn::Island { isl: s, ops: List::from_words(&[]) };
    assert_eq!(check(SYM_INDIRECT, addr_ind), Ok(()));
    assert_eq!(check(SYM_INDIRECT, call_ind), Ok(()));
    assert_eq!(check(0, addr), Ok(()));
    assert_eq!(check(0, call), Ok(()));
    assert_eq!(check(0, island), Ok(()));
    assert_eq!(check(0, addr_ind), bad);
    assert_eq!(check(0, call_ind), bad);
    assert_eq!(check(SYM_INDIRECT, addr), bad);
    assert_eq!(check(SYM_INDIRECT, call), bad);
    assert_eq!(check(SYM_INDIRECT, island), bad);

    // One upstream function both called through its import slot and used as an island:
    // an indirect and a direct slot of the same name.
    let mut w = ImageWriter::new(1);
    let ind = w.symbol("f", SYM_INDIRECT);
    let dir = w.symbol("f", 0);
    assert_ne!(ind, dir);
    w.add_function(FunctionDef {
        code: code(&[
            Insn::CallSymInd { d: Slot(0), sym: ind, k: 0, a: List::from_words(&[]) },
            Insn::Island { isl: dir, ops: List::from_words(&[]) },
            Insn::Abort {},
        ]),
        ..Default::default()
    });
    let obj = w.finish(ELF).unwrap();
    assert_eq!(obj.symbols.iter().map(|s| (s.name.as_str(), s.flags)).collect::<Vec<_>>(), [("f", SYM_INDIRECT), ("f", 0), (PERSONALITY, 0)]);
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
fn crate_hashes() {
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
    // Code past the end.
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fe(h, 2, offset_of!(FuncEntry, code_len)), 1000)), Err(ImageError::BadFunction(2)));
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
    w.add_data(&[0; 8], 8, &[AllocReloc { offset: 0, target: AllocTarget::Symbol(t), addend: 0 }], &[AllocFixup { offset: 0, sym: s, addend: 0 }]);
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

/// Scopes and call sites from `finish_encoded`'s `Encoded`s are read back unchanged, in
/// every mode.
#[test]
fn scopes_and_call_sites_round_trip() {
    // f0: takes the address of a 16-byte local, calls f1 (cleanup at `lpad`), ends the
    // local's storage, returns. f1: just returns.
    let f0 = code(&[
        Insn::Addr { d: Slot(-8), s: Slot(-32) },
        Insn::Call { d: Slot(-8), f: Func(1), k: 8, a: List::from_words(&[]) },
        Insn::Ret { s: Slot(-8), k: 8 },
        Insn::Lpad { x: Slot(-16) },
        Insn::Resume { x: Slot(-16) },
    ]);
    let f1 = code(&[Insn::Abort {}]);
    let starts = |c: &[u32]| {
        let mut v = vec![];
        let mut at = 0;
        while at < c.len() {
            v.push(at as u32);
            at += Insn::decode(&c[at..]).unwrap().1;
        }
        v
    };
    let s0 = starts(&f0);
    let scopes = [
        Scope { code_offset: s0[0], frame_offset: -32, size: 16, kind: ScopeKind::Escape { align: 8 } },
        Scope { code_offset: s0[2], frame_offset: -32, size: 16, kind: ScopeKind::End },
        Scope { code_offset: s0[3], frame_offset: -48, size: 8, kind: ScopeKind::Lend },
    ];
    let cleanup = [CleanupEntry { offset: s0[1], target: s0[3] | CATCH }, CleanupEntry { offset: s0[4], target: CONTINUE }];
    for mode in [ELF, Mode { fp_arg: true, frame_pointer: false, align_loops: false, ..ELF }, Mode { pe: true, ..ELF }, AOT, Mode { pe: true, ..AOT }]
    {
        let enc = vec![asm::encode(&f0, 48, &cleanup, &scopes, mode).unwrap(), asm::encode(&f1, 16, &[], &[], mode).unwrap()];
        assert_eq!(enc[0].scopes.len(), 3);
        assert_eq!(enc[0].call_sites.len(), 2);
        assert!(enc[0].call_sites[0].catch);
        let mut w = ImageWriter::new(SCID);
        for (name, frame_size) in [("f0", 48), ("f1", 16)] {
            w.add_function(FunctionDef { name: name.into(), frame_size, ..Default::default() });
        }
        w.prepare(mode);
        let obj = w.finish_encoded(enc.clone()).unwrap();
        let b = Buf::new(&obj.rodata, obj.rodata_align);
        let img = Image::parse(b.bytes()).unwrap();
        img.validate().unwrap();
        assert_eq!(img.mode(), mode);
        for (i, e) in enc.iter().enumerate() {
            let scopes: Vec<Scope> = img.scopes(i as u32).iter().map(Scope::from).collect();
            let sites: Vec<CallSite> = img.call_sites(i as u32).iter().map(CallSite::from).collect();
            assert_eq!((scopes, sites), (e.scopes.clone(), e.call_sites.clone()), "{mode:?}");
        }
        assert_eq!(img.scopes(0)[0].align, 8);
        assert_eq!(img.scopes(0)[1].align, 0);
        assert_eq!(img.scopes(0)[2].align, SCOPE_LEND);
        assert!(img.scopes(1).is_empty() && img.scopes(2).is_empty());

        // `validate` checks the runs and the entries.
        use std::mem::{offset_of, size_of};
        let fe = |h: &Header, i: usize, field: usize| h.functions.off as usize + i * size_of::<FuncEntry>() + field;
        let sc = |h: &Header, i: usize, field: usize| h.scopes.off as usize + i * size_of::<ScopeEntry>() + field;
        let cs = |h: &Header, i: usize, field: usize| h.call_sites.off as usize + i * size_of::<CallSiteEntry>() + field;
        assert_eq!(validate_edited(&obj, |r, h| put32(r, fe(h, 1, offset_of!(FuncEntry, scopes)), 4)), Err(ImageError::BadFunction(1)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, fe(h, 0, offset_of!(FuncEntry, call_sites) + 4), 3)), Err(ImageError::BadFunction(0)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, sc(h, 1, offset_of!(ScopeEntry, align)), 3)), Err(ImageError::BadScope(1)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, sc(h, 0, 0), 10_000)), Err(ImageError::BadScope(0)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, cs(h, 1, offset_of!(CallSiteEntry, len)), 10_000)), Err(ImageError::BadCallSite(1)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, cs(h, 0, offset_of!(CallSiteEntry, pad)), 10_000)), Err(ImageError::BadCallSite(0)));
        let len0 = |r: &[u8], h: &Header| {
            let at = fe(h, 0, offset_of!(FuncEntry, code_len));
            u32::from_le_bytes(r[at..at + 4].try_into().unwrap())
        };
        assert_eq!(
            validate_edited(&obj, |r, h| {
                let n = len0(r, h);
                put32(r, sc(h, 0, 0), n)
            }),
            Err(ImageError::BadScope(1))
        );
        assert_eq!(validate_edited(&obj, |r, h| put32(r, cs(h, 1, 0), 0)), Err(ImageError::BadCallSite(1)));
        assert!(matches!(validate_edited(&obj, |r, _| put32(r, offset_of!(Header, mode), MODE_PE)), Err(ImageError::BadMode)));
        assert!(matches!(validate_edited(&obj, |r, _| put32(r, offset_of!(Header, mode), 32)), Err(ImageError::BadMode)));
        // Counters need the JIT records, and the other way round.
        let bits = mode_bits(mode) ^ MODE_COUNTERS;
        assert!(matches!(validate_edited(&obj, |r, _| put32(r, offset_of!(Header, mode), bits)), Err(ImageError::BadData)));
    }
}

/// A function whose inline sequences' stores are dropped as dead ([`asm::Asm::dead`]), one
/// of them a `mov` that leaves no code at all, around a call of function 0.
fn dead_stores(mode: Mode) -> asm::Encoded {
    use asm::Opnd::{Imm, Slot};
    let mut a = asm::Asm::new(mode);
    a.insn(Opcode::MovW64, &[Slot(-16), Slot(-8)]);
    a.insn(Opcode::MovW64, &[Slot(-56), Slot(-16)]);
    a.insn(Opcode::MovW128, &[Slot(-48), Slot(-24)]);
    a.insn(Opcode::ImmW64, &[Slot(-16), Imm(5)]);
    a.insn(Opcode::AddW64, &[Slot(-32), Slot(-56), Slot(-56)]);
    a.dead(-56i32 as u32, 8);
    a.insn(Opcode::AddImmW32, &[Slot(-60), Slot(-32), Imm(3)]);
    a.insn(Opcode::MulW32, &[Slot(-64), Slot(-60), Slot(-60)]);
    a.dead(-60i32 as u32, 4);
    a.insn(Opcode::Call, &[Slot(0), asm::Opnd::Func(Func(0)), Imm(0), asm::Opnd::Words(vec![])]);
    a.insn(Opcode::Ret, &[Slot(-64), Imm(4)]);
    a.finish(64, |s| s)
}

/// The functions of a linked image decode from its text section through the image's ranges
/// and tables alone ([`ImageResolver`]) as their encoder output decodes with its side data,
/// dropped stores included.
#[test]
fn linked_functions_decode() {
    for mode in
        [ELF, Mode { fp_arg: true, frame_pointer: false, ..ELF }, Mode { pe: true, ..ELF }, AOT, Mode { fp_arg: true, frame_pointer: false, ..AOT }]
    {
        let mut w = sample();
        let mut enc: Vec<asm::Encoded> = w.functions().iter().map(|f| asm::encode(&f.code, f.frame_size, &f.cleanup, &[], mode).unwrap()).collect();
        enc.push(dead_stores(mode));
        assert!(enc.last().unwrap().dropped.len() >= 2);
        w.add_function(FunctionDef { name: "dead".into(), frame_size: 64, ..Default::default() });
        w.prepare(mode);
        let obj = w.finish_encoded(enc.clone()).unwrap();
        let l = link(&obj, |s| 0x1000 + s.name.len() as u64);
        let img = unsafe { Image::from_header(l.ro.bytes().as_ptr()) }.unwrap();
        img.validate().unwrap();
        let mut handlers: Vec<(usize, Opcode)> = ALL_OPCODES.iter().map(|&op| (handler_addr(&l.text, op) as usize, op)).collect();
        handlers.sort();
        let res = ImageResolver { image: img, handlers: &handlers, probe: probe_addr(&l.text) as usize };
        for (i, e) in enc.iter().enumerate() {
            let got = res.decode(i as u32, l.text.bytes()).expect("a function").unwrap_or_else(|e| panic!("f{i} {mode:?}: {e:?}"));
            // The encoder's output, its code constants at their place in the image's.
            let cc = img.code_consts();
            let base = if e.rodata.is_empty() { 0 } else { cc.windows(e.rodata.len()).position(|w| w == e.rodata).unwrap() as u32 };
            let relocs: Vec<asm::Reloc> = e
                .relocs
                .iter()
                .map(|r| match r.to {
                    asm::Ref::Ro(o) => asm::Reloc { to: asm::Ref::Ro(base + o), ..*r },
                    _ => *r,
                })
                .collect();
            let want = asm::decode_reduced(&e.code, &relocs, cc, &e.call_sites, &e.dropped, &e.scopes, mode).unwrap();
            assert_eq!(got, want, "f{i} {mode:?}");
        }
        // Not a function.
        assert!(res.decode(enc.len() as u32, l.text.bytes()).is_none());
    }
}

/// The dropped stores of `finish_encoded`'s `Encoded`s are read back unchanged, and
/// `validate` checks them.
#[test]
fn dropped_stores_round_trip() {
    for mode in [ELF, Mode { fp_arg: true, frame_pointer: false, ..ELF }, AOT] {
        let enc = vec![asm::encode(&code(&[Insn::Abort {}]), 16, &[], &[], mode).unwrap(), dead_stores(mode)];
        let mut w = ImageWriter::new(SCID);
        w.add_function(FunctionDef { name: "f0".into(), frame_size: 16, ..Default::default() });
        w.add_function(FunctionDef { name: "dead".into(), frame_size: 64, ..Default::default() });
        w.prepare(mode);
        let obj = w.finish_encoded(enc.clone()).unwrap();
        let b = Buf::new(&obj.rodata, obj.rodata_align);
        let img = Image::parse(b.bytes()).unwrap();
        img.validate().unwrap();
        for (i, e) in enc.iter().enumerate() {
            let read: Vec<asm::DroppedStore> =
                img.dropped(i as u32).iter().map(|d| asm::DroppedStore::from_parts(d.code_offset, d.frame_offset, d.size, d.reg).unwrap()).collect();
            assert_eq!(read, e.dropped, "{mode:?}");
        }
        assert!(img.dropped(0).is_empty() && img.dropped(2).is_empty());
        let n = enc[1].dropped.len();
        assert!(n >= 2);
        assert_eq!((img.dropped(1)[0].frame_offset, img.dropped(1)[0].size), (-56, 8));

        use std::mem::{offset_of, size_of};
        let fe = |h: &Header, i: usize, field: usize| h.functions.off as usize + i * size_of::<FuncEntry>() + field;
        let dr = |h: &Header, i: usize, field: usize| h.dropped.off as usize + i * size_of::<DroppedEntry>() + field;
        assert_eq!(
            validate_edited(&obj, |r, h| put32(r, fe(h, 1, offset_of!(FuncEntry, dropped) + 4), n as u32 + 1)),
            Err(ImageError::BadFunction(1))
        );
        assert_eq!(validate_edited(&obj, |r, h| put32(r, dr(h, 0, 0), 10_000)), Err(ImageError::BadDropped(0)));
        assert_eq!(validate_edited(&obj, |r, h| r[dr(h, 1, offset_of!(DroppedEntry, size))] = 3), Err(ImageError::BadDropped(1)));
        assert_eq!(validate_edited(&obj, |r, h| r[dr(h, 0, offset_of!(DroppedEntry, reg))] = 1), Err(ImageError::BadDropped(0)));
        // Out of order: the second before the first.
        assert_eq!(
            validate_edited(&obj, |r, h| {
                let first = u32::from_le_bytes(r[dr(h, 0, 0)..][..4].try_into().unwrap());
                put32(r, dr(h, 1, 0), first.wrapping_sub(1))
            }),
            Err(ImageError::BadDropped(1))
        );
    }
}

/// With counters, every function has a JIT record in the writable section, initialized and
/// relocated, which its counter checks and stubs address; the unwind information describes
/// the check before the prologue and the entry's stub after the code.
#[test]
fn jit_records() {
    for mode in [AOT, Mode { fp_arg: true, frame_pointer: false, ..AOT }] {
        let obj = sample().finish(mode).unwrap();
        assert_eq!(obj.data_align, 64);
        let l = link(&obj, |s| 0x1000 + s.name.len() as u64);
        let img = unsafe { Image::from_header(l.ro.bytes().as_ptr()) }.unwrap();
        img.validate().unwrap();
        let h = img.header();
        assert_eq!(h.mode & MODE_COUNTERS, MODE_COUNTERS);
        assert_eq!((h.jit_records.count, h.jit_records.off % 64), (3, 0));
        // Past the fixup area, even its one-past-the-end address.
        assert!(h.jit_records.off > h.fixup_area + 16);
        let t = l.text.bytes();
        for (i, f) in obj.functions.iter().enumerate() {
            let rec = img.jit_records().wrapping_add(i) as u64;
            assert_eq!(rec, l.data.addr() + h.jit_records.off as u64 + 64 * i as u64);
            let r = unsafe { &*(rec as *const JitRecord) };
            assert_eq!((r.ctr, r.entry as u64, r.osr as u64, r.next as u64), (JIT_THRESHOLD, trip_addr(&l.text, false), trip_addr(&l.text, true), 0));
            assert_eq!((r.state.load(std::sync::atomic::Ordering::Relaxed), r.func, r.header as u64), (JIT_COLD, i as u32, l.ro.addr()));
            // `sub qword [rip + x], 16` reaches the counter, `js` the entry's stub, whose
            // `lea r11, [rip + x]` the record.
            let at = f.start as u64;
            assert_eq!(t[at as usize..][..3], [0x48, 0x83, 0x2d]);
            assert_eq!(t[at as usize + 7], asm::ENTRY_COUNT);
            assert_eq!((l.text.addr() + at + 8).wrapping_add(i32_at(&l.text, at + 3) as i64 as u64), rec);
            assert_eq!(t[at as usize + 8], 0x78); // `js rel8`
            assert_eq!(at as i64 + 10 + t[at as usize + 9] as i8 as i64, (f.start + f.entry_stub) as i64);
            assert_eq!(f.prologue, 10);
            let stub = (f.start + f.entry_stub) as u64;
            assert_eq!(t[stub as usize..][..3], [0x4c, 0x8d, 0x1d]);
            assert_eq!((l.text.addr() + stub + 7).wrapping_add(i32_at(&l.text, stub + 3) as i64 as u64), rec);
            assert_eq!(t[stub as usize + 7..][..4], [0x41, 0xff, 0x53, JIT_ENTRY_SLOT]);
        }
        // The FDEs: the prologue's rules after the check, and at the entry's stub CFA =
        // rsp + 8 (with a frame pointer, `rbp` restored).
        let eh = &obj.unwind[0].1;
        let f0 = &obj.functions[0];
        let tail: &[u8] = if mode.frame_pointer { &[0x0c, 7, 8, 0xc6] } else { &[0x0c, 7, 8] };
        assert!(eh.windows(tail.len()).any(|w| w == tail), "{eh:02x?}");
        if mode.frame_pointer {
            assert!(eh.windows(7).any(|w| w == [0x40 | 11, 0x0e, 16, 0x86, 2, 0x40 | 3, 0x0d]), "{eh:02x?}");
        } else {
            assert!(eh.windows(3).any(|w| w == [0x40 | 14, 0x0e, 64]), "{eh:02x?}");
        }
        assert!(f0.entry_stub > f0.prologue);
    }
    // PE: the check is part of the prologue, and the entry's stub has an entry of its own.
    let obj = sample().finish(Mode { pe: true, ..AOT }).unwrap();
    assert_eq!(obj.unwind[0].1.len(), 2 * 3 * 12);
    let x = &obj.unwind[1].1;
    assert_eq!(&x[..14], [1, 22, 5, 5 | 1 << 4, 22, 2 | (32 / 8 - 1) << 4, 18, 3, 13, 6 << 4, 12, 7 << 4, 11, 5 << 4]);
    assert_eq!(&x[16..20], [1, 0, 0, 0]);
}
