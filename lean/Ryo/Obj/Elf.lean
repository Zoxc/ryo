/-!
# ELF64 relocatable objects (aot.md §C3)

A reader for what the image objects are: ELF64, little-endian, `ET_REL`, x86-64. It reads the
section headers (with their names), the symbol table and the `RELA` sections, bounds-checking
every read, and returns `Except String`. Relocation types other than `R_X86_64_64`,
`R_X86_64_PC32` and `R_X86_64_PLT32` (what `backend/src/objfile.rs` emits) are rejected, as are
`REL` sections.

Executable, not verified: its fidelity to the ELF spec is tested against `readelf -W -S -s -r`
(`scripts/lean-decode-diff.py --readelf`).
-/

namespace Ryo.Obj

/-! ## Little-endian reads -/

/-- The `n` bytes at `off` as a little-endian unsigned number, if in bounds. -/
def readLE (b : ByteArray) (off n : Nat) : Except String Nat :=
  if off + n ≤ b.size then
    .ok ((List.range n).foldr (fun i acc => acc * 256 + (b[off + i]!).toNat) 0)
  else
    .error s!"read of {n} bytes at {off} past the end ({b.size} bytes)"

def readU8 (b : ByteArray) (off : Nat) : Except String Nat := readLE b off 1
def readU16 (b : ByteArray) (off : Nat) : Except String Nat := readLE b off 2
def readU32 (b : ByteArray) (off : Nat) : Except String Nat := readLE b off 4
def readU64 (b : ByteArray) (off : Nat) : Except String Nat := readLE b off 8

/-- Two's complement of an `n`-bit value. -/
def toSigned (bits v : Nat) : Int :=
  if v < 2 ^ (bits - 1) then (v : Int) else (v : Int) - (2 ^ bits : Nat)

def readI32 (b : ByteArray) (off : Nat) : Except String Int := toSigned 32 <$> readU32 b off
def readI64 (b : ByteArray) (off : Nat) : Except String Int := toSigned 64 <$> readU64 b off

/-- The bytes `[off, off + n)`, if in bounds. -/
def slice (b : ByteArray) (off n : Nat) : Except String ByteArray :=
  if off + n ≤ b.size then .ok (b.extract off (off + n))
  else .error s!"range [{off}, {off + n}) past the end ({b.size} bytes)"

/-- The NUL-terminated string at `off` of a string table (UTF-8; the terminator must be in
the table). -/
def readCStr (b : ByteArray) (off : Nat) : Except String String := do
  if off ≥ b.size then throw s!"string at {off} past the end of its table ({b.size} bytes)"
  let rec go (i : Nat) (fuel : Nat) : Except String Nat :=
    match fuel with
    | 0 => .error s!"string at {off} isn't terminated"
    | fuel + 1 => if b[i]! == 0 then .ok i else go (i + 1) fuel
  let e ← go off (b.size - off)
  match String.fromUTF8? (b.extract off e) with
  | some s => pure s
  | none => throw s!"string at {off} isn't UTF-8"

/-! ## Constants -/

namespace Elf

def ET_REL := 1
def EM_X86_64 := 62

def SHT_NULL := 0
def SHT_PROGBITS := 1
def SHT_SYMTAB := 2
def SHT_STRTAB := 3
def SHT_RELA := 4
def SHT_NOBITS := 8
def SHT_REL := 9
def SHT_SYMTAB_SHNDX := 18

def SHF_WRITE := 0x1
def SHF_ALLOC := 0x2
def SHF_EXECINSTR := 0x4
def SHF_GNU_RETAIN := 0x200000

def SHN_UNDEF := 0
def SHN_LORESERVE := 0xff00
def SHN_ABS := 0xfff1
def SHN_COMMON := 0xfff2
def SHN_XINDEX := 0xffff

def STB_LOCAL := 0
def STB_GLOBAL := 1
def STB_WEAK := 2

def STT_NOTYPE := 0
def STT_OBJECT := 1
def STT_FUNC := 2
def STT_SECTION := 3
def STT_FILE := 4

