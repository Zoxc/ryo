//! Step 6 (design/backend.md#pipeline): cg_llvm's `link`, once per crate type, each final
//! output with its own registry object.

use std::fs;
use std::path::{Path, PathBuf};

use rustc_codegen_ssa::back::archive::{AddArchiveKind, ArArchiveBuilderBuilder, ArchiveBuilderBuilder, ArchiveEntryKind};
use rustc_codegen_ssa::traits::CodegenBackend;
use rustc_codegen_ssa::{CompiledModule, CompiledModules, CrateInfo, ModuleKind};
use rustc_metadata::EncodedMetadata;
use rustc_session::Session;
use rustc_session::config::{CrateType, OutputFilenames, OutputType};

use crate::objfile;

/// What `link` needs from `codegen_crate`.
pub struct LinkInfo {
    /// The `CompiledModule` names of the local crate's images (one per CGU with VM code).
    pub images: Vec<String>,
    /// The target writes Mach-O objects.
    pub macho: bool,
    /// The symbol of `ryo_rt`'s `ryo_vm_register` (tagged and mangled).
    pub register: String,
    /// For a Rust dylib: the runtime crates' exported symbols, which it doesn't export
    /// ([`crate::symbols::runtime_exports`]); empty for other crate types.
    pub runtime_exports: rustc_data_structures::fx::FxHashSet<String>,
}

impl LinkInfo {
    pub fn new(tcx: rustc_middle::ty::TyCtxt<'_>, images: Vec<String>) -> Self {
        let dylib = tcx.crate_types().contains(&CrateType::Dylib);
        LinkInfo {
            images,
            macho: crate::symbols::is_macho(tcx.sess),
            register: crate::symbols::rt_symbol(tcx, objfile::REGISTER_SYMBOL),
            runtime_exports: if dylib { crate::symbols::runtime_exports(tcx) } else { Default::default() },
        }
    }
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
    let fmt = super::object_format(sess);
    let types = crate_info.crate_types.clone();
    let n = types.len();

    // `link_binary` deletes the module objects and the metadata's temp dir at the end of each
    // call, so every call but the last gets hardlinks and a copy (design/backend.md#pipeline).
    let scratch = outputs.temp_path_for_cgu(OutputType::Object, "ryo_link").with_extension("d");
    let mut saved_metadata = None;
    if n > 1 {
        let _ = fs::remove_dir_all(&scratch);
        fs::create_dir_all(&scratch).unwrap_or_else(|e| sess.dcx().fatal(format!("creating {}: {e}", scratch.display())));
        saved_metadata = Some(save_metadata(sess, &metadata, &scratch));
    }
    let mut metadata = Some(metadata);
    let mut modules = Some(modules);
    for (i, &crate_type) in types.iter().enumerate() {
        let last = i + 1 == n;
        // Everything but rustc's own `link_binary` (design/backend.md#self-profile).
        let prep_t = sess.prof.generic_activity("ryo_link_prep");
        let mut these = if last { modules.take().unwrap() } else { hardlinked(sess, modules.as_ref().unwrap(), &scratch.join(i.to_string())) };
        let this_metadata = if last {
            metadata.take().unwrap()
        } else {
            let (full, stub) = saved_metadata.clone().unwrap();
            EncodedMetadata::from_path(full, stub, None).unwrap_or_else(|e| sess.dcx().fatal(format!("reloading the crate metadata: {e}")))
        };
        // Without linking (`--emit=obj` etc.) a registry object would only be left behind.
        if crate_type != CrateType::Rlib && sess.opts.output_types.should_link() {
            let registry = registry_module(sess, &*fmt, &crate_info, info, outputs, crate_type);
            // Mach-O has no constructor priorities: ld64 and lld lay out `__mod_init_func` in
            // input order and dyld runs it in that order, so the registry object goes first,
            // ahead of the crate's own objects and every rlib (design/platforms.md). Objects ahead of
            // rustc's can still come first; for them the JIT's trips register lazily.
            if info.macho {
                these.modules.insert(0, registry);
            } else {
                these.modules.push(registry);
            }
        }
        // In an rlib, the image is added afterwards, as a plain member (not a Rust object,
        // which downstream crates would read as rustc's own codegen). `link_binary` writes the
        // rlib only with `link` output to a file, which `partition::check_outputs` requires.
        let images = if crate_type == CrateType::Rlib { take_images(&mut these, info) } else { Vec::new() };
        let mut single = crate_info.clone();
        single.crate_types = vec![crate_type];
        // A Rust dylib's copy of the runtime is private (`dylib_dependency_formats`): rustc
        // would export it with every other statically linked crate.
        if crate_type == CrateType::Dylib
            && let Some(list) = single.exported_symbols.get_mut(&crate_type)
        {
            list.retain(|e| !info.runtime_exports.contains(&e.name));
        }
        drop(prep_t);
        llvm.link(sess, these, single, this_metadata, outputs);
        let objects: Vec<PathBuf> = images.into_iter().filter_map(|m| m.object).collect();
        if !objects.is_empty() {
            let _t = sess.prof.generic_activity("ryo_append_rlib");
            let rlib = rustc_session::output::out_filename(sess, crate_type, outputs, crate_info.local_crate_name);
            if let rustc_session::config::OutFileName::Real(rlib) = rlib {
                append_to_rlib(sess, &rlib, &objects);
            }
            for o in &objects {
                remove_temp(sess, o);
            }
        }
    }
    if n > 1 {
        remove_temp(sess, &scratch);
    }
}

