import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.NoArgCursor
import Ryo.Proofs.DSWork.Ret
import Ryo.Proofs.DSWork.Island
import Ryo.Proofs.DSWork.Arg

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

/-! ### Call steps never stop with `noBehavior` -/

/-- `m` doesn't stop with `noBehavior`. -/
def call_NoNB {α : Type} (m : OpSem.M α) : Prop := ∀ msg, m ≠ .error (.noBehavior msg)

theorem call_NoNB.ok {α : Type} (a : α) : call_NoNB (.ok a : OpSem.M α) := fun _ h => by cases h

theorem call_NoNB.pure {α : Type} (a : α) : call_NoNB (pure a : OpSem.M α) := fun _ h => by cases h

theorem call_NoNB.illFormed {α : Type} (m : String) : call_NoNB (illFormed m : OpSem.M α) :=
  fun _ h => by simp [OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h

theorem call_NoNB.ub {α : Type} (m : String) : call_NoNB (ub m : OpSem.M α) :=
  fun _ h => by simp [OpSem.ub, throw, throwThe, MonadExceptOf.throw] at h

theorem call_NoNB.bind {α β : Type} {m : OpSem.M α} {f : α → OpSem.M β} (hm : call_NoNB m)
    (hf : ∀ a, m = .ok a → call_NoNB (f a)) : call_NoNB (m >>= f) := by
  intro msg h
  cases hm' : m with
  | error e =>
    rw [hm'] at h; cases h; exact hm msg hm'
  | ok a => rw [hm'] at h; exact hf a hm' msg h

theorem call_NoNB.foldlM {α σ : Type} (f : σ → α → OpSem.M σ) (hf : ∀ s a, call_NoNB (f s a)) :
    ∀ (l : List α) (s : σ), call_NoNB (l.foldlM f s)
  | [], s => call_NoNB.pure s
  | a :: l, s => by
    simp only [List.foldlM_cons]
    exact call_NoNB.bind (hf s a) fun s' _ => call_NoNB.foldlM f hf l s'

theorem call_NoNB.mapM {α β : Type} (f : α → OpSem.M β) (hf : ∀ a, call_NoNB (f a)) :
    ∀ (l : List α), call_NoNB (l.mapM f)
  | [] => call_NoNB.pure _
  | a :: l => by
    simp only [List.mapM_cons]
    exact call_NoNB.bind (hf a) fun b _ =>
      call_NoNB.bind (call_NoNB.mapM f hf l) fun bs _ => call_NoNB.pure _

theorem call_NoNB.byteAt (st : OpSem.State) (o : Int) : call_NoNB (st.byteAt o) := by
  unfold OpSem.State.byteAt
  split
  · exact call_NoNB.pure _
  · split
    · split
      · exact call_NoNB.illFormed _
      · split
        · exact call_NoNB.pure _
        · exact call_NoNB.illFormed _
    · exact call_NoNB.illFormed _

theorem call_NoNB.readFrame (st : OpSem.State) (o : Int) (n : Nat) :
    call_NoNB (st.readFrame o n) :=
  call_NoNB.mapM _ (fun _ => call_NoNB.byteAt _ _) _

theorem call_NoNB.writeEscaped (st : OpSem.State) (o : Int) (bs : List AbstractByte) :
    call_NoNB (st.writeEscaped o bs) := by
  unfold OpSem.State.writeEscaped
  refine call_NoNB.foldlM _ (fun mem bi => ?_) _ _
  obtain ⟨b, i⟩ := bi
  dsimp only
  split
  · exact call_NoNB.pure _
  · split
    · exact call_NoNB.illFormed _
    · exact call_NoNB.pure _

theorem call_NoNB.writeFrame (st : OpSem.State) (o : Int) (bs : List AbstractByte) :
    call_NoNB (st.writeFrame o bs) := by
  unfold OpSem.State.writeFrame
  exact call_NoNB.bind (call_NoNB.writeEscaped _ _ _) fun _ _ => call_NoNB.pure _

theorem call_NoNB.frameAddr (fp : Nat) (o : Int) : call_NoNB (R.frameAddr fp o) := by
  unfold R.frameAddr
  dsimp only
  split
  · exact call_NoNB.illFormed _
  · exact call_NoNB.pure _

theorem call_NoNB.escape (s : R.RState) (o : Int) (size align : Nat) :
    call_NoNB (R.escape s o size align) := by
  unfold R.escape
  simp only
  split
  · exact call_NoNB.pure _
  split
  · exact call_NoNB.illFormed _
  refine call_NoNB.bind (call_NoNB.frameAddr _ _) fun addr _ => ?_
  split
  · exact call_NoNB.illFormed _
  split
  · exact call_NoNB.illFormed _
  exact call_NoNB.bind (call_NoNB.readFrame _ _ _) fun _ _ => call_NoNB.pure _

theorem call_NoNB.storageEnd (s : R.RState) (o : Int) (size : Nat) :
    call_NoNB (R.storageEnd s o size) := by
  unfold R.storageEnd
  exact call_NoNB.bind (call_NoNB.writeFrame _ _ _) fun _ _ => call_NoNB.pure _

theorem call_NoNB.applyScope (s : R.RState) (sc : R.Scope) : call_NoNB (R.applyScope s sc) := by
  unfold R.applyScope
  split
  · exact call_NoNB.escape _ _ _ _
  · exact call_NoNB.storageEnd _ _ _
  · exact call_NoNB.pure _

theorem call_NoNB.scopes (l : List R.Scope) (s : R.RState) : call_NoNB (l.foldlM R.applyScope s) :=
  call_NoNB.foldlM _ call_NoNB.applyScope l s

theorem call_NoNB.asPtr (bs : List AbstractByte) : call_NoNB (OpSem.asPtr bs) := by
  unfold OpSem.asPtr
  split
  · exact call_NoNB.pure _
  · exact call_NoNB.ub _

theorem call_NoNB.addrOf (st : OpSem.State) (o : Int) : call_NoNB (st.addrOf o) := by
  unfold OpSem.State.addrOf
  split
  · split
    · exact call_NoNB.pure _
    · exact call_NoNB.illFormed _
  · split
    · split
      · exact call_NoNB.pure _
      · exact call_NoNB.illFormed _
    · split
      · exact call_NoNB.pure _
      · exact call_NoNB.ub _

theorem call_NoNB.retRegs (k : Nat) (l : Bool) : call_NoNB (R.retRegs k l) := by
  unfold R.retRegs
  split
  · exact call_NoNB.pure _
  · exact call_NoNB.illFormed _

theorem call_NoNB.callee (st : OpSem.State) (f : Full.Opcode) (o : R.Opnd Nat) :
    call_NoNB (R.callee st f o) := by
  unfold R.callee
  split
  · split
    · exact call_NoNB.pure _
    · exact call_NoNB.illFormed _
  · split
    · exact call_NoNB.pure _
    · split
      · exact call_NoNB.pure _
      · exact call_NoNB.illFormed _
  · split
    · exact call_NoNB.bind (call_NoNB.readFrame _ _ _) fun _ _ =>
        call_NoNB.bind (call_NoNB.asPtr _) fun _ _ => call_NoNB.pure _
    · exact call_NoNB.illFormed _
  · exact call_NoNB.illFormed _

macro "call_nonb" : tactic => `(tactic| repeat (first
  | exact call_NoNB.pure _ | exact call_NoNB.ok _ | exact call_NoNB.illFormed _
  | exact call_NoNB.ub _ | exact call_NoNB.readFrame _ _ _ | exact call_NoNB.addrOf _ _
  | exact call_NoNB.asPtr _ | exact call_NoNB.writeFrame _ _ _
  | (refine call_NoNB.bind ?_ fun _ _ => ?_) | split))

theorem call_NoNB.argRegs (st : OpSem.State) : ∀ ws : List (BitVec 32), call_NoNB (R.argRegs st ws)
  | [] => call_NoNB.pure _
  | [_] => call_NoNB.illFormed _
  | s :: r :: rest => by
    unfold R.argRegs
    refine call_NoNB.bind (call_NoNB.argRegs st rest) fun rs _ => ?_
    simp only
    call_nonb

macro "call_nonb2" : tactic => `(tactic| repeat (first
  | exact call_NoNB.pure _ | exact call_NoNB.ok _ | exact call_NoNB.illFormed _
  | exact call_NoNB.ub _ | exact call_NoNB.readFrame _ _ _ | exact call_NoNB.addrOf _ _
  | exact call_NoNB.asPtr _ | exact call_NoNB.writeFrame _ _ _
  | exact call_NoNB.retRegs _ _ | exact call_NoNB.callee _ _ _ | exact call_NoNB.argRegs _ _
  | exact call_NoNB.frameAddr _ _ | exact call_NoNB.scopes _ _
  | (refine call_NoNB.bind ?_ fun _ _ => ?_) | split))

/-- R's step of a call: it doesn't stop with `noBehavior`, and when it succeeds it is a query. -/
theorem call_step_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) :
    call_NoNB (R.step c s ch) ∧ ∀ out, R.step c s ch = .ok out → ∃ q s', out = .ext q s' := by
  constructor
  · unfold R.step
    simp only [hi]
    refine call_NoNB.bind (call_NoNB.scopes _ _) fun s1 _ => ?_
    simp only [hf, hsh]
    call_nonb2
  · intro out h
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
    cases hrd : s1.st.readFrame (-(c.d.frameSize : Int)) (c.stackSize s1.pc) with
    | error e => simp [hrd] at h
    | ok stack =>
    simp only [hrd] at h
    split at h
    · rename_i n dst _ _
      cases hw : s1.st.writeFrame dst.toInt (List.replicate n .uninit) with
      | error e => simp [hw] at h
      | ok st' =>
        simp only [hw, pure, Except.pure, Except.ok.injEq] at h
        exact ⟨_, _, h.symm⟩
    · simp only [pure, Except.pure, Except.ok.injEq] at h
      exact ⟨_, _, h.symm⟩

/-- R's step of a tail call: it doesn't stop with `noBehavior`, and when it succeeds it ends
the function. -/
theorem tail_step_ok {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {fo : R.Opnd Nat} {ws : List (BitVec 32)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [fo, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .tailCall) :
    call_NoNB (R.step c s ch) ∧ ∀ out, R.step c s ch = .ok out → ∃ fin, out = .done fin := by
  constructor
  · unfold R.step
    simp only [hi]
    refine call_NoNB.bind (call_NoNB.scopes _ _) fun s1 _ => ?_
    simp only [hf, hsh]
    call_nonb2
  · intro out h
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
    simp only [hrd, pure, Except.pure, Except.ok.injEq] at h
    exact ⟨_, h.symm⟩

/-- Under `RSafe`, R's step of a call is a query. -/
theorem call_step_ext {Safe : R.Query → Prop} {c : R.Code} {s : R.RState} {op : Reduced.Opcode}
    {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (hs : RSafe Safe c s) :
    ∃ q s', R.step c s {} = .ok (.ext q s') := by
  obtain ⟨hnb, hout⟩ := call_step_ok (ch := {}) hi hf hsh
  cases h : R.step c s {} with
  | error e =>
    obtain ⟨m, rfl⟩ := hs.1 {} e h
    exact absurd h (hnb m)
  | ok out =>
    obtain ⟨q, s', rfl⟩ := hout out h
    exact ⟨q, s', rfl⟩

/-- Under `RSafe`, R's step of a tail call ends the function. -/
theorem tail_step_done {Safe : R.Query → Prop} {c : R.Code} {s : R.RState} {op : Reduced.Opcode}
    {fo : R.Opnd Nat} {ws : List (BitVec 32)} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [fo, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .tailCall) (hs : RSafe Safe c s) :
    ∃ fin, R.step c s {} = .ok (.done fin) := by
  obtain ⟨hnb, hout⟩ := tail_step_ok (ch := {}) hi hf hsh
  cases h : R.step c s {} with
  | error e =>
    obtain ⟨m, rfl⟩ := hs.1 {} e h
    exact absurd h (hnb m)
  | ok out =>
    obtain ⟨fin, rfl⟩ := hout out h
    exact ⟨fin, rfl⟩

end Ryo.Proofs.DecodeSound

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

/-- `CallRead` with the call site: the call item `ci` at `p3`, `n` bytes. -/
inductive CallReadS (fr : Frame) (c : Cursor) : Proto → Cursor → Prop
  | call {f : Full.Opcode} {fo : Opnd Nat} {pre ps : List Item} {ci : Item} {ws : List (BitVec 32)}
      {d : BitVec 32} {k : Nat} {p3 n : Nat} {c' : Cursor} :
      Call.callHead f fo = some (pre, ci) →
      Dec c c.pos (pre ++ ps) p3 → decodeItem (atPos c p3) = some (ci, n) →
      Dec c (p3 + n) (resultStores k d) c'.pos → c' = atPos c c'.pos →
      ((∀ it ∈ ps, XmmOk it) → Call.paramItems fr.mode.pe ws = some ps) → k < 2 ^ 32 →
      CallReadS fr c (callProto f fo d k ws c.pos (p3, n)) c'
  | tail {w : Bool} {f : Full.Opcode} {fo : Opnd Nat} {pre ps : List Item} {j : Item}
      {ws : List (BitVec 32)} {c' : Cursor} :
      Call.tailHead w f fo = some (pre, j) →
      Dec c c.pos (pre ++ ps ++ (fr.epilogue ++ [j])) c'.pos → c' = atPos c c'.pos →
      ((∀ it ∈ ps, XmmOk it) → Call.paramItems fr.mode.pe ws = some ps) →
      CallReadS fr c { op := f, ops := [fo, .words ws], pos := c.pos } c'

set_option maxRecDepth 100000 in
theorem call_read_site {fr : Frame} {dropped : List DroppedStore} {c c' : Cursor} {q : Proto}
    (h : (callInsn fr dropped).run c = .ok (some q, c')) : CallReadS fr c q c' := by
  unfold callInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨pr, c2, h2, h⟩ := bind_ok h
  have hpre : Dec c c.pos (preItems pr) c2.pos ∧ c2 = atPos c c2.pos := by
    obtain ⟨y, c7, h7, h8⟩ := bind_ok h2
    cases y with
    | none =>
      have := run_tryItem_none h7; subst this
      obtain ⟨u, c9, h9, h10⟩ := bind_ok h8
      rw [run_setPos] at h9; cases h9
      obtain ⟨rfl, rfl⟩ := pure_ok h10
      exact ⟨.nil _, rfl⟩
    | some it =>
      obtain ⟨n, hn, rfl⟩ := run_tryItem_some h7
      split at h8
      · rename_i s heq; cases heq
        obtain ⟨rfl, rfl⟩ := pure_ok h8
        exact ⟨Dec.single hn, rfl⟩
      · rename_i mm heq; cases heq
        split at h8
        · rename_i hb
          obtain ⟨rfl, rfl⟩ := pure_ok h8
          have : M.frame mm.disp = mm := by cases mm; simp only [beq_iff_eq] at hb; subst hb; rfl
          refine ⟨?_, rfl⟩
          simp only [preItems, this]; exact Dec.single hn
        · obtain ⟨u, c9, h9, h10⟩ := bind_ok h8
          rw [run_setPos] at h9; cases h9
          obtain ⟨rfl, rfl⟩ := pure_ok h10
          exact ⟨.nil _, rfl⟩
      · obtain ⟨u, c9, h9, h10⟩ := bind_ok h8
        rw [run_setPos] at h9; cases h9
        obtain ⟨rfl, rfl⟩ := pure_ok h10
        exact ⟨.nil _, rfl⟩
  obtain ⟨dpre, epre⟩ := hpre
  obtain ⟨ws, c3, h3, h⟩ := bind_ok h
  obtain ⟨ps, dps, eps, hps⟩ := params_read h3
  rw [epre] at dps
  have dpp := dpre.trans' dps
  have eps' : c3 = atPos c c3.pos := eps.trans (by rw [epre])
  obtain ⟨callAt, c4, h4, h⟩ := bind_ok h
  obtain ⟨rfl, hc4⟩ := pos_run' h4
  subst c4
  split at h
  · obtain ⟨u, c9, -, h10⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h10; cases he
  dsimp only at h
  obtain ⟨it, c5, h5, h⟩ := bind_ok h
  obtain ⟨r, c6, h6, h⟩ := bind_ok h
  have hnone : r = none → False := by
    intro hr; subst hr
    obtain ⟨u, c9, -, h10⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h10; cases he
  have fin_call : ∀ f fo ci n, Call.callHead f fo = some (preItems pr, ci) →
      decodeItem c3 = some (ci, n) → r = some (f, [fo], true) → c6 = atPos c3 (c3.pos + n) →
      CallReadS fr c q c' := by
    intro f fo ci n hhead hn hr hc6
    subst hr hc6
    dsimp only at h
    obtain ⟨x, c7, h7, h⟩ := bind_ok h
    obtain ⟨rfl, hc7⟩ := pos_run' h7
    subst c7
    obtain ⟨⟨d, k⟩, c8, h8, h⟩ := bind_ok h
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    obtain ⟨d8, e8, hk⟩ := resultSeq_read h8
    rw [eps'] at hn
    have hsite : (c3.pos, c3.pos + n - c3.pos) = (c3.pos, n) := by simp
    rw [hsite]
    refine .call hhead dpp hn ?_ ?_ hps hk
    · rw [eps'] at d8
      exact Dec.at_iff.mp d8
    · rw [e8, eps']
  have fin_tail : ∀ w f fo j (cE : Cursor) n2, Call.tailHead w f fo = some (preItems pr, j) →
      Dec c c3.pos fr.epilogue cE.pos → cE = atPos c cE.pos →
      decodeItem cE = some (j, n2) →
      r = some (f, [fo, .words ws], false) → c6 = atPos cE (cE.pos + n2) →
      CallReadS fr c q c' := by
    intro w f fo j cE n2 hhead dE eE hn2 hr hc6
    subst hr hc6
    dsimp only at h
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    refine .tail hhead ?_ ?_ hps
    · rw [eE] at hn2
      have := (dpp.append dE).append (Dec.single hn2)
      simpa using this
    · rw [eE]
  split at h6
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_call _) hn rfl rfl
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_callSym _) hn rfl rfl
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_callSymInd _) hn rfl rfl
  · obtain ⟨rfl, rfl⟩ := pure_ok h6
    obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
    exact fin_call _ _ _ n (head_callPtr _) hn rfl rfl
  · -- A tail call: the epilogue and the jump, read again from `callAt`.
    have e5 : c5 = atPos c3 c5.pos := posOnly_run PosOnly.tryItem h5
    obtain ⟨u, c7, h7, h6⟩ := bind_ok h6
    rw [run_setPos] at h7; cases h7
    have hc3 : atPos c5 c3.pos = c3 := by rw [e5]
    rw [hc3] at h6
    obtain ⟨b, cE, hE, h6⟩ := bind_ok h6
    split at h6
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      exact (hnone rfl).elim
    rename_i hb
    have hb : b = true := by simpa using hb
    subst hb
    obtain ⟨dE, eE⟩ := expectItems_dec hE
    have dE' : Dec c c3.pos fr.epilogue cE.pos := by
      obtain ⟨p3, rfl⟩ : ∃ p, c3 = atPos c p := ⟨_, eps'⟩
      exact Dec.at_iff.mp dE
    have eE' : cE = atPos c cE.pos := by rw [eE, eps']
    obtain ⟨y, c8, h8, h6⟩ := bind_ok h6
    split at h6
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h8
      exact fin_tail false _ _ _ cE n2 (head_tailCall false _) dE' eE' hn2 rfl rfl
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h8
      exact fin_tail false _ _ _ cE n2 (head_tailCallPtr false _) dE' eE' hn2 rfl rfl
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h8
      exact fin_tail true _ _ _ cE n2 (head_tailCallPtr true _) dE' eE' hn2 rfl rfl
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      exact (hnone rfl).elim

end Ryo.Proofs.DecodeLink

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

/-! ### The items: in the code, canonical, fetched -/

theorem call_link_length (addr : BitVec 64) (addrOf : RefAddr) :
    ∀ (rs : List Reloc) (code : List UInt8), (link addr addrOf code rs).length = code.length
  | [], code => rfl
  | r :: rs, code => by
    simp only [link, List.foldl_cons] at *
    have := call_link_length addr addrOf rs
      ((List.range code.length).map fun j =>
        if r.pos ≤ j ∧ j < r.pos + 4 then (leBytes (addrOf r.to - (addr + BitVec.ofNat 64 (r.pos + 4))) 4).getD (j - r.pos) 0
        else code.getD j 0)
    simp only [link] at this
    rw [this]; simp

theorem call_linkedAt_length (ctx : Ctx) (i : Item) (pos : Nat) :
    (i.linkedAt ctx pos).length = i.size := by
  unfold Item.linkedAt
  simp only
  rw [call_link_length, encode_len]

/-- The addresses of items a `Dec` run read are in the code. -/
theorem call_dec_inCode {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) :
    ∀ {p q : Nat} {items : List Item}, Dec c p items q → Boundary rs p → ∀ a,
      InCode ctx items p a → ∃ j, j < c.code.size ∧ a = addrAt ctx j
  | _, _, _, .nil p, _, a, h => absurd h (by simp [InCode])
  | _, _, _, .cons (p := p) (n := n) (i := i) hd hrest, hb, a, h => by
    obtain ⟨-, hn, hle, hb'⟩ := decodeItem_itemAt (c := atPos c p) hk.fields hk.sorted hk.loaded
      hk.small hk.fp hb hd
    rcases h with ⟨j, hj, rfl⟩ | h
    · rw [call_linkedAt_length] at hj
      exact ⟨p + j, by simp at hle; omega, (addrAt_add' ctx p j)⟩
    · rw [hn] at h
      exact call_dec_inCode hk hrest hb' a h

/-! #### Canonical items -/

theorem call_canon_of {i : Item} (hw : ∀ p, i.wf p = true) (ht : ∀ b e, i ≠ .tableEntry b e)
    (pos : Nat) : i.Canonical pos := ⟨ht, .inl (hw _)⟩

theorem call_canon_list : ∀ {L : List Item}, (∀ i ∈ L, ∀ pos, i.Canonical pos) → ∀ pos, Canon L pos
  | [], _, _ => trivial
  | i :: L, h, pos => ⟨h i (by simp) pos, call_canon_list (fun j hj => h j (by simp [hj])) _⟩

theorem call_intArg_usable (pe : Bool) (i : Nat) : (intArg pe i).usable = true := by
  unfold intArg
  cases pe <;> simp only [Bool.false_eq_true, ↓reduceIte] <;>
    (rcases i with _ | _ | _ | _ | _ | _ | i <;> simp [List.getD, Reg.usable] <;> decide)

theorem call_argReg_of_spec {r : Nat} {e : Bool} {a : ArgReg} (h : ArgReg.of? r e = some a) :
    (a.xmm = true → (a.size = 2 ∨ a.size = 4 ∨ a.size = 8 ∨ a.size = 16) ∧ a.index < 8) := by
  unfold ArgReg.of? at h
  intro hx
  generalize hA : (⟨r &&& 0x20 != 0, r &&& 0x1f, r >>> 8⟩ : ArgReg) = b at h
  by_cases hc : ((if b.xmm then (b.size == 2 || b.size == 4 || b.size == 8 || b.size == 16) &&
      b.index < 8 else (if e then 1 ≤ b.size && b.size ≤ 8
      else b.size == 1 || b.size == 2 || b.size == 4 || b.size == 8) && b.index < 6) &&
      r &&& 0xc0 == 0 && b.word == r) = true
  · simp only [hc, ↓reduceIte] at h
    cases h
    rw [hx] at hc
    simp only [↓reduceIte, Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq,
      decide_eq_true_eq] at hc
    omega
  · simp [hc] at h

theorem call_paramItem_canon {pe : Bool} {s w : BitVec 32} {L : List Item}
    (h : Call.paramItem pe s w = some L) : ∀ i ∈ L, ∀ pos, i.Canonical pos := by
  unfold Call.paramItem at h
  simp only at h
  split at h
  · cases h
  rename_i a ha
  have hx := call_argReg_of_spec ha
  cases pe <;> cases hB : (w.toNat &&& argAddr != 0) <;> cases hX : a.xmm <;> simp [hB, hX] at h
  all_goals first
    | obtain ⟨hc, rfl⟩ := h
    | (by_cases h2 : a.size = 2 <;> simp [h2] at h <;> subst h)
  all_goals intro i hi pos
  all_goals simp at hi
  all_goals (try rcases hi with rfl | rfl)
  all_goals (try subst hi)
  all_goals refine call_canon_of (fun p => ?_) (fun _ _ h => by cases h) pos
  all_goals simp [Item.wf, call_intArg_usable, Item.memWf, M.frame, *]
  all_goals first | (have := (hx hX).1; omega) | decide | simp [Reg.usable]


theorem call_paramItems_canon {pe : Bool} :
    ∀ {ws : List (BitVec 32)} {L : List Item}, Call.paramItems pe ws = some L →
      ∀ i ∈ L, ∀ pos, i.Canonical pos
  | [], L, h => by cases h; simp
  | [_], L, h => by cases h
  | s :: w :: rest, L, h => by
    simp only [Call.paramItems, bind, Option.bind, pure] at h
    cases h1 : Call.paramItem pe s w with
    | none => simp [h1] at h
    | some L1 =>
      cases h2 : Call.paramItems pe rest with
      | none => simp [h1, h2] at h
      | some L2 =>
        simp only [h1, h2, Option.some.injEq] at h
        subst h
        intro i hi
        rcases List.mem_append.1 hi with hi | hi
        · exact call_paramItem_canon h1 i hi
        · exact call_paramItems_canon h2 i hi

theorem call_head_canon {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item} {ci : Item}
    (h : Call.callHead f fo = some (pre, ci)) :
    (∀ i ∈ pre, ∀ pos, i.Canonical pos) ∧ ∀ pos, ci.Canonical pos := by
  unfold Call.callHead at h
  split at h <;> (try simp only [beq_iff_eq] at h)
  all_goals repeat' (split at h)
  all_goals (try cases h)
  all_goals refine ⟨fun i hi => ?_, call_canon_of (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h)⟩
  all_goals simp at hi
  all_goals subst hi
  all_goals exact call_canon_of (fun _ => by simp [Item.wf, Item.memWf, M.frame, Reg.usable]) (fun _ _ h => by cases h)


theorem call_tailHead_canon {w : Bool} {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item}
    {j : Item} (h : Call.tailHead w f fo = some (pre, j)) :
    (∀ i ∈ pre, ∀ pos, i.Canonical pos) ∧ ∀ pos, j.Canonical pos := by
  cases w <;> unfold Call.tailHead at h <;> simp only [Call.jmpRaxOf] at h
  split at h <;> (try simp only [beq_iff_eq] at h)
  all_goals repeat' (split at h)
  all_goals (try cases h)
  all_goals refine ⟨fun i hi => ?_, call_canon_of (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h)⟩
  all_goals simp at hi
  all_goals subst hi
  all_goals exact call_canon_of (fun _ => by simp [Item.wf, Item.memWf, M.frame, Reg.usable]) (fun _ _ h => by cases h)


theorem call_epilogue_canon (F : Nat) (m : Ryo.Obj.Mode) :
    ∀ i ∈ epilogue F m, ∀ pos, i.Canonical pos := by
  unfold epilogue
  split
  · intro i hi
    split at hi <;> simp only [List.mem_append, List.mem_cons, List.not_mem_nil, or_false,
      false_or] at hi
    all_goals (try rcases hi with rfl | rfl)
    all_goals (try subst hi)
    all_goals exact call_canon_of (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h)
  · split
    · intro i hi; simp only [List.mem_singleton] at hi; subst hi
      exact call_canon_of (fun _ => rfl) (fun _ _ h => by cases h)
    · intro i hi; simp only [List.mem_singleton] at hi; subst hi
      exact call_canon_of (fun _ => rfl) (fun _ _ h => by cases h)

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- A call's result slots are apart after its return (`Call.call_return`'s `hres`). Proof idea:
`ResultPrivate` gives them private after the scopes (the call's step and its answer keep
`escaped`: `st` is the state after the answer); the `FrameSep` after the answer (`SepAcross.call`'s `AllocFacts`, `FrameSep.extend`) has `FrameOwn`,
so a private window byte (`FrameBounds.result`: the slots are in the window) is in no live
allocation. -/
theorem call_resultApart' (H : Hyps S) {s s1 : R.RState} {x x' : X86.State} {op : Reduced.Opcode}
    {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64} {ws : List (BitVec 32)} {f : Full.Opcode}
    (hf : FrameInv S s x)
    (hi : S.c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hof : op.full = some f) (hsh : f.info.shape = .call)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) {st : OpSem.State}
    (hesc : st.escaped = s1.st.escaped) (hsep : FrameSep (-(S.F : Int)) S.K st x') :
    Call.ResultApart k.toNat d st x' := by
  intro parts hp q hq i hil
  have hpriv := H.resultPrivate s x s1 op d fo k ws f hf hi hof hsh hsc parts hp q hq i hil
  have hpe : st.escapedAt (d.toInt + q.1.off + i) = none := by
    unfold OpSem.State.escapedAt at hpriv ⊢; rw [hesc]; exact hpriv
  have hb : -(S.F : Int) ≤ d.toInt ∧ d.toInt + 16 ≤ S.K :=
    H.frameBounds.result s.pc op d fo k ws f hi hof hsh
  have h16 := ((CallLemmas.retRegsS_parts hp d).2.1 q hq).2.2
  refine ⟨hpe, fun id al hg hl hin => ?_⟩
  obtain ⟨e, hem, h1, h2, -⟩ := hsep.own id al _ hg hl (by omega) (by omega) hin
  exact escapedAt_none hpe e hem ⟨h1, h2⟩

/-! #### The opcodes and heads -/

set_option maxRecDepth 100000 in
theorem call_ofFull_call {op : Reduced.Opcode} (h : Reduced.Opcode.ofFull .call = some op) :
    op.full = some .call := by
  have e : (Reduced.Opcode.ofFull .call).bind Reduced.Opcode.full = some .call := by rfl
  rw [h] at e; exact e

set_option maxRecDepth 100000 in
theorem call_ofFull_callSym {op : Reduced.Opcode} (h : Reduced.Opcode.ofFull .callSym = some op) :
    op.full = some .callSym := by
  have e : (Reduced.Opcode.ofFull .callSym).bind Reduced.Opcode.full = some .callSym := by rfl
  rw [h] at e; exact e

set_option maxRecDepth 100000 in
theorem call_ofFull_callSymInd {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull .callSymInd = some op) : op.full = some .callSymInd := by
  have e : (Reduced.Opcode.ofFull .callSymInd).bind Reduced.Opcode.full = some .callSymInd := by rfl
  rw [h] at e; exact e

set_option maxRecDepth 100000 in
theorem call_ofFull_callPtr {op : Reduced.Opcode} (h : Reduced.Opcode.ofFull .callPtr = some op) :
    op.full = some .callPtr := by
  have e : (Reduced.Opcode.ofFull .callPtr).bind Reduced.Opcode.full = some .callPtr := by rfl
  rw [h] at e; exact e

set_option maxRecDepth 100000 in
theorem call_ofFull_tailCall {op : Reduced.Opcode} (h : Reduced.Opcode.ofFull .tailCall = some op) :
    op.full = some .tailCall := by
  have e : (Reduced.Opcode.ofFull .tailCall).bind Reduced.Opcode.full = some .tailCall := by rfl
  rw [h] at e; exact e

set_option maxRecDepth 100000 in
theorem call_ofFull_tailCallPtr {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull .tailCallPtr = some op) : op.full = some .tailCallPtr := by
  have e : (Reduced.Opcode.ofFull .tailCallPtr).bind Reduced.Opcode.full = some .tailCallPtr := by rfl
  rw [h] at e; exact e

/-- `callHead`'s four forms. -/
theorem call_head_cases {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item} {ci : Item}
    (h : Call.callHead f fo = some (pre, ci)) :
    (∃ g, f = .call ∧ fo = .func g ∧ pre = [] ∧ ci = .call (.func g)) ∨
    (∃ s, f = .callSym ∧ fo = .sym s ∧ pre = [] ∧ ci = .callMem (.sym s)) ∨
    (∃ s, f = .callSymInd ∧ fo = .sym s ∧ pre = [.loadRip .rax (.sym s)] ∧ ci = .callMemRax) ∨
    (∃ p, f = .callPtr ∧ fo = .slot p ∧ pre = [.ld .q false .rax (M.frame p)] ∧ ci = .callRax) := by
  cases fo
  case func g =>
    by_cases hf : f = .call
    · subst hf
      simp only [Call.callHead, beq_self_eq_true, ↓reduceIte, Option.some.injEq,
        Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact .inl ⟨g, rfl, rfl, rfl, rfl⟩
    · simp [Call.callHead, hf] at h
  case sym s =>
    by_cases hf : f = .callSym
    · subst hf
      simp only [Call.callHead, beq_self_eq_true, ↓reduceIte, Option.some.injEq,
        Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact .inr (.inl ⟨s, rfl, rfl, rfl, rfl⟩)
    · by_cases hf' : f = .callSymInd
      · subst hf'
        simp only [Call.callHead, symInd_ne, Bool.false_eq_true, ↓reduceIte, beq_self_eq_true,
          Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        exact .inr (.inr (.inl ⟨s, rfl, rfl, rfl, rfl⟩))
      · simp [Call.callHead, hf, hf'] at h
  case slot p =>
    by_cases hf : f = .callPtr
    · subst hf
      simp only [Call.callHead, beq_self_eq_true, ↓reduceIte, Option.some.injEq,
        Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact .inr (.inr (.inr ⟨p, rfl, rfl, rfl, rfl⟩))
    · simp [Call.callHead, hf] at h
  all_goals simp [Call.callHead] at h

/-- `tailHead`'s two forms. -/
theorem call_tail_cases {w : Bool} {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item} {j : Item}
    (h : Call.tailHead w f fo = some (pre, j)) :
    (∃ g, f = .tailCall ∧ fo = .func g ∧ pre = []) ∨
    (∃ p, f = .tailCallPtr ∧ fo = .slot p ∧ pre = [.ld .q false .rax (M.frame p)]) := by
  cases fo
  case func g =>
    by_cases hf : f = .tailCall
    · subst hf
      simp only [Call.tailHead, beq_self_eq_true, ↓reduceIte, Option.some.injEq,
        Prod.mk.injEq] at h
      exact .inl ⟨g, rfl, rfl, h.1.symm⟩
    · simp [Call.tailHead, hf] at h
  case slot p =>
    by_cases hf : f = .tailCallPtr
    · subst hf
      simp only [Call.tailHead, beq_self_eq_true, ↓reduceIte, Option.some.injEq,
        Prod.mk.injEq] at h
      exact .inr ⟨p, rfl, rfl, h.1.symm⟩
    · simp [Call.tailHead, hf] at h
  all_goals simp [Call.tailHead] at h

set_option maxRecDepth 100000 in
/-- A call's opcode: its reduced form, its shape, the callee operand without targets, not `arg`. -/
theorem call_head_op {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item} {ci : Item}
    {op : Reduced.Opcode} (h : Call.callHead f fo = some (pre, ci))
    (hof : Reduced.Opcode.ofFull f = some op) :
    op.full = some f ∧ f.info.shape = .call ∧ fo.targetsOf = [] ∧ (f == .arg) = false ∧
      0 < ci.size := by
  have hs := Call.call_shapes
  rcases call_head_cases h with ⟨g, rfl, rfl, -, rfl⟩ | ⟨s, rfl, rfl, -, rfl⟩ |
    ⟨s, rfl, rfl, -, rfl⟩ | ⟨p, rfl, rfl, -, rfl⟩
  · refine ⟨call_ofFull_call hof, hs.1, rfl, by decide, ?_⟩
    have e : (Item.call (.func g)).size = 5 := rfl
    omega
  · refine ⟨call_ofFull_callSym hof, hs.2.1, rfl, by decide, ?_⟩
    have e : (Item.callMem (.sym s)).size = 6 := rfl
    omega
  · refine ⟨call_ofFull_callSymInd hof, hs.2.2.1, rfl, by decide, ?_⟩
    have e : Item.callMemRax.size = 2 := rfl
    omega
  · refine ⟨call_ofFull_callPtr hof, hs.2.2.2, rfl, by decide, ?_⟩
    have e : Item.callRax.size = 2 := rfl
    omega

/-- A tail call's opcode. -/
theorem call_tail_op {w : Bool} {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item} {j : Item}
    {op : Reduced.Opcode} (h : Call.tailHead w f fo = some (pre, j))
    (hof : Reduced.Opcode.ofFull f = some op) :
    op.full = some f ∧ f.info.shape = .tailCall ∧ fo.targetsOf = [] := by
  have hs := Call.tailCall_shapes
  rcases call_tail_cases h with ⟨g, rfl, rfl, -⟩ | ⟨p, rfl, rfl, -⟩
  · exact ⟨call_ofFull_tailCall hof, hs.1, rfl⟩
  · exact ⟨call_ofFull_tailCallPtr hof, hs.2, rfl⟩

/-! #### Straight-line items before the call or jump -/

/-- The loads before a call or tail call, and the epilogue. -/
def CallShape (i : Item) : Prop :=
  RetShape i ∨ (∃ r m, i = .leaM r m) ∨ ∃ r to, i = .loadRip r to

theorem call_shape_ok (ctx : Ctx) {i : Item} (h : CallShape i) :
    i.FallsThrough ctx ∧ i.MemKept ctx := by
  rcases h with h | ⟨r, m, rfl⟩ | ⟨r, to, rfl⟩
  · exact ret_shape_ok ctx h
  · refine ⟨fun s s' he => ?_, fun s s' he => ?_⟩
    · obtain ⟨y, e, -, -, -, -, hr⟩ := Call.exec_leaM ctx r m s
      rw [e] at he; obtain rfl := Switch.except_ok_inj he; exact hr
    · obtain ⟨y, e, hm, -, -, -, -⟩ := Call.exec_leaM ctx r m s
      rw [e] at he; obtain rfl := Switch.except_ok_inj he; exact hm
  · refine ⟨fun s s' he => ?_, fun s s' he => ?_⟩
    · obtain ⟨y, e, -, -, -, -, hr⟩ := Call.exec_loadRip ctx r to s
      rw [e] at he; obtain rfl := Switch.except_ok_inj he; exact hr
    · obtain ⟨y, e, hm, -, -, -, -⟩ := Call.exec_loadRip ctx r to s
      rw [e] at he; obtain rfl := Switch.except_ok_inj he; exact hm

theorem call_paramItem_shape {pe : Bool} {s w : BitVec 32} {L : List Item}
    (h : Call.paramItem pe s w = some L) : ∀ i ∈ L, CallShape i := by
  have h' := h
  unfold Call.paramItem at h'
  simp only at h'
  split at h'
  · cases h'
  rename_i a ha
  rcases Call.paramItem_cases h ha with ⟨-, -, -, rfl⟩ | ⟨-, -, -, rfl⟩ | ⟨-, -, -, rfl⟩ |
    ⟨-, -, -, rfl⟩
  · intro i hi; simp only [List.mem_singleton] at hi; subst hi
    exact .inr (.inl ⟨_, _, rfl⟩)
  · intro i hi
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
    rcases hi with rfl | rfl
    · exact .inl (.inl ⟨_, _, _, _, rfl⟩)
    · exact .inl (.inr (.inl ⟨_, _, _, rfl⟩))
  · intro i hi; simp only [List.mem_singleton] at hi; subst hi
    exact .inl (.inr (.inr (.inl ⟨_, _, _, rfl⟩)))
  · intro i hi; simp only [List.mem_singleton] at hi; subst hi
    exact .inl (.inl ⟨_, _, _, _, rfl⟩)

theorem call_paramItems_shape {pe : Bool} :
    ∀ {ws : List (BitVec 32)} {L : List Item}, Call.paramItems pe ws = some L →
      ∀ i ∈ L, CallShape i
  | [], L, h => by cases h; simp
  | [_], L, h => by cases h
  | s :: w :: rest, L, h => by
    simp only [Call.paramItems, bind, Option.bind, pure] at h
    cases h1 : Call.paramItem pe s w with
    | none => simp [h1] at h
    | some L1 =>
      cases h2 : Call.paramItems pe rest with
      | none => simp [h1, h2] at h
      | some L2 =>
        simp only [h1, h2, Option.some.injEq] at h
        subst h
        intro i hi
        rcases List.mem_append.1 hi with hi | hi
        · exact call_paramItem_shape h1 i hi
        · exact call_paramItems_shape h2 i hi

theorem call_ldFrame_shape (p : BitVec 32) : CallShape (.ld .q false .rax (M.frame p)) :=
  .inl (.inl ⟨_, _, _, _, rfl⟩)

/-! #### The `sret` write and the state after a call's step -/

/-- An `Uninit` write anywhere keeps `FrameSep` (no new initialized private byte, the
allocations' shapes and the escaped objects unchanged). -/
theorem call_sep_uninit {lo hi : Int} {st st' : OpSem.State} {x : X86.State} {off : Int} {n : Nat}
    (hs : FrameSep lo hi st x) (h : st.writeFrame off (List.replicate n .uninit) = .ok st') :
    FrameSep lo hi st' x ∧ AllocShape st.mem st'.mem ∧ st'.escaped = st.escaped := by
  have hesc := writeFrame_escaped h
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off (List.replicate n .uninit) with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
  simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
  subst h
  have hsh : AllocShape st.mem m' := allocShape_of_escOnly (writeEscaped_spec hm).escOnly
  refine ⟨⟨fun id a' o hg hl h1 h2 hin => ?_, fun o he hu => ?_, ?_, ?_⟩, hsh, hesc⟩
  · obtain ⟨a, ha, had, hlv, hsz⟩ := hsh id a' hg
    obtain ⟨e, hem, ho1, ho2, hid⟩ := hs.own id a o ha (hlv ▸ hl) h1 h2
      (by rw [← had, ← hsz]; exact hin)
    exact ⟨e, hem, ho1, ho2, hid⟩
  · have he1 : st.escapedAt o = none := by
      unfold OpSem.State.escapedAt at he ⊢; rw [← hesc]; exact he
    simp only [OpSem.State.privateIn, he1, Option.isNone_none, Bool.and_true] at hu
    by_cases hr : off ≤ o ∧ o < off + (List.replicate n AbstractByte.uninit).length
    · have hlt : (o - off).toNat < n := by simp only [List.length_replicate] at hr; omega
      rw [if_pos (decide_eq_true hr)] at hu
      exact (hu (by rw [List.getD_eq_getElem?_getD, List.getElem?_replicate, if_pos hlt]; rfl)).elim
    · simp only [hr, decide_false, Bool.false_eq_true, ↓reduceIte] at hu
      exact hs.init o he1 hu
  · intro id1 a1 id2 a2 i j hg1 hg2 hl1 hl2 hi hj heq
    obtain ⟨b1, hb1, had1, hlv1, hsz1⟩ := hsh id1 a1 hg1
    obtain ⟨b2, hb2, had2, hlv2, hsz2⟩ := hsh id2 a2 hg2
    rw [had1, had2] at heq
    exact hs.dis id1 b1 id2 b2 i j hb1 hb2 (hlv1 ▸ hl1) (hlv2 ▸ hl2) (hsz1 ▸ hi) (hsz2 ▸ hj) heq
  · intro id a' hg hl
    obtain ⟨a, ha, had, hlv, hsz⟩ := hsh id a' hg
    rw [had, hsz]; exact hs.space id a ha (hlv ▸ hl)

theorem call_allocsApart_shape {lo : BitVec 64} {st st' : OpSem.State} {x : X86.State}
    (h : Handler.AllocsApart lo st x) (hsh : AllocShape st.mem st'.mem) :
    Handler.AllocsApart lo st' x := by
  intro id a' hg hl i hi
  obtain ⟨a, ha, had, hlv, hsz⟩ := hsh id a' hg
  rw [had]; exact h id a ha (hlv ▸ hl) i (by rw [← hsz]; exact hi)

/-! #### The answer with a given answer (`Call.call_return`/`call_unwind` take theirs from the
contract; `SepAcross.call` gives its own) -/

/-- `Call.call_return` for the answer `a`. -/
theorem call_return_at (ctx : Ctx) {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)} {Owned : BitVec 64 → Prop} {lo : BitVec 64} {a : R.Answer}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call)
    (hcr : Call.CallReturn c.mode.pe Owned lo (s.fp - c.d.frameSize) (c.stackSize s.pc)
      s.world x1 x' a)
    (hfp : c.d.frameSize ≤ s.fp) (hr : RRel s x1)
    (hb : c.d.frameSize + c.stackSize s.pc < 2 ^ 62) (hd : d.toInt + 16 ≤ 2 ^ 31)
    (hap : Call.CallApart Owned lo c.d.frameSize (c.stackSize s.pc) (s.fp - c.d.frameSize) s.st x1)
    (hk : ∃ parts, R.retRegs k.toNat false = .ok parts)
    (hres : Call.ResultApart k.toNat d (s.withWorld a.world).st x') :
    ∃ s'' x'', R.answer c s a = .ok (.step s'') ∧
      execItems ctx (resultStores k.toNat d) x' = .ok x'' ∧
      RRel s'' x'' ∧ MemRel s''.st x'' ∧ s''.pc = s.pc + 1 ∧ s''.fp = s.fp ∧
      x''.rip = x'.rip + BitVec.ofNat 64 ((resultStores k.toNat d).map Item.size).sum ∧
      x''.rsp = x'.rsp ∧ x''.reg .rbp = x'.reg .rbp ∧
      (∀ i, Saved c.mode.pe i → x''.regs i = x'.regs i) ∧
      ∃ (st1 : OpSem.State) (parts : List (RetPart × R.Reg)) (regs : R.Regs),
        R.writeRanges (s.withWorld a.world).st [(-(c.d.frameSize : Int), c.stackSize s.pc)]
          a.frame = .ok st1 ∧ R.retRegs k.toNat false = .ok parts ∧
        parts.foldlM (init := st1) (fun st (q : RetPart × R.Reg) =>
          st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok s''.st := by
  have hrbp : x'.reg .rbp = x1.reg .rbp :=
    hcr.saved 5 (Call.saved_of_calleeSaved (by simp [CalleeSaved]))
  obtain ⟨st1, hw, hrel, hwf, hmr, he1, -, -, heo⟩ := Call.answer_rel hr hcr.toCallEnd hap hrbp hfp hb
  obtain ⟨regsR, hresR, hRet⟩ := hcr.regs
  obtain ⟨parts, hp⟩ := hk
  obtain ⟨hstores, hpq, hnd⟩ := CallLemmas.retRegsS_parts hp d
  have hra : ∀ q ∈ parts, CallLemmas.RangeApart st1 x' (d.toInt + q.1.off) q.1.size :=
    fun q hq => (hres parts hp q hq).of_escOnly (by rw [he1]; rfl) heo
  obtain ⟨st2, x'', hfold, hx, hrel2, hmr2, g1, g2, -, -, -, rs2, p2⟩ :=
    CallLemmas.exec_stores ctx d regsR hd parts st1 x' hpq hnd hrel hmr hra (fun q hq => by
      apply hRet
      obtain ⟨_, hfor, _⟩ := hpq q hq
      rcases hfor with ⟨_, h | h⟩ | ⟨_, h | h⟩ <;> rw [h] <;> simp [ArgRet.retRegList])
  have hrbp2 : x''.reg .rbp = x'.reg .rbp := rs2 5 (by decide) (by decide) (by decide)
  refine ⟨⟨s.pc + 1, s.fp, st2, s.args⟩, x'', CallLemmas.answer_ret hi hf hsh hresR hw hp hfold,
    by rw [hstores]; exact hx, ⟨hrel2, by rw [hrbp2, hrbp]; exact hr.rbp, ?_⟩, hmr2, rfl, rfl,
    by rw [p2, hstores], ?_, hrbp2, fun i hi' => ?_, st1, parts, regsR, hw, hp, hfold⟩
  · exact ⟨fun e he' => by rw [g1] at he'; rw [g2]; exact hwf.idLt e he',
      fun e he' e' he'' hid => by rw [g1] at he' he''; exact hwf.idInj e he' e' he'' hid⟩
  · show x''.regs 4 = x'.regs 4
    exact rs2 4 (by decide) (by decide) (by decide)
  · obtain ⟨h0, h2, h11, -⟩ := Call.saved_ne hi'
    exact rs2 i h0 h2 h11

/-- `Call.call_unwind` for the answer `a`. -/
theorem call_unwind_at {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)} {Owned : BitVec 64 → Prop} {lo : BitVec 64}
    {padOf : BitVec 64 → Option (BitVec 64)} {a : R.Answer} {exc : ThinPointer} {pad : Nat}
    {cat : Bool}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call) (hres : a.result = .unwind exc)
    (hce : Call.CallEnd Owned lo (s.fp - c.d.frameSize) (c.stackSize s.pc) s.world x1 x' a)
    (hland : Call.Landed c.mode.pe padOf (x1.rsp + 8) x1 x' exc)
    (hfp : c.d.frameSize ≤ s.fp) (hr : RRel s x1)
    (hb : c.d.frameSize + c.stackSize s.pc < 2 ^ 62)
    (hap : Call.CallApart Owned lo c.d.frameSize (c.stackSize s.pc) (s.fp - c.d.frameSize) s.st x1)
    (hpad : c.cleanupAt s.pc = some (some pad, cat)) :
    ∃ st1, R.writeRanges (s.withWorld a.world).st [(-(c.d.frameSize : Int), c.stackSize s.pc)]
        a.frame = .ok st1 ∧
      R.answer c s a = .ok (.step ⟨pad, s.fp, { st1 with exception := exc }, s.args⟩) ∧
      RRel ⟨pad, s.fp, { st1 with exception := exc }, s.args⟩ x' ∧ MemRel st1 x' := by
  have hrbp : x'.reg .rbp = x1.reg .rbp :=
    hland.saved 5 (Call.saved_of_calleeSaved (by simp [CalleeSaved]))
  obtain ⟨st1, hw, hrel, hwf, hmr, -, -, -, -⟩ := Call.answer_rel hr hce hap hrbp hfp hb
  exact ⟨st1, hw, CallLemmas.answer_unwind hi hf hsh hres hw hpad,
    ⟨Call.rel_exc exc hrel, by rw [hrbp]; exact hr.rbp, ⟨hwf.idLt, hwf.idInj⟩⟩, hmr⟩

/-! #### The result stores -/

/-- `arg_items_form` without the index bound (a result store into `rax` is index 6). -/
theorem call_items_form (a : ArgReg) (d : BitVec 32) (pe : Bool)
    (hv : (a.xmm = true → (a.size = 2 ∨ a.size = 4 ∨ a.size = 8 ∨ a.size = 16) ∧ a.index < 8) ∧
      (a.xmm = false → 1 ≤ a.size ∧ a.size ≤ 8)) :
    ∀ i ∈ argStore a d pe, ArgItemForm d a.size i := by
  obtain ⟨xm, n, idx⟩ := a
  have hd0 : d + BitVec.ofNat 32 0 = d := by simp
  cases xm with
  | true =>
    obtain ⟨hs, hx⟩ := hv.1 rfl
    simp only [argStore, sseStore, ↓reduceIte]
    rcases hs with rfl | hs
    · intro i hi
      simp only [beq_self_eq_true, ↓reduceIte, List.mem_cons, List.not_mem_nil, or_false] at hi
      rcases hi with rfl | rfl
      · exact .inr (.inr (.inl ⟨idx, rfl, hx⟩))
      · exact .inl ⟨.w, .r11, 0, by rw [hd0]; rfl, by simp [W.bits], rfl⟩
    · have : (n == 2) = false := by rcases hs with rfl | rfl | rfl <;> rfl
      intro i hi
      simp only [this, Bool.false_eq_true, ↓reduceIte, List.mem_cons, List.not_mem_nil,
        or_false] at hi
      subst hi
      exact .inr (.inl ⟨idx, rfl, hs, hx⟩)
  | false =>
    obtain ⟨h1, h8⟩ := hv.2 rfl
    simp only [argStore, Bool.false_eq_true, ↓reduceIte]
    have hu := arg_intArg_usable pe idx
    generalize intArg pe idx = r at hu
    intro i hi
    have st0 : ∀ w : W, w.bits / 8 ≤ n → ArgItemForm d n (.st w r (M.frame d)) :=
      fun w hw => .inl ⟨w, r, 0, by rw [hd0]; rfl, by omega, hu⟩
    simp only at h1 h8
    obtain _|_|_|_|_|_|_|_|_|n := n
    any_goals omega
    all_goals simp [intStore, widthOf] at hi
    all_goals first
      | (subst hi; exact st0 _ (by simp [W.bits]))
      | (rcases hi with rfl | rfl | rfl | rfl | rfl <;>
          first
            | exact st0 _ (by simp [W.bits])
            | exact .inl ⟨_, r, _, rfl, by simp [W.bits], hu⟩
            | exact .inr (.inr (.inr ⟨r, _, rfl, hu⟩)))
      | (rcases hi with rfl | rfl | rfl <;>
          first
            | exact st0 _ (by simp [W.bits])
            | exact .inl ⟨_, r, _, rfl, by simp [W.bits], hu⟩
            | exact .inr (.inr (.inr ⟨r, _, rfl, hu⟩)))

theorem call_storeR_form {d : BitVec 32} {p : RetPart} {rr : R.Reg} (hp : CallLemmas.partOkS p)
    (hfor : ArgRet.RegFor p rr) :
    ∀ i ∈ CallLemmas.storeR d (p, rr), ArgItemForm (d + BitVec.ofNat 32 p.off) p.size i := by
  rcases hfor with ⟨hx, hr | hr⟩ | ⟨hx, hr | hr⟩ <;> subst hr
  · have hv : 1 ≤ p.size ∧ p.size ≤ 8 := by unfold CallLemmas.partOkS at hp; simpa [hx] using hp
    have hst : CallLemmas.storeR d (p, .gpr 0) =
        argStore ⟨false, p.size, 6⟩ (d + BitVec.ofNat 32 p.off) false := by
      simp [argStore, CallLemmas.storeR, hx, ArgRet.retX86, frameAt, intArg]
    rw [hst]
    exact call_items_form ⟨false, p.size, 6⟩ _ false ⟨fun h => by simp at h, fun _ => hv⟩
  · have hv : 1 ≤ p.size ∧ p.size ≤ 8 := by unfold CallLemmas.partOkS at hp; simpa [hx] using hp
    have hst : CallLemmas.storeR d (p, .gpr 1) =
        argStore ⟨false, p.size, 2⟩ (d + BitVec.ofNat 32 p.off) false := by
      simp [argStore, CallLemmas.storeR, hx, ArgRet.retX86, frameAt, intArg]
    rw [hst]
    exact call_items_form ⟨false, p.size, 2⟩ _ false ⟨fun h => by simp at h, fun _ => hv⟩
  · have hv : p.size = 2 ∨ p.size = 4 ∨ p.size = 8 ∨ p.size = 16 := by
      unfold CallLemmas.partOkS at hp; simpa [hx] using hp
    have hst : CallLemmas.storeR d (p, .xmm 0) =
        argStore ⟨true, p.size, 0⟩ (d + BitVec.ofNat 32 p.off) false := by
      simp [argStore, CallLemmas.storeR, hx, ArgRet.retXmm, frameAt]
    rw [hst]
    exact call_items_form ⟨true, p.size, 0⟩ _ false ⟨fun _ => ⟨hv, by simp⟩, fun h => by simp at h⟩
  · have hv : p.size = 2 ∨ p.size = 4 ∨ p.size = 8 ∨ p.size = 16 := by
      unfold CallLemmas.partOkS at hp; simpa [hx] using hp
    have hst : CallLemmas.storeR d (p, .xmm 1) =
        argStore ⟨true, p.size, 1⟩ (d + BitVec.ofNat 32 p.off) false := by
      simp [argStore, CallLemmas.storeR, hx, ArgRet.retXmm, frameAt]
    rw [hst]
    exact call_items_form ⟨true, p.size, 1⟩ _ false ⟨fun _ => ⟨hv, by simp⟩, fun h => by simp at h⟩

/-- The bytes `IslandKept` names: code or rodata (`CodeApart`), or a link slot. -/
theorem call_kept_cases (H : Hyps S) {x : X86.State} {b : BitVec 64} (hb : IslandKept S x b) :
    ((∃ p, p < S.body.code.size ∧ b = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ b = S.ctx.addrOf (.ro j))) ∨
    ∃ o : Int, 0 ≤ o ∧ o < 16 ∧ b = fpAddr x o := by
  rcases hb with hb | ⟨r, hr, k, hk, rfl⟩ | hb | ⟨i, hi, hb⟩
  · exact .inl (.inl hb)
  · exact .inl (.inl ⟨r.pos + k, by have := H.relocsIn r hr; omega, rfl⟩)
  · exact .inl (.inr hb)
  · right
    have e : ∀ c : Int, x.reg .rbp + BitVec.ofInt 64 c + BitVec.ofNat 64 i = fpAddr x (c + i) :=
      fun c => by simp only [fpAddr, island_ofInt_add, BitVec.add_assoc]
    rcases hb with rfl | rfl
    · refine ⟨8 + i, by omega, by omega, ?_⟩
      rw [← e]; rfl
    · refine ⟨0 + i, by omega, by omega, ?_⟩
      rw [← e]; simp

/-- A kept byte is off a frame range `[D, D + n)` in the window that misses the link slots. -/
theorem call_kept_off (H : Hyps S) {s : R.RState} {x : X86.State} (hf : FrameInv S s x)
    {D : Int} {n : Nat} (hD : -(S.F : Int) ≤ D) (hDK : D + n ≤ S.K) (hoff : D + n ≤ 0 ∨ 16 ≤ D)
    (b : BitVec 64) (hb : IslandKept S x b) : n ≤ (b - fpAddr x D).toNat := by
  have hFl := H.frameBounds.F_le
  have hKl := H.frameBounds.K_le
  have eF : (S.F : Int) = S.c.d.frameSize := rfl
  rcases call_kept_cases H hb with hcode | ⟨o, ho1, ho2, rfl⟩
  · apply Classical.byContradiction
    intro hlt
    obtain ⟨t, ht, hbe⟩ := arg_in_range (Nat.lt_of_not_le hlt)
    exact (H.codeApart b hcode).2.2.1 (D + t) (by omega) (by omega) (hbe.trans (hf.fpAddr_eq _))
  · simp only [fpAddr]
    have e : ∀ A C : BitVec 64, x.reg .rbp + A - (x.reg .rbp + C) = A - C := by
      intros; bv_omega
    rw [e, BitVec.toNat_sub, BitVec.toNat_ofInt, BitVec.toNat_ofInt]
    omega

/-- The result stores, fetched from `q0`: they keep the bytes `IslandKept` names. -/
theorem call_stores_steps (H : Hyps S) {s : R.RState} {x y y' : X86.State} {k : Nat}
    {d : BitVec 32} {parts : List (RetPart × R.Reg)} {q0 : Nat} (hf : FrameInv S s x)
    (hp : R.retRegs k false = .ok parts) (hdb : -(S.F : Int) ≤ d.toInt ∧ d.toInt + 16 ≤ S.K)
    (hoff : ∀ q ∈ parts, OffLink (d.toInt + q.1.off, q.1.size))
    (hca : CodeAt S.ctx y.mem (resultStores k d) q0)
    (hinC : ∀ b, InCode S.ctx (resultStores k d) q0 b → IslandKept S x b)
    (hrip : y.rip = addrAt S.ctx q0) (hrb : y.reg .rbp = x.reg .rbp)
    (he : execItems S.ctx (resultStores k d) y = .ok y') :
    Steps S.ctx y y' ∧ y'.rip = addrAt S.ctx (q0 + codeSize (resultStores k d)) ∧
      ∀ b, IslandKept S x b → y'.mem b = y.mem b := by
  obtain ⟨hst, hpq, -⟩ := CallLemmas.retRegsS_parts hp d
  have hKl := H.frameBounds.K_le
  have hdb' := toInt_bounds d
  have hmem : ∀ i ∈ resultStores k d, ∃ q ∈ parts,
      ArgItemForm (d + BitVec.ofNat 32 q.1.off) q.1.size i ∧
      (d + BitVec.ofNat 32 q.1.off).toInt = d.toInt + q.1.off ∧ 1 ≤ q.1.size ∧
      q.1.off + q.1.size ≤ 16 := by
    intro i hi
    rw [hst, List.mem_flatMap] at hi
    obtain ⟨⟨pp, rr⟩, hq, hi⟩ := hi
    obtain ⟨hok, hfor, hle⟩ := hpq _ hq
    simp only at hok hfor hle
    have h1 : 1 ≤ pp.size := by unfold CallLemmas.partOkS at hok; split at hok <;> omega
    exact ⟨(pp, rr), hq, call_storeR_form hok hfor i hi,
      CallLemmas.toInt_disp d pp.off (by omega) (by omega), h1, hle⟩
  have hcan : Canon (resultStores k d) q0 := call_canon_list (fun i hi pos => by
    obtain ⟨q, -, hform, -⟩ := hmem i hi
    exact arg_item_canonical hform pos) q0
  have hrun : FetchRun S.ctx (IslandKept S x) (resultStores k d) y :=
    arg_fetchRun (fun z => z.reg .rbp = x.reg .rbp) (fun i hi z z' hz hez => by
      obtain ⟨q, hq, hform, hdisp, h1, hle⟩ := hmem i hi
      have hoffq := hoff q hq
      obtain ⟨r1, r2, r3⟩ := arg_item_exec S.ctx hform (by rw [hdisp]; omega) (by omega) hez
      refine ⟨r1, fun b hb => r3 b ?_, r2.trans hz⟩
      have e : fpAddr z (d + BitVec.ofNat 32 q.1.off).toInt =
          fpAddr x (d.toInt + q.1.off) := by simp [fpAddr, hz, hdisp]
      rw [e]
      exact call_kept_off H hf (by omega) (by omega) hoffq b hb) y hrb
  exact steps_of_run hcan hca hrip hinC hrun he

/-! #### What the callee leaves alone -/

/-- The bytes `IslandKept` names are off the stack below `rsp` and not where the callee may
write: the outgoing area ends at `fp` (`n ≤ F`), the code and rodata are apart (`CodeApart`),
the link slots private (`LinkPrivate`, `FrameOwn`) and not runtime-owned (`EnvApart.window`). -/
theorem call_kept_callee (H : Hyps S) {s s1 s' : R.RState} {x : X86.State} (hf : FrameInv S s x)
    (hci : CacheInv (S.used s.pc) x)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hsh : AllocShape s1.st.mem s'.st.mem) (hesc : s'.st.escaped = s1.st.escaped)
    (hsep' : FrameSep (-(S.F : Int)) S.K s'.st x) (n : Nat) (hn : n ≤ S.F)
    (b : BitVec 64) (hb : IslandKept S x b) :
    ¬ InStack S.lo x.rsp b ∧
      ¬ Call.CallMayWrite S.Owned S.lo (s.fp - S.F) n s'.world b := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hwin : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  have hfpF : S.F ≤ s.fp := hf.fpF
  have hfb := H.frameBounds
  have hrsp0 := island_rsp_toNat hf.rrel.rbp (by omega) hfpF hf.rsp
  have hrbp : x.reg .rbp = BitVec.ofNat 64 s.fp := hf.rrel.rbp
  have hW : ∀ o, S.winAddr o = BitVec.ofNat 64 s.fp + BitVec.ofInt 64 o := fun o => by
    rw [← hf.fpAddr_eq]; simp [fpAddr, hrbp]
  have hx0 : S.x0.rsp.toNat = s.fp + 8 := by
    have h0 : S.x0.rsp = x.reg .rbp + 8 := by have := hf.frame.rbp; bv_omega
    have h8 : (8 : BitVec 64).toNat = 8 := rfl
    rw [h0, hrbp, BitVec.toNat_add, BitVec.toNat_ofNat, h8,
      Nat.mod_eq_of_lt (show s.fp < 2 ^ 64 by omega)]
    omega
  have hspn : (BitVec.ofNat 64 (s.fp - S.F + n)).toNat = s.fp - S.F + n := by
    rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
  have hbi : BInv S s (x.jump (addrAt S.ctx (posOf S.r s.pc))) :=
    ⟨hf.congr rfl rfl rfl, .inr ⟨rfl, hci⟩⟩
  rcases call_kept_cases H hb with hcode | ⟨o, ho1, ho2, rfl⟩
  · obtain ⟨hown, hstk, hnw, hal⟩ := H.codeApart b hcode
    refine ⟨fun h => hstk ⟨h.1, by have := h.2; omega⟩, ?_⟩
    rintro (h | ⟨id, al, hg, hl, hlt⟩ | h)
    · exact hstk ⟨h.1, by have := h.2; omega⟩
    · have hold : island_AllOk (fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz) s.st :=
        fun id al hg hl hlt => hal s _ hbi ⟨id, al, hg, hl, hlt⟩
      have hnew := island_allOk_foldlM
        (P := fun addr sz => ¬ (b - BitVec.ofNat 64 addr).toNat < sz)
        (F := S.F) (K := S.K) _ (fun off sz h1 h2 h3 hlt => by
          refine hnw (off + (b - BitVec.ofNat 64 ((s.fp : Int) + off).toNat).toNat)
            (by omega) (by omega) ?_
          rw [hW, island_ofInt_add, ← BitVec.add_assoc, ← ofNat_frameAddr _ _ h3]
          exact island_sub_toNat rfl) (hfb.scopesIn s.pc) hold hsc
      obtain ⟨a0, hg0, had, hlv, hsz⟩ := hsh id al hg
      exact hnew id a0 hg0 (hlv ▸ hl) (by rw [← had, ← hsz]; exact hlt)
    · exact hown h
  · have hoF : -(S.F : Int) ≤ o := by omega
    have hfo : (fpAddr x o).toNat = s.fp + o.toNat := by
      rw [fpAddr, hrbp, ← ofNat_frameAddr _ _ (by omega), BitVec.toNat_ofNat,
        Nat.mod_eq_of_lt (by omega)]
      omega
    obtain ⟨hesc1, -⟩ := H.linkPrivate s x s1 hf hsc o ho1 ho2
    refine ⟨fun h => by have := h.2; omega, ?_⟩
    rintro (h | ⟨id, al, hg, hlv, hlt⟩ | h)
    · have := h.2; omega
    · obtain ⟨e, hem, he1, he2, -⟩ := hsep'.own id al o hg hlv hoF (by omega) hlt
      have hesc' : s'.st.escapedAt o = none := by
        unfold OpSem.State.escapedAt at hesc1 ⊢; rw [hesc]; exact hesc1
      exact escapedAt_none hesc' e hem ⟨he1, he2⟩
    · rw [hf.fpAddr_eq] at h
      exact H.envApart.window o hoF (by omega) h

/-- The frame separation after a call's answer: the outgoing area and the result parts are
written in the window. -/
theorem call_sep_answer (H : Hyps S) {st0 st1 st2 : OpSem.State} {y : X86.State} {d : BitVec 32}
    {k : Nat} {parts : List (RetPart × R.Reg)} {regs : R.Regs} {n : Nat}
    {fr : List (List AbstractByte)}
    (hs : FrameSep (-(S.F : Int)) S.K st0 y) (hn : n ≤ S.F)
    (hw : R.writeRanges st0 [(-(S.F : Int), n)] fr = .ok st1)
    (hdb : -(S.F : Int) ≤ d.toInt ∧ d.toInt + 16 ≤ S.K)
    (hp : R.retRegs k false = .ok parts)
    (hfold : parts.foldlM (init := st1) (fun st (q : RetPart × R.Reg) =>
      st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size)) = .ok st2) :
    FrameSep (-(S.F : Int)) S.K st2 y := by
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have h1 := island_sep_writeRanges hs (fun r hr => by
    simp only [List.mem_singleton] at hr; subst hr
    refine ⟨Int.le_refl _, ?_⟩
    show -(S.F : Int) + (n : Int) ≤ S.K
    omega) hw
  obtain ⟨-, hpq, -⟩ := CallLemmas.retRegsS_parts hp d
  exact foldlM_inv (fun st => FrameSep (-(S.F : Int)) S.K st y)
    (fun q : RetPart × R.Reg => q.1.off + q.1.size ≤ 16)
    (fun st (q : RetPart × R.Reg) =>
      st.writeFrame (d.toInt + q.1.off) ((regs.get q.2).take q.1.size))
    (fun st q st' hP hQ hst => island_sep_writeFrame hP hst (by omega)
      (by have := List.length_take_le q.1.size (regs.get q.2); omega))
    parts st1 st2 h1 (fun q hq => (hpq q hq).2.2) hfold

set_option maxHeartbeats 2000000 in
/-- `bodySim_call`. A call: `Call.call_query` to the callee's entry (the items fetched by
`steps_of_run_last`), the environment step there (`EnvOutside.call`), and per `SepAcross.call`'s
answer either its return (`call_return_at`, the result stores fetched by `call_stores_steps`,
`PE`'s `nop` by `NopRead`) or an unwind to the landing pad (`call_unwind_at`, `PadsLinked`);
the callee leaves the code, rodata and link slots alone (`call_kept_callee`). A tail call:
`Call.tail_call_step` and `ExitRel`'s `tailCall` from `FrameFacts`. The outgoing area fits in
the frame (`hstk`, `StackSizes.frame`: callee writes below `sp + n` would otherwise reach the
link slots, and the answer's area write would leave the window). -/
theorem bodySim_call' (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (callInsn S.fr (S.dr k)).run cur = .ok (some q, c')) :
    BodySim S k p (S.used k) := by
  have hstk : ∀ k, S.c.stackSize k + (if S.c.mode.pe then 16 else 0) ≤ S.F :=
    H.stackSizes.frame
  intro s x hs hfi hrip hci hsafe
  have hcur := noArg_call hn hr
  subst hcur
  have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs := bs_linkOk_at hfi.code p
  have eF : (S.F : Int) = S.c.d.frameSize := rfl
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hfi.win
  have hwin := hfb.window hwinT
  have hK : (16 : Int) ≤ S.K := by have := H.argSizeK; omega
  have hFl := hfb.F_le
  have hKl := hfb.K_le
  have hfpF : S.F ≤ s.fp := hfi.fpF
  have hfp64 : s.fp < 2 ^ 64 := by omega
  have hstkF : S.c.stackSize s.pc ≤ S.F := by have := hstk s.pc; split at this <;> omega
  obtain ⟨hlt, ⟨p1, ctr, hpq⟩, ⟨i, hi, hio⟩, hbd, hnop, hcache, hargs⟩ := hP
  have hpk := (Array.getElem?_eq_some_iff.1 hpq).2
  have hio' := hpk ▸ hio hlt
  cases call_read_site hr with
  | @call f fo pre ps ci ws d kk p3 n c'' hhead hd hn1 hd2 hc' hps hk32 =>
    -- The instruction.
    simp only [InsnOf] at hio'
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio'
    obtain ⟨hf, hsh, hfoT, hfa, hci0⟩ := call_head_op hhead hof
    have hops' : ops = [.slot d, fo, .imm (BitVec.ofNat 64 kk), .words ws] :=
      opnds_plain hops (by
        intro o ho
        simp only [List.mem_cons, List.not_mem_nil, or_false] at ho
        rcases ho with rfl | rfl | rfl | rfl
        · rfl
        · exact hfoT
        · rfl
        · rfl)
    subst hops'
    have hkk : (BitVec.ofNat 64 kk).toNat = kk := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
    have hxok : ∀ it ∈ ps, XmmOk it := fun it hit => hd.xmmOk it (by simp [hit])
    have hpsOk : Call.paramItems S.c.mode.pe ws = some ps := hps hxok
    have hseq : Call.callSeq S.c.mode.pe f fo ws = some (pre ++ ps ++ [ci]) := by
      simp [Call.callSeq, hhead, hpsOk, bind, Option.bind, pure]
    -- The code.
    have hdA : Dec (atPos S.body p) p (pre ++ ps ++ [ci]) (p3 + n) := hd.append (Dec.single hn1)
    obtain ⟨hca, hq3, hb3⟩ := hlk.dec hdA hbd
    have hn0 : 0 < n := by
      obtain ⟨-, hq3', -⟩ := hlk.dec hd hbd
      have e1 := codeSize_append (pre ++ ps) [ci]
      have e2 : codeSize [ci] = ci.size := by simp [codeSize]
      have epos : (atPos S.body p).pos = p := rfl
      omega
    -- R's step.
    rw [← hs] at hi
    obtain ⟨qq, s', hstep⟩ := call_step_ext hi hf hsh hsafe
    have hsafeQ := hsafe.2 {} qq s' hstep
    obtain ⟨s1, parts, -, -, -, hsc, hp, -, -, -, -, hsret, hpc', hfp', -, -⟩ :=
      CallLemmas.step_call hi hf hsh hstep
    have hk1 := scopes_keeps _ hsc
    have hpcS : s'.pc = s.pc := hpc'.trans hk1.pc
    have hfpS : s'.fp = s.fp := hfp'.trans hk1.fp
    have hsep1 := (sep_foldlM _ (hfb.scopesIn _) hwin hfi.rrel hfi.sep hsc).2
    have hrbpN : (x.reg .rbp).toNat = s.fp := by
      rw [hfi.rrel.rbp, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hfp64]
    have hrspN : x.rsp.toNat = s.fp - S.F := island_rsp_toNat hfi.rrel.rbp hfp64 hfpF hfi.rsp
    have hS' : FrameSep (-(S.F : Int)) S.K s'.st x ∧ AllocShape s1.st.mem s'.st.mem ∧
        s'.st.escaped = s1.st.escaped := by
      rcases hsret with heq | ⟨nn, dst, hw⟩
      · rw [heq]; exact ⟨hsep1, fun id a h => ⟨a, h, rfl, rfl, rfl⟩, rfl⟩
      · exact call_sep_uninit hsep1 hw
    obtain ⟨hsep', hshp, hesc'⟩ := hS'
    have hap : Handler.StackApart S.lo s'.st x :=
      Handler.FrameSep.stackApart hsep'
        (Handler.stack_off_window (by rw [hrbpN, hrspN]; omega) (by rw [hrbpN]; omega))
        (call_allocsApart_shape (island_allocs' H hfi hsc) hshp)
    have hb62 : S.c.d.frameSize + S.c.stackSize s.pc < 2 ^ 62 := H.stackSizes.stack s.pc
    have hlo : S.lo.toNat + 8 ≤ x.rsp.toNat := by have := hfi.room; omega
    obtain ⟨cal, regs, stack, x1, hq, hx1, he1, hstl, -, hrr1, -, -, -, -, hrsp1, hret1, hsv1,
        hmem1⟩ :=
      Call.call_query S.ctx hi hf hsh hseq hfi.rrel hfi.mem (hfb.scope_size _) hfi.rsp hb62 hlo
        (H.envApart.syms s x hfi) hstep hap
    have hrbp1 : x1.reg .rbp = x.reg .rbp := by
      show x1.regs 5 = x.regs 5; exact hsv1 5 (Island.saved_rbp _)
    -- Fetching the call.
    have hcanon : Canon (pre ++ ps ++ [ci]) p := call_canon_list (fun it hit pos => by
      rcases List.mem_append.1 hit with hit | hit
      · rcases List.mem_append.1 hit with hit | hit
        · exact (call_head_canon hhead).1 it hit pos
        · exact call_paramItems_canon hpsOk it hit pos
      · simp only [List.mem_singleton] at hit; subst hit; exact (call_head_canon hhead).2 pos) p
    have hshapes : ∀ it ∈ pre ++ ps, it.FallsThrough S.ctx ∧ it.MemKept S.ctx := by
      intro it hit
      refine call_shape_ok S.ctx ?_
      rcases List.mem_append.1 hit with hit | hit
      · rcases call_head_cases hhead with ⟨_, -, -, rfl, -⟩ | ⟨_, -, -, rfl, -⟩ |
          ⟨_, -, -, rfl, -⟩ | ⟨_, -, -, rfl, -⟩
        · cases hit
        · cases hit
        · simp only [List.mem_singleton] at hit; subst hit; exact .inr (.inr ⟨_, _, rfl⟩)
        · simp only [List.mem_singleton] at hit; subst hit; exact call_ldFrame_shape _
      · exact call_paramItems_shape hpsOk it hit
    have hsteps1 : Steps S.ctx x x1 :=
      steps_of_run_last (S := fun _ => True) hcanon hca hrip (fun _ _ => trivial)
        (fetchRun_of_forall hshapes x) hx1
    -- The callee.
    have hsafeQ' : S.Safe ⟨.call cal regs (s.fp - S.c.d.frameSize) stack, s'.world⟩ := hq ▸ hsafeQ
    have hshad : S.c.mode.pe = true → 32 ≤ stack.length := fun hpe => by
      rw [hstl]; exact H.stackSizes.shadow hpe s.pc op _ f hi hf hsh
    have hcaX : Call.CallApart S.Owned S.lo S.c.d.frameSize (S.c.stackSize s.pc)
        (s.fp - S.c.d.frameSize) s'.st x :=
      Call.FrameSep.callApart hsep' hwin (by omega) hfi.rrel.rbp hfpF
        (fun o h1 h2 => by rw [hfi.fpAddr_eq]; exact H.envApart.window o h1 h2)
    have hcaX1 := Call.callApart_congr hcaX hrbp1
    have hci' : CacheInv (S.used s.pc) x := by rw [hs]; exact hci
    have hkept := call_kept_callee H hfi hci' hsc hshp hesc' hsep' (S.c.stackSize s.pc) hstkF
    have hdb := hfb.result s.pc op d fo _ ws f hi hf hsh
    have hi' : S.c.d.insns[s'.pc]? = some (.native op [.slot d, fo, .imm (BitVec.ofNat 64 kk),
        .words ws]) := by rw [hpcS]; exact hi
    have hra : x1.mem.read64 x1.rsp = addrAt S.ctx (p3 + n) := by
      rw [hret1, hrip, hq3, addrAt_add]; rfl
    refine Reach.steps hsteps1 (Reach.env (H.envOutside.call _ _ _ _ _ _ he1) fun y hy => ?_)
    have hsa := H.sepAcross.call cal regs (s.fp - S.c.d.frameSize) stack s'.st x1 y x he1
      hsafeQ' hshad hsep'
    by_cases hry : y.rip = x1.mem.read64 x1.rsp
    · -- It returns.
      obtain ⟨a', hcr, hal⟩ := hsa.1 ⟨hy, hry⟩
      rw [hstl] at hcr
      have hrbpY : y.reg .rbp = x.reg .rbp := by
        show y.regs 5 = x.regs 5; rw [hcr.saved 5 (Island.saved_rbp _)]; exact hrbp1
      have hsepW : FrameSep (-(S.F : Int)) S.K (s'.withWorld a'.world).st y :=
        FrameSep.extend hsep' hrbpY rfl hal.1 hsep'.init hal.2.1 hal.2.2
      have hresA : Call.ResultApart (BitVec.ofNat 64 kk).toNat d (s'.withWorld a'.world).st y :=
        call_resultApart' H hfi hi hf hsh hsc hesc' hsepW
      have hcr' : Call.CallReturn S.c.mode.pe S.Owned S.lo (s'.fp - S.c.d.frameSize)
          (S.c.stackSize s'.pc) s'.world x1 y a' := by rw [hpcS, hfpS]; exact hcr
      have hmemKy : ∀ b, IslandKept S x b → y.mem b = x.mem b := fun b hb => by
        obtain ⟨h1, h2⟩ := hkept b hb
        rw [hcr.mem b h2, hmem1 b h1]
      have hlky := island_link_kept hfi.code hmemKy
      have hlk' : LinkOk S.ctx y.mem (atPos S.body p) S.rs := bs_linkOk_at hlky p
      obtain ⟨s'', x'', hans, hx'', hrr'', hmr'', hpc'', hfp'', hrip'', hrsp'', hrbp'', hsv'',
          st1, parts', regsR, hw1, hp', hfold⟩ :=
        call_return_at S.ctx hi' hf hsh hcr' (by rw [hfpS]; exact hfpF) hrr1
          (by rw [hpcS]; exact hb62) (by omega) (by rw [hpcS, hfpS]; exact hcaX1) ⟨parts, hp⟩ hresA
      have hoff := hfb.resultOff s.pc op d fo _ ws f hi hf hsh parts hp
      rw [hkk] at hp hx''
      have hyrip : y.rip = addrAt S.ctx (p3 + n) := by rw [hry, hra]
      obtain ⟨hca2, hcpos, hbE⟩ := hlk'.dec hd2 hb3
      obtain ⟨hsteps2, hrip2, hmem2⟩ := call_stores_steps H hfi hp hdb hoff hca2
        (fun b hb => by
          obtain ⟨j, hj, rfl⟩ := call_dec_inCode hlk' hd2 hb3 b hb
          exact .inl ⟨j, hj, rfl⟩) hyrip hrbpY hx''
      have hmemK'' : ∀ b, IslandKept S x b → x''.mem b = x.mem b :=
        fun b hb => (hmem2 b hb).trans (hmemKy b hb)
      have hsepX : FrameSep (-(S.F : Int)) S.K s''.st x'' :=
        FrameSep.congr hrbp'' (call_sep_answer H hsepW (by rw [hpcS]; exact hstkF) hw1 hdb hp'
          hfold)
      have hrbpX : x''.reg .rbp = x.reg .rbp := hrbp''.trans hrbpY
      have hrspX : x''.rsp = x.rsp := by
        rw [hrsp'', hcr.rsp, hrsp1]; exact BitVec.sub_add_cancel _ _
      have hsvX : ∀ i, Saved S.c.mode.pe i → x''.regs i = x.regs i := fun i hi => by
        rw [hsv'' i hi, hcr.saved i hi, hsv1 i hi]
      have hpcK : s''.pc = k + 1 := by rw [hpc'', hpcS, hs]
      have hFI : FrameInv S s'' x'' := by
        refine ⟨hrr'', hmr'', hsepX, by rw [hfp'', hfpS]; exact hwinT,
          by rw [hfp'', hfpS]; exact hfpF, by rw [hrspX, hrbpX]; exact hfi.rsp,
          by rw [hrspX]; exact hfi.room, island_link_kept hfi.code hmemK'',
          island_ro_kept hfi.ro hmemK'', ?_,
          island_frame_kept hfi.frame hmemK'' hrbpX (fun i hi _ => hsvX i hi)⟩
        rintro ⟨hlt', ha⟩
        change s''.pc < S.r.protos.size at hlt'
        change S.args (s''.pc + 1) = true at ha
        rw [hpcK] at hlt' ha
        have h1 : S.args (k + 1) = false := by
          rw [hargs]; show (S.args k && (f == Full.Opcode.arg)) = false
          rw [hfa, Bool.and_false]
        have h2 := hD.argsSucc (k + 1) (by simpa using hlt')
        rw [h1] at h2
        simp [h2] at ha
      have fin : ∀ z : X86.State, z.regs = x''.regs → z.xmm = x''.xmm → z.mem = x''.mem →
          z.rip = addrAt S.ctx (S.start (k + 1)) → Reach S.ctx S.E (SNext S s) z := by
        intro z hzr hzx hzm hzrip
        refine .done (.inl ⟨_, .answer hstep hans, hFI.congr hzr hzx hzm, .inl ⟨?_, ?_⟩⟩)
        · change z.rip = addrAt S.ctx (S.start s''.pc)
          rw [hpcK]; exact hzrip
        · change CacheInv (S.cache s''.pc) z
          rw [hpcK, hcache]; exact CacheInv.emptyPe _ _
      refine Reach.steps hsteps2 ?_
      have hxrip : x''.rip = addrAt S.ctx c'.pos := by rw [hrip2, hcpos]
      have hlkX := island_link_kept hfi.code hmemK''
      generalize hE : S.start (k + 1) = pE at hnop fin
      generalize hC : c'.pos = pC at hnop hxrip hbE
      cases hnop with
      | none _ => exact fin x'' rfl rfl rfl hxrip
      | nop _ hby hrl =>
        obtain ⟨hit, -, -⟩ := nop_itemAt hlkX (p := pC) (n := 1) (by omega) (by omega)
          (island_nop_bytes hby) hrl hbE
        refine reach_padding (ns := [1]) (by simp) ⟨hit, trivial⟩ hxrip fun z h1 h2 h3 h4 => ?_
        refine fin z h1 h2 h3 ?_
        rw [h4]; rfl
    · -- It unwinds.
      obtain ⟨a', exc, hres, hend, hland, hal⟩ := hsa.2 ⟨hy, hry⟩
      rw [hstl] at hend
      have hpads := H.padsLinked k hlt (p3, n) (by rw [hpk]; simp) (p3 + n)
        (by show p3 < p3 + n; omega) (by show p3 + n ≤ p3 + n; omega)
      have hl := hland.rip
      rw [hra, hpads] at hl
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
        have h32 := posOf_lt_32 hD hfi.code (pad_lpad hD hcl).1
        have e : (pos32 S.r pad).setWidth 64 = BitVec.ofNat 64 (posOf S.r pad) := by
          apply BitVec.eq_of_toNat_eq
          rw [BitVec.toNat_setWidth, pos32, BitVec.toNat_ofNat, BitVec.toNat_ofNat,
            Nat.mod_eq_of_lt h32]
        rw [e]; rfl
      have hrbpY : y.reg .rbp = x.reg .rbp := by
        show y.regs 5 = x.regs 5; rw [hland.saved 5 (Island.saved_rbp _)]; exact hrbp1
      have hsepW : FrameSep (-(S.F : Int)) S.K (s'.withWorld a'.world).st y :=
        FrameSep.extend hsep' hrbpY rfl hal.1 hsep'.init hal.2.1 hal.2.2
      have hpad' : S.c.cleanupAt s'.pc = some (some pad, cat) := by rw [hpcS, hs]; exact hcl
      have hend' : Call.CallEnd S.Owned S.lo (s'.fp - S.c.d.frameSize) (S.c.stackSize s'.pc)
          s'.world x1 y a' := by rw [hpcS, hfpS]; exact hend
      obtain ⟨st1, hw1, hans, hrrY, hmrY⟩ := call_unwind_at hi' hf hsh hres hend' hland
        (by rw [hfpS]; exact hfpF) hrr1 (by rw [hpcS]; exact hb62)
        (by rw [hpcS, hfpS]; exact hcaX1) hpad'
      have hsepY : FrameSep (-(S.F : Int)) S.K st1 y := island_sep_writeRanges hsepW
        (fun r hr => by
          simp only [List.mem_singleton] at hr; subst hr
          refine ⟨Int.le_refl _, ?_⟩
          show -(S.c.d.frameSize : Int) + (S.c.stackSize s'.pc : Int) ≤ S.K
          rw [hpcS]; omega) hw1
      have hmemKy : ∀ b, IslandKept S x b → y.mem b = x.mem b := fun b hb => by
        obtain ⟨h1, h2⟩ := hkept b hb
        rw [hend.mem b h2, hmem1 b h1]
      have hrspY : y.rsp = x.rsp := by rw [hland.rsp, hrsp1]; exact BitVec.sub_add_cancel _ _
      have hsvY : ∀ i, Saved S.c.mode.pe i → y.regs i = x.regs i := fun i hi => by
        rw [hland.saved i hi, hsv1 i hi]
      refine .done (.inl ⟨_, .answer hstep hans, ?_⟩)
      refine ⟨⟨hrrY, hmrY, ⟨hsepY.own, hsepY.init, hsepY.dis, hsepY.space⟩,
        by show (s'.fp : Int) + _ ≤ _; rw [hfpS]; exact hwinT,
        by show S.c.d.frameSize ≤ s'.fp; rw [hfpS]; exact hfpF,
        by rw [hrspY, hrbpY]; exact hfi.rsp, by rw [hrspY]; exact hfi.room,
        island_link_kept hfi.code hmemKy, island_ro_kept hfi.ro hmemKy, ?_,
        island_frame_kept hfi.frame hmemKy hrbpY (fun i hi _ => hsvY i hi)⟩, .inr ⟨hyrip, ?_⟩⟩
      · intro h
        exact absurd h (pad_not_leadArg hD hcl)
      · change CacheInv (S.used pad) y
        rw [H.cacheCleared.pads k pad cat hcl]; exact CacheInv.emptyPe _ _
  | @tail w f fo pre ps j ws c'' hhead hd hc' hps =>
    simp only [InsnOf] at hio'
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio'
    obtain ⟨hf, hsh, hfoT⟩ := call_tail_op hhead hof
    have hops' : ops = [fo, .words ws] :=
      opnds_plain hops (by
        intro o ho
        simp only [List.mem_cons, List.not_mem_nil, or_false] at ho
        rcases ho with rfl | rfl
        · exact hfoT
        · rfl)
    subst hops'
    have hxok : ∀ it ∈ ps, XmmOk it := fun it hit => hd.xmmOk it (by simp [hit])
    have hpsOk : Call.paramItems S.c.mode.pe ws = some ps := hps hxok
    have eE : S.fr.epilogue = epilogue S.c.d.frameSize S.c.mode := by
      show epilogue S.r.frameSize S.c.mode = _
      rw [reducedOf_frameSize hD.reduced]
    rw [eE] at hd
    have hseq : Call.tailSeq S.c.d.frameSize S.c.mode w f fo ws =
        some (pre ++ ps ++ (epilogue S.c.d.frameSize S.c.mode ++ [j])) := by
      simp [Call.tailSeq, hhead, hpsOk, bind, Option.bind, pure]
    obtain ⟨hca, -, -⟩ := hlk.dec hd hbd
    rw [← hs] at hi
    obtain ⟨fin, hstep⟩ := tail_step_done hi hf hsh hsafe
    obtain ⟨s1, cal, regs, stack, x', hfin, -, -, -, -, hx', hent, -, hrsp', hrbp', -, hsv'⟩ :=
      Call.tail_call_step S.ctx hi hf hsh hseq hfi.rrel hfi.mem (hfb.scope_size _)
        (fun h1 => ⟨hfi.rsp, by
          rcases h1 with h1 | h1
          · exact H.peFrame h1
          · exact absurd (h1.symm.trans H.fp) (by decide)⟩)
        (by have := H.stackSizes.stack s.pc; omega) hstep
    rw [← List.append_assoc] at hx' hca
    have hcanon : Canon (pre ++ ps ++ epilogue S.c.d.frameSize S.c.mode ++ [j]) p :=
      call_canon_list (fun it hit pos => by
        rcases List.mem_append.1 hit with hit | hit
        · rcases List.mem_append.1 hit with hit | hit
          · rcases List.mem_append.1 hit with hit | hit
            · exact (call_tailHead_canon hhead).1 it hit pos
            · exact call_paramItems_canon hpsOk it hit pos
          · exact call_epilogue_canon _ _ it hit pos
        · simp only [List.mem_singleton] at hit; subst hit
          exact (call_tailHead_canon hhead).2 pos) p
    have hshapes : ∀ it ∈ pre ++ ps ++ epilogue S.c.d.frameSize S.c.mode,
        it.FallsThrough S.ctx ∧ it.MemKept S.ctx := by
      intro it hit
      refine call_shape_ok S.ctx ?_
      rcases List.mem_append.1 hit with hit | hit
      · rcases List.mem_append.1 hit with hit | hit
        · rcases call_tail_cases hhead with ⟨_, -, -, rfl⟩ | ⟨_, -, -, rfl⟩
          · cases hit
          · simp only [List.mem_singleton] at hit; subst hit; exact call_ldFrame_shape _
        · exact call_paramItems_shape hpsOk it hit
      · exact .inl (ret_epilogue_shape _ _ it hit)
    have hsteps : Steps S.ctx x x' :=
      steps_of_run_last (S := fun _ => True) hcanon hca hrip (fun _ _ => trivial)
        (fetchRun_of_forall hshapes x) hx'
    subst hfin
    refine Reach.steps hsteps (.done (.inr ⟨_, .step hstep, hent.world, hent, ?_, ?_⟩))
    · rw [hrsp']; have := hfi.frame.rbp; bv_omega
    · intro i hsv
      by_cases h5 : i = 5
      · subst h5
        exact (hrbp' (.inr H.fp)).trans hfi.frame.savedRbp
      · rw [hsv' i hsv h5]; exact hfi.frame.saved i hsv h5

end Insn

end Ryo.Proofs.DecodeSound
