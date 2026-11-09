/-
Ryo.Proofs.Lower.SimMove — the simulation of two more statement forms (M5a), modelled on
`sim_binop` (`Ryo.Proofs.Lower.SimBinOp`), with `_d` private:

- `sim_copyInt`: `_d = copy _a` on integer locals of type `t`, lowered to `mov.wN d, s`
  (handler kind `mov`). L0 stores the re-encoding of the bits it loaded, R the bytes it read;
  the former refine the latter (`bytesInj_encodeBits_of_decode`).
- `sim_constInt`: `_d = const bits` at integer type `t`, lowered to `imm.wN d, v` (handler kind
  `imm`) with `v ≡ bits` modulo `2^(8 t.size)`. Both sides store `encodeBits t.size bits`.

The L0 side is `assign_use_inv` (an assignment of an operand) with `runOn_decodeConst_ok` (a
constant decodes at its type); the R side the forward directions of `Inline.opSem_mov` and
`Inline.opSem_imm` (`opSem_mov_fwd`, `opSem_imm_fwd`).
-/
import Ryo.Proofs.Lower.SimBinOp

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem
open Ryo.Check.Lower (LocalSlot)

/-! ### Bytes -/

/-- `encodeBits n` only depends on the value modulo `2^(8n)`. -/
theorem encodeBits_mod (n v : Nat) : encodeBits n (v % 2 ^ (8 * n)) = encodeBits n v := by
  unfold encodeBits
  rw [Ryo.Spec.Theorems.leEncode_mod]

/-- Re-encoding an integer decoded at its type gives the bytes of the bits decoded. -/
theorem encodeBits_toBits_ofBits (t : IntType) (u : Nat) :
    encodeBits t.size (t.toBits (t.ofBits u)) = encodeBits t.size u := by
  rw [Ryo.Spec.Theorems.IntType.toBits_ofBits, ← modulus_eq_two_pow, encodeBits_mod]

