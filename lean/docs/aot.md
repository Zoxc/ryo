# Part C. MIR → x86 for AOT code

How the machine code `rustc-ryo` emits is related to the MIR it came from: the lowering
check C1' (L0 → R), the verified decoder (bytes → R), the image checks for every other byte
of the image object, and the AOT theorems that compose them. R itself, with its provenance
and frame layouts, is in [reduced.md](reduced.md). `Dn` are the divergences of L0 from
MiniRust ([mir-spec.md](mir-spec.md) §A.7); milestones `Mn` are in [plan.md](plan.md#3-milestones).

## C1. L0 → R: the lowering, by translation validation (C1')

**Input**: the R program `P` that the verified Lean decoder read from the function's bytes in
the image object (§C2), not a dump of the code, and not words. Together with the dumped MIR
body and the certificate.

**Certificate** (dumped by the backend, untrusted):

- the frame map: local → slot offset, `F`, temporaries' range, exception slot, sret slot,
  homes of ABI inputs and spread fields; the frame-object table of R
  ([reduced.md](reduced.md) §C0.2)
- per MIR statement and terminator, the range of R instructions it produced. One
  `Asm::insn` gives exactly one R instruction (`reduce` maps each full instruction to one
  native op or one `handler`), so `InsnId`s are R indices. Counters, stubs and padding are
  dropped by the decoder and never appear in ranges. Per block its label.
- the `ArgPlan` per call and for the function's own signature (`sig.rs`)
- the resolved callee kind per call (VM `call`, `call.sym`, `call.ptr`, `virtual`, which
  island template and `ops`)

Relocation targets are not in the certificate: the checker reads them from the object and
resolves names itself (§C4).

**Relational spec** (`Ryo/Check/Lower/*.lean`): an inductive relation per syntactic class,
mirroring [lowering.md](../../design/lowering.md), over the op view, so the lowering's tables (binop, cast, rvalue) are
written in full-opcode terms:

- `LowerPlace Γ place → PlaceCode` (slot `off_n + k`, `[slot_n + k]`, computed pointer via
  `ptr.index`/`ptr.add` into a temporary, unsized tails)
- `LowerOperand`, `LowerRvalue Γ dst rv insns` (the cases of the rvalue, cast and binop
  tables)
- `LowerStmt`, `LowerTerm` (fused compare-branches, switches, `Assert`, `Drop`, calls, tail
  calls, unwind entries, landing pads, terminate stubs)
- `LowerProlog` (`arg`s, stack pieces, `Indirect` copies)

Rules leave freedom where the backend has it (which temporary, which equivalent instruction
form), so backend refactors don't break the checker. A `view i = none` makes the checker
reject (coverage reports it). The **checker** (`Ryo/Check/Lower/Decide.lean`) decides the
relation using the certificate. `check_sound : check Γ body P = ok → LowersFn Γ body P`.

**Simulation** (`Ryo/Proofs/LowerSim.lean`): `LowersFn Γ body P → FnSim conv body P`, a
forward simulation L0 → R, made backward by determinism of R modulo the environment. The
per-frame relation `R_Γ (s0 : L0 frame) (s1 : R frame)`:

- **pc**: MIR `(bb, i)` ↔ the first instruction of statement `i`'s range.
- **Locals**: the proof is for every valid layout `φ` of R's frame objects. Every
  storage-live local `l` has address `φ(o_l) + (off_l - off_{o_l})` in L0. The simulation
  picks it at `StorageLive` and frame entry, which is valid because the daemonic address
  choice only needs alignment and no overlap with live allocations (the checker validates
  that conflicting locals' slots are disjoint: the backend's storage-liveness dataflow,
  recomputed in Lean), and `φ` is known from function entry.
  - If `l` is escaped, its L0 allocation corresponds to the R allocation of its frame object
    (the `AllocId` renaming `ι`), from the escape to the end. If it is not escaped, its L0
    allocation is unreferenced: no provenance for it occurs in the L0 state, because the
    checker validated that escapes cover every `addr` and by-address argument, but for the
    two exceptions of R's `addr` ([reduced.md](reduced.md) §C0.3). A zero-sized local's L0
    allocation is mapped by `ι` to *no* provenance (R's pointer to a zero-sized object has
    none): an L0 pointer with that provenance relates to the R pointer with the same address
    and no provenance, which MiniRust's `≤def` alone doesn't allow, so the relation adds it
    for these allocations. That is sound because L0 can use that provenance only where it
    doesn't matter: every access through it of non-zero size is out of bounds (UB), size-0
    accesses need no provenance at either level, comparisons and casts to integers see the
    address, an in-bounds `offset` from it moves by 0, and `offset_from` is integer arithmetic
    in R (`sub`, `div`), with L0's same-allocation requirement only adding UB on the source
    side. A pointer at an escaped local's end (a zero-sized field there) has the local's
    provenance at both levels.
  - If `l` is escaped or *semantically live* (read later before being overwritten; liveness
    recomputed in Lean), then the L0 bytes `≤def` the R bytes of its slot, provenance mapped
    through `ι`.
  - Locals that are dead in that sense may differ. This covers the fused compare whose
    `bool` is never stored, and `dead_after_read`.
- **Temporaries**: unconstrained between statements.
- **Memory outside frames**: the same allocations (environment allocations correspond to
  themselves), L0 bytes `≤def` R bytes at the same addresses, provenance mapped through
  `ι`. Both levels use `Ryo/Spec/Mem`, so this is MiniRust's "more defined" order up to a
  renaming of `AllocId`s; its lemmas live next to `Ryo/Spec/Mem/Refine.lean`, and the JIT
  part reuses them.
- **Globals**:
  - each L0 const allocation is mapped by `ι` to its pool copy's R allocation (D7 lets the
    source choose the copy); the pool check (§C4) proves the copy holds the allocation
  - vtables to their pool copies (D29), checked the same way
  - statics and symbol slots to the linked addresses (the static's bytes are cg_llvm's)
  - fn pointers to symbol addresses (D6)
