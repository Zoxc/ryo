# Divergences of the Lean spec from MiniRust

How `Ryo/Spec` differs from MiniRust (pinned at `d821c6e3`), as implemented. §1 checks the
documented divergences D1–D36 ([mir-spec.md](mir-spec.md) §A.7 and "Deviations during M1")
against the code: which declarations implement each one, which tests exercise it, and
where the code differs from the table. §2 lists differences from MiniRust that the table does
not document. §3 lists places where the docs no longer match the code. Where L0 differs from
what rustc, LLVM and ryo actually do, see [divergences.md](divergences.md) (cited as Rn);
assumptions are in [assumptions.md](assumptions.md).

Every D-number is cited in the code as `-- [Dn]` at the definitions concerned (`grep -rn
'\[D16\]' Ryo`). D16, the only one that had no inline tag, got one at `Memory` with this
document.

## 1. D1–D36 against the code

"As documented" means the code does what the mir-spec row says, as amended by "Deviations
during M1". Tests are in `RyoTest/` (`lake exe ryotest <name>`).

| D | Implemented by | Tests | Status |
|---|---|---|---|
| D1 MIR syntax | Mir/Syntax.lean (`ProjElem`, `Rvalue`, `Terminator`, …); `projectPlace`, `evalRvalue`, `evalTerminator` | all | as documented; extra fields per Deviations (`deref` pointee, `CallerLoc`, `FnAbiSummary` on calls, `Callee.virtual idx`) |
| D2 layouts as input, rustc tag algorithm | `Ty`, `EnumRepr`, `TagInfo`; `tagToVariant`, `tagForVariant`, `Ty.decode`/`encode` (enum case) | Enum.lean | as documented; `tagToVariant` agrees with Miri's `read_discriminant` (direct: valid range, then discriminant lookup; niche: relative value, untagged-niche value UB) |
| D3 valid ranges | `ValidRange`; `Ty.decode` (int, ptr, tag), `checkValue`, `checkPtr` | Divergence.lean `D3/*`, Enum.lean | as documented |
| D4 `char` | `Ty.char`, `isUnicodeScalar`, `evalCast .intToInt` | `D4/*` | as documented |
| D5 floats | Lang/Float.lean; `resolveFloat`, `Choice.nanBits` | `D5/*` | **differs from the table, as Deviations says**: exact rational arithmetic instead of `opaque` + `@[implemented_by]`; `f16`/`f128` arithmetic works too. Not covered by the row: `powi` is compiler-rt's `__powidf2` loop (R3, fixed), `fmuladd` fused or not is a daemonic choice (R4, fixed), so is the zero `minimum_number_nsz` returns for opposite zeros (R5, fixed) |
| D6 fn pointers | `fnPointer`, `instOfFnPtr`, `Choice.fnAddr`, `AllocationKind.function` | `D6/*` | as documented. With D8, function allocations are size 0, so distinct functions may share an address (MiniRust's overlap rule kept them unique, see §2) |
| D7 consts/statics | `globalPtrF`, `Choice.constCopy`, `Allocation.mutable`, `Allocation.vtableRo`, `GlobalKind.mutable` | `D7/*` | as documented, plus Deviations (lazy statics). Interior mutability is the dump's `static (mutable := true)` flag |
| D8 ZST allocations | `Allocation.overlaps` | `D8/zst_sharing` | as documented |
| D9 storage | `storageLive`, `storageDead`, `createFrame` (always-live locals) | Basic.lean | as documented |
| D10 binary ops | `evalIntBinOp`, `evalBinOp`, `comparePtr`, `orderingValue` | Int.lean, Ptr.lean | as documented. `*WithOverflow` builds a tuple that is stored at the destination's type; the helper `IntType.withOverflowTy` is unused |
| D11 ptr ↔ int | `IntPtrCast.expose`/`ptrFromInt`, `evalCast` | Ptr.lean | as documented (the address of a negative source wraps, R1, fixed) |
| D12 `Move`, in-place args | `evalArg`, `createFrame`, `Cont.caller` de-init list, `evalTerminator .call` | Call.lean | as Deviations: in-place args and return place alias the caller |
| D13 uninit scalars | `decodeBits`, `Ty.decode` | `D13/uninit_int` | as documented |
| D14 ABI, `rust-call`, `#[track_caller]` | `abiCompatible`, `unfoldTransparent`, `fnAbiCompatible`, `untupleLast`, `callerRustCall`, `evalCallerLoc`, intrinsic `caller_location` | Call.lean | as Deviations (Miri's rules on `Ty`); approximations in R18 |
| D15 validity at boundaries | `createFrame` (entry `typedLoad`), `doReturn`, `checkPtr` | Call.lean | as documented |
| D16 no aliasing model | `Memory` (no extras, `-- [D16]`), `PointeeInfo` without `freeze`/`unpin` | none (nothing to test) | as documented |
| D17 single thread, atomics | `atomicAlign`, atomic cases of `evalIntrinsic` | `D17/*` | as documented; RMW on raw pointers keeps provenance; `cxchgweak` never fails (R10) |
| D18 unwinding | Mir/Unwind.lean, `Frame.unwinding`/`pendingUnwind`, `Cont`, `step` | Call.lean (`unwinding`, `catch_unwind`) | as Deviations (payload = exception pointer, started by `_Unwind_RaiseException`, bottom → `Final.unwound`) |
| D19 `Assert`, `Drop` | `evalTerminator .assert`/`.drop` | Call.lean | as documented; a panic function that returns is UB (no target block) |
| D20 intrinsics | `evalIntrinsic`, `callInstance` (`abort`, `unreachable`, `catch_unwind`), `copyBytes`, `Statement.assume` | Int.lean, Ptr.lean, Divergence.lean | every listed intrinsic is implemented, plus `select_unpredictable`, `prefetch_*`, `wrapping_*`, `saturating_*`, `*_with_overflow`, `three_way_compare`, `ptr_mask`, `offset`, `minimum*`/`maximum*`, `f*_fast`, `f*_algebraic`, `float_to_int_unchecked`, `fmuladd`. **Not implemented**: the row's "any other intrinsic: external call to its fallback body". Lean has no notion of fallback bodies, and other intrinsics are `illFormed`; the dump must present the fallback body as the callee (assumptions.md §4) |
| D21 heap | `callExternal`, `heapAlloc`, `AllocationKind.heap` | `D21/*` | as documented; `realloc` may grow in place and `write` records its bytes (R7, R8, fixed) |
| D22 thread locals | `evalRvalue .threadLocalRef`, `GlobalKind.threadLocal` | `D22/thread_local` | as documented |
| D23 `RuntimeChecks` | `evalOperand .runtimeChecks` | `D23/runtime_checks` | as documented |
| D24 type ids | `resolveRef .typeId`, relocations to `.typeId` | `D24/type_id_ptr` | as documented |
| D25 stack overflow | `pushFrame`, `State.maxDepth`, `Refines` | Call.lean | implemented, but the `Refines` clause cannot fire between L0 programs: `runN` gives a stack above the fuel to both sides (assumptions.md §2, §6) |
| D26 addresses | `Memory.addrOk`, `Target.ADDR_LIMIT` | `R2/addr_bound` | as documented (MiniRust's bound, `addr + size < 2^64`, since R2 was fixed) |
| D27 128-bit ints | `IntType` | `D27/i128` | as documented |
| D28 discriminants | `readDiscriminant`, `writeDiscriminant`, `evalRvalue .discriminant` | Enum.lean | as documented |
| D29 vtables | `vtableSizeAlign`, `vtableWordPtr`, `splitReceiver`, `resolveCallee .virtual`, `TupleHeadLayout.tailOffset` | Unsized.lean | as documented; the vtable's trait is not checked (R19, §2) |
| D30 unsizing | `unsizeValue`, `UnsizeMeta` | Unsized.lean | as documented |
| D31 `Repeat` | `evalRvalue .repeat` | `D31_D32/repeat_union` | as documented |
| D32 `Aggregate` | `evalRvalue .aggregate` | `D31_D32/repeat_union`, Enum.lean | as documented; `Wf` checks the variant index, field count and field shapes of an `adt` aggregate |
| D33 `Transmute` | `transmute`, `evalCast .transmute` | `D33/transmute_size` | as documented (also `boxDerefTransmute`, `subtype`) |
| D34 numeric `as` | `Float.toInt`, `Float.ofInt`, `Float.convert` | `D5/floats` | as documented |
| D35 pointer casts | `evalCast` (`ptrToPtr`, `fnPtrToPtr`, coercions) | `D35/wide_to_thin` | as documented |
| D36 packed/unaligned places | `Place.aligned`, `projectPlace .deref`, `placeLoad`/`placeStore` | Basic.lean | as documented |

## 2. Differences from MiniRust not in the D-table

| Topic | MiniRust | Lean (declaration) | Class |
|---|---|---|---|
| Allocation bound | `addr + size` must be a valid `usize` (`< 2^64`) | same (`Memory.addrOk`) | fixed (R2) |
| Return value | `Return` loads `_0` at the callee type and stores it into the caller's place (a typed copy) | `_0` *is* the caller's place (D12, as Miri); `doReturn` only validates, so padding is not reset | deliberate (Miri); more defined than MiniRust |
| Function addresses | unique: `overlaps` reports equal addresses as overlapping, and `fn_from_ptr` relies on it | size-0 `function` allocations may share addresses (D8); lookup is by provenance (`instOfFnPtr`) | deliberate (`unnamed_addr`, D6) |
| ABI compatibility | structural on `Type` (tuples, arrays, unions field by field), no `repr(transparent)`, no NPO | Miri's rules: transparent wrappers and NPO unfolded, `char` ~ `u32`, 1-ZSTs; other aggregates need `Ty` equality | as D14 says; stricter than MiniRust for structurally equal aggregates, laxer for wrappers |
| Vtable pointer validity | `check_ptr` for `VTablePtr` also checks the vtable's `trait_name` | `vtableSizeAlign` only checks it is a live vtable allocation | gap (R19) |
| Valid ranges in `check_ptr` | none | `checkPtr` also checks the pointer's `ValidRange` | D3 |
| `Cmp` result | `Type::Int(I8)` | the destination type (`i8` or the `Ordering` enum, `orderingValue`) | D10 |
| `compare_ptr` with mismatched metadata | `panic!` | compares a metadata key (`none` as 0) | spec totality; ill-typed MIR only |
| `PtrOffsetFrom` | checks the gap from both pointers | requires equal provenance (unless distance 0) and checks from `q` | equivalent |
| Entry/exit validation | `Validate` statements inserted by `minimize` (with retags) | implicit at entry and `Return` (D15), no retags | D15, D16 |
| Program end | the start function must call `exit`; returning from it is ill-formed | returns end the run (`Final.returned`), and so does unwinding (`Final.unwound`) | harness convention (R11) |
| Globals | all allocated by `Machine::new` | statics on first use, constants per evaluation | D7 (same behaviors, as Step.lean argues) |
| `IntPtrCast.exposed` | `Set<Provenance>` | `List AllocId` | representation only |
| Errors | `panic!` for spec bugs and ill-typed input | `Outcome.illFormed` (machine) or `none` (`decode`/`encode`); ill-formed runs are not behaviors | deliberate (mir-spec §A.8) |
| Monad | `NdResult` (abstract non-determinism, `pick`/`predict`) | `SemM := ExceptT Outcome (StateT State (ReaderT Oracle Id))`, the state survives UB; choices are `Choice` requests checked against their constraints | as Deviations |
| `TerminationInfo` | `Deadlock`, `MemoryLeak`, `MachineStop` | `Outcome`: no deadlock (D17), no leak check (D21), `exit`; adds `noBehavior`, `stackOverflow`, `outOfFuel` | as Outcome.lean says |
| Concurrency, locks, Tree Borrows, `Atomicity` | present | absent | D16, D17 |
| Float, `char`, `fnDef`, `opaqueBytes` types | absent | present | D4, D5; `fnDef` and `opaqueBytes` are rustc types MiniRust lacks |
| `Downcast`, `Field`, `Index`, `Deref`, `aligned` | as specified | same (checked line by line against `lang/step/expressions.md`) | — |
| Integer ops, `Shl`/`Shr`, `Div`/`Rem`, unchecked ops, `with_overflow` | as specified | same results; `Shr` of negative values is floor division as in MiniRust's `Int >>` | — |

## 3. Documentation drift

Places where the docs say something the code no longer does (not fixed here; the plan text
is kept as written):

- mir-spec §A.3 says `IntPtrCast` has `exposed : Std.TreeSet AllocId`; it is a `List`.
- mir-spec §A.7 D5 says float operations are `opaque` with `@[implemented_by]` hardware
  functions; "Deviations during M1" supersedes it (exact arithmetic, `powi` included since
  R3 was fixed).
- mir-spec §A.7 D20 says other intrinsics go to their fallback body; the Lean code makes them
  `illFormed` and relies on the dump (§1).
- mir-spec §A.8 acceptance says every D-ID appears in the code; true in module headers, and
  with this change also as an inline `-- [Dn]` tag for all 36.
- `Mir/Behavior.lean` and mir-spec "Deviations" say `Behaviors` runs *sources* with a stack
  above the fuel; it does so for every program, targets included (assumptions.md §2).
