//! The full instruction set: operand types, the per-opcode operand table, decoding, encoding
//! and disassembly. The lowering emits it; the reduced set ([`crate::reduced`], mapped to by
//! [`crate::asm::reduce`]) is the subset of it that runs as native code, with every handler
//! call one `handler` instruction.
//!
//! Everything here is derived from the single opcode list in `src/isa/full_ops.rs`: the [`Opcode`]
//! enum, the [`OP_INFO`] table (mnemonic, operand names and kinds, fixed length), the decoded
//! [`Insn`] enum, the decoder, the encoder and the [`Display`](fmt::Display) disassembly. So
//! the VM, the backend's encoder and the disassembler can't drift apart.
//!
//! # Encoding
//!
//! Instruction words are the backend's own form of a function's code: the lowering produces
//! them, and the x86 encoder ([`crate::asm`]) turns them into machine code, which decodes
//! back to the same words. An instruction is a sequence of little-endian `u32` words. Word 0
//! holds the opcode in its low 16 bits; its high 16 bits must be 0. The operands follow in
//! the order they are listed, each taking the words of its [`OperandKind`]:
//!
//! | Kind | Words | Rust type |
//! |---|---|---|
//! | `Slot` | 1 | [`Slot`]: signed frame offset |
//! | `Mem` | 2 | [`Mem`]: `[p + k]`, slot `p` then signed `k` |
//! | `U8` / `U16` / `U32` | 1 | `u8` / `u16` / `u32` (the upper bits of the word are 0) |
//! | `U64` / `I64` | 2 | `u64` / `i64`, low word first |
//! | `U128` | 4 | `u128`, low word first |
//! | `Const` | 1 | [`Const`]: constant pool byte offset |
//! | `Abs` | 1 | [`Abs`]: a constant pool or data area offset |
//! | `Sym` | 1 | [`Sym`]: symbol table index |
//! | `Func` | 1 | [`Func`]: function table index |
//! | `Target` | 1 | [`Target`]: branch target, signed words relative to the instruction start |
//! | `Neg` | 1 | [`Neg`]: a branch's polarity, 0 or 1 |
//! | `Targets`, `Words`, `Cases*` | 1 + n·e | a [`List`]: count `n`, then `n` elements of `e` words |
//!
//! Instructions without a list operand have a fixed length ([`Opcode::fixed_len`]). The
//! variable-length ones are `switch.dense`, `switch.sparse`, `island` and the calls (`call`,
//! `call.sym`, `call.sym.ind`, `call.ptr`, `tail_call`, `tail_call.ptr`, with their argument
//! lists); their lengths follow from their count words ([`insn_len`]).

use core::fmt;
use core::marker::PhantomData;

#[cfg(feature = "alloc")]
use alloc::vec::Vec;

macro_rules! newtype {
    ($(#[$m:meta])* $name:ident($inner:ty), $kind:ident, $prefix:literal) => {
        $(#[$m])*
        #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Default)]
        #[repr(transparent)]
        pub struct $name(pub $inner);

        impl<'a> Operand<'a> for $name {
            const KIND: OperandKind = OperandKind::$kind;
            #[inline]
            fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
                Ok($name(take::<1>(w, pos)?[0] as $inner))
            }
            #[cfg(feature = "alloc")]
            fn write(&self, out: &mut Vec<u32>) {
                out.push(self.0 as u32);
            }
        }

        impl fmt::Display for $name {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                write!(f, concat!($prefix, "{}"), self.0)
            }
        }
    };
}

newtype!(
    /// A frame slot: the value at `fp + offset` (bytes, signed: frames grow downward, so
    /// locals are below `fp` and the incoming arguments above it). Displayed as `$off`.
    Slot(i32), Slot, "$"
);
newtype!(
    /// A constant pool byte offset. Displayed as `k<off>`.
    Const(u32), Const, "k"
);
newtype!(
    /// A symbol table index. Displayed as `sym<idx>`.
    Sym(u32), Sym, "sym"
);
newtype!(
    /// A function table index (a VM function in the same image). Displayed as `fn<idx>`.
    Func(u32), Func, "fn"
);

/// A branch target in words, relative to the start of the instruction that contains it.
/// Displayed as `@+n` / `@-n`.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Default)]
#[repr(transparent)]
pub struct Target(pub i32);

impl fmt::Display for Target {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "@{:+}", self.0)
    }
}

/// Memory operand `[p + k]`: load the pointer in slot `p`, add the signed byte offset `k`.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Mem {
    pub p: Slot,
    pub k: i32,
}

/// A byte offset into the image's writable data area. Displayed as
/// `data<off>`.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Default)]
#[repr(transparent)]
pub struct Data(pub u32);

impl fmt::Display for Data {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "data{}", self.0)
    }
}

/// The address `addr.const` writes: a constant pool allocation, or one in the writable data
/// area (PE). One word: the offset, with bit 31 set for the data area.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Abs {
    Const(Const),
    Data(Data),
}

/// Bit 31 of an [`Abs`] word: the data area.
pub const ABS_DATA: u32 = 1 << 31;

impl Abs {
    /// The operand of an `Abs` word.
    pub fn from_word(v: u32) -> Abs {
        if v & ABS_DATA != 0 { Abs::Data(Data(v & !ABS_DATA)) } else { Abs::Const(Const(v)) }
    }

    /// The operand's word.
    pub const fn to_word(self) -> u32 {
        match self {
            Abs::Const(k) => k.0,
            Abs::Data(d) => d.0 | ABS_DATA,
        }
    }
}

/// A branch's polarity: with `Neg(true)` (`!` after the mnemonic) the branch is taken when
/// its condition is false.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, Default)]
pub struct Neg(pub bool);

