/-
Ryo.Proofs.DecodeSound — M3 `decode_sound` (aot.md §C2): when the Lean decoder accepts a
function's bytes giving the R program `d`, and the linked bytes are in code memory, L2's
fetching machine simulates R's steps of `d`, instruction by instruction.

**The simulation** (generic, §1, proved). The x86 side is `Step` (`Ryo.X86.Fetch`: canonical
items fetched from memory) and the environment (`Env`): at a state the environment runs from
(`out`: just after a `call` of a handler, a callee, an island or a trip) it comes back in any
state `ret` allows. `Reach Q x`: whatever the environment does, the machine from `x` reaches a
state in `Q` (by code steps, which `ExecUnique` makes deterministic; at an environment state,
for every return it may give). It is a safety property in the environment (a callee that never
returns satisfies it) but a progress property in the code: a `Reach` run doesn't fault. The R
side is `RNext` (one instruction: `R.step`, or a call/island `.ext` continued by an `answer`)
and `RDone` (the function's end). `RSafe Safe c s`: R's step from `s` has no error but for
choices outside the allowed set (`noBehavior`), and each query it makes is one the environment
handles (`Safe`, the callee's or template's R side; the composition with the environment's
simulations discharges it). Then:

- `InsnSim Inv Exit`: from every related state whose R step is safe, the machine reaches a state
  related to an R successor (`Inv`), or the function's end related to R's (`Exit`).
- `Runs n s x`: `n` R transitions are simulated from `(s, x)`, each in the sense of `InsnSim`;
  `FnSim s x := ∀ n, Runs n s x`.
- `fnSim_of_insnSim`: `InsnSim` and safety of every R state reachable from `s` give `FnSim`.

**The relation** (§2). `Setup` fixes the function: the R code `c` (its `Decoded` the decoder's),
the decoder's read (`r`, the body cursor and its iterations' positions, caches and dropped
stores, `Layout`), the window end `K`, the state `x0` at the function's entry (the caller's
`call` done), and the environment's parameters. At an instruction boundary (`BInv S s x`):

- `rip` at instruction `s.pc`'s start (where the previous one falls through, before its
  padding) with the cache it was read with, or at its position (`posOf`, a branch target: after
  the padding) with the cache the decoder used there (`Setup.used`: cleared at targets);
- `FrameInv`: `RRel` (`Rel`, `fp` in `rbp`, `EscWF`), `MemRel`, `FrameSep` over the window
  `[-F, K)` with the window in the address space, `rsp = fp - F`, room on the stack below
  `rsp` (`lo`), the code linked in memory (`LinkOk`) and the rodata (`RoLoaded`), at a leading
  `arg` (`LeadArg`: it and every instruction before are `arg`s) the incoming argument registers
  no earlier `arg` read (`ArgsLive`: an `arg` stored in pieces shifts its own register, so only
  the unconsumed ones stay related; at instruction 0 it is `ArgsRel`), and the frame's link to the caller (`FrameFacts`: return address, saved `rbp`, the
  other callee-saved registers as at entry, on PE `rsi`/`rdi` too).
- `ExitRel`: a return with the return registers related, `rip` the return address, `rsp` and
  the callee-saved registers as the caller left them, and the world related; a tail call at the
  callee's entry (`EntryAt`) with `rsp` as at entry; an unwind out of the function is not a
  state of this function (the unwinder lands in a caller), so never related here.

