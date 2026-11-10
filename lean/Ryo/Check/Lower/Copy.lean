/-
Ryo.Check.Lower.Copy — statement rules for whole-local copies and bit-preserving casts lowered
to one `mov` (aot.md §C1, M5b).

Every rule moves a whole local `_a` (`copy`/`move`, `Operand.local?`) into a whole local `_d`
(private or escaped), with one `mov` handler instruction (`movInsnOk`) of `n` bytes
between the slots, `n` the size of both types and both slots. `mov` exists at 1, 2, 4, 8 and
16 bytes (`mov.w8` .. `mov.w128`, handler types `u8` .. `u128`; `movWidth`); other sizes are
split by the backend (`operand.rs` `mov`) into several instructions, which these rules do not
cover. R copies the bytes it reads, provenance included, while L0 stores the re-encoding of the
value it decoded; each rule's simulation (`Ryo/Proofs/Lower/SimCopy.lean`) shows the stored
bytes are less defined than the loaded ones (`bytesLeDefined`), which is what the memory
relation needs.

Rules:
- `copyAny`: `_d = _a` at one well-formed sized type `ty` of any kind (generalizes `copyInt`,
  `copyBool`, `copyPtr` of `Stmt.lean`, which stay): re-encoding a decoded value is less
  defined than the bytes (`Ryo.Spec.Theorems.encode_decode_le`, which needs `ty.wf`).
- `bitCast`: `_d = cast k _a ty` for `k` a transmute (`transmute`, `boxDerefTransmute`,
  `subtype`; L0 `transmute`: encode at the source type, decode at `ty`), `ty` `_d`'s type,
  both types well-formed of `n` bytes: two re-encodings, each less defined.
- `ptrCast`: `_d = cast k _a ty` for `k` a pointer cast keeping the thin pointer (`ptrToPtr`,
  `fnPtrToPtr`, the `mutToConstPointer`, `unsafeFnPointer`, `arrayToPointer` coercions; fn
  pointers are `.ptr .fnPtr _`), `_a` and `_d` thin pointers (`metaKind = .none`), `n = 8`:
  L0's value is `_a`'s pointer without metadata, whatever `ty` is (if it is a pointer type at
  all), and its encoding at `_d`'s thin pointer type is the source's `encodePtr` (pointer
  encoding ignores the valid range). The backend lowers these casts with `operand_into` (a
  `mov`), as the transmutes (`cast.rs`).

`checkCopy` is `none` for any other statement (other families handle constants, projected
places and other casts), else the verdict.
-/
import Ryo.Check.Lower.Stmt
import Ryo.Spec.Lang.WellFormed

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The sizes `mov` has a handler for. -/
def movWidth (n : Nat) : Bool := n == 1 || n == 2 || n == 4 || n == 8 || n == 16

theorem movWidth_pos {n : Nat} (h : movWidth n = true) : 0 < n := by
  unfold movWidth at h
  simp only [Bool.or_eq_true, beq_iff_eq] at h
  omega

/-- The casts L0 evaluates by `transmute` (encode at the source type, decode at the target). -/
def bitCastKind : CastKind → Bool
  | .transmute | .boxDerefTransmute | .subtype => true
  | _ => false

/-- The casts that keep a thin pointer as it is. -/
def ptrCastKind : CastKind → Bool
  | .ptrToPtr | .fnPtrToPtr | .pointerCoercion .mutToConstPointer
  | .pointerCoercion .unsafeFnPointer | .pointerCoercion .arrayToPointer => true
  | _ => false

