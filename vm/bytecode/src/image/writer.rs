//! The image writer (backend side, needs `alloc`).
//!
//! [`ImageWriter`] collects functions, constants and symbols, and
//! [`ImageWriter::finish`] encodes the functions ([`crate::asm`]) and lays out the three
//! sections. The result, [`ImageObject`], is plain bytes plus a relocation list and each
//! function's unwind information; the backend turns it into an object file (with the
//! `object` crate), defining `__ryo_image_<StableCrateId>` at offset 0 of the read-only
//! section.
//!
//! The data relocations are absolute 64-bit addresses (`R_X86_64_64` /
//! `IMAGE_REL_AMD64_ADDR64`), written at `offset` in `section`, of `target + addend`:
//!
//! - the header's `data` and `text` fields → the writable and text sections
//! - each symbol slot → its symbol. For symbols flagged [`SYM_INDIRECT`], the backend
//!   relocates against `__imp_<name>` instead (design/platforms.md).
//! - pointers inside constant and fixup-area allocations → a symbol, or the read-only or
//!   writable section (intra-image)
//!
//! The code's are 32-bit PC-relative fields ([`RelocKind::Pc32`], [`RelocKind::Call32`]):
//! RIP-relative addresses of symbol slots, constants, the data area and code
//! constants, and calls of the handlers and `ryo_probe_stack`. Calls between functions are
//! resolved by the writer.

use alloc::collections::BTreeMap;
use alloc::string::String;
use alloc::vec;
use alloc::vec::Vec;
use core::{mem, slice};

use super::*;
use crate::asm::{self, CallSite, Encoded, Mode, Ref};
use crate::full::{Abs, Const, Data, DecodeError, Decoder, Func, Opcode, OperandKind, Sym};

/// A symbol referenced by the image.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SymbolDef {
    pub name: String,
    /// [`SYM_INDIRECT`] or 0.
    pub flags: u8,
}

/// What a pointer inside an allocation points at.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum AllocTarget {
    /// A native symbol (function or static).
    Symbol(Sym),
    /// A constant pool allocation (intra-image).
    Const(Const),
    /// A fixup-area allocation (intra-image).
    Data(Data),
}

/// A pointer inside an allocation: the 8 bytes at `offset` become `target + addend`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct AllocReloc {
    pub offset: u32,
    pub target: AllocTarget,
    pub addend: i64,
}

/// A PE fixup inside a fixup-area allocation: the 8 bytes at `offset` become the address
/// loaded through the (indirect) symbol slot `sym`, plus `addend`, at registration.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct AllocFixup {
    pub offset: u32,
    pub sym: Sym,
    pub addend: i64,
}

/// One function's instruction words and tables.
#[derive(Clone, Debug, Default)]
pub struct FunctionDef {
    /// The symbol naming its machine code: local (for backtraces and profilers), or defined
    /// as `symbol` says.
    pub name: String,
    pub code: Vec<u32>,
    /// The frame size `F` ([`crate::abi::frame_size`]): the prologue reserves it, and the
    /// unwind information describes it. Not stored in the image.
    pub frame_size: u32,
    /// See [`FuncEntry::arg_size`].
    pub arg_size: u32,
    /// See [`FuncEntry::ret_size`].
    pub ret_size: u32,
    /// See [`FuncEntry::ret_kind`].
    pub ret_kind: u32,
    /// Cleanup entries, in any order (the writer sorts them): one per call-like instruction
    /// that can unwind.
    pub cleanup: Vec<CleanupEntry>,
    /// The function's symbol is global: native code calls it by name.
    pub symbol: Option<FuncSymbol>,
    /// [`FUNC_INLINE_ALWAYS`] etc.: the source attributes the JIT's inliner reads.
    pub flags: u8,
}

/// How a function's symbol is defined in the image object, if it is global ([`FunctionDef`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FuncSymbol {
    /// ELF visibility: default, hidden or protected (PE has none: a DLL exports what its
    /// export list names).
    pub visibility: SymVisibility,
    /// A weak definition (ELF; on PE, an ordinary one).
    pub weak: bool,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SymVisibility {
    Default,
    Hidden,
    Protected,
}

/// Section of an [`ImageObject`].
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Section {
    ReadOnly,
    Writable,
    /// The machine code (executable).
    Text,
    /// ELF: `.eh_frame` (CIE and FDEs).
    EhFrame,
    /// ELF: `.gcc_except_table` (the LSDAs).
    Lsda,
    /// PE: `.pdata` (function table).
    Pdata,
    /// PE: `.xdata` (unwind info).
    Xdata,
}

/// A relocation target.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RelocTarget {
    /// [`ImageObject::symbols`]`[i]`.
    Symbol(Sym),
    /// The start of a section of this image.
    Section(Section),
    /// The handler `ryo_h_<op>` in `ryo_rt`.
    Handler(Opcode),
    /// `ryo_probe_stack` in `ryo_rt`.
    Probe,
    /// `ryo_jit_trip_entry` and `ryo_jit_trip_osr` in `ryo_rt`: what the JIT records' slots
    /// start at.
    TripEntry,
    TripOsr,
    /// `ryo_seh_handler` in `ryo_rt`: the language handler of PE unwind info.
    SehHandler,
}

