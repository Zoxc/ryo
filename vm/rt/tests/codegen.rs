//! Codegen check of the tail-call dispatch (design/vm.md, "Dispatch"): builds `ryo_rt` as
//! `y build` does (release, `-Ccodegen-units=1`, default features) with
//! `--emit=llvm-ir,asm`, and checks that
//! - every handler is a `preserve_nonecc` function, one per opcode plus the invalid-opcode one;
//! - every call between handlers is a `musttail call preserve_nonecc` followed by `ret`, and
//!   the only other call of a handler is `run`'s entry call;
//! - no handler saves a register only the C ABI preserves (`rbx`, `r12`–`r15`); a handler
//!   sets up a frame only if it makes a native call or uses `rbp` (which `preserve_none`
//!   preserves on x86_64); the hot handlers have no prologue at all;
//! - handlers dispatch with an indirect `jmp`.
//!
//! It builds into its own target directory, so it doesn't contend with the running `cargo
//! test`. It runs once, under the default (tail-call) strategy; the other strategies skip it.

#![cfg(target_arch = "x86_64")]

use std::collections::BTreeMap;
use std::path::PathBuf;
use std::process::Command;

/// The handler functions in the IR: name → body lines.
fn handlers(ir: &str) -> BTreeMap<String, Vec<&str>> {
    let mut out = BTreeMap::new();
    let mut cur: Option<(String, Vec<&str>)> = None;
    for line in ir.lines() {
        if line.starts_with("define ") {
            if line.contains(" preserve_nonecc ") {
                let name = line.split('@').nth(1).unwrap().split('(').next().unwrap().to_owned();
                cur = Some((name, Vec::new()));
            }
        } else if line == "}" {
            if let Some((n, body)) = cur.take() {
                out.insert(n, body);
            }
        } else if let Some((_, body)) = &mut cur {
            body.push(line);
        }
    }
    out
}

/// The assembly of function `name`: its instructions, without labels and directives.
fn asm_of<'a>(asm: &'a str, name: &str) -> Vec<&'a str> {
    let start = format!("{name}:");
    let mut lines = asm.lines().skip_while(|l| *l != start).skip(1);
    let mut out = Vec::new();
    for l in &mut lines {
        let t = l.trim();
        if t.starts_with(".Lfunc_end") || t == ".cfi_endproc" {
            break;
        }
        if t.is_empty() || t.starts_with('.') || t.starts_with('#') || t.ends_with(':') {
            continue;
        }
        out.push(t);
    }
    out
}

