//! Island instructions and requests (design/stubs.md#islands-vm--native).
//!
//! An island is `island isl, n_ops, ops…, n_succs, t…`: the merge pass instantiates the
//! template (found by its diagnostic item name in `ryo_rt`) with the generic args, adds the
//! instance and its neighbors to the native CGU, and fills `isl`.

use rustc_middle::mir::UnwindAction;
use rustc_middle::ty::GenericArg;
use rustc_span::Symbol;
use ryo_bytecode::insn::Opcode;

use super::{FnCx, IslandRequest};

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

    /// `call_ptrN<A0, …, R>` (Rust ABI through a fn pointer), N ≤ 17.
    pub fn call_ptr(n: usize) -> Option<String> {
        (n <= 17).then(|| format!("ryo_island_call_ptr{n}"))
    }

    /// `call_cN<A0, …, R>` (`extern "C"` through a fn pointer), N ≤ 16.
    pub fn call_c(n: usize) -> Option<String> {
        (n <= 16).then(|| format!("ryo_island_call_c{n}"))
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
    ) -> u32 {
        let at = self.code.pos();
        self.code.words.extend([Opcode::Island as u32, 0, ops.len() as u32]);
        self.code.words.extend_from_slice(ops);
        self.code.words.push(0);
        self.islands.push(IslandRequest { at: at + 1, template: Symbol::intern(template), args: self.tcx.mk_args(args) });
        if let Some(u) = unwind {
            self.unwind_entry(at, u);
        }
        at
    }
}
