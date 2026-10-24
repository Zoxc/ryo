/-
Ryo.Spec.Mir.Syntax — runtime MIR (rustc 1.99.1), monomorphized, as the spec's AST.

Ports: replaces MiniRust `lang/syntax.md` (D1); follows rustc's
`compiler/rustc_middle/src/mir/syntax.rs` (1.99.1, `MirPhase::Runtime(Optimized)`).

Everything a backend resolves is resolved here (mir-spec §A.2.7): callees are `InstanceId`s
(bodies, externs, intrinsics), drop glue and the panic lang items of `Assert`/`UnwindTerminate`
are instances, vtables and constant data are `Global` allocations (D7, D29), `RuntimeChecks`
are constants (D23), caller locations are constants (D14).

Differences from rustc's MIR data:
- `ProjElem.deref` carries the pointee type (rustc gets it from the place's type; our pointer
  types only carry pointee *layouts*, so that recursive types stay finite).
- `PointerCoercion.reifyFnPointer`/`closureFnPointer` carry the resolved instance, and
  `unsize` carries the metadata to attach (D30: a length, a vtable allocation, or a trait
  upcast), all of which rustc computes from types.
- `Callee.virtual idx`: a call through vtable slot `idx` of the first argument (D29;
  rustc: `InstanceKind::Virtual`).
- `Terminator.call`/`tailCall` carry the caller's view of the ABI (`FnAbiSummary`, D14) and
  the caller location for `#[track_caller]` callees (D14).
- `Assert` carries its panic function and operands (D19, cg_ssa `codegen_assert_terminator`).
- Statements that are no-ops in runtime MIR (`FakeRead`, `AscribeUserType`, `Coverage`,
  `ConstEvalCounter`, `Nop`, `BackwardIncompatibleDropHint`) are `Statement.nop`.

JSON (de)serialization is derived; the derived instances are the dump schema (mir-spec §A.3).
-/
import Ryo.Spec.Lang.Types

namespace Ryo.Spec

open Lean

-- [D1]
/-- A place projection (rustc `ProjectionElem<Local, Ty>`). -/
inductive ProjElem where
  | deref (pointee : Ty)
  | field (f : Nat) (ty : Ty)
  | index (l : Local)
  | constantIndex (offset minLen : Nat) (fromEnd : Bool)
  | subslice (fromIdx toIdx : Nat) (fromEnd : Bool)
  | downcast (v : Nat)
  | opaqueCast (ty : Ty)
  | unwrapUnsafeBinder (ty : Ty)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- A MIR place: a local and projections. -/
structure MPlace where
  base : Local
  proj : List ProjElem := []
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

-- [D6] [D24]
/-- What a pointer in a constant points to (rustc `GlobalAlloc`). -/
inductive GlobalRef where
  /-- A static, constant or vtable allocation. -/
  | alloc (g : GlobalId)
  /-- `GlobalAlloc::Function` (D6). -/
  | fn (i : InstanceId)
  /-- `GlobalAlloc::TypeId` (D24): no provenance, address = offset. -/
  | typeId
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- A constant (rustc `ConstValue` after evaluation). -/
inductive ConstOperand where
  /-- `ConstValue::Scalar(Int)`: the bits, interpreted at the operand's type. -/
  | scalar (bits : Nat)
  /-- `ConstValue::Scalar(Ptr)`: a pointer into a global, function or type id. -/
  | ptr (target : GlobalRef) (offset : Nat)
  /-- `ConstValue::ZeroSized`. -/
  | zeroSized
  /-- `ConstValue::Slice`: a wide pointer to a constant allocation with a length. -/
  | slice (alloc : GlobalId) (len : Nat)
  /-- `ConstValue::Indirect`: the value stored in a constant allocation at an offset. -/
  | indirect (alloc : GlobalId) (offset : Nat)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive RuntimeCheck where
  | ubChecks | contractChecks | overflowChecks
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive Operand where
  | copy (p : MPlace)
  | move (p : MPlace)
  | const (c : ConstOperand) (ty : Ty)
  /-- D23: the session's value of the check. -/
  | runtimeChecks (k : RuntimeCheck) (value : Bool)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- rustc `BinOp` (all 26). -/
inductive BinOp where
  | add | addUnchecked | addWithOverflow
  | sub | subUnchecked | subWithOverflow
  | mul | mulUnchecked | mulWithOverflow
  | div | rem
  | bitXor | bitAnd | bitOr
  | shl | shlUnchecked | shr | shrUnchecked
  | eq | lt | le | ne | ge | gt
  | cmp
  | offset
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive UnOp where
  | not | neg | ptrMetadata
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

