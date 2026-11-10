/-
Ryo.Proofs.Lower.SimCmpMoreX — `stmt_simX`'s cases (StmtSimX.lean) for `LowerCmpX` and
`LowerCmpConst` (and `LowerBoolBin`, as `LowerCmpX`; `LowerDerefCast`, as the deref load
and store; `LowerUnionAgg`, as `castMore`; `LowerStoreTemp`, as the deref store over two
instructions; `LowerFieldWrite`, as the deref store; `LowerFieldCopyN`, as `LowerStoreTemp`;
`LowerStmtEsc`, as `LowerCmpX`; `LowerDerefWide`, as `LowerDerefCast`; `LowerRefDerefIdx`, as
`LowerCmpConst`; `LowerRefDerefDown`, as `LowerCmpX`; `LowerDerefStoreF`, as `LowerDerefCast`'s
store) under pending scopes: `lift_cmpX` on `c.dropScopes` through
`SimRef.stmt_simX_single` (one instruction, as the `refDeref` case), `lift_cmpConst` on the cut
code through `ScopeMulti.stmtOutX_of_liftN` (as `SimMoreX.stmt_simX_castMore`). Neither has own
scopes (no `ref`). A file of its own because `ScopeMulti` imports `FnStep`.
-/
import Ryo.Proofs.Lower.ScopeMulti
import Ryo.Proofs.Lower.SimCmpX
import Ryo.Proofs.Lower.SimCmpConst
import Ryo.Proofs.Lower.SimBoolBin
import Ryo.Proofs.Lower.SimDerefCast
import Ryo.Proofs.Lower.SimUnionAgg
import Ryo.Proofs.Lower.SimUnionAggDst
import Ryo.Proofs.Lower.SimStoreTemp
import Ryo.Proofs.Lower.SimFieldWrite
import Ryo.Proofs.Lower.SimFieldCopyN
import Ryo.Proofs.Lower.SimStmtEsc
import Ryo.Proofs.Lower.SimDerefWide
import Ryo.Proofs.Lower.SimRefDerefIdx
import Ryo.Proofs.Lower.SimRefDerefDown
import Ryo.Proofs.Lower.SimDerefStoreF
import Ryo.Proofs.Lower.SimRefDerefWideE

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- `FnRelX`'s escaped objects are local slots (`objs`), so the escaped bytes lie in them. -/
theorem FnRelX.escInSlots {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m : Memory} {s1 : R.RState} (h : FnRelX Γ ι live f m s1) : EscInSlots Γ s1 := by
  intro o e he
  obtain ⟨hmem, hle, hlt⟩ := end_escapedAt_some he
  obtain ⟨l, p, sl, -, hsl, hoff, hsz, -⟩ := h.objs e hmem
  exact ⟨l, sl, hsl, by omega, by omega⟩

/-- `LowerCmpX` under pending scopes. -/
theorem stmt_simX_cmpX {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerCmpX Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h
    exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    cases h <;> first | rfl | simp [ownSpec, refPlace?]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmt_simX_single hfn hmode hρ M hst hr h2 hnext hR hown fun hc0 hsc0 hpe0 hpl0 =>
    lift_cmpX M.stack M.body.symm hmode.symm hρ.symm h hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb
      M.dinv.2 hl2 hl1 hev

/-- `LowerCmpConst` under pending scopes. -/
theorem stmt_simX_cmpConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerCmpConst Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    generalize rangeInsns c.d r = is at h
    cases h <;> first | rfl | simp [ownSpec, refPlace?]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_cmpConst M.stack M.body.symm hmode' hρ' h hi hsc hpe0
      hpl0 M.rel.rel M.rel.escInSlots M.pb M.dinv.2 hl2 hl1 hev)

