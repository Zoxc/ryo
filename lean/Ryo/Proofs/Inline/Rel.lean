/-
Ryo.Proofs.Inline.Rel — the R ↔ L2 relation on a frame (reduced.md §C0.7: provenance erased,
`Uninit` refined by any byte), and how frame reads and writes keep it.

- `ByteRel b x`: R's abstract byte `b` and L2's byte `x`: an initialized byte (an integer
  byte, or a pointer fragment with its provenance erased) is the same byte; `Uninit` relates
  to any byte.
- `Rel st x`: `opSem`'s state `st` and the x86 state `x`, with `fp` in `rbp`: every frame byte
  at an offset `o` in `[-2^63, 2^63)` (one offset per address) that `st` reads without failing
  (`byteAt`: private, or its escaped object's allocation byte) relates to the byte at
  `rbp + o`; and each escaped object's allocation is at `rbp + off` (`φ_AOT`, §C0.2).
- `readFrame_rel`, `asNat_rel`: a frame read of `n` bytes at `o` relates to the `n` x86 bytes
  at `rbp + o`, and decodes to their little-endian value.
- `rel_writeFrame`: a write of private bytes at `d`, against x86 memory that changes exactly
  at those addresses, to bytes they relate to, keeps `Rel`, and keeps `opSem`'s memory,
  escapes, exposure and exception.
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

/-- The relation after a private frame write at `d`, against an x86 state whose memory
changed exactly at `rbp + d + i` (`i < bs.length`), to bytes the written ones relate to. -/
theorem rel_writeFrame {st st' : OpSem.State} {x x' : X86.State} {d : Int} {bs : List AbstractByte}
    {xs : List UInt8} (hr : Rel st x) (hw : st.writeFrame d bs = .ok st')
    (hp : ∀ i < bs.length, st.escapedAt (d + i) = none) (hd : -2 ^ 63 ≤ d)
    (hdn : d + bs.length ≤ 2 ^ 63) (hx : BytesRel bs xs) (hrbp : x'.reg .rbp = x.reg .rbp)
    (hin : ∀ i (h : i < xs.length), x'.mem (fpAddr x d + BitVec.ofNat 64 i) = xs[i])
    (hout : ∀ a, xs.length ≤ (a - fpAddr x d).toNat → x'.mem a = x.mem a) :
    Rel st' x' ∧ st'.mem = st.mem ∧ st'.escaped = st.escaped ∧ st'.exposed = st.exposed ∧
      st'.exception = st.exception := by
  unfold OpSem.State.writeFrame at hw
  rw [writeEscaped_private hp] at hw
  simp only [bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  have hlen := hx.length
  have hfp : ∀ o, fpAddr x' o = fpAddr x o := fun o => by simp [fpAddr, hrbp]
  refine ⟨⟨fun o ho1 ho2 b hb => ?_, fun e he a ha => ?_⟩, rfl, rfl, rfl, rfl⟩
  · rw [hfp]
    rw [byteAt_with] at hb
    by_cases hin' : d ≤ o ∧ o < d + bs.length
    · -- Written: private, the new byte.
      have hpo : st.escapedAt o = none := by
        have := hp (o - d).toNat (by omega)
        rwa [show d + ((o - d).toNat : Int) = o by omega] at this
      simp only [hpo, OpSem.State.privateIn, pure, Except.pure, Except.ok.injEq] at hb
      subst hb
      have hk : (o - d).toNat < bs.length := by omega
      simp only [hin', Option.isNone_none]
      rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hk, Option.getD_some]
      have := hin (o - d).toNat (by omega)
      rw [← fpAddr_add, show d + ((o - d).toNat : Int) = o by omega] at this
      rw [this]
      exact hx.getElem _ hk _
    · -- Not written: the old byte, at an address the x86 write didn't touch.
      have hnot : x'.mem (fpAddr x o) = x.mem (fpAddr x o) :=
        hout _ (by rw [← hlen]; exact fpAddr_sub_ge x o d bs.length ⟨ho1, ho2⟩ hd hdn hin')
      rw [hnot]
      apply hr.frame o ho1 ho2 b
      revert hb
      cases hf : st.escapedAt o with
      | none =>
        simp [OpSem.State.privateIn, hin', OpSem.State.byteAt, hf]
      | some e => simp
  · rw [hfp]; exact hr.layout e he a ha

end Ryo.Proofs.Inline
