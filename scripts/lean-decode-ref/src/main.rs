//! `lean-decode-ref`: the Rust side of the Lean image reader and decoder cross-check
//! (`scripts/lean-decode-diff.py`, lean/docs/aot.md §C2–§C3).
//!
//! ```text
//! lean-decode-ref summary <image object>   the image summary, as `ryo-lean obj` prints it
//! lean-decode-ref decode <image object>    each VM function decoded to the reduced set
//! lean-decode-ref lsda <image object>      each VM function's FDE and LSDA call sites
//! ```
//!
//! The object is read with the `object` crate (an ELF reader independent of the Lean one). The
//! image is `ryo_bytecode::image::Image`, parsed and validated by the runtime's own code. For
//! `decode`, the object is linked in memory: the read-only, writable and text sections are laid
//! out in one buffer, the text's relocations applied (handlers and `ryo_probe_stack` at made-up
//! addresses past the text), and each function decoded by `ImageResolver::decode`, the decoder
//! the runtime uses (`asm::decode_linked`). That is `asm::decode_reduced`'s reader with the
//! fields classified by address: the object can't give `decode_reduced` its relocation list,
//! since the writer resolves calls between the image's functions and leaves no relocation for
//! them (`Ryo/Obj/Reloc.lean` reads them the same way).
//!
//! The decode output, per function (the format `ryo-lean decode` is to reproduce):
//!
//! ```text
//! func <i> <name>
//!   frame <frame size>
//!   <reduced::Disasm lines: word offset, then the instruction>
//!   cleanup <word offset> -> <landing pad word offset>[ catch] | continue
//!   scope <word offset> <frame offset> <size> escape <align> | end | lend
//!   dropped <word offset>
//!   head <word offset>
//! ```
//!
//! or `  error: <what> at <byte>` when the code isn't canonical, `  error: malformed
//! instruction list` when the function's instruction list isn't well formed. A file that isn't an image object
//! prints one `error: ...` line and exits with 1.
//!
//! `lsda` prints what `ryo-lean lsda` does (`Ryo.Obj.ImageObject.lsdaLines`), found another
//! way: not by parsing the CIE and FDEs' augmentation, but by walking `.eh_frame`'s entries by
//! their lengths and taking each FDE's relocations, the one at its `pc_begin` (8 bytes in)
//! against the text, and the other against the LSDA section; the call sites are
//! `asm::lsda::parse` of the bytes up to the next LSDA (or the section's end), compared with
//! the image's table (`CallSite::from(&CallSiteEntry)`).

use std::process::ExitCode;

use object::read::elf::ElfFile64;
use object::{LittleEndian, Object, ObjectSection, ObjectSymbol, RelocationFlags, RelocationTarget, SectionIndex, SymbolKind, SymbolSection, elf};
use ryo_bytecode::asm::{CallSite, Ref, Resolver, ScopeKind, lsda};
use ryo_bytecode::full::Opcode;
use ryo_bytecode::image::{CATCH, CONTINUE, Header, Image, ImageResolver, JIT_LOOP_CTR};
use ryo_bytecode::{ALL_OPCODES, reduced};

const IMAGE_PREFIX: &str = "__ryo_image_";
const PROBE: &str = "ryo_probe_stack";

/// A relocation of the object.
#[derive(Clone, Copy)]
struct Rel {
    offset: u64,
    sym: object::SymbolIndex,
    addend: i64,
    r_type: u32,
}

fn relocs(file: &ElfFile64<'_, LittleEndian>, section: SectionIndex) -> Result<Vec<Rel>, String> {
    let s = file.section_by_index(section).map_err(|e| e.to_string())?;
    let mut out = Vec::new();
    for (offset, r) in s.relocations() {
        let RelocationTarget::Symbol(sym) = r.target() else { return Err(format!("relocation at {offset} not against a symbol")) };
        let RelocationFlags::Elf { r_type } = r.flags() else { return Err("not ELF".into()) };
        if !matches!(r_type, elf::R_X86_64_64 | elf::R_X86_64_PC32 | elf::R_X86_64_PLT32) {
            return Err(format!("relocation type {r_type} at {offset}"));
        }
        out.push(Rel { offset, sym, addend: r.addend(), r_type });
    }
    out.sort_by_key(|r| r.offset);
    Ok(out)
}

