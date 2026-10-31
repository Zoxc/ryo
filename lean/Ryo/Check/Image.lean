/-
Ryo.Check.Image — the image checks of aot.md §C4 that need no dump: the structure of an image
object (function table and symbols, relocations, JIT records, header, anchor and `__ryo_main`
slots) and of the link's registry object, against the decoded code (`ryo-lean check-image`).

- `Ryo/Check/Image/Funcs.lean`: the function table, the side-table runs, the function symbols,
  and the signature fields the code shows;
- `Ryo/Check/Image/Relocs.lean`: the relocations of the text (a second decode by
  relocations), the read-only and writable sections (with the constant relocation table), the
  JIT records, the header, the registration entry, the anchor and `__ryo_main`;
- `Ryo/Check/Image/Registry.lean`: the registry stub, and the link-level checks;
- `Ryo/Check/Image/Unwind.lean`: the CIE, each function's FDE rows against the frame rules its
  decoded prologue establishes, and its LSDA against the image's call sites;
- `Ryo/Check/Image/Pool.lean` and `Ryo/Check/Image/Dump.lean` (separate, `ryo-lean
  check-pool`): the constant pool, `__ryo_main` and the function symbols against the dump.

`cli` is `ryo-lean check-image`. Not here: what needs the dump (`Dump.lean`, and C1' for
symbol names vs the instances' `tcx.symbol_name` and the `ArgPlan`s).
-/
import Ryo.Check.Image.Funcs
import Ryo.Check.Image.Relocs
import Ryo.Check.Image.Registry
import Ryo.Check.Image.Unwind

namespace Ryo.Check.Image

open Ryo.Obj

/-- What checking one image object found. -/
structure ObjectResult where
  symbol : String
  crateHash : Nat
  cguHash : Nat
  funcs : Nat
  mismatches : Array String
  main : Option MainSlot

/-- Every check of one image object. -/
def checkObject (o : ImageObject) : ObjectResult :=
  let ds := decodeAll o
  let (mainOut, main) := checkMain o
  let mismatches := checkFuncs o ds ++ checkTextRelocs o ds ++ checkRoRelocs o ++ checkDataRelocs o ++
    checkHeader o ++ checkEntry o ++ checkAnchor o ++ mainOut ++ checkOtherRelocs o ++ unwindChecks o ds
  { symbol := o.symbol, crateHash := o.image.header.crateHash, cguHash := o.image.header.cguHash, funcs := o.funcs.size, mismatches, main }

/-- `ryo-lean check-image`: checks the image objects `objs` and the registry object, prints
each mismatch (prefixed with its object), notes, and a summary; 1 on any mismatch. -/
def run (objs : List String) (registry : Option String) : IO UInt32 := do
  let mut bad := 0
  let mut funcs := 0
  let mut syms : Array (String × Nat × Nat) := #[]
  let mut mains := 0
  for path in objs do
    match Ryo.Obj.readImageObject (← IO.FS.readBinFile path) with
    | .error e =>
      IO.println s!"{path}: can't read the image object: {e}"
      bad := bad + 1
    | .ok o =>
      let r := checkObject o
      for m in r.mismatches do IO.println s!"{path}: {m}"
      bad := bad + r.mismatches.size
      funcs := funcs + r.funcs
      syms := syms.push (r.symbol, r.crateHash, r.cguHash)
      if let some m := r.main then
        mains := mains + 1
        let what := match m.func with
          | some i => s!"func {i} of this image"
          | none => "undefined here"
        IO.println s!"{path}: note: {mainSlotName} names `{m.name}` ({what})"
  if let some path := registry then
    match Ryo.Obj.readElf (← IO.FS.readBinFile path) with
    | .error e =>
      IO.println s!"{path}: can't read the registry object: {e}"
      bad := bad + 1
    | .ok e =>
      let out := checkRegistry e
      for m in out do IO.println s!"{path}: {m}"
      bad := bad + out.size
  let link := checkLink syms mains
  for m in link do IO.println m
  bad := bad + link.size
  let reg := if registry.isSome then " and a registry object" else ""
  IO.println s!"check-image: {objs.length} image objects ({funcs} functions){reg}: {bad} mismatches"
  pure (if bad == 0 then 0 else 1)

/-- `ryo-lean check-image <image object>... [--registry <registry object>]`. -/
def cli (args : List String) : IO UInt32 := do
  let rec split (l : List String) (objs : List String) (reg : Option String) : Option (List String × Option String) :=
    match l with
    | [] => some (objs.reverse, reg)
    | "--registry" :: r :: l => if reg.isSome then none else split l objs (some r)
    | "--registry" :: [] => none
    | o :: l => split l (o :: objs) reg
  match split args [] none with
  | some (objs, reg) =>
    if objs.isEmpty && reg.isNone then
      IO.eprintln "usage: ryo-lean check-image <image object>... [--registry <registry object>]"
      pure 2
    else run objs reg
  | none =>
    IO.eprintln "check-image: --registry needs an object, and takes only one"
    pure 2

end Ryo.Check.Image
