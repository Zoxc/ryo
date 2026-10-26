/-
Ryo.Proofs.Inline.Mem — the inline sequences with a memory operand `[p + k]` (the pointer in
frame slot `p`, plus `k`) against `opSem`: `load` (`sound_load`) and `store` (`sound_store`).

Besides `Rel` (the frame), they relate L0 memory to x86 memory:

- `MemRel st x`: each live allocation's byte `i` relates to the x86 byte at `addr + i`;
- `FrameApart st x`: no private frame byte is at an x86 address inside a live allocation;
- `MemDisjoint st` (stores only): distinct live allocation bytes have distinct x86 addresses
  (non-overlapping, and none wraps around the address space).

`load` gives `Post` and keeps `MemRel`. `store` changes L0 memory, so `Post`'s frame clauses
don't apply: it gives `PostMem` (both relations after, `st'` differs from `st` only in its
memory, x86 memory changed only inside live allocations).
-/
import Ryo.Proofs.Inline.Basic

set_option linter.constructorNameAsVariable false
set_option linter.deprecated false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm

theorem fp_load {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .load (ty :: ps) = some
      { reads := [rdA "m" 8], writes := [rdA "d" n],
        derefs := [⟨PtrSrc.mem "m", .bytes n, .read, false⟩] } ∧
    footprintOf .store (ty :: ps) = some
      { reads := [rdA "m" 8, rdA "s" n], derefs := [⟨PtrSrc.mem "m", .bytes n, .write, false⟩] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h]
  exact ⟨rfl, rfl⟩

theorem opSem_load {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {d p k : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.load, [ty], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"m", .mem⟩])
    (hsem : opSem op [.slot d, .mem p k] st ch = .ok (c, st')) :
    ∃ bp q bs, st.readFrame p 8 = .ok bp ∧ asPtr bp = .ok q ∧
      st.load (q.wrappingOffset k) n = .ok bs ∧ st.writeFrame d bs = .ok st' ∧ c = .next := by
  oinv hsem, hh, (fp_load (ps := []) (tySize_of_parse hty)).1
  osimp [ho] at hra
  obtain ⟨bp, hr, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty, Env.memPtr] at hk
  obtain ⟨q, hq, bs, hl, rfl⟩ := hk
  exact ⟨bp, q, bs, hr, hq, hl, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

theorem opSem_store {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {s p k : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.store, [ty], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩])
    (hsem : opSem op [.mem p k, .slot s] st ch = .ok (c, st')) :
    ∃ bp q bs mem', st.readFrame p 8 = .ok bp ∧ asPtr bp = .ok q ∧ st.readFrame s n = .ok bs ∧
      st.store st.mem (q.wrappingOffset k) bs = .ok mem' ∧ st' = { st with mem := mem' } ∧
      c = .next := by
  oinv hsem, hh, (fp_load (ps := []) (tySize_of_parse hty)).2
  osimp [ho] at hra
  obtain ⟨bp, hr, bs, hs, rfl⟩ := hra
  osimp [ho, Env.memPtr] at hk
  obtain ⟨q, hq, mem', hm, rfl⟩ := hk
  exact ⟨bp, q, bs, mem', hr, hq, hs, hm, commit_nil hc, rfl⟩

/-! ### L0 memory accesses -/

theorem liftOutcome_ok {α : Type} {x : Except Outcome α} {a : α} :
    liftOutcome x = .ok a ↔ x = .ok a := by
  cases x with
  | ok b => simp [liftOutcome, pure, Except.pure]
  | error e => cases e <;> simp [liftOutcome, throw, throwThe, MonadExceptOf.throw]

theorem resolve_addr (st : OpSem.State) (p : ThinPointer) (len : Nat) :
    (st.resolve p len).addr = p.addr := by
  have he : (st.resolveExposed p len).addr = p.addr := by
    unfold OpSem.State.resolveExposed
    split <;> rfl
  unfold OpSem.State.resolve
  split
  · split
    · rfl
    · exact he
  · exact he

theorem checkPtr_ok {m : Memory} {p : ThinPointer} {len : Nat} {r : Option (AllocId × Nat)}
    (hn : len ≠ 0) (h : m.checkPtr p len = .ok r) :
    ∃ id a, m.get? id = some a ∧ a.live = true ∧ a.addr ≤ p.addr ∧ p.addr + len ≤ a.addr + a.size ∧
      r = some (id, p.addr - a.addr) := by
  unfold Memory.checkPtr at h
  simp only [beq_iff_eq, hn, ↓reduceIte] at h
  rcases hp : p.prov with _ | id <;> simp only [hp] at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  rcases ha : m.get? id with _ | a <;> simp only [ha] at h
  · simp [throwUb, throwThe, MonadExceptOf.throw] at h
  by_cases hl : a.live = true <;>
    by_cases hb : p.addr < a.addr ∨ p.addr + len > a.addr + a.size <;>
    simp_all [throwUb, throwThe, MonadExceptOf.throw, bind, Except.bind, pure, Except.pure]
  exact ⟨id, a, ha, hl, hb.1, hb.2, h.symm⟩

theorem getElem!_of_get? {m : Memory} {id : AllocId} {a : Allocation} (h : m.get? id = some a) :
    m.allocs[id]! = a := by
  simp only [Memory.get?] at h
  simp [getElem!_def, h]

theorem load_ok {st : OpSem.State} {p : ThinPointer} {n : Nat} {bs : List AbstractByte}
    (hn : n ≠ 0) (h : st.load p n = .ok bs) :
    ∃ id a, st.mem.get? id = some a ∧ a.live = true ∧ a.addr ≤ p.addr ∧
      p.addr + n ≤ a.addr + a.size ∧
      bs = (a.data.extract (p.addr - a.addr) (p.addr - a.addr + n)).toList := by
  unfold OpSem.State.load at h
  rw [liftOutcome_ok] at h
  have hra := resolve_addr st p n
  generalize st.resolve p n = p' at h hra
  rw [← hra]
  unfold Memory.load at h
  simp only [Align.isAligned, Align.one, Align.bytes, Nat.pow_zero, Nat.mod_one, beq_self_eq_true, Bool.not_true,
    Bool.false_eq_true, ↓reduceIte, bind, Except.bind] at h
  cases hc : st.mem.checkPtr p' n with
  | error e => simp [hc] at h
  | ok r =>
    obtain ⟨id, a, ha, hl, h1, h2, rfl⟩ := checkPtr_ok hn hc
    simp only [hc, pure, Except.pure, Except.ok.injEq, getElem!_of_get? ha] at h
    exact ⟨id, a, ha, hl, h1, h2, h.symm⟩

/-- The data a store writes: `bs` from `off`. -/
def storeData (data : Array AbstractByte) (off : Nat) (bs : List AbstractByte) :
    Array AbstractByte :=
  (bs.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) data

theorem store_ok {st : OpSem.State} {mem mem' : Memory} {p : ThinPointer} {bs : List AbstractByte}
    (hn : bs.length ≠ 0) (h : st.store mem p bs = .ok mem') :
    ∃ id a, mem.get? id = some a ∧ a.live = true ∧ a.addr ≤ p.addr ∧
      p.addr + bs.length ≤ a.addr + a.size ∧
      mem' = { allocs := mem.allocs.set! id { a with data := storeData a.data (p.addr - a.addr) bs } } := by
  unfold OpSem.State.store at h
  rw [liftOutcome_ok] at h
  have hra := resolve_addr st p bs.length
  generalize st.resolve p bs.length = p' at h hra
  rw [← hra]
  unfold Memory.store at h
  simp only [Align.isAligned, Align.one, Align.bytes, Nat.pow_zero, Nat.mod_one, beq_self_eq_true, Bool.not_true,
    Bool.false_eq_true, ↓reduceIte, bind, Except.bind] at h
  cases hc : mem.checkPtr p' bs.length with
  | error e => simp [hc] at h
  | ok r =>
    obtain ⟨id, a, ha, hl, h1, h2, rfl⟩ := checkPtr_ok hn hc
    simp only [hc, getElem!_of_get? ha] at h
    split at h
    · simp [throwUb, throwThe, MonadExceptOf.throw] at h
    · simp only [pure, Except.pure, Except.ok.injEq] at h
      exact ⟨id, a, ha, hl, h1, h2, h.symm⟩

theorem foldl_set_size (off : Nat) : ∀ (bs : List AbstractByte) (k : Nat) (data : Array AbstractByte),
    ((bs.zipIdx k).foldl (fun d (b, i) => d.set! (off + i) b) data).size = data.size
  | [], _, _ => rfl
  | b :: bs, k, data => by
    simp only [List.zipIdx_cons, List.foldl_cons]
    rw [foldl_set_size off bs (k + 1)]
    simp

theorem foldl_set_get? (off : Nat) : ∀ (bs : List AbstractByte) (k : Nat) (data : Array AbstractByte),
    off + k + bs.length ≤ data.size → ∀ j,
    ((bs.zipIdx k).foldl (fun d (b, i) => d.set! (off + i) b) data)[j]? =
      if off + k ≤ j ∧ j < off + k + bs.length then bs[j - (off + k)]? else data[j]?
  | [], _, _, _, j => by simp; omega
  | b :: bs, k, data, hs, j => by
    simp only [List.zipIdx_cons, List.foldl_cons]
    rw [foldl_set_get? off bs (k + 1) _ (by simp at hs ⊢; omega) j]
    simp only [List.length_cons] at hs ⊢
    split <;> split
    · rw [show j - (off + k) = (j - (off + (k + 1))) + 1 by omega, List.getElem?_cons_succ]
    · omega
    · simp only [Array.set!, Array.getElem?_setIfInBounds]
      have h2 : j = off + k := by omega
      subst h2
      simp [show off + k < data.size by omega]
    · simp only [Array.set!, Array.getElem?_setIfInBounds]
      simp [show off + k ≠ j by omega]

theorem storeData_size (data : Array AbstractByte) (off : Nat) (bs : List AbstractByte) :
    (storeData data off bs).size = data.size := foldl_set_size off bs 0 data

theorem storeData_get? {data : Array AbstractByte} {off : Nat} {bs : List AbstractByte}
    (h : off + bs.length ≤ data.size) (j : Nat) :
    (storeData data off bs)[j]? =
      if off ≤ j ∧ j < off + bs.length then bs[j - off]? else data[j]? :=
  foldl_set_get? off bs 0 data (by simpa using h) j

theorem get?_set {mem : Memory} {id : AllocId} {a a' : Allocation} (ha : mem.get? id = some a)
    (id' : AllocId) :
    ({ allocs := mem.allocs.set! id a' } : Memory).get? id' =
      if id' = id then some a' else mem.get? id' := by
  simp only [Memory.get?] at ha ⊢
  have : id < mem.allocs.size := by
    rcases Array.getElem?_eq_some_iff.1 ha with ⟨h, -⟩; exact h
  simp only [Array.set!, Array.getElem?_setIfInBounds]
  by_cases h : id' = id
  · subst h; simp [this]
  · simp [h, Ne.symm h]

/-! ### Memory relations -/

/-- Each live allocation's bytes relate to the x86 bytes at its address. -/
def MemRel (st : OpSem.State) (x : X86.State) : Prop :=
  ∀ id a, st.mem.get? id = some a → a.live = true → ∀ i (h : i < a.data.size),
    ByteRel a.data[i] (x.mem (BitVec.ofNat 64 (a.addr + i)))

/-- No private frame byte (at an offset in `[-2^63, 2^63)`) is at an x86 address in a live
allocation. -/
def FrameApart (st : OpSem.State) (x : X86.State) : Prop :=
  ∀ id a o, st.mem.get? id = some a → a.live = true → st.escapedAt o = none →
    -2 ^ 63 ≤ o → o < 2 ^ 63 → ¬ ((fpAddr x o - BitVec.ofNat 64 a.addr).toNat < a.size)

/-- The live allocations' bytes have distinct x86 addresses. -/
def MemDisjoint (st : OpSem.State) : Prop :=
  ∀ id1 a1 id2 a2 i j, st.mem.get? id1 = some a1 → st.mem.get? id2 = some a2 →
    a1.live = true → a2.live = true → i < a1.size → j < a2.size →
    BitVec.ofNat 64 (a1.addr + i) = BitVec.ofNat 64 (a2.addr + j) → id1 = id2 ∧ i = j

theorem bv_add_sub_toNat (a b : BitVec 64) : a + BitVec.ofNat 64 (b - a).toNat = b := by
  rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]; bv_decide

theorem ofNat_add_sub (a i : Nat) :
    BitVec.ofNat 64 (a + i) - BitVec.ofNat 64 a = BitVec.ofNat 64 i := by
  rw [BitVec.ofNat_add]
  generalize BitVec.ofNat 64 a = x
  generalize BitVec.ofNat 64 i = y
  bv_decide

theorem nv_mem {ρ : R.Addrs} {o : R.Opnd Nat} {v : Val} :
    R.nativeVal ρ .mem o = some v ↔ ∃ p k, o = .mem p k ∧ v = .mem p.toInt k.toInt := by
  cases o <;> simp [R.nativeVal, eq_comm] <;>
    exact ⟨fun h => ⟨_, _, ⟨rfl, rfl⟩, h⟩, fun ⟨_, _, ⟨h1, h2⟩, h⟩ => h1 ▸ h2 ▸ h⟩

/-- A write to `n` private frame bytes at `d` keeps `MemRel`. -/
theorem memRel_frame {st st' : OpSem.State} {x x' : X86.State} {d : Int} {n : Nat}
    (hm : MemRel st x) (hmem : st'.mem = st.mem) (hap : FrameApart st x)
    (hp : ∀ i < n, st.escapedAt (d + i) = none) (hd : -2 ^ 63 ≤ d) (hdn : d + n ≤ 2 ^ 63)
    (hx : ∀ b, n ≤ (b - fpAddr x d).toNat → x'.mem b = x.mem b) : MemRel st' x' := by
  intro id a hg hl i hi
  rw [hmem] at hg
  rw [hx]
  · exact hm id a hg hl i hi
  · apply Nat.not_lt.1
    intro hj
    generalize hb : BitVec.ofNat 64 (a.addr + i) = b at hj
    have := hap id a (d + ((b - fpAddr x d).toNat : Nat)) hg hl (hp _ hj) (by omega) (by omega)
    rw [fpAddr_add, bv_add_sub_toNat, ← hb, ofNat_add_sub] at this
    apply this
    simp only [BitVec.toNat_ofNat, Allocation.size]
    exact Nat.lt_of_le_of_lt (Nat.mod_le _ _) hi

theorem bytesRel_of_get : ∀ (bs : List AbstractByte) (xs : List UInt8), bs.length = xs.length →
    (∀ i (h1 : i < bs.length) (h2 : i < xs.length), ByteRel bs[i] xs[i]) → BytesRel bs xs
  | [], [], _, _ => trivial
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | b :: bs, y :: xs, hl, hb =>
    ⟨hb 0 (by simp) (by simp), bytesRel_of_get bs xs (by simpa using hl)
      fun i h1 h2 => hb (i + 1) (by simpa using h1) (by simpa using h2)⟩

/-- An allocation's bytes relate to the x86 bytes at their address. -/
theorem bytesRel_alloc {st : OpSem.State} {x : X86.State} (hm : MemRel st x) {id : AllocId}
    {a : Allocation} (hg : st.mem.get? id = some a) (hl : a.live = true) {off n : Nat}
    (h : off + n ≤ a.size) :
    BytesRel (a.data.extract off (off + n)).toList
      (bytesAt x.mem (BitVec.ofNat 64 (a.addr + off)) n) := by
  simp only [Allocation.size] at h
  apply bytesRel_of_get _ _ (by simp [bytesAt_length]; omega)
  intro i h1 h2
  simp only [Array.length_toList, Array.size_extract] at h1
  rw [getElem_bytesAt, ← BitVec.ofNat_add, Nat.add_assoc]
  simp only [Array.getElem_toList, Array.getElem_extract]
  exact hm id a hg hl _ (by omega)

theorem sound_load (w : W) : ∀ (ctx : Ctx) (ρ : R.Addrs) (op : Full.Opcode)
    (ops : List (R.Opnd Nat)) (items : List Item) (br : Option Cond) (vals : Operands)
    (st st' : OpSem.State) (ctl : Control) (ch : OpSem.Choice) (x : Ryo.X86.State),
    shapeOk op (.load w) = true → sequence (.load w) ops = some (items, br) →
    nativeVals ρ op ops = some vals → opSem op vals st ch = .ok (ctl, st') → Rel st x →
    Private op vals st → MemRel st x → FrameApart st x →
    ∃ x', execItems ctx items x = .ok x' ∧ Post op ops vals items br st st' ctl x x' ∧
      MemRel st' x' := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hp hm hap
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨pp, k, rfl, rfl⟩ := nv_mem.1 h1
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨hits, rfl⟩ := hseq
  have hty := (tyName_parse w).1
  obtain ⟨bp, q, bs, hrp, hq, hl, hwr, rfl⟩ := opSem_load hh hty ho hsem
  have hwr' : wranges op [.slot s0.toInt, .mem pp.toInt k.toInt] = [(s0.toInt, wbytes w)] :=
    wranges_eq hh (fp_load (ps := []) (tySize_of_parse hty)).1 (by simp [opndVal, ho])
  have hbp := toInt_bounds pp
  have hb0 := toInt_bounds s0
  have hqa := asPtr_rel (readFrame_rel hr hrp (by omega) (by omega)) hq
  have hn0 : wbytes w ≠ 0 := by cases w <;> decide
  obtain ⟨id, a, hg, hlv, ha1, ha2, rfl⟩ := load_ok hn0 hl
  have hbs : BytesRel (a.data.extract ((q.wrappingOffset k.toInt).addr - a.addr)
      ((q.wrappingOffset k.toInt).addr - a.addr + wbytes w)).toList
      (bytesAt x.mem (BitVec.ofNat 64 (leDecode (bytesAt x.mem (fpAddr x pp.toInt) 8)) +
        k.signExtend 64) (wbytes w)) := by
    have := bytesRel_alloc hm hg hlv (off := (q.wrappingOffset k.toInt).addr - a.addr)
      (n := wbytes w) (by omega)
    rwa [Nat.add_sub_cancel' ha1, wrappingOffset_bv, hqa, ← sext_eq] at this
  have hlen : (a.data.extract ((q.wrappingOffset k.toInt).addr - a.addr)
      ((q.wrappingOffset k.toInt).addr - a.addr + wbytes w)).toList.length = wbytes w := by
    simp only [Array.length_toList, Array.size_extract, Allocation.size] at ha2 ⊢; omega
  have key : ∃ x', execItems ctx items x = .ok x' ∧
      Post op [.slot s0, .mem pp k] [.slot s0.toInt, .mem pp.toInt k.toInt] items none st st'
        .next x x' := by
    subst hits
    cases w <;> xrun <;>
      refine post_mem hr hwr (by rw [hlen]; rfl) (by decide) (by rw [hwr']; rfl)
        (bytesRel_val hbs (bytesAt_length ..) ?_) ?_ ?_ ?_ ?_ ?_ rfl
    all_goals xobs
  obtain ⟨x', hx, hpost⟩ := key
  have hmem : st'.mem = st.mem :=
    writeFrame_mem_private hwr (by rw [hlen]; exact private_range hp hwr')
  refine ⟨x', hx, hpost, memRel_frame (d := s0.toInt) (n := wbytes w) hm hmem hap
    (private_range hp hwr') (by omega) (by cases w <;> simp <;> omega) fun b hb => ?_⟩
  exact hpost.memOut b (by simp [hwr']; exact hb)

/-! ### Stores through a pointer -/

theorem addr_hit (base off : Nat) (b : BitVec 64) :
    b = BitVec.ofNat 64 (base + (off + (b - BitVec.ofNat 64 (base + off)).toNat)) := by
  rw [← Nat.add_assoc, BitVec.ofNat_add (base + off), BitVec.ofNat_toNat, BitVec.setWidth_eq]
  generalize BitVec.ofNat 64 (base + off) = y
  bv_decide

theorem off_toNat_le (base m : Nat) :
    (BitVec.ofNat 64 (base + m) - BitVec.ofNat 64 base).toNat ≤ m := by
  rw [ofNat_add_sub, BitVec.toNat_ofNat]; exact Nat.mod_le _ _

/-- What a store of `bs` at offset `off` of live allocation `id` (at x86 address
`a.addr + off`, `n` bytes of `V`) keeps: `MemRel`, `Rel`, and x86 memory outside live
allocations. -/
theorem post_store {st : OpSem.State} {mem' : Memory} {x x' : X86.State} {id : AllocId}
    {a : Allocation} {off V : Nat} {bs : List AbstractByte}
    (hr : Rel st x) (hm : MemRel st x) (hap : FrameApart st x) (hdis : MemDisjoint st)
    (hg : st.mem.get? id = some a) (hlv : a.live = true) (hb : off + bs.length ≤ a.size)
    (hn : bs.length ≤ 2 ^ 64)
    (hmem' : mem' = { allocs := st.mem.allocs.set! id { a with data := storeData a.data off bs } })
    (hx : BytesRel bs (leEncode bs.length V)) (hrbp : x'.reg .rbp = x.reg .rbp)
    (hmem : x'.mem = x.mem.write (BitVec.ofNat 64 (a.addr + off)) bs.length V) :
    MemRel { st with mem := mem' } x' ∧ Rel { st with mem := mem' } x' ∧
      ∀ b, (∀ id a, st.mem.get? id = some a → a.live = true →
        ¬ (b - BitVec.ofNat 64 a.addr).toNat < a.size) → x'.mem b = x.mem b := by
  simp only [Allocation.size] at hb
  have hlen := hx.length
  rw [leEncode_length] at hlen
  -- The allocations after the store.
  have hg' : ∀ id' a', mem'.get? id' = some a' → ∃ a0, st.mem.get? id' = some a0 ∧
      a'.addr = a0.addr ∧ a'.live = a0.live ∧
      (id' = id → a' = { a with data := storeData a.data off bs }) ∧ (id' ≠ id → a' = a0) := by
    intro id' a' h
    rw [hmem', get?_set hg] at h
    by_cases hi : id' = id
    · subst hi
      simp only [↓reduceIte, Option.some.injEq] at h
      subst h
      exact ⟨a, hg, rfl, rfl, fun _ => rfl, fun h => absurd rfl h⟩
    · simp only [hi, ↓reduceIte] at h
      exact ⟨a', h, rfl, rfl, fun h' => absurd h' hi, fun _ => rfl⟩
  have hout : ∀ b, (∀ id a, st.mem.get? id = some a → a.live = true →
      ¬ (b - BitVec.ofNat 64 a.addr).toNat < a.size) → x'.mem b = x.mem b := by
    intro b hb'
    rw [hmem]
    apply X86.Mem.write_other
    apply Nat.not_lt.1
    intro hc
    apply hb' id a hg hlv
    rw [addr_hit a.addr off b]
    exact Nat.lt_of_le_of_lt (off_toNat_le _ _) (by simp only [Allocation.size]; omega)
  have hmr : MemRel { st with mem := mem' } x' := by
    intro id' a' h hl' i hi
    obtain ⟨a0, h0, hadr, hlive, hsame, hdiff⟩ := hg' id' a' h
    rw [hlive] at hl'
    rw [hmem]
    by_cases he : id' = id
    · subst he
      rw [hg] at h0; cases h0
      obtain rfl := hsame rfl
      simp only [storeData_size] at hi ⊢
      have hd := storeData_get? hb i
      rw [Array.getElem?_eq_getElem (by rw [storeData_size]; exact hi)] at hd
      by_cases hin : off ≤ i ∧ i < off + bs.length
      · rw [if_pos hin, List.getElem?_eq_getElem (by omega), Option.some.injEq] at hd
        rw [hd, show a.addr + i = a.addr + off + (i - off) by omega,
          BitVec.ofNat_add (a.addr + off) (i - off), write_at _ _ _ _ _ hn (by omega)]
        exact hx.getElem _ _ _
      · rw [if_neg hin, Array.getElem?_eq_getElem hi, Option.some.injEq] at hd
        rw [hd, X86.Mem.write_other]
        · exact hm _ _ hg hlv i hi
        · apply Nat.not_lt.1
          intro hc
          have hhit := addr_hit a.addr off (BitVec.ofNat 64 (a.addr + i))
          generalize (BitVec.ofNat 64 (a.addr + i) - BitVec.ofNat 64 (a.addr + off)).toNat = c
            at hc hhit
          have hoc : off + c < a.size := by simp only [Allocation.size]; omega
          have hij : i = off + c := (hdis id' a id' a i (off + c) hg hg hlv hlv hi hoc hhit).2
          exact hin ⟨by omega, by omega⟩
    · obtain rfl := hdiff he
      rw [X86.Mem.write_other]
      · exact hm id' a' h0 hl' i hi
      · apply Nat.not_lt.1
        intro hc
        have hhit := addr_hit a.addr off (BitVec.ofNat 64 (a'.addr + i))
        generalize (BitVec.ofNat 64 (a'.addr + i) - BitVec.ofNat 64 (a.addr + off)).toNat = c
          at hc hhit
        have hoc : off + c < a.size := by simp only [Allocation.size]; omega
        exact he (hdis id' a' id a i (off + c) h0 hg hl' hlv hi hoc hhit).1
  have hfp : ∀ o, fpAddr x' o = fpAddr x o := fun o => by simp [fpAddr, hrbp]
  refine ⟨hmr, ⟨fun o ho1 ho2 b hb => ?_, fun e he a' ha' => ?_,
    fun p hp => by rw [hfp]; exact hr.zeroSized p hp⟩, hout⟩
  · rw [hfp]
    have hesc : ({ st with mem := mem' } : OpSem.State).escapedAt o = st.escapedAt o := rfl
    unfold OpSem.State.byteAt at hb
    rw [hesc] at hb
    cases hE : st.escapedAt o with
    | none =>
      simp only [hE, pure, Except.pure, Except.ok.injEq] at hb
      rw [hout _ fun id a hg hl => hap id a o hg hl hE ho1 ho2]
      exact hr.frame o ho1 ho2 b (by simp [OpSem.State.byteAt, hE, hb, pure, Except.pure])
    | some e =>
      simp only [hE] at hb
      cases hg2 : mem'.get? e.id with
      | none => simp [hg2, illFormed, throw, throwThe, MonadExceptOf.throw] at hb
      | some a2 =>
        simp only [hg2] at hb
        by_cases hl2 : a2.live = true
        · simp only [hl2, Bool.not_true, Bool.false_eq_true, ↓reduceIte] at hb
          cases hd : a2.data[(o - e.off).toNat]? with
          | none => simp [hd, illFormed, throw, throwThe, MonadExceptOf.throw] at hb
          | some b' =>
            simp only [hd, pure, Except.pure, Except.ok.injEq] at hb
            subst hb
            obtain ⟨hj, rfl⟩ := Array.getElem?_eq_some_iff.1 hd
            have := hmr e.id a2 hg2 hl2 _ hj
            obtain ⟨a0, h0, hadr, -⟩ := hg' e.id a2 hg2
            have hin := List.find?_some hE
            simp only [decide_eq_true_eq] at hin
            have hl := hr.layout e (List.mem_of_find?_eq_some hE) a0 h0
            have hfo : fpAddr x o = BitVec.ofNat 64 (a2.addr + (o - e.off).toNat) := by
              rw [BitVec.ofNat_add, hadr, hl, ← fpAddr_add]
              congr 1; omega
            rw [hfo]; exact this
        · simp [hl2, illFormed, throw, throwThe, MonadExceptOf.throw] at hb
  · rw [hfp]
    obtain ⟨a0, h0, hadr, -⟩ := hg' e.id a' ha'
    rw [hadr]
    exact hr.layout e he a0 h0

/-- What running a `store` sequence gives: `Post` with memory in place of the frame. `st'`
differs from `st` at most in its memory; both relations hold after; registers as in `Post`;
x86 memory changed only inside `st`'s live allocations. -/
structure PostMem (items : List Item) (st st' : OpSem.State) (ctl : Control) (x x' : X86.State) :
    Prop where
  rel : Rel st' x'
  memRel : MemRel st' x'
  same : st'.frame = st.frame ∧ st'.escaped = st.escaped ∧ st'.exposed = st.exposed ∧
    st'.exception = st.exception
  regs : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x'.regs i = x.regs i
  xmm : x'.xmm = x.xmm
  rip : x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum
  memOut : ∀ b, (∀ id a, st.mem.get? id = some a → a.live = true →
    ¬ (b - BitVec.ofNat 64 a.addr).toNat < a.size) → x'.mem b = x.mem b
  ctl : ctl = .next

