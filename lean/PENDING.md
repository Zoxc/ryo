# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- The JIT's SSA tier decodes the three inline address instructions as `Kind::RefAddr` and
  builds a pure `Op::RefAddr(ref, ind)` (rip-relative `lea`, or the slot load and with `ind`
  one more load) instead of `hcall.reg`; LVN keys it. Only matters if the Lean model covers
  the SSA tier. Commit: "Give the JIT SSA tier a pure op for rip-relative addresses".

- The JIT's SSA tier decodes `copy`, `zero`, `load.copy`, `store.copy` of up to 64 bytes and
  `mov.w128`, `load.w128`, `store.w128` as `Kind::Copy`: pieces cut along the other scalar
  accesses' boundaries, built as plain loads/stores (all reads before all writes) instead of
  handler calls, so copied aggregates promote. Only matters if the Lean model covers the SSA
  tier. Commit: "JIT SSA tier: small block copies as loads and stores".

- The JIT's SSA tier inlines direct calls of the image's functions (`jit::inline`: an
  IR-to-IR splice with landing-pad action substitution, callee allocas appended as
  `Alloca::inlined`, outgoing areas merged) and promotes memory allocas whose address no
  longer escapes (`jit::opt::promote`). Only matters if the Lean model covers the SSA tier;
  the splice and the promotion are the passes to prove or validate. Commit: "Inline
  same-image calls in the JIT's SSA tier".

- The SSA tier's inliner specializes small callees to constant arguments before splicing
  them (`jit::inline::specialize`: the entry parameters' uses replaced by constants, then
  the passes), and weighs sites by the JIT records' counts. Only matters if the Lean model
  covers the SSA tier. Commit: "Weigh inlining by the counters and specialize callees to
  constants".

- The SSA tier's inliner inlines across images (`jit::inline::rebase`: another image's
  callee's `RefAddr`s and handler address arguments become 64-bit constants or a load
  through a symbol's value, its calls the JIT's call forms) and through symbols that hold a
  VM function's entry. Only matters if the Lean model covers the SSA tier. Commit: "Inline
  across images in the JIT's SSA tier".

- Proofs to extend (left by the session that applied the entries above; no `sorry` was
  added, the theorems keep their scope):
  - Niche discriminants (commit 844ffef): the lowered plain-op decoding is proved against
    `tagToVariant` (`Ryo/Proofs/NicheDiscr.lean`, `nicheDiscr_sound`, a model of
    `FnCx::niche_discr`); the fused form (a `SwitchInt` testing the tag with `br.eq.imm`, or
    `sub.imm` + `br.gt.u.imm` + `switch.dense` past 4 arms) is not proved, and nothing checks
    the model against the emitted ops.

- The SSA tier gains a check-elimination pass (`jit::opt::checks`, run after the folds): a
  dominator-tree walk with range and `a < b` facts from single-predecessor branch edges turns
  `Ovf` ops that can't overflow into `Bin` (flag constant 0, `BrOvf` a jump) and folds the
  compares and compare-branches the facts decide. Only matters if the Lean model covers the
  SSA tier; each fold is a proof obligation. Commit: "JIT: eliminate checks dominating
  branches decide".

- The SSA tier's alloca promotion (`jit::opt::promote`) also takes allocas accessed at
  overlapping widths: their fields are the pieces the accesses' bounds cut them into (power
  of two widths), a store covering several stores each piece (shifted down), a load covering
  several loads each and puts them together (zero-extended, shifted, or'ed; an undefined
  piece reads zero). Only matters if the Lean model covers the SSA tier. Commit: "JIT SSA:
  scalar replacement of mixed-width allocas".