/// How a relocated field is written.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RelocKind {
    /// 64 bits: `target + addend`.
    Abs64,
    /// 32 bits: `target + addend - field` (RIP-relative data).
    Pc32,
    /// 32 bits, as `Pc32`, of a call (through the PLT if the target is in a shared object).
    Call32,
    /// 64 bits: `target + addend - field` (the `.eh_frame` pointers of [`EhPointers::Abs8`]).
    Pc64,
    /// 32 bits: `target + addend` relative to the image base (PE `ADDR32NB`).
    Rva32,
}

/// A relocation.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Reloc {
    pub section: Section,
    pub offset: u64,
    pub target: RelocTarget,
    pub addend: i64,
    pub kind: RelocKind,
}

/// A function's machine code in the text section, with what its unwind information needs.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FuncCode {
    pub name: String,
    pub symbol: Option<FuncSymbol>,
    pub start: u32,
    pub len: u32,
    pub frame_size: u32,
    /// Positions relative to `start`.
    pub call_sites: Vec<CallSite>,
    /// Where the prologue starts, where the entry's counter stub does and where the PE pad
    /// region does (`len` if none), relative to `start` ([`Encoded::prologue`],
    /// [`Encoded::entry_stub`], [`Encoded::region`]).
    pub prologue: u32,
    pub entry_stub: u32,
    pub region: u32,
}

/// A written image: section contents and relocations.
#[derive(Clone, Debug)]
pub struct ImageObject {
    /// Read-only section (RELRO / `.rdata`); the header is at offset 0.
    pub rodata: Vec<u8>,
    pub rodata_align: u64,
    /// Writable section (`.data`).
    pub data: Vec<u8>,
    pub data_align: u64,
    /// Text section, aligned to 16.
    pub text: Vec<u8>,
    pub functions: Vec<FuncCode>,
    /// The unwind sections: [`Section::EhFrame`] and [`Section::Lsda`] (ELF), or
    /// [`Section::Pdata`] and [`Section::Xdata`] (PE).
    pub unwind: Vec<(Section, Vec<u8>)>,
    /// Symbols, indexed by [`Sym`].
    pub symbols: Vec<SymbolDef>,
    pub relocs: Vec<Reloc>,
}

/// An invalid instruction or operand.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CodeError {
    Decode(DecodeError),
    /// A branch target isn't the start of an instruction in the same function.
    BadTarget,
    FuncOutOfRange,
    SymOutOfRange,
    /// A `sym` operand's slot is indirect ([`SYM_INDIRECT`]) but the instruction loads it
    /// directly, or the other way round. Only `addr.sym.ind` and `call.ext.ind` load through
    /// the slot; island symbols (`isl`) are always direct.
    SymIndirection,
    ConstOutOfRange,
    DataOutOfRange,
    /// The last instruction can fall through past the function's end.
    FallsOffEnd,
    /// A call or `ret` passes its return value in a way the machine code can't, or an `arg`
    /// names an invalid register ([`crate::asm::return_ok`]).
    BadReturn,
    /// An `arg` after an instruction that isn't one.
    ArgNotFirst,
    /// A reference to the function's JIT record without [`Mode::counters`].
    NoJitRecord,
    /// A reference only JIT code makes (a handler's register entry, [`Ref::RegHandler`]).
    JitOnly,
}

/// A code reference of an encoded function, resolved once the image layout is known.
#[derive(Clone, Copy)]
struct CodeRef {
    /// Text offset of the field.
    at: u32,
    to: Ref,
    /// Text offset of the function.
    start: u32,
    /// Offset of the function's rodata in the code-constants area.
    ro_base: u32,
    func: u32,
}

/// The fields of a [`JitRecord`] the linker fills in ([`JitRecord::image_bytes`] leaves them
/// 0), and with what.
const JIT_RECORD_RELOCS: [(usize, RelocTarget); 3] = [
    (mem::offset_of!(JitRecord, entry), RelocTarget::TripEntry),
    (mem::offset_of!(JitRecord, osr), RelocTarget::TripOsr),
    (mem::offset_of!(JitRecord, header), RelocTarget::Section(Section::ReadOnly)),
];

/// Why [`ImageWriter::finish`] failed.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum WriteError {
    /// Instruction at `offset` of function `func`: a word offset in word-level code, a byte
    /// offset in the function's machine code for encoded functions (the reference's field).
    Code { func: u32, offset: u32, error: CodeError },
    /// A duplicate cleanup entry, one not at a call-like instruction, or one whose landing
    /// pad isn't an `lpad` instruction.
    Cleanup(u32),
    /// Allocation relocation or fixup out of range or misplaced, or a relocation against an
    /// indirect symbol (that must be a fixup).
    AllocReloc,
    /// A section exceeds `u32` offsets.
    TooLarge,
    /// The machine-code encoder rejected function `func`.
    Encode { func: u32, error: asm::EncodeError },
}

