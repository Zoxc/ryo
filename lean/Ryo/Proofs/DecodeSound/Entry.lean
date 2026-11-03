/-
Ryo.Proofs.DecodeSound.Entry — the entry step of `decode_sound` (aot.md §C2), frame-pointer
mode only: from the function's entry state `S.x0` (the caller's `call` done, `rip` at the
function's first byte, `rsp` at the return address), the code the decoder read before the body
(`readFrame`: the entry's counter check `inc qword [rip + record]; jns stub` with its stub, then
`prologue F mode` = `push rbp; mov rbp, rsp; [mov eax, F; call probe]; [sub rsp, F]`), run by
the fetching machine, reaches a state related (`BInv`) to R's entry state
`R.entry S.c fp args stack w`, with `fp = x0.rsp - 8`, `args` the incoming argument registers,
`stack` the incoming stack arguments at `x0.rsp + 8` and `w` the world (`EntryAt`, as a caller's
`call_sound` gives it). With `decode_sound` this closes the "Not covered: the prologue" gap of
`DecodeSound.lean`'s module comment (`entry_sound`).

**Statement** (`reach_entry`). Premises, each a named structure field below:

- `EntryRead S` (`DecodeSound/Basic.lean`): the decoder's layout of the entry (the counter check
  and its stub, the prologue of the frame size, item by item up to the body), from
  `Decodes.entry` (`entryRead_of_decodes`; set by `decodes_of_ok` from `read_instructions_entry`).
- `EntryEnv S args stack w`: the caller's side. `EntryAt` of the call at `x0` (outgoing area at
  `x0.rsp + 8`), `rip` at position 0, the stack arguments `argSize` bytes, room on the stack for
  the frame and the calls (`lo + 72 + F ≤ x0.rsp`), the incoming area within the address space,
  the code and rodata linked at entry, and the world's live allocations disjoint, in the address
  space, apart from the runtime-owned bytes and the stack below `x0.rsp`, and off the frame
  window `[-F, K)`.
- `EntryContract S`: the environment's side. The probe's contract (`ProbeContract`: it returns
  to its return address with `rsp + 8`, every register but `r11` and every `xmm` kept, memory
  outside runtime-owned bytes and the stack below its caller's `rsp` kept: `ryo_probe_stack`'s
  comment), the entry trip keeping the argument registers (`EntryTripKeeps`: jit.md's entry trip
  keeps every register but `rax`, `r11` and the flags; `TripContract` only gives the
  callee-saved ones), the entry counter runtime-owned and the entry slot off the stack, and
  `F < 2 ^ 31` (`sub rsp, F`'s immediate sign-extends to `F`).

**Proved**: the R entry state (`entry_ok`), the relation from a state past the prologue
(`frameInv_entry`, `binv_entry`: all 13 `FrameInv` fields), the counter check with its stub and
trip (`reach_entryCheck`), the prologue with the probe (`reach_prologue`: `entry_pushMov`,
`entry_probe`, `entry_sub`), and the composition (`reach_entry`, `entry_sound`). Nothing is open.
-/
import Ryo.Proofs.DecodeSound

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)

/-! ## The premises -/

/-- R's `fp` at the entry: the entry `rsp` less the 8 bytes `push rbp` takes. -/
def entryFp (S : Setup) : Nat := S.x0.rsp.toNat - 8

