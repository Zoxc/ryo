/-
Ryo.Check.Image.Dump — the checks of aot.md §C4 that need the MIR dump (`RYO_DUMP_LEAN`,
`Ryo.Spec.Program`) besides the pool's (`Ryo/Check/Image/Pool.lean`), as far as the object and
the dump decide them without knowing which instance each function is:

- **The C `main`.** A VM entry fn gets the backend's C `main` (`lower/entry.rs`) in its own
  image: a function named `target.entry_name` (`main` on ELF) with no rustc instance and no
  certificate, added exactly when the entry fn is one of the CGU's VM functions
  (`partition.rs` `build_cgu`). So an image function is named `main` exactly when one is the
  dump's start instance (`Program.start`). (There is no `__ryo_main` slot any more.)
- **Function symbols.** An image function whose symbol is a dumped instance's is not an
  intrinsic instance (the image compiles MIR bodies). It may be `ext`: the dump writes
  `drop_in_place::<dyn Trait>` and `ThreadLocal` shims as `ext` though the image compiles
  them, so "ext" doesn't tell a foreign item from those; C1' decides.
- **Symbol slots** are counted by what the dump says they name (an instance, a static, or
  nothing the dump knows: handlers' islands, std code outside the dump). A name is the dump's
  spelling or it names nothing in the dump, so there is nothing more to check per slot here.

What remains for C1' (its certificate maps each function to its instance): that each
function's symbol is its instance's `tcx.symbol_name`, that each `Sym s` operand's slot names
the callee or static the MIR names, and the signature fields (`arg_size`, `ret_kind`) against
the instance's `ArgPlan`.
-/
import Std.Data.HashMap
import Ryo.Spec
import Ryo.Check.Image.Relocs

namespace Ryo.Check.Image.Dump

open Ryo.Spec Ryo.Obj Std

/-- `target.entry_name` on the ELF targets: the C `main`'s symbol. -/
def cMainName : String := "main"

structure Report where
  /-- The C `main`'s symbol (`cMainName`), if the image has it. -/
  main : Option String := none
  funcs : Nat := 0
  /-- Functions whose symbol is a dumped instance's. -/
  funcsInDump : Nat := 0
  slots : Nat := 0
  slotsInstances : Nat := 0
  slotsStatics : Nat := 0
  errors : Array String := #[]
  deriving Inhabited

def Report.ok (r : Report) : Bool := r.errors.isEmpty

def check (prog : Program) (o : ImageObject) : Report := Id.run do
  let inst : HashMap String Instance := prog.instances.foldl (init := {}) fun m i => m.insert i.symbol i
  let statics : HashMap String Nat := (Array.range prog.globals.size).foldl (init := {}) fun m g =>
    match prog.globals[g]!.symbol with
    | some s => m.insert s g
    | none => m
  let startSym := prog.symbol prog.start
  let mut rep : Report := { funcs := o.funcs.size, slots := o.image.header.symbols.count }
  -- Functions.
  let names := o.funcs.map fun f => o.funcName f.codeOff
  for h : i in [0:names.size] do
    let n := names[i]
    if let some ins := inst[n]? then
      rep := { rep with funcsInDump := rep.funcsInDump + 1 }
      if ins.kind matches .intrinsic .. then
        rep := { rep with errors := rep.errors.push s!"func {i} `{n}` is a dumped intrinsic instance" }
  -- The C `main`: exactly with the entry fn.
  let hasMain := names.contains cMainName
  if hasMain then rep := { rep with main := some cMainName }
  if hasMain && !names.contains startSym then
    rep := { rep with errors := rep.errors.push s!"the image has the C `{cMainName}`, but the dump's entry instance `{startSym}` isn't an image function" }
  else if !hasMain && names.contains startSym then
    rep := { rep with errors := rep.errors.push s!"the entry instance `{startSym}` is an image function, but the image has no C `{cMainName}`" }
  -- Symbol slots.
  for s in [0:o.image.header.symbols.count] do
    let .ok n := o.slotName s | continue
    if inst.contains n then rep := { rep with slotsInstances := rep.slotsInstances + 1 }
    else if statics.contains n then rep := { rep with slotsStatics := rep.slotsStatics + 1 }
  return rep

/-- The line `ryo-lean check-pool` prints for one object, then the errors. -/
def Report.render (r : Report) (path : String) : Array String :=
  #[s!"dump-check {path}: main {r.main.getD "-"} funcs {r.funcs} in-dump {r.funcsInDump} slots {r.slots} slot-instances {r.slotsInstances} slot-statics {r.slotsStatics} errors {r.errors.size}"]
    ++ r.errors.map ("error: " ++ ·)

end Ryo.Check.Image.Dump
