//! `rustc_codegen_ryo`: the ryo codegen backend (design/backend.md).
//!
//! - this file: the `CodegenBackend` impl and the query overrides
//! - [`partition`]: pipeline steps 1–4 and the image contents
//! - [`lower`]: MIR → bytecode
//! - [`symbols`]: the image's symbol names and linkage (PE imports)
//! - [`link`]: step 6, one `link_binary` per crate type with its registry object
//! - [`dump`]: `RYO_DUMP` / `RYO_DUMP_CODE`, the VM functions as text
//! - [`dump_lean`]: `RYO_DUMP_LEAN`, the program as the Lean MIR spec's input (lean/)
//! - [`objfile`]: the image and registry objects, written without compiler types
#![feature(rustc_private)]

// The compiler crates.
extern crate rustc_abi;
extern crate rustc_codegen_llvm;
extern crate rustc_codegen_ssa;
extern crate rustc_data_structures;
extern crate rustc_hir;
extern crate rustc_incremental;
extern crate rustc_index;
extern crate rustc_metadata;
extern crate rustc_middle;
extern crate rustc_serialize;
extern crate rustc_session;
extern crate rustc_span;
extern crate rustc_symbol_mangling;
extern crate rustc_target;
extern crate rustc_type_ir;

// Links the compiler's own `librustc_driver` dylib, which holds all the crates above.
extern crate rustc_driver;

mod dump;
mod dump_lean;
mod json;
mod link;
mod lower;
mod objfile;
mod partition;
mod persist;
mod switches;
mod symbols;

use std::any::Any;
use std::path::PathBuf;
use std::sync::OnceLock;

use rustc_codegen_ssa::traits::CodegenBackend;
use rustc_codegen_ssa::{CompiledModule, CompiledModules, CrateInfo, ModuleKind, TargetConfig};
use rustc_metadata::EncodedMetadata;
use rustc_metadata::creader::MetadataLoaderDyn;
use rustc_middle::dep_graph::WorkProductMap;
use rustc_middle::middle::exported_symbols::{ExportedSymbol, SymbolExportInfo};
use rustc_middle::mono::MonoItemPartitions;
use rustc_middle::query::LocalCrate;
use rustc_middle::ty::{self, Instance, TyCtxt};
use rustc_middle::util::Providers;
use rustc_session::config::{CrateType, OutputFilenames, OutputType, PrintRequest};
use rustc_session::{IncrCompSession, Session};
use rustc_span::Symbol;

pub type BoxedBackend = Box<dyn CodegenBackend>;

/// The entry point rustc looks up in a `-Zcodegen-backend=<path>` dylib.
#[unsafe(no_mangle)]
pub fn __rustc_codegen_backend() -> BoxedBackend {
    RyoBackend::new()
}

/// Printed by `init` and by the partition provider when `RYO_BACKEND_MARKER` is set, so `y test`
/// can check that this backend, and our query override, ran.
pub const INIT_MARKER: &str = "ryo backend: init";
pub const PARTITION_MARKER: &str = "ryo backend: partition";

/// The ryo backend: cg_llvm plus the VM pipeline (design/backend.md).
pub struct RyoBackend {
    llvm: Box<dyn CodegenBackend>,
    /// The debugging switches, read when the backend is created.
    switches: switches::Switches,
    /// Set by `codegen_crate` for `link`, which has no `tcx`.
    link_info: OnceLock<link::LinkInfo>,
}

impl RyoBackend {
    pub fn new() -> BoxedBackend {
        Box::new(RyoBackend {
            llvm: rustc_codegen_llvm::LlvmCodegenBackend::new(),
            switches: switches::Switches::from_env(),
            link_info: OnceLock::new(),
        })
    }
}

/// The type of a `collect_and_partition_mono_items` provider (`rustc_middle/src/queries.rs:2450`,
/// providers are `for<'tcx> fn(TyCtxt<'tcx>, Key) -> Value`, `rustc_middle/src/query/plumbing.rs:489-495`).
type PartitionProvider = for<'tcx> fn(TyCtxt<'tcx>, ()) -> MonoItemPartitions<'tcx>;
type SymbolNameProvider = for<'tcx> fn(TyCtxt<'tcx>, Instance<'tcx>) -> ty::SymbolName<'tcx>;
type ExportedProvider = for<'tcx> fn(TyCtxt<'tcx>, LocalCrate) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)];
type UpstreamProvider = for<'tcx> fn(TyCtxt<'tcx>, ()) -> partition::UpstreamMonos<'tcx>;

/// The default providers, saved in `provide`. Statics, because providers are plain fns.
struct Originals {
    partition: PartitionProvider,
    symbol_name: SymbolNameProvider,
    exported_generic_symbols: ExportedProvider,
    exported_non_generic_symbols: ExportedProvider,
    upstream_monomorphizations: UpstreamProvider,
}

