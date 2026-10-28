//! Pipeline steps 1–4 (design/backend.md#pipeline), run inside our
//! `collect_and_partition_mono_items`: collect, classify, lower, build the native CGU. Also
//! builds the image (step 5's contents; `codegen_crate` writes it), and the `symbol_name` and
//! exported-symbols overrides that depend on these results.

use std::sync::OnceLock;

use rustc_data_structures::fx::{FxHashMap, FxHashSet, FxIndexMap};
use rustc_data_structures::unord::UnordSet;
use rustc_hir::attrs::Linkage;
use rustc_hir::def_id::{CrateNum, DefId, LOCAL_CRATE};
use rustc_middle::middle::exported_symbols::{ExportedSymbol, SymbolExportInfo, SymbolExportKind, SymbolExportLevel};
use rustc_middle::mir::interpret::{AllocId, GlobalAlloc};
use rustc_middle::mono::{CodegenUnit, CollectionMode, MonoItem, MonoItemData, MonoItemPartitions, Visibility};
use rustc_middle::ty::{self, Instance, InstanceKind, Ty, TyCtxt, TypingEnv};
use rustc_session::config::{CrateType, EntryFnType, OutputType};
use rustc_span::Symbol;
use ryo_bytecode::asm::{self, Ref};
use ryo_bytecode::full::{Const, Data, Func, Sym};
use ryo_bytecode::image::{AllocFixup, AllocReloc, AllocTarget, FuncSymbol, FunctionDef, ImageObject, ImageWriter, SYM_INDIRECT, SymVisibility};

use rustc_middle::dep_graph::{WorkProduct, WorkProductId};

use super::dump;
use super::lower::{self, CodeReloc, LowerCx, LoweredFn, NeedsNative};
use super::persist;
use super::switches::Switches;
use super::symbols::{self, local_stable_crate_id, static_symbol};

/// The `ryo_rt` items the backend instantiates or checks (design/stubs.md, Lookup).
#[derive(Clone, Copy)]
pub struct RtItems {
    pub krate: CrateNum,
    pub c_main: DefId,
    /// `ryo_rt::vm::FP_ARG`: whether its handlers take `fp` in `rdi`.
    pub fp_arg: DefId,
}

/// A value computed once per session and kept in a static. Only [`Results`] needs one: the
/// partition provider hands it to the exported-symbols providers, and query providers are plain
/// fns with no per-session slot to reach (rustc_codegen_cranelift overrides no queries, so it
/// keeps all its state in the backend struct and `OngoingCodegen`). It is keyed on the
/// session's `GlobalCtxt` address, so a second session in the same process is a fatal error
/// instead of reading stale values.
struct SessionCell<T>(OnceLock<(usize, T)>);

impl<T> SessionCell<T> {
    const fn new() -> Self {
        SessionCell(OnceLock::new())
    }

    fn key(tcx: TyCtxt<'_>) -> usize {
        std::ptr::from_ref::<rustc_middle::ty::GlobalCtxt<'_>>(*tcx) as usize
    }

    fn check<'a>(tcx: TyCtxt<'_>, (key, v): &'a (usize, T)) -> &'a T {
        if *key != Self::key(tcx) {
            tcx.dcx().fatal("the ryo backend supports one compilation session per process");
        }
        v
    }

    /// Fails if a value was already set.
    fn set(&self, tcx: TyCtxt<'_>, v: T) -> Result<(), ()> {
        self.0.set((Self::key(tcx), v)).map_err(|_| ())
    }

    fn get(&self, tcx: TyCtxt<'_>) -> Option<&T> {
        Some(Self::check(tcx, self.0.get()?))
    }
}

/// `ryo_rt`'s crate and template items, found through its diagnostic items. `None` if
/// `ryo_rt` isn't loaded (rustc wasn't run through `rustc-ryo`).
pub fn rt_items(tcx: TyCtxt<'_>) -> Option<RtItems> {
    let krate = *tcx.crates(()).iter().find(|&&c| is_rt_crate(tcx, c))?;
    rt_items_in(tcx, krate)
}

/// The runtime crate's name.
pub const RT_CRATE: &str = "ryo_rt";

/// Whether `krate` is `ryo_rt`.
pub fn is_rt_crate(tcx: TyCtxt<'_>, krate: CrateNum) -> bool {
    tcx.crate_name(krate).as_str() == RT_CRATE
}

/// [`rt_items`], given `ryo_rt`'s crate.
pub fn rt_items_in(tcx: TyCtxt<'_>, krate: CrateNum) -> Option<RtItems> {
    let items = tcx.diagnostic_items(krate);
    let get = |name: &str| items.name_to_id.get(&Symbol::intern(name)).copied();
    Some(RtItems { krate, c_main: get("ryo_c_main")?, fp_arg: get("ryo_rt_fp_arg")? })
}

/// What the partition provider hands to the other providers and to `codegen_crate`. Set once:
/// the query is `eval_always` and computed once per session.
pub struct Results {
    /// One image per codegen unit with VM functions, in rustc's CGU order.
    pub images: Vec<CguImage>,
    /// With `RYO_DUMP_LEAN`: the data of the certificate file (`dump_lean::write_certs`).
    pub lean: Option<LeanCerts>,
    /// The interned data, lifetime-erased ([`Results::exports`]).
    exports: Exports<'static>,
}

/// The image of one codegen unit (design/backend.md#pipeline), or, for a CGU whose candidates
/// all stay native, only its side data: saved as a work product too, so an incremental session
/// doesn't lower them again just to find that out.
pub struct CguImage {
    /// The name of the (native) CGU it belongs to; the image is `<name>.ryo_image`.
    pub cgu_name: Symbol,
    /// The image, ready to be written as an object, or the previous session's.
    pub image: ImageSrc,
    /// The symbol `__ryo_main` points at: the entry fn's, for a VM `main` in this image.
    pub main_symbol: Option<String>,
}

/// What `RYO_DUMP_LEAN`'s certificate file needs from the partition.
pub struct LeanCerts {
    /// Per image, in CGU order: its CGU's name and each of its VM functions' symbol and
    /// lowering certificate (JSON), in image order (`lower/cert.rs`). An `#[inline]` function
    /// copied into several images has an entry in each: the copies are lowered separately.
    pub images: Vec<(String, Vec<(String, String)>)>,
    /// The symbol of each island instance the image calls, and its template's diagnostic
    /// item name, sorted.
    pub islands: Vec<(String, String)>,
}

/// The part of [`Results`] that holds this session's interned data.
struct Exports<'tcx> {
    /// For `exported_generic_symbols`: the VM functions with `External` linkage whose symbols
    /// the images define, with their visibility.
    vm: Vec<(Instance<'tcx>, Visibility)>,
    /// Native items made `External` + `Hidden` only because an image references them.
    hidden_for_image: Vec<Instance<'tcx>>,
}

static RESULTS: SessionCell<Results> = SessionCell::new();

/// The upstream statics this crate defines (an upstream EII static implemented here), recorded
/// from rustc's CGUs before lowering. Symbol names, sorted, for the image key.
static CODEGENED_UPSTREAM: SessionCell<(UnordSet<DefId>, String)> = SessionCell::new();

/// Whether the upstream static `def_id` is defined by this crate.
pub fn is_defined_upstream_static(tcx: TyCtxt<'_>, def_id: DefId) -> bool {
    CODEGENED_UPSTREAM.get(tcx).is_some_and(|(set, _)| set.contains(&def_id))
}

pub fn results(tcx: TyCtxt<'_>) -> Option<&'static Results> {
    RESULTS.get(tcx)
}

/// [`Results`] for the exported-symbols overrides, after forcing the partitioning. The dep
/// graph sees the results only through the native CGUs (the partition query's hash), not the
/// images' roots and exports, which can change while the native CGUs don't (a VM function's new
/// callee). Both queries are `cache_on_disk`, so a green node would load the previous session's
/// list (design/backend.md#incremental): with VM code they depend on the forever-red node and
/// rerun every session, as rustc's `create_def` makes its callers do. They are cheap.
fn results_untracked(tcx: TyCtxt<'_>) -> Option<&'static Results> {
    let _ = tcx.collect_and_partition_mono_items(());
    let r = results(tcx)?;
    tcx.dep_graph.read_index(rustc_middle::dep_graph::DepNodeIndex::FOREVER_RED_NODE);
    Some(r)
}

impl Results {
    fn new<'tcx>(images: Vec<CguImage>, lean: Option<LeanCerts>, exports: Exports<'tcx>) -> Self {
        // SAFETY: only the lifetime parameter changes; `exports` restores it (see there).
        let exports = unsafe { std::mem::transmute::<Exports<'tcx>, Exports<'static>>(exports) };
        Results { images, lean, exports }
    }

    fn exports<'tcx>(&self, _tcx: TyCtxt<'tcx>) -> &Exports<'tcx> {
        // SAFETY: the instances were interned by this session's `TyCtxt`, which outlives every
        // query provider call, and a process runs one session (`RESULTS` checks it). Only the
        // lifetime parameter changes.
        unsafe { std::mem::transmute::<&Exports<'static>, &Exports<'tcx>>(&self.exports) }
    }
}

/// Our `collect_and_partition_mono_items` (design/backend.md#pipeline steps 1–4).
pub fn collect_and_partition_mono_items<'tcx>(tcx: TyCtxt<'tcx>, original: super::PartitionProvider) -> MonoItemPartitions<'tcx> {
    // Providers are plain fns, so this one reads the switches itself.
    let switches = super::switches::Switches::from_env();
    if switches.marker {
        eprintln!("{}", super::PARTITION_MARKER);
    }
    // A crate with no VM code is rustc's partition as is: no image, any number of codegen
    // units, cg_llvm's incremental reuse (design/backend.md#pipeline).
    if !vm_enabled(tcx, &switches) {
        return original(tcx, ());
    }
    let partitions = original(tcx, ());
    let Some(rt) = rt_items(tcx) else { tcx.dcx().fatal("the ryo backend needs `ryo_rt` (`--extern force:ryo_rt`); run it through `rustc-ryo`") };

    // The upstream EII statics a local static implements (`foreign_item_symbol_aliases`): cg_llvm
    // defines the declaration's symbol as an alias next to it, so references to it are
    // direct (no `dllimport` on an already defined global).
    let upstream: UnordSet<DefId> = partitions
        .codegen_units
        .iter()
        .flat_map(|cgu| cgu.items().keys())
        .filter_map(|item| if let MonoItem::Static(d) = *item { d.is_local().then_some(d) } else { None })
        .flat_map(|d| tcx.codegen_fn_attrs(d).foreign_item_symbol_aliases.iter().map(|a| a.0))
        .filter(|d| !d.is_local())
        .collect();
    let names = upstream.items().map(|&d| static_symbol(tcx, d).name.to_owned()).into_sorted_stable_ord();
    if CODEGENED_UPSTREAM.set(tcx, (upstream, names.join(" "))).is_err() {
        tcx.dcx().fatal("collect_and_partition_mono_items ran twice in one process");
    }
    let (native, results) = {
        let _t = tcx.prof.generic_activity("ryo_partition");
        Partitioner::new(tcx, rt, &switches, partitions.codegen_units).run()
    };
    if results.images.iter().any(CguImage::has_object) {
        check_outputs(tcx);
    }
    if RESULTS.set(tcx, results).is_err() {
        tcx.dcx().fatal("collect_and_partition_mono_items ran twice in one process");
    }
    MonoItemPartitions {
        // `CodegenUnit` is arena-allocated (`rustc_middle/src/arena.rs:107`).
        codegen_units: tcx.arena.alloc_from_iter(native),
        // Keeps every original DefId, VM functions included (design/backend.md#query-overrides).
        all_mono_items: partitions.all_mono_items,
    }
}

