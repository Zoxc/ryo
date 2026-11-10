/-
Ryo.Proofs.Lower.SimOvf — the simulation of `LowerOvf` (M5b, `Check/Lower/Ovf.lean`):
`_d = op(_a, _b)` for `AddWithOverflow`/`SubWithOverflow`/`MulWithOverflow` on integer locals of
type `t`, `_d` the pair `(t, bool)` at offsets `ov`, `oo` of its private slot, lowered to
`op.ovf d+ov, d+oo, a, b`.

- L0 (`ovf_ok`): the operator yields `(bringInBounds i, !canRepresent i)` for the exact result
  `i`, the state unchanged; the store writes `encodeFields` of the pair over uninitialized bytes
  (`encode_pair`): the value's bits at `ov`, the flag's byte at `oo`.
- R (`opSem_ovf_fwd`, `intOvf_eq`): `intOvf` reads the operands at the type's signedness, which
  gives back L0's integers (`val_ofNat`), computes the same exact `i`, and writes
  `BitVec.ofInt w i` (L0's wrapped value's bits, `toNat_ofInt_toBits`) and the flag
  `val (ofInt w i) ≠ i`, which is L0's `!canRepresent i` (`val_ofInt`, `ovf_flag`).
- The bytes: R's two writes are private (`writeFrame_priv_ok`); the frame after them
  (`ovf_frame`) holds, over the slot, exactly L0's stored bytes where L0 wrote and R's old bytes
  elsewhere, which L0 has uninitialized (`ovf_bytes`); `frameLocal_priv` and
  `LocalRel.frame_apart` (`SimAgg.lean`) give the relations, and L0's bytes carry no provenance
  (`ovf_noprov`).
- `lift_ovf`: the rule lifted to R's `step` (`LiftOut`), as `lift_unop`.
-/
import Ryo.Proofs.Lower.SimBinX
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.Ovf

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The instruction form -/

theorem intTyOkSg_spec {ty : String} {n : Nat} {sg : Bool} (h : intTyOkSg ty n sg = true) :
    OpSem.Ty.parse ty = some (.int n sg) := by
  unfold intTyOkSg at h
  split at h
  next n' sg' hp =>
    simp only [Bool.and_eq_true, beq_iff_eq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact hp
  · cases h

theorem ovfInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {m : String} {n : Nat} {sg : Bool}
    {d o a b : Int} (h : ovfInsnOk Γ i m n sg d o a b = true) :
    ∃ v ty r, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.ovf, [ty, m], r⟩ ∧
      OpSem.Ty.parse ty = some (.int n sg) ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] ∧
      v.ops = [.slot d, .slot o, .slot a, .slot b] ∧ v.ctl = some .next := by
  unfold ovfInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty m' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨hkd, hm⟩, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hkd hm
      exact ⟨v, ty, r, hv, hh, intTyOkSg_spec hty, ho, hops, hctl⟩
    · cases h
  · cases h

theorem ovfLayoutOk_spec {N ov oo n : Nat} (h : ovfLayoutOk N ov oo n = true) :
    ov + n ≤ N ∧ oo + 1 ≤ N := by
  simp only [ovfLayoutOk, Bool.and_eq_true, decide_eq_true_eq] at h
  exact ⟨h.1.1, h.1.2⟩

/-! ### R -/

/-- The footprint of an `ovf` handler at `n` bytes. -/
def ovfFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "a" n, Ryo.Proofs.Inline.rdA "b" n],
    writes := [Ryo.Proofs.Inline.rdA "d" n, Ryo.Proofs.Inline.rdA "o" 1] }

