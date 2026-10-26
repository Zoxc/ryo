//! Every use of rustc's internal APIs goes through this module (design/build.md#toolchain).
//!
//! - this file: the `CodegenBackend` impl and the query overrides
//! - [`partition`]: pipeline steps 1–4 and the image contents
//! - [`lower`]: MIR → bytecode
//! - [`symbols`]: the image's symbol names and linkage (PE imports)
//! - [`link`]: step 6, one `link_binary` per crate type with its registry object
//! - [`dump`]: `RYO_DUMP` / `RYO_DUMP_CODE`, the VM functions as text
//! - [`dump_lean`]: `RYO_DUMP_LEAN`, the program as the Lean MIR spec's input (lean/)

mod dump;
mod dump_lean;
mod json;
mod link;
mod lower;
mod partition;
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

use crate::objfile;

pub type BoxedBackend = Box<dyn CodegenBackend>;

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
            let _ = self.link_info.set(link::LinkInfo { image: None, linked_roots: linked_roots(), macho });
            let llvm = self.llvm.codegen_crate(tcx);
            return Box::new(RyoOngoingCodegen { llvm, image: None });
        };
        assert_eq!(partitions.codegen_units[0].name(), results.cgu_name);
        let fmt = object_format(tcx.sess);
        let scid = symbols::local_stable_crate_id(tcx);
        // Step 5: the image object (design/backend.md#pipeline).
        let image_name = format!("{}.ryo_image", results.cgu_name);
        let image_path = tcx.output_filenames(()).temp_path_for_cgu(OutputType::Object, &image_name);
        let rt_symbol = |name: &str| symbols::rt_symbol(tcx, name);
        let write_t = tcx.prof.generic_activity("ryo_write_image");
        let cgu_hash = ryo_bytecode::image::cgu_hash(results.cgu_name.as_str().as_bytes());
        let bytes = objfile::write_image(&*fmt, &results.image, scid, cgu_hash, results.main_symbol.as_deref(), &rt_symbol)
            .unwrap_or_else(|e| tcx.dcx().fatal(e));
        if let Err(e) = std::fs::write(&image_path, bytes) {
            tcx.dcx().fatal(format!("writing {}: {e}", image_path.display()));
        }
        drop(write_t);
        let _ =
            self.link_info.set(link::LinkInfo { image: Some(link::LocalImage { module: image_name.clone() }), linked_roots: linked_roots(), macho });
        dump_lean::dump(tcx, &self.switches, results);
        // The native CGU (step 4), compiled by cg_llvm as usual.
        let llvm = self.llvm.codegen_crate(tcx);
        Box::new(RyoOngoingCodegen { llvm, image: Some((image_name, image_path)) })
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
        let (mut modules, work_products) = self.llvm.join_codegen(ongoing.llvm, sess, incr_comp_session, outputs, crate_info);
        // The image, so `link_rlib` and the object list include it (design/backend.md#pipeline
        // step 5).
        if let Some((name, path)) = ongoing.image {
            modules.modules.push(object_module(name, path));
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

/// What `codegen_crate` returns: cg_llvm's ongoing codegen, plus the image object's module name
/// and path if the crate has one (design/backend.md#pipeline step 5).
struct RyoOngoingCodegen {
    llvm: Box<dyn Any>,
    image: Option<(String, PathBuf)>,
}
