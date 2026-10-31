use ryo_bytecode::Insn;
use ryo_bytecode::asm::{self, CallSite, InsnList, Mode, Scope, ScopeKind};
use ryo_bytecode::full::*;
use ryo_bytecode::image::*;

const ELF: Mode = Mode { fp_arg: false, frame_pointer: true, align_loops: true, pe: false, counters: false, far_rt: false };
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
    link_with(obj, resolve, None).0
}

/// PLT stubs or import thunks for the handlers, which [`link_with`] calls them through: one
/// per opcode, 16 bytes apart, `prefix` then `jmp [rip + slot]`, the slots after the stubs.
/// A slot holds the handler's address ([`handler_addr`]), or with `lazy` the address after
/// its stub's `jmp`, as a lazily bound PLT slot points back into the PLT.
#[derive(Clone, Copy)]
struct Stubs<'a> {
    prefix: &'a [u8],
    lazy: bool,
}

/// [`link`], calling the handlers through `stubs` (returned) if given.
fn link_with(obj: &ImageObject, resolve: impl Fn(&SymbolDef) -> u64, stubs: Option<Stubs<'_>>) -> (Linked, Option<Buf>) {
    let n = ALL_OPCODES.len();
    let stub_bytes = vec![0u8; if stubs.is_some() { n * 24 } else { 0 }];
    let [ro, data, text, mut plt] =
        Buf::several(&[(&obj.rodata, obj.rodata_align), (&obj.data, obj.data_align), (&obj.text, 16), (&stub_bytes, 16)]).try_into().ok().unwrap();
    if let Some(st) = stubs {
        for &op in ALL_OPCODES {
            let at = 16 * op as usize;
            let end = at + st.prefix.len() + 6;
            let slot = 16 * n + 8 * op as usize;
            let mut b = st.prefix.to_vec();
            b.extend([0xff, 0x25]);
            b.extend(((slot - end) as i32).to_le_bytes());
            unsafe { std::slice::from_raw_parts_mut(plt.ptr.add(at), b.len()) }.copy_from_slice(&b);
            plt.write_u64(slot as u64, if st.lazy { plt.addr() + end as u64 } else { handler_addr(&text, op) });
        }
    }
    let handler = |text: &Buf, op: Opcode| if stubs.is_some() { plt.addr() + 16 * op as u64 } else { handler_addr(text, op) };
    let mut l = Linked { ro, data, text };
    assert_eq!(l.ro.addr() % obj.rodata_align, 0);
    for r in &obj.relocs {
        let target = match r.target {
            RelocTarget::Symbol(s) => resolve(&obj.symbols[s.0 as usize]),
            RelocTarget::Section(Section::ReadOnly) => l.ro.addr(),
            RelocTarget::Section(Section::Writable) => l.data.addr(),
            RelocTarget::Section(Section::Text) => l.text.addr(),
            RelocTarget::Section(_) => continue,
            RelocTarget::Handler(op) => handler(&l.text, op),
            RelocTarget::Probe => probe_addr(&l.text),
            RelocTarget::TripEntry => trip_addr(&l.text, false),
            RelocTarget::TripOsr => trip_addr(&l.text, true),
            // Only `.xdata` refers to it.
            RelocTarget::SehHandler => continue,
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
            RelocKind::Pc64 => unreachable!("Mach-O `.eh_frame` only"),
        }
    }
    (l, stubs.map(|_| plt))
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
        flags: FUNC_INLINE_ALWAYS | FUNC_COLD,
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
    w.add_function(FunctionDef {
        name: String::new(),
        code: code(&[Insn::Abort {}]),
        frame_size: 16,
        flags: FUNC_INLINE_NEVER,
        ..Default::default()
    });
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

    // Functions: machine code, each aligned to 16, in order.
    let fs = img.functions();
    assert_eq!(fs.len(), 3);
    assert_eq!(fs[0].code_off, 0);
    assert_eq!(fs[1].code_off, fs[0].code_len.next_multiple_of(16));
    assert_eq!((fs[0].arg_size, fs[0].ret_size, fs[1].arg_size), (8, 8, 0));
    assert_eq!(img.symbols()[3], 0x2000 + "_ZN4test3fooE".len() as u64);
    assert_eq!(img.symbols()[0], 0x1000);
    assert_eq!(img.symbol_flags(), &[0, SYM_INDIRECT, 0, 0, 0]);
    assert_eq!(img.func_flags(), &[FUNC_INLINE_ALWAYS | FUNC_COLD, 0, FUNC_INLINE_NEVER]);
    assert_eq!(obj.functions[1].symbol, Some(FuncSymbol { visibility: SymVisibility::Default, weak: false }));
    assert_eq!(obj.functions.iter().map(|f| f.name.as_str()).collect::<Vec<_>>(), ["f0", "f1", ""]);
    assert_eq!(obj.functions[0].eh.frame_size, 48);

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

    // Writable section: the fixup area with an intra-image pointer, and the PE fixup applied
    // at registration.
    let data = &l.data;
    assert_eq!(data.read_u64(8), k.as_ptr() as u64 + vt_off as u64);
    assert_eq!(data.read_u64(0), 0x0707070707070707);
    unsafe { img.apply_fixups() };
    assert_eq!(data.read_u64(0), &*real_static as *const u64 as u64 + 4);
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
    // Each function's body (without counters, no stub), and f0's pad region (its landing
    // pad's block resumes).
    assert_eq!(obj.unwind[0].1.len(), (3 + 1) * 12);
    // f0: version 1, the handler flags, prologue 8 bytes (`push rbp; mov rbp, rsp; sub rsp,
    // 48`), 3 codes (alloc small 48, set fpreg, push rbp), rbp at rsp + 0; then (codes padded
    // to 4) the handler's RVA and its data: no offset, the region's, and the LSDA.
    let infos = pe_infos(&obj);
    let f0 = &obj.functions[0];
    let x = &obj.unwind[1].1;
    assert_eq!(&x[..12], [1 | 0x18, 8, 3, 5, 8, 2 | (48 / 8 - 1) << 4, 4, 3, 1, 5 << 4, 0, 0]);
    let lsda = ryo_bytecode::asm::lsda::write(&f0.call_sites);
    assert_eq!(&x[16..infos[1]], &ryo_bytecode::image::pe_with_handler(&[0; 4], &ryo_bytecode::image::pe_handler_data(0, f0.region, &lsda)).0[8..]);
    // Then the region's, with the handler, its data at the region's offset.
    let region = ryo_bytecode::image::pe_with_handler(
        &ryo_bytecode::image::pe_region_unwind_info(),
        &ryo_bytecode::image::pe_handler_data(f0.region, f0.region, &lsda),
    )
    .0;
    assert_eq!(&x[infos[1]..][..region.len()], region);
    assert!(f0.eh.entry_stub == f0.region && f0.region < f0.eh.len);
    // The region starts with its entry, `sub rsp, 40; jmp r11`, then the landing pad.
    assert_eq!(obj.text[(f0.start + f0.region) as usize..][..7], [0x48, 0x83, 0xec, 40, 0x41, 0xff, 0xe3]);
    assert_eq!(f0.call_sites[0].pad, Some(f0.region + 7));
    // The `.pdata` fields, and every `UNWIND_INFO`'s handler.
    assert_eq!(obj.relocs.iter().filter(|r| r.kind == RelocKind::Rva32).count(), 12 + 4);
    let handlers: Vec<_> = obj.relocs.iter().filter(|r| r.target == RelocTarget::SehHandler).map(|r| (r.section, r.offset)).collect();
    assert_eq!(handlers[..2], [(Section::Xdata, 12), (Section::Xdata, infos[1] as u64 + 8)]);
    // No personality on PE.
    assert_eq!(obj.symbols.len(), 4);
}

