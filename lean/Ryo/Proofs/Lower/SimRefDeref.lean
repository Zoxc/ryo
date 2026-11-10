/-
Ryo.Proofs.Lower.SimRefDeref — the simulation of `LowerRefDeref` (`Check/Lower/RefDeref.lean`,
M5b's places): `_d = &(*_p).f₁.….fₖ` / `&raw …` lowered to `mov.w64 d, p` (offset 0) or
`ptr_add d, p, off` into `_d`'s slot, private or escaped.

L0 (`assign_refDeref_inv`): as `ref`'s `assign_ref_inv`, with `runOn_evalPlace_deref` for the
place: `_p`'s 8 bytes `bp` decode to `q`, the fields offset it in bounds (`q.addr + off <
2^64`), and `_d` gets `encodePtr ⟨q.addr + off, q.prov⟩`. No memory is accessed through `q`, so
nothing about where it points is needed (no `DerefInv`).

R (`refDeref_rstep`): `_p`'s slot bytes `bp1` relate to `bp` (`readLocal_inj`). At offset 0,
`mov` copies `bp1`, which L0's re-encoding refines (`ptr_reenc_le`, `BytesInj.of_le_trans`);
otherwise `ptr_add` writes `encodePtr (q1.wrappingOffset off)` for R's decoding `q1`
(`decodePtr_inj`), at L0's address (`wrappingOffset_addr`) with the related provenance
(`encodePtr_inj'`). `FnRel.dstWrite` then writes and relates `_d`, private or escaped (as
`SimDst`; `LiveDisjoint` for the escaped case).

Invariants: the stored provenance is `q.prov`, carried by a byte of `bp` (`encodePtr_sub`), so
`Hidden`, `ProvBounded` and `MemKept` (hence `DerefInv`) follow from `_p`'s load as for a copy
(`Hidden.load`, `ProvBounded.load`, `memKept_load`).

`encodePtr_inj'`/`encodePtr_prov'` restate `SimRef`'s `encodePtr_inj`/`encodePtr_prov` here:
`SimRef` imports `FnStep`, which imports this file.
-/
import Ryo.Proofs.Lower.SimDeref
import Ryo.Proofs.Lower.SimCopy
import Ryo.Proofs.Lower.WriteDst
import Ryo.Check.Lower.RefDeref

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Pointer encodings -/

/-- The same address bytes with related provenances (`SimRef.ptrBytes_inj`). -/
theorem ptrBytes_inj' {ι : Inj} (L : List UInt8) {pr0 pr1 : Option AllocId}
    (h : ProvInj ι pr0 pr1) :
    BytesInj ι (Ryo.Spec.Theorems.ptrBytes L pr0) (Ryo.Spec.Theorems.ptrBytes L pr1) := by
  refine BytesInj.of_getElem (by simp [Ryo.Spec.Theorems.ptrBytes]) fun i h0 h1 => ?_
  simp only [Ryo.Spec.Theorems.ptrBytes, List.getElem_map, List.getElem_zipIdx]
  cases pr0 with
  | none => simp [ByteInj]
  | some a =>
    simp only [ProvInj] at h
    cases ha : ι a with
    | none => simp [ByteInj, ha]
    | some b =>
      simp only [ha] at h
      subst h
      simp [ByteInj, ha]

/-- Related pointers have related encodings (`SimRef.encodePtr_inj`). -/
theorem encodePtr_inj' {ι : Inj} {p0 p1 : ThinPointer} (h : PtrInj ι p0 p1) :
    BytesInj ι (encodePtr p0) (encodePtr p1) := by
  rw [Ryo.Spec.Theorems.encodePtr_eq, Ryo.Spec.Theorems.encodePtr_eq, ← h.1]
  exact ptrBytes_inj' _ h.2

