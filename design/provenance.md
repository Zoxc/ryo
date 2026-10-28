# Pointer provenance

How each tier treats provenance today, from MIR to the JIT, and what the Lean model says.
Hardware never sees provenance: it matters for what the optimizers may assume and for what
the proofs ([verification.md](verification.md)) must justify. The model is R's
(`lean/docs/reduced.md` §C0.3, §D.1); the tiers are meant to refine it.

## Rust's model, as it reaches us

- **Strict provenance**: a pointer is an address plus the provenance of one allocation.
  `ptr.with_addr(a)`/`map_addr` keep the provenance; `addr()` drops it (an integer);
  `without_provenance(a)` is a pointer without one, valid for zero-sized accesses only.
- **Exposed provenance**: `expose_provenance()` gives the address and marks the allocation
  exposed; `with_exposed_provenance(a)` picks (angelically) some exposed allocation.
- **MIR**: `CastKind::PointerExposeProvenance` (`p as usize`) and
  `PointerWithExposedProvenance` (`a as *const T`); `with_addr`, `addr`,
  `without_provenance` are library code over `wrapping_offset`, `Transmute` and these casts.
  `Transmute` ptr→int strips provenance at the integer type (MiniRust's integer decode);
  int→ptr gives none. Constants carry provenance as relocations of their allocation
  (`Scalar::Ptr`, `ConstValue::Slice`/`Indirect`, pointers inside allocations).
- **Aliasing models** (Stacked/Tree Borrows, `noalias`) are ignored everywhere: no tier
  uses reference-ness, and the proofs exclude them (verification.md, non-goals).

## Lowering (`backend/src/lower/`)

- **Casts** (`cast.rs`, [lowering.md](lowering.md#casts)): `PtrToPtr`, `FnPtrToPtr`,
  `Transmute`, `PointerExposeProvenance`, `PointerWithExposedProvenance` are all
  bit-preserving `mov`/`copy` of the slot (wide→thin drops the metadata word). Exposure
  leaves no trace in the code.
- **Pointer arithmetic**: `Offset`, `arith_offset`, projections and indexing are `ptr.add`/
  `ptr.index` (wrapping). `ptr_offset_from(_unsigned)` is `sub.w64` (+ exact division),
  `ptr_guaranteed_cmp` is `eq.w64`, raw-pointer compares are unsigned integer compares
  (`intrinsic.rs`, `binop.rs`).
- **Atomics** (`intrinsic.rs`): a thin raw pointer type selects the `.ptr` forms
  (`AtomicPtr`'s, provenance kept, `fetch_byte_add`/bitwise ops keep the pointer's in
  memory); every other type the `.wN` integer forms, which drop it.
- **Frame**: slots are untyped bytes. Taking an address (`addr`, a by-address call
  argument: sret, an `Indirect` copy) records an **escape** of the whole object (local or
  temporary, `FnCx::escape`, `Frame::object`; native if there is none); `StorageDead` and
  the per-statement temporary reset record an **end**; island operands a **lend**
  ([vm.md](vm.md#escapes-storage-ends-and-island-operands)). Locals never borrowed, dropped
  or indexed are private (`frame.rs`, `dead_after_read`).
- **Constants** (`constant.rs`, [lowering.md](lowering.md#constants)): a pointer constant
  is `addr.const` of the pool copy (memory, vtables: the image's own copy) or `addr.sym`
  (functions, statics) plus `ptr.add`; type ids are an immediate of the offset (no address,
  no provenance); `Indirect` constants are `const` copies of pool bytes, or a load from the
  PE fixup area. Pointers inside pool allocations are `Abs64` relocations, intra-image or
  against a symbol; PE imports go to the writable fixup area, patched once at registration
  ([vm.md](vm.md#image-format)).

## VM (`vm/rt/src/vm/interp.rs`, [instructions.md](instructions.md))

- Moves, copies, `const`, loads, stores, `mem*`, `fill` move `MaybeUninit<T>` or bytes:
  provenance and uninit bytes go through unchanged, whatever the slot's Rust type.
- Arithmetic, compares and the `.wN` atomics read their operands as integers.
- Memory operands `[p + k]` dereference `p` as a pointer the program computed
  (`wrapping_offset`); validity is the program's responsibility.
- `addr` is `lea [fp + s]`; nothing checks escapes at run time.

## Lean model (`lean/Ryo/Vm/OpSem/`, `lean/Ryo/Vm/R/`, `lean/Ryo/Spec/Mem/`)

- **Memory** is MiniRust's (`Ryo/Spec/Mem`): allocations, abstract bytes with provenance
  fragments, a list of exposed allocations (`IntPtrCast.lean`), `≤def` with `Uninit` and
  "no provenance" at the bottom (`Refine.lean`).
- **Frame objects** (reduced.md §C0.2–C0.3, `OpSem/Basic.lean`): **private** until an
  `Escape` scope, then an allocation at `φ(o)` with a fresh id, **exposed** at once
  (`R.escape`, `Sem.lean`); an `End` frees what it covers whole and makes the bytes
  `Uninit`. A frame access to an escaped byte is its allocation's byte (one copy;
  `writeEscaped`). `addrOf`: inside an escaped object, its provenance; at its end, the
  same (zero-sized trailing field); a zero-sized object, its address without provenance;
  else UB.
- **Values** (§D.1): moves/loads/stores keep bytes; integer ops decode integers (provenance
  dropped, `Uninit` UB); `ptr.add`/`ptr.index`/`addr*` keep or make provenance; `.ptr`
  atomics keep it, `.wN` drop it.
- **Exposure is invisible**: `expose_provenance` is a move, so every escaped object counts
  as exposed and a never-escaped one never is.
- **Resolution at the access** (`State.resolve`, reduced.md §C0.3 "Resolution time"): an
  access uses the pointer's own provenance if its live allocation contains the range, else
  the live exposed allocation containing it, else is UB (non-zero length). The fallback for
  pointers *with* provenance makes extra provenance never add UB, which is what lets R keep
  provenance where Rust drops it (`as usize`, transmutes) and the JIT return a pointer where
  R computed an integer; it picks the allocation whose bytes are at that address, so the
  hardware agrees. Proved in `Ryo/Proofs/Provenance.lean` (`resolve_mono`, `load_mono`,
  `store_mono`, `use_mono`, `drop_exposed_mono`), given that live allocations don't
  overlap (`LiveDisjoint`, kept by `escape`). The price: in R, an out-of-bounds access from
  an object reaches an *exposed* neighbour (L0 says UB), so independent placement of
  escaped objects rests on L0's placement being daemonic, not on R's UB.
- **Image** (`R/Run.lean`, `worldWith`): five allocations, the constant pool (immutable,
  `.const`), the data area from the fixups on (mutable), the symbol slots (immutable), the
  site slots, the code constants; then the environment's allocations the symbol slots point
  to (`NativeAlloc`: native statics and functions, other images' parts), each slot holding
  its target's address without provenance. Every allocation is exposed
  (`worldWith_exposed`), so integer addresses reach them. Relocated pool/data fields hold pointers with the target part's provenance.
  The constant-pool check (verification.md) requires each entry's relocations to be
  exactly its rustc allocation's provenance.
- **Consequences** (§C0.3): frame privacy (no provenance for non-escaped bytes exists),
  independent placement of private objects (a pointer of one object can't reach a private
  one; `φ` is a parameter),
  dangling after `End`. The relocation lemma (§C0.7) moves unreferenced objects at OSR.
- **Proofs against x86** (`Ryo/Proofs/Inline/`): `Rel` relates frame bytes with provenance
  erased (`Rel.lean`); `MemRel` each live allocation byte to x86 memory, `FrameApart` no
  initialized private byte inside an allocation, `WrApart` (loads) no written one,
  `MemDisjoint` (stores) distinct allocation bytes at
  distinct addresses (`Mem.lean`); `EscWF` fresh, distinct ids for escaped objects
  (`Scope.lean`); `FrameSep` over the frame window, which the scopes keep and which gives
  `FrameApart`, `WrApart` and `MemDisjoint` (`ScopeMem.lean`), and the calls' layout
  hypotheses (`StackApart`, `CallApart`, `IslandApart`, also over initialized private bytes
  only); across a call it is kept given the environment's facts on the allocations it leaves
  (`FrameSep.extend`).
- **L0 ↔ R** ([lean/docs/aot.md](../lean/docs/aot.md) §C1): provenance related by a renaming
  `ι` of allocation ids (escaped local ↔ its frame allocation, constant ↔ pool copy,
  zero-sized local ↔ no provenance), and pointers by `ProvLe`: an L0 pointer with an
  exposed provenance (an int→ptr cast's choice) relates to R's at the same address whatever
  R's provenance (reduced.md §C0.7); escape coverage is checked per function
  (`Check/Lower/CertCheck.lean`, `checkAddrs`).

## JIT SSA tier (`vm/bytecode/src/jit/`, [jit.md](jit.md#the-ssa-tier))

Values are untyped bit vectors; the IR has no pointer type and no provenance annotation
beyond what an instruction is. The model ([lean/docs/jit.md](../lean/docs/jit.md) §E.3) is
R's memory under the JIT's layout: `AllocaAddr` carries its alloca's provenance.

- **Allocas** (`alloca.rs`): union-find over accesses, escapes and lends. Promoted (no
  escape, no block/island access, scalar fields), memory (moved freely, alignment mod 16
  kept), outgoing, incoming. `escaped` = an `Escape` covers it; `pinned` = may be escaped
  at a cyclic head (stays at its AOT offset). An `addr` is a 1-byte access of the byte it
  points at, which picks the alloca of the resulting `AllocaAddr`.
- **Construction** (`build.rs`): `mov`/`imm` vanish; frame addresses become
  `AllocaAddr(a, k)`, image addresses `RefAddr` (pure: slots are filled before VM code
  runs). `AllocaAddr` is never a constant (OSR-transparent constants).
- **LVN** (`opt/lvn.rs`): folds constants and identities on any value, pointer or not
  (`x + 0`, `x & -1`, `x | 0`, `PtrAdd(0)`, `PtrAdd` chains, `PtrAdd` of `AllocaAddr`
  within `0..=size`); CSE of `RefAddr`/`AllocaAddr` within a block. Memory: forwarding
  keyed by `(alloca, offset)` or `(pointer SSA value, offset)`, narrower loads take the
  low bytes. Alias rules: a pointer store kills every other pointer key and every escaped
  or pinned alloca, never a non-escaped one; an alloca store its own bytes, and the pointer
  keys only if escaped/pinned; a call kills pointer keys, aliasable allocas, outgoing; an
  island everything. Two different pointer values always may alias (no provenance or
  base analysis).
- **Folds** (`opt/fold.rs`): `Load`/`Store` through `AllocaAddr` become `ALoad`/`AStore`,
  through `PtrAdd` take the offset. **DSE** (`opt/dse.rs`) only on memory allocas neither
  escaped, pinned nor addressed. **Promotion** (`opt/promote.rs`) of unpinned allocas with
  no `AllocaAddr` left and no handler/island naming them (the AOT `escaped` bit may be set:
  the IR's remaining uses are the escapes that matter). **Copies** (`opt/copies.rs`):
  small `memcpy`/`memmove`/`memset` become loads and stores of values, bytes kept.
- **Check elimination** (`opt/checks.rs`): facts on values from branch edges; addresses
  are values like others, never constants.
- **Inlining** (`inline.rs`): callee allocas are more allocas (no frame injection); its
  pointer parameters become the caller's `AllocaAddr`s, which the folds then turn into
  accesses of the caller's alloca. `rebase` (across images) turns `RefAddr` into 64-bit
  constants (`PtrAdd(0)` of a constant, which LVN folds to the constant) and symbol
  `RefAddr`s into the slot's value at compile time: provenance-less addresses.
- **No pass folds a load from memory to a constant** today, constant pool included.

## Rules for optimizations

1. **Non-escaped frame bytes are unreachable through pointers.** A pass may keep them in
   registers, drop their stores and move them only if no `Escape` covers them and no
   `AllocaAddr` of them reaches a store, call, handler or island. This rests on the
   image's scopes (checked by C1'; conditional otherwise, lean/docs/jit.md §E.7).
2. **A pointer derived from one object never reaches another.** Allocas may be placed
   independently; an access outside the object it was derived from is UB in L0 (in R only
   if no exposed allocation lies there: the placement is L0's daemonic choice). Passes may rely
   on it for allocas only; they don't rely on it between memory pointers (any two may
   alias).
3. **Integer-typed slots and values may carry provenance.** Slots and IR values are
   untyped; a `mov`/`copy`/load/store or a ptr↔int transmute keeps it. Only an integer
   instruction (or a `.wN` atomic) drops it. So no pass may assume a value is
   provenance-free from its MIR type, and a value that is moved, loaded or stored must be
   moved, loaded or stored as bytes. A pass may *add* provenance (return a pointer where R
   computes the same integer, as LVN's identities do): proved never to add UB.
4. **Folding to a constant drops provenance.** A pointer-producing instruction may become
   an integer constant only if every access through the result lands in an exposed
   allocation (`drop_exposed_mono`): image parts (all exposed in R) and escaped objects are; never fold
   `AllocaAddr` (the JIT moves allocas, and OSR entries differ) and never give a frame
   address an integer form.
5. **Loads from memory folded to constants.** Allowed only from an immutable allocation
   whose bytes are fixed before VM code runs: the constant pool (vtables included), the
   code constants, the symbol slots. The folded bytes must carry the right provenance: a
   relocated pointer field becomes a `RefAddr` of its target (pool, data area, symbol),
   not the bare integer, unless rule 4 holds for it; a non-pointer field becomes a
   constant; a partly relocated read (a pointer's fragment) is not folded. The data area
   (statics, PE fixups), the site slots and anything through `addr.sym` of a static are
   mutable: never folded.
6. **What is UB, what is defined.** UB (may be assumed not to happen): an access outside a
   live allocation or through a dangling pointer (after `End`), a store into the constant
   pool or vtables, an integer read of `Uninit`, `addr` of an unescaped non-zero-sized
   object. Defined (must be kept): wrapping pointer arithmetic out of bounds without
   access, comparing and subtracting any pointers (as integers), zero-sized accesses
   through any pointer, int→ptr round trips into exposed allocations, reading pointers as
   integers.

## Open questions and gaps

- **End pointers in the JIT.** An `addr` at an escaped object's end (a trailing ZST field)
  is a 1-byte access of the *next* byte (`alloca.rs`, `decode.rs`), so its `AllocaAddr`
  belongs to whatever alloca holds that byte, or a fresh 1-byte one, placed independently
  of the object. The model gives it the object's provenance (§C0.3). If that object moves
  or the other alloca does, `&l.zst == (&l as *const u8).add(size_of_val(&l))` can fail and
  stepping back reads the wrong bytes. Unverified by a test. Related: C1' must still
  exclude an end where another escaped object starts (§C0.7).
- **Resolution time** (was: access-time resolution vs `≤def`): settled by resolving with a
  fallback (above), proved at the level of accesses and bytes. Left for the relations when
  they are formalized (M5, M7): the step-level statement (an R step from states that differ
  by `≤def` bytes and `ProvLe` pointers is matched), and the invariant that `ι` maps L0's
  exposed allocations into R's and that `LiveDisjoint` holds of every world (image parts,
  environment answers).
- **Image allocations** (settled): one allocation per image part is kept. L0's globals map
  into the parts at offsets, R being more defined across entries, which refinement allows;
  constant-load folding is justified on it (`store_immutable`, `fold_load_reloc`,
  `drop_exposed_mono`; lean/docs/reduced.md §C0.7 "Image and environment"). Native
  statics reached through `addr.sym` are environment allocations the world exposes, and
  `rebase`'s integer addresses are sound by that exposure. Left: the multi-image world is
  the environment's (assumed: every loaded image's parts and natives exposed and disjoint),
  and that no step or environment answer changes an immutable allocation.
- The remaining items are recorded as future obligations in lean/docs/reduced.md §C0.7
  ("Provenance obligations not addressed yet").
- **Islands** run cg_llvm code under LLVM's provenance and `noalias` rules; a `Lend`
  operand is assumed not captured (template contract, not checked against LLVM IR).
- **Memory alias analysis** uses no provenance: store-to-load forwarding through pointers
  works only on one SSA pointer value; no base/offset disambiguation across different
  objects (rule 2) is used, and no `noalias`.
- **Not modeled**: PE fixups (verification.md's non-goal), the provenance behaviour of
  intrinsics run as islands, layouts other than `φ_AOT` and the JIT's allocas
  (§C0.4).
