/-
Ryo.Spec.Mir.External — the environment: calls to functions outside the program (mir-spec §A.6).

Ports: none (MiniRust programs are closed). Takes over MiniRust's `Allocate`/`Deallocate`,
`PrintStdout`/`PrintStderr`, `Exit` and `Abort` intrinsics as shims of the corresponding
external symbols (D21: the heap is `__rust_alloc` & co.).

A call to an instance without a body is an external call event (`Event.extCall`) with the
callee's symbol, the argument values and the result. Relationally, the environment may do
anything an `ExtSpec` allows (see `Ryo.Spec.Mir.Behavior`); the interpreter implements these
shims and treats any other symbol as ill-formed (not runnable):
- `__rust_alloc`, `__rust_alloc_zeroed`, `__rust_dealloc`, `__rust_realloc`: `heap`
  allocations (D21; `GlobalAlloc`'s preconditions are UB);
- `write(fd, buf, len)`: records the bytes, returns `len`;
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

-- [D21] [D18]
/-- Run an external function. -/
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
      let .ptr np ← heapAlloc newSize al.bytes false | throwIllFormed "realloc"
      memUpdate (·.store np.thin (bytes.take newSize.toNat) .one)
      memUpdate (·.deallocate old .heap oldSize al)
      pure (.ret (.ptr np))
    | "write", [_, buf, len] => do
      let n := (← argInt len).toNat
      let _ ← liftE ((← getMem).load (← argPtr buf) n .one)
      pure (.ret (.int n))
    | "exit", [c] => do
      emit (.extCall sym args (.ret unitValue))
      throw (.exit (← argInt c))
    | "abort", [] => do
      emit (.extCall sym args (.ret unitValue))
      throw .abort
    | "_Unwind_RaiseException", [p] => do pure (.unwind (← argPtr p))
    | "ryo_test_print", _ => pure (.ret unitValue)
    | _, _ => throwIllFormed s!"call to unknown external function `{sym}`"
  emit (.extCall sym args res)
  pure res

end Ryo.Spec.Sem
