/-
Ryo.Check.Lower.Cmp — the comparison rules of statement lowering and their checker (aot.md §C1,
M5b).

`LowerCmp Γ st is` says that the R instructions `is` lower the comparison statement `st`
(`binop.rs` `compare`, its non-float, non-wide-pointer branch). `checkCmp` decides it
(`checkCmp_sound`), answering `none` for a statement that is not a comparison.

Rules (`op ∈ {eq, ne, lt, le, gt, ge}`, `_d : bool`, private or escaped):
- `reg`: `_d = op(_a, _b)` (`copy`/`move` of whole locals) with `_a`, `_b` of one comparison
  type `ty` (an integer type `t`, or `bool`, which the backend compares as an unsigned byte),
  lowered to one `cmp` handler instruction at `ty`'s width on `[d, x, y]`: `x, y = a, b` with
  the operator's own `intCmp` operator, except that `gt`/`ge` swap them and use `<`/`<=` (the
  VM has no register `gt`/`ge`): `cmpRegForm`.
- `imm`: `_d = op(_a, const bits : tc)` with `tc` the same integer type as `_a`'s (any valid
  range) or `bool` for a `bool` `_a`, lowered to one `cmp_imm` instruction (operator `cmpOp op`,
  no swap) on `[d, a, imm]`, the immediate's low `8 × width` bits `bits`'s. `cmp_imm` reads its
  immediate as `BitVec.ofNat (8 * n) imm` (`Env.immBv`: the low bits, zero- or sign-extension
  of the encoded field above them is irrelevant), so agreement modulo `2 ^ (8 * n)` is exact.

The handler's type parameter carries the signedness `intCmp` uses: `cmpTyOk` requires it to be
`ty`'s for the order comparisons; `==`/`!=` handlers are typed unsigned at every type, which is
correct since equality does not depend on it. The slot of a `bool` is 1 byte, the operands'
slots `ty`'s size.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The `intCmp` operator (`Ryo.Vm.OpSem.intCmp`) of an L0 comparison, unswapped. -/
def cmpOp : BinOp → Option String
  | .eq => some "=="
  | .ne => some "!="
  | .lt => some "<"
  | .le => some "<="
  | .gt => some ">"
  | .ge => some ">="
  | _ => none

/-- The register form of a comparison (`compare` in binop.rs): the `cmp` handler's operator and
whether the operands are swapped (`a > b` as `b < a`, `a >= b` as `b <= a`). -/
def cmpRegForm : BinOp → Option (String × Bool)
  | .eq => some ("==", false)
  | .ne => some ("!=", false)
  | .lt => some ("<", false)
  | .le => some ("<=", false)
  | .gt => some ("<", true)
  | .ge => some ("<=", true)
  | _ => none

/-- A comparison operand type: its size in bytes and signedness. `bool` is an unsigned byte. -/
def cmpOpnd : Spec.Ty → Option (Nat × Bool)
  | .int t _ => some (t.size, t.signed)
  | .bool => some (1, false)
  | _ => none

/-- The constant's type `tc` matches the local's `ta`: the same integer type (valid ranges may
differ), or both `bool`. -/
def cmpConstTy : Spec.Ty → Spec.Ty → Bool
  | .int t _, .int t' _ => t == t'
  | .bool, .bool => true
  | _, _ => false

