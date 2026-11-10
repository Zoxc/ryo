/-
Ryo.Proofs.Lower.SimUnop — the simulation of the unary-operator rules (M5b, `LowerUnop`,
`Check/Lower/Unop.lean`), each a single instruction with a private destination:

- `intUn`: `_d = not(_a)` / `_d = neg(_a)` on integer locals of type `t`, lowered to the `un`
  handler `not.wN d, a` / `neg.wN d, a` (method `not` / `wrapping_neg`). L0 computes
  `t.bringInBounds (-i - 1)` / `t.bringInBounds (-i)` (`unResult`), R `~~~a` / `-a` on the bit
  pattern; both are the same value modulo `2 ^ (8 * t.size)` (`intUn_wrap`). The model is
  `sim_binImm` (`SimBinImm.lean`) with `opSem_un_fwd` for `opSem_binImm_fwd`.
- `notBool`: `_d = not(_a)` at `bool`, lowered to `xor.imm.w8 d, a, 1` (a `bin_imm`/`binop_imm`
  handler with method `^` at 1 byte; `opSem_binImm_fwd` is its forward lemma). L0's byte is
  `0` or `1` (provenance ignored), R reads the same data, xors it with 1, and writes the byte
  L0 stores for `!b`, without provenance.

`lift_unop` is the rule's lift to R's `step` (`LiftOut`), as `lift_binopImm`/`lift_constBool`
(`FnRel.lean`, `FnSim.lean`). Beyond the common shape it takes `IntsSized f.body` (`LowersFn`'s
`ints`), for `0 < sd.size` in the integer rule.
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Check.Lower.Unop

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- L0's result of an integer `unMethod` operator. -/
def unResult (op : UnOp) (t : IntType) (i : Int) : Int :=
  match op with
  | .not => t.bringInBounds (-i - 1)
  | _ => t.bringInBounds (-i)

/-! ### Operands: `copy` and `move` -/

theorem eval_unop_norm {pl : MPlace} {op : UnOp} {oa : Operand} {a : Local}
    (ha : oa.local? = some a) :
    evalStatement (.assign pl (.unaryOp op oa)) =
      evalStatement (.assign pl (.unaryOp op (.copy ⟨a, []⟩))) := by
  rcases local?_cases ha with rfl | rfl <;>
    first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]

/-! ### The instruction form -/

theorem unInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {m : String} {n : Nat} {d a : Int}
    (h : unInsnOk Γ i m n d a = true) :
    ∃ v ty r, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.un, [ty, m], r⟩ ∧
      intTyOk ty n = true ∧ v.op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩] ∧
      v.ops = [.slot d, .slot a] ∧ v.ctl = some .next := by
  unfold unInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty m' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨hkd, hm⟩, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hkd hm
      exact ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩
    · cases h
  · cases h

/-! ### L0 -/

/-- An assignment of a unary operator on a copied local (no projections), run to success: both
locals are live, the operand loads at its type, and the store writes the result of `evalUnOp`.

Proof: as `assign_binimm_inv` (`SimBinImm.lean`), with
`evalRvalue (.unaryOp op oa) td = (evalOperand oa >>= fun l => evalUnOp op l td)` (by `rfl`
or `unfold evalRvalue`), then `runOn_evalPlace_nil`, `runOn_localPlace_ok`,
`runOn_evalOperand_copy`, `runOn_placeStore_ok` and `runOn_bind_ok`. -/
theorem assign_unop_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {op : UnOp}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.unaryOp op (.copy ⟨a, []⟩)))) o s =
      (.ok (), s')) :
    ∃ pd pa td ta va v,
      f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      f.body.locals[d]? = some td ∧ f.body.locals[a]? = some ta ∧
      typedLoad s.mem pa ta .one = .ok va ∧
      ∃ s1, runOn (evalUnOp op (va, ta) td) o s = (.ok v, s1) ∧
      ∃ mem', typedStore s1.mem pd v td .one = .ok mem' ∧ s' = { s1 with mem := mem' } := by
  have e : evalStatement (.assign ⟨d, []⟩ (.unaryOp op (.copy ⟨a, []⟩))) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.unaryOp op (.copy ⟨a, []⟩)) ty >>= fun v =>
            placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.unaryOp op (.copy ⟨a, []⟩)) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.unaryOp op (.copy ⟨a, []⟩)) td =
      (evalOperand (.copy ⟨a, []⟩) >>= fun l => evalUnOp op l td) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨la, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pa, ta, va, hla, hta, hva, hla', hs3⟩ := runOn_evalOperand_copy hs h5
  subst hla'
  rw [hs3] at h6
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pd, pa, td, ta, va, v, hld, hla, htd, hta, hva, s2, h6, mem', hst, hs'⟩

