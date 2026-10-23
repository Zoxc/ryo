/-
`ryo-lean`: run MIR programs with the L0 spec's interpreter.

  ryo-lean run <program.json> [--fuel N] [--stdout]
                                           interpret a dumped program (`Program` JSON, or a
                                           `RunRequest` with `program` and `args`). With
                                           `--stdout`, the bytes the program `write`s to fds 1
                                           and 2 go to stdout and stderr, the other events and
                                           the result to stderr (prefixed `ryo-lean: `), and the
                                           exit status is the program's: 0 when `main`
                                           returns, `c` for `exit(c)`, 134 for `abort`, 3 for
                                           UB, 4 for anything else (ill-formed, out of fuel, ..)
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

def runFile (path : String) (fuel : Nat) (stdout : Bool := false) : IO UInt32 := do
  let s ← IO.FS.readFile path
  let j ← IO.ofExcept (Json.parse s)
  let req : RunRequest ← match fromJson? j with
    | .ok (r : RunRequest) => pure r
    | .error _ => do
      let p : Program ← IO.ofExcept (fromJson? j)
      pure { program := p }
  let r := runWith concreteOracle req.program req.args fuel
  let out ← IO.getStdout
  let err ← IO.getStderr
  let log (s : String) : IO Unit :=
    if stdout then err.putStrLn s!"ryo-lean: {s}" else out.putStrLn s
  for e in r.events do
    match e with
    | .extCall sym args res =>
      let resS := match res with
        | .ret v => (toJson v).compress
        | .unwind p => s!"unwind {(toJson p).compress}"
      log s!"event: {sym}({", ".intercalate (args.map fun a => (toJson a).compress)}) -> {resS}"
    | .write fd bytes =>
      if stdout && (fd == 1 || fd == 2) then
        let h := if fd == 1 then out else err
        h.write ⟨bytes.toArray⟩
        h.flush
      else
        log s!"event: write({fd}, {repr (String.fromUTF8? ⟨bytes.toArray⟩)})"
  log s!"{describeResult r} after {r.steps} steps"
  if stdout then
    pure (match r.result with
      | .ok (.returned _) => 0
      | .error (.exit c) => UInt32.ofNat c.toNat
      | .error .abort => 134
      | .error (.ub _) => 3
      | _ => 4)
  else
    pure (match r.result with
      | .ok (.returned _) => 0
      | .error (.exit c) => UInt32.ofNat c.toNat
      | _ => 1)

def main (args : List String) : IO UInt32 := do
  match args with
  | ["run", path] => runFile path 10000000
  | ["run", path, "--fuel", n] => runFile path n.toNat!
  | ["run", path, "--stdout"] => runFile path 10000000 true
  | ["run", path, "--fuel", n, "--stdout"] | ["run", path, "--stdout", "--fuel", n] =>
    runFile path n.toNat! true
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
    IO.eprintln "usage: ryo-lean run <program.json> [--fuel N] [--stdout]\n       ryo-lean example <name> [out.json]"
    pure 2
