/-
Ryo.Proofs.IslandLemmas — helpers for `Ryo.Proofs.Island`: R's island step and answer, the
island's setup items, and the frame relation after a template's writes over the `Lend` extents.
-/
import Ryo.Proofs.ArgRet
import Ryo.Proofs.Handler
import Ryo.Proofs.ScopeMem

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.IslandLemmas

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope

/-! ### Memory reads (copied from `Handler`, `Cache`) -/

theorem foldr_congr' (f g : Nat → Nat) : ∀ (l : List Nat), (∀ i ∈ l, f i = g i) →
    l.foldr (fun i acc => f i + 256 * acc) 0 = l.foldr (fun i acc => g i + 256 * acc) 0
  | [], _ => rfl
  | a :: l, h => by
    simp only [List.foldr_cons]
    rw [h a (by simp), foldr_congr' f g l (fun i hi => h i (by simp [hi]))]

theorem readNat_zero (m : Mem) (a : BitVec 64) : m.readNat a 0 = 0 := rfl

theorem readNat_succ (m : Mem) (a : BitVec 64) (k : Nat) :
    m.readNat a (k + 1) = (m a).toNat + 256 * m.readNat (a + 1) k := by
  unfold Mem.readNat
  rw [List.range_succ_eq_map]
  simp only [List.foldr_cons, List.foldr_map]
  congr 2
  · simp
  · apply foldr_congr'
    intro i _
    have : a + BitVec.ofNat 64 (i + 1) = a + 1 + BitVec.ofNat 64 i := by
      apply BitVec.eq_of_toNat_eq; simp; omega
    simp only [this]

theorem mod_split (x n : Nat) :
    x % 2 ^ (8 * (n + 1)) = x % 256 + 256 * (x / 256 % 2 ^ (8 * n)) := by
  rw [show 8 * (n + 1) = 8 + 8 * n by omega, Nat.pow_add]
  exact Nat.mod_mul

theorem readNat_write_self (m : Mem) (a : BitVec 64) (n v : Nat) (hn : n < 2 ^ 64) :
    ∀ (j k : Nat), j + k ≤ n →
    (m.write a n v).readNat (a + BitVec.ofNat 64 j) k = (v >>> (8 * j)) % 2 ^ (8 * k)
  | _, 0, _ => by simp [readNat_zero]; omega
  | j, k + 1, h => by
    rw [readNat_succ]
    have e : a + BitVec.ofNat 64 j + 1 = a + BitVec.ofNat 64 (j + 1) := by
      apply BitVec.eq_of_toNat_eq; simp; omega
    rw [e, readNat_write_self m a n v hn (j + 1) k (by omega), mod_split]
    have hb : m.write a n v (a + BitVec.ofNat 64 j) = UInt8.ofNat (v >>> (8 * j)) := by
      simp only [Mem.write]
      have : (a + BitVec.ofNat 64 j - a).toNat = j := by
        rw [BitVec.add_comm, BitVec.add_sub_cancel]; simp; omega
      rw [this, ite_eq_left (by omega)]
    rw [hb, UInt8.toNat_ofNat']
    congr 2
    rw [Nat.shiftRight_eq_div_pow, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul,
      show 8 * (j + 1) = 8 * j + 8 by omega, Nat.pow_add]

theorem read64_write_self (m : Mem) (a v : BitVec 64) :
    (m.write a 8 v.toNat).read64 a = v := by
  have := readNat_write_self m a 8 v.toNat (by decide) 0 8 (by omega)
  simp only [BitVec.add_zero, Nat.mul_zero, Nat.shiftRight_zero] at this
  simp only [Mem.read64, this]
  apply BitVec.eq_of_toNat_eq
  simp [Nat.mod_eq_of_lt v.isLt]

theorem readNat_congr (m m' : Mem) : ∀ (a : BitVec 64) (k : Nat),
    (∀ i < k, m (a + BitVec.ofNat 64 i) = m' (a + BitVec.ofNat 64 i)) →
    m.readNat a k = m'.readNat a k
  | _, 0, _ => rfl
  | a, k + 1, h => by
    rw [readNat_succ, readNat_succ]
    have h0 := h 0 (by omega)
    simp only [BitVec.add_zero] at h0
    rw [h0, readNat_congr m m' (a + 1) k (fun i hi => by
      have := h (i + 1) (by omega)
      have e : a + BitVec.ofNat 64 (i + 1) = a + 1 + BitVec.ofNat 64 i := by
        apply BitVec.eq_of_toNat_eq; simp; omega
      rwa [e] at this)]

/-- The island's setup items, as one state transformation. -/
theorem exec_pre (ctx : Ctx) (mode : Ryo.Obj.Mode) (r1 r2 : Reg) (isl o : Nat) (x : X86.State)
    (pe : Bool) (hpe : mode.pe = pe) (h1 : r1.idx ≠ Reg.rsp.idx) (h2 : r2.idx ≠ Reg.rsp.idx) :
    let items := [fpItem r1 mode, .lea r2 (.ro o)] ++
      (if pe then [Item.subRsp 32] else []) ++ [.callMem (.sym isl)]
    let sh : BitVec 64 := if pe then 32 else 0
    ∃ x1, execItems ctx items x = .ok x1 ∧
      x1.mem = x.mem.write (x.rsp - sh - 8) 8 (x.rip + BitVec.ofNat 64 (items.map Item.size).sum).toNat ∧
      x1.rip = x.mem.read64 (ctx.addrOf (.sym isl)) ∧
      x1.regs = fun i => if i = Reg.rsp.idx then x.rsp - sh - 8 else
        if i = r2.idx then ctx.addrOf (.ro o) else if i = r1.idx then x.reg .rbp else x.regs i := by
  intro items sh
  subst hpe
  have h1' : ¬ (4 : Fin 16) = r1.idx := fun h => h1 (by rw [← h]; rfl)
  have h2' : ¬ (4 : Fin 16) = r2.idx := fun h => h2 (by rw [← h]; rfl)
  cases hp : mode.pe <;> cases hf : mode.framePointer <;>
    simp only [items, sh, hp, hf, fpItem, Bool.false_eq_true, ↓reduceIte, List.cons_append,
      List.nil_append, execItems_cons, execItems_nil, Item.exec, pure, Except.pure, ex_bind_ok'] <;>
    refine ⟨_, rfl, ?_, ?_, ?_⟩
  all_goals simp only [State.push, State.setMem, State.setReg, State.jump, State.setFlags, State.rsp,
    State.reg, State.ea, M.frame, ↓reduceIte, List.map_cons, List.map_nil, List.sum_cons,
    List.sum_nil, Nat.add_zero, BitVec.ofNat_add, BitVec.add_assoc, BitVec.sub_zero, subF_eq]
  all_goals simp [h1', h2', State.reg, BitVec.sub_sub]
  all_goals funext i; by_cases hi : i = 4 <;> simp [hi]

theorem bv_add4 (A P Q : BitVec 64) : A + P + Q = A - 4 + (4 + P + Q) := by
  rw [← BitVec.add_assoc, ← BitVec.add_assoc, BitVec.sub_add_cancel]
theorem bv_subadd (r k : BitVec 64) : r - k - 8 + 8 + k = r := by
  rw [BitVec.sub_add_cancel, BitVec.sub_add_cancel]

/-- The push below the shadow space writes only on the stack. -/
theorem push_other' (lo sp a : BitVec 64) (k : Nat) (hk : k ≤ 32) (hlo : lo.toNat + 8 + k ≤ sp.toNat)
    (ha : ¬ Counter.InStack lo sp a) : 8 ≤ (a - (sp - BitVec.ofNat 64 k - 8)).toNat := by
  simp only [Counter.InStack] at ha
  have e : (BitVec.ofNat 64 k).toNat = k := by simp; omega
  have := a.isLt; have := sp.isLt
  rw [BitVec.toNat_sub, BitVec.toNat_sub, BitVec.toNat_sub, e]
  have e8 : (8 : BitVec 64).toNat = 8 := rfl
  rw [e8]
  by_cases h1 : lo.toNat ≤ a.toNat
  · have h2 : sp.toNat ≤ a.toNat := by omega
    omega
  · omega

/-- A successful step of `island isl, ops`: the scopes, then the query. -/
theorem step_island {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {f : Full.Opcode} {isl : Nat} {ws : List (BitVec 32)} {o : R.Out}
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws])) (hf : op.full = some f)
    (hsh : f.info.shape = .island) (h : R.step c s ch = .ok o) :
    ∃ s1, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      o = .ext ⟨.island isl (c.islandTemplate s1.pc) s1.fp (ws.map (·.toInt)) (c.lendsAt s1.pc),
        s1.world⟩ s1 := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf, hsh, pure, Except.pure, Except.ok.injEq] at h
    exact ⟨s1, rfl, h.symm⟩

/-- R's answer at an island: the world, the writes over the `Lend` extents, then the result. -/
theorem answer_island {c : R.Code} {s : R.RState} {op : Reduced.Opcode} {f : Full.Opcode}
    {isl : Nat} {ws : List (BitVec 32)} (a : R.Answer)
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws])) (hf : op.full = some f)
    (hsh : f.info.shape = .island) :
    R.answer c s a = (do
      let st ← R.writeRanges (s.withWorld a.world).st (c.lendsAt s.pc) a.frame
      match a.result with
      | .unwind exc => R.unwindAt c { s.withWorld a.world with st } exc
      | .ret _ => pure (.step { s.withWorld a.world with st, pc := s.pc + 1 })) := by
  unfold R.answer
  simp only [hi, hf, hsh]
  rfl

