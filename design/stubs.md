# Stubs: islands

- **Island** (VM → native): one operation the VM can't do itself (a call of an `extern "C"`
  function or of a callee without a symbol, an intrinsic, a SIMD op, …), called directly
  from VM code by the `island` instruction.
- No stub is needed the other way: VM functions are native functions of their signatures,
  and native code calls them at their own symbols ([VM functions as native
  functions](#vm-functions-as-native-functions)). Rust-ABI calls from VM code to native
  code need none either ([vm.md](vm.md#calls-and-islands)).

Islands are **instances of generic templates in `ryo_rt`**. The backend instantiates them and
adds them to the native CGU ([backend.md](backend.md#pipeline)), and cg_llvm compiles them
from `ryo_rt`'s MIR in its metadata, like any other upstream generic. Whatever is specific to
one stub (types, callee) is a generic argument. The calling-convention
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
- **Lookup**: templates are tagged with `#[rustc_diagnostic_item = "ryo_island_call"]`,
  `"ryo_island_call_c2"` etc., and the backend finds them through
  `tcx.diagnostic_items(ryo_rt_cnum)`. `get_diagnostic_item` only searches user-visible crates
  (`rustc_passes/src/diagnostic_items.rs:81`).

## Islands (VM → native)

- **Signature** (uniform): `unsafe fn(fp: *mut u8, ops: *const u32) -> u32` (Rust ABI).
  - `fp` is the VM frame pointer.
  - `ops` points at the island's operand array in the image's code constants: the operand
    words of the `island` instruction ([vm.md](vm.md#calls-and-islands)).
  - The return value is 0, and VM code ignores it.
  - **Called directly**: VM code calls the island through its symbol slot,
    `lea rdi, [rsp + F]; lea rsi, [rip + ops]; call [rip + isl]` (`mov rdi, rbp` with a
    frame pointer, [vm.md](vm.md#frames)), with the Rust ABI's argument
    registers (`rcx`/`rdx` and 32 bytes of shadow space on PE). Rust ABI, because Rust-ABI
    functions may unwind: a panic leaves the island natively, into the VM frame
    ([Unwinding](#unwinding)). With `extern "C"`, a panic couldn't leave the island
    (nounwind plus an abort guard).
- **Frame access**: templates see the frame only through raw pointers. Each operand word
  `ops[i]` is a frame offset, and operand `i` is the slot at `fp + ops[i]`
  (`ryo_rt::island::slot`).
- **Dedup**: one instance per (template, generic args). The offsets are runtime operands, so
  one instance serves every site.

### Templates

In `ryo_rt::island`, much of it macro-generated:

```rust
// direct call of a safe Rust fn without a symbol; F = the callee's FnDef type (ZST)
pub unsafe fn call<F: FnOnce<Args, Output = R>, Args: Tuple, R>(fp: *mut u8, ops: *const u32) -> u32 {
    const { assert!(size_of::<F>() == 0) };
    let f: F = unsafe { mem::zeroed() };
    let args = unsafe { slot::<Args>(fp, ops, 0).read() };   // args packed in a frame slot
    unsafe { slot::<R>(fp, ops, 1).write(f.call_once(args)) };
    0
}
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
  | `call_cN` | argument block, `(A0, …, A{N-1})` in `arg_block` layout | destination, `R` | slot holding the fn pointer |
  | `drop_in_place` | slot holding the `*mut T` | | |
  | intrinsic wrappers | the inputs in order, then the destination | | |

  The argument block is read as one tuple (`slot::<(A0, …)>(fp, ops, 0).read()`), which the
  lowering writes in the outgoing area ([lowering.md](lowering.md#frame-slots)).
- Operations the VM has no instruction for, with the same operand convention: the 128-bit
  `mul_w128`, `div_{s,u}_w128`, `rem_{s,u}_w128`, `mul_ovf_{s,u}_w128`, and
  `as_cast<A, B>` for numeric casts from or to `f16`/`f128` (through `ryo_rt::island::AsCast`,
  implemented for every pair of an `f16`/`f128` with any integer type, `isize`/`usize` included, or float type).
- The intrinsic wrappers, tagged `"ryo_island_<name>"`: `sqrtf32`, `sqrtf64`, `powif32`,
  `powif64`, `fmaf32`, `fmaf64`, `compare_bytes`, `raw_eq<T>`, `catch_unwind<Data>` (`ops`:
  `try_fn`, `data`, `catch_fn`, destination), and
  the SIMD intrinsics without constant operands (`simd_add<T>`, `simd_eq<T, U>`,
  `simd_splat<T, U>`, `simd_select<M, T>`, the reductions, …), each generic exactly like its
  intrinsic, so the lowering passes the intrinsic's generic args unchanged.
  `catch_unwind`'s fn pointers are often VM functions (`do_call`, `do_catch`), called
  natively: a panic in them unwinds natively into the intrinsic's landing pad in the
  island.
- A non-generic template (`compare_bytes`, …) has one instance, `ryo_rt`'s own: the image
  links to it instead of adding a copy to the native CGU (it isn't codegened locally).
- `call_cN` exist for arities 0..=16.
- `call` is only for callees without a symbol (intrinsics the lowering calls as fn items);
  everything with a symbol is a direct `call.sym`. It relies on `FnOnce`, which is only
  implemented for safe, Rust-ABI, non-variadic fns without `#[target_feature]`
  (`rustc_type_ir/src/ty_kind.rs:1131`, `candidate_assembly.rs:591`), and isn't used for
  `#[track_caller]` callees (`Location::caller()` would point into `ryo_rt`).
- Generic argument types are fine for FFI: the fn-pointer ABI is computed after
  monomorphization from concrete layouts, and `improper_ctypes` doesn't apply, because the
  island signature only has raw pointers.

`#[track_caller]` native callees are no gap: they are called directly at their symbol,
with the `&'static Location` as the last ABI input ([lowering.md](lowering.md#caller-location)).
This covers `panic_bounds_check` and the other panic lang items that `Assert` calls.

What becomes an island:

- calls of `extern "C"` functions (FFI, local `extern "C" fn`s), and of safe callees
  without a symbol
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
- `call_cN` arities above 16
- functions with unsized parameters (`unsized_fn_params`)
- functions whose locals or arguments, including the argument block of any island call they make,
  contain a type with alignment above 16: VM frames only guarantee 16
  ([lowering.md](lowering.md#frame-slots)), and templates access slots aligned

### Unwinding

Templates don't catch, and the VM doesn't either: a panic in an island unwinds natively out
of it into the calling VM frame, whose LSDA sends it to the frame's landing pad or on to its
caller ([vm.md](vm.md#unwinding)). Whether an island call is a call site at all follows the
MIR unwind action ([lowering.md](lowering.md#unwinding)): islands that can't unwind, and
calls with `UnwindAction::Unreachable`, are none, so unwinding out of them aborts.

## VM functions as native functions

There are no portals: the image object defines each VM function's real symbol on its code
([backend.md](backend.md#pipeline), [vm.md](vm.md#image-format)), and the code follows the
platform calling convention for the function's Rust-ABI signature
([vm.md](vm.md#calls-and-islands)). Native callers, other crates, fn pointers and vtables
link to it unchanged.

- **Symbol and linkage**: when native code or the image refers to the function by name
  (`partition.rs`, `need_symbol`), the symbol is global, with the function's linkage and
  visibility from the partition; an `Internal` one becomes hidden, since the image is a
  separate object. Otherwise it is local. `#[no_mangle]`/`#[export_name]` VM functions keep
  their `SymbolExportLevel::C` export through the exported-symbols queries
  ([backend.md](backend.md#query-overrides)).
- **`#[track_caller]` functions** take their `Location` as the last ABI input, as natively
  (`rustc_ty_utils/src/abi.rs:600`). Their `Shim(Reify)` instance (fn pointers, vtables)
  has its own symbol and no `Location`.
- **Indirect args**: callers may mark them `ReadOnly`/`CapturesNone` from the original MIR
  (deduced param attrs, `rustc_ty_utils/src/abi.rs:652-660`). The prologue copies each
  `Indirect` input into its own home slot, so the function body never writes the caller's
  memory. A tail call reuses that memory as rustc does ([vm.md](vm.md#calls-and-islands)).
- **Unwinding**: a panic in a VM function unwinds natively into its caller.

## Program entry: `main`

cg_ssa only emits the C `main` wrapper if the CGU contains the entry fn's own mono item
(`maybe_create_entry_wrapper`, `rustc_codegen_ssa/src/base.rs:508-517`). With a VM `main`,
the entry fn is a VM function in the image instead, so the backend provides the wrapper itself, as a template
instance:

```rust
// vm/rt/src/entry.rs
unsafe extern "C" {
    // defined by the binary crate's image: the address of the entry fn
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
  fn's symbol. Only binaries instantiate `c_main`, so dylibs and cdylibs never reference the
  symbol.
- `#[no_main]` crates and `-Zcrate-attr=no_main` skip this, exactly like cg_ssa.

## Calls between VM and native code

- **VM → VM, same image**: `call fn`, a direct machine call, with no stub.
- **Calls with a symbol** (upstream instances, local native Rust-ABI functions, VM
  functions of other images): `call.sym` on the callee's symbol (`call.sym.ind` through
  `__imp_` on PE). The backend doesn't need to know whether upstream compiled it to
  bytecode: both are native functions of the same signature.
- **Indirect calls** (fn pointer, `dyn` vtable): `call.ptr` for Rust-ABI pointers, the
  `call_cN` island for `extern "C"` ones.
- **Separate `ryo_rt` copies**: each cdylib or staticlib carries its own `ryo_rt`, with its
  own registry. Calls across them are plain native calls, so nothing depends on which copy
  registered the callee.
