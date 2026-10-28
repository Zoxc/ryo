/-
Ryo.Proofs.DecodeSound.Basic — the definitions of `decode_sound` (`Ryo/Proofs/DecodeSound.lean`,
whose module comment describes them) and its proved lemmas that the per-shape files build on:
the simulation (§1), the relation and `Decodes` (§2), the hypotheses `Hyps` (§3), and the
per-instruction helpers (§4: canonical branches, relocation boundaries, `noBehavior`-free
steps, `ProtoFacts`, `bodySim_unreachable`, `bodySim_jmp`, `reach_padding`, `boundary_start`,
`insnSim_oob`). The decoder facts are in `DSWork/Boundary.lean`, the other shapes' bodies in
`DSWork/*.lean`, the composition in `DecodeSound.lean`.
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
def Indexed (fr : Vm.Frame) (ro : ByteArray) (targets : Option (Array Nat))
    (callSites : Array CallSite) (c : Cursor)
    (protos : List Proto) (start : Nat → Nat) (cache : Nat → Cache)
    (dr : Nat → List DroppedStore) (args : Nat → Bool) : Prop :=
  ∀ k (hk : k < protos.length), Iter fr ro targets callSites c (args k) (start k) (cache k) (dr k)
    protos[k] (start (k + 1)) (cache (k + 1)) (dr (k + 1))

/-- `Iters` as indexed iterations, from the chain's start to its end. -/
theorem iters_indexed {fr : Vm.Frame} {ro : ByteArray} {targets : Option (Array Nat)}
    {callSites : Array CallSite} {c : Cursor} :
    ∀ {a : Bool} {p : Nat} {cache : Cache} {dr : List DroppedStore} {qs : List Proto} {pe : Nat}
      {dre : List DroppedStore}, Iters fr ro targets callSites c a p cache dr qs pe dre →
    ∃ (start : Nat → Nat) (ca : Nat → Cache) (drs : Nat → List DroppedStore) (args : Nat → Bool),
      start 0 = p ∧ ca 0 = cache ∧ drs 0 = dr ∧ args 0 = a ∧ start qs.length = pe ∧
      drs qs.length = dre ∧
      (∀ k (hk : k < qs.length), args (k + 1) = (args k && qs[k].op == .arg)) ∧
      Indexed fr ro targets callSites c qs start ca drs args := by
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
  /-- The call sites (the LSDA's): PE's `nop` after a call with a landing pad. -/
  callSites : Array CallSite
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

def fr : Vm.Frame := ⟨S.r.frameSize, S.c.mode, false⟩

/-- The cache the decoder used at proto `k`'s position: cleared at a branch target. -/
def used (k : Nat) : Cache :=
  if sortedContains S.targets (posOf S.r k) then { pe := S.c.mode.pe } else S.cache k

/-- Where proto `k`'s iteration ends: the next one's start. -/
def stop (k : Nat) : Nat := S.start (k + 1)

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
return address above it and the caller's `rbp` saved below; the other callee-saved registers
(`Saved`: on PE also `rsi`, `rdi`, which the function's code doesn't change) as at entry. -/
structure FrameFacts (S : Setup) (x : X86.State) : Prop where
  rbp : x.reg .rbp + 16 = S.x0.rsp + 8
  retAddr : x.mem.read64 (x.reg .rbp + 8) = S.x0.mem.read64 S.x0.rsp
  savedRbp : x.mem.read64 (x.reg .rbp) = S.x0.reg .rbp
  saved : ∀ i, Saved S.c.mode.pe i → i ≠ 5 → x.regs i = S.x0.regs i

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
  reduced : reducedOf S.r mode.pe = .ok S.c.d
  modeEq : S.c.mode = mode
  rsEq : S.rs = relocs
  roEq : S.ro = rodata
  callSitesEq : S.callSites = callSites
  /-- No pad region (PE's cleanup code after the body, run by the exception dispatcher on its
  own stack): not covered. -/
  noRegion : regionPad mode callSites = none
  bodyEq : S.body = bodyCursor { code := code.data, pos := 0, fields := .relocs relocs } mode
    S.r.frameSize S.body.pos
  run : ∃ stub padded c1, (instructions S.fr rodata dropped.toList (some S.targets) stub
    S.body.code.size callSites).run S.body = .ok ((S.r.protos, padded), c1)
  start0 : S.start 0 = S.body.pos
  cache0 : S.cache 0 = { pe := mode.pe }
  dr0 : S.dr 0 = dropped.toList
  args0 : S.args 0 = true
  argsSucc : ∀ k (hk : k < S.r.protos.toList.length),
    S.args (k + 1) = (S.args k && S.r.protos.toList[k].op == .arg)
  iters : Indexed S.fr S.ro (some S.targets) S.callSites S.body S.r.protos.toList S.start S.cache
    S.dr S.args
  /-- The prologue (the entry's counter check, the frame's `prologue`) is read item by item from
  0 to the body's start (frame-pointer form: the body cursor is the code's). -/
  prologue : S.c.mode.framePointer = true → ∃ items, Dec S.body 0 items S.body.pos

