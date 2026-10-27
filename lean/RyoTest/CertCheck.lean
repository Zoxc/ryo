/-
RyoTest.CertCheck — the lowering certificate's reader (`Ryo/Check/Lower/Cert.lean`), the
plan recomputation from a dumped ABI (`Ryo/Check/Lower/Plan.lean`, `sig.rs`'s `arg_plan` and
`ret_kind`) on hand-made signatures, and the call checks' argument lists and facts
(`Ryo/Check/Lower/CertCheck.lean`). The whole check runs on real image objects in
`scripts/lean-cert-check.py`. The escape coverage of the addresses taken (`checkAddrs`) on
hand-built code: zero-sized locals, inside and at the end of escaped objects, uncovered ones,
an escape on one of two paths only, by-address call arguments.
-/
import RyoTest.Harness
import Ryo.Check.Lower.CertCheck

namespace RyoTest.CertCheck

open Ryo.Spec Ryo.Vm.Asm Ryo.Check.Lower

def RET_SRET : Nat := Ryo.Check.Image.RET_SRET

/-- Arguments by their scalars (`"i8"` … `"i128"`, `"ptr"`, `"f16"`, `"f32"`, `"f64"`,
`"f128"`). -/
def scalarOf (s : String) (off : Nat := 0) : AbiScalar :=
  match s with
  | "i8" => ⟨false, 1, off⟩ | "i16" => ⟨false, 2, off⟩ | "i32" => ⟨false, 4, off⟩
  | "i128" => ⟨false, 16, off⟩ | "f32" => ⟨true, 4, off⟩ | "f64" => ⟨true, 8, off⟩
  | "f128" => ⟨true, 16, off⟩ | "f16" => ⟨true, 2, off⟩ | _ => ⟨false, 8, off⟩

def direct (s : String) : ArgAbi :=
  let sc := scalarOf s
  { mode := .direct, size := sc.size, align := Align.ofBytes sc.size, detail := s, scalars := some [sc] }

def pair (a b : String) (bOff : Nat) : ArgAbi :=
  let x := scalarOf a
  let y := scalarOf b bOff
  { mode := .pair, size := bOff + y.size, align := Align.ofBytes 8, scalars := some [x, y] }

def indirect (size : Nat) (onStack : Bool := false) : ArgAbi :=
  { mode := .indirect, size, align := Align.ofBytes 8, detail := if onStack then "on_stack" else "" }

def cast (size : Nat) : ArgAbi :=
  { mode := .cast, size, align := Align.ofBytes 1, detail := "CastTarget", scalars := some [⟨false, size, 0⟩] }

def unit : ArgAbi := { mode := .ignore, size := 0, align := .one }

def sig (args : List ArgAbi) (ret : ArgAbi := unit) : FnAbiSummary := { conv := .rust, args, ret }

def r (i size : Nat) (off : Nat := 0) : ArgLoc := .reg ⟨false, size, i⟩ off
def x (i size : Nat) (off : Nat := 0) : ArgLoc := .reg ⟨true, size, i⟩ off

def expectSig (pe : Bool) (s : FnAbiSummary) (k : Nat) (locs : List (List ArgLoc)) (stack : Nat) : Except String Unit :=
  match sigOf pe s with
  | .ok (k', p) => check (k' == k && p == ⟨locs, stack⟩) s!"got kind {k'} {p.text}, expected kind {k} {(ArgPlan.mk locs stack).text}"
  | .error e => .error s!"no plan: {e}"

def expectNoSig (pe : Bool) (s : FnAbiSummary) (why : String) : Except String Unit :=
  match sigOf pe s with
  | .ok (_, p) => .error s!"expected no plan, got {p.text}"
  | .error e => check ((e.splitOn why).length > 1) s!"expected `{why}`, got `{e}`"

def i64 : ArgAbi := direct "i64"
def f64 : ArgAbi := direct "f64"

