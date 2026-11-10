/-
Ryo.Proofs.Lower.SimFused — the simulation of `LowerFused` (`Check/Lower/Fused.lean`, M5b): a
fused block's compare `_c = op(_a, _b)` and its `switchInt(_c)`, two L0 steps, against one R
compare-and-branch and a goto.

L0's first step (the compare) is matched by no R step: the function simulation's invariant
admits the state between the two (`MatchMid`: L0's state after the compare, evaluated from a
state `MatchAt` relates to R at the compare's point, whose `pcAt` is the terminator range's
start since the compare has no range). `sim_fused` is the second step from there, taking both
L0 evaluations: R branches on its own compare of `_a`'s and `_b`'s slots (unchanged, as L0's
operands are) and reaches the start of L0's target. `FnRel` holds there at any `live'` within
`live` (the compare's point) without `_c`: R never wrote `_c`'s slot, so `_c` must be dead at
the target, which `LowerFused`'s `hdead` gives at both successors (`FnRel.store_dead`).

The steps: L0's compare as in `lift_cmp` (`assign_binop_inv`/`assign_cmpImm_inv`,
`typedLoad_cmp`, `cmp_eval`, `typedStore_bool`); R's reads as there (`hrel.opnd`,
`readLocal_inj`, `decodeBits_inj`); `brRegForm_spec`/`brImmForm_spec` turn L0's compare into
the handler's (`cb`, MIR's being `cb != pol`); `opSem_brCmp_fwd`/`opSem_brCmpImm_fwd'` the
branch's `opSem`, `step_branch` and `branch_run` (with `hsel`) R's run; `fused_switch_l0` L0's
switch on the stored `bool`; `FnRel.store_dead` the relation without `_c`.

The niche-discriminant rule (`LowerFused.niche`) is `SimNiche.lean`'s (`sim_fusedNiche`,
`niche_stmt_stack`, `niche_kill`), which also holds `FnRel.store_dead`. The fused assert
(`LowerFused.assert`) is `sim_fusedAssert` (its section below), whose failing path is
`sim_fused`'s second outcome (`FusedAssertOut`).
-/
import Ryo.Proofs.Lower.SimCmp
import Ryo.Check.Lower.Fused
import Ryo.Proofs.Lower.SimNiche
import Ryo.Proofs.Lower.SimNicheDense
import Ryo.Proofs.Lower.SimTermMore
import Ryo.Proofs.Lower.SimCmpX

namespace Ryo.Proofs.Lower

/-! ### Forward `opSem` of the compare-and-branches -/

section
open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem

/-- The footprint of a `br_cmp` handler at `n` bytes. -/
def brCmpFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "a" n, Ryo.Proofs.Inline.rdA "b" n], flow := .branch }

/-- `br_cmp` (`br.eq`, `br.lt.*`) at `n` bytes on slots `x`, `y`: branch on the handler's
compare, the state unchanged.

Proof: as `opSem_brCmpImm_fwd` (`SimTerm.lean`) with two reads: the footprint
`{ reads := [rdA "a" n, rdA "b" n], flow := .branch }` (`Inline.footprint_eq hh`,
`Footprint.lean`'s `br_cmp` case: `Inline.fp_w (Inline.tySize_of_parse hty)`'s component, or
`simp [footprintOf, Inline.tySize_of_parse hty]`), `prepare` (fits: `slot_fits`, `.none` fits
`.neg`/`.target`), `readAll` as in `opSem_cmp_fwd`, `kindSem .br_cmp` (`Inline.intTy_of_parse
hty`, `Env.bv`, `hva`, `hvb`, `hres`), `commit` of no writes. -/
theorem opSem_brCmp_fwd {op : Full.Opcode} {r : Option String} {ty o : String} {n : Nat}
    {sg : Bool} {x y : Int} {st : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.br_cmp, [ty, o], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"a", .slot⟩, ⟨"b", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩])
    (hfits : -2 ^ 31 ≤ x ∧ x < 2 ^ 31 ∧ -2 ^ 31 ≤ y ∧ y < 2 ^ 31)
    {ba bb : List AbstractByte} {va vb : Nat} {res : Bool}
    (hra : st.readFrame x n = .ok ba) (hrb : st.readFrame y n = .ok bb)
    (hva : asNat ba = .ok va) (hvb : asNat bb = .ok vb)
    (hres : intCmp o sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res) :
    opSem op [.slot x, .slot y, .none, .none] st ch = .ok (.branch res, st) := by
  obtain ⟨hx1, hx2, hy1, hy2⟩ := hfits
  have hfx := slot_fits hx1 hx2
  have hfy := slot_fits hy1 hy2
  have hneg : Val.fits .neg .none = true := rfl
  have htgt : Val.fits .target .none = true := rfl
  have hfp : footprint op = some (brCmpFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.2.2.2.2.2.1
  have hprep : prepare op [.slot x, .slot y, .none, .none] =
      .ok (⟨.br_cmp, [ty, o], r⟩,
        (brCmpFp n),
        opndVal op.info [.slot x, .slot y, .none, .none]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfx, hfy, hneg, htgt])]
    rfl
  have hva' : opndVal op.info [.slot x, .slot y, .none, .none] "a" = some (.slot x) := by
    simp [opndVal, ho]
  have hvb' : opndVal op.info [.slot x, .slot y, .none, .none] "b" = some (.slot y) := by
    simp [opndVal, ho]
  have hrd : readAll (brCmpFp n) (opndVal op.info [.slot x, .slot y, .none, .none]) st =
      .ok [("a", ba), ("b", bb)] := by
    simp only [readAll, brCmpFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', hvb', Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .br_cmp [ty, o]
      (mkEnv [("a", ba), ("b", bb)] (opndVal op.info [.slot x, .slot y, .none, .none]) st ch) =
      .ok { ctl := .branch res, mem := st.mem, writes := [] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, out, hva, hvb,
      hres, bind, Except.bind, pure, Except.pure]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure, commit,
    List.foldlM_nil, hst]

/-- `br_cmp_imm` with any operator (`opSem_brCmpImm_fwd` is its `==` case): branch on the
handler's compare of the slot and the immediate's low `8 n` bits, the state unchanged.

Proof: `opSem_brCmpImm_fwd`'s, with `hres` in `kindSem` instead of `intCmp`'s `==` arm. -/
theorem opSem_brCmpImm_fwd' {op : Full.Opcode} {r : Option String} {ty o : String} {n : Nat}
    {sg : Bool} {k2 k3 k4 : OperandKind} {a : Int} {y : Nat} {st : OpSem.State}
    {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.br_cmp_imm, [ty, o], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"a", .slot⟩, ⟨"imm", k2⟩, ⟨"neg", k3⟩, ⟨"t", k4⟩])
    (hfa : Val.fits .slot (.slot a) = true) (hk2 : Val.fits k2 (.imm y) = true)
    (hk3 : Val.fits k3 .none = true) (hk4 : Val.fits k4 .none = true)
    {ba : List AbstractByte} {va : Nat} {res : Bool}
    (hra : st.readFrame a n = .ok ba) (hva : asNat ba = .ok va)
    (hres : intCmp o sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) y) = .ok res) :
    opSem op [.slot a, .imm y, .none, .none] st ch = .ok (.branch res, st) := by
  have hfp : footprint op = some { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch } := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.2.2.2.2.2.2
  have hprep : prepare op [.slot a, .imm y, .none, .none] =
      .ok (⟨.br_cmp_imm, [ty, o], r⟩,
        { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch },
        opndVal op.info [.slot a, .imm y, .none, .none]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfa, hk2, hk3, hk4])]
    rfl
  have hva' : opndVal op.info [.slot a, .imm y, .none, .none] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvy : opndVal op.info [.slot a, .imm y, .none, .none] "imm" = some (.imm y) := by
    simp [opndVal, ho]
  have hrd : readAll { reads := [Ryo.Proofs.Inline.rdA "a" n], flow := .branch }
      (opndVal op.info [.slot a, .imm y, .none, .none]) st = .ok [("a", ba)] := by
    simp only [readAll, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', Val.slotOff, Extent.eval, hra,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .br_cmp_imm [ty, o]
      (mkEnv [("a", ba)] (opndVal op.info [.slot a, .imm y, .none, .none]) st ch) =
      .ok { ctl := .branch res, mem := st.mem, writes := [] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, Env.immBv,
      Env.imm, out, hva, hvy, hres, bind, Except.bind, pure, Except.pure]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure, commit,
    List.foldlM_nil, hst]

end

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The checker's instruction forms -/

/-- `brCmpOps`'s facts.