/-- The forward direction of an `ovf` handler's `opSem`: the two writes in order. -/
theorem opSem_ovf_fwd {op : Full.Opcode} {r : Option String} {ty m : String} {n : Nat}
    {sg : Bool} {d o a b : Int} {st st1 st2 : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.ovf, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ o ∧ o < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31 ∧
      -2 ^ 31 ≤ b ∧ b < 2 ^ 31)
    {ba bb : List AbstractByte} {va vb : Nat} {res : BitVec (8 * n)} {fl : Bool}
    (hra : st.readFrame a n = .ok ba) (hrb : st.readFrame b n = .ok bb)
    (hva : asNat ba = .ok va) (hvb : asNat bb = .ok vb)
    (hres : intOvf m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok (res, fl))
    (hw1 : st.writeFrame d (intBytes n res.toNat) = .ok st1)
    (hw2 : st1.writeFrame o (boolByte fl) = .ok st2) :
    opSem op [.slot d, .slot o, .slot a, .slot b] st ch = .ok (.next, st2) := by
  obtain ⟨hd1, hd2, ho1, ho2, ha1, ha2, hb1, hb2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfo := slot_fits ho1 ho2
  have hfa := slot_fits ha1 ha2
  have hfb := slot_fits hb1 hb2
  have hts := Ryo.Proofs.Inline.tySize_of_parse hty
  have hfp : footprint op = some (ovfFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    first
      | (simp only [footprintOf, List.head?, Option.bind_some, hts]; done)
      | (simp only [footprintOf, List.head?, Option.bind_some, hts]; rfl)
      | (simp [footprintOf, ovfFp, hts]; done)
      | (simp [footprintOf, ovfFp, hts]; rfl)
  have hprep : prepare op [.slot d, .slot o, .slot a, .slot b] =
      .ok (⟨.ovf, [ty, m], r⟩, ovfFp n, opndVal op.info [.slot d, .slot o, .slot a, .slot b]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfo, hfa, hfb])]
    rfl
  have hva' : opndVal op.info [.slot d, .slot o, .slot a, .slot b] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvb' : opndVal op.info [.slot d, .slot o, .slot a, .slot b] "b" = some (.slot b) := by
    simp [opndVal, ho]
  have hvd' : opndVal op.info [.slot d, .slot o, .slot a, .slot b] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hvo' : opndVal op.info [.slot d, .slot o, .slot a, .slot b] "o" = some (.slot o) := by
    simp [opndVal, ho]
  have hrd : readAll (ovfFp n) (opndVal op.info [.slot d, .slot o, .slot a, .slot b]) st =
      .ok [("a", ba), ("b", bb)] := by
    simp only [readAll, ovfFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', hvb', Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .ovf [ty, m] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot o, .slot a, .slot b]) st ch) =
      .ok { ctl := .next, mem := st.mem,
            writes := [("d", intBytes n res.toNat), ("o", boolByte fl)] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, out, hva, hvb,
      hres, bind, Except.bind, pure, Except.pure]
  have hc : commit (ovfFp n) (opndVal op.info [.slot d, .slot o, .slot a, .slot b]) st
      [("d", intBytes n res.toNat), ("o", boolByte fl)] = .ok st2 := by
    have hl1 : (intBytes n res.toNat).length = n := Ryo.Spec.Theorems.encodeBits_length _ _
    have hl2 : (boolByte fl).length = 1 := Ryo.Spec.Theorems.encodeBits_length _ _
    generalize intBytes n res.toNat = RV at hw1 hl1 ⊢
    generalize boolByte fl = RB at hw2 hl2 ⊢
    simp only [commit, ovfFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', hvo', Val.slotOff, Extent.eval,
      hl1, hl2, hw1, hw2, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)

/-! ### Arithmetic -/

/-- The exact result of an overflow-checked operator. -/
def ovfExact : BinOp → Int → Int → Int
  | .addWithOverflow, x, y => x + y
  | .subWithOverflow, x, y => x - y
  | _, x, y => x * y

