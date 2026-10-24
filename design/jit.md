# JIT

With its `jit` feature (`y build` enables it on x86_64 Linux and windows-msvc, in both
sysroots, [build.md](build.md#build)), `ryo_rt` recompiles hot VM functions on a background
thread and switches their entry and loop heads over to the new code. Every image is built
for it: each function counts its calls and loop iterations in a *JIT record* and leaves
through a stub into the runtime when the count runs out ([vm.md](vm.md#jit-records-and-counters)).

The JIT code is the function compiled through an SSA tier with a register allocator ([The
SSA tier](#the-ssa-tier)), or, where that tier doesn't handle it (or with
`RYO_JIT_OPT=reencode`), decoded and encoded again without counters. Its frame may differ from the AOT code's (it does with
`RYO_JIT_SHUFFLE`), and nothing relies on them matching: a call running the AOT code moves
over at its next loop head through an OSR entry that converts the frame ([OSR](#osr)). On
PE, `ryo_jit_start` fails for now (the JIT isn't ported), so the trips act as the no-op JIT
after the first.

The work is split in two ([Packaging](#packaging)):

- the **runtime side**, `ryo_rt`'s `vm::jit` (`vm/rt/src/vm/jit/mod.rs`): the trips, the
  queue, the settings and the counters, `core` only like the rest of the runtime
  ([vm.md](vm.md#runtime-crate-ryo_rt), "No re-entry");
- the **JIT thread**, the `ryo_jit` crate (`vm/jit/`): the compiler and installer
  (`install.rs`) and the thread's loop (`thread.rs`), on a std of its own. `ryo_rt` bundles
  it as one sealed object and starts it through its one symbol, `ryo_jit_start`.

A function's life:

1. Its AOT code counts down its record's `ctr` (a call 16, a loop iteration 1, from
   `JIT_THRESHOLD`, 10 000) and, when it goes negative, calls through the record's `entry`
   or `osr` slot: a *trip* into the runtime.
2. The first trip queues the record and wakes the JIT thread, which decodes the function
   from its image, encodes it again, installs the code near the image, and publishes it in
   the record.
3. From then on the counter is `REDIRECT`, so every check takes its stub: an entry's
   straight into the JIT code, a loop head's into an OSR entry. The slots are redirected,
   no AOT code is patched.

## Records and trips

The record (`image::JitRecord`, 64 bytes, one per function in the image's writable
section; its fields and the counter checks and stubs that use it are in
[vm.md](vm.md#jit-records-and-counters)) is the runtime's once the image is registered. Its
`state` moves `Cold → Queued → Done` (or `Failed`), and only the JIT thread writes
`jit_code`, `jit_len`, `entry` and `osr` after the writer.

- **Trips** (`ryo_jit_trip_entry`, `ryo_jit_trip_osr`, `vm::trip_entry` and
  `vm::trip_osr`), lock-free:
  - `Cold`: `state` CAS `Cold → Queued`; the winner pushes the record onto the queue and
    wakes the JIT thread. The counter goes back to the threshold, and the stub continues
    the AOT code.
  - `Queued`: the counter goes back to the threshold; `Failed`: to `i64::MAX`.
  - `Done`: the entry's trip stores the counter `REDIRECT` and continues in the JIT code;
    a loop head's jumps to the record's `osr` slot, the OSR dispatcher, in assembly,
    leaving the counter negative. Only a stub that read the slot before the publication
    gets there: the stubs call the dispatcher directly afterwards. A trip that waited for
    the compile (`RYO_JIT_SYNC`) continues the same way.
- **Registers**: the trips may clobber only `rax`, `r11` and the flags (vm.md's counter
  stubs' contract). `ryo_jit_trip_entry` saves the argument registers (`rdi`…`r9`,
  `xmm0`–`xmm7`) in a 192-byte area, which keeps `rsp` 16-aligned for the Rust call (`rsp`
  is 16-aligned at the trip), and restores them; it returns to the stub, or jumps to the
  JIT entry, with the stack as it found it. `ryo_jit_trip_osr` saves only `eax`, the
  head's index, for the dispatcher: nothing else is live at a head. On PE they also save
  `xmm8`–`xmm15` (entry, a 320-byte area) and `xmm6`–`xmm15` (loop head), callee-saved on
  Win64 but not for the `sysv64` Rust code they call (`rdi` and `rsi` are saved at an
  entry, and by the prologue at a head).
- **No unwinding**: the Rust parts can't panic: nothing may unwind out of them, since the
  stubs aren't call sites. They are `sysv64-unwind`/`C-unwind` only so that the compiler
  adds no abort-on-unwind guard, which would reach core's panic path ("No re-entry").
- **Counters** are written with relaxed atomics, racing the AOT code's `sub`s; a reset that
  races the publication re-checks `state` and stores `REDIRECT` again. Registration sets
  every counter to `RYO_JIT_THRESHOLD` if it is set, and to `i64::MAX` with `RYO_JIT=off`
  ([Settings](#settings)).
- **`REDIRECT`** = `i64::MIN / 2`: a compiled function's counter, negative enough that every
  check takes its stub for 2^58 calls. `i64::MIN` would wrap to a large positive count at
  the next `sub`.
- **The no-op JIT** (`ryo_rt` without its `jit` feature, `vm/rt/src/vm/jit/noop.rs`):
  `ryo_jit_trip_entry` and `ryo_jit_trip_osr` are naked assembly, `mov rax, i64::MAX; mov
  [r11], rax; ret`: the counter is set to `i64::MAX`, so the function never trips again in
  practice, and the stub continues the AOT code. A store racing other threads' `sub`s may be
  lost; the counter then runs out again later, harmlessly. With the feature, the runtime
  acts the same way when the JIT is off or couldn't start.

## Queue and thread

- **Queue**: a Treiber stack of records (`static QUEUE`, linked through `next`). Each
  record is pushed at most once (only the `Cold → Queued` winner pushes), and the one
  consumer takes the whole stack (`swap(null)`) and reverses it to compile in trip order, so
  there is no ABA problem. The pusher bumps a wake word and wakes it (`futex_wake`) only if
  the JIT thread announced it sleeps; the thread re-checks the queue after announcing, then
  waits on the word's value it read, so no wake is lost. On PE the futex is
  `WaitOnAddress`.
- **The thread** starts with the first push (a flag swapped once), not at registration,
  which runs in constructors and under the loader lock: the push builds the `RtApi` and
  calls `ryo_jit_start`, which spawns the thread (`ryo-jit`) with the JIT's own std. If it
  can't start (it returns false, as on PE for now, or on an `RtApi` version mismatch),
  every queued record fails (its waiters woken) and the trips act as the no-op JIT. It
  takes the queue with `RtApi::next_batch` (which sleeps on the futex while it is empty),
  compiles each record, catching its panics, and reports it with `RtApi::done` (counted, or
  `Failed`; the waiters woken). It is detached; exiting mid-compile is fine.

## Compiling and installing

`vm/jit/src/install.rs`, per record:

- **Decoding**: `image::ImageResolver::decode` from the image alone (the handler table is
  every `ryo_h_*` handler's address with its opcode, from `RtApi::handlers`, sorted, built
  once; the probe `ryo_probe_stack`, `RtApi::probe`). The decoder reads the counters'
  checks and stubs as part of the canonical form and lists the loop heads
  (`Decoded::heads`, [vm.md](vm.md#jit-records-and-counters)).
- **Encoding**: the SSA tier's `jit::compile` ([The SSA tier](#the-ssa-tier)), or, for a
  function it doesn't handle, `asm::encode_reduced_at` in the image's mode without counters
  (in another frame layout with `RYO_JIT_SHUFFLE`, [OSR](#osr)), which also gives the
  instructions' positions for the OSR entries, then the OSR entries. A failure (decode, encode, reach,
  memory) or a panic marks the record `Failed`, counter `i64::MAX`, and the thread goes on.
- **Entry redirection**: the stub `call`s through `entry`, so the JIT code must get rid of
  the stub's return address. The JIT code starts with `lea r11, [rip + code]; mov [rsp],
  r11; ret` (12 bytes, `JIT_ENTRY_PREFIX`), at which `entry` points: the `ret` replaces the
  return address with the code and returns to it. Unlike a `pop`, that keeps the return
  stack buffer balanced: the `ret` mispredicts (it predicts the stub), but the function's
  own `ret` and its callers' don't, which a dropped return address would make mispredict
  one frame after the other (a native caller of a compiled function pays this per call: it
  can't be re-linked). Direct calls of the JIT code (between JIT functions, and a
  function's calls of itself) target the instruction after it.
- **Code memory**: mappings of 32 MiB, each within ±2 GiB of every image it serves (the
  image's three sections, and the handlers), so the code keeps every field `rel32`, as in
  AOT code. They are mapped read-write with `MAP_FIXED_NOREPLACE` at hints stepping away
  from the image (a result out of reach is unmapped and the next hint tried). A function
  takes whole pages from a mapping's start: the entry prefix at byte 4, the code at 16, the
  OSR code ([OSR](#osr)) 16-aligned, then its code constants (`Encoded::rodata`)
  16-aligned, copied next to the code rather than pointing at the image's (they are equal
  for an exact re-encode, but needn't stay so). The pages turn read-execute once written
  and are never written again or reused, so no cross-modifying code. Unwind information and
  call slots are taken from the mapping's end and stay read-write. A full mapping is
  retired and another mapped; a function of more than half a mapping fails.
- **Relocation**: handlers and the probe by address; a function of the image to its JIT
  code if it is `Done` at that moment (itself always), else (tail calls) its AOT start,
  whose counter redirects once it is compiled; symbol slots, sites, constants and the data
  area in the image, by the header's ranges, as the writer resolves them; code constants to
  the copy; the record (`Ref::Rec`, `Ref::RecCtr`) to itself. A field out of `rel32` reach
  fails the function.
- **Call slots**: a `call` of a function of the image that isn't compiled yet becomes a
  `call.sym` of a symbol past the image's, which relocates to a call slot: 8 bytes at the
  mapping's end, one per mapping and callee, holding the callee's AOT entry (its JIT code
  if it was compiled since), and its JIT code once it is published (an atomic store, no
  code patching). So JIT code reaches functions compiled after it without their entry
  stubs. Tail calls still go to the AOT entry.
- **Publishing**: `jit_code` and `jit_len`, then `entry` and `osr` (release), then
  `state = Done`, then the counter `REDIRECT`, then the function's call slots. Every later
  call's and loop iteration's check then takes its stub straight into the JIT code, without
  the runtime.

## Unwinding and profiling

- **Unwind information**: per function an `.eh_frame` (`image::eh_cie` and `image::eh_fde`,
  shared with the image writer: the same CIE and rules), the OSR code's FDE
  ([OSR](#osr)), the zero terminator, and its LSDA (`asm::lsda::write` of the JIT code's
  call sites), all PC-relative, registered with libgcc's `__register_frame`, which is the
  program's unwinder (the sealed object only references it). The personality is the
  image's `rust_eh_personality` slot, the symbol slot holding the program's personality's
  address, which the runtime passes in (`RtApi::personality`): in the JIT that name is its
  own std's. So panics unwind through JIT frames and their landing pads run. The entry
  prefix before the FDE's range runs before the frame exists and calls nothing.
- **Perf map**: with `RYO_JIT_PERFMAP=1`, a line per function in `/tmp/perf-<pid>.map`,
  named `ryo-jit:f<index>@<AOT address>`, so `perf` names JIT frames.
- **Backtraces**: JIT frames have no symbols, so backtraces show them unnamed (`y test`'s
  `backtrace` check runs with `RYO_JIT=off`).

## OSR

A call that runs a function's AOT code when it is compiled moves to the JIT code at its next
loop head (on-stack replacement), so entry into the JIT code is bounded: a call that never
returns (a `main` in a loop) switches over too, and calls switch at their entry. At an AOT
loop head the state is all in the AOT frame (the register cache is empty at branch targets,
and dropped stores are flushed before them, [vm.md](vm.md#register-cache)), so that is where
frames convert. The JIT compiles the entries with the function (`asm::osr`, `asm::frame`).

- **Dispatcher**: the record's `osr` slot points at it, after the JIT function's code. The
  head's stub calls it with `eax` the head's index (`Decoded::heads`) and `rsp` at
  `fp - F_aot - 8`: `lea r11, [rip + T]; movsxd rax, [r11 + rax*4]; add rax, r11; jmp rax`,
  `T` a table of `i32` offsets of the entries.
- **Entries**, one per head: `pop rcx` (the stub's return address), then, if the frames
  differ, `rdx = fp` (`lea rdx, [rsp + F_aot]`, or `rbp` with a frame pointer), the probe
  if the stack grows by 4096 or more, `rsp` to a scratch area below both frames, the live
  bytes that move loaded from their AOT slots into it and then stored to their JIT ones (a
  parallel move, in 8, 4, 2 and 1-byte pieces), `rsp = fp - F_jit`, and `jmp` to the head in
  the JIT code. With equal frames an entry is `pop rcx; jmp`. `fp` doesn't move, so the
  return address, the caller's frame and the stack arguments stay. A head at an `arg` or an
  `lpad` (registers live that the stub doesn't keep; the lowering emits neither) has no
  entry: its table entry is a `ret`, back to the AOT code.
- **Layouts**: `asm::frame::SlotMap` maps AOT frame offsets to JIT ones by ranges of
  translated bytes (injective, so the parallel move never overwrites a byte it still
  reads); bytes in no range keep their offset, as escaped objects must (pointers to them may
  be anywhere) and the incoming arguments do. `remap_slots` renames every frame operand of
  the reduced code: native instructions' slots and memory pointers, call argument lists,
  island operand words, and handler arguments that hold slots (found through the handler's
  layout, a 32-bit half for a shared register). Positions don't change, so targets, cleanup
  entries, dropped stores and heads stay valid; scopes keep their bytes' new offsets. By
  default the JIT keeps the AOT layout (the identity map), so every entry is a jump.
- **Shuffled layout** (`RYO_JIT_SHUFFLE`, `frame::shuffle_map`), to catch any reliance on
  matching frames: every byte below `fp` that no escape covers moves down by `F + 64`, into a
  frame of `2F + 64` (so the outgoing area is at `rsp` again, frames of 2016 bytes and more
  probe, and the moved bytes land below all the old ones); escaped objects stay. An access
  that would straddle an escaped object and moved bytes pins its bytes too, and an address
  taken of bytes no escape covers keeps the function's AOT layout. Island operands' extents
  aren't known: each lies in one object, and a function with islands keeps its AOT layout
  if that pinning went past the escapes (it may have split such an object). A function
  whose frame can't be shuffled is compiled in its AOT layout (logged with `RYO_JIT_LOG`).
- **Liveness** (`frame::head_liveness`): which frame bytes each head's entry must move, by a
  backward pass over the reduced code with landing pad edges. It is conservative: inline
  instructions, `ret`, `arg` and call results read and write exactly their widths (a
  result in two parts with a gap between them clobbers its extent instead), handlers
  read 16 bytes per slot operand (or the lengths of `copy`, `const`, `zero`, `load.copy`,
  `store.copy` and `fill`) and kill nothing, and calls and islands read every byte (the stack
  arguments and the island operands' extents aren't in the code). Escaped bytes don't move,
  so their liveness doesn't matter.
- **Unwinding**: the OSR code has an FDE of its own, without an LSDA (nothing in it unwinds
  but through the probe). With a frame pointer its rules are the body's (CFA = `rbp + 16`);
  without, CFA = `rsp + F_aot + 24` while the stub's return address is on the stack,
  `rsp + F_aot + 16` after the `pop`, and `rdx + 16` once `rdx` is `fp`, until the jump into
  the body, whose FDE describes `F_jit`.

## The SSA tier

By default (`RYO_JIT_OPT=ssa`; `ssa-naive` and `reencode`, [Settings](#settings)) the JIT
compiles a function through an SSA tier instead of re-encoding it: decoded reduced code → an SSA IR whose frame
slots are *allocas* with provenance, promoted to SSA values where no pointer can reach
them → x86-64 with a register allocator. It lives in `ryo_bytecode::jit` (`alloc`), so
that it is tested without the runtime; `install.rs` calls `jit::compile` in place of
`asm::encode_reduced_at`. A function it doesn't handle (`jit::Unsupported`, with the reason
under `RYO_JIT_LOG`) goes through the re-encoding pipeline, which stays the fallback and the
`reencode` mode: PE images, 16-byte SSE arguments and results, an island operand without a
`Lend` scope, a frame access in the return address's 16 bytes or below the frame, more than
about 65 000 slot shapes or 8 million variable × block definitions. In the corpus that is
about one function in 500. Handlers stay calls, and nothing is speculated: the AOT code stays the
baseline the tier refines.

### IR

`jit::ir`: blocks with parameters (no phis), instructions in an arena, `u32` ids.
- **Values** are untyped bit vectors of 1, 2, 4 or 8 bytes: an operation of width `w` reads
  the low `w` bytes of its operands, and the rest of a register or slot holding a value is
  unspecified. Compares give 1-byte booleans. Constants and `undef` are values without a
  definition.
- **Instructions**: the native reduced instructions on values (`Bin`, `Cmp`, `PtrAdd`,
  `PtrIndex`), `AllocaAddr`, `Load`/`Store` through a pointer, `ALoad`/`AStore` of a memory
  alloca, `OsrLoad` (OSR entries only), `LandingPad` (the exception object, `rax`),
  `HCall` (a handler call: its `In` values are stored to a scratch area whose offsets its
  slot operands get, its `Out` values loaded back, and a `br`/`switch` handler's return
  value is a result; or, `hcall.reg`, the same through the handler's [register
  entry](#register-entries)), `Call` and `Island`.
- **Terminators**: `jmp`, `br` (on a boolean), `brcmp`, `switch` (a switch handler's
  index), `ret`, `tail_call`, `trap`, and `invoke`: a call, island or `resume` with a
  landing pad ends its block, with a normal edge (to a fresh single-predecessor block that
  stores the results) and an edge to a *pad stub*, one per call site, which takes the
  exception object and jumps to the code after the `lpad`. The call defines its results;
  only the normal edge's block uses them. No moves are ever needed on the exceptional edge.
- Every edge, the switch's included, may carry arguments. `Func::verify` checks dominance,
  argument counts and widths (`RYO_JIT_CHECK`), and `Func` prints as text.

### Frame and provenance

`jit::alloca` cuts the AOT frame into allocas: byte ranges that no access crosses, by
union-find over the bytes of every access (with the handlers' exact effects,
`jit::effects`, checked against the handlers without memory effects or operand-given lengths
by `vm/rt/tests/ops.rs`, and against the Lean `opSem` footprints by
`vm/rt/tests/lean_opsem.rs`), every escaped
object (`Escape` scopes), every island operand (`Lend` scopes,
[vm.md](vm.md#escapes-storage-ends-and-island-operands)), and the lengths of block-copying
handlers. Each is:
- **promoted** when no escape covers it, no island or block handler touches it, and every
  access is a 1, 2, 4 or 8-byte field: a reaching-shape dataflow (per byte, the
  `(offset, width)` that last wrote it) gives each read the variable it reads, so a slot
  reused at another width splits into variables; a read that two shapes reach keeps the
  alloca in memory. Its fields are SSA variables: mem2reg and scalar replacement in one;
- **memory**, placed by the JIT anywhere in its frame, at an offset congruent to its AOT
  one modulo 16 (so every byte keeps its alignment);
- **outgoing**: the longest run from the frame's bottom of bytes nothing reads and no
  pointer reaches (the stack arguments the calls read, and island argument blocks), kept at
  the JIT frame's bottom;
- **incoming**: positive offsets, the caller's argument area, never moved. Its fields that
  are only read (whole, not overlapping) are variables too, loaded at the entry.

A read past the frame's top (`ret` and the calls load a 3, 5, 6 or 7-byte value as the next
power of two) counts only for its bytes inside the frame; the rest don't matter. A
zero-sized island operand accesses nothing (the lowering records its `Lend` too).

Moving objects relies on the source's provenance (no access through a pointer to bytes
that aren't escaped, no pointer from one object reaching another, addresses not
observable before they escape); [verification.md](verification.md#the-jit) states the
frame-layout-parametric semantics this needs.

### Construction

`jit::decode` classifies each instruction with its exact accesses and cuts blocks (leaders:
targets, after branches, calls with a landing pad, landing pads, loop heads), with the CFG
including landing pad edges. `jit::build` is Braun et al.'s construction (CC 2013) over
the promoted variables: blocks are filled in layout order and sealed once their
predecessors are; parameters get an operand row per predecessor while being built, trivial
ones become aliases, and the edges' argument lists are written once at the end. Copies
(`mov`), constants (`imm`) and trivial parameters disappear on the way. Then `jit::lvn`, local
value numbering, one forward pass per block in reverse postorder: pure operations on
constants fold, with algebraic identities (`x + 0`, `x * 1`, `x - x`, `p + i * s` with a
constant `i`, `PtrAdd` chains); a pure operation repeated in its block is replaced by the
first; and a load of alloca bytes, or of a pointer value plus an offset, that an earlier load
or store of the block left known is replaced by that value. Only what may write them forgets
them: a store through a pointer the other pointers' bytes and the escaped (or pinned)
allocas, a store to an alloca its own bytes, a handler the allocas it names and, if it
touches memory, what a pointer store does, a call also the outgoing area, an island
everything. Then the folds
instruction selection relies on: a compare used only by the following branch becomes a
`brcmp`, an overflow op (`add`/`sub`/`mul.ovf`) whose flag only the branch ending its block
reads becomes a `br ovf` on the flags it leaves, and loads and stores through an `AllocaAddr` or a `PtrAdd` take its alloca or
constant into their address.

### OSR

Only **cyclic** heads (on a cycle of the CFG, landing pad edges included) get OSR entries;
the other heads are backward jumps of the block layout that an activation passes at most
once, so entry stays bounded. Their AOT counter checks still trip once the function is
compiled, and the dispatcher's entry for them is a `ret` back into the AOT code. Each
cyclic head's entry is a block with no predecessors that jumps to the head: Braun's reads
there find nothing and become `OsrLoad`s of the AOT frame, so exactly what something reads
after the head is loaded. A forward dataflow of the escape scopes gives the memory allocas
that may be escaped at a cyclic head: those are **pinned** at their AOT offsets (pointers
to them may be anywhere); every other alloca moves. The entry code: `pop rcx`, `rsp` to a
scratch area below both frames, every `OsrLoad`'s bytes and every moved memory alloca read
from the AOT frame into it, the callee-saved registers saved (they still hold the caller's
values: AOT code never touches them), the allocas copied to their JIT offsets, the head's
parameters set from the scratch copies (registers last, `rdx`, the base without a frame
pointer, last of all), `rsp = fp - F_jit`, `jmp` to the head.

### Back end

- **Frame** (`jit::emit`): `fp` is the address below the return address, as in AOT code.
  Below the pinned allocas: the callee-saved registers' save slots (`mov`s, not pushes),
  the moved allocas, the spill slots, the handler scratch area, and the outgoing area at
  `rsp`. The prologue is `sub rsp, F + 8` (or `push rbp; mov rbp, rsp; sub rsp, F` with
  `fp-rbp`), with the probe from `PROBE_FROM`; handler and island operands are `fp`
  offsets either way.
- **Instruction selection**: per instruction over the allocated locations; two-address
  forms with a hint to reuse the first operand's register, immediates where they fit
  (`r10` takes the others), `[base + index*scale]` for `ptr.index` by 1, 2, 4 or 8,
  `setcc`, compare-branches fused, overflow ops as `add`/`sub`/`imul` (8 and 16-bit
  multiplies, and unsigned 32-bit ones, in 32 or 64 bits with a range check; unsigned 64-bit
  ones as `mul`, `rax` and `rdx` saved in `r10`/`r11` around it) with `seto`/`setb`/`seta`, or
  their `jcc` for `br ovf`, extensions as `movzx`/`movsx`/`mov r32`, fall-through layout. `r10` and `r11` are the emitter's
  scratch registers and never allocated.
- **Calls**: `hcall.reg` moves its `In` values into the first argument registers (a
  parallel move), sets the data registers after them, calls the register entry and moves
  its results out of `rax` and `rdx` ([Register entries](#register-entries)). `hcall`
  stores its `In` values to the scratch area, sets the argument
  registers (the slot operands' offsets patched into them), calls the handler and loads
  its `Out` values, each at its width (a wider load of what the handler just stored would
  miss the store forwarding); VM and native calls move their arguments into the argument registers
  as a parallel move (`xmm` ones by `movq`, or `movd` for 4 and 2-byte parts, which reads
  the 8-byte slot a value lives in), the callee of `call.ptr` into `rax`; islands
  get `fp` and an operand array of JIT offsets in the function's code constants. All of
  them clobber every caller-saved register.
- **Edges**: parallel moves, sequentialized with `r11` for memory-to-memory moves and
  `r10` to break cycles; a conditional edge with moves goes through a stub after its block.
- **Unwinding**: the body's FDE rows are the CFA after the prologue and a `DW_CFA_offset`
  per saved register; the LSDA's call sites are the calls with a landing pad (to their
  pad stub) or a `Continue` entry, as in AOT code. Values live into a pad live across the
  call, so they are in callee-saved registers or the frame, which the unwinder restores.

### Register entries

Every handler that returns and whose frame operands are all scalars has a second entry,
`ryo_hr_<Opcode>`, that takes those operands' values in registers and returns its results in
registers, for `hcall.reg`. The frame entry `ryo_h_<Opcode>` stays as it is (AOT code calls
only it, and is unchanged).

- **Which**: `jit::effects::reg_entry(op, mode)`, a `const fn` from the handler effect table
  (`effects`, also `const`) and the register layout: `op`, `br` and `switch` shapes (not
  `resume`, `lpad` or traps) whose frame operands are each read, written or updated at 1 to
  8 bytes (no `addr`, no block operands, no `w128`), with at most six inputs and data
  registers and at most two results: most handlers.
- **Convention**: `extern "sysv64-unwind" fn(a0, …, a5: u64) -> (u64, u64)`. The arguments
  are, in order from `rdi`: the values of the frame operands it reads (by operand order,
  each in its register's low bytes, the rest ignored), then whole every argument register of
  the frame entry's layout that holds anything but a slot offset (immediates, addresses,
  case tables, a `Mem` operand's displacement; their slot-offset halves are ignored). No
  `fp`. The results are the values of the frame operands it writes (by operand order; for an
  update, the new value), then the `br`/`switch` return value, in `rax` then `rdx`, each in
  the low bytes. It clobbers what any `sysv64` call does: the SSA tier keeps nothing in a
  caller-saved register across it, as for every call. A `preserve_none`- or
  `preserve_most`-like convention, which would let values stay in caller-saved registers,
  isn't available to Rust functions without a naked wrapper; the entries are leaf functions
  of a few instructions, so the cost is in the caller's register pressure, not in them.
- **Generation**: `handlers!` (`ryo_rt`'s `interp.rs`) instantiates each handler body a
  second time in `hr`, on a local buffer of eight 8-byte words as its frame (`fp`) with the
  operand slot offsets replaced by constants (`8 × operand index`), the inputs stored to it
  first and the outputs read from it last. Every offset is then constant, so LLVM keeps the
  buffer in registers: `ryo_hr_AddOvfUW64` is `mov rax, rdi; xor edx, edx; add rax, rsi;
  setb dl; ret` against the frame entry's nine instructions, `ryo_hr_ZextW32W64` is `mov eax,
  edi; ret`. `vm/rt/tests/codegen.rs` checks that every entry exists and keeps nothing on
  the stack, `vm/rt/tests/reg_entries.rs` runs every entry against its frame entry on random
  operands.
- **Interface**: `RtApi::reg_handlers` gives their addresses (null without one), the JIT
  relocates `Ref::RegHandler` against it (`JIT_ABI_VERSION` 3), and `RYO_JIT_DUMP` names them
  `ryo_hr_<Opcode>`.
- **Use**: the builder makes a handler call `hcall.reg` when the handler has a register
  entry and every frame operand is a promoted variable; otherwise (an operand in a memory
  alloca, a handler without one) it calls the frame entry through the scratch area. The
  register allocator hints the results to `rax`, `rdx`.

### Register allocation

`jit::regalloc`:
- **`ssa-naive`**: every value in a stack slot of its own: the correctness baseline, kept as
  a stress mode.
- **`ssa`**: linear scan on SSA without splitting. Exact block liveness (an iterative
  dataflow), then each value's interval is the hull of its live positions in the linear
  block order (holes are ignored), and it lives in one register or one slot throughout.
  Intervals that cross a call or handler call take callee-saved registers (`rbx`,
  `r12`–`r15`, `rbp` without a frame pointer); others prefer the caller-saved ones; hints
  are the first operand's register, an incoming edge argument's for a parameter, the
  argument register for an entry parameter, and `rax`/`rdx` for results. When no register
  is free, the interval ending last is spilled.
- **Checker** (`RYO_JIT_CHECK=1`): `regalloc::check` walks each block backward from its
  exact live-out set and checks that no location holds two live values, that nothing lives
  across a call in a caller-saved register, that `r10`, `r11` (and `rbp` with a frame
  pointer) aren't allocated, and that every use has a location; with `Func::verify` before
  it. A failure is printed on stderr and the function stays in its AOT code (`Failed`), so
  that the corpus (which compares stderr) and the JIT tests (which check where code runs)
  see it.

### Choices

- The tier lives in `ryo_bytecode::jit` (testable without the runtime, next to the
  decoder).
- Island operand extents come from `Lend` scopes in the image (`FORMAT_VERSION` 21); an
  island operand without one makes the function `Unsupported`.
- Allocas escaped at a cyclic head are pinned (one code version); a separate OSR version
  that pins nothing is the follow-up.
- The handler effect table is by family from the mnemonics, checked against the handlers.
- An in-tree linear scan, no new dependencies.
- Handlers stay calls, through their register entries where they have one; native handler
  operations (overflow arithmetic, extensions, …) are the follow-up, as are splitting and
  rematerialization.
- The re-encoding pipeline stays, as the fallback and the `reencode` mode.
- Only 1, 2, 4 and 8-byte integer fields are promoted (`w128` values and floats stay in
  memory; floats move through general-purpose registers at calls).
- AOT code keeps its counter checks at acyclic heads, and the dispatcher returns into the
  AOT code there.
- Two scratch registers (`r10`, `r11`) rather than one: simpler instruction selection and
  moves at the cost of one allocatable register.
- Intervals without holes, and no allocation hint beyond the above: the first allocator
  is simple; holes, splitting and a regalloc2 comparison are follow-ups.

## Packaging

The JIT thread is the `ryo_jit` crate, which `y build` turns into one object that `ryo_rt`'s
rlib bundles (`build/src/jit.rs`, [build.md](build.md#build)):

- **Interface** (`ryo_bytecode::jit_abi`, `core` only, so neither crate depends on the
  other): `extern "C" fn ryo_jit_start(rt: &'static RtApi) -> bool`, the JIT's only symbol,
  and `RtApi`, which the runtime builds once, at the first push:
  | Field | |
  |---|---|
  | `abi`, `format`, `size` | `JIT_ABI_VERSION`, `FORMAT_VERSION` and `size_of::<RtApi>()`, checked by `RtApi::compatible`: on a mismatch the start fails |
  | `flags` | `JIT_SYNC`, `JIT_LOG`, `JIT_PERFMAP`, `JIT_TEST_PANIC`, `JIT_OPT_SSA`, `JIT_OPT_SSA_NAIVE`, `JIT_CHECK` ([Settings](#settings)) |
  | `probe` | `ryo_probe_stack`'s address |
  | `personality` | the program's `rust_eh_personality`'s address, by which the JIT finds an image's personality slot |
  | `next_batch` | the queued records in trip order, sleeping while there are none (the JIT thread only) |
  | `done` | reports a record: compiled (after the JIT published it), or failed (the runtime marks it `Failed`); wakes its waiters |
  | `shuffled` | whether an image's functions get shuffled frames |
  | `handlers` | every opcode's handler address, null for opcodes without one |
  | `reg_handlers` | every opcode's [register entry](#register-entries) address, null for opcodes without one |

  `REDIRECT` and `JIT_ENTRY_PREFIX` are there too. Nothing crosses the interface by
  unwinding: the callbacks are `C-unwind` only for the reason the trips are. Records,
  images and code are shared memory in `ryo_bytecode`'s layout; both sides build their
  reader from the same source in one `y build`. Publishing (the release stores to the
  record and the call slots) is the JIT's.
- **A private std**: `ryo_jit` is built as a staticlib with fat LTO, against the native
  std, whatever the sysroot. That leaves one object with the JIT and std; its definitions
  but `ryo_jit_start` are then made local (ELF) or renamed to `__ryo_jit$<name>` (COFF,
  where they can't be made local; LLVM's content-named constants `__xmm@…` keep their
  names and merge by content), and its debug information is stripped. `compiler_builtins`
  is left out: its functions bind to the program's copy, which every Rust link has, native
  even under `--sysroot ryo`. Its undefined symbols are the C library's, the OS's and the
  unwinder's, so it reaches nothing of the program's std, and the program nothing of its.
  Unsealed, a second std in the program would clash (duplicate `rust_eh_personality`,
  `std::panicking::EMPTY_PANIC`) or, worse, bind to the program's (VM-compiled under
  `--sysroot ryo`). The JIT allocates with its own std's allocator (`malloc`), never the
  program's `#[global_allocator]`, and catches its panics even in a `-Cpanic=abort`
  program. Its panic hook keeps its panics, which only fail a function, off stderr but
  with `RYO_JIT_LOG`.
- **Bundling**: `ryo_rt`'s build script links it (`-l static=ryo_jit` from
  `RYO_JIT_LIB_DIR`), so rustc copies it into the rlib, and it goes wherever `ryo_rt` is
  linked statically: the binary, a Rust dylib (where rustc's version script keeps
  `ryo_jit_start` local), a cdylib, a staticlib (as a member). It is a native member, never
  LTO input, so users' `-Clto` doesn't touch it. The backend and the image format don't
  know about it. Without `RYO_JIT_LIB_DIR` (`vm/`'s own tests) the `ryo_jit` rlib provides
  `ryo_jit_start` instead, on the tests' std.
- **PE**: `y build` seals and bundles it the same way, but there `ryo_jit_start` returns
  false until the JIT is ported ([platforms.md](platforms.md)).
- **Cost**: the sealed object is about 1.6 MB, and a binary's text is about 0.24 MB larger
  than with the JIT on the program's std (a private std's threads, panics, formatting and
  collections; on PE, with the stub, the file grows by about 50 KB). A proc macro carries
  it too (0.25 MB): the linker doesn't drop it there.

## Settings

Read once by the runtime side, with the C runtime's `getenv`, and passed on in
`RtApi::flags` (`vm::configure_jit` sets them in tests, and `vm::jit_shuffle_image` asks
for shuffled frames per image, `RtApi::shuffled`):

| Variable | Effect |
|---|---|
| `RYO_JIT=off` | the no-op JIT; registration sets every counter to `i64::MAX` |
| `RYO_JIT_THRESHOLD=n` | registration sets every counter to `n`, and trips reset to it; 0: trip at the first call |
| `RYO_JIT_SYNC=1` | a trip that finds its record queued waits on a futex on `state` until it leaves `Queued`, then continues in the JIT code; nested trips on that thread and trips on the JIT thread never wait |
| `RYO_JIT_PERFMAP=1` | the [perf map](#unwinding-and-profiling) |
| `RYO_JIT_LOG=1` | a line on stderr per compiled or failed function, and per function whose frame couldn't be shuffled, and the JIT thread's panics |
| `RYO_JIT_SHUFFLE=1` | JIT frames in another layout ([OSR](#osr)) |
| `RYO_JIT_TEST_PANIC=1` | tests: every compile panics, which must fail the function and nothing else |
| `RYO_JIT_OPT=…` | `ssa` (the default), `ssa-naive` or `reencode`: how functions are compiled ([The SSA tier](#the-ssa-tier)); with `RYO_JIT_SHUFFLE` the SSA tier lays allocas out in reverse with gaps |
| `RYO_JIT_CHECK=1` | the SSA tier's checkers: a failure is printed on stderr and the function falls back |
| `RYO_JIT_DUMP=dir` | the SSA tier writes each function's reduced code, IR before and after value numbering and the folds, locations and code (or, for one it doesn't handle, the reason and the reduced code) to `dir/f<index>-<image header address>.txt`, and every installed function's code with its relocations by name to `dir/f<index>-<image header address>.code` (for `y bench codegen`, [build.md](build.md#test-and-bench)); read by the JIT thread itself, not passed in `RtApi` |
| `RYO_JIT_SSA_LIMIT=n` | debugging: only the first `n` functions the JIT compiles go to the SSA tier, the rest are re-encoded (bisects a miscompile; read by the JIT thread) |

## Limits

- A child of `fork` has no JIT thread, so with `RYO_JIT_SYNC` its trips wait forever.
- Tail calls of functions compiled later stay through their AOT entries.
- A program that interposes `malloc` itself with Rust code (which may call VM code) would
  run that code on the JIT thread, and with `RYO_JIT_SYNC` could deadlock.
- Each `ryo_rt` copy in a process (cdylibs, a staticlib per C link) has its own JIT,
  thread, code regions and private std. Two ryo staticlibs in one C link both define
  `ryo_jit_start`, a duplicate-symbol error, like `ryo_vm_register` already is (one ryo
  staticlib per final C link, [backend.md](backend.md#pipeline)).
- `#![no_std]` final artifacts don't link with the native sysroot: the sealed object needs
  libc, libpthread and the unwinder, which std brings.
- The trips on PE have no SEH unwind information: nothing unwinds through them, but a
  debugger's stack walk stops there.

## Testing

- **`vm/jit/tests/jit.rs`** (`y test` runs it with and without `ryo_rt`'s `fp-rbp`; it links
  `ryo_jit` as an rlib, on the tests' std, so it tests the compiler and the trips, not the
  sealing): with threshold 0 and `RYO_JIT_SYNC`'s waiting, functions give the AOT code's
  results with arguments of every kind, in JIT code (checked by return addresses within
  `jit_code`), a recursion switches over midway, panics unwind through JIT frames with
  their landing pads, JIT code calls JIT and AOT functions, and sixteen threads trip at
  once. With and without shuffled frames, OSR at every head pass of a few loops keeps the
  values live at the head (integers of every width, floats, `w128`, an escaped local read
  through a pointer and directly), at the outer and inner heads of nested loops, a panic
  after OSR runs the JIT frame's landing pad, `rsp` moves by the frames' difference, and a
  thread spinning in an AOT loop and one deep in a self-recursion, both started before the
  compile, reach JIT code without returning (a native callee checks its return address).
- **The corpus**: `RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1 y test` runs it with every function's
  JIT code from its first call, and `RYO_JIT_THRESHOLD=16` instead enters it by OSR at the
  first loop head pass of each function's first call (whose entry check leaves the counter
  at 0), both also with `RYO_JIT_SHUFFLE=1`. With a ryo sysroot, `y test` runs the corpus
  that way (`ryo-std-jit`, `ryo-std-jit-shuffle`), std's own VM functions included
  ([build.md](build.md#test-and-bench)).
- **The SSA tier**: `y test` runs `vm/jit/tests/` through the tier with its checkers, then
  with `RYO_JIT_OPT=ssa-naive` and with `reencode` (each with and without `fp-rbp`; through
  the tier `rsp` moves by a multiple of 16 instead of the frames' difference), whose SSA-specific tests cover an alloca escaped only
  after the head (moved at OSR), an acyclic head (the trip returns into the AOT code), a slot
  reused at two widths, handler results feeding branches, a value live into a landing pad
  across a call, and sixteen values live across a call. `vm/jit/tests/ssa.rs` (a process of
  its own) checks, by `ryo_jit::ssa_stats`, that its functions go through the tier: switch
  tables with edge arguments, sparse switches, tail calls with stack arguments and through
  a pointer, SSE arguments and results, a catching landing pad, probed 12 KiB frames entered
  by OSR, and an alloca pinned at the head. Then the corpus on its own VM
  functions through the tier (`ryo-jit-ssa`, threshold 0, and `ryo-jit-ssa-osr`, OSR at the
  first head pass; with a ryo sysroot, `ryo-std-jit` and `ryo-std-jit-shuffle` go through
  the tier too, and `ryo-std-jit-reencode` through the re-encoding pipeline). `vm/bytecode/tests/jit_ssa.rs`
  builds hand-written functions' IR (promotion, block parameters at a loop head and its OSR
  loads, reaching shapes, pinned and moved escaped locals, handler slots sharing a register),
  `tests/jit_x86.rs` checks the
  encoder against `objdump`, and `vm/rt/tests/ops.rs` the handler effect table.
- **Packaging**: `jit-sealed` (`y test`, and `y test --cross` for PE) checks the bundled
  object: only `ryo_jit_start` (and the renamed symbols and constants) defined globally, no
  Rust symbol or allocator shim referenced, no unwinder defined, and on COFF no `.drectve`
  or `.CRT$X*` section. `jit-private-std` runs `tests/vm_jit_private.rs`, whose VM global
  allocator trips while it holds its lock (with the program's allocator, the JIT would
  deadlock there), and the same program built with `-Cpanic=abort` and run with
  `RYO_JIT_TEST_PANIC`, which must run as without the JIT.
- The counters' code shape, its round trips and the trips of the no-op JIT are tested with
  the encoder ([vm.md](vm.md#jit-records-and-counters)).

## Future work

The SSA tier doesn't optimize beyond promotion, copy and constant propagation, local value
numbering and its folds: passes, inlining, more native handler operations, interval splitting and an OSR version
that pins nothing are the next steps, behind the same records, trips, OSR entries and
packaging; [verification.md](verification.md#the-jit) describes how its output would be
validated.
