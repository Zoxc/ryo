//! The canonical machine-code elements of VM code: every [`Item`] has exactly one encoding,
//! and [`read`] accepts only that one. Immediates take their shortest form; padding is the
//! standard multi-byte `nop`s.

use alloc::vec::Vec;

use super::decode::Resolver;
use super::encode::{Ref, Reloc};

/// A fieldless `#[repr(u8)]` enum whose discriminants are x86 numbers, with `from_num`, the
/// inverse of `as u8`.
macro_rules! numbered {
    ($(#[$m:meta])* pub enum $t:ident { $($(#[$vm:meta])* $v:ident = $n:literal,)* }) => {
        $(#[$m])*
        #[repr(u8)]
        pub enum $t {
            $($(#[$vm])* $v = $n,)*
        }

        impl $t {
            pub(super) fn from_num(n: u8) -> Option<$t> {
                match n {
                    $($n => Some($t::$v),)*
                    _ => None,
                }
            }
        }
    };
}

numbered! {
/// The general-purpose registers the encoder uses, by their x86 number.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Reg {
    Rax = 0,
    Rcx = 1,
    Rdx = 2,
    Rsp = 4,
    Rbp = 5,
    Rsi = 6,
    Rdi = 7,
    R8 = 8,
    R9 = 9,
    R10 = 10,
    R11 = 11,
}
}

impl Reg {
    fn low(self) -> u8 {
        self as u8 & 7
    }

    fn ext(self) -> bool {
        self as u8 >= 8
    }
}

/// The register of a handler call's argument position `i` ([`super::handler_arg`]), `None`
/// for PE's stack position.
pub fn handler_reg(pe: bool, i: u8) -> Option<Reg> {
    match super::handler_arg(pe, i) {
        super::HandlerArg::Reg(n) => Reg::from_num(n),
        super::HandlerArg::Stack => None,
    }
}

/// PE: a handler call's stack argument ([`super::HandlerArg::Stack`]): the `dword` at
/// `[rsp + 32]`, past the shadow space.
pub const STACK_ARG: M = M { base: Reg::Rsp, disp: 32 };

/// The island argument registers (`fp`, `ops`): the Rust ABI, `sysv64` or Win64.
pub const fn island_args(pe: bool) -> [Reg; 2] {
    if pe { [Reg::Rcx, Reg::Rdx] } else { [Reg::Rdi, Reg::Rsi] }
}

numbered! {
/// A branch condition, on the flags of the `test` or `cmp` before it, by its x86 condition
/// code (`jcc rel8` is `0x70 | cc`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cond {
    /// No condition (`jmp`): not a condition code.
    Always = 0x10,
    /// `jz`: the value tested was zero (false), or the compared values are equal.
    Z = 0x4,
    /// `jnz`.
    Nz = 0x5,
    /// Signed `<`, `>=`, `<=`, `>` (`jl`, `jge`, `jle`, `jg`).
    L = 0xc,
    Ge = 0xd,
    Le = 0xe,
    G = 0xf,
    /// Unsigned `<`, `>=`, `<=`, `>` (`jb`, `jae`, `jbe`, `ja`).
    B = 0x2,
    Ae = 0x3,
    Be = 0x6,
    A = 0x7,
    /// `js`, `jns`: the result was negative (a counter ran out).
    S = 0x8,
    Ns = 0x9,
    /// `jo`, `jno`: signed overflow.
    O = 0x0,
    No = 0x1,
}
}

impl Cond {
    /// The x86 condition code (`jcc rel8` is `0x70 | cc`).
    fn cc(self) -> u8 {
        assert!(self != Cond::Always, "no condition code");
        self as u8
    }

    /// The condition of x86 condition code `cc` (0 to 15).
    fn from_cc(cc: u8) -> Option<Cond> {
        Cond::from_num(cc).filter(|&c| c != Cond::Always)
    }

    /// The opposite condition.
    pub fn not(self) -> Cond {
        Cond::from_cc(self.cc() ^ 1).unwrap()
    }
}

/// The operand size of a native instruction: 8, 16, 32 or 64 bits.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum W {
    B,
    W,
    D,
    Q,
}

impl W {
    /// The width of `n` bytes, if 1, 2, 4 or 8.
    pub fn from_bytes(n: u32) -> Option<W> {
        match n {
            1 => Some(W::B),
            2 => Some(W::W),
            4 => Some(W::D),
            8 => Some(W::Q),
            _ => None,
        }
    }

    pub fn bytes(self) -> u32 {
        self.bits() / 8
    }

    pub fn bits(self) -> u32 {
        match self {
            W::B => 8,
            W::W => 16,
            W::D => 32,
            W::Q => 64,
        }
    }

    /// The low bits of `v` at this width, sign-extended: the value of an immediate field.
    pub fn sext(self, v: u64) -> i64 {
        match self {
            W::B => v as i8 as i64,
            W::W => v as i16 as i64,
            W::D => v as i32 as i64,
            W::Q => v as i64,
        }
    }

    /// A full-width immediate field (`Q`: 32 bits, sign-extended).
    fn imm(self, imm: i32, out: &mut Vec<u8>) {
        match self {
            W::B => out.push(imm as u8),
            W::W => out.extend_from_slice(&(imm as u16).to_le_bytes()),
            W::D | W::Q => out.extend_from_slice(&imm.to_le_bytes()),
        }
    }

    fn imm_len(self) -> u32 {
        match self {
            W::B => 1,
            W::W => 2,
            W::D | W::Q => 4,
        }
    }
}

/// A memory operand `[base + disp]`, `base` `rbp` (a frame slot), `rsp` (a frame slot
/// without a frame pointer: [`Cursor::sp_frame`]) or a register holding a pointer (one whose
/// ModRM encoding needs no SIB byte). `rsp` takes the SIB byte `0x24`. The displacement takes
/// its shortest form: none for a zero displacement off a register other than `rbp`, then
/// `disp8`, then `disp32`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct M {
    pub base: Reg,
    pub disp: i32,
}

impl M {
    pub fn frame(disp: i32) -> M {
        M { base: Reg::Rbp, disp }
    }

    pub fn rax(disp: i32) -> M {
        M { base: Reg::Rax, disp }
    }

    fn len(self) -> u32 {
        let sib = (self.base == Reg::Rsp) as u32;
        1 + sib
            + if self.base != Reg::Rbp && self.disp == 0 {
                0
            } else if i8::try_from(self.disp).is_ok() {
                1
            } else {
                4
            }
    }

    /// The ModRM byte (`reg` in its middle field), the SIB byte of `rsp`, and the
    /// displacement.
    fn write(self, reg: u8, out: &mut Vec<u8>) {
        let rm = self.base.low();
        let sib = |out: &mut Vec<u8>| {
            if self.base == Reg::Rsp {
                out.push(0x24);
            }
        };
        if self.base != Reg::Rbp && self.disp == 0 {
            out.push(reg << 3 | rm);
            sib(out);
        } else if let Ok(d) = i8::try_from(self.disp) {
            out.push(0x40 | reg << 3 | rm);
            sib(out);
            out.push(d as u8);
        } else {
            out.push(0x80 | reg << 3 | rm);
            sib(out);
            out.extend_from_slice(&self.disp.to_le_bytes());
        }
    }
}

/// A register or memory operand (ModRM `r/m`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Rm {
    Reg(Reg),
    Mem(M),
}

impl Rm {
    fn len(self) -> u32 {
        match self {
            Rm::Reg(_) => 1,
            Rm::Mem(m) => m.len(),
        }
    }

    fn write(self, reg: u8, out: &mut Vec<u8>) {
        match self {
            Rm::Reg(r) => out.push(0xc0 | reg << 3 | r.low()),
            Rm::Mem(m) => m.write(reg, out),
        }
    }
}

numbered! {
/// The integer ALU operations, by their x86 `/digit`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Alu {
    Add = 0,
    Or = 1,
    And = 4,
    Sub = 5,
    Xor = 6,
    Cmp = 7,
}
}

numbered! {
/// The shifts and rotates, by their x86 `/digit`. The immediate shifts ([`Item::Shift`]) are
/// `Shl`, `Shr` and `Sar` only.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Sh {
    Rol = 0,
    Ror = 1,
    Shl = 4,
    Shr = 5,
    Sar = 7,
}
}

/// Whether `v` fits a sign-extended 8-bit immediate.
fn imm8(v: i32) -> bool {
    i8::try_from(v).is_ok()
}

