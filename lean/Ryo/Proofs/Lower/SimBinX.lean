/-
Ryo.Proofs.Lower.SimBinX — the simulation of `LowerBinX`'s rules (M5b, `Check/Lower/BinX.lean`):
unchecked arithmetic, shifts, division and remainder, one handler instruction with a private
destination.

- The arithmetic (`BinRefines`): when L0's `evalIntBinOp op t l r` succeeds, it leaves the state
  unchanged and yields an integer whose bit pattern is R's result on the operands' bit patterns.
  Unchecked `add`/`sub`/`mul` (`refines_unchecked`): L0's success means no overflow, and the
  exact result has the wrapped one's bits (`intBin_wrap`). Shifts (`refines_shift`): L0's amount
  is `rhs.rem_euclid(bits)` (`rhs` itself for the unchecked forms, in range on success:
  `shift_ok`), R's the amount operand's bits modulo the width (`amt_of_imm`, the width dividing
  the moduli); `shl` wraps both sides (`shl_arith`), `shr` is floor division by `2 ^ k`, on the
  unsigned value or on the two's complement one (`shr_arith`, `ofBits_signed`, `toBits_toInt`).
  `div`/`rem` (`refines_divrem`): L0's success means a non-zero divisor and a representable
  quotient, so R's `unchecked_*` checks pass (`divrem_guards`: `MIN / -1` overflows); the
  results are `udiv`/`umod` on the unsigned values, `sdiv`/`srem` (`tdiv`/`tmod`, the former
  wrapped by `bmod`) on the signed ones (`div_val`, `rem_val`).
- R: `opSem_binX_fwd`/`opSem_binImmX_fwd`, `opSem_bin_fwd`/`opSem_binImm_fwd` for the
  handler kinds `binKd`/`binImmKd` (same footprint and `kindSem` branch).
- `sim_binX`/`sim_binImmX`: `sim_binop`/`sim_binImm` (`SimBinOp.lean`, `SimBinImm.lean`) over
  `BinRefines`, with the common write `sim_int_write`, also giving L0's provenance-free store.
- `lift_binX`: the rules lifted to R's `step` (`LiftOut`), as `lift_unop` (`SimUnop.lean`).
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Check.Lower.BinX

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The instruction forms -/

theorem intTyOkS_spec {ty : String} {n : Nat} {chk sg0 : Bool}
    (h : intTyOkS ty n chk sg0 = true) :
    ∃ sg, OpSem.Ty.parse ty = some (.int n sg) ∧ (chk = true → sg = sg0) := by
  unfold intTyOkS at h
  split at h
  next n' sg hp =>
    simp only [Bool.and_eq_true, beq_iff_eq] at h
    obtain ⟨rfl, h2⟩ := h
    refine ⟨sg, hp, fun hc => ?_⟩
    subst hc
    simpa using h2
  · cases h

theorem binKd_cases {kd : Handlers.HandlerKind} (h : binKd kd = true) :
    kd = .bin ∨ kd = .bin_fn ∨ kd = .binop ∨ kd = .shift := by
  simp only [binKd, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with ((h | h) | h) | h <;> simp [h]

theorem binImmKd_cases {kd : Handlers.HandlerKind} (h : binImmKd kd = true) :
    kd = .bin_imm ∨ kd = .binop_imm ∨ kd = .shift_imm := by
  simp only [binImmKd, Bool.or_eq_true, beq_iff_eq] at h
  rcases h with (h | h) | h <;> simp [h]

theorem binXInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {m : String} {n : Nat} {chk sg0 : Bool}
    {d a b : Int} (h : binXInsnOk Γ i m n chk sg0 d a b = true) :
    ∃ v kd ty r, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨kd, [ty, m], r⟩ ∧
      binKd kd = true ∧ intTyOkS ty n chk sg0 = true ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] ∧
      v.ops = [.slot d, .slot a, .slot b] ∧ v.ctl = some .next := by
  unfold binXInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty m' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨hkd, hm⟩, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hm
      exact ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩
    · cases h
  · cases h

theorem binImmXInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {m : String} {n : Nat} {chk sg0 : Bool}
    {d a : Int} {q bits : Nat} (h : binImmXInsnOk Γ i m n chk sg0 d a q bits = true) :
    ∃ v kd ty r, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨kd, [ty, m], r⟩ ∧
      binImmKd kd = true ∧ intTyOkS ty n chk sg0 = true ∧
      v.op.info.operands.map (·.name) = ["d", "a", "imm"] ∧
      (v.op.info.operands.take 2).map (·.kind) = [.slot, .slot] ∧
      immOpsModOk v.ops [d, a] q bits = true ∧ v.ctl = some .next := by
  unfold binImmXInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty m' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨hkd, hm⟩, hty⟩, hn⟩, hk⟩, hops⟩, hctl⟩ := h
      subst hm
      exact ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩
    · cases h
  · cases h

theorem shiftOk_spec {t tc : IntType} (h : shiftOk t tc = true) :
    (8 * t.size) ∣ 2 ^ (8 * t.size) ∧ (8 * t.size) ∣ 2 ^ (8 * tc.size) := by
  simp only [shiftOk, Bool.and_eq_true, beq_iff_eq] at h
  exact ⟨Nat.dvd_of_mod_eq_zero h.1, Nat.dvd_of_mod_eq_zero h.2⟩

/-! ### R -/

