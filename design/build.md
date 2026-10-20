# Build

## Toolchain

- The toolchain is pinned in `rust-toolchain.toml` to an exact stable version (1.99.1), with
  the components `rustc-dev`, `rust-src` and `llvm-tools`. `rustc-dev` ships the compiler
  crates as rlibs (`rustc_codegen_llvm` included) linked against `librustc_driver-*.so`, and
  their sources under `lib/rustlib/rustc-src/rust/compiler`. Those sources are the reference
  for every compiler API the backend uses.
- Compiler APIs change every release, so a toolchain bump is a porting task. All rustc API
  use goes through a thin `backend/src/rustc_api.rs`, so ports stay local.
- Every rustc/cargo invocation runs with `RUSTC_BOOTSTRAP=1`.

## The `y` build tool

Our own build tool, written in Rust in `build/`, separate from rust's `x.py`/bootstrap. It is
modeled on cg_clif's `build_system/`.

- A zero-dependency bin crate (its own `Cargo.toml` and `Cargo.lock`, not a workspace member),
  run through `./y.sh <cmd>` (or `y.cmd`/`y.ps1` on Windows), which is
  `cargo run --manifest-path build/Cargo.toml -- <cmd>`.
- Commands: `build [--sysroot llvm|ryo]`, `build-clif`, `test`, `bench`, `clean`.
- It sets `RUSTC_BOOTSTRAP=1` on everything it spawns.

### `build`

1. **Backend**: `cargo build --release -Zembed-metadata=no` for `backend/`, with
   `RUSTFLAGS=-Zallow-features=rustc_private,...`. Only the listed features are allowed,
   even though `RUSTC_BOOTSTRAP` would allow all.
2. **Sysroot**: a self-contained `dist/` directory:
   ```
   dist/bin/rustc-ryo, cargo-ryo          wrappers
   dist/lib/librustc_codegen_ryo.so       the backend
   dist/lib/rustlib/<target>/lib/         std rlibs + libryo_rt.rlib
   ```
   - `--sysroot llvm` (default): copy the toolchain's prebuilt std rlibs, skipping the
     `rustc_*`/LLVM rustc-dev libs, as cg_clif does.
   - `--sysroot ryo`: build std from `rust-src` with our backend
     (`-Zforce-unstable-if-unmarked --sysroot=/dev/null -Zcodegen-backend=...`).
   - `ryo_rt` is always built with the stock LLVM backend, against that std, with
     `-Copt-level=3 -Ccodegen-units=1 -Cpanic=unwind` regardless of the user's profile, and
     installed next to std. There is no native library to link.
3. **Wrappers** (like cg_clif's `scripts/rustc-clif.rs`, `cargo-clif.rs`): tiny Rust programs
   compiled with plain rustc. They locate `dist/` from `current_exe()`, set
   `RUSTC_BOOTSTRAP=1` and `RUSTUP_TOOLCHAIN` (baked in at build time), and add:
   - `--sysroot dist`
   - `-Zcodegen-backend=dist/lib/librustc_codegen_ryo.so`
   - `-Zunstable-options --extern force:ryo_rt`
   - `-Ccodegen-units=1`, appended *after* the user's args so it wins
     ([backend.md](backend.md#pipeline))
   - `-Zmir-opt-level=2 -Zinline-mir=yes`, also for debug builds
     ([lowering.md](lowering.md#input))

   They reject `-Zrandomize-layout`, because argument block layouts must agree between
   crates ([lowering.md](lowering.md#frame-slots)).

   `cargo-ryo` sets `RUSTC=rustc-ryo`.

### `build-clif`: the Cranelift backend on stable

The `rustc-codegen-cranelift` rustup component is nightly-only, but the stable `rustc-dev`
sources include `compiler/rustc_codegen_cranelift` at the version that matches the pinned
toolchain (`lib/rustlib/rustc-src/rust/compiler/rustc_codegen_cranelift`). `y build-clif` builds
it from there, the same way it builds our backend:

- It copies that directory to `build/clif/` and runs `cargo build --release
  -Zembed-metadata=no` with `RUSTC_BOOTSTRAP=1`, against the pinned stable toolchain and its
  `rustc-dev`. It doesn't use cg_clif's own `y.sh`, which would install the nightly from
  cg_clif's `rust-toolchain.toml`.
- The Cranelift crates come from crates.io through cg_clif's `Cargo.lock`, so the build needs
  network access once, or a vendored copy.
- It installs `dist/lib/librustc_codegen_cranelift.so` and a `rustc-clif` wrapper (like
  `rustc-ryo`, without `force:ryo_rt` and the MIR flags), using the same prebuilt LLVM std
  sysroot.

This gives a third backend, built from the same toolchain, to compare against.

### `test` and `bench`

- `test`: the test corpus is built with `rustc-ryo` and with plain rustc, and the outputs are
  diffed. It includes an ABI sweep: argument types (ZST, scalar pairs, large aggregates,
  `f32`/`f64` mixes, `u128`, `extern "C"`, closures, vtable shims, `#[track_caller]`) through
  portals and island templates, on both targets.
- `test --clif`: also builds the corpus with `rustc-clif` and diffs its output too. That
  helps tell ryo bugs from test-corpus problems.
- `bench`: VM dispatch benches (fib, sieve, sorting, hashmap), and hyperfine comparisons of
  each benchmark built with LLVM `-O0`, LLVM `-O3`, Cranelift (`rustc-clif`) and ryo. Each
  comparison covers compile time (Cranelift is the fast-compile reference ryo competes
  with) and run time. `y bench` builds cg_clif first if `dist/` doesn't have it.

## Layout

```
y.sh, y.cmd, y.ps1                         entry points for the build tool
build/          bin        y                   build tool (own Cargo.lock, no deps)
scripts/                                       rustc-ryo.rs, cargo-ryo.rs wrappers
backend/        dylib      rustc_codegen_ryo   #![feature(rustc_private)]
vm/             cargo workspace for everything that ends up in the output program
  bytecode/     rlib       ryo_bytecode        format: opcodes, encoding, image layout;
                                               used by the backend (writer) and the VM (reader)
  rt/           rlib       ryo_rt              the runtime: VM, registry, portal/island
                                               templates, panic glue
tests/                                         test programs, driven by `y test`
```

The backend is `crate-type = ["dylib"]`, like cg_clif: a Rust dylib that dynamically links
`librustc_driver`. A cdylib would statically link its own copy of std and the compiler crates,
separate from the ones rustc itself uses. `backend/` depends on `vm/bytecode` by path, so both
sides share one definition of the format.

## Usage

`dist/bin/rustc-ryo foo.rs` or `dist/bin/cargo-ryo build`. With the default sysroot, std is
the prebuilt LLVM-compiled one: std's own code is native, and generic std code instantiated
in a ryo-built crate goes through ryo like everything else.