/-- A `bool` decodes from one byte holding `0` or `1`. -/
theorem decode_bool_val {bs : List AbstractByte} {w : Value}
    (hd : Spec.Ty.bool.decode bs = some w) :
    ∃ b : Bool, ∃ f, bs = [.init (if b then 1 else 0) f] ∧ w = .bool b := by
  simp only [Spec.Ty.decode] at hd
  split at hd
  · next f =>
    cases hd
    exact ⟨false, f, by first | rfl | (subst_vars; rfl) | simp_all, rfl⟩
  · next f =>
    cases hd
    exact ⟨true, f, by first | rfl | (subst_vars; rfl) | simp_all, rfl⟩
  · cases hd

/-- An integer `unMethod` operator succeeds without changing the state.

Proof: as `evalIntBinOp_wrap`: `cases op <;> simp [unMethod] at hm <;> rfl` (`evalUnOp`'s
first and third alternatives). -/
theorem evalUnOp_int {op : UnOp} {m : String} (hm : unMethod op = some m) (t : IntType)
    (valid : ValidRange) (i : Int) (dt : Spec.Ty) (o : Spec.Oracle) (s : Spec.State) :
    runOn (evalUnOp op (.int i, .int t valid) dt) o s = (.ok (.int (unResult op t i)), s) := by
  cases op <;> simp [unMethod] at hm <;> rfl

/-! ### Arithmetic -/

/-- Negation respects congruence. -/
theorem neg_emod_congr {x y M : Int} (h : x % M = y % M) : (-x) % M = (-y) % M := by
  rw [← Int.zero_sub x, ← Int.zero_sub y, Int.sub_emod 0 x M, h, ← Int.sub_emod 0 y M]

/-- R's `un` method on the bit pattern of an L0 integer gives the bit pattern of L0's result.

Proof: `cases op <;> simp [unMethod] at hm <;> subst hm <;> refine ⟨_, rfl, ?_⟩`, then as the
`sub` case of `intBin_wrap` (`IntBin.lean`): `BitVec.toNat_not` (`2 ^ w - 1 - x`) and
`BitVec.toNat_neg` (`(2 ^ w - x) % 2 ^ w`), `BitVec.toNat_ofNat`, `modulus_eq_two_pow`; on L0's
side `IntType.toBits_eq_of_emod` with `IntType.bringInBounds_emod` to drop `bringInBounds`,
then `toBits_of_emod_nat` and `IntType.ofBits_emod` (all as used in `intBin_wrap`), closing the
integer congruences with `Int.emod_emod_of_dvd`/`Int.sub_emod`/`Int.neg_emod` or `omega` on
the `Nat`-cast forms (`natCast_sub_add_emod` is the pattern for `2 ^ w - x`). -/
theorem intUn_wrap {op : UnOp} {m : String} (hm : unMethod op = some m) (t : IntType)
    (u : Nat) :
    ∃ res, intUn m (BitVec.ofNat (8 * t.size) u) = .ok res ∧
      res.toNat = t.toBits (unResult op t (t.ofBits u)) := by
  have hW := modulus_eq_two_pow t
  have hM := Ryo.Spec.Theorems.IntType.modulus_pos t
  have hx : t.ofBits u % (t.modulus : Int) = ((u % t.modulus : Nat) : Int) % (t.modulus : Int) := by
    rw [Ryo.Spec.Theorems.IntType.ofBits_emod, Int.natCast_emod, Int.emod_emod]
  have hb := Nat.mod_lt u hM
  cases op with
  | not =>
    simp [unMethod] at hm
    subst hm
    refine ⟨_, rfl, ?_⟩
    have hl := (~~~BitVec.ofNat (8 * t.size) u).isLt
    rw [← Nat.mod_eq_of_lt hl, BitVec.toNat_not, BitVec.toNat_ofNat, hW,
      show unResult .not t (t.ofBits u) = t.bringInBounds (-t.ofBits u - 1) from rfl,
      Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
        (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (-t.ofBits u - 1))]
    refine (toBits_of_emod_nat t ?_).symm
    generalize u % t.modulus = b at hx hb ⊢
    have h1 : ((t.modulus - 1 - b : Nat) : Int) = (-(b : Int) - 1) + (t.modulus : Int) * 1 := by
      omega
    rw [h1, Int.add_mul_emod_self_left, Int.sub_emod (-t.ofBits u) 1, neg_emod_congr hx,
      ← Int.sub_emod (-(b : Int)) 1]
  | neg =>
    simp [unMethod] at hm
    subst hm
    refine ⟨_, rfl, ?_⟩
    rw [BitVec.toNat_neg, BitVec.toNat_ofNat, hW,
      show unResult .neg t (t.ofBits u) = t.bringInBounds (-t.ofBits u) from rfl,
      Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
        (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (-t.ofBits u))]
    refine (toBits_of_emod_nat t ?_).symm
    generalize u % t.modulus = b at hx hb ⊢
    have h1 : ((t.modulus - b : Nat) : Int) = -(b : Int) + (t.modulus : Int) * 1 := by omega
    rw [h1, Int.add_mul_emod_self_left]
    exact neg_emod_congr hx
  | ptrMetadata => simp [unMethod] at hm

