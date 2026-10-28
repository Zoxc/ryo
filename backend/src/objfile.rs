//! Object files the backend writes itself, with the `object` crate: the image object
//! (design/vm.md#image-format) and the registry object (design/backend.md#pipeline, step 6).
//!
//! No compiler types here. The format-specific parts sit behind [`ObjectFormat`]
//! (design/platforms.md): ELF ([`Elf`]), PE/COFF ([`Coff`]) and Mach-O ([`MachO`]).

use object::write::{Mangling, Object, Relocation, StandardSegment, Symbol, SymbolId, SymbolSection};
use object::{
    Architecture, BinaryFormat, Endianness, RelocationFlags, SectionFlags, SectionKind, SymbolFlags, SymbolKind, SymbolScope, elf, macho, pe,
};
use ryo_bytecode::full::Opcode;
use ryo_bytecode::image::{FuncSymbol, ImageObject, RelocKind, RelocTarget, SYM_INDIRECT, Section, SymVisibility};

/// The symbol an image defines: `__ryo_image_<StableCrateId>_<CGU hash>`, both in hex
/// (`image::cgu_hash` of the codegen unit's name).
pub fn image_symbol(stable_crate_id: u64, cgu_hash: u64) -> String {
    format!("__ryo_image_{stable_crate_id:016x}_{cgu_hash:016x}")
}

/// The pointer slot `ryo_rt::entry::c_main` loads the entry fn's address from.
pub const MAIN_SLOT_SYMBOL: &str = "__ryo_main";

/// Defined (weak, or a COMDAT on PE) by every registry stub; every image object references it
/// (its header's `anchor` field): `__ryo_registry_anchor_<tag>`, so that each ryo build's
/// images pull that build's stub (design/build.md#the-abi-tag).
pub fn anchor_symbol() -> String {
    format!("__ryo_registry_anchor_{}", ryo_bytecode::ABI_TAG)
}

/// The registration entry point in `ryo_rt` (before tagging and mangling).
pub const REGISTER_SYMBOL: &str = "ryo_vm_register";

/// The stack probe of large frames, in `ryo_rt` (before mangling).
pub const PROBE_SYMBOL: &str = "ryo_probe_stack";
/// `ryo_rt`'s language handler of VM code's PE unwind info (design/vm.md#unwinding).
pub const SEH_HANDLER_SYMBOL: &str = "ryo_seh_handler";

/// The no-op JIT's trip entry points in `ryo_rt`, which the JIT records' slots start at
/// (before mangling).
pub const TRIP_ENTRY_SYMBOL: &str = "ryo_jit_trip_entry";
pub const TRIP_OSR_SYMBOL: &str = "ryo_jit_trip_osr";

/// The name of opcode `op`'s handler in `ryo_rt` (before mangling).
pub fn handler_name(op: Opcode) -> String {
    format!("ryo_h_{op:?}")
}

