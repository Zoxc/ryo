//! The `RYO_DUMP` and `RYO_DUMP_CODE` debug dumps of the image's VM functions.

use rustc_data_structures::fx::FxHashMap;
use rustc_middle::ty::{Instance, TyCtxt};
use ryo_bytecode::asm::{self, Ref};
use ryo_bytecode::full::{Const, Data, Func, Site, Sym};
use ryo_bytecode::image::{CATCH, CONTINUE};

use super::lower::CodeReloc;
use super::partition::{VmFn, path};
use super::symbols;

/// Writes dump `text` to `path`, fatal on failure.
pub(super) fn write(tcx: TyCtxt<'_>, var: &str, path: &std::ffi::OsStr, text: &str) {
    std::fs::write(path, text).unwrap_or_else(|e| tcx.dcx().fatal(format!("ryo: {var}: {e}")));
}

/// The `RYO_DUMP` text: each VM function, by path, decoded back to VM instructions, its
/// operands that name relocations (`fn`, `sym`, `site`, `k`, `data`) listed below it.
pub(super) fn vm_text<'tcx>(tcx: TyCtxt<'tcx>, vm: &[VmFn<'tcx>], mode: asm::Mode) -> String {
    use std::fmt::Write;
    let mut fns: Vec<(String, &VmFn<'tcx>)> = vm.iter().map(|v| (path(v.instance), v)).collect();
    fns.sort_by(|a, b| a.0.cmp(&b.0));
    let mut out = String::new();
    for (name, v) in fns {
        let l = &v.lowered;
        let c = &l.code;
        let flags = func_flags_suffix(symbols::func_flags(tcx, v.instance));
        writeln!(out, "fn {name} (frame {}, args {}, ret {}){flags}", l.frame_size, l.arg_size, l.ret_size).unwrap();
        match asm::decode(&c.code, &c.relocs, &c.rodata, &c.call_sites, &c.dropped, &c.scopes, mode) {
            Ok(d) => dump_labeled(&mut out, &d.words, &d.cleanup, &d.scopes),
            Err(e) => writeln!(out, "  undecodable: {e:?}").unwrap(),
        }
        for (i, r) in l.relocs.iter().enumerate() {
            let what = match *r {
                CodeReloc::Call { callee } => format!("fn{i} = {}", path(callee)),
                CodeReloc::Symbol { target } => format!("sym{i} = {}", path(target)),
                CodeReloc::Static { def_id } => {
                    format!("sym{i} = static {}", rustc_middle::ty::print::with_no_trimmed_paths!(tcx.def_path_str(def_id)))
                }
                CodeReloc::Const { offset, .. } => format!("k{i} = const allocation + {offset}"),
                CodeReloc::Bytes { ref bytes, align } => format!("k{i} = bytes {bytes:02x?} align {align}"),
                CodeReloc::Data { offset, .. } => format!("data{i} = allocation + {offset}"),
                CodeReloc::Island { template, args } => format!("sym{i} = island {template}{args:?}"),
            };
            writeln!(out, "  {what}").unwrap();
        }
        out.push('\n');
    }
    out
}

/// The `RYO_DUMP_CODE` text, for `y bench codegen` to disassemble: each VM function, by
/// path, as `fn <path>`, then `code <hex>` and one `reloc <offset> <target>` per relocated
/// field, the targets named as the `RYO_DUMP` operands are. The merge appends the image's
/// names ([`image_names`]): `image <index> <path>` per function, and `ref <index> <global>
/// <local>` per reference of its code, the image's name (`fn12`, `k96`) then the
/// function's (`fn0`, `k1`), with which the JIT's code (`RYO_JIT_DUMP`) is printed.
pub(super) fn code_text<'tcx>(tcx: TyCtxt<'tcx>, vm: &[VmFn<'tcx>]) -> String {
    use std::fmt::Write;
    let mut fns: Vec<(String, &VmFn<'tcx>)> = vm.iter().map(|v| (path(v.instance), v)).collect();
    fns.sort_by(|a, b| a.0.cmp(&b.0));
    let mut out = String::new();
    for (name, v) in fns {
        let c = &v.lowered.code;
        let flags = func_flags_suffix(symbols::func_flags(tcx, v.instance));
        writeln!(out, "fn {name}{flags}").unwrap();
        out.push_str("code ");
        for b in &c.code {
            write!(out, "{b:02x}").unwrap();
        }
        out.push('\n');
        for r in &c.relocs {
            let to = match r.to {
                Ref::Handler(op) => crate::objfile::handler_name(op),
                Ref::RegHandler(op) => crate::objfile::reg_handler_name(op),
                Ref::Probe => crate::objfile::PROBE_SYMBOL.to_owned(),
                Ref::Func(x) => x.to_string(),
                Ref::Sym(x) => x.to_string(),
                Ref::Site(x) => x.to_string(),
                Ref::Const(x) => x.to_string(),
                Ref::Data(x) => x.to_string(),
                Ref::Ro(off) => format!("ro+{off}"),
                Ref::Rec => "jit_record".to_owned(),
                Ref::RecLoopCtr => "jit_record.ctr_l".to_owned(),
            };
            writeln!(out, "reloc {} {to}", r.at).unwrap();
        }
    }
    out
}

/// Appends the merge's `RYO_DUMP_CODE` names for image function `i` ([`code_text`]): the
/// function's line, and one line per reference of its `relocs`, given each local reference's
/// image index `vals`.
pub(super) fn image_names(out: &mut String, i: usize, instance: Instance<'_>, relocs: &[asm::Reloc], vals: &[u32]) {
    use std::fmt::Write;
    writeln!(out, "image {i} {}", path(instance)).unwrap();
    let v = |i: u32| vals[i as usize];
    for r in relocs {
        let _ = match r.to {
            Ref::Func(Func(k)) => writeln!(out, "ref {i} {} {}", Func(v(k)), Func(k)),
            Ref::Sym(Sym(k)) => writeln!(out, "ref {i} {} {}", Sym(v(k)), Sym(k)),
            Ref::Site(Site(k)) => writeln!(out, "ref {i} {} {}", Site(v(k)), Site(k)),
            Ref::Const(Const(k)) => writeln!(out, "ref {i} {} {}", Const(v(k)), Const(k)),
            Ref::Data(Data(k)) => writeln!(out, "ref {i} {} {}", Data(v(k)), Data(k)),
            _ => Ok(()),
        };
    }
}

/// Prints decoded VM code for `RYO_DUMP`: one instruction per line, without offsets, with
/// branch targets (`@±n`) and cleanup entries naming labels `L<n>`, numbered in order of
/// position, and `L<n>:` printed before each labeled instruction.
fn dump_labeled(out: &mut String, words: &[u32], cleanup: &[ryo_bytecode::image::CleanupEntry], scopes: &[asm::Scope]) {
    use std::fmt::Write;
    let mut lines = Vec::new();
    for r in ryo_bytecode::full::Decoder::new(words) {
        match r {
            Ok((at, insn)) => lines.push((at, insn.to_string())),
            Err(e) => {
                lines.push((usize::MAX, format!("error: {e}")));
                break;
            }
        }
    }
    // Rewrites each `@±n` in `text` (at `at`) with `f(at + n)`.
    fn targets(text: &str, at: usize, mut f: impl FnMut(usize) -> String) -> String {
        let mut res = String::new();
        let mut rest = text;
        while let Some(i) = rest.find('@') {
            res.push_str(&rest[..i]);
            let t = &rest[i + 1..];
            let n = t.find(|c: char| c != '+' && c != '-' && !c.is_ascii_digit()).unwrap_or(t.len());
            let off: i64 = t[..n].parse().expect("a branch offset");
            res.push_str(&f((at as i64 + off) as usize));
            rest = &t[n..];
        }
        res.push_str(rest);
        res
    }
    let mut labeled = std::collections::BTreeSet::new();
    for (at, text) in &lines {
        targets(text, *at, |t| {
            labeled.insert(t);
            String::new()
        });
    }
    for e in cleanup {
        labeled.insert(e.offset as usize);
        if e.target != CONTINUE {
            labeled.insert((e.target & !CATCH) as usize);
        }
    }
    let label: FxHashMap<usize, usize> = labeled.iter().enumerate().map(|(i, &at)| (at, i)).collect();
    let name = |at: usize| match label.get(&at) {
        Some(l) => format!("L{l}"),
        None => format!("@{at}"),
    };
    // The escapes and storage ends before the instruction at `at`.
    let mut scopes = scopes.iter().peekable();
    let mut scopes_at = |out: &mut String, at: usize| {
        while let Some(sc) = scopes.next_if(|sc| sc.code_offset as usize <= at) {
            let what = match sc.kind {
                asm::ScopeKind::Escape { align } => format!("escape align {align}"),
                asm::ScopeKind::End => "end".to_owned(),
                asm::ScopeKind::Lend => "lend".to_owned(),
            };
            writeln!(out, "    ; {what} ${}, {} bytes", sc.frame_offset, sc.size).unwrap();
        }
    };
    for (at, text) in &lines {
        if label.contains_key(at) {
            writeln!(out, "{}:", name(*at)).unwrap();
        }
        scopes_at(out, *at);
        writeln!(out, "    {}", targets(text, *at, name)).unwrap();
    }
    scopes_at(out, usize::MAX);
    for e in cleanup {
        let to = match e.target {
            CONTINUE => "continue".to_owned(),
            t if t & CATCH != 0 => format!("{} (catch)", name((t & !CATCH) as usize)),
            t => name(t as usize),
        };
        writeln!(out, "  cleanup {} -> {to}", name(e.offset as usize)).unwrap();
    }
}

/// The names of [`func_flags`]' bits, as the dumps print them (` [always, cold]`, or empty).
pub(crate) fn func_flags_suffix(flags: u8) -> String {
    use ryo_bytecode::image::*;
    let names = [(FUNC_INLINE_ALWAYS, "always"), (FUNC_INLINE_NEVER, "never"), (FUNC_COLD, "cold"), (FUNC_INLINE_HINT, "hint")];
    let set: Vec<&str> = names.iter().filter(|n| flags & n.0 != 0).map(|n| n.1).collect();
    if set.is_empty() { String::new() } else { format!(" [{}]", set.join(", ")) }
}
