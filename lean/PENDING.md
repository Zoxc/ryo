# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- The JIT's SSA tier decodes the three inline address instructions as `Kind::RefAddr` and
  builds a pure `Op::RefAddr(ref, ind)` (rip-relative `lea`, or the slot load and with `ind`
  one more load) instead of `hcall.reg`; LVN keys it. Only matters if the Lean model covers
  the SSA tier. Commit: "Give the JIT SSA tier a pure op for rip-relative addresses".

- Split up-counting JIT counters: a JIT record has a call counter `ctr_e` at offset 0 and
  a loop counter `ctr_l` at offset 56 (`jit_len` is gone; `JIT_LOOP_CTR`), which the writer
  starts at `-JIT_ENTRY_THRESHOLD` (625) and `-JIT_THRESHOLD` (10 000). The entry's check is
  `inc qword [rip + rec]; jns stub` (`Item::CtrInc(false)`, relocated against `Ref::Rec`),
  a loop head's `inc qword [rip + rec + 56]; jns stub` (`Item::CtrInc(true)`,
  `Ref::RecLoopCtr`), replacing `sub qword [rip + ctr], k; js` (`CtrSub`, `Ref::RecCtr`,
  `ENTRY_COUNT` are gone); the prologue starts at byte 9. The runtime biases the counters
  by the record's state (`±JIT_BIAS`). The generated tables and vectors are regenerated
  (`entryCount` became `jitLoopCtr`, `ctrSub` became `ctrInc`, `recordCtr`
  `recordLoopCtr`), so `lake build` fails until the model follows: the x86 model and
  decoder (`Ryo/Vm/DecodeReduced.lean`), the image check (`Ryo/Check/Image/Relocs.lean`,
  `RyoTest/ImageCheck.lean`) and `lean/docs/aot.md`. Commit: "Split the JIT counters into
  up-counting call and loop counters".

- The image's scope and dropped-store tables are gone: each function has an instruction list
  instead (`asm::list`, design/vm.md "Instruction list"), a byte stream of delta-encoded
  entries holding its branch targets, scopes, dropped stores and the inline sequences the
  register cache emitted non-plainly (opcode and cache selector). `Header` has `lists`
  (bytes) in place of `scopes` and no `dropped`; `FuncEntry` has `list` (byte offset,
  length) in place of `scopes` and no `dropped`; `ScopeEntry`, `DroppedEntry` and
  `SCOPE_LEND` are gone, `ImageError::BadList(func)` replaces `BadScope`/`BadDropped`.
  `decode_linked` takes the list and reads the code in one pass, the cache cleared at the
  list's targets (checked to be exactly the branch targets afterwards), a listed sequence
  inverted directly (`Cache::invert`); `decode`/`decode_reduced` are unchanged (two passes,
  the vectors too). The Lean image reader (`Ryo/Obj/Image.lean`, `Ryo/Check/Image/Funcs.lean`,
  `Ryo/Vm/DecodeObj.lean`, `RyoTest/Obj.lean`) and `lean-decode-ref`'s summary lines
  (`lists`, `list <bytes>`) need to follow. Layout after the version removal: `lists` 96,
  `call_sites` 104, `fixup_area` 116, `mode` 120, `jit_records` 124, header size 136;
  `FuncEntry` 36 bytes, `list` 20, `call_sites` 28. Commit: "Replace the scope and dropped-store
  tables with per-function instruction lists".

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