inductive LowerCopy (Γ : StmtCtx) : Statement → List Insn → Prop where
  | copyAny {d a : Local} {oa : Operand} {ty : Ty} {n : Nat} {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some ty) (hta : Γ.body.locals[a]? = some ty)
      (hwf : ty.wf = true) (hn : ty.size? = some n) (hpos : 0 < n)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = n ∧ sa.size = n)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : movInsnOk Γ i n sd.off sa.off = true) :
      LowerCopy Γ (.assign ⟨d, []⟩ (.use oa)) [i]
  | bitCast {d a : Local} {oa : Operand} {k : CastKind} {ty ta : Ty} {n : Nat}
      {sd sa : LocalSlot} {i : Insn}
      (hk : bitCastKind k = true) (ha : oa.local? = some a)
      (htd : Γ.body.locals[d]? = some ty) (hta : Γ.body.locals[a]? = some ta)
      (hwfd : ty.wf = true) (hwfa : ta.wf = true)
      (hnd : ty.size? = some n) (hna : ta.size? = some n) (hpos : 0 < n)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = n ∧ sa.size = n)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : movInsnOk Γ i n sd.off sa.off = true) :
      LowerCopy Γ (.assign ⟨d, []⟩ (.cast k oa ty)) [i]
  | ptrCast {d a : Local} {oa : Operand} {k : CastKind} {ty : Ty} {ptd pta : PtrType}
      {vd va : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hk : ptrCastKind k = true) (ha : oa.local? = some a)
      (hkd : ptd.metaKind = .none) (hka : pta.metaKind = .none)
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd))
      (hta : Γ.body.locals[a]? = some (.ptr pta va))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 8 ∧ sa.size = 8)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : movInsnOk Γ i 8 sd.off sa.off = true) :
      LowerCopy Γ (.assign ⟨d, []⟩ (.cast k oa ty)) [i]

/-- The slots and the instruction of a `mov` of `n` bytes from `_a` to `_d` (private or
escaped: the simulation writes either, `Ryo.Proofs.Lower.FnRel.write_dst`); `rule` prefixes the
reasons. -/
def checkMovAny (Γ : StmtCtx) (rule : String) (d a : Local) (n : Nat) (is : List Insn) :
    Verdict :=
  if !movWidth n then .unsupported s!"{rule}: not a mov width"
  else match Γ.slots[d]?, Γ.slots[a]?, is with
    | some sd, some sa, [i] =>
      if !(sd.size == n && sa.size == n) then .rejected s!"{rule}: slot sizes"
      else if !(offOk sd.off && offOk sa.off) then .rejected s!"{rule}: offsets"
      else if movInsnOk Γ i n sd.off sa.off then .ok
      else .unsupported s!"{rule}: instruction form"
    | _, _, _ => .unsupported s!"{rule}: slots or instruction count"

theorem checkMovAny_ok {Γ : StmtCtx} {rule : String} {d a : Local} {n : Nat} {is : List Insn}
    (h : checkMovAny Γ rule d a n is = .ok) :
    ∃ i sd sa, is = [i] ∧ Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧
      (sd.size = n ∧ sa.size = n) ∧ (offOk sd.off ∧ offOk sa.off) ∧
      movInsnOk Γ i n sd.off sa.off = true ∧ 0 < n := by
  unfold checkMovAny at h
  split at h
  · cases h
  next hw =>
    have hpos : 0 < n := movWidth_pos (by simpa using hw)
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
            exact ⟨i, sd, sa, rfl, hsd, hsa, by simpa using hsz, by simpa using hoff, hi, hpos⟩
          · cases h
    · cases h

/-- `copyAny`'s checker: `_d = _a`. -/
def checkCopyAny (Γ : StmtCtx) (d a : Local) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]?, Γ.body.locals[a]? with
  | some td, some ta =>
    if td != ta then .unsupported "copy any: mixed types"
    else if !td.wf then .unsupported "copy any: ill-formed type"
    else match td.size? with
      | some n => checkMovAny Γ "copy any" d a n is
      | none => .unsupported "copy any: unsized type"
  | _, _ => .unsupported "copy any: locals"

/-- `bitCast`'s checker: `_d = cast k _a ty` for a transmute `k`. -/
def checkBitCast (Γ : StmtCtx) (d a : Local) (ty : Ty) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]?, Γ.body.locals[a]? with
  | some td, some ta =>
    if td != ty then .unsupported "bit cast: destination type"
    else if !(td.wf && ta.wf) then .unsupported "bit cast: ill-formed type"
    else match td.size?, ta.size? with
      | some n, some na =>
        if n != na then .unsupported "bit cast: sizes"
        else checkMovAny Γ "bit cast" d a n is
      | _, _ => .unsupported "bit cast: unsized type"
  | _, _ => .unsupported "bit cast: locals"

