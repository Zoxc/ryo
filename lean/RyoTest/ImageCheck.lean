/-
Tests of the image checks (`Ryo/Check/Image`, aot.md §C4) on image and registry objects built
here from bytes: a small ELF writer, an image of two VM functions in the counters mode (an
entry counter check and its stub, a handler call taking a symbol slot's address, a call of the
other function, which carries no relocation and is a call site), with its JIT records, anchor
and `__ryo_main` slots, `.eh_frame` and LSDAs, and a registry object listing it. The objects
pass every check; mutations of them (a function's length, a relocation dropped or added, a JIT
record's counter, a registry entry listed twice, an FDE's range, row or CFA offset, an LSDA's
call sites) are rejected. The checks run on real objects in `scripts/lean-image-check.py`.
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

/-- Function 0: the entry's counter check, the prologue, `addr.sym` of slot 0 into
`[fp - 16]` (the frame is addressed from `rsp`: `fp` is `rsp + 16`), a call of function 1,
`ret`, the entry's stub. -/
def f0Items (back stub : Nat) : List Item :=
  [.ctrSub 16, .branch .s (bv32 stub) true] ++ Ryo.Vm.Asm.prologue frameSize mode ++
  [.leaM .rdi ⟨.rsp, bv32 frameSize⟩, .setReg .rsi (BitVec.ofNat 64 0xfffffff0), .lea .rdx (.sym 0),
   .call (.handler addrSym), .call (.func 1)] ++
  [Ryo.Vm.Asm.epilogue frameSize mode, .ret] ++ entryStub (bv32 back) true

/-- Function 1: the counter check, a frame of 0, `ret`, the stub. -/
def f1Items (back stub : Nat) : List Item :=
  [.ctrSub 16, .branch .s (bv32 stub) true] ++ Ryo.Vm.Asm.prologue 0 mode ++
  [Ryo.Vm.Asm.epilogue 0 mode, .ret] ++ entryStub (bv32 back) true

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

-- Read-only layout: header, 2 functions, code constants (none, at 240), fixups (none), 1 symbol
-- flag at 240, the slot at 248, no instruction lists, the call-site table at 256 (one entry).
def roSize : Nat := 268
def slotOff : Nat := 248
def recOff : Nat := 64
def dataSize : Nat := 64 + 2 * 64

/-- `DW_CFA_advance_loc*` by `d`. -/
def advance (d : Nat) : List UInt8 :=
  if d < 64 then [(0x40 + d).toUInt8] else if d < 256 then [0x02, d.toUInt8] else 0x03 :: le 2 d

def padTo8 (body : List UInt8) : List UInt8 := body ++ List.replicate ((8 - (body.length + 4) % 8) % 8) 0

/-- `.eh_frame` as `unwind_elf` writes it for this mode (no frame pointer, counters): the CIE,
then per function (`code_off`, `code_len`, frame size `F`, LSDA offset) an FDE whose rows
change after the counter check and `sub rsp` (14 + 4 bytes in) to CFA `rsp + F + 16`, and at
the entry stub (the last 16 bytes) back to `rsp + 8`; with its relocations (section 6, against symbols 3 the text, 1 the read-only
section, 13 the LSDAs). -/
def ehFrame (funcs : List (Nat × Nat × Nat × Nat)) : List UInt8 × Array Rel := Id.run do
  let cie := padTo8 ([0, 0, 0, 0, 1] ++ "zPLR".toUTF8.toList ++ [0, 1, 0x78, 16, 7, 0x9b, 0, 0, 0, 0, 0x1b, 0x1b,
    0x0c, 7, 8, 0x90, 1])
  let mut eh := le 4 cie.length ++ cie
  let mut rels : Array Rel := #[⟨6, 4 + 15, 1, Elf.R_X86_64_PC32, slotOff⟩]
  for (off, len, f, l) in funcs do
    let at_ := eh.length
    let stub := len - 16  -- `lea r11, [rip + rec]; call [r11 + 8]; jmp rel32`
    let fde := padTo8 (le 4 (at_ + 4) ++ le 4 0 ++ le 4 len ++ [4] ++ le 4 0 ++ advance 18 ++ [0x0e, (f + 16).toUInt8]
      ++ advance (stub - 18) ++ [0x0c, 7, 8])
    rels := rels.push ⟨6, at_ + 8, 3, Elf.R_X86_64_PC32, off⟩
    rels := rels.push ⟨6, at_ + 17, 13, Elf.R_X86_64_PC32, l⟩
    eh := eh ++ le 4 fde.length ++ fde
  return (eh, rels)

