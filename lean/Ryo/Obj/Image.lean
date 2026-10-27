/-
# The image in an image object (aot.md §C3)

Locates a crate's image in its image object (`backend/src/objfile.rs`, `write_image`): the
read-only section holding `__ryo_image_<StableCrateId>_<CGU hash>` at the header, and the writable and
text sections its header's `data` and `text` fields are relocated against. Ports
`Image::parse` and `Image::validate`'s bounds and alignment checks
(`vm/bytecode/src/image/mod.rs`) over the object's bytes, and gathers each function's inputs
to `asm::decode_reduced` (`Ryo.Obj.FuncInputs`).

Layouts are `repr(C)` (`Header` 160 bytes, `FuncEntry` 36, `CallSiteEntry` 12,
`FixupEntry` 16). Each function's scopes, dropped stores and branch targets are in its
instruction list (`Ryo.Obj.List`), a run of the instruction-list bytes.
-/
import Std.Data.HashMap
import Ryo.Obj.Elf
import Ryo.Obj.Reloc
import Ryo.Obj.List

namespace Ryo.Obj

open Ryo.Vm

/-- `image::MAGIC`. -/
def imageMagic : List UInt8 := "RYOIMAGE".toUTF8.toList

/-- The prefix of the symbol an image defines, `__ryo_image_<StableCrateId>_<CGU hash>` (both
16 lowercase hex digits; `objfile::image_symbol`). -/
def imageSymbolPrefix : String := "__ryo_image_"

/-- `image::CONTINUE` and `image::CATCH`. -/
def CONTINUE : Nat := 0xffffffff
def CATCH : Nat := 0x80000000

/-- `image::SYM_INDIRECT`. -/
def SYM_INDIRECT : Nat := 1

