/-
Ryo.Check.Image.Common — what the image checks (aot.md §C4) share: each function's decoding
(done once, used by the function-table and the relocation checks), the names of the runtime and
registry symbols with the ABI tag, and small helpers.

A check returns its mismatches as lines of text, and never stops at the first: an empty array
means the object passed.
-/
import Ryo.Vm.DecodeObj

namespace Ryo.Check.Image

open Ryo.Obj Ryo.Vm Ryo.Vm.R

/-- The symbols the image objects and the registry stub reference (`objfile.rs`,
`rt_symbols.rs`), before the ABI tag and mangling: `ryo_rt`'s trips and `ryo_vm_register`,
the registry stub's anchor. Each carries the ABI tag of the ryo build as a suffix,
`<name>_<tag>` (`tagged`, design/build.md#the-abi-tag); the `ryo_rt` ones are mangled as
internal symbols (`isRtSymbol`). `__ryo_main` (the binary's entry slot) is untagged. -/
def tripEntryName : String := "ryo_jit_trip_entry"
def tripOsrName : String := "ryo_jit_trip_osr"
def anchorBase : String := "__ryo_registry_anchor"
def mainSlotName : String := "__ryo_main"
def registerName : String := "ryo_vm_register"
/-- The prefix of the ELF section of the registration entries (`objfile.rs` `elf_entries`). -/
def entriesBase : String := "ryo_images"

/-- `name` with the ABI tag `tag` as a suffix (`rt_symbols::tagged!`, `objfile.rs`). -/
def tagged (name tag : String) : String := name ++ "_" ++ tag

/-- The registry anchor of ABI tag `tag` (`objfile::anchor_symbol`), unmangled. -/
def anchorName (tag : String) : String := tagged anchorBase tag
/-- The ELF section of the registration entries, `ryo_images_<tag>` (`elf_entries`), and the
bounds the linker defines for it. -/
def entriesSection (tag : String) : String := tagged entriesBase tag
def entriesStartName (tag : String) : String := "__start_" ++ entriesSection tag
def entriesStopName (tag : String) : String := "__stop_" ++ entriesSection tag

/-- `image::fnv1a`, 64-bit FNV-1a: `image::cgu_hash` of a codegen unit's name and
`ryo_bytecode::ABI` of the ABI tag. -/
def fnv1a (s : String) : Nat :=
  s.toUTF8.foldl (fun h b => ((h ^^^ b.toNat) * 0x100000001b3) % 2 ^ 64) 0xcbf29ce484222325

/-- `ryo_bytecode::ABI` of tag `tag`: the image header's `abi`. -/
def abiHash (tag : String) : Nat := fnv1a tag

/-- The ABI tags of an object's `ryo_images_<tag>` sections (an image object and a registry
stub each have one): the tag the checks hold the object's other names to. -/
def entryTags (e : Elf) : Array String :=
  e.sections.filterMap fun s =>
    if s.name.startsWith (entriesBase ++ "_") then
      let t := (s.name.drop (entriesBase.length + 1)).toString
      if t.isEmpty then none else some t
    else none

/-- The object's ABI tag: that of its one `ryo_images_<tag>` section, or why there is none. -/
def objectTag (e : Elf) : Except String String :=
  match (entryTags e).toList with
  | [t] => .ok t
  | l => .error s!"{l.length} `{entriesBase}_<tag>` sections, not 1"

/-- Whether `name` is `ryo_rt`'s symbol `base` (with its tag: `tagged`): unmangled, or as
rustc mangles internal symbols (a v0 identifier `<len><base>` ending the name), as
`ImageObject.isProbe` reads `ryo_probe_stack`. -/
def isRtSymbol (base name : String) : Bool :=
  name == base || name.endsWith (toString base.length ++ base)

/-- `image::JIT_THRESHOLD` (the loop counter `ctr_l` starts at its negation),
`JIT_ENTRY_THRESHOLD` (likewise the call counter `ctr_e`), `JIT_ENTRY_SLOT`, `JIT_OSR_SLOT`,
the offsets of `JitRecord::func` and `JitRecord::header`, and `JIT_LOOP_CTR` (`ctr_l`'s). -/
def jitThreshold : Nat := 10000
def jitEntryThreshold : Nat := jitThreshold / 16
def jitEntrySlot : Nat := 8
def jitOsrSlot : Nat := 16
def jitFuncOff : Nat := 36
def jitHeaderOff : Nat := 40
def jitLoopCtrOff : Nat := 56

/-- `asm::RET_SRET`. -/
def RET_SRET : Nat := 2 ^ 31

def hex (n : Nat) : String := "0x" ++ String.ofList (Nat.toDigits 16 n)

/-- `n` as 16 lowercase hex digits (`{:016x}`). -/
def hex16 (n : Nat) : String :=
  let s := String.ofList (Nat.toDigits 16 n)
  String.ofList (List.replicate (16 - s.length) '0') ++ s

/-- The symbol an image defines (`objfile::image_symbol`):
`__ryo_image_<stable_crate_id>_<cgu_hash>`, both as 16 hex digits. -/
def imageSymbol (stableCrateId cguHash : Nat) : String :=
  imageSymbolPrefix ++ hex16 stableCrateId ++ "_" ++ hex16 cguHash

/-- `image::cgu_hash`: 64-bit FNV-1a of a codegen unit's name. -/
def cguHash (name : String) : Nat := fnv1a name

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
      | .ok fi => match DecodeObj.decodeFunc fi (DecodeObj.listHints o i) with
        | .error e => .error e
        | .ok none => .error "malformed instruction list"
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