/-- Fresh data bytes refine the initialized bytes they were read from. -/
theorem bytesInj_ofBytes_of_mapM (ι : Inj) {bs : List AbstractByte} {ds : List UInt8}
    (h : bs.mapM AbstractByte.data = some ds) : BytesInj ι (ds.map AbstractByte.ofByte) bs := by
  induction bs generalizing ds with
  | nil =>
    simp at h
    subst h
    exact True.intro
  | cons x bs ih =>
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.pure_def] at h
    cases hx : x.data with
    | none => simp [hx] at h
    | some d =>
      cases hl : bs.mapM AbstractByte.data with
      | none => simp [hx, hl] at h
      | some ds' =>
        simp [hx, hl] at h
        subst h
        show ByteInj ι (AbstractByte.ofByte d) x ∧ BytesInj ι (ds'.map AbstractByte.ofByte) bs
        refine ⟨?_, ih hl⟩
        rw [Ryo.Spec.Theorems.AbstractByte.eq_init_of_data hx]
        exact (rfl : d = d)

/-- The encoding of the bits decoded from `n` bytes refines those bytes. -/
theorem bytesInj_encodeBits_of_decode {ι : Inj} {bs : List AbstractByte} {n u : Nat}
    (h : decodeBits bs = some u) (hl : bs.length = n) : BytesInj ι (encodeBits n u) bs := by
  rw [Ryo.Spec.Theorems.decodeBits_iff] at h
  obtain ⟨ds, hds, rfl⟩ := h
  have hl' : ds.length = n := by
    rw [← hl]; exact Ryo.Spec.Theorems.length_mapM_option _ _ _ hds
  subst hl'
  unfold encodeBits
  rw [Ryo.Spec.Theorems.leEncode_leDecode]
  exact bytesInj_ofBytes_of_mapM ι hds

/-! ### L0 -/

theorem size_int (t : IntType) (valid : ValidRange) : (Spec.Ty.int t valid).size = t.size := by
  first
    | rfl
    | (unfold Spec.Ty.size; rw [size?_int]; rfl)

theorem runOn_getMem (o : Spec.Oracle) (s : Spec.State) :
    runOn SemM.getMem o s = (.ok s.mem, s) := rfl

/-- A constant's bytes decoded at its type, run to success: the decoding, no state change. -/
theorem runOn_decodeConst_ok {o : Spec.Oracle} {s s1 : Spec.State} {bytes : List AbstractByte}
    {ty : Spec.Ty} {v : Value} (h : runOn (decodeConst bytes ty) o s = (.ok v, s1)) :
    ty.decode bytes = some v ∧ s1 = s := by
  cases hdec : ty.decode bytes with
  | none =>
    unfold decodeConst at h
    first | rw [hdec] at h | simp only [hdec] at h
    exact (prod_err_ok h).elim
  | some w =>
    have e : runOn (decodeConst bytes ty) o s = runOn (SemM.getMem >>= fun m =>
        SemM.liftE (checkValue m w ty) >>= fun _ => (pure w : SemM Value)) o s := by
      first
        | (unfold decodeConst; rw [hdec]; done)
        | (unfold decodeConst; rw [hdec]; rfl)
        | (simp only [decodeConst, hdec]; done)
        | (simp only [decodeConst, hdec]; rfl)
    rw [e] at h
    obtain ⟨m, s2, h1, h2⟩ := runOn_bind_ok h
    rw [runOn_getMem] at h1
    obtain ⟨-, hs2⟩ := prod_ok_inj h1
    subst hs2
    obtain ⟨_, s3, h3, h4⟩ := runOn_bind_ok h2
    obtain ⟨-, hs3⟩ := runOn_liftE_ok h3
    subst hs3
    obtain ⟨hv, hs⟩ := prod_ok_inj h4
    exact ⟨by rw [hv], hs.symm⟩

/-- An assignment of an operand to a local (no projections), run to success: the local is
live, the operand evaluates, and the store writes its value. -/
theorem assign_use_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {op : Operand}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use op))) o s = (.ok (), s')) :
    ∃ pd td r s1, f.locals[d]? = some (some pd) ∧ f.body.locals[d]? = some td ∧
      runOn (evalOperand op) o s = (.ok r, s1) ∧
      ∃ mem', typedStore s1.mem pd r.1 td .one = .ok mem' ∧ s' = { s1 with mem := mem' } := by
  have e : evalStatement (.assign ⟨d, []⟩ (.use op)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.use op) ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.use op) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.use op) td = (evalOperand op >>= fun r => pure r.1) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨hv, hs3⟩ := prod_ok_inj h6
  subst v
  subst s3
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pd, td, r, s2, hld, htd, h5, mem', hst, hs'⟩

/-! ### R -/

/-- The footprint of a `mov` handler at `n` bytes. -/
def movFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "s" n], writes := [Ryo.Proofs.Inline.rdA "d" n] }

/-- The footprint of an `imm` handler at `n` bytes. -/
def immFp (n : Nat) : Footprint := { writes := [Ryo.Proofs.Inline.rdA "d" n] }