/// Fails for the outputs a crate with VM code can't have (design/backend.md#unsupported-options).
/// An object or bitcode file is cg_llvm's native modules only, without the images, so it
/// would lack the VM functions. Without `link` there is nothing to add the images to (`link`
/// appends them to an rlib after `link_binary`, which writes it only then), so they would be
/// left behind as temporaries, or appended to a stale rlib; output for reading (`asm`,
/// `llvm-ir`, `mir`) is fine alongside `link`. And an output written to stdout (`-o -`) can't
/// have the images appended.
fn check_outputs(tcx: TyCtxt<'_>) {
    let opts = &tcx.sess.opts;
    let fail = |what: String| -> ! {
        tcx.dcx().fatal(format!(
            "the ryo backend doesn't support {what} for a crate with VM code: the VM functions are in separate image objects (design/backend.md#unsupported-options)"
        ))
    };
    if let Some(t) = [OutputType::Object, OutputType::Bitcode, OutputType::ThinLinkBitcode].into_iter().find(|t| opts.output_types.contains_key(t)) {
        fail(format!("`--emit={}`", t.shorthand()));
    }
    if !opts.output_types.should_link() {
        let emits: Vec<&str> = opts.output_types.keys().map(|t| t.shorthand()).collect();
        fail(format!("`--emit={}` without `link`", emits.join(",")));
    }
    if matches!(tcx.output_filenames(()).path(OutputType::Exe), rustc_session::config::OutFileName::Stdout) {
        fail("`-o -`".to_owned());
    }
}

/// Whether the crate may have VM code. Proc macros stay native: it keeps VM code out of
/// rustc's own process, and they gain nothing from it. `RYO_NO_VM` is a debugging switch
/// (design/backend.md#pipeline, step 2). A panic runtime (`panic_unwind`, `panic_abort`) too:
/// portals re-raise a panic from the VM through its `__rust_start_panic` (design/vm.md,
/// Unwinding), so that must be native, and the rest of the runtime gains nothing from the VM.
/// Runtime-internal crates too (design/backend.md#unsupported-options): `compiler_builtins`
/// and `#![no_builtins]` crates implement `memcpy` and friends, which the handlers call (VM
/// code there would recurse), as does a target that sets `no_builtins` (rustc treats every
/// crate as `#![no_builtins]` then), `#![profiler_runtime]`, the VM's own crates
/// ([`RUNTIME_CRATES`]), and `core` (and its `-Zbuild-std` alias): the handlers call its
/// non-generic functions, which must not re-enter VM code.
fn vm_enabled(tcx: TyCtxt<'_>, switches: &Switches) -> bool {
    !switches.no_vm
        && !tcx.crate_types().contains(&CrateType::ProcMacro)
        && !tcx.is_panic_runtime(LOCAL_CRATE)
        && !tcx.is_compiler_builtins(LOCAL_CRATE)
        && !rustc_hir::find_attr!(tcx.hir_krate_attrs(), NoBuiltins)
        && !tcx.sess.target.no_builtins
        && !rustc_hir::find_attr!(tcx.hir_krate_attrs(), ProfilerRuntime)
        && !is_runtime_crate(tcx, LOCAL_CRATE)
        && !matches!(tcx.crate_name(LOCAL_CRATE).as_str(), "core" | "rustc_std_workspace_core")
}

/// The VM's own crates: always native ([`vm_enabled`]), their copies of other crates'
/// generics are never linked to ([`upstream_monomorphizations`]), and every final artifact
/// links a private copy of them (`dylib_dependency_formats`). (`ryo_jit` is sealed into
/// `ryo_rt`, so it is a crate only when built on its own, as with `-Zbuild-std`.)
pub const RUNTIME_CRATES: [&str; 3] = [RT_CRATE, "ryo_bytecode", "ryo_jit"];

/// Whether `krate` is one of [`RUNTIME_CRATES`].
pub fn is_runtime_crate(tcx: TyCtxt<'_>, krate: CrateNum) -> bool {
    RUNTIME_CRATES.contains(&tcx.crate_name(krate).as_str())
}

/// How the image's machine code is generated: as `ryo_rt`'s handlers expect `fp`, with a
/// frame pointer where the session needs one, with loop-head alignment unless
/// `RYO_ASM_ALIGN=0`, and for the target's object format.
fn asm_mode(tcx: TyCtxt<'_>, rt: RtItems, switches: &Switches) -> asm::Mode {
    let fp_arg = tcx.const_eval_poly(rt.fp_arg).ok().and_then(|v| v.try_to_scalar_int()).map(|i| i.to_u8() != 0);
    let Some(fp_arg) = fp_arg else { tcx.dcx().fatal("ryo_rt's FP_ARG isn't a bool") };
    let pe = super::symbols::is_pe(tcx);
    if pe && fp_arg {
        // PE's handlers are Win64 and read `fp` from `rbp` (`asm::Mode::pe`).
        tcx.dcx().fatal("ryo_rt's handlers take fp in rdi, but on PE they must read rbp: a ryo_rt built for another target?");
    }
    asm::Mode {
        fp_arg,
        // Handlers that read `rbp` and PE unwind info need it (`asm::Mode::frame_pointer`).
        frame_pointer: !fp_arg || pe || needs_frame_pointer(tcx.sess),
        align_loops: switches.asm_align,
        pe,
        // The JIT's trigger, in every build: one code shape (design/vm.md, "JIT records and
        // counters").
        counters: true,
        far_rt: false,
    }
}

/// Whether the session asks for frame pointers, as `rustc_codegen_llvm::attributes::
/// frame_pointer` decides: the target's default and `-Cforce-frame-pointers`
/// (`-Zinstrument-mcount` is rejected). `NonLeaf` counts as `Always`: VM functions call handlers.
fn needs_frame_pointer(sess: &rustc_session::Session) -> bool {
    use rustc_target::spec::FramePointer;
    let mut fp = sess.target.frame_pointer;
    fp.ratchet(sess.opts.cg.force_frame_pointers);
    fp != FramePointer::MayOmit
}

/// A VM function: its lowering, and whether native code or the image calls it by name (then
/// the image defines its symbol globally, with its linkage; an internal one becomes hidden).
pub(super) struct VmFn<'tcx> {
    pub(super) instance: Instance<'tcx>,
    data: MonoItemData,
    pub(super) lowered: LoweredFn<'tcx>,
    global: bool,
}

/// What one CGU's image gives the native CGUs and the exported-symbols queries: its VM
/// functions (and whether the image defines a global symbol for each), the island instances it
/// calls, the items it refers to by symbol, and the symbol `__ryo_main` points
/// at. A function of the CGU's own items and tracked queries alone, so it is saved with the
/// image and read back when the image is reused (design/backend.md#incremental, `persist.rs`).
pub(super) struct CguVm<'tcx> {
    vm: Vec<(Instance<'tcx>, bool)>,
    islands: Vec<Instance<'tcx>>,
    refs: Vec<MonoItem<'tcx>>,
    main: Option<String>,
}

type CguVmData<'tcx> = (Vec<(Instance<'tcx>, bool)>, Vec<Instance<'tcx>>, Vec<MonoItem<'tcx>>, Option<String>);

impl<'tcx> CguVm<'tcx> {
    fn empty() -> Self {
        CguVm { vm: Vec::new(), islands: Vec::new(), refs: Vec::new(), main: None }
    }

    /// The side data: a byte saying whether the CGU has an image object (it has VM
    /// functions), readable before the image's dep node is green, a checksum of that byte and
    /// the rest ([`CguVm::split`]), then the encoded fields.
    fn save(&self, tcx: TyCtxt<'tcx>) -> Vec<u8> {
        let body = persist::encode(tcx, &(&self.vm, &self.islands, &self.refs, &self.main));
        let has_object = u8::from(!self.vm.is_empty());
        let mut out = vec![has_object];
        out.extend_from_slice(&side_checksum(has_object, &body));
        out.extend(body);
        out
    }

    /// Saved side data's has-object byte and encoded fields, if it is whole: its checksum
    /// matches. Checked before the image's dep node is marked green, so a corrupted file
    /// rebuilds the image rather than panicking in the decoder (`MemDecoder`'s footer check
    /// only catches truncation).
    fn split(data: &[u8]) -> Option<(bool, &[u8])> {
        let (head, body) = data.split_at_checked(SIDE_HEADER)?;
        (head[1..] == side_checksum(head[0], body)).then_some((head[0] != 0, body))
    }

    /// Decodes the encoded fields ([`CguVm::split`]'s body).
    fn load(tcx: TyCtxt<'tcx>, body: &[u8]) -> Option<Self> {
        let (vm, islands, refs, main): CguVmData<'tcx> = persist::decode(tcx, body)?;
        Some(CguVm { vm, islands, refs, main })
    }
}

/// The length of [`CguVm::save`]'s header: the has-object byte and the checksum.
const SIDE_HEADER: usize = 17;

/// The stable hash of `v`.
fn stable_fingerprint<T: std::hash::Hash + ?Sized>(v: &T) -> rustc_data_structures::fingerprint::Fingerprint {
    let mut h = rustc_data_structures::stable_hash::StableHasher::new();
    v.hash(&mut h);
    h.finish()
}

/// [`CguVm::save`]'s checksum of the side data: its first byte and the encoded fields.
fn side_checksum(has_object: u8, body: &[u8]) -> [u8; 16] {
    stable_fingerprint(&(has_object, body)).to_le_bytes()
}

