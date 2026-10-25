/-
RyoTest.View — `Ryo.Vm.R.view` against Rust's `asm::decode`, over the vectors of
`vm/bytecode/tests/lean_view_vectors.rs` (`RyoTest/ViewVectors.lean`): every function is
decoded with `decodeReduced`, each instruction viewed (addresses placed by an injective
symbolic `ρ`), and printed in the vectors' common form (opcode, operands, targets as
instruction indices, case values read from the code constants), which must be Rust's full
instruction line for line. The vectors must exercise every register packing in use (`Mem`,
`U128`, case lists, target lists, `lpad`'s exception object, both `fp_arg` layouts; no opcode
shares a register between two 32-bit operands any more).

Also: `unpack` rejects arguments that don't fit (a register too many or too few, an address
where a value belongs and the reverse, nonzero bits outside an operand, a missing `fp` or
exception object), and `view` a switch table of the wrong length.
-/
import RyoTest.Harness
import RyoTest.ViewVectors
import Ryo.Vm.DecodeReduced
import Ryo.Vm.R.View

namespace RyoTest.View

open Lean Ryo.Vm Ryo.Vm.R Ryo.Vm.OpSem Ryo.Spec

/-- The symbolic placement: kind tag above bit 40, the index below. -/
def tagBase : Nat := 2 ^ 40

def ρ : Addrs
  | .const n => some ⟨1 * tagBase + n, none⟩
  | .data n => some ⟨2 * tagBase + n, none⟩
  | .sym n => some ⟨3 * tagBase + n, none⟩
  | .site n => some ⟨4 * tagBase + n, none⟩
  | .ro n => some ⟨5 * tagBase + n, none⟩
  | _ => none

def addrText (p : ThinPointer) : String :=
  let n := p.addr % tagBase
  match p.addr / tagBase with
  | 1 => s!"k{n}"
  | 2 => s!"d{n}"
  | 3 => s!"y{n}"
  | 4 => s!"t{n}"
  | _ => s!"?addr{p.addr}"

def caseSize : ElemKind → Nat
  | .case8 => 1 | .case16 => 2 | .case32 => 4 | .case64 => 8 | _ => 16

/-- `n` little-endian values of `size` bytes at `off` of `ro`. -/
def caseValues (ro : ByteArray) (off size n : Nat) : List Nat :=
  (List.range n).map fun j =>
    (List.range size).foldr (fun b acc => acc * 256 + (ro.get! (off + j * size + b)).toNat) 0

def targetsText (ts : List Nat) : String := "[" ++ ",".intercalate (ts.map (s!"@{·}")) ++ "]"

/-- An instruction's view in the vectors' common form. `native` is the native instruction's
operands, for what `opSem` doesn't get when `ctl` is `none`. -/
def render (ro : ByteArray) (v : View) (native : List (Opnd Nat)) : String := Id.run do
  let infos := v.op.info.operands
  -- The table's entries before the default.
  let cases : List Nat := match v.ctl with
    | some (.table ts) => ts.dropLast
    | _ => []
  let mut s := v.op.mnemonic
  for ((info, val), k) in (infos.zip v.ops).zipIdx do
    let nat := native[k]?
    let t := match info.kind, val with
      | _, .slot o => s!"s{o}"
      | _, .mem p x => s!"m{p},{x}"
      | _, .imm n => s!"i{n}"
      | _, .addr p => addrText p
      | _, .targets n => if n == cases.length then targetsText cases else s!"?targets{n}"
      | .list e, .cases p n =>
        if n != cases.length || p.addr / tagBase != 5 then "?cases" else
        let vals := caseValues ro (p.addr % tagBase) (caseSize e) n
        "c[" ++ ",".intercalate ((vals.zip cases).map fun (x, c) => s!"{x}=>@{c}") ++ "]"
      | .target, .none => match v.ctl, nat with
        | some (.branch _ x), _ => s!"@{x}"
        | some (.table ts), _ => s!"@{ts.getLast?.getD 0}"
        | none, some (.target x) => s!"@{x}"
        | _, _ => "?target"
      | .neg, .none => match v.ctl, nat with
        | some (.branch n _), _ => s!"n{if n then 1 else 0}"
        | none, some (.neg n) => s!"n{if n then 1 else 0}"
        | _, _ => "?neg"
      | .func, .none => match nat with
        | some (.func f) => s!"f{f}"
        | _ => "?func"
      | .list .word, .none => match nat with
        | some (.words ws) => "w[" ++ ",".intercalate (ws.map fun w => toString w.toNat) ++ "]"
        | _ => "?words"
      | _, _ => "?"
    s := s ++ " " ++ t
  return s

structure Vector where
  inputs : Inputs
  full : List String

def vectors : Except String (Array Vector) := do
  let j ← Json.parse ViewVectors.json
  (← j.getArr?).mapM fun v => do
    let inputs ← Inputs.ofJson (← v.getObjVal? "in")
    let full ← v.getObjValAs? (List String) "full"
    pure { inputs, full }

/-- What the vectors' handler calls exercise. -/
structure Coverage where
  mem : Nat := 0
  u128 : Nat := 0
  cases : Nat := 0
  targets : Nat := 0
  lpad : Nat := 0
  fpArg : Nat := 0
  rbp : Nat := 0
  handlers : Nat := 0
  natives : Nat := 0

