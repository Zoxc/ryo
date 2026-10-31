import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.NoArgCursor

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

/-! ### What the counter check needs, from `Hyps` and the decoder -/

/-- The facts the counter check and its trip need to keep the frame relation (the trip may
write runtime-owned bytes and the stack below `rsp`, `TripContract`): the loop counter is
runtime-owned; the record's OSR slot is not on the stack; no byte of the frame window is
runtime-owned; no live allocation is runtime-owned or on the stack below the frame; the relocated fields lie within the code; and at
a loop head (a branch target) the decoder's cache is empty and the instruction is not a leading
`arg` (the trip clobbers the caller-saved registers). All from `Hyps` and the decoder:
`ctr_apart`. -/
structure CounterApart (S : Setup) : Prop where
  ctrOwned : ∀ j < 8, S.Owned (S.ctx.addrOf .recordLoopCtr + BitVec.ofNat 64 j)
  slotOff : ∀ j < 8,
    ¬ InStack S.lo S.x0.rsp (S.ctx.addrOf .record + BitVec.ofNat 64 16 + BitVec.ofNat 64 j)
  window : ∀ s x, FrameInv S s x → ∀ o : Int, -(S.F : Int) ≤ o → o < S.K → ¬ S.Owned (fpAddr x o)
  allocs : ∀ s x, FrameInv S s x → ∀ a, Call.InAlloc s.world a →
    ¬ S.Owned a ∧ ¬ InStack S.lo x.rsp a
  relocs : ∀ r ∈ S.rs.toList, r.pos + 4 ≤ S.body.code.size
  heads : ∀ k (hk : k < S.r.protos.size), S.r.protos[k].counter.isSome = true →
    S.used k = { pe := S.c.mode.pe } ∧ ¬ LeadArg S k

section Heads

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