def sysv : Except String Unit := do
  -- Seven integers: the seventh on the stack.
  expectSig false (sig (List.replicate 7 i64))
    0 ((List.range 6).map (fun i => [r i 8]) ++ [[.stack 0 0 8]]) 16
  -- Small integers keep their size; `Ignore` takes nothing.
  expectSig false (sig [direct "i8", unit, direct "i16"] (direct "i32"))
    (retKind [⟨false, 4, 0⟩]) [[r 0 1], [], [r 1 2]] 0
  -- An `i128` with five registers taken goes to a 16-aligned stack slot, leaving `r9` to
  -- the next integer.
  expectSig false (sig (List.replicate 5 i64 ++ [direct "i128", i64, i64]))
    0 ((List.range 5).map (fun i => [r i 8]) ++ [[.stack 0 0 16], [r 5 8], [.stack 16 0 8]]) 32
  -- With four taken, it takes two registers.
  expectSig false (sig (List.replicate 4 i64 ++ [direct "i128"]))
    0 ((List.range 4).map (fun i => [r i 8]) ++ [[r 4 8 0, r 5 8 8]]) 0
  -- Nine floats: the ninth on the stack; an `f128` past the registers 16-aligned.
  expectSig false (sig (List.replicate 9 f64 ++ [direct "f128"]))
    0 ((List.range 8).map (fun i => [x i 8]) ++ [[.stack 0 0 8], [.stack 16 0 16]]) 32
  -- Floats and integers count separately; a pair takes one of each.
  expectSig false (sig [f64, pair "i64" "f32" 8, i64])
    0 [[x 0 8], [r 0 8, x 1 4 8], [r 1 8]] 0
  -- `Indirect`: a pointer in the next integer register, then on the stack.
  expectSig false (sig [indirect 24, i64])
    0 [[.ptrReg 0], [r 1 8]] 0
  expectSig false (sig (List.replicate 6 i64 ++ [indirect 24, indirect 32]))
    0 ((List.range 6).map (fun i => [r i 8]) ++ [[.ptrStack 0], [.ptrStack 8]]) 16
  -- An sret return takes the first integer register.
  expectSig false (sig [i64, indirect 24] (indirect 40))
    RET_SRET [[r 1 8], [.ptrReg 2]] 0
  -- The Rust ABI's small aggregates: an integer `Cast`.
  expectSig false (sig [cast 6] (cast 3)) (retKind [⟨false, 3, 0⟩]) [[r 0 6]] 0
  -- Returns: a pair of an integer and a float, an `i128` in `rax:rdx`.
  expectSig false (sig [] (pair "i32" "f64" 8)) (retKind [⟨false, 4, 0⟩, ⟨true, 8, 8⟩]) [] 0
  expectSig false (sig [] (direct "i128")) (retKind [⟨false, 8, 0⟩, ⟨false, 8, 8⟩]) [] 0
  -- What the backend leaves native.
  expectNoSig false (sig [indirect 24 true]) "Indirect on_stack"
  expectNoSig false (sig [{ mode := .indirectUnsized, size := 16, align := Align.ofBytes 8 }]) "indirectUnsized"
  expectNoSig false (sig [cast 12]) "Cast"
  expectNoSig false (sig [] (pair "i128" "i64" 16)) "more than two registers"
  expectNoSig false { conv := .c, args := [], ret := unit } "ABI"

def win64 : Except String Unit := do
  -- Positions, not classes; after four, 8-byte slots after the 32 bytes of shadow space.
  expectSig true (sig [i64, f64, direct "i32", f64, i64, f64])
    0 [[r 0 8], [x 1 8], [r 2 4], [x 3 8], [.stack 32 0 8], [.stack 40 0 8]] 48
  -- The shadow space alone.
  expectSig true (sig [i64]) 0 [[r 0 8]] 32
  -- sret takes position 0; `Indirect` pointers take positions too.
  expectSig true (sig [indirect 24, i64, indirect 16, indirect 8] (indirect 40))
    RET_SRET [[.ptrReg 1], [r 2 8], [.ptrReg 3], [.ptrStack 32]] 48
  -- An `i128` is two 8-byte positions, low half first; it can straddle `r9` and the stack.
  expectSig true (sig [direct "i128", i64])
    0 [[r 0 8 0, r 1 8 8], [r 2 8]] 32
  expectSig true (sig [i64, i64, f64, direct "i128", direct "i128"])
    0 [[r 0 8], [r 1 8], [x 2 8], [r 3 8 0, .stack 32 8 8], [.stack 40 0 8, .stack 48 8 8]] 64
  -- An `f16` takes its position's `xmm` (2 bytes) or an 8-byte slot.
  expectSig true (sig [direct "f16", i64, i64, i64, direct "f16"])
    0 [[x 0 2], [r 1 8], [r 2 8], [r 3 8], [.stack 32 0 2]] 48
  -- A `Direct` `f128` is passed by reference, like an `Indirect` input.
  expectSig true (sig [i64, direct "f128", f64, i64, direct "f128"])
    0 [[r 0 8], [.ptrReg 1], [x 2 8], [r 3 8], [.ptrStack 32]] 48
  -- Returns: `i128` in `rax:rdx`, `f16` in `xmm0`, `f128` as sret (taking position 0).
  expectSig true (sig [] (direct "i128")) (retKind [⟨false, 8, 0⟩, ⟨false, 8, 8⟩]) [] 32
  expectSig true (sig [] (direct "f16")) (retKind [⟨true, 2, 0⟩]) [] 32
  expectSig true (sig [direct "f128", i64] (direct "f128")) RET_SRET [[.ptrReg 1], [r 2 8]] 32
  -- An `f128` in a `Pair` stays native; on SysV it doesn't.
  expectNoSig true (sig [pair "f128" "i64" 16]) "f128 in a pair argument on Win64"
  expectNoSig true (sig [] (pair "i64" "f128" 16)) "f128 in a returned pair on Win64"
  expectSig false (sig [pair "f128" "i64" 16]) 0 [[x 0 16, r 0 8 16]] 0