/// Where a CGU's image object comes from.
pub enum ImageSrc {
    /// Written this session, with its side data ([`CguVm::save`]); no image if the CGU has no
    /// VM function.
    Fresh { image: Option<ImageObject>, side: Vec<u8> },
    /// The previous session's, from the incremental cache: its work product (without an `o`
    /// file if the CGU has no VM function).
    Reused(WorkProduct),
}

impl CguImage {
    /// Whether there is an image object (the CGU has VM functions).
    pub fn has_object(&self) -> bool {
        match &self.image {
            ImageSrc::Fresh { image, .. } => image.is_some(),
            ImageSrc::Reused(wp) => wp.saved_files.contains_key(WP_OBJECT),
        }
    }
}

/// A CGU's VM part as this session lowered it: for the stats, the dumps and the Lean
/// certificates.
struct Fresh<'tcx> {
    /// The CGU's name.
    cgu: Symbol,
    vm: Vec<VmFn<'tcx>>,
    /// The image's constant pool size in bytes (`RYO_STATS`).
    pool: usize,
    failed: Vec<(Instance<'tcx>, NeedsNative)>,
    dump: String,
    code_dump: String,
}

/// One CGU's image phase.
struct ImagePart<'tcx> {
    vm: CguVm<'tcx>,
    image: Option<ImageSrc>,
    fresh: Option<Fresh<'tcx>>,
}

/// The session's settings an image depends on beyond its CGU's items and the queries its
/// lowering reads (which its dep node tracks), for the reuse fingerprint.
fn image_settings(tcx: TyCtxt<'_>, rt: RtItems, mode: asm::Mode, switches: &Switches) -> String {
    // The backend itself by its build ID (`build.rs`): a rebuilt backend may lower
    // differently. Baked in rather than read from the backend's file, which a rebuild may
    // replace while this session runs. And `ryo_rt`'s crate hash: what its handlers expect
    // may change without the backend changing, and an image that calls no island reads
    // nothing else of it.
    // And the upstream statics this crate defines, which references reach directly on PE
    // (`symbols::static_symbol_flags`).
    let upstream = CODEGENED_UPSTREAM.get(tcx).map_or("", |(_, names)| names.as_str());
    format!("{:?} {} {} {} {} {upstream}", mode, local_stable_crate_id(tcx), switches.asm_align, env!("RYO_BACKEND_ID"), tcx.crate_hash(rt.krate))
}

struct Partitioner<'a, 'tcx> {
    tcx: TyCtxt<'tcx>,
    rt: RtItems,
    switches: &'a Switches,
    /// How the images' machine code is generated ([`asm_mode`]), for lowering and merging.
    mode: asm::Mode,
    /// One per rustc CGU, in its order.
    units: Vec<Unit<'a, 'tcx>>,
    /// The CGUs holding each of rustc's items (several for `LocalCopy` items).
    homes: FxHashMap<MonoItem<'tcx>, Vec<usize>>,
    /// The CGU that added each [`unique`] item no CGU of rustc's holds ([`Self::expose_unique`]).
    owners: FxHashMap<MonoItem<'tcx>, usize>,
    stats: Stats,
}

/// One codegen unit: rustc's, its VM functions (its image) and what its native CGU gains.
struct Unit<'a, 'tcx> {
    cgu: &'a CodegenUnit<'tcx>,
    vm: CguVm<'tcx>,
    /// Whether each VM function has a global symbol in the image.
    index: FxHashMap<Instance<'tcx>, bool>,
    /// `Internal` `LocalCopy` VM functions native code of this CGU references: they stay in
    /// the native CGU too (an image symbol for them could clash with another CGU's copy).
    keep_native: FxHashSet<Instance<'tcx>>,
    /// Items added to the native CGU besides the original's native items.
    added: FxIndexMap<MonoItem<'tcx>, MonoItemData>,
    /// Stub instances whose neighbors haven't been walked yet.
    work: Vec<Instance<'tcx>>,
    /// Linkage and visibility changes of the CGU's own items.
    flips: FxHashMap<MonoItem<'tcx>, (Linkage, Visibility)>,
    /// Added items made External or WeakODR + Hidden only for an image.
    hidden_added: Vec<Instance<'tcx>>,
}

/// Totals for `RYO_STATS`.
#[derive(Default)]
struct Stats {
    native_fns: usize,
    islands: usize,
    reused: usize,
}

/// Whether `item` exists once per crate: a copy of a `LocalCopy` function may be in several
/// CGUs, which therefore can't each give it a strong global symbol.
fn unique<'tcx>(tcx: TyCtxt<'tcx>, item: MonoItem<'tcx>) -> bool {
    item.instantiation_mode(tcx) != rustc_middle::mono::InstantiationMode::LocalCopy
}

impl<'a, 'tcx> Unit<'a, 'tcx> {
    /// The native CGU: the original's native items (with `flips` applied), then the added
    /// stubs and their neighbors.
    fn native_cgu(&self) -> CodegenUnit<'tcx> {
        let mut native = CodegenUnit::new(self.cgu.name());
        // Set by `merge_codegen_units` for every CGU (`rustc_monomorphize/src/partitioning.rs:462-507`).
        native.set_symbol_name(self.cgu.symbol_name());
        if self.cgu.is_primary() {
            native.make_primary();
        }
        if self.cgu.is_code_coverage_dead_code_cgu() {
            native.make_code_coverage_dead_code_cgu();
        }
        let items = native.items_mut();
        for (item, data) in self.cgu.items() {
            let is_vm = matches!(item, MonoItem::Fn(i) if self.index.contains_key(i) && !self.keep_native.contains(i));
            if !is_vm {
                let mut data = *data;
                if let Some(&(linkage, visibility)) = self.flips.get(item) {
                    data.linkage = linkage;
                    data.visibility = visibility;
                }
                items.insert(*item, data);
            }
        }
        for (item, data) in &self.added {
            items.insert(*item, *data);
        }
        native.compute_size_estimate();
        native
    }
}

