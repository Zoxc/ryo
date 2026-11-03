/-
Ryo.X86.VRet — environment relations read on virtual states (`Ryo.X86.VirtFp`): `rbp` replaced
by the same value before and after.
-/
import Ryo.X86.State

namespace Ryo.X86

/-! ### Environment relations on virtual states -/

theorem State.setReg_reg_self (x : State) (r : Reg) : x.setReg r (x.reg r) = x := by
  cases x
  simp only [State.setReg, State.reg, State.mk.injEq, and_true]
  funext i
  split <;> simp_all

/-- `Ret` read on virtual states: both ends are real states with `rbp` replaced by the same
value. With `v := x.reg .rbp` it is `Ret` itself (`vRet_of`). -/
def VRet (Ret : State → State → Prop) (xv xv' : State) : Prop :=
  ∃ v x x', Ret x x' ∧ xv = x.setReg .rbp v ∧ xv' = x'.setReg .rbp v

end Ryo.X86
