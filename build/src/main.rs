//! `y`: ryo's build tool (design/build.md#the-y-build-tool).

mod bench;
mod clif;
mod crates;
mod cross;
mod dist;
mod sysroot;
mod test;
mod utils;

#[cfg(test)]
#[path = "../../scripts/rustc-ryo.rs"]
mod rustc_ryo;

#[cfg(test)]
#[path = "../../scripts/rustc-clif.rs"]
mod rustc_clif;

use std::process::ExitCode;

const USAGE: &str = "\
usage: ./y.sh <command>

commands:
  build [--sysroot llvm|ryo] [--target T]...
                               build the backend, the sysroot and the wrappers into dist/;
                               also install std and ryo_rt for each target T
  build-clif                   build cg_clif from the toolchain's rustc-dev sources
  test [--clif]                build the test corpus with rustc-ryo and plain rustc, diff outputs
  test --cross T               cross-build and link (not run) the corpus for target T, e.g.
                               x86_64-pc-windows-msvc; needs `build --target T` first
  bench [--runs N]             compare LLVM -O0/-O3, Cranelift and ryo: compile and run time
  bench codegen                dump ryo's code for each bench program to bench/codegen/
{CRATES}
  clean                        remove dist/ and target/
";

fn usage() -> String {
    USAGE.replace("{CRATES}", crates::USAGE)
}

#[derive(Debug, PartialEq)]
enum Sysroot {
    Llvm,
    Ryo,
}

#[derive(Debug, PartialEq)]
enum Cmd {
    /// `targets`: extra targets (besides the host) to install std and `ryo_rt` for.
    Build { sysroot: Sysroot, targets: Vec<String> },
    BuildClif,
    Test { clif: bool },
    /// `test --cross <target>`.
    CrossTest { target: String },
    Bench { runs: u32 },
    BenchCodegen,
    BenchCrates(crates::Options),
    Clean,
    Help,
}

fn parse_args(args: &[String]) -> Result<Cmd, String> {
    let Some((cmd, rest)) = args.split_first() else {
        return Ok(Cmd::Help);
    };
    let rest: Vec<&str> = rest.iter().map(String::as_str).collect();
    let no_args = |cmd: Cmd| match rest.as_slice() {
        [] => Ok(cmd),
        [arg, ..] => Err(format!("unexpected argument `{arg}`")),
    };
    match cmd.as_str() {
        "build" => {
            let mut sysroot = Sysroot::Llvm;
            let mut targets = Vec::new();
            let mut args = rest.iter().copied();
            while let Some(arg) = args.next() {
                let (flag, value) = match arg.split_once('=') {
                    Some((f, v)) if f.starts_with("--") => (f, Some(v)),
                    _ => (arg, None),
                };
                let mut value = || value.or_else(|| args.next()).ok_or(format!("`{flag}` needs a value"));
                match flag {
                    "--sysroot" => {
                        sysroot = match value()? {
                            "llvm" => Sysroot::Llvm,
                            "ryo" => Sysroot::Ryo,
                            other => return Err(format!("unknown sysroot `{other}`")),
                        }
                    }
                    "--target" => targets.push(value()?.to_owned()),
                    _ => return Err(format!("unexpected argument `{arg}`")),
                }
            }
            Ok(Cmd::Build { sysroot, targets })
        }
        "build-clif" => no_args(Cmd::BuildClif),
        "test" => match rest.as_slice() {
            [] => Ok(Cmd::Test { clif: false }),
            ["--clif"] => Ok(Cmd::Test { clif: true }),
            ["--cross", t] => Ok(Cmd::CrossTest { target: t.to_string() }),
            [a] if a.starts_with("--cross=") => Ok(Cmd::CrossTest { target: a["--cross=".len()..].to_owned() }),
            [arg, ..] => Err(format!("unexpected argument `{arg}`")),
        },
        "bench" => match rest.as_slice() {
            ["codegen"] => Ok(Cmd::BenchCodegen),
            ["crates", opts @ ..] => crates::parse_options(opts).map(Cmd::BenchCrates),
            [] => Ok(Cmd::Bench { runs: bench::DEFAULT_RUNS }),
            ["--runs", n] => match n.parse() {
                Ok(runs) if runs > 0 => Ok(Cmd::Bench { runs }),
                _ => Err(format!("bad run count `{n}`")),
            },
            [arg, ..] => Err(format!("unexpected argument `{arg}`")),
        },
        "clean" => no_args(Cmd::Clean),
        "help" | "-h" | "--help" => Ok(Cmd::Help),
        other => Err(format!("unknown command `{other}`")),
    }
}