theorem intOvf_eq {op : BinOp} {m : String} (hm : ovfMethod op = some m) {w : Nat} {sg : Bool}
    (A B : BitVec w) :
    intOvf m sg A B = .ok (BitVec.ofInt w (ovfExact op (OpSem.BitVec.val sg A)
        (OpSem.BitVec.val sg B)),
      OpSem.BitVec.val sg (BitVec.ofInt w (ovfExact op (OpSem.BitVec.val sg A)
        (OpSem.BitVec.val sg B))) != ovfExact op (OpSem.BitVec.val sg A)
        (OpSem.BitVec.val sg B)) := by
  cases op
  case addWithOverflow =>
    obtain rfl : "overflowing_add" = m := Option.some.inj hm
    rfl
  case subWithOverflow =>
    obtain rfl : "overflowing_sub" = m := Option.some.inj hm
    rfl
  case mulWithOverflow =>
    obtain rfl : "overflowing_mul" = m := Option.some.inj hm
    rfl
  all_goals first
    | exact absurd hm (by simp [ovfMethod])
    | exact absurd hm (by decide)

/-- A successful overflow-checked operator: the wrapped result and the overflow flag. -/
theorem ovf_ok {op : BinOp} {m : String} (hm : ovfMethod op = some m) {t : IntType}
    {l r : Int} {dt : Spec.Ty} {o : Spec.Oracle} {s s1 : Spec.State} {v : Value}
    (h : runOn (evalIntBinOp op t l r dt) o s = (.ok v, s1)) :
    s1 = s ∧ v = .tuple [.int (t.bringInBounds (ovfExact op l r)),
      .bool (!t.canRepresent (ovfExact op l r))] := by
  cases op
  case addWithOverflow =>
    have e : runOn (evalIntBinOp .addWithOverflow t l r dt) o s =
        (.ok (.tuple [.int (t.bringInBounds (l + r)), .bool (!t.canRepresent (l + r))]), s) := rfl
    rw [e] at h
    obtain ⟨h1, h2⟩ := prod_ok_inj h
    exact ⟨h2.symm, h1.symm⟩
  case subWithOverflow =>
    have e : runOn (evalIntBinOp .subWithOverflow t l r dt) o s =
        (.ok (.tuple [.int (t.bringInBounds (l - r)), .bool (!t.canRepresent (l - r))]), s) := rfl
    rw [e] at h
    obtain ⟨h1, h2⟩ := prod_ok_inj h
    exact ⟨h2.symm, h1.symm⟩
  case mulWithOverflow =>
    have e : runOn (evalIntBinOp .mulWithOverflow t l r dt) o s =
        (.ok (.tuple [.int (t.bringInBounds (l * r)), .bool (!t.canRepresent (l * r))]), s) := rfl
    rw [e] at h
    obtain ⟨h1, h2⟩ := prod_ok_inj h
    exact ⟨h2.symm, h1.symm⟩
  all_goals first
    | exact absurd hm (by simp [ovfMethod])
    | exact absurd hm (by decide)

/-- R reads an L0 integer's bits back at the type's signedness. -/
theorem val_ofNat {t : IntType} (hpos : 0 < t.size) (u : Nat) :
    OpSem.BitVec.val t.signed (BitVec.ofNat (8 * t.size) u) = t.ofBits u := by
  cases hs : t.signed
  · show ((BitVec.ofNat (8 * t.size) u).toNat : Int) = t.ofBits u
    rw [BitVec.toNat_ofNat, modulus_eq_two_pow, ofBits_unsigned hs]
  · show (BitVec.ofNat (8 * t.size) u).toInt = t.ofBits u
    rw [ofBits_signed hs hpos]

theorem toNat_ofInt_toBits (t : IntType) (i : Int) :
    (BitVec.ofInt (8 * t.size) i).toNat = t.toBits i := by
  rw [BitVec.toNat_ofInt]
  unfold IntType.toBits
  rw [modulus_eq_two_pow]

