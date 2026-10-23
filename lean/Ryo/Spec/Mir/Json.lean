/-
Ryo.Spec.Mir.Json — the dump format.

Ports: none. The derived `Lean.ToJson`/`Lean.FromJson` instances of `Ryo.Spec.Mir.Syntax`
(and of the types and constants it contains) *are* the schema: a dump is `toJson program`.
The backend writer (`RYO_DUMP_LEAN`) is milestone M1b.

Conventions of the derived encoding: constructors with arguments are objects
`{"ctor": {"field": ...}}`, constructors without arguments are strings `"ctor"`, structures are
objects, `Option` is `null` or the value, `Align` is its byte count.
-/
import Ryo.Spec.Mir.Syntax
import Ryo.Spec.Lang.Values

namespace Ryo.Spec

open Lean

def Program.toJsonString (p : Program) : String := (toJson p).compress

def Program.ofJsonString (s : String) : Except String Program := do
  let j ← Json.parse s
  fromJson? j

/-- A run request: a program and the start function's arguments. -/
structure RunRequest where
  program : Program
  args : List (Value × Ty) := []
deriving ToJson, FromJson

end Ryo.Spec
