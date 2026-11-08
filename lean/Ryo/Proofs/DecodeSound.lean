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
stores, the `arg` flags, `Indexed`), the window end `K`, the state `x0` at the function's entry (the caller's
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
  other callee-saved registers as at entry, on PE `rsi`/`rdi` too), and the frame bytes in
  `[-F + 32, frameLo)` (on PE a handler call's stack argument) private and `Uninit`
  (`slots`: no frame write of the code reaches them, `boundsOk`, nor a call's answer,
  `argSlotsCheck`; it gives `Hyps.peStackArg`, `Discharge/PeStackArg.lean`), and every escaped
  object the range of an `Escape` scope, in the run of leading `arg`s of one before `pc`
  (`esc`, `Discharge/EscFrom.lean`).
- `ExitRel`: a return with the return registers related, `rip` the return address, `rsp` and
  the callee-saved registers as the caller left them, and the world related; a tail call at the
  callee's entry (`EntryAt`) with `rsp` as at entry; an unwind out of the function is not a
  state of this function (the unwinder lands in a caller), so never related here.

**Per instruction** (§4). `InsnSim` at `k` splits into the prologue of the iteration (the
padding's `nop`s, `reach_padding`; the counter check, `reach_counter`) and the body
(`BodySim`), one lemma per shape the decoder reads (`bodySim_arg`, `bodySim_call'`,
`bodySim_inline`, `bodySim_handler'`, `bodySim_ret`, `bodySim_unreachable`, `bodySim_jmp`,
`bodySim_island`, `bodySim_dense`), dispatched by `bodySim_of_read` over `ProtoRead`/`InsnRead`.
Proved helpers: decoded branches are canonical (`branch_canonical`), every iteration starts at a
relocation boundary (`boundary_start`), R's scopes never stop with `noBehavior` (`noNB_scopes`);
facts of the decoder: the prologue read item by item (`read_instructions_prologue`), landing
pads are `lpad`s (`pad_lpad`, so not leading `arg`s, `pad_not_leadArg`), protos lie within the
code (`posOf_le_size`, so `posOf_lt_32`). `bodySim_inline` is `DSWork/Inline.lean`'s
`bodySim_inline'` (with `InlineEscBounded`, proved from `FrameSep`'s `EscIn` by
`inlineEscBounded_of`; it also takes `inlineClsOk`, proved in `RyoProofs`, `InlineBelowLink`, from `FrameBounds.writesOff`, and
`CacheRegsOk`, from `DecodeLink/CacheRegs.lean`'s `cacheRegsOk_of_decodes`).

**Files.** `DecodeSound/Basic.lean`: §1–§3 and §4's helpers, `bodySim_unreachable`,
`bodySim_jmp`, `reach_padding`, `boundary_start`. `DSWork/Boundary.lean`: the decoder facts.
`DSWork/{Arg,Ret,Island,Counter,Call,Handler}.lean`: `bodySim_arg`, `bodySim_ret`,
`bodySim_island`, `reach_counter`, `bodySim_call'`, `bodySim_handler'`. This file: the inline and dense-switch bodies (`bodySim_inline`, `bodySim_dense`), the dispatch, `insnSim_main`, §5.

**`decode_sound`** (§5): from `decodeReduced … = .ok d`, `read_instructions_prologue`,
`instructions_read` and `iters_indexed` give the layout; `reducedOf_insns` the instructions; then
`fnSim_of_insnSim`. The switch tables' facts (`HdlTables`: table starts at relocation
boundaries, code and targets below `2 ^ 31`) are checked: `decodeChecked` runs `tablesCheck`,
and `decode_sound` takes its success (`htc`), from which `DecodeLink.Tables.hdlTables_of_check`
gives them.

**Hypotheses** (`Hyps`). Trusted: the handler, `resume`, call, island and trip contracts on the
environment's `ret` (`HandlerContract`, `ResumeContract`: `resume`'s handler is assembly, outside
`opSem`, and comes back only at a landing pad; `CallContract`, `IslandContract`,
`TripContract`; on PE every return keeps `rsi`/`rdi`, `peSaved`), the personality's call-site
lookup (`unwinderReadsLsda`: the unwinder's pad for a return address is the LSDA's), the link map (`Linked`,
`Globals`). Proved elsewhere, outside the default build: `OpFacts` of every opcode (`opFacts`,
`RyoProofs/OpFacts.lean`), `InlineOk` of every inline opcode (`inlineOk`, by `inlineOps_ok`,
`RyoProofs/InlineOk.lean`) and each inline class of its shape and `clsOk` (`inlineClsOk`, by
`inlineOps_shape`, `RyoProofs/InlineOps.lean`, and `inlineOps_clsOk`). Both frame modes: without a frame pointer the relations are read on the virtual state
`S.virt x` (`rbp := rsp + F`, `Ryo/X86/VirtFp.lean`; the real `rbp` kept, `RbpOk`), frame operands
checked not to wrap off `rsp` (`spDispCheck`). Handler calls may have PE's stack argument
(`HandlerStackArg`; `resume`'s fit in registers, `resume_regs_le`). PE's pad region (the cleanup code after the body, which the exception dispatcher's language
handler calls on its own stack, `Call.PadCalled`): the relation is `RBInv` (`BInv` in the body,
`RegionInv` in the region): body instructions at cleanup sites enter it (`rinsnSim_peClean`,
`DecodeSound/RegionEntry.lean`), region instructions keep it (`rinsnSim_region`,
`DSWork/*Region.lean`); `decodes_of_ok` reads the body and the region as two passes
(`decodes_of_ok_region`, `DecodeSound/RegionRead.lean`; Lean-only check: the body's protos lie
before the region's entry). For the region: `Hyps.resumePe` (trusted: `resume`'s handler never returns
on PE), `SepAcross.handlerAt` (the handler's home space off the frame), `EnvApart.stackOff` (no
runtime-owned byte on the stack), `DeadStoreSim.emptyR`/`inlineR`, and the checks
`regionLayoutOk` (no `ret` or tail call in the region) and `regionCallsCheck` (in
`stackSizesCheck`: no stack arguments for a call there). Open prerequisites, each a named
hypothesis to be discharged later:

- of the decoded code, checkable (the decoder or a check could reject the code otherwise):
  `windowOk` (`windowCheck`: `frameTop ≤ 16 + argSize ≤ 2 ^ 31`, run by check-image;
  with `boundsOk`, checked by `decodeBounded`, it gives `Hyps.frameBounds` for the window
  `[-F, K)`, `K = 16 + argSize`, `Discharge/FrameBounds.lean`);
- privacy after the scopes: none open (a call's result slots may be in escaped objects:
  `CallLemmas.exec_stores` writes them like a `load` does, `sound_load_esc`). The link slots
  (`LinkPrivate`: in no escaped object or `Lend` extent) and the `arg` destinations (`ArgPrivate`) are checked: `decodeChecked` runs `privCheck` (`Hyps.privOk`),
  which with `FrameInv.esc` gives `Hyps.linkPrivate` and `Hyps.argPrivate`
  (`Discharge/PrivCheck.lean`);
- the environment and the layout (not checkable from the function): `sepAcross` (the frame
  separation across handler calls, calls and islands, `SepAcross`: `FrameSep.extend`'s
  allocation facts, not yet in the contracts), `envApart` (`EnvApart`: the frame window not
  runtime-owned, live allocations neither runtime-owned nor below `rsp`, the symbol slots and
  the JIT record off the stack), `codeApart` (`CodeApart`: nothing the function or its environment writes is code or
  rodata), `envOutside` (`EnvOutside`: the environment's entries are `Env.out` states);
- facts of the decoder and linker not yet exposed: `deadStore` (`DeadStoreSim`: the steps of
  dropped stores). The LSDA as linked against `cleanupAt` (`PadsLinked`) is derived by `Hyps.padsLinked`
  (`Discharge/PadsLinked.lean`) from `callSitesCheck` (`Decodes.callSitesOk`, run by
  `decodeChecked`: call sites sorted by start and aligned with the calls) and the trusted
  `unwinderReadsLsda`. Relocated fields within the code (`RelocsIn`) are checked too:
  `decodeChecked` runs `relocsInCheck`, whose success (`Hyps.relocsInOk`,
  `relocsInOk_of_decodes`) gives `Hyps.relocsIn` (`Discharge/RelocsIn.lean`). So is the cache
  the decoder used being empty at branch targets and landing pads (`CacheCleared`):
  `decodeChecked` runs `cacheClearedCheck` (`Hyps.cacheOk`, `cacheOk_of_decodes`, with
  `Decodes.targetsRead`, the first pass's targets), which gives `Hyps.cacheTargets` and
  `Hyps.cacheCleared` (`Discharge/CacheCleared.lean`). So are the leading `arg`s (`ArgsOk`:
  they read distinct argument registers of the convention, and no branch target is one):
  `decodeChecked` runs `argsLeadCheck` (`Hyps.argsChecked`, `argsChecked_of_decodes`), which
  with the decoder gives `Hyps.argsUntargeted` and `Hyps.argsOk` (`Discharge/ArgsOk.lean`).

The entry (R's `entry` against the entry's counter check, the prologue and the stack probe, up
to instruction 0's boundary) is `DecodeSound/Entry.lean` (`reach_entry`, `entry_sound`), from the
exact read of the code before the body (`Decodes.entry`, `read_instructions_entry`). Not
covered: the trip's `Done` outcome (a transfer into JIT code, which simulates the same
function).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.DSWork.Boundary
import Ryo.Proofs.DecodeSound.Region
import Ryo.Proofs.DecodeSound.RegionRead
import Ryo.Proofs.DecodeSound.Dense
import Ryo.Proofs.DSWork.Arg
import Ryo.Proofs.DSWork.Ret
import Ryo.Proofs.DSWork.Counter
import Ryo.Proofs.DSWork.Island
import Ryo.Proofs.DSWork.Call
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.Dense
import Ryo.Proofs.DSWork.Inline
import Ryo.Proofs.DecodeLink.Bounds
import Ryo.Vm.Frame
import Ryo.Proofs.DecodeLink.Tables
import Ryo.Proofs.DecodeLink.CacheRegs
import Ryo.Proofs.Discharge.RelocsIn
import Ryo.Proofs.Discharge.CacheCleared
import Ryo.Proofs.DecodeSound.RegionEntry
import Ryo.Proofs.DSWork.CallRegion
import Ryo.Proofs.DSWork.IslandRegion
import Ryo.Proofs.DSWork.HandlerRegion
import Ryo.Proofs.DSWork.InlineRegion
import Ryo.Proofs.DSWork.ResumeRegion

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

/-! #### The inline and dense-switch bodies

Proved in `DSWork/*.lean`: `bodySim_arg` (Arg), `bodySim_ret` (Ret), `bodySim_island` (Island),
`reach_counter` (Counter), `bodySim_call'` (Call), `bodySim_handler'` (Handler),
`bodySim_inline'` (Inline, with the proved `InlineEscBounded` (`inlineEscBounded_of`),
`inlineClsOk`, `InlineBelowLink` (`inlineBelowLink_of`) and `CacheRegsOk`
(`cacheRegsOk_of_decodes`));
`bodySim_unreachable`, `bodySim_jmp` in `DecodeSound/Basic.lean`. Here: `bodySim_inline`
and `bodySim_dense`. -/

/-- An inline sequence without a dropped store: `DSWork/Inline.lean`'s `bodySim_inline'`, its
extra hypotheses: `InlineEscBounded` (`inlineEscBounded_of`), `inlineClsOk` from `Hyps`, `InlineBelowLink`
from `frameBounds` (`inlineBelowLink_of`) and `CacheRegsOk` from the decoder's caches
(`cacheRegsOk_of_decodes`, `k` below the protos' count). -/
theorem bodySim_inline (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur cur' c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache') (hn : NoArg S.fr S.body p a cur)
    (hc : (callInsn S.fr (S.dr k)).run cur = .ok (none, cur'))
    (hr : (inlineInsn (S.used k) (S.dr k) true).run cur' = .ok (some (q, cache', dr'), c'))
    (hq : q.dropped = false) :
    BodySim S k p (S.used k) := by
  have hk : k ≤ S.r.protos.toList.length := by rw [Array.length_toList]; exact Nat.le_of_lt hP.lt
  exact bodySim_inline' hD H (inlineBelowLink_of H.frameBounds) (inlineEscBounded_of H)
    H.inlineClsOk (CacheRegs.cacheRegsOk_of_decodes hD k hk) hP hn hc hr hq

/-! #### The dense switch (helpers in `DecodeSound/Dense.lean`) -/

set_option maxHeartbeats 1000000 in
/-- A dense switch: `denseSwitch`'s inline index computation (`Asm.denseIndex`) and its jump
table, standing in for R's `switch.dense` handler call. R: the scopes, then `opSem`'s index
(`dense_opSem`, no writes) and PE's home space made `Uninit` (`R.clearHome`, as for any handler
call: `hdl_frameInv_clear`); x86, in either frame form, on the virtual state: with a frame
pointer `Dense.dense_switch_steps` to the entry's target; without one the same runs
(`Dense.denseIndex_exec`, `Switch.exec_switch`) from `FForm.virtAt`, fetched in the `spFrame`
form by `steps_of_run_last_fb` (`dense_vt`, `Hyps.spDisp`). The registers but `rax`/`rcx` kept
(`Dense.Keep`, `hdl_switch_regs`), so `FrameInv` of R's state after the scopes
(`dense_frameInv`, `hdl_frameInv_regs`); the target's cache cleared (`CacheCleared.targets`). -/
theorem bodySim_denseB (_hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (denseSwitch S.fr).run cur = .ok (some q, c')) (htable : HdlTables S) :
    BodySimBE S k p := by
  intro s xr hs hfR hrip _ hsafe
  obtain ⟨x, hxdef⟩ : ∃ x, x = S.virt xr := ⟨_, rfl⟩
  have hf : FrameInv S s x := by rw [hxdef]; exact hfR.1
  have hcur := noArg_insn hn (InsnRead.dense (ro := S.ro) hr)
  subst hcur
  obtain ⟨w, sl, base, n, its, at_, tb, pE, args, es, hden, hq, hargs, hd1, hd2, hes⟩ :=
    dense_read hr
  subst hq
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFacts_insnOf hP
  simp only [InsnOf] at hio
  obtain ⟨t', rfl, ht'⟩ := hio
  obtain ⟨rs', rfl, hmap⟩ := thenMap_table ht'
  rw [← hs] at hi
  have hres : denseOp w ≠ .resume := by cases w <;> decide
  have hun : denseOp w ≠ .unreachable := by cases w <;> decide
  obtain ⟨s1, vals, hsc, hu, hno, hsucc⟩ := handler_rside hi hsafe hres hun
  -- The frame after the scopes, still related to `x`; R's step.
  have hfb := H.frameBounds
  obtain ⟨hr1, -⟩ := memRel_foldlM _ (hfb.scope_size _) hf.rrel hf.mem hsc
  obtain ⟨ch, hop⟩ := dense_opSem hargs hu hr1.rel hno
  generalize hI : Dense.denseIdx w (x.memW w (x.ea (M.frame sl))) base n = idx at hop
  obtain ⟨st'', pc, hcl, hpc, hstep⟩ := hsucc ch _ _ hop
  obtain ⟨j, hj, hget⟩ := hdl_succ_table hpc
  cases hj
  obtain ⟨hil, -⟩ := List.getElem?_eq_some_iff.1 hget
  have hlen' : rs'.length = es.length := by
    have := congrArg List.length hmap
    simpa using this
  have hi2 : idx < es.length := hlen' ▸ hil
  have hpe : posOf S.r pc = es[idx].toNat := by
    have h1 : (rs'.map (posOf S.r))[idx]? = (es.map (·.toNat))[idx]? := by rw [hmap]
    rw [List.getElem?_map, List.getElem?_map, hget, List.getElem?_eq_getElem hi2] at h1
    simpa using h1
  have htg : es[idx].toNat ∈ S.r.protos[k].targets := by
    rw [hpk]
    simp [Proto.targets, R.Then.targets] <;> exact ⟨es[idx], List.getElem_mem hi2, rfl⟩
  have hnl : ¬ LeadArg S pc := H.argsUntargeted _hD k hlt _ htg pc hpe
  -- The table in memory (either form: entries have no frame operand).
  obtain ⟨htb, hbtb, hes31⟩ :=
    htable (atPos (atPos S.body p) at_) tb pE es k rfl rfl rfl (Dec.at_iff.2 hd2) hes
      (List.ne_nil_of_length_pos (by omega)) hlt (fun e he => by
        rw [hpk]
        simp [Proto.targets, R.Then.targets] <;> exact ⟨e, he, rfl⟩)
  have htab : CodeAt S.ctx x.mem (es.map (Item.tableEntry tb)) tb.toNat :=
    entries_codeAtF hf.code hes hbtb
  -- The machine: from `xr` to a real state at the entry's target whose virtual state `z` has
  -- `x`'s memory and registers but `rax`/`rcx`.
  have hM : ∃ xr'' z, Steps S.ctx xr xr'' ∧ S.virt xr'' = z ∧ RbpOk S xr'' ∧
      xr''.rip = addrAt S.ctx es[idx].toNat ∧ z.mem = x.mem ∧
      ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → z.regs i = x.regs i := by
    cases hsp : S.body.spFrame with
    | none =>
      -- The frame-pointer form: the virtual state is the real one.
      have hx : x = xr := by rw [hxdef]; exact S.virt_eq hsp
      have hrip' : x.rip = addrAt S.ctx p := by rw [hx]; exact hrip
      subst hI
      have hlk : LinkOk S.ctx x.mem (atPos S.body p) S.rs :=
        ⟨hf.code.fields, hf.code.sorted, hf.code.loaded, hf.code.small, hsp⟩
      obtain ⟨hca, -, -⟩ := hlk.dec (hd1.append hd2) hP.bound
      have hcan : Canon (its ++ Switch.switchItems tb) p :=
        (canon_append _ _ _).2 ⟨handler_canon_of (Dense.dense_items_canonical hden),
          dense_switch_canon _ _⟩
      obtain ⟨x'', hst, -, hrip'', hmem, -, y, -, hk, hex⟩ :=
        Dense.dense_switch_steps (ctx := S.ctx) hden hcan hca hrip' htab hi2 htb hes31
      exact ⟨x'', x'', (by rw [← hx]; exact hst), S.virt_eq hsp, rbpOk_of_sp hsp, hrip'', hmem,
        fun i h0 h1 => (hdl_switch_regs hex i h0 h1).trans (hk.2.2 i h0 h1)⟩
    | some F =>
      -- Without a frame pointer: the items run on `virtAt`, fetched in their `spFrame` form.
      have hvt := dense_vt S.ctx F hden tb
      have e : its ++ Switch.switchItems tb =
          (its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx]) ++ [Item.jmpRax] := by
        simp [Switch.switchItems]
      have hdc := hd1.append hd2
      rw [e] at hdc
      obtain ⟨hca, -, -⟩ := (hf.code.atPos p).dec hdc hP.bound
      rw [hxdef, setup_virt_mem] at hca
      obtain ⟨xv, hxv⟩ : ∃ xv, xv = FForm.virtAt S.body.spFrame
          ((its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx]) ++ [Item.jmpRax]) xr :=
        ⟨_, rfl⟩
      obtain ⟨ja, hxa⟩ := nf_virtAt_jump S
        ((its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx]) ++ [Item.jmpRax]) xr
      have hxa' : xv = x.jump ja := by rw [hxv, hxa, hxdef]
      have hxvr : xv.regs = x.regs := by rw [hxa']; try rfl
      have hxvm : xv.mem = x.mem := by rw [hxa']; try rfl
      have hxvl : xv.memW w (xv.ea (M.frame sl)) = x.memW w (x.ea (M.frame sl)) := by
        rw [hxa']; try rfl
      -- The virtual run: the index computation, then the table jump.
      obtain ⟨y, hy, hya, -, -, hk⟩ := Dense.denseIndex_exec (ctx := S.ctx) hden xv
      have hrax : y.reg .rax = BitVec.ofNat 64 idx := by rw [hya, hxvl, hI]
      have ht' : CodeAt S.ctx y.mem (es.map (Item.tableEntry tb)) tb.toNat := by
        rw [hk.1, hxvm]; exact htab
      obtain ⟨x'', he2, hrip2, -, -, hmem2, -, -⟩ :=
        Switch.exec_switch ht' hi2 hrax htb (hes31 _ (List.getElem_mem hi2))
      have he' : execItems S.ctx
          ((its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx]) ++ [Item.jmpRax]) xv =
          .ok x'' := by
        rw [← e, X86.execItems_append, hy]; exact he2
      have hfr : FetchRun S.ctx (InCode S.ctx (((its ++ [Item.leaTable tb, Item.loadTableEntry,
          Item.addRaxRcx]) ++ [Item.jmpRax]).map (FForm.item S.body.spFrame)) p)
          (its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx]) xv := by
        refine fetchRun_of_forall (fun i hm => ?_) xv
        rcases List.mem_append.1 hm with hm | hm
        · exact Dense.dense_items_ok S.ctx hden i hm
        · simp only [List.mem_cons, List.not_mem_nil, or_false] at hm
          rcases hm with rfl | rfl | rfl
          · exact Switch.leaTable_straight S.ctx tb
          · exact Switch.loadTableEntry_straight S.ctx
          · exact Switch.addRaxRcx_straight S.ctx
      have hcan : Canon (((its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx]) ++
          [Item.jmpRax]).map (FForm.item S.body.spFrame)) p := by
        rw [hsp]
        exact handler_canon_of fun i hi => by
          obtain ⟨i0, hi0, rfl⟩ := List.mem_map.mp hi
          rcases List.mem_append.mp hi0 with hi0 | hi0
          · exact (hvt.1 i0 hi0).can
          · simp only [List.mem_singleton] at hi0
            subst hi0
            exact hvt.2.2
      have hreg : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x''.regs i = x.regs i := fun i h0 h1 =>
        (hdl_switch_regs he2 i h0 h1).trans ((hk.2.2 i h0 h1).trans (congrFun hxvr i))
      have hmx : x''.mem = x.mem := hmem2.trans (hk.1.trans hxvm)
      subst hxv
      have hst := steps_of_run_last_fb (ctx := S.ctx) (fb := S.body.spFrame)
        (S := InCode S.ctx (((its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx]) ++
          [Item.jmpRax]).map (FForm.item S.body.spFrame)) p)
        (items := its ++ [Item.leaTable tb, Item.loadTableEntry, Item.addRaxRcx])
        (j := Item.jmpRax)
        (fun i hi => by
          rcases List.mem_append.mp hi with hi | hi
          · exact (hvt.1 i hi).rbp
          · simp only [List.mem_singleton] at hi
            subst hi
            exact hvt.2.1)
        (fun F' hF' => by
          have e2 : F' = F := (Option.some.inj (hsp.symm.trans hF')).symm
          rw [e2]
          exact H.spDisp F hsp (atPos S.body p) rfl hsp _ _ _ hdc)
        (fun i hi => (hvt.1 i hi).rip) (fun m h => by cases h)
        (fun i hi => (hvt.1 i hi).rsp) hcan hca hrip (fun _ h => h) hfr he'
      -- Back to the real state: `rbp` the entry's, and `virt` of it is `x''`.
      have hr0 : xr.reg .rbp = S.x0.reg .rbp := hfR.2 (by simp [Setup.fb, hsp])
      rw [hr0] at hst
      have hxs : x = xr.setReg .rbp (xr.rsp + F.setWidth 64) := hxdef.trans (nf_virt_some hsp xr)
      have h5 : x''.reg .rbp = x.reg .rbp := by
        show x''.regs 5 = x.regs 5
        exact hreg 5 (by decide) (by decide)
      have h4 : x''.rsp = x.rsp := by
        show x''.regs 4 = x.regs 4
        exact hreg 4 (by decide) (by decide)
      have hx5 : x.reg .rbp = x.rsp + F.setWidth 64 := by
        rw [hxs, X86.State.reg_setReg, FForm.rsp_setReg_rbp]
      refine ⟨S.real x'', x'', hst, Setup.virt_real S (fun F' hF' => ?_), fun _ => ?_,
        (nf_real_rip _ _ _).trans hrip2, hmx, hreg⟩
      · have e2 : F' = F := (Option.some.inj (hsp.symm.trans hF')).symm
        rw [e2, h5, h4]; exact hx5
      · show (FForm.real S.body.spFrame (S.x0.reg .rbp) x'').reg .rbp = _
        rw [hsp]
        exact X86.State.reg_setReg x'' .rbp _
  obtain ⟨xr'', _, hst, rfl, hok, hripz, hmem, hreg⟩ := hM
  -- The machine state after the jump.
  have hrbp : (S.virt xr'').reg .rbp = x.reg .rbp := by
    show (S.virt xr'').regs 5 = x.regs 5
    exact hreg 5 (by decide) (by decide)
  have hrsp : (S.virt xr'').rsp = x.rsp := by
    show (S.virt xr'').regs 4 = x.regs 4
    exact hreg 4 (by decide) (by decide)
  have hsv : ∀ i, Saved S.c.mode.pe i → (S.virt xr'').regs i = x.regs i := by
    intro i hi
    apply hreg <;> rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;> decide
  -- R's step clears PE's home space (`R.clearHome`), though the inline switch calls nothing.
  have hfi'' := hdl_frameInv_regs
    (hdl_frameInv_clear H (dense_frameInv H hf hsc hnl) (hdl_home_le H hi) hcl) hmem hrbp hrsp
    hsv hnl
  have hc := H.cacheTargets k hlt _ htg
  have hrip'' : xr''.rip = addrAt S.ctx (posOf S.r pc) := by rw [hripz, hpe]
  have hused : S.used pc = { pe := S.c.mode.pe } := by
    simp only [Setup.used, hpe, hc, ↓reduceIte]
  refine Reach.steps hst (.done (.inl ⟨_, .step hstep,
    ⟨⟨⟨hfi'', hok⟩, .inr ⟨hrip'', ?_⟩⟩, .inr ⟨hrip'', hused⟩⟩⟩))
  show CacheInv (S.used pc) (S.virt xr'')
  rw [hused]
  exact CacheInv.emptyPe _ _

theorem bodySim_dense (_hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (denseSwitch S.fr).run cur = .ok (some q, c')) (htable : HdlTables S) :
    BodySim S k p (S.used k) :=
  BodySimB.used (bodySim_denseB _hD H hP hn hr htable).toB

/-! #### The dispatch over what the decoder read -/

/-- `insn` reads a dense switch (`denseSwitch`), or else (`denseSwitch` finding none at the
cursor) `insnCore`'s instruction. -/
theorem insn_split {fr : Vm.Frame} {ro : ByteArray} {c c' : Cursor} {q : Proto}
    (h : (insn fr ro).run c = .ok (q, c')) :
    (denseSwitch fr).run c = .ok (some q, c') ∨
      ((∀ c'', (denseSwitch fr).run c ≠ .ok (some q, c'')) ∧ (insnCore fr ro).run c = .ok (q, c')) := by
  unfold insn at h
  obtain ⟨r, c1, h1, h2⟩ := bind_ok h
  cases r with
  | some p =>
    obtain ⟨rfl, rfl⟩ := pure_ok h2
    exact .inl h1
  | none =>
    have := denseSwitch_none h1
    subst this
    refine .inr ⟨fun c'' he => ?_, h2⟩
    rw [h1] at he
    cases he

theorem noHandler_ops : Full.Opcode.ret ≠ Full.Opcode.unreachable ∧ Full.Opcode.ret ≠ Full.Opcode.jmp ∧
    Full.Opcode.ret ≠ Full.Opcode.island := by decide

/-- A proto the decoder read at `p` is simulated by its shape's body lemma. -/
theorem bodySim_of_read (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore}
    (hP : ProtoFacts S k p q c' cache')
    (hr : ProtoRead S.fr S.ro true S.body p (S.used k) (S.dr k) (S.args k) q c' cache' dr')
    (htable : HdlTables S) :
    BodySim S k p (S.used k) := by
  generalize ha : S.args k = a at hr
  cases hr with
  | arg h => exact bodySim_arg hD H ha hP h
  | call hn h => exact bodySim_call' hD H hP hn h
  | inline hn hc h =>
    cases hq : q.dropped
    · exact bodySim_inline hD H hP hn hc h hq
    · exact H.deadStore.inline k p _ _ _ q c' cache' dr' hn hc h hq
  | insn hn hc hi h =>
    have e1 := callInsn_none hc
    have e2 := inlineInsn_none hi
    subst e1 e2
    rcases insn_split h with hd | ⟨hnd, hcore⟩
    · exact bodySim_dense hD H hP hn hd htable
    have hir := insnCore_read hcore
    have hir' := hir
    cases hir' with
    | handler => exact bodySim_handler' hD H hP hn hir (by simp) hnd htable
    | ret => exact bodySim_ret hD H hP hn hir rfl
    | unreachable => exact bodySim_unreachable hD H hP hn hir rfl
    | jmp => exact bodySim_jmp hD H hP hn hir rfl
    | island => exact bodySim_island hD H hP hn hir rfl
    | resume => exact bodySim_handler' hD H hP hn hir (by simp) hnd htable
    | dense h => exact (hnd _ h).elim

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
    (hnop : S.c.inRegion (k + 1) = false →
      NopRead S.fr S.callSites S.body q c'.pos (S.start (k + 1)))
    (hcache : S.c.inRegion (k + 1) = false → S.cache (k + 1) = cache') (htable : HdlTables S)
    (hbody : S.c.inRegion k = false) (hncl : NotCleanup S k) :
    InsnSimAt S k := by
  intro s x hs hbi hsafe
  obtain ⟨hfR, hat⟩ := hbi
  have hf := hfR.1
  have hp1 : posOf S.r k = p1 := by rw [posOf_eq hk, hq]
  have hpr : ProtoRead S.fr S.ro true S.body p2 (S.used k) (S.dr k) (S.args k) q c' cache' dr' := by
    have e : (if (some S.targets).any (sortedContains · p1) then ({ pe := S.fr.mode.pe } : Cache)
        else S.cache k) = S.used k := by simp [Setup.used, Setup.fr, hp1, Option.any]
    rw [e] at hpr
    exact hpr
  have hb0 := boundary_start hD hf.code (prologue_dec hD) k (Nat.le_of_lt hk)
  -- The boundary at `p1`, and the code there, from memory (the padding's `nop`s are the same
  -- items in both forms).
  obtain ⟨ns, hns, hcode, hp1e, hb1⟩ := padRead_codeAt hf.code hpad hb0
  rw [setup_virt_mem] at hcode
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
    bodySim_of_read hD H ⟨hk, ⟨p1, counter, by simp [hk, hq]⟩, hinsn, hb2, hnop, hcache, hargs,
      hbody, hncl⟩ hpr htable
  -- From `p1` with the cache `used k`.
  have from_p1 : ∀ y, FrameInvR S s y → y.rip = addrAt S.ctx p1 →
      CacheInv (S.used k) (S.virt y) → Reach S.ctx S.E (SNext S s) y := by
    intro y hfy hry hcy
    cases hctr with
    | none => exact body hb1 s y hs hfy hry hcy hsafe
    | check hcnt hd =>
      have hb2 := (hfy.1.code.dec hd hb1).2.2
      refine reach_counter hD H hk (by rw [hq]) (.check hcnt hd) hb1 hs hfy hry hcy ?_
      exact fun z hfz hrz hcz => body hb2 s z hs hfz hrz hcz hsafe
  rcases hat with ⟨hrip, hci⟩ | ⟨hrip, hci⟩
  · rw [hs] at hrip hci
    refine reach_padding hns hcode hrip fun y h1 h2 h3 h4 => ?_
    -- The `nop`s keep everything but `rip`, so also the virtual state's.
    have hsp : y.rsp = x.rsp := by simp [State.rsp, State.reg, h1]
    have hvr : (S.virt y).regs = (S.virt x).regs :=
      funext fun i => setup_virt_regs_congr S (P := fun _ => True) (fun i _ => by rw [h1]) hsp i trivial
    have hvx : (S.virt y).xmm = (S.virt x).xmm := by rw [setup_virt_xmm, setup_virt_xmm, h2]
    have hvm : (S.virt y).mem = (S.virt x).mem := by rw [setup_virt_mem, setup_virt_mem, h3]
    have hok : RbpOk S y := fun h => by
      have e : y.reg .rbp = x.reg .rbp := by simp [State.reg, h1]
      exact e.trans (hfR.2 h)
    refine from_p1 y ⟨hf.congr hvr hvx hvm, hok⟩ (by rw [h4, ← hp1e]) ?_
    have hcy := inv_congr hci hvr hvm
    unfold Setup.used
    split
    · exact CacheInv.emptyPe _ _
    · exact hcy
  · rw [hs, hp1] at hrip
    rw [hs] at hci
    exact from_p1 x hfR hrip hci

/-! ### PE's pad region and its cleanup sites (PE-T2, PE-T3/T4)

`rinsnSim_peClean` (T2): a body instruction at a PE cleanup site, by shape through
`insnSim_prefix` (the padding and counter check of `insnSim_main` for any post-condition) and
the body lemmas reaching `RSNext` (`bodySim_call_fpRB`, `bodySim_islandRB`, `handler_resume_pe`,
the others by `rsnext_of_snext`). `rinsnSim_region` (T3/T4): `regionSim_main` over the region's
iterations, dispatched by `regionSim_of_read`. -/

/-- The body's targets are the whole function's when no successor is in the region. -/
theorem rsnext_of_snext {s : R.RState} {x : X86.State}
    (hs : ∀ s', RNext S.c s s' → S.c.inRegion s'.pc = false)
    (h : Reach S.ctx S.E (SNext S s) x) : Reach S.ctx S.E (RSNext S s) x := by
  refine h.mono ?_
  rintro x' (⟨s', hn, hb⟩ | hd)
  · exact .inl ⟨s', hn, (rbInv_body (hs s' hn)).2 hb⟩
  · exact .inr hd

/-- `insnSim_main`'s prefix for any post-condition `Q`: the padding (from the iteration's
start) and the counter check, then `body` from `p2` with the cache `S.used k`. -/
theorem insnSim_prefix (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p1 p2 : Nat} {counter : Option (Nat × Nat)} {q : Proto}
    (hk : k < S.r.protos.size) (hq : S.r.protos[k] = { q with pos := p1, counter })
    (hpad : PadRead S.body (S.start k) p1) (hctr : CounterRead S.fr S.body p1 counter p2)
    (_hbody : S.c.inRegion k = false) {Q : R.RState → X86.State → Prop}
    (body : Boundary S.rs p2 → ∀ s x, s.pc = k → (∃ xb, BInv S s xb) → FrameInvR S s x →
      x.rip = addrAt S.ctx p2 → CacheInv (S.used k) (S.virt x) → RSafe S.Safe S.c s →
      Reach S.ctx S.E (Q s) x) :
    ∀ s x, s.pc = k → BInv S s x → RSafe S.Safe S.c s → Reach S.ctx S.E (Q s) x := by
  intro s x hs hbi hsafe
  have hbx : ∃ xb, BInv S s xb := ⟨x, hbi⟩
  obtain ⟨hfR, hat⟩ := hbi
  have hf := hfR.1
  have hp1 : posOf S.r k = p1 := by rw [posOf_eq hk, hq]
  have hb0 := boundary_start hD hf.code (prologue_dec hD) k (Nat.le_of_lt hk)
  obtain ⟨ns, hns, hcode, hp1e, hb1⟩ := padRead_codeAt hf.code hpad hb0
  rw [setup_virt_mem] at hcode
  have from_p1 : ∀ y, FrameInvR S s y → y.rip = addrAt S.ctx p1 →
      CacheInv (S.used k) (S.virt y) → Reach S.ctx S.E (Q s) y := by
    intro y hfy hry hcy
    cases hctr with
    | none => exact body hb1 s y hs hbx hfy hry hcy hsafe
    | check hcnt hd =>
      have hb2 := (hfy.1.code.dec hd hb1).2.2
      refine reach_counter hD H hk (by rw [hq]) (.check hcnt hd) hb1 hs hfy hry hcy ?_
      exact fun z hfz hrz hcz => body hb2 s z hs hbx hfz hrz hcz hsafe
  rcases hat with ⟨hrip, hci⟩ | ⟨hrip, hci⟩
  · rw [hs] at hrip hci
    refine reach_padding hns hcode hrip fun y h1 h2 h3 h4 => ?_
    have hsp : y.rsp = x.rsp := by simp [State.rsp, State.reg, h1]
    have hvr : (S.virt y).regs = (S.virt x).regs :=
      funext fun i => setup_virt_regs_congr S (P := fun _ => True) (fun i _ => by rw [h1]) hsp i trivial
    have hvx : (S.virt y).xmm = (S.virt x).xmm := by rw [setup_virt_xmm, setup_virt_xmm, h2]
    have hvm : (S.virt y).mem = (S.virt x).mem := by rw [setup_virt_mem, setup_virt_mem, h3]
    have hok : RbpOk S y := fun h => by
      have e : y.reg .rbp = x.reg .rbp := by simp [State.reg, h1]
      exact e.trans (hfR.2 h)
    refine from_p1 y ⟨hf.congr hvr hvx hvm, hok⟩ (by rw [h4, ← hp1e]) ?_
    have hcy := inv_congr hci hvr hvm
    unfold Setup.used
    split
    · exact CacheInv.emptyPe _ _
    · exact hcy
  · rw [hs, hp1] at hrip
    rw [hs] at hci
    exact from_p1 x hfR hrip hci

/-- A `BodySimRB` body as `insnSim_prefix`'s `body` (frame-pointer form; `RSNextE` is in
`RSNext`). -/
theorem rbody_of_RB {k p : Nat} {cache : Cache} (hfp : S.c.mode.framePointer = true)
    (h : BodySimRB S k p) :
    ∀ s x, s.pc = k → (∃ xb, BInv S s xb) → FrameInvR S s x → x.rip = addrAt S.ctx p →
      CacheInv cache (S.virt x) → RSafe S.Safe S.c s → Reach S.ctx S.E (RSNext S s) x := by
  intro s x hs hbx hfy hry _ hsafe
  refine (h s x hs ((frameInvR_iff hfp).1 hfy) hry hbx hsafe).mono ?_
  rintro x' (⟨s', hn, hb', -⟩ | hd)
  · exact .inl ⟨s', hn, hb'⟩
  · exact .inr hd

/-- `S.fixResume` keeps the opcode, the position and the counter. -/
theorem rgn_fix_keep (q : Proto) : (S.fixResume q).op = q.op ∧ (S.fixResume q).pos = q.pos ∧
    (S.fixResume q).counter = q.counter := by
  unfold Setup.fixResume
  split
  · split <;> exact ⟨rfl, rfl, rfl⟩
  · exact ⟨rfl, rfl, rfl⟩

/-- The region proto's opcode is the iteration's. -/
theorem rgn_op_of {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    (hP : ProtoFactsR S k p q c' cache') : (S.r.protos[k]'hP.lt).op = q.op := by
  obtain ⟨p1, ctr, hpq⟩ := hP.proto
  rw [(Array.getElem?_eq_some_iff.1 hpq).2]
  exact (rgn_fix_keep _).1

/-- `bodySim_of_read` in PE's pad region: by shape (no `arg`: `region_not_leadArg`; no `ret` or
tail call: `region_shape`; dropped inline stores by `DeadStoreSim.inlineR`). -/
theorem regionSim_of_read (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore}
    (hP : ProtoFactsR S k p q c' cache')
    (hr : ProtoRead S.frR S.ro true S.body p (S.used k) (S.dr k) (S.args k) q c' cache' dr')
    (htable : HdlTables S) :
    RegionSim S k p (S.used k) := by
  generalize ha : S.args k = a at hr
  cases hr with
  | arg _ =>
    exact absurd ha (by rw [(region_not_leadArg hD (Nat.le_of_lt hP.lt) hP.inR).2]; decide)
  | call hn h => exact (regionSim_call hD H hP hn h).used
  | inline hn hc h =>
    cases hq : q.dropped
    · exact regionSim_inline hD H hP hn hc h hq
    · exact H.deadStore.inlineR k p _ _ _ q c' cache' dr' hP.inR hn hc h hq
  | insn hn hc hi h =>
    have e1 := callInsn_none hc
    have e2 := inlineInsn_none hi
    subst e1 e2
    rcases insn_split h with hd | ⟨hnd, hcore⟩
    · exact (regionSim_dense hD H hP hn hd htable).used
    have hir := insnCore_read hcore
    have hir' := hir
    cases hir' with
    | handler =>
      by_cases hres : (S.r.protos[k]'hP.lt).op = .resume
      · exact (regionSim_resume hD H hP hn hir (by rw [← rgn_op_of hP]; exact hres)).used
      · exact (regionSim_handler hD H hP hn hir (by simp)
          (by rw [← rgn_op_of hP]; exact hres) hnd htable).used
    | ret =>
      have hsh : Full.Opcode.ret.info.shape = .ret := by
        set_option maxRecDepth 100000 in decide
      exact ((region_shape hD hP.lt hP.inR).1 (by rw [rgn_op_of hP]; exact hsh)).elim
    | unreachable => exact (regionSim_unreachable hD H hP hn hir rfl).used
    | jmp => exact (regionSim_jmp hD H hP hn hir rfl).used
    | island => exact (regionSim_island hD H hP hn hir rfl).used
    | resume => exact (regionSim_resume hD H hP hn hir rfl).used
    | dense h => exact (hnd _ h).elim

/-- Instruction `k` of a pad-region iteration (as `insnSim_main`; no counter check,
`RegionFacts.heads`): the padding, then the body (`regionSim_of_read`). The iteration's proto is
`read`'s after `resumeSlots` (`S.fixResume`). -/
theorem regionSim_main (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p1 p2 : Nat} {counter : Option (Nat × Nat)} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hk : k < S.r.protos.size)
    (hreg : S.c.inRegion k = true)
    (hq : S.r.protos[k] = S.fixResume { q with pos := p1, counter })
    (hpad : PadRead S.body (S.start k) p1) (hctr : CounterRead S.frR S.body p1 counter p2)
    (hpr : ProtoRead S.frR S.ro (some S.targets).isSome S.body p2
      (if (some S.targets).any (sortedContains · p1) then { pe := S.frR.mode.pe } else S.cache k)
      (S.dr k) (S.args k) q c' cache' dr')
    (hnop : NopRead S.frR S.callSites S.body q c'.pos (S.start (k + 1)))
    (hcache : S.cache (k + 1) = cache') (htable : HdlTables S) :
    RInsnSimAt S k := by
  intro s x hs hrbi hsafe
  have hreg' : S.c.inRegion s.pc = true := by rw [hs]; exact hreg
  obtain ⟨e, hR, hat⟩ := (rbInv_region hreg').1 hrbi
  obtain ⟨hkop, hkpos, hkctr⟩ := rgn_fix_keep (S := S) { q with pos := p1, counter }
  have hp1 : posOf S.r k = p1 := by rw [posOf_eq hk, hq]; exact hkpos
  -- No counter check in the region (`RegionFacts.heads`).
  have hc0 : counter = none := by
    cases hc : counter with
    | none => rfl
    | some v =>
      have h1 : S.r.protos[k].counter.isSome = true := by rw [hq, hkctr]; simp [hc]
      have := hD.region.heads k hk h1
      rw [hreg] at this; cases this
  subst hc0
  cases hctr
  have hpr : ProtoRead S.frR S.ro true S.body p1 (S.used k) (S.dr k) (S.args k) q c' cache' dr' := by
    have e : (if (some S.targets).any (sortedContains · p1) then ({ pe := S.frR.mode.pe } : Cache)
        else S.cache k) = S.used k := by simp [Setup.used, Setup.frR, Setup.fr, hp1, Option.any]
    rw [e] at hpr
    exact hpr
  have hb0 := boundary_start hD hR.code (prologue_dec hD) k (Nat.le_of_lt hk)
  obtain ⟨ns, hns, hcode, hp1e, hb1⟩ := padRead_codeAt hR.code hpad hb0
  have hinsn : ∃ i, S.c.d.insns[k]? = some i ∧ ∀ hk : k < S.r.protos.size,
      InsnOf (posOf S.r) S.r.protos[k] i := by
    have h1 := (reducedOf_insns hD.reduced)
    have hk' : k < S.c.d.insns.size := h1.1 ▸ hk
    exact ⟨S.c.d.insns[k], by simp [hk'], fun hk => h1.2 k hk hk'⟩
  have body : RegionSim S k p1 (S.used k) :=
    regionSim_of_read hD H ⟨hk, ⟨p1, none, by simp [hk, hq]⟩, hinsn, hb1, hnop, hcache, hreg⟩
      hpr htable
  rcases hat with ⟨hrip, hci⟩ | ⟨hrip, hci⟩
  · rw [hs] at hrip hci
    refine reach_padding hns hcode hrip fun y h1 _ h3 h4 => ?_
    refine body e s y hs (hR.congr h1 h3) (by rw [h4, ← hp1e]) ?_ hsafe
    have hcy := inv_congr hci h1 h3
    unfold Setup.used
    split
    · exact CacheInv.emptyPe _ _
    · exact hcy
  · rw [hs, hp1] at hrip
    rw [hs] at hci
    exact body e s x hs hR hrip hci hsafe

end Insn

/-! ## 5. `decode_sound` -/

/-! ### The entry's code as `read` reads it -/

/-- `checkStubs` with the entry's stub `(es, eb)`: the entry stub `lea r11, [rip + rec];
call [r11 + 8]; jmp eb` at `es`, read after the loop heads' from `bodyEnd` (a property of
positions that holds at `bodyEnd` and is kept by every `Dec` reading holds at `es`). -/
theorem checkStubs_entry {es eb : Nat} {protos : Array Proto} {heads : Array Nat}
    {bodyEnd limit : Nat} {c c' : Cursor} {u : Unit} (R : Nat → Prop)
    (hR : ∀ p L q, R p → Dec c p L q → R q) (hR0 : R bodyEnd)
    (h : (checkStubs (some (es, eb)) protos heads bodyEnd limit).run c = .ok (u, c')) :
    R es ∧ ∃ (t : BitVec 32) (long : Bool) (q : Nat), t.toNat = eb ∧
      Dec c es (entryStub t long) q := by
  unfold checkStubs at h
  dsimp only at h
  obtain ⟨u1, c1, h1, h⟩ := bind_ok h
  rw [run_setPos] at h1
  cases h1
  obtain ⟨u2, c2, h2, -⟩ := bind_ok h
  rw [Std.Legacy.Range.forIn'_eq_forIn'_range'] at h2
  have key := sl_forIn'_each (fun c2 => c2 = atPos c c2.pos ∧ R c2.pos)
    (fun n => n = heads.size → ∃ stub back,
      (heads.toList.map (fun i => protos[i]!.counter.getD (0, 0)) ++ [(es, eb)])[n]? =
        some (stub, back) ∧ R stub ∧
        ∃ (t : BitVec 32) (long : Bool) (q : Nat), Dec c stub (entryStub t long) q ∧
          t.toNat = back)
    _ _ _ _ _ _ ?step ⟨rfl, hR0⟩ h2
  case step =>
    intro n hmem b cur r cur' hP0 hr
    obtain ⟨hP, hRc⟩ := hP0
    have hlt0 : n < (heads.toList.map (fun i => protos[i]!.counter.getD (0, 0)) ++
        [(es, eb)]).length := by
      obtain ⟨i, hi, hni⟩ := List.mem_range'.1 hmem
      simp only [Std.Legacy.Range.size, List.length_append, List.length_map,
        Array.length_toList, List.length_singleton] at hi hni ⊢
      omega
    generalize heq : (heads.toList.map (fun i => protos[i]!.counter.getD (0, 0)) ++
      [(es, eb)])[n]'hlt0 = sb at hr
    obtain ⟨stub, back⟩ := sb
    try dsimp only at hr
    obtain ⟨at_, c1, h1, hr⟩ := bind_ok hr
    obtain ⟨rfl, hc1⟩ := pos_run' h1
    subst c1
    try dsimp only at hr
    rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨hne, hr⟩
    · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
    have hs : cur.pos = stub := by simpa using hne
    obtain ⟨c2, d2, e2, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
    have P2 := sl_trans hP e2
    try dsimp only at hr
    rcases sl_ite_ok hr with ⟨hlt, hr⟩ | ⟨hlt, hr⟩
    · obtain ⟨c3, d3, e3, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
      obtain ⟨c4, d4, e4, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
      obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      obtain ⟨d5, e5⟩ := item_dec h5
      have P3 := sl_trans P2 e3
      have P4 := sl_trans P3 e4
      have P5 := sl_trans P4 e5
      have d := (sl_dec hP d2).append ((sl_dec P2 d3).append ((sl_dec P3 d4).append (sl_dec P4 d5)))
      have hR5 := hR _ _ _ hRc d
      try dsimp only at hr
      split at hr
      · try dsimp only at hr
        rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨-, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        refine ⟨⟨P5, hR5⟩, ?_, _, rfl⟩
        intro hn
        exact absurd hlt (by omega)
      · first
          | exact (err_ok hr).elim
          | (obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim)
    · obtain ⟨c3, d3, e3, hr⟩ := check_dec (fun _ _ _ hh => err_ok hh) hr
      obtain ⟨x, c5, h5, hr⟩ := bind_ok hr
      obtain ⟨d5, e5⟩ := item_dec h5
      have P3 := sl_trans P2 e3
      have P5 := sl_trans P3 e5
      have d := (sl_dec hP d2).append ((sl_dec P2 d3).append (sl_dec P3 d5))
      have hR5 := hR _ _ _ hRc d
      simp only [List.singleton_append] at d
      try dsimp only at hr
      split at hr
      · try dsimp only at hr
        rcases sl_ite_ok hr with ⟨-, hr⟩ | ⟨hb, hr⟩
        · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
        obtain ⟨rfl, rfl⟩ := pure_ok hr
        refine ⟨⟨P5, hR5⟩, ?_, _, rfl⟩
        intro _
        exact ⟨stub, back, List.getElem?_eq_some_iff.mpr ⟨_, heq⟩, hs ▸ hRc, _, _, _,
          by rw [← hs]; exact d, by simpa using hb⟩
      · first
          | exact (err_ok hr).elim
          | (obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim)
  obtain ⟨stub, back, hL, hRs, t, long, q, hd, ht⟩ :=
    key heads.size (by simp [List.mem_range', Std.Legacy.Range.size] <;> omega) rfl
  simp [List.getElem?_append_right] at hL
  obtain ⟨rfl, rfl⟩ := hL
  exact ⟨hRs, t, long, q, ht, hd⟩

/-- `read_instructions_targets` with the entry's code (the read from position 0): the counter
check and its stub (`CheckReadC`, the stub at a position every property kept by `Dec` reaches from
the instructions' end) and the prologue of the frame size, up to the body's cursor (in either
frame form: `readFrame` reads the check and the prologue with the code's cursor, and their items
read alike in the body's, `Dec.of_entryKind`). -/
theorem read_instructions_entry {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' cT : Cursor} {r : ReadResult} {ts : Array Nat}
    (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hT : (readTargets ro callSites dropped mode).run c = .ok (ts, cT))
    (hnr : regionPad mode callSites = none) (hc0 : c.pos = 0) :
    ∃ (c0 c1 : Cursor) (stub : Option Nat) (padded : Array Bool),
      c0 = bodyCursor c mode r.frameSize c0.pos ∧
      (instructions ⟨r.frameSize, mode, false⟩ ro dropped (some ts) stub c.code.size
        callSites).run c0 = .ok ((r.protos, padded), c1) ∧
      (mode.framePointer = true → ∃ items, Dec c0 c.pos items c0.pos) ∧
      (∃ p1, CheckReadC c0 mode
          (fun s => ∀ R : Nat → Prop, (∀ p L q, R p → Dec c0 p L q → R q) → R c1.pos → R s) p1 ∧
        Dec c0 p1 (prologue r.frameSize mode) c0.pos) := by
  unfold Vm.read at h
  unfold readTargets at hT
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  obtain ⟨eT, d1, g1, hT⟩ := bind_ok hT
  obtain ⟨he1, hd1⟩ := dm_run_det h1 g1
  subst he1
  rw [← hd1] at hT
  have hc1 := readFrame_body h1
  obtain ⟨items, hd⟩ := readFrame_dec h1
  obtain ⟨q1, hq1, hqd⟩ := readFrame_exact h1
  dsimp only at h
  dsimp only at hT
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨x', d2, g2, hT⟩ := bind_ok hT
  obtain ⟨hx', hd2⟩ := get_run g2
  rw [hx', hd2] at hT
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  have hra : ra = none ∧ c3 = c1 := by
    unfold regionEntry at h3; rw [hnr] at h3
    exact ⟨(pure_ok h3).1.symm, (pure_ok h3).2.symm⟩
  rw [hra.1, hra.2] at h
  obtain ⟨ra', d3, g3, hT⟩ := bind_ok hT
  have hra' : ra' = none ∧ d3 = c1 := by
    unfold regionEntry at g3; rw [hnr] at g3
    exact ⟨(pure_ok g3).1.symm, (pure_ok g3).2.symm⟩
  rw [hra'.1, hra'.2] at hT
  have hsize : c1.code.size = c.code.size := by rw [hc1]; rfl
  dsimp only at h
  dsimp only at hT
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  obtain ⟨hb4, hc4⟩ := pos_run' h4
  subst hb4
  rw [hc4] at h
  obtain ⟨body', d4, g4, hT⟩ := bind_ok hT
  obtain ⟨hb4', hd4⟩ := pos_run' g4
  subst hb4'
  rw [hd4] at hT
  obtain ⟨⟨p1, pd1, be1⟩, c5, h5, h⟩ := bind_ok h
  have e5 := readParts_pos h5
  obtain ⟨⟨p1', pd1', be1'⟩, d5, g5, hT⟩ := bind_ok hT
  obtain ⟨hp1, -⟩ := dm_run_det h5 g5
  have hp1' : p1 = p1' := congrArg Prod.fst hp1
  rw [← hp1'] at hT
  dsimp only at hT
  obtain ⟨hts, -⟩ := pure_ok hT
  dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, h6, h⟩ := bind_ok h
  have e6 := readParts_pos h6
  have hpass : ∃ c7, bodyEnd = c7.pos ∧ (instructions ⟨fs, mode, false⟩ ro dropped
      (some ((p1.toList.flatMap Proto.targets).toArray.qsort (· < ·))) (entry.map (·.1))
      c.code.size callSites).run (atPos c5 c1.pos) = .ok ((protos, padded), c7) := by
    unfold readParts at h6
    obtain ⟨u, c7, h7, h6⟩ := bind_ok h6
    rw [run_setPos] at h7; cases h7
    obtain ⟨⟨ps, pd⟩, c8, h8, h6⟩ := bind_ok h6
    obtain ⟨be, c9, h9, h6⟩ := bind_ok h6
    obtain ⟨rfl, rfl⟩ := pos_run' h9
    obtain ⟨u, c10, h10, h6⟩ := bind_ok h6
    obtain ⟨he, -⟩ := pure_ok h6
    cases he
    rw [hsize] at h8
    exact ⟨_, rfl, h8⟩
  obtain ⟨c7, hbe, hc7⟩ := hpass
  rw [hts] at hc7
  dsimp only at h
  obtain ⟨u, c8, h8, h⟩ := bind_ok h
  have e8 : c8 = c6 := by
    first
      | exact (pure_ok h8).2.symm
      | (simp only [checkRegionStart] at h8; exact (pure_ok h8).2.symm)
  obtain ⟨heads, c9, h9, h⟩ := bind_ok h
  have e9 := sl_loopHeads_pos h9
  obtain ⟨u', c10, h10, h⟩ := bind_ok h
  simp only [Nat.lt_irrefl, ↓reduceIte] at h
  obtain ⟨protos', c11, h11, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pure_ok h11
  obtain ⟨acts, c12, -, h⟩ := bind_ok h
  obtain ⟨he, -⟩ := pure_ok h
  cases he
  rw [e8] at e9
  have hb : atPos c5 c1.pos = bodyCursor c mode fs (atPos c5 c1.pos).pos := by
    rw [e5]
    show atPos (atPos c1 c5.pos) c1.pos = _
    rw [hc1]; rfl
  have e9' : c9 = atPos (atPos c5 c1.pos) c9.pos := by
    refine (sl_trans (sl_trans e5 e6) e9).trans ?_
    show atPos c1 c9.pos = atPos c5 c9.pos
    rw [e5]
    try rfl
  have hx : mode.framePointer = true → atPos c5 c1.pos = atPos c c1.pos := fun hfp => by
    rw [hb]; simp [bodyCursor, hfp]
  refine ⟨_, c7, _, padded, hb, hc7, fun hfp => ⟨items, ?_⟩, ?_⟩
  · show Dec (atPos c5 c1.pos) c.pos items c1.pos
    rw [hx hfp, Dec.at_iff]
    exact hd
  have hcv : ∀ {p L q}, Dec c p L q → L.all entryKind = true → Dec (atPos c5 c1.pos) p L q :=
    fun d hk => Dec.of_entryKind (c := c) ((congrArg Cursor.code hb).trans rfl)
      ((congrArg Cursor.fields hb).trans rfl) d hk
  obtain ⟨hk1, hk2⟩ := hq1
  refine ⟨q1, ⟨fun hc => (hk1 hc).1.trans hc0, fun hc => ?_⟩, hcv hqd (prologue_entryKind _ _)⟩
  obtain ⟨t, l, hdc, hen⟩ := hk2 hc
  subst hen
  obtain ⟨-, tb, bl, q, htb, hds⟩ :=
    checkStubs_entry (fun _ => True) (fun _ _ _ _ _ => trivial) trivial h10
  exact ⟨t, l, tb, bl, q, hc0 ▸ hcv hdc rfl, htb,
    fun R hR hR0 => (checkStubs_entry R (fun p L q hp hd => hR p L q hp (sl_dec e9' hd))
      (by rw [hbe]; exact hR0) h10).1, sl_dec e9' hds⟩

/-- `read` with a pad region at `p`, in its two passes: the body's `instructions` pass (`S.fr`,
`droppedBody`, up to the region's entry), the counter stubs from its end to the entry, the
region's pass (`readRegion`: `S.frR`, `droppedRegion`, from the region's first instruction), how
`resumeSlots` leaves their protos (`resumeFix`), the entry's facts (as `read_instructions_entry`),
and the loop heads' and counter stubs' facts (as `ctr_read_heads`, `sl_read_stubs`). -/
theorem read_region_passes {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    {c c' cT : Cursor} {r : ReadResult} {ts : Array Nat} {p : Nat}
    (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c'))
    (hT : (readTargets ro callSites dropped mode).run c = .ok (ts, cT))
    (hp : regionPad mode callSites = some p) (hc0 : c.pos = 0) :
    ∃ (c0 cB cR : Cursor) (stub : Option Nat) (pB pR : Array Bool) (qB qR : Array Proto),
      c0 = bodyCursor c mode r.frameSize c0.pos ∧
      (instructions ⟨r.frameSize, mode, false⟩ ro
        (dropped.takeWhile (·.at_ < p - regionEntryLen)) (some ts) stub (p - regionEntryLen)
        callSites).run c0 = .ok ((qB, pB), cB) ∧
      (∃ items, Dec c0 cB.pos items (p - regionEntryLen)) ∧
      (instructions ⟨r.frameSize, mode, true⟩ ro
        (dropped.dropWhile (·.at_ < p - regionEntryLen)) (some ts) none c.code.size
        callSites).run (atPos c0 p) = .ok ((qR, pR), cR) ∧
      r.protos.size = qB.size + qR.size ∧
      (∀ k (hk : k < qB.size), r.protos[k]! = qB[k]) ∧
      (∀ j (hj : j < qR.size), r.protos[qB.size + j]! =
        resumeFix (lpadSlotOf r.protos) ⟨r.frameSize, mode, false⟩ qR[j]) ∧
      leastCleanupPad r.actions = some qB.size ∧
      0 < qB.size ∧
      p ≤ c.code.size ∧
      (mode.framePointer = true → ∃ items, Dec c0 c.pos items c0.pos) ∧
      (∃ p1, CheckReadC c0 mode
          (fun s => ∀ R : Nat → Prop, (∀ p L q, R p → Dec c0 p L q → R q) → R cB.pos → R s) p1 ∧
        Dec c0 p1 (prologue r.frameSize mode) c0.pos) ∧
      (∀ R : Nat → Prop, (∀ p L q, R p → Dec c0 p L q → R q) → R cB.pos →
        ∀ k (hk : k < r.protos.size) stub back, r.protos[k].counter = some (stub, back) →
          R stub) ∧
      (∀ k (hk : k < r.protos.size), r.protos[k].counter.isSome = true →
        ∃ k', ∃ hk' : k' < r.protos.size, posOf r k ∈ r.protos[k'].targets) ∧
      (∃ c1 c9 : Cursor, c1 = bodyCursor c mode r.frameSize c1.pos ∧ c9 = atPos c1 c9.pos ∧
        ∀ k (hk : k < r.protos.size) stub back, r.protos[k].counter = some (stub, back) →
          ∃ n t long q, t.toNat = back ∧ Dec c9 stub [.lea .r11 .record,
            .setReg .rax (BitVec.ofNat 64 n), .callR11 16, .branch .always t long] q) := by
  unfold Vm.read at h
  unfold readTargets at hT
  obtain ⟨⟨entry, fs⟩, c1, h1, h⟩ := bind_ok h
  obtain ⟨eT, d1, g1, hT⟩ := bind_ok hT
  obtain ⟨he1, hd1⟩ := dm_run_det h1 g1
  subst he1
  rw [← hd1] at hT
  have hc1 := readFrame_body h1
  obtain ⟨items, hd⟩ := readFrame_dec h1
  obtain ⟨q1, hq1, hqd⟩ := readFrame_exact h1
  dsimp only at h
  dsimp only at hT
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  obtain ⟨hx, hc2⟩ := get_run h2
  rw [hx, hc2] at h
  obtain ⟨x', d2, g2, hT⟩ := bind_ok hT
  obtain ⟨hx', hd2⟩ := get_run g2
  rw [hx', hd2] at hT
  obtain ⟨ra, c3, h3, h⟩ := bind_ok h
  have hra : regionEntryLen ≤ p ∧ ra = some (p - regionEntryLen) ∧ c3 = c1 := by
    unfold regionEntry at h3; rw [hp] at h3
    try dsimp only at h3
    split at h3
    · exact (err_ok h3).elim
    · rename_i hlt
      exact ⟨by omega, (pure_ok h3).1.symm, (pure_ok h3).2.symm⟩
  obtain ⟨hle, hra1, hra2⟩ := hra
  rw [hra1, hra2] at h
  obtain ⟨ra', d3, g3, hT⟩ := bind_ok hT
  have hra' : ra' = some (p - regionEntryLen) ∧ d3 = c1 := by
    unfold regionEntry at g3; rw [hp] at g3
    try dsimp only at g3
    split at g3
    · exact (err_ok g3).elim
    · exact ⟨(pure_ok g3).1.symm, (pure_ok g3).2.symm⟩
  rw [hra'.1, hra'.2] at hT
  have hsize : c1.code.size = c.code.size := by rw [hc1]; rfl
  dsimp only at h
  dsimp only at hT
  obtain ⟨body, c4, h4, h⟩ := bind_ok h
  obtain ⟨hb4, hc4⟩ := pos_run' h4
  subst hb4
  rw [hc4] at h
  obtain ⟨body', d4, g4, hT⟩ := bind_ok hT
  obtain ⟨hb4', hd4⟩ := pos_run' g4
  subst hb4'
  rw [hd4] at hT
  obtain ⟨⟨p1, pd1, be1⟩, c5, h5, h⟩ := bind_ok h
  have e5 := readParts_pos h5
  obtain ⟨⟨p1', pd1', be1'⟩, d5, g5, hT⟩ := bind_ok hT
  obtain ⟨hp1, -⟩ := dm_run_det h5 g5
  have hp1' : p1 = p1' := congrArg Prod.fst hp1
  rw [← hp1'] at hT
  dsimp only at hT
  obtain ⟨hts, -⟩ := pure_ok hT
  dsimp only at h
  obtain ⟨⟨protos, padded, bodyEnd⟩, c6, h6, h⟩ := bind_ok h
  have e6 := readParts_pos h6
  obtain ⟨qB, qR, pB, pR, cB, hrunB, hcntB, hallB, hrunR, hx6⟩ := readParts_region_runs h6
  simp only [Prod.mk.injEq] at hx6
  obtain ⟨rfl, rfl, rfl⟩ := hx6
  rw [hts] at hrunB hrunR
  rw [hsize, show p - regionEntryLen + regionEntryLen = p by omega] at hrunR
  -- the positions: the body's before its limit, the region's from `p`
  have hqR0 : ∀ y, qR.toList.head? = some y → p ≤ y.pos := by
    have := iters_head_pos (instructions_read hrunR).1
    simpa using this
  have hrsB : ((qB ++ qR).toList.takeWhile
      (fun x => decide (x.pos < p - regionEntryLen + regionEntryLen))).length = qB.size := by
    rw [Array.toList_append]
    have := takeWhile_len_append (P := fun x => decide (x.pos < p - regionEntryLen + regionEntryLen))
      qB.toList qR.toList (fun x hx => by
        have := hallB x hx; simp only [Option.getD_some] at this; simp; omega)
      (fun y hy => by have := hqR0 y hy; simp; omega)
    simpa using this
  -- the rest of `read`
  dsimp only at h
  simp only [hrsB] at h
  obtain ⟨u, c8, h8, h⟩ := bind_ok h
  simp only [checkRegionStart] at h8
  obtain ⟨hcond, e8⟩ := expect_ok h8
  simp only [Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at hcond
  obtain ⟨⟨⟨hrs0, hrsp⟩, -⟩, hlay⟩ := hcond
  obtain ⟨heads, c9, h9, h⟩ := bind_ok h
  have e9 := sl_loopHeads_pos h9
  have hh := sl_heads h9
  have hhd := ctr_heads_of h9
  obtain ⟨u', c10, h10, h⟩ := bind_ok h
  have hlt : qB.size < (qB ++ qR).size := by
    by_cases hl : qB.size < (qB ++ qR).size
    · exact hl
    · rw [Array.getElem?_eq_none (by omega)] at hrsp
      simp at hrsp
  simp only [hlt, ↓reduceIte] at h
  obtain ⟨out, c11, h11, h⟩ := bind_ok h
  obtain ⟨acts, c12, h12, h⟩ := bind_ok h
  obtain ⟨he, -⟩ := pure_ok h
  subst he
  obtain ⟨hosz, hoix⟩ := resumeSlots_eq h11
  have hslot := resumeSlots_lpadSlot h11
  have hspec := resumeSlots_spec h11
  -- the cursors
  rw [e8] at e9
  have hb : atPos c5 c1.pos = bodyCursor c mode fs (atPos c5 c1.pos).pos := by
    rw [e5]
    show atPos (atPos c1 c5.pos) c1.pos = _
    rw [hc1]; rfl
  have e9' : c9 = atPos (atPos c5 c1.pos) c9.pos := by
    refine (sl_trans (sl_trans e5 e6) e9).trans ?_
    show atPos c1 c9.pos = atPos c5 c9.pos
    rw [e5]
    try rfl
  have hx1 : mode.framePointer = true → atPos c5 c1.pos = atPos c c1.pos := fun hfp => by
    rw [hb]; simp [bodyCursor, hfp]
  have hcv : ∀ {p L q}, Dec c p L q → L.all entryKind = true → Dec (atPos c5 c1.pos) p L q :=
    fun d hk => Dec.of_entryKind (c := c) ((congrArg Cursor.code hb).trans rfl)
      ((congrArg Cursor.fields hb).trans rfl) d hk
  have hent0 := sl_readFrame_entry h1
  -- the protos
  have hgetB : ∀ k (hk : k < qB.size), (qB ++ qR)[k]! = qB[k] := by
    intro k hk
    rw [getElem!_pos (qB ++ qR) k (by simp; omega), Array.getElem_append_left hk]
  have hgetR : ∀ j (hj : j < qR.size), (qB ++ qR)[qB.size + j]! = qR[j] := by
    intro j hj
    rw [getElem!_pos (qB ++ qR) (qB.size + j) (by simp; omega),
      Array.getElem_append_right (Nat.le_add_right _ _)]
    simp
  have hcnt : ∀ k (hk : k < out.size), out[k].counter = (qB ++ qR)[k]!.counter := by
    intro k hk
    rw [← getElem!_pos out k hk]
    exact (hspec.2 k).2.1
  have hc5 : c5.code.size = c.code.size := by rw [e5]; exact hsize
  refine ⟨atPos c5 c1.pos, cB, _, entry.map (·.1), pB, pR, qB, qR, hb, hrunB, ?stubs, hrunR,
    by show out.size = _; rw [hosz]; simp, fun k hk => ?bodyP, fun j hj => ?regP,
    actionsOf_least h12 (by omega), hrs0, ?psz, fun hfp => ⟨items, ?fpg⟩, ?ent, ?stubR, ?heads,
    ?stubs2⟩
  case bodyP =>
    show out[k]! = qB[k]
    rw [hoix k (by simp; omega), if_neg (show ¬ qB.size ≤ k by omega), hgetB k hk]
  case regP =>
    show out[qB.size + j]! = resumeFix (lpadSlotOf out) ⟨fs, mode, false⟩ qR[j]
    rw [hoix _ (by simp; omega), if_pos (Nat.le_add_right _ _), hgetR j hj, hslot]
  case fpg =>
    show Dec (atPos c5 c1.pos) c.pos items c1.pos
    rw [hx1 hfp, Dec.at_iff]
    exact hd
  case stubs =>
    cases hcm : mode.counters with
    | false =>
      have hend : cB.pos = p - regionEntryLen := by
        rcases hcntB with h0 | h0
        · rw [hcm] at h0; cases h0
        · exact h0
      exact ⟨[], by rw [← hend]; exact .nil _⟩
    | true =>
      obtain ⟨⟨es, eb⟩, hee⟩ := Option.isSome_iff_exists.mp (hent0 hcm)
      rw [hee] at h10
      exact checkStubs_end (fun s => ∃ items, Dec (atPos c5 c1.pos) cB.pos items s)
        (fun _ L _ ⟨its, d⟩ hd => ⟨its ++ L, d.append (sl_dec e9' hd)⟩) ⟨[], .nil _⟩ h10
  case psz =>
    have hq0 : 0 < qR.size := by simp at hlt; omega
    have hle0 := instructions_pos_le hrunR (Nat.le_of_eq hc5.symm) qR[0]
      (Array.getElem_mem_toList hq0)
    have hrsp' := hrsp
    rw [Array.getElem?_append_right (Nat.le_refl _), Nat.sub_self] at hrsp'
    simp only [Option.map_eq_some_iff] at hrsp'
    obtain ⟨y, hy, hyp⟩ := hrsp'
    have hy' : qR[0] = y := by
      rw [Array.getElem?_eq_getElem hq0] at hy
      exact Option.some.inj hy
    have : y.pos ≤ c.code.size := by rw [← hy']; exact Nat.le_trans hle0 (Nat.le_of_eq hc5)
    omega
  case ent =>
    obtain ⟨hk1, hk2⟩ := hq1
    refine ⟨q1, ⟨fun hc => (hk1 hc).1.trans hc0, fun hc => ?_⟩, hcv hqd (prologue_entryKind _ _)⟩
    obtain ⟨t, l, hdc, hen⟩ := hk2 hc
    subst hen
    obtain ⟨-, tb, bl, q, htb, hds⟩ :=
      checkStubs_entry (fun _ => True) (fun _ _ _ _ _ => trivial) trivial h10
    exact ⟨t, l, tb, bl, q, hc0 ▸ hcv hdc rfl, htb,
      fun R hR hR0 => (checkStubs_entry R (fun p L q hp hd => hR p L q hp (sl_dec e9' hd))
        hR0 h10).1, sl_dec e9' hds⟩
  case stubR =>
    intro R hR hR0 k hk stub back hc
    have hk0 : k < (qB ++ qR).size := by rw [← hosz]; exact hk
    have hc0' : (qB ++ qR)[k].counter = some (stub, back) := by
      rw [← getElem!_pos (qB ++ qR) k hk0, ← hcnt k hk]
      exact hc
    obtain ⟨hcm, n, hn, hkn⟩ := hh k hk0 (by rw [hc0']; rfl)
    have := sl_checkStubs_R R (fun p L q hp hd => hR p L q hp (sl_dec e9' hd)) hR0 h10
      (hent0 hcm) n hn
    rw [hkn, getElem!_pos (qB ++ qR) k hk0, hc0'] at this
    exact this
  case heads =>
    intro k hk hcs
    have hk0 : k < (qB ++ qR).size := by rw [← hosz]; exact hk
    have hcs0 : (qB ++ qR)[k].counter.isSome = true := by
      rw [← getElem!_pos (qB ++ qR) k hk0, ← hcnt k hk]
      exact hcs
    obtain ⟨k', hk', hmem⟩ := hhd k hk0 hcs0
    obtain ⟨hlc, hlt2⟩ := regionLayoutOk_spec hlay
    -- the head is in the body (the region has no counters), so its branch is too
    have hkb : k < qB.size := by
      refine Classical.byContradiction fun hn => ?_
      have := hlc k hk0 (by omega)
      rw [getElem!_pos (qB ++ qR) k hk0] at this
      rw [this] at hcs0
      simp at hcs0
    have hmem' : (qB ++ qR)[k]!.pos ∈ (qB ++ qR)[k']!.targets := by
      rw [getElem!_pos (qB ++ qR) k' hk']
      have e : ((qB ++ qR).map (·.pos))[k]! = (qB ++ qR)[k]!.pos := by
        rw [getElem!_pos ((qB ++ qR).map (·.pos)) k (by simpa using hk0), Array.getElem_map,
          getElem!_pos (qB ++ qR) k hk0]
      rw [← e]; exact hmem
    have hk'b : k' < qB.size := by
      refine Classical.byContradiction fun hn => ?_
      have := (hlt2 k' hk' _ hmem' k hk0 rfl).2 (by omega)
      omega
    have hk'o : k' < out.size := by rw [hosz]; exact hk'
    refine ⟨k', hk'o, ?_⟩
    have e1 : out[k'] = (qB ++ qR)[k'] := by
      rw [← getElem!_pos out k' hk'o, hoix k' hk', if_neg (show ¬ qB.size ≤ k' by omega),
        getElem!_pos _ k' hk']
    have hk1 : k < out.size := hk
    rw [posOf_eq hk]
    show out[k].pos ∈ out[k'].targets
    rw [← getElem!_pos out k hk1, (hspec.2 k).1, e1, ← getElem!_pos (qB ++ qR) k' hk']
    exact hmem'
  case stubs2 =>
    refine ⟨c1, c9, hc1, sl_trans (sl_trans e5 e6) e9, ?_⟩
    intro k hk stub back hc
    have hk0 : k < (qB ++ qR).size := by rw [← hosz]; exact hk
    have hc0' : (qB ++ qR)[k].counter = some (stub, back) := by
      rw [← getElem!_pos (qB ++ qR) k hk0, ← hcnt k hk]
      exact hc
    obtain ⟨hcm, n, hn, hkn⟩ := hh k hk0 (by rw [hc0']; rfl)
    obtain ⟨stub', back', hL, t, long, q, ht, hd⟩ := sl_checkStubs h10 (hent0 hcm) n hn
    rw [hkn, getElem!_pos (qB ++ qR) k hk0, hc0'] at hL
    simp only [Option.getD_some, Prod.mk.injEq] at hL
    obtain ⟨rfl, rfl⟩ := hL
    exact ⟨n, t, long, q, ht, hd⟩

/-- PE-T1: `read`'s layout of PE's pad region (`RegionFacts`: `readParts`' region branch,
`checkRegionStart`, `regionPad` the least cleanup pad, `actionsOf`, `loopHeads`' cross check), for
any `Setup` whose read, reduced code, mode, call sites and body cursor are the decoder's. -/
theorem regionFacts_of_read {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c' : Cursor}
    (hread : (Vm.read rodata callSites dropped.toList scopes mode).run
      { code := code.data, pos := 0, fields := .relocs relocs } = .ok (S.r, c'))
    (hred : reducedOf S.r mode.pe = .ok S.c.d) (hm : S.c.mode = mode)
    (hcs : S.callSites = callSites)
    (hbody : S.body = bodyCursor { code := code.data, pos := 0, fields := .relocs relocs } mode
      S.r.frameSize S.body.pos) :
    RegionFacts S callSites mode :=
  { start := regionFacts_start hread hred hm hbody
    noStart := regionFacts_noStart hread hred
    pads := regionFacts_pads
    catchPads := regionFacts_catchPads hread hred hm
    resume := regionFacts_resume hread hred hm
    noCross := regionFacts_noCross hread hred hm
    heads := regionFacts_heads hread hred hm
    bodyEnd := regionFacts_bodyEnd hread hred hm
    entryBody := regionFacts_entryBody hread hred hm }

/-- Without a pad region no instruction is in one (a region start is a cleanup pad, which
makes `regionPad` `some`). -/
theorem inRegion_false_of_noPad {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {cc cc' : Cursor}
    {r : ReadResult} {c : R.Code}
    (hread : (Vm.read ro callSites dropped scopes mode).run cc = .ok (r, cc'))
    (hred : reducedOf r mode.pe = .ok c.d) (hm : c.mode = mode)
    (hnr : regionPad mode callSites = none) (k : Nat) : c.inRegion k = false := by
  unfold R.Code.inRegion
  cases hpe : c.mode.pe with
  | false => rfl
  | true =>
    cases hst : c.d.regionStart with
    | none => simp
    | some rs =>
      exfalso
      obtain ⟨i0, hact⟩ := cleanup_action hred (List.min?_mem hst)
      obtain ⟨p, hp⟩ := regionPad_some hread (by rw [← hm]; exact hpe) hact
      rw [hnr] at hp
      cases hp

/-- `decodes_of_ok` without a PE pad region (`regionPad … = none`): one `instructions` pass
over the whole function. -/
theorem decodes_of_ok_noRegion {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (hnr : regionPad mode callSites = none)
    (hcs : callSitesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (cleans : BitVec 64 → Bool) (region : BitVec 64)
    (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.cleans = cleans ∧ S.region = region ∧ S.Safe = Safe := by
  obtain ⟨r, c', hread, hred⟩ := decodeReduced_read hdec
  obtain ⟨targets, cT, hT⟩ := readTargets_of_check hcc
  obtain ⟨c0, c1, stub, padded, hc0, hrun, hpro, hent⟩ :=
    read_instructions_entry hread hT hnr rfl
  obtain ⟨hit, -, -, -⟩ := instructions_read hrun
  -- The entry's code, with the stub's relocation boundary from the instructions' end.
  have hentry : ∃ p1, CheckReadC c0 c.mode
      (fun s => ∀ m, LinkOkF ctx m c0 relocs c.mode → Boundary relocs s) p1 ∧
      Dec c0 p1 (prologue c.d.frameSize c.mode) c0.pos := by
    obtain ⟨p1, ⟨hk1, hk2⟩, hpr⟩ := hent
    have hF : c.d.frameSize = r.frameSize := by rw [hc]; exact reducedOf_frameSize hred
    refine ⟨p1, ⟨fun h0 => hk1 (hm ▸ h0), fun h0 => ?_⟩, by rw [hF, hm]; exact hpr⟩
    obtain ⟨t, l, tb, bl, q, d1, e1, hB, d2⟩ := hk2 (hm ▸ h0)
    refine ⟨t, l, tb, bl, q, d1, e1, fun m hL => ?_, d2⟩
    obtain ⟨-, -, hb0⟩ := hL.dec (Dec.append d1 hpr) (boundary_zero _)
    exact hB (Boundary relocs) (fun p L q hp hd => (hL.dec hd hp).2.2)
      (sl_iters_boundaryF hL (instructions_read hrun).1 hb0)
  obtain ⟨st, ca, drs, ar, h0, hc0', hd0, ha0, -, -, har, hix⟩ := iters_indexed hit
  have hsz : c0.code.size = code.data.size := by rw [hc0]; rfl
  refine ⟨Setup.mk ctx E c r c0 relocs rodata callSites targets st ca drs ar x0 Owned lo padOf
    cleans region Safe, ⟨⟨c', hread⟩,
    hc ▸ hred, hm, rfl, rfl, rfl, hc0, ?_, h0, hc0', fun _ => hd0, ha0, har, ?_, ?_, ?_, ?_,
    fun hfp => hpro (hm ▸ hfp), hcs, ⟨cT, hT⟩, hentry, ctr_read_heads hread hnr,
    sl_read_stubs hread hnr, fun _ => sl_read_stubs_R hread hnr, ?_, ?_,
    fun h => absurd hnr h, fun h => absurd hnr h⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  · exact fun _ => ⟨stub, padded, c1, by simpa [Setup.fr, hm, hsz] using hrun⟩
  · intro k hk _
    have hix' : Indexed (⟨r.frameSize, c.mode, false⟩ : Vm.Frame) rodata (some targets) callSites
        c0 r.protos.toList st ca drs ar := by simpa [hm] using hix
    exact hix' k hk
  · intro k _ _ h0
    exact Bool.noConfusion
      (h0.symm.trans (inRegion_false_of_noPad (c := c) hread (hc ▸ hred) hm hnr (k + 1)))
  · intro k _ h0
    exact Bool.noConfusion
      (h0.symm.trans (inRegion_false_of_noPad (c := c) hread (hc ▸ hred) hm hnr k))
  · intro rs hpe hst
    exfalso
    obtain ⟨i0, hact⟩ := cleanup_action (hc ▸ hred) (List.min?_mem hst)
    obtain ⟨p, hp⟩ := regionPad_some hread (by rw [← hm]; exact hpe) hact
    rw [hnr] at hp
    cases hp
  · exact regionFacts_of_read hread (hc ▸ hred) hm rfl hc0
  · -- no pad region (`hnr`): a region start would be a cleanup pad, so `regionPad` is `some`
    intro rs hpe hst m _
    exfalso
    obtain ⟨i0, hact⟩ := cleanup_action (hc ▸ hred) (List.min?_mem hst)
    obtain ⟨p, hp⟩ := regionPad_some hread (by rw [← hm]; exact hpe) hact
    rw [hnr] at hp
    cases hp

/-- P1c (open): `decodes_of_ok` with a PE pad region (`regionPad … = some p`): the body's
iterations from `readParts`' body pass (`S.fr`, `droppedBody`, up to `limit`), the region's from
`readRegion`'s (`S.frR`, `droppedRegion`; `resumeSlots` gives `S.fixResume`), `S.start`/`S.cache`/
`S.dr`/`S.args` glued at `rs` (`regionAt`), the entry, heads and stubs from the same read, and
`regionBoundary` from the body's end (`bodyEnd = limit` without counters, `checkStubs`' end
with them). -/
theorem decodes_of_ok_region {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded} {p : Nat}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (hp : regionPad mode callSites = some p)
    (hcs : callSitesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (cleans : BitVec 64 → Bool) (region : BitVec 64)
    (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.cleans = cleans ∧ S.region = region ∧ S.Safe = Safe := by
  subst hm
  obtain ⟨r, c', hread, hred⟩ := decodeReduced_read hdec
  obtain ⟨targets, cT, hT⟩ := readTargets_of_check hcc
  obtain ⟨c0, cB, cR, stub, pB, pR, qB, qR, hc0, hrunB, hstubs, hrunR, hsz, hpB, hpR, hleast,
    hnb0, hpsz, hpro, hent, hstubR, hheads, hstubs2⟩ :=
    read_region_passes hread hT hp rfl
  have hpe : c.mode.pe = true := by
    unfold regionPad at hp
    cases h : c.mode.pe with
    | true => rfl
    | false => rw [h] at hp; simp at hp
  have hstart : c.d.regionStart = some qB.size := by rw [hc, regionStart_eq hred, hleast]
  have hinR : ∀ k, c.inRegion k = decide (qB.size ≤ k) := by
    intro k
    unfold R.Code.inRegion
    rw [hpe, hstart]
    simp
  have hne : (Full.Opcode.lpad == Full.Opcode.arg) = false := by decide
  -- the region's first proto is the least cleanup pad, an `lpad`, at `p`
  have hlpad : r.protos[qB.size]!.op = .lpad := by
    obtain ⟨i0, hact⟩ := cleanup_action hred
      (List.min?_mem (show d.regionStart = some qB.size by rw [← hc]; exact hstart))
    have hi0 : i0 < r.actions.size := by
      by_cases h : i0 < r.actions.size
      · exact h
      · rw [getElem!_neg r.actions i0 h] at hact; simp at hact
    rw [getElem!_pos r.actions i0 hi0] at hact
    exact read_tail_facts hread _ (Array.getElem_mem hi0) _ _ hact
  obtain ⟨L, hLsz, hL, hposL, -, -, -, -, -, -⟩ := read_region_start hread hp
  have hLn : L = qB.size := Option.some.inj (hL.symm.trans hleast)
  subst hLn
  have hqR : 0 < qR.size := by omega
  have hop0 : qR[0].op = .lpad := by
    have e := hpR 0 hqR
    rw [Nat.add_zero] at e
    rw [e, resumeFix_op] at hlpad
    exact hlpad
  have hcode : c0.code = ({ code := code.data, pos := 0, fields := .relocs relocs } : Cursor).code := by
    rw [hc0]; rfl
  -- the two passes' iterations
  obtain ⟨hitB, -, -, -⟩ := instructions_read hrunB
  obtain ⟨hitR, -, -, -⟩ := instructions_read hrunR
  obtain ⟨stB, caB, drB, arB, h0B, hc0B, hd0B, ha0B, -, -, harB, hixB⟩ := iters_indexed hitB
  obtain ⟨stR, caR, drR, arR, h0R, hc0R, -, ha0R, -, -, harR, hixR⟩ := iters_indexed hitR
  -- the region's run has its flag off after its first proto (an `lpad`)
  have harR1 : ∀ j, 1 ≤ j → j ≤ qR.size → arR j = false := by
    intro j hj1 hjs
    induction j with
    | zero => omega
    | succ j ih =>
      rw [harR j (by simp; omega)]
      cases j with
      | zero => simp [Array.getElem_toList, hop0, hne]
      | succ j => rw [ih (by omega) (by omega)]; rfl
  -- the prologue from 0, the body's end at a boundary
  have hpro0 : ∃ items, Dec c0 0 items c0.pos := by
    obtain ⟨p1, ⟨hk1, hk2⟩, hpr⟩ := id hent
    cases hcn : c.mode.counters with
    | false =>
      have e := hk1 hcn
      subst e
      exact ⟨_, hpr⟩
    | true =>
      obtain ⟨t, l, tb, bl, q, d1, -⟩ := hk2 hcn
      exact ⟨_, d1.append hpr⟩
  have hbody : ∀ m, LinkOkF ctx m c0 relocs c.mode → Boundary relocs cB.pos := by
    intro m hL
    obtain ⟨items, hd0⟩ := hpro0
    obtain ⟨-, -, hb0⟩ := hL.dec hd0 (boundary_zero _)
    exact sl_iters_boundaryF hL hitB hb0
  have hentry : ∃ p1, CheckReadC c0 c.mode
      (fun s => ∀ m, LinkOkF ctx m c0 relocs c.mode → Boundary relocs s) p1 ∧
      Dec c0 p1 (prologue c.d.frameSize c.mode) c0.pos := by
    obtain ⟨p1, ⟨hk1, hk2⟩, hpr⟩ := id hent
    have hF : c.d.frameSize = r.frameSize := by rw [hc]; exact reducedOf_frameSize hred
    refine ⟨p1, ⟨hk1, fun h0 => ?_⟩, by rw [hF]; exact hpr⟩
    obtain ⟨t, l, tb, bl, q, d1, e1, hB, d2⟩ := hk2 h0
    refine ⟨t, l, tb, bl, q, d1, e1, fun m hL => ?_, d2⟩
    exact hB (Boundary relocs) (fun p L q hp hd => (hL.dec hd hp).2.2) (hbody m hL)
  have hnone : regionPad c.mode callSites ≠ none := by rw [hp]; simp
  refine ⟨Setup.mk ctx E c r c0 relocs rodata callSites targets
    (fun k => if k < qB.size then stB k else stR (k - qB.size))
    (fun k => if k < qB.size then caB k else caR (k - qB.size))
    (fun k => if k < qB.size then drB k else drR (k - qB.size))
    (fun k => if k ≤ qB.size then arB k else false) x0 Owned lo padOf cleans region Safe,
    ⟨⟨c', hread⟩, hc ▸ hred, rfl, rfl, rfl, rfl, hc0, fun h => absurd h hnone, ?_, ?_,
    fun h => absurd h hnone, ?_, ?_, ?_, ?_, ?_, ?_, fun hfp => hpro hfp, hcs, ⟨cT, hT⟩, hentry,
    hheads, hstubs2, fun h => absurd h hnone,
    regionFacts_of_read hread (hc ▸ hred) rfl rfl hc0, ?_, ?_, ?_⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  -- start0, cache0, args0
  · show (if 0 < qB.size then stB 0 else stR (0 - qB.size)) = c0.pos
    rw [if_pos hnb0, h0B]
  · show (if 0 < qB.size then caB 0 else caR (0 - qB.size)) = { pe := c.mode.pe }
    rw [if_pos hnb0, hc0B]
  · show (if 0 ≤ qB.size then arB 0 else false) = true
    rw [if_pos (Nat.zero_le _), ha0B]
  -- argsSucc
  · intro k hk
    have hks : k < r.protos.size := by simpa using hk
    have hk' : k < r.protos.toList.length := hk
    show (if k + 1 ≤ qB.size then arB (k + 1) else false) =
      ((if k ≤ qB.size then arB k else false) && r.protos.toList[k].op == .arg)
    by_cases h1 : k + 1 ≤ qB.size
    · have hkq : k < qB.toList.length := by simp; omega
      rw [if_pos h1, if_pos (show k ≤ qB.size by omega), harB k hkq]
      have e : qB.toList[k] = r.protos.toList[k] := by
        simp only [Array.getElem_toList]
        rw [← hpB k (by omega), getElem!_pos r.protos k hks]
      rw [e]
    · rw [if_neg h1]
      by_cases h2 : k ≤ qB.size
      · have hke : k = qB.size := by omega
        rw [if_pos h2]
        have e : r.protos.toList[k].op = .lpad := by
          simp only [Array.getElem_toList]
          rw [← getElem!_pos r.protos k hks]
          subst hke
          exact hlpad
        rw [e, hne, Bool.and_false]
      · rw [if_neg h2]
        rfl
  -- itersB
  · intro k hk hr1
    have h1 : c.inRegion (k + 1) = false := hr1
    rw [hinR] at h1
    have hlt : k + 1 < qB.size := by simpa using h1
    have hks : k < r.protos.size := by simpa using hk
    have hkB : k < qB.toList.length := by simp; omega
    have hk' : k < r.protos.toList.length := hk
    refine iter_congr (hixB k hkB) (ite_pos_eq (show k ≤ qB.size by omega))
      (ite_pos_eq (show k < qB.size by omega)) (ite_pos_eq (show k < qB.size by omega))
      (ite_pos_eq (show k < qB.size by omega)) ?_ (ite_pos_eq hlt) (ite_pos_eq hlt)
      (ite_pos_eq hlt)
    show qB.toList[k] = r.protos.toList[k]
    simp only [Array.getElem_toList]
    rw [← hpB k (by omega), getElem!_pos r.protos k hks]
  -- itersLast
  · intro k hk hr0 _
    have h0' : c.inRegion k = false := hr0
    rw [hinR] at h0'
    have hk1 : k < qB.size := by simpa using h0'
    have hks : k < r.protos.size := by simpa using hk
    have hkB : k < qB.toList.length := by simpa using hk1
    have hk' : k < r.protos.toList.length := hk
    refine ⟨_, _, _, iter_congr (hixB k hkB) (ite_pos_eq (show k ≤ qB.size by omega))
      (ite_pos_eq hk1) (ite_pos_eq hk1) (ite_pos_eq hk1) ?_ rfl rfl rfl⟩
    show qB.toList[k] = r.protos.toList[k]
    simp only [Array.getElem_toList]
    rw [← hpB k hk1, getElem!_pos r.protos k hks]
  -- itersR
  · intro k hk hr
    have h' : c.inRegion k = true := hr
    rw [hinR] at h'
    have hge : qB.size ≤ k := by simpa using h'
    have hks : k < r.protos.size := by simpa using hk
    have hj : k - qB.size < qR.toList.length := by simp; omega
    have ha : arR (k - qB.size) = false ∨ qR.toList[k - qB.size].op ≠ .arg := by
      by_cases hke : k = qB.size
      · right
        have e0 : qR.toList[k - qB.size] = qR[0] := by simp [hke]
        rw [e0, hop0]
        decide
      · left
        exact harR1 _ (by omega) (by simp at hj; omega)
    have hI := iter_args (iter_atPos (hixR (k - qB.size) hj)) ha
      (if k ≤ qB.size then arB k else false)
    refine ⟨qR.toList[k - qB.size], ?_, iter_congr hI rfl
      (ite_neg_eq (show ¬ k < qB.size by omega)) (ite_neg_eq (show ¬ k < qB.size by omega))
      (ite_neg_eq (show ¬ k < qB.size by omega)) rfl
      ((congrArg stR (show k - qB.size + 1 = k + 1 - qB.size by omega)).trans
        (ite_neg_eq (show ¬ k + 1 < qB.size by omega)))
      ((congrArg caR (show k - qB.size + 1 = k + 1 - qB.size by omega)).trans
        (ite_neg_eq (show ¬ k + 1 < qB.size by omega)))
      ((congrArg drR (show k - qB.size + 1 = k + 1 - qB.size by omega)).trans
        (ite_neg_eq (show ¬ k + 1 < qB.size by omega)))⟩
    have e := hpR (k - qB.size) (by simp at hj; omega)
    rw [show qB.size + (k - qB.size) = k by omega, getElem!_pos r.protos k hks] at e
    exact e
  -- regionAt
  · intro rs _ hst
    have hrs : rs = qB.size := Option.some.inj (hst.symm.trans hstart)
    subst hrs
    refine ⟨?_, ?_⟩
    · show (if qB.size < qB.size then stB qB.size else stR (qB.size - qB.size)) = posOf r qB.size
      rw [if_neg (Nat.lt_irrefl _), Nat.sub_self, h0R, hposL]
    · show (if qB.size < qB.size then caB qB.size else caR (qB.size - qB.size)) =
        { pe := c.mode.pe }
      rw [if_neg (Nat.lt_irrefl _), Nat.sub_self, hc0R]
  -- regionBoundary
  · intro rs _ hst m hL
    have hrs : rs = qB.size := Option.some.inj (hst.symm.trans hstart)
    subst hrs
    obtain ⟨its, hds⟩ := hstubs
    obtain ⟨-, -, hbL⟩ := hL.dec hds (hbody m hL)
    show Boundary relocs (posOf r qB.size - regionEntryLen)
    rw [hposL]
    exact hbL
  -- posLeR
  · intro _ k hk0
    have hk : k < r.protos.size := hk0
    have hsz0 : c0.code.size = code.data.size := by rw [hcode]
    show posOf r k ≤ c0.code.size
    rw [posOf_eq hk, ← getElem!_pos r.protos k hk]
    by_cases hkb : k < qB.size
    · rw [hpB k hkb]
      have h2 : p ≤ code.data.size := hpsz
      exact instructions_pos_le hrunB (by rw [hsz0]; omega) _
        (Array.getElem_mem_toList hkb)
    · have hj : k - qB.size < qR.size := by omega
      have e := hpR (k - qB.size) hj
      rw [show qB.size + (k - qB.size) = k by omega] at e
      rw [e, resumeFix_pos]
      exact instructions_pos_le hrunR (by show _ ≤ c0.code.size; rw [hsz0]; exact Nat.le_refl _) _
        (Array.getElem_mem_toList hj)
  -- stubsBoundaryR
  · intro _ m hL k hk stub back hcnt
    exact hstubR (Boundary relocs) (fun p L q hp hd => (hL.dec hd hp).2.2) (hbody m hL) k hk
      stub back hcnt

/-- Every function `decodeReduced` accepts has a `Setup` that is its read, for any R code with
its `Decoded` and mode and any choice of the other parameters. -/
theorem decodes_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (hcs : callSitesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (cleans : BitVec 64 → Bool) (region : BitVec 64)
    (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.cleans = cleans ∧ S.region = region ∧ S.Safe = Safe := by
  cases hp : regionPad mode callSites with
  | none =>
    exact decodes_of_ok_noRegion hdec hp hcs hcc c hc hm ctx E x0 Owned lo padOf cleans region
      Safe
  | some p =>
    exact decodes_of_ok_region hdec hp hcs hcc c hc hm ctx E x0 Owned lo padOf cleans region Safe

/-- A1: the region's iterations, read with `S.frR` (`readParts_region`):
an empty iteration (a dropped store with no code, B7: its simulation, as
`DeadStoreSim.empty`), or a main one whose proto is `read`'s after `resumeSlots`
(`S.fixResume`). -/
theorem region_iter {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k : Nat} (hk : k < S.r.protos.size) (hr : S.c.inRegion k = true) :
    RInsnSimAt S k ∨
      ∃ (p1 p2 : Nat) (counter : Option (Nat × Nat)) (q : Proto) (c' : Cursor) (cache' : Cache)
        (dr' : List DroppedStore),
        S.r.protos[k] = S.fixResume { q with pos := p1, counter } ∧
        PadRead S.body (S.start k) p1 ∧ CounterRead S.frR S.body p1 counter p2 ∧
        ProtoRead S.frR S.ro (some S.targets).isSome S.body p2
          (if (some S.targets).any (sortedContains · p1) then { pe := S.frR.mode.pe }
            else S.cache k) (S.dr k) (S.args k) q c' cache' dr' ∧
        NopRead S.frR S.callSites S.body q c'.pos (S.start (k + 1)) ∧
        S.cache (k + 1) = cache' := by
  obtain ⟨q0, hq0, hit⟩ := hD.itersR k (by simpa using hk) hr
  generalize hdr : S.dr k = drk at hit
  generalize hst1 : S.start (k + 1) = st1 at hit
  generalize hca1 : S.cache (k + 1) = ca1 at hit
  generalize hdr1 : S.dr (k + 1) = dr1 at hit
  cases hit with
  | empty hd _ => exact .inl (H.deadStore.emptyR k hk hr _ _ hdr hd)
  | @main p1 p2 _ _ _ _ _ counter q c' hpad hctr hpr hnop =>
    refine .inr ⟨p1, p2, counter, q, c', ca1, dr1, ?_, hpad, hctr, hpr, hnop, rfl⟩
    simpa using hq0

/-- PE-T3/T4 (dispatch PE-T5): an instruction of PE's pad region, from `RegionInv`: calls and
islands with the outgoing area on the dispatcher's stack (T3), handlers, inline code, branches,
`lpad` and `resume` (`add rsp, 40; ret` to `ExitRel`'s `unwind`) (T4). -/
theorem rinsnSim_region {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    (htable : HdlTables S) {k : Nat} (hk : k < S.r.protos.size)
    (hr : S.c.inRegion k = true) : RInsnSimAt S k := by
  rcases region_iter hD H hk hr with h | ⟨p1, p2, counter, q, c', cache', dr', hq, hpad, hctr,
    hpr, hnop, hcache⟩
  · exact h
  · exact regionSim_main hD H hk hr hq hpad hctr hpr hnop hcache htable

/-- PE-T2: a body instruction at a PE cleanup site (a call, island or handler whose unwind comes
back through the pad region, `Call.PadCalled`, to `RegionInv` at the pad); otherwise as
`insnSim_main`. -/
theorem rinsnSim_peClean {S : Setup} {code : ByteArray} {relocs : Array Reloc}
    {rodata : ByteArray} {callSites : Array CallSite} {dropped : Array DroppedStore}
    {scopes : Array R.Scope} {mode : Ryo.Obj.Mode}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    (htable : HdlTables S) {k : Nat} (hk : k < S.r.protos.size)
    (hb : S.c.inRegion k = false) (hc : ¬ NoPeClean S k) : RInsnSimAt S k := by
  obtain ⟨hpe, pad, hcl⟩ : S.c.mode.pe = true ∧ ∃ pad, S.c.cleanupAt k = some (some pad, false) := by
    by_cases hpe : S.c.mode.pe = true
    · exact ⟨hpe, Classical.byContradiction fun hn => hc fun _ pad h => hn ⟨pad, h⟩⟩
    · exact (hc fun h => absurd h hpe).elim
  have hfp : S.c.mode.framePointer = true := vt_fp_of_pe hD.modeValid hpe
  -- A3: the instruction has call sites, so it is a call, an island or a handler `resume`.
  have hsites := cleanup_sites hD hk hcl hb
  -- The iteration; it ends at `k + 1`'s start unless `k` is the body's last instruction.
  obtain ⟨st1, ca1, dr1, hit, hend⟩ : ∃ st1 ca1 dr1, Iter S.fr S.ro (some S.targets) S.callSites
      S.body (S.args k) (S.start k) (S.cache k) (S.dr k) S.r.protos.toList[k] st1 ca1 dr1 ∧
      (S.c.inRegion (k + 1) = false → st1 = S.start (k + 1) ∧ ca1 = S.cache (k + 1)) := by
    cases hk1 : S.c.inRegion (k + 1) with
    | false => exact ⟨_, _, _, hD.itersB k (by simpa using hk) hk1, fun _ => ⟨rfl, rfl⟩⟩
    | true =>
      obtain ⟨p', ca', dr', h⟩ := hD.itersLast k (by simpa using hk) hb hk1
      exact ⟨p', ca', dr', h, fun h' => by simp [hk1] at h'⟩
  simp only [Array.getElem_toList] at hit
  generalize hpk : S.r.protos[k] = pk at hit
  generalize hdr : S.dr k = drk at hit
  rw [hpk] at hsites
  cases hit with
  | empty _ hr =>
    have h0 := inline_read_sites hr
    exact (hsites h0).elim
  | @main p1 p2 _ _ _ _ _ counter q c' hpad hctr hpr hnop =>
  rw [← hdr] at hpr
  have hqs : q.sites ≠ [] := hsites
  intro s x hs hrbi hsafe
  have hbs : S.c.inRegion s.pc = false := by rw [hs]; exact hb
  have hbi := (rbInv_body hbs).1 hrbi
  have hp1 : posOf S.r k = p1 := by rw [posOf_eq hk, hpk]
  have e : (if (some S.targets).any (sortedContains · p1) then ({ pe := S.fr.mode.pe } : Cache)
      else S.cache k) = S.used k := by simp [Setup.used, Setup.fr, hp1, Option.any]
  rw [e] at hpr
  have hargs : S.args (k + 1) = (S.args k && q.op == .arg) := by
    have := hD.argsSucc k (by simpa using hk)
    simpa [hpk] using this
  have hinsn : ∃ i, S.c.d.insns[k]? = some i ∧ ∀ hk : k < S.r.protos.size,
      InsnOf (posOf S.r) S.r.protos[k] i := by
    have h1 := (reducedOf_insns hD.reduced)
    have hk' : k < S.c.d.insns.size := h1.1 ▸ hk
    exact ⟨S.c.d.insns[k], by simp [hk'], fun hk => h1.2 k hk hk'⟩
  refine insnSim_prefix hD H hk hpk hpad hctr hb (Q := RSNext S) ?_ s x hs hbi hsafe
  intro hb2
  have hPN : ProtoFactsN S k p2 q c' _ :=
    ⟨hk, ⟨p1, counter, by simp [hk, hpk]⟩, hinsn, hb2, fun h => (hend h).1 ▸ hnop,
      fun h => (hend h).2.symm, hargs, hb⟩
  generalize ha : S.args k = a at hpr
  cases hpr with
  | arg h =>
    obtain ⟨_, _, rfl, -⟩ := argInsn_read h
    exact (hqs rfl).elim
  | call hn h => exact rbody_of_RB hfp (bodySim_call_fpRB hfp hD H hPN hn h)
  | inline hn hc h => exact (hqs (inline_read_sites h)).elim
  | insn hn hc hi h =>
    have e1 := callInsn_none hc
    have e2 := inlineInsn_none hi
    subst e1 e2
    rcases insn_split h with hd | ⟨hnd, hcore⟩
    · obtain ⟨_, _, _, _, _, _, _, _, _, _, -, rfl, -⟩ := dense_read hd
      exact (hqs rfl).elim
    have hir := insnCore_read hcore
    have hir' := hir
    cases hir' with
    | @handler _ _ _ _ _ op _ _ _ _ _ _ _ _ _ hth =>
      by_cases hres : op = .resume
      · intro s' y hs' _ hfy hry _ hsafe'
        exact (handler_resume_pe hD H hpe hPN hn hir hres s' y hs' ((frameInvR_iff hfp).1 hfy)
          hry hsafe').mono fun _ h => h.elim
      · exact (hqs (thenSeq_sites hth hres)).elim
    | ret => exact (hqs rfl).elim
    | unreachable => exact (hqs rfl).elim
    | jmp => exact (hqs rfl).elim
    | island => exact rbody_of_RB hfp (bodySim_islandRB hfp hD H hPN hn hir rfl)
    | resume => exact (hqs rfl).elim
    | dense h => exact (hnd _ h).elim

/-- **`decode_sound`** (aot.md §C2): for a function the decoder accepts (`Decodes`, given by
`decodes_of_ok` from `decodeReduced … = .ok d`) under `Hyps`, the fetching machine with its
environment simulates the R program from every boundary whose R runs are safe. -/
theorem decode_sound {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (htc : tablesCheck code relocs rodata callSites dropped scopes mode = true) :
    ∀ s x, RBInv S s x → SafeFrom S.Safe S.c s →
      FnSim S.ctx S.E S.c (RBInv S) (ExitRel S) s x := by
  have htable : HdlTables S := DecodeLink.Tables.hdlTables_of_check hD htc
  refine fnSim_of_insnSim _ _ _ _ _ _ fun s x hrbi hsafe => ?_
  by_cases hk : s.pc < S.r.protos.size
  · cases hreg : S.c.inRegion s.pc with
    | true => exact rinsnSim_region hD H htable hk hreg s x rfl hrbi hsafe
    | false =>
    by_cases hnc : NoPeClean S s.pc
    case neg => exact rinsnSim_peClean hD H htable hk hreg hnc s x rfl hrbi hsafe
    have hbi := (rbInv_body hreg).1 hrbi
    have hncl : NotCleanup S s.pc :=
      notCleanup_of (H.cleansLinked hD hbi.1.1.code.small) hnc
    refine rinsnSim_of_insnSim hD hreg hnc ?_ s x rfl hrbi hsafe
    obtain ⟨st1, ca1, dr1, hit, hend⟩ : ∃ st1 ca1 dr1, Iter S.fr S.ro (some S.targets)
        S.callSites S.body (S.args s.pc) (S.start s.pc) (S.cache s.pc) (S.dr s.pc)
        S.r.protos.toList[s.pc] st1 ca1 dr1 ∧
        (S.c.inRegion (s.pc + 1) = false → st1 = S.start (s.pc + 1) ∧
          ca1 = S.cache (s.pc + 1)) := by
      cases hk1 : S.c.inRegion (s.pc + 1) with
      | false => exact ⟨_, _, _, hD.itersB s.pc (by simpa using hk) hk1, fun _ => ⟨rfl, rfl⟩⟩
      | true =>
        obtain ⟨p', ca', dr', h⟩ := hD.itersLast s.pc (by simpa using hk) hreg hk1
        exact ⟨p', ca', dr', h, fun h' => by simp [hk1] at h'⟩
    simp only [Array.getElem_toList] at hit
    generalize hpk : S.r.protos[s.pc] = pk at hit
    generalize hdr : S.dr s.pc = drk at hit
    cases hit with
    | empty hd _ =>
      exact H.deadStore.empty s.pc hk _ _ hdr hd
    | main hpad hctr hpr hnop =>
      rw [← hdr] at hpr
      exact insnSim_main hD H hk hpk hpad hctr hpr (fun h => (hend h).1 ▸ hnop)
        (fun h => (hend h).2.symm) htable hreg hncl
  · exact rinsnSim_oob hD (Nat.le_of_not_lt hk) s x rfl hrbi hsafe

/-- `decode_sound` from the decoder's acceptance directly (without a PE pad region, as
`decodes_of_ok`; and with the switch tables checked, `htc`). -/
theorem decode_sound_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (htc : tablesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcs : callSitesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (cleans : BitVec 64 → Bool) (region : BitVec 64)
    (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.cleans = cleans ∧ S.region = region ∧ S.Safe = Safe ∧
      (Hyps S → ∀ s x, RBInv S s x → SafeFrom Safe c s → FnSim ctx E c (RBInv S) (ExitRel S) s x) := by
  obtain ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h7c, h7r, h8⟩ :=
    decodes_of_ok hdec hcs hcc c hc hm ctx E x0 Owned lo padOf cleans region Safe
  refine ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h7c, h7r, h8, fun H => ?_⟩
  subst h1 h2 h3 h8
  exact decode_sound hD H htc

/-- What `Frame.decodeChecked` accepting a function gives: `decodeReduced`'s acceptance, the
bound check (`Decoded.boundsOk`), `tablesCheck`, `frameSizesCheck`, `privCheck`, `callSitesCheck`,
`relocsInCheck` (`Hyps.relocsInOk` by `relocsInOk_of_decodes`), `cacheClearedCheck`
(`Hyps.cacheOk` by `cacheOk_of_decodes`), `argsLeadCheck` (`Hyps.argsChecked` by
`argsChecked_of_decodes`) and `spDispCheck` (`Hyps.spDispOk` by `spDispOk_of_decodes`). -/
theorem decodeChecked_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {d : Decoded}
    (h : Frame.decodeChecked code (.relocs relocs) rodata callSites dropped scopes mode facts =
      .ok d) :
    decodeReduced code relocs rodata callSites dropped scopes mode = .ok d ∧
      d.boundsOk mode = true ∧ tablesCheck code relocs rodata callSites dropped scopes mode = true ∧
      frameSizesCheck d mode = true ∧ privCheck d = true ∧
      callSitesCheck code relocs rodata callSites dropped scopes mode = true ∧
      relocsInCheck code.data relocs = true ∧
      cacheClearedCheck code relocs rodata callSites dropped scopes mode = true ∧
      argsLeadCheck code relocs rodata callSites dropped scopes mode = true ∧
      spDispCheck code.data d mode = true := by
  unfold Frame.decodeChecked Frame.decodeChecked.checkDropped at h
  cases hb : decodeBounded code (.relocs relocs) rodata callSites dropped scopes mode with
  | error e => simp [hb, bind, Except.bind, throw, throwThe, MonadExceptOf.throw] at h
  | ok d0 =>
    obtain ⟨hd, hbo⟩ := DecodeLink.Bounds.decodeBounded_ok hb
    cases hfs : frameSizesCheck d0 mode with
    | false => simp [hb, hfs, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hpc : privCheck d0 with
    | false => simp [hb, hfs, hpc, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hsd : spDispCheck code.data d0 mode with
    | false => simp [hb, hfs, hpc, hsd, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases ht : tablesCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hcs : callSitesCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hri : relocsInCheck code.data relocs with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, hri, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, bind, Except.bind, pure, Except.pure, throw,
        throwThe, MonadExceptOf.throw] at h
    | true =>
    cases hal : argsLeadCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, bind, Except.bind, pure, Except.pure, throw,
        throwThe, MonadExceptOf.throw] at h
    | true =>
      cases hdn : Frame.droppedNotDead d0 mode facts with
      | error e => simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure, Except.pure] at h
      | ok l =>
        cases l with
        | nil =>
          simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure, Except.pure] at h
          subst h
          exact ⟨hd, hbo, rfl, hfs, hpc, rfl, rfl, rfl, rfl, hsd⟩
        | cons k rest =>
          simp [hb, hfs, hpc, hsd, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure, Except.pure, throw,
            throwThe, MonadExceptOf.throw] at h

/-- `decode_sound_of_ok` from the checked decoder's acceptance (`Frame.decodeChecked`: the
bound check, `tablesCheck`, `frameSizesCheck`, `privCheck`, `callSitesCheck`, `relocsInCheck`,
`cacheClearedCheck` and `argsLeadCheck` included). -/
theorem decode_sound_of_checked {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {d : Decoded}
    (hdec : Frame.decodeChecked code (.relocs relocs) rodata callSites dropped scopes mode facts =
      .ok d)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (cleans : BitVec 64 → Bool) (region : BitVec 64)
    (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.cleans = cleans ∧ S.region = region ∧ S.Safe = Safe ∧
      (Hyps S → ∀ s x, RBInv S s x → SafeFrom Safe c s → FnSim ctx E c (RBInv S) (ExitRel S) s x) :=
  have h := decodeChecked_ok hdec
  decode_sound_of_ok h.1 h.2.2.1 h.2.2.2.2.2.1 h.2.2.2.2.2.2.2.1 c hc hm ctx E x0 Owned lo padOf
    cleans region Safe

end Ryo.Proofs.DecodeSound
