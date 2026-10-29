/-
Ryo.Spec.Mir.Call — calls: argument passing, frame creation, ABI checks.

Ports: MiniRust `lang/step/terminators.md` § Call (`check_abi_compatibility`,
`prepare_for_inplace_passing`, `eval_argument`, `create_frame`, `eval_call`) and the frame
part of § Return (deallocating locals).

Divergences:
- D9: at frame creation, besides `_0` and the arguments, every local without
  `StorageLive`/`StorageDead` statements is allocated (rustc `always_storage_live_locals`).
- D12: `Move` arguments are passed in place: the callee's argument local *is* the caller's
  place (which must be aligned and dereferenceable at the callee's type); the caller's place is
  `Uninit` after the call. The return place is passed in place too: the caller's destination
  is de-initialized at the call and the callee writes its `_0` there (Miri's return place).
- D14: ABI compatibility follows rustc's documented rules as Miri implements them
  (`check_argument_compat`): equal types; 1-ZSTs; `repr(transparent)`-like wrappers unfolded;
  `Option<&T>`-like enums as their pointer; integers of the same size *and* signedness;
  `char` ~ `u32`; pointers with the same metadata kind. If both sides have a `FnAbiSummary`,
  those must agree too. `rust-call`: the caller's last argument (a tuple) is spread; a callee
  with `spread_arg` gathers trailing arguments back into a tuple. `#[track_caller]` bodies get
  the caller location (hidden argument).
- D15: arguments are validated at the callee's types on entry (LLVM `noundef`, `nonnull`,
  `align`, `dereferenceable`, `range` argument attributes).
- D25: pushing a frame beyond `State.maxDepth` is `stackOverflow`.
-/
import Ryo.Spec.Mir.Statement

namespace Ryo.Spec.Sem

open SemM

/-! ## ABI compatibility (D14) -/

def _root_.Ryo.Spec.Ty.is1Zst (t : Ty) : Bool := t.isSized && t.size == 0 && t.align == .one

/-- Unfold wrappers that are ABI-transparent: structs whose only non-1-ZST field covers the
whole struct, and `Option<&T>`-like enums (nullable pointer optimization). -/
def unfoldTransparent : Nat → Ty → Ty
  | 0, t => t
  | fuel + 1, t =>
    match t with
    | .tuple fields head none =>
      match fields.filter (fun (_, ft) => !Ty.is1Zst ft) with
      | [(0, ft)] =>
        if ft.size == head.headSizeAndAlign.1 && ft.align == head.align then
          unfoldTransparent fuel ft
        else t
      | _ => t
    | .enum [v0, v1] _ (.multiple ⟨_, _, _, .niche _ _ _ 0⟩) size _ =>
      let payload (v : Variant) : Option Ty :=
        match v.fields with
        | .tuple fs _ none =>
          match fs.filter (fun (_, ft) => !Ty.is1Zst ft) with
          | [(0, ft)] => some ft
          | [] => none
          | _ => none
        | _ => none
      let p := match payload v0, payload v1 with
        | some a, none => some a
        | none, some b => some b
        | _, _ => none
      match p with
      | some pt =>
        match unfoldTransparent fuel pt with
        | .ptr k _ => if size == 8 then .ptr k (ValidRange.full 8) else t
        | _ => t
      | none => t
    | _ => t

-- [D14]
/-- Are a caller's and a callee's view of an argument (or return) type compatible? -/
def abiCompatible (caller callee : Ty) : Bool :=
  caller == callee || (caller.is1Zst && callee.is1Zst) ||
    match unfoldTransparent 16 caller, unfoldTransparent 16 callee with
    | .int a _, .int b _ => a == b
    | .char, .int b _ => b == IntType.u32
    | .int a _, .char => a == IntType.u32
    | .char, .char | .bool, .bool => true
    | .float a, .float b => a == b
    | .ptr a _, .ptr b _ => a.metaKind == b.metaKind
    | a, b => a == b

def argAbiCompatible (a b : ArgAbi) : Bool :=
  a.mode == b.mode && a.size == b.size && a.align == b.align && a.detail == b.detail

/-- `Rust` and `rust-call` are the same calling convention (rustc `CanonAbi::Rust`); they only
differ in how the caller's MIR arguments map to the ABI's. -/
def _root_.Ryo.Spec.CallConv.canon : CallConv → CallConv
  | .rustCall => .rust
  | cc => cc

/-- Ignored (`PassMode::Ignore`, zero-sized) arguments are not passed at all, so they don't
take part (rustc's ABI-compatibility rules; Miri's `check_argument_compat` skips them). -/
def fnAbiCompatible (a b : FnAbiSummary) : Bool :=
  let live (as : List ArgAbi) := as.filter (·.mode != .ignore)
  a.conv.canon == b.conv.canon && (live a.args).length == (live b.args).length &&
    argAbiCompatible a.ret b.ret &&
    ((live a.args).zip (live b.args)).all fun (x, y) => argAbiCompatible x y

/-! ## Arguments -/

/-- An evaluated argument: value, caller type, and the place for in-place (`Move`) passing. -/
structure ArgVal where
  val : Value
  ty : Ty
  inPlace : Option Place := none
deriving Inhabited

-- [D12]
/-- `eval_argument` (D12: `Move` operands are passed in place). -/
def evalArg : Operand → SemM ArgVal
  | .move p => do
    let (pl, ty) ← evalPlace p
    let v ← placeLoad pl ty
    pure ⟨v, ty, some pl⟩
  | o => do
    let (v, ty) ← evalOperand o
    pure ⟨v, ty, none⟩

/-- `rust-call`: spread the last argument (a tuple) into its fields (D14). -/
def untupleLast (args : List ArgVal) : SemM (List ArgVal) := do
  match args.getLast? with
  | some ⟨.tuple vs, .tuple fields _ none, _⟩ =>
    if vs.length != fields.length then throwIllFormed "rust-call: tuple arity mismatch"
    pure (args.dropLast ++ (vs.zip fields).map fun (v, (_, t)) => ⟨v, t, none⟩)
  | some _ => throwIllFormed "rust-call: last argument is not a tuple"
  | none => throwIllFormed "rust-call: no arguments"

/-! ## Frames -/

/-- Locals mentioned by a `StorageLive`/`StorageDead` statement. -/
def _root_.Ryo.Spec.Body.storageLocals (b : Body) : List Local :=
  b.blocks.toList.flatMap fun bd => bd.stmts.filterMap fun
    | .storageLive l | .storageDead l => some l
    | _ => none

/-- Allocate a fresh stack slot for a local of type `ty`. -/
def allocSlot (ty : Ty) : SemM ThinPointer := do
  let some size := ty.size? | throwIllFormed "unsized local"
  let (p, mem) ← (← getMem).allocate .stack size ty.align
  setMem mem
  pure p

-- [D9] [D12] [D14] [D15]
/-- `create_frame`: allocate locals, pass arguments, check ABIs, validate arguments. -/
def createFrame (inst : InstanceId) (body : Body) (cont : Cont) (args : List ArgVal)
    (retPlace : Option (Place × Ty)) (callerLoc : Option Value)
    (callerAbi : Option FnAbiSummary) : SemM Frame := do
  let n := body.locals.size
  if n == 0 then throwIllFormed "body without a return local"
  let mut locals : Array (Option ThinPointer) := Array.replicate n none
  let mut aliased : List Local := []
  -- D14: FnAbi summaries
  if let (some ca, some cb) := (callerAbi, body.abi) then
    if !fnAbiCompatible ca cb then throwUb "call ABI violation: function ABIs are not compatible"
  -- the return place
  let retTy := body.locals[0]!
  match retPlace with
  | some (pl, callerRetTy) =>
    if !abiCompatible callerRetTy retTy then
      throwUb "call ABI violation: return types are not compatible"
    -- D12: in place; the caller's destination was de-initialized by the caller.
    if !retTy.align.isAligned pl.ptr.thin.addr then
      throwUb "call: return place is misaligned for the callee's return type"
    liftE ((← getMem).dereferenceable pl.ptr.thin retTy.size)
    locals := locals.set! 0 (some pl.ptr.thin)
    aliased := [0]
  | none =>
    locals := locals.set! 0 (some (← allocSlot retTy))
  -- arguments (D14: spread for `rust-call` callees). When both sides' ABIs are known,
  -- arguments passed as `PassMode::Ignore` (ZSTs) are skipped on either side, as Miri's
  -- `pass_argument` does: a closure's environment is not passed through a fn pointer to its
  -- `FnOnce` shim, for instance.
  let argLocals := (List.range body.argCount).map (· + 1)
  let useIgnore := callerAbi.isSome && body.abi.isSome
  let ignored (abi : Option FnAbiSummary) (k : Nat) : Bool :=
    useIgnore && ((abi.bind (·.args[k]?)).map (·.mode == .ignore)).getD false
  let args := (args.zipIdx.filter fun (_, k) => !ignored callerAbi k).map (·.1)
  -- the callee's ABI inputs: argument locals, the spread tuple's fields in its place
  let slots : List (Local × Option (Offset × Ty)) := argLocals.flatMap fun l =>
    if body.spreadArg == some l then
      match body.locals[l]! with
      | .tuple fields _ none => fields.map fun f => (l, some f)
      | _ => [(l, none)]
    else [(l, none)]
  let slotsIgn := slots.zipIdx.map fun (sl, k) => (sl, ignored body.abi k)
  let fed := (slotsIgn.filter (!·.2)).map (·.1)
  if fed.length != args.length then
    throwUb "call ABI violation: number of arguments does not agree"
  if let some sl := body.spreadArg then
    let sty := body.locals[sl]!
    let .tuple _ _ none := sty | throwIllFormed "spread_arg is not a tuple"
    locals := locals.set! sl (some (← allocSlot sty))
  for ((l, field), a) in fed.zip args do
    match field with
    | some (off, fty) =>
      if !abiCompatible a.ty fty then
        throwUb "call ABI violation: argument types are not compatible"
      let some p := locals[l]! | throwIllFormed "spread_arg without a slot"
      memUpdate (typedStore · (p.wrappingOffset off) a.val a.ty .one)
    | none =>
      let lty := body.locals[l]!
      if !abiCompatible a.ty lty then
        throwUb "call ABI violation: argument types are not compatible"
      match a.inPlace with
      | some pl =>
        if !lty.align.isAligned pl.ptr.thin.addr then
          throwUb "call: in-place argument is misaligned for the callee's type"
        liftE ((← getMem).dereferenceable pl.ptr.thin lty.size)
        locals := locals.set! l (some pl.ptr.thin)
        aliased := l :: aliased
      | none =>
        let p ← allocSlot lty
        memUpdate (typedStore · p a.val a.ty a.ty.align)
        locals := locals.set! l (some p)
  -- ignored (zero-sized) argument locals get a slot with nothing in it
  for ((l, field), ign) in slotsIgn do
    if ign && field.isNone then
      locals := locals.set! l (some (← allocSlot body.locals[l]!))
  -- D9: always-live locals
  let storage := body.storageLocals
  for l in List.range n do
    if l > body.argCount && locals[l]!.isNone && !storage.contains l then
      locals := locals.set! l (some (← allocSlot body.locals[l]!))
  -- D15: validate the arguments at the callee's types
  for l in argLocals do
    if let some p := locals[l]! then
      let _ ← liftE (typedLoad (← getMem) p body.locals[l]! .one)
  -- D14: track_caller
  let callerLocation := if body.trackCaller then callerLoc else none
  if body.trackCaller && callerLocation.isNone then
    throwIllFormed "#[track_caller] callee without a caller location"
  pure { inst, body, locals, aliased, cont, callerLocation }

-- [D25]
/-- Push a frame (D25: bounded depth). -/
def pushFrame (f : Frame) : SemM Unit := do
  let s ← get
  if s.stack.length ≥ s.maxDepth then throw .stackOverflow
  set { s with stack := f :: s.stack }

/-- Call a body: create its frame and make it active. -/
def callBody (inst : InstanceId) (body : Body) (cont : Cont) (args : List ArgVal)
    (retPlace : Option (Place × Ty)) (callerLoc : Option Value)
    (callerAbi : Option FnAbiSummary) : SemM Unit := do
  pushFrame (← createFrame inst body cont args retPlace callerLoc callerAbi)

/-- Pop the active frame, deallocating its (non-aliased) live locals. -/
def popFrame : SemM Frame := do
  let f ← curFrame
  for (slot, l) in f.locals.toList.zipIdx do
    if let some p := slot then
      if !f.aliased.contains l then
        let ty ← localTy f l
        memUpdate (·.deallocate p .stack ty.size ty.align)
  modify fun s => { s with stack := s.stack.drop 1 }
  pure f

end Ryo.Spec.Sem
