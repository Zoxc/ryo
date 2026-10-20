# Platforms: ELF and PE

Targets: `x86_64-unknown-linux-gnu` and `x86_64-pc-windows-msvc`.

| Concern | ELF (linux-gnu) | PE/COFF (windows-msvc) |
|---|---|---|
| Image registry | Registry object generated at final link, constructor in `.init_array` | Same object, constructor in `.CRT$XCU` |
| Image pointers to functions/statics in another shared object | Plain absolute relocation in the symbol table (the dynamic linker resolves it) | Functions and data: for every symbol from an upstream crate or an FFI library, the symbol slot holds the address of `__imp_<sym>` and is flagged indirect. Whether the target will end up in another DLL isn't known when compiling an rlib, so the rule applies always; when the definition is linked statically, link.exe/lld-link resolve `__imp_` locally (warnings LNK4217 and LNK4286, which the wrappers silence). The VM loads through the slot (`addr.sym.ind`, and the indirect form of the `call.ext` symbol load). So slots hold the real address, never an import thunk, and portal addresses compare equal to the defining image's portal for `vm::lookup_addr` and fn-pointer equality. Constants pointing at such data go into the image's writable `fixups` area and are patched once at registration |
| Registry constructor calling `ryo_vm_register` | Direct call (PLT if `ryo_rt` is in a shared object) | Through `__imp_ryo_vm_register` when `ryo_rt` is in an upstream Rust DLL |
| Data relocations | `R_X86_64_64` | `IMAGE_REL_AMD64_ADDR64`, plus `ADDR32NB` for RVAs |
| Portal symbols exported from a Rust dylib | Visibility from the exported-symbols queries | `dllexport` and the export list rustc generates from the exported-symbols queries. Portals appear there under the original symbol name |
| VM stack | `mmap` + `mprotect` guard page | `VirtualAlloc` + `PAGE_GUARD`, via `#[link(name = "kernel32")]` or std |
| TLS for VM state | `#[thread_local]` (initial-exec in exe, general-dynamic in dylib) | `#[thread_local]` (implicit TLS `.tls`, in exe and DLL) |
| Panics out of islands | Itanium unwinding, caught by `catch_unwind` in `ryo_rt` | SEH-based Rust panics, same `catch_unwind`. The VM never unwinds natively, so only the Rust-compiled handlers need unwind info, and rustc emits it |
| Runtime | `libryo_rt.rlib` in the sysroot, linked as a Rust crate | Same, so the linker flavor (`ld`/`lld`/`link.exe`) doesn't matter |
| ABI | SysV | Win64: different indirect/`i128`/aggregate rules. The ABI sweep test runs on both |
| Build entry point | `y.sh` | `y.cmd` / `y.ps1` |

The backend's format-specific parts sit behind one `trait ObjectFormat`, covering the image
section, symbol and relocation kinds, the registry constructor section and import
indirection. `object::BinaryFormat` picks the implementation from the target spec.
