/-
Ryo.Proofs.Discharge.StubsLinked — the counter stubs `read` checks (`checkStubs`), toward the
`Hyps` field `stubsLinked`.

- `sl_checkStubs`: a successful `checkStubs` with the entry's stub read, for the `n`th loop head,
  `lea r11, [rip + rec]; mov eax, n; call [r11 + 16]; jmp back` at the head's stub position, from
  the cursor `checkStubs` starts at.
- `sl_heads`: a proto with a counter check is a loop head (`heads[n]` for some `n`), and then
  `mode.counters`; `sl_readFrame_entry`: with counters `readFrame` returns the entry's stub.
- `sl_loopHeads_pos`: `loopHeads` moves only the position.
- `sl_read_stubs`: `read` (no pad region) reads every loop head's stub from the body's cursor.
- `stubsDec_of_decodes`: the `Dec` part of `StubsLinked` from `Decodes`.
- `stubsLinked_of_decodes`: `StubsLinked`, given the stubs' relocation boundaries (`Boundary`
  needs the relocations sorted, `LinkOk`, which `Decodes` doesn't give).
-/
import Ryo.Proofs.DecodeSound.Basic

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.DecodeLink

/-! ### Generic steps -/

theorem sl_ite_ok {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α}
    (h : (if p then x else y).run c = .ok (a, c')) :
    (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
  by_cases hp : p
  · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
  · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩

theorem sl_trans {a b d : Cursor} (h1 : b = atPos a b.pos) (h2 : d = atPos b d.pos) :
    d = atPos a d.pos := by
  rw [h2, h1]

theorem sl_dec {a b : Cursor} {p q : Nat} {L : List Item} (e : b = atPos a b.pos)
    (d : Dec b p L q) : Dec a p L q := by
  have h := Dec.at_iff (c := a) (r := b.pos) (p := p) (q := q) (items := L)
  rw [← e] at h
  exact h.mp d

theorem sl_indexAt (ipos : Array Nat) (at_ b : Nat) : PosOnly (indexAt ipos at_ b) := by
  intro c a c' h
  unfold indexAt at h
  try dsimp only at h
  split at h
  · obtain ⟨-, rfl⟩ := pure_ok h; rfl
  · exact (err_ok h).elim

theorem sl_forIn'_pos {α β : Type} :
    ∀ (l : List α) (f : (a : α) → a ∈ l → β → DM (ForInStep β)) (init b : β) (c c' : Cursor),
      (∀ a h b, PosOnly (f a h b)) → (forIn' l init f).run c = .ok (b, c') → c' = atPos c c'.pos
  | [], f, init, b, c, c', _, h => by
    simp only [List.forIn'_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    rfl
  | a :: l, f, init, b, c, c', hs, h => by
    simp only [List.forIn'_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    have e1 := hs a (by simp) init c r c1 h1
    cases r with
    | done b' => obtain ⟨rfl, rfl⟩ := pure_ok h2; exact e1
    | yield b' =>
      have e2 := sl_forIn'_pos l _ b' b c1 c'
        (fun a' ha' => hs a' (List.mem_cons_of_mem a ha')) h2
      rw [e2, e1]

/-- A `for'` loop whose body keeps `P` of the cursor, always yields, and shows `Q` of its
element: `Q` of every element. -/
theorem sl_forIn'_each {α β : Type} (P : Cursor → Prop) (Q : α → Prop) :
    ∀ (l : List α) (f : (a : α) → a ∈ l → β → DM (ForInStep β)) (init b : β) (c c' : Cursor),
      (∀ a (h : a ∈ l) b c r c', P c → (f a h b).run c = .ok (r, c') →
        P c' ∧ Q a ∧ ∃ b', r = .yield b') →
      P c → (forIn' l init f).run c = .ok (b, c') → ∀ a ∈ l, Q a
  | [], _, _, _, _, _, _, _, _ => by simp
  | a :: l, f, init, b, c, c', hs, h0, h => by
    simp only [List.forIn'_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    obtain ⟨hP1, hQ, b', rfl⟩ := hs a (by simp) init c r c1 h0 h1
    intro a' ha'
    rcases List.mem_cons.mp ha' with rfl | ha'
    · exact hQ
    · exact sl_forIn'_each P Q l _ b' b c1 c'
        (fun a'' h'' => hs a'' (List.mem_cons_of_mem a h'')) hP1 h2 a' ha'

theorem sl_forIn_all {α β : Type} :
    ∀ (l : List α) (f : α → β → DM (ForInStep β)) (init b : β) (c c' : Cursor),
      (∀ a b c r c', (f a b).run c = .ok (r, c') → ∃ b', r = .yield b') →
      (forIn l init f).run c = .ok (b, c') →
      ∀ a ∈ l, ∃ b c r c', (f a b).run c = .ok (r, c')
  | [], _, _, _, _, _, _, _ => by simp
  | a :: l, f, init, b, c, c', hy, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    obtain ⟨b', rfl⟩ := hy a init c r c1 h1
    intro a' ha'
    rcases List.mem_cons.mp ha' with rfl | ha'
    · exact ⟨_, _, _, _, h1⟩
    · exact sl_forIn_all l f b' b c1 c' hy h2 a' ha'

macro "sl_posonly" : tactic => `(tactic| repeat (first
  | exact PosOnly.pure _ | exact PosOnly.pos | exact PosOnly.setPos _ | exact PosOnly.err _ _
  | exact PosOnly.tryItem | exact PosOnly.item | exact PosOnly.fuel | exact PosOnly.get'
  | exact sl_indexAt _ _ _
  | refine PosOnly.bind ?_ (fun _ => ?_)
  | refine PosOnly.forIn_range _ _ _ (fun _ _ => ?_)
  | refine PosOnly.forIn_list _ _ _ (fun _ _ => ?_)
  | split
  | dsimp only))

/-! ### `readFrame`, `loopHeads` -/

/-- With counters, `readFrame` returns the entry's counter check. -/
theorem sl_readFrame_entry {mode : Mode} {c c' : Cursor} {entry : Option (Nat × Nat)} {fs : Nat}
    (h : (readFrame mode).run c = .ok ((entry, fs), c')) (hc : mode.counters = true) :
    entry.isSome = true := by
  unfold readFrame at h
  rcases sl_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h1, -⟩ := bind_ok h; exact (err_ok h1).elim
  obtain ⟨e0, c1, h1, h⟩ := bind_ok h
  have he0 : e0.isSome = true := by
    rcases sl_ite_ok h1 with ⟨-, h1⟩ | ⟨hn, -⟩
    · obtain ⟨i1, ca, -, h1⟩ := bind_ok h1
      obtain ⟨i2, cb, -, h1⟩ := bind_ok h1
      split at h1
      · obtain ⟨p, cc, -, h1⟩ := bind_ok h1
        obtain ⟨rfl, -⟩ := pure_ok h1
        rfl
      · exact (err_ok h1).elim
    · exact absurd hc hn
  obtain ⟨start, c2, -, h⟩ := bind_ok h
  obtain ⟨fu, c3, -, h⟩ := bind_ok h
  obtain ⟨alloc, c4, -, h⟩ := bind_ok h
  rcases sl_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h4, -⟩ := bind_ok h; exact (err_ok h4).elim
  obtain ⟨u, c5, -, h⟩ := bind_ok h
  obtain ⟨u, c6, -, h⟩ := bind_ok h
  rcases sl_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨u, c7, -, h⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h
    cases he
    exact he0
  · obtain ⟨he, -⟩ := pure_ok h
    cases he
    exact he0

/-- `loopHeads` moves only the position. -/
theorem sl_loopHeads_pos {mode : Mode} {protos : Array Proto} {padded : Array Bool} {rs : Nat}
    {heads : Array Nat} {c c' : Cursor}
    (h : (loopHeads mode protos padded rs).run c = .ok (heads, c')) : c' = atPos c c'.pos := by
  unfold loopHeads at h
  obtain ⟨head, c10, h10, h⟩ := bind_ok h
  obtain ⟨u, c11, h11, h⟩ := bind_ok h
  obtain ⟨-, rfl⟩ := pure_ok h
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h11
  rw [Std.Legacy.Range.forIn'_eq_forIn'_range'] at h10
  have e11 := PosOnly.forIn_list _ _ _ (fun _ _ => by sl_posonly) _ _ _ h11
  have e10 := sl_forIn'_pos _ _ _ _ _ _ (fun _ _ _ => by sl_posonly) h10
  rw [e11, e10]

/-- A proto with a counter check is a loop head (`heads[n]`), and counters are on. -/
theorem sl_heads {mode : Mode} {protos : Array Proto} {padded : Array Bool} {rs : Nat}
    {heads : Array Nat} {c c' : Cursor}
    (h : (loopHeads mode protos padded rs).run c = .ok (heads, c')) :
    ∀ k (hk : k < protos.size), protos[k].counter.isSome = true →
      mode.counters = true ∧ ∃ n, ∃ hn : n < heads.size, heads[n] = k := by
  unfold loopHeads at h
  obtain ⟨head, c10, -, h⟩ := bind_ok h
  obtain ⟨u, c11, h11, h⟩ := bind_ok h
  obtain ⟨rfl, -⟩ := pure_ok h
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h11
  have hall := sl_forIn_all _ _ _ _ _ _ ?_ h11
  · intro k hk hc
    obtain ⟨b, c, r, c', hr⟩ := hall k (by simp [List.mem_range', Std.Legacy.Range.size]; omega)
    dsimp only at hr
    rcases sl_ite_ok hr with ⟨-, h⟩ | ⟨-, h⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    rcases sl_ite_ok h with ⟨-, h⟩ | ⟨hn, -⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    have hk' : protos[k]! = protos[k] := by simp [getElem!_def, hk]
    rw [hk', hc] at hn
    have h2 : (mode.counters && head[k]!) = true := by
      revert hn; cases (mode.counters && head[k]!) <;> simp
    rw [Bool.and_eq_true] at h2
    refine ⟨h2.1, ?_⟩
    have hmem : k ∈ (List.range protos.size).filter (fun j => head[j]!) :=
      List.mem_filter.mpr ⟨List.mem_range.mpr hk, h2.2⟩
    obtain ⟨n, hn, he⟩ := List.getElem_of_mem hmem
    exact ⟨n, by simpa using hn, by simpa using he⟩
  · intro a b c r c' hr
    dsimp only at hr
    rcases sl_ite_ok hr with ⟨-, h⟩ | ⟨-, h⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    rcases sl_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    obtain ⟨rfl, -⟩ := pure_ok h; exact ⟨_, rfl⟩

/-! ### `checkStubs` -/

/-- What `checkStubs` reads for the `n`th loop head: its stub, at the stub position its counter
check names, returning to where the check says. -/
theorem sl_checkStubs {entry : Option (Nat × Nat)} {protos : Array Proto} {heads : Array Nat}
    {bodyEnd limit : Nat} {c c' : Cursor} {u : Unit}
    (h : (checkStubs entry protos heads bodyEnd limit).run c = .ok (u, c'))
    (he : entry.isSome = true) :
    ∀ n (hn : n < heads.size), ∃ stub back,
      protos[heads[n]]!.counter.getD (0, 0) = (stub, back) ∧
      ∃ t long q, t.toNat = back ∧ Dec c stub [.lea .r11 .record,
        .setReg .rax (BitVec.ofNat 64 n), .callR11 16, .branch .always t long] q := by
  obtain ⟨⟨es, eb⟩, rfl⟩ := Option.isSome_iff_exists.mp he
  unfold checkStubs at h
  dsimp only at h
  obtain ⟨u1, c1, h1, h⟩ := bind_ok h
  rw [run_setPos] at h1
  cases h1
  obtain ⟨u2, c2, h2, -⟩ := bind_ok h
  rw [Std.Legacy.Range.forIn'_eq_forIn'_range'] at h2
  have key := sl_forIn'_each (fun c2 => c2 = atPos c c2.pos)
    (fun n => n < heads.size → ∃ stub back,
      (heads.toList.map (fun i => protos[i]!.counter.getD (0, 0)) ++ [(es, eb)])[n]? =
        some (stub, back) ∧
      ∃ t long q, t.toNat = back ∧ Dec c stub [.lea .r11 .record,
        .setReg .rax (BitVec.ofNat 64 n), .callR11 16, .branch .always t long] q)
    _ _ _ _ _ _ ?step rfl h2
  case step =>
    intro n hmem b cur r cur' hP hr
    have hP : cur = atPos c cur.pos := hP
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
    have hs : cur.pos = stub := by simpa using hne
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
      rw [hs] at d
      simp only [List.singleton_append] at d
      try dsimp only at hr
      split at hr
      · try dsimp only at hr
        rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨hb, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        refine ⟨P5, ?_, _, rfl⟩
        intro _
        exact ⟨stub, back, List.getElem?_eq_some_iff.mpr ⟨_, heq⟩, _, _, _, by simpa using hb, d⟩
      · first
          | exact (err_ok hr).elim
          | (obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim)
    · obtain ⟨c3, d3, e3, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
      obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      obtain ⟨-, e5⟩ := item_dec h5
      have P5 := sl_trans (sl_trans P2 e3) e5
      try dsimp only at hr
      split at hr
      · try dsimp only at hr
        rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        refine ⟨P5, ?_, _, rfl⟩
        intro h
        exact absurd h hlt
      · first
          | exact (err_ok hr).elim
          | (obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim)
  intro n hn
  obtain ⟨stub, back, hL, rest⟩ :=
    key n (by simp [List.mem_range', Std.Legacy.Range.size] <;> omega) hn
  refine ⟨stub, back, ?_, rest⟩
  rw [List.getElem?_append_left (by simpa using hn)] at hL
  simpa [hn] using hL

/-! ### `read` -/

/-- `read` (no pad region) reads every loop head's counter stub, from a cursor that is the body's
(`bodyCursor`) at another position. -/
theorem sl_read_stubs {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hnr : regionPad mode callSites = none) :
    ∃ c1 c9 : Cursor, c1 = bodyCursor c mode r.frameSize c1.pos ∧ c9 = atPos c1 c9.pos ∧
      ∀ k (hk : k < r.protos.size) stub back, r.protos[k].counter = some (stub, back) →
        ∃ n t long q, t.toNat = back ∧ Dec c9 stub [.lea .r11 .record,
          .setReg .rax (BitVec.ofNat 64 n), .callR11 16, .branch .always t long] q := by
  unfold Vm.read at h
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  have hc1 := readFrame_body h1
  dsimp only at h
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  have hra : ra = none ∧ c3 = c1 := by
    unfold regionEntry at h3; rw [hnr] at h3
    exact ⟨(pure_ok h3).1.symm, (pure_ok h3).2.symm⟩
  rw [hra.1, hra.2] at h
  dsimp only at h
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  obtain ⟨-, hc4⟩ := pos_run' h4
  rw [hc4] at h
  obtain ⟨⟨p1, pd1, be1⟩, c5, h5, h⟩ := bind_ok h
  have e5 := readParts_pos h5
  try dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, h6, h⟩ := bind_ok h
  have e6 := readParts_pos h6
  dsimp only at h
  obtain ⟨u, c8, h8, h⟩ := bind_ok h
  have e8 : c8 = c6 := by
    first
      | exact (pure_ok h8).2.symm
      | (simp only [checkRegionStart] at h8; exact (pure_ok h8).2.symm)
  obtain ⟨heads, c9, h9, h⟩ := bind_ok h
  have e9 := sl_loopHeads_pos h9
  have hh := sl_heads h9
  obtain ⟨u', c10, h10, h⟩ := bind_ok h
  simp only [Nat.lt_irrefl, ↓reduceIte] at h
  obtain ⟨protos', c11, h11, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pure_ok h11
  obtain ⟨acts, c12, -, h⟩ := bind_ok h
  obtain ⟨he, -⟩ := pure_ok h
  cases he
  rw [e8] at e9
  refine ⟨c1, c9, hc1, sl_trans (sl_trans e5 e6) e9, ?_⟩
  intro k hk stub back hc
  have hk0 : k < protos.size := hk
  have hc0 : protos[k].counter = some (stub, back) := hc
  obtain ⟨hcnt, n, hn, hkn⟩ := hh k hk0 (by rw [hc0]; rfl)
  obtain ⟨stub', back', hL, t, long, q, ht, hd⟩ :=
    sl_checkStubs h10 (sl_readFrame_entry h1 hcnt) n hn
  have hk' : protos[k]! = protos[k] := by simp [getElem!_def, hk0]
  rw [hkn, hk', hc0] at hL
  simp only [Option.getD_some, Prod.mk.injEq] at hL
  obtain ⟨rfl, rfl⟩ := hL
  exact ⟨n, t, long, q, ht, hd⟩

/-! ### From `Decodes` -/

section Discharge

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- The `Dec` part of `StubsLinked`: each loop head's stub, read from the body's cursor. -/
theorem stubsDec_of_decodes (hD : Decodes S code relocs rodata callSites dropped scopes mode) :
    ∀ k (hk : k < S.r.protos.size) stub back, S.r.protos[k].counter = some (stub, back) →
      ∃ n t long q, t.toNat = back ∧ Dec S.body stub [.lea .r11 .record,
        .setReg .rax (BitVec.ofNat 64 n), .callR11 16, .branch .always t long] q := by
  obtain ⟨c', hr⟩ := hD.read
  obtain ⟨c1, c9, hc1, hc9, hall⟩ := sl_read_stubs hr hD.noRegion
  have key : c9 = atPos S.body c9.pos := by
    refine hc9.trans ?_
    calc atPos c1 c9.pos
        = atPos (bodyCursor { code := code.data, pos := 0, fields := .relocs relocs } mode
            S.r.frameSize c1.pos) c9.pos := congrArg (atPos · c9.pos) hc1
      _ = atPos (bodyCursor { code := code.data, pos := 0, fields := .relocs relocs } mode
            S.r.frameSize S.body.pos) c9.pos := rfl
      _ = atPos S.body c9.pos := (congrArg (atPos · c9.pos) hD.bodyEq).symm
  intro k hk stub back hc
  obtain ⟨n, t, long, q, ht, hd⟩ := hall k hk stub back hc
  exact ⟨n, t, long, q, ht, sl_dec key hd⟩

/-- `StubsLinked` from the decoder's acceptance and the stubs' relocation boundaries (which need
the relocations sorted, `LinkOk`, beyond `Decodes`). -/
theorem stubsLinked_of_decodes (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hB : ∀ k (hk : k < S.r.protos.size) stub back, S.r.protos[k].counter = some (stub, back) →
      Boundary S.rs stub) : StubsLinked S :=
  fun k hk stub back hc => ⟨hB k hk stub back hc, stubsDec_of_decodes hD k hk stub back hc⟩

end Discharge

end Ryo.Proofs.DecodeSound
