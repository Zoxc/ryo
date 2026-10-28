# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- The register cache no longer records zero-extension after `bsf`/`bsr` at any width (Commit:
  "Asm: No zero-extension known after bsf/bsr"); a zero source leaves the destination
  unmodified (SDM BSF/BSR), so at 32 bits the upper half isn't known to be zero until the
  following `cmovz`. `cacheSafe` can accept 32-bit `bsf`/`bsr`, and the `hcount` hypothesis on
  `inline_step_cached` can go.

- Several ryo runtimes (Commit: "Rt: ABI tag, private runtime per module, run-time merge"):
  the image header gains `abi` (u64 at 160, FNV-1a of the ABI tag) and `anchor` (u64 at 168,
  relocated against `__ryo_registry_anchor_<tag>`; the separate `ryo_anchor` slot section is
  gone); the header is 176 bytes. Runtime symbols carry the tag (`ryo_h_<Op>_<tag>`, trips,
  `ryo_probe_stack_<tag>`, `ryo_vm_register_<tag>`, now mangled as an internal symbol); the
  registration section is `ryo_images_<tag>`; the registry constructor is `lea rdi, start;
  lea rsi, stop; lea rdx, anchor; jmp ryo_vm_register`, i.e. `register(start, end, anchor)`
  skips images of another anchor and aborts on another `abi`. The Lean image and registry
  checks (`Ryo/Obj/Image.lean`, `Ryo/Check/Image/Registry.lean`) need the new layout, names
  and constructor form.

- Proofs for the inline forms added by "Inline variable shifts and rotates" (5fe50cc), "Inline
  bswap" (b388245), "Inline division and remainder" (e04359a), "Inline cttz and ctlz"
  (33feaa4), "Inline the dense switch index" (7915238) and "Inline cmp3" (d91a246). The model
  has them (items `shiftCl`, `bswap`, `div`, `cdq`, `bsf`, `bsr`, `cmov`, `setccR` with
  encode/decode/exec, `Uniq.fam_*` for each; classes `shiftVar`, `div`, `count`, `cmp3`,
  `bswap` in `Asm.classOfParts`/`sequence`/`classifyNew`, the cache effects, `Asm.denseIndex`
  and `DecodeReduced.denseSwitch`), and `RyoTest/Inline.lean` runs the sequences against the
  handlers' methods; what is left:
  - `Sound`/`SoundC` for the new classes (`Ryo/Proofs/Inline.lean`: `laterClass` lists them;
    `frameOnly` is `false` for them, so `inline_sound` doesn't cover them). `div` changes `rdx`
    (a `SoundC` with `clobbers` `[0, 1, 2]`, as unsigned 64-bit `mul.ovf`); its proof needs
    MIR's "no zero divisor, no `MIN / -1`" from `opSem` (UB there); `count` goes through
    `bsf`/`bsr` of zero writing `ctx.undef`, which the `cmovz` overwrites (32/64 bits) or the
    guard bit rules out (8/16).
  - The register cache proofs for the new items: `cacheSafe`, `update_inv`, `onlyARB` (`div`'s
    `rdx`, `cdq`), `exec_swap` (with `div` pinned to `rax` like `mulQ`: `isMulQ`,
    `emitHead_mulQ`); then drop the `hlater : laterClass cls = false` hypotheses of
    `sequence_ok`, `sequence_cacheSafe`, `cached_of` (`Ryo/Proofs/CacheMem.lean`),
    `inline_step_cached` (`Ryo/Proofs/CacheStep.lean`) and `inline_step_cached_ops`
    (`RyoProofs/InlineOk.lean`). `exec_withRm` already covers `div`'s cached divisor.
  - The dense switch: `InsnRead.dense` (`Ryo/Proofs/DecodeLink/Read.lean`) only records that
    `denseSwitch` read it, and `link_handler` (`Links.lean`) takes the hypothesis `hnd` that the
    instruction isn't one. Left: its link (the code is `denseIndex op s base n` then
    `Switch.switchItems`, from `denseScan`/`table`), and a step lemma that the items compute
    `switch.dense`'s case index in `rax` (`s - base` wrapping at the width, `n` if not below
    `n`) before `exec_switch`, in place of the handler contract.
  - The co-simulation harness (`lean/harness`) doesn't generate the new items yet (it must not
    generate `bsf`/`bsr` of zero, where the model writes `ctx.undef` and the CPU keeps the
    register).

- The inline dense switch index (`InsnRead.dense`, `DecodeReduced.denseSwitch`) in the
  decode-soundness composition: `bs_insn`, `bodySim_unreachable` and `bodySim_jmp` cover it;
  left is `bodySim_dense` (`Ryo/Proofs/DecodeSound.lean`, `sorry`), which needs the step
  lemma for the index items (see the inline-forms entry). Commit: "Asm, JIT SSA: inline
  shift/rotate/bswap/div/count/switch-index/cmp3 forms and native JIT ops".
