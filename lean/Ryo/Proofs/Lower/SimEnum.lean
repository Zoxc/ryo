/-
Ryo.Proofs.Lower.SimEnum — the lifts of the enum rules (`Check/Lower/Enum.lean`, M5b).

- Reads (`LowerEnumRead`, one instruction, the common `LiftOut` shape):
  - `discrDirect`: L0 loads the `tag.tag.size` tag bytes at `_e`'s pointer plus the tag offset
    (`readDiscriminant`, the pointer `wrappingOffset`: `wrappingOffset_eq` unwraps it inside
    the allocation), decodes bits `u`, finds a variant `var` with `tag.tag.toBits var.discr = u`
    and stores `var.discr` brought into `discrTy` then `t` (`discrDirect_mem`). R reads the same
    sub-range of `_e`'s slot (`readLocal_sub_inj`) and moves or converts it; `cvt_bytes` /
    `cast_mov_bytes` (SimIntCast) give `t.toBits (t.bringInBounds (tag.tag.ofBits u))`, which
    the rule's `discrAgree` makes L0's (`tagRead_val`); `sim_tagRead` is the step.
  - `discrSingle`: L0 stores `singleDiscr` without reading memory (`discrSingle_mem`), R's `imm`
    the same bits, as `lift_constInt`.
  - `downcast`: as `lift_field`, the place evaluated by `runOn_evalPlace_downcast` (a downcast
    step keeps the pointer and moves to the variant's fields).
- Tag writes (`LowerSetDiscr`, not assignments): `tag` stores the tag bits into a sub-range of
  `_e` in both L0 (`setTag_mem`) and R (`imm`), which keeps `_e` related
  (`writeLocal_sub_priv`, `_e` live since the statement reads it: `setDiscr_live`); `implicit`
  changes nothing in L0 (`setImplicit_mem`) and R runs nothing (`lift_setImplicit`,
  `liftOutN_zero`). `stmtOut_of_liftN_kill` is `stmtOut_of_liftN` for any statement that kills
  no storage.
- Aggregates (`LowerEnumAgg`, several instructions): L0's encoding of `.variant v (.tuple vals)`
  is the variant's field tuple's encoding with the tag written over it last, i.e. `AggMem` of
  the variant's fields followed by the tag field `tagField` adds (`enumAgg_mem`); SimAgg's
  `lift_aggMem` then applies unchanged.

`stmt_sim_enum` is the family's case of `stmt_sim` (FnStep.lean). Nothing beyond `LowersFn`'s
facts is needed: the rules carry `0 < t.size` and the offsets' ranges themselves.

L0's inversions go through `discr_inv`/`discr_assign_inv` (the `discriminant` rvalue) and
`setDiscr_inv` (`writeDiscriminant`), with `readDiscriminant`/`writeDiscriminant` computed by the
`exE_*` steps; `start_le` and `wrappingOffset_eq` unwrap the tag's address.
-/
import Ryo.Proofs.Lower.SimField
import Ryo.Proofs.Lower.SimIntCast
import Ryo.Proofs.Lower.SimAgg
import Ryo.Check.Lower.Enum

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### `Except` steps (all by `rfl`) -/

theorem exE_ok_bind {ε α β : Type} (a : α) (g : α → Except ε β) :
    (Except.ok a >>= g) = g a := rfl

theorem exE_error_bind {ε α β : Type} (x : ε) (g : α → Except ε β) :
    (Except.error x >>= g) = Except.error x := rfl

theorem exE_pure {ε α : Type} (a : α) : (pure a : Except ε α) = Except.ok a := rfl

theorem exE_throw {ε α : Type} (x : ε) : (throw x : Except ε α) = Except.error x := rfl

theorem exE_throwUb {α : Type} (msg : String) :
    (throwUb msg : Except Outcome α) = Except.error (.ub msg) := rfl

theorem exE_throwIllFormed {α : Type} (msg : String) :
    (throwIllFormed msg : Except Outcome α) = Except.error (.illFormed msg) := rfl

theorem exE_ensure_true (msg : String) : (ensureUb true msg : Except Outcome Unit) = pure () :=
  rfl

theorem exE_ensure_false (msg : String) :
    (ensureUb false msg : Except Outcome Unit) = throwUb msg := rfl

/-! ### Pointers -/

/-- `wrappingOffset` by `off < 2^64` landing at or above `p` does not wrap: the result is below
`2^64`, so `p.addr` is, and a wrapped sum would land below `p.addr` (`omega` on the `%`). -/
theorem wrappingOffset_eq {p : ThinPointer} {off : Nat} (hoff : off < 2 ^ 64)
    (hle : p.addr ≤ (p.wrappingOffset off).addr) :
    p.wrappingOffset off = ⟨p.addr + off, p.prov⟩ := by
  have hL : ((Target.ADDR_LIMIT : Nat) : Int) = 18446744073709551616 := by
    first | rfl | decide | simp [Target.ADDR_LIMIT]
  have hoff' : off < 18446744073709551616 := hoff
  have hle' : p.addr ≤
      (((p.addr : Int) + (off : Int)) % ((Target.ADDR_LIMIT : Nat) : Int)).toNat := hle
  rw [hL] at hle'
  have hk : (((p.addr : Int) + (off : Int)) % ((Target.ADDR_LIMIT : Nat) : Int)).toNat =
      p.addr + off := by
    rw [hL]; omega
  first
    | (unfold ThinPointer.wrappingOffset; rw [hk])
    | (simp only [ThinPointer.wrappingOffset, hk])
    | (show ThinPointer.mk _ p.prov = _; rw [hk])

/-- A related local's pointer is its allocation's start, so a pointer of the same provenance
whose allocation starts at or below it (`load_eq_ok_pos`, `Memory.store_eq_ok`) is at or above
it. -/
theorem start_le {m : Memory} {ι : Inj} {fp : Nat} {st : OpSem.State} {slot : LocalSlot}
    {p q : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m slot p lv) (hq : q.prov = p.prov)
    {id : AllocId} (hid : id < m.allocs.size) (hpid : q.prov = some id)
    (hle : m.allocs[id].addr ≤ q.addr) : p.addr ≤ q.addr := by
  have key : ∀ a x, p.prov = some a → m.get? a = some x → p.addr = x.addr → p.addr ≤ q.addr := by
    intro a x hpa hx hpx
    have e1 : id = a := Option.some.inj (hpid.symm.trans (hq.trans hpa))
    rw [← e1] at hx
    have h1 : m.allocs[id]? = some x := hx
    rw [Array.getElem?_eq_getElem hid] at h1
    rw [hpx, ← Option.some.inj h1]
    exact hle
  cases hr with
  | priv a x hp _ hx _ _ hpaddr => exact key a x hp hx hpaddr
  | esc a x _ _ hp _ hx _ _ hpaddr => exact key a x hp hx hpaddr

/-! ### Discriminant reads: L0 -/

/-- The `discriminant` rvalue of a whole enum local at an integer destination, run to success:
`readDiscriminant` at the local's pointer gives a variant index, whose discriminant is brought
into `discrTy` then `t`; the state is unchanged. -/
theorem discr_inv {o : Spec.Oracle} {s s2 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {e : Local}
    {vs : List Spec.Variant} {discrTy : IntType} {repr : EnumRepr} {esz : Nat} {eal : Align}
    {t : IntType} {vd : ValidRange} {w : Value}
    (hte : f.body.locals[e]? = some (.enum vs discrTy repr esz eal))
    (h : runOn (evalRvalue (.discriminant ⟨e, []⟩) (.int t vd)) o s = (.ok w, s2)) :
    ∃ pe idx, f.locals[e]? = some (some pe) ∧
      readDiscriminant s.mem pe (.enum vs discrTy repr esz eal) = .ok idx ∧
      w = .int (t.bringInBounds (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))) ∧
      s2 = s := by
  have e1 : evalRvalue (.discriminant ⟨e, []⟩) (.int t vd) = (evalPlace ⟨e, []⟩ >>= fun x =>
      match x with
      | (pl, ty) =>
        match ty with
        | .enum vs discrTy .. => do
          if !pl.aligned then
            throwUb "getting the discriminant of a place based on a misaligned pointer"
          let idx ← SemM.liftE (readDiscriminant (← SemM.getMem) pl.ptr.thin ty)
          let d := (vs[idx]?.map (·.discr)).getD 0
          pure (Value.int (t.bringInBounds (discrTy.bringInBounds d)))
        | _ => pure (.int 0)) := by
    first | rfl | (unfold evalRvalue; rfl) | (simp only [evalRvalue]; rfl)
  rw [e1] at h
  obtain ⟨x, s3, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pe, ty, hpe, hty, rfl, rfl⟩ := runOn_localPlace_ok hs h1
  obtain rfl : ty = .enum vs discrTy repr esz eal := Option.some.inj (hty.symm.trans hte)
  simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte, pure_bind] at h2
  obtain ⟨m, s4, h3, h4⟩ := runOn_bind_ok h2
  rw [runOn_getMem0] at h3
  obtain ⟨rfl, rfl⟩ := prod_ok_inj h3
  obtain ⟨idx, s5, h5, h6⟩ := runOn_bind_ok h4
  obtain ⟨hrd, rfl⟩ := runOn_liftE_ok h5
  obtain ⟨hw, rfl⟩ := runOn_pure_inv h6
  exact ⟨pe, idx, hpe, hrd, hw, rfl⟩

/-- An assignment of a whole enum local's discriminant to a whole integer local, run to
success: `discr_inv`'s read, then the store of its value at `_d`'s type. -/
theorem discr_assign_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d e : Local}
    {vs : List Spec.Variant} {discrTy : IntType} {repr : EnumRepr} {esz : Nat} {eal : Align}
    {t : IntType} {vd : ValidRange}
    (hte : f.body.locals[e]? = some (.enum vs discrTy repr esz eal))
    (htd : f.body.locals[d]? = some (.int t vd))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩))) o s = (.ok (), s')) :
    ∃ pd pe idx, f.locals[d]? = some (some pd) ∧ f.locals[e]? = some (some pe) ∧
      readDiscriminant s.mem pe (.enum vs discrTy repr esz eal) = .ok idx ∧
      s.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
        (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))))) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  have e0 : evalStatement (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.discriminant ⟨e, []⟩) ty' >>= fun v =>
          placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e0] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hpd, htd', rfl, hs1⟩ := runOn_localPlace_ok hs h1
  rw [hs1] at h2
  obtain rfl : td = .int t vd := Option.some.inj (htd'.symm.trans htd)
  have h2' : runOn (evalRvalue (.discriminant ⟨e, []⟩) (.int t vd) >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v (.int t vd)) o s = (.ok (), s') := h2
  obtain ⟨w, s2, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨pe, idx, hpe, hrd, rfl, rfl⟩ := discr_inv hs hte h3
  obtain ⟨mem', hst, rfl⟩ := runOn_placeStore_ok h4
  exact ⟨pd, pe, idx, hpd, hpe, hrd, typedStore_int hst, rfl⟩

