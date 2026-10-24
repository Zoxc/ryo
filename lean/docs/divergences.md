# Divergences of the Lean spec from the code it models

Where L0 (`Ryo/Spec`) gives a program a meaning different from what it has when compiled:
rustc's MIR semantics and layouts, LLVM-compiled native code (std, islands, handlers), and
ryo's lowering and runtime. Found by auditing the Lean code against rustc's cg_ssa and Miri,
the intrinsic docs in `library/core/src/intrinsics`, and ryo's backend and VM. Divergences
from MiniRust, including the check of the D1–D36 table, are in
[minirust-divergences.md](minirust-divergences.md); trusted inputs and other assumptions in
[assumptions.md](assumptions.md).

**Why the direction matters.** L0 is the *source* of every refinement theorem (target
behaviors ⊆ source behaviors, plus anything after source UB). So:

- spec has **more UB** than real code: the theorem stays true but says nothing about the
  affected programs. Acceptable when Rust itself calls it UB.
- spec has **less UB** than real code: the theorem is stronger, and ryo must actually behave
  as the spec says on those programs. Differential runs against LLVM-compiled code may
  disagree there, since LLVM may exploit the UB.
- spec is **narrower** (deterministic, or fewer outcomes) than what compiled code may do: the
  theorem is **false** for programs that observe the difference. These are the important
  ones to fix.

Classification: **bug** (wrong, should be fixed), **narrowing** (fewer behaviors than real
code; fix by adding a daemonic choice), **gap** (not modeled yet; runs stop `illFormed`),
**simplification** (deliberate, harmless for the theorems), **deliberate** (follows Rust's
documented semantics where codegen is more lenient).

## Summary

| # | Topic | Declaration | Class |
|---|---|---|---|
| R1 | Int-to-pointer cast of a negative signed integer gives address 0 | `evalCast` | bug, **fixed** |
| R2 | An allocation may end exactly at 2^64, making in-bounds offsets to its end UB | `Memory.addrOk` | bug (more UB), **fixed** |
| R3 | `powi` uses the host `pow`, not compiler-rt's `__powidf2` | `Float.powi` | bug / narrowing, **fixed** |
| R4 | `fmuladd` always fused | `evalIntrinsic` `"fmuladd"` | narrowing, **fixed** |
| R5 | `minimum_number_nsz`/`maximum_number_nsz` of equal zeros returns `x` | `Float.minNum` | narrowing, **fixed** |
| R6 | `compare_bytes` returns exactly -1/0/1 | `evalIntrinsic` `"compare_bytes"` | narrowing, **fixed** |
| R7 | `__rust_realloc` never returns the old address | `callExternal` | narrowing, **fixed** |
| R8 | `write`'s bytes are not in the trace | `callExternal` | bug (trace too coarse), **fixed** |
| R9 | Heap allocation never fails | `heapAlloc` | simplification |
| R10 | Atomic RMW on pointers unsupported; `cxchgweak` never fails spuriously | `evalIntrinsic` atomics | gap / narrowing (harmless on x86) |
| R11 | Unwinding out of, or returning from, the start function | `contUnwind`, `doReturn` | simplification |
| R12 | Stack overflow by frame count | `pushFrame`, `runN` | simplification |
| R13 | Intrinsics and externals outside the modeled set | `evalIntrinsic`, `callExternal` | gap |
| R14 | No aliasing UB | D16 | deliberate (less UB) |
| R15 | Overlapping assignments are defined | `evalStatement .assign` | deliberate (less UB) |
| R16 | Validity at calls is checked in full | `createFrame`, `doReturn`, `checkPtr` | deliberate (more UB) |
| R17 | Typed copies reset padding and strip provenance | `typedLoad`/`typedStore`, `evalRvalue` | deliberate (spec less defined) |
| R18 | ABI compatibility is approximated structurally | `abiCompatible`, `unfoldTransparent` | simplification (both directions) |
| R19 | Vtable metadata is not checked against the trait | `vtableSizeAlign`, `checkPtrMetadata` | simplification (less UB) |
| R20 | `typed_swap_nonoverlapping` swaps raw bytes | `evalIntrinsic` | deliberate (less UB, matches ryo) |
| R21 | Float details: NaN of the interpreter, `f*_algebraic`, `f16`/`f128` | Lang/Float.lean, `concreteOracle` | simplification / narrowing |
| R22 | Evaluation order and minor UB-message differences | various | simplification |
| R23 | `Rvalue::Reborrow` took the place's address | `evalRvalue .reborrow` | bug (unstable feature), **fixed** |
| R24 | Allocator shims didn't match rustc's mangled `#[rustc_std_internal_symbol]` names | `callExternal`, `internalName` | gap, **fixed** (M1b) |
| R25 | Shims required bare integers/pointers; std passes `Alignment`, `NonNull<u8>` | `argInt`, `argPtr`, `scalarOf` | gap, **fixed** (M1b) |
| R26 | Closures called through fn pointers were ABI-incompatible (ZST `self`, `rust-call`) | `fnAbiCompatible`, `createFrame` | bug (more UB), **fixed** (M1b) |
| R27 | `Drop` of a `dyn` place ran the `dyn` glue instead of the vtable's drop entry | `evalTerminator .drop` | bug, **fixed** (M1b) |
| R28 | Direct enum tags wider than the discriminant type were ill-formed | `Ty.wf`, `tagToVariant` | bug, **fixed** (M1b) |
| R29 | `is_val_statically_known` missing | `evalIntrinsic` | gap, **fixed** (M1b) |
| R30 | `assert_inhabited`/`assert_zero_valid`/`assert_mem_uninitialized_valid` never panic | `evalIntrinsic` | narrowing, open |
| R31 | `caller_location` in MIR-inlined `#[track_caller]` code | `callInstance` | bug (ill-formed), **fixed** (M1b) |

