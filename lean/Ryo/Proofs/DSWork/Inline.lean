import Lean
import Ryo.Proofs.DecodeSound.Basic
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

/-! ### Helpers -/

set_option maxRecDepth 100000 in
theorem inline_ofFullTable : (List.range Reduced.ofFullTable.size).all (fun i =>
    (Reduced.ofFullTable[i]!).all fun op =>
      Reduced.toFullTable[op.val.toNat]! == some ⟨i.toUInt16⟩) = true := by
  decide +kernel

set_option maxRecDepth 100000 in
/-- `Opcode.ofFull` and `Opcode.full` agree. -/
theorem inline_full_of {f : Full.Opcode} {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull f = some op) : op.full = some f := by
  unfold Reduced.Opcode.ofFull at h
  have hlt : f.val.toNat < Reduced.ofFullTable.size := by
    refine Classical.byContradiction fun hn => ?_
    rw [getElem!_neg Reduced.ofFullTable f.val.toNat hn] at h
    cases h
  have := List.all_eq_true.1 inline_ofFullTable f.val.toNat (List.mem_range.2 hlt)
  rw [h] at this
  simp only [Option.all_some, beq_iff_eq] at this
  unfold Reduced.Opcode.full
  rw [this]
  congr
  simp

section
variable {T U : Type} (g : T → U) (a : Option (Opnd T))
theorem inline_m_slot (s) : a.map (opndMap g) = some (.slot s) ↔ a = some (.slot s) := by
  rcases a with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> simp [opndMap]
theorem inline_m_imm (s) : a.map (opndMap g) = some (.imm s) ↔ a = some (.imm s) := by
  rcases a with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> simp [opndMap]
theorem inline_m_neg (s) : a.map (opndMap g) = some (.neg s) ↔ a = some (.neg s) := by
  rcases a with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> simp [opndMap]
theorem inline_m_const (s) : a.map (opndMap g) = some (.const s) ↔ a = some (.const s) := by
  rcases a with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> simp [opndMap]
theorem inline_m_data (s) : a.map (opndMap g) = some (.data s) ↔ a = some (.data s) := by
  rcases a with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> simp [opndMap]
theorem inline_m_sym (s) : a.map (opndMap g) = some (.sym s) ↔ a = some (.sym s) := by
  rcases a with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> simp [opndMap]
theorem inline_m_mem (s k) : a.map (opndMap g) = some (.mem s k) ↔ a = some (.mem s k) := by
  rcases a with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> simp [opndMap]
end

set_option hygiene false in
/-- Case on operand `i` of `ops` (none or each constructor), closing what reduces. -/
local macro "seq_case " i:num : tactic =>
  `(tactic| all_goals (generalize (ops[$i]?) = x; rcases x with _ | ⟨_|_|_|_|_|_|_|_|_|_|_|_|_|_⟩ <;> try rfl))

/-- `sequence` doesn't look at targets. -/
theorem inline_seq_map {T U : Type} (g : T → U) (c : Class) (ops : List (Opnd T)) :
    sequence c (ops.map (opndMap g)) = sequence c ops := by
  cases c <;> unfold sequence <;> simp only [List.getElem?_map]
  case mov => seq_case 1; seq_case 0
  case mov128 => seq_case 1; seq_case 0
  case imm => seq_case 1; seq_case 0
  case addr => seq_case 1; seq_case 0
  case addrConst => seq_case 1; seq_case 0
  case addrSym => seq_case 1; seq_case 0
  case addrSymInd => seq_case 1; seq_case 0
  case ptrAdd => seq_case 2; seq_case 1; seq_case 0
  case ptrIndex => seq_case 3; seq_case 1; seq_case 2; seq_case 0
  case load => seq_case 1; seq_case 0
  case store => seq_case 0; seq_case 1
  case bin => seq_case 1; seq_case 2; seq_case 0
  case binImm => seq_case 2; seq_case 1; seq_case 0
  case mul => seq_case 1; seq_case 2; seq_case 0
  case mulImm => seq_case 2; seq_case 1; seq_case 0
  case shiftImm => seq_case 2; seq_case 1; seq_case 0
  case cmp => seq_case 1; seq_case 2; seq_case 0
  case cmpImm => seq_case 1; seq_case 2; seq_case 0
  case br => seq_case 0; seq_case 1
  case brCmp => seq_case 0; seq_case 1; seq_case 2
  case brCmpImm => seq_case 0; seq_case 1; seq_case 2
  case ovf => seq_case 1; seq_case 2; seq_case 3; seq_case 0
  case mulOvf => seq_case 2; seq_case 3; seq_case 0; seq_case 1
  case ext => seq_case 1; seq_case 0
  case shiftVar => seq_case 1; seq_case 2; seq_case 0
  case div => seq_case 1; seq_case 2; seq_case 0
  case count => seq_case 1; seq_case 0
  case cmp3 => seq_case 1; seq_case 2; seq_case 0
  case bswap => seq_case 1; seq_case 0

/-- What `inline_classOfParts` says of a class. -/
def inline_okC : Class → Prop
  | .ovf op _ _ => op = .add ∨ op = .sub
  | .ext a _ true => a ≠ .q
  | .shiftImm sh _ => sh.isShift = true
  | _ => True

theorem inline_ec {α : Sort _} {β : Sort _} {a b : α} (x : β) (h : a = b) :
    @Eq.rec α a (fun _ _ => β) x b h = x := by subst h; rfl

open Lean Meta Elab Tactic in
/-- Rewrite `h` with the equation `heq`. -/
def inline_rwH (mk : TacticM Expr) : TacticM Unit := withMainContext do
  let heq ← mk
  let some ld := (← getLCtx).findFromUserName? `h | throwError "no h"
  let g ← getMainGoal
  let r ← g.rewrite ld.type heq
  let mv ← g.replaceLocalDecl ld.fvarId r.eNew r.eqProof
  replaceMainGoal (mv.mvarId :: r.mvarIds)

open Lean Meta Elab Tactic in
/-- Decide the outermost `dite` of `h`: by `decide` when closed, by a hypothesis `¬ c`, or
split (substituting the variable when it equals a literal). -/
elab "inline_dite_step" : tactic => withMainContext do
  let some ld := (← getLCtx).findFromUserName? `h | throwError "no h"
  let ty ← instantiateMVars ld.type
  let some e := ty.find? (fun e => e.isAppOfArity ``dite 5 && !(e.getArg! 1).hasLooseBVars)
    | throwError "no dite"
  let c := e.getArg! 1
  let inst := e.getArg! 2
  let args (p : Expr) : Array (Option Expr) :=
    #[some c, some inst, some p, some (e.getArg! 0), some (e.getArg! 3), some (e.getArg! 4)]
  let pos (p : Expr) : MetaM Expr := mkAppOptM ``dif_pos (args p)
  let neg (p : Expr) : MetaM Expr := mkAppOptM ``dif_neg (args p)
  if !c.hasFVar then
    let d ← mkDecide c
    let dv ← whnfD d
    if dv.isConstOf ``true then
      inline_rwH (do pos (← mkDecideProof c))
    else
      inline_rwH (do neg (← mkDecideProof (mkNot c)))
    return
  if let some ldn ← findLocalDeclWithType? (mkNot c) then
    inline_rwH (neg (mkFVar ldn))
    return
  let r ← (← getMainGoal).byCases c `hc
  replaceMainGoal [r.1.mvarId]
  inline_rwH (pos (mkFVar r.1.fvarId))
  evalTactic (← `(tactic| try subst hc))
  let gs ← getGoals
  setGoals [r.2.mvarId]
  inline_rwH (neg (mkFVar r.2.fvarId))
  setGoals (gs ++ (← getGoals))

theorem inline_q_lt {b : W} (h : W.q.bits < b.bits) : False := by
  cases b <;> simp [W.bits] at h

set_option hygiene false in
macro "inline_cop_tac" : tactic => `(tactic| (
  unfold classOfParts at h
  delta classOfParts.match_11 at h
  simp only [classOfParts._sparseCasesOn_11, classOfParts._sparseCasesOn_12] at h
  repeat' inline_dite_step
  all_goals (try simp only [inline_ec, Functor.map, Option.map, bind, Option.bind, pure,
    Option.some.injEq, reduceCtorEq] at h)
  all_goals repeat' (split at h <;> try simp only [inline_ec, Functor.map, Option.map, bind,
    Option.bind, pure, Option.some.injEq, reduceCtorEq] at h)
  all_goals (subst h; simp only [inline_okC])
  all_goals first | trivial | (rintro rfl; exact inline_q_lt ‹_›) | simp))

theorem inline_cop0 {cls : Class} (h : classOfParts [] = some cls) :
    inline_okC cls := by inline_cop_tac
theorem inline_cop1 {cls : Class} (a : String) (h : classOfParts [a] = some cls) :
    inline_okC cls := by inline_cop_tac
theorem inline_cop2 {cls : Class} (a b : String) (h : classOfParts [a, b] = some cls) :
    inline_okC cls := by inline_cop_tac
theorem inline_cop3 {cls : Class} (a b c : String) (h : classOfParts [a, b, c] = some cls) :
    inline_okC cls := by inline_cop_tac
