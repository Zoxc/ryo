/-
`ryo-lean`: run MIR programs with the L0 spec's interpreter; read image objects.

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
  ryo-lean obj <file.o>                    print the image of an image object: header, symbol
                                           slots, functions and their code's relocations
                                           (`Ryo.Obj.ImageObject.summary`); exit status 1 if
                                           it can't be read
  ryo-lean elf <file.o>                    print an ELF object's sections, symbols and
                                           relocations (`Ryo.Obj.Elf.dump`)
  ryo-lean ehframe <file.o>                an object's `.eh_frame`: CIEs, FDEs and each one's
                                           row table (`Ryo.Obj.EhFrame.dump`)
  ryo-lean lsda <image object>             per function of the image its FDE and LSDA call
                                           sites, and whether they are the image's call-site
                                           table (`Ryo.Obj.ImageObject.lsdaLines`)
  ryo-lean exec-item                       run x86 items on states, JSON lines on stdin and
                                           stdout (`Ryo/X86/Cosim.lean`, x86.md §B.3)
  ryo-lean decode <inputs.json>            decode one function's machine code to R
                                           (`Ryo.Vm.decodeReduced`; the JSON form is in
                                           `Ryo/Vm/DecodeReduced.lean`) and print its text,
                                           or `error at <byte>: <what>` (exit status 1)
  ryo-lean decode <image object>           each function of the image decoded, as
                                           scripts/lean-decode-ref prints Rust's
  ryo-lean dead <image object> [<dump.json> <cert.json>]
                                           the functions the checked decoding rejects (a
                                           dropped store not shown dead), with a reader
                                           of each such store; with the dump and the
                                           certificate, also given the facts check-cert
                                           verifies (calls' stack arguments and sret
                                           destinations, islands' templates)
  ryo-lean check-pool <dump.json> <image object>... [-v]
                                           the checks of each object against the MIR dump:
                                           the constant pool and vtables
                                           (`Ryo/Check/Image/Pool.lean`), a `pool-check` line
                                           with the pool references matched, byte constants,
                                           not in the dump and mismatched (each mismatch with
                                           details; `-v` lists those not in the dump too), and
                                           `__ryo_main` and the function symbols
                                           (`Ryo/Check/Image/Dump.lean`), a `dump-check` line;
                                           exit status 1 on a mismatch or an error
  ryo-lean check-cert <dump.json> <cert.json> <image object>... [-v]
                                           the lowering certificate (`RYO_DUMP_LEAN`'s
                                           `<crate>.cert.json`) against each object's decoded
                                           code and the dump (`Ryo/Check/Lower/CertCheck.lean`):
                                           a `cert-check` line (functions, certificates, calls
                                           and how their plans were verified, islands, the
                                           escape coverage of the addresses taken), a
                                           `dead-check` line (the dead-store check with the
                                           certificate's facts) and the errors; then a
                                           `cert-map` line (certificate images without an
                                           object); exit status 1 on an error. `-v` prints
                                           every error (default: the first 50 per object). A
                                           crate's image objects (one per CGU) go together,
                                           each checked against its own certificate image
                                           (by `cgu_hash`)
  ryo-lean check-image <image object>... [--registry <registry object>]
                                           the image checks that need no dump (aot.md §C4,
                                           `Ryo.Check.Image`) on a link's image objects and
                                           registry object: each mismatch, then a summary;
                                           exit status 1 on any
  ryo-lean opsem                           `opSem` on JSON lines on stdin, a result per line
                                           on stdout (`Ryo/Vm/OpSem/Json.lean`), for the
                                           differential test against the handlers
  ryo-lean effects [<out.rs>]              the JIT's handler effect table, generated from the
                                           footprints (`Ryo/Vm/OpSem/JitEffects.lean`), as
                                           `vm/bytecode/src/jit/effects_table.rs`
  ryo-lean rrun <image object> <fn>|--all [<int>...] [--fuel N] [--unwind <text>] [--cert <cert.json>]
                                           run an image function as R (`Ryo.Vm.R.cli`); with
                                           `--cert`, each function's zero-sized frame objects
                                           are its certificate's locals of size 0 (`addr` of
                                           one is a pointer without provenance; without the
                                           certificate it is UB)
-/
import Ryo
import Ryo.Examples
import Ryo.Vm.DecodeObj
import Ryo.Check.Image

open Ryo.Spec Lean

def describeResult (r : RunResult) : String :=
  match r.result with
  | .ok (.returned v) => s!"returned {(toJson v).compress}"
  | .ok (.unwound p) => s!"unwound with payload {(toJson p).compress}"
  | .error o => toString o

def runFile (path : String) (fuel : Nat) (stdout : Bool := false) : IO UInt32 := do
  let s ← IO.FS.readFile path
  let j ← IO.ofExcept (Json.parse s)
  -- A `RunRequest` has a `program` field, a bare `Program` doesn't: pick the decoder by it, so
  -- an error inside a request is reported as itself.
  let req : RunRequest ← match j.getObjVal? "program" with
    | .ok _ => IO.ofExcept (fromJson? j)
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
      | .error (.exit c) => UInt32.ofNat (c % 256).toNat
      | .error .abort => 134
      | .error (.ub _) => 3
      | _ => 4)
  else
    pure (match r.result with
      | .ok (.returned _) => 0
      | .error (.exit c) => UInt32.ofNat (c % 256).toNat
      | _ => 1)

