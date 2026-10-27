# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- Win64 argument plans and returns (`lower/sig.rs`, `arg_plan`/`ret_kind`; Lean
  `Check/Lower/Plan.lean`, `RyoTest/CertCheck.lean`'s `win64`) no longer reject `i128`,
  `f16` and `f128`: on PE an `i128` integer piece is two 8-byte pieces (low half first),
  each taking the next position (register `pos < 4` or an 8-byte stack slot); an `f16`
  float piece is placed like `f32`/`f64` (`xmm` of its position, size 2, or an 8-byte slot);
  a `Direct` `f128` argument is placed like an `Indirect` one (`ptrReg`/`ptrStack`); a
  `Direct` `f128` return is `RET_SRET`; an `f128` in a `Pair` argument or return is still
  rejected. `i128` returns are `rax:rdx` and `f16` returns `xmm0` as on SysV. Commit: "Win64:
  pass i128, f16 and f128 as LLVM does".

- Image writer: `ImageWriter::set_eh_pointers(EhPointers::Abs8)` (Mach-O images) writes
  the CIE's L and R encodings as `DW_EH_PE_pcrel | DW_EH_PE_absptr` (0x10), and each FDE's
  `pc_begin`, `pc_range` and LSDA pointer as 8 bytes (augmentation length 8), with
  `RelocKind::Pc64` for the pointers. The default (`Sdata4`, ELF and the JIT, `eh_cie` and
  `eh_fde`) is unchanged. Only matters if the Lean `.eh_frame` model (`Ryo/Obj/EhFrame.lean`)
  is to cover Mach-O images. Commit: "image: 8-byte .eh_frame pointers for Mach-O images".

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

- The backend lowers `simd_splat/eq/lt/gt/bitmask` at 16 × i8/u8 to `vsplat`/`veq`/`vlt.s`/
  `vmsb.i8x16` (`simd_gt(a, b)` as `vlt.s(b, a)`) and `simd_and/or/xor` on 16-byte integer
  vectors to `and/or/xor.w128` (`lower/simd.rs`); trusted like the island contracts until L0
  has `simd_*` semantics (`simd_bitmask`'s all-0/all-1 lane precondition, which `vmsb`
  refines). Commit: "Lower i8x16 simd_* intrinsics to VM opcodes".

- Functions whose `#[target_feature]`s are all enabled for the crate are now lowered as VM
  functions; inside them a `simd_*` intrinsic without an instruction is `NeedsNative`
  instead of an island (`FnCx::strict_simd`). Only matters if the Lean model covers which
  functions are VM code. Commit: "Lower baseline #[target_feature] functions as VM code".

- Image identity and registration through the linker (CGU plan stage 3). The image symbol is
  `__ryo_image_<StableCrateId>_<CGU hash>` (both 16 hex digits; the CGU hash is
  `image::cgu_hash`, 64-bit FNV-1a of rustc's CGU name), and `Header` gains `cgu_hash: u64`
  at offset 152 (after `const_relocs`, `Header` grows 152 -> 160 bytes). Each image object
  has a new section with one 8-byte entry, `R_X86_64_64` + 0 against the read-only
  section's start (ELF `ryo_images`, flags `SHF_ALLOC|SHF_WRITE|SHF_GNU_RETAIN`; PE `.ryo$m`;
  Mach-O `__DATA,__ryo_images`). The registry object is now a crate-independent stub: a
  weak hidden `__ryo_registry_anchor` (a COMDAT on PE), a null 8-byte `ryo_images` entry,
  the constructor `lea rdi, [rip + __start_ryo_images]; lea rsi, [rip + __stop_ryo_images];
  jmp ryo_vm_register` (both bounds undefined `STV_HIDDEN`, `R_X86_64_PC32` - 4; the jump
  `R_X86_64_PLT32` - 4), and `.init_array.00000` as before; no image list
  (`.data.rel.ro.ryo_registry` is gone). `ryo_vm_register(start, end)` registers the
  non-null entries of `[start, end)` and rejects two images with the same `(crate_hash,
  cgu_hash)`. Lean: `Obj/Image.lean` (`readHeader`, `headerSize`, the image symbol form),
  `Check/Image/Relocs.lean` (the header symbol check, the entry section and its relocation
  as an allowed section), `Check/Image/Registry.lean` (the stub's form instead of the list;
  `checkLink`: each image object has its entry, not a list membership), `X86.registryCtor`.
  Commit: "Register images through a linker section; CGU hash in the image identity".

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
