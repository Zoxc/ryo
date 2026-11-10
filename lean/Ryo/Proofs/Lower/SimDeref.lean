/-
Ryo.Proofs.Lower.SimDeref — the simulation of `load` and `store` (`Check/Lower/Deref.lean`,
M5b's places): `_d = copy/move (*_p).f₁.….fₖ` lowered to one `load` of `n` bytes from
`[sp.off + off]` into `_d`'s private slot, and `(*_p).f₁.….fₖ = copy/move _a` lowered to one
`store` of `_a`'s `n` bytes to `[sp.off + off]`.

L0 (`runOn_evalPlace_deref`): `_p`'s 8 bytes decode to a thin pointer `q`, which the field
projections offset in bounds by `off` (so `q.addr + off < 2^64`, and R's `wrappingOffset` by
the same `off` gives the same address). R reads `_p`'s slot, whose bytes relate to L0's
(`readLocal_inj`), so R's pointer has `q`'s address and, when `ι` maps `q`'s allocation, its
image as provenance (`decodePtr_inj`).

Where a pointer read from L0 memory points: `FnRel`'s `Hidden` says no live L0 byte carries
the provenance of a private storage-live local, so such a pointer never points into a private
local of the frame (`loaded_ptr_not_priv`). For R that is not enough: the pointee must be an
allocation R holds, i.e. one `ι` maps. That is the invariant `Hidden m (Unmapped ι m)` (no live
byte carries the provenance of a live, non-empty allocation `ι` drops; `loaded_ptr_mapped`),
which neither `FnRel` nor `MatchAt` has yet. The lifts take it as a hypothesis, the store also
`LiveDisjoint` (L0's live allocations don't overlap: `store_inj` needs the other L0 allocations
in the stored-to R object disjoint from the stored range), and `derefInv_store` shows a store
of bytes whose provenance comes from loaded bytes keeps both. Then:
- load: R's `State.load` resolves to `ι`'s image and returns related bytes (`stLoad_inj`); the
  re-encoding L0 stores into `_d` is below them (`reenc_wf`, `BytesInj.of_le_trans`), as for
  `field` (`sim_derefLoad`);
- store: R's store through the image (`resolve_inj_of_checkPtr`, `store_inj` with its `hdisj`
  from `LiveDisjoint`) keeps `MemInj`; the stored-to allocation is mapped, so it is no private
  local's (`ι` drops those), and R's frame is untouched: every `LocalRel` survives
  (`sim_derefStore`, `FnRel.after_store`).
The stored bytes' provenance is the loaded bytes' (`bytesLeDefined_prov`), which keeps
`Hidden`, `ProvBounded` and the new invariant.
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Proofs.Lower.SimField
import Ryo.Proofs.Provenance
import Ryo.Check.Lower.Deref

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### The invariants the deref rules add -/

