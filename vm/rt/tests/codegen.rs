//! Codegen check of the handlers (design/vm.md, "Handlers"): builds `ryo_rt` as `y build`
//! does (release, `-Ccodegen-units=1`, this test's `fp-rbp` feature) with `--emit=asm`, and
//! checks that
//! - every opcode with a handler has its `ryo_h_<Opcode>` function;
//! - with `fp-rbp`, every handler written in Rust reads `rbp` (the VM function's fp) before
//!   any instruction that writes `rbp`, so it sees the caller's (no frame pointer was set up;
//!   a handler may save `rbp` and use it as a register afterwards);
//! - the hot handlers have no prologue (no push, no stack adjustment) and make no call.
//!
//! It builds into its own target directory, so it doesn't contend with the running `cargo
//! test`.

#![cfg(target_arch = "x86_64")]

use std::path::PathBuf;
use std::process::Command;

use ryo_bytecode::asm::has_handler;
use ryo_bytecode::{ALL_OPCODES, Opcode};

/// The instructions of the function whose (mangled) name ends with `suffix`, without labels
/// and directives.
fn asm_of<'a>(asm: &'a str, suffix: &str) -> Option<Vec<&'a str>> {
    let start = asm.lines().position(|l| l.ends_with(&format!("{suffix}:")) && !l.starts_with('.'))?;
    let mut out = Vec::new();
    for l in asm.lines().skip(start + 1) {
        let t = l.trim();
        if t.starts_with(".Lfunc_end") || t == ".cfi_endproc" {
            break;
        }
        if t.is_empty() || t.starts_with('.') || t.starts_with('#') || t.ends_with(':') {
            continue;
        }
        out.push(t);
    }
    Some(out)
}

#[test]
fn handlers_read_rbp_first_and_hot_ones_have_no_prologue() {
    let fp_rbp = !ryo_rt::vm::FP_ARG;
    let dir = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join(if fp_rbp { "codegen-fp-rbp" } else { "codegen" });
    let manifest = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("Cargo.toml");
    let st = Command::new(env!("CARGO"))
        .env("RUSTC_BOOTSTRAP", "1")
        .env_remove("RUSTFLAGS")
        .env_remove("CARGO_ENCODED_RUSTFLAGS")
        .args(["rustc", "--release", "--lib", "--manifest-path"])
        .arg(&manifest)
        .arg("--target-dir")
        .arg(&dir)
        .args(if fp_rbp { &["--features", "fp-rbp"][..] } else { &[] })
        .args(["--", "-Ccodegen-units=1", "--emit=asm"])
        .status()
        .expect("running cargo");
    assert!(st.success(), "building ryo_rt failed");
    let deps = dir.join("release").join("deps");
    let s = std::fs::read_dir(&deps)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "s") && p.file_name().unwrap().to_str().unwrap().starts_with("ryo_rt-"))
        .max_by_key(|p| p.metadata().unwrap().modified().unwrap())
        .expect("no ryo_rt .s");
    let asm = std::fs::read_to_string(s).unwrap();

    // Written in assembly: they use `rbp` and the stack by design.
    let naked = [Opcode::TailCall, Opcode::TailCallInd, Opcode::Resume];
    let mut checked = 0;
    for &op in ALL_OPCODES {
        if !has_handler(op) {
            continue;
        }
        let name = format!("ryo_h_{op:?}");
        let a = asm_of(&asm, &name).unwrap_or_else(|| panic!("{name}: not in the assembly"));
        if naked.contains(&op) {
            continue;
        }
        if !fp_rbp {
            checked += 1;
            continue;
        }
        let dump = || a.join("\n");
        let read = a.iter().position(|i| i.starts_with("movq\t%rbp, %"));
        // AT&T syntax: the destination is the last operand.
        let writes = a.iter().position(|i| i.ends_with("%rbp") && !i.starts_with("push") && !i.starts_with("cmp") && !i.starts_with("test"));
        // Handlers that never return (`unreachable`, `abort`) needn't read it.
        if let Some(r) = read {
            assert!(writes.is_none_or(|w| w > r), "{name}: writes rbp before reading it\n{}", dump());
        } else {
            assert!(matches!(op, Opcode::Unreachable | Opcode::Abort), "{name}: doesn't read rbp\n{}", dump());
        }
        checked += 1;
    }
    assert!(checked > 800, "{checked}");
    for op in [
        Opcode::AddW32,
        Opcode::AddImmW64,
        Opcode::LoadW64,
        Opcode::StoreW64,
        Opcode::MovW64,
        Opcode::ImmW64,
        Opcode::BrLtSW64,
        Opcode::BrLtUImmW64,
        Opcode::Br,
        Opcode::EqW32,
        Opcode::PtrIndex,
        Opcode::Addr,
    ] {
        let a = asm_of(&asm, &format!("ryo_h_{op:?}")).unwrap();
        let bad = a.iter().find(|i| i.starts_with("push") || (i.starts_with("sub") && i.ends_with("%rsp")) || i.starts_with("call"));
        assert!(bad.is_none(), "{op:?}: has a prologue or a call\n{}", a.join("\n"));
    }
    eprintln!("AddW32:\n  {}", asm_of(&asm, "ryo_h_AddW32").unwrap().join("\n  "));
}
