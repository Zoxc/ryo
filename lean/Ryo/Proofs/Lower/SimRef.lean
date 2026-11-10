/-
Ryo.Proofs.Lower.SimRef — the simulation of `ref` (`Check/Lower/Ref.lean`, M5b): `_d = &_a.fs` /
`&raw _a.fs` lowered to one `addr` from `_a`'s slot at `off` into `_d`'s slot (private or escaped), after
the `Escape` of `_a`'s whole slot (the statement's own scope, `ownSpec`), with pending `End`s
before it (`FnRelEsc.lean`'s design).

L0: the place evaluates to `_a`'s pointer offset by `off` (`runOn_evalPlace_fields`, as for
`field`), `&` checks the pointer's validity (`checkValue`, which only adds UB), and the value
`Value.ptr` of that thin pointer is stored into `_d`: one store of `encodePtr ⟨pa.addr + off,
pa.prov⟩` (`assign_ref_inv`). R: the `Escape` makes `_a` escaped (`scope_escape_rel`), `addr`
gives `⟨y.addr + (sa.off + off - e.off), some e.id⟩` for `_a`'s object `e` at `y.addr = fp +
e.off`, the same address as L0's (`pa.addr = fp + sa.off`), with the object's provenance, which
`ι'` maps `_a`'s allocation to (`addrOf_inj`); its encoding refines L0's bytes
(`encodePtr_inj`), so `FnRel.write_dst` (`WriteDst.lean`, with L0's `LiveDisjoint` from
`DerefInv`) writes and relates `_d`; a frame write keeps R's allocations' addresses, liveness and
sizes (`writeFrame_allocsKept`), which `FnRelX`'s `free`, `idLt`, `addrAt` read. The stored provenance is `_a`'s, no longer
private, so `Hidden` holds for `PrivAlloc ι'`; `ProvBounded` by `LocalRel.prov_lt`.

Hypotheses beyond the family interface's: the scopes before the instruction (`hsc`, `hpre`,
`hown`: `ScopesOk`), `FnRelX` (for `FnRel`), `ι`'s freshness (`MatchAt.fresh`) and `DerefInv`;
the conclusion is `LiftOutX` (`ι` grows).

`StmtSimX.lean` holds `stmt_simX`, one statement under pending scopes (`FnRelEsc.lean`'s
`MatchAtX` → `StmtOutX`): the one-instruction families and `LowerStmt`'s assignments on
`c.dropScopes` from the fold (`stmt_simX_family`, `stmt_simX_single`), `ref` (`stmt_simX_ref`),
`StorageDead` (`stmt_simX_storageDead`; its `End` located by `LowersFnX.stmtsX.endAt`).

`ScopeMulti.lean` holds the rest of `stmt_simX`'s cases: `StorageLive` (`storageLive_privX`,
`live_fnRelX`) and the deref `store`, `enum`, `agg` (their lifts on `c.cut`, the code without
scopes and cut at the range's end, so a `LiftOutN` run stays in the range: `run_cut`,
`stmtOutX_of_liftN`).

## The function level

Terminators with pending `End`s are `TermSimX.lean`'s, the run and the entry `FnSimX.lean`'s
(`fn_simX`, `match_entryEsc`, `fn_soundEsc`); the entry's `free`, `aligned` and no-object facts
are hypotheses there, for M5c.
-/
import Ryo.Proofs.Lower.FnRelEsc
import Ryo.Proofs.Lower.SimField
import Ryo.Proofs.Lower.FnStep
import Ryo.Check.Lower.Ref

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-- The forward direction of `Inline.opSem_addr`.

