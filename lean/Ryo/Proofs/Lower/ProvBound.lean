/-
Ryo.Proofs.Lower.ProvBound — an L0 memory invariant (M5a): every byte's provenance is an
existing allocation id (`< m.allocs.size`). It gives `lift_storageLive`'s freshness hypothesis
(`Hidden s.mem (· = s.mem.allocs.size)`: no byte carries the id the next allocation gets) and is
kept by allocation, deallocation, and stores of bounded bytes (provenance-free ones, or bytes
loaded from a bounded memory), hence by the L0 statements of the `LowerStmt` integer rules.
-/
import Ryo.Proofs.Lower.FnRel

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Check.Lower

/-- Every byte of `bs` with provenance has an id below `n`. -/
def BytesBounded (n : Nat) (bs : List AbstractByte) : Prop :=
  ∀ b ∈ bs, ∀ f, b.provFrag = some f → f.prov < n

/-- Every byte of every allocation of `m` has provenance below `m.allocs.size`. -/
def ProvBounded (m : Memory) : Prop :=
  ∀ a x, m.get? a = some x → ∀ i (h : i < x.data.size) f,
    x.data[i].provFrag = some f → f.prov < m.allocs.size

theorem ProvBounded.hidden {m : Memory} (h : ProvBounded m) : Hidden m (· = m.allocs.size) := by
  intro a x hx _ i hi f hf heq
  exact Nat.ne_of_lt (h a x hx i hi f hf) heq

