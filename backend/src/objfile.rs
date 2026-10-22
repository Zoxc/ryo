//! Object files the backend writes itself, with the `object` crate: the image object
//! (design/vm.md#image-format) and the registry object (design/backend.md#pipeline, step 6).
//!
//! No compiler types here. The format-specific parts sit behind [`ObjectFormat`]
//! (design/platforms.md): ELF ([`Elf`]) and PE/COFF ([`Coff`]).

use object::write::{Object, Relocation, StandardSegment, Symbol, SymbolId, SymbolSection};
use object::{
    Architecture, BinaryFormat, Endianness, RelocationFlags, SectionFlags, SectionKind, SymbolFlags, SymbolKind,
    SymbolScope, elf, pe,
};
use ryo_bytecode::image::{FuncSymbol, ImageObject, RelocKind, RelocTarget, SYM_INDIRECT, Section, SymVisibility};
use ryo_bytecode::full::Opcode;

/// The symbol an image defines: `__ryo_image_<StableCrateId>`, with the id in hex.
pub fn image_symbol(stable_crate_id: u64) -> String {
    format!("{IMAGE_SYMBOL_PREFIX}{stable_crate_id:016x}")
}

/// Prefix of [`image_symbol`]; the registry finds upstream images by it.
pub const IMAGE_SYMBOL_PREFIX: &str = "__ryo_image_";

/// The pointer slot `ryo_rt::entry::c_main` loads the entry fn's address from.
pub const MAIN_SLOT_SYMBOL: &str = "__ryo_main";

/// Defined by every registry object; every image object references it.
pub const ANCHOR_SYMBOL: &str = "__ryo_registry_anchor";

/// The registration entry point in `ryo_rt`.
pub const REGISTER_SYMBOL: &str = "ryo_vm_register";

/// The stack probe of large frames, in `ryo_rt` (before mangling).
pub const PROBE_SYMBOL: &str = "ryo_probe_stack";

/// The name of opcode `op`'s handler in `ryo_rt` (before mangling).
pub fn handler_name(op: Opcode) -> String {
    format!("ryo_h_{op:?}")
}