/// The name of opcode `op`'s register entry in `ryo_rt` (JIT code only; before mangling).
pub fn reg_handler_name(op: Opcode) -> String {
    format!("ryo_hr_{op:?}")
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
    fn local_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64) {
        obj.add_symbol(defined(name, section, offset, size, SymbolKind::Text, SymbolScope::Compilation));
    }
    /// The global symbol of a VM function that native code calls by name.
    fn global_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64, sym: FuncSymbol);
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
    /// The section of an image object's registration entry: one pointer to its header, in
    /// the link unit's entry list (design/backend.md#pipeline), kept by linker GC.
    fn entry_section(&self, obj: &mut Object<'static>) -> object::write::SectionId;
    /// The registry stub's part: a null entry of the entry list (so the list exists in every
    /// link unit), and a constructor that calls `register` (`ryo_vm_register`'s symbol) as
    /// `(start, end, anchor)` with the list's bounds and the registry anchor `anchor`. With
    /// `register_import`, `register` is in another DLL and is called through its import slot.
    /// With `register_hidden` (ELF), the reference is hidden, so the linker binds it to the
    /// link unit's own `ryo_rt` (which it then doesn't export).
    fn add_registry_ctor(&self, obj: &mut Object<'static>, register: &str, anchor: &str, register_import: bool, register_hidden: bool);
    /// Defines the hidden registry anchor `name`, such that several stubs in one link (two
    /// ryo staticlibs in a C program) don't clash: weak, or a COMDAT on PE.
    fn define_anchor(&self, obj: &mut Object<'static>, name: &str) {
        let anchor = self.data_section(obj, "ryo_registry_anchor");
        obj.append_section_data(anchor, &[0], 1);
        let id = self.hidden_global(obj, name, anchor, 0, 1, SymbolKind::Data);
        obj.symbol_mut(id).weak = true;
    }
    /// The object-file name of the symbol `name` (as rustc names it): Mach-O prepends `_`.
    fn mangle(&self, name: &str) -> String {
        name.to_owned()
    }
    /// The symbol a relocation against the start of `section` uses.
    fn section_target(&self, obj: &mut Object<'static>, section: object::write::SectionId) -> SymbolId {
        obj.section_symbol(section)
    }
    /// Whether the PC-relative fields of `.eh_frame` are written without relocations, and the
    /// personality as a GOT reference to its symbol (Mach-O, [`write_image`]).
    fn implicit_eh_frame(&self) -> bool {
        false
    }
}

/// The format for a target's binary format, or an error for formats not implemented yet.
/// `macos_min` is the deployment target of Mach-O objects, `xxxx.yy.zz` in nibbles
/// (`object::write::MachOBuildVersion::minos`); other formats ignore it.
pub fn format_for(binary_format: BinaryFormat, macos_min: u32) -> Result<Box<dyn ObjectFormat>, String> {
    match binary_format {
        BinaryFormat::Elf => Ok(Box::new(Elf)),
        BinaryFormat::Coff => Ok(Box::new(Coff)),
        BinaryFormat::MachO => Ok(Box::new(MachO { macos_min })),
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
                RelocKind::Pc64 => elf::R_X86_64_PC64,
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

    fn global_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64, sym: FuncSymbol) {
        let (scope, st_other) = match sym.visibility {
            SymVisibility::Default => (SymbolScope::Dynamic, elf::STV_DEFAULT),
            SymVisibility::Hidden => (SymbolScope::Linkage, elf::STV_HIDDEN),
            SymVisibility::Protected => (SymbolScope::Dynamic, elf::STV_PROTECTED),
        };
        let bind = if sym.weak { elf::STB_WEAK } else { elf::STB_GLOBAL };
        obj.add_symbol(Symbol {
            weak: sym.weak,
            flags: SymbolFlags::Elf { st_info: (bind << 4) | elf::STT_FUNC, st_other },
            ..defined(name, section, offset, size, SymbolKind::Text, scope)
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
            flags: SymbolFlags::Elf { st_info: (elf::STB_GLOBAL << 4) | elf_type(kind), st_other: elf::STV_HIDDEN },
            ..defined(name, section, offset, size, kind, SymbolScope::Linkage)
        })
    }

    fn import_slot(&self, name: &str) -> Result<String, String> {
        Err(format!("indirect symbol `{name}` in an ELF image (indirect slots are PE-only)"))
    }

    fn entry_section(&self, obj: &mut Object<'static>) -> object::write::SectionId {
        // A C-identifier name, so the linker defines `__start_`/`__stop_` bounds; retained, as
        // lld (>= 13, `-z start-stop-gc`) doesn't keep a section for its bounds' references.
        let s = obj.add_section(Vec::new(), elf_entries().into_bytes(), SectionKind::Data);
        obj.section_mut(s).flags = SectionFlags::Elf { sh_flags: u64::from(elf::SHF_ALLOC | elf::SHF_WRITE | elf::SHF_GNU_RETAIN) };
        s
    }

    fn define_anchor(&self, obj: &mut Object<'static>, name: &str) {
        let anchor = self.data_section(obj, "ryo_registry_anchor");
        obj.append_section_data(anchor, &[0], 1);
        obj.add_symbol(Symbol {
            weak: true,
            flags: SymbolFlags::Elf { st_info: (elf::STB_WEAK << 4) | elf::STT_OBJECT, st_other: elf::STV_HIDDEN },
            ..defined(name, anchor, 0, 1, SymbolKind::Data, SymbolScope::Linkage)
        });
    }

    fn add_registry_ctor(&self, obj: &mut Object<'static>, register: &str, anchor: &str, _register_import: bool, register_hidden: bool) {
        let entries = self.entry_section(obj);
        obj.append_section_data(entries, &[0; 8], 8);
        // The dynamic linker resolves the PLT entry if `ryo_rt` is in a shared object. A
        // hidden reference binds to this link unit's own `ryo_rt` at link time.
        // lea rdi, [rip + __start_ryo_images_<tag>]; lea rsi, [rip + __stop_ryo_images_<tag>];
        // lea rdx, [rip + anchor]; jmp ryo_vm_register
        let code = [0x48, 0x8d, 0x3d, 0, 0, 0, 0, 0x48, 0x8d, 0x35, 0, 0, 0, 0, 0x48, 0x8d, 0x15, 0, 0, 0, 0, 0xe9, 0, 0, 0, 0];
        let text = obj.add_section(obj.segment_name(StandardSegment::Text).to_vec(), b".text.ryo_registry".to_vec(), SectionKind::Text);
        obj.append_section_data(text, &code, 16);
        // Hidden, so each link unit (executable or shared object) walks its own list.
        let bound = |obj: &mut Object<'static>, name: String| {
            obj.add_symbol(Symbol {
                flags: SymbolFlags::Elf { st_info: elf::STB_GLOBAL << 4, st_other: elf::STV_HIDDEN },
                ..undefined_symbol(&name, SymbolKind::Unknown)
            })
        };
        let start = bound(obj, format!("__start_{}", elf_entries()));
        let stop = bound(obj, format!("__stop_{}", elf_entries()));
        let anchor = obj.symbol_id(anchor.as_bytes()).expect("the anchor is defined first");
        let register = if register_hidden { bound(obj, register.to_owned()) } else { undefined(obj, register, SymbolKind::Text) };
        let rel = |offset, symbol, r_type| Relocation { offset, symbol, addend: -4, flags: RelocationFlags::Elf { r_type } };
        obj.add_relocation(text, rel(3, start, elf::R_X86_64_PC32)).unwrap();
        obj.add_relocation(text, rel(10, stop, elf::R_X86_64_PC32)).unwrap();
        obj.add_relocation(text, rel(17, anchor, elf::R_X86_64_PC32)).unwrap();
        obj.add_relocation(text, rel(22, register, elf::R_X86_64_PLT32)).unwrap();
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
                RelocKind::Pc64 => unreachable!("no .eh_frame on PE"),
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

    fn global_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64, _sym: FuncSymbol) {
        // PE has no symbol visibility: a DLL exports what its export list names (rustc's
        // `/EXPORT` directives). A weak definition would need a comdat; VM functions never
        // have weak linkage (`vm_fn_sig` keeps functions with such a `#[linkage]` native).
        obj.add_symbol(defined(name, section, offset, size, SymbolKind::Text, SymbolScope::Dynamic));
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
        obj.add_symbol(defined(name, section, offset, size, kind, SymbolScope::Linkage))
    }

    fn import_slot(&self, name: &str) -> Result<String, String> {
        // x86_64 has no `_` decoration, so the import slot is `__imp_` + the symbol name
        // (`rustc_codegen_llvm/src/back/write.rs:1326`, `create_msvc_imps`).
        Ok(format!("__imp_{name}"))
    }

    fn entry_section(&self, obj: &mut Object<'static>) -> object::write::SectionId {
        // Grouped: the linker sorts `.ryo$*` by suffix, so the entries (`$<tag>m`) sit between
        // the stub's markers (`$<tag>a`, `$<tag>z`), as the CRT's `.CRT$XC*`, and apart from
        // other tags'. Not a COMDAT, so `/OPT:REF` keeps it.
        coff_entries(obj, "m")
    }

    fn add_registry_ctor(&self, obj: &mut Object<'static>, register: &str, anchor: &str, register_import: bool, _register_hidden: bool) {
        let start = coff_entries(obj, "a");
        obj.append_section_data(start, &[0; 8], 8);
        let end = coff_entries(obj, "z");
        obj.append_section_data(end, &[0; 8], 8);
        // Win64: the first three arguments are in rcx, rdx and r8. The tail jump leaves rsp
        // alone, so this is a leaf function and needs no unwind info (no `.pdata`).
        // lea rcx, [rip + .ryo$<tag>a]; lea rdx, [rip + .ryo$<tag>z]; lea r8, [rip + anchor];
        // jmp ryo_vm_register / jmp [rip + __imp_ryo_vm_register]
        let mut code = vec![0x48, 0x8d, 0x0d, 0, 0, 0, 0, 0x48, 0x8d, 0x15, 0, 0, 0, 0, 0x4c, 0x8d, 0x05, 0, 0, 0, 0];
        let target = if register_import {
            code.extend_from_slice(&[0xff, 0x25, 0, 0, 0, 0]);
            undefined(obj, &format!("__imp_{register}"), SymbolKind::Data)
        } else {
            code.extend_from_slice(&[0xe9, 0, 0, 0, 0]);
            undefined(obj, register, SymbolKind::Text)
        };
        let anchor = obj.symbol_id(anchor.as_bytes()).expect("the anchor is defined first");
        let target_at = code.len() as u64 - 4;
        let text = obj.add_section(Vec::new(), b".text$ryo_registry".to_vec(), SectionKind::Text);
        obj.append_section_data(text, &code, 16);
        let start_sym = obj.section_symbol(start);
        let end_sym = obj.section_symbol(end);
        // `object` turns the addend into COFF's implicit one (REL32 is relative to the end of
        // the field, so -4 becomes 0).
        let rel = |offset, symbol| Relocation { offset, symbol, addend: -4, flags: RelocationFlags::Coff { typ: pe::IMAGE_REL_AMD64_REL32 } };
        obj.add_relocation(text, rel(3, start_sym)).unwrap();
        obj.add_relocation(text, rel(10, end_sym)).unwrap();
        obj.add_relocation(text, rel(17, anchor)).unwrap();
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

    fn define_anchor(&self, obj: &mut Object<'static>, name: &str) {
        // A weak definition needs a COMDAT on PE; any copy will do.
        let anchor = obj.add_section(Vec::new(), b".data$ryo_registry_anchor".to_vec(), SectionKind::Data);
        obj.append_section_data(anchor, &[0], 1);
        // A COMDAT section needs its section symbol (`object`'s COFF writer).
        obj.section_symbol(anchor);
        let symbol = self.hidden_global(obj, name, anchor, 0, 1, SymbolKind::Data);
        obj.add_comdat(object::write::Comdat { kind: object::ComdatKind::Any, symbol, sections: vec![anchor] });
    }
}

/// Mach-O (x86_64-apple-darwin). Symbols get the `_` prefix ([`ObjectFormat::mangle`]; the
/// `object` crate's own mangling is off, as it skips symbols of unknown kind). Relocations are
/// extern: the `object` crate writes implicit addends without the target section's address,
/// which non-extern (section-numbered) ones would need, so relocations against a section use a
/// local symbol at its start. The code's fields are `X86_64_RELOC_SIGNED` (an ELF addend of -4
/// is a field of 0; extern relocations add the field arithmetically, so an immediate after the
/// field needs no `SIGNED_1`), its calls `X86_64_RELOC_BRANCH` (through a stub if the target is
/// in a dylib), data pointers `X86_64_RELOC_UNSIGNED`. `__eh_frame` is written as LLVM writes
/// it ([`ObjectFormat::implicit_eh_frame`]). The objects don't set
/// `MH_SUBSECTIONS_VIA_SYMBOLS`: the image's code calls between functions without
/// relocations, so each section must stay in one piece (one atom, for ld64).
pub struct MachO {
    /// `LC_BUILD_VERSION`'s `minos` (ld64 warns about objects without the command).
    pub macos_min: u32,
}

impl MachO {
    fn section(obj: &mut Object<'static>, segment: &str, name: &str, kind: SectionKind) -> object::write::SectionId {
        assert!(name.len() <= 16, "Mach-O section name `{name}` is too long");
        obj.add_section(segment.as_bytes().to_vec(), name.as_bytes().to_vec(), kind)
    }
}

impl ObjectFormat for MachO {
    fn new_object(&self) -> Object<'static> {
        let mut obj = Object::new(BinaryFormat::MachO, Architecture::X86_64, Endianness::Little);
        obj.set_mangling(Mangling::None);
        let mut version = object::write::MachOBuildVersion::default();
        version.platform = macho::PLATFORM_MACOS;
        version.minos = self.macos_min;
        obj.set_macho_build_version(version);
        obj
    }

    fn reloc(&self, kind: RelocKind) -> RelocationFlags {
        let (r_type, r_pcrel, r_length) = match kind {
            RelocKind::Abs64 => (macho::X86_64_RELOC_UNSIGNED, false, 3),
            RelocKind::Pc32 => (macho::X86_64_RELOC_SIGNED, true, 2),
            RelocKind::Call32 => (macho::X86_64_RELOC_BRANCH, true, 2),
            RelocKind::Rva32 => unreachable!("no image-relative relocations on Mach-O"),
            RelocKind::Pc64 => unreachable!("`__eh_frame` pointers have no relocations on Mach-O"),
        };
        RelocationFlags::MachO { r_type, r_pcrel, r_length }
    }

    fn text_section(&self, obj: &mut Object<'static>) -> object::write::SectionId {
        Self::section(obj, "__TEXT", "__text", SectionKind::Text)
    }

    fn unwind_section(&self, obj: &mut Object<'static>, which: Section) -> object::write::SectionId {
        match which {
            Section::EhFrame => {
                // As LLVM and ld64 have it: coalesced, kept live with the code it describes.
                let s = Self::section(obj, "__TEXT", "__eh_frame", SectionKind::ReadOnlyData);
                let flags = macho::S_COALESCED | macho::S_ATTR_NO_TOC | macho::S_ATTR_STRIP_STATIC_SYMS | macho::S_ATTR_LIVE_SUPPORT;
                obj.section_mut(s).flags = SectionFlags::MachO { flags };
                s
            }
            Section::Lsda => Self::section(obj, "__TEXT", "__gcc_except_tab", SectionKind::ReadOnlyData),
            _ => unreachable!("not a Mach-O unwind section"),
        }
    }

    fn global_function(&self, obj: &mut Object<'static>, name: &str, section: object::write::SectionId, offset: u64, size: u64, sym: FuncSymbol) {
        // Hidden is `N_PEXT` (private extern); a weak definition `N_WEAK_DEF`. Mach-O has no
        // protected visibility: such a symbol is exported as a default one.
        let scope = match sym.visibility {
            SymVisibility::Default | SymVisibility::Protected => SymbolScope::Dynamic,
            SymVisibility::Hidden => SymbolScope::Linkage,
        };
        obj.add_symbol(Symbol { weak: sym.weak, ..defined(name, section, offset, size, SymbolKind::Text, scope) });
    }

    fn relro_section(&self, obj: &mut Object<'static>, name: &str) -> object::write::SectionId {
        // `__DATA,__const` (ld64 moves it to `__DATA_CONST`, read-only after the fixups) for
        // the image, the first such section of its object; the small
        // slots of the image object get sections of their own in `__DATA`, as an object
        // must not have two sections of the same name.
        let sect = if name == "ryo_image" { "__const".to_owned() } else { format!("__{name}") };
        Self::section(obj, "__DATA", &sect, SectionKind::ReadOnlyDataWithRel)
    }

    fn data_section(&self, obj: &mut Object<'static>, _name: &str) -> object::write::SectionId {
        // At most one per object: the image's writable section, or the registry anchor.
        Self::section(obj, "__DATA", "__data", SectionKind::Data)
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
        // `N_PEXT`: global in the link unit, not exported.
        obj.add_symbol(defined(name, section, offset, size, kind, SymbolScope::Linkage))
    }

    fn import_slot(&self, name: &str) -> Result<String, String> {
        Err(format!("indirect symbol `{name}` in a Mach-O image (indirect slots are PE-only)"))
    }

    fn entry_section(&self, obj: &mut Object<'static>) -> object::write::SectionId {
        // `S_ATTR_NO_DEAD_STRIP` against `-dead_strip`.
        let s = Self::section(obj, "__DATA", &macho_entries(), SectionKind::Data);
        obj.section_mut(s).flags = SectionFlags::MachO { flags: macho::S_REGULAR | macho::S_ATTR_NO_DEAD_STRIP };
        s
    }

    fn add_registry_ctor(&self, obj: &mut Object<'static>, register: &str, anchor: &str, _register_import: bool, _register_hidden: bool) {
        let entries = self.entry_section(obj);
        obj.append_section_data(entries, &[0; 8], 8);
        // As on ELF, with the bounds ld64 and lld define for `section$start$<seg>$<sect>`;
        // ld64 adds a stub if `ryo_rt` is in a dylib.
        // lea rdi, [rip + start]; lea rsi, [rip + end]; lea rdx, [rip + anchor];
        // jmp _ryo_vm_register
        let code = [0x48, 0x8d, 0x3d, 0, 0, 0, 0, 0x48, 0x8d, 0x35, 0, 0, 0, 0, 0x48, 0x8d, 0x15, 0, 0, 0, 0, 0xe9, 0, 0, 0, 0];
        let text = self.text_section(obj);
        obj.append_section_data(text, &code, 16);
        let start = undefined(obj, &format!("section$start$__DATA${}", macho_entries()), SymbolKind::Data);
        let end = undefined(obj, &format!("section$end$__DATA${}", macho_entries()), SymbolKind::Data);
        let anchor = obj.symbol_id(anchor.as_bytes()).expect("the anchor is defined first");
        let register = undefined(obj, &self.mangle(register), SymbolKind::Text);
        let rel = |offset, symbol, kind| Relocation { offset, symbol, addend: -4, flags: self.reloc(kind) };
        obj.add_relocation(text, rel(3, start, RelocKind::Pc32)).unwrap();
        obj.add_relocation(text, rel(10, end, RelocKind::Pc32)).unwrap();
        obj.add_relocation(text, rel(17, anchor, RelocKind::Pc32)).unwrap();
        obj.add_relocation(text, rel(22, register, RelocKind::Call32)).unwrap();
        // dyld runs an image's initializers in the order of `__mod_init_func`, after those of
        // the images it depends on (`ryo_rt`'s dylib, if it is one).
        let init = Self::section(obj, "__DATA", "__mod_init_func", SectionKind::Data);
        obj.section_mut(init).flags = SectionFlags::MachO { flags: macho::S_MOD_INIT_FUNC_POINTERS };
        obj.append_section_data(init, &[0; 8], 8);
        let ctor = self.section_target(obj, text);
        obj.add_relocation(init, Relocation { offset: 0, symbol: ctor, addend: 0, flags: self.abs64() }).unwrap();
    }

    fn mangle(&self, name: &str) -> String {
        format!("_{name}")
    }

    fn section_target(&self, obj: &mut Object<'static>, section: object::write::SectionId) -> SymbolId {
        // `l`: a linker-private local, which ld64 drops from the output. Section names are
        // unique in these objects.
        let name = format!("l{}", obj.section(section).name().unwrap_or("?"));
        if let Some(id) = obj.symbol_id(name.as_bytes()) {
            return id;
        }
        obj.add_symbol(Symbol {
            name: name.into_bytes(),
            value: 0,
            size: 0,
            // Text or Data, so `symbol_id` finds it.
            kind: if obj.section(section).name() == Some("__text") { SymbolKind::Text } else { SymbolKind::Data },
            scope: SymbolScope::Compilation,
            weak: false,
            section: SymbolSection::Section(section),
            flags: SymbolFlags::None,
        })
    }

    fn implicit_eh_frame(&self) -> bool {
        true
    }
}

