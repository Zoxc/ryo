//! Island instructions and requests (design/stubs.md#islands-vm--native).
//!
//! An island is `island isl, n_ops, ops…`: the merge pass instantiates the
//! template (found by its diagnostic item name in `ryo_rt`) with the generic args, adds the
//! instance and its neighbors to the native CGU, and fills `isl`.

use rustc_middle::mir::UnwindAction;
use rustc_middle::ty::GenericArg;
use rustc_span::Symbol;
use ryo_bytecode::asm::{InsnId, Opnd};
use ryo_bytecode::insn::{Opcode, Sym};

use super::{CodeReloc, FnCx};

/// Template diagnostic item names (`vm/rt/src/island.rs`).
pub mod templates {
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

    /// The arity of the SIMD intrinsic `name` if `ryo_rt` has a wrapper for it,
    /// `ryo_island_<name>`, generic like the intrinsic.
    pub fn simd(name: &str) -> Option<usize> {
        Some(match name {
            "simd_add" | "simd_sub" | "simd_mul" | "simd_div" | "simd_rem" | "simd_shl" | "simd_shr" | "simd_and"
            | "simd_or" | "simd_xor" | "simd_saturating_add" | "simd_saturating_sub" | "simd_minimum_number_nsz"
            | "simd_maximum_number_nsz" | "simd_eq" | "simd_ne" | "simd_lt" | "simd_le" | "simd_gt" | "simd_ge"
            | "simd_reduce_add_ordered" | "simd_reduce_mul_ordered" | "simd_arith_offset" => 2,
            "simd_neg" | "simd_fabs" | "simd_bswap" | "simd_bitreverse" | "simd_ctlz" | "simd_ctpop" | "simd_cttz"
            | "simd_ceil" | "simd_floor" | "simd_round" | "simd_round_ties_even" | "simd_trunc" | "simd_fsqrt"
            | "simd_splat" | "simd_cast" | "simd_as" | "simd_bitmask" | "simd_reduce_add_unordered"
            | "simd_reduce_mul_unordered" | "simd_reduce_max" | "simd_reduce_min" | "simd_reduce_and"
            | "simd_reduce_or" | "simd_reduce_xor" | "simd_reduce_all" | "simd_reduce_any" | "simd_cast_ptr"
            | "simd_expose_provenance" | "simd_with_exposed_provenance" => 1,
            "simd_fma" | "simd_relaxed_fma" | "simd_funnel_shl" | "simd_funnel_shr" | "simd_select"
            | "simd_select_bitmask" => 3,
            _ => return None,
        })
    }

    /// `call_cN<A0, …, R>` (`extern "C"` through a fn pointer), N ≤ 16.
    pub fn call_c(n: usize) -> Option<&'static str> {
        const NAMES: [&str; 17] = [
            "ryo_island_call_c0", "ryo_island_call_c1", "ryo_island_call_c2", "ryo_island_call_c3",
            "ryo_island_call_c4", "ryo_island_call_c5", "ryo_island_call_c6", "ryo_island_call_c7",
            "ryo_island_call_c8", "ryo_island_call_c9", "ryo_island_call_c10", "ryo_island_call_c11",
            "ryo_island_call_c12", "ryo_island_call_c13", "ryo_island_call_c14", "ryo_island_call_c15",
            "ryo_island_call_c16",
        ];
        NAMES.get(n).copied()
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Emits an island with no successor list (it falls through), and requests its template
    /// instance. An island whose operation can unwind has the unwind action `unwind`; one
    /// without (`None`) can't unwind (design/lowering.md#unwinding).
    pub fn island(
        &mut self,
        template: &str,
        args: &[GenericArg<'tcx>],
        ops: &[u32],
        unwind: Option<UnwindAction>,
    ) -> InsnId {
        let isl = self.reloc(CodeReloc::Island { template: Symbol::intern(template), args: self.tcx.mk_args(args) });
        let at = self.emit(Opcode::Island, vec![Opnd::Sym(Sym(isl)), Opnd::Words(ops.to_vec())]);
        if let Some(u) = unwind {
            self.unwind_entry(at, u);
        }
        at
    }
}
