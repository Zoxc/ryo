/-
Tests of the object readers (`Ryo/Obj`) on small hand-built inputs: the ELF reader's checks
and error paths, `Image.parse`/`validate`'s, handler symbol names and the decoder's field
classification. The readers are checked on real image objects by
`scripts/lean-decode-diff.py` (against Rust and readelf).
-/
import RyoTest.Harness

namespace RyoTest.Obj

open Ryo.Obj Ryo.Vm

/-! ## Byte builders -/

/-- `v` as `n` little-endian bytes. -/
def le (n v : Nat) : List UInt8 := (List.range n).map fun i => (v / 256 ^ i % 256).toUInt8

def bytes (l : List UInt8) : ByteArray := ⟨l.toArray⟩

/-- A string table of `names`, and each name's offset. -/
def strtab (names : List String) : List UInt8 × List Nat :=
  names.foldl (fun (tab, offs) n => (tab ++ n.toUTF8.toList ++ [0], offs ++ [tab.length])) ([0], [])

def elfHeader (cls : Nat := 2) (data : Nat := 1) (etype : Nat := 1) (machine : Nat := 62)
    (shoff : Nat := 0) (shnum : Nat := 0) (shstrndx : Nat := 0) : List UInt8 :=
  [0x7f, 0x45, 0x4c, 0x46, cls.toUInt8, data.toUInt8, 1] ++ List.replicate 9 0 ++ le 2 etype
    ++ le 2 machine ++ le 4 1 ++ le 8 0 ++ le 8 0 ++ le 8 shoff ++ le 4 0 ++ le 2 64 ++ le 2 0
    ++ le 2 0 ++ le 2 64 ++ le 2 shnum ++ le 2 shstrndx

def shdr (name type flags offset size link info align entsize : Nat) : List UInt8 :=
  le 4 name ++ le 4 type ++ le 8 flags ++ le 8 0 ++ le 8 offset ++ le 8 size ++ le 4 link
    ++ le 4 info ++ le 8 align ++ le 8 entsize

/-- An object with `.shstrtab`, `.symtab` (the null symbol and `foo`, a global function at
`.text` + 4), `.strtab`, `.text` (8 bytes) and `.rela.text` with one relocation of type
`relType` at `relOff` against `foo`. `textSize` overrides `.text`'s header size. -/
def mkObj (relType : Nat := Elf.R_X86_64_PC32) (relOff : Nat := 2) (textSize : Nat := 8) : ByteArray :=
  let (shstr, so) := strtab [".shstrtab", ".symtab", ".strtab", ".text", ".rela.text"]
  let (str, no) := strtab ["foo"]
  let sym (name info shndx value size : Nat) := le 4 name ++ [info.toUInt8, 0] ++ le 2 shndx ++ le 8 value ++ le 8 size
  let symtab := sym 0 0 0 0 0 ++ sym no[0]! (Elf.STB_GLOBAL * 16 + Elf.STT_FUNC) 4 4 4
  let text := List.replicate 8 (0x90 : UInt8)
  let rela := le 8 relOff ++ le 8 (1 * 2 ^ 32 + relType) ++ le 8 (2 ^ 64 - 4)
  let o1 := 64
  let o2 := o1 + shstr.length
  let o3 := o2 + symtab.length
  let o4 := o3 + str.length
  let o5 := o4 + text.length
  let shoff := o5 + rela.length
  let sh := shdr 0 0 0 0 0 0 0 0 0
    ++ shdr so[0]! Elf.SHT_STRTAB 0 o1 shstr.length 0 0 1 0
    ++ shdr so[1]! Elf.SHT_SYMTAB 0 o2 symtab.length 3 1 8 24
    ++ shdr so[2]! Elf.SHT_STRTAB 0 o3 str.length 0 0 1 0
    ++ shdr so[3]! Elf.SHT_PROGBITS (Elf.SHF_ALLOC + Elf.SHF_EXECINSTR) o4 textSize 0 0 16 0
    ++ shdr so[4]! Elf.SHT_RELA 0x40 o5 rela.length 2 4 8 24
  bytes (elfHeader (shoff := shoff) (shnum := 6) (shstrndx := 1) ++ shstr ++ symtab ++ str ++ text ++ rela ++ sh)

def expectError {α} (r : Except String α) (msg : String) : Except String Unit :=
  match r with
  | .ok _ => .error s!"expected an error containing `{msg}`"
  | .error e => if (e.splitOn msg).length > 1 then .ok () else .error s!"expected `{msg}`, got `{e}`"

/-! ## ELF -/

