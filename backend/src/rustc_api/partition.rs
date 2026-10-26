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
use rustc_middle::mono::{CodegenUnit, CollectionMode, InstantiationMode, MonoItem, MonoItemData, MonoItemPartitions, Visibility};
use rustc_middle::ty::{self, Instance, InstanceKind, Ty, TyCtxt, TypingEnv};
use rustc_session::config::{CrateType, EntryFnType};
use rustc_span::Symbol;
use ryo_bytecode::asm::{self, Ref};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};
use ryo_bytecode::image::{
    AllocFixup, AllocReloc, AllocTarget, CATCH, CONTINUE, FuncSymbol, FunctionDef, ImageObject, ImageWriter, SYM_INDIRECT, SymVisibility,
};

use crate::objfile;

use super::lower::{self, CodeReloc, LowerCx, LoweredFn, NeedsNative};

/// The `ryo_rt` items the backend instantiates or checks (design/stubs.md, Lookup).
#[derive(Clone, Copy)]
pub struct RtItems {
    pub krate: CrateNum,
    pub c_main: DefId,
    /// `ryo_rt::vm::FP_ARG`: whether its handlers take `fp` in `rdi`.
    pub fp_arg: DefId,
}

/// A value computed once per session and kept in a static (providers are plain fns). It is
/// keyed on the session's `GlobalCtxt` address, so a second session in the same process is a
/// fatal error instead of reading stale values.
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

    fn get_or_init(&self, tcx: TyCtxt<'_>, f: impl FnOnce() -> T) -> &T {
        Self::check(tcx, self.0.get_or_init(|| (Self::key(tcx), f())))
    }

    /// Fails if a value was already set.
    fn set(&self, tcx: TyCtxt<'_>, v: T) -> Result<(), ()> {
        self.0.set((Self::key(tcx), v)).map_err(|_| ())
    }

    fn get(&self, tcx: TyCtxt<'_>) -> Option<&T> {
        Some(Self::check(tcx, self.0.get()?))
    }
}

static RT_ITEMS: SessionCell<Option<RtItems>> = SessionCell::new();

/// `ryo_rt`'s crate and template items, found through its diagnostic items. `None` if
/// `ryo_rt` isn't loaded (rustc wasn't run through `rustc-ryo`).
pub fn rt_items(tcx: TyCtxt<'_>) -> Option<RtItems> {
    *RT_ITEMS.get_or_init(tcx, || {
        let krate = *tcx.crates(()).iter().find(|&&c| tcx.crate_name(c).as_str() == "ryo_rt")?;
        let items = tcx.diagnostic_items(krate);
        let get = |name: &str| items.name_to_id.get(&Symbol::intern(name)).copied();
        Some(RtItems { krate, c_main: get("ryo_c_main")?, fp_arg: get("ryo_rt_fp_arg")? })
    })
}

/// What the partition provider hands to the other providers and to `codegen_crate`. Set once:
/// the query is `eval_always` and computed once per session.
pub struct Results {
    /// The name of the single (native) CGU, which `codegen_unit(name)` looks up.
    pub cgu_name: Symbol,
    /// The image, ready to be written as an object.
    pub image: ImageObject,
    /// The symbol `__ryo_main` points at: the entry fn's, for a VM `main`.
    pub main_symbol: Option<String>,
    /// With `RYO_DUMP_LEAN`: each VM function's symbol and lowering certificate (JSON), in
    /// image order (`lower/cert.rs`).
    pub certs: Vec<(String, String)>,
    /// With `RYO_DUMP_LEAN`: the symbol of each island instance the image calls, and its
    /// template's diagnostic item name, sorted (for the certificate file).
    pub islands: Vec<(String, String)>,
    /// For `exported_non_generic_symbols`: the Rust symbols the image refers to ([`Roots`]).
    lto_roots: Vec<(String, SymbolExportKind)>,
    /// The interned data, lifetime-erased ([`Results::exports`]).
    exports: Exports<'static>,
}

