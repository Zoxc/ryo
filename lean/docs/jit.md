# Part E. The JIT

The JIT's output is validated offline, per compilation, from a log, against the R programs
the Lean decoder reads from the AOT code it was compiled from. Composed with the AOT theorem
([aot.md](aot.md) §C5), validated JIT code refines L0. R, its provenance and its frame
layouts are in [reduced.md](reduced.md).

Two pipelines are covered: today's JIT ([jit.md](../../design/jit.md): decode, re-encode in
the same or a shuffled frame layout, OSR entries), and the planned optimizing SSA pipeline
(§E.3), which turns frame objects into allocas with provenance and emits register-allocated
x86.

## E.1 Today's JIT (decode → re-encode → remap → OSR entries)

Its output is canonical, so it is validated with `decodeReduced`. It stays relevant as long
as it is the JIT (and as the SSA pipeline's fallback), and its OSR lemma generalizes to the SSA
pipeline.

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

## E.3 The SSA pipeline's levels

The optimizing SSA pipeline builds a CFG SSA IR with block parameters from the decoded R program
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
  R allocation of its frame object), with R-SSA's values allowed *more* provenance than R's
  (`bytesLeDefined`): LVN's identities on any value (`x + 0`, `x & -1`, `x | 0`, a
  same-width `Ext`) return a pointer operand where R computes an integer. That never adds UB,
  because an access resolves to the pointer's own allocation only if it contains the range
  and else to the exposed one that does ([reduced.md](reduced.md) §C0.3, "Resolution time";
  `Ryo/Proofs/Provenance.lean`: `use_mono`, `intBytes_le`, `lvn_*`). The converse, an R-SSA
  value with *less* provenance (folding a pointer to an integer constant: `rebase`, a
  folded load), is sound when the provenance it drops is exposed (`drop_exposed_mono`);
- for promoted allocas, CompCertSSA's dominance equation: at each point, the R object's
  private bytes equal the value of the variable's current SSA name;
- at OSR entries, the relocation lemma for the moved (non-pinned) allocas, from `R(φ_AOT)` to
  `R(φ_JIT)`; pinned allocas have `φ_JIT = φ_AOT`.

Provenance is erased only at emission (LIR → L2+). A by-product: inlining needs no
frame-merging injection (CompCert's `dstk`), because callee allocas are just more allocations.

## E.4 SSA-pipeline validation, step by step

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
| 8 | Unwind tables | the JIT FDE's rows match the decoded prologue and callee-saved saves (`DW_CFA_offset`; the saves are packed 8-byte slots at the frame's top, or, when no alloca is pinned above them, pushes and pops, each push without a frame pointer followed by a `DW_CFA_def_cfa_offset` row, "JIT SSA: push and pop callee-saved registers"); the LSDA matches the LIR's call sites and pads | LSDA parse |

**Theorem (per compilation):** if every check passes, the JIT code (entry and every OSR
entry) simulates the R programs that the Lean decoder read from the AOT code of the root and
of every inlined callee. Composed with the AOT theorem, the JIT code refines L0.

**The SSA pipeline's passes so far** (none modelled in Lean yet; each is an obligation for steps
3 and 4 when M7 starts, with the commit that added it):

- **Address ops**: `Op::RefAddr(ref, ind)` for the three inline address instructions (a
  rip-relative `lea`, or the slot load and with `ind` one more load), pure and keyed by LVN.
  Its rule is the R ones' (`inline_sound_rip`). ("Give the JIT SSA pipeline a pure op for
  rip-relative addresses".)
- **Small copies**: `copy`, `zero`, `load.copy`, `store.copy` of at most 128 bytes (`MAX_COPY`) and
  `mov.w128`, `load.w128`, `store.w128` decode as `Kind::Copy`, pieces cut at the other
  scalar accesses' boundaries, all reads before all writes; and after `simplify`,
  `memcpy`/`memmove`/`memset` handler calls of constant length 1 to 128 (operands all values,
  no unwinding) become loads then stores (`memset`: the byte times `0x0101…`), then LVN again
  (`jit::opt::copies`). Rule: the pieces equal the handler's footprint effect. ("JIT SSA pipeline:
  small block copies as loads and stores"; "JIT SSA: constant-length memcpy/memmove/memset as
  loads and stores"; "JIT: do block copies of up to 128 bytes as loads and stores".)
