//! Pipeline steps 1–4 (design/backend.md#pipeline), run inside our
//! `collect_and_partition_mono_items`: collect, classify, lower, build the native CGU. Also
//! builds the image (step 5's contents; `codegen_crate` writes it), and the `symbol_name` and
//! exported-symbols overrides that depend on these results.

use std::sync::OnceLock;

use rustc_data_structures::fx::{FxHashMap, FxHashSet, FxIndexMap};
use rustc_hir::attrs::Linkage;
use rustc_hir::def_id::{CrateNum, DefId, LOCAL_CRATE};
use rustc_middle::middle::exported_symbols::{ExportedSymbol, SymbolExportInfo};
use rustc_middle::mir::interpret::{AllocId, GlobalAlloc};
use rustc_middle::mono::{
    CodegenUnit, CollectionMode, InstantiationMode, MonoItem, MonoItemData, MonoItemPartitions, Visibility,
};
use rustc_middle::ty::{self, Instance, InstanceKind, Ty, TyCtxt, TypingEnv};
use rustc_session::config::{CrateType, EntryFnType};
use rustc_span::Symbol;
use ryo_bytecode::image::{FunctionDef, ImageObject, ImageWriter, portal_id};
use ryo_bytecode::insn::{Opcode, Sym};

use super::lower::{self, CodeReloc, LoweredFn};

/// The `RYO_RT_ABI` the backend was written against (`vm/rt/src/lib.rs`).
const EXPECTED_RT_ABI: u32 = 1;

