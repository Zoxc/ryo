/-
Ryo.Spec.Mir.WellFormed — static well-formedness of MIR programs.

Ports: MiniRust `lang/well-formed.md` (the expression/statement/terminator/function/program
part: `check_wf` for `PlaceExpr`, `ValueExpr`, `Statement`, `Terminator`, `Function`,
`Program`), checked on MIR instead (D1), in the spirit of rustc's MIR validator
(`rustc_mir_transform/src/validate.rs`).

Checked:
- every local type is well-formed (`Ty.wf`) and sized; `argCount`, `spreadArg` in range;
- local and block indices are in range, and so are the instances of calls, tail calls, drop
  glue and assert panics, and the targets of globals' relocations (other instance and global
  indices, in constants, `ThreadLocalRef`, fn-pointer and vtable casts and the lang items,
  are only checked when they are used, `global?`/`callInstance`);
- place projections type-check (deref of pointers, fields in range, index locals of type
  `usize`, downcasts in range);
- `SwitchInt` operands are integers, `bool` or `char`;
- cleanup-block discipline: unwind edges go to cleanup blocks, normal edges stay within the
  same kind of block (cleanup → cleanup, normal → normal), `UnwindResume` only in cleanup
  blocks, and calls in cleanup blocks do not use `UnwindAction::{Continue, Cleanup}`;
- rvalues against their destination (rustc `TypeChecker::visit_rvalue` and `Rvalue::ty`), up to
  the type's *shape* (constructor, integer/float type, pointer metadata kind, size; see
  `sameShape`): operand kinds of each `BinOp`/`UnOp` (homogeneous operands, comparisons to
  `bool`, `*WithOverflow` to `(T, bool)`, `Offset` of a raw pointer by `isize`/`usize`), source
  and target kinds of each `CastKind` (`Transmute`: only that both are sized; a size mismatch
  is UB, D33), `Ref`/`RawPtr` to a pointer with the place's metadata kind, `Discriminant` to an
  integer, `Repeat` to an array of that length, `ThreadLocalRef` to a pointer, `Aggregate`
  field counts and field shapes, the variant index and the union's active field in range, and
  `AggregateKind::RawPtr`/`PtrMetadata` metadata types;
- D9 needs no check (`always_storage_live_locals` is computed from the body).
Not checked: exact `Ty` equality (rustc compares Rust types up to regions; our `Ty`s are
layouts, and the dump of one Rust type need not agree on trait names, `ValidRange`s and
reference/raw/box pointer kinds), nested field types beyond their shape, `Unsize` beyond the
metadata kind (`unsizeValue` checks struct coercions when it runs), aggregates of ADTs that are
neither structs, enums nor unions (out of scope), and call destinations against the callee's
return type.
-/
import Ryo.Spec.Mir.Syntax
import Ryo.Spec.Lang.WellFormed

namespace Ryo.Spec.Wf

abbrev WfM := Except String

def ensure (b : Bool) (msg : String) : WfM Unit := if b then pure () else throw msg

def localTy (b : Body) (l : Local) : WfM Ty :=
  match b.locals[l]? with
  | some t => pure t
  | none => throw s!"local _{l} out of range"

def projTy (b : Body) (ty : Ty) : ProjElem → WfM Ty
  | .deref pointee => do
    let .ptr _ _ := ty | throw "Deref of a non-pointer type"
    pure pointee
  | .field f _ =>
    match ty with
    | .tuple fields _ tail =>
      match fields[f]? with
      | some (_, t) => pure t
      | none =>
        match tail with
        | some t => if f == fields.length then pure t else throw s!"Field {f} out of range"
        | none => throw s!"Field {f} out of range"
    | .union fields _ _ _ =>
      match fields[f]? with
      | some (_, t) => pure t
      | none => throw s!"Field {f} out of range"
    | _ => throw "Field projection on a non-projectable type"
  | .index l => do
    let lt ← localTy b l
    match lt with
    | .int ⟨false, 8⟩ _ => pure ()
    | _ => throw "Index local is not a usize"
    match ty with
    | .array e _ | .slice e => pure e
    | _ => throw "Index of a non-indexable type"
  | .constantIndex .. =>
    match ty with
    | .array e _ | .slice e => pure e
    | _ => throw "ConstantIndex of a non-indexable type"
  | .subslice fr to fromEnd =>
    match ty with
    | .array e n =>
      if fromEnd || to < fr || to > n then throw "Subslice out of range" else pure (.array e (to - fr))
    | .slice e => pure (.slice e)
    | _ => throw "Subslice of a non-indexable type"
  | .downcast v =>
    match ty with
    | .enum vs .. =>
      match vs[v]? with
      | some var => pure var.fields
      | none => throw s!"Downcast to variant {v} out of range"
    | _ => throw "Downcast of a non-enum"
  | .opaqueCast t | .unwrapUnsafeBinder t => pure t

