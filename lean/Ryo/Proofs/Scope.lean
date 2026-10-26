/-
Ryo.Proofs.Scope — R's scopes (`Escape`, `End`, `Lend`, applied before each instruction:
reduced.md §C0.3) keep the R ↔ x86 relation (§C0.2 `φ_AOT`, §C0.7), with the x86 state
unchanged: scopes emit no code (aot.md §C2, M3 `decode_sound`).

- `EscWF st`: what `escape` guarantees of `opSem`'s escaped objects and `rel_writeFrame`'s
  callers don't: each escaped object's `AllocId` is an allocation of the memory (`< size`:
  `escape` takes the fresh id `allocs.size`), and no two escaped objects share an id (so a
  frame write into one never lands in another's allocation, and `End` freeing one object
  doesn't free a kept one). Disjointness of the escaped ranges, liveness and data sizes are
  not needed: `byteAt` checks liveness and bounds itself (a failing read relates to nothing),
  and `escapedAt` takes the first object containing an offset.
- `RRel s x`: `Rel s.st x`, `fp` in `rbp`, and `EscWF`. No bound on `fp` is needed:
  `frameAddr fp off` is `(fp + off).toNat` with `fp + off ≥ 0`, which is `rbp + off` mod
  `2^64` (`ofNat_frameAddr`).
- `rrel_escape`: a new escaped object's allocation holds the frame's current bytes, so every
  `byteAt` is unchanged; its address is `fp + off`, so `layout` holds. Ids stay fresh.
- `rrel_storageEnd`: the bytes in `[off, off + size)` become `Uninit` (private or in a partly
  covered object: `EscFrom`), which relates to any byte; outside it, `escapedAt` finds the
  same object (the dropped objects lie inside the range) and its allocation's bytes are
  unchanged (distinct ids: neither `freeObjs` nor the write touches it).
- `rrel_applyScope`, `rrel_scopes`: one scope, and `step`'s fold over `c.scopesAt pc`.
- `ScopeKeeps`, `scopes_keeps`: scopes keep `pc`, `fp`, the argument registers, the
  zero-sized objects and the exception register, and only append to the exposed allocations.
- `escWF_of_sameButWrites`: the inline theorems' outputs (`SameButWrites`) keep `EscWF`.
-/
import Ryo.Proofs.Inline.Rel
import Ryo.Vm.R.Sem

namespace Ryo.Proofs.Scope

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Proofs.Inline

/-! ### The invariant and the relation -/

/-- What `escape` guarantees of the escaped objects (see the module comment). -/
structure EscWF (st : OpSem.State) : Prop where
  /-- Each escaped object's id is an allocation (`escape` takes `allocs.size`; nothing removes
  allocations). -/
  idLt : ∀ e ∈ st.escaped, e.id < st.mem.allocs.size
  /-- Escaped objects have distinct ids (each `escape` takes a fresh one). -/
  idInj : ∀ e ∈ st.escaped, ∀ e' ∈ st.escaped, e.id = e'.id → e = e'

/-- The R state `s` and the x86 state `x` (§C0.7 under `φ_AOT`, `fp` in `rbp`). -/
structure RRel (s : R.RState) (x : X86.State) : Prop where
  rel : Rel s.st x
  rbp : x.reg .rbp = BitVec.ofNat 64 s.fp
  wf : EscWF s.st

/-! ### Lemmas -/

theorem find?_filter_of_some {α : Type} {p q : α → Bool} : ∀ {l : List α} {e : α},
    l.find? p = some e → q e = true → (l.filter q).find? p = some e
  | [], _, h, _ => by simp at h
  | a :: l, e, h, hq => by
    by_cases hp : p a = true
    · rw [List.find?_cons_of_pos hp] at h
      cases h
      simp [hq, List.find?_cons_of_pos hp]
    · rw [List.find?_cons_of_neg hp] at h
      have := find?_filter_of_some (q := q) h hq
      by_cases hqa : q a = true
      · simp [hqa, List.find?_cons_of_neg hp, this]
      · simp [hqa, this]

theorem find?_filter_of_none {α : Type} {p q : α → Bool} {l : List α} (h : l.find? p = none) :
    (l.filter q).find? p = none := by
  rw [List.find?_eq_none] at h ⊢
  intro x hx; exact h x (List.mem_filter.1 hx).1