/// Index ranges that [`validate_code`] checks operands against.
#[derive(Clone, Copy, Debug)]
pub struct CodeLimits {
    pub functions: u32,
    pub symbols: u32,
    /// Constant pool size in bytes.
    pub consts: u32,
    /// Fixup area size in bytes.
    pub data: u32,
}

pub(crate) fn op_falls_through(op: Opcode) -> bool {
    !matches!(op, Opcode::Jmp | Opcode::Unreachable | Opcode::Abort | Opcode::Ret | Opcode::Resume | Opcode::TailCall | Opcode::TailCallPtr)
        && !op.mnemonic().starts_with("switch.")
}

/// Whether `op` calls code that may unwind, so it can have a cleanup entry.
pub fn op_may_unwind(op: Opcode) -> bool {
    matches!(op, Opcode::Call | Opcode::CallSym | Opcode::CallSymInd | Opcode::CallPtr | Opcode::Island | Opcode::Resume)
}

/// Decodes all of `code` (one function) and checks every operand: indices in range, branch
/// targets on instruction starts within the function, and no fall-through past the end.
/// Returns the instruction start bitmap.
pub fn validate_code(code: &[u32], lim: &CodeLimits) -> Result<Vec<bool>, (u32, CodeError)> {
    let mut starts = vec![false; code.len()];
    let mut last = None;
    for r in Decoder::new(code) {
        let (at, insn) = r.map_err(|e| (code.len() as u32, CodeError::Decode(e)))?;
        starts[at] = true;
        last = Some(insn.opcode());
    }
    if let Some(op) = last {
        if op_falls_through(op) {
            return Err((code.len() as u32, CodeError::FallsOffEnd));
        }
    }
    let target_ok = |at: usize, t: i32| -> bool {
        let p = at as i64 + t as i64;
        p >= 0 && (p as usize) < code.len() && starts[p as usize]
    };
    let mut args_only = true;
    for r in Decoder::new(code) {
        let (at, insn) = r.unwrap();
        let words = &code[at..];
        let fail = |e| Err((at as u32, e));
        if !crate::asm::return_ok(words) {
            return fail(CodeError::BadReturn);
        }
        if insn.opcode() == Opcode::Arg && !args_only {
            return fail(CodeError::ArgNotFirst);
        }
        args_only &= insn.opcode() == Opcode::Arg;
        let info = insn.opcode().info();
        if !info.branch_offsets(&words[1..]).all(|t| target_ok(at, t)) {
            return fail(CodeError::BadTarget);
        }
        for (o, w) in info.operand_words(&words[1..]) {
            match o.kind {
                OperandKind::Func if w[0] >= lim.functions => return fail(CodeError::FuncOutOfRange),
                OperandKind::Sym if w[0] >= lim.symbols => return fail(CodeError::SymOutOfRange),
                OperandKind::Const if w[0] > lim.consts => return fail(CodeError::ConstOutOfRange),
                OperandKind::Abs => match Abs::from_word(w[0]) {
                    Abs::Const(k) if k.0 > lim.consts => return fail(CodeError::ConstOutOfRange),
                    Abs::Data(d) if d.0 > lim.data => return fail(CodeError::DataOutOfRange),
                    _ => {}
                },
                _ => {}
            }
        }
    }
    Ok(starts)
}

/// Checks that every `sym` operand's slot is indirect exactly when the instruction loads
/// through it (`addr.sym.ind`, `call.ext.ind`'s `sym`). `code` must have passed
/// [`validate_code`] with these symbols.
fn check_indirection(code: &[u32], symbols: &[SymbolDef]) -> Result<(), (u32, CodeError)> {
    for r in Decoder::new(code) {
        let (at, insn) = r.unwrap();
        let op = insn.opcode();
        for (o, w) in op.info().operand_words(&code[at + 1..]) {
            if o.kind == OperandKind::Sym {
                let indirect = symbols[w[0] as usize].flags & SYM_INDIRECT != 0;
                let loads_through = matches!(op, Opcode::AddrSymInd | Opcode::CallSymInd) && o.name == "sym";
                if indirect != loads_through {
                    return Err((at as u32, CodeError::SymIndirection));
                }
            }
        }
    }
    Ok(())
}

/// Validates function `i`'s code and sorts and checks its cleanup entries.
fn check_function(i: u32, f: &mut FunctionDef, lim: &CodeLimits, symbols: &[SymbolDef]) -> Result<(), WriteError> {
    let starts = validate_code(&f.code, lim)
        .and_then(|s| check_indirection(&f.code, symbols).map(|()| s))
        .map_err(|(offset, error)| WriteError::Code { func: i, offset, error })?;
    f.cleanup.sort();
    for (j, e) in f.cleanup.iter().enumerate() {
        let op_at = |o: u32| (starts.get(o as usize) == Some(&true)).then(|| Opcode::from_u16(f.code[o as usize] as u16)).flatten();
        let call = op_at(e.offset).is_some_and(op_may_unwind);
        let pad = match e.action() {
            Cleanup::Pad(p, _) => op_at(p) == Some(Opcode::Lpad),
            Cleanup::Continue => true,
        };
        if !call || !pad || (j > 0 && f.cleanup[j - 1].offset == e.offset) {
            return Err(WriteError::Cleanup(i));
        }
    }
    Ok(())
}

