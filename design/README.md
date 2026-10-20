# ryo design

ryo is a rustc codegen backend that compiles MIR to bytecode for a VM, and uses
`rustc_codegen_llvm` (cg_llvm) for everything the VM doesn't do itself.

- [build.md](build.md): toolchain, the `y` build tool, sysroot, repository layout
- [backend.md](backend.md): the codegen backend: pipeline and query overrides
- [stubs.md](stubs.md): portals and islands, the glue between native code and the VM
- [lowering.md](lowering.md): MIR → bytecode
- [vm.md](vm.md): the VM: execution model, instruction set, image format, dispatch, runtime crate
- [platforms.md](platforms.md): ELF and PE specifics

## Goals

- A rustc codegen backend (`backend/`) that compiles MIR to bytecode and links the VM runtime
  (`ryo_rt`) into the output.
- Works with **stable** rustc via `RUSTC_BOOTSTRAP=1`, which enables nightly features and
  `rustc_private` on a stable toolchain (pinned: 1.99.1).
- Full language coverage. Every MIR operation the VM doesn't implement (a call to native
  code, an intrinsic, a SIMD op, …) runs as an **island**: an instance of a generic template
  in `ryo_rt`, compiled by cg_llvm and called from the bytecode. The surrounding function
  stays in the VM. Only things no template can express (inline asm, C-variadic calls, …) make
  a whole function native.
- No CGU partitioning on our side. One code unit, lowered by a parallel loop over mono items
  using the rustc parallel frontend (`-Zthreads=N`).
- A fully optimized VM dispatch loop, written in Rust (no C).

Non-goals: incremental compilation, debuginfo for VM code, JIT, targets other than x86_64,
Mach-O. The backend rejects `-Cincremental`: portal symbols and the image come from
per-session state the query system doesn't track, so reused objects could carry stale
symbols. `cargo-ryo` sets `CARGO_INCREMENTAL=0`, so cargo's dev profile works.

**Targets**: `x86_64-unknown-linux-gnu` (ELF) and `x86_64-pc-windows-msvc` (PE/COFF). Every
format-specific mechanism has an ELF and a PE variant ([platforms.md](platforms.md)), and
`y test` runs on both.

## Terms

| Term | Meaning |
|---|---|
| **VM function** | A mono item compiled to bytecode. |
| **Native item** | A mono item compiled by cg_llvm. |
| **Portal** | A native function with a VM function's symbol and signature. Calling it enters the VM. ([stubs.md](stubs.md#portals-native--vm)) |
| **Island** | A native template instance that performs one operation for the VM, run by the `island` instruction. ([stubs.md](stubs.md#islands-vm--native)) |
| **Image** | A crate's bytecode, constants and symbol table, emitted as one object file. ([vm.md](vm.md#image-format)) |
| **Registry object** | An object generated at each final link that registers every crate's image with the VM. ([backend.md](backend.md#pipeline)) |
| **`ryo_rt`** | The runtime crate: VM, templates, panic glue. A sysroot rlib. ([vm.md](vm.md#runtime-crate-ryo_rt)) |