- **Calls**: the **ABI convention** `AbiConv plan (vals, mem0) (regs, stack, mem1)`. The
  checker validates the call's argument list and outgoing-area stores against the plan, and
  the convention lemma does the rest. `Indirect` args point at a temporary copy, which
  refines D12's in-place passing. sret: the destination address in the first integer
  register; R makes the destination's `ret_size` bytes `Uninit` at the call
  ([reduced.md](reduced.md) §C0.4), as D12 does L0's, which keeps `≤def` if `ret_size` is the
  return type's size and the destination is disjoint from the call's by-address argument
  copies and its outgoing area (what the callee reads after the call starts). Callees:
  `Sym s` must be the symbol of the callee the dump names (`tcx.symbol_name`), `Func i` that
  callee's function-table entry.
- **Unwinding**: L0 `unwind` from a callee ↔ R landing at the call's cleanup entry, `lpad x`
  storing the exception object in slot `x`, `resume x` ↔ `UnwindResume`. Terminate pads ↔
  D18's lang-item call. `UnwindAction::Unreachable` ↔ no call-site entry (L0 UB, so
  anything goes).
- **Islands**: each template family has a **contract** at R (`Ryo/Vm/R/Islands.lean`): which
  slots it reads at which types, which it writes, and which L0 operation it performs.
  - `call`: the FnOnce call of `F` with the argument tuple.
  - `call_cN`: external C call through the fn-pointer slot.
  - `drop_in_place`: call of the drop glue.
  - intrinsic wrappers: the D20 intrinsic.
  - `as_cast`, 128-bit arithmetic: the L0 op.
  - `catch_unwind`: D18.

  Trusted (§C6). The C1' rule checks that the `island` instruction's symbol is the template
  instance the dump names, that the `ops` array (read from the object's `.rodata`) is
  what the contract requires, and that each operand's `Lend` scope is the extent the
  contract accesses, an operand without one being zero-sized (the dead-store check, §C2,
  relies on it). The file has the operand roles so far (per template and `ops` position: read,
  only written, or unused), which the dead-store check uses; the types and L0 operations are
  to come.
- **Escape/storage side data**: the checker verifies that `Scope` escapes cover every `addr`
  and every by-address argument, and that ends match `StorageDead`. Covered means: the slot
  is in an object escaped on every path to the instruction, with exactly two exceptions,
  which R's `addr` gives a meaning ([reduced.md](reduced.md) §C0.3): the slot is the end of
  such an object (one past the end: the backend takes the address of a zero-sized last
  field of an escaped local, `&l.f`), or it is a local the certificate gives size 0 (a
  zero-sized local, which never escapes). The second relies on the frame map's sizes,
  which C1' must check against the body's layouts; and for the first, the relational spec
  must check that the place is the end of the escaped object's own local, and that no other
  object escaped there starts at that address (R would give the pointer the other object's
  provenance, and a step back from it would be UB in R but not in L0). This is what makes R's
  allocation lifetimes (escape to end) match L0's provenance, so frame privacy holds for the
  R program, and it is what the JIT relies on ([jit.md](jit.md) §E.7).
- **Composition**: VM→VM calls use the same convention as calls to native code, so each
  function is verified on its own. The whole-program theorem composes them under the
  convention (CompCertO-style vertical and horizontal composition), assuming native code
  (LLVM-compiled MIR, libc) refines its own semantics under the same convention. There are
  no portals ([stubs.md](../../design/stubs.md)), so native callers need no extra stage.

**Lowering forms the rules must cover** (beyond the obvious one per MIR construct; added as
the backend gained them):

- Unsigned `/` and `%` by a constant `2^k`: `shr.u.imm x, k` and `and.imm x, 2^k - 1`, not
  `div.u`/`rem.u` (binary operations). ("Lower unsigned div/rem by a power of two to shifts
  and masks".)
- A `SwitchInt` with exactly two values: a `br.eq.imm` per value plus a `jmp` (the second
  test omitted when `otherwise` is an empty unreachable block, or negated to fall through),
  not `switch.dense` (terminators). ("Lower two-case switches to compare-and-branch".)
- Block copies and zeroing of at most 48 bytes that aren't one scalar width (`copy`,
  `load.copy`, `store.copy`, `zero`): `mov.wN`/`load.wN`/`store.wN`/`imm.wN 0` pieces cut at
  the value's scalar field offsets (the widest piece that fits and straddles no field start);
  slot to slot only when the ranges don't overlap, `load` only when no piece overwrites the
  pointer slot. Rule: an aggregate assignment of `n` bytes equals its pieces, given those two
  side conditions (piecewise copying of overlapping ranges or through the overwritten pointer
  would differ). ("Lower small block copies and zeroing to scalar pieces".)
- Niche discriminants (`FnCx::niche_discr`): the plain-op decoding is proved against
  `tagToVariant` (`Ryo/Proofs/NicheDiscr.lean`, `nicheDiscr_sound`, on a model of the
  lowering); the fused form (a `SwitchInt` testing the tag with `br.eq.imm`, or `sub.imm` +
  `br.gt.u.imm` + `switch.dense` past 4 arms) is not, and nothing checks the model against
  the emitted ops.

**Incremental coverage**: the checker reports per function `validated | unsupported(rule) |
rejected(reason)`, totalled like `RYO_STATS`. `rejected` is a bug in the backend or the
checker. `y test` fails on `rejected` and prints coverage.

**Implemented: the certificate check** (`Ryo/Check/Lower/`, `ryo-lean check-cert <dump>
<cert> <image objects>...`, over the corpus with `scripts/lean-cert-check.py`). The backend
writes the certificate next to the dump (`RYO_DUMP_LEAN`, `<crate>.cert.json`: per VM function
the frame map, its own `ArgPlan`, the ranges, and per call instruction its kind, return kind
and size and the callee's `ArgPlan`; the islands' templates by symbol). The check, short of
the relational spec: each image function has exactly one certificate (by symbol) and each
certificate a function. Own signature: `argSize = plan.stackSize = FuncEntry.arg_size`,
`ret_kind` the entry's, the frame size the decoded one, an sret slot iff `RET_SRET`, and the
`arg` instructions are exactly the prologue's, the plan's register pieces in order; for a
dumped body with an ABI, the return kind and plan recomputed from the dumped `FnAbiSummary`
(`Plan.lean`, a port of `sig.rs`'s `arg_plan` and `ret_kind` for SysV and Win64, from each
argument's `PassMode` and LLVM-level scalars, `ArgAbi.scalars`) are the certificate's and
`ret_size` is the ABI's, and the locals, spread argument and caller location agree with the
body. Ranges: prologue, blocks, stubs and pads are consecutive and cover the code, one block
per MIR block with its statement count (the fused compare counted; blocks the dumper
truncated are skipped). Calls: one entry per `call*`/`tail_call*` instruction, the kind fits
the opcode, `k` is the return kind, and the argument list's register words (and the slots
the certificate fixes, and one home per input) are what `pass_args` builds from the plan. A
call's plan is then verified by the callee's `FuncEntry` (a `Ref.func` callee: `arg_size`,
`ret_kind`, sret `ret_size`, and the callee's own certificate plan), or by the dump (the one
call of a `call`/`tailCall` terminator with an ABI, of a `drop` of glue with a body, of an
`assert` of a panic function with a body: plan, return kind and size recomputed from that
ABI), or by neither; calls of `ext` lang items (assert panics, terminate stubs, whose ABI the
dump doesn't give) and calls in functions outside the dump are the latter. Islands: each
`island`'s symbol is in the islands table. Escape coverage: every address taken (an `addr`'s
slot, each `ARG_ADDR` argument of a call) is in an object escaped on every path to it (a
forward must-dataflow over the scopes, `Frame.mustEscapedAt`), at the end of one, or at a
local of size 0, and nothing else (corpus: 14219, 26 and 383 of 14628, 0 uncovered). The verified calls' stack-argument and sret sizes
and the islands' templates are `Frame.Facts` for the dead-store check (§C2); they hold given
what the rest of C1' checks (that each call lowers the terminator whose range it is in, and
that each island symbol is the template instance the dump names). Remaining: the relational
spec itself (`LowerPlace` … `LowerProlog`), the frame map against the body's locals and
storage, the stack pieces and `Indirect` copies, unwind actions and landing pads.