/// Builds an image. Functions are numbered in the order they are added.
#[derive(Clone, Debug)]
pub struct ImageWriter {
    stable_crate_id: u64,
    cgu_hash: u64,
    functions: Vec<FunctionDef>,
    consts: Vec<u8>,
    const_align: u32,
    const_relocs: Vec<AllocReloc>,
    data: Vec<u8>,
    data_align: u32,
    data_relocs: Vec<AllocReloc>,
    fixups: Vec<AllocFixup>,
    symbols: Vec<SymbolDef>,
    /// Slots by (name, flags): a symbol can have a direct and an indirect slot.
    sym_index: BTreeMap<(String, u8), u32>,
    /// The code's mode, from `prepare`.
    mode: Option<Mode>,
    /// The slot of `rust_eh_personality` (ELF).
    personality: Option<Sym>,
    eh_pointers: EhPointers,
}

/// How `.eh_frame` encodes the FDEs' first address, range and LSDA pointer
/// ([`ImageWriter::set_eh_pointers`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub enum EhPointers {
    /// 4 bytes, `DW_EH_PE_pcrel | DW_EH_PE_sdata4` ([`RelocKind::Pc32`]): ELF, and the JIT.
    #[default]
    Sdata4,
    /// 8 bytes, `DW_EH_PE_pcrel | DW_EH_PE_absptr` ([`RelocKind::Pc64`]): Mach-O, as LLVM
    /// writes `__eh_frame` there. lld reads 4-byte pointers as unsigned, so it loses FDEs
    /// whose code comes before them; Apple's linkers only ever see LLVM's form.
    Abs8,
}

/// The personality routine of VM code's unwind information (ELF).
pub const PERSONALITY: &str = "rust_eh_personality";

fn align_to(v: usize, a: usize) -> usize {
    (v + a - 1) & !(a - 1)
}

fn add_alloc(buf: &mut Vec<u8>, max_align: &mut u32, bytes: &[u8], align: u32) -> u32 {
    assert!(align.is_power_of_two(), "alignment must be a power of two");
    let off = align_to(buf.len(), align as usize);
    buf.resize(off, 0);
    buf.extend_from_slice(bytes);
    *max_align = (*max_align).max(align);
    u32::try_from(off).expect("allocation area too large")
}

impl ImageWriter {
    pub fn new(stable_crate_id: u64) -> Self {
        ImageWriter {
            stable_crate_id,
            cgu_hash: 0,
            functions: Vec::new(),
            consts: Vec::new(),
            const_align: 1,
            const_relocs: Vec::new(),
            data: Vec::new(),
            data_align: 1,
            data_relocs: Vec::new(),
            fixups: Vec::new(),
            symbols: Vec::new(),
            sym_index: BTreeMap::new(),
            mode: None,
            personality: None,
            eh_pointers: EhPointers::Sdata4,
        }
    }

    /// Sets the pointer encoding of `.eh_frame` (not PE). The default is [`EhPointers::Sdata4`].
    pub fn set_eh_pointers(&mut self, p: EhPointers) {
        self.eh_pointers = p;
    }

    /// Sets the header's CGU hash ([`super::cgu_hash`]; 0 by default).
    pub fn set_cgu_hash(&mut self, h: u64) {
        self.cgu_hash = h;
    }

    /// The 32-bit crate hash the registry uses.
    pub fn crate_hash(&self) -> u32 {
        crate_hash(self.stable_crate_id)
    }

    /// Interns a symbol slot and returns its index. Slots are keyed by name and flags, so
    /// one symbol used both directly (e.g. as an island) and indirectly (PE `__imp_`, e.g.
    /// by `call.ext.ind`) gets two slots. A leading `\x01` (as in bindgen's
    /// `#[link_name = "\u{1}_ZN..."]` for C++ methods) means "this name verbatim" to LLVM:
    /// it is kept, for the object writer, which drops it and doesn't mangle the rest (Mach-O's
    /// `_`).
    pub fn symbol(&mut self, name: &str, flags: u8) -> Sym {
        let key = (String::from(name), flags);
        if let Some(&i) = self.sym_index.get(&key) {
            return Sym(i);
        }
        let i = self.symbols.len() as u32;
        self.symbols.push(SymbolDef { name: name.into(), flags });
        self.sym_index.insert(key, i);
        Sym(i)
    }

