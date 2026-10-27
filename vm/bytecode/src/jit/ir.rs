//! The SSA IR (design/jit.md, "The SSA tier"): blocks with parameters, instructions in an
//! arena, `u32` ids. Values are untyped bit vectors of 1, 2, 4 or 8 bytes (general-purpose
//! registers) or 16 bytes (vectors, in `xmm` registers): an operation of width `w` reads the
//! low `w` bytes of its operands and defines the low `w` bytes of its result (the rest of a
//! register or slot holding it is unspecified). Vectors and scalars are separate classes: no
//! operation reads a vector at a scalar width or the other way round. Compare results are
//! 1-byte booleans (0 or 1). A constant of 16 bytes is its `u64` zero-extended
//! ([`Op::VConst`] makes any other).
//!
//! Frame memory is cut into allocas ([`Alloca`]); pointers into the frame come only from
//! [`Op::AllocaAddr`]. Promoted allocas have no memory: their fields are SSA values.

use alloc::boxed::Box;
use alloc::vec::Vec;
use core::fmt;

use crate::asm::{ArgReg, Ref, RetPart};
use crate::full::{Func as FuncIdx, Opcode, Sym};
use crate::reduced::Arg;

macro_rules! id {
    ($name:ident, $p:literal) => {
        #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
        pub struct $name(pub u32);
        impl $name {
            pub fn idx(self) -> usize {
                self.0 as usize
            }
        }
        impl fmt::Display for $name {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                write!(f, concat!($p, "{}"), self.0)
            }
        }
    };
}
id!(Value, "v");

impl Value {
    /// No value: padding for a missing operand, never read (it indexes out of bounds).
    pub const NONE: Value = Value(u32::MAX);
}
id!(Block, "b");
id!(Inst, "i");
id!(AllocaId, "a");

/// Where a value comes from.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ValueDef {
    /// Result `n` of an instruction.
    Inst(Inst, u8),
    /// Parameter `n` of a block.
    Param(Block, u16),
    Const(u64),
    /// Uninitialized memory: any bits.
    Undef,
    /// A removed trivial phi: the value it stands for (resolved away by
    /// [`Func::resolve_aliases`]).
    Alias(Value),
}

#[derive(Clone, Copy, Debug)]
pub struct ValueData {
    pub def: ValueDef,
    /// Bytes: 1, 2, 4, 8 or 16.
    pub w: u8,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum BinOp {
    Add,
    Sub,
    Mul,
    And,
    Or,
    Xor,
    /// Shifts: the amount is masked to the width in bits less one (a constant operand is
    /// already below it).
    Shl,
    ShrS,
    ShrU,
    /// Rotates: the amount taken modulo the width in bits (it comes from a 4-byte operand,
    /// zero-extended at 8 bytes).
    Rotl,
    Rotr,
    /// Division and remainder, signed or not: undefined for a zero divisor or `MIN / -1`.
    DivS,
    DivU,
    RemS,
    RemU,
}

impl BinOp {
    pub fn commutative(self) -> bool {
        matches!(self, BinOp::Add | BinOp::Mul | BinOp::And | BinOp::Or | BinOp::Xor)
    }

    /// `a self b` on the low `w` bytes ([`Op::Bin`]).
    pub fn eval(self, w: u8, a: u64, b: u64) -> u64 {
        let (a, b) = (mask(a, w), mask(b, w));
        let r = match self {
            BinOp::Add => a.wrapping_add(b),
            BinOp::Sub => a.wrapping_sub(b),
            BinOp::Mul => a.wrapping_mul(b),
            BinOp::And => a & b,
            BinOp::Or => a | b,
            BinOp::Xor => a ^ b,
            BinOp::Shl => a << (b & (8 * w as u64 - 1)),
            BinOp::ShrU => a >> (b & (8 * w as u64 - 1)),
            BinOp::ShrS => (sext(a, w) >> (b & (8 * w as u64 - 1))) as u64,
            BinOp::Rotl | BinOp::Rotr => {
                let (n, k) = (8 * w as u32, (b & (8 * w as u64 - 1)) as u32);
                let k = if self == BinOp::Rotl { k } else { (n - k) % n };
                if k == 0 { a } else { a << k | a >> (n - k) }
            }
            // Undefined for a zero divisor or `MIN / -1`: any value will do.
            BinOp::DivU => a.checked_div(b).unwrap_or(0),
            BinOp::RemU => a.checked_rem(b).unwrap_or(0),
            BinOp::DivS => sext(a, w).checked_div(sext(b, w)).unwrap_or(0) as u64,
            BinOp::RemS => sext(a, w).checked_rem(sext(b, w)).unwrap_or(0) as u64,
        };
        mask(r, w)
    }

    /// `a self b` (an add, a sub or a mul) at `w` bytes, signed or not, and whether it
    /// overflowed ([`Op::Ovf`]).
    pub fn eval_ovf(self, signed: bool, w: u8, a: u64, b: u64) -> (u64, bool) {
        let bits = 8 * w as u32;
        if signed {
            let (x, y) = (sext(a, w) as i128, sext(b, w) as i128);
            let r = match self {
                BinOp::Add => x + y,
                BinOp::Sub => x - y,
                _ => x * y,
            };
            let lim = 1i128 << (bits - 1);
            (mask(r as u64, w), r < -lim || r >= lim)
        } else {
            let (x, y) = (mask(a, w) as u128, mask(b, w) as u128);
            let (r, under) = match self {
                BinOp::Add => (x + y, false),
                BinOp::Sub => (x.wrapping_sub(y), x < y),
                _ => (x * y, false),
            };
            (mask(r as u64, w), under || r > mask(u64::MAX, w) as u128)
        }
    }
}

/// A comparison, signed (`S`) or unsigned (`U`).
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum Cc {
    Eq,
    Ne,
    LtS,
    LtU,
    LeS,
    LeU,
    GtS,
    GtU,
    GeS,
    GeU,
}

impl Cc {
    /// The comparison that is true when `self` is false.
    pub fn negate(self) -> Cc {
        match self {
            Cc::Eq => Cc::Ne,
            Cc::Ne => Cc::Eq,
            Cc::LtS => Cc::GeS,
            Cc::LtU => Cc::GeU,
            Cc::LeS => Cc::GtS,
            Cc::LeU => Cc::GtU,
            Cc::GtS => Cc::LeS,
            Cc::GtU => Cc::LeU,
            Cc::GeS => Cc::LtS,
            Cc::GeU => Cc::LtU,
        }
    }

