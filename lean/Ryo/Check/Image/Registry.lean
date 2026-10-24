/-
Ryo.Check.Image.Registry — the registry object of a link (`objfile.rs` `write_registry`,
aot.md §C4 "Registry object"), and what ties it to the link's image objects:

- the constructor in `.text.ryo_registry` is exactly `lea rdi, [rip + images]; mov esi, n;
  jmp ryo_vm_register` (`Ryo.X86.registryCtor`, decoded by `Ryo.X86.decodeX` from the
  relocations: the `lea`'s field `R_X86_64_PC32` − 4 against the image list, the `jmp`'s
  `R_X86_64_PLT32` − 4 against `ryo_vm_register`, nothing else), and nothing follows it;
- `.init_array.00000` is one `R_X86_64_64` + 0 to the constructor;
- the list (`.data.rel.ro.ryo_registry`) has one `R_X86_64_64` + 0 per 8-byte entry, each
  against an undefined `__ryo_image_<16 hex digits>`, no name twice, and `n` is the entry
  count;
- `__ryo_registry_anchor` is defined;
- with the link's image objects: each one's image symbol is in the list exactly once (the
  list may name images of objects not given: upstream crates' images in their rlibs), and
  the link has at most one `__ryo_main`.

ELF only (the PE constructor, `register_import`, is out of scope).
-/
import Ryo.Check.Image.Common
import Ryo.X86.Extra

namespace Ryo.Check.Image

open Ryo.Obj Ryo.X86

/-- Whether `s` is an image symbol: the prefix and 16 lowercase hex digits. -/
def isImageSymbol (s : String) : Bool :=
  s.startsWith imageSymbolPrefix &&
    let rest := (s.drop imageSymbolPrefix.length).toString
    rest.length == 16 && rest.all fun c => c.isDigit || ('a' ≤ c && c ≤ 'f')

/-- A registry object's checks: mismatches, and the image symbols its list names. -/
def checkRegistry (e : Elf) : Array String × Array String := Id.run do
  let mut out : Array String := #[]
  match (e.symbols.filter (·.name == anchorName)).toList with
  | [s] => if !s.defined then out := out.push s!"registry: `{anchorName}` isn't defined"
  | l => out := out.push s!"registry: {l.length} `{anchorName}` symbols"
  let list := e.sectionByName? ".data.rel.ro.ryo_registry"
  let text := e.sectionByName? ".text.ryo_registry"
  let init := e.sectionByName? ".init_array.00000"
  -- The list.
  let mut names : Array String := #[]
  if let some l := list then
    if l.size % 8 != 0 then out := out.push s!"registry list: {l.size} bytes"
    if !allBytes (e.data l) 0 l.size 0 then out := out.push "registry list: nonzero bytes"
    let rs := e.relocsOf l.index
    let mut at_ : Array (Option String) := Array.replicate (l.size / 8) none
    for r in rs do
      let t := relaText e r
      let sym := relSymbol e r
      if r.type != .abs64 || r.addend != 0 || r.offset % 8 != 0 then
        out := out.push s!"registry list: {t}"; continue
      let some s := sym | out := out.push s!"registry list: {t}"; continue
      if s.defined || !isImageSymbol s.name then
        out := out.push s!"registry list: {t}, not an (undefined) image symbol"; continue
      let k := r.offset / 8
      if at_[k]?.join.isSome then out := out.push s!"registry list: entry {k} relocated twice"
      at_ := at_.set! k (some s.name)
    for k in [0:at_.size] do
      match at_[k]! with
      | none => out := out.push s!"registry list: entry {k} has no relocation"
      | some n =>
        if names.contains n then out := out.push s!"registry list: `{n}` listed twice"
        names := names.push n
  -- The constructor.
  match list, text, init with
  | none, none, none => pure ()
  | some l, some t, some ia =>
    let mut acc : Array XReloc := #[]
    for r in e.relocsOf t.index do
      let sym := relSymbol e r
      let isList := sym.any fun s => s.type == Elf.STT_SECTION && s.shndx == l.index && s.value == 0
      let isReg := sym.any fun s => s.type != Elf.STT_SECTION && !s.defined && s.name == registerName
      if r.type == .pc32 && isList && r.addend == -4 then acc := acc.push ⟨r.offset, .images⟩
      else if r.type == .plt32 && isReg && r.addend == -4 then acc := acc.push ⟨r.offset, .vmRegister⟩
      else out := out.push s!"registry constructor: {relaText e r}"
    let xrs := acc.qsort (·.pos < ·.pos)
    let code := (e.data t).data
    let rec go (c : XCursor) (fuel : Nat) (acc : List XItem) : Option (List XItem) :=
      match fuel with
      | 0 => some acc.reverse
      | fuel + 1 =>
        if c.pos ≥ c.code.size then some acc.reverse
        else match decodeX c with
          | some (x, n) => go { c with pos := c.pos + n } fuel (x :: acc)
          | none => none
    match go { code, pos := 0, fields := .relocs xrs } code.size [] with
    | none => out := out.push "registry constructor: not canonical code"
    | some items =>
      let n := match items with
        | [_, .movImm32 _ n, _] => n
        | _ => 0
      if items != registryCtor n false false then
        out := out.push s!"registry constructor: {items.length} forms, not `lea rdi, [rip + images]; mov esi, n; jmp {registerName}`"
      else if n.toNat != l.size / 8 then
        out := out.push s!"registry constructor: n = {n.toNat}, the list has {l.size / 8} entries"
    if t.flags &&& Elf.SHF_EXECINSTR == 0 then out := out.push "registry constructor: `.text.ryo_registry` isn't executable"
    -- `.init_array.00000`.
    match slotInit e ia t with
    | some m => out := out.push s!"registry .init_array.00000: {m}"
    | none => pure ()
  | _, _, _ => out := out.push "registry: the list, the constructor and `.init_array.00000` aren't all there"
  return (out, names)
where
  /-- One `R_X86_64_64` + 0 at offset 0 of the 8-byte `.init_array` section, to the
  constructor's start. -/
  slotInit (e : Elf) (ia t : Section) : Option String :=
    let rs := e.relocsOf ia.index
    if ia.type != 14 then some s!"type {ia.type}, not SHT_INIT_ARRAY"
    else if ia.size != 8 then some s!"{ia.size} bytes"
    else match rs.toList with
      | [r] =>
        let ok := r.offset == 0 && r.type == .abs64 &&
          (relSymbol e r).any fun s => s.shndx == t.index && (s.value : Int) + r.addend == 0
        if ok && allBytes (e.data ia) 0 8 0 then none else some (relaText e r)
      | l => some s!"{l.length} relocations"

/-- The link-level checks: each image object's symbol in the registry list exactly once, at
most one `__ryo_main`. -/
def checkLink (images : Array String) (listed : Option (Array String)) (mains : Nat) : Array String := Id.run do
  let mut out : Array String := #[]
  if let some l := listed then
    for s in images do
      let n := (l.filter (· == s)).size
      if n != 1 then out := out.push s!"link: `{s}` is in the registry list {n} times"
  if mains > 1 then out := out.push s!"link: {mains} image objects define {mainSlotName}"
  return out

end Ryo.Check.Image
