//! Step 6 (design/backend.md#pipeline): cg_llvm's `link`, once per crate type, each final
//! output with its own registry object.

use std::fs;
use std::path::{Path, PathBuf};

use rustc_codegen_ssa::back::archive::{AddArchiveKind, ArArchiveBuilderBuilder, ArchiveBuilderBuilder, ArchiveEntryKind};
use rustc_codegen_ssa::traits::CodegenBackend;
use rustc_codegen_ssa::{CompiledModule, CompiledModules, CrateInfo};
use rustc_data_structures::fx::FxHashMap;
use rustc_hir::def_id::LOCAL_CRATE;
use rustc_metadata::EncodedMetadata;
use rustc_middle::middle::dependency_format::Linkage;
use rustc_session::Session;
use rustc_session::config::{CrateType, OutputFilenames, OutputType};

use super::object_module;
use crate::objfile;

/// What `link` needs from `codegen_crate`.
pub struct LinkInfo {
    /// The local crate's image symbol.
    pub local_image: String,
    /// The name of the image's `CompiledModule`.
    pub image_module: String,
    /// Per crate type, the image symbols that only LTO needs, as entries of its
    /// `linked_symbols` and of its `exported_symbols` (`partition::linked_roots`).
    pub linked_roots: Vec<(CrateType, (Vec<String>, Vec<String>))>,
    pub binary_format: object::BinaryFormat,
}

pub fn link(
    llvm: &dyn CodegenBackend,
    info: Option<&LinkInfo>,
    sess: &Session,
    modules: CompiledModules,
    crate_info: CrateInfo,
    metadata: EncodedMetadata,
    outputs: &OutputFilenames,
) {
    // No codegen ran (e.g. `--emit=metadata`): nothing of ours to link.
    let Some(info) = info else { return llvm.link(sess, modules, crate_info, metadata, outputs) };
    let fmt = objfile::format_for(info.binary_format).unwrap_or_else(|e| sess.dcx().fatal(e));
    let types = crate_info.crate_types.clone();
    let n = types.len();

    // `link_binary` deletes the module objects and the metadata's temp dir at the end of each
    // call, so every call but the last gets hardlinks and a copy (design/backend.md#pipeline).
    let scratch = outputs.temp_path_for_cgu(OutputType::Object, "ryo_link").with_extension("d");
    let mut saved_metadata = None;
    if n > 1 {
        let _ = fs::remove_dir_all(&scratch);
        fs::create_dir_all(&scratch)
            .unwrap_or_else(|e| sess.dcx().fatal(format!("creating {}: {e}", scratch.display())));
        saved_metadata = Some(save_metadata(sess, &metadata, &scratch));
    }
    let mut metadata = Some(metadata);
    let mut modules = Some(modules);
    for (i, &crate_type) in types.iter().enumerate() {
        let last = i + 1 == n;
        // Everything but rustc's own `link_binary` (design/backend.md#self-profile).
        let prep_t = sess.prof.generic_activity("ryo_link_prep");
        let mut these = if last {
            modules.take().unwrap()
        } else {
            hardlinked(sess, modules.as_ref().unwrap(), &scratch.join(i.to_string()))
        };
        let this_metadata = if last {
            metadata.take().unwrap()
        } else {
            let (full, stub) = saved_metadata.clone().unwrap();
            EncodedMetadata::from_path(full, stub, None)
                .unwrap_or_else(|e| sess.dcx().fatal(format!("reloading the crate metadata: {e}")))
        };
        // Without linking (`--emit=obj` etc.) a registry object would only be left behind.
        if crate_type != CrateType::Rlib && sess.opts.output_types.should_link() {
            let registry_t = sess.prof.generic_activity("ryo_registry_images");
            let images = registry_images(sess, info, &crate_info, crate_type);
            let import = register_is_imported(&crate_info, crate_type);
            let bytes = objfile::write_registry(&*fmt, &images, import).unwrap_or_else(|e| sess.dcx().fatal(e));
            let name = format!("{}.ryo_registry.{}", crate_info.local_crate_name, crate_type);
            let path = outputs.temp_path_for_cgu(OutputType::Object, &name);
            fs::write(&path, bytes).unwrap_or_else(|e| sess.dcx().fatal(format!("writing {}: {e}", path.display())));
            these.modules.push(object_module(name, path));
            drop(registry_t);
        }
        // In an rlib, the image must not be a Rust object: `-Clto` downstream reads bitcode
        // from every Rust object of an rlib and leaves them out of the link, which would drop
        // the image. So it is added afterwards, as a plain member.
        let image = if crate_type == CrateType::Rlib {
            let i = these.modules.iter().position(|m| m.name == info.image_module);
            i.map(|i| these.modules.remove(i))
        } else {
            None
        };
        let mut single = crate_info.clone();
        single.crate_types = vec![crate_type];
        remove_roots(&mut single, info, crate_type);
        drop(prep_t);
        llvm.link(sess, these, single, this_metadata, outputs);
        if let Some(object) = image.and_then(|m| m.object) {
            let _t = sess.prof.generic_activity("ryo_append_rlib");
            let rlib = rustc_session::output::out_filename(sess, crate_type, outputs, crate_info.local_crate_name);
            if let rustc_session::config::OutFileName::Real(rlib) = rlib {
                append_to_rlib(sess, &rlib, &object);
            }
            if !sess.opts.cg.save_temps {
                let _ = fs::remove_file(&object);
            }
        }
    }
    if n > 1 && !sess.opts.cg.save_temps {
        let _ = fs::remove_dir_all(&scratch);
    }
}