impl<'a, 'tcx> Partitioner<'a, 'tcx> {
    fn new(tcx: TyCtxt<'tcx>, rt: RtItems, switches: &'a Switches, cgus: &'a [CodegenUnit<'tcx>]) -> Self {
        let mut homes: FxHashMap<MonoItem<'tcx>, Vec<usize>> = FxHashMap::default();
        for (u, cgu) in cgus.iter().enumerate() {
            for item in cgu.items().keys() {
                homes.entry(*item).or_default().push(u);
            }
        }
        let units = cgus
            .iter()
            .map(|cgu| Unit {
                cgu,
                vm: CguVm::empty(),
                index: FxHashMap::default(),
                keep_native: FxHashSet::default(),
                added: FxIndexMap::default(),
                work: Vec::new(),
                flips: FxHashMap::default(),
                hidden_added: Vec::new(),
            })
            .collect();
        Partitioner { tcx, rt, switches, mode: asm_mode(tcx, rt, switches), units, homes, owners: FxHashMap::default(), stats: Stats::default() }
    }

    fn run(mut self) -> (Vec<CodegenUnit<'tcx>>, Results) {
        let tcx = self.tcx;
        let entry = tcx.entry_fn(()).map(|(def_id, _)| Instance::mono(tcx, def_id));
        let (images, fresh) = self.lower(entry);
        let failed: Vec<(Instance<'tcx>, NeedsNative)> =
            fresh.iter().flat_map(|f| f.failed.iter().map(|(i, w)| (*i, NeedsNative(w.0.clone())))).collect();
        if self.switches.stats >= 2 {
            for (instance, why) in &failed {
                eprintln!("ryo: native {}: {}", path(*instance), why.0);
            }
        }
        self.stats.native_fns = failed.len();

        let stubs_t = tcx.prof.generic_activity("ryo_stubs");
        self.add_symbol_needs(entry);
        let natives: Vec<CodegenUnit<'tcx>> = self.units.iter().map(Unit::native_cgu).collect();
        drop(stubs_t);

        if self.switches.stats >= 1 {
            self.print_stats(&natives, &fresh, &failed);
        }
        let lean = self.write_dumps(&fresh, &failed);
        (natives, self.into_results(images, lean))
    }

    /// Steps 2, 3 and 5's contents, per CGU and in parallel (over CGUs, and over each one's
    /// functions): classify, lower and build the image, or reuse the previous session's.
    fn lower(&mut self, entry: Option<Instance<'tcx>>) -> (Vec<CguImage>, Vec<Fresh<'tcx>>) {
        let tcx = self.tcx;
        let settings = image_settings(tcx, self.rt, self.mode, self.switches);
        let parts: Vec<ImagePart<'tcx>> = {
            let _t = tcx.prof.generic_activity("ryo_lower");
            let cgus: Vec<&CodegenUnit<'tcx>> = self.units.iter().map(|u| u.cgu).collect();
            let (rt, mode, switches) = (self.rt, self.mode, self.switches);
            rustc_data_structures::sync::par_map(cgus, |cgu| image_part(tcx, rt, mode, switches, &settings, entry, cgu))
        };
        let mut images = Vec::new();
        let mut fresh = Vec::new();
        for (u, part) in parts.into_iter().enumerate() {
            let unit = &mut self.units[u];
            unit.index = part.vm.vm.iter().copied().collect();
            if let Some(image) = part.image {
                images.push(CguImage { cgu_name: unit.cgu.name(), image, main_symbol: part.vm.main.clone() });
            }
            if part.fresh.is_none() && !part.vm.vm.is_empty() {
                self.stats.reused += 1;
            }
            unit.vm = part.vm;
            fresh.extend(part.fresh);
        }
        (images, fresh)
    }

    /// Step 1 (symbols) and 4, per CGU: the native items' references to VM functions,
    /// islands, the entry wrapper, and the native items the image refers to; then, once every
    /// CGU's linkage changes for its image are known, the stub neighbors.
    fn add_symbol_needs(&mut self, entry: Option<Instance<'tcx>>) {
        let tcx = self.tcx;
        let mut islands = FxHashSet::default();
        for u in 0..self.units.len() {
            self.scan_native_items(u);
            self.add_islands(u, &mut islands);
            if let Some(main) = entry
                && self.units[u].index.contains_key(&main)
                && let Some((_, ty)) = tcx.entry_fn(())
            {
                self.add_c_main(u, main, ty);
            }
            let refs = self.units[u].vm.refs.clone();
            for item in refs {
                self.make_visible(u, item);
            }
        }
        for u in 0..self.units.len() {
            self.walk_stub_neighbors(u);
        }
        self.stats.islands = islands.len();
    }

    /// `RYO_STATS=1`'s totals.
    fn print_stats(&self, natives: &[CodegenUnit<'tcx>], fresh: &[Fresh<'tcx>], failed: &[(Instance<'tcx>, NeedsNative)]) {
        let mut n_vm = 0;
        for unit in &self.units {
            for &(v, global) in &unit.vm.vm {
                let global = if global { " (global)" } else { "" };
                eprintln!("ryo: vm fn {}{global}", path(v));
            }
            n_vm += unit.vm.vm.len();
        }
        eprintln!(
            "ryo: {n_vm} VM functions, {} native functions, {} islands, {} native items",
            self.stats.native_fns,
            self.stats.islands,
            natives.iter().map(|n| n.items().len()).sum::<usize>()
        );
        let n_images = self.units.iter().filter(|u| !u.vm.vm.is_empty()).count();
        let cross = self.cross_image_refs(fresh);
        eprintln!("ryo: {n_images} images in {} codegen units, {cross} cross-image references to VM functions", self.units.len());
        eprintln!("ryo: {} of {n_images} images reused", self.stats.reused);
        // Constants are deduplicated per image only: several images may each hold a copy.
        let pool: usize = fresh.iter().map(|f| f.pool).sum();
        eprintln!("ryo: {pool} bytes of constant pools in the {} images built", fresh.iter().filter(|f| !f.vm.is_empty()).count());
        print_coverage(fresh, failed);
    }

    /// The `RYO_DUMP*` files, and `RYO_DUMP_LEAN`'s certificates.
    fn write_dumps(&self, fresh: &[Fresh<'tcx>], failed: &[(Instance<'tcx>, NeedsNative)]) -> Option<LeanCerts> {
        let tcx = self.tcx;
        let lean = self.switches.dump_lean.is_some().then(|| {
            // `RYO_DUMP_LEAN` turns reuse off, so every image is fresh.
            let images = fresh
                .iter()
                .filter(|f| !f.vm.is_empty())
                .map(|f| {
                    let certs = f.vm.iter().filter_map(|v| Some((tcx.symbol_name(v.instance).name.to_owned(), v.lowered.cert.clone()?)));
                    (f.cgu.to_string(), certs.collect())
                })
                .collect();
            LeanCerts { images, islands: island_names(tcx, self.rt, fresh) }
        });
        if let Some(path) = &self.switches.dump {
            dump::write(tcx, "RYO_DUMP", path, &fresh.iter().map(|f| f.dump.as_str()).collect::<String>());
        }
        if let Some(path) = &self.switches.dump_code {
            dump::write(tcx, "RYO_DUMP_CODE", path, &fresh.iter().map(|f| f.code_dump.as_str()).collect::<String>());
        }
        if let Some(path) = &self.switches.dump_native {
            let kept: Vec<Instance<'tcx>> = self.units.iter().flat_map(|u| u.keep_native.iter().copied()).collect();
            dump::write(tcx, "RYO_DUMP_NATIVE", path, &native_text(tcx, fresh, failed, &kept));
        }
        lean
    }

    /// The export lists, with `images` and `lean`.
    fn into_results(self, images: Vec<CguImage>, lean: Option<LeanCerts>) -> Results {
        let mut vm_exports: Vec<(Instance<'tcx>, Visibility)> = Vec::new();
        let mut hidden: Vec<Instance<'tcx>> = Vec::new();
        for unit in &self.units {
            // Items made External or WeakODR + Hidden only for an image aren't exported
            // (design/backend.md#query-overrides).
            hidden.extend(unit.flips.iter().filter_map(|(item, &(linkage, _))| match *item {
                MonoItem::Fn(i) if matches!(linkage, Linkage::External | Linkage::WeakODR) && unit.cgu.items()[item].linkage == Linkage::Internal => {
                    Some(i)
                }
                _ => None,
            }));
            hidden.extend(unit.hidden_added.iter().copied());
            for &(v, global) in &unit.vm.vm {
                let data = unit.cgu.items()[&MonoItem::Fn(v)];
                if global && data.linkage == Linkage::External {
                    vm_exports.push((v, data.visibility));
                }
            }
        }
        Results::new(images, lean, Exports { vm: vm_exports, hidden_for_image: hidden })
    }

    /// References of a VM function of another image by the fresh images (a `call.sym` or its
    /// address), for `RYO_STATS`.
    fn cross_image_refs(&self, fresh: &[Fresh<'tcx>]) -> usize {
        let all: FxHashSet<Instance<'tcx>> = self.units.iter().flat_map(|u| u.vm.vm.iter().map(|v| v.0)).collect();
        let mut n = 0;
        for f in fresh {
            let local: FxHashSet<Instance<'tcx>> = f.vm.iter().map(|v| v.instance).collect();
            for v in &f.vm {
                for r in &v.lowered.relocs {
                    if let CodeReloc::Symbol { target } = *r
                        && all.contains(&target)
                        && !local.contains(&target)
                    {
                        n += 1;
                    }
                }
            }
        }
        n
    }

    /// Native code of CGU `u` references the VM function `instance` (if it is one of the
    /// CGU's): a global one needs nothing more; an internal one without a global symbol (a
    /// `LocalCopy`) stays native as well, as an `Internal` item of the native CGU.
    fn native_ref(&mut self, u: usize, instance: Instance<'tcx>) {
        let unit = &mut self.units[u];
        let Some(&global) = unit.index.get(&instance) else { return };
        if global || !unit.keep_native.insert(instance) {
            return;
        }
        // The CGU's VM functions are its items, so it keeps this one native.
        debug_assert!(unit.cgu.items().contains_key(&MonoItem::Fn(instance)));
        // Its own references are native now too (`walk_stub_neighbors`).
        unit.work.push(instance);
    }

    /// Whether `item` is defined with a global symbol by some CGU other than `u`: one of its
    /// non-internal items (VM or native, after the flips so far), or a VM function another
    /// image gives a global symbol.
    fn global_elsewhere(&self, u: usize, item: MonoItem<'tcx>) -> bool {
        let Some(homes) = self.homes.get(&item) else { return false };
        homes.iter().any(|&h| {
            let unit = &self.units[h];
            let linkage = unit.flips.get(&item).map_or(unit.cgu.items()[&item].linkage, |f| f.0);
            h != u && (linkage != Linkage::Internal || matches!(item, MonoItem::Fn(f) if unit.index.get(&f) == Some(&true)))
        })
    }

    /// For a [`unique`] item (a static, or a function that isn't a `LocalCopy`) that CGU `u`
    /// needs and doesn't hold: whether another CGU defines it, made linkable from `u` if
    /// needed. Its CGU in rustc's partition (one, being unique): an internal item there becomes
    /// External + Hidden, a linkonce one its weak form (as [`Self::make_visible`] does in `u`);
    /// a VM function is global already ([`build_cgu`]). Else the CGU that added it before
    /// (`owners`): an internal addition becomes External + Hidden. Else `false`, and `u` adds
    /// it and becomes its owner. A copy of its own in `u` would be a second instance: a second
    /// counter, lock or `OnceLock` for a static.
    fn expose_unique(&mut self, u: usize, item: MonoItem<'tcx>) -> bool {
        if let Some(homes) = self.homes.get(&item) {
            for &h in homes.iter().filter(|&&h| h != u) {
                let unit = &mut self.units[h];
                if matches!(item, MonoItem::Fn(f) if unit.index.contains_key(&f)) || unit.flips.contains_key(&item) {
                    continue;
                }
                let data = unit.cgu.items()[&item];
                let flip = match data.linkage {
                    Linkage::Internal => Some((Linkage::External, Visibility::Hidden)),
                    Linkage::LinkOnceAny => Some((Linkage::WeakAny, data.visibility)),
                    Linkage::LinkOnceODR => Some((Linkage::WeakODR, data.visibility)),
                    _ => None,
                };
                if let Some(flip) = flip {
                    unit.flips.insert(item, flip);
                }
            }
            return true;
        }
        let Some(&h) = self.owners.get(&item) else { return false };
        let unit = &mut self.units[h];
        let data = unit.added.get_mut(&item).expect("an owned item is added");
        if data.linkage == Linkage::Internal {
            data.linkage = Linkage::External;
            data.visibility = Visibility::Hidden;
            if let MonoItem::Fn(f) = item {
                unit.hidden_added.push(f);
            }
        }
        true
    }

    /// Marks the VM functions referenced by CGU `u`'s native items: functions (their
    /// neighbors, which include vtable methods) and static initializers.
    fn scan_native_items(&mut self, u: usize) {
        let tcx = self.tcx;
        let mut refs = Vec::new();
        let unit = &self.units[u];
        for (item, _) in unit.cgu.items() {
            match *item {
                MonoItem::Fn(i) if unit.index.contains_key(&i) => {}
                MonoItem::Fn(i) => {
                    for n in neighbors(tcx, i) {
                        if let MonoItem::Fn(f) = n {
                            refs.push(f);
                        }
                    }
                }
                MonoItem::Static(def_id) => {
                    if let Ok(alloc) = tcx.eval_static_initializer(def_id) {
                        // Statics are native items of their own.
                        let (mut seen, mut items) = (FxHashSet::default(), Vec::new());
                        for prov in alloc.inner().provenance().ptrs().values() {
                            alloc_refs(tcx, prov.alloc_id(), &mut seen, &mut items);
                        }
                        refs.extend(items.into_iter().filter_map(|n| if let MonoItem::Fn(f) = n { Some(f) } else { None }));
                    }
                }
                // `sym` operands are native references (like the collector's handling,
                // `rustc_monomorphize/src/collector.rs:493-535`).
                MonoItem::GlobalAsm(item_id) => {
                    let item = tcx.hir_item(item_id);
                    if let rustc_hir::ItemKind::GlobalAsm { asm, .. } = item.kind {
                        for (op, _) in asm.operands {
                            if let rustc_hir::InlineAsmOperand::SymFn { expr } = *op
                                && let ty::FnDef(def_id, args) = *tcx.typeck(item_id.owner_id).expr_ty(expr).kind()
                                && let Some(args) = args.no_bound_vars()
                            {
                                let typing_env = TypingEnv::fully_monomorphized();
                                refs.push(Instance::resolve_for_fn_ptr(tcx, typing_env, def_id, args).unwrap());
                            }
                        }
                    }
                }
            }
        }
        for f in refs {
            self.native_ref(u, f);
        }
    }

    /// The C `main` wrapper for a VM `main` (design/stubs.md#program-entry-main), in the CGU
    /// of the entry fn.
    fn add_c_main(&mut self, u: usize, main: Instance<'tcx>, entry_ty: EntryFnType) {
        let tcx = self.tcx;
        let typing_env = TypingEnv::fully_monomorphized();
        let sig = tcx.fn_sig(main.def_id()).instantiate_identity().skip_norm_wip();
        let main_ret = tcx.normalize_erasing_late_bound_regions(typing_env, sig).output();
        let EntryFnType::Main { sigpipe } = entry_ty;
        let start_def = tcx.require_lang_item(rustc_hir::attrs::lang_items::LangItem::Start, rustc_span::DUMMY_SP);
        let start_args = tcx.mk_args(&[main_ret.into()]);
        let start = Instance::expect_resolve(tcx, typing_env, start_def, start_args, rustc_span::DUMMY_SP);
        let start_ty = Ty::new_fn_def(tcx, start.def_id(), ty::Binder::dummy(start.args));
        let args = tcx.mk_args(&[start_ty.into(), main_ret.into(), ty::Const::from_bits(tcx, u128::from(sigpipe), typing_env, tcx.types.u8).into()]);
        let c_main = Instance::new_raw(self.rt.c_main, args);
        let data = MonoItemData {
            inlined: false,
            linkage: Linkage::External,
            visibility: Visibility::Default,
            size_estimate: MonoItem::Fn(c_main).size_estimate(tcx),
        };
        let unit = &mut self.units[u];
        unit.added.insert(MonoItem::Fn(c_main), data);
        unit.work.push(c_main);
    }

    /// Adds to CGU `u` whatever its stub instances use that the collector never saw,
    /// recursively (design/backend.md#pipeline step 4, Stub neighbors). `items_of_instance`
    /// already applies `should_codegen_locally`, so upstream copies (share-generics) are linked
    /// to, not defined. A [`unique`] item is defined once ([`Self::expose_unique`]); a
    /// `LocalCopy` another CGU defines globally is referenced; otherwise it is added internal:
    /// only the stubs reference it.
    fn walk_stub_neighbors(&mut self, u: usize) {
        let tcx = self.tcx;
        while let Some(instance) = self.units[u].work.pop() {
            for n in neighbors(tcx, instance) {
                if let MonoItem::Fn(f) = n
                    && self.units[u].index.contains_key(&f)
                {
                    self.native_ref(u, f);
                    continue;
                }
                let unit = &self.units[u];
                if unit.cgu.items().contains_key(&n) || unit.added.contains_key(&n) {
                    continue;
                }
                if unique(tcx, n) {
                    if self.expose_unique(u, n) {
                        continue;
                    }
                    self.owners.insert(n, u);
                } else if self.global_elsewhere(u, n) {
                    continue;
                }
                let data =
                    MonoItemData { inlined: false, linkage: Linkage::Internal, visibility: Visibility::Default, size_estimate: n.size_estimate(tcx) };
                let unit = &mut self.units[u];
                unit.added.insert(n, data);
                if let MonoItem::Fn(f) = n {
                    unit.work.push(f);
                }
            }
        }
    }

    /// Instantiates the island templates CGU `u`'s image calls (design/stubs.md): linked to an
    /// upstream copy where one is exported, otherwise added to the CGU as `WeakODR` +
    /// `Hidden`, so every CGU that uses an island has its own copy and the linker keeps one.
    /// `all` collects every island, for the stats.
    fn add_islands(&mut self, u: usize, all: &mut FxHashSet<Instance<'tcx>>) {
        let tcx = self.tcx;
        for island in self.units[u].vm.islands.clone() {
            all.insert(island);
            let item = MonoItem::Fn(island);
            let elsewhere = self.global_elsewhere(u, item);
            let unit = &mut self.units[u];
            if unit.added.contains_key(&item) || unit.cgu.items().contains_key(&item) {
                continue;
            }
            // Upstream copies, and non-generic templates, which `ryo_rt` itself defines; and a
            // copy another CGU defines globally (perhaps exported: a hidden copy here would
            // take it out of the exports, `hidden_for_image`).
            if island.upstream_monomorphization(tcx).is_some() || !tcx.should_codegen_locally(island) || elsewhere {
                continue;
            }
            let data =
                MonoItemData { inlined: false, linkage: Linkage::WeakODR, visibility: Visibility::Hidden, size_estimate: item.size_estimate(tcx) };
            unit.added.insert(item, data);
            unit.hidden_added.push(island);
            unit.work.push(island);
        }
    }

    /// Makes a native item CGU `u`'s image refers to by symbol linkable from the image's
    /// object: an internal item becomes External + Hidden if it is unique in the crate, else
    /// (a `LocalCopy`, of which other CGUs may expose their own copy) WeakODR + Hidden; a
    /// linkonce one (`#[linkage]`), which LLVM drops when no native code uses it, its weak form,
    /// in whichever CGU holds it (design/backend.md, Linkage). Items that no CGU defines
    /// globally but are codegened locally are added, WeakODR + Hidden.
    fn make_visible(&mut self, u: usize, item: MonoItem<'tcx>) {
        let tcx = self.tcx;
        if let MonoItem::Fn(f) = item
            && self.units[u].index.contains_key(&f)
        {
            return; // a VM function of the image: its own symbol
        }
        let hidden_internal = |item: MonoItem<'tcx>| {
            if unique(tcx, item) { (Linkage::External, Visibility::Hidden) } else { (Linkage::WeakODR, Visibility::Hidden) }
        };
        if let MonoItem::Fn(f) = item
            && lower::is_tls_shim(f)
            && !symbols::is_pe(tcx)
            && !self.units[u].cgu.items().contains_key(&item)
            && !self.units[u].added.contains_key(&item)
        {
            // rustc only creates `ThreadLocal` shims where the target doesn't export TLS
            // (`needs_thread_local_shim`), so on ELF the backend adds its own, also for
            // upstream statics. The same static always gives the same body, so copies from
            // several crates and CGUs merge (design/backend.md, Linkage).
            let data =
                MonoItemData { inlined: false, linkage: Linkage::WeakODR, visibility: Visibility::Hidden, size_estimate: item.size_estimate(tcx) };
            let unit = &mut self.units[u];
            unit.added.insert(item, data);
            unit.hidden_added.push(f);
            unit.work.push(f);
            return;
        }
        if let Some(data) = self.units[u].cgu.items().get(&item) {
            let flip = match data.linkage {
                Linkage::Internal => Some(hidden_internal(item)),
                Linkage::LinkOnceAny => Some((Linkage::WeakAny, data.visibility)),
                Linkage::LinkOnceODR => Some((Linkage::WeakODR, data.visibility)),
                _ => None,
            };
            if let Some(flip) = flip {
                self.units[u].flips.insert(item, flip);
            }
            return;
        }
        if let Some(data) = self.units[u].added.get(&item) {
            if data.linkage == Linkage::Internal {
                let (linkage, visibility) = hidden_internal(item);
                let unit = &mut self.units[u];
                let data = unit.added.get_mut(&item).unwrap();
                data.linkage = linkage;
                data.visibility = visibility;
                if let MonoItem::Fn(f) = item {
                    unit.hidden_added.push(f);
                }
            }
            return;
        }
        if unique(tcx, item) && self.expose_unique(u, item) {
            return;
        }
        // A `LocalCopy` defined globally by another CGU: a native item there needs at most the
        // linkonce flip.
        if self.global_elsewhere(u, item) {
            for h in self.homes.get(&item).cloned().unwrap_or_default() {
                let data = self.units[h].cgu.items()[&item];
                let flip = match data.linkage {
                    Linkage::LinkOnceAny => Some((Linkage::WeakAny, data.visibility)),
                    Linkage::LinkOnceODR => Some((Linkage::WeakODR, data.visibility)),
                    _ => None,
                };
                if let Some(flip) = flip {
                    self.units[h].flips.insert(item, flip);
                }
            }
            return;
        }
        if let MonoItem::Fn(f) = item
            && tcx.should_codegen_locally(f)
        {
            let data =
                MonoItemData { inlined: false, linkage: Linkage::WeakODR, visibility: Visibility::Hidden, size_estimate: item.size_estimate(tcx) };
            if unique(tcx, item) {
                self.owners.insert(item, u);
            }
            let unit = &mut self.units[u];
            unit.added.insert(item, data);
            unit.hidden_added.push(f);
            unit.work.push(f);
        }
    }
}

/// CGU `cgu`'s image phase: its VM functions lowered and its image built, inside the image's
/// own dep node under incremental compilation, or the previous session's image reused when
/// that node is green (design/backend.md#incremental).
fn image_part<'tcx>(
    tcx: TyCtxt<'tcx>,
    rt: RtItems,
    mode: asm::Mode,
    switches: &Switches,
    settings: &str,
    entry: Option<Instance<'tcx>>,
    cgu: &CodegenUnit<'tcx>,
) -> ImagePart<'tcx> {
    // `ryo_rt` instances are always native (design/vm.md).
    let mut cands: Vec<(Instance<'tcx>, MonoItemData)> = Vec::new();
    for (item, data) in cgu.items() {
        if let MonoItem::Fn(instance) = *item
            && instance.def_id().krate != rt.krate
        {
            cands.push((instance, *data));
        }
    }
    if cands.is_empty() {
        return ImagePart { vm: CguVm::empty(), image: None, fresh: None };
    }
    // A stable image order: by symbol name.
    cands.sort_by_cached_key(|(i, _)| tcx.symbol_name(*i).name);
    // Only the entry's own CGU depends on it.
    let entry = entry.filter(|e| cands.iter().any(|(i, _)| i == e));
    let build = || build_cgu(tcx, rt, mode, switches, entry, cgu, &cands);
    let incremental = tcx.dep_graph.is_fully_enabled()
        && !tcx.sess.opts.unstable_opts.disable_incr_comp_backend_caching
        && switches.dump_lean.is_none()
        && switches.dump.is_none()
        && switches.dump_code.is_none()
        && switches.dump_native.is_none();
    if !incremental {
        return build();
    }
    // The image's dep node: named after the CGU, its candidates with their linkage and
    // visibility, and the settings, so that a change to any of them gives a node the previous
    // session didn't have. The queries the lowering reads are the node's edges.
    // The entry by its symbol: an `Instance`'s `Debug` shows its `DefIndex`, which an item
    // added ahead of it changes.
    let entry_symbol = entry.map(|e| tcx.symbol_name(e).name);
    let mut key = format!("{}\n{settings}\n{entry_symbol:?}\n", cgu.name());
    for (i, d) in &cands {
        key.push_str(&format!("{} {:?} {:?}\n", tcx.symbol_name(*i).name, d.linkage, d.visibility));
    }
    let fp = stable_fingerprint(&key).to_hex();
    let node = CodegenUnit::new(Symbol::intern(&format!("{}.ryo.{fp}", cgu.name()))).codegen_dep_node(tcx);
    let wp = image_work_product_name(cgu.name());
    let prev = tcx.dep_graph.previous_work_product(&WorkProductId::from_cgu_name(&wp));
    let side = prev
        .as_ref()
        .and_then(|p| p.saved_files.get(WP_SIDE))
        .zip(tcx.incr_comp_session)
        .and_then(|(f, incr)| std::fs::read(rustc_incremental::in_incr_comp_dir_sess(incr, f)).ok());
    // A work product saved without its object (rustc only warns when a file fails to copy
    // into the cache) can't be reused; the side data says whether it had one.
    if let (Some(prev), Some(side)) = (prev, side)
        && let Some((has_object, body)) = CguVm::split(&side)
        && (!has_object || prev.saved_files.contains_key(WP_OBJECT))
        && tcx.dep_graph.try_mark_green(tcx, &node).is_some()
    {
        let vm = CguVm::load(tcx, body).unwrap_or_else(|| tcx.dcx().fatal(format!("ryo: the saved image of `{}` is unreadable", cgu.name())));
        return ImagePart { vm, image: Some(ImageSrc::Reused(prev)), fresh: None };
    }
    tcx.dep_graph.with_task(node, tcx, build, None).0
}

