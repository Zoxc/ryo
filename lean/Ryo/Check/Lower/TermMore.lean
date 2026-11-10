/-
Ryo.Check.Lower.TermMore — the rules of `Unreachable`, `UnwindResume` and `Assert` (aot.md §C1,
M5b), next to `Term.lean`'s. Rules mirror `backend/src/lower/terminator.rs`:

- `unreachable`: one `unreachable` trap (`Opcode::Unreachable`, a bare `ud2`). L0's step there
  is UB, so the simulation needs nothing of R; the rule only pins the form.
- `resume`: one `resume x` (`Opcode::Resume` on the frame's exception slot), its cleanup entry
  continuing the unwind (`unwind_entry(at, Continue)`). The cleanup table is the decoded
  function's, not the range's: `resumesCheck` checks it for every `resume` of the function
  (for `LowersFn`). That `x` is the slot the landing pads store the exception object to
  (`FuncCert.exception`) is M5c's: the simulation takes it as a hypothesis (`ExcAt`,
  `Proofs/Lower/SimTermMore.lean`).
- `assert`: `br c, !expected, target` on a `bool` local `c`'s slot (to `target` when
  `c == expected`), then the code of the panic call (`lang_item_call`), which is M5c's and not
  checked here: the simulation stops on the failing path (`AssertFails`).
- `assertField`: the same on a `bool` field of a local (`copy/move _a.f…`, `fieldPath`: the
  overflow flag `_t.1` of a checked operation's `(T, bool)` result): `br` on `_a`'s slot at the
  field's offset (`operand_slot` of the place, a slot inside `_a`'s).
- `assertKnown`/`assertKnownFail`: a `bool` constant condition (`known`): equal to `expected`
  the code of a goto to `target`, else only the panic call (again unchecked).

Not covered: fused `Assert`s (`Fused.lean`), the `!overflow_checks` jump of an optional overflow
check (a goto with a non-constant condition: rejected, as L0 may panic there).
-/
import Ryo.Check.Lower.Term
import Ryo.Check.Lower.Field

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- An `unreachable` trap. -/
def unreachableOk (Γ : StmtCtx) (i : Insn) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v => v.op == Full.Opcode.unreachable
  | none => false

/-- `resume x`'s slot. -/
def resumeOps (Γ : StmtCtx) (i : Insn) : Option Int :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    if v.op == Full.Opcode.resume && v.ctl.isSome then
      match v.ops with
      | [.slot x] => some x
      | _ => none
    else none
  | none => none

/-- Whether `i`'s view is a `resume`. -/
def isResume (mode : Ryo.Obj.Mode) (ρ : Addrs) (i : Insn) : Bool :=
  match view mode ρ i with
  | some v => v.op == Full.Opcode.resume
  | none => false

/-- A `bool` constant operand's bits. -/
def constBool? : Operand → Option Nat
  | .const (.scalar bits) .bool => some bits
  | _ => none

inductive LowerTermMore (Γ : TermCtx) (next : Nat) : Terminator → List Insn → Prop where
  | unreachable {i : Insn} (h : unreachableOk Γ.toStmtCtx i = true) :
      LowerTermMore Γ next .unreachable [i]
  | resume {i : Insn} {x : Int} (h : resumeOps Γ.toStmtCtx i = some x) :
      LowerTermMore Γ next .unwindResume [i]
  | assert {d : Operand} {l : Local} {expected : Bool} {msg : AssertMessage}
      {target : BasicBlock} {unwind : UnwindAction} {sl : LocalSlot} {ibr : Insn}
      {tl : List Insn} {s : Int} {neg : Bool} {t : Nat}
      (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some .bool)
      (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = 1) (hoff : offOk sl.off = true)
      (hbr : brOps Γ.toStmtCtx ibr = some (s, neg, t)) (hs : s = sl.off)
      (hneg : neg = !expected) (ht : blockStart Γ target = some t) :
      LowerTermMore Γ next (.assert d expected msg target unwind) (ibr :: tl)
  | assertField {d : Operand} {a : Local} {projs : List ProjElem} {ta : Spec.Ty} {off : Nat}
      {expected : Bool} {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction}
      {sl : LocalSlot} {ibr : Insn} {tl : List Insn} {s : Int} {neg : Bool} {t : Nat}
      (hd : operandPlace? d = some ⟨a, projs⟩) (hta : Γ.body.locals[a]? = some ta)
      (hpath : fieldPath ta projs = some (off, .bool)) (hsl : Γ.slots[a]? = some sl)
      (hin : off + 1 ≤ sl.size) (hoff : offOk (sl.off + off) = true)
      (hbr : brOps Γ.toStmtCtx ibr = some (s, neg, t)) (hs : s = sl.off + off)
      (hneg : neg = !expected) (ht : blockStart Γ target = some t) :
      LowerTermMore Γ next (.assert d expected msg target unwind) (ibr :: tl)
  | assertKnown {bits : Nat} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
      {unwind : UnwindAction} {is : List Insn}
      (hk : ((bits % 256 == 1) == expected) = true) (hg : gotoOk Γ next target is = true) :
      LowerTermMore Γ next (.assert (.const (.scalar bits) .bool) expected msg target unwind) is
  | assertKnownFail {bits : Nat} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
      {unwind : UnwindAction} {is : List Insn}
      (hk : ((bits % 256 == 1) == expected) = false) :
      LowerTermMore Γ next (.assert (.const (.scalar bits) .bool) expected msg target unwind) is

