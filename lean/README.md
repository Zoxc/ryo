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
lake exe ryo-lean run p.json --stdout  # as the program: fd 1/2 bytes to stdout/stderr, its exit status
lake exe ryo-lean decode f.json    # one function's machine code to R (decodeReduced), as text
lake exe ryo-lean decode x.o       # every function of an image object, decoded
../scripts/lean-diff.py [--opt]    # differential runs: tests/lean/*.rs under rustc, ryo and
                                   # ryo-lean on the backend's RYO_DUMP_LEAN dump (./y.sh build first)
lake exe ryo-lean obj x.ryo_image.rcgu.o   # an image object's image: header, symbol slots,
                                   # functions and their code's relocations
lake exe ryo-lean elf x.o          # an ELF object's sections, symbols and relocations
lake exe ryo-lean ehframe x.o      # an object's .eh_frame: CIEs, FDEs and their row tables
lake exe ryo-lean lsda x.ryo_image.rcgu.o  # per image function its FDE and LSDA call sites,
                                   # and whether they are the image's call-site table
../scripts/lean-decode-diff.py [--opt] [--readelf] [--decode] [--unwind] [--frame-pointer]
                                   # the object readers against Rust (scripts/lean-decode-ref)
                                   # and readelf on the corpus's image objects
lake exe ryo-lean check-pool dump.json x.ryo_image.rcgu.o [-v]
                                   # image objects against the RYO_DUMP_LEAN dump: the constant
                                   # pool and vtables, `__ryo_main` (Ryo/Check/Image/{Pool,Dump}.lean)
../scripts/lean-pool-check.py [--opt]  # check-pool on the corpus, tabulated
lake exe ryo-lean check-cert dump.json dump.cert.json x.ryo_image.rcgu.o [-v]
                                   # the lowering certificate (RYO_DUMP_LEAN's <crate>.cert.json)
                                   # against the objects' decoded code and the dump: function
                                   # map, signatures and plans, ranges, calls, islands
                                   # (docs/aot.md §C1, Ryo/Check/Lower/CertCheck.lean)
../scripts/lean-cert-check.py [--opt] [--corpus DIR]  # check-cert on the corpus, tabulated
lake exe ryo-lean check-image x.ryo_image.rcgu.o... [--registry r.ryo_registry.bin.rcgu.o]
                                   # the image checks that need no dump (docs/aot.md §C4) on
                                   # a link's objects: each mismatch, then a summary
../scripts/lean-image-check.py [--opt] [--frame-pointer] [--corpus DIR]
                                   # check-image on the corpus, each program's objects as a link
lake exe ryo-lean rrun x.ryo_image.rcgu.o fib 10   # an image function run as R (Ryo/Vm/R/Run.lean)
lake exe ryo-lean exec-item         # run x86 items on states given as JSON lines (Ryo/X86/Cosim.lean)
lake exe ryo-lean opsem            # opSem on JSON lines (Ryo/Vm/OpSem/Json.lean); from vm/:
                                   # `cargo test -p ryo_rt --test lean_opsem` runs it against
                                   # every handler (skipped without the binary)
cargo run --release --manifest-path harness/Cargo.toml -- [--cases N] [--seed S]
                                   # co-simulation of Item.exec against the CPU (x86-64 Linux;
                                   # lake build first): random items and inline runs
