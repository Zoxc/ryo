# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- Image writer: `ImageWriter::set_eh_pointers(EhPointers::Abs8)` (Mach-O images) writes
  the CIE's L and R encodings as `DW_EH_PE_pcrel | DW_EH_PE_absptr` (0x10), and each FDE's
  `pc_begin`, `pc_range` and LSDA pointer as 8 bytes (augmentation length 8), with
  `RelocKind::Pc64` for the pointers. The default (`Sdata4`, ELF and the JIT, `eh_cie` and
  `eh_fde`) is unchanged. Only matters if the Lean `.eh_frame` model (`Ryo/Obj/EhFrame.lean`)
  is to cover Mach-O images. Commit: "image: 8-byte .eh_frame pointers for Mach-O images".
  Out of scope for the model: its object readers (`readElf`/`readImageObject`) only read
  ELF objects, so a Mach-O image's `Abs8` `.eh_frame` never reaches `Ryo/Obj/EhFrame.lean`.

- The SSA tier's inliner skips an accepted call site that an earlier splice pruned (the
  code after a callee that never returns, or a landing pad no copied call unwinds to); it
  used to panic and leave the whole function in AOT code (`Vec::extend_with`). Only matters
  if the Lean model covers the SSA tier. Commit: "JIT inliner: skip call sites an earlier
  splice pruned".

- The SSA tier inlines more callees of other images (`inline::rebase`): an island becomes
  a call of the island's address in the JIT's call form (`Island::isl` is now a
  `CallTarget`: `Sym` in the unit's image, or `Func` with a `FUNC_KINDS` bit), a
  `call.sym.ind` a `Load` of the slot's value and a `CallTarget::Ptr` call of it, and a
  handler's code constant argument (`Arg::Ro`, sparse switch cases) an `Arg::Imm` of its
  address in the callee image's code constants (`Env::addr` takes `Ref::Ro`). Only matters
  if the Lean model covers the SSA tier. Commit: "JIT: inline islands, indirect symbol calls
  and sparse switches across images".