theorem fp_binX {kd : Handlers.HandlerKind} (hkd : binKd kd = true) {ty : String}
    {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf kd (ty :: ps) = some (binFp n) := by
  rcases binKd_cases hkd with rfl | rfl | rfl | rfl <;>
    first
      | (simp only [footprintOf, List.head?, Option.bind_some, h]; done)
      | (simp only [footprintOf, List.head?, Option.bind_some, h]; rfl)
      | (simp [footprintOf, binFp, h]; done)
      | (simp [footprintOf, binFp, h]; rfl)

theorem fp_binImmX {kd : Handlers.HandlerKind} (hkd : binImmKd kd = true) {ty : String}
    {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf kd (ty :: ps) = some (binImmFp n) := by
  rcases binImmKd_cases hkd with rfl | rfl | rfl <;>
    first
      | (simp only [footprintOf, List.head?, Option.bind_some, h]; done)
      | (simp only [footprintOf, List.head?, Option.bind_some, h]; rfl)
      | (simp [footprintOf, binImmFp, h]; done)
      | (simp [footprintOf, binImmFp, h]; rfl)

/-- `opSem_bin_fwd` for the handler kinds `binKd` (`bin`, `bin_fn`, `binop`, `shift`). -/
theorem opSem_binX_fwd {op : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String}
    {ty m : String} {n : Nat} {sg : Bool} {d a b : Int} {st st' : OpSem.State}
    {ch : OpSem.Choice}
    (hkd : binKd kd = true) (hh : op.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31 ∧ -2 ^ 31 ≤ b ∧ b < 2 ^ 31)
    {ba bb : List AbstractByte} {va vb : Nat} {res : BitVec (8 * n)}
    (hra : st.readFrame a n = .ok ba) (hrb : st.readFrame b n = .ok bb)
    (hva : asNat ba = .ok va) (hvb : asNat bb = .ok vb)
    (hres : intBin m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res)
    (hw : st.writeFrame d (intBytes n res.toNat) = .ok st') :
    opSem op [.slot d, .slot a, .slot b] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2, hb1, hb2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfb := slot_fits hb1 hb2
  have hfp : footprint op = some (binFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact fp_binX hkd (Ryo.Proofs.Inline.tySize_of_parse hty)
  have hprep : prepare op [.slot d, .slot a, .slot b] =
      .ok (⟨kd, [ty, m], r⟩, (binFp n),
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
  have hrd : readAll (binFp n) (opndVal op.info [.slot d, .slot a, .slot b]) st =
      .ok [("a", ba), ("b", bb)] := by
    simp only [readAll, binFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', hvb', Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem kd [ty, m] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes n res.toNat)] } := by
    rcases binKd_cases hkd with rfl | rfl | rfl | rfl <;>
      simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, out, hva, hvb,
        hres, bind, Except.bind, pure, Except.pure]
  have hlen : (intBytes n res.toNat).length = n := Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (binFp n) (opndVal op.info [.slot d, .slot a, .slot b]) st
      [("d", intBytes n res.toNat)] = .ok st' := by
    simp only [commit, binFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen, hw,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

/-- `opSem_binImm_fwd` for the handler kinds `binImmKd` (`bin_imm`, `binop_imm`, `shift_imm`). -/
theorem opSem_binImmX_fwd {op : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String}
    {ty m : String} {n : Nat} {sg : Bool} {k : OperandKind} {d a : Int} {v : Nat}
    {st st' : OpSem.State} {ch : OpSem.Choice}
    (hkd : binImmKd kd = true) (hh : op.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31)
    (hfk : Val.fits k (.imm v) = true)
    {ba : List AbstractByte} {va : Nat} {res : BitVec (8 * n)}
    (hra : st.readFrame a n = .ok ba) (hva : asNat ba = .ok va)
    (hres : intBin m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) v) = .ok res)
    (hw : st.writeFrame d (intBytes n res.toNat) = .ok st') :
    opSem op [.slot d, .slot a, .imm v] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfp : footprint op = some (binImmFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact fp_binImmX hkd (Ryo.Proofs.Inline.tySize_of_parse hty)
  have hprep : prepare op [.slot d, .slot a, .imm v] =
      .ok (⟨kd, [ty, m], r⟩, (binImmFp n),
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
  have hrd : readAll (binImmFp n) (opndVal op.info [.slot d, .slot a, .imm v]) st =
      .ok [("a", ba)] := by
    simp only [readAll, binImmFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', Val.slotOff, Extent.eval, hra,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem kd [ty, m] (mkEnv [("a", ba)]
      (opndVal op.info [.slot d, .slot a, .imm v]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes n res.toNat)] } := by
    rcases binImmKd_cases hkd with rfl | rfl | rfl <;>
      simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, Env.immBv,
        Env.imm, hvi', out, hva, hres, bind, Except.bind, pure, Except.pure]
  have hlen : (intBytes n res.toNat).length = n := Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (binImmFp n) (opndVal op.info [.slot d, .slot a, .imm v]) st
      [("d", intBytes n res.toNat)] = .ok st' := by
    simp only [commit, binImmFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen,
      hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

/-! ### L0 -/

theorem runOn_ite_ub {α : Type} {c : Bool} {x : SemM α} {msg : String} {o : Spec.Oracle}
    {s s1 : Spec.State} {v : α} (h : runOn (if c then x else throwUb msg) o s = (.ok v, s1)) :
    c = true ∧ runOn x o s = (.ok v, s1) := by
  cases c
  · have h' : ((Except.error (Outcome.ub msg), s) : Except Outcome α × Spec.State) =
        (.ok v, s1) := h
    exact (prod_err_ok h').elim
  · exact ⟨rfl, h⟩

theorem runOn_ite_ub' {α : Type} {c : Bool} {x : SemM α} {msg : String} {o : Spec.Oracle}
    {s s1 : Spec.State} {v : α} (h : runOn (if c then throwUb msg else x) o s = (.ok v, s1)) :
    c = false ∧ runOn x o s = (.ok v, s1) := by
  cases c
  · exact ⟨rfl, h⟩
  · have h' : ((Except.error (Outcome.ub msg), s) : Except Outcome α × Spec.State) =
        (.ok v, s1) := h
    exact (prod_err_ok h').elim

/-- A successful unchecked `add`/`sub`/`mul`: the state is unchanged, and the result has the
wrapping operator's bits. -/
theorem unchecked_ok {op op' : BinOp}
    (hu : (op = .addUnchecked ∧ op' = .add) ∨ (op = .subUnchecked ∧ op' = .sub) ∨
      (op = .mulUnchecked ∧ op' = .mul))
    {t : IntType} {l r : Int} {dt : Spec.Ty} {o : Spec.Oracle} {s s1 : Spec.State} {v : Value}
    (h : runOn (evalIntBinOp op t l r dt) o s = (.ok v, s1)) :
    s1 = s ∧ ∃ i, v = .int i ∧ t.toBits i = t.toBits (wrapResult op' t l r) := by
  rcases hu with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · obtain ⟨msg, e⟩ : ∃ msg : String, runOn (evalIntBinOp .addUnchecked t l r dt) o s =
        runOn (if t.canRepresent (l + r) then (pure (.int (l + r)) : SemM Value)
          else throwUb msg) o s := ⟨_, rfl⟩
    rw [e] at h
    obtain ⟨-, h2⟩ := runOn_ite_ub h
    rw [runOn_pure] at h2
    obtain ⟨hv, hs⟩ := prod_ok_inj h2
    exact ⟨hs.symm, l + r, hv.symm, (Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
      (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (l + r))).symm⟩
  · obtain ⟨msg, e⟩ : ∃ msg : String, runOn (evalIntBinOp .subUnchecked t l r dt) o s =
        runOn (if t.canRepresent (l - r) then (pure (.int (l - r)) : SemM Value)
          else throwUb msg) o s := ⟨_, rfl⟩
    rw [e] at h
    obtain ⟨-, h2⟩ := runOn_ite_ub h
    rw [runOn_pure] at h2
    obtain ⟨hv, hs⟩ := prod_ok_inj h2
    exact ⟨hs.symm, l - r, hv.symm, (Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
      (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (l - r))).symm⟩
  · obtain ⟨msg, e⟩ : ∃ msg : String, runOn (evalIntBinOp .mulUnchecked t l r dt) o s =
        runOn (if t.canRepresent (l * r) then (pure (.int (l * r)) : SemM Value)
          else throwUb msg) o s := ⟨_, rfl⟩
    rw [e] at h
    obtain ⟨-, h2⟩ := runOn_ite_ub h
    rw [runOn_pure] at h2
    obtain ⟨hv, hs⟩ := prod_ok_inj h2
    exact ⟨hs.symm, l * r, hv.symm, (Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
      (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (l * r))).symm⟩

def isShl : BinOp → Bool
  | .shl | .shlUnchecked => true
  | _ => false

/-- L0's shift result by `k` (left: wrapped multiplication, right: floor division). -/
def shiftResult (left : Bool) (t : IntType) (l : Int) (k : Nat) : Int :=
  match left with
  | true => t.bringInBounds (l * 2 ^ k)
  | false => l / 2 ^ k

theorem shiftAmt_eq {r b : Int} (hc : (decide (r < 0) || decide (r ≥ b)) = false) :
    r % b = r := by
  simp only [Bool.or_eq_false_iff, decide_eq_false_iff_not] at hc
  obtain ⟨h1, h2⟩ := hc
  exact Int.emod_eq_of_lt (by omega) (by omega)

/-- A successful shift: the state is unchanged, the amount is `r.rem_euclid(bits)` (`r` itself
for the unchecked forms, which are UB unless it is in range). -/
theorem shift_ok {op : BinOp} (hop : isShift op = true) {t : IntType} {l r : Int}
    {dt : Spec.Ty} {o : Spec.Oracle} {s s1 : Spec.State} {v : Value}
    (h : runOn (evalIntBinOp op t l r dt) o s = (.ok v, s1)) :
    s1 = s ∧ v = .int (shiftResult (isShl op) t l (r % (t.bits : Int)).toNat) := by
  cases op
  case shl =>
    have e : runOn (evalIntBinOp .shl t l r dt) o s =
        (.ok (.int (t.bringInBounds (l * 2 ^ (r % (t.bits : Int)).toNat))), s) := rfl
    rw [e] at h
    obtain ⟨h1, h2⟩ := prod_ok_inj h
    exact ⟨h2.symm, h1.symm⟩
  case shr =>
    have e : runOn (evalIntBinOp .shr t l r dt) o s =
        (.ok (.int (l / 2 ^ (r % (t.bits : Int)).toNat)), s) := rfl
    rw [e] at h
    obtain ⟨h1, h2⟩ := prod_ok_inj h
    exact ⟨h2.symm, h1.symm⟩
  case shlUnchecked =>
    first
    | (have e : runOn (evalIntBinOp .shlUnchecked t l r dt) o s =
          runOn ((if r < 0 || r ≥ (t.bits : Int) then throwUb "overflow in unchecked shift"
            else pure r : SemM Int) >>= fun k =>
            (pure (.int (t.bringInBounds (l * 2 ^ k.toNat))) : SemM Value)) o s := by
         first
           | rfl
           | (simp only [evalIntBinOp]; done)
           | (unfold evalIntBinOp; rfl)
       rw [e] at h
       obtain ⟨k, s2, h1, h2⟩ := runOn_bind_ok h
       obtain ⟨hc, h3⟩ := runOn_ite_ub' h1
       try dsimp only at h2
       rw [runOn_pure] at h3 h2
       obtain ⟨hk, hs2⟩ := prod_ok_inj h3
       rw [← hk, ← hs2] at h2
       obtain ⟨h4, h5⟩ := prod_ok_inj h2
       refine ⟨h5.symm, ?_⟩
       rw [← h4]
       show Value.int (t.bringInBounds (l * 2 ^ r.toNat)) = Value.int (t.bringInBounds (l * 2 ^ (r % (t.bits : Int)).toNat))
       rw [shiftAmt_eq hc])
    | (first
         | simp only [evalIntBinOp] at h
         | (unfold evalIntBinOp at h; simp only at h)
       split at h
       · exact (prod_err_ok h).elim
       · rename_i hc
         have h' : ((Except.ok (Value.int (t.bringInBounds (l * 2 ^ r.toNat))), s) :
             Except Outcome Value × Spec.State) = (.ok v, s1) := h
         obtain ⟨h4, h5⟩ := prod_ok_inj h'
         refine ⟨h5.symm, ?_⟩
         rw [← h4]
         show Value.int (t.bringInBounds (l * 2 ^ r.toNat)) = Value.int (t.bringInBounds (l * 2 ^ (r % (t.bits : Int)).toNat))
         have hr : r % (t.bits : Int) = r := by
           try simp only [Bool.or_eq_true, decide_eq_true_eq, not_or] at hc
           exact Int.emod_eq_of_lt (by omega) (by omega)
         rw [hr])
  case shrUnchecked =>
    first
    | (have e : runOn (evalIntBinOp .shrUnchecked t l r dt) o s =
          runOn ((if r < 0 || r ≥ (t.bits : Int) then throwUb "overflow in unchecked shift"
            else pure r : SemM Int) >>= fun k =>
            (pure (.int (l / 2 ^ k.toNat)) : SemM Value)) o s := by
         first
           | rfl
           | (simp only [evalIntBinOp]; done)
           | (unfold evalIntBinOp; rfl)
       rw [e] at h
       obtain ⟨k, s2, h1, h2⟩ := runOn_bind_ok h
       obtain ⟨hc, h3⟩ := runOn_ite_ub' h1
       try dsimp only at h2
       rw [runOn_pure] at h3 h2
       obtain ⟨hk, hs2⟩ := prod_ok_inj h3
       rw [← hk, ← hs2] at h2
       obtain ⟨h4, h5⟩ := prod_ok_inj h2
       refine ⟨h5.symm, ?_⟩
       rw [← h4]
       show Value.int (l / 2 ^ r.toNat) = Value.int (l / 2 ^ (r % (t.bits : Int)).toNat)
       rw [shiftAmt_eq hc])
    | (first
         | simp only [evalIntBinOp] at h
         | (unfold evalIntBinOp at h; simp only at h)
       split at h
       · exact (prod_err_ok h).elim
       · rename_i hc
         have h' : ((Except.ok (Value.int (l / 2 ^ r.toNat)), s) :
             Except Outcome Value × Spec.State) = (.ok v, s1) := h
         obtain ⟨h4, h5⟩ := prod_ok_inj h'
         refine ⟨h5.symm, ?_⟩
         rw [← h4]
         show Value.int (l / 2 ^ r.toNat) = Value.int (l / 2 ^ (r % (t.bits : Int)).toNat)
         have hr : r % (t.bits : Int) = r := by
           try simp only [Bool.or_eq_true, decide_eq_true_eq, not_or] at hc
           exact Int.emod_eq_of_lt (by omega) (by omega)
         rw [hr])
  all_goals exact absurd hop (by decide)

/-! ### Arithmetic -/

/-- R's method `m` (signedness `sg`) on `A`, `B` refines L0's operator on `l`, `r` at `t`. -/
def BinRefines (op : BinOp) (m : String) (sg : Bool) (t : IntType) (l r : Int)
    (A B : BitVec (8 * t.size)) : Prop :=
  ∀ (dt : Spec.Ty) (o : Spec.Oracle) (s s1 : Spec.State) (v : Value),
    runOn (evalIntBinOp op t l r dt) o s = (.ok v, s1) →
    s1 = s ∧ ∃ i res, v = .int i ∧ intBin m sg A B = .ok res ∧ res.toNat = t.toBits i

theorem refines_unchecked {op op' : BinOp} {m : String}
    (hu : (op = .addUnchecked ∧ op' = .add) ∨ (op = .subUnchecked ∧ op' = .sub) ∨
      (op = .mulUnchecked ∧ op' = .mul))
    (hm : binMethod op' = some m) (t : IntType) (sg : Bool) (u w : Nat) :
    BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u) (BitVec.ofNat _ w) := by
  intro dt o s s1 v h
  obtain ⟨hs1, i, rfl, hi⟩ := unchecked_ok hu h
  obtain ⟨res, hres, hrn⟩ := intBin_wrap hm t sg u w
  exact ⟨hs1, i, res, rfl, hres, hrn.trans hi.symm⟩

theorem mul_emod_congr {a b c M : Int} (h : a % M = b % M) : (a * c) % M = (b * c) % M := by
  rw [Int.mul_emod a c M, h, ← Int.mul_emod b c M]

theorem ofBits_unsigned {t : IntType} (h : t.signed = false) (u : Nat) :
    t.ofBits u = ((u % t.modulus : Nat) : Int) := by
  unfold IntType.ofBits
  simp [h]

theorem ofBits_signed {t : IntType} (hs : t.signed = true) (hpos : 0 < t.size) (u : Nat) :
    t.ofBits u = (BitVec.ofNat (8 * t.size) u).toInt := by
  have hW := modulus_eq_two_pow t
  -- `t.size : Size` (an `abbrev` of `Nat`), which `omega` doesn't see through
  have hb : 1 ≤ t.bits := by
    have h8 : (t.size : Nat) ≤ t.size * 8 := Nat.le_mul_of_pos_right _ (by decide)
    exact Nat.le_trans hpos h8
  have hM : t.modulus = 2 * 2 ^ (t.bits - 1) := by
    unfold IntType.modulus
    rw [← Nat.pow_succ']; congr 1; omega
  have hm := Nat.mod_lt u (Ryo.Spec.Theorems.IntType.modulus_pos t)
  rw [BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat, hW]
  unfold IntType.ofBits
  simp only [hs, Bool.true_and, decide_eq_true_eq]
  generalize u % t.modulus = n at hm ⊢
  generalize 2 ^ (t.bits - 1) = H at hM ⊢
  generalize t.modulus = M at hM hm ⊢
  split <;> split <;> omega

theorem toBits_natCast_lt (t : IntType) {n : Nat} (h : n < t.modulus) :
    t.toBits (n : Int) = n := by
  have h' : (n : Int) < (t.modulus : Int) := by omega
  unfold IntType.toBits
  simp only [Int.emod_eq_of_lt (Int.natCast_nonneg n) h', Int.toNat_natCast]

/-- The bits of a bit vector's two's complement value are the bit vector's. -/
theorem toBits_toInt (t : IntType) (x : BitVec (8 * t.size)) : t.toBits x.toInt = x.toNat := by
  have hW := modulus_eq_two_pow t
  have hx := x.isLt
  unfold IntType.toBits
  rw [BitVec.toInt_eq_toNat_cond, ← hW]
  generalize x.toNat = X at hx ⊢
  generalize 2 ^ (8 * t.size) = P at hx ⊢
  have h1 : (X : Int) < (P : Int) := by omega
  split
  · simp only [Int.emod_eq_of_lt (Int.natCast_nonneg X) h1, Int.toNat_natCast]
  · have e : ((X : Int) - (P : Int)) = (X : Int) + (P : Int) * (-1) := by omega
    rw [e, Int.add_mul_emod_self_left]
    simp only [Int.emod_eq_of_lt (Int.natCast_nonneg X) h1, Int.toNat_natCast]

theorem shl_arith {t : IntType} {sg : Bool} {u k : Nat} {B : BitVec (8 * t.size)}
    (hamt : B.toNat % (8 * t.size) = k) :
    ∃ res, intBin "wrapping_shl" sg (BitVec.ofNat (8 * t.size) u) B = .ok res ∧
      res.toNat = t.toBits (shiftResult true t (t.ofBits u) k) := by
  refine ⟨_, rfl, ?_⟩
  have hW := modulus_eq_two_pow t
  rw [hamt, BitVec.toNat_shiftLeft, BitVec.toNat_ofNat, Nat.shiftLeft_eq, hW]
  show u % t.modulus * 2 ^ k % t.modulus = t.toBits (t.bringInBounds (t.ofBits u * 2 ^ k))
  rw [Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
    (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (t.ofBits u * 2 ^ k))]
  refine (toBits_of_emod_nat t ?_).symm
  rw [mul_emod_congr (Ryo.Spec.Theorems.IntType.ofBits_emod t u), Int.natCast_mul,
    Int.natCast_emod]
  exact (mul_emod_congr (Int.emod_emod (u : Int) (t.modulus : Int))).symm

theorem shr_arith {t : IntType} (hpos : 0 < t.size) {u k : Nat} {B : BitVec (8 * t.size)}
    (hamt : B.toNat % (8 * t.size) = k) :
    ∃ res, intBin "wrapping_shr" t.signed (BitVec.ofNat (8 * t.size) u) B = .ok res ∧
      res.toNat = t.toBits (shiftResult false t (t.ofBits u) k) := by
  refine ⟨_, rfl, ?_⟩
  rw [hamt]
  show _ = t.toBits (t.ofBits u / 2 ^ k)
  have hW := modulus_eq_two_pow t
  cases hsg : t.signed
  · rw [if_neg Bool.false_ne_true, BitVec.toNat_ushiftRight, BitVec.toNat_ofNat,
      Nat.shiftRight_eq_div_pow, hW, ofBits_unsigned hsg]
    show _ = t.toBits ((u % t.modulus / 2 ^ k : Nat) : Int)
    rw [toBits_natCast_lt t (Nat.lt_of_le_of_lt (Nat.div_le_self (u % t.modulus) (2 ^ k))
      (Nat.mod_lt u (Ryo.Spec.Theorems.IntType.modulus_pos t)))]
  · rw [if_pos (rfl : true = true), ofBits_signed hsg hpos]
    have e : ((BitVec.ofNat (8 * t.size) u).sshiftRight k).toInt =
        (BitVec.ofNat (8 * t.size) u).toInt / 2 ^ k :=
      (BitVec.toInt_sshiftRight (x := BitVec.ofNat (8 * t.size) u) (n := k)).trans
        (Int.shiftRight_eq_div_pow _ k)
    rw [← e, toBits_toInt]

/-- R's shift amount (the operand's bits modulo the width) is L0's (`r.rem_euclid(bits)`), for
an immediate `x` congruent to the constant `bits : tc` modulo the width. -/
theorem amt_of_imm {t tc : IntType} {x bits : Nat} (hd1 : (8 * t.size) ∣ 2 ^ (8 * t.size))
    (hd2 : (8 * t.size) ∣ 2 ^ (8 * tc.size)) (hx : x % (8 * t.size) = bits % (8 * t.size)) :
    (BitVec.ofNat (8 * t.size) x).toNat % (8 * t.size) =
      (tc.ofBits (bits % 2 ^ (8 * tc.size)) % (t.bits : Int)).toNat := by
  rw [BitVec.toNat_ofNat, Nat.mod_mod_of_dvd x hd1, hx]
  have hb : (t.bits : Int) = ((8 * t.size : Nat) : Int) := by
    unfold IntType.bits; rw [Nat.mul_comm]
  have hW := modulus_eq_two_pow tc
  have hd : ((8 * t.size : Nat) : Int) ∣ (tc.modulus : Int) := by
    rw [← hW]; exact Int.ofNat_dvd.mpr hd2
  rw [hb, ← Int.emod_emod_of_dvd (tc.ofBits (bits % 2 ^ (8 * tc.size))) hd,
    Ryo.Spec.Theorems.IntType.ofBits_emod, hW, Int.natCast_emod bits tc.modulus, Int.emod_emod,
    Int.emod_emod_of_dvd (bits : Int) hd, ← Int.natCast_emod, Int.toNat_natCast]

theorem refines_shift {op : BinOp} {m : String} (hm : binXMethod op = some m)
    (hop : isShift op = true) {t : IntType} (hpos : 0 < t.size) {sg : Bool}
    (hsg : binXSigned op = true → sg = t.signed) (u : Nat) {r : Int} {B : BitVec (8 * t.size)}
    (hamt : B.toNat % (8 * t.size) = (r % (t.bits : Int)).toNat) :
    BinRefines op m sg t (t.ofBits u) r (BitVec.ofNat _ u) B := by
  intro dt o s s1 v h
  obtain ⟨hs1, hv⟩ := shift_ok hop h
  subst hv
  refine ⟨hs1, ?_⟩
  cases op
  case shl =>
    obtain rfl : "wrapping_shl" = m := Option.some.inj hm
    obtain ⟨res, h1, h2⟩ := shl_arith (sg := sg) (u := u) hamt
    exact ⟨_, res, rfl, h1, h2⟩
  case shlUnchecked =>
    obtain rfl : "wrapping_shl" = m := Option.some.inj hm
    obtain ⟨res, h1, h2⟩ := shl_arith (sg := sg) (u := u) hamt
    exact ⟨_, res, rfl, h1, h2⟩
  case shr =>
    obtain rfl : "wrapping_shr" = m := Option.some.inj hm
    obtain rfl := hsg rfl
    obtain ⟨res, h1, h2⟩ := shr_arith hpos (u := u) hamt
    exact ⟨_, res, rfl, h1, h2⟩
  case shrUnchecked =>
    obtain rfl : "wrapping_shr" = m := Option.some.inj hm
    obtain rfl := hsg rfl
    obtain ⟨res, h1, h2⟩ := shr_arith hpos (u := u) hamt
    exact ⟨_, res, rfl, h1, h2⟩
  all_goals exact absurd hop (by decide)

/-! ### Division and remainder -/

/-- An `if`-chain of two UB checks before an integer result, run to success. -/
theorem divrem_chain {msg1 msg2 : String} {c1 c2 : Bool} {x : Int} {o : Spec.Oracle}
    {s s1 : Spec.State} {v : Value}
    (h : runOn (if c1 then throwUb msg1 else if c2 then throwUb msg2
      else (pure (.int x) : SemM Value)) o s = (.ok v, s1)) :
    c1 = false ∧ c2 = false ∧ v = .int x ∧ s1 = s := by
  obtain ⟨h1, h2⟩ := runOn_ite_ub' h
  obtain ⟨h3, h4⟩ := runOn_ite_ub' h2
  rw [runOn_pure] at h4
  obtain ⟨h5, h6⟩ := prod_ok_inj h4
  exact ⟨h1, h3, h5.symm, h6.symm⟩

theorem ne_zero_of_beq {r : Int} (h : (r == 0) = false) : r ≠ 0 := by
  intro hr
  subst hr
  exact absurd h (by decide)

theorem rep_of_not {b : Bool} (h : (!b) = false) : b = true := by
  cases b
  · exact absurd h (by decide)
  · rfl

/-- A successful `div`: a non-zero divisor, a representable quotient (no `MIN / -1`). -/
theorem div_ok {t : IntType} {l r : Int} {dt : Spec.Ty} {o : Spec.Oracle}
    {s s1 : Spec.State} {v : Value}
    (h : runOn (evalIntBinOp .div t l r dt) o s = (.ok v, s1)) :
    s1 = s ∧ r ≠ 0 ∧ t.canRepresent (l.tdiv r) = true ∧ v = .int (l.tdiv r) := by
  have e : runOn (evalIntBinOp .div t l r dt) o s =
      runOn (if r == 0 then throwUb "division by zero"
        else if !t.canRepresent (l.tdiv r) then throwUb "overflow in division"
        else (pure (.int (l.tdiv r)) : SemM Value)) o s := by
    first
      | rfl
      | (simp only [evalIntBinOp]; done)
  rw [e] at h
  obtain ⟨h1, h2, h3, h4⟩ := divrem_chain h
  exact ⟨h4, ne_zero_of_beq h1, rep_of_not h2, h3⟩

/-- A successful `rem`: as `div_ok`, L0's checks are the quotient's. -/
theorem rem_ok {t : IntType} {l r : Int} {dt : Spec.Ty} {o : Spec.Oracle}
    {s s1 : Spec.State} {v : Value}
    (h : runOn (evalIntBinOp .rem t l r dt) o s = (.ok v, s1)) :
    s1 = s ∧ r ≠ 0 ∧ t.canRepresent (l.tdiv r) = true ∧ v = .int (l.tmod r) := by
  have e : runOn (evalIntBinOp .rem t l r dt) o s =
      runOn (if r == 0 then throwUb "modulus of remainder is zero"
        else if !t.canRepresent (l.tdiv r) then throwUb "overflow in remainder"
        else (pure (.int (l.tmod r)) : SemM Value)) o s := by
    first
      | rfl
      | (simp only [evalIntBinOp]; done)
  rw [e] at h
  obtain ⟨h1, h2, h3, h4⟩ := divrem_chain h
  exact ⟨h4, ne_zero_of_beq h1, rep_of_not h2, h3⟩

theorem intMin_toInt {w : Nat} (hw : 0 < w) :
    (OpSem.intMin w).toInt = -((2 ^ (w - 1) : Nat) : Int) := by
  have hP : 2 ^ w = 2 * 2 ^ (w - 1) := by
    rw [← Nat.pow_succ']; congr 1; omega
  have hlt : 2 ^ (w - 1) < 2 ^ w := by
    rw [hP]; have := Nat.two_pow_pos (w - 1); omega
  unfold OpSem.intMin
  rw [BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt, hP]
  generalize 2 ^ (w - 1) = H
  split <;> omega

/-- R's checks pass where L0's do: the divisor's bits are non-zero, and a signed `MIN / -1`
has an unrepresentable quotient. -/
theorem divrem_guards {t : IntType} (hpos : 0 < t.size) {u wv : Nat}
    (hr0 : t.ofBits wv ≠ 0) (hrep : t.canRepresent ((t.ofBits u).tdiv (t.ofBits wv)) = true) :
    (BitVec.ofNat (8 * t.size) wv == 0) = false ∧
      (t.signed && BitVec.ofNat (8 * t.size) u == OpSem.intMin (8 * t.size) &&
        BitVec.ofNat (8 * t.size) wv == BitVec.allOnes (8 * t.size)) = false := by
  have hW := modulus_eq_two_pow t
  have hw : 0 < 8 * t.size := Nat.mul_pos (by decide) hpos
  cases hsg : t.signed
  · refine ⟨?_, rfl⟩
    cases hc : (BitVec.ofNat (8 * t.size) wv == 0)
    · rfl
    · exfalso
      apply hr0
      have hB : BitVec.ofNat (8 * t.size) wv = 0 := beq_iff_eq.mp hc
      have h1 : wv % 2 ^ (8 * t.size) = 0 := by
        have := congrArg BitVec.toNat hB
        rw [BitVec.toNat_ofNat] at this
        exact this
      rw [ofBits_unsigned hsg wv, ← hW, h1] <;> rfl
  · refine ⟨?_, ?_⟩
    · cases hc : (BitVec.ofNat (8 * t.size) wv == 0)
      · rfl
      · exfalso
        apply hr0
        rw [ofBits_signed hsg hpos wv, beq_iff_eq.mp hc]
        exact BitVec.toInt_zero
    · have key : ¬ (BitVec.ofNat (8 * t.size) u = OpSem.intMin (8 * t.size) ∧
          BitVec.ofNat (8 * t.size) wv = BitVec.allOnes (8 * t.size)) := by
        rintro ⟨hA, hB⟩
        have hl : t.ofBits u = -((2 ^ (8 * t.size - 1) : Nat) : Int) := by
          rw [ofBits_signed hsg hpos u, hA, intMin_toInt hw]
        have hr : t.ofBits wv = -1 := by
          rw [ofBits_signed hsg hpos wv, hB, BitVec.toInt_allOnes, if_pos hw]
        rw [hl, hr, Int.neg_tdiv_neg, Int.tdiv_one] at hrep
        have hbw : t.bits = 8 * t.size := Nat.mul_comm _ _
        have hp : (2 : Int) ^ (t.bits - 1) = ((2 ^ (8 * t.size - 1) : Nat) : Int) := by
          rw [hbw] <;> rfl
        simp only [IntType.canRepresent, IntType.max, IntType.min, hsg, ↓reduceIte,
          Bool.and_eq_true, decide_eq_true_eq] at hrep
        rw [hp] at hrep
        omega
      cases hA : (BitVec.ofNat (8 * t.size) u == OpSem.intMin (8 * t.size))
      · rfl
      · cases hB : (BitVec.ofNat (8 * t.size) wv == BitVec.allOnes (8 * t.size))
        · rfl
        · exact absurd ⟨beq_iff_eq.mp hA, beq_iff_eq.mp hB⟩ key

theorem intBin_div_eq {sg : Bool} {w : Nat} {A B : BitVec w} (hb : (B == 0) = false)
    (hg : (sg && A == OpSem.intMin w && B == BitVec.allOnes w) = false) :
    intBin "unchecked_div" sg A B = .ok (if sg then A.sdiv B else A.udiv B) := by
  have e : intBin "unchecked_div" sg A B =
      (if B == 0 then OpSem.ub "division by zero"
        else if sg && A == OpSem.intMin w && B == BitVec.allOnes w then
          OpSem.ub "overflow in signed division (MIN / -1)"
        else if "unchecked_div" == "unchecked_div" then
          (pure (if sg then A.sdiv B else A.udiv B) : OpSem.M (BitVec w))
        else pure (if sg then A.srem B else A.umod B)) := rfl
  rw [e, hb, hg] <;> rfl

theorem intBin_rem_eq {sg : Bool} {w : Nat} {A B : BitVec w} (hb : (B == 0) = false)
    (hg : (sg && A == OpSem.intMin w && B == BitVec.allOnes w) = false) :
    intBin "unchecked_rem" sg A B = .ok (if sg then A.srem B else A.umod B) := by
  have e : intBin "unchecked_rem" sg A B =
      (if B == 0 then OpSem.ub "division by zero"
        else if sg && A == OpSem.intMin w && B == BitVec.allOnes w then
          OpSem.ub "overflow in signed division (MIN / -1)"
        else if "unchecked_rem" == "unchecked_div" then
          (pure (if sg then A.sdiv B else A.udiv B) : OpSem.M (BitVec w))
        else pure (if sg then A.srem B else A.umod B)) := rfl
  rw [e, hb, hg] <;> rfl

/-- R's quotient's bits are L0's: `udiv` on the unsigned values, `sdiv` (L0's `tdiv`, wrapped,
`BitVec.toInt_sdiv`) on the signed ones. -/
theorem div_val {t : IntType} (hpos : 0 < t.size) (u wv : Nat) :
    (if t.signed then (BitVec.ofNat (8 * t.size) u).sdiv (BitVec.ofNat (8 * t.size) wv)
      else (BitVec.ofNat (8 * t.size) u).udiv (BitVec.ofNat (8 * t.size) wv)).toNat =
      t.toBits ((t.ofBits u).tdiv (t.ofBits wv)) := by
  have hW := modulus_eq_two_pow t
  cases hsg : t.signed
  · rw [if_neg Bool.false_ne_true, ofBits_unsigned hsg u, ofBits_unsigned hsg wv]
    show (BitVec.ofNat (8 * t.size) u).toNat / (BitVec.ofNat (8 * t.size) wv).toNat =
      t.toBits (((u % t.modulus / (wv % t.modulus) : Nat) : Int))
    rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW,
      toBits_natCast_lt t (Nat.lt_of_le_of_lt (Nat.div_le_self (u % t.modulus) (wv % t.modulus))
        (Nat.mod_lt u (Ryo.Spec.Theorems.IntType.modulus_pos t)))]
  · rw [if_pos (rfl : true = true), ofBits_signed hsg hpos u, ofBits_signed hsg hpos wv,
      ← toBits_toInt t ((BitVec.ofNat (8 * t.size) u).sdiv (BitVec.ofNat (8 * t.size) wv)),
      BitVec.toInt_sdiv]
    exact Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t (by rw [← hW]; exact Int.bmod_emod)

/-- R's remainder's bits are L0's (`umod`, `srem` = L0's `tmod`, `BitVec.toInt_srem`). -/
theorem rem_val {t : IntType} (hpos : 0 < t.size) (u wv : Nat) :
    (if t.signed then (BitVec.ofNat (8 * t.size) u).srem (BitVec.ofNat (8 * t.size) wv)
      else (BitVec.ofNat (8 * t.size) u).umod (BitVec.ofNat (8 * t.size) wv)).toNat =
      t.toBits ((t.ofBits u).tmod (t.ofBits wv)) := by
  have hW := modulus_eq_two_pow t
  cases hsg : t.signed
  · rw [if_neg Bool.false_ne_true, ofBits_unsigned hsg u, ofBits_unsigned hsg wv]
    show (BitVec.ofNat (8 * t.size) u).toNat % (BitVec.ofNat (8 * t.size) wv).toNat =
      t.toBits (((u % t.modulus % (wv % t.modulus) : Nat) : Int))
    rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW,
      toBits_natCast_lt t (Nat.lt_of_le_of_lt (Nat.mod_le (u % t.modulus) (wv % t.modulus))
        (Nat.mod_lt u (Ryo.Spec.Theorems.IntType.modulus_pos t)))]
  · rw [if_pos (rfl : true = true), ofBits_signed hsg hpos u, ofBits_signed hsg hpos wv,
      ← toBits_toInt t ((BitVec.ofNat (8 * t.size) u).srem (BitVec.ofNat (8 * t.size) wv)),
      BitVec.toInt_srem]

theorem refines_divrem {op : BinOp} {m : String} (hm : binXMethod op = some m)
    (hop : op = .div ∨ op = .rem) {t : IntType} (hpos : 0 < t.size) (u wv : Nat) :
    BinRefines op m t.signed t (t.ofBits u) (t.ofBits wv) (BitVec.ofNat _ u)
      (BitVec.ofNat _ wv) := by
  intro dt o s s1 v h
  rcases hop with rfl | rfl
  · obtain rfl : "unchecked_div" = m := Option.some.inj hm
    obtain ⟨hs1, hr0, hrep, rfl⟩ := div_ok h
    obtain ⟨hb, hg⟩ := divrem_guards hpos hr0 hrep
    exact ⟨hs1, _, _, rfl, intBin_div_eq hb hg, div_val hpos u wv⟩
  · obtain rfl : "unchecked_rem" = m := Option.some.inj hm
    obtain ⟨hs1, hr0, hrep, rfl⟩ := rem_ok h
    obtain ⟨hb, hg⟩ := divrem_guards hpos hr0 hrep
    exact ⟨hs1, _, _, rfl, intBin_rem_eq hb hg, rem_val hpos u wv⟩

/-- `bin`'s arithmetic, by operator. -/
theorem binX_refines {op : BinOp} {m : String} (hm : binXMethod op = some m) {t : IntType}
    {sg : Bool} (hsg : binXSigned op = true → sg = t.signed) (hpos : 0 < t.size)
    (hmod : shiftOk t t = true) (u w : Nat) :
    BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u) (BitVec.ofNat _ w) := by
  obtain ⟨hd1, -⟩ := shiftOk_spec hmod
  have hamt : (BitVec.ofNat (8 * t.size) w).toNat % (8 * t.size) =
      (t.ofBits w % (t.bits : Int)).toNat := by
    have h := amt_of_imm (tc := t) (x := w) (bits := w) hd1 hd1 rfl
    rwa [ofBits_congr t (Nat.mod_mod w _)] at h
  cases op
  case addUnchecked => exact refines_unchecked (.inl ⟨rfl, rfl⟩) hm t sg u w
  case subUnchecked => exact refines_unchecked (.inr (.inl ⟨rfl, rfl⟩)) hm t sg u w
  case mulUnchecked => exact refines_unchecked (.inr (.inr ⟨rfl, rfl⟩)) hm t sg u w
  case shl => exact refines_shift hm rfl hpos hsg u hamt
  case shlUnchecked => exact refines_shift hm rfl hpos hsg u hamt
  case shr => exact refines_shift hm rfl hpos hsg u hamt
  case shrUnchecked => exact refines_shift hm rfl hpos hsg u hamt
  case div =>
    obtain rfl := hsg rfl
    exact refines_divrem hm (.inl rfl) hpos u w
  case rem =>
    obtain rfl := hsg rfl
    exact refines_divrem hm (.inr rfl) hpos u w
  all_goals first
    | exact absurd hm (by simp [binXMethod])
    | exact absurd hm (by decide)

/-- `binImm`'s arithmetic, by operator: the constant `bits : tc` against the immediate `x`. -/
theorem binImmX_refines {op : BinOp} {m : String} (hm : binImmXMethod op = some m)
    {t tc : IntType} {sg : Bool} (hsg : binXSigned op = true → sg = t.signed) (hpos : 0 < t.size)
    (hmod : immModOk op t tc = true) {x bits : Nat}
    (hx : x % immMod op t = bits % immMod op t) (u : Nat) :
    BinRefines op m sg t (t.ofBits u) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
      (BitVec.ofNat _ u) (BitVec.ofNat _ x) := by
  have hm' : binXMethod op = some m := by
    cases op
    all_goals first
      | exact hm
      | exact absurd hm (by simp [binImmXMethod])
      | exact absurd hm (by decide)
  -- the arithmetic operators: `tc = t`, the immediate congruent modulo `2 ^ (8 * t.size)`
  have harith : ∀ {op' : BinOp},
      ((op = .addUnchecked ∧ op' = .add) ∨ (op = .subUnchecked ∧ op' = .sub) ∨
        (op = .mulUnchecked ∧ op' = .mul)) → binMethod op' = some m →
      BinRefines op m sg t (t.ofBits u) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
        (BitVec.ofNat _ u) (BitVec.ofNat _ x) := by
    intro op' hu hb
    have hns : isShift op = false := by
      rcases hu with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> rfl
    have htc : tc = t := by
      have e : immModOk op t tc = (tc == t) := by
        first
          | (simp only [immModOk, hns]; done)
          | (unfold immModOk; rw [hns]; done)
          | (unfold immModOk; rw [hns]; rfl)
      rw [e] at hmod
      simpa using hmod
    have hx' : x % 2 ^ (8 * t.size) = bits % 2 ^ (8 * t.size) := by
      have e : immMod op t = 2 ^ (8 * t.size) := by
        first
          | (simp only [immMod, hns]; done)
          | (unfold immMod; rw [hns]; done)
          | (unfold immMod; rw [hns]; rfl)
      rw [e] at hx
      exact hx
    rw [htc, ofBits_congr t (show bits % 2 ^ (8 * t.size) % 2 ^ (8 * t.size) =
      x % 2 ^ (8 * t.size) by rw [Nat.mod_mod]; exact hx'.symm)]
    exact refines_unchecked hu hb t sg u x
  -- the shifts: the immediate congruent modulo the width
  have hshift : isShift op = true →
      BinRefines op m sg t (t.ofBits u) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
        (BitVec.ofNat _ u) (BitVec.ofNat _ x) := by
    intro hs
    have e1 : immModOk op t tc = shiftOk t tc := by
      first
        | (simp only [immModOk, hs]; done)
        | (unfold immModOk; rw [hs]; done)
        | (unfold immModOk; rw [hs]; rfl)
    have e2 : immMod op t = 8 * t.size := by
      first
        | (simp only [immMod, hs]; done)
        | (unfold immMod; rw [hs]; done)
        | (unfold immMod; rw [hs]; rfl)
    rw [e1] at hmod
    rw [e2] at hx
    obtain ⟨hd1, hd2⟩ := shiftOk_spec hmod
    exact refines_shift hm' hs hpos hsg u (amt_of_imm hd1 hd2 hx)
  cases op
  case addUnchecked => exact harith (.inl ⟨rfl, rfl⟩) hm
  case subUnchecked => exact harith (.inr (.inl ⟨rfl, rfl⟩)) hm
  case mulUnchecked => exact harith (.inr (.inr ⟨rfl, rfl⟩)) hm
  case shl => exact hshift rfl
  case shlUnchecked => exact hshift rfl
  case shr => exact hshift rfl
  case shrUnchecked => exact hshift rfl
  all_goals first
    | exact absurd hm (by simp [binImmXMethod, binXMethod])
    | exact absurd hm (by decide)

/-! ### The simulations -/

/-- The common write: L0 stores the integer `i` into private `_d`; R's handler writes `res`,
whose value is `i`'s bits. -/
theorem sim_int_write {ι : Inj} {fp : Nat} {st : OpSem.State} {s : Spec.State}
    {t : IntType} {valid : ValidRange} {sd : LocalSlot} (hsd : sd.size = t.size)
    {pd : ThinPointer} (hmem : MemInj ι s.mem st.mem)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {i : Int} {mem' : Memory} (hst : typedStore s.mem pd (.int i) (.int t valid) .one = .ok mem')
    {res : BitVec (8 * t.size)} (hrn : res.toNat = t.toBits i)
    {opc : Full.Opcode} {ops : OpSem.Operands} {ch : OpSem.Choice}
    (hop : ∀ st', st.writeFrame sd.off (intBytes t.size res.toNat) = .ok st' →
      opSem opc ops st ch = .ok (.next, st')) :
    ∃ st', opSem opc ops st ch = .ok (.next, st') ∧
      MemInj ι mem' st'.mem ∧ LocalRel ι fp st' mem' sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' mem' slot p lv) ∧
      ∃ bs, s.mem.store pd bs .one = .ok mem' ∧ ∀ b ∈ bs, b.provFrag = none := by
  have hsto := typedStore_int hst
  have hbeq : intBytes t.size res.toNat = encodeBits t.size (t.toBits i) := by
    rw [hrn]; rfl
  have hlen : (intBytes t.size res.toNat).length = t.size := by
    rw [hbeq]; exact Ryo.Spec.Theorems.encodeBits_length _ _
  have hpw : ∀ k < (intBytes t.size res.toNat).length, st.escapedAt (sd.off + k) = none := by
    intro k hk
    rw [hlen, ← hsd] at hk
    exact hprivd k hk
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off (intBytes t.size res.toNat) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hbs : BytesInj ι (encodeBits t.size (t.toBits i)) (intBytes t.size res.toNat) := by
    rw [hbeq]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size (t.toBits i)).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop st' hwr, hmi, hrd, ?_, _, hsto, encodeBits_noprov _ _⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

/-- `bin`'s simulation: `sim_binop` over `BinRefines`. -/
theorem sim_binX {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a b : Local} {op : BinOp} {m : String} {t : IntType} {valid : ValidRange}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    (htb : f.body.locals[b]? = some (.int t valid))
    {sd sa sb : LocalSlot} (hsd : sd.size = t.size) (hsa : sa.size = t.size)
    (hsb : sb.size = t.size)
    {pd pa pb : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa)) (hpb : f.locals[b]? = some (some pb))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true) (hrb : LocalRel ι fp st s.mem sb pb true)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    (hkd : binKd kd = true) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31 ∧
      -2 ^ 31 ≤ sb.off ∧ sb.off < 2 ^ 31)
    (har : ∀ u w, BinRefines op m sg t (t.ofBits u) (t.ofBits w) (BitVec.ofNat _ u)
      (BitVec.ofNat _ w))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))))
      o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .slot sb.off] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd', pa', pb', td, ta, tb, va, vb, v, hpd', hpa', hpb', htd', hta', htb', hla, hlb,
    s1, hev, mem', hst, rfl⟩ := assign_binop_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e3 : pb' = pb := Option.some.inj (Option.some.inj (hpb'.symm.trans hpb))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  have e6 : tb = .int t valid := Option.some.inj (htb'.symm.trans htb)
  subst e1 e2 e3 e4 e5 e6
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  obtain ⟨bsb, ub, hlob, hdb, -, rfl⟩ := typedLoad_int hlb
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits ub) (.int t valid)) o s = _ at hev
  obtain ⟨hs1, iv, res, rfl, hres, hrn⟩ := (har ua ub) _ o s s1 v hev
  subst s1
  rw [← hsa] at hloa
  rw [← hsb] at hlob
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hmem hrb hlob
  rw [hsa] at hrfa
  rw [hsb] at hrfb
  have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
  have hvb : asNat bb = .ok ub := by unfold asNat; rw [decodeBits_inj hib hdb]; rfl
  obtain ⟨st', hop, hmi, hrd, hoth, bs, hsto, hnp⟩ := sim_int_write hsd hmem ad xd hpdp hιd hxd
    hlived haddrd hpaddrd hsized hprivd hst hrn
    (fun st' hwr => opSem_binX_fwd (ch := ch) hkd hh hty ho hfits hrfa hrfb hva hvb hres hwr)
  exact ⟨st', hop, hmi, hrd, hoth, rfl, bs, hsto, hnp⟩

/-- `binImm`'s simulation: `sim_binImm` over `BinRefines`, the constant at its own type `tc`. -/
theorem sim_binImmX {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {op : BinOp} {m : String} {t tc : IntType} {valid vc : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    {sd sa : LocalSlot} (hsd : sd.size = t.size) (hsa : sa.size = t.size)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    {k : OperandKind} {x : Nat}
    (hkd : binImmKd kd = true) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    (hfk : Val.fits k (.imm x) = true)
    (har : ∀ u, BinRefines op m sg t (t.ofBits u) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
      (BitVec.ofNat _ u) (BitVec.ofNat _ x))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int tc vc))))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .imm x] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd', pa', td, ta, va, v, hpd', hpa', htd', hta', hla, s1, hev, mem', hst, rfl⟩ :=
    assign_binimm_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  change runOn (evalIntBinOp op t (t.ofBits ua) (tc.ofBits (bits % 2 ^ (8 * tc.size)))
    (.int t valid)) o s = _ at hev
  obtain ⟨hs1, iv, res, rfl, hres, hrn⟩ := (har ua) _ o s s1 v hev
  subst s1
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa] at hrfa
  have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
  obtain ⟨st', hop, hmi, hrd, hoth, bs, hsto, hnp⟩ := sim_int_write hsd hmem ad xd hpdp hιd hxd
    hlived haddrd hpaddrd hsized hprivd hst hrn
    (fun st' hwr => opSem_binImmX_fwd (ch := ch) hkd hh hty ho hfits hfk hrfa hva hres hwr)
  exact ⟨st', hop, hmi, hrd, hoth, rfl, bs, hsto, hnp⟩

/-! ### The lift -/

/-- `LowerBinX`'s rules lifted to R's `step` (as `lift_unop`). -/
theorem lift_binX {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerBinX Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @bin d a b oa ob op m t valid sd sa sb i hm ha hb hmod htd hta htb hsd hsa hsb hsize hoff
      hpriv hbi =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binXInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb0, _, _, _, _, _, _, hpd, hpa, hpb0, -⟩ := assign_binop_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpb0 hsb hlb
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binX (ch := ch) hs htd hta htb
      hsize.1 hsize.2.1 hsize.2.2 hpd hpa hpb0 hrel.frame.mem hra hrb ad xd hp hι hx hl haddr
      hpaddr hsz hpv hkd hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
      (fun u w => binX_refines hm hsg hpos hmod u w) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩
  | @binImm d a oa op m bits t tc valid vc sd sa i hm ha hmod htd hta hsd hsa hsize hoff hpriv
      hbi =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    rw [eval_binopImm_norm ha] at h
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmXInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty', hsg⟩ := intTyOkS_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsModOk_spec hops
    obtain ⟨k, ho⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot sa.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd hta
    obtain ⟨pd, pa, _, _, _, _, hpd, hpa, -⟩ := assign_binimm_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hpos : 0 < t.size := hwf d t valid htd
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_binImmX (ch := ch) hs htd hta
      hsize.1 hsize.2 hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hkd hh
      hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk
      (fun u => binImmX_refines hm hsg hpos hmod hx u) h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩

end Ryo.Proofs.Lower
