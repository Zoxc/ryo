//! Every use of rustc's internal APIs goes through this module (design/build.md#toolchain).

extern crate rustc_codegen_llvm;
extern crate rustc_codegen_ssa;
extern crate rustc_metadata;
extern crate rustc_middle;
extern crate rustc_session;
extern crate rustc_span;

// Links the compiler's own `librustc_driver` dylib, which holds all the crates above.
extern crate rustc_driver;

use std::any::Any;
use std::sync::OnceLock;

use rustc_codegen_ssa::traits::CodegenBackend;
use rustc_codegen_ssa::{CompiledModules, CrateInfo, TargetConfig};
use rustc_metadata::EncodedMetadata;
use rustc_metadata::creader::MetadataLoaderDyn;
use rustc_middle::dep_graph::WorkProductMap;
use rustc_middle::mono::{CodegenUnit, MonoItemPartitions};
use rustc_middle::ty::TyCtxt;
use rustc_middle::util::Providers;
use rustc_session::config::{CrateType, OutputFilenames, PrintRequest};
use rustc_session::{IncrCompSession, Session};
use rustc_span::Symbol;

pub type BoxedBackend = Box<dyn CodegenBackend>;

/// The ryo backend. Currently forwards every method to cg_llvm.
pub struct RyoBackend {
    llvm: Box<dyn CodegenBackend>,
}

impl RyoBackend {
    pub fn new() -> BoxedBackend {
        Box::new(RyoBackend { llvm: rustc_codegen_llvm::LlvmCodegenBackend::new() })
    }
}

impl CodegenBackend for RyoBackend {
    fn name(&self) -> &'static str {
        "ryo"
    }

    fn init(&self, sess: &Session) {
        // Lets `y test` check that this backend, not plain cg_llvm, compiled the crate.
        if std::env::var_os("RYO_BACKEND_MARKER").is_some() {
            eprintln!("ryo backend: init");
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
        // The default provider is `rustc_monomorphize`'s, installed before the backend's
        // `provide` runs (`rustc_interface/src/passes.rs:980-981`). `provide` runs once per
        // session, and the provider is a plain fn, so a second session would find the same one.
        let original = providers.queries.collect_and_partition_mono_items;
        let _ = ORIGINAL_PARTITION.set(original);
        providers.queries.collect_and_partition_mono_items = collect_and_partition_mono_items;
    }

    fn target_cpu(&self, sess: &Session) -> String {
        self.llvm.target_cpu(sess)
    }

    fn codegen_crate<'tcx>(&self, tcx: TyCtxt<'tcx>) -> Box<dyn Any> {
        // Usually already computed (metadata encoding, `exported_generic_symbols`); this forces
        // it otherwise, so `PARTITION` is set.
        let partitions = tcx.collect_and_partition_mono_items(());
        let info = PARTITION.get().expect("collect_and_partition_mono_items didn't run our provider");
        debug_assert_eq!(partitions.codegen_units[0].name(), info.cgu_name);
        // The native CGU (design/backend.md#pipeline step 4); compiled by cg_llvm as usual.
        let llvm = self.llvm.codegen_crate(tcx);
        Box::new(RyoOngoingCodegen { llvm })
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
        let (modules, work_products) =
            self.llvm.join_codegen(ongoing.llvm, sess, incr_comp_session, outputs, crate_info);
        // The image's `CompiledModule` is pushed onto `modules.modules` here once it exists
        // (design/backend.md#pipeline step 5).
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
        // One `link_binary` call per crate type comes later (design/backend.md#pipeline step 6).
        self.llvm.link(sess, compiled_modules, crate_info, metadata, outputs)
    }
}

/// What `codegen_crate` returns: cg_llvm's ongoing codegen, plus (later) the image path
/// (design/backend.md#pipeline step 5).
struct RyoOngoingCodegen {
    llvm: Box<dyn Any>,
}

/// The type of a `collect_and_partition_mono_items` provider (`rustc_middle/src/queries.rs:2450`,
/// providers are `for<'tcx> fn(TyCtxt<'tcx>, Key) -> Value`, `rustc_middle/src/query/plumbing.rs:489-495`).
type PartitionProvider = for<'tcx> fn(TyCtxt<'tcx>, ()) -> MonoItemPartitions<'tcx>;

/// The default provider, saved in `provide`. A static, because providers are plain fns.
static ORIGINAL_PARTITION: OnceLock<PartitionProvider> = OnceLock::new();

/// What our partition provider hands to `codegen_crate`. The query is `eval_always` and computed
/// once per session, so this is set once. Later packages add the bytecode results here.
struct PartitionResults {
    /// The name of the single (native) CGU, which `codegen_unit(name)` looks up.
    cgu_name: Symbol,
}

static PARTITION: OnceLock<PartitionResults> = OnceLock::new();

/// Our `collect_and_partition_mono_items` (design/backend.md#pipeline steps 1 and 4): run the
/// original, require exactly one CGU, and return a rebuilt copy of it. For now the copy has the
/// same items; later the VM functions are removed and the stub instances added.
fn collect_and_partition_mono_items<'tcx>(tcx: TyCtxt<'tcx>, (): ()) -> MonoItemPartitions<'tcx> {
    // `rustc-ryo` forces `-Ccodegen-units=1` (`rustc_session/src/session.rs:1058`).
    let n = tcx.sess.codegen_units().as_usize();
    if n != 1 {
        tcx.dcx().fatal(format!(
            "the ryo backend requires `-Ccodegen-units=1`, but {n} codegen units were requested"
        ));
    }
    let original = ORIGINAL_PARTITION.get().expect("provide() didn't save the original provider");
    let partitions = original(tcx, ());
    // With one CGU requested, merging always leaves exactly one, and partitioning never returns
    // none (`rustc_monomorphize/src/partitioning.rs:286-288`).
    let [cgu] = partitions.codegen_units else {
        tcx.dcx().fatal(format!(
            "the ryo backend expected one codegen unit, got {}",
            partitions.codegen_units.len()
        ));
    };
    let native = rebuild_cgu(cgu);
    if PARTITION.set(PartitionResults { cgu_name: native.name() }).is_err() {
        tcx.dcx().fatal("collect_and_partition_mono_items ran twice in one process");
    }
    MonoItemPartitions {
        // `CodegenUnit` is arena-allocated (`rustc_middle/src/arena.rs:107`).
        codegen_units: tcx.arena.alloc_from_iter([native]),
        // Keeps every original DefId, VM functions included (design/backend.md#query-overrides).
        all_mono_items: partitions.all_mono_items,
    }
}

/// A copy of `cgu` built through the public `CodegenUnit` API (`rustc_middle/src/mono.rs:408-510`):
/// same name, symbol name, items with their linkage/visibility, primary and coverage flags.
fn rebuild_cgu<'tcx>(cgu: &CodegenUnit<'tcx>) -> CodegenUnit<'tcx> {
    let mut new = CodegenUnit::new(cgu.name());
    // Set by `merge_codegen_units` for every CGU (`rustc_monomorphize/src/partitioning.rs:462-507`).
    new.set_symbol_name(cgu.symbol_name());
    if cgu.is_primary() {
        new.make_primary();
    }
    if cgu.is_code_coverage_dead_code_cgu() {
        new.make_code_coverage_dead_code_cgu();
    }
    new.items_mut().extend(cgu.items().iter().map(|(item, data)| (*item, *data)));
    new.compute_size_estimate();
    new
}