def placeTy (b : Body) (p : MPlace) : WfM Ty := do
  p.proj.foldlM (projTy b) (← localTy b p.base)

def operandTy (b : Body) : Operand → WfM Ty
  | .copy p | .move p => placeTy b p
  | .const _ ty => pure ty
  | .runtimeChecks .. => pure .bool

/-! ## Rvalue typing

rustc's validator (`TypeChecker::visit_rvalue`, `visit_statement` on `Assign`) requires the
rvalue's type to equal the destination's (`mir_assign_valid_types`: equal up to regions and
opaque types) and constrains operand kinds per operator and cast kind. Our `Ty` has layouts,
not Rust types: two `Ty`s of the same Rust type agree, but distinct Rust types can share a
`Ty` and the dump of one Rust type at two places may differ in details we do not want to trust
(trait names of `dyn` types, `ValidRange`s, `ref`/`box`/`raw` pointer kinds). So we compare
*shapes* (`sameShape`): the type constructor, the integer/float type, the pointer's
metadata kind, and the size. Every check below follows from rustc's rvalue types
(`Rvalue::ty`, `BinOp::ty`) and validator (equal Rust types have equal layouts), so the MIR
rustc produces passes; where rustc's validator accepts a combination rustc never emits and
the semantics cannot run (`IntToInt` to a float, ...), we require what the semantics runs.
Where the semantics accepts more than rustc (three-way comparison of `bool`s and pointers,
as in MiniRust), so do we. Ill-typed programs are rejected before they run. -/

/-- rustc's name of a constructor (`Ryo.Spec.BinOp.addWithOverflow` → `AddWithOverflow`),
from its `Repr`, for error messages. -/
def ctorName {α : Type} [Repr α] (a : α) : String :=
  let head := ((reprStr a).splitOn " ").headD ""
  let last := (head.splitOn ".").getLastD head
  last.capitalize

/-- A short description of a type for error messages. -/
def tyKind : Ty → String
  | .int t _ => s!"{if t.signed then "i" else "u"}{t.bits}"
  | .bool => "bool"
  | .char => "char"
  | .float f => s!"f{f.bits}"
  | .ptr .fnPtr _ => "fn pointer"
  | .ptr p _ => if p.isWide then "wide pointer" else "pointer"
  | .fnDef _ => "fn item"
  | .tuple .. => "struct/tuple"
  | .array _ n => s!"array of length {n}"
  | .slice _ => "slice"
  | .union .. => "union"
  | .enum .. => "enum"
  | .traitObject _ => "dyn type"
  | .opaqueBytes .. => "opaque bytes"

/-- The metadata kind with the trait name erased: `dyn` names are not compared (rustc renders
them with lifetimes and auto traits, and upcasts and `dyn A + Send → dyn A` keep the vtable
kind). -/
def metaClass : PointerMetaKind → Nat
  | .none => 0
  | .elementCount => 1
  | .vtablePointer _ => 2

/-- The metadata kind of a pointer *to* `t`. -/
def tyMetaClass (t : Ty) : Nat := metaClass t.metaKind

def ptrMetaClass (p : PtrType) : Nat := metaClass p.metaKind

/-- The metadata kind a value of pointer type `t` carries (0 for non-pointers). -/
def ptrTyMetaClass : Ty → Nat
  | .ptr p _ => ptrMetaClass p
  | _ => 0

/-- Same shape: what any two `Ty`s of the same Rust type (up to regions) share. Fields are not
compared recursively (sizes and the constructor suffice to catch shape errors, and nested
`Ty`s may legitimately differ in the details listed above). -/
def sameShape (a b : Ty) : Bool :=
  a.size? == b.size? &&
  match a, b with
  | .int t _, .int t' _ => t == t'
  | .bool, .bool | .char, .char => true
  | .float f, .float f' => f == f'
  | .ptr p _, .ptr p' _ => ptrMetaClass p == ptrMetaClass p'
  | .fnDef _, .fnDef _ => true
  | .tuple fs _ _, .tuple fs' _ _ => fs.length == fs'.length
  | .array _ n, .array _ n' => n == n'
  | .slice _, .slice _ | .union .., .union .. | .enum .., .enum .. => true
  | .traitObject _, .traitObject _ | .opaqueBytes .., .opaqueBytes .. => true
  | _, _ => false

