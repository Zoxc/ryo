/-
Ryo.Proofs.Lower.SimWide — the lift of `LowerWide` (`Check/Lower/Wide.lean`, M5b): wide
pointer metadata reads and casts, each one `mov` into a private destination.

Wide pointers. Every rule's L0 effect is "load bytes from `_a`, store bytes less defined than
some sub-range of them into `_d`" (`MovSubMem`, `MovMem` for the whole slot), and R's `mov`
copies that sub-range of `_a`'s slot (`readLocal_sub_inj`), so the rules share
`lift_movSub` (as `lift_movMem`, `SimCopy.lean`, for a sub-range) and differ in how L0's run
gives the bytes:
- `metaLen`: L0 decodes 16 bytes `bs0` at `_a`'s slice pointer type, the length `u` being
  `decodeBits (bs0.drop 8)`, and stores `encodeBits 8 u` at `usize` (`encodeBits_decode_le`:
  below the 8 bytes it was decoded from); the 8-byte load at `+ 8` is `bs0.drop 8`
  (`load_sub_of_load`).
- `wideCast`: the value is `_a`'s decoded pointer, metadata included (`evalCast_wide_ok`); its
  encoding at `_d`'s type is its encoding at `_a`'s (`encode_ptr_shape`), below `bs0`
  (`encode_decode_le`, `_a`'s type well-formed).
- `wideToThin`: the value is the thin part `tp = decodePtr (bs0.take 8)`, whose encoding is
  below `bs0.take 8` (`ptr_reenc_le`), the 8-byte load at `+ 0`.
`lift_wide` needs no hypothesis beyond `LowersFn`'s.

Pool constants (a global's address by `addr.const`, a copy of a pool constant by `const`) are
not lowered by these rules. L0's `globalPtr g` instantiates global `g` on demand and lets the
oracle pick among existing copies (D7); R's address is fixed by the image (it points into the
constant pool, allocation `constsId`). A lift would assume `GlobalPick ι o s g off p` for the
instruction's address operand `p`: the run of `globalPtr g` changes neither memory nor stack
and returns `q` with `PtrInj ι (q.wrappingOffset off) p`, `q`'s allocation mapped by `ι`.
Discharging it needs: a certificate map from global ids to pool offsets `k_g`, checked against
the relocations (`CodeReloc::Const { alloc, offset }` is `ρ (.const (k_g + off))`); an invariant
in `Match` that every constant/vtable global the code uses has one L0 copy, mapped by `ι` to
`constsId` at `k_g`, whose bytes refine the pool's (with relocated addresses); and an oracle
condition that `.constCopy g n` answers that copy (fresh copies would need `LiftOut` to extend
`ι`). Statics are reached by `addr.sym` instead (`constant.rs`), not by these rules.
-/
import Ryo.Proofs.Lower.SimCopy
import Ryo.Proofs.Lower.SimField
import Ryo.Proofs.Lower.SimDst
import Ryo.Proofs.Lower.SimUnop
import Ryo.Check.Lower.Wide

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Loads and bytes -/

/-- A sub-range of a successful load is a successful load (at alignment one).

Proof: `load_eq_ok_pos` (`n ≠ 0` from `hjk`, `hk`) gives the allocation `id`, its bounds and
`bs` as the extract at `p.addr - x.addr`; `load_of_bounds` (alignment one: `Align.isAligned`
of `Align.one`, as in `stLoad_inj`) gives the sub-load as the extract at
`p.addr + j - x.addr`; the two lists agree by `List.ext_getElem` with `Array.getElem_extract`,
`List.getElem_take`, `List.getElem_drop` (`omega` for the indices). -/
theorem load_sub_of_load {m : Memory} {p : ThinPointer} {n j k : Nat} {al : Align}
    {bs : List AbstractByte} (h : m.load p n al = .ok bs) (hjk : j + k ≤ n) (hk : 0 < k) :
    m.load ⟨p.addr + j, p.prov⟩ k .one = .ok ((bs.drop j).take k) := by
  obtain ⟨id, hid, hprov, hlv, h1, h2, rfl⟩ := load_eq_ok_pos (by omega) h
  have hal : Align.one.isAligned (p.addr + j) = true := by
    simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
  rw [load_of_bounds (p := ⟨p.addr + j, p.prov⟩) hid hal (by omega) hprov hlv
    (by show _ ≤ p.addr + j; omega) (by show p.addr + j + k ≤ _; omega)]
  congr 1
  apply List.ext_getElem
  · simp only [Array.length_toList, Array.size_extract, List.length_take, List.length_drop]
    omega
  · intro q hq1 hq2
    simp only [Array.getElem_toList, Array.getElem_extract, List.getElem_take,
      List.getElem_drop]
    congr 1
    omega

/-- Fresh data bytes of the bits decoded from `bs` are below `bs` (`init x none` is below any
`init x _`).

Proof: `decodeBits_iff` gives `ds` with `bs.mapM AbstractByte.data = some ds`; `encodeBits
bs.length (leDecode ds)` is `ds.map AbstractByte.ofByte` (`leEncode_leDecode`, as in
`bytesInj_encodeBits_of_decode`); then `bytesLeDefined_iff` pointwise: `bs[i]` is
`init ds[i] _` (`AbstractByte.eq_init_of_data`, or `mapM_data_iff`) and `ofByte ds[i] = init
ds[i] none` is below it (`AbstractByte.leDefined`, `cases` on the fragment). -/
theorem encodeBits_decode_le {bs : List AbstractByte} {u : Nat} (h : decodeBits bs = some u) :
    bytesLeDefined (encodeBits bs.length u) bs = true := by
  obtain ⟨ds, hds, hu⟩ := (Ryo.Spec.Theorems.decodeBits_iff bs u).mp h
  subst hu
  obtain ⟨hl, hget⟩ := (Ryo.Spec.Theorems.mapM_data_iff bs ds).mp hds
  have e : encodeBits bs.length (leDecode ds) = ds.map AbstractByte.ofByte := by
    unfold encodeBits
    rw [hl, Ryo.Spec.Theorems.leEncode_leDecode]
  rw [e]
  refine (Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mpr
    ⟨by rw [List.length_map]; omega, fun k h0 h1 => ?_⟩
  rw [List.getElem_map]
  have hdk := hget k h1 (by simpa using h0)
  rw [Ryo.Spec.Theorems.AbstractByte.eq_init_of_data hdk]
  generalize bs[k].provFrag = fr
  cases fr <;> simp [AbstractByte.ofByte, AbstractByte.leDefined]

/-! ### The common lift: a `mov` from a sub-range of `_a`'s slot -/

/-- L0's effect of a statement lowered to a `mov` of `n` bytes from `_a`'s slot at `off` to
`_d`: `n` bytes `bs0` loaded at `_a`'s pointer plus `off`, bytes less defined than them stored
into `_d`, the stack unchanged. `MovMem` is the case `off = 0`, `n` the slot's size. -/
def MovSubMem (f : Spec.Frame) (d a : Local) (off n : Nat) (s s' : Spec.State) : Prop :=
  ∃ pd pa bs0 bsd, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
    s.mem.load ⟨pa.addr + off, pa.prov⟩ n .one = .ok bs0 ∧ bytesLeDefined bsd bs0 = true ∧
    s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack

/-- A `mov` of `n` bytes from `_a`'s slot at `off` to `_d`'s private slot simulates any L0
effect `MovSubMem`.

Proof: `lift_movMem`'s (SimCopy.lean) with `readLocal_sub_inj hrel.frame.mem hra hsize.2 hlo0`
(SimField.lean) in place of `readLocal_inj`: R's read `ba` of `sa.off + off` with `BytesInj ι
bs0 ba`, so `BytesInj ι bsd ba` (`BytesInj.of_le`); `bsd.length = n` from
`bytesLeDefined_iff` and `load_length`; the write (`writeEscaped_private'`), `opSem_mov_fwd`
(offsets by `offOk_spec`), `writeLocal_priv`, `LocalRel.store_other`,
`LocalRel.writeFrame_apart`; `Hidden`/`ProvBounded` by `le_prov` with `hrel.hidden.load hlo0`
and `hpb.load hlo0`; then `step_of_view`, `hrel.after`, `store_size`. -/
theorem lift_movSub {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d a : Local} {off n : Nat} {sd sa : LocalSlot} {i : R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
    (hsize : sd.size = n ∧ off + n ≤ sa.size) (hpos : 0 < n)
    (hoff : offOk sd.off ∧ offOk (sa.off + off))
    (hmi : movInsnOk Γ i n sd.off (sa.off + off) = true)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hla : live a = true) (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmm : MovSubMem f d a off n s s') :
    LiftOut Γ c ch ι live' f s s' s1 := by
  obtain ⟨pd, pa, bs0, bsd, hpd, hpa, hlo0, hle, hsto, hstk⟩ := hmm
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  have hra := hrel.opnd hpa hsa hla
  have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  -- R's read refines `bs0`, hence `bsd`
  obtain ⟨ba, hrfa, hia⟩ := readLocal_sub_inj hrel.frame.mem hra hsize.2 hlo0
  have hbs := BytesInj.of_le hle hia
  have hlend : bsd.length = n :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans (movLoad_length hlo0)
  have hlenb : ba.length = n := (BytesInj.length hbs).symm.trans hlend
  -- R's write, to a private or an escaped `_d`
  have hlen0 : bsd.length = sd.size := by rw [hlend, hsize.1]
  obtain ⟨st', hwr, hesc, hmi', hrd, hoth⟩ := hrel.write_dst hld hpd hsd hpos' hbs hlen0 hsto
  have hop := opSem_mov_fwd (ch := ch) hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hlenb hwr
  have hsub := le_prov hle
  -- `Hidden`: the stored provenance is the loaded bytes', which `Hidden` excludes
  have hhid := hrel.hidden.load hlo0
  have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hhid _ (List.getElem_mem hj) fr0 hf0
  -- the bound: likewise
  have hbd := hpb.load hlo0
  have hbd' : BytesBounded s.mem.allocs.size bsd := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hbd _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
    hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

/-! ### L0: the wide pointer rules -/

/-- A wide pointer type's size.

Proof: as `size?_ptr_thin`: `simp [Spec.Ty.size?, Spec.Ty.layout, PtrType.isWide, hk,
LayoutStrategy.size?]` (`isWide` is `metaKind != .none`, true by `hk`). -/
theorem size?_ptr_wide {pt : PtrType} {valid : ValidRange} (hk : pt.metaKind ≠ .none) :
    (Spec.Ty.ptr pt valid).size? = some 16 := by
  simp [Spec.Ty.size?, Spec.Ty.layout, PtrType.isWide, hk, LayoutStrategy.size?]

/-- The value-keeping casts of a pointer to a wide pointer type, run to success, return it.

Proof: as `evalCast_thin_ok` (SimCopy.lean): `cases k` (and the coercion); `ptrToPtr` and
`fnPtrToPtr` take the `pt.isWide` branch (`PtrType.isWide`, `hkd`), giving `pure (.ptr pv)`;
`mutToConstPointer`/`unsafeFnPointer` are `pure val`; `runOn_pure_inv`. Kinds outside
`wideKeepKind` contradict `hk`. -/
theorem evalCast_wide_ok {k : CastKind} (hk : wideKeepKind k = true) {pv : Pointer}
    {src : Spec.Ty} {ptd : PtrType} {vd : ValidRange} (hkd : ptd.metaKind ≠ .none)
    {o : Spec.Oracle} {s s2 : Spec.State} {w : Value}
    (h : runOn (evalCast k (Value.ptr pv, src) (.ptr ptd vd)) o s = (.ok w, s2)) :
    w = .ptr pv ∧ s2 = s := by
  have hw : ptd.isWide = true := by simp [PtrType.isWide, hkd]
  cases k
  all_goals first
    | (exfalso; simp [wideKeepKind] at hk; done)
    | (have e : evalCast .ptrToPtr (Value.ptr pv, src) (.ptr ptd vd) =
          (if ptd.isWide = true then (pure (Value.ptr pv) : SemM Value)
            else pure (Value.ptr pv.thin.widen)) := rfl
       rw [e, if_pos hw] at h
       exact runOn_pure_inv h)
    | (have e : evalCast .fnPtrToPtr (Value.ptr pv, src) (.ptr ptd vd) =
          (if ptd.isWide = true then (pure (Value.ptr pv) : SemM Value)
            else pure (Value.ptr pv.thin.widen)) := rfl
       rw [e, if_pos hw] at h
       exact runOn_pure_inv h)
    | (rename_i c
       cases c
       all_goals first
         | (exfalso; simp [wideKeepKind] at hk; done)
         | exact runOn_pure_inv (a := Value.ptr pv) h)

/-- Pointer types whose metadata kinds encode alike encode every value alike.

Proof: `cases v` (non-pointer values encode to `none` at both, the catch-all of
`Spec.Ty.encode`); for `.ptr pv`, `simp only [Spec.Ty.encode]` and case on `ptd.metaKind`,
`pta.metaKind` (`hshape` rules out the mixed and thin cases by `simp [sameMetaShape]`) and on
`pv.metadata`. -/
theorem encode_ptr_shape {ptd pta : PtrType} {vd va : ValidRange}
    (hshape : sameMetaShape ptd.metaKind pta.metaKind = true) (v : Value) :
    (Spec.Ty.ptr ptd vd).encode v = (Spec.Ty.ptr pta va).encode v := by
  cases v
  case ptr pv =>
    obtain ⟨tp, md⟩ := pv
    simp only [Spec.Ty.encode]
    revert hshape
    generalize ptd.metaKind = kd
    generalize pta.metaKind = ka
    intro hshape
    cases kd <;> cases ka
    all_goals first
      | (exfalso; simp [sameMetaShape] at hshape; done)
      | (cases md with
          | none => rfl
          | some m => cases m <;> rfl)
  all_goals first | rfl | simp [Spec.Ty.encode]

/-- A wide pointer decodes from 16 bytes: its thin part from the first 8 and, for a slice
pointer, its length from the last 8. -/
theorem decode_ptr_wide_inv {pt : PtrType} {valid : ValidRange} (hk : pt.metaKind ≠ .none)
    {bs : List AbstractByte} {v : Value} (hd : (Spec.Ty.ptr pt valid).decode bs = some v) :
    ∃ pv : Pointer, bs.length = 16 ∧ decodePtr (bs.take 8) = some pv.thin ∧ v = .ptr pv ∧
      (pt.metaKind = .elementCount →
        ∃ u, decodeBits (bs.drop 8) = some u ∧ pv.metadata = some (.elementCount u)) := by
  cases hm : pt.metaKind with
  | none => exact absurd hm hk
  | elementCount =>
    simp only [Spec.Ty.decode, hm] at hd
    by_cases hl : bs.length = 16
    · cases hdp : decodePtr (bs.take 8) with
      | none => simp [hl, hdp] at hd
      | some tp =>
        by_cases hv : valid.contains tp.addr = true
        · cases hdb : decodeBits (bs.drop 8) with
          | none => simp [hl, hdp, hv, hdb] at hd
          | some u =>
            simp [hl, hdp, hv, hdb] at hd
            subst hd
            exact ⟨⟨tp, some (.elementCount u)⟩, hl, rfl, rfl, fun _ => ⟨u, rfl, rfl⟩⟩
        · simp [hl, hdp, hv] at hd
    · simp [hl] at hd
  | vtablePointer tr =>
    simp only [Spec.Ty.decode, hm] at hd
    by_cases hl : bs.length = 16
    · cases hdp : decodePtr (bs.take 8) with
      | none => simp [hl, hdp] at hd
      | some tp =>
        by_cases hv : valid.contains tp.addr = true
        · cases hdb : decodePtr (bs.drop 8) with
          | none => simp [hl, hdp, hv, hdb] at hd
          | some vt =>
            simp [hl, hdp, hv, hdb] at hd
            subst hd
            exact ⟨⟨tp, some (.vtablePointer vt)⟩, hl, rfl, rfl, fun h0 => by cases h0⟩
        · simp [hl, hdp, hv] at hd
    · simp [hl] at hd

/-- `ptrToPtr`/`fnPtrToPtr` of a pointer to a thin pointer type, run to success, keep its thin
part. -/
theorem evalCast_toThin_ok {k : CastKind} (hk : wideThinKind k = true) {pv : Pointer}
    {src : Spec.Ty} {ptd : PtrType} {vd : ValidRange} (hkd : ptd.metaKind = .none)
    {o : Spec.Oracle} {s s2 : Spec.State} {w : Value}
    (h : runOn (evalCast k (Value.ptr pv, src) (.ptr ptd vd)) o s = (.ok w, s2)) :
    w = .ptr ⟨pv.thin, none⟩ ∧ s2 = s := by
  have hw : ¬ (ptd.isWide = true) := by simp [PtrType.isWide, hkd]
  cases k
  all_goals first
    | (exfalso; simp [wideThinKind] at hk; done)
    | (have e : evalCast .ptrToPtr (Value.ptr pv, src) (.ptr ptd vd) =
          (if ptd.isWide = true then (pure (Value.ptr pv) : SemM Value)
            else pure (Value.ptr pv.thin.widen)) := rfl
       rw [e, if_neg hw] at h
       exact runOn_pure_inv h)
    | (have e : evalCast .fnPtrToPtr (Value.ptr pv, src) (.ptr ptd vd) =
          (if ptd.isWide = true then (pure (Value.ptr pv) : SemM Value)
            else pure (Value.ptr pv.thin.widen)) := rfl
       rw [e, if_neg hw] at h
       exact runOn_pure_inv h)

/-- `PtrMetadata` of a slice pointer is its length. -/
theorem evalUnOp_meta_len {pv : Pointer} {pta : PtrType} {va : ValidRange} {dt : Spec.Ty}
    {u : Nat} (hka : pta.metaKind = .elementCount)
    (hpm : pv.metadata = some (.elementCount u)) :
    evalUnOp .ptrMetadata (Value.ptr pv, Spec.Ty.ptr pta va) dt = pure (Value.int u) := by
  first
    | (simp only [evalUnOp, hka, hpm]; done)
    | (unfold evalUnOp; rw [hka, hpm])
    | (simp only [evalUnOp]; rw [hka, hpm])
    | simp [evalUnOp, hka, hpm]

/-- `wideCast`'s L0 side.

Proof: as `ptrCast_mem` (SimCopy.lean): `eval_cast_norm ha`, `assign_cast_inv`,
`runOn_evalOperand_copy`; the load at `.ptr pta va` is 16 bytes `bs0` (`typedLoad_inv`,
`size?_ptr_wide hka`) decoding to `v0`, which is a pointer `.ptr pv` (`Spec.Ty.decode` of a
pointer type, by `cases` on the decode as in `decode_ptr_thin_inv`); `subst hty`;
`evalCast_wide_ok` (`hkd` from `hshape`: `sameMetaShape .none _ = false`) gives `w = .ptr pv`;
the store encodes at `.ptr ptd vd`, which is the encoding at `.ptr pta va`
(`encode_ptr_shape`), below `bs0` by `Ryo.Spec.Theorems.encode_decode_le _ bs0 _ hwf`
(length by `movLoad_length`, `tySize_of`). -/
theorem wideCast_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    {k : CastKind} {ty : Spec.Ty} {ptd pta : PtrType} {vd va : ValidRange}
    (hk : wideKeepKind k = true) (ha : oa.local? = some a)
    (hka : pta.metaKind ≠ .none) (hshape : sameMetaShape ptd.metaKind pta.metaKind = true)
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hty : ty = .ptr ptd vd)
    (hta : f.body.locals[a]? = some (.ptr pta va)) (hwf : (Spec.Ty.ptr pta va).wf = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k oa ty))) o s = (.ok (), s')) :
    MovMem f d a 16 s s' := by
  rw [eval_cast_norm ha] at h
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  obtain ⟨pa, ta', v0, hpa, hta', hla, hr, hs1⟩ := runOn_evalOperand_copy hs hev
  subst hr
  subst hs1
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = .ptr pta va := Option.some.inj (hta'.symm.trans hta)
  rw [e4] at hst
  rw [e5] at hla hca
  subst hty
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv (size?_ptr_wide hka) hla
  obtain ⟨pv, hlen0, -, hv, -⟩ := decode_ptr_wide_inv hka hd0
  subst hv
  have hkd : ptd.metaKind ≠ .none := by
    intro h0
    rw [h0] at hshape
    cases hm : pta.metaKind <;> rw [hm] at hshape <;> simp [sameMetaShape] at hshape
  obtain ⟨hw, hs2⟩ := evalCast_wide_ok hk hkd hca
  subst hw
  subst hs2
  subst hs'
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  rw [encode_ptr_shape hshape] at hen
  exact ⟨pd, pa, bs0, bsd, hpd, hpa, hlo, reenc_wf hwf (size?_ptr_wide hka) hlen0 hd0 hen,
    hsto, rfl⟩

/-- `wideToThin`'s L0 side.

Proof: as `ptrCast_mem`: invert (`eval_cast_norm`, `assign_cast_inv`,
`runOn_evalOperand_copy`); the 16 loaded bytes `bs0` decode at the wide type to a pointer whose
thin part is `tp` with `decodePtr (bs0.take 8) = some tp` (`Spec.Ty.decode`'s wide cases:
`.elementCount`/`.vtablePointer` both `decodePtr (bytes.take 8)`); `ptrToPtr`/`fnPtrToPtr` at
the thin `ty` (`subst hty`, `PtrType.isWide`, `hkd`) give `.ptr tp.widen = .ptr ⟨tp, none⟩`,
encoded at `_d`'s type as `encodePtr tp` (`Spec.Ty.encode`, `hkd`); the sub-load at `+ 0` is
`bs0.take 8` (`load_sub_of_load`, `List.drop_zero`; `⟨pa.addr + 0, pa.prov⟩ = pa` by
`Nat.add_zero` and `cases pa`), and `ptr_reenc_le` (length 8 by `List.length_take`) gives the
order. -/
theorem wideToThin_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    {k : CastKind} {ty : Spec.Ty} {ptd pta : PtrType} {vd va : ValidRange}
    (hk : wideThinKind k = true) (ha : oa.local? = some a)
    (hka : pta.metaKind ≠ .none) (hkd : ptd.metaKind = .none)
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hty : ty = .ptr ptd vd)
    (hta : f.body.locals[a]? = some (.ptr pta va))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k oa ty))) o s = (.ok (), s')) :
    MovSubMem f d a 0 8 s s' := by
  rw [eval_cast_norm ha] at h
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  obtain ⟨pa, ta', v0, hpa, hta', hla, hr, hs1⟩ := runOn_evalOperand_copy hs hev
  subst hr
  subst hs1
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = .ptr pta va := Option.some.inj (hta'.symm.trans hta)
  rw [e4] at hst
  rw [e5] at hla hca
  subst hty
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv (size?_ptr_wide hka) hla
  obtain ⟨pv, hlen0, hdp, hv, -⟩ := decode_ptr_wide_inv hka hd0
  subst hv
  obtain ⟨hw, hs2⟩ := evalCast_toThin_ok hk hkd hca
  subst hw
  subst hs2
  subst hs'
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have he' : bsd = encodePtr pv.thin := by
    simp [Spec.Ty.encode, hkd] at hen
    first | exact hen.symm | exact hen
  rw [he'] at hsto
  have hsub := load_sub_of_load hlo (j := 0) (k := 8) (by omega) (by omega)
  rw [List.drop_zero] at hsub
  have hl8 : (bs0.take 8).length = 8 := by simp [hlen0]
  exact ⟨pd, pa, bs0.take 8, encodePtr pv.thin, hpd, hpa, hsub, ptr_reenc_le hl8 hdp, hsto,
    rfl⟩

/-- `metaLen`'s L0 side.

Proof: `eval_unop_norm ha`, `assign_unop_inv` (SimUnop.lean); the 16 loaded bytes `bs0`
(`typedLoad_inv`, `size?_ptr_wide`) decode at the slice pointer type (`hka`) to
`.ptr ⟨tp, some (.elementCount u)⟩` with `decodeBits (bs0.drop 8) = some u`; `evalUnOp
.ptrMetadata` returns `.int u` (`hka`; `runOn_pure_inv`); `typedStore_int` at `t = ⟨false, 8⟩`
stores `encodeBits 8 (t.toBits u)`, which is `encodeBits 8 u` (`u < 2 ^ 64` from
`Ryo.Spec.Theorems.decodeBits_iff` and the length 8; `IntType.toBits` of a non-negative value
below the modulus); the sub-load at `+ 8` is `bs0.drop 8` (`load_sub_of_load` with `j = k = 8`,
`List.take_of_length_le`), and `encodeBits_decode_le` (length 8) gives the order. -/
theorem metaLen_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    {pta : PtrType} {va : ValidRange} {t : IntType} {vd : ValidRange}
    (ha : oa.local? = some a) (hka : pta.metaKind = .elementCount)
    (hta : f.body.locals[a]? = some (.ptr pta va))
    (htd : f.body.locals[d]? = some (.int t vd)) (ht : t = ⟨false, 8⟩)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.unaryOp .ptrMetadata oa))) o s =
      (.ok (), s')) :
    MovSubMem f d a 8 8 s s' := by
  rw [eval_unop_norm ha] at h
  obtain ⟨pd, pa, td, ta, w0, v, hpd, hpa, htd', hta', hla, s1, hev, mem', hst, hs'⟩ :=
    assign_unop_inv hs h
  have e4 : td = .int t vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .ptr pta va := Option.some.inj (hta'.symm.trans hta)
  subst e4
  subst e5
  subst ht
  have hk' : pta.metaKind ≠ .none := by rw [hka]; decide
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv (size?_ptr_wide hk') hla
  obtain ⟨pv, hlen0, -, hv, hmeta⟩ := decode_ptr_wide_inv hk' hd0
  obtain ⟨u, hu, hpm⟩ := hmeta hka
  subst hv
  rw [evalUnOp_meta_len hka hpm] at hev
  obtain ⟨hv', hs1⟩ := runOn_pure_inv hev
  subst hv'
  subst hs1
  subst hs'
  have hl8 : (bs0.drop 8).length = 8 := by simp [hlen0]
  have hu64 : u < 2 ^ (8 * 8) := by
    obtain ⟨ds, hds, hdu⟩ := (Ryo.Spec.Theorems.decodeBits_iff _ u).mp hu
    have hlds := ((Ryo.Spec.Theorems.mapM_data_iff _ ds).mp hds).1
    have hlt := Ryo.Spec.Theorems.leDecode_lt ds
    rw [hdu, ← hlds, hl8] at hlt
    exact hlt
  have htb : IntType.toBits ⟨false, 8⟩ (u : Int) = u := by
    show ((u : Int) % ((2 ^ (8 * 8) : Nat) : Int)).toNat = u
    have h1 : (u : Int) % ((2 ^ (8 * 8) : Nat) : Int) = (u : Int) :=
      Int.emod_eq_of_lt (by omega) (Int.ofNat_lt.mpr hu64)
    rw [h1]
    rfl
  have hsto := typedStore_int hst
  rw [htb] at hsto
  have hle := encodeBits_decode_le hu
  rw [hl8] at hle
  have hsub := load_sub_of_load hlo (j := 8) (k := 8) (by omega) (by omega)
  have ht8 : (bs0.drop 8).take 8 = bs0.drop 8 := List.take_of_length_le (by omega)
  rw [ht8] at hsub
  exact ⟨pd, pa, bs0.drop 8, encodeBits 8 u, hpd, hpa, hsub, hle, hsto, rfl⟩

/-! ### The wide pointer lift -/

/-- `LowerWide`'s lift.

Proof: `cases hlow`; types rewritten with `hbody`; `live a` from `hlo _ (operand_local_mem
ha)` (`rvalueLocals` of a cast or unary operator is `operandLocals`); then
- `metaLen`: `lift_movSub` (`off = n = 8`, `hpos` by `decide`) with `metaLen_mem`;
- `wideCast`: `lift_movMem` (SimCopy.lean, `n = 16`) with `wideCast_mem`;
- `wideToThin`: `lift_movSub` (`off = 0`, `n = 8`) with `wideToThin_mem`.
No hypothesis beyond `LowersFn`'s. -/
theorem lift_wide {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerWide Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hld : Ryo.Proofs.Provenance.LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | metaLen ha hka hta htd ht hsd hsa hsize hoff hmi =>
    rw [hbody] at hta htd
    exact lift_movSub hmode hρ hsd hsa hsize (by decide) hoff hmi hi hsc hpe hpl hrel
      hpb hld (hlo _ (operand_local_mem ha)) hlive' (metaLen_mem hs ha hka hta htd ht h)
  | wideCast hk ha hka hshape htd hty hta hwf hsd hsa hsize hoff hmi =>
    rw [hbody] at hta htd
    exact lift_movMemE hmode hρ hsd hsa hsize (by decide) hoff hmi hi hsc hpe hpl hrel
      hpb hld (hlo _ (operand_local_mem ha)) hlive'
      (wideCast_mem hs hk ha hka hshape htd hty hta hwf h)
  | wideToThin hk ha hka hkd htd hty hta hsd hsa hsize hoff hmi =>
    rw [hbody] at hta htd
    exact lift_movSub hmode hρ hsd hsa hsize (by decide) hoff hmi hi hsc hpe hpl hrel
      hpb hld (hlo _ (operand_local_mem ha)) hlive' (wideToThin_mem hs hk ha hka hkd htd hty hta h)

end Ryo.Proofs.Lower