    /// The comparison with the operands swapped.
    pub fn swap(self) -> Cc {
        match self {
            Cc::Eq | Cc::Ne => self,
            Cc::LtS => Cc::GtS,
            Cc::LtU => Cc::GtU,
            Cc::LeS => Cc::GeS,
            Cc::LeU => Cc::GeU,
            Cc::GtS => Cc::LtS,
            Cc::GtU => Cc::LtU,
            Cc::GeS => Cc::LeS,
            Cc::GeU => Cc::LeU,
        }
    }

    /// Whether `a self a` holds.
    pub fn reflexive(self) -> bool {
        matches!(self, Cc::Eq | Cc::LeS | Cc::LeU | Cc::GeS | Cc::GeU)
    }

    /// Whether `a self b` holds on the low `w` bytes.
    pub fn holds(self, w: u8, a: u64, b: u64) -> bool {
        let (ua, ub) = (mask(a, w), mask(b, w));
        let (sa, sb) = (sext(ua, w), sext(ub, w));
        match self {
            Cc::Eq => ua == ub,
            Cc::Ne => ua != ub,
            Cc::LtU => ua < ub,
            Cc::LeU => ua <= ub,
            Cc::GtU => ua > ub,
            Cc::GeU => ua >= ub,
            Cc::LtS => sa < sb,
            Cc::LeS => sa <= sb,
            Cc::GtS => sa > sb,
            Cc::GeS => sa >= sb,
        }
    }

    pub fn signed(self) -> bool {
        matches!(self, Cc::LtS | Cc::LeS | Cc::GtS | Cc::GeS)
    }
}

/// A frame address a handler or an island operand names: a byte of a memory alloca, or of
/// the handler scratch area (where promoted values are passed).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SlotRef {
    /// `offset` bytes into the alloca.
    Alloca(AllocaId, i32),
    /// `offset` bytes into the scratch area.
    Scratch(u32),
}

/// What unwinding out of a call does.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Site {
    /// It can't unwind (no call site: the unwinder aborts).
    None,
    /// To the caller.
    Continue,
    /// To the landing pad: the block ends in [`Term::Invoke`].
    Pad { catch: bool },
}

/// A handler call. `args` are the `In` values, stored at `ins` (scratch offsets, 8 bytes
/// each) before the call; the results are the `nout` `Out` values loaded from `outs` after it,
/// then with `ret` the handler's return value (`al` for a `br` shape, `rax` for a `switch`).
/// With `reg`, it calls the handler's register entry (`effects::RegEntry`) instead: the `In`
/// values go in the first argument registers, the `Out` values and the return value come back
/// in `rax`, `rdx`, and `ins` and `outs` are empty.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HCall {
    pub h: Opcode,
    /// The argument registers from `rdi`: their values, with the frame offsets in their low
    /// and high 32-bit halves replaced by the slots given.
    pub regs: Vec<(Arg, [Option<SlotRef>; 2])>,
    pub ins: Vec<u32>,
    pub outs: Vec<u32>,
    pub nout: u8,
    pub ret: bool,
    pub reg: bool,
    pub site: Site,
}

impl HCall {
    /// The allocas its frame operands name.
    pub fn allocas(&self) -> impl Iterator<Item = AllocaId> + '_ {
        self.regs.iter().flat_map(|r| r.1.iter().flatten()).filter_map(SlotRef::alloca)
    }
}

impl SlotRef {
    pub fn alloca(&self) -> Option<AllocaId> {
        match *self {
            SlotRef::Alloca(a, _) => Some(a),
            SlotRef::Scratch(_) => None,
        }
    }
}

impl Call {
    /// The index of the argument passed in the callee's entry register `r`.
    pub fn arg_for(&self, r: &ArgReg) -> Option<usize> {
        self.regs.iter().position(|x| x.xmm == r.xmm && x.index == r.index)
    }

    /// The bytes of argument `ai` that the call defines: it zero-extends the argument to its
    /// register's size (at most 8); past that, the register's bytes are unspecified.
    pub fn arg_width(&self, ai: usize) -> u8 {
        (self.regs[ai].size as u8).min(8)
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CallTarget {
    /// A function of the image: `call rel32`.
    Func(FuncIdx),
    /// `call [rip + sym]`.
    Sym(Sym),
    /// Through the pointer the symbol slot points at.
    SymInd(Sym),
    /// The first argument value is the callee's address.
    Ptr,
}

/// A call (or tail call): `args` (after the callee for [`CallTarget::Ptr`]) go to `regs`;
/// the results are the return parts (`parts`), integer ones from `rax`/`rdx`, float ones from
/// `xmm0`/`xmm1`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Call {
    pub target: CallTarget,
    pub regs: Vec<ArgReg>,
    pub parts: Vec<RetPart>,
    pub site: Site,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Island {
    /// The island function: a symbol of the unit's image ([`CallTarget::Sym`]), or for one
    /// inlined from another image, the JIT's call form of its address ([`CallTarget::Func`]
    /// with an [`crate::asm::FUNC_KINDS`] bit, [`super::inline::rebase`]).
    pub isl: CallTarget,
    pub ops: Vec<SlotRef>,
    pub site: Site,
}

/// A vector operation on 16 × 8-bit lanes ([`Op::V`]; the `vsplat`, `veq`, `vlt.s` and
/// `vmsb` instructions, design/instructions.md "SIMD"), or between a vector and its two
/// 64-bit halves.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum VOp {
    /// A byte (1-byte operand) in every lane.
    Splat,
    /// Lanes equal: `0xff`, else 0.
    Eq,
    /// Lanes less, signed: `0xff`, else 0.
    LtS,
    /// The lanes' top bits: a 2-byte mask, lane `i` at bit `i`.
    Msb,
    /// The 8-byte half `n` (0: the low bytes).
    Half(u8),
    /// Two 8-byte operands as one vector, the first in the low bytes.
    Pair,
}

impl VOp {
    /// The operands' widths and the result's.
    pub fn widths(self) -> (&'static [u8], u8) {
        match self {
            VOp::Splat => (&[1], 16),
            VOp::Eq | VOp::LtS => (&[16, 16], 16),
            VOp::Msb => (&[16], 2),
            VOp::Half(_) => (&[16], 8),
            VOp::Pair => (&[8, 8], 16),
        }
    }

