//! Codegen check of the handlers (design/vm.md, "Handlers"): builds `ryo_rt` as `y build`
//! does (release, `-Ccodegen-units=1`) with `--emit=asm`, and checks that
//! - every opcode with a handler has its `ryo_h_<Opcode>` function, and off Apple its
//!   frame-pointer set's `ryo_hf_<Opcode>`;
//! - every handler of the frame-pointer set written in Rust reads `rbp` (the VM function's
//!   fp) before any instruction that writes `rbp`, so it sees the caller's (no frame pointer
//!   was set up; a handler may save `rbp` and use it as a register afterwards);
//! - the hot handlers of both sets have no prologue (no push, no stack adjustment) and make
//!   no call;
//! - built for Windows (Win64 handlers), every handler reads `rbp` first, saves any of
//!   `xmm6`–`xmm15` it writes, and the hot ones have no prologue (design/platforms.md).
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
    // The handlers' symbols carry the ABI tag (`ryo_h_<Op>_<tag>`).
    if !suffix.ends_with(ryo_bytecode::ABI_TAG)
        && let Some(a) = asm_of(asm, &format!("{suffix}_{}", ryo_bytecode::ABI_TAG))
    {
        return Some(a);
    }
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
fn rt_asm(dir: &str, target: Option<&str>) -> String {
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

/// Built for Windows, the handlers are Win64 functions (design/vm.md, "Handlers"): each
/// handler written in Rust reads `rbp`, its `fp`, before writing it; one that writes one of
/// `xmm6`–`xmm15` (callee-saved there) stores it first, and so do the register entries; the
/// hot handlers have no prologue and make no call.
#[test]
fn win64_handlers() {
    const TARGET: &str = "x86_64-pc-windows-msvc";
    let installed = Command::new("rustc").args(["--print", "target-libdir", "--target", TARGET]).output();
    if !installed.is_ok_and(|o| o.status.success() && std::path::Path::new(String::from_utf8_lossy(&o.stdout).trim()).exists()) {
        eprintln!("skipped: no {TARGET} standard library");
        return;
    }
    let asm = rt_asm("codegen-win64", Some(TARGET));
    let pe = ryo_bytecode::asm::Mode { fp_arg: false, frame_pointer: true, align_loops: false, pe: true, counters: false, far_rt: false };
    // AT&T syntax: the destination is the last operand.
    let xmm_kept = |name: &str, a: &[&str]| {
        for x in 6..16 {
            let reg = format!("%xmm{x}");
            let Some(w) = a.iter().position(|i| i.ends_with(&reg) || i.ends_with(&format!("%ymm{x}"))) else { continue };
            let saved = a[..w]
                .iter()
                .any(|i| (i.starts_with("movaps") || i.starts_with("movups")) && i.contains(&format!("{reg}, ")) && i.ends_with("(%rsp)"));
            assert!(saved, "{name}: writes {reg} without saving it\n{}", a.join("\n"));
        }
    };
    let mut checked = 0;
    for &op in ALL_OPCODES {
        if !has_handler(op) || op == Opcode::Resume {
            continue;
        }
        let name = format!("ryo_h_{op:?}");
        let a = asm_of(&asm, &name).unwrap_or_else(|| panic!("{name}: not in the assembly"));
        let read = a.iter().position(|i| i.starts_with("movq\t%rbp, %"));
        let writes = a.iter().position(|i| i.ends_with("%rbp") && !i.starts_with("push") && !i.starts_with("cmp") && !i.starts_with("test"));
        match read {
            Some(r) => assert!(writes.is_none_or(|w| w > r), "{name}: writes rbp before reading it\n{}", a.join("\n")),
            None => assert!(op == Opcode::Abort, "{name}: doesn't read rbp\n{}", a.join("\n")),
        }
        xmm_kept(&name, &a);
        // A register entry identical to another may be merged into it, without a name.
        if ryo_bytecode::jit::effects::reg_entry(op, pe).is_some()
            && let Some(a) = asm_of(&asm, &hr_name("hr", op))
        {
            xmm_kept(&hr_name("hr", op), &a);
        }
        checked += 1;
    }
    assert!(checked > 800, "{checked}");
    for op in [Opcode::AddW32, Opcode::AddImmW64, Opcode::LoadW64, Opcode::StoreW64, Opcode::MovW64, Opcode::BrLtSW64, Opcode::Br, Opcode::EqW32] {
        let a = asm_of(&asm, &format!("ryo_h_{op:?}")).unwrap();
        let bad = a.iter().find(|i| i.starts_with("push") || (i.starts_with("sub") && i.ends_with("%rsp")) || i.starts_with("call"));
        assert!(bad.is_none(), "{op:?}: has a prologue or a call\n{}", a.join("\n"));
    }
    short_reg_entries(&asm, "hr", |a| a, pe);
    eprintln!("AddW32 (Win64):\n  {}", asm_of(&asm, "ryo_h_AddW32").unwrap().join("\n  "));
}

/// The hot register entries that return two values are short: on Win64 (`pe`) they come back
/// in `xmm0` (`ryo_rt::vm::RegRet`'s PE form, three instructions instead of `mov rdx`).
/// `strip` drops what the target adds to every function.
fn short_reg_entries<'a>(asm: &'a str, hr: &str, strip: impl Fn(Vec<&'a str>) -> Vec<&'a str>, mode: ryo_bytecode::asm::Mode) {
    for op in [Opcode::AddOvfUW64, Opcode::SubOvfUW32, Opcode::ZextW32W64, Opcode::AddImmW32, Opcode::LoadW64, Opcode::StoreW64, Opcode::BrLtSW64] {
        if ryo_bytecode::jit::effects::reg_entry(op, mode).is_none() {
            continue;
        }
        let Some(a) = asm_of(asm, &hr_name(hr, op)) else { continue };
        let a = strip(a);
        let limit = if mode.pe { 7 } else { 5 };
        assert!(a.len() <= limit, "{op:?}: register entry of {} instructions\n{}", a.len(), a.join("\n"));
    }
}

/// `a` without the frame pointer's prologue and epilogue, which Apple's targets put in every
/// function (`frame-pointer=all`; `-Cforce-frame-pointers` can't lower it).
fn strip_apple_fp(a: Vec<&str>) -> Vec<&str> {
    if !cfg!(target_vendor = "apple") {
        return a;
    }
    a.into_iter().filter(|i| !matches!(*i, "pushq\t%rbp" | "movq\t%rsp, %rbp" | "popq\t%rbp")).collect()
}

/// `a` reads `rbp` before writing it: a handler that reads `fp` from there.
fn reads_rbp_first(name: &str, op: Opcode, a: &[&str]) {
    let read = a.iter().position(|i| i.starts_with("movq\t%rbp, %"));
    // AT&T syntax: the destination is the last operand.
    let writes = a.iter().position(|i| i.ends_with("%rbp") && !i.starts_with("push") && !i.starts_with("cmp") && !i.starts_with("test"));
    // A handler that never returns (`abort`) needn't read it.
    match read {
        Some(r) => assert!(writes.is_none_or(|w| w > r), "{name}: writes rbp before reading it\n{}", a.join("\n")),
        None => assert!(op == Opcode::Abort, "{name}: doesn't read rbp\n{}", a.join("\n")),
    }
}

#[test]
fn handlers_read_rbp_first_and_hot_ones_have_no_prologue() {
    let asm = rt_asm("codegen", None);
    // The sets: the target's (`fp` in `rdi`), and off Apple the frame-pointer set (`rbp`):
    // symbol prefix, register entry module, mode.
    let mut sets = vec![("ryo_h_", "hr", ryo_rt::vm::MODE)];
    #[cfg(not(target_vendor = "apple"))]
    sets.push(("ryo_hf_", "hrf", ryo_rt::vm::FP_MODE));
    for (prefix, hr, mode) in sets {
        // Written in assembly: they use `rbp` and the stack by design.
        let naked = [Opcode::Resume];
        let mut checked = 0;
        for &op in ALL_OPCODES {
            if !has_handler(op) {
                continue;
            }
            let name = format!("{prefix}{op:?}");
            let a = strip_apple_fp(asm_of(&asm, &name).unwrap_or_else(|| panic!("{name}: not in the assembly")));
            if naked.contains(&op) {
                continue;
            }
            if !mode.fp_arg {
                reads_rbp_first(&name, op, &a);
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
            let a = strip_apple_fp(asm_of(&asm, &format!("{prefix}{op:?}")).unwrap());
            let bad = a.iter().find(|i| i.starts_with("push") || (i.starts_with("sub") && i.ends_with("%rsp")) || i.starts_with("call"));
            assert!(bad.is_none(), "{prefix}{op:?}: has a prologue or a call\n{}", a.join("\n"));
        }
        eprintln!("{prefix}AddW32:\n  {}", asm_of(&asm, &format!("{prefix}AddW32")).unwrap().join("\n  "));

        // The register entries: none touches the stack (their buffer of frame operands is
        // kept in registers) but those that call or need a frame anyway. One identical to
        // another may be merged into it, without a name of its own.
        let mut checked = 0;
        for &op in ALL_OPCODES {
            if ryo_bytecode::jit::effects::reg_entry(op, mode).is_none() {
                continue;
            }
            let name = hr_name(hr, op);
            let Some(a) = asm_of(&asm, &name) else { continue };
            let a = strip_apple_fp(a);
            let frame = a.iter().any(|i| i.starts_with("push") || i.starts_with("call") || i.starts_with("jmp\t") && !i.contains(".LBB"));
            if !frame {
                // (`lock or [rsp - 64], 0` is a fence.)
                let bad = a.iter().find(|i| (i.contains("(%rsp)") && !i.starts_with("lock")) || (i.starts_with("sub") && i.ends_with("%rsp")));
                assert!(bad.is_none(), "{name}: keeps its operands on the stack\n{}", a.join("\n"));
            }
            checked += 1;
        }
        // The frame-pointer set's register entries take no `fp`: LLVM merges each into the
        // target set's twin.
        assert!(checked > 300 || hr == "hrf", "{checked}");
        short_reg_entries(&asm, hr, strip_apple_fp, mode);
    }
}

/// The symbol suffix of `op`'s register entry in module `hr` (`hr`, `hrf`), which has no
/// symbol of its own: `<hr>::<Opcode>` mangled (v0).
fn hr_name(hr: &str, op: Opcode) -> String {
    let n = format!("{op:?}");
    format!("{}{hr}{}{n}", hr.len(), n.len())
}