/-- `LowerBoolBin` under pending scopes (as `stmt_simX_cmpX`). -/
theorem stmt_simX_boolBin {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerBoolBin Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    cases h <;> first | rfl | simp [ownSpec, refPlace?]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmt_simX_single hfn hmode hρ M hst hr h2 hnext hR hown fun hc0 hsc0 hpe0 hpl0 =>
    lift_boolBin M.stack M.body.symm hmode.symm hρ.symm h hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb
      M.dinv.2 hl2 hl1 hev

/-- `LowerDerefCast` under pending scopes: the load as `stmt_simX_cmpX`, the store as
`ScopeMulti.stmt_simX_derefStore`. -/
theorem stmt_simX_derefCast {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerDerefCast Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨pl, rv, i, rfl, hR⟩ : ∃ pl rv i, st = .assign pl rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  obtain ⟨b, ps⟩ := pl
  cases ps with
  | nil =>
    have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, []⟩ rv) = [] := by
      cases h <;> first | rfl | simp [ownSpec, refPlace?]
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmt_simX_single hfn hmode hρ M hst hr h2 hnext hR hown fun hc0 hsc0 hpe0 hpl0 =>
      lift_derefCastLoad M.stack M.body.symm hmode.symm hρ.symm h hc0 hsc0 hpe0 hpl0 M.rel.rel
        M.pb M.dinv.1 M.dinv.2 hl2 hl1 hev
  | cons x xs =>
    have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, x :: xs⟩ rv) = [] := rfl
    have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
    obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
    have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
    have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
    refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown hR
      (fun hi _ hpe0 hpl0 => ?_)
    have hc : (c.cut r.2).d.insns[s0.pc]? = some i := hi 0 (by simp)
    have hpl1 : PlainView (c.cut r.2).mode (c.cut r.2).ρ i := hpl0 i (by simp)
    exact liftOutN_of_lift (lift_derefCastStore (ch := ch) M.stack M.body.symm hmode' hρ' h
      (List.cons_ne_nil _ _) hc (cut_scopesAt c r.2 _) hpe0 hpl1 M.rel.rel M.pb M.dinv.1 M.dinv.2
      hlv2 (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

/-- `LowerUnionAgg` under pending scopes (as `SimMoreX.stmt_simX_castMore`). -/
theorem stmt_simX_unionAgg {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerUnionAgg Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    cases h; exact ⟨_, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    cases h; first | rfl | simp [ownSpec, refPlace?]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_unionAgg M.stack M.body.symm hmode' hρ' h hi hsc hpe0 hpl0
      M.rel.rel M.pb M.dinv.2 M.rel.escIdOff hl2 hl1 hev)

/-- `LowerStoreTemp` under pending scopes (as `ScopeMulti.stmt_simX_derefStore`, the lift over
the statement's two instructions). -/
theorem stmt_simX_storeTemp {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerStoreTemp Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨b, x, xs, rv, rfl⟩ : ∃ b x xs rv, st = .assign ⟨b, x :: xs⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, _, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, x :: xs⟩ rv) = [] := rfl
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_storeTemp (ch := ch) M.stack M.body.symm hmode' hρ' h hi hsc
      hpe0 hpl0 M.rel.rel M.pb M.dinv.1 M.dinv.2 hlv2
      (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

/-- `LowerFieldWrite` under pending scopes (as `ScopeMulti.stmt_simX_derefStore`). -/
theorem stmt_simX_fieldWrite {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerFieldWrite Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨b, x, xs, rv, i, rfl, hR⟩ : ∃ b x xs rv i, st = .assign ⟨b, x :: xs⟩ rv ∧
      rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, _, _, rfl, rfl⟩
  rw [hR] at h
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, x :: xs⟩ rv) = [] := rfl
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown hR
    (fun hi _ hpe0 hpl0 => ?_)
  have hc : (c.cut r.2).d.insns[s0.pc]? = some i := hi 0 (by simp)
  have hpl1 : PlainView (c.cut r.2).mode (c.cut r.2).ρ i := hpl0 i (by simp)
  exact liftOutN_of_lift (lift_fieldWriteRule (ch := ch) M.stack M.body.symm hmode' hρ' h hc
    (cut_scopesAt c r.2 _) hpe0 hpl1 M.rel.rel M.pb hlv2
    (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

/-- `LowerFieldCopyN` under pending scopes (as `stmt_simX_storeTemp`). -/
theorem stmt_simX_fieldCopyN {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerFieldCopyN Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨b, x, xs, rv, rfl⟩ : ∃ b x xs rv, st = .assign ⟨b, x :: xs⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h; exact ⟨_, _, _, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, x :: xs⟩ rv) = [] := rfl
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_fieldCopyN (ch := ch) M.stack M.body.symm hmode' hρ' h hi hsc
      hpe0 hpl0 M.rel.rel M.pb hlv2 (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

/-- `LowerStmtEsc` under pending scopes (as `LowerCmpX`). -/
theorem stmt_simX_stmtEsc {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerStmtEsc Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    cases h <;> first | rfl | simp [ownSpec, refPlace?]
  have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmt_simX_single hfn hmode hρ M hst hr h2 hnext hR hown fun hc0 hsc0 hpe0 hpl0 =>
    lift_stmtEsc M.stack M.body.symm hwf hmode.symm hρ.symm h hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb
      M.dinv.2 hl2 hl1 hev

/-- `LowerDerefWide` under pending scopes (as `LowerDerefCast`). -/
theorem stmt_simX_derefWide {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerDerefWide Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨pl, rv, i, rfl, hR⟩ : ∃ pl rv i, st = .assign pl rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  obtain ⟨b, ps⟩ := pl
  cases ps with
  | nil =>
    have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, []⟩ rv) = [] := by
      cases h <;> first | rfl | simp_all [ownSpec, refPlace?]
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmt_simX_single hfn hmode hρ M hst hr h2 hnext hR hown fun hc0 hsc0 hpe0 hpl0 =>
      lift_derefWideLoad M.stack M.body.symm hmode.symm hρ.symm h hc0 hsc0 hpe0 hpl0 M.rel.rel
        M.pb M.dinv.1 M.dinv.2 hl2 hl1 hev
  | cons x xs =>
    have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, x :: xs⟩ rv) = [] := rfl
    have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
    obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
    have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
    have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
    refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown hR
      (fun hi _ hpe0 hpl0 => ?_)
    have hc : (c.cut r.2).d.insns[s0.pc]? = some i := hi 0 (by simp)
    have hpl1 : PlainView (c.cut r.2).mode (c.cut r.2).ρ i := hpl0 i (by simp)
    exact liftOutN_of_lift (lift_derefWideStore (ch := ch) M.stack M.body.symm hmode' hρ' h
      (List.cons_ne_nil _ _) hc (cut_scopesAt c r.2 _) hpe0 hpl1 M.rel.rel M.pb M.dinv.1 M.dinv.2
      hlv2 (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

/-- `LowerRefDerefIdx` under pending scopes (as `LowerCmpConst`). -/
theorem stmt_simX_refDerefIdx {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerRefDerefIdx Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h; exact ⟨_, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    generalize rangeInsns c.d r = is at h
    cases h with
    | mk hrv htp _ _ _ _ _ hsp _ _ _ _ _ _ => simp [ownSpec, hrv, hsp, htp, fieldPath]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_refDerefIdx M.stack M.body.symm hmode' hρ' h hi hsc hpe0
      hpl0 M.rel.rel M.pb M.dinv.2 hl2 hl1 hev)

/-- `LowerRefDerefDown` under pending scopes (as `LowerCmpX`). -/
theorem stmt_simX_refDerefDown {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerRefDerefDown Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h
    exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    cases h with
    | mk hrv htp _ _ _ _ _ hsp _ _ _ => simp [ownSpec, hrv, hsp, htp, fieldPath]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmt_simX_single hfn hmode hρ M hst hr h2 hnext hR hown fun hc0 hsc0 hpe0 hpl0 =>
    lift_refDerefDown M.stack M.body.symm hmode.symm hρ.symm h hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb
      M.dinv.2 hl2 hl1 hev

/-- `LowerDerefStoreF` under pending scopes (as `LowerDerefCast`'s store). -/
theorem stmt_simX_derefStoreF {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerDerefStoreF Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨b, x, xs, rv, i, rfl, hR⟩ : ∃ b x xs rv i, st = .assign ⟨b, x :: xs⟩ rv ∧
      rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h
    exact ⟨_, _, _, _, _, rfl, rfl⟩
  rw [hR] at h
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨b, x :: xs⟩ rv) = [] := rfl
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  refine stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown hR
    (fun hi _ hpe0 hpl0 => ?_)
  have hc : (c.cut r.2).d.insns[s0.pc]? = some i := hi 0 (by simp)
  have hpl1 : PlainView (c.cut r.2).mode (c.cut r.2).ρ i := hpl0 i (by simp)
  exact liftOutN_of_lift (lift_derefStoreF (ch := ch) M.stack M.body.symm hmode' hρ' h
    hc (cut_scopesAt c r.2 _) hpe0 hpl1 M.rel.rel M.pb M.dinv.1 M.dinv.2
    hlv2 (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev)

/-- `LowerRefDerefWideE` under pending scopes (as `LowerCmpConst`). -/
theorem stmt_simX_refDerefWideE {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (h : LowerRefDerefWideE Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h; exact ⟨_, _, rfl⟩
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    generalize rangeInsns c.d r = is at h
    cases h with
    | mk hrv htp _ _ _ _ _ hsp => simp [ownSpec, hrv, hsp, htp, fieldPath]
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  have hmode' : Γ.toStmtCtx.mode = (c.cut r.2).mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = (c.cut r.2).ρ := hρ.symm
  exact stmtOutX_of_liftN hfn hmode hρ M hst hr h1 h2 hnext rfl rfl hown rfl
    (fun hi hsc hpe0 hpl0 => lift_refDerefWideE M.stack M.body.symm hmode' hρ' h hi hsc hpe0
      hpl0 M.rel.rel M.pb M.dinv.2 hl2 hl1 hev)

end Ryo.Proofs.Lower
