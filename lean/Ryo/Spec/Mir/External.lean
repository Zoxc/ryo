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
- `ryo_test_print(..)`: records its arguments, returns `()` (tests);
- `__rust_no_alloc_shim_is_unstable_v2()`: a no-op.
Symbols of `#[rustc_std_internal_symbol]` items are matched by their unmangled name
(`internalName`), and the shims see integer and pointer arguments through single-field structs
and fieldless enums (`scalarOf`: std passes `Alignment` and `NonNull<u8>`).
-/
import Ryo.Spec.Mir.Unwind

namespace Ryo.Spec.Sem

open SemM

/-- The scalar a value carries through ABI-transparent wrappers (std's allocator shims take
`NonNull<u8>` and `Alignment`, a struct around a fieldless `repr(usize)` enum): structs with
one non-1-ZST field, and fieldless enums as their discriminant. -/
def scalarOf : Nat → Value → Ty → Option Value
  | 0, _, _ => none
  | fuel + 1, .tuple vs, .tuple fields _ none =>
    match (vs.zip fields).filter (fun (_, (_, t)) => !t.is1Zst) with
    | [(v, (_, t))] => scalarOf fuel v t
    | _ => none
  | _, .variant i (.tuple []), .enum vs .. => vs[i]?.map (fun var => .int var.discr)
  | _, v, _ => some v

def argInt (a : Value × Ty) : SemM Int :=
  match scalarOf 16 a.1 a.2 with
  | some (.int i) => pure i
  | _ => throwIllFormed "external call: expected an integer argument"

def argPtr (a : Value × Ty) : SemM ThinPointer :=
  match scalarOf 16 a.1 a.2 with
  | some (.ptr p) => pure p.thin
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

/-- The name of a `#[rustc_std_internal_symbol]` item: rustc mangles it as
`__rustc::<name>` (v0: `_R...7___rustc<len>[_]<name>...`, `mangle_internal_symbol`), e.g.
`_RNvCs5fGHjzWXRav_7___rustc12___rust_alloc` for `__rust_alloc`: the identifier's decimal
length, a `_` separator if the identifier starts with `_` or a digit, then the identifier.
Other symbols are unchanged. -/
def internalName (sym : String) : String :=
  match sym.splitOn "7___rustc" with
  | [pre, rest] =>
    if !pre.startsWith "_R" then sym else
    let cs := rest.toList
    let digits := cs.takeWhile Char.isDigit
    let n := (String.ofList digits).toNat!
    let cs := cs.drop digits.length
    let cs := match cs with
      | '_' :: c :: t => if c == '_' || c.isDigit then c :: t else '_' :: c :: t
      | _ => cs
    if digits.isEmpty || cs.length < n then sym else String.ofList (cs.take n)
  | _ => sym

-- [D21] [D18]
/-- Run an external function: a shim, or the environment. Arguments come with their types,
so that the shims can see through ABI-transparent wrappers (`scalarOf`). -/
def callExternal (sym : String) (targs : List (Value × Ty)) : SemM ExtResult := do
  let sym := internalName sym
  let args := targs.map (·.1)
  let res ← match sym, targs with
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
    -- the allocator shim's marker that std's allocator is linked (`alloc::alloc`): a no-op
    | "__rust_no_alloc_shim_is_unstable_v2", [] => pure (.ret unitValue)
    | _, _ => callEnv sym args
  if sym != "write" then emit (.extCall sym args res)
  pure res

end Ryo.Spec.Sem
