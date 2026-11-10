/-
Ryo.Proofs.Lower.SimCmp — the simulation of the comparison rules (`LowerCmp`,
`Check/Lower/Cmp.lean`, M5b): `_d = op(_a, _b)` lowered to one `cmp` instruction (operands
swapped for `gt`/`ge`), and `_d = op(_a, const)` lowered to one `cmp_imm`, on integer or `bool`
operands, `_d : bool` private.

- L0: the register form's assignment inverts with `assign_binop_inv` (generic in the operator);
  the immediate form's with `assign_cmpImm_inv` (generic in the constant's type). A comparison
  operand loads as the bits `u` its bytes denote, `cmpValue ty u` (`typedLoad_cmp`); a
  constant is its bits modulo `2 ^ (8 * n)` (`runOn_evalOperand_const_cmp`).
- Arithmetic: `relResult` on L0's `compare` of the operand values is `intCmp` on the bit
  patterns at the handler's signedness (`cmp_eval`); the register form's swap is `intCmp`'s
  definition of `>`/`>=` (`cmpRegForm_spec`).
- R: the forward directions of `Inline.opSem_cmp`/`opSem_cmpImm` (`opSem_cmp_fwd`,
  `opSem_cmpImm_fwd`); the result byte is `boolByte`, which is what L0 stores at `bool`
  (`typedStore_bool`), a provenance-free byte.

The lift needs nothing from `LowersFn` beyond the common hypotheses: the destination is 1 byte,
so no `IntsSized`.
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Proofs.Lower.WriteDst
import Ryo.Check.Lower.Cmp

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The checker's instruction forms -/

theorem cmpInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {o : String} {n : Nat} {sg : Bool}
    {d x y : Int} (h : cmpInsnOk Γ i o n sg d x y = true) :
    ∃ v ty r, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.cmp, [ty, o], r⟩ ∧
      cmpTyOk ty o n sg = true ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] ∧
      v.ops = [.slot d, .slot x, .slot y] ∧ v.ctl = some .next := by
  unfold cmpInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty o' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨hkd, ho⟩, hty⟩, hops0⟩, hops⟩, hctl⟩ := h
      subst hkd ho
      exact ⟨v, ty, r, hv, hh, hty, hops0, hops, hctl⟩
    · cases h
  · cases h

theorem cmpImmInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {o : String} {n : Nat} {sg : Bool}
    {d a : Int} {bits : Nat} (h : cmpImmInsnOk Γ i o n sg d a bits = true) :
    ∃ v ty r, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.cmp_imm, [ty, o], r⟩ ∧
      cmpTyOk ty o n sg = true ∧
      v.op.info.operands.map (·.name) = ["d", "a", "imm"] ∧
      (v.op.info.operands.take 2).map (·.kind) = [.slot, .slot] ∧
      immOpsOk v.ops [d, a] n bits = true ∧ v.ctl = some .next := by
  unfold cmpImmInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty o' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨hkd, ho⟩, hty⟩, hn⟩, hk⟩, hops⟩, hctl⟩ := h
      subst hkd ho
      exact ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩
    · cases h
  · cases h

/-! ### L0 -/

/-- The L0 value of a comparison operand of type `ty` whose bytes denote `u`. -/
def cmpValue : Spec.Ty → Nat → Value
  | .int t _, u => .int (t.ofBits u)
  | _, u => .bool (u == 1)

/-- The bits an L0 value of comparison type `ty` can have: a `bool`'s are 0 or 1. -/
def cmpBitsOk : Spec.Ty → Nat → Prop
  | .bool, u => u < 2
  | _, _ => True

/-- A typed load at a comparison type: the bytes' bits `u`, the value `cmpValue ty u`.

Proof: `cmpOpnd_spec`. Integer: `typedLoad_int` (`cmpBitsOk` is `True`). `bool`:
`typedLoad_inv size?_bool` gives the bytes and `Spec.Ty.bool.decode bs = some v`; unfold
`Spec.Ty.decode` (as in `decode_bool_inv`): `bs = [.init 0 f]` with `v = .bool false` or
`bs = [.init 1 f]` with `v = .bool true`; `decodeBits [.init x f] = some x.toNat`
(`Ryo.Spec.Theorems.decodeBits_iff`, or `rfl`/`decide` on the two cases). -/
theorem typedLoad_cmp {mem : Memory} {p : ThinPointer} {ty : Spec.Ty} {n : Nat} {sg : Bool}
    {al : Align} {v : Value} (hty : cmpOpnd ty = some (n, sg))
    (h : typedLoad mem p ty al = .ok v) :
    ∃ bs u, mem.load p n al = .ok bs ∧ decodeBits bs = some u ∧ bs.length = n ∧
      cmpBitsOk ty u ∧ v = cmpValue ty u := by
  rcases cmpOpnd_spec hty with ⟨t, valid, rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩
  · obtain ⟨bs, u, hl, hd, hlen, rfl⟩ := typedLoad_int h
    exact ⟨bs, u, hl, hd, hlen, True.intro, rfl⟩
  · obtain ⟨bs, hl, hd⟩ := typedLoad_inv size?_bool h
    simp only [Spec.Ty.decode] at hd
    split at hd
    · cases hd
      refine ⟨_, 0, hl, ?_, ?_, ?_, rfl⟩ <;>
        first
          | rfl
          | decide
          | exact (by decide : (0 : Nat) < 2)
          | (subst_vars; rfl)
          | (subst_vars; decide)
    · cases hd
      refine ⟨_, 1, hl, ?_, ?_, ?_, rfl⟩ <;>
        first
          | rfl
          | decide
          | exact (by decide : (1 : Nat) < 2)
          | (subst_vars; rfl)
          | (subst_vars; decide)
    · cases hd