-- [D30]
/-- D30: the metadata an `Unsize` coercion attaches to the (innermost) pointer. -/
inductive UnsizeMeta where
  /-- `[T; n]` → `[T]`. -/
  | length (n : Nat)
  /-- `T` → `dyn Trait`: the vtable allocation (rustc `vtable_allocation`). -/
  | vtable (g : GlobalId)
  /-- `dyn A` → `dyn B`: keep the vtable (`none`), or use the vtable pointer stored in word
  `k` of the old vtable (trait upcasting). -/
  | upcast (entry : Option Nat)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive PointerCoercion where
  | reifyFnPointer (i : InstanceId)
  | unsafeFnPointer
  | closureFnPointer (i : InstanceId)
  | mutToConstPointer
  | arrayToPointer
  | unsize (m : UnsizeMeta)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- rustc `CastKind` (all 12). -/
inductive CastKind where
  | pointerExposeProvenance
  | pointerWithExposedProvenance
  | pointerCoercion (c : PointerCoercion)
  | intToInt | floatToInt | floatToFloat | intToFloat
  | ptrToPtr | fnPtrToPtr
  | transmute | boxDerefTransmute
  | subtype
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- rustc `AggregateKind` (coroutines are out of scope). The aggregate's type is the
destination's. -/
inductive AggregateKind where
  | array
  | tuple
  /-- A struct/enum/union: variant index (0 for structs/unions), active field for unions. -/
  | adt (variant : Nat) (activeField : Option Nat)
  | closure
  /-- `aggregate_raw_ptr`: data pointer and metadata. -/
  | rawPtr
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- rustc `Rvalue` (all 13). -/
inductive Rvalue where
  | use (o : Operand)
  | «repeat» (o : Operand) (n : Nat)
  | ref (mutbl : Bool) (p : MPlace)
  | threadLocalRef (g : GlobalId)
  | rawPtr (mutbl : Bool) (p : MPlace)
  | cast (k : CastKind) (o : Operand) (ty : Ty)
  | binaryOp (op : BinOp) (a b : Operand)
  | unaryOp (op : UnOp) (a : Operand)
  | discriminant (p : MPlace)
  | aggregate (k : AggregateKind) (ops : List Operand)
  | copyForDeref (p : MPlace)
  | wrapUnsafeBinder (o : Operand) (ty : Ty)
  | reborrow (ty : Ty) (mutbl : Bool) (p : MPlace)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive Statement where
  | assign (p : MPlace) (rv : Rvalue)
  | setDiscriminant (p : MPlace) (variant : Nat)
  | storageLive (l : Local)
  | storageDead (l : Local)
  /-- `Intrinsic(Assume)`. -/
  | assume (o : Operand)
  /-- `Intrinsic(CopyNonOverlapping)`. -/
  | copyNonOverlapping (src dst count : Operand)
  | placeMention (p : MPlace)
  /-- `FakeRead`, `AscribeUserType`, `Coverage`, `ConstEvalCounter`, `Nop`,
  `BackwardIncompatibleDropHint`. -/
  | nop (what : String := "Nop")
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

-- [D14]
/-- The `&'static Location` passed to `#[track_caller]` callees (D14). -/
inductive CallerLoc where
  /-- A constant location. -/
  | const (c : ConstOperand) (ty : Ty)
  /-- The location the current (itself `#[track_caller]`) function received. -/
  | inherit
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive Callee where
  /-- A resolved instance: a body, an extern, or an intrinsic. -/
  | inst (i : InstanceId)
  /-- A function pointer value. -/
  | fnPtr (o : Operand)
  /-- D29: vtable slot `idx` of the first argument's vtable. -/
  | «virtual» (idx : Nat)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive TerminateReason where
  | abi | inCleanup
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive UnwindAction where
  | «continue»
  | unreachable
  | terminate (r : TerminateReason)
  | cleanup (bb : BasicBlock)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- Calling conventions (rustc `ExternAbi` as far as calls care). -/
inductive CallConv where
  | rust | rustCall | c | other (name : String)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- rustc `PassMode`, reduced to its kind. -/
inductive PassModeKind where
  | ignore | direct | pair | cast | indirect | indirectUnsized
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- How one argument (or the return value) is passed (rustc `ArgAbi`, summarized). -/
structure ArgAbi where
  mode : PassModeKind
  size : Size
  align : Align
  /-- Scalar classes etc. as the dumper renders them (`"i32"`, `"ptr"`, `"f64"`, ...);
  part of the compatibility check. -/
  detail : String := ""
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- rustc `FnAbi`, summarized (D14). -/
structure FnAbiSummary where
  conv : CallConv
  args : List ArgAbi
  ret : ArgAbi
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