/-! ### The frame after the template's writes -/

/-- Frame offset `o`'s address for frame pointer `fp` (`Island.lendAddr`). -/
def la (fp : Nat) (o : Int) : BitVec 64 := BitVec.ofNat 64 fp + BitVec.ofInt 64 o

theorem la_add (fp : Nat) (o : Int) (i : Nat) : la fp o + BitVec.ofNat 64 i = la fp (o + i) := by
  simp [la, BitVec.ofInt_add, BitVec.add_assoc]

/-- `o` is in the range `l`. -/
def InR (l : Int × Nat) (o : Int) : Prop := l.1 ≤ o ∧ o < l.1 + l.2

/-- The state during the writes over the `Lend` extents `L`, `D` those done, against x86 memory
`m` (the template's return): `st0`'s escaped objects, at their addresses; every live allocation
related to `m`; each private byte related to `m` if it is in a done extent or in none. -/
structure Inv (st0 : OpSem.State) (fp : Nat) (L D : List (Int × Nat)) (m : X86.Mem)
    (st : OpSem.State) : Prop where
  escaped : st.escaped = st0.escaped
  zeroSized : st.zeroSized = st0.zeroSized
  size : st0.mem.allocs.size ≤ st.mem.allocs.size
  alloc : ∀ e ∈ st0.escaped, ∃ al, st.mem.get? e.id = some al ∧
    BitVec.ofNat 64 al.addr = la fp e.off
  mem : ∀ id al, st.mem.get? id = some al → al.live = true → ∀ i (h : i < al.data.size),
    ByteRel al.data[i] (m (BitVec.ofNat 64 (al.addr + i)))
  priv : ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → st0.escapedAt o = none →
    ((∃ l ∈ D, InR l o) ∨ (∀ l ∈ L, ¬ InR l o)) → ByteRel (st.frame o) (m (la fp o))

theorem escapedAt_congr {st st' : OpSem.State} (h : st'.escaped = st.escaped) (o : Int) :
    st'.escapedAt o = st.escapedAt o := by
  unfold OpSem.State.escapedAt; rw [h]

theorem escFold_ok (st : OpSem.State) (off : Int) : ∀ (l : List (AbstractByte × Nat)) (mem : Memory),
    (∀ e ∈ st.escaped, ∃ al, mem.get? e.id = some al) →
    ∃ m', l.foldlM (escStep st off) mem = .ok m'
  | [], mem, _ => ⟨mem, rfl⟩
  | p :: l, mem, h => by
    simp only [List.foldlM_cons]
    have : ∃ m1, escStep st off mem p = .ok m1 ∧ ∀ e ∈ st.escaped, ∃ al, m1.get? e.id = some al := by
      unfold escStep
      cases he : st.escapedAt (off + p.2) with
      | none => exact ⟨mem, rfl, h⟩
      | some e =>
        obtain ⟨al, hal⟩ := h e (escapedAt_some he).1
        simp only [hal]
        refine ⟨_, rfl, fun e' he' => ?_⟩
        rw [get?_set hal]
        split
        · exact ⟨_, rfl⟩
        · exact h e' he'
    obtain ⟨m1, h1, h1'⟩ := this
    rw [h1]
    exact escFold_ok st off l m1 h1'

/-- One extent's write keeps the invariant, the extent now done. -/
theorem inv_write {st0 st : OpSem.State} {fp : Nat} {L D : List (Int × Nat)} {m : X86.Mem}
    {off : Int} {n : Nat} {bs : List AbstractByte} (hinv : Inv st0 fp L D m st)
    (hbs : BytesRel bs (bytesAt m (la fp off) n)) (hb : -2 ^ 62 < off ∧ off + n < 2 ^ 62) :
    ∃ st', st.writeFrame off bs = .ok st' ∧ Inv st0 fp L (D ++ [(off, n)]) m st' := by
  have hlen : bs.length = n := by rw [hbs.length, bytesAt_length]
  have hea := escapedAt_congr hinv.escaped
  obtain ⟨m', hm'⟩ := escFold_ok st off bs.zipIdx st.mem (fun e he => by
    rw [hinv.escaped] at he
    obtain ⟨al, h, -⟩ := hinv.alloc e he; exact ⟨al, h⟩)
  have hw : st.writeEscaped off bs = .ok m' := hm'
  have hspec := writeEscaped_spec hw
  refine ⟨_, by unfold OpSem.State.writeFrame; rw [hw]; rfl, ?_⟩
  refine ⟨hinv.escaped, hinv.zeroSized, by simp only; rw [hspec.1]; exact hinv.size, ?_, ?_, ?_⟩
  · intro e he
    obtain ⟨al, hal, haddr⟩ := hinv.alloc e he
    have hlt : e.id < m'.allocs.size := by
      rw [hspec.1]; exact (Array.getElem?_eq_some_iff.1 hal).1
    obtain ⟨a', ha'⟩ : ∃ a', m'.get? e.id = some a' := ⟨_, Array.getElem?_eq_getElem hlt⟩
    obtain ⟨a, ha, hae, -⟩ := hspec.2 _ _ ha'
    rw [hal] at ha; cases ha
    refine ⟨a', ha', ?_⟩
    rw [hae]; exact haddr
  · intro id a' ha' hlive i hi
    obtain ⟨a, ha, hae, hsz, hj⟩ := hspec.2 _ _ ha'
    have hlive' : a.live = true := by rw [hae] at hlive; exact hlive
    have haddr : a'.addr = a.addr := by rw [hae]
    by_cases hh : ∃ p ∈ bs.zipIdx, Hits st off p id i
    · obtain ⟨q, hq, ⟨e, he, hid, hj'⟩, hv⟩ := (hj i).2 hh (by omega)
      obtain ⟨hk, hq1⟩ := mem_zipIdx hq
      obtain ⟨hem, h1, h2⟩ := escapedAt_some he
      rw [hinv.escaped] at hem
      obtain ⟨al, hal, hladdr⟩ := hinv.alloc e hem
      rw [hid, ha] at hal; cases hal
      have : a'.data[i] = q.1 := by
        rw [Array.getElem?_eq_getElem hi] at hv; exact Option.some.inj hv
      rw [this, hq1, haddr, BitVec.ofNat_add, hladdr, la_add]
      have hg := hbs.getElem q.2 hk (by rw [bytesAt_length]; omega)
      rw [getElem_bytesAt, la_add] at hg
      have : e.off + ((i : Nat) : Int) = off + (q.2 : Int) := by omega
      rw [this]; exact hg
    · have hd := (hj i).1 (fun p hp h => hh ⟨p, hp, h⟩)
      have hi' : i < a.data.size := by omega
      rw [Array.getElem?_eq_getElem hi, Array.getElem?_eq_getElem hi'] at hd
      rw [Option.some.inj hd, haddr]
      exact hinv.mem id a ha hlive' i hi'
  · intro o h1 h2 hn hD
    simp only
    have hn' : st.escapedAt o = none := by rw [hea]; exact hn
    by_cases hin : off ≤ o ∧ o < off + bs.length
    · have : st.privateIn off bs.length o = true := by
        simp [OpSem.State.privateIn, hin, hn']
      simp only [this, ↓reduceIte]
      have hk : (o - off).toNat < bs.length := by omega
      rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hk, Option.getD_some]
      have hg := hbs.getElem _ hk (by rw [bytesAt_length]; omega)
      rw [getElem_bytesAt, la_add, show off + ((o - off).toNat : Int) = o by omega] at hg
      exact hg
    · have : st.privateIn off bs.length o = false := by
        simp [OpSem.State.privateIn, hin]
      simp only [this, Bool.false_eq_true, ↓reduceIte]
      apply hinv.priv o h1 h2 hn
      rcases hD with ⟨l, hl, hil⟩ | hall
      · rcases List.mem_append.1 hl with hl | hl
        · exact .inl ⟨l, hl, hil⟩
        · simp only [List.mem_singleton] at hl; subst hl
          exact absurd ⟨hil.1, by rw [hlen]; exact hil.2⟩ hin
      · exact .inr hall

theorem inv_fold {st0 : OpSem.State} {fp : Nat} {L : List (Int × Nat)} {m : X86.Mem} :
    ∀ (ps : List ((Int × Nat) × List AbstractByte)) (D : List (Int × Nat)) (st : OpSem.State),
    Inv st0 fp L D m st →
    (∀ p ∈ ps, BytesRel p.2 (bytesAt m (la fp p.1.1) p.1.2) ∧ -2 ^ 62 < p.1.1 ∧
      p.1.1 + p.1.2 < 2 ^ 62) →
    ∃ st', ps.foldlM (init := st) (fun st ((off, n), bs) => do
        if bs.length != n then
          illFormed s!"an answer's bytes for [{off}, {off + n}) have the wrong length"
        st.writeFrame off bs) = .ok st' ∧ Inv st0 fp L (D ++ ps.map (·.1)) m st'
  | [], D, st, h, _ => ⟨st, rfl, by simpa using h⟩
  | ((off, n), bs) :: ps, D, st, h, hp => by
    obtain ⟨hbs, hb1, hb2⟩ := hp _ (List.mem_cons_self ..)
    obtain ⟨st1, hw, h1⟩ := inv_write h hbs ⟨hb1, hb2⟩
    have hlen : bs.length = n := by rw [hbs.length, bytesAt_length]
    obtain ⟨st', hf, h'⟩ := inv_fold ps _ st1 h1 (fun p hp' => hp p (List.mem_cons_of_mem _ hp'))
    refine ⟨st', ?_, by simpa using h'⟩
    simp only [List.foldlM_cons, hlen, bne_self_eq_false, Bool.false_eq_true, ↓reduceIte]
    simp only [bind, Except.bind, pure, Except.pure, hw]
    exact hf

