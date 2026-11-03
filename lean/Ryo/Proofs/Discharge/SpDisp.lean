/-
Ryo.Proofs.Discharge.SpDisp — `Item.SpDispOk` for every decoded item without a frame pointer,
from the Lean-only check `spDispCheck` (`Ryo/Vm/SpDispCheck.lean`, run by
`Frame.decodeChecked`).

- `spDispOk_of_item`: `spDispItemOk` is `Item.SpDispOk`.
- `spDisp_of_decodeItem`, `spDisp_of_scan`: an item `decodeItem` reads at any position of the
  code (and so every item of a `Dec` run) is `SpDispOk`: it is a base item (no memory operand,
  `baseCandidate_ok`) or `fromSpFrame` of an SSE or native candidate, which read only the code
  and the position, so the scan's cursor's.
- `Hyps.spDisp`: the property `decode_sound` needs, from `Hyps.spDispOk`.
- `spDispOk_of_decodes`: `decodeChecked`'s check on its inputs (`decodeChecked_ok`) is
  `Hyps.spDispOk` for a `Setup` that is their read (`Decodes`).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.DecodeLink.Items
import Ryo.Proofs.DecodeLink.Tables
import Ryo.Vm.SpDispCheck

namespace Ryo.Proofs.DecodeSound

open Ryo.Vm Ryo.Vm.Asm Ryo.X86 Ryo.Vm.R Ryo.Proofs.DecodeLink

theorem spDispOk_of_item {F : BitVec 32} {i : Item} (h : spDispItemOk F i = true) :
    Item.SpDispOk F i := by
  intro m hm hb
  unfold spDispItemOk at h
  rw [hm] at h
  simp only [hb, bne_self_eq_false, Bool.false_or, decide_eq_true_eq] at h
  exact h

