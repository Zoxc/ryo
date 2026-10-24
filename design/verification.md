# Verification

ryo's compiled code is to be verified in Lean 4, in `lean/` (a Lake project beside
`backend/`, `build/` and `vm/`). This is the high-level plan; the details (each level's
definitions, the checkers and certificate formats, the divergences of the MIR spec from
MiniRust, milestones and open questions) are in [lean/docs/](../lean/docs/plan.md).

## Goals

- **End to end, MIR → x86 bytes**: for every VM function that passes validation, the machine
  code at its address, run under the platform calling convention, refines the semantics of
  the function's MIR. That covers the lowering, the `Asm` encoder, the register cache,
  dead-store dropping, branch relaxation, counters and stubs, and every other byte of the
  image object the code depends on.
- **The JIT too**: every JIT compilation that passes validation refines the AOT code it was
  compiled from, so by composition the MIR.
- **Nothing verified in Rust.** The backend runs inside rustc (`rustc_private`, `TyCtxt`
  everywhere) and changes every week, so no extraction tool can take it, and a model of it
  would drift. Instead every compiler step is covered by **translation validation**: its
  input, its output and an untrusted certificate go to a Lean checker, and the checker is
  proved sound once. A rejection is a test failure, not a miscompile, and coverage grows rule
  by rule.
- **Bugs found before theorems.** Every milestone finds bugs on its own: an executable MIR
  semantics to run differentially, an independent decoder diffed against the Rust one,
  checks of every byte of the image object.

Non-goals: concurrency (single-threaded executions; atomics are sequential), PE, aliasing
models (Tree Borrows), and verifying LLVM's output (native functions, islands).

## Levels