/-- A scalar constant at a comparison type: its bits modulo `2 ^ (8 * n)`, state unchanged.

Proof: `cmpOpnd_spec`. Integer: `runOn_evalOperand_const_scalar_int` (`SimBinImm.lean`).
`bool`: as `constBool_mem` (`FnSim.lean`): unfold `evalOperand` to `evalConst … >>= pure`,
`evalConst (.scalar bits) .bool = decodeConst (encodeBits 1 bits) .bool` (`rfl`),
`runOn_decodeConst_ok`, `encodeBits_one`; the decode succeeds only for `bits % 256 ∈ {0, 1}`
(unfold `Spec.Ty.decode`, case on `UInt8.ofNat (bits % 256)` being 0 or 1:
`UInt8.toNat_ofNat`/`omega`), giving `.bool (bits % 256 == 1)`. -/
theorem runOn_evalOperand_const_cmp {o : Spec.Oracle} {s s1 : Spec.State} {bits : Nat}
    {tc : Spec.Ty} {n : Nat} {sg : Bool} {r : Value × Spec.Ty} (hty : cmpOpnd tc = some (n, sg))
    (h : runOn (evalOperand (.const (.scalar bits) tc)) o s = (.ok r, s1)) :
    r = (cmpValue tc (bits % 2 ^ (8 * n)), tc) ∧ cmpBitsOk tc (bits % 2 ^ (8 * n)) ∧ s1 = s := by
  rcases cmpOpnd_spec hty with ⟨t, valid, rfl, rfl, -⟩ | ⟨rfl, rfl, -⟩
  · obtain ⟨rfl, rfl⟩ := runOn_evalOperand_const_scalar_int h
    exact ⟨rfl, True.intro, rfl⟩
  · have e3 : evalOperand (.const (.scalar bits) .bool) =
        (evalConst (.scalar bits) .bool >>= fun w => pure (w, Spec.Ty.bool)) := by
      first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
    rw [e3] at h
    obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok h
    obtain ⟨hr, hs1⟩ := prod_ok_inj h2
    subst hr hs1
    have e5 : evalConst (.scalar bits) Spec.Ty.bool = decodeConst (encodeBits 1 bits) .bool :=
      rfl
    rw [e5] at h1
    obtain ⟨hdec, hs2⟩ := runOn_decodeConst_ok h1
    subst hs2
    rw [encodeBits_one] at hdec
    have hu : (UInt8.ofNat (bits % 256)).toNat = bits % 256 := by
      rw [UInt8.toNat_ofNat']
      exact Nat.mod_mod _ _
    have hval : w = .bool (bits % 256 == 1) ∧ bits % 256 < 2 := by
      generalize hb : ([.init (UInt8.ofNat (bits % 256)) none] : List AbstractByte) = bs
        at hdec
      simp only [Spec.Ty.decode] at hdec
      split at hdec
      · cases hdec
        have h3 : UInt8.ofNat (bits % 256) = 0 := by
          first
            | (injection hb with h1 _; injection h1 with h3 _; exact h3)
            | (subst_vars; injection hb with h1 _; injection h1 with h3 _; exact h3)
            | simp_all
        have h4 : bits % 256 = (0 : UInt8).toNat := hu.symm.trans (congrArg UInt8.toNat h3)
        have h5 : bits % 256 = 0 := h4
        rw [h5]
        exact ⟨rfl, by decide⟩
      · cases hdec
        have h3 : UInt8.ofNat (bits % 256) = 1 := by
          first
            | (injection hb with h1 _; injection h1 with h3 _; exact h3)
            | (subst_vars; injection hb with h1 _; injection h1 with h3 _; exact h3)
            | simp_all
        have h4 : bits % 256 = (1 : UInt8).toNat := hu.symm.trans (congrArg UInt8.toNat h3)
        have h5 : bits % 256 = 1 := h4
        rw [h5]
        exact ⟨rfl, by decide⟩
      · cases hdec
    obtain ⟨rfl, hlt⟩ := hval
    have h8 : (2 : Nat) ^ (8 * 1) = 256 := rfl
    first
      | exact ⟨rfl, hlt, rfl⟩
      | (rw [h8]; exact ⟨rfl, hlt, rfl⟩)

/-- An assignment of an operator on a copied local and a scalar constant of any type, run to
success (`assign_binimm_inv` without fixing the constant's type).

Proof: `assign_binimm_inv`'s, with the constant's step kept: `runOn_bind_ok` on
`evalOperand (.const …) >>= …` gives `lb, s4`; the constant's evaluation leaves the state
unchanged and returns `(w, tc)` (unfold `evalOperand` to `evalConst … >>= fun w => pure (w, tc)`,
`runOn_bind_ok`, `evalConst (.scalar bits) tc = decodeConst … tc` by `rfl`,
`runOn_decodeConst_ok`, `prod_ok_inj`). -/
theorem assign_cmpImm_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {op : BinOp} {bits : Nat}
    {tc : Spec.Ty}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) tc)))) o s = (.ok (), s')) :
    ∃ pd pa td ta va vc v,
      f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      f.body.locals[d]? = some td ∧ f.body.locals[a]? = some ta ∧
      typedLoad s.mem pa ta .one = .ok va ∧
      runOn (evalOperand (.const (.scalar bits) tc)) o s = (.ok (vc, tc), s) ∧
      ∃ s1, runOn (evalBinOp op (va, ta) (vc, tc) td) o s = (.ok v, s1) ∧
      ∃ mem', typedStore s1.mem pd v td .one = .ok mem' ∧ s' = { s1 with mem := mem' } := by
  have e : evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) tc))) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.binaryOp op (.copy ⟨a, []⟩)
            (.const (.scalar bits) tc)) ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.binaryOp op (.copy ⟨a, []⟩)
      (.const (.scalar bits) tc)) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) tc)) td =
      (evalOperand (.copy ⟨a, []⟩) >>= fun l =>
        evalOperand (.const (.scalar bits) tc) >>= fun r => evalBinOp op l r td) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨la, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pa, ta, va, hla, hta, hva, hla', hs3⟩ := runOn_evalOperand_copy hs h5
  subst hla'
  rw [hs3] at h6
  obtain ⟨lb, s4, h7, h8⟩ := runOn_bind_ok h6
  have e3 : evalOperand (.const (.scalar bits) tc) =
      (evalConst (.scalar bits) tc >>= fun w => pure (w, tc)) := by
    first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
  have h7' := h7
  rw [e3] at h7'
  obtain ⟨w, s5, h9, h10⟩ := runOn_bind_ok h7'
  have e5 : evalConst (.scalar bits) tc = decodeConst (encodeBits tc.size bits) tc := rfl
  rw [e5] at h9
  obtain ⟨-, hs5⟩ := runOn_decodeConst_ok h9
  subst hs5
  obtain ⟨hlb, hs4⟩ := prod_ok_inj h10
  subst hlb hs4
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pd, pa, td, ta, va, w, v, hld, hla, htd, hta, hva, h7, s2, h8, mem', hst, hs'⟩

