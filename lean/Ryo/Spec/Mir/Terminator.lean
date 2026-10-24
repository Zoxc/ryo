/-
Ryo.Spec.Mir.Terminator — terminators.

Ports: MiniRust `lang/step/terminators.md` (`Goto`, `Switch`, `Unreachable`, `Call`,
`Return`, `Intrinsic`), dispatching to `Ryo.Spec.Mir.Call` and `Ryo.Spec.Mir.Unwind`.

Divergences:
- D1: rustc's terminators: `SwitchInt` compares the operand's bits against the targets'
  values; `UnwindResume`/`UnwindTerminate` (D18); `TailCall`.
- D12: call operands are evaluated callee first, then arguments, then the destination (Miri);
  the destination is de-initialized while the call runs and receives the return value.
- D15: the return value is validated at the callee's return type on `Return`.
- D19: `Drop` calls the drop-glue instance with a pointer to the place (wide for unsized
  places), or does nothing without glue. A failed `Assert` calls the assert kind's panic lang
  item with its operands (and caller location); the call must not return.
- D29: `Callee.virtual idx` loads entry `idx` of the vtable of the first argument (the wide
  pointer found by descending into the non-1-ZST field of the receiver, as cg_ssa does) and
  calls it with the receiver's data pointer.
- Tail calls replace the current frame; the callee must be a body (external and intrinsic tail
  calls are ill-formed here), and arguments are passed by value.
-/
import Ryo.Spec.Mir.Intrinsics

namespace Ryo.Spec.Sem

open SemM

/-- The caller-location value passed to a `#[track_caller]` callee (D14). -/
def evalCallerLoc : Option CallerLoc → SemM (Option Value)
  | none => pure none
  | some (.const c ty) => do pure (some (← evalConst c ty))
  | some .inherit => do pure (← curFrame).callerLocation

-- [D29]
/-- D29: split a receiver into its vtable and the receiver with the data pointer only. -/
def splitReceiver : Nat → Value → Ty → SemM (ThinPointer × Value × Ty)
  | 0, _, _ => throwIllFormed "virtual call: receiver nested too deeply"
  | fuel + 1, v, ty =>
    match v, ty with
    | .ptr p, .ptr pt valid =>
      match p.metadata with
      | some (.vtablePointer vt) =>
        let thinTy : PtrType := match pt with
          | .ref m _ => .ref m ⟨.sized 0 .one, true⟩
          | .box _ => .box ⟨.sized 0 .one, true⟩
          | .raw m _ => .raw m ⟨.sized 0 .one, true⟩
          | other => other
        pure (vt, .ptr p.thin.widen, .ptr thinTy valid)
      | _ => throwUb "virtual call: receiver is not a `dyn` pointer"
    | .tuple vs, .tuple fields _ none =>
      match (vs.zip fields).filter (fun (_, (_, t)) => !t.is1Zst) with
      | [(fv, (_, ft))] => splitReceiver fuel fv ft
      | _ => throwIllFormed "virtual call: receiver has no single non-ZST field"
    | _, _ => throwIllFormed "virtual call: invalid receiver"

/-- Resolve the callee to an instance (D6, D29). -/
def resolveCallee (f : Callee) (args : List ArgVal) : SemM (InstanceId × List ArgVal) := do
  match f with
  | .inst i => pure (i, args)
  | .fnPtr o => do
    match (← evalOperand o).1 with
    | .ptr p => pure (← instOfFnPtr p, args)
    | _ => throwIllFormed "call through a non-pointer"
  | .virtual idx => do
    let some a0 := args.head? | throwIllFormed "virtual call without a receiver"
    let (vt, v, ty) ← splitReceiver 16 a0.val a0.ty
    let fp ← vtableWordPtr vt idx
    pure (← instOfFnPtr fp.widen, ⟨v, ty, none⟩ :: args.drop 1)

