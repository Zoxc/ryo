/-
Ryo.Proofs.Inline — the inline sequences (`Ryo.Vm.Asm.sequence`, `asm/inline.rs`) against
`opSem` (aot.md §C2 "Inline sequences").

For an opcode `op` of an inline class `c` (of `c`'s shape, `shapeOk`), native operands `ops`
whose sequence is `sequence c ops = some (items, br)`, and the values `vals` `opSem` takes for
them (`nativeVals`, as `view` computes them): if `opSem op vals st` succeeds with `(ctl, st')`
and `Rel st x` (`Ryo/Proofs/Inline/Rel.lean`: the frame bytes, `fp` in `rbp`, provenance
erased, `Uninit` refined by any byte), then running `items` from `x` succeeds with an `x'`
such that (`Post`):

- `Rel st' x'`, and `st'` differs from `st` at most in its frame bytes, private or in escaped
  objects (`SameButWrites`: memory changes only in the escaped objects' allocations, `EscOnly`);
- only `rax`, `rcx` and the flags changed among the registers, the `xmm`s didn't, and `rip`
  moved past the items;
- x86 memory changed only at the addresses of the footprint's write ranges;
- the control effect: `next`, or (with a branch condition `br`) `branch b` with the condition
  holding on `x'`'s flags exactly when `b` differs from the instruction's `neg` (the branch is
  taken when `b != neg`, `Then.succ`).

Where `opSem` fails (UB: an `Uninit` integer read, `addr` of a non-escaped object, …) nothing
is required. Reads and writes may be of private or escaped bytes: a write into an escaped object
writes its allocation in `opSem` (`writeEscaped`), and `rel_writeFrame` (`Inline/Rel.lean`)
keeps `Rel` for both (under `Rel`, escaped objects sit at their frame addresses, so two frame
offsets never write the same allocation byte, `esc_inj`). Only `load` still assumes its
destination private (`Private`), for `MemRel` (see `Inline/Mem.lean`).

Classes: `mov`, `mov128`, `imm`, `addr`, `ptrAdd`, `ptrIndex`, `bin`, `binImm`, `mul`, `mulImm`,
`shiftImm`, `cmp`, `cmpImm`, `br`, `brCmp`, `brCmpImm`, `ext` (`inline_sound`), and the rip-relative
addresses `addrConst`, `addrSym`, `addrSymInd` (`inline_sound_rip`, `SoundG`: `Sound` given
`Globals`, where the constants, data and symbol slots are linked and that out-of-frame loads
read the x86 bytes; `Ryo/Proofs/Inline/Rip.lean`). Not yet: `load`, `store` (memory through a
pointer; see aot.md §C2).

The overflow ops `ovf` (`add.ovf`/`sub.ovf`) and `mulOvf` are `inline_sound_ovf`
(`Ryo/Proofs/Inline/Ovf.lean`): the sequences store the result `d`, then the flag byte `o`, as
`opSem` writes them, so overlapping outputs agree. All but unsigned 64-bit `mul.ovf` are `Sound`;
that one (`mul`, `rdx:rax`) also changes `rdx` (`clobbers`, `SoundC`: `inline_sound_umulq`), as
the register cache knows (`Cache.update` drops `rdx`'s entry after a `mul`). `Sound c → SoundC c`
(`Sound.soundC`) carries the other classes over (`inline_soundC`).
-/
import Ryo.Proofs.Inline.Ovf
import Ryo.Proofs.Inline.Mem
import Ryo.Proofs.Inline.Rip

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Vm.Asm

/-- The inline classes the theorems cover: all but `load` and `store`, whose memory operand
goes through a pointer, the overflow ops (`inline_sound_ovf`, in their own module), and the
rip-relative addresses (`inline_sound_rip`: they
need `Globals`). -/
def frameOnly : Class → Bool
  | .load _ | .store _ | .ovf .. | .mulOvf .. | .addrConst | .addrSym | .addrSymInd => false
  -- No inline opcode is an immediate rotate (`classOfParts`).
  | .shiftImm sh _ => sh.isShift
  -- Not covered yet: the variable shifts and rotates, `div`/`rem`, `cttz`/`ctlz`, `cmp3`, `bswap`.
  | .shiftVar .. | .div .. | .count .. | .cmp3 .. | .bswap _ => false
  | _ => true

/-- The classes inlined after these proofs were written, which they don't cover yet (lean/PENDING.md):
the variable shifts and rotates, `div`/`rem`, `cttz`/`ctlz`, `cmp3` and `bswap`. Their
sequences use items the register cache proofs don't track (`cacheSafe`) and registers other than
`rax` and `rcx` (`rdx`). -/
def laterClass : Class → Bool
  | .shiftVar .. | .div .. | .count .. | .cmp3 .. | .bswap _ => true
  | _ => false

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
  | shiftImm sh w => exact sound_shiftImm sh w (by simpa [frameOnly] using hc)
  | cmp c w => exact sound_cmp c w
  | cmpImm c w => exact sound_cmpImm c w
  | br => exact sound_br
  | brCmp c w => exact sound_brCmp c w
  | brCmpImm c w => exact sound_brCmpImm c w
  | ovf => simp [frameOnly] at hc
  | mulOvf => simp [frameOnly] at hc
  | ext src dst sx => exact sound_ext src dst sx
  | shiftVar => simp [frameOnly] at hc
  | div => simp [frameOnly] at hc
  | count => simp [frameOnly] at hc
  | cmp3 => simp [frameOnly] at hc
  | bswap => simp [frameOnly] at hc

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

/-- Each overflow sequence implements `opSem`, with `rdx` clobbered by unsigned 64-bit
`mul.ovf` (`SoundC`). -/
theorem inline_soundC_ovf (c : Class) (hc : ovfClass c = true) : SoundC c := by
  cases c with
  | ovf op sg w =>
    cases op <;> simp [ovfClass] at hc
    · exact sound_ovf .add (Or.inl rfl) sg w
    · exact sound_ovf .sub (Or.inr rfl) sg w
  | mulOvf sg w => exact sound_mulOvf sg w
  | _ => simp [ovfClass] at hc

/-- Each overflow sequence but unsigned 64-bit `mul.ovf`'s implements `opSem` (`Sound`). -/
theorem inline_sound_ovf (c : Class) (hc : ovfClass c = true) (hq : c ≠ .mulOvf false .q) :
    Sound c :=
  (inline_soundC_ovf c hc).sound (by
    unfold clobbers; split
    · exact absurd rfl hq
    · rfl)

/-- Unsigned 64-bit `mul.ovf`, which also changes `rdx`. -/
theorem inline_sound_umulq : SoundC (.mulOvf false .q) := sound_mulOvf false .q

/-- `SoundC` for every class but `load`, `store` and the rip-relative addresses. -/
theorem inline_soundC (c : Class) (hc : frameOnly c = true ∨ ovfClass c = true) : SoundC c :=
  hc.elim (fun h => (inline_sound c h).soundC) (inline_soundC_ovf c)

end Ryo.Proofs.Inline