/-- `_d = discriminant(_e)` at a direct tag, run to success.

Proof: as `assign_use_inv`: `evalStatement (.assign ..)` is `evalPlace ⟨d, []⟩ >>= fun (pl, ty)
=> evalRvalue rv ty >>= placeStore pl · ty` (`rfl`); `runOn_evalPlace_nil`,
`runOn_localPlace_ok hs` for `_d` (`pd`, its type is `.int t vd` by `htd`) and inside
`evalRvalue (.discriminant ⟨e, []⟩)` for `_e` (`pe`, the place aligned, its type by `hte`).
`readDiscriminant` (unfold; `liftE`, `runOn_liftE_ok`): the `.multiple tag` branch's
`signedDereferenceable` succeeds (`tag.offset ≥ 0`), then `mem.load (pe.wrappingOffset
tag.offset) tag.tag.size .one = .ok bs`, `decodeBits bs = some u`, and `tagToVariant`'s
`.direct` branch (`henc`) returns `i` from `vs.zipIdx.find?`: `List.find?_some` gives
`tag.tag.toBits var.discr == u` and `List.mem_zipIdx`-style lemmas `vs[i]? = some var` (so
`var ∈ vs` and the stored discriminant is `var.discr`); the inhabitedness `ensureUb` passes.
The value stored is `.int (t.bringInBounds (discrTy.bringInBounds var.discr))`;
`runOn_placeStore_ok` and `typedStore_int` give the store, the stack is unchanged. -/
theorem discrDirect_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d e : Local}
    {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {esz : Nat} {eal : Align}
    {t : IntType} {vd : ValidRange}
    (hte : f.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
    (henc : tag.encoding = .direct) (htd : f.body.locals[d]? = some (.int t vd))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩))) o s = (.ok (), s')) :
    ∃ (pd pe : ThinPointer) (bs : List AbstractByte) (var : Spec.Variant),
      f.locals[d]? = some (some pd) ∧
      f.locals[e]? = some (some pe) ∧
      s.mem.load (pe.wrappingOffset tag.offset) tag.tag.size .one = .ok bs ∧
      decodeBits bs = some (tag.tag.toBits var.discr) ∧ var ∈ vs ∧
      s.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
        (discrTy.bringInBounds var.discr)))) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  obtain ⟨pd, pe, idx0, hpd, hpe, hrd, hsto, hstk⟩ := discr_assign_inv hs hte htd h
  cases hsd : s.mem.signedDereferenceable pe tag.offset with
  | error x =>
    exfalso
    simp only [readDiscriminant, hsd, pure_bind, exE_ok_bind, exE_error_bind, exE_pure, exE_throw,
        exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false, Except.ok.injEq,
        reduceCtorEq] at hrd
  | ok u0 =>
    cases hld : s.mem.load (pe.wrappingOffset tag.offset) tag.tag.size .one with
    | error x =>
      exfalso
      simp only [readDiscriminant, hsd, hld, pure_bind, exE_ok_bind, exE_error_bind, exE_pure,
          exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
          Except.ok.injEq, reduceCtorEq] at hrd
    | ok bs =>
      cases hdb : decodeBits bs with
      | none =>
        exfalso
        simp only [readDiscriminant, hsd, hld, hdb, pure_bind, exE_ok_bind, exE_error_bind,
            exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
            Except.ok.injEq, reduceCtorEq] at hrd
      | some u =>
        cases htv : tagToVariant vs discrTy tag u with
        | error msg =>
          exfalso
          simp only [readDiscriminant, hsd, hld, hdb, htv, pure_bind, exE_ok_bind, exE_error_bind,
              exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true,
              exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
        | ok i =>
          have hi : i = idx0 := by
            cases hv : variantInhabited vs i
            · simp only [readDiscriminant, hsd, hld, hdb, htv, hv, pure_bind, exE_ok_bind,
                exE_error_bind, exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed,
                exE_ensure_true, exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
            · simp only [readDiscriminant, hsd, hld, hdb, htv, hv, pure_bind, exE_ok_bind,
                exE_error_bind, exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed,
                exE_ensure_true, exE_ensure_false, Except.ok.injEq, reduceCtorEq] at hrd
              first | exact hrd | exact hrd.symm
          subst hi
          obtain ⟨var, hvar, hbits⟩ : ∃ var, vs[i]? = some var ∧ tag.tag.toBits var.discr = u := by
            unfold tagToVariant at htv
            simp only [henc] at htv
            split at htv
            · cases htv
            · split at htv
              next v0 i0 hf =>
                cases htv
                have hp := List.find?_some hf
                have hm := List.mem_of_find?_eq_some hf
                rw [List.mem_zipIdx_iff_getElem?] at hm
                exact ⟨v0, hm, by simpa using hp⟩
              · cases htv
          simp only [hvar, Option.map_some, Option.getD_some] at hsto
          exact ⟨pd, pe, bs, var, hpd, hpe, hld, by rw [hdb, hbits], List.mem_of_getElem? hvar,
            hsto, hstk⟩

/-- `_d = discriminant(_e)` of a `.single idx` enum, run to success: no memory read, the store
of `singleDiscr`.

Proof: as `discrDirect_mem` up to `readDiscriminant`, whose `.single i` branch is `pure i` and
the inhabitedness check; the value is `.int (t.bringInBounds (singleDiscr vs discrTy idx))`
(unfold `singleDiscr`), stored by `runOn_placeStore_ok`, `typedStore_int`. -/
theorem discrSingle_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d e : Local}
    {vs : List Spec.Variant} {discrTy : IntType} {idx : Nat} {esz : Nat} {eal : Align}
    {t : IntType} {vd : ValidRange}
    (hte : f.body.locals[e]? = some (.enum vs discrTy (.single idx) esz eal))
    (htd : f.body.locals[d]? = some (.int t vd))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.discriminant ⟨e, []⟩))) o s = (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧
      s.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
        (singleDiscr vs discrTy idx)))) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  obtain ⟨pd, pe, idx0, hpd, -, hrd, hsto, hstk⟩ := discr_assign_inv hs hte htd h
  have hidx : idx0 = idx := by
    cases hv : variantInhabited vs idx
    · simp only [readDiscriminant, hv, pure_bind, exE_ok_bind, exE_error_bind, exE_pure, exE_throw,
        exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false, Except.ok.injEq,
        reduceCtorEq] at hrd
    · simp only [readDiscriminant, hv, pure_bind, exE_ok_bind, exE_error_bind, exE_pure, exE_throw,
        exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false, Except.ok.injEq,
        reduceCtorEq] at hrd
      first | exact hrd.symm | exact hrd
  subst hidx
  exact ⟨pd, hpd, hsto, hstk⟩

/-! ### Discriminant reads: the bytes and R -/

/-- R's cast of the tag of `dv` is L0's discriminant when `discrAgree` holds at `dv`. -/
theorem tagRead_val {tt t discrTy : IntType} {dv : Int} {u : Nat}
    (hag : t.toBits (tt.ofBits (tt.toBits dv)) = t.toBits (discrTy.bringInBounds dv))
    (hu : tt.toBits dv = u) :
    t.toBits (t.bringInBounds (tt.ofBits u)) =
      t.toBits (t.bringInBounds (discrTy.bringInBounds dv)) := by
  subst hu
  rw [Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
      (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (tt.ofBits (tt.toBits dv))),
    Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
      (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (discrTy.bringInBounds dv))]
  exact hag

/-- The handler step of `discrDirect` from L0's memory facts (`discrDirect_mem`, the pointer
unwrapped): the `mov` or `cvt` from `se.off + toff` to `sd.off` succeeds, keeping `MemInj`,
giving `_d`'s `LocalRel` and keeping every disjoint local's.