theorem BytesBounded.mono {n n' : Nat} {bs : List AbstractByte} (h : BytesBounded n bs)
    (hle : n ≤ n') : BytesBounded n' bs :=
  fun b hb f hf => Nat.lt_of_lt_of_le (h b hb f hf) hle

theorem bytesBounded_noprov {n : Nat} {bs : List AbstractByte}
    (h : ∀ b ∈ bs, b.provFrag = none) : BytesBounded n bs := by
  intro b hb f hf
  rw [h b hb] at hf
  cases hf

/-- A pushed allocation without provenance keeps the bound. -/
theorem ProvBounded.push {m : Memory} (h : ProvBounded m) {a : Allocation}
    (ha : ∀ i (hi : i < a.data.size), a.data[i].provFrag = none) :
    ProvBounded { allocs := m.allocs.push a } := by
  intro b x hx i hi f hf
  simp only [Memory.get?, Array.getElem?_push] at hx
  simp only [Array.size_push]
  split at hx
  · obtain rfl := Option.some.inj hx
    rw [ha i hi] at hf
    cases hf
  · exact Nat.lt_succ_of_lt (h b x hx i hi f hf)

/-- L0's `allocate` of a stack allocation keeps the bound. -/
theorem ProvBounded.allocate {o : Spec.Oracle} {s s2 : Spec.State} {m m' : Memory} {size : Size}
    {al : Align} {p : ThinPointer} (h : ProvBounded m)
    (hal : runOn (m.allocate .stack size al : SemM (ThinPointer × Memory)) o s = (.ok (p, m'), s2)) :
    ProvBounded m' := by
  obtain ⟨a, hda, -, -, -, -, -, rfl, -, -⟩ := runOn_allocate_ok hal
  refine h.push fun i hi => ?_
  have e : a.data[i] = .uninit := by simp [hda]
  rw [e]
  rfl

theorem ProvBounded.dealloc {m m' : Memory} {p : ThinPointer} {k : AllocationKind} {n : Nat}
    {al : Align} (h : ProvBounded m) (hd : m.deallocate p k n al = .ok m') : ProvBounded m' := by
  obtain ⟨id, a0, hg, rfl⟩ := dealloc_ok_aux hd
  have hid : id < m.allocs.size := by
    unfold Memory.get? at hg
    exact (Array.getElem?_eq_some_iff.mp hg).1
  intro c x hx i hi f hf
  suffices f.prov < m.allocs.size by simpa [Array.set!] using this
  unfold Memory.get? at hx
  simp only [Array.set!, Array.getElem?_setIfInBounds] at hx
  by_cases hc : id = c
  · subst hc
    simp [hid] at hx
    first
      | (subst hx; exact h id a0 hg i hi f hf)
      | (rw [← hx] at hi hf; exact h id a0 hg i hi f hf)
      | (rw [hx] at hi hf; exact h id a0 hg i hi f hf)
  · rw [if_neg hc] at hx
    exact h c x hx i hi f hf

/-- The written array of a store of bounded bytes keeps the old array's bound. -/
private theorem arr_bounded {n : Nat} {d arr : Array AbstractByte} {bs : List AbstractByte}
    {o : Nat}
    (hold : ∀ i (h : i < d.size) f, d[i].provFrag = some f → f.prov < n)
    (hbs : BytesBounded n bs)
    (hg : ∀ j, arr[j]? = if o + 0 ≤ j ∧ j < o + 0 + bs.length ∧ j < d.size then
      bs[j - o - 0]? else d[j]?) :
    ∀ i (h : i < arr.size) f, arr[i].provFrag = some f → f.prov < n := by
  intro i hi f hf
  have e := hg i
  rw [Array.getElem?_eq_getElem hi] at e
  split at e
  · rename_i c
    have hk : i - o - 0 < bs.length := by omega
    rw [List.getElem?_eq_getElem hk] at e
    rw [Option.some.inj e] at hf
    exact hbs _ (List.getElem_mem hk) f hf
  · obtain ⟨hi', he⟩ := Array.getElem?_eq_some_iff.mp e.symm
    rw [← he] at hf
    exact hold i hi' f hf

/-- A store of bytes bounded by the memory's size keeps the bound. -/
theorem ProvBounded.store {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (h : ProvBounded m) (hs : m.store p bs al = .ok m') (hbs : BytesBounded m.allocs.size bs) :
    ProvBounded m' := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hs with
    ⟨_, _, rfl⟩ | ⟨k, hid, _, _, _, _, _, _, _, rfl⟩
  · exact h
  · intro a x hx i hi f hf
    suffices f.prov < m.allocs.size by simpa using this
    by_cases hak : a = k
    · subst hak
      simp only [Memory.get?, Array.getElem?_set_self, Option.some.injEq] at hx
      subst hx
      exact arr_bounded (h a _ (Array.getElem?_eq_getElem hid)) hbs
        (Ryo.Spec.Theorems.foldl_set_getElem bs 0 (p.addr - m.allocs[a].addr)
          m.allocs[a].data) i hi f hf
    · simp only [Memory.get?] at hx
      rw [Array.getElem?_set_ne hid (Ne.symm hak)] at hx
      exact h a x hx i hi f hf

theorem ProvBounded.store_noprov {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte}
    {al : Align} (h : ProvBounded m) (hs : m.store p bs al = .ok m')
    (hbs : ∀ b ∈ bs, b.provFrag = none) : ProvBounded m' :=
  h.store hs (bytesBounded_noprov hbs)

/-- Bytes loaded from a bounded memory are bounded (so storing them back keeps the bound:
pointer copies). -/
theorem ProvBounded.load {m : Memory} {p : ThinPointer} {n : Nat} {al : Align}
    {bs : List AbstractByte} (h : ProvBounded m) (hl : m.load p n al = .ok bs) :
    BytesBounded m.allocs.size bs := by
  by_cases hn : n = 0
  · subst hn
    rw [load_zero_inv hl]
    intro b hb
    cases hb
  · obtain ⟨id, hid, -, -, -, -, rfl⟩ := load_eq_ok_pos hn hl
    intro b hb f hf
    rw [Array.mem_toList_iff] at hb
    obtain ⟨j, hj, rfl⟩ := Array.mem_iff_getElem.mp hb
    rw [Array.getElem_extract] at hf
    exact h id _ (Array.getElem?_eq_getElem hid) _ _ f hf

/-- The shape `binop_mem`, `binImm_mem` and `use_mem` conclude with keeps the bound. -/
theorem ProvBounded.of_mem {s s' : Spec.State} {P : ThinPointer → Prop} (h : ProvBounded s.mem)
    (hex : ∃ pd, P pd ∧ s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none) :
    ProvBounded s'.mem := by
  obtain ⟨_, _, _, bs, hst, hnp⟩ := hex
  exact h.store_noprov hst hnp

/-! ### The integer rules' L0 statements -/

theorem provBounded_binop {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a b : Local} {op : BinOp} {m : String}
    (hm : binMethod op = some m) {t : IntType} {valid : ValidRange}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    (htb : f.body.locals[b]? = some (.int t valid)) (hpb : ProvBounded s.mem)
    (h : runOn (Sem.evalStatement (.assign ⟨d, []⟩ (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))))
      o s = (.ok (), s')) :
    ProvBounded s'.mem :=
  hpb.of_mem (binop_mem hs hm htd hta htb h)

theorem provBounded_binImm {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {op : BinOp} {m : String}
    (hm : binMethod op = some m) {t : IntType} {valid vc : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    (hpb : ProvBounded s.mem)
    (h : runOn (Sem.evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int t vc))))) o s = (.ok (), s')) :
    ProvBounded s'.mem :=
  hpb.of_mem (binImm_mem hs hm htd hta h)

theorem provBounded_use {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {oa : Operand} {t : IntType}
    {valid : ValidRange} (htd : f.body.locals[d]? = some (.int t valid))
    (hev0 : ∀ r s1, runOn (Sem.evalOperand oa) o s = (.ok r, s1) → s1 = s) (hpb : ProvBounded s.mem)
    (h : runOn (Sem.evalStatement (.assign ⟨d, []⟩ (.use oa))) o s = (.ok (), s')) :
    ProvBounded s'.mem :=
  hpb.of_mem (use_mem hs htd hev0 h)

end Ryo.Proofs.Lower
