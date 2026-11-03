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
`inlineOps_shape`, `RyoProofs/InlineOps.lean`, and `inlineOps_clsOk`). Restrictions: the frame-pointer mode (`fp`), the items without a
frame pointer have no step lemmas yet (handler calls may have PE's stack argument,
`HandlerStackArg`; `resume`'s fit in registers, `resume_regs_le`); no PE pad region (`Decodes.noRegion`: PE's cleanup code after the body, which the
exception dispatcher enters on its own stack). Open prerequisites, each a named hypothesis to be
discharged later:

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

/-! #### The dense switch -/

/-- `denseItems.go`'s items, decoded one after the other up to the table's `lea`. -/
theorem denseItems_go_dec (c : Cursor) : ∀ (k p : Nat) (acc its : List Item) (at_ : Nat),
    denseItems.go c p acc k = some (its, at_) → ∃ l, its = acc.reverse ++ l ∧ Dec c p l at_
  | 0, p, acc, its, at_, h => by simp [denseItems.go] at h
  | k + 1, p, acc, its, at_, h => by
    unfold denseItems.go at h
    cases hdi : decodeItem { c with pos := p } with
    | none => rw [hdi] at h; cases h
    | some r =>
      obtain ⟨it, n⟩ := r
      have hit : decodeItem (atPos c p) = some (it, n) := hdi
      rw [hdi] at h
      cases it
      all_goals simp only [Bool.true_and, Bool.false_and, Bool.false_eq_true, ↓reduceIte,
        reduceCtorEq] at h
      all_goals (try split at h) <;> first
        | (cases h; done)
        | (cases h; exact ⟨[], by simp, .nil _⟩)
        | (obtain ⟨l, hl, hd⟩ := denseItems_go_dec c k _ _ its at_ h
           exact ⟨_ :: l, by simp [hl], .cons hit hd⟩)

