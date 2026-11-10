/-
Ryo.Check.Lower.DerefSplit — a store through a thin pointer split into pieces (aot.md §C1,
M5b's places), and its checker.

What the backend emits (`backend/src/lower/operand.rs` `store`, `split`, `pieces`): for
`(*_p).f₁.….fₖ = copy/move _a` whose `n` bytes are not one store width (`Width::of_size`) and
at most `SPLIT_MAX`, the stores `store.wN [p + (k + o)], s + o` for the pieces `(o, wN)` of
`pieces` (the widest width up to 8 at each offset not straddling a field offset). The pointer
slot `p` is `_p`'s, unless `_p` is escaped (`piece_ptr` then copies it into a temporary first:
not covered here).

Rule (`store`): as `Deref.lean`'s `store` (`_p` of type `.ptr pt valid` with a thin pointer,
the projections after the deref fields `fieldPath` covers, `_a` a whole local of the projected
type `ty`, well-formed, of `n > 0` bytes), with both `_p`'s and `_a`'s slots never escaped
(each piece reads both again after the earlier pieces' stores, which then cannot have changed
them), the offsets in range, and the instructions `storePiecesOk`: one `store` of `w` bytes from
`[sa.off + o, +w)` to `[sp.off + (off + o)]` for each width `w > 0` of `ws`, at the running
offset `o`, the widths summing to `n`. The simulation is `Proofs/Lower/SimDerefSplit.lean`.

`checkDerefSplit` reads the widths off the instructions (`storeWidthOf`, untrusted) and checks
them; it answers `none` unless the statement is such a store and all checks pass, so it must
run before `checkDeref`, which reports these as `deref store: not a store width`.
-/
import Ryo.Check.Lower.Deref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The stores of the pieces of widths `ws` from offset `o`: through the pointer in slot `p`
at `k + o`, from slot `s + o`. -/
def storePiecesOk (Γ : StmtCtx) (p k s : Int) : Nat → List Insn → List Nat → Bool
  | _, [], [] => true
  | o, i :: is, w :: ws =>
    decide (0 < w) && storeInsnOk Γ i w p (k + o) (s + o) && storePiecesOk Γ p k s (o + w) is ws
  | _, _, _ => false