/// The object-format-specific parts of the image and registry objects.
pub trait ObjectFormat {
    fn new_object(&self) -> Object<'static>;
    /// An absolute 64-bit data relocation.
    fn abs64(&self) -> RelocationFlags {
        self.reloc(RelocKind::Abs64)
    }
    /// A relocation of an image field of kind `kind`.
    fn reloc(&self, kind: RelocKind) -> RelocationFlags;
    /// The executable section of VM code.
    fn text_section(&self, obj: &mut Object<'static>) -> object::write::SectionId;
    /// An unwind section of the image ([`Section::EhFrame`] …).
    fn unwind_section(&self, obj: &mut Object<'static>, which: Section) -> object::write::SectionId;
    /// A local symbol naming the code of a VM function (backtraces, profilers).
    fn local_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64);
    /// The global symbol of a VM function that native code calls by name.
    fn global_function(
        &self,
        obj: &mut Object<'static>,
        name: &str,
        section: object::write::SectionId,
        offset: u64,
        size: u64,
        sym: FuncSymbol,
    );
    /// A section for data that is only written by relocations (RELRO / `.rdata`).
    fn relro_section(&self, obj: &mut Object<'static>, name: &str) -> object::write::SectionId;
    /// A writable data section.
    fn data_section(&self, obj: &mut Object<'static>, name: &str) -> object::write::SectionId;
    /// Defines a global symbol that is visible only inside the link unit.
    fn hidden_global(
        &self,
        obj: &mut Object<'static>,
        name: &str,
        section: object::write::SectionId,
        offset: u64,
        size: u64,
        kind: SymbolKind,
    ) -> SymbolId;
    /// The symbol an indirect symbol slot ([`SYM_INDIRECT`]) for `name` relocates against:
    /// the import slot holding `name`'s address. An error on formats without import slots.
    fn import_slot(&self, name: &str) -> Result<String, String>;
    /// Adds a constructor that calls `ryo_vm_register(images, n)`. With `register_import`,
    /// `ryo_vm_register` is in another DLL and is called through its import slot.
    fn add_registry_ctor(
        &self,
        obj: &mut Object<'static>,
        images: object::write::SectionId,
        n: usize,
        register_import: bool,
    );
}

/// The format for a target's binary format, or an error for formats not implemented yet.
pub fn format_for(binary_format: BinaryFormat) -> Result<Box<dyn ObjectFormat>, String> {
    match binary_format {
        BinaryFormat::Elf => Ok(Box::new(Elf)),
        BinaryFormat::Coff => Ok(Box::new(Coff)),
        f => Err(format!("the ryo backend doesn't support the {f:?} object format yet")),
    }
}

pub struct Elf;

impl ObjectFormat for Elf {
    fn new_object(&self) -> Object<'static> {
        let mut obj = Object::new(BinaryFormat::Elf, Architecture::X86_64, Endianness::Little);
        // Without it, GNU ld assumes the object needs an executable stack.
        let note = obj.add_section(Vec::new(), b".note.GNU-stack".to_vec(), SectionKind::Elf(elf::SHT_PROGBITS));
        obj.section_mut(note).flags = SectionFlags::Elf { sh_flags: 0 };
        obj
    }

    fn reloc(&self, kind: RelocKind) -> RelocationFlags {
        RelocationFlags::Elf {
            r_type: match kind {
                RelocKind::Abs64 => elf::R_X86_64_64,
                RelocKind::Pc32 => elf::R_X86_64_PC32,
                RelocKind::Call32 => elf::R_X86_64_PLT32,
                RelocKind::Rva32 => unreachable!("no image-relative relocations on ELF"),
            },
        }
    }

    fn text_section(&self, obj: &mut Object<'static>) -> object::write::SectionId {
        obj.add_section(obj.segment_name(StandardSegment::Text).to_vec(), b".text.ryo_image".to_vec(), SectionKind::Text)
    }

    fn unwind_section(&self, obj: &mut Object<'static>, which: Section) -> object::write::SectionId {
        match which {
            Section::EhFrame => {
                let s = obj.add_section(Vec::new(), b".eh_frame".to_vec(), SectionKind::Elf(elf::SHT_X86_64_UNWIND));
                obj.section_mut(s).flags = SectionFlags::Elf { sh_flags: u64::from(elf::SHF_ALLOC) };
                s
            }
            Section::Lsda => obj.add_section(Vec::new(), b".gcc_except_table.ryo_image".to_vec(), SectionKind::ReadOnlyData),
            _ => unreachable!("not an ELF unwind section"),
        }
    }

    fn local_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64) {
        obj.add_symbol(Symbol {
            name: name.as_bytes().to_vec(),
            value: offset,
            size,
            kind: SymbolKind::Text,
            scope: SymbolScope::Compilation,
            weak: false,
            section: SymbolSection::Section(section),
            flags: SymbolFlags::None,
        });
    }

    fn global_function(
        &self,
        obj: &mut Object<'static>,
        name: &str,
        section: object::write::SectionId,
        offset: u64,
        size: u64,
        sym: FuncSymbol,
    ) {
        let (scope, st_other) = match sym.visibility {
            SymVisibility::Default => (SymbolScope::Dynamic, elf::STV_DEFAULT),
            SymVisibility::Hidden => (SymbolScope::Linkage, elf::STV_HIDDEN),
            SymVisibility::Protected => (SymbolScope::Dynamic, elf::STV_PROTECTED),
        };
        let bind = if sym.weak { elf::STB_WEAK } else { elf::STB_GLOBAL };
        obj.add_symbol(Symbol {
            name: name.as_bytes().to_vec(),
            value: offset,
            size,
            kind: SymbolKind::Text,
            scope,
            weak: sym.weak,
            section: SymbolSection::Section(section),
            flags: SymbolFlags::Elf { st_info: (bind << 4) | elf::STT_FUNC, st_other },
        });
    }

    fn relro_section(&self, obj: &mut Object<'static>, name: &str) -> object::write::SectionId {
        // `.data.rel.ro.*` goes to RELRO: writable while relocating, read-only afterwards.
        obj.add_section(Vec::new(), format!(".data.rel.ro.{name}").into_bytes(), SectionKind::Data)
    }

    fn data_section(&self, obj: &mut Object<'static>, name: &str) -> object::write::SectionId {
        obj.add_section(Vec::new(), format!(".data.{name}").into_bytes(), SectionKind::Data)
    }

    fn hidden_global(
        &self,
        obj: &mut Object<'static>,
        name: &str,
        section: object::write::SectionId,
        offset: u64,
        size: u64,
        kind: SymbolKind,
    ) -> SymbolId {
        obj.add_symbol(Symbol {
            name: name.as_bytes().to_vec(),
            value: offset,
            size,
            kind,
            scope: SymbolScope::Linkage,
            weak: false,
            section: SymbolSection::Section(section),
            flags: SymbolFlags::Elf { st_info: (elf::STB_GLOBAL << 4) | elf_type(kind), st_other: elf::STV_HIDDEN },
        })
    }

    fn import_slot(&self, name: &str) -> Result<String, String> {
        Err(format!("indirect symbol `{name}` in an ELF image (indirect slots are PE-only)"))
    }

    fn add_registry_ctor(
        &self,
        obj: &mut Object<'static>,
        images: object::write::SectionId,
        n: usize,
        _register_import: bool,
    ) {
        // The dynamic linker resolves the PLT entry if `ryo_rt` is in a shared object.
        // lea rdi, [rip + images]; mov esi, n; jmp ryo_vm_register
        let mut code = vec![0x48, 0x8d, 0x3d, 0, 0, 0, 0, 0xbe];
        code.extend_from_slice(&u32::try_from(n).expect("too many images").to_le_bytes());
        code.extend_from_slice(&[0xe9, 0, 0, 0, 0]);
        let text = obj.add_section(
            obj.segment_name(StandardSegment::Text).to_vec(),
            b".text.ryo_registry".to_vec(),
            SectionKind::Text,
        );
        obj.append_section_data(text, &code, 16);
        let images_sym = obj.section_symbol(images);
        let register = undefined(obj, REGISTER_SYMBOL, SymbolKind::Text);
        let rel = |offset, symbol, r_type| Relocation { offset, symbol, addend: -4, flags: RelocationFlags::Elf { r_type } };
        obj.add_relocation(text, rel(3, images_sym, elf::R_X86_64_PC32)).unwrap();
        obj.add_relocation(text, rel(13, register, elf::R_X86_64_PLT32)).unwrap();
        // Priority 0, before every other constructor: std's own (`.init_array.00099`, args
        // init) may be VM code (design/platforms.md).
        let init = obj.add_section(Vec::new(), b".init_array.00000".to_vec(), SectionKind::Elf(elf::SHT_INIT_ARRAY));
        obj.section_mut(init).flags = SectionFlags::Elf { sh_flags: u64::from(elf::SHF_ALLOC | elf::SHF_WRITE) };
        obj.append_section_data(init, &[0; 8], 8);
        let text_sym = obj.section_symbol(text);
        obj.add_relocation(init, Relocation { offset: 0, symbol: text_sym, addend: 0, flags: self.abs64() }).unwrap();
    }
}

/// PE/COFF (x86_64-pc-windows-msvc). Section names use the `$` grouping suffix, so the linker
/// merges them into `.rdata`, `.data` and `.text`, and `.CRT$XCT` into the CRT's initializer
/// table (between `.CRT$XCA` and `.CRT$XCZ`), which the CRT startup code runs before `main` or
/// on `DLL_PROCESS_ATTACH` (`_initterm`).
pub struct Coff;

impl ObjectFormat for Coff {
    fn new_object(&self) -> Object<'static> {
        Object::new(BinaryFormat::Coff, Architecture::X86_64, Endianness::Little)
    }

