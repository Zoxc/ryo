/-
Ryo.Check.Lower.Fused — the rules of a fused compare (aot.md §C1, M5b): a block whose last
statement `_c = op(_a, _b)` (`op ∈ {eq, ne, lt, le, gt, ge}`) feeds its `switchInt(_c)`, the
two lowered together over the terminator's range to one compare-and-branch (`br.<cmp>` or
`br.<cmp>.imm` on `_a`'s and `_b`'s slots or `_a`'s slot and an immediate), then the code of a
goto (`backend/src/lower/terminator.rs`: `fusable_compare`, `branch_cmp`, `branch_cmp2`). The
certificate marks such a block `fused` and gives the compare no range of its own (`BlockCert`).

`LowerFused Γ next st term is`: `st = _c = op(oa, ob)` with `_c : bool` and `term =
switchInt(_c) [(v, bb)] otherwise` (`v < 2`), `oa`, `ob` (a `copy`/`move` of a whole local or,
`imm`, `ob` a scalar constant) of one comparison type (`cmpOpnd`: an integer type or `bool`).
The branch `ibr` tests R's condition `cb = intCmp o x y` (the handler's operator `o` and the
operands, maybe swapped, of `branch_form`: `brRegForm`, `brImmForm`), and MIR's compare is
`cb != pol`. The rest `tl` and the branch's `neg`/target are checked by `selOk` against
`fusedSel pol v bb otherwise`: for each `cb`, the MIR target of the switch on `cb != pol`.

R never writes `_c`'s slot. The simulation (`Proofs/Lower/SimFused.lean`) therefore needs `_c`
dead at both successors' entries (`deadAtSuccs`, from `computeLive`: the backend fuses only
when the compare is `_c`'s only definition and the switch its only other use, so `_c` is read
nowhere else), and `_c`'s slot private (`hpriv`: L0's store to it must not be visible to R).

Niche-discriminant switches (`Fused::Discr`) are `Niche.lean`'s rule (`LowerFused.niche`) and,
in the dense form, `NicheDense.lean`'s (`LowerFused.nicheDense`).

A compare feeding an `Assert` (`LowerFused.assert`, `LowerFusedAssert`): one compare-and-branch
to the assert's target (`branch_cmp(c, expected, target)`), then the panic call, which M5c
checks. `FusedCmpBr` is the compare and its branch, `reg`'s and `imm`'s conditions without the
switch's; R branches exactly when MIR's compare is `expected` (`neg = (pol == expected)`).
`_c` must be dead at every successor of the assert (the target and the unwind's cleanup
block) and not read by the panic call (`hargs`), so that `FnRel` without `_c` serves both paths
(`Proofs/Lower/SimFused.lean`, `sim_fusedAssert`).

