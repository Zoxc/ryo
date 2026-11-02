# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- C-ABI plans (commits "Backend: Call SysV extern \"C\" functions directly", "… Compile SysV
  extern \"C\" fns as VM functions", "… C ABI on Win64", "… C-unwind and variadic C calls in VM
  code" and the `f16` SSE cut): the model and checkers are done (`Check/Lower/Plan.lean` with
  `AbiScalar.sext` read from the dump, `Cert.lean`, `CertCheck`, `Check/Image/Funcs.lean`,
  `Vm/Asm.lean`'s `ArgReg.sext`/`argRax`; variadic calls' `ARG_RAX` and Win64 duplicate
  entries in `passArgs`, from the dump's `FnAbiSummary.fixed`). Left: proofs (the ABI
  convention lemmas, the variadic entries). The call-list `movsx` and `al` loads are in
  `Proofs/Call.lean` (`paramItem`), and the decoders refuse an `al` load in calls through `rax`. `Proofs/PassArgs.lean` has the
  `al`-word and `sext` facts of `ArgReg.of?`; still missing: `passArgs`' variadic suffix (the
  `al` entry last on SysV, Win64's duplicates) and the convention lemmas.

- `UnwindAction::Unreachable` call sites (follow-up to "Backend: C-unwind and variadic C calls
  in VM code"): calls and islands with MIR's `Unreachable`, and direct calls of non-unwinding
  `C` callees, get a `NOUNWIND` cleanup entry (`FnCx::unwind_entry`) when the body has no
  landing pad, none otherwise. `docs/aot.md` (Unwinding) states the rule and the image checks
  accept the entry; no Lean checker derives cleanup entries from MIR. Left: proofs only (the
  call-site/cleanup-entry correspondence).
