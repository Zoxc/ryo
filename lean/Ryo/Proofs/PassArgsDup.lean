/-
Ryo.Proofs.PassArgsDup — how the Win64 duplicate words of a C-variadic call decode.

`win64Dups` (`Proofs/PassArgsConv.lean`) gives each `xmm` piece of a variadic input a second
entry, the word `(ArgReg.mk false (roundPow2 (max size 4)) index false).word`: Win64 passes a
variadic `xmm_i` argument also in the `i`-th integer argument register. Its size is 4 or 8
(`roundPow2_max4`), and for indices below 4 `ArgReg.of?` decodes the word back to that integer
register, in call lists and as an `arg`'s register alike (`of?_dupWord`). With
`argPlan_reg` (Win64 `xmm` pieces are `xmm0`-`xmm3`) every duplicate of an `argPlan` plan
decodes to the integer register of its `xmm` piece's position, `rcx rdx r8 r9`, never `rax`
(`win64Dup_of?`).
-/
import Ryo.Proofs.PassArgsConv

namespace Ryo.Proofs.PassArgsDup

open Ryo.Spec Ryo.Vm.Asm Ryo.Check.Lower Ryo.Proofs.Call Ryo.Proofs.PassArgsConv

/-- A duplicate's size, `max size 4` rounded to a power of two, is 4 or 8. -/
theorem roundPow2_max4 (s : Nat) : roundPow2 (max s 4) = 4 ∨ roundPow2 (max s 4) = 8 := by
  have h1 : ¬ max s 4 ≤ 1 := by omega
  have h2 : ¬ max s 4 ≤ 2 := by omega
  rw [roundPow2, ite_eq_right h1, ite_eq_right h2]
  split
  · exact Or.inl rfl
  · exact Or.inr rfl

/-- A 4- or 8-byte integer register word of index below 4 decodes to itself. -/
theorem of?_gprWord {sz i : Nat} (hs : sz = 4 ∨ sz = 8) (hi : i < 4) (e : Bool) :
    ArgReg.of? (ArgReg.mk false sz i false).word e = some (ArgReg.mk false sz i false) := by
  obtain rfl | rfl := hs <;> obtain _ | _ | _ | _ | i := i <;>
    first | omega | (cases e <;> rfl)

/-- A duplicate word of index below 4 decodes to the integer register of that index. -/
theorem of?_dupWord (s : Nat) {i : Nat} (hi : i < 4) (e : Bool) :
    ArgReg.of? (ArgReg.mk false (roundPow2 (max s 4)) i false).word e =
      some (ArgReg.mk false (roundPow2 (max s 4)) i false) :=
  of?_gprWord (roundPow2_max4 s) hi e

/-- Every Win64 duplicate of an `argPlan` plan: input `i`'s `xmm` piece `r` (`xmm0`-`xmm3`),
from its home, whose word decodes to the 4- or 8-byte, zero-extended integer register of the
same index: the handler-call register `intArg true r.index` (`rcx rdx r8 r9`), not `rax`. -/
theorem win64Dup_of? {abi : FnAbiSummary} {sret c : Bool} {plan : ArgPlan} {fixed : Nat}
    (hp : argPlan true abi sret c = .ok plan) {e : SlotReq × Nat}
    (he : e ∈ win64Dups plan fixed) (ex : Bool) :
    ∃ i ls r off, fixed ≤ i ∧ i < plan.locs.length ∧ plan.locs[i]? = some ls ∧
      ArgLoc.reg r off ∈ ls ∧ r.xmm = true ∧ r.index < 4 ∧ e.1 = .home i off ∧
      ArgReg.of? e.2 ex = some (ArgReg.mk false (roundPow2 (max r.size 4)) r.index false) ∧
      (roundPow2 (max r.size 4) = 4 ∨ roundPow2 (max r.size 4) = 8) ∧
      handlerReg true r.index = some (intArg true r.index) ∧ intArg true r.index ≠ .rax := by
  obtain ⟨i, ls, r, off, hf, hlt, hget, hmem, hx, rfl⟩ := mem_win64Dups he
  have hls : ls ∈ plan.locs := List.mem_of_getElem? hget
  have hb : r.index < regBound true true := (argPlan_reg hp hls hmem).2 hx
  have h4 : r.index < 4 := hb
  have h4' : r.index < regBound true false := h4
  exact ⟨i, ls, r, off, hf, hlt, hget, hmem, hx, h4, rfl, of?_dupWord r.size h4 ex,
    roundPow2_max4 r.size, intArg_handlerReg h4', intArg_ne_rax h4'⟩

end Ryo.Proofs.PassArgsDup