Thin pointer and `char` register compares (`CmpX.lean`'s `cmpUKind`, unsigned) are
`FusedCmpBr.regU`, fused with a switch by `LowerFused.sw` (the general form over `FusedCmpBr`).

Not covered (`checkFused`'s buckets): `char` compares with a constant, projected operands.
-/
import Ryo.Check.Lower.Cmp
import Ryo.Check.Lower.TermExt
import Ryo.Check.Lower.Live
import Ryo.Check.Lower.Niche
import Ryo.Check.Lower.NicheDense
import Ryo.Check.Lower.CmpX

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- `branch_form`'s register form of `op`: the `br_cmp` operator, whether the operands are
swapped and the polarity (`true`: MIR's compare is the negation of the handler's). -/
def brRegForm : BinOp → Option (String × Bool × Bool)
  | .eq => some ("==", false, false)
  | .ne => some ("==", false, true)
  | .lt => some ("<", false, false)
  | .ge => some ("<", false, true)
  | .gt => some ("<", true, false)
  | .le => some ("<", true, true)
  | _ => none

/-- `branch_form`'s immediate form of `op`: the `br_cmp_imm` operator and the polarity. -/
def brImmForm : BinOp → Option (String × Bool)
  | .eq => some ("==", false)
  | .ne => some ("==", true)
  | .lt => some ("<", false)
  | .ge => some ("<", true)
  | .gt => some (">", false)
  | .le => some (">", true)
  | _ => none

/-- A `br_cmp` (`br.eq`, `br.lt.s`, `br.lt.u`) at `n` bytes (signedness `sg` for an order
operator): its operator, slots `x, y`, `neg` and target `t`. -/
def brCmpOps (Γ : StmtCtx) (i : Insn) (n : Nat) (sg : Bool) :
    Option (String × Int × Int × Bool × Nat) :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler?, v.ops, v.ctl with
    | some ⟨.br_cmp, [ty, o], _⟩, [.slot x, .slot y, .none, .none], some (.branch neg t) =>
      if cmpTyOk ty o n sg &&
          v.op.info.operands == [⟨"a", .slot⟩, ⟨"b", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩] then
        some (o, x, y, neg, t)
      else none
    | _, _, _ => none
  | none => none

/-- A `br_cmp_imm` (`br.eq.imm`, `br.lt.*.imm`, `br.gt.*.imm`) at `n` bytes (signedness `sg`
for an order operator): its operator, slot `a`, immediate `y`, `neg` and target `t`. -/
def brCmpImmOps (Γ : StmtCtx) (i : Insn) (n : Nat) (sg : Bool) :
    Option (String × Int × Nat × Bool × Nat) :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler?, v.ops, v.ctl with
    | some ⟨.br_cmp_imm, [ty, o], _⟩, [.slot a, .imm y, .none, .none], some (.branch neg t) =>
      if cmpTyOk ty o n sg && v.op.info.operands.map (·.name) == ["a", "imm", "neg", "t"] &&
          v.op.info.operands.head?.map (·.kind) == some .slot then
        some (o, a, y, neg, t)
      else none
    | _, _, _ => none
  | none => none

/-- The MIR target of the fused switch on case `v` when R's compare is `cb` (MIR's is
`cb != pol`). -/
def fusedSel (pol : Bool) (v : Nat) (bb otherwise : BasicBlock) (cb : Bool) : BasicBlock :=
  selBool v bb otherwise (cb != pol)

/-- `_c` is dead at the entry of every block of `bbs` (`computeLive`). -/
def deadAtSuccs (Γ : TermCtx) (c : Local) (bbs : List BasicBlock) : Bool :=
  bbs.all fun b => !(computeLive Γ.body).get b 0 c

inductive FusedCmpBr (Γ : TermCtx) : Statement → Insn → Local → Bool → Bool → Nat → Prop where
  | reg {c a b : Local} {oa ob : Operand} {op : BinOp} {o : String} {sw pol : Bool}
      {ty : Spec.Ty} {n : Nat} {sg : Bool} {sc sa sb : LocalSlot} {ibr : Insn} {x y : Int}
      {neg : Bool} {t : Nat}
      (hf : brRegForm op = some (o, sw, pol)) (ha : oa.local? = some a)
      (hb : ob.local? = some b)
      (htc : Γ.body.locals[c]? = some .bool) (hta : Γ.body.locals[a]? = some ty)
      (htb : Γ.body.locals[b]? = some ty) (hty : cmpOpnd ty = some (n, sg))
      (hsc : Γ.slots[c]? = some sc) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sc.size = 1 ∧ sa.size = n ∧ sb.size = n)
      (hoff : offOk sa.off = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sc.size, Γ.escaped (sc.off + k) = false)
      (hbr : brCmpOps Γ.toStmtCtx ibr n sg = some (o, x, y, neg, t))
      (hxy : x = (if sw then sb.off else sa.off) ∧ y = (if sw then sa.off else sb.off)) :
      FusedCmpBr Γ (.assign ⟨c, []⟩ (.binaryOp op oa ob)) ibr c pol neg t
  | imm {c a : Local} {oa : Operand} {op : BinOp} {o : String} {pol : Bool} {bits : Nat}
      {ty tc : Spec.Ty} {n : Nat} {sg : Bool} {sc sa : LocalSlot} {ibr : Insn} {x : Int}
      {y : Nat} {neg : Bool} {t : Nat}
      (hf : brImmForm op = some (o, pol)) (ha : oa.local? = some a)
      (htc : Γ.body.locals[c]? = some .bool) (hta : Γ.body.locals[a]? = some ty)
      (hc : cmpConstTy tc ty = true) (hty : cmpOpnd ty = some (n, sg))
      (hsc : Γ.slots[c]? = some sc) (hsa : Γ.slots[a]? = some sa)
      (hsize : sc.size = 1 ∧ sa.size = n) (hoff : offOk sa.off = true)
      (hpriv : ∀ k < sc.size, Γ.escaped (sc.off + k) = false)
      (hbr : brCmpImmOps Γ.toStmtCtx ibr n sg = some (o, x, y, neg, t)) (hx : x = sa.off)
      (hy : y % 2 ^ (8 * n) = bits % 2 ^ (8 * n)) :
      FusedCmpBr Γ (.assign ⟨c, []⟩ (.binaryOp op oa (.const (.scalar bits) tc))) ibr c pol neg t
  /-- Thin pointers or `char`s (`cmpUKind`), compared unsigned. -/
  | regU {c a b : Local} {oa ob : Operand} {op : BinOp} {o : String} {sw pol : Bool}
      {ta tb : Spec.Ty} {n : Nat} {sc sa sb : LocalSlot} {ibr : Insn} {x y : Int}
      {neg : Bool} {t : Nat}
      (hf : brRegForm op = some (o, sw, pol)) (ha : oa.local? = some a)
      (hb : ob.local? = some b)
      (htc : Γ.body.locals[c]? = some .bool) (hta : Γ.body.locals[a]? = some ta)
      (htb : Γ.body.locals[b]? = some tb) (hk : cmpUKind ta tb = some n)
      (hsc : Γ.slots[c]? = some sc) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sc.size = 1 ∧ sa.size = n ∧ sb.size = n)
      (hoff : offOk sa.off = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sc.size, Γ.escaped (sc.off + k) = false)
      (hbr : brCmpOps Γ.toStmtCtx ibr n false = some (o, x, y, neg, t))
      (hxy : x = (if sw then sb.off else sa.off) ∧ y = (if sw then sa.off else sb.off)) :
      FusedCmpBr Γ (.assign ⟨c, []⟩ (.binaryOp op oa ob)) ibr c pol neg t

