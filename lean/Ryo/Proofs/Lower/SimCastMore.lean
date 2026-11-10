/-
Ryo.Proofs.Lower.SimCastMore — the lift of `LowerCastMore` (`Check/Lower/CastMore.lean`, M5b):
array-to-slice unsizing and transmutes of scalar constants, as field writes into `_d`'s private
slot simulated by `SimAgg.lift_aggMem`.

The rules state R's side as `Agg.lean`'s fields and pieces (`AggFields`, `piecesOk` of
`aggPieces`), so all that is left is L0's: its store is `AggMem` of those fields.
- `unsizeLen_mem`: `assign_cast_inv` and the operand's load (a thin pointer `tp` decoded from
  8 bytes `bs0`, `decode_ptr_thin_inv`); the cast is `pure (.ptr ⟨tp, some (.elementCount n)⟩)`
  (`evalCast_unsizeLen_ok`); the store at the slice pointer type writes `encodePtr tp ++
  encodeBits 8 n` (`Spec.Ty.encode`), which is `writeFields` of the two fields over 16
  uninitialized bytes. The first field's bytes are below `bs0` (`ptr_reenc_le`), the second are
  the length's `encodeBits` (`bytesLeDefined_refl`).
- `transmuteConst_mem`: as `SimCopy.bitCast_mem` with the constant's bytes (`encodeBits n bits`,
  `runOn_evalOperand_const_dec`) in place of a load: two re-encodings, each below its bytes
  (`encode_decode_le`), give the stored bytes below `encodeBits n bits`, the one `.imm` field.