```

`.lake/` is ignored (`.gitignore`).

From the repository root, `./y.sh lean` checks that the generated tables are up to date, then
runs `lake build` and `lake test` here; `./y.sh lean gen` regenerates the tables.
`Ryo/Vm/Generated/*.lean` (opcodes, shapes, operand kinds, the reduced set and its maps to the
full one, `asm::layout`, the handler kinds) are generated from the Rust source by the test
`vm/bytecode/tests/lean_tables.rs`, pinned to `FORMAT_VERSION`; `./y.sh test` runs it, so stale
tables fail it. Don't edit them by hand.

## Layout

```
lakefile.toml, lean-toolchain      Lean 4.35.0, no dependencies
Main.lean                          exe `ryo-lean`: `run <program.json>`, `example <name>`,
                                   `obj <file.o>`, `elf <file.o>`, `decode`, `dead`,
                                   `ehframe <file.o>`, `lsda <file.o>`,
                                   `check-pool <dump.json> <file.o>...`, `check-cert`,
                                   `check-image`,
                                   `exec-item`, `opsem`
Ryo.lean                           imports the spec, the generated tables, the x86 model,
                                   the object readers and the examples
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
Ryo/Vm/Generated/                  generated (`./y.sh lean gen`): Types, Full and Reduced
                                   (opcode lists, `Opcode.<name>` constants, full <-> reduced),
                                   Asm (`asm::layout`, `has_handler`, `has_inline`), Handlers
                                   (handlers.rs: kind, parameters, return type)
Ryo/Obj/                           object readers (docs/aot.md §C3): Elf (ELF64 relocatable
                                   objects: sections, symbols, RELA), Reloc (the decoder's
                                   inputs: Mode, Ref, Reloc, CallSite, Scope, DroppedStore,
                                   FuncInputs and its field classification), Image (locating the
                                   image, `Image::parse`/`validate`, per-function inputs, the
                                   `ryo-lean obj` summary), Lsda (`asm::lsda`'s parse and
                                   write), EhFrame (CIEs, FDEs, row tables), Unwind (each
                                   function's FDE and LSDA)
Ryo/Vm/R/Syntax.lean               R (reduced.md §C0.1): instructions, side data, `Decoded`
                                   and its text (`reduced::Disasm` and the side data)
Ryo/Vm/R/Islands.lean              the island contracts' operand roles (read, only written,
                                   unused) by template and `ops` position (trusted)
Ryo/Vm/R/Sem.lean, Run.lean        R's step function, open at calls (reduced.md §C0.4); runs of images
Ryo/Vm/R/View.lean                 `unpack` (handler argument registers by `asm::layout`) and
                                   `view` (reduced.md §C0.6): R instructions as opcode, `Val`s
                                   and control, Rust's `asm::decode`
Ryo/Vm/Asm.lean                    asm/ pieces the decoder shares with the encoder: modes,
                                   return kinds, fixed sequences, inline sequences, the
                                   register cache
Ryo/Vm/DecodeReduced.lean          `decodeReduced` (aot.md §C2), a port of Rust's
                                   `asm::decode_reduced`; its JSON inputs (`ryo-lean decode`)
Ryo/Vm/Frame.lean                  frame accesses of R code, the dropped-store deadness check
                                   (with facts about callees' stack-argument extents, sret
                                   destinations and island templates)
Ryo/Vm/OpSem/                      `opSem` (reduced.md Part D): Basic (operands, state, results),
                                   Footprint (per opcode, from the handler table), Arith
                                   (integer and float operations), Sem (per handler kind),
                                   Lemmas (frame accesses only through the footprint), Json
                                   (`ryo-lean opsem`)
Ryo/Vm/DecodeObj.lean              `ryo-lean decode <obj>`: an image object's functions decoded
                                   (Ryo/Obj's inputs, linked at made-up addresses), printed as
                                   scripts/lean-decode-ref prints Rust's
Ryo/Check/Image/Pool.lean          image checks (docs/aot.md §C4): the constant pool and
                                   vtables against the dump's allocations (`check-pool`)
Ryo/Check/Image/Dump.lean          `__ryo_main` and function symbols against the dump
Ryo/Check/Image.lean, Image/       `ryo-lean check-image` (aot.md §C4): function table and
                                   symbols (Funcs), relocations, JIT records, header, anchor
                                   and `__ryo_main` (Relocs), the registry object (Registry),
                                   FDE rows and LSDAs against the decoded code (Unwind)
Ryo/Check/Lower/                   the lowering check C1' (docs/aot.md §C1), so far its
                                   certificate: Plan (`sig.rs`'s `arg_plan` and `ret_kind` from
                                   the dumped ABI), Cert (the certificate and its JSON reader),
                                   CertCheck (`ryo-lean check-cert`, and the facts it gives the
                                   dead-store check)
Ryo/Examples.lean                  example programs for `ryo-lean example`
Ryo/X86/                           L2 (docs/x86.md Part B): Item (asm::x86's items), Encode,
                                   Decode (canonical, unlinked or linked), State, Exec (per
                                   the SDM), Extra (OSR code, JIT entry prefix, registry ctor),
                                   Cosim (`ryo-lean exec-item`)
RyoTest/*.lean, RyoTest.lean       tests; RyoTestMain.lean is the test driver (exe `ryotest`)
RyoTest/DecodeReducedVectors.lean  generated by vm/bytecode/tests/lean_reduced_vectors.rs
                                   (RYO_LEAN_GEN=1): Rust's decode_reduced on encoded
                                   functions and mutations, which RyoTest/DecodeReduced checks
RyoTest/ViewVectors.lean           generated by vm/bytecode/tests/lean_view_vectors.rs
                                   (RYO_LEAN_GEN=1): Rust's full decode of encoded functions,
                                   which RyoTest/View checks `view` against
RyoTest/UnwindVectors.lean         generated by vm/bytecode/tests/lean_unwind_vectors.rs
                                   (RYO_LEAN_GEN=1): eh_fde's FDEs and LSDAs with Rust's
                                   lsda::parse verdict, which RyoTest/Unwind checks
RyoTest/X86Vectors.lean            generated by vm/bytecode/tests/lean_x86_vectors.rs
                                   (RYO_LEAN_GEN=1); ../scripts/lean-x86-objdump.py checks
                                   the same vectors against objdump
harness/                           standalone Rust crate: the co-simulation of `Item.exec` against
                                   the CPU (docs/x86.md §B.3)
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
- External calls are events. Symbols without a shim are run by the oracle's environment
  (`Oracle.env`), which `Behaviors`/`Refines` restrict by an `ExtSpec`; the interpreter's
  environment runs nothing. The shims cover `__rust_alloc` & co., `write`,
  `exit`, `abort`, `_Unwind_RaiseException` (starts unwinding) and `ryo_test_print`.

## Status

M1 is done: `lake build` succeeds with no `sorry` (the five representation laws
`encode_length`, `decode_encode`, `encode_decode_le`, `decode_mono` and `store_load` are proved in
`Ryo/Spec/Theorems`), and `lake test` passes. M1b's dumper and differential runs work, and the
lowering certificate is written and checked against the code and the dump (`check-cert`). What
is left of M1 and the later milestones are in [docs/plan.md](docs/plan.md#3-milestones).
