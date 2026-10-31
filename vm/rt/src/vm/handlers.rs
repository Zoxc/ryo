// The handler table: every opcode with a handler, with its handler kind, the kind's
// parameters and, unless it is `()`, the handler's return type. Included by interp.rs,
// whose `*_!` body macros implement the kinds. `handlers!` is invoked as
// `for_each_handler!(handlers!())` and receives `Name => kind(params) [-> R]; ...`.
// A family of full_ops.rs is one entry, `fam Add => kind(params) @ [W8(u8), W16(u16)];`: the
// members `AddW8 => kind(u8, params); AddW16 => kind(u16, params);` (`fam Pre * Post` for
// `PreW8Post`), the parameters of each width first. Named width lists stand for the common
// ones (`handler_entries!`): `@ U` all unsigned widths, `@ S` signed, `@ U64`/`@ S64` up to
// W64, `@ AU`/`@ AS` the atomic types, `@ P` the `AtomicPtr` kinds' (`Ptr`, no parameters). `fam Pre * ord L => kind(params) @ AU;` is one family
// per ordering of the named list (`A` all, `L` load, `S` store, `C` the compare-exchange
// success-failure pairs): `Post` is the ordering's name, its `Ordering` variants are appended
// to the parameters.
//
// `full_ops.rs` has no handler for `jmp`, the calls, `ret`, `arg`, `island` and
// `unreachable` (a bare `ud2`); `resume`'s are written apart from the list (interp.rs: in
// assembly off Windows). The list is checked against `full_ops.rs` when built.
// Kinds: integer types select the width and signedness (`i*` for `.s` forms), float
// types the format; `Atomic*` the atomic type; orderings are `core::sync::atomic::Ordering`
// variants. The `*_ptr` atomic kinds are `AtomicPtr`'s: the same machine operations as the
// 64-bit integer ones, but the value is a pointer (with provenance, in the Lean semantics),
// and the read-modify-write ones take a `usize` operand (`fetch_byte_add`, `fetch_or`, ...).
// The SIMD kinds (`vsplat`, `vcmp`, `vmsb`) take the lane type and the lane count.