/-- The width of an instruction whose view is a handler at one integer type (the guess for
`storePiecesOk`'s widths). -/
def storeWidthOf (Γ : StmtCtx) (i : Insn) : Option Nat :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨_, [ty], _⟩ =>
      match OpSem.Ty.parse ty with
      | some (.int w _) => some w
      | _ => none
    | _ => none
  | none => none

inductive LowerDerefSplit (Γ : StmtCtx) : Statement → List Insn → Prop where
  | store {p a : Local} {oa : Operand} {pointee ty : Ty} {fields : List ProjElem} {pt : PtrType}
      {valid : ValidRange} {off n : Nat} {sp sa : LocalSlot} {ws : List Nat} {is : List Insn}
      (ha : oa.local? = some a)
      (htp : Γ.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hpath : fieldPath pointee fields = some (off, ty))
      (hta : Γ.body.locals[a]? = some ty)
      (hn : ty.size? = some n) (hpos : 0 < n) (hwf : ty.wf = true)
      (hsp : Γ.slots[p]? = some sp) (hsa : Γ.slots[a]? = some sa)
      (hsize : sa.size = n ∧ sp.size = 8)
      (hoff : offOk sp.off = true ∧ offOk sa.off = true ∧ offOk (sa.off + n) = true ∧
        offOk (off : Int) = true ∧ offOk ((off + n : Nat) : Int) = true)
      (hprivp : ∀ k < sp.size, Γ.escaped (sp.off + k) = false)
      (hpriva : ∀ k < sa.size, Γ.escaped (sa.off + k) = false)
      (hws : ws.sum = n)
      (his : storePiecesOk Γ sp.off off sa.off 0 is ws = true) :
      LowerDerefSplit Γ (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) is

/-! ### The checker -/

/-- The rule's conditions for `(*_p).fields = copy/move _a` at `off` of type `ty`. -/
def derefSplitOk (Γ : StmtCtx) (p a : Local) (off : Nat) (ty : Ty) (is : List Insn) : Bool :=
  match Γ.body.locals[a]?, ty.size?, Γ.slots[p]?, Γ.slots[a]?, is.mapM (storeWidthOf Γ) with
  | some ta, some n, some sp, some sa, some ws =>
    decide (ta = ty) && decide (0 < n) && ty.wf && sa.size == n && sp.size == 8 &&
      offOk sp.off && offOk sa.off && offOk (sa.off + n) && offOk (off : Int) &&
      offOk ((off + n : Nat) : Int) && privOk Γ sp.off sp.size && privOk Γ sa.off sa.size &&
      ws.sum == n && storePiecesOk Γ sp.off off sa.off 0 is ws
  | _, _, _, _, _ => false

theorem derefSplitOk_spec {Γ : StmtCtx} {p a : Local} {off : Nat} {ty : Ty} {is : List Insn}
    (h : derefSplitOk Γ p a off ty is = true) :
    ∃ (n : Nat) (sp sa : LocalSlot) (ws : List Nat),
      Γ.body.locals[a]? = some ty ∧ ty.size? = some n ∧ 0 < n ∧ ty.wf = true ∧
      Γ.slots[p]? = some sp ∧ Γ.slots[a]? = some sa ∧ (sa.size = n ∧ sp.size = 8) ∧
      (offOk sp.off = true ∧ offOk sa.off = true ∧ offOk (sa.off + n) = true ∧
        offOk (off : Int) = true ∧ offOk ((off + n : Nat) : Int) = true) ∧
      (∀ k < sp.size, Γ.escaped (sp.off + k) = false) ∧
      (∀ k < sa.size, Γ.escaped (sa.off + k) = false) ∧
      ws.sum = n ∧ storePiecesOk Γ sp.off off sa.off 0 is ws = true := by
  unfold derefSplitOk at h
  split at h
  next ta n sp sa ws hta hn hsp hsa hws =>
    simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩, h7⟩, h8⟩, h9⟩, h10⟩, h11⟩, h12⟩, h13⟩,
      h14⟩ := h
    subst h1
    exact ⟨n, sp, sa, ws, hta, hn, h2, h3, hsp, hsa, ⟨h4, h5⟩, ⟨h6, h7, h8, h9, h10⟩,
      privOk_spec h11, privOk_spec h12, h13, h14⟩
  next => cases h

/-- Decide `LowerDerefSplit` (see the module comment). -/
def checkDerefSplit (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨p, .deref pointee :: fields⟩ (.use oa) =>
    match oa.local? with
    | some a =>
      match Γ.body.locals[p]? with
      | some (.ptr pt _) =>
        if pt.metaKind = .none then
          match fieldPath pointee fields with
          | some (off, ty) => if derefSplitOk Γ p a off ty is then some .ok else none
          | none => none
        else none
      | _ => none
    | none => none
  | _ => none

theorem checkDerefSplit_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkDerefSplit Γ st is = some .ok) : LowerDerefSplit Γ st is := by
  unfold checkDerefSplit at h
  split at h
  next p pointee fields oa =>
    split at h
    next a ha =>
      split at h
      next pt valid htp =>
        split at h
        next hk =>
          split at h
          next off ty hpath =>
            split at h
            next hok =>
              obtain ⟨n, sp, sa, ws, hta, hn, hpos, hwf, hsp, hsa, hsize, hoff, hpp, hpa, hws,
                his⟩ := derefSplitOk_spec hok
              exact .store ha htp hk hpath hta hn hpos hwf hsp hsa hsize hoff hpp hpa hws his
            next => cases h
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
