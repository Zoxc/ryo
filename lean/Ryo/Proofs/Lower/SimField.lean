/-
Ryo.Proofs.Lower.SimField — the simulation of `field` (`Check/Lower/Field.lean`, M5b's places):
`_d = copy/move _a.f₁.….fₖ` lowered to one `mov` of `n` bytes from `_a`'s slot at `off` (the
sum of L0's field offsets) to `_d`'s private slot.

L0 evaluates the place to `_a`'s pointer offset by `off` (`runOn_evalPlace_fields`: each
`.field` step is `ptrOffsetInbounds`, which leaves the state alone), loads `n` bytes there,
decodes them at the field type `ty` and stores the value's re-encoding into `_d`. R copies the
`n` bytes at `sa.off + off`: a sub-range of `_a`'s slot, related to L0's load whether `_a` is
private or escaped (`readLocal_sub_inj`, generalizing `readLocal_inj`). The re-encoding is below
the loaded bytes in MiniRust's order at any well-formed type (`reenc_wf`, from
`encode_decode_le`), and that order composes with `ByteInj` (`BytesInj.of_le_trans`), so what R
copied refines what L0 stored. The stored bytes' provenance is the loaded bytes'
(`bytesLeDefined_prov`), which keeps `Hidden` and `ProvBounded` (as for `lift_copyPtr`).
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Check.Lower.Field
import Ryo.Spec.Theorems.Monotone

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### L0: reading a field place of a local -/

/-- `copy p` and `move p` evaluate alike.

Proof: as `eval_use_norm`: `cases oa` (the `operandPlace?` hypothesis rules out `const` and the
rest by `cases ha`), then `first | rfl | simp only [evalStatement, evalRvalue,
evalOperand_move]`. -/
theorem eval_use_place_norm {pl : MPlace} {oa : Operand} {p : MPlace}
    (ha : operandPlace? oa = some p) :
    evalStatement (.assign pl (.use oa)) = evalStatement (.assign pl (.use (.copy p))) := by
  cases oa <;> simp [operandPlace?] at ha <;> subst ha <;>
    first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]

/-- The base local of an operand's place is among the rvalue's locals (so `hlo` makes it
live).

Proof: `cases oa <;> simp_all [operandPlace?, rvalueLocals, operandLocals, placeLocals]`
(after `cases ha` on the `some p = some _` equations, `p.base` is the head of `placeLocals`). -/
theorem operandPlace?_mem {oa : Operand} {p : MPlace} (ha : operandPlace? oa = some p) :
    p.base ∈ rvalueLocals (.use oa) := by
  cases oa <;> simp [operandPlace?] at ha <;> subst ha <;>
    simp [rvalueLocals, operandLocals, placeLocals]