/-- The forward direction of `Inline.opSem_mov`. -/
theorem opSem_mov_fwd {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {d s : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.mov, [ty], r⟩) (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ s ∧ s < 2 ^ 31)
    {bs : List AbstractByte} (hr : st.readFrame s n = .ok bs) (hlen : bs.length = n)
    (hw : st.writeFrame d bs = .ok st') :
    opSem op [.slot d, .slot s] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, hs1, hs2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfs := slot_fits hs1 hs2
  have hfp : footprint op = some (movFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (ps := []) (Ryo.Proofs.Inline.tySize_of_parse hty)).1
  have hprep : prepare op [.slot d, .slot s] =
      .ok (⟨.mov, [ty], r⟩, (movFp n), opndVal op.info [.slot d, .slot s]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfs])]
    rfl
  have hvs : opndVal op.info [.slot d, .slot s] "s" = some (.slot s) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .slot s] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (movFp n) (opndVal op.info [.slot d, .slot s]) st = .ok [("s", bs)] := by
    simp only [readAll, movFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvs, Val.slotOff, Extent.eval, hr,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .mov [ty] (mkEnv [("s", bs)] (opndVal op.info [.slot d, .slot s]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", bs)] } := by
    simp [kindSem, mkEnv, out, bind, Except.bind, pure, Except.pure]
  have hc : commit (movFp n) (opndVal op.info [.slot d, .slot s]) st [("d", bs)] = .ok st' := by
    simp only [commit, movFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval, hlen,
      hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-- The forward direction of `Inline.opSem_imm` (the immediate must fit its operand kind). -/
theorem opSem_imm_fwd {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {k : OperandKind} {d : Int} {v : Nat} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.imm, [ty], r⟩) (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"imm", k⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31) (hfk : Val.fits k (.imm v) = true)
    (hw : st.writeFrame d (intBytes n v) = .ok st') :
    opSem op [.slot d, .imm v] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfp : footprint op = some (immFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_w (ps := []) (Ryo.Proofs.Inline.tySize_of_parse hty)).2.1
  have hprep : prepare op [.slot d, .imm v] =
      .ok (⟨.imm, [ty], r⟩, (immFp n), opndVal op.info [.slot d, .imm v]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfk])]
    rfl
  have hvi : opndVal op.info [.slot d, .imm v] "imm" = some (.imm v) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .imm v] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (immFp n) (opndVal op.info [.slot d, .imm v]) st = .ok [] := by
    first
      | rfl
      | simp [readAll, immFp, pure, Except.pure]
  have hk : kindSem .imm [ty] (mkEnv [] (opndVal op.info [.slot d, .imm v]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes n v)] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.imm, hvi, out, bind,
      Except.bind, pure, Except.pure]
  have hlen : (intBytes n v).length = n := Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (immFp n) (opndVal op.info [.slot d, .imm v]) st
      [("d", intBytes n v)] = .ok st' := by
    simp only [commit, immFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval, hlen,
      hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-! ### The simulations -/

/-- `_d = copy _a` on integer locals of type `t`, lowered to `mov.wN d, a` (see the module
comment). -/
theorem sim_copyInt {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {t : IntType} {valid : ValidRange}
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
    {opc : Full.Opcode} {r : Option String} {ty : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.mov, [ty], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t.size sg))
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
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  subst rv
  subst s1
  -- the load
  obtain ⟨bsa, ua, hloa, hda, hlena, rfl⟩ := typedLoad_int hla
  -- the store: the bits loaded, re-encoded
  have hsto := typedStore_int hst
  rw [encodeBits_toBits_ofBits] at hsto
  -- R's read
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa] at hrfa
  have hda' := decodeBits_inj hia hda
  have hlenb : ba.length = t.size := (BytesInj.length hia).symm.trans hlena
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
  have hbs : BytesInj ι (encodeBits t.size ua) ba := bytesInj_encodeBits_of_decode hda' hlenb
  have hlen0 : (encodeBits t.size ua).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlenb, ← hsd]; exact hap)

/-- `_d = const bits` at integer type `t`, lowered to `imm.wN d, v` with `v ≡ bits` (see the
module comment). -/
theorem sim_constInt {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d : Local} {t : IntType} {valid : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid))
    {sd : LocalSlot} (hsd : sd.size = t.size)
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
  -- the constant
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
  -- the store: `encodeBits t.size bits`
  have hsto := typedStore_int hst
  rw [encodeBits_toBits_ofBits, hu, encodeBits_mod] at hsto
  -- R's write: the same bytes
  have hib : intBytes t.size v = encodeBits t.size bits := by
    show encodeBits t.size v = _
    rw [← encodeBits_mod t.size v, hv, encodeBits_mod]
  have hlen : (intBytes t.size v).length = t.size := by
    rw [hib]; exact Ryo.Spec.Theorems.encodeBits_length _ _
  have hpw : ∀ i < (intBytes t.size v).length, st.escapedAt (sd.off + i) = none := by
    intro i hi
    rw [hlen, ← hsd] at hi
    exact hprivd i hi
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off (intBytes t.size v) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_imm_fwd (ch := ch) hh hty ho hfits hfk hwr
  have hbs : BytesInj ι (encodeBits t.size bits) (intBytes t.size v) := by
    rw [hib]; exact encodeBits_inj ι _ _
  have hlen0 : (encodeBits t.size bits).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsd]; exact hap)

end Ryo.Proofs.Lower