/-- The image object's parts. Sections: 1 read-only, 2 writable, 3 text, 4 anchor slot,
5 `__ryo_main`. Symbols: 1–3 the first three's section symbols, 4–5 the functions, 6 the
image, 7 the slot's `rust_eh_personality`, 8 `ryo_h_AddrSym`, 9–10 the trip entry points,
11 the anchor, 12 `__ryo_main`, 13 the LSDA section's. Sections 6 and 7 are `.eh_frame` and
the LSDAs, function 0's of the call sites `lsda0`. With `resolve`, the call of function 1 holds its displacement, as the writer
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
  let entry (off len : Nat) (sites : Span) : List UInt8 :=
    le 4 off ++ le 4 len ++ List.replicate 12 0 ++ le 8 0 ++ span sites
  let header := "RYOIMAGE".toUTF8.toList ++ le 4 (crateHash stableId) ++ le 4 roSize ++ le 8 stableId
    ++ le 8 0 ++ le 4 dataSize ++ le 4 text.length ++ le 8 0 ++ span ⟨136, 2⟩
    ++ span ⟨240, 0⟩ ++ span ⟨240, 0⟩ ++ span ⟨240, 1⟩ ++ span ⟨slotOff, 1⟩ ++ span ⟨256, 0⟩
    ++ span ⟨256, 0⟩ ++ span ⟨256, 1⟩ ++ le 4 0 ++ le 4 0 ++ le 4 21 ++ span ⟨recOff, 2⟩ ++ le 4 0
  let ro := header ++ entry 0 c0.length ⟨0, 1⟩ ++ entry f1Off c1.length ⟨1, 0⟩ ++ List.replicate 32 0 ++ [0]
    ++ List.replicate 7 0 ++ le 8 0 ++ le 4 site0.start ++ le 4 site0.len ++ le 4 CONTINUE
  let lsda0 := (Lsda.write lsda0).toList
  let lsda1 := (Lsda.write #[]).toList
  let (eh, ehRels) := ehFrame [(0, c0.length, frameSize, 0), (f1Off, c1.length, 0, lsda0.length)]
  let record (i : Nat) : List UInt8 := le 8 jitThreshold ++ List.replicate 28 0 ++ le 4 i ++ List.replicate 24 0
  let data := List.replicate recOff 0 ++ record 0 ++ record 1
  let secs : Array Sec := #[
    { name := ".data.rel.ro.ryo_image", flags := 3, data := ro, align := 16 },
    { name := ".data.ryo_image", flags := 3, data := data, align := 64 },
    { name := ".text.ryo_image", flags := 6, data := text, align := 16 },
    { name := ".data.rel.ro.ryo_anchor", flags := 3, data := List.replicate 8 0 },
    { name := ".data.rel.ro.ryo_main", flags := 3, data := List.replicate 8 0 },
    { name := ".eh_frame", type := 0x70000001, flags := 2, data := eh },
    { name := ".gcc_except_table.ryo_image", flags := 2, data := lsda0 ++ lsda1, align := 4 }]
  let syms : Array Sym := #[
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 1 },
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 2 },
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 3 },
    { name := "f0", bind := 0, type := Elf.STT_FUNC, shndx := 3, size := c0.length },
    { name := "f1", type := Elf.STT_FUNC, vis := 2, shndx := 3, value := f1Off, size := c1.length },
    { name := imageSymbolPrefix ++ hex16 stableId, type := Elf.STT_OBJECT, vis := 2, shndx := 1, size := roSize },
    { name := "rust_eh_personality" }, { name := "ryo_h_AddrSym" }, { name := tripEntryName }, { name := tripOsrName },
    { name := anchorName },
    { name := mainSlotName, type := Elf.STT_OBJECT, vis := 2, shndx := 5, size := 8 },
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 7 }]
  let abs := Elf.R_X86_64_64
  let mut rels : Array Rel := ehRels ++ #[⟨1, 24, 2, abs, 0⟩, ⟨1, 40, 3, abs, 0⟩, ⟨1, slotOff, 7, abs, 0⟩,
    ⟨4, 0, 11, abs, 0⟩, ⟨5, 0, 5, abs, 0⟩]
  for i in [0:2] do
    let r := recOff + 64 * i
    rels := rels ++ #[⟨2, r + 8, 9, abs, 0⟩, ⟨2, r + 16, 10, abs, 0⟩, ⟨2, r + 40, 1, abs, 0⟩]
  for (base, rs, func) in [(0, r0, 0), (f1Off, r1, 1)] do
    let rec_ : Int := recOff + 64 * func
    for r in rs do
      match (r.to : Ryo.X86.Ref) with
      | .handler _ => rels := rels.push ⟨3, base + r.pos, 8, Elf.R_X86_64_PLT32, -4⟩
      | .sym s => rels := rels.push ⟨3, base + r.pos, 1, Elf.R_X86_64_PC32, (slotOff + 8 * s : Nat) - 4⟩
      | .recordCtr => rels := rels.push ⟨3, base + r.pos, 2, Elf.R_X86_64_PC32, rec_ - 5⟩
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
  expectMismatch (p.poke 1 (136 + 4) (c0 + 1)) "st_size"
  expectMismatch (p.poke 1 (136 + 4) (c0 - 1)) "decode"
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
  expectMismatch (p.poke 2 recOff 5) "ctr 5"
  expectMismatch { p with rels := p.rels.filter (fun r => !(r.sec == 2 && r.off == recOff + 8)) } "JIT record 0"
  -- The symbol slot's relocation, twice; its flag set.
  expectMismatch { p with rels := p.rels.push ⟨1, slotOff, 7, Elf.R_X86_64_64, 0⟩ } "symbol slot 0: 2 relocations"
  expectMismatch (p.poke 1 240 1) "SYM_INDIRECT"
  -- No anchor.
  expectMismatch { p with rels := p.rels.filter (·.sec != 4) } "anchor"
  -- A wrong image symbol for the stable crate id.
  let syms := p.syms.set! 5 { p.syms[5]! with name := imageSymbolPrefix ++ hex16 (stableId + 1) }
  expectMismatch { p with syms } "stable_crate_id"
  -- A function symbol of the wrong size, a missing one.
  expectMismatch { p with syms := p.syms.set! 4 { p.syms[4]! with size := 3 } } "st_size 3"
  expectMismatch { p with syms := p.syms.set! 4 { p.syms[4]! with type := Elf.STT_OBJECT } } "no function symbol"
  -- `ret_kind` 8 on function 1: its `ret` loads nothing, and function 0's call collects nothing.
  let k1 := 136 + 36 + 16
  expectMismatch (p.poke 1 k1 8) "ret of kind"
  expectMismatch (p.poke 1 k1 8) "collects kind"