theorem val_ofInt {t : IntType} (hpos : 0 < t.size) (i : Int) :
    OpSem.BitVec.val t.signed (BitVec.ofInt (8 * t.size) i) = t.bringInBounds i := by
  have hr : BitVec.ofInt (8 * t.size) i = BitVec.ofNat (8 * t.size) (t.toBits i) := by
    apply BitVec.eq_of_toNat_eq
    rw [toNat_ofInt_toBits, BitVec.toNat_ofNat,
      Nat.mod_eq_of_lt (Ryo.Spec.Theorems.toBits_lt t i)]
  show _ = t.ofBits (t.toBits i)
  rw [hr, val_ofNat hpos]

/-- The wrapped value differs from the exact one exactly when that is not representable. -/
theorem ovf_flag {t : IntType} (hwf : t.wf = true) (i : Int) :
    (t.bringInBounds i != i) = !t.canRepresent i := by
  cases hc : t.canRepresent i
  · have hne : t.bringInBounds i ≠ i := by
      intro he
      have h1 := Ryo.Spec.Theorems.IntType.canRepresent_ofBits t hwf (t.toBits i)
      have h2 : t.canRepresent (t.bringInBounds i) = true := h1
      rw [he, hc] at h2
      cases h2
    simp [hne]
  · have he : t.bringInBounds i = i := Ryo.Spec.Theorems.int_roundtrip t hwf i hc
    simp [he]

/-! ### L0's bytes -/

/-- The pair's encoding: the value's bits at `ov`, the flag's byte at `oo`. -/
theorem encode_pair {t : IntType} {vt : ValidRange} {ov oo : Nat} {head : TupleHeadLayout}
    {w : Int} {fl : Bool} (hrep : t.canRepresent w = true) :
    (Spec.Ty.tuple [(ov, .int t vt), (oo, .bool)] head none).encode (.tuple [.int w, .bool fl]) =
      some (writeAt (writeAt (List.replicate head.headSizeAndAlign.1 .uninit) ov
        (encodeBits t.size (t.toBits w))) oo [.init (if fl then 1 else 0) none]) := by
  have h1 : (Spec.Ty.int t vt).encode (.int w) = some (encodeBits t.size (t.toBits w)) := by
    simp [Spec.Ty.encode, hrep]
  have h2 : Spec.Ty.bool.encode (.bool fl) = some [.init (if fl then 1 else 0) none] := rfl
  show Spec.Ty.encodeFields [(ov, .int t vt), (oo, .bool)] [.int w, .bool fl]
    (List.replicate head.headSizeAndAlign.1 .uninit) = _
  simp only [Spec.Ty.encodeFields, Option.bind_eq_bind, h1, h2, Option.bind_some]

theorem mem_writeAt {l src : List AbstractByte} {off : Nat} {b : AbstractByte}
    (h : b ∈ writeAt l off src) : b ∈ l ∨ b ∈ src := by
  unfold writeAt at h
  rcases List.mem_append.mp h with h | h
  · rcases List.mem_append.mp h with h | h
    · exact .inl (List.mem_of_mem_take h)
    · exact .inr h
  · exact .inl (List.mem_of_mem_drop h)

theorem ovf_noprov {N ov oo n v : Nat} {x : UInt8} :
    ∀ b ∈ writeAt (writeAt (List.replicate N .uninit) ov (encodeBits n v)) oo [.init x none],
      b.provFrag = none := by
  intro b hb
  rcases mem_writeAt hb with hb | hb
  · rcases mem_writeAt hb with hb | hb
    · rw [List.eq_of_mem_replicate hb] <;> rfl
    · exact encodeBits_noprov _ _ b hb
  · rw [List.mem_singleton.mp hb] <;> rfl

/-! ### R's frame -/

