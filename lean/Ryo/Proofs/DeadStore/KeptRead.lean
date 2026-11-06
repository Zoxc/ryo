/-
Ryo.Proofs.DeadStore.KeptRead — the kept-read invariant: no byte of the patch set is kept-read
live (`Frame.Flow.keptReadLive`, certified by `Cert.hkept`), so the machine code never reads,
from memory, a byte where the real machine and the ghost differ.

- `KrAt S C k P`, `KrInv S C s P` (`KrAt` at `s.pc`; in `Defs.lean`): every frame byte of `P`
  is out of the kept-read liveness into the instruction.
- `krAt_dropped`: the bytes a dropped store adds (its range but its flag byte) satisfy it at each
  successor (`Cert.hunread`, `droppedUnread_spec`); `krAt_dropped_off` in offsets.
- `krAt_succ`, `krAt_succ_covers` (with `CoveredAtSound`), `krAt_pad`: the bytes kept, along an
  edge, if not written for sure and not ended before the instruction unless the cache covers
  them entering the successor (`keptRead_succ`, `keptRead_pad`).
- `krInv_off`, `krInv_hrd`: the kept items at `s.pc` read no byte of `P` through an `rbp`-based
  operand, in `keptReads_apart`'s offset form and in `keptApart_of_live`'s address form
  (`itm_hrd_of_off`).
-/
import Ryo.Proofs.DeadStore.Defs
import Ryo.Proofs.DeadStore.Fix
import Ryo.Proofs.DeadStore.Items

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Proofs.DecodeSound

variable {S : Setup}

-- `Cert.kr`, `KrAt`, `KrInv` and `KrOk` are in `Defs.lean` (`DInv` carries `KrOk`).

/-! ### (a) A dropped store's bytes -/

/-- The bytes dropped store `k` adds (`droppedBitsAt`, but its flag byte) are out of the
kept-read liveness into each successor. -/
theorem krAt_dropped (C : Cert S) {k : Nat} (hk : k ∈ S.c.d.dropped.toList) {t : Nat}
    (ht : t ∈ C.fl.succ[k]!) {Q : Int → Prop}
    (hQ : ∀ o, Q o → InFrame S o → (Frame.droppedBitsAt S.c.d k).testBit (bit S o) = true ∧
      (Frame.flagBits S.c.d k).testBit (bit S o) = false) :
    KrAt S C t Q := by
  intro o ho hin
  obtain ⟨hd, hfl⟩ := hQ o ho hin
  exact droppedUnread_spec (C.hunread k hk) hd hfl ht

/-- `krAt_dropped` in offsets: the bytes of the dropped store's destination range but its flag
slot. -/
theorem krAt_dropped_off (C : Cert S) {k : Nat} (hk : k ∈ S.c.d.dropped.toList) {t : Nat}
    (ht : t ∈ C.fl.succ[k]!) {s : BitVec 32} {w : Nat}
    (hs : Frame.droppedStore S.c.d k = some (s, w)) {Q : Int → Prop}
    (hQ : ∀ o, Q o → s.toInt ≤ o ∧ o < s.toInt + w ∧ ∀ f, Frame.flagSlot S.c.d k = some f →
      o ≠ f.toInt) :
    KrAt S C t Q := by
  refine krAt_dropped C hk ht fun o ho hin => ?_
  obtain ⟨h1, h2, hf⟩ := hQ o ho
  obtain ⟨hi1, hi2⟩ := hin
  refine ⟨testBit_droppedBitsAt hs ?_ ?_, testBit_flagBits fun f hf' => ?_⟩
  · simp only [Frame.range, bit]; omega
  · simp only [Frame.range, bit]; omega
  · have hne := hf f hf'
    simp only [Frame.range, bit]
    omega

/-! ### (b) The bytes kept along an edge -/

