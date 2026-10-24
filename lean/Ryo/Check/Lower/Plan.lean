/-
Ryo.Check.Lower.Plan — where the platform calling convention puts a signature's inputs and
how it returns its value, recomputed from the dumped ABI (`FnAbiSummary`): a port of
`backend/src/rustc_api/lower/sig.rs`'s `ArgLoc`, `ArgPlan`, `arg_plan` and `ret_kind`.

The dump gives each argument's `PassMode` kind and, for a `Direct` scalar, a `Pair` and an
integer `Cast` without prefix, its LLVM-level scalars (`ArgAbi.scalars`: class, size, offset),
which is all `arg_plan` reads of the layout. The lowering check (`CertCheck.lean`) compares
these with the certificate's plans; a mode the backend leaves native (`NeedsNative`) is an
error here (`Except.error` with `sig.rs`'s reason).
-/
import Ryo.Spec
import Ryo.Check.Image.Common

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm.Asm

/-- `sig::ArgLoc`: where a piece of an ABI input goes. -/
inductive ArgLoc
  /-- The `reg.size` bytes at `off` of the value, in an argument register (`reg.index` its
  position among its class's argument registers; on PE, the argument's position). -/
  | reg (reg : ArgReg) (off : Nat)
  /-- The `size` bytes at `off` of the value, `at_` bytes into the stack argument area. -/
  | stack (at_ off size : Nat)
  /-- An `Indirect` input: a pointer to the value, in an integer argument register. -/
  | ptrReg (index : Nat)
  /-- The same, on the stack. -/
  | ptrStack (at_ : Nat)
deriving DecidableEq, Repr, Inhabited

/-- `sig::ArgPlan`: per input its pieces, and the size of the stack argument area (a multiple
of 16, on PE at least the 32 bytes of shadow space). -/
structure ArgPlan where
  locs : List (List ArgLoc)
  stackSize : Nat
deriving DecidableEq, Repr, Inhabited

def ArgLoc.text : ArgLoc → String
  | .reg r off => s!"{if r.xmm then "xmm" else "gpr"}{r.index}:{r.size}@{off}"
  | .stack at_ off size => s!"stack{at_}:{size}@{off}"
  | .ptrReg i => s!"ptr gpr{i}"
  | .ptrStack at_ => s!"ptr stack{at_}"

def ArgPlan.text (p : ArgPlan) : String :=
  s!"stack {p.stackSize} [{", ".intercalate (p.locs.map fun ls => "[" ++ ", ".intercalate (ls.map (·.text)) ++ "]")}]"

/-- `n` rounded up to a multiple of `m` (`next_multiple_of`). -/
def roundUp (n m : Nat) : Nat := (n + m - 1) / m * m

/-- `arg_plan`'s `State`. -/
structure PlanState where
  pe : Bool
  gpr : Nat := 0
  xmm : Nat := 0
  /-- PE: the next position. -/
  pos : Nat := 0
  stack : Nat := 0

abbrev PlanM := StateT PlanState (Except String)

namespace PlanM

/-- `State::stack`: a slot of `size` bytes (8 or 16) in the stack area. -/
def slot (size : Nat) : PlanM Nat := modifyGet fun st =>
  let at_ := roundUp st.stack (if size == 16 && !st.pe then 16 else 8)
  (at_, { st with stack := at_ + roundUp size 8 })

/-- `State::int`: an integer of `size` bytes (1 to 8, or 16 for `i128` on SysV) at `off`. -/
def int (size off : Nat) : PlanM (List ArgLoc) := do
  let st ← get
  if st.pe then
    if size > 8 then throw "i128 argument on Win64"
    let l ← if st.pos < 4 then pure (ArgLoc.reg ⟨false, size, st.pos⟩ off)
      else do pure (.stack (← slot 8) off size)
    modify fun s => { s with pos := s.pos + 1 }
    return [l]
  else if size == 16 then
    if st.gpr ≤ 4 then
      set { st with gpr := st.gpr + 2 }
      return [.reg ⟨false, 8, st.gpr⟩ off, .reg ⟨false, 8, st.gpr + 1⟩ (off + 8)]
    else do return [.stack (← slot 16) off 16]
  else if st.gpr < 6 then
    set { st with gpr := st.gpr + 1 }
    return [.reg ⟨false, size, st.gpr⟩ off]
  else do return [.stack (← slot 8) off size]

/-- `State::float`: a float of `size` bytes at `off`. -/
def float (size off : Nat) : PlanM (List ArgLoc) := do
  let st ← get
  if st.pe then
    if size != 4 && size != 8 then throw "f16 or f128 argument on Win64"
    let l ← if st.pos < 4 then pure (ArgLoc.reg ⟨true, size, st.pos⟩ off)
      else do pure (.stack (← slot 8) off size)
    modify fun s => { s with pos := s.pos + 1 }
    return [l]
  else if st.xmm < 8 then
    set { st with xmm := st.xmm + 1 }
    return [.reg ⟨true, size, st.xmm⟩ off]
  else do return [.stack (← slot (max size 8)) off size]

/-- `State::ptr`: an `Indirect` input's pointer. -/
def ptr : PlanM (List ArgLoc) := do
  let st ← get
  let reg := if st.pe then (if st.pos < 4 then some st.pos else none)
    else if st.gpr < 6 then some st.gpr else none
  let l ← match reg with
    | some i => pure (ArgLoc.ptrReg i)
    | none => do pure (.ptrStack (← slot 8))
  if st.pe then modify fun s => { s with pos := s.pos + 1 }
  else if reg.isSome then modify fun s => { s with gpr := s.gpr + 1 }
  return [l]

def scalar (s : AbiScalar) : PlanM (List ArgLoc) :=
  if s.float then float s.size s.off else int s.size s.off

end PlanM

/-- The scalars of a `Cast` the plan takes: the Rust ABI's integer for an aggregate of up to
8 bytes (`cast.rest.total ≤ 8`; the dumper has checked the rest of `arg_plan`'s guard). -/
def castScalar? (a : ArgAbi) : Option AbiScalar :=
  match a.scalars with
  | some [s] => if !s.float && s.size ≤ 8 && s.off == 0 then some s else none
  | _ => none

/-- `arg_plan`: the assignment of `abi`'s inputs to argument registers and the stack, on
SysV or (`pe`) Win64; `sret` makes the return pointer take the first integer register. -/
def argPlan (pe : Bool) (abi : FnAbiSummary) (sret : Bool) : Except String ArgPlan := do
  let st : PlanState := { pe, stack := if pe then 32 else 0, gpr := if sret then 1 else 0,
                          pos := if sret then 1 else 0 }
  let (locs, st) ← (abi.args.mapM fun (a : ArgAbi) => do
    match a.mode, a.scalars with
    | .ignore, _ => pure []
    | .direct, some [s] => PlanM.scalar s
    | .pair, some [x, y] => do return (← PlanM.scalar x) ++ (← PlanM.scalar y)
    | .cast, _ => match castScalar? a with
      | some s => PlanM.int s.size 0
      | none => throw s!"argument passed as Cast {a.detail}"
    | .indirect, _ =>
      if a.detail == "" then PlanM.ptr else throw s!"argument passed as Indirect {a.detail}"
    | m, _ => throw s!"argument passed as {repr m} ({a.detail})").run st
  return { locs, stackSize := roundUp st.stack 16 }

/-- `ret_kind`: how a VM function of this signature returns its value (`asm::ret_kind`'s
encoding, `RET_SRET` for an `Indirect` return). -/
def retKindOf (pe : Bool) (ret : ArgAbi) : Except String Nat := do
  let scalar (s : AbiScalar) : Except String (List RetPart) := do
    if pe && (s.size == 16 || s.size == 2 && s.float) then throw "i128, f16 or f128 return on Win64"
    if s.float then return [⟨true, s.size, s.off⟩]
    if s.size == 16 then return [⟨false, 8, s.off⟩, ⟨false, 8, s.off + 8⟩]
    return [⟨false, s.size, s.off⟩]
  let parts ← match ret.mode, ret.scalars with
    | .ignore, _ => pure []
    | .direct, some [s] => scalar s
    | .pair, some [a, b] => do pure ((← scalar a) ++ (← scalar b))
    | .cast, _ => match castScalar? ret with
      | some s => pure [⟨false, s.size, 0⟩]
      | none => throw s!"return passed as Cast {ret.detail}"
    | .indirect, _ | .indirectUnsized, _ => pure []
    | m, _ => throw s!"return passed as {repr m} ({ret.detail})"
  if ret.mode matches .indirect | .indirectUnsized then return Ryo.Check.Image.RET_SRET
  if parts.length > 2 then throw "return value in more than two registers"
  return retKind parts

/-- `from_fn_abi`'s return kind and plan of a Rust-ABI signature. -/
def sigOf (pe : Bool) (abi : FnAbiSummary) : Except String (Nat × ArgPlan) := do
  unless abi.conv matches .rust | .rustCall do throw s!"{repr abi.conv} ABI"
  if abi.ret.align.bytes > 16 then throw "return value aligned above 16"
  let k ← retKindOf pe abi.ret
  return (k, ← argPlan pe abi (k == Ryo.Check.Image.RET_SRET))

end Ryo.Check.Lower
