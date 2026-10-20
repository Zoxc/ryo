//! Island instructions and requests (design/stubs.md#islands-vm--native).
//!
//! An island is `island sym, n_ops, ops…, n_targets, t…`: the merge pass instantiates the
//! template (found by its diagnostic item name in `ryo_rt`) with the generic args, adds the
//! instance and its neighbors to the native CGU, and fills `sym`.

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
    /// instance. Islands whose operation can unwind are `island.catch` unless `unwind` is
    /// `Unreachable`, with a cleanup entry for `unwind` (design/lowering.md#unwinding).
    pub fn island(
        &mut self,
        template: &str,
        args: &[GenericArg<'tcx>],
        ops: &[u32],
        unwind: Option<UnwindAction>,
    ) -> u32 {
        let catch = matches!(unwind, Some(u) if u != UnwindAction::Unreachable);
        let op = if catch { Opcode::IslandCatch } else { Opcode::Island };
        let at = self.code.pos();
        self.code.words.extend([op as u32, 0, ops.len() as u32]);
        self.code.words.extend_from_slice(ops);
        self.code.words.push(0);
        self.islands.push(IslandRequest { at: at + 1, template: Symbol::intern(template), args: self.tcx.mk_args(args) });
        if let Some(u) = unwind {
            self.unwind_entry(at, u);
        }
        at
    }
}
