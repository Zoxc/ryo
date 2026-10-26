# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.


- The SSA tier's inliner splices callees whose `ret` has more parts than the call site
  reads (an sret callee returning its pointer to a site with no results): the extra parts
  are dropped. Only matters if the Lean model covers the SSA tier. Commit: "JIT inliner:
  allow a callee to return parts the call doesn't use" (431f12e).

- The SSA tier's small block copies (`Kind::Copy` decoding and `jit::opt::copies`) now go
  up to 128 bytes (`MAX_COPY`), not 64. Only matters if the Lean model covers the SSA tier.
  Commit: "JIT: do block copies of up to 128 bytes as loads and stores" (2c86394).

- Image header gains `func_flags` (`[u8]` per function, bits always/never/cold/hint:
  `FUNC_INLINE_ALWAYS = 1`, `FUNC_INLINE_NEVER = 2`, `FUNC_COLD = 4`, `FUNC_INLINE_HINT = 8`)
  after `sym_flags`, so `Header` grows 136 → 144 bytes and the parts after it move
  (`lean/Ryo/Obj/Image.lean` `readHeader`, the `parts` dump line); the reader checks its count
  equals the function count, and `validate` rejects unknown bits. Nothing in the VM semantics
  reads it (the JIT's inliner does). Commit: "Carry inline and cold attributes in the image".

- Inline `add.ovf`/`sub.ovf`/`mul.ovf` (w8-w64) now store the result first and the flag
  second (`... st d; setcc cl; mov [o], cl`), as `opSem` and the handlers write them, so
  overlapping `d`/`o` end with the same bytes. `inline_sound_ovf`'s `RangesDisjoint`
  hypothesis (Proofs/Inline/Ovf.lean, `SoundD`) can be dropped: swap the store order in
  the modelled sequences and prove plain `Sound`. Decoding: the result's
  store no longer ends the sequence (the flag's does), `d` is the second-to-last frame
  operand and `o` the last, and a dropped (dead) result store sits mid-sequence, before
  the `setcc cl` (the decoder continues past it; re-encoding's `drop_store` names it). The regenerated
  `RyoTest/DecodeReducedVectors.lean` and `ViewVectors.lean` have the new order, so
  `lake test` fails (decode_reduced and view vectors with ovf ops)
  until the Lean decoder (`decodeReduced`'s inline sequences) reads it. Commit: "Store the
  overflow ops' result before their flag".