theorem ctr_ite_ok {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α}
    (h : (if p then x else y).run c = .ok (a, c')) :
    (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
  by_cases hp : p
  · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
  · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩

theorem ctr_forIn_mem {α β : Type} (I : β → Prop) :
    ∀ (l : List α) (f : α → β → DM (ForInStep β)) (init b : β) (c c' : Cursor),
      (∀ a ∈ l, ∀ b c r c', I b → (f a b).run c = .ok (r, c') → I r.value) → I init →
      (forIn l init f).run c = .ok (b, c') → I b
  | [], f, init, b, c, c', _, h0, h => by
    simp only [List.forIn_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    exact h0
  | a :: l, f, init, b, c, c', hs, h0, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    have := hs a (by simp) init c r c1 h0 h1
    cases r with
    | done b' => obtain ⟨rfl, rfl⟩ := pure_ok h2; exact this
    | yield b' => exact ctr_forIn_mem I l f b' b c1 c' (fun a' ha' => hs a' (by simp [ha'])) this h2

theorem ctr_forIn'_mem {α β : Type} (I : β → Prop) :
    ∀ (l : List α) (f : (a : α) → a ∈ l → β → DM (ForInStep β)) (init b : β) (c c' : Cursor),
      (∀ a (h : a ∈ l), ∀ b c r c', I b → (f a h b).run c = .ok (r, c') → I r.value) → I init →
      (forIn' l init f).run c = .ok (b, c') → I b
  | [], f, init, b, c, c', _, h0, h => by
    simp only [List.forIn'_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    exact h0
  | a :: l, f, init, b, c, c', hs, h0, h => by
    simp only [List.forIn'_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    have := hs a (by simp) init c r c1 h0 h1
    cases r with
    | done b' => obtain ⟨rfl, rfl⟩ := pure_ok h2; exact this
    | yield b' =>
      exact ctr_forIn'_mem I l _ b' b c1 c' (fun a' ha' => hs a' (List.mem_cons_of_mem a ha')) this h2

/-- Every body of a loop that only yields ran successfully at some state. -/
theorem ctr_forIn_all {α β : Type} :
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
    · exact ctr_forIn_all l f b' b c1 c' hy h2 a' ha'

theorem ctr_set_true {head : Array Bool} {j j' : Nat} (h : (head.set! j true)[j']! = true) :
    j' = j ∨ head[j']! = true := by
  by_cases e : j' = j
  · exact .inl e
  · right
    simp only [Array.set!_eq_setIfInBounds, getElem!_def,
      Array.getElem?_setIfInBounds_ne (Ne.symm e)] at h
    simpa [getElem!_def] using h

theorem ctr_heads_of {mode : Mode} {protos : Array Proto} {padded : Array Bool} {rs : Nat}
    {heads : Array Nat} {c c' : Cursor}
    (h : (loopHeads mode protos padded rs).run c = .ok (heads, c')) :
    ∀ k (hk : k < protos.size), protos[k].counter.isSome = true →
      ∃ k', ∃ hk' : k' < protos.size, (protos.map (·.pos))[k]! ∈ protos[k'].targets := by
  unfold loopHeads at h
  obtain ⟨head, c10, h10, h⟩ := bind_ok h
  obtain ⟨u, c11, h11, h⟩ := bind_ok h
  let P : Nat → Prop := fun j =>
    ∃ k', ∃ hk' : k' < protos.size, (protos.map (·.pos))[j]! ∈ protos[k'].targets
  have hinv : ∀ j, head[j]! = true → P j := by
    rw [Std.Legacy.Range.forIn'_eq_forIn'_range'] at h10
    refine ctr_forIn'_mem (fun hd : Array Bool => ∀ j, hd[j]! = true → P j) _ _ _ _ _ _
      ?_ ?_ h10
    · intro i hi b c r c' hb hr
      have hil : i < protos.size := by
        have := List.mem_range'.1 hi
        simp [Std.Legacy.Range.size] at this
        omega
      dsimp only at hr
      obtain ⟨_, _, -, hr⟩ := bind_ok hr
      obtain ⟨b2, c2, h2, h3⟩ := bind_ok hr
      obtain ⟨rfl, -⟩ := pure_ok h3
      refine ctr_forIn_mem (fun hd : Array Bool => ∀ j, hd[j]! = true → P j) _ _ _ _ _ _
        ?_ hb h2
      intro t ht b c r c' hb hr
      obtain ⟨j, c3, hj, h4⟩ := bind_ok hr
      have hjt : (protos.map (·.pos))[j]! = t := by
        unfold indexAt at hj
        try dsimp only at hj
        split at hj
        · rename_i j' hj'
          obtain ⟨rfl, -⟩ := pure_ok hj
          exact rustBinarySearch_ok hj'
        · exact (err_ok hj).elim
      have hP : P j := by
        refine ⟨i, hil, ?_⟩
        rw [hjt]
        simp only [Proto.targets, List.mem_append, List.mem_flatMap]
        rcases List.mem_append.mp ht with ht | ht
        · left
          obtain ⟨o, ho, hot⟩ := List.mem_filterMap.mp ht
          refine ⟨o, ho, ?_⟩
          cases o <;> simp at hot
          subst hot; simp [Opnd.targetsOf]
        · right
          revert ht
          split
          · rename_i _ _ _ he; rw [he]; simp [Then.targets]
          · rename_i _ ts he; rw [he]; simp only [Then.targets]
            intro ht
            exact List.mem_of_getLast? (by simpa using ht)
          · simp
      split at h4
      · obtain ⟨rfl, -⟩ := pure_ok h4
        intro j' hj'
        rcases ctr_set_true hj' with rfl | hj'
        · exact hP
        · exact hb j' hj'
      · obtain ⟨rfl, -⟩ := pure_ok h4
        exact hb
    · intro j hj
      simp only [getElem!_def, Array.getElem?_replicate] at hj
      split at hj <;> simp_all
  have hall := ctr_forIn_all _ _ _ _ _ _ ?_ (by
    rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h11; exact h11)
  · intro k hk hc
    obtain ⟨b, c, r, c', hr⟩ := hall k (by simp [List.mem_range', Std.Legacy.Range.size]; omega)
    dsimp only at hr
    rcases ctr_ite_ok hr with ⟨-, h⟩ | ⟨-, h⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    rcases ctr_ite_ok h with ⟨-, h⟩ | ⟨hn, -⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    have hk' : protos[k]! = protos[k] := by simp [getElem!_def, hk]
    rw [hk', hc] at hn
    have hh : head[k]! = true := by
      cases hh : head[k]! <;> simp_all
    exact hinv k hh
  · intro a b c r c' hr
    dsimp only at hr
    rcases ctr_ite_ok hr with ⟨-, h⟩ | ⟨-, h⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    rcases ctr_ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok h; exact (err_ok h').elim
    obtain ⟨rfl, -⟩ := pure_ok h; exact ⟨_, rfl⟩

theorem ctr_read_heads {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hnr : regionPad mode callSites = none) :
    ∀ k (hk : k < r.protos.size), r.protos[k].counter.isSome = true →
      ∃ k', ∃ hk' : k' < r.protos.size, posOf r k ∈ r.protos[k'].targets := by
  unfold Vm.read at h
  obtain ⟨⟨entry, fs⟩, c1, -, h⟩ := bind_ok h
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
  obtain ⟨body, c4, -, h⟩ := bind_ok h
  obtain ⟨_, c5, -, h⟩ := bind_ok h
  try dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, -, h⟩ := bind_ok h
  dsimp only at h
  obtain ⟨u, c8, -, h⟩ := bind_ok h
  obtain ⟨heads, c9, h9, h⟩ := bind_ok h
  obtain ⟨u, c10, -, h⟩ := bind_ok h
  simp only [Nat.lt_irrefl, ↓reduceIte] at h
  obtain ⟨protos', c11, h11, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pure_ok h11
  obtain ⟨acts, c12, -, h⟩ := bind_ok h
  obtain ⟨he, -⟩ := pure_ok h
  cases he
  unfold posOf
  exact ctr_heads_of h9

/-- A loop head is a branch target (`ctr_read_heads`, without a pad region, `hD.noRegion`):
`read`'s loop-head pass sets `head[j]` only for `j = index p.pos t`
with `t` in `single ++ br` (a `.target` operand, a handler branch or a table's last target:
all in `Proto.targets`), and its check `counter.isSome != (counters && head[i])` rejects a
counter elsewhere; `rustBinarySearch` gives `posOf S.r j = t`. -/
theorem ctr_head_target (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : k < S.r.protos.size) (h : S.r.protos[k].counter.isSome = true) :
    ∃ k', ∃ hk' : k' < S.r.protos.size, posOf S.r k ∈ S.r.protos[k'].targets := by
  obtain ⟨c', hr⟩ := hD.read
  exact ctr_read_heads hr hD.noRegion k hk h

theorem ctr_apart (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) : CounterApart S := by
  refine ⟨H.envApart.ctrOwned, H.envApart.slotOff, fun s x hf o h1 h2 => ?_, H.envApart.allocs,
    H.relocsIn, fun k hk hc => ?_⟩
  · rw [hf.fpAddr_eq]; exact H.envApart.window o h1 h2
  · obtain ⟨k', hk', hmem⟩ := ctr_head_target hD hk hc
    refine ⟨?_, H.argsOk.untargeted k' hk' _ hmem k rfl⟩
    unfold Setup.used
    rw [ite_eq_left_iff.mpr (fun h => absurd (H.cacheCleared.targets k' hk' _ hmem) h)]

end Heads

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-! ### Addresses -/

theorem ctr_add_sub_left (x y : BitVec 64) : x + y - x = y := by bv_omega

theorem ctr_base_setWidth (ctx : Ctx) (t : BitVec 32) :
    ctx.base + t.setWidth 64 = addrAt ctx t.toNat := by
  unfold addrAt; congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_setWidth, BitVec.toNat_ofNat]

/-- The numbers behind a boundary's frame: `rbp = fp`, `rsp = fp - F`, the entry `rsp = fp + 8`. -/
theorem ctr_nums (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x) :
    (x.reg .rbp).toNat = s.fp ∧ x.rsp.toNat = s.fp - S.F ∧ S.x0.rsp.toNat = s.fp + 8 ∧
      s.fp + 16 ≤ 2 ^ 64 ∧ S.F ≤ s.fp ∧ (S.K : Int) ≤ 2 ^ 31 ∧ 16 ≤ S.K := by
  have hK := H.argSizeK
  have hKl := H.frameBounds.K_le
  have hwin := hf.win
  have hfp := hf.fpF
  have hb := hf.rrel.rbp
  have hlt : s.fp < 2 ^ 64 := by omega
  have hrb : (x.reg .rbp).toNat = s.fp := by rw [hb, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hlt]
  refine ⟨hrb, ?_, ?_, by omega, hfp, hKl, by omega⟩
  · rw [hf.rsp, BitVec.toNat_sub, hrb, BitVec.toNat_ofNat]
    have : S.F < 2 ^ 64 := by omega
    rw [Nat.mod_eq_of_lt this]; omega
  · have e : S.x0.rsp = x.reg .rbp + 8 := by have := hf.frame.rbp; bv_omega
    rw [e, BitVec.toNat_add, hrb]; simp; omega

theorem ctr_rsp_le (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x) :
    x.rsp.toNat ≤ S.x0.rsp.toNat := by
  obtain ⟨-, h2, h3, -⟩ := ctr_nums H hf; omega

theorem ctr_inStack_lift (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x)
    {a : BitVec 64} (h : ¬ InStack S.lo S.x0.rsp a) : ¬ InStack S.lo x.rsp a := by
  have := ctr_rsp_le H hf
  intro ⟨h1, h2⟩; exact h ⟨h1, by omega⟩

/-- The frame window is apart from what the trip may write. -/
theorem ctr_window_apart (H : Hyps S) (HC : CounterApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {o : Int} (h1 : -(S.F : Int) ≤ o) (h2 : o < S.K) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) := by
  refine ⟨HC.window s x hf o h1 h2, fun ⟨_, hs⟩ => ?_⟩
  obtain ⟨hrb, hrsp, -, hw, hF, hKl, -⟩ := ctr_nums H hf
  have hwin := hf.win
  rw [hrsp] at hs
  simp only [fpAddr, BitVec.toNat_add, hrb, BitVec.toNat_ofInt] at hs
  omega

/-- The trip's write set and the check's counter write keep memory outside it. -/
abbrev ctr_Keeps (S : Setup) (x : X86.State) (m : Mem) : Prop :=
  ∀ a, ¬ S.Owned a → ¬ InStack S.lo x.rsp a → m a = x.mem a

theorem ctr_linkOk (H : Hyps S) (HC : CounterApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : ctr_Keeps S x m) : LinkOk S.ctx m S.body S.rs := by
  have hc : ∀ j, j < S.body.code.size → m (addrAt S.ctx j) = x.mem (addrAt S.ctx j) := by
    intro j hj
    obtain ⟨ho, hst, -⟩ := H.codeApart (addrAt S.ctx j) (.inl ⟨j, hj, rfl⟩)
    exact hm _ ho (ctr_inStack_lift H hf hst)
  obtain ⟨hfl, hso, ⟨hl1, hl2⟩, hsm, hfp⟩ := hf.code
  refine ⟨hfl, hso, ⟨fun j hj hr => ?_, fun r hr k hk => ?_⟩, hsm, hfp⟩
  · rw [hc j hj]; exact hl1 j hj hr
  · rw [hc _ (by have := HC.relocs r hr; omega)]; exact hl2 r hr k hk

theorem ctr_roLoaded (H : Hyps S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : ctr_Keeps S x m) : RoLoaded S.ctx m S.ro := by
  obtain ⟨base, h1, h2⟩ := hf.ro
  refine ⟨base, h1, fun j hj => ?_⟩
  obtain ⟨ho, hst, -⟩ := H.codeApart (base + BitVec.ofNat 64 j) (.inr ⟨j, hj, (h1 j).symm⟩)
  rw [hm _ ho (ctr_inStack_lift H hf hst)]; exact h2 j hj

theorem ctr_read64 (H : Hyps S) (HC : CounterApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {m : Mem} (hm : ctr_Keeps S x m) {o : Int}
    (h1 : -(S.F : Int) ≤ o) (h2 : o + 8 ≤ S.K) : m.read64 (fpAddr x o) = x.mem.read64 (fpAddr x o) := by
  unfold Mem.read64; congr 1
  apply readNat_congr
  intro i hi
  rw [← fpAddr_add]
  obtain ⟨a1, a2⟩ := ctr_window_apart H HC hf (o := o + i) (by omega) (by omega)
  exact hm _ a1 a2

/-- A frame byte `opSem` can read and that is initialized is apart from the trip's writes. -/
theorem ctr_byte_apart (H : Hyps S) (HC : CounterApart S) {s : R.RState} {x : X86.State}
    (hf : FrameInv S s x) {o : Int} {b : AbstractByte} (hb : s.st.byteAt o = .ok b)
    (hu : b ≠ .uninit) :
    ¬ S.Owned (fpAddr x o) ∧ ¬ InStack S.lo x.rsp (fpAddr x o) := by
  unfold OpSem.State.byteAt at hb
  split at hb
  · rename_i hn
    have hb' : s.st.frame o = b := by simpa [pure, Except.pure] using hb
    obtain ⟨i1, i2⟩ := hf.sep.init o hn (by rw [hb']; exact hu)
    exact ctr_window_apart H HC hf i1 i2
  · rename_i e he
    split at hb
    · rename_i a hg
      split at hb
      · cases hb
      · rename_i hlive
        split at hb
        · rename_i b' hd
          have hmem : e ∈ s.st.escaped := List.mem_of_find?_eq_some he
          have hin := List.find?_some he
          simp only [decide_eq_true_eq] at hin
          have hlay := hf.rrel.rel.layout e hmem a hg
          have hn : ((o - e.off).toNat : Int) = o - e.off := Int.toNat_of_nonneg (by omega)
          have hlt : (o - e.off).toNat < a.data.size := by
            rcases Array.getElem?_eq_some_iff.1 hd with ⟨h, -⟩; exact h
          have hsp := hf.sep.space e.id a hg (by simpa using hlive)
          have haddr : fpAddr x o = BitVec.ofNat 64 a.addr + BitVec.ofNat 64 (o - e.off).toNat := by
            rw [hlay, ← fpAddr_add, hn]; congr 1; omega
          refine HC.allocs s x hf _ ⟨e.id, a, hg, by simpa using hlive, ?_⟩
          rw [haddr, ctr_add_sub_left, BitVec.toNat_ofNat]
          simp only [Allocation.size] at *
          omega
        · cases hb
    · cases hb

/-- `FrameInv` survives a state that agrees with `x` (`Counter.Agree`), at an instruction past
the leading `arg`s. -/
theorem ctr_frameInv (H : Hyps S) (HC : CounterApart S) {s : R.RState} {x y : X86.State}
    (hf : FrameInv S s x) (hag : Counter.Agree S.Owned S.lo x y) (ha : ¬ LeadArg S s.pc)
    (hsv : S.c.mode.pe = true → y.regs 6 = x.regs 6 ∧ y.regs 7 = x.regs 7) :
    FrameInv S s y := by
  have hrbp : y.reg .rbp = x.reg .rbp := hag.2.1 5 (Or.inr (Or.inl rfl))
  have hfp : ∀ o, fpAddr y o = fpAddr x o := fun o => by simp [fpAddr, hrbp]
  have hm : ctr_Keeps S x y.mem := hag.2.2
  obtain ⟨hrb, hrsp, -, hw, hF, hKl, hK16⟩ := ctr_nums H hf
  refine ⟨⟨⟨fun o h1 h2 b hb => ?_, fun e he a h => ?_, fun p hp => ?_⟩, hrbp.trans hf.rrel.rbp,
    hf.rrel.wf⟩, fun id a hg hl i hi => ?_, hf.sep.congr hrbp, hf.win, hf.fpF,
    by rw [hag.1, hrbp]; exact hf.rsp, by rw [hag.1]; exact hf.room, ctr_linkOk H HC hf hm,
    ctr_roLoaded H hf hm, fun h => absurd h ha, ?_⟩
  · have hr := hf.rrel.rel.frame o h1 h2 b hb
    rw [hfp]
    cases b with
    | uninit => trivial
    | init v p =>
      obtain ⟨a1, a2⟩ := ctr_byte_apart H HC hf hb (by simp)
      rw [hm _ a1 a2]; exact hr
  · rw [hfp]; exact hf.rrel.rel.layout e he a h
  · rw [hfp]; exact hf.rrel.rel.zeroSized p hp
  · have hr := hf.mem id a hg hl i hi
    have hsp := hf.sep.space id a hg hl
    obtain ⟨a1, a2⟩ := HC.allocs s x hf (BitVec.ofNat 64 (a.addr + i)) ⟨id, a, hg, hl, by
      rw [BitVec.ofNat_add, ctr_add_sub_left, BitVec.toNat_ofNat]
      simp only [Allocation.size] at *
      omega⟩
    rw [hm _ a1 a2]; exact hr
  · obtain ⟨f1, f2, f3, f5⟩ := hf.frame
    have e8 : x.reg .rbp + 8 = fpAddr x 8 := rfl
    have e0 : x.reg .rbp = fpAddr x 0 := by simp [fpAddr]
    refine ⟨by rw [hrbp]; exact f1, ?_, ?_, fun i hi h5 => ?_⟩
    rotate_left 2
    · rcases hi with hi | ⟨hpe, h67⟩
      · rw [hag.2.1 i hi]; exact f5 i (Or.inl hi) h5
      · obtain ⟨g6, g7⟩ := hsv hpe
        rcases h67 with rfl | rfl
        · rw [g6]; exact f5 _ (Or.inr ⟨hpe, Or.inl rfl⟩) h5
        · rw [g7]; exact f5 _ (Or.inr ⟨hpe, Or.inr rfl⟩) h5
    · rw [hrbp, e8, ctr_read64 H HC hf hm (by omega) (by omega), ← e8]; exact f2
    · rw [hrbp, e0, ctr_read64 H HC hf hm (by omega) (by omega), ← e0]; exact f3

theorem ctr_link_length (addr : BitVec 64) (addrOf : RefAddr) :
    ∀ (relocs : List X86.Reloc) (code : List UInt8), (link addr addrOf code relocs).length = code.length
  | [], _ => rfl
  | r :: rs, code => by
    simp only [link, List.foldl_cons] at *
    have := ctr_link_length addr addrOf rs
    simp only [link] at this
    rw [this]; simp

theorem ctr_linkedAt_length (ctx : Ctx) (i : Item) (pos : Nat) :
    (i.linkedAt ctx pos).length = i.size := by
  unfold Item.linkedAt
  simp only
  rw [ctr_link_length, encode_len]

/-- The addresses of items decoded from a linked cursor are code addresses. -/
theorem ctr_inCode_dec {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} (hk : LinkOk ctx m c rs) :
    ∀ {p q : Nat} {items : List Item}, Dec c p items q → Boundary rs p →
      ∀ a, InCode ctx items p a → ∃ j, j < c.code.size ∧ a = addrAt ctx j := by
  intro p q items hd
  induction hd with
  | nil => intro _ a h; exact absurd h id
  | @cons p n q i is hdi _ ih =>
    intro hb a ha
    obtain ⟨-, hsz, hle, hb'⟩ := decodeItem_itemAt (c := atPos c p) hk.fields hk.sorted hk.loaded
      hk.small hk.fp hb hdi
    rcases ha with ⟨j, hj, rfl⟩ | ha
    · rw [ctr_linkedAt_length, hsz] at hj
      exact ⟨p + j, by simp at hle; omega, addrAt_add' ctx p j⟩
    · rw [hsz] at ha; exact ih hb' a ha

/-- Code bytes are neither runtime-owned nor on the stack below a boundary's `rsp`. -/
theorem ctr_code_apart (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x)
    {p q : Nat} {items : List Item} (hd : Dec S.body p items q) (hb : Boundary S.rs p) :
    ∀ a, InCode S.ctx items p a → ¬ S.Owned a ∧ ¬ InStack S.lo x.rsp a := by
  intro a ha
  obtain ⟨j, hj, rfl⟩ := ctr_inCode_dec hf.code hd hb a ha
  obtain ⟨ho, hst, -⟩ := H.codeApart _ (.inl ⟨j, hj, rfl⟩)
  exact ⟨ho, ctr_inStack_lift H hf hst⟩

theorem ctr_push_other (lo sp a : BitVec 64) (hlo : lo.toNat + 8 ≤ sp.toNat)
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

theorem ctr_simple_canonical (i : Item) (h : i.wf 0 = true)
    (hw : ∀ p q, i.wf p = i.wf q) (ht : ∀ b e, i ≠ .tableEntry b e) (p : Nat) : i.Canonical p :=
  ⟨ht, .inl (by rw [hw _ 0]; exact h)⟩

/-- `reach_counter`. Proof: the check's items (`ctrInc true`, `jns stub`) are fetched from
memory (`LinkOk.dec`, `branch_canonical`); `Counter.counter_noop` under `H.trip`: no trip falls
through to `p2`; a trip branches to the stub (`H.stubsLinked`), whose `call [r11 + 16]` is an
environment step (`H.envOutside.trip`) returning to its `jmp back` (`back = p2`); `ctr_frameInv`
with `ctr_apart hD H` keeps `FrameInv` (a loop head isn't a leading `arg`, `CounterApart.heads`),
and the cache there is empty (`heads`, `CacheInv.empty`); on PE the trip keeps `rsi`/`rdi`
(`H.peSaved`). -/
theorem reach_counter (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p1 p2 stub : Nat} (hk : k < S.r.protos.size)
    (hq : S.r.protos[k].counter = some (stub, p2))
    (hctr : CounterRead S.fr S.body p1 (some (stub, p2)) p2) (hb : Boundary S.rs p1)
    {Q : X86.State → Prop} {s : R.RState} {x : X86.State} (hs : s.pc = k)
    (hf : FrameInv S s x) (hrip : x.rip = addrAt S.ctx p1) (hci : CacheInv (S.used k) x)
    (kont : ∀ y, FrameInv S s y → y.rip = addrAt S.ctx p2 → CacheInv (S.used k) y →
      Reach S.ctx S.E Q y) :
    Reach S.ctx S.E Q x := by
  have htrip : S.c.mode.pe = true → ∀ a b, S.E.ret a b → b.regs 6 = a.regs 6 ∧ b.regs 7 = a.regs 7 :=
    H.peSaved
  have HC := ctr_apart hD H
  obtain ⟨huk, hnl⟩ := HC.heads k hk (by rw [hq]; rfl)
  have hci0 : ∀ y, CacheInv (S.used k) y := fun y => by rw [huk]; exact CacheInv.empty y
  have hnl' : ¬ LeadArg S s.pc := by rw [hs]; exact hnl
  obtain ⟨hbs, n, t', long', q, ht', hdecs⟩ := H.stubsLinked k hk stub p2 hq
  have hsp : S.body.spFrame = none := hf.code.fp
  cases hctr with
  | @check _ t long hcnt hdec =>
  obtain ⟨hca, hp2, -⟩ := hf.code.dec hdec hb
  have hdec0 := hdec
  rcases hdec0 with _ | ⟨hd1, _ | ⟨hd2, _ | _⟩⟩
  obtain ⟨-, hs1, -, hb1⟩ := decodeItem_itemAt (c := atPos S.body p1) hf.code.fields hf.code.sorted
    hf.code.loaded hf.code.small hf.code.fp hb hd1
  rename_i n1 n2
  have hcan2 := branch_canonical hsp hd2
  rw [← hs1] at hcan2
  obtain ⟨x', hx⟩ := Counter.check_ok S.ctx true t long x
  have hap := ctr_code_apart H hf hdec hb
  have hrun : FetchRun S.ctx (InCode S.ctx (Counter.check true t long) p1) [.ctrInc true] x := by
    intro y hy
    rw [Counter.exec_ctrInc] at hy
    cases hy
    refine ⟨rfl, fun a ha => ?_, trivial⟩
    apply Mem.write_other
    apply Classical.byContradiction
    intro hlt
    apply (hap a ha).1
    have e : a = Counter.ctrAddr S.ctx true + BitVec.ofNat 64 (a - Counter.ctrAddr S.ctx true).toNat := by
      rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]; bv_omega
    rw [e]
    exact HC.ctrOwned _ (by omega)
  have hsteps : Steps S.ctx x x' :=
    steps_of_run_last (items := [.ctrInc true]) (j := .branch .ns t long)
      ⟨ctr_simple_canonical _ rfl (fun _ _ => rfl) (fun _ _ h => by cases h) _, hcan2, trivial⟩
      hca hrip (fun _ h => h) hrun hx
  obtain ⟨-, hs2, -, -⟩ := decodeItem_itemAt (c := atPos S.body (p1 + n1)) hf.code.fields
    hf.code.sorted hf.code.loaded hf.code.small hf.code.fp hb1 hd2
  have hafter : Counter.after x.rip true t long = addrAt S.ctx (p1 + n1 + n2) := by
    rw [hrip]
    simp only [Counter.after, Counter.checkLen, hs1, hs2]
    rw [addrAt_add' S.ctx p1, Nat.add_assoc]
  have hback : S.ctx.base + t'.setWidth 64 = Counter.after x.rip true t long := by
    rw [hafter, ctr_base_setWidth, ht']
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by have := hf.room; omega
  obtain ⟨hregs, -, hmem, -⟩ := Counter.check_effect S.ctx true t long x x' hx
  rcases Counter.counter_noop H.trip S.ctx true t long (headStub (BitVec.ofNat 64 n) t' long')
      (BitVec.ofNat 64 n) t' long' (.inr rfl) x x' hback (fun j hj => HC.ctrOwned j hj) hlo hx with
    ⟨hrip', hag⟩ | ⟨hrip', hstub⟩
  · exact Reach.steps hsteps (kont x' (ctr_frameInv H HC hf hag hnl' (fun _ => by rw [hregs]; exact ⟨rfl, rfl⟩))
    (hrip'.trans hafter) (hci0 x'))
  have hag' : Counter.Agree S.Owned S.lo x x' := by
    refine ⟨by simp [State.rsp, State.reg, hregs], fun i _ => by rw [hregs], fun a ha _ => hmem a ?_⟩
    apply Classical.byContradiction
    intro hlt
    apply ha
    have e : a = Counter.ctrAddr S.ctx true + BitVec.ofNat 64 (a - Counter.ctrAddr S.ctx true).toNat := by
      rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]; bv_omega
    rw [e]
    exact HC.ctrOwned _ (by omega)
  have hL' := ctr_linkOk H HC hf hag'.2.2
  obtain ⟨hcs, -, -⟩ := hL'.dec hdecs hbs
  have hap' := ctr_code_apart H hf hdecs hbs
  rcases hdecs with _ | ⟨hs1d, _ | ⟨hs2d, _ | ⟨hs3d, _ | ⟨hs4d, _ | _⟩⟩⟩⟩
  rename_i m1 m2 m3 m4
  obtain ⟨-, e1, -, b1⟩ := decodeItem_itemAt (c := atPos S.body t.toNat) hf.code.fields
    hf.code.sorted hf.code.loaded hf.code.small hf.code.fp hbs hs1d
  obtain ⟨-, e2, -, b2⟩ := decodeItem_itemAt (c := atPos S.body (t.toNat + m1)) hf.code.fields
    hf.code.sorted hf.code.loaded hf.code.small hf.code.fp b1 hs2d
  obtain ⟨-, e3, -, -⟩ := decodeItem_itemAt (c := atPos S.body (t.toNat + m1 + m2)) hf.code.fields
    hf.code.sorted hf.code.loaded hf.code.small hf.code.fp b2 hs3d
  have hcan4 := branch_canonical hsp hs4d
  rw [← e1, ← e2, ← e3] at hcan4
  obtain ⟨i1, i2, i3, i4, -⟩ := hcs
  have scan : ∀ i : Item, i.wf 0 = true → (∀ p q, i.wf p = i.wf q) → (∀ b e, i ≠ .tableEntry b e) →
      ∀ p, i.Canonical p := ctr_simple_canonical
  have hrs : x'.rip = addrAt S.ctx t.toNat := hrip'.trans (ctr_base_setWidth _ _)
  -- `lea r11, [record]`
  let y1 := (x'.jump (x'.rip + BitVec.ofNat 64 (Item.lea .r11 .record).size)).setReg .r11
    (S.ctx.addrOf .record)
  have he1 : (Item.lea .r11 .record).exec S.ctx x' = .ok y1 := rfl
  have st1 : Step S.ctx x' y1 :=
    .exec _ t.toNat (scan _ rfl (fun _ _ => rfl) (fun _ _ h => by cases h) _) i1 hrs he1
  have hy1rip : y1.rip = addrAt S.ctx (t.toNat + (Item.lea .r11 .record).size) := by
    rw [← addrAt_add', ← hrs]; rfl
  have hy1r11 : y1.reg .r11 = S.ctx.addrOf .record := State.reg_setReg _ _ _
  have hy1rsp : y1.rsp = x'.rsp := State.reg_setReg_other _ _ _ _ (by decide)
  -- `mov eax, n`
  have hy1sv : y1.regs 6 = x'.regs 6 ∧ y1.regs 7 = x'.regs 7 := by
    simp [y1, State.setReg, State.jump, Reg.idx, Reg.num]
  obtain ⟨y2, he2, hy2rip, hy2mem, hy2r11, hy2rsp, hy2sv⟩ : ∃ y2,
      (Item.setReg .rax (BitVec.ofNat 64 n)).exec S.ctx y1 = .ok y2 ∧
      y2.rip = y1.rip + BitVec.ofNat 64 (Item.setReg .rax (BitVec.ofNat 64 n)).size ∧
      y2.mem = y1.mem ∧ y2.reg .r11 = y1.reg .r11 ∧ y2.rsp = y1.rsp ∧
      (y2.regs 6 = y1.regs 6 ∧ y2.regs 7 = y1.regs 7) := by
    simp only [Item.exec]
    split
    · exact ⟨_, rfl, rfl, rfl, by simp [State.setFlags, State.reg, State.setReg, State.jump, Reg.idx, Reg.num],
        by simp [State.setFlags, State.rsp, State.reg, State.setReg, State.jump, Reg.idx, Reg.num],
        by simp [State.setFlags, State.setReg, State.jump, Reg.idx, Reg.num]⟩
    · exact ⟨_, rfl, rfl, rfl, by simp [State.reg, State.setReg, State.jump, Reg.idx, Reg.num],
        by simp [State.rsp, State.reg, State.setReg, State.jump, Reg.idx, Reg.num],
        by simp [State.setReg, State.jump, Reg.idx, Reg.num]⟩
  have st2 : Step S.ctx y1 y2 :=
    .exec _ _ (scan _ rfl (fun _ _ => rfl) (fun _ _ h => by cases h) _) i2 hy1rip he2
  have hy2rip' : y2.rip = addrAt S.ctx (t.toNat + (Item.lea .r11 .record).size +
      (Item.setReg .rax (BitVec.ofNat 64 n)).size) := by
    rw [hy2rip, hy1rip, addrAt_add']
  have hrsp2 : y2.rsp = x.rsp := by rw [hy2rsp, hy1rsp, hag'.1]
  have hlo2 : S.lo.toNat + 8 ≤ y2.rsp.toNat := by rw [hrsp2]; exact hlo
  -- `call [r11 + 16]`
  let next := y2.rip + BitVec.ofNat 64 (Item.callR11 16).size
  obtain ⟨y3, he3, hy3rip, hy3rsp, hy3mem, hy3sv⟩ : ∃ y3, (Item.callR11 16).exec S.ctx y2 = .ok y3 ∧
      y3.rip = y2.mem.read64 (S.ctx.addrOf .record + BitVec.ofNat 64 16) ∧
      y3.rsp = y2.rsp - 8 ∧ y3.mem = y2.mem.write (y2.rsp - 8) 8 next.toNat ∧
      (y3.regs 6 = y2.regs 6 ∧ y3.regs 7 = y2.regs 7) := by
    refine ⟨_, rfl, ?_, ?_, ?_, ?_⟩
    rotate_left 3
    · simp [State.jump, State.push, State.setMem, State.setReg, Reg.idx, Reg.num]
    · simp only [State.jump, State.push, State.setMem]
      rw [show (State.reg { y2 with rip := next } .r11) = y2.reg .r11 from rfl, hy2r11, hy1r11]
      rfl
    · simp [State.jump, State.push, State.setMem, State.rsp, State.reg, State.setReg]
    · rfl
  have st3 : Step S.ctx y2 y3 :=
    .exec _ _ (scan _ rfl (fun _ _ => rfl) (fun _ _ h => by cases h) _)
      (by rw [hy2mem]; exact i3) hy2rip' he3
  have hy3m : ∀ a, ¬ InStack S.lo x.rsp a → y3.mem a = y2.mem a := by
    intro a ha
    rw [hy3mem]
    exact Mem.write_other _ _ _ _ _ (ctr_push_other S.lo y2.rsp a hlo2 (by rw [hrsp2]; exact ha))
  have hout : S.E.out y3 := by
    have hrd : y2.mem.readNat (S.ctx.addrOf .record + BitVec.ofNat 64 16) 8 =
        y3.mem.readNat (S.ctx.addrOf .record + BitVec.ofNat 64 16) 8 :=
      readNat_congr _ _ _ _ (fun i hi => (hy3m _ (ctr_inStack_lift H hf (HC.slotOff i hi))).symm)
    refine H.envOutside.trip y3 ⟨16, ?_⟩
    rw [hy3rip]
    unfold Mem.read64
    rw [hrd]
  refine Reach.steps hsteps (.step st1 (.step st2 (.step st3 (.env hout fun y4 hret => ?_))))
  -- the trip's return, `jmp back`
  have hy3sp : y3.rsp + 8 = x.rsp := by rw [hy3rsp, ← hrsp2]; exact BitVec.sub_add_cancel _ _
  have hy4rip : y4.rip = addrAt S.ctx (t.toNat + (Item.lea .r11 .record).size +
      (Item.setReg .rax (BitVec.ofNat 64 n)).size + (Item.callR11 16).size) := by
    rw [H.trip.ret_rip _ _ hret, hy3mem, hy3rsp, CallLemmas.read64_write_self]
    show y2.rip + _ = _
    rw [hy2rip', addrAt_add']
  have i4' : ItemAt S.ctx y4.mem (.branch .always t' long') (t.toNat + (Item.lea .r11 .record).size +
      (Item.setReg .rax (BitVec.ofNat 64 n)).size + (Item.callR11 16).size) := by
    have := codeAt_of_agree (m := x'.mem) (m' := y4.mem) (items := [.branch .always t' long'])
      ⟨i4, trivial⟩ (fun a ha => by
        obtain ⟨ho, hst⟩ := hap' a (.inr (.inr (.inr ha)))
        rw [H.trip.ret_mem _ _ hret (by rw [hy3sp]; exact hlo) a ho (by rw [hy3sp]; exact hst),
          hy3m a hst, hy2mem]; rfl)
    exact this.1
  obtain ⟨y5, he5⟩ : ∃ y5, (Item.branch .always t' long').exec S.ctx y4 = .ok y5 := by
    simp [Item.exec, Cond.eval, bind, Except.bind, pure, Except.pure]
  have st5 : Step S.ctx y4 y5 := .exec _ _ hcan4 i4' hy4rip he5
  have hy5sv : y5.regs 6 = y4.regs 6 ∧ y5.regs 7 = y4.regs 7 := by
    simp [Item.exec, Cond.eval, bind, Except.bind, pure, Except.pure] at he5
    subst he5
    simp [State.jump]
  have hrun : Counter.Run S.ctx S.E.ret (headStub (BitVec.ofNat 64 n) t' long') x' y5 :=
    .step _ _ _ _ _ (fun _ h => by cases h) he1
      (.step _ _ _ _ _ (fun _ h => by cases h) he2
        (.call _ _ _ _ _ _ he3 hret (.step _ _ _ _ _ (fun _ h => by cases h) he5 (.nil _))))
  obtain ⟨hr5, hag5⟩ := hstub y5 hrun
  have hsv5 : S.c.mode.pe = true → y5.regs 6 = x.regs 6 ∧ y5.regs 7 = x.regs 7 := by
    intro hpe
    obtain ⟨r6, r7⟩ := htrip hpe y3 y4 hret
    rw [hy5sv.1, hy5sv.2, r6, r7, hy3sv.1, hy3sv.2, hy2sv.1, hy2sv.2, hy1sv.1, hy1sv.2, hregs]
    exact ⟨rfl, rfl⟩
  exact .step st5 (kont y5 (ctr_frameInv H HC hf hag5 hnl' hsv5) (hr5.trans hafter) (hci0 y5))

end Insn