    /// Adds a constant pool allocation; `relocs` offsets are relative to it.
    pub fn add_const(&mut self, bytes: &[u8], align: u32, relocs: &[AllocReloc]) -> Const {
        let off = add_alloc(&mut self.consts, &mut self.const_align, bytes, align);
        self.const_relocs.extend(relocs.iter().map(|r| AllocReloc { offset: off + r.offset, ..*r }));
        Const(off)
    }

    /// Adds a fixup-area allocation (PE: constants pointing at DLL-imported data). Offsets
    /// are relative to it.
    pub fn add_data(&mut self, bytes: &[u8], align: u32, relocs: &[AllocReloc], fixups: &[AllocFixup]) -> Data {
        let off = add_alloc(&mut self.data, &mut self.data_align, bytes, align);
        self.data_relocs.extend(relocs.iter().map(|r| AllocReloc { offset: off + r.offset, ..*r }));
        self.fixups.extend(fixups.iter().map(|x| AllocFixup { offset: off + x.offset, ..*x }));
        Data(off)
    }

    /// Adds the next function and returns its index.
    pub fn add_function(&mut self, f: FunctionDef) -> Func {
        self.functions.push(f);
        Func(self.functions.len() as u32 - 1)
    }

    /// The functions added so far.
    pub fn functions(&self) -> &[FunctionDef] {
        &self.functions
    }

    /// Validates everything, encodes the functions in `mode` and lays out the image.
    pub fn finish(mut self, mode: Mode) -> Result<ImageObject, WriteError> {
        self.prepare(mode);
        self.validate_functions()?;
        let enc = self
            .functions
            .iter()
            .enumerate()
            .map(|(i, f)| asm::encode(&f.code, f.frame_size, &f.cleanup, &[], mode).map_err(|error| WriteError::Encode { func: i as u32, error }))
            .collect::<Result<Vec<_>, _>>()?;
        self.finish_encoded(enc)
    }

    /// Validates every function's instruction words and cleanup entries (also done by
    /// [`finish_encoded`](Self::finish_encoded)), so that only valid code gets encoded.
    pub fn validate_functions(&mut self) -> Result<(), WriteError> {
        let lim = self.limits();
        for (i, f) in self.functions.iter_mut().enumerate() {
            check_function(i as u32, f, &lim, &self.symbols)?;
        }
        Ok(())
    }

    fn limits(&self) -> CodeLimits {
        CodeLimits {
            functions: self.functions.len() as u32,
            symbols: self.symbols.len() as u32,
            consts: self.consts.len() as u32,
            data: self.data.len() as u32,
        }
    }

    /// Adds what the unwind information of `mode`'s format refers to (the slot of
    /// `rust_eh_personality` on ELF). Call before [`finish_encoded`](Self::finish_encoded).
    pub fn prepare(&mut self, mode: Mode) {
        self.mode = Some(mode);
        if !mode.pe {
            self.personality = Some(self.symbol(PERSONALITY, 0));
        }
    }

    /// Lays out the image with the functions' machine code already built (`encoded[i]` of
    /// function `i`, from [`asm::Asm`] or [`asm::encode`]), after [`prepare`](Self::prepare).
    /// Instruction words, if any, aren't looked at: [`finish`](Self::finish) validates them.
    pub fn finish_encoded(mut self, encoded: Vec<Encoded>) -> Result<ImageObject, WriteError> {
        assert_eq!(encoded.len(), self.functions.len());
        let mode = self.mode.expect("prepare before finish_encoded");
        let mut text = self.layout_text(&encoded)?;
        let data = self.layout_data(mode, text.funcs.len())?;
        let (ro, header) = self.layout_ro(mode, &text, &data)?;
        let mut relocs = self.relocs(mode, &header, &mut text, &data)?;
        let unwind = if mode.pe {
            assert!(mode.frame_pointer, "PE unwind info needs the frame pointer");
            unwind_pe(&text.func_code, mode, &mut relocs)
        } else {
            let slot = header.symbols.off as u64 + 8 * self.personality.expect("prepare").0 as u64;
            unwind_elf(&text.func_code, slot, mode, self.eh_pointers, &mut relocs)
        };

        Ok(ImageObject {
            rodata: ro,
            rodata_align: (self.const_align as u64).max(16),
            data: data.data,
            data_align: data.align as u64,
            text: text.text,
            functions: text.func_code,
            unwind,
            symbols: self.symbols,
            relocs,
        })
    }

