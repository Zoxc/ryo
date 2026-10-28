/-
Ryo.Proofs.Inline.All — every inline class but `load`, `store` and the rip-relative addresses
implements `opSem`: the classes of `Ryo/Proofs/Inline.lean` (`inline_soundC`), and the later ones
(`laterClass`: `Later.lean`'s variable shifts and rotates, `bswap`, `cmp3`; `LaterDiv.lean`'s
`div` and `count`). `div` also changes `rdx` (`clobbers`).
-/
import Ryo.Proofs.Inline.Later
import Ryo.Proofs.Inline.LaterDiv

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Vm.Asm

/-- `SoundC` for every class of `frameOnly`, `ovfClass` or `laterClass`. -/
theorem inline_soundC_all (c : Class)
    (hc : frameOnly c = true ∨ ovfClass c = true ∨ laterClass c = true) : SoundC c := by
  rcases hc with h | h | h
  · exact inline_soundC c (Or.inl h)
  · exact inline_soundC c (Or.inr h)
  · cases c with
    | shiftVar sh w => exact (sound_shiftVar sh w).soundC
    | div sg rem w => exact SoundX.toC (sound_div sg rem w)
    | count lz w => exact (sound_count lz w).soundC
    | cmp3 sg w => exact (sound_cmp3 sg w).soundC
    | bswap w => exact (sound_bswap w).soundC
    | _ => simp [laterClass] at h

/-- `Sound` for those classes that change only `rax` and `rcx` (all but unsigned 64-bit
`mul.ovf` and `div`). -/
theorem inline_sound_all (c : Class)
    (hc : frameOnly c = true ∨ ovfClass c = true ∨ laterClass c = true)
    (hcl : clobbers c = [0, 1]) : Sound c :=
  (inline_soundC_all c hc).sound hcl

end Ryo.Proofs.Inline
