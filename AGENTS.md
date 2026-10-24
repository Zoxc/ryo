# User rules

- Committing. Whatever is uncommitted when you start stays uncommitted.
- Don't reference an uncommitted file from a committed one.
- Commit messages. Keep the title brief -- a line, not a paragraph -- and put what needs
  saying under it, ideally in one short paragraph
- Codegen dumps. After every change that can affect the generated code (AOT or JIT), run
  `./y.sh build && ./y.sh bench codegen` and commit the regenerated `bench/codegen/`
  with that change, so its diff shows the effect.
- Optimizing. When a change is meant to make generated code faster, compare it against the
  commit before with `scripts/compare-branches.py --worktree <base> --build head=. --metric
  cachegrind` (instruction counts: deterministic, so small differences are real), and report
  those counts alongside CPU-time numbers.
- Lean sync. Changes to the Rust code (backend, JIT, VM) don't update the Lean code. Instead,
  when a change affects what the Lean model or proofs describe, add an entry to
  `lean/PENDING.md` saying what changed (with the commit), for a later Lean session to apply.
  That session removes the entries it handles.
- Lean effort. When delegating Lean work to subagents, use medium effort for writing specs
  and low effort for proofs.

# Project rules

- Formatting. Run `cargo fmt` in each workspace you changed (`backend`, `build`, `vm`) before
  committing; `rustfmt.toml` at the root sets the style.