/-- `dest` (the assignment's destination type) has the shape of the rvalue's type `rv`. -/
def expectShape (what : String) (rv dest : Ty) : WfM Unit :=
  ensure (sameShape rv dest)
    s!"{what}: a value of type {tyKind rv} assigned to a place of type {tyKind dest}"

def isInt : Ty → Bool
  | .int .. => true
  | _ => false

def isFloat : Ty → Bool
  | .float _ => true
  | _ => false

def isPtr : Ty → Bool
  | .ptr .. => true
  | _ => false

def isRawPtr : Ty → Bool
  | .ptr (.raw ..) _ => true
  | _ => false

def isFnPtr : Ty → Bool
  | .ptr .fnPtr _ => true
  | _ => false

def isFnDef : Ty → Bool
  | .fnDef _ => true
  | _ => false

def isBool : Ty → Bool
  | .bool => true
  | _ => false

/-- Integers, `bool` and `char` (rustc: `is_integral() || is_char() || is_bool()`). -/
def isIntLike : Ty → Bool
  | .int .. | .bool | .char => true
  | _ => false

/-- A zero-sized struct/tuple (the `()` that thin-pointer metadata is). -/
def isUnitLike : Ty → Bool
  | t@(.tuple ..) => t.size? == some 0
  | _ => false

/-- The destination of a pointer's metadata (`PtrMetadata`, `AggregateKind::RawPtr`): `()`,
`usize`, or a vtable pointer. -/
def checkMetaTy (what : String) (mk : PointerMetaKind) (t : Ty) : WfM Unit :=
  match mk with
  | .none => ensure (isUnitLike t) s!"{what}: thin-pointer metadata must be `()`, not {tyKind t}"
  | .elementCount =>
    ensure (t matches .int ⟨false, 8⟩ _) s!"{what}: slice metadata must be usize, not {tyKind t}"
  | .vtablePointer _ =>
    ensure (isPtr t) s!"{what}: vtable metadata must be a pointer, not {tyKind t}"

-- rustc `BinOp::ty` and the `BinaryOp` arm of `visit_rvalue`.
def checkBinOp (op : BinOp) (a b dest : Ty) : WfM Unit := do
  let name := ctorName op
  let homogeneous := match op with
    | .offset | .shl | .shlUnchecked | .shr | .shrUnchecked => false
    | _ => true
  if homogeneous then
    ensure (sameShape a b)
      s!"BinaryOp {name}: operands of different types ({tyKind a}, {tyKind b})"
  let both (ok : Ty → Bool) (kinds : String) : WfM Unit :=
    for x in [a, b] do
      ensure (ok x) s!"BinaryOp {name}: operand of type {tyKind x}, expected {kinds}"
  match op with
  | .offset => do
    ensure (isRawPtr a) s!"BinaryOp Offset: {tyKind a} is not a raw pointer"
    -- rustc emits `Offset` only for `T: Sized`, which the semantics needs (`pointeeSize`).
    let sizedPointee := match a with
      | .ptr pt _ => pt.pointee?.any (fun l => l.layout matches .sized ..)
      | _ => false
    ensure sizedPointee s!"BinaryOp Offset: {tyKind a} doesn't point at a sized type"
    ensure (b matches .int ⟨_, 8⟩ _)
      s!"BinaryOp Offset: offset of type {tyKind b}, expected isize or usize"
    expectShape "BinaryOp Offset" a dest
  | .eq | .ne | .lt | .le | .gt | .ge => do
    both (fun x => isIntLike x || isFloat x || isRawPtr x || isFnPtr x)
      "a bool, char, integer, float, raw pointer or fn pointer"
    ensure (dest matches .bool)
      s!"BinaryOp {name}: result assigned to a place of type {tyKind dest}, expected bool"
  | .cmp => do
    -- rustc: integers and `char`; MiniRust (and the semantics) also compare `bool` and
    -- pointers three-way, so those are accepted too.
    both (fun x => isIntLike x || isRawPtr x || isFnPtr x)
      "a bool, char, integer, raw pointer or fn pointer"
    -- `Ordering` (a fieldless `i8` enum), or one like it: variants with the discriminants
    -- -1, 0 and 1, as `orderingValue` needs; the semantics also accepts a plain integer.
    let orderingLike := match dest with
      | .int .. => true
      | .enum vs discrTy .. =>
        [-1, 0, 1].all fun (d : Int) => vs.any fun v => discrTy.bringInBounds v.discr == d
      | _ => false
    ensure orderingLike
      s!"BinaryOp Cmp: result assigned to a place of type {tyKind dest}, expected Ordering"
  | .addWithOverflow | .subWithOverflow | .mulWithOverflow => do
    both isInt "an integer"
    match dest with
    | .tuple [(_, r), (_, o)] _ none =>
      ensure (sameShape a r && isBool o)
        s!"BinaryOp {name}: result must be ({tyKind a}, bool)"
    | _ => throw s!"BinaryOp {name}: result assigned to a place of type {tyKind dest}, \
        expected ({tyKind a}, bool)"
  | .addUnchecked | .subUnchecked | .mulUnchecked
  | .shl | .shlUnchecked | .shr | .shrUnchecked => do
    both isInt "an integer"
    expectShape s!"BinaryOp {name}" a dest
  | .bitAnd | .bitOr | .bitXor => do
    both (fun x => isInt x || isBool x) "an integer or bool"
    expectShape s!"BinaryOp {name}" a dest
  | .add | .sub | .mul | .div | .rem => do
    both (fun x => isInt x || isFloat x) "an integer or float"
    expectShape s!"BinaryOp {name}" a dest

def checkUnOp (op : UnOp) (a dest : Ty) : WfM Unit :=
  match op with
  | .neg => do
    ensure (isInt a || isFloat a) s!"UnaryOp Neg on {tyKind a}"
    expectShape "UnaryOp Neg" a dest
  | .not => do
    ensure (isInt a || isBool a) s!"UnaryOp Not on {tyKind a}"
    expectShape "UnaryOp Not" a dest
  | .ptrMetadata =>
    match a with
    | .ptr p _ => checkMetaTy "UnaryOp PtrMetadata" p.metaKind dest
    | _ => throw s!"UnaryOp PtrMetadata on {tyKind a}"

-- The `Cast` arm of `visit_rvalue`, with the destinations `evalCast` accepts.
def checkCast (k : CastKind) (src dst : Ty) : WfM Unit := do
  let expect (b : Bool) (msg : String) : WfM Unit :=
    let name := match k with
      | .pointerCoercion c => s!"PointerCoercion({ctorName c})"
      | _ => ctorName k
    ensure b s!"Cast {name}: {msg} (from {tyKind src} to {tyKind dst})"
  match k with
  | .intToInt =>
    expect (isIntLike src && (isInt dst || dst == .char))
      "expected an integer, bool or char to an integer or char"
  | .intToFloat =>
    expect (isIntLike src && isFloat dst) "expected an integer, bool or char to a float"
  | .floatToInt => expect (isFloat src && isInt dst) "expected a float to an integer"
  | .floatToFloat => expect (isFloat src && isFloat dst) "expected a float to a float"
  | .pointerExposeProvenance => expect (isPtr src && isInt dst) "expected a pointer to an integer"
  | .pointerWithExposedProvenance =>
    -- `evalCast` gives a thin pointer (no metadata to attach).
    expect (isIntLike src && isRawPtr dst && ptrTyMetaClass dst == 0)
      "expected an integer, bool or char to a thin raw pointer"
  | .ptrToPtr =>
    -- A thin pointer cannot become a wide one; wide → wide keeps the metadata.
    expect (isPtr src && isPtr dst &&
        (ptrTyMetaClass dst == 0 || ptrTyMetaClass src == ptrTyMetaClass dst))
      "expected a pointer to a pointer with no or the same metadata"
  | .fnPtrToPtr =>
    expect (isFnPtr src && isPtr dst && ptrTyMetaClass dst == 0)
      "expected a fn pointer to a thin pointer"
  | .transmute | .boxDerefTransmute => do
    -- rustc: any two sized types (different sizes are UB when run, D33)
    expect (src.isSized && dst.isSized) "both types must be sized"
    if k == .boxDerefTransmute then expect (isPtr dst) "the target must be a pointer"
  | .subtype => expect (sameShape src dst) "the types differ"
  | .pointerCoercion c =>
    match c with
    | .reifyFnPointer _ =>
      expect (isFnDef src && isFnPtr dst) "expected a fn item to a fn pointer"
    | .closureFnPointer _ => expect (isFnPtr dst) "expected a fn pointer target"
    | .unsafeFnPointer =>
      expect (isFnPtr src && isFnPtr dst) "expected a fn pointer to a fn pointer"
    -- (rustc disallows these two after borrowck; the semantics keeps the address)
    | .mutToConstPointer =>
      expect (isPtr src && sameShape src dst) "expected a pointer to a pointer"
    | .arrayToPointer =>
      expect (isPtr src && isPtr dst && ptrTyMetaClass dst == 0)
        "expected a pointer to a thin pointer"
    | .unsize m =>
      -- rustc: `CoerceUnsized`. A pointer gets the metadata; a struct (`Box`, `Rc`, ...)
      -- is coerced field by field (D30), which `unsizeValue` checks when it runs.
      match src, dst with
      | .ptr _ _, .ptr _ _ =>
        let cls := match m with | .length _ => 1 | _ => 2
        expect (ptrTyMetaClass dst == cls)
          s!"the target pointer's metadata does not fit the {ctorName m} metadata"
        -- An upcast keeps or replaces the source's vtable (`unsizeValue`), so needs one.
        if m matches .upcast _ then
          expect (ptrTyMetaClass src == 2) "an upcast needs a source pointer with a vtable"
      | .tuple fs _ _, .tuple fs' _ _ => expect (fs.length == fs'.length) "the structs differ"
      | _, _ => expect false "expected a pointer or a struct of pointers"

