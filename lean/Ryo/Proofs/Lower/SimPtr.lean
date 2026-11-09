/-
Ryo.Proofs.Lower.SimPtr — copies of whole locals at any type whose re-encoding refines the bytes
it was decoded from (M5a): `bool` and thin pointers, lowered to a `mov` of the type's size.

`mov` copies the bytes it read, provenance included (`opSem_mov_fwd`), while L0 stores the
re-encoding of the value it decoded. `sim_copyBytes` is the simulation for any type given
that re-encoding refines what R copied (`Reenc`); `reenc_bool` and `reenc_ptr` prove it for
`bool` (the byte's provenance is dropped) and for thin pointers (`decodePtr` keeps the
provenance only when every byte carries it at its position, `encodePtr` writes it back, so each
byte is either the original or the original without provenance).
-/
import Ryo.Proofs.Lower.SimMove

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem
open Ryo.Check.Lower (LocalSlot)
open Ryo.Spec.Theorems (ptrBytes ptrProvOf)

/-! ### Typed accesses at any type -/

theorem typedLoad_inv {mem : Memory} {p : ThinPointer} {ty : Spec.Ty} {al : Align} {n : Nat}
    {v : Value} (hn : ty.size? = some n) (h : typedLoad mem p ty al = .ok v) :
    ∃ bs, mem.load p n al = .ok bs ∧ ty.decode bs = some v := by
  cases hl : mem.load p n al with
  | error e =>
    simp [typedLoad, hn, hl] at h
  | ok bs =>
    cases hdec : ty.decode bs with
    | none =>
      first
        | (simp [typedLoad, hn, hl, hdec, throwUb, throwThe, MonadExceptOf.throw] at h; done)
        | (simp [typedLoad, hn, hl, hdec] at h; done)
        | (simp only [typedLoad, hn, hl, hdec] at h; cases h)
    | some w =>
      cases hc : checkValue mem w ty with
      | error e => simp [typedLoad, hn, hl, hdec, hc] at h; cases h
      | ok _ =>
        simp [typedLoad, hn, hl, hdec, hc] at h
        refine ⟨bs, rfl, ?_⟩
        first
          | (rw [hdec, h])
          | (cases h; exact hdec)
          | (subst h; exact hdec)

