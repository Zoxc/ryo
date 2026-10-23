# Parts C0 and D. The reduced VM level R, and `opSem`

R is the meaning of decoded machine code, and the only VM level: the full VM instruction set
is a vocabulary (it names the handlers and the layouts), never a program representation
([plan.md](plan.md) §0). Every relation of the plan goes through R: L0 → R is the lowering
check ([aot.md](aot.md) §C1), L2 → R is `decode_sound` ([aot.md](aot.md) §C2), and the JIT
validates R → R-SSA → LIR → L2+ ([jit.md](jit.md)).

**R carries provenance.** R's memory is L0's memory model (`Ryo/Spec/Mem`: MiniRust's
`BasicMemory` and `IntPtrCast`, abstract bytes with provenance fragments), not a flat byte
array. The lowering erases nothing; provenance is erased only where the bytes are executed,
at R → L2 (and LIR → L2+ in the JIT). This is what lets the JIT's SSA IR have allocas with
provenance and be related to R by identity on provenance, and lets the facts the JIT needs
(frame privacy, independent placement of frame objects, dangling after a storage end) be
consequences of the memory model instead of extra rules (§C0.3).

## C0. R

### C0.1 Syntax

The reduced set (`reduced_ops.rs`, generated into Lean): native ops, and `handler h args neg
t` where `args` are argument-register values: `Fp`, `Exception`, `Imm`, or the address of a
`Const`/`Data`/`Sym`/`Site`/`Ro` (`reduced.rs`). Targets are instruction indices. Each
function comes with its side data, read from the image object by the Lean decoder: the scope
table (escapes and storage ends, [vm.md](../../design/vm.md#escapes-and-storage-ends)), the
cleanup entries and LSDA, and the island operand extents (a `Lend` scope per island operand
object, metadata the JIT also needs; until it exists, an island operand's extent is the
width the island contract gives it).

### C0.2 Frames are objects, at a layout

R is stated over **frame objects**, not over raw `fp` offsets. A function's frame objects are
byte ranges of `[-F, 0)` and the incoming area `[16, 16 + arg_size)` that no access crosses:
the union of each instruction's accesses, each `Escape` scope's whole object, and each
island operand's extent. The object table is a certificate (dumped, or recomputed by the
checker the same way the JIT computes its allocas); the checker validates that every access
stays inside one object.

R is **parametric in the frame layout** `φ : object → address` (aligned, disjoint, inside the
frame). A frame operand `fp + off` means byte `off - off_o` of the object `o` containing
`off`, at `φ(o)`. The AOT code is `R(φ_AOT)` with `φ_AOT(o) = fp + off_o`; JIT code is
`R(φ_JIT)` for the layout the JIT chose. Handler and island contracts are stated on frame
operands, so they are layout-relative already.

### C0.3 State and memory, with provenance

- **Memory** (per thread): `Ryo/Spec/Mem`, shared with L0. Allocations are the program's
  globals (constant-pool entries and vtables as immutable allocations, D7/D29; statics),
  heap and native memory created by the environment (external calls, under L0's
  environment interface, [mir-spec.md](mir-spec.md) §A.6), and **escaped frame objects**.
- **A stack of VM frames** `{fn, pc : insn index, φ, private bytes, live objects}`.
- At call boundaries only: an argument/return register file (`rdi…r9`, `xmm0…7`,
  `rax`/`rdx`), holding abstract bytes.
- **Frame objects.** An object is **private** until it escapes: its bytes (abstract bytes,
  so pointers stored in slots keep their provenance and uninitialized bytes stay `Uninit`)
  are reachable only through frame operands. At an `Escape` scope it becomes an
  **allocation** at `φ(o)`, with a fresh `AllocId`, holding its current bytes. At the
  matching `End` (a `StorageDead`, the temporaries' reset) or at return, the allocation is
  deallocated and the bytes become private again. An object escaped twice without an end
  in between stays one allocation.
- **Values**:
  - `addr d, s` yields a pointer to `s` with the provenance of `s`'s object; it is UB if
    that object is not an allocation at that point (the lowering check rules this out:
    escapes cover every `addr` and by-address argument);
  - moves, copies, loads, stores, handler copies and the register file preserve abstract
    bytes, provenance fragments included;
  - integer operations decode their operands as integers, dropping provenance as MiniRust's
    integer decode does; `ptr.add` and `ptr.index` keep it;
  - **exposure is invisible in R** (`expose_provenance` lowers to a move), so every escaped
    object counts as exposed, and an access through a pointer without provenance resolves
    angelically among exposed allocations (`IntPtrCast`). A never-escaped object is never
    exposed.
- **Accesses through pointers** (a `[p+k]` operand, a handler's or island's deref, a
  callee) are L0 memory accesses: they need the provenance of a live allocation and must stay
  in it.

What used to be separate rules of R are now consequences of the memory model:

- **Frame privacy**: a pointer cannot reach bytes of a frame object that is not escaped at
  that point, because no provenance for them exists. This is what lets the JIT promote
  non-escaped objects to SSA values, drop their stores and move them.
- **In bounds**: a pointer derived from object `A` cannot access object `B`, so objects can
  be placed independently (the layout parameter).
- **Storage ends**: after an `End`, pointers to the object dangle (LLVM's `lifetime.end`).

The escape ghost state of the earlier design is the set of live frame allocations. Dropped
stores are not ghost state: the Lean decoder re-checks them ([aot.md](aot.md) §C2).

### C0.4 Semantics

- Native instruction `op ops`: `opSem op ops` on the frame operands and memory operands
  `[load64(p) + k]`.
- `handler h args neg t`: the contract `H h` (below), then the shape's control flow: branch
  on the returned `bool` with polarity `neg`, jump through `t` on the returned index (default
  last), or fall through.
- Calls at register level: `call`/`call.sym`/`call.ptr`/`tail_call*`/`ret`/`arg`, using the
  call's argument list and return kind `k` (these are already native R instructions). The
  callee is the environment or another R function, under the convention
  ([aot.md](aot.md) §C1, "Calls").
- `island`: a call `isl(fp, &ops)` under the Rust ABI, meaning the island's contract; its
  operands are accesses during the call (like an LLVM `nocapture` argument with a known
  footprint), not escapes.
- `lpad`/`resume`: the exception object in a slot.

### C0.5 Handler contracts

`H h`: reading its operands from `rdi…r9` as `unpack(layout h)` (`fp` from `rdi` or `rbp`),
it performs `opSem h` with **exactly** `h`'s footprint (the frame operands it reads and
writes, at their widths), returns `al`/`rax` per shape, clobbers the caller-saved registers
and flags, preserves `rbx`, `rbp`, `rsp`, `r12`–`r15`, and requires `rsp ≡ 0 mod 16` at the
call. Accesses a handler makes **through pointer operands** are R memory accesses, with
provenance. So slot operands are frame accesses with an exact footprint, and pointer
accesses cannot reach private frame bytes.

`ryo_h_h` reading `unpack(layout h)` is part of the contract (`asm::read` does it, and
`vm/rt/tests/ops.rs` tests it). No `pack` appears in any proof: validation only unpacks bytes
it read itself.

### C0.6 The op view

`view : R.insn → Option (Opcode × Operands)`: a native instruction maps to itself;
`handler h args neg t` maps to `h` with `unpack(layout h, args)` and `neg`/targets
re-attached; `none` when the args don't unpack (a malformed `Imm` packing, an `Addr` where a
slot is expected). By construction `semR i = opSem (view i)` plus the shape's control flow.
`view` is the Lean analogue of Rust's `asm::decode`, and the lowering check's rules are
written over it.

### C0.7 How R relates to its neighbors

- **L0 ↔ R** ([aot.md](aot.md) §C1): identity on addresses under `φ` (L0 picks a local's
  address daemonically at `StorageLive`, so the simulation picks `φ(o)`; `φ` is fixed at
  function entry, so no prophecy is needed), and identity on provenance up to a renaming of
  `AllocId`s: each escaped local's L0 allocation corresponds to its frame object's R
  allocation, globals to their image copies, environment allocations to themselves. A
  non-escaped local's L0 allocation is unreferenced (no provenance for it exists in the L0
  state) and corresponds to private bytes. Bytes are related by MiniRust's "more defined"
  order (`Ryo/Spec/Mem/Refine.lean`) through the renaming.
