/-
Ryo.Vm.OpSem.Json — `ryo-lean opsem`: `opSem` on JSON lines, for the differential test
against the `ryo_h_*` handlers (reduced.md, "Validating `opSem`").

One request per line on stdin, one result per line on stdout:

```
{"op": "add.w32",
 "ops": [{"slot": -8}, {"slot": -16}, {"slot": -24}],
 "frame": {"base": -64, "bytes": [0, 1, null, ...]},
 "allocs": [{"addr": 4096, "bytes": [...], "mutable": true}],
 "escaped": [{"off": -32, "size": 8, "alloc": 1}],
 "exception": 0,
 "choice": {"nan": 2143289344, "pick_y": false, "spurious": false}}
```

- `ops`, one per operand of the opcode (`Full.Opcode.info`): `{"slot": o}`, `{"mem": [p, k]}`,
  `{"imm": v}` (a number or a decimal string, for `U128`), `{"addr": a}` (an address operand),
  `{"targets": n}` (a jump table's length), `{"cases": [a, n]}` (a case list's values'
  address and count), or `null` (targets, `neg`).
- `frame`: the private frame bytes from `base` (the others are `Uninit`); a byte is a number,
  `null` (`Uninit`) or `[b, alloc, pos]` (with a provenance fragment).
- `allocs`: allocations `0, 1, …` (live, of kind heap, align 1), all exposed: a pointer
  without provenance accesses the one containing the range.
