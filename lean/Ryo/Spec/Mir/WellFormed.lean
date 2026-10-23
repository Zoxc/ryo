/-
Ryo.Spec.Mir.WellFormed — static well-formedness of MIR programs.

Ports: MiniRust `lang/well-formed.md` (the expression/statement/terminator/function/program
part: `check_wf` for `PlaceExpr`, `ValueExpr`, `Statement`, `Terminator`, `Function`,
`Program`), checked on MIR instead (D1), in the spirit of rustc's MIR validator
(`rustc_mir_transform/src/validate.rs`).

Checked:
- every local type is well-formed (`Ty.wf`) and sized; `argCount`, `spreadArg` in range;
- local, block, instance and global indices are in range;
- place projections type-check (deref of pointers, fields in range, index locals of type
  `usize`, downcasts in range);
- `SwitchInt` operands are integers, `bool` or `char`;
- cleanup-block discipline: unwind edges go to cleanup blocks, normal edges stay within the
  same kind of block (cleanup → cleanup, normal → normal), `UnwindResume` only in cleanup
  blocks, and calls in cleanup blocks do not use `UnwindAction::{Continue, Cleanup}`;
- D9 needs no check (`always_storage_live_locals` is computed from the body).
Not (yet) checked: the full typing of rvalues against their destination (subtyping and
layout-equivalent types make an equality check too strict).
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

def checkRvalue (b : Body) : Rvalue → WfM Unit
  | .use o | .repeat o _ | .cast _ o _ | .unaryOp _ o | .wrapUnsafeBinder o _ => do
    let _ ← operandTy b o
  | .ref _ p | .rawPtr _ p | .discriminant p | .copyForDeref p | .reborrow _ _ p => do
    let _ ← placeTy b p
  | .threadLocalRef _ => pure ()
  | .binaryOp _ x y => do
    let _ ← operandTy b x
    let _ ← operandTy b y
  | .aggregate _ ops => ops.forM fun o => do let _ ← operandTy b o

def checkStatement (b : Body) : Statement → WfM Unit
  | .assign p rv => do
    let t ← placeTy b p
    ensure t.isSized "Assign to an unsized place"
    checkRvalue b rv
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
  | .call f args dest target unwind _ _ => do
    match f with
    | .inst i => ensure (i < nInst) "Call: instance out of range"
    | .fnPtr o => do let _ ← operandTy b o
    | .virtual _ => ensure (!args.isEmpty) "virtual call without a receiver"
    args.forM fun o => do let _ ← operandTy b o
    let _ ← placeTy b dest
    if let some t := target then edge b cleanup t
    unwindEdge b cleanup unwind
  | .tailCall f args _ _ => do
    match f with
    | .inst i => ensure (i < nInst) "TailCall: instance out of range"
    | .fnPtr o => do let _ ← operandTy b o
    | .virtual _ => pure ()
    args.forM fun o => do let _ ← operandTy b o
  | .assert c _ msg target unwind => do
    match ← operandTy b c with
    | .bool => pure ()
    | _ => throw "Assert on a non-bool"
    ensure (msg.panicFn < nInst) "Assert: panic function out of range"
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
