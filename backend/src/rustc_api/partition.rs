//! Pipeline steps 1–4 (design/backend.md#pipeline), run inside our
//! `collect_and_partition_mono_items`: collect, classify, lower, build the native CGU. Also
//! builds the image (step 5's contents; `codegen_crate` writes it), and the `symbol_name` and
//! exported-symbols overrides that depend on these results.

use std::sync::OnceLock;

use rustc_data_structures::fx::{FxHashMap, FxHashSet, FxIndexMap};
use rustc_hir::attrs::Linkage;
use rustc_hir::def_id::{CrateNum, DefId, LOCAL_CRATE};
use rustc_middle::middle::exported_symbols::{ExportedSymbol, SymbolExportInfo, SymbolExportKind, SymbolExportLevel};
use rustc_middle::mir::interpret::{AllocId, GlobalAlloc};
use rustc_middle::mono::{CodegenUnit, CollectionMode, MonoItem, MonoItemData, MonoItemPartitions, Visibility};
use rustc_middle::ty::{self, Instance, InstanceKind, Ty, TyCtxt, TypingEnv};
use rustc_session::config::{CrateType, EntryFnType};
use rustc_span::Symbol;
use ryo_bytecode::asm::{self, Ref};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};
use ryo_bytecode::image::{AllocFixup, AllocReloc, AllocTarget, FuncSymbol, FunctionDef, ImageObject, ImageWriter, SYM_INDIRECT, SymVisibility};

use crate::objfile;

use rustc_middle::dep_graph::{WorkProduct, WorkProductId};

use super::dump;
use super::link::LinkedRoots;
use super::lower::{self, CodeReloc, LowerCx, LoweredFn, NeedsNative};
use super::persist;
use super::switches::Switches;
use super::symbols::{self, local_stable_crate_id, rt_symbol, static_symbol};

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

/// Whether `krate` is `ryo_rt`.
pub fn is_rt_crate(tcx: TyCtxt<'_>, krate: CrateNum) -> bool {
    tcx.crate_name(krate).as_str() == "ryo_rt"
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
    /// For `exported_non_generic_symbols`: the Rust symbols the images refer to ([`Roots`]).
    lto_roots: Vec<(String, SymbolExportKind)>,
    /// The interned data, lifetime-erased ([`Results::exports`]).
    exports: Exports<'static>,
}

/// The image of one codegen unit (design/backend.md#pipeline).
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