theorem reducedOf_frameSize {r : ReadResult} {pe : Bool} {d : Decoded} (h : reducedOf r pe = .ok d) :
    d.frameSize = r.frameSize := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

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
    R.unpack S.c.ρ h S.c.mode args = some vals → Handler.AtHandler S.ctx h x →
    Handler.ArgsIn S.c.ρ S.c.mode.pe x x args → Handler.HRel st x → Handler.NoUB h vals st →
    S.E.ret x x' →
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
      Call.Landed S.c.mode.pe S.padOf (x.rsp + 8) x x' exc ∧
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
  pads : ∀ k pad cat, S.c.cleanupAt k = some (some pad, cat) → S.used pad = { pe := S.c.mode.pe }

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
  ∀ args off x x', R.unpack S.c.ρ .resume S.c.mode args = some [.slot off] →
    Handler.AtHandler S.ctx .resume x → Handler.ArgsIn S.c.ρ S.c.mode.pe x x args → S.E.ret x x' →
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

/-- Open: the frame's link slots `[0, 16)` are private after the scopes and in no `Lend`
extent (so no callee, handler or template may write them: `FrameOwn` puts private window bytes
in no live allocation; `FrameFacts` is kept). A check could discharge it: no `Escape` or `Lend`
scope covers the link slots (then by induction, escaped objects come only from the scopes). -/
def LinkPrivate (S : Setup) : Prop :=
  ∀ s x s1, FrameInv S s x → (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 →
    ∀ o : Int, 0 ≤ o → o < 16 →
      s1.st.escapedAt o = none ∧ ∀ l ∈ S.c.lendsAt s.pc, ¬ (l.1 ≤ o ∧ o < l.1 + l.2)

/-- Open: the frame-offset facts `FrameBounds` lacks: a handler call's frame writes lie in the
window (`FrameBounds.writes` covers the native instructions only), and so does a call's result
slot (as `FrameBounds.ret`'s). To join `FrameBounds` once `DecodeLink/Bounds.lean` derives it
(the decoder reads the offsets; a bound check like `FrameBounds`' discharges them). -/
structure MoreBounds (S : Setup) : Prop where
  handler : ∀ (k : Nat) (h : Full.Opcode) (args : List R.Arg) (t : R.Then Nat) (vals : Operands),
    S.c.d.insns[k]? = some (.handler h args t) →
    R.unpack S.c.ρ h S.c.mode args = some vals → WrIn (-(S.F : Int)) S.K h vals
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
  handler : Handler.HandlerContract S.ctx S.c.ρ S.c.mode S.Owned S.lo (fun _ => S.E.ret)
  resume : ResumeContract S
  call : CallContract S.ctx S.c.mode.pe S.Owned S.lo S.padOf S.Safe (RetAt S.E) (UnwAt S.E)
  island : IslandContract S.ctx S.c.mode.pe S.Owned S.lo S.padOf S.Safe (RetAt S.E) (UnwAt S.E)
  trip : TripContract S.Owned S.lo S.E.ret
  linked : Handler.Linked S.ctx S.c.ρ
  globals : ∃ st0 x0, Globals S.ctx S.c.ρ st0 x0
  /-- On PE, every return of the environment keeps `rsi` and `rdi` (callee-saved in the Win64
  convention; `TripContract`'s `CalleeSaved` is SysV's): the trip's return after the counter
  check (`reach_counter`). -/
  peSaved : S.c.mode.pe = true → ∀ a b, S.E.ret a b → b.regs 6 = a.regs 6 ∧ b.regs 7 = a.regs 7
  -- Proved in `RyoProofs` (outside the default build): `opFacts`, `inlineOps_ok`.
  opFacts : ∀ h, Shapes.OpFacts h
  inlineOk : ∀ f cls, (f, cls) ∈ inlineOps → Step.InlineOk f cls
  -- The restrictions: the frame-pointer form (no step lemmas without it yet), and handler calls
  -- with their arguments in registers (PE's stack argument, the `atomic.cxchg` handlers', writes
  -- the frame's bottom: its step is open).
  fp : S.c.mode.framePointer = true
  regArgs : ∀ (k : Nat) (h : Full.Opcode) (args : List R.Arg) (t : R.Then Nat),
    S.c.d.insns[k]? = some (.handler h args t) → args.length ≤ (handlerRegs S.c.mode.pe).length
  /-- The window holds the incoming area. -/
  argSizeK : (16 + S.c.argSize : Int) ≤ S.K
  -- Open prerequisites: the decoded code (checkable).
  frameBounds : FrameBounds S.c S.K
  moreBounds : MoreBounds S
  relocsIn : RelocsIn S
  argsOk : ArgsOk S
  /-- On PE the frame size and the return address fit a signed 32-bit displacement, as PE's
  epilogue (`ArgRet.ret_step`, `bodySim_ret`) needs (`FrameBounds.F_le` gives `F ≤ 2 ^ 31`
  only). The decoder could check it. -/
  peFrame : S.c.mode.pe = true → S.F + 8 < 2 ^ 31
  -- Open prerequisites: privacy of frame bytes after the scopes.
  loadPrivate : LoadPrivate S
  argPrivate : ArgPrivate S
  resultPrivate : ResultPrivate S
  linkPrivate : LinkPrivate S
  /-- On PE, an island template's 32-byte shadow space at the frame's bottom, `[-F, -F + 32)`,
  lies below the link slots (`32 ≤ F`) and holds no initialized private byte after the scopes
  (the frame separation with the lower bound `-F + 32`; `bodySim_island`). A check could
  discharge it with the scopes (no private slot in the shadow space). -/
  peShadow : S.c.mode.pe = true → 32 ≤ S.F ∧ ∀ s x s1, FrameInv S s x →
    (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1 → FrameSep (-(S.F : Int) + 32) S.K s1.st x
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

set_option maxHeartbeats 10000000 in
theorem br_baseCandidate_brOk {c : Cursor} {i : Item} (h : c.baseCandidate = some i) :
    BrFits c.pos i := by
  unfold Cursor.baseCandidate at h
  simp only [bind, pure] at h
  repeat' (first
    | (simp only [Option.bind_eq_some_iff, Option.bind_none, Option.bind_some, Option.some.injEq,
        reduceCtorEq, Functor.map, Option.map_eq_some_iff, exists_const] at h)
    | (split at h) | (obtain ⟨_, _, h⟩ := h))
  all_goals first | trivial  | exact br_baseNoRex_brOk ‹_›

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
    rcases fromSpFrame_cases (hacc _ _ h) with ⟨f, m', hf, -⟩ | ⟨rfl, -⟩ | ⟨rfl, hs, -⟩
    · rw [hsp] at hf; cases hf
    · trivial
    · trivial
  · obtain ⟨k, hk, h⟩ := Option.bind_eq_some_iff.mp h
    rcases fromSpFrame_cases (hacc _ _ h) with ⟨f, m', hf, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -, -⟩
    · rw [hsp] at hf; cases hf
    · exact br_nativeCandidate_brOk hk
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
  | dense hds =>
    -- The index computation up to the table (`denseScan`), then the table from its `lea`.
    unfold denseSwitch at hds
    obtain ⟨x, c1, h1, h2⟩ := bind_ok hds
    obtain ⟨rfl, rfl⟩ := get_run h1
    split at h2
    · obtain ⟨_, c2, hs, h3⟩ := bind_ok h2
      rw [run_setPos] at hs
      cases hs
      obtain ⟨ts, c3, htb, h4⟩ := bind_ok h3
      split at h4
      · obtain ⟨-, rfl⟩ := pure_ok h4
        have hl := bs_table_len htb
        obtain ⟨tb, pE, es, -, hts, hes, rfl⟩ := table_read htb
        have hne : es ≠ [] := by
          intro he; subst he; simp at hts; subst hts; simp at hl
        exact bs_table_bound (bs_linkOk_at hk _) hne hes
      · exact (err_ok h4).elim
    · cases (pure_ok h2).1
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
  | resume _ h1 h2 => exact (hk.dec (.cons h1 (Dec.single h2)) hb).2.2

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

/-- After PE's `nop` after a call (no relocation starts in it): a boundary. -/
theorem bs_nop {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {fr : Vm.Frame}
    {callSites : Array CallSite} {q : Proto} {p p' : Nat} (hk : LinkOk ctx m c rs)
    (h : NopRead fr callSites c q p p') (hb : Boundary rs p) : Boundary rs p' := by
  cases h with
  | none _ => exact hb
  | nop _ _ hr =>
    intro r hr0 hlt
    by_cases h0 : r.pos < p
    · exact Nat.le_trans (hb r hr0 h0) (Nat.le_succ _)
    · exfalso
      have hr' : relocsIn rs p 1 = [] := by simpa [Cursor.relocsHere, hk.fields] using hr
      have := (mem_relocsIn hk.sorted p 1 r).mpr ⟨hr0, by omega, by omega⟩
      rw [hr'] at this; cases this

theorem bs_iter {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} {fr : Vm.Frame}
    {ro : ByteArray} {targets : Array Nat} {callSites : Array CallSite} {a : Bool} {p p' : Nat}
    {cache cache' : Cache} {dr dr' : List DroppedStore} {q : Proto} (hk : LinkOk ctx m c rs)
    (hb : Boundary rs p)
    (h : Iter fr ro (some targets) callSites c a p cache dr q p' cache' dr') : Boundary rs p' := by
  cases h with
  | empty hd hr =>
    obtain ⟨-, -, _, _, _, _, -, -, -, -, hx⟩ := link_inline_drop (bs_linkOk_at hk _) hb hr
    rcases hx with ⟨-, _, -, -, -, hb'⟩ | ⟨_, _, _, -, _, -, -, -, hb'⟩ <;> exact hb'
  | main hpad hctr hpr hnop =>
    obtain ⟨-, -, -, -, hb1⟩ := padRead_codeAt hk hpad hb
    exact bs_nop hk hnop (bs_protoRead hk (bs_counter hk hctr hb1) hpr)

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
  obtain ⟨f1, f2, f3, f5⟩ := hfr
  refine ⟨by rw [hrbp]; exact f1, by rw [hrbp, hm]; exact f2, by rw [hrbp, hm]; exact f3,
    fun i hi h5 => by rw [hr]; exact f5 i hi h5⟩

/-- What a body lemma knows of proto `k`, read at `p` as `q` ending at `c'` with cache `cache'`:
the proto (`q` with the iteration's position and counter), its R instruction, the relocation
boundary at `p`, and where the next iteration starts (after PE's `nop` after a call with a
landing pad, `NopRead`). -/
structure ProtoFacts (S : Setup) (k p : Nat) (q : Proto) (c' : Cursor) (cache' : Cache) : Prop where
  lt : k < S.r.protos.size
  proto : ∃ p1 counter, S.r.protos[k]? = some { q with pos := p1, counter }
  insn : ∃ i, S.c.d.insns[k]? = some i ∧ ∀ hk : k < S.r.protos.size,
    InsnOf (posOf S.r) S.r.protos[k] i
  bound : Boundary S.rs p
  nop : NopRead S.fr S.callSites S.body q c'.pos (S.start (k + 1))
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
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (_hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .unreachable) :
    BodySim S k p (S.used k) := by
  intro s x hs _ _ _ hsafe
  exfalso
  obtain ⟨i, p1, ctr, hi, hio, -⟩ := protoFacts_insnOf hP
  cases hr with
  | dense hds =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hds
    rw [hw] at hop
    cases w <;> exact absurd hop (by decide)
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | jmp => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
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

set_option maxRecDepth 100000 in
/-- `jmp t` (`Shapes.jmp_step`, `DecodeLink.link_jmp`, `branch_canonical`; the target isn't a
leading `arg`, `ArgsOk.untargeted`). -/
theorem bodySim_jmp (_hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .jmp) :
    BodySim S k p (S.used k) := by
  intro s x hs hf hrip _ hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFacts_insnOf hP
  have hb := hP.bound
  cases hr with
  | dense hds =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hds
    rw [hw] at hop
    cases w <;> exact absurd hop (by decide)
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
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
        exact CacheInv.emptyPe _ x'

/-! #### The iteration's padding, the boundaries, instructions outside the code -/

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

end Ryo.Proofs.DecodeSound