def decodeFile (path : String) : IO UInt32 := do
  let j ← IO.ofExcept (Json.parse (← IO.FS.readFile path))
  let i ← IO.ofExcept (Ryo.Vm.Inputs.ofJson j)
  let r := i.decode
  IO.print (Ryo.Vm.decodeText r)
  pure (if r matches .ok _ then 0 else 1)

def decodeObj (path : String) : IO UInt32 := do
  match Ryo.Obj.readImageObject (← IO.FS.readBinFile path) with
  | .ok o =>
    for l in Ryo.Vm.DecodeObj.objLines o do IO.println l
    pure 0
  | .error e =>
    IO.println s!"error: {e}"
    pure 1

def deadObj (path : String) (dumpCert : Option (String × String) := none) : IO UInt32 := do
  match Ryo.Obj.readImageObject (← IO.FS.readBinFile path) with
  | .ok o =>
    let none_ : (Nat → Ryo.Vm.Frame.Facts) × (String → Option String) := (fun _ => {}, fun _ => none)
    let (extra, islands) ← match dumpCert with
      | none => pure none_
      | some (dump, certPath) => do
        let p : Program ← IO.ofExcept (Program.ofJsonString (← IO.FS.readFile dump))
        let cert ← IO.ofExcept (Ryo.Check.Lower.Cert.ofJsonString (← IO.FS.readFile certPath))
        pure (Ryo.Check.Lower.deadFacts p cert o)
    for l in Ryo.Vm.DecodeObj.deadLines o extra islands do IO.println l
    pure 0
  | .error e =>
    IO.println s!"error: {e}"
    pure 1

def checkPool (dump : String) (objs : List String) (verbose : Bool) : IO UInt32 := do
  let j ← IO.ofExcept (Json.parse (← IO.FS.readFile dump))
  let p : Program ← IO.ofExcept (fromJson? j)
  let mut status : UInt32 := 0
  for path in objs do
    match Ryo.Obj.readImageObject (← IO.FS.readBinFile path) with
    | .ok o =>
      let r := Ryo.Check.Image.Pool.checkObject p o
      for l in r.render path verbose do IO.println l
      let d := Ryo.Check.Image.Dump.check p o
      for l in d.render path do IO.println l
      unless r.ok && d.ok do status := 1
    | .error e =>
      IO.println s!"pool-check {path}: error: {e}"
      status := 1
  pure status

def checkCert (dump certPath : String) (objs : List String) (verbose : Bool) : IO UInt32 := do
  let p : Program ← IO.ofExcept (Program.ofJsonString (← IO.FS.readFile dump))
  let cert ← IO.ofExcept (Ryo.Check.Lower.Cert.ofJsonString (← IO.FS.readFile certPath))
  let mut status : UInt32 := 0
  let mut read : Array (String × Ryo.Obj.ImageObject) := #[]
  for path in objs do
    match Ryo.Obj.readImageObject (← IO.FS.readBinFile path) with
    | .ok o => read := read.push (path, o)
    | .error e =>
      IO.println s!"cert-check {path}: error: {e}"
      status := 1
  for (path, o) in read do
    let r := Ryo.Check.Lower.checkObject p cert o
    let ls := r.render path
    for l in if verbose then ls else ls.extract 0 52 do IO.println l
    if !verbose && ls.size > 52 then IO.println s!"error: ... and {ls.size - 52} more"
    unless r.ok do status := 1
  let un := Ryo.Check.Lower.unmatched cert (read.map (·.2))
  IO.println s!"cert-map: images {cert.images.size} certificates {cert.size} unmatched {un.size}"
  for e in un do IO.println s!"error: {e}"
  unless un.isEmpty do status := 1
  pure status

def objFile (path : String) : IO UInt32 := do
  let bytes ← IO.FS.readBinFile path
  match Ryo.Obj.readImageObject bytes with
  | .ok o =>
    for l in o.summary do IO.println l
    pure 0
  | .error e =>
    IO.println s!"error: {e}"
    pure 1

def elfFile (path : String) : IO UInt32 := do
  let bytes ← IO.FS.readBinFile path
  match Ryo.Obj.readElf bytes with
  | .ok e =>
    for l in e.dump do IO.println l
    pure 0
  | .error e =>
    IO.println s!"error: {e}"
    pure 1