/-- A byte of a pointer's encoding carries the pointer's provenance (`SimRef.encodePtr_prov`). -/
theorem encodePtr_prov' {p : ThinPointer} {b : AbstractByte} {fr : ProvenanceFrag}
    (hb : b ∈ encodePtr p) (hf : b.provFrag = some fr) : p.prov = some fr.prov := by
  rw [Ryo.Spec.Theorems.encodePtr_eq] at hb
  unfold Ryo.Spec.Theorems.ptrBytes at hb
  obtain ⟨⟨x, j⟩, -, rfl⟩ := List.mem_map.1 hb
  cases hpr : p.prov with
  | none => simp [hpr, AbstractByte.provFrag] at hf
  | some q =>
    simp [hpr, AbstractByte.provFrag] at hf
    subst hf
    rfl

/-- The provenance of the encoding of a pointer derived from `decodePtr bp` is carried by some
byte of `bp` (the form `memKept_load` and the `Hidden`/`ProvBounded` transfers take).

Proof: `encodePtr_prov'` gives `q.prov = some fr.prov`, `decodePtr_prov_mem` a byte of `bp`
with it, `List.mem_iff_getElem` its index. -/
theorem encodePtr_sub {bp : List AbstractByte} {q : ThinPointer} (hq : decodePtr bp = some q)
    (off : Nat) :
    ∀ b ∈ encodePtr ⟨q.addr + off, q.prov⟩, ∀ fr, b.provFrag = some fr →
      ∃ j, ∃ hj : j < bp.length, ∃ fr0, bp[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
  intro b hb fr hf
  have h1 : (⟨q.addr + off, q.prov⟩ : ThinPointer).prov = some fr.prov := encodePtr_prov' hb hf
  obtain ⟨b0, hb0, fr0, hf0, he0⟩ := decodePtr_prov_mem hq h1
  obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hb0
  exact ⟨j, hj, fr0, hf0, he0⟩

/-! ### L0 -/

/-- L0's `_d = &(*_p).fields` / `&raw (*_p).fields` into a thin pointer local: `_p`'s pointer
`q` offset by `off`, encoded, stored into `_d`.

Proof: as `assign_ref_inv`: `evalStatement`'s `assign` binds `evalPlace ⟨d, []⟩`
(`runOn_localPlace_ok`) and `evalRvalue`, which is `addrOf ⟨p, .deref pointee :: fields⟩ _ chk`;
`runOn_evalPlace_deref hs htp hk hpath` gives the place and the state unchanged, `checkValue`
(for `&`) leaves it too (`runOn_liftE_ok`); `placeStore` at `.ptr ptd vd` is `typedStore`
(`typedStore_inv`), whose encoding of a thin pointer (`hkd`) is `encodePtr`. -/
theorem assign_refDeref_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {rv : Rvalue}
    {pointee ty : Spec.Ty} {fields : List ProjElem} {off : Nat} {pt ptd : PtrType}
    {valid vd : ValidRange}
    (hrv : refPlace? rv = some ⟨p, .deref pointee :: fields⟩)
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .none)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ pd pp bp q, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.store pd (encodePtr ⟨q.addr + off, q.prov⟩) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  have e : evalStatement (.assign ⟨d, []⟩ rv) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue rv ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd', hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue rv td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  -- the rvalue is `addrOf ⟨p, .deref pointee :: fields⟩ td chk`
  have hE : ∃ chk, evalRvalue rv td = addrOf ⟨p, .deref pointee :: fields⟩ td chk := by
    cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv
    all_goals subst hrv
    all_goals first
      | exact ⟨true, rfl⟩
      | exact ⟨false, rfl⟩
      | (refine ⟨true, ?_⟩; unfold evalRvalue; rfl)
      | (refine ⟨false, ?_⟩; unfold evalRvalue; rfl)
      | (refine ⟨true, ?_⟩; simp only [evalRvalue]; done)
      | (refine ⟨false, ?_⟩; simp only [evalRvalue]; done)
  obtain ⟨chk, hE⟩ := hE
  rw [hE] at h3
  -- `addrOf`: the place, then (for `&`) `checkValue`, which keeps the state
  have e3 : runOn (addrOf ⟨p, .deref pointee :: fields⟩ td chk) o s =
      runOn (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x =>
        if chk then (SemM.getMem >>= fun m => SemM.liftE (checkValue m (.ptr x.1.ptr) td) >>=
          fun _ => pure (Value.ptr x.1.ptr)) else pure (Value.ptr x.1.ptr)) o s := by
    cases chk <;> first | rfl | (unfold addrOf; rfl) | (simp only [addrOf]; rfl)
  rw [e3] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, hr, hs3⟩ := runOn_evalPlace_deref hs htp hk hpath h5
  subst hr
  rw [hs3] at h6
  have hv : v = .ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen ∧ s2 = s := by
    cases chk with
    | false =>
      have h6' : runOn (pure (Value.ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen) :
          SemM Value) o s = (.ok v, s2) := h6
      rw [runOn_pure] at h6'
      obtain ⟨h7, h8⟩ := prod_ok_inj h6'
      exact ⟨h7.symm, h8.symm⟩
    | true =>
      have h6' : runOn (SemM.getMem >>= fun m => SemM.liftE (checkValue m
          (.ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen) td) >>=
          fun _ => pure (Value.ptr (⟨q.addr + off, q.prov⟩ : ThinPointer).widen)) o s =
          (.ok v, s2) := h6
      obtain ⟨m, s4, h7, h8⟩ := runOn_bind_ok h6'
      rw [runOn_getMem] at h7
      obtain ⟨-, hs4⟩ := prod_ok_inj h7
      rw [← hs4] at h8
      obtain ⟨u, s5, h9, h10⟩ := runOn_bind_ok h8
      obtain ⟨-, hs5⟩ := runOn_liftE_ok h9
      rw [hs5] at h10
      rw [runOn_pure] at h10
      obtain ⟨h11, h12⟩ := prod_ok_inj h10
      exact ⟨h11.symm, h12.symm⟩
  obtain ⟨hv1, hv2⟩ := hv
  subst hv1
  rw [hv2] at h4
  obtain ⟨mem', hst, rfl⟩ := runOn_placeStore_ok h4
  obtain ⟨bs, hen, hsto⟩ := typedStore_inv hst
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  subst e4
  have hbs : bs = encodePtr ⟨q.addr + off, q.prov⟩ := by
    simp [Spec.Ty.encode, hkd, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbs
  exact ⟨pd, pp, bp, q, hld, hpp, hlp, hq, hlim, hsto, rfl⟩

/-! ### R -/

/-- The footprint of a `ptr_add` handler (`Inline.fp_ptr_add`). -/
def ptrAddFp : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "p" 8], writes := [Ryo.Proofs.Inline.rdA "d" 8] }

