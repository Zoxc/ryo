/-
Tests of the image checks (`Ryo/Check/Image`, aot.md §C4) on image and registry objects built
here from bytes: a small ELF writer, an image of two VM functions in the counters mode (an
entry counter check and its stub, a handler call taking a symbol slot's address, a call of the
other function, which carries no relocation and is a call site), with its JIT records, the
header's anchor field, the `__ryo_main` slot, its registration entry, `.eh_frame` and LSDAs,
all named with the ABI tag `abiTag`, and a registry stub of that tag. The objects pass every
check; mutations of them (a function's length, a relocation dropped or added, a JIT record's
counter, the entry's relocation, the header's `abi` and `anchor`, a name with another tag, the
stub's bounds and anchor, an FDE's range, row or CFA offset, an LSDA's call sites) are
rejected. The checks run on real objects in `scripts/lean-image-check.py`.
-/
import RyoTest.Harness
import RyoTest.Obj

namespace RyoTest.ImageCheck

open Ryo.Obj Ryo.X86 Ryo.Check.Image RyoTest.Obj
open Ryo.Vm (Full.all)

/-! ## A small ELF writer -/

structure Sec where
  name : String
  type : Nat := Elf.SHT_PROGBITS
  flags : Nat
  data : List UInt8
  align : Nat := 8
deriving Inhabited

/-- A symbol; `shndx` the index of a section in the list given to `write` (from 1), or 0. -/
structure Sym where
  name : String
  value : Nat := 0
  size : Nat := 0
  bind : Nat := Elf.STB_GLOBAL
  type : Nat := Elf.STT_NOTYPE
  vis : Nat := 0
  shndx : Nat := 0
deriving Inhabited

/-- A relocation of section `sec` (from 1) against symbol `sym` (from 1). -/
structure Rel where
  sec : Nat
  off : Nat
  sym : Nat
  type : Nat
  addend : Int := 0

structure Parts where
  secs : Array Sec
  syms : Array Sym
  rels : Array Rel

def pad (n a : Nat) : Nat := (n + a - 1) / a * a

/-- The object: the sections `1..k`, a `.rela` section per relocated one, `.symtab`,
`.strtab`, `.shstrtab`, then the section headers. -/
def Parts.write (p : Parts) : ByteArray := Id.run do
  let k := p.secs.size
  let targets := (List.range k).map (· + 1) |>.filter fun i => p.rels.any (·.sec == i)
  let symtabIdx := k + targets.length + 1
  let (str, nameOffs) := strtab (p.syms.toList.map (·.name))
  let symEntry (s : Sym) (no : Nat) : List UInt8 :=
    le 4 no ++ [(s.bind * 16 + s.type).toUInt8, s.vis.toUInt8] ++ le 2 s.shndx ++ le 8 s.value ++ le 8 s.size
  let symtab := List.replicate 24 0 ++ (p.syms.toList.zip nameOffs).flatMap fun (s, no) => symEntry s no
  let relaOf (i : Nat) : List UInt8 := (p.rels.toList.filter (·.sec == i)).flatMap fun r =>
    le 8 r.off ++ le 8 (r.sym * 2 ^ 32 + r.type) ++ le 8 (r.addend.toNat + (if r.addend < 0 then 2 ^ 64 - r.addend.natAbs else 0))
  let names := p.secs.toList.map (·.name) ++ targets.map (fun i => ".rela" ++ p.secs[i - 1]!.name)
    ++ [".symtab", ".strtab", ".shstrtab"]
  let (shstr, shOffs) := strtab names
  let mut out : List UInt8 := []
  let mut hdrs : List UInt8 := List.replicate 64 0
  let mut off := 64
  let mut j := 0
  let place (out : List UInt8) (off a : Nat) : List UInt8 × Nat :=
    let o := pad off a
    (out ++ List.replicate (o - off) 0, o)
  for s in p.secs do
    let (o1, o) := place out off s.align
    out := o1 ++ s.data
    hdrs := hdrs ++ shdr shOffs[j]! s.type s.flags o s.data.length 0 0 s.align 0
    off := o + s.data.length
    j := j + 1
  for i in targets do
    let d := relaOf i
    let (o1, o) := place out off 8
    out := o1 ++ d
    hdrs := hdrs ++ shdr shOffs[j]! Elf.SHT_RELA 0x40 o d.length symtabIdx i 8 24
    off := o + d.length
    j := j + 1
  let locals := 1 + (p.syms.toList.takeWhile (·.bind == Elf.STB_LOCAL)).length
  for (d, ty, link, info, al, es) in [(symtab, Elf.SHT_SYMTAB, symtabIdx + 1, locals, 8, 24),
      (str, Elf.SHT_STRTAB, 0, 0, 1, 0), (shstr, Elf.SHT_STRTAB, 0, 0, 1, 0)] do
    let (o1, o) := place out off al
    out := o1 ++ d
    hdrs := hdrs ++ shdr shOffs[j]! ty 0 o d.length link info al es
    off := o + d.length
    j := j + 1
  let (o1, shoff) := place out off 8
  bytes (elfHeader (shoff := shoff) (shnum := j + 1) (shstrndx := j) ++ o1 ++ hdrs)

/-! ## An image object -/

def mode : Mode := Mode.ofBits 21
def frameSize : Nat := 16
def stableId : Nat := 0x0123456789abcdef
def addrSym : Nat := (Full.all.find? (·.info.name == "AddrSym")).get!.val.toNat

def bv32 (n : Nat) : BitVec 32 := BitVec.ofNat 32 n

/-- The objects' ABI tag (a real build's is 16 hex digits, `y build`'s `RYO_ABI`). -/
def abiTag : String := "0123abcd"

/-- `name` mangled as rustc mangles `ryo_rt`'s internal symbols (a v0 identifier ending it). -/
def mangleRt (name : String) : String := "_RNvCs5fGHjzWXRav_7___rustc" ++ toString name.length ++ name

/-- Function 0: the entry's counter check, the prologue, `addr.sym` of slot 0 into
`[fp - 16]` (the frame is addressed from `rsp`: `fp` is `rsp + 16`), a call of function 1,
`ret`, the entry's stub. -/
def f0Items (back stub : Nat) : List Item :=
  [.ctrInc false, .branch .ns (bv32 stub) true] ++ Ryo.Vm.Asm.prologue frameSize mode ++
  [.leaM .rdi ⟨.rsp, bv32 frameSize⟩, .setReg .rsi (BitVec.ofNat 64 0xfffffff0), .lea .rdx (.sym 0),
   .call (.handler addrSym), .call (.func 1)] ++
  (Ryo.Vm.Asm.epilogue frameSize mode ++ [.ret]) ++ entryStub (bv32 back) true

/-- Function 1: the counter check, a frame of 0, `ret`, the stub. -/
def f1Items (back stub : Nat) : List Item :=
  [.ctrInc false, .branch .ns (bv32 stub) true] ++ Ryo.Vm.Asm.prologue 0 mode ++
  (Ryo.Vm.Asm.epilogue 0 mode ++ [.ret]) ++ entryStub (bv32 back) true

def len (items : List Item) : Nat := (encodeItems items).1.length

/-- The function's code and its relocations, with `back` after the first two items and the
stub after all but the last three. -/
def funcCode (mk : Nat → Nat → List Item) : List UInt8 × List Ryo.X86.Reloc :=
  let dummy := mk 0 0
  let back := len (dummy.take 2)
  let stub := len (dummy.take (dummy.length - 3))
  encodeItems (mk back stub)

/-- The position of function 0's `call` of function 1's field. -/
def callField : Nat := ((funcCode f0Items).2.find? (·.to == Ryo.X86.Ref.func 1)).get!.pos

/-- Function 0's one call site: the `call` of function 1, unwinding continuing in the caller. -/
def site0 : CallSite := ⟨callField - 1, 5, none, false⟩

/-- The position of function 0's handler `call`. -/
def handlerCall : Nat := ((funcCode f0Items).2.find? (·.to == Ryo.X86.Ref.handler addrSym)).get!.pos - 1

/-- LEB128. -/
def leb (n : Nat) : List UInt8 :=
  if h : n < 128 then [n.toUInt8] else (n % 128 + 128).toUInt8 :: leb (n / 128)
decreasing_by omega

/-- Function 0's instruction list: the handler call's entry (`HANDLER_SEL`, stored as 0). -/
def list0 : List UInt8 := leb (2 * handlerCall) ++ leb addrSym ++ [0]

/-- Where the function table starts: after the header. -/
def funcsOff : Nat := headerSize
/-- Where the instruction lists start, in the padding after the function flags. -/
def listsOff : Nat := 248

-- Read-only layout: header (168 bytes), 2 functions at 168, function flags at 240, function 0's
-- instruction list at 248, code constants (none, at 264), fixups (none), 1 symbol flag at 264,
-- the slot at 272, no pool, the call-site table at 280 (one entry), no constant relocations
-- (at 292).
def roSize : Nat := 292
def slotOff : Nat := 272
def cgu : Nat := 0xfedcba9876543210
def recOff : Nat := 64
def dataSize : Nat := 64 + 2 * 64

/-- `DW_CFA_advance_loc*` by `d`. -/
def advance (d : Nat) : List UInt8 :=
  if d < 64 then [(0x40 + d).toUInt8] else if d < 256 then [0x02, d.toUInt8] else 0x03 :: le 2 d

def padTo8 (body : List UInt8) : List UInt8 := body ++ List.replicate ((8 - (body.length + 4) % 8) % 8) 0

/-- `.eh_frame` as `unwind_elf` writes it for this mode (no frame pointer, counters): the CIE,
then per function (`code_off`, `code_len`, frame size `F`, LSDA offset) an FDE whose rows
change after the counter check and `sub rsp` (13 + 4 bytes in) to CFA `rsp + F + 16`, and at
the entry stub (the last 16 bytes) back to `rsp + 8`; with its relocations (section 5, against
symbols 3 the text, 1 the read-only section, 13 the LSDAs). -/
def ehFrame (funcs : List (Nat × Nat × Nat × Nat)) : List UInt8 × Array Rel := Id.run do
  let cie := padTo8 ([0, 0, 0, 0, 1] ++ "zPLR".toUTF8.toList ++ [0, 1, 0x78, 16, 7, 0x9b, 0, 0, 0, 0, 0x1b, 0x1b,
    0x0c, 7, 8, 0x90, 1])
  let mut eh := le 4 cie.length ++ cie
  let mut rels : Array Rel := #[⟨5, 4 + 15, 1, Elf.R_X86_64_PC32, slotOff⟩]
  for (off, len, f, l) in funcs do
    let at_ := eh.length
    let stub := len - 16  -- `lea r11, [rip + rec]; call [r11 + 8]; jmp rel32`
    let fde := padTo8 (le 4 (at_ + 4) ++ le 4 0 ++ le 4 len ++ [4] ++ le 4 0 ++ advance 17 ++ [0x0e, (f + 16).toUInt8]
      ++ advance (stub - 17) ++ [0x0c, 7, 8])
    rels := rels.push ⟨5, at_ + 8, 3, Elf.R_X86_64_PC32, off⟩
    rels := rels.push ⟨5, at_ + 17, 13, Elf.R_X86_64_PC32, l⟩
    eh := eh ++ le 4 fde.length ++ fde
  return (eh, rels)

/-- The image object's parts. Sections: 1 read-only, 2 writable, 3 text, 4 `__ryo_main`,
5 `.eh_frame`, 6 the LSDAs (function 0's of the call sites `lsda0`), 7 the registration entry
(`ryo_images_<tag>`). Symbols: 1–3 the first three sections' symbols, 4–5 the functions, 6
the image, 7 the slot's `rust_eh_personality`, 8 `ryo_h_AddrSym_<tag>`, 9–10 the trip entry
points (mangled), 11 the anchor (the header's `anchor` field's), 12 `__ryo_main`, 13 the LSDA
section's. With `resolve`, the call of function 1 holds its displacement, as the writer
resolves it; without, its field is 0. -/
def imageParts (resolve : Bool := true) (lsda0 : Array CallSite := #[site0]) : Parts := Id.run do
  let (c0, r0) := funcCode f0Items
  let (c1, r1) := funcCode f1Items
  let f1Off := pad c0.length 16
  let mut code0 := c0.toArray
  for r in r0 do
    if r.to == Ryo.X86.Ref.func 1 && resolve then
      let d := (BitVec.ofInt 32 ((f1Off : Int) - (r.pos + 4 : Nat))).toNat
      for k in [0:4] do code0 := code0.set! (r.pos + k) ((d >>> (8 * k)) % 256).toUInt8
  let text := code0.toList ++ List.replicate (f1Off - c0.length) 0xcc ++ c1
  let entry (off len : Nat) (list sites : Span) : List UInt8 :=
    le 4 off ++ le 4 len ++ List.replicate 12 0 ++ span list ++ span sites
  let header := "RYOIMAGE".toUTF8.toList ++ le 4 (crateHash stableId) ++ le 4 roSize ++ le 8 stableId
    ++ le 8 0 ++ le 4 dataSize ++ le 4 text.length ++ le 8 0 ++ span ⟨funcsOff, 2⟩
    ++ span ⟨264, 0⟩ ++ span ⟨264, 0⟩ ++ span ⟨264, 1⟩ ++ span ⟨240, 2⟩ ++ span ⟨slotOff, 1⟩ ++ span ⟨280, 0⟩
    ++ span ⟨listsOff, list0.length⟩ ++ span ⟨280, 1⟩ ++ le 4 21 ++ le 4 0 ++ span ⟨recOff, 2⟩ ++ span ⟨roSize, 0⟩
    ++ le 8 cgu ++ le 8 (abiHash abiTag) ++ le 8 0
  let ro := header ++ entry 0 c0.length ⟨0, list0.length⟩ ⟨0, 1⟩ ++ entry f1Off c1.length ⟨list0.length, 0⟩ ⟨1, 0⟩
    ++ List.replicate (listsOff - 240) 0 ++ list0 ++ List.replicate (264 - listsOff - list0.length) 0 ++ [0]
    ++ List.replicate 7 0 ++ le 8 0 ++ le 4 site0.start ++ le 4 site0.len ++ le 4 CONTINUE
  let lsda0 := (Lsda.write lsda0).toList
  let lsda1 := (Lsda.write #[]).toList
  let (eh, ehRels) := ehFrame [(0, c0.length, frameSize, 0), (f1Off, c1.length, 0, lsda0.length)]
  let record (i : Nat) : List UInt8 :=
    le 8 (2 ^ 64 - jitEntryThreshold) ++ List.replicate 28 0 ++ le 4 i ++ List.replicate 16 0 ++
      le 8 (2 ^ 64 - jitThreshold)
  let data := List.replicate recOff 0 ++ record 0 ++ record 1
  let secs : Array Sec := #[
    { name := ".data.rel.ro.ryo_image", flags := 3, data := ro, align := 16 },
    { name := ".data.ryo_image", flags := 3, data := data, align := 64 },
    { name := ".text.ryo_image", flags := 6, data := text, align := 16 },
    { name := ".data.rel.ro.ryo_main", flags := 3, data := List.replicate 8 0 },
    { name := ".eh_frame", type := 0x70000001, flags := 2, data := eh },
    { name := ".gcc_except_table.ryo_image", flags := 2, data := lsda0 ++ lsda1, align := 4 },
    { name := entriesSection abiTag, flags := 3 + Elf.SHF_GNU_RETAIN, data := List.replicate 8 0 }]
  let syms : Array Sym := #[
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 1 },
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 2 },
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 3 },
    { name := "f0", bind := 0, type := Elf.STT_FUNC, shndx := 3, size := c0.length },
    { name := "f1", type := Elf.STT_FUNC, vis := 2, shndx := 3, value := f1Off, size := c1.length },
    { name := imageSymbol stableId cgu, type := Elf.STT_OBJECT, vis := 2, shndx := 1, size := roSize },
    { name := "rust_eh_personality" }, { name := mangleRt (tagged "ryo_h_AddrSym" abiTag) },
    { name := mangleRt (tagged tripEntryName abiTag) }, { name := mangleRt (tagged tripOsrName abiTag) },
    { name := anchorName abiTag },
    { name := mainSlotName, type := Elf.STT_OBJECT, vis := 2, shndx := 4, size := 8 },
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 6 }]
  let abs := Elf.R_X86_64_64
  let mut rels : Array Rel := ehRels ++ #[⟨1, 24, 2, abs, 0⟩, ⟨1, 40, 3, abs, 0⟩, ⟨1, slotOff, 7, abs, 0⟩,
    ⟨1, headerAnchorOff, 11, abs, 0⟩, ⟨4, 0, 5, abs, 0⟩, ⟨7, 0, 1, abs, 0⟩]
  for i in [0:2] do
    let r := recOff + 64 * i
    rels := rels ++ #[⟨2, r + 8, 9, abs, 0⟩, ⟨2, r + 16, 10, abs, 0⟩, ⟨2, r + 40, 1, abs, 0⟩]
  for (base, rs, func) in [(0, r0, 0), (f1Off, r1, 1)] do
    let rec_ : Int := recOff + 64 * func
    for r in rs do
      match (r.to : Ryo.X86.Ref) with
      | .handler _ => rels := rels.push ⟨3, base + r.pos, 8, Elf.R_X86_64_PLT32, -4⟩
      | .sym s => rels := rels.push ⟨3, base + r.pos, 1, Elf.R_X86_64_PC32, (slotOff + 8 * s : Nat) - 4⟩
      | .recordLoopCtr => rels := rels.push ⟨3, base + r.pos, 2, Elf.R_X86_64_PC32, rec_ + 56 - 4⟩
      | .record => rels := rels.push ⟨3, base + r.pos, 2, Elf.R_X86_64_PC32, rec_ - 4⟩
      | _ => pure ()
  return { secs, syms, rels }