def certJson : String := "{\"functions\":[{\"symbol\":\"f\",\"cert\":{\"frameSize\":48,\"outgoing\":16,\"argSize\":16,\"retKind\":2147483648,\"locals\":[{\"off\":-16,\"size\":16},{\"off\":-24,\"size\":8}],\"localsEnd\":32,\"tempsEnd\":48,\"exception\":-40,\"sret\":-32,\"argHomes\":[-24,-48],\"argPtrs\":[null,-8],\"callerLocation\":null,\"spreadArg\":2,\"plan\":{\"stackSize\":16,\"locs\":[[{\"reg\":{\"xmm\":true,\"size\":8,\"index\":0},\"off\":0}],[{\"ptrReg\":1}],[{\"stack\":0,\"off\":8,\"size\":4}],[{\"ptrStack\":8}]]},\"prologue\":[0,3],\"blocks\":[{\"stmts\":[[3,3],[3,5]],\"term\":[5,7],\"fused\":true}],\"stubs\":[{\"reason\":\"abi\",\"insns\":[7,8]}],\"pads\":[{\"insns\":[8,10],\"block\":null}],\"calls\":[{\"insn\":6,\"kind\":\"dropVm\",\"retKind\":0,\"retSize\":0,\"plan\":null},{\"insn\":7,\"kind\":\"tailPtr\",\"retKind\":8,\"retSize\":8,\"plan\":{\"stackSize\":0,\"locs\":[]}}]}}],\"islands\":[{\"symbol\":\"isl\",\"template\":\"ryo_rt::island::call\"}]}"

