/-
Ryo.Proofs.Lower.GlobKept — every L0 step keeps the program and each global's first constant
copy (D7), the fact the pool invariant (`SimPoolConst.lean`'s `PoolInv`) needs to carry over a
step.

`GlobKept s s'`: `s'` has `s`'s program, and every global's first copy in `s` is still its first
copy in `s'` (later copies may be appended), and likewise every instance's first address copy
(`State.fnCopies`, D6). `Keeps x`: every run of `x` (successful or not) ends
in a state `GlobKept` from its start. Nothing in the semantics writes `State.prog`, and the only
write of `State.constCopies` is `recordConstCopy`, which appends (`keeps_recordConstCopy`), the
only write of `State.fnCopies` is `fnPointer`'s, which appends to the entry it read
(`keeps_fnPointer`, by hand: nothing between the read and the write changes the copies); every
other state change is a `modify`/`set` of other fields.

`Keeps` is closed under `pure`, `>>=`, `<$>`, `get`, `throw`, `choose`, `liftE`, `modify` of
other fields, and the list loops (`forIn`, `mapM`, `foldlM`). The `keeps` tactic applies these
and the lemmas `keeps_*` of each semantic function (in dependency order, each by unfolding the
definition, splitting its matches and `keeps`); the recursive ones (`globalPtrF`, `unsizeValue`,
`splitReceiver`) are by induction on their fuel. The results: `keeps_evalStatement`
(`stmt_globKept`) and the non-call terminators (`keeps_term_goto`, `keeps_term_switchInt`,
`keeps_term_unreachable`). Open (M5c): the call paths (`callInstance` with
`createFrame`, `callExternal`, `evalIntrinsic`, returns and unwinding), and so every terminator and
`Sem.step`; the same tactic applies, but `createFrame` and `evalIntrinsic` need cheaper proofs.
-/
import Ryo.Proofs.Lower.L0Inv

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem

/-! ### The relation -/

/-- What a step keeps of L0's globals: the program, each global's first copy and each
instance's first address copy (a structure, so `.1`/`.2` stay the first two). -/
structure GlobKept (s s' : Spec.State) : Prop where
  prog : s'.prog = s.prog
  consts : ∀ g p ps, s.constCopies.getD g [] = p :: ps → ∃ ps', s'.constCopies.getD g [] = p :: ps'
  fns : ∀ i p ps, s.fnCopies.getD i [] = p :: ps → ∃ ps', s'.fnCopies.getD i [] = p :: ps'

theorem GlobKept.refl (s : Spec.State) : GlobKept s s :=
  ⟨rfl, fun _ p ps h => ⟨ps, h⟩, fun _ p ps h => ⟨ps, h⟩⟩

theorem GlobKept.trans {s s' s'' : Spec.State} (h1 : GlobKept s s') (h2 : GlobKept s' s'') :
    GlobKept s s'' := by
  refine ⟨h2.1.trans h1.1, fun g p ps h => ?_, fun i p ps h => ?_⟩
  · obtain ⟨ps', h'⟩ := h1.2 g p ps h
    exact h2.2 g p ps' h'
  · obtain ⟨ps', h'⟩ := h1.fns i p ps h
    exact h2.fns i p ps' h'

theorem GlobKept.of_eq {s s' : Spec.State} (h1 : s'.prog = s.prog)
    (h2 : s'.constCopies = s.constCopies) (h3 : s'.fnCopies = s.fnCopies) :
    GlobKept s s' :=
  ⟨h1, fun _ p ps h => ⟨ps, by rw [h2]; exact h⟩, fun _ p ps h => ⟨ps, by rw [h3]; exact h⟩⟩

/-- Every run of `x` keeps L0's globals. -/
structure Keeps {α : Type} (x : SemM α) : Prop where
  run : ∀ o s, GlobKept s (runOn x o s).2

/-! ### Closure -/

theorem Keeps.pure {α : Type} (a : α) : Keeps (pure a : SemM α) :=
  ⟨fun o s => by rw [runOn_pure]; exact GlobKept.refl s⟩

theorem Keeps.bind {α β : Type} {x : SemM α} {f : α → SemM β} (hx : Keeps x)
    (hf : ∀ a, Keeps (f a)) : Keeps (x >>= f) := by
  refine ⟨fun o s => ?_⟩
  have h1 := hx.run o s
  rw [runOn_bind]
  rcases h : runOn x o s with ⟨r, s1⟩
  rw [h] at h1
  cases r with
  | error e => exact h1
  | ok a => exact h1.trans ((hf a).run o s1)

theorem Keeps.get : Keeps (get : SemM Spec.State) :=
  ⟨fun o s => by rw [runOn_get]; exact GlobKept.refl s⟩

theorem Keeps.read : Keeps (read : SemM Spec.Oracle) :=
  ⟨fun _ s => GlobKept.refl s⟩

theorem Keeps.throwThe {α : Type} (e : Outcome) : Keeps (throwThe Outcome e : SemM α) :=
  ⟨fun _ s => GlobKept.refl s⟩

theorem Keeps.throw {α : Type} (e : Outcome) : Keeps (throw e : SemM α) :=
  ⟨fun _ s => GlobKept.refl s⟩

theorem Keeps.modify {g : Spec.State → Spec.State} (h : ∀ s, GlobKept s (g s)) :
    Keeps (modify g : SemM Unit) :=
  ⟨fun _ s => h s⟩

theorem Keeps.choose (c : Choice) : Keeps (choose c : SemM c.Answer) :=
  ⟨fun o s => by rw [runOn_choose]; exact GlobKept.of_eq rfl rfl rfl⟩

theorem Keeps.liftE {α : Type} (e : Except Outcome α) : Keeps (SemM.liftE e) := by
  cases e with
  | error x => exact ⟨fun _ s => GlobKept.refl s⟩
  | ok a => exact ⟨fun _ s => GlobKept.refl s⟩

theorem Keeps.map {α β : Type} {f : α → β} {x : SemM α} (hx : Keeps x) : Keeps (f <$> x) := by
  rw [map_eq_pure_bind]
  exact hx.bind fun _ => Keeps.pure _

theorem Keeps.forIn_list {β γ : Type} {l : List β} {f : β → γ → SemM (ForInStep γ)}
    {init : γ} (h : ∀ a b, Keeps (f a b)) : Keeps (forIn l init f) := by
  induction l generalizing init with
  | nil => rw [List.forIn_nil]; exact Keeps.pure _
  | cons a l ih =>
    rw [List.forIn_cons]
    refine (h a init).bind fun r => ?_
    cases r with
    | done b => exact Keeps.pure _
    | yield b => exact ih

theorem Keeps.mapM_list {β γ : Type} {l : List β} {f : β → SemM γ} (h : ∀ a, Keeps (f a)) :
    Keeps (l.mapM f) := by
  induction l with
  | nil => rw [List.mapM_nil]; exact Keeps.pure _
  | cons a l ih =>
    rw [List.mapM_cons]
    exact (h a).bind fun _ => ih.bind fun _ => Keeps.pure _

theorem Keeps.foldlM_list {β γ : Type} {l : List β} {f : γ → β → SemM γ} {init : γ}
    (h : ∀ b a, Keeps (f b a)) : Keeps (l.foldlM f init) := by
  induction l generalizing init with
  | nil => rw [List.foldlM_nil]; exact Keeps.pure _
  | cons a l ih =>
    rw [List.foldlM_cons]
    exact (h init a).bind fun _ => ih

/-! ### The tactic -/

-- One step of `keeps`: a closure lemma, a function's `keeps_*` lemma (by name, unhygienic:
-- lemmas not yet defined fail and are skipped), or opening a binder or a match. The lemmas are
-- applied at reducible transparency, so no definition is unfolded behind the tactic's back.
set_option hygiene false in
macro "keeps_step" : tactic => `(tactic| first
  | (with_reducible exact Keeps.pure _)
  | (with_reducible exact Keeps.get)
  | (with_reducible exact Keeps.read)
  | (with_reducible exact Keeps.throwThe _)
  | (with_reducible exact Keeps.throw _)
  | (with_reducible exact Keeps.choose _)
  | (with_reducible exact Keeps.liftE _)
  | (with_reducible exact keeps_throwUb _)
  | (with_reducible exact keeps_throwIllFormed _)
  | (with_reducible exact keeps_throwNoBehavior _)
  | (with_reducible exact keeps_getMem)
  | (with_reducible apply keeps_setMem)
  | (with_reducible apply keeps_memUpdate)
  | (with_reducible exact keeps_prog)
  | (with_reducible exact keeps_curFrame)
  | (with_reducible apply keeps_setCurFrame)
  | (with_reducible apply keeps_modifyCurFrame)
  | (with_reducible apply keeps_jumpTo)
  | (with_reducible apply keeps_emit)
  | (with_reducible apply keeps_recordStatic)
  | (with_reducible apply keeps_ptrFromInt)
  | (with_reducible apply keeps_recordConstCopy)
  | (with_reducible apply keeps_localTy)
  | (with_reducible apply keeps_allocate)
  | (with_reducible apply keeps_ptrOffsetInbounds)
  | (with_reducible apply keeps_sizeAlignOf)
  | (with_reducible apply keeps_placeLoad)
  | (with_reducible apply keeps_placeStore)
  | (with_reducible apply keeps_localPlace)
  | (with_reducible apply keeps_readIndexLocal)
  | (with_reducible apply keeps_elemsOf)
  | (with_reducible apply keeps_projectPlace)
  | (with_reducible apply keeps_evalPlace)
  | (with_reducible apply keeps_global?)
  | (with_reducible apply keeps_fnPointer)
  | (with_reducible apply keeps_instOfFnPtr)
  | (with_reducible apply keeps_globalPtrF)
  | (with_reducible apply keeps_globalPtr)
  | (with_reducible apply keeps_resolveRef)
  | (with_reducible apply keeps_decodeConst)
  | (with_reducible apply keeps_evalConst)
  | (with_reducible apply keeps_evalOperand)
  | (with_reducible apply keeps_vtableWordPtr)
  | (with_reducible apply keeps_unsizeValue)
  | (with_reducible apply keeps_intLike)
  | (with_reducible apply keeps_evalCast)
  | (with_reducible apply keeps_resolveFloat)
  | (with_reducible apply keeps_orderingValue)
  | (with_reducible apply keeps_relResult)
  | (with_reducible apply keeps_evalIntBinOp)
  | (with_reducible apply keeps_pointeeSize)
  | (with_reducible apply keeps_evalBinOp)
  | (with_reducible apply keeps_evalUnOp)
  | (with_reducible apply keeps_addrOf)
  | (with_reducible apply keeps_evalRvalue)
  | (with_reducible apply keeps_storageDead)
  | (with_reducible apply keeps_storageLive)
  | (with_reducible apply keeps_copyBytes)
  | (with_reducible apply keeps_evalStatement)
  | (with_reducible apply keeps_evalArg)
  | (with_reducible apply keeps_untupleLast)
  | (with_reducible apply keeps_allocSlot)
  | (with_reducible apply keeps_createFrame)
  | (with_reducible apply keeps_pushFrame)
  | (with_reducible apply keeps_callBody)
  | (with_reducible apply keeps_popFrame)
  | (with_reducible apply keeps_argInt)
  | (with_reducible apply keeps_argPtr)
  | (with_reducible apply keeps_heapAlloc)
  | (with_reducible apply keeps_callEnv)
  | (with_reducible apply keeps_callExternal)
  | (with_reducible apply keeps_intArg)
  | (with_reducible apply keeps_ptrArg)
  | (with_reducible apply keeps_floatArg)
  | (with_reducible apply keeps_pointeeLayout)
  | (with_reducible apply keeps_atomicAlign)
  | (with_reducible apply keeps_evalIntrinsic)
  | (with_reducible apply keeps_deinitPlaces)
  | (with_reducible apply keeps_jumpOrUb)
  | (with_reducible apply keeps_contReturn)
  | (with_reducible apply keeps_callTerminate)
  | (with_reducible apply keeps_applyUnwindAction)
  | (with_reducible apply keeps_contUnwind)
  | (with_reducible apply keeps_unwindOut)
  | (with_reducible apply keeps_evalCallerLoc)
  | (with_reducible apply keeps_splitReceiver)
  | (with_reducible apply keeps_resolveCallee)
  | (with_reducible apply keeps_callInstance)
  | (with_reducible apply keeps_doReturn)
  | (with_reducible apply keeps_switchBits)
  | (with_reducible apply keeps_evalTerminator)
  | ((with_reducible apply Keeps.modify); intro _; exact GlobKept.of_eq rfl rfl rfl)
  | (with_reducible apply Keeps.forIn_list)
  | (with_reducible apply Keeps.mapM_list)
  | (with_reducible apply Keeps.foldlM_list)
  | (with_reducible apply Keeps.map)
  | (with_reducible apply Keeps.bind)
  | (intro _)
  | split
  | (dsimp only))

/-- `Keeps` of a composite: `keeps_step` until nothing applies. -/
macro "keeps" : tactic => `(tactic| repeat' keeps_step)

/-! ### The state helpers -/

theorem keeps_throwUb {α : Type} (msg : String) : Keeps (throwUb msg : SemM α) :=
  ⟨fun _ s => GlobKept.refl s⟩

theorem keeps_throwIllFormed {α : Type} (msg : String) : Keeps (throwIllFormed msg : SemM α) :=
  ⟨fun _ s => GlobKept.refl s⟩

theorem keeps_throwNoBehavior {α : Type} (msg : String) :
    Keeps (throwNoBehavior msg : SemM α) :=
  ⟨fun _ s => GlobKept.refl s⟩

theorem keeps_getMem : Keeps SemM.getMem := ⟨fun _ s => GlobKept.refl s⟩

theorem keeps_setMem (m : Memory) : Keeps (SemM.setMem m) :=
  ⟨fun _ _ => GlobKept.of_eq rfl rfl rfl⟩

theorem keeps_memUpdate (g : Memory → Except Outcome Memory) : Keeps (SemM.memUpdate g) :=
  ⟨fun o s => by rw [runOn_memUpdate]; split <;> exact GlobKept.of_eq rfl rfl rfl⟩

theorem keeps_prog : Keeps SemM.prog := ⟨fun _ s => GlobKept.refl s⟩

theorem keeps_curFrame : Keeps SemM.curFrame := by
  refine ⟨fun o s => ?_⟩
  cases hs : s.stack with
  | nil => rw [runOn_curFrame_nil hs]; exact GlobKept.refl s
  | cons f rest => rw [runOn_curFrame hs]; exact GlobKept.refl s

theorem keeps_setCurFrame (f : Spec.Frame) : Keeps (SemM.setCurFrame f) := by
  refine ⟨fun o s => ?_⟩
  cases hs : s.stack with
  | nil =>
    have e : runOn (SemM.setCurFrame f) o s = (.error (.illFormed "no active frame"), s) := by
      have e0 : runOn (SemM.setCurFrame f) o s = runOn (match s.stack with
          | _ :: rest => (modify fun s => { s with stack := f :: rest } : SemM Unit)
          | [] => throwIllFormed "no active frame") o s := rfl
      rw [e0, hs]; rfl
    rw [e]; exact GlobKept.refl s
  | cons g rest => rw [runOn_setCurFrame hs]; exact GlobKept.of_eq rfl rfl rfl

theorem keeps_modifyCurFrame (g : Spec.Frame → Spec.Frame) : Keeps (SemM.modifyCurFrame g) := by
  have e : SemM.modifyCurFrame g = (SemM.curFrame >>= fun f => SemM.setCurFrame (g f)) := rfl
  rw [e]
  exact keeps_curFrame.bind fun f => keeps_setCurFrame _

theorem keeps_jumpTo (bb : BasicBlock) : Keeps (SemM.jumpTo bb) := keeps_modifyCurFrame _

theorem keeps_emit (e : Event) : Keeps (SemM.emit e) := ⟨fun _ _ => GlobKept.of_eq rfl rfl rfl⟩

/-! ### `recordConstCopy`: the only write of the copies -/

theorem keeps_recordConstCopy (g : GlobalId) (p : ThinPointer) : Keeps (recordConstCopy g p) := by
  unfold recordConstCopy
  apply Keeps.modify
  intro s
  refine ⟨rfl, fun g' p0 ps h => ?_, fun _ p0 ps h => ⟨ps, h⟩⟩
  simp only [Array.getD_eq_getD_getElem?] at h ⊢
  -- `g'` is in range (its entry is non-empty)
  have hlt : g' < s.constCopies.size := by
    by_cases hl : g' < s.constCopies.size
    · exact hl
    · rw [Array.getElem?_eq_none (Nat.not_lt.mp hl)] at h
      cases h
  -- the extended array agrees below the old size, and holds `g`
  have harr : ∀ i, i < s.constCopies.size →
      (if s.constCopies.size ≤ g then
        s.constCopies ++ Array.replicate (g + 1 - s.constCopies.size) [] else s.constCopies)[i]? =
        s.constCopies[i]? := by
    intro i hi
    by_cases hc : s.constCopies.size ≤ g
    · rw [if_pos hc]; exact Array.getElem?_append_left hi
    · rw [if_neg hc]
  have hsz : g < (if s.constCopies.size ≤ g then
      s.constCopies ++ Array.replicate (g + 1 - s.constCopies.size) [] else s.constCopies).size := by
    by_cases hc : s.constCopies.size ≤ g
    · rw [if_pos hc, Array.size_append, Array.size_replicate,
        Nat.add_sub_of_le (Nat.le_succ_of_le hc)]
      exact Nat.lt_succ_self g
    · rw [if_neg hc]; exact Nat.not_le.mp hc
  generalize hA : (if s.constCopies.size ≤ g then
      s.constCopies ++ Array.replicate (g + 1 - s.constCopies.size) [] else s.constCopies) = A
    at harr hsz ⊢
  show ∃ ps', ((A.setIfInBounds g (A[g]! ++ [p]))[g']?).getD [] = p0 :: ps'
  by_cases hg : g' = g
  · rw [hg] at h hlt ⊢
    rw [Array.getElem?_setIfInBounds_self_of_lt hsz]
    have hA' : A[g]? = some (p0 :: ps) := by
      rw [harr g hlt]
      cases hc : s.constCopies[g]? with
      | none => rw [hc] at h; cases h
      | some l => rw [hc] at h; simp only [Option.getD_some] at h; rw [h]
    have hb : A[g]! = p0 :: ps := by
      rw [getElem!_pos A g hsz]
      exact Option.some.inj ((Array.getElem?_eq_getElem hsz).symm.trans hA')
    exact ⟨ps ++ [p], by rw [hb]; rfl⟩
  · rw [Array.getElem?_setIfInBounds_ne (fun e => hg e.symm), harr g' hlt]
    exact ⟨ps, h⟩

/-! ### The semantic functions, callees first -/

theorem keeps_localTy (f : Spec.Frame) (l : Local) : Keeps (SemM.localTy f l) := by
  unfold SemM.localTy; keeps

theorem keeps_allocate (m : Memory) (k : AllocationKind) (size : Size) (al : Align) (mu : Bool) :
    Keeps (m.allocate k size al mu : SemM (ThinPointer × Memory)) := by
  unfold Memory.allocate; keeps

theorem keeps_ptrOffsetInbounds (p : ThinPointer) (off : Int) : Keeps (ptrOffsetInbounds p off) := by
  unfold ptrOffsetInbounds; keeps

theorem keeps_sizeAlignOf (ty : Spec.Ty) (md : Option PointerMeta) : Keeps (sizeAlignOf ty md) := by
  unfold sizeAlignOf; keeps

theorem keeps_placeLoad (pl : Place) (ty : Spec.Ty) : Keeps (placeLoad pl ty) := by
  unfold placeLoad; keeps

theorem keeps_placeStore (pl : Place) (v : Value) (ty : Spec.Ty) : Keeps (placeStore pl v ty) := by
  unfold placeStore; keeps

theorem keeps_localPlace (l : Local) : Keeps (localPlace l) := by
  unfold localPlace; keeps

theorem keeps_readIndexLocal (l : Local) : Keeps (readIndexLocal l) := by
  unfold readIndexLocal; keeps

theorem keeps_elemsOf (pl : Place) (ty : Spec.Ty) : Keeps (elemsOf pl ty) := by
  unfold elemsOf; keeps

theorem keeps_projectPlace (pl : Place) (ty : Spec.Ty) (e : ProjElem) :
    Keeps (projectPlace pl ty e) := by
  cases e <;> (unfold projectPlace; keeps)

theorem keeps_evalPlace (p : MPlace) : Keeps (evalPlace p) := by
  unfold evalPlace; keeps

theorem keeps_global? (g : GlobalId) : Keeps (global? g) := by
  unfold global?; keeps

/-! ### `fnPointer`: the only write of the address copies -/

/-- A run whose final state has its start's `fnCopies`. -/
structure FnSame {α : Type} (x : SemM α) : Prop where
  run : ∀ o s, (runOn x o s).2.fnCopies = s.fnCopies

theorem FnSame.bind {α β : Type} {x : SemM α} {f : α → SemM β} (hx : FnSame x)
    (hf : ∀ a, FnSame (f a)) : FnSame (x >>= f) := by
  refine ⟨fun o s => ?_⟩
  have h1 := hx.run o s
  rw [runOn_bind]
  rcases h : runOn x o s with ⟨r, s1⟩
  rw [h] at h1
  cases r with
  | error e => exact h1
  | ok a => exact ((hf a).run o s1).trans h1

theorem FnSame.of_run {α : Type} {x : SemM α} (hx : FnSame x) {o : Spec.Oracle}
    {s s' : Spec.State} {r : Except Outcome α} (h : runOn x o s = (r, s')) :
    s'.fnCopies = s.fnCopies := by
  have := hx.run o s
  rw [h] at this
  exact this

theorem Keeps.of_run {α : Type} {x : SemM α} (hx : Keeps x) {o : Spec.Oracle}
    {s s' : Spec.State} {r : Except Outcome α} (h : runOn x o s = (r, s')) : GlobKept s s' := by
  have := hx.run o s
  rw [h] at this
  exact this

/-- An allocation keeps `fnCopies` (it only chooses an address and may fail). -/
theorem fnSame_allocate (m : Memory) (k : AllocationKind) (size : Size) (al : Align) (mu : Bool) :
    FnSame (m.allocate k size al mu : SemM (ThinPointer × Memory)) := by
  unfold Memory.allocate
  repeat' (first
    | exact ⟨fun _ _ => rfl⟩
    | (with_reducible apply FnSame.bind)
    | (intro _)
    | split)