## Bugs and narrowings

**R1. Int-to-pointer casts of negative values.** `evalCast .pointerWithExposedProvenance`
(Mir/Cast.lean:100) computes the address as `i.toNat % 2^64`. `Int.toNat` clamps negatives to
0, so `-1isize as *const u8` gets address 0. cg_ssa sign-extends a signed source
(`intcast(.., isize, signed)`, then `inttoptr`), giving `0xffff_ffff_ffff_ffff`. Checked:
evaluating the cast on `(.int (-1), isizeTy)` returns address 0. Fix:
`IntType.usize.toBits i` (that is, `(i % 2^64).toNat`). Applies to every negative signed
source.
**Fixed:** the address is `IntType.usize.toBits i`; test `R1/neg_int_to_ptr`.

**R2. Allocations ending at 2^64.** `Memory.addrOk` (Mem/Basic.lean:62) accepts
`addr + size ≤ 2^64`. MiniRust requires `addr + size` to be a valid `usize` (`< 2^64`), and
no real allocation reaches the top of the address space. `ptrOffsetInbounds` then makes the
one-past-the-end pointer of such an allocation UB ("in-bounds pointer arithmetic
overflowed"). Because the address is a daemonic choice, *every* program that offsets a
pointer to the end of an allocation has UB in some execution, so it has UB. That makes the spec
far more UB than intended (e.g. `slice::iter`'s end pointer). The concrete oracle never picks
such an address, so tests do not see it. Fix: `addr + size < Target.ADDR_LIMIT`.
**Fixed** as proposed; test `R2/addr_bound`.

**R3. `powi`.** `evalIntrinsic "powi"` (Mir/Intrinsics.lean:315) calls Lean's
`Float.pow`/`Float32.pow`, which is the host libm's `pow` on a converted exponent. LLVM lowers
`llvm.powi` to compiler-rt's `__powidf2`/`__powisf2` (repeated squaring, one rounding per
multiplication). ryo keeps `powi` native, so ryo-compiled programs get `__powidf2`'s result.
The two differ often: over x ∈ (1, 3), k ∈ {2, 3, 7, 13, 31, 77}, 7290 of 11994 sampled
pairs differ in the last bits. The spec allows one result and the compiled code produces another,
so refinement fails. NaN results also bypass RFC 3514's candidate set, `f16`/`f128` are
`illFormed`, and the result depends on the host libm ([assumptions.md](assumptions.md) §1.2).
Fix: define `powi` as the `__powidf2` loop over the exact `Float.mul`/`Float.div` (rustc
leaves its precision unspecified, so a daemonic choice would also be valid, but then it must
contain `__powidf2`'s result).
**Fixed:** `Float.powi` is the `__powidf2` loop over the exact `Float.mul` (one rounding per
multiplication, the same order as LLVM's inline expansion for constant exponents), then
`Float.div 1 r` for a negative exponent; a NaN anywhere gives `nanCandidates [x]`. `f128` uses
the same loop (`__powitf2`), `f16` is promoted to `f32` and rounded back (`Float.powiF16`, as
LLVM legalizes `f16` on x86-64). No host float code is left in the semantics. Remaining
difference: LLVM *constant-folds* `powi` with constant operands using the host `pow`, so a
program whose `powi` operands are all compile-time constants may get the correctly rounded
result instead. Tests `R3/powi_loop` (against the loop on hardware `Float`/`Float32`) and
`R3/powi`.

**R4. `fmuladd`.** `evalIntrinsic "fma" | "fmuladd"` (Mir/Intrinsics.lean:373) always
computes the fused result. The intrinsic is documented as non-deterministically fused or
unfused; its fallback body is the unfused `a * b + c`. LLVM on baseline x86-64 (no `fma`
target feature) emits a separate multiply and add. ryo does not lower `fmuladd` itself and
calls the native code or the fallback body, so it computes the unfused result, which the spec
does not allow. Fix: a daemonic choice between `Float.fma` and `Float.mul` then `Float.add`
(each NaN-resolved).
**Fixed** as proposed (`Choice.fmulAddFused`; the concrete oracle does not fuse); test
`R4/fmuladd`.

**R5. `minimum_number_nsz_*` / `maximum_number_nsz_*` on equal operands.** `Float.minNum`
(Lang/Float.lean:244) returns `x` when the operands compare equal, i.e. for `+0.0` vs `-0.0`.
`nsz` leaves the sign unspecified, but the docstring's "we return `x` (a refinement)" has
the direction backwards: a deterministic source is *narrower*. The fallback body
(`if x.is_nan() || y <= x { y } else { x }`) returns `y` in that case. ryo's
`FminF64`/`FmaxF64` handlers are `f64::min`/`max` compiled by LLVM (`minnum`/`maxnum`, whose
zero sign depends on operand order on x86). Fix: a daemonic choice between `x` and `y` when
both are zeros.
**Fixed:** `Choice.nszZero` for zeros of different sign (equal non-zero operands have equal
bits); the concrete oracle returns `y`. Test `R5/nsz_zero`.

**R6. `compare_bytes`.** `evalIntrinsic "compare_bytes"` (Mir/Intrinsics.lean:380) returns
-1, 0 or 1. The intrinsic only promises the sign ("negative if `left` is less"), and it
lowers to `memcmp`. ryo calls it through the `ryo_island_compare_bytes` wrapper, so the
magnitude is glibc's (typically the byte difference). A program that inspects the value (not
just its sign) shows a target behavior the spec lacks. Fix: a daemonic choice of the
magnitude, or of any `i32` with the right sign.
**Fixed:** `Choice.compareBytes diff` accepts any `i32` with the sign of the first byte
difference; the concrete oracle answers the difference itself (glibc). Test
`R6/compare_bytes`.

**R7. `__rust_realloc` moves every time.** The shim (`callExternal`, Mir/External.lean:52)
allocates the new block while the old one is live, then frees the old one. `Memory.addrOk`
forbids overlap with the live old block, so the new address always differs. Real `realloc`
often grows in place and returns the same address, which a program can observe (comparing
the old address with the new one is defined). Fix: read the old bytes, deallocate, then
allocate (the daemonic address may then coincide), then store.
**Fixed** as proposed; test `R7/realloc_in_place`.

**R8. `write` is invisible in traces.** The `write` shim (Mir/External.lean:62) checks that the
buffer is readable and returns `len`. The event records only the argument values `(fd, ptr,
len)`, not the bytes, although the module header says it "records the bytes". Two programs
that print different data at the same address have the same trace, so `Refines` cannot tell
correct output from wrong output. The `ptr` is an address, so traces also differ for
irrelevant reasons. Fix: record the bytes (and the `fd`) in the event instead of the pointer.
The same applies to `ryo_test_print`, which records its arguments as values (fine for
scalars, wrong for pointers to data).
**Fixed** for `write`: it emits `Event.write fd bytes` (instead of an `extCall` event) with
the data bytes; uninitialized bytes are UB and provenance is dropped, as in Miri. Test
`R8/write_trace`. `ryo_test_print` (tests only) still records values.

**R9. Allocation never fails.** `heapAlloc` (Mir/External.lean:34) always succeeds or stops with
`noBehavior` when no address fits. Real `__rust_alloc` returns null on failure (then
`handle_alloc_error`). Harmless for refinement, since OOM paths are rarely tested, but
differential runs that exhaust memory will differ. Zero-size and non-power-of-two-alignment
requests are UB, as `GlobalAlloc` says.

**R10. Atomics.** D17 makes atomics sequential, with orderings ignored and fences no-ops.
That is exact for single-threaded programs. Two details: (a) the RMW intrinsics
(`atomic_xadd`, …, Mir/Intrinsics.lean:274) require an integer type (`intArg`). On pointer
types (`AtomicPtr::fetch_ptr_add`/`fetch_byte_add`/`fetch_or` on `*mut T`) they stop
`illFormed` (gap). (b) `atomic_cxchgweak` never fails spuriously. Rust allows spurious failure,
but x86's `lock cmpxchg` never fails spuriously, so this matches every target ryo has
(narrowing that is harmless on x86-64).

## Simplifications and gaps

**R11. Program start and end.** A run calls `Program.start` with given arguments
(`Sem.start`). Returning ends the run with `Final.returned v`. Unwinding out of it ends with
`Final.unwound` (`contUnwind .bottom`, Unwind.lean:77). In a real binary, `main` is called by
`lang_start`, which turns a return into an exit code and catches a panic (exit code 101), and
unwinding out of an `extern "C"` function aborts. This is a harness convention for running
single functions. Theorems about whole programs should start at `lang_start` (or model it).

**R12. Stack overflow.** The interpreter overflows after `maxDepth` frames (default 10,000,
`pushFrame`). Real code overflows after a number of *bytes* (8 MiB main-thread stack,
guard page and `ryo_probe_stack`). In `Behaviors`, L0 never overflows (`runN`), which is the
intent for a source. A differential run of deep recursion can therefore succeed in one and
abort in the other.

**R13. Unmodeled intrinsics and externals.** Calls stop `illFormed` (no behavior) for:
- intrinsics outside the implemented set, notably the libm family (`floorf*`, `ceilf*`,
  `truncf*`, `roundf*`, `rintf*`, `sinf*`, `expf*`, `logf*`, …, which `f64::floor` etc. call
  since they moved to `core`), `carrying_mul_add`, SIMD, and intrinsics whose fallback body
  the dump did not provide in place of the intrinsic (`is_val_statically_known`, used by
  `core`'s integer `pow`, has fallback body `false`; the D20 fallback rule is the dump's
  job, see [minirust-divergences.md](minirust-divergences.md));
- external symbols other than the shims ([assumptions.md](assumptions.md) §5), which
  includes the panic machinery: a failed `Assert` calls the panic lang item, which in a dump
  without `core`'s bodies is external and stops the run.

ryo keeps functions using SIMD and some intrinsics native, so part of this is by design. The
libm family and the panic path will be needed for M1b differential runs.

**R14. No aliasing UB (D16).** L0 has none of the UB that LLVM's `noalias`, `readonly` and
`dereferenceable`-on-entry annotations of *native* code create. Programs violating Rust's
aliasing rules are defined in L0 and may behave differently when the same function is
LLVM-compiled. ryo's own code does not exploit aliasing, so the theorem is fine. Differential
runs against native code must exclude such programs (run them under Miri first).

**R15. Overlapping assignments.** `evalStatement .assign` (Mir/Statement.lean) evaluates the
rvalue to a value and stores it, so `*p = *q` with overlapping non-scalar places is defined
(memmove semantics). In MIR this is UB ("assignments not producing primitives must be
non-overlapping": Miri's `copy_op` uses a non-overlapping `mem_copy`, and LLVM's `memcpy` is
UB on overlap). Less UB than rustc. ryo copies large aggregates with `Memmove`
(`copy_val`, backend lower/operand.rs), so it is consistent with the spec. Keep it that way, or add the
UB.

**R16. Validity at calls is checked in full (D15).** Arguments are validated at the callee's
types on entry, and the return value at `Return`, with `checkValue`. That includes
dereferenceability and alignment of every reference and `Box`, inhabitedness of pointees, and
valid vtables for raw `dyn` pointers. LLVM only gets `dereferenceable`/`noalias` where rustc
emits them (not for `!Freeze` pointees behind `&`, not for `&mut !Unpin`), and nothing for
raw pointers. So L0 has more UB than native codegen. This follows Rust's validity invariant
as Miri checks it, so it is deliberate.

**R17. Typed copies are less defined than byte copies.** Every load/store goes through
`decode`/`encode` (MiniRust): padding becomes `Uninit`, integers lose provenance, unions keep
only their chunks, and an enum `Aggregate` rewrites the whole enum (variant fields, tag,
everything else `Uninit`). cg_ssa and ryo copy bytes and write only the fields and the tag. The
spec's memory is less defined than the target's, which is the sound direction. Programs that
read padding after a typed copy have UB in L0 but work natively. Note that the return value
is *not* re-encoded: the callee's `_0` is the caller's place (D12), so its padding keeps
whatever the callee wrote.

**R18. ABI compatibility (D14).** `abiCompatible` (Mir/Call.lean:72) is Miri's
`check_argument_compat` approximated on `Ty`. Two departures from rustc's documented rules:
- `repr(transparent)` is recognized *structurally* (`unfoldTransparent`): any struct whose
  only non-1-ZST field is at offset 0 and has the struct's size and alignment, whether or not
  it is `repr(transparent)`. The null-pointer optimization is recognized for two-variant enums
  with a niche starting at 0 and size 8. Less UB than rustc, which guarantees neither for
  non-`transparent` structs. The x86-64 calling convention passes such pairs the same way, so
  no observable divergence is expected.
- Other aggregates must be equal as `Ty` (`a == b`), including field types. Structs that
  differ only in, say, `&u8` vs `*const u8` fields are compatible for codegen (same `PassMode`)
  but UB here. Rust does not guarantee their compatibility, so this is more UB than codegen
  but within the language rules.

When both sides carry a `FnAbiSummary`, they must also be equal, including the `detail`
strings. That is only as faithful as the dumper's rendering ([assumptions.md](assumptions.md)
§4).

**R19. Vtable trait not checked.** `vtableSizeAlign` (Lang/Representation.lean:268) accepts
any live `vtable` allocation. MiniRust and Miri also require the vtable to be *for the
pointer's trait*, so a `*const dyn A` carrying a `dyn B` vtable is UB there and defined
here. The `GlobalKind.vtable` trait name is dumped but dropped when allocating. Fix: keep the
trait name on the allocation and compare.

**R20. `typed_swap_nonoverlapping`.** Swaps raw bytes (Mir/Intrinsics.lean:210), without
checking validity at `T`. Miri does a typed copy (invalid values are UB). ryo's lowering is a
byte copy through a temporary (`LoadCopy`/`Memcpy`/`StoreCopy`), so the spec matches ryo and
has less UB than Miri.

**R21. Floats.** Arithmetic is exact IEEE round-to-nearest-even, and NaN payloads are a
daemonic choice from RFC 3514's set. That covers what x86-64 SSE produces, including its
negative default NaN. Remaining differences:
- the *interpreter* picks the positive canonical NaN (`concreteOracle`), while x86 produces
  `0xfff8…` (sign set) for invalid operations. Differential runs must compare NaNs modulo the
  candidate set, not bit for bit;
- `f*_algebraic` compute the single exact operation. LLVM may reassociate and contract across
  several such operations, producing results that no sequence of exact operations gives
  (narrowing). ryo itself computes the exact operation;
- `f16`/`f128` arithmetic is computed exactly (more than mir-spec requires), and ryo's
  `call` template runs the native code, which should agree. Not tested yet.

**R22. Small things.**
- `TailCall` evaluates the arguments before a `fnPtr` callee operand, while `Call` evaluates the callee
  first (Mir/Terminator.lean). Only the order of UB checks differs.
- `ConstValue::Indirect` constants that are invalid at their type are UB, while other invalid
  constants are `illFormed` (`evalConst`). rustc never produces either.
- `Discriminant` of a non-enum is 0, as in rustc. `SetDiscriminant` of a niche-encoded variant
  does a validation read, as Miri does (cg_ssa writes nothing). Codegen assumes it holds, so
  the extra UB is Rust's.
- `ptr_guaranteed_cmp` may return 2 (daemonic). ryo and LLVM at run time always return the
  exact answer, which the spec includes.

**R23. `Reborrow`.** rustc's `Rvalue::Reborrow(ty, mutbl, place)` (the unstable `Reborrow`
traits experiment) reborrows a user type implementing `Reborrow`: a bitwise copy of the place
at type `ty`, with `&mut` fields reborrowed. `evalRvalue .reborrow` treats it like `Ref` and
produced the place's address. Only programs using the experiment were affected. **Fixed**: it
loads the place's value at `ty` (reborrowing `&mut` fields is a no-op without an aliasing
model, D16). `Wf` requires the place's shape for a mutable reborrow and, for a shared one (the
`CoerceShared` target), the same size and alignment. Test `R23/reborrow_copies`.