/// The `.xdata` offsets of a PE image object's `UNWIND_INFO`s, in `.pdata` order.
fn pe_infos(obj: &ImageObject) -> Vec<usize> {
    let mut out: Vec<(u64, usize)> =
        obj.relocs.iter().filter(|r| r.section == Section::Pdata && r.offset % 12 == 8).map(|r| (r.offset, r.addend as usize)).collect();
    out.sort();
    out.into_iter().map(|(_, x)| x).collect()
}

/// `pe_unwind_info` byte for byte (hand-checked against the x64 `UNWIND_INFO` layout, and
/// decoded by `llvm-readobj --unwind` from a COFF object holding them): every allocation
/// form, the probe's call near and through `r11`, a counter check before the prologue.
#[test]
fn pe_unwind_info_encodings() {
    let pe = Mode { pe: true, fp_arg: false, ..ELF };
    let info = |frame_size: u32, prologue: u32, mode: Mode| {
        ryo_bytecode::image::pe_unwind_info(&EhFunc { len: 1000, frame_size, prologue, entry_stub: 1000 }, mode)
    };
    // The push and the frame register, last first: set fpreg after 4 bytes (`mov rbp, rsp`),
    // push rbp (5) after 1.
    let tail = |p: u8| [p + 4, 3, p + 1, 5 << 4];
    // F = 0: nothing allocated; the prologue is the 4 bytes of `push` and `mov`.
    assert_eq!(info(0, 0, pe), [&[1, 4, 2, 5][..], &tail(0)].concat());
    // F = 16: `sub rsp, 16` (imm8) after 8, UWOP_ALLOC_SMALL of 2 slots.
    assert_eq!(info(16, 0, pe), [&[1, 8, 3, 5, 8, 2 | 1 << 4][..], &tail(0), &[0, 0]].concat());
    // F = 128: `sub rsp, 128` (imm32, 7 bytes) after 11, UWOP_ALLOC_SMALL of 16 slots.
    assert_eq!(info(128, 0, pe), [&[1, 11, 3, 5, 11, 2 | 15 << 4][..], &tail(0), &[0, 0]].concat());
    // F = 144: UWOP_ALLOC_LARGE with 18 slots in a 16-bit field.
    assert_eq!(info(144, 0, pe), [&[1, 11, 4, 5, 11, 1, 18, 0][..], &tail(0)].concat());
    // F = 4096: `mov eax, 4096; call ryo_probe_stack` (10 bytes) before the `sub`.
    assert_eq!(info(4096, 0, pe), [&[1, 21, 4, 5, 21, 1, 0, 2][..], &tail(0)].concat());
    // Through `r11` (`mov eax, 4096; mov r11, imm64; call r11`, 18 bytes).
    assert_eq!(info(4096, 0, Mode { far_rt: true, ..pe }), [&[1, 29, 4, 5, 29, 1, 0, 2][..], &tail(0)].concat());
    // 512 KiB allocated, past the 16-bit form: UWOP_ALLOC_LARGE with the size in 32 bits.
    let big = info(512 * 1024 + 16, 0, pe);
    assert_eq!(big, [&[1, 21, 5, 5, 21, 0x11, 0x10, 0, 8, 0][..], &tail(0), &[0, 0]].concat());
    // A counter check of 12 bytes first: every offset moves by 12.
    assert_eq!(info(48, 12, pe), [&[1, 20, 3, 5, 20, 2 | 5 << 4][..], &tail(12), &[0, 0]].concat());
    assert_eq!(PE_LEAF_UNWIND, [1, 0, 0, 0]);
    // The SSA pipeline's forms: a push of rbx (3) after 4, an allocation, the frame register at
    // rsp + 32 after 13, saves of r12 by `mov` (8-scaled 16-bit, then 32-bit unscaled) and of
    // xmm6 (16-scaled).
    use ryo_bytecode::image::{PeUnwindOp as U, pe_unwind_codes};
    let ops = [
        (1, U::Push(5)),
        (4, U::Push(3)),
        (8, U::Alloc(8)),
        (13, U::SetFpreg),
        (17, U::Save(12, 16)),
        (25, U::Save(12, 0x80000)),
        (30, U::SaveXmm(6, 32)),
    ];
    assert_eq!(
        pe_unwind_codes(30, 2, &ops),
        [1, 30, 11, 0x25, 30, 8 | 6 << 4, 2, 0, 25, 5 | 12 << 4, 0, 0, 8, 0, 17, 4 | 12 << 4, 2, 0, 13, 3, 8, 2, 4, 3 << 4, 1, 5 << 4, 0, 0]
    );
}