    fn reloc(&self, kind: RelocKind) -> RelocationFlags {
        RelocationFlags::Coff {
            typ: match kind {
                RelocKind::Abs64 => pe::IMAGE_REL_AMD64_ADDR64,
                RelocKind::Pc32 | RelocKind::Call32 => pe::IMAGE_REL_AMD64_REL32,
                RelocKind::Rva32 => pe::IMAGE_REL_AMD64_ADDR32NB,
            },
        }
    }

    fn text_section(&self, obj: &mut Object<'static>) -> object::write::SectionId {
        obj.add_section(Vec::new(), b".text$ryo_image".to_vec(), SectionKind::Text)
    }

    fn unwind_section(&self, obj: &mut Object<'static>, which: Section) -> object::write::SectionId {
        let name: &[u8] = match which {
            Section::Pdata => b".pdata",
            Section::Xdata => b".xdata",
            _ => unreachable!("not a PE unwind section"),
        };
        obj.add_section(Vec::new(), name.to_vec(), SectionKind::ReadOnlyData)
    }

    fn local_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64) {
        obj.add_symbol(Symbol {
            name: name.as_bytes().to_vec(),
            value: offset,
            size,
            kind: SymbolKind::Text,
            scope: SymbolScope::Compilation,
            weak: false,
            section: SymbolSection::Section(section),
            flags: SymbolFlags::None,
        });
    }

    fn global_function(
        &self,
        obj: &mut Object<'static>,
        name: &str,
        section: object::write::SectionId,
        offset: u64,
        size: u64,
        _sym: FuncSymbol,
    ) {
        // PE has no symbol visibility: a DLL exports what its export list names (rustc's
        // `/EXPORT` directives). A weak definition would need a comdat; VM functions with
        // weak linkage get an ordinary one.
        obj.add_symbol(Symbol {
            name: name.as_bytes().to_vec(),
            value: offset,
            size,
            kind: SymbolKind::Text,
            scope: SymbolScope::Dynamic,
            weak: false,
            section: SymbolSection::Section(section),
            flags: SymbolFlags::None,
        });
    }

    fn relro_section(&self, obj: &mut Object<'static>, name: &str) -> object::write::SectionId {
        // The loader applies base relocations to read-only sections too.
        obj.add_section(Vec::new(), format!(".rdata${name}").into_bytes(), SectionKind::ReadOnlyData)
    }

    fn data_section(&self, obj: &mut Object<'static>, name: &str) -> object::write::SectionId {
        obj.add_section(Vec::new(), format!(".data${name}").into_bytes(), SectionKind::Data)
    }

    fn hidden_global(
        &self,
        obj: &mut Object<'static>,
        name: &str,
        section: object::write::SectionId,
        offset: u64,
        size: u64,
        kind: SymbolKind,
    ) -> SymbolId {
        // PE has no symbol visibility: a DLL exports only what its export list (rustc's
        // `/EXPORT` directives) names, and these symbols are never in it.
        obj.add_symbol(Symbol {
            name: name.as_bytes().to_vec(),
            value: offset,
            size,
            kind,
            scope: SymbolScope::Linkage,
            weak: false,
            section: SymbolSection::Section(section),
            flags: SymbolFlags::None,
        })
    }

    fn import_slot(&self, name: &str) -> Result<String, String> {
        // x86_64 has no `_` decoration, so the import slot is `__imp_` + the symbol name
        // (`rustc_codegen_llvm/src/back/write.rs:1326`, `create_msvc_imps`).
        Ok(format!("__imp_{name}"))
    }

    fn add_registry_ctor(
        &self,
        obj: &mut Object<'static>,
        images: object::write::SectionId,
        n: usize,
        register_import: bool,
    ) {
        // Win64: the first two arguments are in rcx and rdx. The tail jump leaves rsp alone,
        // so this is a leaf function and needs no unwind info (no `.pdata`).
        // lea rcx, [rip + images]; mov edx, n; jmp ryo_vm_register / jmp [rip + __imp_...]
        let mut code = vec![0x48, 0x8d, 0x0d, 0, 0, 0, 0, 0xba];
        code.extend_from_slice(&u32::try_from(n).expect("too many images").to_le_bytes());
        let target = if register_import {
            code.extend_from_slice(&[0xff, 0x25, 0, 0, 0, 0]);
            undefined(obj, &format!("__imp_{REGISTER_SYMBOL}"), SymbolKind::Data)
        } else {
            code.extend_from_slice(&[0xe9, 0, 0, 0, 0]);
            undefined(obj, REGISTER_SYMBOL, SymbolKind::Text)
        };
        let target_at = code.len() as u64 - 4;
        let text = obj.add_section(Vec::new(), b".text$ryo_registry".to_vec(), SectionKind::Text);
        obj.append_section_data(text, &code, 16);
        let images_sym = obj.section_symbol(images);
        // `object` turns the addend into COFF's implicit one (REL32 is relative to the end of
        // the field, so -4 becomes 0).
        let rel = |offset, symbol| Relocation {
            offset,
            symbol,
            addend: -4,
            flags: RelocationFlags::Coff { typ: pe::IMAGE_REL_AMD64_REL32 },
        };
        obj.add_relocation(text, rel(3, images_sym)).unwrap();
        obj.add_relocation(text, rel(target_at, target)).unwrap();
        // Read-only, like the CRT's own `.CRT$XC*` sections (`#pragma section(".CRT$XCU",
        // long, read)`), so the linker merges them without an attribute-mismatch warning.
        // `XCT` sorts before the user initializers in `.CRT$XCU`, std's among them, which may
        // be VM code (design/platforms.md).
        let init = obj.add_section(Vec::new(), b".CRT$XCT".to_vec(), SectionKind::ReadOnlyData);
        obj.append_section_data(init, &[0; 8], 8);
        let text_sym = obj.section_symbol(text);
        obj.add_relocation(init, Relocation { offset: 0, symbol: text_sym, addend: 0, flags: self.abs64() }).unwrap();
    }
}

