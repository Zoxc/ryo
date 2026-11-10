/-
Ryo.Check.Lower.PrologStack — the prologue's rule with stack inputs (aot.md §C1, M5b), next to
`PrologInd.lean`'s (registers and `Indirect` pointers in registers only).

What the backend emits (`FnCx::prologue`, `backend/src/lower/frame.rs`): first the `arg`s (as
`PrologInd.lean`: the sret pointer, each input's register pieces or `Indirect` pointer
register, the caller location), then per input, in order, its stack pieces' `mov`s from the
incoming argument area (frame offset `16 + at`, `incoming`) into its home (`Stack`), or its
pointer's into its pointer slot (`PtrStack`), and then an `Indirect` input's `load.copy` (when
not empty). A `mov` of `n` bytes is `mov.wN` pieces (`FnCx::mov`, `movPieces`; a `copy` handler
for large sizes is not covered).

`LowerPrologT Γ is inps lw`: the inputs (`InputOkT`: register and stack pieces inside the home,
`ArgExt.none` only; one pointer in a register; one pointer on the stack), the `arg`s
(`ArgsAre`), then the phase-2 items (`allItemsT`: `movs`, `copy`, `movCopy`) as `ItemsAre`, every
destination pairwise disjoint (`allDstsT`), every `mov` source (the incoming area) apart from
every destination, every register pointer slot apart from every phase-2 destination. Not covered
(`prologTWhy`): `byval`, extended C stack pieces, a spread argument.
-/
import Ryo.Check.Lower.PrologInd
import Ryo.Check.Lower.Agg

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The frame offset of the incoming argument area's byte `at_` (`fp + 16 + at_`). -/
def incoming (at_ : Nat) : Int := 16 + at_

/-- A stack piece of an input's value: `size` bytes at `off`, at `at_` in the incoming area. -/
structure StackPc where
  at_ : Nat
  off : Nat
  size : Nat

/-- How an input is passed, stack pieces allowed. -/
inductive InKindT where
  /-- Its pieces in registers and on the stack. -/
  | regs (rps : List (Nat × Asm.ArgReg)) (sps : List StackPc)
  /-- By address in integer register `idx`, the pointer stored to slot `ptr`. -/
  | ind (ptr : Int) (idx : Nat)
  /-- By address at `at_` in the incoming area, the pointer moved to slot `ptr`. -/
  | indStack (ptr : Int) (at_ : Nat)

structure InputT where
  slot : LocalSlot
  kind : InKindT

/-- An input's `arg` writes. -/
def InputT.writes (inp : InputT) : List ArgWrite :=
  match inp.kind with
  | .regs rps _ => rps.map fun p => (inp.slot.off + p.1, p.2)
  | .ind ptr idx => [(ptr, ptrArg idx)]
  | .indStack _ _ => []

/-- A phase-2 item: `n` bytes moved from `s` to `d`; a copy through a pointer slot the `arg`s
filled; a pointer's 8 bytes moved from `s` to the copy's pointer slot, then the copy (when not
empty). -/
inductive Item where
  | movs (d s : Int) (n : Nat)
  | copy (cp : CopyIn)
  | movCopy (cp : CopyIn) (s : Int)

/-- An input's phase-2 items. -/
def InputT.items (inp : InputT) : List Item :=
  match inp.kind with
  | .regs _ sps => sps.map fun sp => .movs (inp.slot.off + sp.off) (incoming sp.at_) sp.size
  | .ind ptr _ => if inp.slot.size = 0 then [] else [.copy ⟨inp.slot.off, ptr, inp.slot.size⟩]
  | .indStack ptr at_ => [.movCopy ⟨inp.slot.off, ptr, inp.slot.size⟩ (incoming at_)]

/-- An item's written ranges. -/
def Item.dsts : Item → List (Int × Nat)
  | .movs d _ n => [(d, n)]
  | .copy cp => [(cp.dst, cp.size)]
  | .movCopy cp _ => if cp.size = 0 then [(cp.ptr, 8)] else [(cp.ptr, 8), (cp.dst, cp.size)]

/-- An item's ranges of the incoming area, read. -/
def Item.srcs : Item → List (Int × Nat)
  | .movs _ s n => [(s, n)]
  | .copy _ => []
  | .movCopy _ s => [(s, 8)]

/-- An item's register pointer slot, read. -/
def Item.ptrs : Item → List (Int × Nat)
  | .copy cp => [(cp.ptr, 8)]
  | _ => []

