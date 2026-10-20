//! Step 6 (design/backend.md#pipeline): cg_llvm's `link`, once per crate type, each final
//! output with its own registry object.

use std::fs;
use std::path::{Path, PathBuf};

use rustc_codegen_ssa::traits::CodegenBackend;
use rustc_codegen_ssa::{CompiledModule, CompiledModules, CrateInfo};
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
            let images = registry_images(sess, info, &crate_info, crate_type);
            let bytes = objfile::write_registry(&*fmt, &images).unwrap_or_else(|e| sess.dcx().fatal(e));
            let name = format!("{}.ryo_registry.{}", crate_info.local_crate_name, crate_type);
            let path = outputs.temp_path_for_cgu(OutputType::Object, &name);
            fs::write(&path, bytes).unwrap_or_else(|e| sess.dcx().fatal(format!("writing {}: {e}", path.display())));
            these.modules.push(object_module(name, path));
        }
        let mut single = crate_info.clone();
        single.crate_types = vec![crate_type];
        llvm.link(sess, these, single, this_metadata, outputs);
    }
    if n > 1 && !sess.opts.cg.save_temps {
        let _ = fs::remove_dir_all(&scratch);
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
        let data = fs::read(&rlib).unwrap_or_else(|e| sess.dcx().fatal(format!("reading {}: {e}", rlib.display())));
        match objfile::archive_image_symbols(&data) {
            Ok(syms) => images.extend(syms),
            Err(e) => sess.dcx().fatal(format!("reading the symbol table of {}: {e}", rlib.display())),
        }
    }
    images
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