-- The `Aggregate` arm of `visit_rvalue` (field counts and types), plus the variant index
-- range rustc gets from `adt_def.variants()[idx]`.
def checkAggregate (b : Body) (k : AggregateKind) (ops : List Operand) (dest : Ty) : WfM Unit := do
  let tys ← ops.mapM (operandTy b)
  let fieldsMatch (what : String) (fields : List (Offset × Ty)) : WfM Unit := do
    ensure (fields.length == tys.length)
      s!"Aggregate {what}: {tys.length} operands for {fields.length} fields"
    for ((_, ft), t) in fields.zip tys do expectShape s!"Aggregate {what} field" t ft
  match k, dest with
  | .array, .array e n => do
    ensure (n == tys.length) s!"Aggregate array: {tys.length} operands for an array of length {n}"
    for t in tys do expectShape "Aggregate array element" t e
  | .array, _ => throw s!"Aggregate array assigned to a place of type {tyKind dest}"
  | .tuple, .tuple fs _ none => fieldsMatch "tuple" fs
  | .tuple, _ => throw s!"Aggregate tuple assigned to a place of type {tyKind dest}"
  | .closure, .tuple fs _ none => fieldsMatch "closure" fs
  | .closure, _ => throw s!"Aggregate closure assigned to a place of type {tyKind dest}"
  | .adt v active, .enum vs .. => do
    ensure active.isNone "Aggregate: active field on an enum"
    match vs[v]? with
    | some var =>
      match var.fields with
      | .tuple fs _ none => fieldsMatch s!"variant {v}" fs
      | _ => throw s!"Aggregate: variant {v} is not a sized struct"
    | none => throw s!"Aggregate: variant {v} out of range"
  | .adt v active, .union fs .. => do
    ensure (v == 0) s!"Aggregate: variant {v} of a union"
    let some f := active | throw "Aggregate: union without an active field"
    let some (_, ft) := fs[f]? | throw s!"Aggregate: union field {f} out of range"
    let [t] := tys | throw "Aggregate: unions take exactly one operand"
    expectShape "Aggregate union field" t ft
  | .adt v active, .tuple fs _ none => do
    ensure (v == 0) s!"Aggregate: variant {v} of a struct"
    ensure active.isNone "Aggregate: active field on a struct"
    fieldsMatch "struct" fs
  -- Other destinations (SIMD vectors as `opaqueBytes`, ...) are out of scope; the semantics
  -- rejects them when they run (mir-spec §A.1).
  | .adt .., _ => pure ()
  | .rawPtr, .ptr pt _ => do
    let [d, m] := tys | throw "Aggregate RawPtr: expected a data pointer and metadata"
    ensure (isRawPtr d && ptrTyMetaClass d == 0)
      s!"Aggregate RawPtr: the data pointer is a {tyKind d}, expected a thin raw pointer"
    checkMetaTy "Aggregate RawPtr" pt.metaKind m
  | .rawPtr, _ => throw s!"Aggregate RawPtr assigned to a place of type {tyKind dest}"