/-- A function's rule context for statements' instruction forms (`movInsnOk`). -/
def PrologICtx.sctx (Γ : PrologICtx) : StmtCtx :=
  { body := default, slots := Γ.slots, mode := Γ.mode, ρ := Γ.ρ, escaped := Γ.escaped }

/-- The instructions of the phase-2 items, in order. -/
inductive ItemsAre (Γ : StmtCtx) : List Insn → List Item → Prop where
  | nil : ItemsAre Γ [] []
  | movs {d s : Int} {n : Nat} {ws : List Nat} {is rest : List Insn} {its : List Item}
      (hp : piecesOk Γ is (movPieces d s 0 ws) = true) (hsum : ws.sum = n)
      (hb : offOk d = true ∧ offOk (d + n) = true ∧ offOk s = true ∧ offOk (s + n) = true)
      (hr : ItemsAre Γ rest its) : ItemsAre Γ (is ++ rest) (.movs d s n :: its)
  | copy {i : Insn} {cp : CopyIn} {rest : List Insn} {its : List Item}
      (hc : loadCopyOk Γ.mode Γ.ρ i cp = true) (hr : ItemsAre Γ rest its) :
      ItemsAre Γ (i :: rest) (.copy cp :: its)
  | movCopy0 {cp : CopyIn} {s : Int} {ws : List Nat} {is rest : List Insn} {its : List Item}
      (hp : piecesOk Γ is (movPieces cp.ptr s 0 ws) = true) (hsum : ws.sum = 8)
      (hb : offOk cp.ptr = true ∧ offOk (cp.ptr + 8) = true ∧ offOk s = true ∧
        offOk (s + 8) = true)
      (hz : cp.size = 0) (hr : ItemsAre Γ rest its) :
      ItemsAre Γ (is ++ rest) (.movCopy cp s :: its)
  | movCopy1 {cp : CopyIn} {s : Int} {ws : List Nat} {is rest : List Insn} {i : Insn}
      {its : List Item}
      (hp : piecesOk Γ is (movPieces cp.ptr s 0 ws) = true) (hsum : ws.sum = 8)
      (hb : offOk cp.ptr = true ∧ offOk (cp.ptr + 8) = true ∧ offOk s = true ∧
        offOk (s + 8) = true)
      (hz : cp.size ≠ 0) (hc : loadCopyOk Γ.mode Γ.ρ i cp = true) (hr : ItemsAre Γ rest its) :
      ItemsAre Γ (is ++ i :: rest) (.movCopy cp s :: its)

/-- An input's plan pieces split into register and stack pieces (`ArgExt.none` only). -/
def splitPieces : List ArgLoc → Option (List (Nat × Asm.ArgReg) × List StackPc)
  | [] => some ([], [])
  | .reg a off :: ls => (splitPieces ls).map fun (r, s) => ((off, { a with sext := false }) :: r, s)
  | .stack at_ off size .none :: ls => (splitPieces ls).map fun (r, s) => (r, ⟨at_, off, size⟩ :: s)
  | _ :: _ => none

/-- Input `k`'s rule (see the module comment). -/
inductive InputOkT (Γ : PrologICtx) (k : Nat) : InputT → Prop where
  | regs {slot : LocalSlot} {rps : List (Nat × Asm.ArgReg)} {sps : List StackPc} (ls : List ArgLoc)
      (hs : Γ.slots[k + 1]? = some slot) (hh : Γ.argHomes[k]? = some slot.off)
      (hl : Γ.plan.locs[k]? = some ls) (hp : splitPieces ls = some (rps, sps))
      (hfit : ∀ p ∈ rps, p.1 + p.2.size ≤ slot.size)
      (hfs : ∀ sp ∈ sps, sp.off + sp.size ≤ slot.size) : InputOkT Γ k ⟨slot, .regs rps sps⟩
  | ind {slot : LocalSlot} {ptr : Int} {idx : Nat}
      (hs : Γ.slots[k + 1]? = some slot) (hh : Γ.argHomes[k]? = some slot.off)
      (hl : Γ.plan.locs[k]? = some [.ptrReg idx]) : InputOkT Γ k ⟨slot, .ind ptr idx⟩
  | indStack {slot : LocalSlot} {ptr : Int} {at_ : Nat}
      (hs : Γ.slots[k + 1]? = some slot) (hh : Γ.argHomes[k]? = some slot.off)
      (hl : Γ.plan.locs[k]? = some [.ptrStack at_]) : InputOkT Γ k ⟨slot, .indStack ptr at_⟩

