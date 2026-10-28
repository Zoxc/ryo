# Cheat sheet

`./y.sh --help` lists every command; `design/build.md`, `design/backend.md#debugging-switches`
and `design/jit.md#settings` have the details.

## Using ryo in another project

Build once with `./y.sh build` (add `--sysroot ryo` for a std built with ryo), then run the
wrapper by its path. It runs the pinned cargo with `RUSTC` set to `rustc-ryo`:

```sh
cd ~/src/my-crate
~/dev/ryo/dist/bin/cargo-ryo build
~/dev/ryo/dist/bin/cargo-ryo run --release
```

- `cargo ryo build`: works with `dist/bin` on `PATH`, or with `cargo-ryo` symlinked into it.
- `RUSTC=~/dev/ryo/dist/bin/rustc-ryo cargo build`: an existing cargo.
- `~/dev/ryo/dist/bin/rustc-ryo -O main.rs`: a single file.
- `RUSTFLAGS="--sysroot ryo"`: use the std built with ryo.

Cargo rebuilds when ryo is rebuilt, and keeps ryo and plain-cargo artifacts apart in
`target/`. The debugging switches below work for programs built this way.

## Build

- `./y.sh build`: backend, sysroot and wrappers into `dist/`.
- `./y.sh build --sysroot ryo`: also std built with ryo. `./y.sh build` doesn't rebuild it,
  so rerun this after backend or runtime changes.
- `./y.sh build --target x86_64-pc-windows-msvc`: also std and `ryo_rt` for that target
  (needed before `test --cross`).

## Test

- `./y.sh test --no-changed`: the fixed fast set.
- `./y.sh test --only jit`: one area: `jit`, `backend`, `lean`, `std` or `rt`.
- `./y.sh test --program hello --variant ryo`: one corpus program and variant.
- `./y.sh test --cross x86_64-pc-windows-msvc`: cross-build and link the corpus, not run.
- `./y.sh test`: the fast set plus tests the changed paths select. Changes to the build
  tooling escalate it to `--full`, which runs everything.
- `RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1 ./y.sh test`: everything through the JIT.
- `(cd backend && RUSTC_BOOTSTRAP=1 cargo test)`: backend unit tests, not run by `y test`.

`y test` skips the ryo-std variants when the ryo sysroot is stale, unless they're asked for,
and uses a JIT with debug assertions (`RYO_JIT_CHECKED=0` for the release one).

## Lean

- `./y.sh lean`: checks the generated tables, then `lake build` and `lake test`.
- `./y.sh lean gen`: regenerates the tables after editing `full_ops.rs`.
- `./y.sh lean --proofs`: also the slow proofs.
- `(cd lean && lake build ryo-lean)`: rebuilds `ryo-lean` ("unknown opcode" means it's
  stale).

## Benchmarks

- `./y.sh bench --metric cachegrind`: LLVM -O0 and -O1 and ryo on `bench/`,
  instructions and estimated cycles per run. Everything builds with cargo's dev profile
  (debug assertions, overflow checks), except one CGU, no incremental and no debuginfo.
  `--llvm O0,O3n`, `--clif O0,O3` and `--ryo aot,jit` pick the columns (`n`: no debug
  assertions or overflow checks); cg_clif's O1 to O3 share one Cranelift level and differ
  only in rustc's MIR passes. compare-branches uses the same flags; add
  `--flags=-Cdebug-assertions=off` to turn the checks off.
- `./y.sh bench codegen`: rewrites `bench/codegen/` (after `./y.sh build`).
- `./y.sh bench crates --quick`: crates.io crates with LLVM and ryo (`--backends
  llvm,clif,ryo` adds Cranelift), one sample each (the default is 5 builds and 10 runs).
  `--crates memchr` narrows it.
- `scripts/compare-branches.py --worktree <base> --build head=. --metric cachegrind`:
  compares against a base commit; `--programs fib` for one program, `RYO_JIT=off` for AOT
  only.

Use `--metric cachegrind`, not CPU time: the machine is usually busy.

## Debugging switches

Compiling:

- `RYO_DUMP=f`, `RYO_DUMP_CODE=f`: the VM code, the machine code.
- `RYO_STATS=1|2`: lowering statistics.
- `RYO_NO_VM=1`: everything native.
- `RYO_ASM_CHECK=1`: checks the encoder's output.

Running:

- `RYO_JIT=off`: AOT code only.
- `RYO_JIT_THRESHOLD=0`: compile on the first call (or `n`, or `e,l`).
- `RYO_JIT_SYNC=1`: compile synchronously (deterministic; needed for cachegrind).
- `RYO_JIT_OPT=ssa|ssa-naive|reencode`: the JIT tier.
- `RYO_JIT_CHECK=1`, `RYO_JIT_LOG=1`, `RYO_JIT_DUMP=dir`: check, log, dump.
- `RYO_JIT_SSA_LIMIT=n`: only the first `n` functions through the SSA tier, for bisecting.