/-- `image::FUNC_INLINE_ALWAYS` etc.: a function's inline and cold attributes. Nothing in
the VM semantics reads them (the JIT's inliner does). -/
def FUNC_INLINE_ALWAYS : Nat := 1
def FUNC_INLINE_NEVER : Nat := 2
def FUNC_COLD : Nat := 4
def FUNC_INLINE_HINT : Nat := 8
def FUNC_FLAGS : Nat := FUNC_INLINE_ALWAYS ||| FUNC_INLINE_NEVER ||| FUNC_COLD ||| FUNC_INLINE_HINT

def headerSize : Nat := 160

/-- `image::Span`: offset and element count. -/
structure Span where
  off : Nat
  count : Nat
  deriving Repr, DecidableEq, Inhabited

instance : ToString Span := ⟨fun s => s!"{s.off}+{s.count}"⟩

/-- `image::Header`. -/
structure Header where
  crateHash : Nat
  size : Nat
  stableCrateId : Nat
  data : Nat
  dataSize : Nat
  textSize : Nat
  text : Nat
  functions : Span
  codeConsts : Span
  fixups : Span
  symFlags : Span
  /-- One flag byte per function (`FUNC_INLINE_ALWAYS` etc.). -/
  funcFlags : Span
  symbols : Span
  consts : Span
  /-- The functions' instruction lists (bytes). -/
  lists : Span
  callSites : Span
  siteCount : Nat
  fixupArea : Nat
  mode : Nat
  jitRecords : Span
  /-- `[u32]`, strictly increasing: the pool offset of every relocated 8-byte field of the
  constant pool. Nothing in the VM semantics reads it (the JIT's constant-load fold does). -/
  constRelocs : Span
  /-- `image::cgu_hash` of the codegen unit's name: with `crateHash`, the image's identity in
  the registry. -/
  cguHash : Nat
  deriving Repr, Inhabited

/-- `image::FuncEntry`. -/
structure FuncEntry where
  codeOff : Nat
  codeLen : Nat
  argSize : Nat
  retSize : Nat
  retKind : Nat
  /-- The function's instruction list: a run of the instruction-list bytes. -/
  list : Span
  callSites : Span
  deriving Repr, Inhabited

/-- `image::CallSiteEntry`. -/
structure CallSiteEntry where
  start : Nat
  len : Nat
  pad : Nat
  deriving Repr, Inhabited

/-- `image::FixupEntry`. -/
structure FixupEntry where
  offset : Nat
  sym : Nat
  addend : Int
  deriving Repr, Inhabited

/-- `image::ImageError`, rendered as Rust's `Debug` prints it. -/
inductive ImageError where
  | truncated
  | misaligned
  | badMagic
  | outOfBounds (what : String)
  | badFunction (i : Nat)
  | badFixup (i : Nat)
  | badSymbolFlags (i : Nat)
  | badFuncFlags (i : Nat)
  | badMode
  /-- A function's instruction list (function index) is malformed. -/
  | badList (i : Nat)
  | badCallSite (i : Nat)
  | badData
  /-- A constant relocation (index) is out of the pool, misaligned or out of order. -/
  | badConstReloc (i : Nat)
  deriving Repr, DecidableEq, Inhabited

instance : ToString ImageError where
  toString
    | .truncated => "Truncated"
    | .misaligned => "Misaligned"
    | .badMagic => "BadMagic"
    | .outOfBounds w => s!"OutOfBounds(\"{w}\")"
    | .badFunction i => s!"BadFunction({i})"
    | .badFixup i => s!"BadFixup({i})"
    | .badSymbolFlags i => s!"BadSymbolFlags({i})"
    | .badFuncFlags i => s!"BadFuncFlags({i})"
    | .badMode => "BadMode"
    | .badList i => s!"BadList({i})"
    | .badCallSite i => s!"BadCallSite({i})"
    | .badData => "BadData"
    | .badConstReloc i => s!"BadConstReloc({i})"

/-- A parsed read-only section: its bytes (`Header::size` of them) and header. -/
structure Image where
  bytes : ByteArray
  header : Header
  deriving Inhabited

/-! ## `Image::parse` -/

private def u32! (b : ByteArray) (o : Nat) : Nat := (readU32 b o).toOption.getD 0
private def u64! (b : ByteArray) (o : Nat) : Nat := (readU64 b o).toOption.getD 0
private def span! (b : ByteArray) (o : Nat) : Span := ⟨u32! b o, u32! b (o + 4)⟩

/-- Reads the header at the start of `b` (which must hold `headerSize` bytes). -/
def readHeader (b : ByteArray) : Header :=
  { crateHash := u32! b 8, size := u32! b 12, stableCrateId := u64! b 16, data := u64! b 24,
    dataSize := u32! b 32, textSize := u32! b 36, text := u64! b 40, functions := span! b 48,
    codeConsts := span! b 56, fixups := span! b 64, symFlags := span! b 72,
    funcFlags := span! b 80, symbols := span! b 88, consts := span! b 96, lists := span! b 104,
    callSites := span! b 112, siteCount := u32! b 120, fixupArea := u32! b 124,
    mode := u32! b 128, jitRecords := span! b 132, constRelocs := span! b 140,
    cguHash := u64! b 152 }

/-- `cast`'s checks: `span.count` elements of `size` bytes at `span.off` lie in `len` bytes,
and `span.off` is a multiple of `align` (the section start is 8-aligned). -/
def checkPart (len : Nat) (span : Span) (size align : Nat) (what : String) :
    Except ImageError Unit := do
  if span.off + span.count * size > len then throw (.outOfBounds what)
  if span.off % align != 0 then throw .misaligned

/-- `Image::parse`: `bytes` is the read-only section from the header on, `aligned` whether
it starts 8-aligned. Checks the header and that every part is in bounds and aligned. -/
def Image.parse (bytes : ByteArray) (aligned : Bool := true) : Except ImageError Image := do
  if bytes.size < headerSize then throw .truncated
  if !aligned then throw .misaligned
  if (bytes.extract 0 8).toList != imageMagic then throw .badMagic
  let h := readHeader bytes
  if h.size > bytes.size then throw .truncated
  let bytes := bytes.extract 0 h.size
  let n := bytes.size
  checkPart n h.functions 36 4 "functions"
  checkPart n h.codeConsts 1 1 "code constants"
  checkPart n h.fixups 16 8 "fixups"
  checkPart n h.symFlags 1 1 "symbol flags"
  checkPart n h.funcFlags 1 1 "function flags"
  checkPart n h.symbols 8 8 "symbols"
  checkPart n h.consts 1 1 "constants"
  checkPart n h.lists 1 1 "instruction lists"
  checkPart n h.callSites 12 4 "call sites"
  checkPart n h.constRelocs 4 4 "constant relocations"
  let all := MODE_FP_ARG ||| MODE_FRAME_POINTER ||| MODE_ALIGN_LOOPS ||| MODE_PE ||| MODE_COUNTERS
  if h.mode &&& (2 ^ 32 - 1 - all) != 0 || !(Mode.ofBits h.mode).valid then throw .badMode
  if h.symFlags.count != h.symbols.count then throw (.outOfBounds "symbol flags")
  if h.funcFlags.count != h.functions.count then throw (.outOfBounds "function flags")
  if h.siteCount * 8 > h.fixupArea || h.fixupArea > h.dataSize then throw .badData
  let r := h.jitRecords
  let records := if (Mode.ofBits h.mode).counters then h.functions.count else 0
  if r.count != records || r.off % 64 != 0 || r.off + 64 * r.count > h.dataSize then
    throw .badData
  return { bytes, header := h }

namespace Image

def mode (img : Image) : Mode := Mode.ofBits img.header.mode

def function? (img : Image) (i : Nat) : Option FuncEntry :=
  if i < img.header.functions.count then
    let b := img.bytes
    let o := img.header.functions.off + i * 36
    some { codeOff := u32! b o, codeLen := u32! b (o + 4), argSize := u32! b (o + 8),
           retSize := u32! b (o + 12), retKind := u32! b (o + 16), list := span! b (o + 20),
           callSites := span! b (o + 28) }
  else none

def functions (img : Image) : Array FuncEntry :=
  (Array.range img.header.functions.count).filterMap img.function?

/-- The run `run` (an index range) of the table `table` of `size`-byte entries, read by
`get`; empty if out of range (`Image::run`). -/
private def run {α} (table run : Span) (size : Nat) (get : Nat → α) : Array α :=
  if run.off + run.count ≤ table.count then
    (Array.range run.count).map fun j => get (table.off + (run.off + j) * size)
  else #[]

def callSiteAt (img : Image) (o : Nat) : CallSiteEntry :=
  let b := img.bytes
  { start := u32! b o, len := u32! b (o + 4), pad := u32! b (o + 8) }

/-- Function `f`'s instruction list bytes (`Image::list`; empty if out of range). -/
def list (img : Image) (f : FuncEntry) : ByteArray :=
  let t := img.header.lists
  if f.list.off + f.list.count ≤ t.count then
    img.bytes.extract (t.off + f.list.off) (t.off + f.list.off + f.list.count)
  else .empty

def callSites (img : Image) (f : FuncEntry) : Array CallSiteEntry :=
  run img.header.callSites f.callSites 12 img.callSiteAt

def fixups (img : Image) : Array FixupEntry :=
  let b := img.bytes
  (Array.range img.header.fixups.count).map fun i =>
    let o := img.header.fixups.off + i * 16
    { offset := u32! b o, sym := u32! b (o + 4), addend := toSigned 64 (u64! b (o + 8)) }

def symbolFlags (img : Image) : Array Nat :=
  (Array.range img.header.symFlags.count).map fun i =>
    (readU8 img.bytes (img.header.symFlags.off + i)).toOption.getD 0

def funcFlags (img : Image) : Array Nat :=
  (Array.range img.header.funcFlags.count).map fun i =>
    (readU8 img.bytes (img.header.funcFlags.off + i)).toOption.getD 0

/-- The pool offsets of the constant pool's relocated fields (`Image::const_relocs`). -/
def constRelocs (img : Image) : Array Nat :=
  (Array.range img.header.constRelocs.count).map fun i => u32! img.bytes (img.header.constRelocs.off + 4 * i)

def codeConsts (img : Image) : ByteArray :=
  img.bytes.extract img.header.codeConsts.off (img.header.codeConsts.off + img.header.codeConsts.count)

/-! ## `Image::validate` -/

/-- `Image::validate`: the function table (sorted, in the text), each function's
instruction list (well formed, `walkList`) and call-site run, the fixups, the symbol and
function flags, and the constant relocations (each 8-aligned in the section, inside the pool,
after the one before). -/
def validate (img : Image) : Except ImageError Unit := do
  let h := img.header
  let mut prevEnd := 0
  for i in [0:h.functions.count] do
    let some f := img.function? i | throw (.badFunction i)
    let e := f.codeOff + f.codeLen
    if f.codeOff < prevEnd || e > h.textSize then throw (.badFunction i)
    prevEnd := e
    let runOk (s : Span) (n : Nat) := s.off + s.count ≤ n
    if !runOk f.list h.lists.count || !runOk f.callSites h.callSites.count then
      throw (.badFunction i)
    if (walkList (img.list f) f.codeLen).isNone then throw (.badList i)
    let mut prev := 0
    let mut j := 0
    for c in img.callSites f do
      let padOk := c.pad == CONTINUE || c.pad % CATCH < f.codeLen
      let cEnd := c.start + c.len
      let sorted := c.start ≥ prev
      prev := cEnd
      if !sorted || cEnd > f.codeLen || !padOk then throw (.badCallSite (f.callSites.off + j))
      j := j + 1
  let mut i := 0
  for x in img.fixups do
    if x.sym ≥ h.symbols.count || x.offset % 8 != 0 || x.offset < h.fixupArea
        || x.offset + 8 > h.dataSize then
      throw (.badFixup i)
    i := i + 1
  i := 0
  for fl in img.symbolFlags do
    if fl &&& (255 - SYM_INDIRECT) != 0 then throw (.badSymbolFlags i)
    i := i + 1
  i := 0
  for fl in img.funcFlags do
    if fl &&& (255 - FUNC_FLAGS) != 0 then throw (.badFuncFlags i)
    i := i + 1
  i := 0
  let mut next := 0
  for o in img.constRelocs do
    if o < next || (h.consts.off + o) % 8 != 0 || o + 8 > h.consts.count then throw (.badConstReloc i)
    next := o + 8
    i := i + 1

end Image

/-! ## The image object -/

/-- A relocation's target: a section and an offset in it (`S + A` for a defined symbol or a
section symbol), or an undefined symbol by name, with the addend. -/
inductive Target where
  | sect (index : Nat) (off : Int)
  | named (name : String) (addend : Int)
  deriving Repr, DecidableEq, Inhabited

/-- An image object: the ELF object, the image, and the sections it lives in. -/
structure ImageObject where
  elf : Elf
  /-- `__ryo_image_<id>_<cgu>`. -/
  symbol : String
  image : Image
  /-- The read-only, writable and text sections, and where the image starts in each (the
  header's symbol, and the targets of the header's `data` and `text` relocations). -/
  ro : Section
  roBase : Nat
  data : Section
  dataBase : Nat
  text : Section
  textBase : Nat
  /-- The text section's bytes from `textBase`, `Header::text_size` of them. -/
  textBytes : ByteArray
  /-- The read-only section's relocations, by offset. -/
  roRelocs : Array Rela
  /-- The text section's relocations, sorted by offset. -/
  textRelocs : Array Rela
  /-- The function table. -/
  funcs : Array FuncEntry
  /-- By text offset (from `textBase`), the first `STT_FUNC` symbol (in symbol-table order)
  defined there. -/
  funcSyms : Std.HashMap Nat String

private def sortRelas (rs : Array Rela) : Array Rela := rs.qsort (fun a b => a.offset < b.offset)

/-- The target of a relocation. -/
def Elf.target (e : Elf) (r : Rela) : Except String Target := do
  let some s := e.symbol? r.sym | throw s!"relocation symbol {r.sym} out of range"
  if s.defined then pure (.sect s.shndx ((s.value : Int) + r.addend))
  else if s.shndx == Elf.SHN_UNDEF then pure (.named s.name r.addend)
  else throw s!"relocation against symbol `{s.name}` in special section {s.shndx}"

/-- The relocation at `off` in a list sorted by offset. -/
def findRela (rs : Array Rela) (off : Nat) : Option Rela :=
  let rec go (lo hi : Nat) (fuel : Nat) : Option Rela :=
    match fuel with
    | 0 => none
    | fuel + 1 =>
      if lo < hi then
        let mid := (lo + hi) / 2
        let r := rs[mid]!
        if r.offset == off then some r
        else if r.offset < off then go (mid + 1) hi fuel
        else go lo mid fuel
      else none
  go 0 rs.size (rs.size + 1)

/-- The section and offset an `R_X86_64_64` field of the header points at. -/
private def headerPointer (e : Elf) (roRelocs : Array Rela) (fieldOff : Nat) (what : String) :
    Except String (Section × Nat) := do
  let some r := findRela roRelocs fieldOff | throw s!"the header's `{what}` field has no relocation"
  unless r.type == .abs64 do throw s!"the header's `{what}` relocation isn't R_X86_64_64"
  match ← e.target r with
  | .sect i off =>
    let some s := e.section? i | throw s!"`{what}`: no section {i}"
    if off < 0 then throw s!"`{what}` points before its section"
    pure (s, off.toNat)
  | .named n _ => throw s!"the header's `{what}` points at undefined `{n}`"

/-- Locates and parses the image of an image object (`Image::parse`; `Image::validate` is
separate). -/
def readImageObject (bytes : ByteArray) : Except String ImageObject := do
  let elf ← readElf bytes
  let cands := elf.symbols.filter fun s => s.name.startsWith imageSymbolPrefix && s.defined
  let sym ← match cands.toList with
    | [s] => pure s
    | [] => throw "no image symbol (__ryo_image_*)"
    | _ => throw "more than one image symbol"
  let some ro := elf.section? sym.shndx | throw "image symbol's section out of range"
  if sym.value > ro.size then throw "image symbol past its section's end"
  let roData := elf.data ro
  let aligned := ro.addralign % 8 == 0 && ro.addralign != 0 && sym.value % 8 == 0
  let image ← match Image.parse (roData.extract sym.value roData.size) aligned with
    | .ok i => pure i
    | .error e => throw s!"image: {e}"
  let roRelocs := sortRelas (elf.relocsOf ro.index)
  -- Header fields `data` (offset 24) and `text` (40).
  let (data, dataBase) ← headerPointer elf roRelocs (sym.value + 24) "data"
  let (text, textBase) ← headerPointer elf roRelocs (sym.value + 40) "text"
  if dataBase + image.header.dataSize > data.size then throw "the writable section is shorter than `data_size`"
  if textBase + image.header.textSize > text.size then throw "the text section is shorter than `text_size`"
  unless text.flags &&& Elf.SHF_EXECINSTR != 0 do throw s!"`text` points at non-executable `{text.name}`"
  let textBytes := (elf.data text).extract textBase (textBase + image.header.textSize)
  let funcSyms := elf.symbols.foldl (init := ({} : Std.HashMap Nat String)) fun m s =>
    if s.type == Elf.STT_FUNC && s.shndx == text.index && s.value ≥ textBase
        && !m.contains (s.value - textBase) then
      m.insert (s.value - textBase) s.name
    else m
  return { elf, symbol := sym.name, image, ro, roBase := sym.value, data, dataBase, text, textBase,
           textBytes, roRelocs, textRelocs := sortRelas (elf.relocsOf text.index),
           funcs := image.functions, funcSyms }

namespace ImageObject

/-- The name of symbol slot `i`: the symbol its `R_X86_64_64` relocation is against. -/
def slotName (o : ImageObject) (i : Nat) : Except String String := do
  let slotOff := o.roBase + o.image.header.symbols.off + 8 * i
  let some r := findRela o.roRelocs slotOff | throw s!"symbol slot {i} has no relocation"
  unless r.type == .abs64 && r.addend == 0 do throw s!"symbol slot {i}'s relocation isn't R_X86_64_64 + 0"
  let some s := o.elf.symbol? r.sym | throw s!"symbol slot {i}: bad symbol"
  pure (o.elf.symbolName s)

/-- The name of the function whose code starts at text offset `off`: the first `STT_FUNC`
symbol (in symbol-table order) defined there. -/
def funcName (o : ImageObject) (off : Nat) : String := o.funcSyms.getD off "?"

/-- A handler's index by its symbol: `ryo_h_<Name>` as `rustc` mangles internal symbols (a
v0 identifier `<len>ryo_h_<Name>` ending the name), or unmangled. -/
def handlerOf? (name : String) : Option Full.Opcode :=
  let parts := name.splitOn "ryo_h_"
  if parts.length < 2 then none else
  let op := parts.getLast!
  let ident := "ryo_h_" ++ op
  let shapeOk := name == ident || name.endsWith (toString ident.length ++ ident)
  if !shapeOk then none else
  Full.all.find? fun o => o.info.name == op && o.hasHandler

