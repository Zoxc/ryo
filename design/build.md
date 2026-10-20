# Build

## Toolchain

- The toolchain is pinned to an exact stable version (1.99.1), with the components
  `rustc-dev`, `rust-src` and `llvm-tools`. `rust-toolchain.toml` says `channel = "stable"`
  rather than `"1.99.1"`: rustup treats `1.99.1` as a separate toolchain and downloads it even
  when the installed `stable` is 1.99.1. `y` enforces the pin instead: it fails unless
  `rustc -vV` reports release 1.99.1. Since `stable` can move after `y build`, the wrappers
  also bake in the path of the toolchain's `librustc_driver-<hash>` (which the backend links
  against) and fail with a clear error if it no longer exists. `rustc-dev` ships the compiler
  crates as rlibs (`rustc_codegen_llvm` included) linked against `librustc_driver-*.so`, and
  their sources under `lib/rustlib/rustc-src/rust/compiler`. Those sources are the reference
  for every compiler API the backend uses.
- Compiler APIs change every release, so a toolchain bump is a porting task. All rustc API
  use goes through the `backend/src/rustc_api/` module (the backend impl, the pipeline, the
  lowering, the link step), so ports stay local. The `extern crate`s for the compiler crates
  are in `lib.rs`, since they must be at the crate root, and only `rustc_api` uses them.
- Every rustc/cargo invocation runs with `RUSTC_BOOTSTRAP=1`.

## The `y` build tool

Our own build tool, written in Rust in `build/`, separate from rust's `x.py`/bootstrap. It is
modeled on cg_clif's `build_system/`.

- A zero-dependency bin crate (its own `Cargo.toml` and `Cargo.lock`, not a workspace member),
  run through `./y.sh <cmd>` (or `y.cmd`/`y.ps1` on Windows), which is
  `cargo run --manifest-path build/Cargo.toml -- <cmd>`.
- Commands: `build [--sysroot llvm|ryo] [--target T]...`, `build-clif`, `test [--clif | --cross T]`, `bench [--runs N]`,
  `clean`.
- It sets `RUSTC_BOOTSTRAP=1` on everything it spawns.

### `build`

1. **Backend**: `cargo build --release -Zembed-metadata=no` for `backend/`, with
   `RUSTFLAGS=-Zallow-features=rustc_private,...`. Only the listed features are allowed,
   even though `RUSTC_BOOTSTRAP` would allow all.
