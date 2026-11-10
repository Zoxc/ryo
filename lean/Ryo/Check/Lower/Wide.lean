/-
Ryo.Check.Lower.Wide — statement rules for wide pointers (aot.md §C1, M5b) and their
checker.

Wide pointers (`LowerWide`), each into a whole local `_d` whose slot no `Escape` covers, from a
whole local `_a` (`copy`/`move`, `Operand.local?`), lowered to one `mov` (`movInsnOk`):
- `metaLen`: `_d = PtrMetadata(_a)` for `_a` a slice-like pointer (`metaKind = .elementCount`)
  and `_d : usize`, lowered to a `mov` of 8 bytes from `_a`'s slot at offset 8 (the backend's
  `fx.mov(d, s + META, PTR)`, `binop.rs` `unary_op`). L0 decodes the 16 bytes at `_a`'s type
  (the length is `decodeBits` of the last 8) and stores the length's encoding, which is below
  those 8 bytes (a sub-range read, as `Field.lean`'s). The thin case (`()`, no instruction) and
  the vtable case (`dyn` metadata) are not covered.
- `wideCast`: `_d = cast k _a ty` for a cast keeping the pointer value (`wideKeepKind`:
  `ptrToPtr`, `fnPtrToPtr`, `mutToConstPointer`, `unsafeFnPointer`) between wide pointers whose
  metadata kinds encode alike (`sameMetaShape`: both lengths or both vtables, whatever the
  trait), `ty` `_d`'s type, `_a`'s type well-formed, lowered to one `mov` of 16 bytes
  (`operand_into`, `cast.rs`). L0's value is `_a`'s decoded pointer, metadata included, and its
  encoding at `_d`'s type is its encoding at `_a`'s, below the loaded bytes
  (`encode_decode_le`).
- `wideToThin`: `_d = cast k _a ty` for `k` `ptrToPtr`/`fnPtrToPtr` from a wide to a thin
  pointer (`ty` `_d`'s type), lowered to one `mov` of 8 bytes from `_a`'s slot (the data
  pointer; `cast.rs`: "Wide to thin: drop the metadata"). L0 keeps the thin part (D35), whose
  encoding is below the first 8 loaded bytes.
Unsizing (`[T; n]` → `[T]`: a `mov` and an `imm`; `T` → `dyn Trait`: a `mov` and the vtable's
address) takes two instructions and is left to the multi-instruction rules.

`checkWide` claims every `PtrMetadata` into a whole local and every pointer cast
(`ptrCastKind`) of a whole local with a wide source or destination, and is `none` otherwise.

Pool constants (a global's address, `addr.const`; a copy of a pool constant, `const`) are not
covered: their simulation needs an invariant relating L0's copies of globals to R's constant
pool (see `Ryo/Proofs/Lower/SimWide.lean`).
-/
import Ryo.Check.Lower.Copy

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-! ### Wide pointers -/

/-- Two wide metadata kinds `Ty.encode` treats alike (it looks only at the kind, not at the
trait of a vtable). -/
def sameMetaShape : PointerMetaKind → PointerMetaKind → Bool
  | .elementCount, .elementCount => true
  | .vtablePointer _, .vtablePointer _ => true
  | _, _ => false

/-- The casts L0 evaluates to the operand's pointer itself when the target is wide. -/
def wideKeepKind : CastKind → Bool
  | .ptrToPtr | .fnPtrToPtr | .pointerCoercion .mutToConstPointer
  | .pointerCoercion .unsafeFnPointer => true
  | _ => false

/-- The casts L0 evaluates to the operand's thin part when the target is thin. -/
def wideThinKind : CastKind → Bool
  | .ptrToPtr | .fnPtrToPtr => true
  | _ => false

/-- A local's type is a wide pointer. -/
def isWidePtr : Option Ty → Bool
  | some (.ptr p _) => p.metaKind != .none
  | _ => false

inductive LowerWide (Γ : StmtCtx) : Statement → List Insn → Prop where
  | metaLen {d a : Local} {oa : Operand} {pta : PtrType} {va : ValidRange} {t : IntType}
      {vd : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (ha : oa.local? = some a) (hka : pta.metaKind = .elementCount)
      (hta : Γ.body.locals[a]? = some (.ptr pta va))
      (htd : Γ.body.locals[d]? = some (.int t vd)) (ht : t = ⟨false, 8⟩)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 8 ∧ (8 : Nat) + 8 ≤ sa.size)
      (hoff : offOk sd.off ∧ offOk (sa.off + (8 : Nat)))
      (hi : movInsnOk Γ i 8 sd.off (sa.off + (8 : Nat)) = true) :
      LowerWide Γ (.assign ⟨d, []⟩ (.unaryOp .ptrMetadata oa)) [i]
  | wideCast {d a : Local} {oa : Operand} {k : CastKind} {ty : Ty} {ptd pta : PtrType}
      {vd va : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hk : wideKeepKind k = true) (ha : oa.local? = some a)
      (hka : pta.metaKind ≠ .none) (hshape : sameMetaShape ptd.metaKind pta.metaKind = true)
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd)) (hty : ty = .ptr ptd vd)
      (hta : Γ.body.locals[a]? = some (.ptr pta va)) (hwf : (Ty.ptr pta va).wf = true)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 16 ∧ sa.size = 16)
      (hoff : offOk sd.off ∧ offOk sa.off)
      (hi : movInsnOk Γ i 16 sd.off sa.off = true) :
      LowerWide Γ (.assign ⟨d, []⟩ (.cast k oa ty)) [i]
  | wideToThin {d a : Local} {oa : Operand} {k : CastKind} {ty : Ty} {ptd pta : PtrType}
      {vd va : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hk : wideThinKind k = true) (ha : oa.local? = some a)
      (hka : pta.metaKind ≠ .none) (hkd : ptd.metaKind = .none)
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd)) (hty : ty = .ptr ptd vd)
      (hta : Γ.body.locals[a]? = some (.ptr pta va))
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 8 ∧ (0 : Nat) + 8 ≤ sa.size)
      (hoff : offOk sd.off ∧ offOk (sa.off + (0 : Nat)))
      (hi : movInsnOk Γ i 8 sd.off (sa.off + (0 : Nat)) = true) :
      LowerWide Γ (.assign ⟨d, []⟩ (.cast k oa ty)) [i]