## C2. Bytes → R: `decodeReduced` and `decode_sound` (proved once)

Rather than relating the Rust encoder to anything, prove the **Lean decoder** correct:

`decode_sound : decodeReduced mode code side relocs = some P → L2Sim (code @ addr) P`

stated directly for `R(φ_AOT)`, with provenance erased (L2 memory is flat; R's provenance
checks only add UB on the R side). The decoder reads the function's bytes from the object's text
section (located by its symbol and `FuncEntry`), the `.rodata` parts the code reads (island
`ops` arrays, sparse-switch values, jump tables), the image's side data (call sites, and
the function's instruction list: scopes, dropped stores, branch targets), the LSDA, and the relocation list. All from the object, not from
`RYO_DUMP_CODE` and not from a Rust re-serialization (§C4 has the ELF reader). The proof
follows the decoder's structure:

- **Shapes**: for each shape (`op` handler call, `br`, `switch`, `trap`, `ret`, `arg`, `jmp`,
  `call*`, `tail_call*`, `island`, `lpad`), a lemma: from a state related to the R state,
  executing the canonical sequence reaches the related successor. Handler calls use `H h`.
- **Inline sequences** (`asm::inline`): per opcode × width × operand pattern, the sequence's
  effect equals `opSem op ops`. These are `BitVec` goals: `bv_decide` and `simp`, with most
  cases generated by tactic. High value, low cost: the inline sequences are where encoding
  bugs live.

  **Implemented** (`Ryo/Proofs/Inline.lean`, `inline_sound`): for every class but `load` and
  `store`, at every width and condition (`mov`, `mov128`, `imm`, `addr`, `ptrAdd`, `ptrIndex`,
  `bin`, `binImm`, `mul`, `mulImm`, `shiftImm`, `cmp`, `cmpImm`, `br`, `brCmp`, `brCmpImm`;
  both immediate forms where `fits` decides), and every opcode of the class's handler shape
  (`shapeOk`): if `sequence c ops = some (items, br)`, `opSem op vals st` succeeds (`vals` the
  operand values `view` gives) and `Rel st x`, then `execItems items x` succeeds with `x'` and
  `Rel st' x'`; `st'` differs from `st` only in private frame bytes; only `rax`, `rcx`, the
  flags and `rip` (past the items) changed; x86 memory changed only in the footprint's write
  ranges; and the control is `next`, or `branch b` with `br` holding on the flags iff
  `b != neg`. `Rel` (§C0.7 of [reduced.md](reduced.md)): every frame byte `opSem` reads
  (`byteAt`: private or escaped) relates to the byte at `rbp + off` (initialized bytes equal,
  provenance erased, `Uninit` anything), and escaped objects are at `rbp + off`. Side
  condition: the written range is private (`Private`). Proofs are per handler kind for
  `opSem` (`Inline/OpSem.lean`), then per width by `simp` and `bv_decide`. `load` and `store`
  (memory through a pointer) are `sound_load`/`sound_store` (`Inline/Mem.lean`), given the
  memory part of the relation (`MemRel`: live allocations' bytes at their addresses), private
  frame bytes outside every allocation (`FrameApart`) and, for `store`, allocations disjoint in
  the address space (`MemDisjoint`). The link to the opcodes,
  `(op, c) ∈ inlineOps → shapeOk op c`, is `inlineOps_shape` (`RyoProofs/InlineOps.lean`, in
  its own library `RyoProofs`, outside the default build: about 3.5 minutes): `decide +kernel`
  over the generated mnemonics as character lists (`Generated/Mnemonics.lean`), with
  `String.splitOn` replaced by a fuelled split proved equal to it; it covers all 222 inline
  opcodes, the native `ovf`, `mulOvf`, `ext`, `addr.const`, `addr.sym` and `addr.sym.ind`
  ones included, and uses no `bv_decide` or `native_decide`. Left: writes into escaped
  objects (`writeEscaped`), and the sequences of `ovf`, `mulOvf` and `ext`, and of the
  rip-relative addresses `addrConst` (`lea r, [rip + k]`), `addrSym` (`mov r, [rip + slot]`)
  and `addrSymInd` (one more `mov r, [r]`), each then `mov [fp + d], r`, which need the
  relation to say where constants, data and symbol slots are (lean/PENDING.md, "proofs to
  extend"). No mismatch between the
  sequences and `opSem` was found. `bv_decide`'s proofs are axioms checked by compiled code
  ([assumptions.md](assumptions.md) §1.4).
- **Register cache**: invariant `CacheInv c regs mem fp`: for each `(r, slot, width) ∈ c`,
  `regs r = zext (mem[fp+slot, width])`. The decoder runs the same cache (as the Rust one
  does). The lemmas show each sequence preserves it, and that targets, non-inline
  instructions, overlapping writes and stores through pointers clear it as
  [vm.md](../../design/vm.md#register-cache) describes.
- **Dropped stores**: the relation lets the L2 frame differ from R on bytes whose store was
  dropped, until overwritten. The Lean decoder **checks** each dropped store's deadness by a
  backward liveness over the decoded code (`Frame.decodeChecked`). Handlers read and write
  their operands at `opSem`'s footprints ([reduced.md](reduced.md) §C0.5); calls read their
  argument list, and if the convention allows stack arguments (argument registers ran out)
  the callee's stack-argument extent of the outgoing area, or every byte where it isn't
  known; islands read their operands' `Lend` extents (none for a zero-sized
  operand, for which the encoder records no `Lend`) and, taking `fp` and calling anything,
  make a pointer access, assuming the island
  contract's operand footprint is the `Lend` extent (C1' checks it against the template,
  §C1 "Islands"; [reduced.md](reduced.md) §C0.1); pointer accesses read the objects that may be
  escaped there (an `Escape` scope reaching it without an `End`); an `End` makes its bytes
  `Uninit` (reduced.md §C0.3), so they are dead before it. The Rust decoder trusts the `dropped` list;
  the Lean one must not. Three refinements take facts from outside the function
  (`Frame.Facts`):
  - **Stack-argument extents.** For a `call` of an image function, its `arg_size`, once the
    callee's own decoded code is shown to access its incoming area only within those bytes
    (extents, escapes and tail calls included: `Frame.incomingExtents`); for `call.sym` and
    `call.ptr`, the `ArgPlan`'s stack size from the certificate (C1').
  - **sret destinations.** A call makes its sret destination `Uninit` once it has read its
    arguments (reduced.md §C0.4), so a store there is dead unless the call passes those bytes
    itself. The size is the callee's `ret_size` (an image function's `FuncEntry`; C1' must
    check it against the signature) or the certificate's.
  - **Island destinations.** With the island's template known (its symbol, from the
    certificate), the contract's operand roles (`Ryo/Vm/R/Islands.lean`, trusted with the
    rest of the contract, §C6): a `Lend` only unread operands sit at isn't read, and one only
    destinations sit at is written whole on the fall-through.

  Known rejections: `call.sym`/`call.ptr` calls that may have stack arguments, without the
  certificate; stores into an object escaped at a later pointer access only along other
  paths (the escape dataflow is path-insensitive); and stale bytes a whole-object copy moves
  but nothing uses.