/// The encoding of an operand. See the [module docs](self).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum OperandKind {
    Slot,
    Mem,
    U8,
    U16,
    U32,
    U64,
    I64,
    U128,
    Const,
    Abs,
    Sym,
    Func,
    Target,
    Neg,
    /// A count word followed by that many elements of the given kind.
    List(ElemKind),
    /// The handler of a reduced `handler` ([`crate::reduced::Handler`]): a full opcode.
    /// Reduced set only: no full-set opcode has this operand.
    Handler,
}

/// The element kind of a [`List`] operand.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum ElemKind {
    /// [`Target`] (1 word).
    Target,
    /// Raw `u32` (1 word): island operands.
    Word,
    /// [`Case8`] (2 words).
    Case8,
    /// [`Case16`] (2 words).
    Case16,
    /// [`Case32`] (2 words).
    Case32,
    /// [`Case64`] (3 words).
    Case64,
    /// [`Case128`] (5 words).
    Case128,
    /// [`crate::reduced::Arg`] (3 words): a reduced `handler`'s argument registers.
    /// Reduced set only.
    Arg,
}

impl ElemKind {
    pub const fn words(self) -> usize {
        match self {
            ElemKind::Target | ElemKind::Word => 1,
            ElemKind::Case8 | ElemKind::Case16 | ElemKind::Case32 => 2,
            ElemKind::Case64 | ElemKind::Arg => 3,
            ElemKind::Case128 => 5,
        }
    }

    /// The bytes of a case value (1, 2, 4, 8 or 16, its size in a code constant), or `None`
    /// for a kind that isn't a case.
    pub const fn case_bytes(self) -> Option<usize> {
        match self {
            ElemKind::Case8 => Some(1),
            ElemKind::Case16 => Some(2),
            ElemKind::Case32 => Some(4),
            ElemKind::Case64 => Some(8),
            ElemKind::Case128 => Some(16),
            ElemKind::Target | ElemKind::Word | ElemKind::Arg => None,
        }
    }

    /// Whether this is a sparse switch's case kind.
    pub const fn is_case(self) -> bool {
        self.case_bytes().is_some()
    }
}

impl Opcode {
    /// The element kind of the opcode's case list, if it has one.
    pub fn case_elem(self) -> Option<ElemKind> {
        self.info().operands.iter().find_map(|o| match o.kind {
            OperandKind::List(e) if e.is_case() => Some(e),
            _ => None,
        })
    }

    /// Whether the instruction calls code that may unwind, so it can have a cleanup entry:
    /// the calls, `island` and `resume`.
    pub const fn may_unwind(self) -> bool {
        matches!(self.info().shape, Shape::Call | Shape::Island) || matches!(self, Opcode::Resume)
    }

    /// Whether the instruction loads through the slot of its `Sym` operand (`addr.sym.ind`,
    /// `call.sym.ind`), so the symbol must be indirect; the other `Sym` operands must not be.
    pub const fn loads_through_sym(self) -> bool {
        matches!(self, Opcode::AddrSymInd | Opcode::CallSymInd)
    }
}

impl OperandKind {
    /// Number of words, or `None` for a list (variable).
    pub const fn words(self) -> Option<usize> {
        Some(match self {
            OperandKind::Slot
            | OperandKind::U8
            | OperandKind::U16
            | OperandKind::U32
            | OperandKind::Const
            | OperandKind::Abs
            | OperandKind::Sym
            | OperandKind::Func
            | OperandKind::Target
            | OperandKind::Neg
            | OperandKind::Handler => 1,
            OperandKind::Mem | OperandKind::U64 | OperandKind::I64 => 2,
            OperandKind::U128 => 4,
            OperandKind::List(_) => return None,
        })
    }
}

/// Decoding failure.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum DecodeError {
    /// No words left where an instruction or operand was expected.
    Truncated,
    /// Word 0's low 16 bits aren't an opcode.
    UnknownOpcode(u16),
    /// Word 0's high 16 bits are non-zero.
    ReservedBits(u32),
    /// An operand word out of its kind's range (a `U8` above 255, a `Neg` other than 0/1).
    BadOperand(u32),
}

impl fmt::Display for DecodeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            DecodeError::Truncated => f.write_str("truncated instruction"),
            DecodeError::UnknownOpcode(op) => write!(f, "unknown opcode {op:#x}"),
            DecodeError::ReservedBits(w) => write!(f, "reserved bits set in word 0 ({w:#x})"),
            DecodeError::BadOperand(w) => write!(f, "operand word out of range ({w:#x})"),
        }
    }
}

#[inline]
fn take<'a, const N: usize>(w: &'a [u32], pos: &mut usize) -> Result<&'a [u32; N], DecodeError> {
    let s = w.get(*pos..*pos + N).ok_or(DecodeError::Truncated)?;
    *pos += N;
    Ok(s.try_into().unwrap())
}

/// An operand type: how it is read from and written to instruction words.
pub trait Operand<'a>: Sized + Copy {
    const KIND: OperandKind;
    /// Whether the disassembly lists the operand (a [`Neg`] is a suffix of the mnemonic).
    const LISTED: bool = true;
    /// Reads the operand at `w[*pos..]` and advances `pos`.
    fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError>;
    /// Appends the operand's words.
    #[cfg(feature = "alloc")]
    fn write(&self, out: &mut Vec<u32>);
    /// What the disassembly appends to the mnemonic.
    fn suffix(&self) -> &'static str {
        ""
    }
}

/// The integer in the words `w`, low word first.
#[inline]
const fn words_to_u128(w: &[u32]) -> u128 {
    let mut v = 0;
    let mut i = 0;
    while i < w.len() {
        v |= (w[i] as u128) << (32 * i);
        i += 1;
    }
    v
}

/// Appends the low `n` words of `v`, low word first.
#[cfg(feature = "alloc")]
fn push_u128(out: &mut Vec<u32>, v: u128, n: usize) {
    out.extend((0..n).map(|i| (v >> (32 * i)) as u32));
}