theorem InputOkT.slot_eq {Γ : PrologICtx} {k : Nat} {inp : InputT} (h : InputOkT Γ k inp) :
    Γ.slots[k + 1]? = some inp.slot := by
  cases h with
  | regs _ hs => exact hs
  | ind hs => exact hs
  | indStack hs => exact hs

inductive InputsOkT (Γ : PrologICtx) : Nat → List InputT → Prop where
  | nil (k : Nat) : InputsOkT Γ k []
  | cons {k : Nat} {inp : InputT} {inps : List InputT} :
      InputOkT Γ k inp → InputsOkT Γ (k + 1) inps → InputsOkT Γ k (inp :: inps)

def allWritesT (Γ : PrologICtx) (inps : List InputT) (lw : List ArgWrite) : List ArgWrite :=
  sretWrites Γ.toPrologXCtx ++ inps.flatMap InputT.writes ++ lw

def allItemsT (inps : List InputT) : List Item := inps.flatMap InputT.items

def allDstsT (Γ : PrologICtx) (inps : List InputT) (lw : List ArgWrite) : List (Int × Nat) :=
  (allWritesT Γ inps lw).map ArgWrite.rng ++ (allItemsT inps).flatMap Item.dsts

structure LowerPrologT (Γ : PrologICtx) (is : List Insn) (inps : List InputT)
    (lw : List ArgWrite) : Prop where
  spread : Γ.spread = false
  len : inps.length = nInputs Γ.toPrologXCtx
  inputs : InputsOkT Γ 0 inps
  loc : locWrites Γ.toPrologXCtx inps.length = some lw
  args : ArgsAre (is.take (allWritesT Γ inps lw).length) (allWritesT Γ inps lw)
  items : ItemsAre Γ.sctx (is.drop (allWritesT Γ inps lw).length) (allItemsT inps)
  disj : (allDstsT Γ inps lw).Pairwise RngDisj
  srcs : ∀ r ∈ (allItemsT inps).flatMap Item.srcs, ∀ d ∈ allDstsT Γ inps lw, RngDisj r d
  ptrs : ∀ r ∈ (allItemsT inps).flatMap Item.ptrs, ∀ d ∈ (allItemsT inps).flatMap Item.dsts,
    RngDisj r d

/-! ### The checker -/

/-- Input `k`'s checker. -/
def checkInputT (Γ : PrologICtx) (k : Nat) : Option InputT :=
  match Γ.slots[k + 1]?, Γ.argHomes[k]?, Γ.plan.locs[k]? with
  | some slot, some h, some ls =>
    if h == slot.off then
      match ls with
      | [.ptrReg idx] =>
        match Γ.argPtrs[k]? with
        | some (some p) => some ⟨slot, .ind p idx⟩
        | _ => none
      | [.ptrStack at_] =>
        match Γ.argPtrs[k]? with
        | some (some p) => some ⟨slot, .indStack p at_⟩
        | _ => none
      | _ =>
        match splitPieces ls with
        | some (rps, sps) =>
          if rps.all (fun p => decide (p.1 + p.2.size ≤ slot.size)) &&
              sps.all (fun sp => decide (sp.off + sp.size ≤ slot.size)) then
            some ⟨slot, .regs rps sps⟩
          else none
        | none => none
    else none
  | _, _, _ => none

