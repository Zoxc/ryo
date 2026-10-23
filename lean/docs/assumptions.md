# Assumptions of the Lean development

Everything the Lean code (`Ryo/Spec`, milestone M1) takes on trust rather than proving or
checking: logical holes, opaque code, cut-offs, the oracle and environment contracts, the
trusted input, and the semantic choices that fix what "the MIR ryo compiles" means. Each
entry says where it is, what it assumes, why, and how to discharge or check it.

Divergences of the spec from what rustc/LLVM and ryo actually do are in
[divergences.md](divergences.md), and its differences from MiniRust in
[minirust-divergences.md](minirust-divergences.md). Line numbers are as of the commit that
added this file; declaration names are the stable reference.

## 0. Regenerating the list

The mechanical part of this audit (§1, §2) can be redone with two commands from `lean/`.

Source grep, for constructs that introduce assumptions or silent defaults:

```
grep -rnE '\b(axiom|sorry|admit|opaque|partial|unsafe|implemented_by|extern|native_decide|panic!|decreasing_by)\b|\]!|get!|getD|toNat\b' \
  --include=*.lean Ryo Main.lean | grep -v '^[^:]*:[0-9]*:\s*--'
```

Kernel view, which also catches compiler-generated `partial` definitions: put this in a scratch
file outside the tree and run `lake env lean <file>` after `lake build`. It reports every
theorem in `Ryo` that depends on `sorryAx`, and every `axiom` and `opaque` constant in `Ryo`.

```lean
import Lean
import Ryo
open Lean Elab Command in
elab "#ryo_axioms" : command => do
  let env ← getEnv
  for (name, ci) in env.constants.map₁.toList do
    if !(`Ryo).isPrefixOf name || name.isInternal then continue
    match ci with
    | .thmInfo _ =>
      if (← liftCoreM (collectAxioms name)).contains ``sorryAx then logInfo m!"sorry: {name}"
    | .axiomInfo _ => logInfo m!"axiom: {name}"
    | .opaqueInfo _ => logInfo m!"opaque: {name}"
    | _ => pure ()