/-- A handler type parameter: an integer of `n` bytes, of signedness `sg` unless the operator
`o` is `==` or `!=`. -/
def cmpTyOk (ty o : String) (n : Nat) (sg : Bool) : Bool :=
  match OpSem.Ty.parse ty with
  | some (.int n' s) => n' == n && ((o == "==" || o == "!=") || s == sg)
  | _ => false

/-- An instruction whose view is a `cmp` handler with operator `o` at `n` bytes (signedness `sg`
for an order comparison), on slots `d, x, y`, falling through. -/
def cmpInsnOk (Γ : StmtCtx) (i : Insn) (o : String) (n : Nat) (sg : Bool) (d x y : Int) :
    Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, o'], _⟩ =>
      kd == .cmp && o' == o && cmpTyOk ty o n sg &&
        v.op.info.operands == [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] &&
        v.ops == [.slot d, .slot x, .slot y] && v.ctl == some .next
    | _ => false
  | none => false

/-- An instruction whose view is a `cmp_imm` handler with operator `o` at `n` bytes (signedness
`sg` for an order comparison), on slots `d, a` and an immediate whose low `n` bytes are
`bits`'s, falling through. -/
def cmpImmInsnOk (Γ : StmtCtx) (i : Insn) (o : String) (n : Nat) (sg : Bool) (d a : Int)
    (bits : Nat) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [ty, o'], _⟩ =>
      kd == .cmp_imm && o' == o && cmpTyOk ty o n sg &&
        v.op.info.operands.map (·.name) == ["d", "a", "imm"] &&
        (v.op.info.operands.take 2).map (·.kind) == [.slot, .slot] &&
        immOpsOk v.ops [d, a] n bits && v.ctl == some .next
    | _ => false
  | none => false

inductive LowerCmp (Γ : StmtCtx) : Statement → List Insn → Prop where
  | reg {d a b : Local} {oa ob : Operand} {op : BinOp} {o : String} {sw : Bool} {ty : Spec.Ty}
      {n : Nat} {sg : Bool} {sd sa sb : LocalSlot} {i : Insn}
      (hf : cmpRegForm op = some (o, sw)) (ha : oa.local? = some a) (hb : ob.local? = some b)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some ty)
      (htb : Γ.body.locals[b]? = some ty) (hty : cmpOpnd ty = some (n, sg))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sd.size = 1 ∧ sa.size = n ∧ sb.size = n)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off)
      (hi : cmpInsnOk Γ i o n sg sd.off (if sw then sb.off else sa.off)
        (if sw then sa.off else sb.off) = true) :
      LowerCmp Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) [i]
  | imm {d a : Local} {oa : Operand} {op : BinOp} {o : String} {bits : Nat} {ty tc : Spec.Ty}
      {n : Nat} {sg : Bool} {sd sa : LocalSlot} {i : Insn}
      (ho : cmpOp op = some o) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some ty)
      (hc : cmpConstTy tc ty = true) (hty : cmpOpnd ty = some (n, sg))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 1 ∧ sa.size = n)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : cmpImmInsnOk Γ i o n sg sd.off sa.off bits = true) :
      LowerCmp Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) tc))) [i]

/-- `reg`'s checker: `_d = oa op ob`, `op`'s register form `(o, sw)`. -/
def checkCmpReg (Γ : StmtCtx) (d : Local) (o : String) (sw : Bool) (oa ob : Operand)
    (is : List Insn) : Verdict :=
  match oa.local?, ob.local? with
  | some a, some b =>
    match Γ.body.locals[d]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some .bool, some ta, some tb =>
      match cmpOpnd ta with
      | some (n, sg) =>
        if ta = tb then
          match Γ.slots[d]?, Γ.slots[a]?, Γ.slots[b]?, is with
          | some sd, some sa, some sb, [i] =>
            if !(sd.size == 1 && sa.size == n && sb.size == n) then .rejected "cmp: slot sizes"
            else if !(offOk sd.off && offOk sa.off && offOk sb.off) then .rejected "cmp: offsets"
            else if cmpInsnOk Γ i o n sg sd.off (if sw then sb.off else sa.off)
                (if sw then sa.off else sb.off) then .ok
            else .unsupported "cmp: instruction form"
          | _, _, _, _ => .unsupported "cmp: slots or instruction count"
        else .unsupported "cmp: mixed types"
      | none => .unsupported "cmp: operand type"
    | _, _, _ => .unsupported "cmp: destination or operand types"
  | _, _ => .unsupported "cmp: operands"

/-- `imm`'s checker: `_d = oa op const bits : tc`, `op`'s operator `o`. -/
def checkCmpImm (Γ : StmtCtx) (d : Local) (o : String) (oa : Operand) (bits : Nat)
    (tc : Spec.Ty) (is : List Insn) : Verdict :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[d]?, Γ.body.locals[a]? with
    | some .bool, some ta =>
      match cmpOpnd ta with
      | some (n, sg) =>
        if cmpConstTy tc ta then
          match Γ.slots[d]?, Γ.slots[a]?, is with
          | some sd, some sa, [i] =>
            if !(sd.size == 1 && sa.size == n) then .rejected "cmp imm: slot sizes"
            else if !(offOk sd.off && offOk sa.off) then .rejected "cmp imm: offsets"
            else if cmpImmInsnOk Γ i o n sg sd.off sa.off bits then .ok
            else .unsupported "cmp imm: instruction form"
          | _, _, _ => .unsupported "cmp imm: slots or instruction count"
        else .unsupported "cmp imm: constant type"
      | none => .unsupported "cmp imm: operand type"
    | _, _ => .unsupported "cmp imm: destination or operand types"
  | none => .unsupported "cmp imm: operand"

/-- Decide `LowerCmp`; `none` for a statement that is not a comparison assignment. -/
def checkCmp (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) tc)) =>
    match cmpOp op with
    | some o => some (checkCmpImm Γ d o oa bits tc is)
    | none => none
  | .assign ⟨d, []⟩ (.binaryOp op oa ob) =>
    match cmpRegForm op with
    | some (o, sw) => some (checkCmpReg Γ d o sw oa ob is)
    | none => none
  | _ => none

/-! ### Soundness -/