macro_rules! int_operand {
    ($t:ty, $kind:ident, $n:literal) => {
        impl<'a> Operand<'a> for $t {
            const KIND: OperandKind = OperandKind::$kind;
            #[inline]
            fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
                Ok(words_to_u128(take::<$n>(w, pos)?) as $t)
            }
            #[cfg(feature = "alloc")]
            fn write(&self, out: &mut Vec<u32>) {
                push_u128(out, *self as u128, $n);
            }
        }
    };
}
int_operand!(u32, U32, 1);
int_operand!(u64, U64, 2);
int_operand!(i64, I64, 2);
int_operand!(u128, U128, 4);

/// The narrow immediates: one word, whose bits above the width must be 0.
macro_rules! narrow_operand {
    ($t:ty, $kind:ident) => {
        impl<'a> Operand<'a> for $t {
            const KIND: OperandKind = OperandKind::$kind;
            #[inline]
            fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
                let v = take::<1>(w, pos)?[0];
                <$t>::try_from(v).map_err(|_| DecodeError::BadOperand(v))
            }
            #[cfg(feature = "alloc")]
            fn write(&self, out: &mut Vec<u32>) {
                out.push(u32::from(*self));
            }
        }
    };
}
narrow_operand!(u8, U8);
narrow_operand!(u16, U16);

impl<'a> Operand<'a> for Abs {
    const KIND: OperandKind = OperandKind::Abs;
    #[inline]
    fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
        Ok(Abs::from_word(take::<1>(w, pos)?[0]))
    }
    #[cfg(feature = "alloc")]
    fn write(&self, out: &mut Vec<u32>) {
        out.push(self.to_word());
    }
}

impl fmt::Display for Abs {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Abs::Const(k) => fmt::Display::fmt(k, f),
            Abs::Data(d) => fmt::Display::fmt(d, f),
        }
    }
}

impl<'a> Operand<'a> for Neg {
    const KIND: OperandKind = OperandKind::Neg;
    const LISTED: bool = false;
    #[inline]
    fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
        match take::<1>(w, pos)?[0] {
            0 => Ok(Neg(false)),
            1 => Ok(Neg(true)),
            v => Err(DecodeError::BadOperand(v)),
        }
    }
    #[cfg(feature = "alloc")]
    fn write(&self, out: &mut Vec<u32>) {
        out.push(self.0 as u32);
    }
    fn suffix(&self) -> &'static str {
        if self.0 { "!" } else { "" }
    }
}

impl fmt::Display for Neg {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.suffix())
    }
}

impl<'a> Operand<'a> for Target {
    const KIND: OperandKind = OperandKind::Target;
    #[inline]
    fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
        Ok(Target(take::<1>(w, pos)?[0] as i32))
    }
    #[cfg(feature = "alloc")]
    fn write(&self, out: &mut Vec<u32>) {
        out.push(self.0 as u32);
    }
}

impl<'a> Operand<'a> for Mem {
    const KIND: OperandKind = OperandKind::Mem;
    #[inline]
    fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
        let [p, k] = *take::<2>(w, pos)?;
        Ok(Mem { p: Slot(p as i32), k: k as i32 })
    }
    #[cfg(feature = "alloc")]
    fn write(&self, out: &mut Vec<u32>) {
        out.push(self.p.0 as u32);
        out.push(self.k as u32);
    }
}

impl fmt::Display for Mem {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if self.k < 0 { write!(f, "[{} - {}]", self.p, (self.k as i64).unsigned_abs()) } else { write!(f, "[{} + {}]", self.p, self.k) }
    }
}

/// An element of a [`List`] operand.
pub trait Elem: Copy + 'static {
    const KIND: ElemKind;
    /// Reads one element from exactly `KIND.words()` words.
    fn get(w: &[u32]) -> Self;
    #[cfg(feature = "alloc")]
    fn put(&self, out: &mut Vec<u32>);
    fn fmt_elem(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result;
    /// Whether the `KIND.words()` words `w` are an element.
    fn valid(_w: &[u32]) -> bool {
        true
    }
}

impl Elem for Target {
    const KIND: ElemKind = ElemKind::Target;
    fn get(w: &[u32]) -> Self {
        Target(w[0] as i32)
    }
    #[cfg(feature = "alloc")]
    fn put(&self, out: &mut Vec<u32>) {
        out.push(self.0 as u32);
    }
    fn fmt_elem(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Display::fmt(self, f)
    }
}

impl Elem for u32 {
    const KIND: ElemKind = ElemKind::Word;
    fn get(w: &[u32]) -> Self {
        w[0]
    }
    #[cfg(feature = "alloc")]
    fn put(&self, out: &mut Vec<u32>) {
        out.push(*self);
    }
    fn fmt_elem(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{self}")
    }
}

