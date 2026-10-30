# JIT

`ryo_rt` (on every supported target, x86_64 Linux, windows-msvc and macOS, in both sysroots,
[build.md](build.md#build)) recompiles hot VM functions on a background
thread and switches their entry and loop heads over to the new code. Every image is built
for it: each function counts its calls and loop iterations in a *JIT record* and leaves
through a stub into the runtime when a counter stops being negative ([vm.md](vm.md#jit-records-and-counters)).

The JIT code is the function compiled through an SSA pipeline with a register allocator ([The
SSA pipeline](#the-ssa-pipeline)), or, where that pipeline doesn't handle it (or with
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

1. Its AOT code counts its calls and loop iterations up in its record's `ctr_e` and `ctr_l`
   (from `-JIT_ENTRY_THRESHOLD`, 625, and `-JIT_THRESHOLD`, 10 000) and, when one stops
   being negative, calls through the record's `entry` or `osr` slot: a *trip* into the
   runtime.
2. The first trip queues the record and wakes the JIT thread, which decodes the function
   from its image, encodes it again, installs the code near the image, and publishes it in
   the record.
3. From then on the counters have the `Done` bias, so every check takes its stub: an entry's
   straight into the JIT code, a loop head's into an OSR entry. The slots are redirected,
   no AOT code is patched.

## Records and trips

The record (`image::JitRecord`, 64 bytes, one per function in the image's writable
section; its fields and the counter checks and stubs that use it are in
[vm.md](vm.md#jit-records-and-counters)) is the runtime's once the image is registered. Its
`state` moves `Cold → Queued → Done` (or `Failed`), and only the JIT thread writes
`jit_code`, `entry` and `osr` after the writer.

- **Trips** (`ryo_jit_trip_entry`, `ryo_jit_trip_osr`, `vm::trip_entry` and
  `vm::trip_osr`), lock-free:
  - `Cold`: `state` CAS `Cold → Queued`; the winner pushes the record onto the queue and
    wakes the JIT thread. The counters get the `Queued` bias, and the stub continues the
    AOT code.
  - `Queued`, `Failed`: the counters get the bias (if a racing increment erased it).
  - `Done`: the entry's trip continues in the JIT code; a loop head's jumps to the
    record's `osr` slot, the OSR dispatcher, in assembly. Only a stub that read the slot before the publication
    gets there: the stubs call the dispatcher directly afterwards. A trip that waited for
    the compile (`RYO_JIT_SYNC`) continues the same way.
- **Registers**: the trips may clobber only `rax`, `r11` and the flags (vm.md's counter
  stubs' contract). `ryo_jit_trip_entry` saves the argument registers (`rdi`…`r9`,
  `xmm0`–`xmm7`) in a 192-byte area, which keeps `rsp` 16-aligned for the Rust call (`rsp`
  is 16-aligned at the trip), and restores them; it returns to the stub, or jumps to the
  JIT entry, with the stack as it found it. `ryo_jit_trip_osr` saves only `eax`, the
  head's index, for the dispatcher: nothing else is live at a head. On PE they also save
  `xmm8`–`xmm15` (entry, a 320-byte area) and `rdi`, `rsi` and `xmm6`–`xmm15` (loop head),
  callee-saved on Win64 but not for the `sysv64` Rust code they call (`rdi` and `rsi` are
  among an entry's argument registers); with `ryo_rt`'s `pe-test` the Linux trips save the
  same, for PE code run off Windows. On Windows they carry unwind info (`.seh_*`: the area
  and the nonvolatile registers saved in it), so stack walks and a panic in their Rust code
  get through them; they test the Rust code's result before the restore and end in two
  epilogues of the forms the Win64 unwinder recognizes (`add rsp`, the pops, then `ret` or
  `rex.w jmp r11`), so an asynchronous walk gets through them anywhere.
- **No unwinding**: the Rust parts can't panic: nothing may unwind out of them, since the
  stubs aren't call sites. They are `sysv64-unwind`/`C-unwind` only so that the compiler
  adds no abort-on-unwind guard, which would reach core's panic path ("No re-entry").
- **Counters** count up from minus their thresholds, and the runtime moves a bias with the
  record's state ([vm.md](vm.md#jit-records-and-counters)): none while `Cold`, `-JIT_BIAS`
  (2^62) while `Queued` or `Failed`, `+JIT_BIAS` once `Done`. It changes a bias only by a
  compare-exchange that keeps the count (`image::jit_settle`), and re-reads `state` after
  it, so a trip racing the publication leaves the final state's bias. An AOT increment that
  read the value before the exchange and writes after it erases the bias: a lost `Queued`
  bias costs a spurious trip, which restores it; a lost `Done` bias would leave the
  function in AOT code, so the JIT thread re-checks each record it published after its
  next batches, or after a millisecond without one, until it has seen the bias twice.
  Registration sets the counters from `RYO_JIT_THRESHOLD` if it is set, and to the
  `Failed` bias with `RYO_JIT=off` ([Settings](#settings)).
- **Counts**: the count is the value less its bias plus its threshold
  (`image::jit_count`), so the JIT thread reads exact call and loop-iteration counts of the
  AOT code with a plain load (`install::counts`; `RYO_JIT_LOG` prints them).
- **The no-op JIT**: with `RYO_JIT=off`, or once the JIT couldn't start, a trip settles
  both of the record's counters at a failed record's bias (`jit_settle`, keeping their
  counts), so the function never trips again in practice, and the stub continues the AOT
  code. An `inc` racing the settle may erase the bias; the counter then trips again later,
  harmlessly. The JIT is always built in: there is no build of `ryo_rt` without it.

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
  can't start (it returns false, as on PE for now, or if the thread doesn't spawn),
  every queued record fails (its waiters woken) and the trips act as the no-op JIT. It
  takes the queue with `RtApi::next_batch` (which sleeps on the futex while it is empty),
  compiles each record, catching its panics, and reports it with `RtApi::done` (counted, or
  `Failed`; the waiters woken). It is detached; exiting mid-compile is fine.
- **Allocation failure** is a panic on the JIT thread, not std's abort: `thread::oom_panics`
  sets an allocation error hook (`std::alloc::set_alloc_error_hook`; `-Zoom=panic` is gone
  from the pinned toolchain) that panics on `ryo-jit` and leaves other threads to the hook
  before it (in the sealed JIT, whose std is private, std's default abort; as an rlib, the
  program's). So an OOM fails the function, which keeps its AOT code. What makes that safe:
  everything on the thread that allocates runs inside a `catch_unwind` (the compile, the
  failure's log line; `recheck`'s room is reserved before the compile), so no panic ends the
  thread or reaches `ryo_rt` (`RtApi`'s calls don't allocate in the JIT); and `install`
  allocates nothing from `JitRecord::publish` on (the log line is formatted before), so a
  published record is always reported compiled. A panic before publication leaves only
  harmless state: the region space it took is lost, call slots it made are complete (they
  hold their callee's address and are retargeted on its publication), code registered with
  the unwinder is never reached. Code memory failing to map is an error (`vmem::reserve_code`
  returns `None`: no region, the function fails). The panic itself allocates its payload: a
  failure there is a second panic, which aborts, as in a truly exhausted process.

## Compiling and installing

`vm/jit/src/install.rs`, per record:

- **Decoding**: `image::ImageResolver::decode` from the image alone (the handler table is
  every `ryo_h_*` handler's address with its opcode, from `RtApi::handlers`, sorted, built
  once; the probe `ryo_probe_stack`, `RtApi::probe`). The decoder reads the counters'
  checks and stubs as part of the canonical form and lists the loop heads
  (`Decoded::heads`, [vm.md](vm.md#jit-records-and-counters)).
- **Encoding**: the SSA pipeline's `jit::compile` ([The SSA pipeline](#the-ssa-pipeline)), or, for a
  function it doesn't handle, `asm::encode_reduced_at` in the image's mode without counters
  (in another frame layout with `RYO_JIT_SHUFFLE`, [OSR](#osr)), which also gives the
  instructions' positions for the OSR entries, then the OSR entries. A failure (decode, encode, reach,
  memory) or a panic marks the record `Failed` (its counters get the `Failed` bias), and the thread goes on.
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
  image's three sections, and the handlers if it can), so the code keeps its image's fields
  `rel32`, as in AOT code. A mapping that reaches the image and the handlers is preferred;
  an image more than about 2 GiB from them (an executable whose `ryo_rt` is in a shared
  std, `-Cprefer-dynamic`) gets one that reaches the image only, and its code calls the
  handlers and the probe as `mov r11, imm64; call r11` (`Mode::far_rt`; `r11` is free at
  every call: no argument, never allocated, the emitters' scratch). One mapping serves every
  image it reaches, so images loaded close together (an executable's, or a library's) share
  one, and images far apart get their own. They are mapped read-write with `MAP_FIXED_NOREPLACE` at hints stepping away
  from the image (a result out of reach is unmapped and the next hint tried). A function
  takes whole pages from a mapping's start: the entry prefix at byte 4, the code at 16, the
  OSR code ([OSR](#osr)) 16-aligned, then its code constants (`Encoded::rodata`)
  16-aligned, copied next to the code rather than pointing at the image's (they are equal
  for an exact re-encode, but needn't stay so). The pages turn read-execute once written
  and are never written again or reused, so no cross-modifying code. Unwind information and
  call slots are taken from the mapping's end and stay read-write. A full mapping is
  retired and another mapped; a function of more than half a mapping fails.
- **Calls**: the mapping is chosen before encoding, and every `call`, `call.sym` and
  `tail_call` but a self-call gets its form for it. The callee is a VM function with a JIT
  record (a function of the image, or the function of any registered image whose AOT entry
  a `call.sym`'s symbol slot holds, found by `RtApi::image_at`), or a fixed address (native
  code, a VM function without a record). A known target (a compiled callee's JIT code, a
  fixed address) is called directly, `call rel32`/`jmp rel32`, if the whole mapping reaches
  it, else as `mov r11, imm64; call r11`/`jmp [rip]; .quad` (through memory, an epilogue's
  end to the Win64 unwinder). A VM function not compiled yet goes
  through a *call slot*, `call [rip + slot]`/`jmp [rip + slot]`: 8 bytes at the mapping's
  end, one per mapping and callee, holding the callee's AOT entry and then, once it is
  published, its JIT code (an aligned atomic store, no code patching). So calls and tail
  calls of another image's functions, and of functions compiled later, run their JIT code
  without the entry's counter check and stub once it exists. The reduced code carries the
  forms as function operands with a `FUNC_SLOT`, `FUNC_NEAR` or `FUNC_FAR` bit
  (`asm::FUNC_KINDS`) and the callee's index in the compile's list; both encoders emit them.
  A `call.sym` whose slot holds 0 (a weak symbol) stays through the image's symbol slot, as
  do `call.sym.ind` (PE) and island calls. Function pointers are untouched: `addr.sym` and
  native callers still get the AOT entry.
- **Relocation**: handlers and the probe by address (`imm64` with `far_rt`); the callees as
  above; symbol slots, sites, constants and the data area in the image, by the header's
  ranges, as the writer resolves them; code constants to the copy; the record (`Ref::Rec`,
  `Ref::RecLoopCtr`) to itself. Every one of these is in reach by the mapping's choice. If the
  mapping fills up before the function is installed, it is retired and the function is
  compiled again for another (its calls' forms depend on the mapping).
- **Decoding through PLTs**: code linked against a shared `ryo_rt` calls the handlers and
  the probe through PLT stubs. The resolver reads a call target outside the image as a
  stub (`jmp [rip + got]`, with `endbr64` and `bnd` in `.plt.sec`) and resolves the GOT
  slot's value, which `BIND_NOW` (Rust's default) has filled. A lazily bound slot points
  back into the PLT, which resolves to nothing: the function stays on its AOT code.
- **Folded handlers**: LLVM's MergeFunctions (and a linker's ICF) may give several
  handlers one address (the `ptr` and `w64` atomics fold in pairs). The resolver returns
  every opcode registered at a call's target, and the call's instruction list entry
  ([design/vm.md](vm.md#instruction-list)) picks the one it calls; an entry naming another
  opcode, or none, fails the decode.
- **Publishing**: `jit_code` (and the code's length in the JIT's own table), then `entry`
  and `osr` (release), then `state = Done`, then the counters' `Done` bias, then the
  function's call slots, of every mapping and image (kept by callee, so publishing visits
  only its own). Every later
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
- **PE** (`sys/windows.rs`): per function one `RUNTIME_FUNCTION` over the body and the OSR
  code, and the AOT code's `UNWIND_INFO` (`image::pe_unwind_info`: `push rbp; mov rbp,
  rsp`, the probe, `sub`, `rbp` the frame register at offset 0), in the
  region's read-write end, registered with `RtlAddFunctionTable` (base: the function's
  allocation, below both; never deleted, code is never freed). One entry covers the OSR
  code too: there the AOT frame's `rbp` is already in place (the
  stub's return address and the moving `rsp` don't matter with a frame register), so the
  body's description past its prologue is the OSR code's at every instruction, and an
  entry's `jmp` to its head stays inside the function, which the unwinder's epilogue check
  requires (a separate entry would make `pop rcx; jmp head` look like an epilogue). As in
  the AOT code, the `UNWIND_INFO` names `ryo_seh_handler` ([vm.md](vm.md#pe-seh)), with the
  LSDA of the JIT code's call sites as handler data: the handler RVA can't reach `ryo_rt`
  from the allocation, so it is a thunk after the OSR code, `jmp [rip]; .quad` the handler's
  address (`RtApi::seh_handler`). Re-encoded code keeps the AOT code's pad region at the end
  of the code, with its own entry and handler; then the OSR code, after it, gets an entry
  of its own, the body's `UNWIND_INFO` without a prologue (`SizeOfProlog` 0), and the
  `pop rcx; jmp head` concern above holds there only for asynchronous unwinders (nothing
  in it calls code that unwinds). The SSA pipeline doesn't lay out pad regions: it leaves
  functions with cleanup landing pads, its inlined callees' included, to re-encoding
  (`Unsupported`). The entry prefix has no entry: a leaf, the return address at `rsp` (the
  AOT stub's, then the body's start, whose prologue hasn't run). The SSA pipeline's functions
  get their own `UNWIND_INFO` (`jit::Output::pe_unwind`, [PE frames](#back-end)). Their OSR
  entries keep `rbp` and store the other saves (`rdi` and `rsi` among them, which the AOT
  code never touches, and the used `xmm6`–`xmm15`) at slots that may hold AOT frame bytes the
  entry reads first, so until then the body's description would take the caller's registers
  from those bytes. Each entry is split where its saves are stored: the part before, with
  the dispatcher, is the OSR code, under an entry of its own whose `UNWIND_INFO`
  (`image::pe_osr_unwind_info`) is the AOT frame's without a prologue (`rbp` saved at `fp`,
  the frame register; the caller's other registers still in place, which that part never
  writes); the part after (moved allocas, the head's parameters, `lea rsp`, the `jmp` to
  the head) is appended to the body's code, under the body's entry. The pre part leaves by
  `lea r11, [rip + post]; jmp r11`, which isn't an epilogue form (a `jmp rel32` out of its
  entry would be one), and the post part's `jmp` to the head stays inside the body's entry.
  Their terminate pads are entered by `RtlUnwindEx` with the SSA
  frame's `rsp`, as the Itanium personality enters them.
- **macOS** (`sys/macos.rs`): the same `.eh_frame` as on ELF (Mach-O images' VM code is
  SysV with DWARF unwind information), but registered one FDE at a time: libunwind's
  `__register_frame` (libSystem's) takes a single FDE, finds its CIE through the FDE's CIE
  pointer, and adds its range to the `DwarfFDECache` that the unwinder searches for code no
  loaded image covers. It has no exit teardown; the common `FRAMES_OPEN` lock and `atexit`
  close stay anyway.
- **Perf map**: with `RYO_JIT_PERFMAP=1`, a line per function in `/tmp/perf-<pid>.map`,
  named `ryo-jit:f<index>@<AOT address>`, so `perf` names JIT frames (Linux only: off on
  Windows and macOS, `sys::perfmap_path`).
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

## The SSA pipeline

By default (`RYO_JIT_OPT=ssa`; `ssa-naive` and `reencode`, [Settings](#settings)) the JIT
compiles a function through an SSA pipeline instead of re-encoding it: decoded reduced code → an SSA IR whose frame
slots are *allocas* with provenance, promoted to SSA values where no pointer can reach
them → x86-64 with a register allocator. It lives in `ryo_bytecode::jit` (`alloc`), so
that it is tested without the runtime; `install.rs` calls `jit::compile` in place of
`asm::encode_reduced_at`. A function it doesn't handle (`jit::Unsupported`, with the reason
under `RYO_JIT_LOG`) goes through the re-encoding pipeline, which stays the fallback and the
`reencode` mode: on PE, frames without room for their saves (see [PE frames](#back-end)), 16-byte SSE arguments and results, an island operand without a
`Lend` scope, a frame access in the return address's 16 bytes or below the frame, more than
about 65 000 slot shapes or 8 million variable × block definitions. In the corpus that is
about one function in 500. Handlers stay calls, and nothing is speculated: the AOT code stays the
baseline the SSA pipeline refines.

### IR

`jit::ir`: blocks with parameters (no phis), instructions in an arena, `u32` ids.
- **Values** are untyped bit vectors of 1, 2, 4 or 8 bytes, or 16 for a vector: an
  operation of width `w` reads the low `w` bytes of its operands, and the rest of a register
  or slot holding a value is unspecified. Vectors are a class of their own (no operation
  reads one at a scalar width, or a scalar as a vector). Compares give 1-byte booleans.
  Constants and `undef` are values without a definition; a 16-byte constant is its `u64`
  zero-extended, `VConst` any other.
- **Instructions**: the native reduced instructions on values (`Bin`, `Cmp`, `PtrAdd`,
  `PtrIndex`), the vector operations (`V`: `vsplat`, `veq`, `vlt.s`, `vmsb` on 16 × 8-bit
  lanes, a vector's 8-byte halves and a pair of them; `and`/`or`/`xor.w128` are `Bin` at
  16 bytes; [SIMD](#simd)), `AllocaAddr`, `RefAddr` (`addr.const`, `addr.sym`, `addr.sym.ind`: a
  pure rip-relative `lea` of the constant, or a load of the symbol slot and for `.ind` once
  more through it; JIT code is always within reach of the image), `Load`/`Store` through a pointer, `ALoad`/`AStore` of a memory
  alloca, `OsrLoad` (OSR entries only), `LandingPad` (the exception object, `rax`),
  `HCall` (a handler call: its `In` values are stored to a scratch area whose offsets its
  slot operands get, its `Out` values loaded back, and a `br`/`switch` handler's return
  value is a result; or, `hcall.reg`, the same through the handler's [register
  entry](#register-entries)), `Call` and `Island`.
- **Terminators**: `jmp`, `br` (on a boolean), `brcmp`, `switch` (a switch handler's
  index), `ret`, `tail_call`, `trap` (a `ud2`: `unreachable`, or after a handler that
  doesn't return), and `invoke`: a call, island or `resume` with a landing pad ends its
  block, with a normal edge (to a fresh single-predecessor block that stores the
  results) and an edge to a *pad stub*, one per call site, which takes the
  exception object and jumps to the code after the `lpad`. The call defines its results;
  only the normal edge's block uses them. No moves are ever needed on the exceptional edge.
- Every edge, the switch's included, may carry arguments. `Func::verify` checks dominance,
  argument counts and widths (`RYO_JIT_CHECK`), and `Func` prints as text.

### Frame and provenance

`jit::alloca` cuts the AOT frame into allocas: byte ranges that no access crosses, by
union-find over the bytes of every access (with the handlers' exact effects,
`jit::effects`, generated from the Lean footprints (`ryo-lean effects`), checked against the handlers without memory effects or operand-given lengths
by `vm/rt/tests/ops.rs`, and against the Lean `opSem` footprints by
`vm/rt/tests/lean_opsem.rs`), every escaped
object (`Escape` scopes), every island operand (`Lend` scopes,
[vm.md](vm.md#escapes-storage-ends-and-island-operands)), and the lengths of block-copying
handlers. Each is:
- **promoted** when no escape covers it, no island or block handler touches it, and every
  access is a 1, 2, 4 or 8-byte field, or a 16-byte one read and written only whole (a
  vector): a reaching-shape dataflow (per byte, the
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
(`mov`), constants (`imm`) and trivial parameters disappear on the way. Then the passes of `jit::opt`: `opt::lvn`,
value numbering, one forward pass per block in a preorder walk of the dominator tree: pure
operations on constants fold, with algebraic identities (`x + 0`, `x * 1`, `x - x`,
`p + i * s` with a constant `i`, `PtrAdd` chains); a pure operation repeated in its block or
a block it dominates is replaced by the first (addresses only within a block, being cheaper
to recompute than to keep live); and a load of alloca bytes, or of a pointer value plus an
offset, that an earlier load or store left known is replaced by that value, within a block
and into a successor it is the only predecessor of (extended basic blocks). Only what may
write them forgets them: a store through a pointer the other pointers' bytes and the escaped
(or pinned) allocas, a store to an alloca its own bytes, a handler the allocas it names and,
if it touches memory, what a pointer store does, a call also the outgoing area, an island
everything. Then `opt::dse` drops a store to a memory alloca no pointer reaches when later
stores of its block overwrite its bytes before its loads, a handler or island naming it, or
the block's end may read them. Then `opt::simplify`, the global simplifications: sparse conditional constant
propagation (Wegman and Zadeck) over the block parameters, with executable edges, where
`undef` counts as varying and edges from OSR entries don't count for a head's parameters
([OSR-transparent constants](#osr-transparent-constants)); the values it proves constant
become constants, the branches, overflow branches and switches it decides become jumps, the
blocks left unreachable go, and `opt::lvn`'s identities run again on what the constants
reach. A parameter whose arguments are all one value (but for itself, as around a self-loop)
becomes that value (not at a head with an OSR entry), which then dominates every predecessor,
so the block; at such a head, a parameter equal to an earlier one on every normal edge becomes that one. A block that ends in a jump to a block with no other predecessor takes its
instructions and terminator (not
into a landing pad stub, and never an AOT loop head or an entry). It repeats while the
identities find new constants, at most three rounds. Then the folds (`opt::fold`)
instruction selection relies on: a compare used only by the following branch becomes a
`brcmp`, an overflow op (`add`/`sub`/`mul.ovf`) whose flag only the branch ending its block
reads becomes a `br ovf` on the flags it leaves, and loads and stores through an `AllocaAddr` or a `PtrAdd` take its alloca or
constant into their address. Then `opt::checks` (check elimination) and `opt::hoist`,
[loop-invariant code motion](#loop-invariant-code-motion). Last, `opt::dce` marks and sweeps: a value is live when an
effect, a terminator or a live value reads it, and a parameter's edge arguments only when the
parameter is live, so pure instructions without live results and dead parameters (dead
loop-carried values included, but not the entry's) go with their arguments. A handler call
through its register entry whose handler touches no memory (`effects`) and that can't unwind
counts as pure: its frame operands are values, so it only computes its results.
After DCE, `opt::thread` threads jumps: an edge into an empty block that only jumps on (not an
AOT loop head, whose OSR entry lands there, and with parameters used by nothing but that
jump) goes to the jump's target instead, a conditional edge only as far as it stays without
arguments (one with arguments would need a stub for its moves), and the blocks left
unreachable leave the layout. The emitter falls through to the next block in layout and
inverts a branch whose true target is next.

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

### OSR-transparent constants

Every cyclic head has its OSR entry as an extra predecessor, whose arguments are `OsrLoad`s,
so no head parameter would ever be constant. Constant propagation leaves those edges out: a
head parameter whose arguments on the executable normal edges are all the constant `c` is `c`,
also when the head is entered by OSR, and the entry's `OsrLoad` of it goes. Why that holds:

- An OSR entry is taken only from an AOT activation at the head, that is from a state the
  same function reached by running from its entry: the AOT code and the IR are the same
  program (the IR is built from the decoded AOT code, and the passes before preserve its
  meaning for every run from the entry), and both start from the function's entry.
- Propagation is sound for every run from the entry whatever the loads, calls and handlers
  return (their results count as varying), so in any such run the variable the parameter
  stands for holds `c` (its low bytes, which are all the parameter defines) whenever control
  reaches the head along a normal edge, and control reaches the head only along those. The
  AOT frame holds that variable's value at the head, so its slot holds `c` too, and loading
  it would give `c`.
- What both runs needn't agree on is excluded: `undef` counts as varying, not as any value
  (the AOT slot holds whatever bytes were there, not the constant the IR may pick for it;
  construction shares one `undef` per width, so `opt::lvn`'s identities don't fold `x - x`
  of it either),
  and frame addresses (`AllocaAddr`, which differ for moved allocas) are never constants.
- If no normal edge into a head is executable, propagation counts its OSR edge (whose
  `OsrLoad`s vary): the entry is then never taken, but the code stays well formed.

The same argument holds for any fact about values both runs compute, and `opt::osr` gives
the passes its helpers: the OSR edges, a head parameter's one normal value (`invariant`),
two parameters equal on every normal edge (`same_params`), and dominators without the OSR
edges (`normal_idoms`), under which facts established before a loop reach its head through
the parameters' normal arguments. A parameter whose normal arguments are one non-constant
value still needs that value at the OSR entry, which doesn't have it, so parameter aliasing
doesn't make it that value (the entry sets the head's parameters from the AOT frame: even with
the normal edges gone, its `OsrLoad`s can't stand for them). But a parameter equal to an
earlier one of the same head on every normal edge (each edge passing them one value that
isn't `undef`, or each its own parameter) becomes that one: the AOT frame's two slots hold
the same bytes at the head, and the entry's `OsrLoad` of the second goes. OSR heads and their entries are never removed or merged.

An OSR entry only loads from the AOT frame (its code is the entry sequence, not IR), so a
value computed for it ([LICM](#loop-invariant-code-motion)) goes in a *landing*: a body block
between the entry and its head that only the entry reaches (`osr::osr_landing`). Its edge into
the head counts as the OSR edge (`osr_edge`): the values it passes are those of the normal
edges whenever the entry is taken, by the argument above.

### Loop-invariant code motion

`opt::hoist`, after the checks; general only with `RYO_JIT_LICM=1` (off by default: it doesn't
speed up the benches and costs 1-2% compile time), otherwise only `vsplat`s move, by the same
rules (landings included). Natural loops of the dominators without the OSR edges,
innermost first, so a value invariant in several levels leaves each in turn.
- **What**: a pure operation whose operands are constants, values from before the loop,
  hoisted values, or head parameters with one value on every normal edge (`osr::invariant`);
  frame and constant addresses (`AllocaAddr`, `RefAddr` without `ind`) are recomputed where a
  hoisted instruction needs them, never moved. Loads (`load`, and `aload` of a memory alloca)
  too when nothing in the loop may write their bytes, by `opt::lvn`'s rules (a store through
  the same pointer to other bytes doesn't). Not an overflow op (its flag feeds a branch).
  Only instructions in blocks no other head's OSR entry reaches without passing the head.
- **Faults**: a load through a pointer, a division and an effect-free handler call may fault,
  so they move only if they run whenever the head does: every path from the head reaches
  them with no exit, latch, call or cycle on the way.
- **Where**: the head's one entry predecessor if it ends in a jump, or a new preheader that
  the entry edges go to, with the head's parameters. At a head with an OSR entry the value
  also needs computing for the entry: it becomes a new head parameter that the preheader
  passes, each latch passes on, and the entry's landing computes again from the entry's
  values of the head's parameters (OSR-transparently: an invariant parameter is its normal
  value there, and a load nothing in the loop writes reads the same bytes at the head on every
  iteration). Identical hoisted instructions are one.
- **Register pressure**: a hoisted value is live across the whole loop, and the linear
  scan's intervals are hulls in the layout. An instruction moves only if something in the
  loop uses it (not one only an exit or a cold path uses). The expensive ones (divisions,
  `vsplat`, effect-free handler calls, `RefAddr ind`) always move; a cheap one only if it
  runs on every iteration, no call is laid out within the loop (but in blocks that end in a
  trap), and it takes the register of an operand that nothing else in the loop uses, so it
  costs the loop no register (a loop that runs once would pay for a new one: a callee-saved
  register's save and restore in a hashmap probe, say). Cheap operations feeding a moved one
  are copied out with it, the originals left for their other uses.


### Loop rotation

`opt::rotate`, once after the other passes (before `regalloc::remat`), only with
`RYO_JIT_ROTATE=1`. A loop whose head is only a test (no instructions, a branch, compare or
plain, out of the loop or into it) and whose one latch jumps back to it gets the test copied
to the end of the latch, branching back into the body, so an iteration runs no jump of its own. The
head stays for the preheader and its OSR entry, which still lands there.
- **Shape**: the head's in-loop successor `b` has no other predecessor and starts no AOT loop
  head; no call runs in the loop but on cold paths (the added parameters would cross it).
  The exit gets a new block on the head's edge unless it is a plain body block, starts no
  AOT loop head and has the head as its only predecessor.
- **SSA repair**: the head's parameters used outside it become parameters of
  `b` and of the exit block, passed the originals by the head and the copies by the latch;
  a use neither dominates cancels the rotation.
- **Why off**: it pays only when the register allocator gives the latch's new values their
  parameters' registers, so the back edge has no moves. Sieve's inner loop then loses its
  jump (run Ir -9.5%, estimated cycles -8.4%), but elsewhere the back edge
  keeps its moves (same instruction count, more code) or the extra parameters shift spills:
  sort +0.9% Ir (+1.1% cycles), hashmap +0.1% Ir (+1.6% cycles, I1 misses). Copying heads
  with instructions (loads) cost sort more, a move per iteration. Strength reduction of
  index IVs to pointers isn't done: the benches' loops reload their base pointers each
  iteration (no alias analysis), and `[base + index]` addressing already covers the rest.

### Back end

- **Frame** (`jit::emit`): `fp` is the address below the return address, as in AOT code.
  Below the pinned allocas: the callee-saved registers' save slots (8 bytes each, packed
  and 8-aligned: `DW_CFA_offset` counts in 8 bytes), the moved allocas, the spill slots,
  the handler scratch area, and the outgoing area at `rsp`. With nothing pinned the saves
  are pushed, from `fp + 0` (the padding below the return address) or with a frame pointer from
  `fp - 8`, and the prologue is the pushes then `sub rsp` of the rest (`F + 8` or `F` less
  8 per push), the epilogue `add rsp` (with a frame pointer `lea rsp, [rbp - 8n]`, or `leave`
  for no saves) and the pops; with pinned allocas the prologue is `sub rsp, F + 8` (or
  `push rbp; mov rbp, rsp; sub rsp, F` with a frame pointer) then a `mov` per save. The probe from
  `PROBE_FROM` comes before the `sub`; handler and island operands are `fp` offsets either
  way; OSR entries store the saves at their slots, which the epilogue reads either way.
  A leaf (no calls, no OSR entries) without a frame pointer, not on PE, has no handler scratch area and its
  frame is rounded to 8 bytes, not 16 (nothing it calls needs the alignment); with nothing
  in it and no saves, it has no frame at all (no prologue, epilogue or unwind rows; `fp`
  is `rsp - 8`).
- **PE frames**: as the AOT code's ([vm.md](vm.md#frames)): `rbp` saved at `fp`, the
  frame register, and the SSA pipeline's own saves below it, where `rdi` and `rsi` are callee-saved
  registers like `rbx` and `r12`–`r15` (Win64, the handlers' convention too: saved only
  when used). The prologue is `push rbp`, the pushed saves, a `sub rsp` up to the frame
  offset `K` if the pushes don't reach a multiple of 16, `lea rbp, [rsp + K]`, the probe,
  `sub rsp, F - K`, then the stored saves and the `xmm` saves; each with its unwind code
  (the shared encoder `image::pe_unwind_codes`: `UWOP_PUSH_NONVOL`, `UWOP_ALLOC_*`,
  `UWOP_SET_FPREG`, `UWOP_SAVE_NONVOL`, `UWOP_SAVE_XMM128`). The `xmm` saves are of the
  callee-saved `xmm6`–`xmm15` the code may write (those the allocation names, and the
  scratch `xmm14`, `xmm15` if there is any vector), `movdqa` to 16-byte aligned slots:
  below the pushed saves, or with pinned allocas in the free 16-byte slots within 240 bytes
  below `rbp`; OSR entries store them as they store the other saves. Win64 sets the frame register after the pushes and addresses stored
  saves upward from `rbp - K`, `K` at most 240, so with pinned allocas the saves go into the
  caller's home space (`fp + 16` to `fp + 48`, unless a stack argument is read there) and
  the 8-byte slots within 240 bytes below `rbp` that no pinned alloca covers, the rest of
  the frame below them; without room the function is re-encoded. The epilogue is the
  stored saves' and the `xmm` saves' loads, `lea rsp, [rbp - 8n]`, the pops, then `ret` or the tail jump, a
  register one as `rex.w jmp` and a far one as `jmp [rip]; .quad` so that the unwinder
  sees an epilogue (nothing between the pops and the jump). Calls (handlers, VM
  functions, natives and islands; Win64: `rcx rdx r8 r9`, `xmm0`–`xmm3` by position) get
  32 bytes of shadow space at the bottom of the frame, if the stack arguments don't cover
  it, and 8 more for a handler's stack argument (`atomic.cxchg`, `mov [rsp + 32], r11d`).
  Register entries there take at most four arguments, and return two values in `xmm0`,
  which the call moves to `rax` and `rdx` (`movq`, `punpckhqdq`, `movq`). The SSA pipeline doesn't
  compile arguments past the fourth.
- **Instruction selection**: per instruction over the allocated locations; two-address
  forms with a hint to reuse the first operand's register, immediates where they fit
  (`r10` takes the others), `lea` for an add or subtract into another register (32-bit
  `lea` at 4 bytes and below), `[base + index*scale]` for `ptr.index` by 1, 2, 4 or 8,
  `setcc`, compare-branches fused, `test r, r` for a compare of a register with 0, overflow ops as `add`/`sub`/`imul` (8 and 16-bit
  multiplies, and unsigned 32-bit ones, in 32 or 64 bits with a range check; unsigned 64-bit
  ones as `mul` in `rax`/`rdx`) with `seto`/`setb`/`seta`, or their `jcc` for `br ovf`;
  the `div`/`rem` and variable-shift handlers decode as native operations, `div`/`idiv` in
  `rax`/`rdx` (8 and 16 bits at 32) and shifts by `cl` (masked explicitly at 8 and 16 bits);
  extensions as `movzx`/`movsx`/`mov r32` (none, nor for narrow call arguments and return
  parts, when the instruction that made the value leaves its upper bits zero: `E::zext`),
  fall-through layout. `r10` and `r11` are the emitter's
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
- **Unwinding**: the body's FDE rows are the CFA after the prologue (and without a frame
  pointer after each push) and a `DW_CFA_offset` per saved register; the LSDA's call sites are the calls with a landing pad (to their
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
- **Convention**: `extern "C-unwind" fn(a0, …, a5: u64) -> (u64, u64)` (`RegRet` in `rax`,
  `rdx`); on PE, Win64, whose 16-byte structs return through memory, at most four
  arguments, all in registers, and the return value one `u64` in `rax` or two in `xmm0`,
  low then high (`__m128i`, `ryo_rt`'s `RegRetOf`). The arguments are, in order from the
  first argument register: the values of the frame operands it reads (by operand order,
  each in its register's low bytes, the rest ignored), then whole every argument register of
  the frame entry's layout that holds anything but a slot offset (immediates, addresses,
  case tables, a `Mem` operand's displacement; their slot-offset halves are ignored). No
  `fp`. The results are the values of the frame operands it writes (by operand order; for an
  update, the new value), then the `br`/`switch` return value, in `rax` then `rdx`, each in
  the low bytes. It clobbers what any call of the convention does: the SSA pipeline keeps nothing in a
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
  relocates `Ref::RegHandler` against it, and `RYO_JIT_DUMP` names them
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
  `r12`–`r15`, `rbp` without a frame pointer); others prefer the caller-saved ones, but
  not the fixed registers an instruction they cross clobbers (`regalloc::clobbers`: `rax`/
  `rdx` for `div`, `rem` and the unsigned 64-bit `mul.ovf`, `rcx` for a variable shift);
  hints are the first operand's register, an incoming edge argument's for a parameter, the
  argument register for an entry parameter, `rax`/`rdx` for results (also of `div`/`rem`),
  and `rcx` for a shift amount (`rcx` goes last among the caller-saved registers then);
  a use's hint (a shift amount, a call or register-entry argument, a returned value) goes
  before an operand's but not before a register the value comes in. Before it,
  `regalloc::remat` recomputes an `AllocaAddr` or a `RefAddr` that loads at most once,
  when it is live across a call, before its uses after each call (one clone per stretch
  between calls), so it takes no callee-saved register or spill slot. When no register
  is free, the interval with the least spill weight per position is spilled (its
  definition and uses, each `8^depth` by loop depth, approximated as the layout range from
  a head to its last predecessor; 1 in cold blocks; of equal ones, the one ending last).
- **Checker** (`RYO_JIT_CHECK=1`): `regalloc::check` walks each block backward from its
  exact live-out set and checks that no location holds two live values, that nothing lives
  across an instruction in a register it clobbers (a call: every caller-saved one), that `r10`, `r11` (and `rbp` with a frame
  pointer) aren't allocated, and that every use has a location; with `Func::verify` before
  it. A failure is printed on stderr and the function stays in its AOT code (`Failed`), so
  that the corpus (which compares stderr) and the JIT tests (which check where code runs)
  see it.

### Inlining

`jit::inline` inlines calls of VM functions into the unit (direct calls of the root's
image's functions, and calls through symbols whose slots hold a VM function's entry, of
any image; see "Across images" below), after
the first round of passes (`jit::compile`: build, `opt::run`, inline, `opt::run`, promote,
`opt::run`). Nothing is speculated: a direct call's target is fixed, so a unit is never
rebuilt. The JIT thread caches each callee's IR (built and optimized, by image and
function; `install.rs`'s `InlineEnv`), so that a function is decoded and built once for all
the units that inline it.

- **Exploration**: from the root, its direct calls heaviest first, each callee's IR from
  the cache, down to depth 6, at most 6000 cost units of callee IR and 400 nodes. Not
  inlined: recursion (a function already on the path), tail calls in the callee, stack
  arguments (an incoming area), argument or result registers other than 1, 2, 4 or 8
  bytes, arguments the call doesn't set, calls through pointers or through symbols that
  don't hold a VM function's entry. A callee with
  a `resume`, or with landing pads at a catching site, is inlined only where its calls that
  unwind out wouldn't land on the site's landing pad (stage 4 of the inlining plan
  handles those).
- **Weights**: static: 1 per call site, 8 per loop level of the site's block (up to 4),
  1/16 in a cold block (a landing pad stub, a trap, or only cold successors), multiplied
  down the path.
- **Profile**: once the root's AOT code was called at least 4 times, its records' exact
  counts raise weights: a callee's calls over the root's, split over the unit's sites of
  it by their static weights (there are no samples of call sites), at most 16 times the
  static weight. The counts cover every AOT caller of the callee, so this overestimates
  for callees hot elsewhere; the cap bounds it. Tiny leaves aren't deferred to callers.
- **Cost and benefit**: the cost is the callee's instructions (a handler call through the
  scratch area 4, through its register entry 2, a call 4, others 1; branches 1, cold
  blocks a quarter); the benefit is the weight times the call protocol saved, `2 × args +
  8 (+1 with a result)`, plus what a trial folded, plus the promotion the splice enables:
  for each pointer argument into a memory alloca of the root (or an inlined ancestor, through
  the parameters that pass it) that nothing but loads, stores and VM calls reach, the
  callee's loads and stores through that parameter, by block weight, if the callee doesn't
  let it escape otherwise.
- **Trials**: a callee of cost 60 or less called with constant arguments is specialized
  to them (its entry parameters' uses replaced, then `opt::run`), memoized per function
  and constants, at most 16 per unit; the cost is the specialized IR's, and the splice uses
  it.
- **Clusters**: bottom-up, a node absorbs the child cluster with the best benefit per cost
  while that raises its own ratio; a cluster is inlined whole or not at all. Clusters are
  taken best ratio first: always at a cost of 12 or less, else not at a cold site, and only
  at a ratio of at least `0.303 × 2^((unit + cluster) / 400)` (the bar rises as the unit
  grows) within a unit of 2000, or 3000 for roots running 100 loop iterations per call; the children of an accepted cluster it
  didn't absorb become candidates. Inlined allocas may add at most 64 KiB of frame.
- **Splice** (IR to IR): the callee's allocas, values and blocks are copied with fresh
  ids (allocas marked `inlined`, never pinned; outgoing areas merge into one at the bottom
  of the frame). Its entry parameters become the call's arguments (zero-extended past the
  call's register size), its returns jumps to a continuation block whose parameters are
  the call's results. A copied call that unwinds to its caller takes the site's action:
  none, to the caller, or the site's landing pad, as an invoke to the site's stub (which
  then has several invokes). The callee's own landing pads stay; its loop heads become
  ordinary blocks, without OSR entries, and OSR entries convert only the root's allocas.
- **Promotion** (`opt::promote`, on every unit): a memory alloca that isn't pinned, whose
  address nothing takes any more, that no handler or island names, and whose accesses are
  to equal or disjoint fields of 1, 2, 4 or 8 bytes becomes SSA values (Braun et al. on the
  IR; OSR entries load the AOT frame's bytes). This is what removes the field round trips
  of `&self` wrappers once their calls are inlined. A field that would need a parameter on
  a landing pad stub keeps its alloca in memory: pad edges move nothing.
- **Call forms** are assigned after inlining (`inline::retarget`, through
  `Env::retarget`): the unit's remaining calls and tail calls of functions and symbols get
  their forms as in [Compiling and installing](#compiling-and-installing) (slot, `rel32`
  or `imm64`).
- **Across images**: a callee of another image (a dylib's, an rlib's own image, std's) is
  inlined if its image's mode is the root's (but for counters). Its IR is cached by its
  image's header and function, and `inline::rebase` puts it in the root's image's terms
  before it is explored: addresses of its constants, data and site caches (`RefAddr`,
  handler arguments) become 64-bit constants, a symbol's `RefAddr` the value its slot held
  when compiling (slots are filled before VM code runs and never again; an indirect one
  loads through it at run time), its calls of its functions and symbols the JIT's call
  forms (or a direct call of the root), its islands the call form of the island's address
  (the island ABI is unchanged: `fp` and the operand array the unit lays out), a call
  through a symbol's pointer (PE's `__imp_`) a load of that pointer and a call of it, and
  code constant arguments (a sparse switch's case values) their addresses in its image's
  code constants. With one image per codegen unit ([backend.md](backend.md#pipeline)),
  this is what lets calls between a crate's own CGUs be inlined as calls inside one image
  are. Callees with tail calls aren't inlined (in any image). Its counters are its own image's records. Unwinding needs nothing more: every
  image's unwind information names the program's `rust_eh_personality`, which the unit's
  uses too. Images are never unregistered, so the inlined addresses stay valid; a symbol
  bound to another image's function is resolved when compiling, as the call forms already
  are, so interposition after that isn't seen (it isn't supported anywhere in the VM).
  Call slots are allocated only for the call forms the installed code uses.
- `RYO_JIT_DUMP` shows the decisions (each cluster with its benefit, cost and outcome, and
  the calls not inlinable and why) and the IR after the splices; `RYO_JIT_CHECK` verifies
  the IR after each splice and after promotion.

### Choices

- The SSA pipeline lives in `ryo_bytecode::jit` (testable without the runtime, next to the
  decoder).
- Island operand extents come from `Lend` scopes in the image; an
  island operand without one makes the function `Unsupported`.
- Allocas escaped at a cyclic head are pinned (one code version); a separate OSR version
  that pins nothing is the follow-up.
- The handler effect table is by family from the mnemonics, checked against the handlers.
- An in-tree linear scan, no new dependencies.
- Handlers stay calls, through their register entries where they have one; native handler
  operations (overflow arithmetic, extensions, …) are the follow-up, as are splitting and
  rematerialization.
- The re-encoding pipeline stays, as the fallback and the `reencode` mode.
- Only 1, 2, 4 and 8-byte integer fields and whole vectors are promoted (`w128` integers and
  floats stay in memory; floats move through general-purpose registers at calls).
- AOT code keeps its counter checks at acyclic heads, and the dispatcher returns into the
  AOT code there.
- Two scratch registers (`r10`, `r11`) rather than one: simpler instruction selection and
  moves at the cost of one allocatable register.
- Intervals without holes, and no allocation hint beyond the above: the first allocator
  is simple; holes, splitting and a regalloc2 comparison are follow-ups.

### SIMD

The SIMD instructions (`vsplat.i8x16`, `veq.i8x16`, `vlt.s.i8x16`, `vmsb.i8x16`,
[instructions.md](instructions.md)) and `and`/`or`/`xor.w128` decode as native vector
operations, not handler calls, with exact 16-byte accesses (2 for `vmsb`'s mask, 1 for
`vsplat`'s byte):

- **Fields**: a 16-byte field a vector operation reads or writes whole promotes to a 16-byte
  value (a narrower read of it keeps the alloca in memory). Small copies are cut into one
  16-byte piece over such a field (also across frame-to-frame copies), so `load.copy` of 16
  bytes into it is one 16-byte load (`_mm_loadu_si128`). After inlining, a vector stored as
  two 8-byte halves and loaded whole is their pair, a half of a stored vector a half
  (`opt::lvn`), and promotion splits a vector access over two 8-byte fields the same way; a
  pair of the halves of one vector is that vector, a pair of the two 8-byte loads of a
  16-byte range one 16-byte load, and an or that puts a value's bytes back together that
  value.
- **Folds** (`opt::lvn`): operations on constants, `vmsb(vlt.s(x, 0))` to `vmsb(x)` (so
  `_mm_movemask_epi8` is one `pmovmskb`), `x == x`, `x < x`, and the bitwise identities with
  zeros and ones. `opt::hoist` moves a `vsplat` of an invariant byte out of its loops
  ([LICM](#loop-invariant-code-motion)).
- **Registers**: a second class, `xmm0`–`xmm13` with `xmm14`/`xmm15` the emitter's scratch
  registers, on PE too, whose prologue saves the callee-saved `xmm6`–`xmm15` it names
  ([PE frames](#back-end)). No `xmm` register survives a call: a vector live across one
  takes a 16-byte spill slot (two 8-byte ones). The checker checks the classes, the reserved
  registers and that no vector is in an `xmm` register across a call; edge moves, OSR entries
  (`OsrLoad`s of 16 bytes) and parameters handle both classes.
- **Emission** (SSE2, the x86-64 baseline): `movdqu` loads and stores, `movdqa` between
  registers, packed operations register to register only (a legacy SSE memory operand must
  be aligned): `pcmpeqb`, `pcmpgtb` with the operands swapped for `vlt.s`, `pand`/`por`/`pxor`;
  `pmovmskb` for `vmsb`; `vsplat` as `movzx`, `imul 0x01010101`, `movd`, `pshufd 0`; halves
  by `movq` (`pshufd 0xee` for the high one, or a load from a spilled vector), a pair by two
  `movq` and `punpcklqdq`; constants as `pxor`, `pcmpeqb x, x`, a `movq` of a 64-bit one or a
  load from the function's read-only data.

## Packaging

The JIT thread is the `ryo_jit` crate, which `y build` turns into one object that `ryo_rt`'s
rlib bundles (`build/src/jit.rs`, [build.md](build.md#build)):

- **Interface** (`ryo_bytecode::jit_abi`, `core` only, so neither crate depends on the
  other): `extern "C" fn ryo_jit_start(rt: &'static RtApi) -> Option<extern "C" fn()>`, the
  JIT's only symbol, which returns its exit report ([statistics](#statistics)) or `None` if
  its thread didn't start,
  and `RtApi`, which the runtime builds once, at the first push. Neither carries a version:
  the JIT is built with the runtime ([version-matched](vm.md#image-format)).
  | Field | |
  |---|---|
  | `settings` | `JitSettings`: `log`, `perfmap`, `test_panic`, `test_oom`, `check`, `opt` (`JitOpt`), `ssa_limit` ([Settings](#settings)) |
  | `probe` | `ryo_probe_stack`'s address |
  | `personality` | the program's `rust_eh_personality`'s address, by which the JIT finds an image's personality slot |
  | `thresholds` | the counters' thresholds (calls, loop iterations), for the counts |
  | `next_batch` | the queued records in trip order, sleeping while there are none unless asked not to (the JIT thread only) |
  | `done` | reports a record: compiled (after the JIT published it), or failed (the runtime marks it `Failed`); wakes its waiters |
  | `shuffled` | whether an image's functions get shuffled frames |
  | `image_at` | the header of the registered image whose text holds an address, or null (cross-image calls) |
  | `handlers` | every opcode's handler address, null for opcodes without one |
  | `reg_handlers` | every opcode's [register entry](#register-entries) address, null for opcodes without one |

  `JIT_ENTRY_PREFIX` is there too. Nothing crosses the interface by
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
  LTO input (ryo rejects `-Clto` anyway). The backend and the image format don't
  know about it. Without `RYO_JIT_LIB_DIR` (`vm/`'s own tests) the `ryo_jit` rlib provides
  `ryo_jit_start` instead, on the tests' std.
- **Mach-O**: sealed as on ELF: `llvm-objcopy --keep-global-symbol=_ryo_jit_start` (C
  symbols carry Mach-O's `_` prefix) makes the rest non-external, and the object is archived
  alone, in the BSD format. Its undefined symbols are libSystem's (`dispatch_*`, `_dyld_*`,
  `pthread_*`, `__tlv_bootstrap`) and the unwinder's. `jit-sealed` also checks that it has no
  initializers (`__mod_init_func`, `__init_offsets`) and no `LC_LINKER_OPTION` (the
  counterpart of `.drectve`). Code memory needs no `MAP_JIT` on x86_64 (`vmem`: `mmap`, then
  `mprotect` W^X), so a binary signed with the hardened runtime needs the
  `com.apple.security.cs.allow-unsigned-executable-memory` entitlement;
  `com.apple.security.cs.allow-jit` only covers `MAP_JIT` mappings. Without the hardened
  runtime nothing is needed. Under Rosetta 2 the `mprotect`s make the translator drop and
  retranslate rewritten pages. arm64 (`MAP_JIT` with per-thread write protection,
  `pthread_jit_write_protect_np`, needed there) is not a target.
- **PE**: `y build` seals and bundles it the same way. Its own imports (`RtlAddFunctionTable`,
  `GetStdHandle`, `WriteFile`) are `raw-dylib` from kernel32, import members of the
  library like std's ([platforms.md](platforms.md)).
- **Cost**: the sealed object is about 1.6 MB, and a binary's text is about 0.24 MB larger
  than with the JIT on the program's std (a private std's threads, panics, formatting and
  collections; on PE, with the stub, the file grows by about 50 KB). A proc macro carries
  it too (0.25 MB): the linker doesn't drop it there.

## Settings

Read once by the runtime side, with the C runtime's `getenv`, and those the JIT needs passed
on in `RtApi::settings` (`vm::configure_jit` sets them in tests, `vm::configure_jit_off` turns the JIT off, and `vm::jit_shuffle_image` asks
for shuffled frames per image, `RtApi::shuffled`):

| Variable | Effect |
|---|---|
| `RYO_JIT=off` | the no-op JIT; registration gives every counter the `Failed` bias |
| `RYO_JIT_THRESHOLD=n` | registration starts the counters at `n / 16` calls and `n` loop iterations (`e,l`: `e` and `l`); 0: trip at the first call |
| `RYO_JIT_SYNC=1` | a trip that finds its record queued waits on a futex on `state` until it leaves `Queued`, then continues in the JIT code; nested trips on that thread and trips on the JIT thread never wait |
| `RYO_JIT_PERFMAP=1` | the [perf map](#unwinding-and-profiling) |
| `RYO_JIT_LOG=1` | a line on stderr per compiled or failed function, and per function whose frame couldn't be shuffled, and the JIT thread's panics |
| `RYO_JIT_SHUFFLE=1` | JIT frames in another layout ([OSR](#osr)) |
| `RYO_JIT_TEST_PANIC=1` | tests: every compile panics, which must fail the function and nothing else |
| `RYO_JIT_TEST_OOM=1` | tests: every compile fails an allocation (`isize::MAX` bytes), which must fail the function and nothing else |
| `RYO_JIT_OPT=…` | `ssa` (the default), `ssa-naive` or `reencode`: how functions are compiled ([The SSA pipeline](#the-ssa-pipeline)); with `RYO_JIT_SHUFFLE` the SSA pipeline lays allocas out in reverse with gaps |
| `RYO_JIT_CHECK=1` | the SSA pipeline's checkers: a failure is printed on stderr and the function falls back |
| `RYO_JIT_DUMP=dir` | the SSA pipeline writes each function's reduced code, IR before and after value numbering and the folds, locations and code (or, for one it doesn't handle, the reason and the reduced code) to `dir/f<index>-<image header address>.txt`, and every installed function's code with its relocations by name to `dir/f<index>-<image header address>.code` (for `y bench codegen`, [build.md](build.md#test-and-bench)); read by the JIT thread itself, not passed in `RtApi` |
| `RYO_JIT_LICM=1` | the SSA pipeline's general [loop-invariant code motion](#loop-invariant-code-motion); off by default, when only splats are hoisted |
| `RYO_JIT_ROTATE=1` | the SSA pipeline's [loop rotation](#loop-rotation); off by default |
| `RYO_JIT_SSA_LIMIT=n` | debugging: only the first `n` functions the JIT compiles go to the SSA pipeline, the rest are re-encoded (bisects a miscompile) |
| `RYO_JIT_STATS=1\|2` | [statistics](#statistics) on stderr: `1` a startup line at the first image registration and a summary at exit, `2` also a progress line from the JIT thread at most once a minute; another value warns and means `1`. Independent of `RYO_JIT_LOG` |

### Statistics

`RYO_JIT_STATS` prints lines starting with `[ryo] jit` on stderr (`y test` drops them from
the stderr it compares), each with one `write`:

```
[ryo] jit: on, ssa, thresholds 64 calls / 1024 iterations (RYO_JIT_THRESHOLD), sync, pid 41213
[ryo] jit stats: +60s compiled 412 (ssa 398, reencode 14), failed 3, code 1.9 MiB
[ryo] jit stats: summary, pid 41213, 2.84s since the JIT started
[ryo] jit stats:   queued    1203 records in 97 batches (largest 143)
[ryo] jit stats:   compiled  1171: ssa 1102, reencode 69 (ssa unsupported 61, ssa-limit 0, RYO_JIT_OPT=reencode 8)
[ryo] jit stats:   failed      12: no personality slot 9, panicked 1, region full 0, ssa check failed 0, other 2
[ryo] jit stats:   in flight   20 (taken, not yet reported; approximate at exit)
[ryo] jit stats:   ssa: devirt 5, inlined 40 calls
[ryo] jit stats:   code   2.3 MiB (ssa 2.1, reencode 0.2) in 3 regions; region-full retries 2
[ryo] jit stats:   time   compile 1.21s (mean 1.0ms, max 38ms)
```

- **Startup line**: the runtime's, at the first image registration, formatted without
  `core::fmt` (a fixed buffer, `Line`); it lists the tier, the thresholds and the flags that
  are on, or `off (RYO_JIT=off)`. It registers the summary's `atexit` handler.
- **Counters**: nothing on the AOT side (code, handlers, trips). The counters
  (`vm/jit/src/stats.rs`) are atomics only the JIT thread writes, with a `Relaxed` load
  and store; other threads read them with `Relaxed` loads. A record's are stored before its
  state leaves `Queued` (`JitRecord::publish`, `JitRecord::fail`), so a `RYO_JIT_SYNC` waiter
  sees them; the timing counters and `largest_batch` come after, so they can be one behind. Compile timing is gated by `JitSettings::count` (on with stats, and in tests).
- **Summary**: the `atexit` handler calls the JIT's report (formatted on the stack, no lock,
  no waiting for the JIT thread), or prints `JIT off`, `no function reached a threshold`,
  `JIT thread failed to start` or `JIT thread still starting`. Read mid-compile, the counters needn't balance: `in flight`
  saturates at 0. A forked child prints nothing; `_exit`, `abort`, signals and `exec` skip it.
- **Progress** (`2`): the JIT thread checks after each batch, so an idle JIT prints none.
- With `RYO_JIT_SYNC` in a single-threaded program, everything but the times and the pid is
  deterministic.

`y test` links a checked JIT, built with debug assertions and overflow checks
(`RYO_JIT_CHECKED`, [build.md](build.md#build)); measurements use the release one.

## Limits

- A child of `fork` has no JIT thread, so with `RYO_JIT_SYNC` its trips wait forever.
- The JIT runs on Linux, Windows and x86_64 macOS (`sys`). On Windows `y test` passes with the JIT
  from the first call, by OSR, shuffled, with each tier and `RYO_JIT_CHECK=1`, and with
  `RYO_JIT_TEST_PANIC`/`RYO_JIT_TEST_OOM`, including panics unwinding through JIT frames
  (Windows 11, 2026-10-29); `jit.rs` and `ssa.rs` don't build there (Linux and Apple only),
  and the exit race, regions far apart (`VirtualAlloc` at each hint, which fails where taken;
  32 MiB committed per region) and walks by debuggers and profilers are untested. Exit: `ExitProcess` kills the JIT thread wherever it is, so there is no
  `atexit` handler to close the registry (it could wait on a lock the thread died holding;
  the registry isn't torn down anyway); a thread killed inside `RtlAddFunctionTable` could
  leave ntdll's function table lock held, which would hang only an unwind through
  non-image code during the rest of the exit. macOS (x86_64, natively or under Rosetta,
  `vm/jit/src/sys/macos.rs`) is likewise sealed and checked from Linux only (`y test --cross
  x86_64-apple-darwin`: `jit-sealed`, `rt-core-only` and the corpus) and has never run: the per-FDE registration (read from LLVM's libunwind, which
  Apple's may differ from), the hint-and-verify region search (`mmap` without
  `MAP_FIXED_NOREPLACE`, the address only a hint), the `__ulock` waits in the trips, and
  ld64 linking the sealed object (a second `rust_eh_personality`, local, among the
  personalities compact unwind can encode, three at most) are untested there.
- Island calls and `call.sym.ind` stay through the image's symbol slots. A callee's slot is
  never replaced by a direct call: a caller compiled before its callee keeps the slot.
- A program that interposes `malloc` itself with Rust code (which may call VM code) would
  run that code on the JIT thread, and with `RYO_JIT_SYNC` could deadlock.
- Each runtime instance in a process has its own JIT, thread, code regions and private std
  ([vm.md](vm.md#several-ryo-runtimes-in-one-process)): a cdylib, a C link of staticlibs, a
  ryo build. Copies of one build with one std (an executable and its Rust dylibs) merge into
  one instance at run time. Two same-build ryo staticlibs in one C link don't collide on
  `ryo_jit_start_<tag>`: archive extraction takes one sealed member, as it takes one `ryo_rt`
  member. Only a link that takes every member (`--whole-archive`) pulls both, and then the
  users' std and `ryo_rt` collide too (unsupported, as for any two Rust staticlibs).
- The thread starting pins its module (`dladdr` + `dlopen(RTLD_NOLOAD | RTLD_NODELETE)`,
  `GetModuleHandleExW(PIN)`): `dlclose` of it is a no-op.
- `#![no_std]` final artifacts don't link with the native sysroot: the sealed object needs
  libc, libpthread and the unwinder, which std brings.

## Testing

- **`vm/jit/tests/jit.rs`** (it links
  `ryo_jit` as an rlib, on the tests' std, so it tests the compiler and the trips, not the
  sealing): with threshold 0 and `RYO_JIT_SYNC`'s waiting, functions give the AOT code's
  results with arguments of every kind, in JIT code (checked by return addresses within
  `jit_code`), a recursion switches over midway, panics unwind through JIT frames with
  their landing pads, JIT code calls JIT and AOT functions, and sixteen threads trip at
  once. Calls of another image's function and tail calls go through a call slot before the
  callee is compiled and to its JIT code after (from callers compiled before it and after
  it, past its counter, three images), and native code mapped more than 2 GiB away is
  called through `r11`, also with a panic unwinding through the far call. With and without shuffled frames, OSR at every head pass of a few loops keeps the
  values live at the head (integers of every width, floats, `w128`, an escaped local read
  through a pointer and directly), at the outer and inner heads of nested loops, a panic
  after OSR runs the JIT frame's landing pad, `rsp` moves by the frames' difference, and a
  thread spinning in an AOT loop and one deep in a self-recursion, both started before the
  compile, reach JIT code without returning (a native callee checks its return address).
  `pe_code` runs an image's VM code in the PE form on Linux (Win64 natives, `ryo_rt`'s
  `pe-test` handlers, its `.pdata` dropped; the JIT registers nothing for PE code off
  Windows): compiled at the entry and by
  OSR, with and without shuffled frames, with a probed frame, its results are the AOT
  code's, the JIT prologue is the one `pe_unwind_info` describes, and every callee-saved
  register of both conventions, `rdi` and `rsi` included, survives. `pe_numeric_args` calls
  a PE function through `extern "win64"` with the pieces `i128`, `f16` and `f128` lower to
  (an `i128` straddling `r9` and the stack, `f16`s in an `xmm` and a stack slot, an `f128`
  pointer, an `f16` return in `xmm0`), in AOT code and then JIT code; `pe_cxchg` an
  `atomic.cxchg`, whose Win64 handler takes its fifth argument on the stack and whose
  register entry returns two values in `xmm0`. `vm/bytecode/tests/
  image.rs` checks `pe_unwind_info` byte for byte (decoded once with `llvm-readobj
  --unwind` from a hand-made COFF object). Through the SSA pipeline, `ssa.rs`'s `pe_frames`
  runs a loop with values live across a five-argument Win64 native (its fifth argument past
  the shadow space, which the callee overwrites with every volatile register), at the
  entry and by OSR, shuffled or not, with the saves pushed, in the home space and below
  `rbp` (an 8 KiB pinned alloca, so the frame probes): the results are the AOT
  code's and every Win64 callee-saved register, `xmm6`–`xmm15` included, survives.
  `vm/bytecode/tests/jit_pe.rs` runs each SSA prologue symbolically and unwinds it at every
  step by its `UNWIND_INFO` as `RtlVirtualUnwind` does, checks that each epilogue restores
  the caller's registers in the form the unwinder recognizes (a `jmp rel32` within the
  function isn't one), that the OSR code writes no callee-saved register and stores every
  save before it jumps to its post part, ending in no epilogue form, and that no code names
  `xmm6`–`xmm15`. On Windows the registration has run for the corpus's panics through JIT
  frames; debugger and profiler walks haven't been tried.
- **The corpus**: `RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1 y test` runs it with every function's
  JIT code from its first call, and `RYO_JIT_THRESHOLD=2,0` instead enters it by OSR at the
  first loop head pass of each function's first call (whose entry check doesn't trip),
  both also with `RYO_JIT_SHUFFLE=1`. With a ryo sysroot, `y test` runs the corpus
  that way (`ryo-std-jit`, `ryo-std-jit-shuffle`), std's own VM functions included
  ([build.md](build.md#test-and-bench)).
- **The SSA pipeline**: `y test` runs `vm/jit/tests/` through the SSA pipeline with its checkers, then
  with `RYO_JIT_OPT=ssa-naive` and with `reencode` (through
  the SSA pipeline `rsp` moves by a multiple of 16 instead of the frames' difference), whose SSA-specific tests cover an alloca escaped only
  after the head (moved at OSR), an acyclic head (the trip returns into the AOT code), a slot
  reused at two widths, handler results feeding branches, a value live into a landing pad
  across a call, and sixteen values live across a call. `vm/jit/tests/ssa.rs` (a process of
  its own) checks, by `ryo_jit::stats()`, that its functions go through the SSA pipeline: switch
  tables with edge arguments, sparse switches, tail calls with stack arguments and through
  a pointer, SSE arguments and results, a catching landing pad, probed 12 KiB frames entered
  by OSR, an alloca pinned at the head, and every SIMD instruction and fold
  (`simd_against_handlers`: each against the AOT code's handlers on edge-lane and random
  vectors at every misalignment, across a call, in a loop entered by OSR at several head
  passes). Then the corpus on its own VM
  functions through the SSA pipeline (`ryo-jit-ssa`, threshold 0, and `ryo-jit-ssa-osr`, OSR at the
  first head pass; with a ryo sysroot, `ryo-std-jit` and `ryo-std-jit-shuffle` go through
  the SSA pipeline too, and `ryo-std-jit-reencode` through the re-encoding pipeline). `vm/bytecode/tests/jit_ssa.rs`
  builds hand-written functions' IR (promotion, block parameters at a loop head and its OSR
  loads, reaching shapes, pinned and moved escaped locals, handler slots sharing a register)
and checks the passes on it and on hand-built IR (value numbering, constants through a loop
and past its OSR entry, a switch on a constant, a self-loop parameter, a dead handler call, promoted vectors, the
vector folds and the splat hoist, a vector reassembled from its halves),
  `tests/jit_x86.rs` checks the
  encoder against `objdump` (the SSE2 forms included), `jit_pe.rs` that vectors on PE
  stay out of `xmm6`–`xmm15`, and `vm/rt/tests/ops.rs` the handler effect table.
- **Packaging**: `jit-sealed` (`y test`, and `y test --cross` for PE and Mach-O) checks the
  bundled object: only `ryo_jit_start` (and the renamed symbols and constants) defined
  globally, no Rust symbol or allocator shim referenced, no unwinder defined, on COFF no
  `.drectve` or `.CRT$X*` section, and on Mach-O no initializers or linker options. `jit-private-std` runs `tests/vm_jit_private.rs`, whose VM global
  allocator trips while it holds its lock (with the program's allocator, the JIT would
  deadlock there), and the same program built with `-Cpanic=abort` and run with
  `RYO_JIT_TEST_PANIC`, and again with `RYO_JIT_TEST_OOM`, which must run as without the
  JIT, logging the failed compiles.
- The counters' code shape, its round trips and the trips with `RYO_JIT=off` (the
  no-op JIT; `vm/rt/tests` run with it, `vm::configure_jit_off`) are tested with the encoder ([vm.md](vm.md#jit-records-and-counters)).

## Future work

The SSA pipeline doesn't optimize beyond promotion, copy and constant propagation, local value
numbering, global constant propagation and CFG simplification, its folds and DCE: passes, inlining, more native handler operations, interval splitting and an OSR version
that pins nothing are the next steps, behind the same records, trips, OSR entries and
packaging; [verification.md](verification.md#the-jit) describes how its output would be
validated.
