/-
Ryo.Check.Lower.Term — the relational spec of terminator lowering and its checker (aot.md §C1,
M5a), first rules, next to `Stmt.lean`'s statements.

`LowerTerm Γ next term is` says that the R instructions `is` (a block's terminator range
`[lo, next)` in the decoded code) are a lowering of MIR terminator `term`. A MIR block `bb` is
entered at R index `blockStart Γ bb`: the first instruction of its first statement range, or of
its terminator range when it has no statements (ranges are contiguous, so empty ranges give the
position too). Rules mirror `backend/src/lower/terminator.rs`:

- `goto`: `FnCx::jump`: nothing when `bb` starts at `next` (falls through), else one `jmp` to
  `bb`'s start (`gotoOk`).
- `ret`: `FnCx::ret` for return kind `0` (`ret [0, 0]`) and for an integer `_0` returned in one
  general-purpose register (`ret [_0's slot, k]`, `k` the function's return kind, a single
  integer part of `t`'s size at offset 0). sret and C `signext` returns (a widening first) are
  not covered.
- `switchNone`: a `SwitchInt` without cases is a `goto otherwise`.
- `switchBool`: one case `(v, bb)` on a `bool` local: `br` on its slot (branching when
  `(s != 0) != neg`), then the code of a goto to the other target (`selOk`: for each value of
  the branch condition, taken means the target is that block's start, not taken means the rest
  is a goto there).
- `switchInt`: the same on an integer local with `br.eq.imm` (condition `a == imm`, the
  immediate the case value at `t`'s width).

Fused blocks (`BlockCert.fused`: the compare lowered with the terminator) and dead blocks are not
covered (`checkBlockTerm`).
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- A function's context for its terminators' rules. -/
structure TermCtx extends StmtCtx where
  blocks : Array BlockCert
  /-- The function's return kind (`FuncCert.retKind`). -/
  retKind : Nat

/-- The R index block `bb` starts at (see the module comment). -/
def blockStart (Γ : TermCtx) (bb : BasicBlock) : Option Nat :=
  Γ.blocks[bb]?.map fun b => (b.stmts[0]?.map (·.1)).getD b.term.1

/-- A native `jmp`'s target. -/
def jmpTo : Insn → Option Nat
  | .native op [.target t] =>
    match op.full with
    | some f => if f.info.shape == .jmp then some t else none
    | none => none
  | _ => none

theorem jmpTo_spec {i : Insn} {t : Nat} (h : jmpTo i = some t) :
    ∃ op f, i = .native op [.target t] ∧ op.full = some f ∧ f.info.shape = .jmp := by
  unfold jmpTo at h
  split at h
  next op t' =>
    split at h
    next f hf =>
      split at h
      next hs =>
        cases h
        exact ⟨op, f, rfl, hf, by simpa using hs⟩
      next => cases h
    next => cases h
  next => cases h

/-- A native `ret`'s source slot and return-kind word. -/
def retOps : Insn → Option (Int × Nat)
  | .native op [.slot src, .imm k] =>
    match op.full with
    | some f => if f.info.shape == .ret then some (src.toInt, k.toNat) else none
    | none => none
  | _ => none

theorem retOps_spec {i : Insn} {src : Int} {k : Nat} (h : retOps i = some (src, k)) :
    ∃ op f s kw, i = .native op [.slot s, .imm kw] ∧ op.full = some f ∧ f.info.shape = .ret ∧
      s.toInt = src ∧ kw.toNat = k := by
  unfold retOps at h
  split at h
  next op s kw =>
    split at h
    next f hf =>
      split at h
      next hs =>
        cases h
        exact ⟨op, f, s, kw, rfl, hf, by simpa using hs, rfl, rfl⟩
      next => cases h
    next => cases h
  next => cases h

/-- The code of a goto to `bb` at the end of a terminator range ending at `next`. -/
def gotoOk (Γ : TermCtx) (next : Nat) (bb : BasicBlock) : List Insn → Bool
  | [] => blockStart Γ bb == some next
  | [i] =>
    match jmpTo i with
    | some t => blockStart Γ bb == some t
    | none => false
  | _ => false

theorem gotoOk_spec {Γ : TermCtx} {next : Nat} {bb : BasicBlock} {is : List Insn}
    (h : gotoOk Γ next bb is = true) :
    (is = [] ∧ blockStart Γ bb = some next) ∨
      ∃ i t, is = [i] ∧ jmpTo i = some t ∧ blockStart Γ bb = some t := by
  match is, h with
  | [], h =>
    left
    simp only [gotoOk, beq_iff_eq] at h
    exact ⟨rfl, h⟩
  | [i], h =>
    right
    simp only [gotoOk] at h
    split at h
    next t ht => exact ⟨i, t, rfl, ht, by simpa using h⟩
    next => cases h
  | _ :: _ :: _, h => simp [gotoOk] at h

/-- `ret`'s rule: return kind 0, or an integer `_0` in one register (see the module comment). -/
def retOk (Γ : TermCtx) (i : Insn) : Bool :=
  match retOps i with
  | some (src, k) =>
    k == Γ.retKind &&
      (k == 0 ||
        match Γ.body.locals[0]?, Γ.slots[0]? with
        | some (Ty.int t _), some s0 =>
          Asm.retParts k true == some (some ⟨false, t.size, 0⟩, none) && s0.size == t.size &&
            s0.off == src
        | _, _ => false)
  | none => false

/-- The R branch of `br` on slot `s`, with `neg` and target `t`, falling through otherwise. -/
def brOps (Γ : StmtCtx) (i : Insn) : Option (Int × Bool × Nat) :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler?, v.ops, v.ctl with
    | some ⟨.br, [], _⟩, [.slot s, .none, .none], some (.branch neg t) =>
      if v.op.info.operands == [⟨"s", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩] then
        some (s, neg, t)
      else none
    | _, _, _ => none
  | none => none

/-- `br.eq.imm` at `n` bytes: slot `a`, immediate `y`, `neg`, target `t`. -/
def brImmOps (Γ : StmtCtx) (i : Insn) (n : Nat) : Option (Int × Nat × Bool × Nat) :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler?, v.ops, v.ctl with
    | some ⟨.br_cmp_imm, [ty, m], _⟩, [.slot a, .imm y, .none, .none], some (.branch neg t) =>
      if m == "==" && intTyOk ty n &&
          v.op.info.operands.map (·.name) == ["a", "imm", "neg", "t"] &&
          v.op.info.operands.head?.map (·.kind) == some .slot then
        some (a, y, neg, t)
      else none
    | _, _, _ => none
  | none => none

/-- The MIR target for branch condition `b` of a `bool` switch on case value `v`. -/
def selBool (v : Nat) (bb otherwise : BasicBlock) (b : Bool) : BasicBlock :=
  if b == (v == 1) then bb else otherwise

/-- The MIR target for branch condition `b` (`a == v`) of an integer switch. -/
def selInt (bb otherwise : BasicBlock) (b : Bool) : BasicBlock :=
  if b then bb else otherwise

/-- A branch with `neg` to `t` followed by `tl`: for each condition `b`, R reaches `sel b`'s
start (taken: `t`; not taken: `tl`, a goto). -/
def selOk (Γ : TermCtx) (next : Nat) (neg : Bool) (t : Nat) (sel : Bool → BasicBlock)
    (tl : List Insn) : Bool :=
  [false, true].all fun b =>
    if b != neg then blockStart Γ (sel b) == some t else gotoOk Γ next (sel b) tl

theorem selOk_spec {Γ : TermCtx} {next : Nat} {neg : Bool} {t : Nat} {sel : Bool → BasicBlock}
    {tl : List Insn} (h : selOk Γ next neg t sel tl = true) (b : Bool) :
    ((b != neg) = true → blockStart Γ (sel b) = some t) ∧
      ((b != neg) = false → gotoOk Γ next (sel b) tl = true) := by
  unfold selOk at h
  have hb := List.all_eq_true.mp h b (by cases b <;> simp)
  refine ⟨fun hn => ?_, fun hn => ?_⟩
  · rw [if_pos hn] at hb
    simpa using hb
  · rw [if_neg (by rw [hn]; exact Bool.false_ne_true)] at hb
    exact hb

inductive LowerTerm (Γ : TermCtx) (next : Nat) : Terminator → List Insn → Prop where
  | goto {bb : BasicBlock} {is : List Insn} (h : gotoOk Γ next bb is = true) :
      LowerTerm Γ next (.goto bb) is
  | ret {i : Insn} (h : retOk Γ i = true) : LowerTerm Γ next .«return» [i]
  | switchNone {d : Operand} {l : Local} {otherwise : BasicBlock} {is : List Insn}
      (hd : d.local? = some l) (h : gotoOk Γ next otherwise is = true) :
      LowerTerm Γ next (.switchInt d [] otherwise) is
  | switchBool {d : Operand} {l : Local} {v : Nat} {bb otherwise : BasicBlock} {sl : LocalSlot}
      {ibr : Insn} {tl : List Insn} {s : Int} {neg : Bool} {t : Nat}
      (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some .bool)
      (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = 1) (hoff : offOk sl.off = true)
      (hbr : brOps Γ.toStmtCtx ibr = some (s, neg, t)) (hs : s = sl.off) (hv : v < 2)
      (hsel : selOk Γ next neg t (selBool v bb otherwise) tl = true) :
      LowerTerm Γ next (.switchInt d [(v, bb)] otherwise) (ibr :: tl)
  | switchInt {d : Operand} {l : Local} {v : Nat} {bb otherwise : BasicBlock} {sl : LocalSlot}
      {ty : IntType} {valid : ValidRange}
      {ibr : Insn} {tl : List Insn} {a : Int} {y : Nat} {neg : Bool} {t : Nat}
      (hd : d.local? = some l) (hty : Γ.body.locals[l]? = some (.int ty valid))
      (hsl : Γ.slots[l]? = some sl) (hsize : sl.size = ty.size) (hoff : offOk sl.off = true)
      (hbr : brImmOps Γ.toStmtCtx ibr ty.size = some (a, y, neg, t)) (ha : a = sl.off)
      (hv : v < 2 ^ (8 * ty.size)) (hy : y % 2 ^ (8 * ty.size) = v)
      (hsel : selOk Γ next neg t (selInt bb otherwise) tl = true) :
      LowerTerm Γ next (.switchInt d [(v, bb)] otherwise) (ibr :: tl)

/-- `ok` when `c` holds, else `unsupported why`. -/
def okIf (c : Bool) (why : String) : Verdict := if c then .ok else .unsupported why

theorem okIf_ok {c : Bool} {why : String} (h : okIf c why = .ok) : c = true := by
  cases c
  · simp [okIf] at h
  · rfl

/-- One-case `SwitchInt`'s checker. -/
def switch1Ok (Γ : TermCtx) (next : Nat) (d : Operand) (v : Nat) (bb otherwise : BasicBlock)
    (ibr : Insn) (tl : List Insn) : Bool :=
  match d.local? with
  | none => false
  | some l =>
    match Γ.body.locals[l]?, Γ.slots[l]? with
    | some .bool, some sl =>
      match brOps Γ.toStmtCtx ibr with
      | some (s, neg, t) =>
        sl.size == 1 && offOk sl.off && s == sl.off && decide (v < 2) &&
          selOk Γ next neg t (selBool v bb otherwise) tl
      | none => false
    | some (.int ty _), some sl =>
      match brImmOps Γ.toStmtCtx ibr ty.size with
      | some (a, y, neg, t) =>
        sl.size == ty.size && offOk sl.off && a == sl.off && decide (v < 2 ^ (8 * ty.size)) &&
          y % 2 ^ (8 * ty.size) == v && selOk Γ next neg t (selInt bb otherwise) tl
      | none => false
    | _, _ => false

theorem switch1Ok_sound {Γ : TermCtx} {next : Nat} {d : Operand} {v : Nat}
    {bb otherwise : BasicBlock} {ibr : Insn} {tl : List Insn}
    (h : switch1Ok Γ next d v bb otherwise ibr tl = true) :
    LowerTerm Γ next (.switchInt d [(v, bb)] otherwise) (ibr :: tl) := by
  unfold switch1Ok at h
  split at h
  next => cases h
  next l hl =>
    split at h
    next sl hty hsl =>
      split at h
      next s neg t hbr =>
        simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
        obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := h
        exact LowerTerm.switchBool (hd := hl) (hty := hty) (hsl := hsl) (hsize := h1)
          (hoff := h2) (hbr := hbr) (hs := h3) (hv := h4) (hsel := h5)
      next => cases h
    next ty valid sl hty hsl =>
      split at h
      next a y neg t hbr =>
        simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
        obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
        exact LowerTerm.switchInt (hd := hl) (hty := hty) (hsl := hsl) (hsize := h1)
          (hoff := h2) (hbr := hbr) (ha := h3) (hv := h4) (hy := h5) (hsel := h6)
      next => cases h
    next => cases h

/-- Decide `LowerTerm` for the rules so far, on a terminator range ending at `next`. -/
def checkTerm (Γ : TermCtx) (next : Nat) : Terminator → List Insn → Verdict
  | .goto bb, is => okIf (gotoOk Γ next bb is) "goto: form"
  | .«return», is =>
    match is with
    | [i] => okIf (retOk Γ i) "return: form"
    | _ => .unsupported "return: instruction count"
  | .switchInt d cases otherwise, is =>
    match cases, is with
    | [], is =>
      match d.local? with
      | some _ => okIf (gotoOk Γ next otherwise is) "switch: no cases, form"
      | none => .unsupported "switch: operand"
    | [(v, bb)], ibr :: tl => okIf (switch1Ok Γ next d v bb otherwise ibr tl) "switch: one case, form"
    | _, _ => .unsupported "switch: cases"
  | t, _ => .unsupported (match t with
    | .call .. => "terminator: call" | .tailCall .. => "terminator: tail call"
    | .drop .. => "terminator: drop" | .assert .. => "terminator: assert"
    | .unreachable => "terminator: unreachable" | .unwindResume => "terminator: resume"
    | .unwindTerminate _ => "terminator: terminate" | _ => "terminator")

theorem checkTerm_sound {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List Insn}
    (h : checkTerm Γ next term is = .ok) : LowerTerm Γ next term is := by
  cases term <;>
    first
    | (simp only [checkTerm] at h; cases h)
    | skip
  case goto bb =>
    simp only [checkTerm] at h
    exact .goto (okIf_ok h)
  case «return» =>
    simp only [checkTerm] at h
    split at h
    next i => exact .ret (okIf_ok h)
    next => cases h
  case switchInt d cases otherwise =>
    simp only [checkTerm] at h
    split at h
    next is' =>
      split at h
      next l hl => exact .switchNone hl (okIf_ok h)
      next => cases h
    next v bb ibr tl => exact switch1Ok_sound (okIf_ok h)
    next => cases h

/-- A block's terminator against its certificate range (`next` the range's end): fused and dead
blocks are not covered. -/
def checkBlockTerm (Γ : TermCtx) (b : BlockCert) (term : Terminator) (insns : Array Insn) :
    Verdict :=
  if b.fused then .unsupported "terminator: fused compare"
  else if b.dead then .unsupported "terminator: dead block"
  else checkTerm Γ b.term.2 term (insns.extract b.term.1 b.term.2).toList

theorem checkBlockTerm_sound {Γ : TermCtx} {b : BlockCert} {term : Terminator}
    {insns : Array Insn} (h : checkBlockTerm Γ b term insns = .ok) :
    b.fused = false ∧ b.dead = false ∧
      LowerTerm Γ b.term.2 term (insns.extract b.term.1 b.term.2).toList := by
  unfold checkBlockTerm at h
  cases hf : b.fused <;> simp only [hf, if_true, if_false, Bool.false_eq_true] at h
  · cases hd : b.dead <;> simp only [hd, if_true, if_false, Bool.false_eq_true] at h
    · exact ⟨rfl, rfl, checkTerm_sound h⟩
    · cases h
  · cases h

end Ryo.Check.Lower