macro_rules! case_elem {
    ($(#[$m:meta])* $name:ident, $v:ty, $kind:ident, $n:literal) => {
        $(#[$m])*
        #[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
        pub struct $name {
            pub value: $v,
            pub target: Target,
        }
        impl Elem for $name {
            const KIND: ElemKind = ElemKind::$kind;
            fn get(w: &[u32]) -> Self {
                $name { value: words_to_u128(&w[..$n]) as $v, target: Target(w[$n] as i32) }
            }
            #[cfg(feature = "alloc")]
            fn put(&self, out: &mut Vec<u32>) {
                push_u128(out, self.value as u128, $n);
                out.push(self.target.0 as u32);
            }
            fn fmt_elem(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                write!(f, "{} => {}", self.value, self.target)
            }
            /// The value's bits above its width must be 0, as for the scalar operands.
            fn valid(w: &[u32]) -> bool {
                words_to_u128(&w[..$n]) <= <$v>::MAX as u128
            }
        }
    };
}
case_elem!(
    /// A `switch.sparse.w8` case: value word, then target.
    Case8, u8, Case8, 1
);
case_elem!(
    /// A `switch.sparse.w16` case: value word, then target.
    Case16, u16, Case16, 1
);
case_elem!(
    /// A `switch.sparse.w32` case: value word, then target.
    Case32, u32, Case32, 1
);
case_elem!(
    /// A `switch.sparse.w64` case: value (2 words), then target.
    Case64, u64, Case64, 2
);
case_elem!(
    /// A `switch.sparse.w128` case: value (4 words), then target.
    Case128, u128, Case128, 4
);

/// A variable-length list operand: a zero-copy view over its element words (not including
/// the count word). Encoded as the count `n`, then `n` elements.
#[derive(Clone, Copy, PartialEq, Eq)]
pub struct List<'a, T> {
    words: &'a [u32],
    _elem: PhantomData<T>,
}

impl<'a, T: Elem> List<'a, T> {
    /// Wraps already-encoded element words. Panics unless `words.len()` is a multiple of the
    /// element size.
    pub fn from_words(words: &'a [u32]) -> Self {
        assert!(words.len() % T::KIND.words() == 0, "partial list element");
        List { words, _elem: PhantomData }
    }

    /// The element words (without the count word).
    pub fn words(&self) -> &'a [u32] {
        self.words
    }

    pub fn len(&self) -> usize {
        self.words.len() / T::KIND.words()
    }

    pub fn is_empty(&self) -> bool {
        self.words.is_empty()
    }

    pub fn get(&self, i: usize) -> Option<T> {
        let n = T::KIND.words();
        self.words.get(i * n..i * n + n).map(T::get)
    }

    pub fn iter(&self) -> impl ExactSizeIterator<Item = T> + 'a {
        self.words.chunks_exact(T::KIND.words()).map(T::get)
    }
}

/// Encodes list elements into words, for [`List::from_words`].
#[cfg(feature = "alloc")]
pub fn list_words<T: Elem>(elems: impl IntoIterator<Item = T>) -> Vec<u32> {
    let mut out = Vec::new();
    for e in elems {
        e.put(&mut out);
    }
    out
}

impl<T: Elem> fmt::Debug for List<'_, T>
where
    T: fmt::Debug,
{
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_list().entries(self.iter()).finish()
    }
}

impl<T: Elem> fmt::Display for List<'_, T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("[")?;
        for (i, e) in self.iter().enumerate() {
            if i > 0 {
                f.write_str(", ")?;
            }
            e.fmt_elem(f)?;
        }
        f.write_str("]")
    }
}

impl<'a, T: Elem> Operand<'a> for List<'a, T> {
    const KIND: OperandKind = OperandKind::List(T::KIND);
    #[inline]
    fn read(w: &'a [u32], pos: &mut usize) -> Result<Self, DecodeError> {
        let n = take::<1>(w, pos)?[0] as usize;
        let len = n.checked_mul(T::KIND.words()).ok_or(DecodeError::Truncated)?;
        let words = w.get(*pos..).and_then(|r| r.get(..len)).ok_or(DecodeError::Truncated)?;
        if let Some(e) = words.chunks_exact(T::KIND.words()).find(|e| !T::valid(e)) {
            return Err(DecodeError::BadOperand(e[0]));
        }
        *pos += len;
        Ok(List { words, _elem: PhantomData })
    }
    #[cfg(feature = "alloc")]
    fn write(&self, out: &mut Vec<u32>) {
        out.push(self.len() as u32);
        out.extend_from_slice(self.words);
    }
}

/// Maps an operand kind name in the opcode list to its Rust type.
macro_rules! op_ty {
    ($lt:lifetime, Slot) => { $crate::full::Slot };
    ($lt:lifetime, Mem) => { $crate::full::Mem };
    ($lt:lifetime, U8) => { u8 };
    ($lt:lifetime, U16) => { u16 };
    ($lt:lifetime, U32) => { u32 };
    ($lt:lifetime, U64) => { u64 };
    ($lt:lifetime, I64) => { i64 };
    ($lt:lifetime, U128) => { u128 };
    ($lt:lifetime, Const) => { $crate::full::Const };
    ($lt:lifetime, Abs) => { $crate::full::Abs };
    ($lt:lifetime, Sym) => { $crate::full::Sym };
    ($lt:lifetime, Func) => { $crate::full::Func };
    ($lt:lifetime, Target) => { $crate::full::Target };
    ($lt:lifetime, Neg) => { $crate::full::Neg };
    ($lt:lifetime, Targets) => { $crate::full::List<$lt, $crate::full::Target> };
    ($lt:lifetime, Words) => { $crate::full::List<$lt, u32> };
    ($lt:lifetime, Cases8) => { $crate::full::List<$lt, $crate::full::Case8> };
    ($lt:lifetime, Cases16) => { $crate::full::List<$lt, $crate::full::Case16> };
    ($lt:lifetime, Cases32) => { $crate::full::List<$lt, $crate::full::Case32> };
    ($lt:lifetime, Cases64) => { $crate::full::List<$lt, $crate::full::Case64> };
    ($lt:lifetime, Cases128) => { $crate::full::List<$lt, $crate::full::Case128> };
    ($lt:lifetime, Handler) => { $crate::reduced::Handler };
    ($lt:lifetime, Args) => { $crate::full::List<$lt, $crate::reduced::Arg> };
    // In a family member, `ImmW` is the immediate of its width (`u64` for `ptr`) and
    // `CasesW` the case list of its width; the other kinds don't depend on it.
    ($lt:lifetime, ImmW W8) => { u8 };
    ($lt:lifetime, ImmW W16) => { u16 };
    ($lt:lifetime, ImmW W32) => { u32 };
    ($lt:lifetime, ImmW W64) => { u64 };
    ($lt:lifetime, ImmW W128) => { u128 };
    ($lt:lifetime, ImmW Ptr) => { u64 };
    ($lt:lifetime, CasesW W8) => { op_ty!($lt, Cases8) };
    ($lt:lifetime, CasesW W16) => { op_ty!($lt, Cases16) };
    ($lt:lifetime, CasesW W32) => { op_ty!($lt, Cases32) };
    ($lt:lifetime, CasesW W64) => { op_ty!($lt, Cases64) };
    ($lt:lifetime, CasesW W128) => { op_ty!($lt, Cases128) };
    ($lt:lifetime, $k:ident $w:ident) => { op_ty!($lt, $k) };
}