/// `pe_with_handler`, the pad region's `UNWIND_INFO` and the handler data, byte for byte
/// (the x64 `UNWIND_INFO` layout: the handler's RVA after the codes, whose array has an even
/// count, then the language-specific data), and `lsda::find` on them.
#[test]
fn pe_unwind_with_handler() {
    use ryo_bytecode::asm::{CallSite, lsda};
    use ryo_bytecode::image::{PE_HANDLER_FLAGS, PeHandlerData, pe_handler_data, pe_region_unwind_info, pe_with_handler};
    let pe = Mode { pe: true, fp_arg: false, ..ELF };
    // F = 48: 3 codes, padded to 4; the RVA at 12, then the data, padded to 4.
    let info = ryo_bytecode::image::pe_unwind_info(&EhFunc { len: 1000, frame_size: 48, prologue: 0, entry_stub: 1000 }, pe);
    assert_eq!(info.len(), 12);
    let (h, rva) = pe_with_handler(&info, &[0xaa, 0xbb, 0xcc]);
    assert_eq!(PE_HANDLER_FLAGS, 0x18);
    assert_eq!(h[0], 1 | 0x18);
    assert_eq!((rva, &h[1..12], &h[12..]), (12, &info[1..], &[0, 0, 0, 0, 0xaa, 0xbb, 0xcc, 0][..]));
    // 4 codes need no padding: the RVA right after them.
    let info = ryo_bytecode::image::pe_unwind_info(&EhFunc { len: 1000, frame_size: 144, prologue: 0, entry_stub: 1000 }, pe);
    let (h, rva) = pe_with_handler(&info, &[]);
    assert_eq!((info.len(), rva, h.len()), (12, 12, 16));
    // The region: `sub rsp, 40` (4 bytes) is the prologue, UWOP_ALLOC_SMALL of 5 slots, no
    // frame register.
    assert_eq!(pe_region_unwind_info(), [1, 4, 1, 0, 4, 2 | 4 << 4, 0, 0]);

    let sites = [
        CallSite { start: 10, len: 5, pad: Some(100), catch: false },
        CallSite { start: 20, len: 6, pad: None, catch: false },
        CallSite { start: 130, len: 5, pad: Some(170), catch: true },
    ];
    let l = lsda::write(&sites);
    let data = pe_handler_data(96, 96, &l);
    assert_eq!(&data[..12], [96, 0, 0, 0, 96, 0, 0, 0, l.len() as u8, 0, 0, 0]);
    let d = PeHandlerData::parse(&data).unwrap();
    assert_eq!((d.begin, d.region, d.lsda), (96, 96, &l[..]));
    assert_eq!(unsafe { PeHandlerData::from_ptr(data.as_ptr()) }, Some(d));
    assert_eq!(PeHandlerData::parse(&data[..data.len() - 1]), None);
    for (pc, want) in [(9, None), (10, Some(sites[0])), (14, Some(sites[0])), (15, None), (25, Some(sites[1])), (134, Some(sites[2])), (500, None)] {
        assert_eq!(lsda::find(d.lsda, pc), Some(want), "pc {pc}");
    }
    assert_eq!(lsda::find(&l[1..], 10), None);
    assert_eq!(lsda::find(&lsda::write(&[]), 0), Some(None));
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
    // Fixups: out of range, bad symbol (unaligned is fine: packed constants).
    let fx = |h: &Header| h.fixups.off as usize;
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fx(h), 4096)), Err(ImageError::BadFixup(0)));
    assert_eq!(validate_edited(&obj, |r, h| put32(r, fx(h) + 4, 5)), Err(ImageError::BadFixup(0)));
    // Unknown symbol flag bits.
    assert_eq!(validate_edited(&obj, |r, h| r[h.sym_flags.off as usize + 2] = 0x80), Err(ImageError::BadSymbolFlags(2)));
    // Unknown function flag bits.
    assert_eq!(validate_edited(&obj, |r, h| r[h.func_flags.off as usize + 1] = 0x10), Err(ImageError::BadFuncFlags(1)));
    // Constant relocations: out of order (overlapping), past the pool; unaligned is fine.
    let cr = |h: &Header, i: usize| h.const_relocs.off as usize + 4 * i;
    assert_eq!(validate_edited(&obj, |r, h| put32(r, cr(h, 1), 0)), Err(ImageError::BadConstReloc(1)));
    assert_eq!(validate_edited(&obj, |r, h| put32(r, cr(h, 0), 1)), Ok(()));
    assert_eq!(validate_edited(&obj, |r, h| put32(r, cr(h, 1), 9)), Err(ImageError::BadConstReloc(1)));
    assert_eq!(validate_edited(&obj, |r, h| put32(r, cr(h, 1), h.consts.count - 4)), Err(ImageError::BadConstReloc(1)));
    assert_eq!(validate_edited(&obj, |_, _| ()), Ok(()));
}

