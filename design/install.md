# Installing ryo

`./y.sh install` installs ryo for use on one's own crates; `./y.sh uninstall` undoes it.
The code is `build/src/install.rs` and the launcher package `scripts/Cargo.toml`.

Contributors don't use it: `./y.sh build` builds into `dist/` and `dist/bin/cargo-ryo` is
used directly ([build.md](build.md)). That path is unchanged and stays the reference;
`install/` exists only for `y install`, and the two never touch each other's directories.

## Why it works this way

- The backend is a `rustc_private` dylib linked against the exact `librustc_driver` of rustc
  1.99.1 with `rustc-dev`, and needs a sysroot that `y build` assembles (std, `ryo_rt`,
  rust-lld). `cargo install` can only build and copy `bin` targets, so it can't produce a
  working ryo on its own.
- The real wrappers (`scripts/rustc-ryo.rs`, `cargo-ryo.rs`) find their sysroot from their own
  canonicalized path, so they must stay next to it.

So `y install` builds ryo into the checkout's `install/` and keeps the installed copy there,
and `cargo install --path scripts` delivers small **launchers** into cargo's bin dir
(`~/.cargo/bin`, on `PATH` for rustup users) that run the real wrappers in `install/`. No
PATH or shell setup of ours; `cargo install --list`/`cargo uninstall` see the launchers like
any cargo tool.

Consequence (accepted): the installed ryo lives in the checkout. Deleting or moving the
checkout breaks it (the launchers then say ryo isn't installed); run `./y.sh uninstall`
first.

## Layout of `install/`

Everything except the launchers and what is added to rustup is under `<checkout>/install/`
(gitignored):

| Path | What |
|---|---|
| `install/target/` | cargo output of the install build |
| `install/build/` | `y`'s output dir for the install build: what `dist/` is for `y build` |
| `install/<version>/` | the installed ryo: a copy of `install/build/` |
| `install/current` | a text file naming the active `<version>` (a file, not a symlink) |
| `install/manifest.toml` | what the install added |
| `install/.lock` | held while `y install`/`uninstall` run (exclusive create, with the pid; taken over if that process is dead) |

- `dist::build_in` takes the output and target dirs as parameters (`y build` passes `dist/`
  and `target/`), so a dev build and an install can run at once without sharing cargo locks
  or forcing each other's rebuilds.
- Everything the install build spawns runs with `RUSTUP_TOOLCHAIN=1.99.1-<host>`, so the
  wrappers bake in that explicit name, never `stable`, and `rustup update` can't swap it.
- `<version>` is `git describe --always --dirty`, for humans. Copying `install/build/` to a
  fresh `install/<version>/` keeps the installed ryo intact while a later install builds,
  gives each install a new wrapper path (cargo caches `rustc -vV` by path and mtime) and
  fresh mtimes (the backend's incremental fingerprint uses the dylib's mtime).
- `y clean` doesn't touch `install/`; only `y uninstall` removes it.

## The launchers

`scripts/Cargo.toml` is a package `cargo-ryo` (own workspace, no dependencies, `publish =
false`) with the bins `cargo-ryo` and `rustc-ryo`, both `scripts/launcher.rs`. Each execs
`<dir>/bin/<its name>` with its arguments, where `<dir>` is `$RYO_HOME` if set (e.g. a
development `dist/`), else `<checkout>/install/<contents of current>`, the checkout coming
from `CARGO_MANIFEST_DIR` at build time (`cargo install --path` builds from the source dir,
so a hand-run `cargo install --path scripts` works the same). Without an install:
`error: ryo is not installed in <checkout>/install; run ./y.sh install there`.

They exec the versioned path, so the real `cargo-ryo` sets `RUSTC` to a path that changes
with each install. All logic stays in the real wrappers.

## `y install`

```
y install [--target T]... [--sysroot llvm|ryo] [--no-toolchain-install] [--yes] [--dry-run]
```

1. **Plan** (read-only): rustup's host (x86_64 only; on Apple silicon it says to rerun under
   Rosetta), which of the toolchain `1.99.1-<host>`, the components `rustc-dev`, `rust-src`,
   `llvm-tools` and the targets are missing, the previous manifest, the cargo root
   (`$CARGO_INSTALL_ROOT`, else `$CARGO_HOME`, else `~/.cargo`) and who installed `cargo-ryo`
   there. Printed, then confirmed (below). `--no-toolchain-install` fails here, printing the
   rustup commands to run, if anything is missing.
2. **Toolchain**: `rustup toolchain install 1.99.1 --profile minimal`, `rustup component
   add`, `rustup target add` for what is missing. The manifest is written after each, so a
   later failure leaves the additions recorded. Checks `rustc +<toolchain> -vV` reports
   1.99.1.
3. **Build** into `install/build/` and `install/target/` (`dist::build_in`).
4. **Copy** to `install/<version>.partial/`, rename it to `install/<version>/` (an existing
   one of the same version is removed first), write `install/current` and the manifest.