theorem inv_writeRanges {st0 st : OpSem.State} {fp : Nat} {L : List (Int × Nat)} {m : X86.Mem}
    {new : List (List AbstractByte)} (h : Inv st0 fp L [] m st) (hlen : new.length = L.length)
    (hnew : ∀ j (h1 : j < L.length) (h2 : j < new.length),
      BytesRel new[j] (bytesAt m (la fp L[j].1) L[j].2))
    (hb : ∀ l ∈ L, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62) :
    ∃ st', R.writeRanges st L new = .ok st' ∧ Inv st0 fp L L m st' := by
  unfold R.writeRanges
  by_cases he : new.isEmpty = true
  · have : new = [] := List.isEmpty_iff.1 he
    subst this
    have : L = [] := List.eq_nil_of_length_eq_zero (by simpa using hlen.symm)
    subst this
    exact ⟨st, rfl, h⟩
  · simp only [he, Bool.false_eq_true, ↓reduceIte, hlen, bne_self_eq_false]
    obtain ⟨st', hf, h'⟩ := inv_fold (L.zip new) [] st h (by
      intro p hp
      obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.1 hp
      simp only [List.length_zip] at hj
      simp only [List.getElem_zip]
      exact ⟨hnew j (by omega) (by omega), hb _ (List.getElem_mem _)⟩)
    refine ⟨st', ?_, ?_⟩
    · simpa using hf
    · have : (L.zip new).map (·.1) = L := by
        rw [List.map_fst_zip]; omega
      simpa [this] using h'

