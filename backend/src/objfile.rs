//! Object files the backend writes itself, with the `object` crate: the image object
//! (design/vm.md#image-format) and the registry object (design/backend.md#pipeline, step 6).
//!
//! No compiler types here. The format-specific parts sit behind [`ObjectFormat`]
//! (design/platforms.md); only ELF is implemented so far.

use object::write::{Object, Relocation, StandardSegment, Symbol, SymbolId, SymbolSection};
use object::{
    Architecture, BinaryFormat, Endianness, RelocationFlags, SectionFlags, SectionKind, SymbolFlags, SymbolKind,
    SymbolScope, elf,
};
use ryo_bytecode::image::{ImageObject, RelocTarget, Section};

/// The symbol an image defines: `__ryo_image_<StableCrateId>`, with the id in hex.
pub fn image_symbol(stable_crate_id: u64) -> String {
    format!("{IMAGE_SYMBOL_PREFIX}{stable_crate_id:016x}")
}

/// Prefix of [`image_symbol`]; the registry finds upstream images by it.
pub const IMAGE_SYMBOL_PREFIX: &str = "__ryo_image_";

/// The pointer slot `ryo_rt::entry::c_main` loads the entry fn's portal from.
pub const MAIN_SLOT_SYMBOL: &str = "__ryo_main";

/// Defined by every registry object; `ryo_rt::vm::enter` references it.
pub const ANCHOR_SYMBOL: &str = "__ryo_registry_anchor";

/// The registration entry point in `ryo_rt`.
pub const REGISTER_SYMBOL: &str = "ryo_vm_register";

/// The object-format-specific parts of the image and registry objects.
pub trait ObjectFormat {
    fn new_object(&self) -> Object<'static>;
    /// An absolute 64-bit data relocation.
    fn abs64(&self) -> RelocationFlags;
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
    /// Adds a constructor that calls `ryo_vm_register(images, n)`.
    fn add_registry_ctor(&self, obj: &mut Object<'static>, images: object::write::SectionId, n: usize);
}

/// The format for a target's binary format, or an error for formats not implemented yet.
pub fn format_for(binary_format: BinaryFormat) -> Result<Box<dyn ObjectFormat>, String> {
    match binary_format {
        BinaryFormat::Elf => Ok(Box::new(Elf)),
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

    fn abs64(&self) -> RelocationFlags {
        RelocationFlags::Elf { r_type: elf::R_X86_64_64 }
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

    fn add_registry_ctor(&self, obj: &mut Object<'static>, images: object::write::SectionId, n: usize) {
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
        let init = obj.add_section(Vec::new(), b".init_array".to_vec(), SectionKind::Elf(elf::SHT_INIT_ARRAY));
        obj.section_mut(init).flags = SectionFlags::Elf { sh_flags: u64::from(elf::SHF_ALLOC | elf::SHF_WRITE) };
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

/// The image object: the two image sections, `__ryo_image_<id>` at the start of the read-only
/// one, and, for binaries with a VM `main`, the `__ryo_main` slot pointing at `main_portal`.
pub fn write_image(
    fmt: &dyn ObjectFormat,
    image: &ImageObject,
    stable_crate_id: u64,
    main_portal: Option<&str>,
) -> Result<Vec<u8>, String> {
    let mut obj = fmt.new_object();
    let ro = fmt.relro_section(&mut obj, "ryo_image");
    obj.append_section_data(ro, &image.rodata, image.rodata_align);
    let rw = fmt.data_section(&mut obj, "ryo_image");
    obj.append_section_data(rw, &image.data, image.data_align);
    fmt.hidden_global(&mut obj, &image_symbol(stable_crate_id), ro, 0, image.rodata.len() as u64, SymbolKind::Data);

    let syms: Vec<SymbolId> = image.symbols.iter().map(|s| undefined(&mut obj, &s.name, SymbolKind::Unknown)).collect();
    for r in &image.relocs {
        let section = match r.section {
            Section::ReadOnly => ro,
            Section::Writable => rw,
        };
        let symbol = match r.target {
            RelocTarget::Symbol(s) => syms[s.0 as usize],
            RelocTarget::Section(Section::ReadOnly) => obj.section_symbol(ro),
            RelocTarget::Section(Section::Writable) => obj.section_symbol(rw),
        };
        obj.add_relocation(section, Relocation { offset: r.offset, symbol, addend: r.addend, flags: fmt.abs64() })
            .map_err(|e| format!("image relocation: {e}"))?;
    }

    if let Some(portal) = main_portal {
        let slot = fmt.relro_section(&mut obj, "ryo_main");
        obj.append_section_data(slot, &[0; 8], 8);
        fmt.hidden_global(&mut obj, MAIN_SLOT_SYMBOL, slot, 0, 8, SymbolKind::Data);
        let target = undefined(&mut obj, portal, SymbolKind::Text);
        obj.add_relocation(slot, Relocation { offset: 0, symbol: target, addend: 0, flags: fmt.abs64() })
            .map_err(|e| format!("__ryo_main relocation: {e}"))?;
    }
    obj.write().map_err(|e| format!("writing the image object: {e}"))
}

/// The registry object of one final link: a constructor registering `images` (image symbols),
/// and the hidden `__ryo_registry_anchor`.
pub fn write_registry(fmt: &dyn ObjectFormat, images: &[String]) -> Result<Vec<u8>, String> {
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
        fmt.add_registry_ctor(&mut obj, list, images.len());
    }
    obj.write().map_err(|e| format!("writing the registry object: {e}"))
}

/// The image symbols an archive (an rlib) defines, from its symbol table.
pub fn archive_image_symbols(data: &[u8]) -> Result<Vec<String>, String> {
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
