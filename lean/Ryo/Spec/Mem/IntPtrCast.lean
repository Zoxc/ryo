/-
Ryo.Spec.Mem.IntPtrCast — exposed provenance.

Ports: MiniRust `mem/intptrcast.md` (`IntPtrCast`, `expose`, `int2ptr`).

D11: kept as in MiniRust. `ptrFromInt` asks the oracle for the provenance (angelic `predict`):
the answer must be `none` or an exposed allocation; anything else is `noBehavior`. The
executable oracle answers with the live exposed allocation containing the address, as Miri
does.
-/
import Ryo.Spec.Mem.Basic

namespace Ryo.Spec

structure IntPtrCast where
  exposed : List AllocId := []
deriving Repr, Inhabited

namespace IntPtrCast

def expose (s : IntPtrCast) (p : ThinPointer) : IntPtrCast :=
  match p.prov with
  | some id => if s.exposed.contains id then s else { exposed := id :: s.exposed }
  | none => s

-- [D11]
def ptrFromInt {m : Type → Type} [Monad m] [MonadExceptOf Outcome m] [MonadChoice m]
    (s : IntPtrCast) (addr : Nat) : m ThinPointer := do
  let prov ← choose (.exposedProv addr)
  match prov with
  | none => pure ⟨addr, none⟩
  | some id =>
    if s.exposed.contains id then pure ⟨addr, some id⟩
    else throwNoBehavior "int-to-ptr cast picked a provenance that was never exposed"

end IntPtrCast

end Ryo.Spec