/// The constant relocation table is exactly the pool offsets of the object's relocations in
/// the pool, and classifies reads.
#[test]
fn const_relocs_match_object() {
    let obj = sample().finish(ELF).unwrap();
    let b = Buf::new(&obj.rodata, 8);
    let img = Image::parse(b.bytes()).unwrap();
    let h = img.header();
    let (lo, hi) = (h.consts.off as u64, h.consts.off as u64 + h.consts.count as u64);
    let mut want: Vec<u32> =
        obj.relocs.iter().filter(|r| r.section == Section::ReadOnly && (lo..hi).contains(&r.offset)).map(|r| (r.offset - lo) as u32).collect();
    want.sort();
    assert_eq!(img.const_relocs(), &want[..]);
    assert_eq!(want, [8, 16]);
    let f = want[0];
    assert_eq!(img.const_reloc_at(f, 8), Some(true));
    assert_eq!(img.const_reloc_at(f, 4), None);
    assert_eq!(img.const_reloc_at(f + 4, 8), None);
    assert_eq!(img.const_reloc_at(f + 8, 8), Some(true));
    assert_eq!(img.const_reloc_at(f, 16), None);
    assert_eq!(img.const_reloc_at(0, 6), Some(false));
    assert_eq!(img.const_reloc_at(24, 8), Some(false));
}