def probeName : String := "ryo_probe_stack"

def isProbe (name : String) : Bool :=
  name == probeName || name.endsWith (toString probeName.length ++ probeName)

/-- What the code field `at` (a text offset) refers to, by its relocation: the inverse of the
writer's mapping (`finish_encoded`), with the address ranges `ImageResolver::resolve` uses.
`func` is the function the field is in (for its JIT record). -/
def refOf (o : ImageObject) (func : Nat) (r : Rela) : Except String Ref := do
  let h := o.image.header
  let tgt ← o.elf.target r
  match r.type, tgt with
  | .plt32, .named n a =>
    unless a == -4 do throw s!"call relocation at {r.offset} with addend {a}"
    match handlerOf? n with
    | some op => pure (.handler op)
    | none => if isProbe n then pure .probe else throw s!"call relocation at {r.offset} against `{n}`"
  | .pc32, .sect i off =>
    -- The field's target: `S + A + 4` (the field is the item's last 4 bytes).
    let to := off + 4
    let within (base len : Nat) (end_ : Bool) : Option Nat :=
      let d := to - base
      if d ≥ 0 && d < len + (if end_ then 1 else 0) then some d.toNat else none
    if i == o.text.index then
      match within o.textBase h.textSize false with
      | some d =>
        match (o.funcs.findIdx? (·.codeOff == d)) with
        | some f => pure (.func f)
        | none => throw s!"field at {r.offset} points into the text, not at a function"
      | none => throw s!"field at {r.offset} points outside the text"
    else if i == o.ro.index then
      let base := o.roBase
      if let some d := within (base + h.symbols.off) (h.symbols.count * 8) false then
        if d % 8 == 0 then pure (.sym (d / 8)) else throw s!"field at {r.offset} points inside a symbol slot"
      else if let some d := within (base + h.codeConsts.off) h.codeConsts.count false then pure (.ro d)
      else if let some d := within (base + h.consts.off) h.consts.count true then pure (.const d)
      else throw s!"field at {r.offset} points at read-only offset {to - base}"
    else if i == o.data.index then
      let base := o.dataBase
      let rec_ := h.jitRecords.off + 64 * func
      let dataEnd := if h.jitRecords.count != 0 then h.jitRecords.off else h.dataSize
      if h.jitRecords.count != 0 && to == ((base + rec_ : Nat) : Int) then pure .record
      else if h.jitRecords.count != 0 && to == ((base + rec_ + Asm.jitLoopCtr : Nat) : Int) then
        pure .recordLoopCtr
      else if let some d := within base (h.siteCount * 8) false then
        if d % 8 == 0 then pure (.site (d / 8)) else throw s!"field at {r.offset} points inside a site slot"
      else if let some d := within (base + h.fixupArea) (dataEnd - h.fixupArea) true then pure (.data d)
      else throw s!"field at {r.offset} points at writable offset {to - base}"
    else throw s!"field at {r.offset} points into section {i}"
  | ty, .named n _ => throw s!"{ty.name} relocation at {r.offset} against undefined `{n}`"
  | ty, .sect i _ => throw s!"{ty.name} relocation at {r.offset} against section {i}"

