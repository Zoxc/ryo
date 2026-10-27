import Ryo.Proofs.DecodeSound
import Ryo.Proofs.NoArgCursor

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

/-- R errors that are not `noBehavior`. -/
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
    site.2 = 6 ∧ Dec c c.pos ([fpItem (Island.islandRegs fr.mode.pe).1 fr.mode,
      .lea (Island.islandRegs fr.mode.pe).2 (.ro ops)] ++
      (if fr.mode.pe then [Item.subRsp 32] else [])) site.1 := by
  unfold islandCall at h
  obtain ⟨at_, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  cases hpe : fr.mode.pe <;> rw [hpe] at h <;> simp (config := { zeta := false }) only [Bool.false_eq_true, ↓reduceIte] at h
  all_goals
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
  · obtain ⟨st, c3, h3, h⟩ := bind_ok h
    obtain ⟨rfl, hc3⟩ := pos_run' h3
    subst c3
    obtain ⟨y, c4, h4, h⟩ := bind_ok h
    split at h
    case h_2 => exact (err_ok h).elim
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    refine ⟨rfl, ?_⟩
    simp only [Island.islandRegs, hpe, Bool.false_eq_true, ↓reduceIte, List.append_nil,
      Frame.fp] at d1 ⊢
    rw [e1] at d2
    exact d1.trans' d2
  · obtain ⟨c3, d3, e3, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
    obtain ⟨st, c5, h5, h⟩ := bind_ok h
    obtain ⟨rfl, hc5⟩ := pos_run' h5
    subst c5
    obtain ⟨y, c4, h4, h⟩ := bind_ok h
    split at h
    case h_2 => exact (err_ok h).elim
    obtain ⟨c6, d6, e6, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    refine ⟨rfl, ?_⟩
    simp only [Island.islandRegs, hpe, ↓reduceIte, Frame.fp] at d1 ⊢
    rw [e1] at d2; rw [e2, e1] at d3
    have := (d1.trans' d2).trans' d3
    simpa using this

theorem island_pre_steps {ctx : Ctx} {mode : Ryo.Obj.Mode} (hfpm : mode.framePointer = true)
    {isl o p : Nat} {x x1 : X86.State}
    (hc : CodeAt ctx x.mem (Island.islandPre mode isl o) p) (hrip : x.rip = addrAt ctx p)
    (he : execItems ctx (Island.islandPre mode isl o) x = .ok x1) : Steps ctx x x1 := by
  have c : ∀ (i : Item) (p : Nat), i.wf (BitVec.ofNat 32 p) = true →
      (∀ b e, i ≠ .tableEntry b e) → i.Canonical p := fun _ _ hw ht => ⟨ht, .inl hw⟩
  unfold Island.islandPre at hc he
  simp only [fpItem, hfpm, ↓reduceIte] at hc he
  cases hpe : mode.pe <;> simp only [hpe, Island.islandRegs, Bool.false_eq_true, ↓reduceIte,
    List.append_nil] at hc he
  · refine steps_of_run_last (items := [.mov .rdi .rbp, .lea .rsi (.ro o)])
      (j := .callMem (.sym isl)) ?_ hc hrip (fun _ h => h) ?_ he
    · refine ⟨c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, trivial⟩ <;> intro _ _ h <;> cases h
    · refine fetchRun_of_forall (fun j hj => ?_) x
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      rcases hj with rfl | rfl <;>
        exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
          fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩
  · refine steps_of_run_last (items := [.mov .rcx .rbp, .lea .rdx (.ro o), .subRsp 32])
      (j := .callMem (.sym isl)) ?_ hc hrip (fun _ h => h) ?_ he
    · refine ⟨c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, trivial⟩ <;>
        intro _ _ h <;> cases h
    · refine fetchRun_of_forall (fun j hj => ?_) x
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      rcases hj with rfl | rfl | rfl <;>
        exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
          fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩

theorem island_post_steps {ctx : Ctx} {mode : Ryo.Obj.Mode} {p : Nat} {y y' : X86.State}
    (hc : CodeAt ctx y.mem (Island.islandPost mode) p) (hrip : y.rip = addrAt ctx p)
    (he : execItems ctx (Island.islandPost mode) y = .ok y') : Steps ctx y y' := by
  unfold Island.islandPost at hc he
  cases hpe : mode.pe <;> simp only [hpe, Bool.false_eq_true, ↓reduceIte] at hc he
  · cases he; exact .refl _
  · have hcan : Canon [Item.addRsp 32] p := ⟨⟨fun _ _ h => (nomatch h), Or.inl rfl⟩, trivial⟩
    have hrun : FetchRun ctx (fun _ => True) [Item.addRsp 32] y := by
      refine fetchRun_of_forall (fun j hj => ?_) y
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      subst hj
      exact ⟨fun _ _ h => by cases Switch.except_ok_inj h; rfl,
        fun _ _ h => by cases Switch.except_ok_inj h; rfl⟩
    exact (steps_of_run hcan hc hrip (fun _ _ => trivial) hrun he).1

/-! #### The island's extra hypotheses -/

/-- The bytes a template must leave alone: the code (its bytes and relocated fields), the
rodata, and the frame's link slots at `x`'s `rbp` (return address, saved `rbp`, PE's saved
`rsi`/`rdi`). -/
def IslandKept (S : Setup) (x : X86.State) (b : BitVec 64) : Prop :=
  (∃ j, j < S.body.code.size ∧ b = addrAt S.ctx j) ∨
  (∃ r ∈ S.rs.toList, ∃ k, k < 4 ∧ b = addrAt S.ctx (r.pos + k)) ∨
  (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j)) ∨
  (∃ i, i < 8 ∧ (b = x.reg .rbp + 8 + BitVec.ofNat 64 i ∨ b = x.reg .rbp + BitVec.ofNat 64 i ∨
    (S.c.mode.pe = true ∧ (b = x.reg .rbp - 16 + BitVec.ofNat 64 i ∨
      b = x.reg .rbp - 8 + BitVec.ofNat 64 i))))

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
  kept : ∀ s x s1, FrameInv S s x → CacheInv (S.used s.pc) x →
    (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 →
    ∀ b, IslandKept S x b →
      ¬ Island.IslandMayWrite S.Owned S.lo x.rsp s.fp (S.c.lendsAt s.pc) s1.world b
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

/-- Live allocations stay off the stack below `rsp` across the scopes. Proof idea:
`EnvApart.allocs` before them; an `Escape` allocates at `fp + off` with the scope in the window
(`FrameBounds.scopes`), at or above `rsp = fp - F` and below `fp + K ≤ 2^64` (`FrameInv.win`),
so not `InStack`; `End` only frees. Induction over `foldlM` (`R.applyScope`, `R.escape`). -/
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
/-- A template leaves the code, the rodata and the link slots alone. Proof idea: unfold
`IslandMayWrite`: below `rsp ≤ x0.rsp` (`ctr_rsp_le`-style from `FrameFacts`) the code, rodata
are not (`CodeApart`), the link slots are above `rsp`; a `Lend` extent is in the window
(`FrameBounds.scopes`), the code and rodata are not (`CodeApart`'s window clause, `fpAddr_eq`),
the link slots in none (`LinkPrivate`); a live allocation of `s1`: the code and rodata are in
none (`CodeApart`: the allocations of `s1` are `s`'s or the scopes', in the window), the link
slots are private (`LinkPrivate`), so in none (`FrameOwn` after the scopes); runtime-owned: not
the code or rodata (`CodeApart`), not the window (`EnvApart.window`). The relocated fields are
code bytes (`RelocsIn`). -/
theorem island_kept' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {s s1 : R.RState} {x : X86.State} (hf : FrameInv S s x)
    (hci : CacheInv (S.used s.pc) x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) (b : BitVec 64)
    (hb : IslandKept S x b) :
    ¬ Island.IslandMayWrite S.Owned S.lo x.rsp s.fp (S.c.lendsAt s.pc) s1.world b := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hfb := H.frameBounds
  have hFle : (S.F : Int) ≤ 2 ^ 31 := hfb.F_le
  have hKle := hfb.K_le
  have hrsp := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
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
  have hbi : BInv S s (x.jump (addrAt S.ctx (posOf S.r s.pc))) :=
    ⟨hf.congr rfl rfl rfl, .inr ⟨rfl, hci⟩⟩
  -- A code or rodata byte.
  have hcode : ∀ b, ((∃ p, p < S.body.code.size ∧ b = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j))) →
      ¬ Island.IslandMayWrite S.Owned S.lo x.rsp s.fp (S.c.lendsAt s.pc) s1.world b := by
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
  · -- A link slot: `fp + o` with `o ∈ [linkLo, 16)`.
    obtain ⟨o, ho1, ho2, rfl⟩ : ∃ o : Int, S.linkLo ≤ o ∧ o < 16 ∧ b = fpAddr x o := by
      have e : ∀ c : Int, x.reg .rbp + BitVec.ofInt 64 c + BitVec.ofNat 64 i =
          fpAddr x (c + i) := fun c => by
        simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
      rcases hb with rfl | rfl | ⟨hpe, rfl | rfl⟩
      · refine ⟨8 + i, ?_, by omega, ?_⟩
        · unfold Setup.linkLo; split <;> omega
        · rw [← e]; rfl
      · refine ⟨0 + i, ?_, by omega, ?_⟩
        · unfold Setup.linkLo; split <;> omega
        · rw [← e]; simp
      · refine ⟨-16 + i, by simp only [Setup.linkLo, hpe, ite_true]; omega, by omega, ?_⟩
        have h16 : BitVec.ofInt 64 (-16) = -16 := by decide
        simp only [fpAddr, island_ofInt_add, h16]
        bv_omega
      · refine ⟨-8 + i, by simp only [Setup.linkLo, hpe, ite_true]; omega, by omega, ?_⟩
        have h8 : BitVec.ofInt 64 (-8) = -8 := by decide
        simp only [fpAddr, island_ofInt_add, h8]
        bv_omega
    have hoF : -(S.F : Int) ≤ o := by
      unfold Setup.linkLo at ho1
      split at ho1
      · have := frameSize_pe hD (by assumption); omega
      · omega
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
    (H : Hyps S) : IslandHyps S :=
  ⟨fun _ _ _ hf hsc => island_allocs' H hf hsc, H.envApart.syms,
    fun _ _ hf o h1 h2 => by rw [hf.fpAddr_eq]; exact H.envApart.window o h1 h2,
    fun _ _ _ hf hci hsc => island_kept' hD H hf hci hsc,
    fun _ _ _ hcl => pad_not_leadArg hD hcl,
    fun _ hL _ pad _ hcl => posOf_lt_32 hD hL (pad_lpad hD hcl).1⟩

theorem island_link_kept {x y : X86.State} (hc : LinkOk S.ctx x.mem S.body S.rs)
    (hk : ∀ b, IslandKept S x b → y.mem b = x.mem b) : LinkOk S.ctx y.mem S.body S.rs :=
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
    (hsv : ∀ i, CalleeSaved i → i ≠ 5 → y.regs i = x.regs i) : FrameFacts S y := by
  refine ⟨by rw [hb]; exact hf.rbp, ?_, ?_, fun hpe => ?_,
    fun i hi h5 => by rw [hsv i hi h5]; exact hf.saved i hi h5⟩
  · rw [hb, island_read64_kept (fun i hi => hk _ (Or.inr (Or.inr (Or.inr ⟨i, hi, Or.inl rfl⟩))))]
    exact hf.retAddr
  · rw [hb, island_read64_kept (fun i hi =>
      hk _ (Or.inr (Or.inr (Or.inr ⟨i, hi, Or.inr (Or.inl rfl)⟩))))]
    exact hf.savedRbp
  · rw [hb, island_read64_kept (fun i hi =>
      hk _ (Or.inr (Or.inr (Or.inr ⟨i, hi, Or.inr (Or.inr ⟨hpe, Or.inl rfl⟩)⟩)))),
      island_read64_kept (fun i hi =>
      hk _ (Or.inr (Or.inr (Or.inr ⟨i, hi, Or.inr (Or.inr ⟨hpe, Or.inr rfl⟩)⟩))))]
    exact hf.savedPe hpe

/-! #### The body -/

set_option maxHeartbeats 1000000 in
/-- `island isl, ops` (`Island.island_query` and the return / unwind continuations of
`island_return`/`island_unwind` against the answers `SepAcross.island` gives, with
`DecodeLink.link_island`'s reads and `opsAt_of_opsArray`). -/
theorem bodySim_island' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' {}) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .island) :
    BodySim S k p (S.used k) := by
  have HI := island_hyps hD H
  intro s x hs hfi hrip hci hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨hlt, ⟨p1, ctr, hpq⟩, ⟨i, hi, hio⟩, hbd, hstop, hcache, hargs⟩ := hP
  cases hr with
  | handler _ _ _ hhh => simp only at hop; subst hop; simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | jmp => simp only at hop; exact absurd hop (by decide)
  | unreachable _ => simp only at hop; exact absurd hop (by decide)
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
  -- The code.
  have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs := bs_linkOk_at hfi.code p
  obtain ⟨hd, -⟩ := islandCall_read hic
  obtain ⟨hca, hq', -⟩ := hlk.dec hd hbd
  simp only at hq'
  obtain ⟨hs2, hsd⟩ := island_site_read hic
  obtain ⟨-, hsite, -⟩ := hlk.dec hsd hbd
  simp only at hsite
  have hpre := ((codeAt_append _ _ _).1 hca).1
  have hsteps1 : ∀ x1, execItems S.ctx (Island.islandPre S.c.mode isl o) x = .ok x1 →
      Steps S.ctx x x1 := fun _ he => island_pre_steps H.fp hpre hrip he
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
  have hlo : S.lo.toNat + 8 + Island.shadow S.c.mode.pe ≤ x.rsp.toNat := by
    have := hfi.room; have := Island.shadow_le S.c.mode.pe; omega
  have hkept := HI.kept s x s1 hfi (by rw [hs]; exact hci) hsc
  have hnotStack : ∀ b, IslandKept S x b → ¬ InStack S.lo x.rsp b :=
    fun b hb hst => hkept b hb (Or.inl hst)
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
  have hiap : Island.IslandApart S.Owned S.lo (x1.rsp + 8 + BitVec.ofNat 64
      (Island.shadow S.c.mode.pe)) s1.fp (S.c.lendsAt s.pc) s1.st := by
    rw [hrsp1, hk.fp]
    exact Island.FrameSep.islandApart hsep1 hwin (by omega) hfi.rrel.rbp hfpF
      (by rw [hrspN]; exact Nat.le_refl _) hlends (HI.owned s x hfi)
  have hi1 : S.c.d.insns[s1.pc]? = some (.native op [.sym isl, .words ws]) := by
    rw [hk.pc]; exact hi
  have hretA : x1.mem.read64 x1.rsp = addrAt S.ctx (p + codeSize (Island.islandPre S.c.mode isl o)) := by
    rw [hret1, hrip, addrAt_add]; rfl
  -- The template.
  refine Reach.steps (hsteps1 _ hex) (Reach.env (H.envOutside.island _ _ _ _ _ _ hat) fun y hy => ?_)
  by_cases hry : y.rip = x1.mem.read64 x1.rsp
  · -- It returns.
    obtain ⟨a', hret, hal⟩ := (H.sepAcross.island isl _ _ _ _ s1.st s1.world x1 y x hat hsafeQ
      hsep1).1 ⟨hy, hry⟩
    have hret' : Island.IslandReturn S.c.mode.pe S.Owned S.lo s1.fp (S.c.lendsAt s.pc) s1.world
        x1 y a' := by rw [hk.fp]; exact hret
    obtain ⟨st, hw, hrel⟩ := Island.answer_core hret'.toIslandEnd hrr1 hlends hiap
    obtain ⟨regs, hres⟩ := hret.result
    have hmemKy : ∀ b, IslandKept S x b → y.mem b = x.mem b := by
      intro b hb
      have hnw := hkept b hb
      rw [hret.mem b (by rw [hrsp1]; exact hnw), hmemS b (fun h => hnw (Or.inl h))]
    obtain ⟨x'', hx, hmem, hrip'', hrsp'', hregs''⟩ := Island.exec_post S.ctx S.c.mode y
    have hmemK : ∀ b, IslandKept S x b → x''.mem b = x.mem b := fun b hb => by
      rw [hmem]; exact hmemKy b hb
    have hrbp'' : x''.reg .rbp = x.reg .rbp := by
      show x''.regs 5 = x.regs 5
      rw [hregs'' 5 (by decide), hret.saved 5 (Island.saved_rbp _)]; exact hrbp1
    have hrbpS : x''.reg .rbp = BitVec.ofNat 64 s1.fp := by rw [hrbp'', hfi.rrel.rbp, hk.fp]
    obtain ⟨hR'', hM'', hW''⟩ := hrel x'' hmem hrbpS
    have hw1 : R.writeRanges (s1.withWorld a'.world).st (S.c.lendsAt s1.pc) a'.frame = .ok st := by
      rw [hk.pc]; exact hw
    have hans : R.answer S.c s1 a' = .ok (.step { s1.withWorld a'.world with st, pc := s1.pc + 1 }) := by
      rw [IslandLemmas.answer_island a' hi1 hf hsh, hw1, hres]; rfl
    have hrspX : x''.rsp = x.rsp := by rw [hrsp'', hret.rsp, hrsp1]
    have hsv'' : ∀ i, Saved S.c.mode.pe i → x''.regs i = x.regs i := fun i hi => by
      rw [hregs'' i (Island.saved_ne_rsp hi), hret.saved i hi, hsv1 i hi]
    have hsepW : FrameSep (-(S.c.d.frameSize : Int)) S.K (s1.withWorld a'.world).st x'' :=
      FrameSep.extend hsep1 hrbp'' rfl hal.1 hsep1.init hal.2.1 hal.2.2
    have hsep'' := island_sep_writeRanges hsepW hlendsIn hw
    have hpc'' : s1.pc + 1 = k + 1 := by rw [hk.pc, hs]
    -- `islandPost` from `y`.
    have hlky := island_link_kept hfi.code hmemKy
    obtain ⟨hcay, -, -⟩ := (bs_linkOk_at hlky p).dec hd hbd
    simp only at hcay
    have hposty := ((codeAt_append _ _ _).1 hcay).2
    have hsteps2 := island_post_steps hposty (by rw [hry, hretA]; rfl) hx
    refine Reach.steps hsteps2 (.done (.inl ⟨_, .answer hstep hans, ?_⟩))
    refine ⟨⟨⟨hR'', hrbpS, hW''⟩, hM'', hsep'', by show (s1.fp : Int) + _ ≤ _; rw [hk.fp]; exact hwinT,
      by show S.c.d.frameSize ≤ s1.fp; rw [hk.fp]; exact hfpF,
      by rw [hrspX, hrbp'']; exact hrspF, by rw [hrspX]; exact hfi.room,
      island_link_kept hfi.code hmemK, island_ro_kept hfi.ro hmemK, ?_,
      island_frame_kept hfi.frame hmemK hrbp'' (fun i hi _ => hsv'' i (Or.inl hi))⟩, .inl ⟨?_, ?_⟩⟩
    · rintro ⟨hlt', ha⟩
      change s1.pc + 1 < S.r.protos.size at hlt'
      change S.args (s1.pc + 1 + 1) = true at ha
      rw [hpc''] at hlt' ha
      have hia : (Full.Opcode.island == Full.Opcode.arg) = false := by decide
      have h1 : S.args (k + 1) = false := by rw [hargs, hop, hia, Bool.and_false]
      have h2 := hD.argsSucc (k + 1) (by simpa using hlt')
      rw [h1] at h2
      simp [h2] at ha
    · change x''.rip = addrAt S.ctx (S.start (s1.pc + 1))
      rw [hpc'', hstop, hq', hrip'', hry, hretA, codeSize_append, ← Nat.add_assoc]
      simp only [addrAt_add]
      rfl
    · change CacheInv (S.cache (s1.pc + 1)) x''
      rw [hpc'', hcache]; exact CacheInv.empty _
  · -- It unwinds.
    obtain ⟨a', exc, hres, hend, hland, hal⟩ := (H.sepAcross.island isl _ _ _ _ s1.st s1.world x1 y
      x hat hsafeQ hsep1).2 ⟨hy, hry⟩
    have hsite6 : p + codeSize (Island.islandPre S.c.mode isl o) = site.1 + 6 := by
      have hc6 : codeSize [Item.callMem (.sym isl)] = 6 := rfl
      have : codeSize (Island.islandPre S.c.mode isl o) =
          codeSize ([fpItem (Island.islandRegs S.c.mode.pe).1 S.c.mode,
            .lea (Island.islandRegs S.c.mode.pe).2 (.ro o)] ++
            (if S.c.mode.pe then [.subRsp 32] else [])) + 6 := by
        unfold Island.islandPre; rw [codeSize_append, hc6]
      rw [this, hsite, Nat.add_assoc]; rfl
    have hpads := H.padsLinked k hlt site (by rw [hpk]; simp)
      (p + codeSize (Island.islandPre S.c.mode isl o)) (by omega) (by omega)
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
    have hyrip : y.rip = addrAt S.ctx (posOf S.r pad) := by
      rw [← Option.some.inj hl]
      have h32 := HI.padPos _ hfi.code k pad cat hcl
      have e : (pos32 S.r pad).setWidth 64 = BitVec.ofNat 64 (posOf S.r pad) := by
        apply BitVec.eq_of_toNat_eq
        rw [BitVec.toNat_setWidth, pos32, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
          Nat.mod_eq_of_lt h32]
      rw [e]; rfl
    have hpad' : S.c.cleanupAt s1.pc = some (some pad, cat) := by rw [hk.pc, hs]; exact hcl
    have hend' : Island.IslandEnd S.c.mode.pe S.Owned S.lo s1.fp (S.c.lendsAt s.pc) s1.world
        x1 y a' := by rw [hk.fp]; exact hend
    obtain ⟨st, hw, hrel⟩ := Island.answer_core hend' hrr1 hlends hiap
    have hmemKy : ∀ b, IslandKept S x b → y.mem b = x.mem b := by
      intro b hb
      have hnw := hkept b hb
      rw [hend.mem b (by rw [hrsp1]; exact hnw), hmemS b (fun h => hnw (Or.inl h))]
    have hrbpY : y.reg .rbp = x.reg .rbp := by
      show y.regs 5 = x.regs 5
      rw [hland.saved 5 (Island.saved_rbp _)]; exact hrbp1
    have hrbpS : y.reg .rbp = BitVec.ofNat 64 s1.fp := by rw [hrbpY, hfi.rrel.rbp, hk.fp]
    obtain ⟨hR1, hM1, hW1⟩ := hrel y rfl hrbpS
    have hw1 : R.writeRanges (s1.withWorld a'.world).st (S.c.lendsAt s1.pc) a'.frame = .ok st := by
      rw [hk.pc]; exact hw
    have hans : R.answer S.c s1 a' = .ok (.step { s1.withWorld a'.world with
        st := { st with exception := exc }, pc := pad }) := by
      rw [IslandLemmas.answer_island a' hi1 hf hsh, hw1, hres]
      simp only [bind, Except.bind]
      unfold R.unwindAt
      simp only [R.RState.withWorld, hpad']
      rfl
    have hrspX : y.rsp = x.rsp := by rw [hland.rsp, hrsp1]
    have hsvY : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i := fun i hi => by
      rw [hland.saved i hi, hsv1 i hi]
    have hsepW : FrameSep (-(S.c.d.frameSize : Int)) S.K (s1.withWorld a'.world).st y :=
      FrameSep.extend hsep1 hrbpY rfl hal.1 hsep1.init hal.2.1 hal.2.2
    have hsepY := island_sep_writeRanges hsepW hlendsIn hw
    refine .done (.inl ⟨_, .answer hstep hans, ?_⟩)
    refine ⟨⟨⟨⟨hR1.frame, hR1.layout, hR1.zeroSized⟩, hrbpS, ⟨hW1.idLt, hW1.idInj⟩⟩, hM1,
      ⟨hsepY.own, hsepY.init, hsepY.dis, hsepY.space⟩,
      by show (s1.fp : Int) + _ ≤ _; rw [hk.fp]; exact hwinT,
      by show S.c.d.frameSize ≤ s1.fp; rw [hk.fp]; exact hfpF,
      by rw [hrspX, hrbpY]; exact hrspF, by rw [hrspX]; exact hfi.room,
      island_link_kept hfi.code hmemKy, island_ro_kept hfi.ro hmemKy, ?_,
      island_frame_kept hfi.frame hmemKy hrbpY (fun i hi _ => hsvY i (Or.inl hi))⟩,
      .inr ⟨hyrip, ?_⟩⟩
    · intro h
      exact absurd h (HI.padArgs k pad cat hcl)
    · change CacheInv (S.used pad) y
      rw [H.cacheCleared.pads k pad cat hcl]; exact CacheInv.empty _

end Insn

end Ryo.Proofs.DecodeSound
