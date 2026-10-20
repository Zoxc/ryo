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
use rustc_middle::mono::{
    CodegenUnit, CollectionMode, InstantiationMode, MonoItem, MonoItemData, MonoItemPartitions, Visibility,
};
use rustc_middle::ty::{self, Instance, InstanceKind, Ty, TyCtxt, TypingEnv};
use rustc_session::config::{CrateType, EntryFnType};
use rustc_span::Symbol;
use ryo_bytecode::image::{
    AllocFixup, AllocReloc, AllocTarget, FunctionDef, ImageObject, ImageWriter, SYM_INDIRECT, portal_id,
};
use ryo_bytecode::insn::{Const, Data, Opcode, Sym};

use super::lower::{self, CodeReloc, LowerCx, LoweredFn, NeedsNative};

/// The `RYO_RT_ABI` the backend was written against (`vm/rt/src/lib.rs`).
const EXPECTED_RT_ABI: u32 = 2;

/// The `ryo_rt` items the backend instantiates or checks (design/stubs.md, Lookup).
#[derive(Clone, Copy)]
pub struct RtItems {
    pub krate: CrateNum,
    pub portal: DefId,
    /// `portal_tc0..=16`, the `#[track_caller]` portals.
    pub portal_tc: [DefId; lower::MAX_PORTAL_TC_ARITY + 1],
    pub c_main: DefId,
    pub abi: DefId,
}

/// The values below are computed once per session and kept in statics (providers are plain
/// fns). They are keyed on the session's `GlobalCtxt` address, so a second session in the same
/// process is detected instead of reading stale values.
fn session_key(tcx: TyCtxt<'_>) -> usize {
    std::ptr::from_ref::<rustc_middle::ty::GlobalCtxt<'_>>(*tcx) as usize
}

fn check_session(tcx: TyCtxt<'_>, key: usize) {
    if key != session_key(tcx) {
        tcx.dcx().fatal("the ryo backend supports one compilation session per process");
    }
}

static RT_ITEMS: OnceLock<(usize, Option<RtItems>)> = OnceLock::new();

/// `ryo_rt`'s crate and template items, found through its diagnostic items. `None` if
/// `ryo_rt` isn't loaded (rustc wasn't run through `rustc-ryo`).
pub fn rt_items(tcx: TyCtxt<'_>) -> Option<RtItems> {
    let (key, items) = *RT_ITEMS.get_or_init(|| {
        let find = || {
            let krate = *tcx.crates(()).iter().find(|&&c| tcx.crate_name(c).as_str() == "ryo_rt")?;
            let items = tcx.diagnostic_items(krate);
            let get = |name: &str| items.name_to_id.get(&Symbol::intern(name)).copied();
            let mut portal_tc = [get("ryo_portal")?; lower::MAX_PORTAL_TC_ARITY + 1];
            for (n, d) in portal_tc.iter_mut().enumerate() {
                *d = get(&format!("ryo_portal_tc{n}"))?;
            }
            Some(RtItems {
                krate,
                portal: get("ryo_portal")?,
                portal_tc,
                c_main: get("ryo_c_main")?,
                abi: get("ryo_rt_abi")?,
            })
        };
        (session_key(tcx), find())
    });
    check_session(tcx, key);
    items
}

/// What the partition provider hands to the other providers and to `codegen_crate`. Set once:
/// the query is `eval_always` and computed once per session.
pub struct Results {
    /// The name of the single (native) CGU, which `codegen_unit(name)` looks up.
    pub cgu_name: Symbol,
    /// The image, ready to be written as an object.
    pub image: ImageObject,
    /// The symbol `__ryo_main` points at: the entry fn's portal, for a VM `main`.
    pub main_portal: Option<String>,
    /// The symbol of each VM function, by image function index. A portal's symbol is its
    /// function's.
    symbols: Vec<String>,
    /// For `exported_non_generic_symbols`: the Rust symbols the image refers to ([`Roots`]).
    lto_roots: Vec<(String, SymbolExportKind)>,
    /// For `exported_generic_symbols`: (portal, original), lifetime-erased.
    portals: Vec<Pair<'static>>,
    /// The portals made `External` + `Hidden` only because the image references them.
    hidden_for_image: Vec<Instance<'static>>,
    /// `session_key` of the session that computed this.
    key: usize,
}

static RESULTS: OnceLock<Results> = OnceLock::new();

pub fn results(tcx: TyCtxt<'_>) -> Option<&'static Results> {
    let r = RESULTS.get()?;
    check_session(tcx, r.key);
    Some(r)
}

impl Results {
    /// The (portal, original) pairs.
    fn portals<'tcx>(&self, _tcx: TyCtxt<'tcx>) -> &[(Instance<'tcx>, Instance<'tcx>)] {
        // SAFETY: the instances were interned by this session's `TyCtxt`, which outlives every
        // query provider call, and a process runs one session (`RyoBackend::provide`). Only
        // the lifetime parameter changes.
        unsafe { std::mem::transmute::<&[Pair<'static>], &[Pair<'tcx>]>(&self.portals) }
    }

    fn hidden_for_image<'tcx>(&self, _tcx: TyCtxt<'tcx>) -> &[Instance<'tcx>] {
        // SAFETY: as for `portals`.
        unsafe { std::mem::transmute::<&[Instance<'static>], &[Instance<'tcx>]>(&self.hidden_for_image) }
    }
}

