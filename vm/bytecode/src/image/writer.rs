//! The image writer (backend side, needs `alloc`).
//!
//! [`ImageWriter`] collects functions, constants, symbols and sites, and
//! [`ImageWriter::finish`] lays out the two sections. The result, [`ImageObject`], is plain
//! bytes plus a relocation list; the backend turns it into an object file (with the `object`
//! crate), defining `__ryo_image_<StableCrateId>` at offset 0 of the read-only section.
//!
//! Every relocation is an absolute 64-bit address (`R_X86_64_64` /
//! `IMAGE_REL_AMD64_ADDR64`), written at `offset` in `section`, of `target + addend`:
//!
//! - the header's `data` field → the writable section
//! - each symbol slot → its symbol. For symbols flagged [`SYM_INDIRECT`], the backend
//!   relocates against `__imp_<name>` instead (design/platforms.md).
//! - pointers inside constant and fixup-area allocations → a symbol, or the read-only or
//!   writable section (intra-image)

use alloc::collections::BTreeMap;
use alloc::string::String;
use alloc::vec;
use alloc::vec::Vec;
use core::{mem, slice};

use super::*;
use crate::insn::{ABS_DATA, Const, Data, DecodeError, Decoder, ElemKind, Func, OperandKind, Opcode, Site, Sym};

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
    /// A native symbol (function, static, portal).
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

/// One function's bytecode and tables.
#[derive(Clone, Debug, Default)]
pub struct FunctionDef {
    pub code: Vec<u32>,
    /// See [`FuncEntry::frame_size`].
    pub frame_size: u32,
    /// See [`FuncEntry::arg_size`].
    pub arg_size: u32,
    /// See [`FuncEntry::ret_size`].
    pub ret_size: u32,
    /// Cleanup entries, in any order (the writer sorts them): one per call-like instruction
    /// that can unwind.
    pub cleanup: Vec<CleanupEntry>,
    pub portal: Option<Sym>,
}

/// Section of an [`ImageObject`].
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Section {
    ReadOnly,
    Writable,
}

/// A relocation target.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RelocTarget {
    /// [`ImageObject::symbols`]`[i]`.
    Symbol(Sym),
    /// The start of a section of this image.
    Section(Section),
}

/// An absolute 64-bit relocation.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Reloc {
    pub section: Section,
    pub offset: u64,
    pub target: RelocTarget,
    pub addend: i64,
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
}

/// Why [`ImageWriter::finish`] failed.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum WriteError {
    /// Instruction at word `offset` of function `func`.
    Code { func: u32, offset: u32, error: CodeError },
    /// A duplicate cleanup entry, one not at a call-like instruction, or one whose landing
    /// pad isn't an `lpad` instruction.
    Cleanup(u32),
    /// Portal symbol out of range or indirect.
    Portal(u32),
    /// Allocation relocation or fixup out of range or misplaced, or a relocation against an
    /// indirect symbol (that must be a fixup).
    AllocReloc,
    /// A section exceeds `u32` offsets.
    TooLarge,
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
            | Opcode::TailCallInd
    ) && !op.mnemonic().starts_with("switch.")
}