## Found by the differential runs (M1b)

`scripts/lean-diff.py` runs the programs in `tests/lean/` with plain rustc, with ryo, and
with the Lean interpreter on the backend's `RYO_DUMP_LEAN` dump, at `-O0` and `-O3`, and
compares output and exit status (tests `M1b/*` in RyoTest/M1b.lean pin each fix). Every
disagreement so far was in the spec (none in ryo's
lowering: ryo matched rustc on every program):

**R24. Allocator symbols.** rustc mangles `#[rustc_std_internal_symbol]` items as
`__rustc::<name>` (v0 `_R…7___rustc12___rust_alloc`), so `Vec` stopped at an unknown external.
**Fixed**: `internalName` recovers the name before matching the shims, and
`__rust_no_alloc_shim_is_unstable_v2` is a no-op shim.

**R25. Shim arguments.** std passes the alignment as `Alignment` (a struct around a
fieldless `repr(usize)` enum) and pointers as `NonNull<u8>`; the shims wanted bare scalars.
**Fixed**: `callExternal` gets the argument types and `scalarOf` sees through single-field
structs and fieldless enums.

**R26. Closures through fn pointers.** A closure coerced to a fn pointer is called through
its `FnOnce` shim, whose ABI has a leading zero-sized `self` (`PassMode::Ignore`) and the
`rust-call` convention; the spec called the call ABI-incompatible (UB). **Fixed**: `rust` and
`rust-call` are one convention (rustc `CanonAbi::Rust`), and `Ignore` arguments are skipped on
both sides when both ABIs are known, as Miri's `pass_argument` does.

