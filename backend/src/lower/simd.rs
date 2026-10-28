//! Portable `simd_*` intrinsics as VM instructions (design/lowering.md#simd): a table of
//! (intrinsic, type-argument shapes) → opcode. The intrinsics and shapes without a row stay
//! wrapper islands (`intrinsic.rs`), or keep a `#[target_feature]` function native
//! ([`FnCx::strict_simd`]).

use rustc_middle::ty::{self, Instance, Ty};
use ryo_bytecode::full::Opcode;

use super::call::{ArgSrc, CallCont};
use super::{FnCx, NeedsNative, native};

/// What a type argument of a `simd_*` intrinsic is, as far as the table cares.
#[derive(Clone, Copy, PartialEq)]
enum Shape {
    /// 16 lanes of `i8`.
    I8x16,
    /// 16 lanes of `u8`.
    U8x16,
    /// Another 16-byte vector of integers (`i16x8` … `i64x2`, `__m128i`).
    Int128,
    /// `i8` or `u8`.
    Byte,
    /// A 16-bit mask: `u16` or `[u8; 2]`.
    Mask16,
    Other,
}

use Shape::*;

fn x8(s: Shape) -> bool {
    matches!(s, I8x16 | U8x16)
}

fn int128(s: Shape) -> bool {
    matches!(s, I8x16 | U8x16 | Int128)
}

/// A row: the intrinsic, the test of its type arguments, the opcode, and whether the two
/// inputs are swapped. The opcode's operands are the destination, then the inputs.
struct Row {
    name: &'static str,
    ok: fn(&[Shape]) -> bool,
    op: Opcode,
    swap: bool,
}

const fn row(name: &'static str, ok: fn(&[Shape]) -> bool, op: Opcode) -> Row {
    Row { name, ok, op, swap: false }
}

/// The intrinsics with an instruction. Only SSE2 semantics: no unsigned compares (`simd_lt`
/// on `u8` stays an island), no `ne`/`le`/`ge`, no other shapes.
const ROWS: &[Row] = &[
    row("simd_splat", |t| matches!(t, [v, Byte] if x8(*v)), Opcode::VsplatI8x16),
    row("simd_eq", |t| matches!(t, [v, m] if x8(*v) && x8(*m)), Opcode::VeqI8x16),
    row("simd_lt", |t| matches!(t, [I8x16, m] if x8(*m)), Opcode::VltSI8x16),
    Row { swap: true, ..row("simd_gt", |t| matches!(t, [I8x16, m] if x8(*m)), Opcode::VltSI8x16) },
    row("simd_bitmask", |t| matches!(t, [v, Mask16] if x8(*v)), Opcode::VmsbI8x16),
    row("simd_and", |t| matches!(t, [v] if int128(*v)), Opcode::AndW128),
    row("simd_or", |t| matches!(t, [v] if int128(*v)), Opcode::OrW128),
    row("simd_xor", |t| matches!(t, [v] if int128(*v)), Opcode::XorW128),
];

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    fn simd_shape(&self, t: Ty<'tcx>) -> Shape {
        let tcx = self.tcx;
        match *t.kind() {
            ty::Adt(..) if t.is_simd() => {
                let (n, e) = t.simd_size_and_type(tcx);
                match (e.kind(), n) {
                    (ty::Int(ty::IntTy::I8), 16) => I8x16,
                    (ty::Uint(ty::UintTy::U8), 16) => U8x16,
                    (ty::Int(_) | ty::Uint(_), _) if e.primitive_size(tcx).bytes() * n == 16 => Int128,
                    _ => Other,
                }
            }
            ty::Int(ty::IntTy::I8) | ty::Uint(ty::UintTy::U8) => Byte,
            ty::Uint(ty::UintTy::U16) => Mask16,
            ty::Array(e, len) if matches!(e.kind(), ty::Uint(ty::UintTy::U8)) && len.try_to_target_usize(tcx) == Some(2) => Mask16,
            _ => Other,
        }
    }

    /// `simd_*` intrinsic `name` as its instruction, if [`ROWS`] has one for its type
    /// arguments. `Ok(false)`: no row.
    pub(super) fn simd_op(
        &mut self,
        name: &str,
        callee: Instance<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        cont: &CallCont<'tcx>,
    ) -> Result<bool, NeedsNative> {
        let shapes: Vec<Shape> = callee.args.iter().map(|g| g.as_type().map_or(Other, |t| self.simd_shape(t))).collect();
        let Some(row) = ROWS.iter().find(|r| r.name == name && (r.ok)(&shapes)) else { return Ok(false) };
        if args.len() + 1 != row.op.info().operands.len() {
            return native("intrinsic argument count");
        }
        let mut ins = args.iter().map(|a| self.arg_slot(a)).collect::<Result<Vec<u32>, _>>()?;
        if row.swap {
            ins.swap(0, 1);
        }
        self.into_dest(cont, |fx, d| {
            let mut ops = vec![d];
            ops.extend(ins);
            fx.op(row.op, &ops);
            Ok(())
        })
    }
}
