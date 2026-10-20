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

`VmThread` is the per-thread state: stack bounds, stack top, and the chain of entry records.
Each entry record holds the payload of a panic unwinding through it. It is `!Send` and `!Sync`, and is only reached through a raw pointer. It
is never a `&mut`, because re-entrant `vm::enter` calls (VM → island → native → portal → VM)
on the same thread would otherwise create aliasing mutable references.

## Frames and the VM stack

- **The stack**: each thread has its own VM stack, an `mmap`ed (ELF) or `VirtualAlloc`ed (PE)
  region with a guard page, created on the first `vm::enter` (behind a `cold_path`). Frames
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
- Two words are written per call. The current function isn't stored: on the cold paths that
  need it (unwinding, backtraces), it is found from the pc through the image's function
  table, which is sorted by code offset. The destination slot isn't stored either: `ret`
  reads it from the caller's call instruction at `return pc`, since all call instructions
  have their destination operand in the same word ([Encoding](#encoding)).
- **Outgoing calls**: a callee's frame starts at the caller's `fp + frame_size`. The caller
  writes the arguments there before the call ([lowering.md](lowering.md#calls)).
- **Stack check**: each call compares `new_fp + callee.frame_size` against the stack limit,
  where `new_fp = fp + frame_size`, so the header is included. For `call fn`, the callee's
  `frame_size` is an immediate in the instruction. For `call.ext`/`call.ind`, it is read from
  the resolved function record. On overflow, the VM reports "stack overflow" and aborts, like
  native Rust. Native stack use by islands and portals is protected by the native guard page
  as usual.
- **Re-entrancy**: `vm::enter` allocates its frame at the thread's current stack top, so it
  works while the thread is already running bytecode further down the stack. It pushes an
  *entry record* (the previous stack top, plus the suspended outer dispatch's `pc`, `fp` and
  image context, if any) onto `VmThread`'s chain, and pops it on return.

## Encoding

- Instructions are sequences of 32-bit words. The first word holds the opcode (low 16 bits)
  and a small immediate field (high 16 bits). Each opcode has a **fixed length**, so
  instructions can be decoded and rewritten in place, and the next instruction is always at
  a known offset.
- Code positions are **offsets** from the function's code start. Cleanup tables and the
  function table are keyed by offset, not absolute pc, so the code can be copied elsewhere
  (for quickening/direct threading, or a JIT) and still map back.
- For call instructions, word 1 is always the destination slot (`ret` reads it).

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
| `ptr.add d, p, imm` | `d = p + imm` (wrapping) |
| `ptr.index d, p, i, stride` | `d = p + i * stride` |

### Integer arithmetic

At widths 8/16/32/64/128, wrapping:

| Instruction | Semantics |
|---|---|
| `add sub mul .wN d, a, b` | |
| `div.s div.u rem.s rem.u .wN d, a, b` | no checks (MIR guarantees valid operands) |
| `and or xor .wN d, a, b` | |
| `shl shr.s shr.u .wN d, a, b` | amount masked to the width |
| `neg not .wN d, a` | |
| `add.ovf sub.ovf mul.ovf .{s,u}.wN d, a, b` | result at `d`, overflow flag (u8) at the pair's second field |
| `eq ne lt.s lt.u le.s le.u .wN d, a, b` | writes a `bool` |
| `cmp3.s cmp3.u .wN d, a, b` | three-way compare (`Ordering` as `i8`) |
| `rotl rotr ctpop ctlz cttz bswap bitreverse .wN` | intrinsics |

There are `.imm` variants (`add.imm.w64 d, a, imm`, `eq.imm`, …) for the common cases. At
128 bits, `mul`, `div` and `rem` are islands.

### Floating point

| Instruction | Semantics |
|---|---|
| `fadd fsub fmul fdiv frem .fN d, a, b` | IEEE, with Rust semantics |
| `fneg fabs .fN d, a` | |
| `feq fne flt fle .fN d, a, b` | |
| `fmin fmax copysign .fN d, a, b` | |

libm functions (`sqrt`, `sin`, `powi`, …) are islands.

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

Direct-tagged enums use plain loads, stores and integer ops.

### Atomics

- **Operations**: `atomic.load/store.wN.ord`,
  `atomic.xchg/add/sub/and/or/xor/nand/min/max/umin/umax.wN.ord`,
  `atomic.cxchg[.weak].wN.ord_s.ord_f`, `fence.ord`, `compiler_fence.ord`. Each handler
  performs the matching `core::sync::atomic` operation.
- **Width and alignment**: widths 8–64 run in the VM. 128-bit atomics are islands (they need
  `cmpxchg16b`, which core provides when the target supports it). Atomic operands are always
  memory operands, aligned as the type requires.

### Control flow

| Instruction | Semantics |
|---|---|
| `jmp t` | |
| `br.if s, t` / `br.unless s, t` | branch on a `bool` slot |
| `br.cmp.{eq,ne,lt.s,lt.u,le.s,le.u}.wN a, b, t`, and `.imm` variants | fused compare + branch |
| `switch.dense.wN s, base, n, t_default, t_0 … t_{n-1}` | jump table on `s - base` |
| `switch.sparse.wN s, n, t_default, (v_i, t_i)…` | sorted values: a linear scan for `n ≤ 4`, binary search above |
| `unreachable` | report and abort (only reachable through UB) |
| `abort` | `core::intrinsics::abort` |

`switch.*` are the only variable-length instructions. Their length is given by their `n`
word.

### Calls and islands

| Instruction | Semantics |
|---|---|
| `call d, fn, frame_size` | call a VM function in this image |
| `call.ext d, sym, site, island` | call the function at symbol `sym` (an upstream instance): bytecode if it is a portal of a VM function, otherwise through `island` |
| `call.ind d, p, site, island` | indirect call through the fn pointer in slot `p` |
| `tail_call fn, frame_size` / `tail_call.ind p, site, island` | `become` |
| `ret s, len` | return `_0` (`len` bytes at `s`) |
| `island d, sym, n_ops, ops…, n_targets, t…` | call `island(fp, &ops)`, jump to `t[ret]` |
| `island.catch d, sym, n_ops, ops…, n_targets, t…` | the same through `call_catching`, then unwind if the island panicked |
| `resume` | continue unwinding |

- **`call`**:
  - Sets `new_fp = fp + frame_size(caller)`, checks the stack, and writes `[new_fp] = fp`,
    `[new_fp + 8] = pc`.
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
  tear, and relaxed loads/stores are enough, because the slot only ever holds a value that
  is correct for the site.
  - **`call.ext`**: the target is the constant `sym`, so the slot caches the resolution:
    null (unresolved), `NATIVE` (a sentinel), or a `*const Function`. On first use,
    `vm::lookup_addr(sym)` fills it.
  - **`call.ind`**: the slot caches the last VM `*const Function` this site called. On a
    call, the VM compares the target pointer with that function's portal address (a field of
    the function record). If they match, it calls the function directly. Otherwise it calls
    `vm::lookup_addr`, and stores the result if it is a VM function. Concurrent stores of
    different functions are fine: whichever wins is a valid cache entry, and every hit is
    verified against the target.
  - **VM function**: called directly. The arguments are already in the argument block layout
    ([lowering.md](lowering.md#frame-slots)), which is the same for every caller.
  - **Native target**: the instruction calls its `island` operand, a `call_ptrN` instance
    for the signature, with the fn pointer, the outgoing argument block and `d` as operands.
    The island always goes through `call_catching` unless the site's unwind action is
    `Unreachable` (or the crate is `panic=abort`). This is independent of whether the site
    has a cleanup entry: with `Continue`, the caught panic simply unwinds the VM frame.
  - **Crossing images**: when the callee is in another image, the VM loads the callee's
    image context.
- **`tail_call`**:
  - The arguments are staged in the outgoing block (above the current frame), then
    `memmove`d down to `fp + H`. The header (caller fp, return pc) is kept, so the callee
    returns to the original caller.
  - The stack check is redone with the callee's `frame_size`.
  - `tail_call.ind` to a native target can't be a true tail call. It runs the island, then
    returns as `ret` would, so it uses native stack for the duration of that call.

### Unwinding

- **Where panics start**: only in native code (an island, or the panic machinery an island
  calls). They are caught by `call_catching`, in `island.catch` and on the native path of
  `call.ext`/`call.ind`. Every native call that may unwind is caught, whatever its unwind
  action, apart from `Unreachable`. So no panic ever unwinds natively through the dispatch
  handlers, which would skip entry-record pops. The VM never unwinds
  natively, and VM `call`s don't unwind by themselves.
- **When `call_catching` reports a panic**: the payload is stored in the innermost entry
  record (one slot per `vm::enter`), so nested entries each keep their own payload. Then the
  VM looks up the current code offset in the function's cleanup table:
  - **Cleanup entry**: jump to the cleanup block. It ends in `resume`, which continues
    unwinding, or it reaches a normal exit as MIR allows.
  - **Terminate entry**: abort.
  - **No entry**: pop the frame, and repeat the lookup in the caller at its call
    instruction's offset (the return pc).
- **Reaching the entry frame**: when unwinding gets to the frame of the current
  `vm::enter`, `enter` moves the payload out of the entry record into the portal's
  out-parameter, pops the record, and returns 1. The portal then calls
  `resume_unwind_from_vm(payload)`, which re-raises it natively. If an outer VM frame catches
  it, that happens through its own `island.catch`.
- A panic during cleanup: calls in cleanup blocks have `Terminate` entries, so this aborts.

## Image format

Each crate's image is one object file with a read-only section, a writable section and
relocations. It defines the symbol `__ryo_image_<StableCrateId>`, which points at the header.

**Read-only:**

```
header        magic, format version, crate hash, section offsets/counts
functions     per function, sorted by code offset: code offset, code length,
              frame_size, cleanup table offset, portal symbol index (or none)
code          the instruction words of all functions
cleanup       per function: sorted (code offset, target block offset | terminate)
constants     constant pool: allocations, aligned
symbols       pointer-sized slots, one per referenced native symbol (functions, statics,
              islands, portals), filled in by the linker
              (`R_X86_64_64` / `IMAGE_REL_AMD64_ADDR64`); plus a flags array
              (bit 0: indirect, load through the slot)
```

The read-only sections can live in RELRO/`.rdata`, since nothing writes to them after
relocation.

**Writable** (`.data`/`.bss`):

```
site cache    one AtomicPtr per call.ext/call.ind site
fixups        PE only: constant allocations that point at DLL-imported data
```

- Instructions refer to native symbols only by symbol-table index, so code contains no
  absolute addresses and needs no relocations.
- **No re-entry into the VM from the runtime**: the registry, `lookup_addr`, `vm::enter`,
  stack setup and `call_catching` use only `core` and `ryo_rt`'s own lock (a spin lock, or a
  futex/`WaitOnAddress` lock). With `--sysroot ryo`, std's `Mutex`, allocator or TLS code may
  be VM functions, and calling them from inside the runtime would enter the VM before it
  exists. The panic payload box is the exception: it is only touched through
  `catch_unwind`/`resume_unwind`, outside the VM's own state transitions. In particular,
  `resume_unwind_from_vm` (which ends in std's `rust_panic_without_hook`, possibly a VM
  function under `--sysroot ryo`) runs only after `vm::enter` has popped its entry record.
- **Registry**: `ryo_vm_register(images, n)` is called by the registry object's constructor,
  and also when a shared object loads at run time (`dlopen`/`LoadLibrary`). It appends the
  images to a global list under `ryo_rt`'s lock, applies the PE fixups, and publishes the list:
  readers load an atomic pointer to an immutable snapshot, and old snapshots are never freed.
  The snapshot holds the crate hash → image map and the sorted code-range → image map.
  Images are never unregistered: unloading a shared object that contains ryo code
  (`dlclose`/`FreeLibrary`) is not supported, because site caches, snapshots and frames
  may still point into it.
  It does no other work, so startup is O(number of images).
- **`vm::lookup_addr`**: maps a portal address to its VM function. It uses a hash map built
  lazily on the first lookup from all registered images' portal symbols, and rebuilt
  (published the same way) when images are added. The site caches mean it's rarely called.
- **`vm::enter(id, …)`**: resolves `id` as crate hash → image (a small map in the snapshot),
  then function index → record.

## Dispatch

The hot loop is written in Rust, using nightly features available through `RUSTC_BOOTSTRAP`:

| Need | C technique | Rust |
|---|---|---|
| Tail-call threaded dispatch | `musttail` (clang) | `#![feature(explicit_tail_calls)]`: `become handler(…)` |
| No callee-saved spills, more argument registers | `__attribute__((preserve_none))` | `#![feature(rust_preserve_none_cc)]`: `extern "rust-preserve-none"` (`unstable.rs:724`), lowered to LLVM `preserve_none` on x86_64 |
| Direct-threaded dispatch | `goto *labels[op]` | `#![feature(loop_match)]` (`#[loop_match]` + `#[const_continue]`) |
| Frame allocation | `alloca` | not needed: a separate VM stack |
| Branch hints | `__builtin_expect` | `core::hint::{likely, unlikely, cold_path}`, `#[cold]` |
| Unchecked access | — | `get_unchecked`, `read_unaligned`, `unreachable_unchecked` |

- **Tail-call handlers** are the main strategy:
  - **Shape**: one small `extern "rust-preserve-none"` function per opcode, with the
    signature `(pc, fp, vm, syms, consts)`. Each ends with
    `become HANDLERS[op(next_pc)](next_pc, fp, vm, syms, consts)`.
  - **Why `preserve_none`**: with the plain Rust ABI, `become` still uses the C register
    convention. That means only 4 integer argument registers on Win64, and callee-saved
    register spills in every handler prologue.
  - **Fallback**: `dispatch!` falls back to the Rust ABI if `rust-preserve-none` is
    unavailable.
  - **Test**: a codegen test checks that handlers compile to `musttail` jumps without
    prologue pushes.
- **`loop_match`** in one function is an alternative strategy, built from the same handler
  bodies.
- **A plain `loop { match op { … } }`** works on any compiler, and is the reference for
  correctness tests.

All three are generated from one `dispatch!` macro over the handler bodies, and `y bench`
compares them. `explicit_tail_calls` and `loop_match` are `incomplete` features
(`unstable.rs:539,619`), so the plain loop stays tested too.

## Runtime crate: `ryo_rt`

The whole runtime is one rlib in the sysroot: the VM, the registry, the portal and island
templates, and the panic glue. It is a normal Rust dependency of every ryo-built crate.

- **Generic templates** get instantiated per program, with that program's types, from MIR in
  `ryo_rt`'s metadata.
- **Linking** follows Rust's normal rules: a Rust dylib contains one copy of `ryo_rt`, and the
  exe linking it uses that copy (`dependency_format`). Each cdylib or staticlib gets its own
  copy, with the usual Rust symbol hygiene.
- **std**: the VM uses the program's std for `catch_unwind`/`resume_unwind` and for
  allocating panic payloads. `y build` builds `ryo_rt` against the sysroot's std.
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
    and 1 for unwinding, with the payload (`RawPayload`, an opaque pointer pair) moved to
    `payload_out` before the entry record is popped.
  - `vm::lookup_addr(fnptr)`: portal address → VM function.
  - `vm::register`: `#[no_mangle] extern "C" fn ryo_vm_register(images, n)`.
- **`portal`**: `portal`, `portal_tc0..N` ([stubs.md](stubs.md#portals-native--vm)).
- **`island`**: the island templates ([stubs.md](stubs.md#templates)).
- **`unwind`**:
  - `call_catching(fn_ptr, fp, ops)`: runs an island inside `catch_unwind`, and stores the
    payload (`Box<dyn Any + Send>`, kept opaque as a pointer pair) in the current entry
    record.
  - `resume_unwind_from_vm(payload)`: rebuilds the `Box<dyn Any + Send>` and calls
    `resume_unwind`.

### Rules

- `ryo_rt` is always compiled by cg_llvm, and the backend treats every `ryo_rt` instance as
  native, including stub instances and their neighbors.
- It depends on `core`/`std` only.
- It carries a `RYO_RT_ABI` const, which the backend checks, erroring on a mismatch.
- **Panic strategy**: `ryo_rt` is built with `panic=unwind`, like std. It is valid in
  `panic=abort` programs (`verify_ok` in `rustc_metadata/src/dependency_format.rs:404-500`) as
  long as it makes no `C-unwind` calls (`ffi_unwind_calls.rs:132`). In an abort program,
  `catch_unwind` simply never catches. `-Zpanic-in-drop` must match.
