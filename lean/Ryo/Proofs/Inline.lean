/-
Ryo.Proofs.Inline — the inline sequences (`Ryo.Vm.Asm.sequence`, `asm/inline.rs`) against
`opSem` (aot.md §C2 "Inline sequences").

For an opcode `op` of an inline class `c` (of `c`'s shape, `shapeOk`), native operands `ops`
whose sequence is `sequence c ops = some (items, br)`, and the values `vals` `opSem` takes for
them (`nativeVals`, as `view` computes them): if `opSem op vals st` succeeds with `(ctl, st')`
and `Rel st x` (`Ryo/Proofs/Inline/Rel.lean`: the frame bytes, `fp` in `rbp`, provenance
erased, `Uninit` refined by any byte), then running `items` from `x` succeeds with an `x'`
such that (`Post`):

- `Rel st' x'`, and `st'` differs from `st` at most in its private frame bytes;
- only `rax`, `rcx` and the flags changed among the registers, the `xmm`s didn't, and `rip`
  moved past the items;
- x86 memory changed only at the addresses of the footprint's write ranges;
- the control effect: `next`, or (with a branch condition `br`) `branch b` with the condition
  holding on `x'`'s flags exactly when `b` differs from the instruction's `neg` (the branch is
  taken when `b != neg`, `Then.succ`).

Where `opSem` fails (UB: an `Uninit` integer read, `addr` of a non-escaped object, …) nothing
is required. The written ranges must be private bytes (`Private`): a store into an escaped
object writes its allocation in `opSem` (`writeEscaped`), which these theorems don't cover
yet. Reads may be of private or escaped bytes (`Rel` covers both).

Classes: `mov`, `mov128`, `imm`, `addr`, `ptrAdd`, `ptrIndex`, `bin`, `binImm`, `mul`, `mulImm`,
`shiftImm`, `cmp`, `cmpImm`, `br`, `brCmp`, `brCmpImm` (`load`, `store`: memory through a
pointer, left; see aot.md §C2; `ovf`, `mulOvf`, `ext`: not yet).
-/
import Ryo.Proofs.Inline.Cmp
import Ryo.Proofs.Inline.Mem

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Vm.Asm

/-- The inline classes the theorems cover: all but `load` and `store`, whose memory operand
goes through a pointer, and the overflow ops and extensions, not proved yet. -/
def frameOnly : Class → Bool
  | .load _ | .store _ | .ovf .. | .mulOvf .. | .ext .. => false
  | _ => true

/-- Each inline sequence implements `opSem` (see the module comment), for every class but
`load` and `store`. -/
theorem inline_sound (c : Class) (hc : frameOnly c = true) : Sound c := by
  cases c with
  | mov w => exact sound_mov w
  | mov128 => exact sound_mov128
  | imm w => exact sound_imm w
  | addr => exact sound_addr
  | ptrAdd => exact sound_ptrAdd
  | ptrIndex => exact sound_ptrIndex
  | load w => simp [frameOnly] at hc
  | store w => simp [frameOnly] at hc
  | bin op w => exact sound_bin op w
  | binImm op w => exact sound_binImm op w
  | mul w => exact sound_mul w
  | mulImm w => exact sound_mulImm w
  | shiftImm sh w => exact sound_shiftImm sh w
  | cmp c w => exact sound_cmp c w
  | cmpImm c w => exact sound_cmpImm c w
  | br => exact sound_br
  | brCmp c w => exact sound_brCmp c w
  | brCmpImm c w => exact sound_brCmpImm c w
  | ovf => simp [frameOnly] at hc
  | mulOvf => simp [frameOnly] at hc
  | ext => simp [frameOnly] at hc

end Ryo.Proofs.Inline
