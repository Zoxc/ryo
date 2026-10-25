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
`shiftImm`, `cmp`, `cmpImm`, `br`, `brCmp`, `brCmpImm`, `ext` (`inline_sound`), and the rip-relative
addresses `addrConst`, `addrSym`, `addrSymInd` (`inline_sound_rip`, `SoundG`: `Sound` given
`Globals`, where the constants, data and symbol slots are linked and that out-of-frame loads
read the x86 bytes; `Ryo/Proofs/Inline/Rip.lean`). Not yet: `load`, `store` (memory through a
pointer; see aot.md §C2).

The overflow ops `ovf` (`add.ovf`/`sub.ovf`) and `mulOvf` hold in a weaker form,
`inline_sound_ovf` (`SoundD`, `Ryo/Proofs/Inline/Ovf.lean`), under two side conditions:
- the written ranges (`wranges`: the result `d`, the flag byte `o`) are pairwise disjoint
  (`RangesDisjoint`): `opSem` writes `d`, then `o`, but the sequence stores the flag first, so
  where the flag byte lies inside `d`'s range they disagree (`opSem` leaves the flag there, x86
  the result's byte);
- unsigned 64-bit `mul.ovf` (`mul`, `rdx:rax`) also changes `rdx` (`clobbers`), as the register
  cache knows (`Cache.update` drops `rdx`'s entry after a `mul`).
`Sound c → SoundD c` (`Sound.soundD`) carries the other classes over (`inline_soundD`).
-/
import Ryo.Proofs.Inline.Ovf
import Ryo.Proofs.Inline.Mem
import Ryo.Proofs.Inline.Rip

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Vm.Asm

/-- The inline classes the theorems cover: all but `load` and `store`, whose memory operand
goes through a pointer, the overflow ops (`inline_sound_ovf`: their two writes are in the other
order than `opSem`'s; see the module comment), and the rip-relative addresses (`inline_sound_rip`: they
need `Globals`). -/
def frameOnly : Class → Bool
  | .load _ | .store _ | .ovf .. | .mulOvf .. | .addrConst | .addrSym | .addrSymInd => false
  | _ => true

/-- Each inline sequence implements `opSem` (see the module comment), for every class of
`frameOnly`. -/
theorem inline_sound (c : Class) (hc : frameOnly c = true) : Sound c := by
  cases c with
  | mov w => exact sound_mov w
  | mov128 => exact sound_mov128
  | imm w => exact sound_imm w
  | addr => exact sound_addr
  | addrConst => simp [frameOnly] at hc
  | addrSym => simp [frameOnly] at hc
  | addrSymInd => simp [frameOnly] at hc
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
  | ext src dst sx => exact sound_ext src dst sx

/-- The rip-relative address classes. -/
def ripAddr : Class → Bool
  | .addrConst | .addrSym | .addrSymInd => true
  | _ => false

/-- Each rip-relative address sequence implements `opSem`, given `Globals`. -/
theorem inline_sound_rip (c : Class) (hc : ripAddr c = true) : SoundG c := by
  cases c <;> simp [ripAddr] at hc
  · exact sound_addrConst
  · exact sound_addrSym
  · exact sound_addrSymInd

/-- Both together: every class but `load`, `store`, `ovf` and `mulOvf`, given `Globals`. -/
theorem inline_soundG (c : Class) (hc : frameOnly c = true ∨ ripAddr c = true) : SoundG c :=
  hc.elim (fun h => (inline_sound c h).soundG) (inline_sound_rip c)

/-- The overflow classes: `add.ovf`/`sub.ovf` (the only `ovf` classes, `Class.ofName`) and
`mul.ovf`. -/
def ovfClass : Class → Bool
  | .ovf .add .. | .ovf .sub .. | .mulOvf .. => true
  | _ => false

/-- Each overflow sequence implements `opSem`, given disjoint write ranges and with `rdx`
clobbered by unsigned 64-bit `mul.ovf` (`SoundD`). -/
theorem inline_sound_ovf (c : Class) (hc : ovfClass c = true) : SoundD c := by
  cases c with
  | ovf op sg w =>
    cases op <;> simp [ovfClass] at hc
    · exact sound_ovf .add (Or.inl rfl) sg w
    · exact sound_ovf .sub (Or.inr rfl) sg w
  | mulOvf sg w => exact sound_mulOvf sg w
  | _ => simp [ovfClass] at hc

/-- `SoundD` for every class but `load`, `store` and the rip-relative addresses. -/
theorem inline_soundD (c : Class) (hc : frameOnly c = true ∨ ovfClass c = true) : SoundD c :=
  hc.elim (fun h => (inline_sound c h).soundD) (inline_sound_ovf c)

end Ryo.Proofs.Inline