/-- `ptrOffsetInbounds` by a natural offset, run to success: the address moves, the state
stays. -/
theorem runOn_ptrOffsetInbounds_ok {o : Spec.Oracle} {s s1 : Spec.State} {q q' : ThinPointer}
    {off : Nat} (h : runOn (ptrOffsetInbounds q (off : Int)) o s = (.ok q', s1)) :
    q' = ⟨q.addr + off, q.prov⟩ ∧ s1 = s := by
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
  · rw [runOn_pure] at h4
    obtain ⟨hq, hs1⟩ := prod_ok_inj h4
    have e : ((q.addr : Int) + (off : Int)).toNat = q.addr + off := by omega
    refine ⟨by rw [← hq, e], ?_⟩
    rw [← hs1, hs3, ← hs2]

/-- The common tail of `projectPlace`'s sized-field cases. -/
theorem runOn_offset_place {o : Spec.Oracle} {s s1 : Spec.State} {q : ThinPointer} {off : Nat}
    {fty : Spec.Ty} {r : Spec.Place × Spec.Ty}
    (h : runOn (ptrOffsetInbounds q (off : Int) >>= fun q' =>
      pure ((⟨q'.widen, true⟩ : Spec.Place), fty)) o s = (.ok r, s1)) :
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, true⟩, fty) ∧ s1 = s := by
  obtain ⟨q', s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨rfl, hs2⟩ := runOn_ptrOffsetInbounds_ok h1
  rw [runOn_pure] at h2
  obtain ⟨hr, hs1⟩ := prod_ok_inj h2
  exact ⟨hr.symm, hs1.symm.trans hs2⟩

/-- One field projection `fieldOf` covers, run to success. -/
theorem runOn_projectPlace_field {o : Spec.Oracle} {s s1 : Spec.State} {q : ThinPointer}
    {t fty ann : Spec.Ty} {fi off : Nat} {r : Spec.Place × Spec.Ty}
    (hf : fieldOf t fi = some (off, fty))
    (h : runOn (projectPlace ⟨q.widen, true⟩ t (.field fi ann)) o s = (.ok r, s1)) :
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, true⟩, fty) ∧ s1 = s := by
  unfold fieldOf at hf
  split at hf
  next fields head tail =>
    have e : projectPlace ⟨q.widen, true⟩ (.tuple fields head tail) (.field fi ann) =
        (ptrOffsetInbounds q (off : Int) >>= fun q' =>
          pure ((⟨q'.widen, true⟩ : Spec.Place), fty)) := by
      first
        | (simp only [projectPlace, hf]; done)
        | (simp only [projectPlace, hf]; rfl)
        | simp [projectPlace, hf]
    rw [e] at h
    exact runOn_offset_place h
  next fields a b c =>
    have e : projectPlace ⟨q.widen, true⟩ (.union fields a b c) (.field fi ann) =
        (ptrOffsetInbounds q (off : Int) >>= fun q' =>
          pure ((⟨q'.widen, true⟩ : Spec.Place), fty)) := by
      first
        | (simp only [projectPlace, hf]; done)
        | (simp only [projectPlace, hf]; rfl)
        | simp [projectPlace, hf]
    rw [e] at h
    exact runOn_offset_place h
  · cases hf

/-- The projections' fold over field projections `fieldPath` covers (`F` is `evalPlace`'s
folded function). -/
theorem runOn_foldlM_fields {o : Spec.Oracle}
    {F : Spec.Place × Spec.Ty → ProjElem → SemM (Spec.Place × Spec.Ty)} (projs : List ProjElem) :
    ∀ {q : ThinPointer} {t ty : Spec.Ty} {off : Nat} {s s1 : Spec.State}
      {r : Spec.Place × Spec.Ty},
    fieldPath t projs = some (off, ty) →
    runOn (projs.foldlM F (⟨q.widen, true⟩, t)) o s = (.ok r, s1) →
    (∀ x e, F x e = projectPlace x.1 x.2 e) →
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, true⟩, ty) ∧ s1 = s := by
  induction projs with
  | nil =>
    intro q t ty off s s1 r hp h _
    simp only [fieldPath, Option.some.injEq, Prod.mk.injEq] at hp
    obtain ⟨rfl, rfl⟩ := hp
    rw [List.foldlM_nil, runOn_pure] at h
    obtain ⟨hr, hs⟩ := prod_ok_inj h
    exact ⟨by rw [← hr, Nat.add_zero], hs.symm⟩
  | cons e ps ih =>
    intro q t ty off s s1 r hp h hF
    cases e
    case field fi ann =>
      simp only [fieldPath] at hp
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
    all_goals simp [fieldPath] at hp

/-- A place of field projections `fieldPath` covers, evaluated: `_a`'s pointer offset by the
sum of the offsets, still aligned, at the projected type, the state unchanged.

Proof: `evalPlace ⟨a, projs⟩` is `localPlace a >>= fun init => projs.foldlM (fun (pl, ty) e =>
projectPlace pl ty e) init` (`rfl`); `runOn_bind_ok` and `runOn_localPlace_ok hs` give
`init = (⟨pa.widen, true⟩, ta)` and `s2 = s`. Then a generalized lemma by induction on `projs`
over the accumulator `(⟨q.widen, true⟩, t)` with `fieldPath t projs = some (off', ty)`:
`[]` is `pure` (`off' = 0`, `⟨q.addr + 0, q.prov⟩ = q`); for `.field f _ :: ps`,
`List.foldlM_cons` and `runOn_bind_ok` split off `projectPlace ⟨q.widen, true⟩ t (.field f _)`;
`fieldOf t f = some (o, fty)` makes `t` a `tuple`/`union` with `fields[f]? = some (o, fty)`
(`unfold fieldOf at *; split at *`), so the step is `ptrOffsetInbounds q o >>= pure ...`, whose
success (`runOn_liftE`, the `if` on the address range) gives `⟨(q.addr + o : Int).toNat, q.prov⟩`
(`Int.toNat` of a sum of naturals: `omega` after `Int.toNat_natCast`-style rewrites) with the
state unchanged; the IH at `⟨q.addr + o, q.prov⟩` and `Nat.add_assoc` finish it. -/
theorem runOn_evalPlace_fields {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {a : Local} {projs : List ProjElem}
    {ta ty : Spec.Ty} {off : Nat} {r : Spec.Place × Spec.Ty}
    (hta : f.body.locals[a]? = some ta) (hpath : fieldPath ta projs = some (off, ty))
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
  obtain ⟨hr, hs1⟩ := runOn_foldlM_fields projs hpath h2 (fun ⟨_, _⟩ _ => rfl)
  exact ⟨pa, hpa, hr, hs1⟩

/-- `_d = copy _a.projs` run to success, in memory terms (the analogue of `copy_mem`): L0 loads
`n` bytes at `_a`'s pointer offset by `off`, decodes them at `ty`, and stores the re-encoding
into `_d`.

Proof: `assign_use_inv hs h` (destination, `td`, the operand run, the store); unfold
`evalOperand (.copy ⟨a, projs⟩)` to `evalPlace .. >>= fun (pl, ty) => placeLoad pl ty >>= pure`
(`rfl`, as in `runOn_evalOperand_copy`), `runOn_bind_ok`, `runOn_evalPlace_fields`,
`runOn_placeLoad_ok` (the place is aligned, its thin pointer is `⟨pa.addr + off, pa.prov⟩`);
`td = ty` from `htd`; then `typedLoad_inv hn` and `typedStore_inv`. -/
theorem field_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {projs : List ProjElem}
    {ta ty : Spec.Ty} {off n : Nat}
    (hta : f.body.locals[a]? = some ta) (hpath : fieldPath ta projs = some (off, ty))
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
  obtain ⟨pa, hpa, rfl, hs2⟩ := runOn_evalPlace_fields hs hta hpath h1
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

/-! ### R: a sub-range of a related local -/

/-- A load of `n > 0` bytes at `off` inside an allocation, through a pointer to its start:
the data's sub-range, which lies inside the allocation. -/
theorem load_sub {m : Memory} {p : ThinPointer} {a : AllocId} {x : Allocation}
    (hp : p.prov = some a) (hx : m.get? a = some x) (hpaddr : p.addr = x.addr)
    {off n : Nat} {al : Align} {bs : List AbstractByte} (hn : n ≠ 0)
    (h : m.load ⟨p.addr + off, p.prov⟩ n al = .ok bs) :
    bs = (x.data.extract off (off + n)).toList ∧ off + n ≤ x.data.size := by
  obtain ⟨id, hid, hprov, -, hlo, hhi, hbs⟩ := load_eq_ok_pos hn h
  have hia : id = a := Option.some.inj (hprov.symm.trans hp)
  have hx' : m.get? id = some x := by rw [hia]; exact hx
  have hxa : m.allocs[id] = x := by
    have h' : m.allocs[id]? = some x := hx'
    rw [Array.getElem?_eq_getElem hid] at h'
    exact Option.some.inj h'
  simp only [hxa, hpaddr, Nat.add_sub_cancel_left] at hbs hhi
  exact ⟨hbs, by omega⟩

/-- A successful load returns `n` bytes. -/
theorem load_length {m : Memory} {p : ThinPointer} {n : Nat} {al : Align}
    {bs : List AbstractByte} (h : m.load p n al = .ok bs) : bs.length = n := by
  by_cases hn : n = 0
  · subst hn
    rw [load_zero_inv h]
    rfl
  · obtain ⟨id, hid, -, -, hlo, hhi, rfl⟩ := load_eq_ok_pos hn h
    first
      | (rw [Array.length_toList, Array.size_extract]; omega)
      | (simp only [Array.length_toList, Array.size_extract] at hlo hhi ⊢; omega)
      | (simp at hlo hhi ⊢; omega)

/-- Reading `n` bytes at `off` inside a related local: L0's load at the local's pointer plus
`off` and R's frame read at `slot.off + off` give related bytes (a private local must be
semantically live). Generalizes `readLocal_inj` (`off = 0`, `n = slot.size`).

Proof: first a `load_sub` lemma generalizing `load_whole`: for `p.prov = some a`,
`m.get? a = some x`, `p.addr = x.addr`, a successful `m.load ⟨p.addr + off, p.prov⟩ n al` is
`(x.data.extract off (off + n)).toList` (from `Memory.checkPtr_eq_ok`: the allocation is `a`,
the in-allocation offset `off`; `n = 0` gives `[]`), and `off + n ≤ x.data.size`. Then as
`readLocal_inj`: `priv` with `readFrame_eq_map (g := fun i => st.frame (slot.off + (off + i)))`
(`hpriv (off + i)`, casts by `push_cast`/`omega`) and `hbytes rfl (off + i)`; `esc` with
`g := fun i => (y.data[x.addr - y.addr + off + i]?).getD .uninit` (`hin (off + i)`) and
`hxy.bytes`. Pointwise via `BytesInj_of_getElem`, `Array.getElem_extract`. -/
theorem readLocal_sub_inj {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory}
    {slot : LocalSlot} {p : ThinPointer} (hm : MemInj ι m0 st.mem)
    (hr : LocalRel ι fp st m0 slot p true) {off n : Nat} (hin : off + n ≤ slot.size)
    {al : Align} {bs0 : List AbstractByte}
    (h : m0.load ⟨p.addr + off, p.prov⟩ n al = .ok bs0) :
    ∃ bs1, st.readFrame (slot.off + off) n = .ok bs1 ∧ BytesInj ι bs0 bs1 := by
  by_cases hn : n = 0
  · subst hn
    rw [load_zero_inv h]
    refine ⟨[], ?_, trivial⟩
    have := readFrame_eq_map (st := st) (off := slot.off + off) (n := 0)
      (g := fun _ => .uninit) (fun i hi => absurd hi (Nat.not_lt_zero _))
    rw [List.range_zero, List.map_nil] at this
    exact this
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    obtain ⟨rfl, hle⟩ := load_sub hp hx hpaddr hn h
    refine ⟨_, readFrame_eq_map (g := fun i => st.frame (slot.off + ((off + i : Nat) : Int)))
      (fun i hi => ?_), ?_⟩
    · have e : slot.off + (off : Int) + (i : Int) = slot.off + ((off + i : Nat) : Int) := by
        omega
      rw [e, OpSem.State.byteAt, hpriv (off + i) (by omega)] <;> rfl
    · apply BytesInj_of_getElem (by
        first
          | (rw [Array.length_toList, Array.size_extract, List.length_map, List.length_range];
             omega)
          | (simp; omega)
          | simp)
      intro k h0 _
      have hk : k < n := by
        first
          | (rw [Array.length_toList, Array.size_extract] at h0; omega)
          | (simp at h0; omega)
      simp only [Array.getElem_toList, Array.getElem_extract, List.getElem_map,
        List.getElem_range]
      exact hbytes rfl (off + k) (by omega)
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    obtain ⟨rfl, hle⟩ := load_sub hp hx hpaddr hn h
    obtain ⟨y', hy', hxy⟩ := hm a e.id x hx hι
    obtain rfl : y = y' := Option.some.inj (hy.symm.trans hy')
    have hlo := hxy.lo
    have hhi := hxy.hi
    simp only [Allocation.size] at hhi
    refine ⟨_, readFrame_eq_map
      (g := fun i => (y.data[x.addr - y.addr + (off + i)]?).getD .uninit) (fun i hi => ?_), ?_⟩
    · have hb : x.addr - y.addr + (off + i) < y.data.size := by omega
      have e1 : slot.off + (off : Int) + (i : Int) = slot.off + ((off + i : Nat) : Int) := by
        omega
      have hcast : slot.off + ((off + i : Nat) : Int) - e.off =
          ((x.addr - y.addr + (off + i) : Nat) : Int) := by
        omega
      have hidx : (slot.off + ((off + i : Nat) : Int) - e.off).toNat =
          x.addr - y.addr + (off + i) := by
        rw [hcast]; omega
      rw [e1, OpSem.State.byteAt, hin (off + i) (by omega)]
      simp only [hy, hylive, Bool.not_true, Bool.false_eq_true, ↓reduceIte, hidx,
        Array.getElem?_eq_getElem hb, Option.getD_some] <;> rfl
    · apply BytesInj_of_getElem (by
        first
          | (rw [Array.length_toList, Array.size_extract, List.length_map, List.length_range];
             omega)
          | (simp; omega)
          | simp)
      intro k h0 _
      have hk : k < n := by
        first
          | (rw [Array.length_toList, Array.size_extract] at h0; omega)
          | (simp at h0; omega)
      have hb : x.addr - y.addr + (off + k) < y.data.size := by omega
      simp only [Array.getElem_toList, Array.getElem_extract, List.getElem_map,
        List.getElem_range, Array.getElem?_eq_getElem hb, Option.getD_some]
      exact hxy.bytes hlive (off + k) (by omega) hb

/-! ### Re-encoding at any well-formed type -/

/-- MiniRust's order then `ByteInj`: a byte below `b0` relates to whatever `b0` relates to.

Proof: `cases b <;> cases b0 <;> cases b1`, then the provenance options; `simp_all
[AbstractByte.leDefined, ByteInj]` (an `init d (some f)` below `init d0 (some f0)` has
`d = d0 ∧ f = f0`; an `init d none` below `init d0 _` has `d = d0`). -/
theorem ByteInj.of_le_trans {ι : Inj} {b b0 b1 : AbstractByte} (hle : b.leDefined b0 = true)
    (h : ByteInj ι b0 b1) : ByteInj ι b b1 := by
  cases b with
  | uninit => cases b1 <;> exact trivial
  | init d pf =>
    cases b0 with
    | uninit => cases pf <;> simp [AbstractByte.leDefined] at hle
    | init d0 pf0 =>
      cases b1 with
      | uninit => cases pf0 <;> exact (h : False).elim
      | init d1 g =>
        cases pf with
        | none =>
          have e : d = d0 := by simpa [AbstractByte.leDefined] using hle
          subst e
          cases pf0 with
          | none => first | exact h | (simp only [ByteInj] at h ⊢; exact h)
          | some _ => simp only [ByteInj] at h ⊢; exact h.1
        | some fr =>
          cases pf0 with
          | none => simp [AbstractByte.leDefined] at hle
          | some fr0 =>
            have e : d = d0 ∧ fr = fr0 := by simpa [AbstractByte.leDefined] using hle
            obtain ⟨rfl, rfl⟩ := e
            exact h

/-- Pointwise `ByteInj.of_le_trans`; the order also fixes the length.

Proof: induction on `bs` generalizing `bs0 bs1` as in `BytesInj.of_leDefined`
(`bytesLeDefined` is `List.leDefinedBy`, `false` on unequal lengths). -/
theorem BytesInj.of_le_trans {ι : Inj} {bs bs0 bs1 : List AbstractByte}
    (hle : bytesLeDefined bs bs0 = true) (h : BytesInj ι bs0 bs1) :
    BytesInj ι bs bs1 ∧ bs.length = bs0.length := by
  induction bs generalizing bs0 bs1 with
  | nil =>
    cases bs0 with
    | nil => exact ⟨h, rfl⟩
    | cons _ _ => simp [bytesLeDefined, List.leDefinedBy] at hle
  | cons b bs ih =>
    cases bs0 with
    | nil => simp [bytesLeDefined, List.leDefinedBy] at hle
    | cons b0 bs0 =>
      cases bs1 with
      | nil => exact (h : False).elim
      | cons b1 bs1 =>
        have hle' : (b.leDefined b0 && bytesLeDefined bs bs0) = true := hle
        simp only [Bool.and_eq_true] at hle'
        have h' : ByteInj ι b0 b1 ∧ BytesInj ι bs0 bs1 := h
        obtain ⟨h1, h2⟩ := ih hle'.2 h'.2
        refine ⟨?_, by simp [h2]⟩
        show ByteInj ι b b1 ∧ BytesInj ι bs bs1
        exact ⟨ByteInj.of_le_trans hle'.1 h'.1, h1⟩

/-- A byte below `b0` with a provenance fragment has `b0`'s. -/
theorem provFrag_of_le {b b0 : AbstractByte} {fr : ProvenanceFrag}
    (hle : b.leDefined b0 = true) (hfr : b.provFrag = some fr) : b0.provFrag = some fr := by
  cases b with
  | uninit => simp [AbstractByte.provFrag] at hfr
  | init d pf =>
    simp only [AbstractByte.provFrag] at hfr
    subst hfr
    cases b0 with
    | uninit => simp [AbstractByte.leDefined] at hle
    | init d0 pf0 =>
      cases pf0 with
      | none => simp [AbstractByte.leDefined] at hle
      | some fr0 =>
        have e : d = d0 ∧ fr = fr0 := by simpa [AbstractByte.leDefined] using hle
        rw [e.2]
        rfl

/-- Bytes below `bs0` carry only provenance `bs0` carries (at the same index), in the shape
`lift_copyPtr` uses (`ptr_reenc_prov`).

Proof: induction on `bs` generalizing `bs0`; a byte with `provFrag = some fr` below `b0` is
`init d (some fr)` below `init d0 (some fr)` (`AbstractByte.leDefined`), so `j = 0`, `fr0 = fr`;
the tail case shifts `j` by one. -/
theorem bytesLeDefined_prov {bs bs0 : List AbstractByte} (hle : bytesLeDefined bs bs0 = true) :
    ∀ b ∈ bs, ∀ fr, b.provFrag = some fr →
      ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
  induction bs generalizing bs0 with
  | nil => intro b hb; cases hb
  | cons b bs ih =>
    cases bs0 with
    | nil => simp [bytesLeDefined, List.leDefinedBy] at hle
    | cons b0 bs0 =>
      have hle' : (b.leDefined b0 && bytesLeDefined bs bs0) = true := hle
      simp only [Bool.and_eq_true] at hle'
      intro c hc fr hfr
      rcases List.mem_cons.mp hc with rfl | hc
      · refine ⟨0, by simp, fr, ?_, rfl⟩
        show b0.provFrag = some fr
        exact provFrag_of_le hle'.1 hfr
      · obtain ⟨j, hj, fr0, h0, he⟩ := ih hle'.2 c hc fr hfr
        exact ⟨j + 1, by simp [hj], fr0, by simpa using h0, he⟩

/-- A value decoded at a well-formed type re-encodes below the bytes it was decoded from.

Proof: `Ryo.Spec.Theorems.encode_decode_le ty bs0 v hwf (by simp [Spec.Ty.size, hn, hl]) hd`
gives `⟨bs, he', hle⟩`; `bs = bsd` from `he.symm.trans he'`. -/
theorem reenc_wf {ty : Spec.Ty} {n : Nat} (hwf : ty.wf = true) (hn : ty.size? = some n)
    {bs0 bsd : List AbstractByte} {v : Value} (hl : bs0.length = n)
    (hd : ty.decode bs0 = some v) (he : ty.encode v = some bsd) :
    bytesLeDefined bsd bs0 = true := by
  obtain ⟨bs, he', hle⟩ := Ryo.Spec.Theorems.encode_decode_le ty bs0 v hwf
    (by simp [Ryo.Spec.Ty.size, hn, hl]) hd
  obtain rfl : bsd = bs := Option.some.inj (he.symm.trans he')
  exact hle

/-! ### The simulation -/

/-- The handler step of `field` from L0's memory facts (`field_mem`): the `mov` from
`sa.off + off` to `sd.off` succeeds, keeping `MemInj`, giving `_d`'s `LocalRel` and keeping
every disjoint local's (the analogue of `sim_copyBytes`).

Proof: as `sim_copyBytes`: `readLocal_sub_inj hmem hra hin hlo` gives R's bytes `ba` with
`BytesInj ι bs0 ba`; `bs0.length = n` (`BytesInj.length` and the frame read's length, or the
load's: `Memory.load` returns `n` bytes); `reenc_wf hwf hn` then `BytesInj.of_le_trans` give
`BytesInj ι bsd ba` and `bsd.length = n`; the write `st.writeFrame sd.off ba` succeeds on the
private slot (`writeEscaped_private'`); `opSem_mov_fwd hh hty ho hfits` is the step;
`writeLocal_priv` the destination; `LocalRel.store_other` and `LocalRel.writeFrame_apart` the
others. -/
theorem sim_copyField {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {ty : Spec.Ty} {n off : Nat} (hwf : ty.wf = true) (hn : ty.size? = some n)
    {sd sa : LocalSlot} (hsd : sd.size = n) (hin : off + n ≤ sa.size)
    {pd pa : ThinPointer} {bs0 bsd : List AbstractByte} {v : Value}
    (hlo : s.mem.load ⟨pa.addr + off, pa.prov⟩ n .one = .ok bs0)
    (hdec : ty.decode bs0 = some v) (hen : ty.encode v = some bsd)
    (hsto : s.mem.store pd bsd .one = .ok s'.mem)
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
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off + off ∧
      sa.off + off < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ st', opSem opc [.slot sd.off, .slot (sa.off + off)] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  have hbl : bs0.length = n := load_length hlo
  obtain ⟨ba, hrfa, hia⟩ := readLocal_sub_inj hmem hra hin hlo
  have hle := reenc_wf hwf hn hbl hdec hen
  obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
  rw [hbl] at hlend
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

/-- `field`'s lift: a `mov` of `n` bytes from inside `_a`'s slot to `_d`'s private slot.

Proof (as `lift_copyPtr`): `cases hlow`; `rw [eval_use_place_norm ha] at h`; `movInsnOk_spec`,
`intTyOk_spec`, `rw [hbody] at hta htd`; `field_mem hs hta hpath htd hn h` (pointers, bytes,
store, stack); `live a` from `hlo _ (operandPlace?_mem ha)`, then `hrel.opnd hpa hsa` for `_a`;
`hrel.priv_dst hpd hsd (by omega) hpriv` for `_d`; `sim_copyField` (offsets by `offOk_spec`).
Memory invariants: `bytesLeDefined_prov (reenc_wf ..)` sends each stored provenance to a loaded
byte's, so `hrel.hidden.load hlo0` gives `Hidden.store_hidden` and `hpb.load hlo0` gives
`hpb.store`; `store_size` the allocation count. The step is `step_of_view`, the relation
`hrel.after` (`opSem_out` for the escapes). No hypothesis beyond `LowersFn`'s is needed (the
rule carries `ty.wf`). -/
theorem lift_field {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerField Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @field d a oa projs ta ty off n sd sa i ha hta hpath htd hn hpos hwf hsd hsa hsize hoff
      hpriv hmi =>
    rw [eval_use_place_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at hta htd
    obtain ⟨pd, pa, bs0, w, bsd, hpd, hpa, hlo0, hd, hen, hsto, hstk⟩ :=
      field_mem hs hta hpath htd hn h
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
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

end Ryo.Proofs.Lower