def readObj (p : Parts) : Except String ImageObject := readImageObject p.write

def mismatches (p : Parts) : Except String (Array String) := do
  return (checkObject (← readObj p)).mismatches

def expectClean (p : Parts) : Except String Unit := do
  let m ← mismatches p
  check m.isEmpty s!"expected no mismatches, got {m}"

def expectMismatch (p : Parts) (msg : String) : Except String Unit := do
  let m ← mismatches p
  check (m.any fun l => (l.splitOn msg).length > 1) s!"expected a mismatch containing `{msg}`, got {m}"

/-- Sets 4 bytes of section `i`'s (from 1) data at `off`. -/
def Parts.poke (p : Parts) (i off v : Nat) : Parts :=
  let s := p.secs[i - 1]!
  let d := s.data.toArray
  let d := (List.range 4).foldl (fun d k => d.set! (off + k) ((v >>> (8 * k)) % 256).toUInt8) d
  { p with secs := p.secs.set! (i - 1) { s with data := d.toList } }

def imagePositive : Except String Unit := do
  let p := imageParts
  let o ← readObj p
  check (o.funcs.size == 2) "two functions"
  check (Ryo.Vm.DecodeObj.objLines o |>.all fun l => (l.splitOn "error").length == 1) "decodes"
  expectClean p
  let r := checkObject o
  check (r.main.map (·.func) == some (some 1)) "__ryo_main names function 1"
  -- Unresolved, the call of function 1 is a call of the next byte: the decode fails.
  expectMismatch (imageParts (resolve := false)) "decode"