/-! ### R -/

/-- The footprint of an `un` handler at `n` bytes. -/
def unFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "a" n], writes := [Ryo.Proofs.Inline.rdA "d" n] }

/-- The forward direction of `Inline.Later.opSem_un`.

Proof: as `opSem_binImm_fwd` (`SimBinImm.lean`) with two operands and `unFp n`: the footprint
by `rw [Ryo.Proofs.Inline.footprint_eq hh]` then
`simp only [footprintOf, List.head?, Option.bind_some, Ryo.Proofs.Inline.tySize_of_parse hty]`
(and `rfl`; this is `Ryo.Proofs.Inline.Later.fp_un`, not imported here), `prepare` by
`if_neg` on the operand count and fits (`slot_fits`), `readAll` on `"a"`, `kindSem .un` by
`simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, out, hva, hres, ...]`,
`commit` on `"d"` with `Ryo.Spec.Theorems.encodeBits_length`. -/
theorem opSem_un_fwd {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat}
    {sg : Bool} {d a : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.un, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31)
    {ba : List AbstractByte} {va : Nat} {res : BitVec (8 * n)}
    (hra : st.readFrame a n = .ok ba) (hva : asNat ba = .ok va)
    (hres : intUn m (BitVec.ofNat (8 * n) va) = .ok res)
    (hw : st.writeFrame d (intBytes n res.toNat) = .ok st') :
    opSem op [.slot d, .slot a] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfp : footprint op = some (unFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    first
      | (simp only [footprintOf, List.head?, Option.bind_some,
          Ryo.Proofs.Inline.tySize_of_parse hty]; done)
      | (simp only [footprintOf, List.head?, Option.bind_some,
          Ryo.Proofs.Inline.tySize_of_parse hty]; rfl)
      | (simp [footprintOf, Ryo.Proofs.Inline.tySize_of_parse hty]; rfl)
      | simp [footprintOf, unFp, Ryo.Proofs.Inline.tySize_of_parse hty]
  have hprep : prepare op [.slot d, .slot a] =
      .ok (⟨.un, [ty, m], r⟩, (unFp n), opndVal op.info [.slot d, .slot a]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa])]
    rfl
  have hva' : opndVal op.info [.slot d, .slot a] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvd' : opndVal op.info [.slot d, .slot a] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (unFp n) (opndVal op.info [.slot d, .slot a]) st = .ok [("a", ba)] := by
    simp only [readAll, unFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', Val.slotOff, Extent.eval, hra,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .un [ty, m] (mkEnv [("a", ba)] (opndVal op.info [.slot d, .slot a]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes n res.toNat)] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, out, hva, hres,
      bind, Except.bind, pure, Except.pure]
  have hlen : (intBytes n res.toNat).length = n := Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (unFp n) (opndVal op.info [.slot d, .slot a]) st
      [("d", intBytes n res.toNat)] = .ok st' := by
    simp only [commit, unFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen,
      hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

/-! ### The simulations -/

/-- `intUn`'s simulation: as `sim_binImm` without the immediate.

Proof: `assign_unop_inv`, pin the locals and types; `typedLoad_int` on the load; rewrite the
operation with `evalUnOp_int`; `typedStore_int`; R's read by `readLocal_inj` and
`decodeBits_inj` (`asNat ba = .ok ua`); `intUn_wrap hm t ua` for `res`; the write's existence
by `writeEscaped_private'`; `opSem_un_fwd`; `writeLocal_priv` with `encodeBits_inj`; the
other locals by `LocalRel.store_other` and `LocalRel.writeFrame_apart` (exactly the tail of
`sim_binImm`). -/
theorem sim_unop {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {op : UnOp} {m : String} (hm : unMethod op = some m)
    {t : IntType} {valid : ValidRange}
    (htd : f.body.locals[d]? = some (.int t valid))
    (hta : f.body.locals[a]? = some (.int t valid))
    {sd sa : LocalSlot} (hsd : sd.size = t.size) (hsa : sa.size = t.size)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true)
    -- `_d` private
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    -- the instruction
    {opc : Full.Opcode} {r : Option String} {ty : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.un, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.unaryOp op (.copy ⟨a, []⟩)))) o s =
      (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', pa', td, ta, va, w, hpd', hpa', htd', hta', hla, s1, hev, mem', hst, rfl⟩ :=
    assign_unop_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  -- the load
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  -- the operation
  rw [evalUnOp_int hm t valid (t.ofBits ua) (.int t valid) o s] at hev
  simp only [Prod.mk.injEq, Except.ok.injEq] at hev
  obtain ⟨hw, hs1⟩ := hev
  subst hw
  subst s1
  -- the store
  have hsto := typedStore_int hst
  -- R's read
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa] at hrfa
  have hda' := decodeBits_inj hia hda
  have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
  obtain ⟨res, hres, hrn⟩ := intUn_wrap hm t ua
  -- R's write
  have hbeq : intBytes t.size res.toNat =
      encodeBits t.size (t.toBits (unResult op t (t.ofBits ua))) := by
    rw [hrn]; rfl
  have hlen : (intBytes t.size res.toNat).length = t.size := by
    rw [hbeq]; exact Ryo.Spec.Theorems.encodeBits_length _ _
  have hpw : ∀ i < (intBytes t.size res.toNat).length, st.escapedAt (sd.off + i) = none := by
    intro i hi
    rw [hlen, ← hsd] at hi
    exact hprivd i hi
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off (intBytes t.size res.toNat) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_un_fwd (ch := ch) hh hty ho hfits hrfa hva hres hwr
  have hbs : BytesInj ι (encodeBits t.size (t.toBits (unResult op t (t.ofBits ua))))
      (intBytes t.size res.toNat) := by
    rw [hbeq]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size (t.toBits (unResult op t (t.ofBits ua)))).length =
      sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