- **Inlining** (`jit::inline`, step 4): an IR-to-IR splice with landing-pad action
  substitution, callee allocas appended as `Alloca::inlined`, outgoing areas merged; sites
  weighed by the JIT records' counts; small callees specialized to constant arguments first
  (`specialize`: the entry parameters' uses replaced by constants, then the passes); across
  images (`rebase`: the callee's `RefAddr`s and handler address arguments become 64-bit
  constants or a load through a symbol's value, its calls the JIT's call forms) and through
  symbols holding a VM function's entry. The splice lemma (§E.6) plus a rule for the
  specialization and for `rebase` (the pool-identity question, §E.6). ("Inline same-image
  calls in the JIT's SSA pipeline"; "Weigh inlining by the counters and specialize callees to
  constants"; "Inline across images in the JIT's SSA pipeline".) `rebase` also carries an
  island (a call of its address in the JIT's call form: `Island::isl` a `CallTarget`), a
  `call.sym.ind` (a `Load` of the slot's value, then a `CallTarget::Ptr` call) and a
  handler's code-constant argument (`Arg::Ro`, sparse switch cases: an `Arg::Imm` of its
  address in the callee image's code constants) ("JIT: inline islands, indirect symbol
  calls and sparse switches across images"). A site that an earlier splice pruned (code
  after a callee that never returns, a landing pad no copied call unwinds to) is skipped
  ("JIT inliner: skip call sites an earlier splice pruned"). A callee whose `ret` has more
  parts than the site reads (an sret callee returning its pointer to a site with no results)
  is spliced with the extra parts dropped ("JIT inliner: allow a callee to return parts the
  call doesn't use"). After the first round and the devirtualization after it, one more
  round restricted to the calls devirtualization made direct (`Params::rounds = 2`,
  `inline`'s `only`), charged against the unit as it is ("JIT: inline calls that
  devirtualization made direct").
- **Devirtualization** (`jit::inline::devirt`, `Env::direct`; on the root before and after
  inlining, and on each explored callee's copy): a `Call Ptr` (or tail call) whose callee is
  `RefAddr(Sym(s), false)` becomes a call of `s`; one whose callee is a constant equal to a
  registered image's VM function's AOT entry becomes a direct call of that function. Rule: a
  call through the address of `f`'s AOT entry equals a call of `f` (the entry dispatches to
  the JIT code; arguments, results and unwinding unchanged); a symbol slot is filled once,
  before VM code runs. ("JIT: call constant function pointers directly".)
- **Constant-pool loads** (`jit::opt::lvn`, `jit::opt::ConstMem`, `Image::read_pool`): a
  read with no relocated byte becomes the pool's bits; a whole relocated 8-byte field into
  the pool or the data area the `RefAddr` of its target, one to a function or native symbol
  its bits; partial reads of a relocated field, reads past the pool, and the data area are
  not folded; a constant address into another image's pool (`RtApi::image_at`) gives
  integers (as `rebase`). `const` of at most `MAX_COPY` bytes decodes as a block copy from
  the pool (`Side::Pool`), cut at its relocated fields. Rule: an immutable allocation's read
  equals its `world` bytes (stores to it are UB, `Ryo/Proofs/Provenance.lean`'s
  constant-load lemma), and the copy pieces equal the handler's footprint. ("JIT: fold loads
  from the constant pool".)
- **SIMD** (`Op::V`, `Op::VConst`): `vsplat`/`veq`/`vlt.s`/`vmsb.i8x16` and
  `and`/`or`/`xor.w128` as 16-byte IR values (so R-SSA values also have 16 bytes), vector
  fields of allocas promoted, copies cut into 16-byte pieces over them, an `xmm` register
  class (none live across a call; on PE only `xmm0`–`xmm5`), 16-byte spill slots and OSR
  loads, SSE2 emission; the folds `vmsb(vlt.s(x, 0)) = vmsb(x)`, half/pair and constant
  folds, the splat hoist (`opt::hoist`), and LVN reassembling a value from its shifted
  pieces. Rules against `opSem`'s vector handlers (`bv_decide`). ("JIT SSA: native SSE2 for
  the SIMD instructions".)
- **Division and variable shifts**: the `div`/`rem` and variable-shift handlers decode as
  native `BinOp`s (`DivS`/`DivU`/`RemS`/`RemU`; shift amounts masked to the width), allocated
  with fixed-register clobbers (`regalloc::clobbers`). Rule: the op equals `opSem` where the
  handler doesn't trap (division by zero and `MIN / -1` stay checked before). ("JIT SSA: fixed
  registers for div, rem, variable shifts and mul".) Likewise `rotl.wN`/`rotr.wN` (and the
  inline forms the decoder takes as them) as `BinOp::Rotl`/`Rotr` at `w` bytes, the 4-byte
  amount extended or truncated to `w` and taken modulo the width, emitted as `rol`/`ror r,
  cl` with `rcx` a fixed clobber, or the immediate rotate for a constant amount; rule as for
  the shifts ("JIT SSA: native rotates"). Of the AOT inline forms, the SSA pipeline takes only the
  variable shifts, rotates and division as their handler calls (`asm::ssa_as_handler`).
- **Native bit ops and compares** (instead of handler calls; `Op::fold` folds constants):
  `bswap.w16-w64` as `Op::Bswap(w)` (`bswap r`; at 16 bits the 32-bit swap and `shr 16`;
  "JIT SSA: bswap"); `cttz`/`ctlz` (W8–W64) as `Op::Count { lz, w }`, a 4-byte count, emitted
  as the AOT form (`bsf`/`bsr` with `cmovz`, or the guard bit for 8/16-bit `cttz`; `ctlz`'s
  `xor` by N-1; "JIT SSA: cttz and ctlz"); `switch.dense.w8-w64` as `Op::SwitchIdx { w,
  base, n }` (`(s - base) mod 2^N`, or `n` if not below `n`; 8 bytes) feeding `Term::Switch`,
  emitted as `sub`/`cmp`/`cmovae` ("JIT SSA: dense switch index"); `cmp3.s/u.w8-w64` as
  `Op::Cmp3(signed, w)`, a byte, emitted as `cmp`, `setl`/`setb` into `r10b`,
  `setg`/`seta`, `sub`, with LVN folding `x <=> x` ("JIT SSA: cmp3"). Rule: each op equals
  `opSem` of its handler at the op's result width (`cmp3` writes 1 byte, `cttz`/`ctlz` 4),
  and its emission is the AOT inline class's sequence, so the emission template reuses that
  class's `Sound` lemma (`Ryo/Proofs/Inline.lean`, still open for these classes).
- **Frame cut, end pointers** (`jit/alloca.rs`): an `addr` at an escaped object's end is
  joined to that object's alloca (the one escaping at that `addr`, unless one escaping there
  starts at that address; with none escaping there, any escaped object ending there), so the
  one-past-the-end pointer keeps its place under any layout. For the checker comparing the
  frame-object tables, R's table must join it the same way. ("JIT: keep end pointers with
  their escaped object".)
- **PE frames**: SSA frames on PE treat `rdi`/`rsi` as callee-saved like `rbx` and
  `r12`–`r15` (saved only when used, no fixed slots), push only `rbp` before the saves, set
  `rbp` by `lea rbp, [rsp + K]` (`K = 8n` rounded to 16), store saves that can't be pushed
  into the caller's home space or free slots within 240 bytes below `rbp`, give calls 32
  bytes of shadow space and use the Win64 argument registers, described by a PE
  `UNWIND_INFO` from `image::pe_unwind_codes` (shared with the AOT `pe_unwind_info`). Handler
  calls take the Win64 positions (a fifth argument as `mov [rsp + 32], r11d`), calls clobber
  only Win64's volatile registers, and register entries take at most four arguments and
  return two values in `xmm0`, moved to `rax`/`rdx` after the call. The Lean unwind model
  (`Ryo/Obj/Unwind.lean`) covers only ELF `.eh_frame`; LIR → L2+ emission on PE needs the
  Win64 frame, the Win64 handler and register-entry conventions (the handler contract's
  register clauses, [assumptions.md](assumptions.md) §6, per platform ABI) and an
  `UNWIND_INFO` reader. ("JIT SSA: compile PE code with Win64 frames"; "Asm, Rt, JIT,
  Backend: Win64 handlers on PE".)
- **Promotion** (`jit::opt::promote`): allocas whose address no longer escapes, also when
  accessed at overlapping widths: fields are the pieces the accesses' bounds cut (power-of-two
  widths); a store covering several pieces stores each (shifted down), a load covering several
  combines them (zero-extended, shifted, or'ed; an undefined piece reads zero). Step 2's
  dominance relation, per piece; the zero for an undefined piece refines `Uninit`. ("Inline
  same-image calls…"; "JIT SSA: scalar replacement of mixed-width allocas".)
- **Check elimination** (`jit::opt::checks`, after the folds): a dominator-tree walk with
  range and `a < b` facts from single-predecessor branch edges turns `Ovf` ops that can't
  overflow into `Bin` (flag constant 0, `BrOvf` a jump) and folds the compares and
  compare-branches the facts decide. A validator per fold: the fact holds on the edge, and
  implies the fold (`bv_decide`). ("JIT: eliminate checks dominating branches decide".)
- **Bit-count folds** (LVN): a register-entry `ctpop` handler call (W8 to W64, no site) of a
  constant folds to the handler's count, and `Op::Count` of a constant through `Op::fold`
  (`ctlz`/`cttz` of 0 the width): a rewrite rule against `opSem`'s bit counts. ("JIT SSA:
  fold bit counts of constants"; "JIT SSA: cttz and ctlz".)
- **Loop-invariant code motion** (`jit::opt::hoist`, after `opt::checks`; general only with
  `RYO_JIT_LICM=1`, otherwise only the `vsplat` hoist above): pure operations, loads nothing
  in the loop may write, and divisions, loads through pointers and effect-free handler calls
  only where they run whenever the head does, move to the head's entry predecessor or a new
  preheader. At a head with an OSR entry the value becomes a new head parameter, recomputed
  for the entry in a *landing* block between the entry and the head (`osr::osr_landing`; its
  edge is the OSR edge, `osr_edge`; `osr::through_landings` passes the entry values it uses
  as its parameters after promotion); `simplify` never merges a block into an OSR entry.
  Rules: availability for the moved values (step 3), the fault condition (a hoisted
  faulting op runs whenever the head does), and for the landing, that the recomputed value
  equals the normal edges' at the head (invariant parameters are their normal value there;
  a load nothing in the loop writes reads the same bytes), so step 7's relation holds at
  the landing's target. ("JIT SSA: loop-invariant code motion, with OSR landings".)
- **Loop rotation** (`jit::opt::rotate`, only with `RYO_JIT_ROTATE=1`, once after
  `opt::run`'s last round, before `regalloc::remat`): a head that is only a compare branch
  gets the branch copied to the end of its one latch, which then branches to the body or
  the exit; the body and exit blocks take the head's values as new parameters. The head
  stays, and the OSR entry still targets it. Rule: a block duplication with SSA repair
  (per-block symbolic evaluation; the copied branch reads the latch's arguments for the
  head's parameters). ("JIT SSA: Loop rotation behind RYO_JIT_ROTATE".)

**`cpuid`.** The theorem is relative to the CPU having the logged features: the generic
decoder accepts a form only if its feature is in the set, and L2+ faults on a form whose
feature is absent. Validate per feature set the corpus runs on (at least: baseline x86-64
and the development machine's set).

## E.5 OSR and unwinding in the SSA pipeline

- **OSR entries** are extra CFG entries at the root's AOT heads: blocks with no
  predecessors whose reads of variables are `osr.load`s of the AOT slots. The construction
  certificate covers them; `osr_entry_sound`'s obligation is that the entry block
  establishes the relation from the AOT frame. The emitted entry reads everything it needs
  from the AOT frame into a scratch area below both frames before writing the JIT frame, so
  the two layouts may overlap. Inlined callees' heads are ordinary blocks, so they add no
  OSR obligation. With LICM the entry's target may be a *landing* (`osr::osr_landing`), not
  the head: a block only the entry reaches that computes the hoisted head parameters from
  the entry's values, then jumps to the head; the obligation is then that the entry plus its
  landing establish the relation at the head. Loop rotation keeps the entry on the head.
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
folded: a load of a relocated field reads the pointer a `RefAddr` of its target makes
(`fold_load_reloc`, `store_immutable`; [reduced.md](reduced.md) §C0.7, "Image and
environment"). D7 lets the source pick a const's copy; constants from image B folded into a
unit of image A as 64-bit integers (`rebase`) are sound because every image part is exposed
(`drop_exposed_mono`), so a `Ref` need not carry its image for soundness, only for the
validator to recompute the address.

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
  handlers. Done: `Ryo/Vm/OpSem/JitEffects.lean` maps every footprint to the JIT's vocabulary
  (fences' `memory` and `resume`'s entry, which the footprints can't express, explicitly) and
  `ryo-lean effects` writes it as `vm/bytecode/src/jit/effects_table.rs`, which
  `jit::effects` reads; `y lean gen` regenerates it and `y lean` fails if it is stale.
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
- `RYO_JIT_SHUFFLE=1`, and each inlining and optimization level of the SSA pipeline

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