/-- `GlobKept` over a bind: the first part's, then the rest's from its successful states. -/
theorem globKept_bind {α β : Type} {x : SemM α} {f : α → SemM β} {o : Spec.Oracle}
    {s0 s : Spec.State} (hx : GlobKept s0 (runOn x o s).2)
    (hf : ∀ a s1, runOn x o s = (.ok a, s1) → GlobKept s0 (runOn (f a) o s1).2) :
    GlobKept s0 (runOn (x >>= f) o s).2 := by
  rw [runOn_bind]
  rcases e : runOn x o s with ⟨r, s1⟩
  rw [e] at hx
  cases r with
  | error _ => exact hx
  | ok a => exact hf a s1 e

theorem runOn_modify (g : Spec.State → Spec.State) (o : Spec.Oracle) (s : Spec.State) :
    runOn (modify g : SemM Unit) o s = (.ok (), g s) := rfl

/-- `fnPointer`'s write of a fresh copy: `existing ++ [p]` at `i`, `existing` the entry `F` had,
keeps every first entry (as `keeps_recordConstCopy`). -/
theorem fnCopies_set_kept (F : Array (List ThinPointer)) (i : InstanceId) (p : ThinPointer) :
    ∀ j p0 ps, F.getD j [] = p0 :: ps → ∃ ps',
      ((if F.size ≤ i then F ++ Array.replicate (i + 1 - F.size) [] else F).set! i
        (F.getD i [] ++ [p])).getD j [] = p0 :: ps' := by
  intro j p0 ps h
  simp only [Array.getD_eq_getD_getElem?] at h ⊢
  have hlt : j < F.size := by
    by_cases hl : j < F.size
    · exact hl
    · rw [Array.getElem?_eq_none (Nat.not_lt.mp hl)] at h
      cases h
  have harr : ∀ k, k < F.size →
      (if F.size ≤ i then F ++ Array.replicate (i + 1 - F.size) [] else F)[k]? = F[k]? := by
    intro k hk
    by_cases hc : F.size ≤ i
    · rw [if_pos hc]; exact Array.getElem?_append_left hk
    · rw [if_neg hc]
  have hsz : i < (if F.size ≤ i then F ++ Array.replicate (i + 1 - F.size) [] else F).size := by
    by_cases hc : F.size ≤ i
    · rw [if_pos hc, Array.size_append, Array.size_replicate,
        Nat.add_sub_of_le (Nat.le_succ_of_le hc)]
      exact Nat.lt_succ_self i
    · rw [if_neg hc]; exact Nat.not_le.mp hc
  generalize hA : (if F.size ≤ i then F ++ Array.replicate (i + 1 - F.size) [] else F) = A
    at harr hsz ⊢
  show ∃ ps', ((A.setIfInBounds i (F[i]?.getD [] ++ [p]))[j]?).getD [] = p0 :: ps'
  by_cases hg : j = i
  · subst hg
    rw [Array.getElem?_setIfInBounds_self_of_lt hsz]
    exact ⟨ps ++ [p], by rw [h]; rfl⟩
  · rw [Array.getElem?_setIfInBounds_ne (fun e => hg e.symm), harr j hlt]
    exact ⟨ps, h⟩