- `escaped`: frame objects that are allocations (`alloc` indexes `allocs`; its bytes are the
  object's).
- `choice` (optional): `Choice`; each is checked against the allowed set.

The result: `{"ok": {"control": "next" | {"branch": b} | {"index": i}, "frame": [...],
"allocs": [[...], ...]}, "reads": [[off, len], ...], "writes": [[off, len], ...]}` with the
frame bytes from `base` (as many as given) and each allocation's bytes, or `{"stop": "ub" |
"abort" | "unreachable" | "unsupported" | "ill_formed" | "no_behavior", "msg": m, "reads": …,
"writes": …}`. `reads`/`writes` are the footprint's frame ranges. A line that doesn't parse
gives `{"error": m}`.
-/
import Ryo.Vm.OpSem.Sem
import Lean.Data.Json

namespace Ryo.Vm.OpSem.Json

open Lean Ryo.Spec Ryo.Vm

def getNat (j : Json) : Except String Nat :=
  match j with
  | .str s => match s.toNat? with
    | some n => pure n
    | none => throw s!"not a number: {s}"
  | _ => do
    let i : Int ← fromJson? j
    if i < 0 then throw s!"negative: {i}" else pure i.toNat

def getInt (j : Json) : Except String Int := fromJson? j

def field (j : Json) (k : String) : Except String Json := j.getObjVal? k

def optField (j : Json) (k : String) : Option Json := (j.getObjVal? k).toOption

def parseByte (j : Json) : Except String AbstractByte :=
  match j with
  | .null => pure .uninit
  | .arr #[b, a, p] => do
    pure (.init (UInt8.ofNat (← getNat b)) (some ⟨← getNat a, ← getNat p⟩))
  | _ => do
    let b ← getNat j
    if b < 256 then pure (.ofByte (UInt8.ofNat b)) else throw s!"byte out of range: {b}"

def byteJson : AbstractByte → Json
  | .uninit => .null
  | .init b none => toJson b.toNat
  | .init b (some f) => .arr #[toJson b.toNat, toJson f.prov, toJson f.pos]

def parseBytes (j : Json) : Except String (List AbstractByte) := do
  let a ← j.getArr?
  a.toList.mapM parseByte

def parseVal (j : Json) : Except String Val := do
  if j.isNull then return .none
  if let some v := optField j "slot" then return .slot (← getInt v)
  if let some v := optField j "mem" then
    let a ← v.getArr?
    if a.size != 2 then throw "mem: [p, k]"
    return .mem (← getInt a[0]!) (← getInt a[1]!)
  if let some v := optField j "imm" then return .imm (← getNat v)
  if let some v := optField j "addr" then return .addr ⟨← getNat v, none⟩
  if let some v := optField j "targets" then return .targets (← getNat v)
  if let some v := optField j "cases" then
    let a ← v.getArr?
    if a.size != 2 then throw "cases: [addr, n]"
    return .cases ⟨← getNat a[0]!, none⟩ (← getNat a[1]!)
  throw s!"bad operand: {j.compress}"

structure Request where
  op : Full.Opcode
  ops : Operands
  base : Int
  frameLen : Nat
  st : State
  ch : Choice

def parseRequest (j : Json) : Except String Request := do
  let m : String ← fromJson? (← field j "op")
  let some op := Full.Opcode.ofMnemonic? m | throw s!"unknown opcode {m}"
  let ops ← ((← (← field j "ops").getArr?).toList).mapM parseVal
  let (base, fbytes) ← match optField j "frame" with
    | some f => do pure (← getInt (← field f "base"), ← parseBytes (← field f "bytes"))
    | none => pure (0, [])
  let allocsJ := match optField j "allocs" with
    | some a => (a.getArr?.toOption.getD #[]).toList
    | none => []
  let allocs ← allocsJ.mapM fun a => do
    let addr ← getNat (← field a "addr")
    let data ← parseBytes (← field a "bytes")
    let mutable : Bool := match optField a "mutable" with
      | some (.bool b) => b
      | _ => true
    let al : Allocation :=
      { data := data.toArray, addr, align := Align.one, kind := .heap, mutable,
        vtableRo := by intro h; cases h }
    pure al
  let escaped ← match optField j "escaped" with
    | some e => do
      ((← e.getArr?).toList.mapM fun o => do
        pure ({ off := ← getInt (← field o "off"), size := ← getNat (← field o "size"),
                id := ← getNat (← field o "alloc") } : EscapedObj))
    | none => pure []
  let exception ← match optField j "exception" with
    | some x => pure (⟨← getNat x, none⟩ : ThinPointer)
    | none => pure ThinPointer.null
  let ch ← match optField j "choice" with
    | some c => do
      let nan ← match optField c "nan" with
        | some n => if n.isNull then pure none else pure (some (← getNat n))
        | none => pure none
      let flag (k : String) : Bool := match optField c k with
        | some (.bool b) => b
        | _ => false
      pure ({ nan, pickY := flag "pick_y", spurious := flag "spurious" } : Choice)
    | none => pure {}
  let farr := fbytes.toArray
  let frame (o : Int) : AbstractByte :=
    if base ≤ o then farr.getD (o - base).toNat .uninit else .uninit
  pure { op, ops, base, frameLen := fbytes.length, ch,
         st := { frame, escaped, mem := { allocs := allocs.toArray },
                 exposed := List.range allocs.length, exception } }

def rangesJson (rs : List (Int × Nat)) : Json :=
  .arr (rs.map fun (o, n) => Json.arr #[toJson o, toJson n]).toArray

def stopJson : Stop → String × String
  | .ub m => ("ub", m)
  | .abort => ("abort", "")
  | .unreachable => ("unreachable", "")
  | .unsupported m => ("unsupported", m)
  | .illFormed m => ("ill_formed", m)
  | .noBehavior m => ("no_behavior", m)

def respond (r : Request) : Json :=
  let val := opndVal r.op.info r.ops
  let (reads, writes) := match footprint r.op with
    | some fp => (fp.readRanges val, fp.writeRanges val)
    | none => ([], [])
  let fpFields := [("reads", rangesJson reads), ("writes", rangesJson writes)]
  match opSem r.op r.ops r.st r.ch with
  | .ok (c, st) =>
    let ctl : Json := match c with
      | .next => "next"
      | .branch b => Json.mkObj [("branch", toJson b)]
      | .index i => Json.mkObj [("index", toJson i)]
    let frame := (List.range r.frameLen).map fun (i : Nat) =>
      byteJson (match st.byteAt (r.base + (i : Int)) with
        | .ok b => b
        | .error _ => .uninit)
    let allocs := st.mem.allocs.toList.map fun a => Json.arr (a.data.map byteJson)
    Json.mkObj ([("ok", Json.mkObj [("control", ctl), ("frame", .arr frame.toArray),
      ("allocs", .arr allocs.toArray)])] ++ fpFields)
  | .error s =>
    let (k, m) := stopJson s
    Json.mkObj ([("stop", toJson k), ("msg", toJson m)] ++ fpFields)

def handleLine (line : String) : Json :=
  match Json.parse line >>= parseRequest with
  | .ok r => respond r
  | .error e => Json.mkObj [("error", toJson e)]

partial def main : IO UInt32 := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  let rec loop : IO Unit := do
    let line ← stdin.getLine
    if line.isEmpty then return
    let l := line.trimAscii.toString
    if !l.isEmpty then
      stdout.putStrLn (handleLine l).compress
      stdout.flush
    loop
  loop
  pure 0

end Ryo.Vm.OpSem.Json
