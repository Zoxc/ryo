/-
Ryo.Proofs.Lower.SimZstRead — the simulation of `LowerZstRead` (`Check/Lower/ZstRead.lean`,
M5b): a read of a zero-sized projected place into `_d`, with no instruction.

L0 (`field_mem`, `downcast_mem`): the load is of 0 bytes, so the re-encoding stored into `_d` is
empty too (`reenc_wf`), and a store of no bytes leaves the memory (`zst_store_eq`). R takes no
step. `FnRel` at the next liveness (`FnRel.zstWrite`): every local but `_d` keeps its relation
(`LocalRel.weaken`); `_d`'s slot is empty, so its relation holds at any liveness
(`LocalRel.zero`).
-/
import Ryo.Proofs.Lower.SimEnum
import Ryo.Check.Lower.ZstRead

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- A local's relation over an empty slot holds at any liveness. -/
theorem LocalRel.zero {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory} {slot : LocalSlot}
    {p : ThinPointer} {lv : Bool} (h : LocalRel ι fp st m0 slot p lv) (hz : slot.size = 0)
    (lv' : Bool) : LocalRel ι fp st m0 slot p lv' := by
  cases h with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv _ =>
    exact .priv a x hp hι hx hlive haddr hpaddr hsize hpriv
      (fun _ k hk => absurd hk (by omega))
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    exact .esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize

/-- `FnRel` after a write of nothing to `_d`, whose slot is empty: at any liveness that adds
`_d`. -/
theorem FnRel.zstWrite {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {d : Local}
    {sd : LocalSlot} (hsd : Γ.slots[d]? = some sd) (hz : sd.size = 0)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true) : FnRel Γ ι live' f m0 s1 := by
  refine ⟨⟨hrel.frame.mem, ?_⟩, hrel.hidden, hrel.unaliased, hrel.provNe, hrel.apart, hrel.esc⟩
  intro l p hp hal
  obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
  refine ⟨slot, hsl, ?_⟩
  by_cases hl : l = d
  · subst hl
    rw [hsd] at hsl
    obtain rfl := Option.some.inj hsl
    exact hr.zero hz _
  · exact hr.weaken (fun h => (hlive' l h).resolve_left hl)

/-- A zero-sized re-encoding stored into `_d` leaves L0's memory. -/
theorem zst_store_eq {ty : Spec.Ty} (hwf : ty.wf = true) (hn : ty.size? = some 0)
    {m m' : Memory} {q pd : ThinPointer} {bs0 bsd : List AbstractByte} {v : Value}
    (hlo : m.load q 0 .one = .ok bs0) (hdec : ty.decode bs0 = some v)
    (hen : ty.encode v = some bsd) (hsto : m.store pd bsd .one = .ok m') : m' = m := by
  have hb0 : bs0 = [] := load_zero_inv hlo
  have hl : bs0.length = 0 := by simp [hb0]
  have hle := reenc_wf hwf hn hl hdec hen
  have hlb : bsd.length = 0 :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans hl
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with ⟨-, -, he⟩ | ⟨_, _, _, hne, -⟩
  · exact he
  · exact absurd hlb hne

/-- `LowerZstRead`'s lift: no R step. -/
theorem lift_zstRead {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerZstRead Γ (.assign ⟨d, []⟩ rv) is) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  have key : ∀ {sd : LocalSlot}, Γ.slots[d]? = some sd → sd.size = 0 → s'.stack = s.stack →
      s'.mem = s.mem → LiftOutN Γ c ch ι live' f s s' s1 0 := by
    intro sd hsd hz hstk hm
    refine ⟨s1.st, .refl _, hstk, ?_, ?_, ?_, ?_⟩
    · rw [hm]
      exact (hrel.zstWrite hsd hz hlive').congr rfl rfl rfl rfl
    · rw [hm]; exact hpb
    · exact Nat.le_of_eq (by rw [hm])
    · rw [hm]; exact MemKept.refl _
  cases hlow with
  | @field d a oa projs ta ty off sd ha hta hpath htd hn hwf hsd hz =>
    rw [eval_use_place_norm ha] at h
    rw [hbody] at hta htd
    obtain ⟨pd, pa, bs0, v, bsd, -, -, hlo, hdec, hen, hsto, hstk⟩ :=
      field_mem hs hta hpath htd hn h
    exact key hsd hz hstk (zst_store_eq hwf hn hlo hdec hen hsto)
  | @downcast d a oa projs ta ty off sd ha hta hpath htd hn hwf hsd hz =>
    rw [eval_use_place_norm ha] at h
    rw [hbody] at hta htd
    obtain ⟨pd, pa, bs0, v, bsd, -, -, hlo, hdec, hen, hsto, hstk⟩ :=
      downcast_mem hs hta hpath htd hn h
    exact key hsd hz hstk (zst_store_eq hwf hn hlo hdec hen hsto)

/-- The statement's `StmtOut`. -/
theorem stmt_sim_zstRead {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerZstRead Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, rfl⟩
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hlen := rangeInsns_length (r := r) h2
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  refine stmtOut_of_liftN (k := (rangeInsns c.d r).length) M.stack hfn.storage M.hbd hst M.sl
    M.fresh M.dinv (by rw [hpc0, hlen]; omega) ?_
  exact lift_zstRead M.stack M.body.symm h M.rel M.pb hl1 hev

end Ryo.Proofs.Lower