inductive LowerFusedAssert (Γ : TermCtx) (next : Nat) :
    Statement → Terminator → List Insn → Prop where
  | mk {st : Statement} {ibr : Insn} {tl : List Insn} {c : Local} {pol neg : Bool} {t : Nat}
      {od : Operand} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
      {unwind : UnwindAction}
      (hcmp : FusedCmpBr Γ st ibr c pol neg t) (hd : od.local? = some c)
      (hneg : neg = (pol == expected)) (ht : blockStart Γ target = some t)
      (hdead : deadAtSuccs Γ c (termSuccs (.assert od expected msg target unwind)) = true)
      (hargs : (!(msg.args.flatMap operandLocals).contains c) = true) :
      LowerFusedAssert Γ next st (.assert od expected msg target unwind) (ibr :: tl)

inductive LowerFused (Γ : TermCtx) (next : Nat) : Statement → Terminator → List Insn → Prop where
  | reg {c a b : Local} {oa ob od : Operand} {op : BinOp} {o : String} {sw pol : Bool}
      {ty : Spec.Ty} {n : Nat} {sg : Bool} {sc sa sb : LocalSlot} {v : Nat}
      {bb otherwise : BasicBlock} {ibr : Insn} {tl : List Insn} {x y : Int} {neg : Bool}
      {t : Nat}
      (hf : brRegForm op = some (o, sw, pol)) (ha : oa.local? = some a)
      (hb : ob.local? = some b) (hd : od.local? = some c)
      (htc : Γ.body.locals[c]? = some .bool) (hta : Γ.body.locals[a]? = some ty)
      (htb : Γ.body.locals[b]? = some ty) (hty : cmpOpnd ty = some (n, sg))
      (hsc : Γ.slots[c]? = some sc) (hsa : Γ.slots[a]? = some sa) (hsb : Γ.slots[b]? = some sb)
      (hsize : sc.size = 1 ∧ sa.size = n ∧ sb.size = n)
      (hoff : offOk sa.off = true ∧ offOk sb.off = true)
      (hpriv : ∀ k < sc.size, Γ.escaped (sc.off + k) = false)
      (hbr : brCmpOps Γ.toStmtCtx ibr n sg = some (o, x, y, neg, t))
      (hxy : x = (if sw then sb.off else sa.off) ∧ y = (if sw then sa.off else sb.off))
      (hv : v < 2) (hsel : selOk Γ next neg t (fusedSel pol v bb otherwise) tl = true)
      (hdead : deadAtSuccs Γ c [bb, otherwise] = true) :
      LowerFused Γ next (.assign ⟨c, []⟩ (.binaryOp op oa ob))
        (.switchInt od [(v, bb)] otherwise) (ibr :: tl)
  | imm {c a : Local} {oa od : Operand} {op : BinOp} {o : String} {pol : Bool} {bits : Nat}
      {ty tc : Spec.Ty} {n : Nat} {sg : Bool} {sc sa : LocalSlot} {v : Nat}
      {bb otherwise : BasicBlock} {ibr : Insn} {tl : List Insn} {x : Int} {y : Nat}
      {neg : Bool} {t : Nat}
      (hf : brImmForm op = some (o, pol)) (ha : oa.local? = some a) (hd : od.local? = some c)
      (htc : Γ.body.locals[c]? = some .bool) (hta : Γ.body.locals[a]? = some ty)
      (hc : cmpConstTy tc ty = true) (hty : cmpOpnd ty = some (n, sg))
      (hsc : Γ.slots[c]? = some sc) (hsa : Γ.slots[a]? = some sa)
      (hsize : sc.size = 1 ∧ sa.size = n) (hoff : offOk sa.off = true)
      (hpriv : ∀ k < sc.size, Γ.escaped (sc.off + k) = false)
      (hbr : brCmpImmOps Γ.toStmtCtx ibr n sg = some (o, x, y, neg, t)) (hx : x = sa.off)
      (hy : y % 2 ^ (8 * n) = bits % 2 ^ (8 * n))
      (hv : v < 2) (hsel : selOk Γ next neg t (fusedSel pol v bb otherwise) tl = true)
      (hdead : deadAtSuccs Γ c [bb, otherwise] = true) :
      LowerFused Γ next (.assign ⟨c, []⟩ (.binaryOp op oa (.const (.scalar bits) tc)))
        (.switchInt od [(v, bb)] otherwise) (ibr :: tl)
  /-- A niche-discriminant switch (`Niche.lean`). -/
  | niche {st : Statement} {term : Terminator} {is : List Insn}
      (h : LowerNicheSwitch Γ next st term is) : LowerFused Γ next st term is
  /-- A niche-discriminant switch's dense form (`NicheDense.lean`). -/
  | nicheDense {st : Statement} {term : Terminator} {is : List Insn}
      (h : LowerNicheDense Γ next st term is) : LowerFused Γ next st term is
  /-- A compare feeding an `Assert`. -/
  | assert {st : Statement} {term : Terminator} {is : List Insn}
      (h : LowerFusedAssert Γ next st term is) : LowerFused Γ next st term is
  /-- `reg`/`imm` over any `FusedCmpBr` (used for `regU`). -/
  | sw {st : Statement} {od : Operand} {c : Local} {pol neg : Bool} {t : Nat} {v : Nat}
      {bb otherwise : BasicBlock} {ibr : Insn} {tl : List Insn}
      (hcmp : FusedCmpBr Γ st ibr c pol neg t) (hd : od.local? = some c) (hv : v < 2)
      (hsel : selOk Γ next neg t (fusedSel pol v bb otherwise) tl = true)
      (hdead : deadAtSuccs Γ c [bb, otherwise] = true) :
      LowerFused Γ next st (.switchInt od [(v, bb)] otherwise) (ibr :: tl)