/-- The SSE candidate reads only the code and the position. -/
theorem sseCandidate_congr {c c' : Cursor} (h1 : c.code = c'.code) (h2 : c.pos = c'.pos) :
    c.sseCandidate = c'.sseCandidate := by
  cases c; cases c'
  simp only at h1 h2
  subst h1 h2
  rfl

/-- The native candidate reads only the code and the position. -/
theorem nativeCandidate_congr {c c' : Cursor} (h1 : c.code = c'.code) (h2 : c.pos = c'.pos) :
    c.nativeCandidate = c'.nativeCandidate := by
  cases c; cases c'
  simp only at h1 h2
  subst h1 h2
  rfl

/-- `fromSpFrame` reads only the frame form. -/
theorem fromSpFrame_congr {c c' : Cursor} (h : c.spFrame = c'.spFrame) (i : Item) :
    c.fromSpFrame i = c'.fromSpFrame i := by
  unfold Cursor.fromSpFrame
  rw [h]

theorem spDispScan_at {code : Array UInt8} {F : BitVec 32} {p : Nat}
    (h : spDispScan code F = true) (hp : p < code.size) :
    spDispAt (spDispCursor code F p) F (spDispCursor code F p).sseCandidate = true ∧
      spDispAt (spDispCursor code F p) F (spDispCursor code F p).nativeCandidate = true := by
  unfold spDispScan at h
  rw [List.all_eq_true] at h
  have := h p (List.mem_range.mpr hp)
  simpa only [Bool.and_eq_true] using this

theorem spDispAt_some {c : Cursor} {F : BitVec 32} {k : Option Item} {i : Item}
    (hk : k.bind c.fromSpFrame = some i) (h : spDispAt c F k = true) : spDispItemOk F i = true := by
  unfold spDispAt at h
  rw [hk] at h
  exact h

/-- An item `decodeItem` reads at any position of the code, without a frame pointer of frame
size `F`, is `SpDispOk F`. -/
theorem spDisp_of_decodeItem {code : Array UInt8} {F : BitVec 32} {c : Cursor} {p n : Nat}
    {i : Item} (h : spDispScan code F = true) (hc : c.code = code) (hs : c.spFrame = some F)
    (hdi : decodeItem (atPos c p) = some (i, n)) : Item.SpDispOk F i := by
  have hp : p < code.size := by
    have := Ryo.Proofs.DecodeLink.Tables.decodeItem_pos_lt hdi
    rw [← hc]; exact this
  have h1 : (atPos c p).code = (spDispCursor code F p).code := hc
  have h2 : (atPos c p).pos = (spDispCursor code F p).pos := rfl
  have h3 : (atPos c p).spFrame = (spDispCursor code F p).spFrame := hs
  obtain ⟨hsse, hnat⟩ := spDispScan_at h hp
  have hacc : ∀ (post : Item → Option Item) (k : Item), (atPos c p).accept post k = some (i, n) →
      post k = some i := by
    intro post k ha
    unfold Cursor.accept at ha
    split at ha
    · rename_i hp; cases ha; exact hp
    · cases ha
  unfold decodeItem at hdi
  rcases Option.orElse_some' hdi with hdi | hdi
  · obtain ⟨k, hk, hdi⟩ := Option.bind_eq_some_iff.mp hdi
    cases hacc _ _ hdi
    intro m hm _
    rw [(baseCandidate_ok hk).1] at hm
    cases hm
  rcases Option.orElse_some' hdi with hdi | hdi
  · obtain ⟨k, hk, hdi⟩ := Option.bind_eq_some_iff.mp hdi
    have hpost := hacc _ _ hdi
    refine spDispOk_of_item (spDispAt_some ?_ hsse)
    rw [← sseCandidate_congr h1 h2, hk]
    exact (fromSpFrame_congr h3 k).symm.trans hpost
  · obtain ⟨k, hk, hdi⟩ := Option.bind_eq_some_iff.mp hdi
    have hpost := hacc _ _ hdi
    refine spDispOk_of_item (spDispAt_some ?_ hnat)
    rw [← nativeCandidate_congr h1 h2, hk]
    exact (fromSpFrame_congr h3 k).symm.trans hpost

/-- `spDispScan`'s success: every item of any `Dec` run over the code, without a frame pointer
of frame size `F`, is `SpDispOk F`. -/
theorem spDisp_of_scan {code : Array UInt8} {F : BitVec 32} (h : spDispScan code F = true) :
    ∀ c : Cursor, c.code = code → c.spFrame = some F → ∀ p items q, Dec c p items q →
      ∀ i ∈ items, Item.SpDispOk F i := by
  intro c hc hs p items q hd
  induction hd with
  | nil => intro i hi; cases hi
  | cons hdi _ ih =>
    intro i hi
    rcases List.mem_cons.mp hi with rfl | hi
    · exact spDisp_of_decodeItem h hc hs hdi
    · exact ih i hi

/-- Without a frame pointer, every decoded item's frame operand `[rsp + d + F]` has the signed
displacement `d + F` (no wrap), so it reads as `[rbp + d]` on the virtual state
(`Item.SpDispOk`, `Ryo.X86.VirtFp.exec_item_virt`), from `spDispCheck`. -/
theorem Hyps.spDisp {S : Setup} (H : Hyps S) : ∀ F, S.body.spFrame = some F →
    ∀ c : Cursor, c.code = S.body.code → c.spFrame = some F → ∀ p items q, Dec c p items q →
      ∀ i ∈ items, Item.SpDispOk F i :=
  fun F hF => spDisp_of_scan (H.spDispOk F hF)

/-- `decodeChecked`'s `spDispCheck` on the function's inputs gives `Hyps.spDispOk` for their
read. -/
theorem spDispOk_of_decodes {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (h : spDispCheck code.data S.c.d mode = true) :
    ∀ F, S.body.spFrame = some F → spDispScan S.body.code F = true := by
  intro F hsp
  have hc : S.body.code = code.data := (congrArg Cursor.code hD.bodyEq).trans rfl
  rw [hc]
  cases hfp : mode.framePointer with
  | true =>
    rw [hD.bodyEq] at hsp
    simp [bodyCursor, hfp] at hsp
  | false =>
    rw [hD.bodyEq] at hsp
    simp only [bodyCursor, hfp] at hsp
    simp only [spDispCheck, hfp, Bool.false_or, reducedOf_frameSize hD.reduced] at h
    simp at hsp
    subst hsp
    exact h

end Ryo.Proofs.DecodeSound
