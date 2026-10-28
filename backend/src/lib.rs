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
extern crate rustc_crate_store;
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
type DylibFormatsProvider =
    for<'tcx> fn(TyCtxt<'tcx>, rustc_hir::def_id::CrateNum) -> &'tcx [(rustc_hir::def_id::CrateNum, rustc_crate_store::LinkagePreference)];

/// The default providers, saved in `provide`. Statics, because providers are plain fns.
struct Originals {
    partition: PartitionProvider,
    symbol_name: SymbolNameProvider,
    exported_generic_symbols: ExportedProvider,
    upstream_monomorphizations: UpstreamProvider,
    dylib_dependency_formats: DylibFormatsProvider,
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

fn upstream_monomorphizations<'tcx>(tcx: TyCtxt<'tcx>, (): ()) -> partition::UpstreamMonos<'tcx> {
    partition::upstream_monomorphizations(tcx, (originals().upstream_monomorphizations)(tcx, ()))
}

/// An upstream Rust dylib's dependency formats without the runtime crates (`ryo_rt`,
/// `ryo_bytecode`): every final artifact links its own, private copy of the runtime, never
/// one included in a dylib, so sibling dylibs don't both provide it (rustc's "only shows up
/// once" error), and no dylib exports it ([`link::LinkInfo::runtime_exports`]). Copies of one ryo build
/// merge at run time (design/vm.md#several-ryo-runtimes-in-one-process).
fn dylib_dependency_formats<'tcx>(
    tcx: TyCtxt<'tcx>,
    cnum: rustc_hir::def_id::CrateNum,
) -> &'tcx [(rustc_hir::def_id::CrateNum, rustc_crate_store::LinkagePreference)] {
    let all = (originals().dylib_dependency_formats)(tcx, cnum);
    if !all.iter().any(|(c, _)| partition::is_runtime_crate(tcx, *c)) {
        return all;
    }
    tcx.arena.alloc_from_iter(all.iter().copied().filter(|(c, _)| !partition::is_runtime_crate(tcx, *c)))
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
        if let Some(why) = unsupported(sess) {
            sess.dcx().fatal(format!("the ryo backend doesn't support {why} (design/backend.md#unsupported-options)"));
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

    /// No: rustc's implicit crate-local ThinLTO (opt-level >= 1 with several codegen units)
    /// internalizes every symbol below the `Rust` export level that isn't listed, including
    /// native items only an image refers to, which LTO doesn't see. `false` makes
    /// `Session::lto` return `Lto::No` for it; explicit LTO is rejected in `init`.
    fn thin_lto_supported(&self) -> bool {
        false
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
            upstream_monomorphizations: q.upstream_monomorphizations,
            dylib_dependency_formats: providers.extern_queries.dylib_dependency_formats,
        });
        providers.extern_queries.dylib_dependency_formats = dylib_dependency_formats;
        q.collect_and_partition_mono_items = collect_and_partition_mono_items;
        q.symbol_name = symbol_name;
        q.exported_generic_symbols = exported_generic_symbols;
        q.upstream_monomorphizations = upstream_monomorphizations;
    }

    fn target_cpu(&self, sess: &Session) -> String {
        self.llvm.target_cpu(sess)
    }

    fn codegen_crate<'tcx>(&self, tcx: TyCtxt<'tcx>) -> Box<dyn Any> {
        if let Some(why) = unsupported_features(tcx.sess) {
            tcx.dcx().fatal(format!("the ryo backend doesn't support {why} (design/backend.md#unsupported-options)"));
        }
        // Usually already computed (metadata encoding, `exported_generic_symbols`); this forces
        // it otherwise, so the results are set.
        let _ = tcx.collect_and_partition_mono_items(());
        // A crate with no VM code has no image (`partition::vm_enabled`); its output still
        // registers its upstream crates' images.
        let results = partition::results(tcx);
        let images = results.map(|r| write_images(tcx, r)).unwrap_or_default();
        let modules = images.iter().filter(|i| i.path.is_some()).map(|i| i.name.clone()).collect();
        let _ = self.link_info.set(link::LinkInfo::new(tcx, modules));
        if let Some(results) = results {
            dump_lean::dump(tcx, &self.switches, results);
        }
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

/// Why the session can't be built with ryo, if it can't: options whose effect VM code can't
/// have (instrumentation, sanitizers, hardening), LTO in any form, options that bypass ryo's
/// link step, and targets the images can't be made for. Checked in `init`, for every crate:
/// most crates have VM code, and one without (a proc macro, `RYO_NO_VM`) may still link
/// upstream images; so do the target checks, as `link` needs the object format for the
/// registry object even then (design/backend.md#unsupported-options).
fn unsupported(sess: &Session) -> Option<String> {
    use rustc_session::config::{CFGuard, CFProtection, FunctionReturn, InstrumentCoverage, InstrumentMcount, LtoCli};
    // `target` is the parsed spec, so this covers custom target JSON too.
    let target = &sess.target;
    if target.arch != rustc_target::spec::Arch::X86_64 || target.pointer_width != 64 {
        return Some(format!("the target `{}`: the VM is x86_64 only", target.llvm_target));
    }
    if symbols::is_macho(sess) && target.os != rustc_target::spec::Os::MacOs {
        return Some(format!("the target `{}`: Mach-O is supported for x86_64 macOS only", target.llvm_target));
    }
    if target.requires_lto {
        return Some(format!("the target `{}`, which requires LTO", target.llvm_target));
    }
    // A soft-float ABI passes floats in general registers, where VM signatures use xmm; the
    // handlers and VM code use SSE besides. The flag forms (`+soft-float`, `-sse2`), for which
    // rustc only warns, are checked in `codegen_crate` ([`unsupported_features`]).
    if let Some(abi) = target.rustc_abi {
        return Some(format!("the target `{}` with the `{abi:?}` ABI (soft-float)", target.llvm_target));
    }
    // The PE import rules (`symbols::symbol_flags`, cg_llvm's on MSVC) and the SEH handler
    // assume MSVC: on MinGW cg_llvm leaves functions' `dllimport` to GNU ld, which doesn't
    // synthesize `__imp_` for static definitions, and its targets unwind with the GCC
    // personality.
    if target.binary_format == rustc_target::spec::BinaryFormat::Coff && target.env != rustc_target::spec::Env::Msvc {
        return Some(format!("the target `{}`: PE is supported for windows-msvc only", target.llvm_target));
    }
    let (c, z) = (&sess.opts.cg, &sess.opts.unstable_opts);
    let flags = [
        // LTO: the images are separate objects LTO doesn't see, so it would internalize or
        // drop what only they refer to; linker-plugin LTO also makes the rlib's Rust objects
        // bitcode, whose symbols the rebuilt archive index (`link::append_to_rlib`) lacks.
        (!matches!(c.lto, LtoCli::Unspecified | LtoCli::No), "`-Clto`"),
        (c.linker_plugin_lto.enabled(), "`-Clinker-plugin-lto`"),
        (z.dylib_lto, "`-Zdylib-lto`"),
        // (`-Zthinlto=yes` needs no check: with `thin_lto_supported() == false`,
        // `Session::lto` returns `No` before it reads it.)
        // Instrumentation and hardening VM code would silently lack: sanitizer checks (and
        // CFI/KCFI type checks that trap on VM functions), CET (`endbr64`, and the property
        // note whose absence turns CET off for the whole binary), CFG tables, coverage and
        // profile counters, XRay and mcount hooks, patchable entries, stack protectors and
        // the Spectre thunks.
        // The effective set: `-Zsanitizer` plus the target's default sanitizers.
        (!sess.sanitizers().is_empty(), "sanitizers (`-Zsanitizer` or the target's default sanitizers)"),
        (z.cf_protection != CFProtection::None, "`-Zcf-protection`"),
        (c.control_flow_guard != CFGuard::Disabled, "`-Ccontrol-flow-guard`"),
        (z.ehcont_guard, "`-Zehcont-guard`"),
        (c.instrument_coverage != InstrumentCoverage::No, "`-Cinstrument-coverage`"),
        (c.profile_generate.enabled(), "`-Cprofile-generate`"),
        (z.instrument_xray.is_some(), "`-Zinstrument-xray`"),
        (!matches!(z.instrument_mcount, InstrumentMcount::Disabled), "`-Zinstrument-mcount`"),
        (z.patchable_function_entry != Default::default(), "`-Zpatchable-function-entry`"),
        // The images lay out VM functions at their own alignment.
        (z.min_function_alignment.is_some(), "`-Zmin-function-alignment`"),
        (z.stack_protector != rustc_target::spec::StackProtector::None, "`-Zstack-protector`"),
        // (`-Zretpoline-external-thunk` sets `retpoline` too.)
        (z.retpoline_external_thunk, "`-Zretpoline-external-thunk`"),
        (z.retpoline, "`-Zretpoline`"),
        (z.function_return != FunctionReturn::Keep, "`-Zfunction-return`"),
        (z.indirect_branch_cs_prefix, "`-Zindirect-branch-cs-prefix`"),
        // Tuple layouts (island argument blocks) must agree between crates.
        (z.randomize_layout, "`-Zrandomize-layout`"),
        // The images use rel32 calls and RIP-relative addressing, which need the small
        // model's 2 GiB reach (`kernel` is for kernels, which are soft-float anyway).
        // The effective model: `-Ccode-model`, else the target's.
        (
            sess.code_model().is_some_and(|m| m != rustc_target::spec::CodeModel::Small),
            "a code model other than `small` (`-Ccode-model` or the target's)",
        ),
        // cg_llvm's Enzyme and offload passes see only its own modules, not VM code.
        (!z.autodiff.is_empty(), "`-Zautodiff`"),
        (!z.offload.is_empty(), "`-Zoffload`"),
        // `-Zno-link` saves the modules in an `.rlink` and `-Zlink-only` links them without
        // `codegen_crate`, so without the registry object.
        (z.no_link, "`-Zno-link`"),
        (z.link_only, "`-Zlink-only`"),
        // The staticlib options rewrite or hide the Rust objects' symbols, but not the
        // upstream images, which are plain members: renamed symbols they refer to don't
        // resolve, and their own symbols aren't hidden.
        (z.staticlib_rename_internal_symbols, "`-Zstaticlib-rename-internal-symbols`"),
        (z.staticlib_hide_internal_symbols, "`-Zstaticlib-hide-internal-symbols`"),
    ];
    flags.into_iter().find(|f| f.0).map(|f| f.1.to_owned())
}

/// [`unsupported`]'s soft-float check for `-Ctarget-feature`: rustc fills
/// `internal_target_features` only after `init` (`rustc_interface/src/interface.rs`), and
/// only warns about `+soft-float` and `-sse2`.
fn unsupported_features(sess: &Session) -> Option<String> {
    let features = &sess.internal_target_features;
    if features.contains(&Symbol::intern("soft-float")) {
        return Some("the `soft-float` target feature".to_owned());
    }
    if !features.contains(&Symbol::intern("sse2")) {
        return Some("disabling the `sse2` target feature (soft-float)".to_owned());
    }
    // LLVM's Spectre and LVI hardening, which rustc passes to LLVM by their LLVM names (it
    // only warns that they aren't Rust features): VM code would silently lack it, as with
    // `-Zretpoline`. The target's features, then `-Ctarget-feature`; the last sign wins.
    const HARDENING: [&str; 9] = [
        "retpoline",
        "retpoline-indirect-calls",
        "retpoline-indirect-branches",
        "retpoline-external-thunk",
        "lvi-cfi",
        "lvi-load-hardening",
        "seses",
        "harden-sls-ret",
        "harden-sls-ijmp",
    ];
    let mut on: Vec<&str> = Vec::new();
    for f in sess.target.features.split(',').chain(sess.opts.cg.target_feature.split(',')) {
        let f = f.trim();
        let (enable, name) = match f.split_at_checked(1) {
            Some(("+", n)) => (true, n),
            Some(("-", n)) => (false, n),
            _ => continue,
        };
        if let Some(&h) = HARDENING.iter().find(|&&h| h == name) {
            on.retain(|&o| o != h);
            if enable {
                on.push(h);
            }
        }
    }
    on.first().map(|h| format!("the `{h}` target feature"))
}

/// Step 5 (design/backend.md#pipeline): writes the image objects, one per CGU with VM
/// functions, or places the previous session's.
fn write_images(tcx: TyCtxt<'_>, results: &partition::Results) -> Vec<OngoingImage> {
    let _t = tcx.prof.generic_activity("ryo_write_image");
    let fmt = object_format(tcx.sess);
    let mut images = Vec::with_capacity(results.images.len());
    for img in &results.images {
        // Side data alone is only for the incremental cache.
        if !img.has_object() && tcx.sess.opts.incremental.is_none() {
            continue;
        }
        let name = format!("{}.ryo_image", img.cgu_name);
        let image_path = tcx.output_filenames(()).temp_path_for_cgu(OutputType::Object, &name);
        let save = match &img.image {
            partition::ImageSrc::Fresh { image, side } => write_fresh_image(tcx, &*fmt, img, image.as_ref(), side, &image_path),
            partition::ImageSrc::Reused(wp) => place_reused_image(tcx, wp, &image_path),
        };
        let path = img.has_object().then_some(image_path);
        images.push(OngoingImage { cgu: img.cgu_name.to_string(), name, path, save });
    }
    images
}

/// Writes a CGU's image object (if it has one) and its side data.
fn write_fresh_image(
    tcx: TyCtxt<'_>,
    fmt: &dyn objfile::ObjectFormat,
    img: &partition::CguImage,
    image: Option<&ryo_bytecode::image::ImageObject>,
    side: &[u8],
    image_path: &std::path::Path,
) -> ImageSave {
    // A file left by `-Csave-temps` may still be a hard link into the incremental cache (a
    // reused image's); writing through it would change the cached copy.
    let write = |p: &std::path::Path, bytes: &[u8]| {
        let _ = std::fs::remove_file(p);
        link::write_or_fatal(tcx.sess, p, bytes);
    };
    let side_path = image_path.with_extension("ryo");
    write(&side_path, side);
    if let Some(image) = image {
        let scid = symbols::local_stable_crate_id(tcx);
        let cgu_hash = ryo_bytecode::image::cgu_hash(img.cgu_name.as_str().as_bytes());
        let bytes = objfile::write_image(fmt, image, scid, cgu_hash, img.main_symbol.as_deref(), &|name: &str| symbols::rt_symbol(tcx, name))
            .unwrap_or_else(|e| tcx.dcx().fatal(e));
        write(image_path, &bytes);
    }
    ImageSave::Fresh(side_path)
}

/// Places the previous session's image object, as cg_ssa reuses a CGU's
/// (`execute_copy_from_cache_work_item`).
fn place_reused_image(tcx: TyCtxt<'_>, wp: &rustc_middle::dep_graph::WorkProduct, image_path: &std::path::Path) -> ImageSave {
    let incr = tcx.incr_comp_session.expect("a reused image without an incremental session");
    let from = wp.saved_files.get("o").map(|f| rustc_incremental::in_incr_comp_dir_sess(incr, f));
    if let Some(from) = &from {
        let _ = std::fs::remove_file(image_path);
        link::link_or_copy(tcx.sess, from, image_path);
    }
    ImageSave::Reused(wp.clone(), from)
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
/// Mach-O only for macOS (`init` rejects other Mach-O targets), with its deployment target.
pub(crate) fn object_format(sess: &Session) -> Box<dyn objfile::ObjectFormat> {
    let target = &sess.target;
    let mut macos_min = 0;
    if symbols::is_macho(sess) {
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