/// The `ryo_rt` items the backend instantiates or checks (design/stubs.md, Lookup).
#[derive(Clone, Copy)]
pub struct RtItems {
    pub krate: CrateNum,
    pub portal: DefId,
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
            Some(RtItems { krate, portal: get("ryo_portal")?, c_main: get("ryo_c_main")?, abi: get("ryo_rt_abi")? })
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
    // The exported-symbols queries don't yet keep image-only native symbols from being
    // internalized (design/backend.md#query-overrides).
    if matches!(tcx.sess.lto(), rustc_session::config::Lto::Fat | rustc_session::config::Lto::Thin) {
        tcx.dcx().fatal("the ryo backend doesn't support `-Clto` yet");
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
        }
    }

    fn vm_enabled(&self) -> bool {
        // Proc macros stay native: it keeps VM code out of rustc's own process, and they gain
        // nothing from it. `RYO_NO_VM` is a debugging switch (design/backend.md#pipeline, step 2).
        std::env::var_os("RYO_NO_VM").is_none() && !self.tcx.crate_types().contains(&CrateType::ProcMacro)
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
        let lowered: Vec<_> = rustc_data_structures::sync::par_map(candidates, |(instance, data)| {
            (instance, data, lower::lower(tcx, instance))
        });
        let mut ok: Vec<(Instance<'tcx>, MonoItemData, LoweredFn<'tcx>)> = Vec::new();
        for (instance, data, r) in lowered {
            match r {
                Ok(l) => ok.push((instance, data, l)),
                Err(why) if stats >= 2 => eprintln!("ryo: native {}: {}", path(instance), why.0),
                Err(_) => {}
            }
        }
        // Calls to native code aren't islands yet: a function calling one is native too.
        loop {
            let set: FxHashSet<Instance<'tcx>> = ok.iter().map(|v| v.0).collect();
            let before = ok.len();
            ok.retain(|(instance, _, l)| {
                let keep = l.relocs.iter().all(|r| match r {
                    CodeReloc::Call { callee, .. } => set.contains(callee),
                    CodeReloc::Symbol { .. } => true,
                });
                if !keep && stats >= 2 {
                    eprintln!("ryo: native {}: calls a native function", path(*instance));
                }
                keep
            });
            if ok.len() == before {
                break;
            }
        }
        for (i, (instance, data, lowered)) in ok.into_iter().enumerate() {
            self.index.insert(instance, i as u32);
            self.vm.push(VmFn { instance, data, lowered, portal: None });
        }

        // Step 1 (portals): VM functions that native code or the image may reach.
        let entry = tcx.entry_fn(()).and_then(|(def_id, ty)| {
            let main = Instance::mono(tcx, def_id);
            self.index.contains_key(&main).then_some((main, ty))
        });
        let mut wanted = Vec::new();
        for v in &self.vm {
            if v.data.linkage != Linkage::Internal || entry.is_some_and(|(m, _)| m == v.instance) {
                wanted.push(v.instance);
            }
            for r in &v.lowered.relocs {
                if let CodeReloc::Symbol { target, .. } = r {
                    wanted.push(*target);
                }
            }
        }
        for f in wanted {
            self.need_portal(f);
        }
        self.scan_native_items();

        // Step 4: the entry wrapper and the stub neighbors.
        let main_portal = entry.map(|(main, ty)| {
            self.add_c_main(main, ty);
            tcx.symbol_name(main).name.to_owned()
        });
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
                items.insert(*item, *data);
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
            eprintln!("ryo: {} VM functions, {} native items", self.vm.len(), native.items().len());
        }

        let (image, symbols) = self.build_image();
        let portals = self.vm.iter().filter_map(|v| Some((v.portal?, v.instance))).collect();
        let hidden: Vec<Instance<'tcx>> = self
            .vm
            .iter()
            .filter(|v| v.data.linkage == Linkage::Internal)
            .filter_map(|v| v.portal)
            .collect();
        let results = Results {
            cgu_name: native.name(),
            image,
            main_portal,
            symbols,
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
        let sig = lower::rust_sig(tcx, instance).expect("VM functions have a supported signature");
        let id = self.portal_id(i);
        let args = tcx.mk_args(&[
            Ty::new_tup(tcx, &sig.inputs).into(),
            sig.output.into(),
            ty::Const::from_bits(tcx, u128::from(id), TypingEnv::fully_monomorphized(), tcx.types.u64).into(),
        ]);
        let portal = Instance::new_raw(self.rt.portal, args);
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

    /// The merge pass: resolves every function's relocations, then lays out the image.
    fn build_image(&mut self) -> (ImageObject, Vec<String>) {
        let tcx = self.tcx;
        let mut w = ImageWriter::new(local_stable_crate_id(tcx));
        let symbols: Vec<String> = self.vm.iter().map(|v| tcx.symbol_name(v.instance).name.to_owned()).collect();
        let call_f = lower::operand_offset(Opcode::Call, 1);
        let call_fs = lower::operand_offset(Opcode::Call, 2);
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
                    CodeReloc::Symbol { at, target } => {
                        let Sym(s) = w.symbol(tcx.symbol_name(target).name, super::symbol_flags(tcx, target));
                        code[at as usize] = s;
                    }
                }
            }
            assert!(l.islands.is_empty(), "island requests aren't supported yet");
            let portal = v.portal.map(|_| w.symbol(&symbols[i], 0));
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
            Ok(image) => (image, symbols),
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
        if def_id == rt.portal {
            let (_, idx) = ryo_bytecode::image::split_portal_id(instance.args.const_at(2).to_leaf().to_u64());
            let r = results(tcx).expect("portal symbol requested before partitioning");
            return ty::SymbolName::new(tcx, &r.symbols[idx as usize]);
        }
        if def_id == rt.c_main {
            return ty::SymbolName::new(tcx, &tcx.sess.target.entry_name);
        }
    }
    let name = original();
    if MonoItem::Fn(instance).instantiation_mode(tcx) == InstantiationMode::LocalCopy
        && instance.upstream_monomorphization(tcx).is_none()
    {
        return ty::SymbolName::new(tcx, &format!("{}.ryo{:016x}", name.name, local_stable_crate_id(tcx)));
    }
    name
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
    if !list.iter().any(|(s, _)| matches!(s, ExportedSymbol::Generic(d, _) if d.krate == rt.krate)) {
        return list;
    }
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
            _ => Some((s, info)),
        })
        .collect();
    out.sort_by_cached_key(|s| s.0.symbol_name_for_local_instance(tcx));
    tcx.arena.alloc_from_iter(out)
}
