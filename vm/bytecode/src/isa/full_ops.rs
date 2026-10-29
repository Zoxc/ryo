// The opcode list: the single source of truth for the instruction set (design/instructions.md).
// Each entry: `Variant = "mnemonic" shape { operand: Kind, ... }`, operands in order. Kinds
// and shapes are documented in full.rs. A `fam` entry is a family of widths (`define_ops!`):
// `fam Add = "add" .. @ [W8, W16]` is `AddW8` (`add.w8`) then `AddW16` (`add.w16`), and
// `ImmW` its members' immediate of their width. Opcode values are assigned in list order,
// so any edit here changes the encoding.
//
// Conventions: `d` destination slot, `s`/`a`/`b` source slots, `m` memory operand, `p` a
// slot holding a pointer, `o` the flag slot of overflow ops and compare-exchange, `t` branch
// target, `neg` branch polarity. `.imm` forms take an immediate of the width.

define_ops! {
    // ---- data movement ----
    fam Mov = "mov" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    Copy = "copy" op { d: Slot, s: Slot, len: U32 },
    fam Imm = "imm" op { d: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    Const = "const" op { d: Slot, k: Const, len: U32 },
    Zero = "zero" op { d: Slot, len: U32 },
    fam Load = "load" op { d: Slot, m: Mem } @ [W8, W16, W32, W64, W128],
    fam Store = "store" op { m: Mem, s: Slot } @ [W8, W16, W32, W64, W128],
    LoadCopy = "load.copy" op { d: Slot, m: Mem, len: U32 },
    StoreCopy = "store.copy" op { m: Mem, s: Slot, len: U32 },
    Memcpy = "memcpy" op { dp: Slot, sp: Slot, n: Slot },
    Memmove = "memmove" op { dp: Slot, sp: Slot, n: Slot },
    Memset = "memset" op { dp: Slot, b: Slot, n: Slot },
    Fill = "fill" op { d: Slot, k: Const, elem_size: U32, count: U32 },

    // ---- addresses ----
    Addr = "addr" op { d: Slot, s: Slot },
    AddrSym = "addr.sym" op { d: Slot, sym: Sym },
    AddrSymInd = "addr.sym.ind" op { d: Slot, sym: Sym },
    AddrConst = "addr.const" op { d: Slot, a: Abs },
    PtrAdd = "ptr.add" op { d: Slot, p: Slot, imm: I64 },
    PtrIndex = "ptr.index" op { d: Slot, p: Slot, i: Slot, stride: U32 },

    // ---- integer arithmetic ----
    fam Add = "add" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Sub = "sub" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Mul = "mul" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64],
    fam DivS = "div.s" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64],
    fam DivU = "div.u" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64],
    fam RemS = "rem.s" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64],
    fam RemU = "rem.u" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64],
    fam And = "and" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Or = "or" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Xor = "xor" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Shl = "shl" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam ShrS = "shr.s" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam ShrU = "shr.u" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Eq = "eq" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Ne = "ne" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam LtS = "lt.s" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam LtU = "lt.u" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam LeS = "le.s" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam LeU = "le.u" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Cmp3S = "cmp3.s" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Cmp3U = "cmp3.u" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Rotl = "rotl" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam Rotr = "rotr" op { d: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam AddImm = "add.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam SubImm = "sub.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam MulImm = "mul.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64],
    fam AndImm = "and.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam OrImm = "or.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam XorImm = "xor.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam ShlImm = "shl.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam ShrSImm = "shr.s.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam ShrUImm = "shr.u.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam EqImm = "eq.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam NeImm = "ne.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam LtSImm = "lt.s.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam LtUImm = "lt.u.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam LeSImm = "le.s.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam LeUImm = "le.u.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam GtSImm = "gt.s.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam GtUImm = "gt.u.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam GeSImm = "ge.s.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam GeUImm = "ge.u.imm" op { d: Slot, a: Slot, imm: ImmW } @ [W8, W16, W32, W64, W128],
    fam Neg = "neg" op { d: Slot, a: Slot } @ [W8, W16, W32, W64, W128],
    fam Not = "not" op { d: Slot, a: Slot } @ [W8, W16, W32, W64, W128],
    fam Ctpop = "ctpop" op { d: Slot, a: Slot } @ [W8, W16, W32, W64, W128],
    fam Ctlz = "ctlz" op { d: Slot, a: Slot } @ [W8, W16, W32, W64, W128],
    fam Cttz = "cttz" op { d: Slot, a: Slot } @ [W8, W16, W32, W64, W128],
    fam Bitreverse = "bitreverse" op { d: Slot, a: Slot } @ [W8, W16, W32, W64, W128],
    fam AddOvfS = "add.ovf.s" op { d: Slot, o: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam AddOvfU = "add.ovf.u" op { d: Slot, o: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam SubOvfS = "sub.ovf.s" op { d: Slot, o: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam SubOvfU = "sub.ovf.u" op { d: Slot, o: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64, W128],
    fam MulOvfS = "mul.ovf.s" op { d: Slot, o: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64],
    fam MulOvfU = "mul.ovf.u" op { d: Slot, o: Slot, a: Slot, b: Slot } @ [W8, W16, W32, W64],
    fam Bswap = "bswap" op { d: Slot, a: Slot } @ [W16, W32, W64, W128],

    // ---- floating point ----
    FaddF32 = "fadd.f32" op { d: Slot, a: Slot, b: Slot },
    FsubF32 = "fsub.f32" op { d: Slot, a: Slot, b: Slot },
    FmulF32 = "fmul.f32" op { d: Slot, a: Slot, b: Slot },
    FdivF32 = "fdiv.f32" op { d: Slot, a: Slot, b: Slot },
    FremF32 = "frem.f32" op { d: Slot, a: Slot, b: Slot },
    FeqF32 = "feq.f32" op { d: Slot, a: Slot, b: Slot },
    FneF32 = "fne.f32" op { d: Slot, a: Slot, b: Slot },
    FltF32 = "flt.f32" op { d: Slot, a: Slot, b: Slot },
    FleF32 = "fle.f32" op { d: Slot, a: Slot, b: Slot },
    FminF32 = "fmin.f32" op { d: Slot, a: Slot, b: Slot },
    FmaxF32 = "fmax.f32" op { d: Slot, a: Slot, b: Slot },
    CopysignF32 = "copysign.f32" op { d: Slot, a: Slot, b: Slot },
    FnegF32 = "fneg.f32" op { d: Slot, a: Slot },
    FabsF32 = "fabs.f32" op { d: Slot, a: Slot },
    FaddF64 = "fadd.f64" op { d: Slot, a: Slot, b: Slot },
    FsubF64 = "fsub.f64" op { d: Slot, a: Slot, b: Slot },
    FmulF64 = "fmul.f64" op { d: Slot, a: Slot, b: Slot },
    FdivF64 = "fdiv.f64" op { d: Slot, a: Slot, b: Slot },
    FremF64 = "frem.f64" op { d: Slot, a: Slot, b: Slot },
    FeqF64 = "feq.f64" op { d: Slot, a: Slot, b: Slot },
    FneF64 = "fne.f64" op { d: Slot, a: Slot, b: Slot },
    FltF64 = "flt.f64" op { d: Slot, a: Slot, b: Slot },
    FleF64 = "fle.f64" op { d: Slot, a: Slot, b: Slot },
    FminF64 = "fmin.f64" op { d: Slot, a: Slot, b: Slot },
    FmaxF64 = "fmax.f64" op { d: Slot, a: Slot, b: Slot },
    CopysignF64 = "copysign.f64" op { d: Slot, a: Slot, b: Slot },
    FnegF64 = "fneg.f64" op { d: Slot, a: Slot },
    FabsF64 = "fabs.f64" op { d: Slot, a: Slot },

    // ---- SIMD (128-bit vectors) ----
    VsplatI8x16 = "vsplat.i8x16" op { d: Slot, s: Slot },
    VeqI8x16 = "veq.i8x16" op { d: Slot, a: Slot, b: Slot },
    VltSI8x16 = "vlt.s.i8x16" op { d: Slot, a: Slot, b: Slot },
    VmsbI8x16 = "vmsb.i8x16" op { d: Slot, a: Slot },

    // ---- conversions ----
    ZextW8W16 = "zext.w8.w16" op { d: Slot, s: Slot },
    SextW8W16 = "sext.w8.w16" op { d: Slot, s: Slot },
    ZextW8W32 = "zext.w8.w32" op { d: Slot, s: Slot },
    SextW8W32 = "sext.w8.w32" op { d: Slot, s: Slot },
    ZextW8W64 = "zext.w8.w64" op { d: Slot, s: Slot },
    SextW8W64 = "sext.w8.w64" op { d: Slot, s: Slot },
    ZextW8W128 = "zext.w8.w128" op { d: Slot, s: Slot },
    SextW8W128 = "sext.w8.w128" op { d: Slot, s: Slot },
    ZextW16W32 = "zext.w16.w32" op { d: Slot, s: Slot },
    SextW16W32 = "sext.w16.w32" op { d: Slot, s: Slot },
    ZextW16W64 = "zext.w16.w64" op { d: Slot, s: Slot },
    SextW16W64 = "sext.w16.w64" op { d: Slot, s: Slot },
    ZextW16W128 = "zext.w16.w128" op { d: Slot, s: Slot },
    SextW16W128 = "sext.w16.w128" op { d: Slot, s: Slot },
    ZextW32W64 = "zext.w32.w64" op { d: Slot, s: Slot },
    SextW32W64 = "sext.w32.w64" op { d: Slot, s: Slot },
    ZextW32W128 = "zext.w32.w128" op { d: Slot, s: Slot },
    SextW32W128 = "sext.w32.w128" op { d: Slot, s: Slot },
    ZextW64W128 = "zext.w64.w128" op { d: Slot, s: Slot },
    SextW64W128 = "sext.w64.w128" op { d: Slot, s: Slot },
    TruncW16W8 = "trunc.w16.w8" op { d: Slot, s: Slot },
    TruncW32W8 = "trunc.w32.w8" op { d: Slot, s: Slot },
    TruncW32W16 = "trunc.w32.w16" op { d: Slot, s: Slot },
    TruncW64W8 = "trunc.w64.w8" op { d: Slot, s: Slot },
    TruncW64W16 = "trunc.w64.w16" op { d: Slot, s: Slot },
    TruncW64W32 = "trunc.w64.w32" op { d: Slot, s: Slot },
    TruncW128W8 = "trunc.w128.w8" op { d: Slot, s: Slot },
    TruncW128W16 = "trunc.w128.w16" op { d: Slot, s: Slot },
    TruncW128W32 = "trunc.w128.w32" op { d: Slot, s: Slot },
    TruncW128W64 = "trunc.w128.w64" op { d: Slot, s: Slot },
    fam CvtF2iSatSF32 = "cvt.f2i.sat.s.f32" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    fam CvtF2iSatSF64 = "cvt.f2i.sat.s.f64" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    fam CvtF2iSatUF32 = "cvt.f2i.sat.u.f32" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    fam CvtF2iSatUF64 = "cvt.f2i.sat.u.f64" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    fam CvtI2fS * F32 = "cvt.i2f.s" * ".f32" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    fam CvtI2fS * F64 = "cvt.i2f.s" * ".f64" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    fam CvtI2fU * F32 = "cvt.i2f.u" * ".f32" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    fam CvtI2fU * F64 = "cvt.i2f.u" * ".f64" op { d: Slot, s: Slot } @ [W8, W16, W32, W64, W128],
    CvtF2fF32F64 = "cvt.f2f.f32.f64" op { d: Slot, s: Slot },
    CvtF2fF64F32 = "cvt.f2f.f64.f32" op { d: Slot, s: Slot },


    // ---- atomics ----
    fam AtomicLoad * Relaxed = "atomic.load" * ".relaxed" op { d: Slot, p: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicLoad * Acquire = "atomic.load" * ".acquire" op { d: Slot, p: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicLoad * Seqcst = "atomic.load" * ".seqcst" op { d: Slot, p: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicStore * Relaxed = "atomic.store" * ".relaxed" op { p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicStore * Release = "atomic.store" * ".release" op { p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicStore * Seqcst = "atomic.store" * ".seqcst" op { p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXchg * Relaxed = "atomic.xchg" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXchg * Acquire = "atomic.xchg" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXchg * Release = "atomic.xchg" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXchg * Acqrel = "atomic.xchg" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXchg * Seqcst = "atomic.xchg" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAdd * Relaxed = "atomic.add" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAdd * Acquire = "atomic.add" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAdd * Release = "atomic.add" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAdd * Acqrel = "atomic.add" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAdd * Seqcst = "atomic.add" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicSub * Relaxed = "atomic.sub" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicSub * Acquire = "atomic.sub" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicSub * Release = "atomic.sub" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicSub * Acqrel = "atomic.sub" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicSub * Seqcst = "atomic.sub" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAnd * Relaxed = "atomic.and" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAnd * Acquire = "atomic.and" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAnd * Release = "atomic.and" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAnd * Acqrel = "atomic.and" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicAnd * Seqcst = "atomic.and" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicOr * Relaxed = "atomic.or" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicOr * Acquire = "atomic.or" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicOr * Release = "atomic.or" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicOr * Acqrel = "atomic.or" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicOr * Seqcst = "atomic.or" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXor * Relaxed = "atomic.xor" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXor * Acquire = "atomic.xor" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXor * Release = "atomic.xor" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXor * Acqrel = "atomic.xor" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicXor * Seqcst = "atomic.xor" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicNand * Relaxed = "atomic.nand" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicNand * Acquire = "atomic.nand" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicNand * Release = "atomic.nand" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicNand * Acqrel = "atomic.nand" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicNand * Seqcst = "atomic.nand" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMin * Relaxed = "atomic.min" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMin * Acquire = "atomic.min" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMin * Release = "atomic.min" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMin * Acqrel = "atomic.min" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMin * Seqcst = "atomic.min" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMax * Relaxed = "atomic.max" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMax * Acquire = "atomic.max" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMax * Release = "atomic.max" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMax * Acqrel = "atomic.max" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicMax * Seqcst = "atomic.max" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmin * Relaxed = "atomic.umin" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmin * Acquire = "atomic.umin" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmin * Release = "atomic.umin" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmin * Acqrel = "atomic.umin" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmin * Seqcst = "atomic.umin" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmax * Relaxed = "atomic.umax" * ".relaxed" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmax * Acquire = "atomic.umax" * ".acquire" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmax * Release = "atomic.umax" * ".release" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmax * Acqrel = "atomic.umax" * ".acqrel" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicUmax * Seqcst = "atomic.umax" * ".seqcst" op { d: Slot, p: Slot, s: Slot } @ [W8, W16, W32, W64],
    fam AtomicCxchg * RelaxedRelaxed = "atomic.cxchg" * ".relaxed.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * RelaxedAcquire = "atomic.cxchg" * ".relaxed.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * RelaxedSeqcst = "atomic.cxchg" * ".relaxed.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * AcquireRelaxed = "atomic.cxchg" * ".acquire.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * AcquireAcquire = "atomic.cxchg" * ".acquire.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * AcquireSeqcst = "atomic.cxchg" * ".acquire.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * ReleaseRelaxed = "atomic.cxchg" * ".release.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * ReleaseAcquire = "atomic.cxchg" * ".release.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * ReleaseSeqcst = "atomic.cxchg" * ".release.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * AcqrelRelaxed = "atomic.cxchg" * ".acqrel.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * AcqrelAcquire = "atomic.cxchg" * ".acqrel.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * AcqrelSeqcst = "atomic.cxchg" * ".acqrel.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * SeqcstRelaxed = "atomic.cxchg" * ".seqcst.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * SeqcstAcquire = "atomic.cxchg" * ".seqcst.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchg * SeqcstSeqcst = "atomic.cxchg" * ".seqcst.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * RelaxedRelaxed = "atomic.cxchg.weak" * ".relaxed.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * RelaxedAcquire = "atomic.cxchg.weak" * ".relaxed.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * RelaxedSeqcst = "atomic.cxchg.weak" * ".relaxed.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * AcquireRelaxed = "atomic.cxchg.weak" * ".acquire.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * AcquireAcquire = "atomic.cxchg.weak" * ".acquire.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * AcquireSeqcst = "atomic.cxchg.weak" * ".acquire.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * ReleaseRelaxed = "atomic.cxchg.weak" * ".release.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * ReleaseAcquire = "atomic.cxchg.weak" * ".release.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * ReleaseSeqcst = "atomic.cxchg.weak" * ".release.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * AcqrelRelaxed = "atomic.cxchg.weak" * ".acqrel.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * AcqrelAcquire = "atomic.cxchg.weak" * ".acqrel.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * AcqrelSeqcst = "atomic.cxchg.weak" * ".acqrel.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * SeqcstRelaxed = "atomic.cxchg.weak" * ".seqcst.relaxed" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * SeqcstAcquire = "atomic.cxchg.weak" * ".seqcst.acquire" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    fam AtomicCxchgWeak * SeqcstSeqcst = "atomic.cxchg.weak" * ".seqcst.seqcst" op { d: Slot, o: Slot, p: Slot, old: Slot, new: Slot } @ [W8, W16, W32, W64, Ptr],
    FenceAcquire = "fence.acquire" op {  },
    FenceRelease = "fence.release" op {  },
    FenceAcqrel = "fence.acqrel" op {  },
    FenceSeqcst = "fence.seqcst" op {  },
    CompilerFence = "compiler_fence" op {  },

    // ---- control flow ----
    // Branches take a polarity: `neg` (`!` after the mnemonic) branches when the condition is false.
    Jmp = "jmp" jmp { t: Target },
    Br = "br" br { s: Slot, neg: Neg, t: Target },
    fam BrEq = "br.eq" br { a: Slot, b: Slot, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam BrLtS = "br.lt.s" br { a: Slot, b: Slot, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam BrLtU = "br.lt.u" br { a: Slot, b: Slot, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam BrEqImm = "br.eq.imm" br { a: Slot, imm: ImmW, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam BrLtSImm = "br.lt.s.imm" br { a: Slot, imm: ImmW, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam BrLtUImm = "br.lt.u.imm" br { a: Slot, imm: ImmW, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam BrGtSImm = "br.gt.s.imm" br { a: Slot, imm: ImmW, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam BrGtUImm = "br.gt.u.imm" br { a: Slot, imm: ImmW, neg: Neg, t: Target } @ [W8, W16, W32, W64, W128],
    fam SwitchDense = "switch.dense" switch { s: Slot, base: ImmW, default: Target, table: Targets } @ [W8, W16, W32, W64, W128],
    fam SwitchSparse = "switch.sparse" switch { s: Slot, default: Target, cases: CasesW } @ [W8, W16, W32, W64, W128],
    Unreachable = "unreachable" trap {  },
    Abort = "abort" trap {  },

    // ---- calls, returns, islands ----
    Call = "call" call { d: Slot, f: Func, k: U32, a: Words },
    CallSym = "call.sym" call { d: Slot, sym: Sym, k: U32, a: Words },
    CallSymInd = "call.sym.ind" call { d: Slot, sym: Sym, k: U32, a: Words },
    CallPtr = "call.ptr" call { d: Slot, p: Slot, k: U32, a: Words },
    TailCall = "tail_call" tail_call { f: Func, a: Words },
    TailCallPtr = "tail_call.ptr" tail_call { p: Slot, a: Words },
    Ret = "ret" ret { s: Slot, k: U32 },
    Arg = "arg" arg { d: Slot, r: U32 },
    Island = "island" island { isl: Sym, ops: Words },
    Lpad = "lpad" lpad { x: Slot },
    Resume = "resume" trap { x: Slot },
}

// ---- typed families ----
// The width- and format-suffixed opcodes by family, for code that picks an opcode by operation
// and width (the backend's lowering). The tables are built from the mnemonics above at compile
// time: `IntOp::Add.at(Width::W32)` is `AddW32`, and a combination the list lacks (`mul.w128`)
// is `None`.

/// Integer operand widths of the instruction set.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Width {
    W8,
    W16,
    W32,
    W64,
    W128,
}

impl Width {
    pub const ALL: [Width; 5] = [Width::W8, Width::W16, Width::W32, Width::W64, Width::W128];

    /// The width of a scalar of `size` bytes, if the VM has one.
    pub const fn of_size(size: u64) -> Option<Width> {
        Some(match size {
            1 => Width::W8,
            2 => Width::W16,
            4 => Width::W32,
            8 => Width::W64,
            16 => Width::W128,
            _ => return None,
        })
    }

    pub const fn bits(self) -> u32 {
        8 << self as u32
    }

    pub const fn bytes(self) -> u32 {
        self.bits() / 8
    }

    /// Words an immediate of this width takes (`U32` for widths up to 32).
    pub const fn imm_words(self) -> usize {
        match self {
            Width::W8 | Width::W16 | Width::W32 => 1,
            Width::W64 => 2,
            Width::W128 => 4,
        }
    }

    /// `v` truncated to this width.
    pub const fn truncate(self, v: u128) -> u128 {
        if matches!(self, Width::W128) { v } else { v & ((1u128 << self.bits()) - 1) }
    }

    /// The mnemonic component: `w32`.
    pub const fn mnemonic(self) -> &'static str {
        ["w8", "w16", "w32", "w64", "w128"][self as usize]
    }
}

/// Float formats the VM implements (`f16` and `f128` are islands).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum FloatWidth {
    F32,
    F64,
}

impl FloatWidth {
    pub const ALL: [FloatWidth; 2] = [FloatWidth::F32, FloatWidth::F64];

    /// The mnemonic component: `f32`.
    pub const fn mnemonic(self) -> &'static str {
        ["f32", "f64"][self as usize]
    }
}

/// The forms of an integer family: `add.w32`, `add.imm.w32`, `br.eq.w32`, `br.eq.imm.w32`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum IntForm {
    Reg,
    Imm,
    Br,
    BrImm,
}

macro_rules! families {
    ($(#[$m:meta])* $ty:ident { $($name:ident($stem:literal)),* $(,)? }) => {
        $(#[$m])*
        #[derive(Clone, Copy, Debug, PartialEq, Eq)]
        pub enum $ty { $($name),* }

        impl $ty {
            const ALL: &[$ty] = &[$($ty::$name),*];

            /// The mnemonic without the width (and `br`, `imm`) components: `shr.u`.
            pub const fn stem(self) -> &'static str {
                match self { $($ty::$name => $stem),* }
            }
        }
    };
}

families! {
    /// Integer families, suffixed by a [`Width`].
    IntOp {
        Mov("mov"), Imm("imm"), Load("load"), Store("store"),
        Add("add"), Sub("sub"), Mul("mul"), DivS("div.s"), DivU("div.u"), RemS("rem.s"), RemU("rem.u"),
        And("and"), Or("or"), Xor("xor"), Shl("shl"), ShrS("shr.s"), ShrU("shr.u"), Rotl("rotl"), Rotr("rotr"),
        Eq("eq"), Ne("ne"), LtS("lt.s"), LtU("lt.u"), LeS("le.s"), LeU("le.u"),
        GtS("gt.s"), GtU("gt.u"), GeS("ge.s"), GeU("ge.u"), Cmp3S("cmp3.s"), Cmp3U("cmp3.u"),
        Neg("neg"), Not("not"), Ctpop("ctpop"), Ctlz("ctlz"), Cttz("cttz"), Bswap("bswap"), Bitreverse("bitreverse"),
        AddOvfS("add.ovf.s"), AddOvfU("add.ovf.u"), SubOvfS("sub.ovf.s"), SubOvfU("sub.ovf.u"),
        MulOvfS("mul.ovf.s"), MulOvfU("mul.ovf.u"), SwitchDense("switch.dense"), SwitchSparse("switch.sparse"),
    }
}

families! {
    /// Float families, suffixed by a [`FloatWidth`].
    FloatOp {
        Fadd("fadd"), Fsub("fsub"), Fmul("fmul"), Fdiv("fdiv"), Frem("frem"),
        Feq("feq"), Fne("fne"), Flt("flt"), Fle("fle"), Fmin("fmin"), Fmax("fmax"),
        Copysign("copysign"), Fneg("fneg"), Fabs("fabs"),
    }
}

const fn bytes_eq(a: &[u8], b: &[u8]) -> bool {
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

/// `s` without the `.`-separated last component `c`.
const fn strip_last<'a>(s: &'a [u8], c: &[u8]) -> Option<&'a [u8]> {
    if s.len() <= c.len() {
        return None;
    }
    let (head, tail) = s.split_at(s.len() - c.len());
    let (head, dot) = head.split_at(head.len() - 1);
    if dot[0] == b'.' && bytes_eq(tail, c) { Some(head) } else { None }
}

/// The opcode whose mnemonic is `parts` joined by `.`.
const fn find(parts: &[&str]) -> Option<Opcode> {
    let mut i = 0;
    'ops: while i < ALL_OPCODES.len() {
        let op = ALL_OPCODES[i];
        i += 1;
        let mut m = op.mnemonic().as_bytes();
        let mut j = parts.len();
        while j > 1 {
            j -= 1;
            match strip_last(m, parts[j].as_bytes()) {
                Some(h) => m = h,
                None => continue 'ops,
            }
        }
        if bytes_eq(m, parts[0].as_bytes()) {
            return Some(op);
        }
    }
    None
}

/// Each integer family's [`Family`] per [`IntForm`], found by the stem of the family's
/// mnemonic: `add.imm` is `IntOp::Add`'s `Imm` form, `br.eq` `IntOp::Eq`'s `Br` form.
static INT_FAMS: [[Option<Family>; 4]; IntOp::ALL.len()] = {
    let mut t = [[None; 4]; IntOp::ALL.len()];
    let mut i = 0;
    while i < Family::ALL.len() {
        let fam = Family::ALL[i];
        i += 1;
        let fi = FAMILY_INFO[fam as usize];
        let m = match Opcode::from_u16(fi.base) {
            Some(op) => op.mnemonic().as_bytes(),
            None => panic!("a family without opcodes"),
        };
        // The first member's width component.
        let Some(m) = strip_last(m, OpWidth::ALL[fi.mask.trailing_zeros() as usize].mnemonic().as_bytes()) else {
            continue;
        };
        let (m, imm) = match strip_last(m, b"imm") {
            Some(m) => (m, true),
            None => (m, false),
        };
        let (m, br) = if m.len() > 3 && bytes_eq(m.split_at(3).0, b"br.") { (m.split_at(3).1, true) } else { (m, false) };
        let form = match (br, imm) {
            (false, false) => IntForm::Reg,
            (false, true) => IntForm::Imm,
            (true, false) => IntForm::Br,
            (true, true) => IntForm::BrImm,
        };
        let mut f = 0;
        while f < IntOp::ALL.len() {
            if bytes_eq(m, IntOp::ALL[f].stem().as_bytes()) {
                t[f][form as usize] = Some(fam);
            }
            f += 1;
        }
    }
    // Every family exists in some form.
    let mut f = 0;
    while f < IntOp::ALL.len() {
        assert!(
            t[f][0].is_some() || t[f][1].is_some() || t[f][2].is_some() || t[f][3].is_some(),
            "an IntOp family without opcodes"
        );
        f += 1;
    }
    t
};

impl IntOp {
    fn form_at(self, form: IntForm, w: Width) -> Option<Opcode> {
        INT_FAMS[self as usize][form as usize]?.at(OpWidth::ALL[w as usize])
    }

    /// `self` at width `w`: `add.w32`.
    pub fn at(self, w: Width) -> Option<Opcode> {
        self.form_at(IntForm::Reg, w)
    }

    /// The immediate form: `add.imm.w32`.
    pub fn imm_at(self, w: Width) -> Option<Opcode> {
        self.form_at(IntForm::Imm, w)
    }

    /// The compare-and-branch form: `br.eq.w32`.
    pub fn br_at(self, w: Width) -> Option<Opcode> {
        self.form_at(IntForm::Br, w)
    }

    /// The compare-with-immediate-and-branch form: `br.eq.imm.w32`.
    pub fn br_imm_at(self, w: Width) -> Option<Opcode> {
        self.form_at(IntForm::BrImm, w)
    }
}

static FLOAT_OPS: [[Option<Opcode>; 2]; FloatOp::ALL.len()] = {
    let mut t = [[None; 2]; FloatOp::ALL.len()];
    let mut f = 0;
    while f < FloatOp::ALL.len() {
        let mut w = 0;
        while w < 2 {
            t[f][w] = find(&[FloatOp::ALL[f].stem(), FloatWidth::ALL[w].mnemonic()]);
            w += 1;
        }
        assert!(t[f][0].is_some() || t[f][1].is_some(), "a FloatOp family without opcodes");
        f += 1;
    }
    t
};

impl FloatOp {
    /// `self` at format `f`: `fadd.f64`.
    pub fn at(self, f: FloatWidth) -> Option<Opcode> {
        FLOAT_OPS[self as usize][f as usize]
    }
}

/// Integer conversions: `[signed][from][to]`, `trunc` when narrowing, `sext`/`zext` when
/// widening, `None` on the diagonal.
static INT_CASTS: [[[Option<Opcode>; 5]; 5]; 2] = {
    let mut t = [[[None; 5]; 5]; 2];
    let mut k = 0;
    while k < 50 {
        let (s, a, b) = (k / 25, k / 5 % 5, k % 5);
        let name = if b < a {
            "trunc"
        } else if s == 1 {
            "sext"
        } else {
            "zext"
        };
        if a != b {
            t[s][a][b] = find(&[name, Width::ALL[a].mnemonic(), Width::ALL[b].mnemonic()]);
            assert!(t[s][a][b].is_some(), "missing integer conversion");
        }
        k += 1;
    }
    t
};

/// `cvt.f2i.sat.{s,u}.F.W` and `cvt.i2f.{s,u}.W.F`: `[dir][signed][float][int]`, `dir` 0 for
/// `cvt.f2i.sat`, 1 for `cvt.i2f`.
static FLOAT_INT_CASTS: [[[[Option<Opcode>; 5]; 2]; 2]; 2] = {
    let mut t = [[[[None; 5]; 2]; 2]; 2];
    let mut k = 0;
    while k < 20 {
        let (s, f, w) = (k / 10, k / 5 % 2, k % 5);
        let su = if s == 1 { "s" } else { "u" };
        let (fm, wm) = (FloatWidth::ALL[f].mnemonic(), Width::ALL[w].mnemonic());
        t[0][s][f][w] = find(&["cvt.f2i.sat", su, fm, wm]);
        t[1][s][f][w] = find(&["cvt.i2f", su, wm, fm]);
        assert!(t[0][s][f][w].is_some() && t[1][s][f][w].is_some(), "missing float conversion");
        k += 1;
    }
    t
};

/// An integer conversion: `zext`, `sext` (`sx`) or `trunc` from width `from` to `to`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Ext {
    pub from: Width,
    pub to: Width,
    pub sx: bool,
}

/// [`Opcode::ext`] by opcode value.
static EXTS: [Option<Ext>; Opcode::COUNT] = {
    let mut t = [None; Opcode::COUNT];
    let mut k = 0;
    while k < 50 {
        let (s, a, b) = (k / 25, k / 5 % 5, k % 5);
        if let Some(op) = INT_CASTS[s][a][b] {
            t[op as usize] = Some(Ext { from: Width::ALL[a], to: Width::ALL[b], sx: s == 1 && b > a });
        }
        k += 1;
    }
    t
};

/// The integer conditions of the compare and compare-and-branch families.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
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

/// Per family: whether it is an `.imm` form, and whether it is a compare-and-branch.
static FAMILY_FORMS: [(bool, bool); Family::ALL.len()] = {
    let mut t = [(false, false); Family::ALL.len()];
    let mut f = 0;
    while f < t.len() {
        let info = match Opcode::from_u16(FAMILY_INFO[f].base) {
            Some(op) => op.info(),
            None => panic!("a family without opcodes"),
        };
        let imm = !matches!(Family::ALL[f], Family::Imm) && info.operand_index("imm").is_some();
        t[f] = (imm, matches!(info.shape, Shape::Br));
        f += 1;
    }
    t
};

impl Family {

    /// The condition of a compare (`lt.s`, `lt.s.imm`) or compare-and-branch (`br.lt.s`)
    /// family.
    pub const fn cc(self) -> Option<Cc> {
        use Family::*;
        Some(match self {
            Eq | EqImm | BrEq | BrEqImm => Cc::Eq,
            Ne | NeImm => Cc::Ne,
            LtS | LtSImm | BrLtS | BrLtSImm => Cc::LtS,
            LtU | LtUImm | BrLtU | BrLtUImm => Cc::LtU,
            LeS | LeSImm => Cc::LeS,
            LeU | LeUImm => Cc::LeU,
            GtSImm | BrGtSImm => Cc::GtS,
            GtUImm | BrGtUImm => Cc::GtU,
            GeSImm => Cc::GeS,
            GeUImm => Cc::GeU,
            _ => return None,
        })
    }

    /// Whether the family is an `.imm` form: an immediate in place of the operand `b`.
    pub const fn imm(self) -> bool {
        FAMILY_FORMS[self as usize].0
    }

    /// Whether the family is a compare-and-branch (`br` shape).
    pub const fn is_branch(self) -> bool {
        FAMILY_FORMS[self as usize].1
    }

    /// The signedness of the integer families with a `.s` and a `.u` form.
    pub const fn signed(self) -> Option<bool> {
        use Family::*;
        Some(match self {
            DivS | RemS | ShrS | ShrSImm | LtS | LeS | Cmp3S | LtSImm | LeSImm | GtSImm | GeSImm | AddOvfS | SubOvfS | MulOvfS | BrLtS
            | BrLtSImm | BrGtSImm => true,
            DivU | RemU | ShrU | ShrUImm | LtU | LeU | Cmp3U | LtUImm | LeUImm | GtUImm | GeUImm | AddOvfU | SubOvfU | MulOvfU | BrLtU
            | BrLtUImm | BrGtUImm => false,
            _ => return None,
        })
    }
}

impl Opcode {
    /// The integer conversion `self` is (`zext`, `sext`, `trunc`), if it is one.
    pub const fn ext(self) -> Option<Ext> {
        EXTS[self as usize]
    }
}

/// `d = s as <to>` between integer widths: `trunc`, `sext` or `zext`; `None` if `from == to`.
pub fn int_cast_op(from: Width, to: Width, signed: bool) -> Option<Opcode> {
    INT_CASTS[signed as usize][from as usize][to as usize]
}

/// Float to integer, saturating: `cvt.f2i.sat.{s,u}.F.W`.
pub fn cvt_f2i(f: FloatWidth, w: Width, signed: bool) -> Opcode {
    FLOAT_INT_CASTS[0][signed as usize][f as usize][w as usize].unwrap()
}

/// Integer to float: `cvt.i2f.{s,u}.W.F`.
pub fn cvt_i2f(w: Width, f: FloatWidth, signed: bool) -> Opcode {
    FLOAT_INT_CASTS[1][signed as usize][f as usize][w as usize].unwrap()
}

/// Between float formats: `cvt.f2f.A.B`; `None` if `a == b`.
pub fn cvt_f2f(a: FloatWidth, b: FloatWidth) -> Option<Opcode> {
    match (a, b) {
        (FloatWidth::F32, FloatWidth::F64) => Some(Opcode::CvtF2fF32F64),
        (FloatWidth::F64, FloatWidth::F32) => Some(Opcode::CvtF2fF64F32),
        _ => None,
    }
}

/// The opcode with mnemonic `m` (`atomic.load.w32.acquire`), for families with more
/// components than width and format.
pub fn by_mnemonic(m: &str) -> Option<Opcode> {
    ALL_OPCODES.iter().copied().find(|op| op.mnemonic() == m)
}