fn elf_type(kind: SymbolKind) -> u8 {
    match kind {
        SymbolKind::Text => elf::STT_FUNC,
        SymbolKind::Data => elf::STT_OBJECT,
        _ => elf::STT_NOTYPE,
    }
}

/// An undefined (external) symbol reference, added once per name.
fn undefined(obj: &mut Object<'static>, name: &str, kind: SymbolKind) -> SymbolId {
    if let Some(id) = obj.symbol_id(name.as_bytes()) {
        return id;
    }
    obj.add_symbol(Symbol {
        name: name.as_bytes().to_vec(),
        value: 0,
        size: 0,
        kind,
        scope: SymbolScope::Unknown,
        weak: false,
        section: SymbolSection::Undefined,
        flags: SymbolFlags::None,
    })
}

/// The image object: the image sections, `__ryo_image_<id>` at the start of the read-only
/// one, a symbol per VM function (global for those native code calls by name), a reference
/// to the registry anchor, and, for binaries with a VM `main`, the `__ryo_main` slot
/// pointing at `main_symbol`. `rt_symbol` names `ryo_rt`'s handlers (`ryo_h_<op>`) and
/// `ryo_probe_stack`, as rustc mangles them.
pub fn write_image(
    fmt: &dyn ObjectFormat,
    image: &ImageObject,
    stable_crate_id: u64,
    main_symbol: Option<&str>,
    rt_symbol: &dyn Fn(&str) -> String,
) -> Result<Vec<u8>, String> {
    let mut obj = fmt.new_object();
    let ro = fmt.relro_section(&mut obj, "ryo_image");
    obj.append_section_data(ro, &image.rodata, image.rodata_align);
    let rw = fmt.data_section(&mut obj, "ryo_image");
    obj.append_section_data(rw, &image.data, image.data_align);
    let text = fmt.text_section(&mut obj);
    obj.append_section_data(text, &image.text, 16);
    for f in &image.functions {
        match f.symbol {
            Some(sym) => fmt.global_function(&mut obj, &f.name, text, f.start as u64, f.len as u64, sym),
            None => fmt.local_function(&mut obj, &f.name, text, f.start as u64, f.len as u64),
        }
    }
    let mut unwind = Vec::new();
    for (which, bytes) in &image.unwind {
        let s = fmt.unwind_section(&mut obj, *which);
        obj.append_section_data(s, bytes, if *which == Section::EhFrame { 8 } else { 4 });
        unwind.push((*which, s));
    }
    let section = |s: Section| match s {
        Section::ReadOnly => ro,
        Section::Writable => rw,
        Section::Text => text,
        Section::EhFrame | Section::Lsda | Section::Pdata | Section::Xdata => {
            unwind.iter().find(|u| u.0 == s).expect("unwind section").1
        }
    };
    fmt.hidden_global(&mut obj, &image_symbol(stable_crate_id), ro, 0, image.rodata.len() as u64, SymbolKind::Data);

    // Indirect slots relocate against the import slot (design/platforms.md). The writer only
    // relocates against indirect symbols from their slots (constants pointing at them are
    // fixups), so every relocation against them is a slot's.
    let syms = image
        .symbols
        .iter()
        .map(|s| {
            let name = if s.flags & SYM_INDIRECT != 0 { fmt.import_slot(&s.name)? } else { s.name.clone() };
            Ok(undefined(&mut obj, &name, SymbolKind::Unknown))
        })
        .collect::<Result<Vec<SymbolId>, String>>()?;
    // Handler symbols, by opcode: most relocations are handler calls.
    let mut handlers: Vec<Option<SymbolId>> = vec![None; ryo_bytecode::full::ALL_OPCODES.len()];
    for r in &image.relocs {
        let symbol = match r.target {
            RelocTarget::Symbol(s) => syms[s.0 as usize],
            RelocTarget::Section(s) => obj.section_symbol(section(s)),
            RelocTarget::Handler(op) => *handlers[op as usize]
                .get_or_insert_with(|| undefined(&mut obj, &rt_symbol(&handler_name(op)), SymbolKind::Text)),
            RelocTarget::Probe => undefined(&mut obj, &rt_symbol(PROBE_SYMBOL), SymbolKind::Text),
        };
        obj.add_relocation(section(r.section), Relocation { offset: r.offset, symbol, addend: r.addend, flags: fmt.reloc(r.kind) })
            .map_err(|e| format!("image relocation: {e}"))?;
    }

    // A reference to the registry object of the link unit, so that a C linker taking the
    // image out of a staticlib takes the registry object too (design/backend.md#pipeline).
    let anchor_slot = fmt.relro_section(&mut obj, "ryo_anchor");
    obj.append_section_data(anchor_slot, &[0; 8], 8);
    let anchor = undefined(&mut obj, ANCHOR_SYMBOL, SymbolKind::Data);
    obj.add_relocation(anchor_slot, Relocation { offset: 0, symbol: anchor, addend: 0, flags: fmt.abs64() })
        .map_err(|e| format!("registry anchor relocation: {e}"))?;

    if let Some(main) = main_symbol {
        let slot = fmt.relro_section(&mut obj, "ryo_main");
        obj.append_section_data(slot, &[0; 8], 8);
        fmt.hidden_global(&mut obj, MAIN_SLOT_SYMBOL, slot, 0, 8, SymbolKind::Data);
        let target = undefined(&mut obj, main, SymbolKind::Text);
        obj.add_relocation(slot, Relocation { offset: 0, symbol: target, addend: 0, flags: fmt.abs64() })
            .map_err(|e| format!("__ryo_main relocation: {e}"))?;
    }
    obj.write().map_err(|e| format!("writing the image object: {e}"))
}