**Per instruction** (§4). `InsnSim` at `k` splits into the prologue of the iteration (the
padding's `nop`s, `reach_padding`; the counter check, `reach_counter`) and the body
(`BodySim`), one lemma per shape the decoder reads (`bodySim_arg`, `bodySim_call`,
`bodySim_inline`, `bodySim_handler`, `bodySim_ret`, `bodySim_unreachable`, `bodySim_jmp`,
`bodySim_island`, `bodySim_dense`), dispatched by `bodySim_of_read` over `ProtoRead`/`InsnRead`.
Proved helpers: decoded branches are canonical (`branch_canonical`), every iteration starts at a
relocation boundary (`boundary_start`), R's scopes never stop with `noBehavior` (`noNB_scopes`);
facts of the decoder: the prologue read item by item (`read_instructions_prologue`), landing
pads are `lpad`s (`pad_lpad`, so not leading `arg`s, `pad_not_leadArg`), protos lie within the
code (`posOf_le_size`, so `posOf_lt_32`). Still `sorry`: `bodySim_call`, `bodySim_inline`,
`bodySim_handler` (worked on in `DSWork/{Call,Inline,Handler}.lean`) and `bodySim_dense`.

**Files.** `DecodeSound/Basic.lean`: §1–§3 and §4's helpers, `bodySim_unreachable`,
`bodySim_jmp`, `reach_padding`, `boundary_start`. `DSWork/Boundary.lean`: the decoder facts.
`DSWork/{Arg,Ret,Island,Counter}.lean`: `bodySim_arg`, `bodySim_ret`, `bodySim_island`,
`reach_counter`. This file: the open bodies, the dispatch, `insnSim_main`, §5.

**`decode_sound`** (§5): from `decodeReduced … = .ok d`, `read_instructions_prologue`,
`instructions_read` and `iters_indexed` give the layout; `reducedOf_insns` the instructions; then
`fnSim_of_insnSim`.

**Hypotheses** (`Hyps`). Trusted: the handler, `resume`, call, island and trip contracts on the
environment's `ret` (`HandlerContract`, `ResumeContract`: `resume`'s handler is assembly, outside
`opSem`, and comes back only at a landing pad; `CallContract`, `IslandContract`,
`TripContract`; on PE every return keeps `rsi`/`rdi`, `peSaved`), the link map (`Linked`,
`Globals`). Proved elsewhere, outside the default build: `OpFacts` of every opcode
(`RyoProofs/OpFacts.lean`) and `InlineOk` of every inline class (`RyoProofs/InlineOk.lean`). Restrictions: the frame-pointer mode (`fp`), the items without a
frame pointer have no step lemmas yet; handler calls with their arguments in registers
(`regArgs`: PE's stack argument, the `atomic.cxchg` handlers', writes the frame's bottom, its
step is open); no PE pad region (`Decodes.noRegion`: PE's cleanup code after the body, which the
exception dispatcher enters on its own stack). Open prerequisites, each a named hypothesis to be
discharged later:

- of the decoded code, checkable (the decoder or a check could reject the code otherwise):
  `frameBounds` (`FrameBounds c K`, from the decoder, `DecodeLink/Bounds.lean`, in progress),
  `peFrame` (on PE `F + 8 < 2 ^ 31`, for the epilogue),
  `moreBounds` (`MoreBounds`: handler writes and call result slots in the window, to join
  `FrameBounds`), `relocsIn` (`RelocsIn`: relocated fields within the code), `argsOk`
  (`ArgsOk`: the leading `arg`s read distinct argument registers of the convention, and no
  branch target is one);
- privacy after the scopes (checkable with the scopes, as an invariant): `loadPrivate` (a
  `load`'s destination, `LoadPrivate`), `argPrivate` (an `arg`'s, `ArgPrivate`),
  `resultPrivate` (a call's result slots, `ResultPrivate`), `linkPrivate` (the frame's link
  slots, in no escaped object or `Lend` extent, `LinkPrivate`), `peShadow` (on PE the island
  templates' 32-byte shadow space at the frame's bottom holds no private byte);