- **R ↔ L2** ([aot.md](aot.md) §C2): provenance erased, private bytes and allocations both
  at their `φ` addresses, `Uninit` refined by any byte. R's provenance checks only add UB
  on the R side, which a refinement may ignore.
- **R ↔ R-SSA** ([jit.md](jit.md) §E.3): under `φ_JIT`, allocas are R's frame objects with
  the same provenance and addresses; promoted objects are SSA values (CompCertSSA's
  dominance equation). Entering JIT code by OSR changes the layout mid-execution, which the
  **relocation lemma** justifies: two states that differ only in the addresses of objects
  that nothing refers to (no provenance fragment for them anywhere, never exposed) are
  bisimilar. Because R has provenance, "not escaped at the loop head" already means
  "unreferenced" in R, and the lemma is applied in R, not by going back to L0. It is proved
  once on `Ryo/Spec/Mem`, so it holds for L0 as well.

---

## Part D. `opSem` and the shared library

With one VM level, Part D is the library everything else stands on:

- **`Ryo/Vm/Generated/`**: opcodes, shapes, operand kinds, `asm::layout` (register, count,
  shift for 32-bit pairs, `U128` and case-list pairs, `lpad`'s exception object), handler
  kinds, reduced-set membership. Generated by a Rust program, pinned to `FORMAT_VERSION`.
- **`Ryo/Vm/OpSem/`**: `opSem` per handler kind (~45 kinds: `bin`, `cmp`, `shift`, `ovf`,
  `cvt`, `discr`, `aload`, …), on abstract bytes, with each opcode's **footprint** (frame
  operands read and written at their widths; whether it derefs pointer operands;
  `copy`/`fill` lengths). Lemmas: `opSem` only touches its footprint; the frame part is
  deterministic.
- **`Ryo/Vm/R/`**: R syntax, frame objects and layouts, `view`, `unpack`, the step function
  (§C0), handler, island, `ryo_h_Resume`, probe and trip contracts.
- **`Ryo/Vm/DecodeReduced.lean`**: the decoder, with `decode_sound` in `Ryo/Proofs/`.

`opSem` is the single source of truth for: native R instructions; handler contracts; the
lowering check's rules; the inline sequences (`asm::inline`) and the JIT's
instruction-selection templates, each proved against it; and the JIT's exact handler effect
tables, which are the footprints ([jit.md](jit.md) §E.7). So an inline form and a handler
call of the same opcode agree by construction, which matters because `is_native(op, ops)`
depends on the operands.

**Validating `opSem`** (it is trusted as the meaning of the opcodes): a differential harness
calls each `ryo_h_*` on random frames (canary-filled, like `vm/rt/tests/inline.rs`) and
compares the result and the bytes touched with `ryo-lean opsem` on the same input. The same
run checks the footprints.

`pack`/`unpack` can be tested against the Rust layout, but no proof needs `pack`. The index
form of handler operands (the full set's `Const`/`Sym` indices) never needs a meaning: R's
handler arguments are addresses, which is what the handler receives.