Proof: as `opSem_mov_fwd`: the footprint is `Inline.fp_addr ps` (via `Inline.footprint_eq hh`),
`prepare` succeeds (`ho`, `slot_fits`), `readAll` of no reads is `[]`, `kindSem .addr` is
`out e [("d", encodePtr p)]` (`Inline.addrOf_erase`: the kind's state has the frame erased, and
`addrOf` doesn't read it; `hp`), `commit` writes `d` (`hw`, `encodePtr`'s length 8). -/
theorem opSem_addr_fwd {op : Full.Opcode} {r : Option String} {ps : List String}
    {d s : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {p : ThinPointer}
    (hh : op.handler? = some ⟨.addr, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ s ∧ s < 2 ^ 31)
    (hp : st.addrOf s = .ok p) (hw : st.writeFrame d (encodePtr p) = .ok st') :
    opSem op [.slot d, .slot s] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, hs1, hs2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfs := slot_fits hs1 hs2
  have hfp : footprint op =
      some { writes := [Ryo.Proofs.Inline.rdA "d" 8], addrs := ["s"] } := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact Ryo.Proofs.Inline.fp_addr ps
  have hprep : prepare op [.slot d, .slot s] =
      .ok (⟨.addr, ps, r⟩, { writes := [Ryo.Proofs.Inline.rdA "d" 8], addrs := ["s"] },
        opndVal op.info [.slot d, .slot s]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfs])]
    rfl
  have hvs : opndVal op.info [.slot d, .slot s] "s" = some (.slot s) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .slot s] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll { writes := [Ryo.Proofs.Inline.rdA "d" 8], addrs := ["s"] }
      (opndVal op.info [.slot d, .slot s]) st = .ok [] := rfl
  have hk : kindSem .addr ps (mkEnv [] (opndVal op.info [.slot d, .slot s]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", encodePtr p)] } := by
    have hp' : ({ st with frame := fun _ => .uninit } : OpSem.State).addrOf s = .ok p := hp
    first
      | (simp [kindSem, mkEnv, out, Env.slot, hvs, hp', bind, Except.bind, pure, Except.pure];
          done)
      | (simp [kindSem, mkEnv, out, Env.slot, hvs, Ryo.Proofs.Inline.addrOf_erase, hp, bind,
          Except.bind, pure, Except.pure]; done)
  have hc : commit { writes := [Ryo.Proofs.Inline.rdA "d" 8], addrs := ["s"] }
      (opndVal op.info [.slot d, .slot s]) st [("d", encodePtr p)] = .ok st' := by
    simp only [commit, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval,
      Ryo.Spec.Theorems.encodePtr_length, hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)

/-- L0's `_d = &_a.projs` / `&raw _a.projs` into a thin pointer local: one store of the
encoding of `_a`'s pointer offset by `off`.

Proof: `refPlace?` splits `rv` into `.ref m p`/`.rawPtr m p` (`cases rv <;> simp at hrv`); then
as `assign_use_inv`: `evalStatement`'s `assign` binds `evalPlace ⟨d, []⟩` (`runOn_localPlace_ok`)
and `evalRvalue`, which is `addrOf ⟨a, projs⟩ _ check`: `runOn_evalPlace_fields hs hta hpath`
gives the place `⟨⟨pa.addr + off, pa.prov⟩.widen, true⟩` and the state unchanged, `checkValue`
(for `ref`) leaves it too (`runOn_liftE`); `placeStore` at `.ptr pt valid` is `typedStore`
(`typedStore_inv`), whose encoding of a thin pointer value (`metaKind = .none`) is `encodePtr`
of it (`Ty.encode`, as in `ptr_reenc_prov`). -/
theorem assign_ref_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {rv : Rvalue}
    {projs : List ProjElem} {ta ty : Spec.Ty} {off : Nat} {pt : PtrType} {valid : ValidRange}
    (hrv : refPlace? rv = some ⟨a, projs⟩)
    (hta : f.body.locals[a]? = some ta) (hpath : fieldPath ta projs = some (off, ty))
    (htd : f.body.locals[d]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ pd pa, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.store pd (encodePtr ⟨pa.addr + off, pa.prov⟩) .one = .ok s'.mem ∧
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
  -- the rvalue is `addrOf ⟨a, projs⟩ td chk`
  have hE : ∃ chk, evalRvalue rv td = addrOf ⟨a, projs⟩ td chk := by
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
  have e3 : runOn (addrOf ⟨a, projs⟩ td chk) o s = runOn (evalPlace ⟨a, projs⟩ >>= fun x =>
      if chk then (SemM.getMem >>= fun m => SemM.liftE (checkValue m (.ptr x.1.ptr) td) >>=
        fun _ => pure (Value.ptr x.1.ptr)) else pure (Value.ptr x.1.ptr)) o s := by
    cases chk <;> first | rfl | (unfold addrOf; rfl) | (simp only [addrOf]; rfl)
  rw [e3] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pa, hpa, hr, hs3⟩ := runOn_evalPlace_fields hs hta hpath h5
  subst hr
  rw [hs3] at h6
  have hv : v = .ptr (⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen ∧ s2 = s := by
    cases chk with
    | false =>
      have h6' : runOn (pure (Value.ptr (⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen) :
          SemM Value) o s = (.ok v, s2) := h6
      rw [runOn_pure] at h6'
      obtain ⟨h7, h8⟩ := prod_ok_inj h6'
      exact ⟨h7.symm, h8.symm⟩
    | true =>
      have h6' : runOn (SemM.getMem >>= fun m => SemM.liftE (checkValue m
          (.ptr (⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen) td) >>=
          fun _ => pure (Value.ptr (⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen)) o s =
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
  have e4 : td = .ptr pt valid := Option.some.inj (htd'.symm.trans htd)
  subst e4
  have hbs : bs = encodePtr ⟨pa.addr + off, pa.prov⟩ := by
    simp [Spec.Ty.encode, hk, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbs
  exact ⟨pd, pa, hld, hpa, hsto, rfl⟩

/-- The pointer R's `addr` computes into an escaped local relates to L0's: `_a`'s object `e`
(`LocalRel.esc`) holds offset `sa.off + off`, its allocation is at `fp + e.off`, so `addrOf`
gives `fp + sa.off + off` with `e`'s provenance, which `ι` maps `_a`'s allocation to.

Proof: `cases hr`; `priv` contradicts `hesc` (`hpriv 0`). `esc`: `hin off hoff` gives
`escapedAt (sa.off + off) = some e`, `end_escapedAt_some` gives `e.off ≤ sa.off + off`;
`unfold OpSem.State.addrOf`, `hy`; the address: `y.addr + (sa.off + off - e.off).toNat =
pa.addr + off` by `hyaddr`, `haddr`, `hpaddr` (`omega` after `Int.toNat_of_nonneg`); the
provenance: `ProvInj ι (some a) (some e.id)` is `hι`. -/
theorem addrOf_inj {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory} {sa : LocalSlot}
    {pa : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 sa pa lv)
    (hesc : st.escapedAt sa.off ≠ none) {off : Nat} (hoff : off < sa.size) :
    ∃ p1, ∃ e : OpSem.EscapedObj, st.addrOf (sa.off + off) = .ok p1 ∧
      PtrInj ι ⟨pa.addr + off, pa.prov⟩ p1 ∧ p1.prov = some e.id ∧
      st.escapedAt (sa.off + off) = some e := by
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    exact (hesc (by simpa using hpriv 0 (by omega))).elim
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    have he := hin off hoff
    obtain ⟨-, hle, -⟩ := end_escapedAt_some he
    have hnn : ((sa.off + (off : Int) - e.off).toNat : Int) = sa.off + off - e.off :=
      Int.toNat_of_nonneg (by omega)
    refine ⟨⟨y.addr + (sa.off + (off : Int) - e.off).toNat, some e.id⟩, e, ?_, ?_, rfl, he⟩
    · simp only [OpSem.State.addrOf, he, hy, pure, Except.pure] <;> rfl
    · unfold PtrInj
      refine ⟨?_, ?_⟩
      · dsimp only
        omega
      · dsimp only
        rw [hp]
        simp only [ProvInj, hι]

/-- Two escaped objects of a pairwise disjoint list that both cover offset `o` are the same. -/
theorem escaped_eq_of_overlap {l : List OpSem.EscapedObj}
    (hl : l.Pairwise fun (e e' : OpSem.EscapedObj) =>
      e.off + (e.size : Int) ≤ e'.off ∨ e'.off + (e'.size : Int) ≤ e.off)
    {x y : OpSem.EscapedObj} (hx : x ∈ l) (hy : y ∈ l) {o : Int}
    (hox : x.off ≤ o ∧ o < x.off + x.size) (hoy : y.off ≤ o ∧ o < y.off + y.size) : x = y := by
  induction l with
  | nil => cases hx
  | cons a t ih =>
    rw [List.pairwise_cons] at hl
    obtain ⟨ha, ht⟩ := hl
    rcases List.mem_cons.mp hx with rfl | hx'
    · rcases List.mem_cons.mp hy with rfl | hy'
      · rfl
      · rcases ha y hy' with h | h <;> omega
    · rcases List.mem_cons.mp hy with rfl | hy'
      · rcases ha x hx' with h | h <;> omega
      · exact ih ht hx' hy'

/-- `addrOf_inj` at the end of `_a`'s slot (`addrOf`'s at-end case): when no escaped object
covers that offset, `_a`'s object `e` ends there (it covers the slot's last byte), it is the
only non-empty object ending there (`escaped_eq_of_overlap`, the objects being disjoint), and
`addrOf` gives its allocation's address plus `e.size`, `pa.addr + sa.size`, with `e`'s
provenance. -/
theorem addrOf_end_inj {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory} {sa : LocalSlot}
    {pa : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 sa pa lv)
    (hesc : st.escapedAt sa.off ≠ none) (hpos : 0 < sa.size)
    (hnone : st.escapedAt (sa.off + sa.size) = none)
    (hdisj : st.escaped.Pairwise fun (e e' : OpSem.EscapedObj) =>
      e.off + (e.size : Int) ≤ e'.off ∨ e'.off + (e'.size : Int) ≤ e.off) :
    ∃ p1, st.addrOf (sa.off + sa.size) = .ok p1 ∧
      PtrInj ι ⟨pa.addr + sa.size, pa.prov⟩ p1 := by
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    exact (hesc (by simpa using hpriv 0 hpos)).elim
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    have he := hin (sa.size - 1) (by omega)
    obtain ⟨hmem, hle, hlt⟩ := end_escapedAt_some he
    have hnone' := hnone
    unfold OpSem.State.escapedAt at hnone'
    have hn := List.find?_eq_none.mp hnone' e hmem
    simp only [decide_eq_true_eq] at hn
    have hn2 : ¬ (sa.off + (sa.size : Int) < e.off + e.size) := fun h => hn ⟨by omega, h⟩
    have hend : e.off + (e.size : Int) = sa.off + sa.size := by omega
    have hfind : st.escaped.find? (fun e' : OpSem.EscapedObj =>
        e'.size != 0 && e'.off + e'.size == sa.off + sa.size) = some e := by
      cases hf : st.escaped.find? (fun e' : OpSem.EscapedObj =>
          e'.size != 0 && e'.off + e'.size == sa.off + sa.size) with
      | none =>
        have h1 := List.find?_eq_none.mp hf e hmem
        have hs0 : e.size ≠ 0 := by omega
        exact (h1 (by simp [hs0, hend])).elim
      | some e' =>
        have h1 := List.find?_some hf
        have h2 := List.mem_of_find?_eq_some hf
        simp only [Bool.and_eq_true, bne_iff_ne, ne_eq, beq_iff_eq] at h1
        obtain ⟨h1a, h1b⟩ := h1
        have hee : e' = e := escaped_eq_of_overlap hdisj h2 hmem
          (o := sa.off + sa.size - 1) ⟨by omega, by omega⟩ ⟨by omega, by omega⟩
        rw [hee]
    refine ⟨⟨y.addr + e.size, some e.id⟩, ?_, ?_⟩
    · first
        | (simp only [OpSem.State.addrOf, hnone, hfind, hy, pure, Except.pure]; done)
        | (simp only [OpSem.State.addrOf, hnone, hfind, hy, pure, Except.pure] <;> rfl)
        | (unfold OpSem.State.addrOf; rw [hnone]; simp only [hfind, hy]; rfl)
    · unfold PtrInj
      refine ⟨?_, ?_⟩
      · dsimp only
        omega
      · dsimp only
        rw [hp]
        simp only [ProvInj, hι]

/-- The same address bytes with related provenances. -/
theorem ptrBytes_inj {ι : Inj} (L : List UInt8) {pr0 pr1 : Option AllocId}
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

/-- Related pointers have related encodings.

Proof: `Ryo.Spec.Theorems.encodePtr_eq` on both sides (`ptrBytes` of the address bytes with
the provenance at each position); the address bytes are equal (`h.1`); per byte `ByteInj`
with fragment `⟨q, k⟩`: by `h.2` (`ProvInj`), `ι q = some b` forces R's provenance `some b`
(`BytesInj.of_getElem`, `getElem?_ptrBytes`). -/
theorem encodePtr_inj {ι : Inj} {p0 p1 : ThinPointer} (h : PtrInj ι p0 p1) :
    BytesInj ι (encodePtr p0) (encodePtr p1) := by
  rw [Ryo.Spec.Theorems.encodePtr_eq, Ryo.Spec.Theorems.encodePtr_eq, ← h.1]
  exact ptrBytes_inj _ h.2

/-- A byte of a pointer's encoding carries the pointer's provenance. -/
theorem encodePtr_prov {p : ThinPointer} {b : AbstractByte} {fr : ProvenanceFrag}
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

/-- `ref`'s lift (see the module comment): from `FnRelX` at the fold `s0` of the pending scopes
`pre`, the own `Escape` `sc` runs, then `addr`.

Proof: `cases hlow`; `addrInsnOk_spec hi` for the view; `assign_ref_inv` for L0 (`hbody`).
`hown` is `[.escS sa.off sa.size ta.align.exp]` against `[sc]` (`ownSpec`, `hrv`, `hsa`,
`hta`). `scope_escape_rel` (with `hlo` at `_a`: `placeLocals`' base) gives `ι'`, `s0'` and
`_a`'s object; `hrel'.rel.opnd` gives `_a`'s `LocalRel ι' … true` (`esc`), `addrOf_inj` R's
pointer `p1`. `FnRel.write_dst` at `s0'` (`_d` private or escaped, `hdi.2`) gives the
`writeFrame` of `encodePtr p1`, `MemInj`, `_d`'s relation and the other locals' (with
`encodePtr_inj`, length 8 = `sd.size`); `opSem_addr_fwd` gives the instruction,
`step_of_view_scopes` with `hsc` = `pre ++ [sc]` (`scopes_append_ok hpre`, then `sc`) the step.
`FnRel.after` assembles `FnRel` at `ι'` with `Hidden` by `Hidden.store_hidden` (the stored
fragments' provenance is `pa.prov`, mapped by `ι'`); `FnRelX`'s other fields carry over from
`scope_escape_rel`'s (the frame write keeps the objects, `writeFrame_allocsKept` the
allocations' addresses, liveness and sizes); `ProvBounded.store` with `LocalRel.prov_lt`. -/
theorem lift_ref {Γ : StmtCtx} {c : R.Code} {s1 s0 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerRef Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i)
    {pre : List R.Scope} {sc : R.Scope} (hsc : c.scopesAt s1.pc = pre ++ [sc])
    (hpre : pre.foldlM R.applyScope s1 = .ok s0)
    (hown : specsOk (ownSpec Γ (.assign ⟨d, []⟩ rv)) [sc] = true)
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i)
    (hrel : FnRelX Γ ι live f s.mem s0) (hpb : ProvBounded s.mem)
    (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    ∃ s0', R.applyScope s0 sc = .ok s0' ∧ LiftOutX Γ c ch ι live' f s s' s1 s0' := by
  cases hlow with
  | @ref d a rv projs ta ty off pt valid sd sa i hrv hne htaΓ hpath htdΓ hk hsd hsa hsize hend
      hoff hesc hai =>
    obtain ⟨v, ps, r, hv, hh, ho, hops, hctl⟩ := addrInsnOk_spec hai
    rw [hmode, hρ] at hv
    have hta : f.body.locals[a]? = some ta := by rw [← hbody]; exact htaΓ
    have htd : f.body.locals[d]? = some (.ptr pt valid) := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, pa, hpd, hpa, hsto, hstk⟩ := assign_ref_inv hs hrv hta hpath htd hk h
    -- the own `Escape`
    have hsc1 : ScopeSpec.ok (.escS sa.off sa.size ta.align.exp) sc = true := by
      simp only [ownSpec, hrv, hsa, htaΓ, hpath, Option.isSome_some, ↓reduceIte, specsOk, Bool.and_true] at hown
      exact hown
    have hla : live a = true := hlo a (by
      cases rv <;> simp only [refPlace?, reduceCtorEq, Option.some.injEq] at hrv <;>
        (subst hrv; simp [rvalueLocals, placeLocals]))
    have hpos : 0 < sa.size := by omega
    obtain ⟨ι', s0', hsc', hle, hext, hpc, hfp, hargs, hX', e, hine⟩ :=
      scope_escape_rel hrel hpa hsa hta hla hpos hesc hsc1 hfresh
    have hnal : ∀ l, l ∉ f.aliased := by
      intro l
      rw [hrel.rel.unaliased]
      simp
    -- `_a`'s pointer in R
    obtain ⟨slot, hslot, hra⟩ := hX'.rel.frame.locals a pa hpa (hnal a)
    have hss : slot = sa := Option.some.inj (hslot.symm.trans hsa)
    subst hss
    have hesc0 : s0'.st.escapedAt slot.off ≠ none := by
      have h0 : s0'.st.escapedAt slot.off = some e := by simpa using hine 0 hpos
      rw [h0]
      simp
    -- `addr`'s pointer: inside `_a`'s object, or at its end (`addrOf_end_inj`: no escaped
    -- object covers the offset after the slot, by `hend` and `FnRel.esc`)
    have hnone : off = slot.size → s0'.st.escapedAt (slot.off + slot.size) = none := by
      intro he0
      cases hq : s0'.st.escapedAt (slot.off + slot.size) with
      | none => rfl
      | some q =>
        have h1 := hX'.rel.esc _ q hq
        rw [hend he0] at h1
        cases h1
    obtain ⟨p1, haddr1, hpinj⟩ : ∃ p1, s0'.st.addrOf (slot.off + off) = .ok p1 ∧
        PtrInj ι' ⟨pa.addr + off, pa.prov⟩ p1 := by
      rcases Nat.lt_or_ge off slot.size with hlt | hge
      · obtain ⟨p1, -, h1, h2, -⟩ := addrOf_inj hra hesc0 hlt
        exact ⟨p1, h1, h2⟩
      · have he0 : off = slot.size := by omega
        subst he0
        exact addrOf_end_inj hra hesc0 hpos (hnone rfl) hX'.disj
    obtain ⟨a0, hpa0, hlt0⟩ := LocalRel.prov_lt hra
    have hιa : ι' a0 ≠ none := by
      cases hra with
      | priv a1 x1 hp1 hι1 _ _ _ _ _ hpv1 _ =>
        exfalso
        have h1 := hpv1 0 hpos
        rw [hine 0 hpos] at h1
        cases h1
      | esc a1 x1 e2 y2 hp1 hι1 =>
        have e3 : a1 = a0 := Option.some.inj (hp1.symm.trans hpa0)
        subst e3
        rw [hι1]
        simp
    -- `_d`'s slot, private or escaped
    have hpos8 : 0 < sd.size := by omega
    obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hX'.rel.write_dst hdi.2 hpd hsd hpos8
      (encodePtr_inj hpinj) (by rw [Ryo.Spec.Theorems.encodePtr_length, hsize.1]) hsto
    have hf1 := offOk_spec hoff.1
    have hf3 := offOk_spec hoff.2.2
    have hop := opSem_addr_fwd (ch := ch) hh ho ⟨hf1.1, hf1.2, hf3.1, hf3.2⟩ haddr1 hwr
    have hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0' := by
      rw [hsc, scopes_append_ok hpre, List.foldlM_cons, hsc']
      all_goals rfl
    have hstep := step_of_view_scopes hi hfold hpe hpl hv hctl (by rw [hops]; exact hop)
    -- the relation
    have hbprov : ∀ b ∈ encodePtr ⟨pa.addr + off, pa.prov⟩, ∀ fr, b.provFrag = some fr →
        fr.prov = a0 := by
      intro b hb fr hf
      have h1 := encodePtr_prov hb hf
      exact Option.some.inj (h1.symm.trans hpa0)
    have hhid : Hidden s'.mem (PrivAlloc ι' f) := hX'.rel.hidden.store_hidden hsto
      (fun b hb fr hf hpr => by
        obtain ⟨-, -, -, -, hn⟩ := hpr
        rw [hbprov b hb fr hf] at hn
        exact hιa hn)
    have hescR := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    have hak : AllocsKept s0'.st.mem st'.mem := writeFrame_allocsKept hwr
    have hfn := hX'.rel.after hpd hsd hmi hrd hoth hhid hescR hlive' (pc' := s0'.pc + 1)
    have hagree := Ryo.Spec.Theorems.Memory.store_agree hsto
    have hbd : BytesBounded s.mem.allocs.size (encodePtr ⟨pa.addr + off, pa.prov⟩) := by
      intro b hb fr hf
      rw [hbprov b hb fr hf]
      exact hlt0
    refine ⟨s0', hsc', ι', st', hle, fun q hq => hext q (by
        rw [hpa0]
        intro he'
        have h1 : a0 = q := Option.some.inj he'
        subst h1
        exact absurd hq (Nat.not_le.mpr hlt0)), hstep, hstk, ?_, hpb.store hsto hbd,
      Nat.le_of_eq (store_size hsto).symm,
      (hdi.mono hle).store_mapped hsto (fun b hb fr hf => by rw [hbprov b hb fr hf]; exact hιa)⟩
    -- `FnRelX`'s other fields: R's objects are unchanged and its allocations keep their
    -- address, liveness and size (a frame write), L0's keep their liveness (one store)
    refine ⟨hfn, fun e' he' => ?_, ?_, fun q b x e' hq hx hl' he' hid => ?_,
      fun j y hy hl' => ?_, hX'.aligned, fun e' he' => ?_, fun e' he' y hy => ?_⟩
    · have he2 : e' ∈ s0'.st.escaped := by
        have h2 : e' ∈ st'.escaped := he'
        rw [hescR] at h2
        exact h2
      exact hX'.objs e' he2
    · show List.Pairwise _ st'.escaped
      rw [hescR]
      exact hX'.disj
    · have he2 : e' ∈ s0'.st.escaped := by
        have h2 : e' ∈ st'.escaped := he'
        rw [hescR] at h2
        exact h2
      rcases hagree.get? q with ⟨-, h2⟩ | ⟨x0, x1, h1, h2, -, -, hl0, -, -⟩
      · rw [h2] at hx; cases hx
      · rw [h2] at hx
        cases hx
        exact hX'.owned q b x0 e' hq h1 (hl0.trans hl') he2 hid
    · obtain ⟨y0, hy0, hadd, hlv, hsz⟩ := hak.2 j y hy
      rcases hX'.free j y0 hy0 (by rw [← hlv]; exact hl') with ⟨e2, he2, h1, h2, h3⟩ | hfr
      · refine .inl ⟨e2, ?_, h1, ?_, ?_⟩
        · show e2 ∈ st'.escaped
          rw [hescR]
          exact he2
        · rw [hadd]; exact h2
        · rw [hsz]; exact h3
      · refine .inr fun l sl hsl => ?_
        rw [hadd, hsz]
        exact hfr l sl hsl
    · have he2 : e' ∈ s0'.st.escaped := by
        have h2 : e' ∈ st'.escaped := he'
        rw [hescR] at h2
        exact h2
      show e'.id < st'.mem.allocs.size
      rw [hak.1]
      exact hX'.idLt e' he2
    · have he2 : e' ∈ s0'.st.escaped := by
        have h2 : e' ∈ st'.escaped := he'
        rw [hescR] at h2
        exact h2
      obtain ⟨y0, hy0, hadd, -, -⟩ := hak.2 e'.id y hy
      show (y.addr : Int) = s0'.fp + e'.off
      rw [hadd]
      exact hX'.addrAt e' he2 y0 hy0


/-! ### One statement with scopes -/

/-- The one-instruction families (`family_shape`'s) under pending scopes: the family's lift on
`c.dropScopes` from the fold `s0`, through `stmtOutX_family`; the view and the empty pending list
after the statement are `LowersFnX.stmtsX`'s, the range's end `BlockOk.stmt`'s (`hnext`). -/
theorem stmt_simX_family {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hf : LowerCopy Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerIntCast Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerUnop Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerField Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerCmp Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerWide Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerBinX Γ.toStmtCtx st (rangeInsns c.d r) ∨
      LowerOffset Γ.toStmtCtx st (rangeInsns c.d r) ∨ LowerOvf Γ.toStmtCtx st (rangeInsns c.d r) ∨
      (LowerDeref Γ.toStmtCtx st (rangeInsns c.d r) ∧ ∃ d rv, st = .assign ⟨d, []⟩ rv))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨d, rv, i, rfl, hR⟩ := family_shape hf
  rw [hR] at hf
  have hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [] := by
    rcases hf with h | h | h | h | h | h | h | h | h | ⟨h, -⟩ <;> cases h <;>
      first | rfl | (simp_all [ownSpec, refPlace?])
  obtain ⟨hi0, he⟩ := rangeInsns_single h2 hR
  have hlt : r.1 < r.2 := by omega
  obtain ⟨hc, hc0, hfold, hpcs, hpc0, -⟩ := family_setup hfn M hst hr h2 hR hown
  have hsx := hfn.stmtsX f.bb bd blk M.hbd M.hblk
  obtain ⟨v, hv, hctl⟩ := hsx.next f.stmt r hr r.1 (Nat.le_refl _) hlt i hi0
  rw [← hmode, ← hρ] at hv
  have hpend0 := hsx.pend0 f.stmt r hr hlt
  have hpcNext : r.2 = pcAt blk (f.stmt + 1) := hnext.trans (nextStart_eq blk f.stmt)
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hbody : Γ.toStmtCtx.body = f.body := M.body.symm
  have hmode' : Γ.toStmtCtx.mode = c.dropScopes.mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = c.dropScopes.ρ := hρ.symm
  have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
  have hsc0 : c.dropScopes.scopesAt s0.pc = [] := dropScopes_scopesAt c _
  have hpe0 : c.dropScopes.mode.pe = false := hpe
  have hpl0 : PlainView c.dropScopes.mode c.dropScopes.ρ i := hpl
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  have hl : LiftOut Γ.toStmtCtx c.dropScopes ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f
      s s1x s0 := by
    rcases hf with hf | hf | hf | hf | hf | hf | hf | hf | hf | hf
    · exact lift_copy M.stack hbody hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_intCast M.stack hbody hwf hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb M.dinv.2 hl2
        hl1 hev
    · exact lift_unop M.stack hbody hwf hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb M.dinv.2 hl2 hl1
        hev
    · exact lift_field M.stack hbody hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_cmp M.stack hbody hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_wide M.stack hbody hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb M.dinv.2 hl2 hl1 hev
    · exact lift_binX M.stack hbody hwf hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb hl2 hl1 hev
    · exact lift_offset M.stack hbody hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb hl2 hl1 hev
    · exact lift_ovf M.stack hbody hwf hmode' hρ' hf hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb hl2 hl1 hev
    · exact lift_derefLoad M.stack hbody hmode' hρ' hf.1 hc0 hsc0 hpe0 hpl0 M.rel.rel M.pb
        M.dinv.1 M.dinv.2 hl2 hl1 hev
  exact stmtOutX_family hfn hmode M hst hr h2 hR hown hpl hv hctl hpcNext hpend0 hl

/-- The `ref` statement under pending scopes: the scopes at `pc` are the pending ones (folded to
`s0`, `MatchAtX.pend`) then the statement's own `Escape` `sc` (`ScopesOk.stmt`,
`specsOk_append`); `lift_ref`. -/
theorem stmt_simX_ref {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hlow : LowerRef Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have hlow0 := hlow
  obtain ⟨d, rv, i, rfl, hR⟩ : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ rangeInsns c.d r = [i] := by
    generalize rangeInsns c.d r = is at hlow0 ⊢
    cases hlow0
    exact ⟨_, _, _, rfl, rfl⟩
  rw [hR] at hlow
  obtain ⟨sa, ta, hown1⟩ : ∃ (sa : LocalSlot) (ta : Spec.Ty),
      ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [.escS sa.off sa.size ta.align.exp] := by
    have hl2 := hlow
    cases hl2 with
    | @ref _ _ _ _ ta _ _ _ _ _ sa _ hrv _ hta hpath _ _ _ hsa _ _ _ _ _ =>
      exact ⟨sa, ta, by simp only [ownSpec, hrv, hsa, hta, hpath, Option.isSome_some, ↓reduceIte]⟩
  obtain ⟨hi0, he⟩ := rangeInsns_single h2 hR
  have hlt : r.1 < r.2 := by omega
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hi0
  have hsc := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmt f.stmt _ r hst hr hlt
  have hX : scopesAtD c.d r.1 = c.scopesAt s1.pc := by rw [hpc0]; rfl
  rw [hown1, hX] at hsc
  obtain ⟨hsplit, -, hown_ok⟩ := specsOk_append hsc
  have hlen1 := specsOk_length _ _ hown_ok
  obtain ⟨sc, hsc1⟩ : ∃ sc, (c.scopesAt s1.pc).drop (pendSpecs Γ.toStmtCtx bd blk f.stmt).length
      = [sc] := by
    rcases hd : (c.scopesAt s1.pc).drop (pendSpecs Γ.toStmtCtx bd blk f.stmt).length with
      _ | ⟨x, _ | ⟨y, ys⟩⟩
    · rw [hd] at hlen1; simp at hlen1
    · exact ⟨x, rfl⟩
    · rw [hd] at hlen1; simp at hlen1
  have hscs : c.scopesAt s1.pc =
      (c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk f.stmt).length ++ [sc] :=
    hsplit.trans (by rw [hsc1])
  have hown' : specsOk (ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv)) [sc] = true := by
    rw [hown1, ← hsc1]
    exact hown_ok
  have hsx := hfn.stmtsX f.bb bd blk M.hbd M.hblk
  have hpend0 := hsx.pend0 f.stmt r hr hlt
  have hpcNext : r.2 = pcAt blk (f.stmt + 1) := hnext.trans (nextStart_eq blk f.stmt)
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  obtain ⟨s0', hA, hXl⟩ := lift_ref M.stack M.body.symm hmode.symm hρ.symm hlow hc hscs M.pend
    hown' hpe hpl M.rel M.pb M.fresh M.dinv hl2 hl1 hev
  refine stmtOutX_of_liftX M.stack hfn.storage M.hbd hst M.sl M.fresh ?_ hpend0 hXl
  rw [(applyScope_pc_fp hA).1, scopes_pc M.pend, hpc0, ← hpcNext, he]

/-- A one-instruction assignment without own scopes, from a lift on `c.dropScopes` at the fold
`s0` (`hlift`, given the scope-free code's facts there). -/
theorem stmt_simX_single {Γ : TermCtx} {c : R.Code} {ι : Inj} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {d : Local} {rv : Rvalue} (hst : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv)) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt) {i : R.Insn} (hR : rangeInsns c.d r = [i])
    (hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [])
    (hlift : c.dropScopes.d.insns[s0.pc]? = some i → c.dropScopes.scopesAt s0.pc = [] →
      c.dropScopes.mode.pe = false → PlainView c.dropScopes.mode c.dropScopes.ρ i →
      LiftOut Γ.toStmtCtx c.dropScopes ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f s
        s1x s0) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  obtain ⟨hi0, he⟩ := rangeInsns_single h2 hR
  have hlt : r.1 < r.2 := by omega
  obtain ⟨hc, hc0, -, -, -, -⟩ := family_setup hfn M hst hr h2 hR hown
  have hsx := hfn.stmtsX f.bb bd blk M.hbd M.hblk
  obtain ⟨v, hv, hctl⟩ := hsx.next f.stmt r hr r.1 (Nat.le_refl _) hlt i hi0
  rw [← hmode, ← hρ] at hv
  have hpend0 := hsx.pend0 f.stmt r hr hlt
  have hpcNext : r.2 = pcAt blk (f.stmt + 1) := hnext.trans (nextStart_eq blk f.stmt)
  have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  exact stmtOutX_family hfn hmode M hst hr h2 hR hown hpl hv hctl hpcNext hpend0
    (hlift hc0 (dropScopes_scopesAt c _) hpe hpl)

/-- A copy of a whole local has no own scope (`useSpec`). -/
theorem ownSpec_use_local {Γ : StmtCtx} {d a : Local} {o : Operand} (h : o.local? = some a) :
    ownSpec Γ (.assign ⟨d, []⟩ (.use o)) = [] := by
  simp only [ownSpec, refPlace?]
  simp [useSpec, h]

/-- `LowerStmt`'s one-instruction assignments under pending scopes (as `stmt_sim_base`'s, on
`c.dropScopes`). The storage statements are not covered here (`none` of the result: the
caller handles them). -/
theorem stmt_simX_baseAssign {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt) {is : List R.Insn} (hR : rangeInsns c.d r = is)
    (hlow : LowerStmt Γ.toStmtCtx st is) (hnl : ∀ l, st ≠ .storageLive l)
    (hnd : ∀ l, st ≠ .storageDead l)
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have hbody : Γ.toStmtCtx.body = f.body := M.body.symm
  have hmode' : Γ.toStmtCtx.mode = c.dropScopes.mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = c.dropScopes.ρ := hρ.symm
  have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
  have sgl := fun {d rv i} (hst' : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv))
    (hR' : rangeInsns c.d r = [i]) (hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = []) =>
    stmt_simX_single (ch := ch) (s1x := s1x) hfn hmode hρ M hst' hr h2 hnext hR' hown
  cases hlow with
  | binop hm ha hb htd hta htb hsd hsa hsb hsize hoff hpriv hi =>
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    refine sgl hst hR rfl (fun hc0 hsc0 hpe0 hpl0 => ?_)
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_binop (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, _, _, _, _, _, _, _, hm, ha, hb, htd, hta, htb, hsd, hsa, hsb, hsize, hoff, hpriv, hi⟩
      hc0 hsc0 hpe0 hpl0 M.rel.rel
      (fun x hx => hl2 x (by
        rcases hx with hx | hx
        · exact List.mem_append_left _ (operand_local_mem hx)
        · exact List.mem_append_right _ (operand_local_mem hx)))
      hl1 hev
    have hev' := hev
    rw [eval_binop_norm ha hb] at hev'
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := binop_mem M.stack hm (by rw [← hbody]; exact htd)
      (by rw [← hbody]; exact hta) (by rw [← hbody]; exact htb) hev'
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | binopImm hm ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    refine sgl hst hR rfl (fun hc0 hsc0 hpe0 hpl0 => ?_)
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_binopImm (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, _, _, _, hm, ha, htd, hta, hsd, hsa, hsize, hoff, hpriv, hi⟩
      hc0 hsc0 hpe0 hpl0 M.rel.rel
      (fun x hx => hl2 x (List.mem_append_left _ (operand_local_mem hx))) hl1 hev
    have hev' := hev
    rw [eval_binopImm_norm ha] at hev'
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := binImm_mem M.stack hm (by rw [← hbody]; exact htd)
      (by rw [← hbody]; exact hta) hev'
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | copyInt ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    refine sgl hst hR (ownSpec_use_local ha) (fun hc0 hsc0 hpe0 hpl0 => ?_)
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_copyInt (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, _, _, _, _, ha, htd, hta, hsd, hsa, hsize, hoff, hpriv, hi⟩
      hc0 hsc0 hpe0 hpl0 M.rel.rel (fun x hx => hl2 x (operand_local_mem hx)) hl1 hev
    have hev' := hev
    rw [eval_use_norm ha] at hev'
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := use_mem M.stack (by rw [← hbody]; exact htd)
      (fun _ _ hr => by
        obtain ⟨_, _, _, _, _, _, _, he⟩ := runOn_evalOperand_copy M.stack hr
        exact he) hev'
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | constInt htd hsd hsize hoff hpriv hi =>
    obtain ⟨hl1, -⟩ := assign_live hfn.live M.hbd hst
    refine sgl hst hR rfl (fun hc0 hsc0 hpe0 hpl0 => ?_)
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_constInt (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, htd, hsd, hsize, hoff, hpriv, hi⟩ hc0 hsc0 hpe0 hpl0 M.rel.rel hl1 hev
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := use_mem M.stack (by rw [← hbody]; exact htd)
      (fun _ _ hr => (runOn_evalOperand_const_scalar_int hr).2) hev
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | copyBool ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact sgl hst hR (ownSpec_use_local ha) (fun hc0 hsc0 hpe0 hpl0 =>
      lift_copyBool M.stack hbody hmode' hρ' ha htd hta hsd hsa hsize hoff hpriv hi hc0 hsc0
        hpe0 hpl0 M.rel.rel M.pb (hl2 _ (operand_local_mem ha)) hl1 hev)
  | copyPtr hk ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact sgl hst hR (ownSpec_use_local ha) (fun hc0 hsc0 hpe0 hpl0 =>
      lift_copyPtr M.stack hbody hmode' hρ' hk ha htd hta hsd hsa hsize hoff hpriv hi hc0 hsc0
        hpe0 hpl0 M.rel.rel M.pb (hl2 _ (operand_local_mem ha)) hl1 hev)
  | constBool htd hsd hsize hoff hpriv hi =>
    obtain ⟨hl1, -⟩ := assign_live hfn.live M.hbd hst
    exact sgl hst hR rfl (fun hc0 hsc0 hpe0 hpl0 =>
      lift_constBool M.stack hbody hmode' hρ' htd hsd hsize hoff hpriv hi hc0 hsc0 hpe0 hpl0
        M.rel.rel M.pb hl1 hev)
  | storageLive l => exact absurd rfl (hnl l)
  | storageDead l => exact absurd rfl (hnd l)

/-! ### `StorageDead` under pending scopes -/

/-- After an empty range the next statement's pending `End`s are this one's plus its own. -/
theorem pendSpecs_succ {Γ : StmtCtx} {bd : BlockData} {blk : BlockCert} {i : Nat}
    {st : Statement} (heq : startAt blk (i + 1) = startAt blk i)
    (hst : bd.stmts[i]? = some st) :
    pendSpecs Γ bd blk (i + 1) = pendSpecs Γ bd blk i ++ endSpec Γ st := by
  unfold pendSpecs
  rw [heq, List.range_succ, List.flatMap_append]
  simp [hst]

/-- L0's `StorageDead _l`: the frame drops `_l`, the memory only kills `_l`'s allocation. -/
theorem storageDead_L0 {Γ : TermCtx} {ι : Inj} {live : Local → Bool} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} {s0 : R.RState} {l : Local}
    (hs : s.stack = f :: rest) (hrel : FnRelX Γ.toStmtCtx ι live f s.mem s0)
    (h : runOn (evalStatement (.storageDead l)) o s = (.ok (), s')) :
    ∃ f' : Spec.Frame, s'.stack = f' :: rest ∧ f'.body = f.body ∧ f'.bb = f.bb ∧
      f'.stmt = f.stmt ∧ f'.pendingUnwind = f.pendingUnwind ∧ f'.cont = f.cont ∧
      (∀ l' p', f'.locals[l']? = some (some p') → f.locals[l']? = some (some p') ∧ l' ≠ l) ∧
      (∀ l' p', f.locals[l']? = some (some p') → l' ≠ l → f'.locals[l']? = some (some p')) ∧
      (ProvBounded s.mem → ProvBounded s'.mem) ∧ s'.mem.allocs.size = s.mem.allocs.size ∧
      MemKept s.mem s'.mem ∧
      (∀ q x', s'.mem.get? q = some x' → ∃ x, s.mem.get? q = some x ∧
        (x'.live = true → x.live = true) ∧ x'.addr = x.addr ∧ x'.data.size = x.data.size) ∧
      (∀ p, f.locals[l]? = some (some p) → ∀ q x', p.prov = some q →
        s'.mem.get? q = some x' → x'.live = false) := by
  have h' : runOn (storageDead l) o s = (.ok (), s') := h
  by_cases hl : ∃ p, f.locals[l]? = some (some p)
  · obtain ⟨p, hp⟩ := hl
    obtain ⟨ty, m', -, hd, hs'⟩ :=
      storageDead_live hs hp (by rw [hrel.rel.unaliased]; rfl) h'
    have hmem' : s'.mem = m' := by rw [hs']
    obtain ⟨sl1, -, hr1⟩ := hrel.rel.frame.locals l p hp (by rw [hrel.rel.unaliased]; simp)
    obtain ⟨q0, x0, hq0, -, -⟩ := hr1.alloc_live
    obtain ⟨a0, ha0, hm0⟩ := dealloc_ok_at hd hq0
    refine ⟨{ f with locals := f.locals.set! l none, aliased := f.aliased.erase l },
      by rw [hs'], rfl, rfl, rfl, rfl, rfl, fun l' p' hp' => ?_, fun l' p' hp' hne => ?_,
      fun hpb => ?_, ?_, ?_, fun q x' hx' => ?_, fun p' hp' q x' hq hx' => ?_⟩
    · by_cases e : l' = l
      · have hp'' : (f.locals.set! l none)[l']? = some (some p') := hp'
        rw [e] at hp''
        exact absurd (getElem?_set!_self hp'') (by simp)
      · have hp'' : (f.locals.set! l none)[l']? = some (some p') := hp'
        rw [getElem?_set!_ne e] at hp''
        exact ⟨hp'', e⟩
    · show (f.locals.set! l none)[l']? = some (some p')
      rw [getElem?_set!_ne hne]
      exact hp'
    · rw [hmem']; exact hpb.dealloc hd
    · rw [hmem']; exact dealloc_size hd
    · rw [hmem']; exact memKept_dealloc hd
    · rw [hmem', hm0, end_get?_set _ ha0] at hx'
      by_cases hq : q = q0
      · rw [if_pos hq] at hx'
        cases hx'
        exact ⟨a0, by rw [hq]; exact ha0, fun h3 => by simp at h3, rfl, rfl⟩
      · rw [if_neg hq] at hx'
        exact ⟨x', hx', id, rfl, rfl⟩
    · have e1 : p' = p := Option.some.inj (Option.some.inj (hp'.symm.trans hp))
      subst e1
      rw [hmem'] at hx'
      exact dealloc_dead hd hq hx'
  · have hl' : ∀ p, f.locals[l]? ≠ some (some p) := fun p hp => hl ⟨p, hp⟩
    rw [storageDead_dead hs hl'] at h'
    obtain ⟨-, hss⟩ := prod_ok_inj h'
    subst hss
    refine ⟨f, hs, rfl, rfl, rfl, rfl, rfl, fun l' p' hp' => ⟨hp', ?_⟩, fun l' p' hp' _ => hp',
      id, rfl, ⟨fun a x' hx' => ⟨x', hx', rfl, id, rfl⟩, fun _ hA => hA⟩,
      fun q x' hx' => ⟨x', hx', id, rfl, rfl⟩, fun p hp => absurd hp (hl' p)⟩
    intro e
    subst e
    exact hl' p' hp'

/-- `FnRelX` after a `StorageDead _l` without an `End`: R unchanged; no object is `_l`'s
(`hnoobj`). -/
theorem dead_fnRelX {Γ : TermCtx} {ι : Inj} {live live' : Local → Bool} {f f' : Spec.Frame}
    {m0 m0' : Memory} {s0 : R.RState} {l : Local}
    (hrel : FnRelX Γ.toStmtCtx ι live f m0 s0) (hfn : FnRel Γ.toStmtCtx ι live' f' m0' s0)
    (hloc : ∀ l' p', f'.locals[l']? = some (some p') → f.locals[l']? = some (some p') ∧ l' ≠ l)
    (hloc' : ∀ l' p', f.locals[l']? = some (some p') → l' ≠ l → f'.locals[l']? = some (some p'))
    (hbody' : f'.body = f.body)
    (hkeep : ∀ q x', m0'.get? q = some x' → ∃ x, m0.get? q = some x ∧
      (x'.live = true → x.live = true) ∧ x'.addr = x.addr ∧ x'.data.size = x.data.size)
    (hdead : ∀ p, f.locals[l]? = some (some p) → ∀ q x', p.prov = some q →
      m0'.get? q = some x' → x'.live = false)
    (hnoobj : ∀ e ∈ s0.st.escaped, ∀ (l2 : Local) (p2 : ThinPointer) (sl2 : LocalSlot),
      f.locals[l2]? = some (some p2) → Γ.slots[l2]? = some sl2 → e.off = sl2.off →
      0 < sl2.size → l2 ≠ l) :
    FnRelX Γ.toStmtCtx ι live' f' m0' s0 := by
  refine ⟨hfn, fun e he => ?_, hrel.disj, fun q b x e hq hx hl he hid => ?_, hrel.free,
    fun l' p' ty hp' hty => ?_, hrel.idLt, hrel.addrAt⟩
  · obtain ⟨l2, p2, sl2, hp2, hsl2, ho2, hs2, hpos⟩ := hrel.objs e he
    exact ⟨l2, p2, sl2, hloc' l2 p2 hp2 (hnoobj e he l2 p2 sl2 hp2 hsl2 ho2 hpos), hsl2, ho2,
      hs2, hpos⟩
  · obtain ⟨x0, hx0, hl0, -, -⟩ := hkeep q x hx
    obtain ⟨l3, p3, sl3, hp3, hpa3, hsl3, ho3, hs3⟩ := hrel.owned q b x0 e hq hx0 (hl0 hl) he hid
    have hl3 : l3 ≠ l := by
      intro e1
      subst e1
      have := hdead p3 hp3 q x hpa3 hx
      rw [hl] at this
      cases this
    exact ⟨l3, p3, sl3, hloc' l3 p3 hp3 hl3, hpa3, hsl3, ho3, hs3⟩
  · rw [hbody'] at hty
    exact hrel.aligned l' p' ty (hloc l' p' hp').1 hty

/-- Sub-lemma 4 (`StorageDead`): R doesn't step; with an `End` (`endSpec`), it is the next
pending scope (`LowersFnX.stmtsX.endAt`), folded by `scope_end_rel`; without one, no object
is `_l`'s (an object in its slot would make `Γ.escaped` true there, `privOk`). -/
theorem stmt_simX_storageDead {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {l : Local} (hst : bd.stmts[f.stmt]? = some (.storageDead l)) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt) (hR0 : rangeInsns c.d r = [])
    (hev : runOn (evalStatement (.storageDead l)) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have he : r.2 = r.1 := rangeInsns_nil h1 h2 hR0
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hstart : startAt blk f.stmt = r.1 := pcAt_some hr
  have hstart1 : startAt blk (f.stmt + 1) = startAt blk f.stmt := by
    show pcAt blk (f.stmt + 1) = _
    rw [← nextStart_eq, ← hnext, he, hstart]
  have hps := pendSpecs_succ (Γ := Γ.toStmtCtx) hstart1 hst
  have hpcN : s1.pc = pcAt blk (f.stmt + 1) := by
    rw [hpc0, ← he, hnext, nextStart_eq]
  obtain ⟨f', hstk, hb', hbb', hst', hpu', hcont', hloc, hloc', hpbI, hsz, hmk, hkeep, hdead⟩ :=
    storageDead_L0 M.stack M.rel hev
  have hdeadL := hfn.deadAfter f.bb bd f.stmt l M.hbd hst
  have hlive' : ∀ l', (computeLive Γ.body).get f.bb (f.stmt + 1) l' = true →
      (computeLive Γ.body).get f.bb f.stmt l' = true := by
    intro l' hl'
    by_cases e : l' = l
    · subst e; rw [hdeadL] at hl'; cases hl'
    · exact (hfn.live.stmt f.bb bd M.hbd f.stmt _ hst).1 l' hl'
        (by intro h; exact e (Option.some.inj h).symm)
  have hslN : ∀ l' p', f'.locals[l']? = some (some p') →
      (computeStorage Γ.body).get f.bb (f.stmt + 1) l' = true := by
    intro l' p' hp'
    obtain ⟨hp0, hne⟩ := hloc l' p' hp'
    exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l' (M.sl l' p' hp0)
      (by intro h; exact hne (Option.some.inj h).symm)
  have hfrN : ∀ a, s1x.mem.allocs.size ≤ a → ι a = none :=
    fun a ha => M.fresh a (by rw [← hsz]; exact ha)
  -- without an `End`
  have caseA : endSpec Γ.toStmtCtx (.storageDead l) = [] → StmtOutX Γ c ch ι f rest bd blk s s1x
      s1 := by
    intro hE
    obtain ⟨f'', hstk'', -, -, -, hfn'⟩ := lift_storageDead M.stack M.rel.rel hlive' hev
    have e2 : f' = f'' := (List.cons.inj (hstk.symm.trans hstk'')).1
    subst e2
    have hnoobj : ∀ e ∈ s0.st.escaped, ∀ (l2 : Local) (p2 : ThinPointer) (sl2 : LocalSlot),
        f.locals[l2]? = some (some p2) → Γ.slots[l2]? = some sl2 → e.off = sl2.off →
        0 < sl2.size → l2 ≠ l := by
      intro e hem l2 p2 sl2 hp2 hsl2 ho2 hpos e3
      subst e3
      have hpv : privOk Γ.toStmtCtx sl2.off sl2.size = true := by
        cases hpv : privOk Γ.toStmtCtx sl2.off sl2.size with
        | true => rfl
        | false => simp [endSpec, hsl2, hpv] at hE
      have h0 : Γ.toStmtCtx.escaped sl2.off = false := by simpa using privOk_spec hpv 0 hpos
      cases hf : s0.st.escapedAt sl2.off with
      | none =>
        unfold OpSem.State.escapedAt at hf
        have := List.find?_eq_none.1 hf e hem
        simp only [decide_eq_true_eq, not_and] at this
        obtain ⟨l4, p4, sl4, -, -, -, hs4, hp4⟩ := M.rel.objs e hem
        have h5 := this (by omega)
        omega
      | some e' =>
        have := M.rel.rel.esc sl2.off e' hf
        rw [h0] at this
        cases this
    refine ⟨ι, s1, s0, f', fun _ _ h => h, .refl _, hstk, hb', hbb', hst', hpu', hcont', hpcN,
      ?_, dead_fnRelX M.rel hfn' hloc hloc' hb' hkeep hdead hnoobj, hslN, hpbI M.pb, hfrN,
      M.dinv.of_memKept hmk⟩
    rw [hps, hE, List.append_nil]
    exact M.pend
  cases hsl : Γ.slots[l]? with
  | none => exact caseA (by simp [endSpec, hsl])
  | some sl =>
    cases hpv : privOk Γ.toStmtCtx sl.off sl.size with
    | true => exact caseA (by simp [endSpec, hsl, hpv])
    | false =>
      have hE : endSpec Γ.toStmtCtx (.storageDead l) = [.endS sl.off sl.size] := by
        simp [endSpec, hsl, hpv]
      obtain ⟨sc, hsc, hok⟩ :=
        (hfn.stmtsX f.bb bd blk M.hbd M.hblk).endAt f.stmt l sl hst hsl hpv
      have hmay := (hfn.scopes f.bb bd blk M.hbd M.hblk).endLive f.stmt l sl hst hsl hpv
      obtain ⟨s0', f'', hA, hstk'', -, -, -, hX⟩ :=
        scope_end_rel (live' := (computeLive Γ.body).get f.bb (f.stmt + 1)) M.stack M.body
          M.hbd hst hsl hok hmay hfn.share.2 M.sl M.rel hlive' hev
      have e2 : f' = f'' := (List.cons.inj (hstk.symm.trans hstk'')).1
      subst e2
      have hn : (c.scopesAt s1.pc)[(pendSpecs Γ.toStmtCtx bd blk f.stmt).length]? = some sc := by
        have hX0 : c.scopesAt s1.pc = scopesAtD c.d (startAt blk f.stmt) := by
          (rw [hpc0, hstart]) <;> rfl
        rw [hX0]
        exact hsc
      refine ⟨ι, s1, s0', f', fun _ _ h => h, .refl _, hstk, hb', hbb', hst', hpu', hcont',
        hpcN, ?_, hX, hslN, hpbI M.pb, hfrN, M.dinv.of_memKept hmk⟩
      rw [hps, hE, List.length_append, List.length_singleton]
      exact fold_take_succ M.pend hn hA

end Ryo.Proofs.Lower