fn elf_type(kind: SymbolKind) -> u8 {
    match kind {
        SymbolKind::Text => elf::STT_FUNC,
        SymbolKind::Data => elf::STT_OBJECT,
        _ => elf::STT_NOTYPE,
    }
}

/// A symbol defined at `offset` in `section`, strong and without format-specific flags.
fn defined(name: &str, section: object::write::SectionId, offset: u64, size: u64, kind: SymbolKind, scope: SymbolScope) -> Symbol {
    Symbol {
        name: name.as_bytes().to_vec(),
        value: offset,
        size,
        kind,
        scope,
        weak: false,
        section: SymbolSection::Section(section),
        flags: SymbolFlags::None,
    }
}

/// An undefined (external) symbol reference, added once per name.
fn undefined(obj: &mut Object<'static>, name: &str, kind: SymbolKind) -> SymbolId {
    if let Some(id) = obj.symbol_id(name.as_bytes()) {
        return id;
    }
    obj.add_symbol(undefined_symbol(name, kind))
}

fn undefined_symbol(name: &str, kind: SymbolKind) -> Symbol {
    Symbol {
        name: name.as_bytes().to_vec(),
        value: 0,
        size: 0,
        kind,
        scope: SymbolScope::Unknown,
        weak: false,
        section: SymbolSection::Undefined,
        flags: SymbolFlags::None,
    }
}