static ORIGINALS: OnceLock<Originals> = OnceLock::new();

fn originals() -> &'static Originals {
    ORIGINALS.get().expect("provide() didn't save the original providers")
}

fn collect_and_partition_mono_items<'tcx>(tcx: TyCtxt<'tcx>, (): ()) -> MonoItemPartitions<'tcx> {
    partition::collect_and_partition_mono_items(tcx, originals().partition)
}

fn symbol_name<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> ty::SymbolName<'tcx> {
    symbols::symbol_name(tcx, instance, || (originals().symbol_name)(tcx, instance))
}

fn exported_generic_symbols<'tcx>(tcx: TyCtxt<'tcx>, krate: LocalCrate) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    partition::exported_generic_symbols(tcx, (originals().exported_generic_symbols)(tcx, krate))
}

fn exported_non_generic_symbols<'tcx>(tcx: TyCtxt<'tcx>, krate: LocalCrate) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    partition::exported_non_generic_symbols(tcx, (originals().exported_non_generic_symbols)(tcx, krate))
}

fn upstream_monomorphizations<'tcx>(tcx: TyCtxt<'tcx>, (): ()) -> partition::UpstreamMonos<'tcx> {
    partition::upstream_monomorphizations(tcx, (originals().upstream_monomorphizations)(tcx, ()))
}