/// Whether `op` calls code that may unwind, so it can have a cleanup entry.
pub fn op_may_unwind(op: Opcode) -> bool {
    matches!(
        op,
        Opcode::Call | Opcode::CallExt | Opcode::CallExtInd | Opcode::CallInd | Opcode::TailCallInd | Opcode::Island
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
    for r in Decoder::new(code) {
        let (at, insn) = r.unwrap();
        let words = &code[at..];
        let fail = |e| Err((at as u32, e));
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
                    let loads_through = matches!(op, Opcode::AddrSymInd | Opcode::CallExtInd) && o.name == "sym";
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
}

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
        }
    }

    /// The 32-bit crate hash used in portal IDs.
    pub fn crate_hash(&self) -> u32 {
        crate_hash(self.stable_crate_id)
    }

    /// Interns a symbol slot and returns its index. Slots are keyed by name and flags, so
    /// one symbol used both directly (e.g. as an island) and indirectly (PE `__imp_`, e.g.
    /// by `call.ext.ind`) gets two slots.
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

    /// Allocates a site cache slot for a `call.ext`/`call.ind` site.
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

    /// Validates everything and lays out the image.
    pub fn finish(mut self) -> Result<ImageObject, WriteError> {
        let nsyms = self.symbols.len() as u32;
        let lim = CodeLimits {
            functions: self.functions.len() as u32,
            symbols: nsyms,
            sites: self.sites,
            consts: self.consts.len() as u32,
            data: self.data.len() as u32,
        };

        // Function table, code and cleanup tables.
        let mut funcs = Vec::with_capacity(self.functions.len());
        let mut code: Vec<u32> = Vec::new();
        let mut cleanup: Vec<CleanupEntry> = Vec::new();
        for (i, f) in self.functions.iter_mut().enumerate() {
            let i = i as u32;
            let starts = validate_code(&f.code, &lim)
                .and_then(|s| check_indirection(&f.code, &self.symbols).map(|()| s))
                .map_err(|(offset, error)| WriteError::Code { func: i, offset, error })?;
            f.cleanup.sort();
            for (j, e) in f.cleanup.iter().enumerate() {
                let op_at = |o: u32| {
                    (starts.get(o as usize) == Some(&true)).then(|| Opcode::from_u16(f.code[o as usize] as u16)).flatten()
                };
                let call = op_at(e.offset).is_some_and(op_may_unwind);
                let pad = e.target == CONTINUE || op_at(e.target) == Some(Opcode::Lpad);
                if !call || !pad || (j > 0 && f.cleanup[j - 1].offset == e.offset) {
                    return Err(WriteError::Cleanup(i));
                }
            }
            let portal = match f.portal {
                Some(Sym(s)) if s < nsyms && self.symbols[s as usize].flags & SYM_INDIRECT == 0 => s,
                Some(_) => return Err(WriteError::Portal(i)),
                None => NO_PORTAL,
            };
            let too_large = |_| WriteError::TooLarge;
            funcs.push(FuncEntry {
                code_off: code.len().try_into().map_err(too_large)?,
                code_len: f.code.len().try_into().map_err(too_large)?,
                frame_size: f.frame_size,
                arg_size: f.arg_size,
                ret_size: f.ret_size,
                cleanup_off: cleanup.len().try_into().map_err(too_large)?,
                cleanup_len: f.cleanup.len().try_into().map_err(too_large)?,
                portal,
            });
            code.extend_from_slice(&f.code);
            cleanup.extend_from_slice(&f.cleanup);
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
        let code_span = span(code.len(), 4, 4)?;
        let cleanup_span = span(cleanup.len(), mem::size_of::<CleanupEntry>(), 4)?;
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
            code: code_span,
            cleanup: cleanup_span,
            fixups: fixups_span,
            sym_flags,
            symbols,
            consts,
            site_count: self.sites,
            fixup_area: fixup_area as u32,
        };

        let mut ro = vec![0u8; size];
        let flags: Vec<u8> = self.symbols.iter().map(|s| s.flags).collect();
        // SAFETY: all of these are padding-free plain-data types.
        unsafe {
            put(&mut ro, 0, slice::from_ref(&header));
            put(&mut ro, functions.off, &funcs);
            put(&mut ro, code_span.off, &code);
            put(&mut ro, cleanup_span.off, &cleanup);
            put(&mut ro, fixups_span.off, &fixups);
            put(&mut ro, sym_flags.off, &flags);
            put(&mut ro, consts.off, &self.consts);
        }

        // Relocations.
        let mut relocs = Vec::new();
        relocs.push(Reloc {
            section: Section::ReadOnly,
            offset: mem::offset_of!(Header, data) as u64,
            target: RelocTarget::Section(Section::Writable),
            addend: 0,
        });
        for i in 0..nsyms {
            relocs.push(Reloc {
                section: Section::ReadOnly,
                offset: symbols.off as u64 + i as u64 * 8,
                target: RelocTarget::Symbol(Sym(i)),
                addend: 0,
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
            Ok(Reloc { section, offset: (base + r.offset as usize) as u64, target, addend })
        };
        for r in &self.const_relocs {
            relocs.push(map(r, Section::ReadOnly, consts.off as usize, self.consts.len())?);
        }
        for r in &self.data_relocs {
            relocs.push(map(r, Section::Writable, fixup_area, self.data.len())?);
        }

        Ok(ImageObject {
            rodata: ro,
            rodata_align: (self.const_align as u64).max(8),
            data,
            data_align: data_align as u64,
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
