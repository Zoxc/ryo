# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- The JIT's SSA tier packs the callee-saved registers' save slots (8 bytes each, 8-aligned,
  at the frame's top) and, when no alloca is pinned above them, pushes and pops them (the
  FDE rows: `DW_CFA_def_cfa_offset` after each push without a frame pointer, then
  `DW_CFA_offset` per register). Only matters if the Lean model covers the SSA tier's
  frames or unwind rows. Commit: "JIT SSA: push and pop callee-saved registers".
- Lowering: `ptr_offset_from(_unsigned)` and `exact_div` by a constant `v = ±2^k * m`
  (`m` odd, w8-w64) lower to `shr.s/u.imm k` and `mul.imm` by the inverse of `m` mod 2^N
  (negated for negative `v`) instead of `div.s/u`. Only equal to the division on exact
  multiples: a C1' rule against the intrinsics' semantics (inexact is UB), with
  `m * inv = 1 mod 2^N` checkable per site. Also `/ 1` -> `mov`, `% 1` and signed `% -1` ->
  `imm 0`, signed `/ -1` -> `mul.imm` all-ones (the `rem` forms drop the read of `x`, a
  refinement). Commit: "Lower exact division by constants to shifts and inverse multiplies".

- Lowering: unsigned w8-w32 `/` and `%` by a constant `b` (not a power of two) lower to
  `zext` to w64, `mul.imm M`, `shr.u.imm p`, `trunc` (and `x - q * b` for `%`) when
  `M = ceil(2^p / b) < 2^(64-N)` and `M*b - 2^p <= 2^(p-N)` (both checkable per site;
  otherwise the handler stays). A C1' rule with that side condition and one Nat lemma.
  Commit: "Lower small unsigned division by constants to multiply-shift".

- Lowering: `rotate_left`/`rotate_right` by a constant `n` (w8-w64) lower to
  `shl.imm c`, `shr.u.imm N-c`, `or` with `c = n mod N` (`rotate_right` uses `N - c`), or a
  `mov` for `c = 0`; `bswap.w8` lowers to `mov.w8` (a refinement: `mov` keeps uninit bytes
  where `bswap` was UB). C1' rules; `BitVec.rotateLeft` unfolding lemma. Commit: "Lower
  rotates by a constant to shifts and an or".

- Lowering: `copy_nonoverlapping`, `copy` and `write_bytes` with a constant count, of at
  most 48 bytes in total, and `typed_swap_nonoverlapping` of a type of at most 48 bytes, and
  an all-equal-bytes `Repeat` of at most 48 bytes into memory, lower to `load`/`store` pieces
  (all loads into a frame temp before the stores, so `copy`'s overlap is exact) or `store`
  pieces of a byte pattern (`imm`, or `zext.w8.w64` + `mul.imm 0x0101..01`) instead of
  `memcpy`/`memmove`/`memset`. A C1' rule for the intrinsic statement (whole-range
  dereferenceability becomes per piece: a refinement of UB). Commit: "Lower constant-length
  copy and set intrinsics to load/store pieces".

- The SSA tier's inliner splices callees whose `ret` has more parts than the call site
  reads (an sret callee returning its pointer to a site with no results): the extra parts
  are dropped. Only matters if the Lean model covers the SSA tier. Commit: "JIT inliner:
  allow a callee to return parts the call doesn't use" (431f12e).

- The SSA tier's small block copies (`Kind::Copy` decoding and `jit::opt::copies`) now go
  up to 128 bytes (`MAX_COPY`), not 64. Only matters if the Lean model covers the SSA tier.
  Commit: "JIT: do block copies of up to 128 bytes as loads and stores" (2c86394).
