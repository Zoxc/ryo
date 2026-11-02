/-
Ryo.Proofs.ArgPeBound — the PE bound on `arg` registers (PENDING dbb3619): `argInsn` accepts
only registers with index below 4 on PE, so an accepted `arg`'s register is one of the
convention's (`ArgRet.IsArg`) and its `RegRel` (what `ArgRet.arg_step` asks for) follows from
`ArgsRel`.

- `of?_index`: `ArgReg.of? w true = some a` bounds `a.index` by 8 (`xmm`) or 6.
- `isArg_of`: with the PE bound, `IsArg pe (.ofArgReg a)`; `argsRel_regRel` the corollary.
- `argInsn_reg`: an accepted `arg` proto's register: `ArgReg.of?` of its operand, the PE bound,
  and its `RegRel` from `ArgsRel`.
-/
import Ryo.Proofs.ArgRet
import Ryo.Proofs.DecodeLink.Arg

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.Asm Ryo.Proofs.ArgRet

theorem of?_index {w : Nat} {a : ArgReg} (h : ArgReg.of? w true = some a) :
    a.index < (if a.xmm then 8 else 6) := by
  unfold ArgReg.of? at h
  simp only [Option.ite_none_right_eq_some, Option.some.injEq] at h
  obtain ⟨hok, rfl⟩ := h
  simp only
  revert hok
  cases w &&& 0x20 != 0 <;> intro hok <;> simp_all <;> omega

theorem isArg_of {pe : Bool} {w : Nat} {a : ArgReg} (h : ArgReg.of? w true = some a)
    (hpe : pe → a.index < 4) : IsArg pe (R.Reg.ofArgReg a) := by
  have hi := of?_index h
  cases pe
  · cases hx : a.xmm <;>
      simp only [R.Reg.ofArgReg, IsArg, hx, Bool.false_eq_true, ↓reduceIte] at hi ⊢ <;> omega
  · have h4 := hpe rfl
    cases hx : a.xmm <;> simp only [R.Reg.ofArgReg, IsArg, hx, Bool.false_eq_true, ↓reduceIte] <;>
      omega

theorem argsRel_regRel {pe : Bool} {args : R.Regs} {x : X86.State} {w : Nat} {a : ArgReg}
    (hA : ArgsRel pe args x) (h : ArgReg.of? w true = some a) (hpe : pe → a.index < 4) :
    RegRel pe args x (R.Reg.ofArgReg a) :=
  hA _ (isArg_of h hpe)

/-- An `arg` proto `argInsn` accepts: its register operand decodes to `a`, below 4 on PE, so
its `RegRel` follows from `ArgsRel`. -/
theorem argInsn_reg {mode : Mode} {c c' : Cursor} {q : Proto}
    (h : (argInsn mode).run c = .ok (some q, c')) :
    ∃ (a : ArgReg) (d : BitVec 32), q.op = .arg ∧
      q.ops = [.slot d, .imm (BitVec.ofNat 64 a.word)] ∧
      ArgReg.of? (BitVec.ofNat 64 a.word).toNat true = some a ∧ (mode.pe → a.index < 4) ∧
      ∀ (args : R.Regs) (x : X86.State), ArgsRel mode.pe args x →
        RegRel mode.pe args x (R.Reg.ofArgReg a) := by
  obtain ⟨a, d, rfl, hs, hi, hof, -, -, hpe⟩ := argInsn_bounds h
  have hw : (BitVec.ofNat 64 a.word).toNat = a.word := by
    rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by have := word_lt a; omega)
  obtain ⟨b, hb⟩ := Option.isSome_iff_exists.mp hof
  have hex : ArgReg.of? a.word true = some a := by rw [hb, of_word_eq hs hi hb]
  exact ⟨a, d, rfl, rfl, by rw [hw]; exact hex, hpe, fun _ _ hA => argsRel_regRel hA hex hpe⟩

end Ryo.Proofs.DecodeLink