/-- A store keeps each allocation, at the same address, size and liveness. -/
theorem store_get?_bwd {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (h : m.store p bs al = .ok m') {a : AllocId} {x : Allocation} (hx : m.get? a = some x) :
    ∃ x', m'.get? a = some x' ∧ x'.addr = x.addr ∧ x'.live = x.live ∧
      x'.data.size = x.data.size := by
  obtain ⟨hsz, hag⟩ := Ryo.Spec.Theorems.Memory.store_agree h
  obtain ⟨hlt, rfl⟩ := Array.getElem?_eq_some_iff.mp (show m.allocs[a]? = some x from hx)
  have hlt' : a < m'.allocs.size := by
    first
      | (have hs' := store_size h; omega)
      | (rw [← hsz]; exact hlt)
      | exact hsz ▸ hlt
  obtain ⟨e1, -, e3, e4, -⟩ := hag a hlt hlt'
  exact ⟨m'.allocs[a], get?_of_lt hlt', e1.symm, e3.symm, e4.symm⟩

/-- A store of bytes none of whose provenance is `Unmapped` keeps `Hidden m (Unmapped ι m)`
and `LiveDisjoint` (a store changes no allocation's address, size or liveness).

Proof: `Ryo.Spec.Theorems.Memory.store_eq_ok h`: either `m' = m`, or `m'` sets allocation `id`
to `{ m.allocs[id] with data := … }` (the data's size kept: `foldl_set_size`). So
`m'.get? a` and `m.get? a` agree on `addr`, `data.size`, `live` for every `a`
(`Array.getElem?_set`), which makes `Unmapped ι m' a ↔ Unmapped ι m a` and transfers
`LiveDisjoint` pointwise. `Hidden`: `Hidden.store_hidden hmap h hbs` gives
`Hidden m' (Unmapped ι m)`, then `Hidden.mono` with the equivalence. -/
theorem derefInv_store {ι : Inj} {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte}
    {al : Align} (hmap : Hidden m (Unmapped ι m)) (hld : LiveDisjoint m)
    (h : m.store p bs al = .ok m')
    (hbs : ∀ b ∈ bs, ∀ fr, b.provFrag = some fr → ¬ Unmapped ι m fr.prov) :
    Hidden m' (Unmapped ι m') ∧ LiveDisjoint m' := by
  have hU : ∀ a, Unmapped ι m' a → Unmapped ι m a := by
    rintro a ⟨hι, x', hx', hl', hp'⟩
    obtain ⟨x, hx, -, el, es⟩ := store_get?_fwd h hx'
    exact ⟨hι, x, hx, el.trans hl', by omega⟩
  refine ⟨(hmap.store_hidden h hbs).mono hU, ?_⟩
  intro i j a b x hi hj hla hlb h1 h2 h3 h4
  obtain ⟨a0, ha0, ea, el, es⟩ := store_get?_fwd h hi
  obtain ⟨b0, hb0, eb, el', es'⟩ := store_get?_fwd h hj
  simp only [Allocation.size] at h2 h4
  exact hld i j a0 b0 x ha0 hb0 (el.trans hla) (el'.trans hlb) (by omega)
    (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)

/-! ### Where a pointer read from memory points -/

/-- A pointer decoded from bytes with provenance `a` has a byte carrying `a`.

Proof: `Ryo.Spec.Theorems.decodePtr_eq` at `hq` (`cases` on `decodeBits bs`, the `none` case
contradicts `hq`) makes `q = ⟨_, ptrProvOf bs⟩`; `(Ryo.Spec.Theorems.ptrProvOf_iff bs a).1 ha`
gives `bs ≠ []` and `bs[0].provFrag = some ⟨a, 0⟩`; the byte is `bs[0]`
(`List.getElem_mem`). -/
theorem decodePtr_prov_mem {bs : List AbstractByte} {q : ThinPointer} {a : AllocId}
    (hq : decodePtr bs = some q) (ha : q.prov = some a) :
    ∃ b ∈ bs, ∃ fr, b.provFrag = some fr ∧ fr.prov = a := by
  rw [Ryo.Spec.Theorems.decodePtr_eq] at hq
  cases hd : decodeBits bs with
  | none => rw [hd] at hq; cases hq
  | some v =>
    rw [hd] at hq
    have hq' : (⟨v, Ryo.Spec.Theorems.ptrProvOf bs⟩ : ThinPointer) = q := Option.some.inj hq
    subst hq'
    obtain ⟨hne, hall⟩ := (Ryo.Spec.Theorems.ptrProvOf_iff bs a).1 ha
    have h0 : 0 < bs.length := by
      cases bs with
      | nil => exact absurd rfl hne
      | cons _ _ => simp
    exact ⟨bs[0], List.getElem_mem h0, ⟨a, 0⟩, hall 0 h0, rfl⟩

/-- The address of a pointer decoded from 8 bytes is below `2^64`. -/
theorem decodePtr_addr_lt {bp : List AbstractByte} {q : ThinPointer}
    (hq : decodePtr bp = some q) (hl : bp.length = 8) : q.addr < Target.ADDR_LIMIT := by
  rw [Ryo.Spec.Theorems.decodePtr_eq] at hq
  cases hd : decodeBits bp with
  | none => rw [hd] at hq; cases hq
  | some v =>
    rw [hd] at hq
    have hq' : (⟨v, Ryo.Spec.Theorems.ptrProvOf bp⟩ : ThinPointer) = q := Option.some.inj hq
    subst hq'
    have hv := Ryo.Proofs.Provenance.decodeBits_lt hd
    rw [hl] at hv
    have h64 : Target.ADDR_LIMIT = 2 ^ (8 * 8) := rfl
    rw [h64]
    exact hv

/-- **A pointer read from L0 memory never points into a private local of the frame**
(with `A = PrivAlloc ι f`, `FnRel.hidden`): its provenance is one of its bytes', and `Hidden`
excludes those. -/
theorem loaded_ptr_not_priv {m : Memory} {A : AllocId → Prop} (hh : Hidden m A)
    {pp : ThinPointer} {k : Nat} {al : Align} {bp : List AbstractByte}
    (hlp : m.load pp k al = .ok bp) {q : ThinPointer} (hq : decodePtr bp = some q) {a : AllocId}
    (ha : q.prov = some a) : ¬ A a := by
  obtain ⟨b, hb, fr, hfr, rfl⟩ := decodePtr_prov_mem hq ha
  exact hh.load hlp b hb fr hfr

/-- A pointer read from L0 memory into a live, non-empty allocation points into one `ι` maps
(the new invariant at `loaded_ptr_not_priv`). -/
theorem loaded_ptr_mapped {ι : Inj} {m : Memory} (hmap : Hidden m (Unmapped ι m))
    {pp : ThinPointer} {k : Nat} {al : Align} {bp : List AbstractByte}
    (hlp : m.load pp k al = .ok bp) {q : ThinPointer} (hq : decodePtr bp = some q) {a : AllocId}
    (ha : q.prov = some a) {x : Allocation} (hx : m.get? a = some x) (hlv : x.live = true)
    (hpos : 0 < x.data.size) : ∃ b, ι a = some b := by
  have hn := loaded_ptr_not_priv hmap hlp hq ha
  cases hι : ι a with
  | none =>
    exfalso
    apply hn
    exact ⟨hι, x, hx, hlv, hpos⟩
  | some b => exact ⟨b, rfl⟩

/-- A mapped allocation is no private local's. -/
theorem mapped_not_privAlloc {ι : Inj} {f : Spec.Frame} {a b : AllocId} (hb : ι a = some b) :
    ¬ PrivAlloc ι f a := by
  rintro ⟨_, _, _, _, h⟩
  rw [hb] at h
  cases h

/-- The deref's target: a non-empty L0 access through the loaded pointer (offset by `off`) is
in an allocation `ι` maps.

Proof: `load_eq_ok_pos hn hlo` gives the allocation `id` (`q.prov = some id`, live, the range
`[q.addr + off, q.addr + off + n)` inside it, so its size is positive: `omega` after reducing
the `ThinPointer` projections); `loaded_ptr_mapped hmap hlp hq _ (get?_of_lt hid) _ _`. -/
theorem deref_target_mapped {ι : Inj} {m : Memory} (hmap : Hidden m (Unmapped ι m))
    {pp : ThinPointer} {k : Nat} {al : Align} {bp : List AbstractByte}
    (hlp : m.load pp k al = .ok bp) {q : ThinPointer} (hq : decodePtr bp = some q)
    {off n : Nat} (hn : n ≠ 0) {al' : Align} {bs0 : List AbstractByte}
    (hlo : m.load ⟨q.addr + off, q.prov⟩ n al' = .ok bs0) :
    ∃ a b, q.prov = some a ∧ ι a = some b := by
  obtain ⟨id, hid, hprov, hlv, h1, h2, -⟩ := load_eq_ok_pos hn hlo
  have hp : q.prov = some id := hprov
  obtain ⟨b, hb⟩ := loaded_ptr_mapped hmap hlp hq hp (get?_of_lt hid) hlv (by omega)
  exact ⟨id, b, hp, hb⟩

/-- `deref_target_mapped` for a non-empty store through the loaded pointer.

Proof: `Ryo.Spec.Theorems.Memory.store_eq_ok hsto` (the zero-length case contradicts `hn`)
gives the allocation `id` (`q.prov = some id`, live, the range inside it, so its size is
positive); `loaded_ptr_mapped hmap hlp hq _ (get?_of_lt hid) _ _`. -/
theorem deref_store_target_mapped {ι : Inj} {m : Memory} (hmap : Hidden m (Unmapped ι m))
    {pp : ThinPointer} {k : Nat} {al : Align} {bp : List AbstractByte}
    (hlp : m.load pp k al = .ok bp) {q : ThinPointer} (hq : decodePtr bp = some q)
    {off : Nat} {al' : Align} {bs : List AbstractByte} (hn : bs ≠ []) {m' : Memory}
    (hsto : m.store ⟨q.addr + off, q.prov⟩ bs al' = .ok m') :
    ∃ a b, q.prov = some a ∧ ι a = some b := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
    ⟨_, hl, -⟩ | ⟨id, hid, _, hl, hprov, hlv, h1, h2, -, -⟩
  · exact absurd (List.eq_nil_of_length_eq_zero hl) hn
  · have hp : q.prov = some id := hprov
    obtain ⟨b, hb⟩ := loaded_ptr_mapped hmap hlp hq hp (get?_of_lt hid) hlv (by omega)
    exact ⟨id, b, hp, hb⟩

/-! ### L0: places through a deref -/

/-- `ptrOffsetInbounds` by a natural offset, run to success, stays below `ADDR_LIMIT`. -/
theorem runOn_ptrOffsetInbounds_lt {o : Spec.Oracle} {s s1 : Spec.State} {q q' : ThinPointer}
    {off : Nat} (h : runOn (ptrOffsetInbounds q (off : Int)) o s = (.ok q', s1)) :
    q.addr + off < Target.ADDR_LIMIT := by
  unfold ptrOffsetInbounds at h
  obtain ⟨_, _, -, h2⟩ := runOn_bind_ok h
  obtain ⟨_, _, -, h4⟩ := runOn_bind_ok h2
  dsimp only at h4
  split at h4
  next =>
    obtain ⟨_, _, h5, -⟩ := runOn_bind_ok h4
    rw [runOn_throwUb] at h5
    exact (prod_err_ok h5).elim
  next hc =>
    first
      | (simp only [Bool.or_eq_true, decide_eq_true_eq, not_or] at hc; omega)
      | (simp at hc; omega)
      | (revert hc; simp; omega)

/-- `runOn_offset_place` for a place of any alignment flag, with the address bound. -/
theorem runOn_offset_place_al {o : Spec.Oracle} {s s1 : Spec.State} {q : ThinPointer}
    {al : Bool} {off : Nat} {fty : Spec.Ty} {r : Spec.Place × Spec.Ty}
    (h : runOn (ptrOffsetInbounds q (off : Int) >>= fun q' =>
      pure ((⟨q'.widen, al⟩ : Spec.Place), fty)) o s = (.ok r, s1)) :
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩, fty) ∧ s1 = s ∧
      q.addr + off < Target.ADDR_LIMIT := by
  obtain ⟨q', s2, h1, h2⟩ := runOn_bind_ok h
  have hlt := runOn_ptrOffsetInbounds_lt h1
  obtain ⟨rfl, hs2⟩ := runOn_ptrOffsetInbounds_ok h1
  rw [runOn_pure] at h2
  obtain ⟨hr, hs1⟩ := prod_ok_inj h2
  exact ⟨hr.symm, hs1.symm.trans hs2, hlt⟩

/-- `runOn_projectPlace_field` for a place of any alignment flag, with the address bound. -/
theorem runOn_projectPlace_field_al {o : Spec.Oracle} {s s1 : Spec.State} {q : ThinPointer}
    {al : Bool} {t fty ann : Spec.Ty} {fi off : Nat} {r : Spec.Place × Spec.Ty}
    (hf : fieldOf t fi = some (off, fty))
    (h : runOn (projectPlace ⟨q.widen, al⟩ t (.field fi ann)) o s = (.ok r, s1)) :
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩, fty) ∧ s1 = s ∧
      q.addr + off < Target.ADDR_LIMIT := by
  unfold fieldOf at hf
  split at hf
  next fields head tail =>
    have e : projectPlace ⟨q.widen, al⟩ (.tuple fields head tail) (.field fi ann) =
        (ptrOffsetInbounds q (off : Int) >>= fun q' =>
          pure ((⟨q'.widen, al⟩ : Spec.Place), fty)) := by
      first
        | (simp only [projectPlace, hf]; done)
        | (simp only [projectPlace, hf]; rfl)
        | simp [projectPlace, hf]
    rw [e] at h
    exact runOn_offset_place_al h
  next fields a b c =>
    have e : projectPlace ⟨q.widen, al⟩ (.union fields a b c) (.field fi ann) =
        (ptrOffsetInbounds q (off : Int) >>= fun q' =>
          pure ((⟨q'.widen, al⟩ : Spec.Place), fty)) := by
      first
        | (simp only [projectPlace, hf]; done)
        | (simp only [projectPlace, hf]; rfl)
        | simp [projectPlace, hf]
    rw [e] at h
    exact runOn_offset_place_al h
  · cases hf

/-- `runOn_foldlM_fields` (SimField) for a place of any alignment flag, also bounding the final
address: the field steps keep the flag (`{ pl with ptr := … }`) and each
`ptrOffsetInbounds` checks its result is below `ADDR_LIMIT`.

Proof: as `runOn_foldlM_fields`, by induction on `projs`, with `runOn_projectPlace_field` and
`runOn_offset_place` restated for `⟨q.widen, al⟩` (their proofs unchanged: `projectPlace`'s
field cases are `ptrOffsetInbounds q off >>= fun q' => pure ({ pl with ptr := q'.widen }, fty)`,
and `{ (⟨q.widen, al⟩ : Place) with ptr := q'.widen } = ⟨q'.widen, al⟩` by `rfl`). The bound:
`[]` is the hypothesis (`off = 0`); a step's `ptrOffsetInbounds` succeeds only past its
`if a < 0 || a ≥ Target.ADDR_LIMIT` (`runOn_ptrOffsetInbounds_ok` extended with the bound),
and the last step's bound is the conclusion's (`Nat.add_assoc`). -/
theorem runOn_foldlM_fields_al {o : Spec.Oracle}
    {F : Spec.Place × Spec.Ty → ProjElem → SemM (Spec.Place × Spec.Ty)} (projs : List ProjElem) :
    ∀ {q : ThinPointer} {al : Bool} {t ty : Spec.Ty} {off : Nat} {s s1 : Spec.State}
      {r : Spec.Place × Spec.Ty},
    fieldPath t projs = some (off, ty) →
    runOn (projs.foldlM F (⟨q.widen, al⟩, t)) o s = (.ok r, s1) →
    (∀ x e, F x e = projectPlace x.1 x.2 e) →
    r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩, ty) ∧ s1 = s ∧
      (q.addr < Target.ADDR_LIMIT → q.addr + off < Target.ADDR_LIMIT) := by
  induction projs with
  | nil =>
    intro q al t ty off s s1 r hp h _
    simp only [fieldPath, Option.some.injEq, Prod.mk.injEq] at hp
    obtain ⟨rfl, rfl⟩ := hp
    rw [List.foldlM_nil, runOn_pure] at h
    obtain ⟨hr, hs⟩ := prod_ok_inj h
    exact ⟨by rw [← hr, Nat.add_zero], hs.symm, fun hq => by omega⟩
  | cons e ps ih =>
    intro q al t ty off s s1 r hp h hF
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
          obtain ⟨rfl, hs2, hlt1⟩ := runOn_projectPlace_field_al hfo h1
          obtain ⟨hr, hs1, hb⟩ := ih hps h2 hF
          refine ⟨by rw [hr, Nat.add_assoc], by rw [hs1, hs2], fun _ => ?_⟩
          have e1 : (⟨q.addr + o1, q.prov⟩ : ThinPointer).addr = q.addr + o1 := rfl
          have hb1 := hb hlt1
          omega
        · cases hp
      · cases hp
    all_goals simp [fieldPath] at hp

/-- A computation that, when it succeeds, leaves the state alone and returns a value satisfying
`P` (for the deref projection's checks, which only read memory). -/
structure KeepPost {α : Type} (x : SemM α) (P : α → Prop) : Prop where
  run' : ∀ o s a s', runOn x o s = (.ok a, s') → s' = s ∧ P a

theorem KeepPost.run {α : Type} {x : SemM α} {P : α → Prop} {o : Spec.Oracle}
    {s s' : Spec.State} {a : α} (h : runOn x o s = (.ok a, s')) (hp : KeepPost x P) :
    s' = s ∧ P a :=
  hp.run' o s a s' h

theorem KeepPost.pure' {α : Type} {a : α} {P : α → Prop} (h : P a) :
    KeepPost (pure a : SemM α) P := by
  constructor
  intro o s b s' hx
  rw [runOn_pure] at hx
  obtain ⟨rfl, rfl⟩ := prod_ok_inj hx
  exact ⟨rfl, h⟩

theorem KeepPost.bind' {α β : Type} {x : SemM α} {f : α → SemM β} {P : β → Prop}
    (hx : KeepPost x (fun _ => True)) (hf : ∀ a, KeepPost (f a) P) : KeepPost (x >>= f) P := by
  constructor
  intro o s b s' h
  obtain ⟨a, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨rfl, -⟩ := hx.run' o s a s2 h1
  exact (hf a).run' o _ b s' h2

theorem KeepPost.getMem' : KeepPost SemM.getMem (fun _ => True) := by
  constructor
  intro o s a s' h
  rw [runOn_getMem0] at h
  obtain ⟨-, rfl⟩ := prod_ok_inj h
  exact ⟨rfl, trivial⟩

theorem KeepPost.liftE' {α : Type} {e : Except Outcome α} :
    KeepPost (SemM.liftE e) (fun _ => True) := by
  constructor
  intro o s a s' h
  exact ⟨(runOn_liftE_ok h).2, trivial⟩

theorem KeepPost.throwUb' {α : Type} {msg : String} {P : α → Prop} :
    KeepPost (throwUb msg : SemM α) P := by
  constructor
  intro o s a s' h
  rw [runOn_throwUb] at h
  exact (prod_err_ok h).elim

theorem KeepPost.throwIllFormed' {α : Type} {msg : String} {P : α → Prop} :
    KeepPost (throwIllFormed msg : SemM α) P := by
  constructor
  intro o s a s' h
  rw [runOn_throwIllFormed] at h
  exact (prod_err_ok h).elim

theorem KeepPost.sizeAlignOf' {ty : Spec.Ty} {md : Option PointerMeta} :
    KeepPost (sizeAlignOf ty md) (fun _ => True) := by
  constructor
  intro o s a s' h
  unfold sizeAlignOf at h
  obtain ⟨m, s2, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_getMem0] at h1
  obtain ⟨-, rfl⟩ := prod_ok_inj h1
  split at h2
  · rw [runOn_pure] at h2
    exact ⟨(prod_ok_inj h2).2.symm, trivial⟩
  · rw [runOn_throwUb] at h2
    exact (prod_err_ok h2).elim

/-- The deref projection of a thin pointer place, run to success: the place's 8 bytes decode
to `q`, and the result is `q` at the pointee type, with some alignment flag, the state
unchanged (the `safePointee` and `sizeAlignOf` checks only read memory: `KeepPost`). -/
theorem runOn_projectPlace_deref {o : Spec.Oracle} {s s1 : Spec.State} {pl : Spec.Place}
    {pt : PtrType} {valid : ValidRange} {pointee : Spec.Ty} {r : Spec.Place × Spec.Ty}
    (hk : pt.metaKind = .none)
    (h : runOn (projectPlace pl (.ptr pt valid) (.deref pointee)) o s = (.ok r, s1)) :
    ∃ bp q al, s.mem.load pl.ptr.thin 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      r = (⟨q.widen, al⟩, pointee) ∧ s1 = s := by
  try simp only [projectPlace] at h
  obtain ⟨v, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨hv, hs2⟩ := runOn_placeLoad_ok h1
  obtain ⟨bp, hlp, hd⟩ := typedLoad_inv (size?_ptr_thin hk) hv
  obtain ⟨q, -, hq, rfl⟩ := decode_ptr_thin_inv hk hd
  rw [hs2] at h2
  obtain ⟨hs1, al, hr⟩ := KeepPost.run
    (P := fun r : Spec.Place × Spec.Ty => ∃ al, r = (⟨q.widen, al⟩, pointee)) h2 (by
      repeat
        first
          | exact KeepPost.getMem'
          | exact KeepPost.liftE'
          | exact KeepPost.sizeAlignOf'
          | exact KeepPost.throwUb'
          | exact KeepPost.throwIllFormed'
          | exact KeepPost.pure' trivial
          | exact KeepPost.pure' ⟨_, rfl⟩
          | apply KeepPost.bind'
          | intro _
          | dsimp only
          | split)
  exact ⟨bp, q, al, hlp, hq, hr, hs1⟩

/-- A place `(*_p).fields` evaluated: `_p`'s 8 bytes decode to the thin pointer `q`, the place
is `q` offset by the fields' offsets, at the projected type, below `ADDR_LIMIT`, with some
alignment flag, the state unchanged.

Proof: `evalPlace ⟨p, .deref pointee :: fields⟩` is `localPlace p >>= fun init =>
(.deref pointee :: fields).foldlM … init` (`rfl`); `runOn_localPlace_ok hs` gives
`init = (⟨pp.widen, true⟩, .ptr pt valid)` (`htp`); `List.foldlM_cons` and `runOn_bind_ok`
split off `projectPlace ⟨pp.widen, true⟩ (.ptr pt valid) (.deref pointee)`: its `placeLoad`
(`runOn_placeLoad_ok`, then `typedLoad_inv (size?_ptr_thin hk)`) loads 8 bytes `bp` that
decode (`decode_ptr_thin_inv hk`) to `.ptr ⟨q, none⟩` with `decodePtr bp = some q`; the
`safePointee` check is a `liftE` of `dereferenceable` (state unchanged, `runOn_liftE_ok`), and
`sizeAlignOf pointee none` either throws or returns, leaving the state; the result is
`(⟨q.widen, al⟩, pointee)`. Then `runOn_foldlM_fields_al fields hpath`, whose bound hypothesis
is `q.addr < 2^64` from `Ryo.Proofs.Provenance.decodeBits_lt` (`decodePtr_eq`: `q.addr` is
`decodeBits bp`'s value, `bp.length = 8`). -/
theorem runOn_evalPlace_deref {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p : Local} {pointee ty : Spec.Ty}
    {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off : Nat}
    {r : Spec.Place × Spec.Ty}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (h : runOn (evalPlace ⟨p, .deref pointee :: fields⟩) o s = (.ok r, s1)) :
    ∃ pp bp q al, f.locals[p]? = some (some pp) ∧ s.mem.load pp 8 .one = .ok bp ∧
      decodePtr bp = some q ∧ q.addr + off < Target.ADDR_LIMIT ∧
      r = (⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩, ty) ∧ s1 = s := by
  have e : evalPlace ⟨p, .deref pointee :: fields⟩ = (localPlace p >>= fun init =>
      (ProjElem.deref pointee :: fields).foldlM (fun (pl, ty) pe => projectPlace pl ty pe)
        init) := rfl
  rw [e] at h
  obtain ⟨init, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, tp, hpp, htp', hinit, hs2⟩ := runOn_localPlace_ok hs h1
  subst hinit
  have e2 : tp = .ptr pt valid := Option.some.inj (htp'.symm.trans htp)
  subst e2
  rw [hs2, List.foldlM_cons] at h2
  obtain ⟨x, s3, h3, h4⟩ := runOn_bind_ok h2
  have h3' : runOn (projectPlace ⟨pp.widen, true⟩ (.ptr pt valid) (.deref pointee)) o s =
      (.ok x, s3) := h3
  obtain ⟨bp, q, al, hlp, hq, rfl, hs3⟩ := runOn_projectPlace_deref hk h3'
  rw [hs3] at h4
  obtain ⟨hr, hs1, hb⟩ := runOn_foldlM_fields_al fields hpath h4 (fun ⟨_, _⟩ _ => rfl)
  have hl8 : bp.length = 8 := load_length hlp
  exact ⟨pp, bp, q, al, hpp, hlp, hq, hb (decodePtr_addr_lt hq hl8), hr, hs1⟩

/-- `_d = copy (*_p).fields` run to success, in memory terms (the analogue of `field_mem`).

Proof: as `field_mem`, with `runOn_evalPlace_deref` for `runOn_evalPlace_fields`; the
`placeLoad` of the place `⟨_, al⟩` succeeds only if `al = true` but `runOn_placeLoad_ok` does
not need it. -/
theorem derefLoad_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d p : Local} {pointee ty : Spec.Ty}
    {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off n : Nat}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (htd : f.body.locals[d]? = some ty) (hn : ty.size? = some n)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.copy ⟨p, .deref pointee :: fields⟩)))) o
      s = (.ok (), s')) :
    ∃ pd pp bp q bs0 v bsd, f.locals[d]? = some (some pd) ∧ f.locals[p]? = some (some pp) ∧
      s.mem.load pp 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.load ⟨q.addr + off, q.prov⟩ n .one = .ok bs0 ∧ ty.decode bs0 = some v ∧
      ty.encode v = some bsd ∧ s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  obtain ⟨pd, td, rv, s1, hpd, htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  have e : evalOperand (.copy ⟨p, .deref pointee :: fields⟩) =
      (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x => match x with
        | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := rfl
  rw [e] at hev
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, rfl, hs2⟩ :=
    runOn_evalPlace_deref hs htp hk hpath h1
  have h2' : runOn (placeLoad ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ ty >>=
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
  exact ⟨pd, pp, bp, q, bs0, v, bsd, hpd, hpp, hlp, hq, hlim, hlo, hd, hen, hsto,
    by rw [hs1']⟩

/-- `(*_p).fields = copy _a` run to success, in memory terms: L0 loads `_p`'s pointer `q`, then
`_a`'s `n` bytes, decodes them at `ty` and stores the re-encoding at `q + off`.

Proof: `evalStatement (.assign pl (.use op))` is `evalPlace pl >>= fun (pl, ty) =>
evalRvalue (.use op) ty >>= fun v => placeStore pl v ty` (as in `assign_use_inv`);
`runOn_evalPlace_deref hs htp hk hpath` for the place (state unchanged), then `evalRvalue
(.use _)` is `evalOperand _ >>= pure ∘ Prod.fst`, `runOn_evalOperand_copy hs` (`typedLoad` at
`_a`'s type, `ty` by `hta`; `typedLoad_inv hn`), `runOn_placeStore_ok` and `typedStore_inv`
(the store's state is `{ s with mem := _ }`, so the stack is unchanged). -/
theorem derefStore_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {p a : Local} {pointee ty : Spec.Ty}
    {fields : List ProjElem} {pt : PtrType} {valid : ValidRange} {off n : Nat}
    (htp : f.body.locals[p]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
    (hpath : fieldPath pointee fields = some (off, ty))
    (hta : f.body.locals[a]? = some ty) (hn : ty.size? = some n)
    (h : runOn (evalStatement (.assign ⟨p, .deref pointee :: fields⟩ (.use (.copy ⟨a, []⟩)))) o
      s = (.ok (), s')) :
    ∃ pp pa bp q bsa v bsd, f.locals[p]? = some (some pp) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load pp 8 .one = .ok bp ∧ decodePtr bp = some q ∧
      q.addr + off < Target.ADDR_LIMIT ∧
      s.mem.load pa n .one = .ok bsa ∧ ty.decode bsa = some v ∧ ty.encode v = some bsd ∧
      s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  have e : evalStatement (.assign ⟨p, .deref pointee :: fields⟩ (.use (.copy ⟨a, []⟩))) =
      (evalPlace ⟨p, .deref pointee :: fields⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.use (.copy ⟨a, []⟩)) ty >>= fun v => placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨pp, bp, q, al, hpp, hlp, hq, hlim, rfl, hs1⟩ :=
    runOn_evalPlace_deref hs htp hk hpath h1
  have h2' : runOn (evalRvalue (.use (.copy ⟨a, []⟩)) ty >>= fun v =>
      placeStore ⟨(⟨q.addr + off, q.prov⟩ : ThinPointer).widen, al⟩ v ty) o s1 =
      (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.use (.copy ⟨a, []⟩)) ty =
      (evalOperand (.copy ⟨a, []⟩) >>= fun r => pure r.1) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨rr, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨hv, hs3⟩ := prod_ok_inj h6
  obtain ⟨pa, ta, w, hpa, hta', hlw, hrr, hs3'⟩ := runOn_evalOperand_copy hs h5
  subst hrr
  have e3 : ta = ty := Option.some.inj (hta'.symm.trans hta)
  subst e3
  obtain ⟨bsa, hla, hd⟩ := typedLoad_inv hn hlw
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  have hs2 : s2 = s := hs3.symm.trans hs3'
  rw [hs2, ← hv] at hst
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  subst hs'
  exact ⟨pp, pa, bp, q, bsa, w, bsd, hpp, hpa, hlp, hq, hlim, hla, hd, hen, hsto,
    by rw [hs2]⟩

/-! ### R: the handlers -/

/-- The footprint of a `load` handler at `n` bytes (`Inline.fp_load`). -/
def loadFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "m" 8], writes := [Ryo.Proofs.Inline.rdA "d" n],
    derefs := [⟨PtrSrc.mem "m", .bytes n, .read, false⟩] }

/-- The footprint of a `store` handler at `n` bytes (`Inline.fp_load`). -/
def storeFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "m" 8, Ryo.Proofs.Inline.rdA "s" n],
    derefs := [⟨PtrSrc.mem "m", .bytes n, .write, false⟩] }

/-- R's `wrappingOffset` by `off` of a pointer at L0's address, when L0's offset address is
below `ADDR_LIMIT`: the same address. -/
theorem wrappingOffset_addr {q q1 : ThinPointer} {off : Nat} (he : q.addr = q1.addr)
    (hlim : q.addr + off < Target.ADDR_LIMIT) :
    (q1.wrappingOffset (off : Int)).addr = q.addr + off := by
  show (((q1.addr : Int) + ((off : Nat) : Int)) % ((Target.ADDR_LIMIT : Nat) : Int)).toNat =
    q.addr + off
  rw [← he]
  have h1 : (q.addr : Int) + ((off : Nat) : Int) < ((Target.ADDR_LIMIT : Nat) : Int) := by
    omega
  first
    | (rw [Int.emod_eq_of_lt (by omega) h1]; omega)
    | (simp only [Target.ADDR_LIMIT] at h1 ⊢; omega)

/-- The forward direction of `Inline.opSem_load`.

Proof: as `opSem_mov_fwd`: the footprint is `Inline.fp_load`'s (`footprint_eq hh`,
`tySize_of_parse hty`), `prepare` succeeds (`ho`, the operands fit by `hfits`), `readAll` reads
`m`'s 8 bytes `bp` at `p` (`Val.slotOff (.mem p k) = p`), `kindSem .load` decodes them
(`Env.memPtr`, `asPtr`: `hq`) and loads at `q.wrappingOffset k` from the frame-erased state,
whose `load` is `st.load` (it reads only `mem` and `exposed`: `rfl`), and `commit` writes `bs`
at `d` (`hlen`, `hw`). -/
theorem opSem_load_fwd {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat}
    {sg : Bool} {d p k : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.load, [ty], r⟩) (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"m", .mem⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ p ∧ p < 2 ^ 31 ∧ -2 ^ 31 ≤ k ∧ k < 2 ^ 31)
    {bp : List AbstractByte} (hrp : st.readFrame p 8 = .ok bp) {q : ThinPointer}
    (hq : decodePtr bp = some q) {bs : List AbstractByte}
    (hl : st.load (q.wrappingOffset k) n = .ok bs) (hlen : bs.length = n)
    (hw : st.writeFrame d bs = .ok st') :
    opSem op [.slot d, .mem p k] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, hp1, hp2, hk1, hk2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfm : Val.fits .mem (.mem p k) = true := by
    simp only [Val.fits, Bool.and_eq_true, decide_eq_true_eq]
    first | exact ⟨⟨⟨hp1, hp2⟩, hk1⟩, hk2⟩ | exact ⟨hp1, hp2, hk1, hk2⟩ | omega
  have hfp : footprint op = some (loadFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_load (ps := []) (Ryo.Proofs.Inline.tySize_of_parse hty)).1
  have hprep : prepare op [.slot d, .mem p k] =
      .ok (⟨.load, [ty], r⟩, loadFp n, opndVal op.info [.slot d, .mem p k]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfm])]
    rfl
  have hvm : opndVal op.info [.slot d, .mem p k] "m" = some (.mem p k) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .mem p k] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (loadFp n) (opndVal op.info [.slot d, .mem p k]) st = .ok [("m", bp)] := by
    simp only [readAll, loadFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvm, Val.slotOff, Extent.eval, hrp,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hl' : OpSem.State.load { st with frame := fun _ => .uninit } (q.wrappingOffset k) n =
      .ok bs := hl
  have hk : kindSem .load [ty] (mkEnv [("m", bp)] (opndVal op.info [.slot d, .mem p k]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", bs)] } := by
    simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.memPtr, Env.ptr, asPtr, hq,
      hvm, hl', hl, out, bind, Except.bind, pure, Except.pure]
  have hc : commit (loadFp n) (opndVal op.info [.slot d, .mem p k]) st [("d", bs)] =
      .ok st' := by
    simp only [commit, loadFp, List.foldlM_cons, List.foldlM_nil]
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

/-- The forward direction of `Inline.opSem_store`.

Proof: as `opSem_load_fwd`, with `Inline.fp_load`'s second footprint (reads `m` and `s`, no
frame writes); `kindSem .store` stores `bs` at `q.wrappingOffset k` into `st.mem` (`hst`), and
`commit` of no writes returns `{ st with mem := mem' }`. -/
theorem opSem_store_fwd {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat}
    {sg : Bool} {p k s : Int} {st : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.store, [ty], r⟩) (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ p ∧ p < 2 ^ 31 ∧ -2 ^ 31 ≤ k ∧ k < 2 ^ 31 ∧ -2 ^ 31 ≤ s ∧ s < 2 ^ 31)
    {bp : List AbstractByte} (hrp : st.readFrame p 8 = .ok bp) {q : ThinPointer}
    (hq : decodePtr bp = some q) {bs : List AbstractByte} (hrs : st.readFrame s n = .ok bs)
    {mem' : Memory} (hst : st.store st.mem (q.wrappingOffset k) bs = .ok mem') :
    opSem op [.mem p k, .slot s] st ch = .ok (.next, { st with mem := mem' }) := by
  obtain ⟨hp1, hp2, hk1, hk2, hs1, hs2⟩ := hfits
  have hfs := slot_fits hs1 hs2
  have hfm : Val.fits .mem (.mem p k) = true := by
    simp only [Val.fits, Bool.and_eq_true, decide_eq_true_eq]
    first | exact ⟨⟨⟨hp1, hp2⟩, hk1⟩, hk2⟩ | exact ⟨hp1, hp2, hk1, hk2⟩ | omega
  have hfp : footprint op = some (storeFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact (Ryo.Proofs.Inline.fp_load (ps := []) (Ryo.Proofs.Inline.tySize_of_parse hty)).2
  have hprep : prepare op [.mem p k, .slot s] =
      .ok (⟨.store, [ty], r⟩, storeFp n, opndVal op.info [.mem p k, .slot s]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfs, hfm])]
    rfl
  have hvm : opndVal op.info [.mem p k, .slot s] "m" = some (.mem p k) := by
    simp [opndVal, ho]
  have hvs : opndVal op.info [.mem p k, .slot s] "s" = some (.slot s) := by
    simp [opndVal, ho]
  have hrd : readAll (storeFp n) (opndVal op.info [.mem p k, .slot s]) st =
      .ok [("m", bp), ("s", bs)] := by
    simp only [readAll, storeFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvm, hvs, Val.slotOff, Extent.eval, hrp, hrs,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hst' : OpSem.State.store { st with frame := fun _ => .uninit } st.mem
      (q.wrappingOffset k) bs = .ok mem' := hst
  have hk : kindSem .store [ty]
      (mkEnv [("m", bp), ("s", bs)] (opndVal op.info [.mem p k, .slot s]) st ch) =
      .ok { mem := mem' } := by
    simp [kindSem, mkEnv, Env.memPtr, Env.ptr, asPtr, hq, hvm, hst', hst, bind, Except.bind,
      pure, Except.pure]
  have hc : commit (storeFp n) (opndVal op.info [.mem p k, .slot s]) { st with mem := mem' } [] =
      .ok { st with mem := mem' } := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  all_goals first
    | rfl
    | (rw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)
    | simp [hc]

/-! ### The handler steps against the relation -/

/-- The handler step of `load` from L0's memory facts (`derefLoad_mem`), given that the target
allocation is mapped: the `load` succeeds, keeping `MemInj`, giving `_d`'s `LocalRel` and
keeping every disjoint local's (the analogue of `sim_copyField`).

Proof: `readLocal_inj hmem hrp` (at `sp.size = 8`, `hsp ▸ hlp`) gives R's frame bytes `bp1`
with `BytesInj ι bp bp1`; `decodePtr_inj` gives `q1` with `PtrInj ι q q1`. The L0 pointer
`⟨q.addr + off, q.prov⟩` and R's `q1.wrappingOffset off` are `PtrInj`: the address is
`(q1.addr + off) % 2^64 = q.addr + off` (`hlim`, `Target.ADDR_LIMIT = 2^64`, `Int.emod_eq_of_lt`),
the provenance `q`'s. `stLoad_inj hmem _ (n ≠ 0) hmq hlo` gives R's `bs1` with
`BytesInj ι bs0 bs1`. Then exactly `sim_copyField`'s tail: `reenc_wf`, `BytesInj.of_le_trans`,
the write by `hW` (`FnRel.dstWrite`: `_d` private or escaped), `opSem_load_fwd` (with `hrfp`,
`asPtr`). -/
theorem sim_derefLoad {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {ty : Spec.Ty} {n off : Nat} (hwf : ty.wf = true) (hn : ty.size? = some n) (hpos : 0 < n)
    {sd sp : LocalSlot} (hsd : sd.size = n) (hsp : sp.size = 8)
    {pd pp q : ThinPointer} {bp bs0 bsd : List AbstractByte} {v : Value}
    (hlp : s.mem.load pp 8 .one = .ok bp) (hq : decodePtr bp = some q)
    (hmq : ∀ a, q.prov = some a → ι a ≠ none) (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hlo : s.mem.load ⟨q.addr + off, q.prov⟩ n .one = .ok bs0)
    (hdec : ty.decode bs0 = some v) (hen : ty.encode v = some bsd)
    (hsto : s.mem.store pd bsd .one = .ok s'.mem)
    (hmem : MemInj ι s.mem st.mem) (hrp : LocalRel ι fp st s.mem sp pp true)
    -- `_d`, private or escaped (`FnRel.dstWrite`)
    (hW : DstWrite ι fp st s.mem s'.mem sd pd bsd)
    -- the instruction
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.load, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"m", .mem⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sp.off ∧ sp.off < 2 ^ 31 ∧
      -2 ^ 31 ≤ (off : Int) ∧ (off : Int) < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ st', opSem opc [.slot sd.off, .mem sp.off (off : Int)] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  -- R's pointer
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hmem hrp
    (show s.mem.load pp sp.size .one = .ok bp by rw [hsp]; exact hlp)
  rw [hsp] at hrfp
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off := wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  -- R's load
  obtain ⟨bs1, hl1, hia⟩ := stLoad_inj hmem hpi (by omega) hmq hlo
  have hbl : bs0.length = n := load_length hlo
  have hle := reenc_wf hwf hn hbl hdec hen
  obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
  rw [hbl] at hlend
  have hlenb : bs1.length = n := (BytesInj.length hbs).symm.trans hlend
  -- R's write
  obtain ⟨st', hwr, -, hmi, hrd, hoth⟩ := hW bs1 hbs
  have hop := opSem_load_fwd (ch := ch) hh hty ho hfits hrfp hq1 hl1 hlenb hwr
  exact ⟨st', hop, hmi, hrd, hoth⟩

/-- The handler step of `store` from L0's memory facts (`derefStore_mem`), the target
allocation `a0` mapped to `b0`: the `store` succeeds, keeping `MemInj` and every local's
`LocalRel` (none is in `a0` unless escaped, and escaped ones relate only by shape).

Proof: `readLocal_inj hmem hrp` and `decodePtr_inj` give R's pointer `q1` (`PtrInj ι q q1`, so
`q1.prov = some b0`); `readLocal_inj hmem hra` (at `sa.size = n`) gives R's bytes `ba` with
`BytesInj ι bsa ba`, and `reenc_wf`, `BytesInj.of_le_trans` give `BytesInj ι bsd ba`. R's
`State.store` resolves `q1.wrappingOffset off` (address `q.addr + off` by `hlim`) to
`{ _ with prov := some b0 }` (`resolve_inj_of_checkPtr`, the `checkPtr` from
`Memory.store_eq_ok hsto`), so it is `st.mem.store ⟨q.addr + off, some b0⟩ ba .one`;
`store_inj hmem hqa hb0 _ _ hsto hdisj` gives it and `MemInj ι s'.mem mem'`, where `hdisj` (the
other live L0 allocations mapped to `b0` are disjoint from the stored range, which is inside
`a0`) is `hld` at any byte in both. `opSem_store_fwd` is the step. `LocalRel`s: `priv` has
`ι a' = none`, so `a' ≠ a0` and `LocalRel.store_other` keeps it (the R frame is unchanged); an
`esc` local's L0 and R allocations keep their address, size and liveness under the stores
(`Memory.store_eq_ok`). -/
theorem sim_derefStore {ι : Inj} {fp : Nat} {st : OpSem.State} {s s' : Spec.State}
    {ty : Spec.Ty} {n off : Nat} (hwf : ty.wf = true) (hn : ty.size? = some n) (hpos : 0 < n)
    {sp sa : LocalSlot} (hsp : sp.size = 8) (hsa : sa.size = n)
    {pp pa q : ThinPointer} {bp bsa bsd : List AbstractByte} {v : Value}
    (hlp : s.mem.load pp 8 .one = .ok bp) (hq : decodePtr bp = some q)
    {a0 b0 : AllocId} (hqa : q.prov = some a0) (hb0 : ι a0 = some b0)
    (hlim : q.addr + off < Target.ADDR_LIMIT)
    (hla : s.mem.load pa n .one = .ok bsa) (hdec : ty.decode bsa = some v)
    (hen : ty.encode v = some bsd)
    (hsto : s.mem.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok s'.mem)
    (hld : LiveDisjoint s.mem)
    (hmem : MemInj ι s.mem st.mem) (hrp : LocalRel ι fp st s.mem sp pp true)
    (hra : LocalRel ι fp st s.mem sa pa true)
    -- the instruction
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.store, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ sp.off ∧ sp.off < 2 ^ 31 ∧ -2 ^ 31 ≤ (off : Int) ∧ (off : Int) < 2 ^ 31 ∧
      -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ mem', opSem opc [.mem sp.off (off : Int), .slot sa.off] st ch =
        .ok (.next, { st with mem := mem' }) ∧
      MemInj ι s'.mem mem' ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv →
        LocalRel ι fp { st with mem := mem' } s'.mem slot p lv := by
  -- R's pointer and stored bytes
  obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hmem hrp
    (show s.mem.load pp sp.size .one = .ok bp by rw [hsp]; exact hlp)
  rw [hsp] at hrfp
  obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra
    (show s.mem.load pa sa.size .one = .ok bsa by rw [hsa]; exact hla)
  rw [hsa] at hrfa
  have hbl : bsa.length = n := load_length hla
  have hle := reenc_wf hwf hn hbl hdec hen
  obtain ⟨hbs, hlend⟩ := BytesInj.of_le_trans hle hia
  have hlenba : ba.length = bsd.length := (BytesInj.length hbs).symm
  have hN : bsd.length ≠ 0 := by omega
  have hP0 : (⟨q.addr + off, q.prov⟩ : ThinPointer).addr = q.addr + off := rfl
  have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off :=
    wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  -- the stored-to allocation
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
    ⟨_, hl0, -⟩ | ⟨id, hid, _, _, hprov, hlv, h1, h2, -, -⟩
  · exact absurd hl0 hN
  have hia0 : id = a0 := Option.some.inj (hprov.symm.trans hqa)
  have hbid : ι id = some b0 := by rw [hia0]; exact hb0
  -- R's store resolves to `b0`
  have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := s.mem)
    (p := ⟨q.addr + off, q.prov⟩) (len := ba.length)
    (r := some (id, (⟨q.addr + off, q.prov⟩ : ThinPointer).addr - s.mem.allocs[id].addr))).mpr
    (.inr ⟨id, hid, by omega, hprov, hlv, h1, by rw [hlenba]; exact h2, rfl⟩)
  have hres := resolve_inj_of_checkPtr (st := st) hmem hpi hprov hbid (by omega) hc
  have hal : Align.one.isAligned (⟨q.addr + off, q.prov⟩ : ThinPointer).addr = true := by
    simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
  -- the other L0 allocations in `b0` are apart from the stored range (`LiveDisjoint`)
  have hdisj : ∀ a' x', s.mem.get? a' = some x' → x'.live = true → ι a' = some b0 → a' ≠ a0 →
      x'.size = 0 ∨ x'.addr + x'.size ≤ (⟨q.addr + off, q.prov⟩ : ThinPointer).addr ∨
      (⟨q.addr + off, q.prov⟩ : ThinPointer).addr + bsd.length ≤ x'.addr := by
    intro a' x' hx' hl' _ hne
    show x'.size = 0 ∨ x'.addr + x'.size ≤ q.addr + off ∨ q.addr + off + bsd.length ≤ x'.addr
    simp only [Allocation.size]
    by_cases g0 : x'.data.size = 0
    · exact .inl g0
    by_cases g1 : x'.addr + x'.data.size ≤ q.addr + off
    · exact .inr (.inl g1)
    by_cases g2 : q.addr + off + bsd.length ≤ x'.addr
    · exact .inr (.inr g2)
    exfalso
    apply hne
    rw [← hia0]
    rcases Nat.le_total x'.addr (q.addr + off) with hle' | hle'
    · exact hld a' id x' s.mem.allocs[id] (q.addr + off) hx' (get?_of_lt hid) hl' hlv hle'
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
    · exact hld a' id x' s.mem.allocs[id] x'.addr hx' (get?_of_lt hid) hl' hlv (Nat.le_refl _)
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
  obtain ⟨m1', hst1, hmi⟩ := store_inj (p := ⟨q.addr + off, q.prov⟩) hmem hqa hb0 hbs hal hsto
    hdisj
  have hPeq : ({ q1.wrappingOffset (off : Int) with prov := some b0 } : ThinPointer) =
      { (⟨q.addr + off, q.prov⟩ : ThinPointer) with prov := some b0 } := by
    show (⟨(q1.wrappingOffset (off : Int)).addr, some b0⟩ : ThinPointer) = ⟨q.addr + off, some b0⟩
    rw [hwo]
  have hRst : st.store st.mem (q1.wrappingOffset (off : Int)) ba = .ok m1' := by
    unfold OpSem.State.store
    rw [Ryo.Proofs.Inline.liftOutcome_ok, hres, hPeq]
    exact hst1
  have hop := opSem_store_fwd (ch := ch) hh hty ho hfits hrfp hq1 hrfa hRst
  refine ⟨m1', hop, hmi, ?_⟩
  intro slot p lv hr
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    -- `a` is unmapped, so it is not the stored-to allocation
    have hne : (⟨q.addr + off, q.prov⟩ : ThinPointer).prov ≠ some a := by
      show q.prov ≠ some a
      rw [hqa]
      intro he
      have e : a0 = a := Option.some.inj he
      rw [e, hι] at hb0
      cases hb0
    have hx' : s'.mem.get? a = some x := by
      rw [get?_store_other hsto (.inl hne)]
      exact hx
    exact .priv a x hp hι hx' hlive haddr hpaddr hsize hpriv hbytes
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    obtain ⟨x', hx', ea, el, es⟩ := store_get?_bwd hsto hx
    obtain ⟨y', hy', eya, eyl, eys⟩ := store_get?_bwd hst1 hy
    exact .esc a x' e y' hp hι hx' (el.trans hlive) (by rw [ea]; exact haddr)
      (by rw [ea]; exact hpaddr) (by rw [es]; exact hsize) hin hy' (eyl.trans hylive)
      (by rw [eya]; exact hyaddr) (by rw [eys]; exact hysize)

/-- After a step that changes only memory (R's and L0's, a `store` through a pointer), `FnRel`
at a `live'` below `live`.

Proof: as `FnRel.after`: `⟨⟨hmi, _⟩, hhid, hrel.unaliased, hrel.provNe, hrel.apart, _⟩`; each
local's `LocalRel` from `hrel.frame.locals`, `hloc`, then `LocalRel.weaken (hlive' l)`;
`escapedAt` reads only `escaped`, which the memory update keeps, so `hrel.esc` (unfold
`OpSem.State.escapedAt`). -/
theorem FnRel.after_store {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 m0' : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {mem' : Memory}
    {pc' : Nat} (hmi : MemInj ι m0' mem')
    (hloc : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m0 slot p lv →
      LocalRel ι s1.fp { s1.st with mem := mem' } m0' slot p lv)
    (hhid : Hidden m0' (PrivAlloc ι f))
    (hlive' : ∀ l, live' l = true → live l = true) :
    FnRel Γ ι live' f m0' { s1 with pc := pc', st := { s1.st with mem := mem' } } := by
  refine ⟨⟨hmi, ?_⟩, hhid, hrel.unaliased, hrel.provNe, hrel.apart, ?_⟩
  · intro l p hp hal
    obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
    exact ⟨slot, hsl, (hloc slot p (live l) hr).weaken (hlive' l)⟩
  · intro o e he
    apply hrel.esc o e
    first
      | exact he
      | (unfold OpSem.State.escapedAt at he ⊢; exact he)

/-! ### The lifts -/

/-- `load`'s lift: a `load` of `n` bytes through `_p` into `_d`'s private slot. Takes, beyond
`lift_field`'s hypotheses, the new invariant `hmap` (see the module comment); `derefInv_store`
(at the store into `_d`, bytes from the target's load) keeps it.

Proof: `cases hlow` (only `load` has a whole-local destination); `eval_use_place_norm ha` at
`h`; `loadInsnOk_spec hmi` and `intTyOk_spec` for the view; `derefLoad_mem hs` (with `hbody`
at `htp`, `htd`) for L0's facts; `_p` is live (`operandPlace?_mem ha`), so
`hrel.opnd hpp hsp` relates it; `deref_target_mapped hmap hlp hq _ hlo0` makes the target
mapped (`hmq`); `hrel.priv_dst hpd hsd` the destination; `offOk_spec` the fits;
`sim_derefLoad` the step. Then as `lift_field`: `Hidden` and `ProvBounded` for the stored bytes
from the target's load (`hrel.hidden.load hlo0`, `hpb.load hlo0`, `bytesLeDefined_prov`),
`hrel.after`, `step_of_view hi hsc hpe hpl hv hctl`, `opSem_out` for `escaped`, `store_size`. -/
theorem lift_derefLoad {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerDeref Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @load d p oa pointee ty fields pt valid off n sd sp i ha htp hk hpath htd hn hpos hwf hsd
      hsp hsize hoff hmi =>
    rw [eval_use_place_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := loadInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htp htd
    obtain ⟨pd, pp, bp, q, bs0, w, bsd, hpd, hpp, hlp, hq, hlim, hlo0, hd, hen, hsto, hstk⟩ :=
      derefLoad_mem hs htp hk hpath htd hn h
    have hlp' : live p = true := hlo _ (operandPlace?_mem ha)
    have hrp := hrel.opnd hpp hsp hlp'
    have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
    -- `_d` private or escaped
    have hlen0 : bsd.length = sd.size :=
      ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp
        (reenc_wf hwf hn (load_length hlo0) hd hen)).1.trans
        ((load_length hlo0).trans hsize.1.symm)
    have hW := hrel.dstWrite hld hpd hsd hpos' hlen0 hsto
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_target_mapped hmap hlp hq (by omega) hlo0
    have hmq : ∀ a, q.prov = some a → ι a ≠ none := by
      intro a ha'
      have e : a = a0 := Option.some.inj (ha'.symm.trans hqa)
      rw [e, hb0]
      simp
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨st', hop, hmi', hrd, hoth⟩ := sim_derefLoad (ch := ch) hwf hn hpos hsize.1 hsize.2
      hlp hq hmq hlim hlo0 hd hen hsto hrel.frame.mem hrp hW hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩
    have hsub := bytesLeDefined_prov (reenc_wf hwf hn (load_length hlo0) hd hen)
    -- `Hidden`: the stored provenance is the target's loaded bytes', which `Hidden` excludes
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

/-- `store`'s lift: a `store` of `_a`'s `n` bytes through `_p`. The statement assigns a
projected place, so it kills no local: the liveness after is below the liveness before
(`hlive'`, from `LiveSound.stmt` at `stmtKill _ = none`) and the statement's reads (`_p` and
`_a`, `stmtReads`) are live before. Takes the new invariant `hmap` and `LiveDisjoint`; the
load constructor is excluded by `hproj`.

Proof: `cases hlow` (`load`: `pl = ⟨d, []⟩` contradicts `hproj`); `eval_use_norm ha` at `h`;
`storeInsnOk_spec hmi`, `intTyOk_spec`; `derefStore_mem hs`; `_p` and `_a` live from `hlo`
(`simp [stmtReads, placeLocals, rvalueLocals, operandLocals]` with `local?_cases ha`), so
`hrel.opnd` relates both; `deref_store_target_mapped hmap hlp hq _ hsto` (the stored bytes
are `n > 0`: `load_length`, the re-encoding's length) gives `a0 ↦ b0`; `sim_derefStore` the
step; `Hidden` for the stored bytes
from `_a`'s load (`hrel.hidden.load hla`, `bytesLeDefined_prov`, `Hidden.store_hidden`),
`ProvBounded` likewise; `FnRel.after_store`; `step_of_view`; `store_size`. -/
theorem lift_derefStore {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerDeref Γ (.assign pl rv) [i]) (hproj : pl.proj ≠ [])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem)
    (hlo : ∀ l ∈ stmtReads (.assign pl rv), live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign pl rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | load => exact (hproj rfl).elim
  | @store p a oa pointee ty fields pt valid off n sp sa i ha htp hk hpath hta hn hpos hwf hsp
      hsa hsize hoff hmi =>
    rw [eval_use_norm ha] at h
    obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := storeInsnOk_spec hmi
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htp hta
    obtain ⟨pp, pa, bp, q, bsa, w, bsd, hpp, hpa, hlp, hq, hlim, hla, hd, hen, hsto, hstk⟩ :=
      derefStore_mem hs htp hk hpath hta hn h
    -- `_p` and `_a` are read, so live
    have hmemp : p ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) := by
      show p ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.use oa)
      simp [placeLocals]
    have hmema : a ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) := by
      show a ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.use oa)
      rcases local?_cases ha with rfl | rfl <;>
        simp [placeLocals, rvalueLocals, operandLocals]
    have hrp := hrel.opnd hpp hsp (hlo _ hmemp)
    have hra := hrel.opnd hpa hsa (hlo _ hmema)
    have hbl : bsa.length = n := load_length hla
    have hle := reenc_wf hwf hn hbl hd hen
    have hlbd : bsd.length = n := (BytesInj.of_leDefined hle).length.trans hbl
    have hne : bsd ≠ [] := by
      intro he
      rw [he, List.length_nil] at hlbd
      omega
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_store_target_mapped hmap hlp hq hne hsto
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2
    obtain ⟨mem', hop, hmi', hloc⟩ := sim_derefStore (ch := ch) hwf hn hpos hsize.2 hsize.1 hlp
      hq hqa hb0 hlim hla hd hen hsto hld hrel.frame.mem hrp hra hh hty' ho
      ⟨hf1.1, hf1.2, hf3.1, hf3.2, hf2.1, hf2.2⟩
    have hsub := bytesLeDefined_prov hle
    -- `Hidden`: the stored provenance is `_a`'s loaded bytes', which `Hidden` excludes
    have hhid := hrel.hidden.load hla
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hhid _ (List.getElem_mem hj) fr0 hf0
    have hbd := hpb.load hla
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hbd _ (List.getElem_mem hj) fr0 hf0
    exact ⟨{ s1.st with mem := mem' },
      step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
      hrel.after_store hmi' hloc (hrel.hidden.store_hidden hsto hhid') hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hla hsub⟩

end Ryo.Proofs.Lower