/-- A `bool` store writes `boolByte b`.

Proof: `typedStore_inv`; `Spec.Ty.encode .bool (.bool b) = some [.init (if b then 1 else 0)
none]` (`rfl`); `boolByte b = intBytes 1 _ = encodeBits 1 _` (`encodeBits_one`), `cases b <;>
rfl`. -/
theorem typedStore_bool {mem mem' : Memory} {p : ThinPointer} {b : Bool} {al : Align}
    (h : typedStore mem p (.bool b) .bool al = .ok mem') :
    mem.store p (boolByte b) al = .ok mem' := by
  obtain ⟨bs, he, hst⟩ := typedStore_inv h
  have he' : Spec.Ty.bool.encode (.bool b) = some (boolByte b) := by
    cases b <;> first | rfl | decide
  rw [he'] at he
  obtain rfl := Option.some.inj he
  exact hst

/-! ### Arithmetic -/

/-- The register form computes the operator: `intCmp "<" sg b a` is `intCmp ">" sg a b` and
`"<="`/`">="` likewise, by `intCmp`'s definition; the sign condition is the same.

Proof: `cases op <;> simp [cmpRegForm] at h`, then per case `obtain ⟨rfl, rfl⟩ := h`,
`refine ⟨_, rfl, by simp, fun _ _ _ _ => rfl⟩` (`intCmp`'s `">"` arm is the `"<"` arm with the
operands swapped: `rfl` after `simp only [intCmp]`, or `cases sg <;> rfl`). -/
theorem cmpRegForm_spec {op : BinOp} {o : String} {sw : Bool}
    (h : cmpRegForm op = some (o, sw)) :
    ∃ o', cmpOp op = some o' ∧ ((o = "==" ∨ o = "!=") ↔ (o' = "==" ∨ o' = "!=")) ∧
      ∀ (sg : Bool) {w : Nat} (x y : BitVec w),
        intCmp o sg (if sw then y else x) (if sw then x else y) = intCmp o' sg x y := by
  cases op <;> simp [cmpRegForm] at h <;> obtain ⟨rfl, rfl⟩ := h <;>
    exact ⟨_, rfl, by simp, by intro sg w x y; first | rfl | (cases sg <;> rfl)⟩

/-- A comparison type compares with itself (the register form's operands). -/
theorem cmpConstTy_self {ty : Spec.Ty} {n : Nat} {sg : Bool} (h : cmpOpnd ty = some (n, sg)) :
    cmpConstTy ty ty = true := by
  rcases cmpOpnd_spec h with ⟨t, valid, rfl, -, -⟩ | ⟨rfl, -, -⟩
  · first | rfl | simp [cmpConstTy]
  · first | rfl | simp [cmpConstTy]

/-- An integer's value from its bits is the bit vector's, read signed or unsigned. -/
theorem ofBits_bv (t : IntType) (u : Nat) :
    t.ofBits u = if t.signed then (BitVec.ofNat (8 * t.size) u).toInt
      else ((BitVec.ofNat (8 * t.size) u).toNat : Int) := by
  have hW := modulus_eq_two_pow t
  have hM := Ryo.Spec.Theorems.IntType.modulus_pos t
  have hMP : t.modulus = 2 * 2 ^ (t.bits - 1) ∨ (t.modulus = 1 ∧ 2 ^ (t.bits - 1) = 1) := by
    unfold IntType.modulus
    cases hb : t.bits with
    | zero => exact .inr ⟨rfl, rfl⟩
    | succ k =>
      left
      rw [Nat.add_sub_cancel]
      exact (Nat.pow_succ 2 k).trans (Nat.mul_comm _ _)
  have e : t.ofBits u = if (t.signed && decide (u % t.modulus ≥ 2 ^ (t.bits - 1))) = true
      then ((u % t.modulus : Nat) : Int) - (t.modulus : Int)
      else ((u % t.modulus : Nat) : Int) := rfl
  rw [e, BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat, hW]
  have hr : u % t.modulus < t.modulus := Nat.mod_lt _ hM
  generalize u % t.modulus = r at hr ⊢
  generalize 2 ^ (t.bits - 1) = P at hMP ⊢
  generalize t.modulus = M at hM hMP hr ⊢
  cases t.signed
  · first | rfl | simp
  · rw [if_pos (rfl : true = true)]
    by_cases h1 : r ≥ P
    · rw [if_pos (show (true && decide (r ≥ P)) = true from decide_eq_true h1)]
      by_cases h2 : 2 * r < M
      · rw [if_pos h2]; omega
      · rw [if_neg h2]
    · rw [if_neg (show ¬ (true && decide (r ≥ P)) = true from fun h => h1 (of_decide_eq_true h))]
      by_cases h2 : 2 * r < M
      · rw [if_pos h2]
      · rw [if_neg h2]; omega

/-- Bit-vector comparisons are the comparisons of the integers they denote at signedness
`sg`. -/
theorem bv_rel {w : Nat} (sg : Bool) (A B : BitVec w) {x y : Int}
    (hx : x = if sg then A.toInt else (A.toNat : Int))
    (hy : y = if sg then B.toInt else (B.toNat : Int)) :
    (A == B) = decide (x = y) ∧ (if sg then A.slt B else A.ult B) = decide (x < y) ∧
      (if sg then A.sle B else A.ule B) = decide (x ≤ y) := by
  cases sg
  · change x = (A.toNat : Int) at hx
    change y = (B.toNat : Int) at hy
    change (A == B) = decide (x = y) ∧ A.ult B = decide (x < y) ∧ A.ule B = decide (x ≤ y)
    subst hx hy
    refine ⟨?_, ?_, ?_⟩
    · by_cases hab : A = B
      · subst hab; simp
      · have hne : ¬ ((A.toNat : Int) = (B.toNat : Int)) :=
          fun h => hab (BitVec.toNat_inj.mp (Int.ofNat_inj.mp h))
        rw [decide_eq_false hne, beq_false_of_ne hab]
    · rw [BitVec.ult_eq_decide, decide_eq_decide]; exact Int.ofNat_lt.symm
    · rw [BitVec.ule_eq_decide, decide_eq_decide]; exact Int.ofNat_le.symm
  · change x = A.toInt at hx
    change y = B.toInt at hy
    change (A == B) = decide (x = y) ∧ A.slt B = decide (x < y) ∧ A.sle B = decide (x ≤ y)
    subst hx hy
    refine ⟨?_, ?_, ?_⟩
    · by_cases hab : A = B
      · subst hab; simp
      · have hne : ¬ (A.toInt = B.toInt) := fun h => hab (BitVec.toInt_inj.mp h)
        rw [decide_eq_false hne, beq_false_of_ne hab]
    · exact BitVec.slt_eq_decide
    · exact BitVec.sle_eq_decide

/-- L0's relational results on an integer `compare`. -/
theorem compare_rel (x y : Int) :
    (some (compare x y) == some Ordering.eq) = decide (x = y) ∧
    (some (compare x y) != some Ordering.eq) = !decide (x = y) ∧
    (some (compare x y) == some Ordering.lt) = decide (x < y) ∧
    (some (compare x y) == some Ordering.lt || some (compare x y) == some Ordering.eq) =
      decide (x ≤ y) ∧
    (some (compare x y) == some Ordering.gt) = decide (y < x) ∧
    (some (compare x y) == some Ordering.gt || some (compare x y) == some Ordering.eq) =
      decide (y ≤ x) := by
  rcases Int.lt_trichotomy x y with h | h | h
  · rw [Int.compare_eq_lt.mpr h]
    have h1 : decide (x = y) = false := decide_eq_false (by omega)
    have h2 : decide (x < y) = true := decide_eq_true h
    have h3 : decide (x ≤ y) = true := decide_eq_true (by omega)
    have h4 : decide (y < x) = false := decide_eq_false (by omega)
    have h5 : decide (y ≤ x) = false := decide_eq_false (by omega)
    rw [h1, h2, h3, h4, h5]
    decide
  · rw [Int.compare_eq_eq.mpr h]
    have h1 : decide (x = y) = true := decide_eq_true h
    have h2 : decide (x < y) = false := decide_eq_false (by omega)
    have h3 : decide (x ≤ y) = true := decide_eq_true (by omega)
    have h4 : decide (y < x) = false := decide_eq_false (by omega)
    have h5 : decide (y ≤ x) = true := decide_eq_true (by omega)
    rw [h1, h2, h3, h4, h5]
    decide
  · rw [Int.compare_eq_gt.mpr h]
    have h1 : decide (x = y) = false := decide_eq_false (by omega)
    have h2 : decide (x < y) = false := decide_eq_false (by omega)
    have h3 : decide (x ≤ y) = false := decide_eq_false (by omega)
    have h4 : decide (y < x) = true := decide_eq_true h
    have h5 : decide (y ≤ x) = true := decide_eq_true (by omega)
    rw [h1, h2, h3, h4, h5]
    decide

/-- L0's comparison of two operand values is `intCmp` on their bit patterns, at the handler's
signedness `sg` (the type's, or any for `==`/`!=`); it neither fails nor changes the state.

Proof: `cmpOpnd_spec` and `cmpConstTy_spec` (types `.int t valid`/`.int t vc`, or both
`bool`); `cases op <;> simp [cmpOp] at hop` (six cases, `subst`), `refine ⟨_, rfl, ?_⟩`, then
`evalBinOp` reduces (`rfl`/`simp only [evalBinOp, evalIntBinOp, isRel, relResult]`) to
`.bool` of `compare x y`. Integer: `compare (t.ofBits ua) (t.ofBits ub)` against
`BitVec.ult`/`slt` of `BitVec.ofNat (8 * t.size)`: unsigned, `t.ofBits u = u % 2 ^ (8 * t.size)`
(`modulus_eq_two_pow`) and `BitVec.toNat_ofNat`; signed, `t.ofBits u` is
`(BitVec.ofNat (8 * t.size) u).toInt` (`BitVec.toInt_eq_toNat_cond`, `BitVec.toNat_ofNat`;
`t.size = 0` is the degenerate case where both are 0); `==`/`!=` by `BitVec.eq_of_toNat_eq` and
`Ryo.Spec.Theorems.IntType.ofBits_emod` (injectivity of `ofBits` modulo the modulus); then
`Int.compare`'s `lt`/`eq` cases (`Int.compare_lt_iff_lt`, `compare_eq_iff_eq`, or unfold
`compare`/`compareOfLessAndEq` and `split`). `bool`: `ua, ub < 2`, so `ua = 0 ∨ ua = 1`
(`omega`) and likewise `ub`; `subst` and `decide`/`rfl` on the 4 × 6 cases. -/
theorem cmp_eval {op : BinOp} {o : String} (hop : cmpOp op = some o) {ty tc : Spec.Ty}
    {n : Nat} {sg' sg : Bool} (hty : cmpOpnd ty = some (n, sg')) (hc : cmpConstTy tc ty = true)
    (hsg : (o = "==" ∨ o = "!=") ∨ sg = sg') {ua ub : Nat} (hua : cmpBitsOk ty ua)
    (hub : cmpBitsOk ty ub) (ω : Spec.Oracle) (s : Spec.State) :
    ∃ res, intCmp o sg (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub) = .ok res ∧
      runOn (evalBinOp op (cmpValue ty ua, ty) (cmpValue tc ub, tc) .bool) ω s =
        (.ok (.bool res), s) := by
  rcases cmpOpnd_spec hty with ⟨t, valid, rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩
  · rcases cmpConstTy_spec hc with ⟨t', vc, valid', rfl, he⟩ | ⟨-, he⟩
    · injection he with h1 h2
      subst h1 h2
      have hx := ofBits_bv t ua
      have hy := ofBits_bv t ub
      show ∃ res, intCmp o sg (BitVec.ofNat (8 * t.size) ua) (BitVec.ofNat (8 * t.size) ub) =
          .ok res ∧ runOn (evalBinOp op (.int (t.ofBits ua), .int t valid)
            (.int (t.ofBits ub), .int t vc) .bool) ω s = (.ok (.bool res), s)
      generalize BitVec.ofNat (8 * t.size) ua = A at hx ⊢
      generalize BitVec.ofNat (8 * t.size) ub = B at hy ⊢
      generalize t.ofBits ua = x at hx ⊢
      generalize t.ofBits ub = y at hy ⊢
      obtain ⟨hE, hL, hLe⟩ := bv_rel t.signed A B hx hy
      obtain ⟨-, hG, hGe⟩ := bv_rel t.signed B A hy hx
      obtain ⟨c1, c2, c3, c4, c5, c6⟩ := compare_rel x y
      cases op <;> simp [cmpOp] at hop <;> subst hop
      all_goals first
        | (refine ⟨_, rfl, ?_⟩
           show ((Except.ok (Value.bool (some (compare x y) == some Ordering.eq)) :
               Except Outcome Value), s) = (Except.ok (Value.bool (A == B)), s)
           rw [hE, c1])
        | (refine ⟨_, rfl, ?_⟩
           show ((Except.ok (Value.bool (some (compare x y) != some Ordering.eq)) :
               Except Outcome Value), s) = (Except.ok (Value.bool (!(A == B))), s)
           rw [hE, c2])
        | (obtain rfl : sg = t.signed := hsg.resolve_left (by simp)
           refine ⟨_, rfl, ?_⟩
           show ((Except.ok (Value.bool (some (compare x y) == some Ordering.lt)) :
               Except Outcome Value), s) =
             (Except.ok (Value.bool (if t.signed then A.slt B else A.ult B)), s)
           rw [hL, c3])
        | (obtain rfl : sg = t.signed := hsg.resolve_left (by simp)
           refine ⟨_, rfl, ?_⟩
           show ((Except.ok (Value.bool (some (compare x y) == some Ordering.lt ||
               some (compare x y) == some Ordering.eq)) : Except Outcome Value), s) =
             (Except.ok (Value.bool (if t.signed then A.sle B else A.ule B)), s)
           rw [hLe, c4])
        | (obtain rfl : sg = t.signed := hsg.resolve_left (by simp)
           refine ⟨_, rfl, ?_⟩
           show ((Except.ok (Value.bool (some (compare x y) == some Ordering.gt)) :
               Except Outcome Value), s) =
             (Except.ok (Value.bool (if t.signed then B.slt A else B.ult A)), s)
           rw [hG, c5])
        | (obtain rfl : sg = t.signed := hsg.resolve_left (by simp)
           refine ⟨_, rfl, ?_⟩
           show ((Except.ok (Value.bool (some (compare x y) == some Ordering.gt ||
               some (compare x y) == some Ordering.eq)) : Except Outcome Value), s) =
             (Except.ok (Value.bool (if t.signed then B.sle A else B.ule A)), s)
           rw [hGe, c6])
    · cases he
  · rcases cmpConstTy_spec hc with ⟨t', vc, valid', -, he⟩ | ⟨rfl, -⟩
    · cases he
    · have hua' : ua < 2 := hua
      have hub' : ub < 2 := hub
      obtain rfl | rfl : ua = 0 ∨ ua = 1 := by omega
      all_goals obtain rfl | rfl : ub = 0 ∨ ub = 1 := by omega
      all_goals cases op <;> simp [cmpOp] at hop <;> subst hop <;> cases sg <;>
        first
          | exact ⟨_, rfl, rfl⟩
          | (refine ⟨_, rfl, ?_⟩; rfl)

/-! ### R -/

/-- The footprint of a `cmp` handler at `n` bytes. -/
def cmpFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "a" n, Ryo.Proofs.Inline.rdA "b" n],
    writes := [Ryo.Proofs.Inline.rdA "d" 1] }

/-- The footprint of a `cmp_imm` handler at `n` bytes. -/
def cmpImmFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "a" n], writes := [Ryo.Proofs.Inline.rdA "d" 1] }

