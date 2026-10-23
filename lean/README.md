# ryo-lean: verifying ryo in Lean 4

The Lean side of ryo's verification. So far it holds milestone M1: L0, an executable semantics of the runtime MIR ryo compiles,
built on MiniRust's semantic core ([github.com/minirust/minirust](https://github.com/minirust/minirust),
commit `d821c6e3`) with rustc/LLVM behavior where they differ (divergences D1–D36,
[docs/mir-spec.md](docs/mir-spec.md) §A.7).

The MIR spec's design is [docs/mir-spec.md](docs/mir-spec.md).

## Build and test

```
lake build                         # library Ryo + exe ryo-lean (Lean 4.35.0, core + Std only)
lake test                          # runs the ported MiniRust tests and divergence tests
lake exe ryotest <substring>       # only the tests whose name contains <substring>
lake exe ryo-lean example factorial fact.json
lake exe ryo-lean run fact.json    # interpret a JSON program (`Program` or `{program, args}`)
```

`.lake/` is ignored (`.gitignore`).

## Layout

```
lakefile.toml, lean-toolchain      Lean 4.35.0, no dependencies
Main.lean                          exe `ryo-lean`: `run <program.json>`, `example <name>`
Ryo.lean                           imports the spec and the examples
Ryo/Spec.lean                      imports every spec module
Ryo/Spec/Prelude/                  Basic (Size, Align, IntType, FloatTy), Target (x86-64),
                                   Outcome, Nondet (Choice, MonadChoice)
Ryo/Spec/Mem/                      Pointer, AbstractByte, Basic (memory), IntPtrCast, Refine
Ryo/Spec/Lang/                     Float (exact IEEE arithmetic), Types (rustc layouts),
                                   Values, Representation (encode/decode, check_value,
                                   typed load/store, enum tags), WellFormed
Ryo/Spec/Mir/                      Syntax (MIR AST), WellFormed (static checks), State
                                   (machine, SemM), Place, Operand (constants, globals,
                                   fn addresses), Ops, Cast, Rvalue, Statement, Call, Unwind,
                                   External (shims), Intrinsics, Terminator, Step, Interp
                                   (concrete oracle, run loop), Behavior (behaviors,
                                   refinement), Builder (DSL), Json
Ryo/Spec/Theorems/Representation.lean   representation laws (proved parts + open goals)
Ryo/Examples.lean                  example programs for `ryo-lean example`
RyoTest/*.lean, RyoTest.lean       tests; RyoTestMain.lean is the test driver (exe `ryotest`)
docs/                              design documents
```

Each module's header names the MiniRust file it ports and the divergences it applies; the
code cites them inline as `-- [Dn]` at the definitions concerned, and cites sections of
`docs/mir-spec.md` as `mir-spec §A.n`.

## How it works

- The semantics is written in `SemM := ExceptT Outcome (StateT State (ReaderT Oracle Id))`.
  Every non-deterministic choice (allocation addresses, exposed provenance, NaN payloads,
  constant copies, function addresses, `ptr_guaranteed_cmp`) is a `Choice` asked through
  `MonadChoice`; the semantics checks each answer (`noBehavior` when a daemonic answer breaks
  its constraint).
- `Interp.lean`'s `concreteOracle` makes it an interpreter (bump allocator, Miri-like exposed
  provenance, canonical NaN, first copies); `Behavior.lean` quantifies over oracles to get the
  set of behaviors and states `Refines` (with the D25 stack-overflow allowance).
- Floats are exact: operations compute the exact rational result and round to nearest-even
  (`Lang/Float.lean`), cross-checked against hardware `Float`/`Float32` in the tests.
- External calls are events; the interpreter has shims for `__rust_alloc` & co., `write`,
  `exit`, `abort`, `_Unwind_RaiseException` (starts unwinding) and `ryo_test_print`.

## Status

M1 is done: `lake build` succeeds with `sorry` only in `Ryo/Spec/Theorems` (the open
representation theorems, listed there), and `lake test` passes.
