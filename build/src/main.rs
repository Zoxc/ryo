//! `y`: ryo's build tool (design/build.md#the-y-build-tool).

mod bench;
mod clif;
mod crates;
mod cross;
mod dist;
mod jit;
mod lean;
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
  test [--clif] [--full | --only jit|backend|lean|std|rt | --no-changed]
       [--program NAME]... [--variant NAME]...
                               the fast suite plus the tests the changed paths select
                               (design/build.md#fast-suite-and-changed-path-selection);
                               `--full` runs everything and needs the ryo sysroot;
                               `--program`/`--variant` run only those corpus entries;
                               `--no-changed` only the fixed fast set
  test --cross T               cross-build and link (not run) the corpus for target T, e.g.
                               x86_64-pc-windows-msvc or x86_64-apple-darwin; needs
                               `build --target T` first
  bench [--runs N] [--llvm O0,O2d,..] [--clif] [--ryo aot,jit] [--metric time|cachegrind]
                               compare LLVM -O0/-O3, Cranelift and ryo: compile and run time
                               (or, with cachegrind, run instructions and est. cycles); the options
                               pick the columns (`d`: debug assertions)
  bench codegen                dump ryo's code for each bench program to bench/codegen/
  lean [gen | --proofs]        check the generated Lean tables, then `lake build` and
                               `lake test` in lean/; `gen` regenerates the tables;
                               `--proofs` also builds the slow proofs (`RyoProofs`)
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
    Build {
        sysroot: Sysroot,
        targets: Vec<String>,
    },
    BuildClif,
    Test(test::Options),
    /// `test --cross <target>`.
    CrossTest {
        target: String,
    },
    Bench(bench::Options),
    BenchCodegen,
    BenchCrates(crates::Options),
    Lean(LeanMode),
    Clean,
    Help,
}

/// What `y lean` does.
#[derive(Debug, PartialEq)]
enum LeanMode {
    /// `lean`: check the generated tables, then `lake build` and `lake test`.
    Check,
    /// `lean --proofs`: `Check`, plus the slow proofs.
    Proofs,
    /// `lean gen`: regenerate the tables.
    Generate,
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
            let mut args = crate::utils::Flags::new(&rest);
            while let Some(flag) = args.next()? {
                match flag {
                    "--sysroot" => {
                        sysroot = match args.value()? {
                            "llvm" => Sysroot::Llvm,
                            "ryo" => Sysroot::Ryo,
                            other => return Err(format!("unknown sysroot `{other}`")),
                        }
                    }
                    "--target" => targets.push(args.value()?.to_owned()),
                    _ => return Err(args.unexpected()),
                }
            }
            Ok(Cmd::Build { sysroot, targets })
        }
        "build-clif" => no_args(Cmd::BuildClif),
        "test" => parse_test(&rest),
        "bench" => match rest.as_slice() {
            ["codegen"] => Ok(Cmd::BenchCodegen),
            ["crates", opts @ ..] => crates::parse_options(opts).map(Cmd::BenchCrates),
            opts => bench::parse_options(opts).map(Cmd::Bench),
        },
        "lean" => match rest.as_slice() {
            [] => Ok(Cmd::Lean(LeanMode::Check)),
            ["gen"] => Ok(Cmd::Lean(LeanMode::Generate)),
            ["--proofs"] => Ok(Cmd::Lean(LeanMode::Proofs)),
            [arg, ..] => Err(format!("unexpected argument `{arg}`")),
        },
        "clean" => no_args(Cmd::Clean),
        "help" | "-h" | "--help" => Ok(Cmd::Help),
        other => Err(format!("unknown command `{other}`")),
    }
}