#[test]
fn writer_rejects_bad_alloc_relocs() {
    // A pointer past its constant's end.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", 0);
    w.add_const(&[0; 16], 8, &[AllocReloc { offset: 12, target: AllocTarget::Symbol(s), addend: 0 }]);
    assert_eq!(w.finish(ELF).unwrap_err(), WriteError::AllocReloc);
    // An unaligned one (a packed constant) is fine, in the relocation table at its offset.
    let mut w = ImageWriter::new(1);
    let s = w.symbol("x", 0);
    w.add_const(&[0; 3], 1, &[]);
    w.add_const(&[0; 9], 1, &[AllocReloc { offset: 1, target: AllocTarget::Symbol(s), addend: 0 }]);
    let obj = w.finish(ELF).unwrap();
    let b = Buf::new(&obj.rodata, 8);
    let img = Image::parse(b.bytes()).unwrap();
    assert_eq!(img.validate(), Ok(()));
    assert_eq!(img.const_relocs(), &[4]);
    assert_eq!(img.const_reloc_at(4, 8), Some(true));
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
    // The writable section is 8-aligned even with 1-aligned data.
    let mut w = ImageWriter::new(1);
    let d = w.add_data(&[1], 1, &[], &[]);
    let obj = w.finish(ELF).unwrap();
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
            let list = InsnList::read(img.list(i as u32), e.code.len() as u32).unwrap();
            let sites: Vec<CallSite> = img.call_sites(i as u32).iter().map(CallSite::from).collect();
            assert_eq!((list, sites), (e.list(), e.call_sites.clone()), "{mode:?}");
        }
        assert!(img.list(2).is_empty());

        // `validate` checks the runs and the entries.
        use std::mem::{offset_of, size_of};
        let fe = |h: &Header, i: usize, field: usize| h.functions.off as usize + i * size_of::<FuncEntry>() + field;
        let cs = |h: &Header, i: usize, field: usize| h.call_sites.off as usize + i * size_of::<CallSiteEntry>() + field;
        let n = img.list(0).len() as u32;
        assert_eq!(validate_edited(&obj, |r, h| put32(r, fe(h, 1, offset_of!(FuncEntry, list)), n + 1)), Err(ImageError::BadFunction(1)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, fe(h, 0, offset_of!(FuncEntry, call_sites) + 4), 3)), Err(ImageError::BadFunction(0)));
        // An entry past the code, and one cut short.
        assert_eq!(validate_edited(&obj, |r, h| r[h.lists.off as usize] = 0xfe), Err(ImageError::BadList(0)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, fe(h, 0, offset_of!(FuncEntry, list) + 4), n - 1)), Err(ImageError::BadList(0)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, cs(h, 1, offset_of!(CallSiteEntry, len)), 10_000)), Err(ImageError::BadCallSite(1)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, cs(h, 0, offset_of!(CallSiteEntry, pad)), 10_000)), Err(ImageError::BadCallSite(0)));
        assert_eq!(validate_edited(&obj, |r, h| put32(r, cs(h, 1, 0), 0)), Err(ImageError::BadCallSite(1)));
        assert!(matches!(validate_edited(&obj, |r, _| put32(r, offset_of!(Header, mode), MODE_PE)), Err(ImageError::BadMode)));
        assert!(matches!(validate_edited(&obj, |r, _| put32(r, offset_of!(Header, mode), 32)), Err(ImageError::BadMode)));
        // Counters need the JIT records, and the other way round.
        let bits = mode.to_header_bits() ^ MODE_COUNTERS;
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
            let want = asm::decode_reduced(&asm::Encoded { relocs, rodata: cc.to_vec(), ..e.clone() }, mode).unwrap();
            assert_eq!(got, want, "f{i} {mode:?}");
        }
        // Not a function.
        assert!(res.decode(enc.len() as u32, l.text.bytes()).is_none());
    }
}