    /// The text, the function table and what goes with each function's code (its constants,
    /// cleanup list and call sites).
    fn layout_text(&mut self, encoded: &[Encoded]) -> Result<TextLayout, WriteError> {
        let mut t = TextLayout {
            text: Vec::new(),
            code_consts: Vec::new(),
            lists: Vec::new(),
            call_sites: Vec::new(),
            funcs: Vec::with_capacity(self.functions.len()),
            func_code: Vec::with_capacity(self.functions.len()),
            code_refs: Vec::new(),
        };
        for (i, (f, e)) in self.functions.iter_mut().zip(encoded).enumerate() {
            while t.text.len() % 16 != 0 {
                t.text.push(0xcc);
            }
            let start = to_u32(t.text.len())?;
            while t.code_consts.len() % 16 != 0 {
                t.code_consts.push(0);
            }
            let ro_base = t.code_consts.len() as u32;
            t.code_consts.extend_from_slice(&e.rodata);
            t.text.extend_from_slice(&e.code);
            for r in &e.relocs {
                t.code_refs.push(CodeRef { at: start + r.at, to: r.to, start, ro_base, func: i as u32 });
            }
            let list = e.list().write();
            t.lists.extend_from_slice(&list);
            t.call_sites.extend(e.call_sites.iter().map(CallSiteEntry::from));
            t.funcs.push(FuncEntry {
                code_off: start,
                code_len: to_u32(e.code.len())?,
                arg_size: f.arg_size,
                ret_size: f.ret_size,
                ret_kind: f.ret_kind,
                list: Span::new(t.lists.len() - list.len(), list.len())?,
                call_sites: Span::new(t.call_sites.len() - e.call_sites.len(), e.call_sites.len())?,
            });
            t.func_code.push(FuncCode {
                name: core::mem::take(&mut f.name),
                symbol: f.symbol,
                start,
                len: e.code.len() as u32,
                frame_size: f.frame_size,
                call_sites: e.call_sites.clone(),
                prologue: e.prologue,
                entry_stub: e.entry_stub,
                region: e.region,
            });
        }
        Ok(t)
    }

    /// The writable section: the fixup area, then the JIT records (past the
    /// fixup area's one-past-the-end address, which `addr.const` may take); and the checked
    /// fixups.
    fn layout_data(&self, mode: Mode, nfuncs: usize) -> Result<DataLayout, WriteError> {
        let align = self.data_align.max(if mode.counters { 64 } else { 8 }) as usize;
        let mut data = self.data.clone();
        let jit_records = if mode.counters {
            let off = align_to(data.len() + 1, 64);
            data.resize(off, 0);
            for i in 0..nfuncs as u32 {
                data.extend_from_slice(&JitRecord::image_bytes(i));
            }
            Span::new(off, nfuncs)?
        } else {
            Span::default()
        };
        let fixup_offsets: alloc::collections::BTreeSet<u32> = self.fixups.iter().map(|x| x.offset).collect();
        if fixup_offsets.len() != self.fixups.len() || self.data_relocs.iter().any(|r| fixup_offsets.contains(&r.offset)) {
            return Err(WriteError::AllocReloc);
        }
        let nsyms = self.symbols.len() as u32;
        let mut fixups = Vec::with_capacity(self.fixups.len());
        for x in &self.fixups {
            if x.sym.0 >= nsyms
                || self.symbols[x.sym.0 as usize].flags & SYM_INDIRECT == 0
                || x.offset % 8 != 0
                || x.offset as usize + 8 > self.data.len()
            {
                return Err(WriteError::AllocReloc);
            }
            fixups.push(FixupEntry { offset: x.offset, sym: x.sym.0, addend: x.addend });
        }
        Ok(DataLayout { data, align, jit_records, fixups })
    }

    /// The read-only section, starting with its header.
    fn layout_ro(&self, mode: Mode, t: &TextLayout, d: &DataLayout) -> Result<(Vec<u8>, Header), WriteError> {
        let mut off = mem::size_of::<Header>();
        let mut span = |count: usize, size: usize, align: usize| -> Result<Span, WriteError> {
            off = align_to(off, align);
            let s = Span::new(off, count)?;
            off += count * size;
            Ok(s)
        };
        let functions = span(t.funcs.len(), mem::size_of::<FuncEntry>(), 4)?;
        let code_consts = span(t.code_consts.len(), 1, 16)?;
        let fixups = span(d.fixups.len(), mem::size_of::<FixupEntry>(), 8)?;
        let sym_flags = span(self.symbols.len(), 1, 1)?;
        let func_flags = span(t.funcs.len(), 1, 1)?;
        let symbols = span(self.symbols.len(), 8, 8)?;
        let consts = span(self.consts.len(), 1, self.const_align as usize)?;
        let call_sites = span(t.call_sites.len(), mem::size_of::<CallSiteEntry>(), 4)?;
        let lists = span(t.lists.len(), 1, 1)?;
        let mut const_reloc_offs: Vec<u32> = self.const_relocs.iter().map(|r| r.offset).collect();
        const_reloc_offs.sort_unstable();
        if const_reloc_offs.windows(2).any(|w| w[1] < w[0] + 8) {
            return Err(WriteError::AllocReloc);
        }
        let const_relocs = span(const_reloc_offs.len(), 4, 4)?;
        let size = off;

        let header = Header {
            magic: MAGIC,
            crate_hash: crate_hash(self.stable_crate_id),
            stable_crate_id: self.stable_crate_id,
            data: 0,
            size: to_u32(size)?,
            data_size: to_u32(d.data.len())?,
            functions,
            text: 0,
            text_size: to_u32(t.text.len())?,
            code_consts,
            fixups,
            sym_flags,
            func_flags,
            symbols,
            consts,
            lists,
            call_sites,
            mode: mode.to_header_bits(),
            pad: 0,
            jit_records: d.jit_records,
            const_relocs,
            cgu_hash: self.cgu_hash,
            abi: crate::ABI,
            anchor: 0,
        };

        let mut ro = vec![0u8; size];
        let flags: Vec<u8> = self.symbols.iter().map(|s| s.flags).collect();
        let fflags: Vec<u8> = self.functions.iter().map(|f| f.flags).collect();
        // SAFETY: all of these are padding-free plain-data types.
        unsafe {
            put(&mut ro, 0, slice::from_ref(&header));
            put(&mut ro, functions.off, &t.funcs);
            put(&mut ro, code_consts.off, &t.code_consts);
            put(&mut ro, fixups.off, &d.fixups);
            put(&mut ro, sym_flags.off, &flags);
            put(&mut ro, func_flags.off, &fflags);
            put(&mut ro, consts.off, &self.consts);
            put(&mut ro, call_sites.off, &t.call_sites);
            put(&mut ro, lists.off, &t.lists);
            put(&mut ro, const_relocs.off, &const_reloc_offs);
        }
        Ok((ro, header))
    }

