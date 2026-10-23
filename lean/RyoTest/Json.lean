/-
JSON round trip of programs (mir-spec §A.8 acceptance: `ryo-lean run <file.json>` interprets a
program built with the DSL): `ofJsonString (toJsonString p) = p`, and the parsed program runs
the same.
-/
import RyoTest.Harness
import RyoTest.Call
import RyoTest.Enum
import RyoTest.Unsized
import RyoTest.Divergence
import Ryo.Examples

namespace RyoTest.Json

open Ryo.Spec

def roundTrip (name : String) (p : Program) : TestCase :=
  ⟨s!"json/{name}", fun _ => do
    let q ← Program.ofJsonString p.toJsonString
    check (q == p) "program changed in the JSON round trip"
    let r1 := run p
    let r2 := run q
    check (describe r1 == describe r2 && r1.events.toList == r2.events.toList)
      s!"runs differ: {describe r1} vs {describe r2}"⟩

def tests : List TestCase :=
  (Ryo.Examples.all.map fun (n, p) => roundTrip n p) ++ [
    roundTrip "dynamic_dispatch" RyoTest.Unsized.dynamicDispatch,
    roundTrip "niche_enum" RyoTest.Enum.nicheWorks,
    roundTrip "catch_unwind" (RyoTest.Call.catchUnwind true),
    roundTrip "floats" RyoTest.Divergence.floats,
    roundTrip "const_values" RyoTest.Divergence.constValues
  ]

end RyoTest.Json
