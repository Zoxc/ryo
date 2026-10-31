@echo off
cargo run --quiet --manifest-path "%~dp0build\Cargo.toml" --target-dir "%~dp0out\y" -- %*
exit /b %ERRORLEVEL%