theorem privRange {st : OpSem.State} {base : Int} {N : Nat}
    (hprivd : ∀ k < N, st.escapedAt (base + k) = none) {off : Int} {n : Nat}
    (h1 : base ≤ off) (h2 : off + n ≤ base + N) :
    ∀ o, off ≤ o → o < off + n → st.escapedAt o = none := by
  intro o ho1 ho2
  have e : base + ((o - base).toNat : Int) = o := by omega
  have := hprivd (o - base).toNat (by omega)
  rwa [e] at this

/-- The frame after two private writes, the second over the first. -/
theorem ovf_frame {st : OpSem.State} {dV dO : Int} {n m : Nat} {EV EB : List AbstractByte}
    (hEV : EV.length = n) (hEB : EB.length = m)
    (hpV : ∀ o, dV ≤ o → o < dV + n → st.escapedAt o = none)
    (hpB : ∀ o, dO ≤ o → o < dO + m → st.escapedAt o = none) :
    (privState (privState st dV EV) dO EB).frame = fun o =>
      if dO ≤ o ∧ o < dO + m then EB.getD (o - dO).toNat .uninit
      else if dV ≤ o ∧ o < dV + n then EV.getD (o - dV).toNat .uninit else st.frame o := by
  show privFrame (privState st dV EV) dO EB = _
  rw [privFrame_eq (st := privState st dV EV) hEB (fun o h1 h2 => hpB o h1 h2)
    (fun _ _ _ => rfl)]
  funext o
  show (if dO ≤ o ∧ o < dO + m then EB.getD (o - dO).toNat .uninit
    else privFrame st dV EV o) = _
  rw [privFrame_eq hEV hpV (fun _ _ _ => rfl)] <;> rfl

theorem getD_inj {ι : Inj} {l : List AbstractByte} (hself : ∀ e ∈ l, ByteInj ι e e) {i : Nat}
    (hi : i < l.length) : ByteInj ι l[i] (l.getD i .uninit) := by
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hi]
  exact hself _ (List.getElem_mem hi)

/-- L0's stored bytes refine R's frame over the slot. -/
theorem ovf_bytes {ι : Inj} {N ov oo n : Nat} {EV EB : List AbstractByte} (hEV : EV.length = n)
    (hEB : EB.length = 1) (hov : ov + n ≤ N) (hoo : oo + 1 ≤ N)
    (hselfV : ∀ e ∈ EV, ByteInj ι e e) (hselfB : ∀ e ∈ EB, ByteInj ι e e)
    {F : Nat → AbstractByte} {G : Nat → AbstractByte}
    (hF : ∀ k, k < N → F k = if oo ≤ k ∧ k < oo + 1 then EB.getD (k - oo) .uninit
      else if ov ≤ k ∧ k < ov + n then EV.getD (k - ov) .uninit else G k) :
    ∀ k (h : k < (writeAt (writeAt (List.replicate N .uninit) ov EV) oo EB).length),
      ByteInj ι (writeAt (writeAt (List.replicate N .uninit) ov EV) oo EB)[k] (F k) := by
  intro k h
  have hN1 : (writeAt (List.replicate N .uninit) ov EV).length = N := by
    rw [Ryo.Spec.Theorems.writeAt_length _ _ _ (by rw [List.length_replicate, hEV]; omega),
      List.length_replicate]
  have hN2 : (writeAt (writeAt (List.replicate N .uninit) ov EV) oo EB).length = N := by
    rw [Ryo.Spec.Theorems.writeAt_length _ _ _ (by rw [hN1, hEB]; omega), hN1]
  have hk : k < N := by rw [hN2] at h; exact h
  rw [hF k hk]
  by_cases h1 : oo ≤ k ∧ k < oo + 1
  · rw [if_pos h1, writeAt_getElem_in (by rw [hN1, hEB]; omega) h (by rw [hEB]; omega)]
    exact getD_inj hselfB (by rw [hEB]; omega)
  · rw [if_neg h1, writeAt_getElem_out (by rw [hN1, hEB]; omega) h (by rw [hN1]; exact hk)
      (by rw [hEB]; exact h1)]
    by_cases h2 : ov ≤ k ∧ k < ov + n
    · rw [if_pos h2, writeAt_getElem_in (by rw [List.length_replicate, hEV]; omega)
        (by rw [hN1]; exact hk) (by rw [hEV]; omega)]
      exact getD_inj hselfV (by rw [hEV]; omega)
    · rw [if_neg h2, writeAt_getElem_out (by rw [List.length_replicate, hEV]; omega)
        (by rw [hN1]; exact hk) (by rw [List.length_replicate]; exact hk) (by rw [hEV]; exact h2),
        List.getElem_replicate]
      trivial