5. **Launchers**: `cargo +1.99.1-<host> install --locked --force --path <checkout>/scripts
   --root <cargo root>` (the pinned toolchain, which is certainly there).
6. **Previous version**: its `install/<old version>/` is deleted, and targets it added that
   this install doesn't need are removed from rustup, and so is what earlier installs added to
   other toolchains (an older pinned version, another host; all shown in the plan).
7. **Report**, including a hint if cargo's bin dir isn't on `PATH` (shell files are never
   edited).

A failure before step 4 leaves the previous install working (only `*.partial` and the build
dirs changed); `*.partial` and `*.old` leftovers are deleted on the next run. Reruns are
idempotent.

### A second checkout

Only one checkout's launchers can be in a cargo root. If `cargo install --list` shows
`cargo-ryo` installed from anywhere but this checkout's `scripts/`, `y install` refuses in the
plan step, naming the other checkout and saying to run `./y.sh uninstall` there (or `cargo
uninstall cargo-ryo`). There is no `--force` to share or take over.

## The manifest

`install/manifest.toml`, written and read by `y` (a TOML subset, no dependency):

```toml
format = 1
version = "0.3.0-41-g7654b22"
build_id = "9f2c…"
host = "x86_64-unknown-linux-gnu"
targets = ["x86_64-unknown-linux-gnu", "x86_64-pc-windows-msvc"]
sysroots = ["llvm"]
cargo_root = "/home/u/.cargo"

[toolchain]
name = "1.99.1-x86_64-unknown-linux-gnu"
installed_by_ryo = true
components_added = ["rustc-dev", "rust-src", "llvm-tools"]
targets_added = ["x86_64-pc-windows-msvc"]
```

Only what is recorded is ever removed: what the user already had is never recorded (the plan
says "yours"), and what an earlier install recorded stays recorded. When the toolchain changes
(a pin bump, another host), the earlier record moves to an `[[old_toolchain]]` table (same
keys) until the install's last step removes what it lists; `y uninstall` removes those too.

## Plan and confirmation

Both commands print the plan on stdout, then:

- `--dry-run`: exit 0 (wins over `--yes`).
- `--yes`/`-y`: `[y] proceeding (--yes)`, go.
- stdin is a terminal (`IsTerminal`): ask `Proceed? [y/N]` on stderr; `y`/`yes` proceeds,
  anything else or EOF prints `[y] aborted; nothing was changed`, exit 1.
- otherwise: `error: y install needs confirmation; rerun with --yes (or --dry-run to only see
  the plan)`, exit 2. Only the terminal decides, no `CI` sniffing.

Nothing changes before the answer.

## `y uninstall`

```
y uninstall [--keep-toolchain] [--yes] [--dry-run]
```

Plans, confirms, then in this order (entry points first, so a half-done uninstall never
leaves a command pointing at deleted files; `install/` last, since it holds the record):

1. **Launchers**: `cargo uninstall --root <cargo_root> cargo-ryo` if they come from this
   checkout; gone already: skipped; from elsewhere: kept, "not ours".
2. **Toolchain** (unless `--keep-toolchain`): what the manifest recorded. A toolchain ryo
   installed is uninstalled, unless it is rustup's default or `rustup override list` names it;
   otherwise the recorded components and targets are removed from the user's toolchain.
   Everything is kept while the launchers belong to another checkout, which may still use it.
   Kept items are listed with the reason.
3. **`install/`**: deleted entirely (there is no option to keep a cache).

Without a manifest (`install/` deleted by hand) it only offers to remove this checkout's
launchers and says it can't know what was added to rustup; with neither:
`[y] ryo is not installed in this checkout`, exit 0. Never touched: cargo's caches, `dist/`
and `target/`, projects' `target/` dirs, and any config selecting ryo.

## Windows

- `y.cmd`/`y.ps1` run `cargo run … -- %*`/`@args`; cargo inherits the console, so the prompt
  works in cmd, PowerShell and Windows Terminal. In Git Bash (mintty) stdin is a pipe, so it
  counts as no terminal and the error adds `(Git Bash: run from PowerShell or cmd, or pass
  --yes)`.
- No symlinks: `current` is a file, the launchers come from `cargo install`, and the launcher
  waits for the real wrapper instead of `exec`.
- A running `.exe`/`.dll` can't be deleted: a version dir that fails to delete is renamed to
  `*.old` and deleted on the next run. If `cargo install` can't replace a running launcher,
  `current` already names the new version, so the old launchers use it; rerun to update them.

## Not implemented yet

- `--toolchain-link` (a rustup toolchain `ryo` for `cargo +ryo`).
- `cargo ryo --ryo-version`.
- A build-id sidecar for the backend's incremental fingerprint (the copy's fresh mtime
  over-invalidates instead).