/-- `notBool`'s simulation: `xor.imm.w8 d, a, v` with `v`'s low byte 1.

Proof: `assign_unop_inv`, pin the locals and types (`.bool`). The load: `typedLoad_inv
size?_bool` gives one byte `bs0` with `Ty.bool.decode bs0 = some va`; unfolding `Ty.decode`
(as in `decode_bool_inv`, `SimPtr.lean`) `bs0 = [.init x f]` with `x = 0 ∧ va = .bool false` or
`x = 1 ∧ va = .bool true`. `evalUnOp .not (.bool b, .bool) .bool` is `pure (.bool !b)` (`rfl`),
so the state is unchanged and `typedStore_inv` stores `[.init (if !b then 1 else 0) none]`
(`Ty.encode`). R: `readLocal_inj` (at `sa.size = 1`) gives `ba` with
`BytesInj ι [.init x f] ba`, so `ba = [.init x g]` (`ByteInj` of an `init` byte keeps its data)
and `asNat ba = .ok x.toNat` (`decodeBits_inj`, `decodeBits` of one byte). `intBin "^"` is
`pure (A ^^^ B)`; with `v % 256 = 1`, `BitVec.ofNat 8 v = 1`, and for `x ∈ {0, 1}` (a case
split, `decide`) `intBytes 1 (BitVec.ofNat 8 x.toNat ^^^ 1).toNat` is L0's stored list, so
`BytesInj` by `encodeBits_inj`. The write by `writeEscaped_private'`, then
`opSem_binImm_fwd` (with `n = 1`), `writeLocal_priv`, and the tail of `sim_binImm`. -/
theorem sim_notBool {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local}
    (htd : f.body.locals[d]? = some .bool) (hta : f.body.locals[a]? = some .bool)
    {sd sa : LocalSlot} (hsd : sd.size = 1) (hsa : sa.size = 1)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true)
    -- `_d` private
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    -- the instruction
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String}
    {sg : Bool} {k : OperandKind} {v : Nat}
    (hkd : kd = .bin_imm ∨ kd = .binop_imm) (hh : opc.handler? = some ⟨kd, [ty, "^"], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int 1 sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    (hfk : Val.fits k (.imm v) = true)
    (hv : v % 2 ^ (8 * 1) = 1 % 2 ^ (8 * 1))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.unaryOp .not (.copy ⟨a, []⟩)))) o s =
      (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .imm v] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', pa', td, ta, va, w, hpd', hpa', htd', hta', hla, s1, hev, mem', hst, rfl⟩ :=
    assign_unop_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .bool := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  -- the load: one byte, `0` or `1`
  obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv size?_bool hla
  obtain ⟨b, f0, rfl, rfl⟩ := decode_bool_val hd
  -- the operation
  have e : evalUnOp .not (.bool b, .bool) .bool = (pure (.bool !b) : SemM Value) := rfl
  rw [e, runOn_pure] at hev
  obtain ⟨hw, hs1⟩ := prod_ok_inj hev
  subst w
  subst s1
  -- the store
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have hbsd : bsd = [.init (if !b then 1 else 0) none] := by
    have he : Spec.Ty.bool.encode (.bool !b) = some [.init (if !b then 1 else 0) none] := rfl
    exact (Option.some.inj (hen.symm.trans he))
  subst hbsd
  -- R's read
  rw [← hsa] at hlo
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hlo
  rw [hsa] at hrfa
  have hda : decodeBits [AbstractByte.init (if b then 1 else 0) f0] =
      some (if b then 1 else 0 : Nat) := by
    cases b <;> first | rfl | simp [decodeBits, leDecode, AbstractByte.data]
  have hva : asNat ba = .ok (if b then 1 else 0 : Nat) := by
    unfold asNat; rw [decodeBits_inj hia hda]; rfl
  have hv1 : BitVec.ofNat (8 * 1) v = BitVec.ofNat (8 * 1) 1 :=
    BitVec.eq_of_toNat_eq (by simp only [BitVec.toNat_ofNat]; exact hv)
  have hres : intBin "^" sg (BitVec.ofNat (8 * 1) (if b then 1 else 0 : Nat))
      (BitVec.ofNat (8 * 1) v) =
      .ok (BitVec.ofNat (8 * 1) (if b then 1 else 0 : Nat) ^^^ BitVec.ofNat (8 * 1) 1) := by
    rw [hv1]; rfl
  have hib : intBytes 1 (BitVec.ofNat (8 * 1) (if b then 1 else 0 : Nat) ^^^
      BitVec.ofNat (8 * 1) 1).toNat = [.init (if !b then 1 else 0) none] := by
    cases b <;> first | rfl | decide
  -- R's write
  have hlen : (intBytes 1 (BitVec.ofNat (8 * 1) (if b then 1 else 0 : Nat) ^^^
      BitVec.ofNat (8 * 1) 1).toNat).length = 1 := by rw [hib]; rfl
  have hpw : ∀ i < (intBytes 1 (BitVec.ofNat (8 * 1) (if b then 1 else 0 : Nat) ^^^
      BitVec.ofNat (8 * 1) 1).toNat).length, st.escapedAt (sd.off + i) = none := by
    intro i hi
    rw [hlen, ← hsd] at hi
    exact hprivd i hi
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off (intBytes 1 (BitVec.ofNat (8 * 1)
      (if b then 1 else 0 : Nat) ^^^ BitVec.ofNat (8 * 1) 1).toNat) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_binImm_fwd (ch := ch) hkd hh hty ho hfits hfk hrfa hva hres hwr
  have hbs : BytesInj ι [.init (if !b then 1 else 0) none] (intBytes 1 (BitVec.ofNat (8 * 1)
      (if b then 1 else 0 : Nat) ^^^ BitVec.ofNat (8 * 1) 1).toNat) := by
    rw [hib]
    first
      | exact ⟨rfl, trivial⟩
      | simp [BytesInj, ByteInj]
      | (cases b <;> simp [BytesInj, ByteInj])
  have hlen0 : ([.init (if !b then 1 else 0) none] : List AbstractByte).length = sd.size := by
    rw [hsd]; rfl
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