Proof: `readLocal_sub_inj hmem hre hin hlo` gives R's bytes `ba` with `BytesInj ι bs ba`;
`decodeBits_inj` gives `decodeBits ba = some u` (`u := tt.toBits dv`), `u < 2^(8 tt.size)`
from `Ryo.Spec.Theorems.decodeBits_length` and `load_length`. Split `tagReadOk`
(`Bool.or_eq_true`): the `mov` case (`movInsnOk_spec`, `tt.size = t.size`) writes `ba`
(`writeEscaped_private'`, `opSem_mov_fwd`), and L0's bytes are `encodeBits t.size u` by
`tagRead_val` and `cast_mov_bytes`, related to `ba` by `bytesInj_encodeBits_of_decode`; the
`cvt` case (`castInsnOk_spec`) writes `intBytes t.size (cvtInt tt.size sx t.size u)`
(`opSem_cvt_fwd`), which is L0's by `cvt_bytes` and `tagRead_val` (`encodeBits_inj`). Then as
`sim_castExt`: `writeLocal_priv` for `_d`, `LocalRel.store_other` and
`LocalRel.writeFrame_apart` for the others; the view and `ctl` from the `_spec`. -/
theorem sim_tagRead {Γ : StmtCtx} {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {tt t discrTy : IntType} {dv : Int} {sd se : LocalSlot} {toff : Nat} {i : R.Insn}
    (hi : tagReadOk Γ i tt t.size sd.off (se.off + toff) = true)
    (hsd : sd.size = t.size) (hin : toff + tt.size ≤ se.size)
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ se.off + toff ∧
      se.off + toff < 2 ^ 31)
    {pd pe : ThinPointer} {bs : List AbstractByte}
    (hlo : s.mem.load ⟨pe.addr + toff, pe.prov⟩ tt.size .one = .ok bs)
    (hdec : decodeBits bs = some (tt.toBits dv))
    (hag : t.toBits (tt.ofBits (tt.toBits dv)) = t.toBits (discrTy.bringInBounds dv))
    (hsto : s.mem.store pd (encodeBits t.size (t.toBits (t.bringInBounds
      (discrTy.bringInBounds dv)))) .one = .ok s'.mem)
    (hmem : MemInj ι s.mem st.mem) (hre : LocalRel ι fp st s.mem se pe true)
    -- `_d` private
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    {ch : OpSem.Choice} :
    ∃ v st', R.view Γ.mode Γ.ρ i = some v ∧ v.ctl = some .next ∧
      opSem v.op v.ops st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  -- R's read of the tag bytes
  obtain ⟨ba, hrf, hia⟩ := readLocal_sub_inj hmem hre hin hlo
  have hda := decodeBits_inj hia hdec
  have hlenbs : bs.length = tt.size := load_length hlo
  have hlenb : ba.length = tt.size := (BytesInj.length hia).symm.trans hlenbs
  have hu : tt.toBits dv < 2 ^ (8 * tt.size) := by
    have h0 := Ryo.Spec.Theorems.decodeBits_length hdec
    rw [hlenbs] at h0
    exact h0
  have hlenL : (encodeBits t.size (t.toBits (t.bringInBounds
      (discrTy.bringInBounds dv)))).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  have hval := tagRead_val hag rfl
  simp only [tagReadOk, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] at hi
  rcases hi with ⟨hw, hm⟩ | hc
  · -- `mov`: R copies the tag bytes
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hm
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    have hlb : ba.length = t.size := hlenb.trans hw
    have hpw : ∀ k < ba.length, st.escapedAt (sd.off + k) = none := by
      intro k hk
      rw [hlb, ← hsd] at hk
      exact hprivd k hk
    obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off ba = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hrf' : st.readFrame (se.off + toff) t.size = .ok ba := by rw [← hw]; exact hrf
    have hop := opSem_mov_fwd (ch := ch) hh hty' ho hfits hrf' hlb hwr
    have hL : encodeBits t.size (t.toBits (t.bringInBounds (discrTy.bringInBounds dv))) =
        encodeBits t.size (tt.toBits dv) := by
      rw [← hval, cast_mov_bytes tt t hw]
    have hbs : BytesInj ι (encodeBits t.size (t.toBits (t.bringInBounds
        (discrTy.bringInBounds dv)))) ba := by
      rw [hL]; exact bytesInj_encodeBits_of_decode hda hlb
    obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
      hprivd hbs hlenL hsto hwr
    refine ⟨v, st', hv, hctl, by rw [hops]; exact hop, hmi, hrd, ?_⟩
    intro slot p lv hr hne hap
    have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
    exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlb, ← hsd]; exact hap)
  · -- `cvt`: R converts the tag
    obtain ⟨v, tx, ty, r, sx, sy, hv, hh, htx, hty, hsx, ho, hops, hctl⟩ := castInsnOk_spec hc
    have hva : asNat ba = .ok (tt.toBits dv) := by unfold asNat; rw [hda]; rfl
    have hlenw : (intBytes t.size (cvtInt tt.size sx t.size (tt.toBits dv))).length = t.size :=
      Ryo.Spec.Theorems.encodeBits_length _ _
    have hpw : ∀ k < (intBytes t.size (cvtInt tt.size sx t.size (tt.toBits dv))).length,
        st.escapedAt (sd.off + k) = none := by
      intro k hk
      rw [hlenw, ← hsd] at hk
      exact hprivd k hk
    obtain ⟨st', hwr⟩ : ∃ st',
        st.writeFrame sd.off (intBytes t.size (cvtInt tt.size sx t.size (tt.toBits dv))) =
          .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hop := opSem_cvt_fwd (ch := ch) hh htx hty ho hfits hrf hva hwr
    have hwr' := hwr
    rw [cvt_bytes tt t sx hu hsx, hval] at hwr'
    have hbs := encodeBits_inj ι t.size (t.toBits (t.bringInBounds (discrTy.bringInBounds dv)))
    obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
      hprivd hbs hlenL hsto hwr'
    refine ⟨v, st', hv, hctl, by rw [hops]; exact hop, hmi, hrd, ?_⟩
    intro slot p lv hr hne hap
    have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
    exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlenw, ← hsd]; exact hap)

/-! ### Downcast reads -/

/-- The projections' fold over field and downcast projections `downcastPath` covers
(`runOn_foldlM_fields` with a downcast case).

Proof: copy `runOn_foldlM_fields`'s induction. The `.field` case is unchanged
(`simp only [downcastPath] at hp`, `runOn_projectPlace_field`). Add `case downcast v`:
`cases t`; for `.enum vs dt rp sz al`, `simp only [downcastPath] at hp`, `split at hp` on
`vs[v]?` (`next var hvar`); `List.foldlM_cons`, `runOn_bind_ok`, `simp only [hF] at h1`;
`projectPlace ⟨q.widen, true⟩ (.enum vs dt rp sz al) (.downcast v) = pure (⟨q.widen, true⟩,
var.fields)` (`first | rfl | simp only [projectPlace, hvar] | simp [projectPlace, hvar]`), so
`runOn_pure`, `prod_ok_inj` give the accumulator and the state; then `ih hp h2 hF`. The other
types and projections: `simp [downcastPath] at hp`. -/
theorem runOn_foldlM_downcast {o : Spec.Oracle}
    {F : Spec.Place × Spec.Ty → ProjElem → SemM (Spec.Place × Spec.Ty)} (projs : List ProjElem) :
    ∀ {q : ThinPointer} {t ty : Spec.Ty} {off : Nat} {s s1 : Spec.State}
      {r : Spec.Place × Spec.Ty},
    downcastPath t projs = some (off, ty) →
    runOn (projs.foldlM F (⟨q.widen, true⟩, t)) o s = (.ok r, s1) →
    (∀ x e, F x e = projectPlace x.1 x.2 e) →
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, true⟩, ty) ∧ s1 = s := by
  induction projs with
  | nil =>
    intro q t ty off s s1 r hp h _
    simp only [downcastPath, Option.some.injEq, Prod.mk.injEq] at hp
    obtain ⟨rfl, rfl⟩ := hp
    rw [List.foldlM_nil, runOn_pure] at h
    obtain ⟨hr, hs⟩ := prod_ok_inj h
    exact ⟨by rw [← hr, Nat.add_zero], hs.symm⟩
  | cons e ps ih =>
    intro q t ty off s s1 r hp h hF
    cases e
    case field fi ann =>
      simp only [downcastPath] at hp
      split at hp
      next o1 fty hfo =>
        split at hp
        next o2 t2 hps =>
          simp only [Option.some.injEq, Prod.mk.injEq] at hp
          obtain ⟨rfl, rfl⟩ := hp
          rw [List.foldlM_cons] at h
          obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
          simp only [hF] at h1
          obtain ⟨rfl, hs2⟩ := runOn_projectPlace_field hfo h1
          obtain ⟨hr, hs1⟩ := ih hps h2 hF
          exact ⟨by rw [hr, Nat.add_assoc], by rw [hs1, hs2]⟩
        · cases hp
      · cases hp
    case downcast v =>
      cases t
      case enum vs dt rp sz al =>
        simp only [downcastPath] at hp
        split at hp
        next var hvar =>
          rw [List.foldlM_cons] at h
          obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
          simp only [hF] at h1
          have e : projectPlace ⟨q.widen, true⟩ (.enum vs dt rp sz al) (.downcast v) =
              pure (⟨q.widen, true⟩, var.fields) := by
            first
              | (simp only [projectPlace, hvar]; done)
              | (simp only [projectPlace, hvar]; rfl)
              | simp [projectPlace, hvar]
          rw [e, runOn_pure] at h1
          obtain ⟨rfl, rfl⟩ := prod_ok_inj h1
          exact ih hp h2 hF
        · cases hp
      all_goals first | (simp [downcastPath] at hp; done) | cases hp
    all_goals first | (simp [downcastPath] at hp; done) | cases hp

