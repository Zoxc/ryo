/-
Ryo.Proofs.Lower.WriteDst — writing a whole local whose slot may be escaped (M5b, aot.md §C1
"Escape"): the general form of `writeLocal_priv` (FrameRel.lean), for the rule families whose
destination used to have to be private (`hpriv`).

An escaped local `_d` (`LocalRel.esc`) lies in an R frame object `e`, its L0 allocation mapped by
`ι` to `e.id`, whose allocation `y` is at `fp + e.off`. R's `writeFrame` of `bs1` at `_d`'s
offset then writes only `y`, at `pd.addr - y.addr` (the address L0 writes at, `_d`'s), exactly as
`Memory.store` would (`WroteAt`, from `writeEscaped`'s `EscFrom`: `wroteAt_of_escFrom`), and
keeps the frame and the objects; it succeeds since `y` exists (`writeFrame_obj_ok`). L0 stores
`bs0` into `_d`'s allocation; with `BytesInj ι bs0 bs1`:
- `MemInj.wrote` (as `store_inj`): `MemInj` holds after both writes, given that no other live L0
  allocation `ι` maps to `e.id` meets the written range. L0's `LiveDisjoint` (`DerefInv`'s second
  half) gives that: `_d`'s allocation is live and is the range.
- `writeLocal_esc`: `_d` stays related (`esc`, live).
- `LocalRel.writeFrame_apart_any`: `writeFrame_apart` without its privacy premise; a local apart
  from the written range stays related, private or escaped (escaped: its allocation keeps its
  address, liveness and size, `escFrom_fwd`).
`FnRel.write_dst` puts the private (`writeLocal_priv`) and escaped cases together: from `FnRel`
and `LiveDisjoint`, R's write succeeds and gives what `FnRel.after` takes. A lift that used
`priv_dst` with `writeEscaped_private'` and `writeLocal_priv` uses it instead and drops its
`hpriv` (`SimDst.lean`). `Hidden`, `ProvBounded` and `DerefInv` are about L0's memory, whose
store is the same either way.
-/
import Ryo.Proofs.Lower.FnSim

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem
open Ryo.Check.Lower (LocalSlot StmtCtx)
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### R's frame writes -/

/-- A frame write: memory by `writeEscaped` (`EscFrom`), the objects kept, the frame written at
its private bytes. -/
theorem writeFrame_split {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') :
    Ryo.Proofs.Inline.EscFrom st off bs.zipIdx st.mem st'.mem ∧ st'.escaped = st.escaped ∧
      ∀ o, st'.frame o =
        if st.privateIn off bs.length o then bs.getD (o - off).toNat .uninit else st.frame o := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact ⟨Ryo.Proofs.Inline.writeEscaped_spec hm, rfl, fun _ => rfl⟩

/-- `EscFrom` keeps every allocation's address, liveness and size. -/
theorem escFrom_fwd {st : OpSem.State} {off : Int} {l : List (AbstractByte × Nat)}
    {m m' : Memory} (h : Ryo.Proofs.Inline.EscFrom st off l m m') {id : AllocId}
    {y : Allocation} (hy : m.get? id = some y) :
    ∃ y', m'.get? id = some y' ∧ y'.addr = y.addr ∧ y'.live = y.live ∧
      y'.data.size = y.data.size := by
  have hlt : id < m.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show m.allocs[id]? = some y from hy)).1
  have hlt' : id < m'.allocs.size := by rw [h.1]; exact hlt
  obtain ⟨y', hy'⟩ : ∃ y', m'.get? id = some y' := ⟨_, get?_of_lt hlt'⟩
  obtain ⟨a, ha, hae, hsz, -⟩ := h.2 id y' hy'
  have e : a = y := Option.some.inj (ha.symm.trans hy)
  rw [e] at hae hsz
  have h1 := congrArg Allocation.addr hae
  have h2 := congrArg Allocation.live hae
  exact ⟨y', hy', h1, h2, hsz⟩

