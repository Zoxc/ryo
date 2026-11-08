/-
Ryo.Proofs.DecodeSound.RegionRead — `read` with a PE pad region in two passes (P1c, toward
`decodes_of_ok_region`).

- `read_region_passes`: the body's `instructions` pass (`S.fr`, `droppedBody`, up to the region's
  entry), the counter stubs from its end to the entry, the region's pass (`readRegion`: `S.frR`,
  `droppedRegion`, from the region's first instruction), how `resumeSlots` leaves their protos
  (`resumeFix`), and the entry's facts (as `read_instructions_entry`).
- `iter_atPos`, `iter_args`, `iter_congr`: moving an `Iter` to the body's cursor, to another
  leading-`arg` flag (when it doesn't read an `arg`), and along equalities.
-/
import Ryo.Proofs.DecodeSound.Region
import Ryo.Proofs.Discharge.StubsLinked
import Ryo.Proofs.DSWork.Counter

namespace Ryo.Proofs.DecodeSound

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm Ryo.Proofs.DecodeLink

/-- The landing pads' exception slot as `resumeSlots` reads it (`Setup.lpadSlot`'s body). -/
def lpadSlotOf (ps : Array Proto) : Option (BitVec 32) :=
  (ps.find? (·.op == .lpad)).bind fun p =>
    match p.handler with
    | some (args, _) => match args.getLast? with
      | some (.imm v) => some (v.setWidth 32)
      | _ => none
    | none => match p.ops.head? with
      | some (.slot s) => some s
      | _ => none

