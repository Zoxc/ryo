# Verifying ryo in Lean 4: the detailed plan

The high-level plan is [design/verification.md](../../design/verification.md). This document
and the others in `docs/` are its details:

| Document | Contents |
|---|---|
| [plan.md](plan.md) | strategy, semantics engineering, project layout, milestones, risks, open questions |
| [mir-spec.md](mir-spec.md) | Part A: L0, the MIR spec (done, M1), and the divergences D1–D36 from MiniRust |
| [x86.md](x86.md) | Part B: L2, the x86-64 subset ryo emits, and L2+ for the JIT |
| [reduced.md](reduced.md) | §C0 and Part D: R, the reduced VM level with provenance, `opSem`, contracts |
| [aot.md](aot.md) | §C1–C6: the lowering check and its certificate, the verified decoder, the object readers, the image checks, the AOT theorems, the trusted base |
| [jit.md](jit.md) | Part E: today's JIT and the SSA tier: levels, the log, validation step by step, inlining |

References of the form §A.n are to mir-spec.md, §B.n to x86.md, §C0 and Part D to
reduced.md, §C1–§C6 to aot.md, §E.n to jit.md, and §0–§6 to this document.

## 0. Summary

```
L0  MIR (rustc 1.99.1 runtime MIR, monomorphized, with rustc layouts)    Part A (done)
 │  lowering + Asm encoder (one pass)          C1': checked per function on R   Part C
 ▼
R   reduced VM program: native ops (reduced_ops.rs) + `handler h args neg t`,
    with provenance, parametric in the frame layout; decoded by the verified
    Lean decoder from the image object's bytes                                 Part D
 │  canonical x86 sequences, register cache,   decode_sound: proved once        Part C2
 │  dropped stores, counters; provenance erased
 ▼
L2  x86-64 subset (asm::x86::Item, prologue, stubs, OSR code)                 Part B
 ▲
 │  JIT (SSA tier): R ─▶ R-SSA (allocas = R's frame objects + SSA values)     Part E
 │    ─▶ passes / inlining ─▶ LIR (after register allocation) ─▶ x86 (L2+)
 │    each step validated offline from the JIT's log
```

- **No full-VM level.** The lowering calls `Asm::insn(opcode, operands)`, which turns each
  instruction straight into x86 pieces; images store no instruction words, and nothing
  executes them. What survives of the full set is the **opcode vocabulary** (`ops.rs`): it
  names the handlers, `asm::layout`, and the native reduced ops. Its meaning lives in one
  per-handler-kind library, `opSem` (§1.3, Part D), that both native R instructions and
  handler contracts use.
- **The AOT machine code is verified end to end.** For each VM function the backend emits,
  the Lean decoder reads its bytes **from the image object** (text, `.rodata` parts, side
  tables, LSDA, relocations) into an R program `P`; the lowering checker C1' checks `P`
  against the function's dumped MIR; the image checks (§C4) check the rest of the object
  (constant pool, vtables, symbols, function table, relocations, unwind tables, registry
  object). The composition is the AOT theorem (§C5):

  > If `readImage obj = ok img`, `decodeReduced img f = some P`, `checkLowering Γ (mir f)
  > (cert f) P = ok` and `checkImage img dump = ok`, then the x86 code of `f` at its address
  > simulates `L0(mir f)` under the platform calling convention, assuming the trusted base
  > (§C6).

  The MIR dump is the only trusted input from the backend. The Rust lowering, encoder,
  decoders and certificates are not trusted.
- **R carries provenance.** R uses L0's memory model: a frame object becomes an allocation
  at its escape and stops being one at its storage end, so frame privacy, independent
  placement of objects and dangling after `StorageDead` follow from provenance. L0 → R
  relates provenance by a renaming, the JIT's R-SSA is related to R by identity on
  provenance, and provenance is erased only at x86 (§C0).
- **Approach: translation validation, not verifying the Rust** (§1): a Lean MIR spec (done),
  a verified Lean decoder, a relational lowering spec with a decision procedure and one
  simulation lemma per rule, image checks, and per-step validators for the JIT, run offline
  from its log.
- **No Mathlib**: core Lean + `Std` (`BitVec`, `bv_decide`, `omega`, `grind`, `Std.TreeMap`).

---

## 1. Strategy

### 1.1 Options