type Pair<'tcx> = (Instance<'tcx>, Instance<'tcx>);

fn erase(v: Vec<Pair<'_>>) -> Vec<Pair<'static>> {
    // SAFETY: see `Results::portals`; the values are only read back with the session's `'tcx`.
    unsafe { std::mem::transmute(v) }
}

fn stats_level() -> u32 {
    std::env::var("RYO_STATS").ok().and_then(|v| v.parse().ok()).unwrap_or(0)
}

/// Our `collect_and_partition_mono_items` (design/backend.md#pipeline steps 1–4).
pub fn collect_and_partition_mono_items<'tcx>(
    tcx: TyCtxt<'tcx>,
    original: super::PartitionProvider,
) -> MonoItemPartitions<'tcx> {
    // `rustc-ryo` forces `-Ccodegen-units=1`; `Session::codegen_units`
    // (`rustc_session/src/session.rs:1058`) returns it.
    let n = tcx.sess.codegen_units().as_usize();
    if n != 1 {
        tcx.dcx().fatal(format!(
            "the ryo backend requires `-Ccodegen-units=1`, but {n} codegen units were requested"
        ));
    }
    // rustc only allows LTO of a dylib with `-Zdylib-lto`, which isn't tested with the image.
    if matches!(tcx.sess.lto(), rustc_session::config::Lto::Fat | rustc_session::config::Lto::Thin)
        && tcx.crate_types().iter().any(|t| matches!(t, CrateType::Dylib | CrateType::Sdylib))
    {
        tcx.dcx().fatal("the ryo backend doesn't support `-Clto` for dylibs");
    }
    if std::env::var_os("RYO_BACKEND_MARKER").is_some() {
        eprintln!("{}", super::PARTITION_MARKER);
    }
    let partitions = original(tcx, ());
    // With one CGU requested, merging always leaves exactly one, and partitioning never returns
    // none (`rustc_monomorphize/src/partitioning.rs:286-288`).
    let [cgu] = partitions.codegen_units else {
        tcx.dcx().fatal(format!("the ryo backend expected one codegen unit, got {}", partitions.codegen_units.len()));
    };
    let Some(rt) = rt_items(tcx) else {
        tcx.dcx().fatal("the ryo backend needs `ryo_rt` (`--extern force:ryo_rt`); run it through `rustc-ryo`")
    };
    check_rt_abi(tcx, rt);

    let (native, results) = Partitioner::new(tcx, rt, cgu).run();
    if RESULTS.set(results).is_err() {
        tcx.dcx().fatal("collect_and_partition_mono_items ran twice in one process");
    }
    MonoItemPartitions {
        // `CodegenUnit` is arena-allocated (`rustc_middle/src/arena.rs:107`).
        codegen_units: tcx.arena.alloc_from_iter([native]),
        // Keeps every original DefId, VM functions included (design/backend.md#query-overrides).
        all_mono_items: partitions.all_mono_items,
    }
}

fn check_rt_abi(tcx: TyCtxt<'_>, rt: RtItems) {
    let abi = tcx
        .const_eval_poly(rt.abi)
        .ok()
        .and_then(|v| v.try_to_scalar_int())
        .map(|i| i.to_u32());
    if abi != Some(EXPECTED_RT_ABI) {
        tcx.dcx().fatal(format!(
            "ryo_rt's RYO_RT_ABI is {abi:?}, but this backend expects {EXPECTED_RT_ABI}; rebuild with `./y.sh build`"
        ));
    }
}

/// A VM function: its lowering, index and portal.
struct VmFn<'tcx> {
    instance: Instance<'tcx>,
    data: MonoItemData,
    lowered: LoweredFn<'tcx>,
    portal: Option<Instance<'tcx>>,
}

struct Partitioner<'a, 'tcx> {
    tcx: TyCtxt<'tcx>,
    rt: RtItems,
    cgu: &'a CodegenUnit<'tcx>,
    /// VM functions in image order.
    vm: Vec<VmFn<'tcx>>,
    index: FxHashMap<Instance<'tcx>, u32>,
    /// Items added to the native CGU besides the original's native items.
    added: FxIndexMap<MonoItem<'tcx>, MonoItemData>,
    /// Stub instances whose neighbors haven't been walked yet.
    work: Vec<Instance<'tcx>>,
    /// The island instances, deduplicated.
    islands: FxHashSet<Instance<'tcx>>,
    /// Added items made External + Hidden only for the image.
    hidden_added: Vec<Instance<'tcx>>,
    stats: Stats,
}

/// Totals for `RYO_STATS`.
#[derive(Default)]
struct Stats {
    native_fns: usize,
    islands: usize,
}

