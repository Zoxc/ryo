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
code (`posOf_le_size`, so `posOf_lt_32`). Still `sorry`: `bodySim_inline` (worked on in
`DSWork/Inline.lean`) and `bodySim_dense`'s `dense_vals` (the operands `R.unpack` gives a dense switch).

**Files.** `DecodeSound/Basic.lean`: §1–§3 and §4's helpers, `bodySim_unreachable`,
`bodySim_jmp`, `reach_padding`, `boundary_start`. `DSWork/Boundary.lean`: the decoder facts.
`DSWork/{Arg,Ret,Island,Counter,Call,Handler}.lean`: `bodySim_arg`, `bodySim_ret`,
`bodySim_island`, `reach_counter`, `bodySim_call'`, `bodySim_handler'`. This file: the open bodies, the dispatch, `insnSim_main`, §5.

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
  `relocsIn` (`RelocsIn`: relocated fields within the code), `hdlTables`
  (`HdlTables`: switch tables at relocation boundaries, below `2 ^ 31`), `argsOk` (`ArgsOk`:
  the leading `arg`s read distinct argument registers of the convention, and no branch target
  is one);
- privacy after the scopes (checkable with the scopes, as an invariant): `loadPrivate` (a
  `load`'s destination, `LoadPrivate`), `argPrivate` (an `arg`'s, `ArgPrivate`),
  `resultPrivate` (a call's result slots, `ResultPrivate`), `linkPrivate` (the frame's link
  slots, in no escaped object or `Lend` extent, `LinkPrivate`), `peShadow` (on PE the island
  templates' 32-byte shadow space at the frame's bottom holds no private byte);
- the environment and the layout (not checkable from the function): `sepAcross` (the frame
  separation across handler calls, calls and islands, `SepAcross`: `FrameSep.extend`'s
  allocation facts, not yet in the contracts), `envApart` (`EnvApart`: the frame window not
  runtime-owned, live allocations neither runtime-owned nor below `rsp`, the symbol slots and
  the JIT record off the stack), `stackSizes` (`StackSizes`: the callees' stack areas, fitting
  the frame, from the image), `codeApart` (`CodeApart`: nothing the function or its environment writes is code or
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
import Ryo.Proofs.DSWork.Call
import Ryo.Proofs.DSWork.Handler
import Ryo.Proofs.Dense
import Ryo.Proofs.DSWork.Inline

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
`reach_counter` (Counter), `bodySim_call'` (Call), `bodySim_handler'` (Handler);
`bodySim_unreachable`, `bodySim_jmp` in `DecodeSound/Basic.lean`. Still `sorry` here:
`bodySim_inline` (worked on in `DSWork/Inline.lean` as `bodySim_inline'`) and the dense
switch's `dense_vals`. -/

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
    fun ha => absurd ha hnl, hf.frame⟩
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
(`dense_opSem`, no writes); x86: `Dense.dense_switch_steps` to the entry's target, the registers
but `rax`/`rcx` kept (`Dense.Keep`, `hdl_switch_regs`), so `FrameInv` of R's state after the
scopes (`dense_frameInv`, `hdl_frameInv_regs`); the target's cache cleared
(`CacheCleared.targets`). -/
theorem bodySim_dense (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : (denseSwitch S.fr).run cur = .ok (some q, c')) :
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
  obtain ⟨pc, hpc, hstep⟩ := hsucc ch _ _ hop
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
  have hnl : ¬ LeadArg S pc := H.argsOk.untargeted k hlt _ htg pc hpe
  -- The code and the table in memory.
  have hLp := bs_linkOk_at hf.code p
  obtain ⟨hca, -, -⟩ := hLp.dec (hd1.append hd2) hP.bound
  obtain ⟨htb, hbtb, hes31⟩ :=
    H.hdlTables (atPos (atPos S.body p) at_) tb pE es k rfl rfl rfl (Dec.at_iff.2 hd2) hes
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
  have hfi'' := hdl_frameInv_regs (dense_frameInv H hf hsc hnl) hmem hrbp hrsp hsv hnl
  refine Reach.steps hst (.done (.inl ⟨_, .step hstep, hfi'', .inr ⟨?_, ?_⟩⟩))
  · show x''.rip = addrAt S.ctx (posOf S.r pc)
    rw [hrip'', hpe]
  · show CacheInv (S.used pc) x''
    have hc := H.cacheCleared.targets k hlt _ htg
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
    (hr : ProtoRead S.fr S.ro true S.body p (S.used k) (S.dr k) (S.args k) q c' cache' dr') :
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
    · exact bodySim_dense hD H hP hn hd
    have hir := insnCore_read hcore
    have hir' := hir
    cases hir' with
    | handler => exact bodySim_handler' hD H hP hn hir (by simp) hnd
    | ret => exact bodySim_ret hD H hP hn hir rfl
    | unreachable => exact bodySim_unreachable hD H hP hn hir rfl
    | jmp => exact bodySim_jmp hD H hP hn hir rfl
    | island => exact bodySim_island hD H hP hn hir rfl
    | resume => exact bodySim_handler' hD H hP hn hir (by simp) hnd
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
