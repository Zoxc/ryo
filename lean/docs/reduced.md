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
table (escapes and storage ends,
[vm.md](../../design/vm.md#escapes-storage-ends-and-island-operands)), the cleanup entries
and LSDA, and the island operand extents: a `Lend` scope per island operand of a nonzero
size, before the island, recorded by the lowering with the size the template accesses there
(metadata the JIT also needs). The island contract's operand footprint is that extent (C1'
checks it against the template, [aot.md](aot.md) §C1 "Islands"); the dead-store check
relies on it (aot.md §C2). An operand without a `Lend` is zero-sized: `Asm::lend` skips
only those (`asm/encode.rs`), and C1' checks that too. The contract also says what the
template does with each operand slot (`Ryo/Vm/R/Islands.lean`, by template and `ops`
position): reads it, or only writes it, whole and when it returns (a destination: its bytes
before the island are never observed), or neither. Which template an island is comes from
its symbol (C1' checks it is the instance the dump names).

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
  deallocated. At an `End` the bytes it covers become private and `Uninit`, escaped or not.
  This matches L0, where `StorageDead` then `StorageLive` gives uninitialized bytes, and
  LLVM's `lifetime.end`; and the backend already treats those bytes as dead (`reset_temps`
  marks the temporaries dead, `Asm::dead`, along with their `storage_end`, and a local isn't
  read after its `StorageDead`). It keeps the L0 ↔ R relation ([aot.md](aot.md) §C1): an
  object escaped again after an end holds `Uninit` in R where L0's bytes are uninitialized
  after `StorageLive`, so `≤def` holds; temporaries are unconstrained between statements
  anyway. An object escaped twice without an end in between stays one allocation.
- **Values**:
  - `addr d, s` (and a by-address call argument) yields a pointer to `s`: with the
    provenance of `s`'s object if that object is escaped at that point; else, if `s` is the
    **end of an object escaped there** (one past the end, which MIR's `offset` counts as in
    bounds), a pointer at that allocation's end with its provenance, so code may step back
    from it and read; else, if `s` is a **zero-sized object**, a pointer at `φ(o)` without
    provenance, valid (like every pointer in Rust) for zero-sized accesses only; else UB.
    The lowering check rules the last case out: escapes cover every `addr` and by-address
    argument but for exactly these two exceptions ([aot.md](aot.md) §C1). A zero-sized
    object has no bytes and never becomes an allocation (the encoder records no escape of
    size 0), and its placement is free: the JIT may put it anywhere. The object containing
    `s` takes priority, so an end that is also the start of another escaped object gets that
    object's provenance (§C0.7 says why C1' must exclude that case);
  - moves, copies, loads, stores, handler copies and the register file preserve abstract
    bytes, provenance fragments included;
  - integer operations decode their operands as integers, dropping provenance as MiniRust's
    integer decode does; `ptr.add` and `ptr.index` keep it;
  - **exposure is invisible in R** (`expose_provenance` lowers to a move), so every escaped
    object counts as exposed, and so do the image's parts and the environment's allocations
    (`Image.worldWith`, §C0.7 "Image and environment"). A never-escaped object is never exposed.
- **Accesses through pointers** (a `[p+k]` operand, a handler's or island's deref, a
  callee) are L0 memory accesses, with the provenance **resolved at the access**
  (`State.resolve`): the pointer's own, if its allocation is live and contains the range;
  else the exposed live allocation containing the range (`IntPtrCast`'s angelic choice; live
  allocations don't overlap, so there is at most one); else the access is UB (unless it is
  zero-sized). A pointer without provenance takes the second rule only.

