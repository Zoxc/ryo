/-
Ryo.Check.Lower.RetSret — `return` through the caller's sret pointer (aot.md §C1, M5b), next
to `RetX.lean`'s register returns.

What the backend emits (`FnCx::ret`, `backend/src/lower/call.rs`, return kind `RET_SRET`): the
prologue stored the caller's sret pointer (`gpr0`) to the sret slot `so` (`FuncCert.sret`,
`PrologX.lean`'s `sretWrites`); the return copies `_0`'s bytes to where it points and returns
the pointer in `rax`:

    store.copy [so + 0], _0, size(_0)
    ret so, k            -- k: one 8-byte integer part (`rax`)

`LowerRetSret Γ so .return [i1, i2]` is that: `_0`'s slot of `_0`'s type's size,
`storeCopyOk` for `i1`, `retOps i2 = (so, k)` with `Asm.retParts k true` the one part
`⟨false, 8, 0⟩`.

The sret pointer is read at the return: that it is still the caller's needs the slot's bytes
unchanged from the prologue on. `pinInsnOk` checks it per instruction (`pinCheck`: every
instruction of the function): an `arg` writes outside `[so, so + 8)` or is the prologue's
`arg so, gpr0` (rewriting the same bytes); an instruction `opSem` gives the meaning of has
every footprint write outside it; `jmp`, `ret`, calls, tail calls and islands are free (a `ret`
or a tail call ends the function; a call's or island's answer is M5c's).
-/
import Ryo.Check.Lower.PrologInd
import Ryo.Check.Lower.RetX
import Ryo.Vm.OpSem.Footprint

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- An instruction whose view is `store.copy [p + 0], s, n`, falling through, its operands in
range. -/
def storeCopyOk (mode : Ryo.Obj.Mode) (ρ : Addrs) (i : Insn) (p s : Int) (n : Nat) : Bool :=
  match view mode ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, _, _⟩ =>
      kd == .store_copy &&
        v.op.info.operands == [⟨"m", .mem⟩, ⟨"s", .slot⟩, ⟨"len", .u32⟩] &&
        v.ops == [.mem p 0, .slot s, .imm n] && v.ctl == some .next &&
        offOk p && offOk s && decide (n < 2 ^ 32)
    | none => false
  | none => false

theorem storeCopyOk_spec {mode : Ryo.Obj.Mode} {ρ : Addrs} {i : Insn} {p s : Int} {n : Nat}
    (h : storeCopyOk mode ρ i p s n = true) :
    ∃ v ps r, view mode ρ i = some v ∧ v.op.handler? = some ⟨.store_copy, ps, r⟩ ∧
      v.op.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩, ⟨"len", .u32⟩] ∧
      v.ops = [.mem p 0, .slot s, .imm n] ∧ v.ctl = some .next ∧
      offOk p = true ∧ offOk s = true ∧ n < 2 ^ 32 := by
  unfold storeCopyOk at h
  split at h
  next v hv =>
    split at h
    next kd ps r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
      obtain ⟨⟨⟨⟨⟨⟨hkd, ho⟩, hops⟩, hctl⟩, h1⟩, h2⟩, h3⟩ := h
      subst hkd
      exact ⟨v, ps, r, hv, hh, ho, hops, hctl, h1, h2, h3⟩
    · cases h
  · cases h

/-- The return kind of the sret pointer in `rax`. -/
def sretRetParts : Option (Option Asm.RetPart × Option Asm.RetPart) :=
  some (some ⟨false, 8, 0⟩, none)

inductive LowerRetSret (Γ : TermCtx) (so : Int) : Terminator → List Insn → Prop where
  | mk {i1 i2 : Insn} {ty : Ty} {s0 : LocalSlot} {k : Nat}
      (hkind : Γ.retKind = Ryo.Check.Image.RET_SRET)
      (hty : Γ.body.locals[0]? = some ty) (hsl : Γ.slots[0]? = some s0)
      (hsize : ty.size? = some s0.size)
      (hst : storeCopyOk Γ.mode Γ.ρ i1 so s0.off s0.size = true)
      (hro : retOps i2 = some (so, k)) (hk : Asm.retParts k true = sretRetParts) :
      LowerRetSret Γ so .«return» [i1, i2]

theorem LowerRetSret.term_eq {Γ : TermCtx} {so : Int} {term : Terminator} {is : List Insn}
    (h : LowerRetSret Γ so term is) : term = .«return» := by
  cases h; rfl

/-- The sret return's rule on its two instructions, with the function's sret slot. -/
def retSretOk (Γ : TermCtx) (sret : Option Int) (i1 i2 : Insn) : Bool :=
  match sret, Γ.body.locals[0]?, Γ.slots[0]?, retOps i2 with
  | some so, some ty, some s0, some (p, k) =>
    Γ.retKind == Ryo.Check.Image.RET_SRET && p == so && ty.size? == some s0.size &&
      storeCopyOk Γ.mode Γ.ρ i1 so s0.off s0.size && Asm.retParts k true == sretRetParts
  | _, _, _, _ => false