/-! ### The simulation -/

/-- `ovf`'s simulation (see the module comment). -/
theorem sim_ovf {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a b : Local} {op : BinOp} {m : String} (hm : ovfMethod op = some m)
    {t : IntType} {valid vt : ValidRange} {ov oo : Nat} {head : TupleHeadLayout}
    (hwf : t.wf = true) (hpos : 0 < t.size)
    (htd : f.body.locals[d]? = some (.tuple [(ov, .int t vt), (oo, .bool)] head none))
    (hta : f.body.locals[a]? = some (.int t valid))
    (htb : f.body.locals[b]? = some (.int t valid))
    {sd sa sb : LocalSlot} (hsd : sd.size = head.headSizeAndAlign.1) (hsa : sa.size = t.size)
    (hsb : sb.size = t.size) (hov : ov + t.size ≤ sd.size) (hoo : oo + 1 ≤ sd.size)
    {pd pa pb : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa)) (hpb : f.locals[b]? = some (some pb))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true) (hrb : LocalRel ι fp st s.mem sb pb true)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {r : Option String} {ty : String}
    (hh : opc.handler? = some ⟨.ovf, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size t.signed))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off + ov ∧ sd.off + ov < 2 ^ 31 ∧ -2 ^ 31 ≤ sd.off + oo ∧
      sd.off + oo < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sb.off ∧
      sb.off < 2 ^ 31)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))))
      o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot (sd.off + ov), .slot (sd.off + oo), .slot sa.off, .slot sb.off] st
        ch = .ok (.next, st') ∧
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
  have e4 : td = .tuple [(ov, .int t vt), (oo, .bool)] head none :=
    Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  have e6 : tb = .int t valid := Option.some.inj (htb'.symm.trans htb)
  subst e1 e2 e3 e4 e5 e6
  -- the loads
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  obtain ⟨bsb, ub, hlob, hdb, -, rfl⟩ := typedLoad_int hlb
  -- the operation
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits ub)
    (.tuple [(ov, .int t vt), (oo, .bool)] head none)) o s = _ at hev
  obtain ⟨hs1, rfl⟩ := ovf_ok hm hev
  subst s1
  generalize hi : ovfExact op (t.ofBits ua) (t.ofBits ub) = i at hst
  -- the store
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have hrep : t.canRepresent (t.bringInBounds i) = true :=
    Ryo.Spec.Theorems.IntType.canRepresent_ofBits t hwf (t.toBits i)
  rw [encode_pair hrep] at hen
  obtain rfl := Option.some.inj hen
  -- R's reads and result
  rw [← hsa] at hloa
  rw [← hsb] at hlob
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hmem hrb hlob
  rw [hsa] at hrfa
  rw [hsb] at hrfb
  have hva : asNat ba = .ok ua := by unfold asNat; rw [decodeBits_inj hia hda]; rfl
  have hvb : asNat bb = .ok ub := by unfold asNat; rw [decodeBits_inj hib hdb]; rfl
  have hres := intOvf_eq hm (sg := t.signed) (BitVec.ofNat (8 * t.size) ua)
    (BitVec.ofNat (8 * t.size) ub)
  rw [val_ofNat hpos, val_ofNat hpos, hi, val_ofInt hpos, ovf_flag hwf] at hres
  -- the bytes R writes are L0's
  have hRV : intBytes t.size (BitVec.ofInt (8 * t.size) i).toNat =
      encodeBits t.size (t.toBits (t.bringInBounds i)) := by
    show encodeBits t.size _ = _
    rw [toNat_ofInt_toBits, Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
      (Ryo.Spec.Theorems.IntType.bringInBounds_emod t i)]
  have hRB : boolByte (!t.canRepresent i) =
      [.init (if (!t.canRepresent i) then 1 else 0) none] := by
    generalize (!t.canRepresent i) = fl
    cases fl <;> first | rfl | decide
  -- R's writes
  have hEV : (encodeBits t.size (t.toBits (t.bringInBounds i))).length = t.size :=
    Ryo.Spec.Theorems.encodeBits_length _ _
  have hpV := privRange hprivd (off := sd.off + ov) (n := t.size) (by omega) (by omega)
  have hpB := privRange hprivd (off := sd.off + oo) (n := 1) (by omega) (by omega)
  have hw1 := writeFrame_priv_ok (st := st) (off := sd.off + ov)
    (bs := encodeBits t.size (t.toBits (t.bringInBounds i)))
    (fun j hj => hpV _ (by omega) (by rw [hEV] at hj; omega))
  have hw2 := writeFrame_priv_ok
    (st := privState st (sd.off + ov) (encodeBits t.size (t.toBits (t.bringInBounds i))))
    (off := sd.off + oo) (bs := [.init (if (!t.canRepresent i) then 1 else 0) none])
    (fun j hj => hpB _ (by omega) (by simp at hj; omega))
  have hfits' := hfits
  obtain ⟨hf1, hf2, hf3, hf4, hf5, hf6, hf7, hf8⟩ := hfits'
  have hop := opSem_ovf_fwd (ch := ch) hh hty ho hfits hrfa hrfb hva hvb hres
    (by rw [hRV]; exact hw1) (by rw [hRB]; exact hw2)
  -- the frame after both writes
  have hframe := ovf_frame (st := st) (n := t.size) (m := 1) hEV (rfl : ([AbstractByte.init
    (if (!t.canRepresent i) then 1 else 0) none]).length = 1) hpV hpB
  have hselfV : ∀ e ∈ encodeBits t.size (t.toBits (t.bringInBounds i)), ByteInj ι e e :=
    fun e he => encodeBits_inj_self he
  have hselfB : ∀ e ∈ ([AbstractByte.init (if (!t.canRepresent i) then 1 else 0) none]),
      ByteInj ι e e := by
    intro e he
    rw [List.mem_singleton.mp he]
    exact rfl
  have hbs := ovf_bytes (ι := ι) (N := sd.size) hEV rfl hov hoo hselfV hselfB
    (F := fun k => (privState (privState st (sd.off + ov)
      (encodeBits t.size (t.toBits (t.bringInBounds i)))) (sd.off + oo)
      [.init (if (!t.canRepresent i) then 1 else 0) none]).frame (sd.off + k))
    (G := fun k => st.frame (sd.off + k))
    (fun k hk => by
      try dsimp only
      rw [hframe]
      try dsimp only
      by_cases h1 : oo ≤ k ∧ k < oo + 1
      · have hA : sd.off + (oo : Int) ≤ sd.off + (k : Int) ∧
            sd.off + (k : Int) < sd.off + (oo : Int) + ((1 : Nat) : Int) := by omega
        have e : (sd.off + (k : Int) - (sd.off + (oo : Int))).toNat = k - oo := by omega
        rw [if_pos hA, if_pos h1, e]
      · have hA : ¬(sd.off + (oo : Int) ≤ sd.off + (k : Int) ∧
            sd.off + (k : Int) < sd.off + (oo : Int) + ((1 : Nat) : Int)) := by omega
        rw [if_neg hA, if_neg h1]
        by_cases h2 : ov ≤ k ∧ k < ov + t.size
        · have hB : sd.off + (ov : Int) ≤ sd.off + (k : Int) ∧
              sd.off + (k : Int) < sd.off + (ov : Int) + ((t.size : Nat) : Int) := by omega
          have e : (sd.off + (k : Int) - (sd.off + (ov : Int))).toNat = k - ov := by omega
          rw [if_pos hB, if_pos h2, e]
        · have hB : ¬(sd.off + (ov : Int) ≤ sd.off + (k : Int) ∧
              sd.off + (k : Int) < sd.off + (ov : Int) + ((t.size : Nat) : Int)) := by omega
          rw [if_neg hB, if_neg h2])
  rw [← hsd] at hsto
  have hN1 : (writeAt (List.replicate sd.size AbstractByte.uninit) ov
      (encodeBits t.size (t.toBits (t.bringInBounds i)))).length = sd.size := by
    rw [Ryo.Spec.Theorems.writeAt_length _ _ _ (by rw [List.length_replicate, hEV]; exact hov),
      List.length_replicate]
  have hN2 : (writeAt (writeAt (List.replicate sd.size AbstractByte.uninit) ov
      (encodeBits t.size (t.toBits (t.bringInBounds i)))) oo
      [.init (if (!t.canRepresent i) then 1 else 0) none]).length = sd.size := by
    rw [Ryo.Spec.Theorems.writeAt_length _ _ _ (by rw [hN1]; exact hoo), hN1]
  obtain ⟨hmi, hrd⟩ := frameLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hN2 hbs hsto rfl rfl
  refine ⟨_, hop, hmi, hrd, ?_, rfl, _, hsto, ovf_noprov⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  refine LocalRel.frame_apart h1 (lo := sd.off) (hi := sd.off + sd.size) rfl rfl ?_ hap
  intro q hq
  rw [hframe]
  try dsimp only
  have hov' : ov + (t.size : Nat) ≤ sd.size := hov
  have hA : ¬(sd.off + (oo : Int) ≤ q ∧ q < sd.off + (oo : Int) + ((1 : Nat) : Int)) := by
    intro ⟨h1, h2⟩
    rcases hq with hq | hq <;> omega
  have hB : ¬(sd.off + (ov : Int) ≤ q ∧ q < sd.off + (ov : Int) + ((t.size : Nat) : Int)) := by
    intro ⟨h1, h2⟩
    rcases hq with hq | hq <;> omega
  rw [if_neg hA, if_neg hB]

