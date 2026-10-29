//! `RYO_DUMP_LEAN=<dir>`: writes the crate's program, from its entry function, as the Lean
//! MIR spec's `Program` (`lean/Ryo/Spec/Mir/Syntax.lean`, JSON as derived there, see
//! `lean/Ryo/Spec/Mir/Json.lean`) to `<dir>/<crate name>.json` (milestone M1b,
//! lean/docs/plan.md).
//!
//! The dump is trusted input of the verification (lean/docs/aot.md §C6), so it is a plain
//! serializer of rustc's data: monomorphized MIR (`instance_mir` instantiated with the
//! instance's args), layouts from `layout_of`, resolutions from `Instance::expect_resolve` &
//! co., constants from const evaluation, vtables from `vtable_allocation`, ABIs from
//! `fn_abi_of_instance`/`fn_abi_of_fn_ptr`. It calls rustc's queries directly and shares no
//! code with the lowering (`lower/`), so a lowering bug can't hide itself in the dump.
//!
//! Instances: every instance reachable from the user's `main` through calls, fn pointers
//! (reify, closure coercions), drop glue, vtable entries, `Assert` panic lang items, the
//! `UnwindTerminate` lang items, `panic_nounwind` (called by `assert_inhabited` & co.) and
//! function pointers in constants. A body when MIR is available, `intrinsic name tyArgs` for
//! rustc intrinsics (the instance's generic args: types as `intrinsic_ty_arg`, other args as
//! `null`), `ext` otherwise (foreign items, upstream functions without MIR, LLVM intrinsics, virtual
//! calls' instances). Drop glue of `dyn Trait` is `ext` too: rustc's shim body for it only
//! drops `*self` again (codegen turns that into a call of the vtable's drop entry, skipped
//! when it is null). So are thread-local shims, although rustc builds MIR for them: the
//! interpreter rejects a program when it calls one.
//!
//! What the spec's AST can't express becomes a call of an `ext` instance named
//! `ryo-dump: unsupported <what>`, which the interpreter rejects when it gets there.
//!
//! Only reads queries (all cached and side-effect free), and only when the variable is set.
//!
//! Next to it, `<dir>/<crate name>.cert.json`: the lowering's certificate for each VM function
//! of each of the crate's images (`lower/cert.rs`), `{"images": [{"cgu", "functions":
//! [{"symbol", "cert"}]}], "islands": [{"symbol", "template"}]}`: per image, in CGU order, its
//! CGU's name (whose `image::cgu_hash` is the image header's) and its functions in image order
//! (an `#[inline]` function copied into several images has an entry in each), and per island
//! instance the images call its symbol and its template's diagnostic item name
//! (`tcx.symbol_name` of the instance, `get_diagnostic_name` of its def). Unlike the dump it is the lowering's own data,
//! and untrusted (lean/docs/aot.md §C1), but for the island names, which rustc gives.

use std::collections::VecDeque;
use std::rc::Rc;

use super::json::{J, ctor, num, obj, opt, pair, tag};
use rustc_abi::{
    BackendRepr, FieldsShape, HasDataLayout, IntegerType, Primitive, Scalar, Size, TagEncoding, TargetDataLayout, Variants, WrappingRange,
};
use rustc_data_structures::fx::FxHashMap;
use rustc_hir::attrs::lang_items::LangItem;
use rustc_hir::def_id::{DefId, LOCAL_CRATE};
use rustc_middle::mir::interpret::{AllocId, ConstAllocation, GlobalAlloc, Scalar as MScalar, alloc_range};
use rustc_middle::mir::{
    self, AggregateKind, AssertKind, BasicBlock, BinOp, BorrowKind, CastKind, ConstValue, NonDivergingIntrinsic, Operand, Place, ProjectionElem,
    RawPtrKind, Rvalue, SourceInfo, StatementKind, TerminatorKind, UnOp, UnwindAction, UnwindTerminateReason,
};
use rustc_middle::ty::adjustment::PointerCoercion;
use rustc_middle::ty::layout::{HasTyCtxt, HasTypingEnv, TyAndLayout};
use rustc_middle::ty::{self, Instance, InstanceKind, ShimKind, Ty, TyCtxt, TypingEnv};
use rustc_target::callconv::{ArgAbi, FnAbi, PassMode};

/// With `RYO_DUMP_LEAN` set, writes the certificate file and, if the crate has an entry
/// function, the program dump.
pub fn dump(tcx: TyCtxt<'_>, switches: &super::switches::Switches, results: &super::partition::Results) {
    let Some(dir) = &switches.dump_lean else { return };
    let dir = std::path::PathBuf::from(dir);
    write_certs(tcx, results, &dir);
    let Some((main, _)) = tcx.entry_fn(()) else { return };
    let mut d = Dumper::new(tcx);
    let start = d.instance(Instance::mono(tcx, main));
    let mut lang = |item| tcx.lang_items().get(item).map(|def_id| num(d.instance(Instance::mono(tcx, def_id))));
    let cannot_unwind = lang(LangItem::PanicCannotUnwind);
    let in_cleanup = lang(LangItem::PanicInCleanup);
    let nounwind = lang(LangItem::PanicNounwind);
    d.run();
    let program = obj(vec![
        ("instances", J::Arr(d.instances.into_iter().map(|i| i.expect("instance not dumped")).collect())),
        ("globals", J::Arr(d.globals.into_iter().map(|g| g.expect("global not dumped")).collect())),
        ("start", num(start)),
        (
            "langItems",
            obj(vec![
                ("panicCannotUnwind", cannot_unwind.unwrap_or(J::Null)),
                ("panicInCleanup", in_cleanup.unwrap_or(J::Null)),
                ("panicNounwind", nounwind.unwrap_or(J::Null)),
            ]),
        ),
    ]);
    write_json(tcx, &dir, "json", &program);
}

/// Writes `<dir>/<crate name>.cert.json`, the certificates of the images' VM functions: per
/// image (its CGU's name) its functions in image order, and the crate's islands.
fn write_certs(tcx: TyCtxt<'_>, results: &super::partition::Results, dir: &std::path::Path) {
    let Some(lean) = &results.lean else { return };
    let entry = |key, symbol: &str, v| obj(vec![("symbol", J::Str(symbol.into())), (key, v)]);
    let images = lean.images.iter().map(|(cgu, certs)| {
        let functions = certs.iter().map(|(symbol, cert)| entry("cert", symbol, J::Raw(cert.as_str().into())));
        obj(vec![("cgu", J::Str(cgu.clone())), ("functions", J::Arr(functions.collect()))])
    });
    let islands = lean.islands.iter().map(|(symbol, template)| entry("template", symbol, J::Str(template.clone())));
    let certs = obj(vec![("images", J::Arr(images.collect())), ("islands", J::Arr(islands.collect()))]);
    write_json(tcx, dir, "cert.json", &certs);
}

/// Writes `j` to `<dir>/<crate name>.<ext>`, or fails the compilation.
fn write_json(tcx: TyCtxt<'_>, dir: &std::path::Path, ext: &str, j: &J) {
    let mut out = String::new();
    j.write(&mut out);
    if let Err(e) = std::fs::create_dir_all(dir) {
        tcx.dcx().fatal(format!("ryo: RYO_DUMP_LEAN: creating {}: {e}", dir.display()));
    }
    super::dump::write(tcx, "RYO_DUMP_LEAN", dir.join(format!("{}.{ext}", tcx.crate_name(LOCAL_CRATE))), &out);
}

// ---------------------------------------------------------------------------------------------
// The dumper

/// A layout context: the `TyCtxt` with a monomorphic typing env.
#[derive(Clone, Copy)]
struct Lcx<'tcx>(TyCtxt<'tcx>);

impl<'tcx> HasTyCtxt<'tcx> for Lcx<'tcx> {
    fn tcx(&self) -> TyCtxt<'tcx> {
        self.0
    }
}

impl<'tcx> HasTypingEnv<'tcx> for Lcx<'tcx> {
    fn typing_env(&self) -> TypingEnv<'tcx> {
        TypingEnv::fully_monomorphized()
    }
}

impl HasDataLayout for Lcx<'_> {
    fn data_layout(&self) -> &TargetDataLayout {
        &self.0.data_layout
    }
}