/// The sample image's functions (and [`dead_stores`]) encoded in `mode` and linked, the
/// handlers called through `stubs` if given.
fn linked_sample(mode: Mode, stubs: Option<Stubs<'_>>) -> (Vec<asm::Encoded>, Linked, Option<Buf>) {
    let mut w = sample();
    let mut enc: Vec<asm::Encoded> = w.functions().iter().map(|f| asm::encode(&f.code, f.frame_size, &f.cleanup, &[], mode).unwrap()).collect();
    enc.push(dead_stores(mode));
    w.add_function(FunctionDef { name: "dead".into(), frame_size: 64, ..Default::default() });
    w.prepare(mode);
    let obj = w.finish_encoded(enc.clone()).unwrap();
    let (l, plt) = link_with(&obj, |s| 0x1000 + s.name.len() as u64, stubs);
    (enc, l, plt)
}

/// What decoding function `e` of the linked image `img` must give: its encoder output decoded
/// with its relocations, its code constants at their place in the image's.
fn want_decoded(img: Image<'_>, e: &asm::Encoded, mode: Mode) -> asm::Decoded {
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
    asm::decode_reduced(&asm::Encoded { relocs, rodata: cc.to_vec(), ..e.clone() }, mode).unwrap()
}

/// Whether `e` calls a handler.
fn calls_handler(e: &asm::Encoded) -> bool {
    e.relocs.iter().any(|r| matches!(r.to, asm::Ref::Handler(_)))
}

/// The handler table with every opcode's handler at its own address ([`handler_addr`]), and
/// with `folded` also each opcode's partner (`op ^ 1`) there, as if MergeFunctions or ICF had
/// folded each pair: the address alone doesn't tell them apart.
fn handler_table(text: &Buf, folded: bool) -> Vec<(usize, Opcode)> {
    let mut t: Vec<(usize, Opcode)> = ALL_OPCODES.iter().map(|&op| (handler_addr(text, op) as usize, op)).collect();
    if folded {
        t.extend(ALL_OPCODES.iter().filter_map(|&op| Some((handler_addr(text, op) as usize, Opcode::from_u16(op as u16 ^ 1)?))));
    }
    t.sort();
    t
}

/// Folded handlers (several opcodes at one address) decode by the call's instruction list
/// entry, which must name one of them; a call without one, or naming another, fails.
#[test]
fn folded_handlers_decode_by_list() {
    for mode in [ELF, Mode { pe: true, ..ELF }, AOT] {
        let (enc, l, _) = linked_sample(mode, None);
        let img = unsafe { Image::from_header(l.ro.bytes().as_ptr()) }.unwrap();
        let handlers = handler_table(&l.text, true);
        let res = ImageResolver { image: img, handlers: &handlers, probe: probe_addr(&l.text) as usize };
        let mut checked = 0;
        for (i, e) in enc.iter().enumerate() {
            let got = res.decode(i as u32, l.text.bytes()).expect("a function").unwrap_or_else(|e| panic!("f{i} {mode:?}: {e:?}"));
            assert_eq!(got, want_decoded(img, e, mode), "f{i} {mode:?}");
            if !calls_handler(e) {
                continue;
            }
            // The list changed: decoded as `ImageResolver::decode` does.
            let f = img.functions()[i];
            let code = &l.text.bytes()[f.code_off as usize..][..f.code_len as usize];
            let sites: Vec<CallSite> = img.call_sites(i as u32).iter().map(CallSite::from).collect();
            let record = mode.counters.then(|| img.jit_records().wrapping_add(i) as u64);
            let addr = l.text.addr() + f.code_off as u64;
            let list = InsnList::read(img.list(i as u32), f.code_len).unwrap();
            let decode = |list: &InsnList| asm::decode_linked(code, addr, record, &res, &sites, list, mode);
            assert!(decode(&list).is_ok());
            let h = list.hints.iter().position(|h| h.is_handler()).expect("a handler call's entry");
            // Missing.
            let mut missing = list.clone();
            missing.hints.remove(h);
            assert!(decode(&missing).is_err(), "f{i} {mode:?}: without the entry");
            // Naming an opcode whose handler isn't at the call's target.
            let op = list.hints[h].op;
            let other = ALL_OPCODES.iter().copied().find(|&o| o != op && o as u16 != op as u16 ^ 1).unwrap();
            let mut outside = list.clone();
            outside.hints[h].op = other;
            assert!(decode(&outside).is_err(), "f{i} {mode:?}: {other:?} for {op:?}");
            // An inline sequence's entry there instead.
            let mut inline = list.clone();
            inline.hints[h].sel = 0;
            assert!(decode(&inline).is_err(), "f{i} {mode:?}: an inline entry");
            // A stray handler entry.
            let mut stray = list.clone();
            stray.hints.insert(h, asm::Hint { sel: asm::HANDLER_SEL, ..list.hints[h] });
            assert!(decode(&stray).is_err(), "f{i} {mode:?}: a second entry");
            checked += 1;
        }
        assert!(checked >= 2, "{mode:?}");
    }
}

