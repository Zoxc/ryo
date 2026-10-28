# ryo

A rustc codegen backend for fast development builds: MIR is lowered to VM code, with a JIT
at run time.

## Requirements

Beyond what plain Rust needs (rustup, a linker):

- x86_64 only: Linux, Windows (MSVC) or macOS.
- Exactly **Rust 1.99.1** with the components `rustc-dev`, `rust-src` and `llvm-tools`.
  `./y.sh install` installs them through rustup if you don't have them (and removes them
  again on uninstall if it installed them).

## Install

```sh
git clone https://github.com/Zoxc/ryo
cd ryo
./y.sh install
```

On Windows (PowerShell):

```powershell
git clone https://github.com/Zoxc/ryo
cd ryo
.\y.ps1 install
```

It first prints exactly what it will do and asks `Proceed? [y/N]`; nothing changes before
you answer. Then:

1. Installs Rust 1.99.1 with `rustc-dev`, `rust-src` and `llvm-tools` through rustup, or
   adds whatever is missing. Your default toolchain isn't changed.
2. Builds ryo and keeps it in `install/` in the checkout, apart from development builds.
3. Installs `cargo-ryo` and `rustc-ryo` in `~/.cargo/bin` (on your `PATH` with rustup).
   They run the ryo in `install/`, so keep the checkout: deleting or moving it breaks the
   install (run `./y.sh uninstall` first).

Afterwards `cargo ryo build` works in any Cargo project.

In scripts and CI pass `--yes`: without a terminal, `y install` refuses to run otherwise.
`--dry-run` only prints the plan. On Windows run it from PowerShell or cmd (in Git Bash,
pass `--yes`).

Options:

- `--target x86_64-pc-windows-msvc` (repeatable): also support cross-compiling to that target.
- `--sysroot ryo`: also build a standard library compiled by ryo (for the host).
- `--no-toolchain-install`: fail (printing the rustup commands) instead of changing rustup.

To update: `git pull && ./y.sh install`. The previous version is replaced, and toolchain
pieces only it needed are removed (they're listed in the plan).

Only one checkout can be installed at a time: installing from a second checkout is refused
until you run `./y.sh uninstall` in the first.

## Usage

```sh
cargo ryo build
cargo ryo test
cargo ryo run --example foo
```

Other ways: `.cargo/config.toml` `[build] rustc = "rustc-ryo"` with `cargo +1.99.1 build`;
a single file: `rustc-ryo main.rs`. `-Zcodegen-backend=…` in `RUSTFLAGS` on its own does
**not** work: ryo also needs its own sysroot and runtime crate, which the wrappers add.

ryo is meant for fast development builds; use plain `cargo build --release` for releases.
Your profile settings work as with LLVM; after updating ryo, cargo rebuilds everything once
(old incremental data piles up until `cargo clean`).

| Setting | Where | Effect |
|---|---|---|
| `RUSTFLAGS="--sysroot ryo"` | build | Use the ryo-built std (needs `--sysroot ryo` at install) |
| `RYO_STATS=1` | build | Print how many functions became VM code |
| `RYO_NO_VM=1` | build | Compile everything natively (to rule ryo's VM in or out) |
| `RYO_JIT=off` | run | Disable the JIT in the built program |
| `RYO_JIT_THRESHOLD=N` | run | Calls before a function is JIT-compiled |

macOS: programs built with ryo JIT-compile at run time. If you sign one with the hardened
runtime, give it the `com.apple.security.cs.allow-unsigned-executable-memory` entitlement,
or run it with `RYO_JIT=off`.

## Uninstall

```sh
./y.sh uninstall
```

On Windows (PowerShell):

```powershell
.\y.ps1 uninstall
```

Like install, it prints what it will remove (and what it keeps, and why) and asks
`Proceed? [y/N]`; `--yes` for scripts, `--dry-run` to only look. Then, in this order:

1. `cargo uninstall cargo-ryo` (the launchers in `~/.cargo/bin`).
2. From rustup, **only what ryo added**: the Rust 1.99.1 toolchain if ryo installed it,
   otherwise the components and targets it added to yours (`--keep-toolchain` keeps them).
3. `install/` in the checkout.

Afterwards you can delete the checkout. Not touched: cargo's download cache, development
builds (`dist/`, `target/`) and your projects' `target/` dirs. Projects that selected ryo
through `.cargo/config.toml` need that setting removed.

## Development

```sh
./y.sh build
./y.sh test
dist/bin/cargo-ryo build
```

On Windows (PowerShell):

```powershell
.\y.ps1 build
.\y.ps1 test
dist\bin\cargo-ryo.exe build
```

`./y.sh build` builds into `dist/` and `./y.sh test` runs the tests; `./y.sh --help` lists
the other commands (benchmarks, the Lean model, cross builds). Development builds and
`./y.sh install` don't affect each other; to make the installed launchers use your `dist/`,
set `RYO_HOME=<checkout>/dist`. [CHEATSHEET.md](CHEATSHEET.md) lists the common commands and
settings, and the design docs start at [design/README.md](design/README.md).

## License

ryo is licensed under either of the [MIT license](LICENSE-MIT) or the
[Apache License 2.0](LICENSE-APACHE), at your option.

The Lean specification in `lean/` includes ports of
[MiniRust](https://github.com/minirust/minirust) by the MiniRust contributors, used under
the same MIT / Apache-2.0 terms; see [lean/README.md](lean/README.md#license-and-attribution).

Unless you explicitly state otherwise, any contribution you submit for inclusion in ryo is
dual licensed as above, without any additional terms or conditions.