pub fn results(tcx: TyCtxt<'_>) -> Option<&'static Results> {
    RESULTS.get(tcx)
}

impl Results {
    fn new<'tcx>(images: Vec<CguImage>, lean: Option<LeanCerts>, lto_roots: Vec<(String, SymbolExportKind)>, exports: Exports<'tcx>) -> Self {
        // SAFETY: only the lifetime parameter changes; `exports` restores it (see there).
        let exports = unsafe { std::mem::transmute::<Exports<'tcx>, Exports<'static>>(exports) };
        Results { images, lean, lto_roots, exports }
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
    // rustc only allows LTO of a dylib with `-Zdylib-lto`, which isn't tested with the image.
    if matches!(tcx.sess.lto(), rustc_session::config::Lto::Fat | rustc_session::config::Lto::Thin)
        && tcx.crate_types().iter().any(|t| matches!(t, CrateType::Dylib | CrateType::Sdylib))
    {
        tcx.dcx().fatal("the ryo backend doesn't support `-Clto` for dylibs");
    }
    let partitions = original(tcx, ());
    let Some(rt) = rt_items(tcx) else { tcx.dcx().fatal("the ryo backend needs `ryo_rt` (`--extern force:ryo_rt`); run it through `rustc-ryo`") };

    let (native, results) = {
        let _t = tcx.prof.generic_activity("ryo_partition");
        Partitioner::new(tcx, rt, &switches, partitions.codegen_units).run()
    };
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

/// Whether the crate may have VM code. Proc macros stay native: it keeps VM code out of
/// rustc's own process, and they gain nothing from it. `RYO_NO_VM` is a debugging switch
/// (design/backend.md#pipeline, step 2). A panic runtime (`panic_unwind`, `panic_abort`) too:
/// portals re-raise a panic from the VM through its `__rust_start_panic` (design/vm.md,
/// Unwinding), so that must be native, and the rest of the runtime gains nothing from the VM.
fn vm_enabled(tcx: TyCtxt<'_>, switches: &Switches) -> bool {
    !switches.no_vm && !tcx.crate_types().contains(&CrateType::ProcMacro) && !tcx.is_panic_runtime(LOCAL_CRATE)
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
/// frame_pointer` decides: the target's default, `-Zinstrument-mcount` and
/// `-Cforce-frame-pointers`. `NonLeaf` counts as `Always`: VM functions call handlers.
fn needs_frame_pointer(sess: &rustc_session::Session) -> bool {
    use rustc_target::spec::FramePointer;
    let mut fp = sess.target.frame_pointer;
    if let rustc_session::config::InstrumentMcount::Mcount(_) = sess.opts.unstable_opts.instrument_mcount {
        fp.ratchet(FramePointer::Always);
    }
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
/// calls, the items it refers to by symbol, its LTO roots, and the symbol `__ryo_main` points
/// at. A function of the CGU's own items and tracked queries alone, so it is saved with the
/// image and read back when the image is reused (design/backend.md#incremental, `persist.rs`).
pub(super) struct CguVm<'tcx> {
    vm: Vec<(Instance<'tcx>, bool)>,
    islands: Vec<Instance<'tcx>>,
    refs: Vec<MonoItem<'tcx>>,
    roots: Vec<(String, u8)>,
    main: Option<String>,
}

type CguVmData<'tcx> = (Vec<(Instance<'tcx>, bool)>, Vec<Instance<'tcx>>, Vec<MonoItem<'tcx>>, Vec<(String, u8)>, Option<String>);

impl<'tcx> CguVm<'tcx> {
    fn empty() -> Self {
        CguVm { vm: Vec::new(), islands: Vec::new(), refs: Vec::new(), roots: Vec::new(), main: None }
    }

    fn save(&self, tcx: TyCtxt<'tcx>) -> Vec<u8> {
        persist::encode(tcx, &(&self.vm, &self.islands, &self.refs, &self.roots, &self.main))
    }

    fn load(tcx: TyCtxt<'tcx>, data: &[u8]) -> Option<Self> {
        let (vm, islands, refs, roots, main): CguVmData<'tcx> = persist::decode(tcx, data)?;
        Some(CguVm { vm, islands, refs, roots, main })
    }
}

fn root_kind(k: SymbolExportKind) -> u8 {
    match k {
        SymbolExportKind::Text => 0,
        SymbolExportKind::Data => 1,
        SymbolExportKind::Tls => 2,
    }
}

fn root_kind_of(k: u8) -> SymbolExportKind {
    match k {
        0 => SymbolExportKind::Text,
        1 => SymbolExportKind::Data,
        _ => SymbolExportKind::Tls,
    }
}

/// Where a CGU's image object comes from.
pub enum ImageSrc {
    /// Written this session, with its side data ([`CguVm::save`]).
    Fresh { image: ImageObject, side: Vec<u8> },
    /// The previous session's, from the incremental cache: its work product.
    Reused(WorkProduct),
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
fn image_settings(tcx: TyCtxt<'_>, mode: asm::Mode, switches: &Switches) -> String {
    // The backend itself: a rebuilt backend may lower differently.
    let backend = tcx.sess.opts.unstable_opts.codegen_backend.as_deref().and_then(|p| std::fs::metadata(p).ok()).map(|m| {
        let t = m.modified().ok().and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok()).map_or(0, |d| d.as_nanos());
        (m.len(), t)
    });
    format!("{:?} {} {} {backend:?} {}", mode, local_stable_crate_id(tcx), switches.asm_align, env!("CARGO_PKG_VERSION"))
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
        Partitioner { tcx, rt, switches, mode: asm_mode(tcx, rt, switches), units, homes, stats: Stats::default() }
    }

    fn run(mut self) -> (Vec<CodegenUnit<'tcx>>, Results) {
        let tcx = self.tcx;
        let stats = self.switches.stats;

        // Steps 2, 3 and 5's contents, per CGU and in parallel (over CGUs, and over each one's
        // functions): classify, lower and build the image, or reuse the previous session's.
        let settings = image_settings(tcx, self.mode, self.switches);
        let entry = tcx.entry_fn(()).map(|(def_id, _)| Instance::mono(tcx, def_id));
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
        let failed: Vec<(Instance<'tcx>, NeedsNative)> =
            fresh.iter().flat_map(|f| f.failed.iter().map(|(i, w)| (*i, NeedsNative(w.0.clone())))).collect();
        if stats >= 2 {
            for (instance, why) in &failed {
                eprintln!("ryo: native {}: {}", path(*instance), why.0);
            }
        }
        self.stats.native_fns = failed.len();

        // Step 1 (symbols) and 4, per CGU: the native items' references to VM functions,
        // islands, the entry wrapper, the stub neighbors, and the native items the image
        // refers to.
        let stubs_t = tcx.prof.generic_activity("ryo_stubs");
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
            self.walk_stub_neighbors(u);
            let refs = self.units[u].vm.refs.clone();
            for item in refs {
                self.make_visible(u, item);
            }
            self.walk_stub_neighbors(u);
        }
        self.stats.islands = islands.len();

        // The native CGUs: each original's native items, then its stubs and their neighbors.
        let mut natives = Vec::with_capacity(self.units.len());
        for unit in &self.units {
            let mut native = CodegenUnit::new(unit.cgu.name());
            // Set by `merge_codegen_units` for every CGU (`rustc_monomorphize/src/partitioning.rs:462-507`).
            native.set_symbol_name(unit.cgu.symbol_name());
            if unit.cgu.is_primary() {
                native.make_primary();
            }
            if unit.cgu.is_code_coverage_dead_code_cgu() {
                native.make_code_coverage_dead_code_cgu();
            }
            let items = native.items_mut();
            for (item, data) in unit.cgu.items() {
                let is_vm = matches!(item, MonoItem::Fn(i) if unit.index.contains_key(i) && !unit.keep_native.contains(i));
                if !is_vm {
                    let mut data = *data;
                    if let Some(&(linkage, visibility)) = unit.flips.get(item) {
                        data.linkage = linkage;
                        data.visibility = visibility;
                    }
                    items.insert(*item, data);
                }
            }
            for (item, data) in &unit.added {
                items.insert(*item, *data);
            }
            native.compute_size_estimate();
            natives.push(native);
        }
        drop(stubs_t);

        if stats >= 1 {
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
            let cross = self.cross_image_refs(&fresh);
            eprintln!("ryo: {n_images} images in {} codegen units, {cross} cross-image references to VM functions", self.units.len());
            eprintln!("ryo: {} of {n_images} images reused", self.stats.reused);
            // Constants are deduplicated per image only: several images may each hold a copy.
            let pool: usize = fresh.iter().map(|f| f.pool).sum();
            eprintln!("ryo: {pool} bytes of constant pools in the {} images built", fresh.iter().filter(|f| !f.vm.is_empty()).count());
            print_coverage(&fresh, &failed);
        }

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
            LeanCerts { images, islands: island_names(tcx, self.rt, &fresh) }
        });
        if let Some(path) = &self.switches.dump {
            dump::write(tcx, "RYO_DUMP", path, &fresh.iter().map(|f| f.dump.as_str()).collect::<String>());
        }
        if let Some(path) = &self.switches.dump_code {
            dump::write(tcx, "RYO_DUMP_CODE", path, &fresh.iter().map(|f| f.code_dump.as_str()).collect::<String>());
        }
        let mut roots = Roots::default();
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
            for (name, kind) in &unit.vm.roots {
                roots.add(name, root_kind_of(*kind));
            }
        }
        let results = Results::new(images, lean, roots.0.into_iter().collect(), Exports { vm: vm_exports, hidden_for_image: hidden });
        (natives, results)
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
        let tcx = self.tcx;
        let unit = &mut self.units[u];
        let Some(&global) = unit.index.get(&instance) else { return };
        if global || !unit.keep_native.insert(instance) {
            return;
        }
        let item = MonoItem::Fn(instance);
        if !unit.cgu.items().contains_key(&item) {
            let data =
                MonoItemData { inlined: false, linkage: Linkage::Internal, visibility: Visibility::Default, size_estimate: item.size_estimate(tcx) };
            unit.added.insert(item, data);
        }
        // Its own references are native now too (`walk_stub_neighbors`).
        unit.work.push(instance);
    }

    /// Whether `item` is defined with a global symbol by some CGU other than `u`: one of its
    /// non-internal items (VM or native), or a VM function another image gives a global symbol.
    fn global_elsewhere(&self, u: usize, item: MonoItem<'tcx>) -> bool {
        let Some(homes) = self.homes.get(&item) else { return false };
        homes.iter().any(|&h| {
            h != u
                && (self.units[h].cgu.items()[&item].linkage != Linkage::Internal
                    || matches!(item, MonoItem::Fn(f) if self.units[h].index.get(&f) == Some(&true)))
        })
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
    /// to, not defined. An item another CGU defines globally is referenced; otherwise it is
    /// added internal: only the stubs reference it.
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
                if unit.cgu.items().contains_key(&n) || unit.added.contains_key(&n) || self.global_elsewhere(u, n) {
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
            let unit = &mut self.units[u];
            if unit.added.contains_key(&item) || unit.cgu.items().contains_key(&item) {
                continue;
            }
            // Upstream copies, and non-generic templates, which `ryo_rt` itself defines.
            if island.upstream_monomorphization(tcx).is_some() || !tcx.should_codegen_locally(island) {
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
        // Defined by another CGU: a native item there needs at most the linkonce flip.
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
    let build = || build_cgu(tcx, rt, mode, switches, entry, cgu, &cands);
    let incremental = tcx.dep_graph.is_fully_enabled()
        && !tcx.sess.opts.unstable_opts.disable_incr_comp_backend_caching
        && switches.dump_lean.is_none()
        && switches.dump.is_none()
        && switches.dump_code.is_none();
    if !incremental {
        return build();
    }
    // The image's dep node: named after the CGU, its candidates with their linkage and
    // visibility, and the settings, so that a change to any of them gives a node the previous
    // session didn't have. The queries the lowering reads are the node's edges.
    let mut key = format!("{}\n{settings}\n{entry:?}\n", cgu.name());
    for (i, d) in &cands {
        key.push_str(&format!("{} {:?} {:?}\n", tcx.symbol_name(*i).name, d.linkage, d.visibility));
    }
    let fp = {
        use std::hash::Hash;
        let mut h = rustc_data_structures::stable_hash::StableHasher::new();
        key.hash(&mut h);
        let f: rustc_data_structures::fingerprint::Fingerprint = h.finish();
        f.to_hex()
    };
    let node = CodegenUnit::new(Symbol::intern(&format!("{}.ryo.{fp}", cgu.name()))).codegen_dep_node(tcx);
    let wp = image_work_product_name(cgu.name());
    let prev = tcx.dep_graph.previous_work_product(&WorkProductId::from_cgu_name(&wp));
    let side = prev
        .as_ref()
        .and_then(|p| p.saved_files.get("o").and(p.saved_files.get("ryo")))
        .zip(tcx.incr_comp_session)
        .and_then(|(f, incr)| std::fs::read(rustc_incremental::in_incr_comp_dir_sess(incr, f)).ok());
    if let (Some(prev), Some(side)) = (prev, side)
        && tcx.dep_graph.try_mark_green(tcx, &node).is_some()
    {
        let vm = CguVm::load(tcx, &side).unwrap_or_else(|| tcx.dcx().fatal(format!("ryo: the saved image of `{}` is unreadable", cgu.name())));
        return ImagePart { vm, image: Some(ImageSrc::Reused(prev)), fresh: None };
    }
    tcx.dep_graph.with_task(node, tcx, build, None).0
}

/// The work product name of CGU `cgu`'s image (its object and side data).
pub fn image_work_product_name(cgu: Symbol) -> String {
    format!("{cgu}.ryo")
}

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
        return ImagePart {
            vm: CguVm::empty(),
            image: None,
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
    let (image, roots) = build_image(tcx, rt, mode, switches, cgu.name(), &mut vm, &mut dump, &mut code_dump);
    let at = std::mem::offset_of!(ryo_bytecode::image::Header, consts) + 4;
    let pool = image.rodata.get(at..at + 4).map_or(0, |b| u32::from_le_bytes(b.try_into().unwrap()) as usize);
    let cgu_vm = CguVm {
        vm: vm.iter().map(|v| (v.instance, v.global)).collect(),
        islands,
        refs,
        roots: roots.0.into_iter().map(|(n, k)| (n, root_kind(k))).collect(),
        main,
    };
    let side = cgu_vm.save(tcx);
    ImagePart { vm: cgu_vm, image: Some(ImageSrc::Fresh { image, side }), fresh: Some(Fresh { cgu: cgu.name(), vm, pool, failed, dump, code_dump }) }
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
) -> (ImageObject, Roots) {
    let mut w = ImageWriter::new(local_stable_crate_id(tcx));
    w.set_cgu_hash(ryo_bytecode::image::cgu_hash(cgu_name.as_str().as_bytes()));
    let rt_krate = rt.krate;
    let mut pool = Pool::default();
    w.prepare(mode);
    if tcx.sess.target.binary_format == rustc_target::spec::BinaryFormat::MachO {
        // As LLVM writes `__eh_frame` (design/platforms.md).
        w.set_eh_pointers(ryo_bytecode::image::EhPointers::Abs8);
    }
    let mut encoded = Vec::with_capacity(vm.len());
    // The handlers the code calls, and whether it probes the stack.
    let mut handlers = vec![false; ryo_bytecode::full::ALL_OPCODES.len()];
    let mut probe = false;
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
                    pool.roots.function(tcx, target);
                    let flags = symbols::symbol_flags(tcx, target, symbols::SymRole::Target);
                    let Sym(s) = w.symbol(tcx.symbol_name(target).name, flags);
                    if flags & ryo_bytecode::image::SYM_INDIRECT != 0 {
                        // A direct reference too, so the linker extracts the archive member
                        // defining a statically linked function: `__imp_<sym>` is only
                        // synthesized for symbols that are already defined
                        // (design/platforms.md). Functions in DLLs resolve to their thunk.
                        w.symbol(tcx.symbol_name(target).name, 0);
                    }
                    s
                }
                CodeReloc::Static { def_id } => {
                    pool.roots.static_(tcx, def_id);
                    let flags = symbols::static_symbol_flags(tcx, def_id);
                    let Sym(s) = w.symbol(static_symbol(tcx, def_id).name, flags);
                    if flags & ryo_bytecode::image::SYM_INDIRECT != 0 && symbols::static_needs_direct_slot(tcx, def_id) {
                        // As for functions: lld synthesizes `__imp_<sym>` only for a
                        // defined symbol, and a C static library has no `__imp_` of its own
                        // (design/platforms.md).
                        w.symbol(static_symbol(tcx, def_id).name, 0);
                    }
                    s
                }
                CodeReloc::Const { alloc, offset } => pool.intern(tcx, &mut w, alloc).0 + offset,
                CodeReloc::Bytes { ref bytes, align } => pool.bytes(&mut w, bytes, align).0,
                CodeReloc::Data { alloc, offset } => pool.data(tcx, &mut w, alloc).0 + offset,
                CodeReloc::Island { template, args } => {
                    let island = island_instance(tcx, rt_krate, template, args);
                    pool.roots.function(tcx, island);
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
                Ref::Site(Site(i)) => Ref::Site(Site(v(i))),
                Ref::Const(Const(i)) => Ref::Const(Const(v(i))),
                Ref::Data(Data(i)) => Ref::Data(Data(v(i))),
                Ref::Handler(op) => {
                    handlers[op as usize] = true;
                    r.to
                }
                Ref::Probe => {
                    probe = true;
                    r.to
                }
                Ref::Ro(_) | Ref::Rec | Ref::RecLoopCtr | Ref::RegHandler(_) => r.to,
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
    for (i, _) in handlers.iter().enumerate().filter(|h| *h.1) {
        pool.roots.text(&rt_symbol(tcx, &objfile::handler_name(ryo_bytecode::full::ALL_OPCODES[i])));
    }
    if probe {
        pool.roots.text(&rt_symbol(tcx, objfile::PROBE_SYMBOL));
    }
    if mode.counters {
        pool.roots.text(&rt_symbol(tcx, objfile::TRIP_ENTRY_SYMBOL));
        pool.roots.text(&rt_symbol(tcx, objfile::TRIP_OSR_SYMBOL));
    }
    if mode.pe {
        pool.roots.text(&rt_symbol(tcx, objfile::SEH_HANDLER_SYMBOL));
    } else {
        pool.roots.text(ryo_bytecode::image::PERSONALITY);
    }
    match w.finish_encoded(encoded) {
        Ok(image) => (image, pool.roots),
        Err(e) => tcx.dcx().fatal(format!("ryo: invalid image: {e:?}")),
    }
}

/// `instance` for stats output: untrimmed paths, since trimming needs a diagnostic.
/// The instance of `ryo_rt`'s island template `template` for `args`.
fn island_instance<'tcx>(tcx: TyCtxt<'tcx>, rt: CrateNum, template: Symbol, args: ty::GenericArgsRef<'tcx>) -> Instance<'tcx> {
    let Some(&def_id) = tcx.diagnostic_items(rt).name_to_id.get(&template) else {
        tcx.dcx().fatal(format!("ryo_rt has no island template `{template}`; rebuild with `./y.sh build`"))
    };
    Instance::new_raw(def_id, args)
}

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
    /// Every symbol the image refers to that LTO must keep.
    roots: Roots,
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
            match target_alloc {
                GlobalAlloc::Function { instance } => self.roots.function(tcx, instance),
                GlobalAlloc::Static(def_id) => self.roots.static_(tcx, def_id),
                GlobalAlloc::Memory(_) | GlobalAlloc::VTable(..) | GlobalAlloc::TypeId { .. } => {}
            }
            if lower::is_import(tcx, &target_alloc) {
                // Patched at registration from the `__imp_` slot (design/platforms.md).
                let (name, direct) = match target_alloc {
                    GlobalAlloc::Function { instance } => (tcx.symbol_name(instance).name, true),
                    GlobalAlloc::Static(def_id) => (static_symbol(tcx, def_id).name, symbols::static_needs_direct_slot(tcx, def_id)),
                    _ => unreachable!("only functions and statics are imports"),
                };
                if direct {
                    // So the linker extracts the archive member defining it, as for code
                    // references (`build_image`).
                    w.symbol(name, 0);
                }
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

/// The symbols the image refers to, which `-Clto` must not internalize: the image is a
/// separate object that LTO doesn't see (design/backend.md#query-overrides). That includes
/// foreign items, which an LTO module may define (the allocator shim's `__rust_alloc`).
/// `link` takes them out of export lists and `symbols.o` again ([`linked_roots`]).
/// On PE, the image refers to an imported static as `__imp_<name>`, which the linker
/// synthesizes for a static linked in statically, if LTO kept `<name>`.
#[derive(Default)]
struct Roots(FxIndexMap<String, SymbolExportKind>);

impl Roots {
    fn text(&mut self, name: &str) {
        self.add(name, SymbolExportKind::Text);
    }

    /// Adds `name` unless present, allocating only then (most references repeat a symbol).
    fn add(&mut self, name: &str, kind: SymbolExportKind) {
        if !self.0.contains_key(name) {
            self.0.insert(name.to_owned(), kind);
        }
    }

    fn function<'tcx>(&mut self, tcx: TyCtxt<'tcx>, f: Instance<'tcx>) {
        self.text(tcx.symbol_name(f).name);
    }

    fn static_(&mut self, tcx: TyCtxt<'_>, def_id: DefId) {
        self.add(static_symbol(tcx, def_id).name, SymbolExportKind::Data);
    }
}

/// Our local `exported_non_generic_symbols` (design/backend.md#query-overrides): adds the
/// image's [`Roots`] as `used` symbols, which LTO keeps whatever its export threshold
/// (`rustc_codegen_ssa/src/back/lto.rs:107`), also downstream, from this crate's metadata.
/// They are not meant to be exported: `link` takes them out of every output's export list and
/// `symbols.o` again ([`linked_roots`]).
pub fn exported_non_generic_symbols<'tcx>(
    tcx: TyCtxt<'tcx>,
    list: &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)],
) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    // Without codegen there is no image (rustc's provider returns nothing then,
    // `symbol_export.rs:188`), and a proc macro's exports are fixed.
    if !tcx.sess.opts.output_types.should_codegen() || tcx.crate_types().contains(&CrateType::ProcMacro) {
        return list;
    }
    // Forces the partitioning, as `exported_generic_symbols` does during metadata encoding.
    let _ = tcx.collect_and_partition_mono_items(());
    let Some(r) = results(tcx) else { return list };
    let info = |kind| SymbolExportInfo { level: SymbolExportLevel::Rust, kind, used: true, rustc_std_internal_symbol: false };
    debug_assert!(is_root(&ExportedSymbol::NoDefId(ty::SymbolName::new(tcx, "")), &info(SymbolExportKind::Text)));
    let mut roots: Vec<_> = r.lto_roots.iter().collect();
    roots.sort_by(|a, b| a.0.cmp(&b.0));
    let roots = roots.into_iter().map(|(name, kind)| (ExportedSymbol::NoDefId(ty::SymbolName::new(tcx, name)), info(*kind)));
    tcx.arena.alloc_from_iter(list.iter().copied().chain(roots))
}

