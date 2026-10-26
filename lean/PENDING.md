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