/-! ### The checker -/

/-- `reg`'s conditions. -/
def fusedRegOk (Γ : TermCtx) (next : Nat) (c : Local) (op : BinOp) (oa ob od : Operand)
    (v : Nat) (bb otherwise : BasicBlock) (ibr : Insn) (tl : List Insn) : Bool :=
  match brRegForm op, oa.local?, ob.local?, od.local? with
  | some (o, sw, pol), some a, some b, some c' =>
    match Γ.body.locals[c]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some .bool, some ta, some tb =>
      match cmpOpnd ta with
      | some (n, sg) =>
        match Γ.slots[c]?, Γ.slots[a]?, Γ.slots[b]? with
        | some sc, some sa, some sb =>
          match brCmpOps Γ.toStmtCtx ibr n sg with
          | some (o', x, y, neg, t) =>
            c' == c && (decide (ta = tb) && (o' == o && (sc.size == 1 && (sa.size == n &&
              (sb.size == n && (offOk sa.off && (offOk sb.off &&
              (privOk Γ.toStmtCtx sc.off sc.size &&
              (x == (if sw then sb.off else sa.off) && (y == (if sw then sa.off else sb.off) &&
              (decide (v < 2) && (selOk Γ next neg t (fusedSel pol v bb otherwise) tl &&
              deadAtSuccs Γ c [bb, otherwise]))))))))))))
          | none => false
        | _, _, _ => false
      | none => false
    | _, _, _ => false
  | _, _, _, _ => false

theorem fusedRegOk_sound {Γ : TermCtx} {next : Nat} {c : Local} {op : BinOp}
    {oa ob od : Operand} {v : Nat} {bb otherwise : BasicBlock} {ibr : Insn} {tl : List Insn}
    (h : fusedRegOk Γ next c op oa ob od v bb otherwise ibr tl = true) :
    LowerFused Γ next (.assign ⟨c, []⟩ (.binaryOp op oa ob))
      (.switchInt od [(v, bb)] otherwise) (ibr :: tl) := by
  unfold fusedRegOk at h
  split at h
  next o sw pol a b c' hf ha hb hd =>
    split at h
    next ta tb htc hta htb =>
      split at h
      next n sg hty =>
        split at h
        next sc sa sb hsc hsa hsb =>
          split at h
          next o' x y neg t hbr =>
            simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
            obtain ⟨hc', hab, ho, h1, h2, h3, h4, h5, hp, hx, hy, hv, hsel, hdead⟩ := h
            subst hc' hab ho
            exact .reg hf ha hb hd htc hta htb hty hsc hsa hsb ⟨h1, h2, h3⟩ ⟨h4, h5⟩
              (privOk_spec hp) hbr ⟨hx, hy⟩ hv hsel hdead
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- `sw` with `regU`'s conditions (thin pointers or `char`s). -/
def fusedRegUOk (Γ : TermCtx) (next : Nat) (c : Local) (op : BinOp) (oa ob od : Operand)
    (v : Nat) (bb otherwise : BasicBlock) (ibr : Insn) (tl : List Insn) : Bool :=
  match brRegForm op, oa.local?, ob.local?, od.local? with
  | some (o, sw, pol), some a, some b, some c' =>
    match Γ.body.locals[c]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some .bool, some ta, some tb =>
      match cmpUKind ta tb with
      | some n =>
        match Γ.slots[c]?, Γ.slots[a]?, Γ.slots[b]? with
        | some sc, some sa, some sb =>
          match brCmpOps Γ.toStmtCtx ibr n false with
          | some (o', x, y, neg, t) =>
            c' == c && (o' == o && (sc.size == 1 && (sa.size == n &&
              (sb.size == n && (offOk sa.off && (offOk sb.off &&
              (privOk Γ.toStmtCtx sc.off sc.size &&
              (x == (if sw then sb.off else sa.off) && (y == (if sw then sa.off else sb.off) &&
              (decide (v < 2) && (selOk Γ next neg t (fusedSel pol v bb otherwise) tl &&
              deadAtSuccs Γ c [bb, otherwise])))))))))))
          | none => false
        | _, _, _ => false
      | none => false
    | _, _, _ => false
  | _, _, _, _ => false

