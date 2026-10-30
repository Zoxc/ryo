# ryo design overview

ryo is a rustc codegen backend for fast development builds. It compiles each function's MIR
cheaply, straight to simple machine code. A JIT inside the built program then recompiles the
functions that turn out to be hot into optimized code. There are two code forms: the AOT
code, a register VM's instructions encoded as x86-64, and the JIT's SSA IR, built from that
code. Operations the VM doesn't cover are compiled by LLVM.

The detailed design docs start at [design/README.md](design/README.md).

## AOT: VM instructions as machine code

The backend lowers MIR to the instructions of a VM ([lowering.md](design/lowering.md),
[instructions.md](design/instructions.md)). The VM is a register machine whose registers are
slots in the function's frame, addressed by their offset from the frame pointer, `$-12`.
Instructions are fully typed when they're lowered: each one carries its operand widths
(`w8` … `w128`, `f32`, `f64`), so nothing is checked at run time. Here is `fib` from
`bench/codegen/fib.txt`:

```
fn fib (frame 96, args 0, ret 8)
    arg $-12, 4
    br.lt.u.imm.w32! $-12, 2, L0
    zext.w32.w64 $-8, $-12
    jmp L9
L0:
    imm.w32 $-84, 1
    sub.ovf.u.w32 $-36, $-32, $-12, $-84
    ...
    call $-24, fn2, 8, [...]
```

These instructions are never stored or interpreted. The lowering encodes them directly as
x86-64 ([vm.md](design/vm.md#encoding)). Simple instructions are inlined as a few native
instructions working on the frame slots, and the others become calls of small handlers
`ryo_h_<Opcode>` in the runtime crate `ryo_rt`, with their operands passed in argument
registers. Each instruction stands alone: values live in frame slots, not in registers
across instructions, which keeps the encoding fast and simple (`bench/codegen/fib.s`):

```
fn fib
    inc     qword ptr [jit_record]   ; JIT counter
    jns     L6
    sub     rsp,68h
    mov     [rsp+54h],edi            ; arg $-12
    cmp     dword ptr [rsp+54h],2    ; br.lt.u.imm.w32
    jae     L1
    ...
```

A VM function is a real native function: it has the signature's calling convention, its
own symbol, a native frame on the native stack, and native unwind info. Native code and VM
code call each other directly, with no interpreter loop and no transitions between them
([stubs.md](design/stubs.md)).

The encoding can be decoded. Reading the machine code back gives the *reduced* instruction
set: the VM instructions that were inlined, plus one `handler` instruction for each handler
call ([vm.md](design/vm.md#reduced-instructions)). So the code that runs is also the JIT's
input, and the image doesn't need a separate bytecode.

### Islands and native functions

The VM covers the common operations. Anything else, like an `extern "C"` call, an
intrinsic or a SIMD operation, runs as an **island**: an instance of a generic template in
`ryo_rt`, compiled by LLVM and called by the `island` instruction. The function around it
stays in the VM. Only what no template can express, like inline asm or a C-variadic call,
makes a whole function native, compiled by `rustc_codegen_llvm`
([stubs.md](design/stubs.md#islands-vm--native)).

### Images

Each crate's VM code goes into one object file, its **image**, together with constants, a
symbol table, unwind info and a *JIT record* per function. The image reaches everything it
uses RIP-relative, so a call between images needs no setup. At the final link the backend
adds a registry object that hands every image to the runtime
([vm.md](design/vm.md#image-format), [backend.md](design/backend.md#pipeline)).

## JIT: SSA IR

Every AOT function counts its calls and loop iterations in its JIT record. When a counter
gets past its threshold, the function jumps into the runtime, which queues the function for
the JIT thread (`ryo_jit`) ([jit.md](design/jit.md)). The thread decodes the function's
machine code back to reduced instructions and compiles them through an SSA IR
([jit.md](design/jit.md#the-ssa-pipeline)):

- **Construction.** Every frame slot becomes an *alloca* with provenance. Slots that no
  pointer can reach are promoted to SSA values, and the rest stay in memory.
- **IR.** The IR has blocks with parameters instead of phis. Values are untyped 1–8 byte
  bit vectors, or 16-byte vectors. Operations cover the native instructions (`Bin`, `Cmp`,
  `PtrAdd`, loads and stores), calls, islands, and `HCall`, a handler call kept as a call.
  Calls that can unwind end their block with an `invoke`, which has a normal edge and an
  edge to the landing pad.
- **Optimization.** The JIT cleans up the IR and does things like folding the overflow
  checks the lowering emits, inlining and SIMD. General LICM and loop rotation are there
  but off by default. Nothing is speculated, so the AOT code always stays a valid fallback.
- **Back end.** A register allocator assigns registers, and the JIT emits x86-64 with its
  own frame layout and unwind info.

The `fib` above in the SSA IR (`bench/codegen/fib.jit-ssa-post.txt`), where the slots have
become values:

```
b0(v0:4): ; Entry
    br LtU.w4 v0, 0x2 ? b1() : b2()
b1(): ; Body
    v2:8 = Ext { from: 4, to: 8, sx: false } (v0)
    jmp b9(v2)
b2(): ; Body
    v4:4 = Bin(Sub, 4) (v0, 0x1)
    ...
```

A function the SSA IR doesn't handle, about one in 500 in the test corpus, is decoded and
encoded again without its counters instead.

### Installing and OSR

The new code is placed near its image. It is published by redirecting the slots in the
function's JIT record, so the AOT code is never patched, and calls from then on enter the
JIT code. The JIT code's frame layout can differ from the AOT code's. A call already running
the AOT code, such as a long loop, moves over at its next loop head through an OSR entry,
which converts the AOT frame into the JIT code's state ([jit.md](design/jit.md#osr)).
