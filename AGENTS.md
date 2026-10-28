# User rules

- Committing. Whatever is uncommitted when you start stays uncommitted.
- Don't reference an uncommitted file from a committed one.
- Commit messages. Keep the title brief -- a line, not a paragraph -- and start it with an
  uppercase letter (`Add …`, `JIT: …`, not `add …` or `backend: …`). Prefer an area prefix
  naming what the change is about: `Backend:`, `JIT:`, `JIT SSA:`, `Image:`, `Rt:`,
  `Build:`, `Test:`, `Bench:`, `Lean:`, `Scripts:`, `CI:`, `Docs:`. Put what needs saying
  under it, ideally in one short paragraph
- One commit per piece of work. Squash a branch into a single commit, so that rebasing,
  testing and regenerating dumps and Lean tables happen once; split it only for a good reason
  (e.g. a fix that predates the branch, or work the user asked to land per task)
- Codegen dumps. After every change that can affect the generated code (AOT or JIT), run
  `./y.sh build && ./y.sh bench codegen` and commit the regenerated `bench/codegen/`
  with that change, so its diff shows the effect.
- Testing. Run `./y.sh test --no-changed` plus the targeted runs for what you changed
  (`--only jit|backend|lean|std|rt`, `--program …`). Don't run `./y.sh test --full` unless
  asked; plain `./y.sh test` escalates to it when the test selection inputs change. Rebuild
  the ryo sysroot and `ryo-lean` first if they're stale. Say which suites you ran.
- Optimizing. When a change is meant to make generated code faster, compare it against the
  commit before with `scripts/compare-branches.py --worktree <base> --build head=. --metric
  cachegrind` (deterministic, so small differences are real), and report both the
  instruction counts and the estimated cycles (instructions plus weighted cache misses and
  branch mispredictions), so changes that move cost without moving instructions show.
- CPU time. Don't measure or rely on CPU time unless the user asks: the machine is typically
  busy, so timings are noise.
- Lean sync. Changes to the Rust code (backend, JIT, VM) don't update the Lean code. Instead,
  when a change affects what the Lean model or proofs describe, add an entry to
  `lean/PENDING.md` saying what changed (with the commit), for a later Lean session to apply.
  That session removes the entries it handles.
- No compatibility concerns. The backend, VM and JIT are built and linked together, so image
  formats, opcodes and ABIs between them can change freely: no versioning, migration or
  backward compatibility needed.
- Lean effort. When delegating Lean work to subagents, use medium effort for writing specs
  and low effort for proofs.

# Project rules

- Formatting. Run `cargo fmt` in each workspace you changed (`backend`, `build`, `vm`) before
  committing; `rustfmt.toml` at the root sets the style.

# Project overview

ryo is a rustc codegen backend: MIR is lowered to VM instructions, encoded as x86-64 machine
code that calls the VM's handlers; cg_llvm compiles everything else. Start at
`design/README.md` (terms, goals, index of the design docs).

## Repo map

- `backend/` (workspace): `rustc_codegen_ryo` dylib. `src/lib.rs` is the
  `CodegenBackend` impl; `lower/` is MIR -> bytecode (`design/lowering.md`), `partition.rs`
  the pipeline, `link.rs` the registry object (`design/backend.md`).
- `vm/` (workspace, everything that ends up in the output program, `design/vm.md`):
  - `bytecode/` `ryo_bytecode` (`no_std`): the format shared by writer and reader. `ops.rs`
    is the opcode list (single source of truth; order = encoding), `asm/` the machine code
    encoder/decoder and reduced set, `image/` the image format, `jit/` the JIT's SSA tier.
  - `rt/` `ryo_rt` (`no_std` outside tests): handlers (`src/vm/handlers.rs` lists them,
    `interp.rs` the handler-kind macros), registry, island templates (`island.rs`), `main`
    wrapper (`entry.rs`), the JIT trips (`src/vm/jit/`).
  - `jit/` `ryo_jit`: the JIT thread (compile, install); sealed with its own std by
    `y build`, an rlib in `vm/`'s tests.
- `build/` (workspace): the `y` build tool, zero deps (`design/build.md`).
- `scripts/`: `rustc-ryo`/`cargo-ryo`/`rustc-clif` wrappers, the `y install` launcher
  package (`Cargo.toml`, `launcher.rs`), `compare-branches.py`,
  `lean-*` checkers.
- `tests/`: the corpus `y test` builds with ryo and plain rustc and diffs; `tests/lean/` the
  Lean-checked programs; `tests/crates/` workloads for `y bench crates`.
- `bench/`: `fib`, `sieve`, `sort`, `hashmap`; `bench/codegen/` the checked-in dumps.
- `lean/`: Lean model and proofs (`lean/README.md`, `lean/docs/`, `design/verification.md`);
  `lean/PENDING.md` lists Rust changes not yet reflected there.
- `design/`: the design docs; `instructions.md` documents every instruction.

## Tiers

- AOT: the backend emits each VM function as machine code calling handlers
  `ryo_h_<Opcode>` (some instructions inline). There is no interpreter loop: VM functions
  are native functions under their own symbols (`design/stubs.md`).
- Islands: operations the VM lacks run as `ryo_rt` template instances compiled by cg_llvm.
- JIT (`design/jit.md`): counters in each function's JIT record trip into `ryo_rt`, which
  queues the function for the `ryo_jit` thread. It decodes the AOT code back to the reduced
  set and compiles it with the SSA tier (`vm/bytecode/src/jit/`, `RYO_JIT_OPT=ssa`, the
  default) or re-encodes it (`reencode`), then installs it through call slots.