impl CodegenBackend for RyoBackend {
    fn name(&self) -> &'static str {
        "ryo"
    }

    fn init(&self, sess: &Session) {
        if self.switches.marker {
            eprintln!("{INIT_MARKER}");
        }
        // `-Cincremental` is allowed: the partition query is `eval_always`, so the image is
        // rebuilt every session, and the native CGU is hashed as our partition returns it
        // (`codegen_unit`); `symbol_name` reads only tracked queries.
        let z = &sess.opts.unstable_opts;
        // `-Zno-link` saves the modules in an `.rlink` and `-Zlink-only` links them without
        // `codegen_crate`, so without the registry object and the roots' removal; and the
        // staticlib renaming rewrites the Rust objects but not the upstream images, which
        // refer to them by the old names (design/backend.md#unsupported-options).
        for (set, flag) in
            [(z.no_link, "-Zno-link"), (z.link_only, "-Zlink-only"), (z.staticlib_rename_internal_symbols, "-Zstaticlib-rename-internal-symbols")]
        {
            if set {
                sess.dcx().fatal(format!("the ryo backend doesn't support `{flag}`"));
            }
        }
        self.llvm.init(sess)
    }

    fn print(&self, req: &PrintRequest, out: &mut String, sess: &Session) {
        self.llvm.print(req, out, sess)
    }

    fn target_config(&self, sess: &Session) -> TargetConfig {
        self.llvm.target_config(sess)
    }

    fn supported_crate_types(&self, sess: &Session) -> Vec<CrateType> {
        self.llvm.supported_crate_types(sess)
    }

    fn print_passes(&self) {
        self.llvm.print_passes()
    }

    fn print_version(&self) {
        self.llvm.print_version()
    }

    fn replaced_intrinsics(&self) -> Vec<Symbol> {
        self.llvm.replaced_intrinsics()
    }

    fn fallback_intrinsics(&self) -> Vec<Symbol> {
        self.llvm.fallback_intrinsics()
    }

    fn thin_lto_supported(&self) -> bool {
        self.llvm.thin_lto_supported()
    }

    fn has_zstd(&self) -> bool {
        self.llvm.has_zstd()
    }

    fn has_mnemonic(&self, sess: &Session, mnemonic: &str) -> bool {
        self.llvm.has_mnemonic(sess, mnemonic)
    }

    fn metadata_loader(&self) -> Box<MetadataLoaderDyn> {
        self.llvm.metadata_loader()
    }

    fn provide(&self, providers: &mut Providers) {
        self.llvm.provide(providers);
        // The defaults are `rustc_monomorphize`'s, `rustc_symbol_mangling`'s and
        // `rustc_codegen_ssa`'s, installed before the backend's `provide` runs
        // (`rustc_interface/src/passes.rs:980-981`). `provide` runs once per session, and the
        // providers are plain fns, so a second session would find the same ones.
        let q = &mut providers.queries;
        let _ = ORIGINALS.set(Originals {
            partition: q.collect_and_partition_mono_items,
            symbol_name: q.symbol_name,
            exported_generic_symbols: q.exported_generic_symbols,
            exported_non_generic_symbols: q.exported_non_generic_symbols,
            upstream_monomorphizations: q.upstream_monomorphizations,
        });
        q.collect_and_partition_mono_items = collect_and_partition_mono_items;
        q.symbol_name = symbol_name;
        q.exported_generic_symbols = exported_generic_symbols;
        q.exported_non_generic_symbols = exported_non_generic_symbols;
        q.upstream_monomorphizations = upstream_monomorphizations;
    }

    fn target_cpu(&self, sess: &Session) -> String {
        self.llvm.target_cpu(sess)
    }

    fn codegen_crate<'tcx>(&self, tcx: TyCtxt<'tcx>) -> Box<dyn Any> {
        // Usually already computed (metadata encoding, `exported_generic_symbols`); this forces
        // it otherwise, so the results are set.
        let partitions = tcx.collect_and_partition_mono_items(());
        let linked_roots = || tcx.crate_types().iter().map(|&t| (t, partition::linked_roots(tcx, t))).collect();
        let macho = tcx.sess.target.binary_format == rustc_target::spec::BinaryFormat::MachO;
        // A crate with no VM code has no image (`partition::vm_enabled`); its output still
        // registers its upstream crates' images.
        let Some(results) = partition::results(tcx) else {
            let _ = self.link_info.set(link::LinkInfo { images: Vec::new(), linked_roots: linked_roots(), macho });
            let llvm = self.llvm.codegen_crate(tcx);
            return Box::new(RyoOngoingCodegen { llvm, images: Vec::new() });
        };
        let _ = partitions;
        let fmt = object_format(tcx.sess);
        let scid = symbols::local_stable_crate_id(tcx);
        // Step 5: the image objects, one per CGU with VM functions (design/backend.md#pipeline).
        let rt_symbol = |name: &str| symbols::rt_symbol(tcx, name);
        let write_t = tcx.prof.generic_activity("ryo_write_image");
        let mut images = Vec::with_capacity(results.images.len());
        for img in &results.images {
            // Side data alone is only for the incremental cache.
            if !img.has_object() && tcx.sess.opts.incremental.is_none() {
                continue;
            }
            let image_name = format!("{}.ryo_image", img.cgu_name);
            let image_path = tcx.output_filenames(()).temp_path_for_cgu(OutputType::Object, &image_name);
            let save = match &img.image {
                partition::ImageSrc::Fresh { image, side } => {
                    let side_path = image_path.with_extension("ryo");
                    let mut files = vec![(&side_path, side.clone())];
                    if let Some(image) = image {
                        let cgu_hash = ryo_bytecode::image::cgu_hash(img.cgu_name.as_str().as_bytes());
                        let bytes = objfile::write_image(&*fmt, image, scid, cgu_hash, img.main_symbol.as_deref(), &rt_symbol)
                            .unwrap_or_else(|e| tcx.dcx().fatal(e));
                        files.push((&image_path, bytes));
                    }
                    for (p, b) in files {
                        // A file left by `-Csave-temps` may still be a hard link into the
                        // incremental cache (a reused image's); writing through it would change
                        // the cached copy.
                        let _ = std::fs::remove_file(p);
                        if let Err(e) = std::fs::write(p, b) {
                            tcx.dcx().fatal(format!("writing {}: {e}", p.display()));
                        }
                    }
                    ImageSave::Fresh(side_path)
                }
                // The previous session's object, as cg_ssa reuses a CGU's
                // (`execute_copy_from_cache_work_item`).
                partition::ImageSrc::Reused(wp) => {
                    let incr = tcx.incr_comp_session.expect("a reused image without an incremental session");
                    let from = wp.saved_files.get("o").map(|f| rustc_incremental::in_incr_comp_dir_sess(incr, f));
                    if let Some(from) = &from {
                        let _ = std::fs::remove_file(&image_path);
                        if std::fs::hard_link(from, &image_path).is_err()
                            && let Err(e) = std::fs::copy(from, &image_path)
                        {
                            tcx.dcx().fatal(format!("copying {} from the incremental cache: {e}", from.display()));
                        }
                    }
                    ImageSave::Reused(wp.clone(), from)
                }
            };
            let path = img.has_object().then_some(image_path);
            images.push(OngoingImage { cgu: img.cgu_name.to_string(), name: image_name, path, save });
        }
        drop(write_t);
        let modules = images.iter().filter(|i| i.path.is_some()).map(|i| i.name.clone()).collect();
        let _ = self.link_info.set(link::LinkInfo { images: modules, linked_roots: linked_roots(), macho });
        dump_lean::dump(tcx, &self.switches, results);
        // The native CGUs (step 4), compiled by cg_llvm as usual.
        let llvm = self.llvm.codegen_crate(tcx);
        Box::new(RyoOngoingCodegen { llvm, images })
    }

    fn join_codegen(
        &self,
        ongoing_codegen: Box<dyn Any>,
        sess: &Session,
        incr_comp_session: Option<&IncrCompSession>,
        outputs: &OutputFilenames,
        crate_info: &CrateInfo,
    ) -> (CompiledModules, WorkProductMap) {
        let ongoing = ongoing_codegen.downcast::<RyoOngoingCodegen>().expect("expected RyoOngoingCodegen from RyoBackend::codegen_crate");
        // cg_llvm downcasts this to its own `OngoingCodegen` (`rustc_codegen_llvm/src/lib.rs:407-410`).
        let (mut modules, mut work_products) = self.llvm.join_codegen(ongoing.llvm, sess, incr_comp_session, outputs, crate_info);
        // The images, so `link_rlib` and the object list include them
        // (design/backend.md#pipeline step 5), and their work products: saved now (cg_ssa saves
        // only its own modules', inside cg_llvm's join), or the previous session's kept, before
        // rustc writes the index (design/backend.md#incremental).
        for img in ongoing.images {
            let mut m = img.path.clone().map(|p| object_module(img.name, p));
            let wp_name = partition::image_work_product_name(rustc_span::Symbol::intern(&img.cgu));
            match img.save {
                ImageSave::Fresh(side) => {
                    if let Some(incr) = incr_comp_session {
                        let mut files = vec![("ryo", side.as_path())];
                        files.extend(img.path.as_deref().map(|p| ("o", p)));
                        let (id, wp) = rustc_incremental::copy_cgu_workproduct_to_incr_comp_cache_dir(sess, incr, &wp_name, &files, &[]);
                        work_products.insert(id, wp);
                    }
                    if !sess.opts.cg.save_temps {
                        let _ = std::fs::remove_file(&side);
                    }
                }
                ImageSave::Reused(wp, from) => {
                    if let (Some(m), Some(from)) = (&mut m, from) {
                        m.links_from_incr_cache.push(from);
                    }
                    work_products.insert(rustc_middle::dep_graph::WorkProductId::from_cgu_name(&wp_name), wp);
                }
            }
            modules.modules.extend(m);
        }
        (modules, work_products)
    }

    fn print_pass_timings(&self) {
        self.llvm.print_pass_timings()
    }

    fn print_statistics(&self) {
        self.llvm.print_statistics()
    }

    fn print_statistics_json(&self) -> String {
        self.llvm.print_statistics_json()
    }

    fn link(&self, sess: &Session, compiled_modules: CompiledModules, crate_info: CrateInfo, metadata: EncodedMetadata, outputs: &OutputFilenames) {
        link::link(&*self.llvm, self.link_info.get(), sess, compiled_modules, crate_info, metadata, outputs)
    }
}