/-! ### The checker -/

theorem constBool?_spec {d : Operand} {bits : Nat} (h : constBool? d = some bits) :
    d = .const (.scalar bits) .bool := by
  unfold constBool? at h
  split at h
  · cases h; rfl
  · cases h

/-- `assert`'s conditions on a local condition. -/
def assertOk (Γ : TermCtx) (d : Operand) (expected : Bool) (target : BasicBlock) (ibr : Insn) :
    Bool :=
  match d.local? with
  | none => false
  | some l =>
    match Γ.body.locals[l]?, Γ.slots[l]? with
    | some .bool, some sl =>
      match brOps Γ.toStmtCtx ibr with
      | some (s, neg, t) =>
        sl.size == 1 && offOk sl.off && s == sl.off && neg == !expected &&
          blockStart Γ target == some t
      | none => false
    | _, _ => false

theorem assertOk_sound {Γ : TermCtx} {next : Nat} {d : Operand} {expected : Bool}
    {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction} {ibr : Insn}
    {tl : List Insn} (h : assertOk Γ d expected target ibr = true) :
    LowerTermMore Γ next (.assert d expected msg target unwind) (ibr :: tl) := by
  unfold assertOk at h
  split at h
  next => cases h
  next l hl =>
    split at h
    next sl hty hsl =>
      split at h
      next s neg t hbr =>
        simp only [Bool.and_eq_true, beq_iff_eq] at h
        obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := h
        exact .assert hl hty hsl h1 h2 hbr h3 h4 h5
      next => cases h
    next => cases h

/-- `assertField`'s conditions. -/
def assertFieldOk (Γ : TermCtx) (d : Operand) (expected : Bool) (target : BasicBlock)
    (ibr : Insn) : Bool :=
  match operandPlace? d with
  | some ⟨a, projs⟩ =>
    match Γ.body.locals[a]?, Γ.slots[a]? with
    | some ta, some sl =>
      match fieldPath ta projs with
      | some (off, .bool) =>
        match brOps Γ.toStmtCtx ibr with
        | some (s, neg, t) =>
          decide (off + 1 ≤ sl.size) && offOk (sl.off + off) && s == sl.off + off &&
            neg == !expected && blockStart Γ target == some t
        | none => false
      | _ => false
    | _, _ => false
  | none => false

theorem assertFieldOk_sound {Γ : TermCtx} {next : Nat} {d : Operand} {expected : Bool}
    {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction} {ibr : Insn}
    {tl : List Insn} (h : assertFieldOk Γ d expected target ibr = true) :
    LowerTermMore Γ next (.assert d expected msg target unwind) (ibr :: tl) := by
  unfold assertFieldOk at h
  split at h
  next a projs hd =>
    split at h
    next ta sl hta hsl =>
      split at h
      next off hpath =>
        split at h
        next s neg t hbr =>
          simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
          obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := h
          exact .assertField hd hta hpath hsl h1 h2 hbr h3 h4 h5
        next => cases h
      next => cases h
    next => cases h
  next => cases h

def checkUnreachable (Γ : TermCtx) : List Insn → Verdict
  | [i] => okIf (unreachableOk Γ.toStmtCtx i) "unreachable: form"
  | _ => .unsupported "unreachable: instruction count"

theorem checkUnreachable_sound {Γ : TermCtx} {next : Nat} {is : List Insn}
    (h : checkUnreachable Γ is = .ok) : LowerTermMore Γ next .unreachable is := by
  match is, h with
  | [i], h =>
    simp only [checkUnreachable] at h
    exact .unreachable (okIf_ok h)
  | [], h => simp [checkUnreachable] at h
  | _ :: _ :: _, h => simp [checkUnreachable] at h