#[test]
fn tail_call_handlers_are_musttail_without_prologue_pushes() {
    if ryo_rt::vm::STRATEGY != "tail" {
        eprintln!("skipped: dispatch strategy is {}", ryo_rt::vm::STRATEGY);
        return;
    }
    let dir = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("codegen");
    let manifest = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("Cargo.toml");
    let st = Command::new(env!("CARGO"))
        .env("RUSTC_BOOTSTRAP", "1")
        .env_remove("RUSTFLAGS")
        .env_remove("CARGO_ENCODED_RUSTFLAGS")
        .args(["rustc", "--release", "--lib", "--manifest-path"])
        .arg(&manifest)
        .arg("--target-dir")
        .arg(&dir)
        .args(["--", "-Ccodegen-units=1", "--emit=llvm-ir,asm"])
        .status()
        .expect("running cargo");
    assert!(st.success(), "building ryo_rt failed");
    let deps = dir.join("release").join("deps");
    let newest = |ext: &str| {
        std::fs::read_dir(&deps)
            .unwrap()
            .map(|e| e.unwrap().path())
            .filter(|p| {
                p.extension().is_some_and(|e| e == ext)
                    && p.file_name().unwrap().to_str().unwrap().starts_with("ryo_rt-")
            })
            .max_by_key(|p| p.metadata().unwrap().modified().unwrap())
            .unwrap_or_else(|| panic!("no ryo_rt .{ext} in {}", deps.display()))
    };
    let ir = std::fs::read_to_string(newest("ll")).unwrap();
    let asm = std::fs::read_to_string(newest("s")).unwrap();

    let hs = handlers(&ir);
    assert_eq!(hs.len(), ryo_bytecode::Opcode::COUNT + 1, "one handler per opcode, plus invalid_handler");
    let mut tail_calls = 0;
    let mut no_prologue = 0;
    for (name, body) in &hs {
        for (i, l) in body.iter().enumerate() {
            if l.contains("call preserve_nonecc") {
                assert!(l.contains("musttail call preserve_nonecc"), "{name}: non-tail handler call: {l}");
                assert!(body[i + 1].trim_start().starts_with("ret "), "{name}: musttail not followed by ret");
                tail_calls += 1;
            }
        }
        let a = asm_of(&asm, name);
        let dump = || a.join("\n");
        assert!(!a.is_empty(), "{name}: not found in the assembly");
        for ins in &a {
            let saves = ins.starts_with("push") && C_SAVED.iter().any(|r| ins.ends_with(r));
            assert!(!saves, "{name}: saves a register preserve_none doesn't preserve: {ins}\n{}", dump());
        }
        let prologue: Vec<&str> = a.iter().copied().take_while(|i| is_frame_setup(i)).collect();
        let calls = a.iter().any(|i| i.starts_with("call"));
        let uses_rbp = prologue.contains(&"pushq\t%rbp");
        assert!(
            prologue.is_empty() || calls || uses_rbp,
            "{name}: frame setup without a call or a saved rbp: {prologue:?}\n{}",
            dump()
        );
        if prologue.is_empty() {
            no_prologue += 1;
        }
        if body.iter().any(|l| l.contains("musttail")) {
            assert!(a.iter().any(|i| i.starts_with("jmpq\t*")), "{name}: no indirect jump\n{}", dump());
        }
    }
    // The hot handlers: no frame setup and no calls at all.
    for op in ["AddW32", "AddImmW64", "LoadW64", "StoreW64", "BrCmpLtSW64", "Jmp", "MovW64", "AddImmW64BrCmpLtUW64"] {
        let suffix = format!("{}{op}", op.len());
        let name = hs.keys().find(|k| k.ends_with(&suffix)).expect(op);
        let a = asm_of(&asm, name);
        assert!(!is_frame_setup(a[0]), "{op}: has a prologue\n{}", a.join("\n"));
        assert!(!a.iter().any(|i| i.starts_with("call")), "{op}: makes a call\n{}", a.join("\n"));
    }
    // Every handler but the ones that never continue (`unreachable`, `abort`, the invalid
    // handler) dispatches by tail call.
    assert!(tail_calls >= ryo_bytecode::Opcode::COUNT - 2, "{tail_calls} tail calls");
    // The only non-tail call to a handler is `run`'s.
    let plain_calls = ir.lines().filter(|l| l.contains("call preserve_nonecc") && !l.contains("musttail")).count();
    assert_eq!(plain_calls, 1, "calls into the handler chain other than run's");

    let add = hs.keys().find(|k| k.ends_with("6AddW32")).expect("AddW32 handler");
    eprintln!("{no_prologue} of {} handlers have no prologue; AddW32:\n  {}", hs.len(), asm_of(&asm, add).join("\n  "));
}

/// Registers the C ABI preserves but `preserve_none` doesn't. On x86_64 `preserve_none` still
/// preserves `rsp` and `rbp`, so a handler that keeps a value in `rbp` (across a native call,
/// or under register pressure) saves it; that is allowed.
const C_SAVED: [&str; 5] = ["%rbx", "%r12", "%r13", "%r14", "%r15"];

/// A prologue instruction: a push, or a stack pointer adjustment.
fn is_frame_setup(ins: &str) -> bool {
    ins.starts_with("push") || (ins.starts_with("sub") && ins.ends_with("%rsp"))
}
