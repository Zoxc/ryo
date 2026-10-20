#!/usr/bin/env bash
set -e
exec cargo run --quiet --manifest-path "$(dirname "$0")/build/Cargo.toml" -- "$@"
