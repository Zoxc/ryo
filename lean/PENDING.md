# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- The JIT's SSA tier decodes the three inline address instructions as `Kind::RefAddr` and
  builds a pure `Op::RefAddr(ref, ind)` (rip-relative `lea`, or the slot load and with `ind`
  one more load) instead of `hcall.reg`; LVN keys it. Only matters if the Lean model covers
  the SSA tier. Commit: "Give the JIT SSA tier a pure op for rip-relative addresses".

- The JIT's SSA tier decodes `copy`, `zero`, `load.copy`, `store.copy` of up to 64 bytes and
  `mov.w128`, `load.w128`, `store.w128` as `Kind::Copy`: pieces cut along the other scalar
  accesses' boundaries, built as plain loads/stores (all reads before all writes) instead of
  handler calls, so copied aggregates promote. Only matters if the Lean model covers the SSA
  tier. Commit: "JIT SSA tier: small block copies as loads and stores".

- Split up-counting JIT counters (commit "Split the JIT counters into up-counting call and
  loop counters"), partly applied: the x86 model (`ctrInc`, `Ref.recordLoopCtr` at
  `loopCtr` = 56, linked fields), `decodeReduced`, the image reader's refs, the unwind check
  and the tests follow. Left: `Ryo/Check/Image/Relocs.lean` still checks a JIT record's
  initial values as the old layout (`ctr` = `JIT_THRESHOLD` at 0, zero elsewhere); it should
  check `ctr_e` = -625 (`-JIT_ENTRY_THRESHOLD`) at 0, `ctr_l` = -10000 at 56 (and
  `RyoTest/ImageCheck.lean`'s record bytes with it); the co-simulation harness
  (`harness/src/cases.rs`, case 16) still emits `ctrSub`/`recordCtr` and should emit
  `{"ctrInc":{"loop":b}}` against `record`/`recordLoopCtr`; `docs/x86.md` ("Counters:
  CtrSub") and `docs/aot.md` still describe `sub; js`.

- The JIT's SSA tier inlines direct calls of the image's functions (`jit::inline`: an
  IR-to-IR splice with landing-pad action substitution, callee allocas appended as
  `Alloca::inlined`, outgoing areas merged) and promotes memory allocas whose address no
  longer escapes (`jit::opt::promote`). Only matters if the Lean model covers the SSA tier;
  the splice and the promotion are the passes to prove or validate. Commit: "Inline
  same-image calls in the JIT's SSA tier".

- The SSA tier's inliner specializes small callees to constant arguments before splicing
  them (`jit::inline::specialize`: the entry parameters' uses replaced by constants, then
  the passes), and weighs sites by the JIT records' counts. Only matters if the Lean model
  covers the SSA tier. Commit: "Weigh inlining by the counters and specialize callees to
  constants".

- JIT call forms (commit "Give JIT calls their callee's form: slot, rel32 or imm64"). The x86
  items gain three JIT-only forms, never decoded: `CallAbs to` (`49 bb imm64; 41 ff d3`,
  `mov r11, imm64; call r11`, 13 bytes, the 8-byte field at +2), `JmpAbs to` (the same with
  `41 ff e3`) and `JmpMem to` (`ff 25 rel32`, 6 bytes, field at +2). `Mode` gains `far_rt`
  (JIT only, never set from an image's mode bits): handler and probe calls become `CallAbs`,
  including the OSR code's probe. The encoder's `call`/`tail_call` emit a function operand
  with a `FUNC_SLOT` (bit 31: `CallMem`/`JmpMem`), `FUNC_NEAR` (bit 30: `Call`/`Jmp`) or
  `FUNC_FAR` (bit 29: `CallAbs`/`JmpAbs`) bit in another form (`asm::FUNC_KINDS`). Images
  never contain these bits, so the AOT model is unchanged. Only `Ryo/X86/Item.lean`,
  `Encode.lean` and the `Mode` structure would need the new cases if the Lean encoder is to
  cover JIT code.

- Proofs to extend (left by the session that applied the entries above; no `sorry` was
  added, the theorems keep their scope):
  - `inline_sound` (`Ryo/Proofs/Inline.lean`) covers no rip-relative address class:
    `addrConst` (`lea r, [rip + k]`), `addrSym` (`mov r, [rip + slot]`) and `addrSymInd`
    (one more `mov r, [r]`), each then `mov [fp + d], r`. `frameOnly` excludes them, as it
    does `ovf`, `mulOvf` and `ext`. Proving them needs `Rel` to say where the constant pool,
    the data area and the symbol slots are (and that a slot holds the symbol's address).
  - Niche discriminants (commit 844ffef, "Lower niche discriminants with plain ops, fuse them
    into switches") lower to plain ops (`eq.imm`/`sub.imm`/`le.u.imm` and a blend), or are
    fused into a `SwitchInt` testing the tag with `br.eq.imm` (`switch.dense` past 4 arms).
    The cert check counts the fused `Discriminant` like a fused compare; nothing proves the
    lowered decoding against `codegen_get_discr` (`Spec/Lang/Representation.lean`).

- The SSA tier gains a check-elimination pass (`jit::opt::checks`, run after the folds): a
  dominator-tree walk with range and `a < b` facts from single-predecessor branch edges turns
  `Ovf` ops that can't overflow into `Bin` (flag constant 0, `BrOvf` a jump) and folds the
  compares and compare-branches the facts decide. Only matters if the Lean model covers the
  SSA tier; each fold is a proof obligation. Commit: "JIT: eliminate checks dominating
  branches decide".
