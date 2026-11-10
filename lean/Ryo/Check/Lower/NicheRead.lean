/-
Ryo.Check.Lower.NicheRead — the rule of a niche-encoded discriminant read on its own (aot.md §C1,
M5b): `_d = discriminant(_e.f₁.….fₖ)`, an enum in a local or a field of one (`fieldPath`, at
offset `off`) with a `.niche` tag, `_d` a whole integer local, lowered by `FnCx::niche_discr`
(`backend/src/lower/adt.rs`) to plain integer instructions on the tag's bytes (`_e`'s slot at
`off` plus the tag offset), up to three frame temporaries and `_d`'s slot.

The instructions are those of `nicheProg`, op for op the backend's (and `Proofs/NicheDiscr.lean`'s
`nicheDiscr`, whose `nicheDiscr_sound` proves the bit arithmetic), with `tw`/`dw` the tag's and
`_d`'s widths in bytes, `t`/`d` their slots and `b`/`r`/`m` the temporaries:

- one niche variant (`lo = hi`): `cmp_imm b, t, ns` (`!=` when `untagged = lo + 1`, else `==`),
  `b`'s byte cast to `dw` into `d`, then `d += lo'` (`lo'` the smaller one, skipped when 0) when
  `lo` and `untagged` are adjacent, else `neg d; d &= lo ^ untagged; d ^= untagged`;
- otherwise `r = t - ns`, `b = r <=u hi - lo`, `d = r` cast, `d += lo` (skipped when 0),
  `m = b` cast, `neg m`, `d ^= untagged; d &= m; d ^= untagged`.

A cast is a `mov` at equal widths, else an unsigned `cvt` (`zext`/`trunc`). Each instruction is
checked against its op by the family checkers' forms (`NOp.insnOk`): `cmpImmInsnOk`,
`binImmInsnOk`, `binInsnOk`, `unInsnOk`, `movInsnOk`, `cvtUOk`.

`nicheReadOk` checks, besides the instructions: the slots' widths and ranges (`_d` private, the
tag inside `_e`'s slot, `_d` and `_e` distinct locals); the temporaries (`nicheTemps`) in range,
private, meeting no local's slot (`tempApart`) and each other (`rangesApart`); the niche range
`hi - lo` below the tag's modulus (`le.u.imm`'s immediate is not truncated); and that every
variant L0 can decode (the untagged one and those below `lo + (hi - lo) + 1`) has its index as
its discriminant at `_d`'s width (`discrIdxAgree`: the backend computes the index).

The temporaries' offsets are read off the instructions (`nicheTempsOf`); nothing relies on how.
The simulation is `Proofs/Lower/SimNicheRead.lean`.
-/
import Ryo.Check.Lower.Cmp
import Ryo.Check.Lower.Unop
import Ryo.Check.Lower.SwitchStatic
import Ryo.Check.Lower.Field

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- One plain integer instruction of a niche decoding, on frame slots. -/
inductive NOp where
  /-- `d (1 byte) = a o imm` at `n` bytes, unsigned. -/
  | cmpImm (o : String) (n : Nat) (d a : Int) (imm : Nat)
  | binImm (m : String) (n : Nat) (d a : Int) (imm : Nat)
  | bin (m : String) (n : Nat) (d a b : Int)
  | un (m : String) (n : Nat) (d a : Int)
  /-- Unsigned `nx`-byte to `ny`-byte cast. -/
  | cvt (nx ny : Nat) (d s : Int)
  | mov (n : Nat) (d s : Int)