    /// The result on constant operands (vectors as `u128`, scalars in their low bytes).
    pub fn eval(self, x: &[u128]) -> u128 {
        let lanes = |v: u128| v.to_le_bytes();
        let map2 = |a: u128, b: u128, g: fn(u8, u8) -> bool| {
            let (a, b) = (lanes(a), lanes(b));
            u128::from_le_bytes(core::array::from_fn(|i| if g(a[i], b[i]) { 0xff } else { 0 }))
        };
        match self {
            VOp::Splat => u128::from_le_bytes([x[0] as u8; 16]),
            VOp::Eq => map2(x[0], x[1], |a, b| a == b),
            VOp::LtS => map2(x[0], x[1], |a, b| (a as i8) < (b as i8)),
            VOp::Msb => lanes(x[0]).iter().enumerate().fold(0, |m, (i, &c)| m | ((c >> 7) as u128) << i),
            VOp::Half(n) => (x[0] >> (64 * n as u32)) as u64 as u128,
            VOp::Pair => x[0] as u64 as u128 | (x[1] as u64 as u128) << 64,
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Op {
    /// `a op b` (at 16 bytes only `And`, `Or` and `Xor`).
    Bin(BinOp, u8),
    /// `a cc b`: a boolean.
    Cmp(Cc, u8),
    /// `a op b` (`Add`, `Sub` or `Mul`) at `w` bytes, signed or not, and whether it
    /// overflowed (a boolean).
    Ovf(BinOp, bool, u8),
    /// `a` with its `w` (2, 4 or 8) bytes reversed.
    Bswap(u8),
    /// `a <=> b` at `w` bytes, signed or not: -1, 0 or 1, 1 byte.
    Cmp3(bool, u8),
    /// A dense switch's index (`switch.dense`): `i = a - base` at `w` bytes (wrapping), or
    /// `n`, the default's, if `i` isn't below `n`: 8 bytes.
    SwitchIdx {
        w: u8,
        base: u64,
        n: u32,
    },
    /// The trailing (leading with `lz`) zero bits of `a`'s `w` bytes, the width in bits for 0:
    /// 4 bytes.
    Count {
        lz: bool,
        w: u8,
    },
    /// `a` (`from` bytes) zero- or sign-extended (`sx`), or truncated, to `to` bytes.
    Ext {
        from: u8,
        to: u8,
        sx: bool,
    },
    /// `p + k`.
    PtrAdd(i64),
    /// `p + i * stride` (wrapping).
    PtrIndex(u32),
    /// A rip-relative address: of a constant or data area allocation (`lea`), or the value of
    /// a symbol slot (`mov [rip + slot]`), and with `ind` the pointer that one points at. The
    /// slots are filled before any VM code runs, so it is pure.
    RefAddr(Ref, bool),
    /// The address of byte `k` of the alloca (its provenance).
    AllocaAddr(AllocaId, i32),
    /// A vector operation (pure).
    V(VOp),
    /// A 16-byte constant (pure): one a [`ValueDef::Const`] can't be.
    VConst(u128),
    /// `w` bytes at `[p + k]`.
    Load(u8, i32),
    /// `[p + k] = v` (`w` bytes).
    Store(u8, i32),
    /// `w` bytes at byte `k` of a memory alloca.
    ALoad(AllocaId, i32, u8),
    /// The low `n` bytes (1 to 8) of the value to byte `k` of a memory alloca.
    AStore(AllocaId, i32, u8),
    /// In an OSR entry block: `w` bytes of the AOT frame at `fp + off`.
    OsrLoad(i32, u8),
    /// At a landing pad stub: the exception object (`rax`).
    LandingPad,
    HCall(Box<HCall>),
    Call(Box<Call>),
    Island(Box<Island>),
}

impl Op {
    /// The allocas a handler call's frame operands or an island's operands name.
    pub fn named_allocas(&self) -> impl Iterator<Item = AllocaId> + '_ {
        let (h, isl) = match self {
            Op::HCall(h) => (Some(h), None),
            Op::Island(x) => (None, Some(x)),
            _ => (None, None),
        };
        h.into_iter().flat_map(|h| h.allocas()).chain(isl.into_iter().flat_map(|x| x.ops.iter().filter_map(SlotRef::alloca)))
    }

    /// The result of a pure single-result operation on the constant operands `x`, unmasked
    /// to the result's width; `None` for any other operation.
    pub fn fold(&self, x: &[u64]) -> Option<u64> {
        Some(match *self {
            Op::Bin(o, w) => o.eval(w, x[0], x[1]),
            Op::Cmp(cc, w) => cc.holds(w, x[0], x[1]) as u64,
            Op::Bswap(w) => mask(x[0], w).swap_bytes() >> (64 - 8 * w as u32),
            Op::Cmp3(signed, w) => {
                let (lt, gt) = if signed { (Cc::LtS, Cc::GtS) } else { (Cc::LtU, Cc::GtU) };
                mask((gt.holds(w, x[0], x[1]) as u64).wrapping_sub(lt.holds(w, x[0], x[1]) as u64), 1)
            }
            Op::SwitchIdx { w, base, n } => mask(x[0].wrapping_sub(base), w).min(n as u64),
            Op::Count { lz, w } => {
                let (a, n) = (mask(x[0], w), 8 * w as u32);
                (if a == 0 {
                    n
                } else if lz {
                    a.leading_zeros() - (64 - n)
                } else {
                    a.trailing_zeros()
                }) as u64
            }
            Op::Ext { from, to, sx } => {
                let x = mask(x[0], from);
                mask(if sx { sext(x, from) as u64 } else { x }, to)
            }
            Op::PtrAdd(k) => x[0].wrapping_add(k as u64),
            Op::PtrIndex(s) => x[0].wrapping_add(x[1].wrapping_mul(s as u64)),
            // A vector result only when it is a constant's (its high half zero).
            Op::V(o) => {
                let xs: Vec<u128> = x.iter().map(|&c| c as u128).collect();
                let r = o.eval(&xs);
                u64::try_from(r).ok()?
            }
            _ => return None,
        })
    }

    /// Whether it has no effect but its result: dropped when the result is unused.
    pub fn pure(&self) -> bool {
        matches!(
            self,
            Op::Bin(..)
                | Op::V(_)
                | Op::VConst(_)
                | Op::Cmp(..)
                | Op::Bswap(_)
                | Op::Count { .. }
                | Op::SwitchIdx { .. }
                | Op::Cmp3(..)
                | Op::Ovf(..)
                | Op::Ext { .. }
                | Op::PtrAdd(_)
                | Op::PtrIndex(_)
                | Op::AllocaAddr(..)
                | Op::RefAddr(..)
                | Op::OsrLoad(..)
        )
    }

    /// Whether it calls something: every caller-saved register is clobbered.
    pub fn is_call(&self) -> bool {
        matches!(self, Op::HCall(_) | Op::Call(_) | Op::Island(_))
    }

    pub fn site(&self) -> Site {
        match self {
            Op::HCall(h) => h.site,
            Op::Call(c) => c.site,
            Op::Island(i) => i.site,
            _ => Site::None,
        }
    }
}

#[derive(Clone, Debug)]
pub struct InstData {
    pub op: Op,
    pub args: Vec<Value>,
    /// The results are `res .. res + nres`.
    pub res: u32,
    pub nres: u8,
    pub block: Block,
}

impl InstData {
    /// The first two operands, [`Value::NONE`] for missing ones.
    pub fn args2(&self) -> [Value; 2] {
        let a = |n: usize| self.args.get(n).copied().unwrap_or(Value::NONE);
        [a(0), a(1)]
    }

    pub fn results(&self) -> impl Iterator<Item = Value> + use<> {
        (self.res..self.res + self.nres as u32).map(Value)
    }
}

/// A control transfer to `to`, passing `args` to its parameters.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Edge {
    pub to: Block,
    pub args: Vec<Value>,
}

impl Edge {
    pub fn to(to: Block) -> Edge {
        Edge { to, args: Vec::new() }
    }
}

#[derive(Clone, Debug)]
pub enum Term {
    /// Not built yet.
    None,
    Jmp(Edge),
    /// To `t` if the boolean `cond` is true (nonzero), else `f`.
    Br {
        cond: Value,
        t: Edge,
        f: Edge,
    },
    /// To `t` if the block's last instruction, an [`Op::Ovf`], overflowed, else `f`: the
    /// branch on its flag, fused.
    BrOvf {
        t: Edge,
        f: Edge,
    },
    /// To `t` if `a cc b` (at width `w`), else `f`.
    BrCmp {
        cc: Cc,
        w: u8,
        a: Value,
        b: Value,
        t: Edge,
        f: Edge,
    },
    /// To `targets[idx]`; `idx` is less than their count.
    Switch {
        idx: Value,
        targets: Vec<Edge>,
    },
    /// The return parts, of kind `k` (load widths).
    Ret {
        k: u32,
        parts: Vec<Value>,
    },
    TailCall {
        call: Box<Call>,
        args: Vec<Value>,
    },
    /// `ud2`: after a handler that doesn't return.
    Trap,
    /// The block's last instruction, a call with a landing pad: on return to `normal` (none
    /// after a handler that doesn't return), on unwinding to `pad`, a stub block that starts
    /// with [`Op::LandingPad`].
    Invoke {
        normal: Option<Edge>,
        pad: Edge,
    },
}

impl Term {
    /// Its edges, in order (without allocating).
    pub fn edges(&self) -> Edges<'_> {
        let (two, rest): ([Option<&Edge>; 2], &[Edge]) = match self {
            Term::None | Term::Ret { .. } | Term::TailCall { .. } | Term::Trap => ([None, None], &[]),
            Term::Jmp(e) => ([Some(e), None], &[]),
            Term::Br { t, f, .. } | Term::BrCmp { t, f, .. } | Term::BrOvf { t, f } => ([Some(t), Some(f)], &[]),
            Term::Switch { targets, .. } => ([None, None], targets),
            Term::Invoke { normal, pad } => ([normal.as_ref(), Some(pad)], &[]),
        };
        Edges { two: two.into_iter().flatten(), rest: rest.iter() }
    }