Proof: as `brImmOps_spec` (`SimTerm.lean`): `unfold brCmpOps at h`, `split at h` three times,
`simp only [Bool.and_eq_true, beq_iff_eq]` on the condition, `Option.some.injEq`,
`Prod.mk.injEq`. -/
theorem brCmpOps_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {sg : Bool} {o : String} {x y : Int}
    {neg : Bool} {t : Nat} (h : brCmpOps Γ i n sg = some (o, x, y, neg, t)) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.br_cmp, [ty, o], r⟩ ∧
      cmpTyOk ty o n sg = true ∧ v.ops = [.slot x, .slot y, .none, .none] ∧
      v.ctl = some (.branch neg t) ∧
      v.op.info.operands = [⟨"a", .slot⟩, ⟨"b", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩] := by
  unfold brCmpOps at h
  split at h
  next v hv =>
    split at h
    next ty o' r x' y' neg' t' hh hops hctl =>
      split at h
      next hc =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := h
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        obtain ⟨hty, hk⟩ := hc
        exact ⟨v, ty, r, hv, hh, hty, hops, hctl, hk⟩
      next => cases h
    next => cases h
  next => cases h

/-- `brCmpImmOps`'s facts (as `brImmOps_spec`; `operands4` then gives the operand list). -/
theorem brCmpImmOps_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {sg : Bool} {o : String} {a : Int}
    {y : Nat} {neg : Bool} {t : Nat} (h : brCmpImmOps Γ i n sg = some (o, a, y, neg, t)) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.br_cmp_imm, [ty, o], r⟩ ∧
      cmpTyOk ty o n sg = true ∧ v.ops = [.slot a, .imm y, .none, .none] ∧
      v.ctl = some (.branch neg t) ∧
      v.op.info.operands.map (·.name) = ["a", "imm", "neg", "t"] ∧
      v.op.info.operands.head?.map (·.kind) = some .slot := by
  unfold brCmpImmOps at h
  split at h
  next v hv =>
    split at h
    next ty o' r a' y' neg' t' hh hops hctl =>
      split at h
      next hc =>
        simp only [Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := h
        simp only [Bool.and_eq_true, beq_iff_eq] at hc
        obtain ⟨⟨hty, hn⟩, hk⟩ := hc
        exact ⟨v, ty, r, hv, hh, hty, hops, hctl, hn, hk⟩
      next => cases h
    next => cases h
  next => cases h

/-! ### The branch forms -/

theorem dec_lt_nat (a b : Nat) : decide (a < b) = !decide (b ≤ a) := by
  by_cases h : b ≤ a <;> simp [h] <;> omega

theorem dec_lt_int (a b : Int) : decide (a < b) = !decide (b ≤ a) := by
  by_cases h : b ≤ a <;> simp [h] <;> omega

section
variable (sg : Bool) {w : Nat} (x y : BitVec w)
theorem intCmp_eq_ok : intCmp "==" sg x y = .ok (x == y) := rfl
theorem intCmp_ne_ok : intCmp "!=" sg x y = .ok (x != y) := rfl
theorem intCmp_lt_ok : intCmp "<" sg x y = .ok (if sg then x.slt y else x.ult y) := rfl
theorem intCmp_le_ok : intCmp "<=" sg x y = .ok (if sg then x.sle y else x.ule y) := rfl
theorem intCmp_gt_ok : intCmp ">" sg x y = .ok (if sg then y.slt x else y.ult x) := rfl
theorem intCmp_ge_ok : intCmp ">=" sg x y = .ok (if sg then y.sle x else y.ule x) := rfl
end

/-- The register branch form computes MIR's compare up to the polarity: L0's operator `o'`
(`cmpOp`) on `x, y` is the handler's `o` on the (maybe swapped) operands, negated when `pol`;
the sign condition (`cmpTyOk`'s) carries over.

Proof: `cases op <;> simp [brRegForm] at h`, `obtain ⟨rfl, rfl, rfl⟩ := h`, then per case
`refine ⟨_, rfl, by simp, ?_⟩`, `intro sg w x y res hr`, `simp only [intCmp] at hr ⊢`
(`Except.ok.inj`): `==`/`<`/swapped `<` are `rfl` (`">"` is `"<"` swapped by `intCmp`'s
definition); `!=` is `!(x == y)` (`Bool.not_not`); `>=` and `<=` against `<` swapped or not:
`cases sg` and `BitVec.not_lt`/`BitVec.not_slt`-style facts (`x.sle y = !y.slt x`,
`x.ule y = !y.ult x`: `BitVec.sle_iff_not_slt`, `BitVec.ule_iff_not_ult` or via `toInt`/`toNat`
and `decide`). -/
theorem brRegForm_spec {op : BinOp} {o : String} {sw pol : Bool}
    (h : brRegForm op = some (o, sw, pol)) :
    ∃ o', cmpOp op = some o' ∧ ((o' = "==" ∨ o' = "!=") ↔ (o = "==" ∨ o = "!=")) ∧
      ∀ (sg : Bool) {w : Nat} (x y : BitVec w) (res : Bool), intCmp o' sg x y = .ok res →
        intCmp o sg (if sw then y else x) (if sw then x else y) = .ok (res != pol) := by
  cases op <;> simp [brRegForm] at h <;> obtain ⟨rfl, rfl, rfl⟩ := h <;>
    refine ⟨_, rfl, by simp, ?_⟩ <;> intro sg w x y res hr
  -- eq
  · rw [intCmp_eq_ok] at hr
    obtain rfl := Except.ok.inj hr
    show intCmp "==" sg x y = _
    rw [intCmp_eq_ok]
    simp
  -- lt
  · rw [intCmp_lt_ok] at hr
    obtain rfl := Except.ok.inj hr
    show intCmp "<" sg x y = _
    rw [intCmp_lt_ok]
    simp
  -- le
  · rw [intCmp_le_ok] at hr
    obtain rfl := Except.ok.inj hr
    show intCmp "<" sg y x = _
    rw [intCmp_lt_ok]
    apply congrArg Except.ok
    cases sg <;> simp [BitVec.slt, BitVec.sle, BitVec.ult, BitVec.ule] <;>
      first | exact dec_lt_nat _ _ | exact dec_lt_int _ _
  -- ne
  · rw [intCmp_ne_ok] at hr
    obtain rfl := Except.ok.inj hr
    show intCmp "==" sg x y = _
    rw [intCmp_eq_ok]
    apply congrArg Except.ok
    cases h : (x == y) <;> simp [bne, h]
  -- ge
  · rw [intCmp_ge_ok] at hr
    obtain rfl := Except.ok.inj hr
    show intCmp "<" sg x y = _
    rw [intCmp_lt_ok]
    apply congrArg Except.ok
    cases sg <;> simp [BitVec.slt, BitVec.sle, BitVec.ult, BitVec.ule] <;>
      first | exact dec_lt_nat _ _ | exact dec_lt_int _ _
  -- gt
  · rw [intCmp_gt_ok] at hr
    obtain rfl := Except.ok.inj hr
    show intCmp "<" sg y x = _
    rw [intCmp_lt_ok]
    simp

/-- The immediate branch form: as `brRegForm_spec`, without a swap (`>`/`<=` use `br.gt.imm`).

Proof: as `brRegForm_spec`; `le` is `!(x > y)`. -/
theorem brImmForm_spec {op : BinOp} {o : String} {pol : Bool}
    (h : brImmForm op = some (o, pol)) :
    ∃ o', cmpOp op = some o' ∧ ((o' = "==" ∨ o' = "!=") ↔ (o = "==" ∨ o = "!=")) ∧
      ∀ (sg : Bool) {w : Nat} (x y : BitVec w) (res : Bool), intCmp o' sg x y = .ok res →
        intCmp o sg x y = .ok (res != pol) := by
  cases op <;> simp [brImmForm] at h <;> obtain ⟨rfl, rfl⟩ := h <;>
    refine ⟨_, rfl, by simp, ?_⟩ <;> intro sg w x y res hr
  -- eq
  · rw [intCmp_eq_ok] at hr
    obtain rfl := Except.ok.inj hr
    rw [intCmp_eq_ok]
    simp
  -- lt
  · rw [intCmp_lt_ok] at hr
    obtain rfl := Except.ok.inj hr
    rw [intCmp_lt_ok]
    simp
  -- le
  · rw [intCmp_le_ok] at hr
    obtain rfl := Except.ok.inj hr
    rw [intCmp_gt_ok]
    apply congrArg Except.ok
    cases sg <;> simp [BitVec.slt, BitVec.sle, BitVec.ult, BitVec.ule] <;>
      first | exact dec_lt_nat _ _ | exact dec_lt_int _ _
  -- ne
  · rw [intCmp_ne_ok] at hr
    obtain rfl := Except.ok.inj hr
    rw [intCmp_eq_ok]
    apply congrArg Except.ok
    cases h : (x == y) <;> simp [bne, h]
  -- ge
  · rw [intCmp_ge_ok] at hr
    obtain rfl := Except.ok.inj hr
    rw [intCmp_lt_ok]
    apply congrArg Except.ok
    cases sg <;> simp [BitVec.slt, BitVec.sle, BitVec.ult, BitVec.ule] <;>
      first | exact dec_lt_nat _ _ | exact dec_lt_int _ _
  -- gt
  · rw [intCmp_gt_ok] at hr
    obtain rfl := Except.ok.inj hr
    rw [intCmp_gt_ok]
    simp

/-! ### L0's side -/

/-! ### The fused assert (`LowerFused.assert`)

A compare feeding an `Assert` (`LowerFusedAssert`): as for the switch, L0's compare is matched
by no R step, and `sim_fusedAssert` is the second step from `MatchMid`. R branches on its own
compare (`fusedCmpBr_run`: the first half of `sim_fused`'s cases, shared by the register and
immediate forms through `FusedCmpBr`), taken exactly when MIR's compare `res` is `expected`
(`bne_bne_beq`). L0's assert reads back the stored `res` (`typedLoad_stored_bool`), so either
both go to the target (`FusedAssertOut`'s first disjunct, `sim_fused`'s former conclusion), or
L0 runs the panic call and R falls through to its code (the second: `SimTermMore.lean`'s
`AssertFails` facts for the frame one statement on, with the compare store's memory facts), where
the simulation stops for M5c. `FnRel` holds in both at `live'` without `_c` (`FnRel.store_dead`);
the panic call does not read `_c` (`hargs`). -/

theorem _root_.Ryo.Check.Lower.FusedCmpBr.kill {Γ : TermCtx} {st : Statement} {ibr : Insn}
    {c : Local} {pol neg : Bool} {t : Nat} (h : FusedCmpBr Γ st ibr c pol neg t) :
    stmtKill st = some c := by
  cases h <;> rfl

theorem _root_.Ryo.Check.Lower.FusedCmpBr.assign_shape {Γ : TermCtx} {st : Statement}
    {ibr : Insn} {c : Local} {pol neg : Bool} {t : Nat} (h : FusedCmpBr Γ st ibr c pol neg t) :
    ∃ c rv, st = .assign ⟨c, []⟩ rv := by
  cases h <;> exact ⟨_, _, rfl⟩

theorem _root_.Ryo.Check.Lower.LowerFusedAssert.assign_shape {Γ : TermCtx} {next : Nat}
    {st : Statement} {term : Terminator} {is : List Insn}
    (hlow : LowerFusedAssert Γ next st term is) :
    ∃ c rv, st = .assign ⟨c, []⟩ rv := by
  cases hlow with
  | mk hcmp _ _ _ _ _ => cases hcmp <;> exact ⟨_, _, rfl⟩

/-- The `bool` loaded back from a store of `boolByte res` is `res` (as in `fused_switch_l0`). -/
theorem typedLoad_stored_bool {m0 m : Memory} {pc : ThinPointer} {res : Bool} {w : Value}
    (hsto : m0.store pc (boolByte res) .one = .ok m) (hload : typedLoad m pc .bool .one = .ok w) :
    w = .bool res := by
  obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
  have hl2 := Ryo.Spec.Theorems.Memory.store_load_bytes hsto
  rw [boolByte_length res] at hl2
  rw [hl2] at hld
  have hbb : boolByte res = [.init (if res then 1 else 0) none] := by cases res <;> rfl
  rw [hbb] at hld
  simp only [Except.ok.injEq, List.cons.injEq, AbstractByte.init.injEq] at hld
  obtain ⟨⟨hdd, -⟩, -⟩ := hld
  cases res <;> rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;>
    first | rfl | (exfalso; revert hdd; decide) | (simp at hdd)

/-- The compare leaves L0's stack as it is (`fused_stmt_stack`'s proof, per form). -/
theorem fusedCmpBr_stmt_stack {Γ : TermCtx} {st : Statement} {ibr : Insn} {cl : Local}
    {pol neg : Bool} {t : Nat} (hcmp : FusedCmpBr Γ st ibr cl pol neg t) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (h : runOn (evalStatement st) o s = (.ok (), s')) :
    s'.stack = s.stack := by
  cases hcmp with
  | @reg cl a b oa ob op oh sw pol ty n sg sc sa sb ibr x y neg t hf ha hb htc hta htb hty hsc
      hsa hsb hsize hoff hpriv hbr hxy =>
    rw [eval_binop_norm ha hb] at h
    obtain ⟨o', hop, -, -⟩ := brRegForm_spec hf
    rw [hbody] at htc hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    have e6 : ty = tb := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
    obtain ⟨bsa, ua, -, -, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    obtain ⟨bsb, ub, -, -, -, hub, rfl⟩ := typedLoad_cmp hty hlb0
    obtain ⟨res, -, hev2⟩ := cmp_eval hop hty (cmpConstTy_self hty) (Or.inr rfl) hua hub o s
    rw [hev2] at hev
    obtain ⟨-, rfl⟩ := prod_ok_inj hev
    rw [hs']
  | @imm cl a oa op oh pol bits ty tc n sg sc sa ibr x y neg t hf ha htc hta hc hty hsc hsa
      hsize hoff hpriv hbr hx hy =>
    rw [eval_binopImm_norm ha] at h
    obtain ⟨o', hop, -, -⟩ := brImmForm_spec hf
    rw [hbody] at htc hta
    obtain ⟨pd, pa, td, ta, va, vc, w, hpd, hpa, htd', hta', hla0, hcst, s2, hev, mem', hst,
      hs'⟩ := assign_cmpImm_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    subst e4 e5
    obtain ⟨bsa, ua, -, -, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    have htc' : cmpOpnd tc = some (n, sg) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hty
    obtain ⟨hvc, hub, -⟩ := runOn_evalOperand_const_cmp htc' hcst
    obtain ⟨rfl, -⟩ := Prod.mk.inj hvc
    have hub' : cmpBitsOk ty (bits % 2 ^ (8 * n)) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hub
    obtain ⟨res, -, hev2⟩ := cmp_eval hop hty hc (Or.inr rfl) hua hub' o s
    rw [hev2] at hev
    obtain ⟨-, rfl⟩ := prod_ok_inj hev
    rw [hs']
  | @regU cl a b oa ob op oh sw pol ta tb n sc sa sb ibr x y neg t hf ha hb htc hta htb hk hsc
      hsa hsb hsize hoff hpriv hbr hxy =>
    rw [eval_binop_norm ha hb] at h
    obtain ⟨o', hop, -, -⟩ := brRegForm_spec hf
    rw [hbody] at htc hta htb
    obtain ⟨pd, pa, pb, td, ta', tb', va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ta = ta' := Option.some.inj (hta.symm.trans hta')
    have e6 : tb = tb' := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
    obtain ⟨bsa, ua, -, hda, hlena, hua⟩ := typedLoad_u (.inl hk) hla0
    obtain ⟨bsb, ub, -, hdb, hlenb, hub⟩ := typedLoad_u (.inr hk) hlb0
    have hua' : ua < 2 ^ (8 * n) := by
      have := Ryo.Proofs.Provenance.decodeBits_lt hda
      rw [hlena] at this
      exact this
    have hub' : ub < 2 ^ (8 * n) := by
      have := Ryo.Proofs.Provenance.decodeBits_lt hdb
      rw [hlenb] at this
      exact this
    obtain ⟨res, -, hev2⟩ := eval_ucmp (sg := false) hop (Or.inr rfl) hk hua hub hua' hub' o s
    rw [hev2] at hev
    obtain ⟨-, rfl⟩ := prod_ok_inj hev
    rw [hs']

theorem fusedAssert_stmt_stack {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerFusedAssert Γ next st term is) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (h : runOn (evalStatement st) o s = (.ok (), s')) :
    s'.stack = s.stack := by
  cases hlow with
  | mk hcmp _ _ _ _ _ => exact fusedCmpBr_stmt_stack hcmp hs hbody h

/-- The compare and R's branch (`sim_fused`'s first half): L0 stores MIR's compare `res` to
`_c`'s private slot, its stack unchanged, and R branches on `res != pol` with `neg`. -/
theorem fusedCmpBr_run {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {o0 : Spec.Oracle} {s0 sx : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs0 : s0.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) {next : Nat} {st : Statement} {ibr : Insn}
    {tl : List Insn} {cl : Local} {pol neg : Bool} {t : Nat}
    (hcmp : FusedCmpBr Γ st ibr cl pol neg t) (hat : TermAt c s1 next (ibr :: tl))
    (hpl : PlainView c.mode c.ρ ibr) (hrel : FnRel Γ.toStmtCtx ι live f s0.mem s1)
    (hlo : ∀ l ∈ stmtReads st, live l = true)
    (h1 : runOn (evalStatement st) o0 s0 = (.ok (), sx)) :
    ∃ pd sc res, f.locals[cl]? = some (some pd) ∧ Γ.slots[cl]? = some sc ∧ sc.size = 1 ∧
      (∀ k < sc.size, Γ.escaped (sc.off + k) = false) ∧ f.body.locals[cl]? = some .bool ∧
      s0.mem.store pd (boolByte res) .one = .ok sx.mem ∧ sx.stack = s0.stack ∧
      R.step c s1 ch =
        .ok (.step { s1 with pc := if (res != pol) != neg then t else s1.pc + 1 }) := by
  have hstk := fusedCmpBr_stmt_stack hcmp hs0 hbody h1
  cases hcmp with
  | @reg cl a b oa ob op oh sw pol ty n sg sc sa sb ibr x y neg t hf ha hb htc hta htb hty hsc
      hsa hsb hsize hoff hpriv hbr hxy =>
    have hlo' : ∀ l ∈ rvalueLocals (.binaryOp op oa ob), live l = true := hlo
    have hla := hlo' a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo' b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h1
    obtain ⟨vw, tys, r, hvw, hh, hty', hops, hctl, ho⟩ := brCmpOps_spec hbr
    rw [← hmode, ← hρ] at hvw
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨o', hop, hiff, hsw⟩ := brRegForm_spec hf
    rw [hbody] at htc hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs0 h1
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    have e6 : ty = tb := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    obtain ⟨bsb, ub, hlob, hdb, -, hub, rfl⟩ := typedLoad_cmp hty hlb0
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = sg := hsg.imp_left hiff.mpr
    obtain ⟨res, hres, hev2⟩ := cmp_eval hop hty (cmpConstTy_self hty) hsg' hua hub o0 s0
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hsto : s0.mem.store pd (boolByte res) .one = .ok sx.mem := by
      rw [hs']; exact typedStore_bool hst
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpbb hsb hlb
    rw [← hsize.2.1] at hloa
    rw [← hsize.2.2] at hlob
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    obtain ⟨bb', hrfb, hib⟩ := readLocal_inj hrel.frame.mem hrb hlob
    rw [hsize.2.1] at hrfa
    rw [hsize.2.2] at hrfb
    have hda' := decodeBits_inj hia hda
    have hdb' := decodeBits_inj hib hdb
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    have hvb : asNat bb' = .ok ub := by unfold asNat; rw [hdb']; rfl
    obtain ⟨hf1, hf2⟩ := offOk_spec hoff.1
    obtain ⟨hf3, hf4⟩ := offOk_spec hoff.2
    obtain ⟨rfl, rfl⟩ := hxy
    have hc := hsw sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub) res hres
    have hop' : opSem vw.op vw.ops s1.st ch = .ok (.branch (res != pol), s1.st) := by
      rw [hops]
      cases sw
      · exact opSem_brCmp_fwd hh hps ho ⟨hf1, hf2, hf3, hf4⟩ hrfa hrfb hva hvb hc
      · exact opSem_brCmp_fwd hh hps ho ⟨hf3, hf4, hf1, hf2⟩ hrfb hrfa hvb hva hc
    obtain ⟨hi0, hsc0⟩ := hat.head
    have hstep := step_branch hi0 hsc0 hat.pe hpl hvw hctl hop'
    exact ⟨pd, sc, res, hpd, hsc, hsize.1, hpriv, htc, hsto, hstk, hstep⟩
  | @imm cl a oa op oh pol bits ty tc n sg sc sa ibr x y neg t hf ha htc hta hc hty hsc hsa
      hsize hoff hpriv hbr hx hy =>
    have hlo' : ∀ l ∈ rvalueLocals (.binaryOp op oa (.const (.scalar bits) tc)),
        live l = true := hlo
    have hla := hlo' a (List.mem_append_left _ (operand_local_mem ha))
    rw [eval_binopImm_norm ha] at h1
    obtain ⟨vw, tys, r, hvw, hh, hty', hops, hctl, hn, hk⟩ := brCmpImmOps_spec hbr
    obtain ⟨k2, k3, k4, ho⟩ := operands4 hn hk
    rw [← hmode, ← hρ] at hvw
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨o', hop, hiff, hsw⟩ := brImmForm_spec hf
    rw [hbody] at htc hta
    obtain ⟨pd, pa, td, ta, va, vcst, w, hpd, hpa, htd', hta', hla0, hcst, s2, hev, mem', hst,
      hs'⟩ := assign_cmpImm_inv hs0 h1
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    subst e4 e5
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    have htc' : cmpOpnd tc = some (n, sg) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hty
    obtain ⟨hvc, hub, -⟩ := runOn_evalOperand_const_cmp htc' hcst
    obtain ⟨rfl, -⟩ := Prod.mk.inj hvc
    have hub' : cmpBitsOk ty (bits % 2 ^ (8 * n)) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hub
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = sg := hsg.imp_left hiff.mpr
    obtain ⟨res, hres, hev2⟩ := cmp_eval hop hty hc hsg' hua hub' o0 s0
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hsto : s0.mem.store pd (boolByte res) .one = .ok sx.mem := by
      rw [hs']; exact typedStore_bool hst
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hda' := decodeBits_inj hia hda
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    subst hx
    have hfits := hpl.fits vw hvw
    rw [ho, hops] at hfits
    simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
      Bool.and_true, Bool.and_eq_true] at hfits
    obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
    have hxe : BitVec.ofNat (8 * n) y = BitVec.ofNat (8 * n) (bits % 2 ^ (8 * n)) := by
      apply BitVec.eq_of_toNat_eq
      rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, Nat.mod_mod, hy]
    have hc' : intCmp oh sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) y) =
        .ok (res != pol) := by
      rw [hxe]; exact hsw sgh _ _ res hres
    have hop' : opSem vw.op vw.ops s1.st ch = .ok (.branch (res != pol), s1.st) := by
      rw [hops]
      exact opSem_brCmpImm_fwd' hh hps ho hfa hk2 hk3 hk4 hrfa hva hc'
    obtain ⟨hi0, hsc0⟩ := hat.head
    have hstep := step_branch hi0 hsc0 hat.pe hpl hvw hctl hop'
    exact ⟨pd, sc, res, hpd, hsc, hsize.1, hpriv, htc, hsto, hstk, hstep⟩
  | @regU cl a b oa ob op oh sw pol ta tb n sc sa sb ibr x y neg t hf ha hb htc hta htb hk hsc
      hsa hsb hsize hoff hpriv hbr hxy =>
    have hlo' : ∀ l ∈ rvalueLocals (.binaryOp op oa ob), live l = true := hlo
    have hla := hlo' a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo' b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h1
    obtain ⟨vw, tys, r, hvw, hh, hty', hops, hctl, ho⟩ := brCmpOps_spec hbr
    rw [← hmode, ← hρ] at hvw
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨o', hop, hiff, hsw⟩ := brRegForm_spec hf
    rw [hbody] at htc hta htb
    obtain ⟨pd, pa, pb, td, ta', tb', va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs0 h1
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ta = ta' := Option.some.inj (hta.symm.trans hta')
    have e6 : tb = tb' := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
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
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = false := hsg.imp_left hiff.mpr
    obtain ⟨res, hres, hev2⟩ := eval_ucmp hop hsg' hk hua hub hua' hub' o0 s0
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hsto : s0.mem.store pd (boolByte res) .one = .ok sx.mem := by
      rw [hs']; exact typedStore_bool hst
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpbb hsb hlb
    rw [← hsize.2.1] at hloa
    rw [← hsize.2.2] at hlob
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    obtain ⟨bb', hrfb, hib⟩ := readLocal_inj hrel.frame.mem hrb hlob
    rw [hsize.2.1] at hrfa
    rw [hsize.2.2] at hrfb
    have hda' := decodeBits_inj hia hda
    have hdb' := decodeBits_inj hib hdb
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    have hvb : asNat bb' = .ok ub := by unfold asNat; rw [hdb']; rfl
    obtain ⟨hf1, hf2⟩ := offOk_spec hoff.1
    obtain ⟨hf3, hf4⟩ := offOk_spec hoff.2
    obtain ⟨rfl, rfl⟩ := hxy
    have hc := hsw sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub) res hres
    have hop' : opSem vw.op vw.ops s1.st ch = .ok (.branch (res != pol), s1.st) := by
      rw [hops]
      cases sw
      · exact opSem_brCmp_fwd hh hps ho ⟨hf1, hf2, hf3, hf4⟩ hrfa hrfb hva hvb hc
      · exact opSem_brCmp_fwd hh hps ho ⟨hf3, hf4, hf1, hf2⟩ hrfb hrfa hvb hva hc
    obtain ⟨hi0, hsc0⟩ := hat.head
    have hstep := step_branch hi0 hsc0 hat.pe hpl hvw hctl hop'
    exact ⟨pd, sc, res, hpd, hsc, hsize.1, hpriv, htc, hsto, hstk, hstep⟩

/-- `sim_fused`'s liveness premise without `_c`'s name. -/
theorem hw_of_kill {live live' : Local → Bool} {st : Statement} {c : Local}
    (hkill : stmtKill st = some c)
    (hw : ∀ l, live' l = true → live l = true ∧ stmtKill st ≠ some l) :
    ∀ l, live' l = true → live l = true ∧ l ≠ c := fun l hl =>
  ⟨(hw l hl).1, fun e => (hw l hl).2 (by rw [hkill, e])⟩

/-- R's branch condition in terms of MIR's compare: `(res != pol) != (pol == e)` is
`res == e`. -/
theorem bne_bne_beq (r p e : Bool) : ((r != p) != (p == e)) = (r == e) := by
  cases r <;> cases p <;> cases e <;> rfl

/-! ### The rule -/

/-- `sim_fusedAssert`'s conclusion (see the module comment): `sim_fused`'s, or the failing
path's facts (`AssertFails` for the frame one statement on, with the compare's memory facts). -/
def FusedAssertOut (Γ : TermCtx) (c : Code) (ch : OpSem.Choice) (ι : Inj)
    (live' : Local → Bool) (o : Spec.Oracle) (s0 s s' : Spec.State) (f : Spec.Frame)
    (rest : List Spec.Frame) (s1 : RState) (next : Nat) (term : Terminator) : Prop :=
  (∃ s1' b', StepsTo c ch s1 s1' ∧ s'.stack = { f with bb := b', stmt := 0 } :: rest ∧
      b' ∈ termSuccs term ∧ blockStart Γ b' = some s1'.pc ∧ ProvBounded s'.mem ∧
      s'.mem.allocs.size = s0.mem.allocs.size ∧ MemKept s0.mem s'.mem ∧
      FnRel Γ.toStmtCtx ι live' { f with bb := b', stmt := 0 } s'.mem s1') ∨
    (∃ msg unwind s1' tl, (∃ od e target, term = .assert od e msg target unwind) ∧
      StepsTo c ch s1 s1' ∧ s1'.st = s1.st ∧ s1'.fp = s1.fp ∧ TermAt c s1' next tl ∧
      s.stack = { f with stmt := f.stmt + 1 } :: rest ∧ ProvBounded s.mem ∧
      s.mem.allocs.size = s0.mem.allocs.size ∧ MemKept s0.mem s.mem ∧
      FnRel Γ.toStmtCtx ι live' { f with stmt := f.stmt + 1 } s.mem s1' ∧
      runOn (assertPanic msg unwind) o s = (.ok (), s'))

/-- The fused assert (see the module comment), with `sim_fused`'s hypotheses.

Proof: `fusedCmpBr_run` (the store of `res`, the stack, R's branch); L0's assert by
`assert_local_inv` at the frame one statement on (`_c`'s pointer and type as the compare's),
`typedLoad_stored_bool` for its value `res`, `assert_bool_step`; R's condition
`(res != pol) != (pol == expected)` is `res == expected` (`cases`); then the memory facts and
`FnRel.store_dead` as in `sim_fused`. -/
theorem sim_fusedAssert {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o0 o : Spec.Oracle} {s0 sx s s' : Spec.State}
    {f f1 : Spec.Frame} {rest rest1 : List Spec.Frame} (hs0 : s0.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {next : Nat} {st : Statement} {term : Terminator} {is : List Insn}
    (hlow : LowerFusedAssert Γ next st term is) (hat : TermAt c s1 next is)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s0.mem s1) (hpb : ProvBounded s0.mem)
    (hlo : ∀ l ∈ stmtReads st, live l = true)
    (hw : ∀ l, live' l = true → live l = true ∧ stmtKill st ≠ some l)
    (h1 : runOn (evalStatement st) o0 s0 = (.ok (), sx)) (hsx : sx.stack = f1 :: rest1)
    (hs : s = { sx with stack := { f1 with stmt := f1.stmt + 1 } :: rest1 })
    (h2 : runOn (evalTerminator term) o s = (.ok (), s')) :
    FusedAssertOut Γ c ch ι live' o s0 s s' f rest s1 next term := by
  cases hlow with
  | mk hcmp hd hneg ht hdead hargs =>
    have hkill := hcmp.kill
    obtain ⟨pd, sc, res, hpd, hsc, hsz, hpriv, htc, hsto, hsxs, hstep⟩ :=
      fusedCmpBr_run (ch := ch) hs0 hbody hmode hρ hcmp hat (hpl _ (List.mem_cons_self ..)) hrel
        hlo h1
    have hstk : f :: rest = f1 :: rest1 := by rw [← hsx, hsxs, hs0]
    obtain ⟨rfl, rfl⟩ := List.cons.inj hstk
    have hsS : s.stack = { f with stmt := f.stmt + 1 } :: rest := by rw [hs]
    have hm : s.mem = sx.mem := by rw [hs]
    -- L0's assert reads back `res`
    obtain ⟨p, ty, v, hp, hty, hload, h3⟩ := assert_local_inv hsS hd h2
    have hpp : p = pd := Option.some.inj (Option.some.inj (hp.symm.trans hpd))
    subst hpp
    have hty' : ty = .bool := Option.some.inj (hty.symm.trans htc)
    subst hty'
    rw [hm] at hload
    obtain rfl := typedLoad_stored_bool hsto hload
    -- R's condition
    subst hneg
    rw [bne_bne_beq] at hstep
    -- the facts both paths share
    have hnp : ∀ b ∈ boolByte res, b.provFrag = none := by
      first
        | exact encodeBits_noprov 1 _
        | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
    have hpos : 0 < sc.size := by rw [hsz]; exact Nat.one_pos
    have hw' := hw_of_kill hkill hw
    have hrel' := FnRel.store_dead hrel hpd hsc hpos hpriv hsto hnp hw'
    rcases assert_bool_step hsS h3 with ⟨he, hs'⟩ | ⟨hne, hpan⟩
    · have hc := beq_iff_eq.mpr he
      simp only [hc, eq_self_iff_true, if_true, ↓reduceIte] at hstep
      have hm' : s'.mem = sx.mem := by rw [hs', hm]
      refine .inl ⟨_, _, .cons hstep (.refl _), ?_, by simp [termSuccs], ht,
        ?_, ?_, ?_, ?_⟩
      · rw [hs']
        try rfl
      · rw [hm']; exact hpb.store_noprov hsto hnp
      · rw [hm']; exact store_size hsto
      · rw [hm']; exact memKept_noprov hsto hnp
      · rw [hm']; exact hrel'.congr rfl rfl rfl rfl
    · have hc := beq_eq_false_iff_ne.mpr hne
      simp only [hc, Bool.false_eq_true, if_false, ↓reduceIte] at hstep
      refine .inr ⟨_, _, _, _, ⟨_, _, _, rfl⟩,
        .cons hstep (.refl _), rfl, rfl, hat.tail, hsS, ?_, ?_, ?_, ?_, hpan⟩
      · rw [hm]; exact hpb.store_noprov hsto hnp
      · rw [hm]; exact store_size hsto
      · rw [hm]; exact memKept_noprov hsto hnp
      · rw [hm]; exact hrel'.congr rfl rfl rfl rfl

/-- `fused_live`'s case: `_c` is dead at every successor (`hdead`). -/
theorem fusedAssert_kill {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerFusedAssert Γ next st term is) {b' : Nat}
    (hsucc : b' ∈ termSuccs term) :
    ∃ c, stmtKill st = some c ∧ (computeLive Γ.body).get b' 0 c = false := by
  cases hlow with
  | mk hcmp _ _ _ hdead _ =>
    refine ⟨_, hcmp.kill, ?_⟩
    unfold deadAtSuccs at hdead
    have h := List.all_eq_true.mp hdead b' hsucc
    simpa using h

/-- L0's switch on a `bool` local just stored as `boolByte res`: the target is
`selBool v bb otherwise res`.

Proof: `switchInt_inv hs hd h` (pointer `pc` by `hpc`, type `.bool` by `htc`); `typedLoad_bool`
gives the one byte `[.init d pr]` and the value; `Ryo.Spec.Theorems.Memory.store_load_bytes hsto` (the load of
the stored bytes, `boolByte res = [.init (if res then 1 else 0) none]` by `cases res <;> rfl`)
gives `d`, so the value is `.bool res`; `switchBits (.bool res, _) = if res then 1 else 0`
(`rfl`), `find_single`, `bool_target hv`. -/
theorem fused_switch_l0 {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {c : Local} {od : Operand}
    (hd : od.local? = some c) {pc : ThinPointer} (hpc : f.locals[c]? = some (some pc))
    (htc : f.body.locals[c]? = some .bool) {m0 : Memory} {res : Bool}
    (hsto : m0.store pc (boolByte res) .one = .ok s.mem) {v : Nat} (hv : v < 2)
    {bb otherwise : BasicBlock}
    (h : runOn (evalTerminator (.switchInt od [(v, bb)] otherwise)) o s = (.ok (), s')) :
    s' = { s with stack := { f with bb := selBool v bb otherwise res, stmt := 0 } :: rest } := by
  obtain ⟨p, ty0, w, bits, hp, hty', hload, hsw, hs'⟩ := switchInt_inv hs hd h
  rw [hpc] at hp
  obtain rfl := Option.some.inj (Option.some.inj hp)
  rw [htc] at hty'
  obtain rfl := (Option.some.inj hty').symm
  obtain ⟨dd, pr, hld, hcase⟩ := typedLoad_bool hload
  have hl2 := Ryo.Spec.Theorems.Memory.store_load_bytes hsto
  rw [boolByte_length res] at hl2
  rw [hl2] at hld
  have hbb : boolByte res = [.init (if res then 1 else 0) none] := by cases res <;> rfl
  rw [hbb] at hld
  simp only [Except.ok.injEq, List.cons.injEq, AbstractByte.init.injEq] at hld
  obtain ⟨⟨hdd, -⟩, -⟩ := hld
  have hw : w = .bool res := by
    cases res <;> rcases hcase with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;>
      first | rfl | (exfalso; revert hdd; decide) | (simp at hdd)
  subst hw
  have hbits : bits = if res then 1 else 0 := by
    have e : runOn (switchBits (.bool res, .bool)) o s = (.ok (if res then 1 else 0), s) := rfl
    rw [e] at hsw
    simp only [Prod.mk.injEq, Except.ok.injEq] at hsw
    exact hsw.1.symm
  subst hbits
  rw [find_single] at hs'
  rw [hs', ← bool_target hv bb otherwise]
  by_cases hvb : v = (if res then 1 else 0)
  · rw [if_pos hvb, if_pos hvb]
  · rw [if_neg hvb, if_neg hvb]

/-- A fused rule's compare leaves L0's stack as it is (so `MatchMid`'s `f1 :: rest1` is the
compare point's frame and stack), which `fn_step_sim_ret` needs to step L0's switch from there.

Proof: `cases hlow`; `eval_binop_norm`/`eval_binopImm_norm`, `assign_binop_inv`/
`assign_cmpImm_inv` (`s' = { s2 with mem := mem' }`), and `evalBinOp` of a comparison returns
the state unchanged (`typedLoad_cmp` both operands, `runOn_evalOperand_const_cmp`, then
`cmp_eval`'s `(.ok (.bool res), s)` against the inversion's `s2`: `prod_ok_inj`). -/
theorem fused_stmt_stack {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerFused Γ next st term is) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (h : runOn (evalStatement st) o s = (.ok (), s')) :
    s'.stack = s.stack := by
  cases hlow with
  | niche hn => exact niche_stmt_stack hn hs hbody h
  | nicheDense hn => exact nicheDense_stmt_stack hn hs hbody h
  | assert ha => exact fusedAssert_stmt_stack ha hs hbody h
  | sw hcmp => exact fusedCmpBr_stmt_stack hcmp hs hbody h
  | @reg cl a b oa ob od op oh sw pol ty n sg sc sa sb v bb otherwise ibr tl x y neg t hf ha hb
      hd htc hta htb hty hsc hsa hsb hsize hoff hpriv hbr hxy hv hsel hdead =>
    rw [eval_binop_norm ha hb] at h
    obtain ⟨o', hop, -, -⟩ := brRegForm_spec hf
    rw [hbody] at htc hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    have e6 : ty = tb := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
    obtain ⟨bsa, ua, -, -, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    obtain ⟨bsb, ub, -, -, -, hub, rfl⟩ := typedLoad_cmp hty hlb0
    obtain ⟨res, -, hev2⟩ := cmp_eval hop hty (cmpConstTy_self hty) (Or.inr rfl) hua hub o s
    rw [hev2] at hev
    obtain ⟨-, rfl⟩ := prod_ok_inj hev
    rw [hs']
  | @imm cl a oa od op oh pol bits ty tc n sg sc sa v bb otherwise ibr tl x y neg t hf ha hd
      htc hta hc hty hsc hsa hsize hoff hpriv hbr hx hy hv hsel hdead =>
    rw [eval_binopImm_norm ha] at h
    obtain ⟨o', hop, -, -⟩ := brImmForm_spec hf
    rw [hbody] at htc hta
    obtain ⟨pd, pa, td, ta, va, vc, w, hpd, hpa, htd', hta', hla0, hcst, s2, hev, mem', hst,
      hs'⟩ := assign_cmpImm_inv hs h
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    subst e4 e5
    obtain ⟨bsa, ua, -, -, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    have htc' : cmpOpnd tc = some (n, sg) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hty
    obtain ⟨hvc, hub, -⟩ := runOn_evalOperand_const_cmp htc' hcst
    obtain ⟨rfl, -⟩ := Prod.mk.inj hvc
    have hub' : cmpBitsOk ty (bits % 2 ^ (8 * n)) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hub
    obtain ⟨res, -, hev2⟩ := cmp_eval hop hty hc (Or.inr rfl) hua hub' o s
    rw [hev2] at hev
    obtain ⟨-, rfl⟩ := prod_ok_inj hev
    rw [hs']

/-! ### The invariant between the two L0 steps -/

/-- L0 between a fused block's compare and its switch (see the module comment): `s` is
`step`'s result of the compare `st` (the block's last statement, index `blk.stmts.size`)
evaluated from `s0`, which `MatchAt` relates to `s1`, at a block `reach` holds of (the
function simulation's reachable blocks, `Check/Lower/Reach.lean`). -/
def MatchMid (Γ : TermCtx) (reach : Nat → Bool) (ι : Inj) (s : Spec.State) (s1 : RState) :
    Prop :=
  ∃ (s0 sx : Spec.State) (o0 : Spec.Oracle) (f : Spec.Frame) (rest : List Spec.Frame)
    (blk : BlockCert) (bd : BlockData) (st : Statement) (f1 : Spec.Frame)
    (rest1 : List Spec.Frame),
    MatchAt Γ ι s0 s1 f rest blk bd ∧ reach f.bb = true ∧ blk.fused = true ∧
      f.stmt = blk.stmts.size ∧
      bd.stmts[f.stmt]? = some st ∧ runOn (evalStatement st) o0 s0 = (.ok (), sx) ∧
      sx.stack = f1 :: rest1 ∧ s = { sx with stack := { f1 with stmt := f1.stmt + 1 } :: rest1 }

/-! ### The rule -/

/-- The fused pair (see the module comment): from `FnRel` at the compare's point (`live`, which
has the compare's operands, `hlo`), L0's compare (`h1`, its `step` result `s`) and switch
(`h2`), R runs from the terminator range's start (`hat`) to the start of L0's target `b'`, a
successor of the switch, with `FnRel` at any `live'` within `live` that lacks `_c`
(`stmtKill st`): `FusedAssertOut`'s first disjunct; its second is a fused assert's failing path
(`sim_fusedAssert`).

Proof: `cases hlow`; per rule, L0's compare as in `lift_cmp` (`eval_binop_norm`/
`eval_binopImm_norm`, `assign_binop_inv`/`assign_cmpImm_inv` with `hs0`, `hbody` to identify
the types, `typedLoad_cmp`, `runOn_evalOperand_const_cmp` for `imm`, `brRegForm_spec`/
`brImmForm_spec` for `cmpOp op = some o'` and the sign condition, `cmp_eval`), `typedStore_bool`
(the store of `boolByte res` at `_c`'s pointer `pc`; `sx.stack = s0.stack`, so `f1 = f`,
`rest1 = rest`); R's reads (`hrel.opnd` with `hlo`, `readLocal_inj`, `decodeBits_inj`, `asNat`);
the handler's result `cb = res != pol` (`brRegForm_spec`'s implication, `Bool` xor
involutive); `brCmpOps_spec`/`brCmpImmOps_spec`, `opSem_brCmp_fwd`/`opSem_brCmpImm_fwd'` (for
the immediate, `BitVec.ofNat (8 * n) y = BitVec.ofNat (8 * n) (bits % 2 ^ (8 * n))` from `hy`
as in `lift_cmp`), `step_branch` (`hat.head`, `hpl`, `hat.pe`), `branch_run` with `hsel`: R at
`blockStart Γ (fusedSel pol v bb otherwise cb)`, which is `selBool v bb otherwise res`;
`fused_switch_l0` (with `s.mem = sx.mem`) for L0's target; `b' ∈ termSuccs` by `selBool`'s
two values; `FnRel.store_dead` (`hw`, `stmtKill` of the compare is `some c`) then
`FnRel.congr` (R's state and `fp` unchanged by `branch_run`); `ProvBounded.store_noprov` and
`store_size` for the memory facts. -/
theorem sim_fused {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o0 o : Spec.Oracle} {s0 sx s s' : Spec.State}
    {f f1 : Spec.Frame} {rest rest1 : List Spec.Frame} (hs0 : s0.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {next : Nat} {st : Statement} {term : Terminator} {is : List Insn}
    (hlow : LowerFused Γ next st term is) (hat : TermAt c s1 next is)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i)
    (hrel : FnRel Γ.toStmtCtx ι live f s0.mem s1) (hpb : ProvBounded s0.mem)
    (hlo : ∀ l ∈ stmtReads st, live l = true)
    (hw : ∀ l, live' l = true → live l = true ∧ stmtKill st ≠ some l)
    (h1 : runOn (evalStatement st) o0 s0 = (.ok (), sx)) (hsx : sx.stack = f1 :: rest1)
    (hs : s = { sx with stack := { f1 with stmt := f1.stmt + 1 } :: rest1 })
    (h2 : runOn (evalTerminator term) o s = (.ok (), s')) :
    FusedAssertOut Γ c ch ι live' o s0 s s' f rest s1 next term := by
  cases hlow with
  | niche hn =>
    exact .inl (sim_fusedNiche hs0 hbody hmode hρ hn hat hpl hrel hpb hlo hw h1 hsx hs h2)
  | nicheDense hn =>
    exact .inl (sim_fusedNicheDense hs0 hbody hmode hρ hn hat hpl hrel hpb hlo hw h1 hsx hs h2)
  | assert ha =>
    exact sim_fusedAssert hs0 hbody hmode hρ ha hat hpl hrel hpb hlo hw h1 hsx hs h2
  | @sw st od cl pol neg t v bb otherwise ibr tl hcmp hd hv hsel hdead =>
    obtain ⟨pd, sc, res, hpd, hsc, hsc1, hpriv, htc, hsto, hstk0, hstep⟩ :=
      fusedCmpBr_run (ch := ch) hs0 hbody hmode hρ hcmp hat (hpl ibr (List.mem_cons_self ..))
        hrel hlo h1
    obtain ⟨s2', hst2, hb2, hsst, hfp2, -⟩ := branch_run hstep hsel hat
    have hstk : f :: rest = f1 :: rest1 := by
      rw [← hsx, hstk0]
      exact hs0.symm
    obtain ⟨rfl, rfl⟩ := List.cons.inj hstk
    have hsS : s.stack = { f with stmt := f.stmt + 1 } :: rest := by rw [hs]
    have hstoS : s0.mem.store pd (boolByte res) .one = .ok s.mem := by rw [hs]; exact hsto
    have hs2 := fused_switch_l0 (f := { f with stmt := f.stmt + 1 }) hsS hd hpd htc hstoS hv h2
    have hm' : s'.mem = sx.mem := by rw [hs2, hs]
    have hnp : ∀ b ∈ boolByte res, b.provFrag = none := by
      first
        | exact encodeBits_noprov 1 _
        | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
    have hpos : 0 < sc.size := by rw [hsc1]; exact Nat.one_pos
    have hw' : ∀ l, live' l = true → live l = true ∧ l ≠ cl := fun l hl =>
      ⟨(hw l hl).1, fun e => (hw l hl).2 (by subst e; exact hcmp.kill)⟩
    have hxor : ((res != pol) != pol) = res := by cases res <;> cases pol <;> rfl
    have hb3 : blockStart Γ (selBool v bb otherwise res) = some s2'.pc := by
      unfold fusedSel at hb2
      rw [hxor] at hb2
      exact hb2
    refine .inl ⟨s2', selBool v bb otherwise res, hst2, ?_, ?_, hb3, ?_, ?_, ?_, ?_⟩
    · rw [hs2]
      try rfl
    · unfold selBool
      split <;> simp [termSuccs]
    · rw [hm']; exact hpb.store_noprov hsto hnp
    · rw [hm']; exact store_size hsto
    · rw [hm']; exact memKept_noprov hsto hnp
    · rw [hm']
      exact (FnRel.store_dead hrel hpd hsc hpos hpriv hsto hnp hw').congr rfl rfl hsst hfp2
  | @reg cl a b oa ob od op oh sw pol ty n sg sc sa sb v bb otherwise ibr tl x y neg t hf ha hb
      hd htc hta htb hty hsc hsa hsb hsize hoff hpriv hbr hxy hv hsel hdead =>
    have hlo' : ∀ l ∈ rvalueLocals (.binaryOp op oa ob), live l = true := hlo
    have hla := hlo' a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo' b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h1
    obtain ⟨vw, tys, r, hvw, hh, hty', hops, hctl, ho⟩ := brCmpOps_spec hbr
    rw [← hmode, ← hρ] at hvw
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨o', hop, hiff, hsw⟩ := brRegForm_spec hf
    rw [hbody] at htc hta htb
    obtain ⟨pd, pa, pb, td, ta, tb, va, vb, w, hpd, hpa, hpbb, htd', hta', htb', hla0, hlb0, s2,
      hev, mem', hst, hs'⟩ := assign_binop_inv hs0 h1
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    have e6 : ty = tb := Option.some.inj (htb.symm.trans htb')
    subst e4 e5 e6
    -- L0: the loads, the comparison, the store
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    obtain ⟨bsb, ub, hlob, hdb, -, hub, rfl⟩ := typedLoad_cmp hty hlb0
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = sg := hsg.imp_left hiff.mpr
    obtain ⟨res, hres, hev2⟩ := cmp_eval hop hty (cmpConstTy_self hty) hsg' hua hub o0 s0
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hsto : s0.mem.store pd (boolByte res) .one = .ok sx.mem := by
      rw [hs']; exact typedStore_bool hst
    -- R's reads
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpbb hsb hlb
    rw [← hsize.2.1] at hloa
    rw [← hsize.2.2] at hlob
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    obtain ⟨bb', hrfb, hib⟩ := readLocal_inj hrel.frame.mem hrb hlob
    rw [hsize.2.1] at hrfa
    rw [hsize.2.2] at hrfb
    have hda' := decodeBits_inj hia hda
    have hdb' := decodeBits_inj hib hdb
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    have hvb : asNat bb' = .ok ub := by unfold asNat; rw [hdb']; rfl
    -- R's branch
    obtain ⟨hf1, hf2⟩ := offOk_spec hoff.1
    obtain ⟨hf3, hf4⟩ := offOk_spec hoff.2
    obtain ⟨rfl, rfl⟩ := hxy
    have hc := hsw sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) ub) res hres
    have hop' : opSem vw.op vw.ops s1.st ch = .ok (.branch (res != pol), s1.st) := by
      rw [hops]
      cases sw
      · exact opSem_brCmp_fwd hh hps ho ⟨hf1, hf2, hf3, hf4⟩ hrfa hrfb hva hvb hc
      · exact opSem_brCmp_fwd hh hps ho ⟨hf3, hf4, hf1, hf2⟩ hrfb hrfa hvb hva hc
    obtain ⟨hi0, hsc0⟩ := hat.head
    have hstep := step_branch hi0 hsc0 hat.pe (hpl ibr (List.mem_cons_self ..)) hvw hctl hop'
    obtain ⟨s2', hst2, hb2, hsst, hfp2, -⟩ := branch_run hstep hsel hat

    have hstk : f :: rest = f1 :: rest1 := by
      rw [← hsx, hs']
      exact hs0.symm
    obtain ⟨rfl, rfl⟩ := List.cons.inj hstk
    -- L0's switch
    have hsS : s.stack = { f with stmt := f.stmt + 1 } :: rest := by rw [hs]
    have hstoS : s0.mem.store pd (boolByte res) .one = .ok s.mem := by rw [hs]; exact hsto
    have hs2 := fused_switch_l0 (f := { f with stmt := f.stmt + 1 }) hsS hd hpd htc hstoS hv h2
    have hm' : s'.mem = sx.mem := by rw [hs2, hs]
    have hnp : ∀ b ∈ boolByte res, b.provFrag = none := by
      first
        | exact encodeBits_noprov 1 _
        | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
    have hpos : 0 < sc.size := by rw [hsize.1]; exact Nat.one_pos
    have hw' : ∀ l, live' l = true → live l = true ∧ l ≠ cl := fun l hl =>
      ⟨(hw l hl).1, fun e => (hw l hl).2 (by subst e; rfl)⟩
    have hxor : ((res != pol) != pol) = res := by cases res <;> cases pol <;> rfl
    have hb3 : blockStart Γ (selBool v bb otherwise res) = some s2'.pc := by
      unfold fusedSel at hb2
      rw [hxor] at hb2
      exact hb2
    refine .inl ⟨s2', selBool v bb otherwise res, hst2, ?_, ?_, hb3, ?_, ?_, ?_, ?_⟩
    · rw [hs2]
      try rfl
    · unfold selBool
      split <;> simp [termSuccs]
    · rw [hm']; exact hpb.store_noprov hsto hnp
    · rw [hm']; exact store_size hsto
    · rw [hm']; exact memKept_noprov hsto hnp
    · rw [hm']
      exact (FnRel.store_dead hrel hpd hsc hpos hpriv hsto hnp hw').congr rfl rfl hsst hfp2
  | @imm cl a oa od op oh pol bits ty tc n sg sc sa v bb otherwise ibr tl x y neg t hf ha hd
      htc hta hc hty hsc hsa hsize hoff hpriv hbr hx hy hv hsel hdead =>
    have hlo' : ∀ l ∈ rvalueLocals (.binaryOp op oa (.const (.scalar bits) tc)),
        live l = true := hlo
    have hla := hlo' a (List.mem_append_left _ (operand_local_mem ha))
    rw [eval_binopImm_norm ha] at h1
    obtain ⟨vw, tys, r, hvw, hh, hty', hops, hctl, hn, hk⟩ := brCmpImmOps_spec hbr
    obtain ⟨k2, k3, k4, ho⟩ := operands4 hn hk
    rw [← hmode, ← hρ] at hvw
    obtain ⟨sgh, hps, hsg⟩ := cmpTyOk_spec hty'
    obtain ⟨o', hop, hiff, hsw⟩ := brImmForm_spec hf
    rw [hbody] at htc hta
    obtain ⟨pd, pa, td, ta, va, vcst, w, hpd, hpa, htd', hta', hla0, hcst, s2, hev, mem', hst,
      hs'⟩ := assign_cmpImm_inv hs0 h1
    have e4 : td = .bool := Option.some.inj (htd'.symm.trans htc)
    have e5 : ty = ta := Option.some.inj (hta.symm.trans hta')
    subst e4 e5
    -- L0: the load, the constant, the comparison, the store
    obtain ⟨bsa, ua, hloa, hda, -, hua, rfl⟩ := typedLoad_cmp hty hla0
    have htc' : cmpOpnd tc = some (n, sg) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hty
    obtain ⟨hvc, hub, -⟩ := runOn_evalOperand_const_cmp htc' hcst
    obtain ⟨rfl, -⟩ := Prod.mk.inj hvc
    have hub' : cmpBitsOk ty (bits % 2 ^ (8 * n)) := by
      rcases cmpConstTy_spec hc with ⟨t, vc', valid, rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> exact hub
    have hsg' : (o' = "==" ∨ o' = "!=") ∨ sgh = sg := hsg.imp_left hiff.mpr
    obtain ⟨res, hres, hev2⟩ := cmp_eval hop hty hc hsg' hua hub' o0 s0
    rw [hev2] at hev
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hev
    have hsto : s0.mem.store pd (boolByte res) .one = .ok sx.mem := by
      rw [hs']; exact typedStore_bool hst
    -- R's read
    have hra := hrel.opnd hpa hsa hla
    rw [← hsize.2] at hloa
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
    rw [hsize.2] at hrfa
    have hda' := decodeBits_inj hia hda
    have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
    -- R's branch
    subst hx
    have hfits := (hpl ibr (List.mem_cons_self ..)).fits vw hvw
    rw [ho, hops] at hfits
    simp only [List.zip_cons_cons, List.zip_nil_left, List.all_cons, List.all_nil,
      Bool.and_true, Bool.and_eq_true] at hfits
    obtain ⟨hfa, hk2, hk3, hk4⟩ := hfits
    have hxe : BitVec.ofNat (8 * n) y = BitVec.ofNat (8 * n) (bits % 2 ^ (8 * n)) := by
      apply BitVec.eq_of_toNat_eq
      rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, Nat.mod_mod, hy]
    have hc' : intCmp oh sgh (BitVec.ofNat (8 * n) ua) (BitVec.ofNat (8 * n) y) =
        .ok (res != pol) := by
      rw [hxe]; exact hsw sgh _ _ res hres
    have hop' : opSem vw.op vw.ops s1.st ch = .ok (.branch (res != pol), s1.st) := by
      rw [hops]
      exact opSem_brCmpImm_fwd' hh hps ho hfa hk2 hk3 hk4 hrfa hva hc'
    obtain ⟨hi0, hsc0⟩ := hat.head
    have hstep := step_branch hi0 hsc0 hat.pe (hpl ibr (List.mem_cons_self ..)) hvw hctl hop'
    obtain ⟨s2', hst2, hb2, hsst, hfp2, -⟩ := branch_run hstep hsel hat

    have hstk : f :: rest = f1 :: rest1 := by
      rw [← hsx, hs']
      exact hs0.symm
    obtain ⟨rfl, rfl⟩ := List.cons.inj hstk
    -- L0's switch
    have hsS : s.stack = { f with stmt := f.stmt + 1 } :: rest := by rw [hs]
    have hstoS : s0.mem.store pd (boolByte res) .one = .ok s.mem := by rw [hs]; exact hsto
    have hs2 := fused_switch_l0 (f := { f with stmt := f.stmt + 1 }) hsS hd hpd htc hstoS hv h2
    have hm' : s'.mem = sx.mem := by rw [hs2, hs]
    have hnp : ∀ b ∈ boolByte res, b.provFrag = none := by
      first
        | exact encodeBits_noprov 1 _
        | (unfold boolByte intBytes; exact encodeBits_noprov 1 _)
    have hpos : 0 < sc.size := by rw [hsize.1]; exact Nat.one_pos
    have hw' : ∀ l, live' l = true → live l = true ∧ l ≠ cl := fun l hl =>
      ⟨(hw l hl).1, fun e => (hw l hl).2 (by subst e; rfl)⟩
    have hxor : ((res != pol) != pol) = res := by cases res <;> cases pol <;> rfl
    have hb3 : blockStart Γ (selBool v bb otherwise res) = some s2'.pc := by
      unfold fusedSel at hb2
      rw [hxor] at hb2
      exact hb2
    refine .inl ⟨s2', selBool v bb otherwise res, hst2, ?_, ?_, hb3, ?_, ?_, ?_, ?_⟩
    · rw [hs2]
      try rfl
    · unfold selBool
      split <;> simp [termSuccs]
    · rw [hm']; exact hpb.store_noprov hsto hnp
    · rw [hm']; exact store_size hsto
    · rw [hm']; exact memKept_noprov hsto hnp
    · rw [hm']
      exact (FnRel.store_dead hrel hpd hsc hpos hpriv hsto hnp hw').congr rfl rfl hsst hfp2

/-- A fused rule's compare kills `_c`, which is dead at both successors' entries: the
liveness `fn_step_sim_ret` gives `sim_fused` at the successor (`computeLive … b' 0`) lies within
the compare point's without `_c`.

Proof: `cases hlow`; `deadAtSuccs` (`List.all_eq_true`, `b' ∈ termSuccs` is `bb` or
`otherwise`) gives `live b' 0 c = false`; `hlv.term`'s second part (successor entry within the
terminator point, `blk.stmts.size + 1 = bd.stmts.length`) and `hlv.stmt`'s first (the compare's
point, `l ≠ c = stmtKill st`). -/
theorem fused_live {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (hlow : LowerFused Γ next st term is)
    (hlv : LiveSound Γ.body (computeLive Γ.body).get) {b : Nat} {bd : BlockData} {k : Nat}
    (hbd : Γ.body.blocks[b]? = some bd) (hst : bd.stmts[k]? = some st)
    (hlen : k + 1 = bd.stmts.length) (hterm : bd.term = term) {b' : Nat}
    (hsucc : b' ∈ termSuccs term) :
    ∀ l, (computeLive Γ.body).get b' 0 l = true →
      (computeLive Γ.body).get b k l = true ∧ stmtKill st ≠ some l := by
  have hkc : ∃ c, stmtKill st = some c ∧ (computeLive Γ.body).get b' 0 c = false := by
    cases hlow
    case niche hn => exact niche_kill hn hsucc
    case nicheDense hn => exact nicheDense_kill hn hsucc
    case assert ha => exact fusedAssert_kill ha hsucc
    case sw =>
      refine ⟨_, (‹FusedCmpBr Γ _ _ _ _ _ _›).kill, ?_⟩
      have hdead := ‹deadAtSuccs Γ _ [_, _] = true›
      simp [termSuccs] at hsucc
      simp [deadAtSuccs] at hdead
      rcases hsucc with rfl | rfl
      · first | exact hdead.1 | simp_all
      · first | exact hdead.2 | simp_all
    all_goals
      refine ⟨_, rfl, ?_⟩
      have hdead := ‹deadAtSuccs Γ _ [_, _] = true›
      simp [termSuccs] at hsucc
      simp [deadAtSuccs] at hdead
      rcases hsucc with rfl | rfl
      · first | exact hdead.1 | simp_all
      · first | exact hdead.2 | simp_all
  obtain ⟨c, hkc, hcd⟩ := hkc
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

end Ryo.Proofs.Lower
