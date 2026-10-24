/-
Ryo.Check.Image.Unwind — the unwind tables of an image object (aot.md §C4, rows ".eh_frame
FDEs" and ".gcc_except_table LSDAs"), against the decoded code. ELF only.

**The CIE.** One, as `image::eh_cie` writes it: augmentation `zPLR`, code alignment 1, data
alignment −8, return address r16, initial rules CFA = `rsp + 8` with the return address at
CFA − 8, the personality `DW_EH_PE_indirect | pcrel | sdata4` through the image's symbol slot
naming `rust_eh_personality`, LSDA and FDE pointers `pcrel | sdata4`.

**FDEs.** One per VM function, and no other: starting at its `code_off`, of range `code_len`,
of the CIE. Its row table must give, at every byte offset of the function, the rules the
decoded code establishes there, which this check derives from the code itself, not from the
writer's `eh_fde`: the items of the counter check and the prologue are read again from the
bytes (`Ryo.X86.decodeItem`; the decoder has checked they are the prologue of the decoded
frame size), and each item's effect on the frame is applied to the entry state (CFA `rsp + 8`,
return address at CFA − 8): `push rbp` moves an `rsp`-based CFA by 8 and saves `rbp` at the
new `rsp`, `mov rbp, rsp` makes `rbp` the CFA's register, `sub rsp, n` moves an `rsp`-based CFA
by `n`; the stack probe's call and `mov eax, n` change nothing. The state after the prologue
holds for the rest of the code (the body, its loop heads' counter stubs, jump tables) except:

- the entry's counter stub (the target of the entry check's `js`), which runs before the
  prologue, with the state at the `js`;
- epilogues: the decoder accepts them only as the epilogue item directly followed by `ret`, so
  no call (no unwind point) lies between the frame's release and the return, and the FDE gives
  them no rules of their own (by design: only asynchronous unwinding could stop there). The
  derived state keeps the body's there, which is the FDE's.

Comparing the two piecewise-constant functions at every row boundary of either covers every
unwind point: each call, handler call and island, and each landing pad (a decoded `lpad`, in
the body; every call site is checked to lie in the body too).

**LSDAs.** The FDE's LSDA pointer points into a `.gcc_except_table` section; the functions'
LSDAs follow each other in function order from the section's start to its end; each parses
(`Lsda.parse`) and equals the function's run of the image's call-site table (`CONTINUE`, the
`CATCH` bit). The decoder took that run as the function's call sites: it checked that each
starts at a call-like instruction's call with its exact length and that one instruction's
sites agree, that every one is used (`call site outside every call`), and that each landing
pad is an `lpad` instruction, giving `Decoded.cleanup`. So the LSDA covers exactly the
call-like instructions the decoder saw with their unwind actions.
-/
import Ryo.Check.Image.Common

namespace Ryo.Check.Image

open Ryo.Obj Ryo.Obj.EhFrame Ryo.X86 Ryo.Vm

/-- DWARF register numbers. -/
def dwRbp : Nat := 6
def dwRsp : Nat := 7
def dwRa : Nat := 16

/-- The rules at a function's entry (the CIE's). -/
def entryState : State := ⟨dwRsp, 8, [(dwRa, -8)]⟩

/-- An item's effect on the frame rules, for the items of a counter check and a prologue;
`none` for any other. -/
def itemEffect (s : State) : Item → Option State
  | .pushRbp =>
    if s.cfaReg == dwRsp then
      let off := s.cfaOff + 8
      some { s with cfaOff := off, saved := setRule s.saved dwRbp (some (-(off : Int))) }
    else none
  | .mov .rbp .rsp => if s.cfaReg == dwRsp then some { s with cfaReg := dwRbp } else none
  | .subRsp n => if s.cfaReg == dwRsp then some { s with cfaOff := s.cfaOff + n.toNat } else some s
  | .setReg .rax _ | .call .probe | .ctrSub _ | .branch .s _ _ => some s
  | _ => none

/-- The rules the code establishes, as rows (byte offset, state), and the body's extent
`[prologue end, entry stub)`; derived from function `i`'s bytes (see the module doc). -/
def derivedRows (fi : FuncInputs) (d : R.Decoded) : Except String (Array Row × Nat × Nat) := do
  let mode := fi.mode
  if mode.pe then throw "PE unwind information isn't checked"
  let rs := fi.relocs.map fun r => (⟨r.pos, DecodeObj.toRef r.to⟩ : Ryo.X86.Reloc)
  let code := fi.code.data
  let item (pos : Nat) : Except String (Item × Nat) :=
    match decodeItem { code, pos, fields := .relocs rs } with
    | some x => pure x
    | none => throw s!"no item at {pos}"
  let mut pos := 0
  let mut s := entryState
  let mut rows : Array Row := #[⟨0, entryState⟩]
  let mut stub := code.size
  let mut stubState := entryState
  if mode.counters then
    let (i1, n1) ← item 0
    let (i2, n2) ← item n1
    match i1, i2 with
    | .ctrSub _, .branch .s t _ => stub := t.toNat; stubState := s; pos := n1 + n2
    | _, _ => throw "no counter check at the entry"
  for want in Asm.prologue d.frameSize mode do
    let (it, n) ← item pos
    if it != want then throw s!"prologue item at {pos}"
    let some s' := itemEffect s it | throw s!"prologue item at {pos} has no known frame effect"
    pos := pos + n
    if s' != s then rows := rows.push ⟨pos, s'⟩
    s := s'
  let body := pos
  if stub < code.size then
    if stub < body then throw s!"the entry's counter stub at {stub} is inside the prologue"
    rows := rows.push ⟨stub, stubState⟩
  return (rows, body, stub)