    pub fn edges_mut(&mut self) -> EdgesMut<'_> {
        let (two, rest): ([Option<&mut Edge>; 2], &mut [Edge]) = match self {
            Term::None | Term::Ret { .. } | Term::TailCall { .. } | Term::Trap => ([None, None], &mut []),
            Term::Jmp(e) => ([Some(e), None], &mut []),
            Term::Br { t, f, .. } | Term::BrCmp { t, f, .. } | Term::BrOvf { t, f } => ([Some(t), Some(f)], &mut []),
            Term::Switch { targets, .. } => ([None, None], targets),
            Term::Invoke { normal, pad } => ([normal.as_mut(), Some(pad)], &mut []),
        };
        EdgesMut { two: two.into_iter().flatten(), rest: rest.iter_mut() }
    }

    /// Edge `k` ([`Term::edges`] order).
    pub fn edge(&self, k: usize) -> &Edge {
        self.edges().nth(k).unwrap_or_else(|| panic!("no edge {k}"))
    }

    pub fn edge_mut(&mut self, k: usize) -> &mut Edge {
        self.edges_mut().nth(k).unwrap_or_else(|| panic!("no edge {k}"))
    }

    /// The values it reads, but for its edges' arguments.
    pub fn uses(&self) -> Vec<Value> {
        match self {
            Term::Br { cond, .. } => alloc::vec![*cond],
            Term::BrCmp { a, b, .. } => alloc::vec![*a, *b],
            Term::Switch { idx, .. } => alloc::vec![*idx],
            Term::Ret { parts, .. } => parts.clone(),
            Term::TailCall { args, .. } => args.clone(),
            _ => Vec::new(),
        }
    }

    pub fn uses_mut(&mut self) -> Vec<&mut Value> {
        match self {
            Term::Br { cond, .. } => alloc::vec![cond],
            Term::BrCmp { a, b, .. } => alloc::vec![a, b],
            Term::Switch { idx, .. } => alloc::vec![idx],
            Term::Ret { parts, .. } => parts.iter_mut().collect(),
            Term::TailCall { args, .. } => args.iter_mut().collect(),
            _ => Vec::new(),
        }
    }
}

