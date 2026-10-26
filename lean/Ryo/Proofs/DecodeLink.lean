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

**Not here.** The instruction loop (`instructions`: which function read each proto, with the
cursor where, the boundary carried along, the padding and counter checks skipped; a proto's
`pos`, the branch target, is before a loop head's counter check, its items after it); inline
sequences with a dropped store, and the `jcc` target against the `target` operand; the
no-frame-pointer form (`decodeItem` returns `[rbp + d]` for code holding `[rsp + F + d]`);
`XmmOk` and `link_arg`'s bounds, which need the candidate parsers' output ranges; a relocation
starting in a jump table's padding; the island operand array in memory (`OpsAt` from
`opsArray`).
-/
import Ryo.Proofs.DecodeLink.Bytes
import Ryo.Proofs.DecodeLink.Run
import Ryo.Proofs.DecodeLink.Targets
import Ryo.Proofs.DecodeLink.Read
import Ryo.Proofs.DecodeLink.Links
import Ryo.Proofs.DecodeLink.Call
import Ryo.Proofs.DecodeLink.Inline
