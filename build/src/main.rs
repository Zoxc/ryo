//! `y`: ryo's build tool (design/build.md#the-y-build-tool).

mod bench;
mod clif;
mod dist;
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
  build [--sysroot llvm|ryo]   build the backend, the sysroot and the wrappers into dist/
  build-clif                   build cg_clif from the toolchain's rustc-dev sources
  test [--clif]                build the test corpus with rustc-ryo and plain rustc, diff outputs
  bench [--runs N]             compare LLVM -O0/-O3, Cranelift and ryo: compile and run time
  clean                        remove dist/ and target/
";

#[derive(Debug, PartialEq)]
enum Sysroot {
    Llvm,
    Ryo,
}

#[derive(Debug, PartialEq)]
enum Cmd {
    Build { sysroot: Sysroot },
    BuildClif,
    Test { clif: bool },
    Bench { runs: u32 },
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
            let sysroot = match rest.as_slice() {
                [] | ["--sysroot", "llvm"] | ["--sysroot=llvm"] => Sysroot::Llvm,
                ["--sysroot", "ryo"] | ["--sysroot=ryo"] => Sysroot::Ryo,
                ["--sysroot", other] => return Err(format!("unknown sysroot `{other}`")),
                [arg, ..] => return Err(format!("unexpected argument `{arg}`")),
            };
            Ok(Cmd::Build { sysroot })
        }
        "build-clif" => no_args(Cmd::BuildClif),
        "test" => match rest.as_slice() {
            [] => Ok(Cmd::Test { clif: false }),
            ["--clif"] => Ok(Cmd::Test { clif: true }),
            [arg, ..] => Err(format!("unexpected argument `{arg}`")),
        },
        "bench" => match rest.as_slice() {
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
    let args: Vec<String> = std::env::args().skip(1).collect();
    let cmd = match parse_args(&args) {
        Ok(cmd) => cmd,
        Err(msg) => {
            eprintln!("error: {msg}\n\n{USAGE}");
            return ExitCode::FAILURE;
        }
    };
    let result = match cmd {
        Cmd::Help => {
            print!("{USAGE}");
            Ok(())
        }
        Cmd::Build { sysroot: Sysroot::Llvm } => dist::build(),
        Cmd::Build { sysroot: Sysroot::Ryo } => {
            Err("`build --sysroot ryo` is not implemented yet".to_owned())
        }
        Cmd::BuildClif => clif::build(),
        Cmd::Test { clif } => test::run(clif),
        Cmd::Bench { runs } => bench::run(runs),
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
        assert_eq!(parse(&["build"]), Ok(Cmd::Build { sysroot: Sysroot::Llvm }));
        assert_eq!(parse(&["build", "--sysroot", "llvm"]), Ok(Cmd::Build { sysroot: Sysroot::Llvm }));
        assert_eq!(parse(&["build", "--sysroot=ryo"]), Ok(Cmd::Build { sysroot: Sysroot::Ryo }));
        assert!(parse(&["build", "--sysroot", "gcc"]).is_err());
        assert!(parse(&["build", "x"]).is_err());
        assert_eq!(parse(&["test", "--clif"]), Ok(Cmd::Test { clif: true }));
        assert_eq!(parse(&["bench"]), Ok(Cmd::Bench { runs: bench::DEFAULT_RUNS }));
        assert_eq!(parse(&["bench", "--runs", "3"]), Ok(Cmd::Bench { runs: 3 }));
        assert!(parse(&["bench", "--runs", "0"]).is_err());
        assert_eq!(parse(&["clean"]), Ok(Cmd::Clean));
        assert!(parse(&["clean", "x"]).is_err());
        assert!(parse(&["frobnicate"]).is_err());
    }
}