theorem denseScan_some {c : Cursor} {w : W} {sl : BitVec 32} {base n : BitVec 64} {at_ : Nat}
    (h : denseScan c = some (w, sl, base, n, at_)) :
    ∃ its, Dec c c.pos its at_ ∧ Asm.denseIndex (denseOp w) sl base n = some its := by
  unfold denseScan at h
  cases hd : denseItems c with
  | none => simp [hd] at h
  | some r =>
    obtain ⟨its, at'⟩ := r
    obtain ⟨l, hl, hdec⟩ := denseItems_go_dec c 7 c.pos [] its at' hd
    simp only [List.reverse_nil, List.nil_append] at hl
    have hdec' : Dec c c.pos its at' := by rw [hl]; exact hdec
    clear hdec hl
    refine ⟨its, ?_⟩
    simp only [hd, bind, Option.bind] at h
    -- Every branch but the last check's success ends in `none`; which matches `split` takes
    -- first (`base`'s included) doesn't matter.
    repeat' split at h
    all_goals (try simp only [bind, Option.bind, reduceCtorEq] at h)
    all_goals (try (cases h; done))
    all_goals (try (simp at h; done))
    all_goals
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := h
      refine ⟨hdec', ?_⟩
      simp_all [Bool.or_eq_true, bne_iff_ne]

/-- What `denseSwitch` read at `c`: `Asm.denseIndex`'s items (the index computation) then the
jump table (`table`, `table_read`), as the `switch.dense` handler call with the arguments
`denseArgs` gives. -/
theorem dense_read {fr : Vm.Frame} {c c' : Cursor} {q : Proto}
    (h : (denseSwitch fr).run c = .ok (some q, c')) :
    ∃ (w : W) (sl : BitVec 32) (base n : BitVec 64) (its : List Item) (at_ : Nat)
      (tb : BitVec 32) (pE : Nat) (args : List R.Arg) (es : List (BitVec 32)),
      Asm.denseIndex (denseOp w) sl base n = some its ∧
      q = { op := denseOp w, handler := some (args, .table (es.map (·.toNat))), pos := c.pos } ∧
      denseArgs fr (denseOp w) sl base n = some args ∧
      Dec c c.pos its at_ ∧ Dec c at_ (Switch.switchItems tb) pE ∧
      (∀ i (hi : i < es.length), (atPos c (tb.toNat + 4 * i)).tableEntry tb = some es[i]) := by
  unfold denseSwitch at h
  obtain ⟨x, c1, h1, h2⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := get_run h1
  split at h2
  · rename_i w sl base n at_ hscan
    obtain ⟨its, hd1, hden⟩ := denseScan_some hscan
    obtain ⟨u, c2, h3, h⟩ := bind_ok h2
    rw [run_setPos] at h3
    cases h3
    obtain ⟨ts, c3, h4, h⟩ := bind_ok h
    obtain ⟨tb, pE, es, hdT, rfl, hes, -⟩ := table_read h4
    split at h
    · rename_i args hargs
      obtain ⟨e, -⟩ := pure_ok h
      cases e
      exact ⟨w, sl, base, n, its, at_, tb, pE, args, es, hden, rfl, hargs, hd1,
        Dec.at_iff.1 hdT, hes⟩
    · exact (err_ok h).elim
  · obtain ⟨e, -⟩ := pure_ok h2; cases e

/-! The `switch.dense` handlers' tables and `opSem`. -/

set_option maxRecDepth 100000 in
theorem dense_handler (w : W) :
    (denseOp w).handler? = some ⟨.switch_dense, [tyName false w], some "usize"⟩ := by
  cases w <;> rfl

set_option maxRecDepth 100000 in
theorem dense_operands (w : W) :
    (denseOp w).info.operands = [⟨"s", .slot⟩, ⟨"base", immKind w⟩, ⟨"default", .target⟩,
      ⟨"table", .list .target⟩] := by
  cases w <;> rfl

theorem fp_dense {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .switch_dense (ty :: ps) = some { reads := [rdA "s" n], flow := .table } := by
  simp only [footprintOf, List.head?, Option.bind_some, h]
  try rfl

/-- `switch_dense` at `n` bytes: the slot's value minus `base`, clamped to the table length;
no writes. -/
theorem opSem_dense {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {k : OperandKind} {s : Int} {b len : Nat} {st st' : OpSem.State} {ch : OpSem.Choice}
    {c : Control}
    (hh : op.handler? = some ⟨.switch_dense, [ty], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"s", .slot⟩, ⟨"base", k⟩, ⟨"default", .target⟩,
      ⟨"table", .list .target⟩])
    (hsem : opSem op [.slot s, .imm b, .none, .targets len] st ch = .ok (c, st')) :
    ∃ bs v, st.readFrame s n = .ok bs ∧ asNat bs = .ok v ∧
      c = .index (if (BitVec.ofNat (8 * n) v - BitVec.ofNat (8 * n) b).toNat < len
        then (BitVec.ofNat (8 * n) v - BitVec.ofNat (8 * n) b).toNat else len) ∧ st' = st := by
  oinv hsem, hh, fp_dense (ps := []) (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨bs, hr, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨v, hv, rfl⟩ := hk
  exact ⟨bs, v, hr, hv, rfl, commit_nil hc⟩

theorem dense_nb (w : W) (vals : Operands) (st : OpSem.State) :
    NoNB (opSem (denseOp w) vals st {}) := by
  have hh := dense_handler w
  unfold opSem
  refine noNB_bind ?_ fun ⟨h, fp, val⟩ hp => ?_
  · unfold prepare
    intro m hm
    simp only [hh, bind, Except.bind] at hm
    repeat' split at hm
    all_goals first | (cases hm; done) | (cases hm; simp [inline_ill_eq, inline_throw_eq] at *) |
      simp_all [inline_ill_eq, inline_throw_eq]
  have hh' := prepare_handler hp
  rw [hh] at hh'
  cases hh'
  refine noNB_bind ?_ fun reads _ => ?_
  · unfold readAll
    refine noNB_mapM _ (fun a => ?_) _
    split
    · exact noNB_bind (noNB_readFrame _ _ _) fun _ _ => noNB_pure _
    · exact noNB_ill _
  have hrd : ∀ n, NoNB ((mkEnv reads val st {}).rd n) := fun n => by
    unfold mkEnv; dsimp only; split
    · exact noNB_pure _
    · exact noNB_ill _
  refine noNB_bind ?_ fun o _ => ?_
  · unfold kindSem; dsimp only; inline_nb
  refine noNB_bind ?_ fun _ _ => noNB_pure _
  unfold commit
  refine noNB_foldlM _ (fun st w => ?_) _ _
  unfold commitOne
  split
  · exact noNB_ill _
  · split
    · exact noNB_ill _
    · split
      · exact noNB_writeFrame _ _ _
      · exact noNB_ill _

/-- `denseArgs`'s registers: `fp` first with `fpArg` off PE (PE's layout is the `rbp` one, `s`
overwriting `fp`), then `s`, `base` and the case count. -/
def denseRegs (fa pe : Bool) (sl : BitVec 32) (base n : BitVec 64) : List R.Arg :=
  (if fa && !pe then [.fp] else []) ++ [.imm (sl.setWidth 64), .imm base, .imm n]

set_option maxRecDepth 100000 in
theorem dense_args_eq (fsz : Nat) (md : Ryo.Obj.Mode) (rg : Bool) (w : W) (sl : BitVec 32)
    (base n : BitVec 64) :
    denseArgs ⟨fsz, md, rg⟩ (denseOp w) sl base n = some (denseRegs md.fpArg md.pe sl base n) := by
  obtain ⟨fa, fp, al, pe, ct⟩ := md
  cases fa <;> cases pe <;> cases w <;> rfl

set_option maxRecDepth 100000 in
theorem dense_layout (w : W) (fa pe : Bool) : (denseOp w).layout fa pe =
    some (if pe then ⟨[⟨0, 0, 1, false⟩, ⟨1, 0, 1, false⟩, ⟨0, 0, 0, false⟩, ⟨2, 0, 1, false⟩], 0, 3⟩
      else if fa then ⟨[⟨1, 0, 1, false⟩, ⟨2, 0, 1, false⟩, ⟨0, 0, 0, false⟩, ⟨3, 0, 1, false⟩], 1, 4⟩
      else ⟨[⟨0, 0, 1, false⟩, ⟨1, 0, 1, false⟩, ⟨0, 0, 0, false⟩, ⟨2, 0, 1, false⟩], 0, 3⟩) := by
  cases w <;> cases fa <;> cases pe <;> rfl

set_option maxRecDepth 100000 in
theorem dense_shape (w : W) : (denseOp w).info.shape = .switch := by
  cases w <;> rfl

/-- The operands `R.unpack` gives for `denseArgs`'s registers: the slot, `base`, no default
(not passed), the table of `n` cases. -/
theorem dense_vals {ρ : R.Addrs} {fr : Vm.Frame} {w : W} {sl : BitVec 32} {base n : BitVec 64}
    {args : List R.Arg} {vals : Operands}
    (hargs : denseArgs fr (denseOp w) sl base n = some args)
    (hu : R.unpack ρ (denseOp w) fr.mode args = some vals) :
    vals = [.slot sl.toInt, .imm base.toNat, .none, .targets n.toNat] := by
  obtain ⟨fsz, md, rg⟩ := fr
  rw [dense_args_eq] at hargs
  cases hargs
  have hs : (sl.setWidth 64).toNat < 2 ^ 32 := by
    rw [Dense.toNat_zext sl (by decide)]; exact sl.isLt
  have hsl : R.int32 (sl.setWidth 64).toNat = sl.toInt := by
    unfold R.int32
    rw [Dense.toNat_zext sl (by decide), BitVec.ofNat_toNat, BitVec.setWidth_eq]
  have hsl3 : R.int32 sl.toNat = sl.toInt := by
    rw [← hsl, Dense.toNat_zext sl (by decide)]
  have hsl4 : R.int32 (sl.toNat % 2 ^ 64) = sl.toInt := by
    rw [Nat.mod_eq_of_lt (Nat.lt_trans sl.isLt (by decide))]; exact hsl3
  have hs3 : sl.toNat < 2 ^ 32 := sl.isLt
  have hs4 : sl.toNat % 2 ^ 64 < 2 ^ 32 := by
    rw [Nat.mod_eq_of_lt (Nat.lt_trans sl.isLt (by decide))]; exact hs3
  obtain ⟨fa, fp, al, pe, ct⟩ := md
  simp only at hu
  cases fa <;> cases pe <;> cases w <;>
    simp [R.unpack, R.unpackOpnd, R.regImm, denseRegs, dense_layout, dense_operands, dense_shape,
      immKind, hs, hs3, hs4, hsl, hsl3, hsl4] at hu <;>
    first
      | exact hu.symm
      | exact hu.2.symm
      | (obtain ⟨-, hu⟩ := hu; exact hu.symm)
      | (subst hu; rfl)
      | (obtain ⟨-, rfl⟩ := hu; rfl)
      | (by_cases hb : base.toNat < 256 <;> simp [hb] at hu <;> first | exact hu | exact hu.symm)
      | (by_cases hb : base.toNat < 65536 <;> simp [hb] at hu <;> first | exact hu | exact hu.symm)
      | (by_cases hb : base.toNat < 4294967296 <;> simp [hb] at hu <;>
          first | exact hu | exact hu.symm)

/-- `switch.dense`'s `opSem` from the frame related to `x` (`Rel`): the case index `denseIdx`
of the slot's bytes in `x` (`Dense.denseIdx_opSem`, `read_int`), the state unchanged. -/
theorem dense_opSem {w : W} {sl : BitVec 32} {base n : BitVec 64} {args : List R.Arg}
    {vals : Operands} {st : OpSem.State} {x : X86.State}
    (hargs : denseArgs S.fr (denseOp w) sl base n = some args)
    (hu : R.unpack S.c.ρ (denseOp w) S.c.mode args = some vals)
    (hrel : Rel st x) (hno : Handler.NoUB (denseOp w) vals st) :
    ∃ ch, opSem (denseOp w) vals st ch =
      .ok (.index (Dense.denseIdx w (x.memW w (x.ea (M.frame sl))) base n), st) := by
  have hv := dense_vals (fr := S.fr) hargs hu
  subst hv
  cases hs : opSem (denseOp w) [.slot sl.toInt, .imm base.toNat, .none, .targets n.toNat] st {}
    with
  | error e =>
    obtain ⟨m, rfl⟩ := hno {} _ hs
    exact absurd hs (dense_nb w _ st m)
  | ok r =>
    obtain ⟨ctl, st'⟩ := r
    obtain ⟨bs, v, hrd, hvv, rfl, rfl⟩ :=
      opSem_dense (dense_handler w) (tyName_parse w).1 (dense_operands w) hs
    refine ⟨{}, ?_⟩
    rw [hs]
    have hn : wbytes w ≤ 16 := by cases w <;> decide
    have hval := read_int hrel hn hrd hvv
    have hk : w.bits = 8 * wbytes w := by cases w <;> rfl
    have e := Dense.denseIdx_opSem w (x.memW w (x.ea (M.frame sl))) base n (wbytes w) v
      base.toNat n.toNat hk (by
        rw [memW_eq, ea_frame, BitVec.toNat_ofNat, ← wbytes_eq, hval])
      rfl rfl
    rw [e]

/-- `FrameInv` after the scopes, the machine state unchanged (no handler call). -/
theorem dense_frameInv (H : Hyps S) {s s1 : R.RState} {x : X86.State} {pc : Nat}
    (hf : FrameInv S s x) (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hnl : ¬ LeadArg S pc) : FrameInv S { s1 with pc, st := s1.st } x := by
  have hk := scopes_keeps _ hsc
  have hfb := H.frameBounds
  have hwinT : (s.fp : Int) + S.K ≤ 2 ^ 64 := hf.win
  obtain ⟨hr1, hsep1⟩ := sep_foldlM _ (hfb.scopesIn s.pc) (hfb.window hwinT) hf.rrel hf.sep hsc
  obtain ⟨-, hm1⟩ := memRel_foldlM _ (hfb.scope_size _) hf.rrel hf.mem hsc
  refine ⟨⟨hr1.rel, hr1.rbp, hr1.wf⟩, hm1, hsep1, ?_, ?_, hf.rsp, hf.room, hf.code, hf.ro,
    fun ha => absurd ha hnl, hf.frame, (H.slots_scopes (s1 := s1) hf hsc :),
    (hf.esc.scopes hsc).of_not hnl⟩
  · show (s1.fp : Int) + S.K ≤ 2 ^ 64
    rw [hk.fp]; exact hwinT
  · show S.F ≤ s1.fp
    rw [hk.fp]; exact hf.fpF

theorem dense_switch_canon (tb : BitVec 32) (p : Nat) : Canon (Switch.switchItems tb) p := by
  have c : ∀ (i : Item) (p : Nat), i.wf (BitVec.ofNat 32 p) = true →
      (∀ b e, i ≠ .tableEntry b e) → i.Canonical p := fun _ _ hw ht => ⟨ht, .inl hw⟩
  refine ⟨c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, trivial⟩ <;>
    intro _ _ h <;> cases h

set_option maxHeartbeats 1000000 in
/-- A dense switch: `denseSwitch`'s inline index computation (`Asm.denseIndex`) and its jump
table, standing in for R's `switch.dense` handler call. R: the scopes, then `opSem`'s index
(`dense_opSem`, no writes) and PE's home space made `Uninit` (`R.clearHome`, as for any handler
call: `hdl_frameInv_clear`); x86: `Dense.dense_switch_steps` to the entry's target, the registers
but `rax`/`rcx` kept (`Dense.Keep`, `hdl_switch_regs`), so `FrameInv` of R's state after the
scopes (`dense_frameInv`, `hdl_frameInv_regs`); the target's cache cleared
(`CacheCleared.targets`). -/
theorem bodySim_dense (_hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (denseSwitch S.fr).run cur = .ok (some q, c')) (htable : HdlTables S) :
    BodySim S k p (S.used k) := by
  intro s x hs hf hrip hci hsafe
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
  -- The code and the table in memory.
  have hLp := bs_linkOk_at hf.code p
  obtain ⟨hca, -, -⟩ := hLp.dec (hd1.append hd2) hP.bound
  obtain ⟨htb, hbtb, hes31⟩ :=
    htable (atPos (atPos S.body p) at_) tb pE es k rfl rfl rfl (Dec.at_iff.2 hd2) hes
      (List.ne_nil_of_length_pos (by omega)) hlt (fun e he => by
        rw [hpk]
        simp [Proto.targets, R.Then.targets] <;> exact ⟨e, he, rfl⟩)
  have htab : CodeAt S.ctx x.mem (es.map (Item.tableEntry tb)) tb.toNat :=
    entries_codeAt hf.code hes hbtb
  have hcan : Canon (its ++ Switch.switchItems tb) p :=
    (canon_append _ _ _).2 ⟨handler_canon_of (Dense.dense_items_canonical hden),
      dense_switch_canon _ _⟩
  subst hI
  obtain ⟨x'', hst, -, hrip'', hmem, -, y, -, hk, hex⟩ :=
    Dense.dense_switch_steps (ctx := S.ctx) hden hcan hca hrip htab hi2 htb hes31
  -- The machine state after the jump.
  have hreg : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x''.regs i = x.regs i :=
    fun i h0 h1 => (hdl_switch_regs hex i h0 h1).trans (hk.2.2 i h0 h1)
  have hrbp : x''.reg .rbp = x.reg .rbp := by
    show x''.regs 5 = x.regs 5
    exact hreg 5 (by decide) (by decide)
  have hrsp : x''.rsp = x.rsp := by
    show x''.regs 4 = x.regs 4
    exact hreg 4 (by decide) (by decide)
  have hsv : ∀ i, Saved S.c.mode.pe i → x''.regs i = x.regs i := by
    intro i hi
    apply hreg <;> rcases hi with (rfl | rfl | rfl | rfl | rfl | rfl) | ⟨-, rfl | rfl⟩ <;> decide
  -- R's step clears PE's home space (`R.clearHome`), though the inline switch calls nothing.
  have hfi'' := hdl_frameInv_regs
    (hdl_frameInv_clear H (dense_frameInv H hf hsc hnl) (hdl_home_le H hi) hcl) hmem hrbp hrsp
    hsv hnl
  refine Reach.steps hst (.done (.inl ⟨_, .step hstep, hfi'', .inr ⟨?_, ?_⟩⟩))
  · show x''.rip = addrAt S.ctx (posOf S.r pc)
    rw [hrip'', hpe]
  · show CacheInv (S.used pc) x''
    have hc := H.cacheTargets k hlt _ htg
    simp only [Setup.used, hpe, hc, ↓reduceIte]
    exact CacheInv.emptyPe _ _

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
    (hnop : NopRead S.fr S.callSites S.body q c'.pos (S.start (k + 1)))
    (hcache : S.cache (k + 1) = cache') (htable : HdlTables S) :
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
    bodySim_of_read hD H ⟨hk, ⟨p1, counter, by simp [hk, hq]⟩, hinsn, hb2, hnop, hcache, hargs⟩ hpr htable
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

/-! ### The entry's code as `read` reads it -/

/-- A `for` loop over items whose body reads exactly its item (and yields): the loop reads the
list. -/
theorem forIn_dec {c0 : Cursor} (f : Item → PUnit → DM (ForInStep PUnit))
    (hf : ∀ a b cur r cur', cur = atPos c0 cur.pos → (f a b).run cur = .ok (r, cur') →
      r = .yield PUnit.unit ∧ cur' = atPos c0 cur'.pos ∧ Dec c0 cur.pos [a] cur'.pos) :
    ∀ (L : List Item) (b : PUnit) (cur c' : Cursor) (u : PUnit), cur = atPos c0 cur.pos →
      (forIn L b f).run cur = .ok (u, c') → Dec c0 cur.pos L c'.pos
  | [], b, cur, c', u, _, h => by
    simp only [List.forIn_nil] at h
    obtain ⟨-, rfl⟩ := pure_ok h
    exact .nil _
  | a :: L, b, cur, c', u, hc, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    obtain ⟨rfl, e1, d1⟩ := hf a b cur r c1 hc h1
    exact Dec.append d1 (forIn_dec f hf L _ c1 c' u e1 h2)

/-- `readFrame` reads exactly the entry's counter check (with counters; returning its stub and
where it ends) and then `prologue frameSize mode`. -/
theorem readFrame_exact {mode : Mode} {c c' : Cursor} {entry : Option (Nat × Nat)} {fs : Nat}
    (h : (readFrame mode).run c = .ok ((entry, fs), c')) :
    ∃ p1, ((mode.counters = false → p1 = c.pos ∧ entry = none) ∧
      (mode.counters = true → ∃ (t : BitVec 32) (l : Bool),
        Dec c c.pos (Counter.check false t l) p1 ∧ entry = some (t.toNat, p1))) ∧
      Dec c p1 (prologue fs mode) c'.pos := by
  have ite_ok : ∀ {α : Type} {p : Prop} [Decidable p] {x y : DM α} {c c' : Cursor} {a : α},
      (if p then x else y).run c = .ok (a, c') →
        (p ∧ x.run c = .ok (a, c')) ∨ (¬p ∧ y.run c = .ok (a, c')) := by
    intro α p _ x y c c' a h
    by_cases hp : p
    · exact .inl ⟨hp, by simpa only [hp, ite_true] using h⟩
    · exact .inr ⟨hp, by simpa only [hp, ite_false] using h⟩
  unfold readFrame at h
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h1, -⟩ := bind_ok h; exact (err_ok h1).elim
  obtain ⟨entry', c1, h1, h⟩ := bind_ok h
  have e1 : c1 = atPos c c1.pos := posOnly_run (by posonly) h1
  have d1 : (mode.counters = false → c1.pos = c.pos ∧ entry' = none) ∧
      (mode.counters = true → ∃ (t : BitVec 32) (l : Bool),
        Dec c c.pos (Counter.check false t l) c1.pos ∧ entry' = some (t.toNat, c1.pos)) := by
    rcases ite_ok h1 with ⟨hc, h1⟩ | ⟨hc, h1⟩
    · obtain ⟨i1, ca, ha, h1⟩ := bind_ok h1
      obtain ⟨i2, cb, hb', h1⟩ := bind_ok h1
      split at h1
      · obtain ⟨n1, hn1, rfl⟩ := run_tryItem_some ha
        obtain ⟨n2, hn2, rfl⟩ := run_tryItem_some hb'
        obtain ⟨_, _, h5, h1⟩ := bind_ok h1
        obtain ⟨rfl, rfl⟩ := pos_run' h5
        obtain ⟨he, rfl⟩ := pure_ok h1
        refine ⟨fun h0 => (by rw [h0] at hc; cases hc), fun _ => ⟨_, _, Dec.cons hn1 (Dec.single hn2), ?_⟩⟩
        first | exact he.symm | exact he
      · exact (err_ok h1).elim
    · obtain ⟨he, rfl⟩ := pure_ok h1
      exact ⟨fun _ => ⟨rfl, by first | exact he.symm | exact he⟩, fun h0 => absurd h0 hc⟩
  obtain ⟨start, c2, h2, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pos_run' h2
  obtain ⟨fu, c3, h3, h⟩ := bind_ok h
  rw [fuel_run h3] at h
  obtain ⟨alloc, c3, h3, h⟩ := bind_ok h
  have e3 : c3 = atPos c c3.pos := by
    refine (posOnly_run ?_ h3).trans (by rw [e1])
    refine PosOnly.forIn_range _ _ _ (fun _ _ => PosOnly.bind PosOnly.tryItem (fun o => ?_))
    rcases o with _ | i
    · exact PosOnly.pure _
    · cases i <;> first | exact PosOnly.pure _ | (rename_i x; cases x <;> exact PosOnly.pure _) | (rename_i x y; cases x <;> exact PosOnly.pure _) | (rename_i x y; cases x <;> cases y <;> exact PosOnly.pure _)
  rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨_, _, h4, -⟩ := bind_ok h; exact (err_ok h4).elim
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  rw [run_setPos] at h4
  cases h4
  obtain ⟨u, c4, h4, h⟩ := bind_ok h
  have d4 := forIn_dec (c0 := c) _ (fun a b cur r cur' hc hr => by
      obtain ⟨at_, ca, ha, hr⟩ := bind_ok hr
      obtain ⟨rfl, rfl⟩ := pos_run' ha
      obtain ⟨o, cb, hb', hr⟩ := bind_ok hr
      rcases ite_ok hr with ⟨-, hr⟩ | ⟨hne, hr⟩
      · obtain ⟨_, _, h', -⟩ := bind_ok hr; exact (err_ok h').elim
      · obtain ⟨rfl, rfl⟩ := pure_ok hr
        have ho : o = some a := by simpa using hne
        subst ho
        obtain ⟨n, hn, rfl⟩ := run_tryItem_some hb'
        have hn' : decodeItem (atPos c ca.pos) = some (a, n) := by rw [← hc]; exact hn
        exact ⟨rfl, by rw [hc], Dec.single hn'⟩)
    _ _ (atPos c3 c2.pos) c4 u (by rw [e3]) h4
  refine ⟨c2.pos, ?_, ?_⟩
  all_goals rcases ite_ok h with ⟨-, h⟩ | ⟨-, h⟩
  · obtain ⟨u, c5, h5, h⟩ := bind_ok h
    simp only [StateT.run, modify, modifyGet, MonadStateOf.modifyGet, StateT.modifyGet, pure,
      Except.pure] at h5
    cases h5
    obtain ⟨he, -⟩ := pure_ok h
    cases he
    exact d1
  · obtain ⟨he, -⟩ := pure_ok h
    cases he
    exact d1
  · obtain ⟨u, c5, h5, h⟩ := bind_ok h
    simp only [StateT.run, modify, modifyGet, MonadStateOf.modifyGet, StateT.modifyGet, pure,
      Except.pure] at h5
    cases h5
    obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    exact d4
  · obtain ⟨he, rfl⟩ := pure_ok h
    cases he
    exact d4

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

/-- `read_instructions_targets` with the entry's code (frame-pointer form, the read from position
0): the counter check and its stub (`CheckReadC`, the stub at a position every property kept by
`Dec` reaches from the instructions' end) and the prologue of the frame size, up to the body's
cursor. -/
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
      (mode.framePointer = true → ∃ p1, CheckReadC c0 mode
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
  refine ⟨_, c7, _, padded, hb, hc7, fun hfp => ⟨items, ?_⟩, fun hfp => ?_⟩
  · show Dec (atPos c5 c1.pos) c.pos items c1.pos
    rw [hx hfp, Dec.at_iff]
    exact hd
  have hcv : ∀ {p L q}, Dec c p L q → Dec (atPos c5 c1.pos) p L q := fun d => by
    rw [hx hfp, Dec.at_iff]; exact d
  obtain ⟨hk1, hk2⟩ := hq1
  refine ⟨q1, ⟨fun hc => (hk1 hc).1.trans hc0, fun hc => ?_⟩, hcv hqd⟩
  obtain ⟨t, l, hdc, hen⟩ := hk2 hc
  subst hen
  obtain ⟨-, tb, bl, q, htb, hds⟩ :=
    checkStubs_entry (fun _ => True) (fun _ _ _ _ _ => trivial) trivial h10
  exact ⟨t, l, tb, bl, q, hc0 ▸ hcv hdc, htb,
    fun R hR hR0 => (checkStubs_entry R (fun p L q hp hd => hR p L q hp (sl_dec e9' hd))
      (by rw [hbe]; exact hR0) h10).1, sl_dec e9' hds⟩

/-- Every function `decodeReduced` accepts without a PE pad region (`regionPad … = none`) has a
`Setup` that is its read, for any R code with its `Decoded` and mode and any choice of the other
parameters. -/
theorem decodes_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (hnr : regionPad mode callSites = none)
    (hcs : callSitesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.Safe = Safe := by
  obtain ⟨r, c', hread, hred⟩ := decodeReduced_read hdec
  obtain ⟨targets, cT, hT⟩ := readTargets_of_check hcc
  obtain ⟨c0, c1, stub, padded, hc0, hrun, hpro, hent⟩ :=
    read_instructions_entry hread hT hnr rfl
  obtain ⟨hit, -, -, -⟩ := instructions_read hrun
  -- The entry's code, with the stub's relocation boundary from the instructions' end.
  have hentry : c.mode.framePointer = true → ∃ p1, CheckReadC c0 c.mode
      (fun s => ∀ m, LinkOk ctx m c0 relocs → Boundary relocs s) p1 ∧
      Dec c0 p1 (prologue c.d.frameSize c.mode) c0.pos := by
    intro hfp
    rw [hm] at hfp
    obtain ⟨p1, ⟨hk1, hk2⟩, hpr⟩ := hent hfp
    have hF : c.d.frameSize = r.frameSize := by rw [hc]; exact reducedOf_frameSize hred
    refine ⟨p1, ⟨fun h0 => hk1 (hm ▸ h0), fun h0 => ?_⟩, by rw [hF, hm]; exact hpr⟩
    obtain ⟨t, l, tb, bl, q, d1, e1, hB, d2⟩ := hk2 (hm ▸ h0)
    refine ⟨t, l, tb, bl, q, d1, e1, fun m hL => ?_, d2⟩
    obtain ⟨-, -, hb0⟩ := hL.dec (Dec.append d1 hpr) (boundary_zero _)
    exact hB (Boundary relocs) (fun p L q hp hd => (hL.dec hd hp).2.2)
      (sl_iters_boundary hL (instructions_read hrun).1 hb0)
  obtain ⟨st, ca, drs, ar, h0, hc0', hd0, ha0, -, -, har, hix⟩ := iters_indexed hit
  have hsz : c0.code.size = code.data.size := by rw [hc0]; rfl
  refine ⟨Setup.mk ctx E c r c0 relocs rodata callSites targets st ca drs ar x0 Owned lo padOf
    Safe, ⟨⟨c', hread⟩,
    hc ▸ hred, hm, rfl, rfl, rfl, hnr, hc0, ?_, h0, hc0', hd0, ha0, har, ?_,
    fun hfp => hpro (hm ▸ hfp), hcs, ⟨cT, hT⟩, hentry⟩, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  · exact ⟨stub, padded, c1, by simpa [Setup.fr, hm, hsz] using hrun⟩
  · simpa [Setup.fr, hm] using hix

/-- **`decode_sound`** (aot.md §C2): for a function the decoder accepts (`Decodes`, given by
`decodes_of_ok` from `decodeReduced … = .ok d`) under `Hyps`, the fetching machine with its
environment simulates the R program from every boundary whose R runs are safe. -/
theorem decode_sound {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) (htc : tablesCheck code relocs rodata callSites dropped scopes mode = true) :
    ∀ s x, BInv S s x → SafeFrom S.Safe S.c s → FnSim S.ctx S.E S.c (BInv S) (ExitRel S) s x := by
  have htable : HdlTables S := DecodeLink.Tables.hdlTables_of_check hD htc
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
      exact insnSim_main hD H hk hpk hpad hctr hpr hnop hca1 htable s x rfl hbi hsafe
  · exact insnSim_oob hD (Nat.le_of_not_lt hk) s x rfl hbi hsafe

/-- `decode_sound` from the decoder's acceptance directly (without a PE pad region, as
`decodes_of_ok`; and with the switch tables checked, `htc`). -/
theorem decode_sound_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (hnr : regionPad mode callSites = none)
    (htc : tablesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcs : callSitesCheck code relocs rodata callSites dropped scopes mode = true)
    (hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode = true)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.Safe = Safe ∧
      (Hyps S → ∀ s x, BInv S s x → SafeFrom Safe c s → FnSim ctx E c (BInv S) (ExitRel S) s x) := by
  obtain ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h8⟩ :=
    decodes_of_ok hdec hnr hcs hcc c hc hm ctx E x0 Owned lo padOf Safe
  refine ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h8, fun H => ?_⟩
  subst h1 h2 h3 h8
  exact decode_sound hD H htc

/-- What `Frame.decodeChecked` accepting a function gives: `decodeReduced`'s acceptance, the
bound check (`Decoded.boundsOk`), `tablesCheck`, `frameSizesCheck`, `privCheck`, `callSitesCheck`,
`relocsInCheck` (`Hyps.relocsInOk` by `relocsInOk_of_decodes`), `cacheClearedCheck`
(`Hyps.cacheOk` by `cacheOk_of_decodes`) and `argsLeadCheck` (`Hyps.argsChecked` by
`argsChecked_of_decodes`). -/
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
      argsLeadCheck code relocs rodata callSites dropped scopes mode = true := by
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
    cases ht : tablesCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, ht, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hcs : callSitesCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, ht, hcs, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hri : relocsInCheck code.data relocs with
    | false => simp [hb, hfs, hpc, ht, hcs, hri, bind, Except.bind, pure, Except.pure, throw, throwThe,
        MonadExceptOf.throw] at h
    | true =>
    cases hcc : cacheClearedCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, ht, hcs, hri, hcc, bind, Except.bind, pure, Except.pure, throw,
        throwThe, MonadExceptOf.throw] at h
    | true =>
    cases hal : argsLeadCheck code relocs rodata callSites dropped scopes mode with
    | false => simp [hb, hfs, hpc, ht, hcs, hri, hcc, hal, bind, Except.bind, pure, Except.pure, throw,
        throwThe, MonadExceptOf.throw] at h
    | true =>
      cases hdn : Frame.droppedNotDead d0 mode facts with
      | error e => simp [hb, hfs, hpc, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure, Except.pure] at h
      | ok l =>
        cases l with
        | nil =>
          simp [hb, hfs, hpc, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure, Except.pure] at h
          subst h
          exact ⟨hd, hbo, rfl, hfs, hpc, rfl, rfl, rfl, rfl⟩
        | cons k rest =>
          simp [hb, hfs, hpc, ht, hcs, hri, hcc, hal, hdn, bind, Except.bind, pure, Except.pure, throw,
            throwThe, MonadExceptOf.throw] at h

/-- `decode_sound_of_ok` from the checked decoder's acceptance (`Frame.decodeChecked`: the
bound check, `tablesCheck`, `frameSizesCheck`, `privCheck`, `callSitesCheck`, `relocsInCheck`,
`cacheClearedCheck` and `argsLeadCheck` included). -/
theorem decode_sound_of_checked {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {facts : Frame.Facts} {d : Decoded}
    (hdec : Frame.decodeChecked code (.relocs relocs) rodata callSites dropped scopes mode facts =
      .ok d)
    (hnr : regionPad mode callSites = none)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.Safe = Safe ∧
      (Hyps S → ∀ s x, BInv S s x → SafeFrom Safe c s → FnSim ctx E c (BInv S) (ExitRel S) s x) :=
  have h := decodeChecked_ok hdec
  decode_sound_of_ok h.1 hnr h.2.2.1 h.2.2.2.2.2.1 h.2.2.2.2.2.2.2.1 c hc hm ctx E x0 Owned lo padOf
    Safe

end Ryo.Proofs.DecodeSound
