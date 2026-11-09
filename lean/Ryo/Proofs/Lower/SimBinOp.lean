/-
Ryo.Proofs.Lower.SimBinOp — the simulation of one statement (M5a): `_d = op(copy _a, copy _b)`
on integer locals of type `t`, lowered to the handler instruction `op.wN d, a, b` (a `bin` or
`binop` kind with method `binMethod op` at `t`'s width and signedness), with `_d` private.

From related states (each of the three locals related to its slot, `_a` and `_b` semantically
live) a successful L0 run of the statement is matched by a successful `opSem` of the
instruction, and the states after are related: `MemInj` still holds, `_d` is related and live,
and every other local whose slot is disjoint from `_d`'s keeps its relation.
-/
import Ryo.Proofs.Lower.IntBin

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem
open Ryo.Check.Lower (LocalSlot)

/-- An L0 store into another allocation (or of no bytes) leaves an allocation unchanged. -/
theorem get?_store_other {m0 m0' : Memory} {q : ThinPointer} {bs : List AbstractByte}
    {al : Align} (h : m0.store q bs al = .ok m0') {a : AllocId}
    (hne : q.prov ≠ some a ∨ bs = []) : m0'.get? a = m0.get? a := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with
    ⟨-, -, rfl⟩ | ⟨id, hid, -, hlen, hprov, -, -, -, -, rfl⟩
  · rfl
  · have hia : id ≠ a := by
      rintro rfl
      rcases hne with hne | hne
      · exact hne hprov
      · exact hlen (by rw [hne]; rfl)
    unfold Memory.get?
    first
      | (simp only [Array.getElem?_set, if_neg hia]; done)
      | (rw [Array.getElem?_set_ne _ _ hia])
      | simp [Array.getElem?_set, hia]

/-- An L0 store into an allocation other than a local's keeps its relation. -/
theorem LocalRel.store_other {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p q : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 slot p lv)
    {bs : List AbstractByte} {al : Align} (h : m0.store q bs al = .ok m0')
    (hne : q.prov ≠ p.prov ∨ bs = []) : LocalRel ι fp st m0' slot p lv := by
  have hg : ∀ a, p.prov = some a → m0'.get? a = m0.get? a := by
    intro a hp
    apply get?_store_other h
    rcases hne with hne | hne
    · exact .inl (by rw [← hp]; exact hne)
    · exact .inr hne
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    exact .priv a x hp hι (by rw [hg a hp]; exact hx) hlive haddr hpaddr hsize hpriv hbytes
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    exact .esc a x e y hp hι (by rw [hg a hp]; exact hx) hlive haddr hpaddr hsize hin hy hylive
      hyaddr hysize

/-- The statement's simulation (see the module comment). -/
theorem sim_binop {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
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
    -- `_d` private
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    -- the instruction
    {opc : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String} {ty : String}
    (hkd : kd = .bin ∨ kd = .binop) (hh : opc.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size t.signed))
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
  -- the loads
  obtain ⟨bsa, ua, hloa, hda, -, rfl⟩ := typedLoad_int hla
  obtain ⟨bsb, ub, hlob, hdb, -, rfl⟩ := typedLoad_int hlb
  -- the operation
  have hev2 := evalIntBinOp_wrap hm t (t.ofBits ua) (t.ofBits ub) (.int t valid) o s
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits ub) (.int t valid)) o s = _ at hev
  rw [hev2] at hev
  simp only [Prod.mk.injEq, Except.ok.injEq] at hev
  obtain ⟨hv, hs1⟩ := hev
  subst hv
  subst s1
  -- the store
  have hsto := typedStore_int hst
  -- R's reads
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
  obtain ⟨res, hres, hrn⟩ := intBin_wrap hm t t.signed ua ub
  -- R's write
  have hbeq : intBytes t.size res.toNat =
      encodeBits t.size (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits ub))) := by
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
  have hop := opSem_bin_fwd (ch := ch) hkd hh hty ho hfits hrfa hrfb hva hvb hres hwr
  have hbs : BytesInj ι (encodeBits t.size (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits ub))))
      (intBytes t.size res.toNat) := by
    rw [hbeq]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size
      (t.toBits (wrapResult op t (t.ofBits ua) (t.ofBits ub)))).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

end Ryo.Proofs.Lower
