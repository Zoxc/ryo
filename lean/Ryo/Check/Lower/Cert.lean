/-
Ryo.Check.Lower.Cert — the lowering's certificate (aot.md §C1) and its JSON reader.

`RYO_DUMP_LEAN=<dir>` makes the backend write `<dir>/<crate>.cert.json` next to the MIR dump
(`backend/src/rustc_api/dump_lean.rs`, `write_certs`; per function `lower/cert.rs`,
`cert_json` and `plan_json`): `{"functions": [{"symbol", "cert"}], "islands": [{"symbol",
"template"}]}`. It is untrusted: `CertCheck.lean` checks what it uses against the decoded code
and the dump. Ranges are half-open `[lo, hi)` of instruction ids, which are indices of the
decoded R instructions (`Decoded.insns`); frame offsets are signed and `fp`-relative.
-/
import Lean.Data.Json
import Ryo.Check.Lower.Plan

namespace Ryo.Check.Lower

open Lean Ryo.Vm.Asm

/-- `plan_json`'s pieces: `{"reg": {xmm, size, index}, "off"}`, `{"stack", "off", "size"}`,
`{"ptrReg"}` or `{"ptrStack"}`. -/
instance : FromJson ArgLoc where
  fromJson? j := do
    if let .ok r := j.getObjVal? "reg" then
      let reg : ArgReg := ⟨← r.getObjValAs? Bool "xmm", ← r.getObjValAs? Nat "size", ← r.getObjValAs? Nat "index"⟩
      return .reg reg (← j.getObjValAs? Nat "off")
    if let .ok a := j.getObjValAs? Nat "stack" then
      return .stack a (← j.getObjValAs? Nat "off") (← j.getObjValAs? Nat "size")
    if let .ok i := j.getObjValAs? Nat "ptrReg" then return .ptrReg i
    if let .ok a := j.getObjValAs? Nat "ptrStack" then return .ptrStack a
    throw s!"not an argument location: {j.compress}"

instance : FromJson ArgPlan where
  fromJson? j := return { locs := ← j.getObjValAs? _ "locs", stackSize := ← j.getObjValAs? Nat "stackSize" }

/-- A half-open range of instruction ids. -/
abbrev Range := Nat × Nat

/-- A local's slot. -/
structure LocalSlot where
  off : Int
  size : Nat
deriving Repr, Inhabited, FromJson

/-- One block's ranges: per statement lowered on its own, the terminator; `fused` if the
block's last statement (a compare, or a niche enum's `Discriminant`) is lowered with the
terminator. -/
structure BlockCert where
  stmts : Array Range
  term : Range
  fused : Bool
deriving Repr, Inhabited, FromJson

/-- A terminate stub (`reason` as the dump names `UnwindTerminateReason`). -/
structure StubCert where
  reason : String
  insns : Range
deriving Repr, Inhabited, FromJson

/-- A landing pad, continuing at MIR block `block` (`none`: a terminate stub). -/
structure PadCert where
  insns : Range
  block : Option Nat
deriving Repr, Inhabited, FromJson

/-- `cert::CallKind`: what a call instruction calls. -/
inductive CallKind
  /-- `call fn` of a resolved callee. -/
  | vm
  /-- `call.sym` / `call.sym.ind` of a resolved callee. -/
  | sym
  /-- `call.ptr`: a fn pointer or a virtual call. -/
  | ptr
  /-- `call fn` of drop glue. -/
  | dropVm
  /-- `call.ptr` of a vtable's `drop_in_place` entry, with the data pointer. -/
  | virtualDrop
  /-- `call.sym` of a thread local's shim, without arguments. -/
  | threadLocal
  /-- `tail_call fn`. -/
  | tailVm
  /-- `tail_call.ptr`. -/
  | tailPtr
deriving DecidableEq, Repr, Inhabited, FromJson

def CallKind.tail : CallKind → Bool
  | .tailVm | .tailPtr => true
  | _ => false

/-- A call instruction: its id, kind, the callee's return kind (`RET_SRET` for sret) and
return value size, and the callee signature's plan. -/
structure CallCert where
  insn : Nat
  kind : CallKind
  retKind : Nat
  retSize : Nat
  plan : Option ArgPlan
deriving Repr, Inhabited, FromJson

/-- One VM function's certificate (`cert_json`): the frame map, its own plan, the
instruction ranges and the calls. -/
structure FuncCert where
  frameSize : Nat
  outgoing : Nat
  argSize : Nat
  retKind : Nat
  locals : Array LocalSlot
  localsEnd : Nat
  tempsEnd : Nat
  exception : Option Int
  sret : Option Int
  /-- Per ABI input, its home slot. -/
  argHomes : Array Int
  /-- Per ABI input, the slot of its pointer if it is passed `Indirect`. -/
  argPtrs : Array (Option Int)
  callerLocation : Option Int
  spreadArg : Option Nat
  plan : Option ArgPlan
  prologue : Range
  blocks : Array BlockCert
  stubs : Array StubCert
  pads : Array PadCert
  calls : Array CallCert
deriving Repr, Inhabited, FromJson

structure FuncEntryJ where
  symbol : String
  cert : FuncCert
deriving FromJson

structure IslandJ where
  symbol : String
  template : String
deriving FromJson

/-- A crate's certificate file: per VM function (by symbol) its certificate, and per island
instance symbol its template's diagnostic name. -/
structure Cert where
  functions : Array (String × FuncCert)
  islands : Array (String × String)
deriving Inhabited

instance : FromJson Cert where
  fromJson? j := do
    let fs : Array FuncEntryJ ← j.getObjValAs? _ "functions"
    let is : Array IslandJ ← j.getObjValAs? _ "islands"
    return { functions := fs.map fun f => (f.symbol, f.cert), islands := is.map fun i => (i.symbol, i.template) }

def Cert.ofJsonString (s : String) : Except String Cert := do
  fromJson? (← Json.parse s)

end Ryo.Check.Lower
