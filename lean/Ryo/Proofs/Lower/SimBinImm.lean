/-
Ryo.Proofs.Lower.SimBinImm — the simulation of one statement (M5a): `_d = op(copy _a, const)`
with an integer scalar constant, on integer locals of type `t`, lowered to the handler
instruction `op.imm.wN d, a, imm` (a `bin_imm` or `binop_imm` kind with method `binMethod op` at
`t`'s width and signedness), with `_d` private. The model is `sim_binop` (`SimBinOp.lean`).

- L0: a scalar constant at an integer type evaluates to the integer its low bits denote,
  without changing the state (`runOn_evalConst_scalar_int`); the assignment's inversion is
  `assign_binimm_inv`.
- R: the forward direction of `Inline.opSem_binImm` (`opSem_binImm_fwd`); the immediate is
  read as `BitVec.ofNat (8 * n) v`.
- The immediate `v` only has to agree with the constant's bits modulo `2 ^ (8 * t.size)`.
-/
import Ryo.Proofs.Lower.SimBinOp

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem
open Ryo.Check.Lower (LocalSlot binMethod)

/-! ### L0 -/

/-- `ofBits` only looks at the low `8 * size` bits. -/
theorem ofBits_congr (t : IntType) {x y : Nat}
    (h : x % 2 ^ (8 * t.size) = y % 2 ^ (8 * t.size)) : t.ofBits x = t.ofBits y := by
  rw [modulus_eq_two_pow] at h
  first
    | (unfold IntType.ofBits; rw [h]; done)
    | (unfold IntType.ofBits; rw [h])
    | simp only [IntType.ofBits, h]

/-- A scalar constant at an integer type: the integer its low bits denote, state unchanged. -/
theorem runOn_evalConst_scalar_int {o : Spec.Oracle} {s s1 : Spec.State} {bits : Nat}
    {t : IntType} {valid : ValidRange} {w : Value}
    (h : runOn (evalConst (.scalar bits) (.int t valid)) o s = (.ok w, s1)) :
    w = .int (t.ofBits (bits % 2 ^ (8 * t.size))) ∧ s1 = s := by
  have e0 : evalConst (.scalar bits) (.int t valid) =
      decodeConst (encodeBits t.size bits) (.int t valid) := rfl
  rw [e0] at h
  have e1 : decodeConst (encodeBits t.size bits) (.int t valid) =
      (match (Spec.Ty.int t valid).decode (encodeBits t.size bits) with
       | some v => (SemM.getMem >>= fun m =>
          SemM.liftE (checkValue m v (.int t valid)) >>= fun _ => pure v)
       | none => throwIllFormed "constant is not valid at its type" : SemM Value) := rfl
  rw [e1] at h
  cases hdec : (Spec.Ty.int t valid).decode (encodeBits t.size bits) with
  | none =>
    rw [hdec] at h
    exact (prod_err_ok h).elim
  | some w' =>
    rw [hdec] at h
    have h' : runOn (SemM.getMem >>= fun m =>
        SemM.liftE (checkValue m w' (.int t valid)) >>= fun _ => pure w') o s = (.ok w, s1) := h
    obtain ⟨m, s2, h1, h2⟩ := runOn_bind_ok h'
    have h1' : ((Except.ok s.mem, s) : Except Outcome Memory × Spec.State) = (.ok m, s2) := h1
    obtain ⟨hm, hs2⟩ := prod_ok_inj h1'
    subst hm
    subst hs2
    obtain ⟨u, s3, h3, h4⟩ := runOn_bind_ok h2
    obtain ⟨-, hs3⟩ := runOn_liftE_ok h3
    rw [hs3] at h4
    obtain ⟨hw, hs1⟩ := prod_ok_inj h4
    obtain ⟨-, u', hdb, hw'⟩ := decode_int_some hdec
    rw [Ryo.Spec.Theorems.decodeBits_encodeBits] at hdb
    have hu : u' = bits % 2 ^ (8 * t.size) := (Option.some.inj hdb).symm
    subst hu
    exact ⟨hw.symm.trans hw', hs1.symm⟩

theorem runOn_evalOperand_const_scalar_int {o : Spec.Oracle} {s s1 : Spec.State} {bits : Nat}
    {t : IntType} {valid : ValidRange} {r : Value × Spec.Ty}
    (h : runOn (evalOperand (.const (.scalar bits) (.int t valid))) o s = (.ok r, s1)) :
    r = (.int (t.ofBits (bits % 2 ^ (8 * t.size))), .int t valid) ∧ s1 = s := by
  have e : evalOperand (.const (.scalar bits) (.int t valid)) =
      (evalConst (.scalar bits) (.int t valid) >>= fun v => pure (v, .int t valid)) := rfl
  rw [e] at h
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨hw, hs2⟩ := runOn_evalConst_scalar_int h1
  obtain ⟨hr, hs1⟩ := prod_ok_inj h2
  subst hw
  exact ⟨hr.symm, hs1.symm.trans hs2⟩

/-- An assignment of an operator on a copied local and an integer scalar constant, run to
success: the frame's two locals are live, the operand loads, the constant is the integer its low
bits denote, and the store writes the result of `evalBinOp`. -/
theorem assign_binimm_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {op : BinOp} {bits : Nat}
    {t : IntType} {vc : ValidRange}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int t vc))))) o s = (.ok (), s')) :
    ∃ pd pa td ta va v,
      f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      f.body.locals[d]? = some td ∧ f.body.locals[a]? = some ta ∧
      typedLoad s.mem pa ta .one = .ok va ∧
      ∃ s1, runOn (evalBinOp op (va, ta)
        (.int (t.ofBits (bits % 2 ^ (8 * t.size))), .int t vc) td) o s = (.ok v, s1) ∧
      ∃ mem', typedStore s1.mem pd v td .one = .ok mem' ∧ s' = { s1 with mem := mem' } := by
  have e : evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int t vc)))) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.binaryOp op (.copy ⟨a, []⟩)
            (.const (.scalar bits) (.int t vc))) ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.binaryOp op (.copy ⟨a, []⟩)
      (.const (.scalar bits) (.int t vc))) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int t vc))) td =
      (evalOperand (.copy ⟨a, []⟩) >>= fun l =>
        evalOperand (.const (.scalar bits) (.int t vc)) >>= fun r => evalBinOp op l r td) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨la, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pa, ta, va, hla, hta, hva, hla', hs3⟩ := runOn_evalOperand_copy hs h5
  subst hla'
  rw [hs3] at h6
  obtain ⟨lb, s4, h7, h8⟩ := runOn_bind_ok h6
  obtain ⟨hlb, hs4⟩ := runOn_evalOperand_const_scalar_int h7
  subst hlb
  rw [hs4] at h8
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pd, pa, td, ta, va, v, hld, hla, htd, hta, hva, s2, h8, mem', hst, hs'⟩