def Coverage.add (c : Coverage) (i : Insn) (fpArg : Bool) : Coverage :=
  match i with
  | .native .. => { c with natives := c.natives + 1 }
  | .handler h _ _ => match h.layout fpArg with
  | none => c
  | some _ =>
    let kinds := h.info.operands.map (·.kind)
    let has (p : OperandKind → Bool) : Nat := if kinds.any p then 1 else 0
    { c with
      handlers := c.handlers + 1
      mem := c.mem + has (· == .mem)
      u128 := c.u128 + has (· == .u128)
      cases := c.cases + has (fun | .list .target | .list .word | .list .arg => false | .list _ => true | _ => false)
      targets := c.targets + has (· == .list .target)
      lpad := c.lpad + (if h.info.shape == .lpad then 1 else 0)
      fpArg := c.fpArg + (if fpArg then 1 else 0)
      rbp := c.rbp + (if fpArg then 0 else 1) }

def check : Except String Coverage := do
  let mut cov : Coverage := {}
  for (v, k) in (← vectors).zipIdx do
    let d ← match v.inputs.decode with
      | .ok d => pure d
      | .error e => throw s!"vector {k} doesn't decode: {e.text}"
    if d.insns.size != v.full.length then
      throw s!"vector {k}: {d.insns.size} instructions, Rust {v.full.length}"
    for (i, want) in d.insns.toList.zip v.full do
      cov := cov.add i v.inputs.mode.fpArg
      let native := match i with
        | .native _ ops => ops
        | _ => []
      let some vw := view v.inputs.mode ρ i
        | throw s!"vector {k}: no view of {repr i}, Rust {want}"
      let got := render v.inputs.rodata vw native
      if got != want then
        throw s!"vector {k}:\n  rust {want}\n  lean {got}\n  from {repr i}"
  return cov

def opcode (m : String) : Full.Opcode := (Full.Opcode.ofMnemonic? m).get!

def slotArg (o : Int) : Arg := .imm (BitVec.ofNat 64 (BitVec.ofInt 32 o).toNat)

/-- Arguments that don't fit. -/
def rejects : Except String Unit := do
  let div := opcode "div.u.w32"
  let shl := opcode "shl.imm.w8"
  let lpad := opcode "lpad"
  let good := [slotArg (-8), slotArg 16, slotArg (-24)]
  let expect (what : String) (b : Bool) : Except String Unit := if b then pure () else throw what
  expect "div: good" (unpack ρ div false good == some [.slot (-8), .slot 16, .slot (-24)])
  expect "div: fp_arg" (unpack ρ div true (.fp :: good) == some [.slot (-8), .slot 16, .slot (-24)])
  expect "div: no fp" (unpack ρ div true good == none)
  expect "div: fp elsewhere" (unpack ρ div false [.fp, slotArg 16, slotArg (-24)] == none)
  expect "div: too few" (unpack ρ div false good.dropLast == none)
  expect "div: too many" (unpack ρ div false (good ++ [.imm 0]) == none)
  expect "div: an address" (unpack ρ div false [.const 3, slotArg 16, slotArg (-24)] == none)
  expect "div: high bits" (unpack ρ div false [.imm (BitVec.ofNat 64 (2 ^ 32 + 8)), slotArg 16, slotArg (-24)] == none)
  expect "shl: good" ((unpack ρ shl false [slotArg (-8), slotArg 16, .imm 7]).isSome)
  expect "shl: imm out of range" (unpack ρ shl false [slotArg (-8), slotArg 16, .imm 256] == none)
  expect "lpad: good" (unpack ρ lpad false [.exception, slotArg (-8)] == some [.slot (-8)])
  expect "lpad: no exception" (unpack ρ lpad false [.imm 0, slotArg (-8)] == none)
  expect "lpad: exception as operand" (unpack ρ lpad false [.exception, .exception] == none)
  -- A handler call of each vector function, mutated.
  let mut n := 0
  for v in ← vectors do
    let .ok d := v.inputs.decode | throw "decode"
    for i in d.insns do
      let .handler h args t := i | continue
      let m := v.inputs.mode
      let bad (args' : List Arg) (t' : Then Nat) (what : String) : Except String Unit :=
        if (view m ρ (.handler h args' t')).isSome then
          throw s!"{h.mnemonic} {repr args'} {repr t'}: {what} has a view" else pure ()
      if !args.isEmpty then bad args.dropLast t "a register fewer"
      bad (args ++ [.imm 0]) t "a register more"
      for (a, r) in args.zipIdx do
        match a with
        | .imm _ => bad (args.set r (.const 0)) t s!"an address in register {r}"
        | .const _ | .data _ | .sym _ | .site _ | .ro _ => bad (args.set r (.imm 0)) t s!"a value in register {r}"
        | _ => pure ()
      if let .table ts := t then bad args (.table (ts ++ ts.take 1)) "a longer table"
      if let .branch _ x := t then bad args (.table [x]) "a table for a branch"
      if let .next := t then bad args .trap "a trap"
      n := n + 1
  if n < 500 then throw s!"only {n} handler calls mutated"

def tests : List TestCase :=
  [⟨"view/vectors", fun _ => do
      let c ← check
      let need := [("mem", c.mem), ("u128", c.u128), ("cases", c.cases),
        ("targets", c.targets), ("lpad", c.lpad), ("fp_arg", c.fpArg), ("rbp", c.rbp),
        ("natives", c.natives)]
      for (what, k) in need do
        if k == 0 then throw s!"no handler call with {what}"⟩,
   ⟨"view/rejects", fun _ => rejects⟩]

end RyoTest.View
