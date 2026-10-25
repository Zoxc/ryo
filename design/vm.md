# VM

The VM is a register machine whose registers are byte offsets into the current frame.
Instructions are fully typed at lowering time: every instruction knows its operand widths,
so there are no type tags or checks at run time. The backend encodes each function's
instructions as x86-64 machine code ([Encoding](#encoding)): every instruction is a call of
a small handler in `ryo_rt` ([Handlers](#handlers)) with its operands in argument registers,
followed by the instruction's control flow. VM functions run on the native stack, with
native frames, and unwind natively ([Unwinding](#unwinding)). The runtime lives in `ryo_rt`
(module `vm`).

## Execution state

- **`fp`** is the address of the frame ([Frames](#frames)). Handlers take it in `rdi`, which
  VM code sets to `rsp + F` before each handler call; nothing is kept in registers across
  instructions but what the [register cache](#register-cache) keeps between inline
  sequences. With a frame pointer ([Frames](#frames)), VM code keeps `fp` in `rbp`, and with
  `ryo_rt`'s `fp-rbp` feature the handlers read it from there ([Handlers](#handlers)).
- **No image context**: the code addresses its image's symbol slots, constant pool, data
  area and code constants RIP-relative (relocations, [Image format](#image-format)), so a
  call into another image switches nothing.
- **No per-thread state**: VM functions are native functions of their Rust-ABI signatures
  ([Calls and islands](#calls-and-islands)): arguments and return values go where the
  platform convention puts them, never through state the VM keeps, so nested calls
  (VM → native → VM) share nothing.

## Frames

- **Native frames**: VM functions run on the thread's native stack. Like LLVM's code, they
  omit the frame pointer unless the session asks for one (`asm::Mode::frame_pointer`): the
  prologue every function starts with is
  ```
  mov eax, F + 8; call ryo_probe_stack ; only if F >= 4096
  sub rsp, F + 8
  ```
  and `add rsp, F + 8` undoes it before `ret` and tail jumps. Frame slots are addressed
  through `rsp`, `[rsp + F + off]`, and `rbp` is untouched.
- **Counter check**: before the prologue, every function the backend emits counts its call
  in its JIT record, `sub qword [rip + rec.ctr], 16; js .tier_entry`, which moves nothing
  and touches only the flags ([JIT records and counters](#jit-records-and-counters)). So
  the prologue starts at byte 10 (14 with a long `js`).
- **Frame pointer**: the backend keeps one where rustc's LLVM backend would
  (`partition::asm_mode`, following `rustc_codegen_llvm::attributes::frame_pointer`): if
  the target's `frame_pointer` isn't `MayOmit`, with `-Cforce-frame-pointers` or
  `-Zinstrument-mcount`. Also on PE, whose unwind info can't describe the island calls'
  `rsp` adjustment ([Calls and islands](#calls-and-islands)), and when `ryo_rt`'s handlers
  read `fp` from `rbp` (`fp-rbp`). Then the prologue is
  ```
  push rbp
  mov rbp, rsp
  mov eax, F; call ryo_probe_stack     ; only if F >= 4096
  sub rsp, F                           ; only if F > 0
  ```
  the epilogue is `leave`, slots are `[rbp + off]`, and handlers get `mov rdi, rbp`.
- **PE**: the prologue also saves `rdi` and `rsi`, which are callee-saved on Win64 but not
  in the `sysv64` handlers, in the top 16 bytes of the frame (the lowering reserves them,
  `frame.rs`):
  ```
  push rbp; push rdi; push rsi
  lea rbp, [rsp + 16]
  mov eax, F - 16; call ryo_probe_stack ; only if F >= 4096
  sub rsp, F - 16
  ```
  and the epilogue is `lea rsp, [rbp - 16]; pop rsi; pop rdi; pop rbp`
  (`asm/encode.rs`, `Item::WinPrologue`/`WinEpilogue`). `xmm6`–`xmm15` aren't saved: VM
  code doesn't touch them, and the `i128` saturating float casts, whose handlers keep a
  value in `xmm6` across a call, go through the `as_cast` island on PE instead
  ([lowering.md](lowering.md#casts)).
- **Layout**: frames grow downward, and slots are signed offsets from `fp`
  (`ryo_bytecode::abi`):
  ```
  fp + 16 + …       stack arguments (after 32 bytes of shadow space on PE), written by
                    the caller in its outgoing area
  fp + 8            return address (points after the caller's call instruction)
  fp + 0            caller's rbp with a frame pointer, else unused
  fp - 16 … fp - 1  PE: the saved rsi and rdi
  fp - 1 … fp - L   locals (the arguments' homes included), `_0`, temporaries, the
                    exception slot
  fp - F … fp - F + A   outgoing area: the stack arguments of calls, island argument blocks
  ```
  `F = round16(L + largest outgoing area)` (`abi::frame_size`). `rsp` is `fp - F` while the
  function runs, so the outgoing area is at `rsp`, and a callee's `fp` is its caller's
  `fp - F - 16`: the callee's stack arguments (at its `fp + 16`) are the caller's outgoing
  area.
- **Alignment**: `fp` is always 16-aligned (`F` is a multiple of 16, and callers keep `rsp`
  16-aligned at calls, as the ABI requires), and slots are aligned to their types relative
  to `fp`. Types with alignment above 16 never live in VM frames
  ([lowering.md](lowering.md#frame-slots)).
- One word is written per call, the return address (and with a frame pointer the caller's
  `rbp`, by `push rbp`). The current function isn't stored: unwinders and backtraces find it from the pc, like any
  native function ([Unwinding](#unwinding)). The destination slot isn't stored either: the
  value comes back in registers or the outgoing block, and the caller stores it ([Calls and
  islands](#calls-and-islands)).
- **Stack overflow**: there is no VM stack and no explicit stack check. A frame below 4096
  bytes touches at most one page past `rsp`, so running into the thread's guard page faults
  as in native code, and std's handler reports "has overflowed its stack". Larger frames
  call `ryo_probe_stack` first, which touches every page of the new frame top down (with
  `rax` the `sub`'s size, preserving every register but `r11`), as `__rust_probestack` does.
- **Re-entrancy** is plain native nesting: native code calling a VM function pushes its
  frame below whatever is already on the stack.

## Encoding

### Instruction words

- Instruction words are the serialized form of VM instructions: what tests hand-assemble,
  what `asm::decode` recovers and the disassembler prints. The backend doesn't build them;
  its lowering emits machine code directly ([Machine code](#machine-code)). The first word holds the
  opcode (low 16 bits; the high 16 must be 0). The operands follow in list order, each with
  the words of its kind (`ryo_bytecode::full`).
- The opcode list is defined once in `ryo_bytecode` (`vm/bytecode/src/ops.rs`): every opcode
  with its mnemonic, its *shape* ([Machine code](#machine-code)) and its operands. The
  opcode enum, the operand table, the decoder, the encoder and the disassembler of
  instruction words, and the handler register layouts are all generated from it. Opcode
  values follow list order. Tests pin a hash of the opcode table, of the image table entry
  sizes and field offsets (`Header`, `FuncEntry`, `FixupEntry`, `JitRecord`, ...), and of
  every opcode's machine code in eight modes (four with counters), so that a change to any
  of them is deliberate: it updates the pinned values. Nothing is versioned
  ([Image format](#image-format)).
- Code positions in instruction words are word offsets from the function start. The
  cleanup entries (`CleanupEntry`: call-like instruction → `lpad` instruction or
  `CONTINUE`, with `CATCH` for a catch-all pad) are keyed by them. Images contain only the
  machine code.
- Variable-length operands (`switch` tables and cases, island operands) are a count word
  followed by the elements. `switch.*` and `island` are the only variable-length
  instructions.
- Immediates have the instruction's width: one word for `w8`–`w32` (upper bits 0), two for
  `w64`, four for `w128`, low word first. The `switch.sparse` case values and the
  `discr.niche` niche start follow the same rule.

| Operand | Words | Meaning |
|---|---|---|
| `s`, `d` | 1 | signed frame offset: the value at `fp + off` (source / destination) |
| `[p + k]` | 2 | memory: load the pointer at `fp + p`, add the signed constant `k` |
| `imm` | 1 / 2 / 4 | immediate of the instruction's width |
| `k` | 1 | constant pool offset |
| `a` | 1 | `addr.const`: a constant pool offset, or (bit 31) a data area offset |
| `sym` | 1 | symbol table index |
| `fn` | 1 | function table index (a VM function in the same image) |
| `a` (calls) | 1 + 2n | argument list: a count, then (slot, register) pairs ([Calls and islands](#calls-and-islands)) |
| `t` | 1 | branch target, relative to the instruction start, in words |
| `!` | 1 | branch polarity (`neg`), printed as a `!` after the mnemonic |

Integer ops carry their width (`w8` … `w128`) in the opcode, and float ops their format
(`f32`, `f64`).

### Machine code

`ryo_bytecode::asm::Asm` builds one function's machine code from instructions given as
opcodes and operands (`insn`), with labels for branch targets (`label`, `bind`) and unwind
actions per instruction (`set_unwind`); `finish(F, fix)` resolves what depends on the frame
size (slots, through `fix`, and the prologue), relaxes branches and writes the code. The
backend's lowering drives it directly ([lowering.md](lowering.md)); `asm::encode(code, F,
cleanup, mode)` does the same from instruction words (tests and hand-assembled images). The
result is
machine code, relocations (`Ref`: a handler, `ryo_probe_stack`, an image function, a
symbol slot, a constant, a data offset, a code constant), code constants (island
operand arrays and sparse switch values, deduplicated) and call sites for the LSDA. After the
prologue, every instruction becomes the canonical sequence of its shape, except the common
ones, which are [inlined](#inline-instructions):

| Shape | Opcodes | Sequence |
|---|---|---|
| `op` | data movement, arithmetic, conversions, enums, atomics | operand registers, `call ryo_h_<Opcode>` |
| `br` | `br`, `br.eq`, `br.lt`, `br.gt.imm`, … | handler call (returns a `bool`), `test al, al`, `jnz t` (`jz t` with `!`) |
| `switch` | `switch.dense`, `switch.sparse` | handler call (returns the case index, `n` for the default), `lea rcx, [rip + T]; movsxd rax, [rcx + rax*4]; add rax, rcx; jmp rax`, then `int3`s to a multiple of 4 and the table `T` inline in the text: one `i32` offset from `T` per case, the default last |
| `trap` | `unreachable`, `abort`, `resume` | handler call, `ud2`; `unreachable` has no handler and is `ud2` alone |
| `ret` | `ret` | the value's loads into the return registers, epilogue, `ret` |
| `arg` | `arg` | the store of an argument register |
| `jmp` | `jmp` | `jmp t` |
| `call` | `call`, `call.sym`, `call.sym.ind`, `call.ptr` | the callee's address into `rax` where needed, the argument registers' loads, the call, the result's stores from the return registers ([Calls and islands](#calls-and-islands)) |
| `tail_call` | `tail_call`, `tail_call.ptr` | `mov rax, [p]` for `.ptr`, the argument registers' loads, epilogue, `jmp fn` / `jmp rax` |
| `island` | `island` | `lea rdi, [rsp + F]; lea rsi, [rip + ops]; call [rip + isl]` (with a frame pointer `mov rdi, rbp`; PE: `rcx`/`rdx` and 32 bytes of shadow space) |
| `lpad` | `lpad` | `mov rsi, rax` (the exception object; `rdi` with `fp-rbp`), operand registers, handler call |

The epilogue is `add rsp, F + 8`, `leave` with a frame pointer, or on PE
`lea rsp, [rbp - 16]; pop rsi; pop rdi; pop rbp` ([Frames](#frames)).

- **Operand registers** (`asm::layout`, `core` only, shared by the encoder and the
  handlers): a handler takes up to six registers, `rdi, rsi, rdx, rcx, r8, r9`, in operand
  order, on every target (`sysv64`). An operand takes one register, except a memory operand
  (`p`, `k`), a `U128` (low, high) and a case list (values, count), which take two. `rdi`
  holds `fp` (`lea rdi, [rsp + F]`, or `mov rdi, rbp` with a frame pointer) and the operands
  start at `rsi`, except with `fp-rbp`, where handlers read `rbp` and the operands start at
  `rdi`; `lpad` takes the exception object before its operand. If an opcode has more operands than registers, adjacent 32-bit
  operands (slots, `U8`–`U32`) share one, `a | b << 32`, pairing from the last pair. A
  constant, symbol or data operand is passed as its address (`lea reg, [rip + …]`).
  Branch and call targets and polarities aren't passed, and the call shapes and
  `unreachable` have no handler. `layout` is a `const fn` that fails to compile for an opcode whose
  operands don't fit.
- **Canonical form**: every element has exactly one encoding. Register values take the
  shortest of `xor r32, r32`, `mov r32, imm32`, `mov r64, simm32` and `mov r64, imm64`.
  Branches within the function start as `rel8` and grow to `rel32` where they don't reach,
  until nothing changes. Padding is the standard multi-byte `nop`s.
- **Loop heads**: the targets of backward branches are padded to 16 bytes, unless
  `RYO_ASM_ALIGN=0` ([backend.md](backend.md#debugging-switches)). After the padding they
  start with their counter check, which every branch to them passes, and the counter
  stubs follow the function's last instruction
  ([JIT records and counters](#jit-records-and-counters)).
- **Calls between image functions** (`call`, `tail_call`) are `rel32` fields that the
  image writer fills in itself. Handler and `ryo_probe_stack` calls are `Call32`
  relocations; everything else the code refers to is `Pc32` ([Image format](#image-format)).
- **The decoder** `asm::decode` is the exact inverse: it accepts only the canonical
  sequences, with operand registers set in order, and recovers every instruction word, the
  frame size and the cleanup entries (from the call sites). It is the encoder's test
  oracle: `vm/bytecode/tests/asm.rs` round-trips every opcode, in every mode (`fp` in `rdi`
  or `rbp`, with and without a frame pointer, loop alignment, PE), long branches, packed operands, every
  displacement and immediate form of the inline sequences, and rejects non-canonical code.

#### Inline instructions

The common instructions (`asm::has_inline`) are short native sequences instead of handler
calls (`asm::inline`): `mov`, `imm`, `addr`, `ptr.add` (a 32-bit offset), `ptr.index` (a
stride below 2^31), `load`, `store`, `add`, `sub`, `and`, `or`, `xor`, `mul` and their
`.imm` forms, the shifts by an immediate below the width, the compares to a `bool` (`eq`
… `ge.u.imm`), `br` and the compare-branches, the overflow ops `add.ovf`, `sub.ovf` and
`mul.ovf`, and the extensions and truncations (`zext`, `sext`, `trunc`), all at `w8`–`w64`,
and `mov.w128` as two 64-bit halves. Everything else, and these with other operands, keeps
its handler call. [instructions.md](instructions.md) gives each instruction's sequence.

- **Registers**: the sequences compute in one of the caller-saved registers but `rcx`, and
  use `rcx` as scratch, and the flags, all of which every handler call clobbers too. Only the
  register cache ([below](#register-cache)) keeps anything in a register between
  instructions. They read frame
  slots as `[rsp + F + off]` (`[rbp + off]` with a frame pointer), never move `rsp` and call
  nothing, so they are no call sites and the unwind information doesn't change. The
  encoder, the cache and the decoder work on them as `[rbp + off]`, and `Asm::finish`
  writes them in the frame's form.
- **Shape**: a sequence loads its operands (`movzx` for `w8`/`w16`), computes in `rax`, and
  ends in its one write (`mov.w128` stores its high half from `rcx` first): `mov [fp + d], al…rax`, `mov [fp + d], imm` (`imm`), `setcc
  [fp + d]` (compares), `mov [rax + k], cl…rcx` (`store`), or for branches a `cmp`/`test`
  and `jcc t` (the condition inverted with `!`), which relaxes like the other branches.
  `w8`/`w16` arithmetic with an immediate computes in 32 bits; 64-bit immediates that
  aren't sign-extended 32-bit ones go through `rcx`.
- **Overflow ops** compute the result in `rax` and write the flag before it, through `rcx`:
  `setcc cl; mov [fp + o], cl` (`seto` signed, `setb` unsigned), then the result's store.
  `add`/`sub` and signed `w32`/`w64` `imul` set the flag themselves; 8 and 16-bit multiplies
  compute the exact product in 32 bits and compare it to the width's range (`seta`), unsigned
  `w32` ones in 64 bits against `u32::MAX`, and unsigned `w64` ones are `mul [b]`, which the
  register cache computes in `rax` (it clobbers `rdx`). Extensions are `movzx`/`movsx`/`mov`
  and the store at the wider width (sign extensions to 64 bits as `shl` then `sar` by
  `64 - n`), truncations a load at the wider width and the narrower store.
- **Canonical form**: each instruction has one sequence per operand pattern, displacements
  and immediates in their shortest form, and no two instructions share a sequence; a handler
  call of an instruction that has an inline sequence isn't canonical. The
  decoder reads native elements up to the write or the branch and matches them against the
  encoder's sequences.
- **Testing**: `vm/rt/tests/inline.rs` runs every inlined opcode on random operands through
  the VM and compares the results and memory with its handler, called directly on the same
  frame. It does the same for runs of inline instructions that read each other's results,
  against their handlers called one after the other.

#### Register cache

Values stay in registers between inline sequences. The encoder tracks what the caller-saved
registers but `rcx` hold (`inline::Cache`, run over the code in `Asm::finish`): `rax`, `rdx`,
`rsi`, `rdi` and `r8`–`r11`. Every store still happens, so the frame is always up to date,
and handlers, calls, unwinding and the decoder's view of the frame don't change.

- **Which register**: a sequence is written on `rax` and renamed. If its first element
  reloads a slot a register holds at that width, it computes in that register and the reload
  is dropped. Otherwise it computes in an empty register, or the least recently used one.
- **Register operands**: a frame operand that a register holds at least as wide (`add`,
  `sub`, … and `imul` sources, `cmp` with a register or an immediate) reads the register
  instead.
- **What a register holds**: the slot (displacement and width) it was loaded from without
  sign extension, or stored to, when it is the zero-extension of the stored value (stores of
  32- and 64-bit results, and of values loaded at the store's width).
- **What clears it**: a write of the register other than those, a frame write overlapping the
  slot, a store through a pointer (it may point into the frame), every instruction that isn't
  inline (handler calls clobber these registers), and every branch target, including jump
  table entries. So the cache never crosses a block boundary that is a target.
- **Dead stores**: a store from a register is dropped when its slot is dead before
  anything reads it from the frame: the lowering marks slots dead (`Asm::dead`), the
  temporaries of each statement after it and a local after its only read (one definition
  earlier in the same block, never borrowed, dropped or indexed, `frame::dead_after_read`),
  or a later store covers it. Reads that hit the cache read the register, so only the frame
  is stale, where nothing looks. A store stays if a flush point comes first: a branch target,
  a branch, any instruction that isn't inline, a frame read of the slot, or a pointer access
  when an `addr` in the function points into the dead range (pointers into the frame only
  come from `addr`).
- **Encoding**: `r8`–`r11` take REX prefixes, and so do byte operands in `sil` and `dil`.
  Pointer registers address without a displacement when it is 0.
- **Decoding**: the decoder runs the same cache. Dropped stores aren't in the code, so
  `Encoded::dropped` lists them (the item and where it would have been; images store them
  too), and the decoder
  reads each where it would have been; it doesn't check that the store was dead. Branch targets are only known once a
  function is read, so it reads it twice: first only delimiting the inline sequences, to
  find the targets, then decoding them with the cache cleared at the targets. It tries each
  sequence on `rax`, the register renamed back, with register operands that may have been
  frame operands and the dropped reload put back, and keeps the one the cache emits as the
  code is.
- **Testing**: `vm/bytecode/tests/asm.rs` round-trips random runs of inline instructions on
  a few overlapping slots, with branches into them, and `vm/rt/tests/inline.rs` runs such
  runs against their handlers, also with dead-slot hints from a liveness pass, built with
  `Asm` directly.

#### Escapes, storage ends and island operands

The decoded code addresses frame slots with exact widths, but not where its objects begin
and end. An optimizer of decoded code needs that only for the objects whose address
escapes and for the islands' operands, so `Encoded::scopes` (`asm::Scope`) records, as side data like `dropped`:

- **Escape**: a pointer to an object escapes before the instruction: an `addr` of the
  object or a part of it, or a call argument passed by address (an sret destination, an
  `Indirect` input's copy). The scope has the whole object, the local or temporary, not the
  addressed part: its frame offset, size and alignment, since a pointer may reach any of its
  bytes. The lowering finds the object from the place's local, else the live temporary or
  the only local containing the slot (`frame.rs`, `Frame::object`), and keeps the function
  native if there is none.
- **End**: the storage of the bytes ends before the instruction: `StorageDead` of a local,
  or the temporaries' reset before each statement. Pointers into them dangle afterwards (as
  for LLVM's `lifetime.end`), so an escape of the bytes ends there, and slot sharing may
  give them to another local. `Asm::finish` keeps only the ends that overlap an escape.

- **Lend**: an island takes the object as an operand: its template reads and writes it, at
  its type, during the call only. Not an escape (the template keeps no pointer), but the
  only record of the operand's extent, which the island's operand array (offsets only)
  doesn't give: the JIT, which places frame objects itself, needs it
  ([jit.md](jit.md)). The lowering passes each island operand's size
  (`FnCx::island`).

Bytes are escaped at an instruction if an escape of them reaches it on some path, landing
pad edges included, without an end. Everything else is accessed only at the widths
the instructions give. `Asm::escape`, `Asm::storage_end` and `Asm::lend` add pieces without code,
which the register cache and dead-store dropping pass over, and layout records their
positions (an instruction's, so after a loop head's padding). The decoder maps them to word offsets (`Decoded::scopes`, also through
`reduce` and `decode_reduced`), and `vm/bytecode/tests/asm.rs` round-trips them and checks
that they don't change the code. `RYO_DUMP` shows them as `; escape …`, `; end …` and
`; lend …` lines.

### Reduced instructions

The instruction set below, the opcode list, is the *full* set (`ryo_bytecode::full`): the
lowering emits it. The *reduced* set (`ryo_bytecode::reduced`) is what the machine code
consists of: the instructions of the full set that run as native code, which are the inline
instructions and the instructions without a handler (`jmp`, the calls, `ret`, `arg`, `island`,
`unreachable`), with
the same mnemonics, shapes and operands, plus `handler` for every handler call. Its list
(`vm/bytecode/src/reduced_ops.rs`) goes through the same `define_ops!` as the full one, so it
has its own `Opcode`, `Insn`, decoder, encoder and disassembly, in the same word encoding;
`Opcode::full` and `Opcode::of_full` map between the two. Nothing stores it.

- **`handler h, args, t`** (`!` with `neg`): a call of the handler of the full opcode `h`
  with the argument registers `args` from `rdi` on (each three words: `fp`, the exception
  object, an immediate, or the address of a constant, data, a symbol slot, a site or a code
  constant), then `h`'s shape's control flow: a branch to `t[0]` on the returned `bool`
  (`br`), a jump through the table `t` on the returned index, the default last (`switch`),
  or nothing (`t` empty).
- **Mapping**: `asm::reduce` maps a function in the full set to the reduced set: a full
  instruction with operands that aren't inlined becomes a `handler`, case value arrays at
  the code constants where the encoder puts them.
- **Decoding**: `asm::decode_reduced` reads machine code to the reduced set like
  `asm::decode` to the full one, sharing everything but handler calls, which it reads from
  their registers without the handlers' operand lists (only a switch's case count comes from
  its handler's layout).
- **Linked code**: `asm::decode_linked` reads a function as it sits in memory, its fields
  resolved, at its address, without the relocation list: a `rel32` field whose target lies
  inside the function past its first byte (the prologue, never a branch target) is a branch
  or jump table, and any other target is classified by an `asm::Resolver` (a handler, a
  function of the image, a symbol slot, …), which also gives the code constants' bytes. The
  decoder shares everything else with `decode_reduced`. `image::ImageResolver` classifies by
  the image header's ranges, given the handlers' addresses, and takes the scopes, call sites
  and dropped stores from the image's tables (dropped stores aren't recoverable from the
  code: a `mov` whose reload hit the cache and whose store was dropped leaves no code).
- **Encoding**: `asm::encode_reduced` is `decode_reduced`'s exact inverse: from the reduced
  words, frame size, cleanup entries, scopes and dropped stores, and the code constants the
  `handler` arguments address, it gives the machine code, relocations, code constants, call
  sites, dropped stores and scopes `encode` gave. It drives `Asm`: native instructions go
  through `Asm::insn`, a `handler` sets its argument registers as given, calls the handler
  and ends in its shape's control flow (a sparse switch's values become a code constant again,
  in the same order, so at the same offset).
- **Dropped stores in the reduced form**: the dead marks (`Asm::dead`) that dropped a store
  aren't in the code, and can't be recovered (a mark that only partly covers a pending store
  keeps it, so marks from the dropped stores alone would drop others too). Instead
  `Decoded::dropped` lists the word offsets of the instructions whose store was dropped (the
  decoder reads them there anyway), `reduce` maps them like the scopes, and
  `encode_reduced` drops exactly those (`Asm::drop_exactly`, `Asm::drop_store`) instead of
  running dead-store dropping: the register cache runs first and keeps a sequence's write its
  last item, so the store to drop is known before.
- **Testing**: `vm/bytecode/tests/asm.rs` checks on every round trip that `decode_reduced`
  gives what `reduce` gives for the full decoder's output, and that `decode_linked` of the
  code linked at fake addresses gives the same, and `vm/bytecode/tests/reduced.rs` that the
  reduced list is the full list's native instructions. Every round trip also re-encodes
  what `decode_reduced` and `decode_linked` give and compares it with the `Encoded`, also for
  random runs built with `Asm` with dead-slot hints (there and in `vm/rt/tests/inline.rs`), and
  `RYO_ASM_CHECK` ([backend.md](backend.md#debugging-switches)) does it for every function
  the backend emits. `vm/bytecode/tests/image.rs` decodes
  a linked image's functions through `ImageResolver`.

### JIT records and counters

Every function counts its calls and loop iterations down in a *JIT record*, and leaves
through an out-of-line stub into the runtime when the count runs out: the trigger of the [JIT](jit.md)
that recompiles hot functions, and later its way into the new code (a stub calls through
the record, so redirecting the record redirects every entry and loop head without patching
code). `asm::Mode::counters` turns the counters on; the backend always does, so every image
has one code shape, and code the JIT encodes for itself has none.

- **Records** (`image::JitRecord`, one per function in function order, in the writable
  section at `Header::jit_records`): 64 bytes and 64-aligned, one cache line each, so hot
  functions' counters don't share one.
  ```
  ctr: i64              counts down; negative: take the stub
  entry: *const u8      what the entry's stub calls (offset 8, JIT_ENTRY_SLOT)
  osr: *const u8        what a loop head's stub calls (offset 16, JIT_OSR_SLOT)
  next: *mut JitRecord  the JIT queue's link
  state: AtomicU32      Cold, Queued, Done, Failed
  func: u32             the function's index
  header: *const Header
  jit_code: *const u8   the JIT code's first instruction once Done
  jit_len: u64          and its length
  ```
  The writer sets `ctr` to `JIT_THRESHOLD` (10 000), `entry` and `osr` to `ryo_rt`'s
  `ryo_jit_trip_entry` and `ryo_jit_trip_osr` and `header` to the image's header (`Abs64`
  relocations), `func` to the index, the rest to 0. From then on the runtime owns the record
  ([jit.md](jit.md#records-and-trips)).
- **Checks**: at the entry before the prologue, and at every loop head (a target of a
  backward branch, after its padding, before the head's instruction, so every branch to the
  head passes it):
  ```
  f:      sub qword [rip + rec_f.ctr], 16   ; asm::ENTRY_COUNT
          js  .tier_entry
          <prologue> …
  .head:  sub qword [rip + rec_f.ctr], 1
          js  .tier_head_N                  ; N: the head's index, in code order
          …
  ; after the last instruction: the loop heads' stubs in order, then the entry's
  .tier_head_N:  lea r11, [rip + rec_f]; mov eax, N; call [r11 + 16]; jmp .head + 10
  .tier_entry:   lea r11, [rip + rec_f]; call [r11 + 8]; jmp f + 10
  ```
  The `js` and the `jmp` back relax like other branches (`f + 14`, `.head + 14` after a
  long `js`). Counting is a plain `sub`, racy and lossy across threads, which a heuristic
  tolerates. A call counts 16 and an iteration 1, so a long-running loop trips without
  calls. The `sub`'s field is followed by its immediate, so it is relocated against
  `Ref::RecCtr`, the record less one byte, and the `lea` against `Ref::Rec`, the record. Both
  are the function's own, so the encoder needs no function index; the writer resolves them.
- **Resuming**: the stubs `call` through the record's slot, so the return address is the
  continuation in the stub, and whatever the slot points at returns there to continue the
  AOT code, with no lookup. Code a slot is redirected to that doesn't return pops the return
  address first. At the entry the `call` moves `rsp` before the prologue, which is fine: the
  callee pops it again. But the stack is aligned differently at the two: an entry trip
  starts with `rsp` a multiple of 16 (the caller's return address and the stub's are both
  on it), a loop head trip with `rsp + 8` one, as a normal callee. The stack arguments are
  at `rsp + 16` in an entry trip. A trip that calls into Rust must save the argument
  registers and align `rsp` itself, and must read and write `ctr` as a relaxed atomic, as
  the AOT code's `sub`s race with it.
- **Registers**: at the entry the argument registers (integer, `xmm0`–`xmm7`, the stack)
  are live, but `rax` and `r11` aren't: VM functions aren't variadic (those stay native), so
  nothing passes `al`, and no convention passes anything in `r11`. At a loop head nothing
  but `rsp` and `rbp` is live: the register cache is cleared at branch targets. So the stubs
  clobber only `r11`, `rax` and the flags, and the trip entry points may clobber those too.
- **The no-op JIT** (`ryo_rt` without its `jit` feature, `vm/rt/src/vm/jit/noop.rs`): the
  trip entry points set the counter to `i64::MAX`, so the function never trips again in
  practice, and return to the stub, which continues the AOT code. With the feature, the
  trips are the [JIT](jit.md#records-and-trips)'s.
- **Unwinding**: the checks move nothing and call nothing, so only the prologue's rules
  move: the FDE's `advance_loc`s start at `Encoded::prologue`. The entry's stub, last in the
  code, runs before the prologue: its FDE rows say CFA = `rsp + 8` (and with a frame pointer
  `rbp` not saved) from `Encoded::entry_stub` on. The head stubs run in the set-up frame and
  need no rows. On PE the check counts as part of the prologue (the unwind codes' offsets
  and the prologue size include it), and the entry's stub has a `.pdata` entry of its own
  with no unwind codes, as a leaf. Neither stub is a call site: unwinding out of a trip
  entry point aborts, so a trip that can panic needs call-site entries for the stubs
  first. A landing pad that is also a loop head would land on its check, whose head stub
  overwrites the exception object in `rax`; the lowering never branches to an `lpad`.
- **Decoding**: the checks and stubs are part of the canonical form. The decoder reads the
  entry's check, ends the function's instructions at the first stub, reads each loop head's
  check with the instruction it precedes (the instruction's position is the check's),
  requires a check at every loop head and nowhere else, and exactly the stubs in order. They
  decode to nothing, and `Decoded::heads` lists the loop heads' word offsets in order, so
  the stub of loop head `N` is that of `heads[N]` (`heads` is there without counters too).
  `asm::decode_linked` takes the record's address and resolves fields to it as `Ref::Rec`
  (`ImageResolver` from `Header::jit_records`). `encode_reduced` emits them again as the
  mode says, so the round trips stay byte-exact.
- **Cost**: per call and per loop iteration a memory read-modify-write and a not-taken
  branch, 10 bytes per check and 13 to 16 per stub, and 64 bytes of data per function.
- **Testing**: `vm/bytecode/tests/asm.rs` round-trips everything with and without
  counters, `vm/bytecode/tests/image.rs` checks the records, their relocations and the
  unwind information, and `vm/rt/tests/vm.rs` runs functions through the trips, at the
  entry and at loop heads, with arguments of every kind, and unwinds through frames that
  tripped.

## Instruction set

The instructions, what each does, where the lowering uses it and what machine code it
becomes (inline, its own sequence, or which handler it calls) are in
[instructions.md](instructions.md).

## Calls and islands

The calls (`call`, `call.sym`, `call.sym.ind`, `call.ptr`), `tail_call`, `ret`, `arg` and
`island` have no handler: they are native sequences that follow the platform convention
([instructions.md](instructions.md#calls-returns-and-islands)).

- **Native functions**: a VM function is an ordinary native function of its Rust-ABI
  signature. Native code, other images and fn pointers call it at its symbol
  ([backend.md](backend.md#pipeline)), and it calls native and VM callees the same way, with
  no handler, stub or lookup in between. A function whose signature the VM can't follow
  stays native ([lowering.md](lowering.md#frame-slots)).
- **Arguments** go where LLVM puts rustc's `PassMode`s of the ABI inputs
  (`backend/src/rustc_api/lower/sig.rs`, `arg_plan`): each input's scalar pieces (`Direct`,
  `Pair`, the Rust ABI's integer `Cast`) take the next argument register of their class,
  SysV `rdi, rsi, rdx, rcx, r8, r9` and `xmm0`–`xmm7`, or else an 8-byte slot of the stack
  argument area. An `i128` takes two integer registers if two are left, else a 16-aligned
  stack slot. On Win64 the four registers are positional (`rcx, rdx, r8, r9` or
  `xmm0`–`xmm3` by argument position), the stack area starts after 32 bytes of shadow
  space, and `i128`, `f16` and `f128` arguments and returns keep the function native.
  `Indirect` inputs are passed as a pointer to the value, like an integer. An sret
  function's destination pointer takes the first integer register.
- **Call sequence**: the caller stores the stack pieces into its outgoing area at `rsp` with
  ordinary moves first. The call instruction's argument list `a` (`asm::params_ok`) then
  names the register pieces as (slot, register) pairs, loaded right before the call, each
  register once; `asm::ARG_ADDR` loads the slot's address instead (`Indirect` inputs, sret
  destinations). An `Indirect` input is a copy in a temporary, since the callee may write
  to it.
- **Callee side**: the prologue (`lower/frame.rs`, `prologue`) stores the argument
  registers to the inputs' home slots with `arg`s, which come first since the first handler
  call clobbers them, along with the sret pointer and `Indirect` inputs' pointers; then it
  copies the stack pieces from `fp + 16` and the values behind the `Indirect` pointers into
  the homes. An `Indirect` input's pointer stays in its slot for tail calls.
- **Return values** go where rustc's `PassMode` of the return says, as LLVM lowers it:
  the *return kind* `k` (`asm::RET_SRET`). It is 0 for nothing, up to two register parts
  (class, size and offset of each) for `Direct`, `Pair` and the Rust ABI's integer `Cast`,
  or `RET_SRET` for `Indirect`. Integer parts take `rax` then `rdx` (`i128` takes both),
  float parts `xmm0` then `xmm1` (`movss`, `movsd`, `movups`, and `movd` through `r11` for
  `f16`), in order, as LLVM returns a first-class aggregate. A call's kind has each part's
  exact size; `ret`'s has the width it loads (integers rounded up to 1, 2, 4 or 8 bytes:
  the extra bytes are within the frame, and the ABI leaves the register's high bits
  undefined).
- **sret**: a call of an sret function is a kind-0 call whose argument list passes the
  destination's address in the first integer register (`rdi`, PE `rcx`). The callee saves
  it with `arg`, copies `_0` there with `store.copy` before `ret`, and returns the address
  in `rax` (`ret` of the saved slot as an 8-byte part).
- **Tail calls**: the stack pieces are stored over the function's own incoming stack
  arguments by separate moves first, and an `Indirect` input is copied over the function's
  own incoming value, whose pointer is passed on (as rustc does). Then the shape loads the
  argument registers (`a`), and the epilogue and `jmp fn` / `jmp rax` keep the return
  address, so the callee returns to the original caller. `become` requires matching
  signatures, so the stack arguments fit the caller's area and the return kinds match; an
  sret function passes its own saved destination pointer on. Native targets are real tail
  calls too.

## Unwinding

Panics unwind through VM frames natively, with the platform unwinder and the program's
panic runtime, as through native frames. The image carries the unwind information
([Image format](#image-format)):

- **CFI** (ELF): `.eh_frame` with one CIE, augmentation `zPLR`, whose personality is
  `rust_eh_personality`, read through the image's symbol slot for it (`DW_EH_PE_indirect`,
  PC-relative), and one FDE per function. Its rules describe the prologue: after the
  `sub rsp, F + 8` the CFA is `rsp + F + 16`. With a frame pointer every FDE has the same
  rules: after `push rbp` the CFA is `rsp + 16` with `rbp` saved at CFA − 16, after
  `mov rbp, rsp` the CFA is `rbp + 16`. Epilogues have no rules of their own: they call
  nothing, so only an asynchronous unwinder (a profiler's) could stop between them and the
  `ret` or tail jump. The rules start after the counter check, and the entry's counter stub
  has the entry's ([JIT records and counters](#jit-records-and-counters)). The linker merges the section into the program's `.eh_frame` (and its
  `.eh_frame_hdr`).
- **LSDA** (`asm::lsda`, in `.gcc_except_table.ryo_image`): per function, the call-site
  table `rust_eh_personality` reads (`uleb128` entries, landing pads relative to the
  function start, no type table). Every call that may unwind is a call site: the call of the
  call shapes, an `island`, and `resume`'s handler call. Each has the action of its cleanup entry:
  - **Continue** (`UnwindAction::Continue`): landing pad 0, so unwinding leaves the frame.
  - **Cleanup**: landing pad at the function's `lpad` stub for the cleanup block, action 0.
  - **Terminate**: a catch-all pad (action 1, type filter 1, which the Rust personality takes
    as a catch without reading a type table), so the search phase stops there even if nothing
    up the stack catches. Its stub jumps to the function's terminate stub, which calls the
    reason's lang item ([lowering.md](lowering.md#unwinding)).
  - **Unreachable**: no call site, so unwinding out of it aborts, as for a `nounwind` call.
- **Landing pads**: the lowering emits one `lpad x; jmp bb` stub per distinct unwind
  destination. The personality enters it with the exception object in `rax`, `rsp` at
  `fp - F` (and `rbp` restored); `ryo_h_Lpad` stores the object in the function's
  exception slot `x`. The cleanup code ends in `resume x`, whose handler (assembly) loads the
  object and jumps to `_Unwind_Resume`, so the unwinder sees the VM function as its caller.
- **Panic state**: nothing is caught or re-raised on the way, so std's panic count, the
  panic hook, `std::thread::panicking()` in cleanup code and "panic in a destructor during
  cleanup" behave exactly as natively. A panic that leaves a VM function just continues
  unwinding into its caller, native or not, and a `catch_unwind` island catches like the
  intrinsic does ([stubs.md](stubs.md#unwinding)).
- **Backtraces**: frames of VM functions are named by their own symbols, defined on their
  code ([Image format](#image-format)), so `RUST_BACKTRACE=1` and profilers show them between the native frames
  (`y test`'s `backtrace` check, [build.md](build.md#test-and-bench)).
- **PE**: VM code keeps the frame pointer ([Frames](#frames)), and `.pdata`/`.xdata`
  describe each function's prologue (`image/writer.rs`, `unwind_pe`: the pushes of `rbp`,
  `rdi` and `rsi`, `rbp` as frame register at `rsp + 16`, the allocation, after the counter
  check; the entry's counter stub has an entry of its own), so
  the system unwinder can walk through VM frames, but they register no exception handler:
  landing pads don't run on PE, and `resume` aborts. Like the rest of the PE column this is
  only cross-checked ([platforms.md](platforms.md)).

## Handlers

Each opcode with a handler (all but the `jmp`, `call`, `tail_call`, `ret`, `arg` and `island`
shapes) has one non-inlined function
in `ryo_rt`, `ryo_h_<Opcode>`:

- **Signature**: `unsafe extern "sysv64-unwind" fn(a0, …, a5: u64) -> R`, the six argument
  registers, on every target. `R` is `()`, `bool` (branches), `usize` (switches), or `!`
  (traps). Each handler body reads its
  operands through the opcode's `asm::layout`, a constant, so an unused register costs
  nothing. `fp` comes in `rdi`, or with the `fp-rbp` feature from `rbp`, read before
  anything else (handlers set up no frame pointer: `ryo_rt` is built without forced frame
  pointers). `fp-rbp` saves the `fp` argument of every handler call, but VM code must then
  keep the frame pointer.
- **Symbols**: `#[rustc_std_internal_symbol]` with `export_name = "ryo_h_<Opcode>"`, so the
  symbol is mangled as rustc mangles internal symbols (`mangle_internal_symbol`, under
  `__rustc`), the same in every crate that links `ryo_rt`. The backend references them by
  that name, and lists the ones an image uses as LTO roots ([backend.md](backend.md#pipeline)).
- **Generation**: `vm/rt/src/vm/handlers.rs` lists every opcode with its handler *kind* and
  the kind's parameters (`AddW32 => bin(u32, wrapping_add);`, `BrEqW32 => br_cmp(u32, ==) ->
  bool;`). Each kind is a body macro in `vm/rt/src/vm/interp.rs`, and `handlers!` expands the
  list into the handler functions (`ryo_rt::vm::h`). A `const` check fails to compile if the
  list doesn't have exactly the opcodes with Rust handlers.
- **Register entries**: most handlers also have a second entry, `ryo_hr_<Opcode>`, with
  their frame operands' values in registers, which only JIT code calls
  ([jit.md](jit.md#register-entries)).
- **Assembly**: `resume` (`ryo_h_Resume`) and `ryo_probe_stack` are naked functions: they
  end in a jump or need the caller's `rsp`. So are the JIT's trip entry points
  `ryo_jit_trip_entry` and `ryo_jit_trip_osr`, which must preserve every register but `rax`
  and `r11` ([JIT records and counters](#jit-records-and-counters), [jit.md](jit.md#records-and-trips)).
- **Safety model**: images are trusted. Slots are accessed unaligned through `fp + offset`,
  values that may be pointers or uninitialized move as `MaybeUninit` or bytes, memory
  operands dereference what the program computed, and nothing in a handler panics (offset
  arithmetic is wrapping, errors go to `fatal`).
- **Test**: `vm/rt/tests/codegen.rs` builds `ryo_rt` as `y build` does (release,
  `-Ccodegen-units=1`) with `--emit=asm`, and checks that every opcode with a handler has its
  `ryo_h_<Opcode>` function, that with `fp-rbp` every Rust handler reads `rbp` before any
  instruction that writes it, and that the hot handlers have no prologue (no push, no stack
  adjustment) and make no call. `vm/rt/tests/ops.rs` calls every handler directly against a
  Rust reference model, and `vm/rt/tests/vm.rs` runs hand-assembled functions, encoded and
  linked in memory, and called as native functions from the tests and from native code, in `vm::MODE` (without a frame pointer,
  or with `fp-rbp` with one). `cargo test` covers the default; run it with
  `--features fp-rbp` too after changing frames or handlers. `vm/jit/tests/jit.rs` runs
  such functions through the [JIT](jit.md#testing).

## Image format

**Version-matched.** The backend, `ryo_rt` and the JIT are built together from one source
(`y build`), so the image format, the JIT interface (`RtApi`) and the runtime's interface to
the backend carry no version numbers and no compatibility checks: a reader assumes images of
its own build. The header's magic only tells an image from other bytes.

Each crate's image is one object file with a read-only section, a writable section, a text
section and unwind sections, plus relocations. It defines the symbol
`__ryo_image_<StableCrateId>`, which points at the header.

**Read-only** (`.data.rel.ro.ryo_image` / `.rdata$ryo_image`):

```
header          magic, crate hash, StableCrateId, pointers to the writable
                and text sections (relocated), sizes, offset/count of every part below,
                site count, fixup area offset, the `asm::Mode` the code was encoded in,
                the JIT records' offset and count
functions       per function, sorted by code offset: code offset and length (bytes in the
                text section), argument block size, return value size, return kind, and
                its runs of the scope, call-site and dropped-store tables (first index,
                count)
code constants  what the machine code refers to: island operand arrays (a count, then the
                words), sparse switch values
fixups          PE only: (writable offset, symbol index, addend)
symbol flags    one byte per symbol (bit 0: indirect, load through the slot; PE only, and
                only for the `sym` of `addr.sym.ind`/`call.sym.ind`, never for islands
                or allocation pointers, [platforms.md](platforms.md). A symbol used
                both ways has two slots)
symbols         pointer-sized slots, one per referenced native symbol (functions, statics,
                islands, `rust_eh_personality` on ELF), filled in by the linker
constants       constant pool: allocations, aligned
scopes          per function, sorted by position: where a frame object escapes, its
                storage ends or an island takes it as an operand (`asm::Scope`: code
                offset, frame offset, size, alignment, 0 for an end or `SCOPE_LEND`)
call sites      per function, sorted by position: code offset and length, landing pad
                offset (with the catch bit) or none (`asm::CallSite`)
dropped stores  per function, sorted by position: the stores of inline sequences dropped as
                dead (`asm::DroppedStore`: code offset, frame offset, size, register)
```

Scopes, call sites and dropped stores are for decoding a linked function's code at run time
(`asm::decode_linked`), which the code alone doesn't allow: scopes and dropped stores aren't
in the code at all, and the call sites are the LSDA's, which the runtime can't find per function without
parsing `.eh_frame` (and PE has none). The records are the encoder's on both formats.
The code's relocations needn't be stored: `asm::decode_linked` recovers them from the
resolved fields ([Reduced instructions](#reduced-instructions)).

The read-only section can live in RELRO/`.rdata`, since nothing writes to it after
relocation.

**Writable** (`.data.ryo_image` / `.data$ryo_image`):

```
site cache    site_count pointer-sized slots; no instruction uses them any more, so the
              backend leaves it empty
fixups        PE only: constant allocations that point at DLL-imported data
jit records   with counters, one `JitRecord` per function, 64-aligned, past the fixup
              area's one-past-the-end address ([JIT records and
              counters](#jit-records-and-counters))
```

**Text** (`.text.ryo_image` / `.text$ryo_image`): every function's machine code, in function
table order, each aligned to 16 (padded with `int3`), with the function's own symbol
on it: global, with the function's linkage and visibility, when native code or the image
calls it by name, local otherwise (backtraces, profilers) ([backend.md](backend.md#pipeline)). **Unwind**: `.eh_frame` and
`.gcc_except_table.ryo_image` (ELF), `.pdata` and `.xdata` (PE) ([Unwinding](#unwinding)).

- `ryo_bytecode::image` defines the exact layout (`Header`, `FuncEntry`, `FixupEntry`,
  `ScopeEntry`, `CallSiteEntry`, `DroppedEntry`).
  `addr.const` data offsets are offsets from the start of the fixups area.
- **Relocations** (`RelocKind`):
  - `Abs64` (`R_X86_64_64` / `IMAGE_REL_AMD64_ADDR64`): the header's `data` and `text`
    pointers, one per symbol slot, the pointers inside constant and fixup allocations
    (against a symbol, or intra-image against either section), and each JIT record's
    `entry`, `osr` (against `ryo_jit_trip_entry` and `ryo_jit_trip_osr`) and `header`.
  - `Pc32` (`R_X86_64_PC32` / `REL32`): the code's RIP-relative fields (symbol slots,
    constants, the data area, code constants, the function's JIT record), and the
    `.eh_frame` references.
  - `Call32` (`R_X86_64_PLT32` / `REL32`): calls of the handlers and `ryo_probe_stack`.
  - `Rva32` (`IMAGE_REL_AMD64_ADDR32NB`): the `.pdata` entries.

  Calls between functions of the image are resolved by the writer, so they need none.
- **The writer** (`ImageWriter`): `prepare` (the personality slot on ELF), then
  `finish_encoded` takes each function's machine code (the backend's, built while lowering)
  and lays out the sections, resolves the calls between functions and writes the unwind
  information. `finish` encodes functions given as instruction words first (tests). The result (`ImageObject`) is the section bytes, each
  function's code range and call sites, the symbols and the relocation list; the backend
  turns it into an object file. The reader (`Image`) is a zero-copy view over a linked image
  and needs only `core`.
- A PE fixup writes `*slot + addend` at its offset, where `slot` is the indirect symbol's
  slot (the address of `__imp_<sym>`).
- The crate hash is the 32-bit fold of the `StableCrateId`
  (`ryo_bytecode::image::crate_hash`). It is stored in the header, which also keeps the full
  `StableCrateId`, so the registry can detect collisions.
- **Images are trusted**: they are produced by the backend, and the VM doesn't validate
  code. `Image::parse` checks the header (with the mode: known bits, `Mode::valid`) and
  part bounds, and `Image::validate` checks the tables only (functions with their scope and
  call-site runs, sorted and in range, fixups, symbol flags). For functions given as instruction words,
  `finish` checks them (`ryo_bytecode::image::validate_code`: operands in range, branch
  targets on instruction starts, no fall-through past the end, symbol indirection) and the
  cleanup entries, and `encode` checks that every cleanup entry is at an instruction that
  may unwind and lands on an `lpad`. `finish_encoded` checks the relocation targets' ranges.
- **No re-entry into the VM from the runtime**: the registry and the handlers use only `core` and `ryo_rt`'s own lock (a spin lock, or a
  futex/`WaitOnAddress` lock). With `--sysroot ryo`, std's `Mutex`, allocator or TLS code may
  be VM functions, and calling them from inside the runtime would enter the VM before it
  exists. `ryo_rt` being `#![no_std]` rules out direct calls into std and alloc, but not
  core's panic path: under `--sysroot ryo` the `#[panic_handler]` is std's, a VM function, so
  a panic in the runtime (a bounds check, `unwrap`, core's sorts) would enter the VM too. So
  runtime code uses `get` + `fatal`, its own insertion sort, and `C-unwind` for its exported
  C entry points (no abort-on-unwind guard, which calls `core::panicking`). `y test`
  (`rt-core-only`) checks both: the rlibs' undefined symbols name no crate but `core`,
  `compiler_builtins` and `ryo_bytecode` (plus libc and the unwinder), and no call path from
  anything `ryo_rt`'s rlib defines, through `ryo_bytecode`, reaches `core::panicking::*`, a
  `*_fail` helper or `panic_on_ord_violation`. The templates are generic, so they are
  compiled in the program's crates, not in that rlib, and may panic like any program code.
  The [JIT](jit.md)'s trips and queue are part of the runtime and checked like it. Its
  thread, which uses std, is the sealed object the rlib bundles, with a std of its own
  ([Packaging](jit.md#packaging)): the check skips that member (`jit-sealed` checks it), and the
  runtime reaches it only through `ryo_jit_start`.
- **Registry**: `ryo_vm_register(images, n)` is called by the registry object's constructor,
  and also when a shared object loads at run time (`dlopen`/`LoadLibrary`). It appends the
  images to a global list under `ryo_rt`'s lock, applies the PE fixups, and publishes the
  list: readers load an atomic pointer to an immutable snapshot, and old snapshots are never
  freed. The snapshot holds the images sorted by crate hash. Images are never unregistered:
  unloading a shared object that contains ryo code (`dlclose`/`FreeLibrary`) is not
  supported, because frames and fn pointers may still point into it.
  It does no other work, so startup is O(number of images): it only parses headers
  (`Image::parse`, O(1)), and runs `Image::validate` only for images with PE fixups, which
  `apply_fixups` requires. Nothing looks functions up at run time: calls go to symbols.
  Registry memory comes from `mmap`ed chunks (`VirtualAlloc` on PE), not the Rust
  allocator.
- **`__ryo_registry_anchor`**: each image object references it (a pointer slot relocated
  against it, `objfile.rs`, `write_image`), so a C linker that takes an image out of a
  staticlib takes the registry object defining it too ([backend.md](backend.md#pipeline)).

## JIT

With its `jit` feature, `ryo_rt` recompiles hot functions on a background thread and
switches their entry and loop heads over to the new code, entering it mid-call by OSR
([jit.md](jit.md)). What the VM provides for it is the code shape above: the [JIT
records and counters](#jit-records-and-counters), canonical code that the JIT decodes from
the image alone ([Reduced instructions](#reduced-instructions)), and loop heads at which
the whole state is in the frame ([Register cache](#register-cache)). The JIT thread is a
separate crate, `ryo_jit`, sealed with a std of its own into an object that `ryo_rt`'s
rlib bundles ([jit.md](jit.md#packaging)).

## Runtime crate: `ryo_rt`

The whole runtime is one rlib in the sysroot: the handlers, the registry, the island
templates and the `main` wrapper. It is a normal Rust dependency of every ryo-built crate.

- **Generic templates** get instantiated per program, with that program's types, from MIR in
  `ryo_rt`'s metadata.
- **Linking** follows Rust's normal rules: a Rust dylib contains one copy of `ryo_rt`, and the
  exe linking it uses that copy (`dependency_format`). Each cdylib or staticlib gets its own
  copy, with the usual Rust symbol hygiene.
- **std**: `ryo_rt` is `#![no_std]`: it uses only `core` (its tests use std). With
  `--sysroot ryo`, alloc and std are ryo-built and depend on `ryo_rt`
  ([build.md](build.md#build)), so it can't depend on them, and it must not call into them
  anyway (see "No re-entry" above). The [JIT](jit.md) thread has a std of its own, sealed in
  an object the rlib bundles ([Packaging](jit.md#packaging)), so `ryo_rt` is `core`-only in both
  sysroots; that object still needs libc and the unwinder, so a `#![no_std]` final artifact
  doesn't link where `ryo_rt` has the JIT. Unwinding goes through the platform unwinder
  (`_Unwind_Resume`) and the program's personality and panic runtime. `y build` builds
  `ryo_rt` against each sysroot's `core`.
- **Speed**:
  - The handlers are non-generic and compiled once by `y build` at
    `-O3 -Ccodegen-units=1` (`-Cembed-bitcode=yes` for users' LTO), so they're fast even in
    user debug builds.
  - Generic code, by contrast, is compiled at the user's opt-level, and at `-O0`
    `#[optimize(speed)]` has no effect (`rustc_codegen_ssa/src/base.rs:1205`).
  - So templates stay thin, and the handlers are never generic or `#[inline]`.

### Modules

- **`vm`**: the handlers (`vm::h`, generated, plus the assembly ones), the registry and the
  JIT's trip entry points (`vm::trip_entry`, `vm::trip_osr`) and the rest of its runtime
  side (`vm::jit`, [jit.md](jit.md)). Everything uses `core` only.
  - `vm::register`: `#[no_mangle] extern "C-unwind" fn ryo_vm_register(images, n)`.
  - `vm::MODE` / `vm::FP_ARG` (diagnostic item `ryo_rt_fp_arg`): whether the handlers take
    `fp` in `rdi` (unless the `fp-rbp` cargo feature is on). The backend evaluates `FP_ARG`
    and encodes to match, with a frame pointer if it is false.
- **`island`**: the island templates ([stubs.md](stubs.md#templates)).
- **`entry`**: the C `main` wrapper `c_main` ([stubs.md](stubs.md#program-entry-main)).

### Rules

- `ryo_rt` is always compiled by cg_llvm, and the backend treats every `ryo_rt` instance as
  native, including stub instances and their neighbors.
- It depends on `core` and `ryo_bytecode` only, with no third-party crates, and bundles the
  sealed JIT. `ryo_bytecode` is `#![no_std]`. Its reader and `asm::layout` need only
  `core`, and the encoder, decoder and image writer sit behind its `alloc` feature, which
  `ryo_rt` doesn't enable (`ryo_jit`, built separately, does). `y build` installs
  `libryo_bytecode.rlib` next to `libryo_rt.rlib`. `ryo_jit` may take dependencies of its
  own: they are sealed with it, and invisible to programs.
- It is built with the backend, so it carries no ABI version
  ([version-matched](#image-format)).
- **Panic strategy**: `ryo_rt` is built with `panic=unwind`, like std. It is valid in
  `panic=abort` programs (`verify_ok` in `rustc_metadata/src/dependency_format.rs:404-500`) as
  long as it makes no `C-unwind` calls (`ffi_unwind_calls.rs:132`): `_Unwind_Resume` is only
  reached from `resume`'s assembly. `-Zpanic-in-drop` must match.
