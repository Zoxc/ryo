//! The image writer (backend side, needs `alloc`).
//!
//! [`ImageWriter`] collects functions, constants, symbols and sites, and
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
//! RIP-relative addresses of symbol slots, sites, constants, the data area and code
//! constants, and calls of the handlers and `ryo_probe_stack`. Calls between functions are
//! resolved by the writer.

use alloc::collections::BTreeMap;
use alloc::string::String;
use alloc::vec;
use alloc::vec::Vec;
use core::{mem, slice};

use super::*;
use crate::asm::{self, CallSite, Encoded, Mode, Ref};
use crate::full::{ABS_DATA, Const, Data, DecodeError, Decoder, ElemKind, Func, OperandKind, Opcode, Site, Sym};

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
    /// See [`FuncEntry::frame_size`].
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
    SiteOutOfRange,
    ConstOutOfRange,
    DataOutOfRange,
    /// The last instruction can fall through past the function's end.
    FallsOffEnd,
    /// A call or `ret` passes its return value in a way the machine code can't, or an `arg`
    /// names an invalid register ([`crate::asm::return_ok`]).
    BadReturn,
    /// An `arg` after an instruction that isn't one.
    ArgNotFirst,
}

/// Why [`ImageWriter::finish`] failed.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum WriteError {
    /// Instruction at word `offset` of function `func`.
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
    pub sites: u32,
    /// Constant pool size in bytes.
    pub consts: u32,
    /// Fixup area size in bytes.
    pub data: u32,
}

fn op_falls_through(op: Opcode) -> bool {
    !matches!(
        op,
        Opcode::Jmp
            | Opcode::Unreachable
            | Opcode::Abort
            | Opcode::Ret
            | Opcode::Resume
            | Opcode::TailCall
            | Opcode::TailCallPtr
    ) && !op.mnemonic().starts_with("switch.")
}

