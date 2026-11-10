/-
Ryo.Proofs.Lower.SimStmtEsc — the simulation of `LowerStmtEsc` (`Check/Lower/StmtEsc.lean`,
M5b): `Stmt.lean`'s `binop`, `binopImm`, `constInt` and `constBool` with a destination that may
be escaped.

`sim_binopE`, `sim_binImmE`, `sim_constIntE`, `sim_constBoolE` are `sim_binop` (`SimBinOp`),
`sim_binImm` (`SimBinImm`), `sim_constInt` (`SimMove`) and `sim_constBool` (`SimBool`) with the
private-destination facts replaced by `DstWriteAll` (`WriteDst.lean`), as `sim_unop` does: L0's
store and its bytes are computed as there, then `DstWriteAll` gives R's `writeFrame` of the
related bytes, `MemInj`, `_d`'s relation and the other locals' at once, and the `*_fwd` lemma the
instruction's `opSem`. `lift_stmtEsc` is `lift_binop`/`lift_binopImm`/`lift_constInt`/
`lift_constBool` (`FnRel.lean`, `FnSim.lean`) with `FnRel.dstWriteAll` (from L0's
`LiveDisjoint`) for `FnRel.priv_dst`, ending in a `LiftOut` (`memInv_store`: the stored bytes
carry no provenance). `stmt_sim_stmtEsc` is the scope-free case (as `stmt_sim_cmpX`).
-/
import Ryo.Proofs.Lower.WriteDst
import Ryo.Check.Lower.StmtEsc

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The statements -/

/-- `sim_binop` with `_d` private or escaped (`DstWriteAll`). -/
theorem sim_binopE {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a b : Local} {op : BinOp} {m : String} (hm : binMethod op = some m)
    {t : IntType} {valid : ValidRange}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    (htb : f.body.locals[b]? = some (.int t valid))
    {sd sa sb : LocalSlot} (hsd : sd.size = t.size) (hsa : sa.size = t.size)
    (hsb : sb.size = t.size)
    {pd pa pb : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa)) (hpb : f.locals[b]? = some (some pb))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true) (hrb : LocalRel ι fp st s.mem sb pb true)
    (hW : DstWriteAll ι fp st s.mem sd pd)
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String} {sg : Bool}
    (hkd : kd = .bin ∨ kd = .binop) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31 ∧
      -2 ^ 31 ≤ sb.off ∧ sb.off < 2 ^ 31)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))))
      o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off, .slot sb.off] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
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
  have hev2 := evalIntBinOp_wrap hm t (t.ofBits ua) (t.ofBits ub) (.int t valid) o s
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits ub) (.int t valid)) o s = _ at hev
  rw [hev2] at hev
  simp only [Prod.mk.injEq, Except.ok.injEq] at hev
  obtain ⟨hv, hs1⟩ := hev
  subst hv
  subst s1
  have hsto := typedStore_int hst
  rw [← hsa] at hloa
  rw [← hsb] at hlob
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  obtain ⟨bb, hrfb, hib⟩ := readLocal_inj hmem hrb hlob
  rw [hsa] at hrfa
  rw [hsb] at hrfb
  have hda' := decodeBits_inj hia hda
  have hdb' := decodeBits_inj hib hdb
  have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
  have hvb : asNat bb = .ok ub := by unfold asNat; rw [hdb']; rfl
  obtain ⟨res, hres, hrn⟩ := intBin_wrap hm t sg ua ub
  have hbeq : intBytes t.size res.toNat =
      encodeBits t.size (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits ub))) := by
    rw [hrn]; rfl
  have hbs : BytesInj ι (encodeBits t.size (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits ub))))
      (intBytes t.size res.toNat) := by
    rw [hbeq]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits ub)))).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hW _ _ _ hlen0 hsto _ hbs
  have hop := opSem_bin_fwd (ch := ch) hkd hh hty ho hfits hrfa hrfb hva hvb hres hwr
  exact ⟨st', hop, hmi, hrd, hoth⟩