/// [`Term::edges`]: up to two edges held directly, then a switch's table.
#[derive(Clone)]
pub struct Edges<'a> {
    two: core::iter::Flatten<core::array::IntoIter<Option<&'a Edge>, 2>>,
    rest: core::slice::Iter<'a, Edge>,
}

impl<'a> Iterator for Edges<'a> {
    type Item = &'a Edge;
    fn next(&mut self) -> Option<&'a Edge> {
        self.two.next().or_else(|| self.rest.next())
    }
    fn size_hint(&self) -> (usize, Option<usize>) {
        let n = self.clone().two.count() + self.rest.len();
        (n, Some(n))
    }
}

impl ExactSizeIterator for Edges<'_> {}

impl Edges<'_> {
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}

/// [`Term::edges_mut`].
pub struct EdgesMut<'a> {
    two: core::iter::Flatten<core::array::IntoIter<Option<&'a mut Edge>, 2>>,
    rest: core::slice::IterMut<'a, Edge>,
}

impl<'a> Iterator for EdgesMut<'a> {
    type Item = &'a mut Edge;
    fn next(&mut self) -> Option<&'a mut Edge> {
        self.two.next().or_else(|| self.rest.next())
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum BlockKind {
    /// The function's entry: its parameters are the `arg` registers ([`Func::entry_regs`]).
    Entry,
    Body,
    /// The OSR entry of AOT loop head `n` ([`crate::asm::Decoded::heads`]): no predecessors.
    Osr(u32),
    /// A landing pad stub, one per call site.
    Stub,
}

#[derive(Clone, Debug)]
pub struct BlockData {
    pub params: Vec<Value>,
    pub insts: Vec<Inst>,
    pub term: Term,
    /// The predecessors, each with the index of its edge here ([`Term::edges`]).
    pub preds: Vec<(Block, u16)>,
    pub kind: BlockKind,
    /// The AOT loop head this block starts at, if any.
    pub head: Option<u32>,
    /// Off the hot path ([`super::opt::layout`]): laid out after the hot blocks.
    pub cold: bool,
}

/// What an alloca is.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum AllocaKind {
    /// Its fields are SSA values: it has no memory.
    Promoted,
    /// Memory the JIT places.
    Memory,
    /// The stack arguments of the calls: memory at the bottom of the frame (`rsp` up).
    Outgoing,
    /// The caller's argument area (positive offsets): memory at its fixed place.
    Incoming,
}

/// A byte range of the AOT frame that no access crosses ([`crate::jit`]).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Alloca {
    /// Its first byte's offset from `fp` in the AOT frame.
    pub aot_off: i32,
    pub size: u32,
    pub kind: AllocaKind,
    /// It may be escaped at an OSR entry: it keeps its AOT offset.
    pub pinned: bool,
    /// Some pointer reaches it (an escape covers it).
    pub escaped: bool,
    /// It comes from an inlined callee's frame ([`super::inline`]): `aot_off` is an offset in
    /// that frame, not in the AOT frame OSR entries convert.
    pub inlined: bool,
}

#[derive(Clone, Debug, Default)]
pub struct Func {
    pub values: Vec<ValueData>,
    pub insts: Vec<InstData>,
    pub blocks: Vec<BlockData>,
    pub allocas: Vec<Alloca>,
    /// The entry block's parameters' registers.
    pub entry_regs: Vec<ArgReg>,
    /// PE code: the arguments take the Win64 registers.
    pub pe: bool,
    /// By AOT loop head, its OSR entry block.
    pub osr: Vec<Option<Block>>,
    /// The AOT frame size.
    pub aot_frame: u32,
    /// The handler scratch area's size.
    pub scratch: u32,
    /// The blocks in emission order (all but the OSR entries).
    pub layout: Vec<Block>,
}

impl Func {
    /// The index of the entry block, if any.
    pub fn entry(&self) -> Option<usize> {
        self.blocks.iter().position(|b| b.kind == BlockKind::Entry)
    }

    /// The blocks that can run: the layout and the OSR entries.
    pub fn live_blocks(&self) -> Vec<Block> {
        let mut v = self.layout.clone();
        v.extend(self.osr.iter().flatten().copied());
        v
    }

    /// Recomputes every block's predecessors from the terminators of the blocks that can run,
    /// in block order.
    pub fn rebuild_preds(&mut self) {
        for bd in &mut self.blocks {
            bd.preds.clear();
        }
        let mut live = self.live_blocks();
        live.sort_unstable();
        for b in live {
            let tos: Vec<Block> = self.blocks[b.idx()].term.edges().map(|e| e.to).collect();
            for (k, to) in tos.into_iter().enumerate() {
                self.blocks[to.idx()].preds.push((b, k as u16));
            }
        }
    }

    /// Drops the blocks not reachable from the entry and the OSR entries (and, with
    /// `keep_stubs`, from any landing pad stub): they are emptied, trap, have no parameters
    /// or predecessors, aren't stubs, and leave the layout. The reachable blocks lose the
    /// predecessors that were dropped.
    pub fn prune(&mut self, keep_stubs: bool) {
        let n = self.blocks.len();
        let mut seen = alloc::vec![false; n];
        let mut stack: Vec<usize> = (0..n)
            .filter(|&b| match self.blocks[b].kind {
                BlockKind::Entry | BlockKind::Osr(_) => true,
                BlockKind::Stub => keep_stubs,
                _ => false,
            })
            .collect();
        while let Some(b) = stack.pop() {
            if core::mem::replace(&mut seen[b], true) {
                continue;
            }
            stack.extend(self.blocks[b].term.edges().map(|e| e.to.idx()));
        }
        for (b, bd) in self.blocks.iter_mut().enumerate() {
            if seen[b] {
                bd.preds.retain(|&(p, _)| seen[p.idx()]);
            } else {
                bd.insts.clear();
                bd.params.clear();
                bd.preds.clear();
                bd.term = Term::Trap;
                if bd.kind == BlockKind::Stub {
                    bd.kind = BlockKind::Body;
                }
            }
        }
        self.layout.retain(|b| seen[b.idx()]);
    }