/-- Rvalue typing against the destination type `dest`. -/
def checkRvalue (b : Body) (dest : Ty) : Rvalue → WfM Unit
  | .use o => do expectShape "Use" (← operandTy b o) dest
  | .copyForDeref p => do expectShape "CopyForDeref" (← placeTy b p) dest
  | .wrapUnsafeBinder o ty => do
    let t ← operandTy b o
    expectShape "WrapUnsafeBinder" t ty
    expectShape "WrapUnsafeBinder" ty dest
  | .repeat o n => do
    let t ← operandTy b o
    match dest with
    | .array e n' => do
      ensure (n == n') s!"Repeat: {n} copies assigned to an array of length {n'}"
      expectShape "Repeat element" t e
    | _ => throw s!"Repeat assigned to a place of type {tyKind dest}"
  -- `&place`, `&raw place`: a pointer whose metadata kind is the place type's.
  | .ref _ p | .rawPtr _ p => do
    let t ← placeTy b p
    match dest with
    | .ptr pt _ =>
      ensure (pt.pointee?.isSome && ptrMetaClass pt == tyMetaClass t)
        s!"Ref/RawPtr: a pointer to {tyKind t} assigned to a place of type {tyKind dest}"
    | _ => throw s!"Ref/RawPtr assigned to a place of type {tyKind dest}"
  -- rustc: the rvalue's type is `ty` (a user ADT with one lifetime): the place's type for a
  -- mutable reborrow, its `CoerceShared` target (same layout) for a shared one.
  | .reborrow ty mutbl p => do
    let t ← placeTy b p
    if mutbl then expectShape "Reborrow" t ty
    else
      ensure (t.size == ty.size && t.align == ty.align)
        s!"Reborrow: a {tyKind t} place coerced to {tyKind ty} of a different layout"
    expectShape "Reborrow" ty dest
  | .threadLocalRef _ =>
    ensure (isPtr dest) s!"ThreadLocalRef assigned to a place of type {tyKind dest}"
  | .discriminant p => do
    let _ ← placeTy b p
    ensure (isInt dest) s!"Discriminant assigned to a place of type {tyKind dest}"
  | .cast k o ty => do
    checkCast k (← operandTy b o) ty
    expectShape "Cast" ty dest
  | .binaryOp op x y => do checkBinOp op (← operandTy b x) (← operandTy b y) dest
  | .unaryOp op o => do checkUnOp op (← operandTy b o) dest
  | .aggregate k ops => checkAggregate b k ops dest

