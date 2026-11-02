/-
Ryo.Check.Lower.Plan — where the platform calling convention puts a signature's inputs and
how it returns its value, recomputed from the dumped ABI (`FnAbiSummary`): a port of
`backend/src/lower/sig.rs`'s `ArgLoc`, `ArgPlan`, `arg_plan`, `cast_pieces` and `ret_kind`,
for the Rust ABI and the C ABI (SysV and Win64, `extern "C"` and `"C-unwind"`).

The dump gives each argument's `PassMode` kind (`detail` `on_stack` for `byval`) and, for a
`Direct` scalar, a `Pair` and a `Cast` of the shapes x86-64 produces (an optional 8-byte
prefix unit and one rest unit; SSE units past the value's end already cut to 2 bytes or
refused, as `cast_pieces` does), its LLVM-level scalars (`ArgAbi.scalars`: class, size,
offset), which is all `arg_plan` reads of the layout.

C integer extension: rustc extends every C integer scalar under 4 bytes to 32 bits
(`signext` for signed ones, else `zeroext`); the dump marks `signext` (`"sext": true` on the
scalar), which `scalarSext` reads (`AbiScalar.sext`), and a `Direct` C integer under 4 bytes without
it is taken as `zeroext`. A C-variadic call's `al` load (`ARG_RAX`) and Win64's duplicated
integer pair of variadic `xmm` pieces are not plan entries (the certificate's plan doesn't
list them either): `CertCheck.passArgs` adds them to the expected argument list, given the
fixed input count the dump gives (`FnAbiSummary.fixed`). Not covered: that a C-variadic
fn's *definition* stays native. The lowering check (`CertCheck.lean`) compares
these with the certificate's plans; a mode the backend leaves native (`NeedsNative`) is an
error here (`Except.error` with `sig.rs`'s reason).
-/
import Ryo.Spec
import Ryo.Check.Image.Common

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm.Asm

/-- `ArgExtension` of a C stack argument: none, `zeroext`, `signext`. -/
inductive ArgExt
  | none | zext | sext
deriving DecidableEq, Repr, Inhabited

/-- `sig::ArgLoc`: where a piece of an ABI input goes. -/
inductive ArgLoc
  /-- The `reg.size` bytes at `off` of the value, in an argument register (`reg.index` its
  position among its class's argument registers; on PE, the argument's position;
  `reg.sext`: a C `signext` 1- or 2-byte integer). -/
  | reg (reg : ArgReg) (off : Nat)
  /-- The `size` bytes at `off` of the value, `at_` bytes into the stack argument area; C
  only: `ext` extends a 1- or 2-byte integer to the slot. -/
  | stack (at_ off size : Nat) (ext : ArgExt := .none)
  /-- SysV C `Indirect { on_stack: true }` (`byval`): the whole value, `size` bytes, copied to
  `at_`, aligned to `align` (at least 8). -/
  | stackByval (at_ size align : Nat)
  /-- An `Indirect` input: a pointer to the value, in an integer argument register. -/
  | ptrReg (index : Nat)
  /-- The same, on the stack. -/
  | ptrStack (at_ : Nat)
deriving DecidableEq, Repr, Inhabited

/-- `sig::ArgPlan`: per input its pieces, and the size of the stack argument area (a multiple
of 16, on PE at least the 32 bytes of shadow space, as `argPlan` computes it; 0 in the
certificate's hand-built plans of `virtualDrop` and `threadLocal` calls). -/
structure ArgPlan where
  locs : List (List ArgLoc)
  stackSize : Nat
deriving DecidableEq, Repr, Inhabited

def ArgLoc.text : ArgLoc → String
  | .reg r off => s!"{if r.xmm then "xmm" else "gpr"}{r.index}:{r.size}{if r.sext then "s" else ""}@{off}"
  | .stack at_ off size ext =>
    let e := match ext with | .none => "" | .zext => " zext" | .sext => " sext"
    s!"stack{at_}:{size}@{off}{e}"
  | .stackByval at_ size align => s!"byval stack{at_}:{size} align {align}"
  | .ptrReg i => s!"ptr gpr{i}"
  | .ptrStack at_ => s!"ptr stack{at_}"

def ArgPlan.text (p : ArgPlan) : String :=
  s!"stack {p.stackSize} [{", ".intercalate (p.locs.map fun ls => "[" ++ ", ".intercalate (ls.map (·.text)) ++ "]")}]"

/-- `n` rounded up to a multiple of `m` (`next_multiple_of`). -/
def roundUp (n m : Nat) : Nat := (n + m - 1) / m * m

/-- Whether the dump marks the scalar `signext` (`"sext": true`). -/
def scalarSext (s : AbiScalar) : Bool := s.sext == some true

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

/-- `State::next_reg`: the next argument register of the class, if one is left. On PE each
argument takes a position, register or not; on SysV only a register is consumed. -/
def nextReg (xmm : Bool) : PlanM (Option Nat) := modifyGet fun st =>
  if st.pe then
    ((if st.pos < 4 then some st.pos else none), { st with pos := st.pos + 1 })
  else if xmm then
    if st.xmm < 8 then (some st.xmm, { st with xmm := st.xmm + 1 }) else (none, st)
  else
    if st.gpr < 6 then (some st.gpr, { st with gpr := st.gpr + 1 }) else (none, st)

/-- `State::reg_or_stack`. -/
def regOrStack (xmm : Bool) (size off : Nat) (ext : ArgExt) : PlanM (List ArgLoc) := do
  match ← nextReg xmm with
  | some index => return [.reg ⟨xmm, size, index, ext == .sext⟩ off]
  | none => return [.stack (← slot (max size 8)) off size ext]

/-- `State::int`: an integer of `size` bytes (1 to 8, or 16 for a `Direct` `i128`) at `off`.
On Win64 an `i128` is two 8-byte integers, low half first, each taking the next position (so
it can straddle `r9` and the stack); on SysV two registers at once, or the stack. -/
def int (size off : Nat) (ext : ArgExt := .none) : PlanM (List ArgLoc) := do
  let st ← get
  if st.pe && size == 16 then
    return (← regOrStack false 8 off .none) ++ (← regOrStack false 8 (off + 8) .none)
  else if size == 16 then
    if st.gpr ≤ 4 then
      set { st with gpr := st.gpr + 2 }
      return [.reg ⟨false, 8, st.gpr, false⟩ off, .reg ⟨false, 8, st.gpr + 1, false⟩ (off + 8)]
    else do return [.stack (← slot 16) off 16 .none]
  else regOrStack false size off ext

/-- `State::ptr`: an `Indirect` input's pointer. -/
def ptr : PlanM (List ArgLoc) := do
  match ← nextReg false with
  | some i => return [.ptrReg i]
  | none => return [.ptrStack (← slot 8)]

/-- `State::float`: a float of `size` bytes at `off`. PE: an `f16` goes in the low 2 bytes of
its `xmm` or its 8-byte stack slot; a `Direct` `f128` is passed by reference. -/
def float (size off : Nat) : PlanM (List ArgLoc) := do
  if (← get).pe && size == 16 then ptr
  else regOrStack true size off .none

end PlanM

/-- `reg_pieces`: the scalars of a `Direct` scalar, a `Pair` or a `Cast` as the dump gives
them (`none` for other modes and refused `Cast` shapes). -/
def regPieces? (a : ArgAbi) : Option (List AbiScalar) :=
  match a.mode with
  | .direct | .pair => a.scalars
  -- `cast_pieces`: integer units of 1 to 8 bytes, float units of 2 (a cut `f16`), 4, 8 or
  -- 16 (Win64 C's `i128` return) bytes.
  | .cast => a.scalars.filter fun ps => ps.all fun s =>
      if s.float then s.size == 2 || s.size == 4 || s.size == 8 || s.size == 16
      else 1 ≤ s.size && s.size ≤ 8
  | _ => none

/-- `arg_plan`: the assignment of `abi`'s inputs to argument registers and the stack, on
SysV or (`pe`) Win64; `sret` makes the return pointer take the first integer register; `c`
for the C ABI (`byval`, integer extension). -/
def argPlan (pe : Bool) (abi : FnAbiSummary) (sret : Bool) (c : Bool := false) :
    Except String ArgPlan := do
  let st : PlanState := { pe, stack := if pe then 32 else 0, gpr := if sret then 1 else 0,
                          pos := if sret then 1 else 0 }
  let (locs, st) ← (abi.args.mapM fun (a : ArgAbi) => do
    match a.mode with
    | .ignore => pure []
    | .indirect =>
      if a.detail == "" then PlanM.ptr
      else if a.detail == "on_stack" && c && !pe then do
        -- `byval`: the value in the stack area, aligned to at least 8 (the pointee
        -- alignment rustc gives a `byval` argument is the layout's, `ArgAbi.align`).
        let size : Nat := a.size
        let align := max 8 a.align.bytes
        if size > (2 ^ 32 - 1) / 2 || align > 16 then
          throw "byval argument too large or aligned above 16"
        let st ← get
        let at_ := roundUp st.stack align
        set { st with stack := at_ + roundUp size 8 }
        pure [.stackByval at_ size align]
      else throw s!"argument passed as Indirect {a.detail}"
    | m =>
      let some pieces := regPieces? a | throw s!"argument passed as {repr m} ({a.detail})"
      -- A pointer to one half of the input isn't an `ArgLoc`.
      if pe && pieces.length > 1 && pieces.any (fun s => s.float && s.size == 16) then
        throw "f128 in a pair argument on Win64"
      if m == PassModeKind.cast && pieces.any (·.size == 16) then
        throw "16-byte cast unit in an argument"
      let mut out : List ArgLoc := []
      for s in pieces do
        let ext : ArgExt :=
          if c && m == PassModeKind.direct && !s.float && s.size < 4 then
            (if scalarSext s then .sext else .zext)
          else .none
        out := out ++ (← if s.float then PlanM.float s.size s.off else PlanM.int s.size s.off ext)
      pure out).run st
  return { locs, stackSize := roundUp st.stack 16 }

/-- `ret_kind`: how a VM function of this signature returns its value (`asm::ret_kind`'s
encoding, `RET_SRET` for an `Indirect` return). -/
def retKindOf (pe : Bool) (ret : ArgAbi) : Except String Nat := do
  match ret.mode with
  | .ignore => return 0
  | .indirect | .indirectUnsized => return Ryo.Check.Image.RET_SRET
  | _ => pure ()
  let some pieces := regPieces? ret | throw s!"return passed as {repr ret.mode} ({ret.detail})"
  -- Win64: a `Direct` `f128` comes back in memory the caller passes the address of, like an
  -- sret (`i128` in `rax:rdx` as on SysV, `f16` in `xmm0`); not in a pair.
  if pe && ret.mode matches .direct | .pair then
    if pieces.any (fun s => s.float && s.size == 16) then
      if pieces.length > 1 then throw "f128 in a returned pair on Win64"
      return Ryo.Check.Image.RET_SRET
  let parts : List RetPart := pieces.flatMap fun s =>
    if !s.float && s.size == 16 then [⟨false, 8, s.off⟩, ⟨false, 8, s.off + 8⟩]
    else [⟨s.float, s.size, s.off⟩]
  if parts.length > 2 then throw "return value in more than two registers"
  return retKind parts

/-- `AbiSig.ret_sext`: a C return of a `signext` integer under 4 bytes (`ret` of an 8-byte
`sext` temporary: its load width is 8 where the return kind says 1 or 2). -/
def retSext (abi : FnAbiSummary) : Bool :=
  abi.conv == .c && abi.ret.mode == .direct && abi.ret.size < 4 &&
    (abi.ret.scalars.getD []).any scalarSext

/-- `from_fn_abi`'s return kind and plan of a Rust-ABI or C-ABI signature. -/
def sigOf (pe : Bool) (abi : FnAbiSummary) : Except String (Nat × ArgPlan) := do
  let c ← match abi.conv with
    | .rust | .rustCall => pure false
    | .c => pure true
    | conv => throw s!"{repr conv} ABI"
  if abi.ret.align.bytes > 16 then throw "return value aligned above 16"
  let k ← retKindOf pe abi.ret
  return (k, ← argPlan pe abi (k == Ryo.Check.Image.RET_SRET) c)

end Ryo.Check.Lower
