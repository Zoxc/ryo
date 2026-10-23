/-
Ryo.Spec.Mir.State — the abstract machine state and the semantics monad.

Ports: MiniRust `lang/machine.md` (`Machine`, `StackFrame`, `StackPopAction`, `Thread`,
`fn_from_ptr`, `vtable_from_ptr`, `compute_size`, `compute_align`).

Differences:
- D17: one thread; no thread list, locks, data-race tracking.
- `Cont` replaces `StackPopAction`: besides "back to the caller" (with the caller's
  `target`/`unwind` and the in-place argument places to de-initialize, D12), it covers the
  frames the semantics creates itself: `terminate` (D18, calls of the `panic_cannot_unwind` /
  `panic_in_cleanup` lang items) and `catchTry`/`catchHandler` (the `catch_unwind` intrinsic).
- D18: a frame running cleanup blocks remembers the payload (`unwinding`); there is no payload
  stack (`StartUnwind`/`StopUnwind` do not exist in MIR).
- D12: `aliased` locals live in the caller's memory (in-place `Move` arguments, the return
  place) and are not deallocated by the callee.
- D14: `callerLocation`, the hidden argument of `#[track_caller]` bodies.
- D6, D7: function addresses and constant allocations are instantiated on demand; the copies
  are remembered so that later choices can reuse them.
- Events (external calls) are recorded for traces (`Ryo.Spec.Mir.Behavior`).

`SemM` is the semantics monad: exceptions are outcomes (the state survives an exception, so
traces up to UB are kept), and the oracle answers choices (`MonadChoice`). It is mir-spec's
`ExecM`; quantifying over the oracle gives the relational semantics (mir-spec §A.4).
-/
import Ryo.Spec.Mir.Syntax
import Ryo.Spec.Lang.Representation
import Ryo.Spec.Mem.IntPtrCast
import Std.Data.TreeMap

namespace Ryo.Spec

/-- An unwinding payload: the exception object pointer (cg_llvm's landing pad value). -/
abbrev Payload := ThinPointer

/-- What happens when a frame returns or unwinds. -/
inductive Cont where
  /-- The bottom of the stack: the run ends. -/
  | bottom
  /-- Back to the caller: continue at `target` (UB if `none`) or apply `unwind`, after
  de-initializing the in-place argument places (D12). -/
  | caller (target : Option BasicBlock) (unwind : UnwindAction) (deinit : List (ThinPointer × Size))
  /-- A terminate handler (D18): returning or unwinding aborts. -/
  | terminate
  /-- The `try` call of `catch_unwind(try, data, catch)`: returning writes 0 to `dest`,
  unwinding calls `catch(data, payload)`. -/
  | catchTry (data catchFn : Value) (dest : Place) (destTy : Ty) (target : Option BasicBlock)
      (unwind : UnwindAction)
  /-- The `catch` call of `catch_unwind`: returning writes 1 to `dest`. -/
  | catchHandler (dest : Place) (destTy : Ty) (target : Option BasicBlock) (unwind : UnwindAction)
deriving Repr, Inhabited

structure Frame where
  inst : InstanceId
  body : Body
  /-- Storage of the live locals. -/
  locals : Array (Option ThinPointer)
  /-- Locals whose storage is the caller's (D12). -/
  aliased : List Local := []
  bb : BasicBlock := 0
  stmt : Nat := 0
  cont : Cont
  /-- D14: the caller location of a `#[track_caller]` body. -/
  callerLocation : Option Value := none
  /-- D18: the payload while cleanup blocks run. -/
  unwinding : Option Payload := none
  /-- D18: set when a callee unwound into this frame with `UnwindAction::Continue`: the next
  step unwinds out of this frame too. -/
  pendingUnwind : Option Payload := none
deriving Repr, Inhabited

/-- Result of an external call. -/
inductive ExtResult where
  | ret (v : Value)
  | unwind (p : Payload)
deriving Repr, DecidableEq, Inhabited

/-- Observable events. -/
inductive Event where
  /-- An external call (mir-spec §A.6): callee symbol, arguments, result. -/
  | extCall (callee : String) (args : List Value) (result : ExtResult)
  /-- `write(fd, buf, len)`: the bytes written (mir-spec §A.6). -/
  | write (fd : Int) (bytes : List UInt8)
deriving Repr, DecidableEq, Inhabited

/-- How a run ended normally. -/
inductive Final where
  | returned (v : Value)
  | unwound (p : Payload)
deriving Repr, DecidableEq, Inhabited

structure State where
  prog : Program
  mem : Memory := {}
  intptr : IntPtrCast := {}
  /-- The call stack; the head is the active frame. -/
  stack : List Frame := []
  /-- The unique allocation of each static / thread local, by `GlobalId`. -/
  statics : Array (Option ThinPointer) := #[]
  /-- Existing copies of each constant / vtable allocation (D7, D29). -/
  constCopies : Array (List ThinPointer) := #[]
  /-- Existing addresses of each function (D6). -/
  fnCopies : Array (List ThinPointer) := #[]
  /-- Which instance a function allocation belongs to. -/
  fnAllocs : Std.TreeMap AllocId InstanceId := {}
  events : Array Event := #[]
  /-- Number of choices made so far (lets oracles depend on the history). -/
  choiceCount : Nat := 0
  final : Option Final := none
  /-- D25: the deepest stack the run may build; deeper calls overflow. -/
  maxDepth : Nat := 10000

/-- An oracle answers choice number `n`, given the state. -/
structure Oracle where
  answer : Nat → (c : Choice) → State → c.Answer

abbrev SemM := ExceptT Outcome (StateT State (ReaderT Oracle Id))

instance : MonadChoice SemM where
  choose c := do
    let o ← read
    let s ← get
    set { s with choiceCount := s.choiceCount + 1 }
    pure (o.answer s.choiceCount c s)

namespace SemM

def liftE {α : Type} (e : Except Outcome α) : SemM α :=
  match e with
  | .ok a => pure a
  | .error o => throw o

def getMem : SemM Memory := do pure (← get).mem
def setMem (m : Memory) : SemM Unit := modify fun s => { s with mem := m }

/-- Run a memory operation that returns a new memory. -/
def memUpdate (f : Memory → Except Outcome Memory) : SemM Unit := do
  setMem (← liftE (f (← getMem)))

def prog : SemM Program := do pure (← get).prog

def curFrame : SemM Frame := do
  match (← get).stack with
  | f :: _ => pure f
  | [] => throwIllFormed "no active frame"

def setCurFrame (f : Frame) : SemM Unit := do
  match (← get).stack with
  | _ :: rest => modify fun s => { s with stack := f :: rest }
  | [] => throwIllFormed "no active frame"

def modifyCurFrame (g : Frame → Frame) : SemM Unit := do setCurFrame (g (← curFrame))

def jumpTo (bb : BasicBlock) : SemM Unit := modifyCurFrame fun f => { f with bb, stmt := 0 }

def emit (e : Event) : SemM Unit := modify fun s => { s with events := s.events.push e }

def localTy (f : Frame) (l : Local) : SemM Ty :=
  match f.body.locals[l]? with
  | some t => pure t
  | none => throwIllFormed s!"local _{l} out of range"

end SemM

end Ryo.Spec