/// The ELF section of the registration entries, `ryo_images_<tag>` (`__start_ryo_images_<tag>`
/// …): per ABI tag, so that a stub registers only its own build's images
/// (design/build.md#the-abi-tag).
fn elf_entries() -> String {
    format!("ryo_images_{}", ryo_bytecode::ABI_TAG)
}

/// The Mach-O section (in `__DATA`) of the registration entries, `__ryo_<tag>`: section names
/// have at most 16 bytes, so the tag is cut to its first 10 characters (a collision of two
/// builds is caught by the header's `abi` check).
fn macho_entries() -> String {
    let tag = ryo_bytecode::ABI_TAG;
    format!("__ryo_{}", &tag[..tag.len().min(10)])
}

/// The PE section `.ryo$<tag><suffix>` of the registration entries or the stub's markers.
fn coff_entries(obj: &mut Object<'static>, suffix: &str) -> object::write::SectionId {
    obj.add_section(Vec::new(), format!(".ryo${}{suffix}", ryo_bytecode::ABI_TAG).into_bytes(), SectionKind::ReadOnlyData)
}

/// The image object: the image sections, `__ryo_image_<id>_<cgu>` at the start of the
/// read-only one, a symbol per VM function (global for those native code calls by name), its
/// registration entry (a pointer to the header), a reference to the registry anchor, and, for binaries with a VM `main`, the `__ryo_main` slot
/// pointing at `main_symbol`. `rt_symbol` names `ryo_rt`'s handlers (`ryo_h_<op>`) and
/// `ryo_probe_stack`, as rustc mangles them.
pub fn write_image(
    fmt: &dyn ObjectFormat,
    image: &ImageObject,
    stable_crate_id: u64,
    cgu_hash: u64,
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
        let name = fmt.mangle(&f.name);
        match f.symbol {
            Some(sym) => fmt.global_function(&mut obj, &name, text, f.start as u64, f.len as u64, sym),
            None => fmt.local_function(&mut obj, &name, text, f.start as u64, f.len as u64),
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
        Section::EhFrame | Section::Lsda | Section::Pdata | Section::Xdata => unwind.iter().find(|u| u.0 == s).expect("unwind section").1,
    };
    fmt.hidden_global(&mut obj, &fmt.mangle(&image_symbol(stable_crate_id, cgu_hash)), ro, 0, image.rodata.len() as u64, SymbolKind::Data);

    // Indirect slots relocate against the import slot (design/platforms.md). The writer only
    // relocates against indirect symbols from their slots (constants pointing at them are
    // fixups), so every relocation against them is a slot's.
    let syms = image
        .symbols
        .iter()
        .map(|s| {
            // `\x01`: the name verbatim, as LLVM has it (no Mach-O `_`).
            let (name, verbatim) = match s.name.strip_prefix('\x01') {
                Some(n) => (n, true),
                None => (&s.name[..], false),
            };
            let name = if s.flags & SYM_INDIRECT != 0 {
                fmt.mangle(&fmt.import_slot(name)?)
            } else if verbatim {
                name.to_owned()
            } else {
                fmt.mangle(name)
            };
            Ok(undefined(&mut obj, &name, SymbolKind::Unknown))
        })
        .collect::<Result<Vec<SymbolId>, String>>()?;
    let rt = |name: &str| fmt.mangle(&rt_symbol(name));
    // Handler symbols, by opcode: most relocations are handler calls.
    let mut handlers: Vec<Option<SymbolId>> = vec![None; ryo_bytecode::full::ALL_OPCODES.len()];
    let (mut trip_entry, mut trip_osr, mut seh_handler) = (None, None, None);
    // Mach-O's `.eh_frame` fields without relocations: (offset, target section, addend, size).
    let mut implicit = Vec::new();
    for r in &image.relocs {
        if fmt.implicit_eh_frame() && r.section == Section::EhFrame {
            let eh = section(Section::EhFrame);
            match r.target {
                // The CIE's personality, through the slot in the read-only section: on Mach-O
                // a GOT reference to the personality itself, as LLVM writes it (ld64 takes
                // the personality from it).
                RelocTarget::Section(Section::ReadOnly) => {
                    let personality = undefined(&mut obj, &fmt.mangle(ryo_bytecode::image::PERSONALITY), SymbolKind::Text);
                    let flags = RelocationFlags::MachO { r_type: macho::X86_64_RELOC_GOT, r_pcrel: true, r_length: 2 };
                    obj.add_relocation(eh, Relocation { offset: r.offset, symbol: personality, addend: 0, flags })
                        .map_err(|e| format!("image relocation: {e}"))?;
                }
                // The FDEs' first address and LSDA: the linker finds them by address.
                RelocTarget::Section(t) if matches!(r.kind, RelocKind::Pc32 | RelocKind::Pc64) => {
                    implicit.push((r.offset, t, r.addend, if r.kind == RelocKind::Pc64 { 8 } else { 4 }))
                }
                _ => return Err(format!("unexpected .eh_frame relocation {r:?}")),
            }
            continue;
        }
        let symbol = match r.target {
            RelocTarget::Symbol(s) => syms[s.0 as usize],
            RelocTarget::Section(s) => fmt.section_target(&mut obj, section(s)),
            RelocTarget::Handler(op) => *handlers[op as usize].get_or_insert_with(|| undefined(&mut obj, &rt(&handler_name(op)), SymbolKind::Text)),
            RelocTarget::Probe => undefined(&mut obj, &rt(PROBE_SYMBOL), SymbolKind::Text),
            RelocTarget::TripEntry => *trip_entry.get_or_insert_with(|| undefined(&mut obj, &rt(TRIP_ENTRY_SYMBOL), SymbolKind::Text)),
            RelocTarget::TripOsr => *trip_osr.get_or_insert_with(|| undefined(&mut obj, &rt(TRIP_OSR_SYMBOL), SymbolKind::Text)),
            RelocTarget::SehHandler => *seh_handler.get_or_insert_with(|| undefined(&mut obj, &rt(SEH_HANDLER_SYMBOL), SymbolKind::Text)),
        };
        obj.add_relocation(section(r.section), Relocation { offset: r.offset, symbol, addend: r.addend, flags: fmt.reloc(r.kind) })
            .map_err(|e| format!("image relocation: {e}"))?;
    }

    // The registration entry: the stub's constructor registers every image in its link
    // unit's list (design/backend.md#pipeline).
    let entry = fmt.entry_section(&mut obj);
    obj.append_section_data(entry, &[0; 8], 8);
    let header = fmt.section_target(&mut obj, ro);
    obj.add_relocation(entry, Relocation { offset: 0, symbol: header, addend: 0, flags: fmt.abs64() })
        .map_err(|e| format!("registration entry relocation: {e}"))?;

    // A reference to the registry stub of the link unit, so that a C linker taking the image
    // out of a staticlib takes the stub too, in the header's `anchor` field, which
    // registration compares with the stub's anchor (design/backend.md#pipeline).
    let anchor = undefined(&mut obj, &fmt.mangle(&anchor_symbol()), SymbolKind::Data);
    let at = std::mem::offset_of!(ryo_bytecode::image::Header, anchor) as u64;
    obj.add_relocation(ro, Relocation { offset: at, symbol: anchor, addend: 0, flags: fmt.abs64() })
        .map_err(|e| format!("registry anchor relocation: {e}"))?;

    if let Some(main) = main_symbol {
        let slot = fmt.relro_section(&mut obj, "ryo_main");
        obj.append_section_data(slot, &[0; 8], 8);
        fmt.hidden_global(&mut obj, &fmt.mangle(MAIN_SLOT_SYMBOL), slot, 0, 8, SymbolKind::Data);
        let target = undefined(&mut obj, &fmt.mangle(main), SymbolKind::Text);
        obj.add_relocation(slot, Relocation { offset: 0, symbol: target, addend: 0, flags: fmt.abs64() })
            .map_err(|e| format!("__ryo_main relocation: {e}"))?;
    }
    let names = |s: Section| obj.section(section(s)).name().unwrap_or_default().to_owned();
    let implicit: Vec<_> = implicit.into_iter().map(|(offset, t, addend, size)| (offset, names(t), addend, size)).collect();
    let eh_name = if implicit.is_empty() { String::new() } else { names(Section::EhFrame) };
    let mut bytes = obj.write().map_err(|e| format!("writing the image object: {e}"))?;
    if !implicit.is_empty() {
        patch_by_address(&mut bytes, &eh_name, &implicit)?;
    }
    Ok(bytes)
}