/// The handler `ryo_h_<Name>` a (mangled) symbol name stands for: a v0 identifier
/// `<len>ryo_h_<Name>` ending the name, or the bare name.
fn handler_of(name: &str) -> Option<Opcode> {
    let op = name.rsplit("ryo_h_").next().filter(|_| name.contains("ryo_h_"))?;
    let ident = format!("ryo_h_{op}");
    if name != ident && !name.ends_with(&format!("{}{ident}", ident.len())) {
        return None;
    }
    ALL_OPCODES.iter().copied().find(|o| format!("{o:?}") == op && ryo_bytecode::asm::has_handler(*o))
}

fn is_probe(name: &str) -> bool {
    name == PROBE || name.ends_with(&format!("{}{PROBE}", PROBE.len()))
}

fn render(r: Ref) -> String {
    match r {
        Ref::Handler(op) => format!("handler {op:?}"),
        Ref::RegHandler(op) => format!("reg handler {op:?}"),
        Ref::Probe => "probe".into(),
        Ref::Func(f) => format!("func {}", f.0),
        Ref::Sym(s) => format!("sym {}", s.0),
        Ref::Site(s) => format!("site {}", s.0),
        Ref::Const(k) => format!("const {}", k.0),
        Ref::Data(d) => format!("data {}", d.0),
        Ref::Ro(o) => format!("ro {o}"),
        Ref::Rec => "rec".into(),
        Ref::RecLoopCtr => "recloopctr".into(),
    }
}

fn mode_str(bits: u32) -> String {
    let b = |m: u32| (bits & m != 0) as u8;
    use ryo_bytecode::image::*;
    format!(
        "fp_arg={} frame_pointer={} align_loops={} pe={} counters={}",
        b(MODE_FP_ARG),
        b(MODE_FRAME_POINTER),
        b(MODE_ALIGN_LOOPS),
        b(MODE_PE),
        b(MODE_COUNTERS)
    )
}

fn span(s: ryo_bytecode::image::Span) -> String {
    format!("{}+{}", s.off, s.count)
}

/// An image object, linked in memory.
struct Linked<'d> {
    file: ElfFile64<'d, LittleEndian>,
    symbol: String,
    ro: SectionIndex,
    ro_base: u64,
    data: SectionIndex,
    data_base: u64,
    text: SectionIndex,
    text_base: u64,
    ro_relocs: Vec<Rel>,
    text_relocs: Vec<Rel>,
    /// The read-only section from the header, then the writable section, then the text, each
    /// 64-aligned (`u64`s, so that the header is 8-aligned).
    buf: Vec<u64>,
    ro_len: usize,
    data_at: usize,
    text_at: usize,
    text_len: usize,
    /// `(address, opcode)` of each handler, sorted, and `ryo_probe_stack`'s address.
    handlers: Vec<(usize, Opcode)>,
    probe: usize,
}

