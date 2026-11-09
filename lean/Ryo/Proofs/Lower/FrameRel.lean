/-
Ryo.Proofs.Lower.FrameRel — the per-frame relation of the lowering simulation L0 → R (M5a,
aot.md §C1 "Locals"), at R's layout `φ_AOT` (a frame offset `off` at `fp + off`).

Per storage-live, non-aliased L0 local `l` with storage `p`, its certificate slot
`[off, off + size)` (`FuncCert.locals`) relates by `LocalRel`:

- **private** (not escaped in R): `p` is at `fp + off`, its L0 allocation is mapped to none by
  `ι` (nothing in the L0 state carries its provenance: the invariant that makes this sound is
  stated with the simulation, not here), no R escaped object meets the slot, and when the
  local is *semantically live* (`live`: read later before being overwritten, recomputed in
  Lean) its L0 bytes refine R's private frame bytes;
- **escaped**: the slot lies in one R escaped object `e`, whose allocation is at `fp + e.off`,
  and `ι` maps the local's allocation to `e`'s; the bytes are related by `MemInj` (escaped
  locals are always live in the relation's sense: anything may read them).

`FrameRel` adds `MemInj` for the whole memory. Temporaries (R slots no local owns) are
unconstrained. Aliased locals (D12, the caller's storage) are the call rules' (M5c).
-/
import Ryo.Proofs.Lower.MemInj
import Ryo.Check.Lower.Cert
import Ryo.Vm.R.Sem

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Check.Lower

/-- A storage-live L0 local with storage `p` and its slot (see the module comment). -/
inductive LocalRel (ι : Inj) (fp : Nat) (st : OpSem.State) (m0 : Memory) (slot : LocalSlot)
    (p : ThinPointer) (live : Bool) : Prop where
  | priv (a : AllocId) (x : Allocation)
      (hp : p.prov = some a) (hι : ι a = none) (hx : m0.get? a = some x) (hlive : x.live = true)
      (haddr : (x.addr : Int) = fp + slot.off) (hpaddr : p.addr = x.addr)
      (hsize : x.data.size = slot.size)
      (hpriv : ∀ k < slot.size, st.escapedAt (slot.off + k) = none)
      (hbytes : live = true → ∀ k (hk : k < x.data.size), ByteInj ι x.data[k] (st.frame (slot.off + k)))
  | esc (a : AllocId) (x : Allocation) (e : OpSem.EscapedObj) (y : Allocation)
      (hp : p.prov = some a) (hι : ι a = some e.id) (hx : m0.get? a = some x) (hlive : x.live = true)
      (haddr : (x.addr : Int) = fp + slot.off) (hpaddr : p.addr = x.addr)
      (hsize : x.data.size = slot.size)
      (hin : ∀ k < slot.size, st.escapedAt (slot.off + k) = some e)
      (hy : st.mem.get? e.id = some y) (hylive : y.live = true)
      (hyaddr : (y.addr : Int) = fp + e.off) (hysize : y.data.size = e.size)

/-- The frame relation (see the module comment). `slots` is the certificate's frame map. -/
structure FrameRel (ι : Inj) (slots : Array LocalSlot) (live : Local → Bool) (f0 : Spec.Frame)
    (m0 : Memory) (s1 : R.RState) : Prop where
  mem : MemInj ι m0 s1.st.mem
  locals : ∀ (l : Local) p, f0.locals[l]? = some (some p) → l ∉ f0.aliased →
    ∃ slot, slots[l]? = some slot ∧ LocalRel ι s1.fp s1.st m0 slot p (live l)

/-- Equal lengths and pointwise `ByteInj` give `BytesInj`. -/
theorem BytesInj_of_getElem {ι : Inj} : ∀ {bs0 bs1 : List AbstractByte},
    bs0.length = bs1.length →
    (∀ k (h0 : k < bs0.length) (h1 : k < bs1.length), ByteInj ι bs0[k] bs1[k]) →
    BytesInj ι bs0 bs1
  | [], [], _, _ => by simp only [BytesInj]
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl
  | b0 :: bs0, b1 :: bs1, hl, h => by
    simp only [BytesInj]
    exact ⟨h 0 (by simp) (by simp),
      BytesInj_of_getElem (by simpa using hl) fun k h0 h1 => by
        exact h (k + 1) (by simpa using h0) (by simpa using h1)⟩

/-- `mapM` in `M` where every element succeeds. -/
theorem mapM_ok_map {α β : Type} {f : α → OpSem.M β} {g : α → β} :
    ∀ (l : List α), (∀ x ∈ l, f x = .ok (g x)) → l.mapM f = .ok (l.map g)
  | [], _ => rfl
  | x :: l, h => by
    rw [List.mapM_cons, h x (List.mem_cons_self ..),
      mapM_ok_map l (fun y hy => h y (List.mem_cons_of_mem _ hy))]
    rfl

/-- A frame read whose every byte succeeds. -/
theorem readFrame_eq_map {st : OpSem.State} {off : Int} {n : Nat} {g : Nat → AbstractByte}
    (h : ∀ i < n, st.byteAt (off + i) = .ok (g i)) :
    st.readFrame off n = .ok ((List.range n).map g) := by
  unfold OpSem.State.readFrame
  exact mapM_ok_map _ (fun i hi => h i (List.mem_range.mp hi))

/-- A load of a whole allocation through a pointer to its start reads its data. -/
theorem load_whole {m : Memory} {p : ThinPointer} {a : AllocId} {x : Allocation}
    (hp : p.prov = some a) (hx : m.get? a = some x) (hpaddr : p.addr = x.addr)
    {n : Nat} (hn : x.data.size = n) {al : Align} {bs : List AbstractByte}
    (h : m.load p n al = .ok bs) : bs = x.data.toList := by
  unfold Memory.load at h
  simp only [bind, Except.bind] at h
  split at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  · simp only [pure, Except.pure] at h
    cases hc : m.checkPtr p n with
    | error e => simp [hc] at h
    | ok r =>
      rcases (Theorems.Memory.checkPtr_eq_ok).mp hc with ⟨hn0, rfl⟩ |
        ⟨id, hid, _, hprov, _, _, _, rfl⟩
      · simp only [hc, Except.ok.injEq] at h
        subst h
        exact (List.eq_nil_of_length_eq_zero (by simp [hn, hn0])).symm
      · have hia : id = a := Option.some.inj (hprov.symm.trans hp)
        have hx' : m.get? id = some x := by rw [hia]; exact hx
        have hxa : m.allocs[id] = x := by
          have h' : m.allocs[id]? = some x := hx'
          rw [Array.getElem?_eq_getElem hid] at h'
          exact Option.some.inj h'
        simp only [hc, Except.ok.injEq, getElem!_pos m.allocs id hid, hxa, hpaddr, Nat.sub_self,
          Nat.zero_add] at h
        rw [← h, ← hn, Array.extract_size]

/-- Reading a whole related local: L0's load and R's frame read give related bytes (a private
local must be semantically live). -/
theorem readLocal_inj {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory} {slot : LocalSlot}
    {p : ThinPointer} (hm : MemInj ι m0 st.mem) (hr : LocalRel ι fp st m0 slot p true)
    {al : Align} {bs0 : List AbstractByte} (h : m0.load p slot.size al = .ok bs0) :
    ∃ bs1, st.readFrame slot.off slot.size = .ok bs1 ∧ BytesInj ι bs0 bs1 := by
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    have hbs0 := load_whole hp hx hpaddr hsize h
    subst hbs0
    refine ⟨_, readFrame_eq_map (g := fun i => st.frame (slot.off + i)) (fun i hi => ?_), ?_⟩
    · rw [OpSem.State.byteAt, hpriv i hi] <;> rfl
    · apply BytesInj_of_getElem (by simp [hsize])
      intro k h0 _
      have hk : k < x.data.size := by simpa using h0
      simp only [Array.getElem_toList, List.getElem_map, List.getElem_range]
      exact hbytes rfl k hk
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    have hbs0 := load_whole hp hx hpaddr hsize h
    subst hbs0
    obtain ⟨y', hy', hxy⟩ := hm a e.id x hx hι
    obtain rfl : y = y' := Option.some.inj (hy.symm.trans hy')
    have hlo := hxy.lo
    have hhi := hxy.hi
    simp only [Allocation.size] at hhi
    refine ⟨_, readFrame_eq_map
      (g := fun i => (y.data[x.addr - y.addr + i]?).getD .uninit) (fun i hi => ?_), ?_⟩
    · have hb : x.addr - y.addr + i < y.data.size := by omega
      have hcast : slot.off + (i : Int) - e.off = ((x.addr - y.addr + i : Nat) : Int) := by
        omega
      have hidx : (slot.off + (i : Int) - e.off).toNat = x.addr - y.addr + i := by
        rw [hcast]; omega
      rw [OpSem.State.byteAt, hin i hi]
      simp only [hy, hylive, Bool.not_true, Bool.false_eq_true, ↓reduceIte, hidx,
        Array.getElem?_eq_getElem hb, Option.getD_some] <;> rfl
    · apply BytesInj_of_getElem (by simp [hsize])
      intro k h0 _
      have hk : k < x.data.size := by simpa using h0
      have hb : x.addr - y.addr + k < y.data.size := by omega
      simp only [Array.getElem_toList, List.getElem_map, List.getElem_range,
        Array.getElem?_eq_getElem hb, Option.getD_some]
      exact hxy.bytes hlive k hk hb

open Ryo.Vm.OpSem in
/-- A copy of `Ryo.Proofs.Inline.writeEscaped_private` (not imported here). -/
theorem writeEscaped_private' {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    (hp : ∀ i < bs.length, st.escapedAt (off + i) = none) :
    st.writeEscaped off bs = .ok st.mem := by
  unfold OpSem.State.writeEscaped
  have : ∀ (l : List (AbstractByte × Nat)), (∀ p ∈ l, st.escapedAt (off + p.2) = none) →
      ∀ mem, l.foldlM (init := mem) (fun mem (b, i) =>
        match st.escapedAt (off + i) with
        | none => pure mem
        | some e =>
          match mem.get? e.id with
          | none => illFormed s!"escaped frame object at {e.off} has no allocation"
          | some a =>
            let a' := { a with data := a.data.set! (off + i - e.off).toNat b }
            pure { allocs := mem.allocs.set! e.id a' }) = (.ok mem : OpSem.M Memory) := by
    intro l
    induction l with
    | nil => intro _ mem; rfl
    | cons p l ih =>
      intro hl mem
      simp only [List.foldlM_cons]
      rw [hl p (List.mem_cons_self ..)]
      exact ih (fun q hq => hl q (List.mem_cons_of_mem _ hq)) mem
  apply this
  intro p hp'
  obtain ⟨b, i⟩ := p
  rw [List.mem_zipIdx_iff_getElem?] at hp'
  have : i < bs.length := by
    obtain ⟨h, -⟩ := List.getElem?_eq_some_iff.1 hp'
    simpa using h
  exact hp i this

/-- A private frame write changes only the frame. -/
theorem writeFrame_private_eq {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') (hp : ∀ i < bs.length, st.escapedAt (off + i) = none) :
    st'.mem = st.mem ∧ (∀ o, st'.escapedAt o = st.escapedAt o) ∧
      ∀ o, st'.frame o =
        if st.privateIn off bs.length o then bs.getD (o - off).toNat .uninit else st.frame o := by
  unfold OpSem.State.writeFrame at h
  rw [writeEscaped_private' hp] at h
  simp only [bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
  subst h
  exact ⟨rfl, fun _ => rfl, fun _ => rfl⟩

/-- `store`'s data fold at offset 0 over data as long as the bytes: the bytes. -/
theorem fold_getElem0 {bs : List AbstractByte} {d : Array AbstractByte} {off : Nat}
    (hoff : off = 0) (hlen : bs.length = d.size) {k : Nat}
    (hk : k < ((bs.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) d).size) :
    ∃ hk0 : k < bs.length,
      ((bs.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) d)[k] = bs[k] := by
  subst hoff
  have hs : ((bs.zipIdx).foldl (fun d (b, i) => d.set! (0 + i) b) d).size = d.size :=
    Ryo.Spec.Theorems.foldl_set_size bs 0 0 d
  have hkd : k < d.size := hs ▸ hk
  have hk0 : k < bs.length := hlen ▸ hkd
  refine ⟨hk0, ?_⟩
  have e : ((bs.zipIdx).foldl (fun d (b, i) => d.set! (0 + i) b) d)[k]? =
      if 0 + 0 ≤ k ∧ k < 0 + 0 + bs.length ∧ k < d.size then bs[k - 0 - 0]? else d[k]? :=
    Ryo.Spec.Theorems.foldl_set_getElem bs 0 0 d k
  rw [if_pos (by omega), Array.getElem?_eq_getElem hk, Nat.sub_zero, Nat.sub_zero,
    List.getElem?_eq_getElem hk0] at e
  exact Option.some.inj e

/-- Writing a whole private local: L0's store and R's frame write of related bytes keep the
local related (and live), and keep `MemInj` (no R memory changes). -/
theorem writeLocal_priv {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} (hm : MemInj ι m0 st.mem)
    (a : AllocId) (x : Allocation) (hp : p.prov = some a) (hι : ι a = none)
    (hx : m0.get? a = some x) (hlive : x.live = true)
    (haddr : (x.addr : Int) = fp + slot.off) (hpaddr : p.addr = x.addr)
    (hsize : x.data.size = slot.size)
    (hpriv : ∀ k < slot.size, st.escapedAt (slot.off + k) = none)
    {bs0 bs1 : List AbstractByte} (hbs : BytesInj ι bs0 bs1) (hlen : bs0.length = slot.size)
    {al : Align} (h0 : m0.store p bs0 al = .ok m0') (h1 : st.writeFrame slot.off bs1 = .ok st') :
    MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' slot p true := by
  have hl1 : bs1.length = slot.size := (BytesInj.length hbs).symm.trans hlen
  obtain ⟨hmem, hea, hfr⟩ := writeFrame_private_eq h1 (fun k hk => hpriv k (hl1 ▸ hk))
  have hpriv' : ∀ k < slot.size, st'.escapedAt (slot.off + k) = none :=
    fun k hk => (hea _).trans (hpriv k hk)
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h0 with
    ⟨-, hz, rfl⟩ | ⟨id, hid, -, -, hpid, -, -, -, -, hm0'⟩
  · refine ⟨by rw [hmem]; exact hm,
      .priv a x hp hι hx hlive haddr hpaddr hsize hpriv' ?_⟩
    intro _ k hk
    exfalso
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
        data := (bs0.zipIdx).foldl (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b)
          m0.allocs[a].data } := by
      subst hm0'; simp
    have hdata : m0'.allocs[a].data =
        (bs0.zipIdx).foldl (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b)
          m0.allocs[a].data := by rw [hcomp]
    have hsz' : m0'.allocs[a].data.size = slot.size := by
      rw [hdata]
      exact (Ryo.Spec.Theorems.foldl_set_size bs0 0 (p.addr - m0.allocs[a].addr)
        m0.allocs[a].data).trans hsize
    refine .priv a m0'.allocs[a] hp hι ?_ (by rw [hcomp]; exact hlive)
      (by rw [hcomp]; exact haddr) (by rw [hcomp]; exact hpaddr) hsz' hpriv' ?_
    · show m0'.allocs[a]? = _
      exact Array.getElem?_eq_getElem ha'
    · intro _ k hk
      have hk2 : k < ((bs0.zipIdx).foldl
          (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b) m0.allocs[a].data).size :=
        hdata ▸ hk
      obtain ⟨hk0, hF⟩ := fold_getElem0 (bs := bs0) (d := m0.allocs[a].data)
        (off := p.addr - m0.allocs[a].addr) (by omega) (by omega) hk2
      have hdk : m0'.allocs[a].data[k] = bs0[k] := by
        have : ∀ (D : Array AbstractByte), D = (bs0.zipIdx).foldl
            (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b) m0.allocs[a].data →
            ∀ (h : k < D.size), D[k] = bs0[k] := by
          intro D hD _; subst hD; exact hF
        exact this _ hdata hk
      have hks : k < slot.size := hsz' ▸ hk
      have hk1 : k < bs1.length := by omega
      rw [hdk, hfr]
      rw [if_pos (by
        simp only [OpSem.State.privateIn, hpriv k hks, Option.isNone_none, Bool.and_true,
          decide_eq_true_eq]
        omega)]
      have ht : (slot.off + (k : Int) - slot.off).toNat = k := by omega
      rw [ht, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hk1, Option.getD_some]
      exact BytesInj.getElem' hbs k hk0 hk1

/-- A private write to `[off, off + n)` disjoint from a private local's slot leaves it related. -/
theorem LocalRel.writeFrame_apart {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 : Memory}
    {slot : LocalSlot} {p : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 slot p lv)
    {off : Int} {bs : List AbstractByte} (h : st.writeFrame off bs = .ok st')
    (hpriv : ∀ k < bs.length, st.escapedAt (off + k) = none)
    (hapart : off + bs.length ≤ slot.off ∨ slot.off + slot.size ≤ off) :
    LocalRel ι fp st' m0 slot p lv := by
  obtain ⟨hmem, hea, hfr⟩ := writeFrame_private_eq h hpriv
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
    exact .esc a x e y hp hι hx hlive haddr hpaddr hsize
      (fun k hk => (hea _).trans (hin k hk)) (by rw [hmem]; exact hy) hylive hyaddr hysize

end Ryo.Proofs.Lower
