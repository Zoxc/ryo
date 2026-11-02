/-
Ryo.Proofs.MemPost — `MemRel` after a frame write that may touch escaped bytes (the inline
steps' `inline_memSep_of`).

`memRel_of_post`: `opSem`'s write changed only escaped objects' allocation data (`EscOnly`, the
escaped objects the same), the x86 write only the written frame ranges' addresses (`memOut`, as
the inline theorems' `Post` gives), and the new frame bytes relate (`Rel st' x'`). Then every
live allocation still relates:
- one that is no escaped object's: unchanged in R, and its bytes aren't at a written address
  (`FrameOwn` over a window holding the written ranges: a frame address in a live allocation
  is a byte of an escaped object's own allocation), so unchanged in x86 too;
- an escaped object's: its byte `i` is the frame byte at `e.off + i` (`EscWF`: the allocation
  holds `e.size` bytes, and with disjoint ranges `escapedAt` finds `e` there), which `Rel`
  relates to the byte at its address (`Rel.layout`).

`opSem_frame_or`: `opSem` changes a frame byte only in its written ranges (`wranges`).
-/
import Ryo.Proofs.ScopeMem

namespace Ryo.Proofs.MemPost

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem

/-- With disjoint ranges, `escapedAt` finds the escaped object containing the offset. -/
theorem escapedAt_of_mem {st : OpSem.State} (hwf : EscWF st) {e : EscapedObj}
    (he : e ∈ st.escaped) {o : Int} (h1 : e.off ≤ o) (h2 : o < e.off + e.size) :
    st.escapedAt o = some e := by
  cases hf : st.escapedAt o with
  | none =>
    unfold OpSem.State.escapedAt at hf
    have := List.find?_eq_none.1 hf e he
    simp only [decide_eq_true_eq, not_and, Int.not_lt] at this
    have := this h1
    omega
  | some e' =>
    obtain ⟨he', h1', h2'⟩ := escapedAt_some hf
    by_cases hne : e' = e
    · rw [hne]
    · rcases hwf.disj e' he' e he hne with h | h <;> omega

/-- `MemRel` after a frame write (see the module comment). `ws` are the written ranges (the
instruction's `wranges`), within the window `[lo, hi)` of `FrameOwn`; the escaped objects lie in
`[-2^63, 2^63)`, where `Rel.frame` relates bytes. -/
theorem memRel_of_post {st st' : OpSem.State} {x x' : X86.State} {lo hi : Int}
    {ws : List (Int × Nat)} (hm : MemRel st x) (hwf : EscWF st') (hrel : Rel st' x')
    (hesc : st'.escaped = st.escaped) (hmem : EscOnly st st.mem st'.mem)
    (hown : FrameOwn lo hi st x) (hws : ∀ r ∈ ws, lo ≤ r.1 ∧ r.1 + r.2 ≤ hi)
    (hout : ∀ q, (∀ r ∈ ws, r.2 ≤ (q - fpAddr x r.1).toNat) → x'.mem q = x.mem q)
    (hbd : ∀ e ∈ st'.escaped, -2 ^ 63 ≤ e.off ∧ e.off + e.size ≤ 2 ^ 63) :
    MemRel st' x' := by
  intro id a' ha' hlive i hi
  obtain ⟨a, ha, hae, hsz, hkeep⟩ := hmem.2 id a' ha'
  have hlive0 : a.live = true := by rw [hae] at hlive; exact hlive
  have haddr : a'.addr = a.addr := by rw [hae]
  by_cases hid : ∃ e ∈ st.escaped, e.id = id
  · -- An escaped object's allocation: its byte is the frame byte at `e.off + i`.
    obtain ⟨e, he, rfl⟩ := hid
    have he' : e ∈ st'.escaped := by rw [hesc]; exact he
    have hsize : a'.size = e.size := hwf.size e he' a' ha'
    have hie : i < e.size := by rw [← hsize]; exact hi
    have hb := hbd e he'
    have hat : st'.escapedAt (e.off + i) = some e :=
      escapedAt_of_mem hwf he' (by omega) (by omega)
    have hk : (e.off + (i : Int) - e.off).toNat = i := by omega
    have hbyte : st'.byteAt (e.off + i) = .ok a'.data[i] := by
      unfold OpSem.State.byteAt
      rw [hat]
      simp only [ha', hlive, Bool.not_true, Bool.false_eq_true, ↓reduceIte, hk,
        Array.getElem?_eq_getElem hi, pure, Except.pure]
    have hr := hrel.frame (e.off + i) (by omega) (by omega) _ hbyte
    have hlay := hrel.layout e he' a' ha'
    have hq : fpAddr x' (e.off + i) = BitVec.ofNat 64 (a'.addr + i) := by
      rw [fpAddr_add, ← hlay, BitVec.ofNat_add]
    rw [hq] at hr
    exact hr
  · -- No escaped object's: unchanged in R, and not at a written address.
    have hne : ∀ e ∈ st.escaped, e.id ≠ id := fun e he h => hid ⟨e, he, h⟩
    have hsame : a' = a := hkeep hne
    subst hsame
    have h0 := hm id a' ha hlive i hi
    rw [hout]
    · exact h0
    intro r hr
    apply Nat.le_of_not_lt
    intro hlt
    obtain ⟨hlo, hhi⟩ := hws r hr
    -- The written frame byte `r.1 + k` is at the allocation's byte `i`.
    have hfa : fpAddr x (r.1 + ((BitVec.ofNat 64 (a'.addr + i) - fpAddr x r.1).toNat : Nat)) =
        BitVec.ofNat 64 (a'.addr + i) := by
      rw [fpAddr_add, BitVec.ofNat_toNat, BitVec.setWidth_eq, BitVec.add_comm (fpAddr x r.1),
        BitVec.sub_add_cancel]
    have hin : (fpAddr x (r.1 + ((BitVec.ofNat 64 (a'.addr + i) - fpAddr x r.1).toNat : Nat)) -
        BitVec.ofNat 64 a'.addr).toNat < a'.size := by
      rw [hfa]
      have e1 : BitVec.ofNat 64 (a'.addr + i) - BitVec.ofNat 64 a'.addr = BitVec.ofNat 64 i := by
        rw [BitVec.ofNat_add, BitVec.add_comm (BitVec.ofNat 64 a'.addr), BitVec.add_sub_cancel]
      rw [e1, BitVec.toNat_ofNat]
      exact Nat.lt_of_le_of_lt (Nat.mod_le _ _) hi
    obtain ⟨e, he, -, -, hid'⟩ := hown id a' _ ha hlive (by omega) (by omega) hin
    exact hne e he hid'

/-- `opSem` changes a frame byte only inside its written ranges (`opSem_frame_writes`; a
successful `opSem` has a footprint). -/
theorem opSem_frame_or {op : Full.Opcode} {ops : Operands} {st st' : OpSem.State}
    {ch : OpSem.Choice} {c : Control} (h : opSem op ops st ch = .ok (c, st')) (o : Int) :
    st'.frame o = st.frame o ∨ ∃ r ∈ wranges op ops, inRange o r = true := by
  have hfp : ∃ fp, footprint op = some fp := by
    unfold opSem at h
    cases hp : prepare op ops with
    | error e => simp [hp, bind, Except.bind] at h
    | ok y =>
      obtain ⟨hi, fp, val⟩ := y
      exact ⟨fp, (prepare_ok hp).1⟩
  obtain ⟨fp, hfp⟩ := hfp
  by_cases hw : ∃ r ∈ wranges op ops, inRange o r = true
  · exact .inr hw
  · refine .inl (opSem_frame_writes hfp h o fun r hr => ?_)
    have hr' : r ∈ wranges op ops := by
      unfold wranges
      split
      · rename_i fp' hfp'
        rw [hfp] at hfp'
        cases hfp'
        exact hr
      · rename_i hn
        rw [hfp] at hn
        cases hn
    cases hb : inRange o r
    · rfl
    · exact absurd ⟨r, hr', hb⟩ hw

end Ryo.Proofs.MemPost