| Level | What | Memory |
|---|---|---|
| **L0** | rustc 1.99.1 runtime MIR, monomorphized, with rustc's layouts as input. MiniRust's semantic core (abstract bytes, provenance, the representation relation), rustc/LLVM behavior where MiniRust differs (36 listed divergences) | MiniRust allocations with provenance |
| **R** | the reduced VM program: native ops and `handler h args neg t` ([vm.md](vm.md#encoding)), decoded from the machine code | L0's memory model; frame objects are allocations while escaped |
| **R-SSA** | JIT only: CFG SSA with block parameters; frame objects are allocas | as R |
| **LIR** | JIT only: R-SSA after register allocation: registers, spill slots, frame layout | as R |
| **L2** | the x86-64 subset ryo emits (`asm::x86::Item`, stubs, OSR code), extended to **L2+** with the JIT's register-allocated forms | flat bytes, registers, flags |

There is no full-VM level. The lowering turns each `Asm::insn(opcode, operands)` straight into
x86 pieces, images store no instruction words, and nothing executes them. The full opcode
list is a vocabulary: it names the handlers and their operand layouts. Its meaning is one
Lean library, `opSem`, written per handler kind; a native R instruction means `opSem` of its
opcode, and a handler call means the handler's contract, which is `opSem` with an exact
frame footprint. So an inline sequence and a handler call of the same opcode agree by
construction, and the JIT's instruction-selection templates and handler effect tables are
stated against the same definitions.

## R carries provenance

R is not a flat byte machine: it uses L0's memory model (allocations, abstract bytes with
provenance fragments, exposed provenance), and provenance is erased only where code becomes
x86 bytes.

- **Frame objects.** R is stated over the frame's objects (byte ranges no access crosses,
  delimited by the escape scopes and island operand extents the image records,
  [vm.md](vm.md#escapes-storage-ends-and-island-operands)), at a layout `φ` from objects to addresses. AOT
  code is R at the AOT layout (`fp + offset`); JIT code is R at the layout the JIT chose.
- **Escape = allocation.** An object's bytes are private to the frame (reachable only
  through frame operands) until it escapes. At its escape it becomes an allocation at `φ` of
  it, with a fresh provenance; at its storage end (or return) it stops being one. `addr`
  yields a pointer with that provenance. Moves, loads and stores keep provenance; integer
  arithmetic drops it; `ptr.add` and `ptr.index` keep it. R can't see where MIR exposed a
  pointer (`expose_provenance` is a move), so every escaped object counts as exposed, and a
  never-escaped one never.
- **What follows from it.** Frame privacy (no pointer reaches frame bytes that aren't
  escaped), independent placement (a pointer derived from one object can't reach another),
  and dangling after `StorageDead` are consequences of the memory model, not extra rules.
  They are what the JIT relies on to promote objects to SSA values, drop their stores, and
  place or move them.

What this means for the relations:

- **L0 ↔ R**: identity on addresses (L0 picks a local's address non-deterministically, so the
  simulation picks the one R's layout gives), and provenance related by a renaming of
  allocation ids: an escaped local's L0 allocation is its frame object's R allocation, a
  constant is its pool copy, a static or heap block is itself. A local that never escapes
  has no pointers in L0 either, and corresponds to private frame bytes. The lowering check
  validates the escape scopes against MIR (every `addr` and by-address argument covered,
  ends at `StorageDead`), which is what makes R's allocations line up with L0's.
- **R ↔ R-SSA**: the JIT's allocas are R's frame objects (the checker compares the two
  tables), so the relation is identity on addresses and on provenance under the JIT's
  layout. Promoted objects (never escaped, accessed only as whole scalar fields) are SSA
  values, related by the dominance equation of CompCertSSA. Entering the JIT code by OSR
  changes the layout mid-execution: objects escaped at the loop head stay at their AOT
  offsets, and the others move, justified by one **relocation lemma** on the shared memory
  model: states that differ only in the addresses of objects nothing refers to are
  bisimilar. Since R has provenance, "not escaped at the head" already means "nothing refers
  to it" in R, so the lemma is used in R, without going back to L0.
- **R ↔ L2** (and LIR ↔ L2+): provenance erased, addresses identical, uninitialized bytes
  refined by any byte. R's provenance checks only add UB on R's side.

## Proved, checked, trusted

"Proved" is a Lean theorem proved once; "checked" is a Lean checker run per function or per
compilation, proved sound; "trusted" is assumed and tested.

| Step | Proved once | Checked | Trusted |
|---|---|---|---|
| MIR input | representation laws | MIR well-formedness | the MIR dump (MIR, layouts, resolved instances, constant and vtable allocations); L0's fidelity to rustc/LLVM, tested by differential runs |
| Lowering + encoding (MIR → R) | the checker's soundness; one simulation lemma per lowering rule; the ABI convention lemmas | **C1'**: the R program the Lean decoder read from the object against the dumped MIR and a certificate (frame map, statement → instruction ranges, call plans); slot sharing; escapes and ends against MIR | rustc's `PassMode` is what LLVM implements |
| Bytes → R | `decode_sound`: canonical sequences, inline sequences against `opSem` (`bv_decide`), the register-cache invariant, counters and stubs as no-ops | the Lean decoder accepts the bytes; dropped stores re-checked dead | handler, island, probe and trip contracts |
| The rest of the object | — | image checks (below) | linker and loader; the unwinder's reading of CFI and LSDAs |
| JIT | per-step checker soundness, rewrite rules, the inlining splice lemma, instruction-selection templates, the OSR entry and relocation lemmas | every step from the JIT's log (below) | publication ordering, code memory, `cpuid`, the logging path |
| Native code | — | — | LLVM's code (native functions, islands, `c_main`), libc, the allocator, the panic runtime, under the calling convention |

Not trusted: the Rust lowering, encoder and decoders, the certificates, the scope, call-site
and dropped-store tables, the constant pool, the function table, the relocations, the FDEs
and LSDAs, the registry object, and the JIT's passes and heuristics.

## The AOT theorem

For each VM function `f`, the Lean side reads the image object itself: an ELF reader finds
`f`'s bytes, the `.rodata` they read, the side tables, the LSDA and the relocations; the
verified decoder turns them into an R program `P`; C1' checks `P` against `f`'s dumped MIR.

> If the image object parses, the decoder accepts `f`'s bytes as `P`, C1' accepts `P` for
> `f`'s MIR and certificate, and the image checks pass, then the x86 code of `f` at its
> address simulates `f`'s MIR under the platform calling convention, given the contracts.

The proof composes `L2(bytes) ⊑ R(P)` (`decode_sound`) with `R(P) ⊑ L0(f)` (the checker's
soundness and the per-rule lemmas). VM↔VM and VM↔native calls use the same convention, so
per-function results compose (CompCertO-style open semantics). **Program-level**: if every VM
function of every image is validated, the image checks pass and native code honors the
convention, the linked program's behaviors are the MIR program's, or a prefix of one ending
in a stack overflow. Functions the checker can't validate are reported in a coverage count,
like `RYO_STATS`, and the program-level theorem is conditional on them.

The counter stubs are no-ops only given the trip contract, which may transfer to JIT code.
So the theorem comes in two versions: without the JIT (`RYO_JIT=off`, the no-op JIT) it is
unconditional on it; with the JIT on, it assumes every JIT compilation of the run passed
validation.

## Image checks

Every byte the backend emits into an image or registry object is checked against the dump,
the decoded code, or both:

- **Constant pool and vtables**: each referenced entry holds the dumped rustc allocation's
  bytes, its relocations are exactly the allocation's provenance, and it is read-only.
- **Function table and symbols**: each entry covers exactly the decoded code, each symbol is
  at its entry with the name `tcx.symbol_name` gives, and sizes and return kinds match the
  signature.
- **Relocations**: every relocated field the decoder met has the kind and target its form
  needs (handler, probe, symbol slot, pool, data, record), and no other relocations exist;
  symbol slots name the callee the dump names.
- **Unwind tables**: each FDE's rows match the decoded prologue and epilogue; LSDAs match the
  call-site table and the landing pads.
- **Registry object** and `__ryo_main`: the three-instruction constructor, its `.init_array`
  entry, the image list.

A later check compares the linked executable with the objects (each image's sections equal the
object's bytes with relocations applied), so the linker leaves the trusted base and only the
loader remains.

## The JIT

JIT compilations are validated offline, from a log per compilation that holds the AOT bytes
of the function and of everything inlined into it, the intermediate IRs with their
certificates, and the JIT's bytes, OSR code and unwind tables. The Lean side decodes the AOT
bytes itself, so the JIT's own decoder is not trusted.

- **Today's JIT** (decode, re-encode, optionally shuffle the frame, OSR entries,
  [jit.md](jit.md)) emits canonical code, so the same decoder reads its output. The checker
  verifies that the JIT program is the AOT program with its frame remapped, which in R is a
  change of layout, and that each OSR entry moves the bytes live at its head.
- **The SSA tier** (planned): R → R-SSA (Braun's construction with promotion of non-escaped
  objects) → passes and inlining → register allocation → register-allocated x86. Each step
  has its own validator: symbolic execution against a construction certificate; proved
  rewrite rules or per-pass validators; inlining checked as substitution under recorded
  renamings; a location checker for register allocation; and, since the output is not
  canonical, a generic x86 decoder with a per-block template match against the logged LIR.
  OSR entries and unwind tables are checked as above.
- **Dependencies**: frame privacy holds in R because the scope tables delimit R's
  allocations, and C1' validates them; for a function whose lowering isn't validated, the
  JIT theorem is conditional on its scope table. The JIT's handler effect tables must be the
  footprints of `opSem`, generated from them or checked equal.

The guarantee covers every compilation the test corpus performs, under each JIT test mode
(threshold 0, OSR at the first head pass, shuffled frames). Outside the corpus it needs
in-process validation (Lean runtime or extracted checkers) or sampling, which is open.

## Milestones

| Milestone | Delivers |
|---|---|
| **M1** (done) | the MIR spec: executable, with MiniRust's tests ported and every divergence tested |
| M1b | the backend's MIR dump and differential runs of the Lean interpreter against native and ryo builds |
| M2, M2b | Lean x86 encoder/decoder, ELF and image readers, the decoder to R, co-simulation of x86 against the CPU; the image checks |
| M3 | `opSem` and the handler contracts, R's semantics with provenance and the relocation lemma, `decode_sound` |
| M4 | validation of today's JIT |
| M5a–c | the lowering checker C1' and its simulation lemmas: memory relation first, then places and aggregates, then calls, islands and unwinding |
| M6 | composition: the AOT theorems, the linked-executable check |
| M7a–d | the SSA tier's validators: construction, register allocation and emission, passes, inlining |

Value arrives early: M1b gives a differential oracle for the lowering, M2 an independent
decoder and an accounting of every emitted byte, M3 verified decoding of all AOT code and the
`opSem` the JIT's effect tables need. The SSA tier's log format and x86 forms are agreed with
M7a before the tier is built, so the validators fit it.