theorem boolByte_length (b : Bool) : (boolByte b).length = 1 := by
  first | (cases b <;> rfl) | exact Ryo.Spec.Theorems.encodeBits_length _ _

/-- The forward direction of `Inline.opSem_cmp`.

Proof: `opSem_bin_fwd`'s, with footprint `{ reads := [rdA "a" n, rdA "b" n],
writes := [rdA "d" 1] }` (`(Inline.fp_w (Inline.tySize_of_parse hty)).2.2.2.2.2.2.2.1`), the
kind `.cmp` (`kindSem` with `Env.bv`, `hres`, `boolByte`), and the commit's length
`(boolByte res).length = 1` (`encodeBits_length`). -/
theorem opSem_cmp_fwd {op : Full.Opcode} {r : Option String} {ty o' : String} {n : Nat}
    {sg : Bool} {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.cmp, [ty, o'], r⟩) (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31 ∧ -2 ^ 31 ≤ b ∧ b < 2 ^ 31)
    {ba bb : List AbstractByte} {va vb : Nat} {res : Bool}
    (hra : st.readFrame a n = .ok ba) (hrb : st.readFrame b n = .ok bb)
    (hva : asNat ba = .ok va) (hvb : asNat bb = .ok vb)
    (hres : intCmp o' sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res)
    (hw : st.writeFrame d (boolByte res) = .ok st') :
    opSem op [.slot d, .slot a, .slot b] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2, hb1, hb2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfb := slot_fits hb1 hb2
  have hfp : footprint op = some (cmpFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.2.2.2.1
  have hprep : prepare op [.slot d, .slot a, .slot b] =
      .ok (⟨.cmp, [ty, o'], r⟩, (cmpFp n),
        opndVal op.info [.slot d, .slot a, .slot b]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa, hfb])]
    rfl
  have hva' : opndVal op.info [.slot d, .slot a, .slot b] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvb' : opndVal op.info [.slot d, .slot a, .slot b] "b" = some (.slot b) := by
    simp [opndVal, ho]
  have hvd' : opndVal op.info [.slot d, .slot a, .slot b] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (cmpFp n) (opndVal op.info [.slot d, .slot a, .slot b]) st =
      .ok [("a", ba), ("b", bb)] := by
    simp only [readAll, cmpFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', hvb', Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .cmp [ty, o'] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", boolByte res)] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, out, hva, hvb,
      hres, bind, Except.bind, pure, Except.pure]
  have hlen : (boolByte res).length = 1 := boolByte_length res
  have hc : commit (cmpFp n) (opndVal op.info [.slot d, .slot a, .slot b]) st
      [("d", boolByte res)] = .ok st' := by
    simp only [commit, cmpFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen, hw,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

/-- The forward direction of `Inline.opSem_cmpImm`.

Proof: `opSem_binImm_fwd`'s (`SimBinImm.lean`), with footprint `{ reads := [rdA "a" n],
writes := [rdA "d" 1] }` (`(Inline.fp_w …).2.2.2.2.2.2.2.2.1`), the kind `.cmp_imm`
(`Env.immBv`, `Env.imm`), and `(boolByte res).length = 1`. -/
theorem opSem_cmpImm_fwd {op : Full.Opcode} {r : Option String} {ty o' : String} {n : Nat}
    {sg : Bool} {k : OperandKind} {d a : Int} {v : Nat} {st st' : OpSem.State}
    {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.cmp_imm, [ty, o'], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31)
    (hfk : Val.fits k (.imm v) = true)
    {ba : List AbstractByte} {va : Nat} {res : Bool}
    (hra : st.readFrame a n = .ok ba) (hva : asNat ba = .ok va)
    (hres : intCmp o' sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) v) = .ok res)
    (hw : st.writeFrame d (boolByte res) = .ok st') :
    opSem op [.slot d, .slot a, .imm v] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfp : footprint op = some (cmpImmFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.2.2.2.2.1
  have hprep : prepare op [.slot d, .slot a, .imm v] =
      .ok (⟨.cmp_imm, [ty, o'], r⟩, (cmpImmFp n),
        opndVal op.info [.slot d, .slot a, .imm v]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa, hfk])]
    rfl
  have hva' : opndVal op.info [.slot d, .slot a, .imm v] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvi' : opndVal op.info [.slot d, .slot a, .imm v] "imm" = some (.imm v) := by
    simp [opndVal, ho]
  have hvd' : opndVal op.info [.slot d, .slot a, .imm v] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (cmpImmFp n) (opndVal op.info [.slot d, .slot a, .imm v]) st =
      .ok [("a", ba)] := by
    simp only [readAll, cmpImmFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', Val.slotOff, Extent.eval, hra,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .cmp_imm [ty, o'] (mkEnv [("a", ba)]
      (opndVal op.info [.slot d, .slot a, .imm v]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", boolByte res)] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, Env.immBv,
      Env.imm, hvi', out, hva, hres, bind, Except.bind, pure, Except.pure]
  have hlen : (boolByte res).length = 1 := boolByte_length res
  have hc : commit (cmpImmFp n) (opndVal op.info [.slot d, .slot a, .imm v]) st
      [("d", boolByte res)] = .ok st' := by
    simp only [commit, cmpImmFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen,
      hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

/-! ### The lift -/

/-- The comparison rules' lift (see the module comment).

Proof plan, per constructor (`cases hlow`), following `lift_binop`/`lift_binopImm`
(`FnRel.lean`) and `lift_constBool` (`FnSim.lean`):
- `reg`: `rw [eval_binop_norm ha hb] at h`; `cmpInsnOk_spec`, `cmpTyOk_spec` (handler
  signedness `s` with `(o = "==" ∨ o = "!=") ∨ s = sg`); `assign_binop_inv` gives the locals'
  pointers and types (`hbody` to identify them with `htd hta htb`), `typedLoad_cmp` both
  operands (bits `ua`, `ub`); `hrel.opnd` and `readLocal_inj` give R's bytes, `decodeBits_inj`
  the same bits (`asNat`); `cmpRegForm_spec` turns the swapped `intCmp o s y x` into
  `intCmp o' s x y` and moves the sign condition to `o'`; `cmp_eval` (with `tc := ty`,
  `cmpConstTy_self`) gives `res` and L0's value `.bool res`; `typedStore_bool` the store of
  `boolByte res`. R's write: `hrel.priv_dst` (`0 < sd.size` from `sd.size = 1`),
  `writeEscaped_private'` for `writeFrame`'s success, `opSem_cmp_fwd`, `writeLocal_priv` (bytes
  related by `encodeBits_inj`, `boolByte` being `encodeBits 1 _`), the other locals by
  `LocalRel.store_other`/`LocalRel.writeFrame_apart` as in `sim_binImm`; then `step_of_view`,
  `hrel.after`, `hrel.hidden.store_noprov` and `memInv_store` with `encodeBits_noprov 1 _`.
  When `sw`, the instruction reads `b` first: only the `if`s in `hi` differ.