/// Writes the registry object for an output of `crate_type`. It lists no images: each image
/// object linked brings its own entry.
fn registry_module(
    sess: &Session,
    fmt: &dyn objfile::ObjectFormat,
    crate_info: &CrateInfo,
    info: &LinkInfo,
    outputs: &OutputFilenames,
    crate_type: CrateType,
) -> CompiledModule {
    let _t = sess.prof.generic_activity("ryo_registry");
    // Every output has a private copy of `ryo_rt`
    // (design/vm.md#several-ryo-runtimes-in-one-process), which the stub calls.
    let bytes = objfile::write_registry(fmt, &info.register).unwrap_or_else(|e| sess.dcx().fatal(e));
    let name = format!("{}.ryo_registry.{}", crate_info.local_crate_name, crate_type);
    let path = outputs.temp_path_for_cgu(OutputType::Object, &name);
    write_or_fatal(sess, &path, &bytes);
    object_module(name, path)
}

/// Moves the local crate's image modules out of `modules`.
fn take_images(modules: &mut CompiledModules, info: &LinkInfo) -> Vec<CompiledModule> {
    let (images, rest) = std::mem::take(&mut modules.modules).into_iter().partition(|m| info.images.contains(&m.name));
    modules.modules = rest;
    images
}

/// Removes a temporary file or directory, unless `-Csave-temps` keeps it.
fn remove_temp(sess: &Session, path: &Path) {
    if sess.opts.cg.save_temps {
        return;
    }
    let _ = if path.is_dir() { fs::remove_dir_all(path) } else { fs::remove_file(path) };
}

/// Appends `objects` to the archive `rlib` as non-Rust members (`ArchiveEntryKind::Other`).
fn append_to_rlib(sess: &Session, rlib: &Path, objects: &[PathBuf]) {
    let tmp = rlib.with_extension("rlib.ryo-tmp");
    let mut ab = ArArchiveBuilderBuilder.new_archive_builder(sess);
    if let Err(e) = ab.add_archive(rlib, AddArchiveKind::Other) {
        sess.dcx().fatal(format!("reading {}: {e}", rlib.display()));
    }
    for object in objects {
        ab.add_file(object, ArchiveEntryKind::Other);
    }
    ab.build(&tmp, None);
    if let Err(e) = fs::rename(&tmp, rlib) {
        sess.dcx().fatal(format!("writing {}: {e}", rlib.display()));
    }
}

/// Copies the metadata file (and its stub) into `dir`, so later `link_binary` calls can reload
/// it after the first one dropped the original.
fn save_metadata(sess: &Session, metadata: &EncodedMetadata, dir: &Path) -> (PathBuf, Option<PathBuf>) {
    let full = dir.join("metadata.rmeta");
    let stub = dir.join("metadata.stub");
    match metadata.path() {
        Some(p) => {
            fs::copy(p, &full).unwrap_or_else(|e| sess.dcx().fatal(format!("copying {}: {e}", p.display())));
        }
        None => write_or_fatal(sess, &full, metadata.full()),
    }
    write_or_fatal(sess, &stub, metadata.stub_or_full());
    (full, Some(stub))
}

/// A copy of `modules` whose files are hardlinks in `dir` (copies if hardlinking fails).
fn hardlinked(sess: &Session, modules: &CompiledModules, dir: &Path) -> CompiledModules {
    fs::create_dir_all(dir).unwrap_or_else(|e| sess.dcx().fatal(format!("creating {}: {e}", dir.display())));
    let link = |p: &Option<PathBuf>| -> Option<PathBuf> {
        let p = p.as_ref()?;
        let to = dir.join(p.file_name()?);
        link_or_copy(sess, p, &to);
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
    CompiledModules { modules: modules.modules.iter().map(module).collect(), allocator_module: modules.allocator_module.as_ref().map(module) }
}

/// Hardlinks `from` to `to`, or copies it if hardlinking fails; fatal if both fail.
pub(crate) fn link_or_copy(sess: &Session, from: &Path, to: &Path) {
    if fs::hard_link(from, to).is_err() {
        fs::copy(from, to).unwrap_or_else(|e| sess.dcx().fatal(format!("copying {}: {e}", from.display())));
    }
}

/// Writes `bytes` to `path`; fatal on failure.
pub(crate) fn write_or_fatal(sess: &Session, path: &Path, bytes: &[u8]) {
    fs::write(path, bytes).unwrap_or_else(|e| sess.dcx().fatal(format!("writing {}: {e}", path.display())));
}

/// A `CompiledModule` for an object file the backend wrote itself.
pub(crate) fn object_module(name: String, object: PathBuf) -> CompiledModule {
    CompiledModule {
        name,
        kind: ModuleKind::Regular,
        object: Some(object),
        global_asm_object: None,
        dwarf_object: None,
        bytecode: None,
        assembly: None,
        llvm_ir: None,
        links_from_incr_cache: Vec::new(),
    }
}