- **Counters and stubs**: `inc [rip+ctr_e|ctr_l]; jns stub` followed by the stub
  `lea r11,[rip+rec]; …; call [r11+8|16]; jmp back` refines a no-op, given the trip contract
  ([jit.md](jit.md) §E.2). Counter memory is runtime-owned: excluded from the program's
  memory relation.
- **Prologue, epilogue, probe**: the `ryo_probe_stack` contract; the prologue establishes
  `fp` and `F` as the FDE says (§C4 checks the FDE against it).
- **Branch relaxation, padding, jump tables**: handled by the decoder (targets are positions),
  so they need no proof of their own beyond `decodeItem`'s.
- **Unwinding**: the LSDA call-site table (ported `asm::lsda::parse`) maps call sites to
  landing pads, and must agree with the image's call-site table. The unwinder model restores
  `rsp = fp - F` (and `rbp`) at the pad, as the function's FDE rows say; §C4 checks those
  rows, so the remaining assumption is only that the unwinder interprets CFI per DWARF.

Linked mode: the same decoder takes a `LinkMap` (handler addresses, image ranges, records),
the resolver Rust's `decode_linked` has. It is what the JIT validator uses for the JIT's
input ([jit.md](jit.md)), and what the linked-binary check uses (§C4).

The **Rust** `asm::decode_reduced` is not needed for any guarantee: every pipeline that uses
it is validated from bytes (AOT: C1' on the Lean decoding; JIT: Lean decodes the same logged
bytes). Cross-check it differentially against the Lean decoder over the corpus to find bugs
early. If the JIT's guarantee should ever hold at run time without validation, that is when
to Aeneas-extract it ([jit.md](jit.md) §E.9).