/// The mnemonic component of a width token of the opcode list.
macro_rules! width_mn {
    (W8) => {
        "w8"
    };
    (W16) => {
        "w16"
    };
    (W32) => {
        "w32"
    };
    (W64) => {
        "w64"
    };
    (W128) => {
        "w128"
    };
    (Ptr) => {
        "ptr"
    };
}

/// An opcode's `(family, width)` entry: `none none` for the opcodes outside the families.
macro_rules! family_width {
    (none none) => {
        None
    };
    ($f:ident $w:ident) => {
        Some((Family::$f, $crate::full::OpWidth::$w))
    };
}

/// The operand width of a family member (design/instructions.md): the integer widths in
/// their canonical order, then `ptr` (the atomics' `AtomicPtr` forms: 8 bytes, but a
/// pointer, with provenance). A family's members have consecutive opcodes in this order, so
/// `Family::at` is the family's first opcode plus the number of its widths below `w`.
#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum OpWidth {
    W8,
    W16,
    W32,
    W64,
    W128,
    Ptr,
}

impl OpWidth {
    pub const ALL: [OpWidth; 6] = [OpWidth::W8, OpWidth::W16, OpWidth::W32, OpWidth::W64, OpWidth::W128, OpWidth::Ptr];

    /// The size in bytes (8 for `ptr`).
    pub const fn bytes(self) -> u8 {
        [1, 2, 4, 8, 16, 8][self as usize]
    }

    /// The mnemonic component: `w32`, `ptr`.
    pub const fn mnemonic(self) -> &'static str {
        ["w8", "w16", "w32", "w64", "w128", "ptr"][self as usize]
    }

    /// The integer width, `None` for `ptr`.
    pub const fn int(self) -> Option<Width> {
        match self {
            OpWidth::Ptr => None,
            w => Some(Width::ALL[w as usize]),
        }
    }
}

/// A family's opcodes: the first one's value and the bit set of its [`OpWidth`]s.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FamilyInfo {
    pub base: u16,
    pub mask: u8,
}

/// How an instruction runs as machine code ([`crate::asm`]): which handler it calls, and what
/// control flow follows the call. Given in the opcode list.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Shape {
    /// A call of the opcode's handler, then the next instruction (`op`).
    Op,
    /// The handler returns a `bool`, and the instruction branches on it with its polarity
    /// (`br`).
    Br,
    /// The handler returns a case index, and the instruction jumps through a table (`switch`).
    Switch,
    /// The handler doesn't return (`trap`).
    Trap,
    /// The return value is loaded into `rax`/`rdx`, and the function returns, without a
    /// handler (`ret`).
    Ret,
    /// A jump, without a handler (`jmp`).
    Jmp,
    /// A call, without a handler: the argument registers loaded from the list `a`, the call
    /// of a VM function of the same image, a symbol or a fn pointer, then the result's
    /// stores (`call`).
    Call,
    /// The same as a tail call: the argument registers, the epilogue and a jump
    /// (`tail_call`).
    TailCall,
    /// A direct call of an island, without a handler (`island`).
    Island,
    /// A landing pad: the handler stores the exception object (`lpad`).
    Lpad,
    /// The store of an argument register to a slot, without a handler, at the start of the
    /// function (`arg`).
    Arg,
}

impl Shape {
    /// Whether an instruction of this shape can continue at the next one: everything but
    /// jumps, returns, tail calls, switches and traps.
    pub const fn falls_through(self) -> bool {
        !matches!(self, Shape::Jmp | Shape::Ret | Shape::TailCall | Shape::Switch | Shape::Trap)
    }
}

/// Maps a shape name in the opcode list to its [`Shape`].
macro_rules! shape {
    (op) => {
        $crate::full::Shape::Op
    };
    (br) => {
        $crate::full::Shape::Br
    };
    (switch) => {
        $crate::full::Shape::Switch
    };
    (trap) => {
        $crate::full::Shape::Trap
    };
    (ret) => {
        $crate::full::Shape::Ret
    };
    (jmp) => {
        $crate::full::Shape::Jmp
    };
    (call) => {
        $crate::full::Shape::Call
    };
    (tail_call) => {
        $crate::full::Shape::TailCall
    };
    (arg) => {
        $crate::full::Shape::Arg
    };
    (island) => {
        $crate::full::Shape::Island
    };
    (lpad) => {
        $crate::full::Shape::Lpad
    };
}

/// One operand of an opcode: its name in the instruction set docs, and its encoding.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct OperandInfo {
    pub name: &'static str,
    pub kind: OperandKind,
}

/// Static description of an opcode of the full set, or with `O` the reduced one's
/// ([`crate::reduced`]).
#[derive(Clone, Copy, Debug)]
pub struct OpInfo<O: 'static = Opcode> {
    pub opcode: O,
    /// Assembly mnemonic.
    pub mnemonic: &'static str,
    pub shape: Shape,
    /// Operands in encoding order (word 1 onwards).
    pub operands: &'static [OperandInfo],
    /// Length in words, or `None` if the instruction has a list operand.
    pub fixed_len: Option<usize>,
}

