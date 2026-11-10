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

Not covered (`checkFused`'s buckets): fused `Assert`s, niche-discriminant switches
(`Fused::Discr`), `char` and pointer compares, projected operands.
-/
import Ryo.Check.Lower.Cmp
import Ryo.Check.Lower.TermExt
import Ryo.Check.Lower.Live

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
    else .unsupported "fused: operand"
  | .assign _ (.discriminant _), _, _ => .unsupported "fused: niche discriminant"
  | _, .assert .., _ => .unsupported "fused: assert"
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
    · cases h
  · cases h
  · cases h
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