/-- `fnPointer` keeps L0's globals: a reused copy changes only the choice count; a fresh one
appends to its instance's entry, which nothing between `fnPointer`'s read and its write changes
(`fnSame_allocate`). -/
theorem keeps_fnPointer (i : InstanceId) : Keeps (fnPointer i) := by
  refine ⟨fun o s => ?_⟩
  unfold fnPointer
  refine globKept_bind (GlobKept.refl s) fun s0 s1 hg => ?_
  rw [runOn_get] at hg
  obtain ⟨rfl, rfl⟩ := prod_ok_inj hg
  dsimp only
  refine globKept_bind (by rw [runOn_choose]; exact GlobKept.of_eq rfl rfl rfl) fun k s2 hc => ?_
  rw [runOn_choose] at hc
  obtain ⟨rfl, rfl⟩ := prod_ok_inj hc
  split
  · rw [runOn_pure]; exact GlobKept.of_eq rfl rfl rfl
  · refine globKept_bind (by rw [runOn_getMem0]; exact GlobKept.of_eq rfl rfl rfl)
      fun m s3 hm => ?_
    rw [runOn_getMem0] at hm
    obtain ⟨rfl, rfl⟩ := prod_ok_inj hm
    have hs1 : GlobKept s { s with choiceCount := s.choiceCount + 1 } := GlobKept.of_eq rfl rfl rfl
    refine globKept_bind (hs1.trans ((keeps_allocate _ _ _ _ _).run o _)) fun pm s4 ha => ?_
    have hk4 : GlobKept s s4 := hs1.trans (Keeps.of_run (keeps_allocate _ _ _ _ _) ha)
    have hf4 : s4.fnCopies = s.fnCopies := (FnSame.of_run (fnSame_allocate _ _ _ _ _) ha).trans rfl
    obtain ⟨p, mem⟩ := pm
    dsimp only
    have hs4 : GlobKept s4 { s4 with mem := mem } := GlobKept.of_eq rfl rfl rfl
    refine globKept_bind (by rw [runOn_setMem]; exact hk4.trans hs4)
      fun _ s5 hs => ?_
    rw [runOn_setMem] at hs
    obtain ⟨-, rfl⟩ := prod_ok_inj hs
    -- the state after the write, spelled out (the goal's `modify` reduces to it)
    have hkey : GlobKept s
        { s4 with
          mem := mem
          fnCopies := (if s4.fnCopies.size ≤ i then
            s4.fnCopies ++ Array.replicate (i + 1 - s4.fnCopies.size) [] else s4.fnCopies).set! i
              (s.fnCopies.getD i [] ++ [p])
          fnAllocs := match p.prov with
            | some id => s4.fnAllocs.insert id i
            | none => s4.fnAllocs } := by
      refine ⟨hk4.1, hk4.2, ?_⟩
      intro j p0 ps h
      show ∃ ps', ((if s4.fnCopies.size ≤ i then
          s4.fnCopies ++ Array.replicate (i + 1 - s4.fnCopies.size) [] else s4.fnCopies).set! i
            (s.fnCopies.getD i [] ++ [p])).getD j [] = p0 :: ps'
      rw [hf4]
      exact fnCopies_set_kept s.fnCopies i p j p0 ps h
    refine globKept_bind hkey fun _ s6 hmo => ?_
    obtain ⟨-, rfl⟩ := prod_ok_inj hmo
    rw [runOn_pure]
    exact hkey