/// The work product name of CGU `cgu`'s image (its object and side data).
pub fn image_work_product_name(cgu: Symbol) -> String {
    format!("{cgu}.ryo")
}

/// The image work product's file keys (and the side data's extension): the side data
/// ([`CguVm::save`]) and the image object (none if the CGU has no VM function).
pub const WP_SIDE: &str = "ryo";
pub const WP_OBJECT: &str = "o";

/// Classifies, lowers and builds CGU `cgu`'s image from its candidates `cands` (in image
/// order).
fn build_cgu<'tcx>(
    tcx: TyCtxt<'tcx>,
    rt: RtItems,
    mode: asm::Mode,
    switches: &Switches,
    entry: Option<Instance<'tcx>>,
    cgu: &CodegenUnit<'tcx>,
    cands: &[(Instance<'tcx>, MonoItemData)],
) -> ImagePart<'tcx> {
    let (mut ok, failed) = lower_cgu(tcx, cands, mode, switches);
    let mut vm: Vec<VmFn<'tcx>> = Vec::new();
    for &(instance, data) in cands {
        if let Some(lowered) = ok.remove(&instance) {
            // A global symbol for functions native code or another image may call by name: all
            // but internal ones; an internal one unique in the crate, which native code of the
            // CGU may reference, too (hidden); and the entry fn, for `__ryo_main`. A
            // `LocalCopy` copy stays local: the image refers to its own functions by their
            // local symbols, and native code to it gets a native copy (`native_ref`).
            let global = data.linkage != Linkage::Internal || entry == Some(instance) || unique(tcx, MonoItem::Fn(instance));
            vm.push(VmFn { instance, data, lowered, global });
        }
    }
    if vm.is_empty() {
        let side = CguVm::empty().save(tcx);
        return ImagePart {
            vm: CguVm::empty(),
            image: Some(ImageSrc::Fresh { image: None, side }),
            fresh: Some(Fresh { cgu: cgu.name(), vm, pool: 0, failed, dump: String::new(), code_dump: String::new() }),
        };
    }
    let mut refs: Vec<MonoItem<'tcx>> = Vec::new();
    let mut islands: Vec<Instance<'tcx>> = Vec::new();
    let mut seen_allocs = FxHashSet::default();
    for v in &vm {
        for r in &v.lowered.relocs {
            match *r {
                CodeReloc::Symbol { target, .. } => refs.push(MonoItem::Fn(target)),
                CodeReloc::Static { def_id, .. } => refs.push(MonoItem::Static(def_id)),
                CodeReloc::Const { alloc, .. } => alloc_refs(tcx, alloc, &mut seen_allocs, &mut refs),
                CodeReloc::Data { alloc, .. } => alloc_refs(tcx, alloc, &mut seen_allocs, &mut refs),
                CodeReloc::Island { template, args } => islands.push(island_instance(tcx, rt.krate, template, args)),
                CodeReloc::Call { .. } | CodeReloc::Bytes { .. } => {}
            }
        }
    }
    let mut seen = FxHashSet::default();
    islands.retain(|i| seen.insert(*i));
    let mut seen = FxHashSet::default();
    refs.retain(|i| seen.insert(*i));
    let main = entry.filter(|m| vm.iter().any(|v| v.instance == *m)).map(|m| tcx.symbol_name(m).name.to_owned());
    let mut dump = String::new();
    let mut code_dump = String::new();
    let image = build_image(tcx, rt, mode, switches, cgu.name(), &mut vm, &mut dump, &mut code_dump);
    let at = std::mem::offset_of!(ryo_bytecode::image::Header, consts) + 4;
    let pool = image.rodata.get(at..at + 4).map_or(0, |b| u32::from_le_bytes(b.try_into().unwrap()) as usize);
    let cgu_vm = CguVm { vm: vm.iter().map(|v| (v.instance, v.global)).collect(), islands, refs, main };
    let side = cgu_vm.save(tcx);
    ImagePart {
        vm: cgu_vm,
        image: Some(ImageSrc::Fresh { image: Some(image), side }),
        fresh: Some(Fresh { cgu: cgu.name(), vm, pool, failed, dump, code_dump }),
    }
}

