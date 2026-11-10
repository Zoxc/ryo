/-
Ryo.Proofs.Lower.SimOffset — the simulation of `LowerOffset` (M5b, `Check/Lower/Offset.lean`):
`_d = Offset(_a, _b)` on a thin pointer to a sized pointee (`sz` bytes) and an 8-byte index,
lowered to `ptr.index d, a, b, sz`, with `_d` private.

- L0 (`offset_ok`): the pointer and the index load, `bytes = n * sz` is representable, and
  `ptrOffsetInbounds` (`runOn_ptrOffsetInbounds_int`) keeps the address `p.addr + bytes` in
  `[0, 2 ^ 64)`; the result is the pointer at that address with `p`'s provenance, stored by
  `encodePtr`.
- R (`opSem_ptrIndex_fwd`): `ptr_index` reads the pointer (`decodePtr_inj`: the same address,
  related provenance) and the index's bits `u` (`u ≡ n` modulo `2 ^ 64`), and writes
  `encodePtr` of the pointer moved by `u * sz` modulo `2 ^ 64` (`wrap_addr`: the same address as
  L0's, which is in range). The encodings are related (`encodePtr_inj'`).
- `lift_offset`: the rule lifted to R's `step` (`LiftOut`), as `lift_copyPtr` (`FnSim.lean`): the
  stored bytes carry only the loaded pointer's provenance (`offset_prov_sub`), so `Hidden`, the
  provenance bound and `MemKept` carry over.
-/
import Ryo.Proofs.Lower.SimBinX
import Ryo.Proofs.Lower.SimField
import Ryo.Proofs.Lower.SimRefDeref
import Ryo.Check.Lower.Offset

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The instruction form -/

theorem ptrIndexInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {d a b : Int} {sz : Nat}
    (h : ptrIndexInsnOk Γ i d a b sz = true) :
    ∃ v ps r, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.ptr_index, ps, r⟩ ∧
      v.op.info.operands.map (·.name) = ["d", "p", "i", "stride"] ∧
      (v.op.info.operands.take 3).map (·.kind) = [.slot, .slot, .slot] ∧
      v.ops = [.slot d, .slot a, .slot b, .imm sz] ∧ v.ctl = some .next := by
  unfold ptrIndexInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ps r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨hkd, hn⟩, hk⟩, hops⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, ps, r, hv, hh, hn, hk, hops, hctl⟩
    · cases h
  · cases h

theorem operandsPtrIndex {l : List OperandInfo}
    (hn : l.map (·.name) = ["d", "p", "i", "stride"])
    (hk : (l.take 3).map (·.kind) = [.slot, .slot, .slot]) :
    ∃ k, l = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"i", .slot⟩, ⟨"stride", k⟩] := by
  rcases l with _ | ⟨⟨n1, k1⟩, _ | ⟨⟨n2, k2⟩, _ | ⟨⟨n3, k3⟩, _ | ⟨⟨n4, k4⟩, _ | ⟨w, l⟩⟩⟩⟩⟩ <;>
    simp at hn
  simp at hk
  obtain ⟨rfl, rfl, rfl, rfl⟩ := hn
  obtain ⟨rfl, rfl, rfl⟩ := hk
  exact ⟨_, rfl⟩

/-- The stride fits its operand kind (`PlainView.fits`). -/
theorem fits_stride {ops : Operands} {infos : List OperandInfo} {k : OperandKind} {x : Nat}
    (hall : (infos.zip ops).all (fun p => p.2.fits p.1.kind) = true)
    (hmem : (⟨"stride", k⟩, Val.imm x) ∈ infos.zip ops) : Val.fits k (.imm x) = true := by
  have := List.all_eq_true.mp hall _ hmem
  simpa using this

/-! ### R -/

/-- The footprint of `ptr_index`. -/
def ptrIndexFp : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "p" 8, Ryo.Proofs.Inline.rdA "i" 8],
    writes := [Ryo.Proofs.Inline.rdA "d" 8] }

/-- The forward direction of `ptr_index`'s `opSem`. -/
theorem opSem_ptrIndex_fwd {op : Full.Opcode} {r : Option String} {ps : List String}
    {k : OperandKind} {d a b : Int} {stride : Nat} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.ptr_index, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"i", .slot⟩, ⟨"stride", k⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31 ∧ -2 ^ 31 ≤ b ∧ b < 2 ^ 31)
    (hfk : Val.fits k (.imm stride) = true)
    {ba bb : List AbstractByte} {p1 : ThinPointer} {vb : Nat}
    (hra : st.readFrame a 8 = .ok ba) (hrb : st.readFrame b 8 = .ok bb)
    (hpa : decodePtr ba = some p1) (hvb : asNat bb = .ok vb)
    (hw : st.writeFrame d (encodePtr (p1.wrappingOffset ((vb * stride % 2 ^ 64 : Nat) : Int))) =
      .ok st') :
    opSem op [.slot d, .slot a, .slot b, .imm stride] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2, hb1, hb2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfb := slot_fits hb1 hb2
  have hfp : footprint op = some ptrIndexFp := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact Ryo.Proofs.Inline.fp_ptr_index ps
  have hprep : prepare op [.slot d, .slot a, .slot b, .imm stride] =
      .ok (⟨.ptr_index, ps, r⟩, ptrIndexFp,
        opndVal op.info [.slot d, .slot a, .slot b, .imm stride]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa, hfb, hfk])]
    rfl
  have hvp : opndVal op.info [.slot d, .slot a, .slot b, .imm stride] "p" = some (.slot a) := by
    simp [opndVal, ho]
  have hvi : opndVal op.info [.slot d, .slot a, .slot b, .imm stride] "i" = some (.slot b) := by
    simp [opndVal, ho]
  have hvs : opndVal op.info [.slot d, .slot a, .slot b, .imm stride] "stride" =
      some (.imm stride) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .slot a, .slot b, .imm stride] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll ptrIndexFp (opndVal op.info [.slot d, .slot a, .slot b, .imm stride]) st =
      .ok [("p", ba), ("i", bb)] := by
    simp only [readAll, ptrIndexFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvp, hvi, Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .ptr_index ps (mkEnv [("p", ba), ("i", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b, .imm stride]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes :=
              [("d", encodePtr (p1.wrappingOffset ((vb * stride % 2 ^ 64 : Nat) : Int)))] } := by
    simp [kindSem, mkEnv, Env.ptr, Env.int, Env.imm, hvs, out, asPtr, hpa, hvb, bind,
      Except.bind, pure, Except.pure]
  have hc : commit ptrIndexFp (opndVal op.info [.slot d, .slot a, .slot b, .imm stride]) st
      [("d", encodePtr (p1.wrappingOffset ((vb * stride % 2 ^ 64 : Nat) : Int)))] = .ok st' := by
    -- keep the written bytes opaque (`simp` would rewrite the cast inside the offset)
    have hlenE := Ryo.Spec.Theorems.encodePtr_length
      (p1.wrappingOffset ((vb * stride % 2 ^ 64 : Nat) : Int))
    generalize encodePtr (p1.wrappingOffset ((vb * stride % 2 ^ 64 : Nat) : Int)) = E
      at hw hlenE ⊢
    simp only [commit, ptrIndexFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval,
      hlenE, hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)

/-! ### L0 -/

/-- `ptrOffsetInbounds` by any offset, run to success: the address moves and stays in
`[0, 2 ^ 64)`, the state stays (`runOn_ptrOffsetInbounds_ok` for an integer offset). -/
theorem runOn_ptrOffsetInbounds_int {o : Spec.Oracle} {s s1 : Spec.State} {q q' : ThinPointer}
    {off : Int} (h : runOn (ptrOffsetInbounds q off) o s = (.ok q', s1)) :
    q' = ⟨((q.addr : Int) + off).toNat, q.prov⟩ ∧ s1 = s ∧ 0 ≤ (q.addr : Int) + off ∧
      (q.addr : Int) + off < (Target.ADDR_LIMIT : Int) := by
  unfold ptrOffsetInbounds at h
  obtain ⟨m, s2, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_getMem0] at h1
  obtain ⟨_, hs2⟩ := prod_ok_inj h1
  obtain ⟨_, s3, h3, h4⟩ := runOn_bind_ok h2
  obtain ⟨-, hs3⟩ := runOn_liftE_ok h3
  dsimp only at h4
  split at h4
  · obtain ⟨_, _, h5, -⟩ := runOn_bind_ok h4
    rw [runOn_throwUb] at h5
    exact (prod_err_ok h5).elim
  next hc =>
    rw [runOn_pure] at h4
    obtain ⟨hq, hs1⟩ := prod_ok_inj h4
    simp only [Bool.or_eq_true, decide_eq_true_eq, not_or] at hc
    obtain ⟨hc1, hc2⟩ := hc
    exact ⟨hq.symm, by rw [← hs1, hs3, ← hs2], by omega, by omega⟩

/-- A successful `Offset` of a pointer to a sized pointee by `n`: the address `p.addr + n * sz`
is in range, the result keeps `p`'s provenance, the state is unchanged. -/
theorem offset_ok {p : Pointer} {pt : PtrType} {valid : ValidRange} {n : Int} {tb : Spec.Ty}
    {dt : Spec.Ty} {sz : Nat} {al : Align} {inh : Bool}
    (hpe : pt.pointee? = some ⟨.sized sz al, inh⟩) {o : Spec.Oracle} {s s1 : Spec.State}
    {v : Value} (h : runOn (evalBinOp .offset (.ptr p, .ptr pt valid) (.int n, tb) dt) o s =
      (.ok v, s1)) :
    s1 = s ∧ 0 ≤ (p.thin.addr : Int) + n * sz ∧
      (p.thin.addr : Int) + n * sz < (Target.ADDR_LIMIT : Int) ∧
      v = .ptr (⟨((p.thin.addr : Int) + n * sz).toNat, p.thin.prov⟩ : ThinPointer).widen := by
  have e : runOn (evalBinOp .offset (.ptr p, .ptr pt valid) (.int n, tb) dt) o s =
      runOn (do
        let sz ← pointeeSize pt
        let bytes : Int := n * sz
        if !IntType.isize.canRepresent bytes then throwUb "Offset: byte offset overflows isize"
        let q ← ptrOffsetInbounds p.thin bytes
        pure (Value.ptr q.widen) : SemM Value) o s := by
    first
      | rfl
      | (simp only [evalBinOp]; done)
      | (unfold evalBinOp; rfl)
  have hps : pointeeSize pt = pure sz := by
    first
      | (simp only [pointeeSize, hpe]; done)
      | (unfold pointeeSize; rw [hpe]; done)
      | (unfold pointeeSize; rw [hpe]; rfl)
  rw [e, hps] at h
  obtain ⟨sz', s2, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_pure] at h1
  obtain ⟨hsz, hs2⟩ := prod_ok_inj h1
  rw [← hsz, ← hs2] at h2
  try dsimp only at h2
  split at h2
  · first
      | (obtain ⟨_, _, h5, -⟩ := runOn_bind_ok h2
         rw [runOn_throwUb] at h5
         exact (prod_err_ok h5).elim)
      | (rw [runOn_throwUb] at h2
         exact (prod_err_ok h2).elim)
  · obtain ⟨q, s3, h6, h7⟩ := runOn_bind_ok h2
    obtain ⟨rfl, hs3, h0, hlt⟩ := runOn_ptrOffsetInbounds_int h6
    rw [runOn_pure] at h7
    obtain ⟨hv, hs1⟩ := prod_ok_inj h7
    exact ⟨by rw [← hs1, hs3], h0, hlt, hv.symm⟩

/-- R's wrapped address is L0's in-range one: `u ≡ n` modulo `2 ^ 64`. -/
theorem wrap_addr {A u sz : Nat} {n : Int}
    (hu : (u : Int) % (Target.ADDR_LIMIT : Int) = n % (Target.ADDR_LIMIT : Int))
    (h0 : 0 ≤ (A : Int) + n * sz) (h1 : (A : Int) + n * sz < (Target.ADDR_LIMIT : Int)) :
    (((A : Int) + ((u * sz % 2 ^ 64 : Nat) : Int)) % (Target.ADDR_LIMIT : Int)).toNat =
      ((A : Int) + n * sz).toNat := by
  have hL : ((2 ^ 64 : Nat) : Int) = (Target.ADDR_LIMIT : Int) := rfl
  have e : ((A : Int) + ((u * sz % 2 ^ 64 : Nat) : Int)) % (Target.ADDR_LIMIT : Int) =
      (A : Int) + n * sz := by
    rw [Int.natCast_emod, hL, Int.add_emod, Int.emod_emod, ← Int.add_emod, Int.natCast_mul,
      Int.add_emod, mul_emod_congr hu, ← Int.add_emod]
    exact Int.emod_eq_of_lt h0 h1
  rw [e]

/-- The stored pointer's provenance is the loaded one's. -/
theorem offset_prov_sub {bs0 : List AbstractByte} {tp : ThinPointer}
    (hdp : decodePtr bs0 = some tp) (a : Nat) :
    ∀ b ∈ encodePtr ⟨a, tp.prov⟩, ∀ fr, b.provFrag = some fr →
      ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
  intro b hb fr hfr
  have hp := encodePtr_prov' hb hfr
  rw [Ryo.Spec.Theorems.decodePtr_eq] at hdp
  cases hdb : decodeBits bs0 with
  | none => simp [hdb] at hdp
  | some x =>
    simp [hdb] at hdp
    subst hdp
    obtain ⟨hne, hall⟩ := (Ryo.Spec.Theorems.ptrProvOf_iff bs0 fr.prov).mp hp
    have h0 : 0 < bs0.length := by
      cases bs0 with
      | nil => exact absurd rfl hne
      | cons _ _ => simp
    exact ⟨0, h0, _, hall 0 h0, rfl⟩

/-! ### The simulation -/

/-- `offset`'s simulation (see the module comment). -/
theorem sim_offset {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a b : Local} {pt : PtrType} {valid : ValidRange} {tb : IntType} {vb : ValidRange}
    {sz : Nat} {al : Align} {inh : Bool}
    (hk : pt.metaKind = .none) (hpe : pt.pointee? = some ⟨.sized sz al, inh⟩)
    (htd : f.body.locals[d]? = some (.ptr pt valid))
    (hta : f.body.locals[a]? = some (.ptr pt valid))
    (htb : f.body.locals[b]? = some (.int tb vb)) (htb8 : tb.size = 8)
    {sd sa sb : LocalSlot} (hsd : sd.size = 8) (hsa : sa.size = 8) (hsb : sb.size = 8)
    {pd pa pb : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa)) (hpb : f.locals[b]? = some (some pb))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true) (hrb : LocalRel ι fp st s.mem sb pb true)
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {opc : Full.Opcode} {r : Option String} {ps : List String} {k : OperandKind}
    (hh : opc.handler? = some ⟨.ptr_index, ps, r⟩)
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"i", .slot⟩, ⟨"stride", k⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31 ∧
      -2 ^ 31 ≤ sb.off ∧ sb.off < 2 ^ 31)
    (hfk : Val.fits k (.imm sz) = true)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp .offset (.copy ⟨a, []⟩) (.copy ⟨b, []⟩)))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .slot sb.off, .imm sz] st ch =
        .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      (∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv) ∧
      s'.stack = s.stack ∧
      ∃ bs0 bsd, s.mem.load pa 8 .one = .ok bs0 ∧ s.mem.store pd bsd .one = .ok s'.mem ∧
        (∀ b ∈ bsd, ∀ fr, b.provFrag = some fr →
          ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov) := by
  obtain ⟨pd', pa', pb', td, ta, tb', va, vb', v, hpd', hpa', hpb', htd', hta', htb', hla, hlb,
    s1, hev, mem', hst, rfl⟩ := assign_binop_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e3 : pb' = pb := Option.some.inj (Option.some.inj (hpb'.symm.trans hpb))
  have e4 : td = .ptr pt valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .ptr pt valid := Option.some.inj (hta'.symm.trans hta)
  have e6 : tb' = .int tb vb := Option.some.inj (htb'.symm.trans htb)
  subst e1 e2 e3 e4 e5 e6
  -- the loads
  obtain ⟨bs0, hlo0, hd0⟩ := typedLoad_inv (size?_ptr_thin hk) hla
  obtain ⟨tp, -, hdp, rfl⟩ := decode_ptr_thin_inv hk hd0
  obtain ⟨bsb, ub, hlob, hdb, -, rfl⟩ := typedLoad_int hlb
  -- the operation
  obtain ⟨hs1, h0, hlt, hv⟩ := offset_ok hpe hev
  subst s1
  have h0' : 0 ≤ (tp.addr : Int) + tb.ofBits ub * sz := h0
  have hlt' : (tp.addr : Int) + tb.ofBits ub * sz < (Target.ADDR_LIMIT : Int) := hlt
  have hv' : v = .ptr (⟨((tp.addr : Int) + tb.ofBits ub * sz).toNat, tp.prov⟩ :
      ThinPointer).widen := hv
  subst hv'
  -- the store
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have hbsd : bsd = encodePtr ⟨((tp.addr : Int) + tb.ofBits ub * sz).toNat, tp.prov⟩ := by
    simp [Spec.Ty.encode, hk, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbsd
  -- R's reads
  have hlo0' := hlo0
  rw [← hsa] at hlo0'
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hlo0'
  rw [hsa] at hrfa
  obtain ⟨p1, hdp1, hpi⟩ := decodePtr_inj hia hdp
  rw [htb8, ← hsb] at hlob
  obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hmem hrb hlob
  rw [hsb] at hrfb
  have hvb : asNat bb = .ok ub := by unfold asNat; rw [decodeBits_inj hib hdb]; rfl
  -- the address
  have hmod : tb.modulus = Target.ADDR_LIMIT := by
    unfold IntType.modulus IntType.bits
    rw [htb8] <;> rfl
  have hu : (ub : Int) % (Target.ADDR_LIMIT : Int) =
      tb.ofBits ub % (Target.ADDR_LIMIT : Int) := by
    rw [← hmod]
    exact (Ryo.Spec.Theorems.IntType.ofBits_emod tb ub).symm
  have hq1 : p1.wrappingOffset ((ub * sz % 2 ^ 64 : Nat) : Int) =
      ⟨((tp.addr : Int) + tb.ofBits ub * sz).toNat, p1.prov⟩ := by
    unfold ThinPointer.wrappingOffset
    rw [← hpi.1, wrap_addr hu h0' hlt']
  have hbs : BytesInj ι (encodePtr ⟨((tp.addr : Int) + tb.ofBits ub * sz).toNat, tp.prov⟩)
      (encodePtr (p1.wrappingOffset ((ub * sz % 2 ^ 64 : Nat) : Int))) := by
    rw [hq1]
    exact encodePtr_inj' (And.intro rfl hpi.2)
  -- R's write
  have hlen : (encodePtr (p1.wrappingOffset ((ub * sz % 2 ^ 64 : Nat) : Int))).length =
      sd.size := by
    rw [Ryo.Spec.Theorems.encodePtr_length, hsd]
  have hpw : ∀ i < (encodePtr (p1.wrappingOffset ((ub * sz % 2 ^ 64 : Nat) : Int))).length,
      st.escapedAt (sd.off + i) = none := by
    intro i hi
    rw [hlen] at hi
    exact hprivd i hi
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off
      (encodePtr (p1.wrappingOffset ((ub * sz % 2 ^ 64 : Nat) : Int))) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_ptrIndex_fwd (ch := ch) hh ho hfits hfk hrfa hrfb hdp1 hvb hwr
  have hlen0 : (encodePtr ⟨((tp.addr : Int) + tb.ofBits ub * sz).toNat, tp.prov⟩).length =
      sd.size := by
    rw [Ryo.Spec.Theorems.encodePtr_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_, rfl, bs0, _, hlo0, hsto, offset_prov_sub hdp _⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen]; exact hap)

/-! ### The lift -/

/-- `LowerOffset`'s rule lifted to R's `step` (as `lift_copyPtr`). -/
theorem lift_offset {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerOffset Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @offset d a b oa ob pt valid tb vb sz al inh sd sa sb i ha hb hk hpe0 htd hta htb htb8 hsd
      hsa hsb hsize hoff hpriv hpi =>
    have hla := hlo a (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo b (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, ps, r, hv, hh, hn, hk3, hops, hctl⟩ := ptrIndexInsnOk_spec hpi
    rw [hmode, hρ] at hv
    obtain ⟨k, ho⟩ := operandsPtrIndex hn hk3
    have hfk : Val.fits k (.imm sz) = true :=
      fits_stride (hpl.fits v hv) (by rw [ho, hops]; simp)
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb0, _, _, _, _, _, _, hpd, hpa, hpb0, -⟩ := assign_binop_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpb0 hsb hlb
    have hpos : 0 < sd.size := by rw [hsize.1]; decide
    obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨st', hop, hmi, hrd, hoth, hstk, bs0, bsd, hlo0, hsto, hsub⟩ := sim_offset (ch := ch)
      hs hk hpe0 htd hta htb htb8 hsize.1 hsize.2.1 hsize.2.2 hpd hpa hpb0 hrel.frame.mem hra
      hrb ad xd hp hι hx hl haddr hpaddr hsz hpv hh ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ hfk h
    -- `Hidden` and the bound: the stored provenance is the loaded bytes'
    have hhid := hrel.hidden.load hlo0
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hhid _ (List.getElem_mem hj) fr0 hf0
    have hbd := hpb.load hlo0
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hbd _ (List.getElem_mem hj) fr0 hf0
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlo0 hsub⟩

end Ryo.Proofs.Lower
