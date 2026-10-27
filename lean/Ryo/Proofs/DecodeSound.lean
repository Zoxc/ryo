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
  the unconsumed ones stay related; at instruction 0 it is `ArgsRel`), and the frame's link to the caller (`FrameFacts`: return address, saved `rbp` (and PE `rsi`/`rdi`), the
  other callee-saved registers as at entry).
- `ExitRel`: a return with the return registers related, `rip` the return address, `rsp` and
  the callee-saved registers as the caller left them, and the world related; a tail call at the
  callee's entry (`EntryAt`) with `rsp` as at entry; an unwind out of the function is not a
  state of this function (the unwinder lands in a caller), so never related here.

**Per instruction** (§4). `InsnSim` at `k` splits into the prologue of the iteration (the
padding's `nop`s, `reach_padding`, proved; the counter check, `reach_counter`) and the body
(`BodySim`), one lemma per shape the decoder reads (`bodySim_arg`, `bodySim_call`,
`bodySim_inline`, `bodySim_handler`, `bodySim_ret`, `bodySim_unreachable` and `bodySim_jmp`
(both proved), `bodySim_island`), dispatched by `bodySim_of_read` over `ProtoRead`/`InsnRead`.
Proved helpers: decoded branches are canonical (`branch_canonical`), every iteration starts at a
relocation boundary (`boundary_start`), R's scopes never stop with `noBehavior` (`noNB_scopes`).
Facts of the decoder used and not yet proved (`sorry`): the prologue read item by item
(`read_instructions_prologue`), landing pads are `lpad`s (`pad_lpad`, so not leading `arg`s,
`pad_not_leadArg`), protos lie within the code (`posOf_le_size`, so `posOf_lt_32`), PE frames are
at least 16 bytes (`frameSize_pe`). The open proofs are worked on in `DSWork/*.lean`.

**`decode_sound`** (§5): from `decodeReduced … = .ok d`, `read_instructions_prologue`,
`instructions_read` and `iters_indexed` give the layout; `reducedOf_insns` the instructions; then
`fnSim_of_insnSim`.

**Hypotheses** (`Hyps`). Trusted: the handler, `resume`, call, island and trip contracts on the
environment's `ret` (`HandlerContract`, `ResumeContract`: `resume`'s handler is assembly, outside
`opSem`, and comes back only at a landing pad; `CallContract`, `IslandContract`,
`TripContract`), the link map (`Linked`, `Globals`). Proved elsewhere, outside the default
build: `OpFacts` of every opcode (`RyoProofs/OpFacts.lean`) and `InlineOk` of every inline class
(`RyoProofs/InlineOk.lean`). A restriction: the frame-pointer mode (`fp`), the items without a
frame pointer have no step lemmas yet. Open prerequisites, each a named hypothesis to be
discharged later:

- of the decoded code, checkable (the decoder or a check could reject the code otherwise):
  `frameBounds` (`FrameBounds c K`, from the decoder, `DecodeLink/Bounds.lean`, in progress),
  `moreBounds` (`MoreBounds`: handler writes and call result slots in the window, to join
  `FrameBounds`), `relocsIn` (`RelocsIn`: relocated fields within the code), `argsOk`
  (`ArgsOk`: the leading `arg`s read distinct argument registers of the convention, and no
  branch target is one);
- privacy after the scopes (checkable with the scopes, as an invariant): `loadPrivate` (a
  `load`'s destination, `LoadPrivate`), `argPrivate` (an `arg`'s, `ArgPrivate`),
  `resultPrivate` (a call's result slots, `ResultPrivate`), `linkPrivate` (the frame's link
  slots, in no escaped object or `Lend` extent, `LinkPrivate`);
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
import Ryo.Proofs.DecodeLink
import Ryo.Proofs.NoArgCursor
import Ryo.Proofs.FrameBounds
import Ryo.Proofs.Shapes
import Ryo.Proofs.Call
import Ryo.Proofs.Island
import Ryo.Proofs.Switch
import Ryo.Proofs.CacheStep

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

/-! ## 1. The simulation -/

/-- The environment: the states it runs from (`out`) and the states it comes back in. -/
structure Env where
  out : X86.State → Prop
  ret : X86.State → X86.State → Prop

/-- From `x`, the machine reaches `Q` whatever the environment does (see the module comment). -/
inductive Reach (ctx : Ctx) (E : Env) (Q : X86.State → Prop) : X86.State → Prop
  | done {x : X86.State} : Q x → Reach ctx E Q x
  | step {x y : X86.State} : Step ctx x y → Reach ctx E Q y → Reach ctx E Q x
  | env {x : X86.State} : E.out x → (∀ y, E.ret x y → Reach ctx E Q y) → Reach ctx E Q x

namespace Reach