/-! ### The lift -/

/-- The unary-operator rules lifted to R's `step`.

Proof: `cases hlow`; in both cases `rvalueLocals (.unaryOp op oa) = [a]` (`local?_cases`, then
`rfl`), so `hlo a` gives `live a = true`; `rw [eval_unop_norm ha] at h`.
- `intUn`: as `lift_binopImm` (`FnRel.lean`) with `unInsnOk_spec` (no immediate), `hwf` for
  `0 < sd.size`, `assign_unop_inv` for `pd`/`pa`, `hrel.opnd`, `hrel.priv_dst`, `offOk_spec`,
  `sim_unop`. The L0 store is provenance-free: from `assign_unop_inv`, `typedLoad_int` and
  `evalUnOp_int`, `assign_int_mem` gives `s.mem.store pd bs .one = .ok s'.mem` with
  `bs` provenance-free and `s'.stack = s.stack`; then `memInv_store`,
  `hrel.hidden.store_noprov`, `OpFacts.opSem_out` for the escapes, `step_of_view`,
  `hrel.after`, as `lift_constBool`.
- `notBool`: the instruction decoded as in `lift_binopImm` (`binImmInsnOk_spec`,
  `intTyOk_spec`, `immOpsOk_spec`, `operands3`, `fits_last`), `0 < sd.size` from
  `hsize.1`, `sim_notBool`; the L0 store from `assign_unop_inv`, `typedStore_inv` and
  `Ty.encode` of a `bool` (one byte without provenance), then as `lift_constBool`. -/
