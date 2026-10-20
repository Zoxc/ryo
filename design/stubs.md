# Stubs: portals and islands

- **Portal** (native → VM): a native function with the real symbol and signature of a VM
  function. Calling it enters the VM.
- **Island** (VM → native): one operation the VM can't do itself (a call to native code, an
  intrinsic, a SIMD op, …), run from the bytecode with the `island` instruction.

Both are **instances of generic templates in `ryo_rt`**. The backend instantiates them and
adds them to the native CGU ([backend.md](backend.md#pipeline)), and cg_llvm compiles them
from `ryo_rt`'s MIR in its metadata, like any other upstream generic. Whatever is specific to
one stub (types, callee, VM function id) is a generic argument. The calling-convention
details (`fn_abi_of_instance`, `PassMode`, …) come from cg_llvm.

- **Constructing instances**:
  - The instance itself: `Instance::new_raw(def_id, args)` (`ty/instance.rs:509`).
  - Const args: `ty::Const::from_bits(tcx, id, typing_env, u64)` (`ty/consts.rs:217`).
  - `F`: the callee's `FnDef` type.
  - Fn-pointer and argument types: taken from the callee's monomorphized signature.
- **MIR availability**: generic MIR is only encoded in metadata for defs in `reachable_set`
  (`rustc_metadata/src/rmeta/encoder.rs:1116-1120`). So every template is `pub` and
  reachable from the crate root, and helpers are reached through them.
- **Instance identity**: a template instance's symbol is mangled from its generic args, so
  two crates instantiating the same island get the same symbol. Islands therefore follow
  the share-generics rules ([backend.md](backend.md#pipeline), "Upstream copies"), or are
  `Internal` when sharing is off.
- **Lookup**: templates are tagged with `#[rustc_diagnostic_item = "ryo_portal"]`,
  `"ryo_island_call_c2"` etc., and the backend finds them through
  `tcx.diagnostic_items(ryo_rt_cnum)`. `get_diagnostic_item` only searches user-visible crates
  (`rustc_passes/src/diagnostic_items.rs:81`).

## Islands (VM → native)

- **Signature** (uniform): `unsafe fn(fp: *mut u8, ops: *const u32) -> u32` (Rust ABI).
  - `fp` is the VM frame pointer.
  - `ops` points at the operand words that follow the `island` instruction
    ([vm.md](vm.md#calls-and-islands)).
  - The return value is the successor index: 0 for single-target operations, and the arm for
    multi-target ones. Unwinding is never signalled through it.
  - Rust ABI, because the VM calling the island is Rust code from the same toolchain, and
    Rust-ABI calls may unwind. With `extern "C"`, a panic couldn't leave the island (nounwind
    plus an abort guard). With `extern "C-unwind"`, `ryo_rt`'s calls through island pointers
    would count as FFI-unwind calls, which would make `ryo_rt` require `panic=unwind`
    (`ffi_unwind_calls.rs`) and break `panic=abort` programs.
- **Frame access**: templates see the frame only through raw pointers. Each operand word
  `ops[i]` is a frame offset, and operand `i` is the slot at `fp + ops[i]`
  (`ryo_rt::island::slot`).
- **Dedup**: one instance per (template, generic args). The offsets are runtime operands, so
  one instance serves every site.

### Templates

In `ryo_rt::island`, much of it macro-generated:

```rust
// direct call of a safe Rust fn; F = the callee's FnDef type (ZST)
pub unsafe fn call<F: FnOnce<Args, Output = R>, Args: Tuple, R>(fp: *mut u8, ops: *const u32) -> u32 {
    const { assert!(size_of::<F>() == 0) };
    let f: F = unsafe { mem::zeroed() };
    let args = unsafe { slot::<Args>(fp, ops, 0).read() };   // args packed in a frame slot
    unsafe { slot::<R>(fp, ops, 1).write(f.call_once(args)) };
    0
}
// through a fn pointer: unsafe fns, #[target_feature] fns (coercible to `unsafe fn` pointers),
// indirect calls that don't hit a VM function
pub unsafe fn call_ptr2<A, B, R>(fp: *mut u8, ops: *const u32) -> u32 { /* f: unsafe fn(A, B) -> R */ }
// FFI, one per arity, generic over the argument types
pub unsafe fn call_c2<A, B, R>(fp: *mut u8, ops: *const u32) -> u32 { /* f: unsafe extern "C" fn(A, B) -> R */ }
// intrinsics: one wrapper each, generic like the intrinsic itself
pub unsafe fn simd_add<T>(fp: *mut u8, ops: *const u32) -> u32 { … }
// drop glue; the operand slot holds a *mut T (wide if T is unsized)
pub unsafe fn drop_in_place<T: ?Sized>(fp: *mut u8, ops: *const u32) -> u32 { … }
```

- **Operand conventions** (the lowering and the VM build `ops` this way):

  | Template | `ops[0]` | `ops[1]` | `ops[2]` |
  |---|---|---|---|
  | `call` | argument block, `Args` | destination, `R` | |
  | `call_ptrN`, `call_cN` | argument block, `(A0, …, A{N-1})` in `arg_block` layout | destination, `R` | slot holding the fn pointer |
  | `drop_in_place` | slot holding the `*mut T` | | |
  | intrinsic wrappers | the inputs in order, then the destination | | |

  The argument block is read as one tuple (`slot::<(A0, …)>(fp, ops, 0).read()`), so it is
  exactly the callee's argument block ([lowering.md](lowering.md#frame-slots)). For
  `call.ext`/`call.ind`, the VM passes `[outgoing block, d, fn pointer slot]`: for
  `call.ind` that is `p`, for `call.ext` a slot the VM writes the resolved address into.
- The first set of intrinsic wrappers: `sqrtf32`, `sqrtf64`, `powif32`, `powif64`, `fmaf32`,
  `fmaf64`, `simd_add`, `simd_sub`, `simd_mul`, tagged `"ryo_island_<name>"`.
- `call_cN` exist for arities 0..=16. `call_ptrN` exist for 0..=17: 16, plus a trailing
  `&'static Location` for `#[track_caller]` callees ([lowering.md](lowering.md#caller-location)).
- `call.ext`'s native fallback is always a `call_ptrN` (Rust ABI): upstream instances are Rust
  functions, and Rust-ABI calls never count as FFI-unwind calls.
- `call` relies on `FnOnce`, which is only implemented for safe, Rust-ABI, non-variadic fns
  without `#[target_feature]` (`rustc_type_ir/src/ty_kind.rs:1131`,
  `candidate_assembly.rs:591`). Everything else goes through the pointer variants.
- Generic argument types are fine for FFI: the fn-pointer ABI is computed after
  monomorphization from concrete layouts, and `improper_ctypes` doesn't apply, because the
  island signature only has raw pointers.

`#[track_caller]` native callees are no gap: they go through `call_ptrN` with an explicit
trailing `&'static Location`, to the callee instance's own symbol
([lowering.md](lowering.md#caller-location)). This covers `panic_bounds_check` and the other
panic lang items that `Assert` calls.

What becomes an island:

- calls to native code: cg_llvm-compiled items, upstream crates, FFI
- intrinsics the VM doesn't implement, SIMD operations, float ops that need libm
  (`sqrtf64`, …), unusual casts
- drop glue of types the VM doesn't drop itself

### Template gaps

These make the containing function native ([backend.md](backend.md#pipeline), step 2):

- inline asm
- C-variadic calls
- foreign ABIs other than `C` (`C-unwind`, `sysv64`, `win64`, `efiapi`, `vectorcall`, …).
  `C-unwind` in particular can't be a template: `ryo_rt` is built with `panic=unwind`, so a
  template body calling through an `extern "C-unwind"` pointer would give `ryo_rt` a
  required panic strategy of `Unwind` (`rustc_mir_transform/src/ffi_unwind_calls.rs:83-175`),
  and `panic=abort` programs would fail to link. The check looks at the template's own body
  in `ryo_rt`, not at its instances.
- LLVM intrinsics (`InstanceKind::LlvmIntrinsic`, the `link_name = "llvm.*"` functions used
  by `std::arch`): they have no MIR and an `unadjusted` ABI
- arities above 16
- functions with unsized parameters (`unsized_fn_params`)

### Unwinding

Templates don't catch. The VM calls islands that can unwind (the call templates,
`drop_in_place`, some intrinsics) through `ryo_rt::unwind::call_catching`:

```rust
#[inline(never)]
pub unsafe fn call_catching(f: unsafe fn(*mut u8, *const u32) -> u32, fp: *mut u8,
                            ops: *const u32, payload_out: *mut RawPayload) -> CatchResult
#[repr(C)] pub struct CatchResult { pub succ: u32, pub unwinding: bool }
#[repr(C)] pub struct RawPayload { pub data: *mut (), pub vtable: *mut () }  // RawPayload::NONE = nulls
```

It is a non-generic `catch_unwind` wrapper that returns the successor and an "unwinding"
flag separately. The VM passes a pointer to the current entry record's payload slot as
`payload_out`, and on a panic `call_catching` writes the payload there (the
`Box<dyn Any + Send>` as its raw pointer pair, overwriting the slot, which must be
`RawPayload::NONE`) ([vm.md](vm.md#unwinding)). The VM then runs the
function's cleanup blocks ([vm.md](vm.md#unwinding)). Islands that can't unwind are called
directly.

## Portals (native → VM)

Every VM function that native code may reach gets a portal. That covers exported functions,
functions whose address is taken, ones called from a native function, vtable entries,
upstream-visible generics and `main`. A portal is an instance of:

```rust
// vm/rt/src/portal.rs
#[inline(never)]
pub extern "rust-call" fn portal<Args: Tuple, R, const ID: u64>(args: Args) -> R {
    let mut ret = MaybeUninit::<R>::uninit();
    let args = ManuallyDrop::new(args);         // the VM takes ownership of the args
    let mut payload = RawPayload::NONE;
    let st = unsafe { crate::vm::enter(ID, &raw const args as *const u8, ret.as_mut_ptr() as *mut u8, &mut payload) };
    if st != 0 { unsafe { crate::unwind::resume_unwind_from_vm(payload) } }
    unsafe { ret.assume_init() }
}
```

`portal_tc0..N<A, B, …, R, const ID>` are the `#[track_caller]` variants. They are Rust-ABI and
arity-specific, because `#[track_caller]` is rejected on any other ABI (E0737,
`rustc_ast_passes/src/ast_validation.rs:1966`). They pass `Location::caller()` to the VM.

- **ABI**: `rust-call` spreads the last tuple argument (`rustc_ty_utils/src/abi.rs:548-561`),
  and `Rust`/`RustCall` canonicalize to the same `CanonAbi::Rust`
  (`rustc_target/src/spec/abi_map.rs:99`). So `portal::<(A, B), R, ID>` has the ABI of
  `fn(A, B) -> R`. `Args` is exactly the inputs of the original instance's
  `fn_sig_for_fn_abi`, flattened, which is exactly the argument block
  ([lowering.md](lowering.md#frame-slots)):
  - **Closures and other `rust-call` items** (`Shim(ClosureOnce)`, `Shim(FnPtr)`): the
    env/self argument as that signature has it (`&Self`, `&mut Self` or `Self`, depending on
    closure kind), then the tupled args spread out, which is what `fn_abi` does
    (`abi.rs:553-566`).
  - **Vtable shims**: the receiver is `*mut Self` (`abi.rs:50-54`).
  - **`#[track_caller]` functions**: `portal_tcN`. The implicit `Location` arg comes last in
    both (`abi.rs:600`). Their `Shim(Reify)` instance (used for fn pointers and vtables) has
    its own symbol and no `Location`, so it gets a plain `portal`.
- **Symbol and linkage**: the `symbol_name` override gives the portal instance the original
  instance's symbol, so callers (native code, other crates, fn pointers, vtables) link to it
  unchanged. Linkage/visibility are copied from the original's entry in the partition.
  `#[no_mangle]`/`#[export_name]` VM functions keep their `SymbolExportLevel::C` export, and
  the portal is listed in the exported-symbols queries with that level, so internalization
  and LTO keep it. `#[used]` only applies to statics, which are native anyway.
- **One portal per instance**: each instance of a generic VM function has its own portal (the
  ID is per instance). Upstream generic instances that resolve to the upstream crate's shared
  copy (`-Zshare-generics`) get no local portal.
- **Indirect args**: callers mark indirect args `ReadOnly`/`CapturesNone` based on the
  original function's MIR (deduced param attrs, `rustc_ty_utils/src/abi.rs:652-660`). The
  portal copies its spread arguments into the local `args` tuple, so the VM never writes to
  the caller's memory.
- **`ID`**: `StableCrateId`-derived crate hash (high 32 bits) and the function index in that
  crate's image (low 32 bits). `vm::enter` resolves it through the registry and caches the
  result.

## Program entry: `main`

cg_ssa only emits the C `main` wrapper if the CGU contains the entry fn's own mono item
(`maybe_create_entry_wrapper`, `rustc_codegen_ssa/src/base.rs:505-513`). With a VM `main`,
the CGU holds a portal instead, so the backend provides the wrapper itself, as a template
instance:

```rust
// vm/rt/src/entry.rs
unsafe extern "C" {
    // defined by the binary crate's image: the address of the entry fn's portal
    static __ryo_main: *const ();
}
// S = FnDef type of the `start` lang item (std's private `lang_start::<T>`)
pub extern "C" fn c_main<S, T, const SIGPIPE: u8>(argc: c_int, argv: *const *const c_char) -> c_int
where
    S: FnOnce(fn() -> T, isize, *const *const u8, u8) -> isize,
{
    const { assert!(size_of::<S>() == 0) };
    let start: S = unsafe { mem::zeroed() };
    let main: fn() -> T = unsafe { mem::transmute(__ryo_main) };
    start(main, argc as isize, argv as *const *const u8, SIGPIPE) as c_int
}
```

- The body after loading `__ryo_main` is the `pub` helper `entry::start_main::<S, T, SIGPIPE>(main,
  argc, argv)`, which tests call directly; a test binary can also define `__ryo_main` itself.
- `lang_start` is private in std, so the template can't name it. The backend resolves the
  `start` lang item as cg_ssa does (`require_lang_item(LangItem::Start)` +
  `Instance::expect_resolve` with `[T]`, `rustc_codegen_ssa/src/base.rs:566-583`), and passes
  its `FnDef` type as `S`. A private safe fn item still implements `FnOnce`.
- The backend instantiates `c_main::<S, T, SIGPIPE>`, with `T` = `main`'s return type and
  `SIGPIPE` = `EntryFnType::Main { sigpipe }`, as cg_ssa passes it. It gives the instance the
  symbol `main` (`target.entry_name`, also right for MSVC) through the `symbol_name`
  override, and forces `External` linkage with default visibility. As an instance of an
  upstream generic, it would otherwise be internal or hidden. It adds the instance and its
  neighbors to the native CGU.
- The binary crate's image defines `__ryo_main`, a pointer slot relocated against the entry
  fn's portal. Only binaries instantiate `c_main`, so dylibs and cdylibs never reference the
  symbol.
- `#[no_main]` crates and `-Zcrate-attr=no_main` skip this, exactly like cg_ssa.

## Calls between VM and native code

- **VM → VM, same image**: `call fn`, straight through the bytecode, with no stub.
- **Calls to upstream instances**: `call.ext` on the callee's symbol, for every callee whose
  instance comes from another crate. The backend doesn't need to know whether upstream
  compiled it to bytecode. On first use, the site cache resolves the symbol: either it is a
  portal of a registered VM function (later calls go straight to the bytecode), or it is
  native (later calls go through the instruction's `call_ptrN` island)
  ([vm.md](vm.md#calls-and-islands)).
- **Indirect calls** (fn pointer, `dyn` vtable): `call.ind`, with a site cache for the last VM
  target. Non-VM targets go through the `call_ptrN` island for the signature.
- **Separate `ryo_rt` copies**: each cdylib or staticlib carries its own `ryo_rt`, with its own
  registry. A function pointer into another copy's bytecode isn't recognized by `lookup_addr`,
  so it goes through the native path (island → portal). Rust dylibs and the exe that links
  them share one copy.