`lift_castMore` hands both to `lift_aggMem`; `stmt_sim_castMore` is `FnStep.stmt_sim`'s case
(as its `agg` case: `stmtOut_of_liftN` over the statement's range).
-/
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.CastMore

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### L0: the unsizing -/

/-- `unsizeValue` of a pointer between pointer types with a length: the length attached. -/
theorem unsizeValue_length_ptr (n fuel : Nat) (p : Pointer) (pa pd : PtrType)
    (va vd : ValidRange) :
    unsizeValue (.length n) (fuel + 1) (.ptr p) (.ptr pa va) (.ptr pd vd) =
      pure (.ptr ⟨p.thin, some (.elementCount n)⟩) := by
  first
    | rfl
    | (rw [unsizeValue]; rfl)
    | simp [unsizeValue]

/-- The array-to-slice unsizing of a thin pointer attaches the length. -/
theorem evalCast_unsizeLen_ok {n : Nat} {tp : ThinPointer} {pta ptd : PtrType}
    {va vd : ValidRange} {o : Spec.Oracle} {s s2 : Spec.State} {w : Value}
    (h : runOn (evalCast (.pointerCoercion (.unsize (.length n))) (Value.ptr ⟨tp, none⟩,
      Spec.Ty.ptr pta va) (.ptr ptd vd)) o s = (.ok w, s2)) :
    w = .ptr ⟨tp, some (.elementCount n)⟩ ∧ s2 = s := by
  have e : evalCast (.pointerCoercion (.unsize (.length n))) (Value.ptr ⟨tp, none⟩,
      Spec.Ty.ptr pta va) (.ptr ptd vd) =
      unsizeValue (.length n) 64 (.ptr ⟨tp, none⟩) (.ptr pta va) (.ptr ptd vd) := by
    first | rfl | simp [evalCast]
  have e2 : unsizeValue (.length n) 64 (.ptr ⟨tp, none⟩) (.ptr pta va) (.ptr ptd vd) =
      (pure (Value.ptr ⟨tp, some (.elementCount n)⟩) : SemM Value) :=
    unsizeValue_length_ptr n 63 ⟨tp, none⟩ pta ptd va vd
  rw [e, e2] at h
  exact runOn_pure_inv h

/-- The bytes of the unsizing's two fields written over 16 uninitialized bytes. -/
theorem writeFields_unsizeLen (tp : ThinPointer) (n : Nat) :
    writeFields (List.replicate 16 AbstractByte.uninit)
      [(0, encodePtr tp), (8, encodeBits 8 n)] = encodePtr tp ++ encodeBits 8 n := by
  have hl0 : (encodePtr tp).length = 8 := Ryo.Spec.Theorems.encodePtr_length tp
  have hl1 : (encodeBits 8 n).length = 8 := Ryo.Spec.Theorems.encodeBits_length 8 n
  have hw1 : writeAt (List.replicate 16 AbstractByte.uninit) 0 (encodePtr tp) =
      encodePtr tp ++ List.replicate 8 AbstractByte.uninit := by
    simp [writeAt, hl0]
  show writeAt (writeAt (List.replicate 16 AbstractByte.uninit) 0 (encodePtr tp)) 8
    (encodeBits 8 n) = _
  rw [hw1]
  have hd : List.drop (8 + (encodeBits 8 n).length)
      (encodePtr tp ++ List.replicate 8 AbstractByte.uninit) = [] :=
    List.drop_eq_nil_of_le (by simp [hl0, hl1])
  unfold writeAt
  rw [List.take_left' hl0, hd, List.append_nil]

/-- `unsizeLen`'s L0 side: the store is the two fields' bytes. -/
theorem unsizeLen_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand} {n N : Nat}
    {ptd pta : PtrType} {vd va : ValidRange} {so : Int} (ha : oa.local? = some a)
    (hkd : ptd.metaKind = .elementCount) (hka : pta.metaKind = .none)
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hta : f.body.locals[a]? = some (.ptr pta va))
    (hN : N = 16)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.cast (.pointerCoercion (.unsize (.length n))) oa (.ptr ptd vd)))) o s = (.ok (), s')) :
    AggMem f d N (unsizeLenFields (.ptr pta va)) (unsizeLenSrcs a so n) s s' := by
  subst hN
  rw [eval_cast_norm ha] at h
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  obtain ⟨pa, ta', v0, hpa, hta', hla, hr, hs1⟩ := runOn_evalOperand_copy hs hev
  subst r
  subst s1
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = .ptr pta va := Option.some.inj (hta'.symm.trans hta)
  rw [e4] at hst
  rw [e5] at hla hca
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv (size?_ptr_thin hka) hla
  obtain ⟨tp, hlen0, hdp, hv⟩ := decode_ptr_thin_inv hka hd0
  subst v0
  obtain ⟨hw, hs2⟩ := evalCast_unsizeLen_ok hca
  subst w
  subst s2
  subst s'
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have he' : bsd = encodePtr tp ++ encodeBits 8 n := by
    simp [Spec.Ty.encode, hkd] at hen
    first | exact hen.symm | exact hen
  have hl0 : (encodePtr tp).length = 8 := Ryo.Spec.Theorems.encodePtr_length tp
  have hl1 : (encodeBits 8 n).length = 8 := Ryo.Spec.Theorems.encodeBits_length 8 n
  have hw' : writeFields (List.replicate 16 AbstractByte.uninit)
      (((unsizeLenFields (.ptr pta va)).map (·.1)).zip [encodePtr tp, encodeBits 8 n]) = bsd := by
    rw [he']
    exact writeFields_unsizeLen tp n
  refine ⟨pd, [encodePtr tp, encodeBits 8 n], hpd, rfl, rfl, ?_, ?_, ?_, rfl⟩
  · intro j h1 h2
    rcases j with _ | _ | j
    · show ∃ pa bs0, f.locals[a]? = some (some pa) ∧
        s.mem.load pa ([8] : List Nat).sum .one = .ok bs0 ∧
        bytesLeDefined (encodePtr tp) bs0 = true
      exact ⟨pa, bs0, hpa, (by first | exact hlo | simpa using hlo), ptr_reenc_le hlen0 hdp⟩
    · show bytesLeDefined (encodeBits 8 n) (encodeBits 8 n) = true
      exact Ryo.Spec.bytesLeDefined_refl _
    · exfalso
      have : (unsizeLenSrcs a so n).length = 2 := rfl
      omega
  · intro j h1 h2
    rcases j with _ | _ | j
    · show 0 + (encodePtr tp).length ≤ 16
      rw [hl0]; omega
    · show 8 + (encodeBits 8 n).length ≤ 16
      rw [hl1]; omega
    · exfalso
      have : (unsizeLenFields (.ptr pta va)).length = 2 := rfl
      omega
  · rw [hw']
    exact hsto

/-! ### L0: the transmuted constant -/

/-- `transmuteConst`'s L0 side: the store is one field's bytes, below the constant's. -/
theorem transmuteConst_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {k : CastKind}
    {bits n N : Nat} {tc ty : Spec.Ty} (hk : bitCastKind k = true)
    (htd : f.body.locals[d]? = some ty) (hwfc : tc.wf = true) (hnc : tc.size? = some n)
    (hwf : ty.wf = true) (hn : ty.size? = some n) (hN : ty.size? = some N)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k (.const (.scalar bits) tc) ty))) o s =
      (.ok (), s')) :
    AggMem f d N [(0, ty)] [.imm n bits] s s' := by
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  obtain ⟨v0, t0⟩ := r
  obtain ⟨hd0, hr2, hs1⟩ := runOn_evalOperand_const_dec hev rfl
  have hd0' : tc.decode (encodeBits tc.size bits) = some v0 := hd0
  have hr2' : t0 = tc := hr2
  subst t0
  subst s1
  have e4 : td = ty := Option.some.inj (htd'.symm.trans htd)
  rw [e4] at hst
  have e3 : evalCast k (v0, tc) ty =
      (SemM.getMem >>= fun m => SemM.liftE (transmute m v0 tc ty)) := by
    cases k <;> first | rfl | (cases hk; done) | simp [bitCastKind] at hk
  rw [e3] at hca
  obtain ⟨m, s3, h7, h8⟩ := runOn_bind_ok hca
  rw [runOn_getMem] at h7
  obtain ⟨hm, hs3⟩ := prod_ok_inj h7
  subst m
  subst s3
  obtain ⟨htr, hs2⟩ := runOn_liftE_ok h8
  subst s2
  subst s'
  obtain ⟨bs1, hen1, hdec1⟩ := transmute_bytes htr
  obtain ⟨bsd, hen2, hsto⟩ := typedStore_inv hst
  have hl0 : (encodeBits tc.size bits).length = tc.size :=
    Ryo.Spec.Theorems.encodeBits_length _ _
  obtain ⟨bs1', he1', hle1⟩ := Ryo.Spec.Theorems.encode_decode_le tc _ v0 hwfc hl0 hd0'
  have e6 : bs1' = bs1 := Option.some.inj (he1'.symm.trans hen1)
  rw [e6] at hle1
  have hl1 : bs1.length = ty.size :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle1).1.trans
      (hl0.trans ((tySize_of hnc).trans (tySize_of hn).symm))
  obtain ⟨bsd', he2', hle2⟩ := Ryo.Spec.Theorems.encode_decode_le ty bs1 w hwf hl1 hdec1
  have e7 : bsd' = bsd := Option.some.inj (he2'.symm.trans hen2)
  rw [e7] at hle2
  have hle : bytesLeDefined bsd (encodeBits n bits) = true := by
    rw [← tySize_of hnc]
    exact bytesLe_trans hle2 hle1
  have hbl : bsd.length = N :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle2).1.trans (hl1.trans (tySize_of hN))
  have hw' : writeFields (List.replicate N AbstractByte.uninit)
      ((([(0, ty)] : List (Nat × Spec.Ty)).map (·.1)).zip [bsd]) = bsd := by
    show writeAt _ 0 bsd = bsd
    simp [writeAt, hbl]
  refine ⟨pd, [bsd], hpd, rfl, rfl, ?_, ?_, ?_, rfl⟩
  · intro j h1 h2
    cases j with
    | zero => exact hle
    | succ j => simp at h1
  · intro j h1 h2
    cases j with
    | zero => show 0 + bsd.length ≤ N; omega
    | succ j => simp at h1
  · rw [hw']
    exact hsto

/-! ### The lift -/

/-- `LowerCastMore`'s lift: R runs the statement's `is.length` instructions.

Proof: `cases hlow`. `unsizeLen`: `unsizeLen_mem` (types through `hbody`), then `lift_aggMem`;
the one `.slot` source is `_a`, in `ops.flatMap operandLocals` (`aggFields_slot_mem`) through
`oa` (the length's constant has no locals), which `hlo` makes live (`rvalueLocals` of a cast is
its operand's). `transmuteConst`: `cases hf` for the field's type facts, `transmuteConst_mem`,
then `lift_aggMem` with the one field (`aggPieces_single`); no `.slot` source. -/
theorem lift_castMore {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerCastMore Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | unsizeLen ha hkd hka htd hta hsd hsz hoff hpriv hf hpo =>
    rw [hbody] at htd hta
    refine lift_aggMem hmode hρ hsd hoff hpriv hf hpo hi hsc hpe hpl hrel hpb ?_ hlive'
      (unsizeLen_mem hs ha hkd hka htd hta hsz h)
    intro src hsrc a' so' ws he
    obtain ⟨op, hop, hm⟩ := List.mem_flatMap.mp (aggFields_slot_mem hf src hsrc a' so' ws he)
    apply hlo
    simp only [unsizeLenOps, List.mem_cons, List.not_mem_nil, or_false] at hop
    rcases hop with rfl | rfl
    · exact hm
    · simp [operandLocals] at hm
  | transmuteConst hk htd hwfc hnc hsd hsz hoff hpriv hf hpo =>
    rw [hbody] at htd
    have hf' := hf
    cases hf' with
    | imm hwf hn hpos hin =>
      have hmm := transmuteConst_mem hs hk htd hwfc hnc hwf hn hsz h
      refine lift_aggMem hmode hρ hsd hoff hpriv (AggFields.cons hf AggFields.nil)
        (by rw [aggPieces_single]; exact hpo) hi hsc hpe hpl hrel hpb ?_ hlive' hmm
      intro src hsrc a' so' ws he
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hsrc
      subst hsrc
      cases he

/-- `LowerCastMore` in a scope-free function: `stmt_sim`'s case (as its `agg` case). -/
theorem stmt_sim_castMore {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerCastMore Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    cases h <;> exact ⟨_, _, rfl⟩
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
  exact lift_castMore M.stack M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb hl2 hl1
    hev

end Ryo.Proofs.Lower