def STV_HIDDEN := 2

def R_X86_64_64 := 1
def R_X86_64_PC32 := 2
def R_X86_64_PLT32 := 4

end Elf

/-! ## The object -/

/-- A section header, with its name from the section-name string table. -/
structure Section where
  index : Nat
  name : String
  /-- `sh_name`: the name's offset in the section-name string table. -/
  nameOff : Nat
  type : Nat
  flags : Nat
  addr : Nat
  offset : Nat
  size : Nat
  link : Nat
  info : Nat
  addralign : Nat
  entsize : Nat
  deriving Repr, Inhabited

/-- A symbol table entry. `shndx` is the section index (extended indices resolved through
`SHT_SYMTAB_SHNDX`), or one of the reserved `SHN_*`. -/
structure Symbol where
  index : Nat
  name : String
  value : Nat
  size : Nat
  bind : Nat
  type : Nat
  /-- `st_other & 3`. -/
  visibility : Nat
  shndx : Nat
  deriving Repr, Inhabited

def Symbol.defined (s : Symbol) : Bool := s.shndx != Elf.SHN_UNDEF && s.shndx < Elf.SHN_LORESERVE

/-- The relocation types image objects use (`objfile.rs`, `RelocKind` on ELF). -/
inductive RelocType where
  /-- `R_X86_64_64`: 64 bits, `S + A`. -/
  | abs64
  /-- `R_X86_64_PC32`: 32 bits, `S + A - P`. -/
  | pc32
  /-- `R_X86_64_PLT32`: 32 bits, `L + A - P` (a call). -/
  | plt32
  deriving Repr, DecidableEq, Inhabited

def RelocType.ofNat? : Nat → Option RelocType
  | 1 => some .abs64
  | 2 => some .pc32
  | 4 => some .plt32
  | _ => none

def RelocType.toNat : RelocType → Nat
  | .abs64 => 1
  | .pc32 => 2
  | .plt32 => 4

def RelocType.name : RelocType → String
  | .abs64 => "R_X86_64_64"
  | .pc32 => "R_X86_64_PC32"
  | .plt32 => "R_X86_64_PLT32"

/-- One `Elf64_Rela`: at `offset` in the target section, against symbol `sym`. -/
structure Rela where
  offset : Nat
  sym : Nat
  type : RelocType
  addend : Int
  deriving Repr, Inhabited

/-- A `SHT_RELA` section: the relocations of section `target` (`sh_info`) against the symbol
table `symtab` (`sh_link`). -/
structure RelaSection where
  index : Nat
  target : Nat
  symtab : Nat
  relocs : Array Rela
  deriving Repr, Inhabited

structure Elf where
  bytes : ByteArray
  sections : Array Section
  /-- The `SHT_SYMTAB`'s entries (index 0 the null symbol); empty without one. -/
  symbols : Array Symbol
  /-- The index of the `SHT_SYMTAB` section (0 without one). -/
  symtabIndex : Nat
  relas : Array RelaSection

instance : Inhabited Elf := ⟨⟨ByteArray.empty, #[], #[], 0, #[]⟩⟩

namespace Elf

/-- A section's contents (empty for `SHT_NOBITS`; bounds checked when the object is read). -/
def data (e : Elf) (s : Section) : ByteArray :=
  if s.type == SHT_NOBITS then ByteArray.empty else e.bytes.extract s.offset (s.offset + s.size)

def section? (e : Elf) (i : Nat) : Option Section := e.sections[i]?

def sectionByName? (e : Elf) (name : String) : Option Section :=
  e.sections.find? (·.name == name)

def symbol? (e : Elf) (i : Nat) : Option Symbol := e.symbols[i]?

/-- The relocations of section `i` (all `RELA` sections targeting it, in section order). -/
def relocsOf (e : Elf) (i : Nat) : Array Rela :=
  e.relas.foldl (fun acc r => if r.target == i then acc ++ r.relocs else acc) #[]

