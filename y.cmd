@echo off
cargo run --quiet --manifest-path "%~dp0build\Cargo.toml" -- %*
exit /b %ERRORLEVEL%