impl<'d> Linked<'d> {
    fn new(bytes: &'d [u8]) -> Result<Self, String> {
        let file = ElfFile64::<LittleEndian>::parse(bytes).map_err(|e| e.to_string())?;
        let mut cands = file.symbols().filter(|s| s.name().is_ok_and(|n| n.starts_with(IMAGE_PREFIX)) && !s.is_undefined());
        let sym = cands.next().ok_or("no image symbol (__ryo_image_*)")?;
        if cands.next().is_some() {
            return Err("more than one image symbol".into());
        }
        let ro = sym.section_index().ok_or("image symbol not in a section")?;
        let ro_base = sym.address();
        let symbol = sym.name().unwrap_or("").to_owned();
        drop(cands);
        let ro_relocs = relocs(&file, ro)?;
        let pointer = |at: u64, what: &str| -> Result<(SectionIndex, u64), String> {
            let r = ro_relocs.iter().find(|r| r.offset == at).ok_or(format!("the header's `{what}` field has no relocation"))?;
            let s = file.symbol_by_index(r.sym).map_err(|e| e.to_string())?;
            let i = s.section_index().ok_or(format!("the header's `{what}` points at an undefined symbol"))?;
            Ok((i, (s.address() as i64 + r.addend) as u64))
        };
        let (data, data_base) = pointer(ro_base + 24, "data")?;
        let (text, text_base) = pointer(ro_base + 40, "text")?;
        let text_relocs = relocs(&file, text)?;
        let sec = |i| file.section_by_index(i).and_then(|s| s.data()).map_err(|e| e.to_string());
        let ro_bytes = &sec(ro)?[ro_base as usize..];
        let data_bytes = &sec(data)?[data_base as usize..];
        let text_bytes = &sec(text)?[text_base as usize..];
        let header_u32 = |at: usize| u32::from_le_bytes(ro_bytes.get(at..at + 4).unwrap_or(&[0; 4]).try_into().unwrap()) as usize;
        let (data_len, text_len) = (header_u32(32).min(data_bytes.len()), header_u32(36).min(text_bytes.len()));
        let up = |n: usize| n.div_ceil(64) * 64;
        let (data_at, text_at) = (up(ro_bytes.len()), up(ro_bytes.len()) + up(data_len));
        let mut buf = vec![0u64; (text_at + up(text_len)) / 8];
        {
            let b = bytes_mut(&mut buf);
            b[..ro_bytes.len()].copy_from_slice(ro_bytes);
            b[data_at..data_at + data_len].copy_from_slice(&data_bytes[..data_len]);
            b[text_at..text_at + text_len].copy_from_slice(&text_bytes[..text_len]);
        }
        let base = buf.as_ptr() as usize;
        let h0 = base + text_at + up(text_len) + 0x10000;
        let handlers = ALL_OPCODES.iter().map(|&op| (h0 + 16 * op as usize, op)).collect();
        let probe = h0 + 16 * ALL_OPCODES.len() + 16;
        let mut l = Linked {
            file,
            symbol,
            ro,
            ro_base,
            data,
            data_base,
            text,
            text_base,
            ro_relocs,
            text_relocs,
            buf,
            ro_len: ro_bytes.len(),
            data_at,
            text_at,
            text_len,
            handlers,
            probe,
        };
        if l.ro_len >= size_of::<Header>() {
            let (d, t) = (l.addr(data_at) as u64, l.addr(text_at) as u64);
            let b = bytes_mut(&mut l.buf);
            b[24..32].copy_from_slice(&d.to_le_bytes());
            b[40..48].copy_from_slice(&t.to_le_bytes());
        }
        Ok(l)
    }

    fn bytes(&self) -> &[u8] {
        // SAFETY: plain bytes of the `u64` buffer.
        unsafe { std::slice::from_raw_parts(self.buf.as_ptr().cast(), self.buf.len() * 8) }
    }

    fn addr(&self, at: usize) -> usize {
        self.buf.as_ptr() as usize + at
    }