/// Handler calls through PLT stubs or import thunks (`jmp [rip + slot]`, after an `endbr64`
/// and with a `bnd` prefix or not) resolve through their slot, also to folded handlers; a
/// lazily bound slot, which points back into the PLT, resolves to nothing (the function isn't
/// decoded, rather than misread).
#[test]
fn handlers_through_stubs() {
    const ENDBR64: [u8; 4] = [0xf3, 0x0f, 0x1e, 0xfa];
    for mode in [ELF, AOT] {
        for prefix in [&[][..], &ENDBR64, &[0xf2], &[0xf3, 0x0f, 0x1e, 0xfa, 0xf2]] {
            for folded in [false, true] {
                let (enc, l, _plt) = linked_sample(mode, Some(Stubs { prefix, lazy: false }));
                let img = unsafe { Image::from_header(l.ro.bytes().as_ptr()) }.unwrap();
                let handlers = handler_table(&l.text, folded);
                let res = ImageResolver { image: img, handlers: &handlers, probe: probe_addr(&l.text) as usize };
                for (i, e) in enc.iter().enumerate() {
                    let got =
                        res.decode(i as u32, l.text.bytes()).expect("a function").unwrap_or_else(|e| panic!("f{i} {mode:?} {prefix:x?}: {e:?}"));
                    assert_eq!(got, want_decoded(img, e, mode), "f{i} {mode:?} {prefix:x?}");
                }
            }
        }
        let (enc, l, _plt) = linked_sample(mode, Some(Stubs { prefix: &ENDBR64, lazy: true }));
        let img = unsafe { Image::from_header(l.ro.bytes().as_ptr()) }.unwrap();
        let handlers = handler_table(&l.text, false);
        let res = ImageResolver { image: img, handlers: &handlers, probe: probe_addr(&l.text) as usize };
        let mut lazy = 0;
        for (i, e) in enc.iter().enumerate() {
            let got = res.decode(i as u32, l.text.bytes()).expect("a function");
            if calls_handler(e) {
                assert!(got.is_err(), "f{i} {mode:?}: decoded through a lazily bound slot");
                lazy += 1;
            } else {
                assert_eq!(got.unwrap(), want_decoded(img, e, mode), "f{i} {mode:?}");
            }
        }
        assert!(lazy >= 2);
    }
}

/// The dropped stores of `finish_encoded`'s `Encoded`s are read back unchanged.
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
            let read = InsnList::read(img.list(i as u32), e.code.len() as u32).unwrap();
            assert_eq!(read.dropped, e.dropped, "{mode:?}");
        }
        assert!(enc[1].dropped.len() >= 2);
        assert_eq!(enc[1].dropped[0].parts().0, -56);
    }
}