    pub fn value(&mut self, def: ValueDef, w: u8) -> Value {
        debug_assert!(matches!(w, 1 | 2 | 4 | 8 | 16), "width {w}");
        self.values.push(ValueData { def, w });
        Value(self.values.len() as u32 - 1)
    }

    pub fn konst(&mut self, bits: u64, w: u8) -> Value {
        self.value(ValueDef::Const(bits), w)
    }

    /// Makes `v` an alias of the constant `c`, masked to `v`'s width.
    pub fn alias_const(&mut self, v: Value, c: u64) {
        let w = self.w(v);
        let k = self.konst(mask(c, w), w);
        self.values[v.idx()].def = ValueDef::Alias(k);
    }

    pub fn block(&mut self, kind: BlockKind) -> Block {
        self.blocks.push(BlockData { params: Vec::new(), insts: Vec::new(), term: Term::None, preds: Vec::new(), kind, head: None, cold: false });
        Block(self.blocks.len() as u32 - 1)
    }

    /// Appends an instruction with results of widths `ws` to `b`.
    pub fn inst(&mut self, b: Block, op: Op, args: Vec<Value>, ws: &[u8]) -> Inst {
        let i = Inst(self.insts.len() as u32);
        let res = self.values.len() as u32;
        for (n, &w) in ws.iter().enumerate() {
            self.value(ValueDef::Inst(i, n as u8), w);
        }
        self.insts.push(InstData { op, args, res, nres: ws.len() as u8, block: b });
        self.blocks[b.idx()].insts.push(i);
        i
    }

    /// The single result of `i`.
    pub fn result(&self, i: Inst) -> Value {
        debug_assert_eq!(self.insts[i.idx()].nres, 1);
        Value(self.insts[i.idx()].res)
    }

    pub fn param(&mut self, b: Block, w: u8) -> Value {
        let n = self.blocks[b.idx()].params.len() as u16;
        let v = self.value(ValueDef::Param(b, n), w);
        self.blocks[b.idx()].params.push(v);
        v
    }

    pub fn w(&self, v: Value) -> u8 {
        self.values[v.idx()].w
    }

    pub fn def(&self, v: Value) -> ValueDef {
        self.values[v.idx()].def
    }

    /// Follows aliases.
    pub fn resolve(&self, mut v: Value) -> Value {
        while let ValueDef::Alias(a) = self.values[v.idx()].def {
            v = a;
        }
        v
    }

    /// Sets the terminator of `b` and records it as its successors' predecessor.
    pub fn terminate(&mut self, b: Block, t: Term) {
        for (k, e) in t.edges().enumerate() {
            self.blocks[e.to.idx()].preds.push((b, k as u16));
        }
        self.blocks[b.idx()].term = t;
    }

    /// Replaces the terminator of `b` by `t`, keeping its successors' predecessor lists right.
    pub fn set_term(&mut self, b: Block, t: Term) {
        for e in self.blocks[b.idx()].term.edges().map(|e| e.to).collect::<Vec<_>>() {
            self.blocks[e.idx()].preds.retain(|&(p, _)| p != b);
        }
        self.blocks[b.idx()].term = Term::None;
        self.terminate(b, t);
    }

    /// Replaces every use of an alias by its target, and drops the block parameters that are
    /// aliases with their edges' arguments.
    pub fn resolve_aliases(&mut self) {
        for k in 0..self.insts.len() {
            for a in 0..self.insts[k].args.len() {
                self.insts[k].args[a] = self.resolve(self.insts[k].args[a]);
            }
        }
        for b in 0..self.blocks.len() {
            let mut t = core::mem::replace(&mut self.blocks[b].term, Term::None);
            for u in t.uses_mut() {
                *u = self.resolve(*u);
            }
            for e in t.edges_mut() {
                for a in e.args.iter_mut() {
                    *a = self.resolve(*a);
                }
            }
            self.blocks[b].term = t;
        }
        // Parameters: keep the live ones, renumbered, and their arguments.
        for b in 0..self.blocks.len() {
            let keep: Vec<bool> = self.blocks[b].params.iter().map(|&p| !matches!(self.values[p.idx()].def, ValueDef::Alias(_))).collect();
            if keep.iter().all(|&k| k) {
                continue;
            }
            let params: Vec<Value> = self.blocks[b].params.iter().zip(&keep).filter(|(_, k)| **k).map(|(&p, _)| p).collect();
            for (n, &p) in params.iter().enumerate() {
                self.values[p.idx()].def = ValueDef::Param(Block(b as u32), n as u16);
            }
            self.blocks[b].params = params;
            let preds = self.blocks[b].preds.clone();
            for (p, k) in preds {
                let mut t = core::mem::replace(&mut self.blocks[p.idx()].term, Term::None);
                let e = t.edges_mut().into_iter().nth(k as usize).expect("an edge");
                debug_assert_eq!(e.args.len(), keep.len());
                let args = e.args.iter().zip(&keep).filter(|(_, k)| **k).map(|(&a, _)| a).collect();
                e.args = args;
                self.blocks[p.idx()].term = t;
            }
        }
    }

    /// The blocks in reverse postorder from the entry and the OSR entries.
    pub fn rpo(&self) -> Vec<Block> {
        let n = self.blocks.len();
        let mut seen = alloc::vec![false; n];
        let mut post = Vec::with_capacity(n);
        let roots = (0..n).filter(|&b| self.blocks[b].preds.is_empty());
        for r in roots {
            if seen[r] {
                continue;
            }
            seen[r] = true;
            let mut stack: Vec<(usize, usize)> = alloc::vec![(r, 0)];
            while let Some(&mut (b, ref mut k)) = stack.last_mut() {
                if let Some(e) = self.blocks[b].term.edges().nth(*k) {
                    let s = e.to.idx();
                    *k += 1;
                    if !seen[s] {
                        seen[s] = true;
                        stack.push((s, 0));
                    }
                } else {
                    post.push(Block(b as u32));
                    stack.pop();
                }
            }
        }
        post.reverse();
        post
    }

    /// The immediate dominators (Cooper, Harvey, Kennedy), with a virtual root above the
    /// entry and the OSR entries: `None` for those and for unreachable blocks.
    pub fn idoms(&self, rpo: &[Block]) -> Vec<Option<Block>> {
        self.idoms_by(rpo, |_| true)
    }