/-- The forward direction of `Inline.opSem_ptrAdd`.

Proof: as `opSem_load_fwd`: the footprint is `Inline.fp_ptr_add`'s (`footprint_eq hh`),
`prepare` succeeds (`ho`, the slots fit by `hfits`, the immediate by `hfk`), `readAll` reads
`p`'s 8 bytes `bs`, `kindSem .ptr_add` decodes them (`Env.ptr`, `asPtr`: `hq`), reads the
immediate (`Env.imm`) and writes the offset pointer's encoding, and `commit` writes it at `d`
(`encodePtr_length`, `hw`). -/
theorem opSem_ptrAdd_fwd {op : Full.Opcode} {r : Option String} {ps : List String}
    {d p : Int} {x : Nat} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.ptr_add, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"imm", .i64⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ p ∧ p < 2 ^ 31)
    (hfk : Val.fits .i64 (.imm x) = true)
    {bs : List AbstractByte} (hr : st.readFrame p 8 = .ok bs) {q : ThinPointer}
    (hq : decodePtr bs = some q)
    (hw : st.writeFrame d (encodePtr (q.wrappingOffset (BitVec.ofNat 64 x).toInt)) = .ok st') :
    opSem op [.slot d, .slot p, .imm x] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, hp1, hp2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfs := slot_fits hp1 hp2
  have hfp : footprint op = some ptrAddFp := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact Ryo.Proofs.Inline.fp_ptr_add ps
  have hprep : prepare op [.slot d, .slot p, .imm x] =
      .ok (⟨.ptr_add, ps, r⟩, ptrAddFp, opndVal op.info [.slot d, .slot p, .imm x]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfs, hfk])]
    rfl
  have hvp : opndVal op.info [.slot d, .slot p, .imm x] "p" = some (.slot p) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .slot p, .imm x] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hvi : opndVal op.info [.slot d, .slot p, .imm x] "imm" = some (.imm x) := by
    simp [opndVal, ho]
  have hrd : readAll ptrAddFp (opndVal op.info [.slot d, .slot p, .imm x]) st =
      .ok [("p", bs)] := by
    simp only [readAll, ptrAddFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvp, Val.slotOff, Extent.eval, hr,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .ptr_add ps (mkEnv [("p", bs)] (opndVal op.info [.slot d, .slot p, .imm x])
      st ch) =
      .ok { ctl := .next, mem := st.mem,
            writes := [("d", encodePtr (q.wrappingOffset (BitVec.ofNat 64 x).toInt))] } := by
    simp [kindSem, mkEnv, Env.ptr, Env.imm, asPtr, hq, hvi, out, bind, Except.bind, pure,
      Except.pure]
  have hc : commit ptrAddFp (opndVal op.info [.slot d, .slot p, .imm x]) st
      [("d", encodePtr (q.wrappingOffset (BitVec.ofNat 64 x).toInt))] = .ok st' := by
    simp only [commit, ptrAddFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval,
      Ryo.Spec.Theorems.encodePtr_length, hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-- R's step of `refDerefInsnOk`'s instruction, given `_p`'s slot bytes `bp1` related to L0's
`bp` and `DstWrite` for L0's store (`_d` private or escaped): it writes `_d`'s slot `sd` with
bytes refining L0's stored encoding, with `DstWrite`'s facts after it.

Proof: `off = 0`: `movInsnOk_spec`, `hW` at `bp1` (which refines L0's re-encoding:
`ptr_reenc_le`, `BytesInj.of_le_trans`), `opSem_mov_fwd` (8 bytes). Otherwise
`ptrAddInsnOk_spec`, `decodePtr_inj` for R's pointer `q1`, `wrappingOffset_addr` for the
address, `encodePtr_inj'`, `hW` at its encoding, `opSem_ptrAdd_fwd` (its immediate fits by
`PlainView.fits`, `fits_last`). Then `step_of_view`. -/
theorem refDeref_rstep {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {i : R.Insn} (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i)
    {sd : LocalSlot} {sp : Int} {off : Nat} (hri : refDerefInsnOk Γ i sd.off sp off = true)
    (hf1 : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31) (hf2 : -2 ^ 31 ≤ sp ∧ sp < 2 ^ 31)
    {bp bp1 : List AbstractByte} {q : ThinPointer}
    (hrfp : s1.st.readFrame sp 8 = .ok bp1) (hbp : BytesInj ι bp bp1)
    (hq : decodePtr bp = some q) (hl8 : bp.length = 8)
    (hlim : q.addr + off < Target.ADDR_LIMIT)
    {m0 m0' : Memory} {pd : ThinPointer}
    (hW : DstWrite ι s1.fp s1.st m0 m0' sd pd (encodePtr ⟨q.addr + off, q.prov⟩)) :
    ∃ st', R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
      st'.escaped = s1.st.escaped ∧ MemInj ι m0' st'.mem ∧
      LocalRel ι s1.fp st' m0' sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m0 slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι s1.fp st' m0' slot p lv := by
  have hlen1 : bp1.length = 8 := (BytesInj.length hbp).symm.trans hl8
  unfold refDerefInsnOk at hri
  split at hri
  next h0 =>
    subst h0
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hri
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    have hb : BytesInj ι (encodePtr ⟨q.addr + 0, q.prov⟩) bp1 := by
      rw [Nat.add_zero]
      exact (BytesInj.of_le_trans (ptr_reenc_le hl8 hq) hbp).1
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hW bp1 hb
    have hop := opSem_mov_fwd (ch := ch) hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfp hlen1 hwr
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hesc, hmi, hrd,
      hoth⟩
  next h0 =>
    obtain ⟨v, ps, r, hv, hh, ho, hops, hbv, hctl⟩ := ptrAddInsnOk_spec hri
    rw [hmode, hρ] at hv
    have hfk : Val.fits .i64 (.imm off) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops]; simp)
    obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
    have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off :=
      wrappingOffset_addr hpq.1 hlim
    have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
      unfold PtrInj
      exact ⟨hwo.symm, hpq.2⟩
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hW _ (encodePtr_inj' hpi)
    have hwr' : s1.st.writeFrame sd.off
        (encodePtr (q1.wrappingOffset (BitVec.ofNat 64 off).toInt)) = .ok st' := by
      rw [hbv]
      exact hwr
    have hop := opSem_ptrAdd_fwd (ch := ch) hh ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk hrfp hq1 hwr'
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hesc, hmi, hrd,
      hoth⟩

/-! ### The lift -/

/-- `LowerRefDeref`'s lift, with `lift_movMemE`'s interface (no `DerefInv` needed: nothing is
accessed through the pointer; `LiveDisjoint` for an escaped `_d`).

Proof: `cases hlow`; `assign_refDeref_inv` for L0 (`hbody` at the types); `_p` is read
(`rvalueLocals`), so live, and `hrel.opnd` relates it; `readLocal_inj` R's bytes of it;
`FnRel.dstWrite` the destination (private or escaped); `refDeref_rstep` the step. Then
`FnRel.after` assembles `FnRel` with `Hidden` by `Hidden.store_hidden` (the stored provenance
is a byte of `_p`'s load's: `encodePtr_sub`, `Hidden.load`), `ProvBounded.store` likewise,
`memKept_load`. -/
theorem lift_refDeref {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerRefDeref Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @mk d p rv pointee ty fields pt ptd valid vd off sd sp i hrv htpΓ hk hpath htdΓ hkd hsd hsp
      hsize hoff hri =>
    have htp : f.body.locals[p]? = some (.ptr pt valid) := by rw [← hbody]; exact htpΓ
    have htd : f.body.locals[d]? = some (.ptr ptd vd) := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, pp, bp, q, hpd, hpp, hlp, hq, hlim, hsto, hstk⟩ :=
      assign_refDeref_inv hs hrv htp hk hpath htd hkd h
    have hlp' : live p = true := hlo p (by
      cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
        (subst hrv; simp [rvalueLocals, placeLocals]))
    have hrp := hrel.opnd hpp hsp hlp'
    obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hrel.frame.mem hrp
      (show s.mem.load pp sp.size .one = .ok bp by rw [hsize.2]; exact hlp)
    rw [hsize.2] at hrfp
    have hpos8 : 0 < sd.size := by omega
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    have hlen0 : (encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer)).length = sd.size := by
      rw [Ryo.Spec.Theorems.encodePtr_length, hsize.1]
    have hW := hrel.dstWrite hld hpd hsd hpos8 hlen0 hsto
    obtain ⟨st', hstep, hesc, hmi, hrd, hoth⟩ := refDeref_rstep (ch := ch) hmode hρ hi hsc
      hpe hpl hri hf1 hf2 hrfp hbp hq (load_length hlp) hlim hW
    have hsub := encodePtr_sub hq off
    -- `Hidden` and the bound: the stored provenance is a byte of `_p`'s load's
    have hhid' : ∀ b ∈ encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer), ∀ fr,
        b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hrel.hidden.load hlp _ (List.getElem_mem hj) fr0 hf0
    have hbd' : BytesBounded s.mem.allocs.size (encodePtr (⟨q.addr + off, q.prov⟩ : ThinPointer)) := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hpb.load hlp _ (List.getElem_mem hj) fr0 hf0
    exact ⟨st', hstep, hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hlp hsub⟩

end Ryo.Proofs.Lower