    /// The relocations of the header and symbol slots, the JIT records, the code (patching
    /// calls between functions into `t.text`) and the allocations.
    fn relocs(&self, mode: Mode, h: &Header, t: &mut TextLayout, d: &DataLayout) -> Result<Vec<Reloc>, WriteError> {
        let mut relocs = Vec::new();
        let abs = |section, offset, target| Reloc { section, offset, target, addend: 0, kind: RelocKind::Abs64 };
        relocs.push(abs(Section::ReadOnly, mem::offset_of!(Header, data) as u64, RelocTarget::Section(Section::Writable)));
        relocs.push(abs(Section::ReadOnly, mem::offset_of!(Header, text) as u64, RelocTarget::Section(Section::Text)));
        for i in 0..self.symbols.len() as u32 {
            relocs.push(abs(Section::ReadOnly, h.symbols.off as u64 + i as u64 * 8, RelocTarget::Symbol(Sym(i))));
        }
        for i in 0..d.jit_records.count as u64 {
            let rec = d.jit_records.off as u64 + 64 * i;
            for (field, target) in JIT_RECORD_RELOCS {
                relocs.push(abs(Section::Writable, rec + field as u64, target));
            }
        }
        for r in &t.code_refs {
            if let Some(reloc) = self.code_ref_reloc(mode, h, d, &t.funcs, &mut t.text, r)? {
                relocs.push(reloc);
            }
        }
        for r in &self.const_relocs {
            relocs.push(self.alloc_reloc(h, r, Section::ReadOnly, h.consts.off as usize, self.consts.len())?);
        }
        for r in &self.data_relocs {
            relocs.push(self.alloc_reloc(h, r, Section::Writable, 0, self.data.len())?);
        }
        Ok(relocs)
    }

    /// The relocation of a code field, or `None` for a call between functions, resolved here
    /// in `text`.
    fn code_ref_reloc(
        &self,
        mode: Mode,
        h: &Header,
        d: &DataLayout,
        funcs: &[FuncEntry],
        text: &mut [u8],
        r: &CodeRef,
    ) -> Result<Option<Reloc>, WriteError> {
        let &CodeRef { at, to, start, ro_base, func } = r;
        let pc = |target, off: u64| Reloc {
            section: Section::Text,
            offset: at as u64,
            target: RelocTarget::Section(target),
            addend: off as i64 - 4,
            kind: RelocKind::Pc32,
        };
        let call = |target| Reloc { section: Section::Text, offset: at as u64, target, addend: -4, kind: RelocKind::Call32 };
        let bad = |what| WriteError::Code { func, offset: at - start, error: what };
        Ok(Some(match to {
            Ref::Handler(op) => call(RelocTarget::Handler(op)),
            Ref::Probe => call(RelocTarget::Probe),
            Ref::Func(Func(f)) => {
                let f = funcs.get(f as usize).ok_or(bad(CodeError::FuncOutOfRange))?;
                let disp = f.code_off.wrapping_sub(at + 4);
                text[at as usize..at as usize + 4].copy_from_slice(&disp.to_le_bytes());
                return Ok(None);
            }
            Ref::Sym(Sym(s)) if (s as usize) < self.symbols.len() => pc(Section::ReadOnly, h.symbols.off as u64 + 8 * s as u64),
            Ref::Const(Const(k)) if (k as usize) <= self.consts.len() => pc(Section::ReadOnly, h.consts.off as u64 + k as u64),
            Ref::Data(Data(x)) if (x as usize) <= self.data.len() => pc(Section::Writable, x as u64),
            Ref::Ro(o) => pc(Section::ReadOnly, (h.code_consts.off + ro_base + o) as u64),
            Ref::Rec | Ref::RecLoopCtr if mode.counters => {
                let rec = d.jit_records.off as u64 + 64 * func as u64;
                pc(Section::Writable, if to == Ref::RecLoopCtr { rec + JIT_LOOP_CTR as u64 } else { rec })
            }
            Ref::Rec | Ref::RecLoopCtr => return Err(bad(CodeError::NoJitRecord)),
            Ref::RegHandler(_) => return Err(bad(CodeError::JitOnly)),
            Ref::Sym(_) => return Err(bad(CodeError::SymOutOfRange)),
            Ref::Const(_) => return Err(bad(CodeError::ConstOutOfRange)),
            Ref::Data(_) => return Err(bad(CodeError::DataOutOfRange)),
        }))
    }