impl<O: 'static> OpInfo<O> {
    /// Each operand with its words, given the instruction's words after the opcode word (a
    /// list's include its count word). The single place that knows the operand layout.
    pub fn operand_words<'a>(&self, mut words: &'a [u32]) -> impl Iterator<Item = (&'static OperandInfo, &'a [u32])> + use<'a, O> {
        self.operands.iter().map(move |o| {
            let n = match o.kind {
                OperandKind::List(e) => 1 + words[0] as usize * e.words(),
                k => k.words().unwrap(),
            };
            let (w, rest) = words.split_at(n);
            words = rest;
            (o, w)
        })
    }

    /// The branch offsets (relative to the instruction start) of the instruction's target
    /// operands and target-list elements, in operand order, given the words after the opcode
    /// word as for [`operand_words`](Self::operand_words).
    pub fn branch_offsets<'a>(&self, words: &'a [u32]) -> impl Iterator<Item = i32> + use<'a, O> {
        self.operand_words(words).flat_map(|(o, w)| {
            let (w, step) = match o.kind {
                OperandKind::Target => (&w[..1], 1),
                // A case's target is its last word; a word list has none.
                OperandKind::List(e) if e != ElemKind::Word => (&w[1..], e.words()),
                _ => (&w[..0], 1),
            };
            w.chunks(step).map(|el| el[el.len() - 1] as i32)
        })
    }
}

impl<O: 'static> OpInfo<O> {
    /// Word index (from the instruction start) of operand `i`, if every operand before it
    /// has a fixed size.
    pub const fn operand_offset(&self, i: usize) -> Option<usize> {
        let mut off = 1;
        let mut j = 0;
        while j < i {
            match self.operands[j].kind.words() {
                Some(n) => off += n,
                None => return None,
            }
            j += 1;
        }
        Some(off)
    }

    /// Index of the operand called `name`.
    pub const fn operand_index(&self, name: &str) -> Option<usize> {
        let mut i = 0;
        while i < self.operands.len() {
            if str_eq(self.operands[i].name, name) {
                return Some(i);
            }
            i += 1;
        }
        None
    }

    /// Word index of operand `i` (`operands.len()`: the instruction's length) in the
    /// instruction `w`, reading the count words of the list operands before it.
    pub fn operand_start(&self, w: &[u32], i: usize) -> Result<usize, DecodeError> {
        let mut pos = 1usize;
        for o in &self.operands[..i] {
            pos += match o.kind {
                OperandKind::List(e) => {
                    let n = *w.get(pos).ok_or(DecodeError::Truncated)? as usize;
                    1 + n.checked_mul(e.words()).ok_or(DecodeError::Truncated)?
                }
                k => k.words().unwrap(),
            };
        }
        if pos > w.len() {
            return Err(DecodeError::Truncated);
        }
        Ok(pos)
    }
}

pub(crate) const fn str_eq(a: &str, b: &str) -> bool {
    let (a, b) = (a.as_bytes(), b.as_bytes());
    if a.len() != b.len() {
        return false;
    }
    let mut i = 0;
    while i < a.len() {
        if a[i] != b[i] {
            return false;
        }
        i += 1;
    }
    true
}

pub(crate) const fn fixed_len(kinds: &[OperandKind]) -> Option<usize> {
    let mut n = 1;
    let mut i = 0;
    while i < kinds.len() {
        match kinds[i].words() {
            Some(w) => n += w,
            None => return None,
        }
        i += 1;
    }
    Some(n)
}