/-- An unsigned `cvt` from `nx` to `ny` bytes on slots `d, s`, falling through. -/
def cvtUOk (Γ : StmtCtx) (i : Insn) (nx ny : Nat) (d s : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, [tx, ty], _⟩ =>
      match OpSem.Ty.parse tx, OpSem.Ty.parse ty with
      | some (.int nx' sx), some (.int ny' _sy) =>
        kd == .cvt && nx' == nx && ny' == ny && sx == false &&
          v.op.info.operands == [⟨"d", .slot⟩, ⟨"s", .slot⟩] &&
          v.ops == [.slot d, .slot s] && v.ctl == some .next
      | _, _ => false
    | _ => false
  | none => false

/-- Instruction `i` is op `op`. -/
def NOp.insnOk (Γ : StmtCtx) (i : Insn) : NOp → Bool
  | .cmpImm o n d a imm => cmpImmInsnOk Γ i o n false d a imm
  | .binImm m n d a imm => binImmInsnOk Γ i m n d a imm
  | .bin m n d a b => binInsnOk Γ i m n d a b
  | .un m n d a => unInsnOk Γ i m n d a
  | .cvt nx ny d s => cvtUOk Γ i nx ny d s
  | .mov n d s => movInsnOk Γ i n d s

/-- The instructions are the ops, one each. -/
def progOk (Γ : StmtCtx) : List Insn → List NOp → Bool
  | [], [] => true
  | i :: is, op :: ops => op.insnOk Γ i && progOk Γ is ops
  | _, _ => false

/-- The backend's `int_cast` without sign: a `mov` at equal widths. -/
def castOp (d s : Int) (nx ny : Nat) : NOp :=
  if nx = ny then .mov nx d s else .cvt nx ny d s

/-- `FnCx::niche_discr`'s instructions (see the module comment). -/
def nicheProg (tw dw untagged lo hi ns : Nat) (t d b r m : Int) : List NOp :=
  if lo = hi then
    let lo' := if untagged = lo + 1 then lo else untagged
    [.cmpImm (if untagged = lo + 1 then "!=" else "==") tw b t ns, castOp d b 1 dw] ++
      (if lo + 1 = untagged ∨ untagged + 1 = lo then
        (if lo' = 0 then [] else [.binImm "wrapping_add" dw d d lo'])
      else
        [.un "wrapping_neg" dw d d, .binImm "&" dw d d (lo ^^^ untagged),
          .binImm "^" dw d d untagged])
  else
    [.binImm "wrapping_sub" tw r t ns, .cmpImm "<=" tw b r (hi - lo), castOp d r tw dw] ++
      (if lo = 0 then [] else [.binImm "wrapping_add" dw d d lo]) ++
      [castOp m b 1 dw, .un "wrapping_neg" dw m m, .binImm "^" dw d d untagged,
        .bin "&" dw d d m, .binImm "^" dw d d untagged]

/-- The temporaries a decoding uses, with their widths. -/
def nicheTemps (tw dw lo hi : Nat) (b r m : Int) : List (Int × Nat) :=
  if lo = hi then [(b, 1)] else [(b, 1), (r, tw), (m, dw)]

/-- Ranges pairwise disjoint. -/
def rangesApart : List (Int × Nat) → Bool
  | [] => true
  | (a, n) :: rest =>
    rest.all (fun p => decide (a + n ≤ p.1) || decide (p.1 + p.2 ≤ a)) && rangesApart rest

/-- Temporaries in range, private, apart from every local's slot and from each other. -/
def tempsOk (Γ : StmtCtx) (l : List (Int × Nat)) : Bool :=
  l.all (fun p => offOk p.1 && privOk Γ p.1 p.2 && tempApart Γ.slots p.1 p.2) && rangesApart l

/-- Every variant L0 can decode has its index as its discriminant at `t` (see the module
comment). -/
def discrIdxAgree (vs : List Variant) (discrTy t : IntType) (untagged lo hi : Nat) : Bool :=
  (untagged :: List.range (lo + (hi - lo) + 1)).all fun idx =>
    t.toBits (t.bringInBounds (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))) %
        2 ^ (8 * t.size) == idx % 2 ^ (8 * t.size)