def checkStatement (b : Body) : Statement → WfM Unit
  | .assign p rv => do
    let t ← placeTy b p
    ensure t.isSized "Assign to an unsized place"
    checkRvalue b t rv
  | .setDiscriminant p v => do
    match ← placeTy b p with
    | .enum vs .. => ensure (v < vs.length) "SetDiscriminant: variant out of range"
    | _ => throw "SetDiscriminant of a non-enum"
  | .storageLive l | .storageDead l => do let _ ← localTy b l
  | .assume o => do
    match ← operandTy b o with
    | .bool => pure ()
    | _ => throw "Assume of a non-bool"
  | .copyNonOverlapping s d c => do
    let _ ← operandTy b s
    let _ ← operandTy b d
    let _ ← operandTy b c
  | .placeMention p => do let _ ← placeTy b p
  | .nop _ => pure ()

def blockOk (b : Body) (bb : BasicBlock) : WfM BlockData :=
  match b.blocks[bb]? with
  | some bd => pure bd
  | none => throw s!"basic block bb{bb} out of range"

/-- A normal edge: the target exists and has the same cleanup-ness. -/
def edge (b : Body) (fromCleanup : Bool) (bb : BasicBlock) : WfM Unit := do
  let bd ← blockOk b bb
  ensure (bd.isCleanup == fromCleanup)
    (if fromCleanup then s!"edge from a cleanup block to normal block bb{bb}"
     else s!"edge from a normal block to cleanup block bb{bb}")

