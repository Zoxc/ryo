# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- SSA tier on PE (Commit: "Asm, Rt, JIT, Backend: Win64 handlers on PE"): handler
  calls take the Win64 positions (the fifth as `mov [rsp + 32], r11d`), `rdi`/`rsi` are
  callee-saved (saved when used, no longer at fixed AOT slots; the PE prologue pushes only
  `rbp` before the saves, frame offset `K = 8n` rounded to 16), calls clobber only Win64's
  volatile registers, register entries take at most four arguments and return two values in
  `xmm0` (moved to `rax`/`rdx` after the call). Only matters if the Lean model covers the SSA
  tier.

- Image writer: `ImageWriter::set_eh_pointers(EhPointers::Abs8)` (Mach-O images) writes
  the CIE's L and R encodings as `DW_EH_PE_pcrel | DW_EH_PE_absptr` (0x10), and each FDE's
  `pc_begin`, `pc_range` and LSDA pointer as 8 bytes (augmentation length 8), with
  `RelocKind::Pc64` for the pointers. The default (`Sdata4`, ELF and the JIT, `eh_cie` and
  `eh_fde`) is unchanged. Only matters if the Lean `.eh_frame` model (`Ryo/Obj/EhFrame.lean`)
  is to cover Mach-O images. Commit: "image: 8-byte .eh_frame pointers for Mach-O images".
  Out of scope for the model: its object readers (`readElf`/`readImageObject`) only read
  ELF objects, so a Mach-O image's `Abs8` `.eh_frame` never reaches `Ryo/Obj/EhFrame.lean`.



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

- Proofs for the inline forms added by "Inline variable shifts and rotates" (5fe50cc), "Inline
  bswap" (b388245), "Inline division and remainder" (e04359a), "Inline cttz and ctlz"
  (33feaa4), "Inline the dense switch index" (7915238) and "Inline cmp3" (d91a246). The model
  has them (items `shiftCl`, `bswap`, `div`, `cdq`, `bsf`, `bsr`, `cmov`, `setccR` with
  encode/decode/exec, `Uniq.fam_*` for each; classes `shiftVar`, `div`, `count`, `cmp3`,
  `bswap` in `Asm.classOfParts`/`sequence`/`classifyNew`, the cache effects, `Asm.denseIndex`
  and `DecodeReduced.denseSwitch`), and `RyoTest/Inline.lean` runs the sequences against the
  handlers' methods; what is left:
  - `Sound`/`SoundC` for the new classes (`Ryo/Proofs/Inline.lean`: `laterClass` lists them;
    `frameOnly` is `false` for them, so `inline_sound` doesn't cover them). `div` changes `rdx`
    (a `SoundC` with `clobbers` `[0, 1, 2]`, as unsigned 64-bit `mul.ovf`); its proof needs
    MIR's "no zero divisor, no `MIN / -1`" from `opSem` (UB there); `count` goes through
    `bsf`/`bsr` of zero writing `ctx.undef`, which the `cmovz` overwrites (32/64 bits) or the
    guard bit rules out (8/16).
  - The register cache proofs for the new items: `cacheSafe`, `update_inv`, `onlyARB` (`div`'s
    `rdx`, `cdq`), `exec_swap` (with `div` pinned to `rax` like `mulQ`: `isMulQ`,
    `emitHead_mulQ`); then drop the `hlater : laterClass cls = false` hypotheses of
    `sequence_ok`, `sequence_cacheSafe`, `cached_of` (`Ryo/Proofs/CacheMem.lean`),
    `inline_step_cached` (`Ryo/Proofs/CacheStep.lean`) and `inline_step_cached_ops`
    (`RyoProofs/InlineOk.lean`). `exec_withRm` already covers `div`'s cached divisor.
  - The dense switch: `InsnRead.dense` (`Ryo/Proofs/DecodeLink/Read.lean`) only records that
    `denseSwitch` read it, and `link_handler` (`Links.lean`) takes the hypothesis `hnd` that the
    instruction isn't one. Left: its link (the code is `denseIndex op s base n` then
    `Switch.switchItems`, from `denseScan`/`table`), and a step lemma that the items compute
    `switch.dense`'s case index in `rax` (`s - base` wrapping at the width, `n` if not below
    `n`) before `exec_switch`, in place of the handler contract.
  - The co-simulation harness (`lean/harness`) doesn't generate the new items yet (it must not
    generate `bsf`/`bsr` of zero, where the model writes `ctx.undef` and the CPU keeps the
    register).