/-- The end of a `store` sequence: `n` bytes of `V` stored at `E`, the address of byte `off`
of live allocation `id`, from a state `y` that only changed `rax`, `rcx`, the flags and
`rip`. -/
theorem postMem_store {items : List Item} {st : OpSem.State} {mem' : Memory}
    {x y : X86.State} {id : AllocId} {a : Allocation} {off n V : Nat} {bs : List AbstractByte}
    {E a1 : BitVec 64}
    (hr : Rel st x) (hm : MemRel st x) (hap : FrameApart st x) (hdis : MemDisjoint st)
    (hg : st.mem.get? id = some a) (hlv : a.live = true) (hb : off + n ≤ a.size)
    (hmem' : mem' = { allocs := st.mem.allocs.set! id { a with data := storeData a.data off bs } })
    (hlen : bs.length = n) (hn : n ≤ 16) (hx : BytesRel bs (leEncode n V))
    (hE : E = BitVec.ofNat 64 (a.addr + off))
    (hyb : y.reg .rbp = x.reg .rbp) (hym : y.mem = x.mem)
    (hyr : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → y.regs i = x.regs i) (hyx : y.xmm = x.xmm)
    (hrip : a1 = x.rip + BitVec.ofNat 64 (items.map Item.size).sum) :
    PostMem items st { st with mem := mem' } .next x ((y.jump a1).setMem E n V) := by
  subst hlen hE
  obtain ⟨h1, h2, h3⟩ := post_store (x' := (y.jump a1).setMem (BitVec.ofNat 64 (a.addr + off)) bs.length V) hr hm hap hdis hg hlv
    hb (by omega) hmem' hx (by simpa using hyb) (by simp [hym])
  exact ⟨h2, h1, ⟨rfl, rfl, rfl, rfl⟩, fun i h0 h1 => by simpa using hyr i h0 h1,
    by simpa using hyx, by simpa using hrip, h3, rfl⟩

theorem sound_store (w : W) : ∀ (ctx : Ctx) (ρ : R.Addrs) (op : Full.Opcode)
    (ops : List (R.Opnd Nat)) (items : List Item) (br : Option Cond) (vals : Operands)
    (st st' : OpSem.State) (ctl : Control) (ch : OpSem.Choice) (x : Ryo.X86.State),
    shapeOk op (.store w) = true → sequence (.store w) ops = some (items, br) →
    nativeVals ρ op ops = some vals → opSem op vals st ch = .ok (ctl, st') → Rel st x →
    MemRel st x → FrameApart st x → MemDisjoint st →
    br = none ∧ ∃ x', execItems ctx items x = .ok x' ∧ PostMem items st st' ctl x x' := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hm hap hdis
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨pp, k, rfl, rfl⟩ := nv_mem.1 h0
  obtain ⟨s1, rfl, rfl⟩ := nv_slot.1 h1
  simp only [sequence, Option.pure_def, Option.bind_eq_bind, Option.bind_some,
    Option.some.injEq, Prod.mk.injEq, List.getElem?_cons_zero, List.getElem?_cons_succ] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  refine ⟨rfl, ?_⟩
  have hty := (tyName_parse w).1
  obtain ⟨bp, q, bs, mem', hrp, hq, hrs, hst, rfl, rfl⟩ := opSem_store hh hty ho hsem
  have hbp := toInt_bounds pp
  have hb1 := toInt_bounds s1
  have hqa := asPtr_rel (readFrame_rel hr hrp (by omega) (by omega)) hq
  have hn : wbytes w ≤ 8 := by cases w <;> decide
  have hrel := readFrame_rel hr hrs (by omega) (by omega)
  have hlen := readFrame_length hrs
  have hn0 : bs.length ≠ 0 := by rw [hlen]; cases w <;> decide
  obtain ⟨id, a, hg, hlv, ha1, ha2, hmem'⟩ := store_ok hn0 hst
  have hA : BitVec.ofNat 64 (leDecode (bytesAt x.mem (fpAddr x pp.toInt) 8)) + k.signExtend 64 =
      BitVec.ofNat 64 a.addr + BitVec.ofNat 64 ((q.wrappingOffset k.toInt).addr - a.addr) := by
    rw [← BitVec.ofNat_add, Nat.add_sub_cancel' ha1, wrappingOffset_bv, hqa, ← sext_eq]
  cases w <;> xrun <;>
    refine postMem_store hr hm hap hdis hg hlv (by rw [← wbytes_eq, ← hlen]; omega) hmem' hlen (by decide)
      (bytesRel_val hrel (bytesAt_length ..) ?_) ?_ ?_ ?_ ?_ ?_ ?_
  all_goals xobs
  all_goals exact hA

end Ryo.Proofs.Inline
