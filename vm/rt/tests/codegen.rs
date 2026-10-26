//! Codegen check of the handlers (design/vm.md, "Handlers"): builds `ryo_rt` as `y build`
//! does (release, `-Ccodegen-units=1`, `jit`, this test's `fp-rbp` feature) with `--emit=asm`, and
//! checks that
//! - every opcode with a handler has its `ryo_h_<Opcode>` function;
//! - with `fp-rbp`, every handler written in Rust reads `rbp` (the VM function's fp) before
//!   any instruction that writes `rbp`, so it sees the caller's (no frame pointer was set up;
//!   a handler may save `rbp` and use it as a register afterwards);
//! - the hot handlers have no prologue (no push, no stack adjustment) and make no call;
//! - built for Windows, no handler but the four whose operations the lowering avoids on PE
//!   writes `xmm6`–`xmm15`, which Win64 callers of VM functions expect preserved and the
//!   `sysv64` handlers needn't (design/platforms.md).
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
    // An identical function merged into another is an alias, `name = other` (the `.ptr`
    // atomics and their `.w64` twins).
    let alias = asm.lines().find_map(|l| {
        let (name, to) = l.split_once(" = ")?;
        (name.ends_with(suffix) && !l.starts_with(char::is_whitespace)).then(|| to.trim())
    });
    if let Some(to) = alias {
        return asm_of(asm, to);
    }
    let start = asm.lines().position(|l| l.ends_with(&format!("{suffix}:")) && !l.starts_with('.'))?;
    let mut out = Vec::new();
    for l in asm.lines().skip(start + 1) {
        let t = l.trim();
        // The end, or the next function's label (COFF assembly has no `.cfi_endproc`).
        let next_fn = !l.starts_with(char::is_whitespace) && t.ends_with(':') && !t.starts_with('.');
        if t.starts_with(".Lfunc_end") || t == ".cfi_endproc" || t == ".seh_endproc" || next_fn {
            break;
        }
        if t.is_empty() || t.starts_with('.') || t.starts_with('#') || t.ends_with(':') {
            continue;
        }
        out.push(t);
    }
    Some(out)
}

/// `ryo_rt` built as `y build` does, as assembly, into `dir` under the test's target
/// directory: for the host, or `target`.
fn rt_asm(dir: &str, features: &[&str], target: Option<&str>) -> String {
    let dir = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join(dir);
    let manifest = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("Cargo.toml");
    let mut c = Command::new(env!("CARGO"));
    c.env("RUSTC_BOOTSTRAP", "1")
        .env_remove("RUSTFLAGS")
        .env_remove("CARGO_ENCODED_RUSTFLAGS")
        .args(["rustc", "--release", "--lib", "--manifest-path"])
        .arg(&manifest)
        .arg("--target-dir")
        .arg(&dir);
    // With the JIT, whose interface references the register entries.
    c.args(["--features", "jit"]);
    for f in features {
        c.args(["--features", f]);
    }
    if let Some(t) = target {
        c.args(["--target", t]);
    }
    c.args(["--", "-Ccodegen-units=1", "--emit=asm"]);
    // As `y build` builds it for Windows (design/platforms.md).
    if target.is_some_and(|t| t.contains("-windows")) {
        c.arg("-Cno-redzone=yes");
    }
    let st = c.status().expect("running cargo");
    assert!(st.success(), "building ryo_rt failed");
    let deps = match target {
        Some(t) => dir.join(t).join("release").join("deps"),
        None => dir.join("release").join("deps"),
    };
    let s = std::fs::read_dir(&deps)
        .unwrap()
        .map(|e| e.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "s") && p.file_name().unwrap().to_str().unwrap().starts_with("ryo_rt-"))
        .max_by_key(|p| p.metadata().unwrap().modified().unwrap())
        .expect("no ryo_rt .s");
    std::fs::read_to_string(s).unwrap()
}