/-- `ptrCast`'s checker: `_d = cast k _a ty` for a thin-pointer-keeping `k`. -/
def checkPtrCast (Γ : StmtCtx) (d a : Local) (is : List Insn) : Verdict :=
  match Γ.body.locals[d]?, Γ.body.locals[a]? with
  | some (.ptr ptd _), some (.ptr pta _) =>
    if ptd.metaKind = .none ∧ pta.metaKind = .none then checkMovAny Γ "pointer cast" d a 8 is
    else .unsupported "pointer cast: wide pointer"
  | _, _ => .unsupported "pointer cast: not pointers"

/-- The family's checker: `none` unless the statement is a whole-local copy or a transmute or
thin pointer cast of a whole local into a whole local. -/
def checkCopy (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use oa) =>
    match oa.local? with
    | some a => some (checkCopyAny Γ d a is)
    | none => none
  | .assign ⟨d, []⟩ (.cast k oa ty) =>
    match oa.local? with
    | some a =>
      if bitCastKind k then some (checkBitCast Γ d a ty is)
      else if ptrCastKind k then some (checkPtrCast Γ d a is)
      else none
    | none => none
  | _ => none

theorem checkCopyAny_sound {Γ : StmtCtx} {d a : Local} {oa : Operand} {is : List Insn}
    (ha : oa.local? = some a) (h : checkCopyAny Γ d a is = .ok) :
    LowerCopy Γ (.assign ⟨d, []⟩ (.use oa)) is := by
  unfold checkCopyAny at h
  split at h
  next td ta htd hta =>
    split at h
    · cases h
    next hty =>
      have hty : td = ta := by simpa using hty
      subst hty
      split at h
      · cases h
      next hwf =>
        split at h
        next n hn =>
          obtain ⟨i, sd, sa, rfl, hsd, hsa, hsz, hoff, hi, hpos⟩ := checkMovAny_ok h
          exact .copyAny ha htd hta (by simpa using hwf) hn hpos hsd hsa hsz hoff hi
        · cases h
  · cases h

theorem checkBitCast_sound {Γ : StmtCtx} {d a : Local} {oa : Operand} {k : CastKind} {ty : Ty}
    {is : List Insn} (hk : bitCastKind k = true) (ha : oa.local? = some a)
    (h : checkBitCast Γ d a ty is = .ok) :
    LowerCopy Γ (.assign ⟨d, []⟩ (.cast k oa ty)) is := by
  unfold checkBitCast at h
  split at h
  next td ta htd hta =>
    split at h
    · cases h
    next hty =>
      have hty : td = ty := by simpa using hty
      subst hty
      split at h
      · cases h
      next hwf =>
        have hwf : td.wf = true ∧ ta.wf = true := by simpa using hwf
        split at h
        next n na hnd hna =>
          split at h
          · cases h
          next hne =>
            have hne : n = na := by simpa using hne
            subst hne
            obtain ⟨i, sd, sa, rfl, hsd, hsa, hsz, hoff, hi, hpos⟩ := checkMovAny_ok h
            exact .bitCast hk ha htd hta hwf.1 hwf.2 hnd hna hpos hsd hsa hsz hoff hi
        · cases h
  · cases h

theorem checkPtrCast_sound {Γ : StmtCtx} {d a : Local} {oa : Operand} {k : CastKind} {ty : Ty}
    {is : List Insn} (hk : ptrCastKind k = true) (ha : oa.local? = some a)
    (h : checkPtrCast Γ d a is = .ok) :
    LowerCopy Γ (.assign ⟨d, []⟩ (.cast k oa ty)) is := by
  unfold checkPtrCast at h
  split at h
  next ptd vd pta va htd hta =>
    split at h
    next hc =>
      obtain ⟨i, sd, sa, rfl, hsd, hsa, hsz, hoff, hi, -⟩ := checkMovAny_ok h
      exact .ptrCast hk ha hc.1 hc.2 htd hta hsd hsa hsz hoff hi
    · cases h
  · cases h

theorem checkCopy_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkCopy Γ st is = some .ok) : LowerCopy Γ st is := by
  unfold checkCopy at h
  split at h
  next d oa =>
    split at h
    next a ha => exact checkCopyAny_sound ha (Option.some.inj h)
    · cases h
  next d k oa ty =>
    split at h
    next a ha =>
      split at h
      next hk => exact checkBitCast_sound hk ha (Option.some.inj h)
      next =>
        split at h
        next hk => exact checkPtrCast_sound hk ha (Option.some.inj h)
        · cases h
    · cases h
  · cases h

end Ryo.Check.Lower