/// The coverage summary of `RYO_STATS` (design/backend.md#debugging-switches): island
/// instructions per function and by template, and the native functions by reason, of the
/// images built this session.
fn print_coverage(fresh: &[Fresh<'_>], failed: &[(Instance<'_>, NeedsNative)]) {
    let mut by_template: FxIndexMap<Symbol, (usize, usize)> = FxIndexMap::default();
    let mut with_islands = 0;
    let mut total = 0;
    let mut n_vm = 0;
    for v in fresh.iter().flat_map(|f| f.vm.iter()) {
        n_vm += 1;
        let mut n = 0;
        let mut seen = FxHashSet::default();
        for r in &v.lowered.relocs {
            if let CodeReloc::Island { template, .. } = *r {
                n += 1;
                let e = by_template.entry(template).or_default();
                e.0 += 1;
                e.1 += usize::from(seen.insert(template));
            }
        }
        total += n;
        with_islands += usize::from(n > 0);
    }
    let per_fn = if n_vm == 0 { 0.0 } else { total as f64 / n_vm as f64 };
    eprintln!("ryo: {total} island instructions in {with_islands} of {n_vm} VM functions ({per_fn:.2} per function)");
    let mut templates: Vec<_> = by_template.into_iter().collect();
    templates.sort_by(|a, b| b.1.0.cmp(&a.1.0).then_with(|| a.0.as_str().cmp(b.0.as_str())));
    for (t, (n, fns)) in templates {
        eprintln!("ryo: island {t}: {n} in {fns} functions");
    }
    let mut reasons: FxIndexMap<&str, usize> = FxIndexMap::default();
    for (_, why) in failed {
        *reasons.entry(why.0.as_str()).or_default() += 1;
    }
    let mut reasons: Vec<_> = reasons.into_iter().collect();
    reasons.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(b.0)));
    for (why, n) in reasons {
        eprintln!("ryo: native reason: {n} {why}");
    }
}

/// The `RYO_DUMP_NATIVE` text (design/backend.md#debugging-switches): a summary (native
/// functions by reason, island instructions by template), then each function that stays
/// native with its reason, each VM function also kept native (`keep_native`), and each VM
/// function with islands with its island instructions by template. Every line names the
/// function's crate (`[local]` for the crate being compiled) and its instance path, sorted,
/// so the text is deterministic.
fn native_text<'tcx>(tcx: TyCtxt<'tcx>, fresh: &[Fresh<'tcx>], failed: &[(Instance<'tcx>, NeedsNative)], kept: &[Instance<'tcx>]) -> String {
    use std::collections::BTreeMap;
    use std::fmt::Write;
    let name = |i: Instance<'tcx>| {
        let k = i.def_id().krate;
        let krate = if k == LOCAL_CRATE { "local".to_owned() } else { tcx.crate_name(k).to_string() };
        format!("[{krate}] {}", path(i))
    };
    let mut natives: Vec<(String, &str)> = failed.iter().map(|(i, w)| (name(*i), w.0.as_str())).collect();
    natives.sort();
    let mut reasons: BTreeMap<&str, usize> = BTreeMap::new();
    for (_, why) in &natives {
        *reasons.entry(why).or_default() += 1;
    }
    let mut kept: Vec<String> = kept.iter().map(|i| name(*i)).collect();
    kept.sort();
    kept.dedup();
    let mut n_vm = 0;
    let mut with: Vec<(String, BTreeMap<Symbol, usize>)> = Vec::new();
    let mut templates: BTreeMap<&str, (usize, usize)> = BTreeMap::new();
    for v in fresh.iter().flat_map(|f| f.vm.iter()) {
        n_vm += 1;
        let mut by: BTreeMap<Symbol, usize> = BTreeMap::new();
        for r in &v.lowered.relocs {
            if let CodeReloc::Island { template, .. } = *r {
                *by.entry(template).or_default() += 1;
            }
        }
        if !by.is_empty() {
            with.push((name(v.instance), by));
        }
    }
    with.sort_by(|a, b| a.0.cmp(&b.0));
    for (_, by) in &with {
        for (t, n) in by {
            let e = templates.entry(t.as_str()).or_default();
            e.0 += n;
            e.1 += 1;
        }
    }
    let mut out = String::new();
    writeln!(out, "# {} native functions, by reason", natives.len()).unwrap();
    let mut rs: Vec<_> = reasons.into_iter().collect();
    rs.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(b.0)));
    for (why, n) in rs {
        writeln!(out, "{n:5} {why}").unwrap();
    }
    let total: usize = templates.values().map(|t| t.0).sum();
    writeln!(out, "\n# {total} island instructions in {} of {n_vm} VM functions, by template (instructions, functions)", with.len()).unwrap();
    let mut ts: Vec<_> = templates.into_iter().collect();
    ts.sort_by(|a, b| b.1.0.cmp(&a.1.0).then_with(|| a.0.cmp(b.0)));
    for (t, (n, fns)) in ts {
        writeln!(out, "{n:5} {fns:5} {t}").unwrap();
    }
    writeln!(out, "\n# native functions: [crate] instance: reason").unwrap();
    for (f, why) in &natives {
        writeln!(out, "{f}: {why}").unwrap();
    }
    writeln!(out, "\n# VM functions also kept native (local copies native code of their CGU references)").unwrap();
    for f in &kept {
        writeln!(out, "{f}").unwrap();
    }
    writeln!(out, "\n# VM functions with islands: [crate] instance: template x count, ...").unwrap();
    for (f, by) in &with {
        let list: Vec<String> = by.iter().map(|(t, n)| format!("{t} x{n}")).collect();
        writeln!(out, "{f}: {}", list.join(", ")).unwrap();
    }
    out
}