theorem typedStore_inv {mem mem' : Memory} {p : ThinPointer} {v : Value} {ty : Spec.Ty}
    {al : Align} (h : typedStore mem p v ty al = .ok mem') :
    ∃ bs, ty.encode v = some bs ∧ mem.store p bs al = .ok mem' := by
  cases he : ty.encode v with
  | some bs =>
    simp only [typedStore, he] at h
    exact ⟨bs, rfl, h⟩
  | none =>
    first
      | (simp [typedStore, he, throwIllFormed, throwThe, MonadExceptOf.throw] at h; done)
      | (simp [typedStore, he] at h; done)
      | (simp only [typedStore, he] at h; cases h)

/-! ### Re-encoding -/

/-- Re-encoding a value decoded at `ty` refines whatever the decoded bytes refine, at `n`
bytes. -/
def Reenc (ι : Inj) (ty : Spec.Ty) (n : Nat) : Prop :=
  ∀ bs0 bs1 v bs', ty.decode bs0 = some v → ty.encode v = some bs' →
    BytesInj ι bs0 bs1 → BytesInj ι bs' bs1 ∧ bs'.length = n

/-- Dropping a byte's provenance keeps it below what it refined. -/
theorem byteInj_strip {ι : Inj} {x : UInt8} {f : Option ProvenanceFrag} {b : AbstractByte}
    (h : ByteInj ι (.init x f) b) : ByteInj ι (.init x none) b := by
  cases b with
  | uninit => cases f <;> simp [ByteInj] at h
  | init d g =>
    cases f with
    | none => exact h
    | some fr =>
      simp only [ByteInj] at h ⊢
      exact h.1

/-- A `bool` decodes from one initialized byte and re-encodes to it without provenance. -/
theorem decode_bool_inv {bs : List AbstractByte} {w : Value}
    (hd : Spec.Ty.bool.decode bs = some w) :
    ∃ x f, bs = [.init x f] ∧ Spec.Ty.bool.encode w = some [.init x none] := by
  simp only [Spec.Ty.decode] at hd
  split at hd
  · next f =>
    cases hd
    exact ⟨0, f, by first | rfl | (subst_vars; rfl) | simp_all,
      by first | rfl | simp [Spec.Ty.encode]⟩
  · next f =>
    cases hd
    exact ⟨1, f, by first | rfl | (subst_vars; rfl) | simp_all,
      by first | rfl | simp [Spec.Ty.encode]⟩
  · cases hd

theorem reenc_bool (ι : Inj) : Reenc ι .bool 1 := by
  intro bs0 bs1 v bs' hd he hi
  obtain ⟨x, f, rfl, hx⟩ := decode_bool_inv hd
  rw [hx] at he
  cases he
  cases bs1 with
  | nil => simp [BytesInj] at hi
  | cons b1 t1 =>
    cases t1 with
    | nil =>
      have hi' : ByteInj ι (.init x f) b1 ∧ BytesInj ι [] [] := hi
      refine ⟨?_, rfl⟩
      show ByteInj ι (.init x none) b1 ∧ BytesInj ι [] []
      exact ⟨byteInj_strip hi'.1, trivial⟩
    | cons _ _ => simp [BytesInj] at hi

/-- A thin pointer type's size. -/
theorem size?_ptr_thin {pt : PtrType} {valid : ValidRange} (hk : pt.metaKind = .none) :
    (Spec.Ty.ptr pt valid).size? = some 8 := by
  simp [Spec.Ty.size?, Spec.Ty.layout, PtrType.isWide, hk, LayoutStrategy.size?]

/-- A thin pointer decodes from 8 bytes, to the pointer `decodePtr` gives. -/
theorem decode_ptr_thin_inv {pt : PtrType} {valid : ValidRange} (hk : pt.metaKind = .none)
    {bs : List AbstractByte} {v : Value} (hd : (Spec.Ty.ptr pt valid).decode bs = some v) :
    ∃ tp, bs.length = 8 ∧ decodePtr bs = some tp ∧ v = .ptr ⟨tp, none⟩ := by
  simp only [Spec.Ty.decode, hk] at hd
  by_cases hl : bs.length = 8
  · cases hdp : decodePtr bs with
    | none => simp [hl, hdp] at hd
    | some tp =>
      by_cases hv : valid.contains tp.addr = true
      · simp [hl, hdp, hv] at hd
        exact ⟨tp, hl, rfl, hd.symm⟩
      · simp [hl, hdp, hv] at hd
  · simp [hl] at hd

theorem reenc_ptr (ι : Inj) {pt : PtrType} {valid : ValidRange} (hk : pt.metaKind = .none) :
    Reenc ι (.ptr pt valid) 8 := by
  intro bs0 bs1 v bs' hd he hi
  obtain ⟨tp, hlen, hdp, rfl⟩ := decode_ptr_thin_inv hk hd
  have he' : bs' = encodePtr tp := by
    simp [Spec.Ty.encode, hk] at he
    first | exact he.symm | exact he
  subst he'
  rw [Ryo.Spec.Theorems.decodePtr_eq] at hdp
  cases hdb : decodeBits bs0 with
  | none => simp [hdb] at hdp
  | some a =>
    simp [hdb] at hdp
    subst hdp
    obtain ⟨ds, hds, hda⟩ := (Ryo.Spec.Theorems.decodeBits_iff bs0 a).mp hdb
    obtain ⟨hlds, hget⟩ := (Ryo.Spec.Theorems.mapM_data_iff bs0 ds).mp hds
    have h8 : ds.length = 8 := by omega
    have henc : encodePtr ⟨a, ptrProvOf bs0⟩ = ptrBytes ds (ptrProvOf bs0) := by
      rw [Ryo.Spec.Theorems.encodePtr_eq]
      show ptrBytes (leEncode 8 a) _ = _
      rw [← hda, ← h8, Ryo.Spec.Theorems.leEncode_leDecode]
    rw [henc]
    have hl1 : bs1.length = 8 := (BytesInj.length hi).symm.trans hlen
    refine ⟨BytesInj_of_getElem (by rw [Ryo.Spec.Theorems.length_ptrBytes]; omega)
      (fun k h0 h1 => ?_), by rw [Ryo.Spec.Theorems.length_ptrBytes]; omega⟩
    rw [Ryo.Spec.Theorems.getElem_ptrBytes]
    have hk0 : k < bs0.length := by rw [Ryo.Spec.Theorems.length_ptrBytes] at h0; omega
    have hb := hi.getElem' k hk0 h1
    have hdk := hget k hk0 (by omega)
    obtain ⟨f, hf⟩ : ∃ f, bs0[k] = .init (ds[k]'(by omega)) f := by
      have key : ∀ (b : AbstractByte) (y : UInt8), b.data = some y → ∃ f, b = .init y f := by
        intro b y hby
        cases b with
        | uninit => simp [AbstractByte.data] at hby
        | init x f =>
          simp only [AbstractByte.data, Option.some.injEq] at hby
          exact ⟨f, by rw [hby]⟩
      exact key _ _ hdk
    rw [hf] at hb
    rcases Option.eq_none_or_eq_some (ptrProvOf bs0) with hpo | ⟨q, hpo⟩
    · simp only [hpo, Option.map_none]
      exact byteInj_strip hb
    · simp only [hpo, Option.map_some]
      have hq := ((Ryo.Spec.Theorems.ptrProvOf_iff bs0 q).mp hpo).2 k hk0
      rw [hf] at hq
      simp only [AbstractByte.provFrag] at hq
      subst hq
      exact hb

/-! ### The simulation -/

/-- `_d = copy _a` on locals of one type `ty` of `n` bytes whose re-encoding refines what it
was decoded from (`Reenc`), lowered to `mov` at `n` bytes, `_d` private. -/
theorem sim_copyBytes {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {ty : Spec.Ty} {n : Nat} (hn : ty.size? = some n) (hre : Reenc ι ty n)
    (htd : f.body.locals[d]? = some ty) (hta : f.body.locals[a]? = some ty)
    {sd sa : LocalSlot} (hsd : sd.size = n) (hsa : sa.size = n)
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
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.mov, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.copy ⟨a, []⟩)))) o s = (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', td, rv, s1, hpd', htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  obtain ⟨pa', ta, va, hpa', hta', hla, hrv, hs1⟩ := runOn_evalOperand_copy hs hev
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = ty := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = ty := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  subst rv
  subst s1
  -- the load and the store
  obtain ⟨bsa, hloa, hda⟩ := typedLoad_inv hn hla
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  -- R's read
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa] at hrfa
  obtain ⟨hbs, hlend⟩ := hre bsa ba va bsd hda hen hia
  have hlenb : ba.length = n := (BytesInj.length hbs).symm.trans hlend
  -- R's write
  have hpw : ∀ i < ba.length, st.escapedAt (sd.off + i) = none := by
    intro i hi
    rw [hlenb, ← hsd] at hi
    exact hprivd i hi
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off ba = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_mov_fwd (ch := ch) hh hty ho hfits hrfa hlenb hwr
  have hlen0 : bsd.length = sd.size := by rw [hlend, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlenb, ← hsd]; exact hap)

end Ryo.Proofs.Lower
