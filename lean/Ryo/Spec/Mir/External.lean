/-
Ryo.Spec.Mir.External — the environment: calls to functions outside the program (mir-spec §A.6).

Ports: none (MiniRust programs are closed). Takes over MiniRust's `Allocate`/`Deallocate`,
`PrintStdout`/`PrintStderr`, `Exit` and `Abort` intrinsics as shims of the corresponding
external symbols (D21: the heap is `__rust_alloc` & co.).

A call to an instance without a body is an external call event (`Event.extCall`) with the
callee's symbol, the argument values and the result. The shims below run their symbols; any
other symbol is run by the oracle's environment (`Oracle.env`, mir-spec §A.6), which sets the
memory and gives the result (`unwind` starts unwinding, as `_Unwind_RaiseException` does); if
it does not run the symbol (the interpreter's `concreteOracle` runs none), the call is
ill-formed (not runnable). `Ryo.Spec.Mir.Behavior` restricts the environment by an `ExtSpec`.
The shims:
- `__rust_alloc`, `__rust_alloc_zeroed`, `__rust_dealloc`, `__rust_realloc`: `heap`
  allocations (D21; `GlobalAlloc`'s preconditions are UB). `realloc` frees the old block
  before allocating the new one, so the (daemonic) new address may equal the old one;
- `write(fd, buf, len)`: records the bytes as an `Event.write` (not as an `extCall`: the
  trace shows the data, not the buffer's address), returns `len`;
- `exit(code)`, `abort()`;
- `_Unwind_RaiseException(exc)`: starts unwinding with payload `exc` (D18: the panic runtime
  is external; tests use this to start unwinding);
- `ryo_test_print(..)`: records its arguments, returns `()` (tests).
-/
import Ryo.Spec.Mir.Unwind

namespace Ryo.Spec.Sem

open SemM

def argInt : Value → SemM Int
  | .int i => pure i
  | _ => throwIllFormed "external call: expected an integer argument"

def argPtr : Value → SemM ThinPointer
  | .ptr p => pure p.thin
  | _ => throwIllFormed "external call: expected a pointer argument"

def heapAlloc (size align : Int) (zeroed : Bool) : SemM Value := do
  let some al := Align.ofBytes? align.toNat | throwUb "__rust_alloc: alignment is not a power of two"
  if size ≤ 0 then throwUb "__rust_alloc: zero-sized allocation"
  let (p, mem) ← (← getMem).allocate .heap size.toNat al
  setMem mem
  if zeroed then memUpdate (·.store p (List.replicate size.toNat (.init 0 none)) .one)
  pure (.ptr p.widen)

/-- Ask the oracle's environment to run `sym` (mir-spec §A.6); counted with the choices. -/
def callEnv (sym : String) (args : List Value) : SemM ExtResult := do
  let s ← get
  let some (m', r) := (← read).env s.choiceCount sym args s
    | throwIllFormed s!"call to unknown external function `{sym}`"
  set { s with mem := m', choiceCount := s.choiceCount + 1 }
  pure r

-- [D21] [D18]
/-- Run an external function: a shim, or the environment. -/
def callExternal (sym : String) (args : List Value) : SemM ExtResult := do
  let res ← match sym, args with
    | "__rust_alloc", [s, a] => do pure (.ret (← heapAlloc (← argInt s) (← argInt a) false))
    | "__rust_alloc_zeroed", [s, a] => do pure (.ret (← heapAlloc (← argInt s) (← argInt a) true))
    | "__rust_dealloc", [p, s, a] => do
      let some al := Align.ofBytes? (← argInt a).toNat | throwUb "__rust_dealloc: bad alignment"
      memUpdate (·.deallocate (← argPtr p) .heap (← argInt s).toNat al)
      pure (.ret unitValue)
    | "__rust_realloc", [p, os, a, ns] => do
      let old ← argPtr p
      let oldSize := (← argInt os).toNat
      let newSize ← argInt ns
      let some al := Align.ofBytes? (← argInt a).toNat | throwUb "__rust_realloc: bad alignment"
      let bytes ← liftE ((← getMem).load old oldSize al)
      -- free first, so that the new block may start at the old address (growing in place)
      memUpdate (·.deallocate old .heap oldSize al)
      let .ptr np ← heapAlloc newSize al.bytes false | throwIllFormed "realloc"
      memUpdate (·.store np.thin (bytes.take newSize.toNat) .one)
      pure (.ret (.ptr np))
    | "write", [fd, buf, len] => do
      let n := (← argInt len).toNat
      let bytes ← liftE ((← getMem).load (← argPtr buf) n .one)
      -- as Miri: the bytes must be initialized; their provenance is dropped
      let some data := bytes.mapM (·.data) | throwUb "write: uninitialized bytes"
      emit (.write (← argInt fd) data)
      pure (.ret (.int n))
    | "exit", [c] => do
      emit (.extCall sym args (.ret unitValue))
      throw (.exit (← argInt c))
    | "abort", [] => do
      emit (.extCall sym args (.ret unitValue))
      throw .abort
    | "_Unwind_RaiseException", [p] => do pure (.unwind (← argPtr p))
    | "ryo_test_print", _ => pure (.ret unitValue)
    | _, _ => callEnv sym args
  if sym != "write" then emit (.extCall sym args res)
  pure res

end Ryo.Spec.Sem