/-- Sets byte `off` of section `i`'s (from 1) data. -/
def Parts.poke1 (p : Parts) (i off v : Nat) : Parts :=
  let s := p.secs[i - 1]!
  { p with secs := p.secs.set! (i - 1) { s with data := s.data.set off v.toUInt8 } }

/-- Mutations of the unwind tables. Function 0's FDE is at 32 of `.eh_frame` (after the
32-byte CIE): its range at 44, its instructions from 53 (`advance_loc 18`, then
`def_cfa_offset` with its operand at 55). -/
def unwindNegative : Except String Unit := do
  let p := imageParts
  let c0 := (p.syms[3]!).size
  check ((p.secs[5]!).data[53]? == some 0x52 && (p.secs[5]!).data[55]? == some 32) "FDE layout"
  expectMismatch (p.poke 6 44 (c0 + 1)) "FDE range"
  expectMismatch (p.poke1 6 53 0x53) "FDE at 18"
  expectMismatch (p.poke1 6 55 40) "FDE at 18: cfa r7+40"
  -- The FDE of function 0 starting elsewhere.
  let moved := { p with rels := p.rels.map fun r => if r.sec == 6 && r.off == 40 then { r with addend := 16 } else r }
  expectMismatch moved "no FDE starts at the function"
  -- LSDAs: a wrong landing pad, a missing call site.
  expectMismatch (imageParts (lsda0 := #[{ site0 with pad := some 5 }])) "aren't the image's"
  expectMismatch (imageParts (lsda0 := #[])) "aren't the image's"
  -- The personality through a slot naming another symbol.
  expectMismatch { p with syms := p.syms.set! 6 { p.syms[6]! with name := "ext_fn" } } "personality slot"

/-! ## A registry object -/

/-- A registry object listing `images`. Sections: 1 the anchor, 2 the list, 3 the
constructor, 4 `.init_array.00000`. Symbols: 1 the list's, 2 the constructor's section, 3 the
anchor, 4 `ryo_vm_register`, then the images. -/
def registryParts (images : List String) (n : Option Nat := none) : Parts := Id.run do
  let (code, xrs) := encodeXItems (registryCtor (bv32 (n.getD images.length)) false false)
  let secs : Array Sec := #[
    { name := ".data.ryo_registry_anchor", flags := 3, data := [0], align := 1 },
    { name := ".data.rel.ro.ryo_registry", flags := 3, data := List.replicate (8 * images.length) 0 },
    { name := ".text.ryo_registry", flags := 6, data := code, align := 16 },
    { name := ".init_array.00000", type := 14, flags := 3, data := List.replicate 8 0 }]
  let syms : Array Sym := #[
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 2 },
    { name := "", bind := 0, type := Elf.STT_SECTION, shndx := 3 },
    { name := anchorName, type := Elf.STT_OBJECT, vis := 2, shndx := 1, size := 1 },
    { name := registerName }] ++ (images.toArray.map fun n => { name := n })
  let mut rels : Array Rel := #[⟨4, 0, 2, Elf.R_X86_64_64, 0⟩]
  for (_, k) in images.zipIdx do
    rels := rels.push ⟨2, 8 * k, 5 + k, Elf.R_X86_64_64, 0⟩
  for r in xrs do
    match r.to with
    | .images => rels := rels.push ⟨3, r.pos, 1, Elf.R_X86_64_PC32, -4⟩
    | _ => rels := rels.push ⟨3, r.pos, 4, Elf.R_X86_64_PLT32, -4⟩
  return { secs, syms, rels }

def registryResult (p : Parts) : Except String (Array String × Array String) := do
  return checkRegistry (← readElf p.write)

def registry : Except String Unit := do
  let img := imageSymbolPrefix ++ hex16 stableId
  let other := imageSymbolPrefix ++ hex16 1
  let (out, names) ← registryResult (registryParts [img, other])
  check out.isEmpty s!"expected no mismatches, got {out}"
  check (names == #[img, other]) "listed names"
  check (checkLink #[img] (some names) 1).isEmpty "link"
  -- An entry twice.
  let (out, names) ← registryResult (registryParts [img, img])
  check (out.any fun l => (l.splitOn "listed twice").length > 1) s!"duplicate entry: {out}"
  check (!(checkLink #[img] (some names) 1).isEmpty) "duplicate entry in the link"
  -- An image of the link missing, two `__ryo_main`s.
  check (!(checkLink #[img, imageSymbolPrefix ++ hex16 2] (some #[img]) 0).isEmpty) "missing image"
  check (!(checkLink #[img] (some #[img]) 2).isEmpty) "two mains"
  -- `n` off by one; the constructor's `jmp` relocated against something else.
  let (out, _) ← registryResult (registryParts [img] (some 2))
  check (out.any fun l => (l.splitOn "n = 2").length > 1) s!"wrong count: {out}"
  let p := registryParts [img]
  let p := { p with rels := p.rels.map fun r => if r.type == Elf.R_X86_64_PLT32 then { r with sym := 3 } else r }
  let (out, _) ← registryResult p
  check (out.any fun l => (l.splitOn "registry constructor").length > 1) s!"wrong jmp target: {out}"
  -- Not an image symbol.
  let (out, _) ← registryResult (registryParts ["foo"])
  check (out.any fun l => (l.splitOn "image symbol").length > 1) s!"not an image symbol: {out}"

def names : Except String Unit := do
  check (isRtSymbol tripEntryName "_RNvCs5fGHjzWXRav_7___rustc18ryo_jit_trip_entry") "mangled trip entry"
  check (!isRtSymbol tripEntryName "_RNvCs5fGHjzWXRav_7___rustc17ryo_jit_trip_entry") "wrong length"
  check (isImageSymbol "__ryo_image_f993ac938d16a46b" && !isImageSymbol "__ryo_image_f993ac938d16a46") "image symbols"
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
