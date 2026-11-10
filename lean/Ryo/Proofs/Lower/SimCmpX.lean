/-
Ryo.Proofs.Lower.SimCmpX — the simulation of `LowerCmpX` (`Check/Lower/CmpX.lean`, M5b):
comparisons of thin pointers or `char`s between whole locals, one unsigned `cmp`.

- L0 loads (`typedLoad_u`): each operand's `n` bytes decode to the bits `u` (`decodeBits`), the
  value being a pointer with address `u` and no metadata (`decode_ptr_thin_inv`,
  `decodePtr_eq`) or the `char` `.int u`; `UVal` says which.
- L0's comparison (`eval_ucmp`): `evalBinOp` takes the pointer or `char` case, `relResult` on
  `comparePtr` (address, then the equal metadata keys: `Ordering.then_eq`) or on `compare` of
  the code points, which is `compare` of the bits as integers (`compare_natCast`); `rel_ucmp`
  turns that into `intCmp` unsigned on `BitVec.ofNat (8 * n)` (the bits are below `2 ^ (8 * n)`,
  `decodeBits_lt`), by `SimCmp`'s `bv_rel` and `compare_rel`.
- R: as `SimCmp.lift_cmp`'s `reg` case (`opSem_cmp_fwd`, `FnRel.write_dst`).
-/
import Ryo.Proofs.Lower.SimCmp
import Ryo.Check.Lower.CmpX

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Arithmetic -/

/-- `compare` of two naturals cast to integers. -/
theorem compare_natCast (a b : Nat) : compare (a : Int) (b : Int) = compare a b := by
  rcases Nat.lt_trichotomy a b with h | h | h
  · rw [Int.compare_eq_lt.mpr (by omega), Nat.compare_eq_lt.mpr h]
  · subst h
    rw [Int.compare_eq_eq.mpr rfl, Nat.compare_eq_eq.mpr rfl]
  · rw [Int.compare_eq_gt.mpr (by omega), Nat.compare_eq_gt.mpr h]

/-- `relResult` of the integer order of two bit patterns below `2 ^ (8 * n)` is `intCmp`
unsigned on them (any handler signedness for `==`/`!=`).