impl<'a, 'tcx> Partitioner<'a, 'tcx> {
    fn new(tcx: TyCtxt<'tcx>, rt: RtItems, cgu: &'a CodegenUnit<'tcx>) -> Self {
        Partitioner {
            tcx,
            rt,
            cgu,
            vm: Vec::new(),
            index: FxHashMap::default(),
            added: FxIndexMap::default(),
            work: Vec::new(),
            islands: FxHashSet::default(),
            hidden_added: Vec::new(),
            stats: Stats::default(),
        }
    }

    fn vm_enabled(&self) -> bool {
        // Proc macros stay native: it keeps VM code out of rustc's own process, and they gain
        // nothing from it. `RYO_NO_VM` is a debugging switch (design/backend.md#pipeline, step 2).
        // A panic runtime (`panic_unwind`, `panic_abort`) too: portals re-raise a panic from
        // the VM through its `__rust_start_panic` (design/vm.md, Unwinding), so that must be
        // native, and the rest of the runtime gains nothing from the VM.
        std::env::var_os("RYO_NO_VM").is_none()
            && !self.tcx.crate_types().contains(&CrateType::ProcMacro)
            && !self.tcx.is_panic_runtime(LOCAL_CRATE)
    }

    fn run(mut self) -> (CodegenUnit<'tcx>, Results) {
        let tcx = self.tcx;
        let stats = stats_level();

        // Step 2/3: classify and lower. `ryo_rt` instances are always native (design/vm.md).
        let mut candidates: Vec<(Instance<'tcx>, MonoItemData)> = Vec::new();
        if self.vm_enabled() {
            for (item, data) in self.cgu.items() {
                if let MonoItem::Fn(instance) = *item
                    && instance.def_id().krate != self.rt.krate
                {
                    candidates.push((instance, *data));
                }
            }
        }
        // A stable image order: by symbol name.
        candidates.sort_by_cached_key(|(i, _)| tcx.symbol_name(*i).name.to_owned());
        let (mut ok, failed) = lower_all(tcx, &candidates);
        if stats >= 2 {
            for (instance, why) in &failed {
                eprintln!("ryo: native {}: {}", path(*instance), why.0);
            }
        }
        for (instance, data) in candidates {
            if let Some(lowered) = ok.remove(&instance) {
                self.index.insert(instance, self.vm.len() as u32);
                self.vm.push(VmFn { instance, data, lowered, portal: None });
            }
        }
        self.stats.native_fns = failed.len();

        // Step 1 (portals): VM functions that native code or the image may reach, and the
        // native items the image refers to by symbol.
        let entry = tcx.entry_fn(()).and_then(|(def_id, ty)| {
            let main = Instance::mono(tcx, def_id);
            self.index.contains_key(&main).then_some((main, ty))
        });
        let mut wanted = Vec::new();
        let mut image_refs: Vec<MonoItem<'tcx>> = Vec::new();
        let mut seen_allocs = FxHashSet::default();
        for v in &self.vm {
            if v.data.linkage != Linkage::Internal || entry.is_some_and(|(m, _)| m == v.instance) {
                wanted.push(v.instance);
            }
            for r in &v.lowered.relocs {
                match *r {
                    CodeReloc::Symbol { target, .. } => image_refs.push(MonoItem::Fn(target)),
                    CodeReloc::Static { def_id, .. } => image_refs.push(MonoItem::Static(def_id)),
                    CodeReloc::Const { alloc, .. } => alloc_refs(tcx, alloc, &mut seen_allocs, &mut image_refs),
                    CodeReloc::Data { alloc, .. } => alloc_refs(tcx, alloc, &mut seen_allocs, &mut image_refs),
                    CodeReloc::Call { .. } | CodeReloc::Site { .. } | CodeReloc::Bytes { .. } => {}
                    CodeReloc::TailCall { .. } => {}
                }
            }
        }
        for item in &image_refs {
            if let MonoItem::Fn(f) = *item {
                wanted.push(f);
            }
        }
        for f in wanted {
            self.need_portal(f);
        }
        self.scan_native_items();

        // Step 4: islands, the entry wrapper, the stub neighbors, and the native items the
        // image refers to.
        self.add_islands();
        let main_portal = entry.map(|(main, ty)| {
            self.add_c_main(main, ty);
            tcx.symbol_name(main).name.to_owned()
        });
        self.walk_stub_neighbors();
        let mut flips = FxHashSet::default();
        for item in image_refs {
            self.make_visible(item, &mut flips);
        }
        self.walk_stub_neighbors();

        // The native CGU: the original's native items, then the stubs and their neighbors.
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
            let is_vm = matches!(item, MonoItem::Fn(i) if self.index.contains_key(i));
            if !is_vm {
                let mut data = *data;
                if flips.contains(item) {
                    data.linkage = Linkage::External;
                    data.visibility = Visibility::Hidden;
                }
                items.insert(*item, data);
            }
        }
        for (item, data) in &self.added {
            items.insert(*item, *data);
        }
        native.compute_size_estimate();

        if stats >= 1 {
            for v in &self.vm {
                let portal = if v.portal.is_some() { " (portal)" } else { "" };
                let id = self.portal_id(self.index[&v.instance]);
                eprintln!("ryo: vm fn {}{portal} id={:08x}:{:08x}", path(v.instance), id >> 32, id as u32);
            }
            eprintln!(
                "ryo: {} VM functions, {} native functions, {} islands, {} native items",
                self.vm.len(),
                self.stats.native_fns,
                self.stats.islands,
                native.items().len()
            );
        }

        let (image, symbols, roots) = self.build_image();
        let portals = self.vm.iter().filter_map(|v| Some((v.portal?, v.instance))).collect();
        let mut hidden: Vec<Instance<'tcx>> = self
            .vm
            .iter()
            .filter(|v| v.data.linkage == Linkage::Internal)
            .filter_map(|v| v.portal)
            .collect();
        // Items made External + Hidden only for the image aren't exported
        // (design/backend.md#query-overrides).
        hidden.extend(flips.iter().filter_map(|item| match *item {
            MonoItem::Fn(i) => Some(i),
            MonoItem::Static(_) | MonoItem::GlobalAsm(_) => None,
        }));
        hidden.extend(self.hidden_added.iter().copied());
        let results = Results {
            cgu_name: native.name(),
            image,
            main_portal,
            symbols,
            lto_roots: roots.0.into_iter().collect(),
            portals: erase(portals),
            // SAFETY: as in `erase`.
            hidden_for_image: unsafe { std::mem::transmute::<Vec<Instance<'tcx>>, Vec<Instance<'static>>>(hidden) },
            key: session_key(tcx),
        };
        (native, results)
    }

