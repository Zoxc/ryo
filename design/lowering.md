# Lowering: MIR → machine code

Each VM function is lowered on its own (in parallel, [backend.md](backend.md#pipeline))
straight into machine code plus a relocation list. The lowering decides VM instructions
([instructions.md](instructions.md)) and hands each to the assembler `asm::Asm` as an opcode and
typed operands, which appends its x86 sequence at once ([vm.md](vm.md#machine-code)); there
are no instruction words in between. Branch targets are labels (one per block, landing pad
and terminate stub), unwind actions are set on the call-like instructions, and when the
frame size is known `Asm::finish` resolves slots to frame offsets, lays out the code and
writes it.

The entry point is `lower(tcx, cx, instance) -> Result<LoweredFn, NeedsNative>`
(`backend/src/lower/mod.rs`), where `cx: LowerCx` holds the set of functions
assumed to be VM functions of this image (a call of one of them is a `call`, any other local
callee an island). A `LoweredFn` holds:

- the machine code (`asm::Encoded`: code bytes, relocations, code constants, LSDA call
  sites), whose `func`, `sym`, `k` and `data` operands are indices into the
  relocation list
- the relocation list, which the merge pass resolves once every function's index and symbol
  is known, by rewriting the code's relocation targets (the code bytes aren't touched):
  - `Call { callee }`: a `call` / `tail_call` to another VM function of this image (its
    function index)
  - `Symbol { target }`: a `sym` operand, the target's symbol (a VM function's then becomes
    global, [backend.md](backend.md#pipeline); an internal native item is made visible to
    the image). On PE an import's slot is indirect, so the lowering emits `addr.sym.ind` /
    `call.sym.ind` for it
  - `Static { def_id }`: a `sym` operand naming a static
  - `Const { alloc, offset }`: a `k` operand, `offset` bytes into the pool copy of an
    allocation
  - `Bytes { bytes, align }`: a `k` operand, a pool allocation of raw bytes (`fill`
    elements)
  - `Data { alloc, offset }`: a `data` operand, `offset` bytes into the fixup-area copy of
    an allocation (PE, [Constants](#constants))
  - `Island { template, args }`: an `isl` operand, the island template instance
    (diagnostic item name and generic args)
- `frame_size`, `arg_size` and `ret_size`

`NeedsNative(reason)` keeps the function native as a whole. `RYO_STATS=2` prints the reasons
([backend.md](backend.md#debugging-switches)).

A `#[target_feature]` function is lowered like any other if every feature it enables is
already enabled for the crate (`sess.internal_target_features`, which includes implied and
`-C target-cpu`/`-C target-feature` features: on default x86_64 `sse2`, so stdarch's SSE2
`_mm_*` functions): the attribute then changes nothing about its code. Its ABI is no reason
to keep it native, since the Rust ABI passes vectors indirectly whatever the features
(`rustc_target/src/callconv/mod.rs`, #44367), and other ABIs stay native anyway. Its body is
checked like every body: an `llvm.*` link or inline asm keeps it native, and so does a
`simd_*` intrinsic without an instruction ([SIMD](#simd)), which elsewhere is an island
compiled without the features. So it is VM code only if all of it maps. A function with
features the crate doesn't enable (`avx2` in memchr) stays native. Such fn items don't
implement the `Fn*` traits, so they never go through the `call` island
([Calls](#calls)).

The lowering matches every MIR enum (`StatementKind`, `Rvalue`, `Operand`, `ProjectionElem`,
`CastKind`, `BinOp`, `UnOp`, `TerminatorKind`, `AssertKind`, …) exhaustively, with no `_` arm,
so a MIR change in a toolchain bump is a compile error. The tables below follow 1.99.1
(`rustc_middle/src/mir/syntax.rs`).

## Input

- `tcx.instance_mir(instance.def)`, monomorphized with
  `instance.instantiate_mir_and_normalize_erasing_regions`, as cg_ssa does. Every
  `InstanceKind` that has a body is lowered the same way: `Item` and every
  `Shim(ShimKind)`: `VTable`, `Reify`, `FnPtr`, `ClosureOnce`,
  `ConstructCoroutineInClosure`, `ThreadLocal`, `FutureDropPoll`, `DropGlue`, `Clone`,
  `FnPtrAddr`, `AsyncDropGlueCtor`, `AsyncDropGlue` (`rustc_middle/src/ty/instance.rs:62-190`).
- Layouts come from `tcx.layout_of`. Every type is concrete, so every size, offset and
  discriminant encoding is known at lowering time, and the bytecode carries no type
  information.
- **MIR optimization**: ryo uses rustc's default MIR settings, so it compiles the same MIR as
  the other backends and benchmarks compare like with like ([build.md](build.md#build)).
  At `-O0`, `mir_opt_level` is 1 and the MIR inliner is off
  (`rustc_mir_transform/src/inline.rs:48-59`), so every small `Deref::deref`, `Index::index`
  or `Iterator::next` is a full VM call. Users can still pass `-Zmir-opt-level=2
  -Zinline-mir=yes` themselves. Where inlining happens, it stops at upstream items without
  MIR in metadata (non-generic, non-`#[inline]`), and those calls become islands.

## Frame slots

- **ABI inputs**: a function's inputs are those of its `fn_abi`: `fn_sig_for_fn_abi`'s
  inputs with a trailing `rust-call` tuple spread out, as `fn_abi_new_uncached` does
  (`rustc_ty_utils/src/abi.rs:553-566`), plus the implicit `&'static Location` for
  `#[track_caller]` functions (`abi.rs:600`). Their `PassMode`s say where each piece goes
  in registers and on the stack ([vm.md](vm.md#calls-and-islands), `sig.rs`, `arg_plan`);
  a mode the plan doesn't handle keeps the function native.
- **Homes**: each input has a home slot below `fp` (`frame.rs`): its argument local
  `_1.._n`, a field of the spread local for bodies with `spread_arg` (rust-call items whose
  MIR has one tupled local where the ABI is spread), or an 8-byte slot for the caller
  location. The prologue fills the homes from the argument registers (`arg`) and the
  stack argument area at `fp + 16` (after 32 bytes of shadow space on PE), and copies
  `Indirect` inputs from behind their pointers, which get slots of their own. An sret
  function also keeps its destination pointer in a slot.
- **Argument blocks** remain for island calls and for checking the inputs' sizes: the
  layout of the tuple of the ABI input types, as `tcx.layout_of` computes it
  (`sig.rs`, `arg_block`). The `call` and `call_cN` templates read their arguments as that
  tuple. `ryo_bytecode::abi::check_arg_block` doesn't compute this layout: rustc's tuple field
  order depends on niches, not only on sizes and alignments (`(u32, u8, bool, u8)` and
  `(u32, u8, u8, u8)` differ), and changes between releases; the backend takes the
  offsets, size and alignment from `tcx.layout_of`, and `check_arg_block` validates them. The
  wrappers reject `-Zrandomize-layout`, so tuple layouts agree between crates. ZST
  arguments take no space.
- Frames grow downward, and slots are signed offsets from `fp` ([vm.md](vm.md#frames)).
- **Other locals**: each gets a fixed offset below `fp`, aligned to its layout. ZSTs take no
  space. Locals whose storage ranges don't overlap share bytes
  (`frame.rs`): a forward dataflow over every CFG edge (unwind edges included) gives the
  locals that may be storage-live at each block entry, and a local conflicts with every local
  that may be live at one of its `StorageLive`s. Locals are then placed first-fit, as
  close to `fp` as they can go without overlapping a conflicting local. `_0`, the arguments and locals
  without a `StorageLive` keep slots of their own, and so does every local of a body with
  more than 4096 locals (the conflict matrix is quadratic). At `-O0` rustc strips storage
  markers from local MIR (`RemoveStorageMarkers` runs when lifetime markers are off,
  `rustc_mir_transform/src/remove_storage_markers.rs:14`), so there sharing only applies to
  MIR that still has them, such as upstream `#[inline]` and generic items.
- `_0` (the return value) is a normal slot.
- **Temporaries** of the statement being lowered go below the locals, and are freed between
  statements, which marks them dead for the assembler (`Asm::dead`). So does the read of a
  local that nothing reads again (`frame::dead_after_read`).
- **Exception slot**: functions with cleanup or terminate actions, or an `UnwindResume`, have
  one 8-byte slot where landing pads store the exception object ([Unwinding](#unwinding)).
- **Outgoing area**: the stack arguments of the calls a function makes, and island
  argument blocks, are written at `fp - F`, the bottom of the frame (`rsp`), which is the
  callee's `fp + 16`. On PE its first 32 bytes are the shadow space of every call, handlers'
  included, which every frame reserves (8 more where a handler takes a stack argument), and
  island argument blocks start past them (`FnCx::island_block`). The lowering
  hands out outgoing slots as offsets in the block and turns them into frame offsets once
  `F` is known (`frame.rs`, `emit::finish_slots`).
- `frame_size` `F` = locals + temporaries + the largest outgoing area, rounded up to 16 (`abi::frame_size`). It is an
  operand of the prologue's `sub rsp, F` ([vm.md](vm.md#frames)).
- **Alignment**: frames are 16-aligned (`fp` is 16-aligned and `F` a multiple of 16), and
  every slot is aligned to its type relative to `fp`.
  So every slot whose type has alignment ≤ 16 is properly aligned, and templates access
  slots with aligned reads and writes. A function whose locals or arguments (including the
  argument block of any island call it makes) contain a type with alignment above 16 is not
  lowered: it stays native ([stubs.md](stubs.md#template-gaps)).

## Places and operands

- `_n` → slot `off_n`.
- `Field` of a local (any depth, through `Downcast`) → slot `off_n + offset`, folded at
  lowering time. `Downcast` only selects which variant layout applies.
- `(*_n).f…` → the memory operand `[slot_n + k]`: the pointer is loaded from the slot and the
  constant offset `k` is added. A deref anywhere else in the projection list (`(*(*_n).f).g`)
  first loads the inner pointer into a temporary slot.
- `Index(_i)`, `ConstantIndex`, `Subslice` → `ptr.index`/`ptr.add` into a temporary slot,
  then a memory operand on it.
- `OpaqueCast`, `UnwrapUnsafeBinder` → nothing (same bytes, different type).
- Unsized places (`[T]`, `str`, `dyn Trait` behind a deref): the pointer slot holds a wide
  pointer. Lengths and vtables are read from its metadata word. Size-dependent operations use
  the runtime size (from the vtable or `len * size_of::<T>`), computed as cg_ssa's
  `size_and_align_of_dst` does, folding what is known at lowering time.
- A field whose type is an unsized tail other than `[T]`/`str`, at a non-zero offset
  (`(*p).val` with `p: &Wrapper<dyn Trait>`, `RcInner<dyn Trait>`'s value): its offset is
  rounded up at run time to the tail's alignment from the vtable (capped by `repr(packed)`),
  as cg_ssa's `project_field` does, and the place becomes `[t]` on a computed pointer.
- **Operands**:
  - `Copy`/`Move` of a place are lowered the same way (a move is a copy, and drop
    elaboration has already made moves explicit).
  - `Constant` becomes an immediate for scalars, and a constant-pool reference otherwise.
  - `RuntimeChecks(UbChecks | ContractChecks | OverflowChecks)` becomes an immediate `bool`,
    the session's setting, as cg_ssa does.

## Statements

| `StatementKind` | Bytecode |
|---|---|
| `Assign(place, rvalue)` | see Rvalues |
| `SetDiscriminant` | a plain store of the tag value, computed at lowering time (also for niches) |
| `Intrinsic(CopyNonOverlapping)` | `memcpy` |
| `Intrinsic(Assume)` | nothing |
| `StorageLive` | nothing (slot allocation used it) |
| `StorageDead` | no code: a storage end of the local's slot ([vm.md](vm.md#escapes-storage-ends-and-island-operands)) |
| `FakeRead`, `PlaceMention`, `AscribeUserType`, `Coverage`, `ConstEvalCounter`, `Nop`, `BackwardIncompatibleDropHint` | nothing |

## Rvalues

**Aggregate copies**: copies between frame slots use `mov`/`copy`, because distinct slots
never overlap. A copy with one side in memory (through a deref) is a load or a store
(`load.copy`/`store.copy`, `memmove` semantics). A copy between two memory places goes through
a temporary slot up to 256 bytes, and uses `memmove` above that.

| `Rvalue` | Bytecode |
|---|---|
| `Use(op, _)` | `mov.wN` (scalar), `copy`/`memmove` (aggregate), or a load/store when a side is in memory. The retag flag is ignored |
| `CopyForDeref(place)` | same as `Use(Copy(place))` |
| `Repeat(op, n)` | A scalar constant: `zero` or `fill` into a slot, `memset` into memory if all its bytes are equal. Otherwise the element is written once, then doubled with `memcpy`s (⌈log₂ n⌉ of them) |
| `Ref`, `RawPtr` | `addr` (slot address) or the place's address computation. For unsized places, the wide pointer (data plus metadata) |
| `Reborrow(_, _, place)` | same as `Use(Copy(place))`: same layout, bitwise copy |
| `ThreadLocalRef(def)` | `call.sym` (`call.sym.ind` through `__imp_` on PE) of `Shim(ThreadLocal(def))`, without a cleanup entry (the shim can't unwind), which returns the address on the current thread in `rax`. On ELF, rustc doesn't create that shim (`needs_thread_local_shim` is false when the target exports TLS, `rustc_middle/src/ty/util.rs:731-735`), so the backend adds it to the native CGU itself, also for upstream statics, as `WeakODR` + `Hidden` ([backend.md](backend.md#pipeline), Linkage). On PE, the collector puts a local static's shim in the CGU, and an upstream crate exports its own (`symbol_export.rs:203-220`), which the image reaches through `__imp_`. The shim itself is never a VM function (its body is a `ThreadLocalRef`). Foreign thread locals have no shim and stay native |
| `Cast(kind, op, ty)` | see Casts |
| `BinaryOp(op, (a, b))` | see Binary operations |
| `UnaryOp(Not, a)` | `not.wN` (`bool`: `xor` with 1) |
| `UnaryOp(Neg, a)` | `neg.wN`, `fneg.fN` |
| `UnaryOp(PtrMetadata, p)` | load of the metadata word (none for thin pointers) |
| `Discriminant(place)` | tag load, decoded per the layout: `TagEncoding::Direct` (load + zext/sext) or `Niche`, as cg_ssa's `codegen_get_discr` with integer ops: one niche variant `eq.imm`/`ne.imm` on the tag (+ zext, `add.imm` or a `neg`/`and`/`xor` blend), else `sub.imm` + `le.u.imm` + cast/`add.imm` and the blend. When only a `SwitchInt` reads it (the block's last statement), the switch tests the tag instead (see Terminators) |
| `Aggregate(kind, ops)` | field-wise stores into the destination plus the discriminant write. `RawPtr` aggregates build a (wide) pointer from data + metadata |
| `WrapUnsafeBinder(op, _)` | same as `Use(op)` |

### Casts

| `CastKind` | Bytecode |
|---|---|
| `IntToInt` | `zext`/`sext`/`trunc`, or `mov` for same-width casts |
| `FloatToInt` | `cvt.f2i.sat` (Rust `as`: saturating, NaN → 0) |
| `IntToFloat`, `FloatToFloat` | `cvt.i2f`, `cvt.f2f` |
| any of the four above from or to `f16`/`f128` | the `as_cast<A, B>` island (`ops`: source, destination) |
| `PtrToPtr`, `FnPtrToPtr`, `Transmute`, `Subtype`, `BoxDerefTransmute` | `mov`/`copy` (bit-preserving). `PtrToPtr` from wide to thin drops the metadata |
| `PointerExposeProvenance`, `PointerWithExposedProvenance` | `mov` |
| `PointerCoercion(ReifyFnPointer)` | `addr.sym` of the target instance's symbol (VM functions included) |
| `PointerCoercion(ClosureFnPointer)` | `addr.sym` of the closure's `FnOnce` shim |
| `PointerCoercion(UnsafeFnPointer, MutToConstPointer, ArrayToPointer)` | `mov` |
| `PointerCoercion(Unsize)` | as cg_ssa's `coerce_unsized_into`: a pointer becomes the wide pointer, data pointer plus metadata (a constant length, `addr.const` of the vtable in the constant pool, or for trait upcasts the old vtable or its supertrait entry). A struct (`Box`, `Rc`, `Ref<'_, T>`, `Pin<Box<T>>`, …) is coerced field by field: non-ZST fields of unchanged type are copied, the others coerced recursively |

### Binary operations

| `BinOp` | Bytecode |
|---|---|
| `Add`, `Sub`, `Mul` and the `*Unchecked` variants | `add`/`sub`/`mul.wN` (wrapping; unchecked overflow is UB, so wrapping is fine) |
| `AddWithOverflow`, `SubWithOverflow`, `MulWithOverflow` | `add.ovf`/`sub.ovf`/`mul.ovf.{s,u}.wN`, writing the value and the overflow flag (the pair layout) |
| `Div`, `Rem` | `div`/`rem.{s,u}.wN`. MIR guarantees non-zero divisors and no `MIN / -1` (an `Assert` precedes, or it is UB), so the VM never checks |
| `Shl`, `Shr` and the `*Unchecked` variants | `shl`/`shr.{s,u}.wN`, with the amount masked to the width |
| `BitAnd`, `BitOr`, `BitXor` | `and`/`or`/`xor.wN` |
| `Eq`, `Ne`, `Lt`, `Le`, `Gt`, `Ge` | `eq`/`ne`/`lt`/`le.{s,u}.wN` (`Gt`/`Ge` swap the operands). Float compares: `feq`/`flt`/… Raw-pointer compares: unsigned compares on the address (wide pointers compare data, then metadata) |
| `Cmp` | `cmp3.{s,u}.wN` (`Ordering` as `i8`) |
| `Offset` | `ptr.index` (pointer + count × pointee size) |
| float `Add`/`Sub`/`Mul`/`Div`/`Rem` | `fadd`/`fsub`/`fmul`/`fdiv`/`frem.fN` |

128-bit `mul`, `div`, `rem` and `MulWithOverflow` lower to islands (`mul_w128`,
`div_{s,u}_w128`, `rem_{s,u}_w128`, `mul_ovf_{s,u}_w128`; `ops`: `a`, `b`, destination), which
compile to compiler-builtins' `__multi3`, `__udivti3`, … Everything else at 128 bits runs in
the VM. Wide pointer orderings are lexicographic: `a < b` is `a.data < b.data ||
(a.data == b.data && a.meta < b.meta)`.

## Terminators

A block that is unreachable after monomorphization (`mir::traversal::mono_reachable`: behind a
`SwitchInt` on a constant, as `if const { size_of::<T>() == 0 }`, or on `ub_checks()`) is
lowered as a lone `unreachable`, as cg_ssa does (`codegen_block_as_unreachable`,
`rustc_codegen_ssa/src/mir/mod.rs:291-392`): the collector skips these blocks too
(`collector.rs:1367`), so the image must not refer to what they use, which no CGU may define
([backend.md](backend.md#pipeline), step 4). The Lean certificate marks such a block `dead`.

| `TerminatorKind` | Bytecode |
|---|---|
| `Goto` | `jmp`, or fall-through |
| `SwitchInt(d, targets)` | If `d` is a `bool` local defined by an integer, `char`, `bool` or thin-pointer compare as the block's last statement, and used nowhere else, a compare branch on the compare's operands (`br.eq`, `br.lt`, their `.imm` forms or `br.gt.imm`, with the polarity and operand order that give the compare), and the compare isn't emitted. If `d` is a local only this switch reads, defined as the block's last statement by `Discriminant(p)` of a niche-encoded enum, the switch tests the tag of `p`: each niche variant's arm is `br.eq.imm` on its tag value and the untagged variant is the fall-through (more than 4 tested arms: `sub.imm` of `niche_start`, `br.gt.u.imm` of the niche range to the untagged arm, `switch.dense`); arms that go where the untagged variant goes, or to an unreachable `otherwise`, aren't tested. Otherwise `br`/`br!` for `bool`, `br.eq.imm` for a single case, `switch.dense` for dense value sets, and `switch.sparse` otherwise |
| `Return` | `ret`; for sret, after `store.copy` of `_0` to the address saved by the prologue's `arg` |
| `Unreachable` | `unreachable` |
| `Call` | see Calls |
| `TailCall` | `tail_call` / `tail_call.ptr` ([vm.md](vm.md#calls-and-islands)) |
| `Drop { place, .. }` | Nothing if the type has no drop glue. Otherwise a call of `DropGlue(T)`: a VM `call` if the glue is a VM function, an `island` with `drop_in_place::<T>` otherwise. Unsized places pass the wide pointer. `replace` doesn't change the lowering, and `drop` (async drop) is `None` in runtime MIR |
| `Assert { cond, expected, msg, target, unwind }` | a compare branch (fused as for `SwitchInt`) or `br`/`br!` to `target`, and otherwise a call of the panic function for `msg` |
| `UnwindResume` | `resume x`, `x` the exception slot |
| `UnwindTerminate(reason)` | a call of the reason's lang item (`panic_cannot_unwind`, `panic_in_cleanup`), which reports the panic and aborts, as cg_ssa's `codegen_terminate_terminator` |
| `InlineAsm` | not lowerable: the function is native ([backend.md](backend.md#pipeline)) |
| `Yield`, `CoroutineDrop`, `FalseEdge`, `FalseUnwind` | don't occur in runtime MIR (the coroutine transform and CFG cleanup remove them). The lowering ICEs on them |

### `Assert` messages

Each `AssertKind` maps to its panic lang item, as cg_ssa does (`rustc_codegen_ssa/src/mir/block.rs`).

| `AssertKind` | Panic function |
|---|---|
| `BoundsCheck { len, index }` | `panic_bounds_check(index, len)` |
| `Overflow(op, ..)`, `OverflowNeg`, `DivisionByZero`, `RemainderByZero` | `panic_const_*` |
| `ResumedAfterReturn`, `ResumedAfterPanic`, `ResumedAfterDrop` | `panic_const_coroutine_*` / `async_fn_*` / `gen_fn_*` |
| `MisalignedPointerDereference { required, found }` | `panic_misaligned_pointer_dereference` |
| `NullPointerDereference` | `panic_null_pointer_dereference` |
| `InvalidEnumConstruction(v)` | `panic_invalid_enum_construction` |
| `NullReferenceConstructed` | the `PanicNullReferenceConstructed` lang item (`rustc_codegen_ssa/src/mir/block.rs:800-803`) |

These functions are `#[track_caller]`, so they get a location ([Caller location](#caller-location)).
They are called like any other function: a VM `call` if a VM version exists, otherwise an
island.

## Calls

`Call { func, args, destination, target, unwind, .. }`:

1. **Resolve the callee.** For a `FnDef` callee type: `Instance::expect_resolve(tcx,
   typing_env, def_id, args)`, as cg_ssa does. Then:
   - **VM function in this crate's image**: `call fn`.
   - **Anything else with a symbol and the Rust ABI**: `call.sym` on its symbol
     (`call.sym.ind` through `__imp_` on PE): instances from another crate (those
     `should_codegen_locally` says aren't codegened locally: upstream non-generic, or a
     shared upstream generic) and local native functions. It doesn't matter whether the
     callee is VM code ([vm.md](vm.md#calls-and-islands)). Local copies of
     `#[inline]`/cross-crate-inlinable items are lowered locally like any other item.
   - **`extern "C"` functions**: `addr.sym` of the callee into a slot and the `call_cN`
     island ([stubs.md](stubs.md#templates)).
   - **Safe callees without a symbol** (intrinsics without a VM lowering): the `call<F,
     Args, R>` island, for a safe, Rust-ABI fn item without `#[target_feature]` or
     `#[track_caller]`. Not in the `Fn*` shims of the fn item's own type
     (`ShimKind::FnPtr(_, F)`): the template calls
     `<F as FnOnce>::call_once`, which is such a shim, so the call would come back to a VM
     shim calling `F` the same way, forever. Constructors are VM functions like any other
     item: their body is `mir_for_ctfe`, which metadata always has for them, though
     `is_mir_available` (which asks for `optimized_mir`) says no for upstream ones.
   - **`InstanceKind::LlvmIntrinsic`**: not lowerable (no MIR, `unadjusted` ABI). The
     function stays native.
   - **`InstanceKind::Virtual(_, idx)`**: load the fn pointer from the vtable (entry `idx`,
     the word at `idx * 8`, through the receiver's metadata), pass the receiver's data
     pointer, then `call.ptr` (`dyn Fn*` calls are `rust-call` and spread their tuple like
     any other). As cg_ssa does, the receiver (`Box`, `Rc`, `Pin<&mut _>`, …) is peeled
     down to its one non-1-ZST field until a pointer remains; an unsized by-value receiver
     (`Box<dyn FnOnce>`, whose callee is a `VTableShim`) passes its address.
     `fn_abi_of_instance` gives the receiver the wide pointer's type with a thin layout, so
     the signature uses a thin type instead, with the niche of the callee's receiver, so
     that its layout matches the method's, which takes `&Self`, `Box<Self>`, … (non-null)
     or `*mut Self` (a `VTableShim`). The caller passes `&()` if the receiver's data pointer is
     non-null, `*mut ()` otherwise.
   - **`InstanceKind::Intrinsic`**: the matching VM instruction if one exists (`size_of`,
     `transmute`, overflow arithmetic, `copy_nonoverlapping`, `write_bytes`, atomics,
     `abort`, `unreachable`, `likely`/`unlikely`, `caller_location`, …). Otherwise an
     `island` with the intrinsic's wrapper. So far, as VM instructions: `abort`,
     `caller_location`, `cold_path`, `black_box`, `likely`/`unlikely`,
     `ptr_offset_from(_unsigned)`,
     `arith_offset`, `copy`, `write_bytes`, `typed_swap_nonoverlapping`,
     `size_of_val`/`align_of_val` (also of structs with an unsized tail, as cg_ssa's
     `size_and_align_of_dst`), `vtable_size`/`vtable_align`, `ctpop`/`ctlz`/`cttz` (and
     `_nonzero`), `bswap`, `bitreverse`, rotates, `unchecked_funnel_shl`/`_shr`,
     `exact_div`, `disjoint_bitor`, `ptr_guaranteed_cmp`, the nontemporal store, `fabs`, `copysign*`, `minimum_number_nsz_*`/`maximum_number_nsz_*` (the VM's
     `fmin`/`fmax` are `f*::min`/`max`), and the atomics up to 64 bits (an ordering
     combination the VM lacks uses `SeqCst`). As wrapper islands: `catch_unwind` ([Unwinding](#unwinding)),
     `compare_bytes`, `raw_eq`, the `volatile_*` accesses and copies (opaque to the JIT,
     which would merge, forward or hoist VM loads and stores) and the SIMD intrinsics without constant operands
     ([stubs.md](stubs.md#templates)), except those [SIMD](#simd) maps to instructions.
     Otherwise: safe intrinsics go through the `call`
     island (natively), unsafe ones with a fallback body call that body as an ordinary
     instance (cg_ssa's `IntrinsicResult::Fallback`; a VM function if the collector found
     it), and the rest keep the function native.

   A Rust-ABI fn-pointer callee type → `call.ptr`; an `extern "C"` one → `call_cN`.

   **Tail calls** (`TailCall`, `become`): the arguments are staged in temporaries, their
   stack pieces stored over the function's own incoming ones, then `tail_call fn` for a VM
   function of this image, and `tail_call.ptr` otherwise: on a fn pointer, the vtable entry
   of a virtual call, or `addr.sym` of any other callee with a symbol. Calls of intrinsics,
   non-Rust ABIs and an sret callee from a non-sret function stay native.
2. **Arguments** (`call.rs`, `write_args`, `pass_args`): each ABI input's slot is the
   operand's own slot, except that an `Indirect` input, which the callee may write to, is
   copied to a temporary. The stack pieces are stored to the outgoing area at `rsp` by
   plain moves, and the register pieces go into the call's argument list, loaded right
   before the call (`Indirect` inputs as their slot's address). MIR call arguments are
   operands (locals or constants), so no other call runs in between. For island calls the
   arguments are copied into the outgoing area as an argument block instead. For
   `#[track_caller]` callees, the location is appended ([Caller location](#caller-location)).
3. **Destination**: the call instruction names the caller's destination slot, which it
   stores the return registers to after the call; for sret, the argument list passes its
   address, as the callee signature's `PassMode` says ([vm.md](vm.md#calls-and-islands)). A
   destination behind a deref is first written to a temporary slot, then stored.
4. **Unwind**: the call's unwind action becomes a cleanup entry for the instruction
   ([Unwinding](#unwinding)).

Functions with unsized parameters (`unsized_fn_params`) are not lowered: they stay native.

### SIMD

`lower/simd.rs` maps the portable `simd_*` intrinsics SSE2 has single instructions for, by
their type arguments, to VM instructions ([instructions.md](instructions.md#simd)):

| intrinsic | type arguments | instruction |
|---|---|---|
| `simd_splat` | 16 × i8/u8, i8/u8 | `vsplat.i8x16 d, x` |
| `simd_eq` | 16 × i8/u8, 16 × i8/u8 | `veq.i8x16 d, a, b` |
| `simd_lt` / `simd_gt` | 16 × i8, 16 × i8/u8 | `vlt.s.i8x16 d, a, b` / `vlt.s.i8x16 d, b, a` |
| `simd_bitmask` | 16 × i8/u8, `u16` or `[u8; 2]` | `vmsb.i8x16 d, a` |
| `simd_and` / `or` / `xor` | any 16-byte integer vector | `and` / `or` / `xor.w128 d, a, b` |

Vectors are 16-byte slots like any other value. Everything else (unsigned compares,
`ne`/`le`/`ge`, other shapes, float vectors, `simd_shuffle`, …) is a wrapper island, or
keeps a `#[target_feature]` function native (see the top of this file). The table is
trusted, like the island contracts: L0 has no `simd_*` semantics yet.

### Caller location

Mirrors cg_ssa's `get_caller_location`:

- The location for a call site is a `core::panic::Location` constant in the constant pool,
  built from the call's `source_info` span. If the current function is itself
  `#[track_caller]` and the span comes from its body, the location is instead the function's
  own incoming location argument (the home of its last ABI input).
- `#[track_caller]` callee, VM or native: the location is the last ABI input
  (`rustc_ty_utils/src/abi.rs:600`), and the call goes to the callee instance's own symbol
  (not its `ReifyShim`).
- The `caller_location` intrinsic yields the same value.

## Unwinding

VM frames unwind natively ([vm.md](vm.md#unwinding)). The lowering records the unwind action
of every call-like instruction (`call`, `call.sym`, `call.sym.ind`, `call.ptr`, an
`island` whose operation can unwind, `resume`) as a cleanup entry keyed
by its code offset, which the encoder turns into the function's LSDA call-site table:

- `UnwindAction::Continue` → a `CONTINUE` entry: the call is a call site without a landing
  pad, so unwinding leaves the frame. `resume` always has it; tail calls leave no frame
  and have no entry.
- `UnwindAction::Cleanup(bb)` → the landing pad of `bb`.
- `UnwindAction::Terminate(reason)` → a catch-all landing pad (`CATCH`), as cg_llvm's
  terminate pads, so it runs even when nothing up the stack catches. It jumps to a stub
  after the function's blocks that calls the reason's lang item (`panic_cannot_unwind`,
  `panic_in_cleanup`), like cg_ssa's terminate block, so the message and the panic hook run
  as natively. One stub per reason the function uses.
- `UnwindAction::Unreachable` → no entry: the call is no call site, and unwinding out of it
  aborts.

- **Landing pads**: one per distinct destination, after the blocks and terminate stubs:
  `lpad x` (which stores the exception object in the function's exception slot `x`), then a
  `jmp` to the cleanup block or terminate stub. A cleanup block may also be reached by a
  jump from another one, so the pads are separate from the blocks, and `lpad` runs once per
  landing. The cleanup code ends in `resume x`.
- Calls inside cleanup blocks carry `Terminate`, so a panic during unwinding aborts, as with
  native code.
- **PE**: the cleanup blocks come last ([vm.md](vm.md#pe-seh)): the other blocks, their
  terminate stubs and landing pads, then, if any call has a cleanup landing pad, the pad
  region: those landing pads, the cleanup blocks, and the terminate stubs and landing pads
  of their calls. A call with stack arguments there keeps the function native (`rsp` isn't
  `fp - F` in the region).
- The `catch_unwind` intrinsic is an island (`ryo_island_catch_unwind<Data>`, without a
  cleanup entry: the intrinsic is `rustc_nounwind`). Its `try_fn`/`catch_fn` operands are fn
  pointers, VM functions or not, called natively, and the intrinsic catches a panic
  unwinding out of them.
- Islands whose operation can't unwind (intrinsic wrappers, `as_cast`, the 128-bit
  arithmetic, the TLS shim call) get no cleanup entry.

## Constants

- Scalar constants become immediates.
- Other `ConstValue`s and allocations go into the image's constant pool, byte for byte.
- Pointers inside an allocation become relocations:
  - to another pool allocation: intra-image
  - to a static or function: against its symbol

  The linker applies both ([vm.md](vm.md#image-format)).
- Type id "pointers" (`GlobalAlloc::TypeId`) have no address: the base is 0 and the offset
  is part of the hash, as in cg_llvm (`rustc_codegen_llvm/src/common.rs:201-205`). So a
  type-id scalar is an immediate of its offset, and in an allocation the bytes stay as they
  are, with no relocation.
- Pointers to VM functions in constants (vtables, fn-pointer constants) point at their
  symbols, which then become global, so native code can call them too.
- **Vtables**: cg_llvm emits vtables as private, unnamed constants, so there is no symbol to
  relocate against. Vtables that bytecode needs (for unsizing) are therefore put in the
  image's own constant pool, from `tcx.vtable_allocation`, with entries relocated to the functions'
  symbols. Vtable addresses aren't guaranteed unique, so a second copy is fine.
  Allocations are walked recursively, and image vtables are roots of the global-symbol
  computation ([backend.md](backend.md#pipeline)).
- On PE, pointers to functions and statics that another crate or library defines (those
  whose `sym` slot would be indirect, [platforms.md](platforms.md)) can't be link-time
  relocated: they need `__imp_` indirection. Allocations containing them directly go into
  the image's writable `fixups` area instead of the pool, with one fixup per such pointer
  (against an indirect slot; functions and foreign statics of static libraries also get a
  direct slot, as for code references), and registration patches them once. Their address
  is `addr.const` of the data area, and an `Indirect` constant is copied out of them with a load. Allocations
  that only point at such allocations stay in the pool, with intra-image relocations into
  the writable section. This is the only load-time fixup.

## Status

The lowering lives in `backend/src/lower/`, one module per concern (`mod.rs` lists
them). Implemented: everything above for integers, `bool`, `char`, `f32`/`f64`, places,
references, aggregates, enums, all casts (`f16`/`f128` ones through `as_cast`), field-by-field
unsizing, unsized tails at dynamic offsets, `size_of_val` of any unsized type, `Repeat`, wide
pointer compares, 128-bit `mul`/`div`/`rem`/`mul.ovf` islands, constants (pool allocations with
relocations, type ids, vtables, and on PE the fixup area for constants pointing at imports),
thread locals (`ThreadLocalRef` through the TLS shim), switches,
asserts, drops (VM call of the glue, `drop_in_place` island, vtable drop for trait objects),
unwinding (cleanup entries, landing pads, terminate stubs, the `catch_unwind` island) and calls in the platform convention: VM `call`, `call.sym` for everything else with a
symbol, `call.ptr` for fn pointers and virtual calls (`dyn Fn*` included), tail calls, and
islands (`call` for safe intrinsics without a symbol, `call_cN` for `extern "C"`), every
shim kind with a body, plus the intrinsics listed in Calls.
`#[track_caller]` functions are VM functions, and caller locations follow cg_ssa, including a
`#[track_caller]` function's own incoming location and the `caller_location` intrinsic.
`SwitchInt` and `Assert` fuse with the compare that feeds them (compare branches), and
`SwitchInt` with a niche discriminant read. Locals with storage markers share slots; there is
no copy propagation yet.
Still `NeedsNative`, with the reason in `RYO_STATS=2`: argument and return `PassMode`s the
VM doesn't place (on Win64 also an `f128` in a `Pair`), `ThreadLocalRef` of foreign thread locals, `f16`/`f128` arithmetic and
compares, unsafe intrinsics without a VM lowering, wrapper or fallback body (128-bit atomics,
SIMD intrinsics with constant operands, …), coroutines, extern-type tails, by-value
unsized arguments (`unsized_fn_params`) and references to
foreign statics with a `#[linkage]` (std's `extern_weak` `weak!` statics: cg_llvm's private
cell holding the symbol's address has no symbol the image could name).
With `--sysroot ryo`, std builds and the corpus passes against it; 99.2% of the functions
of the ryo-built sysroot crates are bytecode. Most of the rest are `extern "C"`
definitions, C-variadic calls, over-aligned argument blocks and the `#[target_feature]`
functions with features beyond the crate's or bodies that don't map (`avx2` and LLVM
intrinsics in `memchr` and `std_detect`; `y build --sysroot ryo` prints the table).
The PE fixup area is only cross-checked (objects and links), not run, like the rest of the
PE column ([platforms.md](platforms.md)). On PE, landing pads run through
`ryo_seh_handler` ([vm.md](vm.md#pe-seh)), only cross-checked too.

## Code optimization

There is no optimization pass over the code. The lowering itself folds
constant offsets into memory operands (`[p + k]`), selects the `.imm` forms for constant
operands, and fuses a compare with the branch that consumes it. Everything else happens in
the assembler's fixed sequences ([vm.md](vm.md#machine-code)): shortest register loads,
`rel8` branches where they reach, 16-byte loop-head alignment, and keeping values in the
caller-saved registers between inline instructions, dropping stores to slots the lowering
marks dead ([register cache](vm.md#register-cache)). There is no copy
propagation, which matters at `-O0`, where MIR has had little of it.