def parse : Except String Unit := do
  let c ← Cert.ofJsonString certJson
  check (c.functions.size == 1 && c.islands == #[("isl", "ryo_rt::island::call")]) "functions and islands"
  let (s, f) := c.functions[0]!
  check (s == "f" && f.frameSize == 48 && f.retKind == RET_SRET && f.sret == some (-32) && f.exception == some (-40)) "frame"
  check (f.argHomes == #[-24, -48] && f.argPtrs == #[none, some (-8)] && f.callerLocation == none && f.spreadArg == some 2) "homes"
  check (f.plan == some ⟨[[x 0 8], [.ptrReg 1], [.stack 0 8 4], [.ptrStack 8]], 16⟩) s!"plan {repr f.plan}"
  check (f.prologue == (0, 3) && f.blocks.size == 1 && f.blocks[0]!.stmts == #[(3, 3), (3, 5)] && f.blocks[0]!.fused) "blocks"
  check (f.stubs[0]!.reason == "abi" && f.pads[0]!.insns == (8, 10) && f.pads[0]!.block == none) "stubs and pads"
  check (f.calls.map (·.kind) == #[.dropVm, .tailPtr] && f.calls[0]!.plan == none && f.calls[1]!.plan == some ⟨[], 0⟩) "calls"
  -- Rejections.
  check (Cert.ofJsonString (certJson.replace "\"dropVm\"" "\"jump\"") matches .error _) "an unknown call kind"
  check (Cert.ofJsonString (certJson.replace "{\"ptrStack\":8}" "{\"stackPtr\":8}") matches .error _) "an unknown location"

def w32 (n : Int) : BitVec 32 := BitVec.ofInt 32 n

def words (ps : List (Int × Nat)) : List (BitVec 32) := ps.flatMap fun (s, r) => [w32 s, BitVec.ofNat 32 r]

def fc : FuncCert :=
  match Cert.ofJsonString certJson with
  | .ok c => c.functions[0]!.2
  | .error _ => default

def argLists : Except String Unit := do
  let plan : ArgPlan := ⟨[[r 0 3, x 0 8 8], [.ptrReg 1], [.stack 0 0 8]], 16⟩
  -- A call: sret by address, a 3-byte piece passed as 4, an `Indirect` input by address.
  let some want := (passArgs fc plan true false).toOption | .error "passArgs"
  let ok := words [(-64, 8 ||| argAddr), (-40, (ArgReg.mk false 4 0).word), (-32, (ArgReg.mk true 8 0).word),
    (-56, (ArgReg.mk false 8 1).word ||| argAddr)]
  check (checkArgList ok want == none) s!"{checkArgList ok want}"
  -- An input's pieces at different homes, a missing `ARG_ADDR`, a short list.
  let badHome := words [(-64, 8 ||| argAddr), (-40, (ArgReg.mk false 4 0).word), (-24, (ArgReg.mk true 8 0).word),
    (-56, (ArgReg.mk false 8 1).word ||| argAddr)]
  check (checkArgList badHome want |>.isSome) "pieces at two homes"
  let noAddr := words [(-64, 8), (-40, (ArgReg.mk false 4 0).word), (-32, (ArgReg.mk true 8 0).word),
    (-56, (ArgReg.mk false 8 1).word ||| argAddr)]
  check (checkArgList noAddr want |>.isSome) "sret without ARG_ADDR"
  check (checkArgList (ok.take 6) want |>.isSome) "a short list"
  -- A tail call passes the incoming sret and `Indirect` pointers, not by address.
  let some want := (passArgs fc ⟨[[r 0 8], [.ptrReg 1]], 0⟩ true true).toOption | .error "passArgs tail"
  check (checkArgList (words [(-32, 8), (-24, 8), (-8, (ArgReg.mk false 8 1).word)]) want == none) "tail call"
  check (checkArgList (words [(-16, 8), (-24, 8), (-8, (ArgReg.mk false 8 1).word)]) want |>.isSome) "tail call, wrong sret slot"
  -- The function's own `arg`s.
  let some pro := (prologueArgs fc (fc.plan.getD default)).toOption | .error "prologueArgs"
  check (pro == [(-32, 8), (-24, (ArgReg.mk true 8 0).word), (-8, (ArgReg.mk false 8 1).word)]) s!"prologue {pro}"

def facts : Except String Unit := do
  let call (insn : Nat) (stack : Nat) (sret : Bool) (kind : CallKind := .vm) : CallCert :=
    { insn, kind, retKind := if sret then RET_SRET else 0, retSize := 40, plan := some ⟨[], stack⟩ }
  -- Only calls the dump's ABI verified (calls of image functions get theirs from
  -- `DecodeObj.imageFacts`).
  let r : FuncCheck := { calls := #[(call 1 16 true, .entry), (call 2 32 false, .abi), (call 3 48 true, .none),
    (call 4 0 true .tailVm, .abi), (call 6 8 true .sym, .abi)], islands := #[(5, "drop_in_place")] }
  let f := Cert.facts r
  check (f.stackArgs 1 == none && f.stackArgs 2 == some 32 && f.stackArgs 3 == none && f.stackArgs 4 == some 0) "stack args"
  check (f.sretSize 1 == none && f.sretSize 2 == none && f.sretSize 3 == none && f.sretSize 4 == none &&
    f.sretSize 6 == some 40) "sret sizes"
  check (f.islandTemplate 5 == some "drop_in_place" && f.islandTemplate 1 == none) "islands"

/-! ### Escape coverage (`checkAddrs`) -/

section Addrs
open Ryo.Vm.R

def aMode : Ryo.Obj.Mode := { fpArg := true, framePointer := true, alignLoops := false, pe := false, counters := false }
def red (m : String) : Ryo.Vm.Reduced.Opcode := (Ryo.Vm.Reduced.all.find? (·.info.mnemonic == m)).get!
def s32 (o : Int) : BitVec 32 := BitVec.ofInt 32 o
def sl (o : Int) : Opnd Nat := .slot (s32 o)
def nat (m : String) (ops : List (Opnd Nat)) : Insn := .native (red m) ops
def addrI (d s : Int) : Insn := nat "addr" [sl d, sl s]
def retI : Insn := nat "ret" [sl 0, .imm 0]
def esc (k : Nat) (off : Int) (n : Nat) : Nat × Scope := (k, ⟨0, s32 off, n, .escape 8⟩)
def endS (k : Nat) (off : Int) (n : Nat) : Nat × Scope := (k, ⟨0, s32 off, n, .end⟩)
def dec (insns : List Insn) (scopes : List (Nat × Scope) := []) : Decoded :=
  { insns := insns.toArray, frameSize := 64, cleanup := #[], scopes := scopes.toArray, dropped := #[], heads := #[] }

/-- (addrs, inside, at end, zero-sized, args, errors). -/
def addrCounts (d : Decoded) (zs : List Int := []) : Nat × Nat × Nat × Nat × Nat × Nat :=
  let (c, e) := checkAddrs d aMode zs
  (c.addrs, c.inside, c.atEnd, c.zeroSized, c.args, e.size)

def addrs : Except String Unit := do
  -- A zero-sized local.
  let z := addrCounts (dec [addrI (-24) (-16), retI]) [-16]
  check (z == (1, 0, 0, 1, 0, 0)) s!"zero-sized {z}"
  -- Inside an escaped object, and at its end.
  let e := addrCounts (dec [addrI (-24) (-12), addrI (-24) (-8), retI] [esc 0 (-16) 8])
  check (e == (2, 1, 1, 0, 0, 0)) s!"inside, at end {e}"
  -- Uncovered: no escape, an offset next to a zero-sized local, the end after the `End`.
  let u := addrCounts (dec [addrI (-24) (-16), retI]) [-12]
  check (u == (1, 0, 0, 0, 0, 1)) s!"uncovered {u}"
  let u := addrCounts (dec [addrI (-24) (-8), retI] [esc 0 (-16) 8, endS 0 (-16) 8])
  check (u == (1, 0, 0, 0, 0, 1)) s!"after the end {u}"
  -- Escaped on one of two paths only (0 → 2 skips the escape before 1), then on both.
  let br := nat "br.lt.u.imm.w64" [sl (-8), .imm 2, .neg false, .target 2]
  let two := [br, nat "imm.w64" [sl (-8), .imm 0], addrI (-24) (-16), retI]
  let (c, errs) := checkAddrs (dec two [esc 1 (-16) 8]) aMode []
  check (c.inside == 0 && errs.size == 1) s!"one path {errs}"
  check (errs.all fun e => (e.splitOn "some path only").length > 1) s!"one path: {errs}"
  let b := addrCounts (dec two [esc 0 (-16) 8, esc 1 (-16) 8])
  check (b == (1, 1, 0, 0, 0, 0)) s!"both paths {b}"
  -- A by-address call argument, covered; then one that isn't.
  let callI (s : Int) : Insn := nat "call" [sl (-8), .func 0, .imm 0, .words [s32 s, BitVec.ofNat 32 (8 ||| argAddr)]]
  let a := addrCounts (dec [callI (-16), retI] [esc 0 (-16) 8])
  check (a == (1, 1, 0, 0, 1, 0)) s!"argument {a}"
  let a := addrCounts (dec [callI (-32), retI] [esc 0 (-16) 8])
  check (a == (1, 0, 0, 0, 1, 1)) s!"uncovered argument {a}"

end Addrs

def tests : List TestCase :=
  [⟨"cert: plan SysV", fun _ => sysv⟩, ⟨"cert: plan Win64", fun _ => win64⟩,
   ⟨"cert: JSON", fun _ => parse⟩, ⟨"cert: argument lists", fun _ => argLists⟩,
   ⟨"cert: facts", fun _ => facts⟩, ⟨"cert: escape coverage", fun _ => addrs⟩]

end RyoTest.CertCheck