    fn portal_id(&self, index: u32) -> u64 {
        portal_id(ryo_bytecode::image::crate_hash(local_stable_crate_id(self.tcx)), index)
    }

    /// Gives the VM function `instance` (if it is one) a portal.
    fn need_portal(&mut self, instance: Instance<'tcx>) {
        let Some(&i) = self.index.get(&instance) else { return };
        if self.vm[i as usize].portal.is_some() {
            return;
        }
        let tcx = self.tcx;
        let v = &self.vm[i as usize];
        let sig = lower::vm_fn_sig(tcx, instance).expect("VM functions have a supported signature");
        let id = ty::Const::from_bits(tcx, u128::from(self.portal_id(i)), TypingEnv::fully_monomorphized(), tcx.types.u64);
        let portal = if sig.caller_location {
            // `portal_tcN::<A0, …, R, ID>`: `#[track_caller]` itself, so it has the same ABI,
            // including the trailing location, which it passes on (design/stubs.md).
            let n = sig.inputs.len() - 1;
            let mut args: Vec<ty::GenericArg<'tcx>> = sig.inputs[..n].iter().map(|&t| t.into()).collect();
            args.extend::<[ty::GenericArg<'tcx>; 2]>([sig.output.ty.into(), id.into()]);
            Instance::new_raw(self.rt.portal_tc[n], tcx.mk_args(&args))
        } else {
            let args = tcx.mk_args(&[sig.args_tuple(tcx).into(), sig.output.ty.into(), id.into()]);
            Instance::new_raw(self.rt.portal, args)
        };
        // The image references the portal (function table, `__ryo_main`), and the image is a
        // separate object, so an internal portal becomes hidden (design/backend.md, Linkage).
        let mut data = v.data;
        data.inlined = false;
        data.size_estimate = MonoItem::Fn(portal).size_estimate(tcx);
        if data.linkage == Linkage::Internal {
            data.linkage = Linkage::External;
            data.visibility = Visibility::Hidden;
        }
        self.vm[i as usize].portal = Some(portal);
        self.added.insert(MonoItem::Fn(portal), data);
        self.work.push(portal);
    }

    /// Marks VM functions referenced by the original CGU's native items: functions (their
    /// neighbors, which include vtable methods) and static initializers.
    fn scan_native_items(&mut self) {
        let tcx = self.tcx;
        let mut refs = Vec::new();
        for (item, _) in self.cgu.items() {
            match *item {
                MonoItem::Fn(i) if self.index.contains_key(&i) => {}
                MonoItem::Fn(i) => {
                    for n in neighbors(tcx, i) {
                        if let MonoItem::Fn(f) = n {
                            refs.push(f);
                        }
                    }
                }
                MonoItem::Static(def_id) => {
                    if let Ok(alloc) = tcx.eval_static_initializer(def_id) {
                        let mut seen = FxHashSet::default();
                        for prov in alloc.inner().provenance().ptrs().values() {
                            alloc_fns(tcx, prov.alloc_id(), &mut seen, &mut refs);
                        }
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
            self.need_portal(f);
        }
    }

    /// The C `main` wrapper for a VM `main` (design/stubs.md#program-entry-main).
    fn add_c_main(&mut self, main: Instance<'tcx>, entry_ty: EntryFnType) {
        let tcx = self.tcx;
        let typing_env = TypingEnv::fully_monomorphized();
        let sig = tcx.fn_sig(main.def_id()).instantiate_identity().skip_norm_wip();
        let main_ret = tcx.normalize_erasing_late_bound_regions(typing_env, sig).output();
        let EntryFnType::Main { sigpipe } = entry_ty;
        let start_def = tcx.require_lang_item(rustc_hir::attrs::lang_items::LangItem::Start, rustc_span::DUMMY_SP);
        let start_args = tcx.mk_args(&[main_ret.into()]);
        let start = Instance::expect_resolve(tcx, typing_env, start_def, start_args, rustc_span::DUMMY_SP);
        let start_ty = Ty::new_fn_def(tcx, start.def_id(), ty::Binder::dummy(start.args));
        let args = tcx.mk_args(&[
            start_ty.into(),
            main_ret.into(),
            ty::Const::from_bits(tcx, u128::from(sigpipe), typing_env, tcx.types.u8).into(),
        ]);
        let c_main = Instance::new_raw(self.rt.c_main, args);
        let data = MonoItemData {
            inlined: false,
            linkage: Linkage::External,
            visibility: Visibility::Default,
            size_estimate: MonoItem::Fn(c_main).size_estimate(tcx),
        };
        self.added.insert(MonoItem::Fn(c_main), data);
        self.work.push(c_main);
    }

    /// Adds whatever the stub instances use that the collector never saw, recursively
    /// (design/backend.md#pipeline step 4, Stub neighbors). `items_of_instance` already applies
    /// `should_codegen_locally`, so upstream copies (share-generics) are linked to, not
    /// defined. Neighbors are internal: only the stubs reference them.
    fn walk_stub_neighbors(&mut self) {
        let tcx = self.tcx;
        while let Some(instance) = self.work.pop() {
            for n in neighbors(tcx, instance) {
                if let MonoItem::Fn(f) = n
                    && self.index.contains_key(&f)
                {
                    self.need_portal(f);
                    continue;
                }
                if self.cgu.items().contains_key(&n) || self.added.contains_key(&n) {
                    continue;
                }
                let data = MonoItemData {
                    inlined: false,
                    linkage: Linkage::Internal,
                    visibility: Visibility::Default,
                    size_estimate: n.size_estimate(tcx),
                };
                self.added.insert(n, data);
                if let MonoItem::Fn(f) = n {
                    self.work.push(f);
                }
            }
        }
    }

    /// Instantiates the island templates the VM functions request (design/stubs.md):
    /// deduplicated, linked to an upstream copy where one is exported, otherwise added to the
    /// native CGU, visible to the image.
    fn add_islands(&mut self) {
        let tcx = self.tcx;
        let templates = &tcx.diagnostic_items(self.rt.krate).name_to_id;
        let mut new = Vec::new();
        for v in &self.vm {
            for r in &v.lowered.islands {
                let Some(&def_id) = templates.get(&r.template) else {
                    tcx.dcx().fatal(format!("ryo_rt has no island template `{}`; rebuild with `./y.sh build`", r.template))
                };
                new.push(Instance::new_raw(def_id, r.args));
            }
        }
        for island in new {
            let item = MonoItem::Fn(island);
            if self.added.contains_key(&item) || self.cgu.items().contains_key(&item) || !self.islands.insert(island) {
                continue;
            }
            self.stats.islands += 1;
            // Upstream copies, and non-generic templates, which `ryo_rt` itself defines.
            if island.upstream_monomorphization(tcx).is_some() || !tcx.should_codegen_locally(island) {
                continue;
            }
            let data = MonoItemData {
                inlined: false,
                linkage: Linkage::External,
                visibility: Visibility::Hidden,
                size_estimate: item.size_estimate(tcx),
            };
            self.added.insert(item, data);
            self.hidden_added.push(island);
            self.work.push(island);
        }
    }

    /// Makes a native item the image refers to by symbol linkable from the image's object: an
    /// internal item becomes External + Hidden (design/backend.md, Linkage). Items that aren't
    /// in the CGU yet but are codegened locally are added.
    fn make_visible(&mut self, item: MonoItem<'tcx>, flips: &mut FxHashSet<MonoItem<'tcx>>) {
        let tcx = self.tcx;
        if let MonoItem::Fn(f) = item
            && self.index.contains_key(&f)
        {
            return; // a VM function: its portal
        }
        if let MonoItem::Fn(f) = item
            && lower::is_tls_shim(f)
            && !super::is_pe(tcx)
            && !self.cgu.items().contains_key(&item)
            && !self.added.contains_key(&item)
        {
            // rustc only creates `ThreadLocal` shims where the target doesn't export TLS
            // (`needs_thread_local_shim`), so on ELF the backend adds its own, also for
            // upstream statics. The same static always gives the same body, so copies from
            // several crates merge (design/backend.md, Linkage).
            let data = MonoItemData {
                inlined: false,
                linkage: Linkage::WeakODR,
                visibility: Visibility::Hidden,
                size_estimate: item.size_estimate(tcx),
            };
            self.added.insert(item, data);
            self.hidden_added.push(f);
            self.work.push(f);
            return;
        }
        if let Some(data) = self.cgu.items().get(&item) {
            if data.linkage == Linkage::Internal {
                flips.insert(item);
            }
            return;
        }
        if let Some(data) = self.added.get_mut(&item) {
            if data.linkage == Linkage::Internal {
                data.linkage = Linkage::External;
                data.visibility = Visibility::Hidden;
                if let MonoItem::Fn(f) = item {
                    self.hidden_added.push(f);
                }
            }
            return;
        }
        if let MonoItem::Fn(f) = item
            && tcx.should_codegen_locally(f)
        {
            let data = MonoItemData {
                inlined: false,
                linkage: Linkage::External,
                visibility: Visibility::Hidden,
                size_estimate: item.size_estimate(tcx),
            };
            self.added.insert(item, data);
            self.hidden_added.push(f);
            self.work.push(f);
        }
    }

    /// The merge pass: resolves every function's relocations, then lays out the image.
    fn build_image(&mut self) -> (ImageObject, Vec<String>, Roots) {
        let tcx = self.tcx;
        let mut w = ImageWriter::new(local_stable_crate_id(tcx));
        let symbols: Vec<String> = self.vm.iter().map(|v| tcx.symbol_name(v.instance).name.to_owned()).collect();
        let call_f = lower::operand_offset(Opcode::Call, 1);
        let call_fs = lower::operand_offset(Opcode::Call, 2);
        let tail_f = lower::operand_offset(Opcode::TailCall, 0);
        let tail_fs = lower::operand_offset(Opcode::TailCall, 1);
        let templates = &tcx.diagnostic_items(self.rt.krate).name_to_id;
        let mut pool = Pool::default();
        for (i, v) in self.vm.iter().enumerate() {
            let l = &v.lowered;
            let mut code = l.code.clone();
            for r in &l.relocs {
                match *r {
                    CodeReloc::Call { at, callee } => {
                        let c = self.index[&callee];
                        code[at as usize + call_f] = c;
                        code[at as usize + call_fs] = self.vm[c as usize].lowered.frame_size;
                    }
                    CodeReloc::TailCall { at, callee } => {
                        let c = self.index[&callee];
                        code[at as usize + tail_f] = c;
                        code[at as usize + tail_fs] = self.vm[c as usize].lowered.frame_size;
                    }
                    CodeReloc::Symbol { at, target } => {
                        pool.roots.function(tcx, target);
                        let flags = super::symbol_flags(tcx, target, super::SymRole::Target);
                        let Sym(s) = w.symbol(tcx.symbol_name(target).name, flags);
                        code[at as usize] = s;
                        if set_indirect(&mut code, at, flags) {
                            // A direct reference too, so the linker extracts the archive member
                            // defining a statically linked function: `__imp_<sym>` is only
                            // synthesized for symbols that are already defined
                            // (design/platforms.md). Functions in DLLs resolve to their thunk.
                            w.symbol(tcx.symbol_name(target).name, 0);
                        }
                    }
                    CodeReloc::Static { at, def_id } => {
                        pool.roots.static_(tcx, def_id);
                        let flags = super::static_symbol_flags(tcx, def_id);
                        let Sym(s) = w.symbol(static_symbol(tcx, def_id).name, flags);
                        code[at as usize] = s;
                        if set_indirect(&mut code, at, flags) && super::static_needs_direct_slot(tcx, def_id) {
                            // As for functions: lld synthesizes `__imp_<sym>` only for a
                            // defined symbol, and a C static library has no `__imp_` of its own
                            // (design/platforms.md).
                            w.symbol(static_symbol(tcx, def_id).name, 0);
                        }
                    }
                    CodeReloc::Site { at } => code[at as usize] = w.site().0,
                    CodeReloc::Const { at, alloc, offset } => {
                        code[at as usize] = pool.intern(tcx, &mut w, alloc).0 + offset;
                    }
                    CodeReloc::Bytes { at, ref bytes, align } => {
                        code[at as usize] = pool.bytes(&mut w, bytes, align).0;
                    }
                    CodeReloc::Data { at, alloc, offset } => {
                        code[at as usize] = pool.data(tcx, &mut w, alloc).0 + offset;
                    }
                }
            }
            for r in &l.islands {
                let island = Instance::new_raw(templates[&r.template], r.args);
                pool.roots.function(tcx, island);
                let flags = super::symbol_flags(tcx, island, super::SymRole::Island);
                let Sym(s) = w.symbol(tcx.symbol_name(island).name, flags);
                code[r.at as usize] = s;
            }
            let portal = v.portal.map(|_| {
                pool.roots.text(&symbols[i]);
                w.symbol(&symbols[i], 0)
            });
            w.add_function(FunctionDef {
                code,
                frame_size: l.frame_size,
                max_outgoing: l.max_outgoing,
                arg_size: l.arg_size,
                ret_size: l.ret_size,
                cleanup: l.cleanup.clone(),
                portal,
            });
        }
        match w.finish() {
            Ok(image) => (image, symbols, pool.roots),
            Err(e) => tcx.dcx().fatal(format!("ryo: invalid image: {e:?}")),
        }
    }
}

/// `instance` for stats output: untrimmed paths, since trimming needs a diagnostic.
fn path(instance: Instance<'_>) -> String {
    rustc_middle::ty::print::with_no_trimmed_paths!(instance.to_string())
}

/// The items `instance` uses (`items_of_instance`, used items).
fn neighbors<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> Vec<MonoItem<'tcx>> {
    match tcx.items_of_instance((instance, CollectionMode::UsedItems)) {
        Ok((used, _)) => used.iter().map(|s| s.node).collect(),
        Err(e) => tcx.dcx().fatal(format!("collecting the items used by {instance}: {e:?}")),
    }
}

/// The functions an allocation points at, through nested allocations and vtables (like the
/// collector's `collect_alloc`, `rustc_monomorphize/src/collector.rs:1285`).
fn alloc_fns<'tcx>(tcx: TyCtxt<'tcx>, id: AllocId, seen: &mut FxHashSet<AllocId>, out: &mut Vec<Instance<'tcx>>) {
    if !seen.insert(id) {
        return;
    }
    match tcx.global_alloc(id) {
        GlobalAlloc::Function { instance } => out.push(instance),
        GlobalAlloc::Memory(alloc) => {
            for prov in alloc.inner().provenance().ptrs().values() {
                alloc_fns(tcx, prov.alloc_id(), seen, out);
            }
        }
        GlobalAlloc::VTable(ty, dyn_ty) => {
            let principal = dyn_ty.principal().map(|p| tcx.instantiate_bound_regions_with_erased(p));
            alloc_fns(tcx, tcx.vtable_allocation((ty, principal)), seen, out);
        }
        // Statics are native items of their own; type ids hold no pointers.
        GlobalAlloc::Static(_) | GlobalAlloc::TypeId { .. } => {}
    }
}

/// Lowers the candidates (in parallel) until the set of VM functions is stable: a function
/// that calls a candidate which turned out native is lowered again, with an island for that
/// call. Returns the lowered functions and the reasons the others stay native.
fn lower_all<'tcx>(
    tcx: TyCtxt<'tcx>,
    candidates: &[(Instance<'tcx>, MonoItemData)],
) -> (FxHashMap<Instance<'tcx>, LoweredFn<'tcx>>, Vec<(Instance<'tcx>, NeedsNative)>) {
    let mut vm: FxHashSet<Instance<'tcx>> = candidates.iter().map(|c| c.0).collect();
    let mut ok: FxHashMap<Instance<'tcx>, LoweredFn<'tcx>> = FxHashMap::default();
    let mut failed = Vec::new();
    let mut todo: Vec<Instance<'tcx>> = candidates.iter().map(|c| c.0).collect();
    while !todo.is_empty() {
        let cx = LowerCx { vm: &vm };
        let out: Vec<_> =
            rustc_data_structures::sync::par_map(todo, |instance| (instance, lower::lower(tcx, &cx, instance)));
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
            .filter(|(_, l)| l.relocs.iter().any(|r| matches!(r, CodeReloc::Call { callee, .. } | CodeReloc::TailCall { callee, .. } if !vm.contains(callee))))
            .map(|(i, _)| *i)
            .collect();
        todo.sort_by_cached_key(|i| tcx.symbol_name(*i).name.to_owned());
    }
    failed.sort_by_cached_key(|(i, _)| tcx.symbol_name(*i).name.to_owned());
    (ok, failed)
}

/// Switches the instruction whose `sym` operand is word `at` to its `.ind` form if the slot is
/// indirect (PE imports, design/platforms.md). The lowering emits `addr.sym` and `call.ext`,
/// whose `sym` is operand word 2 in both.
/// Returns whether it did.
fn set_indirect(code: &mut [u32], at: u32, flags: u8) -> bool {
    if flags & ryo_bytecode::image::SYM_INDIRECT == 0 {
        return false;
    }
    let start = at as usize - 2;
    let ind = match Opcode::from_u16(code[start] as u16) {
        Some(Opcode::AddrSym) => Opcode::AddrSymInd,
        Some(Opcode::CallExt) => Opcode::CallExtInd,
        op => panic!("ryo: indirect symbol operand of {op:?}"),
    };
    code[start] = ind as u32;
    true
}

/// The symbol of a static (its own, or the foreign item's link name).
fn static_symbol<'tcx>(tcx: TyCtxt<'tcx>, def_id: DefId) -> ty::SymbolName<'tcx> {
    tcx.symbol_name(Instance::mono(tcx, def_id))
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
                    GlobalAlloc::Static(def_id) => {
                        (static_symbol(tcx, def_id).name, super::static_needs_direct_slot(tcx, def_id))
                    }
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
        self.0.entry(name.to_owned()).or_insert(SymbolExportKind::Text);
    }

    fn function<'tcx>(&mut self, tcx: TyCtxt<'tcx>, f: Instance<'tcx>) {
        self.text(tcx.symbol_name(f).name);
    }