#ryo_axioms
#print axioms Ryo.Spec.Theorems.decode_encode   -- [propext, Classical.choice, Quot.sound]
```

Its output at this commit: the `sorry` theorems of §1.1 still open and the seven opaque
instances of §1.2, nothing else. Every proved theorem depends only on Lean's three standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## 1. Logical and implementation assumptions

### 1.1 `sorry`: the open representation theorems

All in `Ryo/Spec/Theorems/Representation.lean`. Nothing else in `Ryo` uses `sorry`, and
nothing uses these theorems yet, so they are open goals, not assumptions other proofs rely on.

| Theorem | States | Status |
|---|---|---|
| `encode_length` | `Ty.encode` at a well-formed sized type gives the type's size | **proved** (no value well-formedness needed) |
| `decode_encode` | `decode (encode v) = some v` for `checkValue`-valid values | **proved** |
| `encode_decode_le` | re-encoding a decoded value is less defined than the bytes | open |
| `decode_mono` | more-defined bytes decode to a more-defined value | open |
| `store_load` | `typedStore` then `typedLoad` gives back a less-defined value | open |

Proving them showed what `Ty.wf` must check, and four spec gaps, all fixed with the proofs:
- `Ty.wf` now checks that union chunks are disjoint, and for enums with a tag
  (`variantTagWf`): each inhabited tagged variant's tag value is in range, valid, decodes back
  to the variant and lies outside the variant's fields; the untagged variant of a niche
  encoding stores, at the tag's place, a scalar (`Ty.scalarRange`) whose valid range is inside
  the tag's and outside the niche values; a direct tag is no wider than the discriminant type;
  the niche values fit the tag. rustc's layouts satisfy these by construction; field alignment
  and the `discr` values themselves still are not checked (the theorems do not need them).
- `checkValue` accepted float values whose bits do not fit the format (they did not
  round-trip); it now requires `bits < 2^bits` (`illFormed` otherwise, as a format mismatch).
- `checkPtrMetadata` accepted a vtable pointer at address 0 or beyond `2^64` if the memory had
  a vtable allocation there; it now rejects both (UB), as no allocation can be there.
- `Ty.encode` of a union did not check the chunk lengths (MiniRust panics), so the encoding
  could be longer than the union; it now returns `none`.

### 1.2 Opaque code

| Where | What | Why | Effect / discharge |
|---|---|---|---|
| `instReprTy.repr`, `instReprValue.repr`, `instToJsonTy.toJson`, `instToJsonValue.toJson`, `instFromJsonTy.fromJson`, `instFromJsonValue.fromJson`, `instFromJsonLayoutStrategy.fromJson` (`deriving` on `Ty`, `Value`, `LayoutStrategy`) | Lean derives these for nested inductives as `partial` defs: an `opaque` constant run by compiled `unsafe` code | `Ty` and `Value` are nested inductives (`List (Offset × Ty)`, `VariantOf Ty`) | Only printing and the dump (§4) use them. Equality is no longer derived: `Ty.beq`/`Value.beq` are structural, `Ty.beq_iff`/`Value.beq_iff` prove they decide `=`, and `DecidableEq Ty`/`DecidableEq Value` are built from them, so the `==` that `abiCompatible`, `unsizeValue` and `atomic_cxchg` use is a `LawfulBEq`. Every other type the semantics compares (`VariantOf`, `Place`, the MIR syntax, `Choice`, `Event`, …) derives `DecidableEq` |
| ~~`Float.pow`, `Float32.pow`~~ | `powi` used the host C library's `pow` | | **Removed**: `powi` is now compiler-rt's `__powidf2` loop over the exact `Float.mul`/`Float.div` (`Float.powi`, [divergences.md](divergences.md) R3) |
| `Float.ofBits`/`toBits`, `Float32.ofBits`/`toBits`, `Float.sqrt`, `UInt*.ofNat/toNat`, `Nat.log2`, `Int.tdiv/tmod`, `Array.*` | `@[extern]` with Lean reference implementations | standard Lean runtime | Proofs use the reference definitions. Only the interpreter's results trust the runtime (GMP-backed `Nat`/`Int`, C arrays): the usual trusted base of compiled Lean. `Float.*` appear only in the test helpers `hwBinop64`/`hwBinop32`/`hwSqrt64` (and `RyoTest`) |

There is no `axiom`, `native_decide`, hand-written `partial`/`unsafe`, `@[extern]` or
`@[implemented_by]` in `Ryo`, and the spec's own termination is structural (or by the fuel
parameters of §2).

### 1.3 Panicking accesses and default values

`xs[i]!` panics (and returns `default` in proofs) when out of range; `getD` silently
substitutes a default. Each use, and what keeps it from mattering:

| Where | Default / panic | Relies on |
|---|---|---|
| `Memory.store`, `Memory.load` (Mem/Basic.lean `m.allocs[id]!`) | panic | `checkPtr` returned this `id`, so it is in range |
| `Memory.writeInit`, `Memory.store` (`d.set! (off + i) b`) | out-of-range writes dropped | `checkPtr` bounds; for globals, `Wf.checkProgram` checks each relocation lies inside the global |
| `createFrame` (Call.lean:152–208, `body.locals[l]!`, `locals[l]!`) | panic | `Wf.checkBody`: `argCount < locals.size`, `spreadArg ≤ argCount`; `n > 0` checked first |
| `recordConstCopy` (`arr[g]!`) | panic | the array was grown to `g + 1` just before |
| `Wf.checkBody` (`b.blocks[0]!`) | panic | `blocks.size > 0` checked just before |
| `Ty.size`, `Ty.align` (Types.lean:151) | `0`, `1` for unsized types | callers check `isSized`; `Wf.checkBody` rejects unsized locals; `Ty.wf` requires sized fields/elements. `prepareInPlace`, the destination de-init in `evalTerminator` and `allocSlot` use them on locals/places that are sized |
| `Ty.layout` of `array`/`slice` with an unsized element (Types.lean:133, 137) | `.sized 0 1` / `.slice 0 1` | `Ty.wf` rejects unsized elements |
| `tagForVariant` (`discr` default `0`), `variantInhabited` (default `false`), `evalRvalue .discriminant` (default `0`) | defaults for an out-of-range variant index | indices come from `tagToVariant`/`readDiscriminant` (in range) or `SetDiscriminant`/`Aggregate` (checked by `Wf.checkStatement` for `SetDiscriminant`; *not* checked for `AggregateKind.adt`) |
| `contUnwind`, `callInstance` (`catch_unwind`), `evalTerminator .drop` (`locals[1]?.getD …`) | argument type `*mut u8` / `*mut T` when the callee has no parameter | the callee is a body with that parameter; the default only names the caller-side type of the argument |
| `callInstance` (`destTy` default `unitTy`) | intrinsic result type `()` without a destination | intrinsics are always called with a destination |
| `concreteOracle` (`nanBits` default `0`) | not a NaN | candidate lists are never empty (`nanCandidates` always contains the two canonical NaNs) |
| `Program.symbol` | `"<instance i>"` | diagnostics only |
| `Main.lean` (`n.toNat!`) | panic on a non-numeric `--fuel` | CLI only |

`Int.toNat` clamps negative values to 0. The uses are on values already known non-negative
(`usize` operands, checked counts). The one that was not, the cast to pointer in `evalCast`,
now wraps with `IntType.usize.toBits` ([divergences.md](divergences.md) R1, fixed).

## 2. Fuel and cut-offs

| Where | Bound | On exhaustion | Assumes / discharge |
|---|---|---|---|
| `runWith` (Interp.lean:59) | `fuel` steps, default 1,000,000 (`ryo-lean run`: 10,000,000, `--fuel`) | `Outcome.outOfFuel`, not a behavior | the run ends within the fuel; `RunsTo .diverges` quantifies over all fuels |
| `State.maxDepth` (State.lean:109), `runWith` (`maxDepth` 10,000) | frames on the stack | `Outcome.stackOverflow` (D25) | a depth bound stands in for the real stack's byte budget ([divergences.md](divergences.md) R12) |
| `runN` (Behavior.lean:47) | `maxDepth := n + 1` with `n` steps of fuel | never reached: a step pushes at most one frame | makes L0 programs never overflow in `Behaviors`, so the D25 disjunct of `Refines` is unreachable while both sides are L0 (§6) |
| `globalPtrF` (Operand.lean:89) | nesting of relocations, `globals.size + 1` | `illFormed` | statics are recorded before their relocations are resolved, so cycles through statics terminate; a cycle among constants or vtables only (which rustc cannot produce) is rejected |
| `unsizeValue` (Cast.lean:38) | struct nesting 64 | `illFormed` | `CoerceUnsized` chains are shallow |
| `unfoldTransparent` (Call.lean:38) | 16 wrappers | stops unfolding (a wrapper deeper than that is compared as is) | more nesting is unrealistic; otherwise spurious ABI UB |
| `splitReceiver` (Terminator.lean:36) | 16 levels | `illFormed` | `dyn` receivers (`Pin<Box<dyn T>>`, …) are shallow |

`noBehavior`, `illFormed` and `outOfFuel` ends are not behaviors (`RunResult.behavior?`). An
`illFormed` stop in a *source* program therefore removes the run, and with it every
behavior that continues it: a target that runs on is then not a refinement, so
ill-formedness can only make a theorem harder, never vacuous. In a *target* L0 program it does
make refinement vacuous for that run.

## 3. Oracle requirements

The semantics asks every non-deterministic choice through `MonadChoice` (`Choice`,
Prelude/Nondet.lean:27) and checks the answer. Requirements per choice, and what the
concrete oracle (`concreteOracle`, Interp.lean:26) answers:

| Choice | Kind | Constraint (checked by) | Bad answer | `concreteOracle` |
|---|---|---|---|---|
| `allocAddr size align` | daemonic | `Memory.addrOk`: non-zero, aligned, `addr + size < 2^64`, no overlap with a live non-empty allocation (D8, D26) | `noBehavior` | bump allocator from `0x10000`, one byte gap |
| `exposedProv addr` | angelic | `none` or an exposed `AllocId` (`IntPtrCast.ptrFromInt`) | `noBehavior` | the live exposed allocation containing `addr`, preferring one where it is not one-past-the-end (Miri) |
| `nanBits fmt cands` | daemonic | answer in `cands` (`resolveFloat`) | `noBehavior` | the first candidate: the positive canonical quiet NaN |
| `constCopy g n` | daemonic | any `Nat` (`< n` reuses a copy, else a fresh copy) | none | `0` (first copy) |
| `fnAddr i n` | daemonic | as `constCopy` | none | `0` |
| `guaranteedCmp` | daemonic | any `Bool` (`true`: exact answer, `false`: 2) | none | `true` |
| `fmulAddFused` | daemonic | any `Bool` (`fmuladd` fused or not) | none | `false` (unfused, as baseline x86-64) |
| `nszZero` | daemonic | any `Bool` (which zero `minimum_number_nsz`/`maximum_number_nsz` return) | none | `true` (the second operand, as the fallback body) |
| `compareBytes diff` | daemonic | an `i32` with the sign of `diff` (`evalIntrinsic "compare_bytes"`) | `noBehavior` | `diff` (glibc's `memcmp`) |

Assumptions:

- **The concrete oracle stays inside the constraints**, so every interpreter run that ends
  without UB is a behavior (README, "How it works"). This is unproved. The bump allocator
  would break `addr + size < 2^64` after 2^64 bytes of allocations (a `noBehavior` stop, not a
  wrong answer). Discharge: a lemma `concreteOracle` answers satisfy `Memory.addrOk`
  (monotone top, alignment), plus the trivial cases.
- **Reported UB can be spurious** for programs that cast integers to pointers: the concrete
  oracle makes one angelic choice, while `Behaviors` counts UB only if *every* angelic
  alternative goes wrong (as with Miri). Interpreter UB verdicts on such programs need a
  second look, not a fix.
- **The oracle may depend on the whole state** (`Oracle.answer : Nat → Choice → State → …`).
  `Behaviors` quantifies over all such oracles; `Oracle.sameDaemonic` compares answers
  pointwise. This is the intended reading of MiniRust's `pick`/`predict`, not a choice to
  revisit.

## 4. Trusted inputs: the dump

The spec's input is a `Program` (Mir/Syntax.lean): MIR bodies, types with layouts, globals
and instances. Today it comes from the `Builder` DSL in the tests. From M1b it comes from
the backend's JSON dump (`RYO_DUMP_LEAN`), whose schema is the derived `FromJson` instances
(Mir/Json.lean). **The dump is the one trusted input** (aot.md §C6). It must faithfully
reflect rustc 1.99.1 (`MirPhase::Runtime(Optimized)`, after drop elaboration, monomorphized;
the reference is `rustc_middle/src/mir/syntax.rs` of the pinned toolchain's `rustc-dev`
sources, not a newer rustc checkout), in particular:

| Dumped item | What must hold | Checked by Lean? |
|---|---|---|
| Statements, terminators, places, operands, rvalues | the body's MIR, with rustc's evaluation-relevant details (`Move` vs `Copy`, `UnwindAction`s, `is_cleanup`) | indices and projections type-check (`Wf.checkProgram`); rvalue typing against the destination is not checked |
| `Ty` layouts: offsets, sizes, alignments, `ValidRange`s, `EnumRepr`, `TagInfo`, `Variant.discr`, `inhabited`, `TupleHeadLayout.packedAlign` | exactly `tcx.layout_of` (layouts are input, D2) | internal consistency only (`Ty.wf`: fields and chunks inside and disjoint, tags consistent with the variants, §1.1); never recomputed |
| `ProjElem.deref pointee`, `field _ ty`, `opaqueCast ty` | the projected types rustc computes | `Wf.projTy` only checks the shape |
| `InstanceKind` (`body` / `ext` / `intrinsic name`) | the resolved instance; intrinsics with a fallback body that the backend calls must be dumped as that body (the D20 fallback rule is not in Lean) | index ranges |
| `drop` glue, `AssertMessage.panicFn` and `args`, `LangItems`, `CallerLoc`, `PointerCoercion` instances, `UnsizeMeta` | what cg_ssa would call or attach | index ranges |
| `Global`s: bytes (`none` = uninit), relocations, alignment, `GlobalKind` (`static mutable` for `static mut` *and* interior mutability; `const`; `vtable`; `threadLocal`) | rustc's const-eval allocations and `vtable_allocation` | relocations inside the bytes and to existing targets |
| `FnAbiSummary` (caller's per call, callee's per body), including the `detail` strings | the `fn_abi` rustc computes; both sides rendered the same way | compared for equality (D14) |
| `Operand.runtimeChecks` values | the session's `ub_checks`/`contract_checks`/`overflow_checks` | no |
| `Statement.nop` | only the no-op statement kinds listed in mir-spec §A.1 | no |

How to check: differential runs (M1b) of the Lean interpreter against native and ryo-compiled
code on the corpus; a Rust-side round trip (dump, reload with `ryo-lean`, compare); spot
checks of dumped layouts against `-Zprint-type-sizes`; later, C1' and the image checks (aot.md
§C4) cross-check the dump against the object it describes.

## 5. Environment and external calls

| Item | Where | Assumption | Status / discharge |
|---|---|---|---|
| Environment = the shims | `callExternal` (External.lean:44) | external calls behave as the shims: `__rust_alloc`/`_zeroed`/`dealloc`/`realloc` (heap allocations, `GlobalAlloc` preconditions as UB, D21), `write` (returns `len`), `exit`, `abort`, `_Unwind_RaiseException` (starts unwinding), `ryo_test_print` (tests) | every other symbol is `illFormed`. Programs whose `std` paths reach other symbols (panic machinery, `__rust_alloc_error_handler`, I/O, …) cannot run yet |
| `ExtSpec` | Behavior.lean:93 | the relational contract (unreachable memory unchanged, frees only reachable heap allocations, may allocate) | stated, **not used** by the semantics; plugging it in is M1/M1b work. Until then the behaviors of a program with external calls are those under the shims only |
| Events | `Event.extCall`, `Event.write` | the trace records callee, argument values and result; for `write`, the fd and the bytes written | `write`'s bytes are in the trace (R8, fixed); other events still carry addresses (e.g. `__rust_alloc`'s result), so traces compare addresses that are daemonic choices |
| Panic runtime | D18 | unwinding starts only in external code; the payload is the exception pointer | the panic runtime (`__rust_start_panic`, `__rust_panic_cleanup`, …) is not shimmed |
| Terminate lang items | `callTerminate` (Unwind.lean:50) | `panic_cannot_unwind`/`panic_in_cleanup` never return; without a body in the program the run aborts | matches cg_ssa; the dump must provide them |

## 6. Semantic assumptions

| Assumption | Where | Why | Check / discharge |
|---|---|---|---|
| Target is x86-64: `PTR_SIZE = 8`, little endian, addresses below 2^64, `isize::MAX` object sizes, `MAX_ATOMIC_SIZE = 8` | Prelude/Target.lean | ryo targets x86-64 only (Linux, macOS, Windows) | a port would make `Target` a parameter, as in MiniRust |
| Primitive layouts hard-coded where a `Ty` carries no layout: `i128`/`u128` 16-aligned (`IntType.align`), `char` 4/4, `bool` 1/1, wide pointers 16/8, `f*` naturally aligned | Prelude/Basic.lean `IntType.align`, Types.lean `Ty.layout` | x86-64 since rustc 1.77 | compare with the dumped layouts in the M1b dumper (assert equal) |
| Layouts are rustc's, not recomputed | D2, §4 | "follow rustc" by construction, `-Zrandomize-layout` included | as §4 |
| Single thread; atomics sequential; no data races | D17 | ryo's theorem is for single-threaded executions | out of scope (plan.md §4) |
| No aliasing model | D16 | less UB makes the theorem stronger; ryo does not exploit aliasing | revisit if the JIT wants `noalias` |
| Out-of-scope constructs are rejected (`illFormed`), not modeled: `InlineAsm`, coroutines, C-variadics, SIMD operations, intrinsics outside the implemented set, unknown externals, tail calls to non-bodies, unsized locals | `throwIllFormed` sites; mir-spec §A.1 | ryo keeps such functions native, so they never need an L0 meaning | coverage reports in M1b; `grep -n throwIllFormed` lists every rejection |
| The program is well-formed MIR: `Wf.checkProgram` passes, and beyond it the bodies are what rustc's MIR validator accepts | `runWith`; Mir/WellFormed.lean | the semantics uses `illFormed` for shapes rustc never produces | rvalue typing in `Wf` is still missing (plan.md M1) |
| Runs start at `Program.start`, called with the given arguments by value; its return or unwinding ends the run (`Final.returned`/`Final.unwound`) | `Sem.start`, `doReturn`, `contUnwind .bottom` | lets single functions run; MiniRust requires `exit` | the real entry point is `lang_start` ([divergences.md](divergences.md) R11) |
| `Refines` compares two L0 programs | Behavior.lean:82 | stated for later levels | the D25 stack-overflow clause cannot fire between L0 programs, since `runN` never overflows (§2). It needs a target semantics with a real stack bound |
| A UB outcome counts only if no angelic answer avoids it | `Behaviors` | MiniRust's `predict` | — |
| The exact float arithmetic is IEEE 754 round-to-nearest-even | Lang/Float.lean | rustc/LLVM default floating-point environment (no `fesetround`, no x87) | tested against hardware `Float`/`Float32` (`D5/matches_hardware`); a proof against an IEEE spec would need a formal IEEE model (none in core) |
| `SemM := ExceptT Outcome (StateT State (ReaderT Oracle Id))`: the state survives an exception | State.lean:115 | the event trace up to UB is kept | — |
