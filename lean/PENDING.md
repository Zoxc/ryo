# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- The SSA tier's frame cut (`jit/alloca.rs`) joins an `addr` at an escaped object's end
  (the object escaping at that `addr`, unless one escaping there starts at that address;
  with none escaping there, any escaped object ending there) to the object's alloca, so
  that the end pointer keeps its place relative to the object under any layout (it was a
  1-byte access of the next byte, in whatever alloca held it). Only matters if the Lean model covers the SSA tier. Commit: "JIT: keep end pointers with
  their escaped object".
- The JIT's SSA tier compiles PE code: its frames always save `rdi`/`rsi` at `fp - 8`/`fp - 16`
  (pushed after `rbp`), set `rbp` with `lea rbp, [rsp + K]` after the pushes, store saves
  that can't be pushed into the caller's home space or free slots within 240 bytes below
  `rbp`, and describe it all with a PE `UNWIND_INFO` from the shared encoder
  `image::pe_unwind_codes` (which `pe_unwind_info` now uses, byte-identical). Calls get 32
  bytes of shadow space; Win64 argument registers. Only matters if the Lean model covers the
  SSA tier's frames or the PE unwind info. Commit: "JIT SSA: compile PE code with Win64 frames".


- The SSA tier's inliner splices callees whose `ret` has more parts than the call site
  reads (an sret callee returning its pointer to a site with no results): the extra parts
  are dropped. Only matters if the Lean model covers the SSA tier. Commit: "JIT inliner:
  allow a callee to return parts the call doesn't use" (431f12e).

- The SSA tier's small block copies (`Kind::Copy` decoding and `jit::opt::copies`) now go
  up to 128 bytes (`MAX_COPY`), not 64. Only matters if the Lean model covers the SSA tier.
  Commit: "JIT: do block copies of up to 128 bytes as loads and stores" (2c86394).

- Image writer: `ImageWriter::set_eh_pointers(EhPointers::Abs8)` (Mach-O images) writes
  the CIE's L and R encodings as `DW_EH_PE_pcrel | DW_EH_PE_absptr` (0x10), and each FDE's
  `pc_begin`, `pc_range` and LSDA pointer as 8 bytes (augmentation length 8), with
  `RelocKind::Pc64` for the pointers. The default (`Sdata4`, ELF and the JIT, `eh_cie` and
  `eh_fde`) is unchanged. Only matters if the Lean `.eh_frame` model (`Ryo/Obj/EhFrame.lean`)
  is to cover Mach-O images. Commit: "image: 8-byte .eh_frame pointers for Mach-O images".

- The SSA tier decodes the `div`/`rem` and variable-shift handlers (`div.{s,u}.wN`,
  `rem.{s,u}.wN`, `shl.wN`, `shr.{s,u}.wN`) as native `BinOp`s (`DivS`/`DivU`/`RemS`/`RemU`,
  shifts with a variable amount masked to the width), allocated with fixed-register
  clobbers (`regalloc::clobbers`). Only matters if the Lean model covers the SSA tier.
  Commit: "JIT SSA: fixed registers for div, rem, variable shifts and mul".

- Image header gains `const_relocs` (a `Span` at offset 140, after `jit_records`, so
  `Header` grows 144 → 152 bytes; the part itself is `[u32]`, 4-aligned, laid out last in the
  read-only section): the constant pool offset of every `Abs64` relocation inside the pool,
  strictly increasing. `Image::parse` checks it in bounds and aligned (`"constant
  relocations"`), `validate` that each field is 8-aligned in the section, inside the pool and
  after the one before (`BadConstReloc(i)`). `lean/Ryo/Obj/Image.lean`: `readHeader`, the
  checks, and the summary's `parts` line, which now ends `... call_sites <span> const_relocs
  <span>` (`scripts/lean-decode-ref` prints it). The image check should require the table to
  equal exactly the pool's `R_X86_64_64` relocation offsets (`Image.world` already iterates
  them). Nothing in the VM semantics reads it (the JIT's constant-load fold does). Commit:
  "Image: list the constant pool's relocated fields".
