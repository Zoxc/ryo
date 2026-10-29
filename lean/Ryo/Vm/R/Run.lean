/-
Ryo.Vm.R.Run — running R programs: a function's steps with an environment answering its
events (`runCode`), a program of R functions whose calls between them are answered by running
the callee's R code (`Program.invoke`), and an image object as such a program
(`imageProgram`, `ryo-lean rrun`).

- `runCode c env ch fuel s`: `step` until the function ends, each `Query` answered by `env`.
- `Program.invoke`: a `Callee.func g` is run as `g`'s R code, its frame below the caller's
  (`fp_callee = sp - 16`, `sp` the caller's `fp - F`), its `Final` the call's answer (the
  return registers, the incoming area's bytes as the outgoing area's, the world; or unwinding),
  a tail call run in the frame it takes over. Other queries go to `Program.ext`; with no
  answer the run halts there (`Halt.external`).
- `imageProgram o`: the functions of image object `o` decoded (`DecodeObj.decodeAll`), their
  calls of image functions with the callee's `arg_size` as the stack size and, for an sret
  callee (`ret_kind = RET_SRET`), its `ret_size` as the destination's size (the image's
  claim; C1' is to check it against the return type). The world: the constant pool and the
  code constants as one immutable allocation each, the data area (statics) as a mutable one,
  the symbol slots, at the made-up addresses of `DecodeObj`;
  pointers between them (the read-only and data sections' `R_X86_64_64` relocations into
  those parts) carry their allocation's provenance, others (to symbols) are left as the
  object has them. A symbol slot holds its target's address as an integer, as the runtime
  fills it: with `Image.worldWith o ns`, the address of the environment's allocation `ns`
  gives for it (a native static or function, another image's part), else a made-up address
  outside every allocation (`Image.symAddr`; `Image.world`). Every allocation of the world is
  exposed (`worldWith_exposed`), so integers reach them as pointers do (`rebase`'s
  constants, a slot's value). One allocation per part, not per constant (D7's copies) or
  static: R is then more defined than L0 across entries, which a refinement allows (L0's
  globals map into the parts at offsets, reduced.md §C0.7), and a load of a relocated pool
  field reads the pointer a `RefAddr` of its target makes (`Ryo.Proofs.Provenance`). Each function's
  zero-sized frame objects (`Code.zeroSized`) come from outside, by symbol: `rrun --cert`
  gives the certificate's locals of size 0 (`Main.lean`; without a certificate there are none,
  and `addr` of a zero-sized local is UB).

Fuel bounds both the steps of each function and the depth of calls, and running out is a halt,
not a behavior.
-/
import Ryo.Vm.R.Sem
import Ryo.Vm.DecodeObj

namespace Ryo.Vm.R

open Ryo.Spec Ryo.Vm.OpSem

/-- Why a run stops without the function ending. -/
inductive Halt where
  | stop (s : Stop)
  | fuel
  /-- A query the environment doesn't answer. -/
  | external (q : Query)
deriving Repr, Inhabited

abbrev RM := Except Halt

def liftM {α : Type} (x : M α) : RM α := x.mapError .stop

/-- `c`'s steps from `s` until it ends, at most `fuel`, with `env` answering its queries. -/
def runCode (c : Code) (env : Query → RM Answer) (ch : OpSem.Choice := {}) : Nat → RState → RM Final
  | 0, _ => throw .fuel
  | n + 1, s => do
    let o ← match ← liftM (step c s ch) with
      | .ext q s => liftM (answer c s (← env q))
      | o => pure o
    match o with
    | .step s => runCode c env ch n s
    | .done f => pure f
    | .ext .. => throw (.stop (.illFormed "an answer gave an event"))

/-- A program of R functions by `Func` index (`none`: not decoded), and how its environment
answers what isn't a call of one of them. -/
structure Program where
  codes : Array (Option Code)
  ext : Query → Option (RM Answer) := fun _ => none

instance : Inhabited Program := ⟨{ codes := #[] }⟩

/-- A callee's `Final` as the answer to the call. -/
def Final.toAnswer (f : Final) : Answer :=
  match f.exit with
  | .ret regs incoming =>
    { result := .ret regs, frame := if incoming.isEmpty then [] else [incoming], world := f.world }
  | .unwind exc => { result := .unwind exc, world := f.world }
  -- `invoke` runs tail calls itself.
  | .tailCall .. => { result := .unwind ThinPointer.null, world := f.world }

/-- An external answer as the end of a function that tail-called outside the program. -/
def Answer.toFinal (a : Answer) : Final :=
  match a.result with
  | .ret regs => { exit := .ret regs (a.frame.head?.getD []), world := a.world }
  | .unwind exc => { exit := .unwind exc, world := a.world }

/-- Call `cal` with the argument registers `args` and the stack arguments `stack` at `sp`, in
`w`: a program function runs as R code (its tail calls too), anything else is `ext`'s. -/
def Program.invoke (p : Program) : Nat → Callee → Nat → Regs → List AbstractByte → World → RM Final
  | 0, _, _, _, _, _ => throw .fuel
  | fuel + 1, cal, sp, args, stack, w => do
    match cal with
    | .func g =>
      let some (some c) := p.codes[g]? | throw (.stop (.unsupported s!"function {g} isn't decoded"))
      let s ← liftM (entry c (sp - 16) args stack w)
      let env (q : Query) : RM Answer := match q.ext with
        | .call (.func h) args' sp' stack' => do
          pure (← p.invoke fuel (.func h) sp' args' stack' q.world).toAnswer
        | _ => (p.ext q).getD (throw (.external q))
      let f ← runCode c env {} fuel s
      match f.exit with
      | .tailCall cal' args' sp' stack' => p.invoke fuel cal' sp' args' stack' f.world
      | _ => pure f
    | _ =>
      let q : Query := ⟨.call cal args sp stack, w⟩
      match p.ext q with
      | some a => pure (← a).toFinal
      | none => throw (.external q)

/-- Where the stack starts: the first function's `fp`. -/
def stackTop : Nat := 0x7fff_0000

/-- Run function `f` of `p` on the argument registers `args` in `w` (no stack arguments). -/
def Program.run (p : Program) (f : Nat) (args : Regs) (w : World) (fuel : Nat := 100000) : RM Final :=
  p.invoke fuel (.func f) (stackTop + 16) args [] w

/-! ### Image objects -/

namespace Image

open Ryo.Obj

/-- Where the symbol of slot `s` is said to be: a made-up address, without an allocation. -/
def symAddr (s : Nat) : Nat := 0x2000_0000 + 16 * s

/-- An allocation of the environment that symbol slot `slot` holds the address of: a native
static or function, a thread-local, another image's part. The runtime fills the slot with
`addr` as a plain integer (no provenance), so the allocation is reached through exposure: the
world exposes it (`worldWith`). -/
structure NativeAlloc where
  slot : Nat
  addr : Nat
  data : List AbstractByte := []
  mutable : Bool := false
  kind : AllocationKind := .static
deriving Repr, Inhabited

/-- The address symbol slot `s` holds: its native allocation's, else a made-up one. -/
def slotAddr (ns : List NativeAlloc) (s : Nat) : Nat :=
  ((ns.find? (·.slot == s)).map (·.addr)).getD (symAddr s)

/-- The symbol slots' contents: each its symbol's address (`slotAddr`). -/
def symSlots (n : Nat) (ns : List NativeAlloc := []) : ByteArray :=
  ⟨((List.range n).flatMap fun s => (encodeBits 8 (slotAddr ns s)).filterMap AbstractByte.data).toArray⟩

/-- The symbol slot whose symbol is at `a`, if any. -/
def symAt? (n a : Nat) : Option Nat :=
  if a ≥ symAddr 0 && (a - symAddr 0) % 16 == 0 && (a - symAddr 0) / 16 < n then some ((a - symAddr 0) / 16)
  else none

/-- The image's parts as allocations: (made-up address, bytes, mutable, kind), in `AllocId`
order: the constant pool, the data area, the symbol slots, the code constants. -/
def parts (o : ImageObject) (ns : List NativeAlloc := []) : List (Nat × ByteArray × Bool × AllocationKind) :=
  let h := o.image.header
  let dataEnd := if h.jitRecords.count != 0 then h.jitRecords.off else h.dataSize
  let dataBytes := (o.elf.data o.data).extract o.dataBase (o.dataBase + dataEnd)
  [(DecodeObj.consts, o.image.bytes.extract h.consts.off (h.consts.off + h.consts.count), false, .const),
   (DecodeObj.datas, dataBytes, true, .static),
   (DecodeObj.syms, symSlots h.symbols.count ns, false, .static),
   (DecodeObj.ros, o.image.codeConsts, false, .const)]

def constsId : AllocId := 0
def dataId : AllocId := 1
def symsId : AllocId := 2
def roId : AllocId := 3

/-- Where `Arg`s point: into the parts. -/
def addrs : Addrs
  | .const k => some ⟨DecodeObj.consts + k, some constsId⟩
  | .data d => some ⟨DecodeObj.datas + d, some dataId⟩
  | .sym s => some ⟨DecodeObj.syms + 8 * s, some symsId⟩
  | .ro o => some ⟨DecodeObj.ros + o, some roId⟩
  | _ => none

/-- A section offset `(section, offset)` as a pointer into a part, if it is in one. -/
def pointerTo (o : ImageObject) (i : Nat) (off : Int) : Option ThinPointer :=
  let h := o.image.header
  let dataEnd := if h.jitRecords.count != 0 then h.jitRecords.off else h.dataSize
  let within (base len : Nat) : Option Nat :=
    if base ≤ off && off ≤ base + len then some (off - base).toNat else none
  if i == o.ro.index then
    if let some d := within (o.roBase + h.consts.off) h.consts.count then addrs (.const d)
    else (within (o.roBase + h.codeConsts.off) h.codeConsts.count).bind (addrs ∘ .ro)
  else if i == o.data.index then
    (within o.dataBase dataEnd).bind (addrs ∘ .data)
  else none

/-- The image's memory: its parts as allocations, with the pointers between them, then the
native allocations `ns` (from `AllocId` 4 on, in order). -/
def worldMem (o : ImageObject) (ns : List NativeAlloc) : Memory := Id.run do
  let mut mem : Memory := {}
  for (addr, bs, mutable, kind) in parts o ns do
    let a : Allocation := { data := bs.toList.toArray.map AbstractByte.ofByte, addr,
                            align := Align.ofBytes 8, kind, mutable := mutable && kind != .vtable,
                            vtableRo := by intro h; simp [h] }
    mem := ⟨mem.allocs.push a⟩
  -- `R_X86_64_64` fields of the parts (section, part start, part id) that point into a part.
  let h := o.image.header
  let dataEnd := if h.jitRecords.count != 0 then h.jitRecords.off else h.dataSize
  let fields : List (Nat × Nat × Nat × AllocId) :=
    [(o.ro.index, o.roBase + h.consts.off, h.consts.count, constsId),
     (o.data.index, o.dataBase, dataEnd, dataId)]
  for (sect, base, len, id) in fields do
    for r in o.elf.relocsOf sect do
      if r.type != .abs64 || r.offset < base || r.offset + 8 > base + len then continue
      let .ok (.sect i off) := o.elf.target r | continue
      let some p := pointerTo o i off | continue
      mem := mem.writeInit ⟨(mem.get? id).get!.addr + (r.offset - base), some id⟩ (encodePtr p)
  for n in ns do
    let a : Allocation := { data := n.data.toArray, addr := n.addr, align := Align.one,
                            kind := n.kind, mutable := n.mutable && n.kind != .vtable,
                            vtableRo := by intro h; simp [h] }
    mem := ⟨mem.allocs.push a⟩
  return mem

/-- The image's world with the environment's allocations `ns` that its symbol slots point to:
every allocation exposed (the image's parts, which code reaches as integers too: `rebase`'s
constants, a symbol slot's value; and the natives, reachable only that way). -/
def worldWith (o : ImageObject) (ns : List NativeAlloc) : World :=
  let mem := worldMem o ns
  { mem, exposed := List.range mem.allocs.size }

/-- The image's world alone: symbol slots hold made-up addresses outside every allocation. -/
def world (o : ImageObject) : World := worldWith o []

/-- Every allocation of the world is exposed. -/
theorem worldWith_exposed (o : ImageObject) (ns : List NativeAlloc) (id : AllocId)
    (h : id < (worldWith o ns).mem.allocs.size) : id ∈ (worldWith o ns).exposed := by
  simpa [worldWith] using h

/-- The callee of instruction `k` if it is a `call` or `tail_call` of an image function. -/
def imageCallee (d : Decoded) (k : Nat) : Option Nat :=
  match d.insns[k]? with
  | some (.native op (_ :: .func g :: _)) => if op.full == some .call then some g else none
  | some (.native op (.func g :: _)) => if op.full == some .tailCall then some g else none
  | _ => none

end Image

/-- Image object `o` as a program (see the module comment), and its world; `zeroSized` gives
each function's zero-sized frame objects by its symbol. -/
def imageProgram (o : Ryo.Obj.ImageObject) (zeroSized : String → List Int := fun _ => []) :
    Program × World :=
  let decoded := DecodeObj.decodeAll o
  let code (i : Nat) (fi : Ryo.Obj.FuncInputs) (d : Decoded) : Code :=
    { d, mode := fi.mode, ρ := Image.addrs, argSize := (o.funcs[i]?.map (·.argSize)).getD 0,
      zeroSized := (o.funcs[i]?.map fun f => zeroSized (o.funcName f.codeOff)).getD [],
      stackSize := fun k => ((Image.imageCallee d k).bind (o.funcs[·]?)).map (·.argSize) |>.getD 0,
      sretSize := fun k => do
        let g ← Image.imageCallee d k
        let e ← o.funcs[g]?
        if e.retKind == Asm.retSret then some e.retSize else none }
  ({ codes := decoded.mapIdx fun i x => x.map fun (fi, d) => code i fi d }, Image.world o)

/-! ### Text -/

def bytesText (bs : List AbstractByte) : String :=
  match decodeBits bs with
  | some n => s!"{n}"
  | none => "[" ++ ", ".intercalate (bs.map fun | .uninit => "_" | .init b _ => s!"{b.toNat}") ++ "]"

def Regs.text (rs : Regs) : String :=
  " ".intercalate (rs.vals.map fun (r, bs) =>
    (match r with | .gpr i => s!"gpr{i}" | .xmm i => s!"xmm{i}") ++ "=" ++ bytesText bs)

def Callee.text (o : Option Ryo.Obj.ImageObject) : Callee → String
  | .func f => s!"fn{f}"
  | .sym s => match o with
    | some o => (o.slotName s).toOption.getD s!"sym{s}"
    | none => s!"sym{s}"
  | .symInd s => s!"[sym{s}]"
  | .ptr p => match o.bind fun o => (Image.symAt? o.image.header.symbols.count p.addr).map (o, ·) with
    | some (o, s) => s!"ptr {(o.slotName s).toOption.getD s!"sym{s}"}"
    | none => s!"ptr {p.addr}"

def Final.text (f : Final) : String :=
  match f.exit with
  | .ret regs _ => s!"ret {regs.text}"
  | .unwind exc => s!"unwind {exc.addr}"
  | .tailCall c args _ _ => s!"tail call {c.text none} {args.text}"

def Halt.text (o : Option Ryo.Obj.ImageObject) : Halt → String
  | .stop s => toString s
  | .fuel => "out of fuel"
  | .external q => match q.ext with
    | .call c args _ _ => s!"external call {c.text o} {args.text}"
    | .island s _ _ _ _ => s!"island {(Callee.sym s).text o}"

end Ryo.Vm.R

namespace Ryo.Vm.R

/-- `ryo-lean rrun <image.o> <function> [<int>...] [--fuel N] [--unwind <text>] [--cert
<cert.json>]`: run an image function (by index,
symbol name, or the first whose name contains the text) as R (`imageProgram`), its integer
arguments in the first integer registers (8 bytes each, two's complement), and print how it
ends: the return registers, unwinding, or why it halted (a `Stop`, an external call or island,
out of fuel). Exit status 0 when it returns. With `--all` for the function, every function on
those arguments, a line each. With `--unwind <text>`, a call of a symbol whose name contains
the text is answered by unwinding (exception object `0xe0`): landing pads run. With `--cert`
(which `Main.lean` reads, passing `zeroSized`), each function's zero-sized frame objects are its
certificate's locals of size 0 (`Code.zeroSized`). -/
def cli (args : List String) (zeroSized : String → List Int := fun _ => []) : IO UInt32 := do
  let (fuel, args) := match args.idxOf? "--fuel" with
    | some i => ((args[i + 1]?.bind String.toNat?).getD 100000, args.take i ++ args.drop (i + 2))
    | none => (100000, args)
  let (unwind, args) := match args.idxOf? "--unwind" with
    | some i => (args[i + 1]?, args.take i ++ args.drop (i + 2))
    | none => (none, args)
  let path :: fn :: ints := args
    | IO.eprintln "usage: ryo-lean rrun <image.o> <function>|--all [<int>...] [--fuel N] [--unwind <text>] [--cert <cert.json>]"; return 2
  let o ← IO.ofExcept (Ryo.Obj.readImageObject (← IO.FS.readBinFile path))
  let names := o.funcs.map fun f => o.funcName f.codeOff
  if fn == "--all" then
    -- Every function, on the arguments given: one line each.
    let some vs := ints.mapM String.toInt? | IO.eprintln "arguments must be integers"; return 2
    let (p, w) := imageProgram o zeroSized
    for h : f in [0:names.size] do
      let r := match p.run f (Regs.ofInts (vs.map fun v => (BitVec.ofInt 64 v).toNat)) w fuel with
        | .ok fin => fin.text
        | .error h => s!"halt: {h.text o}"
      IO.println s!"fn{f} {names[f]}: {r}"
    return 0
  let some f := fn.toNat? <|> names.findIdx? (· == fn) <|>
      names.findIdx? (fun n => (n.splitOn fn).length > 1)
    | IO.eprintln s!"no function `{fn}`"; return 2
  let some vs := ints.mapM String.toInt?
    | IO.eprintln "arguments must be integers"; return 2
  let (p, w) := imageProgram o zeroSized
  -- `--unwind <text>`: external calls of symbols whose name contains it unwind (exception 0xe0).
  let p := match unwind with
    | none => p
    | some t => { p with ext := fun q => match q.ext with
      | .call (.sym s) .. =>
        if ((Callee.sym s).text o).splitOn t |>.length |> (· > 1) then
          some (pure { result := .unwind ⟨0xe0, none⟩, world := q.world })
        else none
      | _ => none }
  IO.println s!"fn{f} {names[f]?.getD "?"}"
  match p.run f (Regs.ofInts (vs.map fun v => (BitVec.ofInt 64 v).toNat)) w fuel with
  | .ok fin =>
    IO.println fin.text
    pure (if fin.exit matches .ret .. then 0 else 1)
  | .error h =>
    IO.println s!"halt: {h.text o}"
    pure 1

end Ryo.Vm.R