theorem keeps_instOfFnPtr (p : Pointer) : Keeps (instOfFnPtr p) := by
  unfold instOfFnPtr; keeps

theorem keeps_recordStatic (g : GlobalId) (p : ThinPointer) : Keeps (recordStatic g p) := by
  unfold recordStatic
  apply Keeps.modify
  intro s
  exact GlobKept.of_eq rfl rfl rfl

theorem keeps_ptrFromInt (c : IntPtrCast) (addr : Nat) :
    Keeps (c.ptrFromInt addr : SemM ThinPointer) := by
  unfold IntPtrCast.ptrFromInt; keeps

private theorem keeps_globalPtrF_aux (n : Nat) (g : GlobalId) : Keeps (globalPtrF n g) := by
  induction n generalizing g with
  | zero => rw [globalPtrF]; keeps
  | succ n ih =>
    rw [globalPtrF]
    keeps
    all_goals (try exact ih _)

theorem keeps_globalPtrF (n : Nat) (g : GlobalId) : Keeps (globalPtrF n g) :=
  keeps_globalPtrF_aux n g

theorem keeps_globalPtr (g : GlobalId) : Keeps (globalPtr g) := by
  unfold globalPtr; keeps

theorem keeps_resolveRef (r : GlobalRef) (off : Nat) : Keeps (resolveRef r off) := by
  unfold resolveRef; keeps