def checkResume (Γ : TermCtx) : List Insn → Verdict
  | [i] =>
    match resumeOps Γ.toStmtCtx i with
    | some _ => .ok
    | none => .unsupported "resume: form"
  | _ => .unsupported "resume: instruction count"

theorem checkResume_sound {Γ : TermCtx} {next : Nat} {is : List Insn}
    (h : checkResume Γ is = .ok) : LowerTermMore Γ next .unwindResume is := by
  match is, h with
  | [i], h =>
    simp only [checkResume] at h
    split at h
    next x hx => exact .resume hx
    next => cases h
  | [], h => simp [checkResume] at h
  | _ :: _ :: _, h => simp [checkResume] at h

def checkAssert (Γ : TermCtx) (next : Nat) (d : Operand) (expected : Bool) (target : BasicBlock)
    (is : List Insn) : Verdict :=
  match constBool? d with
  | some bits =>
    if (bits % 256 == 1) == expected then okIf (gotoOk Γ next target is) "assert: known, form"
    else .ok
  | none =>
    match is with
    | ibr :: _ =>
      if assertOk Γ d expected target ibr then .ok
      else okIf (assertFieldOk Γ d expected target ibr) "assert: form"
    | [] => .unsupported "assert: instruction count"

theorem checkAssert_sound {Γ : TermCtx} {next : Nat} {d : Operand} {expected : Bool}
    {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction} {is : List Insn}
    (h : checkAssert Γ next d expected target is = .ok) :
    LowerTermMore Γ next (.assert d expected msg target unwind) is := by
  unfold checkAssert at h
  split at h
  next bits hb =>
    obtain rfl := constBool?_spec hb
    split at h
    next hk => exact .assertKnown hk (okIf_ok h)
    next hk => exact .assertKnownFail (Bool.eq_false_iff.mpr hk)
  next =>
    split at h
    next ibr tl =>
      split at h
      next ha => exact assertOk_sound ha
      next => exact assertFieldOk_sound (okIf_ok h)
    next => cases h

/-- Decide `LowerTermMore` (`none` for the other terminators). -/
def checkTermMore (Γ : TermCtx) (next : Nat) (term : Terminator) (is : List Insn) :
    Option Verdict :=
  match term with
  | .unreachable => some (checkUnreachable Γ is)
  | .unwindResume => some (checkResume Γ is)
  | .assert d expected _ target _ => some (checkAssert Γ next d expected target is)
  | _ => none

theorem checkTermMore_sound {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List Insn}
    (h : checkTermMore Γ next term is = some .ok) : LowerTermMore Γ next term is := by
  cases term with
  | unreachable => exact checkUnreachable_sound (Option.some.inj h)
  | unwindResume => exact checkResume_sound (Option.some.inj h)
  | assert d expected msg target unwind => exact checkAssert_sound (Option.some.inj h)
  | _ => simp [checkTermMore] at h

/-! ### The cleanup entries of `resume` -/

/-- Whether instruction `k`'s cleanup entry continues unwinding (`Code.cleanupAt`'s
`some (none, _)`). -/
def contAt (d : Decoded) (k : Nat) : Bool :=
  match (d.cleanup.find? (·.1 == k)).map (·.2) with
  | some (none, _) => true
  | _ => false

/-- Every `resume` of the function continues unwinding (see the module comment). -/
def resumesCheck (Γ : TermCtx) (d : Decoded) : Bool :=
  (List.range d.insns.size).all fun k => match d.insns[k]? with
    | some i => !isResume Γ.mode Γ.ρ i || contAt d k
    | none => true

theorem resumesCheck_sound {Γ : TermCtx} {d : Decoded} (h : resumesCheck Γ d = true) :
    ∀ (k : Nat) i, d.insns[k]? = some i → isResume Γ.mode Γ.ρ i = true → contAt d k = true := by
  intro k i hk hr
  unfold resumesCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have := h k (Array.getElem?_eq_some_iff.mp hk).1
  simp only [hk, hr, Bool.not_true, Bool.false_or] at this
  exact this

theorem resumeOps_isResume {Γ : StmtCtx} {i : Insn} {x : Int} (h : resumeOps Γ i = some x) :
    isResume Γ.mode Γ.ρ i = true := by
  unfold resumeOps at h
  unfold isResume
  split at h
  next v hv =>
    try rw [hv]
    split at h
    next hc =>
      simp only [Bool.and_eq_true] at hc
      exact hc.1
    next => cases h
  next => cases h

end Ryo.Check.Lower
