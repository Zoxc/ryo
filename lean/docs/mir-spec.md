# Part A. The MIR spec (L0)

The semantics of the MIR ryo compiles, concrete enough to execute directly: the source level
of every theorem ([plan.md](plan.md)). Implemented in `Ryo/Spec` (milestone M1). The text
below is the specification M1 implemented; the choices made while implementing it that differ
from the text are in [Deviations during M1](#deviations-during-m1) at the end, and the text
is not rewritten to match.

The semantic core is ported by hand from MiniRust
([github.com/minirust/minirust](https://github.com/minirust/minirust), pinned at commit
`d821c6e3`, 2026-07-27); file and section names below (`lang/step/*.md`, `tooling/…`) are
MiniRust's.

### A.1 Scope: which MIR

**Input language**: rustc **1.99.1** runtime MIR (`MirPhase::Runtime(Optimized)`) as ryo
reads it:

- monomorphized with `instantiate_mir_and_normalize_erasing_regions`
- after drop elaboration, so moves are explicit and `Drop` means "run the drop glue"
- every type concrete, every layout known

The reference is `rustc_middle/src/mir/syntax.rs` in the pinned toolchain's `rustc-dev`
sources (`lib/rustlib/rustc-src/rust/compiler/`, [build.md](../../design/build.md#toolchain)),
not a newer rustc checkout.

**In scope** (what [lowering.md](../../design/lowering.md) says ryo lowers to VM code or
islands):

- **Types**: integers `i8`…`i128`/`u8`…`u128`/`isize`/`usize`, `bool`, `char`, `f32`, `f64`
  (`f16`/`f128` only as opaque bits, see D5), raw pointers, references, `Box`, thin and wide
  (`[T]`, `str`, `dyn Trait`, and structs with unsized tails, including tails at
  vtable-aligned offsets), fn pointers, FnDef ZSTs, tuples/structs/closures (as tuples with
  rustc offsets), arrays, unions, enums (`Variants::Single`, `Multiple` with
  `TagEncoding::Direct` and `Niche`), `!`/uninhabited.
- **Statements**: `Assign`, `SetDiscriminant`, `StorageLive`, `StorageDead`,
  `Intrinsic(Assume | CopyNonOverlapping)`, `PlaceMention`. `FakeRead`, `AscribeUserType`,
  `Coverage`, `ConstEvalCounter`, `Nop` and `BackwardIncompatibleDropHint` are no-ops.
- **Places**: `Local` + projections `Deref`, `Field`, `Index`, `ConstantIndex`, `Subslice`,
  `Downcast`, `OpaqueCast`, `UnwrapUnsafeBinder`.
- **Operands**: `Copy`, `Move`, `Constant`, `RuntimeChecks`.
- **Rvalues** (all 13 of 1.99.1): `Use`, `Repeat`, `Ref`, `ThreadLocalRef`, `RawPtr`,
  `Cast` (all 12 `CastKind`s, all `PointerCoercion`s), `BinaryOp` (all 26 `BinOp`s),
  `UnaryOp` (`Not`, `Neg`, `PtrMetadata`), `Discriminant`, `Aggregate` (`Array`, `Tuple`,
  `Adt`, `Closure`, `RawPtr`), `CopyForDeref`, `WrapUnsafeBinder`, `Reborrow`.
- **Terminators**: `Goto`, `SwitchInt`, `UnwindResume`, `UnwindTerminate`, `Return`,
  `Unreachable`, `Drop`, `Call`, `TailCall`, `Assert`, with `UnwindAction`
  `Continue | Unreachable | Terminate(reason) | Cleanup(bb)`.
- **Intrinsics**: those listed in D20.
- **External calls**: any callee that isn't a body in the program (native functions, FFI,
  allocator shims) goes through the environment interface (§A.6).

**Out of scope** (ryo keeps these native, or they don't occur in runtime MIR): `InlineAsm`,
`Yield`, `CoroutineDrop`, `FalseEdge`, `FalseUnwind`, coroutines, C-variadic calls,
non-Rust-ABI function *definitions*, `unsized_fn_params`, extern types, SIMD *operations*
(SIMD values may appear as opaque byte blobs), `f16`/`f128` arithmetic, concurrency (D17),
aliasing models (D16).

### A.2 Design decisions

1. **MIR syntax, MiniRust semantic core.** Port MiniRust's *semantic domain*:
   - `prelude`, `mem/pointer`, `mem/interface`, `mem/basic`, `mem/intptrcast`
   - `lang/types`, `lang/values`, `lang/representation` and the type/value parts of
     `lang/well-formed`

   Do **not** port its expression syntax (`lang/syntax.md`): replace it by a Lean AST of
   rustc MIR. Port its step functions (`lang/step/*.md`, `lang/machine.md`) as the semantics
   of the corresponding MIR constructs. `minirust/tooling/minimize/src/*.rs` is MiniRust's
   own rustc-MIR → MiniRust translation, so it is the reference for what MiniRust thinks each
   MIR construct means: `bb.rs`, `rvalue.rs`, `enums.rs`, `ty.rs`, `constant.rs`,
   `vtable.rs`. Where minimize and rustc/LLVM disagree, rustc/LLVM wins (A.5).
   - *Why not port MiniRust syntax and translate MIR into it?* Then every proof about ryo's
     lowering would go through a second translation (MIR → MiniRust), with its own
     correctness question. ryo's input is MIR, its certificates name MIR locals and blocks,
     and the dump will be MIR.
2. **Layouts are input, not computed.** Every `Ty` carries rustc's layout: field offsets,
   size, alignment, scalar valid ranges, variant layouts, tag placement and encoding. These
   come from `tcx.layout_of` through the dump. MiniRust's types already embed offsets, so
   this extends MiniRust rather than departing from it. A well-formedness check (`WfTy`)
   validates internal consistency (fields inside the size, alignment powers of two, sized
   heads) but never recomputes rustc's choices. This makes "follow rustc's layout" true by
   construction, `-Zrandomize-layout` (which ryo rejects) included.
3. **One concrete memory model**: MiniRust `BasicMemory` (concrete addresses, per-allocation
   provenance, `AbstractByte`), plus `IntPtrCast` for exposed provenance. No
   `class Memory`: the abstraction costs proof effort and buys nothing here. Tree Borrows
   is not ported (D16).
4. **Single thread** (D17): no `ConcurrentMemory`, no data-race tracking, no `locks.md`.
5. **Values use mathematical `Int`**, as in MiniRust (`Value.int : Int → Value`), with
   bounds from the type. The x86 level uses `BitVec 64`. The bridge is
   `BitVec.ofInt`/`toInt`/`toNat` with `omega`/`bv_decide` lemmas.
6. **Non-determinism through an oracle class** (§A.4), so the same semantic functions are
   both an interpreter and a relation.
7. **Everything a rustc backend resolves is resolved in the input.** That covers callee
   instances, drop-glue instances, panic lang items for `Assert` and `UnwindTerminate`,
   vtable allocations, `RuntimeChecks` values, and caller-location constants. The spec
   doesn't do trait resolution. It gets `InstanceId`s with symbol names, exactly what ryo
   gets from `Instance::expect_resolve`.

### A.3 Files and modules

`lakefile.toml`:

```toml
name = "ryo"
version = "0.1.0"
defaultTargets = ["Ryo", "ryo-lean"]
testDriver = "RyoTest"

[leanOptions]
autoImplicit = false
relaxedAutoImplicit = false

[[lean_lib]]
name = "Ryo"

[[lean_lib]]
name = "RyoTest"
globs = ["RyoTest.+"]

[[lean_exe]]
name = "ryo-lean"
root = "Main"
```

`lean-toolchain`: `leanprover/lean4:v4.35.0`.

Modules (namespace `Ryo.Spec`), with the MiniRust source each one ports:

| Lean module | Ports (MiniRust) | Contents |
|---|---|---|
| `Ryo/Spec/Prelude/Basic.lean` | libspecr (`Int`, `Size`, `Align`, `List`, `Map`, `Name`) | `Size := Nat`, `Offset := Nat`, `Align` (power-of-two exponent), `Align.isAligned`, `alignTo`, maps as `Std.TreeMap` keyed by `Nat`-based ids, `Signedness`, `IntType` with `canRepresent`, `bringInBounds`, `min`/`max` |
| `Ryo/Spec/Prelude/Target.lean` | `prelude/target.md` | x86-64 only: `PTR_SIZE = 8`, `PTR_ALIGN = 8`, `INT_MAX_ALIGN = 16`, little endian, `MAX_ATOMIC_SIZE = 8`, `validSize` (≤ `isize::MAX`), `Endianness.encode/decode` |
| `Ryo/Spec/Prelude/Outcome.lean` | `prelude/main.md` (`TerminationInfo`) | `Outcome`: `ub (msg)`, `abort`, `exit (code)`, `illFormed (msg)`, `noBehavior` (a daemonic choice violated its constraint), `stackOverflow` (D25). No `Deadlock`, `MemoryLeak` |
| `Ryo/Spec/Prelude/Nondet.lean` | `prelude/main.md` (`Nondet`, `pick`, `predict`) | `Choice` requests, `MonadChoice`, `ExecM` (oracle-driven, executable), `SetM`/`Behaviors` (relational), §A.4 |
| `Ryo/Spec/Mem/Pointer.lean` | `mem/pointer.md` | `AllocId`, `Provenance := AllocId`, `ThinPointer`, `PointerMeta`, `Pointer`, `wrappingOffset`, `PointeeInfo`, `LayoutStrategy`, `PtrType`, `PointerMetaKind`, `TupleHeadLayout` |
| `Ryo/Spec/Mem/AbstractByte.lean` | `mem/interface.md` | `ProvenanceFrag`, `AbstractByte` (`uninit` / `init (b : UInt8) (frag : Option ProvenanceFrag)`), `AllocationKind` (+ `const`, `static`, D7) |
| `Ryo/Spec/Mem/Basic.lean` | `mem/basic.md` | `Allocation` (+ `mutable : Bool`, D7), `Memory`, `allocate` (address via `MonadChoice`; ZST rule D8), `deallocate`, `load`, `store`, `dereferenceable`, `signedDereferenceable`, `checkPtr` |
| `Ryo/Spec/Mem/IntPtrCast.lean` | `mem/intptrcast.md` | `exposed : Std.TreeSet AllocId`, `expose`, `ptrFromInt` (angelic `predict`) |
| `Ryo/Spec/Mem/Refine.lean` | `lang/representation.md` § Generic properties | `AbstractByte.leDefined`, `ThinPointer.leDefined`, lifted to lists, values and memories. Needed by every later simulation proof |
| `Ryo/Spec/Lang/Float.lean` | none (MiniRust has no floats) | D5: `FloatTy`, IEEE ops as opaque functions on `BitVec`, NaN-nondeterminism wrapper, `as` conversions |
| `Ryo/Spec/Lang/Types.lean` | `lang/types.md`, `minimize/src/ty.rs`, `minimize/src/enums.rs` | `Ty` with rustc layout data (§A.5 sketch), `ValidRange`, `TagInfo`, `TagEncoding`, `Variant`, `Ty.layout`, `Ty.metaKind`, `sizeOf`/`alignOf`, `computeSize`/`computeAlign` for unsized types (from metadata, D29) |
| `Ryo/Spec/Lang/Values.lean` | `lang/values.md` | `Value` (+ `float`, D5), `Place` (`ptr`, `aligned`) |
| `Ryo/Spec/Lang/Representation.lean` | `lang/representation.md` | `Ty.decode`, `Ty.encode`, `checkValue` (well-formed values, incl. safe pointers dereferenceable and aligned), `typedLoad`, `typedStore`, `transmute`; enums decoded through rustc's tag algorithm (D2) |
| `Ryo/Spec/Lang/WellFormed.lean` | `lang/well-formed.md` (types/layouts part) | `WfTy`, `WfValue` |
| `Ryo/Spec/Mir/Syntax.lean` | `lang/syntax.md` (replaced), rustc `mir/syntax.rs` | the MIR AST (§A.5), `Body`, `Program`, `InstanceId`, `Global` (const and static allocations with relocations), `VTable` as an allocation (D29). `deriving Repr, BEq, Inhabited, Lean.FromJson, Lean.ToJson` (hand-write instances where deriving fails on nested/mutual types) |
| `Ryo/Spec/Mir/WellFormed.lean` | `lang/well-formed.md` (expr/fn/program part) | local/block indices in range, operand types match, `SwitchInt` on integer/bool/char, unwind-action well-formedness (cleanup blocks only reached by unwinding), `always_storage_live_locals` |
| `Ryo/Spec/Mir/State.lean` | `lang/machine.md` | `Frame`, `State`, `Event`, `CallReturn` (`ret` / `unwind`), global address maps |
| `Ryo/Spec/Mir/Place.lean` | `lang/step/expressions.md` § Place Expressions | `evalPlace` with every projection, including `Index` bounds UB, `Subslice`/`ConstantIndex from_end`, `Deref` of wide pointers, unsized-tail field offsets rounded up from the vtable's alignment (cg_ssa's `project_field`) |
| `Ryo/Spec/Mir/Operand.lean` | `lang/step/expressions.md` § Constants, Load | `evalOperand` (`Copy`/`Move` = typed load, D12), `evalConst` (scalars, `ConstValue::Slice`/indirect, D7, D24), `RuntimeChecks` (D23) |
| `Ryo/Spec/Mir/Ops.lean` | `lang/step/operators.md` | `evalBinOp` (D10), `evalUnOp`, pointer compares (D10), `Offset` |
| `Ryo/Spec/Mir/Cast.lean` | `operators.md` § Casts, `minimize/src/rvalue.rs` | all `CastKind`s and `PointerCoercion`s (D11, D30, D33–D35) |
| `Ryo/Spec/Mir/Rvalue.lean` | `expressions.md` (Tuple, Union, Variant, AddrOf, GetDiscriminant) | `evalRvalue`: `Repeat`, `Ref`/`RawPtr`/`Reborrow`, `ThreadLocalRef`, `Discriminant` (D28), `Aggregate` (D32), `PtrMetadata` |
| `Ryo/Spec/Mir/Statement.lean` | `lang/step/statements.md` | `Assign` (evaluate the place first, then the rvalue, as Miri does), `SetDiscriminant`, storage (D9), `CopyNonOverlapping`, `Assume` |
| `Ryo/Spec/Mir/Call.lean` | `lang/step/terminators.md` § Call, Return | frame creation, argument passing (by value / in place, D12), `rust-call` spread, `#[track_caller]` location (D14), ABI-compatibility UB (D14), return-place handling, entry/return validation (D15), `TailCall` |
| `Ryo/Spec/Mir/Unwind.lean` | `terminators.md` § unwinding (replaced) | D18: `UnwindAction` semantics, `UnwindResume`, `UnwindTerminate`, cleanup-block discipline, `catch_unwind` |
| `Ryo/Spec/Mir/Terminator.lean` | `lang/step/terminators.md` | `Goto`, `SwitchInt`, `Return`, `Unreachable`, `Drop` (D19), `Assert` (D19), dispatch to Call/Unwind |
| `Ryo/Spec/Mir/Intrinsics.lean` | `lang/step/intrinsics.md` | the D20 set, each with rustc's UB conditions |
| `Ryo/Spec/Mir/External.lean` | none (MiniRust programs are closed) | the environment interface (§A.6): `ExtCall`, `ExtSpec`, built-in shims for the interpreter (`__rust_alloc`, `__rust_dealloc`, `__rust_realloc`, `write`, `exit`, `abort`) |
| `Ryo/Spec/Mir/Step.lean` | `lang/machine.md` (`step`) | `step : Program → State → M (Option Event)` |
| `Ryo/Spec/Mir/Behavior.lean` | none | traces, `Behavior` (`terminates`, `diverges`, `goesWrong (ub)`, `aborts`), `Refines` (with D25), angelic handling (§A.4) |
| `Ryo/Spec/Mir/Interp.lean` | MiniRust's `minirun` | `run (fuel) (oracle) : Program → Except Outcome (List Event × Int)` |
| `Ryo/Spec/Mir/Builder.lean` | `tooling/miniutil/src/build` | a small DSL to write MIR programs in Lean for tests |
| `Ryo/Spec/Mir/Json.lean` | none | dump schema. The derived `FromJson` instances are the schema. The backend writer (`RYO_DUMP_LEAN`) comes in M1b |
| `Ryo/Spec/Theorems/*.lean` | `representation.md` § Generic properties | `encode_length`, `decode_encode` for well-formed values, `decode_mono` (more-defined bytes decode to a more-defined value or the same failure), `store_load` |
| `RyoTest/*.lean` | `tooling/minitest/src/tests/*.rs` | ports of: `int`, `bool`, `align`, `zst`, `locals`, `switch`, `call`, `return_`, `unreachable`, `assume`, `null`, `ptr`, `ptr_offset`, `ptr_offset_from`, `negative_index`, `expose`, `uninit_read`, `no_preserve_padding`, `no_preserve_prov`, `dereferenceable`, `packed`, `enum_discriminant`, `enum_downcast`, `enum_representation`, `wide_ptr`, `slice`, `unsized_struct`, `compute_size`, `compute_align`, `trait_object` (adapted to D29), `unwinding`, `catch_unwind`, `raw_eq`, `place_mention`. Skip `data_race`, `concurrency`, `locks`, `spawn_join`, `atomic*` beyond single-thread, `heap_intrinsics` (heap is external here), `print`, `calling_convention` (redo for D14) |

### A.4 Non-determinism and behaviors

MiniRust uses `pick` (daemonic) for allocation addresses and `predict` (angelic) for
exposed provenance. The spec adds daemonic choices for NaN payloads (D5), for constant and
vtable copies (D7) and fn addresses (D6), and for `ptr_guaranteed_cmp` (D20).

- Write the semantics against a class, so the same code runs and specifies:

  ```lean
  inductive ChoiceKind | daemonic | angelic
  /-- A choice point: what is asked, and how the semantics checks the answer. -/
  inductive Choice where
    | allocAddr (size : Size) (align : Align)       -- daemonic; checked by Memory.allocate
    | exposedProv (addr : Nat)                      -- angelic; answer: Option AllocId
    | nanBits (fmt : FloatTy) (candidates : List Nat)
    | constCopy (g : GlobalId)                      -- which copy of a const allocation
    | fnAddr (i : InstanceId)
    | guaranteedCmp
  class MonadChoice (m : Type → Type) where
    choose : (c : Choice) → m (Choice.Answer c)
  ```

- The semantics **checks** each answer. A daemonic answer that violates its constraint yields
  `Outcome.noBehavior`, which is not a behavior. An angelic answer that leads to UB is
  handled in `Behaviors`.
- `ExecM := StateT State (ExceptT Outcome (ReaderT Oracle Id))` with a concrete oracle:
  - addresses from a bump allocator that respects alignment and non-overlap
  - exposed provenance: the live exposed allocation containing the address, as Miri does
  - NaN: the canonical quiet NaN
  - consts: the first copy
- Behaviors (in `Behavior.lean`): quantify over daemonic oracles. A UB outcome counts only if,
  for the same daemonic answers, **every** angelic alternative also goes wrong. This is
  MiniRust's intent for `predict`. The executable interpreter is sound for this: any run it
  produces without UB is a behavior. A UB it reports can be spurious for int-to-ptr
  programs, as with Miri.
- `Refines (tgt src : Program) : Prop`: every target behavior is a source behavior, or the
  source can go wrong on a prefix of it, or (D25) it is a prefix followed by
  `stackOverflow`. Event traces contain external calls (callee, arguments, returned value),
  their memory effects being part of the convention (§A.6), and exit/abort.

### A.5 Key definitions (sketches; the agent fills in details)

```lean
namespace Ryo.Spec

structure IntType where
  signed : Bool
  size : Size                      -- 1, 2, 4, 8, 16
deriving DecidableEq, Repr, Lean.FromJson, Lean.ToJson

/-- rustc's `WrappingRange` (`start ..= end`, may wrap), on the scalar's bits. -/
structure ValidRange where
  start : Nat
  stop : Nat

inductive TagEncoding where
  | direct
  /-- rustc `TagEncoding::Niche`: variants in `nicheVariants` (inclusive) are encoded as
  `nicheStart + (v - nicheVariants.lo)`, wrapping, in the tag; anything else decodes to
  `untagged`. -/
  | niche (untagged : Nat) (lo hi : Nat) (nicheStart : Nat)

structure TagInfo where
  offset : Offset
  tag : IntType
  valid : ValidRange
  encoding : TagEncoding

mutual
inductive Ty where
  | int (t : IntType) (valid : ValidRange)
  | bool
  | char
  | float (f : FloatTy)
  | ptr (p : PtrType) (valid : ValidRange)       -- `NonNull`: start = 1
  | fnDef (i : InstanceId)                       -- ZST
  | tuple (fields : List (Offset × Ty)) (head : TupleHeadLayout) (tail : Option Ty)
  | array (elem : Ty) (count : Nat)
  | slice (elem : Ty)                            -- `str` is `slice u8` + UTF-8 not checked
  | union (fields : List (Offset × Ty)) (chunks : List (Offset × Size)) (size : Size) (align : Align)
  | enum (variants : List Variant) (discrTy : IntType) (tag : Option TagInfo)
      (size : Size) (align : Align)              -- `!`: no variants
  | traitObject (t : TraitName)
  | opaque (size : Size) (align : Align)         -- SIMD vectors, f16/f128: bytes only
structure Variant where
  discr : Int                                    -- discriminant value (rustc `discr_for_variant`)
  fields : Ty                                    -- a `tuple` with rustc offsets
  inhabited : Bool
end

inductive Value where
  | int (i : Int) | bool (b : Bool) | float (f : FloatTy) (bits : Nat)
  | ptr (p : Pointer)
  | tuple (vs : List Value)
  | variant (idx : Nat) (data : Value)          -- idx: VariantIdx
  | union (chunks : List (List AbstractByte))

/-- Runtime MIR, monomorphized. Indices are `Nat` (`Local`, `BasicBlock`, `FieldIdx`,
`VariantIdx`). -/
inductive ProjElem where
  | deref | field (f : Nat) (ty : Ty) | index (l : Local)
  | constantIndex (offset minLen : Nat) (fromEnd : Bool)
  | subslice (fr to : Nat) (fromEnd : Bool)
  | downcast (v : Nat) | opaqueCast (ty : Ty) | unwrapUnsafeBinder (ty : Ty)
structure MPlace where
  base : Local        -- `local` is a Lean keyword
  proj : List ProjElem
inductive Operand where
  | copy (p : MPlace) | move (p : MPlace) | const (c : ConstOperand) (ty : Ty)
  | runtimeChecks (k : RuntimeCheck) (value : Bool)          -- D23
inductive Rvalue where
  | use (o : Operand) | repeat (o : Operand) (n : Nat)
  | ref (mutbl : Bool) (p : MPlace) | rawPtr (mutbl : Bool) (p : MPlace)
  | threadLocalRef (s : StaticId) | cast (k : CastKind) (o : Operand) (ty : Ty)
  | binaryOp (op : BinOp) (a b : Operand) | unaryOp (op : UnOp) (a : Operand)
  | discriminant (p : MPlace) | aggregate (k : AggregateKind) (ops : List Operand)
  | copyForDeref (p : MPlace) | wrapUnsafeBinder (o : Operand) (ty : Ty)
  | reborrow (ty : Ty) (mutbl : Bool) (p : MPlace)
inductive Callee where
  | instance (i : InstanceId)          -- resolved FnDef: a body, an extern, or an intrinsic
  | fnPtr (o : Operand)
  | virtual (i : InstanceId) (idx : Nat) -- vtable slot `idx` (D29)
inductive Terminator where
  | goto (bb : BasicBlock)
  | switchInt (d : Operand) (cases : List (Nat × BasicBlock)) (otherwise : BasicBlock)
  | unwindResume | unwindTerminate (r : TerminateReason)
  | return_ | unreachable
  | drop (p : MPlace) (glue : Option InstanceId) (target : BasicBlock) (unwind : UnwindAction)
  | call (f : Callee) (args : List Operand) (dest : MPlace) (target : Option BasicBlock)
      (unwind : UnwindAction) (callerLocation : Option ConstOperand)
  | tailCall (f : Callee) (args : List Operand) (callerLocation : Option ConstOperand)
  | assert (cond : Operand) (expected : Bool) (msg : AssertMessage) (target : BasicBlock)
      (unwind : UnwindAction)          -- msg carries the panic lang-item instance + operands
structure Body where
  inst : InstanceId
  locals : Array Ty            -- `_0` first, then args, then the rest
  argCount : Nat
  spreadArg : Option Local
  trackCaller : Bool
  abi : FnAbiSummary           -- calling convention, per-arg PassMode kind (for D14 only)
  blocks : Array BasicBlock    -- each: statements, terminator, isCleanup
```

`State`: a stack of `Frame`s, each with:

- `body`
- `locals : Std.TreeMap Local ThinPointer`: the live ones
- `pc : BasicBlock × Nat`
- the caller's return place and continuation (`target`, `unwind`)
- the caller location, for `#[track_caller]` bodies

plus `mem`, `exposed`, the global address maps, and an `unwinding : Option Payload` mode
flag.

### A.6 The environment (external calls)

A call whose callee has no body in the `Program` (native function, FFI, other crate's
non-dumped code) is an **external call** event:

```lean
structure ExtCall where
  callee : Symbol
  args : List (Value × Ty)
  retTy : Ty
inductive ExtResult | ret (v : Value) | unwind (payload : Payload)
```

Relationally, `ExtSpec` constrains the memory after the call, as CompCert's `extcall`
properties do:

- allocations the program never exposed and that the callee could not reach are unchanged
  (reachability: through pointer arguments, exposed provenance, globals)
- deallocations only of reachable heap allocations
- fresh allocations allowed

The interpreter implements a few shims (the allocator symbols, `write` to fd 1/2, `exit`,
`abort`) and fails on others. That is enough to run test programs whose `std` paths bottom
out in these, and to run single functions with given arguments.

### A.7 Divergences from MiniRust (follow rustc/LLVM)

Every divergence gets an ID. The Lean code cites it as `-- [Dn]` where it applies, so the
list can be audited against the code.

| ID | Topic | MiniRust | rustc / LLVM (what ryo must match) | Spec choice |
|---|---|---|---|---|
| D1 | Syntax | own expression AST | runtime MIR (1.99.1) | MIR AST (§A.5); MiniRust semantics per construct |
| D2 | Layout | offsets in types; enum `Discriminator` decision tree + `tagger` | `layout_of`: offsets, field order chosen by niches, `TagEncoding::{Direct, Niche}`, tag field | layouts are input. Enum tag read/write implements rustc's algorithm (cg_ssa `codegen_get_discr`/`codegen_set_discr`; ryo's `discr.niche`/`set_discr.niche`) directly, not a decision tree |
| D3 | Scalar validity | per type only (bool 0/1, refs non-null…) | `Scalar::valid_range` (`NonZero*`, `NonNull`, `char`, niche-carrying enums), emitted as LLVM `range`/`nonnull` | `ValidRange` on `int`/`ptr`/tags. Decoding a scalar outside it is UB (typed load, call/return validation) |
| D4 | `char` | absent | `u32` with valid range `0..=0x10FFFF`; surrogates invalid per Rust (Miri) | `Ty.char`: UB on load if not a Unicode scalar value |
| D5 | Floats | absent | IEEE binary32/64. NaN payloads non-deterministic (RFC 3514: arithmetic NaN results pick a payload from a specified set). `as` float→int saturates, NaN→0. `min`/`max` per `f*::min`/`max`. `f16`/`f128` exist | `Value.float fmt bits`. Ops are `opaque` functions on `BitVec` (`@[implemented_by]` hardware `Float32`/`Float` for execution), NaN results replaced by a daemonic choice over RFC 3514's set. `f16`/`f128` values are bits only, and their arithmetic is out of scope |
| D6 | Fn pointers | function "allocations" with unique addresses | functions may be merged (`unnamed_addr`) or duplicated (one instance per crate copy) | `ReifyFnPointer` address: daemonic choice per instance; fn-pointer equality not guaranteed |
| D7 | Const allocations, statics | globals unique and mutable | consts and promoted allocations have no unique address (ryo copies them into each image's pool, and vtables too). Consts and immutable statics without `UnsafeCell` are read-only (ryo: RELRO) | daemonic choice of copy per evaluation of a const. Statics unique. `Allocation.mutable = false` for consts and immutable statics: a write is UB |
| D8 | ZST allocations | equal addresses count as overlap | zero-size allocas may coincide; ryo gives ZST locals no space | `allocate` with size 0: any aligned non-null address, no overlap constraint |
| D9 | Storage | `StorageLive`/`Dead` (same as rustc) | locals without any storage statement are live for the whole call (`always_storage_live_locals`); `StorageLive` of a live local reallocates; `StorageDead` of a dead one is a no-op | same, plus the always-live rule at frame creation |
| D10 | Binary ops | `Shl`/`Shr` mask; `*WithOverflow` result type synthesized | `Add`/`Sub`/`Mul` wrap; `*Unchecked` UB on overflow; `*WithOverflow` returns `(T, bool)` **at the destination's rustc layout**; `Div`/`Rem` UB on 0 and `MIN/-1`; `Shl`/`Shr` RHS is any integer type, shift by `rhs.rem_euclid(bits)`; `Cmp` returns `Ordering` (i8 enum); `Offset` is `ptr.offset` (inbounds, count × pointee size, product must fit `isize`); `BitAnd`/`BitOr`/`BitXor`/`Not` on `bool`; `Eq`…`Ge` on raw pointers compare addresses, wide pointers lexicographically (address, then metadata), and fn pointers are comparable | as listed |
| D11 | Ptr ↔ int | `expose`, angelic `PointerWithExposedProvenance`; transmutes strip / lack provenance | same (current Rust rules) | keep MiniRust |
| D12 | `Move`, call arguments | `ArgumentExpr::InPlace` for in-place args | `Move` has no effect except in call arguments, which may be passed in place: after the call the place is unspecified. The return place is de-initialized while the call runs (Miri) | `Move` = `Copy` outside calls. `Move` call args: in-place (callee frame aliases the caller's place), caller's place `Uninit` after return. Destination `Uninit` at call start, written at return |
| D13 | Uninit scalars | UB to decode `Uninit` as int/bool/ptr | same (`noundef`) | keep. Padding resets to `Uninit` on typed copies (MiniRust) |
| D14 | Calls, ABI | structural `check_abi_compatibility`; `CallingConvention::{Rust, C}` | rustc's documented ABI-compatibility rules (`repr(transparent)`, `Option<&T>` ~ `*const T`, same-size integers of either signedness are *not* compatible, …), as `fn_abi` realizes them. `rust-call` spreads the tuple. `#[track_caller]` adds a hidden `&'static Location` argument | UB when caller and callee types are ABI-incompatible by rustc's rules (implemented on the `FnAbiSummary` the dump provides). `Body.trackCaller` + call terminator's `callerLocation` model the hidden argument, and the `caller_location` intrinsic reads it |
| D15 | Validity at call boundaries | `Validate { fn_entry }` inserted by minimize | LLVM argument and return attributes (`noundef`, `nonnull`, `dereferenceable(n)`, `align`, `range`) | `checkValue` on arguments at entry and on the return value at `Return`. No retagging |
| D16 | Aliasing | Tree Borrows available | LLVM `noalias`/`readonly` only on native code | basic memory only. A semantics with less UB makes ryo's theorem stronger, and neither ryo's AOT code nor (initially) the JIT exploits aliasing. Revisit if JIT optimizations want `noalias` |
| D17 | Threads, atomics | threads, data-race detection, locks | native atomics; threads are external (std → pthreads) | single-threaded. Atomics are plain accesses with size ≤ 8, natural alignment required (UB otherwise), RMW/CAS computed sequentially, orderings ignored. Fences: no-ops |
| D18 | Unwinding | `StartUnwind`/`StopUnwind`/`ResumeUnwind`, payload stack, catch blocks | MIR `UnwindAction` per call, `UnwindResume`, `UnwindTerminate`, cleanup blocks. Unwinding starts only in callees (panic runtime: external). `catch_unwind` intrinsic | a call result is `ret v` or `unwind payload` (opaque). `Continue`: propagate. `Cleanup bb`: run the cleanup block in unwinding mode. `Unreachable`: UB. `Terminate r`: call `r`'s lang item (`panic_cannot_unwind`/`panic_in_cleanup`), which doesn't return. `UnwindResume`: propagate. `catch_unwind(try, data, catch)`: call `try(data)`, on unwind call `catch(data, payload)`, result 1 |
| D19 | `Assert`, `Drop` | (minimize: assert → call panic fn, drop → `drop_in_place`) | cg_ssa: failed `Assert` calls the `AssertKind`'s panic lang item with its operands (and caller location). `Drop` calls the drop-glue instance (nothing if no glue). Unsized places pass the wide pointer | exactly so, with the resolved instances from the dump |
| D20 | Intrinsics | a small own set (`Abort`, `Assume`, `Allocate`, …) | rustc intrinsics with their documented UB | `assume` (UB if false), `unreachable` (UB), `abort`, `black_box`/`likely`/`unlikely`/`cold_path` (identity), `ctpop`, `ctlz`/`cttz` (`_nonzero` UB on 0), `bswap`, `bitreverse`, `rotate_left`/`right`, `unchecked_funnel_shl`/`shr`, `exact_div`, `disjoint_bitor`, `unchecked_*`, `ptr_offset_from(_unsigned)`, `arith_offset`, `copy`, `copy_nonoverlapping` (UB on overlap), `write_bytes`, `typed_swap_nonoverlapping`, `size_of_val`, `align_of_val`, `vtable_size`, `vtable_align`, `ptr_guaranteed_cmp` (daemonic: exact answer or 2), `volatile_*` and `nontemporal_store` (as plain accesses), atomics (D17), `fabs`, `copysign`, `minimum_number_nsz`/`maximum_number_nsz`, `caller_location`, `raw_eq`, `compare_bytes`, `catch_unwind`, the `sqrt`/`powi`/`fma` wrappers (D5), saturating/`as` float casts. Any other intrinsic: external call to its fallback body if one exists, else ill-formed (function out of scope) |
| D21 | Heap | `Allocate`/`Deallocate` intrinsics | heap is `__rust_alloc` & co., native allocator shim | external calls (§A.6); interpreter shims allocate `Heap` allocations |
| D22 | Thread locals | absent | `ThreadLocalRef` → the current thread's instance | one allocation per thread-local static (single thread) |
| D23 | `RuntimeChecks` | absent | the session's `ub_checks`/`contract_checks`/`overflow_checks` | constant `Bool` in the operand |
| D24 | Type ids | absent | `GlobalAlloc::TypeId` pointers: base 0, the offset is the hash | a pointer without provenance, address = offset |
| D25 | Resource exhaustion | OOM is "no behavior" | stack overflow aborts (guard page); large frames probe | `Refines` allows any target trace prefix followed by `stackOverflow` at a call |
| D26 | Addresses | `(0, 2^64)` | user space is smaller | keep MiniRust (the target's choices are a subset) |
| D27 | 128-bit ints | same | same (ryo uses islands for some ops) | no divergence; noted because the VM splits them |
| D28 | `Discriminant` / `SetDiscriminant` | `GetDiscriminant`: UB on invalid tag | rustc decode by `TagEncoding` (D2); `Variants::Single` gives a constant; `SetDiscriminant` writes the tag only (niche: nothing for the untagged variant) | rustc's algorithms. Invalid tag on read: UB |
| D29 | Vtables, `dyn` | abstract `VTable` (`methods` map), `VTableMethodLookup` | vtables are constant allocations with layout `[drop_in_place, size, align, entries…]` of 8-byte words; virtual calls load entry `idx` from memory; `size_of_val`/`align_of_val` read them; upcasts use supertrait entries | vtables as `Global` allocations from rustc's `vtable_allocation`. `Callee.virtual` loads the entry from memory and calls the fn pointer. Metadata is a vtable *pointer* |
| D30 | Unsizing | `ConstructWidePointer` | `PointerCoercion::Unsize`: pointer → wide (constant length or vtable address); structs (`Box`, `Rc`, …) field by field (`CoerceUnsized`), as cg_ssa | as rustc |
| D31 | `Repeat` | n/a | the operand's value repeated `n` times | typed copy per element |
| D32 | `Aggregate` | `Tuple`/`Variant` exprs | fields stored, then `SetDiscriminant`; `RawPtr` aggregate builds a (wide) pointer from data + metadata | as rustc (result = encoding of the variant value at the place) |
| D33 | `Transmute` | UB if sizes differ; result must be valid | MIR guarantees equal sizes; invalid result UB | keep MiniRust |
| D34 | Numeric `as` | int-to-int only | `FloatToInt` saturating (NaN → 0); `IntToFloat`/`FloatToFloat` round to nearest even | as rustc, via D5's opaque ops |
| D35 | Pointer casts | `PtrToPtr` same meta kind | `PtrToPtr` wide → thin drops metadata; `FnPtrToPtr`, `PointerCoercion::{ReifyFnPointer, ClosureFnPointer, UnsafeFnPointer, MutToConstPointer, ArrayToPointer}`; `Subtype`, `BoxDerefTransmute` | as rustc |
| D36 | Packed / unaligned places | `Place.aligned` | same idea (`repr(packed)` fields) | keep MiniRust |

### A.8 Order of work for the MIR-spec agent

1. `lean/lean-toolchain`, `lean/lakefile.toml`, `Ryo.lean`, `Main.lean` (prints usage),
   `RyoTest.lean`. `lake build` and `lake test` run (empty).
2. Prelude → Mem → Lang (types, values, representation): port MiniRust section by section.
   Make `decode`/`encode` total, with `Option` results (MiniRust `panic!` = spec bug → return
   `illFormed`).
3. Theorems: `encode_length`, `decode_encode` (well-formed values), `decode_mono`. They
   validate the port. Proving them *now* is cheap, and every later proof needs them.
4. MIR syntax + well-formedness + `FromJson`/`ToJson` derivations.
5. Semantics: places, operands, ops, casts, rvalues, statements, terminators, calls, unwind,
   intrinsics, step, interpreter.
6. Builder DSL + tests (ported minitest cases from the table above, plus tests for each
   divergence D1–D36 that has run-time effects).
7. `Behavior.lean`: behaviors and refinement, stated; proofs come later.

**Acceptance for M1:**

- `lake build` succeeds with no `sorry` in `Ryo.Spec` outside `Ryo/Spec/Theorems` (which
  tracks its open goals in a list).
- `lake test` passes.
- Every D-ID appears in the code.
- `lake exe ryo-lean run <file.json>` interprets a JSON program built with the DSL (`ToJson`
  round trip).

No ryo Rust code changes in M1. The backend dumper is M1b.

---

## Deviations during M1

Choices made while implementing part A (`Ryo/Spec`, see [README.md](../README.md)); the
text above is not rewritten to match.

- **Project**: `testDriver` is an executable (`ryotest`, root `RyoTestMain.lean`) instead of
  the `RyoTest` library, so tests run the interpreter at run time; Lake 4.35 does not accept a
  hyphenated exe name there. The `RyoTest` library globs include the root module.
- **Lean keywords**: `meta` is a keyword in Lean 4.35, so `Pointer.metadata`; `opaque` →
  `Ty.opaqueBytes`.
- **Non-determinism (§A.4)**: one concrete monad, `SemM := ExceptT Outcome (StateT State
  (ReaderT Oracle Id))`, instead of class-polymorphic code plus a separate `SetM`. The oracle
  answers `(choice index, choice, state)`, so quantifying over oracles (`Behavior.lean`) gives
  the relational semantics. `MonadChoice` exists and `Memory.allocate`/`ptrFromInt` are
  written against it. `ExceptT` is outside `StateT` so the event trace survives UB.
  `constCopy`/`fnAddr` choices carry the number of existing copies (answer `< n` reuses one).
- **Floats (D5)**: exact arithmetic on `Nat`/`Int` (exact result, then round to nearest even)
  instead of opaque hardware functions (`powi` is compiler-rt's `__powidf2` loop); hardware
  `Float` is used only to cross-check in tests. Works for every `FloatTy`.
- **Types (§A.5)**: `Ty` is a nested, non-mutual inductive (variants are `VariantOf Ty`) so
  that structural recursion works. Enums use `EnumRepr.{empty, single idx, multiple tag}`
  (rustc `Variants`) instead of `tag : Option TagInfo`. `PtrType.raw` carries pointee info
  (for `Offset`/`ptr_offset_from` scaling). Addresses are `Nat < 2^64`.
- **MIR AST**: `ProjElem.deref` carries the pointee type (pointer types only carry pointee
  layouts, to keep recursive types finite). `reifyFnPointer`/`closureFnPointer` carry the
  resolved instance, `unsize` carries `UnsizeMeta` (length, vtable global, or upcast word).
  `Callee.virtual idx` has no instance. Calls carry the caller's `FnAbiSummary` and a
  `CallerLoc` (`const` or `inherit`, for `#[track_caller]` forwarding). Terminate lang items
  are `Program.langItems`.
- **Calls (D12, D14, D15)**: in-place (`Move`) arguments and the return place alias the
  caller's memory (callee locals not deallocated); `Move` places are de-initialized after
  the call; the destination is de-initialized at the call. Tail-call arguments are by value
  and tail calls must target bodies. ABI compatibility is Miri's `check_argument_compat` on
  `Ty` (transparent wrappers are recognized structurally: one non-1-ZST field covering the
  struct; NPO enums as their pointer), plus equality of `FnAbiSummary`s when both sides have
  one. Entry validation is a typed load of each argument local at the callee's type.
- **Unwinding (D18)**: the payload is the exception-object pointer. Unwinding starts in the
  external `_Unwind_RaiseException` shim. `UnwindAction::Continue` marks the caller frame
  (`pendingUnwind`) and the next step pops it, so `step` stays non-recursive. Unwinding out of
  the start function ends the run (`Final.unwound`) instead of UB (needed to run single
  functions).
- **Globals (D7)**: statics are allocated on first use (still unique); constants are evaluated
  by encoding their bytes and decoding at the operand type.
- **Runs**: the start function is called with arguments and its return ends the run (MiniRust
  requires `exit`). MIR well-formedness (`Mir/WellFormed.lean`) is checked before running;
  it does not yet type-check rvalues against destinations. `Value`s of `opaqueBytes` are
  `Value.union [bytes]`.
- **Refine/Behavior**: the value order lives in `Lang/Values.lean` (values come after memory).
  `Behaviors` runs sources with a stack limit above the fuel, so sources never overflow;
  `ExtSpec` is stated but the semantics uses the interpreter's shims.
- **Tests**: MiniRust's `print` is the `ryo_test_print` shim; MiniRust-specific
  ill-formedness tests (discriminator trees, `Validate`, threads) are not ported.
- **Citations**: each module header lists its MiniRust source and D-IDs; definitions carry
  `-- [Dn]` markers.