## C3. Readers: the ELF object and the image

`Ryo/Obj/*.lean`, executable, small, tested against `object`/`readelf` over the corpus:

- **ELF**: section headers, symbol table, `RELA` sections (`R_X86_64_64`, `PC32`, `PLT32`;
  anything else rejects), section flags.
- **Image**: the read-only section's header, function table, instruction lists
  (`Ryo/Obj/List.lean`, `asm::list`) and call-site table, code constants, symbol slots and flags, constant pool; the writable section's JIT records.
  A Lean port of `Image::parse`/`validate`'s bounds and alignment checks. Per function, the
  decoder's inputs (`Ryo/Obj/Reloc.lean`): the code, its relocations as `Ref`s (the inverse of
  the writer's mapping), the code constants, call sites, scopes, dropped stores and the mode.
  Calls between the image's functions carry no relocation (the writer resolves them), so the
  decoder reads an unrelocated `rel32` field that leaves the function, or targets its first
  byte, as `Ref.func` of the function starting there, as `decode_linked` does; and `Ref.ro`
  offsets are the image's code-constant offsets, since the image doesn't record each
  function's part. `scripts/lean-decode-diff.py` diffs the readers against
  `scripts/lean-decode-ref` (Rust: `object`, `Image`, `ImageResolver::decode` on the object
  linked in memory) and `readelf`.