| Option | What is proved | Fit for ryo |
|---|---|---|
| **Verify the Rust code via extraction** (Aeneas/Charon, hax → Lean) | the actual Rust functions | **Lowering: impossible** (rustc_private, `TyCtxt`, arenas, rustc's own types). **`ryo_bytecode::asm`**: Aeneas has no `dyn Trait`, so `Fields::Linked` and the resolver are out. It has a partial collections/iterator model, `define_ops!` expands to ~850-variant enums, and the code changes every week. Hax's Lean backend is immature. **Handlers**: raw pointers, so out of reach. |
| **Verify a Lean model** of the compiler, compare with the Rust by testing | the model | Proves an algorithm the Rust only resembles. The model drifts from the Rust. |
| **Translation validation** (per-function checker, proved sound once) | each compiled function | Proofs are about the checker, which is small and stable. The Rust stays free to change, and a checker rejection is a test failure, not a miscompile. Standard for compilers (Necula; Tristan–Leroy; CompCert's validated register allocation and scheduling; Alive2). |
| **Verified decoder as validator** (a special case of TV) | every byte string the decoder accepts | ryo's AOT machine code is **canonical and exactly decodable** (`asm::decode_reduced`, `RYO_ASM_CHECK`). So "decode with a verified decoder and compare" validates the encoder, the register cache, dead-store dropping, relaxation and counters, all at once. The SSA JIT's output is not canonical; it gets a generic decoder plus a match against its logged IR instead (§E.4). |

### 1.2 Recommendation per stage

| Stage | Approach | Proof effort is in |
|---|---|---|
| MIR → R (lowering + encoding), on the bytes of the image object | TV: relational spec `Lowers` over R's op view + decision procedure (C1') + per-rule simulation lemmas L0 → R. Certificate from the backend | memory relation (identity on addresses, `AllocId` renaming), frame layouts, calls/ABI, unwinding |
| x86 bytes → R | verified Lean decoder (`decodeReduced`) + `decode_sound` | per-shape lemmas, inline sequences against `opSem`, register-cache invariant, dropped-store deadness (which the Lean decoder **checks**, unlike the Rust one) |
| The rest of the image object | image checks (§C4): pool/vtables vs dump, symbols, `FuncEntry`, relocations, FDE rows, LSDA, registry object | small parsers and comparisons; FDE rows against the prologue |
| Today's JIT (decode/re-encode/remap/OSR) | TV offline: decode JIT output with `decodeReduced`, check `remap(map, decode AOT)`, check OSR entries against Lean-recomputed liveness | the relocation lemma (a remap is a change of frame layout), OSR entry lemma |
| SSA JIT: R → R-SSA → passes → LIR → x86 | TV offline per step from the JIT log: construction certificate, proved rules or pass validators, inlining as substitution under recorded renamings, allocation checker, generic x86 decode + template match against the logged LIR, OSR homes, FDE/LSDA | R-SSA semantics with allocas = R's frame objects (same memory model), dominance lemma, allocation-checker soundness, templates against `opSem`, the inlining splice lemma with unwind-action substitution |
| Handlers, islands, `ryo_probe_stack`, trip entry points, `ryo_vm_register`, `c_main` | **trusted contracts** (Lean specs; handler contracts are `opSem` plus a footprint), tested by `vm/rt/tests/ops.rs`, `inline.rs`, canary-frame effect tests and differential runs against the Lean semantics. Optionally verified later at the binary level with an extended L2 (they are tiny, `-O3`, mostly call-free) | — |

**Why TV for the lowering:** the lowering is ~5k lines spread over a dozen modules, depends
on rustc internals, and changes often (see the git log). A relational spec has roughly one
rule per lowering case (~200), each rule is local, and the checker needs only what the
backend already knows (slot offsets, which statement emitted which instructions). The one
cost is that the backend must dump MIR and layouts faithfully (§C6, trusted base).

**Why not run the checker inside the JIT at run time:** compiled Lean needs the Lean runtime
(C, ref-counting, `libleanrt`), which `ryo_rt` must not carry (no re-entry, `core`-only
outside `jit`). A debug-only `RYO_JIT_VALIDATE` that links it is possible later (§E.8). The
plan validates offline: the guarantee covers every compilation the test corpus performs.

### 1.3 Semantics engineering choices (all levels)

- **Executable first.** Every semantics is a Lean function (`step`), not only an inductive
  relation. The relational view comes from quantifying over the oracle (§A.4 and "Deviations
  during M1"). Executable semantics can be tested against the real thing: MIR programs against
  native runs, x86 items against the CPU, R programs against the handlers.
- **One memory model with provenance, erased only at x86.** L0, R, R-SSA and LIR share
  `Ryo/Spec/Mem` (MiniRust's allocations with concrete addresses and provenance); only L2 is
  a flat byte memory. In R, a frame object becomes an allocation when it escapes and stops
  being one at its storage end, and R is parametric in the frame layout `φ` (§C0). Because
  MiniRust picks allocation addresses non-deterministically (daemonic `pick`), the L0→R
  simulation can choose the address the target uses (`φ` of the local's frame object). So
  every relation is **identity on addresses**, with provenance related by a renaming of
  `AllocId`s (L0 → R, identity for R → R-SSA) or erased (into L2), and `Uninit` refined by
  any byte. No CompCert-style block injection is needed. Moving frame objects mid-execution
  (OSR into a JIT frame) is one lemma: states that differ only in the addresses of
  allocations nothing refers to are bisimilar (§C0.7).
- **Open semantics.** VM functions call, and are called by, native code, other images and
  islands. Each level is an open LTS with incoming and outgoing calls (CompCertO's
  "language interfaces"). The correctness statement per function is a simulation *under a
  convention* that relates L0 calls (callee, argument values, memory) to L2 calls (registers,
  stack area, memory) through rustc's `PassMode` plan. This is what lets per-function results
  compose, and lets native code be an assumption instead of a gap.
- **One operation-semantics library, `opSem`.** The full opcode list is a vocabulary, not a
  level. `opSem : full.Opcode → Operands → FrameMem → Result` is written per handler
  **kind** (~45 kinds: `bin`, `cmp`, `shift`, `ovf`, `cvt`, `discr`, `aload`, …), keyed by
  generated tables, and it is the single source of truth for:
  - native R instructions: `op ops` means `opSem op ops`;
  - handler contracts: `handler h args neg t` means "unpack the operands from the argument
    registers through `asm::layout(h)`, do `opSem h`, then the shape's control flow";
  - the lowering checker's rules (written over the op view, §C1);
  - the inline sequences (`asm::inline`) and the JIT's instruction-selection templates, each
    proved against it;
  - the JIT's exact handler effect tables, generated from its footprints (§E.7).

  So an inline form and a handler call of the same opcode agree by construction, which
  matters because `is_native(op, ops)` depends on the operands.
- **Generated tables.** The opcode list (`ops.rs`, `reduced_ops.rs`), shapes, operand kinds,
  `asm::layout`, handler kinds (`handlers.rs`) and the `Item` byte forms are generated into
  Lean (`lean/Ryo/Vm/Generated/*.lean`) by a small Rust program in the workspace, pinned to
  `FORMAT_VERSION`, so Lean and Rust can't drift.

---

## 2. Project layout and dependencies

### 2.1 Location

`lean/`, a top-level directory beside `backend/`, `build/` and `vm/`.

- The checkers consume ryo's dumps and image objects, and the generated tables come from
  `ryo_bytecode`, so the Lean project must change with the Rust code in the same commits.
- `y` can drive it later (`y lean build`, `y test` running the validators over the corpus
  objects and dumps).
- MiniRust is not vendored. It is a reference
  ([github.com/minirust/minirust](https://github.com/minirust/minirust), pinned at commit
  `d821c6e3`), hand-ported module by module (§A.3). Each ported definition cites its MiniRust
  file and section in a comment, so later MiniRust changes can be reviewed against it.

### 2.2 Dependencies

- **Toolchain**: `leanprover/lean4:v4.35.0`. Bump deliberately, not with every release.
- **No Mathlib** for the spec and checkers:
  - It isn't needed for semantics.
  - Lean core and `Std` cover what the proofs need: `BitVec` with `bv_decide` (inline
    sequences, flags), `omega`, `grind`, `simp`, and `Std.TreeMap`/`Std.HashMap` with lemma
    libraries.
  - Mathlib would force monthly toolchain bumps, multi-GB caches and slow CI, and would slow
    down the executable checker's build.
  - If proofs later need Mathlib-only theory, add **Batteries** first. If Mathlib is still
    needed, add a separate `RyoProofs` library that requires it, so `Ryo` (spec + checkers +
    exe) stays Mathlib-free.
- **No Aeneas/hax** until part E needs them (§E.9).

### 2.3 Tree (target state; M1 created `Ryo/Spec`, `RyoTest`, `Main.lean`, `docs/`)

```
lean/
  lean-toolchain                 leanprover/lean4:v4.35.0
  lakefile.toml
  Main.lean                      exe `ryo-lean`: `run <mir.json>`, later `check <obj> <dump>`,
                                 `check-jit <log>`
  Ryo.lean                       imports everything below
  Ryo/Spec/…                     L0 (done): Prelude, Mem, Lang, Mir, Theorems (§A.3)
  Ryo/Vm/Generated/…             generated opcode, layout, shape and handler-kind tables
  Ryo/Vm/OpSem/…                 `opSem` per handler kind, footprints
  Ryo/Vm/R/…                     R syntax, op view, semantics, handler/island/trip contracts
  Ryo/Vm/DecodeReduced.lean      the verified canonical-sequence decoder
  Ryo/X86/…                      L2: Item, encode, decode, semantics; L2+ (JIT forms),
                                 generic decoder
  Ryo/Obj/…                      ELF reader (sections, symbols, RELA), image parser, LSDA,
                                 `.eh_frame` parser
  Ryo/Check/Lower/…              C1': lowering relation, checker, certificates, dump readers
  Ryo/Check/Image/…              §C4: pool, symbols, function table, relocations, FDEs,
                                 registry object, linked-binary check
  Ryo/Jit/…                      remap and OSR (today's JIT); R-SSA, LIR, validators (part E)
  Ryo/Proofs/…                   simulation proofs between levels
  RyoTest/…                      tests (`lake test`)
```

---

## 3. Milestones

Effort is in person-months (PM) for someone fluent in Lean 4 and compiler verification.
Spec transcription parallelizes well across agents; the simulation proofs dominate and don't.

| # | Milestone | Delivers | Effort | Risk |
|---|---|---|---|---|
| M0 | Lake project (**done**), CI hook (`y lean`), table generator (Rust → `Ryo/Vm/Generated`) | build skeleton | 0.25 left | low |
| **M1** | **MIR spec (part A)** + interpreter + ported tests + representation theorems. **Done** (`lean/`, 179 tests). Left: the open representation theorems (`encode_length`, `decode_encode`, `encode_decode_le`, `decode_mono`, `store_load` beyond scalars), rvalue typing in MIR well-formedness, the relational `ExtSpec`, intrinsics outside D20, external/intrinsic tail calls, `f16`/`f128` tests | executable, citable semantics of what ryo compiles, with every divergence from MiniRust written down | 0.5–1 left | low |
| M1b | Backend dumper `RYO_DUMP_LEAN` (MIR + layouts + resolved instances + const and vtable allocations + certificate, JSON) and differential runs: Lean interpreter vs native/ryo on corpus functions and programs | finds spec mistakes and lowering bugs before any proof; the dump C1' and the pool check need | 1 | low–medium (dump size, std paths needing more shims) |
| **M2** | x86 `Item` encode/decode in Lean, ELF/image/LSDA/`.eh_frame` readers, `decodeReduced` from the object (no proofs yet), co-simulation harness | independent second decoder, diffed against the Rust one over all corpus objects; x86 model validated against hardware | 1.5–2 | low |
| M2b | Image checks (§C4): pool and vtables vs the dump, symbols and `FuncEntry`, relocations, FDE rows, LSDA vs call sites, registry object, `__ryo_main` | every byte of the image object accounted for; FDEs no longer assumed | 1–1.5 | low (needs M1b for the pool) |
| **M3** | `opSem` + footprints (generated tables), R semantics (frame objects, layouts, provenance; the relocation lemma), handler/island/trip contracts, the opSem differential harness, `decode_sound` (shape lemmas, inline sequences by `bv_decide`, register cache, dropped-store deadness, counters). The `opSem` part (M3a, ~0.5) first: the JIT's handler effect tables are generated from it | **every AOT byte sequence verified to implement its R program**; dropped stores checked, not trusted; one source for opcode meaning | 2–2.5 | medium: register-cache and dead-store invariants are subtle; inline proofs are routine |
| M4 | Today's JIT (E.1): remap check, liveness check, OSR entry decode; then `osr_entry_sound` over the relocation lemma. Only the checks if the SSA tier replaces the remap JIT soon; the OSR lemma carries over | JIT test runs become validated compilations | 1–1.5 | medium |
| M5a | C1' framework on R + straight-line integer/bool/pointer code, storage/frame relation, memory relation | first `validated` functions; frame-layout, slot-sharing and scope checks (frame privacy) | 2 | high (memory relation design) |
| M5b | Places, aggregates, enums, casts, constants, vtables, unsizing, switches, asserts | most non-call code validated | 2–3 | medium |
| M5c | Calls (ABI convention, sret, `Indirect`, spread, track_caller, virtual, tail calls), islands, unwinding | full coverage of what ryo lowers | 3–4 | high (ABI convention, unwinding model) |
| M6 | Composition: open semantics, convention composition, the AOT theorems of §C5 (with and without the JIT), linked-equals-object check | end-to-end statement | 2–3 | high |
| M7a | R-SSA semantics with allocas on `Ryo/Spec/Mem`, construction validator (step 2), the JIT log format (agreed with the SSA tier before it is built, so it is built in) | the SSA tier's first step validated at construction | 2–3 | medium |
| M7b | L2+ (extended items, generic decoder, co-simulation), LIR semantics, allocation checker (step 5), emission template match (step 6), JIT FDE/LSDA (step 8), OSR with homes (step 7) | the SSA tier's first step validated end to end: R → x86 | 3–4 | medium–high (allocation checker, OSR homes) |
| M7c | Pass rules and validators (step 3), as the passes land | optimizations proved or validated | 2–4 | depends on the passes |
| M7d | Inlining validator (step 4), then the splice lemma with unwind-action substitution and `lpad.from` | inlined units validated | 1.5–2.5 | medium |

Remaining total ≈ 25–35 PM (M1's 2–3 PM are spent). Value arrives early: M1b gives a
differential oracle; M2–M2b (≈ 3 PM) give an independent decoder and a full accounting of
the object; M3 gives verified decoding of all AOT code and the `opSem` the JIT's effect
tables need; M5–M6 give the end-to-end MIR → x86 theorem function by function through
coverage. M7a–b should track the SSA tier's construction and register-allocation steps, so
its log and IR are designed with the validators in mind.

## 4. Main risks and mitigations

- **Spec fidelity** (L0 says something rustc doesn't): differential runs (M1b), the
  divergence table with tests, and citing rustc/Miri sources per rule.
- **Memory relation complexity** (provenance, ZSTs, slot sharing, escapes): concrete addresses
  in MiniRust's model make it identity-on-addresses, and with provenance in R it is an
  `AllocId` renaming rather than an erasure (§1.3). Start M5a with it, before any other rule.
  The JIT reuses it (§E.3), so it is designed once. The relocation lemma is the one new
  memory-model proof (a permutation argument on `BasicMemory`; Kang et al.'s quasi-concrete
  model is a precedent for "an address is fixed only once observed").
- **Backend churn breaking the checker**: permissive relational rules, coverage reporting
  instead of hard failure for `unsupported`, and the generated tables pinned to
  `FORMAT_VERSION`.
- **Trusted contracts too strong or wrong** (handlers, islands): differential tests of each
  contract (`opSem` vs `ryo_h_*` called directly, with footprints checked by canaries).
- **JIT churn**: the SSA tier is being designed now. Agree the log format and the L2+ form
  list with it early (M7a), and keep its validators per step so a new pass needs only its own.
- **Concurrency**: out of scope. State the theorem for single-threaded executions. Atomics
  are D17's sequential approximation.

## 5. Open questions

- **Pool identity across images** (§E.6).
- **Where to validate the JIT in production** (§E.8).
- **`cpuid`-dependent code**: which feature sets to validate (§E.4).
- **Rust debug validators vs Lean checkers**: generate or extract the Rust ones from the Lean
  ones (§E.9), so a function failing Lean validation also fails closed at run time?
- **`RYO_DUMP`'s full-ISA disassembly** no longer matches what anything verifies. Consider
  printing the R view (`reduced::Disasm`) in `bench/codegen/*.txt` too.
- **Island operand extents**: a `Lend` scope per island operand object (metadata only) gives
  R's frame-object table and the JIT's allocas the extents; until then they come from the
  island contracts.

## 6. Decisions

- There is no full-VM level: R, the meaning of decoded machine code, is the only VM level,
  and the opcode list is a vocabulary for `opSem` (§0).
- R carries provenance (L0's memory model), is parametric in the frame layout, and frame
  privacy is a consequence of its allocations, which the scope table delimits (§C0).
- Validate the image object plus a linked-equals-object check (§C4); check every AOT FDE
  (§C4, cheap, rather than proving the generator).
- Handler contracts have exact frame footprints, and their pointer accesses are memory
  accesses with provenance (§C0.5).
- `view` need not be total: C1' rejects functions whose handler args don't unpack (§C1,
  reported in coverage).
