/-
Ryo.Proofs.Lower.SimNiche — the simulation of `LowerNicheSwitch` (`Check/Lower/Niche.lean`,
M5b): a fused block's `_d = discriminant(_e)` of a niche-encoded enum and its `switchInt(_d)`,
two L0 steps, against R's `br.eq.imm` chain on the tag's bytes.

`sim_fusedNiche` has `sim_fused`'s shape (`SimFused.lean`: L0's first step matched by no R
step, `MatchMid`, then this second one), so `sim_fused` can dispatch to it; `niche_stmt_stack`
and `niche_live` are `fused_stmt_stack`'s and `fused_live`'s cases.

- L0: `discr_assign_inv` (SimEnum) and `readDiscr_multiple_inv` give the tag bytes at `_e`'s
  pointer plus the tag offset (unwrapped by `wrappingOffset_eq`, as in `lift_enumRead`), their
  bits `u` and `tagToVariant`'s variant `idx`, and the store of its discriminant to `_d`;
  `niche_switch_l0` the switch on the stored value: to `caseTarget cases otherwise (nicheBits
  vs discrTy t idx)`.
- R: the tag bytes are related (`readLocal_sub_inj`) so R reads `u` too; `nicheChain_run`, as
  `chain_run` (SimSwitch), walks the tests to a place `NicheHit` for `u`: `nicheAt_spec` for a
  tested value, `nicheRest_spec` for the others (`niche_idx`, and
  `tagForVariant_of_tagToVariant`: a value decoding to a niche variant is its tag).
- `FnRel` without `_d` (`FnRel.store_dead`, here so that `SimFused.lean` can import this file;
  `_d` dead at every successor, `hdead`).
-/
import Ryo.Proofs.Lower.SimEnum
import Ryo.Check.Lower.Niche

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Vm.OpSem Ryo.Check.Lower

/-- `FnRel` after an L0-only store of provenance-free bytes to a private local `c` that is
dead at the new liveness: R's state is unchanged.