macro_rules! for_each_handler {
    ($m:ident!($($args:tt)*)) => { handler_entries! { $m ($($args)*) []
        fam Mov => mov() @ U;
        Copy => copy();
        fam Imm => imm() @ U;
        Const => konst();
        Zero => zero();
        fam Load => load() @ U;
        fam Store => store() @ U;
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
        fam Add => bin(wrapping_add) @ U;
        fam Sub => bin(wrapping_sub) @ U;
        fam Mul => bin(wrapping_mul) @ U64;
        fam DivS => bin_fn(unchecked_div) @ S64;
        fam DivU => bin_fn(unchecked_div) @ U64;
        fam RemS => bin_fn(unchecked_rem) @ S64;
        fam RemU => bin_fn(unchecked_rem) @ U64;
        fam And => binop(&) @ U;
        fam Or => binop(|) @ U;
        fam Xor => binop(^) @ U;
        fam Shl => shift(wrapping_shl) @ U;
        fam ShrS => shift(wrapping_shr) @ S;
        fam ShrU => shift(wrapping_shr) @ U;
        fam Eq => cmp(==) @ U;
        fam Ne => cmp(!=) @ U;
        fam LtS => cmp(<) @ S;
        fam LtU => cmp(<) @ U;
        fam LeS => cmp(<=) @ S;
        fam LeU => cmp(<=) @ U;
        fam Cmp3S => cmp3() @ S;
        fam Cmp3U => cmp3() @ U;
        fam Rotl => rot(rotate_left) @ U;
        fam Rotr => rot(rotate_right) @ U;
        fam AddImm => bin_imm(wrapping_add) @ U;
        fam SubImm => bin_imm(wrapping_sub) @ U;
        fam MulImm => bin_imm(wrapping_mul) @ U64;
        fam AndImm => binop_imm(&) @ U;
        fam OrImm => binop_imm(|) @ U;
        fam XorImm => binop_imm(^) @ U;
        fam ShlImm => shift_imm(wrapping_shl) @ U;
        fam ShrSImm => shift_imm(wrapping_shr) @ S;
        fam ShrUImm => shift_imm(wrapping_shr) @ U;
        fam EqImm => cmp_imm(==) @ U;
        fam NeImm => cmp_imm(!=) @ U;
        fam LtSImm => cmp_imm(<) @ S;
        fam LtUImm => cmp_imm(<) @ U;
        fam LeSImm => cmp_imm(<=) @ S;
        fam LeUImm => cmp_imm(<=) @ U;
        fam GtSImm => cmp_imm(>) @ S;
        fam GtUImm => cmp_imm(>) @ U;
        fam GeSImm => cmp_imm(>=) @ S;
        fam GeUImm => cmp_imm(>=) @ U;
        fam Neg => un(wrapping_neg) @ U;
        fam Not => un(not) @ U;
        fam Ctpop => count(count_ones) @ U;
        fam Ctlz => count(leading_zeros) @ U;
        fam Cttz => count(trailing_zeros) @ U;
        fam Bitreverse => un(reverse_bits) @ U;
        fam AddOvfS => ovf(overflowing_add) @ S;
        fam AddOvfU => ovf(overflowing_add) @ U;
        fam SubOvfS => ovf(overflowing_sub) @ S;
        fam SubOvfU => ovf(overflowing_sub) @ U;
        fam MulOvfS => ovf(overflowing_mul) @ S64;
        fam MulOvfU => ovf(overflowing_mul) @ U64;
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
        fam CvtI2fS * F32 => cvt(f32) @ S;
        fam CvtI2fS * F64 => cvt(f64) @ S;
        fam CvtI2fU * F32 => cvt(f32) @ U;
        fam CvtI2fU * F64 => cvt(f64) @ U;
        CvtF2fF32F64 => cvt(f32, f64);
        CvtF2fF64F32 => cvt(f64, f32);
        fam AtomicLoad * ord L => aload() @ AU;
        fam AtomicStore * ord S => astore() @ AU;
        fam AtomicXchg * ord A => armw(swap) @ AU;
        fam AtomicAdd * ord A => armw(fetch_add) @ AU;
        fam AtomicSub * ord A => armw(fetch_sub) @ AU;
        fam AtomicAnd * ord A => armw(fetch_and) @ AU;
        fam AtomicOr * ord A => armw(fetch_or) @ AU;
        fam AtomicXor * ord A => armw(fetch_xor) @ AU;
        fam AtomicNand * ord A => armw(fetch_nand) @ AU;
        fam AtomicMin * ord A => armw(fetch_min) @ AS;
        fam AtomicMax * ord A => armw(fetch_max) @ AS;
        fam AtomicUmin * ord A => armw(fetch_min) @ AU;
        fam AtomicUmax * ord A => armw(fetch_max) @ AU;
        fam AtomicCxchg * ord C => cxchg(compare_exchange) @ AU;
        fam AtomicCxchgWeak * ord C => cxchg(compare_exchange_weak) @ AU;
        fam AtomicLoad * ord L => aload_ptr() @ P;
        fam AtomicStore * ord S => astore_ptr() @ P;
        fam AtomicXchg * ord A => armw_ptr(swap) @ P;
        fam AtomicAdd * ord A => armw_ptr(fetch_byte_add) @ P;
        fam AtomicSub * ord A => armw_ptr(fetch_byte_sub) @ P;
        fam AtomicAnd * ord A => armw_ptr(fetch_and) @ P;
        fam AtomicOr * ord A => armw_ptr(fetch_or) @ P;
        fam AtomicXor * ord A => armw_ptr(fetch_xor) @ P;
        fam AtomicCxchg * ord C => cxchg_ptr(compare_exchange) @ P;
        fam AtomicCxchgWeak * ord C => cxchg_ptr(compare_exchange_weak) @ P;
        FenceAcquire => fence(Acquire);
        FenceRelease => fence(Release);
        FenceAcqrel => fence(AcqRel);
        FenceSeqcst => fence(SeqCst);
        CompilerFence => compiler_fence(SeqCst);
        Br => br() -> bool;
        fam BrEq => br_cmp(==) -> bool @ U;
        fam BrLtS => br_cmp(<) -> bool @ S;
        fam BrLtU => br_cmp(<) -> bool @ U;
        fam BrEqImm => br_cmp_imm(==) -> bool @ U;
        fam BrLtSImm => br_cmp_imm(<) -> bool @ S;
        fam BrLtUImm => br_cmp_imm(<) -> bool @ U;
        fam BrGtSImm => br_cmp_imm(>) -> bool @ S;
        fam BrGtUImm => br_cmp_imm(>) -> bool @ U;
        fam SwitchDense => switch_dense() -> usize @ U;
        fam SwitchSparse => switch_sparse() -> usize @ U;
        Abort => abort_now() -> !;
        Lpad => lpad();
    } };
}


