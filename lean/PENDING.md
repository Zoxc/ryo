# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

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