/// The part of [`Results`] that holds this session's interned data.
struct Exports<'tcx> {
    /// For `exported_generic_symbols`: the VM functions with `External` linkage whose symbols
    /// the image defines, with their visibility.
    vm: Vec<(Instance<'tcx>, Visibility)>,
    /// Native items made `External` + `Hidden` only because the image references them.
    hidden_for_image: Vec<Instance<'tcx>>,
}

static RESULTS: SessionCell<Results> = SessionCell::new();

pub fn results(tcx: TyCtxt<'_>) -> Option<&'static Results> {
    RESULTS.get(tcx)
}

impl Results {
    fn new<'tcx>(
        cgu_name: Symbol,
        image: ImageObject,
        main_symbol: Option<String>,
        certs: Vec<(String, String)>,
        islands: Vec<(String, String)>,
        lto_roots: Vec<(String, SymbolExportKind)>,
        exports: Exports<'tcx>,
    ) -> Self {
        // SAFETY: only the lifetime parameter changes; `exports` restores it (see there).
        let exports = unsafe { std::mem::transmute::<Exports<'tcx>, Exports<'static>>(exports) };
        Results { cgu_name, image, main_symbol, certs, islands, lto_roots, exports }
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
    // `rustc-ryo` forces `-Ccodegen-units=1`; `Session::codegen_units`
    // (`rustc_session/src/session.rs:1058`) returns it.
    let n = tcx.sess.codegen_units().as_usize();
    if n != 1 {
        tcx.dcx().fatal(format!("the ryo backend requires `-Ccodegen-units=1`, but {n} codegen units were requested"));
    }
    // rustc only allows LTO of a dylib with `-Zdylib-lto`, which isn't tested with the image.
    if matches!(tcx.sess.lto(), rustc_session::config::Lto::Fat | rustc_session::config::Lto::Thin)
        && tcx.crate_types().iter().any(|t| matches!(t, CrateType::Dylib | CrateType::Sdylib))
    {
        tcx.dcx().fatal("the ryo backend doesn't support `-Clto` for dylibs");
    }
    if super::switches::get().marker {
        eprintln!("{}", super::PARTITION_MARKER);
    }
    let partitions = original(tcx, ());
    // With one CGU requested, merging always leaves exactly one, and partitioning never returns
    // none (`rustc_monomorphize/src/partitioning.rs:286-288`).
    let [cgu] = partitions.codegen_units else {
        tcx.dcx().fatal(format!("the ryo backend expected one codegen unit, got {}", partitions.codegen_units.len()));
    };
    let Some(rt) = rt_items(tcx) else { tcx.dcx().fatal("the ryo backend needs `ryo_rt` (`--extern force:ryo_rt`); run it through `rustc-ryo`") };

    let (native, results) = {
        let _t = tcx.prof.generic_activity("ryo_partition");
        Partitioner::new(tcx, rt, cgu).run()
    };
    if RESULTS.set(tcx, results).is_err() {
        tcx.dcx().fatal("collect_and_partition_mono_items ran twice in one process");
    }
    MonoItemPartitions {
        // `CodegenUnit` is arena-allocated (`rustc_middle/src/arena.rs:107`).
        codegen_units: tcx.arena.alloc_from_iter([native]),
        // Keeps every original DefId, VM functions included (design/backend.md#query-overrides).
        all_mono_items: partitions.all_mono_items,
    }
}

/// How the image's machine code is generated: as `ryo_rt`'s handlers expect `fp`, with a
/// frame pointer where the session needs one, with loop-head alignment unless
/// `RYO_ASM_ALIGN=0`, and for the target's object format.
pub fn asm_mode(tcx: TyCtxt<'_>, rt: RtItems) -> asm::Mode {
    let fp_arg = tcx.const_eval_poly(rt.fp_arg).ok().and_then(|v| v.try_to_scalar_int()).map(|i| i.to_u8() != 0);
    let Some(fp_arg) = fp_arg else { tcx.dcx().fatal("ryo_rt's FP_ARG isn't a bool") };
    let pe = tcx.sess.target.binary_format == rustc_target::spec::BinaryFormat::Coff;
    asm::Mode {
        fp_arg,
        // Handlers that read `rbp` and PE unwind info need it (`asm::Mode::frame_pointer`).
        frame_pointer: !fp_arg || pe || needs_frame_pointer(tcx.sess),
        align_loops: super::switches::get().asm_align,
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

/// The symbol of one of `ryo_rt`'s handlers or `ryo_probe_stack` (`#[rustc_std_internal_symbol]`s).
pub fn rt_symbol(tcx: TyCtxt<'_>, name: &str) -> String {
    rustc_symbol_mangling::mangle_internal_symbol(tcx, name)
}

/// A VM function: its lowering, and whether native code or the image calls it by name (then
/// the image defines its symbol globally, with its linkage; an internal one becomes hidden).
struct VmFn<'tcx> {
    instance: Instance<'tcx>,
    data: MonoItemData,
    lowered: LoweredFn<'tcx>,
    global: bool,
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
        !super::switches::get().no_vm && !self.tcx.crate_types().contains(&CrateType::ProcMacro) && !self.tcx.is_panic_runtime(LOCAL_CRATE)
    }

    fn run(mut self) -> (CodegenUnit<'tcx>, Results) {
        let tcx = self.tcx;
        let stats = super::switches::get().stats;

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
        candidates.sort_by_cached_key(|(i, _)| tcx.symbol_name(*i).name);
        let (mut ok, failed) = {
            let _t = tcx.prof.generic_activity("ryo_lower");
            lower_all(tcx, &candidates, asm_mode(tcx, self.rt))
        };
        if stats >= 2 {
            for (instance, why) in &failed {
                eprintln!("ryo: native {}: {}", path(*instance), why.0);
            }
        }
        for (instance, data) in candidates {
            if let Some(lowered) = ok.remove(&instance) {
                self.index.insert(instance, self.vm.len() as u32);
                self.vm.push(VmFn { instance, data, lowered, global: false });
            }
        }
        self.stats.native_fns = failed.len();

        // Step 1 (symbols): VM functions that native code or the image may reach by name, and
        // the native items the image refers to by symbol.
        let stubs_t = tcx.prof.generic_activity("ryo_stubs");
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
                    CodeReloc::Call { .. } | CodeReloc::Bytes { .. } | CodeReloc::Island { .. } => {}
                }
            }
        }
        for item in &image_refs {
            if let MonoItem::Fn(f) = *item {
                wanted.push(f);
            }
        }
        for f in wanted {
            self.need_symbol(f);
        }
        self.scan_native_items();

        // Step 4: islands, the entry wrapper, the stub neighbors, and the native items the
        // image refers to.
        self.add_islands();
        let main_symbol = entry.map(|(main, ty)| {
            self.add_c_main(main, ty);
            tcx.symbol_name(main).name.to_owned()
        });
        self.walk_stub_neighbors();
        let mut flips = FxHashMap::default();
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
                if let Some(&(linkage, visibility)) = flips.get(item) {
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
        drop(stubs_t);

        if stats >= 1 {
            for v in &self.vm {
                let global = if v.global { " (global)" } else { "" };
                eprintln!("ryo: vm fn {}{global}", path(v.instance));
            }
            eprintln!(
                "ryo: {} VM functions, {} native functions, {} islands, {} native items",
                self.vm.len(),
                self.stats.native_fns,
                self.stats.islands,
                native.items().len()
            );
            self.print_coverage(&failed);
        }

        let certs: Vec<(String, String)> =
            self.vm.iter().filter_map(|v| Some((tcx.symbol_name(v.instance).name.to_owned(), v.lowered.cert.clone()?))).collect();
        let islands = if certs.is_empty() { Vec::new() } else { self.island_names() };
        let (image, roots) = self.build_image();
        let vm_exports: Vec<(Instance<'tcx>, Visibility)> =
            self.vm.iter().filter(|v| v.global && v.data.linkage == Linkage::External).map(|v| (v.instance, v.data.visibility)).collect();
        // Items made External + Hidden only for the image aren't exported
        // (design/backend.md#query-overrides).
        let mut hidden: Vec<Instance<'tcx>> = Vec::new();
        hidden.extend(flips.iter().filter_map(|(item, &(linkage, _))| match *item {
            MonoItem::Fn(i) if linkage == Linkage::External => Some(i),
            _ => None,
        }));
        hidden.extend(self.hidden_added.iter().copied());
        let results = Results::new(
            native.name(),
            image,
            main_symbol,
            certs,
            islands,
            roots.0.into_iter().collect(),
            Exports { vm: vm_exports, hidden_for_image: hidden },
        );
        (native, results)
    }

    /// The coverage summary of `RYO_STATS` (design/backend.md#debugging-switches): island
    /// instructions per function and by template, and the native functions by reason.
    fn print_coverage(&self, failed: &[(Instance<'tcx>, NeedsNative)]) {
        let mut by_template: FxIndexMap<Symbol, (usize, usize)> = FxIndexMap::default();
        let mut with_islands = 0;
        let mut total = 0;
        for v in &self.vm {
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
        let per_fn = if self.vm.is_empty() { 0.0 } else { total as f64 / self.vm.len() as f64 };
        eprintln!("ryo: {total} island instructions in {with_islands} of {} VM functions ({per_fn:.2} per function)", self.vm.len());
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

    /// The `RYO_DUMP` text: each VM function, by path, decoded back to VM instructions, its
    /// operands that name relocations (`fn`, `sym`, `site`, `k`, `data`) listed below it.
    fn dump(&self, mode: asm::Mode) -> String {
        use std::fmt::Write;
        let tcx = self.tcx;
        let mut fns: Vec<(String, &VmFn<'tcx>)> = self.vm.iter().map(|v| (path(v.instance), v)).collect();
        fns.sort_by(|a, b| a.0.cmp(&b.0));
        let mut out = String::new();
        for (name, v) in fns {
            let l = &v.lowered;
            let c = &l.code;
            let flags = super::func_flags_suffix(super::func_flags(tcx, v.instance));
            writeln!(out, "fn {name} (frame {}, args {}, ret {}){flags}", l.frame_size, l.arg_size, l.ret_size).unwrap();
            match asm::decode(&c.code, &c.relocs, &c.rodata, &c.call_sites, &c.dropped, &c.scopes, mode) {
                Ok(d) => dump_labeled(&mut out, &d.words, &d.cleanup, &d.scopes),
                Err(e) => writeln!(out, "  undecodable: {e:?}").unwrap(),
            }
            for (i, r) in l.relocs.iter().enumerate() {
                let what = match *r {
                    CodeReloc::Call { callee } => format!("fn{i} = {}", path(callee)),
                    CodeReloc::Symbol { target } => format!("sym{i} = {}", path(target)),
                    CodeReloc::Static { def_id } => {
                        format!("sym{i} = static {}", rustc_middle::ty::print::with_no_trimmed_paths!(tcx.def_path_str(def_id)))
                    }
                    CodeReloc::Const { offset, .. } => format!("k{i} = const allocation + {offset}"),
                    CodeReloc::Bytes { ref bytes, align } => format!("k{i} = bytes {bytes:02x?} align {align}"),
                    CodeReloc::Data { offset, .. } => format!("data{i} = allocation + {offset}"),
                    CodeReloc::Island { template, args } => format!("sym{i} = island {template}{args:?}"),
                };
                writeln!(out, "  {what}").unwrap();
            }
            out.push('\n');
        }
        out
    }

    /// The `RYO_DUMP_CODE` text, for `y bench codegen` to disassemble: each VM function, by
    /// path, as `fn <path>`, then `code <hex>` and one `reloc <offset> <target>` per relocated
    /// field, the targets named as the `RYO_DUMP` operands are. The merge appends the image's
    /// names (`build_image`): `image <index> <path>` per function, and `ref <index> <global>
    /// <local>` per reference of its code, the image's name (`fn12`, `k96`) then the
    /// function's (`fn0`, `k1`), with which the JIT's code (`RYO_JIT_DUMP`) is printed.
    fn dump_code(&self) -> String {
        use std::fmt::Write;
        let mut fns: Vec<(String, &VmFn<'tcx>)> = self.vm.iter().map(|v| (path(v.instance), v)).collect();
        fns.sort_by(|a, b| a.0.cmp(&b.0));
        let mut out = String::new();
        for (name, v) in fns {
            let c = &v.lowered.code;
            let flags = super::func_flags_suffix(super::func_flags(self.tcx, v.instance));
            writeln!(out, "fn {name}{flags}").unwrap();
            out.push_str("code ");
            for b in &c.code {
                write!(out, "{b:02x}").unwrap();
            }
            out.push('\n');
            for r in &c.relocs {
                let to = match r.to {
                    Ref::Handler(op) => format!("ryo_h_{op:?}"),
                    Ref::RegHandler(op) => format!("ryo_hr_{op:?}"),
                    Ref::Probe => "ryo_probe_stack".to_owned(),
                    Ref::Func(x) => x.to_string(),
                    Ref::Sym(x) => x.to_string(),
                    Ref::Site(x) => x.to_string(),
                    Ref::Const(x) => x.to_string(),
                    Ref::Data(x) => x.to_string(),
                    Ref::Ro(off) => format!("ro+{off}"),
                    Ref::Rec => "jit_record".to_owned(),
                    Ref::RecLoopCtr => "jit_record.ctr_l".to_owned(),
                };
                writeln!(out, "reloc {} {to}", r.at).unwrap();
            }
        }
        out
    }

    /// Gives the VM function `instance` (if it is one) a global symbol: native code or the
    /// image calls it by name.
    fn need_symbol(&mut self, instance: Instance<'tcx>) {
        if let Some(&i) = self.index.get(&instance) {
            self.vm[i as usize].global = true;
        }
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
            self.need_symbol(f);
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
        let args = tcx.mk_args(&[start_ty.into(), main_ret.into(), ty::Const::from_bits(tcx, u128::from(sigpipe), typing_env, tcx.types.u8).into()]);
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
                    self.need_symbol(f);
                    continue;
                }
                if self.cgu.items().contains_key(&n) || self.added.contains_key(&n) {
                    continue;
                }
                let data =
                    MonoItemData { inlined: false, linkage: Linkage::Internal, visibility: Visibility::Default, size_estimate: n.size_estimate(tcx) };
                self.added.insert(n, data);
                if let MonoItem::Fn(f) = n {
                    self.work.push(f);
                }
            }
        }
    }

    /// Each island instance the image calls: its symbol and its template's name.
    fn island_names(&self) -> Vec<(String, String)> {
        let tcx = self.tcx;
        let mut out: Vec<(String, String)> = Vec::new();
        for v in &self.vm {
            for r in &v.lowered.relocs {
                let CodeReloc::Island { template, args } = *r else { continue };
                let island = island_instance(tcx, self.rt.krate, template, args);
                out.push((tcx.symbol_name(island).name.to_owned(), template.to_string()));
            }
        }
        out.sort();
        out.dedup();
        out
    }

    /// Instantiates the island templates the VM functions request (design/stubs.md):
    /// deduplicated, linked to an upstream copy where one is exported, otherwise added to the
    /// native CGU, visible to the image.
    fn add_islands(&mut self) {
        let tcx = self.tcx;
        let mut new = Vec::new();
        for v in &self.vm {
            for r in &v.lowered.relocs {
                let CodeReloc::Island { template, args } = *r else { continue };
                new.push(island_instance(tcx, self.rt.krate, template, args));
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
            let data =
                MonoItemData { inlined: false, linkage: Linkage::External, visibility: Visibility::Hidden, size_estimate: item.size_estimate(tcx) };
            self.added.insert(item, data);
            self.hidden_added.push(island);
            self.work.push(island);
        }
    }

    /// Makes a native item the image refers to by symbol linkable from the image's object: an
    /// internal item becomes External + Hidden, and a linkonce one (`#[linkage]`), which LLVM
    /// drops when no native code uses it, its weak form (design/backend.md, Linkage). `flips`
    /// gets the changed CGU items' new linkage and visibility. Items that aren't in the CGU yet
    /// but are codegened locally are added.
    fn make_visible(&mut self, item: MonoItem<'tcx>, flips: &mut FxHashMap<MonoItem<'tcx>, (Linkage, Visibility)>) {
        let tcx = self.tcx;
        if let MonoItem::Fn(f) = item
            && self.index.contains_key(&f)
        {
            return; // a VM function: its global symbol
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
            let data =
                MonoItemData { inlined: false, linkage: Linkage::WeakODR, visibility: Visibility::Hidden, size_estimate: item.size_estimate(tcx) };
            self.added.insert(item, data);
            self.hidden_added.push(f);
            self.work.push(f);
            return;
        }
        if let Some(data) = self.cgu.items().get(&item) {
            let flip = match data.linkage {
                Linkage::Internal => Some((Linkage::External, Visibility::Hidden)),
                Linkage::LinkOnceAny => Some((Linkage::WeakAny, data.visibility)),
                Linkage::LinkOnceODR => Some((Linkage::WeakODR, data.visibility)),
                _ => None,
            };
            if let Some(flip) = flip {
                flips.insert(item, flip);
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
            let data =
                MonoItemData { inlined: false, linkage: Linkage::External, visibility: Visibility::Hidden, size_estimate: item.size_estimate(tcx) };
            self.added.insert(item, data);
            self.hidden_added.push(f);
            self.work.push(f);
        }
    }

    /// The merge pass: resolves every function's relocations, then lays out the image.
    fn build_image(&mut self) -> (ImageObject, Roots) {
        let tcx = self.tcx;
        let mut w = ImageWriter::new(local_stable_crate_id(tcx));
        let rt_krate = self.rt.krate;
        let mut pool = Pool::default();
        let mode = asm_mode(tcx, self.rt);
        w.prepare(mode);
        if tcx.sess.target.binary_format == rustc_target::spec::BinaryFormat::MachO {
            // As LLVM writes `__eh_frame` (design/platforms.md).
            w.set_eh_pointers(ryo_bytecode::image::EhPointers::Abs8);
        }
        let mut encoded = Vec::with_capacity(self.vm.len());
        // The handlers the code calls, and whether it probes the stack.
        let mut handlers = vec![false; ryo_bytecode::full::ALL_OPCODES.len()];
        let mut probe = false;
        if let Some(path) = &super::switches::get().dump {
            let text = self.dump(mode);
            std::fs::write(&path, text).unwrap_or_else(|e| tcx.dcx().fatal(format!("ryo: RYO_DUMP: {e}")));
        }
        let dump_code = super::switches::get().dump_code.as_deref();
        if let Some(path) = &dump_code {
            let text = self.dump_code();
            std::fs::write(path, text).unwrap_or_else(|e| tcx.dcx().fatal(format!("ryo: RYO_DUMP_CODE: {e}")));
        }
        // `RYO_DUMP_CODE`'s names of the image's functions and references, for the JIT's code
        // (`dump_code`).
        let mut names = String::new();
        let merge_t = tcx.prof.generic_activity("ryo_merge");
        for (i, v) in self.vm.iter_mut().enumerate() {
            let l = &mut v.lowered;
            // Each reference's value.
            let vals: Vec<u32> = l
                .relocs
                .iter()
                .map(|r| match *r {
                    CodeReloc::Call { callee } => self.index[&callee],
                    CodeReloc::Symbol { target } => {
                        pool.roots.function(tcx, target);
                        let flags = super::symbol_flags(tcx, target, super::SymRole::Target);
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
                        let flags = super::static_symbol_flags(tcx, def_id);
                        let Sym(s) = w.symbol(static_symbol(tcx, def_id).name, flags);
                        if flags & ryo_bytecode::image::SYM_INDIRECT != 0 && super::static_needs_direct_slot(tcx, def_id) {
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
                        let flags = super::symbol_flags(tcx, island, super::SymRole::Island);
                        w.symbol(tcx.symbol_name(island).name, flags).0
                    }
                })
                .collect();
            let mut code = std::mem::take(&mut l.code);
            if dump_code.is_some() {
                use std::fmt::Write;
                writeln!(names, "image {i} {}", path(v.instance)).unwrap();
                let v = |i: u32| vals[i as usize];
                for r in &code.relocs {
                    let _ = match r.to {
                        Ref::Func(Func(k)) => writeln!(names, "ref {i} {} {}", Func(v(k)), Func(k)),
                        Ref::Sym(Sym(k)) => writeln!(names, "ref {i} {} {}", Sym(v(k)), Sym(k)),
                        Ref::Site(Site(k)) => writeln!(names, "ref {i} {} {}", Site(v(k)), Site(k)),
                        Ref::Const(Const(k)) => writeln!(names, "ref {i} {} {}", Const(v(k)), Const(k)),
                        Ref::Data(Data(k)) => writeln!(names, "ref {i} {} {}", Data(v(k)), Data(k)),
                        _ => Ok(()),
                    };
                }
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
                flags: super::func_flags(tcx, v.instance),
            });
            encoded.push(code);
        }
        drop(merge_t);
        if let Some(path) = &dump_code {
            use std::io::Write;
            let res = std::fs::OpenOptions::new().append(true).open(path).and_then(|mut f| f.write_all(names.as_bytes()));
            res.unwrap_or_else(|e| tcx.dcx().fatal(format!("ryo: RYO_DUMP_CODE: {e}")));
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
        if !mode.pe {
            pool.roots.text(ryo_bytecode::image::PERSONALITY);
        }
        match w.finish_encoded(encoded) {
            Ok(image) => (image, pool.roots),
            Err(e) => tcx.dcx().fatal(format!("ryo: invalid image: {e:?}")),
        }
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

/// Lowers the candidates (in parallel) until the set of VM functions is stable: a function
/// that calls a candidate which turned out native is lowered again, with an island for that
/// call. Returns the lowered functions and the reasons the others stay native.
fn lower_all<'tcx>(
    tcx: TyCtxt<'tcx>,
    candidates: &[(Instance<'tcx>, MonoItemData)],
    mode: asm::Mode,
) -> (FxHashMap<Instance<'tcx>, LoweredFn<'tcx>>, Vec<(Instance<'tcx>, NeedsNative)>) {
    let mut vm: FxHashSet<Instance<'tcx>> = candidates.iter().map(|c| c.0).collect();
    let mut ok: FxHashMap<Instance<'tcx>, LoweredFn<'tcx>> = FxHashMap::default();
    let mut failed = Vec::new();
    let mut todo: Vec<Instance<'tcx>> = candidates.iter().map(|c| c.0).collect();
    while !todo.is_empty() {
        let cx = LowerCx { vm: &vm, mode, cert: super::switches::get().dump_lean.is_some() };
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
                    GlobalAlloc::Static(def_id) => (static_symbol(tcx, def_id).name, super::static_needs_direct_slot(tcx, def_id)),
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

pub fn local_stable_crate_id(tcx: TyCtxt<'_>) -> u64 {
    tcx.stable_crate_id(LOCAL_CRATE).as_u64()
}

/// Our `symbol_name` (design/backend.md#query-overrides): `c_main` is the target's entry name, and local copies of `LocalCopy` instances get
/// a crate-unique suffix (design/backend.md, Linkage).
pub fn symbol_name<'tcx>(tcx: TyCtxt<'tcx>, instance: Instance<'tcx>, original: impl FnOnce() -> ty::SymbolName<'tcx>) -> ty::SymbolName<'tcx> {
    if let InstanceKind::Item(def_id) = instance.def
        && let Some(rt) = rt_items(tcx)
        && def_id.krate == rt.krate
    {
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

/// Prints decoded VM code for `RYO_DUMP`: one instruction per line, without offsets, with
/// branch targets (`@±n`) and cleanup entries naming labels `L<n>`, numbered in order of
/// position, and `L<n>:` printed before each labeled instruction.
fn dump_labeled(out: &mut String, words: &[u32], cleanup: &[ryo_bytecode::image::CleanupEntry], scopes: &[asm::Scope]) {
    use std::fmt::Write;
    let mut lines = Vec::new();
    for r in ryo_bytecode::full::Decoder::new(words) {
        match r {
            Ok((at, insn)) => lines.push((at, insn.to_string())),
            Err(e) => {
                lines.push((usize::MAX, format!("error: {e}")));
                break;
            }
        }
    }
    // Rewrites each `@±n` in `text` (at `at`) with `f(at + n)`.
    fn targets(text: &str, at: usize, mut f: impl FnMut(usize) -> String) -> String {
        let mut res = String::new();
        let mut rest = text;
        while let Some(i) = rest.find('@') {
            res.push_str(&rest[..i]);
            let t = &rest[i + 1..];
            let n = t.find(|c: char| c != '+' && c != '-' && !c.is_ascii_digit()).unwrap_or(t.len());
            let off: i64 = t[..n].parse().expect("a branch offset");
            res.push_str(&f((at as i64 + off) as usize));
            rest = &t[n..];
        }
        res.push_str(rest);
        res
    }
    let mut labeled = std::collections::BTreeSet::new();
    for (at, text) in &lines {
        targets(text, *at, |t| {
            labeled.insert(t);
            String::new()
        });
    }
    for e in cleanup {
        labeled.insert(e.offset as usize);
        if e.target != CONTINUE {
            labeled.insert((e.target & !CATCH) as usize);
        }
    }
    let label: FxHashMap<usize, usize> = labeled.iter().enumerate().map(|(i, &at)| (at, i)).collect();
    let name = |at: usize| match label.get(&at) {
        Some(l) => format!("L{l}"),
        None => format!("@{at}"),
    };
    // The escapes and storage ends before the instruction at `at`.
    let mut scopes = scopes.iter().peekable();
    let mut scopes_at = |out: &mut String, at: usize| {
        while let Some(sc) = scopes.next_if(|sc| sc.code_offset as usize <= at) {
            let what = match sc.kind {
                asm::ScopeKind::Escape { align } => format!("escape align {align}"),
                asm::ScopeKind::End => "end".to_owned(),
                asm::ScopeKind::Lend => "lend".to_owned(),
            };
            writeln!(out, "    ; {what} ${}, {} bytes", sc.frame_offset, sc.size).unwrap();
        }
    };
    for (at, text) in &lines {
        if label.contains_key(at) {
            writeln!(out, "{}:", name(*at)).unwrap();
        }
        scopes_at(out, *at);
        writeln!(out, "    {}", targets(text, *at, name)).unwrap();
    }
    scopes_at(out, usize::MAX);
    for e in cleanup {
        let to = match e.target {
            CONTINUE => "continue".to_owned(),
            t if t & CATCH != 0 => format!("{} (catch)", name((t & !CATCH) as usize)),
            t => name(t as usize),
        };
        writeln!(out, "  cleanup {} -> {to}", name(e.offset as usize)).unwrap();
    }
}