/// A `CompiledModule` for an object file the backend wrote itself.
fn object_module(name: String, object: PathBuf) -> CompiledModule {
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

/// The image and registry objects' format for the session's target (design/platforms.md).
/// Mach-O only for macOS, with its deployment target.
pub(crate) fn object_format(sess: &Session) -> Box<dyn objfile::ObjectFormat> {
    let target = &sess.target;
    let mut macos_min = 0;
    if target.binary_format == rustc_target::spec::BinaryFormat::MachO {
        if target.os != rustc_target::spec::Os::MacOs {
            sess.dcx().fatal(format!("the ryo backend supports Mach-O for macOS only, not {}", target.llvm_target));
        }
        let v = sess.apple_deployment_target();
        macos_min = (u32::from(v.major) << 16) | (u32::from(v.minor) << 8) | u32::from(v.patch);
    }
    objfile::format_for(binary_format(&target.binary_format), macos_min).unwrap_or_else(|e| sess.dcx().fatal(e))
}

fn binary_format(f: &rustc_target::spec::BinaryFormat) -> object::BinaryFormat {
    match f {
        rustc_target::spec::BinaryFormat::Elf => object::BinaryFormat::Elf,
        rustc_target::spec::BinaryFormat::Coff => object::BinaryFormat::Coff,
        rustc_target::spec::BinaryFormat::MachO => object::BinaryFormat::MachO,
        rustc_target::spec::BinaryFormat::Wasm => object::BinaryFormat::Wasm,
        rustc_target::spec::BinaryFormat::Xcoff => object::BinaryFormat::Xcoff,
    }
}

/// What `codegen_crate` returns: cg_llvm's ongoing codegen, plus the image objects
/// (design/backend.md#pipeline step 5).
struct RyoOngoingCodegen {
    llvm: Box<dyn Any>,
    images: Vec<OngoingImage>,
}

/// An image object of `codegen_crate`: its CGU, module name and path (none for a CGU without
/// VM functions, which has only side data), and how its work product is saved.
struct OngoingImage {
    cgu: String,
    name: String,
    path: Option<PathBuf>,
    save: ImageSave,
}

enum ImageSave {
    /// Written this session, with its side data at this path.
    Fresh(PathBuf),
    /// The previous session's work product, and the cached object it was copied from.
    Reused(rustc_middle::dep_graph::WorkProduct, Option<PathBuf>),
}
