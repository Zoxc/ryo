# Instruction set

The VM's instructions, as the lowering emits them: the *full* set, defined once in
`vm/bytecode/src/ops.rs`. Each instruction has a mnemonic, a *shape* that says how it runs
as machine code, and typed operands ([vm.md](vm.md#instruction-words)).

This file says what each instruction does, where the lowering ([lowering.md](lowering.md))
uses it, and what machine code it becomes ([vm.md](vm.md#machine-code)). That is one of:

- a short native sequence (*inline*, `asm::inline`);
- a sequence of its own without a handler (`jmp`, the calls, `ret`, `arg`, `island`,
  `unreachable`);
- a call of its handler `ryo_h_<Opcode>` in `ryo_rt` ([vm.md](vm.md#handlers)).

The native ones are the *reduced* set (`vm/bytecode/src/reduced_ops.rs`,
[vm.md](vm.md#reduced-instructions)), plus `handler` for every handler call.

## Conventions

- **Operands**: `d` is a destination slot, `s`, `a`, `b` source slots, `[p + k]` a memory
  operand (the pointer in slot `p` plus the signed constant `k`), `p` alone a slot holding
  a pointer, `o` the flag slot of overflow ops and compare-exchange, `imm` an immediate of
  the instruction's width, `t` a branch target and `!` the branch polarity. Slots are
  signed byte offsets from `fp`.

- **Widths**: integer instructions carry their width, `w8` … `w128`, float ones their
  format, `f32` or `f64`. A family below written `add.wN` stands for every width the opcode
  list has.

  There are no `f16` or `f128` instructions: those operations, the libm functions (`sqrt`,
  `sin`, `powi`, …), the SIMD intrinsics without an instruction ([SIMD](#simd)) and
  everything else without one are islands ([stubs.md](stubs.md#islands-vm--native)).

- **Inline forms** below use `[fp + x]` for a frame slot, which is `[rbp + x]` with a frame
  pointer and `[rsp + F + x]` without one. They show the sequence on `rax` before the
  register cache renames it and drops reloads ([vm.md](vm.md#register-cache)).

  A sequence's loads and stores have the instruction's width (`movzx` loads at `w8` and
  `w16`); displacements and immediates take their shortest encoding. An inline opcode
  whose operands don't fit its sequence keeps its handler call.

- **Handler calls**: the operand registers (`rdi` = `fp`, then the operands from `rsi`, or
  from `rdi` with `fp-rbp`, [vm.md](vm.md#machine-code)), then `call ryo_h_<Opcode>`, then
  the shape's control flow. In the reduced set each is a `handler` instruction naming the
  full opcode.

  The handlers are generated from `vm/rt/src/vm/handlers.rs`, where each opcode names its
  handler *kind*, a body macro in `vm/rt/src/vm/interp.rs` (given below in parentheses).

- **Handler snippets** are simplified Rust for what a handler body does, shown for one
  width (`T` is the width's unsigned type, `I` its signed one, `F` the float type).
  `frame.read::<T>(s)` is an unaligned read of slot `s`, `frame.write(d, v)` an unaligned
  write of `v` (of its type) to slot `d`, and `frame.addr(s)` is `fp + s`. A memory
  operand `[p + k]` is `mem(p, k)` = `frame.read::<*mut u8>(p).wrapping_offset(k)`.
  Copies of values that may be pointers or uninitialized go through `MaybeUninit<T>`,
  which keeps provenance and uninit bytes. Handlers never panic; errors abort.
  Instructions with an inline form show only that form; their handler fallback has the
  same semantics.

## Data movement

#### `mov.wN d, s`

`w8`–`w128`. Copies an N-bit value between frame slots, keeping provenance and
uninitialized bytes. The lowering's `mov` emits it for every copy of 1, 2, 4, 8 or 16
bytes between slots: operands into temporaries, assignments, bit-preserving casts,
metadata of wide pointers.

Inline at every width:

```
mov rax, [fp + s]
mov [fp + d], rax
```

`mov.w128` is two halves, the high one through `rcx`: `mov rax, [fp + s]; mov rcx,
[fp + s + 8]; mov [fp + d + 8], rcx; mov [fp + d], rax`.

#### `copy d, s, len`

Copies `len` bytes between non-overlapping frame slots: the lowering's `mov` for sizes
that aren't a width. Handler `ryo_h_Copy` (`copy`):

```rust
ptr::copy(frame.addr(s), frame.addr(d), len as usize);
```

#### `imm.wN d, imm`

`w8`–`w128`. Stores an immediate: constants of scalar type, the values of a direct tag
(`SetDiscriminant`), counts and sizes for `memcpy`/`memset`.

Inline at `w8`–`w64`: `mov byte/word/dword/qword [fp + d], imm` (a sign-extended `imm32`
at `w64`), or `mov rax, imm64; mov [fp + d], rax` for a 64-bit value that isn't one.

`imm.w128` is a handler call.

#### `const d, k, len`

Copies `len` bytes from the constant pool at `k` into a slot: the lowering's constants
that live in memory (`ConstValue::Indirect`). Handler `ryo_h_Const` (`konst`); `k` is
passed as its address (`lea reg, [rip + k]`):

```rust
ptr::copy_nonoverlapping(k, frame.addr(d), len as usize);
```

#### `zero d, len`

Zeroes `len` bytes of the frame: `[0; N]` and other `Rvalue::Repeat`s of an all-zero
scalar into a slot. Handler `ryo_h_Zero` (`zero`):

```rust
ptr::write_bytes(frame.addr(d), 0, len as usize);
```

#### `fill d, k, elem_size, count`

Writes `count` copies of the `elem_size`-byte constant at `k` into a slot: `Repeat`s of
any other scalar constant into a slot. Handler `ryo_h_Fill` (`fill`):

```rust
for i in 0..count as usize {
    ptr::copy_nonoverlapping(k, frame.addr(d).add(i * elem_size), elem_size);
}
```

#### `load.wN d, [p + k]`

`w8`–`w128`. Loads an N-bit value from memory: reads through places that go through a
pointer (`*p`, fields and elements behind one), vtable entries (`load.w64`). Unaligned, as
packed fields need.

Inline at `w8`–`w64`:

```
mov rax, [fp + p]
mov rax, [rax + k]
mov [fp + d], rax
```

`load.w128` is a handler call.

#### `store.wN [p + k], s`

`w8`–`w128`. Stores to memory: assignments to places behind a pointer.

Inline at `w8`–`w64`, the value through `rcx`:

```
mov rax, [fp + p]
mov rcx, [fp + s]
mov [rax + k], rcx
```

`store.w128` is a handler call.

#### `load.copy d, [p + k], len` and `store.copy [p + k], s, len`

The loads and stores of other sizes (aggregates), with `memmove` semantics: `Indirect`
arguments' values copied to their homes in the prologue, sret results copied out before
`ret`, `typed_swap_nonoverlapping`.

Handlers `ryo_h_LoadCopy` (`load_copy`) and `ryo_h_StoreCopy` (`store_copy`):

```rust
ptr::copy(mem(p, k), frame.addr(d), len as usize);  // load.copy
ptr::copy(frame.addr(s), mem(p, k), len as usize);  // store.copy
```

#### `memcpy dp, sp, n`, `memmove dp, sp, n`, `memset dp, b, n`

Take the pointers, the byte and the length from slots:

- `memcpy`: `copy_nonoverlapping`;
- `memmove`: `copy`, and memory-to-memory copies above the temporary limit;
- `memset`: `write_bytes`, and `Repeat`s of a byte pattern into memory.

Also the `volatile_*` memory intrinsics, and the doubling copies of other `Repeat`s into
memory.

Handlers `ryo_h_Memcpy`, `ryo_h_Memmove`, `ryo_h_Memset` (`memcpy`, `memmove`, `memset`,
through `core::ptr`):

```rust
let n = frame.read::<usize>(n);
ptr::copy_nonoverlapping(frame.read::<*const u8>(sp), frame.read::<*mut u8>(dp), n); // memcpy
ptr::copy(frame.read::<*const u8>(sp), frame.read::<*mut u8>(dp), n);                // memmove
ptr::write_bytes(frame.read::<*mut u8>(dp), frame.read::<u8>(b), n);                 // memset
```

## Addresses

#### `addr d, s`

Writes `fp + s`, the address of a frame slot: borrows and raw borrows of locals, and the
bases of places that index into a local. Its object escapes there
([vm.md](vm.md#escapes-storage-ends-and-island-operands)).

Inline:

```
lea rax, [fp + s]
mov [fp + d], rax
```

#### `addr.sym d, sym` and `addr.sym.ind d, sym`

`addr.sym` writes the value of the symbol slot `sym`: the address of a function (native or
VM) or a static, for fn pointers, `ReifyFnPointer` and pointers into statics.

`addr.sym.ind` loads once more through the slot, for an indirect slot (PE `__imp_` data,
[platforms.md](platforms.md)).

Inline, the slot read rip-relative (`r` a register the register cache picks):

```
mov r, [rip + sym]
mov r, [r]          ; addr.sym.ind only
mov [fp + d], r
```

#### `addr.const d, a`

Writes the address of a constant pool allocation, or with bit 31 of `a` of one in the
writable fixup area (PE allocations that point at imports): pointers to constant memory,
vtables and constants copied out of the fixup area.

Inline, the allocation's address rip-relative (the fixup area is patched at registration,
before any VM code runs):

```
lea r, [rip + a]
mov [fp + d], r
```

#### `ptr.add d, p, imm`

Writes `p + imm`, wrapping, `imm` an `i64`: field offsets on a pointer and offsets into
statics and functions.

Inline if `imm` fits in a signed 32-bit displacement:

```
mov rax, [fp + p]
lea rax, [rax + imm]
mov [fp + d], rax
```

Otherwise a handler call.

#### `ptr.index d, p, i, stride`

Writes `p + i * stride`, wrapping, `stride` a `u32`: `BinOp::Offset`, `arith_offset` and
indexing of arrays and slices (larger strides keep the function native).

Inline if `stride` is below 2^31:

```
mov rax, [fp + p]
imul rcx, [fp + i], stride
add rax, rcx
mov [fp + d], rax
```

Otherwise a handler call.

## Integer arithmetic

All at widths `w8`–`w128`, wrapping, on unsigned bits; `.s` and `.u` forms say how the
operands are read.

At `w128`, `mul`, `mul.imm`, `div`, `rem` and `mul.ovf` don't exist: the lowering calls
the islands `ryo_island_mul_w128`, `…_div_{s,u}_w128`, `…_rem_{s,u}_w128` and
`…_mul_ovf_{s,u}_w128` instead.

The lowering's `arith` (`binop.rs`) picks the `.imm` form when the right operand is an
integer constant and the form exists.

#### `add`, `sub`, `and`, `or`, `xor` `.wN d, a, b`

`BinOp::Add`, `Sub`, the bit ops and their `Unchecked` forms, also used for address and
layout arithmetic (`size_of_val`, alignment).

Inline at `w8`–`w64`:

```
mov rax, [fp + a]
add rax, [fp + b]          ; sub / and / or / xor
mov [fp + d], rax
```

`w128` is a handler call.

#### `mul.wN d, a, b`

`w8`–`w64`. `BinOp::Mul`.

Inline: `mov eax, [fp + a]; imul eax, [fp + b]` at `w32`/`w64`; at `w8`/`w16` both
operands loaded (`movzx eax`, `movzx ecx`) and `imul eax, ecx` (the low bits are the
same); then the store.

#### `div.s`, `div.u`, `rem.s`, `rem.u` `.wN d, a, b`

`w8`–`w64`. `BinOp::Div` and `Rem`, and `ptr_offset_from`'s division by the element size.

No checks: MIR's asserts guarantee a non-zero divisor and no `MIN / -1`.

Handlers `ryo_h_DivSW8` … (`bin_fn`), `I` for `.s` and `T` for `.u`:

```rust
let (a, b) = (frame.read::<I>(a), frame.read::<I>(b));
frame.write(d, unchecked_div(a, b));  // unchecked_rem; UB if b == 0 or MIN / -1
```

#### `shl`, `shr.s`, `shr.u` `.wN d, a, b`

`BinOp::Shl` and `Shr` and the funnel shifts. The amount is masked to the width, and `b`
has width N too: the lowering converts a differently typed amount first.

Always handler calls, `ryo_h_ShlW8` … (`shift`); `shr.s` reads `a` as `I`:

```rust
let b = frame.read::<T>(b) as u32;
frame.write(d, frame.read::<T>(a).wrapping_shl(b));  // masks b to N - 1; wrapping_shr
```

#### `neg`, `not` `.wN d, a`

`UnOp::Neg` and `UnOp::Not` on integers (`!` on a `bool` is `xor.imm.w8 d, a, 1`), and
branchless min/max and alignment masks.

Handlers `ryo_h_NegW8` … (`un`):

```rust
frame.write(d, frame.read::<T>(a).wrapping_neg());  // !a for not
```

#### `add.ovf`, `sub.ovf`, `mul.ovf` `.{s,u}.wN d, o, a, b`

`AddWithOverflow` and friends. The result goes to `d` and the overflow flag (a `bool`) to
`o`; the lowering passes the offsets of the pair's two fields, since rustc decides the
field order.

Inline at `w8`–`w64`, the flag stored before the result:

```
mov rax, [fp + a]
add rax, [fp + b]          ; sub
seto cl                    ; setb for .u
mov [fp + o], cl
mov [fp + d], rax
```

The multiplies:

- `mul.ovf.s` at `w32`/`w64` is `imul rax, [fp + b]` with `seto`.
- `mul.ovf.u.w64` is `mul qword [fp + b]` with `setb` (always in `rax`, clobbering `rdx`).
- `mul.ovf.u.w32` takes the 64-bit product of the zero-extended operands (`mov ecx,
  [fp + b]; imul rax, rcx; mov ecx, 0xffffffff; cmp rax, rcx; seta cl`).
- At `w8`/`w16` the operands are loaded zero- or sign-extended, `imul eax, ecx` gives the
  exact product, and `seta` compares it to the width's range (`cmp eax, max` unsigned;
  signed `lea ecx, [rax + 2^(n-1)]; cmp ecx, 2^n - 1`).

`add.ovf` and `sub.ovf` also exist at `w128`, as handler calls.

#### `eq`, `ne`, `lt.s`, `lt.u`, `le.s`, `le.u` `.wN d, a, b`

Write a `bool`: `BinOp::Eq` … on integers, `bool`, `char` and thin pointers; `gt` and `ge`
swap the operands. Wide pointer compares combine `w64` compares of both halves with
`and.w8` / `or.w8`.

Inline at `w8`–`w64`:

```
mov rax, [fp + a]
cmp rax, [fp + b]
setcc byte [fp + d]        ; e, ne, l, b, le, be
```

#### `cmp3.s`, `cmp3.u` `.wN d, a, b`

`BinOp::Cmp`, the three-way compare, an `Ordering` as `i8` (-1, 0, 1).

Handlers `ryo_h_Cmp3SW8` … (`cmp3`), `I` for `.s`:

```rust
frame.write(d, frame.read::<T>(a).cmp(&frame.read::<T>(b)) as i8);
```

#### `rotl`, `rotr` `.wN d, a, b`

`rotate_left`/`rotate_right`; `b` is a `u32`, as in the intrinsics.

Handlers `ryo_h_RotlW8` … (`rot`):

```rust
frame.write(d, frame.read::<T>(a).rotate_left(frame.read::<u32>(b)));  // rotate_right
```

#### `ctpop`, `ctlz`, `cttz` `.wN d, a`

The counting intrinsics (also `_nonzero`); the result is a `u32`, which the lowering
converts to the destination's width.

Handlers `ryo_h_CtpopW8` … (`count`):

```rust
frame.write(d, frame.read::<T>(a).count_ones());  // leading_zeros, trailing_zeros: u32
```

#### `bswap`, `bitreverse` `.wN d, a`

The intrinsics. Handlers `ryo_h_BswapW16`, `ryo_h_BitreverseW8` … (`un`). `bswap` has no
`w8` form: a one-byte `bswap` lowers to `mov.w8`.

```rust
frame.write(d, frame.read::<T>(a).swap_bytes());  // reverse_bits
```

### Immediate forms

`add sub mul and or xor shl shr.s shr.u` and the compares `eq ne lt le gt ge` (signed and
unsigned) have `.imm` forms that take an immediate of the width in place of `b`
(`add.imm.w32 d, a, imm`). `gt` and `ge` exist only as `.imm`, since the register forms
swap operands instead.

All `w128` `.imm` forms are handler calls.

#### `add`/`sub`/`and`/`or`/`xor .imm`

Inline: `mov rax, [fp + a]; add rax, imm; mov [fp + d], rax`. `w8` computes in `al`, `w16`
and `w32` in `eax` with an `imm32` (the store drops the high bits), `w64` in `rax` with a
sign-extended `imm32`, or `mov rcx, imm64; add rax, rcx`.

#### `mul.imm`

Inline: `imul eax, [fp + a], imm` at `w32`/`w64` (`imul rax, …`); at `w8`/`w16` `movzx
eax, [fp + a]; imul eax, eax, imm`; a 64-bit immediate that doesn't fit goes through
`rcx`. No `w128` form.

#### `shl`/`shr.s`/`shr.u .imm`

Inline only for an amount below the width: `mov eax, [fp + a]; shl eax, n; mov [fp + d],
al…eax` (32-bit shifts below `w64`; `shr.s` at `w8`/`w16` loads with `movsx`).

Larger amounts are handler calls, which mask the amount to the width.

#### Compares `.imm`

Inline: `cmp byte/word/dword/qword [fp + a], imm; setcc byte [fp + d]` (`g`, `a`, `ge`,
`ae` for `gt`/`ge`), or for a 64-bit immediate that doesn't fit `mov rax, [fp + a]; mov
rcx, imm64; cmp rax, rcx; setcc`.

## Floating point

`f32` and `f64` only, IEEE with Rust semantics. All are handler calls.

#### `fadd`, `fsub`, `fmul`, `fdiv`, `frem` `.fN d, a, b`

The float `BinOp`s. Handlers `ryo_h_FaddF32` … (`fbin`):

```rust
frame.write(d, frame.read::<F>(a) + frame.read::<F>(b));  // -, *, /, %
```

#### `fneg.fN d, a` and `fabs.fN d, a`

`UnOp::Neg` on a float (`fneg`), and the `fabs` intrinsic (`fun`, `abs`):

```rust
frame.write(d, -frame.read::<F>(a));     // fneg
frame.write(d, frame.read::<F>(a).abs()); // fabs
```

#### `feq`, `fne`, `flt`, `fle` `.fN d, a, b`

Write a `bool`: float compares, `>` and `>=` as `flt`/`fle` with swapped operands
(`fcmp`):

```rust
frame.write(d, frame.read::<F>(a) == frame.read::<F>(b));  // !=, <, <=
```

#### `fmin`, `fmax`, `copysign` `.fN d, a, b`

The `minimum_number_nsz` / `maximum_number_nsz` intrinsics (`f32::min`/`max`, which return
the other operand for a NaN) and `copysign` (`fmeth`):

```rust
frame.write(d, frame.read::<F>(a).min(frame.read::<F>(b)));  // max, copysign
```

## SIMD

128-bit vectors in 16-byte frame slots, read and written unaligned. Lane `i` is the byte at
slot offset `i` (the `#[repr(simd)]` layout); the shape, last in the mnemonic, names the
lanes (`i8x16`: 16 8-bit integers), and `.s` marks a signed compare. Lanes are read as
integers, like the integer instructions' operands. `d` may alias an input: the handlers
read every input first. No traps, no memory accesses. All are handler calls, written as
portable Rust over byte arrays (`vsplat`, `vcmp`, `vmsb`), which LLVM turns into the SSE2
instructions. Bitwise operations on vectors are `and`/`or`/`xor.w128`; moves, loads and
stores are the 128-bit and block ones. The backend's mapping from `simd_*` intrinsics is in
[lowering.md](lowering.md#simd).

#### `vsplat.i8x16 d, s`

`simd_splat`: the byte `s` in every lane (`_mm_set1_epi8`).

```rust
frame.write(d, [frame.read::<u8>(s); 16]);
```

#### `veq.i8x16 d, a, b` and `vlt.s.i8x16 d, a, b`

`simd_eq` (either signedness) and the signed `simd_lt` (`simd_gt` with swapped operands):
each lane all ones if the compare holds, else zero (`pcmpeqb`, `pcmpgtb`).

```rust
let (x, y) = (frame.read::<[u8; 16]>(a), frame.read::<[u8; 16]>(b));
frame.write(d, from_fn(|i| if x[i] == y[i] { 0xff } else { 0 }));  // vlt.s: x[i] as i8 < y[i] as i8
```

#### `vmsb.i8x16 d, a`

`simd_bitmask` to a `u16`: the top bit of lane `i` at bit `i` (`pmovmskb`). Defined for
every input, where `simd_bitmask` needs all-ones or all-zero lanes.

```rust
let x = frame.read::<[u8; 16]>(a);
frame.write(d, (0..16).fold(0u16, |m, i| m | ((x[i] >> 7) as u16) << i));
```

## Conversions

#### `zext.wA.wB`, `sext.wA.wB`, `trunc.wA.wB` `d, s`

`zext`/`sext` with A < B, `trunc` with A > B: integer `as` casts between widths, and the
lowering's widening of results (`u32` counts, `bool` masks).

Inline when both widths are at most `w64`:

```
movzx eax, byte [fp + s]   ; movsx for sext; mov eax, [fp + s] for zext.w32.w64
mov [fp + d], rax          ; at the wider width
```

Sign extensions to 64 bits are `mov` at the narrow width, then `shl rax, 64 - A; sar rax,
64 - A`; truncations load at the wider width and store the narrower.

To or from `w128` they are handler calls.

#### `cvt.f2i.sat.{s,u}.fN.wM`, `cvt.i2f.{s,u}.wM.fN`, `cvt.f2f.fA.fB` `d, s`

Float to integer `as`, saturating, NaN → 0; integer to float; and between `f32` and `f64`.

Handlers `ryo_h_CvtF2iSatSF32W8` … (`cvt`), each a Rust `as`:

```rust
frame.write(d, frame.read::<f64>(s) as i32);  // cvt.f2i.sat.s.f64.w32: saturates, NaN -> 0
frame.write(d, frame.read::<u32>(s) as f64);  // cvt.i2f.u.w32.f64
frame.write(d, frame.read::<f32>(s) as f64);  // cvt.f2f.f32.f64
```

Casts involving `f16` or `f128`, and on PE float to `i128`/`u128` (whose handlers keep a
value in `xmm6`, [platforms.md](platforms.md)), are the `as_cast` island.

Bit-preserving casts (transmutes, pointer casts) are `mov` or `copy`.

## Enums

There are no enum instructions. Direct-tagged enums use plain loads, stores, `imm` and
integer casts. Niche-encoded tags (`TagEncoding::Niche`) are decoded with integer ops, as
cg_ssa's `codegen_get_discr`, and stored with `imm.wN` (the variant is known when lowering);
see [lowering.md](lowering.md#rvalues).

## Atomics

All handler calls; each performs the matching `core::sync::atomic` operation, on the
pointer in slot `p`. The handlers are `ryo_h_AtomicLoadW8Relaxed` …
`ryo_h_CompilerFence`.

The lowering (`intrinsic.rs`, `atomic`) maps the `atomic_*` intrinsics onto them; an
ordering combination the opcode list doesn't have takes the `seqcst` form, which is
stronger.

Widths 8–64 run in the VM; 128-bit atomics keep the function native for now (they need
`cmpxchg16b`). Atomic operands are always aligned as the type requires.

#### Orderings

`relaxed`, `acquire`, `release`, `acqrel` and `seqcst`, and only the combinations core
accepts exist: loads have no `release`/`acqrel`, stores no `acquire`/`acqrel`, failure
orderings are `relaxed`/`acquire`/`seqcst`, and fences aren't `relaxed`. `compiler_fence`
has no ordering: every ordering of `atomic_singlethreadfence` maps to it, since it emits no
machine code and is the same barrier to the VM and the JIT for all of them.

In the snippets, `AtomicT` is the width's `AtomicU8` … `AtomicU64` and `ord` the
instruction's ordering.

#### `atomic.load.wN.ord d, p` and `atomic.store.wN.ord p, s`

`atomic_load` and `atomic_store` (`aload`, `astore`):

```rust
let p = AtomicT::from_ptr(frame.read::<*mut T>(p));
frame.write(d, p.load(ord));             // load
p.store(frame.read::<T>(s), ord);        // store
```

#### `atomic.<rmw>.wN.ord d, p, s`

`<rmw>` is one of `xchg add sub and or xor nand min max umin umax`: the read-modify-write
intrinsics; `d` gets the old value. `min`/`max` are signed (`AtomicI*`), `umin`/`umax`
unsigned (`armw`, `swap` and `fetch_*`):

```rust
let p = AtomicT::from_ptr(frame.read::<*mut T>(p));
frame.write(d, p.fetch_add(frame.read::<T>(s), ord));  // swap, fetch_sub, …, fetch_nand
```

#### `atomic.cxchg[.weak].wN.ord_s.ord_f d, o, p, old, new`

`atomic_cxchg` and `atomic_cxchgweak`. The previous value goes to `d` and the success flag
to `o`, the offsets of the result pair's two fields (`cxchg`,
`compare_exchange[_weak]`):

```rust
let p = AtomicT::from_ptr(frame.read::<*mut T>(p));
let (v, ok) = match p.compare_exchange(frame.read::<T>(old), frame.read::<T>(new), ord_s, ord_f) {
    Ok(v) => (v, true),
    Err(v) => (v, false),
};
frame.write(d, v);
frame.write(o, ok);
```

#### `.ptr` forms

`atomic.load/store/xchg/add/sub/and/or/xor.ptr.ord` and
`atomic.cxchg[.weak].ptr.ord_s.ord_f` are `AtomicPtr`'s operations, which the lowering
uses when the intrinsic's type is a thin raw pointer.

On the machine they are the `.w64` ones; the difference is the value's type, a pointer, so
the reduced semantics keeps its provenance (lean/docs/reduced.md §D.1). `add`/`sub` are
`fetch_byte_add`/`_sub`, and the bitwise ones take a `usize` operand, keeping the
provenance of the pointer in memory.

Pointers have no `nand`/`min`/`max`/`umin`/`umax` (core never emits them; such a call
keeps the function native) (`aload_ptr`, `astore_ptr`, `armw_ptr`, `cxchg_ptr`):

```rust
let p = AtomicPtr::<u8>::from_ptr(frame.read::<*mut *mut u8>(p));
frame.write(d, p.swap(frame.read::<*mut u8>(s), ord));           // xchg
frame.write(d, p.fetch_byte_add(frame.read::<usize>(s), ord));   // fetch_byte_sub, fetch_and, …
```

#### `fence.ord` and `compiler_fence`

No operands: `atomic_fence` and `atomic_singlethreadfence` (`fence`, `compiler_fence`):

```rust
core::sync::atomic::fence(ord);
core::sync::atomic::compiler_fence(SeqCst);  // compiler_fence
```

## Control flow

Branches have a polarity: with `!` (`neg`) they branch when the condition is false, so
`br.eq! a, b, t` branches when `a != b`. The lowering (`terminator.rs`) picks the polarity
that lets it fall through to the next block, and only jumps where it can't.

#### `jmp t`

`Goto` and the other leg of a two-way branch, left out when `t` is the next block. No
handler: `jmp rel8/rel32`, relaxed like every branch.

#### `br s, t` and `br! s, t`

Branch if the `bool` in slot `s` is true / false: `SwitchInt` on a `bool`.

Inline:

```
test byte [fp + s], 0xff
jnz t                      ; jz with !
```

#### `br.eq`, `br.lt.s`, `br.lt.u` `.wN a, b, t`

(and `!`.) A compare fused with the `SwitchInt` on its result, when the compare's `bool`
is used only there (integers, `bool`, `char`, thin pointers). `ne`, `le` and `ge` are the
negated forms, with swapped operands where needed.

Inline at `w8`–`w64`:

```
mov rax, [fp + a]
cmp rax, [fp + b]
jcc t                      ; e, l, b; inverted with !
```

#### `br.eq`, `br.lt.{s,u}`, `br.gt.{s,u}` `.imm.wN a, imm, t`

(and `!`.) The same with a constant right operand, and `SwitchInt` on one value
(`br.eq.imm`).

Inline at `w8`–`w64`: `cmp [fp + a], imm; jcc t` (a 64-bit immediate that doesn't fit goes
through `rcx`, as in the compares).

At `w128` both compare-branch families are handler calls.

#### `switch.dense.wN` and `switch.sparse.wN`

`switch.dense.wN s, base, t_default, n, t_0 … t_{n-1}` is a jump table on `s - base`, for
a `SwitchInt` whose values span at most 1024 and at most twice the case count plus 4.

`switch.sparse.wN s, t_default, n, (v_i, t_i)…` is the other `SwitchInt`s of more than one
value, the values sorted (unsigned); the handler scans linearly for `n ≤ 4` and searches
binary above.

Handlers `ryo_h_SwitchDenseW8` … and `ryo_h_SwitchSparseW8` … (`switch_dense`,
`switch_sparse`) return the case index (`n` for the default); the sparse values are a code
constant, passed as its address and the count:

```rust
// dense
let i = frame.read::<T>(s).wrapping_sub(base as T);
return if (i as u128) < n as u128 { i as usize } else { n };

// sparse: vals[0..n] sorted
if n <= 4 {
    return (0..n).find(|&i| vals[i] == v).unwrap_or(n);
}
return vals[..n].binary_search(&v).unwrap_or(n);  // any match; values are distinct
```

Then the jump through the table, which follows inline in the text:

```
call ryo_h_SwitchDenseW32
lea rcx, [rip + T]
movsxd rax, dword [rcx + rax*4]
add rax, rcx
jmp rax
int3 …                     ; to a multiple of 4
T: dd t_0 - T, …, t_default - T
```

#### `unreachable`

`Unreachable` terminators and the missing return of a call that can't return (only
reachable through UB). No handler: a bare `ud2`, which kills the process with `SIGILL`.
It has no call site, so it can't unwind. The decoder reads a `ud2` at the start of an
instruction as `unreachable`; the `ud2` after a `trap`-shaped handler call is read with
the call.

```
ud2
```

#### `abort`

`core::intrinsics::abort`, and writing the tag of an uninhabited variant. Handler
`ryo_h_Abort` (`abort_now`), then `ud2`:

```rust
core::intrinsics::abort();
```

## Calls, returns and islands

None of these has a handler, except `lpad` and `resume`. The calling convention they
follow, and where arguments and return values go, is in
[vm.md](vm.md#calls-and-islands).

#### `call`, `call.sym`, `call.sym.ind`, `call.ptr` `d, …, k, a`

- **`call d, fn, k, a`** calls a VM function of the same image: `Call` terminators and the
  lowering's own calls whose callee is in the image's VM set.
- **`call.sym d, sym, k, a`** calls the function at symbol `sym`, native or a VM function
  of any image.
- **`call.sym.ind d, sym, k, a`** does so through an indirect slot (PE `__imp_`,
  [platforms.md](platforms.md)).
- **`call.ptr d, p, k, a`** calls through the fn pointer in slot `p`: fn pointers, virtual
  calls (the pointer loaded from the vtable with `load.w64`), and drop glue through a
  vtable.

The sequence:

1. the callee's address into `rax` where needed (`mov rax, [rip + slot]` for `.sym.ind`,
   `mov rax, [fp + p]` for `.ptr`);
2. the argument list `a`'s loads into the argument registers (`mov`/`movzx`,
   `movss`/`movsd`, `lea` for `ARG_ADDR`);
3. the call (`call rel32`, `call [rip + slot]`, `call [rax]`, `call rax`);
4. the stores of the return registers into `d` as the return kind `k` says (none for `k`
   0, when `d` must be 0; 3-, 5-, 6- and 7-byte integer parts in pieces of 4, 2 and 1
   bytes with shifts in between).

The call is a call site in the LSDA.

#### `tail_call fn, a` and `tail_call.ptr p, a`

`TailCall` terminators (`become`), to a VM function of the image or through the fn pointer
in `p`; a tail call to anything else with a symbol is `addr.sym` + `tail_call.ptr`.

The sequence: `mov rax, [fp + p]` for `.ptr`, the argument registers' loads, the epilogue,
`jmp fn` / `jmp rax`.

#### `ret s, k`

`Return`. Loads the value at `fp + s` into the return registers as the return kind `k`
says (`rax`, `rdx`, `xmm0`, `xmm1`; integers loaded at 1, 2, 4 or 8 bytes), then the
epilogue and `ret`. With `k` 0, `s` must be 0.

#### `arg d, r`

The prologue's store of the argument register `r` to its home slot `d` (`mov [fp + d],
reg` of the part's size, an SSE store for floats, `movd` through `r11` for `f16`).

Only at the start of a function, before the first handler call clobbers the registers.

#### `island isl, n, ops…`

Calls the island template at symbol slot `isl` with `fp` and the operand array, then
continues; the template's return value is ignored.

Islands are everything the VM has no instruction for: `extern "C"` callees (`call_cN`),
safe callees without a symbol (`call`), intrinsics, 128-bit multiply and divide,
`f16`/`f128`, SIMD without an instruction ([stubs.md](stubs.md#islands-vm--native)).

The operand words are a code constant (offsets only; the lowering records each operand's
extent with `Asm::lend`):

```
lea rdi, [rsp + F]         ; mov rdi, rbp with a frame pointer
lea rsi, [rip + ops]
call [rip + isl]
```

On PE the registers are `rcx`/`rdx`, with `sub rsp, 32` / `add rsp, 32` around the call
for the shadow space. The call is a call site.

The `ops` array is exactly what the template reads; call templates take the argument
block as a tuple in the outgoing area, `ops[1]` the destination.

#### `lpad x`

The landing pad of a cleanup or terminate block, one `lpad x; jmp bb` stub per distinct
unwind destination ([vm.md](vm.md#unwinding)).

The personality enters it with the exception object in `rax`; `mov rsi, rax` (`rdi` with
`fp-rbp`), the operand register, then handler `ryo_h_Lpad` (`lpad`), which stores the
object in the function's exception slot `x`:

```rust
frame.write(x, exception);  // the object, from the register before x's
```

#### `resume x`

`UnwindResume`, continuing to unwind the exception object in slot `x`.

Handler `ryo_h_Resume`, written in assembly: it loads the object and jumps to
`_Unwind_Resume`, so the unwinder sees the VM function as its caller. `trap` shape: the
handler call (a call site) then `ud2`. On PE, in the pad region (where all cleanup code
with a landing pad is, [vm.md](vm.md#pe-seh)), it is `add rsp, 40; ret` instead, without a
call site: the landing pad returns to the trampoline that called it; elsewhere the PE
handler aborts.

```
movsxd rsi, esi
mov rdi, [rdi + rsi]       ; fp-rbp: movsxd rdi, edi; mov rdi, [rbp + rdi]
jmp _Unwind_Resume
```

## Reduced: `handler`

**`handler h, args, t`** (`!` with `neg`) exists only in the reduced set: a call of the
handler of the full opcode `h` with the argument registers `args` from `rdi` on (`fp`, the
exception object, an immediate, or the address of a constant, data, a symbol slot, a site
or a code constant), then `h`'s shape's control flow:

- a branch to `t[0]` on the returned `bool` (`br`);
- a jump through the table `t` on the returned index, the default last (`switch`);
- `ud2` (`trap`);
- or nothing.

Every full instruction with a handler becomes one where it isn't inlined
([vm.md](vm.md#reduced-instructions)).
