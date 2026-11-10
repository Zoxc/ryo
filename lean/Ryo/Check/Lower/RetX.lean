/-
Ryo.Check.Lower.RetX — `return`'s rules extended to every register return (aot.md §C1, M5b),
next to `Term.lean`'s `ret` rule (return kind 0, or an integer `_0` in one general-purpose
register).

`LowerRetX Γ .return is`: the R instructions `is` (the block's terminator range) are a lowering
of `return`. Rules mirror `FnCx::ret` (`backend/src/lower/call.rs`):

- `zero`: return kind `0` (`ret [_, 0]`), as `retOk`.
- `reg`: `ret [_0's slot, k]` with `k` the function's return kind (`FuncCert.retKind`) and its
  register parts (`Asm.retParts k true`, at most two: `rax`/`rdx` for integer parts, `xmm0`/
  `xmm1` for float parts) all inside `_0`'s slot, which has the size of `_0`'s type. This is
  type-agnostic: `ret` copies bytes (each part's `size` bytes at `src + off`, zero-extended to
  the register), so it covers `bool`, `char`, thin pointers, enums, small structs and tuples
  (`Direct`, `Cast`), scalar pairs in `rax:rdx` (`Pair`, a `Direct` `i128`) and floats in `xmm`
  alike. What the caller may read is the bytes of `_0` (`RetValX`, `SimRetX.lean`).

Not covered (`checkRetX`'s buckets): sret (`store.copy` through the sret pointer, then `ret`
of the pointer: two instructions), C `signext` returns (a widening into a temporary first: two
instructions), and an integer part of 3, 5, 6 or 7 bytes, which `ret` loads at the next power
of two (`load_kind`), past `_0`'s slot (the instruction's word then differs from the
function's return kind).
-/
import Ryo.Check.Lower.Term

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The register parts of return kind `k` as `ret` loads them (`Asm.retParts k true`), in order. -/
def retPartList (k : Nat) : Option (List Asm.RetPart) :=
  (Asm.retParts k true).map fun ab => [ab.1, ab.2].filterMap id

inductive LowerRetX (Γ : TermCtx) : Terminator → List Insn → Prop where
  | zero {i : Insn} {src : Int} {k : Nat} (hro : retOps i = some (src, k)) (hk : k = Γ.retKind)
      (h0 : k = 0) : LowerRetX Γ .«return» [i]
  | reg {i : Insn} {src : Int} {k : Nat} {ty : Ty} {s0 : LocalSlot} {ps : List Asm.RetPart}
      (hro : retOps i = some (src, k)) (hk : k = Γ.retKind)
      (hty : Γ.body.locals[0]? = some ty) (hsl : Γ.slots[0]? = some s0)
      (hsize : ty.size? = some s0.size) (hoff : s0.off = src)
      (hps : retPartList k = some ps) (hfit : ∀ p ∈ ps, p.off + p.size ≤ s0.size) :
      LowerRetX Γ .«return» [i]

/-- `ret`'s extended rule on one instruction. -/
def retXOk (Γ : TermCtx) (i : Insn) : Bool :=
  match retOps i with
  | some (src, k) =>
    k == Γ.retKind &&
      (k == 0 ||
        match Γ.body.locals[0]?, Γ.slots[0]?, retPartList k with
        | some ty, some s0, some ps =>
          ty.size? == some s0.size && s0.off == src &&
            ps.all (fun p => decide (p.off + p.size ≤ s0.size))
        | _, _, _ => false)
  | none => false

theorem retXOk_sound {Γ : TermCtx} {i : Insn} (h : retXOk Γ i = true) :
    LowerRetX Γ .«return» [i] := by
  unfold retXOk at h
  split at h
  next src k hro =>
    simp only [Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true] at h
    obtain ⟨hk, h2⟩ := h
    rcases h2 with h2 | h2
    · exact .zero hro hk h2
    · split at h2
      next ty s0 ps hty hsl hps =>
        simp only [Bool.and_eq_true, beq_iff_eq, List.all_eq_true, decide_eq_true_eq] at h2
        obtain ⟨⟨h3, h4⟩, h5⟩ := h2
        exact .reg hro hk hty hsl h3 h4 hps h5
      next => cases h2
  next => cases h

/-- Why `retXOk` fails, for coverage. -/
def retXWhy (Γ : TermCtx) (i : Insn) : String :=
  match retOps i with
  | none => "return: form"
  | some (src, k) =>
    if k != Γ.retKind then "return: load wider than _0"
    else
      match Γ.body.locals[0]?, Γ.slots[0]?, retPartList k with
      | some ty, some s0, some ps =>
        if ty.size? != some s0.size then "return: _0 slot size"
        else if s0.off != src then "return: source slot"
        else if !ps.all (fun p => decide (p.off + p.size ≤ s0.size)) then
          "return: part outside _0"
        else "return: form"
      | _, _, none => "return: kind"
      | _, _, _ => "return: _0"

/-- `return`'s checker: `none` for other terminators. -/
def checkRetX (Γ : TermCtx) (term : Terminator) (is : List Insn) : Option Verdict :=
  match term, is with
  | .«return», [i] => some (if retXOk Γ i then .ok else .unsupported (retXWhy Γ i))
  | .«return», is =>
    some (.unsupported
      (if Γ.retKind == Ryo.Check.Image.RET_SRET then "return: sret"
       else if is.length == 2 then "return: C signext"
       else "return: instruction count"))
  | _, _ => none

theorem checkRetX_sound {Γ : TermCtx} {term : Terminator} {is : List Insn}
    (h : checkRetX Γ term is = some .ok) : LowerRetX Γ term is := by
  unfold checkRetX at h
  split at h
  next i =>
    have h' := Option.some.inj h
    split at h'
    next hok => exact retXOk_sound hok
    next => cases h'
  next => cases Option.some.inj h
  next => cases h

end Ryo.Check.Lower
