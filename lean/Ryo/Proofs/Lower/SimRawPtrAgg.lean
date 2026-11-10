/-
Ryo.Proofs.Lower.SimRawPtrAgg — the lift of `LowerRawPtrAgg` (`Check/Lower/RawPtrAgg.lean`,
M5b): a raw pointer built from data pointer and metadata, written as two fields into `_d`'s
private slot and simulated by `SimAgg.lift_aggMem`.

The rule states R's side as `Agg.lean`'s fields, so all that is left is L0's (`rawPtrAgg_mem`,
giving `AggMem`): `aggFields_mapM` evaluates the two operands to `v0`, `v1` with their encodings
`e0`, `e1` at the field types (and `FieldMem`); at a thin pointer type `v0 = .ptr p` and
`e0 = encodePtr p.thin` (`thinPtr_encode`). The `rawPtr` case then picks the metadata by `_d`'s
kind:
- none: no metadata; `e1 = []` (the field is a ZST inside 8 bytes), the stored encoding is
  `encodePtr p.thin`;
- a length: the metadata type is `usize`, `v1 = .int i` and `e1 = encodeBits 8 i.toNat`
  (`usize_encode`, `usize_toBits`), stored as `encodePtr p.thin ++ e1`;
- a vtable: the metadata type a thin pointer, `v1 = .ptr vt`, `e1 = encodePtr vt.thin`.
In each case the stored bytes are `writeFields` of `[(0, e0), (8, e1)]` over `_d`'s size of
uninitialized bytes (`writeFields_pair`). `checkValue` only adds UB (`KeepPost`).
`lift_rawPtrAgg` hands it to `lift_aggMem`; `stmt_sim_rawPtrAgg` is `FnStep.stmt_sim`'s case.
-/
import Ryo.Proofs.Lower.SimDeref
import Ryo.Proofs.Lower.SimWide
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.RawPtrAgg

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Encodings -/

/-- A value encoded at a thin pointer type is a pointer, encoded as its thin part. -/
theorem thinPtr_encode {t : Spec.Ty} {v : Value} {e : List AbstractByte}
    (h : thinPtrTy t = true) (he : t.encode v = some e) :
    ∃ q : Pointer, v = .ptr q ∧ e = encodePtr q.thin := by
  cases t with
  | ptr pt r =>
    have hk : pt.metaKind = .none := by simpa [thinPtrTy] using h
    cases v with
    | ptr q =>
      simp only [Spec.Ty.encode, hk] at he
      cases hm : q.metadata with
      | none =>
        simp only [hm, Option.some.injEq] at he
        exact ⟨q, rfl, he.symm⟩
      | some md => simp [hm] at he
    | _ => simp [Spec.Ty.encode] at he
  | _ => simp [thinPtrTy] at h

