//! Island instructions and requests (design/stubs.md#islands-vm--native).
//!
//! An island is `island isl, n_ops, ops…`: the merge pass instantiates the
//! template (found by its diagnostic item name in `ryo_rt`) with the generic args, adds the
//! instance and its neighbors to the native CGU, and fills `isl`.

use rustc_middle::mir::UnwindAction;
use rustc_middle::ty::GenericArg;
use rustc_span::Symbol;
use ryo_bytecode::asm::{InsnId, Opnd};
use ryo_bytecode::full::{Opcode, Sym};

use super::{CodeReloc, FnCx};

/// Template diagnostic item names (`vm/rt/src/island.rs`).
pub mod templates {
    use rustc_middle::ty::TyCtxt;
    use rustc_span::Symbol;

    /// `call<F, Args, R>`: a safe Rust fn item through `FnOnce`.
    pub const CALL: &str = "ryo_island_call";
    /// `drop_in_place<T>`.
    pub const DROP_IN_PLACE: &str = "ryo_island_drop_in_place";
    /// `catch_unwind<Data>`: the intrinsic.
    pub const CATCH_UNWIND: &str = "ryo_island_catch_unwind";
    /// `compare_bytes`: the intrinsic.
    pub const COMPARE_BYTES: &str = "ryo_island_compare_bytes";
    /// `raw_eq<T>`: the intrinsic.
    pub const RAW_EQ: &str = "ryo_island_raw_eq";

    /// `as_cast<A, B>`: numeric casts from or to `f16`/`f128`. `ops`: `[src, dest]`.
    pub const AS_CAST: &str = "ryo_island_as_cast";
    /// The 128-bit operations the VM has no instruction for. `ops`: `[a, b, dest]`.
    pub const MUL_W128: &str = "ryo_island_mul_w128";
    pub const DIV_U_W128: &str = "ryo_island_div_u_w128";
    pub const DIV_S_W128: &str = "ryo_island_div_s_w128";
    pub const REM_U_W128: &str = "ryo_island_rem_u_w128";
    pub const REM_S_W128: &str = "ryo_island_rem_s_w128";
    pub const MUL_OVF_U_W128: &str = "ryo_island_mul_ovf_u_w128";
    pub const MUL_OVF_S_W128: &str = "ryo_island_mul_ovf_s_w128";

    /// The wrapper of the intrinsic `name` (`volatile_*`, `simd_*`), `ryo_island_<name>`
    /// (generic like the intrinsic), if `ryo_rt` has one.
    pub fn wrapper(tcx: TyCtxt<'_>, rt: crate::rt::RtItems, name: &str) -> Option<String> {
        let template = format!("ryo_island_{name}");
        rt.item(tcx, Symbol::intern(&template)).map(|_| template)
    }

    /// `call_cN<A0, …, R>` (`extern "C"` through a fn pointer), N ≤ 16.
    pub fn call_c(n: usize) -> Option<String> {
        (n <= 16).then(|| format!("ryo_island_call_c{n}"))
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Emits an island with no successor list (it falls through), and requests its template
    /// instance. `ops` are its operands' slots, each with the size the template accesses
    /// there, which a [`ryo_bytecode::asm::ScopeKind::Lend`] scope records. An island whose
    /// operation can unwind has the unwind action `unwind`; one without (`None`) can't unwind
    /// (design/lowering.md#unwinding).
    pub fn island(&mut self, template: &str, args: &[GenericArg<'tcx>], ops: &[(u32, u32)], unwind: Option<UnwindAction>) -> InsnId {
        let isl = self.reloc(CodeReloc::Island { template: Symbol::intern(template), args: self.tcx.mk_args(args) });
        for &(s, size) in ops {
            self.asm.lend(s, size);
        }
        let at = self.emit(Opcode::Island, &[Opnd::Sym(Sym(isl)), Opnd::Words(ops.iter().map(|o| o.0).collect())]);
        if let Some(u) = unwind {
            self.unwind_entry(at, u);
        }
        at
    }
}