/// Each island instance the fresh images call: its symbol and its template's name.
fn island_names<'tcx>(tcx: TyCtxt<'tcx>, rt: RtItems, fresh: &[Fresh<'tcx>]) -> Vec<(String, String)> {
    let mut out: Vec<(String, String)> = Vec::new();
    for v in fresh.iter().flat_map(|f| f.vm.iter()) {
        for r in &v.lowered.relocs {
            let CodeReloc::Island { template, args } = *r else { continue };
            let island = island_instance(tcx, rt.krate, template, args);
            out.push((tcx.symbol_name(island).name.to_owned(), template.to_string()));
        }
    }
    out.sort();
    out.dedup();
    out
}

/// The merge pass of a CGU's image: resolves every function's relocations, then lays out the
/// image. Appends to the `RYO_DUMP` and `RYO_DUMP_CODE` texts if those are on.
#[allow(clippy::too_many_arguments)]
fn build_image<'tcx>(
    tcx: TyCtxt<'tcx>,
    rt: RtItems,
    mode: asm::Mode,
    switches: &Switches,
    cgu_name: Symbol,
    vm: &mut [VmFn<'tcx>],
    dump_text: &mut String,
    code_text: &mut String,
) -> ImageObject {
    let mut w = ImageWriter::new(local_stable_crate_id(tcx));
    w.set_cgu_hash(ryo_bytecode::image::cgu_hash(cgu_name.as_str().as_bytes()));
    let rt_krate = rt.krate;
    let mut pool = Pool::default();
    w.prepare(mode);
    if symbols::is_macho(tcx.sess) {
        // As LLVM writes `__eh_frame` (design/platforms.md).
        w.set_eh_pointers(ryo_bytecode::image::EhPointers::Abs8);
    }
    let mut encoded = Vec::with_capacity(vm.len());
    if switches.dump.is_some() {
        dump_text.push_str(&dump::vm_text(tcx, vm, mode));
    }
    let mut code_dump = switches.dump_code.as_ref().map(|_| dump::code_text(tcx, vm));
    let merge_t = tcx.prof.generic_activity("ryo_merge");
    let index: FxHashMap<Instance<'tcx>, u32> = vm.iter().enumerate().map(|(i, v)| (v.instance, i as u32)).collect();
    for (i, v) in vm.iter_mut().enumerate() {
        let l = &mut v.lowered;
        // Each reference's value.
        let vals: Vec<u32> = l
            .relocs
            .iter()
            .map(|r| match *r {
                CodeReloc::Call { callee } => index[&callee],
                CodeReloc::Symbol { target } => {
                    let flags = symbols::symbol_flags(tcx, target, symbols::SymRole::Target);
                    let Sym(s) = w.symbol(tcx.symbol_name(target).name, flags);
                    s
                }
                CodeReloc::Static { def_id } => {
                    let flags = symbols::static_symbol_flags(tcx, def_id);
                    let Sym(s) = w.symbol(static_symbol(tcx, def_id).name, flags);
                    s
                }
                CodeReloc::Const { alloc, offset } => pool.intern(tcx, &mut w, alloc).0 + offset,
                CodeReloc::Bytes { ref bytes, align } => pool.bytes(&mut w, bytes, align).0,
                CodeReloc::Data { alloc, offset } => pool.data(tcx, &mut w, alloc).0 + offset,
                CodeReloc::Island { template, args } => {
                    let island = island_instance(tcx, rt_krate, template, args);
                    let flags = symbols::symbol_flags(tcx, island, symbols::SymRole::Island);
                    w.symbol(tcx.symbol_name(island).name, flags).0
                }
            })
            .collect();
        let mut code = std::mem::take(&mut l.code);
        if let Some(out) = &mut code_dump {
            dump::image_names(out, i, v.instance, &code.relocs, &vals);
        }
        for r in &mut code.relocs {
            let v = |i: u32| vals[i as usize];
            r.to = match r.to {
                Ref::Func(Func(i)) => Ref::Func(Func(v(i))),
                Ref::Sym(Sym(i)) => Ref::Sym(Sym(v(i))),
                Ref::Const(Const(i)) => Ref::Const(Const(v(i))),
                Ref::Data(Data(i)) => Ref::Data(Data(v(i))),
                Ref::Handler(_) | Ref::Probe | Ref::Ro(_) | Ref::Rec | Ref::RecLoopCtr | Ref::RegHandler(_) => r.to,
            };
        }
        // A global symbol with the function's linkage; an internal function native code
        // calls becomes hidden (design/backend.md, Linkage).
        let symbol = v.global.then(|| {
            let weak = !matches!(v.data.linkage, Linkage::External | Linkage::Internal);
            let visibility = match (v.data.linkage, v.data.visibility) {
                (Linkage::Internal, _) | (_, Visibility::Hidden) => SymVisibility::Hidden,
                (_, Visibility::Protected) => SymVisibility::Protected,
                (_, Visibility::Default) => SymVisibility::Default,
            };
            FuncSymbol { visibility, weak }
        });
        w.add_function(FunctionDef {
            name: tcx.symbol_name(v.instance).name.to_owned(),
            code: Vec::new(),
            frame_size: l.frame_size,
            arg_size: l.arg_size,
            ret_size: l.ret_size,
            ret_kind: l.ret_kind,
            cleanup: Vec::new(),
            symbol,
            flags: symbols::func_flags(tcx, v.instance),
        });
        encoded.push(code);
    }
    drop(merge_t);
    if let Some(text) = code_dump {
        code_text.push_str(&text);
    }
    let _t = tcx.prof.generic_activity("ryo_finish_image");
    match w.finish_encoded(encoded) {
        Ok(image) => image,
        Err(e) => tcx.dcx().fatal(format!("ryo: invalid image: {e:?}")),
    }
}

/// The instance of `ryo_rt`'s island template `template` for `args`.
fn island_instance<'tcx>(tcx: TyCtxt<'tcx>, rt: CrateNum, template: Symbol, args: ty::GenericArgsRef<'tcx>) -> Instance<'tcx> {
    let Some(&def_id) = tcx.diagnostic_items(rt).name_to_id.get(&template) else {
        tcx.dcx().fatal(format!("ryo_rt has no island template `{template}`; rebuild with `./y.sh build`"))
    };
    Instance::new_raw(def_id, args)
}

/// `instance` for stats output: untrimmed paths, since trimming needs a diagnostic.
pub(super) fn path(instance: Instance<'_>) -> String {
    rustc_middle::ty::print::with_no_trimmed_paths!(instance.to_string())
}

/// The items `instance` uses (`items_of_instance`, used items).
fn neighbors<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Vec<MonoItem<'tcx>> {
    match tcx.items_of_instance((instance, CollectionMode::UsedItems)) {
        Ok((used, _)) => used.iter().map(|s| s.node).collect(),
        Err(e) => tcx.dcx().fatal(format!("collecting the items used by {instance}: {e:?}")),
    }
}