/// Defines [`Opcode`], [`OP_INFO`], [`Insn`], [`Family`] and their decode/encode/display from
/// one list.
///
/// Syntax: `Variant = "mnemonic" shape { operand: Kind, ... },` where `shape` is one of the
/// names handled by `shape!` and `Kind` one of those handled by `op_ty!`. Field order is
/// encoding order. A family of widths is one entry,
/// `fam Name = "stem" shape { .. } @ [W8, W16, ..],`, whose members `NameW8` (`stem.w8`),
/// ... follow each other in the order of the widths ([`OpWidth`]); with
/// `fam Pre * Post = "pre" * ".post" ..` the width goes in the middle (`PreW8Post`,
/// `pre.w8.post`; the family is `PrePost`). Operand kinds `ImmW` and `CasesW` take the
/// member's width.
macro_rules! define_ops {
    (@m [$($acc:tt)*] [$($fams:tt)*] fam $f:ident * $p:ident = $mn:literal * $mp:literal $shape:ident $fields:tt @ [$($w:ident),* $(,)?], $($rest:tt)*) => {
        define_ops!(@m [$($acc)* $(${concat($f, $w, $p)} = concat!($mn, ".", width_mn!($w), $mp); $shape $w ${concat($f, $p)} $fields,)*] [$($fams)* ${concat($f, $p)}] $($rest)*);
    };
    (@m [$($acc:tt)*] [$($fams:tt)*] fam $f:ident = $mn:literal $shape:ident $fields:tt @ [$($w:ident),* $(,)?], $($rest:tt)*) => {
        define_ops!(@m [$($acc)* $(${concat($f, $w)} = concat!($mn, ".", width_mn!($w)); $shape $w $f $fields,)*] [$($fams)* $f] $($rest)*);
    };
    (@m [$($acc:tt)*] [$($fams:tt)*] $name:ident = $mn:literal $shape:ident $fields:tt, $($rest:tt)*) => {
        define_ops!(@m [$($acc)* $name = $mn; $shape none none $fields,] [$($fams)*] $($rest)*);
    };
    (@m [$($acc:tt)*] [$($fams:tt)*]) => {
        define_ops!(@flat [$($fams)*] $($acc)*);
    };
    (@flat [$($fams:ident)*] $($name:ident = $mn:expr; $shape:ident $w:ident $fam:ident { $($field:ident : $kind:ident),* $(,)? },)*) => {
        /// An opcode: the low 16 bits of an instruction's word 0.
        ///
        /// Variants are numbered in list order; any change to the list changes the encoding.
        #[repr(u16)]
        #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
        pub enum Opcode {
            $(
                #[doc = concat!("`", $mn, $(" ", stringify!($field), ":", stringify!($kind),)* "`")]
                $name,
            )*
        }

        /// Word offsets of each opcode's operands, from the instruction start: `off::AddW32::b`
        /// is 3. Operands after a list operand have no fixed position and are `usize::MAX`.
        #[allow(non_snake_case, non_upper_case_globals)]
        pub mod off {
            $(
                #[doc = concat!("Operand word offsets of `", $mn, "`.")]
                pub mod $name {
                    $(pub const $field: usize = super::super::operand_word(
                        super::super::Opcode::$name, stringify!($field));)*
                }
            )*
        }

        /// Every opcode, indexed by its value.
        pub const ALL_OPCODES: &[Opcode] = &[$(Opcode::$name),*];

        /// A family of opcodes that differ only in their [`OpWidth`](crate::full::OpWidth):
        /// `add.w8` .. `add.w128` are [`Family::Add`]'s. Its members have consecutive opcodes,
        /// in width order.
        #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
        pub enum Family {
            $($fams,)*
        }

        /// Each opcode's family and width, indexed by its value.
        static OP_FAMILY: [Option<(Family, $crate::full::OpWidth)>; ALL_OPCODES.len()] = [$(family_width!($fam $w)),*];

        /// Each family's first opcode and widths, indexed by the family.
        /// They must be consecutive and in width order, for each family.
        pub static FAMILY_INFO: [$crate::full::FamilyInfo; Family::ALL.len()] = {
            let mut t = [$crate::full::FamilyInfo { base: u16::MAX, mask: 0 }; Family::ALL.len()];
            let mut i = 0;
            while i < OP_FAMILY.len() {
                if let Some((f, w)) = OP_FAMILY[i] {
                    let fi = &mut t[f as usize];
                    if fi.mask == 0 {
                        fi.base = i as u16;
                    }
                    assert!(fi.base as usize + fi.mask.count_ones() as usize == i, "a family's opcodes aren't consecutive");
                    assert!(fi.mask >> w as u8 == 0, "a family's widths aren't in order");
                    fi.mask |= 1 << w as u8;
                }
                i += 1;
            }
            t
        };

        impl Family {
            /// Every family, indexed by its value.
            pub const ALL: &[Family] = &[$(Family::$fams),*];

            /// The family's member of width `w`, if it has one: its first opcode plus the
            /// number of its widths below `w`.
            #[inline]
            pub const fn at(self, w: $crate::full::OpWidth) -> Option<Opcode> {
                let fi = &FAMILY_INFO[self as usize];
                if fi.mask & (1 << w as u8) == 0 {
                    return None;
                }
                Opcode::from_u16(fi.base + (fi.mask & ((1u8 << w as u8) - 1)).count_ones() as u16)
            }

            /// The bit set of the family's widths (bit `w as u8` for [`OpWidth`](crate::full::OpWidth) `w`).
            pub const fn widths(self) -> u8 {
                FAMILY_INFO[self as usize].mask
            }

            /// The family's members, in width order.
            pub fn members(self) -> impl Iterator<Item = Opcode> {
                let fi = FAMILY_INFO[self as usize];
                (0..fi.mask.count_ones() as u16).map(move |i| Opcode::from_u16(fi.base + i).unwrap())
            }
        }

        /// Static description of every opcode, indexed by its value.
        pub static OP_INFO: [$crate::full::OpInfo<Opcode>; ALL_OPCODES.len()] = [$(
            $crate::full::OpInfo {
                opcode: Opcode::$name,
                mnemonic: $mn,
                shape: shape!($shape),
                operands: &[$(OperandInfo {
                    name: stringify!($field),
                    kind: <op_ty!('static, $kind $w) as Operand<'static>>::KIND,
                }),*],
                fixed_len: fixed_len(&[$(<op_ty!('static, $kind $w) as Operand<'static>>::KIND),*]),
            },
        )*];

        /// A decoded instruction. Field names and order match [`OP_INFO`].
        #[derive(Clone, Copy, Debug, PartialEq, Eq)]
        pub enum Insn<'a> {
            $(
                #[doc = concat!("`", $mn, "`")]
                $name { $($field: op_ty!('a, $kind $w)),* },
            )*
        }

        impl<'a> Insn<'a> {
            /// The instruction's opcode.
            pub fn opcode(&self) -> Opcode {
                match self {
                    $(Insn::$name { .. } => Opcode::$name,)*
                }
            }

            /// Decodes the instruction at the start of `w`. Returns it and its length in
            /// words.
            pub fn decode(w: &'a [u32]) -> Result<(Insn<'a>, usize), DecodeError> {
                let w0 = *w.first().ok_or(DecodeError::Truncated)?;
                let op = Opcode::from_u16(w0 as u16).ok_or(DecodeError::UnknownOpcode(w0 as u16))?;
                if w0 >> 16 != 0 {
                    return Err(DecodeError::ReservedBits(w0));
                }
                let mut pos = 1usize;
                let insn = match op {
                    $(Opcode::$name => {
                        $(let $field = <op_ty!('a, $kind $w) as Operand<'a>>::read(w, &mut pos)?;)*
                        Insn::$name { $($field),* }
                    })*
                };
                Ok((insn, pos))
            }

            /// Appends the instruction's words to `out`.
            #[cfg(feature = "alloc")]
            pub fn encode(&self, out: &mut Vec<u32>) {
                match self {
                    $(Insn::$name { $($field),* } => {
                        out.push(Opcode::$name as u32);
                        $(Operand::write($field, out);)*
                    })*
                }
            }
        }

        /// Index of the operand called `name` of `op`, for `const` contexts. Panics if there is none.
        pub const fn operand_index_const(op: Opcode, name: &str) -> usize {
            match op.info().operand_index(name) {
                Some(i) => i,
                None => panic!("no such operand"),
            }
        }

        /// Word offset of the operand called `name` of `op`, or `usize::MAX` if it follows a list
        /// operand. Used for the [`off`] constants.
        pub const fn operand_word(op: Opcode, name: &str) -> usize {
            match op.info().operand_offset(operand_index_const(op, name)) {
                Some(o) => o,
                None => usize::MAX,
            }
        }

        impl Opcode {
            /// Number of opcodes.
            pub const COUNT: usize = ALL_OPCODES.len();

            #[inline]
            pub const fn from_u16(v: u16) -> Option<Opcode> {
                if (v as usize) < Self::COUNT { Some(ALL_OPCODES[v as usize]) } else { None }
            }

            #[inline]
            pub const fn info(self) -> &'static $crate::full::OpInfo<Opcode> {
                &OP_INFO[self as usize]
            }

            pub const fn mnemonic(self) -> &'static str {
                self.info().mnemonic
            }

            /// The opcode's family and width, if it is a family member.
            #[inline]
            pub const fn fw(self) -> Option<(Family, $crate::full::OpWidth)> {
                OP_FAMILY[self as usize]
            }

            /// The opcode's family, if it is a family member.
            #[inline]
            pub const fn family(self) -> Option<Family> {
                match self.fw() {
                    Some((f, _)) => Some(f),
                    None => None,
                }
            }

            /// The opcode's width, if it is a family member.
            #[inline]
            pub const fn width(self) -> Option<$crate::full::OpWidth> {
                match self.fw() {
                    Some((_, w)) => Some(w),
                    None => None,
                }
            }

            /// Length in words, or `None` for the variable-length opcodes (see [`insn_len`]).
            #[inline]
            pub const fn fixed_len(self) -> Option<usize> {
                self.info().fixed_len
            }
        }

        /// Length in words of the instruction at the start of `w`, reading its count words if it has
        /// list operands. Doesn't validate the other operands.
        pub fn insn_len(w: &[u32]) -> Result<usize, DecodeError> {
            let w0 = *w.first().ok_or(DecodeError::Truncated)?;
            let op = Opcode::from_u16(w0 as u16).ok_or(DecodeError::UnknownOpcode(w0 as u16))?;
            if let Some(n) = op.fixed_len() {
                return Ok(n);
            }
            let info = op.info();
            info.operand_start(w, info.operands.len())
        }

        /// Iterates over the instructions of a code sequence, yielding `(word offset, insn)`.
        pub struct Decoder<'a> {
            code: &'a [u32],
            pos: usize,
        }

        impl<'a> Decoder<'a> {
            pub fn new(code: &'a [u32]) -> Self {
                Decoder { code, pos: 0 }
            }
        }

        impl<'a> Iterator for Decoder<'a> {
            type Item = Result<(usize, Insn<'a>), DecodeError>;
            fn next(&mut self) -> Option<Self::Item> {
                if self.pos >= self.code.len() {
                    return None;
                }
                let at = self.pos;
                Some(match Insn::decode(&self.code[at..]) {
                    Ok((insn, n)) => {
                        self.pos += n;
                        Ok((at, insn))
                    }
                    Err(e) => {
                        self.pos = self.code.len();
                        Err(e)
                    }
                })
            }
        }

        /// Disassembly of a code sequence, one instruction per line, prefixed by its word offset.
        /// Branch targets are printed relative to their instruction, as encoded.
        pub struct Disasm<'a>(pub &'a [u32]);

        impl fmt::Display for Disasm<'_> {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                for r in Decoder::new(self.0) {
                    match r {
                        Ok((at, insn)) => writeln!(f, "{at:6}: {insn}")?,
                        Err(e) => return writeln!(f, "error: {e}"),
                    }
                }
                Ok(())
            }
        }

        impl fmt::Display for Insn<'_> {
            #[allow(unused_assignments, unused_mut, unused_variables)]
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                match self {
                    $(Insn::$name { $($field),* } => {
                        f.write_str($mn)?;
                        $(f.write_str(Operand::suffix($field))?;)*
                        let mut sep = " ";
                        $(
                            if <op_ty!('_, $kind $w) as Operand<'_>>::LISTED {
                                f.write_str(sep)?;
                                fmt::Display::fmt($field, f)?;
                                sep = ", ";
                            }
                        )*
                        Ok(())
                    })*
                }
            }
        }
    };
    ($($t:tt)*) => {
        define_ops!(@m [] [] $($t)*);
    };
}