2. **Sysroot**: a self-contained `dist/` directory:
   ```
   dist/bin/rustc-ryo, cargo-ryo          wrappers
   dist/lib/librustc_codegen_ryo.so       the backend
   dist/lib/rustlib/<target>/lib/         std rlibs + libryo_rt.rlib, libryo_bytecode.rlib
   dist/lib/rustlib/<target>/bin/         the toolchain's self-contained linker (rust-lld)
   ```
   - `--sysroot llvm` (default): copy the toolchain's prebuilt std rlibs, skipping the
     `rustc_*`/LLVM rustc-dev libs, as cg_clif does. The target's `bin/` is copied too, since
     x86_64 Linux links with the sysroot's `rust-lld` by default.
   - `--sysroot ryo`: everything above, plus std built from `rust-src` with our backend, in
     its own sysroot `dist/sysroot-ryo/` (`lib/rustlib/<host>/lib`, and the target's `bin/`
     for `rust-lld`). `rustc-ryo --sysroot ryo` selects it; the default stays the LLVM std, so
     both can be tested from one `dist/`. Host only.
     - `library/` is copied to `target/sysroot-ryo/library` (once per toolchain), and cargo
       builds its `sysroot` crate there (`--release --features "backtrace panic-unwind"`,
       `--target <host>`), with `RUSTFLAGS` `-Zforce-unstable-if-unmarked --sysroot=/dev/null
       -Cpanic=unwind -Cembed-bitcode=yes`, like cg_clif's sysroot build.
     - `RUSTC` is `y` itself (a shim mode selected by an environment variable). It compiles
       `core`, `compiler_builtins`, `rustc-std-workspace-core`, `ryo_rt`, `ryo_bytecode` and
       build scripts with plain rustc, and every other crate with `rustc-ryo`. `ryo_rt` can't
       be ryo-built: every ryo-built crate depends on it, so it and what it depends on (only
       `core`: `ryo_rt` is `#![no_std]`, [vm.md](vm.md#runtime-crate-ryo_rt)) stay LLVM-built.
     - The copy adds `ryo_rt` and `ryo_bytecode` to the library workspace (manifests pointing
       at `vm/`'s sources, on the workspace's `core`), and a `ryo_rt` dependency to `alloc` and
       `rustc-std-workspace-core`, which every other crate depends on. That orders `ryo_rt`
       before them, and `rustc-ryo`'s pathless `--extern force:ryo_rt` finds it through an
       extra `-Lcrate=<deps dir>` (cargo's `-L dependency=` paths aren't searched for it).
     - Cargo doesn't fingerprint the backend, so a new backend (by modification time)
       rebuilds from a clean target directory.
     - The shim collects each ryo-built crate's `RYO_STATS=2` output, and `y build` prints a
       coverage table: VM and native functions and islands per crate, island instructions
       by template, native functions by reason ([backend.md](backend.md#debugging-switches)).
   - `--target T` (repeatable): also install std (from the toolchain's rust-std for `T`)
     and `ryo_rt` for `T`, for cross-compiling with `rustc-ryo --target T`
     ([platforms.md](platforms.md), cross-checking PE on Linux).
   - `ryo_rt` is always built with the stock LLVM backend, against that std, with
     `-Copt-level=3 -Ccodegen-units=1 -Cpanic=unwind -Cembed-bitcode=yes` regardless of the
     user's profile (bitcode, like std's, so `-Clto` builds can include it), and
     installed next to std. There is no native library to link.
3. **Wrappers** (like cg_clif's `scripts/rustc-clif.rs`, `cargo-clif.rs`): tiny Rust programs
   compiled with plain rustc. They locate `dist/` from `current_exe()`, set
   `RUSTC_BOOTSTRAP=1` and `RUSTUP_TOOLCHAIN` (baked in at build time), and add:
   - `--sysroot dist`
   - `-Zcodegen-backend=dist/lib/librustc_codegen_ryo.so`
   - `-Zunstable-options --extern force:ryo_rt`
   - `-Ccodegen-units=1`, appended *after* the user's args so it wins
     ([backend.md](backend.md#pipeline))
   - on windows-msvc targets (`--target *-msvc`, or none on an msvc host),
     `-Clink-arg=/IGNORE:4217 -Clink-arg=/IGNORE:4286` ([platforms.md](platforms.md))

   They add no MIR optimization flags: ryo gets rustc's defaults, like the other backends
   ([lowering.md](lowering.md#input)).

   With no arguments, they pass none (so rustc prints its help), and an explicit `--sysroot`
   from the user replaces `--sysroot dist`.

   They reject `-Zrandomize-layout`, because argument block layouts must agree between
   crates ([lowering.md](lowering.md#frame-slots)).

   `--sysroot ryo` (or `--sysroot=ryo`) means `dist/sysroot-ryo`. `-Zryo-stats[=N]` (or
   `-Z ryo-stats[=N]`, `N` defaulting to 1) is taken out of the arguments, since rustc has
   no such option and a backend can't add one, and sets `RYO_STATS=N` for the backend
   ([backend.md](backend.md#debugging-switches)).

   `cargo-ryo` sets `RUSTC=rustc-ryo` and `CARGO_INCREMENTAL=0` (incremental compilation is
   a non-goal, and the backend rejects it, [README.md](README.md#goals)).

### `build-clif`: the Cranelift backend on stable

The `rustc-codegen-cranelift` rustup component is nightly-only, but the stable `rustc-dev`
sources include `compiler/rustc_codegen_cranelift` at the version that matches the pinned
toolchain (`lib/rustlib/rustc-src/rust/compiler/rustc_codegen_cranelift`). `y build-clif` builds
it from there, the same way it builds our backend:

- It copies that directory to `build/clif/` (gitignored, and excluded from `build/`'s cargo
  workspace) and runs `cargo build --release -Zembed-metadata=no --features unwinding` with
  `RUSTC_BOOTSTRAP=1`, against the pinned stable toolchain and its `rustc-dev`. The target
  directory is `target/clif/`. `unwinding` is what cg_clif's own `--panic-unwind-support`
  enables; without it cg_clif aborts on panic, while the LLVM std and the test corpus
  unwind. It doesn't use cg_clif's own `y.sh`, which would install the nightly from
  cg_clif's `rust-toolchain.toml`.
- The Cranelift crates come from crates.io through cg_clif's `Cargo.lock`, so the build needs
  network access once, or a vendored copy.
- It installs `dist/lib/librustc_codegen_cranelift.so` and a `rustc-clif` wrapper (like
  `rustc-ryo`, without `force:ryo_rt` and the forced `-Ccodegen-units=1`), using the same
  prebuilt LLVM std sysroot.

This gives a third backend, built from the same toolchain, to compare against.

### `test` and `bench`

- `test`: the test corpus is built with `rustc-ryo` (also with `-Zthreads=8`) and with plain
  rustc, and the exit codes, stdout and stderr are diffed. It includes an ABI sweep: argument types (ZST, scalar pairs, large aggregates,
  `f32`/`f64` mixes, `u128`, `extern "C"`, closures, vtable shims, `#[track_caller]`) through
  portals and island templates, on both targets. Programs can list functions that must be
  compiled to bytecode: the ryo builds run with `RYO_STATS=1` and must report them, and the
  program is run once more with `RYO_VM_TRACE`: the reported IDs, mapped back to names
  through the IDs `RYO_STATS` prints, must include the functions the program lists as
  entered, and the output must otherwise be the same
  ([backend.md](backend.md#debugging-switches)). Programs with VM functions are also built at
  `-Copt-level=3` (`ryo-O3`), where only the output and the trace consistency are checked,
  since MIR inlining removes functions. Some programs are a staticlib or cdylib called from a
  C `main`, compiled with `cc`, or `cl` on windows-msvc hosts (skipped without one). The smoke tests check that `rustc-ryo`
  rejects `-Zrandomize-layout`, more than one codegen unit and `-Cincremental`, and that
  `cargo-ryo` builds a dev-profile package.
- With a ryo sysroot in `dist/`, `test` also builds the corpus against it (`--sysroot ryo`):
  variants `ryo-std` and `ryo-std-O3` (output and trace consistency only, like `ryo-O3`). Their
  `entered` lists aren't checked: those name what the LLVM std enters through portals, and VM
  std code calls VM functions directly. Without one, they are skipped.
- `test --cross T`: builds and links, without running, the corpus for target `T` (after
  `build --target T`), against stand-in import libraries ([platforms.md](platforms.md),
  cross-checking). Skipped if the sysroot has no `rust-lld`.
- `test --clif`: also builds the corpus with `rustc-clif` and diffs its output too. That
  helps tell ryo bugs from test-corpus problems.
- `bench [--runs N]`: hyperfine comparisons of each program in `tests/bench/` (fib, sieve,
  sort, hashmap) built with LLVM `-O0`, LLVM `-O3`, Cranelift (`rustc-clif`) and ryo. Each comparison
  covers compile time (Cranelift is the fast-compile reference ryo competes with) and run
  time, printed as two tables of mean and standard deviation. Every backend gets its default
  flags; the one inherent difference is that `rustc-ryo` forces `-Ccodegen-units=1`, while
  LLVM and Cranelift use rustc's default codegen unit count. A note under the compile-time
  table says so. Failed builds and runs are collected and reported at the end. Without hyperfine on `PATH`,
  a built-in timer does the same (one warmup, then `N` runs, default 5). The programs'
  output must agree across backends. `y bench` builds `dist/` and cg_clif first if they are
  missing; `y test --clif` builds cg_clif too.
- VM dispatch benches: `y bench` also runs `vm/rt/benches/dispatch.rs` (hand-assembled fib,
  sieve and insertion sort through `vm::enter`, each also with superinstructions formed) once
  per dispatch strategy ([vm.md](vm.md#dispatch)), and prints a table of programs by
  strategy (`N` runs after one warmup, mean and standard deviation).
- `y test` also runs `vm/`'s cargo tests once per dispatch strategy (`vm/test-dispatch.sh`
  does the same without `dist/`).

## Layout

```
y.sh, y.cmd, y.ps1                         entry points for the build tool
build/          bin        y                   build tool (own Cargo.lock, no deps)
  clif/                                        cg_clif sources copied by `y build-clif` (not committed)
scripts/                                       rustc-ryo.rs, cargo-ryo.rs, rustc-clif.rs wrappers
backend/        dylib      rustc_codegen_ryo   #![feature(rustc_private)]
vm/             cargo workspace for everything that ends up in the output program
  bytecode/     rlib       ryo_bytecode        format: opcodes, encoding, image layout;
                                               used by the backend (writer) and the VM (reader)
  rt/           rlib       ryo_rt              the runtime: VM, registry, portal/island
                                               templates, panic glue
tests/                                         test programs, driven by `y test`
  bench/                                       benchmark programs, driven by `y bench`
```

The backend is `crate-type = ["dylib"]`, like cg_clif: a Rust dylib that dynamically links
`librustc_driver`. A cdylib would statically link its own copy of std and the compiler crates,
separate from the ones rustc itself uses. `backend/` depends on `vm/bytecode` by path, so both
sides share one definition of the format.

## Usage

`dist/bin/rustc-ryo foo.rs` or `dist/bin/cargo-ryo build`. With the default sysroot, std is
the prebuilt LLVM-compiled one: std's own code is native, and generic std code instantiated
in a ryo-built crate goes through ryo like everything else. With `--sysroot ryo` (after
`y build --sysroot ryo`), std's own code is bytecode too, except `core`, `compiler_builtins`
and the panic runtime ([backend.md](backend.md#pipeline)).