/// Takes the image symbols that only LTO needs (`partition::linked_roots`) out of the
/// output's export list (a Rust dylib's includes the `Rust` level, and the roots include other
/// crates' and foreign symbols, which a version script or `.def` file can't export) and out of
/// `symbols.o` (rustc already leaves that empty under `-Clto`, `linker.rs:1760-1768`). One
/// occurrence per crate that listed it, so the names rustc lists itself stay.
fn remove_roots(crate_info: &mut CrateInfo, info: &LinkInfo, crate_type: CrateType) {
    let Some((_, (linked_roots, exported_roots))) = info.linked_roots.iter().find(|(t, _)| *t == crate_type) else {
        return;
    };
    // Names are undecorated on both sides (`partition::linked_roots`).
    fn counts(roots: &[String]) -> FxHashMap<&str, usize> {
        let mut count = FxHashMap::default();
        for r in roots {
            *count.entry(r.as_str()).or_default() += 1;
        }
        count
    }
    let take = |count: &mut FxHashMap<&str, usize>, name: &str| match count.get_mut(name) {
        Some(n) if *n > 0 => {
            *n -= 1;
            true
        }
        _ => false,
    };
    if let Some(linked) = crate_info.linked_symbols.get_mut(&crate_type) {
        let mut count = counts(linked_roots);
        linked.retain(|(name, _)| !take(&mut count, name));
    }
    if let Some(exported) = crate_info.exported_symbols.get_mut(&crate_type) {
        let mut count = counts(exported_roots);
        exported.retain(|e| !take(&mut count, &e.name));
    }
}

/// Appends `object` to the archive `rlib` as a non-Rust member (`ArchiveEntryKind::Other`).
fn append_to_rlib(sess: &Session, rlib: &Path, object: &Path) {
    let tmp = rlib.with_extension("rlib.ryo-tmp");
    let mut ab = ArArchiveBuilderBuilder.new_archive_builder(sess);
    if let Err(e) = ab.add_archive(rlib, AddArchiveKind::Other) {
        sess.dcx().fatal(format!("reading {}: {e}", rlib.display()));
    }
    ab.add_file(object, ArchiveEntryKind::Other);
    ab.build(&tmp, None);
    if let Err(e) = fs::rename(&tmp, rlib) {
        sess.dcx().fatal(format!("writing {}: {e}", rlib.display()));
    }
}

