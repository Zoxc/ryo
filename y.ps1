#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
& cargo run --quiet --manifest-path "$PSScriptRoot/build/Cargo.toml" --target-dir "$PSScriptRoot/out/y" -- @args
exit $LASTEXITCODE