/-- The slots and the instruction of a `mov` of `n` bytes from `_a`'s slot at `off` to `_d`;
`rule` prefixes the reasons. -/
def checkMovSub (Γ : StmtCtx) (rule : String) (d a : Local) (off n : Nat) (is : List Insn) :
    Verdict :=
  match Γ.slots[d]?, Γ.slots[a]?, is with
  | some sd, some sa, [i] =>
    if !(sd.size == n && decide (off + n ≤ sa.size)) then .rejected s!"{rule}: slot sizes"
    else if !(offOk sd.off && offOk (sa.off + off)) then .rejected s!"{rule}: offsets"
    else if movInsnOk Γ i n sd.off (sa.off + off) then .ok
    else .unsupported s!"{rule}: instruction form"
  | _, _, _ => .unsupported s!"{rule}: slots or instruction count"

theorem checkMovSub_ok {Γ : StmtCtx} {rule : String} {d a : Local} {off n : Nat}
    {is : List Insn} (h : checkMovSub Γ rule d a off n is = .ok) :
    ∃ i sd sa, is = [i] ∧ Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧
      (sd.size = n ∧ off + n ≤ sa.size) ∧ (offOk sd.off ∧ offOk (sa.off + off)) ∧
      movInsnOk Γ i n sd.off (sa.off + off) = true := by
  unfold checkMovSub at h
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
          exact ⟨i, sd, sa, rfl, hsd, hsa, by simpa using hsz, by simpa using hoff, hi⟩
        · cases h
  · cases h

/-- `metaLen`'s checker: `_d = PtrMetadata(oa)`. -/
def checkMeta (Γ : StmtCtx) (d : Local) (oa : Operand) (is : List Insn) : Verdict :=
  match oa.local? with
  | none => .unsupported "ptr metadata: operand not a whole local"
  | some a =>
    match Γ.body.locals[a]? with
    | some (.ptr pta _) =>
      match pta.metaKind with
      | .elementCount =>
        match Γ.body.locals[d]? with
        | some (.int t _) =>
          if t = ⟨false, 8⟩ then checkMovSub Γ "ptr metadata" d a 8 8 is
          else .rejected "ptr metadata: destination type"
        | _ => .rejected "ptr metadata: destination type"
      | .none => .unsupported "ptr metadata: thin pointer"
      | .vtablePointer _ => .unsupported "ptr metadata: vtable"
    | _ => .unsupported "ptr metadata: not a pointer"

