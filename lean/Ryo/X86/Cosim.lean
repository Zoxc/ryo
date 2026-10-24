/-
Ryo.X86.Cosim — `ryo-lean exec-item`: runs items on a given state for the co-simulation
against the CPU (x86.md §B.3; the harness is `lean/harness`).

One JSON request per line on stdin, one JSON response per line on stdout:

  request  {"items": [Item, ..]          the items (the JSON of `Item`), or
            "bytes": "hex",              the function's code from position 0, decoded (linked)
                                         with `decodeItem` from `pos` to its end
            "pos": n,                    position of the first item in the function (default 0)
            "base": a,                   the function's address (`Ctx.base`)
            "refs": [[Ref, a], ..],      where each `Ref` lives (others: 0)
            "state": {"regs": [16 x u64], "rip": a, "flags": {"cf": b, "zf": b, "sf": b, "of": b},
                      "xmm": [16 x u128], "mem": [[a, "hex"], ..]}}
  response {"items": [..], "bytes": "hex", "state": {..}}   the items, their linked bytes at
                                         `base + pos`, the state after them (`execItems`, the
                                         same memory regions; an undefined flag is `null`)
           {"items": [..], "bytes": "hex", "fault": Fault}
           {"error": "message"}          unparsable request, undecodable bytes, an item not `wf`

Memory outside the regions reads as 0. The items run in order whatever they do to `rip` (see
`execItems`), so a run of several items should have no control flow but in its last item.
-/
import Ryo.X86.Exec
import Ryo.X86.Decode

namespace Ryo.X86.Cosim

open Lean

def hexDigit (c : Char) : Option Nat :=
  if '0' ≤ c ∧ c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c ∧ c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c ∧ c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

def unhex (s : String) : Except String (Array UInt8) := go s.toList #[]
where
  go : List Char → Array UInt8 → Except String (Array UInt8)
    | [], acc => pure acc
    | a :: b :: rest, acc => match hexDigit a, hexDigit b with
      | some x, some y => go rest (acc.push (UInt8.ofNat (16 * x + y)))
      | _, _ => throw s!"bad hex digit in {s}"
    | [_], _ => throw "odd number of hex digits"

def hex (bs : List UInt8) : String :=
  String.join (bs.map fun b =>
    let d := Nat.toDigits 16 b.toNat
    String.ofList (if d.length < 2 then '0' :: d else d))

/-- A memory region: its start and bytes. -/
structure Region where
  start : BitVec 64
  bytes : Array UInt8

def regionMem (rs : List Region) : Mem := fun a =>
  rs.foldr (fun r acc =>
    let i := (a - r.start).toNat
    if h : i < r.bytes.size then r.bytes[i] else acc) 0

def field {α : Type} [FromJson α] (j : Json) (k : String) : Except String α := do
  match fromJson? (← j.getObjVal? k) with
  | .ok v => pure v
  | .error e => throw s!"{k}: {e}"

def fieldD {α : Type} [FromJson α] (j : Json) (k : String) (d : α) : Except String α :=
  match j.getObjVal? k with
  | .ok .null | .error _ => pure d
  | .ok v => (fromJson? v).mapError fun e => s!"{k}: {e}"

def parseRegion (j : Json) : Except String Region := do
  match j with
  | .arr #[a, .str h] => pure ⟨← fromJson? a, ← unhex h⟩
  | _ => throw s!"bad memory region {j.compress}"

def parseState (j : Json) : Except String (State × List Region) := do
  let regs : Array (BitVec 64) ← field j "regs"
  let xmm : Array (BitVec 128) ← fieldD j "xmm" #[]
  let flags : Flags ← fieldD j "flags" {}
  let mem ← (← fieldD j "mem" ([] : List Json)).mapM parseRegion
  pure ({ regs := fun i => regs.getD i.val 0, rip := ← field j "rip", flags,
          xmm := fun i => xmm.getD i.val 0, mem := regionMem mem }, mem)

def stateJson (s : State) (regions : List Region) : Json :=
  let flag (b : Option Bool) : Json := match b with | some b => toJson b | none => .null
  Json.mkObj [
    ("regs", toJson ((List.finRange 16).map s.regs)),
    ("rip", toJson s.rip),
    ("flags", Json.mkObj [("cf", flag s.flags.cf), ("zf", flag s.flags.zf),
      ("sf", flag s.flags.sf), ("of", flag s.flags.of)]),
    ("xmm", toJson ((List.finRange 16).map s.xmm)),
    ("mem", toJson (regions.map fun r =>
      Json.arr #[toJson r.start, .str (hex ((List.range r.bytes.size).map fun i =>
        s.mem (r.start + BitVec.ofNat 64 i)))]))]

/-- Decodes linked code from `pos` to its end. -/
def decodeAll (code : Array UInt8) (pos : Nat) (base : BitVec 64) (refs : List (Ref × BitVec 64)) :
    Except String (List Item) := do
  let resolve : LinkMap := fun a => (refs.find? (·.2 == a)).map (·.1)
  let record := ((refs.find? (·.1 == .record)).map (·.2)).getD 0
  let rec go (p : Nat) (fuel : Nat) (acc : List Item) : Except String (List Item) :=
    match fuel with
    | 0 => pure acc.reverse
    | fuel + 1 =>
      if p ≥ code.size then pure acc.reverse else
      match decodeItem { code, pos := p, fields := .linked base record resolve } with
      | some (i, n) => go (p + n) fuel (i :: acc)
      | none => throw s!"no item decodes at position {p}"
  go pos code.size []

def handle (j : Json) : Except String Json := do
  let pos : Nat ← fieldD j "pos" 0
  let base : BitVec 64 ← field j "base"
  let refsJ : List (Json × BitVec 64) ← fieldD j "refs" []
  let refs ← refsJ.mapM fun (r, a) => do
    let r : Ref ← fromJson? r
    pure (r, a)
  let items : List Item ← match j.getObjVal? "items" with
    | .ok v => (fromJson? v).mapError fun e => s!"items: {e}"
    | .error _ => do decodeAll (← unhex (← field j "bytes")) pos base refs
  let (_, bad) := items.foldl (fun (p, bad) i =>
    (p + i.len, bad || !i.wf (BitVec.ofNat 32 p))) (pos, false)
  if bad then throw "an item is not wf at its position"
  let addrOf : RefAddr := fun r => ((refs.find? (·.1 == r)).map (·.2)).getD 0
  let (code, relocs) := encodeItems items pos
  let linked := (link base addrOf (List.replicate pos 0 ++ code) relocs).drop pos
  let (s, regions) ← parseState (← j.getObjVal? "state")
  let common := [("items", toJson items), ("bytes", Json.str (hex linked))]
  pure <| match execItems { base, addrOf } items s with
    | .ok s' => Json.mkObj (common ++ [("state", stateJson s' regions)])
    | .error f => Json.mkObj (common ++ [("fault", toJson f)])

/-- The `exec-item` loop: a response line per request line, until end of input. -/
partial def main : IO UInt32 := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  let rec loop : IO Unit := do
    let line ← stdin.getLine
    if line.isEmpty then return
    let line := line.trimAscii.toString
    if !line.isEmpty then
      let out := match Json.parse line with
        | .ok j => match handle j with
          | .ok r => r
          | .error e => Json.mkObj [("error", .str e)]
        | .error e => Json.mkObj [("error", .str s!"bad JSON: {e}")]
      stdout.putStrLn out.compress
      stdout.flush
    loop
  loop
  pure 0

end Ryo.X86.Cosim