theorem fusedRegUOk_sound {Γ : TermCtx} {next : Nat} {c : Local} {op : BinOp}
    {oa ob od : Operand} {v : Nat} {bb otherwise : BasicBlock} {ibr : Insn} {tl : List Insn}
    (h : fusedRegUOk Γ next c op oa ob od v bb otherwise ibr tl = true) :
    LowerFused Γ next (.assign ⟨c, []⟩ (.binaryOp op oa ob))
      (.switchInt od [(v, bb)] otherwise) (ibr :: tl) := by
  unfold fusedRegUOk at h
  split at h
  next o sw pol a b c' hf ha hb hd =>
    split at h
    next ta tb htc hta htb =>
      split at h
      next n hk =>
        split at h
        next sc sa sb hsc hsa hsb =>
          split at h
          next o' x y neg t hbr =>
            simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
            obtain ⟨hc', ho, h1, h2, h3, h4, h5, hp, hx, hy, hv, hsel, hdead⟩ := h
            subst hc' ho
            exact .sw (.regU hf ha hb htc hta htb hk hsc hsa hsb ⟨h1, h2, h3⟩ ⟨h4, h5⟩
              (privOk_spec hp) hbr ⟨hx, hy⟩) hd hv hsel hdead
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- `imm`'s conditions. -/
def fusedImmOk (Γ : TermCtx) (next : Nat) (c : Local) (op : BinOp) (oa : Operand) (bits : Nat)
    (tc : Spec.Ty) (od : Operand) (v : Nat) (bb otherwise : BasicBlock) (ibr : Insn)
    (tl : List Insn) : Bool :=
  match brImmForm op, oa.local?, od.local? with
  | some (o, pol), some a, some c' =>
    match Γ.body.locals[c]?, Γ.body.locals[a]? with
    | some .bool, some ta =>
      match cmpOpnd ta with
      | some (n, sg) =>
        match Γ.slots[c]?, Γ.slots[a]? with
        | some sc, some sa =>
          match brCmpImmOps Γ.toStmtCtx ibr n sg with
          | some (o', x, y, neg, t) =>
            c' == c && (cmpConstTy tc ta && (o' == o && (sc.size == 1 && (sa.size == n &&
              (offOk sa.off && (privOk Γ.toStmtCtx sc.off sc.size && (x == sa.off &&
              (y % 2 ^ (8 * n) == bits % 2 ^ (8 * n) && (decide (v < 2) &&
              (selOk Γ next neg t (fusedSel pol v bb otherwise) tl &&
              deadAtSuccs Γ c [bb, otherwise]))))))))))
          | none => false
        | _, _ => false
      | none => false
    | _, _ => false
  | _, _, _ => false

theorem fusedImmOk_sound {Γ : TermCtx} {next : Nat} {c : Local} {op : BinOp} {oa : Operand}
    {bits : Nat} {tc : Spec.Ty} {od : Operand} {v : Nat} {bb otherwise : BasicBlock}
    {ibr : Insn} {tl : List Insn}
    (h : fusedImmOk Γ next c op oa bits tc od v bb otherwise ibr tl = true) :
    LowerFused Γ next (.assign ⟨c, []⟩ (.binaryOp op oa (.const (.scalar bits) tc)))
      (.switchInt od [(v, bb)] otherwise) (ibr :: tl) := by
  unfold fusedImmOk at h
  split at h
  next o pol a c' hf ha hd =>
    split at h
    next ta htc hta =>
      split at h
      next n sg hty =>
        split at h
        next sc sa hsc hsa =>
          split at h
          next o' x y neg t hbr =>
            simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
            obtain ⟨hc', hct, ho, h1, h2, h3, hp, hx, hy, hv, hsel, hdead⟩ := h
            subst hc' ho
            exact .imm hf ha hd htc hta hct hty hsc hsa ⟨h1, h2⟩ h3 (privOk_spec hp) hbr hx hy
              hv hsel hdead
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- A comparison operand type the rules cover (for the bucket). -/
def fusedOpndOk (Γ : StmtCtx) (oa : Operand) : Bool :=
  match oa.local? with
  | some a =>
    match Γ.body.locals[a]? with
    | some ta => (cmpOpnd ta).isSome
    | none => false
  | none => false

