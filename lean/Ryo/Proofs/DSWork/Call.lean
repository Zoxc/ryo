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
  | tail {f : Full.Opcode} {fo : Opnd Nat} {pre ps : List Item} {j : Item} {ws : List (BitVec 32)}
      {c' : Cursor} :
      Call.tailHead f fo = some (pre, j) →
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
  have fin_tail : ∀ f fo j (cE : Cursor) n2, Call.tailHead f fo = some (preItems pr, j) →
      Dec c c3.pos fr.epilogue cE.pos → cE = atPos c cE.pos →
      decodeItem cE = some (j, n2) →
      r = some (f, [fo, .words ws], false) → c6 = atPos cE (cE.pos + n2) →
      CallReadS fr c q c' := by
    intro f fo j cE n2 hhead dE eE hn2 hr hc6
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
      exact fin_tail _ _ _ cE n2 (head_tailCall _) dE' eE' hn2 rfl rfl
    · obtain ⟨rfl, rfl⟩ := pure_ok h6
      obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some h8
      exact fin_tail _ _ _ cE n2 (head_tailCallPtr _) dE' eE' hn2 rfl rfl
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
  /- Proof idea: unfold ArgReg.of?; split on the 'ok' condition (by cases on a.xmm, not split, which fails on the Bool.rec motive); omega.
  The earlier attempt (broke against the current library):
  unfold ArgReg.of? at h
  simp only at h
  split at h
  · rename_i hc
    cases h
    intro hx
    simp only [hx, ↓reduceIte, Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq,
      decide_eq_true_eq] at hc
    omega
  · cases h -/

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


theorem call_tailHead_canon {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item} {j : Item}
    (h : Call.tailHead f fo = some (pre, j)) :
    (∀ i ∈ pre, ∀ pos, i.Canonical pos) ∧ ∀ pos, j.Canonical pos := by
  unfold Call.tailHead at h
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
so a private window byte (`MoreBounds.result`: the slots are in the window) is in no live
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
  have hb := H.moreBounds.result s.pc op d fo k ws f hi hof hsh
  have h16 := ((CallLemmas.retRegsS_parts hp d).2.1 q hq).2.2
  refine ⟨hpe, fun id al hg hl hin => ?_⟩
  obtain ⟨e, hem, h1, h2, -⟩ := hsep.own id al _ hg hl (by omega) (by omega) hin
  exact escapedAt_none hpe e hem ⟨h1, h2⟩

/-- `bodySim_call`. Proof idea: `noArg_call`, `link_call_ok` (the items in memory, canonical by
`call_head_canon`/`call_paramItems_canon`/`call_epilogue_canon`); a call: `Call.call_sound` with
`StackSizes` (`hb`, `hshadow`), `MoreBounds.result` (`hd`), `EnvApart.syms`, `StackApart` from
`EnvApart.allocs`/`FrameSep`, `CallApart` by `FrameSep.callApart`, `call_resultApart'`; the
environment step at the callee (`H.envOutside.call`); its return to `k + 1` (cache `{}`,
`hP.cache`) with `FrameSep` by `SepAcross.call`, `FrameFacts` and the code kept (`LinkPrivate`,
`CodeApart`, `EnvApart.window`), `S.args (k + 1) = false` (`hP.args`, a call isn't an `arg`);
an unwind: `Call.call_unwind` with `PadsLinked` and `posOf_lt_32` for `hpos`, to the pad
(`pad_not_leadArg`, `CacheCleared.pads`), or no return (`Landed.rip` with `padOf = none`); a
tail call: `Call.tail_call_step` (`hn` from `StackSizes.stack`), `ExitRel`'s `tailCall` from
`FrameFacts`. -/
theorem bodySim_call' (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (callInsn S.fr (S.dr k)).run cur = .ok (some q, c')) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_call'

end Insn

end Ryo.Proofs.DecodeSound