/-- Does the caller spread a `rust-call` tuple argument? -/
def callerRustCall (abi : Option FnAbiSummary) (callee : Option Body) : Bool :=
  match abi with
  | some a => a.conv == .rustCall
  | none =>
    match callee with
    | some b => b.spreadArg.isSome || (b.abi.map (·.conv == .rustCall)).getD false
    | none => false

/-- Call instance `i`: push a frame for a body, or run an external function or intrinsic and
continue through `cont`. `retPlace = none`: the result is not stored anywhere. -/
def callInstance (i : InstanceId) (args : List ArgVal) (retPlace : Option (Place × Ty))
    (cont : Cont) (callerLoc : Option Value) (abi : Option FnAbiSummary) : SemM Unit := do
  let p ← prog
  let some inst := p.instances[i]? | throwIllFormed s!"instance {i} out of range"
  let storeRet (v : Value) : SemM Unit :=
    match retPlace with
    | some (pl, ty) => placeStore pl v ty
    | none => pure ()
  match inst.kind with
  | .body b => do
    let args ← if callerRustCall abi (some b) then untupleLast args else pure args
    callBody i b cont args retPlace callerLoc abi
  | .ext => do
    match ← callExternal inst.symbol (args.map fun a => (a.val, a.ty)) with
    | .ret v => do storeRet v; contReturn cont
    | .unwind pl => contUnwind cont pl
  | .intrinsic name =>
    match name, args with
    | "abort", _ => throw .abort
    | "unreachable", _ => throwUb "entering unreachable code"
    -- [D14] the call's caller location (cg_ssa `get_caller_location`: the frame's own one,
    -- or a constant where MIR inlining put the call into a non-`#[track_caller]` body)
    | "caller_location", [] =>
      match callerLoc with
      | some v => do storeRet v; contReturn cont
      | none => do
        let destTy := (retPlace.map (·.2)).getD unitTy
        storeRet (← evalIntrinsic name [] destTy)
        contReturn cont
    | "catch_unwind", [tryFn, data, catchFn] => do
      let some (dest, destTy) := retPlace | throwIllFormed "catch_unwind without a destination"
      let (target, unwind) ← match cont with
        | .caller t u _ => pure (t, u)
        | _ => throwIllFormed "catch_unwind outside a call terminator"
      let .ptr tp := tryFn.val | throwIllFormed "catch_unwind: try is not a pointer"
      let ti ← instOfFnPtr tp
      let some tb := p.body? ti | throwIllFormed "catch_unwind: try function has no body"
      let argTy := tb.locals[1]?.getD bytePtrTy
      callBody ti tb (.catchTry data.val catchFn.val dest destTy target unwind)
        [⟨data.val, argTy, none⟩] none none none
    | _, _ => do
      let destTy := (retPlace.map (·.2)).getD unitTy
      let v ← evalIntrinsic name (args.map fun a => (a.val, a.ty)) destTy
      storeRet v
      contReturn cont