/-- `sim_binImm` with `_d` private or escaped (`DstWriteAll`). -/
theorem sim_binImmE {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {op : BinOp} {m : String} (hm : binMethod op = some m)
    {t : IntType} {valid vc : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    {sd sa : LocalSlot} (hsd : sd.size = t.size) (hsa : sa.size = t.size)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true)
    (hW : DstWriteAll ι fp st s.mem sd pd)
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
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  have hev2 := evalIntBinOp_wrap hm t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size)))
    (.int t valid) o s
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size)))
    (.int t valid)) o s = _ at hev
  rw [hev2] at hev
  simp only [Prod.mk.injEq, Except.ok.injEq] at hev
  obtain ⟨hw, hs1⟩ := hev
  subst hw
  subst s1
  have hsto := typedStore_int hst
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa] at hrfa
  have hda' := decodeBits_inj hia hda
  have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
  obtain ⟨res, hres, hrn⟩ := intBin_wrap hm t sg ua v
  have hcong : t.ofBits v = t.ofBits (bits % 2 ^ (8 * t.size)) :=
    ofBits_congr t (by rw [Nat.mod_mod]; exact hv)
  rw [hcong] at hrn
  have hbeq : intBytes t.size res.toNat = encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size))))) := by
    rw [hrn]; rfl
  have hbs : BytesInj ι (encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size))))))
      (intBytes t.size res.toNat) := by
    rw [hbeq]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua)
        (t.ofBits (bits % 2 ^ (8 * t.size)))))).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hW _ _ _ hlen0 hsto _ hbs
  have hop := opSem_binImm_fwd (ch := ch) hkd hh hty ho hfits hfk hrfa hva hres hwr
  exact ⟨st', hop, hmi, hrd, hoth⟩

/-- `sim_constInt` with `_d` private or escaped (`DstWriteAll`). -/
theorem sim_constIntE {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {t : IntType} {valid : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid))
    {sd : LocalSlot} (hsd : sd.size = t.size)
    {pd : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hW : DstWriteAll ι fp st s.mem sd pd)
    {opc : Full.Opcode} {r : Option String} {ty : String} {sg : Bool} {k : OperandKind}
    (hh : opc.handler? = some ⟨.imm, [ty], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31)
    {v : Nat} (hfk : Val.fits k (.imm v) = true)
    (hv : v % 2 ^ (8 * t.size) = bits % 2 ^ (8 * t.size))
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.const (.scalar bits) (.int t valid)))))
      o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .imm v] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', td, rv, s1, hpd', htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  subst e1 e4
  have e3 : evalOperand (.const (.scalar bits) (.int t valid)) =
      (evalConst (.scalar bits) (.int t valid) >>= fun w => pure (w, Spec.Ty.int t valid)) := by
    first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
  rw [e3] at hev
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h2
  subst rv
  subst s1
  have e5 : evalConst (.scalar bits) (Spec.Ty.int t valid) =
      decodeConst (encodeBits t.size bits) (.int t valid) := by
    first
      | rfl
      | (show decodeConst (encodeBits (Spec.Ty.int t valid).size bits) _ = _; rw [size_int])
  rw [e5] at h1
  obtain ⟨hdec, hs2⟩ := runOn_decodeConst_ok h1
  subst s2
  obtain ⟨-, u, hdu, rfl⟩ := decode_int_some hdec
  rw [Ryo.Spec.Theorems.decodeBits_encodeBits] at hdu
  have hu : u = bits % 2 ^ (8 * t.size) := (Option.some.inj hdu).symm
  have hsto := typedStore_int hst
  rw [encodeBits_toBits_ofBits, hu, encodeBits_mod] at hsto
  have hib : intBytes t.size v = encodeBits t.size bits := by
    show encodeBits t.size v = _
    rw [← encodeBits_mod t.size v, hv, encodeBits_mod]
  have hbs : BytesInj ι (encodeBits t.size bits) (intBytes t.size v) := by
    rw [hib]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size bits).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hW _ _ _ hlen0 hsto _ hbs
  have hop := opSem_imm_fwd (ch := ch) hh hty ho hfits hfk hwr
  exact ⟨st', hop, hmi, hrd, hoth⟩

/-- `sim_constBool` with `_d` private or escaped (`DstWriteAll`). -/
theorem sim_constBoolE {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {bits : Nat}
    (htd : f.body.locals[d]? = some .bool)
    {sd : LocalSlot} (hsd : sd.size = 1)
    {pd : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hW : DstWriteAll ι fp st s.mem sd pd)
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
  obtain ⟨bsd, hen', hsto⟩ := typedStore_inv hst
  have hbsd : bsd = encodeBits 1 bits := by
    have := hen.symm.trans hen'
    rw [encodeBits_one]
    exact (Option.some.inj this).symm
  subst hbsd
  have hib : intBytes 1 v = encodeBits 1 bits := by
    show encodeBits 1 v = _
    rw [← encodeBits_mod 1 v, hv, encodeBits_mod]
  have hbs : BytesInj ι (encodeBits 1 bits) (intBytes 1 v) := by
    rw [hib]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits 1 bits).length = sd.size := by rw [hsd]; rfl
  obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hW _ _ _ hlen0 hsto _ hbs
  have hop := opSem_imm_fwd (ch := ch) hh hty ho hfits hfk hwr
  exact ⟨st', hop, hmi, hrd, hoth⟩