/// Whether `op` calls code that may unwind, so it can have a cleanup entry.
pub fn op_may_unwind(op: Opcode) -> bool {
    matches!(
        op,
        Opcode::Call | Opcode::CallSym | Opcode::CallSymInd | Opcode::CallPtr | Opcode::Island
            | Opcode::Resume
    )
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
        let mut pos = 1usize;
        for o in insn.opcode().info().operands {
            let w = |i: usize| words[pos + i];
            match o.kind {
                OperandKind::Target if !target_ok(at, w(0) as i32) => return fail(CodeError::BadTarget),
                OperandKind::Func if w(0) >= lim.functions => return fail(CodeError::FuncOutOfRange),
                OperandKind::Sym if w(0) >= lim.symbols => return fail(CodeError::SymOutOfRange),
                OperandKind::Site if w(0) >= lim.sites => return fail(CodeError::SiteOutOfRange),
                OperandKind::Const if w(0) > lim.consts => return fail(CodeError::ConstOutOfRange),
                OperandKind::Abs if w(0) & ABS_DATA == 0 && w(0) > lim.consts => return fail(CodeError::ConstOutOfRange),
                OperandKind::Abs if w(0) & ABS_DATA != 0 && w(0) & !ABS_DATA > lim.data => {
                    return fail(CodeError::DataOutOfRange);
                }
                OperandKind::List(e) => {
                    let n = w(0) as usize;
                    let ew = e.words();
                    for i in 0..n {
                        let t = match e {
                            ElemKind::Target => Some(w(1 + i)),
                            ElemKind::Word => None,
                            _ => Some(w(1 + i * ew + ew - 1)),
                        };
                        if let Some(t) = t
                            && !target_ok(at, t as i32)
                        {
                            return fail(CodeError::BadTarget);
                        }
                    }
                    pos += 1 + n * ew;
                    continue;
                }
                _ => {}
            }
            pos += o.kind.words().unwrap();
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
        let mut pos = 1usize;
        for o in op.info().operands {
            match o.kind {
                OperandKind::Sym => {
                    let indirect = symbols[code[at + pos] as usize].flags & SYM_INDIRECT != 0;
                    let loads_through = matches!(op, Opcode::AddrSymInd | Opcode::CallSymInd) && o.name == "sym";
                    if indirect != loads_through {
                        return Err((at as u32, CodeError::SymIndirection));
                    }
                }
                OperandKind::List(e) => {
                    pos += 1 + code[at + pos] as usize * e.words();
                    continue;
                }
                _ => {}
            }
            pos += o.kind.words().unwrap();
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
        let op_at =
            |o: u32| (starts.get(o as usize) == Some(&true)).then(|| Opcode::from_u16(f.code[o as usize] as u16)).flatten();
        let call = op_at(e.offset).is_some_and(op_may_unwind);
        let pad = e.target == CONTINUE || op_at(e.target & !CATCH) == Some(Opcode::Lpad);
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
    sites: u32,
    /// The code's mode, from `prepare`.
    mode: Option<Mode>,
    /// The slot of `rust_eh_personality` (ELF).
    personality: Option<Sym>,
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
            sites: 0,
            mode: None,
            personality: None,
        }
    }

    /// The 32-bit crate hash the registry uses.
    pub fn crate_hash(&self) -> u32 {
        crate_hash(self.stable_crate_id)
    }

    /// Interns a symbol slot and returns its index. Slots are keyed by name and flags, so
    /// one symbol used both directly (e.g. as an island) and indirectly (PE `__imp_`, e.g.
    /// by `call.ext.ind`) gets two slots. A leading `\x01` (as in bindgen's
    /// `#[link_name = "\u{1}_ZN..."]` for C++ methods) means "this name verbatim" to LLVM,
    /// which drops it; so does this.
    pub fn symbol(&mut self, name: &str, flags: u8) -> Sym {
        let name = name.strip_prefix('\x01').unwrap_or(name);
        let key = (String::from(name), flags);
        if let Some(&i) = self.sym_index.get(&key) {
            return Sym(i);
        }
        let i = self.symbols.len() as u32;
        self.symbols.push(SymbolDef { name: name.into(), flags });
        self.sym_index.insert(key, i);
        Sym(i)
    }

    /// Allocates a slot in the image's site area (no instruction uses one any more).
    pub fn site(&mut self) -> Site {
        self.sites += 1;
        Site(self.sites - 1)
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
            .map(|(i, f)| asm::encode(&f.code, f.frame_size, &f.cleanup, mode).map_err(|error| WriteError::Encode { func: i as u32, error }))
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
            sites: self.sites,
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
        let pe = mode.pe;
        let nsyms = self.symbols.len() as u32;

        // Function table and text.
        let mut funcs = Vec::with_capacity(self.functions.len());
        let mut text: Vec<u8> = Vec::new();
        let mut code_consts: Vec<u8> = Vec::new();
        let mut func_code = Vec::with_capacity(self.functions.len());
        // (text offset of the field, target): resolved once the layout is known.
        let mut code_refs: Vec<(u32, Ref, u32)> = Vec::new();
        for (i, f) in self.functions.iter_mut().enumerate() {
            let i = i as u32;
            let too_large = |_| WriteError::TooLarge;
            let e = &encoded[i as usize];
            while text.len() % 16 != 0 {
                text.push(0xcc);
            }
            let start: u32 = text.len().try_into().map_err(too_large)?;
            while code_consts.len() % 16 != 0 {
                code_consts.push(0);
            }
            let ro_base = code_consts.len() as u32;
            code_consts.extend_from_slice(&e.rodata);
            text.extend_from_slice(&e.code);
            for r in &e.relocs {
                code_refs.push((start + r.at, r.to, ro_base));
            }
            funcs.push(FuncEntry {
                code_off: start,
                code_len: e.code.len().try_into().map_err(too_large)?,
                arg_size: f.arg_size,
                ret_size: f.ret_size,
                ret_kind: f.ret_kind,
            });
            func_code.push(FuncCode {
                name: core::mem::take(&mut f.name),
                symbol: f.symbol,
                start,
                len: e.code.len() as u32,
                frame_size: f.frame_size,
                call_sites: e.call_sites.clone(),
            });
        }

        // Writable section: site cache, then the fixup area.
        let data_align = self.data_align.max(8) as usize;
        let fixup_area = align_to(self.sites as usize * 8, data_align);
        let mut data = vec![0u8; fixup_area];
        data.extend_from_slice(&self.data);
        let fixup_offsets: alloc::collections::BTreeSet<u32> = self.fixups.iter().map(|x| x.offset).collect();
        if fixup_offsets.len() != self.fixups.len()
            || self.data_relocs.iter().any(|r| fixup_offsets.contains(&r.offset))
        {
            return Err(WriteError::AllocReloc);
        }
        let mut fixups = Vec::with_capacity(self.fixups.len());
        for x in &self.fixups {
            if x.sym.0 >= nsyms
                || self.symbols[x.sym.0 as usize].flags & SYM_INDIRECT == 0
                || (fixup_area + x.offset as usize) % 8 != 0
                || x.offset as usize + 8 > self.data.len()
            {
                return Err(WriteError::AllocReloc);
            }
            fixups.push(FixupEntry { offset: (fixup_area + x.offset as usize) as u32, sym: x.sym.0, addend: x.addend });
        }

        // Read-only layout.
        let mut off = mem::size_of::<Header>();
        let mut span = |count: usize, size: usize, align: usize| -> Result<Span, WriteError> {
            off = align_to(off, align);
            let s = Span { off: off.try_into().map_err(|_| WriteError::TooLarge)?, count: count.try_into().map_err(|_| WriteError::TooLarge)? };
            off += count * size;
            Ok(s)
        };
        let functions = span(funcs.len(), mem::size_of::<FuncEntry>(), 4)?;
        let consts_code = span(code_consts.len(), 1, 16)?;
        let fixups_span = span(fixups.len(), mem::size_of::<FixupEntry>(), 8)?;
        let sym_flags = span(self.symbols.len(), 1, 1)?;
        let symbols = span(self.symbols.len(), 8, 8)?;
        let consts = span(self.consts.len(), 1, self.const_align as usize)?;
        let size = off;

        let header = Header {
            magic: MAGIC,
            version: crate::FORMAT_VERSION,
            crate_hash: crate_hash(self.stable_crate_id),
            stable_crate_id: self.stable_crate_id,
            data: 0,
            size: size.try_into().map_err(|_| WriteError::TooLarge)?,
            data_size: data.len().try_into().map_err(|_| WriteError::TooLarge)?,
            functions,
            text: 0,
            text_size: text.len().try_into().map_err(|_| WriteError::TooLarge)?,
            code_consts: consts_code,
            fixups: fixups_span,
            sym_flags,
            symbols,
            consts,
            site_count: self.sites,
            fixup_area: fixup_area as u32,
            reserved: 0,
        };

        let mut ro = vec![0u8; size];
        let flags: Vec<u8> = self.symbols.iter().map(|s| s.flags).collect();
        // SAFETY: all of these are padding-free plain-data types.
        unsafe {
            put(&mut ro, 0, slice::from_ref(&header));
            put(&mut ro, functions.off, &funcs);
            put(&mut ro, consts_code.off, &code_consts);
            put(&mut ro, fixups_span.off, &fixups);
            put(&mut ro, sym_flags.off, &flags);
            put(&mut ro, consts.off, &self.consts);
        }

        // Relocations.
        let mut relocs = Vec::new();
        let abs = |section, offset, target, addend| Reloc { section, offset, target, addend, kind: RelocKind::Abs64 };
        relocs.push(abs(Section::ReadOnly, mem::offset_of!(Header, data) as u64, RelocTarget::Section(Section::Writable), 0));
        relocs.push(abs(Section::ReadOnly, mem::offset_of!(Header, text) as u64, RelocTarget::Section(Section::Text), 0));
        for i in 0..nsyms {
            relocs.push(abs(Section::ReadOnly, symbols.off as u64 + i as u64 * 8, RelocTarget::Symbol(Sym(i)), 0));
        }
        // The code's fields. Calls between functions are resolved here.
        for &(at, to, ro_base) in &code_refs {
            let pc = |target, off: u64| Reloc {
                section: Section::Text,
                offset: at as u64,
                target: RelocTarget::Section(target),
                addend: off as i64 - 4,
                kind: RelocKind::Pc32,
            };
            let call = |target| Reloc { section: Section::Text, offset: at as u64, target, addend: -4, kind: RelocKind::Call32 };
            let bad = |what| WriteError::Code { func: u32::MAX, offset: at, error: what };
            relocs.push(match to {
                Ref::Handler(op) => call(RelocTarget::Handler(op)),
                Ref::Probe => call(RelocTarget::Probe),
                Ref::Func(Func(f)) => {
                    let f = funcs.get(f as usize).ok_or(bad(CodeError::FuncOutOfRange))?;
                    let d = f.code_off.wrapping_sub(at + 4);
                    text[at as usize..at as usize + 4].copy_from_slice(&d.to_le_bytes());
                    continue;
                }
                Ref::Sym(Sym(s)) if s < nsyms => pc(Section::ReadOnly, symbols.off as u64 + 8 * s as u64),
                Ref::Site(Site(s)) if s < self.sites => pc(Section::Writable, 8 * s as u64),
                Ref::Const(Const(k)) if (k as usize) <= self.consts.len() => pc(Section::ReadOnly, consts.off as u64 + k as u64),
                Ref::Data(Data(d)) if (d as usize) <= self.data.len() => pc(Section::Writable, (fixup_area + d as usize) as u64),
                Ref::Ro(o) => pc(Section::ReadOnly, (consts_code.off + ro_base + o) as u64),
                Ref::Sym(_) => return Err(bad(CodeError::SymOutOfRange)),
                Ref::Site(_) => return Err(bad(CodeError::SiteOutOfRange)),
                Ref::Const(_) => return Err(bad(CodeError::ConstOutOfRange)),
                Ref::Data(_) => return Err(bad(CodeError::DataOutOfRange)),
            });
        }
        let map = |r: &AllocReloc, section: Section, base: usize, len: usize| -> Result<Reloc, WriteError> {
            if r.offset as usize + 8 > len || (base + r.offset as usize) % 8 != 0 {
                return Err(WriteError::AllocReloc);
            }
            let (target, addend) = match r.target {
                // A pointer to an indirect symbol's target is only known at registration: it
                // must be a fixup. So relocations against indirect symbols are all slots'.
                AllocTarget::Symbol(s) if s.0 < nsyms && self.symbols[s.0 as usize].flags & SYM_INDIRECT == 0 => {
                    (RelocTarget::Symbol(s), r.addend)
                }
                AllocTarget::Const(k) if (k.0 as usize) <= self.consts.len() => {
                    (RelocTarget::Section(Section::ReadOnly), consts.off as i64 + k.0 as i64 + r.addend)
                }
                AllocTarget::Data(d) if (d.0 as usize) <= self.data.len() => {
                    (RelocTarget::Section(Section::Writable), fixup_area as i64 + d.0 as i64 + r.addend)
                }
                _ => return Err(WriteError::AllocReloc),
            };
            Ok(Reloc { section, offset: (base + r.offset as usize) as u64, target, addend, kind: RelocKind::Abs64 })
        };
        for r in &self.const_relocs {
            relocs.push(map(r, Section::ReadOnly, consts.off as usize, self.consts.len())?);
        }
        for r in &self.data_relocs {
            relocs.push(map(r, Section::Writable, fixup_area, self.data.len())?);
        }
        let unwind = if pe {
            assert!(mode.frame_pointer, "PE unwind info needs the frame pointer");
            unwind_pe(&func_code, &mut relocs)
        } else {
            let slot = symbols.off as u64 + 8 * self.personality.expect("prepare").0 as u64;
            unwind_elf(&func_code, slot, mode, &mut relocs)
        };

        Ok(ImageObject {
            rodata: ro,
            rodata_align: (self.const_align as u64).max(16),
            data,
            data_align: data_align as u64,
            text,
            functions: func_code,
            unwind,
            symbols: self.symbols,
            relocs,
        })
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
/// function an FDE for its prologue and its LSDA ([`asm::lsda`]). With a frame pointer, every
/// function has the same rules (`push rbp; mov rbp, rsp`, after which the CFA is `rbp + 16`);
/// without, the CFA is `rsp + F + 16` after the prologue's `sub rsp, F + 8`. Epilogues have
/// no rules: they make no calls, so only asynchronous unwinding could stop there.
fn unwind_elf(funcs: &[FuncCode], personality_slot: u64, mode: Mode, relocs: &mut Vec<Reloc>) -> Vec<(Section, Vec<u8>)> {
    const PCREL_SDATA4: u8 = 0x1b;
    let pc = |section, offset, target, addend| Reloc { section, offset, target: RelocTarget::Section(target), addend, kind: RelocKind::Pc32 };
    let mut eh = Vec::new();
    // CIE.
    let mut cie = vec![0, 0, 0, 0, 1];
    cie.extend_from_slice(b"zPLR\0");
    cie.extend_from_slice(&[1, 0x78, 16]); // code align 1, data align -8, return address r16
    cie.extend_from_slice(&[7, 0x80 | PCREL_SDATA4]); // augmentation length, P encoding (indirect)
    relocs.push(pc(Section::EhFrame, 4 + cie.len() as u64, Section::ReadOnly, personality_slot as i64));
    cie.extend_from_slice(&[0; 4]);
    cie.extend_from_slice(&[PCREL_SDATA4, PCREL_SDATA4]); // L, R encodings
    cie.extend_from_slice(&[0x0c, 7, 8, 0x90, 1]); // CFA = rsp + 8; return address at CFA - 8
    while (cie.len() + 4) % 8 != 0 {
        cie.push(0); // DW_CFA_nop
    }
    eh.extend_from_slice(&(cie.len() as u32).to_le_bytes());
    eh.extend_from_slice(&cie);
    let mut lsda = Vec::new();
    for f in funcs {
        let l = lsda.len() as u64;
        lsda.extend_from_slice(&asm::lsda::write(&f.call_sites));
        let at = eh.len() as u64;
        let mut fde = Vec::new();
        fde.extend_from_slice(&((at + 4) as u32).to_le_bytes()); // back to the CIE
        relocs.push(pc(Section::EhFrame, at + 8, Section::Text, f.start as i64));
        fde.extend_from_slice(&[0; 4]);
        fde.extend_from_slice(&f.len.to_le_bytes());
        fde.push(4);
        relocs.push(pc(Section::EhFrame, at + 4 + fde.len() as u64, Section::Lsda, l as i64));
        fde.extend_from_slice(&[0; 4]);
        if mode.frame_pointer {
            // After `push rbp`: CFA = rsp + 16, rbp at CFA - 16; after `mov rbp, rsp`: CFA = rbp + 16.
            fde.extend_from_slice(&[0x41, 0x0e, 16, 0x86, 2, 0x43, 0x0d, 6]);
        } else {
            // After the prologue: CFA = rsp + F + 16 (`DW_CFA_advance_loc`, `DW_CFA_def_cfa_offset`).
            let len = asm::prologue_len(f.frame_size, mode);
            debug_assert!(len < 64);
            fde.extend_from_slice(&[0x40 | len as u8, 0x0e]);
            asm::lsda::uleb(&mut fde, f.frame_size + 16);
        }
        while (fde.len() + 4) % 8 != 0 {
            fde.push(0);
        }
        eh.extend_from_slice(&(fde.len() as u32).to_le_bytes());
        eh.extend_from_slice(&fde);
    }
    vec![(Section::EhFrame, eh), (Section::Lsda, lsda)]
}

/// `.pdata` and `.xdata`: per function, its range and unwind info for the shared prologue
/// (`push rbp; push rdi; push rsi; lea rbp, [rsp + 16]; sub rsp, F - 16`, `rbp` the frame
/// register at offset 16 from `rsp`). There is no exception handler: panics unwind through VM
/// frames, but their landing pads don't run.
fn unwind_pe(funcs: &[FuncCode], relocs: &mut Vec<Reloc>) -> Vec<(Section, Vec<u8>)> {
    let rva = |section, offset, target, addend| Reloc { section, offset, target: RelocTarget::Section(target), addend, kind: RelocKind::Rva32 };
    let (mut pdata, mut xdata) = (Vec::new(), Vec::new());
    for f in funcs {
        let x = xdata.len() as i64;
        let p = pdata.len() as u64;
        relocs.push(rva(Section::Pdata, p, Section::Text, f.start as i64));
        relocs.push(rva(Section::Pdata, p + 4, Section::Text, (f.start + f.len) as i64));
        relocs.push(rva(Section::Pdata, p + 8, Section::Xdata, x));
        pdata.extend_from_slice(&[0; 12]);
        // Prologue: push rbp (1), push rdi (1), push rsi (1), lea rbp, [rsp + 16] (5),
        // [mov eax, F - 16 (5); call probe (5)], sub (4 or 7).
        let alloc = f.frame_size - 16;
        let probe = if f.frame_size >= asm::PROBE_FROM { 10 } else { 0 };
        let sub_end = 8 + probe + if alloc == 0 { 0 } else if alloc < 128 { 4 } else { 7 };
        // Unwind codes, last operation first: (offset after it, op | info << 4, extra slots).
        let mut codes: Vec<u8> = Vec::new();
        if alloc != 0 {
            if alloc <= 128 {
                codes.extend_from_slice(&[sub_end as u8, 2 | (((alloc / 8 - 1) as u8) << 4)]);
            } else if alloc <= 512 * 1024 - 8 {
                codes.extend_from_slice(&[sub_end as u8, 1]);
                codes.extend_from_slice(&((alloc / 8) as u16).to_le_bytes());
            } else {
                codes.extend_from_slice(&[sub_end as u8, 1 | 1 << 4]);
                codes.extend_from_slice(&alloc.to_le_bytes());
            }
        }
        codes.extend_from_slice(&[8, 3]); // UWOP_SET_FPREG
        codes.extend_from_slice(&[3, 0 | 6 << 4]); // UWOP_PUSH_NONVOL rsi
        codes.extend_from_slice(&[2, 0 | 7 << 4]); // UWOP_PUSH_NONVOL rdi
        codes.extend_from_slice(&[1, 0 | 5 << 4]); // UWOP_PUSH_NONVOL rbp
        let slots = codes.len() / 2;
        // Version 1; the frame register rbp, at rsp + 1 * 16.
        xdata.extend_from_slice(&[1, sub_end as u8, slots as u8, 5 | 1 << 4]);
        xdata.extend_from_slice(&codes);
        while xdata.len() % 4 != 0 {
            xdata.push(0);
        }
    }
    vec![(Section::Pdata, pdata), (Section::Xdata, xdata)]
}
