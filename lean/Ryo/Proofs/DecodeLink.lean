/-
Ryo.Proofs.DecodeLink — the decoder-to-step links of M3 `decode_sound` (aot.md §C2): when
`decodeReduced` accepts an instruction at a byte position, the code there is the item list the
instruction's shape lemma runs (`CodeAt`, `Ryo.X86.Fetch`), with the operands it takes, and the
branch targets the decoder reads as byte positions are, as R's instruction indices, the
positions of those instructions.

- `DecodeLink.Bytes`: an item `decodeItem` reads from an object's code is `ItemAt` in memory
  holding that code linked (`RelocLoaded`: the relocated fields patched), in the frame-pointer
  form, given the relocations sorted, the code below `2 ^ 32` bytes and no relocated field
  reaching into the item from before (`Boundary`, carried from item to item); items read one
  after the other (`Dec`) are `CodeAt` (`codeAt_of_dec`).
- `DecodeLink.Run`: reading `DM` runs: binds, `for` loop invariants, `PosOnly`, `take`.
- `DecodeLink.Targets`: `posOf r t`, the position instruction `t` was read at; `reducedOf`'s
  instructions are the protos with targets as indices that `posOf` maps back
  (`reducedOf_insns`), so a target read as `tgt.toNat` is an index `t` with `pos32 r t = tgt`
  (the shape lemmas' `pos t = tgt`).
- `DecodeLink.Read`: what `insn` (handler calls, `ret`, `unreachable`, `jmp`, `island`),
  `thenSeq`, `table`, `retSeq`, `islandCall`, `handlerArgs` and `argInsn` read.
- `DecodeLink.Links`: the links per shape in memory (`link_handler` with `ThenAt` for `op`,
  `lpad`, `br`, `switch`, `trap`; `link_jmp`, `link_unreachable`, `link_ret`, `link_island`,
  `link_arg`).
- `DecodeLink.Call`: `callInsn`'s calls and tail calls against `Call.callSeq`/`Call.tailSeq`
  (`link_call`), given the argument loads' `xmm` fields in range (`XmmOk`).
- `DecodeLink.Inline`: an inline sequence without a dropped store is `cache.emit cand`, `cand`
  the `sequence` of its class and operands (`link_inline`, `CacheStep.inline_step_cached`'s
  items), then the `jcc` of a branch class.
- `DecodeLink.Items`: what the candidate parsers return: every decoded item is `XmmOk`
  (`decodeItem_xmmOk`), so `link_call_ok` is `link_call` without that hypothesis; without a frame
  pointer the item in memory is `spFrame F` of the decoded one (`decodeItem_itemAt_sp`,
  `LinkOkSp.dec`).
- `DecodeLink.Arg`: `link_arg_exact`, `link_arg` with `ArgReg.of? r.toNat true = some a`
  (`argInsn_bounds`).
- `DecodeLink.Drop`: inline sequences with dropped stores (`DecDrop`, `SkipAt`,
  `link_inline_drop`) and an inline branch's target operand (`inline_targets`,
  `inline_branch_index`).
- `DecodeLink.Ops`: the island operand array in memory, `OpsAt` from `opsArray`
  (`opsAt_of_opsArray`, given the rodata loaded, `RoLoaded`).
- `DecodeLink.Loop`: the instruction loop as a chain of iterations (`Iters`, `instructions_read`,
  `read_instructions`): each proto read at its position after the padding and counter check,
  with the cache and dropped stores it was read with.
- `DecodeLink.Bounds`: code the bounds check accepts (`decodeBounded`, `Decoded.boundsOk`)
  satisfies `FrameBounds c frameTop` (`decode_frameBounds`, `frameBounds_of_boundsOk`), and so
  for any larger end up to `2 ^ 31` (`FrameBounds.mono`).

**Not here.** The step lemmas for the frame form without a frame pointer (the links give its
items, `Item.spFrame`; `RRel` and the shape lemmas assume `rbp = fp`); the dead-store step
(running the kept items of `SkipAt` against `cache.emit`'s output); a relocation starting in a
jump table's padding.
-/
import Ryo.Proofs.DecodeLink.Bytes
import Ryo.Proofs.DecodeLink.Run
import Ryo.Proofs.DecodeLink.Targets
import Ryo.Proofs.DecodeLink.Read
import Ryo.Proofs.DecodeLink.Links
import Ryo.Proofs.DecodeLink.Call
import Ryo.Proofs.DecodeLink.Inline
import Ryo.Proofs.DecodeLink.Items
import Ryo.Proofs.DecodeLink.Arg
import Ryo.Proofs.DecodeLink.Drop
import Ryo.Proofs.DecodeLink.Ops
import Ryo.Proofs.DecodeLink.Loop
import Ryo.Proofs.DecodeLink.Bounds