theorem cmpOpnd_spec {ty : Spec.Ty} {n : Nat} {sg : Bool} (h : cmpOpnd ty = some (n, sg)) :
    (∃ t valid, ty = .int t valid ∧ n = t.size ∧ sg = t.signed) ∨
      (ty = .bool ∧ n = 1 ∧ sg = false) := by
  unfold cmpOpnd at h
  split at h
  next t valid =>
    have e := Option.some.inj h
    simp only [Prod.mk.injEq] at e
    exact .inl ⟨t, valid, rfl, e.1.symm, e.2.symm⟩
  next =>
    have e := Option.some.inj h
    simp only [Prod.mk.injEq] at e
    exact .inr ⟨rfl, e.1.symm, e.2.symm⟩
  · cases h

theorem cmpConstTy_spec {tc ta : Spec.Ty} (h : cmpConstTy tc ta = true) :
    (∃ t vc valid, tc = .int t vc ∧ ta = .int t valid) ∨ (tc = .bool ∧ ta = .bool) := by
  unfold cmpConstTy at h
  split at h
  next t vc t' valid =>
    have e : t = t' := by simpa using h
    subst e
    exact .inl ⟨t, vc, valid, rfl, rfl⟩
  next => exact .inr ⟨rfl, rfl⟩
  · cases h

theorem cmpTyOk_spec {ty o : String} {n : Nat} {sg : Bool} (h : cmpTyOk ty o n sg = true) :
    ∃ s, OpSem.Ty.parse ty = some (.int n s) ∧ ((o = "==" ∨ o = "!=") ∨ s = sg) := by
  unfold cmpTyOk at h
  split at h
  next n' s hp =>
    simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq] at h
    obtain ⟨e, h2⟩ := h
    subst e
    exact ⟨s, hp, h2⟩
  · cases h

theorem checkCmpReg_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {o : String} {sw : Bool}
    {oa ob : Operand} {is : List Insn} (hf : cmpRegForm op = some (o, sw))
    (h : checkCmpReg Γ d o sw oa ob is = .ok) :
    LowerCmp Γ (.assign ⟨d, []⟩ (.binaryOp op oa ob)) is := by
  unfold checkCmpReg at h
  split at h
  next a b ha hb =>
    split at h
    next ta tb htd hta htb =>
      split at h
      next n sg hty =>
        split at h
        next hab =>
          subst hab
          split at h
          next sd sa sb i hsd hsa hsb =>
            split at h
            · cases h
            next hsz =>
              split at h
              · cases h
              next hoff =>
                cases hi : cmpInsnOk Γ i o n sg sd.off (if sw then sb.off else sa.off)
                    (if sw then sa.off else sb.off) with
                | false => rw [hi] at h; cases h
                | true =>
                  have hsz' : sd.size = 1 ∧ sa.size = n ∧ sb.size = n := by
                    simp at hsz
                    first | exact ⟨hsz.1.1, hsz.1.2, hsz.2⟩ | exact hsz
                  have hoff' : offOk sd.off ∧ offOk sa.off ∧ offOk sb.off := by
                    simp at hoff
                    first | exact ⟨hoff.1.1, hoff.1.2, hoff.2⟩ | exact hoff
                  exact .reg hf ha hb htd hta htb hty hsd hsa hsb hsz' hoff' hi
          · cases h
        · cases h
      · cases h
    · cases h
  · cases h

theorem checkCmpImm_sound {Γ : StmtCtx} {d : Local} {op : BinOp} {o : String} {oa : Operand}
    {bits : Nat} {tc : Spec.Ty} {is : List Insn} (ho : cmpOp op = some o)
    (h : checkCmpImm Γ d o oa bits tc is = .ok) :
    LowerCmp Γ (.assign ⟨d, []⟩ (.binaryOp op oa (.const (.scalar bits) tc))) is := by
  unfold checkCmpImm at h
  split at h
  next a ha =>
    split at h
    next ta htd hta =>
      split at h
      next n sg hty =>
        split at h
        next hc =>
          split at h
          next sd sa i hsd hsa =>
            split at h
            · cases h
            next hsz =>
              split at h
              · cases h
              next hoff =>
                split at h
                next hi =>
                  exact .imm ho ha htd hta hc hty hsd hsa (by simpa using hsz)
                    (by simpa using hoff) hi
                · cases h
          · cases h
        · cases h
      · cases h
    · cases h
  · cases h

theorem checkCmp_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkCmp Γ st is = some .ok) : LowerCmp Γ st is := by
  unfold checkCmp at h
  split at h
  · split at h
    · rename_i ho
      exact checkCmpImm_sound ho (Option.some.inj h)
    · cases h
  · split at h
    · rename_i hf
      exact checkCmpReg_sound hf (Option.some.inj h)
    · cases h
  · cases h

end Ryo.Check.Lower
