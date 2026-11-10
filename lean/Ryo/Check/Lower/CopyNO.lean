/-
Ryo.Check.Lower.CopyNO — `CopyNonOverlapping` with a constant count (aot.md §C1, M5b), and its
checker.

What the backend emits (`backend/src/lower/rvalue.rs`, `NonDivergingIntrinsic::CopyNonOverlapping`;
`operand.rs` `mem_copy_elems`/`mem_copy_pieces`): with the count a constant and `count * size`
bytes (`size` the source pointee's) at most `SPLIT_MAX`, the bytes are loaded from `[src + i]`
into a fresh temporary `t` (`frame.temp`) and stored from it to `[dst + i]`, in pieces of at
most 8 bytes (cut at the element type's field boundaries for one element). L0's `copyBytes`
loads the `count * size` bytes at the source pointer (at the pointee's alignment) and stores
them at the destination pointer; R's per-piece `load`/`store` through the temporary give the
same bytes (as `memmove` would, so the non-overlap check L0 makes is not needed).

Rule (`one`): `_ps` and `_pd` whole locals of thin pointer type (8-byte slots, the pointer read
from the slot as in `Deref.lean`), the source pointee sized (`es` bytes, alignment `al`), the
count a constant `bits` of integer type `ct` with `n = count * es > 0` bytes, lowered to one
piece: `[load.wN t, [sps.off + 0]; store.wN [spd.off + 0], t]` (`loadInsnOk`/`storeInsnOk` at
`n` bytes, so `n` is a handler width), `t` a temporary (`tempOk`: never escaped, apart from
every local's slot). The destination pointer's slot is read directly (`piece_ptr` copies it
into a temporary first when it lies in an escaped local; that form is not covered).

Not covered (`checkCopyNO`'s buckets): several pieces, a runtime count (`mul` of the count by the
element size into a temporary, then the `memcpy` handler).
-/
import Ryo.Check.Lower.Deref
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerCopyNO (Γ : StmtCtx) : Statement → List Insn → Prop where
  | one {os od : Operand} {ps pd : Local} {bits : Nat} {ct : IntType} {cvalid : ValidRange}
      {pt pt' : PtrType} {v v' : ValidRange} {es : Nat} {al : Align} {inh : Bool}
      {sps spd : LocalSlot} {iL iS : Insn} {t : Int} {n : Nat}
      (hos : os.local? = some ps) (hod : od.local? = some pd)
      (hts : Γ.body.locals[ps]? = some (.ptr pt v)) (hks : pt.metaKind = .none)
      (htd : Γ.body.locals[pd]? = some (.ptr pt' v')) (hkd : pt'.metaKind = .none)
      (hpt : pt.pointee? = some ⟨.sized es al, inh⟩)
      (hn : (ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es = n) (hpos : 0 < n)
      (hsps : Γ.slots[ps]? = some sps) (hspd : Γ.slots[pd]? = some spd)
      (hsz : sps.size = 8 ∧ spd.size = 8) (hoff : offOk sps.off = true ∧ offOk spd.off = true)
      (ht : tempOk Γ t n = true)
      (hiL : loadInsnOk Γ iL n t sps.off 0 = true) (hiS : storeInsnOk Γ iS n spd.off 0 t = true) :
      LowerCopyNO Γ (.copyNonOverlapping os od (.const (.scalar bits) (.int ct cvalid))) [iL, iS]

/-! ### The checker -/

/-- The slot a `load`-shaped instruction writes, if any (untrusted, then checked). -/
def loadDstOf (Γ : StmtCtx) (i : Insn) : Option Int :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.ops with
    | [.slot t, _] => some t
    | _ => none
  | none => none

/-- `one`'s conditions. -/
def copyOneOk (Γ : StmtCtx) (os od : Operand) (bits : Nat) (ct : IntType) (iL iS : Insn) :
    Bool :=
  match os.local?, od.local? with
  | some ps, some pd =>
    match Γ.body.locals[ps]?, Γ.body.locals[pd]?, Γ.slots[ps]?, Γ.slots[pd]? with
    | some (.ptr pt _), some (.ptr pt' _), some sps, some spd =>
      match pt.pointee? with
      | some ⟨.sized es _, _⟩ =>
        match loadDstOf Γ iL with
        | some t =>
          decide (pt.metaKind = .none) && decide (pt'.metaKind = .none) &&
            decide (0 < (ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es) &&
            sps.size == 8 && spd.size == 8 && offOk sps.off && offOk spd.off &&
            tempOk Γ t ((ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es) &&
            loadInsnOk Γ iL ((ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es) t sps.off 0 &&
            storeInsnOk Γ iS ((ct.ofBits (bits % 2 ^ (8 * ct.size))).toNat * es) spd.off 0 t
        | none => false
      | _ => false
    | _, _, _, _ => false
  | _, _ => false

theorem copyOneOk_sound {Γ : StmtCtx} {os od : Operand} {bits : Nat} {ct : IntType}
    {cvalid : ValidRange} {iL iS : Insn} (h : copyOneOk Γ os od bits ct iL iS = true) :
    LowerCopyNO Γ (.copyNonOverlapping os od (.const (.scalar bits) (.int ct cvalid)))
      [iL, iS] := by
  unfold copyOneOk at h
  split at h
  next ps pd hos hod =>
    split at h
    next pt v pt' v' sps spd hts htd hsps hspd =>
      split at h
      next es al inh hpt =>
        split at h
        next t hld =>
          simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
          obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩ := h
          exact .one hos hod hts h1 htd h2 hpt rfl h3 hsps hspd ⟨h4, h5⟩ ⟨h6, h7⟩ h8 h9 h10
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- Decide `LowerCopyNO` for a `CopyNonOverlapping` (`none` for any other statement). -/
def checkCopyNO (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .copyNonOverlapping os od oc =>
    some (match oc, is with
      | .const (.scalar bits) (.int ct _), [iL, iS] =>
        okIf (copyOneOk Γ os od bits ct iL iS) "copy nonoverlapping: form"
      | .const _ _, _ => .unsupported "copy nonoverlapping: constant count, pieces"
      | _, _ => .unsupported "copy nonoverlapping: count")
  | _ => none

theorem checkCopyNO_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkCopyNO Γ st is = some .ok) : LowerCopyNO Γ st is := by
  unfold checkCopyNO at h
  split at h
  next os od oc =>
    have h' := Option.some.inj h
    split at h'
    next bits ct cvalid iL iS => exact copyOneOk_sound (okIf_ok h')
    next => cases h'
    next => cases h'
  next => cases h

end Ryo.Check.Lower