/-- At the end of the writes: the frame relation, the memory relation and `EscWF`, for an x86
state with memory `m` and `fp` in `rbp`. -/
theorem inv_final {st0 st : OpSem.State} {fp : Nat} {L : List (Int × Nat)} {m : X86.Mem}
    {x : X86.State} (h : Inv st0 fp L L m st) (hx : x.mem = m) (hrbp : x.reg .rbp = BitVec.ofNat 64 fp)
    (hz : ∀ p ∈ st0.zeroSized, BitVec.ofNat 64 p.2 = la fp p.1) (hwf : EscWF st0) :
    Rel st x ∧ MemRel st x ∧ EscWF st := by
  have hfa : ∀ o, fpAddr x o = la fp o := fun o => by simp [fpAddr, la, hrbp]
  have hea := escapedAt_congr h.escaped
  refine ⟨⟨fun o h1 h2 b hb => ?_, fun e he a ha => ?_, fun p hp => ?_⟩, ?_, ?_, ?_⟩
  · rw [hfa, hx]
    unfold OpSem.State.byteAt at hb
    cases hf : st.escapedAt o with
    | none =>
      rw [hf] at hb
      simp only [pure, Except.pure, Except.ok.injEq] at hb
      subst hb
      apply h.priv o h1 h2 (by rw [← hea]; exact hf)
      by_cases hin : ∃ l ∈ L, InR l o
      · exact .inl hin
      · exact .inr fun l hl hi => hin ⟨l, hl, hi⟩
    | some e =>
      rw [hf] at hb
      obtain ⟨hem, he1, he2⟩ := escapedAt_some hf
      rw [h.escaped] at hem
      obtain ⟨al, hal, haddr⟩ := h.alloc e hem
      simp only [hal] at hb
      split at hb
      · cases hb
      rename_i hlive
      split at hb
      · rename_i b' hb'
        cases hb
        obtain ⟨hi, hv⟩ := Array.getElem?_eq_some_iff.1 hb'
        have := h.mem e.id al hal (by simpa using hlive) _ hi
        rw [hv, BitVec.ofNat_add, haddr, la_add, show e.off + ((o - e.off).toNat : Int) = o by omega] at this
        exact this
      · cases hb
  · rw [h.escaped] at he
    obtain ⟨al, hal, haddr⟩ := h.alloc e he
    rw [hal] at ha; cases ha
    rw [hfa]; exact haddr
  · rw [h.zeroSized] at hp
    rw [hfa]; exact hz p hp
  · intro id al hal hlive i hi
    rw [hx]; exact h.mem id al hal hlive i hi
  · intro e he
    rw [h.escaped] at he
    exact Nat.lt_of_lt_of_le (hwf.idLt e he) h.size
  · intro e he e' he' hid
    rw [h.escaped] at he he'
    exact hwf.idInj e he e' he' hid