    /// The relocation of a pointer at `r.offset` in an allocation of `len` bytes placed at
    /// `base` in `section`.
    fn alloc_reloc(&self, h: &Header, r: &AllocReloc, section: Section, base: usize, len: usize) -> Result<Reloc, WriteError> {
        if r.offset as usize + 8 > len || (base + r.offset as usize) % 8 != 0 {
            return Err(WriteError::AllocReloc);
        }
        let (target, addend) = match r.target {
            // A pointer to an indirect symbol's target is only known at registration: it
            // must be a fixup. So relocations against indirect symbols are all slots'.
            AllocTarget::Symbol(s) if (s.0 as usize) < self.symbols.len() && self.symbols[s.0 as usize].flags & SYM_INDIRECT == 0 => {
                (RelocTarget::Symbol(s), r.addend)
            }
            AllocTarget::Const(k) if (k.0 as usize) <= self.consts.len() => {
                (RelocTarget::Section(Section::ReadOnly), h.consts.off as i64 + k.0 as i64 + r.addend)
            }
            AllocTarget::Data(x) if (x.0 as usize) <= self.data.len() => (RelocTarget::Section(Section::Writable), x.0 as i64 + r.addend),
            _ => return Err(WriteError::AllocReloc),
        };
        Ok(Reloc { section, offset: (base + r.offset as usize) as u64, target, addend, kind: RelocKind::Abs64 })
    }
}

/// [`ImageWriter::layout_text`]'s result: the text and the read-only data that goes with it.
struct TextLayout {
    text: Vec<u8>,
    code_consts: Vec<u8>,
    lists: Vec<u8>,
    call_sites: Vec<CallSiteEntry>,
    funcs: Vec<FuncEntry>,
    func_code: Vec<FuncCode>,
    /// Resolved once the layout is known.
    code_refs: Vec<CodeRef>,
}

/// [`ImageWriter::layout_data`]'s result.
struct DataLayout {
    /// The writable section.
    data: Vec<u8>,
    align: usize,
    jit_records: Span,
    fixups: Vec<FixupEntry>,
}

fn to_u32(v: usize) -> Result<u32, WriteError> {
    v.try_into().map_err(|_| WriteError::TooLarge)
}

impl Span {
    fn new(off: usize, count: usize) -> Result<Span, WriteError> {
        Ok(Span { off: to_u32(off)?, count: to_u32(count)? })
    }
}

impl From<&CallSite> for CallSiteEntry {
    fn from(c: &CallSite) -> CallSiteEntry {
        CallSiteEntry { start: c.start, len: c.len, pad: Cleanup::new(c.pad, c.catch).to_word() }
    }
}

impl From<&CallSiteEntry> for CallSite {
    fn from(c: &CallSiteEntry) -> CallSite {
        let (pad, catch) = match c.action() {
            Cleanup::Pad(p, catch) => (Some(p), catch),
            Cleanup::Continue => (None, false),
        };
        CallSite { start: c.start, len: c.len, pad, catch }
    }
}

/// Copies plain-data values into `buf` at byte offset `off`.
///
/// # Safety
/// `T` must have no padding bytes (every byte of a `T` is initialized).
unsafe fn put<T: Copy>(buf: &mut [u8], off: u32, v: &[T]) {
    // SAFETY: per the caller, all bytes of `v` are initialized.
    let bytes = unsafe { slice::from_raw_parts(v.as_ptr().cast::<u8>(), mem::size_of_val(v)) };
    buf[off as usize..off as usize + bytes.len()].copy_from_slice(bytes);
}

/// `.eh_frame` and `.gcc_except_table`: one CIE naming `rust_eh_personality` (through the
/// symbol slot at `personality_slot` of the read-only section, `DW_EH_PE_indirect`), then per
/// function an FDE with the rules of [`eh_fde_rules`] and its LSDA ([`asm::lsda`]).
fn unwind_elf(funcs: &[FuncCode], personality_slot: u64, mode: Mode, ptrs: EhPointers, relocs: &mut Vec<Reloc>) -> Vec<(Section, Vec<u8>)> {
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
fn unwind_pe(funcs: &[FuncCode], mode: Mode, relocs: &mut Vec<Reloc>) -> Vec<(Section, Vec<u8>)> {
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
