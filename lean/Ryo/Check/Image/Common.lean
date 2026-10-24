/-
Ryo.Check.Image.Common — what the image checks (aot.md §C4) share: each function's decoding
(done once, used by the function-table and the relocation checks), names of `ryo_rt`'s symbols,
and small helpers.

A check returns its mismatches as lines of text, and never stops at the first: an empty array
means the object passed.
-/
import Ryo.Vm.DecodeObj

namespace Ryo.Check.Image

open Ryo.Obj Ryo.Vm Ryo.Vm.R

/-- `ryo_rt`'s symbols the image objects reference (`objfile.rs`), before mangling. -/
def tripEntryName : String := "ryo_jit_trip_entry"
def tripOsrName : String := "ryo_jit_trip_osr"
def anchorName : String := "__ryo_registry_anchor"
def mainSlotName : String := "__ryo_main"
def registerName : String := "ryo_vm_register"

/-- Whether `name` is `ryo_rt`'s symbol `base`: unmangled, or as rustc mangles internal symbols
(a v0 identifier `<len><base>` ending the name), as `ImageObject.isProbe` reads
`ryo_probe_stack`. -/
def isRtSymbol (base name : String) : Bool :=
  name == base || name.endsWith (toString base.length ++ base)

/-- `image::JIT_THRESHOLD`, `JIT_ENTRY_SLOT`, `JIT_OSR_SLOT`, and the offsets of
`JitRecord::func` and `JitRecord::header`. -/
def jitThreshold : Nat := 10000
def jitEntrySlot : Nat := 8
def jitOsrSlot : Nat := 16
def jitFuncOff : Nat := 36
def jitHeaderOff : Nat := 40

/-- `asm::RET_SRET`. -/
def RET_SRET : Nat := 2 ^ 31

def hex (n : Nat) : String := "0x" ++ String.ofList (Nat.toDigits 16 n)

/-- `n` as 16 lowercase hex digits (`{:016x}`). -/
def hex16 (n : Nat) : String :=
  let s := String.ofList (Nat.toDigits 16 n)
  String.ofList (List.replicate (16 - s.length) '0') ++ s

/-- `image::crate_hash`. -/
def crateHash (id : Nat) : Nat := (id ^^^ (id >>> 32)) % 2 ^ 32

/-- `true` iff the bytes `[off, off + n)` of `b` are all `v` (and in bounds). -/
def allBytes (b : ByteArray) (off n : Nat) (v : UInt8) : Bool :=
  off + n ≤ b.size && (List.range n).all fun i => b[off + i]! == v

/-- A function's decoding: its inputs as `Ryo.Obj.funcInputs` reads them, and the decoded code
as `scripts/lean-decode-diff.py --decode` compares it with Rust's (`DecodeObj.decodeFunc`,
linked at made-up addresses), or why there is none. -/
structure FuncDecoding where
  inputs : Except String FuncInputs
  decoded : Except String Decoded

/-- Decodes every function of the image once. -/
def decodeAll (o : ImageObject) : Array FuncDecoding :=
  (Array.range o.funcs.size).map fun i =>
    let inputs := o.funcInputs i
    let decoded : Except String Decoded := match inputs with
      | .error e => .error e
      | .ok fi => match DecodeObj.decodeFunc fi with
        | .error e => .error e
        | .ok none => .error "malformed dropped store"
        | .ok (some (.error e)) => .error s!"{e.what} at {e.at_}"
        | .ok (some (.ok d)) => .ok d
    { inputs, decoded }

/-- The label of function `i` in mismatch lines: its index and symbol. -/
def funcLabel (o : ImageObject) (i : Nat) : String :=
  match o.funcs[i]? with
  | some f => s!"func {i} {o.funcName f.codeOff}"
  | none => s!"func {i}"

/-- The symbol a relocation is against, if in range. -/
def relSymbol (e : Elf) (r : Rela) : Option Symbol := e.symbol? r.sym

/-- A relocation in text form, for mismatch lines. -/
def relaText (e : Elf) (r : Rela) : String :=
  let name := (relSymbol e r).map e.symbolName |>.getD s!"symbol {r.sym}"
  s!"{r.type.name} at {r.offset} against `{name}` {if r.addend < 0 then "-" else "+"} {r.addend.natAbs}"

end Ryo.Check.Image