theorem keeps_decodeConst (bs : List AbstractByte) (ty : Spec.Ty) : Keeps (decodeConst bs ty) := by
  unfold decodeConst; keeps

theorem keeps_evalConst (c : ConstOperand) (ty : Spec.Ty) : Keeps (evalConst c ty) := by
  unfold evalConst; keeps

theorem keeps_evalOperand (o : Operand) : Keeps (evalOperand o) := by
  cases o <;> (unfold evalOperand; keeps)

theorem keeps_vtableWordPtr (vt : ThinPointer) (k : Nat) : Keeps (vtableWordPtr vt k) := by
  unfold vtableWordPtr; keeps

private theorem keeps_unsizeValue_aux (m : UnsizeMeta) (n : Nat) (v : Value) (src dst : Spec.Ty) :
    Keeps (unsizeValue m n v src dst) := by
  induction n generalizing v src dst with
  | zero => unfold unsizeValue; keeps
  | succ n ih =>
    unfold unsizeValue
    keeps
    all_goals (try exact ih _ _ _)

theorem keeps_unsizeValue (m : UnsizeMeta) (n : Nat) (v : Value) (src dst : Spec.Ty) :
    Keeps (unsizeValue m n v src dst) :=
  keeps_unsizeValue_aux m n v src dst

