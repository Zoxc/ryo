# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- C `main` without a template (Commit: "Backend: C main and allocator shim without templates"):
  `ryo_rt::entry` (`c_main`, diagnostic item `ryo_c_main`) is gone. The C `main` is built by
  the backend with no instance: an image function named `target.entry_name`, C ABI
  `(c_int, *const *const u8) -> c_int`, lowered from a synthesized MIR body; `RYO_DUMP_LEAN`
  has no certificate for it and its dump name is `<C main of {entry fn}>`. If the Lean side
  expects a certificate per image function, it should accept this one without.

- JIT SSA address modes, cold sinking, peepholes (Commit: "JIT SSA: Address modes, cold
  sinking and branch peepholes"): new IR ops `LoadIx(w, k, s)` (args `p`, `i`) and
  `StoreIx(w, k, s)` (args `p`, `i`, `v`), `[p + i * s + k]`, made only after the passes by
  `opt::fold::index_addr` from `Load`/`Store` through a `PtrIndex(s)` (s 1/2/4/8) whose only
  uses they are. `opt::dce` drops unused `Load`/`ALoad` (they no longer count as effects).
  `opt::layout` sinks pure values used only in cold blocks into copies there and orders the
  hot blocks in chains. Emitter: `BrCmp Eq|Ne (x & c), 0` as `test x, c` (the `and` not
  emitted), a `Count` result taken as zero-extended (no `mov r32, r32` for its `Ext`), and a
  conditional branch falls through to an edge stub laid right after it. `lean/docs/jit.md`'s
  pass list (E.4, "The SSA pipeline's passes so far") should list these obligations.

- C `main` as a VM function, no `__ryo_main` (Commit: "Backend: No cg_llvm module for fib"):
  the entry wrapper is a C-ABI VM function of the entry fn's image (symbol `main`, `External`,
  default visibility), the instance `ryo_rt::entry::c_main::<M, T, SIGPIPE>` lowered from a
  MIR body the backend builds (`backend/src/lower/entry.rs`: reify the entry fn, `IntToInt` /
  `PtrToPtr` casts, `lang_start::<T>` call with unwind `Unreachable`, `IntToInt` of the
  result); `RYO_DUMP_LEAN` dumps that body for it. Image objects no longer have the
  `__ryo_main` slot (section `ryo_main`), and `rt_symbols::MAIN_SLOT` is gone: the image
  checker (`Ryo/Check/Image.lean`, `Image/Dump.lean`'s `main` field and the "slot exactly when
  the entry function is in the image" rule, `Image/Common.lean` `mainSlotName`,
  `Image/Registry.lean`) should drop it. The allocator shim is now a separate object the
  backend writes (`jmp` forwarders), not an LLVM module: no Lean effect unless the image
  checker looks at it. `lean/docs/aot.md` (the `c_main` row as cg_llvm-compiled code loading
  `__ryo_main`, the trusted-contracts list) and `lean/docs/plan.md`'s `c_main` entry should
  describe it as a VM function checked like any other.

- No `call_cN` islands (Commit: "Backend: Remove the call_cN island"): `ryo_rt::island` has no
  `call_c0` … `call_c16` templates (no `ryo_island_call_cN` diagnostic items) and the backend
  no `Target::CIsland`: an `extern "C"` call whose signature `sig.rs` has no plan for keeps
  the caller native instead. The island role table (`Ryo/Vm/R/Islands.lean`, the
  `call_cN` entry and its `startsWith "call_c"` parsing), its tests (`RyoTest/Frame.lean`,
  the `call_c` cases and `rolesAre "ryo_island_call_c…"`) and `lean/docs/aot.md`'s island
  contract list (`call_cN`: external C call through the fn-pointer slot) should drop it.

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

- Decoder canonical forms (Commit: "Image: Decode only canonical call args, tail jumps and
  arg stores"): `DecodeReduced.lean` already mirrors it (`paramsOk`, PE-only `jmpRaxW`, no
  early `none` after `movd r11d, xmm`). `argInsn_none`'s second case can no longer happen, so
  it and `NoArg` (about 60 uses, `Proofs/NoArgCursor.lean`) can be simplified to `c' = c`.