/-- The conditions shared by both forms after the branch's: polarity, target, liveness. -/
def fusedAssertTail (Γ : TermCtx) (c : Local) (pol neg : Bool) (t : Nat) (od : Operand)
    (expected : Bool) (msg : AssertMessage) (target : BasicBlock) (unwind : UnwindAction) :
    Bool :=
  neg == (pol == expected) && (blockStart Γ target == some t &&
    (deadAtSuccs Γ c (termSuccs (.assert od expected msg target unwind)) &&
    !(msg.args.flatMap operandLocals).contains c))

theorem fusedAssertTail_spec {Γ : TermCtx} {c : Local} {pol neg : Bool} {t : Nat}
    {od : Operand} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
    {unwind : UnwindAction}
    (h : fusedAssertTail Γ c pol neg t od expected msg target unwind = true) :
    neg = (pol == expected) ∧ blockStart Γ target = some t ∧
      deadAtSuccs Γ c (termSuccs (.assert od expected msg target unwind)) = true ∧
      (!(msg.args.flatMap operandLocals).contains c) = true := by
  unfold fusedAssertTail at h
  simp only [Bool.and_eq_true, beq_iff_eq] at h
  exact h

/-- The register form's conditions. -/
def fusedAssertRegOk (Γ : TermCtx) (c : Local) (op : BinOp) (oa ob od : Operand)
    (expected : Bool) (msg : AssertMessage) (target : BasicBlock) (unwind : UnwindAction)
    (ibr : Insn) : Bool :=
  match brRegForm op, oa.local?, ob.local?, od.local? with
  | some (o, sw, pol), some a, some b, some c' =>
    match Γ.body.locals[c]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some .bool, some ta, some tb =>
      match cmpOpnd ta with
      | some (n, sg) =>
        match Γ.slots[c]?, Γ.slots[a]?, Γ.slots[b]? with
        | some sc, some sa, some sb =>
          match brCmpOps Γ.toStmtCtx ibr n sg with
          | some (o', x, y, neg, t) =>
            c' == c && (decide (ta = tb) && (o' == o && (sc.size == 1 && (sa.size == n &&
              (sb.size == n && (offOk sa.off && (offOk sb.off &&
              (privOk Γ.toStmtCtx sc.off sc.size &&
              (x == (if sw then sb.off else sa.off) && (y == (if sw then sa.off else sb.off) &&
              fusedAssertTail Γ c pol neg t od expected msg target unwind))))))))))
          | none => false
        | _, _, _ => false
      | none => false
    | _, _, _ => false
  | _, _, _, _ => false

theorem fusedAssertRegOk_sound {Γ : TermCtx} {next : Nat} {c : Local} {op : BinOp}
    {oa ob od : Operand} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
    {unwind : UnwindAction} {ibr : Insn} {tl : List Insn}
    (h : fusedAssertRegOk Γ c op oa ob od expected msg target unwind ibr = true) :
    LowerFusedAssert Γ next (.assign ⟨c, []⟩ (.binaryOp op oa ob))
      (.assert od expected msg target unwind) (ibr :: tl) := by
  unfold fusedAssertRegOk at h
  split at h
  next o sw pol a b c' hf ha hb hd =>
    split at h
    next ta tb htc hta htb =>
      split at h
      next n sg hty =>
        split at h
        next sc sa sb hsc hsa hsb =>
          split at h
          next o' x y neg t hbr =>
            simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
            obtain ⟨hc', hab, ho, h1, h2, h3, h4, h5, hp, hx, hy, htl⟩ := h
            subst hc' hab ho
            obtain ⟨hneg, ht, hdead, hargs⟩ := fusedAssertTail_spec htl
            exact .mk (.reg hf ha hb htc hta htb hty hsc hsa hsb ⟨h1, h2, h3⟩ ⟨h4, h5⟩
              (privOk_spec hp) hbr ⟨hx, hy⟩) hd hneg ht hdead hargs
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- `fusedAssertRegOk` with `regU`'s conditions (thin pointers or `char`s). -/
def fusedAssertRegUOk (Γ : TermCtx) (c : Local) (op : BinOp) (oa ob od : Operand)
    (expected : Bool) (msg : AssertMessage) (target : BasicBlock) (unwind : UnwindAction)
    (ibr : Insn) : Bool :=
  match brRegForm op, oa.local?, ob.local?, od.local? with
  | some (o, sw, pol), some a, some b, some c' =>
    match Γ.body.locals[c]?, Γ.body.locals[a]?, Γ.body.locals[b]? with
    | some .bool, some ta, some tb =>
      match cmpUKind ta tb with
      | some n =>
        match Γ.slots[c]?, Γ.slots[a]?, Γ.slots[b]? with
        | some sc, some sa, some sb =>
          match brCmpOps Γ.toStmtCtx ibr n false with
          | some (o', x, y, neg, t) =>
            c' == c && (o' == o && (sc.size == 1 && (sa.size == n &&
              (sb.size == n && (offOk sa.off && (offOk sb.off &&
              (privOk Γ.toStmtCtx sc.off sc.size &&
              (x == (if sw then sb.off else sa.off) && (y == (if sw then sa.off else sb.off) &&
              fusedAssertTail Γ c pol neg t od expected msg target unwind)))))))))
          | none => false
        | _, _, _ => false
      | none => false
    | _, _, _ => false
  | _, _, _, _ => false