/-- A frame write succeeds when the objects its bytes fall in have allocations (as
`CallLemmas.writeFrame_ok`, for the written range only). -/
theorem writeFrame_ok_of {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : ∀ k < bs.length, ∀ e, st.escapedAt (off + k) = some e → e.id < st.mem.allocs.size) :
    ∃ st', st.writeFrame off bs = .ok st' := by
  have key : ∀ (l : List (AbstractByte × Nat)) (mem : Memory),
      mem.allocs.size = st.mem.allocs.size →
      (∀ p ∈ l, ∀ e, st.escapedAt (off + p.2) = some e → e.id < st.mem.allocs.size) →
      ∃ m', l.foldlM (Ryo.Proofs.Inline.escStep st off) mem = .ok m' := by
    intro l
    induction l with
    | nil => intro mem _ _; exact ⟨mem, rfl⟩
    | cons p l ih =>
      intro mem hsz hl
      have hl' : ∀ q ∈ l, ∀ e, st.escapedAt (off + q.2) = some e →
          e.id < st.mem.allocs.size := fun q hq => hl q (List.mem_cons_of_mem _ hq)
      simp only [List.foldlM_cons]
      unfold Ryo.Proofs.Inline.escStep
      split
      · exact ih mem hsz hl'
      · rename_i e he
        have hlt : e.id < mem.allocs.size := by
          rw [hsz]; exact hl p (List.mem_cons_self ..) e he
        cases hg : mem.get? e.id with
        | none =>
          rw [get?_of_lt hlt] at hg
          cases hg
        | some a =>
          simp only [pure, Except.pure, bind, Except.bind]
          refine ih _ ?_ hl'
          first
            | (simp only [Array.size_set!]; exact hsz)
            | simp [hsz]
  obtain ⟨m', hm'⟩ := key bs.zipIdx st.mem rfl (fun p hp e he => by
    obtain ⟨hk, -⟩ := Ryo.Proofs.Inline.mem_zipIdx hp
    exact h p.2 hk e he)
  have hwe : st.writeEscaped off bs = .ok m' := hm'
  unfold OpSem.State.writeFrame
  rw [hwe]
  exact ⟨_, rfl⟩

/-- A frame write inside one escaped object with an allocation succeeds. -/
theorem writeFrame_obj_ok {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    {e : EscapedObj} {y : Allocation} (hin : ∀ k < bs.length, st.escapedAt (off + k) = some e)
    (hy : st.mem.get? e.id = some y) : ∃ st', st.writeFrame off bs = .ok st' := by
  have hlt : e.id < st.mem.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show st.mem.allocs[e.id]? = some y from hy)).1
  refine writeFrame_ok_of fun k hk e' he' => ?_
  rw [hin k hk] at he'
  cases he'
  exact hlt

/-- `m1'` is `m1` with allocation `b`'s data overwritten by `bs` at address `pa`, in the shape
`Memory.store` writes it (`foldl_set_getElem`); every other allocation unchanged. -/
def WroteAt (m1 m1' : Memory) (b : AllocId) (pa : Nat) (bs : List AbstractByte) : Prop :=
  ∀ id y, m1.get? id = some y → ∃ y', m1'.get? id = some y' ∧ (id ≠ b → y' = y) ∧
    (id = b → ∃ arr : Array AbstractByte, y' = { y with data := arr } ∧
      arr.size = y.data.size ∧ ∀ j, arr[j]? =
        if pa - y.addr + 0 ≤ j ∧ j < pa - y.addr + 0 + bs.length ∧ j < y.data.size then
          bs[j - (pa - y.addr) - 0]? else y.data[j]?)

/-- `writeEscaped` of bytes that all fall in object `e` (allocation `y`) writes `y` at the
address `pa` matching the frame offset (`hpa`).

