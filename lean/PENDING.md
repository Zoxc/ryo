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

- One image per codegen unit (CGU plan stage 4). A crate with VM code now has an image per
  rustc CGU with VM functions (`<cgu>.ryo_image`, symbol and header CGU hash from that CGU's
  name); `rustc-ryo` no longer forces `-Ccodegen-units=1`. A call of a VM function in
  another CGU's image is a `call.sym` (or `tail_call.ptr` through `addr.sym`) through a symbol
  slot whose `Abs64` relocation names that function's (hidden) symbol, the form calls of
  native Rust functions already have: no new instruction, but a `call.sym` slot may now hold
  another image's VM function, so proofs that want to treat such calls as VM calls need
  multi-image code memory (the step provenance.md leaves open); as opaque native calls they
  are covered as before. `#[inline]` copies are lowered once per CGU, each image its own
  copy. `RYO_DUMP_LEAN`'s certificate file lists the functions of all images, in CGU then
  image order, each symbol once, and `islands` over all images; `check-image` should take
  several image objects of one crate (each with its entry). Island instances are now
  `WeakODR` + `Hidden` in every CGU that uses them (cg_llvm side, outside the model).
  Commit: "One image per codegen unit".