/-! ### The lift -/

/-- `LowerOvf`'s rule lifted to R's `step` (as `lift_unop`). -/
theorem lift_ovf {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerOvf Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @ovf d a b oa ob op m t valid vt ov oo head sd sa sb i hm ha hb htwf htd hta htb hsd hsa hsb
      hsize hlay hoff hpriv hoi =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := ovfInsnOk_spec hoi
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb0, _, _, _, _, _, _, hpd, hpa, hpb0, -⟩ := assign_binop_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpb0 hsb hlb
    have hpos : 0 < t.size := hwf a t valid hta
    obtain ⟨hov, hoo⟩ := ovfLayoutOk_spec hlay
    -- `t.size : Size` (an `abbrev` of `Nat`), which `omega` doesn't see through
    have hpos' : 0 < sd.size := Nat.lt_of_lt_of_le hpos (Nat.le_trans (Nat.le_add_left _ _) hov)
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2.1
    have hf4 := offOk_spec hoff.2.2.2
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs, hsto, hnp⟩ := sim_ovf (ch := ch) hs hm htwf hpos
      htd hta htb hsize.1 hsize.2.1 hsize.2.2 hov hoo hpd hpa hpb0 hrel.frame.mem hra hrb ad xd
      hp hι hx hl haddr hpaddr hsz hpv hh hty ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2, hf4.1, hf4.2⟩ h
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩

end Ryo.Proofs.Lower