/-- The checker of the wide pointer casts: `_d = cast k _a ty`, one of the two wide. -/
def checkWideCast (Γ : StmtCtx) (d a : Local) (k : CastKind) (ty : Ty) (is : List Insn) :
    Verdict :=
  match Γ.body.locals[d]?, Γ.body.locals[a]? with
  | some (.ptr ptd vd), some (.ptr pta va) =>
    if ty = .ptr ptd vd then
      if pta.metaKind = .none then .unsupported "wide cast: thin to wide"
      else if ptd.metaKind = .none then
        if wideThinKind k then checkMovSub Γ "wide to thin" d a 0 8 is
        else .unsupported "wide to thin: cast kind"
      else if !wideKeepKind k then .unsupported "wide cast: cast kind"
      else if !sameMetaShape ptd.metaKind pta.metaKind then
        .unsupported "wide cast: metadata kinds"
      else if !(Ty.ptr pta va).wf then .rejected "wide cast: ill-formed type"
      else checkMovAny Γ "wide cast" d a 16 is
    else .unsupported "wide cast: destination type"
  | _, _ => .unsupported "wide cast: not pointers"

/-- The family's checker: `none` unless the statement is `PtrMetadata` into a whole local or a
pointer cast of a whole local with a wide source or destination (thin ones are
`Copy.lean`'s `ptrCast`). -/
def checkWide (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.unaryOp .ptrMetadata oa) => some (checkMeta Γ d oa is)
  | .assign ⟨d, []⟩ (.cast k oa ty) =>
    match oa.local? with
    | some a =>
      if ptrCastKind k && (isWidePtr Γ.body.locals[d]? || isWidePtr Γ.body.locals[a]?) then
        some (checkWideCast Γ d a k ty is)
      else none
    | none => none
  | _ => none

theorem checkMeta_sound {Γ : StmtCtx} {d : Local} {oa : Operand} {is : List Insn}
    (h : checkMeta Γ d oa is = .ok) :
    LowerWide Γ (.assign ⟨d, []⟩ (.unaryOp .ptrMetadata oa)) is := by
  unfold checkMeta at h
  split at h
  · cases h
  next a ha =>
    split at h
    next pta va hta =>
      split at h
      next hka =>
        split at h
        next t vd htd =>
          split at h
          next ht =>
            obtain ⟨i, sd, sa, rfl, hsd, hsa, hsz, hoff, hi⟩ := checkMovSub_ok h
            exact .metaLen ha hka hta htd ht hsd hsa hsz hoff hi
          · cases h
        · cases h
      · cases h
      · cases h
    · cases h

theorem checkWideCast_sound {Γ : StmtCtx} {d a : Local} {oa : Operand} {k : CastKind} {ty : Ty}
    {is : List Insn} (ha : oa.local? = some a) (h : checkWideCast Γ d a k ty is = .ok) :
    LowerWide Γ (.assign ⟨d, []⟩ (.cast k oa ty)) is := by
  unfold checkWideCast at h
  split at h
  next ptd vd pta va htd hta =>
    split at h
    next hty =>
      split at h
      · cases h
      next hka =>
        split at h
        next hkd =>
          split at h
          next hk =>
            obtain ⟨i, sd, sa, rfl, hsd, hsa, hsz, hoff, hi⟩ := checkMovSub_ok h
            exact .wideToThin hk ha hka hkd htd hty hta hsd hsa hsz hoff hi
          · cases h
        next hkd =>
          split at h
          · cases h
          next hk =>
            split at h
            · cases h
            next hsh =>
              split at h
              · cases h
              next hwf =>
                obtain ⟨i, sd, sa, rfl, hsd, hsa, hsz, hoff, hi, -⟩ := checkMovAny_ok h
                exact .wideCast (by simpa using hk) ha hka (by simpa using hsh) htd hty hta
                  (by simpa using hwf) hsd hsa hsz hoff hi
    · cases h
  · cases h

theorem checkWide_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkWide Γ st is = some .ok) : LowerWide Γ st is := by
  unfold checkWide at h
  split at h
  next d oa => exact checkMeta_sound (Option.some.inj h)
  next d k oa ty =>
    split at h
    next a ha =>
      split at h
      next => exact checkWideCast_sound ha (Option.some.inj h)
      next => cases h
    next => cases h
  next => cases h

end Ryo.Check.Lower
