//! Every use of rustc's internal APIs goes through this module (design/build.md#toolchain).
//!
//! - this file: the `CodegenBackend` impl and the query overrides
//! - [`partition`]: pipeline steps 1–4 and the image contents
//! - [`lower`]: MIR → bytecode
//! - [`link`]: step 6, one `link_binary` per crate type with its registry object


mod link;
mod lower;
mod partition;

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
    /// Set by `codegen_crate` for `link`, which has no `tcx`.
    link_info: OnceLock<link::LinkInfo>,
}

impl RyoBackend {
    pub fn new() -> BoxedBackend {
        Box::new(RyoBackend { llvm: rustc_codegen_llvm::LlvmCodegenBackend::new(), link_info: OnceLock::new() })
    }
}

/// The type of a `collect_and_partition_mono_items` provider (`rustc_middle/src/queries.rs:2450`,
/// providers are `for<'tcx> fn(TyCtxt<'tcx>, Key) -> Value`, `rustc_middle/src/query/plumbing.rs:489-495`).
type PartitionProvider = for<'tcx> fn(TyCtxt<'tcx>, ()) -> MonoItemPartitions<'tcx>;
type SymbolNameProvider = for<'tcx> fn(TyCtxt<'tcx>, Instance<'tcx>) -> ty::SymbolName<'tcx>;
type ExportedProvider = for<'tcx> fn(TyCtxt<'tcx>, LocalCrate) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)];

/// The default providers, saved in `provide`. Statics, because providers are plain fns.
struct Originals {
    partition: PartitionProvider,
    symbol_name: SymbolNameProvider,
    exported_generic_symbols: ExportedProvider,
}

static ORIGINALS: OnceLock<Originals> = OnceLock::new();

fn originals() -> &'static Originals {
    ORIGINALS.get().expect("provide() didn't save the original providers")
}

fn collect_and_partition_mono_items<'tcx>(tcx: TyCtxt<'tcx>, (): ()) -> MonoItemPartitions<'tcx> {
    partition::collect_and_partition_mono_items(tcx, originals().partition)
}

fn symbol_name<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> ty::SymbolName<'tcx> {
    partition::symbol_name(tcx, instance, || (originals().symbol_name)(tcx, instance))
}

fn exported_generic_symbols<'tcx>(
    tcx: TyCtxt<'tcx>,
    krate: LocalCrate,
) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    partition::exported_generic_symbols(tcx, (originals().exported_generic_symbols)(tcx, krate))
}

impl CodegenBackend for RyoBackend {
    fn name(&self) -> &'static str {
        "ryo"
    }

    fn init(&self, sess: &Session) {
        if std::env::var_os("RYO_BACKEND_MARKER").is_some() {
            eprintln!("{INIT_MARKER}");
        }
        // Incremental compilation is a non-goal (design/README.md): the portal symbols and the
        // image come from per-session state that the query system doesn't track, so reused
        // objects could carry stale symbols.
        if sess.opts.incremental.is_some() {
            sess.dcx().fatal(
                "the ryo backend doesn't support incremental compilation; remove `-Cincremental` \
                 (cargo-ryo sets CARGO_INCREMENTAL=0)",
            );
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
        });
        q.collect_and_partition_mono_items = collect_and_partition_mono_items;
        q.symbol_name = symbol_name;
        q.exported_generic_symbols = exported_generic_symbols;
    }

    fn target_cpu(&self, sess: &Session) -> String {
        self.llvm.target_cpu(sess)
    }

    fn codegen_crate<'tcx>(&self, tcx: TyCtxt<'tcx>) -> Box<dyn Any> {
        // Usually already computed (metadata encoding, `exported_generic_symbols`); this forces
        // it otherwise, so the results are set.
        let partitions = tcx.collect_and_partition_mono_items(());
        let results = partition::results(tcx).expect("collect_and_partition_mono_items didn't run our provider");
        assert_eq!(partitions.codegen_units[0].name(), results.cgu_name);
        let fmt = match objfile::format_for(binary_format(&tcx.sess.target.binary_format)) {
            Ok(f) => f,
            Err(e) => tcx.dcx().fatal(e),
        };
        let scid = partition::local_stable_crate_id(tcx);
        // Step 5: the image object (design/backend.md#pipeline).
        let image_name = format!("{}.ryo_image", results.cgu_name);
        let image_path = tcx.output_filenames(()).temp_path_for_cgu(OutputType::Object, &image_name);
        let bytes = objfile::write_image(&*fmt, &results.image, scid, results.main_portal.as_deref())
            .unwrap_or_else(|e| tcx.dcx().fatal(e));
        if let Err(e) = std::fs::write(&image_path, bytes) {
            tcx.dcx().fatal(format!("writing {}: {e}", image_path.display()));
        }
        let _ = self.link_info.set(link::LinkInfo {
            local_image: objfile::image_symbol(scid),
            binary_format: binary_format(&tcx.sess.target.binary_format),
        });
        // The native CGU (step 4), compiled by cg_llvm as usual.
        let llvm = self.llvm.codegen_crate(tcx);
        Box::new(RyoOngoingCodegen { llvm, image: (image_name, image_path) })
    }

    fn join_codegen(
        &self,
        ongoing_codegen: Box<dyn Any>,
        sess: &Session,
        incr_comp_session: Option<&IncrCompSession>,
        outputs: &OutputFilenames,
        crate_info: &CrateInfo,
    ) -> (CompiledModules, WorkProductMap) {
        let ongoing = ongoing_codegen
            .downcast::<RyoOngoingCodegen>()
            .expect("expected RyoOngoingCodegen from RyoBackend::codegen_crate");
        // cg_llvm downcasts this to its own `OngoingCodegen` (`rustc_codegen_llvm/src/lib.rs:407-410`).
        let (mut modules, work_products) =
            self.llvm.join_codegen(ongoing.llvm, sess, incr_comp_session, outputs, crate_info);
        // The image, so `link_rlib` and the object list include it (design/backend.md#pipeline
        // step 5).
        let (name, path) = ongoing.image;
        modules.modules.push(object_module(name, path));
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

    fn link(
        &self,
        sess: &Session,
        compiled_modules: CompiledModules,
        crate_info: CrateInfo,
        metadata: EncodedMetadata,
        outputs: &OutputFilenames,
    ) {
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

/// The image symbol flags for a `sym` operand naming `target` (design/platforms.md): on PE,
/// every symbol defined outside this crate (an upstream crate's, or a foreign item) gets an
/// indirect slot ([`SYM_INDIRECT`](ryo_bytecode::image::SYM_INDIRECT)), relocated against its
/// `__imp_` import slot. The instruction using the operand must then be the `.ind` form
/// (`addr.sym.ind`, `call.ext.ind`). `island` operands and the `island` of `call.ext` are
/// always direct: islands are only called, never compared, so an import thunk will do.
pub(crate) fn symbol_flags<'tcx>(tcx: TyCtxt<'tcx>, target: Instance<'tcx>) -> u8 {
    let pe = matches!(tcx.sess.target.binary_format, rustc_target::spec::BinaryFormat::Coff);
    if pe && !tcx.should_codegen_locally(target) { ryo_bytecode::image::SYM_INDIRECT } else { 0 }
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
/// and path (design/backend.md#pipeline step 5).
struct RyoOngoingCodegen {
    llvm: Box<dyn Any>,
    image: (String, PathBuf),
}
