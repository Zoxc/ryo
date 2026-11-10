/-
Ryo.Check.Lower.DerefZst — zero-sized reads and writes through a thin pointer (aot.md §C1,
M5b's places), and their checker.

`_d = copy/move (*_p).fields` and `(*_p).fields = copy/move _a` where the place's type is
zero-sized: the backend copies no bytes (`copy_val` returns at `size == 0`), so the range has no
instruction. L0 still evaluates the place (`_p`'s pointer must load and decode, the field
offsets stay in bounds) but loads and stores no bytes, so its memory is unchanged; the
simulation (`Proofs/Lower/SimDerefZst.lean`) takes no R step.

Rules: as `Deref.lean`'s `load` and `store` (`_p` of type `.ptr pt valid` with a thin pointer,
the projections after the deref fields `fieldPath` covers), the place's type `ty` well-formed of
0 bytes; `load`: `ty` is `_d`'s type, `_d`'s slot empty; `store`: `ty` is `_a`'s type.

`checkDerefZst` answers `none` unless the statement is such an access with all checks passing,
so it must run before `checkDeref`, which reports these as `deref: zero-sized` and
`deref store: zero-sized`.
-/
import Ryo.Check.Lower.ZstRead
import Ryo.Check.Lower.Deref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerDerefZst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | load {d p : Local} {oa : Operand} {pointee ty : Ty} {fields : List ProjElem} {pt : PtrType}
      {valid : ValidRange} {off : Nat} {sd : LocalSlot}
      (ha : operandPlace? oa = some ⟨p, .deref pointee :: fields⟩)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (htd : Γ.body.locals[d]? = some ty) (hn : ty.size? = some 0) (hwf : ty.wf = true)
      (hsd : Γ.slots[d]? = some sd) (hz : sd.size = 0) :
      LowerDerefZst Γ (.assign ⟨d, []⟩ (.use oa)) []
  | store {p a : Local} {oa : Operand} {pointee ty : Ty} {fields : List ProjElem} {pt : PtrType}
      {valid : ValidRange} {off : Nat}
      (ha : oa.local? = some a)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (hta : Γ.body.locals[a]? = some ty) (hn : ty.size? = some 0) (hwf : ty.wf = true) :
      LowerDerefZst Γ (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) []

/-! ### The checker -/

def derefZstLoadOk (Γ : StmtCtx) (d p : Local) (pointee : Ty) (fields : List ProjElem)
    (is : List Insn) : Bool :=
  match Γ.body.locals[p]?, fieldPath pointee fields, Γ.body.locals[d]?, Γ.slots[d]?, is with
  | some (.ptr pt _), some (_, ty), some td, some sd, [] =>
    decide (pt.metaKind = .none) && zstDstOk td ty sd
  | _, _, _, _, _ => false

def derefZstStoreOk (Γ : StmtCtx) (p : Local) (pointee : Ty) (fields : List ProjElem) (a : Local)
    (is : List Insn) : Bool :=
  match Γ.body.locals[p]?, fieldPath pointee fields, Γ.body.locals[a]?, is with
  | some (.ptr pt _), some (_, ty), some ta, [] =>
    decide (pt.metaKind = .none) && decide (ta = ty) && decide (ty.size? = some 0) && ty.wf
  | _, _, _, _ => false

/-- Decide `LowerDerefZst` (see the module comment). -/
def checkDerefZst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match operandPlace? oa with
    | some ⟨p, .deref pointee :: fields⟩ =>
      if derefZstLoadOk Γ d p pointee fields is then some .ok else none
    | _ => none
  | .assign ⟨p, .deref pointee :: fields⟩ (.use oa) =>
    match oa.local? with
    | some a => if derefZstStoreOk Γ p pointee fields a is then some .ok else none
    | none => none
  | _ => none

theorem derefZstLoadOk_sound {Γ : StmtCtx} {d p : Local} {oa : Operand} {pointee : Ty}
    {fields : List ProjElem} {is : List Insn}
    (ha : operandPlace? oa = some ⟨p, .deref pointee :: fields⟩)
    (h : derefZstLoadOk Γ d p pointee fields is = true) :
    LowerDerefZst Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold derefZstLoadOk at h
  split at h
  next pt valid off ty td sd htp hpath htd hsd =>
    simp only [Bool.and_eq_true, decide_eq_true_eq] at h
    obtain ⟨hk, hz⟩ := h
    obtain ⟨rfl, hn, hwf, hz⟩ := zstDstOk_spec hz
    exact .load ha htp hk hpath htd hn hwf hsd hz
  next => cases h

theorem derefZstStoreOk_sound {Γ : StmtCtx} {p a : Local} {oa : Operand} {pointee : Ty}
    {fields : List ProjElem} {is : List Insn} (ha : oa.local? = some a)
    (h : derefZstStoreOk Γ p pointee fields a is = true) :
    LowerDerefZst Γ (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) is := by
  unfold derefZstStoreOk at h
  split at h
  next pt valid off ty ta htp hpath hta =>
    simp only [Bool.and_eq_true, decide_eq_true_eq] at h
    obtain ⟨⟨⟨hk, rfl⟩, hn⟩, hwf⟩ := h
    exact .store ha htp hk hpath hta hn hwf
  next => cases h

theorem checkDerefZst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDerefZst Γ st is = some .ok) : LowerDerefZst Γ st is := by
  unfold checkDerefZst at h
  split at h
  next d oa =>
    split at h
    next p pointee fields hp =>
      split at h
      next hok => exact derefZstLoadOk_sound hp hok
      next => cases h
    next => cases h
  next p pointee fields oa =>
    split at h
    next a ha =>
      split at h
      next hok => exact derefZstStoreOk_sound ha hok
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
