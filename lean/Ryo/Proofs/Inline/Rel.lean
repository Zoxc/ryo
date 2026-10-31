/-
Ryo.Proofs.Inline.Rel — the R ↔ L2 relation on a frame (reduced.md §C0.7: provenance erased,
`Uninit` refined by any byte), and how frame reads and writes keep it.

- `ByteRel b x`: R's abstract byte `b` and L2's byte `x`: an initialized byte (an integer
  byte, or a pointer fragment with its provenance erased) is the same byte; `Uninit` relates
  to any byte.
- `Rel st x`: `opSem`'s state `st` and the x86 state `x`, with `fp` in `rbp`: every frame byte
  at an offset `o` in `[-2^63, 2^63)` (one offset per address) that `st` reads without failing
  (`byteAt`: private, or its escaped object's allocation byte) relates to the byte at
  `rbp + o`; each escaped object's allocation is at `rbp + off` (`φ_AOT`, §C0.2); and each
  zero-sized frame object is at its frame address (`zeroSized`).
- `readFrame_rel`, `asNat_rel`: a frame read of `n` bytes at `o` relates to the `n` x86 bytes
  at `rbp + o`, and decodes to their little-endian value.
- `rel_writeFrame`: a write of frame bytes at `d` (private, or in escaped objects:
  `writeEscaped`), against x86 memory that changes exactly at those addresses, to bytes they
  relate to, keeps `Rel`, keeps `opSem`'s escapes, exposure and exception, and changes its
  memory only in the escaped objects' allocations (`EscOnly`). Escaped objects of one
  allocation can't alias each other's bytes under `Rel`: they are at their frame addresses
  (`esc_inj`).
-/
import Ryo.Vm.OpSem
import Ryo.X86.Exec
import Ryo.Spec.Theorems.Bytes
import Std.Tactic.BVDecide

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem

/-! ### Bytes -/

/-- An R byte and an L2 byte (§C0.7): provenance erased, `Uninit` refined by any byte. -/
def ByteRel : AbstractByte → UInt8 → Prop
  | .uninit, _ => True
  | .init b _, x => b = x

/-- Byte lists, byte for byte (same length). -/
def BytesRel : List AbstractByte → List UInt8 → Prop
  | [], [] => True
  | b :: bs, x :: xs => ByteRel b x ∧ BytesRel bs xs
  | _, _ => False

theorem BytesRel.length : ∀ {bs : List AbstractByte} {xs : List UInt8}, BytesRel bs xs →
    bs.length = xs.length
  | [], [], _ => rfl
  | _ :: _, _ :: _, h => by simp [BytesRel.length h.2]

theorem BytesRel.getElem : ∀ {bs : List AbstractByte} {xs : List UInt8}, BytesRel bs xs →
    ∀ i (h1 : i < bs.length) (h2 : i < xs.length), ByteRel bs[i] xs[i]
  | [], [], _, _, h1, _ => by simp at h1
  | _ :: _, _ :: _, h, 0, _, _ => h.1
  | _ :: _, _ :: _, h, i + 1, h1, h2 =>
    BytesRel.getElem h.2 i (by simpa using h1) (by simpa using h2)

theorem BytesRel.append {bs' : List AbstractByte} {xs' : List UInt8} (h' : BytesRel bs' xs') :
    ∀ {bs : List AbstractByte} {xs : List UInt8}, BytesRel bs xs → BytesRel (bs ++ bs') (xs ++ xs')
  | [], [], _ => h'
  | _ :: _, _ :: _, h => ⟨h.1, BytesRel.append h' h.2⟩

/-- Integer bytes relate to their bytes. -/
theorem BytesRel.ofBytes : ∀ (xs : List UInt8), BytesRel (xs.map AbstractByte.ofByte) xs
  | [] => trivial
  | _ :: xs => ⟨rfl, BytesRel.ofBytes xs⟩

/-- Pointer bytes relate to their address's bytes. -/
theorem BytesRel.encodePtr (p : ThinPointer) :
    BytesRel (encodePtr p) (leEncode 8 p.addr) := by
  simp only [Ryo.Spec.encodePtr, Target.PTR_SIZE]
  generalize leEncode 8 p.addr = l
  suffices ∀ k, BytesRel ((l.zipIdx k).map fun (b, i) =>
      AbstractByte.init b (p.prov.map fun pr => ⟨pr, i⟩)) l by exact this 0
  induction l with
  | nil => intro; trivial
  | cons x l ih => intro k; exact ⟨rfl, ih (k + 1)⟩

/-- Defined bytes decode to the value of the bytes they relate to. -/
theorem decodeBits_rel : ∀ {bs : List AbstractByte} {xs : List UInt8} {v : Nat}, BytesRel bs xs →
    decodeBits bs = some v → v = leDecode xs
  | [], [], v, _, h => by simp [decodeBits, leDecode] at h ⊢; omega
  | b :: bs, x :: xs, v, h, hd => by
    simp only [decodeBits, List.mapM_cons, Option.bind_eq_bind, Option.pure_def] at hd
    cases b with
    | uninit => simp [AbstractByte.data] at hd
    | init y f =>
      have hy : y = x := h.1
      subst hy
      cases hm : bs.mapM AbstractByte.data with
      | none => simp [AbstractByte.data, hm] at hd
      | some ds =>
        simp only [AbstractByte.data, hm, Option.bind_some, Option.some.injEq] at hd
        have := decodeBits_rel (v := leDecode ds) h.2 (by simp [decodeBits, hm])
        subst hd
        simp [leDecode, this]

theorem asNat_rel {bs : List AbstractByte} {xs : List UInt8} {v : Nat} (h : BytesRel bs xs)
    (hv : asNat bs = .ok v) : v = leDecode xs := by
  unfold asNat at hv
  split at hv
  · rename_i n hn
    cases hv
    exact decodeBits_rel h hn
  · cases hv

theorem asPtr_rel {bs : List AbstractByte} {xs : List UInt8} {p : ThinPointer} (h : BytesRel bs xs)
    (hv : asPtr bs = .ok p) : p.addr = leDecode xs := by
  unfold asPtr at hv
  split at hv
  · rename_i q hq
    cases hv
    rw [Theorems.decodePtr_eq] at hq
    cases hd : decodeBits bs with
    | none => simp [hd] at hq
    | some n =>
      simp only [hd, Option.map_some, Option.some.injEq] at hq
      subst hq
      exact decodeBits_rel h hd
  · cases hv

/-! ### x86 memory as bytes -/

/-- The `n` bytes of `m` at `a`. -/
def bytesAt (m : X86.Mem) (a : BitVec 64) (n : Nat) : List UInt8 :=
  (List.range n).map fun i => m (a + BitVec.ofNat 64 i)

theorem bytesAt_length (m : X86.Mem) (a : BitVec 64) (n : Nat) : (bytesAt m a n).length = n := by
  simp [bytesAt]

theorem getElem_bytesAt (m : X86.Mem) (a : BitVec 64) (n i : Nat) (h : i < (bytesAt m a n).length) :
    (bytesAt m a n)[i] = m (a + BitVec.ofNat 64 i) := by
  simp [bytesAt]

theorem readNat_eq (m : X86.Mem) (a : BitVec 64) (n : Nat) :
    m.readNat a n = leDecode (bytesAt m a n) := by
  unfold X86.Mem.readNat bytesAt
  generalize List.range n = l
  induction l with
  | nil => rfl
  | cons i l ih => simp [leDecode, ih]

theorem bytesAt_add (m : X86.Mem) (a : BitVec 64) (n k : Nat) :
    bytesAt m a (n + k) = bytesAt m a n ++ bytesAt m (a + BitVec.ofNat 64 n) k := by
  apply List.ext_getElem
  · simp [bytesAt_length]
  · intro i h1 h2
    simp only [getElem_bytesAt, List.getElem_append]
    split
    · simp
    · rename_i hi
      simp only [bytesAt_length] at hi ⊢
      rw [BitVec.add_assoc, ← BitVec.ofNat_add]
      congr 3
      omega

theorem getElem_leEncode : ∀ (n v i : Nat) (h : i < (leEncode n v).length),
    (leEncode n v)[i] = UInt8.ofNat (v / 256 ^ i)
  | 0, _, _, h => by simp [leEncode] at h
  | n + 1, v, 0, _ => by simp only [leEncode]; apply UInt8.toNat_inj.1; simp
  | n + 1, v, i + 1, h => by
    simp only [leEncode, List.getElem_cons_succ]
    rw [getElem_leEncode n (v / 256) i (by simp [leEncode] at h; simpa [leEncode_length] using h)]
    rw [Nat.div_div_eq_div_mul, Nat.pow_succ, Nat.mul_comm (256 ^ i)]

/-- The bytes `Mem.write` puts at `a`. -/
theorem bytesAt_write (m : X86.Mem) (a : BitVec 64) (n v : Nat) (hn : n ≤ 2 ^ 64) :
    bytesAt (m.write a n v) a n = leEncode n v := by
  apply List.ext_getElem
  · simp [bytesAt_length, leEncode_length]
  · intro i h1 h2
    rw [getElem_bytesAt, getElem_leEncode]
    simp only [X86.Mem.write]
    have hi : ((a + BitVec.ofNat 64 i) - a).toNat = i := by
      have : (a + BitVec.ofNat 64 i) - a = BitVec.ofNat 64 i := by
        generalize BitVec.ofNat 64 i = c; bv_decide
      rw [this]
      simp [bytesAt_length] at h1
      simp; omega
    rw [hi]
    simp only [bytesAt_length] at h1
    simp only [h1, ↓reduceIte, Nat.shiftRight_eq_div_pow, Nat.pow_mul]

/-! ### Frame offsets and addresses -/

/-- The address of frame offset `o` in `x` (`fp` is `rbp`). -/
def fpAddr (x : X86.State) (o : Int) : BitVec 64 := x.reg .rbp + BitVec.ofInt 64 o

theorem fpAddr_add (x : X86.State) (o : Int) (i : Nat) :
    fpAddr x (o + i) = fpAddr x o + BitVec.ofNat 64 i := by
  simp [fpAddr, BitVec.ofInt_add, BitVec.add_assoc]

theorem fpAddr_sub (x : X86.State) (o d : Int) :
    fpAddr x o - fpAddr x d = BitVec.ofInt 64 (o - d) := by
  simp only [fpAddr]
  rw [Int.sub_eq_add_neg, BitVec.ofInt_add, BitVec.ofInt_neg]
  generalize x.reg .rbp = r
  generalize BitVec.ofInt 64 o = a
  generalize BitVec.ofInt 64 d = b
  bv_decide

/-- Frame offsets `[d, d + n)` are the addresses `rbp + d + i`: any other in-range offset is at
least `n` bytes from `rbp + d`. -/
theorem fpAddr_sub_ge (x : X86.State) (o d : Int) (n : Nat) (ho : -2 ^ 63 ≤ o ∧ o < 2 ^ 63)
    (hd : -2 ^ 63 ≤ d) (hdn : d + n ≤ 2 ^ 63) (hout : ¬ (d ≤ o ∧ o < d + n)) :
    n ≤ (fpAddr x o - fpAddr x d).toNat := by
  have : fpAddr x o - fpAddr x d = BitVec.ofInt 64 (o - d) := fpAddr_sub x o d
  rw [this, BitVec.toNat_ofInt]
  omega

theorem fpAddr_sub_lt (x : X86.State) (o d : Int) (hin : d ≤ o ∧ o < d + 2 ^ 63) :
    (fpAddr x o - fpAddr x d).toNat = (o - d).toNat := by
  have : fpAddr x o - fpAddr x d = BitVec.ofInt 64 (o - d) := fpAddr_sub x o d
  rw [this, BitVec.toNat_ofInt]
  omega

/-! ### The relation -/

/-- `opSem`'s state and the x86 state, with `fp` in `rbp` (§C0.7, under `φ_AOT`). -/
structure Rel (st : OpSem.State) (x : X86.State) : Prop where
  /-- Each frame byte `opSem` can read relates to the byte at its address. -/
  frame : ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → ∀ b, st.byteAt o = .ok b →
    ByteRel b (x.mem (fpAddr x o))
  /-- Escaped objects are allocations at their frame address. -/
  layout : ∀ e ∈ st.escaped, ∀ a, st.mem.get? e.id = some a →
    BitVec.ofNat 64 a.addr = fpAddr x e.off
  /-- Zero-sized frame objects are at their frame address. -/
  zeroSized : ∀ p ∈ st.zeroSized, BitVec.ofNat 64 p.2 = fpAddr x p.1

theorem mapM_ok {α β ε : Type} {f : α → Except ε β} :
    ∀ {l : List α} {bs : List β}, l.mapM f = .ok bs →
      bs.length = l.length ∧ ∀ i (h1 : i < l.length) (h2 : i < bs.length), f l[i] = .ok bs[i]
  | [], bs, h => by
    simp only [List.mapM_nil, pure, Except.pure, Except.ok.injEq] at h
    subst h; simp
  | x :: l, bs, h => by
    simp only [List.mapM_cons, bind, Except.bind] at h
    cases hx : f x with
    | error e => simp [hx] at h
    | ok b =>
      simp only [hx] at h
      cases hl : l.mapM f with
      | error e => simp [hl] at h
      | ok bs' =>
        simp only [hl, pure, Except.pure, Except.ok.injEq] at h
        subst h
        obtain ⟨hlen, hall⟩ := mapM_ok hl
        refine ⟨by simp [hlen], fun i h1 h2 => ?_⟩
        cases i with
        | zero => simpa using hx
        | succ i => simpa using hall i (by simpa using h1) (by simpa using h2)

/-- A frame read relates to the bytes at its address. -/
theorem readFrame_rel {st : OpSem.State} {x : X86.State} (hr : Rel st x) {o : Int} {n : Nat}
    {bs : List AbstractByte} (h : st.readFrame o n = .ok bs) (ho : -2 ^ 63 ≤ o)
    (hon : o + n ≤ 2 ^ 63) : BytesRel bs (bytesAt x.mem (fpAddr x o) n) := by
  obtain ⟨hlen, hall⟩ := mapM_ok h
  simp only [List.length_range] at hlen
  suffices ∀ (bs : List AbstractByte) (xs : List UInt8), bs.length = xs.length →
      (∀ i (h1 : i < bs.length) (h2 : i < xs.length), ByteRel bs[i] xs[i]) → BytesRel bs xs by
    apply this _ _ (by simp [bytesAt_length, hlen])
    intro i h1 h2
    have := hall i (by simp; omega) h1
    simp only [List.getElem_range] at this
    rw [getElem_bytesAt, ← fpAddr_add]
    exact hr.frame _ (by omega) (by omega) _ this
  intro bs
  induction bs with
  | nil => intro xs hl _; cases xs <;> simp_all [BytesRel]
  | cons b bs ih =>
    intro xs hl hb
    cases xs with
    | nil => simp at hl
    | cons y xs =>
      exact ⟨hb 0 (by simp) (by simp),
        ih xs (by simpa using hl) fun i h1 h2 => hb (i + 1) (by simpa using h1) (by simpa using h2)⟩

/-! ### Writes -/

theorem writeEscaped_private {st : OpSem.State} {off : Int} {bs : List AbstractByte}
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

/-- A private write keeps `opSem`'s memory. -/
theorem writeFrame_mem_private {st st' : OpSem.State} {d : Int} {bs : List AbstractByte}
    (hw : st.writeFrame d bs = .ok st') (hp : ∀ i < bs.length, st.escapedAt (d + i) = none) :
    st'.mem = st.mem := by
  unfold OpSem.State.writeFrame at hw
  rw [writeEscaped_private hp] at hw
  simp only [bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw; rfl

theorem byteAt_with (st : OpSem.State) (f : Int → AbstractByte) (o : Int) :
    ({ st with mem := st.mem, frame := f } : OpSem.State).byteAt o =
      match st.escapedAt o with
      | none => pure (f o)
      | some _ => st.byteAt o := by
  have he : ({ st with mem := st.mem, frame := f } : OpSem.State).escapedAt o = st.escapedAt o :=
    rfl
  unfold OpSem.State.byteAt
  rw [he]
  cases st.escapedAt o <;> rfl

/-- The step of `writeEscaped`'s fold. -/
def escStep (st : OpSem.State) (off : Int) (mem : Memory) (p : AbstractByte × Nat) : OpSem.M Memory :=
  match st.escapedAt (off + p.2) with
  | none => pure mem
  | some e =>
    match mem.get? e.id with
    | none => illFormed s!"escaped frame object at {e.off} has no allocation"
    | some a =>
      let a' := { a with data := a.data.set! (off + p.2 - e.off).toNat p.1 }
      pure { allocs := mem.allocs.set! e.id a' }

/-- The write `p` (byte `p.1` at frame offset `off + p.2`) lands at byte `j` of allocation
`id`: its offset is in an escaped object of that allocation, at index `j`. -/
def Hits (st : OpSem.State) (off : Int) (p : AbstractByte × Nat) (id : AllocId) (j : Nat) : Prop :=
  ∃ e, st.escapedAt (off + p.2) = some e ∧ e.id = id ∧ (off + p.2 - e.off).toNat = j

/-- How memory `m'` comes from `m` by the escaped-object writes `l` (`writeEscaped`): the same
allocations, which differ at most in their data, at the bytes the writes hit, each of which
holds a byte one of them wrote. -/
def EscFrom (st : OpSem.State) (off : Int) (l : List (AbstractByte × Nat)) (m m' : Memory) : Prop :=
  m'.allocs.size = m.allocs.size ∧
  ∀ id a', m'.get? id = some a' → ∃ a, m.get? id = some a ∧ a' = { a with data := a'.data } ∧
    a'.data.size = a.data.size ∧ ∀ j,
      ((∀ p ∈ l, ¬ Hits st off p id j) → a'.data[j]? = a.data[j]?) ∧
      ((∃ p ∈ l, Hits st off p id j) → j < a.data.size →
        ∃ q ∈ l, Hits st off q id j ∧ a'.data[j]? = some q.1)

theorem EscFrom.refl (st : OpSem.State) (off : Int) (m : Memory) : EscFrom st off [] m m :=
  ⟨rfl, fun id a' h => ⟨a', h, rfl, rfl, fun _ => ⟨fun _ => rfl, fun ⟨_, hp, _⟩ => by simp at hp⟩⟩⟩

theorem escStep_spec {st : OpSem.State} {off : Int} {m m' : Memory} {p : AbstractByte × Nat}
    (h : escStep st off m p = .ok m') : EscFrom st off [p] m m' := by
  unfold escStep at h
  split at h
  · rename_i hn
    cases h
    refine ⟨rfl, fun id a' h => ⟨a', h, rfl, rfl, fun j => ⟨fun _ => rfl, ?_⟩⟩⟩
    rintro ⟨q, hq, e, he, -⟩
    simp only [List.mem_singleton] at hq
    subst hq
    rw [hn] at he; cases he
  · rename_i e he
    split at h
    · cases h
    · rename_i a ha
      cases h
      refine ⟨by simp, fun id a' h' => ?_⟩
      simp only [Memory.get?, Array.set!_eq_setIfInBounds, Array.getElem?_setIfInBounds] at h' ha
      by_cases hid : e.id = id
      · subst hid
        have hlt : e.id < m.allocs.size := by
          rcases Array.getElem?_eq_some_iff.1 ha with ⟨h1, _⟩; exact h1
        simp only [hlt, ↓reduceIte, Option.some.injEq] at h'
        subst h'
        refine ⟨a, ha, rfl, by simp, fun j => ⟨fun hn => ?_, fun hh hj => ?_⟩⟩
        · simp only [Array.set!_eq_setIfInBounds, Array.getElem?_setIfInBounds]
          split
          · rename_i hj; exact absurd ⟨e, he, rfl, hj⟩ (hn p (List.mem_singleton_self _))
          · rfl
        · obtain ⟨q, hq, e', he', -, hj'⟩ := hh
          simp only [List.mem_singleton] at hq
          subst hq
          rw [he] at he'; cases he'
          refine ⟨q, List.mem_singleton_self _, ⟨e, he, rfl, hj'⟩, ?_⟩
          simp [Array.set!_eq_setIfInBounds, Array.getElem?_setIfInBounds, hj', hj]
      · simp only [hid, ↓reduceIte] at h'
        exact ⟨a', h', rfl, rfl, fun _ => ⟨fun _ => rfl, fun ⟨q, hq, e', he', hid', _⟩ => by
          simp only [List.mem_singleton] at hq; subst hq; rw [he] at he'; cases he'
          exact absurd hid' hid⟩⟩

theorem EscFrom.trans {st : OpSem.State} {off : Int} {l1 l2 : List (AbstractByte × Nat)}
    {m1 m2 m3 : Memory} (h1 : EscFrom st off l1 m1 m2) (h2 : EscFrom st off l2 m2 m3) :
    EscFrom st off (l1 ++ l2) m1 m3 := by
  refine ⟨h2.1.trans h1.1, fun id a3 h => ?_⟩
  obtain ⟨a2, ha2, he2, hs2, hj2⟩ := h2.2 id a3 h
  obtain ⟨a1, ha1, he1, hs1, hj1⟩ := h1.2 id a2 ha2
  refine ⟨a1, ha1, by rw [he2, he1], hs2.trans hs1, fun j => ⟨fun hn => ?_, fun hh hj => ?_⟩⟩
  · rw [(hj2 j).1 (fun p hp => hn p (List.mem_append_right _ hp)),
      (hj1 j).1 (fun p hp => hn p (List.mem_append_left _ hp))]
  · by_cases h2h : ∃ p ∈ l2, Hits st off p id j
    · obtain ⟨q, hq, hh', hv⟩ := (hj2 j).2 h2h (by omega)
      exact ⟨q, List.mem_append_right _ hq, hh', hv⟩
    · have heq := (hj2 j).1 (fun p hp hh' => h2h ⟨p, hp, hh'⟩)
      obtain ⟨p, hp, hph⟩ := hh
      rcases List.mem_append.1 hp with hp | hp
      · obtain ⟨q, hq, hh', hv⟩ := (hj1 j).2 ⟨p, hp, hph⟩ hj
        exact ⟨q, List.mem_append_left _ hq, hh', heq.trans hv⟩
      · exact absurd ⟨p, hp, hph⟩ h2h

theorem foldlM_escStep {st : OpSem.State} {off : Int} :
    ∀ (l : List (AbstractByte × Nat)) (m m' : Memory),
      l.foldlM (escStep st off) m = .ok m' → EscFrom st off l m m' := by
  intro l
  induction l with
  | nil => intro m m' h; cases h; exact EscFrom.refl ..
  | cons p l ih =>
    intro m m' h
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : escStep st off m p with
    | error e => simp [h1] at h
    | ok m1 =>
      simp only [h1] at h
      exact (escStep_spec h1).trans (ih m1 m' h)

theorem writeEscaped_spec {st : OpSem.State} {off : Int} {bs : List AbstractByte} {m' : Memory}
    (h : st.writeEscaped off bs = .ok m') : EscFrom st off bs.zipIdx st.mem m' :=
  foldlM_escStep _ _ _ h

theorem escapedAt_some {st : OpSem.State} {o : Int} {e : EscapedObj}
    (h : st.escapedAt o = some e) : e ∈ st.escaped ∧ e.off ≤ o ∧ o < e.off + e.size := by
  unfold OpSem.State.escapedAt at h
  have h1 := List.mem_of_find?_eq_some h
  have h2 := List.find?_some h
  simp only [decide_eq_true_eq] at h2
  exact ⟨h1, h2⟩

theorem mem_zipIdx {bs : List AbstractByte} {q : AbstractByte × Nat} (h : q ∈ bs.zipIdx) :
    ∃ hk : q.2 < bs.length, q.1 = bs[q.2] := by
  obtain ⟨b, k⟩ := q
  rw [List.mem_zipIdx_iff_getElem?] at h
  obtain ⟨hk, hb⟩ := List.getElem?_eq_some_iff.1 h
  exact ⟨hk, hb.symm⟩

/-- Under `Rel`, two in-range frame offsets in escaped objects of the same allocation, at the
same index, are the same offset: escaped objects are at their frame addresses. -/
theorem esc_inj {st : OpSem.State} {x : X86.State} (hr : Rel st x) {o o' : Int}
    {e e' : EscapedObj} (ho : -2 ^ 63 ≤ o ∧ o < 2 ^ 63) (ho' : -2 ^ 63 ≤ o' ∧ o' < 2 ^ 63)
    (he : st.escapedAt o = some e) (he' : st.escapedAt o' = some e') (hid : e'.id = e.id)
    {a : Allocation} (ha : st.mem.get? e.id = some a)
    (hj : (o' - e'.off).toNat = (o - e.off).toNat) : o' = o := by
  obtain ⟨hm, h1, h2⟩ := escapedAt_some he
  obtain ⟨hm', h1', h2'⟩ := escapedAt_some he'
  have l1 := hr.layout e hm a ha
  have l2 := hr.layout e' hm' a (by rw [hid]; exact ha)
  have : BitVec.ofInt 64 e.off = BitVec.ofInt 64 e'.off := by
    have := l1.symm.trans l2
    simpa [fpAddr] using this
  have := congrArg BitVec.toNat this
  simp only [BitVec.toNat_ofInt] at this
  omega

/-- Memory `m'` differs from `m` at most in the data of the allocations of `st`'s escaped
objects (a frame write: `writeFrame`). -/
def EscOnly (st : OpSem.State) (m m' : Memory) : Prop :=
  m'.allocs.size = m.allocs.size ∧
  ∀ id a', m'.get? id = some a' → ∃ a, m.get? id = some a ∧ a' = { a with data := a'.data } ∧
    a'.data.size = a.data.size ∧ ((∀ e ∈ st.escaped, e.id ≠ id) → a' = a)

theorem EscOnly.refl (st : OpSem.State) (m : Memory) : EscOnly st m m :=
  ⟨rfl, fun _ a' h => ⟨a', h, rfl, rfl, fun _ => rfl⟩⟩

theorem EscOnly.trans {st : OpSem.State} {m1 m2 m3 : Memory} (h1 : EscOnly st m1 m2)
    (h2 : EscOnly st m2 m3) : EscOnly st m1 m3 := by
  refine ⟨h2.1.trans h1.1, fun id a3 h => ?_⟩
  obtain ⟨a2, ha2, he2, hs2, hn2⟩ := h2.2 id a3 h
  obtain ⟨a1, ha1, he1, hs1, hn1⟩ := h1.2 id a2 ha2
  exact ⟨a1, ha1, by rw [he2, he1], hs2.trans hs1, fun hn => (hn2 hn).trans (hn1 hn)⟩

theorem EscOnly.of_escaped {st st1 : OpSem.State} {m m' : Memory} (h : EscOnly st1 m m')
    (he : st1.escaped = st.escaped) : EscOnly st m m' :=
  ⟨h.1, fun id a' ha => let ⟨a, h1, h2, h3, h4⟩ := h.2 id a' ha
    ⟨a, h1, h2, h3, fun hn => h4 (he ▸ hn)⟩⟩

theorem EscFrom.escOnly {st : OpSem.State} {off : Int} {l : List (AbstractByte × Nat)}
    {m m' : Memory} (h : EscFrom st off l m m') : EscOnly st m m' := by
  refine ⟨h.1, fun id a' ha' => ?_⟩
  obtain ⟨a, ha, hae, hsz, hj⟩ := h.2 id a' ha'
  refine ⟨a, ha, hae, hsz, fun hn => ?_⟩
  have hd : a'.data = a.data := Array.ext_getElem? fun j => (hj j).1 fun p _ ⟨e, he, hid, _⟩ =>
    hn e (escapedAt_some he).1 hid
  rw [hae, hd]

/-- `st'` differs from `st` at most in its frame bytes, private or escaped (`EscOnly`). -/
def SameButWrites (st' st : OpSem.State) : Prop :=
  st'.escaped = st.escaped ∧ EscOnly st st.mem st'.mem ∧ st'.exposed = st.exposed ∧
    st'.exception = st.exception ∧ st'.zeroSized = st.zeroSized

theorem SameButWrites.refl (st : OpSem.State) : SameButWrites st st :=
  ⟨rfl, EscOnly.refl _ _, rfl, rfl, rfl⟩

/-- The relation after a frame write at `d` (private or escaped bytes), against an x86 state
whose memory changed exactly at `rbp + d + i` (`i < bs.length`), to bytes the written ones
relate to. `opSem`'s memory changes only in the escaped objects' allocations (`EscOnly`), and
the escaped objects, `exposed`, `exception` and `zeroSized` are kept. -/
theorem rel_writeFrame {st st' : OpSem.State} {x x' : X86.State} {d : Int} {bs : List AbstractByte}
    {xs : List UInt8} (hr : Rel st x) (hw : st.writeFrame d bs = .ok st') (hd : -2 ^ 63 ≤ d)
    (hdn : d + bs.length ≤ 2 ^ 63) (hx : BytesRel bs xs) (hrbp : x'.reg .rbp = x.reg .rbp)
    (hin : ∀ i (h : i < xs.length), x'.mem (fpAddr x d + BitVec.ofNat 64 i) = xs[i])
    (hout : ∀ a, xs.length ≤ (a - fpAddr x d).toNat → x'.mem a = x.mem a) :
    Rel st' x' ∧ EscOnly st st.mem st'.mem ∧ st'.escaped = st.escaped ∧
      st'.exposed = st.exposed ∧ st'.exception = st.exception ∧ st'.zeroSized = st.zeroSized := by
  unfold OpSem.State.writeFrame at hw
  cases hm : st.writeEscaped d bs with
  | error e => simp [hm, bind, Except.bind] at hw
  | ok m' =>
  simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  have hesc := writeEscaped_spec hm
  have hlen := hx.length
  have hfp : ∀ o, fpAddr x' o = fpAddr x o := fun o => by simp [fpAddr, hrbp]
  refine ⟨⟨fun o ho1 ho2 b hb => ?_, fun e he a ha => ?_, fun p hp' => ?_⟩, hesc.escOnly, rfl, rfl, rfl, rfl⟩
  · rw [hfp]
    have hea : ∀ (f : Int → AbstractByte) (m : Memory),
        ({ st with mem := m, frame := f } : OpSem.State).escapedAt o = st.escapedAt o :=
      fun _ _ => rfl
    unfold OpSem.State.byteAt at hb
    rw [hea] at hb
    by_cases hin' : d ≤ o ∧ o < d + bs.length
    · have hk : (o - d).toNat < bs.length := by omega
      have hxo : x'.mem (fpAddr x o) = xs[(o - d).toNat]'(by omega) := by
        have := hin (o - d).toNat (by omega)
        rwa [← fpAddr_add, show d + ((o - d).toNat : Int) = o by omega] at this
      rw [hxo]
      cases hf : st.escapedAt o with
      | none =>
        simp only [hf, OpSem.State.privateIn, hin', decide_true, Option.isNone_none, Bool.and_self,
          ↓reduceIte, pure, Except.pure, Except.ok.injEq] at hb
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
              have := esc_inj hr ⟨ho1, ho2⟩ ⟨by omega, by omega⟩ hf he' hid' ha hj'
              rw [hb'] at hv
              cases hv
              rw [hq1]
              have hqk' : q.2 = (o - d).toNat := by omega
              simp only [hqk']
              exact hx.getElem _ hk _
            · cases hb
        · cases hb
    · have hnot : x'.mem (fpAddr x o) = x.mem (fpAddr x o) :=
        hout _ (by rw [← hlen]; exact fpAddr_sub_ge x o d bs.length ⟨ho1, ho2⟩ hd hdn hin')
      rw [hnot]
      apply hr.frame o ho1 ho2 b
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
            have := esc_inj hr ⟨ho1, ho2⟩ ⟨by omega, by omega⟩ hf he' hid' ha hj'
            omega
          have hdat := (hj _).1 hnh
          rw [ha]
          rw [hae] at hb
          simp only at hb
          simp only
          rw [← hdat]
          exact hb
        · cases hb
  · obtain ⟨a0, ha0, hae, -⟩ := hesc.2 _ _ ha
    rw [hfp, hae]; exact hr.layout e he a0 ha0
  · rw [hfp]; exact hr.zeroSized p hp'

end Ryo.Proofs.Inline
