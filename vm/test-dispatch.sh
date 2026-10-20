#!/bin/sh
# Runs the `vm/` test suite under every VM dispatch strategy (design/vm.md, "Dispatch"):
# tail-call handlers (the default), `#[loop_match]` and the plain `match`. `y test` runs the
# same matrix. Extra arguments go to `cargo test` (e.g. `--release`).
set -eu
cd "$(dirname "$0")"
export RUSTC_BOOTSTRAP=1
for strategy in tail loop-match match; do
    echo "== dispatch: $strategy"
    if [ "$strategy" = tail ]; then
        cargo +stable test --workspace "$@"
    else
        cargo +stable test --workspace --features "ryo_rt/dispatch-$strategy" "$@"
    fi
done
