# User rules

- Committing. Whatever is uncommitted when you start stays uncommitted.
- Don't reference an uncommitted file from a committed one.
- Commit messages. Keep the title brief -- a line, not a paragraph -- and put what needs
  saying under it, ideally in one short paragraph
- Codegen dumps. After every change that can affect the generated code, run
  `./y.sh build && ./y.sh bench codegen` and commit the regenerated `tests/bench/codegen/`
  with that change, so its diff shows the effect.
