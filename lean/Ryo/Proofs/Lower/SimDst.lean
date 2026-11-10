/-
Ryo.Proofs.Lower.SimDst — the lifts of `LowerCopy` (`copyAny`, `bitCast`, `ptrCast`) and
`LowerField` with a destination that may be escaped (M5b): the rules no longer require `_d`'s
slot private (`hpriv`), the lifts write `_d` through `FnRel.write_dst` (WriteDst.lean) in place
of `priv_dst` + `writeLocal_priv`, and take L0's `LiveDisjoint` (`DerefInv`'s second half,
`MatchAt.dinv.2`, `MatchAtX.dinv.2`) for it.

- `lift_movMemE`: `SimCopy.lift_movMem` (now unused, kept) without
  `hpriv`; `lift_copy` dispatches the three copy rules to it with their `*_mem` lemmas.
- `lift_field`: `SimField.lift_field`'s proof with `sim_copyField`'s steps inlined, the write
  by `FnRel.write_dst`.
Everything else is as before: the stored bytes are below the loaded ones, so `Hidden`,
`ProvBounded` and `MemKept` hold as for a private destination (they are about L0's memory).
The results are `LiftOut`s, used unchanged by `FnStep.stmt_sim` and, on `c.dropScopes`, by
`stmt_simX_family` (`liftOutX_of_liftOut`: a step that writes an escaped object keeps the
objects and `AllocsKept`).
-/
import Ryo.Proofs.Lower.WriteDst
import Ryo.Proofs.Lower.SimCopy
import Ryo.Proofs.Lower.SimField

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-- A `mov` of `n` bytes from `_a`'s slot to `_d`'s slot, private or escaped, simulates any L0
effect `MovMem` (`lift_movMem` with `FnRel.write_dst` for the write). -/
theorem lift_movMemE {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d a : Local} {n : Nat} {sd sa : LocalSlot} {i : R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
    (hsize : sd.size = n ∧ sa.size = n) (hpos : 0 < n) (hoff : offOk sd.off ∧ offOk sa.off)
    (hmi : movInsnOk Γ i n sd.off sa.off = true)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hla : live a = true) (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmm : MovMem f d a n s s') :
    LiftOut Γ c ch ι live' f s s' s1 := by
  obtain ⟨pd, pa, bs0, bsd, hpd, hpa, hlo0, hle, hsto, hstk⟩ := hmm
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  have hra := hrel.opnd hpa hsa hla
  have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  -- R's read refines `bs0`, hence `bsd`
  have hloa : s.mem.load pa sa.size .one = .ok bs0 := by rw [hsize.2]; exact hlo0
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
  rw [hsize.2] at hrfa
  have hbs := BytesInj.of_le hle hia
  have hlend : bsd.length = n :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans (movLoad_length hlo0)
  have hlenb : ba.length = n := (BytesInj.length hbs).symm.trans hlend
  have hlen0 : bsd.length = sd.size := by rw [hlend, hsize.1]
  -- R's write, to a private or an escaped `_d`
  obtain ⟨st', hwr, hesc, hmi', hrd, hoth⟩ := hrel.write_dst hld hpd hsd hpos' hbs hlen0 hsto
  have hop := opSem_mov_fwd (ch := ch) hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hlenb hwr
  have hsub := le_prov hle
  -- `Hidden`: the stored provenance is the loaded bytes', which `Hidden` excludes
  have hhid := hrel.hidden.load hlo0
  have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hhid _ (List.getElem_mem hj) fr0 hf0
  -- the bound: likewise
  have hbd := hpb.load hlo0
  have hbd' : BytesBounded s.mem.allocs.size bsd := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hbd _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
    hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

/-- `LowerCopy`'s lift (any destination).

Proof: as `SimCopy`'s former `lift_copy`: `cases hlow`; `live a` from `hlo`, the rule's `*_mem`
lemma, then `lift_movMemE`. -/
theorem lift_copy {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerCopy Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | copyAny ha htd hta hwf hn hpos hsd hsa hsize hoff hmi =>
    rw [hbody] at htd hta
    exact lift_movMemE hmode hρ hsd hsa hsize hpos hoff hmi hi hsc hpe hpl hrel hpb hld
      (hlo _ (operand_local_mem ha)) hlive' (copyAny_mem hs ha htd hta hwf hn h)
  | bitCast hk ha htd hta hwfd hwfa hnd hna hpos hsd hsa hsize hoff hmi =>
    rw [hbody] at htd hta
    exact lift_movMemE hmode hρ hsd hsa hsize hpos hoff hmi hi hsc hpe hpl hrel hpb hld
      (hlo _ (operand_local_mem ha)) hlive'
      (bitCast_mem hs hk ha htd hta hwfd hwfa hnd hna h)
  | ptrCast hk ha hkd hka htd hta hsd hsa hsize hoff hmi =>
    rw [hbody] at htd hta
    exact lift_movMemE hmode hρ hsd hsa hsize (by decide) hoff hmi hi hsc hpe hpl hrel hpb hld
      (hlo _ (operand_local_mem ha)) hlive' (ptrCast_mem hs hk ha hkd hka htd hta h)

/-- `field`'s lift (any destination): a `mov` of `n` bytes from inside `_a`'s slot to `_d`'s.

Proof: `SimField`'s former `lift_field` with `sim_copyField`'s steps in place: `field_mem` for
L0; `readLocal_sub_inj` the read, `reenc_wf` and `BytesInj.of_le_trans` the bytes,
`FnRel.write_dst` the write, `opSem_mov_fwd` the step; `Hidden`/`ProvBounded` by
`bytesLeDefined_prov`. -/
theorem lift_field {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerField Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @field d a oa projs ta ty off n sd sa i ha hta hpath htd hn hpos hwf hsd hsa hsize hoff
      hmi =>
    rw [eval_use_place_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at hta htd
    obtain ⟨pd, pa, bs0, w, bsd, hpd, hpa, hlo0, hd, hen, hsto, hstk⟩ :=
      field_mem hs hta hpath htd hn h
    have hla : live _ = true := hlo _ (operandPlace?_mem ha)
    have hra := hrel.opnd hpa hsa hla
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    -- R's read refines L0's load, hence the stored re-encoding
    have hbl : bs0.length = n := load_length hlo0
    obtain ⟨ba, hrfa, hia⟩ := readLocal_sub_inj hrel.frame.mem hra hsize.2 hlo0
    have hle := reenc_wf hwf hn hbl hd hen
    obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
    rw [hbl] at hlend
    have hlenb : ba.length = n := (BytesInj.length hbs).symm.trans hlend
    have hlen0 : bsd.length = sd.size := by rw [hlend, hsize.1]
    -- R's write, to a private or an escaped `_d`
    obtain ⟨st', hwr, hesc, hmi', hrd, hoth⟩ := hrel.write_dst hld hpd hsd hpos' hbs hlen0 hsto
    have hop := opSem_mov_fwd (ch := ch) hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hlenb
      hwr
    have hsub := bytesLeDefined_prov hle
    -- `Hidden`: the stored provenance is the loaded bytes', which `Hidden` excludes
    have hhid := hrel.hidden.load hlo0
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hhid _ (List.getElem_mem hj) fr0 hf0
    -- the bound: likewise
    have hbd := hpb.load hlo0
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hbd _ (List.getElem_mem hj) fr0 hf0
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

end Ryo.Proofs.Lower