    /// [`Func::idoms`] counting only the edges from the predecessors `keep` accepts.
    pub fn idoms_by(&self, rpo: &[Block], keep: impl Fn(Block) -> bool) -> Vec<Option<Block>> {
        let n = self.blocks.len();
        const ROOT: u32 = u32::MAX;
        let mut order = alloc::vec![u32::MAX; n];
        for (i, b) in rpo.iter().enumerate() {
            order[b.idx()] = i as u32;
        }
        let mut idom: Vec<u32> = alloc::vec![u32::MAX - 1; n];
        for &b in rpo {
            if self.blocks[b.idx()].preds.is_empty() {
                idom[b.idx()] = ROOT;
            }
        }
        let intersect = |idom: &[u32], mut a: u32, mut b: u32| -> u32 {
            while a != b {
                if a == ROOT || b == ROOT {
                    return ROOT;
                }
                while order[a as usize] > order[b as usize] {
                    a = idom[a as usize];
                    if a == ROOT {
                        return ROOT;
                    }
                }
                while order[b as usize] > order[a as usize] {
                    b = idom[b as usize];
                    if b == ROOT {
                        return ROOT;
                    }
                }
            }
            a
        };
        let mut changed = true;
        while changed {
            changed = false;
            for &b in rpo {
                if self.blocks[b.idx()].preds.is_empty() {
                    continue;
                }
                let mut new = u32::MAX - 1;
                for &(p, _) in &self.blocks[b.idx()].preds {
                    if idom[p.idx()] == u32::MAX - 1 || !keep(p) {
                        continue;
                    }
                    new = if new == u32::MAX - 1 { p.0 } else { intersect(&idom, new, p.0) };
                }
                if new != idom[b.idx()] {
                    idom[b.idx()] = new;
                    changed = true;
                }
            }
        }
        idom.into_iter().map(|d| if d >= u32::MAX - 1 { None } else { Some(Block(d)) }).collect()
    }

    /// Checks the IR: every operand defined (no aliases), defined before its use in its
    /// block or in a dominating block, edges passing as many arguments as their targets take,
    /// widths that fit their uses, and every block terminated. A description of the first
    /// problem.
    pub fn verify(&self) -> Result<(), alloc::string::String> {
        use alloc::format;
        let rpo = self.rpo();
        let idom = self.idoms(&rpo);
        let mut pos = alloc::vec![(u32::MAX, u32::MAX); self.values.len()];
        for b in &rpo {
            let bd = &self.blocks[b.idx()];
            for &p in &bd.params {
                pos[p.idx()] = (b.0, 0);
            }
            for (k, &i) in bd.insts.iter().enumerate() {
                for r in self.insts[i.idx()].results() {
                    pos[r.idx()] = (b.0, k as u32 + 1);
                }
            }
        }
        let dominates = |a: Block, mut b: Block| -> bool {
            loop {
                if a == b {
                    return true;
                }
                match idom[b.idx()] {
                    Some(d) => b = d,
                    None => return false,
                }
            }
        };
        let check = |v: Value, b: Block, at: u32, w: u8| -> Result<(), alloc::string::String> {
            let d = self.values.get(v.idx()).ok_or_else(|| format!("{v} out of range"))?;
            match d.def {
                ValueDef::Alias(_) => return Err(format!("{v} is an alias, used in {b}")),
                ValueDef::Const(_) | ValueDef::Undef => return Ok(()),
                _ => {}
            }
            if d.w < w || (d.w == 16) != (w == 16) {
                return Err(format!("{v} is {} bytes, used at {w} in {b}", d.w));
            }
            let (db, dk) = pos[v.idx()];
            if db == u32::MAX {
                return Err(format!("{v} used in {b} isn't defined in a reachable block"));
            }
            if (db == b.0 && dk >= at) || (db != b.0 && !dominates(Block(db), b)) {
                return Err(format!("{v} used in {b} doesn't dominate its use"));
            }
            Ok(())
        };
        for &b in &rpo {
            let bd = &self.blocks[b.idx()];
            for (k, &i) in bd.insts.iter().enumerate() {
                let id = &self.insts[i.idx()];
                let ws = self.arg_widths(id);
                if ws.len() != id.args.len() {
                    return Err(format!("{i} in {b}: {} arguments, wants {}", id.args.len(), ws.len()));
                }
                for (&a, &w) in id.args.iter().zip(&ws) {
                    check(a, b, k as u32 + 1, w)?;
                }
                let rw: &[u8] = match id.op {
                    Op::V(o) => &[o.widths().1],
                    Op::VConst(_) => &[16],
                    _ => &[],
                };
                if !rw.is_empty() && (id.nres != 1 || self.w(Value(id.res)) != rw[0]) {
                    return Err(format!("{i} in {b}: a result of the wrong width"));
                }
                if let Op::Bin(o, 16) = id.op
                    && !matches!(o, BinOp::And | BinOp::Or | BinOp::Xor)
                {
                    return Err(format!("{i} in {b}: {o:?} at 16 bytes"));
                }
            }
            let end = bd.insts.len() as u32 + 1;
            if matches!(bd.term, Term::None) {
                return Err(format!("{b} has no terminator"));
            }
            for u in bd.term.uses() {
                check(u, b, end, 1)?;
            }
            if let Term::BrOvf { .. } = bd.term
                && !matches!(bd.insts.last().map(|i| &self.insts[i.idx()].op), Some(Op::Ovf(..)))
            {
                return Err(format!("{b} branches on an overflow, but its last instruction isn't an overflow op"));
            }
            if let Term::Invoke { .. } = bd.term {
                let last = bd.insts.last().map(|i| self.insts[i.idx()].op.site());
                if !matches!(last, Some(Site::Pad { .. })) {
                    return Err(format!("{b} invokes, but its last instruction has no landing pad"));
                }
            }
            for e in bd.term.edges() {
                let tp = &self.blocks[e.to.idx()].params;
                if tp.len() != e.args.len() {
                    return Err(format!("{b} -> {}: {} arguments for {} parameters", e.to, e.args.len(), tp.len()));
                }
                for (&a, &p) in e.args.iter().zip(tp) {
                    check(a, b, end, self.w(p))?;
                }
            }
        }
        Ok(())
    }