    fn static_(&mut self, tcx: TyCtxt<'_>, def_id: DefId) {
        self.0.entry(static_symbol(tcx, def_id).name.to_owned()).or_insert(SymbolExportKind::Data);
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
    matches!(s, ExportedSymbol::NoDefId(_))
        && info.used
        && info.level == SymbolExportLevel::Rust
        && !info.rustc_std_internal_symbol
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
pub fn linked_roots(tcx: TyCtxt<'_>, crate_type: CrateType) -> (Vec<String>, Vec<String>) {
    let (mut linked, mut exported) = (Vec::new(), Vec::new());
    let Some(deps) = tcx.dependency_formats(()).get(&crate_type) else { return (linked, exported) };
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
                linked.push(name.name.to_owned());
                if exports_rust && !tcx.is_compiler_builtins(cnum) {
                    exported.push(name.name.to_owned());
                }
            }
        }
    }
    (linked, exported)
}

/// The items an allocation refers to by symbol (functions and statics), through nested
/// allocations and vtables.
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

pub fn local_stable_crate_id(tcx: TyCtxt<'_>) -> u64 {
    tcx.stable_crate_id(LOCAL_CRATE).as_u64()
}

/// Our `symbol_name` (design/backend.md#query-overrides): portals take their function's
/// symbol, `c_main` is the target's entry name, and local copies of `LocalCopy` instances get
/// a crate-unique suffix (design/backend.md, Linkage).
pub fn symbol_name<'tcx>(
    tcx: TyCtxt<'tcx>,
    instance: Instance<'tcx>,
    original: impl FnOnce() -> ty::SymbolName<'tcx>,
) -> ty::SymbolName<'tcx> {
    if let InstanceKind::Item(def_id) = instance.def
        && let Some(rt) = rt_items(tcx)
        && def_id.krate == rt.krate
    {
        if def_id == rt.portal || rt.portal_tc.contains(&def_id) {
            // `ID` is the last generic argument of every portal template.
            let id = instance.args.const_at(instance.args.len() - 1).to_leaf().to_u64();
            let (_, idx) = ryo_bytecode::image::split_portal_id(id);
            let r = results(tcx).expect("portal symbol requested before partitioning");
            return ty::SymbolName::new(tcx, &r.symbols[idx as usize]);
        }
        if def_id == rt.c_main {
            return ty::SymbolName::new(tcx, &tcx.sess.target.entry_name);
        }
    }
    let name = original();
    if !symbol_from_attrs(tcx, instance)
        && MonoItem::Fn(instance).instantiation_mode(tcx) == InstantiationMode::LocalCopy
        && instance.upstream_monomorphization(tcx).is_none()
    {
        return ty::SymbolName::new(tcx, &format!("{}.ryo{:016x}", name.name, local_stable_crate_id(tcx)));
    }
    name
}

