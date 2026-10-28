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
- Commands: `build [--sysroot llvm|ryo] [--target T]...`, `build-clif`, `test [--clif | --cross T]`, `bench [--runs N] [--llvm L] [--clif [L]] [--ryo M] [--metric time|cachegrind]`, `bench codegen`,
  `bench crates [...]`, `lean [gen]`, `install`, `uninstall`, `clean`.
- `install`/`uninstall`: build ryo into the checkout's `install/` (with `dist::build_in`, the
  same build as `build` into other directories) and put launchers in cargo's bin dir with
  `cargo install --path scripts` ([install.md](install.md)). Independent of `dist/` and
  `target/`; `clean` leaves `install/` alone.
- It sets `RUSTC_BOOTSTRAP=1` on everything it spawns.

### `build`

1. **Backend**: `cargo build --release -Zembed-metadata=no` for `backend/`, with
   `RUSTFLAGS=-Zallow-features=rustc_private,...`. Only the listed features are allowed,
   even though `RUSTC_BOOTSTRAP` would allow all. The release profile is forced to
   `CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1` and `CARGO_PROFILE_RELEASE_LTO=fat`, so the
   backend's own crates are optimized as one unit whatever the user's settings;
   `librustc_driver` stays a dynamic dependency, outside LTO.
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
     for `rust-lld`). It is opt-in: `rustc-ryo --sysroot ryo` (or `RUSTFLAGS="--sysroot ryo"`
     for `cargo-ryo`) selects it, while the default of `y build`, the wrappers, `cargo-ryo`
     and `y test`'s default variants stays `--sysroot llvm`, the toolchain's prebuilt std, in
     which only std generics instantiated in ryo-built crates become VM functions. Both can be
     tested from one `dist/`. Host only (Linux is what is tested).
     - `library/` is copied to `target/sysroot-ryo/library` (once per toolchain), and cargo
       builds its `sysroot` crate there (`--release --features "backtrace panic-unwind"`,
       `--target <host>`), with `RUSTFLAGS` `-Zforce-unstable-if-unmarked --sysroot=/dev/null
       -Cembed-bitcode=yes`, like cg_clif's sysroot build. No `-Cpanic`: it would override the
       workspace profile's `-Cpanic=abort` for `panic_abort`.
     - `RUSTC` is `y` itself (a shim mode selected by an environment variable). It compiles
       `core`, `compiler_builtins`, `rustc-std-workspace-core`, `ryo_rt`, `ryo_bytecode` and
       build scripts with plain rustc, and every other crate with `rustc-ryo`. `ryo_rt` can't
       be ryo-built: every ryo-built crate depends on it, so it and what it depends on (only
       `core`: `ryo_rt` is `#![no_std]`, [vm.md](vm.md#runtime-crate-ryo_rt)) stay LLVM-built.
       It gets its `jit` feature and the same sealed JIT as `dist/`'s (`RYO_JIT_LIB_DIR` for
       its build script, which the generated manifest names): the JIT has a std of its own,
       the native one, so it never enters this sysroot's VM code ([jit.md](jit.md#packaging)).
     - The copy adds `ryo_rt` and `ryo_bytecode` to the library workspace (manifests pointing
       at `vm/`'s sources, on the workspace's `core`), and a `ryo_rt` dependency to `alloc` and
       `rustc-std-workspace-core`, which every other crate depends on. That orders `ryo_rt`
       before them, and `rustc-ryo`'s pathless `--extern force:ryo_rt` finds it through an
       extra `-Lcrate=<deps dir>` (cargo's `-L dependency=` paths aren't searched for it).
     - Cargo doesn't fingerprint the backend, so a changed backend (by a hash of its
       contents) rebuilds from a clean target directory; an unchanged one rebuilds nothing.
     - The shim collects each ryo-built crate's `RYO_STATS=2` output, and `y build` prints a
       coverage table: VM and native functions and islands per crate, island instructions
       by template, native functions by reason ([backend.md](backend.md#debugging-switches)).
   - `--target T` (repeatable): also install std (from the toolchain's rust-std for `T`)
     and `ryo_rt` for `T`, for cross-compiling with `rustc-ryo --target T`
     ([platforms.md](platforms.md), cross-checking PE and Mach-O on Linux). For
     `x86_64-apple-darwin` (natively or under Rosetta; arm64 is not a target) that is std,
     `ryo_rt` with the sealed JIT, and `ryo_bytecode`: rlibs and objects, which only a
     macOS host can link for real (ld64 and the SDK; `test --cross` links with `rust-lld`
     against stand-ins). On a macOS host `y test` runs programs with `DYLD_LIBRARY_PATH` for
     their dylibs.
   - **The JIT** (`build/src/jit.rs`, [jit.md](jit.md#packaging)), for each target that has
     it (x86_64 Linux, windows-msvc and macOS): `cargo rustc --release
     -p ryo_jit --crate-type staticlib` in its own cargo invocation and target directory
     (`target/jit/`; with `ryo_rt`'s, `ryo_bytecode`'s `alloc` feature would be unified into
     `ryo_rt`'s copy), with fat LTO, `-Copt-level=3 -Ccodegen-units=1 -Cpanic=unwind`, no
     debug information and no `RUSTFLAGS`, against the toolchain's std. Then it is sealed
     with the toolchain's `llvm-ar` and `llvm-objcopy` (`llvm-tools`; no linker, so it works
     for a cross target too): the one LTO object is extracted, every definition but
     `ryo_jit_start` made local (ELF, Mach-O: `_ryo_jit_start`) or renamed (COFF), debug
     information stripped, and the object archived alone (ELF, Mach-O in the BSD format) or
     with the staticlib's import members (COFF) into
     `target/jit/sealed/<target>/libryo_jit.a` (`ryo_jit.lib`). About 35 s from clean.
   - **The checked JIT**, for the host only: the same build with `-Cdebug-assertions=on
     -Coverflow-checks=on` on top (`target/jit-checked/`), still optimized so tests stay
     fast. After `ryo_rt` is built, a copy of its rlib with the bundled `ryo_jit.o` replaced
     by the checked one (`llvm-ar r`; metadata unchanged, so crates built against either
     `ryo_rt` link with either) goes to `dist/jit-checked/`, and likewise
     `dist/sysroot-ryo/jit-checked/` for the ryo sysroot. `rustc-ryo` links it instead of the
     sysroot's `ryo_rt` (`--extern force:ryo_rt=<path>`) when `RYO_JIT_CHECKED=1` is set and
     there is no `--target` (it then also adds `+jit-checked` to its `-vV` build id, so cargo
     rebuilds on a switch). `y test` sets it unless already set (`RYO_JIT_CHECKED=0`: the
     release JIT) and prints which JIT it uses; everything else (`bench`, `bench codegen`,
     `compare-branches.py`, `bench crates`, users) gets the release JIT. `ryo_rt` itself is
     built only once, as above.
   - `ryo_rt` is always built with the stock LLVM backend, against that std, with
     `-Copt-level=3 -Ccodegen-units=1 -Cpanic=unwind -Cembed-bitcode=yes` regardless of the
     user's profile (bitcode, like std's, so `-Clto` builds can include it), and
     installed next to std. Its cargo features are `jit` where the target has the JIT (its
     build script then bundles the sealed library from `RYO_JIT_LIB_DIR` into the rlib,
     [jit.md](jit.md#packaging)) and those listed in `RYO_RT_FEATURES` (comma-separated, such as
     `fp-rbp`, [vm.md](vm.md#handlers)). `ryo_bytecode` is installed without its `alloc`
     feature.
3. **Wrappers** (like cg_clif's `scripts/rustc-clif.rs`, `cargo-clif.rs`): tiny Rust programs
   compiled with plain rustc. They locate `dist/` from `current_exe()`, set
   `RUSTC_BOOTSTRAP=1` and `RUSTUP_TOOLCHAIN` (baked in at build time), and add:
   - `--sysroot dist`
   - `-Zcodegen-backend=dist/lib/librustc_codegen_ryo.so`
   - `-Zunstable-options --extern force:ryo_rt`
   - nothing about codegen units: the backend makes one image per CGU
     ([backend.md](backend.md#pipeline))
   - on windows-msvc targets (`--target *-msvc`, or none on an msvc host),
     `-Clink-arg=/IGNORE:4217 -Clink-arg=/IGNORE:4286` ([platforms.md](platforms.md))

   They add no MIR optimization flags: ryo gets rustc's defaults, like the other backends
   ([lowering.md](lowering.md#input)).

   With no arguments, they pass none (so rustc prints its help), and an explicit `--sysroot`
   from the user replaces `--sysroot dist`.

   They reject `-Zrandomize-layout`, because tuple layouts (island argument blocks) must
   agree between crates ([lowering.md](lowering.md#frame-slots)).

   `--sysroot ryo` (or `--sysroot=ryo`) means `dist/sysroot-ryo`; a directory named `ryo`
   needs a path, such as `--sysroot ./ryo`. `-Zryo-stats[=N]` (or
   `-Z ryo-stats[=N]`, `N` defaulting to 1) is taken out of the arguments, since rustc has
   no such option and a backend can't add one, and sets `RYO_STATS=N` for the backend
   ([backend.md](backend.md#debugging-switches)).

   `cargo-ryo` sets `RUSTC=rustc-ryo`; cargo's dev profile compiles incrementally
   ([README.md](README.md#goals)).

   Cargo identifies the compiler by `rustc -vV` (hashed into every fingerprint and
   metadata hash; cached in `target/.rustc_info.json`, keyed by the compiler's path and
   mtime). For `-vV` (or `-V -v`, `--version --verbose`) `rustc-ryo` appends a line
   `ryo-build: <hash>` to rustc's output, a hash of the backend dylib and the runtime rlibs
   that `y build` bakes in as `RYO_BUILD_ID` (each `y build` relinks the wrapper, so the
   cache sees a new mtime). Plain cargo and `cargo ryo` artifacts thus coexist in one
   target directory, and a new ryo build rebuilds them. The existing lines are unchanged
   and `-V` alone isn't touched, so build scripts that parse the version (`rustc_version`
   ignores unknown keys, `autocfg` reads `-V`) work. `--sysroot ryo` needs no line of its own:
   it comes in `RUSTFLAGS`, which cargo fingerprints (`y test`'s `cargo-ryo` check covers the
   switch between plain cargo and `cargo ryo`).

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
  `rustc-ryo`, without `force:ryo_rt`), using the same
  prebuilt LLVM std sysroot.

This gives a third backend, built from the same toolchain, to compare against.

### `test` and `bench`

- `test`: the test corpus is built with `rustc-ryo` (also with `-Zthreads=8`, and as
  `ryo-novm` with `RYO_NO_VM`, where everything stays native) and with plain rustc, and the
  exit codes, stdout and stderr are diffed. It includes an ABI sweep (`tests/vm_abi.rs`): a value of each kind of
  `PassMode` (ZSTs, scalars, scalar pairs, the Rust ABI's small-aggregate integers, large
  aggregates, `f16`/`f32`/`f64`/`f128` mixes, `u128` with one integer register left, enough
  arguments to spill to the stack, `extern "C"`, closures, vtables, `#[track_caller]`)
  passed and returned VM → native, native → VM and VM → VM, directly and through fn
  pointers. VM functions follow the platform calling convention, so it checks that VM code
  and cg_llvm agree on where every piece goes ([vm.md](vm.md#calls-and-islands)). Programs
  can list functions that must be compiled to bytecode: the ryo builds run with
  `RYO_STATS=1` and must report them ([backend.md](backend.md#debugging-switches)).
  Programs with VM functions are also built at `-Copt-level=3` (`ryo-O3`), where only the
  output is checked, since MIR inlining removes functions. The variants `ryo-jit-ssa` and
  `ryo-jit-ssa-osr` run the corpus through the JIT's SSA tier with its checkers, every VM
  function from its first call or entered by OSR at its first loop head pass
  ([jit.md](jit.md#testing)); `test` runs the JIT's own tests through the tier (`vm jit`),
  its naive allocator (`vm jit ssa-naive`) and the re-encoding pipeline (`vm jit reencode`),
  each also with `fp-rbp`. rustc's default merges the corpus's small crates into one codegen
  unit; the `ryo-cgu*` variants ask for 1, 16 and 256 (also with `-Zshare-generics`, fat
  LTO, thin LTO at `-O3` and the JIT), so calls, fn pointers, vtables and statics cross
  images (`tests/vm_cgu.rs` spreads over many).
  Some programs are a staticlib or cdylib called from a
  C `main`, compiled with `cc`, or `cl` on windows-msvc hosts (skipped without one). The smoke tests check that `rustc-ryo`
  rejects `-Zrandomize-layout` and the backend the options it doesn't support
  (`reject-unsupported`, [backend.md](backend.md#unsupported-options)), that two builds of
  `tests/vm_cgu.rs` (many modules) at 16 codegen units give several, byte-identical image
  objects (`cgu-deterministic`), that `tests/vm_cgu_owner.rs` at 16 codegen units defines a
  static once and nothing only a mono-unreachable block uses (`cgu-ownership`), and
  that `cargo-ryo` builds a dev-profile package (incrementally). The `incremental` check
  rebuilds `tests/incremental/edits.rs` after a series of scripted edits (`--cfg revN`) with
  `-Cincremental -Zincremental-verify-ich`: the output must be plain rustc's and the
  executable byte-identical to a clean incremental build's, at opt-level 0 (incremental's
  256 codegen units), at 16 codegen units, at opt-level 2
  with thin and with fat LTO, and with `RYO_NO_VM` at 16 codegen units, where `#![rustc_partition_reused]`
  checks rustc's reuse; and rebuilds a proc macro at the default codegen units. The `backtrace` check builds
  `tests/vm_backtrace.rs` (a panic two VM calls deep, caught by `catch_unwind`) and runs it
  with `RUST_BACKTRACE=1`: the backtrace must name the VM functions by their own
  symbols, and the native frames around them, and the cleanup
  and the catch must still run ([vm.md](vm.md#unwinding)).
- `test` checks (`rt-core-only`) that every sysroot's `ryo_rt` rlib references no symbols
  outside `core`, `compiler_builtins`, `ryo_bytecode`, libc and the panic runtime's entry
  points, and that no call path from its code reaches core's panic machinery
  ([vm.md](vm.md#runtime-crate-ryo_rt), "No re-entry into the VM from the runtime"). It
  skips the bundled JIT object, which `jit-sealed` checks instead: one global definition,
  `ryo_jit_start`, no Rust symbol or allocator shim referenced, no unwinder defined
  ([jit.md](jit.md#packaging)). `jit-private-std` runs `tests/vm_jit_private.rs` with every
  function compiled at its first call: a VM global allocator that trips under its lock, and
  with `-Cpanic=abort` and `RYO_JIT_TEST_PANIC` a panic in every compile, or with
  `RYO_JIT_TEST_OOM` an allocation failure
  ([jit.md](jit.md#testing)).
- With a ryo sysroot in `dist/`, `test` also builds the corpus against it (`--sysroot ryo`):
  variants `ryo-std`, `ryo-std-O3` (output only, like `ryo-O3`),
  `ryo-std-lto` (`-Clto=fat` on the last crate) and `ryo-std-abort` (`-Cpanic=abort`,
  compared with plain rustc's `-Cpanic=abort` build; programs with a Rust dylib are skipped),
  `ryo-std-jit` (run with `RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1`: every VM function, std's
  included, runs its JIT code from its first call), `ryo-std-jit-shuffle` (also
  `RYO_JIT_SHUFFLE=1`) and `ryo-std-jit-reencode` (through the re-encoding pipeline instead
  of the SSA tier). Without a current one (missing, or stale against its inputs), an
  explicit `--full`, `--only std` or `--variant ryo-std-*` fails; otherwise (the fast suite,
  `--only jit`, changed test programs, or `--full` reached from the changed paths) they are
  skipped with a warning.
- `test --cross T`: builds and links, without running, the corpus for target `T` (after
  `build --target T`), against stand-in system libraries ([platforms.md](platforms.md),
  cross-checking). `T` is `x86_64-pc-windows-msvc` (lld-link, `/force:unresolved`, empty
  import libraries) or `x86_64-apple-darwin` (ld64.lld, `-flat_namespace -undefined
  warning`, empty `libSystem`/`libc`/`libm` archives and a `usr/lib/libSystem.B.tbd` that
  exports nothing, as `SDKROOT`, and `-rpath` to `dist/`'s std for the dylib programs). Skipped if the sysroot has no `rust-lld`. It also checks the target's
  bundled JIT object (`jit-sealed`, in the COFF form no `.drectve` or `.CRT$X*` either, in
  the Mach-O form no initializers or `LC_LINKER_OPTION`), and allows the imports of its
  private std. On Mach-O it also runs `rt-core-only` on the target's `ryo_rt` (Mach-O
  relocations, `_`-prefixed names; calls within one object's `__text` have no relocation,
  so it sees fewer edges than on ELF, where every function has its own section) and `registry-first`: in the linked `vm_sysroot`, the first `__mod_init_func` entry is
  the registry constructor (it jumps to `_ryo_vm_register`), ahead of the program's.
- `test --clif`: also builds the corpus with `rustc-clif` and diffs its output too. That
  helps tell ryo bugs from test-corpus problems.
- `bench [--runs N]`: hyperfine comparisons of each program in `bench/` (fib, sieve,
  sort, hashmap) built with LLVM `-O0`, LLVM `-O1` and ryo; `--clif` adds Cranelift (`rustc-clif`). Each comparison
  covers compile time (Cranelift is the fast-compile reference ryo competes with) and run
  time, printed as two tables of mean and standard deviation. Every backend builds
  with cargo's dev profile, except one CGU, no incremental and no debuginfo: what `cargo
  build -v` passes for a leaf crate (`-Cembed-bitcode=no`, debug assertions and with them
  overflow checks at every opt level), without its `-Cdebuginfo=2` (ryo emits none for VM
  code), plus `-Ccodegen-units=1 -Zthreads=1`, so compile times compare one codegen unit
  on one thread. `scripts/compare-branches.py` uses the same
  flags. Failed builds and runs are collected and reported at the end. Without hyperfine on `PATH`,
  a built-in timer does the same (one warmup, then `N` runs, default 5). The programs'
  output must agree across backends. `y bench` builds `dist/`, and cg_clif if a column needs it, first if they are
  missing; `y test --clif` builds cg_clif too.
  `--llvm O0,O2n,..`, `--clif [O0,O3,..]` and `--ryo aot,jit` pick the columns instead (`n`:
  with `-Cdebug-assertions=off`, which turns off overflow checks too; ryo `aot` runs with `RYO_JIT=off`, `jit` with `RYO_JIT_OPT=ssa`); the first column is the
  output reference and the baseline of the ratio tables. A bare `--clif` is `-O0`. cg_clif
  maps `-O0` to Cranelift's `opt_level=none` and every other level (`-O1`..`-O3`, `s`, `z`)
  to `speed_and_size` (`rustc_codegen_cranelift/src/lib.rs`), so its `-O1`..`-O3` differ
  only in what rustc does before codegen (its MIR passes); that still matters, e.g. sieve
  runs about 30% fewer instructions at `-O3` than at `-O1`. `--metric cachegrind` builds once and reports, instead of times, one
  run's instructions (cachegrind `I refs`, children included) and estimated cycles, each
  also as ratios to the first column. It runs cachegrind with `--cache-sim=yes
  --branch-sim=yes`, and the ryo columns (except `aot`) with `RYO_JIT_SYNC=1 RYO_JIT_OPT=ssa`
  so the counts don't depend on when the JIT thread finishes; the estimate is instructions + 10 * (I1 + D1 misses) + 100 * LL misses
  + 10 * branch mispredictions, the same as `scripts/compare-branches.py --metric
  cachegrind` (whose other tables show the misses themselves).
- `bench codegen`: compiles each program in `bench/` with `rustc-ryo`, `RYO_DUMP` and
  `RYO_DUMP_CODE` ([backend.md](backend.md#debugging-switches)), writing the VM instructions
  to `bench/codegen/<program>.txt` and the x86 code, disassembled with iced-x86, to
  `bench/codegen/<program>.s` (relocated operands by name, jump tables as `.long` entries).
  With `RYO_DUMP_NATIVE` it writes `bench/codegen/<program>.native.txt`: the functions that
  stay native, by reason, and the VM functions with islands, of the program's crate only (std
  comes from the LLVM sysroot), under a header saying so.
  The code dumps don't print offsets: branch targets, jump tables and their entries name labels `L<n>`,
  numbered per function by position, with `L<n>:` before each target, so inserting an
  instruction only changes the lines around it. It then runs each program with the JIT
  compiling synchronously at its default threshold (`RYO_JIT_SYNC=1`, `RYO_JIT_OPT=ssa`, other
  `RYO_JIT_*` settings cleared), so that which functions it compiles, in which order, doesn't
  depend on timing, and with `RYO_JIT_DUMP` ([jit.md](jit.md#settings)), and writes, per
  function the JIT compiled, by path as in the AOT dumps: its code to
  `bench/codegen/<program>.jit.s` (printed as `<program>.s`; a function the SSA tier
  doesn't handle is marked `(reencode)`, and the OSR code follows `; OSR entries`), and the
  SSA tier's IR to `<program>.jit-ssa-pre.txt` (as construction leaves it: Braun et al.'s
  construction with its copy and constant propagation and trivial-parameter removal) and
  `<program>.jit-ssa-post.txt` (after the folds, as register allocation gets it). Their
  references to functions, symbols, constants and data are named as in the function's AOT
  code (`fn2`, `sym1`, `k0`; `<program>.txt` lists them), a call slot as `fn2.slot`. The dumps
  are checked in, so `git diff` shows how a backend or JIT change alters the generated code.
  It uses the backend and JIT in `dist/`: run `y build` first.
- `lean`: checks that the Lean tables generated from the opcode lists, `asm::layout` and the
  handler table (`lean/Ryo/Vm/Generated/`) are up to date (the test
  `vm/bytecode/tests/lean_tables.rs`, which `y test` runs too), then runs `lake build` and
  `lake test` in `lean/` (`lake` from `PATH` or `~/.elan/bin`). `lean gen` regenerates the
  tables.
- `y test` also runs `vm/`'s cargo tests (`cargo test --workspace` in `vm/`): the encoder
  against the decoder, the image writer and reader, every handler against a reference
  model, the handlers' codegen, and hand-assembled functions called as native functions
  ([vm.md](vm.md#handlers)), then `ryo_rt`'s again with `--features fp-rbp`, which takes
  the frame-pointer path, and `ryo_jit`'s tests (`-p ryo_jit`, with and without
  `ryo_rt/fp-rbp`, [jit.md](jit.md#testing)), which link the JIT as an rlib; the first run
  excludes `ryo_jit`, so `ryo_rt`'s other tests run without the JIT.
- The corpus runs with the environment `y test` gets, so `RYO_JIT_THRESHOLD=0
  RYO_JIT_SYNC=1 ./y.sh test` runs every VM function's JIT code from its first call
  ([jit.md](jit.md#settings)); the `backtrace` check sets `RYO_JIT=off`, since JIT frames have
  no symbols.

### Fast suite and changed-path selection

A plain `y test` runs the fast set plus the tests the changed paths select
(`build/src/test.rs`: `FAST`, `RULES`, `select`); `--full` runs everything above.

- The fast set: two cargo runs in `vm/`, `vm` (`--workspace --exclude ryo_jit`, without
  vm/rt/tests/codegen.rs and the slow `every_opcode_round_trips`) and `vm jit` (`-p ryo_jit`,
  `RYO_JIT_OPT=ssa RYO_JIT_CHECK=1`); the corpus programs in `FAST`, each under the variants
  listed there (`ryo` on most, the `ryo-jit-ssa*` variants on the VM programs, `ryo-lto` on
  `vm_lto_dep`, `ryo-abort` on `vm_abort_cleanup`, `ryo-std` and `ryo-std-jit` on
  `collections`); and the cheap checks (`reject-unsupported`, `cgu-deterministic`, `cgu-ownership`, `metadata-only`, `dump`, `exports`,
  `backtrace`). Every other corpus program is on `FULL_ONLY` with a reason; a unit test
  checks that each program is on exactly one of the two lists. Without a current ryo sysroot
  the ryo-std entries are skipped with a warning; the fast suite never builds the sysroot.
- Changed paths: those in `git diff --name-only` against the merge base with `main`, plus
  untracked files. Each matches the first prefix in `RULES` (`Cargo.lock` and `*.md` outside
  `lean/` are matched first), and the extras are printed as `[y] extra: <what> (<path>
  changed)`:
  - `notes/`, `design/`, `.github/`, `*.md` outside `lean/`, `vm/bytecode/tests/` (the fast
    set runs them) and `bench/codegen/`: nothing extra.
  - `lean/`, `tests/lean/`: `y lean` (if `lake` is present).
  - `vm/bytecode/src/{asm/,asm.rs,full.rs,reduced.rs,abi.rs}`: the whole corpus under `ryo`
    and the JIT variants, all six `ryo_jit` runs, the slow vm tests, `y lean`.
  - `vm/bytecode/src/jit*`, `vm/jit/`: all six `ryo_jit` runs, the corpus under the JIT
    variants (`ryo-jit-ssa`, `-osr`, `-shuffle` and the `ryo-std-jit*` ones), `jit-private-std`.
  - `vm/rt/src/vm/handlers.rs`: as other `vm/rt/` paths, plus `y lean`.
  - `vm/rt/src/`, `vm/rt/tests/`, `vm/rt/build.rs`: the `fp-rbp` runs, codegen.rs,
    `rt-core-only`, `jit-sealed`.
  - `backend/`: the whole corpus under every variant (the ryo-std ones need a current
    sysroot), every check, the slow vm tests and the JIT set.
  - `tests/<file>`: the programs built from that file (or its directory) under every
    variant, and the checks that use it.
- Escalation to `--full` (`[y] escalating to --full: <why>`): any changed path under
  `build/`, `bench/` outside `bench/codegen/`, `scripts/`, `rust-toolchain*` or a
  `Cargo.lock`; a path no rule matches; a `tests/` file no program or check uses; or when
  git can't list the changed paths. A unit test checks that every top- and second-level
  directory git tracks has a rule. `--full` fails, instead of skipping, without a current
  ryo sysroot, and adds `y lean` if `lake` is present.
- `--no-changed` runs only the fast set; `--only jit|backend|lean|std|rt` only that area's
  extras, without the fast set; `--program`/`--variant` only those corpus entries, without
  cargo runs or checks.

### `bench crates`

`y bench crates [--build-samples N] [--run-samples N] [--quick] [--crates a,b|all] [--backends
llvm,clif,ryo] [--path DIR] [--timeout SECS] [--out FILE]` compares LLVM (plain rustc), ryo
(`rustc-ryo`, default sysroot) and, if `--backends` names it, Cranelift (`rustc-clif`) on
real crates.io crates, in cargo's `dev` profile only. The default is `llvm,ryo`. Written in Rust in `build/src/crates/`.

- **Crates** (`CRATES` in `build/src/crates/mod.rs`): semver, smallvec, miniz_oxide, memchr,
  hashbrown, rand, regex-syntax, unicode-segmentation, serde_json. Pure Rust, no C
  dependencies, their own test suites ship in the `.crate` archive, and they build on the
  pinned stable. Each is pinned by version and sha256; the archive is downloaded once into
  `target/bench-crates/cache/`, extracted fresh each run into `target/bench-crates/src/`,
  and built `--locked --offline` against the `Cargo.lock` it was published with (after a
  `cargo fetch`). A crate that fails to download or prepare is reported, and the rest still run. Dependencies come
  from cargo's registry cache (network on first use). Crates whose archives lack test data
  (regex), or whose dev-dependencies don't build with `RUSTC_BOOTSTRAP=1` (nom, through
  rustix 0.37), were left out.
  Without `--crates`, only `DEFAULT_CRATES` run: miniz_oxide (tight integer loops),
  hashbrown (generic hashing and probing) and regex-syntax (a large, enum-heavy parser).
  `--crates all` runs every crate.
- **Local workspaces**: `--path DIR` benches the workspace at `DIR` instead, in place (only
  the target directory is the bench's). It is built with `--workspace`, so every member is
  the leaf (cargo's primary packages, cleaned with `cargo clean -p` for the leaf samples) and
  everything else, registry and git crates, a dependency. It has no workload. Its
  per-package profile overrides (`[profile.dev.package."*"]`) get the dev defaults restated
  through `cargo --config` (not under `--stock`), rather than rejecting the workspace.
- **Workloads**: `tests/crates/<crate>.rs`, added to the extracted package as the
  `ryo_bench` example (published manifests set `autoexamples = false`). Each prints a
  checksum that must be the same for every backend.
- **Fairness**: every backend gets `RUSTFLAGS=-Cdebuginfo=0 -Ccodegen-units=1 -Zthreads=1`
  (no `--target`, so dependencies, build scripts and proc macros too), `CARGO_BUILD_JOBS=1`,
  `CARGO_INCREMENTAL=0`, `RUST_TEST_THREADS=1`, no LTO, no target-cpu, the default linker.
  The dev profile's defaults (opt-level 0, debug assertions, overflow checks, unwind) are
  restated through `CARGO_PROFILE_{DEV,TEST}_*`, since crates can override `profile.test`
  (memchr sets opt-level 3); build overrides are forced the same way, and a crate with
  per-package profile overrides is rejected (none of the nine has any). `rustc-ryo` forces `-Ccodegen-units=1` anyway; no MIR
  optimization flags are added for any backend.
- **`--stock`**: none of the above; cargo's and rustc's defaults (the crate's own profiles,
  parallel jobs, codegen units, incremental, debuginfo), only `RUSTC` changed. An unfair
  comparison, for what a user would see.
- **Steps** of a build: `cargo build --lib`, `cargo build --tests` (`cargo test`'s build),
  `cargo build --example ryo_bench`. The warm-up starts from a clean target directory and
  builds the dependencies. Dependency samples (`--dep-samples`) start from a clean target
  directory too and give the dependency metrics; leaf samples (`--leaf-samples`) first run
  `cargo clean -p <crate>`, so only the crate is rebuilt (one that rebuilds a dependency
  fails), and give all other build metrics. `--build-samples N` sets both. Run samples run
  every test binary from the package directory (as `cargo test` would; doc tests are not
  run; memchr skips its five exhaustive `forward_packedpair` tests, 115 of its 120 s with
  LLVM) and the workload. Binary sizes are the workload and the test binaries.
- **Compile-time sections**, measured inside rustc like cargo's `-Zsection-timings`, not
  with `-Zself-profile`/`-Ztime-passes`: cargo is run with `-Zsection-timings --timings`,
  so it passes `--json=timings` and rustc emits `section_timing` records (`codegen` from
  `start_codegen`, before the backend's `codegen_crate`, to after `join_codegen`; `link`
  around linking). Cargo only keeps them rounded to 10 ms in its HTML, so `y` is also the
  `RUSTC_WRAPPER` (selected by `RYO_Y_BENCH_WRAPPER`): it forwards rustc's stderr to cargo
  unchanged and logs the records, the process's wall time and `CARGO_PRIMARY_PACKAGE`
  (leaf vs dependency) per invocation. Frontend = process start to codegen start, backend
  = codegen, link = link, other = the rest of the rustc process.
- **Samples**: default 5 dependency, 5 leaf and 10 run samples (`--quick`: 1 each;
  `--dep-samples 0` and `--run-samples 0` skip those), always after one
  discarded warm-up; backends are interleaved (llvm clif ryo llvm clif ryo …). Reported:
  median, min, standard deviation, n; a cell is noisy if its standard deviation exceeds 3%
  of its median. Timing is `y`'s own loop (no hyperfine). A run sample in which a test
  binary fails or times out, or the workload fails, is dropped (and reported), so n shrinks
  rather than a partial sum being counted. Cargo's target-info probe and `--print` queries
  pass through the wrapper unlogged.
- **Coverage**: ryo's warm-up build runs with `RYO_STATS=1`, which the wrapper strips from
  stderr and logs; the report shows VM/native functions and islands for the library, its
  dependencies and the test targets, native reasons and island templates. The warm-up is
  not timed, so the statistics cost nothing in the samples.
- **Output**: `target/bench-crates/report.html` (or `--out`), self-contained (inline CSS,
  SVG, a few lines of JS for tooltips): a header with toolchain, flags, machine and date;
  test results and every build, test or workload failure; a compile-time breakdown; per
  metric a chart of each backend relative to LLVM (log axis, ± stddev whiskers) and a table;
  coverage; per-unit times. A text summary goes to stdout. Failures are reported, not fatal.


## Layout

```
y.sh, y.cmd, y.ps1                         entry points for the build tool
build/          bin        y                   build tool (own Cargo.lock, no deps)
  clif/                                        cg_clif sources copied by `y build-clif` (not committed)
scripts/                                       rustc-ryo.rs, cargo-ryo.rs, rustc-clif.rs wrappers;
                                               Cargo.toml, launcher.rs: `y install`'s launchers
install/                                       `y install`'s build and installed copy (not committed)
backend/        dylib      rustc_codegen_ryo   #![feature(rustc_private)]
vm/             cargo workspace for everything that ends up in the output program
  bytecode/     rlib       ryo_bytecode        format: opcodes, machine code, image layout;
                                               used by the backend (writer) and the VM (reader)
  rt/           rlib       ryo_rt              the runtime: handlers, registry,
                                               island templates, `main` wrapper, the JIT's
                                               trips; bundles the sealed JIT
  jit/          staticlib  ryo_jit             the JIT thread (compiler, installer), sealed
                                               with its own std by `y build`; an rlib in
                                               `vm/`'s tests
tests/                                         test programs, driven by `y test`
  crates/                                      workloads for `y bench crates`
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