- OSR: running calls switch to JIT code at loop heads (`design/jit.md#osr`).

## `./y.sh` commands (`./y.sh --help`)

- `build [--sysroot llvm|ryo] [--target T]`: backend, sysroot, wrappers into `dist/`.
  `--sysroot ryo` also builds std with ryo (`dist/sysroot-ryo/`).
- `test`: fast set plus tests selected by paths changed since the merge base with `main`;
  `--full` (needs the ryo sysroot), `--only jit|backend|lean|std|rt`, `--no-changed`,
  `--clif`, `--cross T`. One program/variant: `./y.sh test --program hello --variant ryo`
  (names are file stems and variants in `build/src/test.rs`).
- vm crates directly: `cargo test --manifest-path vm/Cargo.toml -p ryo_bytecode --test
  jit_ssa` etc. (`ryo_jit`'s tests need `-p ryo_jit`).
- `bench [--runs N] [--llvm O0,O3] [--clif] [--ryo aot,jit] [--metric time|cachegrind]`: no
  per-program filter; use `compare-branches.py --programs fib` for one.
- `bench codegen`: rewrites `bench/codegen/` (AOT `.txt`/`.s`, JIT `.jit.s`,
  `.jit-ssa-{pre,post}.txt`) using `dist/`, so `./y.sh build` first.
- `bench crates [...]`: crates.io crates per backend, HTML report.
- `install [--target T] [--sysroot ryo] [--yes|--dry-run]` / `uninstall`: install ryo for
  use into the checkout's `install/` plus `cargo install --path scripts` launchers
  (`design/install.md`). Changes the real rustup and `~/.cargo/bin`: test with `--dry-run`
  or an isolated `RUSTUP_HOME`/`CARGO_HOME`.
- `lean [gen | --proofs]`, `build-clif`, `clean` (not `install/`).

## Env vars

- Backend (`design/backend.md#debugging-switches`): `RYO_STATS=1|2`, `RYO_DUMP=<file>`,
  `RYO_DUMP_CODE=<file>`, `RYO_DUMP_NATIVE=<file>`, `RYO_NO_VM`, `RYO_ASM_CHECK`, `RYO_ASM_ALIGN=0`,
  `RYO_BACKEND_MARKER`, `RYO_DUMP_LEAN=<dir>`.
- Runtime/JIT (`design/jit.md#settings`): `RYO_JIT=off`, `RYO_JIT_THRESHOLD=n` (or `e,l`;
  0 = first call), `RYO_JIT_SYNC=1` (deterministic; needed for cachegrind),
  `RYO_JIT_OPT=ssa|ssa-naive|reencode`, `RYO_JIT_CHECK=1`, `RYO_JIT_DUMP=<dir>`,
  `RYO_JIT_LOG=1`, `RYO_JIT_SHUFFLE=1`, `RYO_JIT_PERFMAP=1`, `RYO_JIT_SSA_LIMIT=n` (bisect
  miscompiles), `RYO_JIT_LICM=1` (general LICM, off by default), `RYO_JIT_ROTATE=1` (loop rotation, off by
  default), `RYO_JIT_STATS=1|2` (startup
  line and exit summary on stderr; `2` adds progress at most once a minute), `RYO_JIT_TEST_PANIC=1`, `RYO_JIT_TEST_OOM=1`.
- `y test` passes its env to the corpus: `RYO_JIT_THRESHOLD=0 RYO_JIT_SYNC=1 ./y.sh test`
  runs everything through the JIT.
- Build: `RYO_RT_FEATURES` (e.g. `fp-rbp`); `RYO_LEAN_GEN=1` makes the `lean_*` tests rewrite
  their generated files.

## Measuring

- `scripts/compare-branches.py --worktree <base> --build head=. --metric cachegrind`:
  instruction counts (one sample; `RYO_JIT_SYNC=1 RYO_JIT_OPT=ssa` set; `RYO_JIT=off` for
  AOT only). Its default metric is CPU time, so always pass `--metric cachegrind`; it then
  also reports estimated cycles, misses and branch mispredictions. See its docstring.
- `./y.sh bench --metric cachegrind` for LLVM/Cranelift/ryo columns.

## Generated files

- `bench/codegen/`: `./y.sh bench codegen`.
- `lean/Ryo/Vm/Generated/`: from `ops.rs`, `asm::layout` and the handler table; checked by
  `vm/bytecode/tests/lean_tables.rs`, regenerated by `./y.sh lean gen`. Other Lean
  vectors come from `vm/bytecode/tests/lean_*.rs` with `RYO_LEAN_GEN=1`.

## Pitfalls

- `ryo_rt` and `ryo_bytecode` are `no_std`; `ryo_rt` must not reach core's panic machinery
  or symbols outside core/libc (`y test`'s `rt-core-only` check, `design/vm.md`).
- Editing `ops.rs` changes opcode numbering: regenerate the Lean tables and codegen dumps.
- `compare-branches.py --worktree` creates nested git worktrees under `target/compare/`;
  exclude `target/` when searching, and remove them with `git worktree remove`.
- Toolchain is pinned to stable 1.99.1 with `RUSTC_BOOTSTRAP=1` (`rust-toolchain.toml`,
  `design/build.md#toolchain`).
- The JIT is built for Linux, Windows and x86_64 macOS, but has only ever run on Linux.
