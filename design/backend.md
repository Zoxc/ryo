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
and `codegen_crate` reads them. `partition.rs` holds steps 1–4, `merge.rs` builds each
image's contents (relocations, constant pool, function symbols), `stats.rs` the `RYO_STATS`
and `RYO_DUMP_NATIVE` text, `exports.rs` the exported-symbols overrides, `incr.rs` image
reuse under incremental compilation and `rt.rs` the runtime crates' identity.

1. **Collect.** Call the original `collect_and_partition_mono_items` provider (saved in
   `provide`). The collector (`collect_crate_mono_items`) is `pub(crate)` in
   `rustc_monomorphize`, so the query is the only entry point to it. Its CGUs (any number:
   `-Ccodegen-units`, rustc's default, 256 under incremental) are used as-is, each one
   getting an image of its own (**one image per CGU**):
   - their item lists are the work list; an `#[inline]` (`LocalCopy`) function rustc copied
     into several CGUs is lowered once per copy, each image keeping its own (calls to it
     stay inside the image)
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
     and visibility; an `Internal` one becomes hidden. An `Internal` copy in several CGUs
     gets the global symbol in one of them only (the first that needs it, `exposed`), and
     the others' references resolve to it: two would define the symbol twice.

   A crate with no VM code (a proc
   macro, a panic runtime, a runtime-internal crate, `RYO_NO_VM`, step 2) skips all of this: the provider returns
   rustc's partition as is, with any number of CGUs, and `codegen_crate` writes no image
   (its final outputs still get a registry stub, for their upstream images).
2. **Classify** each mono item:
   - `Fn(instance)` → VM, unless something in it can't be expressed as a VM op or an island
     template. Those functions stay native as a whole:
     - `#[naked]` functions
     - `#[rustc_offload_kernel]` functions (cg_llvm adds an argument)
     - functions with `#[link_section]`: the image's `.text.ryo_image` would hide them
       from section-based tables (`__start_<section>`) and linker-script placement
     - EII implementations (`#[<eii declaration>]`): cg_llvm defines the declaration's symbol
       as a forwarder while predefining the implementation (`add_function_aliases`)
     - functions with a `#[linkage]` other than `external` or `internal`: another object's
       definition may replace a weak or linkonce one, which the image's direct `call`s would
       bypass; `available_externally` defines nothing; PE has no plain weak definitions
     - inline asm
     - references to Objective-C class or selector statics (`#[rustc_objc_class]`,
       `#[rustc_objc_selector]`): cg_llvm doesn't define their symbols, it uses private
       `OBJC_*_REFERENCES_` globals of its own
     - calls to C-variadic functions
     - functions with non-Rust ABIs defined in Rust (`extern "C" fn`): VM code follows only
       the Rust ABI's convention
     - signatures whose arguments or return the VM can't place as LLVM does (other
       `PassMode`s, and on Win64 an `f128` in a `Pair`, [vm.md](vm.md#calls-and-islands))
     - functions with unsized parameters
     - calls to `C-unwind` functions and LLVM intrinsics
     - the other template gaps ([stubs.md](stubs.md#template-gaps))

     The lowering reports these as `Err(NeedsNative(reason))`.

     The lowering assumes every candidate is a VM function. A function that calls a
     candidate of its own CGU which then stays native is lowered again, with an island for
     that call, until the set of VM functions doesn't change. A function that fails in one
     CGU is native in all of them.

     Never VM: everything in a `proc-macro` crate (it keeps the proc macro's own code out of
     the VM, and proc macros gain nothing from it; its rlib dependencies, `syn` say, do have
     images, and the proc macro gets a registry object, so VM code does run in rustc), everything in a panic runtime crate
     (`#![panic_runtime]`: `panic_unwind`, `panic_abort`), everything in a runtime-internal
     crate (`compiler_builtins`, whose `memcpy` VM code would call back into;
     `#![profiler_runtime]`; `#![no_builtins]`, whose functions must not become calls to
     the builtins they implement; `ryo_rt`, `ryo_bytecode` and `ryo_jit`),
     `ryo_rt`'s own instances, and everything when
     `RYO_NO_VM` is set ([Debugging switches](#debugging-switches)).
   - `Static`, `GlobalAsm` → native. Statics are data, and cg_llvm handles relocations,
     linkage and TLS.
3. **Lower VM functions** with one `par_map` over every CGU's functions, so the work is
   parallel over CGUs and over the functions within each: every function is lowered on its own straight into machine code plus a
   relocation list ([lowering.md](lowering.md), [vm.md](vm.md#machine-code)), in the mode
   `asm_mode` gives: a frame pointer only where rustc's LLVM backend would keep one or PE
   requires it ([vm.md](vm.md#frames)), and with one `fp` left in `rbp` for `ryo_rt`'s
   frame-pointer handler set (but on Apple, [vm.md](vm.md#handlers)), without it passed in `rdi`, loop alignment unless `RYO_ASM_ALIGN=0`, inline instructions, the JIT's counters
   (always, [vm.md](vm.md#jit-records-and-counters)), and the target's object
   format. A call of a VM function of the same CGU is a direct `call`; one of another CGU's
   image is a `call.sym` through a symbol slot, as for a native Rust function (the JIT
   recovers the callee from the slot's value, [jit.md](jit.md)), so an image refers to
   another only by symbol. `RYO_STATS` counts these references. The
   results are merged in one pass per image at the end. An operation the VM doesn't support becomes an
   `island` instruction whose `isl` operand is an *island* relocation (template + generic
   args). The merge pass deduplicates islands (same template + args → one instance), assigns
   function indices and symbols, rewrites each function's relocation targets to them,
   and adds the function to the image writer under its own symbol.
4. **Build the native CGUs**, one per rustc CGU, with its name (kept even if empty). Each is
   a copy of the original CGU, with its VM functions removed and the stub instances its
   image needs (islands, and `c_main` in the CGU of the entry fn) added. Our override returns
   exactly these CGUs, so `self.llvm.codegen_crate(tcx)` compiles only what we ask for, in
   parallel as usual.
   - **Islands** are `External` + `Hidden`, defined by the first CGU whose image calls them
     and linked to by the others. Not `WeakODR` copies in every CGU: LLVM's function merging
     (`-Zmerge-functions=aliases` from `-O2`) makes a copy identical to another function an
     alias, a strong symbol on Mach-O and a weak external with a per-object default on COFF,
     so two CGUs' copies clash there.
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
     which the lowering uses for callees. Neighbors are always native. A neighbor that is a VM
     function of the same CGU gets a global symbol instead. One that exists once per crate
     (a static, or a function that isn't `LocalCopy`) must not get a second copy (a second
     counter, lock or `OnceLock`): if another CGU holds it, it is referenced, and made
     linkable there as for the image (`Internal` → `External` + `Hidden`, linkonce → weak,
     `expose_unique`); if no CGU of rustc's holds it, the first CGU that needs it adds it,
     and later ones reference that copy, made `External` + `Hidden`. Any other neighbor (a
     `LocalCopy`) is referenced if another CGU defines it globally (VM or native, after
     those linkage changes), else added `Internal`: only the stubs reference it. The walks
     run after every CGU's image references are made linkable, so these decisions don't
     depend on the order the CGUs are processed in.
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
     - **The TLS shim**, which the backend adds itself on ELF and Mach-O (on PE rustc creates and
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
5. **Emit the images**, one extra object per CGU with VM functions (`<cgu>.ryo_image`), with the `object` crate ([vm.md](vm.md#image-format)):
   `ImageWriter::finish_encoded` lays out the sections and unwind information, and
   `objfile.rs` writes them with their relocations, the handler calls against the handlers'
   mangled symbols (`rt_symbol`), and each function's symbol (global or local, step 1).
   The object is written to disk inside `codegen_crate`, where `tcx` is available. Our
   `codegen_crate` returns a wrapper ongoing type holding cg_llvm's `Box<dyn Any>` and the
   image path. Our `join_codegen` forwards the inner value to cg_llvm's (which downcasts it,
   `rustc_codegen_llvm/src/lib.rs:399-410`), then pushes a `CompiledModule` for the image
   (`kind: ModuleKind::Regular`, `object: Some(path)`) onto `CompiledModules.modules`
   (`rustc_codegen_ssa/src/lib.rs:124-134`), so the object list of final links includes it.
   An rlib gets it the same way: `link_rlib` writes it in the one archive build, and lists it
   among the rlib's Rust objects (`rmeta-link`) like the CGUs. Downstream rustc reads that list
   only for LTO and the `-Zstaticlib-*` symbol options, which are rejected
   ([Unsupported options](#unsupported-options)); a final link pulls the image in through the
   archive index like any member. `link_rlib` writes the rlib only
   with `link` output to a file, which a crate with VM code therefore needs
   ([Unsupported options](#unsupported-options)).
   The image defines one global symbol, `__ryo_image_<StableCrateId>_<CGU hash>` (both as
   16 hex digits; the CGU hash is `image::cgu_hash`, FNV-1a of rustc's CGU name, also in the
   header), hidden: nothing references it, it names the header in tools and dumps. On ELF the
   read-only part is `.data.rel.ro.ryo_image` (writable only while relocating), the writable
   part `.data.ryo_image`, the code `.text.ryo_image`, and the unwind information
   `.eh_frame` and `.gcc_except_table.ryo_image`; on PE they are `.rdata$ryo_image`,
   `.data$ryo_image`, `.text$ryo_image`, `.pdata` and `.xdata`; on Mach-O `__DATA,__const`,
   `__DATA,__data`, `__TEXT,__text`, `__TEXT,__eh_frame` and `__TEXT,__gcc_except_tab`
   ([platforms.md](platforms.md)). `--emit=obj` is rejected for a crate with VM code
   ([Unsupported options](#unsupported-options)). A binary with a VM `main` also gets `__ryo_main` in this
   object ([stubs.md](stubs.md#program-entry-main)).
6. **Link** with cg_llvm's `link` (`link_binary`). The VM is part of `ryo_rt`, which links like
   any Rust dependency, so there is no native runtime library. Two additions:
   - **Registration through the linker**: each image object registers itself. It holds
     one pointer-sized entry pointing at its header, in a section of its own: ELF
     `ryo_images` (writable, `SHF_GNU_RETAIN`), PE `.ryo$m`, Mach-O `__DATA,__ryo_images`
     (`S_ATTR_NO_DEAD_STRIP`). The linker concatenates the entries of every image object in
     the link unit, and keeps them under section GC (`--gc-sections`, `/OPT:REF`,
     `-dead_strip`); the image they point at stays with them.
   - **Registry stub**: at every final link (exe, dylib, cdylib, staticlib) the backend adds
     a small object, the same for every crate (`objfile.rs`, `write_registry`): a null entry
     (so the list exists in every link unit) and a constructor, `lea` of the list's start,
     `lea` of its end, `jmp ryo_vm_register` (`.init_array.00000` on ELF, `.CRT$XCT` on PE,
     ahead of other constructors; `__mod_init_func` on Mach-O). Every output links its own
     `ryo_rt` (design/vm.md#several-ryo-runtimes-in-one-process), so the stub calls that
     copy directly; on ELF the reference is hidden, so the linker binds it at link time and
     the definition isn't exported, and two ryo modules loaded into one process each
     register in their own runtime instead of the first one loaded. The
     JIT's trip entry points and the handlers are `#[rustc_std_internal_symbol]`s, which a
     cdylib doesn't export. The bounds are the linker's
     `__start_ryo_images`/`__stop_ryo_images` (referenced hidden, so a dylib and the exe
     that links it each walk their own list), on Mach-O `section$start$__DATA$__ryo_images`
     and `section$end$...`, on PE the stub's own markers in `.ryo$a` and `.ryo$z` (the
     linker sorts grouped sections by their suffix, as the CRT's `.CRT$XC*`). Null entries
     (the stub's, PE incremental-link padding) are skipped. The stub lists no images, so
     `link` reads no rlib symbol tables. Images in rlibs are archive members, taken only if
     referenced (a native call into a VM function, another image's `call.sym`, a function
     pointer); an image nothing references is never called, so it needn't be registered,
     and it now drops out of the link. Crates linked into an upstream Rust dylib are
     registered by that dylib's own stub.

     **One `link_binary` call per crate type**: `link_binary` loops over
     `crate_info.crate_types` itself and gives every output the same modules
     (`rustc_codegen_ssa/src/back/link.rs:326-401`), but each output needs its own registry
     stub (and an rlib none). So our `link` calls `link_binary` once per crate type,
     through cg_llvm's `link` (cg_llvm's `LlvmArchiveBuilderBuilder` is `pub(crate)`,
     `rustc_codegen_llvm/src/back/archive.rs:13`, so we can't call `link_binary` with it
     ourselves):
     - with a single-type copy of `CrateInfo` (it is `Clone`)
     - with the registry stub added to the modules
     - with every temporary object hardlinked per call (module objects, the allocator module,
       global-asm and DWARF objects) for every call but the last, since `link_binary`
       deletes them at the end (`link.rs:444-490`)
     - with metadata: `EncodedMetadata` isn't `Clone`, and its file lives in a temp dir that
       is deleted when the value is dropped (`rustc_metadata/src/fs.rs:101-107`). So before
       the first call, the backend copies `metadata.path()` and the `stub_or_full()` bytes into
       its own directory, and every call but the last (which gets the original) reloads from
       that copy with `EncodedMetadata::from_path(path, stub_path, None)` (`encoder.rs:2384-2388`).
   - **Staticlib outputs**: nothing in the archive references the stub, so a C linker
     consuming the staticlib would drop it, and with it the constructor. So every stub
     defines a hidden `__ryo_registry_anchor_<tag>`, and every image object references it with a
     strong reference (its header's `anchor` field, relocated against it, `objfile.rs`,
     `write_image`); the stub passes the anchor to `ryo_vm_register`, which registers only
     images of that anchor ([vm.md](vm.md#several-ryo-runtimes-in-one-process)). In
     a staticlib, any image the C linker takes (any VM function called) then pulls the stub
     in. (A weak reference would not cause archive extraction.) The anchor is a weak
     definition (a COMDAT on PE), so two ryo staticlibs in one C link don't clash: the
     extractor takes one stub, which registers every entry of the link unit, the other
     staticlib's images included; if both are taken (`--whole-archive`), both constructors
     run and the second finds every image registered.
   - **Plain rustc can't do the final link** of ryo-built rlibs: without our backend there is
     no stub, and `__ryo_registry_anchor` is undefined. Final links always go through
     `rustc-ryo`.
   - **`ryo_rt`** arrives through `--extern force:ryo_rt` (`rustc_session/src/config.rs:2621`),
     which loads it even when nothing names it. A backend has no hook for injecting an
     `extern crate`. So it is in `CrateInfo`, its generics can be instantiated, and it gets
     linked.

## Incremental

Under `-Cincremental`, each CGU's image is a work product of its own, reused when nothing it
depends on changed (`partition.rs`, `image_part`; the side data and work products in `incr.rs`).

- **Self-contained images.** An image is a function of its CGU's items (with rustc's linkage
  and visibility) and of the queries its lowering reads, nothing else:
  - classification is per CGU: only the CGU's own functions are direct callees, a VM
    function of another CGU is called by symbol (`call.sym`) whether it is VM or native, so a
    function that stays native only makes its own CGU's callers lower again (`lower_cgu`);
  - a VM function's symbol is global if its linkage isn't `Internal`, if it is the entry fn,
    or if it is unique in the crate (not `LocalCopy`), hidden then. A `LocalCopy` copy stays
    local: the image refers to its own functions by their local symbols, and native code of
    the CGU that refers to it gets a native copy (`native_ref`), as no two CGUs may define
    the same global symbol;
  - native items an image refers to are made linkable on the native side only:
    `External` + `Hidden` if unique, `WeakODR` + `Hidden` if a `LocalCopy`, and items added
    for an image `WeakODR` + `Hidden`, so no CGU depends on another's choices.
- **The image's dep node** is a `CompileCodegenUnit` node named
  `<cgu>.ryo.<fingerprint>`, the fingerprint covering the CGU name, its candidates' symbols,
  linkage and visibility, the entry fn's symbol (only in the entry's own CGU's key), the
  `asm::Mode`, the crate's `StableCrateId`, `RYO_ASM_ALIGN`, the backend's build ID
  (`RYO_BACKEND_ID`, baked in by `backend/build.rs`: a hash of the backend's and
  `ryo_bytecode`'s sources and manifests, the lock file, the compiler's `-vV` and the build
  settings; baked in rather than read from the dylib's file, which a rebuild may replace
  while a session runs, and the same for a `-Zcodegen-backend=<name>`), and `ryo_rt`'s crate
  hash (an image that calls no island reads nothing else of `ryo_rt`). `RYO_ASM_CHECK` is
  not in it: it only checks the code it encodes, without changing it. A change to any of
  these gives a node the previous session didn't have. The lowering runs inside
  `dep_graph.with_task(node, ..)`, so the queries it reads (MIR, layouts, ABIs, symbol
  names, constants) are its edges; reading rustc's partition there would be a cycle (this
  runs inside the partition query), which the fingerprint replaces.
- **Reuse.** If the previous session has the work product `<cgu>.ryo` (files `o`, the image
  object, and `ryo`, its side data) and `try_mark_green` marks the node green, the image
  isn't lowered: the side data (`CguVm`: the VM functions and which have global symbols, the
  islands they call, the items they refer to, the `__ryo_main` target) is
  decoded (`persist.rs`, `Instance`s and `MonoItem`s by `DefPathHash`), the native CGUs and
  the exported-symbols queries are built from it as from a fresh image, and `codegen_crate`
  hard-links the cached object into place. A reused image is byte-identical to a fresh one.
  A CGU whose candidates all stay native has a product too, with side data only (no `o`):
  reusing it saves lowering them again only to find that out. The side data's first byte
  says whether the CGU has an object, the next 16 a checksum of the rest: side data whose
  checksum doesn't match (corrupted with its end marker intact, which `MemDecoder` alone
  wouldn't catch) is a cache miss, checked before `try_mark_green`, so the image is rebuilt
  (the `incremental` check flips a byte); a product that should have one but lacks it (rustc
  only warns when a file fails to copy into the cache) isn't reused. The `incremental`
  check's revision 11 adds an unused item ahead of `main` and expects every image reused.
- **Saving.** cg_ssa saves only its own modules' products, inside cg_llvm's join, so our
  `join_codegen` saves each fresh image's object and side data with
  `copy_cgu_workproduct_to_incr_comp_cache_dir`, and re-inserts each reused one's previous
  `WorkProduct`, before rustc writes the work product index. A fresh image's files are
  removed before they are written: under `-Csave-temps` the previous session's may still be
  hard links into the cache, which writing through would change.
- **Exported symbols.** `exported_generic_symbols` is `cache_on_disk`, and its override
  adds data (the images' VM exports, the items made hidden for them) that the dep graph
  sees only through the native CGUs, which can stay the same while that data changes (a new
  generic instance that is VM code adds no native item). A green node would then load the
  previous session's list into the metadata. So with VM code the override reads the
  forever-red dep node (as rustc's `create_def` does) and reruns every session; it is cheap,
  and an unchanged result keeps its dependents green.
- Not reused: with `RYO_DUMP`, `RYO_DUMP_CODE` or `RYO_DUMP_LEAN` (their output covers the
  images built), and under `-Zdisable-incr-comp-backend-caching`. `RYO_STATS` prints
  `ryo: <n> of <m> images reused`; the `incremental` check rebuilds each revision unchanged
  and expects every image reused and the same executable.

**Constants across images.** Each image deduplicates its constant pool on its own, so a
constant several CGUs use is in each of their images (and an image needs no other's pool,
which keeps it a function of its CGU). Moving shared constants to mergeable native
read-only data was the plan's optional last stage; measured, it isn't worth it: in
`regex-syntax` (440 KB of pool at one CGU) the pools grow 1.4% at 16 CGUs and 1.7% at 256,
in the benches and `tests/vm_cgu.rs` by 200 to 1500 bytes. The images' other per-image parts
(headers, function tables, symbol slots) grow more (4.7% and 6.9% of the read-only parts in
`regex-syntax`). `RYO_STATS` prints the pools' total.

## Query overrides (`provide`)

The exported-symbols ones are in `exports.rs`, `symbol_name` in `symbols.rs`.

- `collect_and_partition_mono_items` → the native CGU from step 4. `all_mono_items` keeps the
  original DefIds of VM functions: `is_codegened_item` is built from it
  (`rustc_codegen_ssa/src/base.rs`), and cg_llvm uses that to pick hidden visibility for
  declarations (`callee.rs`). The CGU's name is what `codegen_unit(name)` looks up.
- `exported_generic_symbols`:
  - VM functions aren't in the native CGU, so rustc's provider doesn't list the generic
    ones. The `exported_generic_symbols` override adds the VM generic `Item` instances and
    drop glue (and async drop glue) shims with `External` linkage whose global symbols the
    image defines, as rustc would list them if they were in the CGU
    (`exported_generic_symbols_provider_local`, `symbol_export.rs:398-484`), with their
    visibility. Only symbols the image actually defines are listed, since a listed instance
    without a definition leaves downstream crates with an undefined reference.
  - The entry wrapper `c_main` (`External`, default visibility) isn't listed: only a bin
    has it, rustc doesn't mix `bin` with other crate types, and a bin exports no generics.
  - Nothing else is needed for the images' references to native symbols: no LTO runs
    ([Unsupported options](#unsupported-options)), so rustc's partition decides what is
    internal, and step 4 exposes what the images need.
  - Items made `External` + `Hidden` only for the image (see Linkage) are filtered out of
    `exported_generic_symbols`, whatever `need_visibility` says. The default provider exports every `External` CGU item, and
    skips hidden ones only when `need_visibility` is set (`symbol_export.rs:327, 375-387`).
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

## Unsupported options

Rejected with an error, rather than producing output that doesn't work or silently lacks
something in VM code. The backend's `init` checks the session options, for every crate:
most crates have VM code, and one without (a proc macro, `RYO_NO_VM`) may still link
upstream images.

- LTO in any form: `-Clto` (`fat`, `thin`, `yes`, bare), `-Clinker-plugin-lto`,
  `-Zdylib-lto`, and targets that require LTO (`-Zthinlto=yes` needs no check of its own:
  with `thin_lto_supported() == false`, `Session::lto` returns `Lto::No` before reading it). The images are objects LTO
  doesn't see, so it would internalize or drop symbols only they refer to (a native item
  exposed as hidden for an image, a handler); an rlib also lists its images among its Rust
  objects (`rmeta-link`), which downstream LTO would drop from the link and read bitcode from. rustc's
  implicit crate-local ThinLTO (`opt-level` >= 1 with several codegen units) internalizes
  the same way, so the backend reports `thin_lto_supported() == false`, which makes
  `Session::lto` return `Lto::No` for it: optimized builds work, without cross-CGU
  inlining of their native code.
- Sanitizers, the session's effective set (`Session::sanitizers`: `-Zsanitizer=…` plus the
  target's default sanitizers, e.g. `x86_64-unknown-linux-gnuasan` or a target JSON's
  `default-sanitizers`; the whole set: address, cfi, dataflow, hwaddress, kcfi,
  kernel-address, kernel-hwaddress, leak, memory, memtag, safestack, shadow-call-stack,
  thread, realtime):
  VM code isn't instrumented, so they would miss its accesses (ASan, TSan, HWASan), report
  false positives (MSan: VM stores don't clear shadow memory), or trap on calls into it
  (CFI and KCFI type checks VM functions don't carry).
- Control-flow and Spectre hardening: `-Zcf-protection` (no `endbr64` at VM entries, and
  images without the IBT/SHSTK property note silently turn CET off for the whole binary),
  `-Ccontrol-flow-guard` and `-Zehcont-guard` (VM functions and landing pads aren't in the
  tables), `-Zstack-protector`, `-Zretpoline`, `-Zretpoline-external-thunk`,
  `-Zfunction-return`, `-Zindirect-branch-cs-prefix` and `-Cjump-tables=no` (`switch.dense`
  is a jump table in VM code), and the same hardening enabled by
  its LLVM feature names, which rustc passes to LLVM with only a warning (`retpoline*`,
  `lvi-cfi`, `lvi-load-hardening`, `seses`, `harden-sls-*`, in `-Ctarget-feature` or the
  target's features; the last sign wins). `-Cno-redzone` is supported: VM
  frames never use a red zone ([platforms.md](platforms.md)).
- Instrumentation and profiling, which VM functions would silently lack:
  `-Cinstrument-coverage` (they would vanish from the report), `-Cprofile-generate`,
  `-Zinstrument-xray`, `-Zinstrument-mcount`, `-Zpatchable-function-entry`. A function
  with `#[patchable_function_entry]` stays native.
- `-Zautodiff` and `-Zoffload`: cg_llvm's Enzyme and offload passes see only its own
  modules, not VM code. A `#[rustc_offload_kernel]` function stays native.
- `-Zrandomize-layout`: island argument blocks need tuple layouts that agree between crates.
- Targets other than x86_64 with 64-bit pointers (`aarch64`, `x32`), and Mach-O targets
  other than macOS: the images are x86-64 machine code, in ELF, PE or macOS Mach-O.
- Soft-float: a target with a `rustc_abi` (`softfloat`, as `x86_64-unknown-none` and
  `x86_64-unknown-uefi` have, or a target JSON's `rustc-abi`), and
  `-Ctarget-feature=+soft-float` or `-sse2`, for which rustc only warns. LLVM then passes
  floats in general registers, while VM signatures put them in xmm registers, and the
  handlers and VM code use SSE. The target features are only known after `init`, so
  `codegen_crate` checks them (`sse2` must be in `sess.internal_target_features`,
  `soft-float` must not).
- PE targets other than windows-msvc (MinGW: `windows-gnu`, `windows-gnullvm`): the PE
  import rules match cg_llvm on MSVC, which on `Env::Gnu` leaves functions' `dllimport` to
  the linker, GNU ld doesn't synthesize `__imp_` for static definitions, and the SEH handler
  assumes MSVC ([platforms.md](platforms.md)).
- A code model other than `small` (the default), from `-Ccode-model` or the target's
  (`sess.code_model()`, so a target JSON's `code-model` too): the images reach handlers, other
  images and native items with rel32 calls and RIP-relative addressing, which assume the
  small model's 2 GiB reach. `large` and `medium` place code or data beyond it (a link
  error at best), `kernel` is for kernels, which need soft-float anyway.
- For a crate with VM code: `--emit=obj`, `llvm-bc` and `thin-link-bitcode` (cg_llvm's
  modules, copied to the outputs inside its `join`, without the image objects, so the VM
  functions would be undefined); any `--emit` without `link` (an rlib is written only with
  `link`, and the images are written into it: without it they would be missing from the
  output or left behind); and `-o -` (kept
  rejected: untested with the images).
  Output for reading (`asm`, `llvm-ir`, `mir`) alongside `link` is allowed and covers the
  native code only. Checked after the partitioning, which knows whether there is VM code.
- `-Zno-link` and `-Zlink-only`: the `.rlink` path links without `codegen_crate`, so without
  the registry object.
- `-Zstaticlib-rename-internal-symbols` and `-Zstaticlib-hide-internal-symbols`: they rename
  or hide symbols in the Rust objects of the staticlib's upstream rlibs, which include the
  images (listed in `rmeta-link` like the CGUs); that was never checked against the images'
  registry entries and their references between VM functions, islands and native code.

Runtime-internal crates aren't rejected but stay native as a whole, like proc macros and
panic runtimes ([Pipeline](#pipeline), step 1): `compiler_builtins`, `#![profiler_runtime]`
and `#![no_builtins]` crates (also every crate of a target that sets `no_builtins`), `core`
and its `-Zbuild-std` alias `rustc-std-workspace-core` (the handlers call its non-generic
functions, which must not re-enter VM code), and the runtime's own `ryo_rt`, `ryo_bytecode`
and `ryo_jit` (`partition::RUNTIME_CRATES`, the same list the `upstream_monomorphizations`
override filters; as when built with `-Zbuild-std`).

`y test`'s `reject-unsupported` check runs each (`-Zrandomize-layout` also through an
`@argfile`).

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
  `jit_record` and its loop counter as `jit_record.ctr_l`). Then the image's names, from the merge
  pass: `image <index> <instance>` per function, and `ref <index> <image's> <function's>` per
  reference of its code (`ref 8 k64 k0`), with which `y bench codegen` names the JIT's code
  and IR by the function's own operands.
- `RYO_DUMP_NATIVE=<file>` writes what stays native to `<file>`: a summary (native
  functions by reason, island instructions by template with the number of functions), then
  each function that stayed native as `[<crate>] <instance>: <reason>` (`[local]` for the
  crate being compiled), the VM functions also kept native (`keep_native`), and each VM
  function with islands as `[<crate>] <instance>: <template> x<n>, ...`. All sorted, without
  addresses or hashes, for `y bench codegen` (`<program>.native.txt`). Like the other
  dumps it turns image reuse off.
- `RYO_NO_VM` keeps every function native.
- `RYO_ASM_CHECK` reads every function's machine code back to the reduced set
  (`asm::decode_reduced`), encodes it again (`asm::encode_reduced`) and panics unless it is
  the same, with the same side data ([vm.md](vm.md#reduced-instructions)).
- `RYO_ASM_ALIGN=0` turns off the 16-byte alignment of loop heads
  ([vm.md](vm.md#machine-code)).
- `RYO_BACKEND_MARKER` prints `ryo backend: init` from `init` and `ryo backend: partition`
  from the partition provider, so tests can tell that the backend and its override ran.

`ryo_rt` reads only its JIT's (`RYO_JIT`, `RYO_JIT_THRESHOLD`, `RYO_JIT_SYNC`,
`RYO_JIT_PERFMAP`, `RYO_JIT_LOG`, `RYO_JIT_SHUFFLE`, `RYO_JIT_TEST_PANIC`, `RYO_JIT_TEST_OOM`,
[jit.md](jit.md#settings)), at run time; its build script reads `RYO_JIT_LIB_DIR`, the sealed JIT
`y build` bundles. `y build` reads `RYO_RT_FEATURES`, extra cargo features for the sysroot's `ryo_rt`.

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
`ryo_registry` (writing the stub). measureme's `summarize` lists them.

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
