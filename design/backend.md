# Backend

`backend/src/lib.rs` exports `__rustc_codegen_backend() -> Box<dyn CodegenBackend>`, which
returns `RyoBackend { llvm: LlvmCodegenBackend::new() }`. Most trait methods forward to
`llvm` (`init`, `target_config`, `target_cpu`, `metadata_loader`, `link`, printing).

## Pipeline

Steps 1–4 run **inside our `collect_and_partition_mono_items` override**, not in
`codegen_crate`. Metadata encoding runs before `codegen_crate`
(`rustc_interface/src/passes.rs:1314` vs `:1338`), and when generics are shared it already
calls the query through `exported_generic_symbols` (`symbol_export.rs:330`). The query is
`eval_always` and computed once. The provider stores the VM results in a `OnceLock`,
and `codegen_crate` reads them.

1. **Collect.** Call the original `collect_and_partition_mono_items` provider (saved in
   `provide`). The collector (`collect_crate_mono_items`) is `pub(crate)` in
   `rustc_monomorphize`, so the query is the only entry point to it. `rustc-ryo` forces
   `-Ccodegen-units=1`, so partitioning is cheap (`place_mono_items`, one merge pass,
   internalize), and the single CGU it returns is useful as-is:
   - its item list is the work list
   - each item's `linkage`/`visibility` is what rustc decided. The image object defines each
     VM function's symbol with it ([stubs.md](stubs.md#vm-functions-as-native-functions)).
   - VM functions that are `Internal` and not referenced by native code get a local symbol.
     "Referenced by native code" means referenced by any of:
     - a native function, or a stub neighbor (via `items_of_instance`)
     - the initializer of a native static: the provenance of its allocation, from
       `eval_static_initializer`, covering fn pointers and vtables in statics
     - the entry fn and the `c_main` entry wrapper
       ([stubs.md](stubs.md#program-entry-main))
     - any vtable that the image or a native item references
     - a `sym` operand of a `global_asm!` (resolved like the collector does,
       `rustc_monomorphize/src/collector.rs:493-535`)

     VM functions referenced that way, those that are not `Internal`, and those the image
     refers to by symbol (fn-pointer constants, vtables, `call.sym`) get a global symbol
     (`partition.rs`, `need_symbol`; `objfile.rs`, `global_function`), with their linkage
     and visibility; an `Internal` one becomes hidden.

   The backend errors if `sess.codegen_units()` isn't 1.
2. **Classify** each mono item:
   - `Fn(instance)` → VM, unless something in it can't be expressed as a VM op or an island
     template. Those functions stay native as a whole:
     - `#[naked]` functions
     - EII implementations (`#[<eii declaration>]`): cg_llvm defines the declaration's symbol
       as a forwarder while predefining the implementation (`add_function_aliases`)
     - functions with a `#[linkage]` other than `external` or `internal`: another object's
       definition may replace a weak or linkonce one, which the image's direct `call`s would
       bypass; `available_externally` defines nothing; PE has no plain weak definitions
     - inline asm
     - calls to C-variadic functions
     - functions with non-Rust ABIs defined in Rust (`extern "C" fn`): VM code follows only
       the Rust ABI's convention
     - signatures whose arguments or return the VM can't place as LLVM does (other
       `PassMode`s, and on Win64 `i128`, `f16` and `f128`, [vm.md](vm.md#calls-and-islands))
     - functions with unsized parameters
     - calls to `C-unwind` functions and LLVM intrinsics
     - the other template gaps ([stubs.md](stubs.md#template-gaps))

     The lowering reports these as `Err(NeedsNative(reason))`.

     The lowering assumes every candidate is a VM function. A function that calls a
     candidate which then stays native is lowered again, with an island for that call,
     until the set of VM functions doesn't change.

     Never VM: everything in a `proc-macro` crate (it keeps VM code out of rustc's own process,
     and proc macros gain nothing from it), everything in a panic runtime crate
     (`#![panic_runtime]`: `panic_unwind`, `panic_abort`),
     `ryo_rt`'s own instances, and everything when
     `RYO_NO_VM` is set ([Debugging switches](#debugging-switches)).
   - `Static`, `GlobalAsm` → native. Statics are data, and cg_llvm handles relocations,
     linkage and TLS.
3. **Lower VM functions** with `par_map` over the list. This is the "single code unit,
   parallel loop": every function is lowered on its own straight into machine code plus a
   relocation list ([lowering.md](lowering.md), [vm.md](vm.md#machine-code)), in the mode
   `asm_mode` gives: `fp` passing as `ryo_rt`'s `FP_ARG` says (the backend evaluates the
   const), a frame pointer only where rustc's LLVM backend would keep one, or `FP_ARG`
   or PE require it ([vm.md](vm.md#frames)), loop alignment unless `RYO_ASM_ALIGN=0`, inline instructions, the JIT's counters
   (always, [vm.md](vm.md#jit-records-and-counters)), and the target's object
   format. The
   results are merged in one pass at the end. An operation the VM doesn't support becomes an
   `island` instruction whose `isl` operand is an *island* relocation (template + generic
   args). The merge pass deduplicates islands (same template + args → one instance), assigns
   function indices and symbols, rewrites each function's relocation targets to them,
   and adds the function to the image writer under its own symbol. The handlers and `ryo_probe_stack` the code
   calls, the JIT records' `ryo_jit_trip_entry` and `ryo_jit_trip_osr`, and `rust_eh_personality` on ELF, are added to the image's LTO roots
   ([Query overrides](#query-overrides-provide)).
4. **Build the native CGU.** This is a copy of the original CGU, with the VM functions removed
   and the stub instances (islands and `c_main`) added. Our override returns exactly this CGU,
   so `self.llvm.codegen_crate(tcx)` compiles only what we ask for.
   - **Stub neighbors**: the collector never saw the stubs, so whatever a template body uses
     is missing. Examples: `f.call_once(args)` on a FnDef resolves to a `Shim(FnPtr)`
     (`rustc_ty_utils/src/instance.rs:338`), and `ptr::read::<Args>`, `MaybeUninit` methods
     and `Location::caller` are program-typed instances. cg_llvm only emits declarations for
     items outside the CGU (`rustc_codegen_llvm/src/callee.rs:75-95`). So the backend walks
     each stub instance's neighbors with the `items_of_instance` query
     (`rustc_middle/src/queries.rs:2777`, used items) until nothing new appears. It skips
     items already in the CGU. The query has already dropped what isn't codegened locally:
     the collector's `should_codegen_locally` (`collector.rs:1075`) runs on every neighbor,
     and it is public as the hook `tcx.should_codegen_locally` (`rustc_middle/src/hooks/mod.rs:90`),
     which the lowering uses for callees. Neighbors are always native, and `Internal`: only the
     stubs reference them. A neighbor that is a VM function gets a global symbol instead.
   - **Upstream copies**: before defining a stub instance or neighbor, the backend checks
     `instance.upstream_monomorphization(tcx)`. If an upstream crate exports it
     (share-generics), the image relocates against that copy instead of defining a second one,
     which would collide (`rustc_symbol_mangling/src/lib.rs:154`).
   - **Linkage**: the image is a separate object, so it can't reference `Internal` items.
     Every `Internal` item the image references (directly, or through image vtables) is
     made visible to it, without risking collisions between two ryo crates:
     - **Crate-unique symbols**: the symbols of non-generic `LocalCopy` items (`#[inline]`,
       cross-crate-inlinable) don't include the instantiating crate's hash
       (`rustc_symbol_mangling/src/lib.rs:280-299`), and their bodies can differ between
       crates (`#[rustc_inherit_overflow_checks]`, `ub_checks` follow each crate's
       settings). So merging them would be wrong. The `symbol_name` override appends
       `.ryo<local StableCrateId>` to every instance whose instantiation mode is `LocalCopy`
       and that the local crate defines (`instance.upstream_monomorphization(tcx).is_none()`),
       unless its symbol comes from its attributes (`symbol_name_from_attrs`: foreign items
       such as LLVM intrinsics, `#[no_mangle]`, `#[export_name]`,
       `#[rustc_std_internal_symbol]`), which must keep their names.
       `instantiation_mode` depends on each session's opt-level and incremental settings
       (`rustc_middle/src/mono.rs:178-185`), so an instance that is `LocalCopy` here may be
       `GloballyShared` upstream, and references to an upstream copy must keep upstream's
       symbol.
       That only depends on `instantiation_mode`, not on partitioning, so there is no query
       cycle. These items, and all other image-referenced `Internal` items whose symbols
       are already crate-unique (statics, generics), become `External` + `Hidden`.
     - **The TLS shim**, which the backend adds itself on ELF (on PE rustc creates and
       exports it, [lowering.md](lowering.md#rvalues)): the same static always gives the same
       body, so it is `WeakODR` + `Hidden`. cg_llvm puts WeakODR functions in their own comdat
       where the target supports it (`predefine_fn`, `rustc_codegen_llvm/src/mono_item.rs:80-84`),
       so copies from several crates merge.
     - On PE, hidden visibility has no effect, and exports come only from the export list, so
       nothing leaks.
     - **Linkonce items** (explicit `#[linkage = "linkonce[_odr]"]`, which keeps a function
       native): LLVM drops a linkonce definition no native code uses, so an image-referenced
       one gets the weak form of its linkage (`WeakAny`, `WeakODR`), which merges the same way
       but is kept.
     - Aliases aren't an option: cg_llvm only creates them for foreign-item DefIds
       (`mono_item.rs:54-134`).
5. **Emit the image** as one extra object with the `object` crate ([vm.md](vm.md#image-format)):
   `ImageWriter::finish_encoded` lays out the sections and unwind information, and
   `objfile.rs` writes them with their relocations, the handler calls against the handlers'
   mangled symbols (`rt_symbol`), and each function's symbol (global or local, step 1).
   The object is written to disk inside `codegen_crate`, where `tcx` is available. Our
   `codegen_crate` returns a wrapper ongoing type holding cg_llvm's `Box<dyn Any>` and the
   image path. Our `join_codegen` forwards the inner value to cg_llvm's (which downcasts it,
   `rustc_codegen_llvm/src/lib.rs:399-410`), then pushes a `CompiledModule` for the image
   (`kind: ModuleKind::Regular`, `object: Some(path)`) onto `CompiledModules.modules`
   (`rustc_codegen_ssa/src/lib.rs:124-134`), so the object list of final links includes it.
   An rlib gets it as a plain (non-Rust) archive member instead: `link` takes the module out
   before `link_rlib` and appends the object to the finished rlib afterwards (with
   `ArArchiveBuilder`). `link_rlib` would list it among the rlib's Rust objects
   (`rmeta-link`), and a downstream `-Clto` build reads bitcode from each of those and leaves
   them out of the link (`rustc_codegen_llvm/src/back/lto.rs:94-120`,
   `rustc_codegen_ssa/src/back/link.rs:3756`), which would fail and drop the image.
   The image defines one global symbol, `__ryo_image_<StableCrateId>` (the id as 16 hex
   digits), hidden: only the registry object of the same link unit references it. On ELF the
   read-only part is `.data.rel.ro.ryo_image` (writable only while relocating), the writable
   part `.data.ryo_image`, the code `.text.ryo_image`, and the unwind information
   `.eh_frame` and `.gcc_except_table.ryo_image`; on PE they are `.rdata$ryo_image`,
   `.data$ryo_image`, `.text$ryo_image`, `.pdata` and `.xdata` ([platforms.md](platforms.md)). Limitation: with `--emit=obj` (no linking) the emitted
   `.o` lacks the image, because `join_codegen` adds the image module after cg_ssa has copied
   the module objects to the outputs; and no registry object is generated then. A binary with a VM `main` also gets `__ryo_main` in this
   object ([stubs.md](stubs.md#program-entry-main)).
6. **Link** with cg_llvm's `link` (`link_binary`). The VM is part of `ryo_rt`, which links like
   any Rust dependency, so there is no native runtime library. Two additions:
   - **Registry object**: image objects in rlibs are archive members that nothing
     references, so the linker would skip them. At every final link (exe, dylib, cdylib,
     staticlib), the backend generates a small registry object. It references
     `__ryo_image_<id>` for every ryo-built crate linked *statically* into this output, which
     pulls the members in. Which crates those are:
     - The local crate is always included.
     - Upstream crates come from `CrateInfo.dependency_formats` for the output's crate type
       (`Linkage::Static`), filtered to the ryo-built ones: those whose rlib
       (`CrateInfo.used_crate_source`) has an `__ryo_image_` symbol in its archive symbol
       table, which also gives the symbol (only that table is read, not the whole rlib). The compiler has no public query for a crate's own
       dependencies (`CStore::crate_dependencies_in_postorder` is `pub(crate)`), and `link`
       has no `tcx` and doesn't receive the ongoing value
       (`rustc_codegen_ssa/src/traits/backend.rs:143-150`). `codegen_crate` stores the local
       image's symbol in a `OnceLock` on `RyoBackend` for `link`.
     - Crates already linked into an upstream Rust dylib are registered by that dylib's own
       registry object.

     **One `link_binary` call per crate type**: `link_binary` loops over
     `crate_info.crate_types` itself and gives every output the same modules
     (`rustc_codegen_ssa/src/back/link.rs:326-401`), but each output needs its own registry
     object (and an rlib none). So our `link` calls `link_binary` once per crate type,
     through cg_llvm's `link` (cg_llvm's `LlvmArchiveBuilderBuilder` is `pub(crate)`,
     `rustc_codegen_llvm/src/back/archive.rs:13`, so we can't call `link_binary` with it
     ourselves):
     - with a single-type copy of `CrateInfo` (it is `Clone`)
     - with that type's registry object added to the modules
     - with every temporary object hardlinked per call (module objects, the allocator module,
       global-asm and DWARF objects) for every call but the last, since `link_binary`
       deletes them at the end (`link.rs:444-490`)
     - with metadata: `EncodedMetadata` isn't `Clone`, and its file lives in a temp dir that
       is deleted when the value is dropped (`rustc_metadata/src/fs.rs:101-107`). So before
       the first call, the backend copies `metadata.path()` and the `stub_or_full()` bytes into
       its own directory, and every call but the last (which gets the original) reloads from
       that copy with `EncodedMetadata::from_path(path, stub_path, None)` (`encoder.rs:2384-2388`).
   - **Staticlib outputs**: nothing in the archive references the registry object, so a C
     linker consuming the staticlib would drop it, and with it the constructor and images.
     So every registry object (for every output type) defines a hidden global
     `__ryo_registry_anchor`, and every image object references it with a strong reference
     (a pointer slot relocated against it, `objfile.rs`, `write_image`). Each link unit has
     exactly one registry object, so the symbol is unique per unit. In a staticlib, any
     image the C linker takes (any VM function called) then pulls the registry object in, and with it
     the constructor and the images. (A weak reference would not cause archive extraction.)
     The limitation: one ryo staticlib per final C link. With two, both define the anchor,
     the archive extractor takes the first, and the second staticlib's images are never
     registered. With `--whole-archive`, the result is a duplicate-symbol error instead.
   - **Plain rustc can't do the final link** of ryo-built rlibs: without our backend there is
     no registry object, and `__ryo_registry_anchor` is undefined. Final links always go
     through `rustc-ryo`.
     A constructor (`.init_array.00000` on ELF, `.CRT$XCT` on PE, ahead of other constructors) calls
     `ryo_vm_register(images, n)`. The registry's own symbols are local, so a dylib and the
     exe that links it don't clash.
   - **`ryo_rt`** arrives through `--extern force:ryo_rt` (`rustc_session/src/config.rs:2621`),
     which loads it even when nothing names it. A backend has no hook for injecting an
     `extern crate`. So it is in `CrateInfo`, its generics can be instantiated, and it gets
     linked.

## Query overrides (`provide`)

- `collect_and_partition_mono_items` → the native CGU from step 4. `all_mono_items` keeps the
  original DefIds of VM functions: `is_codegened_item` is built from it
  (`rustc_codegen_ssa/src/base.rs`), and cg_llvm uses that to pick hidden visibility for
  declarations (`callee.rs`). The CGU's name is what `codegen_unit(name)` looks up.
- `exported_non_generic_symbols` / `exported_generic_symbols`:
  - VM functions aren't in the native CGU, so rustc's provider doesn't list the generic
    ones. The `exported_generic_symbols` override adds the VM generic `Item` instances with
    `External` linkage whose global symbols the image defines, as rustc would list them if
    they were in the CGU (`exported_generic_symbols_provider_local`), with their
    visibility. Only symbols the image actually defines are listed, since a listed instance
    without a definition leaves downstream crates with an undefined reference.
  - Every symbol the image refers to (VM functions of other crates, callees, statics, islands, the targets of
    pointers in constants, upstream and foreign ones included, and `ryo_rt`'s handlers,
    `ryo_probe_stack`, `ryo_jit_trip_*` and `rust_eh_personality`, which the machine code, the
    JIT records and the unwind information reference) is added to the local
    `exported_non_generic_symbols` as `NoDefId`, `used`, at the `Rust` level, so `-Clto`
    doesn't internalize it: LTO keeps every `used` symbol whatever its threshold
    (`rustc_codegen_ssa/src/back/lto.rs:107`), and the image is an object LTO doesn't see.
    They are in the crate's metadata, so a downstream `-Clto` build keeps them too (also for
    a crate that is both an rlib and a dylib). Not in metadata-only builds, where rustc's
    provider is empty too (`symbol_export.rs:188`) and the partitioning doesn't run.
    These entries must not be exported: a Rust dylib's export list includes the `Rust`
    level (`linker.rs:1700-1716`), and a version script or `.def` file can't export another
    crate's or a foreign symbol. `used` symbols also go into `symbols.o` (`linker.rs:1780`)
    when LTO is off (rustc empties it under `-Clto`, `linker.rs:1760-1768`), where a
    plain-name reference to a static in a DLL wouldn't resolve on PE. So `codegen_crate`
    collects, per crate type, these entries of every statically linked crate (recognized
    as `NoDefId` + `used` + `Rust`, which rustc never produces), and `link` removes one
    occurrence of each from `linked_symbols`, and from `CrateInfo::exported_symbols` only
    where rustc put them there: crate types whose export threshold the `Rust` level is below
    (Rust dylibs), not proc macros, not from `compiler_builtins`, and not with a target
    `override_export_symbols` (mirroring `linker.rs:1661-1716`). Otherwise a cdylib would
    lose rustc's own export of a `#[no_mangle]` function the image calls. So the names rustc
    lists itself stay; names are compared undecorated on both sides. The image objects
    reference all of them anyway. `y test` (check `exports`) compares the dynamic exports
    of a cdylib and of an executable with `-Zexport-executable-symbols` with plain rustc's,
    with and without `-Clto`.
    `-Clto` of a dylib itself (`-Zdylib-lto`) is rejected.
  - The entry wrapper `c_main` (`External`, default visibility) isn't listed.
  - Items made `External` + `Hidden` only for the image (see Linkage) are filtered out of
    `exported_generic_symbols`, whatever `need_visibility` says. The default provider exports every `External` CGU item, and
    skips hidden ones only when `need_visibility` is set (`symbol_export.rs:327, 375-387`).
  - `y test` builds the corpus with `-Clto=fat` and `-Clto=thin -Copt-level=3` on the last
    crate (as cargo passes it), and `y test --cross` links it with `-Clto=fat` on PE.
- `upstream_monomorphizations` → rustc's, without the instances of other crates' generics
  that `ryo_rt` and `ryo_bytecode` export. rustc shares `#[inline(never)]` instances even
  without share-generics (`symbol_export.rs:389-398`), so a program would link to the
  runtime's native copies instead of compiling its own instances (to VM code). A guard:
  the JIT, which instantiated std's generics (`Vec<u32>`, `[u32]`'s sorts), is now a sealed
  object with a std of its own ([jit.md](jit.md#packaging)), and the runtime is `core`-only.
- `symbol_name` → for `c_main`, the target's `entry_name`. For local `LocalCopy` instances without an
  attribute-given symbol, the default symbol plus `.ryo<StableCrateId as 16 hex digits>` (see
  Linkage). Everything else uses the
  default provider.

## Debugging switches

Environment variables read by the backend (and `y test`):

- `RYO_STATS=1` (`-Zryo-stats` through the wrappers, [build.md](build.md#the-y-build-tool))
  prints each VM function (`ryo: vm fn <instance>`, with ` (global)` if the image defines
  its symbol globally), the totals (`ryo: <n> VM
  functions, <n> native functions, <n> islands, <n> native items`, where islands counts
  distinct island instances), and the coverage: island instructions per VM function, island
  instructions by template (`ryo: island <template>: <n> in <m> functions`) and native
  functions by reason (`ryo: native reason: <n> <reason>`). `RYO_STATS=2` also prints why
  each other function stayed native (`ryo: native <instance>: <reason>`).
- `RYO_DUMP=<file>` writes every VM function of the crate's image (local and upstream generic
  instances alike) to `<file>`, sorted by instance path: `fn <instance> (frame F, args A, ret R)`,
  its machine code decoded back to VM instructions (`asm::decode`, printed as the
  disassembler prints instruction words, but without offsets: branch and switch targets
  are labels `L<n>`, numbered per function by position, with `L<n>:` before each target),
  its cleanup entries (`cleanup <call label> -> <landing pad label>|continue`), and what its `fn`, `sym`,
  `k` and `data` operands refer to. Those operands are numbered per function (by
  relocation, before the merge pass), so the dump doesn't change with unrelated functions.
- `RYO_DUMP_CODE=<file>` writes the same functions' machine code, in the same order, for
  `y bench codegen` to disassemble: `fn <instance>`, `code <hex>`, and `reloc <offset>
  <target>` per relocated field, its target named as `RYO_DUMP` names operands (handlers as
  `ryo_h_<Opcode>`, code constants as `ro+<offset>`, the function's JIT record as
  `jit_record` and its counter as `jit_record.ctr`). Then the image's names, from the merge
  pass: `image <index> <instance>` per function, and `ref <index> <image's> <function's>` per
  reference of its code (`ref 8 k64 k0`), with which `y bench codegen` names the JIT's code
  and IR by the function's own operands.
- `RYO_NO_VM` keeps every function native.
- `RYO_ASM_CHECK` reads every function's machine code back to the reduced set
  (`asm::decode_reduced`), encodes it again (`asm::encode_reduced`) and panics unless it is
  the same, with the same side data ([vm.md](vm.md#reduced-instructions)).
- `RYO_ASM_ALIGN=0` turns off the 16-byte alignment of loop heads
  ([vm.md](vm.md#machine-code)).
- `RYO_BACKEND_MARKER` prints `ryo backend: init` from `init` and `ryo backend: partition`
  from the partition provider, so tests can tell that the backend and its override ran.

`ryo_rt` reads only its JIT's (`RYO_JIT`, `RYO_JIT_THRESHOLD`, `RYO_JIT_SYNC`,
`RYO_JIT_PERFMAP`, `RYO_JIT_LOG`, `RYO_JIT_SHUFFLE`, `RYO_JIT_TEST_PANIC`,
[jit.md](jit.md#settings)), at run time; its build script reads `RYO_JIT_LIB_DIR`, the sealed JIT
`y build` bundles. `y build` reads `RYO_RT_FEATURES`, extra cargo features for the sysroot's `ryo_rt` (such as `fp-rbp`,
[vm.md](vm.md#handlers)); the backend follows `ryo_rt`'s `FP_ARG`.

No MIR is overridden or synthesized, and no DefIds are created. rustc freezes definitions
right after type checking (`rustc_interface/src/passes.rs:1152`), long before mono items
exist, so every stub is an instance of a generic item that already exists in `ryo_rt`. Real
items' MIR also stays as is: it is encoded into metadata, and downstream crates need it to
instantiate generics in their own VM.

### Self-profile

`-Zself-profile` shows the backend's phases as generic activities next to rustc's:
`ryo_partition` (steps 2–4, inside rustc's partition query) with `ryo_lower` (lowering and
machine code), `ryo_stubs` (islands, stub neighbors, the native CGU), `ryo_merge`
(relocation resolution) and `ryo_finish_image` (image layout); `ryo_write_image` (step 5); and at link time
`ryo_link_prep` (per crate type, everything before rustc's `link_binary`) with
`ryo_registry_images`, and `ryo_append_rlib`. measureme's `summarize` lists them.

## Symbol consistency

- `assert_symbols_are_distinct` runs only inside the original provider, over the original
  items (`partitioning.rs:1191`). The VM functions are gone from the native CGU, and the
  image defines their symbols once, so nothing collides.
- Native callers of a VM function only declare it (`callee.rs:75-95`) and call it with its
  `fn_abi`, which the VM code follows as LLVM lowers it ([vm.md](vm.md#calls-and-islands));
  the ABI sweep test (`tests/vm_abi.rs`) checks that both sides agree.
- A VM function's global symbol has the linkage/visibility the original would have had, and
  the exported-symbols queries list exactly the symbols the image defines (`#[no_mangle]`,
  share-generics).