/-- The text relocations in `[off, off + len)` of the text (`textBase`-relative). -/
def textRelocsIn (o : ImageObject) (off len : Nat) : Array Rela :=
  let rs := o.textRelocs
  -- The first relocation at or past `a` (binary search).
  let rec lower (a lo hi : Nat) (fuel : Nat) : Nat :=
    match fuel with
    | 0 => lo
    | fuel + 1 =>
      if lo < hi then
        let mid := (lo + hi) / 2
        if rs[mid]!.offset < a then lower a (mid + 1) hi fuel else lower a lo mid fuel
      else lo
  let lo := lower (o.textBase + off) 0 rs.size (rs.size + 1)
  let hi := lower (o.textBase + off + len) 0 rs.size (rs.size + 1)
  rs.extract lo hi

/-- Function `i`'s decoder inputs (`ImageResolver::decode`'s, from the object). -/
def funcInputs (o : ImageObject) (i : Nat) : Except String FuncInputs := do
  let img := o.image
  let some f := img.function? i | throw s!"no function {i}"
  if f.codeOff + f.codeLen > o.textBytes.size then throw s!"function {i}'s code past the text"
  let relocs ← (o.textRelocsIn f.codeOff f.codeLen).mapM fun r => do
    pure ({ pos := r.offset - o.textBase - f.codeOff, to := ← o.refOf i r } : Reloc)
  let some list := InsnList.read (img.list f) f.codeLen
    | throw s!"function {i}: malformed instruction list"
  pure {
    index := i, name := o.funcName f.codeOff, codeOff := f.codeOff,
    code := o.textBytes.extract f.codeOff (f.codeOff + f.codeLen), relocs,
    rodata := img.codeConsts,
    callSites := (img.callSites f).map fun c =>
      if c.pad == CONTINUE then ⟨c.start, c.len, none, false⟩
      else ⟨c.start, c.len, some (c.pad % CATCH), c.pad ≥ CATCH⟩,
    dropped := list.dropped,
    scopes := list.scopes,
    mode := img.mode,
    funcStarts := o.funcs.map (·.codeOff) }