/-- `byteAt o` depends only on `escapedAt o`, the private byte and that object's allocation. -/
theorem byteAt_congr {st st' : OpSem.State} {o : Int} (he : st'.escapedAt o = st.escapedAt o)
    (hf : st'.frame o = st.frame o)
    (hm : ∀ e, st.escapedAt o = some e → st'.mem.get? e.id = st.mem.get? e.id) :
    st'.byteAt o = st.byteAt o := by
  unfold OpSem.State.byteAt
  rw [he]
  cases h : st.escapedAt o with
  | none => simp [hf]
  | some e => simp only [hm e h]

/-! ### `Escape` -/

/-- What a successful `escape` is: nothing, or a fresh allocation at `fp + off` holding the
frame's bytes, for a range no escaped object overlaps. -/
theorem escape_ok {s s' : R.RState} {off : Int} {size align : Nat}
    (h : R.escape s off size align = .ok s') :
    s' = s ∨ ∃ (bytes : List AbstractByte) (a : Allocation),
      (∀ e ∈ s.st.escaped, ¬ (e.off < off + size ∧ off < e.off + e.size)) ∧
      0 ≤ (s.fp : Int) + off ∧ a.addr = ((s.fp : Int) + off).toNat ∧ a.data = bytes.toArray ∧
      a.live = true ∧ s.st.readFrame off size = .ok bytes ∧
      s' = { s with st := { s.st with
        mem := ({ allocs := s.st.mem.allocs.push a } : Memory),
        escaped := s.st.escaped ++ [({ off := off, size := size, id := s.st.mem.allocs.size } : EscapedObj)],
        exposed := s.st.exposed ++ [s.st.mem.allocs.size] } } := by
  unfold R.escape at h
  simp only at h
  split at h
  · left; cases h; rfl
  right
  split at h
  · cases h
  rename_i hno
  unfold R.frameAddr at h
  simp only [bind, Except.bind] at h
  split at h
  · cases h
  rename_i hnn
  split at hnn
  · cases hnn
  rename_i hge
  simp only [pure, Except.pure, Except.ok.injEq] at hnn
  subst hnn
  simp only [pure, Except.pure] at h
  split at h
  · cases h
  split at h
  · cases h
  cases hr : s.st.readFrame off size with
  | error e => simp [hr] at h
  | ok bytes =>
    simp only [hr, Except.ok.injEq] at h
    subst h
    refine ⟨bytes, _, ?_, by omega, rfl, rfl, rfl, rfl, rfl⟩
    intro e he hov
    simp only [List.any_eq_true, decide_eq_true_eq, not_exists, not_and] at hno
    exact hno e he hov.1 hov.2

/-- `frameAddr fp off` (when not `illFormed`) is `rbp + off` with `fp` in `rbp`. -/
theorem ofNat_frameAddr (fp : Nat) (off : Int) (h : 0 ≤ (fp : Int) + off) :
    BitVec.ofNat 64 ((fp : Int) + off).toNat = BitVec.ofNat 64 fp + BitVec.ofInt 64 off := by
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, BitVec.toNat_add, BitVec.toNat_ofInt]
  omega

/-- `Escape` keeps `RRel` against the same x86 state. -/
theorem rrel_escape {s s' : R.RState} {x : X86.State} {off : Int} {size align : Nat}
    (hr : RRel s x) (h : R.escape s off size align = .ok s') : RRel s' x := by
  rcases escape_ok h with rfl | ⟨bytes, a, hdis, hnn, haddr, hdata, hlive, hread, rfl⟩
  · exact hr
  obtain ⟨⟨hfr, hlay, hzs⟩, hrbp, ⟨hlt, hinj⟩⟩ := hr
  obtain ⟨hlen, hall⟩ := mapM_ok hread
  simp only [List.length_range] at hlen
  have hget : ∀ e ∈ s.st.escaped,
      ({ allocs := s.st.mem.allocs.push a } : Memory).get? e.id = s.st.mem.get? e.id := by
    intro e he
    have := hlt e he
    simp only [Memory.get?, Array.getElem?_push, Nat.ne_of_lt this,
      ↓reduceIte]
  have hgetn : ({ allocs := s.st.mem.allocs.push a } : Memory).get? s.st.mem.allocs.size = some a := by
    simp [Memory.get?]
  refine ⟨⟨fun o ho1 ho2 b hb => ?_, fun e he a' ha' => ?_, hzs⟩, hrbp, ⟨fun e he => ?_, ?_⟩⟩
  · -- frame
    cases ho : s.st.escapedAt o with
    | some e =>
      have he := (escapedAt_some ho).1
      apply hfr o ho1 ho2 b
      rw [← hb]
      symm
      apply byteAt_congr
      · simp only [OpSem.State.escapedAt, List.find?_append] at ho ⊢
        rw [ho]; rfl
      · rfl
      · intro e' he'
        rw [ho] at he'; cases he'
        exact hget e he
    | none =>
      by_cases hin : off ≤ o ∧ o < off + size
      · have hk : (o - off).toNat < bytes.length := by omega
        have hb' := hall (o - off).toNat (by simp; omega) hk
        simp only [List.getElem_range, show off + ((o - off).toNat : Int) = o by omega] at hb'
        have hesc : ({ s.st with
            mem := ({ allocs := s.st.mem.allocs.push a } : Memory),
            escaped := s.st.escaped ++ [({ off := off, size := size, id := s.st.mem.allocs.size } : EscapedObj)],
            exposed := s.st.exposed ++ [s.st.mem.allocs.size] } : OpSem.State).escapedAt o =
              some { off := off, size := size, id := s.st.mem.allocs.size } := by
          simp only [OpSem.State.escapedAt, List.find?_append] at ho ⊢
          rw [ho]
          simp [hin]
        unfold OpSem.State.byteAt at hb
        rw [hesc] at hb
        simp only at hb
        rw [hgetn] at hb
        simp only [hlive, Bool.not_true, Bool.false_eq_true, ↓reduceIte, hdata,
          List.getElem?_toArray, List.getElem?_eq_getElem hk] at hb
        cases hb
        exact hfr o ho1 ho2 _ hb'
      · apply hfr o ho1 ho2 b
        rw [← hb]
        symm
        apply byteAt_congr
        · simp only [OpSem.State.escapedAt, List.find?_append] at ho ⊢
          rw [ho]
          simp [hin]
        · rfl
        · intro e' he'; rw [ho] at he'; cases he'
  · -- layout
    simp only [List.mem_append, List.mem_singleton] at he
    rcases he with he | rfl
    · rw [hget e he] at ha'
      exact hlay e he a' ha'
    · rw [hgetn] at ha'
      cases ha'
      simp only [fpAddr, hrbp, haddr]
      exact ofNat_frameAddr _ _ hnn
  · simp only [List.mem_append, List.mem_singleton] at he
    simp only [Array.size_push]
    rcases he with he | rfl
    · exact Nat.lt_succ_of_lt (hlt e he)
    · simp
  · intro e he e' he' hid
    simp only [List.mem_append, List.mem_singleton] at he he'
    rcases he with he | rfl <;> rcases he' with he' | rfl
    · exact hinj e he e' he' hid
    · exact absurd hid (Nat.ne_of_lt (hlt e he))
    · exact absurd hid.symm (Nat.ne_of_lt (hlt e' he'))
    · rfl

/-! ### `End` -/

theorem freeObjs_size : ∀ (es : List EscapedObj) (m : Memory),
    (R.freeObjs m es).allocs.size = m.allocs.size
  | [], _ => rfl
  | e :: es, m => by
    show (R.freeObjs _ es).allocs.size = _
    rw [freeObjs_size es]
    simp only []
    split <;> simp

theorem freeObjs_get : ∀ (es : List EscapedObj) (m : Memory) (id : AllocId),
    (∀ e ∈ es, e.id ≠ id) → (R.freeObjs m es).get? id = m.get? id
  | [], _, _, _ => rfl
  | e :: es, m, id, h => by
    show (R.freeObjs _ es).get? id = _
    rw [freeObjs_get es _ id fun e' he' => h e' (List.mem_cons_of_mem _ he')]
    have hne := h e (List.mem_cons_self ..)
    simp only []
    split
    · simp [Memory.get?, Array.set!_eq_setIfInBounds, hne]
    · rfl

/-- What a successful `storageEnd` is: the write of `Uninit` over the range, after dropping
(and freeing) the objects it covers whole. -/
theorem storageEnd_ok {s s' : R.RState} {off : Int} {size : Nat}
    (h : R.storageEnd s off size = .ok s') :
    ∃ st', ({ s.st with
        mem := R.freeObjs s.st.mem
          (s.st.escaped.filter fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)),
        escaped := s.st.escaped.filter
          (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) } : OpSem.State).writeFrame
        off (List.replicate size .uninit) = .ok st' ∧ s' = { s with st := st' } := by
  unfold R.storageEnd at h
  simp only [List.partition_eq_filter_filter, bind, Except.bind] at h
  split at h
  · cases h
  rename_i st' hw
  simp only [pure, Except.pure, Except.ok.injEq] at h
  exact ⟨st', hw, h.symm⟩

/-- `End` keeps `RRel` against the same x86 state. -/
theorem rrel_storageEnd {s s' : R.RState} {x : X86.State} {off : Int} {size : Nat}
    (hr : RRel s x) (h : R.storageEnd s off size = .ok s') : RRel s' x := by
  obtain ⟨st', hw, rfl⟩ := storageEnd_ok h
  obtain ⟨⟨hfr, hlay, hzs⟩, hrbp, ⟨hlt, hinj⟩⟩ := hr
  generalize hcov : (fun e : EscapedObj => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) = cov at hw
  generalize hst1 : ({ s.st with
        mem := R.freeObjs s.st.mem (s.st.escaped.filter cov),
        escaped := s.st.escaped.filter (not ∘ cov) } : OpSem.State) = st1 at hw
  have hkept : ∀ e ∈ st1.escaped, e ∈ s.st.escaped ∧ cov e = false := by
    intro e he; subst hst1
    simpa using (List.mem_filter.1 he)
  -- the kept objects' allocations are untouched by `freeObjs`
  have hm1 : ∀ e ∈ st1.escaped, st1.mem.get? e.id = s.st.mem.get? e.id := by
    intro e he
    obtain ⟨he0, hc⟩ := hkept e he
    subst hst1
    apply freeObjs_get
    intro e' he' hid
    obtain ⟨he0', hc'⟩ := List.mem_filter.1 he'
    rw [hinj e' he0' e he0 hid] at hc'
    rw [hc] at hc'; cases hc'
  have hsz1 : st1.mem.allocs.size = s.st.mem.allocs.size := by
    subst hst1; exact freeObjs_size _ _
  -- the escaped object at an offset outside the range is the same
  have hea : ∀ o, ¬ (off ≤ o ∧ o < off + size) → st1.escapedAt o = s.st.escapedAt o := by
    intro o hout
    subst hst1
    unfold OpSem.State.escapedAt
    show (List.filter (not ∘ cov) s.st.escaped).find? _ = s.st.escaped.find? _
    cases hf : s.st.escaped.find? (fun e => decide (e.off ≤ o ∧ o < e.off + e.size)) with
    | none => exact find?_filter_of_none hf
    | some e =>
      apply find?_filter_of_some hf
      obtain ⟨he, h1, h2⟩ := escapedAt_some (st := s.st) (o := o) hf
      subst hcov
      simp only [Function.comp, Bool.not_eq_eq_eq_not, Bool.not_true, decide_eq_false_iff_not]
      omega
  unfold OpSem.State.writeFrame at hw
  cases hm : st1.writeEscaped off (List.replicate size .uninit) with
  | error e => simp [hm, bind, Except.bind] at hw
  | ok m' =>
  simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  have hesc := writeEscaped_spec hm
  refine ⟨⟨fun o ho1 ho2 b hb => ?_, fun e he a' ha' => ?_, ?_⟩, hrbp, ⟨fun e he => ?_, ?_⟩⟩
  · have hea' : ∀ (f : Int → AbstractByte) (m : Memory),
        ({ st1 with mem := m, frame := f } : OpSem.State).escapedAt o = st1.escapedAt o :=
      fun _ _ => rfl
    unfold OpSem.State.byteAt at hb
    rw [hea'] at hb
    by_cases hin : off ≤ o ∧ o < off + size
    · suffices b = .uninit by subst this; trivial
      cases hf : st1.escapedAt o with
      | none =>
        simp only [hf, OpSem.State.privateIn, List.length_replicate, hin,
          Option.isNone_none, pure, Except.pure, Except.ok.injEq,
          List.getD_eq_getElem?_getD, List.getElem?_replicate] at hb
        simp only [and_self, decide_true, Bool.and_self, ↓reduceIte] at hb
        rw [← hb]; split <;> rfl
      | some e =>
        simp only [hf] at hb
        split at hb
        · rename_i a' ha'
          split at hb
          · cases hb
          · split at hb
            · rename_i b' hb'
              cases hb
              obtain ⟨a, ha, hae, hsz, hj⟩ := hesc.2 e.id a' ha'
              have hk : (o - off).toNat < size := by omega
              have hhit : Hits st1 off (.uninit, (o - off).toNat) e.id (o - e.off).toNat :=
                ⟨e, by rw [show off + ((o - off).toNat : Int) = o by omega]; exact hf, rfl,
                  by rw [show off + ((o - off).toNat : Int) = o by omega]⟩
              have hjl : (o - e.off).toNat < a.data.size := by
                rw [← hsz]; exact (Array.getElem?_eq_some_iff.1 hb').1
              obtain ⟨q, hq, -, hv⟩ := (hj _).2
                ⟨_, List.mem_zipIdx_iff_getElem?.2 (by simp [hk]), hhit⟩ hjl
              obtain ⟨hqk, hq1⟩ := mem_zipIdx hq
              rw [hb'] at hv
              cases hv
              rw [hq1]
              simp
            · cases hb
        · cases hb
    · apply hfr o ho1 ho2 b
      have hea1 := hea o hin
      unfold OpSem.State.byteAt
      cases hf : s.st.escapedAt o with
      | none =>
        rw [hea1, hf] at hb
        simp only [OpSem.State.privateIn, List.length_replicate, hin, decide_false,
          Bool.false_and, Bool.false_eq_true, ↓reduceIte] at hb
        subst hst1
        exact hb
      | some e =>
        rw [hea1, hf] at hb
        simp only at hb ⊢
        obtain ⟨he0, h1, h2⟩ := escapedAt_some hf
        have he1 : e ∈ st1.escaped := (escapedAt_some (hea1.trans hf)).1
        split at hb
        · rename_i a' ha'
          obtain ⟨a, ha, hae, hsz, hj⟩ := hesc.2 e.id a' ha'
          have hnh : ∀ p ∈ (List.replicate size AbstractByte.uninit).zipIdx,
              ¬ Hits st1 off p e.id (o - e.off).toNat := by
            rintro q hq ⟨e', he', hid', hj'⟩
            obtain ⟨hqk, -⟩ := mem_zipIdx hq
            simp only [List.length_replicate] at hqk
            obtain ⟨he'0, h1', h2'⟩ := escapedAt_some he'
            have := hinj e' (hkept e' he'0).1 e he0 hid'
            subst this
            omega
          have hdat := (hj _).1 hnh
          rw [hm1 e he1] at ha
          rw [ha]
          rw [hae] at hb
          simp only at hb
          simp only
          rw [← hdat]
          exact hb
        · cases hb
  · obtain ⟨a1, ha1, hae, -⟩ := hesc.2 _ _ ha'
    rw [hm1 e he] at ha1
    rw [hae]
    exact hlay e (hkept e he).1 a1 ha1
  · subst hst1; exact hzs
  · rw [hesc.1, hsz1]; exact hlt e (hkept e he).1
  · intro e he e' he' hid
    exact hinj e (hkept e he).1 e' (hkept e' he').1 hid

/-! ### Scopes -/

/-- One scope keeps `RRel` against the same x86 state. -/
theorem rrel_applyScope {s s' : R.RState} {x : X86.State} {sc : R.Scope} (hr : RRel s x)
    (h : R.applyScope s sc = .ok s') : RRel s' x := by
  unfold R.applyScope at h
  split at h
  · exact rrel_escape hr h
  · exact rrel_storageEnd hr h
  · cases h; exact hr

theorem rrel_foldlM {x : X86.State} : ∀ (l : List R.Scope) {s s' : R.RState}, RRel s x →
    l.foldlM R.applyScope s = .ok s' → RRel s' x
  | [], s, s', hr, h => by cases h; exact hr
  | sc :: l, s, s', hr, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      exact rrel_foldlM l (rrel_applyScope hr h1) h

/-- The scopes before instruction `pc` (`step`'s first part) keep `RRel`. -/
theorem rrel_scopes {c : R.Code} {pc : Nat} {s s' : R.RState} {x : X86.State} (hr : RRel s x)
    (h : (c.scopesAt pc).foldlM R.applyScope s = .ok s') : RRel s' x :=
  rrel_foldlM _ hr h

/-! ### What else scopes keep -/

/-- What a scope keeps of the R state besides `RRel`: the instruction, `fp`, the argument
registers, the zero-sized objects and the exception register; the exposed allocations only
grow (`escape` adds its object's). -/
structure ScopeKeeps (s s' : R.RState) : Prop where
  pc : s'.pc = s.pc
  fp : s'.fp = s.fp
  args : s'.args = s.args
  zeroSized : s'.st.zeroSized = s.st.zeroSized
  exception : s'.st.exception = s.st.exception
  exposed : ∃ l, s'.st.exposed = s.st.exposed ++ l

theorem ScopeKeeps.refl (s : R.RState) : ScopeKeeps s s :=
  ⟨rfl, rfl, rfl, rfl, rfl, ⟨[], by simp⟩⟩

theorem ScopeKeeps.trans {s1 s2 s3 : R.RState} (h1 : ScopeKeeps s1 s2) (h2 : ScopeKeeps s2 s3) :
    ScopeKeeps s1 s3 := by
  obtain ⟨l1, e1⟩ := h1.exposed
  obtain ⟨l2, e2⟩ := h2.exposed
  exact ⟨h2.pc.trans h1.pc, h2.fp.trans h1.fp, h2.args.trans h1.args,
    h2.zeroSized.trans h1.zeroSized, h2.exception.trans h1.exception, ⟨l1 ++ l2, by simp [e2, e1]⟩⟩

theorem writeFrame_keeps {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') :
    st'.zeroSized = st.zeroSized ∧ st'.exception = st.exception ∧ st'.exposed = st.exposed := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact ⟨rfl, rfl, rfl⟩

theorem applyScope_keeps {s s' : R.RState} {sc : R.Scope} (h : R.applyScope s sc = .ok s') :
    ScopeKeeps s s' := by
  unfold R.applyScope at h
  split at h
  · rcases escape_ok h with rfl | ⟨_, _, _, _, _, _, _, _, rfl⟩
    · exact ScopeKeeps.refl _
    · exact ⟨rfl, rfl, rfl, rfl, rfl, ⟨_, rfl⟩⟩
  · obtain ⟨st', hw, rfl⟩ := storageEnd_ok h
    obtain ⟨h1, h2, h3⟩ := writeFrame_keeps hw
    exact ⟨rfl, rfl, rfl, h1, h2, ⟨[], by simp [h3]⟩⟩
  · cases h; exact ScopeKeeps.refl _

theorem scopes_keeps : ∀ (l : List R.Scope) {s s' : R.RState},
    l.foldlM R.applyScope s = .ok s' → ScopeKeeps s s'
  | [], s, s', h => by cases h; exact ScopeKeeps.refl _
  | sc :: l, s, s', h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      exact (applyScope_keeps h1).trans (scopes_keeps l h)

/-! ### The inline theorems keep `EscWF` -/

/-- A state that differs from `st` only in frame bytes (the inline theorems' outputs) keeps
`EscWF`: its escaped objects are the same, and its memory has as many allocations. -/
theorem escWF_of_sameButWrites {st st' : OpSem.State} (hw : EscWF st)
    (h : SameButWrites st' st) : EscWF st' := by
  obtain ⟨hesc, ⟨hsz, -⟩, -⟩ := h
  refine ⟨fun e he => ?_, fun e he e' he' hid => ?_⟩
  · rw [hesc] at he; rw [hsz]; exact hw.idLt e he
  · rw [hesc] at he he'; exact hw.idInj e he e' he' hid

end Ryo.Proofs.Scope