theorem fusedAssertRegUOk_sound {Γ : TermCtx} {next : Nat} {c : Local} {op : BinOp}
    {oa ob od : Operand} {expected : Bool} {msg : AssertMessage} {target : BasicBlock}
    {unwind : UnwindAction} {ibr : Insn} {tl : List Insn}
    (h : fusedAssertRegUOk Γ c op oa ob od expected msg target unwind ibr = true) :
    LowerFusedAssert Γ next (.assign ⟨c, []⟩ (.binaryOp op oa ob))
      (.assert od expected msg target unwind) (ibr :: tl) := by
  unfold fusedAssertRegUOk at h
  split at h
  next o sw pol a b c' hf ha hb hd =>
    split at h
    next ta tb htc hta htb =>
      split at h
      next n hk =>
        split at h
        next sc sa sb hsc hsa hsb =>
          split at h
          next o' x y neg t hbr =>
            simp only [Bool.and_eq_true, beq_iff_eq] at h
            obtain ⟨hc', ho, h1, h2, h3, h4, h5, hp, hx, hy, htl⟩ := h
            subst hc' ho
            obtain ⟨hneg, ht, hdead, hargs⟩ := fusedAssertTail_spec htl
            exact .mk (.regU hf ha hb htc hta htb hk hsc hsa hsb ⟨h1, h2, h3⟩ ⟨h4, h5⟩
              (privOk_spec hp) hbr ⟨hx, hy⟩) hd hneg ht hdead hargs
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- The immediate form's conditions. -/
def fusedAssertImmOk (Γ : TermCtx) (c : Local) (op : BinOp) (oa : Operand) (bits : Nat)
    (tc : Spec.Ty) (od : Operand) (expected : Bool) (msg : AssertMessage)
    (target : BasicBlock) (unwind : UnwindAction) (ibr : Insn) : Bool :=
  match brImmForm op, oa.local?, od.local? with
  | some (o, pol), some a, some c' =>
    match Γ.body.locals[c]?, Γ.body.locals[a]? with
    | some .bool, some ta =>
      match cmpOpnd ta with
      | some (n, sg) =>
        match Γ.slots[c]?, Γ.slots[a]? with
        | some sc, some sa =>
          match brCmpImmOps Γ.toStmtCtx ibr n sg with
          | some (o', x, y, neg, t) =>
            c' == c && (cmpConstTy tc ta && (o' == o && (sc.size == 1 && (sa.size == n &&
              (offOk sa.off && (privOk Γ.toStmtCtx sc.off sc.size && (x == sa.off &&
              (y % 2 ^ (8 * n) == bits % 2 ^ (8 * n) &&
              fusedAssertTail Γ c pol neg t od expected msg target unwind))))))))
          | none => false
        | _, _ => false
      | none => false
    | _, _ => false
  | _, _, _ => false

theorem fusedAssertImmOk_sound {Γ : TermCtx} {next : Nat} {c : Local} {op : BinOp}
    {oa : Operand} {bits : Nat} {tc : Spec.Ty} {od : Operand} {expected : Bool}
    {msg : AssertMessage} {target : BasicBlock} {unwind : UnwindAction} {ibr : Insn}
    {tl : List Insn}
    (h : fusedAssertImmOk Γ c op oa bits tc od expected msg target unwind ibr = true) :
    LowerFusedAssert Γ next (.assign ⟨c, []⟩ (.binaryOp op oa (.const (.scalar bits) tc)))
      (.assert od expected msg target unwind) (ibr :: tl) := by
  unfold fusedAssertImmOk at h
  split at h
  next o pol a c' hf ha hd =>
    split at h
    next ta htc hta =>
      split at h
      next n sg hty =>
        split at h
        next sc sa hsc hsa =>
          split at h
          next o' x y neg t hbr =>
            simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
            obtain ⟨hc', hct, ho, h1, h2, h3, hp, hx, hy, htl⟩ := h
            subst hc' ho
            obtain ⟨hneg, ht, hdead, hargs⟩ := fusedAssertTail_spec htl
            exact .mk (.imm hf ha htc hta hct hty hsc hsa ⟨h1, h2⟩ h3 (privOk_spec hp) hbr hx
              hy) hd hneg ht hdead hargs
          next => cases h
        next => cases h
      next => cases h
    next => cases h
  next => cases h

