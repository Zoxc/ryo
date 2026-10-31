/-
# `.eh_frame` (aot.md §C3, "Unwind")

A reader for the call frame information image objects carry
(`vm/bytecode/src/image/unwind.rs`: `eh_cie`, `eh_fde`, `eh_fde_rows`, `unwind_elf`): CIEs and
FDEs, each FDE's call frame instructions evaluated into its row table (code offset, the CFA
rule `reg + offset`, the saved registers' rules), as `readelf --debug-dump=frames-interp`
shows it. It reads what ryo emits and rejects the rest:

- 32-bit entries only (no `0xffffffff` extended length); a zero length ends the section;
- CIE version 1, augmentation `z` followed by any of `P`, `L`, `R` (or empty);
- pointer encodings `DW_EH_PE_pcrel | DW_EH_PE_sdata4` (`0x1b`), and for the personality
  also with `DW_EH_PE_indirect` (`0x9b`); a CIE without `R` (absolute 8-byte pointers) rejects,
  and so does the Mach-O images' form (`EhPointers::Abs8`: `pcrel | absptr`, `0x10`, 8-byte
  fields), which never reaches this reader: the object readers are ELF only;
- the instructions `DW_CFA_advance_loc` (and `advance_loc1/2/4`), `def_cfa`,
  `def_cfa_offset`, `def_cfa_register`, `offset`, `restore` and `nop` (no advances or
  restores among a CIE's initial instructions).

A pointer field is resolved by a function of its position and stored value: in a relocatable
object (`readEhFrame`) a field with a relocation (`R_X86_64_PC32`, `S + A - P`) points at
`S + A`, a `Target`; one without points at its own position plus the value, in `.eh_frame`,
except that 0 is the null pointer (as `read_encoded_value` in libgcc's unwinder reads it).

Executable, not verified: checked against `readelf --debug-dump=frames` and `frames-interp`
on the corpus (`scripts/lean-decode-diff.py --unwind`).
-/
import Ryo.Obj.Image

namespace Ryo.Obj.EhFrame

/-! ## Values -/

/-- What a pointer field points at. -/
inductive Ptr where
  | null
  | to (t : Target)
  deriving Repr, DecidableEq, Inhabited

/-- A pointer field: where it is in `.eh_frame`, its encoding (`DW_EH_PE_*`) and its value. -/
structure PtrField where
  pos : Nat
  enc : Nat
  value : Ptr
  deriving Repr, DecidableEq, Inhabited

def PCREL_SDATA4 : Nat := 0x1b
def INDIRECT : Nat := 0x80

/-- The register rules of a row: the CFA is `cfaReg + cfaOff`; each register of `saved`
(sorted by number) is saved at `CFA + n` (`DW_CFA_offset`). Registers not in `saved` keep
their value (no rule). -/
structure State where
  cfaReg : Nat
  cfaOff : Nat
  saved : List (Nat × Int)
  deriving Repr, DecidableEq, Inhabited

/-- A row of the table: from code offset `loc` (relative to the FDE's first address) on,
until the next row's. -/
structure Row where
  loc : Nat
  state : State
  deriving Repr, DecidableEq, Inhabited

structure Cie where
  /-- The CIE's position in `.eh_frame`. -/
  offset : Nat
  /-- The length field (the bytes after it). -/
  length : Nat
  version : Nat
  augmentation : String
  codeAlign : Nat
  dataAlign : Int
  raReg : Nat
  personality : Option PtrField
  lsdaEnc : Option Nat
  fdeEnc : Nat
  /-- The rules its initial instructions set (the first row of every FDE). -/
  initial : State
  deriving Repr, Inhabited

structure Fde where
  offset : Nat
  length : Nat
  /-- The position of its CIE. -/
  cie : Nat
  pcBegin : PtrField
  pcRange : Nat
  /-- Present iff the CIE has `L`. -/
  lsda : Option PtrField
  /-- At least one row; the first at 0 (the CIE's initial rules); ascending. -/
  rows : Array Row
  deriving Repr, Inhabited

structure EhFrame where
  cies : Array Cie
  fdes : Array Fde
  deriving Inhabited

/-! ## Reading -/

/-- A reader of the bytes of one entry: the section's bytes and the entry's end. -/
abbrev Rd := ReaderT (ByteArray × Nat) (StateT Nat (Except String))

def Rd.fail {α} (msg : String) : Rd α := do throw s!"at {← get}: {msg}"

def u8 : Rd Nat := do
  let (b, e) ← read
  let p ← get
  if p < e then set (p + 1); pure b[p]!.toNat else Rd.fail "read past the end of the entry"

def uN (n : Nat) : Rd Nat := do
  let (b, e) ← read
  let p ← get
  if p + n ≤ e then
    set (p + n); pure ((List.range n).foldr (fun i acc => acc * 256 + b[p + i]!.toNat) 0)
  else Rd.fail "read past the end of the entry"

/-- An unsigned LEB128 (any length within the entry). -/
def uleb : Rd Nat := do
  let rec go (v shift : Nat) (fuel : Nat) : Rd Nat := do
    match fuel with
    | 0 => Rd.fail "LEB128 past the end of the entry"
    | fuel + 1 =>
      let byte ← u8
      let v := v ||| ((byte % 128) <<< shift)
      if byte < 128 then pure v else go v (shift + 7) fuel
  let (_, e) ← read
  go 0 0 (e - (← get) + 1)

/-- A signed LEB128. -/
def sleb : Rd Int := do
  let rec go (v shift : Nat) (fuel : Nat) : Rd Int := do
    match fuel with
    | 0 => Rd.fail "LEB128 past the end of the entry"
    | fuel + 1 =>
      let byte ← u8
      let v := v ||| ((byte % 128) <<< shift)
      if byte < 128 then
        let bits := shift + 7
        pure (if byte &&& 0x40 != 0 then (v : Int) - (2 ^ bits : Nat) else v)
      else go v (shift + 7) fuel
  let (_, e) ← read
  go 0 0 (e - (← get) + 1)

def cstr : Rd String := do
  let rec go (acc : List UInt8) (fuel : Nat) : Rd (List UInt8) := do
    match fuel with
    | 0 => Rd.fail "string past the end of the entry"
    | fuel + 1 =>
      let c ← u8
      if c == 0 then pure acc.reverse else go (c.toUInt8 :: acc) fuel
  let (_, e) ← read
  let bytes ← go [] (e - (← get) + 1)
  match String.fromUTF8? ⟨bytes.toArray⟩ with
  | some s => pure s
  | none => Rd.fail "augmentation string isn't UTF-8"

/-- How a pointer field is resolved: by its position and stored (signed) value. -/
abbrev Resolve := Nat → Int → Except String Ptr

/-- A pointer field of encoding `enc` (`0x1b`, or `0x9b` if `indirect` is allowed). -/
def ptr (resolve : Resolve) (enc : Nat) (indirect : Bool) : Rd PtrField := do
  unless enc == PCREL_SDATA4 || (indirect && enc == INDIRECT ||| PCREL_SDATA4) do
    Rd.fail s!"pointer encoding {enc} (only 0x1b{if indirect then " and 0x9b" else ""} are read)"
  let pos ← get
  let raw := toSigned 32 (← uN 4)
  match resolve pos raw with
  | .ok v => pure { pos, enc, value := v }
  | .error e => Rd.fail e

/-! ## Call frame instructions -/

/-- `saved` with register `r`'s rule set to `n` (or removed: `none`), kept sorted. -/
def setRule (saved : List (Nat × Int)) (r : Nat) (n : Option Int) : List (Nat × Int) :=
  let rest := saved.filter (·.1 != r)
  match n with
  | none => rest
  | some n => (rest ++ [(r, n)]).mergeSort (fun a b => a.1 ≤ b.1)

/-- Runs the call frame instructions in `[pos, end)` from the rules `init`. For an FDE
(`cie = some initial`), every advance starts a row (one of length 0 starts none) and
`restore` returns a register to its rule in `initial`; for a CIE, neither is allowed. Returns
the rows (the first at 0) and the final rules. -/
def exec (codeAlign : Nat) (dataAlign : Int) (cie : Option State) (init : State) :
    Rd (Array Row × State) := do
  let rec go (loc : Nat) (s : State) (rows : Array Row) (fuel : Nat) : Rd (Array Row × State) := do
    match fuel with
    | 0 => Rd.fail "out of fuel"
    | fuel + 1 =>
      let (_, e) ← read
      if (← get) ≥ e then return (rows.push ⟨loc, s⟩, s)
      let op ← u8
      let advance (d : Nat) : Rd (Array Row × State) := do
        if cie.isNone then Rd.fail "advance among a CIE's initial instructions"
        let d := d * codeAlign
        if d == 0 then go loc s rows fuel
        else go (loc + d) s (rows.push ⟨loc, s⟩) fuel
      match op / 64 with
      | 1 => advance (op % 64)
      | 2 =>
        let n ← uleb
        go loc { s with saved := setRule s.saved (op % 64) (some (n * dataAlign)) } rows fuel
      | 3 =>
        let some initial := cie | Rd.fail "DW_CFA_restore among a CIE's initial instructions"
        let r := op % 64
        go loc { s with saved := setRule s.saved r (initial.saved.lookup r) } rows fuel
      | _ =>
        match op with
        | 0x00 => go loc s rows fuel
        | 0x02 => advance (← u8)
        | 0x03 => advance (← uN 2)
        | 0x04 => advance (← uN 4)
        | 0x0c =>
          let r ← uleb
          let o ← uleb
          go loc { s with cfaReg := r, cfaOff := o } rows fuel
        | 0x0d => go loc { s with cfaReg := ← uleb } rows fuel
        | 0x0e => go loc { s with cfaOff := ← uleb } rows fuel
        | _ => Rd.fail s!"call frame instruction {op} (not one ryo emits)"
  let (_, e) ← read
  go 0 init #[] (e - (← get) + 1)

/-! ## Entries -/

/-- The CIE at `off`, its contents `[off + 8, e)`. -/
def readCie (resolve : Resolve) (off length : Nat) : Rd Cie := do
  let version ← u8
  unless version == 1 do Rd.fail s!"CIE version {version} (only 1 is read)"
  let aug ← cstr
  let chars := aug.toList
  unless chars.isEmpty || (chars.head? == some 'z' && chars.tail.all (fun c => c == 'P' || c == 'L' || c == 'R')) do
    Rd.fail s!"augmentation \"{aug}\" (only z followed by P, L, R is read)"
  let codeAlign ← uleb
  let dataAlign ← sleb
  let raReg ← u8
  let mut personality := none
  let mut lsdaEnc := none
  let mut fdeEnc? := none
  if !chars.isEmpty then
    let len ← uleb
    let start ← get
    for c in chars.tail do
      match c with
      | 'P' => personality := some (← ptr resolve (← u8) true)
      | 'L' => lsdaEnc := some (← u8)
      | _ => fdeEnc? := some (← u8)
    if (← get) != start + len then Rd.fail s!"augmentation data of {(← get) - start} bytes, not {len}"
  let some fdeEnc := fdeEnc? | Rd.fail "CIE without R (absolute pointers aren't read)"
  unless fdeEnc == PCREL_SDATA4 do Rd.fail s!"FDE pointer encoding {fdeEnc} (only 0x1b is read)"
  if let some l := lsdaEnc then
    unless l == PCREL_SDATA4 do Rd.fail s!"LSDA pointer encoding {l} (only 0x1b is read)"
  let (_, initial) ← exec codeAlign dataAlign none ⟨0, 0, []⟩
  pure { offset := off, length, version, augmentation := aug, codeAlign, dataAlign, raReg,
         personality, lsdaEnc, fdeEnc, initial }

/-- The FDE at `off` of CIE `cie`, from after its CIE pointer. -/
def readFde (resolve : Resolve) (off length : Nat) (cie : Cie) : Rd Fde := do
  let pcBegin ← ptr resolve cie.fdeEnc false
  let range := toSigned 32 (← uN 4)
  if range < 0 then Rd.fail s!"negative FDE range {range}"
  let mut lsda := none
  if cie.augmentation.startsWith "z" then
    let len ← uleb
    let start ← get
    if let some enc := cie.lsdaEnc then lsda := some (← ptr resolve enc false)
    if (← get) != start + len then Rd.fail s!"augmentation data of {(← get) - start} bytes, not {len}"
  let (rows, _) ← exec cie.codeAlign cie.dataAlign (some cie.initial) cie.initial
  for r in rows do
    if r.loc > 0 && r.loc ≥ range.toNat then Rd.fail s!"a row at {r.loc}, past the FDE's range {range}"
  pure { offset := off, length, cie := cie.offset, pcBegin, pcRange := range.toNat, lsda, rows }

/-- Reads the section's entries, CIEs and FDEs (an FDE's CIE must come before it). -/
def parse (b : ByteArray) (resolve : Resolve) : Except String EhFrame := do
  let rec go (off : Nat) (eh : EhFrame) (fuel : Nat) : Except String EhFrame := do
    match fuel with
    | 0 => throw "out of fuel"
    | fuel + 1 =>
      if off == b.size then return eh
      let length ← readU32 b off
      if length == 0 then return eh
      if length == 0xffffffff then throw s!"entry at {off}: 64-bit entries aren't read"
      let e := off + 4 + length
      if e > b.size then throw s!"entry at {off}: past the end of the section"
      let id ← readU32 b (off + 4)
      let run {α} (r : Rd α) : Except String α := (r.run (b, e)).run' (off + 8)
      if id == 0 then
        let c ← run (readCie resolve off length)
        go e { eh with cies := eh.cies.push c } fuel
      else
        if id > off + 4 then throw s!"FDE at {off}: its CIE pointer {id} points before the section"
        let at_ := off + 4 - id
        let some cie := eh.cies.find? (·.offset == at_) | throw s!"FDE at {off}: no CIE at {at_}"
        let f ← run (readFde resolve off length cie)
        go e { eh with fdes := eh.fdes.push f } fuel
  go 0 ⟨#[], #[]⟩ (b.size / 8 + 1)

/-! ## In a relocatable object -/

/-- The resolution of `.eh_frame`'s pointer fields in an object: by their `R_X86_64_PC32`
relocation (sorted `relocs`), else relative to the field, in section `self`. -/
def objResolve (e : Elf) (self : Nat) (relocs : Array Rela) : Resolve := fun pos raw =>
  match findRela relocs pos with
  | some r =>
    if r.type != .pc32 then .error s!"pointer field at {pos}: {r.type.name} relocation"
    else (Ptr.to ·) <$> e.target r
  | none => if raw == 0 then .ok .null else .ok (.to (.sect self ((pos : Int) + raw)))

/-- The object's `.eh_frame` section and its entries. -/
def readEhFrame (e : Elf) : Except String (Section × EhFrame) := do
  let some s := e.sectionByName? ".eh_frame" | throw "no .eh_frame section"
  let relocs := (e.relocsOf s.index).qsort (fun a b => a.offset < b.offset)
  let eh ← parse (e.data s) (objResolve e s.index relocs)
  pure (s, eh)

/-! ## Text form (`ryo-lean ehframe`) -/

def State.render (s : State) : String :=
  let regs := s.saved.map fun (r, n) => s!" r{r}=c{if n ≥ 0 then "+" else ""}{n}"
  s!"cfa r{s.cfaReg}+{s.cfaOff}" ++ String.join regs

/-- `<section or symbol> <offset>` (`none` for the null pointer), `@<field position>`. -/
def PtrField.render (e : Elf) (p : PtrField) : String :=
  let t := match p.value with
    | .null => "none"
    | .to (.sect i off) =>
      let name := match e.section? i with | some s => s.name | none => s!"section{i}"
      s!"{name} {off}"
    | .to (.named n a) => s!"{n} {a}"
  s!"{t} @{p.pos}"

/-- What `ryo-lean ehframe` prints:

```
cie <off> len <length> version <v> aug <augmentation> cf <code align> df <data align> ra <reg> [personality <enc> <ptr> [slot <symbol>]] [lsda_enc <enc>] fde_enc <enc>
  row 0 cfa r<reg>+<off> r<reg>=c<offset>...
fde <off> len <length> cie <cie off> pc <ptr> range <n> [lsda <ptr>]
  row <loc> ...
```

with `<ptr>` as `PtrField.render` prints it, rows' `loc` relative to the FDE's first address,
saved registers by number. An indirect personality pointing at a slot with an `R_X86_64_64`
relocation names the slot's symbol (`slot`). -/
def dump (e : Elf) (eh : EhFrame) : Array String :=
  let slotName (p : PtrField) : String :=
    match p.value with
    | .to (.sect s off) =>
      if p.enc &&& INDIRECT != 0 && off ≥ 0 then
        match findRela ((e.relocsOf s).qsort (fun a b => a.offset < b.offset)) off.toNat with
        | some r =>
          if r.type == .abs64 && r.addend == 0 then
            match e.symbol? r.sym with
            | some sym => s!" slot {e.symbolName sym}"
            | none => ""
          else ""
        | none => ""
      else ""
    | _ => ""
  let cie (c : Cie) : Nat × Array String :=
    let pers := match c.personality with
      | none => ""
      | some p => s!" personality {p.enc} {p.render e}{slotName p}"
    let lsda := match c.lsdaEnc with | some l => s!" lsda_enc {l}" | none => ""
    (c.offset, #[s!"cie {c.offset} len {c.length} version {c.version} aug {c.augmentation} cf {c.codeAlign} df {c.dataAlign} ra {c.raReg}{pers}{lsda} fde_enc {c.fdeEnc}",
      s!"  row 0 {c.initial.render}"])
  let fde (f : Fde) : Nat × Array String :=
    let lsda := match f.lsda with | some p => s!" lsda {p.render e}" | none => ""
    (f.offset, #[s!"fde {f.offset} len {f.length} cie {f.cie} pc {f.pcBegin.render e} range {f.pcRange}{lsda}"]
      ++ f.rows.map fun r => s!"  row {r.loc} {r.state.render}")
  -- In section order.
  let entries := (eh.cies.map cie ++ eh.fdes.map fde).qsort (fun a b => a.1 < b.1)
  entries.flatMap (·.2)

end Ryo.Obj.EhFrame
