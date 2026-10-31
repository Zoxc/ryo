/-
# Each image function's unwind tables (aot.md §C3, "Unwind")

`unwind_elf` (`vm/bytecode/src/image/unwind.rs`) gives every function of an image one FDE in
`.eh_frame`, its first address relocated against the text section at the function's
`code_off`, and one LSDA (`asm::lsda::write` of its call sites) in `.gcc_except_table.*`, the
FDE's LSDA pointer relocated against it. The image's call-site table (`CallSiteEntry`) is
written from the same call sites, so the LSDA must describe exactly the image's table.

The LSDAs are concatenated without padding, so a function's LSDA is read up to the next LSDA
any FDE points at in the same section (or the section's end): `Lsda.parse` accepts nothing
after the table.
-/
import Ryo.Obj.EhFrame
import Ryo.Obj.Lsda

namespace Ryo.Obj

open EhFrame

/-- A function's unwind tables. -/
structure FuncUnwind where
  fde : Fde
  /-- The LSDA's section and offset in it. -/
  lsdaSection : Section
  lsdaOff : Nat
  lsda : ByteArray
  /-- `Lsda.parse` of it. -/
  sites : Option (Array CallSite)

namespace ImageObject

/-- The call sites of the image's table for function `f` (`From<&CallSiteEntry> for
CallSite`: `CONTINUE` is no pad, `CATCH` the catch bit). -/
def imageSites (o : ImageObject) (f : FuncEntry) : Array CallSite :=
  (o.image.callSites f).map fun c =>
    if c.pad == CONTINUE then ⟨c.start, c.len, none, false⟩
    else ⟨c.start, c.len, some (c.pad % CATCH), c.pad ≥ CATCH⟩

/-- The FDE of function `i`: the one whose first address is the function's start in the text
section (exactly one). -/
def fdeOf (o : ImageObject) (eh : EhFrame) (i : Nat) : Except String Fde := do
  let some f := o.funcs[i]? | throw s!"no function {i}"
  let start := Ptr.to (.sect o.text.index ((o.textBase + f.codeOff : Nat) : Int))
  match (eh.fdes.filter (·.pcBegin.value == start)).toList with
  | [d] => pure d
  | [] => throw s!"no FDE starts at the function"
  | ds => throw s!"{ds.length} FDEs start at the function"

/-- Function `i`'s FDE and LSDA. -/
def funcUnwind (o : ImageObject) (eh : EhFrame) (i : Nat) : Except String FuncUnwind := do
  let fde ← o.fdeOf eh i
  let some p := fde.lsda | throw "the FDE has no LSDA pointer"
  let .to (.sect s off) := p.value | throw "the FDE's LSDA pointer isn't into a section"
  let some sec := o.elf.section? s | throw s!"LSDA section {s} out of range"
  if off < 0 || off.toNat > sec.size then throw s!"LSDA at {off}, outside {sec.name}"
  let off := off.toNat
  -- The next LSDA in the section.
  let next := eh.fdes.foldl (init := sec.size) fun n (d : Fde) =>
    match d.lsda.map PtrField.value with
    | some (.to (.sect s' o')) => if s' == s && o' > off && o'.toNat < n then o'.toNat else n
    | _ => n
  let lsda := (o.elf.data sec).extract off next
  pure { fde, lsdaSection := sec, lsdaOff := off, lsda, sites := Lsda.parse lsda }

/-- What `ryo-lean lsda` prints, and `scripts/lean-decode-ref lsda` (Rust's `lsda::parse` on
the same bytes):

```
fdes <n> functions <n>
func <i> <name> fde <fde offset> range <n> len <code_len> lsda <section> <offset> <length>
  site <start> <len> pad <pad | none> [catch]
  image equal | image differs
```

(`  lsda error` instead of the sites when the LSDA isn't one; `func <i> <name> error: <what>`
when the function has no FDE or LSDA). -/
def lsdaLines (o : ImageObject) : Array String := Id.run do
  match readEhFrame o.elf with
  | .error e => return #[s!"error: {e}"]
  | .ok (_, eh) =>
    let mut out := #[s!"fdes {eh.fdes.size} functions {o.funcs.size}"]
    for i in [0:o.funcs.size] do
      let f := o.funcs[i]!
      let name := o.funcName f.codeOff
      match o.funcUnwind eh i with
      | .error e => out := out.push s!"func {i} {name} error: {e}"
      | .ok u =>
        out := out.push s!"func {i} {name} fde {u.fde.offset} range {u.fde.pcRange} len {f.codeLen} lsda {u.lsdaSection.name} {u.lsdaOff} {u.lsda.size}"
        match u.sites with
        | none => out := out.push "  lsda error"
        | some sites =>
          for c in sites do
            let pad := match c.pad with | some p => toString p | none => "none"
            out := out.push s!"  site {c.start} {c.len} pad {pad}{if c.catches then " catch" else ""}"
          out := out.push (if sites == o.imageSites f then "  image equal" else "  image differs")
    return out

end ImageObject

end Ryo.Obj
