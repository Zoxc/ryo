/-
Ryo.Check.Image.Relocs — the relocations of an image object (aot.md §C4: "Relocations",
"Symbol slots", "JIT records", "Image header", the anchor and `__ryo_main` slots), against
the writer's mapping (`ImageWriter::finish_encoded`, `objfile.rs` `write_image`).

**Text.** Every relocated field the decoder meets must carry a relocation of the kind its form
needs, and no relocation may be anywhere else. The decoder of record (`DecodeObj.decodeFunc`)
reads the code linked at made-up addresses, which says nothing about where relocations were;
so each function is decoded a second time from its unlinked bytes with `Fields.relocs`, the
object's relocations as `ImageObject.refOf` maps them (`R_X86_64_PLT32` with addend −4 against
`ryo_h_<op>` or `ryo_probe_stack`; `R_X86_64_PC32` into the symbol slots, the code constants,
the pool, the site cache, the data area or the function's JIT record; anything else is a
mismatch). Calls between the image's functions carry no relocation (the writer resolves
them), so for that decode a `Ref.func` field is added at every `call`/`jmp rel32` (`e8`/`e9`)
whose unrelocated displacement leaves the function for a function's first byte. With
`Fields.relocs` `decodeItem` accepts an item only if the relocations starting in its bytes are
exactly its own fields' (`Cursor.encodedAt`), padding and jump table entries only without
any, and the R decoder only takes each form's references (handlers and the probe for `call`,
addresses for `lea`, a slot for `call [rip + x]`, the record's counters for `inc`). So if this
decode succeeds and gives the same R code as the linked one, every relocation starting inside
an item is that item's field, of a kind its form takes. What the items don't cover (the
`int3`s before a jump table) is covered by the field bytes check: a relocated field's bytes
are 0 in the object (RELA: the addend is in the relocation), never `int3`. Relocations
outside every function, overlapping ones and ones in no image section are mismatches.