-- [D15]
/-- `Return` (D15: validate the return value at the callee's type). -/
def doReturn : SemM Unit := do
  let f ← curFrame
  let retTy ← localTy f 0
  let some (some p) := f.locals[0]? | throwUb "return place is dead"
  let v ← liftE (typedLoad (← getMem) p retTy .one)
  let f ← popFrame
  match f.cont with
  | .bottom => modify fun s => { s with final := some (.returned v) }
  | c => contReturn c

/-- `SwitchInt`: the bits of the discriminant operand. -/
def switchBits : Value × Ty → SemM Nat
  | (.int i, .int t _) => pure (t.toBits i)
  | (.int i, .char) => pure i.toNat
  | (.bool b, _) => pure (if b then 1 else 0)
  | _ => throwIllFormed "SwitchInt on a non-integer"

-- [D12] [D19] [D18]
def evalTerminator : Terminator → SemM Unit
  | .goto bb => jumpTo bb
  | .switchInt d cases otherwise => do
    let bits ← switchBits (← evalOperand d)
    match cases.find? (·.1 == bits) with
    | some (_, bb) => jumpTo bb
    | none => jumpTo otherwise
  | .unwindResume => do
    match (← curFrame).unwinding with
    | some p => unwindOut p
    | none => throwIllFormed "UnwindResume outside a cleanup block"
  | .unwindTerminate r => callTerminate r
  | .return => doReturn
  | .unreachable => throwUb "reached unreachable code"
  | .drop p glue target unwind => do
    let (pl, ty) ← evalPlace p
    -- [D29] a `dyn Trait` place: the vtable's drop entry (word 0) with the data pointer,
    -- nothing if the entry is null (cg_ssa `codegen_drop_terminator`); the glue instance of
    -- `dyn Trait` only drops `*self` again
    if let .traitObject _ := ty then
      let some (.vtablePointer vt) := pl.ptr.metadata
        | throwUb "drop of a `dyn` place without a vtable"
      let fp ← vtableWordPtr vt 0
      if fp.addr == 0 then jumpTo target
      else
        let i ← instOfFnPtr fp.widen
        let argTy := match (← prog).body? i with
          | some b => b.locals[1]?.getD bytePtrTy
          | none => bytePtrTy
        callInstance i [⟨.ptr pl.ptr.thin.widen, argTy, none⟩] none (.caller (some target) unwind [])
          none none
    else
    match glue with
    | none => jumpTo target
    | some i => do
      let argTy := match (← prog).body? i with
        | some b => b.locals[1]?.getD (rawPtrTy ty true)
        | none => rawPtrTy ty true
      callInstance i [⟨.ptr pl.ptr, argTy, none⟩] none (.caller (some target) unwind []) none none
  | .call f args dest target unwind callerLoc abi => do
    let (i, argVals) ← match f with
      | .fnPtr o => do
        -- the callee operand is evaluated before the arguments
        let (cv, _) ← evalOperand o
        let argVals ← args.mapM evalArg
        match cv with
        | .ptr p => pure (← instOfFnPtr p, argVals)
        | _ => throwIllFormed "call through a non-pointer"
      | f => do resolveCallee f (← args.mapM evalArg)
    let (destPl, destTy) ← evalPlace dest
    let loc ← evalCallerLoc callerLoc
    -- D12: the destination is unobservable while the call runs
    memUpdate (·.deinit destPl.ptr.thin destTy.size .one)
    let deinit := argVals.filterMap fun a => a.inPlace.map fun pl => (pl.ptr.thin, a.ty.size)
    callInstance i argVals (some (destPl, destTy)) (.caller target unwind deinit) loc abi
  | .tailCall f args callerLoc abi => do
    let argVals ← args.mapM fun o => do
      let (v, ty) ← evalOperand o
      pure (⟨v, ty, none⟩ : ArgVal)
    let (i, argVals) ← resolveCallee f argVals
    let loc ← evalCallerLoc callerLoc
    let old ← curFrame
    let retTy ← localTy old 0
    let retPlace : Option (Place × Ty) :=
      if old.aliased.contains 0 then
        match old.locals[0]? with
        | some (some p) => some (⟨p.widen, true⟩, retTy)
        | _ => none
      else none
    let some b := (← prog).body? i | throwIllFormed "tail call to a function without a body"
    let _ ← popFrame
    let argVals ← if callerRustCall abi (some b) then untupleLast argVals else pure argVals
    callBody i b old.cont argVals retPlace loc abi
  | .assert cond expected msg target unwind => do
    match (← evalOperand cond).1 with
    | .bool b =>
      if b == expected then jumpTo target
      else do
        let args ← msg.args.mapM fun o => do
          let (v, ty) ← evalOperand o
          pure (⟨v, ty, none⟩ : ArgVal)
        let loc ← evalCallerLoc msg.callerLocation
        callInstance msg.panicFn args none (.caller none unwind []) loc none
    | _ => throwIllFormed "Assert on a non-bool"

end Ryo.Spec.Sem