/-- Trusted (`ryo_probe_stack`, `vm/rt/src/vm/interp.rs`: "preserves every register but
`r11`"): the environment runs from the probe's entry, and every return comes back to the return
address with `rsp + 8`, every register but `rsp` and `r11` and every `xmm` kept, and memory kept
outside runtime-owned bytes and the stack below the caller's `rsp` (it pushes `rax` there). Its
page touches only read; a guard page hit is a non-return (no `ret` state), which `Reach` allows. -/
structure ProbeContract (S : Setup) : Prop where
  out : ∀ x : X86.State, x.rip = S.ctx.addrOf .probe → S.E.out x
  rip : ∀ x x', x.rip = S.ctx.addrOf .probe → S.E.ret x x' → x'.rip = x.mem.read64 x.rsp
  rsp : ∀ x x', x.rip = S.ctx.addrOf .probe → S.E.ret x x' → x'.rsp = x.rsp + 8
  regs : ∀ x x', x.rip = S.ctx.addrOf .probe → S.E.ret x x' →
    ∀ i : Fin 16, i ≠ 4 → i ≠ 11 → x'.regs i = x.regs i
  xmm : ∀ x x', x.rip = S.ctx.addrOf .probe → S.E.ret x x' → ∀ i, x'.xmm i = x.xmm i
  mem : ∀ x x', x.rip = S.ctx.addrOf .probe → S.E.ret x x' →
    S.lo.toNat + 8 ≤ (x.rsp + 8).toNat →
    ∀ a, ¬ S.Owned a → ¬ InStack S.lo (x.rsp + 8) a → x'.mem a = x.mem a

/-- Trusted (jit.md "Records and trips": the entry trip keeps every register but `rax`, `r11`
and the flags): a return of the environment from the entry trip (`call [r11 + 8]`, `r11` the
record) keeps every register but `rax`, `rsp` (`TripContract.ret_rsp`) and `r11`, and every
`xmm`. `TripContract` alone keeps only the callee-saved registers, which would lose the incoming
arguments. -/
def EntryTripKeeps (S : Setup) : Prop :=
  ∀ x x', x.rip = x.mem.read64 (S.ctx.addrOf .record + BitVec.ofNat 64 8) → S.E.ret x x' →
    (∀ i : Fin 16, i ≠ 0 → i ≠ 4 → i ≠ 11 → x'.regs i = x.regs i) ∧ ∀ i, x'.xmm i = x.xmm i

/-- The environment's side of the entry (see the module comment). -/
structure EntryContract (S : Setup) : Prop where
  probe : ProbeContract S
  trip : EntryTripKeeps S
  /-- The entry counter (`inc qword [rip + record]`) is runtime-owned (like
  `EnvApart.ctrOwned` for the loop counter). -/
  ctrOwned : ∀ j < 8, S.Owned (S.ctx.addrOf .record + BitVec.ofNat 64 j)
  /-- The entry slot `[record + 8]` is off the stack below the entry `rsp` (the stub's push
  doesn't change the trip's target; like `EnvApart.slotOff`). -/
  slotOff : ∀ j < 8,
    ¬ InStack S.lo S.x0.rsp (S.ctx.addrOf .record + BitVec.ofNat 64 8 + BitVec.ofNat 64 j)
  /-- `sub rsp, F`'s 32-bit immediate sign-extends to `F` (checkable: `FrameBounds.F_le` gives
  only `F ≤ 2 ^ 31`; on PE `Hyps.peFrame` gives it). -/
  frameSmall : S.F < 2 ^ 31

/-- The caller's side of the entry (see the module comment). `args`, `stack`, `w`: R's entry
registers, incoming stack bytes and world. -/
structure EntryEnv (S : Setup) (args : R.Regs) (stack : List AbstractByte) (w : R.World) :
    Prop where
  /-- The caller's `call` (`Call.call_sound`'s `EntryAt`): arguments related, the outgoing area
  at `x0.rsp + 8 = fp + 16`, the world related. -/
  at_ : ∃ cal, EntryAt S.ctx S.c.mode.pe cal args (entryFp S + 16) stack w S.x0
  /-- At the function's first byte. -/
  rip : S.x0.rip = addrAt S.ctx 0
  /-- The caller passed the function's whole incoming area (`Code.stackSize` of the call is the
  callee's `argSize`). -/
  stackLen : stack.length = S.c.argSize
  /-- Room on the stack: the frame, the return address and saved `rbp`, and `FrameInv.room`'s
  64 bytes. -/
  room : S.lo.toNat + 72 + S.F ≤ S.x0.rsp.toNat
  /-- The incoming area is within the address space. -/
  top : S.x0.rsp.toNat + 8 + S.c.argSize ≤ 2 ^ 64
  /-- The code and the rodata linked at entry. -/
  code : LinkOk S.ctx S.x0.mem S.body S.rs
  ro : RoLoaded S.ctx S.x0.mem S.ro
  /-- No live allocation is runtime-owned or on the stack below the entry `rsp` (`EnvApart.allocs`
  at the entry). -/
  allocsApart : ∀ a, Call.InAlloc w a → ¬ S.Owned a ∧ ¬ InStack S.lo S.x0.rsp a
  /-- No live allocation meets the frame window (the frame is fresh stack, the incoming area the
  caller's private outgoing area). -/
  winFree : ∀ o : Int, -(S.F : Int) ≤ o → o < S.K → ¬ Call.InAlloc w (S.winAddr o)
  /-- The world's live allocations are disjoint and within the address space. -/
  dis : MemDisjoint ({ mem := w.mem } : OpSem.State)
  space : InSpace ({ mem := w.mem } : OpSem.State)

/-- Memory kept outside runtime-owned bytes and the stack below the entry `rsp`. -/
def Keeps (S : Setup) (m : Mem) : Prop :=
  ∀ a, ¬ S.Owned a → ¬ InStack S.lo S.x0.rsp a → m a = S.x0.mem a

/-- A state past the counter check: every register but `rax` and `r11` (the stub's) and every
`xmm` as at entry, memory kept (`Keeps`). -/
structure AtCheck (S : Setup) (y : X86.State) : Prop where
  regs : ∀ i : Fin 16, i ≠ 0 → i ≠ 11 → y.regs i = S.x0.regs i
  xmm : ∀ i, y.xmm i = S.x0.xmm i
  mem : Keeps S y.mem

/-- A state past the prologue: `rbp = x0.rsp - 8` with the caller's `rbp` saved there,
`rsp = rbp - F`, every other register but `rax` and `r11` and every `xmm` as at entry, memory
otherwise kept. -/
structure AtBody (S : Setup) (x : X86.State) : Prop where
  rbp : x.reg .rbp = S.x0.rsp - 8
  rsp : x.rsp = S.x0.rsp - 8 - BitVec.ofNat 64 S.F
  regs : ∀ i : Fin 16, i ≠ 0 → i ≠ 4 → i ≠ 5 → i ≠ 11 → x.regs i = S.x0.regs i
  xmm : ∀ i, x.xmm i = S.x0.xmm i
  savedRbp : x.mem.read64 (S.x0.rsp - 8) = S.x0.reg .rbp
  mem : Keeps S x.mem

/-! ## R's entry state -/

/-- What `R.entry` gives: instruction 0, `fp`, the argument registers, no escaped object, the
world's memory, each zero-sized object at `fp + off` (not below 0), and the frame `Uninit` but
the incoming area `[16, 16 + |stack|)`, which holds `stack`. -/
theorem entry_ok {c : R.Code} {fp : Nat} {args : R.Regs} {stack : List AbstractByte}
    {w : R.World} {s0 : R.RState} (h : R.entry c fp args stack w = .ok s0) :
    s0.pc = 0 ∧ s0.fp = fp ∧ s0.args = args ∧ s0.st.escaped = [] ∧ s0.st.mem = w.mem ∧
      (∀ p ∈ s0.st.zeroSized, 0 ≤ (fp : Int) + p.1 ∧ p.2 = ((fp : Int) + p.1).toNat) ∧
      ∀ o, s0.st.frame o = if 16 ≤ o ∧ o < 16 + (stack.length : Int) then
        stack.getD (o - 16).toNat .uninit else .uninit := by
  unfold R.entry at h
  obtain ⟨zs, hz, h⟩ := ebind_ok h
  dsimp only at h
  obtain ⟨st, hw, h⟩ := ebind_ok h
  simp only [pure, Except.pure, Except.ok.injEq] at h
  subst h
  unfold OpSem.State.writeFrame at hw
  have hwe := writeEscaped_private
    (st := ({ mem := w.mem, exposed := w.exposed, zeroSized := zs } : OpSem.State)) (off := 16)
    (bs := stack) (fun _ _ => rfl)
  rw [hwe] at hw
  simp only [bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
  subst hw
  refine ⟨rfl, rfl, rfl, rfl, rfl, ?_, fun o => ?_⟩
  · intro p hp
    obtain ⟨hlen, hall⟩ := Ryo.Proofs.Inline.mapM_ok hz
    obtain ⟨i, hi, hpi⟩ := List.getElem_of_mem hp
    obtain ⟨a, ha, hp'⟩ := ebind_ok (hall i (by simp at hi; omega) hi)
    simp only [pure, Except.pure, Except.ok.injEq] at hp'
    have hpe : p = (c.zeroSized[i]'(by simp at hi; omega), a) := by
      rw [← hpi]; exact hp'.symm
    subst hpe
    unfold R.frameAddr at ha
    dsimp only at ha
    split at ha
    · first
        | cases ha
        | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at ha
    · rename_i hneg
      simp only [pure, Except.pure, Except.ok.injEq] at ha
      subst ha
      dsimp only
      exact ⟨by omega, rfl⟩
  · simp [OpSem.State.privateIn, OpSem.State.escapedAt]

/-! ## Arithmetic of the entry frame -/

theorem entryFp_eq {S : Setup} (h8 : 8 ≤ S.x0.rsp.toNat) :
    BitVec.ofNat 64 (entryFp S) = S.x0.rsp - 8 := by
  apply BitVec.eq_of_toNat_eq
  have := S.x0.rsp.isLt
  rw [BitVec.toNat_ofNat, BitVec.toNat_sub, show (8 : BitVec 64).toNat = 8 from rfl]
  unfold entryFp
  omega

theorem winAddr_toNat {S : Setup} {n : Nat} (h8 : 8 ≤ S.x0.rsp.toNat)
    (htop : S.x0.rsp.toNat - 8 + n < 2 ^ 64) :
    (S.winAddr (n : Int)).toNat = S.x0.rsp.toNat - 8 + n := by
  unfold Setup.winAddr
  rw [BitVec.ofInt_natCast, BitVec.toNat_add, BitVec.toNat_sub, BitVec.toNat_ofNat,
    show (8 : BitVec 64).toNat = 8 from rfl]
  have := S.x0.rsp.isLt
  omega

theorem read64_keep {m m' : Mem} {a : BitVec 64}
    (h : ∀ j < 8, m' (a + BitVec.ofNat 64 j) = m (a + BitVec.ofNat 64 j)) :
    m'.read64 a = m.read64 a := by
  unfold Mem.read64; congr 1
  apply readNat_congr
  intro i hi
  exact h i hi

theorem intArg_idx_ne {pe : Bool} {i : Nat} (hi : i < (if pe then 4 else 6)) :
    (intArg pe i).idx ≠ 0 ∧ (intArg pe i).idx ≠ 4 ∧ (intArg pe i).idx ≠ 5 ∧
      (intArg pe i).idx ≠ 11 := by
  have h6 : i < 6 := by cases pe <;> simp at hi <;> omega
  have : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨ i = 4 ∨ i = 5 := by omega
  cases pe <;> rcases this with rfl | rfl | rfl | rfl | rfl | rfl <;>
    first | decide | (simp at hi)

section Entry

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- The code stays linked in memory that `Keeps` the entry's. -/
theorem entry_linkOk (H : Hyps S) {m : Mem} (hL : LinkOk S.ctx S.x0.mem S.body S.rs)
    (hm : Keeps S m) : LinkOk S.ctx m S.body S.rs := by
  have hc : ∀ j, j < S.body.code.size → m (addrAt S.ctx j) = S.x0.mem (addrAt S.ctx j) := by
    intro j hj
    obtain ⟨ho, hst, -⟩ := H.codeApart (addrAt S.ctx j) (.inl ⟨j, hj, rfl⟩)
    exact hm _ ho hst
  obtain ⟨hfl, hso, ⟨hl1, hl2⟩, hsm, hfp⟩ := hL
  refine ⟨hfl, hso, ⟨fun j hj hr => ?_, fun r hr k hk => ?_⟩, hsm, hfp⟩
  · rw [hc j hj]; exact hl1 j hj hr
  · rw [hc _ (by have := H.relocsIn r hr; omega)]; exact hl2 r hr k hk

theorem entry_roLoaded (H : Hyps S) {m : Mem} (hR : RoLoaded S.ctx S.x0.mem S.ro)
    (hm : Keeps S m) : RoLoaded S.ctx m S.ro := by
  obtain ⟨base, h1, h2⟩ := hR
  refine ⟨base, h1, fun j hj => ?_⟩
  obtain ⟨ho, hst, -⟩ := H.codeApart (base + BitVec.ofNat 64 j) (.inr ⟨j, hj, (h1 j).symm⟩)
  rw [hm _ ho hst]; exact h2 j hj

/-- The code before the body stays in memory that `Keeps` the entry's. -/
theorem entry_codeAt (H : Hyps S) (hL : LinkOk S.ctx S.x0.mem S.body S.rs) {p q : Nat}
    {items : List Item} (hd : Dec S.body p items q) (hb : Boundary S.rs p) {m : Mem}
    (hm : Keeps S m) : CodeAt S.ctx m items p := by
  refine codeAt_of_agree (hL.dec hd hb).1 fun a ha => ?_
  obtain ⟨j, hj, rfl⟩ := ctr_inCode_dec hL hd hb a ha
  obtain ⟨h1, h2, -⟩ := H.codeApart _ (.inl ⟨j, hj, rfl⟩)
  exact hm _ h1 h2

/-- The frame bytes `[-F + 32, frameLo)` lie below the incoming area. -/
theorem frameLo_le (H : Hyps S) : S.c.d.frameLo S.c.mode ≤ 16 := by
  have h32 : S.c.mode.pe = true → 32 ≤ S.c.d.frameSize := H.peShadow
  have hs : S.c.d.shadowSize S.c.mode ≤ (if S.c.mode.pe then 40 else 0) := by
    unfold R.Decoded.shadowSize
    cases S.c.mode.pe <;> simp <;> split <;> omega
  unfold R.Decoded.frameLo
  cases hpe : S.c.mode.pe
  · rw [hpe] at hs; simp at hs; omega
  · have := h32 hpe; rw [hpe] at hs; simp at hs; omega

/-! ## The relation past the prologue -/

/-- `FrameInv` of R's entry state, from a state past the prologue (all 13 fields). -/
theorem frameInv_entry (H : Hyps S) {args : R.Regs} {stack : List AbstractByte} {w : R.World}
    {s0 : R.RState} {x : X86.State} (hE : EntryEnv S args stack w)
    (hs0 : R.entry S.c (entryFp S) args stack w = .ok s0) (hx : AtBody S x) :
    FrameInv S s0 x := by
  obtain ⟨hpc, hfp0, hargs, hesc, hmem, hzs, hframe⟩ := entry_ok hs0
  obtain ⟨cal, hat⟩ := hE.at_
  have hroom := hE.room
  have htop := hE.top
  have hlen := hE.stackLen
  have hfpdef : entryFp S = S.x0.rsp.toNat - 8 := rfl
  have hK : S.K = 16 + (S.c.argSize : Int) := rfl
  have hFdef : S.F = S.c.d.frameSize := rfl
  have h8 : 8 ≤ S.x0.rsp.toNat := by omega
  have hr64 := S.x0.rsp.isLt
  have hfpv := entryFp_eq (S := S) h8
  have hfw : ∀ o, fpAddr x o = S.winAddr o := fun o => by
    simp only [fpAddr, Setup.winAddr, hx.rbp]
  have hnone : ∀ o, s0.st.escapedAt o = none := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]; rfl
  have hbyte : ∀ o, s0.st.byteAt o = .ok (s0.st.frame o) := fun o => by
    unfold OpSem.State.byteAt; rw [hnone o]; rfl
  -- The window addresses at or above the return address are not on the stack below `x0.rsp`.
  have hns : ∀ n : Nat, 8 ≤ n → n < 16 + S.c.argSize → ¬ InStack S.lo S.x0.rsp (S.winAddr n) := by
    intro n hn1 hn2 ⟨_, hlt⟩
    rw [winAddr_toNat h8 (by omega)] at hlt
    omega
  refine ⟨⟨⟨fun o h1 h2 b hb => ?_, fun e he a _ => ?_, fun p hp => ?_⟩, ?_, ?_⟩,
    fun id a hg hl i hi => ?_, ⟨fun id a o hg hl h1 h2 hin => ?_, fun o _ hu => ?_, ?_, ?_,
      fun e he => ?_⟩, ?_, ?_, ?_, ?_, entry_linkOk H hE.code hx.mem, entry_roLoaded H hE.ro hx.mem,
    fun _ => ?_, ⟨?_, ?_, ?_, fun i hi h5 => ?_⟩, fun o h1 h2 => ⟨hnone o, ?_⟩,
    fun e he => ?_⟩
  -- rrel.rel.frame
  · rw [hbyte o] at hb
    simp only [Except.ok.injEq] at hb
    subst hb
    rw [hframe o]
    split
    · rename_i hin
      obtain ⟨i, rfl⟩ : ∃ i : Nat, o = ((16 + i : Nat) : Int) := ⟨(o - 16).toNat, by omega⟩
      have hi : i < stack.length := by omega
      rw [show (((16 + i : Nat) : Int) - 16).toNat = i by omega]
      have hg : stack.getD i .uninit = stack[i] := by simp [hi]
      rw [hg]
      have hrel := BytesRel.getElem hat.stack i hi (by rw [bytesAt_length]; exact hi)
      rw [getElem_bytesAt] at hrel
      have haddr : S.winAddr ((16 + i : Nat) : Int) =
          BitVec.ofNat 64 (entryFp S + 16) + BitVec.ofNat 64 i := by
        apply BitVec.eq_of_toNat_eq
        rw [winAddr_toNat h8 (by omega), BitVec.toNat_add, BitVec.toNat_ofNat, BitVec.toNat_ofNat]
        omega
      rw [hfw, hx.mem (S.winAddr ((16 + i : Nat) : Int))
        (H.envApart.window ((16 + i : Nat) : Int) (by omega) (by omega))
        (hns (16 + i) (by omega) (by omega)), haddr]
      exact hrel
    · trivial
  -- rrel.rel.layout
  · rw [hesc] at he; simp at he
  -- rrel.rel.zeroSized
  · obtain ⟨h0, hp2⟩ := hzs p hp
    rw [hp2, ofNat_frameAddr _ _ h0, hfpv]
    simp only [fpAddr, hx.rbp]
  -- rrel.rbp
  · rw [hfp0, hfpv]; exact hx.rbp
  -- rrel.wf
  · refine ⟨?_, ?_, ?_, ?_⟩ <;> intro e he <;> rw [hesc] at he <;> simp at he
  -- mem
  · rw [hmem] at hg
    have hr := hat.world id a hg hl i hi
    have hsp := hE.space id a hg hl
    obtain ⟨a1, a2⟩ := hE.allocsApart (BitVec.ofNat 64 (a.addr + i)) ⟨id, a, hg, hl, by
      rw [BitVec.ofNat_add, ctr_add_sub_left, BitVec.toNat_ofNat]
      simp only [Allocation.size] at *
      omega⟩
    rw [hx.mem _ a1 a2]; exact hr
  -- sep.own
  · exact (hE.winFree o h1 h2 ⟨id, a, by rw [← hmem]; exact hg, hl, by rw [← hfw]; exact hin⟩).elim
  -- sep.init
  · rw [hframe o] at hu
    split at hu
    · rename_i hin
      exact ⟨by omega, by omega⟩
    · exact absurd rfl hu
  -- sep.dis
  · unfold MemDisjoint; rw [hmem]; exact hE.dis
  -- sep.space
  · unfold InSpace; rw [hmem]; exact hE.space
  -- sep.esc
  · rw [hesc] at he; simp at he
  -- win
  · rw [hfp0]; omega
  -- fpF
  · rw [hfp0]; omega
  -- rsp
  · rw [hx.rsp, hx.rbp]
  -- room
  · have eF : (BitVec.ofNat 64 S.F).toNat = S.F := by rw [BitVec.toNat_ofNat]; omega
    rw [hx.rsp, BitVec.toNat_sub, BitVec.toNat_sub, eF, show (8 : BitVec 64).toNat = 8 from rfl]
    omega
  -- args
  · rw [hpc, hargs]
    refine argsLive_zero.mpr (hat.args.congr (fun i hi => ?_) (fun i _ => hx.xmm _))
    obtain ⟨n0, n4, n5, n11⟩ := intArg_idx_ne hi
    exact hx.regs _ n0 n4 n5 n11
  -- frame.rbp
  · rw [hx.rbp]; generalize S.x0.rsp = r; bv_decide
  -- frame.retAddr
  · have e : x.reg .rbp + 8 = S.x0.rsp := by rw [hx.rbp]; generalize S.x0.rsp = r; bv_decide
    rw [e]
    apply read64_keep
    intro j hj
    have ea : S.x0.rsp + BitVec.ofNat 64 j = S.winAddr ((8 + j : Nat) : Int) := by
      apply BitVec.eq_of_toNat_eq
      rw [winAddr_toNat h8 (by omega), BitVec.toNat_add, BitVec.toNat_ofNat]
      omega
    rw [ea]
    exact hx.mem (S.winAddr ((8 + j : Nat) : Int))
      (H.envApart.window ((8 + j : Nat) : Int) (by omega) (by omega))
      (hns (8 + j) (by omega) (by omega))
  -- frame.savedRbp
  · rw [hx.rbp]; exact hx.savedRbp
  -- frame.saved
  · have hne : i ≠ 0 ∧ i ≠ 4 ∧ i ≠ 11 := by
      unfold Saved CalleeSaved at hi
      rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;> decide
    exact hx.regs i hne.1 hne.2.1 h5 hne.2.2
  -- slots
  · have := frameLo_le H
    rw [hframe o, if_neg]
    omega
  -- esc
  · rw [hesc] at he; simp at he

/-- `BInv` at R's entry state, from a state past the prologue at the body's start. -/
theorem binv_entry (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {args : R.Regs} {stack : List AbstractByte} {w : R.World} {s0 : R.RState} {x : X86.State}
    (hE : EntryEnv S args stack w) (hs0 : R.entry S.c (entryFp S) args stack w = .ok s0)
    (hx : AtBody S x) (hrip : x.rip = addrAt S.ctx S.body.pos) : BInv S s0 x := by
  obtain ⟨hpc, -⟩ := entry_ok hs0
  refine ⟨frameInv_entry H hE hs0 hx, .inl ⟨?_, ?_⟩⟩
  · rw [hpc, hD.start0]; exact hrip
  · rw [hpc, hD.cache0]; exact CacheInv.emptyPe _ _

/-! ## The machine's run -/

/-- The decoder's entry layout, from `Decodes.entry` (`read_instructions_entry`). -/
theorem entryRead_of_decodes (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hfp : S.c.mode.framePointer = true) : EntryRead S :=
  hD.entry hfp

/-! ### Single items of the entry code -/

/-- An item of the code before the body, read at `p` (a relocation boundary), is in memory that
`Keeps` the entry's. -/
theorem entry_itemAt (H : Hyps S) {args : R.Regs} {stack : List AbstractByte} {w : R.World}
    (hE : EntryEnv S args stack w) {p n : Nat} {i : Item}
    (hdi : decodeItem (atPos S.body p) = some (i, n)) (hb : Boundary S.rs p) {m : Mem}
    (hm : Keeps S m) : ItemAt S.ctx m i p ∧ i.size = n ∧ Boundary S.rs (p + n) := by
  have hL := entry_linkOk H hE.code hm
  obtain ⟨h1, h2, -, h4⟩ := decodeItem_itemAt (c := atPos S.body p) hL.fields hL.sorted
    hL.loaded hL.small hL.fp hb hdi
  exact ⟨h1, h2, h4⟩

theorem entry_canon {i : Item} (hw : ∀ p, i.wf p = true) (ht : ∀ b e, i ≠ .tableEntry b e)
    (pos : Nat) : i.Canonical pos := ⟨ht, .inl (hw _)⟩

/-- `split` of a read over a concatenation. -/
theorem dec_split {c : Cursor} : ∀ {a b : List Item} {p r : Nat}, Dec c p (a ++ b) r →
    ∃ q, Dec c p a q ∧ Dec c q b r
  | [], _, p, _, h => ⟨p, .nil p, h⟩
  | _ :: _, _, _, _, h => by
    cases h with
    | cons hi hr =>
      obtain ⟨q, h1, h2⟩ := dec_split hr
      exact ⟨q, .cons hi h1, h2⟩

/-- `mov eax, v`: only `rax` (and the flags, `rip`) change. -/
theorem exec_setReg_rax (ctx : Ctx) (v : BitVec 64) (s s' : X86.State)
    (h : Item.exec ctx (.setReg .rax v) s = .ok s') :
    s'.rip = s.rip + BitVec.ofNat 64 (Item.setReg .rax v).size ∧
      (∀ i : Fin 16, i ≠ 0 → s'.regs i = s.regs i) ∧ s'.xmm = s.xmm ∧ s'.mem = s.mem := by
  simp only [Item.exec] at h
  split at h
  all_goals
    simp only [pure, Except.pure, Except.ok.injEq] at h
    subst h
    refine ⟨rfl, fun i hi => ?_, rfl, rfl⟩
    show (if i = 0 then _ else s.regs i) = s.regs i
    rw [if_neg hi]

/-- `sub rsp, F`'s immediate: below `2 ^ 31` it sign-extends to `F`. -/
theorem signExtend_F {F : Nat} (h : F < 2 ^ 31) :
    (BitVec.ofNat 32 F).signExtend 64 = BitVec.ofNat 64 F := by
  have hlt : BitVec.ofNat 32 F < 2147483648 := by
    rw [BitVec.lt_def, BitVec.toNat_ofNat, show (2147483648 : BitVec 32).toNat = 2147483648 from rfl]
    omega
  have e : BitVec.ofNat 64 F = (BitVec.ofNat 32 F).setWidth 64 := by
    apply BitVec.eq_of_toNat_eq
    rw [BitVec.toNat_setWidth, BitVec.toNat_ofNat, BitVec.toNat_ofNat]
    omega
  rw [e]
  generalize BitVec.ofNat 32 F = b at hlt ⊢
  bv_decide

/-- The stack below `x0.rsp - 8` is within the stack below `x0.rsp`. -/
theorem inStack_mono {S : Setup} (h8 : 8 ≤ S.x0.rsp.toNat) {a : BitVec 64}
    (h : ¬ InStack S.lo S.x0.rsp a) : ¬ InStack S.lo (S.x0.rsp - 8) a := by
  intro ⟨h1, h2⟩
  apply h
  refine ⟨h1, ?_⟩
  rw [BitVec.toNat_sub, show (8 : BitVec 64).toNat = 8 from rfl] at h2
  have := S.x0.rsp.isLt
  omega

/-- After `push rbp; mov rbp, rsp` (and the probe): `rbp = rsp = x0.rsp - 8` with the caller's
`rbp` saved there, the other registers but `rax`, `r11` and every `xmm` as at entry, memory
otherwise kept. -/
structure AtFrame (S : Setup) (z : X86.State) : Prop where
  rbp : z.reg .rbp = S.x0.rsp - 8
  rsp : z.rsp = S.x0.rsp - 8
  regs : ∀ i : Fin 16, i ≠ 0 → i ≠ 4 → i ≠ 5 → i ≠ 11 → z.regs i = S.x0.regs i
  xmm : ∀ i, z.xmm i = S.x0.xmm i
  savedRbp : z.mem.read64 (S.x0.rsp - 8) = S.x0.reg .rbp
  mem : Keeps S z.mem

theorem atBody_of_atFrame_zero {z : X86.State} (hz : AtFrame S z) (hF : S.F = 0) : AtBody S z :=
  ⟨hz.rbp, by rw [hz.rsp, hF]; simp, fun i h0 h4 h5 h11 => hz.regs i h0 h4 h5 h11, hz.xmm,
    hz.savedRbp, hz.mem⟩

/-- `push rbp; mov rbp, rsp`. -/
theorem entry_pushMov (H : Hyps S) {args : R.Regs} {stack : List AbstractByte} {w : R.World}
    (hE : EntryEnv S args stack w) {p1 p2 : Nat}
    (hd : Dec S.body p1 [.pushRbp, .mov .rbp .rsp] p2) (hb : Boundary S.rs p1)
    {y : X86.State} (hy : AtCheck S y) (hrip : y.rip = addrAt S.ctx p1) {Q : X86.State → Prop}
    (k : ∀ z, AtFrame S z → z.rip = addrAt S.ctx p2 → Boundary S.rs p2 → Reach S.ctx S.E Q z) :
    Reach S.ctx S.E Q y := by
  have hroom := hE.room
  have hlo8 : S.lo.toNat + 8 ≤ S.x0.rsp.toNat := by omega
  rcases hd with _ | ⟨hd1, _ | ⟨hd2, _ | _⟩⟩
  rename_i n1 n2
  have hy4 : y.rsp = S.x0.rsp := hy.regs 4 (by decide) (by decide)
  have hy5 : y.reg .rbp = S.x0.reg .rbp := hy.regs 5 (by decide) (by decide)
  obtain ⟨hi1, hs1, hb1⟩ := entry_itemAt H hE hd1 hb hy.mem
  -- `push rbp`
  obtain ⟨y1, hy1⟩ : ∃ y1, y1 =
      (y.jump (y.rip + BitVec.ofNat 64 Item.pushRbp.size)).push (y.reg .rbp) := ⟨_, rfl⟩
  have he1 : Item.exec S.ctx .pushRbp y = .ok y1 := by rw [hy1]; rfl
  have r1 : y1.rip = addrAt S.ctx (p1 + n1) := by
    rw [hy1]; show y.rip + BitVec.ofNat 64 Item.pushRbp.size = _; rw [hrip, hs1, addrAt_add]
  have g1 : ∀ i : Fin 16, y1.regs i = if i = 4 then S.x0.rsp - 8 else y.regs i := by
    intro i; rw [hy1, ← hy4]; rfl
  have x1 : y1.xmm = y.xmm := by rw [hy1]; rfl
  have m1 : y1.mem = y.mem.write (S.x0.rsp - 8) 8 (S.x0.reg .rbp).toNat := by
    rw [hy1, ← hy4, ← hy5]; rfl
  have hk1 : Keeps S y1.mem := fun a ho hs => by
    rw [m1, Mem.write_other _ _ _ _ _ (ctr_push_other _ _ _ hlo8 hs)]; exact hy.mem a ho hs
  -- `mov rbp, rsp`
  obtain ⟨hi2, hs2, hb2⟩ := entry_itemAt H hE hd2 hb1 hk1
  obtain ⟨y2, hy2⟩ : ∃ y2, y2 = (y1.jump (y1.rip + BitVec.ofNat 64 (Item.mov .rbp .rsp).size)).setReg
      .rbp (y1.reg .rsp) := ⟨_, rfl⟩
  have he2 : Item.exec S.ctx (.mov .rbp .rsp) y1 = .ok y2 := by rw [hy2]; rfl
  have y1rsp : y1.reg .rsp = S.x0.rsp - 8 := by
    show y1.regs 4 = _; rw [g1, if_pos (rfl : (4 : Fin 16) = 4)]
  refine Reach.step (.exec _ p1 (entry_canon (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h) _)
    hi1 hrip he1) ?_
  refine Reach.step (.exec _ (p1 + n1)
    (entry_canon (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h) _) hi2 r1 he2) ?_
  refine k y2 ⟨?_, ?_, fun i h0 h4 h5 h11 => ?_, fun i => ?_, ?_, ?_⟩ ?_ hb2
  · rw [hy2, State.reg_setReg]; exact y1rsp
  · rw [hy2]; show y1.regs 4 = _
    rw [g1, if_pos (rfl : (4 : Fin 16) = 4)]
  · rw [hy2]; show (if i = 5 then _ else y1.regs i) = _
    rw [if_neg h5, g1, if_neg h4]; exact hy.regs i h0 h11
  · rw [hy2]; show y1.xmm i = _; rw [x1]; exact hy.xmm i
  · rw [hy2]; show y1.mem.read64 _ = _; rw [m1]
    exact Ryo.Proofs.IslandLemmas.read64_write_self _ _ _
  · rw [hy2]; exact hk1
  · rw [hy2]; show y1.rip + BitVec.ofNat 64 (Item.mov .rbp .rsp).size = _
    rw [r1, hs2, addrAt_add']

/-- `mov eax, v; call probe`, and the probe's return. -/
theorem entry_probe (H : Hyps S) (hC : EntryContract S) {args : R.Regs}
    {stack : List AbstractByte} {w : R.World} (hE : EntryEnv S args stack w) {p q : Nat}
    {v : BitVec 64} (hd : Dec S.body p [.setReg .rax v, .call .probe] q) (hb : Boundary S.rs p)
    {z : X86.State} (hz : AtFrame S z) (hrip : z.rip = addrAt S.ctx p) {Q : X86.State → Prop}
    (k : ∀ z', AtFrame S z' → z'.rip = addrAt S.ctx q → Boundary S.rs q → Reach S.ctx S.E Q z') :
    Reach S.ctx S.E Q z := by
  have hroom := hE.room
  have hr64 := S.x0.rsp.isLt
  have h8 : 8 ≤ S.x0.rsp.toNat := by omega
  have hlo16 : S.lo.toNat + 8 ≤ (S.x0.rsp - 8).toNat := by
    rw [BitVec.toNat_sub, show (8 : BitVec 64).toNat = 8 from rfl]; omega
  rcases hd with _ | ⟨hd1, _ | ⟨hd2, _ | _⟩⟩
  rename_i n1 n2
  obtain ⟨hi1, hs1, hb1⟩ := entry_itemAt H hE hd1 hb hz.mem
  -- `mov eax, v`
  obtain ⟨z1, he1⟩ : ∃ z1, Item.exec S.ctx (.setReg .rax v) z = .ok z1 := by
    simp only [Item.exec]; split <;> exact ⟨_, rfl⟩
  obtain ⟨r1, g1, x1, m1⟩ := exec_setReg_rax S.ctx v z z1 he1
  have hk1 : Keeps S z1.mem := by rw [m1]; exact hz.mem
  obtain ⟨hi2, hs2, hb2⟩ := entry_itemAt H hE hd2 hb1 hk1
  have r1' : z1.rip = addrAt S.ctx (p + n1) := by rw [r1, hrip, hs1, addrAt_add]
  have z1rsp : z1.rsp = S.x0.rsp - 8 := by
    show z1.regs 4 = _; rw [g1 4 (by decide)]; exact hz.rsp
  -- `call probe`
  obtain ⟨z2, hz2⟩ : ∃ z2, z2 = ((z1.jump (z1.rip + BitVec.ofNat 64 (Item.call .probe).size)).push
      (z1.rip + BitVec.ofNat 64 (Item.call .probe).size)).jump (S.ctx.addrOf .probe) := ⟨_, rfl⟩
  have he2 : Item.exec S.ctx (.call .probe) z1 = .ok z2 := by rw [hz2]; rfl
  have nxt : z1.rip + BitVec.ofNat 64 (Item.call .probe).size = addrAt S.ctx (p + n1 + n2) := by
    rw [r1', hs2, addrAt_add']
  have z2rip : z2.rip = S.ctx.addrOf .probe := by rw [hz2]; rfl
  have z2rsp : z2.rsp = z1.rsp - 8 := by
    rw [hz2]; rfl
  have z2regs : ∀ i : Fin 16, i ≠ 4 → z2.regs i = z1.regs i := by
    intro i hi; rw [hz2]; show (if i = 4 then _ else z1.regs i) = _; rw [if_neg hi]
  have z2x : z2.xmm = z1.xmm := by rw [hz2]; rfl
  have z2m : z2.mem = z1.mem.write (z1.rsp - 8) 8 (addrAt S.ctx (p + n1 + n2)).toNat := by
    rw [hz2, ← nxt]; rfl
  have z2ret : z2.mem.read64 z2.rsp = addrAt S.ctx (p + n1 + n2) := by
    rw [z2m, z2rsp]; exact Ryo.Proofs.IslandLemmas.read64_write_self _ _ _
  have z2rsp8 : z2.rsp + 8 = S.x0.rsp - 8 := by
    rw [z2rsp, z1rsp]; exact BitVec.sub_add_cancel _ _
  refine Reach.step (.exec _ p (entry_canon (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h) _)
    hi1 hrip he1) ?_
  refine Reach.step (.exec _ (p + n1)
    (entry_canon (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h) _) hi2 r1' he2) ?_
  refine .env (hC.probe.out z2 z2rip) fun z3 hret => ?_
  have P := hC.probe
  have r3 : z3.rip = addrAt S.ctx (p + n1 + n2) := by rw [P.rip z2 z3 z2rip hret, z2ret]
  have rsp3 : z3.rsp = S.x0.rsp - 8 := by rw [P.rsp z2 z3 z2rip hret, z2rsp8]
  have g3 : ∀ i : Fin 16, i ≠ 0 → i ≠ 4 → i ≠ 11 → z3.regs i = z.regs i := fun i h0 h4 h11 => by
    rw [P.regs z2 z3 z2rip hret i h4 h11, z2regs i h4, g1 i h0]
  have keep3 : ∀ a, ¬ S.Owned a → ¬ InStack S.lo (S.x0.rsp - 8) a → z3.mem a = z.mem a := by
    intro a ho hs
    rw [P.mem z2 z3 z2rip hret (by rw [z2rsp8]; exact hlo16) a ho (by rw [z2rsp8]; exact hs),
      z2m, z1rsp, Mem.write_other _ _ _ _ _ (ctr_push_other _ _ _ hlo16 hs), m1]
  have sv3 : z3.mem.read64 (S.x0.rsp - 8) = S.x0.reg .rbp := by
    rw [← hz.savedRbp]
    apply read64_keep
    intro j hj
    have ea : S.x0.rsp - 8 + BitVec.ofNat 64 j = S.winAddr (j : Int) := by
      unfold Setup.winAddr; rw [BitVec.ofInt_natCast]
    rw [ea]
    refine keep3 _ (H.envApart.window (j : Int) (by omega)
      (by show (j : Int) < 16 + (S.c.argSize : Int); omega)) ?_
    intro ⟨_, h2⟩
    rw [winAddr_toNat h8 (by omega), BitVec.toNat_sub,
      show (8 : BitVec 64).toNat = 8 from rfl] at h2
    omega
  refine k z3 ⟨?_, rsp3, fun i h0 h4 h5 h11 => ?_, fun i => ?_, sv3, fun a ho hs => ?_⟩ r3 hb2
  · show z3.regs 5 = _; rw [g3 5 (by decide) (by decide) (by decide)]; exact hz.rbp
  · rw [g3 i h0 h4 h11]; exact hz.regs i h0 h4 h5 h11
  · rw [P.xmm z2 z3 z2rip hret i, z2x, x1]; exact hz.xmm i
  · rw [keep3 a ho (inStack_mono h8 hs)]; exact hz.mem a ho hs

/-- `sub rsp, F`. -/
theorem entry_sub (H : Hyps S) (hC : EntryContract S) {args : R.Regs}
    {stack : List AbstractByte} {w : R.World} (hE : EntryEnv S args stack w) {p q : Nat}
    (hd : Dec S.body p [.subRsp (BitVec.ofNat 32 S.F)] q) (hb : Boundary S.rs p)
    {z : X86.State} (hz : AtFrame S z) (hrip : z.rip = addrAt S.ctx p) {Q : X86.State → Prop}
    (k : ∀ x, AtBody S x → x.rip = addrAt S.ctx q → Reach S.ctx S.E Q x) :
    Reach S.ctx S.E Q z := by
  rcases hd with _ | ⟨hd1, _ | _⟩
  rename_i n1
  obtain ⟨hi1, hs1, -⟩ := entry_itemAt H hE hd1 hb hz.mem
  obtain ⟨z1, hz1⟩ : ∃ z1, z1 = ((z.jump (z.rip + BitVec.ofNat 64
      (Item.subRsp (BitVec.ofNat 32 S.F)).size)).setReg .rsp
      (z.rsp - (BitVec.ofNat 32 S.F).signExtend 64)).setFlags
      (subF z.rsp ((BitVec.ofNat 32 S.F).signExtend 64)).2 := ⟨_, rfl⟩
  have he1 : Item.exec S.ctx (.subRsp (BitVec.ofNat 32 S.F)) z = .ok z1 := by rw [hz1]; rfl
  have hsx := signExtend_F hC.frameSmall
  have g1 : ∀ i : Fin 16, i ≠ 4 → z1.regs i = z.regs i := fun i hi => by
    rw [hz1]; show (if i = 4 then _ else z.regs i) = _; rw [if_neg hi]
  refine Reach.step (.exec _ p (entry_canon (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h) _)
    hi1 hrip he1) (k z1 ⟨?_, ?_, fun i h0 h4 h5 h11 => ?_, fun i => ?_, ?_, ?_⟩ ?_)
  · show z1.regs 5 = _; rw [g1 5 (by decide)]; exact hz.rbp
  · have e : z1.rsp = z.rsp - (BitVec.ofNat 32 S.F).signExtend 64 := by rw [hz1]; rfl
    rw [e, hsx, hz.rsp]
  · rw [g1 i h4]; exact hz.regs i h0 h4 h5 h11
  · rw [hz1]; exact hz.xmm i
  · rw [hz1]; exact hz.savedRbp
  · rw [hz1]; exact hz.mem
  · rw [hz1]; show z.rip + BitVec.ofNat 64 _ = _; rw [hrip, hs1, addrAt_add]

/-- The entry's counter check: from `x0`, the machine reaches the check's end `p1` (a relocation
boundary) in a state `AtCheck` (whatever the trip does). Without counters there is no code
(`p1 = 0`). With them, as `reach_counter`: the check (`Counter.check_effect`; the counter is
runtime-owned, `EntryContract.ctrOwned`) falls through to `p1` or branches to the stub, whose
`call [r11 + 8]` is an environment state (`H.envOutside.trip`; the slot is off the stack,
`slotOff`) returning (`H.trip`, `EntryTripKeeps` for the other registers and the `xmm`s) to its
`jmp p1`. -/
theorem reach_entryCheck (H : Hyps S) (hC : EntryContract S) {args : R.Regs}
    {stack : List AbstractByte} {w : R.World} (hE : EntryEnv S args stack w) {p1 : Nat}
    (hchk : CheckRead S p1) {Q : X86.State → Prop}
    (kont : ∀ y, AtCheck S y → y.rip = addrAt S.ctx p1 → Boundary S.rs p1 → Reach S.ctx S.E Q y) :
    Reach S.ctx S.E Q S.x0 := by
  by_cases hc : S.c.mode.counters = true
  · obtain ⟨t, l, tb, bl, qs, hdec, htb, hbs', hdecs⟩ := hchk.2 hc
    have hL := hE.code
    have hbs : Boundary S.rs t.toNat := hbs' _ hL
    have hroom := hE.room
    have hlo8 : S.lo.toNat + 8 ≤ S.x0.rsp.toNat := by omega
    have hsp : S.body.spFrame = none := hL.fp
    obtain ⟨hca, -, hbp1⟩ := hL.dec hdec (boundary_zero _)
    have hap : ∀ a, InCode S.ctx (Counter.check false t l) 0 a → ¬ S.Owned a := by
      intro a ha
      obtain ⟨j, hj, rfl⟩ := ctr_inCode_dec hL hdec (boundary_zero _) a ha
      exact (H.codeApart _ (.inl ⟨j, hj, rfl⟩)).1
    have hdec0 := hdec
    rcases hdec0 with _ | ⟨hd1, _ | ⟨hd2, _ | _⟩⟩
    rename_i n1 n2
    obtain ⟨-, hs1, -, hb1⟩ := decodeItem_itemAt (c := atPos S.body 0) hL.fields hL.sorted
      hL.loaded hL.small hL.fp (boundary_zero _) hd1
    obtain ⟨-, hs2, -, -⟩ := decodeItem_itemAt (c := atPos S.body (0 + n1)) hL.fields hL.sorted
      hL.loaded hL.small hL.fp hb1 hd2
    have hcan2 := branch_canonical hsp hd2
    rw [← hs1] at hcan2
    -- The counter is runtime-owned: everything else is kept by the check.
    have hctr : ∀ a, ¬ S.Owned a → 8 ≤ (a - Counter.ctrAddr S.ctx false).toNat := by
      intro a ho
      apply Classical.byContradiction
      intro hlt
      apply ho
      have e : a = Counter.ctrAddr S.ctx false +
          BitVec.ofNat 64 (a - Counter.ctrAddr S.ctx false).toNat := by
        rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]; bv_omega
      rw [e]
      exact hC.ctrOwned _ (by omega)
    obtain ⟨x', hx⟩ := Counter.check_ok S.ctx false t l S.x0
    have hrun : FetchRun S.ctx (InCode S.ctx (Counter.check false t l) 0) [.ctrInc false] S.x0 := by
      intro y hy
      rw [Counter.exec_ctrInc] at hy
      cases hy
      exact ⟨rfl, fun a ha => Mem.write_other _ _ _ _ _ (hctr a (hap a ha)), trivial⟩
    have hsteps : Steps S.ctx S.x0 x' :=
      steps_of_run_last (items := [.ctrInc false]) (j := .branch .ns t l)
        ⟨ctr_simple_canonical _ rfl (fun _ _ => rfl) (fun _ _ h => by cases h) _, hcan2, trivial⟩
        hca hE.rip (fun _ h => h) hrun hx
    obtain ⟨hregs, hxmm, hmem, hrip'⟩ := Counter.check_effect S.ctx false t l S.x0 x' hx
    have hk' : Keeps S x'.mem := fun a ho _ => hmem a (hctr a ho)
    have hafter : Counter.after S.x0.rip false t l = addrAt S.ctx (0 + n1 + n2) := by
      rw [hE.rip]
      simp only [Counter.after, Counter.checkLen, hs1, hs2]
      rw [addrAt_add' S.ctx 0, Nat.add_assoc]
    by_cases hmsb : (Counter.incremented S.ctx false S.x0).msb = true
    · -- Not taken: past the check.
      have hr : x'.rip = addrAt S.ctx (0 + n1 + n2) := by rw [hrip', if_pos hmsb, hafter]
      exact Reach.steps hsteps
        (kont x' ⟨fun i _ _ => by rw [hregs], fun i => by rw [hxmm], hk'⟩ hr hbp1)
    -- Taken: the entry stub, the trip, `jmp` back.
    have hrs : x'.rip = addrAt S.ctx t.toNat := by
      rw [hrip', if_neg hmsb, ctr_base_setWidth]
    have hxsp : x'.rsp = S.x0.rsp := by show x'.regs 4 = _; rw [hregs]; rfl
    obtain ⟨hcs, -, -⟩ := (entry_linkOk H hE.code hk').dec hdecs hbs
    have hdecs0 := hdecs
    rcases hdecs0 with _ | ⟨hs1d, _ | ⟨hs2d, _ | ⟨hs3d, _ | _⟩⟩⟩
    rename_i m1 m2 m3
    obtain ⟨-, e1, -, b1⟩ := decodeItem_itemAt (c := atPos S.body t.toNat) hL.fields hL.sorted
      hL.loaded hL.small hL.fp hbs hs1d
    obtain ⟨-, e2, -, -⟩ := decodeItem_itemAt (c := atPos S.body (t.toNat + m1)) hL.fields
      hL.sorted hL.loaded hL.small hL.fp b1 hs2d
    have hcan3 := branch_canonical hsp hs3d
    rw [← e1, ← e2] at hcan3
    obtain ⟨i1, i2, -, -⟩ := hcs
    have hlea := ctr_simple_canonical (.lea .r11 .record) rfl (fun _ _ => rfl)
      (fun _ _ h => by cases h)
    have hcall := ctr_simple_canonical (.callR11 8) rfl (fun _ _ => rfl) (fun _ _ h => by cases h)
    -- `lea r11, [record]`
    obtain ⟨y1, hy1⟩ : ∃ y1, y1 = (x'.jump (x'.rip + BitVec.ofNat 64
        (Item.lea .r11 .record).size)).setReg .r11 (S.ctx.addrOf .record) := ⟨_, rfl⟩
    have he1 : (Item.lea .r11 .record).exec S.ctx x' = .ok y1 := by rw [hy1]; rfl
    have st1 : Step S.ctx x' y1 := .exec _ t.toNat (hlea _) i1 hrs he1
    have hy1rip : y1.rip = addrAt S.ctx (t.toNat + (Item.lea .r11 .record).size) := by
      rw [hy1, ← addrAt_add', ← hrs]; rfl
    have hy1r11 : y1.reg .r11 = S.ctx.addrOf .record := by rw [hy1]; exact State.reg_setReg _ _ _
    have hy1g : ∀ i : Fin 16, i ≠ 11 → y1.regs i = x'.regs i := fun i hi => by
      rw [hy1]; show (if i = 11 then _ else x'.regs i) = _; rw [if_neg hi]
    have hy1m : y1.mem = x'.mem := by rw [hy1]; rfl
    have hy1x : y1.xmm = x'.xmm := by rw [hy1]; rfl
    have hy1sp : y1.rsp = S.x0.rsp := by
      show y1.regs 4 = _; rw [hy1g 4 (by decide)]; exact hxsp
    -- `call [r11 + 8]`
    obtain ⟨y2, hy2⟩ : ∃ y2, y2 = ((y1.jump (y1.rip + BitVec.ofNat 64 (Item.callR11 8).size)).push
        (y1.rip + BitVec.ofNat 64 (Item.callR11 8).size)).jump
        (y1.mem.read64 (y1.reg .r11 + (8 : BitVec 8).signExtend 64)) := ⟨_, rfl⟩
    have he2 : (Item.callR11 8).exec S.ctx y1 = .ok y2 := by rw [hy2]; rfl
    have st2 : Step S.ctx y1 y2 := .exec _ _ (hcall _) (by rw [hy1m]; exact i2) hy1rip he2
    have hy2sp : y2.rsp = S.x0.rsp - 8 := by
      have e : y2.rsp = y1.rsp - 8 := by rw [hy2]; rfl
      rw [e, hy1sp]
    have hy2g : ∀ i : Fin 16, i ≠ 4 → y2.regs i = y1.regs i := fun i hi => by
      rw [hy2]; show (if i = 4 then _ else y1.regs i) = _; rw [if_neg hi]
    have hy2x : y2.xmm = y1.xmm := by rw [hy2]; rfl
    have hnext : y1.rip + BitVec.ofNat 64 (Item.callR11 8).size = addrAt S.ctx
        (t.toNat + (Item.lea .r11 .record).size + (Item.callR11 8).size) := by
      rw [hy1rip, addrAt_add']
    have hy2m : y2.mem = y1.mem.write (S.x0.rsp - 8) 8 (addrAt S.ctx
        (t.toNat + (Item.lea .r11 .record).size + (Item.callR11 8).size)).toNat := by
      rw [hy2, ← hnext, ← hy1sp]; rfl
    have hkeep2 : ∀ a, ¬ InStack S.lo S.x0.rsp a → y2.mem a = x'.mem a := by
      intro a ha
      rw [hy2m, Mem.write_other _ _ _ _ _ (ctr_push_other _ _ _ hlo8 ha), hy1m]
    have hy2rip : y2.rip = y2.mem.read64 (S.ctx.addrOf .record + BitVec.ofNat 64 8) := by
      have h1 : y2.rip = y1.mem.read64 (S.ctx.addrOf .record + BitVec.ofNat 64 8) := by
        rw [hy2]; show y1.mem.read64 (y1.reg .r11 + (8 : BitVec 8).signExtend 64) = _
        rw [hy1r11, show (8 : BitVec 8).signExtend 64 = BitVec.ofNat 64 8 by decide]
      rw [h1]
      apply read64_keep
      intro j hj
      rw [hkeep2 _ (hC.slotOff j hj), hy1m]
    have hout : S.E.out y2 := H.envOutside.trip y2 ⟨8, hy2rip⟩
    refine Reach.steps hsteps (.step st1 (.step st2 (.env hout fun y3 hret => ?_)))
    -- The trip's return, `jmp` back.
    have hy2sp8 : y2.rsp + 8 = S.x0.rsp := by rw [hy2sp]; exact BitVec.sub_add_cancel _ _
    obtain ⟨tg, tx⟩ := hC.trip y2 y3 hy2rip hret
    have hy3rip : y3.rip = addrAt S.ctx
        (t.toNat + (Item.lea .r11 .record).size + (Item.callR11 8).size) := by
      rw [H.trip.ret_rip _ _ hret, hy2m, hy2sp]
      exact Ryo.Proofs.IslandLemmas.read64_write_self _ _ _
    have hy3sp : y3.rsp = S.x0.rsp := by rw [H.trip.ret_rsp _ _ hret, hy2sp8]
    have hk3 : Keeps S y3.mem := fun a ho hs => by
      rw [H.trip.ret_mem _ _ hret (by rw [hy2sp8]; exact hlo8) a ho (by rw [hy2sp8]; exact hs),
        hkeep2 a hs]
      exact hk' a ho hs
    obtain ⟨⟨-, -, i3, -⟩, -, -⟩ := (entry_linkOk H hE.code hk3).dec hdecs hbs
    obtain ⟨y4, he4, hy4⟩ : ∃ y4, (Item.branch .always tb bl).exec S.ctx y3 = .ok y4 ∧
        y4 = y3.jump (S.ctx.base + tb.setWidth 64) :=
      ⟨_, by first
        | rfl
        | simp [Item.exec, Cond.eval, bind, Except.bind, pure, Except.pure, State.jump], rfl⟩
    have st4 : Step S.ctx y3 y4 := .exec _ _ hcan3 i3 hy3rip he4
    refine .step st4 (kont y4 ⟨fun i h0 h11 => ?_, fun i => ?_, ?_⟩ ?_ hbp1)
    · rw [hy4]
      show y3.regs i = _
      by_cases h4 : i = 4
      · subst h4; exact hy3sp
      · rw [tg i h0 h4 h11, hy2g i h4, hy1g i h11, hregs]
    · rw [hy4]; show y3.xmm i = _; rw [tx i, hy2x, hy1x, hxmm]
    · rw [hy4]; exact hk3
    · rw [hy4]; show S.ctx.base + tb.setWidth 64 = _; rw [ctr_base_setWidth, htb]
  · have hp1 : p1 = 0 := hchk.1 (by simpa using hc)
    subst hp1
    exact kont S.x0 ⟨fun _ _ _ => rfl, fun _ => rfl, fun _ _ _ => rfl⟩ hE.rip (boundary_zero _)

/-- The prologue `push rbp; mov rbp, rsp; [mov eax, F; call probe]; [sub rsp, F]` (frame-
pointer form, `H.fp`) from a state `AtCheck` at `p1` reaches the body's start in a state
`AtBody` (whatever the probe does): each item is canonical (`Item.wf` is `true` for all
five), in memory by `entry_codeAt`, and executed by `Step.exec`; `push rbp` writes
`[x0.rsp - 8, x0.rsp)` (on the stack below `x0.rsp`, so `Keeps`, and apart from the code by
`H.codeApart`); `call probe` is an environment state (`ProbeContract.out`) whose returns
(`ProbeContract`, its memory clause with `lo + 8 ≤ x0.rsp - 8` from `EntryEnv.room`) come back
at `sub rsp, F` (`ProbeContract.rip` and the pushed return address) with `rbp`, the saved `rbp`
(window offsets `[0, 8)`, `H.envApart.window`) and the other registers kept; `sub rsp, F`'s
immediate sign-extends to `F` (`EntryContract.frameSmall`). -/
theorem reach_prologue (H : Hyps S) (hC : EntryContract S) {args : R.Regs}
    {stack : List AbstractByte} {w : R.World} (hE : EntryEnv S args stack w) {p1 : Nat}
    (hpro : Dec S.body p1 (prologue S.F S.c.mode) S.body.pos) (hb : Boundary S.rs p1)
    {y : X86.State} (hy : AtCheck S y) (hrip : y.rip = addrAt S.ctx p1) :
    Reach S.ctx S.E (fun x => AtBody S x ∧ x.rip = addrAt S.ctx S.body.pos) y := by
  have hfp := H.fp
  unfold prologue at hpro
  simp only [hfp, ↓reduceIte] at hpro
  obtain ⟨q, hAB, hC'⟩ := dec_split hpro
  obtain ⟨p2, hA, hB⟩ := dec_split hAB
  refine entry_pushMov H hE hA hb hy hrip fun z hz hz2 hb2 => ?_
  have kfin : ∀ z', AtFrame S z' → z'.rip = addrAt S.ctx q → Boundary S.rs q →
      Reach S.ctx S.E (fun x => AtBody S x ∧ x.rip = addrAt S.ctx S.body.pos) z' := by
    intro z' hz' hr' hb'
    split at hC'
    · exact entry_sub H hC hE hC' hb' hz' hr' fun x hx hxr => .done ⟨hx, hxr⟩
    · rename_i hF
      have hF0 : S.F = 0 := by simpa using hF
      exact .done ⟨atBody_of_atFrame_zero hz' hF0, by rw [hC'.nil_eq]; exact hr'⟩
  split at hB
  · exact entry_probe H hC hE hB hb2 hz hz2 kfin
  · exact kfin z hz (by rw [hB.nil_eq]; exact hz2) (by rw [hB.nil_eq]; exact hb2)

/-! ## The entry step -/

/-- **The entry step** (frame-pointer mode, `H.fp`): from the function's entry `x0`, whatever
the environment does (the entry trip, the probe), the fetching machine reaches a state related
(`BInv`) to R's entry state `R.entry S.c (x0.rsp - 8) args stack w`, given the decoder's entry
layout (`EntryRead`), the environment's contracts (`EntryContract`) and the caller's call
(`EntryEnv`, with `EntryAt`). -/
theorem reach_entry (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (hR : EntryRead S) (hC : EntryContract S) {args : R.Regs}
    {stack : List AbstractByte} {w : R.World} {s0 : R.RState} (hE : EntryEnv S args stack w)
    (hs0 : R.entry S.c (entryFp S) args stack w = .ok s0) :
    Reach S.ctx S.E (BInv S s0) S.x0 := by
  obtain ⟨p1, hchk, hpro⟩ := hR
  refine reach_entryCheck H hC hE hchk fun y hy hrip hb => ?_
  exact (reach_prologue H hC hE hpro hb hy hrip).mono fun x ⟨hx, hxr⟩ =>
    binv_entry hD H hE hs0 hx hxr

/-- `reach_entry` with the decoder's layout from `Decodes` (`entryRead_of_decodes`). -/
theorem reach_entry' (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (hC : EntryContract S) {args : R.Regs} {stack : List AbstractByte}
    {w : R.World} {s0 : R.RState} (hE : EntryEnv S args stack w)
    (hs0 : R.entry S.c (entryFp S) args stack w = .ok s0) :
    Reach S.ctx S.E (BInv S s0) S.x0 :=
  reach_entry hD H (entryRead_of_decodes hD H.fp) hC hE hs0

/-- The function from its entry: the entry step, then `decode_sound` from the boundary it
reaches, for R runs from the entry state that are safe. -/
theorem entry_sound (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (htc : tablesCheck code relocs rodata callSites dropped scopes mode = true)
    (hC : EntryContract S) {args : R.Regs} {stack : List AbstractByte} {w : R.World}
    {s0 : R.RState} (hE : EntryEnv S args stack w)
    (hs0 : R.entry S.c (entryFp S) args stack w = .ok s0) (hsafe : SafeFrom S.Safe S.c s0) :
    Reach S.ctx S.E (fun x => BInv S s0 x ∧ FnSim S.ctx S.E S.c (BInv S) (ExitRel S) s0 x)
      S.x0 :=
  (reach_entry' hD H hC hE hs0).mono fun x hx => ⟨hx, decode_sound hD H htc s0 x hx hsafe⟩

end Entry

end Ryo.Proofs.DecodeSound
