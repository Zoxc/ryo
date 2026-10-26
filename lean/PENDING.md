# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- The SSA tier's frame cut (`jit/alloca.rs`) joins an `addr` at an escaped object's end
  (the object escaping at that `addr`, unless one escaping there starts at that address;
  with none escaping there, any escaped object ending there) to the object's alloca, so
  that the end pointer keeps its place relative to the object under any layout (it was a
  1-byte access of the next byte, in whatever alloca held it). Only matters if the Lean model covers the SSA tier. Commit: "JIT: keep end pointers with
  their escaped object".


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

- The four `compiler_fence.{acquire,release,acqrel,seqcst}` opcodes are one `compiler_fence`
  with no ordering; the backend maps every ordering of `atomic_singlethreadfence` to it. The
  generated tables are regenerated; any hand-written spec or proof naming the per-ordering
  forms should use the single op. Commit: "Merge the compiler_fence opcodes into one".

- `bswap.w8` is gone from the opcode list (a one-byte `bswap` was already lowered to
  `mov.w8`). The generated tables are regenerated; any hand-written spec or proof naming
  `bswap.w8` should drop it. Commit: "Remove the bswap.w8 opcode".

- Image writer: `ImageWriter::set_eh_pointers(EhPointers::Abs8)` (Mach-O images) writes
  the CIE's L and R encodings as `DW_EH_PE_pcrel | DW_EH_PE_absptr` (0x10), and each FDE's
  `pc_begin`, `pc_range` and LSDA pointer as 8 bytes (augmentation length 8), with
  `RelocKind::Pc64` for the pointers. The default (`Sdata4`, ELF and the JIT, `eh_cie` and
  `eh_fde`) is unchanged. Only matters if the Lean `.eh_frame` model (`Ryo/Obj/EhFrame.lean`)
  is to cover Mach-O images. Commit: "image: 8-byte .eh_frame pointers for Mach-O images".