- **Unwind** (`Ryo/Obj/EhFrame.lean`, `Lsda.lean`, `Unwind.lean`): `.eh_frame`'s CIEs
  (version 1, `z` + `P`/`L`/`R`, pointers `pcrel|sdata4`, the personality also `indirect`) and
  FDEs, with the CFA instructions ryo emits (`advance_loc*`, `def_cfa*`, `offset`, `restore`,
  `nop`; anything else rejects) evaluated into row tables; pointer fields resolved through
  their `R_X86_64_PC32` relocations to (section, offset). `.gcc_except_table`: `Lsda.parse`
  and `write`, ports of `asm::lsda`'s with the same acceptance. Per image function, its FDE
  (the one starting at its `code_off` in the text) and its LSDA (up to the next one), compared
  with the image's call-site table. `ryo-lean ehframe` is diffed against `readelf
  --debug-dump=frames` and `frames-interp` (header fields, augmentation data with the
  relocated pointers, rows), and `ryo-lean lsda` against `lean-decode-ref lsda` (Rust's
  `lsda::parse`, the FDEs found by walking `.eh_frame`'s lengths and relocations), with
  `scripts/lean-decode-diff.py --unwind` (`--frame-pointer` adds the frame-pointer mode); the
  FDE row tables of `image::eh_fde` in both modes are unit-tested against the rules it
  documents (`RyoTest/Unwind.lean`, vectors from `vm/bytecode/tests/lean_unwind_vectors.rs`).

These are trusted only as far as "the parse matches the ELF/DWARF spec"; their outputs are
compared against `readelf` (and Rust's readers) in tests.

## C4. Image checks: the rest of the emitted object

Everything the backend emits into an image or registry object, with what checks it. "C1'"
and "decode" mean §C1/§C2; the rest are new checks in `Ryo/Check/Image/`, run with C1' at
`y test` time, per object.

| Emitted | Check | What remains trusted |
|---|---|---|
| VM function text: body, prologue/epilogue, landing-pad stubs, counter checks and stubs, alignment `nop`s | decode + C1' | the trip contract (stubs); inter-function padding is never executed (checked: no decoded target lands in it) |
| `.rodata` parts read by code (island `ops` arrays, switch values, jump tables) | decode reads them from the object; C1' checks the `ops` against the island contract | — |
| **Constant pool** (const allocations, promoted consts, `Bytes`) | for each `Const` the code (or another pool entry) references: the pool bytes at that offset equal the dumped rustc allocation's bytes, its relocations (the object's `R_X86_64_64` into the pool or against symbols) are exactly the allocation's provenance (target allocation at the same offset, or the symbol of the static/fn the dump names), its alignment holds, and it lies in the RELRO section (D7: consts are immutable; the JIT's devirtualization relies on it). Uninit bytes in the allocation may be anything | — (the backend's `Pool::intern` is no longer trusted) |
| **Vtables** | the same check against the dumped `vtable_allocation` (D29: `[drop_in_place, size, align, entries…]`, entries as symbol relocations to the instances the dump names; `drop_in_place` null for types without drop glue, as rustc's `vtable_allocation` has it) | — |
| **Function symbols and the function table** | each `FuncEntry` (`code_off`, `code_len`) covers exactly the code that was decoded, in table order; each function symbol (global or local) is at its entry's `code_off` with its `code_len`; the symbol name is the dump's `tcx.symbol_name` for that instance; `arg_size`, `ret_size`, `ret_kind` agree with the signature's `ArgPlan`; the instruction-list and call-site spans are the ones decode used. The runtime and JIT read these, so check them, don't trust them | — |
| **Relocations** of the text and the read-only section | every relocated field the decoder met has a relocation of the kind its form needs (`Call32` → `ryo_h_<h>` or `ryo_probe_stack`; `Pc32` → a symbol slot, pool offset, data/record offset, rodata; `Abs64` for the header's `text`/`data`, pool pointers, JIT-record initial values → the trip entry points); no relocation outside such fields; names resolve as C1' requires (`Sym s` slot ↔ the callee's symbol) | the linker applies them (see "Linked binary" below) |
| **Symbol slots** (`[u64]`, RELRO) | each slot has exactly one `Abs64` relocation against the symbol `name(s)`, and `SYM_INDIRECT` flags are clear (ELF) | `ld.so` fills them and RELRO makes them read-only after loading |
| **JIT records** (writable: `ctr_e`/`ctr_l`, `entry`/`osr`) | initial counter values, and `Abs64` relocations of `entry`/`osr` to `ryo_jit_trip_entry`/`_osr` | runtime-owned memory, outside the program's memory relation |
| Image header | parsed by the Lean image reader; `text`/`data` relocations checked | `Image::validate` at registration is runtime code (it only rejects) |
| **`.eh_frame` FDEs** (required) | each VM function has exactly one FDE covering `[code_off, +code_len)`, and its rows match what the decoded prologue/epilogue do in that mode (`image::eh_fde`: CFA and saved `rbp`/return address at each prologue position). A handful of fixed shapes per mode, so the check is cheap; it turns the CFI assumption into "the unwinder implements DWARF CFI" | the unwinder |
| `.gcc_except_table` LSDAs | parsed in Lean, checked against the image's call-site table, the decoded `lpad` stubs and C1''s unwind actions | the personality routine |
| **Registry object** (`write_registry`): the constructor `lea rdi,[rip+images]; mov esi,n; jmp ryo_vm_register` in `.text.ryo_registry`, its `.init_array.00000` entry, the image list, `__ryo_registry_anchor` | decode the 3 instructions with the L2 decoder (B.1 extra form); `PC32` → the list, `PLT32` → `ryo_vm_register`; the `.init_array` entry is an `Abs64` to the constructor; the list has one `Abs64` per image symbol of the link, each `__ryo_image_<id>`, no duplicates; `n` equals the list length. Each image's anchor slot references `__ryo_registry_anchor` | `ryo_vm_register` (runtime: trusted contract "registers the images before any VM code runs"); the C runtime runs `.init_array` in priority order |
| **`__ryo_main` slot** | one `Abs64` against the symbol of the entry fn the dump names (`main`'s instance) | — |
| **`c_main`** (`ryo_rt::entry::c_main`, cg_llvm-compiled) | — | native code: loads `__ryo_main` and calls the `start` lang item with it. Ten lines of Rust compiled by LLVM; verifying it means binary verification of LLVM output, which buys little over the native-code assumption every program already has |
| Islands | C1' checks the template instance and `ops` | cg_llvm instances of `ryo_rt` templates: trusted contracts (§C6) |
| Functions the backend leaves native (`NeedsNative`, template gaps), statics | — | LLVM code and data from MIR, under the convention |
| PE (`.pdata`/`.xdata`, fixups, `__imp_` slots) | — | out of scope |

**The pool check** (`Ryo/Check/Image/Pool.lean`, `ryo-lean check-pool`,
`scripts/lean-pool-check.py` over the corpus) implements the two rows above. The pool doesn't
record where each allocation starts, so it matches: a placement "global `g` at pool offset
`b`" holds locally when bytes, alignment and the relocations in `[b, b + size)` agree with
`g`, a pool pointer demanding the placement of its target; valid placements are the greatest
fixpoint over those demands (cycles are fine). Each code reference (`Ref.const k`, with its
use from the decoded `const`/`addr.const`) must be covered by a valid placement of a global its
function's dumped body mentions; `fill` operands are byte constants (C1' checks them), and
references from functions outside the dump are reported, not failed. A static pointer's
relocation names the static's symbol as the dump gives it (`Global.symbol`).
`Ryo/Check/Image/Dump.lean` (also `check-pool`) checks the rest that the dump decides without
the function ↔ instance map: `__ryo_main` exists iff an image function has the entry
instance's symbol, and names it; no image function is a dumped intrinsic. That each
function's and slot's symbol is the instance's the MIR names is C1''s (its certificate maps
functions to instances).

**Implemented: the structural part** (`Ryo/Check/Image/`, `ryo-lean check-image <image
objects>... [--registry <registry object>]`, over the corpus with
`scripts/lean-image-check.py`). Funcs: the function table (16-aligned, in order, covering the
text with only `int3` padding between functions, which the decoder never reaches), the
side-table runs (consecutive, covering their tables), one `STT_FUNC` symbol per entry at its
`code_off` with its `code_len`, and the signature fields the code decides (`ret` kinds, sret
`ret`s from the first argument register's slot, callers' result kinds and tail calls against
the callee's entry, incoming-area accesses within `arg_size`). Relocs: each function decoded
a second time from its unlinked bytes with the object's relocations (`Fields.relocs`, calls
between functions added as `Ref.func` fields), which must succeed and agree with the linked
decode, so every relocation is a field of the form that takes it; relocated fields 0; the
read-only section's relocations only the header's `data`/`text`, one per symbol slot
(`SYM_INDIRECT` clear) and 8-aligned pool pointers to the image's symbols, the pool or the
data area; the JIT records (`ctr_e` = −625, `ctr_l` = −10000, `func`, zeros,
`entry`/`osr`/`header` relocations); the header (image symbol from `stable_crate_id`,
`crate_hash`, section sizes, RELRO); the anchor; `__ryo_main` (one slot naming one of the image's functions or an undefined symbol).
Registry: the constructor decoded with `decodeX` from its relocations, `.init_array.00000`,
the list, and per link each image symbol listed once, at most one `__ryo_main`. Unwind: the
CIE (`zPLR`, entry rules, the personality through the slot naming `rust_eh_personality`), one
FDE per function of range `code_len`, whose row table equals at every offset the rules the
code establishes, derived from the counter check and prologue items read from the bytes
(`push rbp`, `mov rbp, rsp`, `sub rsp` applied to the entry rules; the body's rules up to the
entry's counter stub, the entry rules there; epilogues have no rules by design: the decoder
admits no call between the frame's release and `ret`), every call site and landing pad in the
body, and the LSDAs in function order, each equal to the function's call-site run, which the
decoder matched against the calls and `lpad`s. Remaining: what needs the dump (symbol names,
`ArgPlan`s, which function `__ryo_main` names; the pool and vtables are `Pool.lean`'s).

**Linked binary vs the image object (recommendation).** Validate the **object** as the
primary input: its relocations are *named*, which is what makes the C1'/§C4 resolution
meaningful ("this field calls `ryo_h_add_w32`"), and it exists per crate, so it fits
`y test`. Then add a **linked-equals-object check**, cheap and done once per test binary:
read the final executable's symbol table, build a `LinkMap` from it, and check that for every
image object linked into it, the image's sections in the executable equal the object's bytes
with each relocation applied to the linked symbol address (PLT/GOT entries: the PLT stub or
GOT slot whose dynamic relocation names the same symbol). Equivalently, decode the linked
code with `decodeReduced` in linked mode and check it equals the object decode modulo
resolution. This shrinks the linker in the trusted base to "the loader maps the file's
segments and `ld.so` performs the dynamic relocations", which no test can avoid. It belongs
in M6 (it is only needed for the program-level theorem); before then, the linker is trusted.

**What stays trusted, and why:**

- **Symbol slots filled by the loader.** Checking slot contents means running the program;
  the static check already pins each slot's relocation to the right name. The assumption is
  `ld.so` resolving names as the ELF spec says, which every native program also assumes.
- **Islands compiled by LLVM.** They are 3–10-line Rust templates; their contracts are tested
  by differential runs. Verifying them means binary verification of LLVM's `-O3` output, a
  separate project (possible later with L2+).
- **The linker**, until the linked-equals-object check exists; afterwards only the loader.
- **`ryo_vm_register`, `c_main`, handlers, the trip entry points, `ryo_probe_stack`**:
  runtime code, trusted contracts, tested.

## C5. The AOT theorems

```lean
/-- Per function: the bytes the backend emitted for `f` implement `f`'s MIR. -/
theorem aot_function_correct
    (obj : Bytes) (img : Image) (d : Dump) (f : FuncId) (P : R.Program)
    (hobj : readImage obj = .ok img)
    (hdec : decodeReduced img.mode (img.code f) (img.side f) (img.relocs f) = some P)
    (hlow : checkLowering (d.env f) (d.body f) (d.cert f) P = .ok)
    (himg : checkImage img d = .ok)
    (hc : Contracts) :
    FnSim conv (L0 (d.body f)) (L2 (img.code f) @ img.addr f)