def elfErrors : Except String Unit := do
  expectError (readElf ByteArray.empty) "not ELF"
  expectError (readElf (bytes (List.replicate 64 0))) "bad magic"
  expectError (readElf (bytes (elfHeader (cls := 1)))) "not ELF64"
  expectError (readElf (bytes (elfHeader (data := 2)))) "not little-endian"
  expectError (readElf (bytes (elfHeader (etype := 2)))) "not a relocatable object"
  expectError (readElf (bytes (elfHeader (machine := 3)))) "not x86-64"
  expectError (readElf (bytes (elfHeader (shoff := 64) (shnum := 2)))) "past the end"
  -- Relocation types other than R_X86_64_64, PC32 and PLT32 are rejected (9: GOTPCREL).
  expectError (readElf (mkObj (relType := 9))) "relocation type 9"
  expectError (readElf (mkObj (relOff := 6))) "past the end of section 4"
  expectError (readElf (mkObj (textSize := 4096))) "contents past the end"

def elfRead : Except String Unit := do
  let e ← readElf (bytes (elfHeader))
  check (e.sections.size == 0 && e.symbols.size == 0) "no sections"
  let e ← readElf (mkObj (relType := Elf.R_X86_64_PLT32))
  check (e.sections.map (·.name) == #["", ".shstrtab", ".symtab", ".strtab", ".text", ".rela.text"])
    "section names"
  let some text := e.sectionByName? ".text" | throw "no .text"
  check (text.flags == Elf.SHF_ALLOC + Elf.SHF_EXECINSTR && text.size == 8 && text.addralign == 16)
    "section header fields"
  check ((e.data text).toList == List.replicate 8 0x90) "section contents"
  let some foo := e.symbol? 1 | throw "no symbol 1"
  check (foo.name == "foo" && foo.value == 4 && foo.size == 4 && foo.bind == Elf.STB_GLOBAL
    && foo.type == Elf.STT_FUNC && foo.shndx == 4 && foo.defined) "symbol fields"
  check (!(e.symbols[0]!).defined) "the null symbol is undefined"
  match (e.relocsOf 4).toList with
  | [r] => check (r.offset == 2 && r.sym == 1 && r.type == .plt32 && r.addend == -4) "relocation fields"
  | _ => throw "expected one relocation of .text"
  check (e.dump.size == 6 + 2 + 1) "dump lines"
  check (toSigned 32 0xffffffff == -1 && toSigned 32 5 == 5) "toSigned"
  check ((readU32 (bytes [1, 2, 3, 4]) 0).toOption == some 0x04030201) "readU32"
  check ((readU32 (bytes [1, 2, 3]) 0).toOption.isNone) "readU32 out of bounds"
  -- An object that is ELF but has no image.
  expectError (readImageObject (mkObj)) "no image symbol"

/-! ## The image -/

structure H where
  size : Option Nat := none
  dataSize : Nat := 0
  functions : Span := ⟨136, 0⟩
  textSize : Nat := 0
  codeConsts : Span := ⟨136, 0⟩
  fixups : Span := ⟨136, 0⟩
  symFlags : Span := ⟨136, 0⟩
  symbols : Span := ⟨136, 0⟩
  consts : Span := ⟨136, 0⟩
  lists : Span := ⟨136, 0⟩
  callSites : Span := ⟨136, 0⟩
  siteCount : Nat := 0
  fixupArea : Nat := 0
  mode : Nat := MODE_FP_ARG + MODE_FRAME_POINTER
  jitRecords : Span := ⟨0, 0⟩

def span (s : Span) : List UInt8 := le 4 s.off ++ le 4 s.count

/-- An image: the header `h`, then `rest`. -/
def mkImage (h : H) (rest : List UInt8 := []) (magic : String := "RYOIMAGE") : ByteArray :=
  let size := h.size.getD (136 + rest.length)
  bytes (magic.toUTF8.toList ++ le 4 0 ++ le 4 size ++ le 8 0 ++ le 8 0 ++ le 4 h.dataSize
    ++ le 4 h.textSize ++ le 8 0 ++ span h.functions ++ span h.codeConsts
    ++ span h.fixups ++ span h.symFlags ++ span h.symbols ++ span h.consts ++ span h.lists
    ++ span h.callSites ++ le 4 h.siteCount ++ le 4 h.fixupArea ++ le 4 h.mode
    ++ span h.jitRecords ++ le 4 0 ++ rest)

def funcEntry (off len : Nat) (list callSites : Span := ⟨0, 0⟩) : List UInt8 :=
  le 4 off ++ le 4 len ++ le 4 0 ++ le 4 0 ++ le 4 0 ++ span list ++ span callSites

def expectParse (b : ByteArray) (e : ImageError) (aligned := true) : Except String Unit :=
  match Image.parse b aligned with
  | .ok _ => .error s!"expected {e}, parsed"
  | .error e' => check (e == e') s!"expected {e}, got {e'}"

