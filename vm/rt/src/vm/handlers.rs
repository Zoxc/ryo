// The handler table: every opcode with a handler, with its handler kind, the kind's
// parameters and, unless it is `()`, the handler's return type. Included by interp.rs,
// whose `*_!` body macros implement the kinds. `handlers!` is invoked as
// `for_each_handler!(handlers!())` and receives `Name => kind(params) [-> R]; ...`.
// A family of full_ops.rs is one entry, `fam Add => kind(params) @ [W8(u8), W16(u16)];`: the
// members `AddW8 => kind(u8, params); AddW16 => kind(u16, params);` (`fam Pre * Post` for
// `PreW8Post`), the parameters of each width first.
//
// `full_ops.rs` has no handler for `jmp`, the calls, `ret`, `arg` and `island`; `resume` is
// written in assembly (interp.rs). The list is checked against `full_ops.rs` when built.
// Kinds: integer types select the width and signedness (`i*` for `.s` forms), float
// types the format; `Atomic*` the atomic type; orderings are `core::sync::atomic::Ordering`
// variants. The `*_ptr` atomic kinds are `AtomicPtr`'s: the same machine operations as the
// 64-bit integer ones, but the value is a pointer (with provenance, in the Lean semantics),
// and the read-modify-write ones take a `usize` operand (`fetch_byte_add`, `fetch_or`, ...).
// The SIMD kinds (`vsplat`, `vcmp`, `vmsb`) take the lane type and the lane count.