/// Instruction lists: written and read back, and malformed ones rejected.
#[test]
fn insn_lists() {
    use asm::{Hint, InsnList};
    let e = dead_stores(AOT);
    let l = e.list();
    assert!(!l.targets.is_empty() || !l.hints.is_empty() || !l.dropped.is_empty());
    let b = l.write();
    assert_eq!(InsnList::read(&b, e.code.len() as u32), Some(l.clone()));
    // Every prefix that cuts an entry short, and every position past the code, fails.
    for n in 0..b.len() {
        if let Some(p) = InsnList::read(&b[..n], e.code.len() as u32) {
            assert!(
                p.targets.len() + p.hints.len() + p.dropped.len() + p.scopes.len()
                    < l.targets.len() + l.hints.len() + l.dropped.len() + l.scopes.len()
            );
        }
    }
    let last = [l.targets.last(), l.dropped.last().map(|d| &d.at), l.hints.last().map(|h| &h.at)].into_iter().flatten().max().copied().unwrap();
    assert_eq!(InsnList::read(&b, last - 1), None);
    let one = |x: InsnList| InsnList::read(&x.write(), 100);
    let s = |kind| Scope { code_offset: 3, frame_offset: -8, size: 8, kind };
    let sc = InsnList { scopes: vec![s(ScopeKind::Escape { align: 16 }), s(ScopeKind::End), s(ScopeKind::Lend)], ..Default::default() };
    assert_eq!(one(sc.clone()), Some(sc));
    let h = InsnList { hints: vec![Hint { at: 7, op: Opcode::AddW64, sel: 0x35 }], targets: vec![0, 7], ..Default::default() };
    assert_eq!(one(h.clone()), Some(h));
    // A target twice at one position; entries out of order; a bad alignment; an unknown kind.
    assert_eq!(InsnList::read(&[1, 0, 1, 0], 10), None);
    assert_eq!(InsnList::read(&[1, 1, 0, 0x30, 1, 0], 10), None);
    assert_eq!(InsnList::read(&[1, 2, 0, 8, 3], 10), None);
    assert_eq!(InsnList::read(&[1, 9], 10), None);
    assert_eq!(InsnList::read(&[1, 0, 1, 1, 0, 0x30], 10).map(|l| l.dropped.len()), Some(1));
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
        assert!(h.jit_records.off > 16);
        let t = l.text.bytes();
        for (i, f) in obj.functions.iter().enumerate() {
            let rec = img.jit_records().wrapping_add(i) as u64;
            assert_eq!(rec, l.data.addr() + h.jit_records.off as u64 + 64 * i as u64);
            let r = unsafe { &*(rec as *const JitRecord) };
            assert_eq!(
                (r.ctr_e, r.ctr_l, r.entry as u64, r.osr as u64, r.next as u64),
                (-JIT_ENTRY_THRESHOLD, -JIT_THRESHOLD, trip_addr(&l.text, false), trip_addr(&l.text, true), 0)
            );
            assert_eq!((r.state.load(std::sync::atomic::Ordering::Relaxed), r.func, r.header as u64), (JIT_COLD, i as u32, l.ro.addr()));
            // `inc qword [rip + x]` reaches the call counter, `jns` the entry's stub, whose
            // `lea r11, [rip + x]` the record.
            let at = f.start as u64;
            assert_eq!(t[at as usize..][..3], [0x48, 0xff, 0x05]);
            assert_eq!((l.text.addr() + at + 7).wrapping_add(i32_at(&l.text, at + 3) as i64 as u64), rec);
            assert_eq!(t[at as usize + 7], 0x79); // `jns rel8`
            assert_eq!(at as i64 + 9 + t[at as usize + 8] as i8 as i64, (f.start + f.eh.entry_stub) as i64);
            assert_eq!(f.eh.prologue, 9);
            let stub = (f.start + f.eh.entry_stub) as u64;
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
            assert!(eh.windows(7).any(|w| w == [0x40 | 10, 0x0e, 16, 0x86, 2, 0x40 | 3, 0x0d]), "{eh:02x?}");
        } else {
            assert!(eh.windows(3).any(|w| w == [0x40 | 13, 0x0e, 64]), "{eh:02x?}");
        }
        assert!(f0.eh.entry_stub > f0.eh.prologue);
    }
    // PE: the check is part of the prologue, and the entry's stub has an entry of its own,
    // before f0's pad region's.
    let obj = sample().finish(Mode { pe: true, ..AOT }).unwrap();
    assert_eq!(obj.unwind[0].1.len(), (2 * 3 + 1) * 12);
    let x = &obj.unwind[1].1;
    let infos = pe_infos(&obj);
    assert_eq!(&x[..10], [1 | 0x18, 17, 3, 5, 17, 2 | (48 / 8 - 1) << 4, 13, 3, 10, 5 << 4]);
    assert_eq!(&x[infos[1]..][..4], [1, 0, 0, 0]);
    assert_eq!(&x[infos[2]..][..8], [&[1 | 0x18][..], &ryo_bytecode::image::pe_region_unwind_info()[1..]].concat());
}
