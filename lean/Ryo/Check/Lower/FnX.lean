/-
Ryo.Check.Lower.FnX — a whole function's lowering with scopes (aot.md §C1, M5b): `LowersFnX Γ d`
is `Fn.lean`'s `LowersFn` without `noScopes`/`noEsc`, plus the scope placement of `Ref.lean`
(`ScopesOk`), with the context's `escaped` the offsets the function's `Escape`s cover
(`scopeEscaped`, `fnCtxX`), and the statement ranges' fall-through views and empty pending
lists after them (`StmtsXOk`). `checkFnX` decides it (`checkFnX_sound`). The simulation it is for
is `Ryo/Proofs/Lower/FnRelEsc.lean`'s.
-/
import Ryo.Check.Lower.Fn
import Ryo.Check.Lower.Ref

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R
open Ryo.Proofs.Lower (PlainView IntsSized)

/-- A function's rule context with its `Escape`s. For code without scopes it is `fnCtx`
(`scopeEscaped` of no scopes is constantly false). -/
def fnCtxX (body : Body) (fc : FuncCert) (mode : Ryo.Obj.Mode) (ρ : Addrs) (d : Decoded) :
    TermCtx :=
  { fnCtx body fc mode ρ with escaped := scopeEscaped d }

/-- The statement ranges' facts the simulation with pending scopes needs: every instruction
of a statement's range falls through (a view with control `next`), and a non-empty range
leaves no pending `End` for the next statement. -/
structure BlockStmtsXOk (Γ : TermCtx) (d : Decoded) (bd : BlockData) (blk : BlockCert) :
    Prop where
  next : ∀ (i : Nat) (r : Range), blk.stmts[i]? = some r → ∀ k, r.1 ≤ k → k < r.2 →
    ∀ ins, d.insns[k]? = some ins → ∃ v, view Γ.mode Γ.ρ ins = some v ∧ v.ctl = some .next
  pend0 : ∀ (i : Nat) (r : Range), blk.stmts[i]? = some r → r.1 < r.2 →
    pendSpecs Γ.toStmtCtx bd blk (i + 1) = []
  /-- A `StorageDead` with an `End` finds it at its pending index of the scopes at its start
  (`ScopesOk` checks them only at the next non-empty range). -/
  endAt : ∀ (i : Nat) (l : Local) (sl : LocalSlot), bd.stmts[i]? = some (.storageDead l) →
    Γ.slots[l]? = some sl → privOk Γ.toStmtCtx sl.off sl.size = false →
    ∃ sc, (scopesAtD d (startAt blk i))[(pendSpecs Γ.toStmtCtx bd blk i).length]? = some sc ∧
      ScopeSpec.ok (.endS sl.off sl.size) sc = true

def StmtsXOk (Γ : TermCtx) (d : Decoded) : Prop :=
  ∀ (b : Nat) bd blk, Γ.body.blocks[b]? = some bd → Γ.blocks[b]? = some blk →
    BlockStmtsXOk Γ d bd blk

def nextViewOk (Γ : TermCtx) (ins : Insn) : Bool :=
  match view Γ.mode Γ.ρ ins with
  | some v => v.ctl == some .next
  | none => false

theorem nextViewOk_spec {Γ : TermCtx} {ins : Insn} (h : nextViewOk Γ ins = true) :
    ∃ v, view Γ.mode Γ.ρ ins = some v ∧ v.ctl = some .next := by
  unfold nextViewOk at h
  split at h
  next v hv => exact ⟨v, hv, by simpa using h⟩
  · cases h

def blockStmtsXCheck (Γ : TermCtx) (d : Decoded) (bd : BlockData) (blk : BlockCert) : Bool :=
  ((List.range blk.stmts.size).all fun i => match blk.stmts[i]? with
    | some r =>
      ((List.range (r.2 - r.1)).all fun j => match d.insns[r.1 + j]? with
        | some ins => nextViewOk Γ ins
        | none => true) &&
      (!decide (r.1 < r.2) || (pendSpecs Γ.toStmtCtx bd blk (i + 1)).isEmpty)
    | none => true) &&
  (List.range bd.stmts.length).all fun i => match bd.stmts[i]? with
    | some (.storageDead l) =>
      match Γ.slots[l]? with
      | some sl => privOk Γ.toStmtCtx sl.off sl.size ||
        match (scopesAtD d (startAt blk i))[(pendSpecs Γ.toStmtCtx bd blk i).length]? with
        | some sc => ScopeSpec.ok (.endS sl.off sl.size) sc
        | none => false
      | none => true
    | _ => true

theorem blockStmtsXCheck_sound {Γ : TermCtx} {d : Decoded} {bd : BlockData} {blk : BlockCert}
    (h : blockStmtsXCheck Γ d bd blk = true) : BlockStmtsXOk Γ d bd blk := by
  unfold blockStmtsXCheck at h
  rw [Bool.and_eq_true] at h
  obtain ⟨h, hend⟩ := h
  simp only [List.all_eq_true, List.mem_range] at h hend
  refine ⟨fun i r hr k hk1 hk2 ins hins => ?_, fun i r hr hlt => ?_,
    fun i l sl hst hsl hpriv => ?_⟩
  · have hi := (Array.getElem?_eq_some_iff.mp hr).1
    have hc := h i hi
    rw [hr] at hc
    simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range] at hc
    have hj := hc.1 (k - r.1) (by omega)
    have e : r.1 + (k - r.1) = k := by omega
    rw [e, hins] at hj
    exact nextViewOk_spec hj
  · have hi := (Array.getElem?_eq_some_iff.mp hr).1
    have hc := h i hi
    rw [hr] at hc
    simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true', decide_eq_false_iff_not,
      List.isEmpty_iff] at hc
    rcases hc.2 with h1 | h1
    · exact absurd hlt h1
    · exact h1
  · have hi := (List.getElem?_eq_some_iff.mp hst).1
    have hc := hend i hi
    rw [hst] at hc
    simp only [hsl, hpriv, Bool.false_or] at hc
    split at hc
    next sc hsc => exact ⟨sc, hsc, hc⟩
    · cases hc

