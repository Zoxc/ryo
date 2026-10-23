/-
`ryo-lean`: run MIR programs with the L0 spec's interpreter.

  ryo-lean run <program.json> [--fuel N]   interpret a dumped program (`Program` JSON, or a
                                           `RunRequest` with `program` and `args`)
  ryo-lean example <name> [out.json]       write one of the built-in example programs
-/
import Ryo
import Ryo.Examples

open Ryo.Spec Lean

def describeResult (r : RunResult) : String :=
  match r.result with
  | .ok (.returned v) => s!"returned {(toJson v).compress}"
  | .ok (.unwound p) => s!"unwound with payload {(toJson p).compress}"
  | .error o => toString o

def runFile (path : String) (fuel : Nat) : IO UInt32 := do
  let s ← IO.FS.readFile path
  let j ← IO.ofExcept (Json.parse s)
  let req : RunRequest ← match fromJson? j with
    | .ok (r : RunRequest) => pure r
    | .error _ => do
      let p : Program ← IO.ofExcept (fromJson? j)
      pure { program := p }
  let r := runWith concreteOracle req.program req.args fuel
  for e in r.events do
    match e with
    | .extCall sym args res =>
      let resS := match res with
        | .ret v => (toJson v).compress
        | .unwind p => s!"unwind {(toJson p).compress}"
      IO.println s!"event: {sym}({", ".intercalate (args.map fun a => (toJson a).compress)}) -> {resS}"
  IO.println s!"{describeResult r} after {r.steps} steps"
  pure (match r.result with
    | .ok (.returned _) => 0
    | .error (.exit c) => UInt32.ofNat c.toNat
    | _ => 1)

def main (args : List String) : IO UInt32 := do
  match args with
  | ["run", path] => runFile path 10000000
  | ["run", path, "--fuel", n] => runFile path n.toNat!
  | ["example", name] | ["example", name, _] =>
    match Ryo.Examples.byName name with
    | some p =>
      let out := (toJson ({ program := p } : RunRequest)).pretty
      match args with
      | [_, _, file] => IO.FS.writeFile file out
      | _ => IO.println out
      pure 0
    | none =>
      IO.eprintln s!"unknown example `{name}`; known: {Ryo.Examples.names}"
      pure 2
  | _ =>
    IO.eprintln "usage: ryo-lean run <program.json> [--fuel N]\n       ryo-lean example <name> [out.json]"
    pure 2