/// `for_each_handler!`'s expansion of the `fam` entries, one member (and one ordering) per
/// step, into the list `$m!` receives.
macro_rules! handler_entries {
    // The named width lists (`@ U`).
    (@fam $m:ident $args:tt $acc:tt $f:ident $p:tt $kind:ident $tail:tt $ret:tt U $($rest:tt)*) => {
        handler_entries! {@fam $m $args $acc $f $p $kind $tail $ret [W8(u8), W16(u16), W32(u32), W64(u64), W128(u128)] $($rest)* }
    };
    (@fam $m:ident $args:tt $acc:tt $f:ident $p:tt $kind:ident $tail:tt $ret:tt S $($rest:tt)*) => {
        handler_entries! {@fam $m $args $acc $f $p $kind $tail $ret [W8(i8), W16(i16), W32(i32), W64(i64), W128(i128)] $($rest)* }
    };
    (@fam $m:ident $args:tt $acc:tt $f:ident $p:tt $kind:ident $tail:tt $ret:tt U64 $($rest:tt)*) => {
        handler_entries! {@fam $m $args $acc $f $p $kind $tail $ret [W8(u8), W16(u16), W32(u32), W64(u64)] $($rest)* }
    };
    (@fam $m:ident $args:tt $acc:tt $f:ident $p:tt $kind:ident $tail:tt $ret:tt S64 $($rest:tt)*) => {
        handler_entries! {@fam $m $args $acc $f $p $kind $tail $ret [W8(i8), W16(i16), W32(i32), W64(i64)] $($rest)* }
    };
    (@fam $m:ident $args:tt $acc:tt $f:ident $p:tt $kind:ident $tail:tt $ret:tt AU $($rest:tt)*) => {
        handler_entries! {@fam $m $args $acc $f $p $kind $tail $ret [W8(AtomicU8, u8), W16(AtomicU16, u16), W32(AtomicU32, u32), W64(AtomicU64, u64)] $($rest)* }
    };
    (@fam $m:ident $args:tt $acc:tt $f:ident $p:tt $kind:ident $tail:tt $ret:tt AS $($rest:tt)*) => {
        handler_entries! {@fam $m $args $acc $f $p $kind $tail $ret [W8(AtomicI8, i8), W16(AtomicI16, i16), W32(AtomicI32, i32), W64(AtomicI64, i64)] $($rest)* }
    };
    (@fam $m:ident $args:tt $acc:tt $f:ident $p:tt $kind:ident $tail:tt $ret:tt P $($rest:tt)*) => {
        handler_entries! {@fam $m $args $acc $f $p $kind $tail $ret [Ptr()] $($rest)* }
    };
    // One member per step.
    (@fam $m:ident $args:tt [$($acc:tt)*] $f:ident $p:tt $kind:ident () [$($ret:tt)?] [$w:ident ($($pre:tt)*) $(, $ws:ident $wp:tt)*] $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)* ${concat($f, $w, $p)} => $kind($($pre)*) $(-> $ret)?;] $f $p $kind () [$($ret)?] [$($ws $wp),*] $($rest)* }
    };
    (@fam $m:ident $args:tt [$($acc:tt)*] $f:ident $p:tt $kind:ident ($($tail:tt)+) [$($ret:tt)?] [$w:ident () $(, $ws:ident $wp:tt)*] $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)* ${concat($f, $w, $p)} => $kind($($tail)+) $(-> $ret)?;] $f $p $kind ($($tail)+) [$($ret)?] [$($ws $wp),*] $($rest)* }
    };
    (@fam $m:ident $args:tt [$($acc:tt)*] $f:ident $p:tt $kind:ident ($($tail:tt)+) [$($ret:tt)?] [$w:ident ($($pre:tt)*) $(, $ws:ident $wp:tt)*] $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)* ${concat($f, $w, $p)} => $kind($($pre)*, $($tail)+) $(-> $ret)?;] $f $p $kind ($($tail)+) [$($ret)?] [$($ws $wp),*] $($rest)* }
    };
    (@fam $m:ident $args:tt [$($acc:tt)*] $f:ident $p:tt $kind:ident $tail:tt [$($ret:tt)?] [] $($rest:tt)*) => {
        handler_entries! {$m $args [$($acc)*] $($rest)* }
    };
    // The named ordering lists (`ord A`): name suffix and `Ordering` variants.
    ($m:ident $args:tt $acc:tt fam $f:ident * ord A $($rest:tt)*) => {
        handler_entries! {$m $args $acc fam $f * ord [Relaxed(Relaxed), Acquire(Acquire), Release(Release), Acqrel(AcqRel), Seqcst(SeqCst)] $($rest)* }
    };
    ($m:ident $args:tt $acc:tt fam $f:ident * ord L $($rest:tt)*) => {
        handler_entries! {$m $args $acc fam $f * ord [Relaxed(Relaxed), Acquire(Acquire), Seqcst(SeqCst)] $($rest)* }
    };
    ($m:ident $args:tt $acc:tt fam $f:ident * ord S $($rest:tt)*) => {
        handler_entries! {$m $args $acc fam $f * ord [Relaxed(Relaxed), Release(Release), Seqcst(SeqCst)] $($rest)* }
    };
    ($m:ident $args:tt $acc:tt fam $f:ident * ord C $($rest:tt)*) => {
        handler_entries! {$m $args $acc fam $f * ord [
            RelaxedRelaxed(Relaxed, Relaxed), RelaxedAcquire(Relaxed, Acquire), RelaxedSeqcst(Relaxed, SeqCst),
            AcquireRelaxed(Acquire, Relaxed), AcquireAcquire(Acquire, Acquire), AcquireSeqcst(Acquire, SeqCst),
            ReleaseRelaxed(Release, Relaxed), ReleaseAcquire(Release, Acquire), ReleaseSeqcst(Release, SeqCst),
            AcqrelRelaxed(AcqRel, Relaxed), AcqrelAcquire(AcqRel, Acquire), AcqrelSeqcst(AcqRel, SeqCst),
            SeqcstRelaxed(SeqCst, Relaxed), SeqcstAcquire(SeqCst, Acquire), SeqcstSeqcst(SeqCst, SeqCst)
        ] $($rest)* }
    };
    // One ordering per step: a `fam` entry with the ordering appended to the parameters.
    ($m:ident $args:tt $acc:tt fam $f:ident * ord [] => $kind:ident $tail:tt @ $ws:ident; $($rest:tt)*) => {
        handler_entries! {$m $args $acc $($rest)* }
    };
    ($m:ident $args:tt $acc:tt fam $f:ident * ord [$o:tt ($($v:ident),+) $(, $os:tt $vs:tt)*] => $kind:ident () @ $ws:ident; $($rest:tt)*) => {
        handler_entries! {$m $args $acc fam $f * $o => $kind($($v),+) @ $ws; fam $f * ord [$($os $vs),*] => $kind() @ $ws; $($rest)* }
    };
    ($m:ident $args:tt $acc:tt fam $f:ident * ord [$o:tt ($($v:ident),+) $(, $os:tt $vs:tt)*] => $kind:ident ($($t:tt)+) @ $ws:ident; $($rest:tt)*) => {
        handler_entries! {$m $args $acc fam $f * $o => $kind($($t)+, $($v),+) @ $ws; fam $f * ord [$($os $vs),*] => $kind($($t)+) @ $ws; $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] fam $f:ident * $p:tt => $kind:ident $tail:tt $(-> $ret:tt)? @ [$($ws:tt)*]; $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)*] $f $p $kind $tail [$($ret)?] [$($ws)*] $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] fam $f:ident * $p:tt => $kind:ident $tail:tt $(-> $ret:tt)? @ $ws:ident; $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)*] $f $p $kind $tail [$($ret)?] $ws $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] fam $f:ident => $kind:ident $tail:tt $(-> $ret:tt)? @ [$($ws:tt)*]; $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)*] $f "" $kind $tail [$($ret)?] [$($ws)*] $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] fam $f:ident => $kind:ident $tail:tt $(-> $ret:tt)? @ $ws:ident; $($rest:tt)*) => {
        handler_entries! {@fam $m $args [$($acc)*] $f "" $kind $tail [$($ret)?] $ws $($rest)* }
    };
    ($m:ident $args:tt [$($acc:tt)*] $name:ident => $kind:ident $params:tt $(-> $ret:tt)?; $($rest:tt)*) => {
        handler_entries! {$m $args [$($acc)* $name => $kind $params $(-> $ret)?;] $($rest)* }
    };
    ($m:ident ($($args:tt)*) [$($acc:tt)*]) => {
        $m! { ($($args)*) $($acc)* }
    };
}