**Read-only section**: the header's `data` and `text` fields (`R_X86_64_64` to the start of
the writable and text sections), the symbol slots (exactly one `R_X86_64_64` + 0 each, against
a symbol, its `SYM_INDIRECT` flag clear: ELF), and pool pointers (`R_X86_64_64` at 8-aligned
pool offsets, against one of the image's symbols, or into the pool or the data area); nothing
else. The header's constant relocation table (`const_relocs`) is exactly the pool offsets of
the pool pointers, in order. That a pool pointer is the allocation's provenance is the pool
check (`Ryo/Check/Image/Pool.lean`).

**Writable section**: the JIT records (with counters, one per function): `ctr_e` =
`-JIT_ENTRY_THRESHOLD` (at 0), `ctr_l` = `-JIT_THRESHOLD` (at `JIT_LOOP_CTR`), `func` its
index, every other byte 0; `entry` and `osr` relocated
(`R_X86_64_64` + 0) against `ryo_jit_trip_entry` and `ryo_jit_trip_osr`, `header` against the
image's header; data-area pointers as the pool's; nothing in the site cache.

**Header**: the image symbol is `__ryo_image_<stable_crate_id>_<cgu_hash>` (each as 16 hex
digits), `crate_hash` folds the id, the sections are where and as large as the header says (the read-only one RELRO).
**Anchor**: one `R_X86_64_64` + 0 against `__ryo_registry_anchor`, the only content of an
8-byte RELRO section. **Registration entry**: one 8-byte `ryo_images` section
(`SHF_ALLOC | SHF_WRITE | SHF_GNU_RETAIN`), its one `R_X86_64_64` + 0 field against the start
of the read-only section (the header), which the registry stub's constructor passes to
`ryo_vm_register` with the other objects' (`Ryo/Check/Image/Registry.lean`). **`__ryo_main`**: at most one, an 8-byte slot with one `R_X86_64_64` + 0
against a symbol, which, if this object defines it, is one of its functions. Which function
it must be (`main`'s instance) needs the dump.
-/
import Ryo.Check.Image.Common

namespace Ryo.Check.Image

open Ryo.Obj Ryo.Vm Ryo.Vm.R

/-! ## Text -/

/-- The relocated-field decode of function `i`: its relocations as `refOf` maps them (the
mismatches of those it can't map), the added `Ref.func` fields, and the decode. -/
def relocDecode (o : ImageObject) (i : Nat) (fi : FuncInputs) :
    Array String × Except String Decoded := Id.run do
  let f := o.funcs[i]!
  let l := funcLabel o i
  let mut out : Array String := #[]
  let mut rs : Array Ryo.X86.Reloc := #[]
  let objRelocs := o.textRelocsIn f.codeOff f.codeLen
  for r in objRelocs do
    let pos := r.offset - o.textBase - f.codeOff
    match o.refOf i r with
    | .error e => out := out.push s!"{l}: relocation at {pos}: {e}"
    | .ok (.func g) =>
      out := out.push s!"{l}: relocation at {pos} against the text (func {g}): calls between functions carry none"
    | .ok ref => rs := rs.push ⟨pos, DecodeObj.toRef ref⟩
  let poss := objRelocs.map (·.offset - o.textBase - f.codeOff)
  let code := fi.code
  for p in [1:code.size] do
    if p + 4 > code.size then break
    let b := code[p - 1]!
    if b != 0xe8 && b != 0xe9 then continue
    -- No object relocation's field overlaps the opcode or the displacement.
    if poss.any fun q => q + 4 > p - 1 && q < p + 4 then continue
    let d := toSigned 32 ((readU32 code p).toOption.getD 0)
    let t : Int := (p + 4 : Nat) + d
    if 0 < t && t < code.size then continue
    let abs := (f.codeOff : Int) + t
    if abs < 0 then continue
    if let some g := fi.funcAt? abs.toNat then rs := rs.push ⟨p, .func g⟩
  let sorted := rs.qsort (·.pos < ·.pos)
  let kind (k : Ryo.Obj.ScopeKind) : R.ScopeKind := match k with
    | .escape a => .escape a
    | .end => .end
    | .lend => .lend
  let scopes := fi.scopes.map fun s => R.Scope.mk s.codeOffset (BitVec.ofInt 32 s.frameOffset) s.size (kind s.kind)
  let some dropped := fi.dropped.mapM fun d =>
      Asm.DroppedStore.ofParts? d.pos (BitVec.ofInt 32 d.frameOffset) d.size d.reg
    | return (out, .error "malformed instruction list")
  let r := decodeReduced code sorted fi.rodata fi.callSites dropped scopes fi.mode
  return (out, match r with
    | .ok d => .ok d
    | .error e => .error s!"{e.what} at {e.at_}")

def checkTextRelocs (o : ImageObject) (ds : Array FuncDecoding) : Array String := Id.run do
  let mut out : Array String := #[]
  let tdata := o.elf.data o.text
  let rs := o.textRelocs
  let starts := o.funcs.map (·.codeOff)
  for h : j in [0:rs.size] do
    let r := rs[j]
    let w := if r.type == .abs64 then 8 else 4
    if let some r2 := rs[j + 1]? then
      if r2.offset < r.offset + w then
        out := out.push s!"text: relocations at {r.offset} and {r2.offset} overlap"
    if !allBytes tdata r.offset w 0 then
      out := out.push s!"text: the field of the relocation at {r.offset} isn't zero"
    -- Inside a function?
    let inside := r.offset ≥ o.textBase && (
      let off := r.offset - o.textBase
      match (rustBinarySearch starts off) with
      | .ok k => off + w ≤ starts[k]! + o.funcs[k]!.codeLen
      | .error 0 => false
      | .error k => off + w ≤ starts[k - 1]! + o.funcs[k - 1]!.codeLen)
    if !inside then
      out := out.push s!"text: {relaText o.elf r} outside every function"
  for h : i in [0:ds.size] do
    let (.ok fi, .ok d) := (ds[i].inputs, ds[i].decoded) | continue
    let (bad, r) := relocDecode o i fi
    out := out ++ bad
    match r with
    | .error e => out := out.push s!"{funcLabel o i}: decode by relocations: {e} (the linked decode succeeds)"
    | .ok d2 =>
      let a := DecodeObj.funcLines d
      let b := DecodeObj.funcLines d2
      if a != b then
        let k := (List.range (max a.size b.size)).find? (fun k => a[k]? != b[k]?) |>.getD 0
        out := out.push s!"{funcLabel o i}: decode by relocations differs from the linked decode at line {k}: `{(b[k]?.getD "<end>").trimAscii}` vs `{(a[k]?.getD "<end>").trimAscii}`"
  return out

/-! ## Read-only and writable sections -/

/-- The names of the image's symbol slots (`ImageObject.slotName`), `none` where unreadable. -/
def slotNames (o : ImageObject) : Array (Option String) :=
  (Array.range o.image.header.symbols.count).map fun i => (o.slotName i).toOption

/-- Whether `r`, a pointer inside a pool or data-area allocation, has a target the writer can
give one (`finish_encoded`'s `map`): one of the image's symbols, or the pool or the data area
(up to one past their ends). The reason if not. -/
def allocTarget (o : ImageObject) (names : Array (Option String)) (r : Rela) : Option String :=
  let h := o.image.header
  match relSymbol o.elf r with
  | none => some s!"symbol {r.sym} out of range"
  | some s =>
    if s.type != Elf.STT_SECTION then
      if names.contains (some s.name) then none
      else some s!"against `{s.name}`, which isn't one of the image's symbols"
    else
      let to : Int := (s.value : Int) + r.addend
      let dataEnd := if h.jitRecords.count != 0 then h.jitRecords.off else h.dataSize
      let within (base lo hi : Nat) : Bool := (base + lo : Nat) ≤ to && to ≤ ((base + hi : Nat) : Int)
      if s.shndx == o.ro.index && within o.roBase h.consts.off (h.consts.off + h.consts.count) then none
      else if s.shndx == o.data.index && within o.dataBase h.fixupArea dataEnd then none
      else some s!"against `{o.elf.symbolName s}` + {r.addend}, neither the pool nor the data area"

def checkRoRelocs (o : ImageObject) : Array String := Id.run do
  let h := o.image.header
  let mut out : Array String := #[]
  let names := slotNames o
  let mut slotCount := Array.replicate h.symbols.count 0
  let roBytes := o.elf.data o.ro
  for r in o.roRelocs do
    let t := relaText o.elf r
    if r.offset < o.roBase then
      out := out.push s!"read-only: {t} before the image"; continue
    let off := r.offset - o.roBase
    let sym := relSymbol o.elf r
    let isSection := sym.any (·.type == Elf.STT_SECTION)
    if r.type != .abs64 then
      out := out.push s!"read-only: {t} isn't R_X86_64_64"; continue
    if !allBytes roBytes r.offset 8 0 then
      out := out.push s!"read-only: the field of {t} isn't zero"
    if off == 24 || off == 40 then
      let (want, what) := if off == 24 then (o.data, "data") else (o.text, "text")
      if !(isSection && sym.any (·.shndx == want.index) && r.addend == 0) then
        out := out.push s!"header `{what}`: {t}, not the start of `{want.name}`"
    else if h.symbols.off ≤ off && off < h.symbols.off + 8 * h.symbols.count then
      let k := (off - h.symbols.off) / 8
      if (off - h.symbols.off) % 8 != 0 then
        out := out.push s!"symbol slot {k}: {t} inside the slot"
      else
        slotCount := slotCount.modify k (· + 1)
        if isSection || r.addend != 0 then out := out.push s!"symbol slot {k}: {t}, not against a symbol + 0"
    else if h.consts.off ≤ off && off + 8 ≤ h.consts.off + h.consts.count then
      if off % 8 != 0 then out := out.push s!"pool: {t} at a pool offset that isn't 8-aligned"
      if let some e := allocTarget o names r then out := out.push s!"pool: {t}: {e}"
    else
      out := out.push s!"read-only: {t} at image offset {off}: not the header's data/text, a symbol slot or a pool pointer"
  -- The constant relocation table: the pool pointers' offsets, as the writer sorts them.
  let poolOffs := (o.roRelocs.filter fun r => r.type == .abs64 && r.offset ≥ o.roBase + h.consts.off
    && r.offset + 8 ≤ o.roBase + h.consts.off + h.consts.count).map (·.offset - o.roBase - h.consts.off)
  let table := o.image.constRelocs
  if table != poolOffs then
    let k := (List.range (max table.size poolOffs.size)).find? (fun k => table[k]? != poolOffs[k]?) |>.getD 0
    out := out.push s!"const_relocs: {table.size} entries, the pool has {poolOffs.size} relocated fields; first difference at entry {k}: {table[k]?} vs {poolOffs[k]?}"
  let flags := o.image.symbolFlags
  for k in [0:h.symbols.count] do
    if slotCount[k]! != 1 then
      out := out.push s!"symbol slot {k}: {slotCount[k]!} relocations"
    if flags[k]?.getD 0 != 0 then
      out := out.push s!"symbol slot {k}: flags {flags[k]?.getD 0} (SYM_INDIRECT is PE-only)"
  -- Each name once.
  let mut seen : Std.HashMap String Nat := {}
  for k in [0:names.size] do
    if let some n := names[k]! then
      if let some j := seen[n]? then out := out.push s!"symbol slots {j} and {k} both name `{n}`"
      else seen := seen.insert n k
  return out

def checkDataRelocs (o : ImageObject) : Array String := Id.run do
  let h := o.image.header
  let mut out : Array String := #[]
  let names := slotNames o
  let recs := h.jitRecords
  let recEnd := recs.off + 64 * recs.count
  let dataEnd := if recs.count != 0 then recs.off else h.dataSize
  -- (record, field) → relocations seen.
  let mut seen : Std.HashMap (Nat × Nat) Nat := {}
  let db := o.elf.data o.data
  for r in o.elf.relocsOf o.data.index do
    let t := relaText o.elf r
    if r.offset < o.dataBase then out := out.push s!"writable: {t} before the image's part"; continue
    let off := r.offset - o.dataBase
    let sym := relSymbol o.elf r
    if r.type != .abs64 then out := out.push s!"writable: {t} isn't R_X86_64_64"; continue
    if !allBytes db r.offset 8 0 then out := out.push s!"writable: the field of {t} isn't zero"
    if recs.count != 0 && recs.off ≤ off && off < recEnd then
      let k := (off - recs.off) / 64
      let fld := (off - recs.off) % 64
      seen := seen.insert (k, fld) (seen.getD (k, fld) 0 + 1)
      let named (base : String) : Bool :=
        sym.any fun s => s.type != Elf.STT_SECTION && !s.defined && isRtSymbol base s.name && r.addend == 0
      if fld == jitEntrySlot then
        if !named tripEntryName then out := out.push s!"JIT record {k}: entry: {t}, not {tripEntryName}"
      else if fld == jitOsrSlot then
        if !named tripOsrName then out := out.push s!"JIT record {k}: osr: {t}, not {tripOsrName}"
      else if fld == jitHeaderOff then
        let ok := sym.any fun s => s.type == Elf.STT_SECTION && s.shndx == o.ro.index &&
          (s.value : Int) + r.addend == o.roBase
        if !ok then out := out.push s!"JIT record {k}: header: {t}, not the image's header"
      else out := out.push s!"JIT record {k}: {t} at record offset {fld}"
    else if h.fixupArea ≤ off && off + 8 ≤ dataEnd then
      if off % 8 != 0 then out := out.push s!"data area: {t} at an offset that isn't 8-aligned"
      if let some e := allocTarget o names r then out := out.push s!"data area: {t}: {e}"
    else
      out := out.push s!"writable: {t} at offset {off}: not in a JIT record or the data area"
  -- The records' initial values.
  for k in [0:recs.count] do
    let base := o.dataBase + recs.off + 64 * k
    for fld in [jitEntrySlot, jitOsrSlot, jitHeaderOff] do
      let n := seen.getD (k, fld) 0
      if n != 1 then out := out.push s!"JIT record {k}: {n} relocations at record offset {fld}"
    for (name, off, want) in [("ctr_e", 0, -(jitEntryThreshold : Int)), ("ctr_l", jitLoopCtrOff, -(jitThreshold : Int))] do
      match readI64 db (base + off) with
      | .ok c => if c != want then out := out.push s!"JIT record {k}: {name} {c}, not {want}"
      | .error e => out := out.push s!"JIT record {k}: {e}"
    match readU32 db (base + jitFuncOff) with
    | .ok v => if v != k then out := out.push s!"JIT record {k}: func {v}"
    | .error e => out := out.push s!"JIT record {k}: {e}"
    if !allBytes db (base + 8) (jitFuncOff - 8) 0 || !allBytes db (base + jitHeaderOff) (jitLoopCtrOff - jitHeaderOff) 0 then
      out := out.push s!"JIT record {k}: nonzero bytes besides the counters and func"
  return out

/-! ## Header, sections, the anchor, `__ryo_main` -/

def checkHeader (o : ImageObject) : Array String := Id.run do
  let h := o.image.header
  let mut out : Array String := #[]
  let want := imageSymbol h.stableCrateId h.cguHash
  if o.symbol != want then out := out.push s!"header: image symbol `{o.symbol}`, stable_crate_id and cgu_hash say `{want}`"
  if h.crateHash != crateHash h.stableCrateId then
    out := out.push s!"header: crate_hash {hex h.crateHash}, stable_crate_id folds to {hex (crateHash h.stableCrateId)}"
  if o.roBase != 0 || o.dataBase != 0 || o.textBase != 0 then
    out := out.push s!"header: the image doesn't start its sections (read-only at {o.roBase}, writable at {o.dataBase}, text at {o.textBase})"
  if o.ro.size != o.roBase + h.size then
    out := out.push s!"header: `{o.ro.name}` has {o.ro.size} bytes, the image {o.roBase + h.size}"
  if o.data.size != o.dataBase + h.dataSize then
    out := out.push s!"header: `{o.data.name}` has {o.data.size} bytes, data_size says {o.dataBase + h.dataSize}"
  if !o.ro.name.startsWith ".data.rel.ro." || o.ro.flags &&& (Elf.SHF_WRITE ||| Elf.SHF_ALLOC ||| Elf.SHF_EXECINSTR) != Elf.SHF_WRITE ||| Elf.SHF_ALLOC then
    out := out.push s!"header: read-only section `{o.ro.name}` (flags {o.ro.flags}) isn't RELRO data"
  if o.data.flags &&& (Elf.SHF_WRITE ||| Elf.SHF_ALLOC ||| Elf.SHF_EXECINSTR) != Elf.SHF_WRITE ||| Elf.SHF_ALLOC
      || o.data.index == o.ro.index then
    out := out.push s!"header: writable section `{o.data.name}` (flags {o.data.flags}) isn't writable data"
  if o.text.flags &&& Elf.SHF_WRITE != 0 then out := out.push s!"header: the text `{o.text.name}` is writable"
  return out

/-- The section holding exactly one 8-byte `R_X86_64_64` + 0 field at its start, against a
symbol: that symbol, or why not. -/
def slotSection (e : Elf) (s : Section) : Except String Symbol := do
  let rs := e.relocsOf s.index
  unless s.size == 8 do throw s!"`{s.name}` has {s.size} bytes, not 8"
  unless s.name.startsWith ".data.rel.ro." do throw s!"`{s.name}` isn't RELRO"
  let [r] := rs.toList | throw s!"`{s.name}` has {rs.size} relocations"
  unless r.offset == 0 && r.type == .abs64 && r.addend == 0 do throw s!"`{s.name}`: {relaText e r}"
  unless allBytes (e.data s) 0 8 0 do throw s!"`{s.name}`'s field isn't zero"
  let some sym := relSymbol e r | throw s!"`{s.name}`: bad symbol"
  if sym.type == Elf.STT_SECTION then throw s!"`{s.name}`: against a section"
  pure sym

/-- The registration entry: the one `ryo_images` section, 8 bytes, retained writable data,
with one `R_X86_64_64` + 0 field against the start of the image's header. -/
def checkEntry (o : ImageObject) : Array String := Id.run do
  let e := o.elf
  let some s := match (e.sections.filter (·.name == entriesSection)).toList with
      | [s] => some s
      | _ => none
    | #[s!"entry: {(e.sections.filter (·.name == entriesSection)).size} `{entriesSection}` sections, not 1"]
  let mut out : Array String := #[]
  let want := Elf.SHF_ALLOC ||| Elf.SHF_WRITE ||| Elf.SHF_GNU_RETAIN
  if s.flags &&& (want ||| Elf.SHF_EXECINSTR) != want then
    out := out.push s!"entry: `{entriesSection}` flags {s.flags}, not SHF_ALLOC | SHF_WRITE | SHF_GNU_RETAIN"
  if s.size != 8 || !allBytes (e.data s) 0 8 0 then
    out := out.push s!"entry: `{entriesSection}` isn't 8 zero bytes ({s.size} bytes)"
  match (e.relocsOf s.index).toList with
  | [r] =>
    let ok := r.offset == 0 && r.type == .abs64 && (relSymbol e r).any fun t =>
      t.type == Elf.STT_SECTION && t.shndx == o.ro.index && (t.value : Int) + r.addend == o.roBase
    if !ok then out := out.push s!"entry: {relaText e r}, not R_X86_64_64 to the image's header"
  | l => out := out.push s!"entry: {l.length} relocations, not 1"
  return out

/-- What a `__ryo_main` slot names: the symbol, and the function of this image it is, if it
defines it. -/
structure MainSlot where
  name : String
  func : Option Nat

def checkAnchor (o : ImageObject) : Array String := Id.run do
  let e := o.elf
  let refs := e.relas.flatMap fun rs => (rs.relocs.filter fun r =>
    (relSymbol e r).any (·.name == anchorName)).map (rs.target, ·)
  match refs.toList with
  | [(sec, _)] =>
    let some s := e.section? sec | return #["anchor: bad section"]
    match slotSection e s with
    | .error m => #[s!"anchor: {m}"]
    | .ok sym =>
      if sym.defined then #[s!"anchor: `{anchorName}` is defined in the image object"]
      else if sec == o.ro.index || sec == o.data.index || sec == o.text.index then
        #[s!"anchor: the slot is in an image section"]
      else #[]
  | l => #[s!"anchor: {l.length} relocations against `{anchorName}`"]

/-- `__ryo_main`, if the object has one: mismatches, and what it names. -/
def checkMain (o : ImageObject) : Array String × Option MainSlot := Id.run do
  let e := o.elf
  match (e.symbols.filter (·.name == mainSlotName)).toList with
  | [] => (#[], none)
  | [m] =>
    let some s := (if m.defined then e.section? m.shndx else none)
      | (#[s!"{mainSlotName}: not defined"], none)
    let mut out : Array String := #[]
    if m.value != 0 || m.size != 8 then out := out.push s!"{mainSlotName}: at {m.value} of {m.size} bytes in `{s.name}`"
    match slotSection e s with
    | .error msg => (out.push s!"{mainSlotName}: {msg}", none)
    | .ok t =>
      if !t.defined then (out, some ⟨t.name, none⟩)
      else
        let f := if t.shndx == o.text.index && t.type == Elf.STT_FUNC && t.value ≥ o.textBase then
          o.funcs.findIdx? (·.codeOff == t.value - o.textBase) else none
        match f with
        | some i => (out, some ⟨t.name, some i⟩)
        | none => (out.push s!"{mainSlotName}: `{t.name}` is defined here but isn't one of the image's functions", some ⟨t.name, none⟩)
  | l => (#[s!"{mainSlotName}: {l.length} symbols"], none)

/-- Relocation sections against sections that aren't the image's, its unwind tables, the
anchor and `__ryo_main` slots, or the registration entry. -/
def checkOtherRelocs (o : ImageObject) : Array String := Id.run do
  let e := o.elf
  let mut out : Array String := #[]
  for rs in e.relas do
    let some s := e.section? rs.target | continue
    let known := rs.target == o.ro.index || rs.target == o.data.index || rs.target == o.text.index
      || s.name == ".eh_frame" || s.name.startsWith ".gcc_except_table"
      || s.name == ".data.rel.ro.ryo_anchor" || s.name == ".data.rel.ro.ryo_main" || s.name == entriesSection
    if !known then out := out.push s!"relocations of `{s.name}`, which isn't an image section"
  return out

end Ryo.Check.Image