Proof: `hrel.priv_dst hpc hsc hpos hpriv` gives `c`'s private allocation `ac`. `MemInj`: the
store changes only `ac` (`get?_store_other` elsewhere), which `ι` doesn't map. Locals: `c`
itself is `LocalRel.priv` with the stored allocation (`Memory.store_eq_ok`: same address,
size, liveness) and no bytes owed (`live' c = false` by `hw`); every other storage-live local by
`LocalRel.store_other` (provenance apart: `hrel.provNe`) and `LocalRel.weaken` (`hw`).
`Hidden`: `hrel.hidden.store_noprov hsto hnp`; the rest is unchanged. -/
theorem FnRel.store_dead {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 m0' : Memory} {s1 : RState} (hrel : FnRel Γ ι live f m0 s1) {c : Local}
    {pc : ThinPointer} {sc : LocalSlot} (hpc : f.locals[c]? = some (some pc))
    (hsc : Γ.slots[c]? = some sc) (hpos : 0 < sc.size)
    (hpriv : ∀ k < sc.size, Γ.escaped (sc.off + k) = false) {bs : List AbstractByte}
    (hsto : m0.store pc bs .one = .ok m0') (hnp : ∀ b ∈ bs, b.provFrag = none)
    (hw : ∀ l, live' l = true → live l = true ∧ l ≠ c) :
    FnRel Γ ι live' f m0' s1 := by
  obtain ⟨ac, xc, hpc', hιc, hxc, hlc, hac, hpac, hsc', hpvc⟩ :=
    hrel.priv_dst hpc hsc hpos hpriv
  have hmi : MemInj ι m0' s1.st.mem := by
    intro a b x hx hb
    have hne : pc.prov ≠ some a ∨ bs = [] := by
      left
      rw [hpc']
      intro he
      injection he with he
      subst he
      rw [hιc] at hb
      cases hb
    rw [get?_store_other hsto hne] at hx
    exact hrel.frame.mem a b x hx hb
  refine ⟨⟨hmi, ?_⟩, hrel.hidden.store_noprov hsto hnp, hrel.unaliased, hrel.provNe,
    hrel.apart, hrel.esc⟩
  intro l p hp hal
  obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
  refine ⟨slot, hsl, ?_⟩
  by_cases hl : l = c
  · rw [hl] at hp hsl ⊢
    have e : p = pc := Option.some.inj (Option.some.inj (hp.symm.trans hpc))
    subst e
    rw [hsc] at hsl
    obtain rfl := Option.some.inj hsl
    have hlf : live' c = false := by
      cases h : live' c
      · rfl
      · exact absurd rfl (hw c h).2
    rw [hlf]
    rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
      ⟨-, -, rfl⟩ | ⟨id, hid, -, -, hpid, -, -, -, -, hm0'⟩
    · exact .priv ac xc hpc' hιc hxc hlc hac hpac hsc' hpvc (fun h => by cases h)
    · have hai : ac = id := Option.some.inj (hpc'.symm.trans hpid)
      cases hai
      have hxa : m0.allocs[ac] = xc := by
        simp only [Memory.get?, Array.getElem?_eq_getElem hid, Option.some.injEq] at hxc
        exact hxc
      subst hxa
      have ha' : ac < m0'.allocs.size := by subst hm0'; simpa using hid
      have hgs : m0'.allocs[ac].live = m0.allocs[ac].live ∧
          m0'.allocs[ac].addr = m0.allocs[ac].addr ∧
          m0'.allocs[ac].data.size = m0.allocs[ac].data.size := by
        subst hm0'
        refine ⟨by simp, by simp, ?_⟩
        simp only [Array.getElem_set_self]
        rw [Ryo.Spec.Theorems.foldl_set_size]
      refine .priv ac m0'.allocs[ac] hpc' hιc ?_ (by rw [hgs.1]; exact hlc)
        (by rw [hgs.2.1]; exact hac) (by rw [hgs.2.1]; exact hpac)
        (by rw [hgs.2.2]; exact hsc') hpvc (fun h => by cases h)
      show m0'.allocs[ac]? = _
      exact Array.getElem?_eq_getElem ha'
  · exact (hr.store_other hsto (.inl (hrel.provNe c l pc p (Ne.symm hl) hpc hp))).weaken
      (fun h => (hw l h).1)


/-! ### L0 -/

/-- `readDiscriminant` of a `.multiple tag` enum, run to success: the tag bytes at the tag
offset, their bits, and the variant `tagToVariant` decodes them to.

Proof: as `discrDirect_mem` (SimEnum) up to `tagToVariant`, whatever the encoding. -/
theorem readDiscr_multiple_inv {mem : Memory} {pe : ThinPointer} {vs : List Spec.Variant}
    {discrTy : IntType} {tag : TagInfo} {esz : Nat} {eal : Align} {idx : Nat}
    (hrd : readDiscriminant mem pe (.enum vs discrTy (.multiple tag) esz eal) = .ok idx) :
    ∃ bs u, mem.load (pe.wrappingOffset tag.offset) tag.tag.size .one = .ok bs ∧
      decodeBits bs = some u ∧ tagToVariant vs discrTy tag u = .ok idx := by
  cases hsd : mem.signedDereferenceable pe tag.offset with
  | error x =>
    exfalso
    simp only [readDiscriminant, hsd, pure_bind, exE_ok_bind, exE_error_bind, exE_pure, exE_throw,
        exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false, Except.ok.injEq,
        reduceCtorEq] at hrd
  | ok u0 =>
    cases hld : mem.load (pe.wrappingOffset tag.offset) tag.tag.size .one with
    | error x =>
      exfalso
      simp only [readDiscriminant, hsd, hld, pure_bind, exE_ok_bind, exE_error_bind, exE_pure,
          exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
          Except.ok.injEq, reduceCtorEq] at hrd
    | ok bs =>
      cases hdb : decodeBits bs with
      | none =>
        exfalso
        simp only [readDiscriminant, hsd, hld, hdb, pure_bind, exE_ok_bind, exE_error_bind,
            exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
            Except.ok.injEq, reduceCtorEq] at hrd
      | some u =>
        cases htv : tagToVariant vs discrTy tag u with
        | error msg =>
          exfalso
          simp only [readDiscriminant, hsd, hld, hdb, htv, pure_bind, exE_ok_bind, exE_error_bind,
              exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true,
              exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
        | ok i =>
          have hi : i = idx := by
            cases hv : variantInhabited vs i
            · simp only [readDiscriminant, hsd, hld, hdb, htv, hv, pure_bind, exE_ok_bind,
                exE_error_bind, exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed,
                exE_ensure_true, exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
            · simp only [readDiscriminant, hsd, hld, hdb, htv, hv, pure_bind, exE_ok_bind,
                exE_error_bind, exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed,
                exE_ensure_true, exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
              first | exact hrd | exact hrd.symm
          subst hi
          exact ⟨bs, u, by first | rfl | exact hld, hdb, htv⟩

/-- A niche encoding decodes to the untagged variant or one below `lo + (hi - lo) + 1`.

Proof: unfold `tagToVariant` at the niche encoding: the tagged branch's `lo + rel` with
`rel ≤ hi - lo`, else `untagged`. -/
theorem niche_idx {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {u idx : Nat}
    {untagged lo hi st : Nat} (henc : tag.encoding = .niche untagged lo hi st)
    (h : tagToVariant vs discrTy tag u = .ok idx) :
    idx = untagged ∨ idx < lo + (hi - lo) + 1 := by
  unfold tagToVariant at h
  rw [henc] at h
  simp only at h
  split at h
  · split at h
    · cases h
    · rename_i hrel _
      have h' : lo + (u + tag.tag.modulus - st % tag.tag.modulus) % tag.tag.modulus = idx := by
        simpa using h
      right
      rw [← h']
      first
        | exact Nat.lt_succ_of_le (Nat.add_le_add_left hrel lo)
        | omega
  · split at h
    · cases h
    · left
      have h' : untagged = idx := by simpa using h
      exact h'.symm

/-- The switch on `_d` after the store of `X`'s bytes there: to `caseTarget` of `X`'s low
`t.size` bytes.

Proof: `switchInt_inv`; the load reads the stored bytes (`Memory.store_load_bytes`), which decode
to `X % 2 ^ (8 t.size)` (`decodeBits_encodeBits`); `switchBits` of the integer is its bits
(`IntType.toBits_ofBits`, `modulus_eq_two_pow`). -/
theorem niche_switch_l0 {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {dl : Local} {od : Operand}
    (hd : od.local? = some dl) {pd : ThinPointer} (hpd : f.locals[dl]? = some (some pd))
    {t : IntType} {vd : ValidRange} (htd : f.body.locals[dl]? = some (.int t vd))
    {m0 : Memory} {X : Nat} (hsto : m0.store pd (encodeBits t.size X) .one = .ok s.mem)
    {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    (h : runOn (evalTerminator (.switchInt od cases otherwise)) o s = (.ok (), s')) :
    s' = { s with stack :=
      { f with bb := caseTarget cases otherwise (X % 2 ^ (8 * t.size)), stmt := 0 } :: rest } := by
  obtain ⟨p, ty0, w, bits, hp, hty', hload, hsw, hs'⟩ := switchInt_inv hs hd h
  rw [hpd] at hp
  obtain rfl := Option.some.inj (Option.some.inj hp)
  rw [htd] at hty'
  obtain rfl := (Option.some.inj hty').symm
  obtain ⟨bs, u, hld, hdb, -, rfl⟩ := typedLoad_int hload
  have hl2 := Ryo.Spec.Theorems.Memory.store_load_bytes hsto
  rw [Ryo.Spec.Theorems.encodeBits_length] at hl2
  rw [hl2] at hld
  obtain rfl := Except.ok.inj hld
  rw [Ryo.Spec.Theorems.decodeBits_encodeBits] at hdb
  obtain rfl := Option.some.inj hdb
  have e : runOn (switchBits (.int (t.ofBits (X % 2 ^ (8 * t.size))), .int t vd)) o s =
      (.ok (t.toBits (t.ofBits (X % 2 ^ (8 * t.size)))), s) := rfl
  rw [e] at hsw
  obtain ⟨hb, -⟩ := prod_ok_inj hsw
  rw [Ryo.Spec.Theorems.IntType.toBits_ofBits, ← modulus_eq_two_pow, Nat.mod_mod] at hb
  subst hb
  subst hs'
  rfl

/-- `caseTarget` is one of the switch's successors. -/
theorem caseTarget_mem_termSuccs {d : Operand} {cases : List (Nat × BasicBlock)}
    {otherwise : BasicBlock} (x : Nat) :
    caseTarget cases otherwise x ∈ termSuccs (.switchInt d cases otherwise) := by
  simp only [termSuccs, List.mem_append, List.mem_map, List.mem_singleton]
  unfold caseTarget
  cases hf : cases.find? (·.1 == x) with
  | none => exact .inr rfl
  | some p => exact .inl ⟨p, List.mem_of_find?_eq_some hf, rfl⟩

/-! ### The check's meaning -/

/-- R index `pc` is the start of L0's target for every variant tag value `u` decodes to. -/
def NicheHit (Γ : TermCtx) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
    (vs : List Spec.Variant) (discrTy : IntType) (tag : TagInfo) (t : IntType) (u pc : Nat) :
    Prop :=
  ∀ idx, tagToVariant vs discrTy tag u = .ok idx →
    blockStart Γ (caseTarget cases otherwise (nicheBits vs discrTy t idx)) = some pc

theorem nicheAt_spec {Γ : TermCtx} {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {t : IntType} {u pc : Nat}
    (h : nicheAt Γ cases otherwise vs discrTy tag t u pc = true) :
    NicheHit Γ cases otherwise vs discrTy tag t u pc := by
  intro idx htv
  unfold nicheAt at h
  rw [htv] at h
  simpa [startOk] using h

/-- `nicheRest`'s meaning: `pc` is right for every tag value outside `ex`.

Proof: per the decoded variant `idx` (`niche_idx`): the untagged one by the first conjunct; else
`idx` is in the range, and `tagForVariant_of_tagToVariant` makes its tag `u` (not in `ex`) or
none: either way the range's conjunct at `idx` gives its target. -/
theorem nicheRest_spec {Γ : TermCtx} {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {t : IntType} {ex : List Nat}
    {pc u : Nat} (h : nicheRest Γ cases otherwise vs discrTy tag t ex pc = true)
    (hu : u < tag.tag.modulus) (hex : ex.contains u = false) :
    NicheHit Γ cases otherwise vs discrTy tag t u pc := by
  intro idx htv
  unfold nicheRest at h
  split at h
  next untagged lo hi st henc =>
    rw [Bool.and_eq_true] at h
    obtain ⟨hu0, hall⟩ := h
    rcases niche_idx henc htv with hi0 | hlt
    · subst hi0
      simpa [startOk] using hu0
    · have h1 := List.all_eq_true.mp hall idx (List.mem_range.mpr hlt)
      rcases Ryo.Spec.Theorems.tagForVariant_of_tagToVariant htv hu with hs | hn
      · rw [hs] at h1
        simp only [Bool.or_eq_true] at h1
        rcases h1 with h1 | h1
        · rw [hex] at h1; cases h1
        · simpa [startOk] using h1
      · rw [hn] at h1
        simpa [startOk] using h1
  next => cases h

/-! ### R's run -/

/-- R's run of a `nicheChain` chain, for the tag value `u` (R's tag bytes at slot `a`) not
among the tested values `ex`: to a place `NicheHit` for `u`, its state unchanged.

Proof: `chain_run`'s (SimSwitch), with `nicheAt_spec` where a test is taken (the value is
`u`, as `u` is below `2 ^ (8 n)`) and `nicheRest_spec` at the chain's end. -/
theorem nicheChain_run {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} (hmode : c.mode = Γ.mode)
    (hρ : c.ρ = Γ.ρ) {cases : List (Nat × BasicBlock)} {otherwise : BasicBlock}
    {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {t : IntType} {a : Int}
    {bs : List AbstractByte} {u : Nat} (hu : asNat bs = .ok u)
    (hlt : u < 2 ^ (8 * tag.tag.size)) :
    ∀ {ex : List Nat} {is : List Insn} {s1 : RState} {next : Nat},
      nicheChain Γ next cases otherwise vs discrTy tag t a ex is = true → TermAt c s1 next is →
      (∀ i ∈ is, PlainView c.mode c.ρ i) → s1.st.readFrame a tag.tag.size = .ok bs →
      ex.contains u = false →
      ∃ s2, StepsTo c ch s1 s2 ∧ NicheHit Γ cases otherwise vs discrTy tag t u s2.pc ∧
        s2.st = s1.st ∧ s2.fp = s1.fp := by
  have hum : u % 2 ^ (8 * tag.tag.size) = u := Nat.mod_eq_of_lt hlt
  have hmod : u < tag.tag.modulus := by rw [← modulus_eq_two_pow]; exact hlt
  intro ex is
  induction is generalizing ex with
  | nil =>
    intro s1 next hok hat _ _ hex
    refine ⟨s1, .refl _, ?_, rfl, rfl⟩
    have h := hat.hnext
    simp only [List.length_nil, Nat.add_zero] at h
    subst h
    simp only [nicheChain] at hok
    exact nicheRest_spec hok hmod hex
  | cons i tl ih =>
    intro s1 next hok hat hpl hrf hex
    obtain ⟨hi0, hs0⟩ := hat.head
    have hpli : PlainView c.mode c.ρ i := hpl i (List.mem_cons_self ..)
    simp only [nicheChain] at hok
    split at hok
    next a' y neg tg hb =>
      rw [Bool.and_eq_true] at hok
      obtain ⟨ha, hok⟩ := hok
      have ha' : a' = a := by simpa using ha
      rw [ha'] at hb
      obtain ⟨vw, tyS, r, hvw, hh, htyS, hops, hctl, hn, hk⟩ := brImmOps_spec hb
      obtain ⟨sg, hparse⟩ := intTyOk_spec htyS
      obtain ⟨k2, k3, k4, ho⟩ := operands4 hn hk
      rw [← hmode, ← hρ] at hvw
      have hfits := hpli.fits vw hvw
      rw [ho, hops] at hfits
      simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
        Bool.and_true, Bool.and_eq_true] at hfits
      obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
      have hop : opSem vw.op vw.ops s1.st ch =
          .ok (.branch (BitVec.ofNat (8 * tag.tag.size) u ==
            BitVec.ofNat (8 * tag.tag.size) y), s1.st) := by
        rw [hops]; exact opSem_brCmpImm_fwd hh hparse ho hfa hk2 hk3 hk4 hrf hu
      have hstep := step_branch hi0 hs0 hat.pe hpli hvw hctl hop
      rw [bv_ofNat_beq, hum] at hstep
      cases neg
      · -- a test without `neg`: taken on equality, else the rest of the chain
        simp only [Bool.false_eq_true, ↓reduceIte, Bool.and_eq_true, Bool.or_eq_true] at hok
        obtain ⟨hhit, hrest⟩ := hok
        by_cases hxy : u = y % 2 ^ (8 * tag.tag.size)
        · have hc : ((u == y % 2 ^ (8 * tag.tag.size)) != false) = true := by simp [hxy]
          simp only [hc, ↓reduceIte] at hstep
          have hH : NicheHit Γ cases otherwise vs discrTy tag t u tg := by
            rcases hhit with h | h
            · rw [← hxy, hex] at h; cases h
            · rw [← hxy] at h; exact nicheAt_spec h
          exact ⟨_, .cons hstep (.refl _), hH, rfl, rfl⟩
        · have hc : ((u == y % 2 ^ (8 * tag.tag.size)) != false) = false := by simp [hxy]
          simp only [hc, Bool.false_eq_true, ↓reduceIte] at hstep
          have hex' : (y % 2 ^ (8 * tag.tag.size) :: ex).contains u = false := by
            first
              | (rw [List.contains_cons, hex, Bool.or_false]; exact beq_eq_false_iff_ne.mpr hxy)
              | simp [hex, hxy]
          obtain ⟨s2, hst2, hhit2, hsst, hfp⟩ :=
            @ih (y % 2 ^ (8 * tag.tag.size) :: ex) { s1 with pc := s1.pc + 1 } next hrest
              hat.tail (fun j hj => hpl j (List.mem_cons_of_mem _ hj)) hrf hex'
          exact ⟨s2, .cons hstep hst2, hhit2, hsst, hfp⟩
      · -- the last test, with `neg`: falls through on equality, else branches
        simp only [↓reduceIte, Bool.and_eq_true, Bool.or_eq_true, List.isEmpty_iff] at hok
        obtain ⟨⟨htl, hhit⟩, hrest⟩ := hok
        subst htl
        by_cases hxy : u = y % 2 ^ (8 * tag.tag.size)
        · have hc : ((u == y % 2 ^ (8 * tag.tag.size)) != true) = false := by simp [hxy]
          simp only [hc, Bool.false_eq_true, ↓reduceIte] at hstep
          have hn' : s1.pc + 1 = next := by
            have h := hat.hnext
            simp only [List.length_cons, List.length_nil] at h
            omega
          have hH : NicheHit Γ cases otherwise vs discrTy tag t u next := by
            rcases hhit with h | h
            · rw [← hxy, hex] at h; cases h
            · rw [← hxy] at h; exact nicheAt_spec h
          rw [← hn'] at hH
          exact ⟨_, .cons hstep (.refl _), hH, rfl, rfl⟩
        · have hc : ((u == y % 2 ^ (8 * tag.tag.size)) != true) = true := by simp [hxy]
          simp only [hc, ↓reduceIte] at hstep
          have hex' : (y % 2 ^ (8 * tag.tag.size) :: ex).contains u = false := by
            first
              | (rw [List.contains_cons, hex, Bool.or_false]; exact beq_eq_false_iff_ne.mpr hxy)
              | simp [hex, hxy]
          exact ⟨_, .cons hstep (.refl _), nicheRest_spec hrest hmod hex', rfl, rfl⟩
    next hb =>
      rcases hj : jmpTo i with _ | tg
      · rw [hj] at hok
        cases tl <;> simp at hok
      · rw [hj] at hok
        cases tl with
        | cons _ _ => simp at hok
        | nil =>
          obtain ⟨op, f, rfl, hf, hsh⟩ := jmpTo_spec hj
          have hstep : R.step c s1 ch = .ok (.step { s1 with pc := tg }) := by
            rw [step_eq_stepBody_nil hi0 hs0, stepBody_jmp hf hsh]
          exact ⟨{ s1 with pc := tg }, .cons hstep (.refl _), nicheRest_spec hok hmod hex,
            rfl, rfl⟩

/-! ### The rule -/

/-- The statement leaves L0's stack as it is (`fused_stmt_stack`'s case). -/
theorem niche_stmt_stack {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerNicheSwitch Γ next st term is) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (h : runOn (evalStatement st) o s = (.ok (), s')) :
    s'.stack = s.stack := by
  cases hlow with
  | chain dl e od vs discrTy tag esz eal t vd sd se cs ow is hd hte htd hsd hse hsize hoff
      hpriv hok hdead =>
    rw [hbody] at hte htd
    obtain ⟨-, -, -, -, -, -, -, hstk⟩ := discr_assign_inv hs hte htd h
    exact hstk

/-- The statement kills `_d`, dead at every successor (`hdead`): `fused_live`'s `hkc` for the
rule. -/
theorem niche_kill {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerNicheSwitch Γ next st term is) {b' : Nat}
    (hsucc : b' ∈ termSuccs term) :
    ∃ c, stmtKill st = some c ∧ (computeLive Γ.body).get b' 0 c = false := by
  cases hlow with
  | chain dl e od vs discrTy tag esz eal t vd sd se cs ow is hd hte htd hsd hse hsize hoff
      hpriv hok hdead =>
    refine ⟨dl, rfl, ?_⟩
    have h := List.all_eq_true.mp hdead b' hsucc
    simpa using h

/-- `_d` is dead at every successor (`fused_live`'s case).

Proof: `niche_kill`; then `fused_live`'s end. -/
theorem niche_live {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerNicheSwitch Γ next st term is)
    (hlv : LiveSound Γ.body (computeLive Γ.body).get) {b : Nat} {bd : BlockData} {k : Nat}
    (hbd : Γ.body.blocks[b]? = some bd) (hst : bd.stmts[k]? = some st)
    (hlen : k + 1 = bd.stmts.length) (hterm : bd.term = term) {b' : Nat}
    (hsucc : b' ∈ termSuccs term) :
    ∀ l, (computeLive Γ.body).get b' 0 l = true →
      (computeLive Γ.body).get b k l = true ∧ stmtKill st ≠ some l := by
  obtain ⟨c, hkc, hcd⟩ := niche_kill hlow hsucc
  intro l hl
  have hne : stmtKill st ≠ some l := by
    rw [hkc]
    intro he
    injection he with he
    subst he
    rw [hcd] at hl
    cases hl
  refine ⟨?_, hne⟩
  have ht := (hlv.term b bd hbd).2 b' (by rw [hterm]; exact hsucc) l hl
  rw [← hlen] at ht
  exact (hlv.stmt b bd hbd k st hst).1 l ht hne

/-- A fused niche-discriminant switch (see the module comment), `sim_fused`'s statement.

Proof: L0's statement by `discr_assign_inv` and `readDiscr_multiple_inv`; the tag's address
unwrapped and R's tag bytes related as in `lift_enumRead`'s `discrDirect` case
(`load_eq_ok_pos`, `start_le`, `wrappingOffset_eq`, `readLocal_sub_inj`, `decodeBits_inj`);
`nicheChain_run` from the terminator's start, at L0's variant; L0's switch by
`niche_switch_l0`; the memory facts as `sim_fused`'s; `FnRel.store_dead` and `FnRel.congr`. -/
theorem sim_fusedNiche {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o0 o : Spec.Oracle} {s0 sx s s' : Spec.State}
    {f f1 : Spec.Frame} {rest rest1 : List Spec.Frame} (hs0 : s0.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {next : Nat} {st : Statement} {term : Terminator} {is : List Insn}
    (hlow : LowerNicheSwitch Γ next st term is) (hat : TermAt c s1 next is)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s0.mem s1) (hpb : ProvBounded s0.mem)
    (hlo : ∀ l ∈ stmtReads st, live l = true)
    (hw : ∀ l, live' l = true → live l = true ∧ stmtKill st ≠ some l)
    (h1 : runOn (evalStatement st) o0 s0 = (.ok (), sx)) (hsx : sx.stack = f1 :: rest1)
    (hs : s = { sx with stack := { f1 with stmt := f1.stmt + 1 } :: rest1 })
    (h2 : runOn (evalTerminator term) o s = (.ok (), s')) :
    ∃ s1' b', StepsTo c ch s1 s1' ∧ s'.stack = { f with bb := b', stmt := 0 } :: rest ∧
      b' ∈ termSuccs term ∧ blockStart Γ b' = some s1'.pc ∧ ProvBounded s'.mem ∧
      s'.mem.allocs.size = s0.mem.allocs.size ∧ MemKept s0.mem s'.mem ∧
      FnRel Γ.toStmtCtx ι live' { f with bb := b', stmt := 0 } s'.mem s1' := by
  cases hlow with
  | chain dl e od vs discrTy tag esz eal t vd sd se cs ow is hd hte htd hsd hse hsize hoff
      hpriv hok hdead =>
    rw [hbody] at hte htd
    obtain ⟨pd, pe, idx, hpd, hpe, hrd, hsto, hstk⟩ := discr_assign_inv hs0 hte htd h1
    obtain ⟨bs, u, hld, hdb, htv⟩ := readDiscr_multiple_inv hrd
    -- R's tag bytes
    have hle : live e = true := hlo e (by simp [stmtReads, rvalueLocals, placeLocals])
    have hre := hrel.opnd hpe hse hle
    have hn0 : tag.tag.size ≠ 0 := Nat.pos_iff_ne_zero.mp hsize.2.1
    obtain ⟨id, hid, hpid, -, hlo', -⟩ := load_eq_ok_pos hn0 hld
    have hle2 : pe.addr ≤ (pe.wrappingOffset tag.offset).addr :=
      start_le (q := pe.wrappingOffset tag.offset) hre rfl hid hpid hlo'
    have hoffNat : tag.offset < 2 ^ 64 := by
      have hA := offOk_spec hoff.1
      have hB := offOk_spec hoff.2
      try dsimp only [Size, Offset] at *
      omega
    rw [wrappingOffset_eq hoffNat hle2] at hld
    obtain ⟨ba, hrf, hia⟩ := readLocal_sub_inj hrel.frame.mem hre hsize.2.2 hld
    have hda := decodeBits_inj hia hdb
    have hva : asNat ba = .ok u := by unfold asNat; rw [hda]; rfl
    have hlt : u < 2 ^ (8 * tag.tag.size) := by
      have h0 := Ryo.Spec.Theorems.decodeBits_length hdb
      rw [load_length hld] at h0
      exact h0
    -- R's run
    obtain ⟨s2, hst2, hhit, hsst, hfp⟩ :=
      nicheChain_run (ch := ch) hmode hρ hva hlt (ex := []) hok hat hpl hrf rfl
    have hb := hhit idx htv
    -- L0's switch
    have hstk' : f :: rest = f1 :: rest1 := (hsx.symm.trans (hstk.trans hs0)).symm
    obtain ⟨rfl, rfl⟩ := List.cons.inj hstk'
    have hsS : s.stack = { f with stmt := f.stmt + 1 } :: rest := by rw [hs]
    have hstoS : s0.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
        (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))))) .one = .ok s.mem := by
      rw [hs]; exact hsto
    have hs2 := niche_switch_l0 (f := { f with stmt := f.stmt + 1 }) hsS hd hpd htd hstoS h2
    have hm' : s'.mem = sx.mem := by rw [hs2, hs]
    have hw' : ∀ l, live' l = true → live l = true ∧ l ≠ dl := fun l hl =>
      ⟨(hw l hl).1, fun e => (hw l hl).2 (by subst e; rfl)⟩
    refine ⟨s2, caseTarget cs ow (nicheBits vs discrTy t idx), hst2, ?_,
      caseTarget_mem_termSuccs _, hb, ?_, ?_, ?_, ?_⟩
    · rw [hs2]
      try rfl
    · rw [hm']; exact hpb.store_noprov hsto (encodeBits_noprov _ _)
    · rw [hm']; exact store_size hsto
    · rw [hm']; exact memKept_noprov hsto (encodeBits_noprov _ _)
    · rw [hm']
      exact (FnRel.store_dead hrel hpd hsd hsize.1 hpriv hsto (encodeBits_noprov _ _)
        hw').congr rfl rfl hsst hfp

end Ryo.Proofs.Lower
