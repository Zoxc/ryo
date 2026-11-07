//! Island instructions and requests (design/stubs.md#islands-vm--native).
//!
//! An island is `island isl, n_ops, ops…`: the merge pass instantiates the
//! template (found by its diagnostic item name in `ryo_rt`) with the generic args, adds the
//! instance and its neighbors to the native CGU, and fills `isl`.

use rustc_middle::mir::{Operand, UnwindAction};
use rustc_middle::ty::GenericArg;
use rustc_middle::ty::layout::TyAndLayout;
use rustc_span::Symbol;
use ryo_bytecode::asm::{InsnId, Opnd};
use ryo_bytecode::full::{Opcode, Sym};

use super::place::{Loc, PlaceVal};
use super::{CodeReloc, FnCx, NeedsNative};

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

    /// `s`, a slot holding a value of `layout`, as an island operand: templates access their
    /// operands as aligned (`ryo_rt::island::slot`), but a field of a `repr(packed)` local
    /// can be at any offset, so a misaligned `s` is copied to an aligned temporary.
    pub fn island_slot(&mut self, s: u32, layout: TyAndLayout<'tcx>) -> u32 {
        if is_aligned(s, layout) {
            return s;
        }
        let t = self.temp_for(layout);
        self.with_cuts(layout, |fx| fx.mov(t, s, layout.size.bytes() as u32));
        t
    }

    /// The value of `op` in an aligned frame slot ([`FnCx::island_slot`]), with its size.
    pub fn island_operand(&mut self, op: &Operand<'tcx>) -> Result<(u32, u32), NeedsNative> {
        let (s, layout) = self.operand_slot(op)?;
        Ok((self.island_slot(s, layout), layout.size.bytes() as u32))
    }

    /// [`FnCx::with_place_slot`] for an island's destination: a slot `dst` that isn't
    /// aligned for its type ([`FnCx::island_slot`]) is written through a temporary.
    pub fn with_island_place_slot(
        &mut self,
        dst: PlaceVal<'tcx>,
        f: impl FnOnce(&mut Self, u32) -> Result<(), NeedsNative>,
    ) -> Result<(), NeedsNative> {
        if let (Loc::Slot(d), None) = (dst.loc, dst.meta)
            && !is_aligned(d, dst.layout)
        {
            let t = self.temp_for(dst.layout);
            f(self, t)?;
            self.with_cuts(dst.layout, |fx| fx.mov(d, t, dst.layout.size.bytes() as u32));
            return Ok(());
        }
        self.with_place_slot(dst, f)
    }
}

/// Whether the slot `s` is aligned for `layout` relative to `fp` (frames are 16-aligned,
/// and neither the bias nor `F` changes a slot's offset modulo 16).
pub fn is_aligned(s: u32, layout: TyAndLayout<'_>) -> bool {
    s % (layout.align.abi.bytes().min(16) as u32) == 0
}