/-! ### R -/

/-- The footprint of a `bin_imm`/`binop_imm` handler at `n` bytes. -/
def binImmFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "a" n], writes := [Ryo.Proofs.Inline.rdA "d" n] }

/-- The forward direction of `Inline.opSem_binImm` (for `bin_imm`/`binop_imm`). -/
theorem opSem_binImm_fwd {op : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String}
    {ty m : String} {n : Nat} {sg : Bool} {k : OperandKind} {d a : Int} {v : Nat}
    {st st' : OpSem.State} {ch : OpSem.Choice}
    (hkd : kd = .bin_imm ∨ kd = .binop_imm) (hh : op.handler? = some ⟨kd, [ty, m], r⟩)
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
    rcases hkd with rfl | rfl
    · exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.1
    · exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.2.2.1
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
    rcases hkd with rfl | rfl <;>
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

/-! ### The simulation -/

/-- The statement's simulation (see the module comment): as `sim_binop`, with the second
operand an integer scalar constant `bits` and the instruction's immediate `v` agreeing with it
modulo `2 ^ (8 * t.size)`. -/
theorem sim_binImm {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {op : BinOp} {m : String} (hm : binMethod op = some m)
    {t : IntType} {valid vc : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
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
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    {k : OperandKind} {v : Nat}
    (hkd : kd = .bin_imm ∨ kd = .binop_imm) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    (hfk : Val.fits k (.imm v) = true)
    (hv : v % 2 ^ (8 * t.size) = bits % 2 ^ (8 * t.size))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int t vc))))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .imm v] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', pa', td, ta, va, w, hpd', hpa', htd', hta', hla, s1, hev, mem', hst, rfl⟩ :=
    assign_binimm_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  -- the load
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  -- the operation
  have hev2 := evalIntBinOp_wrap hm t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size)))
    (.int t valid) o s
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size)))
    (.int t valid)) o s = _ at hev
  rw [hev2] at hev
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
  -- the immediate denotes the constant
  obtain ⟨res, hres, hrn⟩ := intBin_wrap hm t sg ua v
  have hcong : t.ofBits v = t.ofBits (bits % 2 ^ (8 * t.size)) :=
    ofBits_congr t (by rw [Nat.mod_mod]; exact hv)
  rw [hcong] at hrn
  -- R's write
  have hbeq : intBytes t.size res.toNat = encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size))))) := by
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
  have hop := opSem_binImm_fwd (ch := ch) hkd hh hty ho hfits hfk hrfa hva hres hwr
  have hbs : BytesInj ι (encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size))))))
      (intBytes t.size res.toNat) := by
    rw [hbeq]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua)
        (t.ofBits (bits % 2 ^ (8 * t.size)))))).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

end Ryo.Proofs.Lower
