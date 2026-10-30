# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- Frame-pointer handler set (Commit: "Rt: Build a frame-pointer handler set, drop fp-rbp"):
  `ryo_rt` has no `fp-rbp` feature and no `FP_ARG` / `ryo_rt_fp_arg` item. Off PE and Apple
  it builds both handler sets: `ryo_h_<Op>` (`fp` in `rdi`, `vm::MODE`) and `ryo_hf_<Op>`
  (`fp` in `rbp`, `vm::FP_MODE`, with its own `ryo_hf_Resume`). The backend picks per crate:
  a kept frame pointer (target default, `-Cforce-frame-pointers`) off Apple and PE gives an
  image mode with `frame_pointer` and without `fp_arg` (`asm::Mode::rbp_set`), whose handler
  relocations name `ryo_hf_<Op>`; otherwise `fp_arg`. Mode bits are unchanged. The image
  relocation checker and the handler-by-symbol lookup (`Ryo/Obj/Image.lean` `ryo_h_` parsing,
  `Ryo/Check/Image/Relocs.lean`) should accept `ryo_hf_<op>` for such modes (and only then);
  `lean/docs/aot.md`'s mode list now says "no `fp_arg` with a frame pointer".

- No-op JIT stubs gone (Commit: "Rt: Always build the JIT, drop the jit feature"): `ryo_rt`
  has no `jit` feature and no `vm/rt/src/vm/jit/noop.rs`; the trips are always the JIT's
  (Rust behind assembly), and "the no-op JIT" now means them with `RYO_JIT=off` or a JIT
  that couldn't start: they settle both counters at the `Failed` bias (keeping counts)
  instead of storing `-JIT_BIAS` into the tripped one. `lean/docs/aot.md` ("with `RYO_JIT=off`
  or the no-op JIT") and any wording about naked-assembly no-op trips (`TripContract`'s
  sources in `lean/docs/assumptions.md`) should say so; `counter_noop` itself is unaffected.

- Several ryo runtimes (Commit: "Rt: ABI tag, private runtime per module, run-time merge"):
  the image header gains `abi` (u64 at 160, FNV-1a of the ABI tag) and `anchor` (u64 at 168,
  relocated against `__ryo_registry_anchor_<tag>`; the separate `ryo_anchor` slot section is
  gone); the header is 176 bytes. Runtime symbols carry the tag (`ryo_h_<Op>_<tag>`, trips,
  `ryo_probe_stack_<tag>`, `ryo_vm_register_<tag>`, now mangled as an internal symbol); the
  registration section is `ryo_images_<tag>`; the registry constructor is `lea rdi, start;
  lea rsi, stop; lea rdx, anchor; jmp ryo_vm_register`, i.e. `register(start, end, anchor)`
  skips images of another anchor and aborts on another `abi`. The Lean image and registry
  checks (`Ryo/Obj/Image.lean`, `Ryo/Check/Image/Registry.lean`) need the new layout, names
  and constructor form.

- Inline forms ("Inline variable shifts and rotates" 5fe50cc, "Inline bswap" b388245, "Inline
  division and remainder" e04359a, "Inline cttz and ctlz" 33feaa4, "Inline the dense switch
  index" 7915238, "Inline cmp3" d91a246): `SoundC` for every class is proved
  (`Ryo/Proofs/Inline/All.lean`), the register cache covers the new items (`hlater` replaced by
  `hcount`), and the dense switch is in `decode_sound` (`Ryo/Proofs/Dense.lean`,
  `bodySim_dense`)..

- f98053b (Image: Keep Mach-O FDEs out of compact unwind): `eh_cie_with` with
  `EhPointers::Abs8` (Mach-O) now appends a second `DW_CFA_offset r16, 1` in place of the two
  `DW_CFA_nop`s of padding (same CIE length). `Ryo/Obj/EhFrame.lean`'s Mach-O CIE form should
  accept it.

- 865dec4 (Image: Range-check sparse switch case values on decode): `Case8`/`Case16` list
  elements with bits above their width are now rejected on decode (`Elem::valid`). The Lean
  decoder's case-list reading may need the same check.

- dbb3619 (Backend: Reject PE-invalid argument registers in the encoders): on PE, `encode` and
  `encode_reduced` return `BadReturn` for an `arg` register or call argument register index of 4
  or more (`asm::pe_regs_ok`). `Ryo/Proofs/ArgRet.lean` and the `ArgReg` model may want the bound.

- 9307c23 (Backend: Re-emit a dumped constant once it turns out to be a vtable): the
  `RYO_DUMP_LEAN` dump can now label a global `vtable` (including supertrait vtables) that it
  previously emitted as `const`. The Lean side reading the dump should expect that.

- Image: Tighten parse and validate bounds: `Image::parse` now rejects a `Header::size`
  smaller than the header (`Truncated`), and `validate` bounds fixups by `fixup_area_len()`
  (the JIT records' offset when there are records) instead of `data_size`.
  `Ryo/Obj/Image.lean`'s `parse`/`validate` should match.