/-- The rule's conditions beyond the types (see the module comment). -/
def nicheReadOk (Γ : StmtCtx) (dl e : Local) (off : Nat) (vs : List Variant)
    (discrTy : IntType) (tag : TagInfo) (t : IntType) (sd se : LocalSlot)
    (untagged lo hi ns : Nat) (b r m : Int) (is : List Insn) : Bool :=
  dl != e && sd.size == t.size && decide (0 < t.size) && decide (0 < tag.tag.size) &&
    decide (off + tag.offset + tag.tag.size ≤ se.size) && offOk sd.off && offOk se.off &&
    offOk (se.off + ((off + tag.offset : Nat) : Int)) && decide (off + tag.offset < 2 ^ 64) &&
    privOk Γ sd.off sd.size &&
    tempsOk Γ (nicheTemps tag.tag.size t.size lo hi b r m) &&
    decide (hi - lo < tag.tag.modulus) && discrIdxAgree vs discrTy t untagged lo hi &&
    progOk Γ is (nicheProg tag.tag.size t.size untagged lo hi ns
      (se.off + ((off + tag.offset : Nat) : Int)) sd.off b r m)

inductive LowerNicheRead (Γ : StmtCtx) : Statement → List Insn → Prop where
  | mk (dl e : Local) (projs : List ProjElem) (ta : Ty) (off : Nat) (vs : List Variant)
      (discrTy : IntType) (tag : TagInfo) (esz : Size)
      (eal : Align) (t : IntType) (vd : ValidRange) (sd se : LocalSlot)
      (untagged lo hi ns : Nat) (b r m : Int) (is : List Insn)
      (hta : Γ.body.locals[e]? = some ta)
      (htd : Γ.body.locals[dl]? = some (.int t vd))
      (hsd : Γ.slots[dl]? = some sd) (hse : Γ.slots[e]? = some se)
      (hpath : fieldPath ta projs = some (off, .enum vs discrTy (.multiple tag) esz eal))
      (henc : tag.encoding = .niche untagged lo hi ns)
      (hok : nicheReadOk Γ dl e off vs discrTy tag t sd se untagged lo hi ns b r m is = true) :
      LowerNicheRead Γ (.assign ⟨dl, []⟩ (.discriminant ⟨e, projs⟩)) is

/-- The first slot operand of an instruction (its destination). -/
def dstSlot (Γ : StmtCtx) (i : Insn) : Option Int :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.ops with
    | .slot d :: _ => some d
    | _ => none
  | none => none

/-- The temporaries `b`, `r`, `m`, read off the destinations of `nicheProg`'s positions. -/
def nicheTempsOf (Γ : StmtCtx) (is : List Insn) (lo hi : Nat) : Int × Int × Int :=
  let at_ (k : Nat) : Int := (is[k]?.bind (dstSlot Γ)).getD 0
  if lo = hi then (at_ 0, at_ 0, at_ 0)
  else (at_ 1, at_ 0, at_ (if lo = 0 then 3 else 4))

/-- `_d = discriminant(_e)` at a niche-encoded tag; `none` for other statements. -/
def checkNicheRead (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨dl, []⟩ (.discriminant ⟨e, projs⟩) =>
    match Γ.body.locals[e]?, Γ.body.locals[dl]?, Γ.slots[dl]?, Γ.slots[e]? with
    | some ta, some (.int t vd), some sd, some se =>
      match fieldPath ta projs with
      | some (off, .enum vs discrTy (.multiple tag) esz eal) =>
        match tag.encoding with
        | .niche untagged lo hi ns =>
          some (okIf (nicheReadOk Γ dl e off vs discrTy tag t sd se untagged lo hi ns
              (nicheTempsOf Γ is lo hi).1 (nicheTempsOf Γ is lo hi).2.1
              (nicheTempsOf Γ is lo hi).2.2 is)
            "discriminant: niche encoding, form")
        | .direct => none
      | _ => none
    | _, _, _, _ => none
  | _ => none

theorem checkNicheRead_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkNicheRead Γ st is = some .ok) : LowerNicheRead Γ st is := by
  unfold checkNicheRead at h
  split at h
  next dl e projs =>
    split at h
    next ta t vd sd se hta htd hsd hse =>
      split at h
      next off vs discrTy tag esz eal hpath =>
        split at h
        next untagged lo hi ns henc =>
          simp only [Option.some.injEq] at h
          exact .mk dl e projs ta off vs discrTy tag esz eal t vd sd se untagged lo hi ns _ _ _
            is hta htd hsd hse hpath henc (okIf_ok h)
        next => cases h
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
