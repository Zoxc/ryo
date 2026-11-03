import Ryo.Proofs.DSWork.Boundary
import Ryo.Proofs.NoArgCursor
import Ryo.Proofs.Discharge.RelocsIn
import Ryo.Proofs.Discharge.PadsLinked
import Ryo.Proofs.Discharge.CacheCleared
import Ryo.Proofs.DSWork.Virt
import Ryo.Proofs.Discharge.SpDisp

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

set_option maxRecDepth 100000 in
theorem island_ofFull {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull .island = some op) : op.full = some .island := by
  have e : (Reduced.Opcode.ofFull .island).bind Reduced.Opcode.full = some .island := by rfl
  rw [h] at e; exact e

/-- `m` doesn't fail with `noBehavior` (it succeeds or fails with another error). -/
def island_NoNB {α : Type} (m : M α) : Prop := ∀ msg, m ≠ .error (.noBehavior msg)

theorem island_noNB_bind {α β : Type} {m : M α} {f : α → M β} (h : island_NoNB m)
    (hf : ∀ a, m = .ok a → island_NoNB (f a)) : island_NoNB (m >>= f) := by
  intro msg he
  cases hm : m with
  | error e => rw [hm] at he; cases he; exact h msg hm
  | ok a => rw [hm] at he; exact hf a hm msg he

theorem island_noNB_pure {α : Type} (a : α) : island_NoNB (pure a : M α) := by
  intro msg h; cases h

theorem island_noNB_ill {α : Type} (s : String) : island_NoNB (illFormed s : M α) := by
  intro msg h; cases h

theorem island_noNB_ub {α : Type} (s : String) : island_NoNB (ub s : M α) := by
  intro msg h; cases h

theorem island_noNB_mapM {α β : Type} (f : α → M β) (hf : ∀ a, island_NoNB (f a)) :
    ∀ l : List α, island_NoNB (l.mapM f)
  | [] => by intro msg h; cases h
  | a :: l => by
    rw [List.mapM_cons]
    refine island_noNB_bind (hf a) fun b _ => island_noNB_bind (island_noNB_mapM f hf l)
      fun bs _ => island_noNB_pure _

theorem island_noNB_foldlM {α β : Type} (f : β → α → M β) (hf : ∀ b a, island_NoNB (f b a)) :
    ∀ (l : List α) (b : β), island_NoNB (l.foldlM f b)
  | [], b => by intro msg h; cases h
  | a :: l, b => by
    rw [List.foldlM_cons]
    exact island_noNB_bind (hf b a) fun b' _ => island_noNB_foldlM f hf l b'

theorem island_noNB_byteAt (st : OpSem.State) (o : Int) : island_NoNB (st.byteAt o) := by
  intro msg h
  unfold OpSem.State.byteAt at h
  repeat' split at h
  all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h

theorem island_noNB_readFrame (st : OpSem.State) (o : Int) (n : Nat) :
    island_NoNB (st.readFrame o n) :=
  island_noNB_mapM _ (fun _ => island_noNB_byteAt _ _) _

theorem island_noNB_writeFrame (st : OpSem.State) (o : Int) (bs : List AbstractByte) :
    island_NoNB (st.writeFrame o bs) := by
  unfold OpSem.State.writeFrame
  refine island_noNB_bind ?_ fun _ _ => island_noNB_pure _
  unfold OpSem.State.writeEscaped
  refine island_noNB_foldlM _ (fun mem bi => ?_) _ _
  intro msg h
  repeat' split at h
  all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h

theorem island_noNB_applyScope (s : R.RState) (sc : R.Scope) :
    island_NoNB (R.applyScope s sc) := by
  unfold R.applyScope
  split
  · unfold R.escape
    intro msg h
    have hr := island_noNB_readFrame s.st
    simp only [island_NoNB] at hr
    simp only [R.frameAddr, bind, Except.bind, pure, Except.pure] at h
    repeat' split at h
    all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h | skip
    all_goals (repeat' split at *) <;> simp_all [illFormed, throw, throwThe, MonadExceptOf.throw]
  · unfold R.storageEnd
    refine island_noNB_bind (island_noNB_writeFrame _ _ _) fun _ _ => island_noNB_pure _
  · exact island_noNB_pure _

theorem island_noNB_scopes (l : List R.Scope) (s : R.RState) :
    island_NoNB (l.foldlM R.applyScope s) :=
  island_noNB_foldlM _ island_noNB_applyScope l s

theorem island_step_scopes_err {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {i : Insn}
    {e : Stop} (hi : c.d.insns[s.pc]? = some i)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .error e) : R.step c s ch = .error e := by
  unfold R.step
  simp [hi, hsc, bind, Except.bind]


/-! #### Small facts -/


theorem island_step_ok {c : R.Code} {s s1 : R.RState} {op : Reduced.Opcode} {isl : Nat}
    {ws : List (BitVec 32)} (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws]))
    (hf : op.full = some .island)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    R.step c s {} = .ok (.ext ⟨.island isl (c.islandTemplate s1.pc) s1.fp (ws.map (·.toInt))
      (c.lendsAt s1.pc), s1.world⟩ s1) := by
  have hsh := Island.island_shape
  unfold R.step
  simp [hi, hsc, hf, hsh, bind, Except.bind, pure, Except.pure]

theorem island_rsp_toNat {x : X86.State} {fp F : Nat} (hb : x.reg .rbp = BitVec.ofNat 64 fp)
    (hfp : fp < 2 ^ 64) (hF : F ≤ fp) (hsp : x.rsp = x.reg .rbp - BitVec.ofNat 64 F) :
    x.rsp.toNat = fp - F := by
  rw [hsp, hb, BitVec.toNat_sub, BitVec.toNat_ofNat, BitVec.toNat_ofNat]
  rw [Nat.mod_eq_of_lt hfp, Nat.mod_eq_of_lt (show F < 2 ^ 64 by omega)]
  omega

theorem island_lends_mem {c : R.Code} {k : Nat} {l : Int × Nat} (h : l ∈ c.lendsAt k) :
    ∃ sc ∈ c.scopesAt k, l = (sc.frameOffset.toInt, sc.size) := by
  unfold R.Code.lendsAt at h
  obtain ⟨sc, hsc, he⟩ := List.mem_filterMap.1 h
  split at he
  · cases he; exact ⟨sc, hsc, rfl⟩
  · cases he