theorem keeps_intLike (v : Value) : Keeps (intLike v) := by
  unfold intLike; keeps

theorem keeps_resolveFloat (f : FloatTy) (r : Float.FRes) : Keeps (resolveFloat f r) := by
  unfold resolveFloat; keeps

theorem keeps_evalCast (k : CastKind) (v : Value × Spec.Ty) (dst : Spec.Ty) :
    Keeps (evalCast k v dst) := by
  unfold evalCast; keeps

theorem keeps_orderingValue (o : Ordering) (ty : Spec.Ty) : Keeps (orderingValue o ty) := by
  unfold orderingValue; keeps

theorem keeps_relResult (op : BinOp) (o : Option Ordering) (ty : Spec.Ty) :
    Keeps (relResult op o ty) := by
  unfold relResult; keeps

theorem keeps_evalIntBinOp (op : BinOp) (t : IntType) (l r : Int) (ty : Spec.Ty) :
    Keeps (evalIntBinOp op t l r ty) := by
  unfold evalIntBinOp; keeps

theorem keeps_pointeeSize (pt : PtrType) : Keeps (pointeeSize pt) := by
  unfold pointeeSize; keeps

theorem keeps_evalBinOp (op : BinOp) (l r : Value × Spec.Ty) (ty : Spec.Ty) :
    Keeps (evalBinOp op l r ty) := by
  unfold evalBinOp; keeps