/// Writes the PC-relative fields of section `eh` of the written Mach-O object `bytes` that
/// have no relocations, as LLVM does for `__eh_frame`: each `(offset, target, addend, size)`
/// is `size` bytes of the address of section `target` plus `addend`, less the field's own
/// address, all in the object's own addresses (from which the linker recovers the targets).
fn patch_by_address(bytes: &mut [u8], eh: &str, fields: &[(u64, String, i64, u64)]) -> Result<(), String> {
    use object::read::{Object as _, ObjectSection as _};
    let file = object::read::macho::MachOFile64::<Endianness>::parse(&*bytes).map_err(|e| format!("reading back the image object: {e}"))?;
    let find = |name: &str| {
        file.sections()
            .find(|s| s.name() == Ok(name))
            .map(|s| (s.address(), s.file_range()))
            .ok_or_else(|| format!("no section {name} in the image object"))
    };
    let (eh_addr, eh_range) = find(eh)?;
    let (eh_off, eh_size) = eh_range.ok_or("no file data for the unwind section")?;
    let mut patches = Vec::new();
    for (offset, target, addend, size) in fields {
        let (addr, _) = find(target)?;
        let value = (addr as i64 + addend) - (eh_addr + offset) as i64;
        if *size == 4 && i32::try_from(value).is_err() {
            return Err("unwind field out of range".to_owned());
        }
        assert!(offset + size <= eh_size);
        patches.push((eh_off + offset, value, *size as usize));
    }
    for (at, value, size) in patches {
        bytes[at as usize..at as usize + size].copy_from_slice(&value.to_le_bytes()[..size]);
    }
    Ok(())
}