fn main() -> ExitCode {
    // `y` is the `RUSTC` of the ryo sysroot's cargo build.
    if let Some(rustc_ryo) = std::env::var_os(sysroot::SHIM_VAR) {
        return sysroot::shim(rustc_ryo);
    }
    // `y` is the `RUSTC_WRAPPER` of `y bench crates`.
    if let Some(log_dir) = std::env::var_os(crates::timing::WRAPPER_VAR) {
        return crates::timing::wrapper(log_dir);
    }
    let args: Vec<String> = std::env::args().skip(1).collect();
    let cmd = match parse_args(&args) {
        Ok(cmd) => cmd,
        Err(msg) => {
            eprintln!("error: {msg}\n\n{}", usage());
            return ExitCode::FAILURE;
        }
    };
    let result = match cmd {
        Cmd::Help => {
            print!("{}", usage());
            Ok(())
        }
        Cmd::Build { sysroot, targets } => dist::build(&targets, sysroot == Sysroot::Ryo),
        Cmd::BuildClif => clif::build(),
        Cmd::Test { clif } => test::run(clif),
        Cmd::CrossTest { target } => cross::run(&target),
        Cmd::Bench { runs } => bench::run(runs),
        Cmd::BenchCodegen => bench::codegen(),
        Cmd::BenchCrates(opts) => crates::run(opts),
        Cmd::Clean => dist::clean(),
    };
    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(msg) => {
            eprintln!("error: {msg}");
            ExitCode::FAILURE
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn parse(args: &[&str]) -> Result<Cmd, String> {
        parse_args(&args.iter().map(|s| s.to_string()).collect::<Vec<_>>())
    }

    #[test]
    fn commands() {
        assert_eq!(parse(&[]), Ok(Cmd::Help));
        let build = |sysroot, targets: &[&str]| {
            Ok(Cmd::Build { sysroot, targets: targets.iter().map(|t| t.to_string()).collect() })
        };
        assert_eq!(parse(&["build"]), build(Sysroot::Llvm, &[]));
        assert_eq!(parse(&["build", "--sysroot", "llvm"]), build(Sysroot::Llvm, &[]));
        assert_eq!(parse(&["build", "--sysroot=ryo"]), build(Sysroot::Ryo, &[]));
        assert_eq!(
            parse(&["build", "--target", "x86_64-pc-windows-msvc", "--sysroot=llvm", "--target=a"]),
            build(Sysroot::Llvm, &["x86_64-pc-windows-msvc", "a"])
        );
        assert!(parse(&["build", "--sysroot", "gcc"]).is_err());
        assert!(parse(&["build", "--target"]).is_err());
        assert!(parse(&["build", "x"]).is_err());
        assert_eq!(parse(&["test", "--clif"]), Ok(Cmd::Test { clif: true }));
        let cross = || Ok(Cmd::CrossTest { target: "x86_64-pc-windows-msvc".into() });
        assert_eq!(parse(&["test", "--cross", "x86_64-pc-windows-msvc"]), cross());
        assert_eq!(parse(&["test", "--cross=x86_64-pc-windows-msvc"]), cross());
        assert_eq!(parse(&["bench"]), Ok(Cmd::Bench { runs: bench::DEFAULT_RUNS }));
        assert_eq!(parse(&["bench", "--runs", "3"]), Ok(Cmd::Bench { runs: 3 }));
        assert!(parse(&["bench", "--runs", "0"]).is_err());
        assert_eq!(parse(&["bench", "codegen"]), Ok(Cmd::BenchCodegen));
        assert!(matches!(parse(&["bench", "crates", "--quick"]), Ok(Cmd::BenchCrates(o)) if o.run_samples == 1));
        assert!(parse(&["bench", "crates", "--frob"]).is_err());
        assert_eq!(parse(&["clean"]), Ok(Cmd::Clean));
        assert!(parse(&["clean", "x"]).is_err());
        assert!(parse(&["frobnicate"]).is_err());
    }
}
