/-
Ryo.Spec.Mir.Operand — operands, constants, globals, function addresses.

Ports: MiniRust `lang/step/expressions.md` § Constants (`eval_constant`), § Load
(`ValueExpr::Load`), and the global/function allocation part of `lang/machine.md`
(`Machine::new`: allocating and filling globals with relocations, function pointers).

Divergences:
- D6: a function's address is a daemonic choice per reification (`Choice.fnAddr`): an existing
  copy or a fresh zero-size `function` allocation. Function pointers are mapped back to
  instances through their provenance (`State.fnAllocs`).
- D7: constant and vtable allocations are instantiated on demand; each evaluation picks a
  copy (`Choice.constCopy`). Statics have one (lazily created) allocation. Constants, vtables
  and statics without interior mutability are read-only.
- D12: `Move` operands are `Copy` (in call arguments they are handled by `Ryo.Spec.Mir.Call`).
- D23: `RuntimeChecks` evaluate to their recorded value.
- D24: pointers to `GlobalAlloc::TypeId` have no provenance; the address is the offset.
- Constants are evaluated by encoding their bytes and decoding at the operand's type, so
  scalar constants of `repr(transparent)`-like wrapper types work as rustc's `Scalar` does.
-/
import Ryo.Spec.Mir.Place

namespace Ryo.Spec.Sem

open SemM

def global? (g : GlobalId) : SemM Global := do
  match (← prog).globals[g]? with
  | some gl => pure gl
  | none => throwIllFormed s!"global {g} out of range"

-- [D6]
/-- D6: a pointer to function `i`. -/
def fnPointer (i : InstanceId) : SemM ThinPointer := do
  let s ← get
  let existing := s.fnCopies.getD i []
  let k ← choose (.fnAddr i existing.length)
  match existing[k]? with
  | some p => pure p
  | none => do
    let (p, mem) ← (← getMem).allocate .function 0 .one (mutable := false)
    setMem mem
    modify fun s =>
      let copies := if s.fnCopies.size ≤ i then
        s.fnCopies ++ Array.replicate (i + 1 - s.fnCopies.size) [] else s.fnCopies
      { s with
        fnCopies := copies.set! i (existing ++ [p])
        fnAllocs := match p.prov with
          | some id => s.fnAllocs.insert id i
          | none => s.fnAllocs }
    pure p

/-- The instance a function pointer points to (`fn_from_ptr`): its provenance must be a
function allocation and the address its start. -/
def instOfFnPtr (p : Pointer) : SemM InstanceId := do
  if p.metadata.isSome then throwUb "invalid pointer for function lookup"
  let some id := p.thin.prov | throwUb "invalid pointer for function lookup"
  let some i := (← get).fnAllocs.get? id | throwUb "invalid pointer for function lookup"
  let some a := (← getMem).get? id | throwUb "invalid pointer for function lookup"
  if a.addr != p.thin.addr then throwUb "invalid pointer for function lookup"
  pure i

def allocKindOf : GlobalKind → AllocationKind
  | .static _ => .static
  | .const => .const
  | .vtable _ => .vtable
  | .threadLocal => .threadLocal

def _root_.Ryo.Spec.GlobalKind.mutable : GlobalKind → Bool
  | .static m => m
  | .threadLocal => true
  | _ => false

def recordStatic (g : GlobalId) (p : ThinPointer) : SemM Unit :=
  modify fun s =>
    let arr := if s.statics.size ≤ g then
      s.statics ++ Array.replicate (g + 1 - s.statics.size) none else s.statics
    { s with statics := arr.set! g (some p) }

def recordConstCopy (g : GlobalId) (p : ThinPointer) : SemM Unit :=
  modify fun s =>
    let arr := if s.constCopies.size ≤ g then
      s.constCopies ++ Array.replicate (g + 1 - s.constCopies.size) [] else s.constCopies
    { s with constCopies := arr.set! g (arr[g]! ++ [p]) }

-- [D7]
/-- A pointer to global `g` (D7): the static's allocation, or a copy of a constant. `fuel`
bounds the nesting of relocations. -/
def globalPtrF : Nat → GlobalId → SemM ThinPointer
  | 0, _ => throwIllFormed "constant relocations nested too deeply"
  | fuel + 1, g => do
    let gl ← global? g
    let s ← get
    let reuse : Option ThinPointer ← match gl.kind with
      | .static _ | .threadLocal => pure (s.statics.getD g none)
      | .const | .vtable _ => do
        let existing := s.constCopies.getD g []
        let k ← choose (.constCopy g existing.length)
        pure existing[k]?
    match reuse with
    | some p => pure p
    | none => do
      let (p, mem) ← (← getMem).allocate (allocKindOf gl.kind) gl.bytes.length gl.align
        (mutable := gl.kind.mutable)
      setMem mem
      match gl.kind with
      | .static _ | .threadLocal => recordStatic g p
      | _ => recordConstCopy g p
      let mut bytes : List AbstractByte :=
        gl.bytes.map fun | some b => .init b none | none => .uninit
      for r in gl.relocs do
        let tgt ← match r.target with
          | .alloc g' => globalPtrF fuel g'
          | .fn i => fnPointer i
          | .typeId => pure ThinPointer.null
        bytes := writeAt bytes r.offset (encodePtr (tgt.wrappingOffset r.addend))
      setMem ((← getMem).writeInit p bytes)
      pure p

def globalPtr (g : GlobalId) : SemM ThinPointer := do
  globalPtrF ((← prog).globals.size + 1) g

-- [D24]
/-- Resolve what a pointer constant points to. -/
def resolveRef (r : GlobalRef) (offset : Nat) : SemM ThinPointer := do
  match r with
  | .alloc g => pure ((← globalPtr g).wrappingOffset offset)
  | .fn i => pure ((← fnPointer i).wrappingOffset offset)
  | .typeId => pure ⟨offset, none⟩  -- D24

/-- Decode constant bytes at a type. -/
def decodeConst (bytes : List AbstractByte) (ty : Ty) : SemM Value := do
  match ty.decode bytes with
  | some v => do liftE (checkValue (← getMem) v ty); pure v
  | none => throwIllFormed "constant is not valid at its type"

/-- `eval_constant`. -/
def evalConst (c : ConstOperand) (ty : Ty) : SemM Value := do
  match c with
  | .scalar bits => decodeConst (encodeBits ty.size bits) ty
  | .ptr r off => decodeConst (encodePtr (← resolveRef r off)) ty
  | .zeroSized => decodeConst [] ty
  | .slice g len => do
    let p ← globalPtr g
    decodeConst (encodePtr p ++ encodeBits 8 len) ty
  | .indirect g off => do
    let p ← globalPtr g
    liftE (typedLoad (← getMem) (p.wrappingOffset off) ty .one)

-- [D12] [D23]
/-- Evaluate an operand to a value and its type. -/
def evalOperand : Operand → SemM (Value × Ty)
  | .copy p | .move p => do
    let (pl, ty) ← evalPlace p
    pure (← placeLoad pl ty, ty)
  | .const c ty => do pure (← evalConst c ty, ty)
  | .runtimeChecks _ b => pure (.bool b, .bool)

end Ryo.Spec.Sem