def expectValidate (b : ByteArray) (e : ImageError) : Except String Unit :=
  match Image.parse b with
  | .error e' => .error s!"expected {e} from validate, parse failed with {e'}"
  | .ok img => match img.validate with
    | .ok () => .error s!"expected {e}, validated"
    | .error e' => check (e == e') s!"expected {e}, got {e'}"

def imageParse : Except String Unit := do
  check ((Image.parse (mkImage {})).toOption.isSome) "the empty image parses"
  expectParse (bytes (List.replicate 100 0)) .truncated
  expectParse (mkImage {}) .misaligned (aligned := false)
  expectParse (mkImage {} (magic := "RYOIMAGX")) .badMagic
  expectParse (mkImage { size := some 200 }) .truncated
  expectParse (mkImage { functions := ⟨136, 1⟩ }) (.outOfBounds "functions")
  expectParse (mkImage { symbols := ⟨140, 0⟩, symFlags := ⟨140, 0⟩ } (List.replicate 8 0)) .misaligned
  expectParse (mkImage { mode := 0 }) .badMode
  expectParse (mkImage { mode := MODE_FRAME_POINTER + 32 }) .badMode
  -- Without a frame pointer, `fp_arg` is required and PE excluded (`Mode::valid`).
  expectParse (mkImage { mode := MODE_FP_ARG + MODE_PE }) .badMode
  check ((Image.parse (mkImage { mode := MODE_FP_ARG })).toOption.isSome) "fp_arg alone is valid"
  expectParse (mkImage { symFlags := ⟨136, 1⟩ } [0]) (.outOfBounds "symbol flags")
  expectParse (mkImage { siteCount := 1, fixupArea := 0 }) .badData
  -- With counters, one 64-aligned JIT record per function.
  let f := funcEntry 0 0
  let counters := MODE_FP_ARG + MODE_FRAME_POINTER + MODE_COUNTERS
  expectParse (mkImage { functions := ⟨136, 1⟩, mode := counters, dataSize := 128 } f) .badData
  expectParse (mkImage { functions := ⟨136, 1⟩, mode := counters, dataSize := 128, jitRecords := ⟨32, 1⟩ } f) .badData
  let good : H := { functions := ⟨136, 1⟩, mode := counters, dataSize := 128, jitRecords := ⟨64, 1⟩ }
  let img ← match Image.parse (mkImage good f) with
    | .ok i => pure i
    | .error e => throw s!"expected a parse, got {e}"
  check (img.mode == { fpArg := true, framePointer := true, alignLoops := false, pe := false, counters := true })
    "mode"

