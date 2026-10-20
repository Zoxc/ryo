# VM

The VM is a register machine whose registers are byte offsets into the current frame.
Bytecode is fully typed at lowering time: every instruction knows its operand widths, so there
are no type tags or checks at run time. The VM lives in `ryo_rt` (module `vm`).

## Execution state

Handlers receive the hot state as arguments, so it stays in machine registers across dispatch
([Dispatch](#dispatch)):

| Argument | Meaning |
|---|---|
| `pc` | `*const u32`, the current instruction |
| `fp` | `*mut u8`, the base of the current frame |
| `vm` | `*mut VmThread`, the thread-local state |
| `syms` | `*const *const ()`, the current image's symbol table |
| `consts` | `*const u8`, the current image's constant pool |

`syms`, `consts` and the current image's code bounds (kept in `VmThread`) form the **image
context**. It is always loaded as one unit, whenever control may pass between images: at
`call.ext`/`call.ind` into another image, at `ret` into another image, at `vm::enter`, when an
entry record is restored, and on every frame pop during unwinding.

`VmThread` is the per-thread state: stack bounds, stack top, the image context (current image
and its code bounds), and the chain of entry records. The **stack top** is the end of the
current frame (`fp + frame_size` of the innermost running function): outgoing argument blocks
and the next frame start there, so `call` and `vm::enter` read it as `new_fp`, and every call,
`ret`, tail call and frame pop updates it. Each entry record holds the payload of a panic
unwinding through it. It is `!Send` and `!Sync`, and is only reached through a raw pointer. It
is never a `&mut`, because re-entrant `vm::enter` calls (VM → island → native → portal → VM)
on the same thread would otherwise create aliasing mutable references.

## Frames and the VM stack

- **The stack**: each thread has its own VM stack, an `mmap`ed (ELF) or `VirtualAlloc`ed (PE)
  region with a guard page, created on the first `vm::enter` (behind a `cold_path`). It is
  8 MiB (`MAP_NORESERVE`, so untouched pages cost nothing; on PE it is committed, which
  only counts against the commit limit). A pthread key (ELF) or FLS
  (PE) destructor unmaps it when the thread exits, unless the thread exits from inside VM
  code (then it is leaked). A `vm::enter` from a thread-exit destructor that runs after
  ours maps a new stack and registers the destructor again; whether that one is freed
  depends on the platform repeating destructor rounds (glibc does, up to
  `PTHREAD_DESTRUCTOR_ITERATIONS`), otherwise it is leaked. On PE, FLS is per fiber while
  the VM stack is per thread, so running VM code on fibers that are deleted before their
  thread exits is not supported. Frames
  are bump-allocated. That is cheaper than `alloca` (no stack probing, frame size known), and
  leaves the native stack to native code.
- **Frame layout**, with `fp` pointing at the start (H = 16):
  ```
  fp + 0     caller fp       (null for the first frame of a vm::enter)
  fp + 8     return pc       (points at the caller's call instruction)
  fp + 16    argument block  (arg_block layout of the signature, lowering.md)
  …          other locals, including _0
  fp + frame_size
  ```
- **Alignment**: `fp` is always 16-aligned (page-aligned stack base, H = 16, `frame_size` a
  multiple of 16), and slots are aligned to their types relative to `fp`. Types with
  alignment above 16 never live in VM frames ([lowering.md](lowering.md#frame-slots)).
- Two words are written per call. The current function isn't stored: on the cold paths that
  need it (unwinding, backtraces), it is found from the pc through the image's function
  table, which is sorted by code offset. The destination slot isn't stored either: `ret`
  reads it from the caller's call instruction at `return pc`, since all call instructions
  have their destination operand in the same word ([Encoding](#encoding)).
- **Outgoing calls**: a callee's frame starts at the caller's `fp + frame_size`. The caller
  writes the arguments there before the call ([lowering.md](lowering.md#calls)).
- **Stack check**: each call compares `new_fp + callee.frame_size + callee.max_outgoing`
  against the stack limit, where `new_fp = fp + frame_size`, so the header is included.
  `max_outgoing` (in the function table) is the number of bytes above its `frame_size` that
  a function may write: H plus its largest outgoing argument block, or 0 if it makes no
  calls. So a function's own outgoing blocks never need a separate check. For `call fn`, the
  callee's `frame_size` is an immediate in the instruction and `max_outgoing` comes from the
  function table. For `call.ext`/`call.ind`, both are read from the resolved function record. On overflow, the VM reports "stack overflow" and aborts, like
  native Rust. Native stack use by islands and portals is protected by the native guard page
  as usual.
- **Re-entrancy**: `vm::enter` allocates its frame at the thread's current stack top, so it
  works while the thread is already running bytecode further down the stack. It copies
  `arg_size` bytes (from the function table) of the portal's args into the new frame. It
  pushes an *entry record* (the previous stack top and image context, the portal's `ret`
  pointer, and the payload slot) onto `VmThread`'s chain, and pops it on return, also if a
  panic unwinds natively through `enter` (a drop guard). The suspended outer dispatch keeps
  its own `pc`, `fp`, `syms` and `consts` in its native frame.

## Encoding

- Instructions are sequences of 32-bit words. The first word holds the opcode (low 16 bits)
  and a small immediate field (high 16 bits). Each opcode has a **fixed length**, so
  instructions can be decoded and rewritten in place, and the next instruction is always at
  a known offset.
- Code positions are **offsets** from the function's code start. Cleanup tables and the
  function table are keyed by offset, not absolute pc, so the code can be copied elsewhere
  (for quickening/direct threading, or a JIT) and still map back.
- For call instructions, word 1 is always the destination slot (`ret` reads it).
- The small immediate field is reserved (must be 0) until quickening uses it.
  Superinstructions are opcodes of their own ([Superinstructions](#superinstructions)).
- The opcode list, with every operand's encoding, is defined once in `ryo_bytecode`
  (`vm/bytecode/src/ops.rs`). The opcode enum, the decoder, the encoder and the
  disassembler are all generated from it. Opcode values follow list order, and every change
  bumps `ryo_bytecode::FORMAT_VERSION`, as does every change to an image table layout
  (`Header`, `FuncEntry`, `CleanupEntry`, `FixupEntry`). Tests pin a hash of the opcode
  table and the table entry sizes and field offsets to the version.
- Variable-length operands (`switch` tables and cases, island operands and targets) are
  encoded as a count word followed by the elements.
- Immediates have the instruction's width: one word for `w8`–`w32` (upper bits ignored), two
  for `w64`, four for `w128`, low word first. The `switch.sparse` case values and the
  `discr.niche` niche start follow the same rule.

| Operand | Encoding | Meaning |
|---|---|---|
| `s`, `d` | u32 | frame offset: the value at `fp + off` (source / destination) |
| `[p + k]` | u32, u32 | memory: load the pointer at `fp + p`, add the signed constant `k` |
| `[p]` | u32 | memory with `k = 0` (separate opcodes) |
| `imm32` / `imm64` | 1 / 2 words | immediate |
| `k` | u32 | constant pool offset |
| `sym` | u32 | symbol table index |
| `site` | u32 | index into the image's writable site cache ([Image format](#image-format)) |
| `fn` | u32 | function table index (VM function in the same image) |
| `t` | i32 | branch target, relative to the instruction start, in words |
| `data` | u32 | byte offset into the image's writable data area (`fixups`) |

Integer ops carry their width (`w8` … `w128`) in the opcode, and float ops their format
(`f32`, `f64`).

## Instruction set

### Data movement

| Instruction | Semantics |
|---|---|
| `mov.wN d, s` | copy N bits |
| `copy d, s, len` | copy `len` bytes between frame slots (never overlapping) |
| `imm.wN d, imm` | store an immediate |
| `const d, k, len` | copy `len` bytes from the constant pool |
| `zero d, len` | zero `len` bytes |
| `load.wN d, [p + k]`, `load.wN d, [p]` | load from memory |
| `store.wN [p + k], s`, `store.wN [p], s` | store to memory |
| `load.copy d, [p + k], len` / `store.copy [p + k], s, len` | aggregate load/store (`memmove` semantics) |
| `memcpy dp, sp, n` / `memmove dp, sp, n` / `memset dp, b, n` | with runtime pointers and lengths in slots |
| `fill d, k, elem_size, count` | repeat a constant element |

### Addresses

| Instruction | Semantics |
|---|---|
| `addr d, s` | `d = fp + s` (slot address) |
| `addr.sym d, sym` | address of a native function, static or portal |
| `addr.sym.ind d, sym` | load the address through the slot (PE `__imp_` data, [platforms.md](platforms.md)) |
| `addr.k d, k` | address of a constant pool allocation |
| `addr.data d, data` | address of an allocation in the writable `fixups` area (PE) |
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
  `d` and the success flag at `o`.
- **Width and alignment**: widths 8–64 run in the VM. 128-bit atomics are islands (they need
  `cmpxchg16b`, which core provides when the target supports it). Atomic operands are always
  memory operands, aligned as the type requires.

### Control flow

| Instruction | Semantics |
|---|---|
| `jmp t` | |
| `br.if s, t` / `br.unless s, t` | branch on a `bool` slot |
| `br.cmp.{eq,ne,lt.s,lt.u,le.s,le.u}.wN a, b, t`, and `.imm` variants | fused compare + branch |
| `switch.dense.wN s, base, t_default, n, t_0 … t_{n-1}` | jump table on `s - base` |
| `switch.sparse.wN s, t_default, n, (v_i, t_i)…` | sorted values: a linear scan for `n ≤ 4`, binary search above |
| `unreachable` | report and abort (only reachable through UB) |
| `abort` | `core::intrinsics::abort` |

`switch.*`, `island` and `island.catch` are the only variable-length instructions. Their
length is given by their count words.

### Calls and islands

| Instruction | Semantics |
|---|---|
| `call d, fn, frame_size` | call a VM function in this image |
| `call.ext d, sym, site, island` | call the function at symbol `sym` (an upstream instance): bytecode if it is a portal of a VM function, otherwise through `island` |
| `call.ext.ind d, sym, site, island` | the same, with the address loaded through the symbol slot (PE `__imp_`, [platforms.md](platforms.md)) |
| `call.ind d, p, site, island` | indirect call through the fn pointer in slot `p` |
| `tail_call fn, frame_size` / `tail_call.ind p, site, island` | `become`. A tail call to an upstream instance is `addr.sym` + `tail_call.ind` |
| `ret s, len` | return `_0` (`len` bytes at `s`) |
| `island sym, n_ops, ops…, n_targets, t…` | call `island(fp, &ops)`, jump to `t[ret]` |
| `island.catch sym, n_ops, ops…, n_targets, t…` | the same through `call_catching`, then unwind if the island panicked |
| `resume` | continue unwinding |

`island`'s operands are encoded as `sym, n_ops, ops…, n_targets, t…`, and the island
receives a pointer to `ops[0]`. The `ops` array is exactly what the template reads
([stubs.md](stubs.md#islands-vm--native)), so for call templates `ops[1]` is the destination.
Islands have no `d` word: "destination in word 1" applies only to the call instructions that
`ret` returns to (`call`, `call.ext`, `call.ext.ind`, `call.ind`).

- **`call`**:
  - Sets `new_fp = fp + frame_size(caller)` (the stack top), checks the stack with the
    immediate `frame_size` (the callee's) and the callee's `max_outgoing`, and writes
    `[new_fp] = fp`, `[new_fp + 8] = pc`.
  - Jumps to the callee's entry. The arguments are already in place.
- **`ret`**:
  - Reads the caller's call instruction at `return pc`, and takes the destination slot `d`
    from word 1.
  - Copies `len` bytes from `fp + s` to `caller_fp + d`.
  - Restores `fp`, and continues after the call instruction (fixed length, so the address is
    known). If the caller fp is null, it returns from `vm::enter` instead.
  - **Returning into another image**: `ret` checks the return pc against the current
    image's code range (two compares, with the bounds kept in `VmThread`). If it is outside,
    the VM finds the caller's image through the registry snapshot's sorted code-range map
    (cold path), and reloads `syms`/`consts` and the bounds. Unwinding uses the same map to
    get from a frame's return pc to its image, function and code offset.
- **`call.ext` / `call.ind` and the site cache**: each site has one pointer-sized
  `AtomicPtr` slot in the image's writable site cache. It is a single word, so it can't
  tear, and the slot only ever holds a value that is correct for the site. A
  `*const Function` is stored with Release and loaded with Acquire: the record was written
  by another thread (under the runtime lock, published through its image's table), and the
  reader dereferences it, so the load must synchronize with that publication.
  - **`call.ext`**: the target is the constant `sym`, so the slot caches the resolution:
    null (unresolved), `NATIVE` (a sentinel), or a `*const Function`. On first use,
    `vm::lookup_addr(sym)` fills it.
  - **`call.ind`**: the slot caches the last target this site called: a VM
    `*const Function`, or a native address tagged as `addr << 1 | 1` (records are 8-aligned,
    and x86_64 user addresses fit in 63 bits). On a call, the VM compares the target pointer
    with the cached function's portal address (a field of the function record) or the tagged
    native address. If they match, it calls the function directly, or goes straight to the
    native path. Otherwise it calls `vm::lookup_addr` and caches the result either way. Concurrent stores of
    different functions are fine: whichever wins is a valid cache entry, and every hit is
    verified against the target.
  - **VM function**: called directly. The arguments are already in the argument block layout
    ([lowering.md](lowering.md#frame-slots)), which is the same for every caller.
  - **Native target**: the instruction calls its `island` operand, a `call_ptrN` instance
    for the signature. The VM writes the fn pointer at `fp + frame_size + 0` (the callee
    frame's header area, unused by a native call), builds
    `ops = [frame_size + H, d, frame_size]` (argument block, destination, fn pointer slot) in
    a local array on the native stack, and calls the island with it
    ([stubs.md](stubs.md#templates)).
    The island always goes through `call_catching` unless the site's unwind action is
    `Unreachable` (or the crate is `panic=abort`). This is independent of whether the site
    has a cleanup entry: with `Continue`, the caught panic simply unwinds the VM frame.
  - **Crossing images**: when the callee is in another image, the VM loads the callee's
    image context.
- **`tail_call`**:
  - The arguments are staged in the outgoing block (above the current frame), then
    `memmove`d down to `fp + H`. The header (caller fp, return pc) is kept, so the callee
    returns to the original caller.
  - The stack check is redone with the callee's `frame_size`. The number of bytes moved is
    the callee's `arg_size` (function table).
  - `tail_call.ind` to a native target can't be a true tail call. It runs the island with
    `ops = [frame_size + H, H, frame_size]`, so the result lands at `fp + H` (the frame is
    dead, and it is at least `H + size_of(R)` bytes, since `_0` lives in it), then returns
    it as `ret` would, with the function's `ret_size` (function table) as the length. It
    uses native stack for the duration of that call.
  - The native path of `call.ext`/`call.ind`/`tail_call.ind` always goes through
    `call_catching`: the instructions don't encode whether the site's unwind action is
    `Unreachable`, so the `Unreachable` shortcut above is not taken yet.

### Unwinding

- **Where panics start**: only in native code (an island, or the panic machinery an island
  calls). They are caught by `call_catching`, in `island.catch` and on the native path of
  `call.ext`/`call.ind`. Every native call that may unwind is caught, whatever its unwind
  action, apart from `Unreachable`. So no panic ever unwinds natively through the dispatch
  handlers, which would skip entry-record pops. The VM never unwinds
  natively, and VM `call`s don't unwind by themselves.
- **When `call_catching` reports a panic**: the payload is stored in the innermost entry
  record (one slot per `vm::enter`; the VM passes a pointer to that slot as
  `call_catching`'s `payload_out`), so nested entries each keep their own payload. Then the
  VM looks up the current code offset in the function's cleanup table:
  - **Cleanup entry**: jump to the cleanup block. It ends in `resume`, which continues
    unwinding, or it reaches a normal exit as MIR allows.
  - **Terminate entry** (`TERMINATE` target): abort without a message. The format keeps it,
    but the lowering never emits one: a `Terminate` action is a normal cleanup entry whose
    target is a stub calling the terminate lang item ([lowering.md](lowering.md#unwinding)).
  - **No entry**: pop the frame, and repeat the lookup in the caller at its call
    instruction's offset (the return pc).
- **Reaching the entry frame**: when unwinding gets to the frame of the current
  `vm::enter`, `enter` moves the payload out of the entry record into the portal's
  out-parameter, pops the record, and returns 1. The portal then calls
  `resume_unwind_from_vm(payload)`, which re-raises it natively. If an outer VM frame catches
  it, that happens through its own `island.catch`.
- A panic during cleanup: calls in cleanup blocks have `Terminate` actions, so this aborts.
- **The panic stays in flight**: `call_catching` catches with the bare `catch_unwind`
  intrinsic and the panic runtime's `__rust_panic_cleanup`, and `resume_unwind_from_vm`
  re-raises with `__rust_start_panic`. These are the halves of std's
  `catch_unwind`/`resume_unwind` that leave std's panic count alone, so while the VM runs
  cleanup blocks the panic is still counted (`std::thread::panicking()`, `Mutex` poisoning,
  "panic in a destructor during cleanup"), exactly as during native unwinding, and only the
  native catch that finally ends the panic uncounts it.
- **Foreign exceptions** (a C++ exception or another Rust runtime's panic unwinding into an
  island): `__rust_panic_cleanup` aborts on them, as std's `catch_unwind` does, so
  `island.catch` and the native paths of `call.ext`/`call.ind` abort the process.

## Image format

Each crate's image is one object file with a read-only section, a writable section and
relocations. It defines the symbol `__ryo_image_<StableCrateId>`, which points at the header.

**Read-only:**

```
header        magic, format version, crate hash, StableCrateId, pointer to the writable
              section (relocated), sizes, offset/count of every part below, site count,
              fixup area offset
functions     per function, sorted by code offset: code offset, code length,
              frame_size, max_outgoing, argument block size, return value size,
              cleanup table offset and length, portal symbol index (or none)
code          the instruction words of all functions
cleanup       per function: sorted (code offset, target block offset | terminate)
fixups        PE only: (writable offset, symbol index, addend)
symbol flags  one byte per symbol (bit 0: indirect, load through the slot; PE only, and
              only for the `sym` of `addr.sym.ind`/`call.ext.ind`, never for islands,
              portals or allocation pointers, [platforms.md](platforms.md). A symbol used
              both ways has two slots)
symbols       pointer-sized slots, one per referenced native symbol (functions, statics,
              islands, portals), filled in by the linker
              (`R_X86_64_64` / `IMAGE_REL_AMD64_ADDR64`)
constants     constant pool: allocations, aligned
```

The read-only sections can live in RELRO/`.rdata`, since nothing writes to them after
relocation.

**Writable** (`.data`/`.bss`):

```
site cache    one AtomicPtr per call.ext/call.ind site
fixups        PE only: constant allocations that point at DLL-imported data
```

- `ryo_bytecode::image` defines the exact layout (`Header`, `FuncEntry`, `CleanupEntry`,
  `FixupEntry`). Code positions in the function and cleanup tables are word offsets, and
  cleanup offsets and targets are relative to the function start. `data` operands and
  `addr.data` are offsets from the start of the fixups area.
- The writer (`ImageWriter`) returns the two sections plus a relocation list: the header's
  pointer to the writable section, one per symbol slot, and the pointers inside constant and
  fixup allocations (against a symbol, or intra-image against either section). The backend
  turns it into an object file. The reader (`Image`) is a zero-copy view over a linked image
  and needs only `core`.
- A PE fixup writes `*slot + addend` at its offset, where `slot` is the indirect symbol's
  slot (the address of `__imp_<sym>`).
- The portal `ID`'s crate hash is the 32-bit fold of the `StableCrateId`
  (`ryo_bytecode::image::crate_hash`). It is stored in the header, which also keeps the full
  `StableCrateId`, so the registry can detect collisions.
- **Images are trusted**: they are produced by the backend, and the VM doesn't validate
  code. `Image::parse` checks the header and part bounds, and `Image::validate` checks the
  tables only (functions, cleanup, fixups, symbol flags). The writer checks the code
  (`ryo_bytecode::image::validate_code`).
- Instructions refer to native symbols only by symbol-table index, so code contains no
  absolute addresses and needs no relocations.
- **No re-entry into the VM from the runtime**: the registry, `lookup_addr`, `vm::enter`,
  stack setup and `call_catching` use only `core` and `ryo_rt`'s own lock (a spin lock, or a
  futex/`WaitOnAddress` lock). With `--sysroot ryo`, std's `Mutex`, allocator or TLS code may
  be VM functions, and calling them from inside the runtime would enter the VM before it
  exists. `ryo_rt` being `#![no_std]` enforces this at compile time, and `y test`
  (`rt-core-only`) checks its rlibs' undefined symbols. The panic payload box is the exception: it is only touched through
  the panic runtime's `__rust_panic_cleanup`/`__rust_start_panic`, outside the VM's own state
  transitions. In particular, `resume_unwind_from_vm` (which ends in `__rust_start_panic`) runs
  only after `vm::enter` has popped its entry record. The panic runtime itself is never VM
  code ([backend.md](backend.md#pipeline)): if `__rust_start_panic` were, the exception it
  raises would be caught by its own island, and its portal would re-raise it through
  `__rust_start_panic` again, forever.
- **Registry**: `ryo_vm_register(images, n)` is called by the registry object's constructor,
  and also when a shared object loads at run time (`dlopen`/`LoadLibrary`). It appends the
  images to a global list under `ryo_rt`'s lock, applies the PE fixups, and publishes the list:
  readers load an atomic pointer to an immutable snapshot, and old snapshots are never freed.
  The snapshot holds the crate hash → image map and the sorted code-range → image map.
  Images are never unregistered: unloading a shared object that contains ryo code
  (`dlclose`/`FreeLibrary`) is not supported, because site caches, snapshots and frames
  may still point into it.
  It does no other work, so startup is O(number of images): it only parses headers
  (`Image::parse`, O(1)), and runs `Image::validate` only for images with PE fixups, which
  `apply_fixups` requires. The per-function run-time records (`vm::Function`: absolute code
  pointer, frame sizes, image, portal address) are built per image on first use (the first
  `enter` into it or the first `lookup_addr`). Registry memory comes from `mmap`ed chunks
  (`VirtualAlloc` on PE), not the Rust allocator.
- **`__ryo_registry_anchor`**: `vm::enter` references it behind `ryo_rt`'s
  `registry-anchor` cargo feature, which `y build` enables when it builds the sysroot's
  `ryo_rt`. Without the backend nothing defines the symbol, so `ryo_rt`'s own tests and
  plain cargo builds leave the feature off.
- **`vm::lookup_addr`**: maps a portal address to its VM function. It uses a hash map built
  lazily on the first lookup from all registered images' portal symbols, and rebuilt
  (published the same way) when images are added. The site caches mean it's rarely called.
- **`vm::enter(id, …)`**: resolves `id` as crate hash → image (a small map in the snapshot),
  then function index → record.

## Dispatch

The hot loop is written in Rust, using nightly features available through `RUSTC_BOOTSTRAP`.
All three are in the pinned 1.99.1 (`rustc_feature/src/unstable.rs`):

| Need | C technique | Rust |
|---|---|---|
| Tail-call threaded dispatch | `musttail` (clang) | `#![feature(explicit_tail_calls)]` (`unstable.rs:539`): `become handler(…)` |
| No callee-saved spills, more argument registers | `__attribute__((preserve_none))` | `#![feature(rust_preserve_none_cc)]`: `extern "rust-preserve-none"` (`unstable.rs:724`), lowered to LLVM `preserve_none` on x86_64 and aarch64, and to the C convention elsewhere (`rustc_codegen_llvm/src/abi.rs:724`) |
| Direct-threaded dispatch | `goto *labels[op]` | `#![feature(loop_match)]` (`unstable.rs:619`; `#[loop_match]` + `#[const_continue]`) |
| Frame allocation | `alloca` | not needed: a separate VM stack |
| Branch hints | `__builtin_expect` | `core::hint::{likely, unlikely, cold_path}`, `#[cold]` |
| Unchecked access | — | `get_unchecked`, `read_unaligned`, `unreachable_unchecked` |

- **Tail-call handlers** are the main strategy, and the default:
  - **Shape**: one small `extern "rust-preserve-none"` function per opcode, with the
    signature `(pc, fp, vm, syms, consts)`. Each ends with
    `become HANDLERS[op(next_pc)](next_pc, fp, vm, syms, consts)`. An opcode outside the
    table selects an `invalid_handler` (which aborts) instead of calling the abort directly:
    a call, even a cold one, made LLVM set up a stack frame in handlers it couldn't
    shrink-wrap.
  - **Why `preserve_none`**: with the plain Rust ABI, `become` still uses the C register
    convention. That means only 4 integer argument registers on Win64, and callee-saved
    register spills in every handler prologue. `preserve_none` is available on every target
    (it is the C convention where LLVM has no `preserve_none`, which `become` also
    supports), so there is no Rust-ABI fallback.
  - **`rbp`**: on x86_64, `preserve_none` still preserves `rsp` and `rbp`. A handler that
    keeps a value in `rbp`, across a native call or under register pressure, saves it.
  - **Unwinding**: `extern "rust-preserve-none"` functions unwind like Rust ones
    (`fn_can_unwind`), so a forced unwind passes through handler frames as it does through
    the other strategies' `run`.
  - **Test**: `vm/rt/tests/codegen.rs` builds `ryo_rt` as `y build` does (release,
    `-Ccodegen-units=1`) with `--emit=llvm-ir,asm` and checks that every handler is
    `preserve_nonecc`, that every call between handlers is a `musttail call` (the only other
    call into the chain is `run`'s), and that dispatch is an indirect `jmp`. No handler saves
    `rbx` or `r12`–`r15`; a handler sets up a frame only if it makes a native call (`memcpy`,
    an island, a compiler-rt float conversion) or saves `rbp`; the hot handlers (`add`,
    `load`, `store`, `mov`, `br.cmp`, `jmp`, superinstructions) have no prologue at all.
- **`loop_match`** in one function is an alternative strategy, built from the same handler
  bodies: the state is the next opcode. The next opcode is read from the code, so every arm
  ends in a plain `break` with a non-constant value, and `#[const_continue]` is never used;
  it only changes how rustc lowers the loop.
- **A plain `loop { match op { … } }`** works on any compiler, and is the reference for
  correctness tests.

The handler list is `vm/rt/src/vm/handlers.rs`: every opcode with a handler *kind* and its
parameters (`AddW32 => bin(u32, wrapping_add);`). Each kind is a macro producing the handler
body, which reads its operands at the generated offsets (`ryo_bytecode::insn::off`), and either
falls through to the next dispatch or returns `run`'s result. The `dispatch!` macro expands
the list into each strategy, so instruction semantics, re-entrancy, entry records,
`call_catching` and image-context reloads are the same code in all three:

- **plain** and **`loop_match`** make each arm a local function that is `inline(always)` in
  optimized builds and `inline(never)` in unoptimized ones (unoptimized builds don't share
  stack slots between the arms, which made the dispatch frame hundreds of KiB). The plain
  `match` is exhaustive, so an opcode added to `ops.rs` without a handler fails to compile.
- **tail** makes each entry a handler function and builds the `HANDLERS` table in a `const`
  block that fails to compile if an opcode has no handler.

The strategy is a `ryo_rt` cargo feature: none for tail calls, `dispatch-loop-match` or
`dispatch-match` for the others (`vm/rt/build.rs` turns them into a cfg; `match` wins if both
are on). `ryo_rt::vm::STRATEGY` names the one built. `explicit_tail_calls` and `loop_match`
are `incomplete` features, so all three stay tested: `y test` runs `vm/`'s tests once per
strategy, as does `vm/test-dispatch.sh` (which needs no `dist/`), and `y bench` compares them
([build.md](build.md#test-and-bench)).

### Superinstructions

A superinstruction runs two adjacent instructions with one dispatch. It is an opcode of its
own (listed after the others in `ops.rs`, with its parts in
`ryo_bytecode::insn::SUPERINSTRUCTIONS`), named `first+second`:

- **Encoding**: it replaces the opcode word of a `first` that is directly followed by a
  `second`, and has exactly `first`'s operands. `second` stays in place, unchanged. So the
  code layout, branch targets (to either part), cleanup offsets and return pcs are
  unaffected, and forming one only rewrites a word.
- **Execution**: `first`'s body, then `second`'s body at the next instruction, read with
  `second`'s operand layout. The handler entry names both kinds
  (`AddImmW64BrCmpLtUW64 => fused(AddImmW64: bin_imm(…), BrCmpLtUW64: br_cmp(…))`), and a
  `const` assertion ties it to the table. `second` is executed by its plain semantics, so it
  may itself have been replaced by a superinstruction (pairs may overlap).
- **Rules** (checked by `ryo_bytecode`'s tests): `first` is fixed-length and always falls
  through (no branches, calls, returns, islands), so it is never a call whose opcode `ret`
  reads back; both parts are plain opcodes.
- **Forming them**: `ryo_bytecode::peephole::fuse` (`alloc`), over a function's finished
  `CodeBuf` ([lowering.md](lowering.md#bytecode-optimization)).
- The current set is a first guess, pending `y bench` profiles of lowered code: the loop
  latches `add.imm.w64` + `br.cmp.lt.u.w64` and `add.imm.w32` + `br.cmp.lt.s.w32`, and
  `load.w64` + `br.cmp.le.u.w64`. Adding one: an `ops.rs` entry (bump `FORMAT_VERSION`), a
  `SUPERINSTRUCTIONS` row and a `fused(…)` handler entry.

## Runtime crate: `ryo_rt`

The whole runtime is one rlib in the sysroot: the VM, the registry, the portal and island
templates, and the panic glue. It is a normal Rust dependency of every ryo-built crate.

- **Generic templates** get instantiated per program, with that program's types, from MIR in
  `ryo_rt`'s metadata.
- **Linking** follows Rust's normal rules: a Rust dylib contains one copy of `ryo_rt`, and the
  exe linking it uses that copy (`dependency_format`). Each cdylib or staticlib gets its own
  copy, with the usual Rust symbol hygiene.
- **std**: `ryo_rt` is `#![no_std]`: it uses only `core` (its tests use std). With
  `--sysroot ryo`, alloc and std are ryo-built and depend on `ryo_rt`
  ([build.md](build.md#build)), so it can't depend on them, and it must not call into them
  anyway (see "No re-entry" below). The VM uses the program's panic runtime
  (`__rust_panic_cleanup`, `__rust_start_panic`, [Unwinding](#unwinding)), which owns the
  panic payload boxes. `y build` builds `ryo_rt` against each sysroot's `core`.
- **Speed**:
  - The interpreter is non-generic and compiled once by `y build` at
    `-O3 -Ccodegen-units=1` (`-Cembed-bitcode=yes` for users' LTO), so it's fast even in
    user debug builds.
  - Generic code, by contrast, is compiled at the user's opt-level, and at `-O0`
    `#[optimize(speed)]` has no effect (`rustc_codegen_ssa/src/base.rs:1205`).
  - So templates stay thin, and the interpreter is never generic or `#[inline]`.

### Modules

- **`vm`**: the interpreter, dispatch, frames and `VmThread` (`#[thread_local]`). The hot path
  uses `core` only.
  - `vm::enter(id, args, ret, payload_out) -> u32`: entry from portals. It returns 0 for ok,
    and 1 for unwinding, with the payload (`RawPayload`, an opaque raw `Box` pointer) moved to
    `payload_out` before the entry record is popped. With `RYO_VM_TRACE` set in the
    environment (read once, with `getenv`/`GetEnvironmentVariableA`), it first prints
    `ryo-vm: enter <crate hash>:<function index>` to stderr, so tests can check that code ran
    in the VM. With `RYO_VM_STATS` set (read once), the VM counts entries, islands run and
    native calls of `call.ext`/`call.ind` (relaxed atomics, only then), and an `atexit`
    handler prints `ryo-vm: <n> enters, <n> islands, <n> native calls`: the run-time side
    of `-Zryo-stats`. `y test` sets it with the trace and checks the enters against it.
  - `vm::lookup_addr(fnptr) -> Option<&'static vm::Function>`: portal address → VM function.
  - `vm::register`: `#[no_mangle] extern "C" fn ryo_vm_register(images, n)`.
- **`portal`**: `portal`, `portal_tc0..N` ([stubs.md](stubs.md#portals-native--vm)).
- **`island`**: the island templates ([stubs.md](stubs.md#templates)).
- **`unwind`**:
  - `call_catching(f, fp, ops, payload_out) -> CatchResult`: runs an island inside the
    `catch_unwind` intrinsic. On a panic it writes the payload (`Box<dyn Any + Send>`, kept opaque as
    its raw wide pointer in `RawPayload`) to `payload_out`, which the VM points at the current entry
    record's payload slot ([stubs.md](stubs.md#unwinding)).
  - `unsafe fn resume_unwind_from_vm(payload) -> !`: hands the payload box back to the panic
    runtime (`__rust_start_panic`), without counting the panic again.

### Rules

- `ryo_rt` is always compiled by cg_llvm, and the backend treats every `ryo_rt` instance as
  native, including stub instances and their neighbors.
- It depends on `core`/`std` and `ryo_bytecode` only, with no third-party crates.
  `ryo_bytecode` is `#![no_std]`. Its reader needs only `core`, and the encoder and image
  writer sit behind its `alloc` feature, which `ryo_rt` doesn't enable. `y build` installs
  `libryo_bytecode.rlib` next to `libryo_rt.rlib`.
- It carries a `RYO_RT_ABI` const (diagnostic item `ryo_rt_abi`), which the backend
  evaluates and checks, erroring on a mismatch.
- **Panic strategy**: `ryo_rt` is built with `panic=unwind`, like std. It is valid in
  `panic=abort` programs (`verify_ok` in `rustc_metadata/src/dependency_format.rs:404-500`) as
  long as it makes no `C-unwind` calls (`ffi_unwind_calls.rs:132`). In an abort program,
  `catch_unwind` simply never catches. `-Zpanic-in-drop` must match.