/-- The name a relocation's symbol stands for: the symbol's, or for a section symbol (which
has none) its section's. -/
def symbolName (e : Elf) (s : Symbol) : String :=
  if s.type == STT_SECTION then
    match e.section? s.shndx with
    | some sec => sec.name
    | none => s.name
  else s.name

end Elf

private def readSectionHeader (b : ByteArray) (shoff i : Nat) : Except String Section := do
  let o := shoff + i * 64
  pure {
    index := i, name := "", nameOff := ← readU32 b o, type := ← readU32 b (o + 4), flags := ← readU64 b (o + 8),
    addr := ← readU64 b (o + 16), offset := ← readU64 b (o + 24), size := ← readU64 b (o + 32),
    link := ← readU32 b (o + 40), info := ← readU32 b (o + 44),
    addralign := ← readU64 b (o + 48), entsize := ← readU64 b (o + 56) }

/-- Reads an ELF64 little-endian x86-64 relocatable object. -/
def readElf (b : ByteArray) : Except String Elf := do
  if b.size < 64 then throw "not ELF: shorter than the ELF header"
  unless b[0]! == 0x7f && b[1]! == 0x45 && b[2]! == 0x4c && b[3]! == 0x46 do
    throw "not ELF: bad magic"
  unless b[4]! == 2 do throw "not ELF64"
  unless b[5]! == 1 do throw "not little-endian"
  unless b[6]! == 1 do throw "bad ELF version"
  let etype ← readU16 b 16
  unless etype == Elf.ET_REL do throw s!"not a relocatable object (e_type {etype})"
  let machine ← readU16 b 18
  unless machine == Elf.EM_X86_64 do throw s!"not x86-64 (e_machine {machine})"
  let shoff ← readU64 b 40
  let shentsize ← readU16 b 58
  let shnum0 ← readU16 b 60
  let shstrndx0 ← readU16 b 62
  if shoff == 0 then
    return { bytes := b, sections := #[], symbols := #[], symtabIndex := 0, relas := #[] }
  unless shentsize == 64 do throw s!"bad e_shentsize {shentsize}"
  -- Extended numbering: the counts live in section 0.
  let s0 ← readSectionHeader b shoff 0
  let shnum := if shnum0 == 0 then s0.size else shnum0
  let shstrndx := if shstrndx0 == Elf.SHN_XINDEX then s0.link else shstrndx0
  if shoff + shnum * 64 > b.size then throw "section headers past the end"
  let raw ← (Array.range shnum).mapM (readSectionHeader b shoff)
  for s in raw do
    if s.type != Elf.SHT_NOBITS && s.offset + s.size > b.size then
      throw s!"section {s.index}'s contents past the end"
    if s.type == Elf.SHT_REL then throw s!"section {s.index} is SHT_REL (only RELA is accepted)"
  let strSection (i : Nat) (what : String) : Except String ByteArray := do
    let some s := raw[i]? | throw s!"{what}: no section {i}"
    unless s.type == Elf.SHT_STRTAB do throw s!"{what}: section {i} isn't a string table"
    slice b s.offset s.size
  let shstr ← if shstrndx == 0 then pure ByteArray.empty else strSection shstrndx "section names"
  let sections ← raw.mapM fun s => do
    if shstrndx == 0 then pure s
    else pure { s with name := ← readCStr shstr s.nameOff }
  let symtabs := sections.filter (·.type == Elf.SHT_SYMTAB)
  if symtabs.size > 1 then throw "more than one symbol table"
  let (symbols, symtabIndex) ← match symtabs[0]? with
    | none => pure (#[], 0)
    | some st => do
      unless st.entsize == 24 do throw s!"symbol table entry size {st.entsize}"
      if st.size % 24 != 0 then throw "symbol table size isn't a multiple of 24"
      let strs ← strSection st.link "symbol names"
      let xindex ← match sections.find? (fun s => s.type == Elf.SHT_SYMTAB_SHNDX && s.link == st.index) with
        | some x => some <$> slice b x.offset x.size
        | none => pure none
      let syms ← (Array.range (st.size / 24)).mapM fun i => do
        let o := st.offset + i * 24
        let info ← readU8 b (o + 4)
        let other ← readU8 b (o + 5)
        let shndx0 ← readU16 b (o + 6)
        let shndx ← if shndx0 == Elf.SHN_XINDEX then
            match xindex with
            | some x => readU32 x (i * 4)
            | none => throw s!"symbol {i} has SHN_XINDEX without SHT_SYMTAB_SHNDX"
          else pure shndx0
        if shndx != Elf.SHN_UNDEF && shndx < Elf.SHN_LORESERVE && shndx ≥ shnum then
          throw s!"symbol {i}'s section {shndx} out of range"
        pure ({ index := i, name := ← readCStr strs (← readU32 b o), value := ← readU64 b (o + 8),
                size := ← readU64 b (o + 16), bind := info / 16, type := info % 16,
                visibility := other % 4, shndx } : Symbol)
      pure (syms, st.index)
  let relas ← (sections.filter (·.type == Elf.SHT_RELA)).mapM fun rs => do
    unless rs.entsize == 24 do throw s!"RELA section {rs.index}: entry size {rs.entsize}"
    if rs.size % 24 != 0 then throw s!"RELA section {rs.index}: size isn't a multiple of 24"
    unless rs.link == symtabIndex && symtabIndex != 0 do
      throw s!"RELA section {rs.index}: sh_link {rs.link} isn't the symbol table"
    let some tgt := sections[rs.info]? | throw s!"RELA section {rs.index}: target {rs.info} out of range"
    let relocs ← (Array.range (rs.size / 24)).mapM fun i => do
      let o := rs.offset + i * 24
      let off ← readU64 b o
      let info ← readU64 b (o + 8)
      let sym := info / 2 ^ 32
      let ty := info % 2 ^ 32
      let some type := RelocType.ofNat? ty
        | throw s!"RELA section {rs.index}, entry {i}: relocation type {ty} isn't R_X86_64_64, PC32 or PLT32"
      if sym ≥ symbols.size then throw s!"RELA section {rs.index}, entry {i}: symbol {sym} out of range"
      let width := if type == .abs64 then 8 else 4
      if off + width > tgt.size then
        throw s!"RELA section {rs.index}, entry {i}: offset {off} past the end of section {tgt.index}"
      pure ({ offset := off, sym, type, addend := ← readI64 b (o + 16) } : Rela)
    pure ({ index := rs.index, target := rs.info, symtab := rs.link, relocs } : RelaSection)
  return { bytes := b, sections, symbols, symtabIndex, relas }

/-- What `ryo-lean elf` prints: the sections, symbols and relocations, one per line, with
numbers in decimal (`scripts/lean-decode-diff.py --readelf` turns `readelf -W -S -s -r`'s
output into the same form):

```
section <i> <name> type <t> flags <f> off <o> size <n> link <l> info <i> align <a> entsize <e>
symbol <i> value <v> size <n> type <t> bind <b> vis <v> shndx <s> <name>
rela <section name> <offset> <type> <symbol name> <addend>
```

(`rela` lines in file order; a section symbol's name is its section's). -/
def Elf.dump (e : Elf) : Array String := Id.run do
  let mut out := #[]
  for s in e.sections do
    out := out.push s!"section {s.index} {s.name} type {s.type} flags {s.flags} off {s.offset} size {s.size} link {s.link} info {s.info} align {s.addralign} entsize {s.entsize}"
  for s in e.symbols do
    out := out.push s!"symbol {s.index} value {s.value} size {s.size} type {s.type} bind {s.bind} vis {s.visibility} shndx {s.shndx} {s.name}"
  for rs in e.relas do
    let name := (e.section? rs.index).map (·.name) |>.getD "?"
    for r in rs.relocs do
      let sym := (e.symbol? r.sym).map e.symbolName |>.getD "?"
      out := out.push s!"rela {name} {r.offset} {r.type.name} {sym} {r.addend}"
  return out

end Ryo.Obj