def imageNegative : Except String Unit := do
  let p := imageParts
  let c0 := (p.syms[3]!).size
  -- Function 0's code_len, one more or one less.
  expectMismatch (p.poke 1 (funcsOff + 4) (c0 + 1)) "st_size"
  expectMismatch (p.poke 1 (funcsOff + 4) (c0 - 1)) "decode"
  -- The handler call's relocation dropped.
  let noCall := { p with rels := p.rels.filter (·.type != Elf.R_X86_64_PLT32) }
  expectMismatch noCall "func 0"
  -- A relocation of the header's `crate_hash` field.
  expectMismatch { p with rels := p.rels.push ⟨1, 8, 7, Elf.R_X86_64_64, 0⟩ } "read-only"
  -- A relocation in the padding between the functions.
  expectMismatch { p with rels := p.rels.push ⟨3, c0, 8, Elf.R_X86_64_PLT32, -4⟩ } "outside every function"
  -- The call of function 1 relocated against the text (the writer resolves it).
  let f1Off := (p.syms[4]!).value
  let p2 := (p.poke 3 callField 0)
  expectMismatch { p2 with rels := p2.rels.push ⟨3, callField, 3, Elf.R_X86_64_PC32, (f1Off : Int) - 4⟩ }
    "calls between functions carry none"
  -- A JIT record's counter, the trip entry's relocation.
  expectMismatch (p.poke 2 recOff 5) "ctr_e"
  expectMismatch (p.poke 2 (recOff + 56) 5) "ctr_l"
  expectMismatch { p with rels := p.rels.filter (fun r => !(r.sec == 2 && r.off == recOff + 8)) } "JIT record 0"
  -- The symbol slot's relocation, twice; its flag set.
  expectMismatch { p with rels := p.rels.push ⟨1, slotOff, 7, Elf.R_X86_64_64, 0⟩ } "symbol slot 0: 2 relocations"
  expectMismatch (p.poke 1 264 1) "SYM_INDIRECT"
  -- The anchor field: unrelocated, relocated against another tag's anchor, nonzero, a second
  -- relocation against the anchor elsewhere, the anchor defined here.
  let isAnchor (r : Rel) := r.sec == 1 && r.off == headerAnchorOff
  expectMismatch { p with rels := p.rels.filter (!isAnchor ·) } "anchor: 0 relocations"
  let other := p.syms.set! 10 { p.syms[10]! with name := anchorName "ffff" }
  expectMismatch { p with syms := other } "header `anchor`"
  expectMismatch (p.poke 1 headerAnchorOff 1) "header: anchor"
  expectMismatch { p with rels := p.rels.push ⟨2, 0, 11, Elf.R_X86_64_64, 0⟩ } "anchor: 2 relocations"
  let defd := p.syms.set! 10 { p.syms[10]! with shndx := 2, type := Elf.STT_OBJECT, size := 1 }
  expectMismatch { p with syms := defd } "is defined in the image object"
  -- The header's `abi`: another tag's hash.
  let p2 := (p.poke 1 152 (abiHash "ffff" % 2 ^ 32)).poke 1 156 (abiHash "ffff" / 2 ^ 32)
  expectMismatch p2 "header: abi"
  -- Runtime symbols of another tag: the handler, a trip.
  let otherTag (k : Nat) (n : String) := { p with syms := p.syms.set! k { p.syms[k]! with name := mangleRt (tagged n "ffff") } }
  expectMismatch (otherTag 7 "ryo_h_AddrSym") "the object's ABI tag"
  expectMismatch (otherTag 8 tripEntryName) "JIT record 0: entry"
  -- The registration section of another tag (the other names then don't match it), two of them.
  let renamed := { p with secs := p.secs.modify 6 fun s => { s with name := entriesSection "ffff" } }
  expectMismatch renamed "header: abi"
  let two := { p with secs := p.secs.push { name := entriesSection "ffff", flags := 3, data := List.replicate 8 0 } }
  expectMismatch two "entry: 2 `ryo_images_<tag>` sections"
  -- A wrong image symbol for the stable crate id.
  let syms := p.syms.set! 5 { p.syms[5]! with name := imageSymbol (stableId + 1) cgu }
  expectMismatch { p with syms } "stable_crate_id"
  let syms := p.syms.set! 5 { p.syms[5]! with name := imageSymbol stableId (cgu + 1) }
  expectMismatch { p with syms } "cgu_hash"
  -- The registration entry: missing, against the writable section, not retained.
  expectMismatch { p with rels := p.rels.filter (·.sec != 7) } "entry: 0 relocations"
  expectMismatch { p with rels := p.rels.map fun r => if r.sec == 7 then { r with sym := 2 } else r } "entry:"
  expectMismatch { p with secs := p.secs.modify 6 fun s => { s with flags := 3 } } "SHF_GNU_RETAIN"
  -- The constant relocation table: an entry, with an empty pool (validate rejects it too).
  let p2 := { p with secs := p.secs.modify 0 fun s => { s with data := s.data ++ le 4 0 } }
  expectMismatch ((p2.poke 1 136 roSize).poke 1 140 1 |>.poke 1 12 (roSize + 4)) "const_relocs: 1 entries"
  -- A function symbol of the wrong size, a missing one.
  expectMismatch { p with syms := p.syms.set! 4 { p.syms[4]! with size := 3 } } "st_size 3"
  expectMismatch { p with syms := p.syms.set! 4 { p.syms[4]! with type := Elf.STT_OBJECT } } "no function symbol"
  -- `ret_kind` 8 on function 1: its `ret` loads nothing, and function 0's call collects nothing.
  let k1 := funcsOff + 36 + 16
  expectMismatch (p.poke 1 k1 8) "ret of kind"
  expectMismatch (p.poke 1 k1 8) "collects kind"

/-- Sets byte `off` of section `i`'s (from 1) data. -/
def Parts.poke1 (p : Parts) (i off v : Nat) : Parts :=
  let s := p.secs[i - 1]!
  { p with secs := p.secs.set! (i - 1) { s with data := s.data.set off v.toUInt8 } }

/-- Mutations of the unwind tables (section 5). Function 0's FDE is at 32 of `.eh_frame`
(after the 32-byte CIE): its range at 44, its instructions from 53 (`advance_loc 17`, then
`def_cfa_offset` with its operand at 55). -/
def unwindNegative : Except String Unit := do
  let p := imageParts
  let c0 := (p.syms[3]!).size
  check ((p.secs[4]!).data[53]? == some 0x51 && (p.secs[4]!).data[55]? == some 32) "FDE layout"
  expectMismatch (p.poke 5 44 (c0 + 1)) "FDE range"
  expectMismatch (p.poke1 5 53 0x52) "FDE at 17"
  expectMismatch (p.poke1 5 55 40) "FDE at 17: cfa r7+40"
  -- The FDE of function 0 starting elsewhere.
  let moved := { p with rels := p.rels.map fun r => if r.sec == 5 && r.off == 40 then { r with addend := 16 } else r }
  expectMismatch moved "no FDE starts at the function"
  -- LSDAs: a wrong landing pad, a missing call site.
  expectMismatch (imageParts (lsda0 := #[{ site0 with pad := some 5 }])) "aren't the image's"
  expectMismatch (imageParts (lsda0 := #[])) "aren't the image's"
  -- The personality through a slot naming another symbol.
  expectMismatch { p with syms := p.syms.set! 6 { p.syms[6]! with name := "ext_fn" } } "personality slot"

/-! ## A registry stub -/

/-- The registry stub of tag `abiTag`. Sections: 1 the anchor, 2 the null entry
(`ryo_images_<tag>`), 3 the constructor, 4 `.init_array.00000`. Symbols: 1 the constructor's
section, 2 the anchor, 3 `ryo_vm_register_<tag>` (mangled), 4 `__start_ryo_images_<tag>`, 5
`__stop_ryo_images_<tag>`. -/
def registryParts : Parts := Id.run do
  let (code, xrs) := encodeXItems (registryCtor false)
  let secs : Array Sec := #[
    { name := ".data.ryo_registry_anchor", flags := 3, data := [0], align := 1 },
    { name := entriesSection abiTag, flags := 3 + Elf.SHF_GNU_RETAIN, data := List.replicate 8 0 },
    { name := ".text.ryo_registry", flags := 6, data := code, align := 16 },
    { name := ".init_array.00000", type := 14, flags := 3, data := List.replicate 8 0 }]
  let syms : Array Sym := #[
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 3 },
    { name := anchorName abiTag, bind := Elf.STB_WEAK, type := Elf.STT_OBJECT, vis := 2, shndx := 1, size := 1 },
    { name := mangleRt (tagged registerName abiTag), vis := 2 },
    { name := entriesStartName abiTag, vis := 2 }, { name := entriesStopName abiTag, vis := 2 }]
  let mut rels : Array Rel := #[⟨4, 0, 1, Elf.R_X86_64_64, 0⟩]
  for r in xrs do
    match r.to with
    | .entriesStart => rels := rels.push ⟨3, r.pos, 4, Elf.R_X86_64_PC32, -4⟩
    | .entriesEnd => rels := rels.push ⟨3, r.pos, 5, Elf.R_X86_64_PC32, -4⟩
    | .anchor => rels := rels.push ⟨3, r.pos, 2, Elf.R_X86_64_PC32, -4⟩
    | _ => rels := rels.push ⟨3, r.pos, 3, Elf.R_X86_64_PLT32, -4⟩
  return { secs, syms, rels }

def registryResult (p : Parts) : Except String (Array String) := do
  return checkRegistry (← readElf p.write)

def expectRegistryMismatch (p : Parts) (msg : String) : Except String Unit := do
  let out ← registryResult p
  check (out.any fun l => (l.splitOn msg).length > 1) s!"expected a registry mismatch containing `{msg}`, got {out}"

def registry : Except String Unit := do
  let p := registryParts
  let out ← registryResult p
  check out.isEmpty s!"expected no mismatches, got {out}"
  let img := imageSymbol stableId cgu
  check (checkLink #[(img, crateHash stableId, cgu)] 1).isEmpty "link"
  -- Two images with the same identity, two `__ryo_main`s.
  check (!(checkLink #[(img, crateHash stableId, cgu), ("x", crateHash stableId, cgu)] 0).isEmpty) "same identity"
  check (checkLink #[(img, crateHash stableId, cgu), (imageSymbol stableId 1, crateHash stableId, 1)] 0).isEmpty
    "two images of one crate"
  check (!(checkLink #[(img, crateHash stableId, cgu)] 2).isEmpty) "two mains"
  -- The bounds swapped; the `jmp` relocated against something else; the bound not hidden.
  let swapped := { p with rels := p.rels.map fun r =>
    if r.sym == 4 then { r with sym := 5 } else if r.sym == 5 then { r with sym := 4 } else r }
  expectRegistryMismatch swapped "registry constructor: 4 forms"
  expectRegistryMismatch { p with rels := p.rels.map fun r => if r.type == Elf.R_X86_64_PLT32 then { r with sym := 2 } else r }
    "registry constructor"
  expectRegistryMismatch { p with syms := p.syms.set! 3 { p.syms[3]! with vis := 0 } } "registry constructor"
  -- `ryo_vm_register` not hidden, of another tag; the anchor's `lea` unrelocated (the old
  -- two-argument constructor's relocations); the anchor of another tag.
  expectRegistryMismatch { p with syms := p.syms.set! 2 { p.syms[2]! with vis := 0 } } "registry constructor"
  expectRegistryMismatch { p with syms := p.syms.set! 2 { p.syms[2]! with name := mangleRt (tagged registerName "ffff") } }
    "registry constructor"
  expectRegistryMismatch { p with rels := p.rels.filter fun r => !(r.sec == 3 && r.sym == 2) } "registry constructor"
  expectRegistryMismatch { p with syms := p.syms.set! 1 { p.syms[1]! with name := anchorName "ffff" } } "0 `__ryo_registry_anchor_"
  -- No `ryo_images_<tag>` section.
  expectRegistryMismatch { p with secs := p.secs.modify 1 fun s => { s with name := "ryo_images" } } "0 `ryo_images_<tag>` sections"
  -- The image objects' tags against the stub's.
  check (checkTags abiTag #[("a.o", abiTag)]).isEmpty "same tag"
  check ((checkTags abiTag #[("a.o", abiTag), ("b.o", "ffff")]).size == 1) "another tag"
  -- The anchor not weak; the entry relocated; an image list.
  expectRegistryMismatch { p with syms := p.syms.set! 1 { p.syms[1]! with bind := Elf.STB_GLOBAL } } "weak and hidden"
  expectRegistryMismatch { p with rels := p.rels.push ⟨2, 0, 3, Elf.R_X86_64_64, 0⟩ } "is relocated"
  let list := { p with secs := p.secs.push { name := ".data.rel.ro.ryo_registry", flags := 3, data := List.replicate 8 0 },
                       rels := p.rels.push ⟨5, 0, 3, Elf.R_X86_64_64, 0⟩ }
  expectRegistryMismatch list "relocations of `.data.rel.ro.ryo_registry`"

def names : Except String Unit := do
  let entry := tagged tripEntryName "638c7434c15abaf6"
  check (isRtSymbol entry "_RNvCs5fGHjzWXRav_7___rustc35ryo_jit_trip_entry_638c7434c15abaf6") "mangled trip entry"
  check (!isRtSymbol entry "_RNvCs5fGHjzWXRav_7___rustc34ryo_jit_trip_entry_638c7434c15abaf6") "wrong length"
  check (!isRtSymbol entry "_RNvCs5fGHjzWXRav_7___rustc18ryo_jit_trip_entry") "untagged"
  check (entriesStartName "t" == "__start_ryo_images_t" && anchorName "t" == "__ryo_registry_anchor_t") "tagged names"
  -- `ryo_bytecode::ABI` of the tag `dev` (`vm/`'s own tests).
  check (abiHash "dev" == 0xca9a2a18f461fffc) "abi"
  check (isImageSymbol "__ryo_image_f993ac938d16a46b_fedcba9876543210" && !isImageSymbol "__ryo_image_f993ac938d16a46b"
    && !isImageSymbol "__ryo_image_f993ac938d16a46b_fedcba987654321") "image symbols"
  check (imageSymbol 0x0123456789abcdef 0xfedcba9876543210 == "__ryo_image_0123456789abcdef_fedcba9876543210")
    "imageSymbol"
  -- FNV-1a vectors.
  check (cguHash "" == 0xcbf29ce484222325 && cguHash "a" == 0xaf63dc4c8601ec8c) "cgu_hash"
  check (crateHash 0xf993ac938d16a46b == 0x748508f8) "crate_hash"
  check (loadKind 0x080305 == some 0x080408 && loadKind 0x030805 == none && retLoadKind RET_SRET == some 8 && retLoadKind 0 == some 0) "load kinds"

def tests : List TestCase := [
  ⟨"ImageCheck/names", fun _ => names⟩,
  ⟨"ImageCheck/image", fun _ => imagePositive⟩,
  ⟨"ImageCheck/image-mutations", fun _ => imageNegative⟩,
  ⟨"ImageCheck/unwind-mutations", fun _ => unwindNegative⟩,
  ⟨"ImageCheck/registry", fun _ => registry⟩,
]

end RyoTest.ImageCheck