/-- A region proto as `resumeSlots` leaves it (`Setup.fixResume`'s body). -/
def resumeFix (slot : Option (BitVec 32)) (fr : Frame) (q : Proto) : Proto :=
  if q.op == .resume then
    match slot with
    | some x => { q with handler := some (resumeArgs fr x, .trap) }
    | none => q
  else q

theorem resumeFix_op {slot : Option (BitVec 32)} {fr : Frame} {q : Proto} :
    (resumeFix slot fr q).op = q.op := by
  unfold resumeFix
  split
  · split <;> rfl
  · rfl

theorem resumeFix_pos {slot : Option (BitVec 32)} {fr : Frame} {q : Proto} :
    (resumeFix slot fr q).pos = q.pos := by
  unfold resumeFix
  split
  · split <;> rfl
  · rfl

/-! ### `read` with a pad region -/

/-- `readParts`' region branch in full: the body's `instructions` from `body` to `limit` (ending
at `limit` without counters), then the region's from right after its entry, and the result
their concatenation with the body's end. -/
theorem readParts_region_runs {fr : Frame} {ro : ByteArray} {callSites : Array CallSite}
    {d1 d2 : List DroppedStore} {stubs : Option Nat} {body limit size r : Nat}
    {targets : Option (Array Nat)} {c c' : Cursor} {x : Array Proto × Array Bool × Nat}
    (h : (readParts fr ro callSites d1 d2 stubs (some r) body limit size targets).run c =
      .ok (x, c')) :
    ∃ (qB qR : Array Proto) (pB pR : Array Bool) (cB : Cursor),
      (instructions fr ro d1 targets stubs limit callSites).run (atPos c body) =
        .ok ((qB, pB), cB) ∧
      (fr.mode.counters = true ∨ cB.pos = limit) ∧
      (∀ x ∈ qB.toList, x.pos < limit) ∧
      (instructions { fr with region := true } ro d2 targets none size callSites).run
        (atPos c (r + regionEntryLen)) = .ok ((qR, pR), c') ∧
      x = (qB ++ qR, pB ++ pR, cB.pos) := by
  unfold readParts at h
  obtain ⟨u, c1, h1, h⟩ := bind_ok h
  rw [run_setPos] at h1; cases h1
  obtain ⟨⟨ps, pd⟩, c2, h2, h⟩ := bind_ok h
  have e2 := (instructions_read h2).2.1
  obtain ⟨be, c3, h3, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pos_run' h3
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  obtain ⟨hcond, rfl⟩ := expect_ok h4
  try dsimp only at h
  obtain ⟨u, c4', h4', h⟩ := bind_ok h
  obtain ⟨hall, rfl⟩ := expect_ok h4'
  obtain ⟨⟨rp, rpd⟩, c5, h5, h⟩ := bind_ok h
  obtain ⟨hx, rfl⟩ := pure_ok h
  unfold readRegion at h5
  obtain ⟨u, c6, h6, h5⟩ := bind_ok h5
  rw [run_setPos] at h6; cases h6
  obtain ⟨i1, c7, h7, h5⟩ := bind_ok h5
  obtain ⟨n1, hd1, rfl⟩ := run_item h7
  obtain ⟨u, c8, h8, h5⟩ := bind_ok h5
  obtain ⟨he1, rfl⟩ := expect_ok h8
  obtain ⟨i2, c9, h9, h5⟩ := bind_ok h5
  obtain ⟨n2, hd2, rfl⟩ := run_item h9
  obtain ⟨q, c10, h10, h5⟩ := bind_ok h5
  obtain ⟨rfl, rfl⟩ := pos_run' h10
  obtain ⟨u, c11, h11, h5⟩ := bind_ok h5
  obtain ⟨he2, rfl⟩ := expect_ok h11
  simp only [Bool.and_eq_true, beq_iff_eq] at he2
  obtain ⟨-, hq⟩ := he2
  have hR : (instructions { fr with region := true } ro d2 targets none size callSites).run
      (atPos c (r + n1 + n2)) = .ok ((rp, rpd), c5) := by
    rw [e2] at h5
    exact h5
  rw [hq] at hR
  refine ⟨ps, rp, pd, rpd, _, h2, ?_, ?_, hR, hx.symm⟩
  · simp only [Bool.or_eq_true, beq_iff_eq] at hcond
    exact hcond
  · intro y hy
    have := Array.all_eq_true.1 hall
    obtain ⟨i, hi, rfl⟩ := List.getElem_of_mem hy
    have h' := this i (by simpa using hi)
    simpa using h'

/-! ### Moving iterations -/

theorem padRead_atPos {c : Cursor} {q0 : Nat} :
    ∀ {p q : Nat}, PadRead (atPos c q0) p q → PadRead c p q := by
  intro p q h
  induction h with
  | nil p => exact .nil p
  | nop h1 h9 hb hr _ ih => exact .nop h1 h9 hb hr ih

theorem counterRead_atPos {fr : Frame} {c : Cursor} {q0 p1 p2 : Nat} {k : Option (Nat × Nat)}
    (h : CounterRead fr (atPos c q0) p1 k p2) : CounterRead fr c p1 k p2 := by
  cases h with
  | none => exact .none _
  | check hc hd => exact .check hc (Dec.at_iff.1 hd)

theorem protoRead_atPos {fr : Frame} {ro : ByteArray} {ex : Bool} {c : Cursor} {q0 p : Nat}
    {cache cache' : Cache} {dr dr' : List DroppedStore} {a : Bool} {q : Proto} {c' : Cursor}
    (h : ProtoRead fr ro ex (atPos c q0) p cache dr a q c' cache' dr') :
    ProtoRead fr ro ex c p cache dr a q c' cache' dr' := by
  cases h with
  | arg h => exact .arg h
  | call hn h => exact .call hn h
  | inline hn h1 h2 => exact .inline hn h1 h2
  | insn hn h1 h2 h3 => exact .insn hn h1 h2 h3

theorem nopRead_atPos {fr : Frame} {cs : Array CallSite} {c : Cursor} {q0 : Nat} {q : Proto}
    {p p' : Nat} (h : NopRead fr cs (atPos c q0) q p p') : NopRead fr cs c q p p' := by
  cases h with
  | none h => exact .none h
  | nop h hb hr => exact .nop h hb hr

theorem iter_atPos {fr : Frame} {ro : ByteArray} {t : Option (Array Nat)} {cs : Array CallSite}
    {c : Cursor} {q0 : Nat} {a : Bool} {p : Nat} {cache cache' : Cache}
    {dr dr' : List DroppedStore} {q : Proto} {p' : Nat}
    (h : Iter fr ro t cs (atPos c q0) a p cache dr q p' cache' dr') :
    Iter fr ro t cs c a p cache dr q p' cache' dr' := by
  cases h with
  | empty hd hin => exact .empty hd hin
  | main hpad hctr hpr hnop =>
    exact .main (padRead_atPos hpad) (counterRead_atPos hctr) (protoRead_atPos hpr)
      (nopRead_atPos hnop)

theorem protoRead_args {fr : Frame} {ro : ByteArray} {ex : Bool} {c : Cursor} {p : Nat}
    {cache cache' : Cache} {dr dr' : List DroppedStore} {a : Bool} {q : Proto} {c' : Cursor}
    (h : ProtoRead fr ro ex c p cache dr a q c' cache' dr') (ha : a = false ∨ q.op ≠ .arg)
    (a' : Bool) : ProtoRead fr ro ex c p cache dr a' q c' cache' dr' := by
  cases h with
  | arg h =>
    exfalso
    rcases ha with ha | ha
    · cases ha
    · obtain ⟨x, d, hq, -⟩ := argInsn_bounds h
      exact ha (by rw [hq])
  | call hn h => exact .call hn h
  | inline hn h1 h2 => exact .inline hn h1 h2
  | insn hn h1 h2 h3 => exact .insn hn h1 h2 h3

/-- An iteration that doesn't read an `arg` (or ran with the flag off) reads alike with any
leading-`arg` flag (`NoArg` ignores it). -/
theorem iter_args {fr : Frame} {ro : ByteArray} {t : Option (Array Nat)} {cs : Array CallSite}
    {c : Cursor} {a : Bool} {p : Nat} {cache cache' : Cache}
    {dr dr' : List DroppedStore} {q : Proto} {p' : Nat}
    (h : Iter fr ro t cs c a p cache dr q p' cache' dr') (ha : a = false ∨ q.op ≠ .arg)
    (a' : Bool) : Iter fr ro t cs c a' p cache dr q p' cache' dr' := by
  cases h with
  | empty hd hin => exact .empty hd hin
  | main hpad hctr hpr hnop => exact .main hpad hctr (protoRead_args hpr ha a') hnop

theorem iter_congr {fr : Frame} {ro : ByteArray} {t : Option (Array Nat)} {cs : Array CallSite}
    {c : Cursor} {a a2 : Bool} {p p2 pe pe2 : Nat} {ca ca2 cb cb2 : Cache}
    {dr dr2 de de2 : List DroppedStore} {q q2 : Proto}
    (h : Iter fr ro t cs c a p ca dr q pe cb de) (e1 : a = a2) (e2 : p = p2) (e3 : ca = ca2)
    (e4 : dr = dr2) (e5 : q = q2) (e6 : pe = pe2) (e7 : cb = cb2) (e8 : de = de2) :
    Iter fr ro t cs c a2 p2 ca2 dr2 q2 pe2 cb2 de2 := by
  subst e1 e2 e3 e4 e5 e6 e7 e8
  exact h

theorem ite_pos_eq {α : Type} {c : Prop} [Decidable c] {x y : α} (h : c) :
    x = (if c then x else y) := (if_pos h).symm

theorem ite_neg_eq {α : Type} {c : Prop} [Decidable c] {x y : α} (h : ¬c) :
    y = (if c then x else y) := (if_neg h).symm

/-! ### `resumeSlots` -/

theorem resumeFix_of_not {slot : Option (BitVec 32)} {fr : Frame} {q : Proto}
    (h : ¬ (q.op == .resume) = true) : resumeFix slot fr q = q := by
  unfold resumeFix
  rw [if_neg h]

/-- A loop over indices that sets each `i` where `P i` to `v i`: the result. -/
theorem forIn_set_loop {F : Nat → Array Proto → DM (ForInStep (Array Proto))}
    (P : Nat → Prop) [DecidablePred P] (v : Nat → Proto)
    (hstep : ∀ i o c r c', (F i o).run c = .ok (r, c') →
      r = .yield (if P i then o.set! i (v i) else o)) :
    ∀ (l : List Nat) (init : Array Proto) (c c' : Cursor) (o : Array Proto), l.Nodup →
      (forIn l init F).run c = .ok (o, c') →
      o.size = init.size ∧ ∀ i, o[i]! = if i ∈ l ∧ i < init.size ∧ P i then v i else init[i]! := by
  intro l
  induction l with
  | nil =>
    intro init c c' o _ h
    simp only [List.forIn_nil] at h
    obtain ⟨rfl, -⟩ := pure_ok h
    exact ⟨rfl, fun i => by simp⟩
  | cons a l ih =>
    intro init c c' o hnd h
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    have hr := hstep a init c r c1 h1
    subst hr
    have hnd' := List.nodup_cons.1 hnd
    obtain ⟨hsz, hix⟩ := ih _ c1 c' o hnd'.2 h2
    have hsz' : (if P a then init.set! a (v a) else init).size = init.size := by
      split <;> simp
    refine ⟨hsz.trans hsz', fun i => ?_⟩
    rw [hix i, hsz']
    by_cases hia : i = a
    · subst hia
      have hn : ¬ (i ∈ l) := hnd'.1
      simp only [hn, false_and, ↓reduceIte, List.mem_cons, true_or, true_and]
      by_cases hP : P i
      · rw [if_pos hP]
        by_cases hlt : i < init.size
        · rw [if_pos ⟨hlt, hP⟩, Array.getElem!_set!_self _ _ _ hlt]
        · rw [if_neg (fun h => hlt h.1)]
          simp only [Array.set!_eq_setIfInBounds, Array.setIfInBounds, hlt, ↓reduceDIte]
      · rw [if_neg hP, if_neg (fun h => hP h.2)]
    · have hv : (if P a then init.set! a (v a) else init)[i]! = init[i]! := by
        split
        · exact Array.getElem!_set!_ne _ _ _ _ (Ne.symm hia)
        · rfl
      rw [hv]
      simp only [List.mem_cons, hia, false_or]

/-- `resumeSlots`: from `rs` on, each proto as `resumeFix` leaves it (a `resume` gets the
landing pads' slot), the others as they were. -/
theorem resumeSlots_eq {protos : Array Proto} {rs : Nat} {fr : Frame} {c c' : Cursor}
    {out : Array Proto} (h : (resumeSlots protos rs fr).run c = .ok (out, c')) :
    out.size = protos.size ∧ ∀ i, i < protos.size →
      out[i]! = if rs ≤ i then resumeFix (lpadSlotOf protos) fr protos[i]! else protos[i]! := by
  unfold resumeSlots at h
  try dsimp only at h
  obtain ⟨o, c1, h1, h2⟩ := bind_ok h
  try dsimp only at h2
  obtain ⟨rfl, -⟩ := pure_ok h2
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h1
  have key := forIn_set_loop (fun i => (protos[i]!.op == .resume) = true)
    (fun i => resumeFix (lpadSlotOf protos) fr protos[i]!) ?step _ protos c c1 o
    (List.nodup_range' 1) h1
  case step =>
    intro a b cur r cur' hr
    try dsimp only at hr
    split at hr
    · rename_i hres
      split at hr
      · rename_i x hx
        obtain ⟨rfl, -⟩ := pure_ok hr
        have hx' : lpadSlotOf protos = some x := hx
        rw [if_pos hres]
        simp only [resumeFix, hres, ↓reduceIte, hx']
      · exact (err_ok hr).elim
    · rename_i hres
      obtain ⟨rfl, -⟩ := pure_ok hr
      rw [if_neg hres]
  obtain ⟨hsz, hix⟩ := key
  refine ⟨hsz, fun i hi => ?_⟩
  rw [hix i]
  by_cases hle : rs ≤ i
  · rw [if_pos hle]
    have hmem : i ∈ List.range' rs (Std.Legacy.Range.size [rs:protos.size]) 1 := by
      simp only [List.mem_range', Std.Legacy.Range.size]
      exact ⟨i - rs, by omega, by omega⟩
    by_cases hres : (protos[i]!.op == .resume) = true
    · rw [if_pos ⟨hmem, hi, hres⟩]
    · rw [if_neg (fun h => hres h.2.2), resumeFix_of_not hres]
  · rw [if_neg hle]
    have hmem : ¬ i ∈ List.range' rs (Std.Legacy.Range.size [rs:protos.size]) 1 := by
      simp [List.mem_range', Std.Legacy.Range.size]; omega
    rw [if_neg (fun h => hmem h.1)]

theorem list_find?_congr {P : Proto → Bool} : ∀ (xs ys : List Proto), ys.length = xs.length →
    (∀ i (hi : i < xs.length) (hj : i < ys.length),
      ys[i] = xs[i] ∨ (P ys[i] = false ∧ P xs[i] = false)) →
    ys.find? P = xs.find? P
  | [], [], _, _ => rfl
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl
  | x :: xs, y :: ys, hl, h => by
    have h0 := h 0 (by simp) (by simp)
    simp only [List.getElem_cons_zero] at h0
    have ih := list_find?_congr xs ys (by simpa using hl) (fun i hi hj => by
      have := h (i + 1) (by simpa using hi) (by simpa using hj)
      simpa using this)
    rcases h0 with e | ⟨e1, e2⟩
    · rw [e]
      cases hx : P x <;> simp [hx, ih]
    · simp only [List.find?_cons, e1, e2]
      exact ih

/-- `resumeSlots` keeps the landing pads' slot (it rewrites only `resume`s). -/
theorem resumeSlots_lpadSlot {protos : Array Proto} {rs : Nat} {fr : Frame} {c c' : Cursor}
    {out : Array Proto} (h : (resumeSlots protos rs fr).run c = .ok (out, c')) :
    lpadSlotOf out = lpadSlotOf protos := by
  obtain ⟨hsz, hix⟩ := resumeSlots_eq h
  have hf : out.toList.find? (·.op == .lpad) = protos.toList.find? (·.op == .lpad) := by
    refine list_find?_congr _ _ (by simp [hsz]) fun i hi hj => ?_
    have hi' : i < protos.size := by simpa using hi
    have hj' : i < out.size := by simpa using hj
    have e := hix i hi'
    rw [getElem!_pos out i hj', getElem!_pos protos i hi'] at e
    simp only [Array.getElem_toList]
    split at e
    · by_cases hres : (protos[i].op == .resume) = true
      · right
        have hop : protos[i].op = .resume := by simpa using hres
        rw [e, resumeFix_op, hop]
        exact ⟨by decide, by decide⟩
      · left
        rw [e, resumeFix_of_not hres]
    · left
      exact e
  unfold lpadSlotOf
  rw [← Array.find?_toList, ← Array.find?_toList, hf]

/-! ### Positions and the region's start -/

/-- An iteration chain's first proto starts at or after the chain's start. -/
theorem iters_head_pos {fr : Frame} {ro : ByteArray} {t : Option (Array Nat)} {cs : Array CallSite}
    {c : Cursor} {a : Bool} {s : Nat} {cache : Cache} {dr : List DroppedStore} {qs : List Proto}
    {pe : Nat} {dre : List DroppedStore} (h : Iters fr ro t cs c a s cache dr qs pe dre) :
    ∀ y, qs.head? = some y → s ≤ y.pos := by
  intro y hy
  cases h with
  | nil => simp at hy
  | cons hi _ =>
    simp only [List.head?_cons, Option.some.injEq] at hy
    subst hy
    cases hi with
    | empty _ _ => exact Nat.le_refl _
    | main hpad _ _ _ => exact hpad.le

theorem takeWhile_len_append {P : Proto → Bool} : ∀ (l1 l2 : List Proto),
    (∀ x ∈ l1, P x = true) → (∀ y, l2.head? = some y → P y = false) →
    ((l1 ++ l2).takeWhile P).length = l1.length
  | [], [], _, _ => rfl
  | [], y :: l2, _, h2 => by simp [h2 y rfl]
  | x :: l1, l2, h1, h2 => by
    have ih := takeWhile_len_append l1 l2 (fun z hz => h1 z (List.mem_cons_of_mem _ hz)) h2
    simp [h1 x (List.mem_cons_self ..), ih]

/-! ### `checkStubs`' end -/

theorem sl_forIn'_end {α β : Type} (P : Cursor → Prop) (Q : α → Prop) :
    ∀ (l : List α) (f : (a : α) → a ∈ l → β → DM (ForInStep β)) (init b : β) (c c' : Cursor),
      (∀ a (h : a ∈ l) b c r c', P c → (f a h b).run c = .ok (r, c') →
        P c' ∧ Q a ∧ ∃ b', r = .yield b') →
      P c → (forIn' l init f).run c = .ok (b, c') → P c'
  | [], _, _, _, _, _, _, h0, h => by
    simp only [List.forIn'_nil] at h
    obtain ⟨-, rfl⟩ := pure_ok h
    exact h0
  | a :: l, f, init, b, c, c', hs, h0, h => by
    simp only [List.forIn'_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    obtain ⟨hP1, -, b', rfl⟩ := hs a (by simp) init c r c1 h0 h1
    exact sl_forIn'_end P Q l _ b' b c1 c'
      (fun a'' h'' => hs a'' (List.mem_cons_of_mem a h'')) hP1 h2

/-- `checkStubs` with an entry stub reads from the body's end to `limit`: a property kept by
`Dec` from `bodyEnd` holds at `limit`. -/
theorem checkStubs_end {es eb : Nat} {protos : Array Proto} {heads : Array Nat}
    {bodyEnd limit : Nat} {c c' : Cursor} {u : Unit} (R : Nat → Prop)
    (hR : ∀ p L q, R p → Dec c p L q → R q) (hR0 : R bodyEnd)
    (h : (checkStubs (some (es, eb)) protos heads bodyEnd limit).run c = .ok (u, c')) :
    R limit := by
  unfold checkStubs at h
  dsimp only at h
  obtain ⟨u1, c1, h1, h⟩ := bind_ok h
  rw [run_setPos] at h1
  cases h1
  obtain ⟨u2, c2, h2, h⟩ := bind_ok h
  rw [Std.Legacy.Range.forIn'_eq_forIn'_range'] at h2
  have key := sl_forIn'_end (fun c2 => c2 = atPos c c2.pos ∧ R c2.pos) (fun _ => True)
    _ _ _ _ _ _ ?step ⟨rfl, hR0⟩ h2
  case step =>
    intro n hmem b cur r cur' hP0 hr
    obtain ⟨hP, hRc⟩ := hP0
    have hlt0 : n < (heads.toList.map (fun i => protos[i]!.counter.getD (0, 0)) ++
        [(es, eb)]).length := by
      obtain ⟨i, hi, hni⟩ := List.mem_range'.1 hmem
      simp only [Std.Legacy.Range.size, List.length_append, List.length_map,
        Array.length_toList, List.length_singleton] at hi hni ⊢
      omega
    generalize heq : (heads.toList.map (fun i => protos[i]!.counter.getD (0, 0)) ++
      [(es, eb)])[n]'hlt0 = sb at hr
    obtain ⟨stub, back⟩ := sb
    try dsimp only at hr
    obtain ⟨at_, c1, h1, hr⟩ := bind_ok hr
    obtain ⟨rfl, hc1⟩ := pos_run' h1
    subst c1
    try dsimp only at hr
    rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨hne, hr⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
    obtain ⟨c2, d2, e2, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
    have P2 := sl_trans hP e2
    try dsimp only at hr
    rcases sl_ite_ok hr with ⟨hlt, hr⟩ | ⟨hlt, hr⟩
    · obtain ⟨c3, d3, e3, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
      obtain ⟨c4, d4, e4, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
      obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      obtain ⟨d5, e5⟩ := item_dec h5
      have P3 := sl_trans P2 e3
      have P4 := sl_trans P3 e4
      have P5 := sl_trans P4 e5
      have d := (sl_dec hP d2).append ((sl_dec P2 d3).append ((sl_dec P3 d4).append (sl_dec P4 d5)))
      have hR5 := hR _ _ _ hRc d
      try dsimp only at hr
      split at hr
      · try dsimp only at hr
        rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        exact ⟨⟨P5, hR5⟩, trivial, _, rfl⟩
      · first
          | exact (err_ok hr).elim
          | (obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim)
    · obtain ⟨c3, d3, e3, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
      obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      obtain ⟨d5, e5⟩ := item_dec h5
      have P3 := sl_trans P2 e3
      have P5 := sl_trans P3 e5
      have d := (sl_dec hP d2).append ((sl_dec P2 d3).append (sl_dec P3 d5))
      have hR5 := hR _ _ _ hRc d
      try dsimp only at hr
      split at hr
      · try dsimp only at hr
        rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        exact ⟨⟨P5, hR5⟩, trivial, _, rfl⟩
      · first
          | exact (err_ok hr).elim
          | (obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim)
  obtain ⟨-, hR2⟩ := key
  -- the final check: the stubs end at `limit`
  obtain ⟨q1, c3, h3, h⟩ := bind_ok h
  obtain ⟨hq1, hc3⟩ := pos_run' h3
  subst hq1
  rw [hc3] at h
  try (obtain ⟨q2, c4, h4, h⟩ := bind_ok h
       obtain ⟨hq2, hc4⟩ := pos_run' h4
       subst hq2
       rw [hc4] at h)
  rcases sl_ite_ok h with ⟨-, h⟩ | ⟨hne, -⟩
  · first
      | exact (err_ok h).elim
      | (obtain ⟨_, _, -, h'⟩ := bind_ok h; exact (err_ok h').elim)
      | (obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim)
  have e : c2.pos = limit := by simpa using hne
  rw [← e]
  exact hR2

end Ryo.Proofs.DecodeSound