fn parse_test(rest: &[&str]) -> Result<Cmd, String> {
    let mut opts = test::Options::default();
    let mut cross = None;
    let mut args = crate::utils::Flags::new(rest);
    while let Some(flag) = args.next()? {
        match flag {
            "--cross" => cross = Some(args.value()?.to_owned()),
            "--clif" => opts.clif = true,
            "--full" => opts.full = true,
            "--no-changed" => opts.no_changed = true,
            "--only" => opts.only = Some(test::Area::parse(args.value()?)?),
            "--program" => opts.programs.push(args.value()?.to_owned()),
            "--variant" => opts.variants.push(args.value()?.to_owned()),
            _ => return Err(args.unexpected()),
        }
    }
    if let Some(target) = cross {
        if opts != test::Options::default() {
            return Err("`--cross` takes no other `test` flags".to_owned());
        }
        return Ok(Cmd::CrossTest { target });
    }
    let modes = [opts.full, opts.only.is_some(), opts.no_changed, !opts.programs.is_empty() || !opts.variants.is_empty()];
    if modes.iter().filter(|m| **m).count() > 1 {
        return Err("`--full`, `--only`, `--no-changed` and `--program`/`--variant` exclude each other".to_owned());
    }
    Ok(Cmd::Test(opts))
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
        Cmd::Test(opts) => test::run(&opts),
        Cmd::CrossTest { target } => cross::run(&target),
        Cmd::Bench(opts) => bench::run(&opts),
        Cmd::BenchCodegen => bench::codegen(),
        Cmd::BenchCrates(opts) => crates::run(opts),
        Cmd::Lean(LeanMode::Check) => lean::check(false),
        Cmd::Lean(LeanMode::Proofs) => lean::check(true),
        Cmd::Lean(LeanMode::Generate) => lean::generate(),
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
        let build = |sysroot, targets: &[&str]| Ok(Cmd::Build { sysroot, targets: targets.iter().map(|t| t.to_string()).collect() });
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
        assert_eq!(parse(&["test", "--clif"]), Ok(Cmd::Test(test::Options { clif: true, ..Default::default() })));
        assert_eq!(parse(&["test"]), Ok(Cmd::Test(test::Options::default())));
        assert_eq!(parse(&["test", "--full"]), Ok(Cmd::Test(test::Options { full: true, ..Default::default() })));
        assert_eq!(parse(&["test", "--only=jit"]), Ok(Cmd::Test(test::Options { only: Some(test::Area::Jit), ..Default::default() })));
        assert_eq!(
            parse(&["test", "--program", "hello", "--variant=ryo"]),
            Ok(Cmd::Test(test::Options { programs: vec!["hello".into()], variants: vec!["ryo".into()], ..Default::default() }))
        );
        assert!(parse(&["test", "--only", "x"]).is_err());
        assert!(parse(&["test", "--full", "--no-changed"]).is_err());
        assert!(parse(&["test", "--clif=x"]).is_err());
        assert!(parse(&["test", "--cross", "a", "--full"]).is_err());
        let cross = || Ok(Cmd::CrossTest { target: "x86_64-pc-windows-msvc".into() });
        assert_eq!(parse(&["test", "--cross", "x86_64-pc-windows-msvc"]), cross());
        assert_eq!(parse(&["test", "--cross=x86_64-pc-windows-msvc"]), cross());
        assert_eq!(parse(&["bench"]), Ok(Cmd::Bench(bench::Options::default())));
        assert_eq!(parse(&["bench", "--runs", "3"]), Ok(Cmd::Bench(bench::Options { runs: 3, ..Default::default() })));
        assert!(parse(&["bench", "--runs", "0"]).is_err());
        assert_eq!(parse(&["bench", "codegen"]), Ok(Cmd::BenchCodegen));
        assert!(matches!(parse(&["bench", "crates", "--quick"]), Ok(Cmd::BenchCrates(o)) if o.run_samples == 1));
        assert!(parse(&["bench", "crates", "--frob"]).is_err());
        assert_eq!(parse(&["lean"]), Ok(Cmd::Lean(LeanMode::Check)));
        assert_eq!(parse(&["lean", "gen"]), Ok(Cmd::Lean(LeanMode::Generate)));
        assert_eq!(parse(&["lean", "--proofs"]), Ok(Cmd::Lean(LeanMode::Proofs)));
        assert!(parse(&["lean", "x"]).is_err());
        assert_eq!(parse(&["clean"]), Ok(Cmd::Clean));
        assert!(parse(&["clean", "x"]).is_err());
        assert!(parse(&["frobnicate"]).is_err());
    }
}
