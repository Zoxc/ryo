# ryo design

ryo is a rustc codegen backend that compiles MIR to the instructions of a VM, encoded as
x86-64 calls of the VM's handlers, and uses
`rustc_codegen_llvm` (cg_llvm) for everything the VM doesn't do itself.

- [build.md](build.md): toolchain, the `y` build tool, sysroot, repository layout
- [backend.md](backend.md): the codegen backend: pipeline and query overrides
- [stubs.md](stubs.md): islands, the glue from VM code to native operations, and how VM
  functions are native functions
- [lowering.md](lowering.md): MIR → bytecode
- [vm.md](vm.md): the VM: execution model, frames, machine code, calling convention,
  handlers, unwinding, image format, runtime crate
- [instructions.md](instructions.md): the instruction set: each instruction's semantics,
  its uses in the lowering, and its inline sequence or handler
- [jit.md](jit.md): the JIT: counters and trips, the JIT thread, re-encoding and
  installing, OSR, packaging as a sealed object, settings
- [provenance.md](provenance.md): pointer provenance across the lowering, the VM, the JIT
  and the Lean model; the rules optimizations follow, and the gaps
- [platforms.md](platforms.md): ELF and PE specifics
- [verification.md](verification.md): the plan to verify the compiled code in Lean
  (`lean/`): levels, what is proved, checked and trusted, the AOT and JIT theorems

## Goals

- A rustc codegen backend (`backend/`) that compiles MIR to bytecode and links the VM runtime
  (`ryo_rt`) into the output.
- Works with **stable** rustc via `RUSTC_BOOTSTRAP=1`, which enables nightly features and
  `rustc_private` on a stable toolchain (pinned: 1.99.1).
- Full language coverage. Every MIR operation the VM doesn't implement (an `extern "C"`
  call, an intrinsic, a SIMD op, …) runs as an **island**: an instance of a generic template
  in `ryo_rt`, compiled by cg_llvm and called from the bytecode. The surrounding function
  stays in the VM. Only things no template can express (inline asm, C-variadic calls, …) make
  a whole function native.
- No CGU partitioning on our side. One code unit, lowered by a parallel loop over mono items
  using the rustc parallel frontend (`-Zthreads=N`).
- Fully optimized VM handlers, written in Rust (no C), called from the machine code of each
  VM function.
- A JIT in the runtime that recompiles hot VM functions on a background thread and switches
  running calls over to the new code ([jit.md](jit.md)).

Non-goals: incremental compilation, debuginfo for VM code, targets other than x86_64. The
backend rejects `-Cincremental`: VM functions' symbols and the image come from
per-session state the query system doesn't track, so reused objects could carry stale
symbols. `cargo-ryo` sets `CARGO_INCREMENTAL=0`, so cargo's dev profile works.

**Targets**: `x86_64-unknown-linux-gnu` (ELF), `x86_64-pc-windows-msvc` (PE/COFF) and
`x86_64-apple-darwin` (Mach-O; arm64 Macs run it under Rosetta). Every format-specific
mechanism has an ELF, a PE and a Mach-O variant ([platforms.md](platforms.md)), and `y test`
runs on Linux and Windows. macOS support is implemented but has not run on a Mac.

## Terms

| Term | Meaning |
|---|---|
| **VM function** | A mono item compiled to VM instructions (as machine code in the image). A native function of its signature, under its own symbol. ([stubs.md](stubs.md#vm-functions-as-native-functions)) |
| **Native item** | A mono item compiled by cg_llvm. |
| **Island** | A native template instance that performs one operation for the VM, run by the `island` instruction. ([stubs.md](stubs.md#islands-vm--native)) |
| **Image** | A crate's VM code, constants, symbol table and unwind information, emitted as one object file. ([vm.md](vm.md#image-format)) |
| **Registry object** | An object generated at each final link that registers every crate's image with the VM. ([backend.md](backend.md#pipeline)) |
| **`ryo_rt`** | The runtime crate: handlers, registry, templates, the JIT's trips. A sysroot rlib. ([vm.md](vm.md#runtime-crate-ryo_rt)) |
| **JIT record** | A function's counter and the slots its counter stubs call through, in the image's writable section. ([vm.md](vm.md#jit-records-and-counters)) |
| **`ryo_jit`** | The JIT thread, sealed by `y build` into one object with a std of its own, which `ryo_rt` bundles; its only symbol is `ryo_jit_start`. ([jit.md](jit.md#packaging)) |