include!("full_ops.rs");

/// A code buffer for one function, with helpers to emit instructions and patch branch
/// targets once the target position is known.
#[cfg(feature = "alloc")]
#[derive(Clone, Debug, Default)]
pub struct CodeBuf {
    pub words: Vec<u32>,
}

#[cfg(feature = "alloc")]
impl CodeBuf {
    pub fn new() -> Self {
        Self::default()
    }

    /// Current position (word offset of the next instruction).
    pub fn pos(&self) -> u32 {
        self.words.len() as u32
    }

    /// Appends `insn` and returns its position.
    pub fn emit(&mut self, insn: &Insn<'_>) -> u32 {
        let at = self.pos();
        insn.encode(&mut self.words);
        at
    }

    /// Sets the fixed-position `Target` operand `operand` (index into the opcode's operand
    /// list) of the instruction at `insn_at` so that it branches to `target_at`.
    pub fn set_target(&mut self, insn_at: u32, operand: usize, target_at: u32) {
        let op = Opcode::from_u16(self.words[insn_at as usize] as u16).expect("not an instruction");
        let info = op.info();
        assert_eq!(info.operands[operand].kind, OperandKind::Target, "not a target operand");
        let off = info.operand_offset(operand).expect("target after a list operand");
        self.words[insn_at as usize + off] = target_at.wrapping_sub(insn_at) as u32;
    }

    /// Sets element `i` of the `Targets` list operand `operand` of the instruction at
    /// `insn_at` (a `switch.dense` table) to branch to `target_at`.
    pub fn set_list_target(&mut self, insn_at: u32, operand: usize, i: usize, target_at: u32) {
        let at = insn_at as usize;
        let op = Opcode::from_u16(self.words[at] as u16).expect("not an instruction");
        let info = op.info();
        assert_eq!(info.operands[operand].kind, OperandKind::List(ElemKind::Target), "not a target list");
        let pos = at + info.operand_start(&self.words[at..], operand).expect("truncated instruction");
        assert!(i < self.words[pos] as usize, "list index out of range");
        self.words[pos + 1 + i] = target_at.wrapping_sub(insn_at) as u32;
    }
}