**R27. `Drop` of `dyn Trait`.** rustc's drop glue for `dyn Trait` only drops `*self` again;
codegen calls the vtable's drop entry (word 0) with the data pointer, skipping a null entry
(cg_ssa `codegen_drop_terminator`). **Fixed** in the `Drop` terminator; the dumper emits the
`dyn` glue as `ext`.

**R28. Widened direct tags.** Without a `repr`, rustc widens an enum's tag to the variants'
alignment (`Option<i128>` has a `u128` tag), which `Ty.wf` rejected (`tag ≤ discrTy`).
**Fixed**: a direct tag is matched against each discriminant at the tag's width (on tags in
the valid range this is cg_ssa's cast of the tag to the discriminant type); the constraint
is gone, and `tagForVariant_of_tagToVariant` no longer needs it. Not yet exercised: widened
tags with negative discriminants.

**R29. `is_val_statically_known`** (used by `i32::pow`) is now an intrinsic answering `false`,
which is always a correct answer.

**R30. `assert_inhabited` & co.** (reached from `MaybeUninit`/`mem::zeroed`) are no-ops for
now: the intrinsic instance does not carry its type arguments, so the spec cannot tell when
they panic. Real code panics for uninhabited (or, for the other two, not zero-/uninit-valid)
types, so the spec is narrower there. Fix: give `InstanceKind.intrinsic` the generic
arguments (the dumper has `instance.args`) and panic as cg_ssa does.

**R31. `caller_location` after MIR inlining.** Inlining a `#[track_caller]` function puts
its `caller_location` call into a body that is not `#[track_caller]`; rustc then gives the
call's own caller location (cg_ssa `get_caller_location`). The spec reported it ill-formed.
**Fixed**: the intrinsic returns the call's `callerLocation` when it has one.

Not divergences, but limits of the runs: non-generic std functions have no MIR in the
sysroot's metadata, so they are external calls without shims and stop the run
(`std::io::_print`, `alloc::fmt::format_inner`, `std::panicking::set_hook`, …), which is why
the corpus prints through `write` and never panics; the dump starts at the user's `main`, not
`lang_start`, so a `main` returning `Err` is not exit status 1; the interpreter's NaN is the
positive quiet NaN where x86 arithmetic produces the negative one (both are allowed, D5).