/// Lowers a CGU's candidates `cands` (in parallel) until its set of VM functions is stable: a
/// function that calls a candidate which turned out native is lowered again, with an island
/// for that call. Only the CGU's own functions are direct callees (a VM function of another
/// CGU is called by symbol, `call.sym`, VM or not), so a CGU's classification depends on its
/// own items alone. Returns the lowered functions and the reasons the others stay native.
#[allow(clippy::type_complexity)]
fn lower_cgu<'tcx>(
    tcx: TyCtxt<'tcx>,
    cands: &[(Instance<'tcx>, MonoItemData)],
    mode: asm::Mode,
    switches: &Switches,
) -> (FxHashMap<Instance<'tcx>, LoweredFn<'tcx>>, Vec<(Instance<'tcx>, NeedsNative)>) {
    let mut vm: FxHashSet<Instance<'tcx>> = cands.iter().map(|c| c.0).collect();
    let mut ok: FxHashMap<Instance<'tcx>, LoweredFn<'tcx>> = FxHashMap::default();
    let mut failed = Vec::new();
    let mut todo: Vec<Instance<'tcx>> = cands.iter().map(|c| c.0).collect();
    while !todo.is_empty() {
        let cx = LowerCx { vm: &vm, mode, cert: switches.dump_lean.is_some(), asm_check: switches.asm_check };
        let out: Vec<_> = rustc_data_structures::sync::par_map(todo, |instance| (instance, lower::lower(tcx, &cx, instance)));
        let mut removed = false;
        for (instance, r) in out {
            match r {
                Ok(l) => {
                    ok.insert(instance, l);
                }
                Err(why) => {
                    ok.remove(&instance);
                    vm.remove(&instance);
                    failed.push((instance, why));
                    removed = true;
                }
            }
        }
        if !removed {
            break;
        }
        todo = ok
            .iter()
            .filter(|(_, l)| l.relocs.iter().any(|r| matches!(r, CodeReloc::Call { callee } if !vm.contains(callee))))
            .map(|(i, _)| *i)
            .collect();
        todo.sort_by_cached_key(|i| tcx.symbol_name(*i).name);
    }
    failed.sort_by_cached_key(|(i, _)| tcx.symbol_name(*i).name);
    (ok, failed)
}

/// The image's constant pool: allocations copied with their pointers relocated
/// (design/lowering.md#constants), and raw byte constants. Deduplicated. On PE, allocations
/// pointing directly at imports go into the writable fixup area instead, with a load-time
/// fixup per such pointer (`lower::constant::needs_fixup`).
#[derive(Default)]
struct Pool {
    allocs: FxHashMap<AllocId, AllocTarget>,
    bytes: FxHashMap<(Vec<u8>, u32), Const>,
}

impl Pool {
    /// The pool copy of `id`, which must not need the fixup area.
    fn intern<'tcx>(&mut self, tcx: TyCtxt<'tcx>, w: &mut ImageWriter, id: AllocId) -> Const {
        match self.target(tcx, w, id) {
            AllocTarget::Const(k) => k,
            _ => tcx.dcx().fatal("ryo: constant-pool reference to a fixup-area allocation"),
        }
    }

    /// The fixup-area copy of `id`, which must need it.
    fn data<'tcx>(&mut self, tcx: TyCtxt<'tcx>, w: &mut ImageWriter, id: AllocId) -> Data {
        match self.target(tcx, w, id) {
            AllocTarget::Data(d) => d,
            _ => tcx.dcx().fatal("ryo: fixup-area reference to a constant-pool allocation"),
        }
    }

    /// Where the copy of the memory or vtable allocation `id` is.
    fn target<'tcx>(&mut self, tcx: TyCtxt<'tcx>, w: &mut ImageWriter, id: AllocId) -> AllocTarget {
        if let Some(&t) = self.allocs.get(&id) {
            return t;
        }
        let alloc = match tcx.global_alloc(id) {
            GlobalAlloc::Memory(alloc) => alloc,
            GlobalAlloc::VTable(ty, dyn_ty) => {
                let t = self.target(tcx, w, lower::vtable_alloc(tcx, ty, dyn_ty));
                self.allocs.insert(id, t);
                return t;
            }
            GlobalAlloc::Function { .. } | GlobalAlloc::Static(_) | GlobalAlloc::TypeId { .. } => {
                tcx.dcx().fatal("ryo: constant-pool reference to a non-memory allocation")
            }
        };
        let inner = alloc.inner();
        let mut bytes = inner.inspect_with_uninit_and_ptr_outside_interpreter(0..inner.len()).to_vec();
        let mut relocs = Vec::new();
        let mut fixups = Vec::new();
        for &(offset, prov) in inner.provenance().ptrs().iter() {
            let at = offset.bytes() as usize;
            let addend = i64::from_le_bytes(bytes[at..at + 8].try_into().unwrap());
            let target_alloc = tcx.global_alloc(prov.alloc_id());
            if lower::is_import(tcx, &target_alloc) {
                // Patched at registration from the `__imp_` slot (design/platforms.md).
                let name = match target_alloc {
                    GlobalAlloc::Function { instance } => tcx.symbol_name(instance).name,
                    GlobalAlloc::Static(def_id) => static_symbol(tcx, def_id).name,
                    _ => unreachable!("only functions and statics are imports"),
                };
                bytes[at..at + 8].fill(0);
                fixups.push(AllocFixup { offset: at as u32, sym: w.symbol(name, SYM_INDIRECT), addend });
                continue;
            }
            let target = match target_alloc {
                GlobalAlloc::Memory(_) | GlobalAlloc::VTable(..) => self.target(tcx, w, prov.alloc_id()),
                GlobalAlloc::Function { instance } => AllocTarget::Symbol(w.symbol(tcx.symbol_name(instance).name, 0)),
                GlobalAlloc::Static(def_id) => AllocTarget::Symbol(w.symbol(static_symbol(tcx, def_id).name, 0)),
                // No address: the bytes (the offset) are part of the type id's hash
                // (`rustc_codegen_llvm/src/common.rs:201-205`).
                GlobalAlloc::TypeId { .. } => continue,
            };
            bytes[at..at + 8].fill(0);
            relocs.push(AllocReloc { offset: at as u32, target, addend });
        }
        let align = inner.align.bytes() as u32;
        let t = if fixups.is_empty() {
            AllocTarget::Const(w.add_const(&bytes, align, &relocs))
        } else {
            AllocTarget::Data(w.add_data(&bytes, align, &relocs, &fixups))
        };
        self.allocs.insert(id, t);
        t
    }

    fn bytes(&mut self, w: &mut ImageWriter, bytes: &[u8], align: u32) -> Const {
        *self.bytes.entry((bytes.to_vec(), align)).or_insert_with(|| w.add_const(bytes, align, &[]))
    }
}

/// The items an allocation refers to by symbol (functions and statics), through nested
/// allocations and vtables (like the collector's `collect_alloc`,
/// `rustc_monomorphize/src/collector.rs:1285`).
fn alloc_refs<'tcx>(tcx: TyCtxt<'tcx>, id: AllocId, seen: &mut FxHashSet<AllocId>, out: &mut Vec<MonoItem<'tcx>>) {
    if !seen.insert(id) {
        return;
    }
    match tcx.global_alloc(id) {
        GlobalAlloc::Function { instance } => out.push(MonoItem::Fn(instance)),
        GlobalAlloc::Static(def_id) => out.push(MonoItem::Static(def_id)),
        GlobalAlloc::Memory(alloc) => {
            for prov in alloc.inner().provenance().ptrs().values() {
                alloc_refs(tcx, prov.alloc_id(), seen, out);
            }
        }
        GlobalAlloc::VTable(ty, dyn_ty) => alloc_refs(tcx, lower::vtable_alloc(tcx, ty, dyn_ty), seen, out),
        GlobalAlloc::TypeId { .. } => {}
    }
}

/// The value of `upstream_monomorphizations`: per generic item, the upstream crate whose copy
/// of each instance to link to.
pub type UpstreamMonos<'tcx> = rustc_hir::def_id::DefIdMap<rustc_data_structures::unord::UnordMap<ty::GenericArgsRef<'tcx>, CrateNum>>;

/// Our `upstream_monomorphizations` (design/backend.md#query-overrides): rustc's, without the
/// copies in the runtime crates ([`RUNTIME_CRATES`]) of other crates' generics. rustc shares
/// `#[inline(never)]` instances even without share-generics; linking to them would turn the
/// program's own instances into the runtime's native code. A guard: the runtime used to
/// instantiate std's in its JIT, which is now a sealed object of its own (design/jit.md#packaging).
pub fn upstream_monomorphizations<'tcx>(tcx: TyCtxt<'tcx>, map: UpstreamMonos<'tcx>) -> UpstreamMonos<'tcx> {
    let runtime = |c: CrateNum| is_runtime_crate(tcx, c);
    map.into_items()
        .filter_map(|(def, args)| {
            let args: rustc_data_structures::unord::UnordMap<_, _> =
                if runtime(def.krate) { args } else { args.into_items().filter(|&(_, c)| !runtime(c)).collect() };
            (!args.is_empty()).then_some((def, args))
        })
        .collect()
}

/// Our local `exported_generic_symbols` (design/backend.md#query-overrides): rustc lists the
/// native CGU's generic items; the VM functions' symbols the image defines are added as
/// rustc would list them if they were in the CGU (`exported_generic_symbols_provider_local`:
/// generic `Item` instances and drop glue shims), and items made hidden only for the image
/// aren't listed.
pub fn exported_generic_symbols<'tcx>(
    tcx: TyCtxt<'tcx>,
    list: &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)],
) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    if !tcx.sess.opts.output_types.should_codegen() {
        return list;
    }
    let Some(r) = results_untracked(tcx) else { return list };
    let hidden: FxHashSet<Instance<'tcx>> = r.exports(tcx).hidden_for_image.iter().copied().collect();
    let mut out: Vec<_> = list
        .iter()
        .copied()
        .filter(|&(s, _)| match s {
            ExportedSymbol::Generic(def_id, args) => !hidden.contains(&Instance::new_raw(def_id, args)),
            ExportedSymbol::DropGlue(ty) => !hidden.contains(&Instance::resolve_drop_glue(tcx, ty)),
            _ => true,
        })
        .collect();
    if tcx.local_crate_exports_generics() {
        let need_visibility = tcx.sess.target.dynamic_linking && !tcx.sess.target.only_cdylib;
        let reachable = tcx.reachable_set(());
        let local_unreachable = |ty: Ty<'tcx>| {
            let root = match ty.peel_refs().kind() {
                ty::Closure(d, _) | ty::FnDef(d, _) | ty::Coroutine(d, _) | ty::CoroutineClosure(d, _) | ty::CoroutineWitness(d, _) => *d,
                _ => return false,
            };
            root.as_local().is_some_and(|d| !reachable.contains(&d))
        };
        let downstream = |def: Option<DefId>, args: ty::GenericArgsRef<'tcx>| {
            args.types().chain(def.map(|d| tcx.type_of(d).skip_binder())).all(|t| t.walk().all(|a| a.as_type().is_none_or(|t| !local_unreachable(t))))
        };
        let info = SymbolExportInfo { level: SymbolExportLevel::Rust, kind: SymbolExportKind::Text, used: false, rustc_std_internal_symbol: false };
        for &(instance, vis) in &r.exports(tcx).vm {
            if need_visibility && vis == Visibility::Hidden {
                continue;
            }
            if !tcx.sess.opts.share_generics() && tcx.codegen_fn_attrs(instance.def_id()).inline != rustc_hir::attrs::InlineAttr::Never {
                continue;
            }
            // The kinds rustc shares (`symbol_export.rs:398-484`).
            let symbol = match instance.def {
                InstanceKind::Item(def) => (instance.args.non_erasable_generics().next().is_some() && downstream(Some(def), instance.args))
                    .then_some(ExportedSymbol::Generic(def, instance.args)),
                InstanceKind::Shim(ty::ShimKind::DropGlue(_, Some(ty))) => {
                    let shared = match ty.kind() {
                        ty::Adt(_, args) | ty::Closure(_, args) => downstream(None, args),
                        _ => true,
                    };
                    shared.then_some(ExportedSymbol::DropGlue(ty))
                }
                InstanceKind::Shim(ty::ShimKind::AsyncDropGlueCtor(_, ty)) => Some(ExportedSymbol::AsyncDropGlueCtorShim(ty)),
                InstanceKind::Shim(ty::ShimKind::AsyncDropGlue(def, ty)) => Some(ExportedSymbol::AsyncDropGlue(def, ty)),
                _ => None,
            };
            out.extend(symbol.map(|s| (s, info)));
        }
    }
    out.sort_by_cached_key(|s| s.0.symbol_name_for_local_instance(tcx));
    tcx.arena.alloc_from_iter(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The checksum covers the has-object byte, which gates reuse, as well as the fields.
    #[test]
    fn side_checksum_covers_every_byte() {
        let body = [1u8, 2, 3, 4];
        let mut data = vec![1u8];
        data.extend_from_slice(&side_checksum(1, &body));
        data.extend_from_slice(&body);
        assert_eq!(CguVm::split(&data), Some((true, &body[..])));
        for i in [0, 1, SIDE_HEADER, data.len() - 1] {
            let mut bad = data.clone();
            bad[i] ^= 1;
            assert!(CguVm::split(&bad).is_none(), "byte {i}");
        }
        assert!(CguVm::split(&data[..10]).is_none());
    }
}
