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

use rustc_codegen_ssa::traits::CodegenBackend;
use rustc_codegen_ssa::{CompiledModules, CrateInfo, TargetConfig};
use rustc_metadata::EncodedMetadata;
use rustc_metadata::creader::MetadataLoaderDyn;
use rustc_middle::dep_graph::WorkProductMap;
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
        self.llvm.provide(providers)
    }

    fn target_cpu(&self, sess: &Session) -> String {
        self.llvm.target_cpu(sess)
    }

    fn codegen_crate<'tcx>(&self, tcx: TyCtxt<'tcx>) -> Box<dyn Any> {
        self.llvm.codegen_crate(tcx)
    }

    fn join_codegen(
        &self,
        ongoing_codegen: Box<dyn Any>,
        sess: &Session,
        incr_comp_session: Option<&IncrCompSession>,
        outputs: &OutputFilenames,
        crate_info: &CrateInfo,
    ) -> (CompiledModules, WorkProductMap) {
        self.llvm.join_codegen(ongoing_codegen, sess, incr_comp_session, outputs, crate_info)
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
        self.llvm.link(sess, compiled_modules, crate_info, metadata, outputs)
    }
}