Proof: every write `q` of the list hits `e.id` at index `pa - y.addr + q.2` (`hhit`: `hin`
names its object). Another allocation has no hit: unchanged (`EscFrom`, `Array.ext_getElem?`).
In `y`, an index in the written range has a hit (the write of `bs`'s byte there), whose byte
`EscFrom` gives; an index outside it has none, or is past the data. -/
theorem wroteAt_of_escFrom {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    {m m' : Memory} {e : EscapedObj} {y : Allocation} {pa : Nat}
    (h : Ryo.Proofs.Inline.EscFrom st off bs.zipIdx m m')
    (hin : ∀ k < bs.length, st.escapedAt (off + k) = some e) (hy : m.get? e.id = some y)
    (hpa : (pa : Int) - y.addr = off - e.off) (hya : y.addr ≤ pa) :
    WroteAt m m' e.id pa bs := by
  have hhit : ∀ q ∈ bs.zipIdx, ∀ id j, Ryo.Proofs.Inline.Hits st off q id j →
      id = e.id ∧ j = pa - y.addr + q.2 ∧ bs[q.2]? = some q.1 := by
    intro q hq id j hh
    obtain ⟨e', he', hid, hj⟩ := hh
    have hq' : bs[q.2]? = some q.1 := List.mem_zipIdx_iff_getElem?.mp hq
    have hk : q.2 < bs.length := (List.getElem?_eq_some_iff.mp hq').1
    rw [hin q.2 hk] at he'
    cases he'
    exact ⟨hid.symm, by omega, hq'⟩
  intro id y0 hy0
  have hlt : id < m.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show m.allocs[id]? = some y0 from hy0)).1
  have hlt' : id < m'.allocs.size := by rw [h.1]; exact hlt
  obtain ⟨y', hy'⟩ : ∃ y', m'.get? id = some y' := ⟨_, get?_of_lt hlt'⟩
  obtain ⟨a, ha, hae, hsz, hj⟩ := h.2 id y' hy'
  have e0 : a = y0 := Option.some.inj (ha.symm.trans hy0)
  rw [← e0]
  refine ⟨y', hy', fun hne => ?_, fun hid => ?_⟩
  · have hd : y'.data = a.data := Array.ext_getElem? fun j =>
      (hj j).1 fun q hq hh => hne (hhit q hq id j hh).1
    rw [hae, hd]
  · have e1 : a = y := by
      rw [e0]
      rw [hid] at hy0
      exact Option.some.inj (hy0.symm.trans hy)
    rw [e1] at hae hsz hj ⊢
    refine ⟨y'.data, hae, hsz, fun j => ?_⟩
    by_cases hc : pa - y.addr + 0 ≤ j ∧ j < pa - y.addr + 0 + bs.length ∧ j < y.data.size
    · rw [if_pos hc]
      have hk : j - (pa - y.addr) - 0 < bs.length := by omega
      have hq : (bs[j - (pa - y.addr) - 0], j - (pa - y.addr) - 0) ∈ bs.zipIdx :=
        List.mem_zipIdx_iff_getElem?.mpr (List.getElem?_eq_getElem hk)
      have hh : Ryo.Proofs.Inline.Hits st off
          (bs[j - (pa - y.addr) - 0], j - (pa - y.addr) - 0) id j := by
        refine ⟨e, hin _ hk, hid.symm, ?_⟩
        show (off + ((j - (pa - y.addr) - 0 : Nat) : Int) - e.off).toNat = j
        omega
      obtain ⟨q, hq', hhq, hv⟩ := (hj j).2 ⟨_, hq, hh⟩ hc.2.2
      obtain ⟨-, hjq, hq1⟩ := hhit q hq' id j hhq
      rw [hv, show j - (pa - y.addr) - 0 = q.2 by omega, hq1]
    · rw [if_neg hc]
      by_cases hjs : j < y.data.size
      · exact (hj j).1 fun q hq hh => by
          obtain ⟨-, hjq, hq1⟩ := hhit q hq id j hh
          have hk : q.2 < bs.length := (List.getElem?_eq_some_iff.mp hq1).1
          exact hc ⟨by omega, by omega, hjs⟩
      · have h1 : y'.data[j]? = none := Array.getElem?_eq_none (by omega)
        have h2 : y.data[j]? = none := Array.getElem?_eq_none (by omega)
        rw [h1, h2]

/-- A frame write apart from a local's slot leaves it related, private or escaped. -/
theorem LocalRel.writeFrame_apart_any {ι : Inj} {fp : Nat} {st st' : OpSem.State}
    {m0 : Memory} {slot : LocalSlot} {p : ThinPointer} {lv : Bool}
    (hr : LocalRel ι fp st m0 slot p lv) {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st')
    (hapart : off + bs.length ≤ slot.off ∨ slot.off + slot.size ≤ off) :
    LocalRel ι fp st' m0 slot p lv := by
  obtain ⟨hef, hesc, hfr⟩ := writeFrame_split h
  have hea : ∀ o, st'.escapedAt o = st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpv hbytes =>
    refine .priv a x hp hι hx hlive haddr hpaddr hsize
      (fun k hk => (hea _).trans (hpv k hk)) ?_
    intro hl k hk
    rw [hfr, if_neg]
    · exact hbytes hl k hk
    · simp only [OpSem.State.privateIn, Bool.and_eq_true, decide_eq_true_eq]
      intro ⟨⟨h1, h2⟩, _⟩
      omega
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    obtain ⟨y', hy', ha', hl', hs'⟩ := escFrom_fwd hef hy
    exact .esc a x e y' hp hι hx hlive haddr hpaddr hsize
      (fun k hk => (hea _).trans (hin k hk)) hy' (by rw [hl']; exact hylive)
      (by rw [ha']; exact hyaddr) (by rw [hs']; exact hysize)

/-! ### The memory relation -/

/-- An L0 store through a mapped provenance and an R write of related bytes at the same address
into the image allocation (`WroteAt`, e.g. a frame write into an escaped object) keep `MemInj`
(as `store_inj`, whose R side is a `Memory.store`). -/
theorem MemInj.wrote {ι : Inj} {m0 m1 m1' : Memory} (hm : MemInj ι m0 m1) {p : ThinPointer}
    {a b : AllocId} (ha : p.prov = some a) (hb : ι a = some b) {bs0 bs1 : List AbstractByte}
    (hbs : BytesInj ι bs0 bs1) {al0 : Align} {m0' : Memory} (h : m0.store p bs0 al0 = .ok m0')
    (hn : bs0.length ≠ 0) (hw : WroteAt m1 m1' b p.addr bs1)
    (hdisj : ∀ a' x', m0.get? a' = some x' → x'.live = true → ι a' = some b → a' ≠ a →
      x'.size = 0 ∨ x'.addr + x'.size ≤ p.addr ∨ p.addr + bs0.length ≤ x'.addr) :
    MemInj ι m0' m1' := by
  have hlen : bs0.length = bs1.length := hbs.length
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with
    ⟨_, hl, _⟩ | ⟨k, hid, _, _, hprov, hlv, h1, h2, _, rfl⟩
  · exact absurd hl hn
  · have e : k = a := Option.some.inj (hprov.symm.trans ha)
    subst k
    have hx : m0.get? a = some m0.allocs[a] := Array.getElem?_eq_getElem hid
    obtain ⟨y, hy, hxy⟩ := hm a b _ hx hb
    have hlo : y.addr ≤ m0.allocs[a].addr := hxy.lo
    have hyp : y.addr ≤ p.addr := by omega
    intro a' b' x' hx' hb'
    by_cases haa : a' = a
    · -- The stored-to L0 allocation.
      subst a'
      simp only [Memory.get?, Array.getElem?_set_self, Option.some.injEq] at hx'
      subst hx'
      have e2 : b' = b := Option.some.inj (hb'.symm.trans hb)
      subst b'
      obtain ⟨y', hy', -, hyb⟩ := hw b y hy
      obtain ⟨arr, rfl, hsz, hg⟩ := hyb rfl
      exact ⟨_, hy', allocInj_store_self hxy hbs hlv (pa := p.addr) h1
        (Ryo.Spec.Theorems.foldl_set_size bs0 0 (p.addr - m0.allocs[a].addr) m0.allocs[a].data)
        hsz
        (Ryo.Spec.Theorems.foldl_set_getElem bs0 0 (p.addr - m0.allocs[a].addr)
          m0.allocs[a].data)
        hg⟩
    · simp only [Memory.get?] at hx'
      rw [Array.getElem?_set_ne hid (Ne.symm haa)] at hx'
      obtain ⟨y2, hy2, hxy2⟩ := hm a' b' x' hx' hb'
      obtain ⟨y', hy', hne, hyb⟩ := hw b' y2 hy2
      by_cases hbb : b' = b
      · -- Another L0 allocation inside the written R allocation: apart from the write.
        obtain ⟨arr, rfl, hsz, hg⟩ := hyb hbb
        rw [hbb] at hy2 hb'
        have e3 : y2 = y := Option.some.inj (hy2.symm.trans hy)
        rw [e3] at hxy2 hsz hg hy'
        exact ⟨_, hy', allocInj_store_other hxy2 (pa := p.addr) (n := bs0.length) hyp
          (fun hl'' => hdisj a' x' hx' hl'' hb' haa) hlen.symm hsz hg⟩
      · exact ⟨y', hy', by rw [hne hbb]; exact hxy2⟩

/-! ### Writing a local -/

/-- Writing a whole escaped local: L0's store and R's frame write of related bytes keep `MemInj`
and the local related (the escaped counterpart of `writeLocal_priv`), given that no other live
L0 allocation in the object meets the slot (`hdisj`). -/
theorem writeLocal_esc {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} (hm : MemInj ι m0 st.mem)
    (a : AllocId) (x : Allocation) (e : OpSem.EscapedObj) (y : Allocation)
    (hp : p.prov = some a) (hι : ι a = some e.id) (hx : m0.get? a = some x)
    (hlive : x.live = true) (haddr : (x.addr : Int) = fp + slot.off) (hpaddr : p.addr = x.addr)
    (hsize : x.data.size = slot.size)
    (hin : ∀ k < slot.size, st.escapedAt (slot.off + k) = some e)
    (hy : st.mem.get? e.id = some y) (hylive : y.live = true)
    (hyaddr : (y.addr : Int) = fp + e.off) (hysize : y.data.size = e.size)
    (hdisj : ∀ a' x', m0.get? a' = some x' → x'.live = true → ι a' = some e.id → a' ≠ a →
      x'.size = 0 ∨ x'.addr + x'.size ≤ p.addr ∨ p.addr + slot.size ≤ x'.addr)
    (hpos : 0 < slot.size)
    {bs0 bs1 : List AbstractByte} (hbs : BytesInj ι bs0 bs1) (hlen : bs0.length = slot.size)
    {al : Align} (h0 : m0.store p bs0 al = .ok m0') (h1 : st.writeFrame slot.off bs1 = .ok st') :
    MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' slot p true := by
  have hl1 : bs1.length = slot.size := (BytesInj.length hbs).symm.trans hlen
  obtain ⟨hef, hesc, -⟩ := writeFrame_split h1
  have hea : ∀ o, st'.escapedAt o = st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]
  obtain ⟨y2, hy2, hxy⟩ := hm a e.id x hx hι
  have e2 : y2 = y := Option.some.inj (hy2.symm.trans hy)
  rw [e2] at hxy
  have hlo : y.addr ≤ x.addr := hxy.lo
  have hw : WroteAt st.mem st'.mem e.id p.addr bs1 :=
    wroteAt_of_escFrom hef (fun k hk => hin k (by omega)) hy (by omega) (by omega)
  have hmi : MemInj ι m0' st'.mem :=
    MemInj.wrote hm hp hι hbs h0 (by omega) hw (fun a' x' g1 g2 g3 g4 => by
      rw [hlen]; exact hdisj a' x' g1 g2 g3 g4)
  refine ⟨hmi, ?_⟩
  -- `_d`'s allocations after both writes: same address, liveness and size
  have hlt : a < m0.allocs.size :=
    (Array.getElem?_eq_some_iff.mp (show m0.allocs[a]? = some x from hx)).1
  have hlt' : a < m0'.allocs.size := by rw [store_size h0]; exact hlt
  obtain ⟨x0, hx0, hxa, hxl, hxs⟩ := store_get?_fwd h0 (get?_of_lt hlt')
  have e3 : x0 = x := Option.some.inj (hx0.symm.trans hx)
  rw [e3] at hxa hxl hxs
  obtain ⟨y', hy', -, hyb⟩ := hw e.id y hy
  obtain ⟨arr, rfl, hsz, -⟩ := hyb rfl
  exact .esc a m0'.allocs[a] e { y with data := arr } hp hι (get?_of_lt hlt')
    (by rw [← hxl]; exact hlive) (by rw [← hxa]; exact haddr) (by rw [← hxa]; exact hpaddr)
    (by rw [← hxs]; exact hsize) (fun k hk => (hea _).trans (hin k hk)) hy' hylive hyaddr
    (hsz.trans hysize)

/-- Writing a whole local, private or escaped (see the module comment): from `FnRel` and L0's
`LiveDisjoint`, R's frame write of bytes related to L0's stored ones succeeds and gives
`FnRel.after`'s premises.

Proof: `_d`'s `LocalRel`. Private: the write succeeds (`writeEscaped_private'`),
`writeLocal_priv`. Escaped: it succeeds (`writeFrame_obj_ok`); `hdisj` because a live L0
allocation meeting `_d`'s (live, at `pd.addr`, of `sd.size` bytes) is `_d`'s (`LiveDisjoint` at
the larger of the two starts); `writeLocal_esc`. Other locals: `LocalRel.store_other` and
`LocalRel.writeFrame_apart_any`. -/
theorem FnRel.write_dst {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) (hld : LiveDisjoint m0)
    {d : Local} {pd : ThinPointer} {sd : LocalSlot}
    (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd) (hpos : 0 < sd.size)
    {bs0 bs1 : List AbstractByte} (hbs : BytesInj ι bs0 bs1) (hlen : bs0.length = sd.size)
    {al : Align} {m0' : Memory} (h0 : m0.store pd bs0 al = .ok m0') :
    ∃ st', s1.st.writeFrame sd.off bs1 = .ok st' ∧ st'.escaped = s1.st.escaped ∧
      MemInj ι m0' st'.mem ∧ LocalRel ι s1.fp st' m0' sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m0 slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι s1.fp st' m0' slot p lv := by
  have hl1 : bs1.length = sd.size := (BytesInj.length hbs).symm.trans hlen
  have hoth : ∀ st', s1.st.writeFrame sd.off bs1 = .ok st' →
      ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m0 slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι s1.fp st' m0' slot p lv := by
    intro st' hwr slot p lv hr hne hap
    exact (LocalRel.store_other hr h0 (.inl (Ne.symm hne))).writeFrame_apart_any hwr
      (by rw [hl1]; exact hap)
  obtain ⟨sd', hsd', hr⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
  rw [hsd] at hsd'
  have e : sd' = sd := (Option.some.inj hsd').symm
  rw [e] at hr
  cases hr with
  | priv a x hp hι hx hl haddr hpaddr hsz hpv _ =>
    have hpw : ∀ k < bs1.length, s1.st.escapedAt (sd.off + k) = none := fun k hk =>
      hpv k (by omega)
    obtain ⟨st', hwr⟩ : ∃ st', s1.st.writeFrame sd.off bs1 = .ok st' := by
      unfold OpSem.State.writeFrame
      rw [writeEscaped_private' hpw]
      exact ⟨_, rfl⟩
    obtain ⟨hmi, hrd⟩ := writeLocal_priv hrel.frame.mem a x hp hι hx hl haddr hpaddr hsz hpv
      hbs hlen h0 hwr
    exact ⟨st', hwr, (writeFrame_split hwr).2.1, hmi, hrd, hoth st' hwr⟩
  | esc a x e y hp hι hx hl haddr hpaddr hsz hin hy hyl hya hys =>
    obtain ⟨st', hwr⟩ := writeFrame_obj_ok (bs := bs1) (fun k hk => hin k (by omega)) hy
    have hdisj : ∀ a' x', m0.get? a' = some x' → x'.live = true → ι a' = some e.id →
        a' ≠ a → x'.size = 0 ∨ x'.addr + x'.size ≤ pd.addr ∨ pd.addr + sd.size ≤ x'.addr := by
      intro a' x' hx' hl' _ hne
      -- `Allocation.size` is `Size`-valued: state everything over `data.size` (`Nat`)
      show x'.data.size = 0 ∨ x'.addr + x'.data.size ≤ pd.addr ∨ pd.addr + sd.size ≤ x'.addr
      by_cases c1 : x'.data.size = 0
      · exact .inl c1
      by_cases c2 : x'.addr + x'.data.size ≤ pd.addr
      · exact .inr (.inl c2)
      by_cases c3 : pd.addr + sd.size ≤ x'.addr
      · exact .inr (.inr c3)
      exfalso
      apply hne
      by_cases c4 : x.addr ≤ x'.addr
      · exact hld a' a x' x x'.addr hx' hx hl' hl (Nat.le_refl _)
          (by show x'.addr < x'.addr + x'.data.size; omega) c4
          (by show x'.addr < x.addr + x.data.size; omega)
      · exact hld a' a x' x x.addr hx' hx hl' hl (by omega)
          (by show x.addr < x'.addr + x'.data.size; omega) (Nat.le_refl _)
          (by show x.addr < x.addr + x.data.size; omega)
    obtain ⟨hmi, hrd⟩ := writeLocal_esc hrel.frame.mem a x e y hp hι hx hl haddr hpaddr hsz hin
      hy hyl hya hys hdisj hpos hbs hlen h0 hwr
    exact ⟨st', hwr, (writeFrame_split hwr).2.1, hmi, hrd, hoth st' hwr⟩

/-- What writing `_d` gives a family's handler-step lemma (`sim_copyField`, `sim_derefLoad`):
for any R bytes refining the stored `bs0`, R's frame write at `_d`'s slot succeeds, keeps the
objects, and gives `MemInj`, `_d`'s `LocalRel` and every apart local's after L0's store
(`m0` to `m0'`). `FnRel.dstWrite` provides it for a private or escaped `_d`. -/
def DstWrite (ι : Inj) (fp : Nat) (st : OpSem.State) (m0 m0' : Memory) (sd : LocalSlot)
    (pd : ThinPointer) (bs0 : List AbstractByte) : Prop :=
  ∀ bs1, BytesInj ι bs0 bs1 → ∃ st', st.writeFrame sd.off bs1 = .ok st' ∧
    st'.escaped = st.escaped ∧ MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' sd pd true ∧
    ∀ (slot : LocalSlot) p lv, LocalRel ι fp st m0 slot p lv → p.prov ≠ pd.prov →
      (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι fp st' m0' slot p lv

theorem FnRel.dstWrite {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) (hld : LiveDisjoint m0)
    {d : Local} {pd : ThinPointer} {sd : LocalSlot}
    (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd) (hpos : 0 < sd.size)
    {bs0 : List AbstractByte} (hlen : bs0.length = sd.size) {al : Align} {m0' : Memory}
    (h0 : m0.store pd bs0 al = .ok m0') : DstWrite ι s1.fp s1.st m0 m0' sd pd bs0 :=
  fun _ hbs => hrel.write_dst hld hpd hsd hpos hbs hlen h0

/-- `DstWrite` for every store L0 may do into `_d` (for handler-step lemmas that compute the
stored bytes themselves, e.g. `sim_unop`). -/
def DstWriteAll (ι : Inj) (fp : Nat) (st : OpSem.State) (m0 : Memory) (sd : LocalSlot)
    (pd : ThinPointer) : Prop :=
  ∀ (bs0 : List AbstractByte) (m0' : Memory) (al : Align), bs0.length = sd.size →
    m0.store pd bs0 al = .ok m0' → DstWrite ι fp st m0 m0' sd pd bs0

theorem FnRel.dstWriteAll {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) (hld : LiveDisjoint m0)
    {d : Local} {pd : ThinPointer} {sd : LocalSlot}
    (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd) (hpos : 0 < sd.size) :
    DstWriteAll ι s1.fp s1.st m0 sd pd :=
  fun _ _ _ hlen h0 => hrel.dstWrite hld hpd hsd hpos hlen h0

end Ryo.Proofs.Lower