/// Whether `instance`'s symbol is fixed by its attributes or is a foreign item's (an LLVM
/// intrinsic's, `#[no_mangle]`, `#[rustc_std_internal_symbol]`): it must not get the
/// crate-unique suffix.
fn symbol_from_attrs<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>) -> bool {
    rustc_symbol_mangling::symbol_name_from_attrs(tcx, instance.def).is_some()
}

/// Our local `exported_generic_symbols` (design/backend.md#query-overrides): portals are
/// listed as the generic functions they stand for (non-generic ones are already in
/// `exported_non_generic_symbols`), portals made hidden only for the image and `c_main` aren't
/// listed.
pub fn exported_generic_symbols<'tcx>(
    tcx: TyCtxt<'tcx>,
    list: &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)],
) -> &'tcx [(ExportedSymbol<'tcx>, SymbolExportInfo)] {
    let Some(rt) = rt_items(tcx) else { return list };
    let Some(r) = results(tcx) else { return list };
    let portals: FxHashMap<Instance<'tcx>, Instance<'tcx>> = r.portals(tcx).iter().copied().collect();
    let hidden: FxHashSet<Instance<'tcx>> = r.hidden_for_image(tcx).iter().copied().collect();
    let mut out: Vec<_> = list
        .iter()
        .filter_map(|&(s, info)| match s {
            ExportedSymbol::Generic(def_id, args) if def_id.krate == rt.krate => {
                let portal = Instance::new_raw(def_id, args);
                let orig = portals.get(&portal)?;
                if hidden.contains(&portal) || orig.args.non_erasable_generics().next().is_none() {
                    return None;
                }
                match orig.def {
                    InstanceKind::Item(d) => Some((ExportedSymbol::Generic(d, orig.args), info)),
                    _ => None,
                }
            }
            ExportedSymbol::Generic(def_id, args) if hidden.contains(&Instance::new_raw(def_id, args)) => None,
            _ => Some((s, info)),
        })
        .collect();
    out.sort_by_cached_key(|s| s.0.symbol_name_for_local_instance(tcx));
    tcx.arena.alloc_from_iter(out)
}