theorem inline_cop4 {cls : Class} (a b c d : String) (h : classOfParts [a, b, c, d] = some cls) :
    inline_okC cls := by inline_cop_tac
theorem inline_cop5 {cls : Class} (a b c d e : String)
    (h : classOfParts [a, b, c, d, e] = some cls) :
    inline_okC cls := by inline_cop_tac
theorem inline_cop6 {cls : Class} (a b c d e f : String) (l : List String)
    (h : classOfParts (a :: b :: c :: d :: e :: f :: l) = some cls) :
    inline_okC cls := by inline_cop_tac

/-- The inline classes: no `ovf` but `add`/`sub`, no sign extension from 64 bits. -/
theorem inline_classOfParts (ps : List String) {cls : Class} (h : classOfParts ps = some cls) :
    (∀ op s w, cls = .ovf op s w → op = .add ∨ op = .sub) ∧ (∀ b, cls ≠ .ext .q b true) ∧
      (∀ sh w, cls = .shiftImm sh w → sh.isShift = true) := by
  have hk : inline_okC cls := by
    rcases ps with _ | ⟨a, _ | ⟨b, _ | ⟨c, _ | ⟨d, _ | ⟨e, _ | ⟨f, l⟩⟩⟩⟩⟩⟩
    · exact inline_cop0 h
    · exact inline_cop1 _ h
    · exact inline_cop2 _ _ h
    · exact inline_cop3 _ _ _ h
    · exact inline_cop4 _ _ _ _ h
    · exact inline_cop5 _ _ _ _ _ h
    · exact inline_cop6 _ _ _ _ _ _ _ h
  refine ⟨fun op s w e => by subst e; exact hk, fun b e => by subst e; exact hk rfl,
    fun sh w e => by subst e; exact hk⟩

theorem inline_class_of {f : Full.Opcode} {cls : Class} (h : (f, cls) ∈ inlineOps) :
    (∀ op s w, cls = .ovf op s w → op = .add ∨ op = .sub) ∧ (∀ b, cls ≠ .ext .q b true) ∧
      (∀ sh w, cls = .shiftImm sh w → sh.isShift = true) := by
  simp only [inlineOps, List.mem_filterMap, Option.map_eq_some_iff, Prod.mk.injEq] at h
  obtain ⟨a, -, c', hc', rfl, rfl⟩ := h
  exact inline_classOfParts _ hc'

theorem inline_dec_split {c : Cursor} :
    ∀ {p q : Nat} {a b : List Item}, Dec c p (a ++ b) q → ∃ m, Dec c p a m ∧ Dec c m b q
  | p, q, [], b, h => ⟨p, .nil _, h⟩
  | p, q, i :: a, b, h => by
    cases h with
    | cons hd hrest =>
      obtain ⟨m, h1, h2⟩ := inline_dec_split hrest
      exact ⟨m, .cons hd h1, h2⟩

theorem inline_named_mem {α β : Type} {l : List α} {ops : List β} {p : α × β → Bool} {o : β}
    (h : ((l.zip ops).find? p).map (·.2) = some o) : o ∈ ops := by
  obtain ⟨⟨a, b⟩, hf, rfl⟩ := Option.map_eq_some_iff.1 h
  exact (List.of_mem_zip (List.mem_of_find?_eq_some hf)).2

theorem inline_ctl_targets {f : Full.Opcode} {ops : List (R.Opnd Nat)} {t : R.Then Nat}
    (h : R.nativeCtl f ops = some t) {x : Nat} (hx : x ∈ t.targets) :
    ∃ o ∈ ops, x ∈ o.targetsOf := by
  unfold R.nativeCtl at h
  simp only [pure] at h
  split at h
  all_goals first
    | (simp only [Option.some.injEq, reduceCtorEq] at h; subst h; simp [Then.targets] at hx; done)
    | (simp only [reduceCtorEq] at h; done)
    | skip
  · split at h
    · rename_i heq
      simp only [Option.some.injEq] at h
      subst h
      simp only [Then.targets, List.mem_singleton] at hx
      subst hx
      simp only [Prod.mk.injEq] at heq
      exact ⟨_, inline_named_mem heq.2, by simp [Opnd.targetsOf]⟩
    · simp at h
  · split at h
    · rename_i heq
      simp only [Option.some.injEq] at h
      subst h
      simp only [Then.targets, List.mem_append, List.mem_flatMap, List.mem_singleton] at hx
      rcases hx with ⟨o, ho, hx⟩ | rfl
      · refine ⟨o, ho, ?_⟩
        cases o <;> simp_all [Opnd.targetsOf]
      · exact ⟨_, inline_named_mem heq, by simp [Opnd.targetsOf]⟩
    · simp at h

theorem inline_succ {t : R.Then Nat} {pc pc' : Nat} {c : Control} (h : t.succ pc c = some pc') :
    pc' = pc + 1 ∨ pc' ∈ t.targets := by
  unfold R.Then.succ at h
  split at h
  · cases h; exact .inl rfl
  · cases h; split <;> simp [Then.targets]
  · exact .inr (List.mem_of_getElem? h)
  · cases h

theorem inline_targetsOf_map {T U : Type} (g : T → U) (o : R.Opnd T) :
    (opndMap g o).targetsOf = o.targetsOf.map g := by
  cases o <;> simp [opndMap, Opnd.targetsOf]

/-! ### `opSem` of an inline opcode is never `noBehavior` (with the default choice) -/

theorem inline_ill_eq {α : Type} (s : String) : (illFormed s : M α) = .error (.illFormed s) := rfl
theorem inline_ub_eq {α : Type} (s : String) : (ub s : M α) = .error (.ub s) := rfl
theorem inline_throw_eq {α : Type} (e : Stop) : (throw e : M α) = .error e := rfl
theorem inline_tub {α : Type} {s : String} {e : Outcome}
    (h : (throwUb s : Except Outcome α) = .error e) : e = .ub s := by cases h; rfl