theorem retSretOk_sound {Γ : TermCtx} {sret : Option Int} {i1 i2 : Insn}
    (h : retSretOk Γ sret i1 i2 = true) :
    ∃ so, sret = some so ∧ LowerRetSret Γ so .«return» [i1, i2] := by
  unfold retSretOk at h
  cases e1 : sret with
  | none => simp [e1] at h
  | some so =>
    cases e2 : Γ.body.locals[0]? with
    | none => simp [e1, e2] at h
    | some ty =>
      cases e3 : Γ.slots[0]? with
      | none => simp [e1, e2, e3] at h
      | some s0 =>
        cases e4 : retOps i2 with
        | none => simp [e1, e2, e3, e4] at h
        | some pk =>
          obtain ⟨p, k⟩ := pk
          simp only [e1, e2, e3, e4, Bool.and_eq_true, beq_iff_eq] at h
          obtain ⟨⟨⟨⟨hk, hp⟩, hsz⟩, hsc⟩, hrp⟩ := h
          subst hp
          first
            | exact ⟨_, e1, .mk hk e2 e3 hsz hsc e4 hrp⟩
            | exact ⟨_, rfl, .mk hk e2 e3 hsz hsc e4 hrp⟩

/-- `return`'s sret checker: `none` unless the function returns through an sret pointer. -/
def checkRetSret (Γ : TermCtx) (sret : Option Int) (term : Terminator) (is : List Insn) :
    Option Verdict :=
  match term, is with
  | .«return», [i1, i2] =>
    if Γ.retKind == Ryo.Check.Image.RET_SRET then
      some (if retSretOk Γ sret i1 i2 then .ok else .unsupported "return: sret form")
    else none
  | _, _ => none

theorem checkRetSret_sound {Γ : TermCtx} {sret : Option Int} {term : Terminator}
    {is : List Insn} (h : checkRetSret Γ sret term is = some .ok) :
    ∃ so, sret = some so ∧ LowerRetSret Γ so term is := by
  unfold checkRetSret at h
  split at h
  next i1 i2 =>
    split at h
    next =>
      have h' := Option.some.inj h
      split at h'
      next hok => exact retSretOk_sound hok
      next => cases h'
    next => cases h
  next => cases h

/-! ### The sret slot is never overwritten -/

/-- An `arg`'s operands against the sret slot `so`: its write misses `[so, so + 8)`, or it is
`arg so, gpr0`. -/
def argPinOk (so : Int) : List (Opnd Nat) → Bool
  | [.slot d, .imm r] =>
    match Asm.ArgReg.of? r.toNat true with
    | some a =>
      decide (d.toInt + a.size ≤ so ∨ so + 8 ≤ d.toInt) || (d.toInt == so && a == sretReg)
    | none => true
  | _ => true

theorem argPinOk_spec {so : Int} {d : BitVec 32} {r : BitVec 64} {a : Asm.ArgReg}
    (ha : Asm.ArgReg.of? r.toNat true = some a) (h : argPinOk so [.slot d, .imm r] = true) :
    (d.toInt + a.size ≤ so ∨ so + 8 ≤ d.toInt) ∨ (d.toInt = so ∧ a = sretReg) := by
  simp only [argPinOk, ha, Bool.or_eq_true, decide_eq_true_eq, Bool.and_eq_true,
    beq_iff_eq] at h
  exact h

/-- An instruction `opSem` gives the meaning of: every footprint write misses `[so, so + 8)`. -/
def viewPinOk (mode : Ryo.Obj.Mode) (ρ : Addrs) (so : Int) (i : Insn) : Bool :=
  match view mode ρ i with
  | some v =>
    match OpSem.footprint v.op with
    | some fp =>
      (fp.writeRanges (OpSem.opndVal v.op.info v.ops)).all fun r =>
        decide (r.1 + r.2 ≤ so ∨ so + 8 ≤ r.1)
    | none => false
  | none => true

/-- A native instruction of shape `sh` leaves the sret slot `so` alone. -/
def pinShapeOk (mode : Ryo.Obj.Mode) (ρ : Addrs) (so : Int) (op : Reduced.Opcode)
    (ops : List (Opnd Nat)) : Shape → Bool
  | .arg => argPinOk so ops
  | .jmp | .ret | .call | .tailCall | .island => true
  | _ => viewPinOk mode ρ so (.native op ops)

/-- One instruction leaves the sret slot `so` alone (see the module comment). -/
def pinInsnOk (mode : Ryo.Obj.Mode) (ρ : Addrs) (so : Int) : Insn → Bool
  | .native op ops =>
    match op.full with
    | some f => pinShapeOk mode ρ so op ops f.info.shape
    | none => true
  | i => viewPinOk mode ρ so i

/-- Every instruction leaves the sret slot alone. -/
def pinCheck (mode : Ryo.Obj.Mode) (ρ : Addrs) (so : Int) (d : Decoded) : Bool :=
  d.insns.all (pinInsnOk mode ρ so)

theorem pinCheck_sound {mode : Ryo.Obj.Mode} {ρ : Addrs} {so : Int} {d : Decoded}
    (h : pinCheck mode ρ so d = true) :
    ∀ (k : Nat) i, d.insns[k]? = some i → pinInsnOk mode ρ so i = true := by
  intro k i hi
  unfold pinCheck at h
  obtain ⟨hk, rfl⟩ := Array.getElem?_eq_some_iff.mp hi
  exact Array.all_eq_true.mp h k hk

/-- No scope meets the sret slot `so`: an `Escape` of it would move its bytes into memory, an
`End` would clear them (functions with scopes, `SimRetSretX.lean`). -/
def pinScopesOk (so : Int) (d : Decoded) : Bool :=
  d.scopes.all fun ks =>
    decide (ks.2.frameOffset.toInt + ks.2.size ≤ so ∨ so + 8 ≤ ks.2.frameOffset.toInt)

end Ryo.Check.Lower
