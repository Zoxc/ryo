# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

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
  unwinder finds no pad; the image encodes and reads it back) against `unwindEntry`, a mirror of
  `FnCx::unwind_entry`. Left: no Lean checker derives cleanup entries from MIR, so that the
  decoded entries are `unwindEntry` of the body's actions is unproved; non-unwinding `C`
  callees are treated as `Unreachable`.

- When a body has landing pads (follow-up to the `UnwindAction::Unreachable` entry above;
  commit "Backend: Decide nounwind entries by the landing pads actually emitted"):
  `FnCx::unwind_entry`'s `has_pads` is no longer "some MIR terminator has a `Cleanup`/
  `Terminate` action" but "some emitted call-like instruction got a landing pad", known only
  once the body is lowered (`Unreachable` sites are collected and get their `NOUNWIND` entries
  at the end of `FnCx::blocks`). Mono-unreachable blocks, drops without glue and folded asserts
  no longer count. Also, `Cleanup(bb)` to a post-mono no-op landing pad (rustc's
  `find_noop_landing_pads`, as cg_ssa) is now a plain `CONTINUE` entry. `unwindEntry` in
  `Proofs/Discharge/Nounwind.lean` and `docs/aot.md` (Unwinding) state the old rule.

- Scopes after code-less instructions (commit ba1600cf, "JIT: Map a scope past instructions
  without code at its position"): the decoder's `read` now maps each scope to the first instruction with code
  at or after the scope's byte offset, skipping instructions with no code at that position
  (before, an island's `Lend` landed on the code-less instruction before the island). `read`
  in `Ryo/Vm/DecodeReduced.lean` (around line 1118) still maps a scope to the first
  instruction at its offset.