variable {ctx : Ctx} {E : Env} {Q Q' : X86.State → Prop}

theorem bind {x : X86.State} (h : Reach ctx E Q x) (k : ∀ y, Q y → Reach ctx E Q' y) :
    Reach ctx E Q' x := by
  induction h with
  | done hq => exact k _ hq
  | step hs _ ih => exact .step hs ih
  | env ho _ ih => exact .env ho ih

theorem mono {x : X86.State} (h : Reach ctx E Q x) (k : ∀ y, Q y → Q' y) : Reach ctx E Q' x :=
  h.bind fun y hy => .done (k y hy)

theorem steps {x y : X86.State} (hs : Steps ctx x y) (h : Reach ctx E Q y) : Reach ctx E Q x := by
  induction hs with
  | refl => exact h
  | step h1 _ ih => exact .step h1 (ih h)

/-- Code steps to `y`, then the environment from `y`. -/
theorem steps_env {x y : X86.State} (hs : Steps ctx x y) (ho : E.out y)
    (k : ∀ z, E.ret y z → Reach ctx E Q z) : Reach ctx E Q x :=
  steps hs (.env ho k)

end Reach

/-- R's step from `s` is safe: errors only for choices outside the allowed set, and its queries
are ones the environment handles. -/
def RSafe (Safe : R.Query → Prop) (c : R.Code) (s : R.RState) : Prop :=
  (∀ ch e, R.step c s ch = .error e → ∃ m, e = .noBehavior m) ∧
  (∀ ch q s1, R.step c s ch = .ok (.ext q s1) → Safe q)

/-- One R transition within the function: a step, or an external event and its answer. -/
inductive RNext (c : R.Code) : R.RState → R.RState → Prop
  | step {s s' : R.RState} {ch : OpSem.Choice} : R.step c s ch = .ok (.step s') → RNext c s s'
  | answer {s s1 s' : R.RState} {ch : OpSem.Choice} {q : R.Query} {a : R.Answer} :
      R.step c s ch = .ok (.ext q s1) → R.answer c s1 a = .ok (.step s') → RNext c s s'

/-- The function ends from `s` with `f`: directly, or after an external event's answer. -/
inductive RDone (c : R.Code) : R.RState → R.Final → Prop
  | step {s : R.RState} {ch : OpSem.Choice} {f : R.Final} : R.step c s ch = .ok (.done f) → RDone c s f
  | answer {s s1 : R.RState} {ch : OpSem.Choice} {q : R.Query} {a : R.Answer} {f : R.Final} :
      R.step c s ch = .ok (.ext q s1) → R.answer c s1 a = .ok (.done f) → RDone c s f

/-- The R states reachable from `s` by `RNext`. -/
inductive RReach (c : R.Code) : R.RState → R.RState → Prop
  | refl (s : R.RState) : RReach c s s
  | step {s s' s'' : R.RState} : RNext c s s' → RReach c s' s'' → RReach c s s''

/-- Every R state reachable from `s` is safe. -/
def SafeFrom (Safe : R.Query → Prop) (c : R.Code) (s : R.RState) : Prop :=
  ∀ s', RReach c s s' → RSafe Safe c s'

theorem SafeFrom.now {Safe : R.Query → Prop} {c : R.Code} {s : R.RState} (h : SafeFrom Safe c s) :
    RSafe Safe c s := h s (.refl s)

theorem SafeFrom.next {Safe : R.Query → Prop} {c : R.Code} {s s' : R.RState}
    (h : SafeFrom Safe c s) (hn : RNext c s s') : SafeFrom Safe c s' :=
  fun s'' hr => h s'' (.step hn hr)

section Sim

variable (ctx : Ctx) (E : Env) (c : R.Code) (Safe : R.Query → Prop)
  (Inv : R.RState → X86.State → Prop) (Exit : R.Final → X86.State → Prop)

/-- What the machine reaches after R's transition from `s`: a related successor, or the
function's end related to R's. -/
def Next (s : R.RState) (x' : X86.State) : Prop :=
  (∃ s', RNext c s s' ∧ Inv s' x') ∨ (∃ f, RDone c s f ∧ Exit f x')

/-- One instruction simulated from every related state with a safe R step. -/
def InsnSim : Prop :=
  ∀ s x, Inv s x → RSafe Safe c s → Reach ctx E (Next c Inv Exit s) x

/-- `n` R transitions simulated from `(s, x)`. -/
def Runs : Nat → R.RState → X86.State → Prop
  | 0, _, _ => True
  | n + 1, s, x => Reach ctx E (fun x' =>
      (∃ s', RNext c s s' ∧ Inv s' x' ∧ Runs n s' x') ∨ (∃ f, RDone c s f ∧ Exit f x')) x

/-- The function simulation: every number of R transitions simulated. -/
def FnSim (s : R.RState) (x : X86.State) : Prop := ∀ n, Runs ctx E c Inv Exit n s x

/-- The composition: one instruction at a time (see the module comment). -/
theorem fnSim_of_insnSim (h : InsnSim ctx E c Safe Inv Exit) :
    ∀ s x, Inv s x → SafeFrom Safe c s → FnSim ctx E c Inv Exit s x := by
  intro s x hi hs n
  induction n generalizing s x with
  | zero => trivial
  | succ n ih =>
    refine (h s x hi hs.now).mono fun x' hx' => ?_
    rcases hx' with ⟨s', hn, hi'⟩ | hd
    · exact .inl ⟨s', hn, hi', ih s' x' hi' (hs.next hn)⟩
    · exact .inr hd

end Sim

/-! ## 2. The layout and the relation -/

/-- The iterations of `instructions`, indexed by instruction: proto `k` is read from
`start k` with cache `cache k` and dropped stores `dr k`, `args k` while every proto before is
an `arg`, the next iteration starting where it ends. -/
def Indexed (fr : Vm.Frame) (ro : ByteArray) (targets : Option (Array Nat)) (c : Cursor)
    (protos : List Proto) (start : Nat → Nat) (cache : Nat → Cache)
    (dr : Nat → List DroppedStore) (args : Nat → Bool) : Prop :=
  ∀ k (hk : k < protos.length), Iter fr ro targets c (args k) (start k) (cache k) (dr k)
    protos[k] (start (k + 1)) (cache (k + 1)) (dr (k + 1))

/-- `Iters` as indexed iterations, from the chain's start to its end. -/
theorem iters_indexed {fr : Vm.Frame} {ro : ByteArray} {targets : Option (Array Nat)} {c : Cursor} :
    ∀ {a : Bool} {p : Nat} {cache : Cache} {dr : List DroppedStore} {qs : List Proto} {pe : Nat}
      {dre : List DroppedStore}, Iters fr ro targets c a p cache dr qs pe dre →
    ∃ (start : Nat → Nat) (ca : Nat → Cache) (drs : Nat → List DroppedStore) (args : Nat → Bool),
      start 0 = p ∧ ca 0 = cache ∧ drs 0 = dr ∧ args 0 = a ∧ start qs.length = pe ∧
      drs qs.length = dre ∧
      (∀ k (hk : k < qs.length), args (k + 1) = (args k && qs[k].op == .arg)) ∧
      Indexed fr ro targets c qs start ca drs args := by
  intro a p cache dr qs pe dre h
  induction h with
  | nil a p cache dr =>
    exact ⟨fun _ => p, fun _ => cache, fun _ => dr, fun _ => a, rfl, rfl, rfl, rfl, rfl, rfl,
      fun k hk => absurd hk (Nat.not_lt_zero _), fun k hk => absurd hk (Nat.not_lt_zero _)⟩
  | @cons a p p' pe cache cache' dr dr' dre q qs hi _ ih =>
    obtain ⟨st, ca, drs, ar, h0, hc0, hd0, ha0, hend, hdend, har, hix⟩ := ih
    let st' : Nat → Nat := fun k => if k = 0 then p else st (k - 1)
    let ca' : Nat → Cache := fun k => if k = 0 then cache else ca (k - 1)
    let drs' : Nat → List DroppedStore := fun k => if k = 0 then dr else drs (k - 1)
    let ar' : Nat → Bool := fun k => if k = 0 then a else ar (k - 1)
    refine ⟨st', ca', drs', ar', rfl, rfl, rfl, rfl, ?_, ?_, ?_, ?_⟩
    · simp only [st', List.length_cons, Nat.add_one_ne_zero, ↓reduceIte, Nat.add_sub_cancel]
      exact hend
    · simp only [drs', List.length_cons, Nat.add_one_ne_zero, ↓reduceIte, Nat.add_sub_cancel]
      exact hdend
    · intro k hk
      cases k with
      | zero => simp [ar', ha0]
      | succ k =>
        have := har k (by simp at hk; omega)
        simpa [ar'] using this
    · intro k hk
      cases k with
      | zero =>
        simp only [st', ca', drs', ar', ↓reduceIte, Nat.zero_add, Nat.add_one_ne_zero,
          Nat.sub_self, h0, hc0, hd0, List.getElem_cons_zero]
        exact hi
      | succ k =>
        have := hix k (by simp at hk; omega)
        simpa [st', ca', drs', ar'] using this

/-- The function being simulated (see the module comment). -/
structure Setup where
  ctx : Ctx
  E : Env
  /-- The R code; its `Decoded` is the decoder's. -/
  c : R.Code
  /-- The decoder's read and its body cursor (code, relocated fields, `spFrame`). -/
  r : ReadResult
  body : Cursor
  rs : Array Reloc
  ro : ByteArray
  /-- The branch targets of the decoder's first pass (the cache is cleared there). -/
  targets : Array Nat
  /-- The iterations (`Indexed`). -/
  start : Nat → Nat
  cache : Nat → Cache
  dr : Nat → List DroppedStore
  args : Nat → Bool
  /-- The frame window's end above `fp`. -/
  K : Int
  /-- The state at the function's entry, just after the caller's `call`. -/
  x0 : X86.State
  Owned : BitVec 64 → Prop
  lo : BitVec 64
  padOf : BitVec 64 → Option (BitVec 64)
  Safe : R.Query → Prop

namespace Setup

variable (S : Setup)

def F : Nat := S.c.d.frameSize

def fr : Vm.Frame := ⟨S.r.frameSize, S.c.mode⟩

/-- The cache the decoder used at proto `k`'s position: cleared at a branch target. -/
def used (k : Nat) : Cache :=
  if sortedContains S.targets (posOf S.r k) then {} else S.cache k

/-- Where proto `k`'s iteration ends: the next one's start. -/
def stop (k : Nat) : Nat := S.start (k + 1)

/-- The frame's link slots are `[linkLo, 16)`: the saved `rbp` and the return address (PE: also
the saved `rsi`/`rdi` below). -/
def linkLo : Int := if S.c.mode.pe then -16 else 0

/-- The address of frame offset `o` (`fp = x0.rsp - 8`, `FrameInv.fpAddr_eq`). -/
def winAddr (o : Int) : BitVec 64 := S.x0.rsp - 8 + BitVec.ofInt 64 o

end Setup

/-! ### The leading `arg`s -/

/-- Instruction `k` is an `arg` of the leading run: it and every instruction before it are
`arg`s (the decoder reads `arg`s only there). -/
def LeadArg (S : Setup) (k : Nat) : Prop := k < S.r.protos.size ∧ S.args (k + 1) = true

/-- Instruction `j` is `arg d, w` reading R's incoming register `r` (as `R.step` reads it). -/
def ArgRegAt (S : Setup) (j : Nat) (r : R.Reg) : Prop :=
  ∃ (op : Reduced.Opcode) (d : BitVec 32) (w : BitVec 64) (f : Full.Opcode) (a : ArgReg),
    S.c.d.insns[j]? = some (.native op [.slot d, .imm w]) ∧ op.full = some f ∧
    f.info.shape = .arg ∧ ArgReg.of? w.toNat true = some a ∧ r = .ofArgReg a

/-- The incoming argument registers not yet consumed at instruction `k`: every argument register
of the convention that no `arg` before `k` reads relates (`arg_store` may clobber the register
it stores, `ArgRet.argClobbers`, so only the later `arg`s' registers stay related; at `k = 0`
this is `ArgsRel`, `argsLive_zero`). -/
def ArgsLive (S : Setup) (k : Nat) (args : R.Regs) (x : X86.State) : Prop :=
  ∀ r, ArgRet.IsArg S.c.mode.pe r → (∀ j, j < k → ¬ ArgRegAt S j r) →
    ArgRet.RegRel S.c.mode.pe args x r

theorem argsLive_zero {S : Setup} {args : R.Regs} {x : X86.State} :
    ArgsLive S 0 args x ↔ ArgsRel S.c.mode.pe args x :=
  ⟨fun h r hr => h r hr (fun _ hj => absurd hj (Nat.not_lt_zero _)), fun h r hr _ => h r hr⟩

/-- The frame's link to the caller (frame-pointer form): `rbp` is the entry `rsp - 8`, with the
return address above it and the caller's `rbp` (PE: also `rsi`, `rdi`) saved below; the other
callee-saved registers as at entry. -/
structure FrameFacts (S : Setup) (x : X86.State) : Prop where
  rbp : x.reg .rbp + 16 = S.x0.rsp + 8
  retAddr : x.mem.read64 (x.reg .rbp + 8) = S.x0.mem.read64 S.x0.rsp
  savedRbp : x.mem.read64 (x.reg .rbp) = S.x0.reg .rbp
  savedPe : S.c.mode.pe = true →
    x.mem.read64 (x.reg .rbp - 16) = S.x0.reg .rsi ∧ x.mem.read64 (x.reg .rbp - 8) = S.x0.reg .rdi
  saved : ∀ i, CalleeSaved i → i ≠ 5 → x.regs i = S.x0.regs i

/-- Everything a boundary relates but the position and the cache (see the module comment). -/
structure FrameInv (S : Setup) (s : R.RState) (x : X86.State) : Prop where
  rrel : RRel s x
  mem : MemRel s.st x
  sep : FrameSep (-(S.F : Int)) S.K s.st x
  win : (s.fp : Int) + S.K ≤ 2 ^ 64
  fpF : S.F ≤ s.fp
  rsp : x.rsp = x.reg .rbp - BitVec.ofNat 64 S.F
  room : S.lo.toNat + 64 ≤ x.rsp.toNat
  code : LinkOk S.ctx x.mem S.body S.rs
  ro : RoLoaded S.ctx x.mem S.ro
  args : LeadArg S s.pc → ArgsLive S s.pc s.args x
  frame : FrameFacts S x

/-- The relation at an instruction boundary (see the module comment). -/
def BInv (S : Setup) (s : R.RState) (x : X86.State) : Prop :=
  FrameInv S s x ∧
    ((x.rip = addrAt S.ctx (S.start s.pc) ∧ CacheInv (S.cache s.pc) x) ∨
      (x.rip = addrAt S.ctx (posOf S.r s.pc) ∧ CacheInv (S.used s.pc) x))

/-- The function's end related to R's (see the module comment). -/
def ExitRel (S : Setup) (f : R.Final) (x' : X86.State) : Prop :=
  WorldRel f.world x' ∧
    match f.exit with
    | .ret regs incoming => RetRel regs x' ∧ x'.rip = S.x0.mem.read64 S.x0.rsp ∧
        x'.rsp = S.x0.rsp + 8 ∧ (∀ i, Saved S.c.mode.pe i → x'.regs i = S.x0.regs i) ∧
        BytesRel incoming (bytesAt x'.mem (S.x0.rsp + 8) S.c.argSize)
    | .tailCall cal regs sp stack => EntryAt S.ctx S.c.mode.pe cal regs sp stack f.world x' ∧
        x'.rsp = S.x0.rsp ∧ ∀ i, Saved S.c.mode.pe i → x'.regs i = S.x0.regs i
    | .unwind _ => False

/-- The simulation's targets after instruction `s.pc`. -/
abbrev SNext (S : Setup) (s : R.RState) : X86.State → Prop := Next S.c (BInv S) (ExitRel S) s

/-- Instruction `k`'s body simulated from `rip` at `p` (past the padding and counter check)
with the cache `cache`. -/
def BodySim (S : Setup) (k p : Nat) (cache : Cache) : Prop :=
  ∀ s x, s.pc = k → FrameInv S s x → x.rip = addrAt S.ctx p → CacheInv cache x →
    RSafe S.Safe S.c s → Reach S.ctx S.E (SNext S s) x

/-- Instruction `k` simulated from every boundary at it. -/
def InsnSimAt (S : Setup) (k : Nat) : Prop :=
  ∀ s x, s.pc = k → BInv S s x → RSafe S.Safe S.c s → Reach S.ctx S.E (SNext S s) x

/-! ### `S` is the decoder's read -/

/-- `S` is `decodeReduced`'s read of a function (see the module comment): the R code is
`reducedOf` of the read, in its mode; the body cursor is the code's with the read's frame; and
the start positions, caches, dropped stores and `arg` flags are those of the second pass's
iterations. -/
structure Decodes (S : Setup) (code : ByteArray) (relocs : Array Reloc) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array R.Scope)
    (mode : Ryo.Obj.Mode) : Prop where
  read : ∃ c', (Vm.read rodata callSites dropped.toList scopes mode).run
    { code := code.data, pos := 0, fields := .relocs relocs } = .ok (S.r, c')
  reduced : reducedOf S.r = .ok S.c.d
  modeEq : S.c.mode = mode
  rsEq : S.rs = relocs
  roEq : S.ro = rodata
  bodyEq : S.body = bodyCursor { code := code.data, pos := 0, fields := .relocs relocs } mode
    S.r.frameSize S.body.pos
  run : ∃ stub padded c1, (instructions S.fr rodata dropped.toList (some S.targets) stub).run
    S.body = .ok ((S.r.protos, padded), c1)
  start0 : S.start 0 = S.body.pos
  cache0 : S.cache 0 = {}
  dr0 : S.dr 0 = dropped.toList
  args0 : S.args 0 = true
  argsSucc : ∀ k (hk : k < S.r.protos.toList.length),
    S.args (k + 1) = (S.args k && S.r.protos.toList[k].op == .arg)
  iters : Indexed S.fr S.ro (some S.targets) S.body S.r.protos.toList S.start S.cache S.dr S.args
  /-- The prologue (the entry's counter check, the frame's `prologue`) is read item by item from
  0 to the body's start (frame-pointer form: the body cursor is the code's). -/
  prologue : S.c.mode.framePointer = true → ∃ items, Dec S.body 0 items S.body.pos

/-- `read_instructions` with the prologue: in the frame-pointer form, the items before the body
are read one after the other from the start (`sorry`: the entry's counter check is two
`tryItem`s, the `for want in prologue` loop `tryItem`s each item, by `forIn_list_inv` as in
`read_instructions`). -/
theorem read_instructions_prologue {ro : ByteArray} {callSites : Array CallSite}
    {dropped : List DroppedStore} {scopes : Array R.Scope} {mode : Ryo.Obj.Mode} {c c' : Cursor}
    {r : ReadResult} (h : (Vm.read ro callSites dropped scopes mode).run c = .ok (r, c')) :
    ∃ (c0 c1 : Cursor) (targets : Array Nat) (stub : Option Nat) (padded : Array Bool),
      c0 = bodyCursor c mode r.frameSize c0.pos ∧
      (instructions ⟨r.frameSize, mode⟩ ro dropped (some targets) stub).run c0 =
        .ok ((r.protos, padded), c1) ∧
      (mode.framePointer = true → ∃ items, Dec c0 c.pos items c0.pos) := by
  sorry  -- TODO(wip): read_instructions_prologue

theorem reducedOf_frameSize {r : ReadResult} {d : Decoded} (h : reducedOf r = .ok d) :
    d.frameSize = r.frameSize := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

/-- Every function `decodeReduced` accepts has a `Setup` that is its read, for any R code with
its `Decoded` and mode and any choice of the other parameters. -/
theorem decodes_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env) (K : Int)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.K = K ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.Safe = Safe := by
  obtain ⟨r, c', hread, hred⟩ := decodeReduced_read hdec
  obtain ⟨c0, c1, targets, stub, padded, hc0, hrun, hpro⟩ := read_instructions_prologue hread
  obtain ⟨hit, -, -, -⟩ := instructions_read hrun
  obtain ⟨st, ca, drs, ar, h0, hc0', hd0, ha0, -, -, har, hix⟩ := iters_indexed hit
  refine ⟨Setup.mk ctx E c r c0 relocs rodata targets st ca drs ar K x0 Owned lo padOf Safe,
    ⟨⟨c', hread⟩,
    hc ▸ hred, hm, rfl, rfl, hc0, ?_, h0, hc0', hd0, ha0, har, ?_, fun hfp => hpro (hm ▸ hfp)⟩,
    rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  · exact ⟨stub, padded, c1, by simpa [Setup.fr, hm] using hrun⟩
  · simpa [Setup.fr, hm] using hix

/-! ## 3. Hypotheses -/

/-- Open: `Private` of a `load`'s destination after the scopes, at each boundary
(`CacheMem.load_step_sep` takes it; reduced.md §C0.3: `load` into an escaped object is not
yet stepped). -/
def LoadPrivate (S : Setup) : Prop :=
  ∀ s x s1 op ops f w vals, BInv S s x → S.c.d.insns[s.pc]? = some (.native op ops) →
    op.full = some f → shapeOk f (.load w) = true → nativeVals S.c.ρ f ops = some vals →
    (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 → Private f vals s1.st

/-- The environment's returns from a call or island: to the return address, or (an unwind)
elsewhere. -/
def RetAt (E : Env) (x x' : X86.State) : Prop := E.ret x x' ∧ x'.rip = x.mem.read64 x.rsp
def UnwAt (E : Env) (x x' : X86.State) : Prop := E.ret x x' ∧ x'.rip ≠ x.mem.read64 x.rsp

/-- The allocation facts `FrameSep.extend` takes of `st'` following `st`, for the frame at
`y`'s `rbp`. -/
def AllocFacts (S : Setup) (st st' : OpSem.State) (y : X86.State) : Prop :=
  AllocsAfter (-(S.F : Int)) S.K st st' y ∧ MemDisjoint st' ∧ InSpace st'

/-- `st` with the world `w`'s memory and exposed allocations (an answer's). -/
def withWorld (st : OpSem.State) (w : R.World) : OpSem.State :=
  { st with mem := w.mem, exposed := w.exposed }

/-- Open: the frame separation across a handler, a call or an island (`FrameSep.extend`): the
contracts strengthened by the allocation facts of the state after (`AllocFacts`: new live
allocations off the frame window, disjoint, in the address space), for the same choice or
answer the contract relates the return to. -/
structure SepAcross (S : Setup) : Prop where
  handler : ∀ h args vals st x x' y, h.hasHandler = true →
    R.unpack S.c.ρ h S.c.mode.fpArg args = some vals → Handler.AtHandler S.ctx h x →
    Handler.ArgsIn S.c.ρ x x args → Handler.HRel st x → Handler.NoUB h vals st → S.E.ret x x' →
    FrameSep (-(S.F : Int)) S.K st y →
    ∃ ch ctl st', opSem h vals st ch = .ok (ctl, st') ∧ Handler.HRel st' x' ∧
      Handler.CtlIn ctl x' ∧ AllocFacts S st st' y
  call : ∀ cal regs sp stack (st : OpSem.State) x x' y,
    EntryAt S.ctx S.c.mode.pe cal regs sp stack ⟨st.mem, st.exposed⟩ x →
    S.Safe ⟨.call cal regs sp stack, ⟨st.mem, st.exposed⟩⟩ →
    (S.c.mode.pe = true → 32 ≤ stack.length) → FrameSep (-(S.F : Int)) S.K st y →
    (RetAt S.E x x' → ∃ a, Call.CallReturn S.c.mode.pe S.Owned S.lo sp stack.length
      ⟨st.mem, st.exposed⟩ x x' a ∧ AllocFacts S st (withWorld st a.world) y) ∧
    (UnwAt S.E x x' → ∃ a exc, a.result = .unwind exc ∧
      Call.CallEnd S.Owned S.lo sp stack.length ⟨st.mem, st.exposed⟩ x x' a ∧
      Call.Landed S.c.mode.pe S.padOf (x.rsp + 8) x x' exc ∧ AllocFacts S st (withWorld st a.world) y)
  island : ∀ isl tpl fp ops lends (st : OpSem.State) w x x' y,
    Island.IslandAt S.ctx S.c.mode.pe isl fp ops st w x →
    S.Safe ⟨.island isl tpl fp ops lends, w⟩ → FrameSep (-(S.F : Int)) S.K st y →
    (RetAt S.E x x' → ∃ a, Island.IslandReturn S.c.mode.pe S.Owned S.lo fp lends w x x' a ∧
      AllocFacts S st (withWorld st a.world) y) ∧
    (UnwAt S.E x x' → ∃ a exc, a.result = .unwind exc ∧
      Island.IslandEnd S.c.mode.pe S.Owned S.lo fp lends w x x' a ∧
      Call.Landed S.c.mode.pe S.padOf (x.rsp + 8 + BitVec.ofNat 64 (Island.shadow S.c.mode.pe)) x x' exc ∧
      AllocFacts S st (withWorld st a.world) y)

/-- Open: the dead-store steps, for an iteration that reads a dropped store with no code
(`Iter.empty`) and an inline sequence with a dropped store in it (`DecodeLink.Drop`'s
`SkipAt`: its kept items run against `cache.emit`). -/
structure DeadStoreSim (S : Setup) : Prop where
  empty : ∀ k, k < S.r.protos.size → ∀ d dr, S.dr k = d :: dr → d.at_ = S.start k →
    InsnSimAt S k
  inline : ∀ k p a cur cur' q c' cache' dr', NoArg S.fr S.body p a cur →
    (callInsn S.fr (S.dr k)).run cur = .ok (none, cur') →
    (inlineInsn (S.used k) (S.dr k) true).run cur' = .ok (some (q, cache', dr'), c') →
    q.dropped = true → BodySim S k p (S.used k)

/-- Open: the cache the decoder used is empty wherever control arrives other than by falling
through: every branch target of the second pass is one of the first pass's, where the cache is
cleared (the second pass, whose inline sequences may differ, isn't checked to jump only there),
and at every landing pad (the decoder doesn't clear it there; the instruction before a pad is
normally a terminator or a call, which leave it empty). -/
structure CacheCleared (S : Setup) : Prop where
  targets : ∀ k (hk : k < S.r.protos.size), ∀ t ∈ S.r.protos[k].targets,
    sortedContains S.targets t = true
  pads : ∀ k pad cat, S.c.cleanupAt k = some (some pad, cat) → S.used pad = {}

/-- Open: the unwinder's landing pad for a return address in instruction `k`'s call sites is
the pad of `k`'s cleanup entry, at its position, and none for a `continue` entry or none (the
LSDA as linked against `Code.cleanupAt`; `Call.call_unwind`'s `hpos`). -/
def PadsLinked (S : Setup) : Prop :=
  ∀ k (hk : k < S.r.protos.size), ∀ site ∈ S.r.protos[k].sites, ∀ p, site.1 < p →
    p ≤ site.1 + site.2 →
    S.padOf (addrAt S.ctx p) = match S.c.cleanupAt k with
      | some (some pad, _) => some (S.ctx.base + (pos32 S.r pad).setWidth 64)
      | _ => none

/-- Open: the counter stub of each loop head is in the code as `read` checked it (`lea r11,
[rip + rec]; mov eax, n; call [r11 + 16]; jmp back`); `read_instructions` doesn't expose the
stub loop yet. -/
def StubsLinked (S : Setup) : Prop :=
  ∀ k (hk : k < S.r.protos.size) stub back, S.r.protos[k].counter = some (stub, back) →
    Boundary S.rs stub ∧ ∃ n t long q, t.toNat = back ∧
      Dec S.body stub [.lea .r11 .record, .setReg .rax (BitVec.ofNat 64 n), .callR11 16,
        .branch .always t long] q

/-- Open: the environment runs from the states just after a call of a handler, a callee, an
island or a trip (`Env.out`), and those are outside the function's body (so `Reach` can't take
an environment step where code runs). -/
structure EnvOutside (S : Setup) : Prop where
  body : ∀ x, S.E.out x → ∀ p, S.start 0 ≤ p → p < S.body.code.size → x.rip ≠ addrAt S.ctx p
  handler : ∀ h x, Handler.AtHandler S.ctx h x → S.E.out x
  call : ∀ cal regs sp stack w x, EntryAt S.ctx S.c.mode.pe cal regs sp stack w x → S.E.out x
  island : ∀ isl fp ops st w x, Island.IslandAt S.ctx S.c.mode.pe isl fp ops st w x → S.E.out x
  trip : ∀ x : X86.State, (∃ d : Nat, x.rip = x.mem.read64 (S.ctx.addrOf .record +
    BitVec.ofNat 64 d)) → S.E.out x

/-- Open (layout): no byte of the code or the rodata is runtime-owned, on the stack below the
entry's `rsp`, in the frame window, or in a live allocation of a related state (so writes keep
`LinkOk` and `RoLoaded`). The image places code and rodata in its own sections; not checkable
from the function alone. -/
def CodeApart (S : Setup) : Prop :=
  ∀ a, ((∃ p, p < S.body.code.size ∧ a = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ a = S.ctx.addrOf (.ro j))) →
    ¬ S.Owned a ∧ ¬ InStack S.lo S.x0.rsp a ∧
      (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → a ≠ S.winAddr o) ∧
      ∀ s x, BInv S s x → ¬ Call.InAlloc s.world a

/-- Trusted: `resume`'s handler (assembly: outside `opSem`, so outside `HandlerContract`)
continues the unwind with the exception object in its slot operand `off`: from its entry `x`
(reached by the handler shape's `call`) the environment comes back only at the landing pad
`padOf` gives for the return address (none: the unwind leaves the function), with the exception
object in `rax`, `rsp` the frame's, the callee-saved registers kept, and memory changed only in
runtime-owned bytes and the stack below `rsp`. -/
def ResumeContract (S : Setup) : Prop :=
  ∀ args off x x', R.unpack S.c.ρ .resume S.c.mode.fpArg args = some [.slot off] →
    Handler.AtHandler S.ctx .resume x → Handler.ArgsIn S.c.ρ x x args → S.E.ret x x' →
    S.padOf (x.mem.read64 x.rsp) = some x'.rip ∧ x'.reg .rax = x.mem.read64 (fpAddr x off) ∧
      x'.rsp = x.rsp + 8 ∧ (∀ i, Saved S.c.mode.pe i → x'.regs i = x.regs i) ∧
      ∀ a, ¬ S.Owned a → ¬ InStack S.lo x.rsp a → x'.mem a = x.mem a

/-- Open (layout and environment): what is apart from what the environment writes (runtime-owned
bytes, the stack below `rsp`). The frame window holds no runtime-owned byte; no live allocation
of a related state is runtime-owned or on the stack below its `rsp` (an invariant: it would
follow from the contracts saying so of the allocations they return, and the scopes allocating in
the window); the symbol slots and what they point to are off the stack below `rsp`; the JIT
record's loop counter is runtime-owned and its OSR slot off the stack. None is checkable from
the function: they are facts of the runtime's and the image's layout. -/
structure EnvApart (S : Setup) : Prop where
  window : ∀ o : Int, -(S.F : Int) ≤ o → o < S.K → ¬ S.Owned (S.winAddr o)
  allocs : ∀ s x, FrameInv S s x → ∀ a, Call.InAlloc s.world a →
    ¬ S.Owned a ∧ ¬ InStack S.lo x.rsp a
  syms : ∀ s x, FrameInv S s x → Call.SymsApart S.ctx S.lo x.rsp x.mem
  ctrOwned : ∀ j < 8, S.Owned (S.ctx.addrOf .recordLoopCtr + BitVec.ofNat 64 j)
  slotOff : ∀ j < 8,
    ¬ InStack S.lo S.x0.rsp (S.ctx.addrOf .record + BitVec.ofNat 64 16 + BitVec.ofNat 64 j)

/-- Open (checkable): the leading `arg`s. Each reads an argument register of the convention
(the decoder takes `xmm4`–`xmm7` on PE too) and no two read the same register (`arg_store`
may clobber the register it stores); no branch target is a leading `arg` (the registers there
would be those of the branch; landing pads are `lpad`s, `pad_not_leadArg`, and loop heads are
targets). The decoder could reject each (the backend stores each incoming register once,
before any code that branches). -/
structure ArgsOk (S : Setup) : Prop where
  conv : ∀ j r, LeadArg S j → ArgRegAt S j r → ArgRet.IsArg S.c.mode.pe r
  distinct : ∀ j k r, j < k → LeadArg S k → ArgRegAt S j r → ¬ ArgRegAt S k r
  untargeted : ∀ k (hk : k < S.r.protos.size), ∀ t ∈ S.r.protos[k].targets, ∀ j,
    posOf S.r j = t → ¬ LeadArg S j

/-- Open: an `arg`'s destination is private after the scopes (`arg_step` keeps `RRel`; with a
private destination memory is unchanged, so `MemRel` and `FrameSep` are kept), like
`LoadPrivate`. A check could discharge it: no `Escape` before the leading run covers an `arg`'s
slot (then by induction, escaped objects come only from the scopes). -/
def ArgPrivate (S : Setup) : Prop :=
  ∀ (s : R.RState) (x : X86.State) (s1 : R.RState) (op : Reduced.Opcode) (d : BitVec 32)
    (w : BitVec 64) (f : Full.Opcode) (a : ArgReg), FrameInv S s x →
    S.c.d.insns[s.pc]? = some (.native op [.slot d, .imm w]) →
    op.full = some f → f.info.shape = .arg → ArgReg.of? w.toNat true = some a →
    (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 →
    ∀ i < a.size, s1.st.escapedAt (d.toInt + i) = none

/-- Open: a call's result slots are private after the scopes (`Call.call_return`'s
`ResultApart`: with `SepAcross.call`'s allocation facts, `FrameOwn` then puts them in no live
allocation), like `LoadPrivate`. A check could discharge it with the scopes (no `Escape` covers
a call's result slot while it is live). -/
def ResultPrivate (S : Setup) : Prop :=
  ∀ (s : R.RState) (x : X86.State) (s1 : R.RState) (op : Reduced.Opcode) (d : BitVec 32)
    (fo : R.Opnd Nat) (k : BitVec 64) (ws : List (BitVec 32)) (f : Full.Opcode), FrameInv S s x →
    S.c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]) →
    op.full = some f → f.info.shape = .call →
    (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 →
    ∀ parts, R.retRegs k.toNat false = .ok parts → ∀ q ∈ parts, ∀ i < q.1.size,
      s1.st.escapedAt (d.toInt + q.1.off + i) = none

/-- Open: the frame's link slots `[linkLo, 16)` are private after the scopes and in no `Lend`
extent (so no callee, handler or template may write them: `FrameOwn` puts private window bytes
in no live allocation; `FrameFacts` is kept). A check could discharge it: no `Escape` or `Lend`
scope covers the link slots (then by induction, escaped objects come only from the scopes). -/
def LinkPrivate (S : Setup) : Prop :=
  ∀ s x s1, FrameInv S s x → (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 →
    ∀ o : Int, S.linkLo ≤ o → o < 16 →
      s1.st.escapedAt o = none ∧ ∀ l ∈ S.c.lendsAt s.pc, ¬ (l.1 ≤ o ∧ o < l.1 + l.2)

/-- Open: the frame-offset facts `FrameBounds` lacks: a handler call's frame writes lie in the
window (`FrameBounds.writes` covers the native instructions only), and so does a call's result
slot (as `FrameBounds.ret`'s). To join `FrameBounds` once `DecodeLink/Bounds.lean` derives it
(the decoder reads the offsets; a bound check like `FrameBounds`' discharges them). -/
structure MoreBounds (S : Setup) : Prop where
  handler : ∀ (k : Nat) (h : Full.Opcode) (args : List R.Arg) (t : R.Then Nat) (vals : Operands),
    S.c.d.insns[k]? = some (.handler h args t) →
    R.unpack S.c.ρ h S.c.mode.fpArg args = some vals → WrIn (-(S.F : Int)) S.K h vals
  result : ∀ (k : Nat) (op : Reduced.Opcode) (d : BitVec 32) (fo : R.Opnd Nat) (kk : BitVec 64)
    (ws : List (BitVec 32)) (f : Full.Opcode),
    S.c.d.insns[k]? = some (.native op [.slot d, fo, .imm kk, .words ws]) →
    op.full = some f → f.info.shape = .call → -(S.F : Int) ≤ d.toInt ∧ d.toInt + 16 ≤ S.K

/-- Open (image): the callees' stack argument areas (`Code.stackSize`, from the image's
`FuncEntry`s) fit: below `2^62` with the frame (`call_sound`'s `hb`; `tail_call_step`'s `hn`
follows), and on PE a call's holds the 32-byte shadow space. The image checks (§C4) could
discharge it against the frame size. -/
structure StackSizes (S : Setup) : Prop where
  stack : ∀ k, S.F + S.c.stackSize k < 2 ^ 62
  shadow : S.c.mode.pe = true → ∀ (k : Nat) (op : Reduced.Opcode) (ops : List (R.Opnd Nat))
    (f : Full.Opcode), S.c.d.insns[k]? = some (.native op ops) →
    op.full = some f → f.info.shape = .call → 32 ≤ S.c.stackSize k

/-- Open (checkable): every relocated field lies within the code (the decoder doesn't check
it; the image checks of the relocations, §C4, or the decoder could). -/
def RelocsIn (S : Setup) : Prop := ∀ r ∈ S.rs.toList, r.pos + 4 ≤ S.body.code.size

/-- What `decode_sound` assumes (see the module comment): the trusted contracts, facts proved
outside the default build, the frame-pointer restriction, and the open prerequisites. -/
structure Hyps (S : Setup) : Prop where
  -- Trusted: the environment's contracts and the link map.
  handler : Handler.HandlerContract S.ctx S.c.ρ S.c.mode.fpArg S.Owned S.lo (fun _ => S.E.ret)
  resume : ResumeContract S
  call : CallContract S.ctx S.c.mode.pe S.Owned S.lo S.padOf S.Safe (RetAt S.E) (UnwAt S.E)
  island : IslandContract S.ctx S.c.mode.pe S.Owned S.lo S.padOf S.Safe (RetAt S.E) (UnwAt S.E)
  trip : TripContract S.Owned S.lo S.E.ret
  linked : Handler.Linked S.ctx S.c.ρ
  globals : ∃ st0 x0, Globals S.ctx S.c.ρ st0 x0
  -- Proved in `RyoProofs` (outside the default build): `opFacts`, `inlineOps_ok`.
  opFacts : ∀ h, Shapes.OpFacts h
  inlineOk : ∀ f cls, (f, cls) ∈ inlineOps → Step.InlineOk f cls
  -- The restriction: the frame-pointer form (no step lemmas without it yet).
  fp : S.c.mode.framePointer = true
  /-- The window holds the incoming area. -/
  argSizeK : (16 + S.c.argSize : Int) ≤ S.K
  -- Open prerequisites: the decoded code (checkable).
  frameBounds : FrameBounds S.c S.K
  moreBounds : MoreBounds S
  relocsIn : RelocsIn S
  argsOk : ArgsOk S
  -- Open prerequisites: privacy of frame bytes after the scopes.
  loadPrivate : LoadPrivate S
  argPrivate : ArgPrivate S
  resultPrivate : ResultPrivate S
  linkPrivate : LinkPrivate S
  -- Open prerequisites: the environment and the layout.
  sepAcross : SepAcross S
  envApart : EnvApart S
  stackSizes : StackSizes S
  codeApart : CodeApart S
  envOutside : EnvOutside S
  -- Open prerequisites: the decoder's and linker's facts not yet exposed.
  deadStore : DeadStoreSim S
  cacheCleared : CacheCleared S
  padsLinked : PadsLinked S
  stubsLinked : StubsLinked S

/-! ## 4. Per instruction -/

/-! ### Decoded branches are canonical -/


/-! ### Decoded branches are canonical -/

/-- A short branch's target fits its `rel8` at `pos`. -/
def BrFits (pos : Nat) : Item → Prop
  | .branch _ t false => fitsSigned 8 (t - (BitVec.ofNat 32 pos + 2)) = true
  | _ => True

theorem br_fits_sext8 (p : Nat) (b : UInt8) :
    fitsSigned 8 (BitVec.ofNat 32 (p + 2) + sext8 b - (BitVec.ofNat 32 p + 2)) = true := by
  have e : BitVec.ofNat 32 (p + 2) + sext8 b - (BitVec.ofNat 32 p + 2) = sext8 b := by
    rw [BitVec.ofNat_add]; bv_omega
  rw [e]
  unfold sext8 fitsSigned
  generalize BitVec.ofNat 8 b.toNat = v
  simp only [beq_iff_eq]
  bv_decide

theorem br_baseNoRex_brOk {c : Cursor} {op : UInt8} {i : Item}
    (h : Cursor.baseCandidate.baseNoRex c op = some i) : BrFits c.pos i := by
  unfold Cursor.baseCandidate.baseNoRex at h
  simp only [bind, pure] at h
  repeat' (first
    | (simp only [Option.bind_eq_some_iff, Option.bind_none, Option.bind_some, Option.some.injEq,
        reduceCtorEq, Functor.map, Option.map_eq_some_iff, exists_const] at h)
    | (split at h) | (obtain ⟨_, _, h⟩ := h))
  all_goals first | trivial | exact br_fits_sext8 _ _

theorem br_winPiece_brOk {c : Cursor} {i : Item} (h : c.winPiece = some i) : BrFits c.pos i := by
  unfold Cursor.winPiece at h
  repeat' (first | (simp only [Option.some.injEq, reduceCtorEq] at h) | (split at h))
  all_goals (subst h; trivial)

set_option maxHeartbeats 10000000 in
theorem br_baseCandidate_brOk {c : Cursor} {i : Item} (h : c.baseCandidate = some i) :
    BrFits c.pos i := by
  unfold Cursor.baseCandidate at h
  simp only [bind, pure] at h
  repeat' (first
    | (simp only [Option.bind_eq_some_iff, Option.bind_none, Option.bind_some, Option.some.injEq,
        reduceCtorEq, Functor.map, Option.map_eq_some_iff, exists_const] at h)
    | (split at h) | (obtain ⟨_, _, h⟩ := h))
  all_goals first | trivial | exact br_winPiece_brOk ‹_› | exact br_baseNoRex_brOk ‹_›

theorem br_nativeCandidate_brOk {c : Cursor} {i : Item} (h : c.nativeCandidate = some i) :
    BrFits c.pos i := by
  suffices hs : OptAll (BrFits c.pos) c.nativeCandidate from hs i h
  unfold Cursor.nativeCandidate
  extract_lets g mem reg rmReg immAt dq byteW post body
  have hpost : ∀ it, BrFits c.pos it → OptAll (BrFits c.pos) (post it) := by
    intro it hit
    unfold post
    split <;> (try split) <;> first | exact optAll_none | exact optAll_some hit
  have hbody : ∀ x, OptAll (BrFits c.pos) (body x) := by
    intro x
    unfold body
    split
    apply optAll_bind; intro op
    dsimp -zeta -zetaDelta only
    extract_lets i1 modrm dqw
    clear_value g mem reg rmReg immAt dq byteW modrm
    split
    all_goals
      repeat' (first
        | exact optAll_none
        | exact optAll_some trivial
        | (apply optAll_bind_item _ hpost)
        | refine optAll_bind fun _ => ?_
        | split)
  clear_value body
  repeat' (first
    | exact optAll_none
    | exact hbody _
    | refine optAll_bind fun _ => ?_
    | split)

theorem br_decodeItem_brOk {c : Cursor} {i : Item} {n : Nat} (hsp : c.spFrame = none)
    (h : decodeItem c = some (i, n)) : BrFits c.pos i := by
  have hacc : ∀ (post : Item → Option Item) (k : Item), c.accept post k = some (i, n) →
      post k = some i := by
    intro post k ha
    unfold Cursor.accept at ha
    split at ha
    · rename_i hp; cases ha; exact hp
    · cases ha
  unfold decodeItem at h
  rcases Option.orElse_some' h with h | h
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    cases hacc _ _ h
    exact br_baseCandidate_brOk hk
  rcases Option.orElse_some' h with h | h
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    obtain ⟨s, z, x, m, rfl, -⟩ := sseCandidate_ok hk
    rcases fromSpFrame_cases (hacc _ _ h) with ⟨f, m', hf, -⟩ | ⟨rfl, -⟩
    · rw [hsp] at hf; cases hf
    · trivial
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    rcases fromSpFrame_cases (hacc _ _ h) with ⟨f, m', hf, -⟩ | ⟨rfl, -⟩
    · rw [hsp] at hf; cases hf
    · exact br_nativeCandidate_brOk hk

/-- A branch `decodeItem` reads at `p` (frame-pointer form) is canonical there. -/
theorem branch_canonical {c : Cursor} {p n : Nat} {cond : Cond} {t : BitVec 32} {l : Bool}
    (hsp : c.spFrame = none) (h : decodeItem (atPos c p) = some (.branch cond t l, n)) :
    (Item.branch cond t l).Canonical p := by
  have hb := br_decodeItem_brOk (c := atPos c p) hsp h
  unfold Item.Canonical
  refine ⟨fun b e he => (nomatch he), Or.inl ?_⟩
  cases l
  · simpa [Item.wf, BrFits] using hb
  · simp [Item.wf]

/-! ### Relocation boundaries along the iterations -/

theorem bs_linkOk_at {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) (p : Nat) : LinkOk ctx m (atPos c p) rs :=
  ⟨hk.fields, hk.sorted, hk.loaded, hk.small, hk.fp⟩

theorem bs_forIn_len {α γ : Type} (f : α → Array γ → DM (ForInStep (Array γ)))
    (hstep : ∀ a b c r c', (f a b).run c = .ok (r, c') → ∃ b', r = .yield b' ∧ b'.size = b.size + 1) :
    ∀ (l : List α) (init : Array γ) (c c' : Cursor) (b : Array γ),
      (forIn l init f).run c = .ok (b, c') → b.size = init.size + l.length
  | [], init, c, c', b, h => by
    simp only [List.forIn_nil] at h
    obtain ⟨rfl, rfl⟩ := pure_ok h
    simp
  | a :: l, init, c, c', b, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, c1, h1, h2⟩ := bind_ok h
    obtain ⟨b', rfl, hs⟩ := hstep a init c r c1 h1
    have := bs_forIn_len f hstep l b' c1 c' b h2
    simp only [List.length_cons]; omega

/-- `table n` reads `n` entries. -/
theorem bs_table_len {n : Nat} {c c' : Cursor} {ts : List Nat}
    (h : (table n).run c = .ok (ts, c')) : ts.length = n := by
  unfold table at h
  obtain ⟨at_, c1, h1, h⟩ := bind_ok h
  obtain ⟨rfl, hc1⟩ := pos_run' h1
  subst c1
  obtain ⟨x, c2, h2, h⟩ := bind_ok h
  split at h
  case h_2 => exact (err_ok h).elim
  rename_i tb
  obtain ⟨c3, -, -, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
  obtain ⟨c4, -, -, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
  obtain ⟨c5, -, -, h⟩ := check_dec (fun _ _ _ hh => err_ok hh) h
  obtain ⟨u, c6, h6, h⟩ := bind_ok h
  obtain ⟨p, c7, h7, h⟩ := bind_ok h
  obtain ⟨rfl, hc7⟩ := pos_run' h7
  subst c7
  split at h
  · obtain ⟨_, _, h8, -⟩ := bind_ok h; exact (err_ok h8).elim
  dsimp only at h
  obtain ⟨out, c8, h8, h⟩ := bind_ok h
  obtain ⟨rfl, rfl⟩ := pure_ok h
  rw [Std.Legacy.Range.forIn_eq_forIn_range'] at h8
  have := bs_forIn_len _ ?step _ #[] c6 c8 out h8
  case step =>
    intro a b cur r cur' hr
    obtain ⟨e, c9, h9, hr2⟩ := bind_ok hr
    obtain ⟨rfl, rfl⟩ := pure_ok hr2
    exact ⟨_, rfl, by simp⟩
  simpa using this

/-- After a jump table with at least one entry: a boundary (no relocation starts in an entry). -/
theorem bs_table_bound {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) {tb : BitVec 32} {es : List (BitVec 32)} (hne : es ≠ [])
    (h : ∀ i (hi : i < es.length), (atPos c (tb.toNat + 4 * i)).tableEntry tb = some es[i]) :
    Boundary rs (tb.toNat + 4 * es.length) := by
  have hlen : 0 < es.length := List.length_pos_iff.mpr hne
  intro r hr hlt
  by_cases h0 : r.pos < tb.toNat
  · omega
  · exfalso
    let i := (r.pos - tb.toNat) / 4
    have hi : i < es.length := by omega
    have he := h i hi
    have hr0 : (atPos c (tb.toNat + 4 * i)).relocsHere 4 = [] := by
      by_cases h1 : (atPos c (tb.toNat + 4 * i)).relocsHere 4 = []
      · exact h1
      · simp [Cursor.tableEntry, h1] at he
    have hr' : relocsIn rs (tb.toNat + 4 * i) 4 = [] := by
      simpa [Cursor.relocsHere, hk.fields] using hr0
    have := (mem_relocsIn hk.sorted (tb.toNat + 4 * i) 4 r).mpr ⟨hr, by omega, by omega⟩
    rw [hr'] at this; cases this

/-- What `insn` reads ends at a boundary. -/
theorem bs_insn {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Vm.Frame}
    {ro : ByteArray} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (insn fr ro).run c = .ok (q, c')) : Boundary rs c'.pos := by
  cases insn_read h with
  -- The inline dense switch index (inline-forms): not yet covered (lean/PENDING.md).
  | dense _ => sorry
  | handler hd hi hn hhh hs ht =>
    rename_i items hat n len nn op args' t' sites
    have hd' : Dec c c.pos (items ++ [.call (.handler n)]) (hat + len) :=
      hd.append (Dec.single hi)
    obtain ⟨-, -, hb1⟩ := hk.dec hd' hb
    have hk1 := bs_linkOk_at hk (hat + len)
    cases thenSeq_read ht with
    | next _ => exact hb1
    | br _ _ hd2 _ => exact (hk1.dec hd2 hb1).2.2
    | trap _ hd2 _ => exact (hk1.dec hd2 hb1).2.2
    | switch _ htb =>
      have hl := bs_table_len htb
      obtain ⟨tb, pE, es, -, hts, hes, rfl⟩ := table_read htb
      have hne : es ≠ [] := by
        intro he; subst he; simp at hts; subst hts; simp at hl
      exact bs_table_bound hk1 hne hes
  | ret => obtain ⟨_, _, -, -, -, -, hb'⟩ := link_ret hk hb h rfl; exact hb'
  | unreachable => exact (link_unreachable hk hb h rfl).2.2.2.2
  | jmp => obtain ⟨_, _, -, -, -, -, hb'⟩ := link_jmp hk hb h rfl; exact hb'
  | island => obtain ⟨_, _, _, -, -, -, -, -, hb'⟩ := link_island hk hb h rfl; exact hb'

/-- The `NoArg` cursor is the code's cursor at a boundary. -/
theorem bs_noArg {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {fr : Vm.Frame} {p : Nat}
    {a : Bool} {cur : Cursor} (hk : LinkOk ctx m c rs) (hb : Boundary rs p)
    (hn : NoArg fr c p a cur) : cur = atPos c cur.pos ∧ Boundary rs cur.pos := by
  have k0 := bs_linkOk_at hk p
  rcases hn with ⟨-, rfl⟩ | ⟨-, h⟩
  · exact ⟨rfl, hb⟩
  · rcases argInsn_none h with rfl | ⟨x, n, hi, rfl, -⟩
    · exact ⟨rfl, hb⟩
    · refine ⟨rfl, ?_⟩
      exact (decodeItem_itemAt k0.fields k0.sorted k0.loaded k0.small k0.fp hb hi).2.2.2

theorem bs_protoRead {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {fr : Vm.Frame}
    {ro : ByteArray} {p : Nat} {cache cache' : Cache} {dr dr' : List DroppedStore} {a : Bool}
    {q : Proto} {c' : Cursor} (hk : LinkOk ctx m c rs) (hb : Boundary rs p)
    (h : ProtoRead fr ro true c p cache dr a q c' cache' dr') : Boundary rs c'.pos := by
  cases h with
  | arg hr =>
    obtain ⟨_, _, -, -, -, -, -, -, hb'⟩ := link_arg_exact (bs_linkOk_at hk p) hb hr
    exact hb'
  | call hn hr =>
    obtain ⟨e, hbc⟩ := bs_noArg hk hb hn
    rw [e] at hr hbc
    rcases link_call_ok (bs_linkOk_at hk _) hbc hr with
      ⟨_, _, _, _, _, -, -, -, -, -, hb'⟩ | ⟨_, _, _, -, -, -, -, -, hb'⟩ <;> exact hb'
  | inline hn hc hr =>
    obtain ⟨e, hbc⟩ := bs_noArg hk hb hn
    have e' := callInsn_none hc
    subst e'
    rw [e] at hr hbc
    obtain ⟨-, -, _, _, _, _, -, -, -, -, hx⟩ := link_inline_drop (bs_linkOk_at hk _) hbc hr
    rcases hx with ⟨-, _, -, -, -, hb'⟩ | ⟨_, _, _, -, _, -, -, -, hb'⟩ <;> exact hb'
  | insn hn hc hi hr =>
    obtain ⟨e, hbc⟩ := bs_noArg hk hb hn
    have e' := callInsn_none hc
    have e'' := inlineInsn_none hi
    subst e' e''
    rw [e] at hr hbc
    exact bs_insn (bs_linkOk_at hk _) hbc hr

theorem bs_counter {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {fr : Vm.Frame}
    {p1 p2 : Nat} {counter : Option (Nat × Nat)} (hk : LinkOk ctx m c rs)
    (h : CounterRead fr c p1 counter p2) (hb : Boundary rs p1) : Boundary rs p2 := by
  cases h with
  | none => exact hb
  | check _ hd => exact (hk.dec hd hb).2.2

theorem bs_iter {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {fr : Vm.Frame}
    {ro : ByteArray} {targets : Array Nat} {a : Bool} {p p' : Nat} {cache cache' : Cache}
    {dr dr' : List DroppedStore} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs p)
    (h : Iter fr ro (some targets) c a p cache dr q p' cache' dr') : Boundary rs p' := by
  cases h with
  | empty hd hr =>
    obtain ⟨-, -, _, _, _, _, -, -, -, -, hx⟩ := link_inline_drop (bs_linkOk_at hk _) hb hr
    rcases hx with ⟨-, _, -, -, -, hb'⟩ | ⟨_, _, _, -, _, -, -, -, hb'⟩ <;> exact hb'
  | main hpad hctr hpr =>
    obtain ⟨-, -, -, -, hb1⟩ := padRead_codeAt hk hpad hb
    exact bs_protoRead hk (bs_counter hk hctr hb1) hpr
/-! ### R steps that never stop with `noBehavior` -/

set_option maxRecDepth 100000 in
theorem ofFull_jmp {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull .jmp = some op) : op.full = some .jmp := by
  have e : (Reduced.Opcode.ofFull .jmp).bind Reduced.Opcode.full = some .jmp := by rfl
  rw [h] at e; exact e

set_option maxRecDepth 100000 in
theorem ofFull_unreachable {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull .unreachable = some op) : op.full = some .unreachable := by
  have e : (Reduced.Opcode.ofFull .unreachable).bind Reduced.Opcode.full = some .unreachable := by rfl
  rw [h] at e; exact e

/-- R errors that are not `noBehavior`. -/
def NoNB {α : Type} (m : M α) : Prop := ∀ msg, m ≠ .error (.noBehavior msg)

theorem noNB_bind {α β : Type} {m : M α} {f : α → M β} (h : NoNB m)
    (hf : ∀ a, m = .ok a → NoNB (f a)) : NoNB (m >>= f) := by
  intro msg he
  cases hm : m with
  | error e => rw [hm] at he; cases he; exact h msg hm
  | ok a => rw [hm] at he; exact hf a hm msg he

theorem noNB_pure {α : Type} (a : α) : NoNB (pure a : M α) := by
  intro msg h; cases h

theorem noNB_ill {α : Type} (s : String) : NoNB (illFormed s : M α) := by
  intro msg h; cases h

theorem noNB_ub {α : Type} (s : String) : NoNB (ub s : M α) := by
  intro msg h; cases h

theorem noNB_mapM {α β : Type} (f : α → M β) (hf : ∀ a, NoNB (f a)) :
    ∀ l : List α, NoNB (l.mapM f)
  | [] => by intro msg h; cases h
  | a :: l => by
    rw [List.mapM_cons]
    refine noNB_bind (hf a) fun b _ => noNB_bind (noNB_mapM f hf l)
      fun bs _ => noNB_pure _

theorem noNB_foldlM {α β : Type} (f : β → α → M β) (hf : ∀ b a, NoNB (f b a)) :
    ∀ (l : List α) (b : β), NoNB (l.foldlM f b)
  | [], b => by intro msg h; cases h
  | a :: l, b => by
    rw [List.foldlM_cons]
    exact noNB_bind (hf b a) fun b' _ => noNB_foldlM f hf l b'

theorem noNB_byteAt (st : OpSem.State) (o : Int) : NoNB (st.byteAt o) := by
  intro msg h
  unfold OpSem.State.byteAt at h
  repeat' split at h
  all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h

theorem noNB_readFrame (st : OpSem.State) (o : Int) (n : Nat) :
    NoNB (st.readFrame o n) :=
  noNB_mapM _ (fun _ => noNB_byteAt _ _) _

theorem noNB_writeFrame (st : OpSem.State) (o : Int) (bs : List AbstractByte) :
    NoNB (st.writeFrame o bs) := by
  unfold OpSem.State.writeFrame
  refine noNB_bind ?_ fun _ _ => noNB_pure _
  unfold OpSem.State.writeEscaped
  refine noNB_foldlM _ (fun mem bi => ?_) _ _
  intro msg h
  repeat' split at h
  all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h

theorem noNB_applyScope (s : R.RState) (sc : R.Scope) :
    NoNB (R.applyScope s sc) := by
  unfold R.applyScope
  split
  · unfold R.escape
    intro msg h
    have hr := noNB_readFrame s.st
    simp only [NoNB] at hr
    simp only [R.frameAddr, bind, Except.bind, pure, Except.pure] at h
    repeat' split at h
    all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h | skip
    all_goals (repeat' split at *) <;> simp_all [illFormed, throw, throwThe, MonadExceptOf.throw]
  · unfold R.storageEnd
    refine noNB_bind (noNB_writeFrame _ _ _) fun _ _ => noNB_pure _
  · exact noNB_pure _

theorem noNB_scopes (l : List R.Scope) (s : R.RState) :
    NoNB (l.foldlM R.applyScope s) :=
  noNB_foldlM _ noNB_applyScope l s

theorem step_scopes_err {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {i : Insn}
    {e : Stop} (hi : c.d.insns[s.pc]? = some i)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .error e) : R.step c s ch = .error e := by
  unfold R.step
  simp [hi, hsc, bind, Except.bind]

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

theorem posOf_eq {r : ReadResult} {k : Nat} (hk : k < r.protos.size) :
    posOf r k = r.protos[k].pos := by
  simp [posOf, hk]

/-! ### Facts derived from the decoder and the relation -/

/-- A landing pad is an `lpad` (`sorry`: `read` rejects a cleanup pad whose proto isn't an
`lpad`, "landing pad isn't an lpad"; `reducedOf`'s `cleanup` is `read`'s `actions`). -/
theorem pad_lpad (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k pad : Nat}
    {cat : Bool} (h : S.c.cleanupAt k = some (some pad, cat)) :
    ∃ hp : pad < S.r.protos.size, S.r.protos[pad].op = .lpad := by
  sorry  -- TODO(wip): pad_lpad

/-- A landing pad is not a leading `arg`: it is an `lpad`. -/
theorem pad_not_leadArg (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k pad : Nat} {cat : Bool} (h : S.c.cleanupAt k = some (some pad, cat)) : ¬ LeadArg S pad := by
  rintro ⟨-, ha⟩
  obtain ⟨hp, hop⟩ := pad_lpad hD h
  have e := hD.argsSucc pad (by simpa using hp)
  simp only [Array.getElem_toList, hop] at e
  have hne : (Full.Opcode.lpad == Full.Opcode.arg) = false := by decide
  rw [hne, Bool.and_false, ha] at e
  exact Bool.noConfusion e

/-- Every proto lies within the code (`sorry`: each iteration starts at a position the
decoder's cursor reached, `instructions_read`, at most the code's size). -/
theorem posOf_le_size (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k : Nat}
    (hk : k < S.r.protos.size) : posOf S.r k ≤ S.body.code.size := by
  sorry  -- TODO(wip): posOf_le_size

/-- Proto positions fit 32 bits (the code does, `LinkOk.small`). -/
theorem posOf_lt_32 (hD : Decodes S code relocs rodata callSites dropped scopes mode) {m : Mem}
    (hL : LinkOk S.ctx m S.body S.rs) {k : Nat} (hk : k < S.r.protos.size) : posOf S.r k < 2 ^ 32 :=
  Nat.lt_of_le_of_lt (posOf_le_size hD hk) hL.small

/-- PE frames hold the saved `rsi`/`rdi` (`sorry`: `read` makes the frame size `alloc + 16` on
PE; `reducedOf_frameSize`). -/
theorem frameSize_pe (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hpe : S.c.mode.pe = true) : 16 ≤ S.F := by
  sorry  -- TODO(wip): frameSize_pe

/-- At a boundary, `fp` is the entry's `rsp - 8` (`FrameFacts.rbp`). -/
theorem FrameInv.fpAddr_eq {s : R.RState} {x : X86.State} (h : FrameInv S s x) (o : Int) :
    fpAddr x o = S.winAddr o := by
  have h1 := h.frame.rbp
  have e : x.reg .rbp = S.x0.rsp - 8 := by bv_omega
  simp only [fpAddr, Setup.winAddr, e]

/-- `FrameInv` sees only the registers, the `xmm` registers and memory. -/
theorem FrameInv.congr {s : R.RState} {x y : X86.State} (h : FrameInv S s x)
    (hr : y.regs = x.regs) (hx : y.xmm = x.xmm) (hm : y.mem = x.mem) : FrameInv S s y := by
  have hrsp : y.rsp = x.rsp := by simp [State.rsp, State.reg, hr]
  have hrbp : y.reg .rbp = x.reg .rbp := by simp [State.reg, hr]
  obtain ⟨⟨hrel, hb, hwf⟩, hmem, hsep, hwin, hfpF, hsp, hroom, hcode, hro, hargs, hfr⟩ := h
  refine ⟨⟨Shapes.rel_congr hr hm hrel, hrbp.trans hb, hwf⟩, Shapes.memRel_congr hm hmem,
    hsep.congr hrbp, hwin, hfpF, by rw [hrsp, hrbp]; exact hsp, by rw [hrsp]; exact hroom,
    by rw [hm]; exact hcode, by rw [hm]; exact hro,
    fun ha r hr' hfr => (hargs ha r hr' hfr).congr (fun i _ => by rw [hr]) (fun i _ => by rw [hx]),
    ?_⟩
  obtain ⟨f1, f2, f3, f4, f5⟩ := hfr
  refine ⟨by rw [hrbp]; exact f1, by rw [hrbp, hm]; exact f2, by rw [hrbp, hm]; exact f3,
    fun hpe => by rw [hrbp, hm]; exact f4 hpe, fun i hi h5 => by rw [hr]; exact f5 i hi h5⟩

/-- What a body lemma knows of proto `k`, read at `p` as `q` ending at `c'` with cache `cache'`:
the proto (`q` with the iteration's position and counter), its R instruction, the relocation
boundary at `p`, and where the next iteration starts. -/
structure ProtoFacts (S : Setup) (k p : Nat) (q : Proto) (c' : Cursor) (cache' : Cache) : Prop where
  lt : k < S.r.protos.size
  proto : ∃ p1 counter, S.r.protos[k]? = some { q with pos := p1, counter }
  insn : ∃ i, S.c.d.insns[k]? = some i ∧ ∀ hk : k < S.r.protos.size,
    InsnOf (posOf S.r) S.r.protos[k] i
  bound : Boundary S.rs p
  stop : S.start (k + 1) = c'.pos
  cache : S.cache (k + 1) = cache'
  args : S.args (k + 1) = (S.args k && q.op == .arg)

theorem protoFacts_insnOf {k p : Nat} {q : Proto} {c' : Cursor} {cache' : Cache}
    (hP : ProtoFacts S k p q c' cache') :
    ∃ i p1 counter, S.c.d.insns[k]? = some i ∧
      InsnOf (posOf S.r) { q with pos := p1, counter } i ∧
      ∃ hk : k < S.r.protos.size, S.r.protos[k] = { q with pos := p1, counter } := by
  obtain ⟨hlt, ⟨p1, ctr, hpq⟩, ⟨i, hi, hio⟩, -⟩ := hP
  have hpk : S.r.protos[k] = { q with pos := p1, counter := ctr } := by
    rw [Array.getElem?_eq_some_iff] at hpq
    exact hpq.2
  exact ⟨i, p1, ctr, hi, hpk ▸ hio hlt, hlt, hpk⟩

/-- A bare `unreachable` (`Shapes.unreachable_step`: R's step is an error, excluded by
`RSafe`). -/
theorem bodySim_unreachable (_hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (_H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' {}) (_hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .unreachable) :
    BodySim S k p (S.used k) := by
  intro s x hs _ _ _ hsafe
  exfalso
  obtain ⟨i, p1, ctr, hi, hio, -⟩ := protoFacts_insnOf hP
  cases hr with
  -- The inline dense switch index (inline-forms): not yet covered (lean/PENDING.md).
  | dense _ => sorry
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | jmp => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | unreachable _ =>
    simp only [InsnOf] at hio
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio
    have hops' : ops = [] := List.map_eq_nil_iff.mp hops
    subst hops'
    have hf := ofFull_unreachable hof
    rw [← hs] at hi
    cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
    | error e =>
      obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
      exact noNB_scopes _ _ m hsc
    | ok s1 =>
      obtain ⟨m, hm⟩ := hsafe.1 {} _ (Shapes.unreachable_step S.ctx (x := x) (ch := {}) hi hf hsc).2
      cases hm
/-! #### The other shapes' bodies (`sorry` but `jmp`'s: `DSWork/*.lean`) -/

/-- `arg d, r` (`ArgRet.arg_step`/`FrameBounds.arg_step_fb` with `DecodeLink.link_arg_exact`):
the register is live (`ArgsLive`, by `ArgsOk.conv`/`distinct`), the others stay so
(`argClobbers` holds no other argument register), the destination private (`ArgPrivate`). -/
theorem bodySim_arg (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {q : Proto} {c' : Cursor} (ha : S.args k = true)
    (hP : ProtoFacts S k p q c' (S.used k))
    (hr : (argInsn S.fr.mode).run (atPos S.body p) = .ok (some q, c')) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_arg

/-- A call or tail call (`Call.call_sound`, `call_unwind`, `tail_call_step` with
`DecodeLink.link_call_ok`; the pad by `PadsLinked`, `posOf_lt_32`, `pad_not_leadArg`). -/
theorem bodySim_call (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' {}) (hn : NoArg S.fr S.body p a cur)
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
    (hP : ProtoFacts S k p q c' {}) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hh : q.handler ≠ none) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_handler

/-- `ret` (`ArgRet.ret_step`, `DecodeLink.link_ret`): the function's end. -/
theorem bodySim_ret (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' {}) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .ret) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_ret

set_option maxRecDepth 100000 in
/-- `jmp t` (`Shapes.jmp_step`, `DecodeLink.link_jmp`, `branch_canonical`; the target isn't a
leading `arg`, `ArgsOk.untargeted`). -/
theorem bodySim_jmp (_hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' {}) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .jmp) :
    BodySim S k p (S.used k) := by
  intro s x hs hf hrip _ hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFacts_insnOf hP
  have hb := hP.bound
  cases hr with
  -- The inline dense switch index (inline-forms): not yet covered (lean/PENDING.md).
  | dense _ => sorry
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | @jmp t long len hd =>
    obtain ⟨hca, -, -⟩ := hf.code.dec (Dec.single hd) hb
    simp only [InsnOf] at hio
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio
    obtain ⟨t', rfl, ht'⟩ : ∃ t', ops = [.target t'] ∧ posOf S.r t' = t.toNat := by
      match ops, hops with
      | [o], h =>
        cases o <;> simp [opndMap] at h
        exact ⟨_, rfl, h⟩
      | [], h => simp at h
      | _ :: _ :: _, h => simp at h
    have hf' := ofFull_jmp hof
    have hik := hi
    rw [← hs] at hi
    cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
    | error e =>
      exfalso
      obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
      exact noNB_scopes _ _ m hsc
    | ok s1 =>
      have hsh : Full.Opcode.jmp.info.shape = .jmp := by decide
      have hstep : R.step S.c s {} = .ok (.step { s1 with pc := t' }) := by
        unfold R.step
        simp only [hi, hsc, hf', bind, Except.bind]
        rw [hsh]
        rfl
      obtain ⟨x', hx, hr', hm', hpc, hrip', hregs, hmem⟩ :=
        Shapes.jmp_step S.ctx (tgt := t) (long := long) (fun n => BitVec.ofNat 32 (posOf S.r n))
          (by simp [ht']) hi hf' hsh hf.rrel hf.mem (H.frameBounds.scope_size _) hstep
      have hex : (Item.branch .always t long).exec S.ctx x = .ok x' := by
        rw [Inline.execItems_cons] at hx
        obtain ⟨y, hy, hn⟩ := except_bind_ok hx
        cases hn; exact hy
      have hxmm : x'.xmm = x.xmm := by
        simp [Item.exec, Cond.eval, bind, Except.bind, pure, Except.pure] at hex
        subst hex; rfl
      have hsp : (atPos S.body p).spFrame = none := hf.code.fp
      refine .step (.exec _ p (branch_canonical hsp hd) hca.1 hrip hex) (.done (.inl ⟨_, .step hstep, ?_⟩))
      have hk := scopes_keeps _ hsc
      have hf0 := hf.congr hregs hxmm hmem
      have hsep := (sep_foldlM _ (H.frameBounds.scopesIn s.pc) (H.frameBounds.window hf.win)
        hf.rrel hf.sep hsc).2
      have hrbp : x'.reg .rbp = x.reg .rbp := by simp [State.reg, hregs]
      refine ⟨⟨hr', hm', hsep.congr hrbp, hk.fp ▸ hf.win, hk.fp ▸ hf.fpF, hf0.rsp, hf0.room,
        hf0.code, hf0.ro, fun ha => ?_, hf0.frame⟩, .inr ⟨?_, ?_⟩⟩
      · exact absurd ha (H.argsOk.untargeted k hlt t.toNat
          (by rw [hpk]; simp [Proto.targets, Opnd.targetsOf]) t' ht')
      · show x'.rip = addrAt S.ctx (posOf S.r t')
        rw [hrip', ht']
        simp only [addrAt, BitVec.ofNat_toNat]
        congr 1
      · show CacheInv (S.used t') x'
        have hc := H.cacheCleared.targets k hlt t.toNat (by
          rw [hpk]; simp [Proto.targets, Opnd.targetsOf])
        simp only [Setup.used, ht', hc, ↓reduceIte]
        exact CacheInv.empty x'

/-- `island isl, ops` (`Island.island_sound`, `island_unwind`, with `DecodeLink.link_island`
and `opsAt_of_opsArray`). -/
theorem bodySim_island (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' {}) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .island) :
    BodySim S k p (S.used k) := by
  sorry  -- TODO(wip): bodySim_island

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
    -- The inline dense switch index (inline-forms): not yet covered (lean/PENDING.md).
    | dense _ => sorry

/-! #### The iteration's prologue: padding and the counter check -/

theorem nop_canonical {n : Nat} (h : 1 ≤ n ∧ n ≤ 9) (p : Nat) : (Item.nop n).Canonical p := by
  unfold Item.Canonical
  refine ⟨fun b e he => (nomatch he), Or.inl ?_⟩
  simp [Item.wf, h.1, h.2]

/-- The padding's `nop`s from `p`: fetched, they leave everything but `rip`. -/
theorem reach_padding {Q : X86.State → Prop} :
    ∀ {ns : List Nat} {p : Nat} {x : X86.State}, (∀ n ∈ ns, 1 ≤ n ∧ n ≤ 9) →
      CodeAt S.ctx x.mem (ns.map Item.nop) p → x.rip = addrAt S.ctx p →
      (∀ y : X86.State, y.regs = x.regs → y.xmm = x.xmm → y.mem = x.mem →
        y.rip = addrAt S.ctx (p + codeSize (ns.map Item.nop)) → Reach S.ctx S.E Q y) →
      Reach S.ctx S.E Q x
  | [], p, x, _, _, hrip, k => k x rfl rfl rfl (by simp [hrip, codeSize])
  | n :: ns, p, x, hns, hc, hrip, k => by
    have hn := hns n (by simp)
    let y := x.jump (x.rip + BitVec.ofNat 64 (Item.nop n).size)
    have hy : (Item.nop n).exec S.ctx x = .ok y := rfl
    have hyr : y.rip = addrAt S.ctx (p + (Item.nop n).size) := by
      show x.rip + _ = _
      rw [hrip, addrAt_add]
    refine .step (.exec (.nop n) p (nop_canonical hn p) hc.1 hrip hy) ?_
    refine reach_padding (fun m hm => hns m (by simp [hm])) hc.2 hyr fun z h1 h2 h3 h4 => ?_
    refine k z h1 h2 h3 ?_
    rw [h4]
    simp only [List.map_cons, codeSize_cons, Nat.add_assoc]

/-- The counter check of a loop head from `p1` to `p2` (`Counter.counter_noop` under the trip
contract, the stub from `StubsLinked`, the record's layout from `EnvApart`): fetched, it reaches
`p2` with the frame relation kept (a loop head is a branch target, so not a leading `arg`:
the trip clobbers the caller-saved registers) and the cache (cleared at a loop head) holding. -/
theorem reach_counter (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p1 p2 stub : Nat} (hk : k < S.r.protos.size)
    (hq : S.r.protos[k].counter = some (stub, p2))
    (hctr : CounterRead S.fr S.body p1 (some (stub, p2)) p2) (hb : Boundary S.rs p1)
    {Q : X86.State → Prop} {s : R.RState} {x : X86.State} (hs : s.pc = k)
    (hf : FrameInv S s x) (hrip : x.rip = addrAt S.ctx p1) (hci : CacheInv (S.used k) x)
    (kont : ∀ y, FrameInv S s y → y.rip = addrAt S.ctx p2 → CacheInv (S.used k) y →
      Reach S.ctx S.E Q y) :
    Reach S.ctx S.E Q x := by
  sorry  -- TODO(wip): reach_counter

/-- Every iteration starts at a relocation boundary, given the code linked in some memory
(`LinkOk`: sorted relocations, which the decoder doesn't check): the prologue ends at one
(`Decodes.prologue`), and each iteration's links give the boundary after what it read
(`bs_iter`). -/
theorem boundary_start (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {m : Mem} (hL : LinkOk S.ctx m S.body S.rs) :
    ∀ k, k ≤ S.r.protos.size → Boundary S.rs (S.start k) := by
  intro k
  induction k with
  | zero =>
    intro _
    rw [hD.start0]
    obtain ⟨items, hd⟩ := hD.prologue H.fp
    exact (hL.dec hd (boundary_zero _)).2.2
  | succ k ih =>
    intro hk
    have hit := hD.iters k (by simp; omega)
    exact bs_iter hL (ih (Nat.le_of_succ_le hk)) hit

/-- Instruction `k` of a main iteration: the padding (from its start), the counter check, then
the body. -/
theorem insnSim_main (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k p1 p2 : Nat} {counter : Option (Nat × Nat)} {q : Proto} {c' : Cursor}
    {cache' : Cache} {dr' : List DroppedStore} (hk : k < S.r.protos.size)
    (hq : S.r.protos[k] = { q with pos := p1, counter })
    (hpad : PadRead S.body (S.start k) p1) (hctr : CounterRead S.fr S.body p1 counter p2)
    (hpr : ProtoRead S.fr S.ro (some S.targets).isSome S.body p2
      (if (some S.targets).any (sortedContains · p1) then {} else S.cache k) (S.dr k) (S.args k)
      q c' cache' dr')
    (hstop : S.start (k + 1) = c'.pos) (hcache : S.cache (k + 1) = cache') :
    InsnSimAt S k := by
  intro s x hs hbi hsafe
  obtain ⟨hf, hat⟩ := hbi
  have hp1 : posOf S.r k = p1 := by rw [posOf_eq hk, hq]
  have hpr : ProtoRead S.fr S.ro true S.body p2 (S.used k) (S.dr k) (S.args k) q c' cache' dr' := by
    have e : (if (some S.targets).any (sortedContains · p1) then ({} : Cache) else S.cache k) =
        S.used k := by simp [Setup.used, hp1, Option.any]
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
    bodySim_of_read hD H ⟨hk, ⟨p1, counter, by simp [hk, hq]⟩, hinsn, hb2, hstop, hcache, hargs⟩ hpr
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
    · exact CacheInv.empty y
    · exact hcy
  · rw [hs, hp1] at hrip
    rw [hs] at hci
    exact from_p1 x hf hrip hci

/-- An instruction index outside the code: R's step is `illFormed`, excluded by `RSafe`. -/
theorem insnSim_oob (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : S.r.protos.size ≤ k) : InsnSimAt S k := by
  intro s x hs _ hsafe
  have hsz := (reducedOf_insns hD.reduced).1
  have hnone : S.c.d.insns[s.pc]? = none := by
    simp only [Array.getElem?_eq_none_iff]; omega
  obtain ⟨m, hm⟩ := hsafe.1 {} _ (by simp [R.step, hnone, illFormed]; rfl)
  cases hm

end Insn

/-! ## 5. `decode_sound` -/

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
    | main hpad hctr hpr =>
      rw [← hdr] at hpr
      exact insnSim_main hD H hk hpk hpad hctr hpr hst1 hca1 s x rfl hbi hsafe
  · exact insnSim_oob hD (Nat.le_of_not_lt hk) s x rfl hbi hsafe

/-- `decode_sound` from the decoder's acceptance directly. -/
theorem decode_sound_of_ok {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (hdec : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d)
    (c : R.Code) (hc : c.d = d) (hm : c.mode = mode) (ctx : Ctx) (E : Env) (K : Int)
    (x0 : X86.State) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop) :
    ∃ S : Setup, Decodes S code relocs rodata callSites dropped scopes mode ∧ S.c = c ∧
      S.ctx = ctx ∧ S.E = E ∧ S.K = K ∧ S.x0 = x0 ∧ S.Owned = Owned ∧ S.lo = lo ∧
      S.padOf = padOf ∧ S.Safe = Safe ∧
      (Hyps S → ∀ s x, BInv S s x → SafeFrom Safe c s → FnSim ctx E c (BInv S) (ExitRel S) s x) := by
  obtain ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h8, h9⟩ :=
    decodes_of_ok hdec c hc hm ctx E K x0 Owned lo padOf Safe
  refine ⟨S, hD, h1, h2, h3, h4, h5, h6, h7, h8, h9, fun H => ?_⟩
  subst h1 h2 h3 h9
  exact decode_sound hD H

end Ryo.Proofs.DecodeSound