def ehframeFile (path : String) : IO UInt32 := do
  let bytes ← IO.FS.readBinFile path
  let r : Except String (Array String) := do
    let e ← Ryo.Obj.readElf bytes
    let (_, eh) ← Ryo.Obj.EhFrame.readEhFrame e
    pure (Ryo.Obj.EhFrame.dump e eh)
  match r with
  | .ok ls =>
    for l in ls do IO.println l
    pure 0
  | .error e =>
    IO.println s!"error: {e}"
    pure 1

def lsdaObj (path : String) : IO UInt32 := do
  match Ryo.Obj.readImageObject (← IO.FS.readBinFile path) with
  | .ok o =>
    let ls := o.lsdaLines
    for l in ls do IO.println l
    pure (if ls.any (·.startsWith "error") then 1 else 0)
  | .error e =>
    IO.println s!"error: {e}"
    pure 1

/-- `rrun`'s arguments without `R.cli`'s options `--fuel N` and `--unwind <text>`. -/
def stripRunOptions : List String → List String
  | "--fuel" :: _ :: l => stripRunOptions l
  | "--unwind" :: _ :: l => stripRunOptions l
  | a :: l => a :: stripRunOptions l
  | [] => []

/-- `ryo-lean rrun`, with `--cert <cert.json>` read here (`Ryo.Vm.R` doesn't import the
certificate): per function symbol, the offsets of its certificate's locals of size 0 as
`Code.zeroSized`, from the image object's own certificate image (`Cert.functionsOf`; the
first certificate of a symbol, as `check-cert` takes it). -/
def rrun (args : List String) : IO UInt32 := do
  match args.idxOf? "--cert" with
  | none => Ryo.Vm.R.cli args
  | some i =>
    let some path := args[i + 1]? | IO.eprintln "--cert needs a certificate file"; return 2
    let cert ← IO.ofExcept (Ryo.Check.Lower.Cert.ofJsonString (← IO.FS.readFile path))
    let rest := args.take i ++ args.drop (i + 2)
    -- The object is the first argument once the options (`R.cli`'s too) and their values are
    -- removed, as `R.cli` takes it.
    let some objPath := (stripRunOptions rest).head? | IO.eprintln "rrun needs an image object"; return 2
    let o ← IO.ofExcept (Ryo.Obj.readImageObject (← IO.FS.readBinFile objPath))
    let zs : Std.HashMap String (List Int) := (cert.functionsOf o).foldl (init := {}) fun m (sym, fc) =>
      if m.contains sym then m
      else m.insert sym ((fc.locals.filter (·.size == 0)).toList.map (·.off))
    Ryo.Vm.R.cli rest (fun sym => zs.getD sym [])

def main (args : List String) : IO UInt32 := do
  match args with
  | "check-image" :: rest => Ryo.Check.Image.cli rest
  | ["obj", path] => objFile path
  | ["elf", path] => elfFile path
  | ["dead", path] => deadObj path
  | ["dead", path, dump, cert] => deadObj path (some (dump, cert))
  | "check-pool" :: dump :: objs@(_ :: _) =>
    checkPool dump (objs.filter (· != "-v")) (objs.contains "-v")
  | "check-cert" :: dump :: cert :: objs@(_ :: _) =>
    checkCert dump cert (objs.filter (· != "-v")) (objs.contains "-v")
  | ["ehframe", path] => ehframeFile path
  | ["lsda", path] => lsdaObj path
  | ["decode", path] => if path.endsWith ".json" then decodeFile path else decodeObj path
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
  | ["exec-item"] => Ryo.X86.Cosim.main
  | ["opsem"] => Ryo.Vm.OpSem.Json.main
  | "effects" :: rest => Ryo.Vm.OpSem.JitEffects.main rest
  | "rrun" :: rest => rrun rest
  | _ =>
    IO.eprintln "usage: ryo-lean run <program.json> [--fuel N] [--stdout]\n       ryo-lean example <name> [out.json]\n       ryo-lean obj <file.o>\n       ryo-lean elf <file.o>\n       ryo-lean decode <inputs.json | file.o>\n       ryo-lean dead <file.o> [<dump.json> <cert.json>]\n       ryo-lean ehframe|lsda <file.o>\n       ryo-lean check-pool <dump.json> <file.o>... [-v]\n       ryo-lean check-cert <dump.json> <cert.json> <image.o>... [-v]\n       ryo-lean check-image <image.o>... [--registry <registry.o>]\n       ryo-lean exec-item\n       ryo-lean opsem\n       ryo-lean effects [<out.rs>]\n       ryo-lean rrun <image.o> <fn>|--all [<int>...] [--fuel N] [--unwind <text>] [--cert <cert.json>]"
    pure 2