/-- At the template's return, before the writes: the state with the answer's world. -/
theorem inv_init {st0 : OpSem.State} {fp : Nat} {L : List (Int × Nat)} {x x' : X86.State}
    {w : R.World} (hr : Rel st0 x) (hrbp : x.reg .rbp = BitVec.ofNat 64 fp) (hwf : EscWF st0)
    (hsize : st0.mem.allocs.size ≤ w.mem.allocs.size)
    (hkeep : ∀ id a, st0.mem.get? id = some a → ∃ a', w.mem.get? id = some a' ∧ a'.addr = a.addr)
    (hw : ∀ id a, w.mem.get? id = some a → a.live = true → ∀ i (h : i < a.data.size),
      ByteRel a.data[i] (x'.mem (BitVec.ofNat 64 (a.addr + i))))
    (hout : ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → st0.escapedAt o = none →
      (∀ l ∈ L, ¬ InR l o) → x'.mem (la fp o) = x.mem (la fp o)) :
    Inv st0 fp L [] x'.mem { st0 with mem := w.mem, exposed := w.exposed } := by
  have hfa : ∀ o, fpAddr x o = la fp o := fun o => by simp [fpAddr, la, hrbp]
  refine ⟨rfl, rfl, hsize, fun e he => ?_, hw, fun o h1 h2 hn hD => ?_⟩
  · obtain ⟨a0, ha0⟩ : ∃ a0, st0.mem.get? e.id = some a0 :=
      ⟨_, Array.getElem?_eq_getElem (hwf.idLt e he)⟩
    obtain ⟨a', ha', hae⟩ := hkeep _ _ ha0
    refine ⟨a', ha', ?_⟩
    rw [hae, hr.layout e he a0 ha0, hfa]
  · rcases hD with ⟨l, hl, -⟩ | hall
    · simp at hl
    · simp only
      rw [hout o h1 h2 hn hall, ← hfa]
      apply hr.frame o h1 h2
      unfold OpSem.State.byteAt; rw [hn]; rfl

end Ryo.Proofs.IslandLemmas