macro_rules! for_each_handler {
    ($m:ident!($($args:tt)*)) => { handler_entries! { $m ($($args)*) []
        fam Mov => mov() @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        Copy => copy();
        fam Imm => imm() @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        Const => konst();
        Zero => zero();
        fam Load => load() @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Store => store() @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        LoadCopy => load_copy();
        StoreCopy => store_copy();
        Memcpy => memcpy();
        Memmove => memmove();
        Memset => memset();
        Fill => fill();
        Addr => addr();
        AddrSym => addr_sym(false);
        AddrSymInd => addr_sym(true);
        AddrConst => addr_const();
        PtrAdd => ptr_add();
        PtrIndex => ptr_index();
        fam Add => bin(wrapping_add) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Sub => bin(wrapping_sub) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Mul => bin(wrapping_mul) @ [W8(u8), W16(u16), W32(u32), W64(u64)];
        fam DivS => bin_fn(unchecked_div) @ [W8(i8), W16(i16), W32(i32), W64(i64)];
        fam DivU => bin_fn(unchecked_div) @ [W8(u8), W16(u16), W32(u32), W64(u64)];
        fam RemS => bin_fn(unchecked_rem) @ [W8(i8), W16(i16), W32(i32), W64(i64)];
        fam RemU => bin_fn(unchecked_rem) @ [W8(u8), W16(u16), W32(u32), W64(u64)];
        fam And => binop(&) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Or => binop(|) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Xor => binop(^) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Shl => shift(wrapping_shl) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam ShrS => shift(wrapping_shr) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam ShrU => shift(wrapping_shr) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Eq => cmp(==) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Ne => cmp(!=) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam LtS => cmp(<) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam LtU => cmp(<) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam LeS => cmp(<=) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam LeU => cmp(<=) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Cmp3S => cmp3() @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam Cmp3U => cmp3() @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Rotl => rot(rotate_left) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Rotr => rot(rotate_right) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam AddImm => bin_imm(wrapping_add) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam SubImm => bin_imm(wrapping_sub) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam MulImm => bin_imm(wrapping_mul) @ [W8(u8), W16(u16), W32(u32), W64(u64)];
        fam AndImm => binop_imm(&) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam OrImm => binop_imm(|) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam XorImm => binop_imm(^) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam ShlImm => shift_imm(wrapping_shl) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam ShrSImm => shift_imm(wrapping_shr) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam ShrUImm => shift_imm(wrapping_shr) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam EqImm => cmp_imm(==) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam NeImm => cmp_imm(!=) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam LtSImm => cmp_imm(<) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam LtUImm => cmp_imm(<) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam LeSImm => cmp_imm(<=) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam LeUImm => cmp_imm(<=) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam GtSImm => cmp_imm(>) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam GtUImm => cmp_imm(>) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam GeSImm => cmp_imm(>=) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam GeUImm => cmp_imm(>=) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Neg => un(wrapping_neg) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Not => un(not) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Ctpop => count(count_ones) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Ctlz => count(leading_zeros) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Cttz => count(trailing_zeros) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam Bitreverse => un(reverse_bits) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam AddOvfS => ovf(overflowing_add) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam AddOvfU => ovf(overflowing_add) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam SubOvfS => ovf(overflowing_sub) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam SubOvfU => ovf(overflowing_sub) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam MulOvfS => ovf(overflowing_mul) @ [W8(i8), W16(i16), W32(i32), W64(i64)];
        fam MulOvfU => ovf(overflowing_mul) @ [W8(u8), W16(u16), W32(u32), W64(u64)];
        fam Bswap => un(swap_bytes) @ [W16(u16), W32(u32), W64(u64), W128(u128)];
        FaddF32 => fbin(f32, +);
        FsubF32 => fbin(f32, -);
        FmulF32 => fbin(f32, *);
        FdivF32 => fbin(f32, /);
        FremF32 => fbin(f32, %);
        FeqF32 => fcmp(f32, ==);
        FneF32 => fcmp(f32, !=);
        FltF32 => fcmp(f32, <);
        FleF32 => fcmp(f32, <=);
        FminF32 => fmeth(f32, min);
        FmaxF32 => fmeth(f32, max);
        CopysignF32 => fmeth(f32, copysign);
        FnegF32 => fneg(f32);
        FabsF32 => fun(f32, abs);
        FaddF64 => fbin(f64, +);
        FsubF64 => fbin(f64, -);
        FmulF64 => fbin(f64, *);
        FdivF64 => fbin(f64, /);
        FremF64 => fbin(f64, %);
        FeqF64 => fcmp(f64, ==);
        FneF64 => fcmp(f64, !=);
        FltF64 => fcmp(f64, <);
        FleF64 => fcmp(f64, <=);
        FminF64 => fmeth(f64, min);
        FmaxF64 => fmeth(f64, max);
        CopysignF64 => fmeth(f64, copysign);
        FnegF64 => fneg(f64);
        FabsF64 => fun(f64, abs);
        VsplatI8x16 => vsplat(u8, 16);
        VeqI8x16 => vcmp(u8, 16, ==);
        VltSI8x16 => vcmp(i8, 16, <);
        VmsbI8x16 => vmsb(u8, 16);
        ZextW8W16 => cvt(u8, u16);
        SextW8W16 => cvt(i8, i16);
        ZextW8W32 => cvt(u8, u32);
        SextW8W32 => cvt(i8, i32);
        ZextW8W64 => cvt(u8, u64);
        SextW8W64 => cvt(i8, i64);
        ZextW8W128 => cvt(u8, u128);
        SextW8W128 => cvt(i8, i128);
        ZextW16W32 => cvt(u16, u32);
        SextW16W32 => cvt(i16, i32);
        ZextW16W64 => cvt(u16, u64);
        SextW16W64 => cvt(i16, i64);
        ZextW16W128 => cvt(u16, u128);
        SextW16W128 => cvt(i16, i128);
        ZextW32W64 => cvt(u32, u64);
        SextW32W64 => cvt(i32, i64);
        ZextW32W128 => cvt(u32, u128);
        SextW32W128 => cvt(i32, i128);
        ZextW64W128 => cvt(u64, u128);
        SextW64W128 => cvt(i64, i128);
        TruncW16W8 => cvt(u16, u8);
        TruncW32W8 => cvt(u32, u8);
        TruncW32W16 => cvt(u32, u16);
        TruncW64W8 => cvt(u64, u8);
        TruncW64W16 => cvt(u64, u16);
        TruncW64W32 => cvt(u64, u32);
        TruncW128W8 => cvt(u128, u8);
        TruncW128W16 => cvt(u128, u16);
        TruncW128W32 => cvt(u128, u32);
        TruncW128W64 => cvt(u128, u64);
        fam CvtF2iSatSF32 => cvt() @ [W8(f32, i8), W16(f32, i16), W32(f32, i32), W64(f32, i64), W128(f32, i128)];
        fam CvtF2iSatSF64 => cvt() @ [W8(f64, i8), W16(f64, i16), W32(f64, i32), W64(f64, i64), W128(f64, i128)];
        fam CvtF2iSatUF32 => cvt() @ [W8(f32, u8), W16(f32, u16), W32(f32, u32), W64(f32, u64), W128(f32, u128)];
        fam CvtF2iSatUF64 => cvt() @ [W8(f64, u8), W16(f64, u16), W32(f64, u32), W64(f64, u64), W128(f64, u128)];
        fam CvtI2fS * F32 => cvt(f32) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam CvtI2fS * F64 => cvt(f64) @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam CvtI2fU * F32 => cvt(f32) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam CvtI2fU * F64 => cvt(f64) @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        CvtF2fF32F64 => cvt(f32, f64);
        CvtF2fF64F32 => cvt(f64, f32);
        fam AtomicLoad * Relaxed => aload(Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicLoad * Acquire => aload(Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicLoad * Seqcst => aload(SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicStore * Relaxed => astore(Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicStore * Release => astore(Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicStore * Seqcst => astore(SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXchg * Relaxed => armw(swap, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXchg * Acquire => armw(swap, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXchg * Release => armw(swap, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXchg * Acqrel => armw(swap, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXchg * Seqcst => armw(swap, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAdd * Relaxed => armw(fetch_add, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAdd * Acquire => armw(fetch_add, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAdd * Release => armw(fetch_add, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAdd * Acqrel => armw(fetch_add, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAdd * Seqcst => armw(fetch_add, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicSub * Relaxed => armw(fetch_sub, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicSub * Acquire => armw(fetch_sub, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicSub * Release => armw(fetch_sub, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicSub * Acqrel => armw(fetch_sub, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicSub * Seqcst => armw(fetch_sub, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAnd * Relaxed => armw(fetch_and, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAnd * Acquire => armw(fetch_and, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAnd * Release => armw(fetch_and, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAnd * Acqrel => armw(fetch_and, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicAnd * Seqcst => armw(fetch_and, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicOr * Relaxed => armw(fetch_or, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicOr * Acquire => armw(fetch_or, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicOr * Release => armw(fetch_or, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicOr * Acqrel => armw(fetch_or, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicOr * Seqcst => armw(fetch_or, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXor * Relaxed => armw(fetch_xor, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXor * Acquire => armw(fetch_xor, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXor * Release => armw(fetch_xor, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXor * Acqrel => armw(fetch_xor, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicXor * Seqcst => armw(fetch_xor, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicNand * Relaxed => armw(fetch_nand, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicNand * Acquire => armw(fetch_nand, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicNand * Release => armw(fetch_nand, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicNand * Acqrel => armw(fetch_nand, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicNand * Seqcst => armw(fetch_nand, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicMin * Relaxed => armw(fetch_min, Relaxed) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMin * Acquire => armw(fetch_min, Acquire) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMin * Release => armw(fetch_min, Release) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMin * Acqrel => armw(fetch_min, AcqRel) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMin * Seqcst => armw(fetch_min, SeqCst) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMax * Relaxed => armw(fetch_max, Relaxed) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMax * Acquire => armw(fetch_max, Acquire) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMax * Release => armw(fetch_max, Release) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMax * Acqrel => armw(fetch_max, AcqRel) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicMax * Seqcst => armw(fetch_max, SeqCst) @ [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)];
        fam AtomicUmin * Relaxed => armw(fetch_min, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmin * Acquire => armw(fetch_min, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmin * Release => armw(fetch_min, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmin * Acqrel => armw(fetch_min, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmin * Seqcst => armw(fetch_min, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmax * Relaxed => armw(fetch_max, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmax * Acquire => armw(fetch_max, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmax * Release => armw(fetch_max, Release) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmax * Acqrel => armw(fetch_max, AcqRel) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicUmax * Seqcst => armw(fetch_max, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * RelaxedRelaxed => cxchg(compare_exchange, Relaxed, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * RelaxedAcquire => cxchg(compare_exchange, Relaxed, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * RelaxedSeqcst => cxchg(compare_exchange, Relaxed, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * AcquireRelaxed => cxchg(compare_exchange, Acquire, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * AcquireAcquire => cxchg(compare_exchange, Acquire, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * AcquireSeqcst => cxchg(compare_exchange, Acquire, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * ReleaseRelaxed => cxchg(compare_exchange, Release, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * ReleaseAcquire => cxchg(compare_exchange, Release, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * ReleaseSeqcst => cxchg(compare_exchange, Release, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * AcqrelRelaxed => cxchg(compare_exchange, AcqRel, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * AcqrelAcquire => cxchg(compare_exchange, AcqRel, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * AcqrelSeqcst => cxchg(compare_exchange, AcqRel, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * SeqcstRelaxed => cxchg(compare_exchange, SeqCst, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * SeqcstAcquire => cxchg(compare_exchange, SeqCst, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchg * SeqcstSeqcst => cxchg(compare_exchange, SeqCst, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * RelaxedRelaxed => cxchg(compare_exchange_weak, Relaxed, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * RelaxedAcquire => cxchg(compare_exchange_weak, Relaxed, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * RelaxedSeqcst => cxchg(compare_exchange_weak, Relaxed, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * AcquireRelaxed => cxchg(compare_exchange_weak, Acquire, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * AcquireAcquire => cxchg(compare_exchange_weak, Acquire, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * AcquireSeqcst => cxchg(compare_exchange_weak, Acquire, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * ReleaseRelaxed => cxchg(compare_exchange_weak, Release, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * ReleaseAcquire => cxchg(compare_exchange_weak, Release, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * ReleaseSeqcst => cxchg(compare_exchange_weak, Release, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * AcqrelRelaxed => cxchg(compare_exchange_weak, AcqRel, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * AcqrelAcquire => cxchg(compare_exchange_weak, AcqRel, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * AcqrelSeqcst => cxchg(compare_exchange_weak, AcqRel, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * SeqcstRelaxed => cxchg(compare_exchange_weak, SeqCst, Relaxed) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * SeqcstAcquire => cxchg(compare_exchange_weak, SeqCst, Acquire) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        fam AtomicCxchgWeak * SeqcstSeqcst => cxchg(compare_exchange_weak, SeqCst, SeqCst) @ [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)];
        AtomicLoadPtrRelaxed => aload_ptr(Relaxed);
        AtomicLoadPtrAcquire => aload_ptr(Acquire);
        AtomicLoadPtrSeqcst => aload_ptr(SeqCst);
        AtomicStorePtrRelaxed => astore_ptr(Relaxed);
        AtomicStorePtrRelease => astore_ptr(Release);
        AtomicStorePtrSeqcst => astore_ptr(SeqCst);
        AtomicXchgPtrRelaxed => armw_ptr(swap, Relaxed);
        AtomicXchgPtrAcquire => armw_ptr(swap, Acquire);
        AtomicXchgPtrRelease => armw_ptr(swap, Release);
        AtomicXchgPtrAcqrel => armw_ptr(swap, AcqRel);
        AtomicXchgPtrSeqcst => armw_ptr(swap, SeqCst);
        AtomicAddPtrRelaxed => armw_ptr(fetch_byte_add, Relaxed);
        AtomicAddPtrAcquire => armw_ptr(fetch_byte_add, Acquire);
        AtomicAddPtrRelease => armw_ptr(fetch_byte_add, Release);
        AtomicAddPtrAcqrel => armw_ptr(fetch_byte_add, AcqRel);
        AtomicAddPtrSeqcst => armw_ptr(fetch_byte_add, SeqCst);
        AtomicSubPtrRelaxed => armw_ptr(fetch_byte_sub, Relaxed);
        AtomicSubPtrAcquire => armw_ptr(fetch_byte_sub, Acquire);
        AtomicSubPtrRelease => armw_ptr(fetch_byte_sub, Release);
        AtomicSubPtrAcqrel => armw_ptr(fetch_byte_sub, AcqRel);
        AtomicSubPtrSeqcst => armw_ptr(fetch_byte_sub, SeqCst);
        AtomicAndPtrRelaxed => armw_ptr(fetch_and, Relaxed);
        AtomicAndPtrAcquire => armw_ptr(fetch_and, Acquire);
        AtomicAndPtrRelease => armw_ptr(fetch_and, Release);
        AtomicAndPtrAcqrel => armw_ptr(fetch_and, AcqRel);
        AtomicAndPtrSeqcst => armw_ptr(fetch_and, SeqCst);
        AtomicOrPtrRelaxed => armw_ptr(fetch_or, Relaxed);
        AtomicOrPtrAcquire => armw_ptr(fetch_or, Acquire);
        AtomicOrPtrRelease => armw_ptr(fetch_or, Release);
        AtomicOrPtrAcqrel => armw_ptr(fetch_or, AcqRel);
        AtomicOrPtrSeqcst => armw_ptr(fetch_or, SeqCst);
        AtomicXorPtrRelaxed => armw_ptr(fetch_xor, Relaxed);
        AtomicXorPtrAcquire => armw_ptr(fetch_xor, Acquire);
        AtomicXorPtrRelease => armw_ptr(fetch_xor, Release);
        AtomicXorPtrAcqrel => armw_ptr(fetch_xor, AcqRel);
        AtomicXorPtrSeqcst => armw_ptr(fetch_xor, SeqCst);
        AtomicCxchgPtrRelaxedRelaxed => cxchg_ptr(compare_exchange, Relaxed, Relaxed);
        AtomicCxchgPtrRelaxedAcquire => cxchg_ptr(compare_exchange, Relaxed, Acquire);
        AtomicCxchgPtrRelaxedSeqcst => cxchg_ptr(compare_exchange, Relaxed, SeqCst);
        AtomicCxchgPtrAcquireRelaxed => cxchg_ptr(compare_exchange, Acquire, Relaxed);
        AtomicCxchgPtrAcquireAcquire => cxchg_ptr(compare_exchange, Acquire, Acquire);
        AtomicCxchgPtrAcquireSeqcst => cxchg_ptr(compare_exchange, Acquire, SeqCst);
        AtomicCxchgPtrReleaseRelaxed => cxchg_ptr(compare_exchange, Release, Relaxed);
        AtomicCxchgPtrReleaseAcquire => cxchg_ptr(compare_exchange, Release, Acquire);
        AtomicCxchgPtrReleaseSeqcst => cxchg_ptr(compare_exchange, Release, SeqCst);
        AtomicCxchgPtrAcqrelRelaxed => cxchg_ptr(compare_exchange, AcqRel, Relaxed);
        AtomicCxchgPtrAcqrelAcquire => cxchg_ptr(compare_exchange, AcqRel, Acquire);
        AtomicCxchgPtrAcqrelSeqcst => cxchg_ptr(compare_exchange, AcqRel, SeqCst);
        AtomicCxchgPtrSeqcstRelaxed => cxchg_ptr(compare_exchange, SeqCst, Relaxed);
        AtomicCxchgPtrSeqcstAcquire => cxchg_ptr(compare_exchange, SeqCst, Acquire);
        AtomicCxchgPtrSeqcstSeqcst => cxchg_ptr(compare_exchange, SeqCst, SeqCst);
        AtomicCxchgWeakPtrRelaxedRelaxed => cxchg_ptr(compare_exchange_weak, Relaxed, Relaxed);
        AtomicCxchgWeakPtrRelaxedAcquire => cxchg_ptr(compare_exchange_weak, Relaxed, Acquire);
        AtomicCxchgWeakPtrRelaxedSeqcst => cxchg_ptr(compare_exchange_weak, Relaxed, SeqCst);
        AtomicCxchgWeakPtrAcquireRelaxed => cxchg_ptr(compare_exchange_weak, Acquire, Relaxed);
        AtomicCxchgWeakPtrAcquireAcquire => cxchg_ptr(compare_exchange_weak, Acquire, Acquire);
        AtomicCxchgWeakPtrAcquireSeqcst => cxchg_ptr(compare_exchange_weak, Acquire, SeqCst);
        AtomicCxchgWeakPtrReleaseRelaxed => cxchg_ptr(compare_exchange_weak, Release, Relaxed);
        AtomicCxchgWeakPtrReleaseAcquire => cxchg_ptr(compare_exchange_weak, Release, Acquire);
        AtomicCxchgWeakPtrReleaseSeqcst => cxchg_ptr(compare_exchange_weak, Release, SeqCst);
        AtomicCxchgWeakPtrAcqrelRelaxed => cxchg_ptr(compare_exchange_weak, AcqRel, Relaxed);
        AtomicCxchgWeakPtrAcqrelAcquire => cxchg_ptr(compare_exchange_weak, AcqRel, Acquire);
        AtomicCxchgWeakPtrAcqrelSeqcst => cxchg_ptr(compare_exchange_weak, AcqRel, SeqCst);
        AtomicCxchgWeakPtrSeqcstRelaxed => cxchg_ptr(compare_exchange_weak, SeqCst, Relaxed);
        AtomicCxchgWeakPtrSeqcstAcquire => cxchg_ptr(compare_exchange_weak, SeqCst, Acquire);
        AtomicCxchgWeakPtrSeqcstSeqcst => cxchg_ptr(compare_exchange_weak, SeqCst, SeqCst);
        FenceAcquire => fence(Acquire);
        FenceRelease => fence(Release);
        FenceAcqrel => fence(AcqRel);
        FenceSeqcst => fence(SeqCst);
        CompilerFence => compiler_fence(SeqCst);
        Br => br() -> bool;
        fam BrEq => br_cmp(==) -> bool @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam BrLtS => br_cmp(<) -> bool @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam BrLtU => br_cmp(<) -> bool @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam BrEqImm => br_cmp_imm(==) -> bool @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam BrLtSImm => br_cmp_imm(<) -> bool @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam BrLtUImm => br_cmp_imm(<) -> bool @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam BrGtSImm => br_cmp_imm(>) -> bool @ [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)];
        fam BrGtUImm => br_cmp_imm(>) -> bool @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam SwitchDense => switch_dense() -> usize @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        fam SwitchSparse => switch_sparse() -> usize @ [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)];
        Abort => abort_now() -> !;
        Lpad => lpad();
    } };
}


/// `for_each_handler!`'s expansion of the `fam` entries, one member per step, into the list
/// `$m!` receives.
macro_rules! handler_entries {
    (@fam $m:ident $args:tt [$($acc:tt)*] $f:ident $p:tt $kind:ident () [$($ret:tt)?] [$w:ident ($($pre:tt)*) $(, $ws:ident $wp:tt)*] $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)* ${concat($f, $w, $p)} => $kind($($pre)*) $(-> $ret)?;] $f $p $kind () [$($ret)?] [$($ws $wp),*] $($rest)* }
    };
    (@fam $m:ident $args:tt [$($acc:tt)*] $f:ident $p:tt $kind:ident ($($tail:tt)+) [$($ret:tt)?] [$w:ident ($($pre:tt)*) $(, $ws:ident $wp:tt)*] $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)* ${concat($f, $w, $p)} => $kind($($pre)*, $($tail)+) $(-> $ret)?;] $f $p $kind ($($tail)+) [$($ret)?] [$($ws $wp),*] $($rest)* }
    };
    (@fam $m:ident $args:tt [$($acc:tt)*] $f:ident $p:tt $kind:ident $tail:tt [$($ret:tt)?] [] $($rest:tt)*) => {
        handler_entries! {$m $args [$($acc)*] $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] fam $f:ident * $p:tt => $kind:ident $tail:tt $(-> $ret:tt)? @ [$($ws:tt)*]; $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)*] $f $p $kind $tail [$($ret)?] [$($ws)*] $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] fam $f:ident => $kind:ident $tail:tt $(-> $ret:tt)? @ [$($ws:tt)*]; $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)*] $f "" $kind $tail [$($ret)?] [$($ws)*] $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] $name:ident => $kind:ident $params:tt $(-> $ret:tt)?; $($rest:tt)*) => {
        handler_entries! {$m $args [$($acc)* $name => $kind $params $(-> $ret)?;] $($rest)* }
    };
    ($m:ident ($($args:tt)*) [$($acc:tt)*]) => {
        $m! { ($($args)*) $($acc)* }
    };
}