    fn image(&self) -> Result<Image<'_>, String> {
        Image::parse(&self.bytes()[..self.ro_len]).map_err(|e| format!("image: {e:?}"))
    }

    fn text(&self) -> &[u8] {
        &self.bytes()[self.text_at..self.text_at + self.text_len]
    }

    fn sym_name(&self, s: object::SymbolIndex) -> String {
        let Ok(s) = self.file.symbol_by_index(s) else { return "?".into() };
        if s.kind() == SymbolKind::Section {
            if let Some(Ok(sec)) = s.section_index().map(|i| self.file.section_by_index(i)) {
                return sec.name().unwrap_or("?").into();
            }
        }
        s.name().unwrap_or("?").into()
    }

    /// The linked address of symbol `s` (`S`), if it has one.
    fn sym_addr(&self, s: object::SymbolIndex) -> Option<i64> {
        let sym = self.file.symbol_by_index(s).ok()?;
        match sym.section() {
            SymbolSection::Section(i) => {
                let (at, base) = if i == self.ro {
                    (0, self.ro_base)
                } else if i == self.data {
                    (self.data_at, self.data_base)
                } else if i == self.text {
                    (self.text_at, self.text_base)
                } else {
                    return None;
                };
                Some(self.addr(at) as i64 + sym.address() as i64 - base as i64)
            }
            SymbolSection::Undefined => {
                let name = sym.name().ok()?;
                if let Some(op) = handler_of(name) {
                    self.handlers.iter().find(|h| h.1 == op).map(|h| h.0 as i64)
                } else if is_probe(name) {
                    Some(self.probe as i64)
                } else {
                    None
                }
            }
            _ => None,
        }
    }

    /// Applies the text's relocations to the in-memory text.
    fn link_text(&mut self) -> Result<(), String> {
        let end = self.text_base + self.text_len as u64;
        let mut fields = Vec::new();
        for r in self.text_relocs.iter().filter(|r| r.offset >= self.text_base && r.offset < end) {
            if r.r_type == elf::R_X86_64_64 {
                return Err(format!("R_X86_64_64 in the text at {}", r.offset));
            }
            let at = self.text_at + (r.offset - self.text_base) as usize;
            let s = self.sym_addr(r.sym).ok_or(format!("text relocation at {} against `{}`", r.offset, self.sym_name(r.sym)))?;
            let v = s + r.addend - self.addr(at) as i64;
            let v = i32::try_from(v).map_err(|_| format!("text relocation at {} out of range", r.offset))?;
            fields.push((at, v));
        }
        let b = bytes_mut(&mut self.buf);
        for (at, v) in fields {
            b[at..at + 4].copy_from_slice(&v.to_le_bytes());
        }
        Ok(())
    }

    fn resolver<'a>(&'a self, image: Image<'a>) -> ImageResolver<'a> {
        ImageResolver { image, handlers: &self.handlers, probe: self.probe }
    }

    /// The first `STT_FUNC` symbol (in symbol-table order) at text offset `off`.
    fn func_name(&self, off: u32) -> String {
        self.file
            .symbols()
            .find(|s| s.kind() == SymbolKind::Text && s.section_index() == Some(self.text) && s.address() == self.text_base + off as u64)
            .and_then(|s| s.name().ok().map(str::to_owned))
            .unwrap_or_else(|| "?".into())
    }

    fn text_relocs_in(&self, off: u32, len: u32) -> &[Rel] {
        let (a, b) = (self.text_base + off as u64, self.text_base + off as u64 + len as u64);
        let lo = self.text_relocs.partition_point(|r| r.offset < a);
        let hi = self.text_relocs.partition_point(|r| r.offset < b);
        &self.text_relocs[lo..hi]
    }

    fn summary(&self, out: &mut Vec<String>) -> Result<(), String> {
        let img = self.image()?;
        let h = img.header();
        out.push(format!("image {}", self.symbol));
        out.push(format!(
            "crate_hash {:#x} stable_crate_id {:#x} cgu_hash {:#x} mode {} {}",
            h.crate_hash,
            h.stable_crate_id,
            h.cgu_hash,
            h.mode,
            mode_str(h.mode)
        ));
        out.push(format!(
            "sizes ro {} data {} text {} sites {} fixup_area {} jit_records {}",
            h.size,
            h.data_size,
            h.text_size,
            h.site_count,
            h.fixup_area,
            span(h.jit_records)
        ));
        out.push(format!(
            "parts functions {} code_consts {} fixups {} sym_flags {} func_flags {} symbols {} consts {} lists {} call_sites {} const_relocs {}",
            span(h.functions),
            span(h.code_consts),
            span(h.fixups),
            span(h.sym_flags),
            span(h.func_flags),
            span(h.symbols),
            span(h.consts),
            span(h.lists),
            span(h.call_sites),
            span(h.const_relocs)
        ));
        out.push(match img.validate() {
            Ok(()) => "validate ok".into(),
            Err(e) => format!("validate error: {e:?}"),
        });
        let flags = img.symbol_flags();
        for i in 0..h.symbols.count {
            let at = self.ro_base + h.symbols.off as u64 + 8 * i as u64;
            let name = match self.ro_relocs.binary_search_by_key(&at, |r| r.offset) {
                Err(_) => format!("error: symbol slot {i} has no relocation"),
                Ok(j) if self.ro_relocs[j].r_type != elf::R_X86_64_64 || self.ro_relocs[j].addend != 0 => {
                    format!("error: symbol slot {i}'s relocation isn't R_X86_64_64 + 0")
                }
                Ok(j) => self.sym_name(self.ro_relocs[j].sym),
            };
            out.push(format!("sym {i} flags {} {name}", flags[i as usize]));
        }
        let res = self.resolver(img);
        let records = img.jit_records() as usize;
        for (i, f) in img.functions().iter().enumerate() {
            let rs = self.text_relocs_in(f.code_off, f.code_len);
            out.push(format!(
                "func {i} off {} len {} arg {} ret {} kind {} list {} call_sites {} relocs {} {}",
                f.code_off,
                f.code_len,
                f.arg_size,
                f.ret_size,
                f.ret_kind,
                img.list(i as u32).len(),
                img.call_sites(i as u32).len(),
                rs.len(),
                self.func_name(f.code_off)
            ));
            for r in rs {
                let pos = r.offset - self.text_base - f.code_off as u64;
                // The field's target: `S + A + 4` (see `Ryo.Obj.ImageObject.refOf`).
                let to = self.sym_addr(r.sym).map(|s| (s + r.addend + 4) as u64);
                let record = (records + 64 * i) as u64;
                let counters = h.jit_records.count != 0;
                let line = match to {
                    Some(to) if counters && to == record => "rec".into(),
                    Some(to) if counters && to == record + JIT_LOOP_CTR as u64 => "recloopctr".into(),
                    Some(to) => res.resolve(to).map_or_else(|| "error: unresolved".into(), render),
                    None => format!("error: against `{}`", self.sym_name(r.sym)),
                };
                out.push(format!("  reloc {pos} {line}"));
            }
        }
        Ok(())
    }

    fn decode(&self, out: &mut Vec<String>) -> Result<(), String> {
        let img = self.image()?;
        let res = self.resolver(img);
        for (i, f) in img.functions().iter().enumerate() {
            out.push(format!("func {i} {}", self.func_name(f.code_off)));
            match res.decode(i as u32, self.text()) {
                None => out.push("  error: malformed instruction list".into()),
                Some(Err(e)) => out.push(format!("  error: {} at {}", e.what, e.at)),
                Some(Ok(d)) => {
                    out.push(format!("  frame {}", d.frame_size));
                    out.extend(reduced::Disasm(&d.words).to_string().lines().map(|l| format!("  {l}")));
                    for c in &d.cleanup {
                        out.push(match c.target {
                            CONTINUE => format!("  cleanup {} -> continue", c.offset),
                            t if t & CATCH != 0 => format!("  cleanup {} -> {} catch", c.offset, t & !CATCH),
                            t => format!("  cleanup {} -> {t}", c.offset),
                        });
                    }
                    for s in &d.scopes {
                        out.push(match s.kind {
                            ScopeKind::Escape { align } => format!("  scope {} {} {} escape {align}", s.code_offset, s.frame_offset, s.size),
                            ScopeKind::End => format!("  scope {} {} {} end", s.code_offset, s.frame_offset, s.size),
                            ScopeKind::Lend => format!("  scope {} {} {} lend", s.code_offset, s.frame_offset, s.size),
                        });
                    }
                    out.extend(d.dropped.iter().map(|w| format!("  dropped {w}")));
                    out.extend(d.heads.iter().map(|w| format!("  head {w}")));
                }
            }
        }
        Ok(())
    }
}

