# JIT

With its `jit` feature (`y build` enables it on x86_64 Linux and windows-msvc, in both
sysroots, [build.md](build.md#build)), `ryo_rt` recompiles hot VM functions on a background
thread and switches their entry and loop heads over to the new code. Every image is built
for it: each function counts its calls and loop iterations in a *JIT record* and leaves
through a stub into the runtime when the count runs out ([vm.md](vm.md#jit-records-and-counters)).

The JIT code is the function decoded and encoded again, without counters and, for now,
without optimizations. Its frame may differ from the AOT code's (it does with
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
- **Encoding**: `asm::encode_reduced_at` in the image's mode without counters (in another
  frame layout with `RYO_JIT_SHUFFLE`, [OSR](#osr)), which also gives the instructions'
  positions for the OSR entries, then the OSR entries. A failure (decode, encode, reach,
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

## Packaging

The JIT thread is the `ryo_jit` crate, which `y build` turns into one object that `ryo_rt`'s
rlib bundles (`build/src/jit.rs`, [build.md](build.md#build)):

- **Interface** (`ryo_bytecode::jit_abi`, `core` only, so neither crate depends on the
  other): `extern "C" fn ryo_jit_start(rt: &'static RtApi) -> bool`, the JIT's only symbol,
  and `RtApi`, which the runtime builds once, at the first push:
  | Field | |
  |---|---|
  | `abi`, `format`, `size` | `JIT_ABI_VERSION`, `FORMAT_VERSION` and `size_of::<RtApi>()`, checked by `RtApi::compatible`: on a mismatch the start fails |
  | `flags` | `JIT_SYNC`, `JIT_LOG`, `JIT_PERFMAP`, `JIT_TEST_PANIC` ([Settings](#settings)) |
  | `probe` | `ryo_probe_stack`'s address |
  | `personality` | the program's `rust_eh_personality`'s address, by which the JIT finds an image's personality slot |
  | `next_batch` | the queued records in trip order, sleeping while there are none (the JIT thread only) |
  | `done` | reports a record: compiled (after the JIT published it), or failed (the runtime marks it `Failed`); wakes its waiters |
  | `shuffled` | whether an image's functions get shuffled frames |
  | `handlers` | every opcode's handler address, null for opcodes without one |

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

The JIT doesn't optimize yet. An optimizing tier (SSA construction, passes, inlining,
register allocation) would sit behind the same records, trips, OSR entries and packaging;
[verification.md](verification.md#the-jit) describes how its output would be validated.
