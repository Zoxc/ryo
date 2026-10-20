#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
& cargo run --quiet --manifest-path "$PSScriptRoot/build/Cargo.toml" -- @args
exit $LASTEXITCODE