/// The registry stub of one final link: the same for every crate. A constructor registering
/// the link unit's entry list (each image object's entry), and the hidden
/// `__ryo_registry_anchor_<tag>`. `register_import`, `register_hidden`: see
/// [`ObjectFormat::add_registry_ctor`].
pub fn write_registry(fmt: &dyn ObjectFormat, register: &str, register_import: bool, register_hidden: bool) -> Result<Vec<u8>, String> {
    let mut obj = fmt.new_object();
    let anchor = fmt.mangle(&anchor_symbol());
    fmt.define_anchor(&mut obj, &anchor);
    fmt.add_registry_ctor(&mut obj, register, &anchor, register_import, register_hidden);
    obj.write().map_err(|e| format!("writing the registry object: {e}"))
}

#[cfg(test)]
mod tests {
    //! The Mach-O objects, read back with `object` (design/platforms.md). Nothing links or
    //! runs them here.
    use object::read::macho::MachOFile64;
    use object::read::{Object as _, ObjectSection as _, ObjectSymbol as _, RelocationTarget};
    use object::{Endianness, RelocationFlags, SymbolScope, macho};
    use ryo_bytecode::asm::Mode;
    use ryo_bytecode::full::{CodeBuf, Insn, List, Slot};
    use ryo_bytecode::image::{FuncSymbol, FunctionDef, ImageObject, ImageWriter, RelocKind, RelocTarget, Section, SymVisibility};

    use super::*;

    const SCID: u64 = 0x0123_4567_89ab_cdef;
    const CGU: u64 = 0xfedc_ba98_7654_3210;
    const MODE: Mode = Mode { fp_arg: true, frame_pointer: true, align_loops: true, pe: false, counters: true, far_rt: false };

    fn fmt() -> MachO {
        MachO { macos_min: 0x000a_0c00 }
    }

    /// Two functions, one global and one local, calling a symbol.
    fn image() -> ImageObject {
        let mut w = ImageWriter::new(SCID);
        w.set_eh_pointers(ryo_bytecode::image::EhPointers::Abs8);
        let ext = w.symbol("ext_fn", 0);
        let mut c = CodeBuf::default();
        c.emit(&Insn::CallSym { d: Slot(-16), sym: ext, k: 8, a: List::from_words(&[]) });
        c.emit(&Insn::Ret { s: Slot(0), k: 0 });
        let def = |name: &str, code, frame_size, symbol| FunctionDef { name: name.into(), code, frame_size, symbol, ..Default::default() };
        w.add_function(def(
            "_ZN3foo3bar17h0123456789abcdefE",
            c.words.clone(),
            16,
            Some(FuncSymbol { visibility: SymVisibility::Default, weak: false }),
        ));
        // A frame this large calls the stack probe.
        w.add_function(def("_ZN3foo5local17h0123456789abcdefE", c.words, 8192, None));
        w.finish(MODE).expect("image")
    }

    fn rt(name: &str) -> String {
        format!("rt_{name}")
    }

    /// The written image object, read back.
    fn written(img: &ImageObject) -> Vec<u8> {
        write_image(&fmt(), img, SCID, CGU, Some("main_fn"), &rt).expect("write_image")
    }

