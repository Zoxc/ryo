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
  `argPlan_ptrReg`: integer pieces in `handlerReg`, never `rax`). Still missing: the stack
  pieces' offsets (`slot`, `byval`) against the convention's stack layout, and how the Win64
  duplicate words decode (`ArgReg.of?`). The call-list `movsx` and `al` loads are in
  `Proofs/Call.lean` (`paramItem`); `Proofs/PassArgs.lean` has the `al`-word and `sext` facts
  of `ArgReg.of?`.

- `UnwindAction::Unreachable` call sites (follow-up to "Backend: C-unwind and variadic C calls
  in VM code"): calls and islands with MIR's `Unreachable`, and direct calls of non-unwinding
  `C` callees, get a `NOUNWIND` cleanup entry (`FnCx::unwind_entry`) when the body has no
  landing pad, none otherwise. `docs/aot.md` (Unwinding) states the rule and the image checks
  accept the entry; no Lean checker derives cleanup entries from MIR. Left: proofs only (the
  call-site/cleanup-entry correspondence).