theorem lift_unop {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerUnop Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @intUn d a oa op m t valid sd sa i hm ha htd hta hsd hsa hsize hoff hpriv hi0 =>
    have hla := hlo _ (operand_local_mem ha)
    rw [eval_unop_norm ha] at h
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := unInsnOk_spec hi0
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htd hta
    obtain ⟨pd, pa, td, ta, va, w, hpd, hpa, htd', hta', hlv, s2, hev, mem', hst, hs'⟩ :=
      assign_unop_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf d _ _ htd
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_unop (ch := ch) hs hm htd hta hsize.1 hsize.2
      hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ h
    -- the L0 store is provenance-free
    have e5 := Option.some.inj (hta'.symm.trans hta)
    subst e5
    obtain ⟨bsa, ua, -, -, -, rfl⟩ := typedLoad_int hlv
    rw [evalUnOp_int hm _ _ _ _ o s] at hev
    simp only [Prod.mk.injEq, Except.ok.injEq] at hev
    obtain ⟨-, hs1⟩ := hev
    obtain ⟨hstk, bs, hsto, hnp⟩ := assign_int_mem htd htd' hst hs1.symm hs'
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩
  | @notBool d a oa sd sa i ha htd hta hsd hsa hsize hoff hpriv hbi =>
    have hla := hlo _ (operand_local_mem ha)
    rw [eval_unop_norm ha] at h
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot sa.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd hta
    obtain ⟨pd, pa, td, ta, va, w, hpd, hpa, htd', hta', hlv, s2, hev, mem', hst, hs'⟩ :=
      assign_unop_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hpos : 0 < sd.size := by rw [hsize.1]; exact Nat.one_pos
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_notBool (ch := ch) hs htd hta hsize.1 hsize.2
      hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hkd hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk hx h
    -- the L0 store: one byte without provenance
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
    have e5 : ta = .bool := Option.some.inj (hta'.symm.trans hta)
    subst e4 e5
    obtain ⟨bs0, -, hd⟩ := typedLoad_inv size?_bool hlv
    obtain ⟨b, f0, -, rfl⟩ := decode_bool_val hd
    have e : evalUnOp .not (.bool b, .bool) .bool = (pure (.bool !b) : SemM Value) := rfl
    rw [e, runOn_pure] at hev
    obtain ⟨hw, hs1⟩ := prod_ok_inj hev
    subst w
    subst s2
    obtain ⟨bsd, hen, hsto0⟩ := typedStore_inv hst
    have hbsd : bsd = [.init (if !b then 1 else 0) none] := by
      have he : Spec.Ty.bool.encode (.bool !b) = some [.init (if !b then 1 else 0) none] := rfl
      exact (Option.some.inj (hen.symm.trans he))
    subst hbsd
    have hsto : s.mem.store pd [.init (if !b then 1 else 0) none] .one = .ok s'.mem := by
      subst hs'; exact hsto0
    have hstk : s'.stack = s.stack := by subst hs'; rfl
    have hnp : ∀ b' ∈ ([.init (if !b then 1 else 0) none] : List AbstractByte),
        b'.provFrag = none := by
      intro b' hb'
      simp only [List.mem_singleton] at hb'
      subst hb'
      rfl
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩

end Ryo.Proofs.Lower
