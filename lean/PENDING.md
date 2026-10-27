# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- PE pad region (design/vm.md#unwinding): on PE the lowering emits the cleanup blocks last
  (`lower/mod.rs`, `blocks`): the body's blocks, the body's terminate stubs and their landing
  pads, then (if there is a cleanup landing pad) the region: the cleanup landing pads, the
  cleanup blocks, their own terminate stubs and pads. The encoder (`Asm::begin_region`;
  `encode`/`encode_reduced` start it at `asm::pe_region_start`, the first cleanup landing
  pad) lays it out after the counter stubs, behind its entry `sub rsp, 40; jmp r11`
  (`Item::JmpR11`, `41 ff e3`, new); in it `resume x` is `add rsp, 40; ret` (no call site:
  the decoder gives it a Continue cleanup entry and the landing pads' exception slot), island
  calls don't move `rsp`, and loop heads have neither counter checks nor padding (the
  decoders' heads exclude them). Nothing may branch across the region's start or fall into
  it, region calls have no cleanup pads, catching pads stay on their call's side
  (`EncodeError::BadRegion`). On PE every call with a landing pad that ends its instruction
  (a call storing no result, a region island) is followed by a 1-byte `nop`. `Encoded::region`
  and `FuncCode::region` give the region's offset; `.pdata` gets a third entry over it with
  `pe_region_unwind_info`. ELF code is unchanged. Matters if the Lean model covers PE code
  (the decoder model, `DecodeReduced.lean`, reads `resume` as a handler call and PE islands
  with their shadow space); `lean_reduced_vectors.rs` gives its PE functions no landing pads
  meanwhile. Commit: "Backend: PE cleanup code in a pad region after the body".

- Image writer: `ImageWriter::set_eh_pointers(EhPointers::Abs8)` (Mach-O images) writes
  the CIE's L and R encodings as `DW_EH_PE_pcrel | DW_EH_PE_absptr` (0x10), and each FDE's
  `pc_begin`, `pc_range` and LSDA pointer as 8 bytes (augmentation length 8), with
  `RelocKind::Pc64` for the pointers. The default (`Sdata4`, ELF and the JIT, `eh_cie` and
  `eh_fde`) is unchanged. Only matters if the Lean `.eh_frame` model (`Ryo/Obj/EhFrame.lean`)
  is to cover Mach-O images. Commit: "image: 8-byte .eh_frame pointers for Mach-O images".
  Out of scope for the model: its object readers (`readElf`/`readImageObject`) only read
  ELF objects, so a Mach-O image's `Abs8` `.eh_frame` never reaches `Ryo/Obj/EhFrame.lean`.