**Resolution time** (why the fallback for pointers *with* provenance). MiniRust and L0 resolve
a provenance-less pointer at the int→ptr cast (`with_exposed_provenance` picks an exposed
allocation, angelically) and drop provenance at ptr→int casts and transmutes. R can't do
either: exposure and transmutes are moves, so R keeps the pointer's provenance where L0 has
an integer, and the JIT's LVN identities (`x + 0 → x`, `x & -1 → x`, `x | 0 → x`, a
same-width extension) return the pointer where R's result was an integer. With strict
resolution (the pointer's own provenance or UB) that extra provenance could *add* UB: L0
casts the address back, picks the exposed `B` the address lies in, and accesses it, where R
still holds `A`'s provenance and would be out of bounds. With the fallback, provenance only
ever adds definedness, which `Ryo/Proofs/Provenance.lean` proves (given `LiveDisjoint`,
live allocations not overlapping, which `escape` keeps: `escape_liveDisjoint`):

- `resolve_mono`, `load_mono`, `store_mono`, `checkDeref_mono`: an access through `p` gives
  what one through `q` does whenever `q` is `p`'s address with no provenance, `p`'s, or any
  exposed one (`ProvLe`), and `q`'s access is defined. The third case is L0's cast-time
  choice (`provLe_exposed`).
- `decodeBits_mono`, `decodePtr_mono`: bytes with more provenance (`bytesLeDefined`) are the
  same integer and a pointer with at least the provenance; `intBytes_le` and `lvn_add_zero`,
  `lvn_and_ones`, `lvn_or_zero`, `lvn_ext_same`: an LVN identity's integer result is `≤def`
  its operand's bytes; `use_mono` puts them together for a pointer read back and used.

Switching to cast-time resolution was the alternative: R would need a cast instruction it
doesn't have (exposure is a move) and every R proof would track which bytes came from a
cast. The fallback changes one definition, keeps every existing proof (they use only that
`resolve` keeps the address, `resolve_addr`) and matches the hardware: the allocation it
picks is the one whose bytes are at that address, so the R ↔ L2 relation is unchanged. What
it costs is the in-bounds property below for *exposed* objects.

What used to be separate rules of R are now consequences of the memory model:

- **Frame privacy**: a pointer cannot reach bytes of a frame object that is not escaped at
  that point, because no provenance for them exists. This is what lets the JIT promote
  non-escaped objects to SSA values, drop their stores and move them. The two exceptions of
  `addr` keep it: a zero-sized object has no bytes, and its pointer has no provenance, so
  any non-zero access through it needs an exposed allocation, which private bytes never
  are; an end pointer has the escaped object's provenance and reaches only its bytes.
- **In bounds**: a pointer derived from object `A` cannot access a *private* object `B`, so
  non-escaped objects can be placed independently (the layout parameter). An access through
  it outside `A` reaches an exposed `B` that lies there (escaped objects, image parts, the
  environment's allocations): defined in R, UB in L0 (whose pointer keeps `A`'s provenance),
  so independent placement of escaped objects rests on L0's daemonic placement (`φ` is one
  of L0's choices), not on R's UB. An end pointer of `A` at the start of `B` resolves to `A`
  for zero-sized accesses and to `B` (if exposed) otherwise.
- **Storage ends**: after an `End`, pointers to the object dangle (LLVM's `lifetime.end`;
  in R an access through one reaches only an exposed allocation now at that address, never
  the dead object's bytes), and its bytes are `Uninit`: a store before the `End` that nothing reads first is dead, which
  the dead-store check uses ([aot.md](aot.md) §C2).

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
- **sret destinations.** A call passing an sret destination (its argument list's first
  entry: the first integer register, by address) reads its argument list, then makes the
  `sretSize` bytes at the destination slot `Uninit`, then runs the callee. `sretSize` is the
  size of the callee's return type; the dead-store check takes it from an image callee's
  `ret_size` or from the call's certificate entry (`call.sym`/`call.ptr`), each of which C1'
  must check against the return type. The convention has the
  callee write its result through the pointer, never reading the old bytes, and L0 makes the
  destination uninitialized at call start too (D12: `deinit` of the destination after the
  arguments are evaluated, `Spec/Mir/Terminator.lean`), so the L0 ↔ R relation keeps
  `≤def` there: L0's destination is `Uninit` while the call runs. What the callee reads
  through other pointers to those bytes is then `Uninit` in both. For this to simulate L0,
  the destination must not overlap what the callee reads as its arguments after the call
  starts (the `Indirect` arguments' copies, the stack arguments): C1' checks it (the lowering
  gives each `Indirect` argument a fresh temporary and stack arguments the outgoing area). An
  escaped destination stays an allocation; only its bytes change. The dead-store check uses
  this (aot.md §C2): a store into the destination is dead unless the call reads it as an
  argument.
- `island`: a call `isl(fp, &ops)` under the Rust ABI, meaning the island's contract; its
  operands are accesses during the call (like an LLVM `nocapture` argument with a known
  footprint), not escapes.
- `lpad`/`resume`: the exception object in a slot.

**Implemented** (`Ryo/Vm/R/Sem.lean`, `Ryo/Vm/R/Run.lean`): an executable small-step
semantics of one function body at `φ_AOT`, open at calls (CompCertO-style). The state is `pc`,
`fp` (an address), `opSem`'s `State` and the incoming argument registers; the `Code` is the
`Decoded` function with its mode, the placement `ρ` of the image's addressed things, its
`arg_size`, its zero-sized frame objects (the certificate's locals of size 0), and per call
its stack-argument size, sret size and island template (facts from outside the function).
At entry the zero-sized objects are placed at `fp + off` (`OpSem.State.zeroSized`). `step : Code → RState → Except Stop Out` gives the next state, an
outgoing event (`Query`: a call with its callee (`Func` index, symbol slot, the slot behind
`call.sym.ind`, or a pointer), argument registers and the outgoing area's bytes at `sp = fp - F`;
an island with its symbol, template, `fp`, operand slots and `Lend` extents) with the state
waiting at it, or the end of the function (`Final`: a return with the return registers by kind
and the incoming area's bytes, a tail call with its stack arguments at `fp + 16`, or
unwinding out); `answer` continues a waiting state with the environment's `Answer` (return
registers or an exception object, the new outgoing-area or `Lend` bytes, the new memory).
Scopes before an instruction take effect before it (§C0.3: `Escape` an exposed allocation at
`fp + off` with the current bytes, `End` deallocating what it covers whole and making the
bytes `Uninit`, `Lend` nothing); every escaped object is deallocated at the end. A native
instruction with a handler shape or a handler call is `opSem (view i)` plus `Then.succ`
(`view = none` is `illFormed`); `resume` and an unwinding answer land at the instruction's
cleanup entry (the landing pad, with the exception register set for `lpad`; out of the
function for `continue`; UB with no entry), single-phase (`Code.catchesAt` gives the `catch`
flag a search phase would ask). Calls build their registers from the argument list (by value
at the register's size, zero-extended; `ARG_ADDR` as `addr`, with its two exceptions), make
the sret destination `Uninit` after reading the arguments, and store the answer's parts by
`k` at `d`. `Run.lean` runs programs: the environment answers a call of a program function by
running its R code below the caller's frame (tail calls in the frame they take over), and
`imageProgram` makes an image object such a program (its constant pool, data, symbol slots,
site slots and code constants as allocations); `ryo-lean rrun <image.o> <fn> <ints> [--cert <cert.json>]` runs one
function (or `--all`; the certificate gives the zero-sized locals). Tested (`RyoTest/RSem.lean`) on hand-built functions (recursive `fib`, branch
polarity, escapes, partial ends, dangling and `Uninit` after an `End`, by-address and stack
arguments, sret, unwinding to a pad and out, tail calls, islands, ill-formed instructions,
`addr` of a zero-sized object with a zero-length and a non-zero access, `addr` at an escaped
object's end and a load back from it, the same after the object's `End`) and
by hand on the corpus (`fib`, `ack`, `gcd`, `collatz`, `become`-recursive `count`/`even`
return their Rust values, at `-O0` and `-O3`). Not modeled yet: layouts other than `φ_AOT` and
the object table (an `Escape`'s range is its object; a partly overlapping escape is
`illFormed`), the constraints the contracts put on answers (the convention for calls, the
islands' contracts beyond their roles, handlers through pointers, `ryo_h_Resume`), the
probe and trip contracts (counters and stubs are not R instructions).

Running every corpus function (on small integer arguments) stops nowhere as `illFormed`. It
showed that the backend takes `addr`s that the first version of §C0.3 made UB: of zero-sized
locals (the encoder records no escape of size 0) and one past the end of an escaped local
(`&l.f` or `&raw const l.f…` of a zero-sized last field, such as an allocator or a
`PhantomData`, after the escape of `l`). §C0.3's two exceptions give both their MIR meaning,
and the certificate check's escape coverage ([aot.md](aot.md) §C1) accepts exactly them: over
the corpus (108 objects), of 14628 addresses taken (4847 by-address arguments), 14219 are in
an object escaped on every path to them, 26 at such an object's end, 383 at a zero-sized
local, and none is uncovered.

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

**Implemented** (`Ryo/Vm/R/View.lean`): `unpack ρ h fpArg args` reads each operand of `h` at
its `asm::layout` location with `handler_operands`' checks (a 32-bit operand from its half of
a shared register or from a register with no other bits set; `Mem` as the slot and a
zero-extended `i32`; `U128` low then high; a case list as its values' `Ro` address and count;
a target list as its count; `fp` first with `fp_arg`, `lpad`'s exception object before the
operands, nowhere else). Addresses are `Val.addr` pointers: `ρ : Arg → Option ThinPointer`
places the constants, data, symbol and site slots and code constants the arguments name
(the image's allocations; tests take an injective symbolic `ρ`). `view mode ρ i` gives
`{op, ops, ctl}`: targets, `neg`, functions and word lists are `Val.none`, and `ctl` is the
shape's `Then` (a branch, the switch table with the default last, `next`, `trap`) for the
handler shapes, `none` for R's own instructions (§C0.4), whose targets and lists stay in the
`Insn`; a handler's `Then` must be its shape's, a switch table one entry per case plus the
default (`encode_reduced`'s check). `Then.succ` gives the next instruction from `opSem`'s
`Control`, so `semR i = (opSem v.op v.ops, v.ctl.succ)`, which R's step function uses
(§C0.4). Checked against Rust's `asm::decode` (`RyoTest/View.lean`, vectors from
`vm/bytecode/tests/lean_view_vectors.rs`: every opcode with random operands, each handler in
both `fp_arg` layouts, and inline runs; same opcode and operands, instruction for
instruction), and `unpack` rejects mutated arguments. Not checked by `view`, as by
`decode_reduced`: a handler call of operands the opcode inlines.

### C0.7 How R relates to its neighbors

- **L0 ↔ R** ([aot.md](aot.md) §C1): identity on addresses under `φ` (L0 picks a local's
  address daemonically at `StorageLive`, so the simulation picks `φ(o)`; `φ` is fixed at
  function entry, so no prophecy is needed), and identity on provenance up to a renaming of
  `AllocId`s: each escaped local's L0 allocation corresponds to its frame object's R
  allocation, globals to their image copies, environment allocations to themselves. A
  non-escaped local's L0 allocation is unreferenced (no provenance for it exists in the L0
  state) and corresponds to private bytes. Bytes are related by MiniRust's "more defined"
  order (`Ryo/Spec/Mem/Refine.lean`) through the renaming, extended by two cases. Pointers
  relate by `ProvLe` (`Ryo/Proofs/Provenance.lean`): an L0 pointer with an exposed
  provenance (an int→ptr cast's choice) relates to R's pointer at that address whatever its
  provenance, which covers R keeping the provenance L0's `as usize`/transmute dropped; the
  relation needs `ι` to map L0's exposed allocations into R's (every escaped local and every
  global is exposed in R). And a
  zero-sized local's L0 allocation is renamed to *no* provenance, so an L0 pointer into it
  relates to R's provenance-less pointer at the same address. Nothing L0 does with that
  provenance can tell: a non-zero access through it is out of bounds (UB), a zero-sized one
  needs none, comparisons and integer casts see only the address, and `offset_from` is
  integer arithmetic in R ([aot.md](aot.md) §C1, "Locals"). An end pointer is the escaped
  local's L0 pointer at its end, a zero-sized field there, with the same provenance at both
  levels; what C1' must exclude is an end that another escaped object starts at, where R's
  priority gives the other object's provenance.
- **R ↔ L2** ([aot.md](aot.md) §C2): provenance erased, private bytes and allocations both
  at their `φ` addresses, `Uninit` refined by any byte. R's provenance checks only add UB
  on the R side, which a refinement may ignore.
- **R ↔ R-SSA** ([jit.md](jit.md) §E.3): under `φ_JIT`, allocas are R's frame objects with
  the same provenance and addresses; values relate by `bytesLeDefined` (R-SSA may hold more
  provenance: an LVN identity returns its pointer operand, `Ryo/Proofs/Provenance.lean`); promoted objects are SSA values (CompCertSSA's
  dominance equation). Entering JIT code by OSR changes the layout mid-execution, which the
  **relocation lemma** justifies: two states that differ only in the addresses of objects
  that nothing refers to (no provenance fragment for them anywhere, never exposed) are
  bisimilar. A zero-sized object's address is referred to without provenance once `addr`
  has taken it, so it is not moved: it has no bytes to move, and keeping it at its
  `φ_AOT` address keeps the pointers to it equal (L0 fixes a local's address while it is
  live). Because R has provenance, "not escaped at the loop head" already means
  "unreferenced" in R, and the lemma is applied in R, not by going back to L0. It is proved
  once on `Ryo/Spec/Mem`, so it holds for L0 as well.

**Image and environment.** R's world (`Image.worldWith`, `Ryo/Vm/R/Run.lean`) has one
allocation per image part (the constant pool, the data area, the symbol slots, the site
slots, the code constants), not one per L0 global, and the environment's allocations that
symbol slots point to (`NativeAlloc`: native statics and functions, another image's parts),
each slot holding its target's address as a plain integer, as the runtime fills it. Every
allocation of the world is exposed (`worldWith_exposed`). So:

- **Granularity.** `ι` maps each L0 global to its part *at an offset* (an injection in
  CompCert's sense, not a renaming). R is more defined than L0 across entries of a part (an
  access from one constant into the next is UB in L0 only), which a refinement allows; no
  pass relies on per-entry bounds. Per-entry allocations would be needed only for a rule that
  wants R's UB between globals, and none does.
- **Constant-load folding** (a load from the pool, the code constants or the symbol slots
  folded at JIT time; rule 5 of design/provenance.md): the allocation is immutable, so a
  store never changes it (`store_immutable`, `Ryo/Proofs/Provenance.lean`), and a load of
  a relocated field reads the pointer the relocation wrote, provenance included
  (`fold_load_reloc`), which is what a `RefAddr` of the target makes (`Image.addrs`); folding
  to the bare address is sound because the target is exposed (`drop_exposed_mono`). A
  non-relocated field folds to its integer; a partly relocated read decodes without
  provenance in both. Left: that no other step changes an immutable allocation (`opSem`'s
  frame writes touch escaped objects only, environment answers must keep them: an
  environment obligation with `LiveDisjoint`).
- **Cross-image addresses as integers** (`rebase`: another image's `RefAddr`s become
  64-bit constants; a symbol slot's value): justified by exposure, given that the
  environment's world contains every loaded image's parts and natives, exposed and
  disjoint (`drop_exposed_mono`, `resolve_of_fits`). The multi-image world itself (each
  image at its own addresses, ids renumbered) is the environment's, not built in Lean.

**Provenance obligations not addressed yet** (design/provenance.md, "gaps"):

- *Islands* run cg_llvm code under LLVM's provenance and `noalias` rules; that a `Lend`
  operand is not captured, and that pointers an island keeps or returns have the
  provenance R gives them, is the template contract's, not checked against the LLVM IR.
- *Alias analysis without provenance*: the JIT's forwarding and DSE use no provenance or
  base/offset disambiguation, so nothing about them needs more than the accesses' lemmas
  above; a pass that does use rule 2 between memory pointers needs its own lemma.
- *PE fixups* (the writable fixup area patched at registration) are not modeled: their
  slots are in the data area as plain bytes.
- The step-level forms of the relations: an R step from states related by `≤def` bytes and
  `ProvLe` pointers is matched (the access and byte lemmas are its cases), and
  `LiveDisjoint` of every reachable state (escapes keep it, `escape_liveDisjoint`; image
  parts' made-up addresses and environment answers must).

---

## Part D. `opSem` and the shared library

With one VM level, Part D is the library everything else stands on:

- **`Ryo/Vm/Generated/`**: opcodes, shapes, operand kinds, `asm::layout` (register, count,
  shift for 32-bit pairs, `U128` and case-list pairs, `lpad`'s exception object), handler
  kinds, reduced-set membership. Generated by a Rust program, which fails when they are stale.
- **`Ryo/Vm/OpSem/`**: `opSem` per handler kind (55 kinds: `bin`, `cmp`, `shift`, `ovf`,
  `cvt`, `aload`, …), on abstract bytes, with each opcode's **footprint** (frame
  operands read and written at their widths; whether it derefs pointer operands;
  `copy`/`fill` lengths). Lemmas: `opSem` only touches its footprint; the frame part is
  deterministic.
- **`Ryo/Vm/R/`**: R syntax (`Syntax.lean`), `view` and `unpack` (`View.lean`, done), the
  step function (`Sem.lean`, at `φ_AOT`, and `Run.lean`, done: §C0.4), frame objects and
  layouts beyond `φ_AOT`, handler, island, `ryo_h_Resume`, probe and trip contracts.
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
run checks the footprints. This is `vm/rt/tests/lean_opsem.rs` (below).

`pack`/`unpack` can be tested against the Rust layout, but no proof needs `pack`. The index
form of handler operands (the full set's `Const`/`Sym` indices) never needs a meaning: R's
handler arguments are addresses, which is what the handler receives.

### D.1 `opSem` as implemented (`Ryo/Vm/OpSem/`)

```
opSem (op : Full.Opcode) (ops : Operands) (st : State) (ch : Choice := {}) :
  Except Stop (Control × State)
footprint (op : Full.Opcode) : Option Footprint
```

- **Operands**: one `Val` per operand of `op` (`Full.Opcode.info`), what the handler gets
  from `unpack(layout op)`: a slot's frame offset, a memory operand `[p + k]`, an immediate,
  an address (`Const`/`Abs`/`Sym`/`Site`, a pointer with provenance), a jump table's length,
  a case list's values' address and count, or nothing (targets, `neg`).
- **State**: the private frame bytes by `fp` offset (abstract bytes), the escaped frame
  objects (each an allocation of the memory, from its start), L0's `Memory`, the exposed
  allocations, the exception register `lpad` stores, and the frame's zero-sized objects
  with their addresses (`zeroSized`, the layout restricted to them). A frame access to an
  escaped object's byte is its allocation's byte, so there is one copy of each byte; `addr`
  of an escaped object (or at its end) is a pointer with its provenance, of a zero-sized
  object a pointer without provenance, of any other offset UB (§C0.3). An access uses the
  pointer's provenance if its live allocation contains the range, else the exposed
  allocation containing it (`IntPtrCast`'s angelic choice, made at the access: §C0.3,
  "Resolution time"). Addresses of frame bytes appear only through allocations, so `opSem` is
  layout-independent.
- **Results**: the control effect (`next`, `branch b` before the polarity, `index i` with the
  table's length for the default) and the next state, or a `Stop`: `ub`, `abort`,
  `unreachable` (R's `unreachable`, a bare `ud2` without a handler, which `step` stops
  with rather than calling `opSem`; R may read it as UB, since the lowering emits it only
  where MIR has UB), `unsupported`, `illFormed` (operands that don't fit the
  opcode), `noBehavior` (a choice outside its set).
- **Choices** (`Choice`, each checked): a NaN result's bits (default the first RFC 3514
  candidate), `fmin`/`fmax` of zeros of opposite sign, and a weak compare-exchange's
  spurious failure (`noBehavior` for a strong one).
- **Values**: per §C0.3. `mov`, `copy`, `const`, `load*`, `store*`, `mem*`, `fill` move
  abstract bytes; integer and float operands are read as integers (provenance dropped,
  `Uninit` UB); pointer operands are decoded as pointers; `ptr.add`, `ptr.index`, `addr*`
  write pointers with provenance. Integer arithmetic is `BitVec` at the opcode's width,
  named by the handler table's Rust method or operator; floats use L0's exact IEEE
  arithmetic (`Ryo/Spec/Lang/Float.lean`), `as` casts per D34. Atomics are sequential (D17)
  at natural alignment. The `.wN` forms are, like their `AtomicUN` handlers,
  integer-typed (an atomic load of a pointer through them drops its provenance); the `.ptr`
  forms, `AtomicPtr`'s, which the lowering selects for a raw pointer type, read and write
  pointers with provenance: a read-modify-write other than `swap` changes the address by a
  `usize` and keeps the provenance of the pointer in memory, and compare-exchange compares
  addresses.
- **UB**: `Uninit` read as an integer or pointer; a zero divisor and `MIN / -1`
  (`unchecked_div`/`_rem`); `memcpy` of overlapping ranges; an access outside a live
  allocation, or a store into an immutable one; a misaligned atomic or `addr.sym` slot;
  `addr` of an offset that is neither in an escaped object, nor at its end, nor a zero-sized
  object. Shift and rotation amounts are masked (`wrapping_sh*`,
  `rotate_*`): no UB.
- **Footprint**: per opcode, from `HandlerKind` and its parameters, naming operands: the
  frame reads and writes at their exact extents (a width, `len`, `elem_size × count`; a
  memory operand reads its slot's 8 bytes), the address-taken slots, the accesses through pointers (source, extent, read /
  write / read-modify-write, aligned; memory extents are upper bounds where the handler can
  stop early), and the flow (`next`, `branch`, `table`, `trap`). Defined for every opcode
  with a Rust handler (`RyoTest/OpSem.lean` checks it, and that it names operands of the
  right kinds).
- **Lemmas** (`OpSem/Lemmas.lean`, proved for all opcodes at once, because `opSem` reads
  the frame only through the footprint's reads, gives the kind semantics the state with its
  private bytes erased, and writes only through the footprint's writes):
  `opSem_frame_writes` (no private byte outside the write ranges changes) and
  `opSem_reads_footprint` (two states agreeing on the read ranges, and on everything but
  the private frame, give the same outcome, control and memory, and frames equal wherever
  either changed). That each kind writes *all* its footprint's writes is tested
  (`OpSem/exact-writes`), and the differential test checks against the handlers that every
  frame byte they change is in the footprint.
- **`ryo-lean opsem`** (`OpSem/Json.lean`): one JSON request per line (opcode, operands,
  frame bytes, allocations, escaped objects, exception, choice), one result per line (the
  control, the frame and memory bytes after, the footprint's ranges), or the `Stop`.
- **Differential test** (`vm/rt/tests/lean_opsem.rs`, skipped without the `ryo-lean`
  binary): every opcode with a Rust handler but the traps, 24 random cases each (half with
  the frame escaped), Lean first and the handler only when Lean gives a next state; frame,
  memory and returned value must agree (floats also under the handler's NaN bits and zero
  sign), and changed frame bytes must be in the footprint's writes.

Out of scope: the opcodes without a Rust handler (`jmp`, the calls, `ret`, `arg`, `island`;
`resume`, whose handler is assembly), which are R's own instructions (§C0.4); f16/f128
(islands). `view` and `unpack` are implemented (§C0.6, `Ryo/Vm/R/View.lean`), and so is the
step function (§C0.4, `Ryo/Vm/R/Sem.lean`); left in `Ryo/Vm/R/`: frame objects and layouts
beyond `φ_AOT`, and the contracts.
The JIT's Rust effect table (`jit/effects_table.rs`, behind `jit::effects`) is generated from
the footprints (`Ryo/Vm/OpSem/JitEffects.lean`, `ryo-lean effects`; [jit.md](jit.md) §E.7),
with `resume`'s entry (no footprint) given by hand; `y lean` checks it is up to date.
Reads are not checked for exactness (an over-approximated read only costs the JIT
precision).

Where the handlers and the docs differ (design/vm.md): `copy`'s doc says the ranges never
overlap, but the handler is a `memmove`, and `opSem` follows the handler; the handler table
names `Case32` as `switch.sparse.w8`'s and `.w16`'s case kind (their lists are `Case8` and
`Case16`), a parameter the handler doesn't use.