theorem island_sep_writeFrame {lo hi : Int} {st st' : OpSem.State} {x : X86.State} {off : Int}
    {bs : List AbstractByte} (hs : FrameSep lo hi st x) (h : st.writeFrame off bs = .ok st')
    (h1 : lo ≤ off) (h2 : off + bs.length ≤ hi) : FrameSep lo hi st' x := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    refine sep_of_shape hs (allocShape_of_escOnly (writeEscaped_spec hm).escOnly) rfl
      (fun o => ?_) rfl
    by_cases hp : st.privateIn off bs.length o = true
    · left
      simp only [OpSem.State.privateIn, Bool.and_eq_true, decide_eq_true_eq] at hp
      omega
    · right
      simp [hp]

theorem island_sep_writeRanges {lo hi : Int} {st st' : OpSem.State} {x : X86.State}
    {rs : List (Int × Nat)} {new : List (List AbstractByte)} (hs : FrameSep lo hi st x)
    (hin : ∀ r ∈ rs, lo ≤ r.1 ∧ r.1 + r.2 ≤ hi) (h : R.writeRanges st rs new = .ok st') :
    FrameSep lo hi st' x := by
  unfold R.writeRanges at h
  split at h
  · cases h; exact hs
  split at h
  · cases h
  simp only at h
  refine foldlM_inv (FrameSep lo hi · x) (fun p : (Int × Nat) × List AbstractByte =>
    lo ≤ p.1.1 ∧ p.1.1 + p.1.2 ≤ hi) _ ?_ _ st st' hs
    (fun p hp => hin p.1 (List.of_mem_zip hp).1) h
  rintro s0 ⟨⟨off, n⟩, bs⟩ s1 h0 ⟨hp1, hp2⟩ hst
  simp only at hst hp1 hp2
  split at hst
  · cases hst
  · rename_i hlen
    have hlen' : bs.length = n := by simpa using hlen
    exact island_sep_writeFrame h0 hst hp1 (by rw [hlen']; exact hp2)

theorem island_site_read {fr : Vm.Frame} {c c' : Cursor} {isl ops : Nat} {site : Nat × Nat}
    (h : (islandCall fr).run c = .ok ((isl, ops, site), c')) :
    site.2 = 6 ∧ Dec c c.pos [fpItem (Island.islandRegs fr.mode.pe).1 fr.mode,
      .lea (Island.islandRegs fr.mode.pe).2 (.ro ops)] site.1 := by
  unfold islandCall at h
  cases hpe : fr.mode.pe <;> rw [hpe] at h <;>
    simp (config := { zeta := false }) only [Bool.false_eq_true, ↓reduceIte] at h
  all_goals
    obtain ⟨at_, c1, h1, h⟩ := bind_ok h
    obtain ⟨rfl, hc1⟩ := pos_run' h1
    subst c1
    obtain ⟨c1, d1, e1, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
    obtain ⟨x, c2, h2, h⟩ := bind_ok h
    obtain ⟨d2, e2⟩ := item_dec h2
    split at h
    case h_2 => exact (err_ok h).elim
    rename_i r o
    split at h
    · obtain ⟨_, _, h3, -⟩ := bind_ok h; exact (err_ok h3).elim
    rename_i hr
    simp only [bne_iff_ne, ne_eq, Decidable.not_not] at hr
    subst hr
    obtain ⟨st, c3, h3, h⟩ := bind_ok h
    obtain ⟨rfl, hc3⟩ := pos_run' h3
    subst c3
    obtain ⟨y, c4, h4, h⟩ := bind_ok h
    split at h
    case h_2 => exact (err_ok h).elim
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    refine ⟨rfl, ?_⟩
    simp only [Island.islandRegs, Bool.false_eq_true, ↓reduceIte, Frame.fp] at d1 ⊢
    rw [e1] at d2
    exact d1.trans' d2

theorem island_pre_steps {ctx : Ctx} {mode : Ryo.Obj.Mode}
    {isl o p : Nat} {x x1 : X86.State}
    (hc : CodeAt ctx x.mem (Island.islandPre mode isl o) p) (hrip : x.rip = addrAt ctx p)
    (he : execItems ctx (Island.islandPre mode isl o) x = .ok x1) : Steps ctx x x1 := by
  have hr : (Island.islandRegs mode.pe).1.usable = true := by
    cases h : mode.pe <;> rfl
  obtain ⟨hcan, hft, hmk⟩ := vt_fpItem_ok ctx mode hr
  unfold Island.islandPre at hc he
  refine steps_of_run_last (items := [fpItem (Island.islandRegs mode.pe).1 mode,
      .lea (Island.islandRegs mode.pe).2 (.ro o)]) (j := .callMem (.sym isl)) ?_ hc hrip
    (fun _ h => h) ?_ he
  · exact ⟨hcan _, ⟨fun _ _ h => (by cases h), .inl rfl⟩, ⟨fun _ _ h => (by cases h), .inl rfl⟩,
      trivial⟩
  · refine fetchRun_of_forall (fun j hj => ?_) x
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
    rcases hj with rfl | rfl
    · exact ⟨hft, hmk⟩
    · exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
        fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩

/-! #### The island's extra hypotheses -/

/-- The bytes a template must leave alone: the code (its bytes and relocated fields), the
rodata, and the frame's link slots at `x`'s `rbp` (return address, saved `rbp`). -/
def IslandKept (S : Setup) (x : X86.State) (b : BitVec 64) : Prop :=
  (∃ j, j < S.body.code.size ∧ b = addrAt S.ctx j) ∨
  (∃ r ∈ S.rs.toList, ∃ k, k < 4 ∧ b = addrAt S.ctx (r.pos + k)) ∨
  (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j)) ∨
  (∃ i, i < 8 ∧ (b = x.reg .rbp + 8 + BitVec.ofNat 64 i ∨ b = x.reg .rbp + BitVec.ofNat 64 i))

/-- What the island step needs, from `Hyps` and the decoder (`island_hyps`). -/
structure IslandHyps (S : Setup) : Prop where
  /-- No live allocation byte is on the stack below `rsp` after the scopes (`Handler.StackApart`). -/
  allocs : ∀ s x s1, FrameInv S s x → (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 →
    Handler.AllocsApart S.lo s1.st x
  /-- The symbol slots and their targets are off the stack below `rsp`. -/
  syms : ∀ s x, FrameInv S s x → Call.SymsApart S.ctx S.lo x.rsp x.mem
  /-- The frame window holds no runtime-owned byte. -/
  owned : ∀ s x, FrameInv S s x → ∀ o, -(S.F : Int) ≤ o → o < S.K → ¬ S.Owned (fpAddr x o)
  /-- A template may not write the code, the rodata or the frame's link slots. -/
  kept : ∀ s x s1 (xb : X86.State), FrameInv S s x → BInv S s xb →
    (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 →
    ∀ b, IslandKept S x b →
      ¬ Island.IslandMayWrite S.Owned S.lo (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe))
        s.fp (S.c.lendsAt s.pc) s1.world b
  /-- A landing pad is not a leading `arg`. -/
  padArgs : ∀ k pad cat, S.c.cleanupAt k = some (some pad, cat) → ¬ LeadArg S pad
  /-- A landing pad's position fits the 32 bits `PadsLinked` gives it. -/
  padPos : ∀ m, LinkOk S.ctx m S.body S.rs → ∀ k pad cat,
    S.c.cleanupAt k = some (some pad, cat) → posOf S.r pad < 2 ^ 32

/-- `P` of every live allocation's address and size. -/
def island_AllOk (P : Nat → Nat → Prop) (st : OpSem.State) : Prop :=
  ∀ id al, st.mem.get? id = some al → al.live = true → P al.addr al.size

theorem island_allOk_scope {P : Nat → Nat → Prop} {F : Nat} {K : Int} {s s' : R.RState}
    {sc : R.Scope}
    (hnew : ∀ (off : Int) (sz : Nat), -(F : Int) ≤ off → off + sz ≤ K → 0 ≤ (s.fp : Int) + off →
      P ((s.fp : Int) + off).toNat sz)
    (hin : -(F : Int) ≤ sc.frameOffset.toInt ∧ sc.frameOffset.toInt + sc.size ≤ K)
    (hp : island_AllOk P s.st) (h : R.applyScope s sc = .ok s') : island_AllOk P s'.st := by
  unfold R.applyScope at h
  split at h
  · rcases escape_ok h with rfl | ⟨bytes, a, -, hnn, haddr, hdata, -, hread, rfl⟩
    · exact hp
    have hasz : a.size = sc.size := by
      simp [Allocation.size, hdata, readFrame_length hread]
    intro id al hg hl
    simp only [Memory.get?, Array.getElem?_push] at hg
    split at hg
    · simp only [Option.some.injEq] at hg
      subst hg
      rw [haddr, hasz]
      exact hnew _ _ hin.1 hin.2 hnn
    · exact hp id al hg hl
  · intro id al hg hl
    obtain ⟨a0, hg0, hl0, had, hsz, -⟩ := storageEnd_alloc h hg hl
    rw [had, hsz]; exact hp id a0 hg0 hl0
  · cases h; exact hp

theorem island_allOk_foldlM {P : Nat → Nat → Prop} {F : Nat} {K : Int} :
    ∀ (l : List R.Scope) {s s' : R.RState},
    (∀ (off : Int) (sz : Nat), -(F : Int) ≤ off → off + sz ≤ K → 0 ≤ (s.fp : Int) + off →
      P ((s.fp : Int) + off).toNat sz) →
    ScopesIn (-(F : Int)) K l → island_AllOk P s.st →
    l.foldlM R.applyScope s = .ok s' → island_AllOk P s'.st
  | [], s, s', _, _, hp, h => by cases h; exact hp
  | sc :: l, s, s', hnew, hl, hp, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      have hfp : s1.fp = s.fp := (applyScope_keeps h1).fp
      exact island_allOk_foldlM l (by rw [hfp]; exact hnew)
        (fun sc' h' => hl sc' (List.mem_cons_of_mem _ h'))
        (island_allOk_scope hnew (hl sc (List.mem_cons_self ..)) hp h1) h

theorem island_ofInt_add (o : Int) (t : Nat) :
    BitVec.ofInt 64 (o + t) = BitVec.ofInt 64 o + BitVec.ofNat 64 t := by
  rw [BitVec.ofInt_add, BitVec.ofInt_natCast]

theorem island_sub_toNat {b a : BitVec 64} {t : Nat} (h : (b - a).toNat = t) :
    b = a + BitVec.ofNat 64 t := by
  rw [← h, BitVec.ofNat_toNat, BitVec.setWidth_eq]; bv_omega

/-- No live allocation byte in `[lo, rsp)`. -/
def island_AllocsOff (lo rsp : BitVec 64) (st : OpSem.State) : Prop :=
  ∀ id al, st.mem.get? id = some al → al.live = true → ∀ i < al.size,
    ¬ InStack lo rsp (BitVec.ofNat 64 (al.addr + i))

theorem island_allocsOff_scope {lo rsp : BitVec 64} {F : Nat} {K : Int} {s s' : R.RState}
    {sc : R.Scope} (hrsp : rsp.toNat = s.fp - F) (hF : F ≤ s.fp) (htop : (s.fp : Int) + K ≤ 2 ^ 64)
    (hin : -(F : Int) ≤ sc.frameOffset.toInt ∧ sc.frameOffset.toInt + sc.size ≤ K)
    (hp : island_AllocsOff lo rsp s.st) (h : R.applyScope s sc = .ok s') :
    island_AllocsOff lo rsp s'.st := by
  unfold R.applyScope at h
  split at h
  · rcases escape_ok h with rfl | ⟨bytes, a, -, hnn, haddr, hdata, -, hread, rfl⟩
    · exact hp
    have hasz : a.size = sc.size := by
      simp [Allocation.size, hdata, readFrame_length hread]
    intro id al hg hl i hi
    simp only [Memory.get?, Array.getElem?_push] at hg
    split at hg
    · simp only [Option.some.injEq] at hg
      subst hg
      have hi2 : i < sc.size := by rw [← hasz]; exact hi
      have hi3 := Nat.lt_of_lt_of_le hi2 (Nat.le_refl _)
      rintro ⟨-, h2⟩
      rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega)] at h2
      omega
    · exact hp id al hg hl i hi
  · intro id al hg hl i hi
    obtain ⟨a0, hg0, hl0, had, hsz, -⟩ := storageEnd_alloc h hg hl
    rw [had]; exact hp id a0 hg0 hl0 i (hsz ▸ hi)
  · cases h; exact hp

theorem island_allocsOff_foldlM {lo rsp : BitVec 64} {F : Nat} {K : Int} :
    ∀ (l : List R.Scope) {s s' : R.RState}, rsp.toNat = s.fp - F → F ≤ s.fp →
    (s.fp : Int) + K ≤ 2 ^ 64 → ScopesIn (-(F : Int)) K l → island_AllocsOff lo rsp s.st →
    l.foldlM R.applyScope s = .ok s' → island_AllocsOff lo rsp s'.st
  | [], s, s', _, _, _, _, hp, h => by cases h; exact hp
  | sc :: l, s, s', hrsp, hF, htop, hl, hp, h => by
    simp only [List.foldlM_cons, bind, Except.bind] at h
    cases h1 : R.applyScope s sc with
    | error e => simp [h1] at h
    | ok s1 =>
      simp only [h1] at h
      have hfp : s1.fp = s.fp := (applyScope_keeps h1).fp
      exact island_allocsOff_foldlM l (hfp ▸ hrsp) (hfp ▸ hF) (hfp ▸ htop)
        (fun sc' h' => hl sc' (List.mem_cons_of_mem _ h'))
        (island_allocsOff_scope hrsp hF htop (hl sc (List.mem_cons_self ..)) hp h1) h

/-- Live allocations stay off the stack below `rsp` across the scopes: `EnvApart.allocs` before
them; an `Escape` allocates at `fp + off` with the scope in the window
(`FrameBounds.scopes`), at or above `rsp = fp - F` and below `fp + K ≤ 2^64` (`FrameInv.win`),
so not `InStack`; `End` only frees (induction over `foldlM`: `island_allocsOff_foldlM`). -/
theorem island_allocs' (H : Hyps S) {s s1 : R.RState} {x : X86.State} (hf : FrameInv S s x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) : Handler.AllocsApart S.lo s1.st x := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hrsp := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
  have h0 : island_AllocsOff S.lo x.rsp s.st := by
    intro id al hg hl i hi
    refine (H.envApart.allocs s x hf _ ⟨id, al, hg, hl, ?_⟩).2
    have e : BitVec.ofNat 64 (al.addr + i) - BitVec.ofNat 64 al.addr = BitVec.ofNat 64 i := by
      rw [BitVec.ofNat_add]; bv_omega
    rw [e, BitVec.toNat_ofNat]
    exact Nat.lt_of_le_of_lt (Nat.mod_le _ _) hi
  exact island_allocsOff_foldlM _ hrsp hfpF hwin (H.frameBounds.scopesIn s.pc) h0 hsc

set_option maxRecDepth 100000 in
/-- A template leaves the code, the rodata and the link slots alone. The proof unfolds
`IslandMayWrite`: its stack writes lie below `rsp + shadow` (`rsp = fp - F`, `hf.rsp`; on PE
the shadow space `[fp - F, fp - F + 32)`), where the code and rodata are not (`CodeApart`), and
the link slots are above that bound since `shadow ≤ F` (`hF32` on PE); a `Lend` extent is in the window
(`FrameBounds.scopes`), the code and rodata are not (`CodeApart`'s window clause, `fpAddr_eq`),
the link slots in none (`LinkPrivate`); a live allocation of `s1`: the code and rodata are in
none (`CodeApart`: the allocations of `s1` are `s`'s or the scopes', in the window), the link
slots are private (`LinkPrivate`), so in none (`FrameOwn` after the scopes); runtime-owned: not
the code or rodata (`CodeApart`), not the window (`EnvApart.window`). The relocated fields are
code bytes (`RelocsIn`). -/
theorem island_kept' (_hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {s s1 : R.RState} {x : X86.State} (hf : FrameInv S s x)
    {xb : X86.State} (hbi : BInv S s xb)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) (b : BitVec 64)
    (hb : IslandKept S x b) (hF32 : S.c.mode.pe = true → 32 ≤ S.F) :
    ¬ Island.IslandMayWrite S.Owned S.lo (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe))
      s.fp (S.c.lendsAt s.pc) s1.world b := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hfb := H.frameBounds
  have hFle : (S.F : Int) ≤ 2 ^ 31 := hfb.F_le
  have hKle := hfb.K_le
  have hrsp0 := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
  have hsh : Island.shadow S.c.mode.pe ≤ S.F ∧ Island.shadow S.c.mode.pe ≤ 32 := by
    unfold Island.shadow; split
    · have := hF32 (by assumption); omega
    · omega
  -- The template's stack writes end at `rsp + shadow ≤ fp`.
  have hrsp : (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe)).toNat =
      s.fp - S.F + Island.shadow S.c.mode.pe := by
    rw [BitVec.toNat_add, BitVec.toNat_ofNat, hrsp0,
      Nat.mod_eq_of_lt (show Island.shadow S.c.mode.pe < 2 ^ 64 by omega)]
    exact Nat.mod_eq_of_lt (by omega)
  have hrbp : x.reg .rbp = BitVec.ofNat 64 s.fp := hf.rrel.rbp
  have hW : ∀ o, S.winAddr o = BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o := fun o => by
    rw [← hf.fpAddr_eq]; simp [fpAddr, hrbp]
  have hlendsIn : ∀ l ∈ S.c.lendsAt s.pc, -(S.F : Int) ≤ l.1 ∧ l.1 + l.2 ≤ S.K := by
    intro l hl
    obtain ⟨sc, hsc', rfl⟩ := island_lends_mem hl
    exact hfb.scopes s.pc sc hsc'
  -- A byte off the window: not in a lend extent nor a new allocation.
  have hlend_win : ∀ b, (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) →
      ¬ ∃ l ∈ S.c.lendsAt s.pc, (b - Island.lendAddr s.fp l.1).toNat < l.2 := by
    rintro b hnw ⟨l, hl, hlt⟩
    have := hlendsIn l hl
    refine hnw (l.1 + (b - Island.lendAddr s.fp l.1).toNat) (by omega) (by omega) ?_
    rw [hW, island_ofInt_add, ← BitVec.add_assoc]
    exact island_sub_toNat rfl
  -- A code or rodata byte.
  have hcode : ∀ b, ((∃ p, p < S.body.code.size ∧ b = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j))) →
      ¬ Island.IslandMayWrite S.Owned S.lo (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe))
        s.fp (S.c.lendsAt s.pc) s1.world b := by
    intro b hb'
    obtain ⟨hown, hstk, hnw, hal⟩ := H.codeApart b hb'
    rintro (hst | hl | hal1 | ho)
    · apply hstk
      refine ⟨hst.1, Nat.lt_of_lt_of_le hst.2 ?_⟩
      have h0 : S.x0.rsp = x.reg .rbp + 8 := by have := hf.frame.rbp; bv_omega
      have h8 : (8 : BitVec 64).toNat = 8 := rfl
      rw [hrsp, h0, hrbp, BitVec.toNat_add, BitVec.toNat_ofNat, h8,
        Nat.mod_eq_of_lt (show s.fp < 2 ^ 64 by omega)]
      omega
    · exact hlend_win b hnw hl
    · have hold : island_AllOk (fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz) s.st :=
        fun id al hg hl hlt => hal s _ hbi ⟨id, al, hg, hl, hlt⟩
      have hnew := island_allOk_foldlM (P := fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz)
        (F := S.F) (K := S.K) _ (fun off sz h1 h2 h3 hlt => by
          refine hnw (off + (b - BitVec.ofNat 64 ((s.fp : Int) + off).toNat).toNat)
            (by omega) (by omega) ?_
          rw [hW, island_ofInt_add, ← BitVec.add_assoc, ← ofNat_frameAddr _ _ h3]
          exact island_sub_toNat rfl) (hfb.scopesIn s.pc) hold hsc
      obtain ⟨id, al, hg, hl, hlt⟩ := hal1
      exact hnew id al hg hl hlt
    · exact hown ho
  rcases hb with hb | ⟨r, hr, k, hk, rfl⟩ | hb | ⟨i, hi, hb⟩
  · exact hcode b (.inl hb)
  · exact hcode _ (.inl ⟨r.pos + k, by have := H.relocsIn r hr; omega, rfl⟩)
  · exact hcode b (.inr hb)
  · -- A link slot: `fp + o` with `o ∈ [0, 16)`.
    obtain ⟨o, ho1, ho2, rfl⟩ : ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o := by
      have e : ∀ c : Int, x.reg .rbp + BitVec.ofInt 64 c + BitVec.ofNat 64 i =
          fpAddr x (c + i) := fun c => by
        simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
      rcases hb with rfl | rfl
      · refine ⟨8 + i, by omega, by omega, ?_⟩
        rw [← e]; rfl
      · refine ⟨0 + i, by omega, by omega, ?_⟩
        rw [← e]; simp
    have hoF : -(S.F : Int) ≤ o := by omega
    obtain ⟨hesc, hnl⟩ := H.linkPrivate s x s1 hf hsc o ho1 ho2
    rintro (hst | ⟨l, hl, hlt⟩ | ⟨id, al, hg, hlv, hlt⟩ | ho)
    · obtain ⟨-, h2⟩ := hst
      rw [hrsp] at h2
      have : (fpAddr x o).toNat = ((s.fp : Int) + o).toNat := by
        rw [Island.fpAddr_eq_lendAddr hrbp, Island.lendAddr, ← ofNat_frameAddr _ _ (by omega),
          BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega)]
      omega
    · apply hnl l hl
      have hli := hlendsIn l hl
      rw [Island.fpAddr_eq_lendAddr hrbp] at hlt
      simp only [Island.lendAddr] at hlt
      have e : BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o - (BitVec.ofNat 64 s.fp + BitVec.ofInt 64 l.1)
          = BitVec.ofInt 64 (o - l.1) := by
        have : BitVec.ofInt 64 o = BitVec.ofInt 64 l.1 + BitVec.ofInt 64 (o - l.1) := by
          rw [← BitVec.ofInt_add]; congr 1; omega
        rw [this]; bv_omega
      rw [e, BitVec.toNat_ofInt] at hlt
      have hsz : l.2 < 2 ^ 62 := by omega
      omega
    · have hsep1 := (sep_foldlM _ (hfb.scopesIn _) (hfb.window hwin) hf.rrel hf.sep hsc).2
      obtain ⟨e, hem, he1, he2, -⟩ := hsep1.own id al o hg hlv hoF (by omega) hlt
      exact escapedAt_none hesc e hem ⟨he1, he2⟩
    · rw [hf.fpAddr_eq] at ho
      exact H.envApart.window o hoF (by omega) ho

theorem island_hyps (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (hF32 : S.c.mode.pe = true → 32 ≤ S.F) : IslandHyps S :=
  ⟨fun _ _ _ hf hsc => island_allocs' H hf hsc, H.envApart.syms,
    fun _ _ hf o h1 h2 => by rw [hf.fpAddr_eq]; exact H.envApart.window o h1 h2,
    fun _ _ _ _ hf hbi hsc b hb => island_kept' hD H hf hbi hsc b hb hF32,
    fun _ _ _ hcl => pad_not_leadArg hD hcl,
    fun _ hL _ pad _ hcl => posOf_lt_32 hD hL (pad_lpad hD hcl).1⟩

theorem island_link_kept {x y : X86.State} (hc : LinkOk S.ctx x.mem S.body S.rs)
    (hk : ∀ b, IslandKept S x b → y.mem b = x.mem b) : LinkOk S.ctx y.mem S.body S.rs :=
  ⟨hc.fields, hc.sorted,
    ⟨fun j hj hr => by rw [hk _ (Or.inl ⟨j, hj, rfl⟩)]; exact hc.loaded.1 j hj hr,
     fun r hr k hk' => by
      rw [hk _ (Or.inr (Or.inl ⟨r, hr, k, hk', rfl⟩))]; exact hc.loaded.2 r hr k hk'⟩,
    hc.small, hc.fp⟩

/-- `island_link_kept` in either frame form. -/
theorem island_link_keptF {x y : X86.State} (hc : LinkOkF S.ctx x.mem S.body S.rs S.c.mode)
    (hk : ∀ b, IslandKept S x b → y.mem b = x.mem b) : LinkOkF S.ctx y.mem S.body S.rs S.c.mode :=
  ⟨hc.fields, hc.sorted,
    ⟨fun j hj hr => by rw [hk _ (Or.inl ⟨j, hj, rfl⟩)]; exact hc.loaded.1 j hj hr,
     fun r hr k hk' => by
      rw [hk _ (Or.inr (Or.inl ⟨r, hr, k, hk', rfl⟩))]; exact hc.loaded.2 r hr k hk'⟩,
    hc.small, hc.fp⟩

theorem island_ro_kept {x y : X86.State} (hro : RoLoaded S.ctx x.mem S.ro)
    (hk : ∀ b, IslandKept S x b → y.mem b = x.mem b) : RoLoaded S.ctx y.mem S.ro := by
  obtain ⟨base, ha, hb⟩ := hro
  refine ⟨base, ha, fun j hj => ?_⟩
  have := hk (S.ctx.addrOf (.ro j)) (Or.inr (Or.inr (Or.inl ⟨j, hj, rfl⟩)))
  rw [ha] at this
  rw [this]; exact hb j hj

theorem island_read64_kept {m m' : Mem} {a : BitVec 64}
    (h : ∀ i, i < 8 → m' (a + BitVec.ofNat 64 i) = m (a + BitVec.ofNat 64 i)) :
    m'.read64 a = m.read64 a := by
  unfold Mem.read64; rw [IslandLemmas.readNat_congr m' m a 8 h]

theorem island_frame_kept {x y : X86.State} (hf : FrameFacts S x)
    (hk : ∀ b, IslandKept S x b → y.mem b = x.mem b) (hb : y.reg .rbp = x.reg .rbp)
    (hsv : ∀ i, Saved S.c.mode.pe i → i ≠ 5 → y.regs i = x.regs i) : FrameFacts S y := by
  refine ⟨by rw [hb]; exact hf.rbp, ?_, ?_, fun i hi h5 => by rw [hsv i hi h5]; exact hf.saved i hi h5⟩
  · rw [hb, island_read64_kept (fun i hi => hk _ (Or.inr (Or.inr (Or.inr ⟨i, hi, Or.inl rfl⟩))))]
    exact hf.retAddr
  · intro hfp3
    rw [hb, island_read64_kept (fun i hi => hk _ (Or.inr (Or.inr (Or.inr ⟨i, hi, Or.inr rfl⟩))))]
    exact hf.savedRbp hfp3

theorem island_nop_bytes {c : Cursor} {p : Nat} (h : c.code[p]? = some 0x90) :
    (atPos c p).bytes 1 = some (nops.getD 1 []) := by
  obtain ⟨hp, he⟩ := getElem?_eq_some_iff.1 h
  simp only [Cursor.bytes, atPos, show p + 1 ≤ c.code.size by omega, ↓reduceIte, Option.some.injEq]
  apply List.ext_getElem
  · simp [nops]; omega
  · intro i h1 h2
    have hn : nops.getD 1 [] = [0x90] := rfl
    simp only [hn, List.length_singleton] at h2 ⊢
    have : i = 0 := by omega
    subst this
    simpa using he

/-! #### The call's start in either frame form -/

/-- The template's entry on the real state (`rbp := r`, the caller's without a frame pointer):
`IslandAt` of the virtual one (`rbp = fp`) with the frame relation read with `rbp := fp`. -/
theorem isl_atB {ctx : Ctx} {pe : Bool} {isl fp : Nat} {ops : List Int} {st : OpSem.State}
    {w : R.World} {x : X86.State} (h : Island.IslandAt ctx pe isl fp ops st w x) (r : BitVec 64) :
    Island.IslandAtB ctx pe isl fp ops st w (x.setReg .rbp r) := by
  have h1 : (Island.islandRegs pe).1 ≠ .rbp := by cases pe <;> decide
  have h2 : (Island.islandRegs pe).2 ≠ .rbp := by cases pe <;> decide
  refine ⟨h.target, (Handler.setRbp_reg x r _ h1).trans h.fpArg, ?_, ?_, h.world⟩
  · rw [Handler.setRbp_reg x r _ h2]; exact h.ops
  · rw [vt_setReg_setReg, ← h.rbp, X86.State.setReg_reg_self]; exact h.frame

/-- The return address is the call site's end: the call (`callMem`) is 6 bytes in either form. -/
theorem isl_site6 {mode : Ryo.Obj.Mode} {fb : FForm} {isl o p q s1 : Nat}
    (hq : q = p + codeSize ((Island.islandPre mode isl o).map (FForm.item fb)))
    (hs : s1 = p + codeSize ([fpItem (Island.islandRegs mode.pe).1 mode,
      .lea (Island.islandRegs mode.pe).2 (.ro o)].map (FForm.item fb))) : q = s1 + 6 := by
  have e : Island.islandPre mode isl o = [fpItem (Island.islandRegs mode.pe).1 mode,
      .lea (Island.islandRegs mode.pe).2 (.ro o)] ++ [Item.callMem (.sym isl)] := rfl
  have h6 : codeSize ([Item.callMem (.sym isl)].map (FForm.item fb)) = 6 := by cases fb <;> rfl
  rw [hq, hs, e, List.map_append, codeSize_append, h6, Nat.add_assoc]

/-- Without a frame pointer (so not PE): `lea rdi, [rsp + F]; lea rsi, [rip + ops]; call [sym]`,
fetched from memory at `p`, run on the virtual state (`steps_of_run_last_fb`). -/
theorem isl_pre_sp_steps {ctx : Ctx} {mode : Ryo.Obj.Mode} (hm : mode.framePointer = false)
    (hpe : mode.pe = false) {F : BitVec 32} {isl o p : Nat} {x xv' : X86.State}
    (hd : ∀ i ∈ Island.islandPre mode isl o, i.SpDispOk F)
    (hc : CodeAt ctx x.mem ((Island.islandPre mode isl o).map (FForm.item (some F))) p)
    (hrip : x.rip = addrAt ctx p)
    (he : execItems ctx (Island.islandPre mode isl o)
      (FForm.virtAt (some F) (Island.islandPre mode isl o) x) = .ok xv') :
    Steps ctx x (xv'.setReg .rbp (x.reg .rbp)) := by
  have e : Island.islandPre mode isl o =
      [Item.leaM .rdi (M.frame 0), Item.lea .rsi (.ro o)] ++ [Item.callMem (.sym isl)] := by
    simp only [Island.islandPre, Island.islandRegs, hpe, fpItem, hm, Bool.false_eq_true,
      ↓reduceIte]
    all_goals rfl
  rw [e] at hd hc he
  have hft : ∀ i ∈ [Item.leaM .rdi (M.frame 0), Item.lea .rsi (.ro o)],
      i.FallsThrough ctx ∧ i.MemKept ctx := by
    intro i hi
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
    rcases hi with rfl | rfl <;>
      exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
        fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩
  exact steps_of_run_last_fb (fb := some F)
    (items := [Item.leaM .rdi (M.frame 0), Item.lea .rsi (.ro o)]) (j := Item.callMem (.sym isl))
    (S := InCode ctx (([Item.leaM .rdi (M.frame 0), Item.lea .rsi (.ro o)] ++
      [Item.callMem (.sym isl)]).map (FForm.item (some F))) p)
    (fun i hi => by
      simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
        or_false] at hi
      rcases hi with rfl | rfl | rfl <;> rfl)
    (fun F' hF' => by cases hF'; exact hd)
    (fun i hi => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
      rcases hi with rfl | rfl <;>
        (intro s a; first | rfl | (simp only [Item.exec]; split <;> rfl)))
    (fun m h => by first | cases h | (simp [Item.mem?] at h))
    (fun i hi => by
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
      rcases hi with rfl | rfl <;>
        (intro y y' h
         cases Switch.except_ok_inj h
         simp [X86.State.rsp, X86.State.reg, X86.State.setReg, X86.State.jump]))
    (by
      simp only [List.cons_append, List.nil_append, List.map_cons, List.map_nil]
      exact ⟨⟨fun _ _ h => (by cases h), .inr ⟨.leaM .rdi (M.frame 0), F, rfl, rfl⟩⟩,
        ⟨fun _ _ h => (by cases h), .inl rfl⟩, ⟨fun _ _ h => (by cases h), .inl rfl⟩, trivial⟩)
    hc hrip (fun _ h => h) (fetchRun_of_forall hft _) he

/-- The island call's start in either frame form (as `hdl_vstart`): the virtual state `xv` the
setup runs from (with a frame pointer the state itself; without one `rbp := rsp + F`, `rip`
shifted, `FForm.virtAt`), the real `rbp` `r`, the fetch of the setup and the call to the real
state after, and the way back from the virtual relation to the real one. -/
theorem isl_vstart (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {s : R.RState} {xr : X86.State} {p q isl o : Nat} (hfR : FrameInvR S s xr)
    (hrip : xr.rip = addrAt S.ctx p)
    (hd : Dec (atPos S.body p) p (Island.islandPre S.c.mode isl o) q) (hbd : Boundary S.rs p) :
    ∃ (xv : X86.State) (r : BitVec 64), FrameInv S s xv ∧
      xv.rip + BitVec.ofNat 64 (codeSize (Island.islandPre S.c.mode isl o)) = addrAt S.ctx q ∧
      (∀ x1, execItems S.ctx (Island.islandPre S.c.mode isl o) xv = .ok x1 →
        x1.reg .rbp = xv.reg .rbp → Steps S.ctx xr (x1.setReg .rbp r)) ∧
      (∀ (y : X86.State) (s' : R.RState), y.rsp = xv.rsp → y.reg .rbp = r →
        FrameInv S s' (y.setReg .rbp (xv.reg .rbp)) → FrameInvR S s' y) := by
  cases hsp : S.body.spFrame with
  | none =>
    have hvx : S.virt xr = xr := S.virt_eq hsp
    have hfx : FrameInv S s xr := by have := hfR.1; rwa [hvx] at this
    have hlk : LinkOk S.ctx xr.mem (atPos S.body p) S.rs :=
      ⟨hfx.code.fields, hfx.code.sorted, hfx.code.loaded, hfx.code.small, hsp⟩
    obtain ⟨hca, hend, -⟩ := hlk.dec hd hbd
    refine ⟨xr, xr.reg .rbp, hfx, ?_, ?_, ?_⟩
    · rw [hrip, addrAt_add', hend]
    · intro x1 he hr1
      rw [← hr1, X86.State.setReg_reg_self]
      exact island_pre_steps hca hrip he
    · intro y s' _ hy2 hfi
      refine ⟨?_, rbpOk_of_sp hsp⟩
      rw [S.virt_eq hsp]
      rw [← hy2, X86.State.setReg_reg_self] at hfi
      exact hfi
  | some F =>
    have hfpm : S.c.mode.framePointer = false := vt_nofp_of_sp hfR.1 hsp
    obtain ⟨-, hnpe⟩ := vt_fpArg_of_nofp hD.modeValid hfpm
    have hvx : ∀ y, S.virt y = FForm.virt (some F) y := fun y => by
      unfold Setup.virt Setup.fb; rw [hsp]
    have hsp' : (atPos S.body p).spFrame = some F := hsp
    obtain ⟨hca, hend, -⟩ := (hfR.1.code.atPos p).dec hd hbd
    rw [hsp', setup_virt_mem] at hca
    rw [hsp'] at hend
    refine ⟨FForm.virtAt (some F) (Island.islandPre S.c.mode isl o) xr, xr.reg .rbp, ?_, ?_, ?_,
      ?_⟩
    · have := hfR.1
      rw [hvx] at this
      exact this.congr rfl rfl rfl
    · show xr.rip + FForm.delta (some F) (Island.islandPre S.c.mode isl o) +
        BitVec.ofNat 64 (codeSize (Island.islandPre S.c.mode isl o)) = addrAt S.ctx q
      rw [hrip, FForm.delta, BitVec.add_assoc, BitVec.sub_add_cancel, addrAt_add', hend]
    · intro x1 he _
      exact isl_pre_sp_steps hfpm hnpe (H.spDisp F hsp (atPos S.body p) rfl hsp p _ _ hd) hca
        hrip he
    · intro y s' hy1 hy2 hfi
      refine ⟨?_, fun h => hy2.trans (hfR.2 h)⟩
      have e1 : (FForm.virtAt (some F) (Island.islandPre S.c.mode isl o) xr).reg .rbp =
          xr.rsp + F.setWidth 64 := X86.State.reg_setReg xr .rbp (xr.rsp + F.setWidth 64)
      have e2 : (FForm.virtAt (some F) (Island.islandPre S.c.mode isl o) xr).rsp = xr.rsp :=
        Handler.setRbp_rsp xr (xr.rsp + F.setWidth 64)
      rw [hvx y]
      show FrameInv S s' (y.setReg .rbp (y.rsp + F.setWidth 64))
      rw [hy1, e2, ← e1]
      exact hfi

/-! #### The body -/

set_option maxHeartbeats 1000000 in
/-- `island isl, ops` (`Island.island_query` and the return / unwind continuations of
`island_return`/`island_unwind` against the answers `SepAcross.island` gives, with
`DecodeLink.link_island`'s reads and `opsAt_of_opsArray`; on PE the `nop` after the call,
`NopRead`). On PE the template's 32-byte shadow space at the frame's bottom,
`[fp - F, fp - F + 32)`, lies below the link slots (`32 ≤ F`, `H.peShadow`, for
`island_kept'`); R's answer makes it `Uninit` (`R.Code.islandWrites`), so
`Island.FrameSep.islandApart` leaves it out. In either frame form (`isl_vstart`): the setup runs
on the virtual state `x`, the template from the real one (`IslandAtB`, `isl_atB`), and its
answers are read back on the virtual state (`rbp := x.reg .rbp`). -/
theorem bodySim_island (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .island) :
    BodySim S k p (S.used k) := by
  have hF32 : S.c.mode.pe = true → 32 ≤ S.F := H.peShadow
  have HI := island_hyps hD H hF32
  have hshF : S.c.islandShadow ≤ S.c.d.frameSize ∧ S.c.islandShadow ≤ 32 := by
    unfold R.Code.islandShadow; split
    · exact ⟨hF32 (by assumption), by omega⟩
    · omega
  have hshE : (S.c.islandShadow : Int) = Island.shadow S.c.mode.pe := rfl
  intro s xr hs hfR hrip hci hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨hlt, ⟨p1, ctr, hpq⟩, ⟨i, hi, hio⟩, hbd, hnop, hcache, hargs⟩ := hP
  cases hr with
  | handler _ _ _ hhh => simp only at hop; subst hop; simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | jmp => simp only at hop; exact absurd hop (by decide)
  | unreachable _ => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | dense hd =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hd
    rw [hw] at hop; cases w <;> exact absurd hop (by decide)
  | @island isl o site ws c'' hic hws =>
  -- The instruction.
  have hpk := (Array.getElem?_eq_some_iff.1 hpq).2
  have hio' := hpk ▸ hio hlt
  simp only [InsnOf] at hio'
  obtain ⟨op, ops, hof, rfl, hops⟩ := hio'
  have hops' : ops = [.sym isl, .words ws] := by
    rcases ops with _ | ⟨o1, _ | ⟨o2, _ | ⟨o3, l⟩⟩⟩ <;> simp at hops
    obtain ⟨h1, h2⟩ := hops
    cases o1 <;> simp [opndMap] at h1
    cases o2 <;> simp [opndMap] at h2
    subst h1 h2; rfl
  subst hops'
  have hf := island_ofFull hof
  have hsh := Island.island_shape
  rw [← hs] at hi
  -- The code, and the virtual state `x` the call's setup runs from (`isl_vstart`; `xr` is
  -- the real one).
  obtain ⟨hd, -⟩ := islandCall_read hic
  obtain ⟨-, hq', hbq⟩ := (hfR.code'.atPos p).dec hd hbd
  obtain ⟨hs2, hsd⟩ := island_site_read hic
  obtain ⟨-, hsite, -⟩ := (hfR.code'.atPos p).dec hsd hbd
  have hsite6 : c'.pos = site.1 + 6 := isl_site6 hq' hsite
  obtain ⟨x, r, hfi, hripE, hsteps1, hconv⟩ := isl_vstart hD H hfR hrip hd hbd
  -- The scopes.
  cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    obtain ⟨m, rfl⟩ := hsafe.1 {} e (island_step_scopes_err hi hsc)
    exact (island_noNB_scopes _ _ m hsc).elim
  | ok s1 =>
  have hstep := island_step_ok hi hf hsc
  have hk := scopes_keeps _ hsc
  rw [hk.pc, hk.fp] at hstep
  have hsafeQ := hsafe.2 {} _ s1 hstep
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hfi.win
  have hwin := hfb.window hwinT
  have hsepF : FrameSep (-(S.c.d.frameSize : Int)) S.K s.st x := hfi.sep
  have hfpF : S.c.d.frameSize ≤ s.fp := hfi.fpF
  have hrspF : x.rsp = x.reg .rbp - BitVec.ofNat 64 S.c.d.frameSize := hfi.rsp
  have hsep1 := (sep_foldlM _ (hfb.scopesIn _) hwin hfi.rrel hsepF hsc).2
  -- Numbers.
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hfp64 : s.fp < 2 ^ 64 := by omega
  have hrbpN : (x.reg .rbp).toNat = s.fp := by
    rw [hfi.rrel.rbp, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hfp64]
  have hrspN : x.rsp.toNat = s.fp - S.c.d.frameSize :=
    island_rsp_toNat hfi.rrel.rbp hfp64 hfpF hrspF
  have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by
    have := hfi.room; omega
  have hkept := HI.kept s x s1 _ hfi (vt_bInv_used hfR (by rw [hs]; exact hci)) hsc
  have hrspSh : x.rsp.toNat ≤ (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe)).toNat := by
    have hsh : Island.shadow S.c.mode.pe ≤ S.c.d.frameSize ∧ Island.shadow S.c.mode.pe ≤ 32 := by
      unfold Island.shadow; split
      · have := hF32 (by assumption); exact ⟨this, by omega⟩
      · omega
    rw [BitVec.toNat_add, BitVec.toNat_ofNat,
      Nat.mod_eq_of_lt (show Island.shadow S.c.mode.pe < 2 ^ 64 by omega), hrspN,
      Nat.mod_eq_of_lt (by omega)]
    omega
  have hnotStack : ∀ b, IslandKept S x b → ¬ InStack S.lo x.rsp b :=
    fun b hb hst => hkept b hb (Or.inl ⟨hst.1, Nat.lt_of_lt_of_le hst.2 hrspSh⟩)
  -- The operand array.
  have hroOps := opsAt_of_opsArray hfi.ro hws
  have hroA : ∀ j < 4 * (ws.length + 1),
      ¬ InStack S.lo x.rsp (S.ctx.addrOf (.ro o) - 4 + BitVec.ofNat 64 j) := by
    intro j hj
    obtain ⟨base, ha, -⟩ := hfi.ro
    obtain ⟨ho, ⟨n, hn, hnl⟩, hw⟩ := opsArray_spec hws
    apply hnotStack
    refine Or.inr (Or.inr (Or.inl ⟨o - 4 + j, ?_, ?_⟩))
    · have h0 : o - 4 + 4 ≤ S.ro.size := by
        unfold rdLE at hn; split at hn
        · omega
        · cases hn
      rcases Nat.eq_zero_or_pos ws.length with hl | hl
      · omega
      · have := hw (ws.length - 1) (by omega)
        unfold rdLE at this; split at this
        · omega
        · cases this
    · rw [ha, ha]
      have e : BitVec.ofNat 64 o = BitVec.ofNat 64 (o - 4) + 4 := by
        rw [show (4 : BitVec 64) = BitVec.ofNat 64 4 from rfl, ← BitVec.ofNat_add,
          Nat.sub_add_cancel ho]
      rw [e, BitVec.ofNat_add]
      bv_omega
  have hsym := HI.syms s x hfi
  have hap : Handler.StackApart S.lo s1.st x :=
    Handler.FrameSep.stackApart hsep1
      (Handler.stack_off_window (by rw [hrbpN, hrspN]; omega) (by rw [hrbpN]; omega))
      (HI.allocs s x s1 hfi hsc)
  obtain ⟨x1, -, hex, hat, hrr1, -, -, -, -, hrsp1, hret1, hsv1, hmemS⟩ :=
    Island.island_query S.ctx hi hf hsh hfi.rrel hfi.mem (hfb.scope_size _) hrspF hlo hroOps
      hroA hsym hstep hap
  have hrbp1 : x1.reg .rbp = x.reg .rbp := hat.rbp.trans hfi.rrel.rbp.symm
  -- The lends.
  have hlendsIn : ∀ l ∈ S.c.lendsAt s.pc, -(S.c.d.frameSize : Int) ≤ l.1 ∧ l.1 + l.2 ≤ S.K := by
    intro l hl
    obtain ⟨sc, hsc', rfl⟩ := island_lends_mem hl
    exact hfb.scopes s.pc sc hsc'
  have hlends : ∀ l ∈ S.c.lendsAt s.pc, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62 := by
    intro l hl
    have := hlendsIn l hl; have := hfb.F_le; have := hfb.K_le
    omega
  have hFle : (S.c.d.frameSize : Int) ≤ 2 ^ 31 := hfb.F_le
  have hshB : -2 ^ 62 < -(S.c.d.frameSize : Int) ∧
      -(S.c.d.frameSize : Int) + S.c.islandShadow < 2 ^ 62 := ⟨by omega, by omega⟩
  -- The template's writes below `fp - F + shadow`: only the shadow space, which R's answer
  -- makes `Uninit`, is left out.
  have hiap : Island.IslandApart S.Owned S.lo (x1.rsp + 8 + BitVec.ofNat 64
      (Island.shadow S.c.mode.pe)) s1.fp (S.c.lendsAt s.pc)
      (-(S.c.d.frameSize : Int), S.c.islandShadow) s1.st := by
    rw [hrsp1, hk.fp]
    have hrspT : (x.rsp + BitVec.ofNat 64 (Island.shadow S.c.mode.pe)).toNat ≤
        x.rsp.toNat + Island.shadow S.c.mode.pe := by
      rw [BitVec.toNat_add, BitVec.toNat_ofNat]
      exact Nat.le_trans (Nat.mod_le _ _) (Nat.add_le_add_left (Nat.mod_le _ _) _)
    refine Island.FrameSep.islandApart hsep1 ⟨by omega, hwin.hi_le, hwin.top⟩ (by omega)
      hfi.rrel.rbp (by omega) ?_ hlends
      (fun o h1 h2 => HI.owned s x hfi o (by have eF : (S.F : Int) = S.c.d.frameSize := rfl; omega) h2)
    intro o h1 _ hn
    have hn' : ¬ (-(S.c.d.frameSize : Int) ≤ o ∧
        o < -(S.c.d.frameSize : Int) + S.c.islandShadow) := hn
    omega
  have hi1 : S.c.d.insns[s1.pc]? = some (.native op [.sym isl, .words ws]) := by
    rw [hk.pc]; exact hi
  have hretA : x1.mem.read64 x1.rsp = addrAt S.ctx c'.pos := by
    rw [hret1]; exact hripE
  -- The template, entered on the real state (`rbp = r`).
  have hatB := isl_atB hat r
  have hx1b : (x1.setReg .rbp r).setReg .rbp (x.reg .rbp) = x1 := by
    rw [vt_setReg_setReg, ← hrbp1, X86.State.setReg_reg_self]
  have hx1rsp : (x1.setReg .rbp r).rsp = x1.rsp := Handler.setRbp_rsp x1 r
  have hx1rbp : (x1.setReg .rbp r).reg .rbp = r := X86.State.reg_setReg x1 .rbp r
  refine Reach.steps (hsteps1 _ hex hrbp1)
    (Reach.env (H.envOutside.island _ _ _ _ _ _ hatB) fun y hy => ?_)
  -- The virtual state after the template, `rbp := x.reg .rbp` (`yv` below).
  have hyvm : (y.setReg .rbp (x.reg .rbp)).mem = y.mem := rfl
  have hyvx : (y.setReg .rbp (x.reg .rbp)).xmm = y.xmm := rfl
  have hyvrip : (y.setReg .rbp (x.reg .rbp)).rip = y.rip := rfl
  have hyvrsp : (y.setReg .rbp (x.reg .rbp)).rsp = y.rsp := Handler.setRbp_rsp y _
  have hyv5 : ∀ z : X86.State, z.regs = y.regs →
      (z.setReg .rbp (x.reg .rbp)).regs = (y.setReg .rbp (x.reg .rbp)).regs := fun z hz => by
    funext i
    show (if i = Reg.rbp.idx then _ else z.regs i) = (if i = Reg.rbp.idx then _ else y.regs i)
    rw [hz]
  have hzrsp : ∀ z : X86.State, z.regs = y.regs → z.rsp = y.rsp := fun z hz => by
    simp [X86.State.rsp, X86.State.reg, hz]
  have hzrbp : ∀ z : X86.State, z.regs = y.regs → z.reg .rbp = y.reg .rbp := fun z hz => by
    simp [X86.State.reg, hz]
  by_cases hry : y.rip = (x1.setReg .rbp r).mem.read64 (x1.setReg .rbp r).rsp
  · -- It returns.
    obtain ⟨a', hretR, hal⟩ := (H.sepAcross.island isl _ _ _ _ s1.st s1.world (x1.setReg .rbp r)
      y x hatB hsafeQ hsep1).1 ⟨hy, hry⟩
    have hyr : y.reg .rbp = r := by
      show y.regs 5 = r
      rw [hretR.saved 5 (Island.saved_rbp _)]; exact hx1rbp
    have hret0 : Island.IslandReturn S.c.mode.pe S.Owned S.lo _ _ s1.world
        ((x1.setReg .rbp r).setReg .rbp (x.reg .rbp)) (y.setReg .rbp (x.reg .rbp)) a' :=
      ⟨Island.islandEnd_setRbp _ hretR.toIslandEnd, hretR.result, by
        show y.rip = (x1.setReg .rbp r).mem.read64
          ((x1.setReg .rbp r).setReg .rbp (x.reg .rbp)).rsp
        rw [Handler.setRbp_rsp (x1.setReg .rbp r)]; exact hretR.rip, by
        show (y.setReg .rbp (x.reg .rbp)).rsp =
          ((x1.setReg .rbp r).setReg .rbp (x.reg .rbp)).rsp + 8
        rw [Handler.setRbp_rsp y, Handler.setRbp_rsp (x1.setReg .rbp r)]; exact hretR.rsp,
        Handler.setRbp_saved hretR.saved⟩
    rw [hx1b] at hret0
    have hyrip : y.rip = addrAt S.ctx c'.pos := by
      rw [hry, hx1rsp]; exact hretA
    generalize hyv : y.setReg .rbp (x.reg .rbp) = yv at hret0 hyvm hyvx hyvrip hyvrsp hyv5
    have hret' : Island.IslandReturn S.c.mode.pe S.Owned S.lo s1.fp (S.c.lendsAt s.pc) s1.world
        x1 yv a' := by rw [hk.fp]; exact hret0
    obtain ⟨st1, st, hw, hw2, hrel⟩ := Island.answer_core hret'.toIslandEnd hrr1 hlends hshB hiap
    obtain ⟨regs, hres⟩ := hret0.result
    have hmemKy : ∀ b, IslandKept S x b → yv.mem b = x.mem b := by
      intro b hb
      have hnw := hkept b hb
      rw [hret0.mem b (by rw [hrsp1]; exact hnw), hmemS b (fun h => hnw (Or.inl ⟨h.1, Nat.lt_of_lt_of_le h.2 hrspSh⟩))]
    have hrbp'' : yv.reg .rbp = x.reg .rbp := by
      show yv.regs 5 = x.regs 5
      rw [hret0.saved 5 (Island.saved_rbp _)]; exact hrbp1
    have hrbpS : yv.reg .rbp = BitVec.ofNat 64 s1.fp := by rw [hrbp'', hfi.rrel.rbp, hk.fp]
    obtain ⟨hR'', hM'', hW''⟩ := hrel yv rfl hrbpS
    have hw1 : R.writeRanges (s1.withWorld a'.world).st (S.c.lendsAt s1.pc) a'.frame = .ok st1 := by
      rw [hk.pc]; exact hw
    have hans : R.answer S.c s1 a' = .ok (.step { s1.withWorld a'.world with st, pc := s1.pc + 1 }) := by
      rw [IslandLemmas.answer_island a' hi1 hf hsh, IslandLemmas.islandWrites_ok hw1 hw2, hres]; rfl
    have hrspX : yv.rsp = x.rsp := by rw [hret0.rsp, hrsp1]
    have hsv'' : ∀ i, Saved S.c.mode.pe i → yv.regs i = x.regs i := fun i hi => by
      rw [hret0.saved i hi, hsv1 i hi]
    have hsepW : FrameSep (-(S.c.d.frameSize : Int)) S.K (s1.withWorld a'.world).st yv :=
      FrameSep.extend hsep1 hrbp'' rfl hal.1 hsep1.init hal.2.1 hal.2.2
    have hsep'' := island_sep_writeFrame (island_sep_writeRanges hsepW hlendsIn hw) hw2
      (Int.le_refl _) (by rw [List.length_replicate]; omega)
    have hpc'' : s1.pc + 1 = k + 1 := by rw [hk.pc, hs]
    have hlkyF := island_link_keptF hfi.code hmemKy
    have hFI : FrameInv S { s1.withWorld a'.world with st, pc := s1.pc + 1 } yv := by
      refine ⟨⟨hR'', hrbpS, hW''⟩, hM'', hsep'', by show (s1.fp : Int) + _ ≤ _; rw [hk.fp]; exact hwinT,
        by show S.c.d.frameSize ≤ s1.fp; rw [hk.fp]; exact hfpF,
        by rw [hrspX, hrbp'']; exact hrspF, by rw [hrspX]; exact hfi.room,
        hlkyF, island_ro_kept hfi.ro hmemKy, ?_,
        island_frame_kept hfi.frame hmemKy hrbp'' (fun i hi _ => hsv'' i hi),
        (((H.slots_scopes hfi hsc).congr (st' := (s1.withWorld a'.world).st) rfl
          (fun _ _ _ => rfl)).writeRanges hw (Discharge.PeStackArg.miss_of_ge
            (Discharge.PeStackArg.lends_lo H.boundsOk s.pc))).writeFrame_uninit hw2,
        (((hfi.esc.scopes hsc).mono (pc' := s1.pc + 1) (fun h => hk.pc ▸ LeadArg.prev hD h)
          (by have := hk.pc; omega)).congr
          (by rw [writeFrame_escaped hw2, Discharge.EscFrom.writeRanges_escaped hw]; rfl) :)⟩
      rintro ⟨hlt', ha⟩
      change s1.pc + 1 < S.r.protos.size at hlt'
      change S.args (s1.pc + 1 + 1) = true at ha
      rw [hpc''] at hlt' ha
      have hia : (Full.Opcode.island == Full.Opcode.arg) = false := by decide
      have h1 : S.args (k + 1) = false := by rw [hargs, hop, hia, Bool.and_false]
      have h2 := hD.argsSucc (k + 1) (by simpa using hlt')
      rw [h1] at h2
      simp [h2] at ha
    have fin : ∀ z : X86.State, z.regs = y.regs → z.xmm = y.xmm → z.mem = y.mem →
        z.rip = addrAt S.ctx (S.start (k + 1)) → Reach S.ctx S.E (SNext S s) z := by
      intro z hzr hzx hzm hzrip
      have hzFI : FrameInv S { s1.withWorld a'.world with st, pc := s1.pc + 1 }
          (z.setReg .rbp (x.reg .rbp)) :=
        hFI.congr (hyv5 z hzr) (by rw [hyvx]; exact hzx) (by rw [hyvm]; exact hzm)
      have hzrsp' : z.rsp = x.rsp := by rw [hzrsp z hzr, ← hyvrsp]; exact hrspX
      have hzrbp' : z.reg .rbp = r := (hzrbp z hzr).trans hyr
      refine .done (.inl ⟨_, .answer hstep hans, ⟨hconv z _ hzrsp' hzrbp' hzFI, .inl ⟨?_, ?_⟩⟩⟩)
      · change z.rip = addrAt S.ctx (S.start (s1.pc + 1))
        rw [hpc'']; exact hzrip
      · change CacheInv (S.cache (s1.pc + 1)) (S.virt z)
        rw [hpc'', hcache]; exact CacheInv.emptyPe _ _
    generalize hE : S.start (k + 1) = pE at hnop fin
    generalize hC : c'.pos = pC at hnop hyrip hbq
    cases hnop with
    | none _ => exact fin y rfl rfl rfl hyrip
    | nop hn9 hby hrl =>
      -- Only on PE, so with a frame pointer.
      have hpe : S.c.mode.pe = true := by
        simp only [nopAfter, Bool.and_eq_true] at hn9
        exact hn9.1.1
      have hfpm := vt_fp_of_pe hD.modeValid hpe
      have hlky := island_link_kept (hfi.code.toLinkOk hfpm) hmemKy
      rw [hyvm] at hlky
      obtain ⟨hit, -, -⟩ := nop_itemAt hlky (p := pC) (n := 1) (by omega) (by omega)
        (island_nop_bytes hby) hrl hbq
      refine reach_padding (ns := [1]) (by simp) ⟨hit, trivial⟩ hyrip fun z h1 h2 h3 h4 => ?_
      refine fin z h1 h2 h3 ?_
      rw [h4]; rfl
  · -- It unwinds.
    obtain ⟨a', exc, hres, hendR, hlandR, hal⟩ := (H.sepAcross.island isl _ _ _ _ s1.st s1.world
      (x1.setReg .rbp r) y x hatB hsafeQ hsep1).2 ⟨hy, hry⟩
    have hyr : y.reg .rbp = r := by
      show y.regs 5 = r
      rw [hlandR.saved 5 (Island.saved_rbp _)]; exact hx1rbp
    have hend := Island.islandEnd_setRbp (x.reg .rbp) hendR
    have hland := Island.landed_setRbp (x.reg .rbp) hlandR
    rw [hx1b] at hend hland
    rw [hx1rsp] at hland
    generalize hyv : y.setReg .rbp (x.reg .rbp) = yv at hend hland hyvm hyvx hyvrip hyvrsp hyv5
    have hpads := (H.padsLinked hD hfi.code.small) k hlt site (by rw [hpk]; simp)
      c'.pos (by omega) (by omega)
    have hl := hland.rip
    rw [hretA, hpads] at hl
    cases hcl : S.c.cleanupAt k with
    | none => rw [hcl] at hl; cases hl
    | some e =>
    obtain ⟨pad?, cat⟩ := e
    cases pad? with
    | none => rw [hcl] at hl; cases hl
    | some pad =>
    rw [hcl] at hl
    have hyrip : yv.rip = addrAt S.ctx (posOf S.r pad) := by
      rw [← Option.some.inj hl]
      have h32 := Nat.lt_of_le_of_lt (posOf_le_size hD (pad_lpad hD hcl).1) hfi.code.small
      have e : (pos32 S.r pad).setWidth 64 = BitVec.ofNat 64 (posOf S.r pad) := by
        apply BitVec.eq_of_toNat_eq
        rw [BitVec.toNat_setWidth, pos32, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
          Nat.mod_eq_of_lt h32]
      rw [e]; rfl
    have hpad' : S.c.cleanupAt s1.pc = some (some pad, cat) := by rw [hk.pc, hs]; exact hcl
    have hend' : Island.IslandEnd S.c.mode.pe S.Owned S.lo s1.fp (S.c.lendsAt s.pc) s1.world
        x1 yv a' := by rw [hk.fp]; exact hend
    obtain ⟨st1, st, hw, hw2, hrel⟩ := Island.answer_core hend' hrr1 hlends hshB hiap
    have hmemKy : ∀ b, IslandKept S x b → yv.mem b = x.mem b := by
      intro b hb
      have hnw := hkept b hb
      rw [hend.mem b (by rw [hrsp1]; exact hnw), hmemS b (fun h => hnw (Or.inl ⟨h.1, Nat.lt_of_lt_of_le h.2 hrspSh⟩))]
    have hrbpY : yv.reg .rbp = x.reg .rbp := by
      show yv.regs 5 = x.regs 5
      rw [hland.saved 5 (Island.saved_rbp _)]; exact hrbp1
    have hrbpS : yv.reg .rbp = BitVec.ofNat 64 s1.fp := by rw [hrbpY, hfi.rrel.rbp, hk.fp]
    obtain ⟨hR1, hM1, hW1⟩ := hrel yv rfl hrbpS
    have hw1 : R.writeRanges (s1.withWorld a'.world).st (S.c.lendsAt s1.pc) a'.frame = .ok st1 := by
      rw [hk.pc]; exact hw
    have hans : R.answer S.c s1 a' = .ok (.step { s1.withWorld a'.world with
        st := { st with exception := exc }, pc := pad }) := by
      rw [IslandLemmas.answer_island a' hi1 hf hsh, IslandLemmas.islandWrites_ok hw1 hw2, hres]
      simp only [bind, Except.bind]
      unfold R.unwindAt
      simp only [R.RState.withWorld, hpad']
      rfl
    have hrspX : yv.rsp = x.rsp := by rw [hland.rsp, hrsp1]
    have hsvY : ∀ i, Saved S.c.mode.pe i → yv.regs i = x.regs i := fun i hi => by
      rw [hland.saved i hi, hsv1 i hi]
    have hsepW : FrameSep (-(S.c.d.frameSize : Int)) S.K (s1.withWorld a'.world).st yv :=
      FrameSep.extend hsep1 hrbpY rfl hal.1 hsep1.init hal.2.1 hal.2.2
    have hsepY := island_sep_writeFrame (island_sep_writeRanges hsepW hlendsIn hw) hw2
      (Int.le_refl _) (by rw [List.length_replicate]; omega)
    have hFIu : FrameInv S { s1.withWorld a'.world with
        st := { st with exception := exc }, pc := pad } yv := by
      refine ⟨⟨⟨hR1.frame, hR1.layout, hR1.zeroSized⟩, hrbpS, ⟨hW1.idLt, hW1.idInj, hW1.size, hW1.disj⟩⟩, hM1,
        ⟨hsepY.own, hsepY.init, hsepY.dis, hsepY.space, hsepY.esc⟩,
        by show (s1.fp : Int) + _ ≤ _; rw [hk.fp]; exact hwinT,
        by show S.c.d.frameSize ≤ s1.fp; rw [hk.fp]; exact hfpF,
        by rw [hrspX, hrbpY]; exact hrspF, by rw [hrspX]; exact hfi.room,
        island_link_keptF hfi.code hmemKy, island_ro_kept hfi.ro hmemKy, ?_,
        island_frame_kept hfi.frame hmemKy hrbpY (fun i hi _ => hsvY i hi),
        ((((H.slots_scopes hfi hsc).congr (st' := (s1.withWorld a'.world).st) rfl
            (fun _ _ _ => rfl)).writeRanges hw (Discharge.PeStackArg.miss_of_ge
              (Discharge.PeStackArg.lends_lo H.boundsOk s.pc))).writeFrame_uninit hw2).congr
            (st' := { st with exception := exc }) rfl (fun _ _ _ => rfl),
        ((hfi.esc.scopes hsc).of_not (HI.padArgs k pad cat hcl)).congr
          (st' := { st with exception := exc })
          (by rw [writeFrame_escaped hw2, Discharge.EscFrom.writeRanges_escaped hw]; rfl)⟩
      intro h
      exact absurd h (HI.padArgs k pad cat hcl)
    -- Back on the real state.
    have hrspR : y.rsp = x.rsp := by rw [← hyvrsp]; exact hrspX
    have hyripR : y.rip = addrAt S.ctx (posOf S.r pad) := by rw [← hyvrip]; exact hyrip
    refine .done (.inl ⟨_, .answer hstep hans,
      ⟨hconv y _ hrspR hyr (by rw [hyv]; exact hFIu), .inr ⟨hyripR, ?_⟩⟩⟩)
    change CacheInv (S.used pad) (S.virt y)
    rw [(H.cacheCleared hD).pads k pad cat hcl]; exact CacheInv.emptyPe _ _

end Insn

end Ryo.Proofs.DecodeSound