/-- `runOn_evalPlace_fields` for `downcastPath` (the same proof). -/
theorem runOn_evalPlace_downcast {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {a : Local} {projs : List ProjElem}
    {ta ty : Spec.Ty} {off : Nat} {r : Spec.Place × Spec.Ty}
    (hta : f.body.locals[a]? = some ta) (hpath : downcastPath ta projs = some (off, ty))
    (h : runOn (evalPlace ⟨a, projs⟩) o s = (.ok r, s1)) :
    ∃ pa, f.locals[a]? = some (some pa) ∧
      r = (⟨(⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen, true⟩, ty) ∧ s1 = s := by
  have e : evalPlace ⟨a, projs⟩ = (localPlace a >>= fun init =>
      projs.foldlM (fun (pl, ty) pe => projectPlace pl ty pe) init) := rfl
  rw [e] at h
  obtain ⟨init, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pa, ta', hpa, hta', hinit, hs2⟩ := runOn_localPlace_ok hs h1
  subst hinit
  have e2 : ta' = ta := Option.some.inj (hta'.symm.trans hta)
  subst e2
  rw [hs2] at h2
  obtain ⟨hr, hs1⟩ := runOn_foldlM_downcast projs hpath h2 (fun ⟨_, _⟩ _ => rfl)
  exact ⟨pa, hpa, hr, hs1⟩

/-- `field_mem` for `downcastPath` (the same proof). -/
theorem downcast_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {projs : List ProjElem}
    {ta ty : Spec.Ty} {off n : Nat}
    (hta : f.body.locals[a]? = some ta) (hpath : downcastPath ta projs = some (off, ty))
    (htd : f.body.locals[d]? = some ty) (hn : ty.size? = some n)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.copy ⟨a, projs⟩)))) o s =
      (.ok (), s')) :
    ∃ pd pa bs0 v bsd, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load ⟨pa.addr + off, pa.prov⟩ n .one = .ok bs0 ∧ ty.decode bs0 = some v ∧
      ty.encode v = some bsd ∧ s.mem.store pd bsd .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  obtain ⟨pd, td, rv, s1, hpd, htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  have e : evalOperand (.copy ⟨a, projs⟩) = (evalPlace ⟨a, projs⟩ >>= fun x => match x with
      | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := rfl
  rw [e] at hev
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨pa, hpa, rfl, hs2⟩ := runOn_evalPlace_downcast hs hta hpath h1
  have h2' : runOn (placeLoad ⟨(⟨pa.addr + off, pa.prov⟩ : ThinPointer).widen, true⟩ ty >>=
      fun v => pure (v, ty)) o s2 = (.ok rv, s1) := h2
  rw [hs2] at h2'
  obtain ⟨v, s3, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨hv, hs3⟩ := runOn_placeLoad_ok h3
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h4
  have hs1' : s1 = s := hs1.symm.trans hs3
  have e4 : td = ty := Option.some.inj (htd'.symm.trans htd)
  subst e4
  obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv hn hv
  rw [← hrv, hs1'] at hst
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  exact ⟨pd, pa, bs0, v, bsd, hpd, hpa, hlo, hd, hen, hsto, by rw [hs1']⟩

/-! ### The reads' lift -/

/-- A read rule's statement and range: an assignment to a whole local, one instruction. -/
theorem enumRead_shape {Γ : StmtCtx} {st : Statement} {is : List R.Insn}
    (h : LowerEnumRead Γ st is) : ∃ d rv i, st = .assign ⟨d, []⟩ rv ∧ is = [i] := by
  cases h <;> exact ⟨_, _, _, rfl, rfl⟩

/-- The reads' lift.

`downcast`: `lift_field`'s proof with `downcast_mem`.

`discrDirect`: `rw [hbody] at hte htd`; `discrDirect_mem hs hte henc htd h` (`pd`,
`pe`, the load at `pe.wrappingOffset tag.offset`, `var ∈ vs`, the store, the stack); `live e`
from `hlo e (by simp [rvalueLocals, placeLocals])`, `hrel.opnd hpe hse` its `LocalRel` (`priv`:
the allocation's address is `pe.addr`; an `esc` one is excluded by `hrel.esc` only if needed —
`readLocal_sub_inj` takes either), and the load's `load_eq_ok_pos` gives `pe.addr ≤` the
wrapped address (same provenance, the allocation's start), so `wrappingOffset_eq` (offset
`< 2^31` from `offOk_spec`) rewrites the load to `⟨pe.addr + tag.offset, pe.prov⟩`;
`hrel.priv_dst hpd hsd (by omega) hpriv` for `_d`; `sim_tagRead` with `dv := var.discr` and
`discrAgree_spec hagree var hvar`. The memory invariants as `lift_constInt`/`lift_intCast`
(`encodeBits_noprov`, `memInv_store`, `hrel.hidden.store_noprov`); the step `step_of_view` (the
view from `sim_tagRead` is the one `hmode`/`hρ` rewrite), the relation `hrel.after`
(`opSem_out` for the escapes).

`discrSingle`: as `lift_constInt` with `discrSingle_mem` in place of the constant's
store: `immInsnOk_spec`, `immOpsOk_spec`, `operands2`, `fits_last`, `opSem_imm_fwd`; R writes
`intBytes t.size x` with `x ≡ t.toBits (singleDiscr ..)` mod `2^(8 t.size)`, which is L0's
`encodeBits t.size (t.toBits (t.bringInBounds (singleDiscr ..)))` by `encodeBits_mod` and
`IntType.toBits_eq_of_emod`/`bringInBounds_emod` (as in `tagRead_val`); `writeLocal_priv`. -/
theorem lift_enumRead {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerEnumRead Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @discrDirect d e vs discrTy tag esz eal t vd sd se i hte henc htd hagree hsd hse hsize hoff
      hpriv hii =>
    rw [hbody] at hte htd
    obtain ⟨pd, pe, bs, var, hpd, hpe0, hld, hdec, hvar, hsto, hstk⟩ :=
      discrDirect_mem hs hte henc htd h
    have hle : live e = true := hlo e (by simp [rvalueLocals, placeLocals])
    have hre := hrel.opnd hpe0 hse hle
    -- the tag's address does not wrap
    have hn0 : tag.tag.size ≠ 0 := Nat.pos_iff_ne_zero.mp hsize.2.2.1
    obtain ⟨id, hid, hpid, -, hlo', -⟩ := load_eq_ok_pos hn0 hld
    have hle2 : pe.addr ≤ (pe.wrappingOffset tag.offset).addr :=
      start_le (q := pe.wrappingOffset tag.offset) hre rfl hid hpid hlo'
    have hoffNat : tag.offset < 2 ^ 64 := by
      have h1 := offOk_spec hoff.2.1
      have h2 := offOk_spec hoff.2.2
      try dsimp only [Size, Offset] at *
      omega
    rw [wrappingOffset_eq hoffNat hle2] at hld
    -- `_d` private
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hsize.2.1
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨v, st', hv, hctl, hop, hmi, hrd, hoth⟩ := sim_tagRead (ch := ch) (dv := var.discr)
      hii hsize.1 hsize.2.2.2 ⟨hf1.1, hf1.2, hf3.1, hf3.2⟩ hld hdec
      (discrAgree_spec hagree var hvar) hsto hrel.frame.mem hre ad xd hp hι hxd hl haddr hpaddr
      hsz hpv
    rw [hmode, hρ] at hv
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle'⟩ := memInv_store hpb hsto (encodeBits_noprov _ _)
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl hop, hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto (encodeBits_noprov _ _))
        hesc hlive', hpb', hle'⟩
  | @discrSingle d e vs discrTy idx esz eal t vd sd i hte htd hsd hsize hoff hpriv hii =>
    obtain ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hii
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands2 hn hk
    have hops'' : v.ops = [.slot sd.off, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
    rw [hbody] at hte htd
    obtain ⟨pd, hpd, hsto, hstk⟩ := discrSingle_mem hs hte htd h
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hsize.2
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff
    -- R writes L0's bytes
    have hib : intBytes t.size x =
        encodeBits t.size (t.toBits (t.bringInBounds (singleDiscr vs discrTy idx))) := by
      show encodeBits t.size x = _
      rw [← encodeBits_mod t.size x, hx, encodeBits_mod,
        Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
          (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (singleDiscr vs discrTy idx))]
    have hlen : (intBytes t.size x).length = t.size := by
      rw [hib]; exact Ryo.Spec.Theorems.encodeBits_length _ _
    have hpw : ∀ j < (intBytes t.size x).length, s1.st.escapedAt (sd.off + j) = none := by
      intro j hj
      rw [hlen, ← hsize.1] at hj
      exact hpv j hj
    obtain ⟨st', hwr⟩ : ∃ st', s1.st.writeFrame sd.off (intBytes t.size x) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hop := opSem_imm_fwd (ch := ch) hh hty' ho hf1 hfk hwr
    have hbs : BytesInj ι (encodeBits t.size (t.toBits (t.bringInBounds
        (singleDiscr vs discrTy idx)))) (intBytes t.size x) := by
      rw [hib]; exact encodeBits_inj ι _ _
    have hlen0 : (encodeBits t.size (t.toBits (t.bringInBounds
        (singleDiscr vs discrTy idx)))).length = sd.size := by
      rw [Ryo.Spec.Theorems.encodeBits_length, hsize.1]
    obtain ⟨hmi, hrd⟩ := writeLocal_priv hrel.frame.mem ad xd hp hι hxd hl haddr hpaddr hsz
      hpv hbs hlen0 hsto hwr
    have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
        p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι s1.fp st' s'.mem slot p lv := by
      intro slot p lv hr hne hap
      have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
      exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlen, ← hsize.1]; exact hap)
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle'⟩ := memInv_store hpb hsto (encodeBits_noprov _ _)
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto (encodeBits_noprov _ _))
        hesc hlive', hpb', hle'⟩
  | @downcast d a oa projs ta ty off n sd sa i ha hta hpath htd hn hpos hwf hsd hsa hsize hoff
      hpriv hmi =>
    rw [eval_use_place_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at hta htd
    obtain ⟨pd, pa, bs0, w, bsd, hpd, hpa, hlo0, hd, hen, hsto, hstk⟩ :=
      downcast_mem hs hta hpath htd hn h
    have hla : live _ = true := hlo _ (operandPlace?_mem ha)
    have hra := hrel.opnd hpa hsa hla
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos' hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi', hrd, hoth⟩ := sim_copyField (ch := ch) hwf hn hsize.1 hsize.2 hlo0
      hd hen hsto hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩
    have hsub := bytesLeDefined_prov (reenc_wf hwf hn (load_length hlo0) hd hen)
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
      hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

/-! ### Tag writes -/

/-- `SetDiscriminant` of a whole local, run to success: `writeDiscriminant` at the local's
pointer and type gives the new memory. -/
theorem setDiscr_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {e : Local} {v : Nat} {ty : Spec.Ty}
    (hte : f.body.locals[e]? = some ty)
    (h : runOn (evalStatement (.setDiscriminant ⟨e, []⟩ v)) o s = (.ok (), s')) :
    ∃ pe m, f.locals[e]? = some (some pe) ∧ writeDiscriminant s.mem pe ty v = .ok m ∧
      s' = { s with mem := m } := by
  have e0 : evalStatement (.setDiscriminant ⟨e, []⟩ v) = (evalPlace ⟨e, []⟩ >>= fun x =>
      match x with
      | (pl, ty) => do
        if !pl.aligned then
          throwUb "setting the discriminant of a place based on a misaligned pointer"
        SemM.memUpdate (writeDiscriminant · pl.ptr.thin ty v)) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e0] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pe, ty', hpe, hty, rfl, rfl⟩ := runOn_localPlace_ok hs h1
  obtain rfl : ty' = ty := Option.some.inj (hty.symm.trans hte)
  simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte, pure_bind, runOn_memUpdate] at h2
  split at h2
  next m hm =>
    obtain ⟨-, rfl⟩ := prod_ok_inj h2
    exact ⟨pe, m, hpe, hm, rfl⟩
  next x hx => exact (prod_err_ok h2).elim

/-- `writeDiscriminant`'s check of an implicit variant returns the memory it read. -/
theorem exE_check {mem m : Memory} {r : Except Outcome Nat} {idx : Nat} {msg : String}
    (h : (r >>= fun a => ensureUb (a == idx) msg >>= fun _ =>
      (Except.ok mem : Except Outcome Memory)) = Except.ok m) : m = mem := by
  cases r with
  | error x => first | cases h | simp [exE_error_bind] at h
  | ok a =>
    simp only [exE_ok_bind] at h
    cases hb : (a == idx)
    · simp only [hb, exE_ensure_false, exE_throwUb, exE_error_bind, reduceCtorEq] at h
    · simp only [hb, exE_ensure_true, exE_pure, exE_ok_bind, Except.ok.injEq] at h
      first | exact h.symm | exact h

/-- `SetDiscriminant(_e, v)` with tag bits, run to success: the store of the bits at `_e`'s
pointer plus the tag offset (wrapped, as L0 computes it).

Proof: `evalStatement (.setDiscriminant p v)` is `evalPlace p >>= fun (pl, ty) => (if
!pl.aligned then throwUb .. else pure ()) >>= fun _ => memUpdate (writeDiscriminant · pl.ptr.thin
ty v)` (`rfl`); `runOn_evalPlace_nil`, `runOn_localPlace_ok hs` (`pe`, aligned, type by `hte`);
`memUpdate` is `getMem`, `liftE`, `setMem` (`runOn_liftE_ok`); in `writeDiscriminant` the
inhabitedness `ensureUb` passes, the `.multiple tag` branch with `hbits` runs
`signedDereferenceable` (ok) and the store, whose result is the new memory; the stack is
unchanged (`setMem`). -/
theorem setTag_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {e : Local} {v : Nat}
    {vs : List Spec.Variant} {discrTy : IntType} {tag : TagInfo} {esz : Nat} {eal : Align}
    {bits : Nat}
    (hte : f.body.locals[e]? = some (.enum vs discrTy (.multiple tag) esz eal))
    (hbits : tagForVariant vs tag v = some bits)
    (h : runOn (evalStatement (.setDiscriminant ⟨e, []⟩ v)) o s = (.ok (), s')) :
    ∃ pe, f.locals[e]? = some (some pe) ∧
      s.mem.store (pe.wrappingOffset tag.offset) (encodeBits tag.tag.size bits) .one =
        .ok s'.mem ∧ s'.stack = s.stack := by
  obtain ⟨pe, m, hpe, hm, rfl⟩ := setDiscr_inv hs hte h
  refine ⟨pe, hpe, ?_, rfl⟩
  cases hv : variantInhabited vs v
  · exfalso
    simp only [writeDiscriminant, hv, pure_bind, exE_ok_bind, exE_error_bind, exE_pure, exE_throw,
        exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false, Except.ok.injEq,
        reduceCtorEq] at hm
  · cases hsd : s.mem.signedDereferenceable pe tag.offset with
    | error x =>
      exfalso
      simp only [writeDiscriminant, hv, hbits, hsd, pure_bind, exE_ok_bind, exE_error_bind,
          exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
          Except.ok.injEq, reduceCtorEq] at hm
    | ok u =>
      simp only [writeDiscriminant, hv, hbits, hsd, pure_bind, exE_ok_bind, exE_error_bind,
          exE_pure, exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
          Except.ok.injEq, reduceCtorEq] at hm
      exact hm

/-- `SetDiscriminant(_e, v)` of an implicitly encoded variant, run to success: nothing changes.

Proof: as `setTag_mem` up to `writeDiscriminant`; `implicitTag` (unfold, `split at himp`)
leaves the `.single` branch or the `.multiple` branch with `tagForVariant = none`
(`Option.isNone_iff_eq_none`), both `check`, which returns the memory it read (`readDiscriminant`
only reads); `setMem` of the same memory: `s'.mem = s.mem`, stack unchanged. -/
theorem setImplicit_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {e : Local} {v : Nat} {ty : Spec.Ty}
    (hte : f.body.locals[e]? = some ty) (himp : implicitTag ty v = true)
    (h : runOn (evalStatement (.setDiscriminant ⟨e, []⟩ v)) o s = (.ok (), s')) :
    s'.mem = s.mem ∧ s'.stack = s.stack := by
  obtain ⟨pe, m, hpe, hm, rfl⟩ := setDiscr_inv hs hte h
  refine ⟨?_, rfl⟩
  show m = s.mem
  cases ty
  case enum vs dt repr sz al =>
    cases hv : variantInhabited vs v
    · exfalso
      simp only [writeDiscriminant, hv, pure_bind, exE_ok_bind, exE_error_bind, exE_pure, exE_throw,
          exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false, Except.ok.injEq,
          reduceCtorEq] at hm
    · cases repr with
      | empty => simp [implicitTag] at himp
      | single i =>
        simp only [writeDiscriminant, hv, pure_bind, exE_ok_bind, exE_error_bind, exE_pure,
            exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
            Except.ok.injEq, reduceCtorEq] at hm
        exact exE_check hm
      | multiple tag =>
        have hn : tagForVariant vs tag v = none := by simpa [implicitTag] using himp
        simp only [writeDiscriminant, hv, hn, pure_bind, exE_ok_bind, exE_error_bind, exE_pure,
            exE_throw, exE_throwUb, exE_throwIllFormed, exE_ensure_true, exE_ensure_false,
            Except.ok.injEq, reduceCtorEq] at hm
        exact exE_check hm
  all_goals simp [implicitTag] at himp

/-- Writing `bs0` into a sub-range `[off, off + n)` of a private local related at `true`, in
both L0 (a store through its pointer offset by `off`) and R (a frame write at `slot.off + off`)
with related bytes, keeps the local related and keeps `MemInj`.

Proof: `cases hr`; the `esc` case contradicts `hpw` at `k = 0` (`hin`, `hpos`: the slot's
offsets are escaped). `priv`: as `writeLocal_priv` — `writeFrame_private_eq h1` (with `hpw`)
gives the new frame (`bs1` on `[slot.off + off, slot.off + off + n)`, the old frame elsewhere)
and unchanged memory and escapes; `Memory.store_eq_ok h0` (the allocation `a`, the only one
changed, unmapped by `ι`, so `MemInj` holds as there); the new data is the old with `bs0` at
`off` (`p.addr - x.addr + off = off` by `hpaddr`; `Ryo.Spec.Theorems.foldl_set_size`, a
`fold_getElem0`-style lemma for indices inside, `Array.getElem_set!`-style for those outside);
inside, `BytesInj.getElem' hbs`; outside, the old `hbytes`. -/
theorem writeLocal_sub_priv {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} (hm : MemInj ι m0 st.mem)
    (hr : LocalRel ι fp st m0 slot p true) {off : Nat} {bs0 bs1 : List AbstractByte}
    (hbs : BytesInj ι bs0 bs1) (hpos : 0 < bs0.length) (hin : off + bs0.length ≤ slot.size)
    (hpw : ∀ k < bs0.length, st.escapedAt (slot.off + off + k) = none)
    {al : Align} (h0 : m0.store ⟨p.addr + off, p.prov⟩ bs0 al = .ok m0')
    (h1 : st.writeFrame (slot.off + off) bs1 = .ok st') :
    MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' slot p true := by
  have hl1 : bs1.length = bs0.length := (BytesInj.length hbs).symm
  obtain ⟨hmem, hea, hfr⟩ := writeFrame_private_eq h1 (fun k hk => hpw k (by omega))
  cases hr with
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hesc _ _ _ _ =>
    exfalso
    have h4 := hpw 0 hpos
    have e0 : slot.off + (off : Int) + ((0 : Nat) : Int) = slot.off + ((off : Nat) : Int) := by
      omega
    rw [e0, hesc off (by omega)] at h4
    cases h4
  | priv a x hp hι hx hlive haddr hpaddr hsize hpv hbytes =>
    have hpriv' : ∀ k < slot.size, st'.escapedAt (slot.off + k) = none :=
      fun k hk => (hea _).trans (hpv k hk)
    rcases Ryo.Spec.Theorems.Memory.store_eq_ok h0 with
      ⟨-, hz, -⟩ | ⟨id, hid, -, -, hpid, -, -, -, -, hm0'⟩
    · exfalso
      omega
    · have hai : a = id := Option.some.inj (hp.symm.trans hpid)
      cases hai
      have hxa : m0.allocs[a] = x := by
        simp only [Memory.get?, Array.getElem?_eq_getElem hid, Option.some.injEq] at hx
        exact hx
      subst hxa
      -- MemInj: only the unmapped allocation `a` changed.
      have hmi : MemInj ι m0' st'.mem := by
        rw [hmem]
        intro a' b x' hg hb
        have hne : a ≠ a' := fun e => by subst e; rw [hι] at hb; cases hb
        have hg' : m0.get? a' = some x' := by
          subst hm0'
          simpa [Memory.get?, Array.getElem?_set, hne] using hg
        exact hm a' b x' hg' hb
      refine ⟨hmi, ?_⟩
      have ha' : a < m0'.allocs.size := by subst hm0'; simpa using hid
      have hcomp : m0'.allocs[a] = { m0.allocs[a] with
          data := (bs0.zipIdx).foldl
            (fun d (b, i) => d.set! (p.addr + off - m0.allocs[a].addr + i) b)
            m0.allocs[a].data } := by
        subst hm0'; simp
      have hdata : m0'.allocs[a].data = (bs0.zipIdx).foldl
          (fun d (b, i) => d.set! (p.addr + off - m0.allocs[a].addr + i) b)
          m0.allocs[a].data := by rw [hcomp]
      have hsz' : m0'.allocs[a].data.size = slot.size := by
        rw [hdata]
        exact (Ryo.Spec.Theorems.foldl_set_size bs0 0 (p.addr + off - m0.allocs[a].addr)
          m0.allocs[a].data).trans hsize
      refine .priv a m0'.allocs[a] hp hι ?_ (by rw [hcomp]; exact hlive)
        (by rw [hcomp]; exact haddr) (by rw [hcomp]; exact hpaddr) hsz' hpriv' ?_
      · show m0'.allocs[a]? = _
        exact Array.getElem?_eq_getElem ha'
      · intro _ k hk
        have hkD : k < m0.allocs[a].data.size := by rw [hsize, ← hsz']; exact hk
        have hks : k < slot.size := by rw [← hsize]; exact hkD
        have hget : m0'.allocs[a].data[k]? =
            if (p.addr + off - m0.allocs[a].addr) + 0 ≤ k ∧
                k < (p.addr + off - m0.allocs[a].addr) + 0 + bs0.length ∧
                k < m0.allocs[a].data.size then
              bs0[k - (p.addr + off - m0.allocs[a].addr) - 0]? else m0.allocs[a].data[k]? := by
          rw [hdata]
          exact Ryo.Spec.Theorems.foldl_set_getElem bs0 0 _ m0.allocs[a].data k
        have hbase : p.addr + off - m0.allocs[a].addr = off := by omega
        rw [Array.getElem?_eq_getElem hk, hbase] at hget
        rw [hfr]
        by_cases hin2 : off ≤ k ∧ k < off + bs0.length
        · rw [if_pos ⟨by omega, by omega, hkD⟩] at hget
          have hk0 : k - off - 0 < bs0.length := by omega
          rw [List.getElem?_eq_getElem hk0] at hget
          have hdk := Option.some.inj hget
          rw [hdk, if_pos (by
            simp only [OpSem.State.privateIn, hpv k hks, Option.isNone_none, Bool.and_true,
              decide_eq_true_eq]
            omega)]
          have ht : (slot.off + (k : Int) - (slot.off + (off : Int))).toNat = k - off - 0 := by
            omega
          have hk1 : k - off - 0 < bs1.length := by omega
          rw [ht, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hk1, Option.getD_some]
          exact BytesInj.getElem' hbs _ hk0 hk1
        · rw [if_neg (by omega), Array.getElem?_eq_getElem hkD] at hget
          have hdk := Option.some.inj hget
          rw [hdk, if_neg (by
            simp only [OpSem.State.privateIn, Bool.and_eq_true, decide_eq_true_eq]
            intro hc
            obtain ⟨⟨hc1, hc2⟩, -⟩ := hc
            exact hin2 ⟨by omega, by omega⟩)]
          exact hbytes rfl k hkD

/-- The liveness facts a `SetDiscriminant` of a whole local takes: it kills nothing and reads
`_e`. -/
theorem setDiscr_live {Γ : TermCtx} {f : Spec.Frame} {bd : BlockData} {e : Local} {v : Nat}
    (hlv : LiveSound Γ.body (computeLive Γ.body).get) (hbd : Γ.body.blocks[f.bb]? = some bd)
    (hst : bd.stmts[f.stmt]? = some (.setDiscriminant ⟨e, []⟩ v)) :
    (∀ l, (computeLive Γ.body).get f.bb (f.stmt + 1) l = true →
      (computeLive Γ.body).get f.bb f.stmt l = true) ∧
    (computeLive Γ.body).get f.bb f.stmt e = true := by
  obtain ⟨h1, h2⟩ := hlv.stmt f.bb bd hbd f.stmt _ hst
  refine ⟨fun l hl => h1 l hl (by intro hk; cases hk), h2 e ?_⟩
  simp [stmtReads, placeLocals]

/-- The tag write's lift: an `imm` of the tag's width into `_e`'s slot at the tag offset.

Proof: `cases hlow` (only `tag` has one instruction); `rw [hbody] at hte`;
`setTag_mem hs hte hbits h` (`pe`, the store, the stack); `hrel.opnd hpe hse hlo` is `_e`'s
`LocalRel` at `true`, a `priv` one (an `esc` one contradicts `hrel.esc` and `hpriv` at `k = 0`),
whose address `pe.addr = x.addr` and `Memory.store_eq_ok` (the bytes are not empty: `hsize.1`,
`encodeBits_length`) give `pe.addr ≤` the wrapped address, so `wrappingOffset_eq` (offset
`< 2^31`) unwraps the store. R: `immInsnOk_spec`, `immOpsOk_spec`, `operands2`, `fits_last`
with `hpl`, `opSem_imm_fwd` writing `intBytes tag.tag.size x = encodeBits tag.tag.size bits`
(`encodeBits_mod`) at `se.off + tag.offset` (`writeEscaped_private'` with `hrel.esc`/`hpriv`).
`writeLocal_sub_priv` (`encodeBits_inj`) gives `MemInj` and `_e`'s relation;
`LocalRel.store_other` (`hrel.provNe`) and `LocalRel.writeFrame_apart` (the range inside
`_e`'s slot, `hrel.apart`) the others'. `hrel.after` with `d := e` (`hlive'` gives its
`.inr`); `memInv_store` and `hrel.hidden.store_noprov` (`encodeBits_noprov`). -/
theorem lift_setTag {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {e : Local} {v : Nat} {i : R.Insn}
    (hlow : LowerSetDiscr Γ (.setDiscriminant ⟨e, []⟩ v) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : live e = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.setDiscriminant ⟨e, []⟩ v)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @tag e v vs discrTy tag esz eal bits se i hte hbits hse hsize hoff hpriv hii =>
    rw [hbody] at hte
    obtain ⟨pe, hpe0, hsto, hstk⟩ := setTag_mem hs hte hbits h
    have hre := hrel.opnd hpe0 hse hlo
    -- the instruction
    obtain ⟨vw, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hii
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands2 hn hk
    have hops'' : vw.ops = [.slot (se.off + tag.offset), .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits vw hv) (by rw [ho, hops'']; simp)
    -- the tag range is private in R
    have hpw0 : ∀ j < tag.tag.size, s1.st.escapedAt (se.off + tag.offset + j) = none := by
      intro j hj
      cases he : s1.st.escapedAt (se.off + tag.offset + j) with
      | none => rfl
      | some e' =>
        have h3 := hrel.esc _ e' he
        rw [hpriv j hj] at h3
        cases h3
    -- L0's store does not wrap
    have hle2 : pe.addr ≤ (pe.wrappingOffset tag.offset).addr := by
      rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
        ⟨-, hl0, -⟩ | ⟨id, hid, -, -, hpid, -, hlo', -⟩
      · exfalso
        rw [Ryo.Spec.Theorems.encodeBits_length] at hl0
        exact Nat.pos_iff_ne_zero.mp hsize.1 hl0
      · exact start_le (q := pe.wrappingOffset tag.offset) hre rfl hid hpid hlo'
    have hoffNat : tag.offset < 2 ^ 64 := by
      have h1 := offOk_spec hoff.1
      have h2 := offOk_spec hoff.2
      try dsimp only [Size, Offset] at *
      omega
    rw [wrappingOffset_eq hoffNat hle2] at hsto
    -- R's write
    have hib : intBytes tag.tag.size x = encodeBits tag.tag.size bits := by
      show encodeBits tag.tag.size x = _
      rw [← encodeBits_mod tag.tag.size x, hx, encodeBits_mod]
    have hlen : (intBytes tag.tag.size x).length = tag.tag.size := by
      rw [hib]; exact Ryo.Spec.Theorems.encodeBits_length _ _
    have hpw : ∀ j < (intBytes tag.tag.size x).length,
        s1.st.escapedAt (se.off + tag.offset + j) = none := by
      intro j hj
      rw [hlen] at hj
      exact hpw0 j hj
    obtain ⟨st', hwr⟩ : ∃ st',
        s1.st.writeFrame (se.off + tag.offset) (intBytes tag.tag.size x) = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    have hf2 := offOk_spec hoff.2
    have hop := opSem_imm_fwd (ch := ch) hh hty' ho hf2 hfk hwr
    have hbs : BytesInj ι (encodeBits tag.tag.size bits) (intBytes tag.tag.size x) := by
      rw [hib]; exact encodeBits_inj ι _ _
    have hl0 : (encodeBits tag.tag.size bits).length = tag.tag.size :=
      Ryo.Spec.Theorems.encodeBits_length _ _
    obtain ⟨hmi, hre'⟩ := writeLocal_sub_priv hrel.frame.mem hre hbs
      (by rw [hl0]; exact hsize.1) (by rw [hl0]; exact hsize.2) (by rw [hl0]; exact hpw0)
      hsto hwr
    have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
        p.prov ≠ pe.prov → (se.off + se.size ≤ slot.off ∨ slot.off + slot.size ≤ se.off) →
        LocalRel ι s1.fp st' s'.mem slot p lv := by
      intro slot p lv hr hne hap
      have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
      refine LocalRel.writeFrame_apart h1 hwr hpw ?_
      rw [hlen]
      have h5 := hsize.2
      try dsimp only [Size, Offset] at *
      omega
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle'⟩ := memInv_store hpb hsto (encodeBits_noprov _ _)
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
      hrel.after hpe0 hse hmi hre' hoth (hrel.hidden.store_noprov hsto (encodeBits_noprov _ _))
        hesc (fun l hl => .inr (hlive' l hl)), hpb', hle'⟩

/-- The implicit tag write's lift: nothing changes, R runs nothing. -/
theorem lift_setImplicit {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool}
    {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    {s1 : R.RState} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body) {e : Local} {v : Nat}
    (hlow : LowerSetDiscr Γ (.setDiscriminant ⟨e, []⟩ v) [])
    (hrel : FnRel Γ ι live f s.mem s1) (hpb : ProvBounded s.mem)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.setDiscriminant ⟨e, []⟩ v)) o s = (.ok (), s')) :
    s'.stack = s.stack ∧ FnRel Γ ι live' f s'.mem s1 ∧ ProvBounded s'.mem ∧
      s.mem.allocs.size ≤ s'.mem.allocs.size ∧ MemKept s.mem s'.mem := by
  cases hlow with
  | implicit hte himp =>
    rw [hbody] at hte
    obtain ⟨hm, hst⟩ := setImplicit_mem hs hte himp h
    rw [hm]
    exact ⟨hst, hrel.weaken hlive', hpb, Nat.le_refl _, MemKept.refl _⟩

/-- No R step: `LiftOutN` of length 0. -/
theorem liftOutN_zero {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {live' : Local → Bool} {f : Spec.Frame} {s s' : Spec.State} {s1 : R.RState}
    (hstk : s'.stack = s.stack) (hrel : FnRel Γ ι live' f s'.mem s1) (hpb : ProvBounded s'.mem)
    (hle : s.mem.allocs.size ≤ s'.mem.allocs.size) (hk : MemKept s.mem s'.mem) :
    LiftOutN Γ c ch ι live' f s s' s1 0 := by
  cases s1
  exact ⟨_, .refl _, hstk, hrel, hpb, hle, hk⟩

/-- `stmtOut_of_liftN` for any statement that kills no storage (the proof is the same). -/
theorem stmtOut_of_liftN_kill {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {f : Spec.Frame} {rest : List Spec.Frame} {r : Range} {s s' : Spec.State} {s1 : R.RState}
    {bd : BlockData} {st : Statement} {k : Nat}
    (hs : s.stack = f :: rest) (hstor : StorageSound Γ.body (computeStorage Γ.body).get)
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hst : bd.stmts[f.stmt]? = some st)
    (hkill : storageKill st = none)
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hfr : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hpc : s1.pc + k = r.2)
    (hl : LiftOutN Γ.toStmtCtx c ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f s s' s1 k) :
    StmtOut Γ c ch ι f rest r s s' s1 := by
  obtain ⟨st', hsteps, hstk, hrel, hpb, hle, hk⟩ := hl
  refine ⟨_, f, hsteps, hstk.trans hs, rfl, rfl, rfl, rfl, rfl, hpc, hrel, ?_, hpb, ?_,
    hdi.of_memKept hk⟩
  · intro l p hp
    exact (hstor.stmt f.bb bd hbd f.stmt _ hst).1 l (hsl l p hp) (by rw [hkill]; intro hk; cases hk)
  · intro a ha
    exact hfr a (Nat.le_trans hle ha)

/-! ### Aggregates -/

/-- What `tagField` gives: no tag (a `.single` enum's own variant, or an implicit one), or one
constant field of the tag's bits at the tag's offset. -/
theorem tagField_cases {vs : List Spec.Variant} {repr : EnumRepr} {v : Nat}
    {tops : List Operand} {tfs : List (Nat × Spec.Ty)}
    (h : tagField vs repr v = some (tops, tfs)) :
    (tops = [] ∧ tfs = [] ∧ repr ≠ .empty ∧ (∀ i, repr = .single i → i = v) ∧
        ∀ tag, repr = .multiple tag → tagForVariant vs tag v = none) ∨
      ∃ tag bits, repr = .multiple tag ∧ tagForVariant vs tag v = some bits ∧
        tops = [.const (.scalar bits) (enumTagTy tag)] ∧ tfs = [(tag.offset, enumTagTy tag)] := by
  cases repr with
  | empty => simp [tagField] at h
  | single i =>
    simp only [tagField] at h
    split at h
    next hi =>
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine .inl ⟨rfl, rfl, ?_, ?_, ?_⟩
      · intro hc; cases hc
      · intro j hj; cases hj; exact hi
      · intro _ hj; cases hj
    next => cases h
  | multiple tag =>
    cases hb : tagForVariant vs tag v with
    | none =>
      simp only [tagField, hb, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine .inl ⟨rfl, rfl, ?_, ?_, ?_⟩
      · intro hc; cases hc
      · intro _ hj; cases hj
      · intro tg hj; cases hj; exact hb
    | some bits =>
      simp only [tagField, hb, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact .inr ⟨tag, bits, rfl, hb, rfl, rfl⟩

theorem AggFields.ops_length {Γ : StmtCtx} {sd : LocalSlot} {ops : List Operand}
    {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc} (hf : AggFields Γ sd ops fields srcs) :
    ops.length = fields.length := by
  induction hf with
  | nil => rfl
  | cons h hs ih => simp [ih]

/-- `AggFields` over appended operands and fields of matching lengths splits. -/
theorem AggFields.split {Γ : StmtCtx} {sd : LocalSlot} :
    ∀ {ops tops : List Operand} {fs tfs : List (Nat × Spec.Ty)} {srcs : List AggSrc},
    ops.length = fs.length → AggFields Γ sd (ops ++ tops) (fs ++ tfs) srcs →
    ∃ s1 s2, srcs = s1 ++ s2 ∧ AggFields Γ sd ops fs s1 ∧ AggFields Γ sd tops tfs s2
  | [], _, [], _, srcs, _, h => ⟨[], srcs, rfl, .nil, h⟩
  | _ :: _, _, _ :: _, _, _, hl, h => by
    cases h with
    | cons h1 hs =>
      obtain ⟨s1, s2, rfl, h2, h3⟩ := AggFields.split (by simpa using hl) hs
      exact ⟨_ :: s1, s2, rfl, .cons h1 h2, h3⟩
  | [], _, _ :: _, _, _, hl, _ => by simp at hl
  | _ :: _, _, [], _, _, hl, _ => by simp at hl

/-- `Ty.encodeVariant` is the selected variant's field tuple's encoding. -/
theorem encodeVariant_eq {vs : List Spec.Variant} {v : Nat} {var : Spec.Variant}
    {x : Value} (h : vs[v]? = some var) : Spec.Ty.encodeVariant vs v x = var.fields.encode x := by
  induction vs generalizing v with
  | nil => simp at h
  | cons w vs ih =>
    obtain ⟨dw, fw, iw⟩ := w
    cases v with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at h
      subst h
      rfl
    | succ n =>
      simp only [List.getElem?_cons_succ] at h
      exact ih h

theorem writeFields_append : ∀ (acc : List AbstractByte) (l1 l2 : List (Nat × List AbstractByte)),
    writeFields acc (l1 ++ l2) = writeFields (writeFields acc l1) l2
  | _, [], _ => rfl
  | acc, (off, b) :: l1, l2 => writeFields_append (writeAt acc off b) l1 l2

theorem getElem_append_one {α : Type} {l : List α} {a : α} {j : Nat}
    (h : j < (l ++ [a]).length) :
    (∃ h' : j < l.length, (l ++ [a])[j] = l[j]) ∨ (j = l.length ∧ (l ++ [a])[j] = a) := by
  by_cases hj : j < l.length
  · exact .inl ⟨hj, List.getElem_append_left hj⟩
  · right
    have e : j = l.length := by simp at h; omega
    subst e
    exact ⟨rfl, by simp⟩

theorem bytesLeDefined_encodeBits (n v : Nat) :
    bytesLeDefined (encodeBits n v) (encodeBits n v) = true := by
  rw [Ryo.Spec.Theorems.bytesLeDefined_iff]
  refine ⟨rfl, fun i h1 _ => ?_⟩
  have hp := encodeBits_noprov n v _ (List.getElem_mem h1)
  generalize (encodeBits n v)[i] = b at hp ⊢
  cases b with
  | uninit => rfl
  | init d q =>
    cases q with
    | none => simp [AbstractByte.leDefined]
    | some q => cases hp


/-- An enum aggregate's L0 effect is `AggMem` of the variant's fields and then the tag field.

Proof: invert the assignment as `agg_mem` does: `_d`'s pointer, the operands' values `vals`
(state unchanged, per operand `evalField_mem` on the first `ops.length` fields of `hf`: split
`AggFields` over `ops ++ tops` and `vfields ++ tfs`, the lengths agreeing, by induction on
`ops`), and the store of the rvalue's value at `_d`'s type, which is `.variant v (.tuple vals)`
(`evalRvalue`'s `.adt` branch at an enum destination; uninhabited is UB). `Ty.encode` of it:
`Ty.encodeVariant vs v` is `var.fields.encode (.tuple vals)` (induction on `v` against `hvar`),
which `aggLayout_encode hlay hsz` writes as `writeFields` of the fields' encodings over
`sd.size` uninitialized bytes; then `repr`'s branch (by `htag`, unfold `tagField`): nothing more
for `.single` and implicit variants (`tops = tfs = []`), else `writeAt _ tag.offset
(encodeBits tag.tag.size bits)`, which is one more `writeFields` step (`writeFields` over an
append is the composition: induction), its `FieldMem` (`.imm`, from `hf`'s last field: the
source is `.imm tag.tag.size bits` by `AggField`'s cases) `bytesLeDefined_refl`-style, its bound
from that `AggField`'s `hin`. -/
theorem enumAgg_mem {Γ : StmtCtx} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {v : Nat} {act : Option Nat} {ops : List Operand} {vs : List Spec.Variant}
    {discrTy : IntType} {repr : EnumRepr} {esz : Nat} {eal : Align} {var : Spec.Variant}
    {vfields : List (Nat × Spec.Ty)} {tops : List Operand} {tfs : List (Nat × Spec.Ty)}
    {sd : LocalSlot} {srcs : List AggSrc}
    (htd : Γ.body.locals[d]? = some (.enum vs discrTy repr esz eal))
    (hvar : vs[v]? = some var) (hlay : aggLayout var.fields = some vfields)
    (htag : tagField vs repr v = some (tops, tfs))
    (hsz : var.fields.size? = some sd.size)
    (hf : AggFields Γ sd (ops ++ tops) (vfields ++ tfs) srcs)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.aggregate (.adt v act) ops))) o s =
      (.ok (), s')) :
    AggMem f d sd.size (vfields ++ tfs) srcs s s' := by
  rw [hbody] at htd
  have e : evalStatement (.assign ⟨d, []⟩ (.aggregate (.adt v act) ops)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.aggregate (.adt v act) ops) ty' >>= fun w =>
          placeStore pl w ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd', rfl, hs1⟩ := runOn_localPlace_ok hs h1
  rw [hs1] at h2
  obtain rfl : td = .enum vs discrTy repr esz eal := Option.some.inj (htd'.symm.trans htd)
  have h2' : runOn (evalRvalue (.aggregate (.adt v act) ops) (.enum vs discrTy repr esz eal) >>=
      fun w => placeStore ⟨pd.widen, true⟩ w (.enum vs discrTy repr esz eal)) o s =
      (.ok (), s') := h2
  obtain ⟨w, s2, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  have e2 : evalRvalue (.aggregate (.adt v act) ops) (.enum vs discrTy repr esz eal) =
      (ops.mapM (fun o => do pure (← evalOperand o).1) >>= fun vals =>
        if !variantInhabited vs v then throwUb "writing an uninhabited enum variant"
        else pure (Value.variant v (.tuple vals))) := by
    first | rfl | (unfold evalRvalue; rfl) | (simp only [evalRvalue]; done)
  rw [e2] at h3
  obtain ⟨vals, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨rfl, rfl⟩ : w = .variant v (.tuple vals) ∧ s2 = s3 := by
    split at h6
    · rw [runOn_throwUb] at h6; exact (prod_err_ok h6).elim
    · exact runOn_pure_inv h6
  -- the encoding: the variant's fields, then the tag
  obtain ⟨bs, he, hsto⟩ := typedStore_inv hst
  have hev := encodeVariant_eq (x := .tuple vals) hvar
  simp only [Spec.Ty.encode, Option.bind_eq_bind, hev] at he
  cases hvb : var.fields.encode (.tuple vals) with
  | none => simp [hvb] at he
  | some vb =>
  simp only [hvb, Option.bind_some] at he
  have hol := AggFields.ops_length hf
  rcases tagField_cases htag with ⟨rfl, rfl, hne, hsi, hmn⟩ | ⟨tag, bits, rfl, hb, rfl, rfl⟩
  · -- no tag write
    simp only [List.append_nil] at hf ⊢
    have hbsv : bs = vb := by
      cases repr with
      | empty => exact absurd rfl hne
      | single i =>
        have hiv := hsi i rfl
        subst hiv
        simp at he
        first | exact he.symm | exact he
      | multiple tag =>
        simp only [hmn tag rfl, Option.some.injEq] at he
        first | exact he.symm | exact he
    obtain ⟨hs5, ebs, hl1, hl2, hl3, hall, hfms, hbds⟩ := aggFields_mapM hs hbody hf h5
    obtain ⟨ebs', hl1', hl2', hall', hvbe⟩ := aggLayout_encode hlay hsz (AggFields.wf hf) hvb
    have hee : ebs' = ebs := by
      apply List.ext_getElem (by omega)
      intro j h1 h2
      exact Option.some.inj ((hall' j (by omega) (by omega) h1).symm.trans
        (hall j (by omega) (by omega) h2))
    subst hee
    rw [hs5] at hsto
    refine ⟨pd, ebs', hld, hl3, hl1.symm, hfms, fun j h1 h2 => hbds j h1 h2, ?_, ?_⟩
    · rw [← hvbe, ← hbsv, hs']
      exact hsto
    · rw [hs']
      show Spec.State.stack _ = _
      rw [hs5]
  · -- the tag write: one more field
    simp only [hb, Option.some.injEq] at he
    have hl : ops.length = vfields.length := by
      simp only [List.length_append, List.length_cons, List.length_nil] at hol
      omega
    obtain ⟨sv, st0, rfl, hfo, hft⟩ := AggFields.split hl hf
    cases hft with
    | @cons op off t src ops' fs' srcs' hfd hnil =>
    cases hnil
    obtain ⟨hs5, ebs, hl1, hl2, hl3, hall, hfms, hbds⟩ := aggFields_mapM hs hbody hfo h5
    obtain ⟨ebs', hl1', hl2', hall', hvbe⟩ := aggLayout_encode hlay hsz (AggFields.wf hfo) hvb
    have hee : ebs' = ebs := by
      apply List.ext_getElem (by omega)
      intro j h1 h2
      exact Option.some.inj ((hall' j (by omega) (by omega) h1).symm.trans
        (hall j (by omega) (by omega) h2))
    subst hee
    rw [hs5] at hsto
    -- the tag field's bytes
    have hsz_t : (enumTagTy tag).size? = some tag.tag.size := size?_int _ _
    have htf : FieldMem f s.mem src (encodeBits tag.tag.size bits) ∧
        tag.offset + (encodeBits tag.tag.size bits).length ≤ sd.size := by
      rw [Ryo.Spec.Theorems.encodeBits_length]
      cases hfd with
      | slot ha => first | cases ha | simp [Operand.local?] at ha
      | @imm _ _ n _ hwf hn hpos hin =>
        obtain rfl : n = tag.tag.size := Option.some.inj (hn.symm.trans hsz_t)
        exact ⟨bytesLeDefined_encodeBits _ _, hin⟩
      | zst hwf hn hin hop =>
        have h0 : tag.tag.size = 0 := Option.some.inj (hsz_t.symm.trans hn)
        refine ⟨?_, by rw [h0]; exact hin⟩
        show encodeBits tag.tag.size bits = []
        exact List.eq_nil_of_length_eq_zero ((Ryo.Spec.Theorems.encodeBits_length _ _).trans h0)
    have hz : ((vfields ++ [(tag.offset, enumTagTy tag)]).map (·.1)).zip
        (ebs' ++ [encodeBits tag.tag.size bits]) =
        (vfields.map (·.1)).zip ebs' ++ [(tag.offset, encodeBits tag.tag.size bits)] := by
      rw [List.map_append, List.zip_append (by rw [List.length_map]; exact hl1.symm)]
      rfl
    refine ⟨pd, ebs' ++ [encodeBits tag.tag.size bits], hld, by simp [hl3], by simp [hl1], ?_,
      ?_, ?_, ?_⟩
    · intro j h1 h2
      rcases getElem_append_one h1 with ⟨hj, e1⟩ | ⟨hj, e1⟩ <;>
        rcases getElem_append_one h2 with ⟨hj2, e2⟩ | ⟨hj2, e2⟩
      · rw [e1, e2]; exact hfms j hj hj2
      · omega
      · omega
      · rw [e1, e2]; exact htf.1
    · intro j h1 h2
      rcases getElem_append_one h1 with ⟨hj, e1⟩ | ⟨hj, e1⟩ <;>
        rcases getElem_append_one h2 with ⟨hj2, e2⟩ | ⟨hj2, e2⟩
      · rw [e1, e2]; exact hbds j hj hj2
      · omega
      · omega
      · rw [e1, e2]; exact htf.2
    · rw [hz, writeFields_append]
      show s.mem.store pd (writeAt (writeFields (List.replicate sd.size .uninit)
        ((vfields.map (·.1)).zip ebs')) tag.offset (encodeBits tag.tag.size bits)) .one = _
      rw [← hvbe, he, hs']
      exact hsto
    · rw [hs']
      show Spec.State.stack _ = _
      rw [hs5]

/-- The enum aggregate's lift (the shape of SimAgg's `lift_agg`).

Proof: `cases hlow`; `enumAgg_mem hs hbody ..` is the `AggMem`; `lift_aggMem hmode hρ
hsd hoff hpriv hf hi' hi hsc hpe hpl hrel hpb hla hlive' hmm` (`hi'` the rule's `piecesOk`).
`hla`: `aggFields_slot_mem hf` puts a `.slot` source's local in
`(ops ++ tops).flatMap operandLocals`; `tops` are constants (unfold `tagField` in `htag`), whose
`operandLocals` are `[]` (`List.flatMap_append`), so it is in `rvalueLocals (.aggregate _ ops)`
and `hlo` makes it live. -/
theorem lift_enumAgg {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerEnumAgg Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @agg d v act ops vs discrTy repr esz eal var vfields tops tfs sd srcs is htd hvar hlay htag
      hsz hsd hoff hpriv hf hpo =>
    have hmm := enumAgg_mem hs hbody htd hvar hlay htag hsz hf h
    refine lift_aggMem hmode hρ hsd hoff hpriv hf hpo hi hsc hpe hpl hrel hpb ?_ hlive' hmm
    intro src hsrc a so ws he
    apply hlo
    have hm := aggFields_slot_mem hf src hsrc a so ws he
    have htops : ∀ op ∈ tops, operandLocals op = [] := by
      rcases tagField_cases htag with ⟨rfl, -⟩ | ⟨tag, bits, -, -, rfl, -⟩
      · intro op hop; cases hop
      · intro op hop
        rw [List.mem_singleton] at hop
        subst hop
        rfl
    have hm' : a ∈ ops.flatMap operandLocals := by
      rw [List.flatMap_append, List.mem_append] at hm
      rcases hm with hm | hm
      · exact hm
      · obtain ⟨op, hop, hin⟩ := List.mem_flatMap.mp hm
        rw [htops op hop] at hin
        cases hin
    simpa [rvalueLocals] using hm'

/-! ### The family's statement step -/

/-- `stmt_sim` (FnStep.lean) for `LowerEnum`.

Proof: set up as `stmt_sim`'s `fam` block (`hpc0`, `hsc`, `hpe`, `hbody`, `hmode'`,
`hρ'`). `read`: `enumRead_shape` gives `.assign ⟨d, []⟩ rv` and `[i]`; then exactly the `fam`
block with `lift_enumRead`. `setDiscr`: `cases` on the rule. `tag` (one instruction):
`rangeInsns_single`, `hfn.plain`, `setDiscr_live hfn.live M.hbd hst`, `lift_setTag`, then
`liftOutN_of_lift` and `stmtOut_of_liftN_kill (hkill := rfl)` with `k = 1`. `implicit` (no
instruction): `rangeInsns_nil h1 h2` gives `r.2 = r.1 = s1.pc`, `lift_setImplicit` and
`liftOutN_zero`, then `stmtOut_of_liftN_kill` with `k = 0`. `agg`: the statement is an
assignment (`cases` on the rule); `assign_live`, the range's instructions by `rangeInsns_at`,
`scopesAt_nil`, `hfn.plain` (as SimAgg's hypotheses), `lift_enumAgg`, then `stmtOut_of_liftN`
with `k = (rangeInsns c.d r).length` (`rangeInsns_length`). -/
theorem stmt_sim_enum {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hlow : LowerEnum Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  cases hlow with
  | read h =>
    obtain ⟨d, rv, i, rfl, hR⟩ := enumRead_shape h
    obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
    have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
    have hpc : s1.pc + 1 = r.2 := by rw [hpc0, he]
    have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    rw [hR] at h
    refine stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc ?_
    exact lift_enumRead M.stack M.body.symm hmode.symm hρ.symm h hc hsc hpe hpl M.rel M.pb hl2
      hl1 hev
  | setDiscr h =>
    generalize hR : rangeInsns c.d r = is at h
    cases h with
    | @tag e v vs discrTy tag esz eal bits se i hte hbits hse hsize hoff hpriv hii =>
      obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
      have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
      have hpl : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc
      obtain ⟨hl1, hl2⟩ := setDiscr_live hfn.live M.hbd hst
      refine stmtOut_of_liftN_kill (k := 1) M.stack hfn.storage M.hbd hst rfl M.sl M.fresh
        M.dinv (by rw [hpc0, he]) ?_
      exact liftOutN_of_lift (lift_setTag M.stack M.body.symm hmode.symm hρ.symm
        (.tag hte hbits hse hsize hoff hpriv hii) hc hsc hpe hpl M.rel M.pb hl2 hl1 hev)
    | implicit hte himp =>
      have hr0 := rangeInsns_nil h1 h2 hR
      obtain ⟨hl1, -⟩ := setDiscr_live hfn.live M.hbd hst
      obtain ⟨hstk, hrel', hpb', hle, hk⟩ :=
        lift_setImplicit M.stack M.body.symm (.implicit hte himp) M.rel M.pb hl1 hev
      refine stmtOut_of_liftN_kill (k := 0) M.stack hfn.storage M.hbd hst rfl M.sl M.fresh
        M.dinv (by rw [hpc0]; omega) ?_
      exact liftOutN_zero hstk hrel' hpb' hle hk
  | agg h =>
    obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
      cases h; exact ⟨_, _, rfl⟩
    have hlen := rangeInsns_length (r := r) h2
    have hi : ∀ j (hj : j < (rangeInsns c.d r).length),
        c.d.insns[s1.pc + j]? = some ((rangeInsns c.d r)[j]'hj) := by
      rw [hpc0]; exact rangeInsns_at h2
    have hsc' : ∀ j, j < (rangeInsns c.d r).length → c.scopesAt (s1.pc + j) = [] :=
      fun _ _ => scopesAt_nil hfn.noScopes _
    have hpl : ∀ i ∈ rangeInsns c.d r, PlainView c.mode c.ρ i := by
      intro i hmem
      obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hmem
      rw [hmode, hρ]
      exact hfn.plain _ _ (hi j hj)
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    refine stmtOut_of_liftN (k := (rangeInsns c.d r).length) M.stack hfn.storage M.hbd hst M.sl
      M.fresh M.dinv (by rw [hpc0, hlen]; omega) ?_
    exact lift_enumAgg M.stack M.body.symm hmode.symm hρ.symm h hi hsc' hpe hpl M.rel M.pb hl2
      hl1 hev

end Ryo.Proofs.Lower