- Lean dump call convention (Commit: "Backend: Fix lowering bugs and the Lean dump's call
  convention"): the dump takes the convention from rustc's `CanonAbi` (`rust`, `c`, `other
  "<CanonAbi>"`; `rustCall` stays separate). The `CallConv` doc in
  `Ryo/Spec/Mir/Syntax.lean` still says "rustc `ExternAbi`". Unsize casts between equal
  types (after region erasure) dump as `upcast none`.

- `Item::map_regs` (8cedd067) maps mov, movd and sse items; the Lean cache model and proofs
  don't have those cases yet.

- `ryo_probe_stack` (Commit: "Rt: Fix JIT diagnostics, probe_stack and registry sort"): the
  last probe is exact (no page below the frame); only relevant if the Lean side describes it.

- SysV C-ABI calls (commit "Backend: Call SysV extern \"C\" functions directly"): calls of non-unwinding `extern "C"`
  functions (symbols and fn pointers) are direct `call.sym`/`call.sym.ind`/`call.ptr` on SysV
  when `sig.rs` builds a plan, else the `call_cN` island as before (always on PE). New in the
  plan and certificate (`plan_json`): `ArgLoc::StackByval {at, size, align}` (JSON
  `{"stackByval", "size", "align"}`) for `Indirect { on_stack: true }` (the whole value copied
  to `at`, aligned to `max(8, pointee_align)`, no register); `Cast` pieces with an 8-byte
  prefix unit at 0 and one rest unit at 8, each integer (1-8 bytes) or float (4/8 bytes, an
  8-byte `xmm` unit may hold two `f32`s); `ArgReg.sext` (bit 7 of the register word,
  `asm::ARG_SEXT`, call argument lists only, 1-/2-byte integers: `movsx r32, byte/word
  [slot]`; `ArgReg::of(_, true)` rejects it), JSON `"sext": true` inside `"reg"` only when
  set; `ArgLoc::Stack.ext` (JSON `"ext": "zext"|"sext"` only when set): C's extension of a
  1-/2-byte stack argument, emitted as `zext`/`sext.w{8,16}.w64` into the outgoing slot
  instead of a `mov`. C calls get no call-site entry (they can't unwind). `dump_lean.rs`'s
  `scalars` now cover those `Cast` shapes and carry `"sext": true` for `signext` scalars
  under 4 bytes. The Lean plan computation (`Ryo/Check/Lower/Plan.lean`), the cert reader
  (`Cert.lean`), the arg-list word decoding (`ArgReg`, the reduced decoder's `movsx` loads)
  and the ABI convention lemmas need the C shapes; definitions of `extern "C"` fns stay
  native.
- SysV C `Cast` SSE units past the value's end (follow-up to "Backend: Call SysV extern \"C\"
  functions directly"): rustc makes every SSE eightbyte that isn't 4 bytes an `f64` unit, so
  `{f16}` or the tail of `{f32, f32, f16}` is an 8-byte unit beyond the value. `sig.rs`
  `cast_pieces` (and `dump_lean.rs` `scalars`) now cut such a unit to 2 bytes when 2 are left
  (an `f16`-sized `xmm` piece) and refuse other sizes (e.g. `{[f16; 3]}`, island), so a return
  no longer stores 8 bytes into a 2-byte value. The Lean plan computation needs the same rule.

- SysV C-ABI definitions (commit "Backend: Compile SysV extern \"C\" fns as VM functions"):
  non-unwinding `extern "C"` fns whose signature has a plan are VM functions on SysV (the
  native reason "non-Rust ABI" is now only for signatures without a plan: Win64, C-unwind,
  variadic, refused shapes). The prologue takes the C plan: `StackByval` copies `size` bytes
  from `fp + 16 + at` into the input's home; `arg` never carries `sext` (the callee ignores
  the caller's extension, the prologue clears the bit). A C `signext` 1-/2-byte return
  (`AbiSig.ret_sext`) is `sext.w{8,16}.w64` into an 8-byte temporary and `ret` of that with
  an 8-byte part, so the `ret` kind's load width is 8 where the function's (call) kind says 1
  or 2: the cert/Lean `ret` rule must allow that. The JIT inliner truncates a callee's
  returned part wider than the call's result (`Ext` to the narrower width). The function
  certificate's plan carries the C shapes of the previous entry.

- Win64 C ABI (commit "Backend: C ABI on Win64"): non-unwinding `extern "C"` calls and
  definitions get a plan on x86_64-pc-windows-msvc too, following rustc's `x86_win64.rs`
  `PassMode`s: 1/2/4/8-byte aggregates (and scalar pairs) as one integer `Cast`, other
  aggregates, `i128` and `f128` arguments `Indirect` (`PtrReg`/`PtrStack`), ZST arguments
  `Indirect` from `Ignore` (a pointer taking a position), every integer scalar under 4 bytes
  extended to 32 bits as argument (`ARG_SEXT`, `Stack` `ext`) and return (`ret_sext`). The PE
  `i128`-in-two-positions / `f128`-by-reference argument rules and the `f128`-sret return rule
  now apply only to `Direct` (Rust-ABI) scalars. The `i128` return is a `Cast` to one 16-byte
  opaque vector unit: one 16-byte `xmm0` return part (`cast_pieces`, `dump_lean.rs`
  `scalars`); a 16-byte `Cast` unit in an argument is refused. The Lean plan computation and
  ABI convention lemmas need the Win64 C shapes.

- C-unwind and variadic C calls (commit "Backend: C-unwind and variadic C calls in VM code"):
  `extern "C-unwind"` signatures get the C plan (`AbiSig.c_unwind`); their direct calls get a
  call-site entry like Rust calls (can unwind to the landing pad), and `C-unwind` fns are VM
  functions with their bodies' normal unwinding (`UnwindTo::Continue`). Calls of C-variadic
  fns (`fn_abi_of_fn_ptr` with the extra argument types, `AbiSig.variadic` = fixed count)
  have a plan over fixed and variadic inputs, plus: on SysV a one-byte load of a temporary
  holding the number of `xmm` argument registers used into `al`, as the new call-list integer
  register index `asm::ARG_RAX` (6, `rax`; `movzx eax, byte [slot]`), allowed only for
  `call`/`call.sym` (`return_ok` refuses it for `call.sym.ind`, `call.ptr` and tail calls;
  `arg` never takes it); on Win64 each variadic `xmm` piece also loaded into the integer
  register of the same position (an extra list pair from the same slot, 8 bytes). The asm
  model's call-list registers and the ABI lemmas need `ARG_RAX` and the duplicated pairs; the
  certificate's plan doesn't list them.

- `UnwindAction::Unreachable` call sites (follow-up to "Backend: C-unwind and variadic C calls
  in VM code"): calls and islands with MIR's `Unreachable`, and direct calls of non-unwinding
  `C` callees, now get a `Continue` cleanup entry (`FnCx::unwind_entry`) instead of none when
  the body has no landing pad (no `Cleanup`/`Terminate` action), as a cg_llvm frame without
  an LSDA; with landing pads they still get none. The model's call-site/cleanup-entry rules need the change.

- `NOUNWIND` cleanup entries ("JIT: Keep inlined nounwind calls terminating", follow-up to
  "Backend: Let exceptions pass through VM frames without landing pads"): the `Continue`
  entries of `Unreachable` calls in bodies without landing pads are now `image::NOUNWIND`
  (`u32::MAX - 1`, `Cleanup::Nounwind`, `asm::Unwind::Nounwind`; in `asm::CallSite` a call
  site without a pad with `catch` set, written to the LSDA as action 0, pad 0). The
  pad-word/cleanup-entry decoding (`Cleanup::from_word`/`to_word`), the encoder's and
  decoder's action tables and the call-site round trip need the extra value; the LSDA is
  unchanged. Today `Obj/Image.lean`'s `padOk` (`c.pad % CATCH < f.codeLen`) rejects it and
  `Obj/Unwind.lean`/`Obj/Image.lean`'s call-site conversion reads it as a catching pad at
  `0x7ffffffe`; `scripts/lean-decode-ref` prints it the same way (`cleanup N -> 2147483646
  catch`), so change it with the Lean decoder. The JIT's inliner keeps such calls `Site::Nounwind`, which the emitter turns
  into a continue entry only when the unit has no landing pad (else no call site).

- Source locations (Commit: "Backend: Source locations for std backtraces of VM frames"):
  the instruction list has a modifier kind `5` (`asm::list::Loc`: `file << 1 | inlined`,
  the line as a zigzag delta from the function's previous location's, the column, and if
  `inlined` the name), ordered after dropped stores and before instructions at one
  position (`ORDER_LOC`; instructions are now rank 4). `walkList`/`InsnList.read` and the
  entry-order check (`Ryo/Obj/List.lean`, `DecodeObj.lean`) should accept and skip it (a
  pure label: the decoders ignore it). The image header gains a last field `strings: Span`
  (the locations' string pool, header size 176), which `Ryo/Obj/Image.lean`'s `Header`
  and `headerSize` don't read yet. Optional, §8 of the design: carry the locations as
  labels of decoded calls, and the JIT's per-call chains (`InstData::loc`, `Func::chains`,
  `Output::calls`) through the per-step checkers.

- Frame-address facts (Commit: "JIT SSA: Fold null and alignment checks of frame addresses"):
  `opt::checks` folds compares and `and`-masks using `checks::addr_facts`: an `AllocaAddr`
  of a memory or incoming alloca has low 4 bits `(aot_off + k) mod 16` and is non-null for
  `k` in `0..=size`; a `RefAddr` of a constant, data area or function is non-null;
  `PtrAdd`/`PtrIndex` keep known low bits. It relies on `fp` being 16-aligned and the JIT
  frame layout placing memory allocas congruent to their AOT offset mod 16. A Lean model of
  check elimination (if any) needs these facts as assumptions on the frame.
