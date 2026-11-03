/-
Ryo.Proofs.Island — the shape `island isl, ops` (aot.md §C2 "Shapes", toward M3
`decode_sound`): R's step (`Ryo.Vm.R.Sem`: the scopes, then a `Query`
`.island isl template fp ops lends`, continued by `answer`, which writes the answer's bytes over
the `Lend` extents) against the items `DecodeReduced.islandCall` accepts.

**Items** (`islandPre`): `fp` into the first argument register (`fpItem`: `mov rdi,
rbp`; PE `rcx`), `lea rsi, [rip + ops]` (PE
`rdx`; `ops` the rodata offset of the operand array: a `u32` count at `ops - 4`, then one `i32`
slot per operand, `DecodeReduced.opsArray`), `call [rip + isl]`; nothing after it. The call leaves `rsp` alone:
on PE every frame reserves its callees' 32-byte shadow space at its own bottom.

**The island boundary** (`IslandAt`, the template's entry, just after the `call`): `rip` the
address in the island's symbol slot, `fp` in the first argument register (and in `rbp`), the
operand array at the second (`OpsAt`: the count and the query's slots), the frame relation
(`Rel st x` for the waiting R state's `st`) and the world relation (`Call.WorldRel`). The frame
relation is in the boundary because a template reads its operands at `fp + ops[i]`, private
frame bytes the R query doesn't carry: what a template computes from them is its own contract
(`Ryo.Vm.R.Islands` has the operand roles; the functional part is to come), stated against the
R state; this file only needs the frame-level part.

**The environment's contract** (`IslandContract`, trusted, in the style of `Call.CallContract`):
`Ret x x'` / `Unw x x'` relate the template's entry to its return / to where unwinding out of
it lands in this frame. Each corresponds to an R answer `a` (`IslandEnd`): one byte list per
`Lend` extent, each related to the x86 bytes at `fp + off` (R then makes the PE shadow space
`Uninit`, `R.Code.islandWrites`: `answer_core`); the answer's world related to `x'`
and extending the query's (`Call.Extends`); x86 memory changed only at `IslandMayWrite`
addresses: the stack below the caller's `rsp` (`fp - F`) plus `shadow` (the template's frames
and, on PE, its shadow space at the caller's frame bottom), the `Lend` extents, the query
world's live allocations, `Owned`. A return (`IslandReturn`) has `rip` the return address,
`rsp` popped (the caller's `fp - F`), the callee-saved registers (`Call.Saved`) kept; an unwind
lands per `Call.Landed` with `rsp` the caller's `fp - F`. As for calls the contract is only for queries the environment's R side handles (`Safe q`): the write set is in
terms of the query's world and `Lend` extents, and a query listing fewer of them than the
template writes must not count (for islands, `Safe` is where the trust that the lowering's
`Lend` scopes cover each template's frame writes sits: `Ryo.Vm.R.Islands`' write roles).

**Theorems.**
- `island_query`: from `RRel s x`, `MemRel s.st x`, R's step `.ext q s'`: the items up to the
  call reach the template's entry `x1` related to `q` (`IslandAt`), `RRel s' x1`,
  `MemRel s'.st x1`, the return address pushed, the callee-saved registers kept.
- `island_return`: every `Ret x1 x'` gives an answer with `R.answer c s a = .ok (.step s'')`,
  and `x'` itself is related to `s''`, at the next item, with `rsp` as before the call
  (`x1.rsp + 8`).
- `island_sound`: the two composed.
- `island_unwind`: every `Unw x1 x'` lands at the island's landing pad, related to R's
  `unwindAt`.

**Hypotheses** beyond the shape: `rsp = fp - F` (`hsp`, which `island_query` takes but its
proof doesn't use), `MemRel` before the call (`hm`, which `island_return` and `island_unwind`
take but don't use), the stack has room (`hlo`), the operand
array is in memory as the decoder read it (`hro`, the rodata relocation) and off the stack
(`hroA`), the symbol slots off the stack (`Call.SymsApart`), no initialized private frame byte
or live allocation byte on the stack below `rsp` (`Handler.StackApart`), no initialized
private frame byte where the template may write unless it's in a `Lend` extent
(`IslandApart`; from `FrameSep` by `FrameSep.islandApart`).

**Not modeled**: frames without a frame pointer, where the encoder emits `lea rdi, [rsp + F]`
(which the decoder reads as `[rbp + 0]`) and `rbp` is the caller's: these theorems execute
`lea rdi, [rbp + 0]` under `rbp = fp`; as for calls, unwinding past this frame; and the templates' functional
contracts.
-/
import Ryo.Proofs.Call
import Ryo.Proofs.IslandLemmas

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Island

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
open Ryo.Proofs.Call (WorldRel Saved Extends InAlloc Landed SymsApart)
open Ryo.Proofs.Counter (CalleeSaved InStack)

/-! ### Items -/

/-- The island call's argument registers: `fp`, then the operand array (PE `rcx`, `rdx`). -/
def islandRegs (pe : Bool) : Reg × Reg := if pe then (.rcx, .rdx) else (.rdi, .rsi)

/-- The callee's shadow space above its return address, at the caller's frame bottom: 32 bytes
on PE. -/
def shadow (pe : Bool) : Nat := if pe then 32 else 0

/-- The items up to the island's call (`islandCall`). -/
def islandPre (mode : Ryo.Obj.Mode) (isl o : Nat) : List Item :=
  [fpItem (islandRegs mode.pe).1 mode, .lea (islandRegs mode.pe).2 (.ro o), .callMem (.sym isl)]

/-! ### The boundary -/

/-- The operand array at `a` in `m`: the count as a `u32` at `a - 4`, then each slot as an
`i32`. -/
def OpsAt (m : Mem) (a : BitVec 64) (ops : List Int) : Prop :=
  m.readNat (a - 4) 4 = ops.length ∧
    ∀ i (h : i < ops.length), m.readNat (a + BitVec.ofNat 64 (4 * i)) 4 = (BitVec.ofInt 32 ops[i]).toNat

/-- The address of frame offset `off` for frame pointer `fp`. -/
def lendAddr (fp : Nat) (off : Int) : BitVec 64 := BitVec.ofNat 64 fp + BitVec.ofInt 64 off

theorem fpAddr_eq_lendAddr {x : X86.State} {fp : Nat} (h : x.reg .rbp = BitVec.ofNat 64 fp)
    (off : Int) : fpAddr x off = lendAddr fp off := by
  simp [fpAddr, lendAddr, h]

/-- The template's entry, for island `isl` with frame pointer `fp`, operand slots `ops`, the
waiting R state's `st` and world `w` (see the module comment). -/
structure IslandAt (ctx : Ctx) (pe : Bool) (isl fp : Nat) (ops : List Int) (st : OpSem.State)
    (w : R.World) (x : X86.State) : Prop where
  target : x.rip = x.mem.read64 (ctx.addrOf (.sym isl))
  fpArg : x.reg (islandRegs pe).1 = BitVec.ofNat 64 fp
  ops : OpsAt x.mem (x.reg (islandRegs pe).2) ops
  rbp : x.reg .rbp = BitVec.ofNat 64 fp
  frame : Rel st x
  world : WorldRel w x

/-- Where a template may write: the stack below `sp0` (the caller's `rsp` plus, on PE, the
32-byte shadow space above it: `shadow`, as `IslandEnd` passes it), the `Lend` extents, the
query world's live allocations, runtime-owned bytes. -/
def IslandMayWrite (Owned : BitVec 64 → Prop) (lo sp0 : BitVec 64) (fp : Nat)
    (lends : List (Int × Nat)) (w : R.World) (b : BitVec 64) : Prop :=
  InStack lo sp0 b ∨ (∃ l ∈ lends, (b - lendAddr fp l.1).toNat < l.2) ∨ InAlloc w b ∨ Owned b

/-- What a template's return and an unwind out of it share. `x` is the entry; the caller's
`rsp` is `x.rsp + 8`, the template may write below `x.rsp + 8 + shadow`. -/
structure IslandEnd (pe : Bool) (Owned : BitVec 64 → Prop) (lo : BitVec 64) (fp : Nat)
    (lends : List (Int × Nat)) (w : R.World) (x x' : X86.State) (a : R.Answer) : Prop where
  frameLen : a.frame.length = lends.length
  frame : ∀ j (h1 : j < lends.length) (h2 : j < a.frame.length),
    BytesRel a.frame[j] (bytesAt x'.mem (lendAddr fp lends[j].1) lends[j].2)
  world : WorldRel a.world x'
  grows : Extends w.mem a.world.mem
  mem : ∀ b, ¬ IslandMayWrite Owned lo (x.rsp + 8 + BitVec.ofNat 64 (shadow pe)) fp lends w b →
    x'.mem b = x.mem b

/-- A template's return related to the answer `a`. -/
structure IslandReturn (pe : Bool) (Owned : BitVec 64 → Prop) (lo : BitVec 64) (fp : Nat)
    (lends : List (Int × Nat)) (w : R.World) (x x' : X86.State) (a : R.Answer) : Prop
    extends IslandEnd pe Owned lo fp lends w x x' a where
  result : ∃ regs, a.result = .ret regs
  rip : x'.rip = x.mem.read64 x.rsp
  rsp : x'.rsp = x.rsp + 8
  saved : ∀ i, Saved pe i → x'.regs i = x.regs i

/-- The environment's contract for islands (trusted; see the module comment). -/
structure IslandContract (ctx : Ctx) (pe : Bool) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop)
    (Ret Unw : X86.State → X86.State → Prop) : Prop where
  ret : ∀ isl tpl fp ops lends st w x x', IslandAt ctx pe isl fp ops st w x →
    Safe ⟨.island isl tpl fp ops lends, w⟩ → Ret x x' →
    ∃ a, IslandReturn pe Owned lo fp lends w x x' a
  unwind : ∀ isl tpl fp ops lends st w x x', IslandAt ctx pe isl fp ops st w x →
    Safe ⟨.island isl tpl fp ops lends, w⟩ → Unw x x' →
    ∃ a exc, a.result = .unwind exc ∧ IslandEnd pe Owned lo fp lends w x x' a ∧
      Landed pe padOf (x.rsp + 8) x x' exc

/-- The template's entry with the frame pointer explicit (what `IslandContractB` and
`EnvOutside` assume): as `IslandAt` without `rbp = fp`, the frame relation read with
`rbp := fp`. Without a frame pointer `rbp` is the caller's, `fp` only in the argument register. -/
structure IslandAtB (ctx : Ctx) (pe : Bool) (isl fp : Nat) (ops : List Int) (st : OpSem.State)
    (w : R.World) (x : X86.State) : Prop where
  target : x.rip = x.mem.read64 (ctx.addrOf (.sym isl))
  fpArg : x.reg (islandRegs pe).1 = BitVec.ofNat 64 fp
  ops : OpsAt x.mem (x.reg (islandRegs pe).2) ops
  frame : Rel st (x.setReg .rbp (BitVec.ofNat 64 fp))
  world : WorldRel w x

theorem IslandAt.toB {ctx : Ctx} {pe : Bool} {isl fp : Nat} {ops : List Int} {st : OpSem.State}
    {w : R.World} {x : X86.State} (h : IslandAt ctx pe isl fp ops st w x) :
    IslandAtB ctx pe isl fp ops st w x :=
  ⟨h.target, h.fpArg, h.ops, by rw [← h.rbp, X86.State.setReg_reg_self]; exact h.frame, h.world⟩

/-- The environment's contract for islands with the frame pointer explicit (trusted; what `Hyps`
assumes): as `IslandContract`, from every `IslandAtB` entry. `toContract`: the frame-pointer
case; `virt`: on virtual states. -/
structure IslandContractB (ctx : Ctx) (pe : Bool) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop)
    (Ret Unw : X86.State → X86.State → Prop) : Prop where
  ret : ∀ isl tpl fp ops lends st w x x', IslandAtB ctx pe isl fp ops st w x →
    Safe ⟨.island isl tpl fp ops lends, w⟩ → Ret x x' →
    ∃ a, IslandReturn pe Owned lo fp lends w x x' a
  unwind : ∀ isl tpl fp ops lends st w x x', IslandAtB ctx pe isl fp ops st w x →
    Safe ⟨.island isl tpl fp ops lends, w⟩ → Unw x x' →
    ∃ a exc, a.result = .unwind exc ∧ IslandEnd pe Owned lo fp lends w x x' a ∧
      Landed pe padOf (x.rsp + 8) x x' exc

theorem IslandContractB.toContract {ctx : Ctx} {pe : Bool} {Owned : BitVec 64 → Prop}
    {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)} {Safe : R.Query → Prop}
    {Ret Unw : X86.State → X86.State → Prop}
    (hC : IslandContractB ctx pe Owned lo padOf Safe Ret Unw) :
    IslandContract ctx pe Owned lo padOf Safe Ret Unw :=
  ⟨fun isl tpl fp ops lends st w x x' h => hC.ret isl tpl fp ops lends st w x x' h.toB,
    fun isl tpl fp ops lends st w x x' h => hC.unwind isl tpl fp ops lends st w x x' h.toB⟩

theorem islandEnd_setRbp {pe : Bool} {Owned : BitVec 64 → Prop} {lo : BitVec 64} {fp : Nat}
    {lends : List (Int × Nat)} {w : R.World} {x x' : X86.State} {a : R.Answer} (v : BitVec 64)
    (h : IslandEnd pe Owned lo fp lends w x x' a) :
    IslandEnd pe Owned lo fp lends w (x.setReg .rbp v) (x'.setReg .rbp v) a :=
  ⟨h.frameLen, h.frame, h.world, h.grows, fun b hb => h.mem b (by rwa [Handler.setRbp_rsp] at hb)⟩

theorem landed_setRbp {pe : Bool} {padOf : BitVec 64 → Option (BitVec 64)} {sp0 : BitVec 64}
    {x x' : X86.State} {exc : ThinPointer} (v : BitVec 64) (h : Landed pe padOf sp0 x x' exc) :
    Landed pe padOf sp0 (x.setReg .rbp v) (x'.setReg .rbp v) exc := by
  refine ⟨?_, ?_, ?_, Handler.setRbp_saved h.saved⟩
  · rw [Handler.setRbp_rsp]; exact h.rip
  · rw [Handler.setRbp_reg x' v .rax (by decide)]; exact h.rax
  · rw [Handler.setRbp_rsp]; exact h.rsp

/-- On virtual states (`VRet`): the contract in the frame-pointer form. -/
theorem IslandContractB.virt {ctx : Ctx} {pe : Bool} {Owned : BitVec 64 → Prop}
    {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)} {Safe : R.Query → Prop}
    {Ret Unw : X86.State → X86.State → Prop}
    (hC : IslandContractB ctx pe Owned lo padOf Safe Ret Unw) :
    IslandContract ctx pe Owned lo padOf Safe (VRet Ret) (VRet Unw) := by
  have hB : ∀ {isl fp ops st w x} (v : BitVec 64),
      IslandAt ctx pe isl fp ops st w (x.setReg .rbp v) → IslandAtB ctx pe isl fp ops st w x := by
    intro isl fp ops st w x v hAt
    have hv : v = BitVec.ofNat 64 fp := by rw [← hAt.rbp, X86.State.reg_setReg]
    have h1 : (islandRegs pe).1 ≠ .rbp := by cases pe <;> decide
    have h2 : (islandRegs pe).2 ≠ .rbp := by cases pe <;> decide
    refine ⟨hAt.target, (Handler.setRbp_reg x v _ h1).symm.trans hAt.fpArg, ?_, ?_, hAt.world⟩
    · rw [← Handler.setRbp_reg x v _ h2]; exact hAt.ops
    · rw [← hv]; exact hAt.frame
  refine ⟨fun isl tpl fp ops lends st w xv xv' hAt hS hret => ?_,
    fun isl tpl fp ops lends st w xv xv' hAt hS hret => ?_⟩
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := hret
    obtain ⟨a, hr⟩ := hC.ret isl tpl fp ops lends st w x x' (hB v hAt) hS hR
    refine ⟨a, islandEnd_setRbp v hr.toIslandEnd, hr.result, ?_, ?_, Handler.setRbp_saved hr.saved⟩
    · show x'.rip = x.mem.read64 (x.setReg .rbp v).rsp
      rw [Handler.setRbp_rsp]; exact hr.rip
    · rw [Handler.setRbp_rsp, Handler.setRbp_rsp]; exact hr.rsp
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := hret
    obtain ⟨a, exc, h1, h2, h3⟩ := hC.unwind isl tpl fp ops lends st w x x' (hB v hAt) hS hR
    refine ⟨a, exc, h1, islandEnd_setRbp v h2, ?_⟩
    rw [Handler.setRbp_rsp]; exact landed_setRbp v h3

theorem intArg_ne_rbp (pe : Bool) (i : Nat) : Ryo.Vm.Asm.intArg pe i ≠ .rbp := by
  unfold Ryo.Vm.Asm.intArg
  rcases i with _ | _ | _ | _ | _ | _ | i <;> cases pe <;> simp

theorem callEnd_setRbp {Owned : BitVec 64 → Prop} {lo : BitVec 64} {sp n : Nat} {w : R.World}
    {x x' : X86.State} {a : R.Answer} (v : BitVec 64) (h : Call.CallEnd Owned lo sp n w x x' a) :
    Call.CallEnd Owned lo sp n w (x.setReg .rbp v) (x'.setReg .rbp v) a :=
  ⟨h.frame, h.world, h.grows, h.mem⟩

/-- A callee's contract on virtual states (`VRet`). -/
theorem _root_.Ryo.Proofs.Call.CallContract.virt {ctx : Ctx} {pe : Bool}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)}
    {Safe : R.Query → Prop} {Ret Unw : X86.State → X86.State → Prop}
    (hC : Call.CallContract ctx pe Owned lo padOf Safe Ret Unw) :
    Call.CallContract ctx pe Owned lo padOf Safe (VRet Ret) (VRet Unw) := by
  have hE : ∀ {cal regs sp stack w x} (v : BitVec 64),
      Call.EntryAt ctx pe cal regs sp stack w (x.setReg .rbp v) →
      Call.EntryAt ctx pe cal regs sp stack w x := by
    intro cal regs sp stack w x v h
    refine ⟨h.target, fun r hr => ArgRet.RegRel.congr (h.args r hr)
      (fun i _ => (Handler.setRbp_reg x v _ (intArg_ne_rbp pe i)).symm) (fun _ _ => rfl),
      ?_, h.stack, h.world⟩
    rw [← Handler.setRbp_rsp x v]; exact h.rsp
  refine ⟨fun cal regs sp stack w xv xv' hAt hS hpe hret => ?_,
    fun cal regs sp stack w xv xv' hAt hS hpe hret => ?_⟩
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := hret
    obtain ⟨a, hr⟩ := hC.ret cal regs sp stack w x x' (hE v hAt) hS hpe hR
    obtain ⟨rs, hrs, hrr⟩ := hr.regs
    refine ⟨a, callEnd_setRbp v hr.toCallEnd, ⟨rs, hrs, fun r hm => ?_⟩, ?_, ?_,
      Handler.setRbp_saved hr.saved⟩
    · have := hrr r hm
      cases r with
      | gpr i =>
        simp only [ArgRet.retBytes] at this ⊢
        rw [Handler.setRbp_reg x' v (if i = 0 then .rax else .rdx) (by split <;> decide)]
        exact this
      | xmm i => exact this
    · show x'.rip = x.mem.read64 (x.setReg .rbp v).rsp
      rw [Handler.setRbp_rsp]; exact hr.rip
    · rw [Handler.setRbp_rsp, Handler.setRbp_rsp]; exact hr.rsp
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := hret
    obtain ⟨a, exc, h1, h2, h3⟩ := hC.unwind cal regs sp stack w x x' (hE v hAt) hS hpe hR
    refine ⟨a, exc, h1, callEnd_setRbp v h2, ?_⟩
    rw [Handler.setRbp_rsp]; exact landed_setRbp v h3

/-- A trip's contract on virtual states (`VRet`). -/
theorem _root_.Ryo.Proofs.Counter.TripContract.virt {Owned : BitVec 64 → Prop} {lo : BitVec 64}
    {Returns : X86.State → X86.State → Prop} (hC : Counter.TripContract Owned lo Returns) :
    Counter.TripContract Owned lo (VRet Returns) := by
  refine ⟨fun s s' h => ?_, fun s s' h => ?_, fun s s' h => ?_, fun s s' h hlo a ha hs => ?_⟩
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := h
    show x'.rip = x.mem.read64 (x.setReg .rbp v).rsp
    rw [Handler.setRbp_rsp]; exact hC.ret_rip x x' hR
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := h
    rw [Handler.setRbp_rsp, Handler.setRbp_rsp]; exact hC.ret_rsp x x' hR
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := h
    exact Handler.setRbp_saved (hC.ret_saved x x' hR)
  · obtain ⟨v, x, x', hR, rfl, rfl⟩ := h
    rw [Handler.setRbp_rsp] at hlo hs
    exact hC.ret_mem x x' hR hlo a ha hs

/-- No initialized private frame byte outside the `Lend` extents and the range `sh` (the
shadow space, which R's answer makes `Uninit`: `Code.islandWrites`) is where the template may
write. Only initialized ones: an `Uninit` byte relates to any x86 byte, and over all private
bytes this would fail as soon as a live allocation lies outside the escaped objects. From
`FrameSep` by `FrameSep.islandApart`. -/
def IslandApart (Owned : BitVec 64 → Prop) (lo sp0 : BitVec 64) (fp : Nat)
    (lends : List (Int × Nat)) (sh : Int × Nat) (st : OpSem.State) : Prop :=
  ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → st.escapedAt o = none → st.frame o ≠ .uninit →
    (∀ l ∈ lends, ¬ (l.1 ≤ o ∧ o < l.1 + l.2)) → ¬ (sh.1 ≤ o ∧ o < sh.1 + sh.2) →
    ¬ IslandMayWrite Owned lo sp0 fp lends ⟨st.mem, st.exposed⟩ (lendAddr fp o)

/-- `IslandApart` from the frame separation over the window `[L, K)`: an initialized
private byte lies in the window (`FrameSep.init`), so at or above `fp + L`; outside `sh` not
below `sp0` (`hsp`); outside the `Lend` extents its address is outside theirs (`hlends` bounds
them, so no wrap); it is in no live allocation (`FrameApart`) and not runtime-owned (`hown`, an
environment fact). For an island `L = -F` and `sh = [-F, -F + shadow)`: the template's writes
reach `fp - F + shadow`. -/
theorem FrameSep.islandApart {Owned : BitVec 64 → Prop} {lo sp0 : BitVec 64} {fp : Nat}
    {L K : Int} {ls : List (Int × Nat)} {sh : Int × Nat} {st : OpSem.State} {x : X86.State}
    (hs : ScopeMem.FrameSep L K st x) (hw : ScopeMem.Window L K fp)
    (_hK : 0 ≤ K) (hb : x.reg .rbp = BitVec.ofNat 64 fp) (hF : 0 ≤ (fp : Int) + L)
    (hsp : ∀ o : Int, L ≤ o → o < K → ¬ (sh.1 ≤ o ∧ o < sh.1 + sh.2) →
      (sp0.toNat : Int) ≤ fp + o)
    (hlends : ∀ l ∈ ls, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62)
    (hown : ∀ o, L ≤ o → o < K → ¬ Owned (fpAddr x o)) :
    IslandApart Owned lo sp0 fp ls sh st := by
  intro o h1 h2 he hu hout hsh hmw
  obtain ⟨i1, i2⟩ := hs.init o he hu
  have htop := hw.top
  have hsp' := hsp o i1 i2 hsh
  rw [← fpAddr_eq_lendAddr hb] at hmw
  rcases hmw with hst | ⟨l, hl, hin⟩ | ⟨id, al, hg, hl, hin⟩ | how
  · simp only [InStack, fpAddr, hb, BitVec.toNat_add, BitVec.toNat_ofInt, BitVec.toNat_ofNat] at hst
    omega
  · rw [← fpAddr_eq_lendAddr hb, fpAddr_sub, BitVec.toNat_ofInt] at hin
    have := hout l hl
    have := hlends l hl
    omega
  · exact hs.frameApart id al o hg hl he hu h1 h2 hin
  · exact hown o i1 i2 how

/-! ### Small facts -/

set_option maxRecDepth 100000 in
theorem island_shape : Full.Opcode.island.info.shape = .island := by decide

theorem shadow_le (pe : Bool) : shadow pe ≤ 32 := by cases pe <;> decide

theorem saved_rbp (pe : Bool) : Saved pe 5 := Or.inl (by simp [CalleeSaved])

theorem saved_ne_rsp {pe : Bool} {i : Fin 16} (h : Saved pe i) : i ≠ 4 := by
  rintro rfl; rcases h with h | ⟨-, h⟩ <;> revert h <;> simp [CalleeSaved]

/-- The answer's writes over the `Lend` extents, then the range `[so, so + sn)` (the shadow
space) made `Uninit`, and the relations after them. -/
theorem answer_core {pe : Bool} {Owned : BitVec 64 → Prop} {lo : BitVec 64} {s : R.RState}
    {L : List (Int × Nat)} {so : Int} {sn : Nat} {x1 x' : X86.State} {a : R.Answer}
    (he : IslandEnd pe Owned lo s.fp L s.world x1 x' a) (hr : RRel s x1)
    (hlends : ∀ l ∈ L, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62)
    (hsb : -2 ^ 62 < so ∧ so + sn < 2 ^ 62)
    (hap : IslandApart Owned lo (x1.rsp + 8 + BitVec.ofNat 64 (shadow pe)) s.fp L (so, sn) s.st) :
    ∃ st1 st, R.writeRanges (s.withWorld a.world).st L a.frame = .ok st1 ∧
      st1.writeFrame so (List.replicate sn .uninit) = .ok st ∧
      ∀ x'' : X86.State, x''.mem = x'.mem → x''.reg .rbp = BitVec.ofNat 64 s.fp →
        Rel st x'' ∧ MemRel st x'' ∧ EscWF st := by
  have hinit := IslandLemmas.inv_init (L := L ++ [(so, sn)]) (x' := x') (w := a.world) hr.rel
    hr.rbp hr.wf he.grows.size he.grows.keep
    he.world (fun o h1 h2 hn hu hall => he.mem _ (hap o h1 h2 hn hu
      (fun l hl => hall l (List.mem_append_left _ hl)) (hall (so, sn) (by simp))))
  obtain ⟨st1, hw, hinv⟩ := IslandLemmas.inv_writeRanges hinit he.frameLen
    (fun j h1 h2 => he.frame j h1 h2) hlends
  obtain ⟨st, hw2, hinv2⟩ := IslandLemmas.inv_clobber hinv hsb
  refine ⟨st1, st, hw, hw2, fun x'' hm hrbp => ?_⟩
  exact IslandLemmas.inv_final hinv2 hm hrbp
    (fun p hp => by have := hr.rel.zeroSized p hp; rwa [fpAddr_eq_lendAddr hr.rbp] at this) hr.wf

/-! ### The theorems -/

/-- An island reaches its template's entry related to R's query (see the module comment). -/
theorem island_query (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {f : Full.Opcode} {isl o : Nat}
    {ws : List (BitVec 32)} {q : R.Query} {lo : BitVec 64}
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .island)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (_hsp : x.rsp = x.reg .rbp - BitVec.ofNat 64 c.d.frameSize)
    (hlo : lo.toNat + 8 ≤ x.rsp.toNat)
    (hro : OpsAt x.mem (ctx.addrOf (.ro o)) (ws.map (·.toInt)))
    (hroA : ∀ i < 4 * (ws.length + 1), ¬ InStack lo x.rsp (ctx.addrOf (.ro o) - 4 + BitVec.ofNat 64 i))
    (hsym : SymsApart ctx lo x.rsp x.mem)
    (h : R.step c s ch = .ok (.ext q s'))
    (hap : Handler.StackApart lo s'.st x) :
    ∃ x1, q = ⟨.island isl (c.islandTemplate s.pc) s.fp (ws.map (·.toInt)) (c.lendsAt s.pc),
        s'.world⟩ ∧
      execItems ctx (islandPre c.mode isl o) x = .ok x1 ∧
      IslandAt ctx c.mode.pe isl s.fp (ws.map (·.toInt)) s'.st s'.world x1 ∧
      RRel s' x1 ∧ MemRel s'.st x1 ∧ s'.pc = s.pc ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      x1.rsp + 8 = x.rsp ∧
      x1.mem.read64 x1.rsp = x.rip + BitVec.ofNat 64 ((islandPre c.mode isl o).map Item.size).sum ∧
      (∀ i, Saved c.mode.pe i → x1.regs i = x.regs i) ∧
      (∀ b, ¬ InStack lo x.rsp b → x1.mem b = x.mem b) := by
  obtain ⟨s1, hsc, ho⟩ := IslandLemmas.step_island hi hf hsh h
  cases ho
  have hk := scopes_keeps _ hsc
  obtain ⟨hr1, hm1⟩ := ScopeMem.memRel_foldlM _ hsz hr hm hsc
  obtain ⟨hne1, hne2, hne12, hne15, hne25, hsv⟩ : (islandRegs c.mode.pe).1.idx ≠ Reg.rsp.idx ∧
      (islandRegs c.mode.pe).2.idx ≠ Reg.rsp.idx ∧
      (islandRegs c.mode.pe).1.idx ≠ (islandRegs c.mode.pe).2.idx ∧
      (5 : Fin 16) ≠ (islandRegs c.mode.pe).1.idx ∧ (5 : Fin 16) ≠ (islandRegs c.mode.pe).2.idx ∧
      (∀ i, Saved c.mode.pe i → i ≠ (islandRegs c.mode.pe).1.idx ∧
        i ≠ (islandRegs c.mode.pe).2.idx) := by
    unfold islandRegs Saved
    cases c.mode.pe <;> simp only [↓reduceIte, Bool.false_eq_true] <;>
      refine ⟨by decide, by decide, by decide, by decide, by decide, ?_⟩ <;>
      rintro i (h | ⟨hp, h⟩) <;>
      first
        | (simp only [CalleeSaved] at h; rcases h with rfl | rfl | rfl | rfl | rfl | rfl <;> decide)
        | (rcases h with rfl | rfl <;> decide)
        | cases hp
  obtain ⟨x1, hex, hmem, hrip, hregs⟩ := IslandLemmas.exec_pre ctx c.mode (islandRegs c.mode.pe).1
    (islandRegs c.mode.pe).2 isl o x hne1 hne2
  have hreg : ∀ i, x1.regs i = _ := fun i => congrFun hregs i
  have hrsp1 : x1.rsp = x.rsp - 8 := by
    simp only [State.rsp, State.reg, hreg, ↓reduceIte]
  have hrbp1 : x1.reg .rbp = x.reg .rbp := by
    simp only [State.reg, hreg]
    simp [hne15, hne25]
  have hfp : ∀ d, fpAddr x1 d = fpAddr x d := fun d => by simp [fpAddr, hrbp1]
  have hmemS : ∀ b, ¬ InStack lo x.rsp b → x1.mem b = x.mem b := by
    intro b hb
    rw [hmem]
    exact Mem.write_other _ _ _ _ _
      (IslandLemmas.push_other' lo x.rsp b hlo hb)
  have hpre : islandPre c.mode isl o = [fpItem (islandRegs c.mode.pe).1 c.mode,
      .lea (islandRegs c.mode.pe).2 (.ro o), .callMem (.sym isl)] := rfl
  obtain ⟨hR1, hM1⟩ := hap.rel hr1.rel hm1 hrbp1 hmemS
  have hrbpS : x1.reg .rbp = BitVec.ofNat 64 s.fp := hrbp1.trans hr.rbp
  refine ⟨x1, by rw [hk.pc, hk.fp], by rw [hpre]; exact hex, ⟨?_, ?_, ?_, hrbpS, hR1, hM1⟩,
    ⟨hR1, by rw [hk.fp]; exact hrbpS, hr1.wf⟩, hM1, hk.pc, hk.fp, hk.args, ?_, ?_, ?_, hmemS⟩
  · rw [hrip]
    unfold Mem.read64
    rw [IslandLemmas.readNat_congr x1.mem x.mem _ 8 (fun i hi =>
      hmemS _ (hsym isl _ (List.mem_cons_self ..) i hi))]
  · show x1.regs _ = _
    have hne1' : ¬ (islandRegs c.mode.pe).1.idx = 4 := hne1
    rw [hreg, ite_eq_right hne1, ite_eq_right hne12, ite_eq_left rfl]; exact hr.rbp
  · show OpsAt x1.mem (x1.regs _) _
    rw [hreg]
    have hne2' : ¬ (islandRegs c.mode.pe).2.idx = 4 := hne2
    rw [ite_eq_right hne2, ite_eq_left rfl]
    refine ⟨?_, fun i hi => ?_⟩
    · rw [IslandLemmas.readNat_congr x1.mem x.mem _ 4 (fun j hj =>
        hmemS _ (hroA j (by omega)))]
      exact hro.1
    · have hl : i < ws.length := by simpa using hi
      rw [IslandLemmas.readNat_congr x1.mem x.mem _ 4 (fun j hj => by
        have e : ctx.addrOf (.ro o) + BitVec.ofNat 64 (4 * i) + BitVec.ofNat 64 j =
            ctx.addrOf (.ro o) - 4 + BitVec.ofNat 64 (4 * (i + 1) + j) := by
          rw [show 4 * (i + 1) + j = 4 + 4 * i + j by omega, BitVec.ofNat_add, BitVec.ofNat_add]
          exact IslandLemmas.bv_add4 _ _ _
        rw [e]; exact hmemS _ (hroA _ (by omega)))]
      exact hro.2 i hi
  · rw [hrsp1]; exact IslandLemmas.bv_subadd _
  · rw [hrsp1, hmem]
    exact IslandLemmas.read64_write_self _ _ _
  · intro i hi
    obtain ⟨h1, h2⟩ := hsv i hi
    rw [hreg]
    simp [saved_ne_rsp hi, h1, h2]

/-- A template's return, from its entry `x1` related to the waiting state `s`'s query, continues
per `R.answer`, the return state `x'` at the item after the call (see the module comment). -/
theorem island_return (ctx : Ctx) {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {isl : Nat} {ws : List (BitVec 32)}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)}
    {Safe : R.Query → Prop} {Ret Unw : X86.State → X86.State → Prop}
    (hC : IslandContract ctx c.mode.pe Owned lo padOf Safe Ret Unw)
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .island)
    (he : IslandAt ctx c.mode.pe isl s.fp (ws.map (·.toInt)) s.st s.world x1)
    (hr : RRel s x1) (_hm : MemRel s.st x1)
    (hlends : ∀ l ∈ c.lendsAt s.pc, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62)
    (hsafe : Safe ⟨.island isl (c.islandTemplate s.pc) s.fp (ws.map (·.toInt)) (c.lendsAt s.pc),
      s.world⟩)
    (hsb : -2 ^ 62 < -(c.d.frameSize : Int) ∧ -(c.d.frameSize : Int) + c.islandShadow < 2 ^ 62)
    (hap : IslandApart Owned lo (x1.rsp + 8 + BitVec.ofNat 64 (shadow c.mode.pe)) s.fp
      (c.lendsAt s.pc) (-(c.d.frameSize : Int), c.islandShadow) s.st)
    (hR : Ret x1 x') :
    ∃ a s'', IslandReturn c.mode.pe Owned lo s.fp (c.lendsAt s.pc) s.world x1 x' a ∧
      R.answer c s a = .ok (.step s'') ∧
      RRel s'' x' ∧ MemRel s''.st x' ∧ s''.pc = s.pc + 1 ∧ s''.fp = s.fp ∧
      s''.args = s.args ∧
      x'.rip = x1.mem.read64 x1.rsp ∧ x'.rsp = x1.rsp + 8 ∧
      (∀ i, Saved c.mode.pe i → x'.regs i = x1.regs i) := by
  obtain ⟨a, hret⟩ := hC.ret _ _ _ _ _ _ _ x1 x' he hsafe hR
  obtain ⟨st1, st, hw, hw2, hrel⟩ := answer_core hret.toIslandEnd hr hlends hsb hap
  obtain ⟨regs, hres⟩ := hret.result
  have hrbp : x'.reg .rbp = BitVec.ofNat 64 s.fp := by
    show x'.regs 5 = _
    rw [hret.saved 5 (saved_rbp _)]; exact hr.rbp
  obtain ⟨hR1, hM1, hW1⟩ := hrel x' rfl hrbp
  refine ⟨a, { s.withWorld a.world with st, pc := s.pc + 1 }, hret, ?_,
    ⟨hR1, hrbp, hW1⟩, hM1, rfl, rfl, rfl, hret.rip, hret.rsp, hret.saved⟩
  rw [IslandLemmas.answer_island a hi hf hsh, IslandLemmas.islandWrites_ok hw hw2, hres]; rfl

/-- The full R step of an island that returns: `island_query` then `island_return`. -/
theorem island_sound (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {f : Full.Opcode} {isl o : Nat}
    {ws : List (BitVec 32)} {q : R.Query}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)}
    {Safe : R.Query → Prop} {Ret Unw : X86.State → X86.State → Prop}
    (hC : IslandContract ctx c.mode.pe Owned lo padOf Safe Ret Unw)
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .island)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsp : x.rsp = x.reg .rbp - BitVec.ofNat 64 c.d.frameSize)
    (hlo : lo.toNat + 8 ≤ x.rsp.toNat)
    (hro : OpsAt x.mem (ctx.addrOf (.ro o)) (ws.map (·.toInt)))
    (hroA : ∀ i < 4 * (ws.length + 1), ¬ InStack lo x.rsp (ctx.addrOf (.ro o) - 4 + BitVec.ofNat 64 i))
    (hsym : SymsApart ctx lo x.rsp x.mem)
    (hlends : ∀ l ∈ c.lendsAt s.pc, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62)
    (h : R.step c s ch = .ok (.ext q s')) (hsafe : Safe q)
    (hap : Handler.StackApart lo s'.st x)
    (hsb : -2 ^ 62 < -(c.d.frameSize : Int) ∧ -(c.d.frameSize : Int) + c.islandShadow < 2 ^ 62)
    (hia : IslandApart Owned lo (x.rsp + BitVec.ofNat 64 (shadow c.mode.pe)) s.fp
      (c.lendsAt s.pc) (-(c.d.frameSize : Int), c.islandShadow) s'.st) :
    ∃ x1, q = ⟨.island isl (c.islandTemplate s.pc) s.fp (ws.map (·.toInt)) (c.lendsAt s.pc),
        s'.world⟩ ∧
      execItems ctx (islandPre c.mode isl o) x = .ok x1 ∧
      IslandAt ctx c.mode.pe isl s.fp (ws.map (·.toInt)) s'.st s'.world x1 ∧
      ∀ x', Ret x1 x' → ∃ a s'',
        IslandReturn c.mode.pe Owned lo s.fp (c.lendsAt s.pc) s'.world x1 x' a ∧
        R.answer c s' a = .ok (.step s'') ∧
        RRel s'' x' ∧ MemRel s''.st x' ∧ s''.pc = s.pc + 1 ∧
        x'.rip = x.rip + BitVec.ofNat 64 ((islandPre c.mode isl o).map Item.size).sum ∧
        x'.rsp = x.rsp ∧ (∀ i, Saved c.mode.pe i → x'.regs i = x.regs i) := by
  obtain ⟨x1, hq, hex, hat, hrr, hmm, hpc, hfp, -, hrsp, hret, hsaved, -⟩ :=
    island_query ctx hi hf hsh hr hm hsz hsp hlo hro hroA hsym h hap
  refine ⟨x1, hq, hex, hat, fun x' hR => ?_⟩
  have hi' : c.d.insns[s'.pc]? = some (.native op [.sym isl, .words ws]) := by rw [hpc]; exact hi
  have hat' : IslandAt ctx c.mode.pe isl s'.fp (ws.map (·.toInt)) s'.st s'.world x1 := by
    rw [hfp]; exact hat
  have hsafe' : Safe ⟨.island isl (c.islandTemplate s'.pc) s'.fp (ws.map (·.toInt))
      (c.lendsAt s'.pc), s'.world⟩ := by rw [hpc, hfp, ← hq]; exact hsafe
  have hap' : IslandApart Owned lo (x1.rsp + 8 + BitVec.ofNat 64 (shadow c.mode.pe)) s'.fp
      (c.lendsAt s'.pc) (-(c.d.frameSize : Int), c.islandShadow) s'.st := by
    rw [hrsp, hpc, hfp]; exact hia
  obtain ⟨a, s'', hA, hans, hrel, hmem, hpc', -, -, hrip, hrsp', hsv⟩ :=
    island_return ctx hC hi' hf hsh hat' hrr hmm (by rw [hpc]; exact hlends) hsafe' hsb hap' hR
  refine ⟨a, s'', by rw [← hfp, ← hpc]; exact hA, hans, hrel, hmem,
    by rw [hpc', hpc], by rw [hrip, hret], by rw [hrsp', hrsp],
    fun i hi => by rw [hsv i hi, hsaved i hi]⟩

/-- Unwinding out of a template into the island's landing pad `pad` (`pos pad` its position). -/
theorem island_unwind (ctx : Ctx) {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {isl : Nat} {ws : List (BitVec 32)}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)}
    {Safe : R.Query → Prop} {Ret Unw : X86.State → X86.State → Prop} {pad : Nat}
    {cat : Bool}
    (pos : Nat → BitVec 32)
    (hC : IslandContract ctx c.mode.pe Owned lo padOf Safe Ret Unw)
    (hi : c.d.insns[s.pc]? = some (.native op [.sym isl, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .island)
    (he : IslandAt ctx c.mode.pe isl s.fp (ws.map (·.toInt)) s.st s.world x1)
    (hr : RRel s x1) (_hm : MemRel s.st x1)
    (hlends : ∀ l ∈ c.lendsAt s.pc, -2 ^ 62 < l.1 ∧ l.1 + l.2 < 2 ^ 62)
    (hsafe : Safe ⟨.island isl (c.islandTemplate s.pc) s.fp (ws.map (·.toInt)) (c.lendsAt s.pc),
      s.world⟩)
    (hsb : -2 ^ 62 < -(c.d.frameSize : Int) ∧ -(c.d.frameSize : Int) + c.islandShadow < 2 ^ 62)
    (hap : IslandApart Owned lo (x1.rsp + 8 + BitVec.ofNat 64 (shadow c.mode.pe)) s.fp
      (c.lendsAt s.pc) (-(c.d.frameSize : Int), c.islandShadow) s.st)
    (hpad : c.cleanupAt s.pc = some (some pad, cat))
    (hpos : padOf (x1.mem.read64 x1.rsp) = some (ctx.base + (pos pad).setWidth 64))
    (hU : Unw x1 x') :
    ∃ a exc s'', a.result = .unwind exc ∧
      IslandEnd c.mode.pe Owned lo s.fp (c.lendsAt s.pc) s.world x1 x' a ∧
      R.answer c s a = .ok (.step s'') ∧ s''.pc = pad ∧ s''.st.exception = exc ∧
      RRel s'' x' ∧ MemRel s''.st x' ∧ s''.fp = s.fp ∧ s''.args = s.args ∧
      x'.rip = ctx.base + (pos pad).setWidth 64 ∧ x'.reg .rax = BitVec.ofNat 64 exc.addr ∧
      x'.rsp = x1.rsp + 8 ∧
      (∀ i, Saved c.mode.pe i → x'.regs i = x1.regs i) := by
  obtain ⟨a, exc, hres, hend, hland⟩ := hC.unwind _ _ _ _ _ _ _ x1 x' he hsafe hU
  obtain ⟨st1, st, hw, hw2, hrel⟩ := answer_core hend hr hlends hsb hap
  have hrbp : x'.reg .rbp = BitVec.ofNat 64 s.fp := by
    show x'.regs 5 = _
    rw [hland.saved 5 (saved_rbp _)]; exact hr.rbp
  obtain ⟨hR1, hM1, hW1⟩ := hrel x' rfl hrbp
  refine ⟨a, exc, { s.withWorld a.world with st := { st with exception := exc }, pc := pad },
    hres, hend, ?_, rfl, rfl, ⟨⟨hR1.frame, hR1.layout, hR1.zeroSized⟩, hrbp, ⟨hW1.idLt, hW1.idInj, hW1.size, hW1.disj⟩⟩,
    hM1, rfl, rfl,
    Option.some.inj (hland.rip.symm.trans hpos), hland.rax, hland.rsp, hland.saved⟩
  rw [IslandLemmas.answer_island a hi hf hsh, IslandLemmas.islandWrites_ok hw hw2, hres]
  simp only [bind, Except.bind]
  unfold R.unwindAt
  simp only [R.RState.withWorld, hpad]
  rfl

end Ryo.Proofs.Island
