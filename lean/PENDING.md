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

- Nested statics in the dump (Commit: "Lean: Dump a nested static's mutability from its
  allocation", 32742fab): `RYO_DUMP_LEAN` dumps nested statics (`DefKind::Static { nested:
  true }`) as `static`, with `mutable` taken from the allocation's mutability; it used to ICE.

- C-variadic call ABI in the dump (Commit: "Lean: Include a C-variadic call's extra arguments
  in its dumped ABI", 335142a7): a call's dumped `abi` (FnAbiSummary) now includes the extra
  arguments of C-variadic calls.

- Exact frame accesses (Commit: "JIT: Make frame accesses of unreachable, handler outputs and
  shift amounts exact", e59b6c33): in `frame::insns`, native `unreachable` doesn't fall
  through, handler outputs `o` and lpad's `x` are `Clobber`, `dp`/`sp`/`n` are `Read(8)`, and
  an inline `ShiftVar` amount is read at most 4 bytes. Applies to any Lean model of frame
  liveness or OSR moves.

- JIT `Ext` of `Undef` (Commit: "JIT: Extend Undef to zero in the emitter", a3544703): a
  widening `Ext` of an `Undef` operand now writes 0 to the destination instead of nothing.
