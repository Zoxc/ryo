/-
Ryo.Check.Image.Registry — the registry stub of a link (`objfile.rs` `write_registry`,
aot.md §C4 "Registry object"), the same for every crate of one ryo build, and the link-level
checks. The stub's names carry the ABI tag of its build (`<tag>`, that of its one
`ryo_images_<tag>` section, `objectTag`):

- the constructor in `.text.ryo_registry` is exactly `lea rdi, [rip + __start_ryo_images_<tag>];
  lea rsi, [rip + __stop_ryo_images_<tag>]; lea rdx, [rip + __ryo_registry_anchor_<tag>];
  jmp ryo_vm_register_<tag>` (`Ryo.X86.registryCtor`, decoded by `Ryo.X86.decodeX` from the
  relocations: the `lea`s' fields `R_X86_64_PC32` − 4 against the undefined hidden bounds the
  linker defines for `ryo_images_<tag>` and against the anchor, the `jmp`'s `R_X86_64_PLT32` − 4
  against the undefined hidden `ryo_vm_register_<tag>` (mangled: the link unit's own `ryo_rt`),
  nothing else), and nothing follows it: `ryo_vm_register(start, end, anchor)`, which registers
  the entries whose header's `anchor` is this one;
- `.init_array.00000` is one `R_X86_64_64` + 0 to the constructor;
- its own registration entry: an 8-byte `ryo_images_<tag>` section (`SHF_ALLOC | SHF_WRITE |
  SHF_GNU_RETAIN`), zero and unrelocated (`ryo_vm_register` skips null entries; it makes the
  section, and so its bounds, exist in every link);
- `__ryo_registry_anchor_<tag>` is defined, weak and hidden (several stubs in one link don't
  clash);
- no other section is relocated (there is no image list: each image object brings its own
  entry, `checkEntry` in `Ryo/Check/Image/Relocs.lean`);
- with the link's image objects: each has the stub's tag (`checkTags`: an image of another
  tag is in another build's entry list, which this stub doesn't register), no two have the same
  `(crate_hash, cgu_hash)` (which `ryo_vm_register` rejects), and the link has at most one
  `__ryo_main`.

ELF only (the PE and Mach-O stubs are out of scope; `registryCtor true` is the PE form).
-/
import Ryo.Check.Image.Common
import Ryo.X86.Extra

namespace Ryo.Check.Image

open Ryo.Obj Ryo.X86

/-- Whether `s` is an image symbol: the prefix, 16 lowercase hex digits, `_`, 16 more. -/
def isImageSymbol (s : String) : Bool :=
  let hex16? (t : String) := t.length == 16 && t.all fun c => c.isDigit || ('a' ≤ c && c ≤ 'f')
  s.startsWith imageSymbolPrefix &&
    match ((s.drop imageSymbolPrefix.length).toString.splitOn "_") with
    | [a, b] => hex16? a && hex16? b
    | _ => false

/-- A registry stub's checks: its mismatches. -/
def checkRegistry (e : Elf) : Array String := Id.run do
  let mut out : Array String := #[]
  let tag ← match objectTag e with
    | .ok t => pure t
    | .error m => return #[s!"registry: {m}"]
  let anchor := anchorName tag
  let entries := entriesSection tag
  match (e.symbols.filter (·.name == anchor)).toList with
  | [s] =>
    if !s.defined then out := out.push s!"registry: `{anchor}` isn't defined"
    else if s.bind != Elf.STB_WEAK || s.visibility != Elf.STV_HIDDEN then
      out := out.push s!"registry: `{anchor}` isn't weak and hidden (bind {s.bind}, visibility {s.visibility})"
  | l => out := out.push s!"registry: {l.length} `{anchor}` symbols"
  let text := e.sectionByName? ".text.ryo_registry"
  let init := e.sectionByName? ".init_array.00000"
  -- The stub's null entry (`objectTag` found exactly one such section).
  if let some s := e.sectionByName? entries then
    let want := Elf.SHF_ALLOC ||| Elf.SHF_WRITE ||| Elf.SHF_GNU_RETAIN
    if s.flags &&& (want ||| Elf.SHF_EXECINSTR) != want then
      out := out.push s!"registry entry: `{entries}` flags {s.flags}, not SHF_ALLOC | SHF_WRITE | SHF_GNU_RETAIN"
    if s.size != 8 || !allBytes (e.data s) 0 8 0 then
      out := out.push s!"registry entry: `{entries}` isn't 8 zero bytes ({s.size} bytes)"
    if !(e.relocsOf s.index).isEmpty then out := out.push s!"registry entry: `{entries}` is relocated"
  -- Relocations elsewhere.
  for rs in e.relas do
    let ok := text.any (·.index == rs.target) || init.any (·.index == rs.target)
    if !ok then
      let name := (e.section? rs.target).map (·.name) |>.getD s!"section {rs.target}"
      out := out.push s!"registry: relocations of `{name}`"
  -- The constructor.
  match text, init with
  | some t, some ia =>
    let mut acc : Array XReloc := #[]
    for r in e.relocsOf t.index do
      let sym := relSymbol e r
      -- Undefined, global and hidden: bound in this link unit.
      let hiddenRef (ok : String → Bool) := sym.any fun s => ok s.name && !s.defined && s.type != Elf.STT_SECTION
        && s.bind == Elf.STB_GLOBAL && s.visibility == Elf.STV_HIDDEN
      let isAnchor := sym.any fun s => s.name == anchor && s.defined && s.type != Elf.STT_SECTION
      if r.type == .pc32 && hiddenRef (· == entriesStartName tag) && r.addend == -4 then
        acc := acc.push ⟨r.offset, .entriesStart⟩
      else if r.type == .pc32 && hiddenRef (· == entriesStopName tag) && r.addend == -4 then
        acc := acc.push ⟨r.offset, .entriesEnd⟩
      else if r.type == .pc32 && isAnchor && r.addend == -4 then acc := acc.push ⟨r.offset, .anchor⟩
      else if r.type == .plt32 && hiddenRef (isRtSymbol (tagged registerName tag)) && r.addend == -4 then
        acc := acc.push ⟨r.offset, .vmRegister⟩
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
      if items != registryCtor false then
        out := out.push s!"registry constructor: {items.length} forms, not `lea rdi, [rip + {entriesStartName tag}]; lea rsi, [rip + {entriesStopName tag}]; lea rdx, [rip + {anchor}]; jmp {tagged registerName tag}`"
    if t.flags &&& Elf.SHF_EXECINSTR == 0 then out := out.push "registry constructor: `.text.ryo_registry` isn't executable"
    -- `.init_array.00000`.
    match slotInit e ia t with
    | some m => out := out.push s!"registry .init_array.00000: {m}"
    | none => pure ()
  | _, _ => out := out.push "registry: the constructor and `.init_array.00000` aren't both there"
  return out
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

/-- The image objects (by path) whose ABI tag isn't the registry stub's `tag`: the stub's
constructor doesn't register them (their entries are in another tag's section, and their
`anchor` is another tag's). -/
def checkTags (tag : String) (images : Array (String × String)) : Array String :=
  images.filterMap fun (path, t) =>
    if t == tag then none
    else some s!"link: `{path}` has ABI tag `{t}`, the registry stub `{tag}`"

/-- The link-level checks, on each image object's symbol, `crate_hash` and `cgu_hash`: no two
objects with the same `(crate_hash, cgu_hash)` (`ryo_vm_register` rejects them), at most one
`__ryo_main`. That each object registers itself is its entry (`checkEntry`). -/
def checkLink (images : Array (String × Nat × Nat)) (mains : Nat) : Array String := Id.run do
  let mut out : Array String := #[]
  let mut seen : Std.HashMap (Nat × Nat) String := {}
  for (s, ch, cg) in images do
    match seen[(ch, cg)]? with
    | some t => out := out.push s!"link: `{s}` and `{t}` have the same crate_hash and cgu_hash"
    | none => seen := seen.insert (ch, cg) s
  if mains > 1 then out := out.push s!"link: {mains} image objects define {mainSlotName}"
  return out

end Ryo.Check.Image