impl Linked<'_> {
    /// The section and offset a relocation points at (`S + A`), if the symbol is defined.
    fn target(&self, r: &Rel) -> Option<(SectionIndex, i64)> {
        let s = self.file.symbol_by_index(r.sym).ok()?;
        Some((s.section_index()?, s.address() as i64 + r.addend))
    }

    fn lsda(&self, out: &mut Vec<String>) -> Result<(), String> {
        let img = self.image()?;
        let eh = self.file.section_by_name(".eh_frame").ok_or("no .eh_frame section")?;
        let data = eh.data().map_err(|e| e.to_string())?;
        let rels = relocs(&self.file, eh.index())?;
        let u32_at = |at: usize| data.get(at..at + 4).map(|b| u32::from_le_bytes(b.try_into().unwrap()));
        // Per FDE: its offset, first address, range and LSDA.
        let mut fdes = Vec::new();
        let mut off = 0;
        while let Some(len) = u32_at(off) {
            if len == 0 {
                break;
            }
            let end = off + 4 + len as usize;
            if u32_at(off + 4).ok_or("truncated entry")? != 0 {
                let pc = rels.iter().find(|r| r.offset == off as u64 + 8).and_then(|r| self.target(r));
                let range = u32_at(off + 12).ok_or("truncated FDE")?;
                let lsda = rels
                    .iter()
                    .filter(|r| r.offset > off as u64 + 8 && r.offset < end as u64)
                    .find_map(|r| self.target(r).filter(|t| t.0 != self.text));
                fdes.push((off, pc, range, lsda));
            }
            off = end;
        }
        out.push(format!("fdes {} functions {}", fdes.len(), img.functions().len()));
        for (i, f) in img.functions().iter().enumerate() {
            let name = self.func_name(f.code_off);
            let start = Some((self.text, (self.text_base + f.code_off as u64) as i64));
            let found: Vec<_> = fdes.iter().filter(|d| d.1 == start).collect();
            let &&(fde, _, range, lsda_ptr) = match &found[..] {
                [d] => d,
                [] => {
                    out.push(format!("func {i} {name} error: no FDE starts at the function"));
                    continue;
                }
                ds => {
                    out.push(format!("func {i} {name} error: {} FDEs start at the function", ds.len()));
                    continue;
                }
            };
            let Some((sec, at)) = lsda_ptr else {
                out.push(format!("func {i} {name} error: the FDE has no LSDA pointer"));
                continue;
            };
            let s = self.file.section_by_index(sec).map_err(|e| e.to_string())?;
            let bytes = s.data().map_err(|e| e.to_string())?;
            let next = fdes.iter().filter_map(|d| d.3).filter(|t| t.0 == sec && t.1 > at).map(|t| t.1 as usize).min().unwrap_or(bytes.len());
            let l = &bytes[at as usize..next];
            out.push(format!("func {i} {name} fde {fde} range {range} len {} lsda {} {at} {}", f.code_len, s.name().unwrap_or("?"), l.len()));
            match lsda::parse(l) {
                None => out.push("  lsda error".into()),
                Some(sites) => {
                    for c in &sites {
                        let pad = c.pad.map_or("none".into(), |p| p.to_string());
                        out.push(format!("  site {} {} pad {pad}{}", c.start, c.len, if c.catch { " catch" } else { "" }));
                    }
                    let image: Vec<CallSite> = img.call_sites(i as u32).iter().map(CallSite::from).collect();
                    out.push(if sites == image { "  image equal" } else { "  image differs" }.into());
                }
            }
        }
        Ok(())
    }
}

fn bytes_mut(buf: &mut [u64]) -> &mut [u8] {
    // SAFETY: plain bytes of the `u64` buffer.
    unsafe { std::slice::from_raw_parts_mut(buf.as_mut_ptr().cast(), buf.len() * 8) }
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let (cmd, path) = match &args[..] {
        [c, p] if c == "summary" || c == "decode" || c == "lsda" => (c.as_str(), p),
        _ => {
            eprintln!("usage: lean-decode-ref summary|decode|lsda <image object>");
            return ExitCode::from(2);
        }
    };
    let bytes = match std::fs::read(path) {
        Ok(b) => b,
        Err(e) => {
            eprintln!("{path}: {e}");
            return ExitCode::from(2);
        }
    };
    let mut out = Vec::new();
    let r = Linked::new(&bytes).and_then(|mut l| match cmd {
        "summary" => l.summary(&mut out),
        "lsda" => l.lsda(&mut out),
        _ => l.link_text().and_then(|()| l.decode(&mut out)),
    });
    let code = match r {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            out.push(format!("error: {e}"));
            ExitCode::from(1)
        }
    };
    let mut s = out.join("\n");
    s.push('\n');
    print!("{s}");
    code
}