/// A machine-code element. Positions are byte offsets in the function.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Item {
    /// `push rbp`
    PushRbp,
    /// `pop rbp`: the end of the PE epilogue (`add rsp, F; pop rbp`, a form the Win64
    /// unwinder recognizes, which `leave` isn't).
    PopRbp,
    /// `sub rsp, imm` (`imm8` below 128, else `imm32`)
    SubRsp(u32),
    /// `add rsp, imm` (`imm8` below 128, else `imm32`)
    AddRsp(u32),
    /// `reg = value`, in the shortest of `xor r32, r32`, `mov r32, imm32`,
    /// `mov r64, simm32`, `mov r64, imm64`.
    SetReg(Reg, u64),
    /// `lea reg, [rip + disp32]`, the field relocated against the [`Ref`].
    Lea(Reg, Ref),
    /// `lea rcx, [rip + disp32]` of a jump table in the function, at this position.
    LeaTable(u32),
    /// `mov dst, src` (64 bits).
    Mov(Reg, Reg),
    /// `call rel32`
    Call(Ref),
    /// `call [rip + disp32]`: through a symbol slot.
    CallMem(Ref),
    /// `call rax`
    CallRax,
    /// `inc qword [rip + disp32]`: one of the function's JIT record's counters counts up, the
    /// call counter at the record's start (the field relocated against [`Ref::Rec`]), or with
    /// `true` the loop counter ([`Ref::RecLoopCtr`]).
    CtrInc(bool),
    /// `call [r11 + disp8]`: a counter stub's call through its JIT record's slot.
    CallR11(u8),
    /// `mov reg, [rip + disp32]`: a symbol slot's value, the field relocated against the
    /// [`Ref`].
    LoadRip(Reg, Ref),
    /// `call [rax]`: through an import slot whose address `rax` holds.
    CallMemRax,
    /// `jmp rax`
    JmpRax,
    /// `rex.w jmp rax`: PE's `tail_call.ptr`, the form the Win64 unwinder takes for an
    /// epilogue's end (a plain `jmp rax` after the pops isn't one).
    JmpRaxW,
    /// `jmp r11`: a PE pad region's entry, to the landing pad the trampoline passes
    /// (design/vm.md#unwinding).
    JmpR11,
    /// `jmp rel32` to another function (a tail call).
    Jmp(Ref),
    /// JIT code only, never decoded: `mov r11, imm64; call r11`, a call of a target out of
    /// `rel32` reach (the `imm64` relocated against the [`Ref`], 8 bytes).
    CallAbs(Ref),
    /// JIT code only: `jmp [rip]; .quad target`, a tail call out of reach (through memory,
    /// which the Win64 unwinder takes for an epilogue's end, and clobbering no register).
    JmpAbs(Ref),
    /// JIT code only: `jmp [rip + disp32]`, a tail call through a call slot.
    JmpMem(Ref),
    /// A jump within the function: `jmp` or a `jcc` on any [`Cond`], `rel8` or (`long`) `rel32`.
    Branch { cond: Cond, target: u32, long: bool },
    /// `test al, al`
    TestAl,
    /// `test rax, rax`
    TestRax,
    /// `leave`
    Leave,
    /// `ret`
    Ret,
    /// `ud2`
    Ud2,
    /// `movsxd rax, [rcx + rax*4]`
    LoadTableEntry,
    /// `add rax, rcx`
    AddRaxRcx,
    /// A padding `nop` of 1 to 9 bytes.
    Nop(u8),
    /// `int3`: padding before a jump table.
    Int3,
    /// A jump table entry: the offset of `target` from the table start `base`.
    TableEntry { base: u32, target: u32 },

    // The native instructions of inlined VM instructions (on `rcx` and the cache's registers,
    // `super::inline::POOL`).
    /// `mov dst, [m]` (32 or 64 bits), or for `B`/`W` `movzx` (`sx`: `movsx`) `dst32, [m]`.
    Ld { w: W, sx: bool, dst: Reg, m: M },
    /// `mov [m], src` at width `w`.
    St { w: W, src: Reg, m: M },
    /// `mov [m], imm` at width `w` (`Q`: a sign-extended `imm32`). `imm` is the field's value,
    /// sign-extended.
    StImm { w: W, m: M, imm: i32 },
    /// `lea dst, [m]` (64 bits).
    LeaM { dst: Reg, m: M },
    /// `op reg, r/m` at width `w`.
    Alu { op: Alu, w: W, reg: Reg, rm: Rm },
    /// `op r/m, imm` at width `w`: a sign-extended `imm8` where it fits, else the full width
    /// (`Q`: `imm32`). `B` is always `imm8`.
    AluImm { op: Alu, w: W, rm: Rm, imm: i32 },
    /// `imul reg, r/m` (`D` or `Q`).
    Imul { w: W, reg: Reg, rm: Rm },
    /// `imul reg, r/m, imm` (`D` or `Q`; `imm8` where it fits, else `imm32`).
    ImulImm { w: W, reg: Reg, rm: Rm, imm: i32 },
    /// `shl`/`shr`/`sar reg, imm8` (`D` or `Q`).
    Shift { op: Sh, w: W, reg: Reg, amt: u8 },
    /// `setcc byte [m]`.
    Setcc { cond: Cond, m: M },
    /// `test byte [m], 0xff`.
    TestM8(M),
    /// `setcc cl`: an overflow flag, before its store from `cl`.
    SetccCl(Cond),
    /// `mul r/m64`: `rdx:rax = rax * r/m`, the unsigned 64-bit multiply with overflow.
    MulQ(Rm),
    /// `op reg, cl` at width `w`: a shift (`D` or `Q`) or a rotate (any width) by `cl`.
    ShiftCl { op: Sh, w: W, reg: Reg },
    /// `div r/m` (`idiv` if `signed`; `D` or `Q`): `rdx:rax / r/m`, the quotient in `rax`, the
    /// remainder in `rdx`.
    Div { signed: bool, w: W, rm: Rm },
    /// `cdq` (`D`) or `cqo` (`Q`): `rdx` the sign of `rax`.
    Cdq(W),
    /// `bsf reg, r/m` (`D` or `Q`): the lowest set bit's index; on zero, ZF set and `reg`
    /// undefined.
    Bsf { w: W, reg: Reg, rm: Rm },
    /// `bsr reg, r/m` (`D` or `Q`): the highest set bit's index, as [`Item::Bsf`].
    Bsr { w: W, reg: Reg, rm: Rm },
    /// `cmovcc reg, r/m` (`D`).
    Cmov { cond: Cond, w: W, reg: Reg, rm: Rm },
    /// `setcc reg8`, another register than `cl` ([`Item::SetccCl`]).
    SetccR(Cond, Reg),
    /// `bswap reg` (`D` or `Q`).
    Bswap { w: W, reg: Reg },

    // Return values and arguments in SSE registers (`xmm0`–`xmm7`).
    /// An SSE load (`st` false) or store of `xmm{x}` at the frame slot `[m]`: `movss` for 4
    /// bytes, `movsd` for 8, `movups` for 16.
    Sse { st: bool, size: u8, x: u8, m: M },
    /// `movd xmm{x}, r32` (`to_xmm`), or `movd r32, xmm{x}`.
    Movd { to_xmm: bool, x: u8, r: Reg },
}