def unwindEdge (b : Body) (fromCleanup : Bool) (u : UnwindAction) : WfM Unit := do
  match u with
  | .cleanup bb => do
    ensure (!fromCleanup) "UnwindAction::Cleanup in a cleanup block"
    let bd ← blockOk b bb
    ensure bd.isCleanup s!"unwind edge to normal block bb{bb}"
  | .continue => ensure (!fromCleanup) "UnwindAction::Continue in a cleanup block"
  | _ => pure ()

/-- A caller location: `inherit` only in a `#[track_caller]` body, which has one to pass on
(`evalCallerLoc`). -/
def checkCallerLoc (b : Body) : Option CallerLoc → WfM Unit
  | some .inherit => ensure b.trackCaller "inherited caller location in a body without #[track_caller]"
  | _ => pure ()

def checkTerminator (b : Body) (nInst : Nat) (cleanup : Bool) : Terminator → WfM Unit
  | .goto bb => edge b cleanup bb
  | .switchInt d cases otherwise => do
    match ← operandTy b d with
    | .int .. | .bool | .char => pure ()
    | _ => throw "SwitchInt on a type that is not an integer, bool or char"
    cases.forM fun (_, bb) => edge b cleanup bb
    edge b cleanup otherwise
  | .unwindResume => ensure cleanup "UnwindResume in a normal block"
  | .unwindTerminate _ => pure ()
  | .return => ensure (!cleanup) "Return in a cleanup block"
  | .unreachable => pure ()
  | .drop p glue target unwind => do
    let _ ← placeTy b p
    if let some i := glue then ensure (i < nInst) "Drop: glue instance out of range"
    edge b cleanup target
    unwindEdge b cleanup unwind
  | .call f args dest target unwind loc _ => do
    match f with
    | .inst i => ensure (i < nInst) "Call: instance out of range"
    | .fnPtr o => do let _ ← operandTy b o
    | .virtual _ => ensure (!args.isEmpty) "virtual call without a receiver"
    args.forM fun o => do let _ ← operandTy b o
    checkCallerLoc b loc
    let _ ← placeTy b dest
    if let some t := target then edge b cleanup t
    unwindEdge b cleanup unwind
  | .tailCall f args loc _ => do
    match f with
    | .inst i => ensure (i < nInst) "TailCall: instance out of range"
    | .fnPtr o => do let _ ← operandTy b o
    | .virtual _ => pure ()
    args.forM fun o => do let _ ← operandTy b o
    checkCallerLoc b loc
  | .assert c _ msg target unwind => do
    match ← operandTy b c with
    | .bool => pure ()
    | _ => throw "Assert on a non-bool"
    ensure (msg.panicFn < nInst) "Assert: panic function out of range"
    -- The panic's operands, evaluated only when the assertion fails.
    msg.args.forM fun o => do let _ ← operandTy b o
    checkCallerLoc b msg.callerLocation
    edge b cleanup target
    unwindEdge b cleanup unwind

def checkBody (nInst : Nat) (b : Body) : WfM Unit := do
  ensure (b.locals.size > 0) "body without a return local"
  ensure (b.argCount < b.locals.size) "argCount out of range"
  if let some s := b.spreadArg then
    ensure (s ≥ 1 && s ≤ b.argCount) "spread_arg is not an argument"
  for (t, l) in b.locals.toList.zipIdx do
    ensure t.wf s!"local _{l}: ill-formed type"
    ensure t.isSized s!"local _{l}: unsized local variable"
  ensure (b.blocks.size > 0) "body without blocks"
  ensure (!(b.blocks[0]!).isCleanup) "the start block is a cleanup block"
  for bd in b.blocks do
    bd.stmts.forM (checkStatement b)
    checkTerminator b nInst bd.isCleanup bd.term

def checkProgram (p : Program) : WfM Unit := do
  ensure (p.body? p.start).isSome "the start instance has no body"
  for (inst, i) in p.instances.toList.zipIdx do
    match inst.kind with
    | .body b =>
      match checkBody p.instances.size b with
      | .ok () => pure ()
      | .error e => throw s!"{inst.symbol} (instance {i}): {e}"
    | _ => pure ()
  for (g, gi) in p.globals.toList.zipIdx do
    for r in g.relocs do
      ensure (r.offset + 8 ≤ g.bytes.length) s!"global {gi}: relocation out of range"
      match r.target with
      | .alloc t => ensure (t < p.globals.size) s!"global {gi}: relocation to a missing global"
      | .fn i => ensure (i < p.instances.size) s!"global {gi}: relocation to a missing function"
      | .typeId => pure ()

end Ryo.Spec.Wf