Proof: as `cmp_eval`'s integer case with `x, y` the patterns themselves (`BitVec.toNat_ofNat`,
`Nat.mod_eq_of_lt`): `bv_rel false` and `compare_rel`, then per operator. -/
theorem rel_ucmp {op : BinOp} {o : String} (hop : cmpOp op = some o) {sg : Bool}
    (hsg : (o = "==" ∨ o = "!=") ∨ sg = false) {n ua ub : Nat}
    (hua : ua < 2 ^ (8 * n)) (hub : ub < 2 ^ (8 * n)) :
    ∃ res, intCmp o sg (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub) = .ok res ∧
      relResult op (some (compare (ua : Int) (ub : Int))) .bool = pure (.bool res) := by
  have hx : (ua : Int) = ((BitVec.ofNat (8 * n) ua).toNat : Int) := by
    rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hua]
  have hy : (ub : Int) = ((BitVec.ofNat (8 * n) ub).toNat : Int) := by
    rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hub]
  generalize BitVec.ofNat (8 * n) ua = A at hx ⊢
  generalize BitVec.ofNat (8 * n) ub = B at hy ⊢
  generalize (ua : Int) = x at hx ⊢
  generalize (ub : Int) = y at hy ⊢
  obtain ⟨hE, hL, hLe⟩ := bv_rel false A B hx hy
  obtain ⟨-, hG, hGe⟩ := bv_rel false B A hy hx
  have hL' : A.ult B = decide (x < y) := hL
  have hLe' : A.ule B = decide (x ≤ y) := hLe
  have hG' : B.ult A = decide (y < x) := hG
  have hGe' : B.ule A = decide (y ≤ x) := hGe
  obtain ⟨c1, c2, c3, c4, c5, c6⟩ := compare_rel x y
  cases op <;> simp [cmpOp] at hop <;> subst hop
  all_goals first
    | (refine ⟨_, rfl, ?_⟩
       show (pure (Value.bool (some (compare x y) == some Ordering.eq)) : SemM Value) =
         pure (Value.bool (A == B))
       rw [hE, c1])
    | (refine ⟨_, rfl, ?_⟩
       show (pure (Value.bool (some (compare x y) != some Ordering.eq)) : SemM Value) =
         pure (Value.bool (!(A == B)))
       rw [hE, c2])
    | (obtain rfl : sg = false := hsg.resolve_left (by simp)
       refine ⟨_, rfl, ?_⟩
       show (pure (Value.bool (some (compare x y) == some Ordering.lt)) : SemM Value) =
         pure (Value.bool (A.ult B))
       rw [hL', c3])
    | (obtain rfl : sg = false := hsg.resolve_left (by simp)
       refine ⟨_, rfl, ?_⟩
       show (pure (Value.bool (some (compare x y) == some Ordering.lt ||
           some (compare x y) == some Ordering.eq)) : SemM Value) =
         pure (Value.bool (A.ule B))
       rw [hLe', c4])
    | (obtain rfl : sg = false := hsg.resolve_left (by simp)
       refine ⟨_, rfl, ?_⟩
       show (pure (Value.bool (some (compare x y) == some Ordering.gt)) : SemM Value) =
         pure (Value.bool (B.ult A))
       rw [hG', c5])
    | (obtain rfl : sg = false := hsg.resolve_left (by simp)
       refine ⟨_, rfl, ?_⟩
       show (pure (Value.bool (some (compare x y) == some Ordering.gt ||
           some (compare x y) == some Ordering.eq)) : SemM Value) =
         pure (Value.bool (B.ule A))
       rw [hGe', c6])

/-! ### L0 -/

/-- The value of a thin pointer or `char` operand whose bytes denote `u`. -/
def UVal : Spec.Ty → Nat → Value → Prop
  | .char, u, v => v = .int u
  | _, u, v => ∃ pr, v = .ptr ⟨⟨u, pr⟩, none⟩

/-- A typed load at a thin pointer or `char` type of `n` bytes: the bytes' bits `u` and the
value `UVal ty u`. -/
theorem typedLoad_u {mem : Memory} {p : ThinPointer} {ta tb : Spec.Ty} {n : Nat} {v : Value}
    (hk : cmpUKind ta tb = some n ∨ cmpUKind tb ta = some n)
    (hl : typedLoad mem p ta .one = .ok v) :
    ∃ bs u, mem.load p n .one = .ok bs ∧ decodeBits bs = some u ∧ bs.length = n ∧ UVal ta u v := by
  have hcases : (∃ pt valid, ta = .ptr pt valid ∧ pt.metaKind = .none ∧ n = 8) ∨
      (ta = .char ∧ n = 4) := by
    rcases hk with hk | hk
    · rcases cmpUKind_spec hk with ⟨pa, va, pb, vb, rfl, rfl, h1, -, rfl⟩ | ⟨rfl, rfl, rfl⟩
      · exact .inl ⟨_, _, rfl, h1, rfl⟩
      · exact .inr ⟨rfl, rfl⟩
    · rcases cmpUKind_spec hk with ⟨pa, va, pb, vb, rfl, rfl, -, h2, rfl⟩ | ⟨rfl, rfl, rfl⟩
      · exact .inl ⟨_, _, rfl, h2, rfl⟩
      · exact .inr ⟨rfl, rfl⟩
  rcases hcases with ⟨pt, valid, rfl, hpk, rfl⟩ | ⟨rfl, rfl⟩
  · obtain ⟨bs, hl', hd⟩ := typedLoad_inv (size?_ptr_thin hpk) hl
    obtain ⟨tp, hlen, hdp, rfl⟩ := decode_ptr_thin_inv hpk hd
    rw [Ryo.Spec.Theorems.decodePtr_eq] at hdp
    cases hdb : decodeBits bs with
    | none => rw [hdb] at hdp; cases hdp
    | some u =>
      rw [hdb] at hdp
      have hq : (⟨u, Ryo.Spec.Theorems.ptrProvOf bs⟩ : ThinPointer) = tp := Option.some.inj hdp
      subst hq
      refine ⟨bs, u, hl', hdb, hlen, ?_⟩
      exact (⟨_, rfl⟩ : ∃ pr, (Value.ptr ⟨⟨u, Ryo.Spec.Theorems.ptrProvOf bs⟩, none⟩) =
        .ptr ⟨⟨u, pr⟩, none⟩)
  · obtain ⟨bs, hl', hd⟩ := typedLoad_inv (n := 4) (by first | rfl | decide) hl
    have hlen : bs.length = 4 := by
      by_cases hne : bs.length = 4
      · exact hne
      · simp [Spec.Ty.decode, hne] at hd
    cases hdb : decodeBits bs with
    | none => simp [Spec.Ty.decode, hlen, hdb] at hd
    | some u =>
      have hv : v = .int u := by
        by_cases hu : isUnicodeScalar u = true
        · simp [Spec.Ty.decode, hlen, hdb, hu] at hd
          first | exact hd.symm | exact hd
        · simp [Spec.Ty.decode, hlen, hdb, hu] at hd
      exact ⟨bs, u, hl', hdb, hlen, hv⟩

/-- L0's comparison of two thin pointers or `char`s is `intCmp` unsigned on their bits.

Proof: `rel_ucmp` gives `res` for `relResult op (some (compare ua ub))`; `evalBinOp` reduces
(per operator, `rfl`) to `relResult` on `comparePtr` (pointers: the address order, the metadata
keys both 0, `Ordering.then_eq`, `compare_natCast`) or on `compare` of the code points. -/
theorem eval_ucmp {op : BinOp} {o : String} (hop : cmpOp op = some o) {sg : Bool}
    (hsg : (o = "==" ∨ o = "!=") ∨ sg = false) {ta tb : Spec.Ty} {n ua ub : Nat}
    {va vb : Value} (hk : cmpUKind ta tb = some n) (hva : UVal ta ua va) (hvb : UVal tb ub vb)
    (hua : ua < 2 ^ (8 * n)) (hub : ub < 2 ^ (8 * n)) (ω : Spec.Oracle) (s : Spec.State) :
    ∃ res, intCmp o sg (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub) = .ok res ∧
      runOn (evalBinOp op (va, ta) (vb, tb) .bool) ω s = (.ok (.bool res), s) := by
  obtain ⟨res, hres, hrel⟩ := rel_ucmp hop hsg hua hub
  refine ⟨res, hres, ?_⟩
  have he : evalBinOp op (va, ta) (vb, tb) .bool =
      relResult op (some (compare (ua : Int) (ub : Int))) .bool := by
    rcases cmpUKind_spec hk with ⟨pta, vla, ptb, vlb, rfl, rfl, -, -, rfl⟩ | ⟨rfl, rfl, rfl⟩
    · -- thin pointers
      obtain ⟨pa, rfl⟩ : ∃ pr, va = .ptr ⟨⟨ua, pr⟩, none⟩ := hva
      obtain ⟨pb, rfl⟩ : ∃ pr, vb = .ptr ⟨⟨ub, pr⟩, none⟩ := hvb
      have hcp : comparePtr ⟨⟨ua, pa⟩, none⟩ ⟨⟨ub, pb⟩, none⟩ = compare (ua : Int) (ub : Int) := by
        show (compare ua ub).then (compare (0 : Nat) 0) = _
        rw [Nat.compare_eq_eq.mpr rfl, Ordering.then_eq, compare_natCast]
      rw [← hcp]
      cases op <;> simp [cmpOp] at hop <;> rfl
    · -- `char`s
      have hva' : va = .int ua := hva
      have hvb' : vb = .int ub := hvb
      subst hva' hvb'
      cases op <;> simp [cmpOp] at hop <;> rfl
  rw [he, hrel]
  rfl

/-! ### The lift -/

/-- `LowerCmpX`'s lift, with `lift_cmp`'s interface.

Proof: `lift_cmp`'s `reg` case with `typedLoad_u` for the loads (the bits below `2 ^ (8 * n)`
by `decodeBits_lt`) and `eval_ucmp` for L0's result. -/
theorem lift_cmpX {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerCmpX Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @uReg d a b oa ob op oc sw ta tb n sd sa sb i hf ha hb htd hta htb hk hsd hsa hsb hsize
      hoff hci =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, tys, r, hv, hh, hty', ho, hops, hctl⟩ := cmpInsnOk_spec hci
    rw [hmode, hρ] at hv
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨o', hop, hiff, hsw⟩ := cmpRegForm_spec hf
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb, td, ta', tb', va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = ta' := Option.some.inj (hta.symm.trans hta')
    have e6 : tb = tb' := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
    -- L0: the loads, the comparison, the store
    obtain ⟨bsa, ua, hloa, hda, hlena, hua⟩ := typedLoad_u (.inl hk) hla0
    obtain ⟨bsb, ub, hlob, hdb, hlenb, hub⟩ := typedLoad_u (.inr hk) hlb0
    have hua' : ua < 2 ^ (8 * n) := by
      have := Ryo.Proofs.Provenance.decodeBits_lt hda
      rw [hlena] at this
      exact this
    have hub' : ub < 2 ^ (8 * n) := by
      have := Ryo.Proofs.Provenance.decodeBits_lt hdb
      rw [hlenb] at this
      exact this
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = false := hsg.imp_left hiff.mp
    obtain ⟨res, hres, hev2⟩ := eval_ucmp hop hsg' hk hua hub hua' hub' o s
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hstk : s'.stack = s.stack := by rw [hs']
    have hsto : s.mem.store pd (boolByte res) .one = .ok s'.mem := by
      rw [hs']; exact typedStore_bool hst
    -- R's reads
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpbb hsb hlb
    rw [← hsize.2.1] at hloa
    rw [← hsize.2.2] at hlob
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hrel.frame.mem hrb hlob
    rw [hsize.2.1] at hrfa
    rw [hsize.2.2] at hrfb
    have hda' := decodeBits_inj hia hda
    have hdb' := decodeBits_inj hib hdb
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    have hvb : asNat bb = .ok ub := by unfold asNat; rw [hdb']; rfl
    -- R's write
    have hpos : 0 < sd.size := by rw [hsize.1]; exact Nat.one_pos
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    have hlen0 : (boolByte res).length = sd.size := by rw [boolByte_length, hsize.1]
    have hbs : BytesInj ι (boolByte res) (boolByte res) := by
      first
        | exact encodeBits_inj ι _ _
        | (unfold boolByte intBytes; exact encodeBits_inj ι _ _)
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hrel.write_dst hld hpd hsd hpos hbs hlen0 hsto
    have hop' : opSem v.op v.ops s1.st ch = .ok (.next, st') := by
      rw [hops]
      cases sw
      · exact opSem_cmp_fwd hh hps ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ hrfa hrfb hva
          hvb ((hsw sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub)).trans hres) hwr
      · exact opSem_cmp_fwd hh hps ho ⟨hf1.1, hf1.2, hf3.1, hf3.2, hf2.1, hf2.2⟩ hrfb hrfa hvb
          hva ((hsw sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub)).trans hres) hwr
    have hnp : ∀ b ∈ boolByte res, b.provFrag = none := by
      first
        | exact encodeBits_noprov 1 _
        | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    refine ⟨st', step_of_view hi hsc hpe hpl hv hctl hop', hstk, ?_, hpb', hle⟩
    exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'

/-- `LowerCmpX` in a scope-free function: `stmt_sim`'s case (as its `refDeref` case). -/
theorem stmt_sim_cmpX {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerCmpX Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h
    exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
    (lift_cmpX M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb M.dinv.2 hl2
      hl1 hev)

end Ryo.Proofs.Lower
