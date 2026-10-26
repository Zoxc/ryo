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

- The SSA tier compiles the SIMD instructions (`vsplat`/`veq`/`vlt.s`/`vmsb.i8x16`,
  `and`/`or`/`xor.w128`) natively: 16-byte IR values (`Op::V`, `Op::VConst`), vector fields
  of allocas promoted, copies cut into 16-byte pieces over them, an `xmm` register class
  (no `xmm` value across a call; on PE only `xmm0`–`xmm5`), 16-byte spill slots and OSR
  loads, SSE2 emission, the folds `vmsb(vlt.s(x, 0)) = vmsb(x)`, half/pair and constant
  folds, the splat hoist (`opt::hoist`), and LVN's reassembly of a value from its shifted
  pieces. The handlers' semantics and effects are unchanged. Only matters if the Lean model
  covers the SSA tier. Commit: "JIT SSA: native SSE2 for the SIMD instructions".

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

- The SSA tier folds loads from the constant pool (`jit::opt::lvn`, `jit::opt::ConstMem`,
  `Image::read_pool`): a read with no relocated byte becomes the pool's bits; a whole
  relocated 8-byte field into the pool or the data area the `RefAddr` of its target, one to
  a function or native symbol its bits; partial reads of a relocated field, reads past the
  pool, and the data area aren't folded; a constant address (another image's pool, found by
  `RtApi::image_at`, which now also matches read-only sections) gives integers (rule 4, as
  `rebase`). And `const` of at most `MAX_COPY` bytes decodes as a block copy from the pool
  (`Side::Pool`), cut at its relocated fields. Add both to lean/docs/jit.md §E.3's pass list.
  Rule: an immutable allocation's read equals its `world` bytes (stores to it are UB), and
  the copy pieces equal the handler's footprint. Only matters if the Lean model covers the
  SSA tier. Commit: "JIT: fold loads from the constant pool".

- The SSA tier devirtualizes calls (`jit::inline::devirt`, `Env::direct`): a `Call Ptr` (or
  tail call) whose callee is `RefAddr(Sym(s), false)` becomes a call of symbol `s`; one whose
  callee is a constant equal to a registered image's VM function's AOT entry becomes a
  direct call of that function (the unit's call form for another image's). It runs on the
  root before and after inlining, and on each explored callee's copy. Add it to
  lean/docs/jit.md §E.3's pass list. Rule: a call through the address of `f`'s AOT entry
  equals a call of `f` (the entry dispatches to the JIT code; arguments, results and
  unwinding unchanged); a symbol slot is filled once, before VM code runs. Commit: "JIT: call
  constant function pointers directly".

- After the first inlining round and the devirtualization that follows it, `jit::compile`
  runs one more `inline` restricted to the calls that devirtualization made direct
  (`Params::rounds = 2`, `inline`'s `only`), charged against the unit as it is; calls made
  direct after that stay calls. Add to lean/docs/jit.md §E.3's pass list. Commit: "JIT:
  inline calls that devirtualization made direct".
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