/// Whether an exported symbol is one of the [`Roots`] that `exported_non_generic_symbols`
/// adds: rustc's own `NoDefId` symbols are never `used` at the `Rust` level.
fn is_root(s: &ExportedSymbol<'_>, info: &SymbolExportInfo) -> bool {
    matches!(s, ExportedSymbol::NoDefId(_)) && info.used && info.level == SymbolExportLevel::Rust && !info.rustc_std_internal_symbol
}

/// The [`Roots`] of the crates an output of `crate_type` links statically, one entry per
/// crate that lists it: the entries they add to that output's `CrateInfo::exported_symbols`
/// (a Rust dylib exports the `Rust` level, `linker.rs:1700-1716`) and `linked_symbols`
/// (`used` symbols go into `symbols.o`, `linker.rs:1780`; rustc leaves it empty under
/// `-Clto`, `linker.rs:1760-1768`), which `link` removes again. Exporting them would fail
/// (they include other crates' and foreign symbols), and on PE a plain-name reference in
/// `symbols.o` to a static in a DLL wouldn't resolve. The images reference every root anyway.
///
/// Returns (the entries in `linked_symbols`, the entries in `exported_symbols`). rustc adds a
/// root to the export list only where the `Rust` level is below the crate type's threshold
/// (Rust dylibs) and the crate isn't `compiler_builtins`, and never for proc macros
/// (`linker.rs:1677-1716`); the same filter here, so `link` never removes one of rustc's own
/// entries of the same name (a `#[no_mangle]` function the image calls, exported by a
/// cdylib). Names are compared undecorated. That holds for the export list's `name`
/// (`symbol_export.rs:737-738`), and for `linked_symbols` on x86_64; on targets that
/// decorate (i686 Windows `_`, Arm64EC `#`, `linking_symbol_name_for_instance_in_crate`)
/// the roots would stay in `symbols.o`, which ryo doesn't support anyway.
pub fn linked_roots(tcx: TyCtxt<'_>, crate_type: CrateType) -> LinkedRoots {
    let mut roots = LinkedRoots { linked: Vec::new(), exported: Vec::new() };
    let Some(deps) = tcx.dependency_formats(()).get(&crate_type) else { return roots };
    let threshold = rustc_codegen_ssa::back::symbol_export::crates_export_threshold(&[crate_type]);
    let exports_rust = crate_type != CrateType::ProcMacro
        && SymbolExportLevel::Rust.is_below_threshold(threshold)
        && tcx.sess.target.override_export_symbols.is_none();
    for (cnum, linkage) in deps.iter_enumerated() {
        if *linkage != rustc_middle::middle::dependency_format::Linkage::Static {
            continue;
        }
        for (s, info) in tcx.exported_non_generic_symbols(cnum) {
            if let ExportedSymbol::NoDefId(name) = s
                && is_root(s, info)
            {
                roots.linked.push(name.name.to_owned());
                if exports_rust && !tcx.is_compiler_builtins(cnum) {
                    roots.exported.push(name.name.to_owned());
                }
            }
        }
    }
    roots
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
/// copies in `ryo_rt` and `ryo_bytecode` of other crates' generics. rustc shares
/// `#[inline(never)]` instances even without share-generics; linking to them would turn the
/// program's own instances into the runtime's native code. A guard: the runtime used to
/// instantiate std's in its JIT, which is now a sealed object of its own (design/jit.md#packaging).
pub fn upstream_monomorphizations<'tcx>(tcx: TyCtxt<'tcx>, map: UpstreamMonos<'tcx>) -> UpstreamMonos<'tcx> {
    let runtime = |c: CrateNum| matches!(tcx.crate_name(c).as_str(), "ryo_rt" | "ryo_bytecode");
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
/// rustc would list them if they were in the CGU (`exported_generic_symbols_provider_local`,
/// generic `Item` instances only), and items made hidden only for the image aren't listed.
pub fn exported_generic_symbols<'tcx>(
    tcx: TyCtxt<'tcx>,
    list: &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)],
) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    let Some(r) = results(tcx) else { return list };
    let hidden: FxHashSet<Instance<'tcx>> = r.exports(tcx).hidden_for_image.iter().copied().collect();
    let mut out: Vec<_> = list
        .iter()
        .copied()
        .filter(|&(s, _)| !matches!(s, ExportedSymbol::Generic(def_id, args) if hidden.contains(&Instance::new_raw(def_id, args))))
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
        for &(instance, vis) in &r.exports(tcx).vm {
            let InstanceKind::Item(def) = instance.def else { continue };
            if need_visibility && vis == Visibility::Hidden {
                continue;
            }
            if !tcx.sess.opts.share_generics() && tcx.codegen_fn_attrs(def).inline != rustc_hir::attrs::InlineAttr::Never {
                continue;
            }
            let downstream = instance
                .args
                .types()
                .chain([tcx.type_of(def).skip_binder()])
                .all(|t| t.walk().all(|a| a.as_type().is_none_or(|t| !local_unreachable(t))));
            if instance.args.non_erasable_generics().next().is_some() && downstream {
                let info =
                    SymbolExportInfo { level: SymbolExportLevel::Rust, kind: SymbolExportKind::Text, used: false, rustc_std_internal_symbol: false };
                out.push((ExportedSymbol::Generic(def, instance.args), info));
            }
        }
    }
    out.sort_by_cached_key(|s| s.0.symbol_name_for_local_instance(tcx));
    tcx.arena.alloc_from_iter(out)
}