- The SSA tier decodes the `rotl.wN`/`rotr.wN` handlers (and the inline forms it takes as
  them) as native `BinOp::Rotl`/`BinOp::Rotr` at `w` bytes (the 4-byte amount extended or
  truncated to `w`, taken modulo the width), emitted as `rol/ror r, cl` at the width with
  `rcx` a fixed-register clobber like the variable shifts (`regalloc::clobbers`), or as the
  immediate rotate for a constant amount. Only matters if the Lean model covers the SSA tier.
  Commit: "JIT SSA: native rotates".

- The JIT's SSA tier builds `bswap.w16-w64` as `Op::Bswap(w)` (`bswap r`, at 16 bits the
  32-bit swap and `shr 16`) instead of a handler call; `Op::fold` folds a constant. Only
  matters if the Lean model covers the SSA tier. Commit: "JIT SSA: bswap".

- The JIT's SSA tier builds `cttz`/`ctlz` (w8-w64) as `Op::Count { lz, w }` (a 4-byte
  count) instead of handler calls, emitted as the AOT form (`bsf`/`bsr` with `cmovz`, or the
  guard bit for 8/16-bit `cttz`; `ctlz`'s `xor` by N-1); `Op::fold` folds a constant (the
  earlier fold of the handler calls of constants now goes through it). Only matters if the
  Lean model covers the SSA tier. Commit: "JIT SSA: cttz and ctlz".

- The JIT's SSA tier builds a `switch.dense.w8-w64` handler call as `Op::SwitchIdx { w,
  base, n }` (`(s - base) mod 2^N`, or `n` if not below `n`; 8 bytes) feeding
  `Term::Switch`, emitted as the AOT form's `sub`/`cmp`/`cmovae`; `Op::fold` folds a
  constant. Only matters if the Lean model covers the SSA tier. Commit: "JIT SSA: dense
  switch index".

- The JIT's SSA tier builds `cmp3.s/u.w8-w64` as `Op::Cmp3(signed, w)` (a byte) instead of a
  handler call, emitted as the AOT form (`cmp`, `setl/setb` into `r10b`, `setg/seta`, `sub`);
  `Op::fold` folds constants and LVN `x <=> x`. The tier now takes only the variable shifts,
  rotates and division as their handler calls (`asm::ssa_as_handler`), which it builds as
  native `Op::Bin`s. Only matters if the Lean model covers the SSA tier. Commit: "JIT SSA:
  cmp3".

- The inline dense switch index (`InsnRead.dense`, `DecodeReduced.denseSwitch`) is a new case
  of the decode-soundness composition: `Ryo/Proofs/DecodeSound.lean`'s `bs_insn`,
  `bodySim_unreachable`, `bodySim_jmp` and the `insn` dispatch take it with `sorry` (the
  file is WIP); `bodySim_unreachable`/`bodySim_jmp` only need that its op is a
  `switch.dense`, `bs_insn` the table read, the dispatch a `bodySim_dense`. Commit: "Asm, JIT
  SSA: inline shift/rotate/bswap/div/count/switch-index/cmp3 forms and native JIT ops".

- JIT SSA LICM (design/jit.md#loop-invariant-code-motion): `opt::hoist`, which only moved
  `vsplat`s, is now loop-invariant code motion (general only with `RYO_JIT_LICM=1`), run after `opt::checks`: pure operations, loads
  nothing in the loop may write, divisions and effect-free handler calls (the last three only
  where they run whenever the head does) move to a preheader (possibly a new block); at a
  head with an OSR entry the value becomes a head parameter, computed for the entry in a new
  *landing* block between the entry and the head (`osr::osr_landing`; `osr_edge` counts its
  edge as the OSR edge, `osr::through_landings` passes entry values it uses as its
  parameters after promotion), and `simplify`'s block merging never merges into an OSR entry.
  Matters for the Lean description of the SSA tier's passes (the splat hoist in
  `lean/docs/jit.md`) and the OSR obligations (the entry's target may now be a landing, not
  the head). Commit: "JIT SSA: loop-invariant code motion, with OSR landings".
  Also: `volatile_load`/`_store` (and unaligned), `volatile_copy_memory`,
  `volatile_copy_nonoverlapping_memory` and `volatile_set_memory` lower to the islands
  `ryo_island_volatile_*` instead of VM loads, stores and `memcpy`/`memmove`/`memset`.