/-- A fused block's last statement and its `Assert` against the terminator range (for
`checkFused`'s `assert` bucket). -/
def checkFusedAssert (Γ : TermCtx) (st : Statement) (term : Terminator) (is : List Insn) :
    Verdict :=
  match st, term, is with
  | .assign ⟨c, []⟩ (.binaryOp op oa (.const (.scalar bits) tc)),
      .assert od expected msg target unwind, ibr :: _ =>
    if fusedOpndOk Γ.toStmtCtx oa then
      okIf (fusedAssertImmOk Γ c op oa bits tc od expected msg target unwind ibr)
        "fused: assert imm, form"
    else .unsupported "fused: operand"
  | .assign ⟨c, []⟩ (.binaryOp op oa ob), .assert od expected msg target unwind, ibr :: _ =>
    if fusedOpndOk Γ.toStmtCtx oa then
      okIf (fusedAssertRegOk Γ c op oa ob od expected msg target unwind ibr)
        "fused: assert, form"
    else okIf (fusedAssertRegUOk Γ c op oa ob od expected msg target unwind ibr)
      "fused: operand"
  | _, _, _ => .unsupported "fused: assert, other"

theorem checkFusedAssert_sound {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (h : checkFusedAssert Γ st term is = .ok) :
    LowerFusedAssert Γ next st term is := by
  unfold checkFusedAssert at h
  split at h
  · split at h
    · exact fusedAssertImmOk_sound (okIf_ok h)
    · cases h
  · split at h
    · exact fusedAssertRegOk_sound (okIf_ok h)
    · exact fusedAssertRegUOk_sound (okIf_ok h)
  · cases h

/-- A fused block's last statement `st` and terminator `term` against the terminator range
`is` ending at `next` (see the module comment for the buckets). -/
def checkFused (Γ : TermCtx) (next : Nat) (st : Statement) (term : Terminator)
    (is : List Insn) : Verdict :=
  match st, term, is with
  | .assign ⟨c, []⟩ (.binaryOp op oa (.const (.scalar bits) tc)),
      .switchInt od [(v, bb)] otherwise, ibr :: tl =>
    if fusedOpndOk Γ.toStmtCtx oa then
      okIf (fusedImmOk Γ next c op oa bits tc od v bb otherwise ibr tl) "fused: compare imm, form"
    else .unsupported "fused: operand"
  | .assign ⟨c, []⟩ (.binaryOp op oa ob), .switchInt od [(v, bb)] otherwise, ibr :: tl =>
    if fusedOpndOk Γ.toStmtCtx oa then
      okIf (fusedRegOk Γ next c op oa ob od v bb otherwise ibr tl) "fused: compare, form"
    else okIf (fusedRegUOk Γ next c op oa ob od v bb otherwise ibr tl) "fused: operand"
  | .assign p (.discriminant q), term', is' =>
    match checkNicheFused Γ next (.assign p (.discriminant q)) term' is' with
    | .ok => .ok
    | v => if checkNicheDense Γ (.assign p (.discriminant q)) term' is' = .ok then .ok else v
  | st', .assert od expected msg target unwind, is' =>
    checkFusedAssert Γ st' (.assert od expected msg target unwind) is'
  | _, _, _ => .unsupported "fused: other"

theorem checkFused_sound {Γ : TermCtx} {next : Nat} {st : Statement} {term : Terminator}
    {is : List Insn} (h : checkFused Γ next st term is = .ok) : LowerFused Γ next st term is := by
  unfold checkFused at h
  split at h
  · split at h
    · exact fusedImmOk_sound (okIf_ok h)
    · cases h
  · split at h
    · exact fusedRegOk_sound (okIf_ok h)
    · exact fusedRegUOk_sound (okIf_ok h)
  · split at h
    · exact .niche (checkNicheFused_sound (by assumption))
    · split at h
      · exact .nicheDense (checkNicheDense_sound (by assumption))
      · exact absurd h (by assumption)
  · exact .assert (checkFusedAssert_sound h)
  · cases h

/-- A fused block: its last statement (index `k`, the number of statement ranges) and the
terminator lowered together over the terminator's range (`Fn.lean`'s `BlockOk` for a block
with `blk.fused`). -/
def FusedBlock (Γ : TermCtx) (next k : Nat) (stmts : List Statement) (term : Terminator)
    (is : List Insn) : Prop :=
  k + 1 = stmts.length ∧ ∃ st, stmts[k]? = some st ∧ LowerFused Γ next st term is

def checkFusedBlock (Γ : TermCtx) (next k : Nat) (stmts : List Statement) (term : Terminator)
    (is : List Insn) : Verdict :=
  if k + 1 = stmts.length then
    match stmts[k]? with
    | some st => checkFused Γ next st term is
    | none => .rejected "fused: no statement"
  else .rejected "fused: statement count"

theorem checkFusedBlock_sound {Γ : TermCtx} {next k : Nat} {stmts : List Statement}
    {term : Terminator} {is : List Insn} (h : checkFusedBlock Γ next k stmts term is = .ok) :
    FusedBlock Γ next k stmts term is := by
  unfold checkFusedBlock at h
  split at h
  next hk =>
    split at h
    next st hst => exact ⟨hk, st, hst, checkFused_sound h⟩
    next => cases h
  next => cases h

end Ryo.Check.Lower
