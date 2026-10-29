/-
Ryo.Proofs.CallLemmas — helpers for `Ryo.Proofs.Call`: the push of the return address, reads
that a write elsewhere keeps, frame writes against an unchanged x86 state (`Uninit` bytes, the
answer's outgoing-area bytes), `writeFrame` succeeding, R's call and tail-call steps and
answers, and the result stores.
-/
import Ryo.Proofs.ArgRet
import Ryo.Proofs.Handler
import Ryo.Proofs.ScopeMem

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CallLemmas

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
open Ryo.Proofs.Counter (InStack)

/-! ### x86 memory -/

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

/-- The push of the return address writes only `[sp - 8, sp)`, which is in the stack. -/
theorem push_other (lo sp a : BitVec 64) (hlo : lo.toNat + 8 ≤ sp.toNat)
    (ha : ¬ InStack lo sp a) : 8 ≤ (a - (sp - 8)).toNat := by
  simp only [InStack] at ha
  have hsp : (sp - 8).toNat = sp.toNat - 8 := by
    rw [BitVec.toNat_sub]; have := sp.isLt; simp; omega
  rw [BitVec.toNat_sub, hsp]
  have := a.isLt; have := sp.isLt
  by_cases h1 : lo.toNat ≤ a.toNat
  · have h2 : sp.toNat ≤ a.toNat := by omega
    omega
  · rw [Nat.mod_eq_of_lt (by omega)]
    omega

/-- The byte at offset `i` from `a`, with `i + 8 < 2^64`, is at least 8 above `a - 8`. -/
theorem above_push (a : BitVec 64) (i : Nat) (hi : i + 8 < 2 ^ 64) :
    8 ≤ (a + BitVec.ofNat 64 i - (a - 8)).toNat := by
  have : a + BitVec.ofNat 64 i - (a - 8) = BitVec.ofNat 64 (i + 8) := by
    rw [BitVec.ofNat_add]; generalize BitVec.ofNat 64 i = c; bv_omega
  rw [this, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hi]; omega

theorem readNat_congr {m m' : Mem} {a : BitVec 64} {n : Nat}
    (h : ∀ i < n, m' (a + BitVec.ofNat 64 i) = m (a + BitVec.ofNat 64 i)) :
    m'.readNat a n = m.readNat a n := by
  rw [readNat_eq, readNat_eq]
  congr 1
  unfold bytesAt
  apply List.map_congr_left
  intro i hi
  exact h i (List.mem_range.1 hi)

theorem read64_congr {m m' : Mem} {a : BitVec 64}
    (h : ∀ i < 8, m' (a + BitVec.ofNat 64 i) = m (a + BitVec.ofNat 64 i)) :
    m'.read64 a = m.read64 a := by
  simp only [Mem.read64, readNat_congr h]

theorem bytesAt_congr {m m' : Mem} {a : BitVec 64} {n : Nat}
    (h : ∀ i < n, m' (a + BitVec.ofNat 64 i) = m (a + BitVec.ofNat 64 i)) :
    bytesAt m' a n = bytesAt m a n := by
  unfold bytesAt
  apply List.map_congr_left
  intro i hi
  exact h i (List.mem_range.1 hi)

/-! ### `writeFrame` succeeds -/

theorem get?_isSome {m : Memory} {id : AllocId} : (m.get? id).isSome ↔ id < m.allocs.size := by
  simp [Memory.get?]

/-- A frame write succeeds when every escaped object has an allocation. -/
theorem writeFrame_ok {st : OpSem.State} (off : Int) (bs : List AbstractByte)
    (h : ∀ e ∈ st.escaped, e.id < st.mem.allocs.size) : ∃ st', st.writeFrame off bs = .ok st' := by
  have key : ∀ (l : List (AbstractByte × Nat)) (mem : Memory),
      (∀ e ∈ st.escaped, e.id < mem.allocs.size) → ∃ m', l.foldlM (escStep st off) mem = .ok m' := by
    intro l
    induction l with
    | nil => intro mem _; exact ⟨mem, rfl⟩
    | cons p l ih =>
      intro mem hm
      simp only [List.foldlM_cons]
      unfold escStep
      split
      · exact ih mem hm
      · rename_i e he
        have hlt := hm e (escapedAt_some he).1
        cases hg : mem.get? e.id with
        | none => exact absurd (get?_isSome.2 hlt) (by simp [hg])
        | some a =>
          simp only [pure, Except.pure, bind, Except.bind]
          apply ih
          intro e' he'
          simp only [Array.size_set!]
          exact hm e' he'
  obtain ⟨m', hm'⟩ := key bs.zipIdx st.mem h
  have hwe : st.writeEscaped off bs = .ok m' := hm'
  unfold OpSem.State.writeFrame
  rw [hwe]
  exact ⟨_, rfl⟩

/-! ### Frame writes against an unchanged x86 state -/

/-- Writing `Uninit` bytes keeps `Rel` (against the same x86 state) and changes the state only by
the write. -/
theorem rel_writeUninit {st st' : OpSem.State} {x : X86.State} {off : Int} {n : Nat}
    (hr : Rel st x) (hw : st.writeFrame off (List.replicate n .uninit) = .ok st') :
    Rel st' x ∧ SameButWrites st' st := by
  unfold OpSem.State.writeFrame at hw
  cases hm : st.writeEscaped off (List.replicate n .uninit) with
  | error e => simp [hm, bind, Except.bind] at hw
  | ok m' =>
  simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  have hesc := writeEscaped_spec hm
  refine ⟨⟨fun o ho1 ho2 b hb => ?_, fun e he a ha => ?_, fun p hp => hr.zeroSized p hp⟩,
    rfl, hesc.escOnly, rfl, rfl, rfl⟩
  · have hea : ∀ (f : Int → AbstractByte) (m : Memory),
        ({ st with mem := m, frame := f } : OpSem.State).escapedAt o = st.escapedAt o :=
      fun _ _ => rfl
    unfold OpSem.State.byteAt at hb
    rw [hea] at hb
    cases hf : st.escapedAt o with
    | none =>
      simp only [hf, pure, Except.pure, Except.ok.injEq] at hb
      subst hb
      split
      · rename_i h
        rw [List.getD_eq_getElem?_getD]
        cases hg : (List.replicate n AbstractByte.uninit)[(o - off).toNat]? with
        | none => trivial
        | some b =>
          rw [List.getElem?_replicate] at hg
          split at hg
          · cases hg; trivial
          · cases hg
      · have := hr.frame o ho1 ho2 (st.frame o) (by unfold OpSem.State.byteAt; rw [hf]; rfl)
        exact this
    | some e =>
      simp only [hf] at hb
      split at hb
      · rename_i a' ha'
        split at hb
        · cases hb
        · rename_i hlv
          split at hb
          · rename_i b' hb'
            cases hb
            obtain ⟨a, ha, hae, hsz, hj⟩ := hesc.2 e.id a' ha'
            by_cases hh : ∃ p ∈ (List.replicate n AbstractByte.uninit).zipIdx,
                Hits st off p e.id (o - e.off).toNat
            · have hjl : (o - e.off).toNat < a.data.size := by
                rw [← hsz]; exact (Array.getElem?_eq_some_iff.1 hb').1
              obtain ⟨q, hq, -, hv⟩ := (hj _).2 hh hjl
              obtain ⟨hqk, hq1⟩ := mem_zipIdx hq
              rw [hb'] at hv
              cases hv
              rw [hq1]
              simp [ByteRel]
            · have hd := (hj _).1 fun p hp hph => hh ⟨p, hp, hph⟩
              rw [hb'] at hd
              refine hr.frame o ho1 ho2 _ ?_
              unfold OpSem.State.byteAt
              rw [hf]
              simp only [ha]
              have hl : a'.live = a.live := by rw [hae]
              have : (!a.live) = false := by
                rw [← hl]; simpa using hlv
              simp only [this, Bool.false_eq_true, ↓reduceIte]
              rw [← hd]
              rfl
          · cases hb
      · cases hb
  · have hea : ∀ (m : Memory), (st.escaped) = ({ st with mem := m } : OpSem.State).escaped :=
      fun _ => rfl
    obtain ⟨a0, ha0, hae, -, -⟩ := hesc.2 e.id a ha
    have := hr.layout e he a0 ha0
    rw [hae]; exact this

/-- Escaped objects are allocations at their frame address (`Rel.layout`). -/
def Layout (st : OpSem.State) (x : X86.State) : Prop :=
  ∀ e ∈ st.escaped, ∀ a, st.mem.get? e.id = some a → BitVec.ofNat 64 a.addr = fpAddr x e.off

theorem addr_of_hit {st : OpSem.State} {x : X86.State} (hlay : Layout st x) {o : Int}
    {e : EscapedObj} (he : st.escapedAt o = some e) {a : Allocation}
    (ha : st.mem.get? e.id = some a) :
    BitVec.ofNat 64 (a.addr + (o - e.off).toNat) = fpAddr x o := by
  obtain ⟨hm, h1, -⟩ := escapedAt_some he
  rw [BitVec.ofNat_add, hlay e hm a ha, ← fpAddr_add]
  congr 1; omega

/-- A frame write of bytes that relate to the x86 bytes at their addresses keeps `MemRel`
(against the same x86 state). -/
theorem memRel_writeRel {st st' : OpSem.State} {x : X86.State} {off : Int} {bs : List AbstractByte}
    (hm : MemRel st x) (hlay : Layout st x) (hw : st.writeFrame off bs = .ok st')
    (hb : ∀ i (h : i < bs.length), ByteRel bs[i] (x.mem (fpAddr x (off + i)))) :
    MemRel st' x := by
  unfold OpSem.State.writeFrame at hw
  cases hwe : st.writeEscaped off bs with
  | error e => simp [hwe, bind, Except.bind] at hw
  | ok m' =>
  simp only [hwe, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  have hesc := writeEscaped_spec hwe
  intro id a' hg hl i hi
  obtain ⟨a0, ha0, hae, hsz, hj⟩ := hesc.2 id a' hg
  have hl0 : a0.live = true := by rw [hae] at hl; exact hl
  have haddr : a'.addr = a0.addr := by rw [hae]
  by_cases hh : ∃ p ∈ bs.zipIdx, Hits st off p id i
  · obtain ⟨q, hq, ⟨e, he, hid, hj'⟩, hv⟩ := (hj i).2 hh (by rw [← hsz]; exact hi)
    obtain ⟨hqk, hq1⟩ := mem_zipIdx hq
    rw [Array.getElem?_eq_getElem hi, Option.some.injEq] at hv
    rw [hv, hq1, haddr]
    subst hid
    have := addr_of_hit hlay he ha0
    rw [hj'] at this
    rw [this]
    exact hb _ hqk
  · have hd := (hj i).1 fun p hp hph => hh ⟨p, hp, hph⟩
    rw [Array.getElem?_eq_getElem hi, Array.getElem?_eq_getElem (by rw [← hsz]; exact hi),
      Option.some.injEq] at hd
    have := hm id a0 ha0 hl0 i (by rw [← hsz]; exact hi)
    simp only [hd, haddr]
    exact this

theorem esc_inj' {st : OpSem.State} {x : X86.State} (hlay : Layout st x) {o o' : Int}
    {e e' : EscapedObj} (ho : -2 ^ 63 ≤ o ∧ o < 2 ^ 63) (ho' : -2 ^ 63 ≤ o' ∧ o' < 2 ^ 63)
    (he : st.escapedAt o = some e) (he' : st.escapedAt o' = some e') (hid : e'.id = e.id)
    {a : Allocation} (ha : st.mem.get? e.id = some a)
    (hj : (o' - e'.off).toNat = (o - e.off).toNat) : o' = o := by
  obtain ⟨hm, h1, h2⟩ := escapedAt_some he
  obtain ⟨hm', h1', h2'⟩ := escapedAt_some he'
  have l1 := hlay e hm a ha
  have l2 := hlay e' hm' a (by rw [hid]; exact ha)
  have : BitVec.ofInt 64 e.off = BitVec.ofInt 64 e'.off := by
    have := l1.symm.trans l2
    simpa [fpAddr] using this
  have := congrArg BitVec.toNat this
  simp only [BitVec.toNat_ofInt] at this
  omega

/-- `rel_writeFrame` against an unchanged x86 state whose bytes at `[d, d + n)` the written
bytes relate to: only the bytes outside the range need to relate before. -/
theorem rel_writeFrame_in {st st' : OpSem.State} {x : X86.State} {d : Int} {bs : List AbstractByte}
    (hfr : ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → ¬ (d ≤ o ∧ o < d + bs.length) → ∀ b,
      st.byteAt o = .ok b → ByteRel b (x.mem (fpAddr x o)))
    (hlay : Layout st x) (hzs : ∀ p ∈ st.zeroSized, BitVec.ofNat 64 p.2 = fpAddr x p.1)
    (hw : st.writeFrame d bs = .ok st') (hd : -2 ^ 63 ≤ d)
    (hdn : d + bs.length ≤ 2 ^ 63) (hx : BytesRel bs (bytesAt x.mem (fpAddr x d) bs.length)) :
    Rel st' x ∧ SameButWrites st' st := by
  unfold OpSem.State.writeFrame at hw
  cases hm : st.writeEscaped d bs with
  | error e => simp [hm, bind, Except.bind] at hw
  | ok m' =>
  simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  have hesc := writeEscaped_spec hm
  have hlen := hx.length
  refine ⟨⟨fun o ho1 ho2 b hb => ?_, fun e he a ha => ?_, fun p hp' => hzs p hp'⟩,
    rfl, hesc.escOnly, rfl, rfl, rfl⟩
  · have hea : ∀ (f : Int → AbstractByte) (m : Memory),
        ({ st with mem := m, frame := f } : OpSem.State).escapedAt o = st.escapedAt o :=
      fun _ _ => rfl
    unfold OpSem.State.byteAt at hb
    rw [hea] at hb
    by_cases hin' : d ≤ o ∧ o < d + bs.length
    · have hk : (o - d).toNat < bs.length := by omega
      have hxo : x.mem (fpAddr x o) = (bytesAt x.mem (fpAddr x d) bs.length)[(o - d).toNat]'(by
          rw [bytesAt_length]; omega) := by
        rw [getElem_bytesAt, ← fpAddr_add, show d + ((o - d).toNat : Int) = o by omega]
      rw [hxo]
      cases hf : st.escapedAt o with
      | none =>
        simp only [hf, OpSem.State.privateIn, hin', Option.isNone_none, pure, Except.pure,
          Except.ok.injEq] at hb
        subst hb
        rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hk, Option.getD_some]
        exact hx.getElem _ hk _
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
              have hhit : Hits st d (bs[(o - d).toNat], (o - d).toNat) e.id (o - e.off).toNat :=
                ⟨e, by rw [show d + ((o - d).toNat : Int) = o by omega]; exact hf, rfl,
                  by rw [show d + ((o - d).toNat : Int) = o by omega]⟩
              have hjl : (o - e.off).toNat < a.data.size := by
                rw [← hsz]; exact (Array.getElem?_eq_some_iff.1 hb').1
              obtain ⟨q, hq, ⟨e', he', hid', hj'⟩, hv⟩ := (hj _).2
                ⟨_, List.mem_zipIdx_iff_getElem?.2 (List.getElem?_eq_getElem hk), hhit⟩ hjl
              obtain ⟨hqk, hq1⟩ := mem_zipIdx hq
              have := esc_inj' hlay ⟨ho1, ho2⟩ ⟨by omega, by omega⟩ hf he' hid' ha hj'
              rw [hb'] at hv
              cases hv
              rw [hq1]
              have hqk' : q.2 = (o - d).toNat := by omega
              simp only [hqk']
              exact hx.getElem _ hk _
            · cases hb
        · cases hb
    · apply hfr o ho1 ho2 hin' b
      unfold OpSem.State.byteAt
      cases hf : st.escapedAt o with
      | none =>
        simp only [hf, OpSem.State.privateIn, hin', decide_false, Bool.false_and,
          Bool.false_eq_true, ↓reduceIte] at hb
        exact hb
      | some e =>
        simp only [hf] at hb ⊢
        split at hb
        · rename_i a' ha'
          obtain ⟨a, ha, hae, hsz, hj⟩ := hesc.2 e.id a' ha'
          have hnh : ∀ p ∈ bs.zipIdx, ¬ Hits st d p e.id (o - e.off).toNat := by
            rintro q hq ⟨e', he', hid', hj'⟩
            obtain ⟨hqk, -⟩ := mem_zipIdx hq
            have := esc_inj' hlay ⟨ho1, ho2⟩ ⟨by omega, by omega⟩ hf he' hid' ha hj'
            omega
          have hdat := (hj _).1 hnh
          rw [ha]
          rw [hae] at hb
          simp only at hb
          simp only
          rw [← hdat]
          exact hb
        · cases hb
  · obtain ⟨a0, ha0, hae, -, -⟩ := hesc.2 e.id a ha
    rw [hae]; exact hlay e he a0 ha0

/-! ### R's steps, answers and result stores -/


theorem step_call {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    {q : R.Query} {s' : R.RState}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (h : R.step c s ch = .ok (.ext q s')) :
    ∃ s1 parts cal regs stack, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.retRegs k.toNat false = .ok parts ∧ R.callee s1.st f fo = .ok cal ∧
      R.argRegs s1.st ws = .ok regs ∧ c.d.frameSize ≤ s1.fp ∧
      s1.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s1.pc) = .ok stack ∧
      (s'.st = s1.st ∨ ∃ (n : Nat) (dst : BitVec 32),
        s1.st.writeFrame dst.toInt (List.replicate n .uninit) = .ok s'.st) ∧
      s'.pc = s1.pc ∧ s'.fp = s1.fp ∧ s'.args = s1.args ∧
      q = ⟨.call cal regs (s1.fp - c.d.frameSize) stack, s'.world⟩ := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf, hsh] at h
    cases hp : R.retRegs k.toNat false with
    | error e => simp [hp] at h
    | ok parts =>
    simp only [hp] at h
    cases hc : R.callee s1.st f fo with
    | error e => simp [hc] at h
    | ok cal =>
    simp only [hc] at h
    cases ha : R.argRegs s1.st ws with
    | error e => simp [ha] at h
    | ok regs =>
    simp only [ha] at h
    cases hfa : R.frameAddr s1.fp (-(c.d.frameSize : Int)) with
    | error e => simp [hfa] at h
    | ok sp =>
    simp only [hfa] at h
    have hsp : c.d.frameSize ≤ s1.fp ∧ sp = s1.fp - c.d.frameSize := by
      unfold R.frameAddr at hfa
      dsimp only at hfa
      split at hfa
      · simp [illFormed, throw, throwThe, MonadExceptOf.throw] at hfa
      · rename_i hlt
        simp only [pure, Except.pure, Except.ok.injEq] at hfa
        omega
    cases hrd : s1.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s1.pc) with
    | error e => simp [hrd] at h
    | ok stack =>
    simp only [hrd] at h
    refine ⟨s1, parts, cal, regs, stack, rfl, rfl, hc, ha, hsp.1, hrd, ?_⟩
    split at h
    · rename_i n dst _ _
      cases hw : s1.st.writeFrame dst.toInt (List.replicate n .uninit) with
      | error e => simp [hw] at h
      | ok st' =>
        simp only [hw, pure, Except.pure, Except.ok.injEq, R.Out.ext.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        exact ⟨.inr ⟨n, dst, hw⟩, rfl, rfl, rfl, by rw [hsp.2]⟩
    · simp only [pure, Except.pure, Except.ok.injEq, R.Out.ext.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨.inl rfl, rfl, rfl, rfl, by rw [hsp.2]⟩

theorem step_tailCall {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {fo : R.Opnd Nat} {ws : List (BitVec 32)} {f : Full.Opcode} {fin : R.Final}
    (hi : c.d.insns[s.pc]? = some (.native op [fo, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .tailCall) (h : R.step c s ch = .ok (.done fin)) :
    ∃ s1 cal regs stack, (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 ∧
      R.callee s1.st f fo = .ok cal ∧ R.argRegs s1.st ws = .ok regs ∧
      s1.st.readFrame 16 (c.stackSize s1.pc) = .ok stack ∧
      fin = R.exit s1 (.tailCall cal regs (s1.fp + 16) stack) := by
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e => simp [hsc] at h
  | ok s1 =>
    simp only [hsc, hf, hsh] at h
    cases hc : R.callee s1.st f fo with
    | error e => simp [hc] at h
    | ok cal =>
    simp only [hc] at h
    cases ha : R.argRegs s1.st ws with
    | error e => simp [ha] at h
    | ok regs =>
    simp only [ha] at h
    cases hrd : s1.st.readFrame 16 (c.stackSize s1.pc) with
    | error e => simp [hrd] at h
    | ok stack =>
    simp only [hrd, pure, Except.pure, Except.ok.injEq, R.Out.done.injEq] at h
    exact ⟨s1, cal, regs, stack, rfl, hc, ha, hrd, h.symm⟩

theorem answer_ret {c : R.Code} {s : R.RState} {op : Reduced.Opcode} {d : BitVec 32}
    {fo : R.Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode} {a : R.Answer}
    {regs : R.Regs} {st1 st2 : OpSem.State} {parts : List (RetPart × R.Reg)}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (hres : a.result = .ret regs)
    (hw : R.writeRanges (s.withWorld a.world).st [(-(c.d.frameSize : Int), c.stackSize s.pc)]
      a.frame = .ok st1)
    (hp : R.retRegs k.toNat false = .ok parts)
    (hst : parts.foldlM (init := st1) (fun st (q : RetPart × R.Reg) =>
      st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok st2) :
    R.answer c s a = .ok (.step ⟨s.pc + 1, s.fp, st2, s.args⟩) := by
  unfold R.answer
  simp only [hi, hf, hsh, bind, Except.bind]
  have e1 : (s.withWorld a.world).pc = s.pc := rfl
  simp only [e1, hw, hres, hp]
  rw [show (fun (st : OpSem.State) (x : RetPart × R.Reg) =>
      match x with | (p, r) => st.writeFrame (d.toInt + ↑p.off) (List.take p.size (regs.get r))) =
      (fun st (q : RetPart × R.Reg) => st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size))
      from rfl, hst]
  rfl

theorem answer_unwind {c : R.Code} {s : R.RState} {op : Reduced.Opcode} {d : BitVec 32}
    {fo : R.Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode} {a : R.Answer}
    {exc : ThinPointer} {st1 : OpSem.State} {pad : Nat} {cat : Bool}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (hres : a.result = .unwind exc)
    (hw : R.writeRanges (s.withWorld a.world).st [(-(c.d.frameSize : Int), c.stackSize s.pc)]
      a.frame = .ok st1)
    (hpad : c.cleanupAt s.pc = some (some pad, cat)) :
    R.answer c s a = .ok (.step ⟨pad, s.fp, { st1 with exception := exc }, s.args⟩) := by
  unfold R.answer
  simp only [hi, hf, hsh, bind, Except.bind]
  have e1 : (s.withWorld a.world).pc = s.pc := rfl
  simp only [e1, hw, hres]
  unfold R.unwindAt
  simp only [hpad]
  rfl

open Ryo.Proofs.ArgRet in
/-- `ret_parts`' part decoder (store form: integer parts of 1 to 8 bytes). -/
def part1S (b off : Nat) : Option (Option RetPart) :=
  if b &&& 0xc0 != 0 then none else
  if b == 0 then some none else
  let xmm := b &&& 0x20 != 0
  let size := b &&& 0x1f
  let ok := if xmm then size == 2 || size == 4 || size == 8 || size == 16
    else 1 ≤ size && size ≤ 8
  if ok then some (some ⟨xmm, size, off⟩) else none

/-- A part the result stores can store: an `xmm` part of 2, 4, 8 or 16 bytes, an integer part
of 1 to 8. -/
def partOkS (p : RetPart) : Prop :=
  if p.xmm then p.size = 2 ∨ p.size = 4 ∨ p.size = 8 ∨ p.size = 16
  else 1 ≤ p.size ∧ p.size ≤ 8

theorem part1S_spec {b off : Nat} {p : RetPart} (h : part1S b off = some (some p)) :
    partOkS p ∧ p.off = off := by
  unfold part1S at h
  by_cases h1 : (b &&& 0xc0 != 0) = true
  · simp [h1] at h
  by_cases h2 : (b == 0) = true
  · simp [h1, h2] at h
  simp only [h1, h2, Bool.false_eq_true, ↓reduceIte, Option.ite_none_right_eq_some,
    Option.some.injEq] at h
  obtain ⟨hok, rfl⟩ := h
  refine ⟨?_, rfl⟩
  unfold partOkS
  simp only
  generalize (b &&& 0x20 != 0) = xb at hok ⊢
  generalize b &&& 0x1f = sz at hok ⊢
  cases xb <;> simp at hok ⊢ <;> omega

theorem retPartsS_eq (k : Nat) : retParts k false = (do
    if k >>> 24 != 0 then none
    let a ← part1S (k &&& 0xff) 0
    let b ← part1S (k >>> 8 &&& 0xff) (k >>> 16 &&& 0xff)
    match a, b with
    | none, some _ => none
    | none, none => if k != 0 then none else some (a, b)
    | some a', some b' => if b'.off < a'.size || b'.off + b'.size > 16 then none else some (a, b)
    | some _, none => if k >>> 16 != 0 then none else some (a, b)) := rfl

theorem retPartsS_spec {k : Nat} {a b : Option RetPart} (h : retParts k false = some (a, b)) :
    (a = none ∧ b = none) ∨ (∃ pa, a = some pa ∧ b = none ∧ partOkS pa ∧ pa.off = 0) ∨
    (∃ pa pb, a = some pa ∧ b = some pb ∧ partOkS pa ∧ partOkS pb ∧ pa.off = 0 ∧
      pa.size ≤ pb.off ∧ pb.off + pb.size ≤ 16) := by
  rw [retPartsS_eq] at h
  by_cases h24 : (k >>> 24 != 0) = true
  · simp [h24] at h
  cases ha0 : part1S (k &&& 0xff) 0 with
  | none => simp [h24, ha0] at h
  | some a0 =>
    cases hb0 : part1S (k >>> 8 &&& 0xff) (k >>> 16 &&& 0xff) with
    | none => simp [h24, ha0, hb0] at h
    | some b0 =>
      simp only [h24, ha0, hb0, Bool.false_eq_true, ↓reduceIte] at h
      cases a0 with
      | none =>
        cases b0 with
        | none =>
          simp at h
          obtain ⟨-, rfl, rfl⟩ := h
          exact .inl ⟨rfl, rfl⟩
        | some pb => simp at h
      | some pa =>
        obtain ⟨hpa, hoa⟩ := part1S_spec ha0
        cases b0 with
        | none =>
          simp at h
          obtain ⟨-, rfl, rfl⟩ := h
          exact .inr (.inl ⟨pa, rfl, rfl, hpa, hoa⟩)
        | some pb =>
          simp at h
          obtain ⟨⟨h1, h2⟩, rfl, rfl⟩ := h
          exact .inr (.inr ⟨pa, pb, rfl, rfl, hpa, (part1S_spec hb0).1, hoa, h1, h2⟩)

open Ryo.Proofs.ArgRet in
/-- A part's result store, from R register `r`'s home. -/
def storeR (d : BitVec 32) (q : RetPart × R.Reg) : List Item :=
  if q.1.xmm then sseStore q.1.size (retXmm q.2) (frameAt d q.1.off)
  else intStore q.1.size (retX86 q.2) (frameAt d q.1.off)

open Ryo.Proofs.ArgRet in
/-- `retRegs`' parts (store form) are `resultStores`' (each in its register), storable, within
16 bytes, in distinct registers. -/
theorem retRegsS_parts {k : Nat} {parts : List (RetPart × R.Reg)}
    (h : R.retRegs k false = .ok parts) (d : BitVec 32) :
    resultStores k d = parts.flatMap (storeR d) ∧
      (∀ q ∈ parts, partOkS q.1 ∧ RegFor q.1 q.2 ∧ q.1.off + q.1.size ≤ 16) ∧
      (parts.map (·.2)).Nodup := by
  unfold R.retRegs at h
  cases hk : retParts k false with
  | none => simp [hk, illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some ab =>
    obtain ⟨a, b⟩ := ab
    simp only [hk, pure, Except.pure, Except.ok.injEq] at h
    subst h
    unfold resultStores partRegs
    rw [hk]
    rcases retPartsS_spec hk with ⟨rfl, rfl⟩ | ⟨pa, rfl, rfl, hpa, hoa⟩ |
      ⟨pa, pb, rfl, rfl, hpa, hpb, hoa, h1, h2⟩
    · simp
    · have hs : pa.size ≤ 16 := by
        unfold partOkS at hpa; split at hpa <;> omega
      cases hx : pa.xmm <;>
        simp [hx, storeR, retX86, retXmm, RegFor, hpa, hoa, hs]
    · have hs : pa.size ≤ 16 := by
        unfold partOkS at hpa; split at hpa <;> omega
      cases hx : pa.xmm <;> cases hy : pb.xmm <;>
        simp [hx, hy, storeR, retX86, retXmm, RegFor, hpa, hpb, hoa, hs, h2]

theorem toInt_disp (d : BitVec 32) (o : Nat) (ho : o < 2 ^ 31) (h : d.toInt + o < 2 ^ 31) :
    (d + BitVec.ofNat 32 o).toInt = d.toInt + o := by
  have hb := toInt_bounds d
  have ho' : (BitVec.ofNat 32 o).toInt = o := by
    simp only [BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat]
    split <;> omega
  rw [BitVec.toInt_add_of_not_saddOverflow]
  · rw [ho']
  · simp only [BitVec.saddOverflow, ho', Bool.or_eq_true, decide_eq_true_eq, not_or]
    omega

open Ryo.Proofs.ArgRet in
theorem fpAddr_disp (y : X86.State) (d : BitVec 32) (o : Nat) (ho : o < 16)
    (hd : d.toInt + 16 ≤ 2 ^ 31) :
    fpAddr y (d + BitVec.ofNat 32 o).toInt = fpAddr y (d.toInt + o) := by
  have hb := toInt_bounds d
  have := ea_off y d o (by omega) (by omega)
  rw [← ea_frame, fpAddr_add]
  exact this

open Ryo.Proofs.ArgRet in
/-- One part's result store: the low `size` bytes of its register at frame offset `d + off`;
only `rax`, `rdx`, `r11` and the flags change, the other return registers kept. -/
theorem exec_storePart (ctx : Ctx) (d : BitVec 32) (p : RetPart) (rr : R.Reg) (y : X86.State)
    (hp : partOkS p) (hfor : RegFor p rr) (hoff : p.off + p.size ≤ 16)
    (hd : d.toInt + 16 ≤ 2 ^ 31) :
    ∃ y' V, execItems ctx (storeR d (p, rr)) y = .ok y' ∧
      y'.mem = y.mem.write (fpAddr y (d.toInt + p.off)) p.size V ∧
      (retBytes y rr).take p.size = leEncode p.size V ∧ y'.xmm = y.xmm ∧
      (∀ i : Fin 16, i ≠ 0 → i ≠ 2 → i ≠ 11 → y'.regs i = y.regs i) ∧
      y'.rip = y.rip + BitVec.ofNat 64 ((storeR d (p, rr)).map Item.size).sum ∧
      (∀ r' ∈ retRegList, r' ≠ rr → retBytes y' r' = retBytes y r') := by
  have hb := toInt_bounds d
  have hsz : p.size ≤ 16 := by unfold partOkS at hp; split at hp <;> omega
  have hsz1 : 1 ≤ p.size := by unfold partOkS at hp; split at hp <;> omega
  have hD : (d + BitVec.ofNat 32 p.off).toInt + p.size ≤ 2 ^ 31 := by
    rw [toInt_disp d p.off (by omega) (by omega)]; omega
  rcases hfor with ⟨hx, hr⟩ | ⟨hx, hr⟩
  · have hv : (p.xmm = true → p.size = 2 ∨ p.size = 4 ∨ p.size = 8 ∨ p.size = 16) ∧
        (p.xmm = false → 1 ≤ p.size ∧ p.size ≤ 8) := by
      unfold partOkS at hp; simp only [hx, Bool.false_eq_true, ↓reduceIte] at hp
      exact ⟨fun h => by simp [hx] at h, fun _ => hp⟩
    have h8 : p.size ≤ 8 := (hv.2 hx).2
    rcases hr with rfl | rfl
    · obtain ⟨y', e, m, xm, rs, rip⟩ := exec_argStore ctx ⟨false, p.size, 6⟩
        (d + BitVec.ofNat 32 p.off) false y (by simpa [hx] using hv) hD
      have hst : argStore ⟨false, p.size, 6⟩ (d + BitVec.ofNat 32 p.off) false = storeR d (p, .gpr 0) := by
        simp [argStore, storeR, hx, retX86, frameAt, intArg]
      rw [hst] at e rip
      refine ⟨y', _, e, by rw [m, fpAddr_disp y d p.off (by omega) hd], ?_, xm, ?_, rip, ?_⟩
      · simp only [retBytes, ↓reduceIte, argVal, Bool.false_eq_true]
        rw [leEncode_take _ _ _ (by omega)]; rfl
      · intro i h0 _ _
        apply rs
        intro g hg
        simp only [argClobbers, Bool.false_eq_true, ↓reduceIte] at hg
        split at hg
        · simp at hg
        · simp only [List.mem_singleton] at hg; subst hg; exact h0
      · intro r' hr' hne
        simp only [retRegList, List.mem_cons, List.not_mem_nil, or_false] at hr'
        have hrs : ∀ i : Fin 16, i ≠ 0 → y'.regs i = y.regs i := by
          intro i h0
          apply rs
          intro g hg
          simp only [argClobbers, Bool.false_eq_true, ↓reduceIte] at hg
          split at hg
          · simp at hg
          · simp only [List.mem_singleton] at hg; subst hg; exact h0
        rcases hr' with rfl | rfl | rfl | rfl
        · exact absurd rfl hne
        · show leEncode 8 (y'.regs 2).toNat = leEncode 8 (y.regs 2).toNat; rw [hrs 2 (by decide)]
        · simp [retBytes, xm]
        · simp [retBytes, xm]
    · obtain ⟨y', e, m, xm, rs, rip⟩ := exec_argStore ctx ⟨false, p.size, 2⟩
        (d + BitVec.ofNat 32 p.off) false y (by simpa [hx] using hv) hD
      have hst : argStore ⟨false, p.size, 2⟩ (d + BitVec.ofNat 32 p.off) false = storeR d (p, .gpr 1) := by
        simp [argStore, storeR, hx, retX86, frameAt, intArg]
      rw [hst] at e rip
      have hrs : ∀ i : Fin 16, i ≠ 2 → y'.regs i = y.regs i := by
        intro i h2
        apply rs
        intro g hg
        simp only [argClobbers, Bool.false_eq_true, ↓reduceIte] at hg
        split at hg
        · simp at hg
        · simp only [List.mem_singleton] at hg; subst hg; exact h2
      refine ⟨y', _, e, by rw [m, fpAddr_disp y d p.off (by omega) hd], ?_, xm,
        fun i _ h2 _ => hrs i h2, rip, ?_⟩
      · simp only [retBytes, argVal, Bool.false_eq_true, ↓reduceIte]
        rw [leEncode_take _ _ _ (by omega)]; rfl
      · intro r' hr' hne
        simp only [retRegList, List.mem_cons, List.not_mem_nil, or_false] at hr'
        rcases hr' with rfl | rfl | rfl | rfl
        · show leEncode 8 (y'.regs 0).toNat = leEncode 8 (y.regs 0).toNat; rw [hrs 0 (by decide)]
        · exact absurd rfl hne
        · simp [retBytes, xm]
        · simp [retBytes, xm]
  · have hv : (p.xmm = true → p.size = 2 ∨ p.size = 4 ∨ p.size = 8 ∨ p.size = 16) ∧
        (p.xmm = false → 1 ≤ p.size ∧ p.size ≤ 8) := by
      unfold partOkS at hp; simp only [hx, ↓reduceIte] at hp
      exact ⟨fun _ => hp, fun h => by simp [hx] at h⟩
    have key : ∀ i, (rr = .xmm i) → ∃ y' V, execItems ctx (storeR d (p, rr)) y = .ok y' ∧
        y'.mem = y.mem.write (fpAddr y (d.toInt + p.off)) p.size V ∧
        (retBytes y rr).take p.size = leEncode p.size V ∧ y'.xmm = y.xmm ∧
        (∀ i : Fin 16, i ≠ 0 → i ≠ 2 → i ≠ 11 → y'.regs i = y.regs i) ∧
        y'.rip = y.rip + BitVec.ofNat 64 ((storeR d (p, rr)).map Item.size).sum ∧
        (∀ r' ∈ retRegList, r' ≠ rr → retBytes y' r' = retBytes y r') := by
      intro i hi
      subst hi
      obtain ⟨y', e, m, xm, rs, rip⟩ := exec_argStore ctx ⟨true, p.size, i⟩
        (d + BitVec.ofNat 32 p.off) false y (by simpa [hx] using hv) hD
      have hst : argStore ⟨true, p.size, i⟩ (d + BitVec.ofNat 32 p.off) false = storeR d (p, .xmm i) := by
        simp [argStore, storeR, hx, retXmm, frameAt]
      rw [hst] at e rip
      have hrs : ∀ j : Fin 16, j ≠ 11 → y'.regs j = y.regs j := by
        intro j h11
        apply rs
        intro g hg
        simp only [argClobbers, ↓reduceIte] at hg
        split at hg
        · simp only [List.mem_singleton] at hg; subst hg; exact h11
        · simp at hg
      refine ⟨y', _, e, by rw [m, fpAddr_disp y d p.off (by omega) hd], ?_, xm,
        fun j _ _ h11 => hrs j h11, rip, ?_⟩
      · simp only [retBytes, argVal, ↓reduceIte]
        rw [leEncode_take _ _ _ (by omega)]
      · intro r' hr' hne
        simp only [retRegList, List.mem_cons, List.not_mem_nil, or_false] at hr'
        rcases hr' with rfl | rfl | rfl | rfl
        · show leEncode 8 (y'.regs 0).toNat = leEncode 8 (y.regs 0).toNat; rw [hrs 0 (by decide)]
        · show leEncode 8 (y'.regs 2).toNat = leEncode 8 (y.regs 2).toNat; rw [hrs 2 (by decide)]
        · simp [retBytes, xm]
        · simp [retBytes, xm]
    rcases hr with rfl | rfl
    · exact key 0 rfl
    · exact key 1 rfl

/-- The `n` frame bytes at `D` are private, and their x86 addresses in no live allocation. -/
def RangeApart (st : OpSem.State) (x : X86.State) (D : Int) (n : Nat) : Prop :=
  ∀ i < n, st.escapedAt (D + i) = none ∧ ∀ id al, st.mem.get? id = some al → al.live = true →
    ¬ (fpAddr x (D + i) - BitVec.ofNat 64 al.addr).toNat < al.size

theorem RangeApart.congr {st st' : OpSem.State} {x x' : X86.State} {D : Int} {n : Nat}
    (h : RangeApart st x D n) (he : st'.escaped = st.escaped) (hm : st'.mem = st.mem)
    (hb : x'.reg .rbp = x.reg .rbp) : RangeApart st' x' D n := by
  intro i hi
  have hfp : fpAddr x' (D + i) = fpAddr x (D + i) := by simp [fpAddr, hb]
  have hea : st'.escapedAt (D + i) = st.escapedAt (D + i) := by
    unfold OpSem.State.escapedAt; rw [he]
  rw [hea, hm, hfp]; exact h i hi

/-- A private write of `n` bytes at `D`, whose x86 addresses are in no live allocation, keeps
`MemRel`. -/
theorem memRel_frame' {st st' : OpSem.State} {x x' : X86.State} {D : Int} {n : Nat}
    (hm : MemRel st x) (hmem : st'.mem = st.mem) (hap : RangeApart st x D n)
    (hx : ∀ b, n ≤ (b - fpAddr x D).toNat → x'.mem b = x.mem b) : MemRel st' x' := by
  intro id a hg hl i hi
  rw [hmem] at hg
  by_cases hc : n ≤ (BitVec.ofNat 64 (a.addr + i) - fpAddr x D).toNat
  · rw [hx _ hc]; exact hm id a hg hl i hi
  · exfalso
    generalize hb : BitVec.ofNat 64 (a.addr + i) = b at hc
    have := (hap _ (Nat.lt_of_not_le hc)).2 id a hg hl
    rw [fpAddr_add, bv_add_sub_toNat, ← hb, ofNat_add_sub] at this
    apply this
    simp only [BitVec.toNat_ofNat, Allocation.size]
    exact Nat.lt_of_le_of_lt (Nat.mod_le _ _) hi

theorem writeFrame_ok_private {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    (hp : ∀ i < bs.length, st.escapedAt (off + i) = none) : ∃ st', st.writeFrame off bs = .ok st' := by
  unfold OpSem.State.writeFrame
  rw [writeEscaped_private hp]
  exact ⟨_, rfl⟩

open Ryo.Proofs.ArgRet in
/-- The result stores of parts `L` against `answer`'s fold of frame writes. -/
theorem exec_stores (ctx : Ctx) (d : BitVec 32) (regs : R.Regs) (hd : d.toInt + 16 ≤ 2 ^ 31) :
    ∀ (L : List (RetPart × R.Reg)) (st : OpSem.State) (y : X86.State),
      (∀ q ∈ L, partOkS q.1 ∧ RegFor q.1 q.2 ∧ q.1.off + q.1.size ≤ 16) → (L.map (·.2)).Nodup →
      Rel st y → MemRel st y → (∀ q ∈ L, RangeApart st y (d.toInt + q.1.off) q.1.size) →
      (∀ q ∈ L, BytesRel (regs.get q.2) (retBytes y q.2)) →
      ∃ st' y', L.foldlM (init := st) (fun st (q : RetPart × R.Reg) =>
          st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok st' ∧
        execItems ctx (L.flatMap (storeR d)) y = .ok y' ∧ Rel st' y' ∧ MemRel st' y' ∧
        st'.escaped = st.escaped ∧ st'.mem = st.mem ∧ st'.exposed = st.exposed ∧
        st'.exception = st.exception ∧ st'.zeroSized = st.zeroSized ∧
        (∀ i : Fin 16, i ≠ 0 → i ≠ 2 → i ≠ 11 → y'.regs i = y.regs i) ∧
        y'.rip = y.rip + BitVec.ofNat 64 ((L.flatMap (storeR d)).map Item.size).sum
  | [], st, y, _, _, hr, hm, _, _ =>
    ⟨st, y, rfl, rfl, hr, hm, rfl, rfl, rfl, rfl, rfl, fun _ _ _ _ => rfl, by simp⟩
  | (p, rr) :: L, st, y, hL, hnd, hr, hm, hap, hrr => by
    obtain ⟨hp, hfor, hoff⟩ := hL (p, rr) (by simp)
    simp only at hp hfor hoff
    have hb := toInt_bounds d
    obtain ⟨y1, V, e1, m1, hV, x1, rs1, p1, ro1⟩ := exec_storePart ctx d p rr y hp hfor hoff hd
    have hrel := hrr (p, rr) (by simp)
    simp only at hrel
    have hw8 : p.size ≤ rr.width := by
      unfold partOkS at hp
      rcases hfor with ⟨hx, h | h⟩ | ⟨hx, h | h⟩ <;> subst h <;>
        simp only [hx, ↓reduceIte, Bool.false_eq_true, R.Reg.width] at hp ⊢ <;> omega
    have hlenr : (retBytes y rr).length = rr.width := by
      cases rr <;> simp [retBytes, R.Reg.width, leEncode_length]
    have hbs : BytesRel ((regs.get rr).take p.size) (leEncode p.size V) := by
      rw [← hV]; exact BytesRel.take _ hrel
    have hlen : ((regs.get rr).take p.size).length = p.size := by
      rw [hbs.length, leEncode_length]
    have hap0 := hap (p, rr) (by simp)
    simp only at hap0
    obtain ⟨st1, hw1⟩ := writeFrame_ok_private (st := st) (off := d.toInt + p.off)
      (bs := (regs.get rr).take p.size) (fun i hi => (hap0 i (by omega)).1)
    have hrbp : y1.reg .rbp = y.reg .rbp := rs1 5 (by decide) (by decide) (by decide)
    obtain ⟨hrel1, h1, h2, h3, h4, h5⟩ := rel_store hr hw1 (by omega) (by omega)
      (by rw [hlen]; exact hbs) hrbp (by rw [m1, hlen])
    have hmem1 : st1.mem = st.mem :=
      writeFrame_mem_private hw1 (fun i hi => (hap0 i (by omega)).1)
    have hm1 : MemRel st1 y1 := memRel_frame' hm hmem1 hap0 (fun b hb' => by
      rw [m1]; exact X86.Mem.write_other _ _ _ _ _ hb')
    have hnd' : (L.map (·.2)).Nodup := (List.nodup_cons.1 hnd).2
    have hnot : rr ∉ L.map (·.2) := (List.nodup_cons.1 hnd).1
    obtain ⟨st2, y2, f2, e2, hr2, hm2, g1, g2, g3, g4, g5, rs2, p2⟩ := exec_stores ctx d regs hd L
      st1 y1 (fun q hq => hL q (by simp [hq])) hnd' hrel1 hm1
      (fun q hq => (hap q (by simp [hq])).congr h2 hmem1 hrbp)
      (fun q hq => by
        have hne : q.2 ≠ rr := fun h => hnot (List.mem_map.2 ⟨q, hq, h⟩)
        have hq' := hrr q (by simp [hq])
        have hmem : q.2 ∈ retRegList := by
          obtain ⟨_, hf, _⟩ := hL q (by simp [hq])
          rcases hf with ⟨_, h | h⟩ | ⟨_, h | h⟩ <;> rw [h] <;> simp [retRegList]
        rw [ro1 _ hmem hne]; exact hq')
    refine ⟨st2, y2, ?_, ?_, hr2, hm2, g1.trans h2, g2.trans hmem1, g3.trans h3, g4.trans h4,
      g5.trans h5, fun i h0 h2' h11 => by rw [rs2 i h0 h2' h11, rs1 i h0 h2' h11], ?_⟩
    · simp only [List.foldlM_cons, hw1, bind, Except.bind]; exact f2
    · rw [List.flatMap_cons, ArgRet.execItems_append, e1]; exact e2
    · rw [p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add]

end Ryo.Proofs.CallLemmas