/-! ### The lift -/

/-- `LowerStmtEsc`'s lift (see the module comment). -/
theorem lift_stmtEsc {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerStmtEsc Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @binop d a b oa ob op m t valid sd sa sb i hm ha hb htd hta htb hsd hsa hsb hsize hoff
      hbi =>
    have hla := hlo _ (List.mem_append_left _ (operand_local_mem ha))
    have hlb := hlo _ (List.mem_append_right _ (operand_local_mem hb))
    rw [eval_binop_norm ha hb] at h
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htd hta htb
    obtain ⟨pd, pa, pb, _, _, _, _, _, _, hpd, hpa, hpb', -⟩ := assign_binop_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hrb := hrel.opnd hpb' hsb hlb
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf d _ _ htd
    have hW := hrel.dstWriteAll hld hpd hsd hpos
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_binopE (ch := ch) hs hm htd hta htb hsize.1
      hsize.2.1 hsize.2.2 hpd hpa hpb' hrel.frame.mem hra hrb hW hkd hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ h
    obtain ⟨pd', hpd', hstk, bs, hsto, hnp⟩ := binop_mem hs hm htd hta htb h
    obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb'', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb'',
      hle⟩
  | @binopImm d a oa op m bits t valid sd sa i hm ha htd hta hsd hsa hsize hoff hbi =>
    have hla := hlo _ (List.mem_append_left _ (operand_local_mem ha))
    rw [eval_binopImm_norm ha] at h
    obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmInsnOk_spec hbi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands3 hn hk
    have hops'' : v.ops = [.slot sd.off, .slot sa.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd hta
    obtain ⟨pd, pa, _, _, _, _, hpd, hpa, -⟩ := assign_binimm_inv hs h
    have hra := hrel.opnd hpa hsa hla
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf d _ _ htd
    have hW := hrel.dstWriteAll hld hpd hsd hpos
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_binImmE (ch := ch) hs hm htd hta hsize.1 hsize.2
      hpd hpa hrel.frame.mem hra hW hkd hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk hx h
    obtain ⟨pd', hpd', hstk, bs, hsto, hnp⟩ := binImm_mem hs hm htd hta h
    obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb'', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb'',
      hle⟩
  | @constInt d bits t valid sd i htd hsd hsize hoff hii =>
    obtain ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hii
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands2 hn hk
    have hops'' : v.ops = [.slot sd.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, hpd, -⟩ := assign_use_inv hs h
    have hpos : 0 < sd.size := by rw [hsize]; exact hwf d _ _ htd
    have hW := hrel.dstWriteAll hld hpd hsd hpos
    have hf1 := offOk_spec hoff
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_constIntE (ch := ch) hs htd hsize hpd hW hh hty' ho
      ⟨hf1.1, hf1.2⟩ hfk hx h
    obtain ⟨pd', hpd', hstk, bs, hsto, hnp⟩ := use_mem hs htd
      (fun r s1 hr => (runOn_evalOperand_const_scalar_int hr).2) h
    obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb'', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb'',
      hle⟩
  | @constBool d bits sd i htd hsd hsize hoff hii =>
    obtain ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hii
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands2 hn hk
    have hops'' : v.ops = [.slot sd.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at htd
    obtain ⟨pd, _, _, _, hpd, -⟩ := assign_use_inv hs h
    have hpos : 0 < sd.size := by rw [hsize]; exact Nat.one_pos
    have hW := hrel.dstWriteAll hld hpd hsd hpos
    have hf1 := offOk_spec hoff
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_constBoolE (ch := ch) hs htd hsize hpd hW hh hty'
      ho ⟨hf1.1, hf1.2⟩ hfk hx h
    obtain ⟨pd', hpd', hstk, hsto⟩ := constBool_mem hs htd h
    obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
    have hnp := encodeBits_noprov 1 bits
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb'', hle⟩ := memInv_store hpb hsto hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb'',
      hle⟩

/-- `LowerStmtEsc` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_cmpX`). -/
theorem stmt_sim_stmtEsc {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerStmtEsc Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at h ⊢
    cases h <;> exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at h
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
    (lift_stmtEsc M.stack M.body.symm hwf hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb
      M.dinv.2 hl2 hl1 hev)

end Ryo.Proofs.Lower