    fn section<'a>(file: &'a MachOFile64<'a, Endianness>, name: &str) -> object::read::macho::MachOSection64<'a, 'a, Endianness> {
        file.sections().find(|s| s.name() == Ok(name)).unwrap_or_else(|| panic!("no section {name}"))
    }

    fn le32(data: &[u8], at: u64) -> i32 {
        i32::from_le_bytes(data[at as usize..at as usize + 4].try_into().unwrap())
    }

    fn le64(data: &[u8], at: u64) -> i64 {
        i64::from_le_bytes(data[at as usize..at as usize + 8].try_into().unwrap())
    }

    #[test]
    fn image_sections_and_symbols() {
        let img = image();
        let bytes = written(&img);
        let file = MachOFile64::<Endianness>::parse(&*bytes).unwrap();
        assert_eq!(file.architecture(), object::Architecture::X86_64);
        let segs: Vec<_> = file.sections().map(|s| (s.segment_name().unwrap().unwrap().to_owned(), s.name().unwrap().to_owned())).collect();
        for want in [
            ("__DATA", "__const"),
            ("__DATA", "__data"),
            ("__TEXT", "__text"),
            ("__TEXT", "__eh_frame"),
            ("__TEXT", "__gcc_except_tab"),
            ("__DATA", "__ryo_main"),
            ("__DATA", &macho_entries()),
        ] {
            assert!(segs.contains(&(want.0.to_owned(), want.1.to_owned())), "missing {want:?} in {segs:?}");
        }
        let eh = section(&file, "__eh_frame");
        let object::SectionFlags::MachO { flags } = eh.flags() else { panic!() };
        assert_eq!(flags, macho::S_COALESCED | macho::S_ATTR_NO_TOC | macho::S_ATTR_STRIP_STATIC_SYMS | macho::S_ATTR_LIVE_SUPPORT);
        let text = section(&file, "__text");
        let object::SectionFlags::MachO { flags } = text.flags() else { panic!() };
        assert_eq!(flags, macho::S_ATTR_PURE_INSTRUCTIONS | macho::S_ATTR_SOME_INSTRUCTIONS);

        let sym = |name: &str| file.symbols().find(|s| s.name() == Ok(name)).unwrap_or_else(|| panic!("no symbol {name}"));
        let global = sym("__ZN3foo3bar17h0123456789abcdefE");
        assert_eq!((global.scope(), global.address()), (SymbolScope::Dynamic, text.address() + img.functions[0].start as u64));
        let local = sym("__ZN3foo5local17h0123456789abcdefE");
        assert_eq!((local.scope(), local.address()), (SymbolScope::Compilation, text.address() + img.functions[1].start as u64));
        let image = sym(&format!("_{}", image_symbol(SCID, CGU)));
        assert_eq!((image.scope(), image.address()), (SymbolScope::Linkage, section(&file, "__const").address()));
        // The registration entry: kept against `-dead_strip`, pointing at the header.
        let entries = section(&file, &macho_entries());
        let object::SectionFlags::MachO { flags } = entries.flags() else { panic!() };
        assert_eq!(flags, macho::S_REGULAR | macho::S_ATTR_NO_DEAD_STRIP);
        let rels: Vec<_> = entries.relocations().collect();
        assert_eq!(rels.len(), 1);
        assert_eq!(rels[0].0, 0);
        assert_eq!(rels[0].1.flags(), RelocationFlags::MachO { r_type: macho::X86_64_RELOC_UNSIGNED, r_pcrel: false, r_length: 3 });
        let RelocationTarget::Symbol(si) = rels[0].1.target() else { panic!() };
        assert_eq!(file.symbol_by_index(si).unwrap().address(), section(&file, "__const").address());
        assert_eq!(sym("___ryo_main").scope(), SymbolScope::Linkage);
        for undef in ["_ext_fn", "_main_fn", &format!("_{}", anchor_symbol()), "_rust_eh_personality"] {
            assert!(sym(undef).is_undefined(), "{undef}");
        }
        // The header's `anchor` field is relocated against it.
        let at = std::mem::offset_of!(ryo_bytecode::image::Header, anchor) as u64;
        let (_, r) = section(&file, "__const").relocations().find(|(o, _)| *o == at).expect("anchor relocation");
        let RelocationTarget::Symbol(si) = r.target() else { panic!() };
        assert_eq!(file.symbol_by_index(si).unwrap().name(), Ok(&*format!("_{}", anchor_symbol())));
        // Every symbol name carries the `_` prefix, the linker-private section starts `l`.
        for s in file.symbols() {
            let n = s.name().unwrap();
            assert!(n.starts_with('_') || n.starts_with("l__"), "{n}");
        }
        let flags = file.macho_header().flags.get(Endianness::Little);
        assert_eq!(flags & macho::MH_SUBSECTIONS_VIA_SYMBOLS, 0);
        let mut cmds = file.macho_load_commands().unwrap();
        let mut build = None;
        while let Some(c) = cmds.next().unwrap() {
            if let Ok(Some(v)) = c.build_version() {
                build = Some((v.platform.get(Endianness::Little), v.minos.get(Endianness::Little)));
            }
        }
        assert_eq!(build, Some((macho::PLATFORM_MACOS, 0x000a_0c00)));
    }

    /// Every image relocation outside `__eh_frame` becomes an extern relocation of the
    /// expected type at the same place, with the ELF addend as the implicit one (plus 4 for
    /// PC-relative fields), against a local symbol at the start of a target section.
    #[test]
    fn image_relocations() {
        let img = image();
        assert!(img.relocs.iter().any(|r| r.kind == RelocKind::Call32), "the test image calls no handler");
        assert!(img.relocs.iter().any(|r| r.kind == RelocKind::Pc32 && r.section == Section::Text));
        let bytes = written(&img);
        let file = MachOFile64::<Endianness>::parse(&*bytes).unwrap();
        let name = |s: Section| match s {
            Section::ReadOnly => "__const",
            Section::Writable => "__data",
            Section::Text => "__text",
            Section::EhFrame => "__eh_frame",
            Section::Lsda => "__gcc_except_tab",
            _ => unreachable!(),
        };
        for r in img.relocs.iter().filter(|r| r.section != Section::EhFrame) {
            let sec = section(&file, name(r.section));
            let (_, rel) = sec.relocations().find(|(o, _)| *o == r.offset).unwrap_or_else(|| panic!("no relocation for {r:?}"));
            let RelocationFlags::MachO { r_type, r_pcrel, r_length } = rel.flags() else { panic!() };
            let want = match r.kind {
                RelocKind::Abs64 => (macho::X86_64_RELOC_UNSIGNED, false, 3),
                RelocKind::Pc32 => (macho::X86_64_RELOC_SIGNED, true, 2),
                RelocKind::Call32 => (macho::X86_64_RELOC_BRANCH, true, 2),
                RelocKind::Rva32 | RelocKind::Pc64 => unreachable!(),
            };
            assert_eq!((r_type, r_pcrel, r_length), want, "{r:?}");
            let RelocationTarget::Symbol(si) = rel.target() else { panic!("non-extern relocation for {r:?}") };
            let target = file.symbol_by_index(si).unwrap();
            let target_name = target.name().unwrap();
            match r.target {
                RelocTarget::Section(t) => {
                    assert_eq!(target_name, format!("l{}", name(t)));
                    assert_eq!(target.address(), section(&file, name(t)).address());
                }
                RelocTarget::Symbol(s) => assert_eq!(target_name, format!("_{}", img.symbols[s.0 as usize].name)),
                RelocTarget::Handler(op) => assert_eq!(target_name, format!("_rt_{}", handler_name(op))),
                RelocTarget::Probe => assert_eq!(target_name, format!("_rt_{PROBE_SYMBOL}")),
                RelocTarget::TripEntry => assert_eq!(target_name, format!("_rt_{TRIP_ENTRY_SYMBOL}")),
                RelocTarget::TripOsr => assert_eq!(target_name, format!("_rt_{TRIP_OSR_SYMBOL}")),
                RelocTarget::SehHandler => unreachable!("PE only"),
            }
            let data = sec.data().unwrap();
            let field = if r_length == 3 { le64(data, r.offset) } else { le32(data, r.offset) as i64 };
            assert_eq!(field, r.addend + if r_pcrel { 4 } else { 0 }, "{r:?}");
        }
    }

    /// PE: every function's `UNWIND_INFO` in `.xdata` names `ryo_seh_handler` (an
    /// `IMAGE_REL_AMD64_ADDR32NB` relocation after its codes) and carries the handler data.
    #[test]
    fn pe_unwind_handler() {
        use object::read::coff::CoffFile;
        let mut w = ImageWriter::new(SCID);
        let ext = w.symbol("ext_fn", 0);
        let mut c = CodeBuf::default();
        c.emit(&Insn::CallSym { d: Slot(-16), sym: ext, k: 8, a: List::from_words(&[]) });
        c.emit(&Insn::Ret { s: Slot(0), k: 0 });
        let def = |name: &str| FunctionDef { name: name.into(), code: c.words.clone(), frame_size: 32, ..Default::default() };
        w.add_function(def("f"));
        w.add_function(def("g"));
        let img = w.finish(Mode { pe: true, ..MODE }).expect("image");
        let bytes = write_image(&Coff, &img, SCID, CGU, None, &rt).expect("write_image");
        let file = CoffFile::<&[u8]>::parse(&*bytes).unwrap();
        let xdata = file.sections().find(|s| s.name() == Ok(".xdata")).expect(".xdata");
        let data = xdata.data().unwrap();
        let mut handlers = Vec::new();
        for (at, rel) in xdata.relocations() {
            assert_eq!(rel.flags(), RelocationFlags::Coff { typ: object::pe::IMAGE_REL_AMD64_ADDR32NB });
            let RelocationTarget::Symbol(si) = rel.target() else { panic!() };
            handlers.push((at, file.symbol_by_index(si).unwrap().name().unwrap().to_owned()));
        }
        // Each function: its body's info (with the handler), its entry stub's (a leaf).
        assert_eq!(handlers.len(), 2, "{handlers:?}");
        for (at, name) in &handlers {
            assert_eq!(name, &format!("rt_{SEH_HANDLER_SYMBOL}"));
            // The handler data after the RVA: no region, an LSDA of the function's one call
            // site.
            let d = ryo_bytecode::image::PeHandlerData::parse(&data[*at as usize + 4..]).unwrap();
            assert_eq!((d.begin, d.region), (0, 0));
            assert!(ryo_bytecode::asm::lsda::find(d.lsda, 0).is_some());
        }
        // The flags of the first: UNW_FLAG_EHANDLER | UNW_FLAG_UHANDLER.
        assert_eq!(data[0], 1 | 3 << 3);
    }

    /// `__eh_frame` as LLVM writes it: the personality a GOT reference, the FDEs' first
    /// address and LSDA pointer without relocations, holding the targets' object addresses.
    #[test]
    fn image_unwind() {
        let img = image();
        let bytes = written(&img);
        let file = MachOFile64::<Endianness>::parse(&*bytes).unwrap();
        let eh = section(&file, "__eh_frame");
        let relocs: Vec<_> = eh.relocations().collect();
        assert_eq!(relocs.len(), 1, "{relocs:?}");
        let RelocationFlags::MachO { r_type, r_pcrel, r_length } = relocs[0].1.flags() else { panic!() };
        assert_eq!((r_type, r_pcrel, r_length), (macho::X86_64_RELOC_GOT, true, 2));
        let RelocationTarget::Symbol(si) = relocs[0].1.target() else { panic!() };
        assert_eq!(file.symbol_by_index(si).unwrap().name(), Ok("_rust_eh_personality"));
        let data = eh.data().unwrap();
        assert_eq!(le32(data, relocs[0].0), 4);

        // The CIE's L and R encodings: pcrel absptr, as LLVM's.
        assert_eq!(data[relocs[0].0 as usize + 4..relocs[0].0 as usize + 6], [0x10, 0x10]);
        // The FDEs, in function order: length, CIE pointer (4 bytes each), pc_begin,
        // pc_range (8 bytes each), augmentation length (1 byte), LSDA (8 bytes).
        let (text, lsda) = (section(&file, "__text").address(), section(&file, "__gcc_except_tab").address());
        let lsda_offsets: Vec<i64> = img
            .relocs
            .iter()
            .filter(|r| r.section == Section::EhFrame && r.target == RelocTarget::Section(Section::Lsda))
            .map(|r| r.addend)
            .collect();
        let mut at = u64::from(u32::from_le_bytes(data[0..4].try_into().unwrap())) + 4;
        for (i, f) in img.functions.iter().enumerate() {
            let len = u64::from(u32::from_le_bytes(data[at as usize..at as usize + 4].try_into().unwrap()));
            let pc_field = at + 8;
            let pc_begin = (eh.address() + pc_field) as i64 + le64(data, pc_field);
            assert_eq!(pc_begin as u64, text + f.start as u64, "FDE {i}");
            assert_eq!(le64(data, at + 16) as u32, f.len, "FDE {i}");
            assert_eq!(data[at as usize + 24], 8, "FDE {i}");
            let lsda_field = at + 25;
            let target = (eh.address() + lsda_field) as i64 + le64(data, lsda_field);
            assert_eq!(target as u64, lsda + lsda_offsets[i] as u64, "FDE {i}");
            at += len + 4;
        }
        assert_eq!(at, data.len() as u64);
    }

    #[test]
    fn registry() {
        let bytes = write_registry(&fmt(), "ryo_vm_register_t", false, false).unwrap();
        let file = MachOFile64::<Endianness>::parse(&*bytes).unwrap();
        let init = section(&file, "__mod_init_func");
        let object::SectionFlags::MachO { flags } = init.flags() else { panic!() };
        assert_eq!(flags, macho::S_MOD_INIT_FUNC_POINTERS);
        assert_eq!(init.size(), 8);
        let text = section(&file, "__text");
        let target = |r: &object::read::Relocation| {
            let RelocationTarget::Symbol(si) = r.target() else { panic!("non-extern relocation") };
            file.symbol_by_index(si).unwrap()
        };
        let (_, r) = init.relocations().next().unwrap();
        assert_eq!(r.flags(), RelocationFlags::MachO { r_type: macho::X86_64_RELOC_UNSIGNED, r_pcrel: false, r_length: 3 });
        assert_eq!(target(&r).address(), text.address());
        let text_relocs: Vec<_> = text.relocations().collect();
        assert_eq!(text_relocs.len(), 4);
        let at = |o| text_relocs.iter().find(|(off, _)| *off == o).map(|(_, r)| r).unwrap();
        let signed = RelocationFlags::MachO { r_type: macho::X86_64_RELOC_SIGNED, r_pcrel: true, r_length: 2 };
        let (start, end) = (format!("section$start$__DATA${}", macho_entries()), format!("section$end$__DATA${}", macho_entries()));
        assert_eq!((at(3).flags(), target(at(3)).name()), (signed, Ok(&*start)));
        assert!(target(at(3)).is_undefined());
        assert_eq!((at(10).flags(), target(at(10)).name()), (signed, Ok(&*end)));
        let anchor_name = format!("_{}", anchor_symbol());
        assert_eq!((at(17).flags(), target(at(17)).name()), (signed, Ok(&*anchor_name)));
        assert_eq!(at(22).flags(), RelocationFlags::MachO { r_type: macho::X86_64_RELOC_BRANCH, r_pcrel: true, r_length: 2 });
        assert_eq!(target(at(22)).name(), Ok("_ryo_vm_register_t"));
        // The stub's own entry is null, so the section exists in every link.
        let entries = section(&file, &macho_entries());
        assert_eq!(entries.data().unwrap(), &[0; 8]);
        assert_eq!(entries.relocations().count(), 0);
        let anchor = file.symbols().find(|s| s.name() == Ok(&*anchor_name)).unwrap();
        assert_eq!((anchor.scope(), anchor.is_weak()), (SymbolScope::Linkage, true));
        assert_eq!(anchor.section_index(), Some(section(&file, "__data").index()));
    }
}