/-- `usize`'s bits of a representable value are the value. -/
theorem usize_toBits {i : Int} (hc : IntType.canRepresent ⟨false, 8⟩ i = true) :
    IntType.toBits ⟨false, 8⟩ i = i.toNat := by
  have hc' : (0 : Int) ≤ i ∧ i ≤ 18446744073709551615 := by
    simpa [IntType.canRepresent, IntType.min, IntType.max, IntType.bits] using hc
  show (i % ((2 ^ 64 : Nat) : Int)).toNat = i.toNat
  have e : ((2 ^ 64 : Nat) : Int) = 18446744073709551616 := rfl
  rw [e, Int.emod_eq_of_lt hc'.1 (by omega)]

/-- A value encoded at `usize` is an integer, encoded as its 8 bytes. -/
theorem usize_encode {r : ValidRange} {v : Value} {e : List AbstractByte}
    (he : (Spec.Ty.int ⟨false, 8⟩ r).encode v = some e) :
    ∃ i : Int, v = .int i ∧ e = encodeBits 8 i.toNat := by
  cases v with
  | int i =>
    simp only [Spec.Ty.encode] at he
    split at he
    next hc =>
      simp only [Option.some.injEq] at he
      refine ⟨i, rfl, ?_⟩
      rw [← he, usize_toBits hc]
      try rfl
    next => cases he
  | _ => simp [Spec.Ty.encode] at he

/-- Two 8-byte fields at 0 and 8 over 16 uninitialized bytes. -/
theorem writeFields_pair {e0 e1 : List AbstractByte} (hl0 : e0.length = 8)
    (hl1 : e1.length = 8) :
    writeFields (List.replicate 16 AbstractByte.uninit) [(0, e0), (8, e1)] = e0 ++ e1 := by
  have hw1 : writeAt (List.replicate 16 AbstractByte.uninit) 0 e0 =
      e0 ++ List.replicate 8 AbstractByte.uninit := by
    simp [writeAt, hl0]
  show writeAt (writeAt (List.replicate 16 AbstractByte.uninit) 0 e0) 8 e1 = _
  rw [hw1]
  have hd : List.drop (8 + e1.length) (e0 ++ List.replicate 8 AbstractByte.uninit) = [] :=
    List.drop_eq_nil_of_le (by simp [hl0, hl1])
  unfold writeAt
  rw [List.take_left' hl0, hd, List.append_nil]

/-- An 8-byte field at 0 and an empty one at 8 over 8 uninitialized bytes. -/
theorem writeFields_thin {e0 : List AbstractByte} (hl0 : e0.length = 8) :
    writeFields (List.replicate 8 AbstractByte.uninit) [(0, e0), (8, [])] = e0 := by
  have hw1 : writeAt (List.replicate 8 AbstractByte.uninit) 0 e0 = e0 := by
    simp [writeAt, hl0]
  show writeAt (writeAt (List.replicate 8 AbstractByte.uninit) 0 e0) 8 [] = _
  rw [hw1]
  simp [writeAt]

/-! ### L0 -/

/-- L0's `_d = aggregate rawPtr ops`, as `AggMem` of the two fields.

Proof: as `agg_mem` up to the rvalue, which is `ops.mapM … >>= _` (the binding's continuation
left to unification); `aggFields_mapM` for the operands (two values, two encodings);
`thinPtr_encode` for the data; the `rawPtr` match reduces (`dsimp`) to the metadata's choice
and the `checkValue` tail, which returns `.ptr ⟨p.thin, m⟩` keeping the state (`KeepPost`); by
cases on `_d`'s metadata kind the choice and the encoding (see the module doc). -/
theorem rawPtrAgg_mem {Γ : StmtCtx} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {ops : List Operand} {ptd : PtrType} {vd : ValidRange} {t0 t1 : Spec.Ty}
    {sd : LocalSlot} {srcs : List AggSrc}
    (htd : Γ.body.locals[d]? = some (.ptr ptd vd))
    (hsz : (Spec.Ty.ptr ptd vd).size? = some sd.size)
    (h0 : thinPtrTy t0 = true) (h1 : rawPtrMetaOk ptd.metaKind t1 = true)
    (hf : AggFields Γ sd ops (rawPtrFields t0 t1) srcs)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.aggregate .rawPtr ops))) o s = (.ok (), s')) :
    AggMem f d sd.size (rawPtrFields t0 t1) srcs s s' := by
  have e : evalStatement (.assign ⟨d, []⟩ (.aggregate .rawPtr ops)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.aggregate .rawPtr ops) ty' >>= fun v =>
          placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1', h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1'
  obtain ⟨pd, td, hld, htd', hx, hs1⟩ := runOn_localPlace_ok hs h1'
  subst hx
  have h2' : runOn (evalRvalue (.aggregate .rawPtr ops) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  rw [hbody] at htd
  obtain rfl : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  -- the operands
  obtain ⟨vals, s3, h5, h6⟩ :=
    runOn_bind_ok (x := ops.mapM fun o => do pure (← evalOperand o).1) h3
  obtain ⟨hs5, ebs, hl1, hl2, hl3, hall, hfms, hbds⟩ := aggFields_mapM hs hbody hf h5
  rcases vals with _ | ⟨v0, _ | ⟨v1, _ | ⟨v2, vals⟩⟩⟩
  all_goals first | (simp at hl2; done) | (simp at hl2; omega) | skip
  rcases ebs with _ | ⟨e0, _ | ⟨e1, _ | ⟨e2, ebs⟩⟩⟩
  all_goals first | (simp at hl1; done) | (simp at hl1; omega) | skip
  have he0 : t0.encode v0 = some e0 := hall 0 (by simp) (by simp) (by simp)
  have he1 : t1.encode v1 = some e1 := hall 1 (by simp) (by simp) (by simp)
  have hb1 : 8 + e1.length ≤ sd.size := hbds 1 (by simp) (by simp)
  obtain ⟨p, rfl, rfl⟩ := thinPtr_encode h0 he0
  have hl0 : (encodePtr p.thin).length = 8 := Ryo.Spec.Theorems.encodePtr_length _
  -- the `rawPtr` case, by `_d`'s kind (the match on it takes the `checkValue` tail into its
  -- branches): the metadata's `pure`, then the tail, which returns `.ptr ⟨p.thin, m⟩`
  generalize hk : ptd.metaKind = kd at h1
  have key : ∃ m, v = .ptr ⟨p.thin, m⟩ ∧ s2 = s3 ∧
      (Spec.Ty.ptr ptd vd).encode (.ptr ⟨p.thin, m⟩) = some (writeFields (List.replicate sd.size AbstractByte.uninit)
        [(0, encodePtr p.thin), (8, e1)]) := by
    cases kd with
    | none =>
      first | simp only [hk] at h6 | rw [hk] at h6
      try dsimp only at h6
      obtain ⟨m, s4, h7, h8⟩ := runOn_bind_ok h6
      obtain ⟨rfl, rfl⟩ := runOn_pure_inv h7
      obtain ⟨hs6, hv⟩ := KeepPost.run (P := fun w : Value => w = .ptr ⟨p.thin, none⟩) h8
        (by
          repeat
            first
              | exact KeepPost.getMem'
              | exact KeepPost.liftE'
              | exact KeepPost.pure' rfl
              | apply KeepPost.bind'
              | intro _
              | dsimp only)
      have hN : sd.size = 8 := Option.some.inj (hsz.symm.trans (size?_ptr_thin hk))
      have he1n : e1 = [] := List.eq_nil_of_length_eq_zero (by omega)
      subst he1n
      refine ⟨none, hv, hs6, ?_⟩
      rw [hN, writeFields_thin hl0]
      simp [Spec.Ty.encode, hk]
    | elementCount =>
      cases t1 with
      | int it r =>
        have hit : it = ⟨false, 8⟩ := by simpa [rawPtrMetaOk] using h1
        subst hit
        obtain ⟨i, rfl, rfl⟩ := usize_encode he1
        first | simp only [hk] at h6 | rw [hk] at h6
        try dsimp only at h6
        obtain ⟨m, s4, h7, h8⟩ := runOn_bind_ok h6
        obtain ⟨rfl, rfl⟩ := runOn_pure_inv h7
        obtain ⟨hs6, hv⟩ := KeepPost.run
          (P := fun w : Value => w = .ptr ⟨p.thin, some (.elementCount i.toNat)⟩) h8
          (by
          repeat
            first
              | exact KeepPost.getMem'
              | exact KeepPost.liftE'
              | exact KeepPost.pure' rfl
              | apply KeepPost.bind'
              | intro _
              | dsimp only)
        have hk' : ptd.metaKind ≠ .none := by rw [hk]; decide
        have hN : sd.size = 16 := Option.some.inj (hsz.symm.trans (size?_ptr_wide hk'))
        refine ⟨_, hv, hs6, ?_⟩
        rw [hN, writeFields_pair hl0 (Ryo.Spec.Theorems.encodeBits_length 8 _)]
        simp [Spec.Ty.encode, hk]
      | _ => simp [rawPtrMetaOk] at h1
    | vtablePointer tr =>
      have h1' : thinPtrTy t1 = true := by simpa [rawPtrMetaOk] using h1
      obtain ⟨vt, rfl, rfl⟩ := thinPtr_encode h1' he1
      first | simp only [hk] at h6 | rw [hk] at h6
      try dsimp only at h6
      obtain ⟨m, s4, h7, h8⟩ := runOn_bind_ok h6
      obtain ⟨rfl, rfl⟩ := runOn_pure_inv h7
      obtain ⟨hs6, hv⟩ := KeepPost.run
        (P := fun w : Value => w = .ptr ⟨p.thin, some (.vtablePointer vt.thin)⟩) h8
        (by
          repeat
            first
              | exact KeepPost.getMem'
              | exact KeepPost.liftE'
              | exact KeepPost.pure' rfl
              | apply KeepPost.bind'
              | intro _
              | dsimp only)
      have hk' : ptd.metaKind ≠ .none := by rw [hk]; intro h; cases h
      have hN : sd.size = 16 := Option.some.inj (hsz.symm.trans (size?_ptr_wide hk'))
      refine ⟨_, hv, hs6, ?_⟩
      rw [hN, writeFields_pair hl0 (Ryo.Spec.Theorems.encodePtr_length _)]
      simp [Spec.Ty.encode, hk]
  obtain ⟨m, rfl, hs6, hen⟩ := key
  have hst' : typedStore s.mem pd (.ptr ⟨p.thin, m⟩) (.ptr ptd vd) .one = .ok mem' := by
    rw [← hs5, ← hs6]
    exact hst
  obtain ⟨bs, he, hsto⟩ := typedStore_inv hst'
  obtain rfl : bs = _ := Option.some.inj (he.symm.trans hen)
  refine ⟨pd, [encodePtr p.thin, e1], hld, hl3, rfl, hfms, hbds, ?_, ?_⟩
  · rw [hs']
    exact hsto
  · rw [hs']
    show s2.stack = s.stack
    rw [hs6, hs5]

/-! ### The lift -/

/-- `LowerRawPtrAgg`'s lift: R runs the statement's `is.length` field pieces.

Proof: `rawPtrAgg_mem`, then `lift_aggMem` (as `lift_agg`'s `agg` case: a `.slot` source is
an operand's local, read by the rvalue, so live by `hlo`). -/
theorem lift_rawPtrAgg {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerRawPtrAgg Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | mk htd hsz hsd hoff hpriv h0 h1 hf hpo =>
    have hmm := rawPtrAgg_mem hs hbody htd hsz h0 h1 hf h
    refine lift_aggMem hmode hρ hsd hoff hpriv hf hpo hi hsc hpe hpl hrel hpb ?_ hlive' hmm
    intro src hsrc a so ws he
    apply hlo
    have := aggFields_slot_mem hf src hsrc a so ws he
    simpa [rvalueLocals] using this

/-- `LowerRawPtrAgg` in a scope-free function: `stmt_sim`'s case (as its `castMore` case). -/
theorem stmt_sim_rawPtrAgg {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerRawPtrAgg Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    cases h; exact ⟨_, _, rfl⟩
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hlen := rangeInsns_length (r := r) h2
  have hi : ∀ j (hj : j < (rangeInsns c.d r).length),
      c.d.insns[s1.pc + j]? = some ((rangeInsns c.d r)[j]'hj) := by
    rw [hpc0]; exact rangeInsns_at h2
  have hsc : ∀ j, j < (rangeInsns c.d r).length → c.scopesAt (s1.pc + j) = [] :=
    fun _ _ => scopesAt_nil hfn.noScopes _
  have hpl : ∀ i ∈ rangeInsns c.d r, PlainView c.mode c.ρ i := by
    intro i hmem
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hmem
    rw [hmode, hρ]
    exact hfn.plain _ _ (hi j hj)
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  refine stmtOut_of_liftN (k := (rangeInsns c.d r).length) M.stack hfn.storage M.hbd hst M.sl
    M.fresh M.dinv (by rw [hpc0, hlen]; omega) ?_
  exact lift_rawPtrAgg M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb hl2
    hl1 hev

end Ryo.Proofs.Lower