/-! ## The summary (`ryo-lean obj`) -/

private def hex (n : Nat) : String :=
  let s := String.ofList (Nat.toDigits 16 n)
  "0x" ++ s

/-- The image summary `ryo-lean obj` prints, line by line. The Rust reference printer
(`scripts/lean-decode-ref`, `--summary`) prints the same text:

```
image <symbol>
crate_hash <hex> stable_crate_id <hex> cgu_hash <hex> mode <bits> <Mode>
sizes ro <size> data <data_size> text <text_size> sites <site_count> fixup_area <off> jit_records <off>+<count>
parts functions <off>+<n> code_consts .. fixups .. sym_flags .. func_flags .. symbols .. consts .. lists .. call_sites .. const_relocs ..
validate ok | validate error: <ImageError>
sym <i> flags <f> <name>
func <i> off <code_off> len <code_len> arg <arg_size> ret <ret_size> kind <ret_kind> list <bytes> call_sites <n> relocs <n> <name>
  reloc <at> <ref>
```

(a `reloc` line per relocated field of the function, `at` relative to the function; a
field the reader can't classify prints `reloc <at> error: <message>`). -/
def summary (o : ImageObject) : Array String := Id.run do
  let img := o.image
  let h := img.header
  let mut out := #[s!"image {o.symbol}",
    s!"crate_hash {hex h.crateHash} stable_crate_id {hex h.stableCrateId} cgu_hash {hex h.cguHash} mode {h.mode} {img.mode}",
    s!"sizes ro {h.size} data {h.dataSize} text {h.textSize} sites {h.siteCount} fixup_area {h.fixupArea} jit_records {h.jitRecords}",
    s!"parts functions {h.functions} code_consts {h.codeConsts} fixups {h.fixups} sym_flags {h.symFlags} func_flags {h.funcFlags} symbols {h.symbols} consts {h.consts} lists {h.lists} call_sites {h.callSites} const_relocs {h.constRelocs}"]
  out := out.push (match img.validate with
    | .ok () => "validate ok"
    | .error e => s!"validate error: {e}")
  let flags := img.symbolFlags
  for i in [0:h.symbols.count] do
    let name := match o.slotName i with
      | .ok n => n
      | .error e => s!"error: {e}"
    out := out.push s!"sym {i} flags {flags[i]!} {name}"
  let fs := o.funcs
  for i in [0:fs.size] do
    let f := fs[i]!
    let rs := o.textRelocsIn f.codeOff f.codeLen
    out := out.push s!"func {i} off {f.codeOff} len {f.codeLen} arg {f.argSize} ret {f.retSize} kind {f.retKind} list {(img.list f).size} call_sites {(img.callSites f).size} relocs {rs.size} {o.funcName f.codeOff}"
    for r in rs do
      let pos := r.offset - o.textBase - f.codeOff
      out := out.push (match o.refOf i r with
        | .ok ref => s!"  reloc {pos} {ref}"
        | .error e => s!"  reloc {pos} error: {e}")
  return out

end ImageObject

end Ryo.Obj