- the environment and the layout (not checkable from the function): `sepAcross` (the frame
  separation across handler calls, calls and islands, `SepAcross`: `FrameSep.extend`'s
  allocation facts, not yet in the contracts), `envApart` (`EnvApart`: the frame window not
  runtime-owned, live allocations neither runtime-owned nor below `rsp`, the symbol slots and
  the JIT record off the stack), `stackSizes` (`StackSizes`: the callees' stack areas, from the
  image), `codeApart` (`CodeApart`: nothing the function or its environment writes is code or
  rodata), `envOutside` (`EnvOutside`: the environment's entries are `Env.out` states, outside
  the function's body);
- facts of the decoder and linker not yet exposed: `deadStore` (`DeadStoreSim`: the steps of
  dropped stores), `cacheCleared` (`CacheCleared`: the cache is empty at branch targets and
  landing pads), `padsLinked` (`PadsLinked`: the LSDA as linked against `cleanupAt`),
  `stubsLinked` (`StubsLinked`: the counter stubs in memory as `read` checked them).

Not covered: the prologue (R's `entry` against the entry's counter check, the prologue and the
stack probe: the simulation starts at instruction 0's boundary) and the trip's `Done` outcome (a
transfer into JIT code, which simulates the same function).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.DSWork.Boundary
import Ryo.Proofs.DSWork.Arg
import Ryo.Proofs.DSWork.Ret
import Ryo.Proofs.DSWork.Counter
import Ryo.Proofs.DSWork.Island

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

/-! ## 4. Per instruction (continued; §1–§4's definitions and proved helpers are in
`DecodeSound/Basic.lean`) -/

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-! #### The shapes' bodies still open

Proved in `DSWork/*.lean`: `bodySim_arg` (Arg), `bodySim_ret` (Ret), `bodySim_island` (Island),
`reach_counter` (Counter); `bodySim_unreachable`, `bodySim_jmp` in `DecodeSound/Basic.lean`.
Still `sorry` here, their proofs worked on in `DSWork/Call.lean`, `Inline.lean`, `Handler.lean`
(as `bodySim_call'`, `bodySim_inline'`, `bodySim_handler'`; to replace these once those files
import `DSWork/Boundary.lean` instead of this file), and the dense switch. -/

/-- A call or tail call (`Call.call_sound`, `call_unwind`, `tail_call_step` with
`DecodeLink.link_call_ok`; the pad by `PadsLinked`, `posOf_lt_32`, `pad_not_leadArg`). -/
theorem bodySim_call (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (callInsn S.fr (S.dr k)).run cur = .ok (some q, c')) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_call

/-- An inline sequence without a dropped store (`CacheStep.inline_step_cached` and
`CacheMem`'s `_sep_cached` steps through `FrameBounds`, with `DecodeLink.link_inline` and
`inline_branch_index`; the `jcc` by `branch_canonical`). -/
theorem bodySim_inline (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur cur' c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache') (hn : NoArg S.fr S.body p a cur)
    (hc : (callInsn S.fr (S.dr k)).run cur = .ok (none, cur'))
    (hr : (inlineInsn (S.used k) (S.dr k) true).run cur' = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_inline

/-- A handler call of shape `op`, `lpad`, `br`, `switch` or `trap` (`Shapes.handler_step_op`,
`_br`, `_trap`, `Switch.switch_tail`, with `DecodeLink.link_handler`; `resume` by
`ResumeContract`, its writes by `MoreBounds.handler`). -/
theorem bodySim_handler (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_handler

/-- A dense switch: `denseSwitch`'s inline index computation (`Asm.denseIndex`, the case index of
`switch.dense` in `rax`: `s - base` wrapping at the width, `n` if not below `n`) and its jump
table, standing in for R's `switch.dense` handler call (`sorry`: needs a step lemma for the
index items against the handler's `opSem`, then `Switch.switchItems` as in `bodySim_handler`'s
`switch` case). -/
theorem bodySim_dense (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (denseSwitch S.fr).run cur = .ok (some q, c')) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_dense

/-! #### The dispatch over what the decoder read -/

theorem noHandler_ops : Full.Opcode.ret ≠ Full.Opcode.unreachable ∧ Full.Opcode.ret ≠ Full.Opcode.jmp ∧
    Full.Opcode.ret ≠ Full.Opcode.island := by decide

/-- A proto the decoder read at `p` is simulated by its shape's body lemma. -/
theorem bodySim_of_read (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache')
    (hr : ProtoRead S.fr S.ro true S.body p (S.used k) (S.dr k) (S.args k) q c' cache' dr') :
    BodySim S k p (S.used k) := by
  generalize ha : S.args k = a at hr
  cases hr with
  | arg h => exact bodySim_arg hD H ha hP h
  | call hn h => exact bodySim_call hD H hP hn h
  | inline hn hc h =>
    cases hq : q.dropped
    · exact bodySim_inline hD H hP hn hc h hq
    · exact H.deadStore.inline k p _ _ _ q c' cache' dr' hn hc h hq
  | insn hn hc hi h =>
    have e1 := callInsn_none hc
    have e2 := inlineInsn_none hi
    subst e1 e2
    have hir := insn_read h
    have hir' := hir
    cases hir' with
    | handler => exact bodySim_handler hD H hP hn hir (by simp)
    | ret => exact bodySim_ret hD H hP hn hir rfl
    | unreachable => exact bodySim_unreachable hD H hP hn hir rfl
    | jmp => exact bodySim_jmp hD H hP hn hir rfl
    | island => exact bodySim_island hD H hP hn hir rfl
    | resume => exact bodySim_handler hD H hP hn hir (by simp)
    | dense h => exact bodySim_dense hD H hP hn h

/-- Instruction `k` of a main iteration: the padding (from its start), the counter check, then
the body. -/
theorem insnSim_main (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p1 p2 : Nat} {counter : Option (Nat × Nat)} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hk : k < S.r.protos.size)
    (hq : S.r.protos[k] = { q with pos := p1, counter })
    (hpad : PadRead S.body (S.start k) p1) (hctr : CounterRead S.fr S.body p1 counter p2)
    (hpr : ProtoRead S.fr S.ro (some S.targets).isSome S.body p2
      (if (some S.targets).any (sortedContains · p1) then { pe := S.fr.mode.pe } else S.cache k)
      (S.dr k) (S.args k) q c' cache' dr')
    (hnop : NopRead S.fr S.callSites S.body q c'.pos (S.start (k + 1)))
    (hcache : S.cache (k + 1) = cache') :
    InsnSimAt S k := by
  intro s x hs hbi hsafe
  obtain ⟨hf, hat⟩ := hbi
  have hp1 : posOf S.r k = p1 := by rw [posOf_eq hk, hq]
  have hpr : ProtoRead S.fr S.ro true S.body p2 (S.used k) (S.dr k) (S.args k) q c' cache' dr' := by
    have e : (if (some S.targets).any (sortedContains · p1) then ({ pe := S.fr.mode.pe } : Cache)
        else S.cache k) = S.used k := by simp [Setup.used, Setup.fr, hp1, Option.any]
    rw [e] at hpr
    exact hpr
  have hb0 := boundary_start hD H hf.code k (Nat.le_of_lt hk)
  -- The boundary at `p1`, and the code there, from memory.
  obtain ⟨ns, hns, hcode, hp1e, hb1⟩ := padRead_codeAt hf.code hpad hb0
  -- The body, from `p2` with the cache `used k`.
  have hargs : S.args (k + 1) = (S.args k && q.op == .arg) := by
    have := hD.argsSucc k (by simpa using hk)
    simpa [hq] using this
  have hinsn : ∃ i, S.c.d.insns[k]? = some i ∧ ∀ hk : k < S.r.protos.size,
      InsnOf (posOf S.r) S.r.protos[k] i := by
    have h1 := (reducedOf_insns hD.reduced)
    have hk' : k < S.c.d.insns.size := h1.1 ▸ hk
    exact ⟨S.c.d.insns[k], by simp [hk'], fun hk => h1.2 k hk hk'⟩
  have body : ∀ (hb2 : Boundary S.rs p2), BodySim S k p2 (S.used k) := fun hb2 =>
    bodySim_of_read hD H ⟨hk, ⟨p1, counter, by simp [hk, hq]⟩, hinsn, hb2, hnop, hcache, hargs⟩ hpr
  -- From `p1` with the cache `used k`.
  have from_p1 : ∀ y, FrameInv S s y → y.rip = addrAt S.ctx p1 → CacheInv (S.used k) y →
      Reach S.ctx S.E (SNext S s) y := by
    intro y hfy hry hcy
    cases hctr with
    | none => exact body hb1 s y hs hfy hry hcy hsafe
    | check hcnt hd =>
      have hb2 := (hfy.code.dec hd hb1).2.2
      refine reach_counter hD H hk (by rw [hq]) (.check hcnt hd) hb1 hs hfy hry hcy ?_
      exact fun z hfz hrz hcz => body hb2 s z hs hfz hrz hcz hsafe
  rcases hat with ⟨hrip, hci⟩ | ⟨hrip, hci⟩
  · rw [hs] at hrip hci
    refine reach_padding hns hcode hrip fun y h1 h2 h3 h4 => ?_
    refine from_p1 y (hf.congr h1 h2 h3) (by rw [h4, ← hp1e]) ?_
    have hcy := inv_congr hci h1 h3
    unfold Setup.used
    split
    · exact CacheInv.emptyPe _ y
    · exact hcy
  · rw [hs, hp1] at hrip
    rw [hs] at hci
    exact from_p1 x hf hrip hci

end Insn

/-! ## 5. `decode_sound` -/

/-- Every function `decodeReduced` accepts has a `Setup` that is its read, for any R code with
its `Decoded` and mode and any choice of the other parameters. -/
theorem decodes_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (hnr : regionPad mode callSites = none)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env) (K : Int)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.K = K ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.Safe = Safe := by
  obtain ⟨r, c', hread, hred⟩ := decodeReduced_read hdec
  obtain ⟨c0, c1, targets, stub, padded, hc0, hrun, hpro⟩ := read_instructions_prologue hread hnr
  obtain ⟨hit, -, -, -⟩ := instructions_read hrun
  obtain ⟨st, ca, drs, ar, h0, hc0', hd0, ha0, -, -, har, hix⟩ := iters_indexed hit
  have hsz : c0.code.size = code.data.size := by rw [hc0]; rfl
  refine ⟨Setup.mk ctx E c r c0 relocs rodata callSites targets st ca drs ar K x0 Owned lo padOf
    Safe, ⟨⟨c', hread⟩,
    hc ▸ hred, hm, rfl, rfl, rfl, hnr, hc0, ?_, h0, hc0', hd0, ha0, har, ?_,
    fun hfp => hpro (hm ▸ hfp)⟩, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  · exact ⟨stub, padded, c1, by simpa [Setup.fr, hm, hsz] using hrun⟩
  · simpa [Setup.fr, hm] using hix

/-- **`decode_sound`** (aot.md §C2): for a function the decoder accepts (`Decodes`, given by
`decodes_of_ok` from `decodeReduced … = .ok d`) under `Hyps`, the fetching machine with its
environment simulates the R program from every boundary whose R runs are safe. -/
theorem decode_sound {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) :
    ∀ s x, BInv S s x → SafeFrom S.Safe S.c s → FnSim S.ctx S.E S.c (BInv S) (ExitRel S) s x := by
  refine fnSim_of_insnSim _ _ _ _ _ _ fun s x hbi hsafe => ?_
  by_cases hk : s.pc < S.r.protos.size
  · have hit := hD.iters s.pc (by simpa using hk)
    simp only [Array.getElem_toList] at hit
    generalize hpk : S.r.protos[s.pc] = pk at hit
    generalize hdr : S.dr s.pc = drk at hit
    generalize hst1 : S.start (s.pc + 1) = st1 at hit
    generalize hca1 : S.cache (s.pc + 1) = ca1 at hit
    generalize hdr1 : S.dr (s.pc + 1) = dr1 at hit
    cases hit with
    | empty hd _ =>
      exact H.deadStore.empty s.pc hk _ _ hdr hd s x rfl hbi hsafe
    | main hpad hctr hpr hnop =>
      rw [← hdr] at hpr
      rw [← hst1] at hnop
      exact insnSim_main hD H hk hpk hpad hctr hpr hnop hca1 s x rfl hbi hsafe
  · exact insnSim_oob hD (Nat.le_of_not_lt hk) s x rfl hbi hsafe

/-- `decode_sound` from the decoder's acceptance directly. -/
theorem decode_sound_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (hnr : regionPad mode callSites = none)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env) (K : Int)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.K = K ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.Safe = Safe ∧
      (Hyps S → ∀ s x, BInv S s x → SafeFrom Safe c s → FnSim ctx E c (BInv S) (ExitRel S) s x) := by
  obtain ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h8, h9⟩ :=
    decodes_of_ok hdec hnr c hc hm ctx E K x0 Owned lo padOf Safe
  refine ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h8, h9, fun H => ?_⟩
  subst h1 h2 h3 h9
  exact decode_sound hD H

end Ryo.Proofs.DecodeSound