def imageValidate : Except String Unit := do
  expectValidate (mkImage { functions := ⟨136, 1⟩, textSize := 16 } (funcEntry 0 32)) (.badFunction 0)
  expectValidate (mkImage { functions := ⟨136, 2⟩, textSize := 64 } (funcEntry 32 16 ++ funcEntry 0 16))
    (.badFunction 1)
  -- Function 0's instruction list: a modifier of kind 5, an entry past the code's end, the
  -- entries at one position out of order (an end scope before a target), a target twice.
  for bad in [[0x01, 0x05], [0x41, 0x00], [0x01, 0x03, 0x00, 0x08, 0x01, 0x00], [0x01, 0x00, 0x01, 0x00]] do
    let rest := funcEntry 0 16 (list := ⟨0, bad.length⟩) ++ bad
    expectValidate (mkImage { functions := ⟨136, 1⟩, textSize := 16, lists := ⟨172, bad.length⟩ } rest) (.badList 0)
  -- A call site past the function's end.
  let rest := funcEntry 0 16 (callSites := ⟨0, 1⟩) ++ le 4 8 ++ le 4 16 ++ le 4 CONTINUE
  expectValidate (mkImage { functions := ⟨136, 1⟩, textSize := 16, callSites := ⟨172, 1⟩ } rest) (.badCallSite 0)
  -- A dropped store of 16 bytes (`size_log2` 4), one of `rbx` (3).
  for bad in [[0x01, 0x01, 0x00, 0x40], [0x01, 0x01, 0x00, 0x33]] do
    let rest := funcEntry 0 16 (list := ⟨0, 4⟩) ++ bad
    expectValidate (mkImage { functions := ⟨136, 1⟩, textSize := 16, lists := ⟨172, 4⟩ } rest) (.badList 0)
  -- A well-formed list: a target at 4, an escape (offset -8, size 8, align 8) and a dropped
  -- store (offset -16, 8 bytes, `rdx`) at 8, an instruction entry (opcode 0, selector 9) at 12.
  let good := [0x09, 0x00, 0x09, 0x02, 0x0f, 0x08, 0x08, 0x01, 0x01, 0x1f, 0x32, 0x08, 0x00, 0x09]
  let rest := funcEntry 0 16 (list := ⟨0, good.length⟩) ++ good
  match Image.parse (mkImage { functions := ⟨136, 1⟩, textSize := 16, lists := ⟨172, good.length⟩ } rest) with
  | .error e => throw s!"parse: {e}"
  | .ok img =>
    if let .error e := img.validate then throw s!"expected the list to validate, got {e}"
    let some l := InsnList.read (img.list img.functions[0]!) 16 | throw "the list doesn't read"
    check (l.targets == #[4] && l.hints == #[⟨12, ⟨0⟩, 9⟩]
      && l.scopes == #[⟨8, -8, 8, .escape 8⟩] && l.dropped == #[⟨8, -16, 8, 2⟩]) s!"the list read: {repr l}"
  -- A function's run past its table.
  let rest := funcEntry 0 16 (list := ⟨0, 1⟩)
  expectValidate (mkImage { functions := ⟨136, 1⟩, textSize := 16 } rest) (.badFunction 0)
  expectValidate (mkImage { symFlags := ⟨136, 1⟩, symbols := ⟨144, 1⟩ } ([2] ++ List.replicate 15 0))
    (.badSymbolFlags 0)
  -- A good one: a function with a call site to a catching pad.
  let rest := funcEntry 0 16 (callSites := ⟨0, 1⟩) ++ le 4 0 ++ le 4 5 ++ le 4 (CATCH + 8)
  match Image.parse (mkImage { functions := ⟨136, 1⟩, textSize := 16, callSites := ⟨172, 1⟩ } rest) with
  | .error e => throw s!"parse: {e}"
  | .ok img =>
    if let .error e := img.validate then throw s!"expected it to validate, got {e}"
    match (img.callSites (img.functions[0]!)).toList with
    | [c] => check (c.start == 0 && c.len == 5 && c.pad == CATCH + 8) "call site"
    | _ => throw "one call site"

/-! ## Names and fields -/

def names : Except String Unit := do
  check (ImageObject.handlerOf? "_RNvCs5fGHjzWXRav_7___rustc15ryo_h_AddrConst" == some Full.Opcode.addrConst)
    "mangled handler"
  check (ImageObject.handlerOf? "ryo_h_AddW32" == some Full.Opcode.addW32) "bare handler"
  check (ImageObject.handlerOf? "_RNvCs5fGHjzWXRav_7___rustc14ryo_h_AddrConst" == none) "wrong length"
  check (ImageObject.handlerOf? "ryo_h_NotAnOpcode" == none) "unknown opcode"
  -- `island` has no handler.
  check (ImageObject.handlerOf? "ryo_h_Island" == none) "opcode without a handler"
  check (ImageObject.isProbe "_RNvCs5fGHjzWXRav_7___rustc15ryo_probe_stack") "probe"
  check (!ImageObject.isProbe "_RNvCs5fGHjzWXRav_7___rustc14ryo_probe_stack") "probe, wrong length"
  check (Ref.render (.handler Full.Opcode.addW32) == "handler AddW32" && Ref.render .recordCtr == "recctr")
    "Ref.render"

def fields : Except String Unit := do
  let f : FuncInputs := {
    index := 1, name := "f", codeOff := 64, code := bytes (List.replicate 32 0x90),
    relocs := #[⟨10, .probe⟩, ⟨20, .sym 3⟩], rodata := ByteArray.empty, callSites := #[],
    dropped := #[], scopes := #[], mode := Mode.ofBits 3, funcStarts := #[0, 64, 128] }
  check (f.field 9 1 5 0 == .ref .probe) "relocated field"
  check (f.field 19 1 5 0 == .ref (.sym 3)) "relocated field (2)"
  check (f.field 0 1 5 10 == .local 15) "branch within the function"
  check (f.field 0 1 5 (-5) == .ref (.func 1)) "call of the function itself"
  check (f.field 0 1 5 59 == .ref (.func 2)) "call of the next function"
  check (f.field 0 1 5 (-69) == .ref (.func 0)) "call of the first function"
  check (f.field 0 1 5 35 == .bad) "into another function's middle"
  check (f.field 0 1 5 (-100) == .bad) "before the text"

def tests : List TestCase := [
  ⟨"Obj/elf-errors", fun _ => elfErrors⟩,
  ⟨"Obj/elf-read", fun _ => elfRead⟩,
  ⟨"Obj/image-parse", fun _ => imageParse⟩,
  ⟨"Obj/image-validate", fun _ => imageValidate⟩,
  ⟨"Obj/names", fun _ => names⟩,
  ⟨"Obj/fields", fun _ => fields⟩,
]

end RyoTest.Obj