def stmtsXCheck (Γ : TermCtx) (d : Decoded) : Bool :=
  (List.range Γ.body.blocks.size).all fun b => match Γ.body.blocks[b]?, Γ.blocks[b]? with
    | some bd, some blk => blockStmtsXCheck Γ d bd blk
    | _, _ => false

theorem stmtsXCheck_sound {Γ : TermCtx} {d : Decoded} (h : stmtsXCheck Γ d = true) :
    StmtsXOk Γ d := by
  intro b bd blk hb hk
  unfold stmtsXCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have hc := h b (Array.getElem?_eq_some_iff.mp hb).1
  rw [hb, hk] at hc
  exact blockStmtsXCheck_sound hc

/-- The function's lowering, scopes allowed (see the module comment). -/
structure LowersFnX (Γ : TermCtx) (d : Decoded) : Prop where
  notPe : Γ.mode.pe = false
  escDef : Γ.escaped = scopeEscaped d
  blocksSize : Γ.blocks.size = Γ.body.blocks.size
  reach : ReachSound Γ.body (reachGet (computeReach Γ.body))
  block : ∀ (b : Nat) bd blk, reachGet (computeReach Γ.body) b = true →
    Γ.body.blocks[b]? = some bd → Γ.blocks[b]? = some blk → BlockOk Γ d bd blk
  plain : ∀ (k : Nat) i, d.insns[k]? = some i → PlainView Γ.mode Γ.ρ i
  ints : IntsSized Γ.body
  live : LiveSound Γ.body (computeLive Γ.body).get
  storage : StorageSound Γ.body (computeStorage Γ.body).get
  share : Γ.slots.size ≤ Γ.body.locals.size ∧ ShareOk Γ.body Γ.slots (computeStorage Γ.body).get
  deadAfter : ∀ (b : Nat) bd (i : Nat) (l : Local), Γ.body.blocks[b]? = some bd →
    bd.stmts[i]? = some (.storageDead l) → (computeLive Γ.body).get b (i + 1) l = false
  fresh : ∀ (b : Nat) bd (i : Nat) (l : Local), Γ.body.blocks[b]? = some bd →
    bd.stmts[i]? = some (.storageLive l) →
    (computeStorage Γ.body).get b i l = false ∧ ∃ sd, Γ.slots[l]? = some sd ∧
      ∀ ty, Γ.body.locals[l]? = some ty → ty.size? = some sd.size
  scopes : ScopesOk Γ d
  stmtsX : StmtsXOk Γ d

/-- The function's checker, scopes allowed. -/
def checkFnX (Γ : TermCtx) (d : Decoded) : Bool :=
  !Γ.mode.pe && Γ.blocks.size == Γ.body.blocks.size && blocksCheck Γ d && plainsCheck Γ d &&
    intsCheck Γ.body && liveCheck Γ.body (computeLive Γ.body) &&
    storageCheck Γ.body (computeStorage Γ.body) &&
    shareCheck Γ.body Γ.slots (computeStorage Γ.body) &&
    storageStmtsCheck Γ.body Γ.slots (computeLive Γ.body) (computeStorage Γ.body) &&
    scopesCheck Γ d && reachOk Γ.body && stmtsXCheck Γ d

/-- `checkFnX` at `fnCtxX` (whose `escaped` is `scopeEscaped d`). -/
theorem checkFnX_sound {body : Body} {fc : FuncCert} {mode : Ryo.Obj.Mode} {ρ : Addrs}
    {d : Decoded} (h : checkFnX (fnCtxX body fc mode ρ d) d = true) :
    LowersFnX (fnCtxX body fc mode ρ d) d := by
  unfold checkFnX at h
  simp only [Bool.and_eq_true, beq_iff_eq, Bool.not_eq_true'] at h
  obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨hpe, hbs⟩, hb⟩, hp⟩, hi⟩, hl⟩, hs⟩, ha⟩, hst⟩, hsc⟩, hre⟩, hsx⟩ := h
  exact { notPe := hpe, escDef := rfl, blocksSize := hbs, reach := reachOk_sound hre,
          block := blocksCheck_sound hb, plain := plainsCheck_sound hp,
          ints := intsCheck_sound hi, live := liveCheck_sound hl,
          storage := storageCheck_sound hs, share := shareCheck_sound ha,
          deadAfter := storageStmtsCheck_dead hst, fresh := storageStmtsCheck_live hst,
          scopes := scopesCheck_sound hsc, stmtsX := stmtsXCheck_sound hsx }

/-- The coverage verdict of a whole function with scopes. -/
def fnVerdictX (body : Body) (fc : FuncCert) (d : Decoded) (mode : Ryo.Obj.Mode) (ρ : Addrs) :
    Verdict :=
  if checkFnX (fnCtxX body fc mode ρ d) d then .ok else .unsupported "function"

end Ryo.Check.Lower