/-- A leaf computation: unfold, split, and see each error isn't `noBehavior`. -/
macro "inline_nb_leaf" : tactic =>
  `(tactic| (intro msg h; (repeat' split at h); all_goals first | cases h | simp_all [inline_ill_eq, inline_ub_eq, inline_throw_eq]))

theorem inline_nb_err {α : Type} (e : Stop) (he : ∀ m, e ≠ .noBehavior m) :
    NoNB (Except.error e : M α) := fun m h => he m (by cases h; rfl)

theorem inline_nb_bind {α β : Type} {m : M α} {f : α → M β} (h : NoNB m)
    (hf : ∀ a, NoNB (f a)) : NoNB (m >>= f) := noNB_bind h fun a _ => hf a

theorem inline_nb_parseTy (p : Option String) : NoNB (OpSem.parseTy p) := by
  unfold OpSem.parseTy; inline_nb_leaf
theorem inline_nb_intTy (p : Option String) : NoNB (OpSem.intTy p) := by
  unfold OpSem.intTy; refine inline_nb_bind (inline_nb_parseTy p) fun t => ?_; inline_nb_leaf
theorem inline_nb_asNat (bs : List AbstractByte) : NoNB (asNat bs) := by
  unfold asNat; inline_nb_leaf
theorem inline_nb_asPtr (bs : List AbstractByte) : NoNB (asPtr bs) := by
  unfold asPtr; inline_nb_leaf
theorem inline_nb_intCmp (o : String) (s : Bool) {w : Nat} (a b : BitVec w) :
    NoNB (intCmp o s a b) := by
  unfold intCmp; inline_nb_leaf
theorem inline_nb_intBin (m : String) (s : Bool) {w : Nat} (a b : BitVec w) :
    NoNB (intBin m s a b) := by
  unfold intBin; inline_nb_leaf
theorem inline_nb_intOvf (m : String) (s : Bool) {w : Nat} (a b : BitVec w) :
    NoNB (intOvf m s a b) := by
  unfold intOvf; inline_nb_leaf
theorem inline_nb_intRot (m : String) {w : Nat} (a : BitVec w) (b : Nat) :
    NoNB (intRot m a b) := by
  unfold intRot; inline_nb_leaf
theorem inline_nb_intCount (m : String) {w : Nat} (a : BitVec w) : NoNB (intCount m a) := by
  unfold intCount; inline_nb_leaf
theorem inline_nb_intUn (m : String) {w : Nat} (a : BitVec w) : NoNB (intUn m a) := by
  unfold intUn; inline_nb_leaf
theorem inline_nb_convert (x y : OpSem.Ty) (v : Nat) : NoNB (OpSem.convert {} x y v) := by
  unfold OpSem.convert; split <;> try exact noNB_pure _
  unfold resolveNaN; split
  · exact noNB_pure _
  · exact noNB_pure _
theorem inline_nb_addrOf (st : OpSem.State) (s : Int) : NoNB (st.addrOf s) := by
  unfold OpSem.State.addrOf; inline_nb_leaf

theorem inline_nb_lift {α : Type} {x : Except Outcome α} (h : ∀ m, x ≠ .error (.noBehavior m)) :
    NoNB (liftOutcome x) := by
  intro m hm
  unfold liftOutcome at hm
  split at hm
  all_goals first | exact h _ rfl | exact h _ (by assumption) | cases hm
theorem inline_nb_checkPtr (mem : Memory) (p : ThinPointer) (n : Nat) (m : String) :
    mem.checkPtr p n ≠ .error (.noBehavior m) := by
  intro h
  unfold Memory.checkPtr at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  repeat' split at h
  all_goals first | (cases h; done) | (cases h; have := inline_tub ‹_›; cases this) |
    (have := inline_tub ‹_›; subst this; cases h)
theorem inline_nb_memLoad (mem : Memory) (p : ThinPointer) (n : Nat) (al : Align) (m : String) :
    mem.load p n al ≠ .error (.noBehavior m) := by
  intro h
  unfold Memory.load at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  repeat' split at h
  all_goals first | (cases h; done) | (cases h; have := inline_tub ‹_›; cases this) |
    (have := inline_tub ‹_›; subst this; cases h) | skip
  all_goals (rename_i hc; exact inline_nb_checkPtr _ _ _ _ (by rw [hc]; cases h; rfl))
theorem inline_nb_memStore (mem : Memory) (p : ThinPointer) (bs : List AbstractByte) (al : Align)
    (m : String) : mem.store p bs al ≠ .error (.noBehavior m) := by
  intro h
  unfold Memory.store at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  repeat' split at h
  all_goals first | (cases h; done) | (cases h; have := inline_tub ‹_›; cases this) |
    (have := inline_tub ‹_›; subst this; cases h) | skip
  all_goals (rename_i hc; exact inline_nb_checkPtr _ _ _ _ (by rw [hc]; cases h; rfl))
theorem inline_nb_load (st : OpSem.State) (p : ThinPointer) (n : Nat) (al : Align) :
    NoNB (st.load p n al) := inline_nb_lift (inline_nb_memLoad _ _ _ _)
theorem inline_nb_store (st : OpSem.State) (mem : Memory) (p : ThinPointer) (bs : List AbstractByte)
    (al : Align) : NoNB (st.store mem p bs al) := inline_nb_lift (inline_nb_memStore _ _ _ _)

section
variable (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
include hrd
theorem inline_nb_int (n : String) : NoNB (e.int n) :=
  inline_nb_bind (hrd n) fun _ => inline_nb_asNat _
theorem inline_nb_bv (n : String) (sz : Nat) : NoNB (e.bv n sz) :=
  inline_nb_bind (inline_nb_int e hrd n) fun _ => noNB_pure _
theorem inline_nb_ptr (n : String) : NoNB (e.ptr n) :=
  inline_nb_bind (hrd n) fun _ => inline_nb_asPtr _
theorem inline_nb_memPtr (n : String) : NoNB (e.memPtr n) := by
  unfold OpSem.Env.memPtr; split
  · exact inline_nb_bind (inline_nb_ptr e hrd n) fun _ => noNB_pure _
  · exact noNB_ill _
end
theorem inline_nb_imm (e : OpSem.Env) (n : String) : NoNB (e.imm n) := by
  unfold OpSem.Env.imm; inline_nb_leaf
theorem inline_nb_immBv (e : OpSem.Env) (n : String) (sz : Nat) : NoNB (e.immBv n sz) :=
  inline_nb_bind (inline_nb_imm e n) fun _ => noNB_pure _
theorem inline_nb_slot (e : OpSem.Env) (n : String) : NoNB (e.slot n) := by
  unfold OpSem.Env.slot; inline_nb_leaf
theorem inline_nb_addr (e : OpSem.Env) (n : String) : NoNB (e.addr n) := by
  unfold OpSem.Env.addr; inline_nb_leaf

set_option hygiene false in
/-- Close a `NoNB` goal of a `do` block from the leaves above. -/
macro "inline_nb" : tactic => `(tactic| repeat' (first
  | exact noNB_pure _ | exact noNB_ill _ | exact noNB_ub _
  | exact inline_nb_err _ (fun _ h => by cases h)
  | exact hrd _
  | exact inline_nb_intTy _ | exact inline_nb_parseTy _ | exact inline_nb_intCmp _ _ _ _
  | exact inline_nb_intBin _ _ _ _ | exact inline_nb_intOvf _ _ _ _ | exact inline_nb_convert _ _ _
  | exact inline_nb_intRot _ _ _ | exact inline_nb_intCount _ _ | exact inline_nb_intUn _ _
  | exact inline_nb_addrOf _ _ | exact inline_nb_load _ _ _ _ | exact inline_nb_store _ _ _ _ _
  | exact inline_nb_int _ hrd _ | exact inline_nb_bv _ hrd _ _ | exact inline_nb_ptr _ hrd _
  | exact inline_nb_memPtr _ hrd _ | exact inline_nb_imm _ _ | exact inline_nb_immBv _ _ _
  | exact inline_nb_slot _ _ | exact inline_nb_addr _ _ | exact inline_nb_asPtr _
  | exact inline_nb_asNat _
  | (refine inline_nb_bind ?_ fun _ => ?_)
  | split
  | (simp only [] ; done)))

