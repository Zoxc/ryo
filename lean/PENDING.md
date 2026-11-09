# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- 16-byte SSE values through calls in the SSA pipeline (commit "JIT SSA: Pass 16-byte SSE
  arguments and results"): an `arg`, a call argument or a `ret`/call result part of 16 bytes
  in an `xmm` register (`f128`, `__m128`) is a 16-byte R-SSA value (no longer declined), so
  `docs/jit.md`'s R-SSA call and return rules (M7a) take vector operands, and the emission
  templates (M7b) the parallel `xmm` moves of `jit::emit`'s `to_abi`/`from_abi`.

- The JIT's re-encoding pipeline is gone (commit "JIT: Remove the re-encoding pipeline; AOT
  code is the fallback"): the JIT compiles with the SSA pipeline only, and a function it
  declines (`jit::Unsupported`, over `RYO_JIT_SSA_LIMIT`) stays in its AOT code (record
  `Failed`). `docs/jit.md` §E.1 (decode → re-encode → remap → OSR entries, the `SlotMap`/
  liveness checks) and its intro, `docs/plan.md`'s M4 (remap check, liveness check) and the
  §E notes on falling back to re-encoding describe a pipeline that no longer exists. M4
  reduces to the OSR entry lemma (`osr_entry_sound` over the relocation lemma) for the SSA
  pipeline's OSR code (`jit::emit`'s `osr_code`, from `asm::osr`'s pieces), to fold into M7.
  The JIT no longer uses `asm::frame::{SlotMap, remap_slots, shuffle_map}` or
  `asm::osr::{osr_code, OsrEntry}`; they stay only for the Lean vectors
  (`vm/bytecode/tests/lean_reduced_vectors.rs`' shuffled frames, `lean_x86_vectors.rs`' OSR
  entries) and can go with those vectors once the Lean side drops them.
  `frame::head_liveness` and `frame::osr_moves` were removed.

- C-ABI plans (commits "Backend: Call SysV extern \"C\" functions directly", "… Compile SysV
  extern \"C\" fns as VM functions", "… C ABI on Win64", "… C-unwind and variadic C calls in VM
  code" and the `f16` SSE cut): the model and checkers are done (`Check/Lower/Plan.lean` with
  `AbiScalar.sext` read from the dump, `Cert.lean`, `CertCheck`, `Check/Image/Funcs.lean`,
  `Vm/Asm.lean`'s `ArgReg.sext`/`argRax`; variadic calls' `ARG_RAX` and Win64 duplicate
  entries in `passArgs`, from the dump's `FnAbiSummary.fixed`). Left: connecting these to the call simulation. `Proofs/PassArgsConv.lean` has `passArgs`'
  variadic suffix (`passArgs_variadic`; SysV `passArgs_sysv_variadic`: the `al` entry last;
  Win64 `passArgs_win64_variadic`/`mem_win64Dups`: the duplicates) and the convention lemmas
  (`argPlan_locsOk`: every register piece in a convention register; `argPlan_reg`/
  `argPlan_ptrReg`: integer pieces in `handlerReg`, never `rax`); `Proofs/PassArgsStack.lean`
  the stack pieces' layout (`argPlan_chain`/`argPlan_stack_mem`/`argPlan_pairwise`: increasing,
  disjoint, 8-aligned, after Win64's shadow space, within `stackSize`, a multiple of 16) and
  `Proofs/PassArgsDup.lean` how the Win64 duplicates decode (`win64Dup_of?`: `xmm_i`'s home into
  `intArg true i`). The call-list `movsx` and `al` loads are in
  `Proofs/Call.lean` (`paramItem`); `Proofs/PassArgs.lean` has the `al`-word and `sext` facts
  of `ArgReg.of?`.

- `UnwindAction::Unreachable` call sites (follow-up to "Backend: C-unwind and variadic C calls
  in VM code"): calls and islands with MIR's `Unreachable`, and direct calls of non-unwinding
  `C` callees, get a `NOUNWIND` cleanup entry (`FnCx::unwind_entry`) when the body has no
  landing pad, none otherwise. `docs/aot.md` (Unwinding) states the rule and the image checks
  accept the entry. `Proofs/Discharge/Nounwind.lean` proves the entry's meaning (L0's
  `Unreachable` unwind is UB; R unwinds out at a `NOUNWIND` entry, never catches there; the
  unwinder finds no pad; the image encodes and reads it back) against `unwindEntries`, a mirror
  of `FnCx::unwind_entry` over the emitted call-like instructions' actions (`has_pads` from the
  pads they got, `Cleanup` to a no-op landing pad a continue entry). Left: no Lean checker
  derives cleanup entries from MIR, so that the decoded entries are `unwindEntries` of the
  emitted instructions' actions is unproved; non-unwinding `C` callees are treated as
  `Unreachable`.