#[derive(Clone, PartialEq, Eq, Hash)]
enum InstKey<'tcx> {
    Inst(Instance<'tcx>),
    /// Something the AST can't express, as an `ext` instance of this name.
    Unsupported(String),
}

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
enum GlobalKey {
    Alloc(AllocId),
    Static(DefId),
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum GKind {
    Const,
    /// A vtable (the `dyn` type's name, if known, is in `Dumper::global_kinds`).
    Vtable,
    Static,
}

struct Dumper<'tcx> {
    tcx: TyCtxt<'tcx>,
    cx: Lcx<'tcx>,
    inst_ids: FxHashMap<InstKey<'tcx>, usize>,
    instances: Vec<Option<J>>,
    inst_queue: VecDeque<(usize, InstKey<'tcx>)>,
    global_ids: FxHashMap<GlobalKey, usize>,
    globals: Vec<Option<J>>,
    global_queue: VecDeque<(usize, GlobalKey)>,
    /// Kind and trait name of each global (a vtable may first be seen as a plain allocation).
    global_kinds: Vec<(GKind, Option<String>)>,
    /// Memoized types, by type, valid range override and `box_ptrs`.
    tys: FxHashMap<(Ty<'tcx>, Option<(u128, u128)>, bool), Rc<str>>,
    /// Serializing an intrinsic's type argument: `Box<T, A>` becomes `(PtrType.box, A)`
    /// (`intrinsic_ty_arg`).
    box_ptrs: bool,
    pointees: FxHashMap<Ty<'tcx>, Rc<str>>,
}

impl<'tcx> Dumper<'tcx> {
    fn new(tcx: TyCtxt<'tcx>) -> Self {
        Dumper {
            tcx,
            cx: Lcx(tcx),
            inst_ids: Default::default(),
            instances: Vec::new(),
            inst_queue: VecDeque::new(),
            global_ids: Default::default(),
            globals: Vec::new(),
            global_queue: VecDeque::new(),
            global_kinds: Vec::new(),
            tys: Default::default(),
            box_ptrs: false,
            pointees: Default::default(),
        }
    }

    fn typing_env(&self) -> TypingEnv<'tcx> {
        self.cx.typing_env()
    }

    fn run(&mut self) {
        loop {
            if let Some((id, key)) = self.inst_queue.pop_front() {
                let j = self.instance_json(key);
                self.instances[id] = Some(j);
            } else if let Some((id, key)) = self.global_queue.pop_front() {
                let j = self.global_json(id, key);
                self.globals[id] = Some(j);
            } else {
                break;
            }
        }
    }

    fn key_id(&mut self, key: InstKey<'tcx>) -> usize {
        if let Some(&id) = self.inst_ids.get(&key) {
            return id;
        }
        let id = self.instances.len();
        self.instances.push(None);
        self.inst_ids.insert(key.clone(), id);
        self.inst_queue.push_back((id, key));
        id
    }

    fn instance(&mut self, i: Instance<'tcx>) -> usize {
        self.key_id(InstKey::Inst(i))
    }

    fn unsupported_inst(&mut self, what: &str) -> usize {
        self.key_id(InstKey::Unsupported(format!("ryo-dump: unsupported {what}")))
    }

    fn global(&mut self, key: GlobalKey, kind: GKind, name: Option<String>) -> usize {
        if let Some(&id) = self.global_ids.get(&key) {
            // A vtable reached first as a plain constant allocation.
            if kind == GKind::Vtable && self.global_kinds[id].0 == GKind::Const {
                self.global_kinds[id] = (GKind::Vtable, name);
                // Already emitted as a constant: emit it again, which also upgrades the
                // vtables it points to.
                if self.globals[id].take().is_some() {
                    self.global_queue.push_back((id, key));
                }
            }
            return id;
        }
        let id = self.globals.len();
        self.globals.push(None);
        self.global_kinds.push((kind, name));
        self.global_ids.insert(key, id);
        self.global_queue.push_back((id, key));
        id
    }

    fn layout(&self, ty: Ty<'tcx>) -> Option<TyAndLayout<'tcx>> {
        self.tcx.layout_of(self.typing_env().as_query_input(ty)).ok()
    }

    fn name_of(&self, ty: Ty<'tcx>) -> String {
        rustc_middle::ty::print::with_no_trimmed_paths!(ty.to_string())
    }

    // -----------------------------------------------------------------------------------------
    // Instances

    fn symbol(&self, i: Instance<'tcx>) -> String {
        match i.def {
            InstanceKind::Intrinsic(def_id) => self.tcx.item_name(def_id).to_string(),
            InstanceKind::Virtual(..) => rustc_middle::ty::print::with_no_trimmed_paths!(format!("ryo-dump: virtual {i}")),
            _ => self.tcx.symbol_name(i).name.to_string(),
        }
    }

    fn instance_json(&mut self, key: InstKey<'tcx>) -> J {
        let i = match key {
            InstKey::Unsupported(name) => return obj(vec![("symbol", J::Str(name)), ("kind", tag("ext"))]),
            InstKey::Inst(i) => i,
        };
        let symbol = self.symbol(i);
        let kind = match i.def {
            InstanceKind::Intrinsic(def_id) => {
                let ty_args = i.args.iter().map(|a| a.as_type().map_or(J::Null, |t| self.intrinsic_ty_arg(t))).collect();
                ctor("intrinsic", vec![("name", J::Str(self.tcx.item_name(def_id).to_string())), ("tyArgs", J::Arr(ty_args))])
            }
            InstanceKind::LlvmIntrinsic(_) | InstanceKind::Virtual(..) => tag("ext"),
            InstanceKind::Item(def_id) => {
                let ctor_kind = matches!(self.tcx.def_kind(def_id), rustc_hir::def::DefKind::Ctor(..));
                if self.tcx.is_foreign_item(def_id) || !(ctor_kind || self.tcx.is_mir_available(def_id)) {
                    tag("ext")
                } else {
                    ctor("body", vec![("b", self.body(i))])
                }
            }
            // `drop_in_place::<dyn Trait>`: its shim body is `drop(*_1)` again, which codegen
            // turns into a call of the vtable's drop entry (`codegen_drop_terminator`).
            InstanceKind::Shim(ShimKind::DropGlue(_, Some(t))) if matches!(t.kind(), ty::Dynamic(..)) => tag("ext"),
            InstanceKind::Shim(ShimKind::ThreadLocal(_)) => tag("ext"),
            InstanceKind::Shim(_) => ctor("body", vec![("b", self.body(i))]),
        };
        obj(vec![("symbol", J::Str(symbol)), ("kind", kind)])
    }

    /// A type argument of an intrinsic instance (`TyArg`): its `Ty`, except that `Box<T, A>`
    /// (anywhere inside) is `(PtrType.box, A)`, since `assert_zero_valid` & co. read
    /// Box-ness (`builtin_deref`, rustc_const_eval `check_validity_requirement_lax`); and its
    /// name as cg_ssa's `codegen_panic_intrinsic` prints it into the panic message.
    fn intrinsic_ty_arg(&mut self, t: Ty<'tcx>) -> J {
        let outer = std::mem::replace(&mut self.box_ptrs, true);
        let ty = self.ty(t);
        self.box_ptrs = outer;
        let name = rustc_middle::ty::print::with_no_visible_paths!(rustc_middle::ty::print::with_no_trimmed_paths!(t.to_string()));
        obj(vec![("ty", ty), ("name", J::Str(name))])
    }

    /// The Rust-level ABI of an instance's signature (`rust-call` for closures).
    fn instance_extern_abi(&self, i: Instance<'tcx>) -> rustc_abi::ExternAbi {
        let t = i.ty(self.tcx, self.typing_env());
        match t.kind() {
            ty::FnDef(..) | ty::FnPtr(..) => t.fn_sig(self.tcx).abi(),
            ty::Closure(..) | ty::CoroutineClosure(..) => rustc_abi::ExternAbi::RustCall,
            _ => rustc_abi::ExternAbi::Rust,
        }
    }

    fn body(&mut self, inst: Instance<'tcx>) -> J {
        let tcx = self.tcx;
        let generic = tcx.instance_mir(inst.def);
        let body: mir::Body<'tcx> =
            inst.instantiate_mir_and_normalize_erasing_regions(tcx, self.typing_env(), ty::EarlyBinder::bind(tcx, generic.clone()));
        let locals: Vec<J> = body.local_decls.iter().map(|d| self.ty(d.ty)).collect();
        let abi = tcx
            .fn_abi_of_instance(self.typing_env().as_query_input((inst, ty::List::empty())))
            .ok()
            .map(|fn_abi| self.fn_abi(fn_abi, self.instance_extern_abi(inst)));
        let mut fx = FnDump { inst, body: &body, track_caller: inst.def.requires_caller_location(tcx) };
        let blocks: Vec<J> = body.basic_blocks.indices().map(|bb| fx.block(self, bb)).collect();
        obj(vec![
            ("locals", J::Arr(locals)),
            ("argCount", num(body.arg_count)),
            ("spreadArg", opt(body.spread_arg.map(|l| num(l.as_usize())))),
            ("trackCaller", J::Bool(fx.track_caller)),
            ("abi", opt(abi)),
            ("blocks", J::Arr(blocks)),
        ])
    }

    fn fn_abi(&self, fn_abi: &FnAbi<'tcx, Ty<'tcx>>, abi: rustc_abi::ExternAbi) -> J {
        let conv = match abi {
            rustc_abi::ExternAbi::Rust => tag("rust"),
            rustc_abi::ExternAbi::RustCall => tag("rustCall"),
            rustc_abi::ExternAbi::C { .. } => tag("c"),
            other => ctor("other", vec![("name", J::Str(other.to_string()))]),
        };
        obj(vec![("conv", conv), ("args", J::Arr(fn_abi.args.iter().map(|a| self.arg_abi(a)).collect())), ("ret", self.arg_abi(&fn_abi.ret))])
    }

    fn arg_abi(&self, a: &ArgAbi<'tcx, Ty<'tcx>>) -> J {
        let prim = |s: &Scalar| match s.primitive() {
            Primitive::Int(i, _) => format!("i{}", i.size().bits()),
            Primitive::Float(f) => format!("f{}", f.size().bits()),
            Primitive::Pointer(_) => "ptr".to_owned(),
        };
        let (mode, detail) = match &a.mode {
            PassMode::Ignore => ("ignore", String::new()),
            PassMode::Direct(_) => (
                "direct",
                match a.layout.backend_repr {
                    BackendRepr::Scalar(s) => prim(&s),
                    _ => "vector".to_owned(),
                },
            ),
            PassMode::Pair(..) => (
                "pair",
                match a.layout.backend_repr {
                    BackendRepr::ScalarPair { a, b, .. } => format!("{},{}", prim(&a), prim(&b)),
                    _ => String::new(),
                },
            ),
            PassMode::Cast { cast, pad_i32 } => ("cast", format!("{cast:?}{}", if *pad_i32 { " pad_i32" } else { "" })),
            PassMode::Indirect { meta_attrs: None, on_stack, .. } => ("indirect", if *on_stack { "on_stack".to_owned() } else { String::new() }),
            PassMode::Indirect { meta_attrs: Some(_), .. } => ("indirectUnsized", String::new()),
        };
        // The LLVM-level scalars of a `Direct` scalar, a `Pair` and an integer `Cast` without
        // prefix (the Rust ABI's small aggregates): class, size and offset in the value, which
        // the Lean side assigns to registers and stack slots as the platform convention says.
        let scalar = |s: &Scalar, off: u64| {
            let float = matches!(s.primitive(), Primitive::Float(_));
            obj(vec![("float", J::Bool(float)), ("size", num(s.size(&self.cx).bytes())), ("off", num(off))])
        };
        let scalars = match (&a.mode, a.layout.backend_repr) {
            (PassMode::Direct(_), BackendRepr::Scalar(s)) => Some(vec![scalar(&s, 0)]),
            (PassMode::Pair(..), BackendRepr::ScalarPair { a, b, b_offset }) => Some(vec![scalar(&a, 0), scalar(&b, b_offset.bytes())]),
            (PassMode::Cast { cast, pad_i32: false }, _)
                if cast.prefix.is_empty()
                    && cast.rest_offset.is_none()
                    && cast.rest.unit.kind == rustc_abi::RegKind::Integer
                    && cast.rest.total == cast.rest.unit.size =>
            {
                Some(vec![obj(vec![("float", J::Bool(false)), ("size", num(cast.rest.total.bytes())), ("off", num(0))])])
            }
            _ => None,
        };
        obj(vec![
            ("mode", tag(mode)),
            ("size", num(a.layout.size.bytes())),
            ("align", num(a.layout.align.abi.bytes())),
            ("detail", J::Str(detail)),
            ("scalars", opt(scalars.map(J::Arr))),
        ])
    }

    // -----------------------------------------------------------------------------------------
    // Globals

    fn global_ref(&mut self, id: AllocId) -> J {
        match self.tcx.global_alloc(id) {
            GlobalAlloc::Function { instance } => ctor("fn", vec![("i", num(self.instance(instance)))]),
            GlobalAlloc::TypeId { .. } => tag("typeId"),
            _ => ctor("alloc", vec![("g", num(self.alloc_global(id, GKind::Const)))]),
        }
    }

    /// The global of a memory, vtable or static allocation `id`. `kind` is `Vtable` for the
    /// targets of a vtable's pointers (supertrait vtables).
    fn alloc_global(&mut self, id: AllocId, kind: GKind) -> usize {
        match self.tcx.global_alloc(id) {
            GlobalAlloc::Memory(_) => self.global(GlobalKey::Alloc(id), kind, None),
            GlobalAlloc::VTable(t, dyn_ty) => {
                let vt = super::lower::vtable_alloc(self.tcx, t, dyn_ty);
                let name = self.name_of(Ty::new_dynamic(self.tcx, dyn_ty, self.tcx.lifetimes.re_erased));
                self.global(GlobalKey::Alloc(vt), GKind::Vtable, Some(name))
            }
            GlobalAlloc::Static(def_id) => self.global(GlobalKey::Static(def_id), GKind::Static, None),
            GlobalAlloc::Function { .. } | GlobalAlloc::TypeId { .. } => unreachable!("not an allocation"),
        }
    }

    fn global_json(&mut self, id: usize, key: GlobalKey) -> J {
        let tcx = self.tcx;
        let (kind, name) = self.global_kinds[id].clone();
        // A static's symbol (`symbol_name` of its instance, as for every item); none for
        // constants and vtables, which have no address of their own.
        let mut symbol = None;
        let (alloc, kind_json): (Option<ConstAllocation<'tcx>>, J) = match key {
            GlobalKey::Alloc(a) => {
                let GlobalAlloc::Memory(alloc) = tcx.global_alloc(a) else { unreachable!() };
                let k = match kind {
                    GKind::Vtable => ctor("vtable", vec![("traitName", opt(name.map(J::Str)))]),
                    _ => tag("const"),
                };
                (Some(alloc), k)
            }
            GlobalKey::Static(def_id) => {
                symbol = Some(tcx.symbol_name(Instance::mono(tcx, def_id)).name.to_string());
                let alloc = if tcx.is_foreign_item(def_id) { None } else { tcx.eval_static_initializer(def_id).ok() };
                let k = if tcx.is_thread_local_static(def_id) {
                    tag("threadLocal")
                } else {
                    let t = tcx.normalize_erasing_regions(self.typing_env(), tcx.type_of(def_id).instantiate_identity());
                    let mutable = tcx.static_mutability(def_id) == Some(rustc_hir::Mutability::Mut) || !t.is_freeze(tcx, self.typing_env());
                    ctor("static", vec![("mutable", J::Bool(mutable))])
                };
                (alloc, k)
            }
        };
        let Some(alloc) = alloc else {
            // A foreign static: no bytes (any access is out of bounds in the interpreter).
            return obj(vec![
                ("bytes", J::Arr(vec![])),
                ("relocs", J::Arr(vec![])),
                ("align", num(1)),
                ("kind", kind_json),
                ("symbol", opt(symbol.map(J::Str))),
            ]);
        };
        let a = alloc.inner();
        let size = a.size().bytes_usize();
        let raw = a.inspect_with_uninit_and_ptr_outside_interpreter(0..size);
        let all_init = a.init_mask().is_range_initialized(alloc_range(Size::ZERO, a.size())).is_ok();
        let bytes: Vec<J> = (0..size)
            .map(|i| {
                if all_init || a.init_mask().is_range_initialized(alloc_range(Size::from_bytes(i), Size::from_bytes(1))).is_ok() {
                    num(raw[i])
                } else {
                    J::Null
                }
            })
            .collect();
        let ptrs: Vec<(Size, AllocId)> = a.provenance().ptrs().iter().map(|(off, prov)| (*off, prov.alloc_id())).collect();
        let ptr_size = tcx.data_layout.pointer_size().bytes_usize();
        let target_kind = if kind == GKind::Vtable { GKind::Vtable } else { GKind::Const };
        let relocs: Vec<J> = ptrs
            .into_iter()
            .map(|(off, target)| {
                let o = off.bytes_usize();
                let mut addend = [0u8; 8];
                addend[..ptr_size].copy_from_slice(&raw[o..o + ptr_size]);
                let t = match tcx.global_alloc(target) {
                    GlobalAlloc::Memory(_) => ctor("alloc", vec![("g", num(self.alloc_global(target, target_kind)))]),
                    _ => self.global_ref(target),
                };
                obj(vec![("offset", num(o)), ("target", t), ("addend", num(u64::from_le_bytes(addend)))])
            })
            .collect();
        obj(vec![
            ("bytes", J::Arr(bytes)),
            ("relocs", J::Arr(relocs)),
            ("align", num(a.align.bytes())),
            ("kind", kind_json),
            ("symbol", opt(symbol.map(J::Str))),
        ])
    }

    // -----------------------------------------------------------------------------------------
    // Constants

    fn const_value(&mut self, v: ConstValue) -> J {
        match v {
            ConstValue::Scalar(MScalar::Int(i)) => ctor("scalar", vec![("bits", num(i.to_bits(i.size())))]),
            ConstValue::Scalar(MScalar::Ptr(p, _)) => {
                let (prov, off) = p.prov_and_relative_offset();
                ctor("ptr", vec![("target", self.global_ref(prov.alloc_id())), ("offset", num(off.bytes()))])
            }
            ConstValue::ZeroSized => tag("zeroSized"),
            ConstValue::Slice { alloc_id, meta } => {
                ctor("slice", vec![("alloc", num(self.alloc_global(alloc_id, GKind::Const))), ("len", num(meta))])
            }
            ConstValue::Indirect { alloc_id, offset } => {
                ctor("indirect", vec![("alloc", num(self.alloc_global(alloc_id, GKind::Const))), ("offset", num(offset.bytes()))])
            }
        }
    }

    // -----------------------------------------------------------------------------------------
    // Types

    fn ty(&mut self, t: Ty<'tcx>) -> J {
        self.ty_with(t, None)
    }

    /// `t` as a `Ty`; `range` overrides the valid range of a scalar leaf (pattern types).
    fn ty_with(&mut self, t: Ty<'tcx>, range: Option<WrappingRange>) -> J {
        let key = (t, range.map(|r| (r.start, r.end)), self.box_ptrs);
        if let Some(s) = self.tys.get(&key) {
            return J::Raw(s.clone());
        }
        let j = self.ty_uncached(t, range).to_raw();
        self.tys.insert(key, j.clone());
        J::Raw(j)
    }

    fn int_type(signed: bool, size: u64) -> J {
        obj(vec![("signed", J::Bool(signed)), ("size", num(size))])
    }

    fn range(r: WrappingRange) -> J {
        obj(vec![("start", num(r.start)), ("stop", num(r.end))])
    }

    /// The valid range of the (first) scalar of a layout.
    fn leaf_range(&self, l: TyAndLayout<'tcx>, over: Option<WrappingRange>) -> WrappingRange {
        if let Some(r) = over {
            return r;
        }
        match l.backend_repr {
            BackendRepr::Scalar(s) | BackendRepr::ScalarPair { a: s, .. } => s.valid_range(&self.cx),
            _ => WrappingRange::full(l.size),
        }
    }

    fn opaque(l: TyAndLayout<'tcx>) -> J {
        Self::size_align("opaqueBytes", l.size.bytes(), l.align.abi.bytes())
    }

    /// `name { size, align }` (`opaqueBytes` or a `sized` layout strategy).
    fn size_align(name: &'static str, size: u64, align: u64) -> J {
        ctor(name, vec![("size", num(size)), ("align", num(align))])
    }

    /// Fields `range` of `l` at their offsets.
    fn fields(&mut self, l: TyAndLayout<'tcx>, range: std::ops::Range<usize>) -> Vec<J> {
        range.map(|i| pair(num(l.fields.offset(i).bytes()), self.ty(l.field(&self.cx, i).ty))).collect()
    }

    /// A sized tuple of `fields`, with the size and alignment of `l`.
    fn sized_tuple(fields: Vec<J>, l: TyAndLayout<'tcx>) -> J {
        ctor("tuple", vec![("fields", J::Arr(fields)), ("head", Self::head(l.size.bytes(), l.align.abi.bytes(), None)), ("tail", J::Null)])
    }

    /// A pointer of kind `p` with the valid range of `l` (or `over`).
    fn ptr_ty(&self, p: J, l: TyAndLayout<'tcx>, over: Option<WrappingRange>) -> J {
        ctor("ptr", vec![("p", p), ("valid", Self::range(self.leaf_range(l, over)))])
    }

    fn ty_uncached(&mut self, t: Ty<'tcx>, over: Option<WrappingRange>) -> J {
        let tcx = self.tcx;
        let Some(l) = self.layout(t) else {
            eprintln!("ryo: RYO_DUMP_LEAN: no layout for {}", self.name_of(t));
            return Self::size_align("opaqueBytes", 0, 1);
        };
        match *t.kind() {
            ty::Bool => tag("bool"),
            ty::Char => tag("char"),
            ty::Int(_) | ty::Uint(_) => {
                let signed = matches!(t.kind(), ty::Int(_));
                ctor("int", vec![("t", Self::int_type(signed, l.size.bytes())), ("valid", Self::range(self.leaf_range(l, over)))])
            }
            ty::Float(f) => {
                let name = match f {
                    ty::FloatTy::F16 => "f16",
                    ty::FloatTy::F32 => "f32",
                    ty::FloatTy::F64 => "f64",
                    ty::FloatTy::F128 => "f128",
                };
                ctor("float", vec![("f", tag(name))])
            }
            ty::RawPtr(p, m) | ty::Ref(_, p, m) => {
                let kind = if t.is_ref() { "ref" } else { "raw" };
                let pt = ctor(kind, vec![("mutbl", J::Bool(m.is_mut())), ("pointee", self.pointee(p))]);
                self.ptr_ty(pt, l, over)
            }
            ty::FnPtr(..) => self.ptr_ty(tag("fnPtr"), l, over),
            ty::FnDef(def_id, args) => {
                let args = args.no_bound_vars().expect("monomorphic fn item");
                let i = Instance::expect_resolve(tcx, self.typing_env(), def_id, args, rustc_span::DUMMY_SP);
                ctor("fnDef", vec![("i", num(self.instance(i)))])
            }
            ty::Never => ctor(
                "enum",
                vec![
                    ("variants", J::Arr(vec![])),
                    ("discrTy", Self::int_type(false, 1)),
                    ("repr", tag("empty")),
                    ("size", num(0)),
                    ("align", num(1)),
                ],
            ),
            ty::Pat(base, _) => {
                let r = self.leaf_range(l, over);
                self.ty_with(base, Some(r))
            }
            ty::Adt(adt, args) if tcx.is_lang_item(adt.did(), LangItem::DynMetadata) => {
                // `DynMetadata<dyn Trait>`: the vtable pointer (`PtrMetadata` of a `dyn` pointer).
                let name = self.name_of(args.type_at(0));
                self.ptr_ty(ctor("vtablePtr", vec![("t", J::Str(name))]), l, over)
            }
            ty::Adt(adt, _) if adt.repr().simd() => Self::opaque(l),
            ty::Adt(adt, _) if adt.is_union() => {
                let fields = self.fields(l, 0..l.fields.count());
                let chunks = if l.size.bytes() > 0 { vec![pair(num(0), num(l.size.bytes()))] } else { vec![] };
                ctor(
                    "union",
                    vec![("fields", J::Arr(fields)), ("chunks", J::Arr(chunks)), ("size", num(l.size.bytes())), ("align", num(l.align.abi.bytes()))],
                )
            }
            ty::Adt(adt, _) if adt.is_enum() => self.enum_ty(t, l, adt),
            ty::Adt(adt, args) if adt.is_box() && self.box_ptrs && l.fields.count() > 0 => {
                // `intrinsic_ty_arg`: field 0 (`Unique<T>`) as a box pointer with its range
                let f0 = l.field(&self.cx, 0);
                let ptr = ctor("box", vec![("pointee", self.pointee(args.type_at(0)))]);
                let mut fields = vec![pair(num(0), self.ptr_ty(ptr, f0, None))];
                fields.extend(self.fields(l, 1..l.fields.count()));
                Self::sized_tuple(fields, l)
            }
            ty::Adt(adt, _) => self.tuple_ty(l, adt.repr().pack.map(|a| a.bytes())),
            ty::Tuple(_) | ty::Closure(..) => self.tuple_ty(l, None),
            ty::Array(e, _) => {
                let count = match l.fields {
                    FieldsShape::Array { count, .. } => count,
                    _ => 0,
                };
                ctor("array", vec![("elem", self.ty(e)), ("count", num(count))])
            }
            ty::Slice(e) => ctor("slice", vec![("elem", self.ty(e))]),
            ty::Str => ctor("slice", vec![("elem", self.ty(tcx.types.u8))]),
            ty::Dynamic(..) => ctor("traitObject", vec![("t", J::Str(self.name_of(t)))]),
            ty::Foreign(_) => ctor("traitObject", vec![("t", J::Str(format!("ryo-dump: unsupported extern type {}", self.name_of(t))))]),
            ty::UnsafeBinder(b) => {
                let inner = tcx.instantiate_bound_regions_with_erased(ty::Binder::from(b));
                self.ty_with(inner, over)
            }
            _ => {
                eprintln!("ryo: RYO_DUMP_LEAN: type {} as opaque bytes", self.name_of(t));
                Self::opaque(l)
            }
        }
    }

    /// Fields at their offsets; an unsized last field is the tail.
    fn tuple_ty(&mut self, l: TyAndLayout<'tcx>, pack: Option<u64>) -> J {
        let n = l.fields.count();
        let unsized_tail = l.is_unsized() && n > 0;
        let sized_n = if unsized_tail { n - 1 } else { n };
        let fields = self.fields(l, 0..sized_n);
        let (end, tail) =
            if unsized_tail { (l.fields.offset(n - 1).bytes(), Some(self.ty(l.field(&self.cx, n - 1).ty))) } else { (l.size.bytes(), None) };
        ctor("tuple", vec![("fields", J::Arr(fields)), ("head", Self::head(end, l.align.abi.bytes(), pack)), ("tail", opt(tail))])
    }

    fn head(end: u64, align: u64, pack: Option<u64>) -> J {
        obj(vec![("end", num(end)), ("align", num(align)), ("packedAlign", opt(pack.map(num)))])
    }

    fn enum_ty(&mut self, t: Ty<'tcx>, l: TyAndLayout<'tcx>, adt: ty::AdtDef<'tcx>) -> J {
        let tcx = self.tcx;
        let (dsigned, dsize) = match adt.repr().discr_type() {
            IntegerType::Pointer(s) => (s, tcx.data_layout.pointer_size().bytes()),
            IntegerType::Fixed(i, s) => (s, i.size().bytes()),
        };
        let variants: Vec<J> = adt
            .variants()
            .indices()
            .map(|v| {
                let vl = l.for_variant(&self.cx, v);
                let fields = self.fields(vl, 0..vl.fields.count());
                let fields = Self::sized_tuple(fields, l);
                let d = t.discriminant_for_variant(tcx, v).expect("enum discriminant");
                let bits = self.layout(d.ty).map_or(128, |dl| dl.size.bits());
                let val = if dsigned { sign_extend(d.val, bits).to_string() } else { d.val.to_string() };
                obj(vec![("discr", J::Num(val)), ("fields", fields), ("inhabited", J::Bool(!vl.is_uninhabited()))])
            })
            .collect();
        let repr = match &l.variants {
            Variants::Empty => tag("empty"),
            Variants::Single { index } => ctor("single", vec![("idx", num(index.as_usize()))]),
            Variants::Multiple { tag: tag_scalar, tag_encoding, tag_field, .. } => {
                let tag_ty = match tag_scalar.primitive() {
                    Primitive::Int(i, s) => Self::int_type(s, i.size().bytes()),
                    Primitive::Pointer(_) => Self::int_type(false, tcx.data_layout.pointer_size().bytes()),
                    Primitive::Float(f) => Self::int_type(false, f.size().bytes()),
                };
                let encoding = match tag_encoding {
                    TagEncoding::Direct => tag("direct"),
                    TagEncoding::Niche { untagged_variant, niche_variants, niche_start } => ctor(
                        "niche",
                        vec![
                            ("untagged", num(untagged_variant.as_usize())),
                            ("lo", num(niche_variants.start.as_usize())),
                            ("hi", num(niche_variants.last.as_usize())),
                            ("nicheStart", num(niche_start)),
                        ],
                    ),
                };
                ctor(
                    "multiple",
                    vec![(
                        "tag",
                        obj(vec![
                            ("offset", num(l.fields.offset(tag_field.as_usize()).bytes())),
                            ("tag", tag_ty),
                            ("valid", Self::range(tag_scalar.valid_range(&self.cx))),
                            ("encoding", encoding),
                        ]),
                    )],
                )
            }
        };
        ctor(
            "enum",
            vec![
                ("variants", J::Arr(variants)),
                ("discrTy", Self::int_type(dsigned, dsize)),
                ("repr", repr),
                ("size", num(l.size.bytes())),
                ("align", num(l.align.abi.bytes())),
            ],
        )
    }

    /// `PointeeInfo` of a pointer to `p`.
    fn pointee(&mut self, p: Ty<'tcx>) -> J {
        if let Some(s) = self.pointees.get(&p) {
            return J::Raw(s.clone());
        }
        let (layout, inhabited) = match self.layout(p) {
            Some(l) => (self.strategy(p, l), !l.is_uninhabited()),
            None => (Self::size_align("sized", 0, 1), true),
        };
        let j = obj(vec![("layout", layout), ("inhabited", J::Bool(inhabited))]).to_raw();
        self.pointees.insert(p, j.clone());
        J::Raw(j)
    }

    /// `LayoutStrategy` of `t`.
    fn strategy(&mut self, t: Ty<'tcx>, l: TyAndLayout<'tcx>) -> J {
        if l.is_sized() {
            return Self::size_align("sized", l.size.bytes(), l.align.abi.bytes());
        }
        match *t.kind() {
            ty::Slice(e) => {
                let el = self.layout(e);
                ctor("slice", vec![("elemSize", num(el.map_or(0, |el| el.size.bytes()))), ("align", num(el.map_or(1, |el| el.align.abi.bytes())))])
            }
            ty::Str => ctor("slice", vec![("elemSize", num(1)), ("align", num(1))]),
            ty::Dynamic(..) => ctor("traitObject", vec![("t", J::Str(self.name_of(t)))]),
            ty::Pat(base, _) => self.strategy(base, l),
            ty::Adt(..) | ty::Tuple(..) if l.fields.count() > 0 => {
                let n = l.fields.count();
                let pack = match t.kind() {
                    ty::Adt(adt, _) => adt.repr().pack.map(|a| a.bytes()),
                    _ => None,
                };
                let tail = l.field(&self.cx, n - 1);
                let head = Self::head(l.fields.offset(n - 1).bytes(), l.align.abi.bytes(), pack);
                ctor("tuple", vec![("head", head), ("tail", self.strategy(tail.ty, tail))])
            }
            _ => ctor("traitObject", vec![("t", J::Str(format!("ryo-dump: unsupported unsized type {}", self.name_of(t))))]),
        }
    }
}

fn sign_extend(v: u128, bits: u64) -> i128 {
    if bits >= 128 {
        return v as i128;
    }
    let shift = 128 - bits;
    ((v << shift) as i128) >> shift
}

// ---------------------------------------------------------------------------------------------
// Bodies

struct FnDump<'a, 'tcx> {
    inst: Instance<'tcx>,
    body: &'a mir::Body<'tcx>,
    track_caller: bool,
}

/// `Err(what)`: something the AST can't express.
type Res<T> = Result<T, String>;

/// The parts `call` and `tailCall` terminators share.
struct CallParts {
    f: J,
    args: J,
    /// `callerLocation`.
    loc: J,
    abi: J,
}

impl<'a, 'tcx> FnDump<'a, 'tcx> {
    fn block(&mut self, d: &mut Dumper<'tcx>, bb: BasicBlock) -> J {
        let data = &self.body.basic_blocks[bb];
        let mut stmts = Vec::new();
        let mut term = None;
        for s in &data.statements {
            match self.statement(d, &s.kind) {
                Ok(j) => stmts.push(j),
                Err(what) => {
                    term = Some(self.unsupported(d, &what));
                    break;
                }
            }
        }
        let term = match term {
            Some(t) => t,
            None => self.terminator(d, data.terminator()).unwrap_or_else(|what| self.unsupported(d, &what)),
        };
        obj(vec![("stmts", J::Arr(stmts)), ("term", term), ("isCleanup", J::Bool(data.is_cleanup))])
    }

    /// A call of the `ext` instance `ryo-dump: unsupported <what>` that doesn't return.
    fn unsupported(&self, d: &mut Dumper<'tcx>, what: &str) -> J {
        eprintln!("ryo: RYO_DUMP_LEAN: {}: unsupported {what}", rustc_middle::ty::print::with_no_trimmed_paths!(self.inst.to_string()));
        let i = d.unsupported_inst(what);
        let f = ctor("inst", vec![("i", num(i))]);
        let dest = obj(vec![("base", num(0)), ("proj", J::Arr(vec![]))]);
        Self::call_json(CallParts { f, args: J::Arr(vec![]), loc: J::Null, abi: J::Null }, dest, J::Null, tag("unreachable"))
    }

    /// A `Call` or `TailCall`'s callee, arguments, caller location and ABI. cg_ssa's
    /// `codegen_call_terminator` takes the location of `fn_span`, in `at`.
    fn call_parts(
        &mut self,
        d: &mut Dumper<'tcx>,
        func: &Operand<'tcx>,
        args: &[rustc_span::Spanned<Operand<'tcx>>],
        at: SourceInfo,
        tail: bool,
    ) -> Res<CallParts> {
        let (f, abi, tc) = self.callee(d, func, tail)?;
        let args = self.operands(d, args.iter().map(|a| &a.node))?;
        let loc = tc.then(|| self.caller_location(d, at));
        Ok(CallParts { f, args: J::Arr(args), loc: opt(loc), abi: opt(abi) })
    }

    /// A `call` terminator from [`call_parts`](Self::call_parts).
    fn call_json(CallParts { f, args, loc, abi }: CallParts, dest: J, target: J, unwind: J) -> J {
        ctor("call", vec![("f", f), ("args", args), ("dest", dest), ("target", target), ("unwind", unwind), ("callerLocation", loc), ("abi", abi)])
    }

    fn operands<'o>(&mut self, d: &mut Dumper<'tcx>, ops: impl IntoIterator<Item = &'o Operand<'tcx>>) -> Res<Vec<J>>
    where
        'tcx: 'o,
    {
        ops.into_iter().map(|o| self.operand(d, o)).collect()
    }

    fn statement(&mut self, d: &mut Dumper<'tcx>, s: &StatementKind<'tcx>) -> Res<J> {
        let nop = |what: &str| Ok(ctor("nop", vec![("what", J::Str(what.to_owned()))]));
        match s {
            StatementKind::Assign(b) => {
                let (p, rv) = &**b;
                let rv = self.rvalue(d, rv)?;
                Ok(ctor("assign", vec![("p", self.place(d, *p)), ("rv", rv)]))
            }
            StatementKind::FakeRead(_) => nop("FakeRead"),
            StatementKind::SetDiscriminant { place, variant_index } => {
                Ok(ctor("setDiscriminant", vec![("p", self.place(d, **place)), ("variant", num(variant_index.as_usize()))]))
            }
            StatementKind::StorageLive(l) => Ok(ctor("storageLive", vec![("l", num(l.as_usize()))])),
            StatementKind::StorageDead(l) => Ok(ctor("storageDead", vec![("l", num(l.as_usize()))])),
            StatementKind::PlaceMention(p) => Ok(ctor("placeMention", vec![("p", self.place(d, **p))])),
            StatementKind::AscribeUserType(..) => nop("AscribeUserType"),
            StatementKind::Coverage(_) => nop("Coverage"),
            StatementKind::Intrinsic(i) => match &**i {
                NonDivergingIntrinsic::Assume(o) => Ok(ctor("assume", vec![("o", self.operand(d, o)?)])),
                NonDivergingIntrinsic::CopyNonOverlapping(c) => Ok(ctor(
                    "copyNonOverlapping",
                    vec![("src", self.operand(d, &c.src)?), ("dst", self.operand(d, &c.dst)?), ("count", self.operand(d, &c.count)?)],
                )),
            },
            StatementKind::ConstEvalCounter => nop("ConstEvalCounter"),
            StatementKind::Nop => nop("Nop"),
            StatementKind::BackwardIncompatibleDropHint { .. } => nop("BackwardIncompatibleDropHint"),
        }
    }

    fn place(&mut self, d: &mut Dumper<'tcx>, p: Place<'tcx>) -> J {
        let tcx = d.tcx;
        let mut pty = mir::PlaceTy::from_ty(self.body.local_decls[p.local].ty);
        let mut proj = Vec::new();
        for elem in p.projection.iter() {
            let next = pty.projection_ty(tcx, elem);
            proj.push(match elem {
                ProjectionElem::Deref => ctor("deref", vec![("pointee", d.ty(next.ty))]),
                ProjectionElem::Field(f, t) => ctor("field", vec![("f", num(f.as_usize())), ("ty", d.ty(t))]),
                ProjectionElem::Index(l) => ctor("index", vec![("l", num(l.as_usize()))]),
                ProjectionElem::ConstantIndex { offset, min_length, from_end } => {
                    ctor("constantIndex", vec![("offset", num(offset)), ("minLen", num(min_length)), ("fromEnd", J::Bool(from_end))])
                }
                ProjectionElem::Subslice { from, to, from_end } => {
                    ctor("subslice", vec![("fromIdx", num(from)), ("toIdx", num(to)), ("fromEnd", J::Bool(from_end))])
                }
                ProjectionElem::Downcast(_, v) => ctor("downcast", vec![("v", num(v.as_usize()))]),
                ProjectionElem::OpaqueCast(t) => ctor("opaqueCast", vec![("ty", d.ty(t))]),
                ProjectionElem::UnwrapUnsafeBinder(t) => ctor("unwrapUnsafeBinder", vec![("ty", d.ty(t))]),
            });
            pty = next;
        }
        obj(vec![("base", num(p.local.as_usize())), ("proj", J::Arr(proj))])
    }

    fn operand(&mut self, d: &mut Dumper<'tcx>, o: &Operand<'tcx>) -> Res<J> {
        Ok(match o {
            Operand::Copy(p) => ctor("copy", vec![("p", self.place(d, *p))]),
            Operand::Move(p) => ctor("move", vec![("p", self.place(d, *p))]),
            Operand::Constant(c) => {
                let v = c.const_.eval(d.tcx, d.typing_env(), c.span).map_err(|e| format!("constant evaluation failed: {e:?}"))?;
                ctor("const", vec![("c", d.const_value(v)), ("ty", d.ty(c.ty()))])
            }
            Operand::RuntimeChecks(k) => {
                let name = match k {
                    mir::RuntimeChecks::UbChecks => "ubChecks",
                    mir::RuntimeChecks::ContractChecks => "contractChecks",
                    mir::RuntimeChecks::OverflowChecks => "overflowChecks",
                };
                ctor("runtimeChecks", vec![("k", tag(name)), ("value", J::Bool(k.value(d.tcx.sess)))])
            }
        })
    }

    fn operand_ty(&self, d: &Dumper<'tcx>, o: &Operand<'tcx>) -> Ty<'tcx> {
        o.ty(&self.body.local_decls, d.tcx)
    }

    fn rvalue(&mut self, d: &mut Dumper<'tcx>, rv: &Rvalue<'tcx>) -> Res<J> {
        let tcx = d.tcx;
        Ok(match rv {
            Rvalue::Use(o, _) => ctor("use", vec![("o", self.operand(d, o)?)]),
            Rvalue::Repeat(o, n) => {
                let n = n.try_to_target_usize(tcx).ok_or("Repeat count")?;
                ctor("repeat", vec![("o", self.operand(d, o)?), ("n", num(n))])
            }
            Rvalue::Ref(_, bk, p) => ctor("ref", vec![("mutbl", J::Bool(matches!(bk, BorrowKind::Mut { .. }))), ("p", self.place(d, *p))]),
            Rvalue::ThreadLocalRef(def_id) => {
                let g = d.global(GlobalKey::Static(*def_id), GKind::Static, None);
                ctor("threadLocalRef", vec![("g", num(g))])
            }
            Rvalue::RawPtr(k, p) => ctor("rawPtr", vec![("mutbl", J::Bool(matches!(k, RawPtrKind::Mut))), ("p", self.place(d, *p))]),
            Rvalue::Cast(k, o, t) => {
                let k = self.cast_kind(d, *k, o, *t)?;
                ctor("cast", vec![("k", k), ("o", self.operand(d, o)?), ("ty", d.ty(*t))])
            }
            Rvalue::BinaryOp(op, b) => {
                let (a, bb) = &**b;
                ctor("binaryOp", vec![("op", tag(binop(*op))), ("a", self.operand(d, a)?), ("b", self.operand(d, bb)?)])
            }
            Rvalue::UnaryOp(op, a) => {
                let op = match op {
                    UnOp::Not => "not",
                    UnOp::Neg => "neg",
                    UnOp::PtrMetadata => "ptrMetadata",
                };
                ctor("unaryOp", vec![("op", tag(op)), ("a", self.operand(d, a)?)])
            }
            Rvalue::Discriminant(p) => ctor("discriminant", vec![("p", self.place(d, *p))]),
            Rvalue::Aggregate(k, ops) => {
                let k = match &**k {
                    AggregateKind::Array(_) => tag("array"),
                    AggregateKind::Tuple => tag("tuple"),
                    AggregateKind::Adt(_, v, _, _, active) => {
                        ctor("adt", vec![("variant", num(v.as_usize())), ("activeField", opt(active.map(|f| num(f.as_usize()))))])
                    }
                    AggregateKind::Closure(..) => tag("closure"),
                    AggregateKind::RawPtr(..) => tag("rawPtr"),
                    AggregateKind::Coroutine(..) | AggregateKind::CoroutineClosure(..) => return Err("coroutine aggregate".into()),
                };
                let ops = self.operands(d, ops.iter())?;
                ctor("aggregate", vec![("k", k), ("ops", J::Arr(ops))])
            }
            Rvalue::CopyForDeref(p) => ctor("copyForDeref", vec![("p", self.place(d, *p))]),
            Rvalue::WrapUnsafeBinder(o, t) => ctor("wrapUnsafeBinder", vec![("o", self.operand(d, o)?), ("ty", d.ty(*t))]),
            Rvalue::Reborrow(t, m, p) => ctor("reborrow", vec![("ty", d.ty(*t)), ("mutbl", J::Bool(m.is_mut())), ("p", self.place(d, *p))]),
        })
    }

    fn cast_kind(&mut self, d: &mut Dumper<'tcx>, k: CastKind, o: &Operand<'tcx>, to: Ty<'tcx>) -> Res<J> {
        let tcx = d.tcx;
        Ok(match k {
            CastKind::PointerExposeProvenance => tag("pointerExposeProvenance"),
            CastKind::PointerWithExposedProvenance => tag("pointerWithExposedProvenance"),
            CastKind::IntToInt => tag("intToInt"),
            CastKind::FloatToInt => tag("floatToInt"),
            CastKind::FloatToFloat => tag("floatToFloat"),
            CastKind::IntToFloat => tag("intToFloat"),
            CastKind::PtrToPtr => tag("ptrToPtr"),
            CastKind::FnPtrToPtr => tag("fnPtrToPtr"),
            CastKind::Transmute => tag("transmute"),
            CastKind::BoxDerefTransmute => tag("boxDerefTransmute"),
            CastKind::Subtype => tag("subtype"),
            CastKind::PointerCoercion(c, _) => {
                let from = self.operand_ty(d, o);
                let c = match c {
                    PointerCoercion::ReifyFnPointer(_) => {
                        let ty::FnDef(def_id, args) = *from.kind() else { return Err("ReifyFnPointer of a non-FnDef".into()) };
                        let args = args.no_bound_vars().ok_or("fn item with bound vars")?;
                        let i = Instance::resolve_for_fn_ptr(tcx, d.typing_env(), def_id, args).ok_or("unresolvable fn pointer")?;
                        ctor("reifyFnPointer", vec![("i", num(d.instance(i)))])
                    }
                    PointerCoercion::ClosureFnPointer(_) => {
                        let ty::Closure(def_id, args) = *from.kind() else { return Err("ClosureFnPointer of a non-closure".into()) };
                        let i = Instance::resolve_closure(tcx, def_id, args, ty::ClosureKind::FnOnce);
                        ctor("closureFnPointer", vec![("i", num(d.instance(i)))])
                    }
                    PointerCoercion::UnsafeFnPointer => tag("unsafeFnPointer"),
                    PointerCoercion::MutToConstPointer => tag("mutToConstPointer"),
                    PointerCoercion::ArrayToPointer => tag("arrayToPointer"),
                    PointerCoercion::Unsize => ctor("unsize", vec![("m", self.unsize_meta(d, from, to)?)]),
                };
                ctor("pointerCoercion", vec![("c", c)])
            }
        })
    }

    /// The pointees whose metadata an `Unsize` from `a` to `b` changes (the pointer itself or
    /// the field of a `CoerceUnsized` struct that differs, skipping 1-ZSTs as cg_ssa does).
    fn unsize_pointees(d: &Dumper<'tcx>, a: Ty<'tcx>, b: Ty<'tcx>) -> Option<(Ty<'tcx>, Ty<'tcx>)> {
        let tcx = d.tcx;
        match (a.kind(), b.kind()) {
            (ty::Ref(_, a, _) | ty::RawPtr(a, _), ty::Ref(_, b, _) | ty::RawPtr(b, _)) => Some((*a, *b)),
            (ty::Pat(a, _), ty::Pat(b, _)) => Self::unsize_pointees(d, *a, *b),
            (ty::Adt(da, sa), ty::Adt(db, sb)) if da == db && da.is_struct() => {
                for f in da.non_enum_variant().fields.iter() {
                    let fa = tcx.normalize_erasing_regions(d.typing_env(), f.ty(tcx, sa));
                    let fb = tcx.normalize_erasing_regions(d.typing_env(), f.ty(tcx, sb));
                    let zst = d.layout(fa).is_some_and(|l| l.is_1zst());
                    if fa != fb && !zst {
                        return Self::unsize_pointees(d, fa, fb);
                    }
                }
                None
            }
            _ => None,
        }
    }

    /// `UnsizeMeta`, as cg_ssa's `unsized_info`.
    fn unsize_meta(&mut self, d: &mut Dumper<'tcx>, from: Ty<'tcx>, to: Ty<'tcx>) -> Res<J> {
        let tcx = d.tcx;
        let (a, b) = Self::unsize_pointees(d, from, to).ok_or("Unsize between unexpected types")?;
        let (sa, sb) = tcx.struct_lockstep_tails_for_codegen(a, b, d.typing_env());
        Ok(match (sa.kind(), sb.kind()) {
            (ty::Array(_, len), ty::Slice(_)) => ctor("length", vec![("n", num(len.try_to_target_usize(tcx).ok_or("array length")?))]),
            (ty::Dynamic(..), ty::Dynamic(..)) => {
                let entry = super::lower::upcast_entry(tcx, sa, sb);
                ctor("upcast", vec![("entry", opt(entry.map(num)))])
            }
            (_, ty::Dynamic(preds, _)) => {
                let vt = super::lower::vtable_alloc(tcx, sa, preds);
                let name = d.name_of(sb);
                let g = d.global(GlobalKey::Alloc(vt), GKind::Vtable, Some(name));
                ctor("vtable", vec![("g", num(g))])
            }
            _ => return Err("unsupported unsizing".into()),
        })
    }

    fn unwind(&self, u: UnwindAction) -> J {
        match u {
            UnwindAction::Continue => tag("continue"),
            UnwindAction::Unreachable => tag("unreachable"),
            UnwindAction::Terminate(r) => ctor("terminate", vec![("r", terminate_reason(r))]),
            UnwindAction::Cleanup(bb) => ctor("cleanup", vec![("bb", num(bb.as_usize()))]),
        }
    }

    /// The caller location at `source_info`, as cg_ssa's `get_caller_location`.
    fn caller_location(&self, d: &mut Dumper<'tcx>, source_info: SourceInfo) -> J {
        let tcx = d.tcx;
        let own = self.track_caller.then_some(None);
        match self.body.caller_location_span(source_info, own, tcx, |span| Some(tcx.span_as_caller_location(span))) {
            None => tag("inherit"),
            Some(c) => ctor("const", vec![("c", d.const_value(c)), ("ty", d.ty(tcx.caller_location_ty()))]),
        }
    }

    /// The callee of a call of `func`, the caller's ABI, and whether the callee takes a caller
    /// location.
    fn callee(&mut self, d: &mut Dumper<'tcx>, func: &Operand<'tcx>, tail: bool) -> Res<(J, Option<J>, bool)> {
        let tcx = d.tcx;
        let fty = self.operand_ty(d, func);
        match *fty.kind() {
            ty::FnDef(def_id, args) => {
                let args = args.no_bound_vars().ok_or("fn item with bound vars")?;
                let mut i = Instance::expect_resolve(tcx, d.typing_env(), def_id, args, rustc_span::DUMMY_SP);
                // cg_ssa: a tail call of a `#[track_caller]` function calls its reify shim,
                // which passes the shim's own location.
                if tail && i.def.requires_caller_location(tcx) {
                    i = Instance::resolve_for_fn_ptr(tcx, d.typing_env(), def_id, args).ok_or("unresolvable tail callee")?;
                }
                let abi = match i.def {
                    // (`fn_abi_of_instance` asserts on LLVM intrinsics)
                    InstanceKind::Intrinsic(_) | InstanceKind::LlvmIntrinsic(_) => None,
                    _ => {
                        tcx.fn_abi_of_instance(d.typing_env().as_query_input((i, ty::List::empty()))).ok().map(|a| d.fn_abi(a, fty.fn_sig(tcx).abi()))
                    }
                };
                let tc = i.def.requires_caller_location(tcx)
                    || matches!(i.def, InstanceKind::Intrinsic(_)) && tcx.item_name(def_id).as_str() == "caller_location";
                let f = match i.def {
                    InstanceKind::Virtual(_, idx) => ctor("virtual", vec![("idx", num(idx))]),
                    _ => ctor("inst", vec![("i", num(d.instance(i)))]),
                };
                Ok((f, abi, tc))
            }
            ty::FnPtr(..) => {
                let sig = fty.fn_sig(tcx);
                let abi = tcx.fn_abi_of_fn_ptr(d.typing_env().as_query_input((sig, ty::List::empty()))).ok().map(|a| d.fn_abi(a, sig.abi()));
                Ok((ctor("fnPtr", vec![("o", self.operand(d, func)?)]), abi, false))
            }
            _ => Err("call of a non-fn type".into()),
        }
    }

    fn terminator(&mut self, d: &mut Dumper<'tcx>, t: &mir::Terminator<'tcx>) -> Res<J> {
        let tcx = d.tcx;
        Ok(match &t.kind {
            TerminatorKind::Goto { target } => ctor("goto", vec![("bb", num(target.as_usize()))]),
            TerminatorKind::SwitchInt { discr, targets } => {
                let cases: Vec<J> = targets.iter().map(|(v, bb)| pair(num(v), num(bb.as_usize()))).collect();
                ctor("switchInt", vec![("d", self.operand(d, discr)?), ("cases", J::Arr(cases)), ("otherwise", num(targets.otherwise().as_usize()))])
            }
            TerminatorKind::UnwindResume => tag("unwindResume"),
            TerminatorKind::UnwindTerminate(r) => ctor("unwindTerminate", vec![("r", terminate_reason(*r))]),
            TerminatorKind::Return => tag("return"),
            TerminatorKind::Unreachable => tag("unreachable"),
            TerminatorKind::Drop { place, target, unwind, .. } => {
                let ty = place.ty(self.body, tcx).ty;
                let glue = Instance::resolve_drop_glue(tcx, ty);
                let glue = match glue.def {
                    InstanceKind::Shim(ShimKind::DropGlue(_, None)) => None,
                    _ => Some(num(d.instance(glue))),
                };
                ctor(
                    "drop",
                    vec![("p", self.place(d, *place)), ("glue", opt(glue)), ("target", num(target.as_usize())), ("unwind", self.unwind(*unwind))],
                )
            }
            TerminatorKind::Call { func, args, destination, target, unwind, fn_span, .. } => {
                let c = self.call_parts(d, func, args, SourceInfo { span: *fn_span, ..t.source_info }, false)?;
                let dest = self.place(d, *destination);
                Self::call_json(c, dest, opt(target.map(|bb| num(bb.as_usize()))), self.unwind(*unwind))
            }
            TerminatorKind::TailCall { func, args, fn_span } => {
                let CallParts { f, args, loc, abi } = self.call_parts(d, func, args, SourceInfo { span: *fn_span, ..t.source_info }, true)?;
                ctor("tailCall", vec![("f", f), ("args", args), ("callerLocation", loc), ("abi", abi)])
            }
            TerminatorKind::Assert { cond, expected, msg, target, unwind } => {
                // cg_ssa's `codegen_assert_terminator`: optional overflow checks pass when the
                // session has overflow checks off.
                if !tcx.sess.overflow_checks() && msg.is_optional_overflow_check() {
                    return Ok(ctor("goto", vec![("bb", num(target.as_usize()))]));
                }
                let (item, ops): (LangItem, Vec<&Operand<'tcx>>) = match &**msg {
                    AssertKind::BoundsCheck { len, index } => (LangItem::PanicBoundsCheck, vec![index, len]),
                    AssertKind::MisalignedPointerDereference { required, found } => {
                        (LangItem::PanicMisalignedPointerDereference, vec![required, found])
                    }
                    AssertKind::NullPointerDereference => (LangItem::PanicNullPointerDereference, vec![]),
                    AssertKind::NullReferenceConstructed => (LangItem::PanicNullReferenceConstructed, vec![]),
                    AssertKind::InvalidEnumConstruction(source) => (LangItem::PanicInvalidEnumConstruction, vec![source]),
                    AssertKind::Overflow(..)
                    | AssertKind::OverflowNeg(_)
                    | AssertKind::DivisionByZero(_)
                    | AssertKind::RemainderByZero(_)
                    | AssertKind::ResumedAfterReturn(_)
                    | AssertKind::ResumedAfterPanic(_)
                    | AssertKind::ResumedAfterDrop(_) => (msg.panic_function(), vec![]),
                };
                let def_id = tcx.require_lang_item(item, t.source_info.span);
                let panic = Instance::mono(tcx, def_id);
                let args = self.operands(d, ops)?;
                let loc = panic.def.requires_caller_location(tcx).then(|| self.caller_location(d, t.source_info));
                let msg = obj(vec![("panicFn", num(d.instance(panic))), ("args", J::Arr(args)), ("callerLocation", opt(loc))]);
                ctor(
                    "assert",
                    vec![
                        ("cond", self.operand(d, cond)?),
                        ("expected", J::Bool(*expected)),
                        ("msg", msg),
                        ("target", num(target.as_usize())),
                        ("unwind", self.unwind(*unwind)),
                    ],
                )
            }
            TerminatorKind::Yield { .. } => return Err("Yield".into()),
            TerminatorKind::CoroutineDrop => return Err("CoroutineDrop".into()),
            TerminatorKind::FalseEdge { .. } => return Err("FalseEdge".into()),
            TerminatorKind::FalseUnwind { .. } => return Err("FalseUnwind".into()),
            TerminatorKind::InlineAsm { .. } => return Err("InlineAsm".into()),
        })
    }
}

fn terminate_reason(r: UnwindTerminateReason) -> J {
    tag(match r {
        UnwindTerminateReason::Abi => "abi",
        UnwindTerminateReason::InCleanup => "inCleanup",
    })
}

fn binop(op: BinOp) -> &'static str {
    match op {
        BinOp::Add => "add",
        BinOp::AddUnchecked => "addUnchecked",
        BinOp::AddWithOverflow => "addWithOverflow",
        BinOp::Sub => "sub",
        BinOp::SubUnchecked => "subUnchecked",
        BinOp::SubWithOverflow => "subWithOverflow",
        BinOp::Mul => "mul",
        BinOp::MulUnchecked => "mulUnchecked",
        BinOp::MulWithOverflow => "mulWithOverflow",
        BinOp::Div => "div",
        BinOp::Rem => "rem",
        BinOp::BitXor => "bitXor",
        BinOp::BitAnd => "bitAnd",
        BinOp::BitOr => "bitOr",
        BinOp::Shl => "shl",
        BinOp::ShlUnchecked => "shlUnchecked",
        BinOp::Shr => "shr",
        BinOp::ShrUnchecked => "shrUnchecked",
        BinOp::Eq => "eq",
        BinOp::Lt => "lt",
        BinOp::Le => "le",
        BinOp::Ne => "ne",
        BinOp::Ge => "ge",
        BinOp::Gt => "gt",
        BinOp::Cmp => "cmp",
        BinOp::Offset => "offset",
    }
}