/-- Along an edge `k → t`: the bytes of `P` (out of the kept-read liveness into `k`) not
written for sure by `k` and not ended before `k` unless `coveredAt` covers them at `t`. -/
theorem krAt_succ (C : Cert S) {k : Nat} (hk : k < C.fl.succ.size) {P P' : Int → Prop}
    (hP : KrAt S C k P) {t : Nat} (ht : t ∈ C.fl.succ[k]!)
    (hP' : ∀ o, P' o → InFrame S o → P o ∧ C.fl.kill[k]!.bits.testBit (bit S o) = false ∧
      (C.fl.ends[k]!.bits.testBit (bit S o) = false ∨
        (Frame.coveredAt S.c.d t).testBit (bit S o) = true)) :
    KrAt S C t P' := by
  intro o ho hin
  obtain ⟨hp, hkill, hend⟩ := hP' o ho hin
  cases hl : (C.kr[t]!).testBit (bit S o) with
  | false => rfl
  | true =>
    have := keptRead_succ C.hkept hk ht hl hkill hend
    rw [hP o hp hin] at this
    cases this

/-- `krAt_succ` with the cache side condition as `CacheCovers` (`CoveredAtSound`). -/
theorem krAt_succ_covers (C : Cert S) (hcov : CoveredAtSound S) {k : Nat}
    (hk : k < C.fl.succ.size) {P P' : Int → Prop} (hP : KrAt S C k P) {t : Nat}
    (ht : t ∈ C.fl.succ[k]!) (htle : t ≤ S.c.d.insns.size)
    (hP' : ∀ o, P' o → InFrame S o → P o ∧ C.fl.kill[k]!.bits.testBit (bit S o) = false ∧
      (C.fl.ends[k]!.bits.testBit (bit S o) = false ∨ CacheCovers S t o)) :
    KrAt S C t P' :=
  krAt_succ C hk hP ht fun o ho hin => by
    obtain ⟨hp, hkill, hend⟩ := hP' o ho hin
    exact ⟨hp, hkill, hend.imp id fun hc => hcov t o htle hc hin⟩

/-- Along an unwinding edge to a landing pad: every byte of `P` is kept. -/
theorem krAt_pad (C : Cert S) {k : Nat} (hk : k < C.fl.succ.size) {P P' : Int → Prop}
    (hP : KrAt S C k P) {t : Nat} (ht : t ∈ C.fl.pad[k]!) (hP' : ∀ o, P' o → P o) :
    KrAt S C t P' := by
  intro o ho hin
  cases hl : (C.kr[t]!).testBit (bit S o) with
  | false => rfl
  | true =>
    have := keptRead_pad C.hkept hk ht hl
    rw [hP o (hP' o ho) hin] at this
    cases this

/-- `KrInv` into the successor of an R transition `s → s'`, by its edge: a flow successor (the
bytes kept not written for sure by `s.pc` and not ended before it unless `coveredAt` covers them
at `s'.pc`) or a landing pad (any bytes of `P`). -/
theorem krInv_next (C : Cert S) {s s' : R.RState} {P P' : Int → Prop} (hI : KrInv S C s P)
    (hk : s.pc < C.fl.succ.size)
    (hedge : (s'.pc ∈ C.fl.succ[s.pc]! ∧ ∀ o, P' o → InFrame S o → P o ∧
        C.fl.kill[s.pc]!.bits.testBit (bit S o) = false ∧
        (C.fl.ends[s.pc]!.bits.testBit (bit S o) = false ∨
          (Frame.coveredAt S.c.d s'.pc).testBit (bit S o) = true)) ∨
      (s'.pc ∈ C.fl.pad[s.pc]! ∧ ∀ o, P' o → P o)) :
    KrInv S C s' P' := by
  rcases hedge with ⟨ht, hP'⟩ | ⟨ht, hP'⟩
  · exact krAt_succ C hk hI ht hP'
  · exact krAt_pad C hk hI ht hP'

/-! ### (c) The kept items' reads -/

/-- The kept items at `s.pc` read no byte of `P` through an `rbp`-based operand (offsets). -/
theorem krInv_off (C : Cert S) {s : R.RState} {P : Int → Prop} (hI : KrInv S C s P)
    (hin : ∀ o, P o → InFrame S o) (hk : s.pc < C.fl.succ.size) {kept : List Item}
    (hkept : S.c.d.items[s.pc]? = some kept) :
    ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it,
      ¬ P (m.disp.toInt + j) :=
  keptReads_apart C.hkept hk hkept fun o ho => by
    have hf := hin o ho
    have hb := hI o ho hf
    obtain ⟨h1, h2⟩ := hf
    exact ⟨h1, h2, hb⟩

/-- `krInv_off` in `keptApart_of_live`'s address form (`hrd`), for a frame of at most `2 ^ 62`
bytes and items reading at most `2 ^ 32` bytes. -/
theorem krInv_hrd (C : Cert S) {s : R.RState} {P : Int → Prop} (hI : KrInv S C s P)
    (hin : ∀ o, P o → InFrame S o) (hF : (S.c.d.frameSize : Int) ≤ 2 ^ 62)
    (hk : s.pc < C.fl.succ.size) {kept : List Item} (hkept : S.c.d.items[s.pc]? = some kept)
    (hrb : ∀ it ∈ kept, readBytes it ≤ 2 ^ 32) (fp : BitVec 64) :
    ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it, ∀ o, P o →
      fp + m.disp.signExtend 64 + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o :=
  itm_hrd_of_off (fun o ho => by
      obtain ⟨h1, h2⟩ := hin o ho
      have e : (2 : Int) ^ 62 = 4611686018427387904 := by decide
      exact ⟨by omega, h2⟩)
    hrb (krInv_off C hI hin hk hkept)

end Ryo.Proofs.DeadStore
