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
- **No image context**: the code addresses its image's symbol slots, site cache, constant
  pool, data area and code constants RIP-relative (relocations, [Image format](#image-format)),
  so a call into another image switches nothing.
- **No per-thread state**: a return value goes to `rax`/`rdx` or the caller's outgoing
  block, never through a pointer the VM keeps ([Calls and islands](#calls-and-islands)), so
  re-entrant `vm::enter` calls (VM → island → native → portal → VM) share nothing.

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
- **Layout**: frames grow downward, and slots are signed offsets from `fp`
  (`ryo_bytecode::abi`):
  ```
  fp + 16 + …       argument block (arg_block layout of the signature, lowering.md),
                    written by the caller in its outgoing area
  fp + 8            return address (points after the caller's call instruction)
  fp + 0            caller's rbp with a frame pointer (0 for the entry frame of a
                    vm::enter), else unused
  fp - 1 … fp - L   locals, `_0`, temporaries, the exception slot
  fp - F … fp - F + A   outgoing argument block of the calls this function makes
  ```
  `F = round16(L + largest outgoing block)` (`abi::frame_size`). `rsp` is `fp - F` while the
  function runs, so the outgoing block is at `rsp`, and a callee's `fp` is its caller's
  `fp - F - 16`: the callee's argument block (at its `fp + 16`) is exactly the caller's
  outgoing block.
- **Alignment**: `fp` is always 16-aligned (`F` is a multiple of 16, and every entry is
  16-aligned, [Entry](#entry)), and slots are aligned to their types relative to `fp`. Types
  with alignment above 16 never live in VM frames ([lowering.md](lowering.md#frame-slots)).
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
- **Re-entrancy** is plain native nesting: `vm::enter` pushes its frames below whatever is
  already on the stack.

## Encoding

### Instruction words

- Instruction words are the serialized form of VM instructions: what tests hand-assemble,
  what `asm::decode` recovers and the disassembler prints. The backend doesn't build them;
  its lowering emits machine code directly ([Machine code](#machine-code)). The first word holds the
  opcode (low 16 bits; the high 16 must be 0). The operands follow in list order, each with
  the words of its kind (`ryo_bytecode::insn`).
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
| `site` | 1 | index into the image's writable site cache ([Image format](#image-format)) |
| `fn` | 1 | function table index (a VM function in the same image) |
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
symbol slot, a site, a constant, a data offset, a code constant), code constants (island
operand arrays and sparse switch values, deduplicated) and call sites for the LSDA. After the
prologue, every instruction becomes the canonical sequence of its shape, except the common
ones, which are [inlined](#inline-instructions):

| Shape | Opcodes | Sequence |
|---|---|---|
| `op` | data movement, arithmetic, conversions, enums, atomics | operand registers, `call ryo_h_<Opcode>` |
| `br` | `br`, `br.eq`, `br.lt`, `br.gt.imm`, … | handler call (returns a `bool`), `test al, al`, `jnz t` (`jz t` with `!`) |
| `switch` | `switch.dense`, `switch.sparse` | handler call (returns the case index, `n` for the default), `lea rcx, [rip + T]; movsxd rax, [rcx + rax*4]; add rax, rcx; jmp rax`, then `int3`s to a multiple of 4 and the table `T` inline in the text: one `i32` offset from `T` per case, the default last |
| `trap` | `unreachable`, `abort`, `resume` | handler call, `ud2` |
| `ret` | `ret` | the value's loads into `rax`/`rdx`, epilogue, `ret` |
| `jmp` | `jmp` | `jmp t` |
| `call` | `call` | `call fn` (`rel32`), the result's stores from `rax`/`rdx` |
| `call_ext`, `call_ind` | `call.ext`, `call.ext.ind`, `call.ind` | resolving handler call, then `call rax` + the result's stores, or the island ([Calls and islands](#calls-and-islands)) |
| `tail_call` | `tail_call` | handler call (moves the arguments), epilogue, `jmp fn` |
| `tail_call_ind` | `tail_call.ind` | resolving handler call, then epilogue and `jmp rax`, or the island and a `ret` |
| `island` | `island` | `lea rdi, [rsp + F]; lea rsi, [rip + ops]; call [rip + isl]` (with a frame pointer `mov rdi, rbp`; PE: `rcx`/`rdx` and 32 bytes of shadow space) |
| `lpad` | `lpad` | `mov rsi, rax` (the exception object; `rdi` with `fp-rbp`), operand registers, handler call |

The epilogue is `add rsp, F + 8`, or `leave` with a frame pointer ([Frames](#frames)).

- **Operand registers** (`asm::layout`, `core` only, shared by the encoder and the
  handlers): a handler takes up to six registers, `rdi, rsi, rdx, rcx, r8, r9`, in operand
  order, on every target (`sysv64`). An operand takes one register, except a memory operand
  (`p`, `k`), a `U128` (low, high) and a case list (values, count), which take two. `rdi`
  holds `fp` (`lea rdi, [rsp + F]`, or `mov rdi, rbp` with a frame pointer) and the operands
  start at `rsi`, except with `fp-rbp`, where handlers read `rbp` and the operands start at
  `rdi`; `lpad` takes the exception object before its operand. If an opcode has more operands than registers, adjacent 32-bit
  operands (slots, `U8`–`U32`) share one, `a | b << 32`, pairing from the last pair. A
  constant, symbol, site or data operand is passed as its address (`lea reg, [rip + …]`).
  Branch and call targets and polarities aren't passed; the call shapes pass only what
  their handler resolves. `layout` is a `const fn` that fails to compile for an opcode whose
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
| `addr.sym d, sym` | address of a native function, static or portal (the symbol slot's value) |
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
| `call d, fn, len` | call a VM function in this image |
| `call.ext d, sym, site, isl, f, len` | call the function at symbol `sym` (an upstream instance): the VM function directly if it is a portal of one, otherwise the `isl` island, with the address in slot `f` |
| `call.ext.ind d, sym, site, isl, f, len` | the same, with the address loaded through the symbol slot (PE `__imp_`, [platforms.md](platforms.md)) |
| `call.ind d, p, site, isl, len` | indirect call through the fn pointer in slot `p` |
| `tail_call fn, n` | `become` a VM function in this image, with an `n`-byte argument block |
| `tail_call.ind p, site, isl, n, s, len` | `become` through the fn pointer in `p`. A tail call to an upstream instance is `addr.sym` + `tail_call.ind` |
| `ret s, len` | return `_0` (`len` bytes at `s`) |
| `island isl, n, ops…` | call `isl(fp, &ops)` and continue |
| `lpad x` | landing pad: store the exception object in slot `x` |
| `resume x` | continue unwinding the exception object in slot `x` |

- **Return values**: a value of 1, 2, 4, 8 or 16 bytes comes back in `rax` (and `rdx` for
  the high half of 16 bytes), the `len` of `ret` and of the calls (`asm::ret_in_regs`). A
  value of any other size comes back at the start of the callee's argument block, its
  `fp + 16`, which is the caller's outgoing block at `rsp`: the lowering copies `_0` there
  before `ret`, and from there to the destination after the call, and makes the caller's
  outgoing block large enough. Its `ret` and call then have `len` 0, like those of an
  empty value. The arguments are dead by then, so they can be overwritten.
- **`call`**: the arguments are already in the outgoing block at `rsp`. `call fn` pushes
  the return address, and after the call come the stores of `rax`/`rdx` into `d`. With
  `len` 0 there is none, and `d` must be 0.
- **`ret`**: loads the `len` bytes at `fp + s` into `rax`/`rdx` (`movzx` for 1 and 2 bytes),
  and the epilogue and `ret` return. With `len` 0, `s` must be 0. It works the same in the
  entry frame ([Entry](#entry)).
- **`call.ext` / `call.ind`**: the handler resolves the target (below) and returns its VM
  entry in `rax`, or 0 for a native target:
  ```
  call ryo_h_CallExt            ; rax = VM entry, or 0
  test rax, rax
  jz 1f
  call rax
  nop dword [rcx + d]
  jmp 2f
  1: lea rdi, [rsp + F]         ; mov rdi, rbp with a frame pointer
     lea rsi, [rip + ops]       ; [-F, d, f] (call.ind: [-F, d, p])
     call [rip + isl]
  2:
  ```
  The native path calls the `isl` island, a `call_ptrN` instance for the signature,
  directly through its symbol slot, with `ops` = (outgoing block, destination, fn pointer
  slot) in the code constants ([stubs.md](stubs.md#templates)). For `call.ext`, the handler
  writes the resolved address into slot `f` first. On PE the island call is
  `mov rcx, rbp; lea rdx, [rip + ops]; sub rsp, 32; call [rip + isl]; add rsp, 32` (the
  Win64 convention and its shadow space).
- **The site cache**: each `call.ext`/`call.ind` site has one pointer-sized `AtomicPtr`
  slot in the image's writable site cache. It is a single word, so it can't tear, and the
  slot only ever holds a value that is correct for the site. A `*const Function` is stored
  with Release and loaded with Acquire: the record was written by another thread (under the
  runtime lock, published through its image's table), and the reader dereferences it, so
  the load must synchronize with that publication.
  - **`call.ext`**: the target is the constant `sym`, so the slot caches the resolution:
    null (unresolved), `NATIVE` (a sentinel), or a `*const Function`. On first use,
    `vm::lookup_addr(sym)` fills it.
  - **`call.ind`**: the slot caches the last target this site called: a VM
    `*const Function`, or a native address tagged as `addr << 1 | 1` (records are 8-aligned,
    and x86_64 user addresses fit in 63 bits). On a call, the handler compares the target
    pointer with the cached function's portal address (a field of the function record) or
    the tagged native address. If they match, it returns the function's entry, or 0 for the
    native path. Otherwise it calls `vm::lookup_addr` and caches the result either way.
    Concurrent stores of different functions are fine: whichever wins is a valid cache
    entry, and every hit is verified against the target.
  - **VM function**: called directly, in whichever image it is. The arguments are already in
    the argument block layout ([lowering.md](lowering.md#frame-slots)), which is the same for
    every caller.
- **`tail_call fn, n`**: the arguments are staged in the outgoing block at `rsp`.
  `ryo_h_TailCall` (assembly) moves the `n` bytes up to `fp + 16`, over the function's own
  argument block, then the epilogue and `jmp fn` keep the return address (and the caller's
  `rbp`), so the callee returns to the original caller. The two ranges never overlap. `become` requires
  matching signatures, so the block fits the caller's.
- **`tail_call.ind p, site, isl, n, s, len`**: `ryo_h_TailCallInd` (an assembly entry that
  passes the caller's `rsp` in `r9`) resolves `p` as `call.ind` does. For a VM function it
  moves the arguments as `tail_call` does and returns the entry, and the epilogue and `jmp rax`
  follows. A native target can't be a true tail call: the island runs with
  `ops = [-F, s, p]`, so the result lands in `_0`'s slot `s`, then the sequence of
  `ret s, len` returns it. A result that doesn't return in registers has `len` 0 and `s` the
  start of the function's own argument block, where its caller expects it. It uses native stack for the duration of that call.
- **`island`**: `island(fp, ops)` through the symbol slot `isl`, with the operand words in
  the code constants. The island's return value is ignored, and execution continues after
  the call. The `ops` array is exactly what the template reads
  ([stubs.md](stubs.md#islands-vm--native)), so for call templates `ops[1]` is the
  destination.

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
  function start, no type table). Every call that may unwind is a call site: the `call`,
  the `call rax` and the island call of the call shapes, an `island`, and `resume`'s
  handler call. Each has the action of its cleanup entry:
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
  cleanup" behave exactly as natively. A panic that leaves the VM through a portal just
  continues unwinding into the native caller, and a `catch_unwind` island catches like the
  intrinsic does ([stubs.md](stubs.md#unwinding)). Entry records are popped by `enter`'s
  drop guard on the way ([Entry](#entry)).
- **Backtraces**: frames of VM functions are named by the local symbol `<symbol>.vm` of
  their code, so `RUST_BACKTRACE=1` and profilers show them between the native frames
  (`y test`'s `backtrace` check, [build.md](build.md#test-and-bench)).
- **PE**: VM code keeps the frame pointer ([Frames](#frames)), and `.pdata`/`.xdata`
  describe each function's prologue (`rbp` as frame register), so
  the system unwinder can walk through VM frames, but they register no exception handler:
  landing pads don't run on PE, and `resume` aborts. Like the rest of the PE column this is
  only cross-checked ([platforms.md](platforms.md)).

## Entry

`vm::enter(id, args, ret)` is the entry from portals ([stubs.md](stubs.md#portals-native--vm)):

1. It resolves `id` (crate hash → image, then function index → record, [Image
   format](#image-format)).
2. It calls `ryo_asm_enter(entry, call)` (`global_asm!` in `vm/rt/src/vm/mod.rs`), `call`
   holding the operands and the results: it saves `rbp` and `rbx`, anchors its frame (and
   its CFI) in `rbx`, reserves the argument block at `rsp` (the larger of `arg_size` and a
   `ret_size` that doesn't return in registers, rounded up to 16, plus 8 to keep the
   callee's `fp` 16-aligned), so that it is the callee's `fp + 16`, copies the portal's
   args there, sets `rbp = 0` (so a frame-pointer chain ends there) and calls the entry.
   Afterwards it stores `rax` and `rdx`, and for a value that doesn't return in registers
   copies it from the start of the block to `ret`. `enter` copies a value in registers to
   `ret`. The Win64 version also saves `rdi`, `rsi` and `xmm6`–`xmm15`, which are
   callee-saved there but not in the `sysv64` convention VM code and the handlers follow,
   and has SEH unwind info.

The VM takes ownership of the args. A panic unwinds out of `ryo_asm_enter` and `enter`
natively, so `enter` returns nothing and the portal has no status to check.

## Handlers

Each opcode with a handler (all but `jmp`, `call`, `ret` and `island`) has one non-inlined function
in `ryo_rt`, `ryo_h_<Opcode>`:

- **Signature**: `unsafe extern "sysv64-unwind" fn(a0, …, a5: u64) -> R`, the six argument
  registers, on every target. `R` is `()`, `bool` (branches), `usize` (switches), `!`
  (traps) or `*const u8` (the resolving call handlers). Each handler body reads its
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
- **Assembly**: `tail_call` (`ryo_h_TailCall`), the argument move of `tail_call.ind` (its
  entry `ryo_h_TailCallInd`, which passes the caller's `rsp` to the Rust part), `resume`
  (`ryo_h_Resume`) and `ryo_probe_stack` are naked functions: they need the caller's `rsp`
  or end in a jump.
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
  linked in memory, through `vm::enter` and portals, in `vm::MODE` (without a frame pointer,
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
                text section), argument block size, return value size, portal symbol
                index (or none)
code constants  what the machine code refers to: island operand arrays (a count, then the
                words), sparse switch values
fixups          PE only: (writable offset, symbol index, addend)
symbol flags    one byte per symbol (bit 0: indirect, load through the slot; PE only, and
                only for the `sym` of `addr.sym.ind`/`call.ext.ind`, never for islands,
                portals or allocation pointers, [platforms.md](platforms.md). A symbol used
                both ways has two slots)
symbols         pointer-sized slots, one per referenced native symbol (functions, statics,
                islands, portals, `rust_eh_personality` on ELF), filled in by the linker
constants       constant pool: allocations, aligned
```

The read-only section can live in RELRO/`.rdata`, since nothing writes to it after
relocation.

**Writable** (`.data.ryo_image` / `.data$ryo_image`):

```
site cache    one AtomicPtr per call.ext/call.ind/tail_call.ind site
fixups        PE only: constant allocations that point at DLL-imported data
```

**Text** (`.text.ryo_image` / `.text$ryo_image`): every function's machine code, in function
table order, each aligned to 16 (padded with `int3`), with a local symbol `<fn symbol>.vm`
naming it, for backtraces and profilers. **Unwind**: `.eh_frame` and
`.gcc_except_table.ryo_image` (ELF), `.pdata` and `.xdata` (PE) ([Unwinding](#unwinding)).

- `ryo_bytecode::image` defines the exact layout (`Header`, `FuncEntry`, `FixupEntry`).
  `addr.abs` data offsets are offsets from the start of the fixups area.
- **Relocations** (`RelocKind`):
  - `Abs64` (`R_X86_64_64` / `IMAGE_REL_AMD64_ADDR64`): the header's `data` and `text`
    pointers, one per symbol slot, and the pointers inside constant and fixup allocations
    (against a symbol, or intra-image against either section).
  - `Pc32` (`R_X86_64_PC32` / `REL32`): the code's RIP-relative fields (symbol slots,
    sites, constants, the data area, code constants), and the `.eh_frame` references.
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
- The portal `ID`'s crate hash is the 32-bit fold of the `StableCrateId`
  (`ryo_bytecode::image::crate_hash`). It is stored in the header, which also keeps the full
  `StableCrateId`, so the registry can detect collisions.
- **Images are trusted**: they are produced by the backend, and the VM doesn't validate
  code. `Image::parse` checks the header and part bounds, and `Image::validate` checks the
  tables only (functions, fixups, symbol flags). For functions given as instruction words,
  `finish` checks them (`ryo_bytecode::image::validate_code`: operands in range, branch
  targets on instruction starts, no fall-through past the end, symbol indirection) and the
  cleanup entries, and `encode` checks that every cleanup entry is at an instruction that
  may unwind and lands on an `lpad`. `finish_encoded` checks the relocation targets' ranges.
- **No re-entry into the VM from the runtime**: the registry, `lookup_addr`, `vm::enter` and
  the handlers use only `core` and `ryo_rt`'s own lock (a spin lock, or a
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
  supported, because site caches and frames may still point into it.
  It does no other work, so startup is O(number of images): it only parses headers
  (`Image::parse`, O(1)), and runs `Image::validate` only for images with PE fixups, which
  `apply_fixups` requires. The per-function run-time records (`vm::Function`: entry address,
  argument and return sizes, image, portal address) are built per image on first use (the
  first `enter` into it or the first `lookup_addr`). Registry memory comes from `mmap`ed
  chunks (`VirtualAlloc` on PE), not the Rust allocator.
- **`__ryo_registry_anchor`**: `vm::enter` references it behind `ryo_rt`'s
  `registry-anchor` cargo feature, which `y build` enables when it builds the sysroot's
  `ryo_rt`. Without the backend nothing defines the symbol, so `ryo_rt`'s own tests and
  plain cargo builds leave the feature off.
- **`vm::lookup_addr`**: maps a portal address to its VM function. It uses a hash map built
  lazily on the first lookup from all registered images' portal symbols, and rebuilt
  (published the same way) when images are added. The site caches mean it's rarely called.
- **`vm::enter(id, …)`**: resolves `id` as crate hash → image (a binary search in the
  snapshot), then function index → record.

## Runtime crate: `ryo_rt`

The whole runtime is one rlib in the sysroot: the handlers, the entry, the registry, and the
portal and island templates. It is a normal Rust dependency of every ryo-built crate.

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

- **`vm`**: the handlers (`vm::h`, generated, plus the assembly ones), `enter` and the
  registry. Everything uses `core` only.
  - `vm::enter(id, args, ret)`: entry from portals ([Entry](#entry)). With `RYO_VM_TRACE`
    set in the environment (read once, with `getenv`/`GetEnvironmentVariableA`), it first
    prints `ryo-vm: enter <crate hash>:<function index>` to stderr, so tests can check that
    code ran in the VM. With `RYO_VM_STATS` set (read once), the VM counts entries and the
    native calls of `call.ext`/`call.ind`/`tail_call.ind` (relaxed atomics, only then), and
    an `atexit` handler prints `ryo-vm: <n> enters, <n> native calls`: the run-time side of
    `-Zryo-stats`. `y test` sets it with the trace and checks the enters against it.
  - `vm::lookup_addr(fnptr) -> Option<&'static vm::Function>`: portal address → VM function.
  - `vm::register`: `#[no_mangle] extern "C-unwind" fn ryo_vm_register(images, n)`.
  - `vm::MODE` / `vm::FP_ARG` (diagnostic item `ryo_rt_fp_arg`): whether the handlers take
    `fp` in `rdi` (unless the `fp-rbp` cargo feature is on). The backend evaluates `FP_ARG`
    and encodes to match, with a frame pointer if it is false.
- **`portal`**: `portal`, `portal_tc0..N` ([stubs.md](stubs.md#portals-native--vm)).
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
