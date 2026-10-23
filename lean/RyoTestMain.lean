import RyoTest

open RyoTest

def main (args : List String) : IO UInt32 := do
  let filter := args.head?
  let mut failed := 0
  let mut passed := 0
  for t in allTests do
    if let some f := filter then
      if (t.name.splitOn f).length ≤ 1 then continue
    match t.run () with
    | .ok () => passed := passed + 1
    | .error msg =>
      failed := failed + 1
      IO.println s!"FAIL {t.name}: {msg}"
  IO.println s!"{passed} passed, {failed} failed"
  pure (if failed == 0 then 0 else 1)