/// The image symbols a final output of `crate_type` registers: the local crate's, and those of
/// the upstream crates linked into it statically. Crates linked into an upstream dylib are
/// registered by that dylib's registry. Upstream rlibs are recognized as ryo-built by an image
/// symbol in their archive symbol table.
fn registry_images(sess: &Session, info: &LinkInfo, crate_info: &CrateInfo, crate_type: CrateType) -> Vec<String> {
    let mut images = vec![info.local_image.clone()];
    let Some(deps) = crate_info.dependency_formats.get(&crate_type) else { return images };
    for (cnum, linkage) in deps.iter_enumerated() {
        if cnum == LOCAL_CRATE || *linkage != Linkage::Static {
            continue;
        }
        let Some(rlib) = crate_info.used_crate_source.get(&cnum).and_then(|s| s.rlib.clone()) else { continue };
        // Only the archive's symbol table is read, not the whole rlib.
        let file = fs::File::open(&rlib).unwrap_or_else(|e| sess.dcx().fatal(format!("reading {}: {e}", rlib.display())));
        let cache = object::ReadCache::new(file);
        match objfile::archive_image_symbols(&cache) {
            Ok(syms) => images.extend(syms),
            Err(e) => sess.dcx().fatal(format!("reading the symbol table of {}: {e}", rlib.display())),
        }
    }
    images
}

/// Whether `ryo_vm_register` lives in another shared object for an output of `crate_type`:
/// `ryo_rt` is linked as a dylib or included in an upstream Rust dylib. On PE the registry
/// constructor then calls it through `__imp_ryo_vm_register` (design/platforms.md).
fn register_is_imported(crate_info: &CrateInfo, crate_type: CrateType) -> bool {
    let Some(deps) = crate_info.dependency_formats.get(&crate_type) else { return false };
    deps.iter_enumerated().any(|(cnum, linkage)| {
        matches!(linkage, Linkage::Dynamic | Linkage::IncludedFromDylib)
            && crate_info.crate_name.get(&cnum).is_some_and(|n| n.as_str() == "ryo_rt")
    })
}

/// Copies the metadata file (and its stub) into `dir`, so later `link_binary` calls can reload
/// it after the first one dropped the original.
fn save_metadata(sess: &Session, metadata: &EncodedMetadata, dir: &Path) -> (PathBuf, Option<PathBuf>) {
    let full = dir.join("metadata.rmeta");
    let stub = dir.join("metadata.stub");
    let write = |p: &Path, data: &[u8]| {
        fs::write(p, data).unwrap_or_else(|e| sess.dcx().fatal(format!("writing {}: {e}", p.display())))
    };
    match metadata.path() {
        Some(p) => {
            fs::copy(p, &full).unwrap_or_else(|e| sess.dcx().fatal(format!("copying {}: {e}", p.display())));
        }
        None => write(&full, metadata.full()),
    }
    write(&stub, metadata.stub_or_full());
    (full, Some(stub))
}

/// A copy of `modules` whose files are hardlinks in `dir` (copies if hardlinking fails).
fn hardlinked(sess: &Session, modules: &CompiledModules, dir: &Path) -> CompiledModules {
    fs::create_dir_all(dir).unwrap_or_else(|e| sess.dcx().fatal(format!("creating {}: {e}", dir.display())));
    let link = |p: &Option<PathBuf>| -> Option<PathBuf> {
        let p = p.as_ref()?;
        let to = dir.join(p.file_name()?);
        if fs::hard_link(p, &to).is_err() {
            fs::copy(p, &to).unwrap_or_else(|e| sess.dcx().fatal(format!("copying {}: {e}", p.display())));
        }
        Some(to)
    };
    let module = |m: &CompiledModule| CompiledModule {
        name: m.name.clone(),
        kind: m.kind,
        object: link(&m.object),
        global_asm_object: link(&m.global_asm_object),
        dwarf_object: link(&m.dwarf_object),
        bytecode: m.bytecode.clone(),
        assembly: m.assembly.clone(),
        llvm_ir: m.llvm_ir.clone(),
        links_from_incr_cache: m.links_from_incr_cache.clone(),
    };
    CompiledModules {
        modules: modules.modules.iter().map(module).collect(),
        allocator_module: modules.allocator_module.as_ref().map(module),
    }
}
