# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- `unreachable` has no handler any more: it is a bare `ud2` in AOT and JIT code (the `trap`
  handler kind is gone, `has_handler unreachable` is false, the reduced set gains
  `unreachable`, and the decoder reads a `ud2` at an instruction's start as it).
  The generated tables and vectors are regenerated, so `lake build` fails until the
  model follows (`Ryo/Vm/OpSem/Footprint.lean` uses `HandlerKind.trap`; the x86 decoder
  needs the bare `ud2`). Commit: "Inline unreachable as a bare ud2".