```

`Contracts` bundles `H h`, the island contracts, `ryo_probe_stack`, `ryo_h_Resume`, and the
trip contract. The proof is the composition `L2(bytes_f) ⊑ R(P)` (`decode_sound`) `⊑ L0(f)`
(`check_sound` + `LowerSim`), with `checkImage` supplying the global relation (pool and
vtable copies hold the allocations, slots name the right symbols, FDE rows match).

**Program-level:** if every VM function of every image is validated (`aot_function_correct`
holds for each), `checkImage` passes for each object (and, for the strong version, the
linked-equals-object check passes for the executable), the contracts hold, and native code
refines its semantics under the convention, then the linked program's behaviors are
behaviors of the MIR program, or a prefix of one followed by `stackOverflow` (D25).

**Dependence on the JIT.** `decode_sound` treats the counter stubs as no-ops *given the trip
contract*, which lets control go to JIT code that simulates the same function. So:
- with `RYO_JIT=off` or the no-op JIT, the trip contract reduces to "returns with registers
  preserved", and the theorem is unconditional on the JIT;
- with the JIT on, the theorem for a run assumes **every JIT compilation in that run passed
  validation** ([jit.md](jit.md)). The induction over run time is well founded: JIT code is entered
  only after publication, and each published unit is validated against AOT code.

Both versions are stated. **Unvalidated functions** (`unsupported`/`rejected`) get no
theorem; the program-level theorem is then conditional on their correctness.

## C6. What is trusted (whole AOT pipeline)

- Lean's kernel, and the Lean statements of L0, R (including `opSem` and the *form* of the
  contracts) and L2. L0 is validated by tests and differential runs (M1, M1b); L2 by
  co-simulation ([x86.md](x86.md) §B.3); `opSem` by differential runs against the handlers.
- **The dump**: the backend's serialization of MIR, layouts, resolved instances, const and
  vtable allocations (M1b). Keep it a dumb serializer of rustc data structures, separate from
  the lowering's own helpers, so a lowering bug can't hide itself.
- **ABI**: that rustc's `PassMode` plan for each signature is what LLVM implements (checked by
  `tests/vm_abi.rs`). The convention's L0 side is rustc's `fn_abi`.
- **Native code**: LLVM-compiled functions and data (native functions, statics, islands,
  `c_main`, allocator shims), libc, the panic runtime and unwinder honor their semantics under
  the convention.
- **Contracts**: `H h` per handler, `ryo_probe_stack`, `ryo_h_Resume`, island templates, trip
  entry points, `ryo_vm_register`.
- The loader and `ld.so` (segment mapping, dynamic relocations, symbol slots, RELRO); the
  static linker until the linked-equals-object check exists.
- The unwinder's and personality's interpretation of CFI and LSDA per DWARF (the tables
  themselves are checked).
- The ELF/DWARF readers' fidelity to the specs (tested against `readelf`).
- The mode: ELF; `fp_arg` with or without frame pointer; `fp-rbp`; counters on (AOT) or off;
  loop alignment on/off. PE is out of scope.

Not trusted: the Rust lowering, encoder and decoders, the certificate, the instruction lists
and the call-site table, the constant pool, the function table and symbols, the relocation
list, the FDEs and LSDAs, the registry object.