/// The standard multi-byte `nop`s (Intel SDM), by length.
const NOPS: [&[u8]; 10] = [
    &[],
    &[0x90],
    &[0x66, 0x90],
    &[0x0f, 0x1f, 0x00],
    &[0x0f, 0x1f, 0x40, 0x00],
    &[0x0f, 0x1f, 0x44, 0x00, 0x00],
    &[0x66, 0x0f, 0x1f, 0x44, 0x00, 0x00],
    &[0x0f, 0x1f, 0x80, 0x00, 0x00, 0x00, 0x00],
    &[0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
    &[0x66, 0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
];

/// The padding items for `n` bytes: 9-byte `nop`s, then the remainder.
pub fn padding(n: u32, out: &mut Vec<Item>) {
    for _ in 0..n / 9 {
        out.push(Item::Nop(9));
    }
    if n % 9 != 0 {
        out.push(Item::Nop((n % 9) as u8));
    }
}

/// The shortest form of `reg = v`: 0 `xor`, 1 `mov r32`, 2 `mov r64, simm32`, 3 `movabs`.
fn set_form(v: u64) -> u8 {
    if v == 0 {
        0
    } else if v <= u32::MAX as u64 {
        1
    } else if v as i64 >= i32::MIN as i64 && v as i64 <= i32::MAX as i64 {
        2
    } else {
        3
    }
}

impl Item {
    /// The encoded length.
    pub fn len(&self) -> u32 {
        match *self {
            Item::PushRbp | Item::PopRbp | Item::Leave | Item::Ret | Item::Int3 => 1,
            Item::TestAl | Item::CallRax | Item::JmpRax | Item::Ud2 | Item::CallMemRax => 2,
            Item::CallR11(_) => 4,
            Item::JmpR11 => 3,
            Item::CtrInc(_) => 7,
            Item::TestRax | Item::Mov(..) | Item::AddRaxRcx => 3,
            Item::LoadTableEntry | Item::TableEntry { .. } => 4,
            Item::SubRsp(v) | Item::AddRsp(v) => {
                if v < 128 {
                    4
                } else {
                    7
                }
            }
            Item::SetReg(r, v) => {
                let rex = r.ext() as u32;
                match set_form(v) {
                    0 => 2 + rex,
                    1 => 5 + rex,
                    2 => 7,
                    _ => 10,
                }
            }
            Item::Lea(..) | Item::LeaTable(_) | Item::LoadRip(..) => 7,
            Item::Call(_) | Item::Jmp(_) => 5,
            Item::CallMem(_) | Item::JmpMem(_) => 6,
            Item::CallAbs(_) => 13,
            Item::JmpAbs(_) => 14,
            Item::JmpRaxW => 3,
            Item::Branch { cond, long, .. } => match (cond, long) {
                (_, false) => 2,
                (Cond::Always, true) => 5,
                (_, true) => 6,
            },
            Item::Nop(n) => n as u32,
            Item::Ld { w, m, .. } => self.prefix_len() + (if matches!(w, W::B | W::W) { 2 } else { 1 }) + m.len(),
            Item::St { m, .. } => self.prefix_len() + 1 + m.len(),
            Item::StImm { w, m, .. } => self.prefix_len() + 1 + m.len() + w.imm_len(),
            Item::LeaM { m, .. } => self.prefix_len() + 1 + m.len(),
            Item::Alu { rm, .. } => self.prefix_len() + 1 + rm.len(),
            Item::AluImm { w, rm, imm, .. } => self.prefix_len() + 1 + rm.len() + if w == W::B || imm8(imm) { 1 } else { w.imm_len() },
            Item::Imul { rm, .. } => self.prefix_len() + 2 + rm.len(),
            Item::ImulImm { rm, imm, .. } => self.prefix_len() + 1 + rm.len() + if imm8(imm) { 1 } else { 4 },
            Item::Shift { .. } => self.prefix_len() + 3,
            Item::ShiftCl { .. } | Item::Bswap { .. } => self.prefix_len() + 2,
            Item::Bsf { rm, .. } | Item::Bsr { rm, .. } | Item::Cmov { rm, .. } => self.prefix_len() + 2 + rm.len(),
            Item::Setcc { m, .. } => self.prefix_len() + 2 + m.len(),
            Item::TestM8(m) => self.prefix_len() + 2 + m.len(),
            Item::SetccCl(_) => 3,
            Item::SetccR(..) => self.prefix_len() + 3,
            Item::MulQ(rm) | Item::Div { rm, .. } => self.prefix_len() + 1 + rm.len(),
            Item::Cdq(w) => 1 + (w == W::Q) as u32,
            Item::Sse { size, m, .. } => (size != 16) as u32 + 2 + m.len(),
            Item::Movd { r, .. } => 4 + r.ext() as u32,
        }
    }

    /// The REX prefix of a native item, if it needs one: `W` for 64 bits, `R` and `B` for
    /// `r8`–`r11`, and a bare `0x40` for a byte operand in `sil` or `dil`.
    fn rex(&self) -> Option<u8> {
        let (w, reg, rm, byte) = match *self {
            Item::Ld { w, dst, m, .. } => (w == W::Q, Some(dst), Rm::Mem(m), false),
            Item::St { w, src, m } => (w == W::Q, Some(src), Rm::Mem(m), w == W::B),
            Item::StImm { w, m, .. } => (w == W::Q, None, Rm::Mem(m), false),
            Item::LeaM { dst, m } => (true, Some(dst), Rm::Mem(m), false),
            Item::Alu { w, reg, rm, .. } => (w == W::Q, Some(reg), rm, w == W::B),
            Item::AluImm { w, rm, .. } => (w == W::Q, None, rm, w == W::B),
            Item::Imul { w, reg, rm } | Item::ImulImm { w, reg, rm, .. } => (w == W::Q, Some(reg), rm, false),
            Item::Shift { w, reg, .. } => (w == W::Q, None, Rm::Reg(reg), false),
            Item::ShiftCl { w, reg, .. } => (w == W::Q, None, Rm::Reg(reg), w == W::B),
            Item::Bswap { w, reg } => (w == W::Q, None, Rm::Reg(reg), false),
            Item::SetccR(_, reg) => (false, None, Rm::Reg(reg), true),
            Item::Bsf { w, reg, rm } | Item::Bsr { w, reg, rm } | Item::Cmov { w, reg, rm, .. } => (w == W::Q, Some(reg), rm, false),
            Item::Setcc { m, .. } | Item::TestM8(m) => (false, None, Rm::Mem(m), false),
            Item::MulQ(rm) => (true, None, rm, false),
            Item::Div { w, rm, .. } => (w == W::Q, None, rm, false),
            _ => return None,
        };
        let sil = |r: Reg| byte && !r.ext() && r.low() >= 4;
        let mut rex = 0x40 | (w as u8) << 3;
        let mut need = false;
        if let Some(r) = reg {
            rex |= (r.ext() as u8) << 2;
            need |= sil(r);
        }
        match rm {
            Rm::Reg(r) => {
                rex |= r.ext() as u8;
                need |= sil(r);
            }
            Rm::Mem(m) => rex |= m.base.ext() as u8,
        }
        (rex != 0x40 || need).then_some(rex)
    }

    /// The length of a native item's prefixes: the operand-size prefix for 16 bits, and REX.
    fn prefix_len(&self) -> u32 {
        self.w16() as u32 + self.rex().is_some() as u32
    }

    /// Whether the item takes the operand-size prefix (16 bits).
    fn w16(&self) -> bool {
        matches!(
            self,
            Item::St { w: W::W, .. }
                | Item::StImm { w: W::W, .. }
                | Item::Alu { w: W::W, .. }
                | Item::AluImm { w: W::W, .. }
                | Item::ShiftCl { w: W::W, .. }
        )
    }

    /// Writes a native item's prefixes ([`Item::prefix_len`]).
    fn prefixes(&self, out: &mut Vec<u8>) {
        if self.w16() {
            out.push(0x66);
        }
        if let Some(r) = self.rex() {
            out.push(r);
        }
    }

    /// The item with every register (operands and memory bases) mapped by `f`.
    pub fn map_regs(self, f: impl Fn(Reg) -> Reg) -> Item {
        let fm = |m: M| M { base: f(m.base), ..m };
        let frm = |rm: Rm| match rm {
            Rm::Reg(r) => Rm::Reg(f(r)),
            Rm::Mem(m) => Rm::Mem(fm(m)),
        };
        match self {
            Item::Ld { w, sx, dst, m } => Item::Ld { w, sx, dst: f(dst), m: fm(m) },
            Item::St { w, src, m } => Item::St { w, src: f(src), m: fm(m) },
            Item::StImm { w, m, imm } => Item::StImm { w, m: fm(m), imm },
            Item::LeaM { dst, m } => Item::LeaM { dst: f(dst), m: fm(m) },
            Item::Alu { op, w, reg, rm } => Item::Alu { op, w, reg: f(reg), rm: frm(rm) },
            Item::AluImm { op, w, rm, imm } => Item::AluImm { op, w, rm: frm(rm), imm },
            Item::Imul { w, reg, rm } => Item::Imul { w, reg: f(reg), rm: frm(rm) },
            Item::ImulImm { w, reg, rm, imm } => Item::ImulImm { w, reg: f(reg), rm: frm(rm), imm },
            Item::Shift { op, w, reg, amt } => Item::Shift { op, w, reg: f(reg), amt },
            Item::ShiftCl { op, w, reg } => Item::ShiftCl { op, w, reg: f(reg) },
            Item::Bswap { w, reg } => Item::Bswap { w, reg: f(reg) },
            Item::SetccR(cond, reg) => Item::SetccR(cond, f(reg)),
            Item::Bsf { w, reg, rm } => Item::Bsf { w, reg: f(reg), rm: frm(rm) },
            Item::Bsr { w, reg, rm } => Item::Bsr { w, reg: f(reg), rm: frm(rm) },
            Item::Cmov { cond, w, reg, rm } => Item::Cmov { cond, w, reg: f(reg), rm: frm(rm) },
            Item::Setcc { cond, m } => Item::Setcc { cond, m: fm(m) },
            Item::TestM8(m) => Item::TestM8(fm(m)),
            Item::MulQ(rm) => Item::MulQ(frm(rm)),
            Item::Div { signed, w, rm } => Item::Div { signed, w, rm: frm(rm) },
            Item::SetReg(r, v) => Item::SetReg(f(r), v),
            Item::Lea(r, to) => Item::Lea(f(r), to),
            Item::LoadRip(r, to) => Item::LoadRip(f(r), to),
            it => it,
        }
    }

    /// Whether the item ends an inline sequence: it writes the result (to the frame or to
    /// memory). The other end is a conditional branch.
    pub fn ends_inline(&self) -> bool {
        match self {
            // `mov.w128`'s high half, before its last store.
            Item::St { src: Reg::Rcx, m, .. } => m.base != Reg::Rbp,
            Item::AluImm { op, rm: Rm::Mem(_), .. } => *op != Alu::Cmp,
            _ => matches!(self, Item::St { .. } | Item::StImm { .. } | Item::Setcc { .. }),
        }
    }

    /// Whether the item ends its inline sequence, after `prev` and before `next`: as
    /// [`Item::ends_inline`], but an overflow op's result store, which its flag's `setcc cl`
    /// follows, doesn't, and that flag's store (from `cl`, into the frame) does.
    pub fn ends_inline_at(&self, prev: Option<&Item>, next: Option<&Item>) -> bool {
        match self {
            Item::St { .. } if matches!(prev, Some(Item::SetccCl(_))) => true,
            Item::St { .. } if matches!(next, Some(Item::SetccCl(_))) => false,
            _ => self.ends_inline(),
        }
    }

    /// Whether the item may be part of an inline sequence (not PE's handler stack argument).
    pub fn is_inline(&self) -> bool {
        !matches!(self, Item::StImm { m: STACK_ARG, .. })
            && matches!(
                self,
                Item::Ld { .. }
                    | Item::St { .. }
                    | Item::StImm { .. }
                    | Item::LeaM { .. }
                    | Item::Alu { .. }
                    | Item::AluImm { .. }
                    | Item::Imul { .. }
                    | Item::ImulImm { .. }
                    | Item::Shift { .. }
                    | Item::Setcc { .. }
                    | Item::TestM8(_)
                    | Item::SetccCl(_)
                    | Item::MulQ(_)
                    | Item::Div { .. }
                    | Item::Cdq(_)
                    | Item::ShiftCl { .. }
                    | Item::Bswap { .. }
                    | Item::SetccR(..)
                    | Item::Bsf { .. }
                    | Item::Bsr { .. }
                    | Item::Cmov { .. }
                    | Item::Lea(..)
                    | Item::LoadRip(..)
                    | Item::SetReg(Reg::Rax | Reg::Rcx | Reg::Rdx | Reg::Rsi | Reg::Rdi | Reg::R8 | Reg::R9 | Reg::R10 | Reg::R11, _)
            )
    }

    /// The item with the displacements of its frame operands (`[rbp + d]`) mapped by `f`.
    pub fn map_frame(self, f: impl Fn(i32) -> i32) -> Item {
        self.map_mem(|m| if m.base == Reg::Rbp { M { disp: f(m.disp), ..m } } else { m })
    }

    /// The `r/m` operand of a native item that has one.
    pub fn rm_mut(&mut self) -> Option<&mut Rm> {
        match self {
            Item::Alu { rm, .. }
            | Item::AluImm { rm, .. }
            | Item::Imul { rm, .. }
            | Item::ImulImm { rm, .. }
            | Item::MulQ(rm)
            | Item::Div { rm, .. }
            | Item::Bsf { rm, .. }
            | Item::Bsr { rm, .. }
            | Item::Cmov { rm, .. } => Some(rm),
            _ => None,
        }
    }

    /// The `r/m` operand of a native item that has one.
    pub fn rm(&self) -> Option<Rm> {
        let mut it = *self;
        it.rm_mut().copied()
    }

    /// The memory operand of a native item: its `m`, or its `r/m` operand's memory.
    pub fn m_mut(&mut self) -> Option<&mut M> {
        match self {
            Item::Ld { m, .. }
            | Item::St { m, .. }
            | Item::StImm { m, .. }
            | Item::LeaM { m, .. }
            | Item::Setcc { m, .. }
            | Item::Sse { m, .. }
            | Item::TestM8(m) => Some(m),
            it => match it.rm_mut()? {
                Rm::Mem(m) => Some(m),
                Rm::Reg(_) => None,
            },
        }
    }

    /// The item with its memory operand mapped by `f`.
    pub fn map_mem(mut self, f: impl Fn(M) -> M) -> Item {
        if let Some(m) = self.m_mut() {
            *m = f(*m);
        }
        self
    }

    /// The item with its frame operand (`[rbp + d]`) as `[rsp + F + d]`: its form in a frame
    /// of size `F` without a frame pointer.
    pub fn sp_frame(self, frame_size: u32) -> Item {
        self.map_mem(|m| if m.base == Reg::Rbp { M { base: Reg::Rsp, disp: m.disp.wrapping_add(frame_size as i32) } } else { m })
    }

    /// The memory operand of the item.
    pub fn mem(&self) -> Option<M> {
        let mut it = *self;
        it.m_mut().copied()
    }

    /// The frame slot the item reads, and how many bytes.
    pub fn frame_read(&self) -> Option<(M, u32)> {
        let (m, w) = match *self {
            Item::Ld { w, m, .. } => (m, w),
            Item::Alu { w, rm: Rm::Mem(m), .. }
            | Item::AluImm { w, rm: Rm::Mem(m), .. }
            | Item::Imul { w, rm: Rm::Mem(m), .. }
            | Item::ImulImm { w, rm: Rm::Mem(m), .. } => (m, w),
            Item::MulQ(Rm::Mem(m)) => (m, W::Q),
            Item::Div { w, rm: Rm::Mem(m), .. }
            | Item::Bsf { w, rm: Rm::Mem(m), .. }
            | Item::Bsr { w, rm: Rm::Mem(m), .. }
            | Item::Cmov { w, rm: Rm::Mem(m), .. } => (m, w),
            Item::TestM8(m) => (m, W::B),
            _ => return None,
        };
        (m.base == Reg::Rbp).then_some((m, w.bytes()))
    }

    /// The frame slot the item writes, and how many bytes.
    pub fn frame_write(&self) -> Option<(M, u32)> {
        let (m, w) = match *self {
            Item::St { w, m, .. } | Item::StImm { w, m, .. } => (m, w),
            Item::Setcc { m, .. } => (m, W::B),
            // Read-modify-write: also a read ([`Item::frame_read`]).
            Item::AluImm { op, w, rm: Rm::Mem(m), .. } if op != Alu::Cmp => (m, w),
            _ => return None,
        };
        (m.base == Reg::Rbp).then_some((m, w.bytes()))
    }

    /// The immediate of the item, sign-extended.
    pub fn imm(&self) -> Option<u64> {
        match *self {
            Item::StImm { imm, .. } | Item::AluImm { imm, .. } | Item::ImulImm { imm, .. } => Some(imm as i64 as u64),
            Item::Shift { amt, .. } => Some(amt as u64),
            Item::SetReg(_, v) => Some(v),
            _ => None,
        }
    }

    /// Appends the item at position `pos`, and its relocation if it has one.
    pub fn write(&self, pos: u32, out: &mut Vec<u8>, relocs: &mut Vec<Reloc>) {
        let start = out.len();
        let rel32 = |out: &mut Vec<u8>, target: u32| {
            let end = pos + (out.len() - start) as u32 + 4;
            out.extend_from_slice(&(target.wrapping_sub(end) as i32).to_le_bytes());
        };
        let reloc = |out: &mut Vec<u8>, relocs: &mut Vec<Reloc>, to: Ref| {
            relocs.push(Reloc { at: pos + (out.len() - start) as u32, to });
            out.extend_from_slice(&[0; 4]);
        };
        match *self {
            Item::PushRbp => out.push(0x55),
            Item::PopRbp => out.push(0x5d),
            Item::SubRsp(v) | Item::AddRsp(v) => {
                let ext = if matches!(self, Item::SubRsp(_)) { 0xec } else { 0xc4 };
                if v < 128 {
                    out.extend_from_slice(&[0x48, 0x83, ext, v as u8]);
                } else {
                    out.extend_from_slice(&[0x48, 0x81, ext]);
                    out.extend_from_slice(&v.to_le_bytes());
                }
            }
            Item::SetReg(r, v) => match set_form(v) {
                0 => {
                    if r.ext() {
                        out.push(0x45);
                    }
                    out.extend_from_slice(&[0x31, 0xc0 | r.low() << 3 | r.low()]);
                }
                1 => {
                    if r.ext() {
                        out.push(0x41);
                    }
                    out.push(0xb8 | r.low());
                    out.extend_from_slice(&(v as u32).to_le_bytes());
                }
                2 => {
                    out.extend_from_slice(&[0x48 | r.ext() as u8, 0xc7, 0xc0 | r.low()]);
                    out.extend_from_slice(&(v as u32).to_le_bytes());
                }
                _ => {
                    out.extend_from_slice(&[0x48 | r.ext() as u8, 0xb8 | r.low()]);
                    out.extend_from_slice(&v.to_le_bytes());
                }
            },
            Item::Lea(r, to) => {
                out.extend_from_slice(&[0x48 | (r.ext() as u8) << 2, 0x8d, 0x05 | r.low() << 3]);
                reloc(out, relocs, to);
            }
            Item::LeaTable(t) => {
                out.extend_from_slice(&[0x48, 0x8d, 0x0d]);
                rel32(out, t);
            }
            Item::Mov(dst, src) => out.extend_from_slice(&[0x48 | (src.ext() as u8) << 2 | dst.ext() as u8, 0x89, 0xc0 | src.low() << 3 | dst.low()]),
            Item::Call(to) => {
                out.push(0xe8);
                reloc(out, relocs, to);
            }
            Item::CallMem(to) => {
                out.extend_from_slice(&[0xff, 0x15]);
                reloc(out, relocs, to);
            }
            Item::CallRax => out.extend_from_slice(&[0xff, 0xd0]),
            Item::CtrInc(lp) => {
                out.extend_from_slice(&[0x48, 0xff, 0x05]);
                reloc(out, relocs, if lp { Ref::RecLoopCtr } else { Ref::Rec });
            }
            Item::CallR11(d) => out.extend_from_slice(&[0x41, 0xff, 0x53, d]),
            Item::CallMemRax => out.extend_from_slice(&[0xff, 0x10]),
            Item::LoadRip(r, to) => {
                out.extend_from_slice(&[0x48 | (r.ext() as u8) << 2, 0x8b, 0x05 | r.low() << 3]);
                reloc(out, relocs, to);
            }
            Item::JmpRax => out.extend_from_slice(&[0xff, 0xe0]),
            Item::JmpRaxW => out.extend_from_slice(&[0x48, 0xff, 0xe0]),
            Item::JmpR11 => out.extend_from_slice(&[0x41, 0xff, 0xe3]),
            Item::Jmp(to) => {
                out.push(0xe9);
                reloc(out, relocs, to);
            }
            Item::JmpMem(to) => {
                out.extend_from_slice(&[0xff, 0x25]);
                reloc(out, relocs, to);
            }
            Item::CallAbs(to) => {
                out.extend_from_slice(&[0x49, 0xbb]);
                relocs.push(Reloc { at: pos + (out.len() - start) as u32, to });
                out.extend_from_slice(&[0; 8]);
                out.extend_from_slice(&[0x41, 0xff, 0xd3]);
            }
            Item::JmpAbs(to) => {
                out.extend_from_slice(&[0xff, 0x25, 0, 0, 0, 0]);
                relocs.push(Reloc { at: pos + (out.len() - start) as u32, to });
                out.extend_from_slice(&[0; 8]);
            }
            Item::Branch { cond, target, long } => {
                if long {
                    match cond {
                        Cond::Always => out.push(0xe9),
                        c => out.extend_from_slice(&[0x0f, 0x80 | c.cc()]),
                    }
                    rel32(out, target);
                } else {
                    out.push(match cond {
                        Cond::Always => 0xeb,
                        c => 0x70 | c.cc(),
                    });
                    let d = target.wrapping_sub(pos + 2) as i32;
                    debug_assert!(i8::try_from(d).is_ok(), "short branch out of range");
                    out.push(d as i8 as u8);
                }
            }
            Item::TestAl => out.extend_from_slice(&[0x84, 0xc0]),
            Item::TestRax => out.extend_from_slice(&[0x48, 0x85, 0xc0]),
            Item::Leave => out.push(0xc9),
            Item::Ret => out.push(0xc3),
            Item::Ud2 => out.extend_from_slice(&[0x0f, 0x0b]),
            Item::LoadTableEntry => out.extend_from_slice(&[0x48, 0x63, 0x04, 0x81]),
            Item::AddRaxRcx => out.extend_from_slice(&[0x48, 0x01, 0xc8]),
            Item::Nop(n) => out.extend_from_slice(NOPS[n as usize]),
            Item::Int3 => out.push(0xcc),
            Item::TableEntry { base, target } => out.extend_from_slice(&(target.wrapping_sub(base) as i32).to_le_bytes()),
            Item::Ld { w, sx, dst, m } => {
                self.prefixes(out);
                match w {
                    W::B => out.extend_from_slice(&[0x0f, if sx { 0xbe } else { 0xb6 }]),
                    W::W => out.extend_from_slice(&[0x0f, if sx { 0xbf } else { 0xb7 }]),
                    W::D | W::Q => out.push(0x8b),
                }
                m.write(dst.low(), out);
            }
            Item::St { w, src, m } => {
                self.prefixes(out);
                out.push(if w == W::B { 0x88 } else { 0x89 });
                m.write(src.low(), out);
            }
            Item::StImm { w, m, imm } => {
                self.prefixes(out);
                out.push(if w == W::B { 0xc6 } else { 0xc7 });
                m.write(0, out);
                w.imm(imm, out);
            }
            Item::LeaM { dst, m } => {
                self.prefixes(out);
                out.push(0x8d);
                m.write(dst.low(), out);
            }
            Item::Alu { op, w, reg, rm } => {
                self.prefixes(out);
                out.push((op as u8) << 3 | if w == W::B { 2 } else { 3 });
                rm.write(reg.low(), out);
            }
            Item::AluImm { op, w, rm, imm } => {
                self.prefixes(out);
                let short = w == W::B || imm8(imm);
                out.push(if w == W::B {
                    0x80
                } else if short {
                    0x83
                } else {
                    0x81
                });
                rm.write(op as u8, out);
                if short {
                    out.push(imm as u8);
                } else {
                    w.imm(imm, out);
                }
            }
            Item::Imul { reg, rm, .. } => {
                self.prefixes(out);
                out.extend_from_slice(&[0x0f, 0xaf]);
                rm.write(reg.low(), out);
            }
            Item::ImulImm { reg, rm, imm, .. } => {
                self.prefixes(out);
                out.push(if imm8(imm) { 0x6b } else { 0x69 });
                rm.write(reg.low(), out);
                if imm8(imm) {
                    out.push(imm as u8);
                } else {
                    out.extend_from_slice(&imm.to_le_bytes());
                }
            }
            Item::Shift { op, reg, amt, .. } => {
                self.prefixes(out);
                out.extend_from_slice(&[0xc1, 0xc0 | (op as u8) << 3 | reg.low(), amt]);
            }
            Item::Setcc { cond, m } => {
                self.prefixes(out);
                out.extend_from_slice(&[0x0f, 0x90 | cond.cc()]);
                m.write(0, out);
            }
            Item::TestM8(m) => {
                self.prefixes(out);
                out.push(0xf6);
                m.write(0, out);
                out.push(0xff);
            }
            Item::SetccCl(cond) => out.extend_from_slice(&[0x0f, 0x90 | cond.cc(), 0xc1]),
            Item::SetccR(cond, reg) => {
                self.prefixes(out);
                out.extend_from_slice(&[0x0f, 0x90 | cond.cc(), 0xc0 | reg.low()]);
            }
            Item::Bsf { reg, rm, .. } | Item::Bsr { reg, rm, .. } | Item::Cmov { reg, rm, .. } => {
                self.prefixes(out);
                out.extend_from_slice(&[
                    0x0f,
                    match *self {
                        Item::Bsf { .. } => 0xbc,
                        Item::Bsr { .. } => 0xbd,
                        Item::Cmov { cond, .. } => 0x40 | cond.cc(),
                        _ => unreachable!(),
                    },
                ]);
                rm.write(reg.low(), out);
            }
            Item::Bswap { reg, .. } => {
                self.prefixes(out);
                out.extend_from_slice(&[0x0f, 0xc8 | reg.low()]);
            }
            Item::ShiftCl { op, w, reg } => {
                self.prefixes(out);
                out.extend_from_slice(&[if w == W::B { 0xd2 } else { 0xd3 }, 0xc0 | (op as u8) << 3 | reg.low()]);
            }
            Item::MulQ(rm) => {
                self.prefixes(out);
                out.push(0xf7);
                rm.write(4, out);
            }
            Item::Div { signed, rm, .. } => {
                self.prefixes(out);
                out.push(0xf7);
                rm.write(6 | signed as u8, out);
            }
            Item::Cdq(w) => {
                if w == W::Q {
                    out.push(0x48);
                }
                out.push(0x99);
            }
            Item::Sse { st, size, x, m } => {
                match size {
                    4 => out.push(0xf3),
                    8 => out.push(0xf2),
                    _ => debug_assert_eq!(size, 16),
                }
                out.extend_from_slice(&[0x0f, 0x10 | st as u8]);
                m.write(x, out);
            }
            Item::Movd { to_xmm, x, r } => {
                out.push(0x66);
                if r.ext() {
                    out.push(0x41);
                }
                out.extend_from_slice(&[0x0f, if to_xmm { 0x6e } else { 0x7e }, 0xc0 | x << 3 | r.low()]);
            }
        }
        debug_assert_eq!(out.len() - start, self.len() as usize, "{self:?}");
    }
}

/// What a function's `rel32` fields refer to, for the [`Cursor`].
#[derive(Clone, Copy)]
pub enum Fields<'a> {
    /// Unlinked code: the relocations, sorted by field position. A field without one is a
    /// branch within the function.
    Relocs(&'a [Reloc]),
    /// Linked code at address `addr`, its fields resolved: a field whose target lies inside
    /// the function, past its first byte, is a branch within it; any other target is
    /// classified by the resolver. (A function's first byte is its prologue, never a branch
    /// target, so a field to it is a call or tail call of the function itself.) A field to
    /// `record` (with [`super::Mode::counters`]) is the function's JIT record ([`Ref::Rec`]).
    ///
    /// A target among the handlers ([`Resolver::handlers`]) is the handler of the opcode the
    /// instruction list's handler entry at the item names ([`super::list::HANDLER_SEL`], in
    /// `hints`), which must be one of the opcodes registered at that address: the address
    /// alone is ambiguous when handlers are folded.
    Linked { addr: u64, record: Option<u64>, resolver: &'a dyn Resolver, hints: &'a [super::list::Hint] },
}

/// A `rel32` field: a branch within the function (its target position), or a reference.
enum Field {
    Local(u32),
    Ref(Ref),
    Bad,
}

/// A function's code being read: the bytes, the position, and what its fields refer to.
pub struct Cursor<'a> {
    pub code: &'a [u8],
    pub pos: u32,
    fields: Fields<'a>,
    /// Without a frame pointer, the frame size `F`: frame slots are `[rsp + F + d]`, which
    /// [`Cursor::item`] returns as `[rbp + d]`, the form the encoder works in.
    pub sp_frame: Option<u32>,
}

/// The code at the cursor isn't a canonical element.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct BadItem(pub u32);

impl<'a> Cursor<'a> {
    pub fn new(code: &'a [u8], fields: Fields<'a>) -> Self {
        Cursor { code, pos: 0, fields, sp_frame: None }
    }

    fn bytes(&self, n: usize) -> Result<&'a [u8], BadItem> {
        self.code.get(self.pos as usize..).and_then(|b| b.get(..n)).ok_or(BadItem(self.pos))
    }

    /// The byte `i` bytes past the cursor.
    fn byte(&self, i: usize) -> Result<u8, BadItem> {
        Ok(self.bytes(i + 1)?[i])
    }

    fn i32_at(&self, off: usize) -> Result<i32, BadItem> {
        let b = self.bytes(off + 4)?;
        Ok(i32::from_le_bytes([b[off], b[off + 1], b[off + 2], b[off + 3]]))
    }

    /// The PC-relative field `off` bytes into an item of length `len`.
    fn field(&self, off: u32, len: u32) -> Result<Field, BadItem> {
        let d = self.i32_at(off as usize)?;
        let local = (self.pos + len).wrapping_add(d as u32);
        Ok(match self.fields {
            Fields::Relocs(relocs) => match relocs.binary_search_by_key(&(self.pos + off), |r| r.at) {
                Ok(i) => Field::Ref(relocs[i].to),
                Err(_) => Field::Local(local),
            },
            Fields::Linked { addr, record, resolver, hints } => {
                let to = addr.wrapping_add((self.pos + len) as u64).wrapping_add(d as i64 as u64);
                let inside = to.wrapping_sub(addr).wrapping_sub(1) < (self.code.len() as u64).wrapping_sub(1);
                if inside {
                    Field::Local(local)
                } else if record == Some(to) {
                    Field::Ref(Ref::Rec)
                } else if record.map(|r| r + super::JIT_LOOP_CTR as u64) == Some(to) {
                    Field::Ref(Ref::RecLoopCtr)
                } else {
                    let set = resolver.handlers(to);
                    if set.is_empty() {
                        resolver.resolve(to).map_or(Field::Bad, Field::Ref)
                    } else {
                        let lo = hints.partition_point(|h| h.at < self.pos);
                        let named = hints[lo..].iter().take_while(|h| h.at == self.pos).find(|h| h.is_handler());
                        match named {
                            Some(h) if set.iter().any(|&(_, op)| op == h.op) => Field::Ref(Ref::Handler(h.op)),
                            _ => Field::Bad,
                        }
                    }
                }
            }
        })
    }

    /// The reference of the field `off` bytes into an item of length `len`.
    fn field_ref(&self, off: u32, len: u32) -> Result<Ref, BadItem> {
        match self.field(off, len)? {
            Field::Ref(r) => Ok(r),
            _ => Err(BadItem(self.pos)),
        }
    }

    /// The target of the PC-relative field `off` bytes into an item of length `len`, which
    /// must be a branch within the function.
    fn local(&self, off: u32, len: u32) -> Result<u32, BadItem> {
        match self.field(off, len)? {
            Field::Local(t) => Ok(t),
            _ => Err(BadItem(self.pos)),
        }
    }

    /// Reads the next element (not padding, `int3` or a table entry), and checks that its
    /// encoding is canonical.
    pub fn item(&mut self) -> Result<Item, BadItem> {
        match self.base_item() {
            Ok(it) => Ok(it),
            Err(e) => self.native().map_err(|_| e),
        }
    }

    /// Reads a native instruction of an inline sequence. It parses leniently, then checks the
    /// bytes are the item's canonical encoding.
    fn native(&mut self) -> Result<Item, BadItem> {
        let bad = BadItem(self.pos);
        let usable = |r: Reg| !matches!(r, Reg::Rsp | Reg::Rbp);
        let (mut w, mut i) = if self.byte(0)? == 0x66 { (W::W, 1) } else { (W::D, 0) };
        // REX: `W`, and the high bits of the ModRM `reg` and `r/m` fields.
        let (mut rr, mut rb) = (0u8, 0u8);
        if let rex @ 0x40..=0x4f = self.byte(i)? {
            if rex & 2 != 0 {
                return Err(bad);
            }
            if rex & 8 != 0 {
                if w == W::W {
                    return Err(bad);
                }
                w = W::Q;
            }
            (rr, rb) = ((rex >> 2 & 1) << 3, (rex & 1) << 3);
            i += 1;
        }
        let op = self.byte(i)?;
        i += 1;
        // The ModRM operand at `i`: the `reg` field, the `r/m` operand, and the next position.
        let modrm = |i: usize| -> Result<(u8, Rm, usize), BadItem> {
            let m = self.byte(i)?;
            let (md, reg, rm) = (m >> 6, m >> 3 & 7 | rr, m & 7);
            if md == 3 {
                return Ok((reg, Rm::Reg(Reg::from_num(rm | rb).ok_or(bad)?), i + 1));
            }
            // No RIP-relative forms, and SIB only for `rsp`: `rbp` or `rsp` (frame slots) or a
            // pointer register.
            if rm == 5 && md == 0 {
                return Err(bad);
            }
            let (base, i) = if rm == 4 {
                if rb != 0 || self.byte(i + 1)? != 0x24 {
                    return Err(bad);
                }
                (Reg::Rsp, i + 1)
            } else {
                (Reg::from_num(rm | rb).filter(|&b| b == Reg::Rbp || usable(b)).ok_or(bad)?, i)
            };
            let (disp, n) = match md {
                0 => (0, 0),
                1 => (self.byte(i + 1)? as i8 as i32, 1),
                _ => (self.i32_at(i + 1)?, 4),
            };
            Ok((reg, Rm::Mem(M { base, disp }), i + 1 + n))
        };
        let mem = |rm: Rm| match rm {
            Rm::Mem(m) => Ok(m),
            Rm::Reg(_) => Err(bad),
        };
        let reg = |n: u8| Reg::from_num(n).filter(|&r| usable(r)).ok_or(bad);
        let rm_reg = |rm: Rm| match rm {
            Rm::Reg(r) => reg(r as u8),
            Rm::Mem(_) => Err(bad),
        };
        // A full-width immediate at `j`.
        let imm_at = |w: W, j: usize| -> Result<i32, BadItem> {
            Ok(match w {
                W::B => self.byte(j)? as i8 as i32,
                W::W => i16::from_le_bytes([self.byte(j)?, self.byte(j + 1)?]) as i32,
                W::D | W::Q => self.i32_at(j)?,
            })
        };
        let dq = |w: W| if matches!(w, W::D | W::Q) { Ok(w) } else { Err(bad) };
        let item = match (w, op) {
            (W::D | W::Q, 0x0f) if matches!(self.byte(i)?, 0xc8..=0xcf) => Item::Bswap { w, reg: reg(self.byte(i)? & 7 | rb)? },
            (W::D | W::Q, 0x0f) => {
                let op2 = self.byte(i)?;
                let (r, rm, _) = modrm(i + 1)?;
                match op2 {
                    0xb6 | 0xb7 | 0xbe | 0xbf if w == W::D => {
                        Item::Ld { w: if op2 & 1 == 0 { W::B } else { W::W }, sx: op2 & 8 != 0, dst: reg(r)?, m: mem(rm)? }
                    }
                    0xaf => Item::Imul { w, reg: reg(r)?, rm },
                    0xbc => Item::Bsf { w, reg: reg(r)?, rm },
                    0xbd => Item::Bsr { w, reg: reg(r)?, rm },
                    0x40..=0x4f if w == W::D => Item::Cmov { cond: Cond::from_cc(op2 & 0xf).ok_or(bad)?, w, reg: reg(r)?, rm },
                    0x90..=0x9f if w == W::D && r == 0 && rm == Rm::Reg(Reg::Rcx) => Item::SetccCl(Cond::from_cc(op2 & 0xf).ok_or(bad)?),
                    0x90..=0x9f if w == W::D && r == 0 && matches!(rm, Rm::Reg(_)) => Item::SetccR(Cond::from_cc(op2 & 0xf).ok_or(bad)?, rm_reg(rm)?),
                    0x90..=0x9f if w == W::D && r == 0 => Item::Setcc { cond: Cond::from_cc(op2 & 0xf).ok_or(bad)?, m: mem(rm)? },
                    _ => return Err(bad),
                }
            }
            (W::D | W::Q, 0x8b) => {
                let (r, rm, _) = modrm(i)?;
                Item::Ld { w, sx: false, dst: reg(r)?, m: mem(rm)? }
            }
            (_, 0x88 | 0x89) => {
                let w = if op == 0x88 { if w == W::D { W::B } else { return Err(bad) } } else { w };
                let (r, rm, _) = modrm(i)?;
                Item::St { w, src: reg(r)?, m: mem(rm)? }
            }
            (_, 0xc6 | 0xc7) => {
                let w = if op == 0xc6 { if w == W::D { W::B } else { return Err(bad) } } else { w };
                let (_, rm, j) = modrm(i)?;
                Item::StImm { w, m: mem(rm)?, imm: imm_at(w, j)? }
            }
            (W::Q, 0x8d) => {
                let (r, rm, _) = modrm(i)?;
                Item::LeaM { dst: reg(r)?, m: mem(rm)? }
            }
            (_, 0x00..=0x3f) if op & 6 == 2 => {
                let w = if op & 1 == 0 { if w == W::D { W::B } else { return Err(bad) } } else { w };
                let (r, rm, _) = modrm(i)?;
                Item::Alu { op: Alu::from_num(op >> 3).ok_or(bad)?, w, reg: reg(r)?, rm }
            }
            (_, 0x80 | 0x81 | 0x83) => {
                let w = if op == 0x80 { if w == W::D { W::B } else { return Err(bad) } } else { w };
                let (r, rm, j) = modrm(i)?;
                let imm = if op == 0x81 { imm_at(w, j)? } else { self.byte(j)? as i8 as i32 };
                Item::AluImm { op: Alu::from_num(r).ok_or(bad)?, w, rm, imm }
            }
            (_, 0x69 | 0x6b) => {
                let (r, rm, j) = modrm(i)?;
                let imm = if op == 0x69 { self.i32_at(j)? } else { self.byte(j)? as i8 as i32 };
                Item::ImulImm { w: dq(w)?, reg: reg(r)?, rm, imm }
            }
            (_, 0xc1) => {
                let (r, rm, j) = modrm(i)?;
                let op = Sh::from_num(r).filter(|op| matches!(op, Sh::Shl | Sh::Shr | Sh::Sar)).ok_or(bad)?;
                Item::Shift { op, w: dq(w)?, reg: rm_reg(rm)?, amt: self.byte(j)? }
            }
            (_, 0xd2 | 0xd3) => {
                let w = if op == 0xd2 { if w == W::D { W::B } else { return Err(bad) } } else { w };
                let (r, rm, _) = modrm(i)?;
                let op = Sh::from_num(r).ok_or(bad)?;
                Item::ShiftCl { op, w, reg: rm_reg(rm)? }
            }
            (W::D, 0xf6) => {
                let (_, rm, _) = modrm(i)?;
                Item::TestM8(mem(rm)?)
            }
            (W::D | W::Q, 0xf7) => {
                let (r, rm, _) = modrm(i)?;
                match (w, r) {
                    (W::Q, 4) => Item::MulQ(rm),
                    (_, 6 | 7) => Item::Div { signed: r == 7, w, rm },
                    _ => return Err(bad),
                }
            }
            (W::D | W::Q, 0x99) => Item::Cdq(w),
            _ => return Err(bad),
        };
        if let Item::Alu { rm: Rm::Reg(r), .. }
        | Item::AluImm { rm: Rm::Reg(r), .. }
        | Item::Imul { rm: Rm::Reg(r), .. }
        | Item::ImulImm { rm: Rm::Reg(r), .. }
        | Item::MulQ(Rm::Reg(r))
        | Item::Div { rm: Rm::Reg(r), .. }
        | Item::Bsf { rm: Rm::Reg(r), .. }
        | Item::Bsr { rm: Rm::Reg(r), .. }
        | Item::Cmov { rm: Rm::Reg(r), .. } = item
        {
            reg(r as u8)?;
        }
        self.accept_native(item)
    }

    /// Takes the native `item` read at the cursor if the bytes there are its canonical
    /// encoding, without a relocation: its frame slots in the encoder's form (`[rbp + d]`)
    /// from the mode's (`[rsp + F + d]` without a frame pointer), and moves past it.
    fn accept_native(&mut self, item: Item) -> Result<Item, BadItem> {
        let bad = BadItem(self.pos);
        let len = item.len();
        let mut want = Vec::with_capacity(len as usize);
        item.write(self.pos, &mut want, &mut Vec::new());
        if self.bytes(len as usize).ok() != Some(&want[..]) || self.reloc_in(self.pos, len) {
            return Err(bad);
        }
        let item = match (item.mem().map(|m| m.base), self.sp_frame) {
            // PE's handler stack argument (with a frame pointer), outside the frame slots.
            (Some(Reg::Rsp), None) if matches!(item, Item::StImm { w: W::D, m: STACK_ARG, .. }) => item,
            (Some(Reg::Rbp), Some(_)) | (Some(Reg::Rsp), None) => return Err(bad),
            (Some(Reg::Rsp), Some(f)) => item.map_mem(|m| M::frame(m.disp.wrapping_sub(f as i32))),
            _ => item,
        };
        self.pos += len;
        Ok(item)
    }

    fn base_item(&mut self) -> Result<Item, BadItem> {
        let bad = BadItem(self.pos);
        let b = self.bytes(1)?;
        // An optional REX prefix (0x40..=0x4f), then the opcode.
        let (rex, at) = if (0x40..=0x4f).contains(&b[0]) { (b[0], 1) } else { (0, 0) };
        let (w, r, x, bx) = (rex & 8 != 0, rex & 4 != 0, rex & 2 != 0, rex & 1 != 0);
        let op = self.byte(at)?;
        let item = match (rex, op) {
            (0, 0x55) => Item::PushRbp,
            (0, 0x5d) => Item::PopRbp,
            // A counter's `inc`: of the record's call counter or its loop counter.
            (0x48, 0xff) if self.byte(2)? == 0x05 => match self.field(3, 7)? {
                Field::Ref(Ref::Rec) => Item::CtrInc(false),
                Field::Ref(Ref::RecLoopCtr) => Item::CtrInc(true),
                _ => return Err(bad),
            },
            (0x48, 0x83 | 0x81) => {
                let ext = self.byte(2)?;
                let (v, long) = if op == 0x83 { (self.byte(3)? as u32, false) } else { (self.i32_at(3)? as u32, true) };
                if long != (v >= 128) || (op == 0x83 && v >= 128) {
                    return Err(bad);
                }
                match ext {
                    0xec => Item::SubRsp(v),
                    0xc4 => Item::AddRsp(v),
                    _ => return Err(bad),
                }
            }
            (0 | 0x45, 0x31) if !x => {
                let m = self.byte(at + 1)?;
                let (rr, rm) = (m >> 3 & 7, m & 7);
                if m >> 6 != 3 || rr != rm || r != bx {
                    return Err(bad);
                }
                let reg = Reg::from_num(rm | (bx as u8) << 3).ok_or(bad)?;
                Item::SetReg(reg, 0)
            }
            (0 | 0x41, 0xb8..=0xbf) => {
                let reg = Reg::from_num(op & 7 | (bx as u8) << 3).ok_or(bad)?;
                let v = self.i32_at(at + 1)? as u32 as u64;
                if set_form(v) != 1 {
                    return Err(bad);
                }
                Item::SetReg(reg, v)
            }
            (0x48 | 0x49, 0xc7) => {
                let m = self.byte(2)?;
                if m & 0xf8 != 0xc0 {
                    return Err(bad);
                }
                let reg = Reg::from_num(m & 7 | (bx as u8) << 3).ok_or(bad)?;
                let v = self.i32_at(3)? as i64 as u64;
                if set_form(v) != 2 {
                    return Err(bad);
                }
                Item::SetReg(reg, v)
            }
            (0x48 | 0x49, 0xb8..=0xbf) => {
                let reg = Reg::from_num(op & 7 | (bx as u8) << 3).ok_or(bad)?;
                let b = self.bytes(10)?;
                let v = u64::from_le_bytes(b[2..10].try_into().unwrap());
                if set_form(v) != 3 {
                    return Err(bad);
                }
                Item::SetReg(reg, v)
            }
            (0x48 | 0x4c, 0x8d) if w && !x && !bx => {
                let m = self.byte(2)?;
                if m & 0xc7 != 0x05 {
                    return Err(bad);
                }
                let reg = Reg::from_num(m >> 3 & 7 | (r as u8) << 3).ok_or(bad)?;
                match self.field(3, 7)? {
                    Field::Ref(to) => Item::Lea(reg, to),
                    Field::Local(t) if reg == Reg::Rcx => Item::LeaTable(t),
                    _ => return Err(bad),
                }
            }
            (0x48..=0x4f, 0x89) if w && !x => {
                let m = self.byte(2)?;
                if m >> 6 != 3 {
                    return Err(bad);
                }
                let src = Reg::from_num(m >> 3 & 7 | (r as u8) << 3).ok_or(bad)?;
                let dst = Reg::from_num(m & 7 | (bx as u8) << 3).ok_or(bad)?;
                Item::Mov(dst, src)
            }
            (0, 0xe8) => Item::Call(self.field_ref(1, 5)?),
            (0x41, 0xff) if self.byte(2)? == 0x53 => Item::CallR11(self.byte(3)?),
            (0x41, 0xff) if self.byte(2)? == 0xe3 => Item::JmpR11,
            (0x48, 0xff) if self.byte(2)? == 0xe0 => Item::JmpRaxW,
            (0x48 | 0x4c, 0x8b) if self.byte(2)? & 0xc7 == 0x05 => {
                let reg = Reg::from_num(self.byte(2)? >> 3 & 7 | (r as u8) << 3).ok_or(bad)?;
                Item::LoadRip(reg, self.field_ref(3, 7)?)
            }
            (0, 0xff) => match self.byte(1)? {
                0x15 => Item::CallMem(self.field_ref(2, 6)?),
                0xd0 => Item::CallRax,
                0x10 => Item::CallMemRax,
                0xe0 => Item::JmpRax,
                _ => return Err(bad),
            },
            (0, 0xe9) => match self.field(1, 5)? {
                Field::Ref(to) => Item::Jmp(to),
                Field::Local(target) => Item::Branch { cond: Cond::Always, target, long: true },
                Field::Bad => return Err(bad),
            },
            (0, 0xeb | 0x70..=0x7f) => {
                let d = self.byte(1)? as i8 as i32 as u32;
                let cond = if op == 0xeb { Cond::Always } else { Cond::from_cc(op & 0xf).ok_or(bad)? };
                Item::Branch { cond, target: (self.pos + 2).wrapping_add(d), long: false }
            }
            (0, 0x0f) => match self.byte(1)? {
                cc @ 0x80..=0x8f => Item::Branch { cond: Cond::from_cc(cc & 0xf).ok_or(bad)?, target: self.local(2, 6)?, long: true },
                0x0b => Item::Ud2,
                op2 @ (0x10 | 0x11) => return self.sse(0, 16, op2 == 0x11),
                _ => return Err(bad),
            },
            (0, 0xf3 | 0xf2) if self.byte(1)? == 0x0f && matches!(self.byte(2)?, 0x10 | 0x11) => {
                return self.sse(1, if op == 0xf3 { 4 } else { 8 }, self.byte(2)? == 0x11);
            }
            (0, 0x66) => {
                let (r_ext, i) = if self.byte(1)? == 0x41 { (8, 2) } else { (0, 1) };
                let (op2, m) = (self.byte(i + 1)?, self.byte(i + 2)?);
                if self.byte(i)? != 0x0f || !matches!(op2, 0x6e | 0x7e) || m >> 6 != 3 {
                    return Err(bad);
                }
                let r = Reg::from_num(m & 7 | r_ext).filter(|r| !matches!(r, Reg::Rsp | Reg::Rbp)).ok_or(bad)?;
                Item::Movd { to_xmm: op2 == 0x6e, x: m >> 3 & 7, r }
            }
            (0, 0x84) if self.byte(1)? == 0xc0 => Item::TestAl,
            (0x48, 0x85) if self.byte(2)? == 0xc0 => Item::TestRax,
            (0, 0xc9) => Item::Leave,
            (0, 0xc3) => Item::Ret,
            (0x48, 0x63) if self.bytes(4)? == [0x48, 0x63, 0x04, 0x81] => Item::LoadTableEntry,
            (0x48, 0x01) if self.byte(2)? == 0xc8 => Item::AddRaxRcx,
            _ => return Err(bad),
        };
        // A relocation must be the item's own field.
        let len = item.len();
        let own = match item {
            Item::Lea(..) | Item::LoadRip(..) => Some(3),
            Item::Call(_) | Item::Jmp(_) => Some(1),
            Item::CallMem(_) => Some(2),
            Item::CtrInc(_) => Some(3),
            _ => None,
        };
        if self.relocs_in(self.pos, len).iter().any(|rl| Some(rl.at - self.pos) != own) {
            return Err(bad);
        }
        self.bytes(len as usize)?;
        self.pos += len;
        Ok(item)
    }

    /// Reads an SSE load or store of a frame slot (`movss`, `movsd`, `movups`) whose `0f`
    /// opcode byte is `pre` bytes in.
    fn sse(&mut self, pre: usize, size: u8, st: bool) -> Result<Item, BadItem> {
        let bad = BadItem(self.pos);
        let at = pre + 2;
        let m = self.byte(at)?;
        let (md, x, rm) = (m >> 6, m >> 3 & 7, m & 7);
        let (base, d) = match rm {
            5 => (Reg::Rbp, at + 1),
            4 if self.byte(at + 1)? == 0x24 => (Reg::Rsp, at + 2),
            _ => return Err(bad),
        };
        let disp = match md {
            // `[rsp]`, without a displacement.
            0 if base == Reg::Rsp => 0,
            1 => self.byte(d)? as i8 as i32,
            2 => self.i32_at(d)?,
            _ => return Err(bad),
        };
        self.accept_native(Item::Sse { st, size, x, m: M { base, disp } })
    }

    /// Reads padding: 9-byte `nop`s, then at most one shorter one. Returns its length.
    pub fn padding(&mut self) -> u32 {
        let start = self.pos;
        loop {
            let rest = self.code.get(self.pos as usize..).unwrap_or(&[]);
            let Some(n) = (1..NOPS.len()).rev().find(|&n| rest.starts_with(NOPS[n])) else { break };
            if self.reloc_in(self.pos, n as u32) {
                break;
            }
            self.pos += n as u32;
            if n != 9 {
                break;
            }
        }
        self.pos - start
    }

    /// The relocations of the fields starting in `at..at + len` (none in linked code, where
    /// only the items' own fields can be references).
    fn relocs_in(&self, at: u32, len: u32) -> &'a [Reloc] {
        let Fields::Relocs(relocs) = self.fields else { return &[] };
        let lo = relocs.partition_point(|r| r.at < at);
        let hi = relocs.partition_point(|r| r.at < at + len);
        &relocs[lo..hi]
    }

    fn reloc_in(&self, at: u32, len: u32) -> bool {
        !self.relocs_in(at, len).is_empty()
    }

    /// Reads a 1-byte `nop` with no relocation in it (PE's after a call with a landing pad).
    pub fn nop1(&mut self) -> bool {
        let ok = self.bytes(1) == Ok(&[0x90][..]) && !self.reloc_in(self.pos, 1);
        if ok {
            self.pos += 1;
        }
        ok
    }

    /// Reads `int3`s up to a multiple of 4.
    pub fn table_padding(&mut self) -> Result<(), BadItem> {
        while self.pos % 4 != 0 {
            if self.bytes(1)? != [0xcc] {
                return Err(BadItem(self.pos));
            }
            self.pos += 1;
        }
        Ok(())
    }

    /// Reads a jump table entry, relative to the table start `base`: its target.
    pub fn table_entry(&mut self, base: u32) -> Result<u32, BadItem> {
        if self.reloc_in(self.pos, 4) {
            return Err(BadItem(self.pos));
        }
        let t = base.wrapping_add(self.i32_at(0)? as u32);
        self.pos += 4;
        Ok(t)
    }
}
