/-
RyoTest.Harness — test registry and assertions over interpreter runs.

Ports: MiniRust `tooling/minitest/src/main.rs` (`assert_stop`, `assert_ub`, `assert_abort`,
`assert_ill_formed`, `get_stdout`): a test builds a program with `Ryo.Spec.Mir.Builder`, runs it
with the concrete oracle and checks how it ended.
-/
import Ryo

namespace RyoTest

open Ryo.Spec

structure TestCase where
  name : String
  run : Unit → Except String Unit

def describe (r : RunResult) : String :=
  match r.result with
  | .ok (.returned v) => s!"returned {repr v}"
  | .ok (.unwound p) => s!"unwound with {repr p}"
  | .error o => toString o

/-- The program returns (MiniRust `assert_stop`). -/
def expectReturn (p : Program) (args : List (Value × Ty) := []) : Except String Unit :=
  let r := run p args
  match r.result with
  | .ok (.returned _) => .ok ()
  | _ => .error s!"expected a normal return, got {describe r}"

def expectReturnValue (p : Program) (v : Value) (args : List (Value × Ty) := []) :
    Except String Unit :=
  let r := run p args
  match r.result with
  | .ok (.returned w) => if v == w then .ok () else .error s!"expected {repr v}, got {repr w}"
  | _ => .error s!"expected a normal return, got {describe r}"

/-- UB whose message contains `msg` (MiniRust `assert_ub`). -/
def expectUb (p : Program) (msg : String) (args : List (Value × Ty) := []) : Except String Unit :=
  let r := run p args
  match r.result with
  | .error (.ub m) =>
    if (m.splitOn msg).length > 1 then .ok ()
    else .error s!"expected UB containing `{msg}`, got UB `{m}`"
  | _ => .error s!"expected UB `{msg}`, got {describe r}"

def expectAbort (p : Program) : Except String Unit :=
  let r := run p
  match r.result with
  | .error .abort => .ok ()
  | _ => .error s!"expected abort, got {describe r}"

def expectExit (p : Program) (code : Int) : Except String Unit :=
  let r := run p
  match r.result with
  | .error (.exit c) => if c == code then .ok () else .error s!"expected exit({code}), got exit({c})"
  | _ => .error s!"expected exit({code}), got {describe r}"

def expectIllFormed (p : Program) (msg : String := "") : Except String Unit :=
  let r := run p
  match r.result with
  | .error (.illFormed m) =>
    if (m.splitOn msg).length > 1 || msg == "" then .ok ()
    else .error s!"expected ill-formed `{msg}`, got `{m}`"
  | _ => .error s!"expected ill-formed, got {describe r}"

def expectUnwound (p : Program) : Except String Unit :=
  let r := run p
  match r.result with
  | .ok (.unwound _) => .ok ()
  | _ => .error s!"expected the run to unwind out of main, got {describe r}"

/-- The integers passed to `ryo_test_print` (MiniRust `get_stdout`). -/
def printed (r : RunResult) : List Int :=
  r.events.toList.flatMap fun
    | .extCall "ryo_test_print" args _ => args.filterMap fun | .int i => some i | _ => none
    | _ => []

def expectPrinted (p : Program) (expected : List Int) (ok : RunResult → Bool := fun _ => true) :
    Except String Unit :=
  let r := run p
  let got := printed r
  if got == expected && ok r then .ok ()
  else .error s!"expected prints {expected}, got {got} ({describe r})"

def check (b : Bool) (msg : String) : Except String Unit := if b then .ok () else .error msg

end RyoTest