theorem inline_nbk_mov (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .mov ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_imm (ps : List String) (e : OpSem.Env) (_hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .imm ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_addr (ps : List String) (e : OpSem.Env) (_hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .addr ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_addr_const (ps : List String) (e : OpSem.Env) (_hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .addr_const ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_addr_sym (ps : List String) (e : OpSem.Env) (_hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .addr_sym ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_ptr_add (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .ptr_add ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_ptr_index (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .ptr_index ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_load (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .load ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_store (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .store ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_bin (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .bin ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_bin_imm (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .bin_imm ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_binop (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .binop ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_binop_imm (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .binop_imm ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_shift_imm (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .shift_imm ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_cmp (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .cmp ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_cmp_imm (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .cmp_imm ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_br (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .br ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_br_cmp (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .br_cmp ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_br_cmp_imm (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .br_cmp_imm ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_ovf (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    : NoNB (kindSem .ovf ps e) := by
  unfold kindSem; dsimp only; inline_nb

theorem inline_nbk_cvt (ps : List String) (e : OpSem.Env) (hrd : ∀ n, NoNB (e.rd n))
    (hch : e.ch = {}) : NoNB (kindSem .cvt ps e) := by
  unfold kindSem; dsimp only; rw [hch]; inline_nb

theorem inline_nb_class (cls : Class) (ps : List String) (e : OpSem.Env)
    (hrd : ∀ n, NoNB (e.rd n)) (hch : e.ch = {}) : NoNB (kindSem (classHandler cls).1 ps e) := by
  cases cls with
  | mov => exact inline_nbk_mov ps e hrd
  | mov128 => exact inline_nbk_mov ps e hrd
  | imm => exact inline_nbk_imm ps e hrd
  | addr => exact inline_nbk_addr ps e hrd
  | addrConst => exact inline_nbk_addr_const ps e hrd
  | addrSym => exact inline_nbk_addr_sym ps e hrd
  | addrSymInd => exact inline_nbk_addr_sym ps e hrd
  | ptrAdd => exact inline_nbk_ptr_add ps e hrd
  | ptrIndex => exact inline_nbk_ptr_index ps e hrd
  | load => exact inline_nbk_load ps e hrd
  | store => exact inline_nbk_store ps e hrd
  | bin op w =>
    cases op
    all_goals first | exact inline_nbk_bin ps e hrd | exact inline_nbk_binop ps e hrd
  | binImm op w =>
    cases op
    all_goals first | exact inline_nbk_bin_imm ps e hrd | exact inline_nbk_binop_imm ps e hrd
  | mul => exact inline_nbk_bin ps e hrd
  | mulImm => exact inline_nbk_bin_imm ps e hrd
  | shiftImm => exact inline_nbk_shift_imm ps e hrd
  | cmp => exact inline_nbk_cmp ps e hrd
  | cmpImm => exact inline_nbk_cmp_imm ps e hrd
  | br => exact inline_nbk_br ps e hrd
  | brCmp => exact inline_nbk_br_cmp ps e hrd
  | brCmpImm => exact inline_nbk_br_cmp_imm ps e hrd
  | ovf => exact inline_nbk_ovf ps e hrd
  | mulOvf => exact inline_nbk_ovf ps e hrd
  | ext => exact inline_nbk_cvt ps e hrd hch
  | shiftVar sh w => cases sh <;> (simp only [classHandler]; unfold kindSem; dsimp only; inline_nb)
  | div => simp only [classHandler]; unfold kindSem; dsimp only; inline_nb
  | count => simp only [classHandler]; unfold kindSem; dsimp only; inline_nb
  | cmp3 => simp only [classHandler]; unfold kindSem; dsimp only; inline_nb
  | bswap => simp only [classHandler]; unfold kindSem; dsimp only; inline_nb

theorem inline_nb_opSem {f : Full.Opcode} {cls : Class} (hok : Step.InlineOk f cls)
    (vals : Operands) (st : OpSem.State) : NoNB (opSem f vals st {}) := by
  obtain ⟨⟨r, hh⟩, -⟩ := shapeOk_spec hok.shape
  unfold opSem
  refine noNB_bind ?_ fun ⟨h, fp, val⟩ hp => ?_
  · unfold prepare
    intro m hm
    simp only [hh, bind, Except.bind] at hm
    repeat' split at hm
    all_goals first | (cases hm; done) | (cases hm; simp [inline_ill_eq, inline_throw_eq] at *) |
      simp_all [inline_ill_eq, inline_throw_eq]
  have hh' := prepare_handler hp
  rw [hh] at hh'
  cases hh'
  refine noNB_bind ?_ fun reads _ => ?_
  · unfold readAll
    refine noNB_mapM _ (fun a => ?_) _
    split
    · exact noNB_bind (noNB_readFrame _ _ _) fun _ _ => noNB_pure _
    · exact noNB_ill _
  refine noNB_bind (inline_nb_class cls _ _ (fun n => ?_) rfl) fun o _ => ?_
  · unfold mkEnv; dsimp only; split
    · exact noNB_pure _
    · exact noNB_ill _
  refine noNB_bind ?_ fun _ _ => noNB_pure _
  unfold commit
  refine noNB_foldlM _ (fun st w => ?_) _ _
  unfold commitOne
  split
  · exact noNB_ill _
  · split
    · exact noNB_ill _
    · split
      · exact noNB_writeFrame _ _ _
      · exact noNB_ill _

/-- An inline proto isn't `bare` (as `DecodeLink.inlineInsn_read`, its proof extended). -/
theorem inline_read_bare {cache cache' : Cache} {dropped dr' : List DroppedStore} {c c' : Cursor}
    {q : Proto} (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c')) :
    q.bare = false := by
  unfold inlineInsn at h
  obtain ⟨p0, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨fu, c2, h2, h⟩ := bind_ok h
  have := fuel_run h2; subst c2
  obtain ⟨st, c3, h3, h⟩ := bind_ok h
  let I : Option (Option (Proto × Cache × List DroppedStore)) × Array Item ×
      Option (Cond × Nat) × Bool × Nat × List DroppedStore × Bool → Cursor → Prop :=
    fun st cur => st.1 = none ∧ st.2.2.2.2.2.2 = false ∧ cur = atPos c cur.pos ∧
      st.2.2.1 = none ∧ (st.2.2.2.1 = false → Dec c c.pos st.2.1.toList cur.pos)
  let D : Option (Option (Proto × Cache × List DroppedStore)) × Array Item ×
      Option (Cond × Nat) × Bool × Nat × List DroppedStore × Bool → Cursor → Prop :=
    fun st cur => st.1 = some none ∨ (st.1 = none ∧ st.2.2.2.2.2.2 = true ∧
      (st.2.2.2.1 = false → (st.2.2.1 = none ∧ Dec c c.pos st.2.1.toList cur.pos) ∨
        ∃ cond tgt long, st.2.2.1 = some (cond, tgt.toNat) ∧
          Dec c c.pos (st.2.1.toList ++ [.branch cond tgt long]) cur.pos))
  have key := forIn_range_inv I D _ ?step _ _ c c3 st ⟨rfl, rfl, rfl, rfl, fun _ => .nil _⟩ h3
  case step =>
    intro a b cur r cur' hI hr
    obtain ⟨o, items, branch, wd, da, dr, ended⟩ := b
    obtain ⟨ho, hend, hc, hbr, hd⟩ := hI
    simp only at ho hend hc hbr hd hr
    subst ho hend hbr
    obtain ⟨pc, rfl⟩ : ∃ p, cur = atPos c p := ⟨_, hc⟩
    split at hr
    · rename_i d hdr
      obtain ⟨p1, c4, h4, hr⟩ := bind_ok hr
      obtain ⟨rfl, hc4⟩ := pos_run' h4
      subst c4
      split at hr
      · -- a dropped store: `wasDropped` from here on
        obtain ⟨p2, c5, h5, hr⟩ := bind_ok hr
        obtain ⟨rfl, hc5⟩ := pos_run' h5
        subst c5
        obtain ⟨nx, c6, h6, hr⟩ := bind_ok hr
        have e6 := posOnly_run PosOnly.tryItem h6
        obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
        rw [run_setPos] at h7; cases h7
        split at hr
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact ⟨rfl, rfl, by rw [e6], rfl, fun h => by cases h⟩
        · obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact .inr ⟨rfl, rfl, fun h => by cases h⟩
      · obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
        cases x with
        | none =>
          have := run_tryItem_none h5; subst this
          obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
          rw [run_setPos] at h7; cases h7
          obtain ⟨rfl, rfl⟩ := pure_ok hr
          exact .inl rfl
        | some it =>
          obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
          dsimp only at hr
          split at hr
          · obtain ⟨p2, c6, h6, hr⟩ := bind_ok hr
            obtain ⟨rfl, hc6⟩ := pos_run' h6
            subst c6
            obtain ⟨nx, c7, h7, hr⟩ := bind_ok hr
            have e7 := posOnly_run PosOnly.tryItem h7
            obtain ⟨u, c8, h8, hr⟩ := bind_ok hr
            rw [run_setPos] at h8; cases h8
            split at hr
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              refine .inr ⟨rfl, rfl, fun hw => .inl ⟨rfl, ?_⟩⟩
              simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              refine ⟨rfl, rfl, by rw [e7], rfl, fun hw => ?_⟩
              simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
          · split at hr
            · split at hr
              · obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact .inr ⟨rfl, rfl, fun hw => .inr ⟨_, _, _, rfl, (hd hw).append (Dec.single hn)⟩⟩
              · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
                rw [run_setPos] at h7; cases h7
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact .inl rfl
            · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
              rw [run_setPos] at h7; cases h7
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inl rfl
    · obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      cases x with
      | none =>
        have := run_tryItem_none h5; subst this
        obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
        rw [run_setPos] at h7; cases h7
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        exact .inl rfl
      | some it =>
        obtain ⟨n, hn, rfl⟩ := run_tryItem_some h5
        dsimp only at hr
        split at hr
        · obtain ⟨p2, c6, h6, hr⟩ := bind_ok hr
          obtain ⟨rfl, hc6⟩ := pos_run' h6
          subst c6
          obtain ⟨nx, c7, h7, hr⟩ := bind_ok hr
          have e7 := posOnly_run PosOnly.tryItem h7
          obtain ⟨u, c8, h8, hr⟩ := bind_ok hr
          rw [run_setPos] at h8; cases h8
          split at hr
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            refine .inr ⟨rfl, rfl, fun hw => .inl ⟨rfl, ?_⟩⟩
            simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
          · obtain ⟨rfl, rfl⟩ := pure_ok hr
            refine ⟨rfl, rfl, by rw [e7], rfl, fun hw => ?_⟩
            simp only [Array.toList_push]; exact (hd hw).append (Dec.single hn)
        · split at hr
          · split at hr
            · obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inr ⟨rfl, rfl, fun hw => .inr ⟨_, _, _, rfl, (hd hw).append (Dec.single hn)⟩⟩
            · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
              rw [run_setPos] at h7; cases h7
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact .inl rfl
          · obtain ⟨u, c7, h7, hr⟩ := bind_ok hr
            rw [run_setPos] at h7; cases h7
            obtain ⟨rfl, rfl⟩ := pure_ok hr
            exact .inl rfl
  obtain ⟨o, items, branch, wd, da, dr, ended⟩ := st
  dsimp only at key h
  rcases key with ⟨rfl, rfl, -, -, -⟩ | rfl | ⟨rfl, rfl, hd⟩
  · obtain ⟨u, c4, -, h4⟩ := bind_ok h
    obtain ⟨he, -⟩ := pure_ok h4; cases he
  · obtain ⟨he, -⟩ := pure_ok h; cases he
  · simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h
    -- the candidate the decoder accepted
    have found : ∃ cand d, decodeInline cand branch = some d ∧
        (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
        q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
        q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ q.bare = false ∧ c' = c3 := by
      have fin : ∀ cand d (P : Proto) pp cc, decodeInline cand branch = some d →
          (if ((cache.emit cand).fst != items.toList) = true then none
            else some (P, (cache.emit cand).snd)) = some (pp, cc) →
          P.op = d.1 → P.ops = d.2 → P.pos = c.pos → P.handler = none → P.dropped = wd →
          P.items = (if wd = true then items.toList.eraseIdx da else items.toList) → P.bare = false →
          (pp, cc, dr) = (q, cache', dr') → c' = c3 → ∃ cand d, decodeInline cand branch = some d ∧
            (cache.emit cand).1 = items.toList ∧ cache' = (cache.emit cand).2 ∧
            q.op = d.1 ∧ q.ops = d.2 ∧ q.pos = c.pos ∧ q.handler = none ∧ q.dropped = wd ∧
            q.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ q.bare = false ∧ c' = c3 := by
        intro cand d P pp cc hd hh h1 h2 h3 h4 h5 h6 h7 he hc
        split at hh
        · cases hh
        · rename_i hne
          simp only [Option.some.injEq, Prod.mk.injEq] at hh he
          obtain ⟨rfl, rfl⟩ := hh
          obtain ⟨rfl, rfl, rfl⟩ := he
          exact ⟨cand, d, hd, by simpa using hne, rfl, h1, h2, h3, h4, h5, h6, h7, hc⟩
      split at h
      · rename_i d hdi
        split at h
        · rename_i pp cc hacc
          obtain ⟨he, rfl⟩ := pure_ok h
          exact fin _ d _ pp cc hdi hacc rfl rfl rfl rfl rfl rfl rfl (by cases he; rfl) rfl
        · obtain ⟨res, c4, h4, hk2⟩ := bind_ok h
          have key2 := forIn_list_inv (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => st.1 = none ∧ cur = c3)
            (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => cur = c3 ∧
                ∃ (cand : List Item) (d : Full.Opcode × List (Opnd Nat)) (P pp : Proto) (cc : Cache), decodeInline cand branch = some d ∧
              (if ((cache.emit cand).fst != items.toList) = true then none
                else some (P, (cache.emit cand).snd)) = some (pp, cc) ∧
              P.op = d.1 ∧ P.ops = d.2 ∧ P.pos = c.pos ∧ P.handler = none ∧ P.dropped = wd ∧
              P.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ P.bare = false ∧
              st.1 = some (some (pp, cc, dr))) _ ?step2 _ _ c3 c4 res ⟨rfl, rfl⟩ h4
          case step2 =>
            intro cand st cur r cur' hI hr
            split at hr
            · rename_i d hd
              split at hr
              · rename_i pp cc hacc
                obtain ⟨rfl, rfl⟩ := pure_ok hr
                exact ⟨hI.2, cand, d, _, pp, cc, hd, hacc, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
              · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
            · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
          rcases key2 with ⟨hn, rfl⟩ | ⟨rfl, cand, d, P, pp, cc, hd, hacc, h1, h2, h3, h4', h5, h6, h7, hs⟩
          · split at hk2
            · rename_i r hr; rw [hn] at hr; cases hr
            · obtain ⟨u, c5, -, hk3⟩ := bind_ok hk2
              obtain ⟨he, -⟩ := pure_ok hk3; cases he
          · split at hk2
            · rename_i r hr; rw [hs] at hr; cases hr
              obtain ⟨he, rfl⟩ := pure_ok hk2
              exact fin cand d P pp cc hd hacc h1 h2 h3 h4' h5 h6 h7 (by cases he; rfl) rfl
            · rename_i hr; rw [hs] at hr; cases hr
      · obtain ⟨res, c4, h4, hk2⟩ := bind_ok h
        have key2 := forIn_list_inv (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => st.1 = none ∧ cur = c3)
          (fun (st : Option (Option (Proto × Cache × List DroppedStore)) × Unit) cur => cur = c3 ∧
                ∃ (cand : List Item) (d : Full.Opcode × List (Opnd Nat)) (P pp : Proto) (cc : Cache), decodeInline cand branch = some d ∧
            (if ((cache.emit cand).fst != items.toList) = true then none
              else some (P, (cache.emit cand).snd)) = some (pp, cc) ∧
            P.op = d.1 ∧ P.ops = d.2 ∧ P.pos = c.pos ∧ P.handler = none ∧ P.dropped = wd ∧
            P.items = (if wd = true then items.toList.eraseIdx da else items.toList) ∧ P.bare = false ∧
            st.1 = some (some (pp, cc, dr))) _ ?step2 _ _ c3 c4 res ⟨rfl, rfl⟩ h4
        case step2 =>
          intro cand st cur r cur' hI hr
          split at hr
          · rename_i d hd
            split at hr
            · rename_i pp cc hacc
              obtain ⟨rfl, rfl⟩ := pure_ok hr
              exact ⟨hI.2, cand, d, _, pp, cc, hd, hacc, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
            · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
          · obtain ⟨rfl, rfl⟩ := pure_ok hr; exact ⟨rfl, hI.2⟩
        rcases key2 with ⟨hn, rfl⟩ | ⟨rfl, cand, d, P, pp, cc, hd, hacc, h1, h2, h3, h4', h5, h6, h7, hs⟩
        · split at hk2
          · rename_i r hr; rw [hn] at hr; cases hr
          · obtain ⟨u, c5, -, hk3⟩ := bind_ok hk2
            obtain ⟨he, -⟩ := pure_ok hk3; cases he
        · split at hk2
          · rename_i r hr; rw [hs] at hr; cases hr
            obtain ⟨he, rfl⟩ := pure_ok hk2
            exact fin cand d P pp cc hd hacc h1 h2 h3 h4' h5 h6 h7 (by cases he; rfl) rfl
          · rename_i hr; rw [hs] at hr; cases hr
    obtain ⟨-, -, -, -, -, -, -, -, -, -, -, hbare, -⟩ := found
    exact hbare

/-- After an inline proto there is no `nop` (it isn't `bare`): the next proto starts where it
ends. -/
theorem inline_nop_none {fr : Vm.Frame} {callSites : Array CallSite} {c : Cursor} {q : Proto}
    {p p' : Nat} (hb : q.bare = false) (h : NopRead fr callSites c q p p') : p' = p := by
  cases h with
  | none => rfl
  | nop hn => simp [nopAfter, hb] at hn

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- An inline instruction's step through the cache, by class (`FrameBounds`' `_fb` steps for
`load`, `store` and the rip-relative addresses, `inline_step_cached` for the `SoundC` rest). -/
theorem inline_cls_step (H : Hyps S) {s s' : R.RState} {x : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class}
    {cand : List Item} {br : Option Cond} {cache : Cache}
    (hf : FrameInv S s x) (hci : CacheInv cache x)
    (hpriv : ∀ w vals, shapeOk f (.load w) = true → nativeVals S.c.ρ f ops = some vals →
      AfterScopes S.c s (Private f vals))
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, cls) ∈ inlineOps) (hlater : laterClass cls = false)
    (hseq : sequence cls ops = some (cand, br))
    (h : R.step S.c s ch = .ok (.step s')) :
    ∃ x', execItems S.ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := by
  have hok := H.inlineOk f cls hmem
  have hfb := H.frameBounds
  obtain ⟨hovf, hext, hshi⟩ := inline_class_of hmem
  have cached : SoundC cls → ∃ x', execItems S.ctx (cache.emit cand).1 x = .ok x' ∧
      RRel s' x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' := fun hsc => by
    obtain ⟨x', h1, h2, h3, h4, h5⟩ :=
      CacheStep.inline_step_cached S.ctx hsc hci hf.rrel hi hfull hok hext hlater hseq h
    exact ⟨x', h1, h2, h3, h4, by cases br <;> exact h5⟩
  cases cls with
  | load w =>
    obtain ⟨x', h1, h2, -, -, h3, h4, h5⟩ := load_step_fb S.ctx hfb hf.win hci hf.rrel hf.mem
      hf.sep (fun vals hv => hpriv w vals hok.shape hv) hi hfull hok hseq h
    exact ⟨x', h1, h2, h3, h4, h5⟩
  | store w =>
    obtain ⟨x', h1, h2, -, -, h3, h4, h5⟩ := store_step_fb S.ctx hfb hf.win hci hf.rrel hf.mem
      hf.sep hi hfull hok hseq h
    exact ⟨x', h1, h2, h3, h4, h5⟩
  | addrConst =>
    obtain ⟨st0, x0, hg⟩ := H.globals
    obtain ⟨x', h1, h2, -, h3, h4, h5⟩ := rip_step_fb S.ctx rfl hfb hf.win hci hf.rrel hf.mem hg
      hf.sep hi hfull hok hseq h
    exact ⟨x', h1, h2, h3, h4, h5⟩
  | addrSym =>
    obtain ⟨st0, x0, hg⟩ := H.globals
    obtain ⟨x', h1, h2, -, h3, h4, h5⟩ := rip_step_fb S.ctx rfl hfb hf.win hci hf.rrel hf.mem hg
      hf.sep hi hfull hok hseq h
    exact ⟨x', h1, h2, h3, h4, h5⟩
  | addrSymInd =>
    obtain ⟨st0, x0, hg⟩ := H.globals
    obtain ⟨x', h1, h2, -, h3, h4, h5⟩ := rip_step_fb S.ctx rfl hfb hf.win hci hf.rrel hf.mem hg
      hf.sep hi hfull hok hseq h
    exact ⟨x', h1, h2, h3, h4, h5⟩
  | ovf aop sg w =>
    rcases hovf aop sg w rfl with rfl | rfl
    · exact cached (inline_soundC _ (.inr rfl))
    · exact cached (inline_soundC _ (.inr rfl))
  | mulOvf sg w => exact cached (inline_soundC _ (.inr rfl))
  | mov w => exact cached (inline_soundC _ (.inl rfl))
  | mov128 => exact cached (inline_soundC _ (.inl rfl))
  | imm w => exact cached (inline_soundC _ (.inl rfl))
  | addr => exact cached (inline_soundC _ (.inl rfl))
  | ptrAdd => exact cached (inline_soundC _ (.inl rfl))
  | ptrIndex => exact cached (inline_soundC _ (.inl rfl))
  | bin o w => exact cached (inline_soundC _ (.inl rfl))
  | binImm o w => exact cached (inline_soundC _ (.inl rfl))
  | mul w => exact cached (inline_soundC _ (.inl rfl))
  | mulImm w => exact cached (inline_soundC _ (.inl rfl))
  | shiftImm sh w => exact cached (inline_soundC _ (.inl (hshi sh w rfl)))
  | cmp c w => exact cached (inline_soundC _ (.inl rfl))
  | cmpImm c w => exact cached (inline_soundC _ (.inl rfl))
  | br => exact cached (inline_soundC _ (.inl rfl))
  | brCmp c w => exact cached (inline_soundC _ (.inl rfl))
  | brCmpImm c w => exact cached (inline_soundC _ (.inl rfl))
  | ext a b sx => exact cached (inline_soundC _ (.inl rfl))
  | shiftVar | div | count | cmp3 | bswap => simp [laterClass] at hlater

/-- Open (checkable), missing from `FrameBounds.writes`: an inline instruction's frame writes miss
the frame's link slots `[0, 16)` (the saved `rbp`, the return address). `FrameBounds.writes` only bounds them by the window `[-F, K)`, and neither
`LoadPrivate` nor `LinkPrivate` keeps them apart (both only say the bytes are private), so
without it a `mov.w64` to slot `0` (`mov [rbp], rax`) overwrites the saved `rbp` and breaks
`FrameFacts.savedRbp` after the step, while R's step (a private frame write) succeeds: the
conclusion of `inline_run'` is false. Like `ArgBelowLink` for `arg`. -/
def InlineBelowLink (S : Setup) : Prop :=
  ∀ (k : Nat) (op : Reduced.Opcode) (ops : List (R.Opnd Nat)) (f : Full.Opcode) (cls : Class)
    (vals : Operands), S.c.d.insns[k]? = some (.native op ops) → op.full = some f →
    (f, cls) ∈ inlineOps → nativeVals S.c.ρ f ops = some vals →
    ∀ r ∈ wranges f vals, r.1 + r.2 ≤ 0 ∨ 16 ≤ r.1

/-- Not covered yet: no inline instruction of the classes added after these proofs
(`laterClass`: variable shifts and rotates, `div`/`rem`, `cttz`/`ctlz`, `cmp3`, `bswap`), whose
cached steps (`CacheStep.inline_step_cached`) are open. -/
def NoLaterClass (S : Setup) : Prop :=
  ∀ (k : Nat) (op : Reduced.Opcode) (ops : List (R.Opnd Nat)) (f : Full.Opcode) (cls : Class),
    S.c.d.insns[k]? = some (.native op ops) → op.full = some f → (f, cls) ∈ inlineOps →
    laterClass cls = false

/-- Open (decoder): on PE the cache an inline instruction is emitted with keeps `rsi` and `rdi`
(pool entries 2 and 3, Win64 callee-saved) out: `fresh` skips them only when `cache.pe` is set,
and `find` returns any entry holding a slot, so a cache with a slot in `rsi` would make `emit`
compute in `rsi` and break `FrameFacts.saved`. The decoder's caches start with `pe` set to the
mode's and only `emit` fills entries, which never picks `rsi`/`rdi` then. -/
def CacheRegsOk (S : Setup) (cache : Cache) : Prop :=
  S.c.mode.pe = true →
    cache.pe = true ∧ (cache.regs[2]!).slot = none ∧ (cache.regs[3]!).slot = none

/-- Open: the run of an inline instruction's emitted items is fetched. Proof idea: the emitted
items are canonical (`cache.emit` renames `sequence`'s items, each `Item.wf`); each item's
memory write is a frame write in the window (`FrameBounds.writes`) or, for `store`, a write in a
live allocation of the state after the scopes, so none touches the code (`CodeApart`, through
`hbi`); `steps_of_run` (with `steps_of_run_last` for `store`, whose pointer write is last). -/
theorem inline_fetch' (H : Hyps S) {s s' : R.RState} {x x' : X86.State} {ch : OpSem.Choice}
    {p : Nat} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class}
    {cand : List Item} {br : Option Cond} {cache : Cache}
    (hf : FrameInv S s x) (hbi : ∃ y, BInv S s y) (hci : CacheInv cache x)
    (hcro : CacheRegsOk S cache)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, cls) ∈ inlineOps) (hlater : laterClass cls = false)
    (hseq : sequence cls ops = some (cand, br))
    (hrip : x.rip = addrAt S.ctx p) (hcode : CodeAt S.ctx x.mem (cache.emit cand).1 p)
    (hstep : R.step S.c s ch = .ok (.step s'))
    (hx : execItems S.ctx (cache.emit cand).1 x = .ok x') : Steps S.ctx x x' := by
  sorry  -- TODO(wip): inline_fetch'

/-- Open: the x86 effects of an inline instruction's emitted items outside R's state. Proof
idea: the emitted items name only pool registers, `rcx` and `rbp` (`sequence_ok`, `emit`'s
renaming to a pool register, not `rsi`/`rdi` on PE by `CacheRegsOk`), none callee-saved nor
`rsp`, and write `rbp` never (`cacheSafe`); their memory writes are the frame writes of
`wranges` (in the window, `FrameBounds.writes`, off the link slots, `InlineBelowLink`) and
`store`'s write in a live allocation (`PostMem.memOut`), none on the code or rodata
(`CodeApart` through `hbi`). Needs the register and memory facts of `Post`/`PostMem`
(`regs`, `memOut`) carried through `cached_of`, which drops them now. -/
theorem inline_effects' (H : Hyps S) (hbl : InlineBelowLink S) {s s' : R.RState}
    {x x' : X86.State} {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} {cls : Class} {cand : List Item} {br : Option Cond} {cache : Cache}
    (hf : FrameInv S s x) (hbi : ∃ y, BInv S s y) (hci : CacheInv cache x)
    (hcro : CacheRegsOk S cache)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, cls) ∈ inlineOps) (hlater : laterClass cls = false)
    (hseq : sequence cls ops = some (cand, br))
    (hstep : R.step S.c s ch = .ok (.step s'))
    (hx : execItems S.ctx (cache.emit cand).1 x = .ok x') :
    x'.rsp = x.rsp ∧ (∀ i, Saved S.c.mode.pe i → i ≠ 5 → x'.regs i = x.regs i) ∧
      (∀ j, j < S.body.code.size → x'.mem (addrAt S.ctx j) = x.mem (addrAt S.ctx j)) ∧
      (∀ j, j < S.ro.size → x'.mem (S.ctx.addrOf (.ro j)) = x.mem (S.ctx.addrOf (.ro j))) ∧
      x'.mem.read64 (x.reg .rbp) = x.mem.read64 (x.reg .rbp) ∧
      x'.mem.read64 (x.reg .rbp + 8) = x.mem.read64 (x.reg .rbp + 8) := by
  sorry  -- TODO(wip): inline_effects'

/-- `MemRel` and `FrameSep` after an inline instruction's emitted items. `load` and `store`
from `load_step_fb`/`store_step_fb` (`execItems` is a function, so their run is `x'`). Open for
the other classes: `rip_step_fb` gives `FrameSep` but not `MemRel` (its frame write is like
`load`'s), and `inline_step_cached` neither (`PostC.same`/`memOut` with `sep_of_opSem` and a
`memRel_frame`-like lemma for escaped frame writes, carried through `cached_of`). -/
theorem inline_memSep' (H : Hyps S) {s s' : R.RState} {x x' : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class}
    {cand : List Item} {br : Option Cond} {cache : Cache}
    (hf : FrameInv S s x) (hbi : ∃ y, BInv S s y) (hci : CacheInv cache x)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hfull : op.full = some f)
    (hmem : (f, cls) ∈ inlineOps) (hlater : laterClass cls = false)
    (hseq : sequence cls ops = some (cand, br))
    (hstep : R.step S.c s ch = .ok (.step s'))
    (hx : execItems S.ctx (cache.emit cand).1 x = .ok x') :
    MemRel s'.st x' ∧ FrameSep (-(S.F : Int)) S.K s'.st x' := by
  have hok := H.inlineOk f cls hmem
  have hfb := H.frameBounds
  obtain ⟨y, hby⟩ := hbi
  cases cls
  case load w =>
    obtain ⟨x1, hx1, -, hm1, hs1, -⟩ := load_step_fb S.ctx hfb hf.win hci hf.rrel hf.mem hf.sep
      (fun vals hv s1 hsc => H.loadPrivate s y s1 op ops f w vals hby hi hfull hok.shape hv hsc)
      hi hfull hok hseq hstep
    cases hx.symm.trans hx1
    exact ⟨hm1, hs1⟩
  case store w =>
    obtain ⟨x1, hx1, -, hm1, hs1, -⟩ := store_step_fb S.ctx hfb hf.win hci hf.rrel hf.mem hf.sep
      hi hfull hok hseq hstep
    cases hx.symm.trans hx1
    exact ⟨hm1, hs1⟩
  all_goals sorry  -- TODO(wip): inline_memSep' (rip and `SoundC` classes)

/-- The x86 side of an inline step that the step lemmas don't give: from a frame relation at an
inline instruction, its emitted items `items` in memory at `rip`, and the R step to `s'` matched
by `items`' run to `x'` (`RRel s' x'`), the run is fetched (`Steps`) and the frame relation
holds after. Not of the later classes (`NoLaterClass`), with a cache keeping PE's `rsi`/`rdi`
out (`CacheRegsOk`), and some boundary relation at `s` (`hbi`, for `CodeApart`'s live
allocations and `LoadPrivate`). Proof: `inline_fetch'` (`Steps`), `inline_memSep'` (`MemRel`,
`FrameSep`), `inline_effects'` (`rsp`, the callee-saved registers, the code, the rodata and the
link words kept); `rbp` from `RRel` (the step keeps `fp`); `ArgsLive` is vacuous (`¬ LeadArg`). -/
theorem inline_run' (H : Hyps S) (hbl : InlineBelowLink S) (hnlc : NoLaterClass S)
    (s s' : R.RState) (x x' : X86.State) (ch : OpSem.Choice) (p : Nat)
    (items : List Item) : FrameInv S s x → (∃ y, BInv S s y) → x.rip = addrAt S.ctx p →
    CodeAt S.ctx x.mem items p →
    (∃ (op : Reduced.Opcode) (ops : List (R.Opnd Nat)) (f : Full.Opcode) (cls : Class)
      (cand : List Item) (br : Option Cond) (cache : Cache),
      S.c.d.insns[s.pc]? = some (.native op ops) ∧ op.full = some f ∧ (f, cls) ∈ inlineOps ∧
      sequence cls ops = some (cand, br) ∧ CacheInv cache x ∧ CacheRegsOk S cache ∧
      (cache.emit cand).1 = items) →
    ¬ LeadArg S s'.pc →
    R.step S.c s ch = .ok (.step s') → execItems S.ctx items x = .ok x' → RRel s' x' →
    Steps S.ctx x x' ∧ FrameInv S s' x' := by
  intro hf hbi hrip hcode hex hnl hstep hx hrr
  obtain ⟨op, ops, f, cls, cand, br, cache, hi, hfull, hmem, hseq, hci, hcro, hemit⟩ := hex
  subst hemit
  have hlater : laterClass cls = false := hnlc s.pc op ops f cls hi hfull hmem
  have hok := H.inlineOk f cls hmem
  -- R's step keeps `fp`.
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi hfull hok.opShape hstep
  obtain ⟨_, _, _, _, _, _, _, _, _, he⟩ :=
    Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
  have hfp' : s'.fp = s.fp := by
    rw [R.Out.step.inj he]
    exact (scopes_keeps _ hsc).fp
  have hrbp : x'.reg .rbp = x.reg .rbp := by
    rw [hrr.rbp, hf.rrel.rbp, hfp']
  have hsteps := inline_fetch' H hf hbi hci hcro hi hfull hmem hlater hseq hrip hcode hstep hx
  obtain ⟨hm', hs'⟩ := inline_memSep' H hf hbi hci hi hfull hmem hlater hseq hstep hx
  obtain ⟨hrsp, hsaved, hcodeK, hroK, hl0, hl8⟩ :=
    inline_effects' H hbl hf hbi hci hcro hi hfull hmem hlater hseq hstep hx
  have hLk' : LinkOk S.ctx x'.mem S.body S.rs := by
    obtain ⟨hfl, hso, ⟨hl1, hl2⟩, hsm, hfp0⟩ := hf.code
    refine ⟨hfl, hso, ⟨fun j hj hr => ?_, fun r hr kk hkk => ?_⟩, hsm, hfp0⟩
    · rw [hcodeK j hj]; exact hl1 j hj hr
    · rw [hcodeK _ (by have := H.relocsIn r hr; omega)]; exact hl2 r hr kk hkk
  have hro' : RoLoaded S.ctx x'.mem S.ro := by
    obtain ⟨base, h1, h2⟩ := hf.ro
    refine ⟨base, h1, fun j hj => ?_⟩
    have e := hroK j hj
    rw [h1] at e
    rw [e]
    exact h2 j hj
  obtain ⟨f1, f2, f3, f4⟩ := hf.frame
  have hframe' : FrameFacts S x' :=
    ⟨by rw [hrbp]; exact f1, by rw [hrbp, hl8]; exact f2, by rw [hrbp, hl0]; exact f3,
      fun i hi5 h5 => by rw [hsaved i hi5 h5]; exact f4 i hi5 h5⟩
  refine ⟨hsteps, ⟨hrr, hm', hs', ?_, ?_, ?_, ?_, hLk', hro', fun hl => absurd hl hnl, hframe'⟩⟩
  · rw [hfp']; exact hf.win
  · rw [hfp']; exact hf.fpF
  · rw [hrsp, hrbp]; exact hf.rsp
  · rw [hrsp]; exact hf.room

/-- An inline instruction's R step with the default choice is not `noBehavior`. Proof idea: no
inline class's `opSem` consults the choice (`Step.InlineOk`'s `opShape`, `stepView_native`), and
the scopes never stop with `noBehavior` (`noNB_scopes`); case on the class as `inline_cls_step`. -/
theorem inline_progress' (H : Hyps S) (s : R.RState) (op : Reduced.Opcode)
    (ops : List (R.Opnd Nat)) (f : Full.Opcode) (cls : Class) (m : String)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hc : (f, cls) ∈ inlineOps) : R.step S.c s {} ≠ .error (.noBehavior m) := by
  have hok := H.inlineOk f cls hc
  intro h
  unfold R.step at h
  simp only [hi, bind, Except.bind] at h
  cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    rw [hsc] at h
    cases h
    exact noNB_scopes _ _ m hsc
  | ok s1 =>
    simp only [hsc, hf] at h
    have hv : R.stepView S.c s1 (.native op ops) {} = .error (.noBehavior m) := by
      rcases Step.opShape_cases hok.opShape with hsh | hsh | hsh | hsh | hsh <;>
        (rw [hsh] at h; exact h)
    unfold R.stepView at hv
    cases hvw : R.view S.c.mode S.c.ρ (.native op ops) with
    | none => simp [hvw, inline_ill_eq] at hv
    | some v =>
      obtain ⟨vals, t, hn, hct, rfl⟩ := Step.view_native hf hok.opShape hvw
      simp only [hvw, bind, Except.bind, beq_iff_eq, hok.notResume, hok.notUnreachable,
        ↓reduceIte] at hv
      cases ho : opSem f vals s1.st {} with
      | error e =>
        rw [ho] at hv
        cases hv
        exact inline_nb_opSem hok vals s1.st m ho
      | ok r =>
        obtain ⟨ctl, st'⟩ := r
        simp only [ho] at hv
        cases hp : t.succ s1.pc ctl with
        | none => simp [hp, inline_ill_eq] at hv
        | some pc' => simp [hp, pure, Except.pure] at hv

set_option maxRecDepth 100000 in
/-- After an inline instruction, R isn't at a leading `arg`. Proof idea: `step_native` and
`stepView_native`: `s'.pc` is `k + 1` (`S.args (k + 1) = false`: `hP.args`, `q.op` isn't `arg`,
no `inlineOps` entry is; so `S.args (k + 2) = false` by `hD.argsSucc`) or a target of proto `k`
(`inline_branch_index`; `ArgsOk.untargeted` needs `H`, so take it: here only `k + 1` and the
targets matter). -/
theorem inline_not_leadArg' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache} {s s' : R.RState} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} {cls : Class} {ch : OpSem.Choice}
    (hP : ProtoFacts S k p q c' cache') (hs : s.pc = k)
    (hi : S.c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hc : (f, cls) ∈ inlineOps) (hstep : R.step S.c s ch = .ok (.step s')) (H : Hyps S) :
    ¬ LeadArg S s'.pc := by
  have hok := H.inlineOk f cls hc
  obtain ⟨s1, hsc, hv⟩ := Step.step_native hi hf hok.opShape hstep
  obtain ⟨vals, t, ctl, st', pc', -, hctl, -, hsucc, ho⟩ :=
    Step.stepView_native hf hok.opShape hok.notResume hok.notUnreachable hv
  have hpc : s'.pc = pc' := by cases ho; rfl
  have hk1 : s1.pc = k := by rw [(scopes_keeps _ hsc).pc, hs]
  rw [hk1] at hsucc
  rw [hpc]
  obtain ⟨i, hi', hio⟩ := hP.insn
  rw [← hs, hi] at hi'
  cases hi'
  have hlt := hP.lt
  have hio' := hio hlt
  obtain ⟨p1, ctr, hpq⟩ := hP.proto
  have hpk : S.r.protos[k] = { q with pos := p1, counter := ctr } := by
    rw [Array.getElem?_eq_some_iff] at hpq
    exact hpq.2
  have htg : ∀ x ∈ t.targets, posOf S.r x ∈ S.r.protos[k].targets := by
    intro x hx
    obtain ⟨o, hoo, hxo⟩ := inline_ctl_targets hctl hx
    unfold InsnOf at hio'
    split at hio'
    · obtain ⟨_, he, -⟩ := hio'; cases he
    · obtain ⟨op', ops', -, he, hops⟩ := hio'
      cases he
      unfold Proto.targets
      refine List.mem_append_left _ (List.mem_flatMap.2 ⟨opndMap (posOf S.r) o, ?_, ?_⟩)
      · rw [← hops]; exact List.mem_map_of_mem hoo
      · rw [inline_targetsOf_map]; exact List.mem_map_of_mem hxo
  rcases inline_succ hsucc with rfl | hx
  · rintro ⟨hlt', ha⟩
    have hqop : q.op = f := by
      rw [hpk] at hio'
      unfold InsnOf at hio'
      split at hio'
      · obtain ⟨_, he, -⟩ := hio'; cases he
      · obtain ⟨op', ops', hof, he, -⟩ := hio'
        cases he
        have := inline_full_of hof
        rw [hf] at this
        exact (Option.some.inj this).symm
    have hna : q.op ≠ .arg := by
      rw [hqop]; rintro rfl; exact absurd hok.opShape (by decide)
    have h1 : S.args (k + 1) = false := by
      rw [hP.args]; simp [hna]
    have h2 := hD.argsSucc (k + 1) (by simpa using hlt')
    rw [h1] at h2
    simp [h2] at ha
  · exact H.argsOk.untargeted k hP.lt _ (htg _ hx) _ rfl

set_option maxRecDepth 100000 in
/-- `bodySim_inline` (`inline_run'`, `inline_progress'`, `branch_canonical`), with the frame
writes off the link slots (`InlineBelowLink`). -/
theorem bodySim_inline' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (hbl : InlineBelowLink S) (hnlc : NoLaterClass S)
    (hcro : ∀ k, CacheRegsOk S (S.used k)) {k p : Nat} {a : Bool}
    {q : Proto}
    {cur cur' c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache') (hn : NoArg S.fr S.body p a cur)
    (hc : (callInsn S.fr (S.dr k)).run cur = .ok (none, cur'))
    (hr : (inlineInsn (S.used k) (S.dr k) true).run cur' = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) :
    BodySim S k p (S.used k) := by
  intro s x hs hf hrip hci hsafe
  have e1 := callInsn_none hc
  subst e1
  have hcur := noArg_inline hn hc hr hq
  subst hcur
  obtain ⟨hpos, hh, cand, br, hdi, ⟨cls, hmem, hseq⟩, hemit, hd⟩ := inlineInsn_read hr hq
  -- The R instruction.
  have hk := hP.lt
  obtain ⟨i, hi, hio⟩ := hP.insn
  obtain ⟨p1, counter, hpk⟩ := hP.proto
  have hpk' : S.r.protos[k] = { q with pos := p1, counter } := by
    rw [Array.getElem?_eq_getElem hk] at hpk; exact Option.some.inj hpk
  have hio' := hio hk
  rw [hpk'] at hio'
  unfold InsnOf at hio'
  simp only [hh] at hio'
  obtain ⟨op, ops, hof, rfl, hops⟩ := hio'
  have hfull := inline_full_of hof
  have hseqR : sequence cls ops = some (cand, br.map (·.1)) := by
    rw [← inline_seq_map (posOf S.r), hops]; exact hseq
  have hok := H.inlineOk _ _ hmem
  have hi' : S.c.d.insns[s.pc]? = some (.native op ops) := hs ▸ hi
  -- R's step.
  obtain ⟨s', hstep⟩ : ∃ s', R.step S.c s {} = .ok (.step s') := by
    cases h : R.step S.c s {} with
    | error e =>
      obtain ⟨m, rfl⟩ := hsafe.1 _ _ h
      exact absurd h (inline_progress' H s op ops _ cls m hi' hfull hmem)
    | ok o =>
      obtain ⟨s1, -, hv⟩ := Step.step_native hi' hfull hok.opShape h
      obtain ⟨_, _, _, _, _, _, _, _, _, rfl⟩ :=
        Step.stepView_native hfull hok.opShape hok.notResume hok.notUnreachable hv
      exact ⟨_, rfl⟩
  have hnl := inline_not_leadArg' hD hP hs hi' hfull hmem hstep H
  -- `load`'s destination is private (`LoadPrivate`, at the boundary at the position).
  have hbi : BInv S s (x.jump (addrAt S.ctx (posOf S.r k))) :=
    ⟨hf.congr rfl rfl rfl, .inr ⟨by rw [hs]; rfl, by rw [hs]; exact hci⟩⟩
  have hpriv : ∀ w vals, shapeOk q.op (.load w) = true → nativeVals S.c.ρ q.op ops = some vals →
      AfterScopes S.c s (Private q.op vals) :=
    fun w vals hsh hv s1 hsc => H.loadPrivate s _ s1 op ops q.op w vals hbi hi' hfull hsh hv hsc
  obtain ⟨x', hx', hrr, hcc, hrip', hbr⟩ :=
    inline_cls_step H hf hci hpriv hi' hfull hmem (hnlc _ _ _ _ _ hi' hfull hmem) hseqR hstep
  rw [hemit] at hx' hcc hrip'
  simp only at hx' hcc hrip'
  have hb := hP.bound
  have hstop : S.start (k + 1) = c'.pos := inline_nop_none (inline_read_bare hr) hP.nop
  have hex : ∃ op ops f cls cand br, ∃ cache : Cache, S.c.d.insns[s.pc]? = some (.native op ops) ∧
      op.full = some f ∧ (f, cls) ∈ inlineOps ∧ sequence cls ops = some (cand, br) ∧
      CacheInv cache x ∧ CacheRegsOk S cache ∧ (cache.emit cand).1 = q.items :=
    ⟨op, ops, q.op, cls, cand, _, S.used k, hi', hfull, hmem, hseqR, hci, hcro k, by rw [hemit]⟩
  rcases hd with ⟨hbrn, hdec⟩ | ⟨cond, tgt, long, hbrs, hdec⟩
  · -- No branch: fall through to `k + 1`.
    subst hbrn
    have hdec' := Dec.at_iff.1 hdec
    obtain ⟨hcode, hcpos, -⟩ := hf.code.dec hdec' hb
    obtain ⟨hsteps, hf'⟩ :=
      inline_run' H hbl hnlc s s' x x' {} p q.items hf ⟨_, hbi⟩ hrip hcode hex hnl hstep hx' hrr
    have hpc : s'.pc = k + 1 := by simp only [BrOk, Option.map_none] at hbr; rw [hbr, hs]
    refine Reach.steps hsteps (.done (.inl ⟨s', .step hstep, hf', .inl ⟨?_, ?_⟩⟩))
    · rw [hpc, hstop, hcpos, hrip', hrip, addrAt_add]; rfl
    · rw [hpc, hP.cache]; exact hcc
  · -- A branch class: the `jcc` after the items.
    subst hbrs
    have hdec' := Dec.at_iff.1 hdec
    obtain ⟨hcode, hcpos, -⟩ := hf.code.dec hdec' hb
    rw [codeAt_append] at hcode
    obtain ⟨hsteps, hf'⟩ :=
      inline_run' H hbl hnlc s s' x x' {} p q.items hf ⟨_, hbi⟩ hrip hcode.1 hex hnl hstep hx' hrr
    obtain ⟨hcode', -, -⟩ := hf'.code.dec hdec' hb
    rw [codeAt_append] at hcode'
    obtain ⟨m, hd1, hd2⟩ := inline_dec_split hdec'
    obtain ⟨-, hm, -⟩ := hf.code.dec hd1 hb
    have hcan : (Item.branch cond tgt long).Canonical (p + codeSize q.items) := by
      cases hd2 with
      | cons hdi2 hnil => rw [← hm]; exact branch_canonical hf.code.fp hdi2
    have hxr : x'.rip = addrAt S.ctx (p + codeSize q.items) := by
      rw [hrip', hrip, addrAt_add]; rfl
    simp only [BrOk, Option.map_some] at hbr
    obtain ⟨neg, t, b, hctl, heval, hpc⟩ := hbr
    have htgt : posOf S.r t = tgt.toNat :=
      inline_branch_index (inline_targets hdi) hops hctl
    have hexec : (Item.branch cond tgt long).exec S.ctx x' = .ok (x'.jump
        (if b then S.ctx.base + tgt.setWidth 64
          else x'.rip + BitVec.ofNat 64 (Item.branch cond tgt long).size)) := by
      cases b <;> simp [Item.exec, State.jump, heval, bind, Except.bind, pure, Except.pure]
    refine Reach.steps hsteps (.step (.exec _ _ hcan hcode'.2.1 hxr hexec)
      (.done (.inl ⟨s', .step hstep, hf'.congr rfl rfl rfl, ?_⟩)))
    cases b with
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte] at hpc ⊢
      refine .inl ⟨?_, ?_⟩
      · show x'.rip + _ = _
        rw [hpc, hs, hstop, hcpos, hxr, ← addrAt_add, codeSize_append, codeSize_cons,
          codeSize_nil, Nat.add_zero, Nat.add_assoc]
      · rw [hpc, hs, hP.cache]; exact hcc
    | true =>
      simp only [↓reduceIte] at hpc ⊢
      refine .inr ⟨?_, ?_⟩
      · show _ = addrAt S.ctx _
        rw [hpc, htgt]
        simp only [addrAt]
        congr 1
        apply BitVec.eq_of_toNat_eq
        simp
      · rw [hpc]
        have hmemt : posOf S.r t ∈ S.r.protos[k].targets := by
          rw [hpk']
          simp only [Proto.targets, hh, List.append_nil, List.mem_flatMap]
          refine ⟨.target (posOf S.r t), ?_, by simp [Opnd.targetsOf]⟩
          rw [← hops]
          exact List.mem_map_of_mem (nativeCtl_target hctl)
        have := H.cacheCleared.targets k hk _ hmemt
        unfold Setup.used
        rw [ite_eq_left_iff.mpr (fun h => absurd this h)]
        exact CacheInv.empty _

end Insn

end Ryo.Proofs.DecodeSound