- `imm`: likewise with `eval_binopImm_norm ha`, `cmpImmInsnOk_spec`, `immOpsOk_spec` (`x` with
  `x % 2 ^ (8 * n) = bits % 2 ^ (8 * n)`), `operands3`, `fits_last`, `assign_cmpImm_inv`,
  `runOn_evalOperand_const_cmp` (the constant is `cmpValue tc (bits % 2 ^ (8 * n))`;
  `cmpOpnd tc = cmpOpnd ty` from `cmpConstTy_spec`), `cmp_eval` with
  `ub := bits % 2 ^ (8 * n)`, and `BitVec.ofNat (8 * n) x = BitVec.ofNat (8 * n) (bits % …)`
  (`BitVec.ofNat_mod_pow2`-style: `BitVec.eq_of_toNat_eq`, `BitVec.toNat_ofNat`, `Nat.mod_mod`)
  for `opSem_cmpImm_fwd`. -/
theorem lift_cmp {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerCmp Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @reg d a b oa ob op oc sw ty n sg sd sa sb i hf ha hb htd hta htb hty hsd hsa hsb hsize
      hoff hci =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, tys, r, hv, hh, hty', ho, hops, hctl⟩ := cmpInsnOk_spec hci
    rw [hmode, hρ] at hv
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨o', hop, hiff, hsw⟩ := cmpRegForm_spec hf
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    have e6 : ty = tb := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
    -- L0: the loads, the comparison, the store
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    obtain ⟨bsb, ub, hlob, hdb, -, hub, rfl⟩ := typedLoad_cmp hty hlb0
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = sg := hsg.imp_left hiff.mp
    obtain ⟨res, hres, hev2⟩ := cmp_eval hop hty (cmpConstTy_self hty) hsg' hua hub o s
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
    -- `_d` private or escaped
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hrel.write_dst hld hpd hsd hpos hbs hlen0 hsto
    have hop : opSem v.op v.ops s1.st ch = .ok (.next, st') := by
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
    refine ⟨st', step_of_view hi hsc hpe hpl hv hctl hop, hstk, ?_, hpb', hle⟩
    exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'
  | @imm d a oa op oc bits ty tc n sg sd sa i ho ha htd hta hc hty hsd hsa hsize hoff
      hci =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    rw [eval_binopImm_norm ha] at h
    obtain ⟨v, tys, r, hv, hh, hty', hn, hk, hops, hctl⟩ := cmpImmInsnOk_spec hci
    rw [hmode, hρ] at hv
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho'⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot sa.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho', hops'']; simp)
    rw [hbody] at htd hta
    obtain ⟨pd, pa, td, ta, va, vc, w, hpd, hpa, htd', hta', hla0, hcst, s2, hev, mem', hst,
      hs'⟩ := assign_cmpImm_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    subst e4 e5
    -- L0: the load, the constant, the comparison, the store
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    have htc : cmpOpnd tc = some (n, sg) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hty
    obtain ⟨hvc, hub, -⟩ := runOn_evalOperand_const_cmp htc hcst
    obtain ⟨rfl, -⟩ := Prod.mk.inj hvc
    have hub' : cmpBitsOk ty (bits % 2 ^ (8 * n)) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hub
    obtain ⟨res, hres, hev2⟩ := cmp_eval ho hty hc hsg hua hub' o s
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hstk : s'.stack = s.stack := by rw [hs']
    have hsto : s.mem.store pd (boolByte res) .one = .ok s'.mem := by
      rw [hs']; exact typedStore_bool hst
    -- R's read
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hda' := decodeBits_inj hia hda
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    -- R's write
    have hpos : 0 < sd.size := by rw [hsize.1]; exact Nat.one_pos
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hlen0 : (boolByte res).length = sd.size := by rw [boolByte_length, hsize.1]
    have hbs : BytesInj ι (boolByte res) (boolByte res) := by
      first
        | exact encodeBits_inj ι _ _
        | (unfold boolByte intBytes; exact encodeBits_inj ι _ _)
    -- `_d` private or escaped
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hrel.write_dst hld hpd hsd hpos hbs hlen0 hsto
    -- the immediate denotes the constant's low bits
    have hxe : BitVec.ofNat (8 * n) x = BitVec.ofNat (8 * n) (bits % 2 ^ (8 * n)) := by
      apply BitVec.eq_of_toNat_eq
      rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, Nat.mod_mod, hx]
    have hres' : intCmp oc sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) x) = .ok res := by
      rw [hxe]; exact hres
    have hop : opSem v.op v.ops s1.st ch = .ok (.next, st') := by
      rw [hops'']
      exact opSem_cmpImm_fwd hh hps ho' ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk hrfa hva hres' hwr
    have hnp : ∀ b ∈ boolByte res, b.provFrag = none := by
      first
        | exact encodeBits_noprov 1 _
        | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    refine ⟨st', step_of_view hi hsc hpe hpl hv hctl hop, hstk, ?_, hpb', hle⟩
    exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'

end Ryo.Proofs.Lower
