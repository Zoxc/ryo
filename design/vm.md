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
  values follow list order. Every change bumps `ryo_bytecode::FORMAT_VERSION`, as does every
  change to an image table layout (`Header`, `FuncEntry`, `FixupEntry`) or to the machine
  code of an instruction. Tests pin a hash of the opcode table, of the table entry sizes and
  field offsets, and of every opcode's machine code in three modes to the version.
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
| `a` | 1 | `addr.abs`: a constant pool offset, or (bit 31) a data area offset |
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
| `trap` | `unreachable`, `abort`, `resume` | handler call, `ud2` |
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
  Branch and call targets and polarities aren't passed, and the call shapes have no
  handler. `layout` is a `const fn` that fails to compile for an opcode whose
  operands don't fit.
- **Canonical form**: every element has exactly one encoding. Register values take the
  shortest of `xor r32, r32`, `mov r32, imm32`, `mov r64, simm32` and `mov r64, imm64`.
  Branches within the function start as `rel8` and grow to `rel32` where they don't reach,
  until nothing changes. Padding is the standard multi-byte `nop`s.
- **Loop heads**: the targets of backward branches are padded to 16 bytes, unless
  `RYO_ASM_ALIGN=0` ([backend.md](backend.md#debugging-switches)).
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
… `ge.u.imm`), `br` and the compare-branches, all at `w8`–`w64`. Everything else, and
these with other operands, keeps its handler call.

- **Registers**: the sequences compute in one of the caller-saved registers but `rcx`, and
  use `rcx` as scratch, and the flags, all of which every handler call clobbers too. Only the
  register cache ([below](#register-cache)) keeps anything in a register between
  instructions. They read frame
  slots as `[rsp + F + off]` (`[rbp + off]` with a frame pointer), never move `rsp` and call
  nothing, so they are no call sites and the unwind information doesn't change. The
  encoder, the cache and the decoder work on them as `[rbp + off]`, and `Asm::finish`
  writes them in the frame's form.
- **Shape**: a sequence loads its operands (`movzx` for `w8`/`w16`), computes in `rax`, and
  ends in its one write: `mov [fp + d], al…rax`, `mov [fp + d], imm` (`imm`), `setcc
  [fp + d]` (compares), `mov [rax + k], cl…rcx` (`store`), or for branches a `cmp`/`test`
  and `jcc t` (the condition inverted with `!`), which relaxes like the other branches.
  `w8`/`w16` arithmetic with an immediate computes in 32 bits; 64-bit immediates that
  aren't sign-extended 32-bit ones go through `rcx`.
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
  `Encoded::dropped` lists them (the item and where it would have been), and the decoder
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

### Reduced instructions

The instruction set above, the opcode list, is the *full* set (`ryo_bytecode::full`): the
lowering emits it. The *reduced* set (`asm::reduced`) is what the machine code consists of:
the instructions of the full set that run as native code, which are the inline instructions
with operands they inline and the shapes without a handler (`jmp`, the calls, `ret`, `arg`,
`island`), plus one `handler` instruction for every handler call:

- **`handler`**: the handler `ryo_h_<Opcode>`, the values of its argument registers from
  `rdi` on (`fp`, the exception object, an immediate, or an address: a constant, data, a
  symbol slot or a code constant), and what follows the call, its shape's control flow: the
  next instruction, a branch on the returned `bool` with its polarity, a jump table on the
  returned index, or nothing (`trap`).
- **Mapping**: `reduce` maps a function in the full set to the reduced set, case value
  arrays placed in the code constants as the encoder places them. Targets and cleanup
  entries are instruction indices.
- **Decoding**: `asm::decode_reduced` reads machine code to the reduced set like
  `asm::decode` to the full one, sharing everything but handler calls, which it reads from
  their registers without the handlers' operand lists (only a switch's case count comes from
  its handler's layout). `vm/bytecode/tests/asm.rs` checks on every round trip that it gives
  what `reduce` gives for the full decoder's output.

## Instruction set

### Data movement

| Instruction | Semantics |
|---|---|
| `mov.wN d, s` | copy N bits |
| `copy d, s, len` | copy `len` bytes between frame slots (never overlapping) |
| `imm.wN d, imm` | store an immediate |
| `const d, k, len` | copy `len` bytes from the constant pool |
| `zero d, len` | zero `len` bytes |
| `load.wN d, [p + k]` | load from memory |
| `store.wN [p + k], s` | store to memory |
| `load.copy d, [p + k], len` / `store.copy [p + k], s, len` | aggregate load/store (`memmove` semantics) |
| `memcpy dp, sp, n` / `memmove dp, sp, n` / `memset dp, b, n` | with runtime pointers and lengths in slots |
| `fill d, k, elem_size, count` | repeat a constant element |

### Addresses

| Instruction | Semantics |
|---|---|
| `addr d, s` | `d = fp + s` (slot address) |
| `addr.sym d, sym` | address of a function (native or VM) or static (the symbol slot's value) |
| `addr.sym.ind d, sym` | load the address through the slot (PE `__imp_` data, [platforms.md](platforms.md)) |
| `addr.abs d, a` | address of a constant pool allocation, or of one in the writable `fixups` area (PE) |
| `ptr.add d, p, imm` | `d = p + imm` (wrapping, `imm` is an i64) |
| `ptr.index d, p, i, stride` | `d = p + i * stride` (`stride` is a u32. Larger strides use `mul.w64` + `add.w64`) |

### Integer arithmetic

At widths 8/16/32/64/128, wrapping:

| Instruction | Semantics |
|---|---|
| `add sub mul .wN d, a, b` | |
| `div.s div.u rem.s rem.u .wN d, a, b` | no checks (MIR guarantees valid operands) |
| `and or xor .wN d, a, b` | |
| `shl shr.s shr.u .wN d, a, b` | amount masked to the width. `b` has width N too (the lowering converts a differently typed amount first) |
| `neg not .wN d, a` | |
| `add.ovf sub.ovf mul.ovf .{s,u}.wN d, o, a, b` | result at `d`, overflow flag (`bool`) at `o`. The lowering passes the offsets of the pair's two fields, since rustc decides the pair's field order |
| `eq ne lt.s lt.u le.s le.u .wN d, a, b` | writes a `bool` |
| `cmp3.s cmp3.u .wN d, a, b` | three-way compare (`Ordering` as `i8`) |
| `rotl rotr .wN d, a, b` | `b` is a `u32`, as in the intrinsics |
| `ctpop ctlz cttz .wN d, a` | result is a `u32`, as in the intrinsics |
| `bswap bitreverse .wN d, a` | |

`.imm` variants take an immediate of the width as `b`: `add sub mul and or xor shl shr.s
shr.u` and the compares `eq ne lt le gt ge` (signed and unsigned; `gt`/`ge` exist only as
`.imm`, because the register forms can swap operands). At 128 bits, `mul`, `div`, `rem` and
`mul.ovf` are islands, so those opcodes don't exist at `w128`.

### Floating point

| Instruction | Semantics |
|---|---|
| `fadd fsub fmul fdiv frem .fN d, a, b` | IEEE, with Rust semantics |
| `fneg fabs .fN d, a` | |
| `feq fne flt fle .fN d, a, b` | |
| `fmin fmax copysign .fN d, a, b` | |

libm functions (`sqrt`, `sin`, `powi`, …) are islands, and so are all `f16` and `f128`
operations.

### Conversions

| Instruction | Semantics |
|---|---|
| `zext.wA.wB`, `sext.wA.wB`, `trunc.wA.wB d, s` | |
| `cvt.f2i.sat.{s,u}.fN.wM d, s` | Rust `as` (saturating, NaN → 0) |
| `cvt.i2f.{s,u}.wM.fN d, s`, `cvt.f2f.fA.fB d, s` | |

Bit-preserving casts are `mov`/`copy`.

### Enums

| Instruction | Semantics |
|---|---|
| `discr.niche.wN d, s, niche_start, variants_start, variants_end, untagged` | decodes a niche-encoded tag into a variant index (`TagEncoding::Niche`) |
| `set_discr.niche.wN d, variant, niche_start, variants_start, untagged` | stores a variant's niche value (a no-op for the untagged variant) |

`niche_start` is an immediate of the tag width. The variant indices are u32s, and `d` of
`discr.niche` receives a `u32` variant index, which the lowering converts to the
discriminant type. Direct-tagged enums use plain loads, stores and integer ops.

### Atomics

- **Operations**: `atomic.load/store.wN.ord`,
  `atomic.xchg/add/sub/and/or/xor/nand/min/max/umin/umax.wN.ord`,
  `atomic.cxchg[.weak].wN.ord_s.ord_f`, `fence.ord`, `compiler_fence.ord`. Each handler
  performs the matching `core::sync::atomic` operation. Orderings are `relaxed`, `acquire`,
  `release`, `acqrel` and `seqcst`, and only the combinations core accepts exist (loads have
  no `release`/`acqrel`, stores no `acquire`/`acqrel`, failure orderings are
  `relaxed`/`acquire`/`seqcst`, fences aren't `relaxed`).
- **Operands**: `atomic.load d, [p]`, `atomic.store [p], s`, `atomic.<rmw> d, [p], s` (`d`
  gets the old value), and `atomic.cxchg d, o, [p], old, new`, with the previous value at
  `d` and the success flag at `o`. `p` is a slot holding the pointer.
- **Width and alignment**: widths 8–64 run in the VM. 128-bit atomics are islands (they need
  `cmpxchg16b`, which core provides when the target supports it). Atomic operands are always
  aligned as the type requires.

### Control flow

Branches have a polarity: `br.eq! a, b, t` branches when `a != b`.

| Instruction | Semantics |
|---|---|
| `jmp t` | |
| `br s, t` / `br! s, t` | branch if the `bool` slot is true / false |
| `br.eq`, `br.lt.s`, `br.lt.u .wN a, b, t` (and `!`) | fused compare + branch. `ne`, `le` and `ge` are the negated forms, with swapped operands where needed |
| `br.eq`, `br.lt.{s,u}`, `br.gt.{s,u} .imm.wN a, imm, t` (and `!`) | with an immediate |
| `switch.dense.wN s, base, t_default, n, t_0 … t_{n-1}` | jump table on `s - base` |
| `switch.sparse.wN s, t_default, n, (v_i, t_i)…` | sorted values: a linear scan for `n ≤ 4`, binary search above |
| `unreachable` | report and abort (only reachable through UB) |
| `abort` | `core::intrinsics::abort` |

### Calls and islands

| Instruction | Semantics |
|---|---|
| `call d, fn, k, a` | call a VM function in this image (`call rel32`) |
| `call.sym d, sym, k, a` | call the function at symbol `sym`, native or a VM function of any image (`call [rip + slot]`) |
| `call.sym.ind d, sym, k, a` | the same through an indirect symbol slot (PE `__imp_`, [platforms.md](platforms.md)): `mov rax, [rip + slot]; call [rax]` |
| `call.ptr d, p, k, a` | call through the fn pointer in slot `p`: `mov rax, [p]; call rax` |
| `tail_call fn, a` | `become` a VM function in this image |
| `tail_call.ptr p, a` | `become` through the fn pointer in `p`. A tail call to anything with a symbol is `addr.sym` + `tail_call.ptr` |
| `ret s, k` | return `_0` at `s` as the return kind `k` says |
| `arg d, r` | store the argument register `r` to slot `d` (only first in a function) |
| `island isl, n, ops…` | call `isl(fp, &ops)` and continue |
| `lpad x` | landing pad: store the exception object in slot `x` |
| `resume x` | continue unwinding the exception object in slot `x` |

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
- **`call`**: after the call come the stores of the return registers into `d` (pieces of
  4, 2 and 1 bytes with shifts in between for a 3-, 5-, 6- or 7-byte integer part). With
  `k` 0 there is none, and `d` must be 0.
- **`ret`**: loads the value at `fp + s` into the return registers, and the epilogue and
  `ret` return. With `k` 0, `s` must be 0.
- **Tail calls**: the stack pieces are stored over the function's own incoming stack
  arguments by separate moves first, and an `Indirect` input is copied over the function's
  own incoming value, whose pointer is passed on (as rustc does). Then the shape loads the
  argument registers (`a`), and the epilogue and `jmp fn` / `jmp rax` keep the return
  address, so the callee returns to the original caller. `become` requires matching
  signatures, so the stack arguments fit the caller's area and the return kinds match; an
  sret function passes its own saved destination pointer on. Native targets are real tail
  calls too.
- **`island`**: `island(fp, ops)` through the symbol slot `isl`, with the operand words in
  the code constants: `lea rdi, [rsp + F]; lea rsi, [rip + ops]; call [rip + isl]`
  (`mov rdi, rbp` with a frame pointer; on PE `rcx`/`rdx` and `sub rsp, 32` / `add rsp, 32`
  around the call for the shadow space). The island's return value is ignored, and
  execution continues after the call. The `ops` array is exactly what the template reads
  ([stubs.md](stubs.md#islands-vm--native)); call templates take the argument block as a
  tuple in the outgoing area, `ops[1]` the destination. Islands remain for `extern "C"`
  callees (`call_cN`), safe callees without a symbol (`call`), intrinsics and operations
  the VM has no instruction for.

### Unwinding

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
  `ret` or tail jump. The linker merges the section into the program's `.eh_frame` (and its
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
  `rdi` and `rsi`, `rbp` as frame register at `rsp + 16`, the allocation), so
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
- **Assembly**: `resume` (`ryo_h_Resume`) and `ryo_probe_stack` are naked functions: they
  end in a jump or need the caller's `rsp`.
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
  `--features fp-rbp` too after changing frames or handlers.

## Image format

Each crate's image is one object file with a read-only section, a writable section, a text
section and unwind sections, plus relocations. It defines the symbol
`__ryo_image_<StableCrateId>`, which points at the header.

**Read-only** (`.data.rel.ro.ryo_image` / `.rdata$ryo_image`):

```
header          magic, format version, crate hash, StableCrateId, pointers to the writable
                and text sections (relocated), sizes, offset/count of every part below,
                site count, fixup area offset
functions       per function, sorted by code offset: code offset and length (bytes in the
                text section), argument block size, return value size, return kind
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
```

The read-only section can live in RELRO/`.rdata`, since nothing writes to it after
relocation.

**Writable** (`.data.ryo_image` / `.data$ryo_image`):

```
site cache    site_count pointer-sized slots; no instruction uses them any more, so the
              backend leaves it empty
fixups        PE only: constant allocations that point at DLL-imported data
```

**Text** (`.text.ryo_image` / `.text$ryo_image`): every function's machine code, in function
table order, each aligned to 16 (padded with `int3`), with the function's own symbol
on it: global, with the function's linkage and visibility, when native code or the image
calls it by name, local otherwise (backtraces, profilers) ([backend.md](backend.md#pipeline)). **Unwind**: `.eh_frame` and
`.gcc_except_table.ryo_image` (ELF), `.pdata` and `.xdata` (PE) ([Unwinding](#unwinding)).

- `ryo_bytecode::image` defines the exact layout (`Header`, `FuncEntry`, `FixupEntry`).
  `addr.abs` data offsets are offsets from the start of the fixups area.
- **Relocations** (`RelocKind`):
  - `Abs64` (`R_X86_64_64` / `IMAGE_REL_AMD64_ADDR64`): the header's `data` and `text`
    pointers, one per symbol slot, and the pointers inside constant and fixup allocations
    (against a symbol, or intra-image against either section).
  - `Pc32` (`R_X86_64_PC32` / `REL32`): the code's RIP-relative fields (symbol slots,
    constants, the data area, code constants), and the `.eh_frame` references.
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
  code. `Image::parse` checks the header and part bounds, and `Image::validate` checks the
  tables only (functions, fixups, symbol flags). For functions given as instruction words,
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
  anyway (see "No re-entry" above). Unwinding goes through the platform unwinder
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

- **`vm`**: the handlers (`vm::h`, generated, plus the assembly ones) and the registry.
  Everything uses `core` only.
  - `vm::register`: `#[no_mangle] extern "C-unwind" fn ryo_vm_register(images, n)`.
  - `vm::MODE` / `vm::FP_ARG` (diagnostic item `ryo_rt_fp_arg`): whether the handlers take
    `fp` in `rdi` (unless the `fp-rbp` cargo feature is on). The backend evaluates `FP_ARG`
    and encodes to match, with a frame pointer if it is false.
- **`island`**: the island templates ([stubs.md](stubs.md#templates)).
- **`entry`**: the C `main` wrapper `c_main` ([stubs.md](stubs.md#program-entry-main)).

### Rules

- `ryo_rt` is always compiled by cg_llvm, and the backend treats every `ryo_rt` instance as
  native, including stub instances and their neighbors.
- It depends on `core`/`std` and `ryo_bytecode` only, with no third-party crates.
  `ryo_bytecode` is `#![no_std]`. Its reader and `asm::layout` need only `core`, and the
  encoder, decoder and image writer sit behind its `alloc` feature, which `ryo_rt` doesn't
  enable. `y build` installs `libryo_bytecode.rlib` next to `libryo_rt.rlib`.
- It carries a `RYO_RT_ABI` const (diagnostic item `ryo_rt_abi`), which the backend
  evaluates and checks, erroring on a mismatch.
- **Panic strategy**: `ryo_rt` is built with `panic=unwind`, like std. It is valid in
  `panic=abort` programs (`verify_ok` in `rustc_metadata/src/dependency_format.rs:404-500`) as
  long as it makes no `C-unwind` calls (`ffi_unwind_calls.rs:132`): `_Unwind_Resume` is only
  reached from `resume`'s assembly. `-Zpanic-in-drop` must match.
