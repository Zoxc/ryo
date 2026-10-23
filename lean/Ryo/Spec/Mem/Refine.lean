/-
Ryo.Spec.Mem.Refine — the "more defined" order on bytes, pointers and memories.

Ports: MiniRust `lang/representation.md` § Generic properties (`DefinedRelation` for
`AbstractByte`, `ThinPointer`, `PointerMeta`, `Pointer`, `List`, `Option`). The order on
`Value` is in `Ryo.Spec.Lang.Values` (values are defined after memory).

These relations are not needed to run programs; they state the representation laws
(`Ryo.Spec.Theorems`) and are the basis of every later simulation proof (memory refinement:
provenance erased, `Uninit` refined by any byte).
-/
import Ryo.Spec.Mem.Basic

namespace Ryo.Spec

def AbstractByte.leDefined : AbstractByte → AbstractByte → Bool
  | .uninit, _ => true
  | .init d1 none, .init d2 _ => d1 == d2
  | .init d1 (some p1), .init d2 (some p2) => d1 == d2 && p1 == p2
  | _, _ => false

def ThinPointer.leDefined (a b : ThinPointer) : Bool :=
  a.addr == b.addr &&
    match a.prov, b.prov with
    | none, _ => true
    | some p, some q => p == q
    | _, _ => false

def PointerMeta.leDefined : PointerMeta → PointerMeta → Bool
  | .vtablePointer p, .vtablePointer q => p.leDefined q
  | a, b => a == b

def Option.leDefinedBy {α : Type} (r : α → α → Bool) : Option α → Option α → Bool
  | none, _ => true
  | some a, some b => r a b
  | _, _ => false

def Pointer.leDefined (a b : Pointer) : Bool :=
  a.thin.leDefined b.thin && Option.leDefinedBy PointerMeta.leDefined a.metadata b.metadata

def List.leDefinedBy {α : Type} (r : α → α → Bool) : List α → List α → Bool
  | [], [] => true
  | a :: as, b :: bs => r a b && List.leDefinedBy r as bs
  | _, _ => false

def bytesLeDefined : List AbstractByte → List AbstractByte → Bool :=
  List.leDefinedBy AbstractByte.leDefined

/-- Memory refinement: same allocations (addresses, kinds, liveness), each byte more defined. -/
def Memory.leDefined (a b : Memory) : Bool :=
  a.allocs.size == b.allocs.size &&
    (a.allocs.zip b.allocs).all fun (x, y) =>
      x.addr == y.addr && x.align == y.align && x.kind == y.kind && x.live == y.live &&
        x.mutable == y.mutable && bytesLeDefined x.data.toList y.data.toList

theorem AbstractByte.leDefined_refl (b : AbstractByte) : b.leDefined b = true := by
  cases b with
  | uninit => rfl
  | init d f => cases f <;> simp [AbstractByte.leDefined]

theorem bytesLeDefined_refl (bs : List AbstractByte) : bytesLeDefined bs bs = true := by
  induction bs with
  | nil => rfl
  | cons b bs ih =>
    simp only [bytesLeDefined, List.leDefinedBy] at *
    simp [AbstractByte.leDefined_refl, ih]

end Ryo.Spec