/-- The state of `rows` (ascending) at byte offset `q`. -/
def stateAt (rows : Array Row) (q : Nat) : Option State :=
  rows.foldl (fun acc r => if r.loc ≤ q then some r.state else acc) none

def checkCie (o : ImageObject) (eh : EhFrame) : Array String := Id.run do
  let mut out : Array String := #[]
  let [c] := eh.cies.toList | return #[s!".eh_frame: {eh.cies.size} CIEs"]
  if c.augmentation != "zPLR" || c.codeAlign != 1 || c.dataAlign != -8 || c.raReg != dwRa then
    out := out.push s!".eh_frame CIE: augmentation {c.augmentation}, alignments {c.codeAlign}/{c.dataAlign}, ra r{c.raReg}"
  if c.initial != entryState then out := out.push s!".eh_frame CIE: initial rules {c.initial.render}"
  if c.lsdaEnc != some PCREL_SDATA4 || c.fdeEnc != PCREL_SDATA4 then
    out := out.push ".eh_frame CIE: LSDA or FDE pointer encoding"
  let h := o.image.header
  match c.personality with
  | some { enc, value := .to (.sect s off), .. } =>
    let base : Int := (o.roBase + h.symbols.off : Nat)
    let k := (off - base) / 8
    let slotOk := s == o.ro.index && off ≥ base && (off - base) % 8 == 0 && k < h.symbols.count
    if enc != INDIRECT ||| PCREL_SDATA4 then out := out.push s!".eh_frame CIE: personality encoding {enc}"
    if !slotOk then out := out.push ".eh_frame CIE: the personality pointer isn't a symbol slot"
    else if (o.slotName k.toNat).toOption != some "rust_eh_personality" then
      out := out.push s!".eh_frame CIE: the personality slot {k} names {(o.slotName k.toNat).toOption}"
  | _ => out := out.push ".eh_frame CIE: no personality pointer into the image"
  return out

def unwindChecks (o : ImageObject) (ds : Array FuncDecoding) : Array String := Id.run do
  if o.image.mode.pe then return #[]
  let (_, eh) ← match readEhFrame o.elf with
    | .ok x => pure x
    | .error e => return #[s!".eh_frame: {e}"]
  let mut out := checkCie o eh
  if eh.fdes.size != o.funcs.size then
    out := out.push s!".eh_frame: {eh.fdes.size} FDEs for {o.funcs.size} functions"
  let mut lsdaEnd : Option (Nat × Nat) := none  -- (section, end of the previous LSDA)
  for h : i in [0:o.funcs.size] do
    let f := o.funcs[i]
    let l := funcLabel o i
    let u ← match o.funcUnwind eh i with
      | .ok u => pure u
      | .error e => out := out.push s!"{l}: unwind tables: {e}"; continue
    if u.fde.pcRange != f.codeLen then
      out := out.push s!"{l}: FDE range {u.fde.pcRange}, code_len {f.codeLen}"
    if eh.cies.size == 1 && u.fde.cie != eh.cies[0]!.offset then out := out.push s!"{l}: FDE of another CIE"
    -- The LSDA.
    if !u.lsdaSection.name.startsWith ".gcc_except_table" then
      out := out.push s!"{l}: the LSDA pointer is into `{u.lsdaSection.name}`"
    let prev := match lsdaEnd with
      | some (s, e) => if s == u.lsdaSection.index then e else 0
      | none => 0
    if u.lsdaOff != prev then out := out.push s!"{l}: LSDA at {u.lsdaOff}, the previous one ends at {prev}"
    lsdaEnd := some (u.lsdaSection.index, u.lsdaOff + u.lsda.size)
    match u.sites with
    | none => out := out.push s!"{l}: the LSDA doesn't parse"
    | some sites =>
      if sites != o.imageSites f then
        out := out.push s!"{l}: the LSDA's {sites.size} call sites aren't the image's {(o.imageSites f).size}"
    -- The rows.
    let some di := ds[i]? | continue
    let (.ok fi, .ok d) := (di.inputs, di.decoded) | continue
    match derivedRows fi d with
    | .error e => out := out.push s!"{l}: frame rules of the code: {e}"
    | .ok (want, body, stub) =>
      let have_ := u.fde.rows
      let points := (want.map (·.loc) ++ have_.map (·.loc)).filter (· < f.codeLen) |>.qsort (· < ·)
      let mut seen : Option Nat := none
      for q in points do
        if seen == some q then continue
        seen := some q
        let a := stateAt have_ q
        let b := stateAt want q
        if a != b then
          let r := fun (x : Option State) => (x.map State.render).getD "none"
          out := out.push s!"{l}: FDE at {q}: {r a}, the code has {r b}"
      for c in o.imageSites f do
        if c.start < body || c.start + c.len > stub then
          out := out.push s!"{l}: call site [{c.start}, {c.start + c.len}) outside the body [{body}, {stub})"
        if let some p := c.pad then
          if p < body || p ≥ stub then out := out.push s!"{l}: landing pad {p} outside the body [{body}, {stub})"
  if let some (s, e) := lsdaEnd then
    if let some sec := o.elf.section? s then
      if e != sec.size then out := out.push s!"`{sec.name}`: the LSDAs end at {e} of {sec.size} bytes"
  return out

end Ryo.Check.Image