    /// The widths an instruction reads its arguments at.
    pub fn arg_widths(&self, id: &InstData) -> Vec<u8> {
        match &id.op {
            Op::Bin(_, w) | Op::Cmp(_, w) | Op::Ovf(_, _, w) | Op::Cmp3(_, w) => alloc::vec![*w, *w],
            Op::Bswap(w) | Op::Count { w, .. } | Op::SwitchIdx { w, .. } => alloc::vec![*w],
            Op::V(o) => o.widths().0.to_vec(),
            Op::VConst(_) => Vec::new(),
            Op::Ext { from, .. } => alloc::vec![*from],
            Op::PtrAdd(_) => alloc::vec![8],
            Op::PtrIndex(_) => alloc::vec![8, 8],
            Op::AllocaAddr(..) | Op::RefAddr(..) | Op::ALoad(..) | Op::OsrLoad(..) | Op::LandingPad | Op::Island(_) => Vec::new(),
            Op::Load(..) => alloc::vec![8],
            Op::Store(w, _) => alloc::vec![8, *w],
            Op::AStore(_, _, n) => alloc::vec![if n.is_power_of_two() { *n } else { 8 }],
            Op::HCall(_) => id.args.iter().map(|_| 1).collect(),
            Op::Call(c) => {
                let mut v: Vec<u8> = Vec::new();
                if c.target == CallTarget::Ptr {
                    v.push(8);
                }
                v.extend(c.regs.iter().map(|r| r.size.min(8) as u8));
                v
            }
        }
    }
}

/// `v`'s low `w` bytes.
pub fn mask(v: u64, w: u8) -> u64 {
    if w >= 8 { v } else { v & ((1u64 << (8 * w)) - 1) }
}

/// `v`'s low `w` bytes, sign-extended (`v` itself for `w >= 8`).
pub fn sext(v: u64, w: u8) -> i64 {
    if w >= 8 {
        return v as i64;
    }
    let s = 64 - 8 * w as u32;
    ((v << s) as i64) >> s
}

/// How many times each value is used (by instructions, terminators and edges).
pub fn use_counts(f: &Func) -> Vec<u32> {
    let mut n = alloc::vec![0u32; f.values.len()];
    for b in &f.blocks {
        for &i in &b.insts {
            for &a in &f.insts[i.idx()].args {
                n[a.idx()] += 1;
            }
        }
        for u in b.term.uses() {
            n[u.idx()] += 1;
        }
        for e in b.term.edges() {
            for a in &e.args {
                n[a.idx()] += 1;
            }
        }
    }
    n
}

impl fmt::Display for Func {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let v = |x: Value| -> alloc::string::String {
            match self.values[x.idx()].def {
                ValueDef::Const(c) => alloc::format!("{c:#x}"),
                ValueDef::Undef => "undef".into(),
                _ => alloc::format!("{x}"),
            }
        };
        let list = |xs: &[Value]| xs.iter().map(|&x| v(x)).collect::<Vec<_>>().join(", ");
        let edge = |e: &Edge| alloc::format!("{}({})", e.to, list(&e.args));
        for (k, a) in self.allocas.iter().enumerate() {
            writeln!(
                f,
                "a{k}: ${}, {} bytes, {:?}{}{}{}",
                a.aot_off,
                a.size,
                a.kind,
                if a.pinned { ", pinned" } else { "" },
                if a.escaped { ", escaped" } else { "" },
                if a.inlined { ", inlined" } else { "" }
            )?;
        }
        for (b, bd) in self.blocks.iter().enumerate() {
            let ps: Vec<_> = bd.params.iter().map(|&p| alloc::format!("{p}:{}", self.w(p))).collect();
            write!(f, "b{b}({}): ; {:?}", ps.join(", "), bd.kind)?;
            if let Some(h) = bd.head {
                write!(f, " head {h}")?;
            }
            if bd.cold {
                write!(f, " cold")?;
            }
            writeln!(f)?;
            for &i in &bd.insts {
                let id = &self.insts[i.idx()];
                let rs: Vec<_> = id.results().map(|r| alloc::format!("{r}:{}", self.w(r))).collect();
                if !rs.is_empty() {
                    write!(f, "    {} = ", rs.join(", "))?;
                } else {
                    write!(f, "    ")?;
                }
                match &id.op {
                    Op::HCall(h) => {
                        if h.reg {
                            write!(f, "hcall.reg {} {:?} outs {}{}", h.h.mnemonic(), h.regs, h.nout, if h.ret { " ret" } else { "" })?
                        } else {
                            write!(f, "hcall {} {:?} ins {:?} outs {:?}{}", h.h.mnemonic(), h.regs, h.ins, h.outs, if h.ret { " ret" } else { "" })?
                        }
                    }
                    op => write!(f, "{op:?}")?,
                }
                writeln!(f, " ({})", list(&id.args))?;
            }
            match &bd.term {
                Term::None => writeln!(f, "    <none>")?,
                Term::Jmp(e) => writeln!(f, "    jmp {}", edge(e))?,
                Term::Br { cond, t, f: e } => writeln!(f, "    br {} ? {} : {}", v(*cond), edge(t), edge(e))?,
                Term::BrOvf { t, f: e } => writeln!(f, "    br ovf ? {} : {}", edge(t), edge(e))?,
                Term::BrCmp { cc, w, a, b, t, f: e } => writeln!(f, "    br {cc:?}.w{w} {}, {} ? {} : {}", v(*a), v(*b), edge(t), edge(e))?,
                Term::Switch { idx, targets } => writeln!(f, "    switch {} [{}]", v(*idx), targets.iter().map(edge).collect::<Vec<_>>().join(", "))?,
                Term::Ret { k, parts } => writeln!(f, "    ret {k:#x} ({})", list(parts))?,
                Term::TailCall { call, args } => writeln!(f, "    tail_call {:?} ({})", call.target, list(args))?,
                Term::Trap => writeln!(f, "    trap")?,
                Term::Invoke { normal, pad } => writeln!(f, "    invoke -> {} unwind {}", normal.as_ref().map_or("-".into(), edge), edge(pad))?,
            }
        }
        Ok(())
    }
}
