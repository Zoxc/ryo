/-
Ryo.Proofs.Lower.SimBool — `_d = const bits : bool` (M5a), lowered to `imm` at 1 byte with an
immediate whose low byte is `bits`'s, `_d` private. The constant decodes from
`encodeBits 1 bits` (one byte without provenance, 0 or 1), which is what both sides store.
-/
import Ryo.Proofs.Lower.SimPtr

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem
open Ryo.Check.Lower (LocalSlot)

theorem encodeBits_one (bits : Nat) :
    encodeBits 1 bits = [.init (UInt8.ofNat (bits % 256)) none] := rfl

theorem sim_constBool {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {bits : Nat}
    (htd : f.body.locals[d]? = some .bool)
    {sd : LocalSlot} (hsd : sd.size = 1)
    {pd : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hmem : MemInj ι s.mem st.mem)
    -- `_d` private
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    -- the instruction
    {opc : Full.Opcode} {r : Option String} {ty : String} {sg : Bool} {k : OperandKind}
    (hh : opc.handler? = some ⟨.imm, [ty], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int 1 sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31)
    {v : Nat} (hfk : Val.fits k (.imm v) = true)
    (hv : v % 2 ^ (8 * 1) = bits % 2 ^ (8 * 1))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.const (.scalar bits) .bool)))) o s =
      (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .imm v] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', td, rv, s1, hpd', htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
  subst e1 e4
  -- the constant
  have e3 : evalOperand (.const (.scalar bits) .bool) =
      (evalConst (.scalar bits) .bool >>= fun w => pure (w, Spec.Ty.bool)) := by
    first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
  rw [e3] at hev
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h2
  subst rv
  subst s1
  have e5 : evalConst (.scalar bits) Spec.Ty.bool = decodeConst (encodeBits 1 bits) .bool := rfl
  rw [e5] at h1
  obtain ⟨hdec, hs2⟩ := runOn_decodeConst_ok h1
  subst s2
  rw [encodeBits_one] at hdec
  obtain ⟨x, f', heq, hen⟩ := decode_bool_inv hdec
  have hx : x = UInt8.ofNat (bits % 256) ∧ f' = none := by
    injection heq with h1 _
    injection h1 with h3 h4
    exact ⟨h3.symm, h4.symm⟩
  obtain ⟨rfl, rfl⟩ := hx
  -- the store: `encodeBits 1 bits`
  obtain ⟨bsd, hen', hsto⟩ := typedStore_inv hst
  have hbsd : bsd = encodeBits 1 bits := by
    have := hen.symm.trans hen'
    rw [encodeBits_one]
    exact (Option.some.inj this).symm
  subst hbsd
  -- R's write: the same bytes
  have hib : intBytes 1 v = encodeBits 1 bits := by
    show encodeBits 1 v = _
    rw [← encodeBits_mod 1 v, hv, encodeBits_mod]
  have hlen : (intBytes 1 v).length = 1 := by rw [hib]; rfl
  have hpw : ∀ i < (intBytes 1 v).length, st.escapedAt (sd.off + i) = none := by
    intro i hi
    rw [hlen, ← hsd] at hi
    exact hprivd i hi
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off (intBytes 1 v) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_imm_fwd (ch := ch) hh hty ho hfits hfk hwr
  have hbs : BytesInj ι (encodeBits 1 bits) (intBytes 1 v) := by
    rw [hib]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits 1 bits).length = sd.size := by rw [hsd]; rfl
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

end Ryo.Proofs.Lower
