//! `RYO_JIT_DUMP`'s `.code` files.

use super::*;

impl Jit {
    /// `RYO_JIT_DUMP`: the installed code of `job`'s function `func` as
    /// `dir/f<func>-<header>.code`, for `y
    /// bench codegen` to disassemble: `tier`, `code <hex>` (the body, then from `osr <offset>`
    /// the OSR code) and a `reloc <offset> <target>` per relocated field, the targets by
    /// image index as the backend's `RYO_DUMP_CODE` names them (`fn3`, `sym2`, `k16`,
    /// `ryo_h_AddOvf`), and per retargeted callee `ext fn<operand> <form> <name>`: the code
    /// and the IR call it as function `operand` ([`asm::FUNC_KINDS`]), which is the caller's
    /// function or symbol `name`, through a call slot (`slot`), directly (`near`) or through
    /// `r11` (`far`).
    pub(super) fn dump_code(
        &self,
        job: &Job<'_>,
        ext: &[Ext],
        tier: Tier,
        code: &[u8],
        relocs: &[asm::Reloc],
        osr: Option<(usize, &asm::osr::OsrCode)>,
    ) {
        let Some(dir) = &self.dump else { return };
        let (func, header) = (job.func, job.img.header() as *const _ as usize);
        use core::fmt::Write as _;
        let mut s = std::format!("tier {}\ncode ", tier.name());
        let hex = |s: &mut std::string::String, bytes: &[u8]| {
            for b in bytes {
                let _ = write!(s, "{b:02x}");
            }
            s.push('\n');
        };
        hex(&mut s, code);
        if let Some((at, o)) = osr {
            let _ = write!(s, "osr {at} ");
            hex(&mut s, &o.code);
        }
        for r in relocs {
            let to = match r.to {
                Ref::Handler(op) => std::format!("ryo_h_{op:?}"),
                Ref::RegHandler(op) => std::format!("ryo_hr_{op:?}"),
                Ref::Probe => "ryo_probe_stack".into(),
                Ref::Func(g) => g.to_string(),
                Ref::Sym(x) => x.to_string(),
                Ref::Const(x) => x.to_string(),
                Ref::Data(x) => x.to_string(),
                Ref::Ro(o) => std::format!("ro+{o}"),
                Ref::Rec => "jit_record".into(),
                Ref::RecLoopCtr => "jit_record.ctr_l".into(),
            };
            let _ = writeln!(s, "reloc {} {to}", r.at);
        }
        // The retargeted callees, which the code and the IR name.
        for (k, e) in ext.iter().enumerate() {
            let form = match e.kind {
                FUNC_SLOT => "slot",
                FUNC_NEAR => "near",
                _ => "far",
            };
            let name = match e.name {
                Name::Func(g) => Func(g).to_string(),
                Name::Sym(x) => Sym(x).to_string(),
                Name::Other(g) => std::format!("{}@other", Func(g)),
                Name::OtherSym(x) => std::format!("{}@other", Sym(x)),
                Name::Addr(a) => std::format!("{a:#x}"),
            };
            let _ = writeln!(s, "ext {} {form} {name}", Func(e.kind | k as u32));
        }
        let _ = std::fs::write(dump_path(dir, func, header, "code"), s);
    }
}

/// `RYO_JIT_DUMP`'s file for `func` (by its image `header`) with extension `ext`:
/// `dir/f<func>-<header>.<ext>`.
pub(super) fn dump_path(dir: &str, func: u32, header: usize, ext: &str) -> String {
    std::format!("{dir}/f{func}-{header:x}.{ext}")
}