theorem keeps_evalUnOp (op : UnOp) (v : Value × Spec.Ty) (ty : Spec.Ty) :
    Keeps (evalUnOp op v ty) := by
  unfold evalUnOp; keeps

theorem keeps_addrOf (p : MPlace) (ty : Spec.Ty) (chk : Bool) : Keeps (addrOf p ty chk) := by
  unfold addrOf; keeps

theorem keeps_evalRvalue (rv : Rvalue) (ty : Spec.Ty) : Keeps (evalRvalue rv ty) := by
  unfold evalRvalue; keeps

theorem keeps_storageDead (l : Local) : Keeps (storageDead l) := by
  unfold storageDead; keeps

theorem keeps_storageLive (l : Local) : Keeps (storageLive l) := by
  unfold storageLive; keeps

theorem keeps_copyBytes (src dst : Pointer) (pt : PtrType) (n : Int) (no : Bool) :
    Keeps (copyBytes src dst pt n no) := by
  unfold copyBytes; keeps

theorem keeps_evalStatement (st : Statement) : Keeps (evalStatement st) := by
  cases st <;> (unfold evalStatement; keeps)

theorem keeps_switchBits (v : Value × Spec.Ty) : Keeps (switchBits v) := by
  unfold switchBits; keeps

/-! ### The non-call terminators

The call paths are M5c's (see the module comment); the function simulation continues only
after these terminators and an `assert`'s jump. -/

theorem keeps_term_goto (bb : BasicBlock) : Keeps (evalTerminator (.goto bb)) := by
  simp only [evalTerminator]
  exact keeps_jumpTo bb

theorem keeps_term_switchInt (d : Operand) (cs : List (Nat × BasicBlock)) (ow : BasicBlock) :
    Keeps (evalTerminator (.switchInt d cs ow)) := by
  simp only [evalTerminator]
  keeps

theorem keeps_term_unreachable : Keeps (evalTerminator .unreachable) := by
  simp only [evalTerminator]
  exact keeps_throwUb _

/-- A statement step keeps L0's globals. -/
theorem stmt_globKept {o : Spec.Oracle} {s s' : Spec.State} {st : Statement}
    {r : Except Outcome Unit} (h : runOn (evalStatement st) o s = (r, s')) : GlobKept s s' := by
  have := (keeps_evalStatement st).run o s
  rw [h] at this
  exact this

end Ryo.Proofs.Lower
