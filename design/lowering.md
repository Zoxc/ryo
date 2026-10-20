# Lowering: MIR → bytecode

Each VM function is lowered on its own (in parallel, [backend.md](backend.md#pipeline)) into a
code buffer, a constant list, a relocation list and a cleanup table. The instruction set is
specified in [vm.md](vm.md#instruction-set).

The entry point is `lower(tcx, cx, instance) -> Result<LoweredFn, NeedsNative>`
(`backend/src/rustc_api/lower/mod.rs`), where `cx: LowerCx` holds the set of functions
assumed to be VM functions of this image (a call of one of them is a `call`, any other local
callee an island). A `LoweredFn` holds:

- the code words, with operands the lowering can't know left as placeholders
- relocations for those operands, which the merge pass resolves once every function's index
  and symbol is known:
  - `Call { at, callee }`: a `call` to another VM function of this image (function index and
    callee `frame_size`)
  - `Symbol { at, target }`: a `sym` operand, the target's symbol (its portal if it is a VM
    function, which then gets one; an internal native item is made visible to the image)
  - `Static { at, def_id }`: a `sym` operand naming a static
  - `Site { at }`: a fresh site cache slot
  - `Const { at, alloc, offset }`: a `k` operand, `offset` bytes into the pool copy of an
    allocation
  - `Bytes { at, bytes, align }`: a `k` operand, a pool allocation of raw bytes (`fill`
    elements)
  - `Data { at, alloc, offset }`: a `data` operand, `offset` bytes into the fixup-area copy
    of an allocation (PE, [Constants](#constants))
- island requests (template diagnostic item name and generic args, plus the operand to fill)
- the cleanup entries, `frame_size`, `max_outgoing`, `arg_size` and `ret_size`

`NeedsNative(reason)` keeps the function native as a whole. `RYO_STATS=2` prints the reasons
([backend.md](backend.md#debugging-switches)).

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

- **Arguments**: the **argument block** has the layout of the tuple of the callee's *ABI*
  argument types, as `tcx.layout_of` computes it. That is `fn_sig_for_fn_abi`'s inputs with
  a trailing `rust-call` tuple spread out, as `fn_abi_new_uncached` does
  (`rustc_ty_utils/src/abi.rs:553-566`), plus the implicit `&'static Location` for
  `#[track_caller]` functions (`abi.rs:600`). For most bodies, the argument locals `_1.._n`
  are the block's fields. Bodies with `spread_arg` (rust-call items whose MIR has one tupled
  local where the ABI is spread) give the spread local its own slot, and the function's
  prologue assembles it from the block fields, because the nested and flat tuple layouts
  differ. Callers (`call`, `call.ind`, `tail_call`), callees, portals
  (whose `Args` tuple is exactly this tuple) and the `call` island templates all use this
  one definition. So an argument block can move between them with one `copy`.
  `ryo_bytecode::abi::arg_block` doesn't compute this layout: rustc's tuple field order
  depends on niches, not only on sizes and alignments (`(u32, u8, bool, u8)` and
  `(u32, u8, u8, u8)` differ), and changes between releases. The backend takes the offsets,
  size and alignment from `tcx.layout_of` of the tuple, and `arg_block` validates them and
  gives the frame offsets. Blocks aligned to more than 16 bytes can't be placed at
  `fp + H`, so such functions stay native. The wrappers reject `-Zrandomize-layout`, since
  tuple layouts must agree between crates. ZST arguments get an offset in the tuple and take no space.
- The argument block starts at `fp + H`, where H is the header size
  ([vm.md](vm.md#frames-and-the-vm-stack)).
- **Other locals**: each gets a fixed offset after the argument block, aligned to its
  layout. ZSTs take no space. Locals whose storage ranges don't overlap share bytes
  (`frame.rs`): a forward dataflow over every CFG edge (unwind edges included) gives the
  locals that may be storage-live at each block entry, and a local conflicts with every local
  that may be live at one of its `StorageLive`s. Locals are then placed first-fit, at the
  lowest aligned offset no conflicting local already uses. `_0`, the arguments and locals
  without a `StorageLive` keep slots of their own, and so does every local of a body with
  more than 4096 locals (the conflict matrix is quadratic). At `-O0` rustc strips storage
  markers from local MIR (`RemoveStorageMarkers` runs when lifetime markers are off,
  `rustc_mir_transform/src/remove_storage_markers.rs:14`), so there sharing only applies to
  MIR that still has them, such as upstream `#[inline]` and generic items.
- `_0` (the return value) is a normal slot.
- `frame_size` = H + argument block + other locals, rounded up to 16.
- **Alignment**: frames are 16-aligned. The VM stack base is page-aligned, H = 16 and
  `frame_size` is a multiple of 16, and every slot is aligned to its type relative to `fp`.
  So every slot whose type has alignment ≤ 16 is properly aligned, and templates access
  slots with aligned reads and writes. A function whose locals or arguments (including the
  argument block of any call it makes) contain a type with alignment above 16 is not
  lowered: it stays native ([stubs.md](stubs.md#template-gaps)).
- `max_outgoing` = H + the largest outgoing argument block among the function's calls
  (`call`, `call.ext`, `call.ext.ind`, `call.ind`, and the staging area of tail calls), or 0
  if it makes none. It goes in the function table, and the stack check on entry covers
  `frame_size + max_outgoing` ([vm.md](vm.md#frames-and-the-vm-stack)).

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
| `SetDiscriminant` | a plain store of the tag value, computed at lowering time (also for niches; `set_discr.niche` is unused so far) |
| `Intrinsic(CopyNonOverlapping)` | `memcpy` |
| `Intrinsic(Assume)` | nothing |
| `StorageLive`, `StorageDead` | nothing (slot allocation used them) |
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
| `ThreadLocalRef(def)` | `addr.sym` of `Shim(ThreadLocal(def))` and a `call_ptr0` island on it (plain `island`: the shim can't unwind), which returns the address on the current thread. On ELF, rustc doesn't create that shim (`needs_thread_local_shim` is false when the target exports TLS, `rustc_middle/src/ty/util.rs:731-735`), so the backend adds it to the native CGU itself, also for upstream statics, as `WeakODR` + `Hidden` ([backend.md](backend.md#pipeline), Linkage). On PE, the collector puts a local static's shim in the CGU, and an upstream crate exports its own (`symbol_export.rs:203-220`), which the image reaches through `__imp_`. The shim itself is never a VM function (its body is a `ThreadLocalRef`). Foreign thread locals have no shim and stay native |
| `Cast(kind, op, ty)` | see Casts |
| `BinaryOp(op, (a, b))` | see Binary operations |
| `UnaryOp(Not, a)` | `not.wN` (`bool`: `xor` with 1) |
| `UnaryOp(Neg, a)` | `neg.wN`, `fneg.fN` |
| `UnaryOp(PtrMetadata, p)` | load of the metadata word (none for thin pointers) |
| `Discriminant(place)` | tag load, decoded per the layout: `TagEncoding::Direct` (load + zext/sext) or `Niche` (`discr.niche`) |
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
| `PointerCoercion(ReifyFnPointer)` | `addr.sym` of the target instance's symbol, or its portal for VM functions |
| `PointerCoercion(ClosureFnPointer)` | `addr.sym` of the closure's `FnOnce` shim (its portal, if it's a VM function) |
| `PointerCoercion(UnsafeFnPointer, MutToConstPointer, ArrayToPointer)` | `mov` |
| `PointerCoercion(Unsize)` | as cg_ssa's `coerce_unsized_into`: a pointer becomes the wide pointer, data pointer plus metadata (a constant length, `addr.k` of the vtable in the constant pool, or for trait upcasts the old vtable or its supertrait entry). A struct (`Box`, `Rc`, `Ref<'_, T>`, `Pin<Box<T>>`, …) is coerced field by field: non-ZST fields of unchanged type are copied, the others coerced recursively |

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

| `TerminatorKind` | Bytecode |
|---|---|
| `Goto` | `jmp`, or fall-through |
| `SwitchInt(d, targets)` | If `d` is a `bool` local defined by an integer, `char`, `bool` or thin-pointer compare as the block's last statement, and used nowhere else, `br.cmp.*` on the compare's operands, and the compare isn't emitted. Otherwise `br.if`/`br.unless` for `bool`, `switch.dense` for dense value sets, and `switch.sparse` otherwise |
| `Return` | `ret` |
| `Unreachable` | `unreachable` |
| `Call` | see Calls |
| `TailCall` | `tail_call` / `tail_call.ind` ([vm.md](vm.md#calls-and-islands)) |
| `Drop { place, .. }` | Nothing if the type has no drop glue. Otherwise a call of `DropGlue(T)`: a VM `call` if the glue is a VM function, an `island` with `drop_in_place::<T>` otherwise. Unsized places pass the wide pointer. `replace` doesn't change the lowering, and `drop` (async drop) is `None` in runtime MIR |
| `Assert { cond, expected, msg, target, unwind }` | `br.cmp` (fused as for `SwitchInt`) or `br.if`/`br.unless` to `target`, and otherwise a call of the panic function for `msg` |
| `UnwindResume` | `resume` |
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
   - **Instance from another crate**, meaning one that `should_codegen_locally` says is not
     codegened locally (upstream non-generic, or a shared upstream generic). Local copies of
     `#[inline]`/cross-crate-inlinable items are lowered locally like any other item:
     `call.ext` on its symbol, with a `call_ptrN` island as the native fallback. It doesn't
     matter whether upstream compiled it to bytecode ([vm.md](vm.md#calls-and-islands)).
   - **Native function**: an `island` with a call template ([stubs.md](stubs.md#templates)):
     `call<F, Args, R>` for a safe, Rust-ABI fn item without `#[target_feature]` or
     `#[track_caller]` (no symbol needed), otherwise `addr.sym` of the callee into a slot and
     `call_ptrN` (Rust ABI) or `call_cN` (`extern "C"`).
   - **`InstanceKind::LlvmIntrinsic`**: not lowerable (no MIR, `unadjusted` ABI). The
     function stays native.
   - **`InstanceKind::Virtual(_, idx)`**: load the fn pointer from the vtable (entry `idx`,
     the word at `idx * 8`, through the receiver's metadata), pass the receiver's data
     pointer, then `call.ind` (`dyn Fn*` calls are `rust-call` and spread their tuple like
     any other). As cg_ssa does, the receiver (`Box`, `Rc`, `Pin<&mut _>`, …) is peeled
     down to its one non-1-ZST field until a pointer remains; an unsized by-value receiver
     (`Box<dyn FnOnce>`, whose callee is a `VTableShim`) passes its address.
     `fn_abi_of_instance` gives the receiver the wide pointer's type with a thin layout, so
     the signature uses a thin type instead, with the niche of the callee's receiver: the
     argument block is a tuple layout, which depends on niches ([Frame slots](#frame-slots)),
     and the method behind the vtable takes `&Self`, `Box<Self>`, … (non-null) or `*mut
     Self` (a `VTableShim`). The caller passes `&()` if the receiver's data pointer is
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
     `exact_div`, `disjoint_bitor`, `ptr_guaranteed_cmp`, the volatile and nontemporal
     accesses, `fabs`, `copysign*`, `minimum_number_nsz_*`/`maximum_number_nsz_*` (the VM's
     `fmin`/`fmax` are `f*::min`/`max`), and the atomics up to 64 bits (an ordering
     combination the VM lacks uses `SeqCst`). As wrapper islands: `catch_unwind` ([Unwinding](#unwinding)),
     `compare_bytes`, `raw_eq` and the SIMD intrinsics without constant operands
     ([stubs.md](stubs.md#templates)). Otherwise: safe intrinsics go through the `call`
     island (natively), unsafe ones with a fallback body call that body as an ordinary
     instance (cg_ssa's `IntrinsicResult::Fallback`; a VM function if the collector found
     it), and the rest keep the function native.

   A fn-pointer callee type → `call.ind`.

   **Tail calls** (`TailCall`, `become`): the arguments are staged in the outgoing block as
   for a call, then `tail_call fn` for a VM function of this image, and `tail_call.ind`
   otherwise: on a fn pointer, the vtable entry of a virtual call, or `addr.sym` of an
   upstream or native callee. Calls of intrinsics and non-Rust ABIs stay native.
2. **Arguments**: the argument operands are copied into the outgoing argument block at
   `fp + frame_size + H` (the callee frame's argument block, in `arg_block` layout) by plain
   `mov`/`copy` instructions immediately before the call. MIR call arguments are operands
   (locals or constants), so no other call runs between building the block and the call. For
   `#[track_caller]` callees, the location is appended ([Caller location](#caller-location)).
3. **Destination**: the call instruction names the caller's destination slot. A destination
   behind a deref is first written to a temporary slot, then stored.
4. **Unwind**: if `unwind` is `Cleanup(bb)`, a cleanup table entry is recorded for this
   call's pc ([Unwinding](#unwinding)).

Functions with unsized parameters (`unsized_fn_params`) are not lowered: they stay native.

### Caller location

Mirrors cg_ssa's `get_caller_location`:

- The location for a call site is a `core::panic::Location` constant in the constant pool,
  built from the call's `source_info` span. If the current function is itself
  `#[track_caller]` and the span comes from its body, the location is instead the function's
  own incoming location argument (the last field of its argument block).
- `#[track_caller]` VM callee: the location is the last field of the argument block.
- `#[track_caller]` native callee: `call_ptrN` with one extra trailing `&'static Location`
  argument, calling the callee instance's own symbol (not its `ReifyShim`). That signature has
  the same ABI as the callee with its implicit location argument (`rustc_ty_utils/src/abi.rs:600`).
- The `caller_location` intrinsic yields the same value.

## Unwinding

- Every call-like instruction (`call`, `call.ext`, `call.ind`, `island.catch`) whose MIR
  terminator has an `unwind` action records a cleanup entry keyed by its code offset:
  - `UnwindAction::Cleanup(bb)` → jump to `bb`
  - `UnwindAction::Terminate(reason)` → jump to a stub after the function's blocks that
    calls the reason's lang item, like cg_ssa's terminate block, so the message and the
    panic hook run as natively. One stub per reason the function uses
  - `UnwindAction::Continue` → no entry: unwinding leaves the frame
  - `UnwindAction::Unreachable` → no entry
- Calls inside cleanup blocks carry `Terminate`, so a panic during unwinding aborts, as with
  native code.
- The `catch_unwind` intrinsic is an island (`ryo_island_catch_unwind<Data>`, a plain
  `island`: the intrinsic is `rustc_nounwind`). Its `try_fn`/`catch_fn` operands are fn
  pointers, so VM functions are reached through their portals: a panic in the VM leaves the
  portal natively and the intrinsic catches it.
- A panic stays counted by std while the VM unwinds (`std::thread::panicking()` is true in
  VM cleanup code, so drops and `Mutex` poisoning behave as natively): `call_catching` and
  `resume_unwind_from_vm` use the panic runtime's own entry points, not std's
  `catch_unwind`/`resume_unwind` ([vm.md](vm.md#modules)).
- Islands whose operation can unwind (call templates, `drop_in_place`, some intrinsics) are
  emitted as `island.catch` unless the unwind action is `Unreachable`, whether or not there
  is a cleanup entry. All others are plain `island`.

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
- Pointers to VM functions in constants (vtables, fn-pointer constants) point at the portal, so
  native code can call them too.
- **Vtables**: cg_llvm emits vtables as private, unnamed constants, so there is no symbol to
  relocate against. Vtables that bytecode needs (for unsizing) are therefore put in the
  image's own constant pool, from `tcx.vtable_allocation`, with entries relocated to portals or
  native symbols. Vtable addresses aren't guaranteed unique, so a second copy is fine.
  Allocations are walked recursively, and image vtables are roots of the portal-needed
  computation ([backend.md](backend.md#pipeline)).
- On PE, pointers to functions and statics that another crate or library defines (those
  whose `sym` slot would be indirect, [platforms.md](platforms.md)) can't be link-time
  relocated: they need `__imp_` indirection. Allocations containing them directly go into
  the image's writable `fixups` area instead of the pool, with one fixup per such pointer
  (against an indirect slot; functions and foreign statics of static libraries also get a
  direct slot, as for code references), and registration patches them once. Their address
  is `addr.data`, and an `Indirect` constant is copied out of them with a load. Allocations
  that only point at such allocations stay in the pool, with intra-image relocations into
  the writable section. This is the only load-time fixup.

## Status

The lowering lives in `backend/src/rustc_api/lower/`, one module per concern (`mod.rs` lists
them). Implemented: everything above for integers, `bool`, `char`, `f32`/`f64`, places,
references, aggregates, enums, all casts (`f16`/`f128` ones through `as_cast`), field-by-field
unsizing, unsized tails at dynamic offsets, `size_of_val` of any unsized type, `Repeat`, wide
pointer compares, 128-bit `mul`/`div`/`rem`/`mul.ovf` islands, constants (pool allocations with
relocations, type ids, vtables, and on PE the fixup area for constants pointing at imports),
thread locals (`ThreadLocalRef` through the TLS shim), switches,
asserts, drops (VM call of the glue, `drop_in_place` island, vtable drop for trait objects),
unwinding (cleanup entries, terminate stubs, the `catch_unwind` island) and calls: VM `call`,
`call.ext`, `call.ind` for fn pointers and virtual calls (`dyn Fn*` included), tail calls, and
islands (`call` for safe Rust fn items and safe intrinsics, `call_ptrN`/`call_cN` through
`addr.sym` otherwise), every shim kind with a body, plus the intrinsics listed in Calls.
`#[track_caller]` functions are VM functions with
`portal_tcN` portals (up to 16 arguments), and caller locations follow cg_ssa, including a
`#[track_caller]` function's own incoming location and the `caller_location` intrinsic.
`SwitchInt` and `Assert` fuse with the compare that feeds them (`br.cmp`). Locals with storage
markers share slots; there is no copy propagation yet.
Still `NeedsNative`, with the reason in `RYO_STATS=2`: `#[track_caller]` functions with more
than 16 arguments, `ThreadLocalRef` of foreign thread locals, `f16`/`f128` arithmetic and
compares, unsafe intrinsics without a VM lowering, wrapper or fallback body (128-bit atomics,
SIMD intrinsics with constant operands, …), coroutines and extern-type tails.
The PE fixup area is only cross-checked (objects and links), not run, like the rest of the
PE column ([platforms.md](platforms.md)).

## Bytecode optimization

After lowering, a peephole pass:

- folds constant offsets into memory operands, and selects the `k = 0` and `.imm` forms
- removes `mov`s of moved-from locals by copy propagation, which matters at `-O0`, where
  MIR has had little of it
- forms superinstructions, choosing the pairs from `y bench` profiles (for example
  `add.imm` + `br.cmp` loop latches, `load` + `br.cmp`). This is
  `ryo_bytecode::peephole::fuse`, run on each function's finished `CodeBuf`: it only rewrites
  the opcode word of each pair's first instruction, so it can run before or after branch
  targets are patched ([vm.md](vm.md#superinstructions))
