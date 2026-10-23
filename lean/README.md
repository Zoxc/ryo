# ryo-lean: verifying ryo in Lean 4

The Lean side of ryo's verification ([design/verification.md](../design/verification.md)).
So far it holds milestone M1: L0, an executable semantics of the runtime MIR ryo compiles,
built on MiniRust's semantic core ([github.com/minirust/minirust](https://github.com/minirust/minirust),
commit `d821c6e3`) with rustc/LLVM behavior where they differ (divergences D1–D36,
[docs/mir-spec.md](docs/mir-spec.md) §A.7).

The detailed plan is in [docs/](docs/plan.md): the strategy and milestones
([plan.md](docs/plan.md)), the MIR spec ([mir-spec.md](docs/mir-spec.md)), the x86 level
([x86.md](docs/x86.md)), the reduced VM level R ([reduced.md](docs/reduced.md)), the AOT
checks and theorems ([aot.md](docs/aot.md)) and the JIT's validation ([jit.md](docs/jit.md)).

What the Lean code takes on trust is in [docs/assumptions.md](docs/assumptions.md) (`sorry`s,
opaque code, fuel, oracle and environment contracts, the dump as trusted input, semantic
choices, and how to regenerate the list). Where L0 differs from what rustc, LLVM and ryo
actually do is in [docs/divergences.md](docs/divergences.md), and where it differs from
MiniRust (with D1–D36 checked against the code) in
[docs/minirust-divergences.md](docs/minirust-divergences.md).

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
Ryo/Spec/Theorems/                 Bytes (byte-list, slice, pointer-byte lemmas), Representation
                                   (encode_length, decode_encode), Monotone (decode_mono,
                                   encode_decode_le), Memory (store_load)
Ryo/Examples.lean                  example programs for `ryo-lean example`
RyoTest/*.lean, RyoTest.lean       tests; RyoTestMain.lean is the test driver (exe `ryotest`)
docs/                              the detailed plan
```

Each module's header names the MiniRust file it ports and the divergences it applies; the
code cites them inline as `-- [Dn]` at the definitions concerned, and cites sections of
`docs/mir-spec.md` as `mir-spec §A.n`.

## How it works

- The semantics is written in `SemM := ExceptT Outcome (StateT State (ReaderT Oracle Id))`.
  Every non-deterministic choice (allocation addresses, exposed provenance, NaN payloads,
  constant copies, function addresses, `ptr_guaranteed_cmp`, `fmuladd` fusion, the zero of
  `minimum_number_nsz`, `compare_bytes`'s value) is a `Choice` asked through
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

M1 is done: `lake build` succeeds with no `sorry` (the five representation laws
`encode_length`, `decode_encode`, `encode_decode_le`, `decode_mono` and `store_load` are proved in
`Ryo/Spec/Theorems`), and `lake test` passes. What is left of M1 and the later milestones are
in [docs/plan.md](docs/plan.md#3-milestones).