-- [D19]
/-- What a failed `Assert` calls (D19): the `AssertKind`'s panic lang item and operands. -/
structure AssertMessage where
  panicFn : InstanceId
  args : List Operand := []
  callerLocation : Option CallerLoc := none
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive Terminator where
  | goto (bb : BasicBlock)
  /-- `cases`: (value bits, target). -/
  | switchInt (d : Operand) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
  | unwindResume
  | unwindTerminate (r : TerminateReason)
  | «return»
  | unreachable
  /-- D19: `glue` is the resolved `drop_in_place::<T>` instance (`none`: nothing to drop). -/
  | drop (p : MPlace) (glue : Option InstanceId) (target : BasicBlock) (unwind : UnwindAction)
  | call (f : Callee) (args : List Operand) (dest : MPlace) (target : Option BasicBlock)
      (unwind : UnwindAction) (callerLocation : Option CallerLoc := none)
      (abi : Option FnAbiSummary := none)
  | tailCall (f : Callee) (args : List Operand) (callerLocation : Option CallerLoc := none)
      (abi : Option FnAbiSummary := none)
  | assert (cond : Operand) (expected : Bool) (msg : AssertMessage) (target : BasicBlock)
      (unwind : UnwindAction)
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure BlockData where
  stmts : List Statement := []
  term : Terminator
  isCleanup : Bool := false
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure Body where
  /-- `_0` first, then the arguments, then the other locals. -/
  locals : Array Ty
  argCount : Nat
  /-- rustc `spread_arg` (`rust-call` bodies): the tuple local the trailing arguments go to. -/
  spreadArg : Option Local := none
  /-- `#[track_caller]`: receives a hidden `&'static Location` (D14). -/
  trackCaller : Bool := false
  /-- The callee's ABI (D14). `none`: only the structural checks apply. -/
  abi : Option FnAbiSummary := none
  blocks : Array BlockData
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

-- [D7] [D22] [D29]
inductive GlobalKind where
  /-- A `static`; `mutable` for `static mut` and statics with interior mutability. -/
  | static (mutable : Bool)
  /-- A constant allocation (promoteds, `ConstValue::{Slice, Indirect}` data): no unique
  address, read-only (D7). -/
  | const
  /-- A vtable allocation (D29), read-only, no unique address. -/
  | vtable (traitName : Option TraitName)
  /-- A `#[thread_local]` static (D22). -/
  | threadLocal
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- A pointer stored in a global's bytes (rustc relocation / provenance entry). -/
structure Relocation where
  offset : Nat
  target : GlobalRef
  /-- Offset into the target. -/
  addend : Nat := 0
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure Global where
  /-- `none` = uninitialized byte. Relocation positions are overwritten by the pointer. -/
  bytes : List (Option UInt8)
  relocs : List Relocation := []
  align : Align
  kind : GlobalKind
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- A type argument of an intrinsic instance (R30). -/
structure TyArg where
  /-- The type, except that `Box<T, A>` (anywhere inside) is the tuple `(PtrType.box, A)`
  (MiniRust's `Box`): `assert_zero_valid` & co. read Box-ness (rustc `builtin_deref`), which
  the struct `Box` of place types does not show. Only the validity checks read it. -/
  ty : Ty
  /-- rustc's printed name (`with_no_visible_paths!(with_no_trimmed_paths!(..))`), which
  cg_ssa `codegen_panic_intrinsic` puts into the panic message. -/
  name : String
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

inductive InstanceKind where
  /-- A function body in the program. -/
  | body (b : Body)
  /-- Not in the program: an external call (mir-spec §A.6). -/
  | ext
  /-- A rustc intrinsic handled by the spec (D20), with the instance's generic arguments
  (rustc `Instance::args`): types, `none` for lifetimes and constants. -/
  | intrinsic (name : String) (tyArgs : List (Option TyArg) := [])
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure Instance where
  symbol : String
  kind : InstanceKind
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

/-- Lang items the semantics calls on its own (D18). -/
structure LangItems where
  panicCannotUnwind : Option InstanceId := none
  panicInCleanup : Option InstanceId := none
  /-- `panic_nounwind`, called by `assert_inhabited` & co. (R30). -/
  panicNounwind : Option InstanceId := none
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

structure Program where
  instances : Array Instance
  globals : Array Global := #[]
  start : InstanceId
  langItems : LangItems := {}
deriving Repr, DecidableEq, Inhabited, ToJson, FromJson

namespace Program

def body? (p : Program) (i : InstanceId) : Option Body :=
  match p.instances[i]? with
  | some ⟨_, .body b⟩ => some b
  | _ => none

def symbol (p : Program) (i : InstanceId) : String :=
  (p.instances[i]?.map (·.symbol)).getD s!"<instance {i}>"

end Program

end Ryo.Spec