/// The registry object of one final link: a constructor registering `images` (image symbols),
/// and the hidden `__ryo_registry_anchor`. `register_import`: see
/// [`ObjectFormat::add_registry_ctor`].
pub fn write_registry(fmt: &dyn ObjectFormat, images: &[String], register_import: bool) -> Result<Vec<u8>, String> {
    let mut obj = fmt.new_object();
    let anchor = fmt.data_section(&mut obj, "ryo_registry_anchor");
    obj.append_section_data(anchor, &[0], 1);
    fmt.hidden_global(&mut obj, ANCHOR_SYMBOL, anchor, 0, 1, SymbolKind::Data);
    if !images.is_empty() {
        let list = fmt.relro_section(&mut obj, "ryo_registry");
        obj.append_section_data(list, &vec![0; images.len() * 8], 8);
        for (i, name) in images.iter().enumerate() {
            let symbol = undefined(&mut obj, name, SymbolKind::Data);
            obj.add_relocation(list, Relocation { offset: i as u64 * 8, symbol, addend: 0, flags: fmt.abs64() })
                .map_err(|e| format!("registry relocation: {e}"))?;
        }
        fmt.add_registry_ctor(&mut obj, list, images.len(), register_import);
    }
    obj.write().map_err(|e| format!("writing the registry object: {e}"))
}

/// The image symbols an archive (an rlib) defines, from its symbol table.
pub fn archive_image_symbols<'d, R: object::ReadRef<'d>>(data: R) -> Result<Vec<String>, String> {
    let archive = object::read::archive::ArchiveFile::parse(data).map_err(|e| e.to_string())?;
    let mut out = Vec::new();
    if let Some(symbols) = archive.symbols().map_err(|e| e.to_string())? {
        for s in symbols {
            let s = s.map_err(|e| e.to_string())?;
            if let Ok(name) = std::str::from_utf8(s.name())
                && name.starts_with(IMAGE_SYMBOL_PREFIX)
            {
                out.push(name.to_owned());
            }
        }
    }
    Ok(out)
}