theorem checkInputT_sound {Γ : PrologICtx} {k : Nat} {inp : InputT}
    (h : checkInputT Γ k = some inp) : InputOkT Γ k inp := by
  unfold checkInputT at h
  split at h
  next slot hm ls h1 h2 h3 =>
    split at h
    next hc =>
      have hh : Γ.argHomes[k]? = some slot.off := by
        rw [h2]; simp only [beq_iff_eq] at hc; rw [hc]
      split at h
      next idx =>
        split at h
        next p _ =>
          simp only [Option.some.injEq] at h
          subst h
          exact .ind h1 hh h3
        next => cases h
      next at_ =>
        split at h
        next p _ =>
          simp only [Option.some.injEq] at h
          subst h
          exact .indStack h1 hh h3
        next => cases h
      next =>
        split at h
        next rps sps hps =>
          split at h
          next hall =>
            simp only [Option.some.injEq] at h
            subst h
            simp only [Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hall
            exact .regs ls h1 hh h3 hps hall.1 hall.2
          next => cases h
        next => cases h
    next => cases h
  next => cases h

def checkInputsT (Γ : PrologICtx) : Nat → Nat → Option (List InputT)
  | _, 0 => some []
  | k, n + 1 =>
    match checkInputT Γ k, checkInputsT Γ (k + 1) n with
    | some p, some ps => some (p :: ps)
    | _, _ => none

theorem checkInputsT_sound {Γ : PrologICtx} :
    ∀ {k n : Nat} {inps : List InputT}, checkInputsT Γ k n = some inps →
      inps.length = n ∧ InputsOkT Γ k inps
  | k, 0, inps, h => by
    simp only [checkInputsT, Option.some.injEq] at h
    subst h
    exact ⟨rfl, .nil k⟩
  | k, n + 1, inps, h => by
    unfold checkInputsT at h
    split at h
    next p ps h1 h2 =>
      simp only [Option.some.injEq] at h
      subst h
      obtain ⟨hl, hok⟩ := checkInputsT_sound h2
      exact ⟨by simp only [List.length_cons, hl], .cons (checkInputT_sound h1) hok⟩
    next => cases h

/-- `mov` pieces of `n` bytes from `s` to `d` at the head of `is`: the instructions after them. -/
def movsMatch (Γ : StmtCtx) (d s : Int) (n : Nat) (is : List Insn) : Option (List Insn) :=
  match parseMovs Γ d s n 0 is with
  | some (ws, _) =>
    if piecesOk Γ (is.take ws.length) (movPieces d s 0 ws) && ws.sum == n && offOk d &&
        offOk (d + n) && offOk s && offOk (s + n) then
      some (is.drop ws.length)
    else none
  | none => none

theorem movsMatch_spec {Γ : StmtCtx} {d s : Int} {n : Nat} {is rest : List Insn}
    (h : movsMatch Γ d s n is = some rest) :
    ∃ ws, piecesOk Γ (is.take ws.length) (movPieces d s 0 ws) = true ∧ ws.sum = n ∧
      (offOk d = true ∧ offOk (d + n) = true ∧ offOk s = true ∧ offOk (s + n) = true) ∧
      rest = is.drop ws.length := by
  unfold movsMatch at h
  split at h
  next ws _ _ =>
    split at h
    next hc =>
      simp only [Bool.and_eq_true, beq_iff_eq] at hc
      obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := hc
      simp only [Option.some.injEq] at h
      exact ⟨ws, h1, h2, ⟨h3, h4, h5, h6⟩, h.symm⟩
    next => cases h
  next => cases h

/-- The phase-2 items against the instructions. -/
def itemsMatch (Γ : StmtCtx) : List Insn → List Item → Bool
  | [], [] => true
  | is, .movs d s n :: its =>
    match movsMatch Γ d s n is with
    | some rest => itemsMatch Γ rest its
    | none => false
  | i :: is, .copy cp :: its => loadCopyOk Γ.mode Γ.ρ i cp && itemsMatch Γ is its
  | is, .movCopy cp s :: its =>
    match movsMatch Γ cp.ptr s 8 is with
    | some rest =>
      if cp.size = 0 then itemsMatch Γ rest its
      else
        match rest with
        | i :: rest' => loadCopyOk Γ.mode Γ.ρ i cp && itemsMatch Γ rest' its
        | [] => false
    | none => false
  | _, _ => false

theorem itemsMatch_movs {Γ : StmtCtx} {d s : Int} {n : Nat} {its : List Item} {is : List Insn} :
    itemsMatch Γ is (.movs d s n :: its) =
      (match movsMatch Γ d s n is with
        | some rest => itemsMatch Γ rest its
        | none => false) := by
  cases is <;> first | rfl | simp [itemsMatch]

theorem itemsMatch_movCopy {Γ : StmtCtx} {cp : CopyIn} {s : Int} {its : List Item}
    {is : List Insn} :
    itemsMatch Γ is (.movCopy cp s :: its) =
      (match movsMatch Γ cp.ptr s 8 is with
        | some rest =>
          if cp.size = 0 then itemsMatch Γ rest its
          else
            match rest with
            | i :: rest' => loadCopyOk Γ.mode Γ.ρ i cp && itemsMatch Γ rest' its
            | [] => false
        | none => false) := by
  cases is <;> first | rfl | simp [itemsMatch]

theorem itemsMatch_sound {Γ : StmtCtx} :
    ∀ {its : List Item} {is : List Insn}, itemsMatch Γ is its = true → ItemsAre Γ is its
  | [], [], _ => .nil
  | [], _ :: _, h => by simp [itemsMatch] at h
  | .movs d s n :: its, is, h => by
    rw [itemsMatch_movs] at h
    split at h
    next rest hm =>
      obtain ⟨ws, h1, h2, h3, rfl⟩ := movsMatch_spec hm
      have := ItemsAre.movs h1 h2 h3 (itemsMatch_sound h)
      rwa [List.take_append_drop] at this
    next => cases h
  | .copy cp :: its, [], h => by simp [itemsMatch] at h
  | .copy cp :: its, i :: is, h => by
    simp only [itemsMatch, Bool.and_eq_true] at h
    exact .copy h.1 (itemsMatch_sound h.2)
  | .movCopy cp s :: its, is, h => by
    rw [itemsMatch_movCopy] at h
    split at h
    next rest hm =>
      obtain ⟨ws, h1, h2, h3, hr⟩ := movsMatch_spec hm
      split at h
      next hz =>
        rw [hr] at h
        have := ItemsAre.movCopy0 h1 h2 h3 hz (itemsMatch_sound h)
        rwa [List.take_append_drop] at this
      next hz =>
        split at h
        next i rest' =>
          simp only [Bool.and_eq_true] at h
          have := ItemsAre.movCopy1 h1 h2 h3 hz h.1 (itemsMatch_sound h.2)
          rw [hr] at this
          rwa [List.take_append_drop] at this
        next => cases h
    next => cases h

/-- Every pair of `as` and `bs` disjoint. -/
def crossDisjoint (as bs : List (Int × Nat)) : Bool :=
  as.all fun r => bs.all fun d => decide (RngDisj r d)

theorem crossDisjoint_sound {as bs : List (Int × Nat)} (h : crossDisjoint as bs = true) :
    ∀ r ∈ as, ∀ d ∈ bs, RngDisj r d := by
  intro r hr d hd
  unfold crossDisjoint at h
  simp only [List.all_eq_true, decide_eq_true_eq] at h
  exact h r hr d hd

/-- The prologue's checker with stack inputs. -/
def checkPrologT (Γ : PrologICtx) (is : List Insn) : Option (List InputT × List ArgWrite) :=
  if Γ.spread then none
  else
    match checkInputsT Γ 0 (nInputs Γ.toPrologXCtx) with
    | some inps =>
      match locWrites Γ.toPrologXCtx inps.length with
      | some lw =>
        if argsMatch (is.take (allWritesT Γ inps lw).length) (allWritesT Γ inps lw) &&
            itemsMatch Γ.sctx (is.drop (allWritesT Γ inps lw).length) (allItemsT inps) &&
            rngsDisjoint (allDstsT Γ inps lw) &&
            crossDisjoint ((allItemsT inps).flatMap Item.srcs) (allDstsT Γ inps lw) &&
            crossDisjoint ((allItemsT inps).flatMap Item.ptrs)
              ((allItemsT inps).flatMap Item.dsts) then
          some (inps, lw)
        else none
      | none => none
    | none => none

theorem checkPrologT_sound {Γ : PrologICtx} {is : List Insn} {inps : List InputT}
    {lw : List ArgWrite} (h : checkPrologT Γ is = some (inps, lw)) : LowerPrologT Γ is inps lw := by
  unfold checkPrologT at h
  split at h
  next => cases h
  next hsp =>
    split at h
    next inps' hc =>
      split at h
      next lw' hl =>
        split at h
        next hm =>
          simp only [Option.some.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          simp only [Bool.and_eq_true] at hm
          obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := hm
          obtain ⟨hlen, hin⟩ := checkInputsT_sound hc
          exact ⟨by simpa using hsp, hlen, hin, hl, argsMatch_sound h1, itemsMatch_sound h2,
            rngsDisjoint_sound h3, crossDisjoint_sound h4, crossDisjoint_sound h5⟩
        next => cases h
      next => cases h
    next => cases h

/-- The prologue's verdict: `PrologInd.lean`'s rule, else this one. -/
def prologTVerdict (Γ : PrologICtx) (is : List Insn) : Verdict :=
  if prologIVerdict Γ is = .ok then .ok
  else
    match checkPrologT Γ is with
    | some _ => .ok
    | none => prologIVerdict Γ is

theorem prologTVerdict_sound {Γ : PrologICtx} {is : List Insn} (h : prologTVerdict Γ is = .ok) :
    (∃ inps lw, LowerPrologI Γ is inps lw) ∨ ∃ inps lw, LowerPrologT Γ is inps lw := by
  unfold prologTVerdict at h
  by_cases hv : prologIVerdict Γ is = .ok
  · exact .inl (prologIVerdict_sound hv)
  · rw [if_neg hv] at h
    split at h
    next r hr => exact .inr ⟨r.1, r.2, checkPrologT_sound hr⟩
    next => exact absurd h hv

end Ryo.Check.Lower
