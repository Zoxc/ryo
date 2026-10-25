# Part E. The JIT

The JIT's output is validated offline, per compilation, from a log, against the R programs
the Lean decoder reads from the AOT code it was compiled from. Composed with the AOT theorem
([aot.md](aot.md) §C5), validated JIT code refines L0. R, its provenance and its frame
layouts are in [reduced.md](reduced.md).

Two pipelines are covered: today's JIT ([jit.md](../../design/jit.md): decode, re-encode in
the same or a shuffled frame layout, OSR entries), and the planned optimizing SSA tier
(§E.3), which turns frame objects into allocas with provenance and emits register-allocated
x86.

## E.1 Today's JIT (decode → re-encode → remap → OSR entries)

Its output is canonical, so it is validated with `decodeReduced`. It stays relevant as long
as it is the JIT (and as the SSA tier's fallback), and its OSR lemma generalizes to the SSA
tier.

- **Log** (`RYO_JIT_DUMP=<dir>`, a planned runtime setting), per compiled function: the AOT
  bytes + side data + `LinkMap`, the JIT bytes at their address, the `SlotMap`, the OSR code
  and its entries, the FDE and LSDA.
- **Checker**:
  1. decode both with `decodeReduced` (counters on for AOT, off for JIT)
  2. check `P_jit = remap map P_aot`
  3. check `map` is injective, fixes escaped bytes and the incoming area (`fp ≥ 0`), and
     keeps every access within one side (moved or pinned)
  4. recompute head liveness in Lean, and check each OSR entry's moves cover the live bytes
     that `map` moves
  5. decode the OSR code (the extra forms of [x86.md](x86.md) §B.1) and check its landing
     positions against the JIT program's head positions
  6. check the JIT FDE and LSDA as [aot.md](aot.md) §C4 does for AOT
- **Theorems**: in the terms of [reduced.md](reduced.md) §C0.2, `remap map` is a change of
  frame layout, `R(P_jit) = R(φ_map)` with `φ_map = map ∘ φ_AOT` on the moved objects.
  - Entry: R is parametric in `φ`, so entering at the function's start needs nothing more.
  - `osr_entry_sound`: from an L2 state at AOT head `h` related to `R(φ_AOT)`, the entry code
    reaches the JIT head `h'` related to `R(φ_map)`, given the move set covers
    `live(h) ∩ moved`. Covers the parallel move via scratch below both frames, `rsp`, the
    probe, and `fp` staying put. The change of layout mid-execution is the **relocation
    lemma** ([reduced.md](reduced.md) §C0.7): moved bytes are not escaped at `h`, so nothing
    refers to them (zero-sized objects, whose addresses `addr` may have taken without
    provenance, stay put). This replaces a separate `remap_sound`.
  - `trip_sound`: the trip contract holds for the published code.

## E.2 Trip contract (used by C2, E.1 and E.5)

`ryo_jit_trip_entry` / `ryo_jit_trip_osr`, called from the stubs with `r11` = record:

- either return to the stub's continuation with every register but `rax`, `r11` and the flags
  preserved, the stack as found, and memory changed only in runtime-owned areas (records,
  queue, code memory)
- or (`Done`) transfer to code that satisfies `FnSim` for the same R function: entry, or
  head `N`. For JIT code that is exactly what a validated compilation provides
  ([aot.md](aot.md) §C5).

Trusted (assembly + Rust). Tested by `vm/rt/tests/jit.rs`.

## E.3 The SSA tier's levels

The optimizing tier builds a CFG SSA IR with block parameters from the decoded R program
(Braun et al.'s on-the-fly construction), and emits register-allocated x86. Two new
semantics:

- **R-SSA**: blocks with parameters; values are bit-vectors of 1, 2, 4 or 8 bytes, as lists
  of abstract bytes. Instructions are the reduced native ops on values, handler calls with
  their exact frame effects, calls, islands, `alloca.addr`, `load`/`store` on allocas and on
  pointers, and `osr.load` (a read of the AOT frame in an OSR entry block).
- **LIR**: R-SSA after out-of-SSA and register allocation: physical registers, spill slots,
  the frame layout chosen for the allocas, parallel moves on edges.

**Allocas are R's frame objects.** The JIT cuts the AOT frame into allocas exactly as R's
frame-object table does ([reduced.md](reduced.md) §C0.2: byte ranges no access crosses,
merged over escape scopes and island operand extents), so the checker can compare the two
tables. Then:

- an alloca that never escapes and is accessed only as whole scalar fields is **promoted**:
  each field is an SSA variable that the construction renames (mem2reg and SROA in one pass);
- every other alloca stays memory, placed by the JIT anywhere in its frame, with its
  alignment, disjoint from the others;
- an alloca that may be escaped at a loop head with an OSR entry is **OSR-pinned** at its AOT
  offset, since pointers to it may be anywhere when a thread enters by OSR.

**Memory model: R's, unchanged.** R-SSA and LIR use `Ryo/Spec/Mem` like R. `alloca.addr a, k`
yields a pointer with the provenance of `a`'s allocation; moves, loads and stores preserve
abstract bytes; arithmetic drops provenance, `ptr.add`/`ptr.index` keep it; escaped allocas
count as exposed. Because R already carries provenance, the R ↔ R-SSA relation is:

- under the JIT's layout `φ_JIT`, identity on addresses and on provenance (each alloca is the
  R allocation of its frame object);
- for promoted allocas, CompCertSSA's dominance equation: at each point, the R object's
  private bytes equal the value of the variable's current SSA name;
- at OSR entries, the relocation lemma for the moved (non-pinned) allocas, from `R(φ_AOT)` to
  `R(φ_JIT)`; pinned allocas have `φ_JIT = φ_AOT`.

Provenance is erased only at emission (LIR → L2+). A by-product: inlining needs no
frame-merging injection (CompCert's `dstk`), because callee allocas are just more allocations.

## E.4 SSA-tier validation, step by step

The JIT log per compilation (`RYO_JIT_DUMP=<dir>`) carries everything the checkers need, so
the checkers never trust the JIT's view of its input:

- the AOT bytes, side data and `LinkMap` of the root **and of every inlined callee** (with
  their images, for cross-image inlining);
- the alloca table (AOT offset, size, alignment, kind, pinned, JIT offset);
- the R-SSA after construction with its certificate (def/use, block parameters, OSR entry
  blocks, landing-pad edges);
- per pass: the output IR and the pass's certificate (liveness, value numbering, renamings),
  or only the output for passes with proved rules;
- the inlining decisions with their renamings;
- the LIR after register allocation (intervals, the location of each value at each
  instruction), with per-block item boundaries in the output;
- the JIT bytes at their address, the OSR entry code, the FDE and LSDA;
- the CPU features the code was compiled for (the `cpuid` bits it used).

| # | Step | Checked per compilation | Proved once |
|---|---|---|---|
| 1 | Input | Lean decodes the logged AOT bytes itself with `decodeReduced` (linked mode). The Rust `decode_linked` is not trusted | `decode_sound` |
| 2 | R → R-SSA (Braun) | the alloca table equals R's frame-object table (every access in one object); per-block symbolic execution against the construction certificate; for each promoted variable, R's private bytes = the value of its current SSA name; OSR entries and landing-pad edges present | checker soundness; dominance lemma |
| 3 | Passes (SCCP, GVN, DCE, folding, LICM, check elimination, SROA, jump threading) | validators for analysis passes (liveness certificate for DCE; availability for GVN/LICM; per-block symbolic evaluation) | rewrite rules once (`bv_decide`, lean-mlir style), with the Rust rule tables generated from them; SCCP and GVN through the dominance lemma |
| 4 | Inlining | the unit equals the root with callee bodies (each decoded from its own logged AOT bytes) substituted under the recorded renamings; actions substituted (§E.6) | the splice lemma (§E.6) |
| 5 | Out-of-SSA + register allocation | location checker (Rideau–Leroy or regalloc2's symbolic checker): parallel moves on edges, callee-saved homes across calls and into landing pads | checker soundness |
| 6 | Emission → x86 | **generic** L2+ decode of the JIT bytes (not `decodeReduced`), then a per-block template match of the items against the LIR; every item's feature is in the logged CPU features; allocas disjoint, aligned, pinned ones at their AOT offsets | one lemma per instruction-selection template against `opSem` |
| 7 | OSR entries | decode the entry code (L2+); Lean recomputes AOT head liveness; the entry's moves establish the R ↔ R-SSA relation at the landing block from the AOT frame (every `osr.load` reads a whole field at its AOT offset, every moved live alloca is copied, no pinned alloca is written); `fp` and the incoming area stay put | `osr_entry_sound`, generalized to slot → register/slot homes; the relocation lemma |
| 8 | Unwind tables | the JIT FDE's rows match the decoded prologue and callee-saved saves (`DW_CFA_offset`); the LSDA matches the LIR's call sites and pads | LSDA parse |

**Theorem (per compilation):** if every check passes, the JIT code (entry and every OSR
entry) simulates the R programs that the Lean decoder read from the AOT code of the root and
of every inlined callee. Composed with the AOT theorem, the JIT code refines L0.

**`cpuid`.** The theorem is relative to the CPU having the logged features: the generic
decoder accepts a form only if its feature is in the set, and L2+ faults on a form whose
feature is absent. Validate per feature set the corpus runs on (at least: baseline x86-64
and the development machine's set).

## E.5 OSR and unwinding in the SSA tier

- **OSR entries** are extra CFG entries at the root's AOT heads: blocks with no
  predecessors whose reads of variables are `osr.load`s of the AOT slots. The construction
  certificate covers them; `osr_entry_sound`'s obligation is that the entry block
  establishes the relation from the AOT frame. The emitted entry reads everything it needs
  from the AOT frame into a scratch area below both frames before writing the JIT frame, so
  the two layouts may overlap. Inlined callees' heads are ordinary blocks, so they add no
  OSR obligation.
- **Landing pads** are exceptional successors. Values live into a pad are in callee-saved
  registers or slots at each unwinding call (allocation checker), and the FDE says where
  (step 8).

## E.6 Inlining

CompCert's `Inlining` (RTL → RTL) is the template, with the heuristic an untrusted oracle:
the proof holds for **any** set of inlined call sites. On SSA with allocas: arguments become
values, `ret` becomes a block parameter of the continuation, and callee allocas become fresh
allocations, so no frame merging is needed. The lemmas new compared to CompCert:

- **Unwind-action substitution**: each inlined call-like instruction keeps its own action,
  except that `CONTINUE` takes the action of the call it was inlined at (none if that call
  had no entry). Callee pads stay, retargeted; the inner one wins.
- **`resume` → `lpad.from x → y` + jump** when the site had a pad; `resume` stays when it
  had `CONTINUE`; abort when it had no entry. `lpad.from` is a JIT-only form with its own
  semantics.
- **Storage ends**: the callee's allocas die at the inlined return (sibling inlined calls
  may then reuse the space; placement, not semantics).
- **Island frame operands**: island contracts are stated on frame operands, so renaming must
  commute with them (an island operand object is an alloca at a placement the contract
  sees).

First step: the validator of step 4 (a linear syntactic check). The splice lemma follows.

**Cross-image inlining** (`call.sym` into another image) needs "symbol slots are immutable
after loading" (RELRO, trusted, [aot.md](aot.md) §C6), and the callee's image's checks
([aot.md](aot.md) §C4) to have passed. **Devirtualization by constant propagation** needs
"pool memory is read-only": D7 makes consts immutable allocations (a write is UB), and §C4
checks the pool is in RELRO and holds the allocation, so a load from a constant vtable may be
folded. Open question: D7 lets the source pick a const's copy; with constants from image B
folded into a unit of image A, check that "each `Ref` carries its image" suffices.

## E.7 What the JIT guarantee depends on

- **Frame privacy comes from the lowering check.** Promotion of non-escaped objects, DCE of
  their stores, free placement of allocas and moving them at OSR are sound only if no
  pointer reaches non-escaped frame bytes. In R that is a consequence of provenance, but only
  because R's allocations are delimited by the image's scopes (in each function's instruction
  list): C1' establishes that the
  scopes match MIR ([aot.md](aot.md) §C1). For a function whose lowering is *not* validated,
  the JIT theorem is **conditional on "the image's scopes are correct"**. State it that
  way, and report it in the coverage (validated / conditional / failed).
- **The exact effect tables** are each handler's footprint. **Generate the Rust table from
  the Lean footprints** (`Ryo/Vm/OpSem`), or check equality in `y test`. Otherwise an
  under-approximated read in Rust silently breaks promotion or DCE while the Lean proof still
  "holds" against a different contract. The canary test validates both against the
  handlers. Checked: `RyoTest/Effects.lean` maps every footprint to the JIT's vocabulary and
  requires it to equal `jit/effects.rs`'s table (`RyoTest/EffectsVectors.lean`, generated by
  `vm/bytecode/tests/lean_effects.rs`, which `y lean` and `y test` run); generating the Rust
  table is still to do.
- **The trip contract and the AOT theorem**: [aot.md](aot.md) §C5. The AOT theorem with the
  JIT on assumes every compilation of the run is validated.
- **Rust-side debug validators** (an IR verifier, an allocation checker, frame and OSR
  checkers that make a failing function fall back to the re-encode pipeline) are robustness
  features, not part of the proof. The proof-backed guarantee comes from the Lean checkers
  run offline on logs (or from extracted checkers, §E.9).
- Trusted on the JIT runtime side: publication ordering (release stores, no cross-modifying
  code), W^X and code memory, `__register_frame`, `cpuid`, and the logging path (that the
  logged bytes are the installed bytes).

## E.8 Where the JIT guarantee holds

Per validated compilation. Run the validators over the corpus with:

- `RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1` (every function compiled, entry path)
- `RYO_JIT_THRESHOLD=16` (OSR at the first head pass)
- `RYO_JIT_SHUFFLE=1`, and each inlining and optimization level of the SSA tier

This turns the JIT test modes into a proof-backed oracle. Outside the test corpus, "every
compilation is validated" (needed by [aot.md](aot.md) §C5 with the JIT on) needs one of: a
debug `RYO_JIT_VALIDATE` linking the Lean runtime, Aeneas-extracted checkers, or sampling.
Open.

## E.9 When to use Aeneas

- When a checker or pass is small, pure, and must run in production, write it in the
  Aeneas-supported subset (no `dyn`, simple loops, `Vec`/slices, no interior mutability), in
  its own crate (e.g. `vm/jitcheck`), extract into `lean/Ryo/Jit/Extracted/`, and prove it
  equal to the Lean checker.
- Candidates: the construction and allocation checkers, liveness, the OSR move sets, the
  rewrite engine. Extracted checkers are also how the Rust debug validators and the Lean
  checkers can be the same code.
- Not `ryo_bytecode::asm` as it is today.