#[test]
fn win64_handlers_preserve_xmm6_to_15() {
    const TARGET: &str = "x86_64-pc-windows-msvc";
    let installed = Command::new("rustc").args(["--print", "target-libdir", "--target", TARGET]).output();
    if !installed.is_ok_and(|o| o.status.success() && std::path::Path::new(String::from_utf8_lossy(&o.stdout).trim()).exists()) {
        eprintln!("skipped: no {TARGET} standard library");
        return;
    }
    let asm = rt_asm("codegen-win64", &[], Some(TARGET));
    // Their `i128` result stays in `xmm6` across a call; the lowering uses an island on PE.
    let avoided = [Opcode::CvtF2iSatSF32W128, Opcode::CvtF2iSatUF32W128, Opcode::CvtF2iSatSF64W128, Opcode::CvtF2iSatUF64W128];
    let mut checked = 0;
    for &op in ALL_OPCODES {
        if !has_handler(op) || avoided.contains(&op) {
            continue;
        }
        // The register entries too (the JIT doesn't run on PE yet, but they are built).
        let reg = ryo_bytecode::jit::effects::reg_entry(op, ryo_rt::vm::MODE).is_some();
        for name in [format!("ryo_h_{op:?}"), hr_name(op)].into_iter().take(1 + reg as usize) {
            // A register entry identical to another may be merged into it, without a name.
            let Some(a) = asm_of(&asm, &name).or_else(|| (!name.starts_with("ryo_h_")).then(Vec::new)) else { panic!("{name}: not in the assembly") };
            // AT&T syntax: the destination is the last operand.
            let bad = a.iter().find(|i| (6..16).any(|x| i.ends_with(&format!("%xmm{x}")) || i.ends_with(&format!("%ymm{x}"))));
            assert!(bad.is_none(), "{name}: writes {:?}\n{}", bad, a.join("\n"));
        }
        checked += 1;
    }
    assert!(checked > 800, "{checked}");
}

#[test]
fn handlers_read_rbp_first_and_hot_ones_have_no_prologue() {
    let fp_rbp = !ryo_rt::vm::FP_ARG;
    let asm = rt_asm(if fp_rbp { "codegen-fp-rbp" } else { "codegen" }, if fp_rbp { &["fp-rbp"] } else { &[] }, None);

    // Written in assembly: they use `rbp` and the stack by design.
    let naked = [Opcode::Resume];
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
        // A handler that never returns (`abort`) needn't read it.
        if let Some(r) = read {
            assert!(writes.is_none_or(|w| w > r), "{name}: writes rbp before reading it\n{}", dump());
        } else {
            assert!(op == Opcode::Abort, "{name}: doesn't read rbp\n{}", dump());
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

    // The register entries: none touches the stack (their buffer of frame operands is kept
    // in registers) but those that call or need a frame anyway. One identical to another may
    // be merged into it, without a name of its own.
    let mut checked = 0;
    for &op in ALL_OPCODES {
        if ryo_bytecode::jit::effects::reg_entry(op, ryo_rt::vm::MODE).is_none() {
            continue;
        }
        let name = hr_name(op);
        let Some(a) = asm_of(&asm, &name) else { continue };
        let frame = a.iter().any(|i| i.starts_with("push") || i.starts_with("call") || i.starts_with("jmp\t") && !i.contains(".LBB"));
        if !frame {
            // (`lock or [rsp - 64], 0` is a fence.)
            let bad = a.iter().find(|i| (i.contains("(%rsp)") && !i.starts_with("lock")) || (i.starts_with("sub") && i.ends_with("%rsp")));
            assert!(bad.is_none(), "{name}: keeps its operands on the stack\n{}", a.join("\n"));
        }
        checked += 1;
    }
    assert!(checked > 300, "{checked}");
    for op in [Opcode::AddOvfUW64, Opcode::SubOvfUW32, Opcode::ZextW32W64, Opcode::AddImmW32, Opcode::LoadW64, Opcode::StoreW64, Opcode::BrLtSW64] {
        let Some(a) = asm_of(&asm, &hr_name(op)) else { continue };
        assert!(a.len() <= 5, "{op:?}: register entry of {} instructions\n{}", a.len(), a.join("\n"));
    }
}

/// The symbol suffix of `op`'s register entry, which has no symbol of its own: `hr::<Opcode>`
/// mangled (v0).
fn hr_name(op: Opcode) -> String {
    let n = format!("{op:?}");
    format!("2hr{}{n}", n.len())
}
