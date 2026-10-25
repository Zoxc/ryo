# Pending Lean updates

Rust-side changes that the Lean model or proofs don't reflect yet. Add an entry per change;
remove it once a Lean session has handled it.

- `unreachable` has no handler any more: it is a bare `ud2` in AOT and JIT code (the `trap`
  handler kind is gone, `has_handler unreachable` is false, the reduced set gains
  `unreachable`, and the decoder reads a `ud2` at an instruction's start as it).
  The generated tables and vectors are regenerated, so `lake build` fails until the
  model follows (`Ryo/Vm/OpSem/Footprint.lean` uses `HandlerKind.trap`; the x86 decoder
  needs the bare `ud2`). Commit: "Inline unreachable as a bare ud2".

- No image format version (commit "Remove the image format and ABI versions"). `FORMAT_VERSION`
  is gone, and with it the generated `formatVersion` (`Ryo/Vm/Generated/Types.lean`), so
  `Ryo/Obj/Image.lean` no longer builds until updated. The header lost its `version` field and
  was reordered: magic 0, `crate_hash` 8, `size` 12, `stable_crate_id` 16, `data` 24,
  `data_size` 32, `text_size` 36, `text` 40, `functions` 48, then the rest as before, each 4
  bytes earlier (`scopes` 96, `call_sites` 104, `dropped` 112, `fixup_area` 124, `mode` 128,
  `jit_records` 132; size still 144). Drop the version check, `ImageError::Version` and the
  `version` in the header dump line; update lean/README.md and lean/docs (plan.md, reduced.md),
  which say the tables are pinned to `FORMAT_VERSION`.
