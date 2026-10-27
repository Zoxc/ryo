/-
Ryo.Check.Lower.CertCheck — the first part of the lowering check C1' (aot.md §C1): the
certificate (`Cert.lean`) against an image object's decoded code and the MIR dump, as far as
they decide it without the relational spec. `ryo-lean check-cert`,
`scripts/lean-cert-check.py` over the corpus.

Per object:

- **Image map.** A crate has an image object per CGU with VM functions, and its certificate
  file a certificate image per image: the object's is the one whose CGU name hashes
  (`cguHash`) to the header's `cgu_hash`, and there must be exactly one; each certificate
  image must have an object (`unmatched`, over the objects checked together).
- **Function map.** Within the object's certificate image, each image function (its symbol)
  has exactly one certificate and each certificate one function, in image order. An
  `#[inline]` function rustc copied into several CGUs is lowered once per copy, and the copies
  differ (a call of a VM function is a `call` in that function's CGU and a `call.sym`
  elsewhere), so each copy has its own image's certificate and is checked against it.
  Functions whose symbol is a dumped instance with a body are counted; for them the dump is
  used below.
- **Own signature.** `argSize = plan.stackSize = FuncEntry.arg_size`, `retKind =
  FuncEntry.ret_kind`, `frameSize` the decoded frame size, an sret slot iff the return kind is
  `RET_SRET`, and the `arg` instructions are exactly the prologue's and are the plan's register
  pieces in order (`frame.rs`, `prologue`: sret `gpr0` into the sret slot, `Reg` into its
  input's home + offset, `PtrReg` into the input's pointer slot). With a dumped body and `abi`:
  the return kind and plan recomputed from the ABI (`Plan.lean`, `sig.rs`) are the
  certificate's, `ret_size` the ABI's return size, and the locals, spread argument and caller
  location agree with the body.
- **Ranges.** Prologue, blocks (statements, terminator), stubs and pads, in that order, are
  consecutive and cover the instructions; as many blocks as the dumped body, each with its
  statement count (the fused statement counted), except blocks the dumper truncated (their
  terminator calls an `ext` instance `ryo-dump: unsupported …`).
- **Calls.** Each decoded `call*` / `tail_call*` instruction has exactly one call entry and vice
  versa; the kind fits the opcode; `k` is the return kind (0 for sret); the argument list's
  register words are what `call.rs`'s `pass_args` builds from the plan (registers, integer
  sizes rounded up to a power of two, `ARG_ADDR` for by-address pieces; tail calls pass the
  incoming sret and `Indirect` pointers, whose slots the certificate gives; the other slots are
  homes, unknown here, but one input's pieces must share one). The fixed signatures of
  `virtualDrop` (`unsafe fn(*mut ())`) and `threadLocal` (no arguments, a pointer back).
  The plan is then **verified** by
  (i) the callee's `FuncEntry` for a `Ref.func` callee (`arg_size = stackSize`, `ret_kind`,
  `ret_size` for sret; also the callee's own certificate plan), or (ii) the dump: a call
  alone in the range of a terminator whose dumped ABI is known (`call`/`tailCall` with an
  `abi`, `drop` of glue with a body, `assert` of a panic function with a body) has the plan,
  return kind and return size recomputed from that ABI; or (iii) neither (counted).
- **Islands.** Each `island` instruction's symbol (its slot's name) is in the islands table.
- **Escape coverage** (§C1, "Escape/storage side data"; `checkAddrs`). Every frame address the
  code takes, an `addr`'s `s` (native, or a handler's footprint `addrs`) and a by-address
  (`ARG_ADDR`) argument's slot of a call or tail call, is one `State.addrOf` defines: (i) inside
  an object escaped on every path to the instruction, or (ii) the end `e.off + e.size` of such
  an object `e` of non-zero size, or (iii) the offset of a certificate local of size 0 (a
  zero-sized object, which never escapes). "Escaped on every path" is `Frame.mustEscapedAt`: a
  forward must-dataflow over successors and landing pads, nothing escaped at entry, the scopes
  before each instruction applied as R's step does (`Escape` adds its range as an object, `End`
  removes the objects it covers whole, `Lend` nothing). Anything else is an error. Counted per
  address taken, by the first of (i)–(iii) that holds (`addrs`, `by-escape`, `at-end`,
  `zero-sized`; `addr-args` of them are by-address arguments). (iii) trusts the certificate's
  locals (offsets, sizes) as far as the checks above go (their count against the dump).

Errors are rejections; gaps (no dumped body, no ABI) are counted.

**Facts** (`Cert.facts`): what the dead-store check (`Frame.Facts`) may assume of a function:
its calls' stack-argument sizes and sret sizes, only for calls verified by (ii), and the
islands' templates; `check-cert`'s dead-store count merges them with `DecodeObj.imageFacts`,
which bounds the calls of (i) by the callee's `arg_size` once the callee's own code is checked
to stay within it. (ii) and the templates rely on what C1' checks later: that the call ↔ terminator map is right (the call instruction
lowers that terminator, so its callee has that ABI), and that an island's symbol is the
template instance the dump names (aot.md §C1, "Calls" and "Islands"). Until then these
facts are as trusted as the certificate's ranges.
-/
import Std.Data.HashMap
import Ryo.Check.Lower.Cert
import Ryo.Check.Image.Common
import Ryo.Vm.Frame

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Obj Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm Ryo.Check.Image Std

/-- How a call's plan was verified. -/
inductive Verified
  | entry | abi | none
deriving DecidableEq, Repr, Inhabited

/-- The frame addresses a function takes (`checkAddrs`), by how each is covered. -/
structure AddrCount where
  addrs : Nat := 0
  /-- Inside an object escaped on every path. -/
  inside : Nat := 0
  /-- At the end of such an object. -/
  atEnd : Nat := 0
  /-- A zero-sized local. -/
  zeroSized : Nat := 0
  /-- Of `addrs`, the by-address call arguments. -/
  args : Nat := 0
deriving Inhabited

/-- The frame addresses instruction `i` takes: (slot, whether it is a by-address call
argument). An `addr`'s `s` (an inline one's operand: its items, a `lea`, show none), a call's or
tail call's `ARG_ADDR` entries, a handler's footprint `addrs`. -/
def addrsTaken (i : Insn) (mode : Ryo.Obj.Mode) : Except String (List (Int × Bool)) := do
  let (e, call) ← match i with
    | .native op ops =>
      pure (Frame.native op ops mode.pe, op.info.shape == .call || op.info.shape == .tailCall)
    | .handler h args _ => pure (← Frame.handler h args mode, false)
  pure (e.opnds.filterMap fun (o, a) => if a == .addr then some (o.toInt, call) else none)

/-- How `State.addrOf` covers slot `s` given the escaped objects `objs` (`[lo, hi)`) and the
zero-sized objects' offsets `zs`: inside an object (`0`), at an object's end (`1`), a zero-sized
object (`2`), in that order; `none` if not. -/
def coverOf (objs : List (Int × Int)) (zs : List Int) (s : Int) : Option Nat :=
  if objs.any (fun (lo, hi) => lo ≤ s && s < hi) then some 0
  else if objs.any (fun (lo, hi) => lo < hi && hi == s) then some 1
  else if zs.contains s then some 2
  else none

/-- The escape coverage of decoded function `d` whose zero-sized objects are at the offsets `zs`
(the module header): the counts and the errors (instruction, slot, why). -/
def checkAddrs (d : Decoded) (mode : Ryo.Obj.Mode) (zs : List Int) : AddrCount × Array String := Id.run do
  let (succ, pad) := Frame.flow d
  let edges := (succ.zip pad).map fun (s, p) => s ++ p
  let must := Frame.mustEscapedAt d edges
  let may := Frame.escapedAt d edges
  let (escapes, _) := Frame.escapeSteps d
  let objs (bits : Nat) : List (Int × Int) :=
    escapes.toList.filterMap fun (lo, hi, j) => if (bits >>> j) % 2 == 1 then some (lo, hi) else none
  let mut c : AddrCount := {}
  let mut errs : Array String := #[]
  for h : k in [0:d.insns.size] do
    match addrsTaken d.insns[k] mode with
    | .error e => errs := errs.push s!"instruction {k}: its addresses taken: {e}"
    | .ok ts =>
      for (s, arg) in ts do
        c := { c with addrs := c.addrs + 1, args := c.args + (if arg then 1 else 0) }
        let what := if arg then "by-address argument" else "addr"
        match coverOf (objs (must[k]?.getD 0)) zs s with
        | some 0 => c := { c with inside := c.inside + 1 }
        | some 1 => c := { c with atEnd := c.atEnd + 1 }
        | some _ => c := { c with zeroSized := c.zeroSized + 1 }
        | none =>
          let some_ := match coverOf (objs (may[k]?.getD 0)) [] s with
            | some 0 => " (inside an object escaped on some path only)"
            | some _ => " (at the end of an object escaped on some path only)"
            | none => ""
          errs := errs.push s!"{what} at {k}: slot {s} is neither in nor at the end of an object escaped on every path, nor a zero-sized local{some_}"
  return (c, errs)

/-- One function's check: its errors and what it established. -/
structure FuncCheck where
  errors : Array String := #[]
  /-- The own plan and return kind matched the dump's ABI. -/
  sigAbi : Bool := false
  blocks : Nat := 0
  truncated : Nat := 0
  /-- Per call instruction: its certificate and how its plan was verified. -/
  calls : Array (CallCert × Verified) := #[]
  /-- Per island instruction its template. -/
  islands : Array (Nat × String) := #[]
  /-- The escape coverage of the addresses taken (`checkAddrs`). -/
  addrs : AddrCount := {}

/-- The facts the dead-store check may assume of the function `r` checked (the module
header): stack-argument and sret sizes of the calls verified by the dump's ABI, the islands'
templates. Calls verified by the callee's `FuncEntry` get their stack-argument extent from
`DecodeObj.imageFacts` instead, which also checks that the callee's code stays within its
`arg_size` (check-image's bound alone doesn't cover access extents, escapes or tail calls),
and no sret size: nothing checks an sret callee's `ret_size` against its return type yet. -/
def Cert.facts (r : FuncCheck) : Frame.Facts :=
  let ok := r.calls.filter (·.2 == .abi)
  let stack : HashMap Nat Nat := ok.foldl (init := {}) fun m (c, _) =>
    match c.plan with
    | some p => m.insert c.insn p.stackSize
    | none => m
  let sret : HashMap Nat Nat := ok.foldl (init := {}) fun m (c, _) =>
    if c.retKind == RET_SRET && !c.kind.tail then m.insert c.insn c.retSize else m
  let isl : HashMap Nat String := r.islands.foldl (init := {}) fun m (k, t) => m.insert k t
  { stackArgs := fun k => stack[k]?, sretSize := fun k => sret[k]?, islandTemplate := fun k => isl[k]? }

/-- What the check reads besides the function. -/
structure Ctx where
  prog : Program
  o : ImageObject
  pe : Bool
  /-- Dumped instances by symbol. -/
  inst : HashMap String Instance
  /-- The object's certificates (`Cert.functionsOf`) by symbol (the first, if there are
  several). -/
  certs : HashMap String FuncCert
  islands : HashMap String String

/-- The certificate images of the image object `o`: those whose CGU name hashes to its
header's `cgu_hash` (exactly one, if the certificate is right). -/
def Cert.imagesOf (cert : Cert) (o : ImageObject) : Array CertImage :=
  cert.images.filter (cguHash ·.cgu == o.image.header.cguHash)

/-- The certificates of the functions of `o`: its (first) certificate image's. -/
def Cert.functionsOf (cert : Cert) (o : ImageObject) : Array (String × FuncCert) :=
  ((cert.imagesOf o)[0]?.map (·.functions)).getD #[]

def Ctx.make (prog : Program) (cert : Cert) (o : ImageObject) : Ctx :=
  { prog, o, pe := o.image.mode.pe,
    inst := prog.instances.foldl (init := {}) fun m i => m.insert i.symbol i,
    certs := (cert.functionsOf o).foldl (init := {}) fun m (s, c) => if m.contains s then m else m.insert s c,
    islands := cert.islands.foldl (init := {}) fun m (s, t) => m.insert s t }

/-- An operand of a native instruction by name. -/
def opnd (op : Reduced.Opcode) (ops : List (Opnd Nat)) (name : String) : Option (Opnd Nat) :=
  ((op.info.operands.zip ops).find? (·.1.name == name)).map (·.2)

def slotOf? : Option (Opnd Nat) → Option Int
  | some (.slot s) => some s.toInt
  | _ => none

def immOf? : Option (Opnd Nat) → Option Nat
  | some (.imm v) => some v.toNat
  | _ => none

/-- An integer argument register's size as a call passes it (`pass_args`: rounded up to a
power of two). -/
def roundPow2 (n : Nat) : Nat := if n ≤ 1 then 1 else if n ≤ 2 then 2 else if n ≤ 4 then 4 else 8

def gpr (i : Nat) : Nat := (ArgReg.mk false 8 i).word

/-- Where an argument-list entry's slot must be: anywhere (a non-tail call's sret
destination), a slot the certificate gives, or input `i`'s home plus `off`. -/
inductive SlotReq
  | any
  | fixed (s : Int)
  | home (i off : Nat)

/-- The argument list `pass_args` builds from `plan` (register words with slot requirements),
for a tail call (`tail`) or not, with the caller's certificate `fc` (its sret and incoming
`Indirect` pointer slots). -/
def passArgs (fc : FuncCert) (plan : ArgPlan) (sret tail : Bool) : Except String (List (SlotReq × Nat)) := do
  let mut out : List (SlotReq × Nat) := []
  if sret then
    if tail then
      let some p := fc.sret | throw "tail call of an sret callee from a function without an sret slot"
      out := out ++ [(.fixed p, gpr 0)]
    else out := out ++ [(.any, gpr 0 ||| argAddr)]
  for h : i in [0:plan.locs.length] do
    for l in plan.locs[i] do
      match l with
      | .reg r off =>
        out := out ++ [(.home i off, { r with size := if r.xmm then r.size else roundPow2 r.size }.word)]
      | .ptrReg idx =>
        if tail then
          let some (some p) := fc.argPtrs[i]? | throw s!"tail call passing input {i} indirectly, which the function didn't get so"
          out := out ++ [(.fixed p, gpr idx)]
        else out := out ++ [(.home i 0, gpr idx ||| argAddr)]
      | .stack .. | .ptrStack _ => pure ()
  return out

/-- Checks a call's argument-list words `ws` against `want`; an error message, or none. -/
def checkArgList (ws : List (BitVec 32)) (want : List (SlotReq × Nat)) : Option String := Id.run do
  let rec pairs : List (BitVec 32) → List (Int × Nat)
    | s :: r :: rest => (s.toInt, r.toNat) :: pairs rest
    | _ => []
  let got := pairs ws
  let show_ (g : List (Int × Nat)) := " ".intercalate (g.map fun (s, r) => s!"{s}:{r}")
  if ws.length % 2 != 0 || got.length != want.length then
    return some s!"argument list [{show_ got}] has {got.length} entries, the plan {want.length}"
  let mut homes : HashMap Nat Int := {}
  for ((s, r), (req, w)) in got.zip want do
    if r != w then return some s!"argument list [{show_ got}]: register word {r} where the plan has {w}"
    match req with
    | .any => pure ()
    | .fixed p => if s != p then return some s!"argument list [{show_ got}]: slot {s} where the certificate has {p}"
    | .home i off =>
      let base := s - off
      match homes[i]? with
      | some b => if b != base then return some s!"argument list [{show_ got}]: input {i}'s pieces at homes {b} and {base}"
      | none => homes := homes.insert i base
  return none

/-- The `arg` instructions `prologue` emits for the plan: (slot, register word). -/
def prologueArgs (fc : FuncCert) (plan : ArgPlan) : Except String (List (Int × Nat)) := do
  let mut out : List (Int × Nat) := fc.sret.toList.map (·, gpr 0)
  for h : i in [0:plan.locs.length] do
    for l in plan.locs[i] do
      match l with
      | .reg r off =>
        let some home := fc.argHomes[i]? | throw s!"no home for input {i}"
        out := out ++ [(home + off, r.word)]
      | .ptrReg idx =>
        let some (some p) := fc.argPtrs[i]? | throw s!"no pointer slot for the indirect input {i}"
        out := out ++ [(p, gpr idx)]
      | _ => pure ()
  return out

/-- The ABI the dump gives the callee of terminator `t`, if any. -/
def termAbi (prog : Program) : Terminator → Option FnAbiSummary
  | .call _ _ _ _ _ _ abi | .tailCall _ _ _ abi => abi
  | .drop _ (some g) _ _ => (prog.body? g).bind (·.abi)
  | .assert _ _ msg _ _ => (prog.body? msg.panicFn).bind (·.abi)
  | _ => none

/-- Whether the dumper truncated the block ending in `t`: a call of `ryo-dump: unsupported …`. -/
def truncated (prog : Program) : Terminator → Bool
  | .call (.inst i) .. => (prog.symbol i).startsWith "ryo-dump: unsupported"
  | _ => false

def kindFits (k : CallKind) (m : String) : Bool :=
  match k with
  | .vm | .dropVm => m == "call"
  | .tailVm => m == "tail_call"
  | .sym | .threadLocal => m == "call.sym" || m == "call.sym.ind"
  | .ptr | .virtualDrop => m == "call.ptr"
  | .tailPtr => m == "tail_call.ptr"

def rangeText (r : Range) : String := s!"[{r.1},{r.2})"

/-- Checks function `i`, decoded as `d`, against its certificate `fc` and the dump. -/
def checkFunc (c : Ctx) (i : Nat) (d : Decoded) (fc : FuncCert) : FuncCheck := Id.run do
  let o := c.o
  let fe := o.funcs[i]!
  let name := o.funcName fe.codeOff
  let mut r : FuncCheck := {}
  let err (r : FuncCheck) (s : String) : FuncCheck := { r with errors := r.errors.push s }
  let body : Option Body := match c.inst[name]? with
    | some ⟨_, .body b⟩ => some b
    | _ => none
  -- Own signature.
  let sret := fc.retKind == RET_SRET
  if fc.frameSize != d.frameSize then r := err r s!"frame size {fc.frameSize}, decoded {d.frameSize}"
  if fc.retKind != fe.retKind then r := err r s!"return kind {fc.retKind}, the entry's {fe.retKind}"
  if fc.sret.isSome != sret then r := err r s!"sret slot {fc.sret} with return kind {fc.retKind}"
  if fc.argSize != fe.argSize then r := err r s!"argument size {fc.argSize}, the entry's {fe.argSize}"
  let argInsns : Array (Nat × Int × Nat) := (Array.range d.insns.size).filterMap fun k =>
    match d.insns[k]! with
    | .native op ops =>
      if op.info.shape == .arg then
        some (k, (slotOf? (opnd op ops "d")).getD 0, (immOf? (opnd op ops "r")).getD 0)
      else none
    | _ => none
  for (k, _, _) in argInsns do
    unless fc.prologue.1 ≤ k && k < fc.prologue.2 do r := err r s!"`arg` at {k}, outside the prologue {rangeText fc.prologue}"
  match fc.plan with
  | none => r := err r "no plan"
  | some plan =>
    if plan.stackSize != fc.argSize then r := err r s!"plan stack size {plan.stackSize}, argument size {fc.argSize}"
    if plan.locs.length != fc.argHomes.size || plan.locs.length != fc.argPtrs.size then
      r := err r s!"{plan.locs.length} inputs, {fc.argHomes.size} homes, {fc.argPtrs.size} pointer slots"
    for h : j in [0:plan.locs.length] do
      let indirect := plan.locs[j].any (· matches .ptrReg _ | .ptrStack _)
      if (fc.argPtrs[j]?.bind id).isSome != indirect then r := err r s!"input {j}: pointer slot {fc.argPtrs[j]?.bind id}, indirect {indirect}"
    match prologueArgs fc plan with
    | .error e => r := err r e
    | .ok want =>
      let got := argInsns.toList.map (·.2)
      if got != want then
        r := err r s!"prologue `arg`s {got.map fun (s, w) => s!"{s}:{w}"}, the plan's {want.map fun (s, w) => s!"{s}:{w}"}"
    if let some b := body then
      if let some abi := b.abi then
        match sigOf c.pe abi with
        | .error e => r := err r s!"the dumped ABI has no plan: {e}"
        | .ok (k, p) =>
          if k != fc.retKind then r := err r s!"return kind {fc.retKind}, the dumped ABI's {k}"
          if p != plan then r := err r s!"plan {plan.text}, the dumped ABI's {p.text}"
          if abi.ret.size != fe.retSize then r := err r s!"the entry's return size {fe.retSize}, the dumped ABI's {abi.ret.size}"
          if k == fc.retKind && p == plan then r := { r with sigAbi := true }
  if let some b := body then
    if fc.locals.size != b.locals.size then r := err r s!"{fc.locals.size} locals, the body {b.locals.size}"
    if fc.spreadArg != b.spreadArg then r := err r s!"spread argument {fc.spreadArg}, the body's {b.spreadArg}"
    if fc.callerLocation.isSome != b.trackCaller then r := err r s!"caller location slot {fc.callerLocation}, track_caller {b.trackCaller}"
  -- Ranges.
  let ranges : Array (String × Range) :=
    #[("prologue", fc.prologue)]
    ++ (Array.range fc.blocks.size).flatMap (fun bi =>
      let blk := fc.blocks[bi]!
      (Array.range blk.stmts.size).map (fun si => (s!"bb{bi}[{si}]", blk.stmts[si]!)) |>.push (s!"bb{bi} term", blk.term))
    ++ (fc.stubs.map fun s => (s!"stub {s.reason}", s.insns))
    ++ (fc.pads.map fun p => ("pad", p.insns))
  let mut at_ := 0
  for (l, (lo, hi)) in ranges do
    if lo != at_ || hi < lo then
      r := err r s!"{l} {rangeText (lo, hi)} doesn't start at {at_}"
      break
    at_ := hi
  if at_ != d.insns.size then r := err r s!"the ranges end at {at_}, the code at {d.insns.size}"
  r := { r with blocks := fc.blocks.size }
  if let some b := body then
    if fc.blocks.size != b.blocks.size then r := err r s!"{fc.blocks.size} blocks, the body {b.blocks.size}"
    else
      for h : bi in [0:fc.blocks.size] do
        let blk := fc.blocks[bi]
        let db := b.blocks[bi]!
        if truncated c.prog db.term then
          r := { r with truncated := r.truncated + 1 }
        else if blk.stmts.size + (if blk.fused then 1 else 0) != db.stmts.length then
          r := err r s!"bb{bi}: {blk.stmts.size} statements{if blk.fused then " + a fused statement" else ""}, the body {db.stmts.length}"
  -- Calls.
  let mut certAt : HashMap Nat CallCert := {}
  for cc in fc.calls do
    if certAt.contains cc.insn then r := err r s!"two call entries for {cc.insn}"
    certAt := certAt.insert cc.insn cc
  -- The terminator (block) each instruction of a terminator range is in, and its call count.
  let mut termOf : HashMap Nat Nat := {}
  let mut termCalls : HashMap Nat Nat := {}
  for h : bi in [0:fc.blocks.size] do
    let (lo, hi) := fc.blocks[bi].term
    for k in [lo:hi] do
      termOf := termOf.insert k bi
      if certAt.contains k then termCalls := termCalls.insert bi (termCalls.getD bi 0 + 1)
  for h : k in [0:d.insns.size] do
    let .native op ops := d.insns[k] | continue
    if op.info.shape == .island then
      match opnd op ops "isl" with
      | some (.sym s) =>
        match o.slotName s with
        | .ok n => match c.islands[n]? with
          | some t => r := { r with islands := r.islands.push (k, t) }
          | none => r := err r s!"island at {k}: `{n}` is not in the certificate's islands"
        | .error e => r := err r s!"island at {k}: {e}"
      | _ => r := err r s!"island at {k} without a symbol"
      continue
    unless op.info.shape == .call || op.info.shape == .tailCall do continue
    let some cc := certAt[k]? | r := err r s!"{op.info.mnemonic} at {k} has no call entry"; continue
    let n0 := r.errors.size
    let m := op.info.mnemonic
    let csret := cc.retKind == RET_SRET
    if !kindFits cc.kind m then r := err r s!"call at {k}: kind {repr cc.kind} for `{m}`"
    if op.info.shape == .call then
      let kk := (immOf? (opnd op ops "k")).getD 0
      if kk != (if csret then 0 else cc.retKind) then r := err r s!"call at {k}: k {kk}, return kind {cc.retKind}"
    let some plan := cc.plan | r := err r s!"call at {k} without a plan"; continue
    match cc.kind with
    | .virtualDrop =>
      if plan != ⟨[[.reg ⟨false, 8, 0⟩ 0]], 0⟩ || cc.retKind != 0 then r := err r s!"call at {k}: virtual drop plan {plan.text}"
    | .threadLocal =>
      if plan != ⟨[], 0⟩ || cc.retKind != retKind [⟨false, 8, 0⟩] || cc.retSize != 8 then r := err r s!"call at {k}: thread-local shim plan {plan.text}"
    | _ => pure ()
    let ws := match opnd op ops "a" with
      | some (.words ws) => ws
      | _ => []
    match passArgs fc plan csret cc.kind.tail with
    | .error e => r := err r s!"call at {k}: {e}"
    | .ok want => if let some e := checkArgList ws want then r := err r s!"call at {k}: {e}"
    -- (i) The callee's entry.
    let mut byEntry := false
    if let some (.func j) := opnd op ops "f" then
      match o.funcs[j]? with
      | none => r := err r s!"call at {k}: no function {j}"
      | some ce =>
        let n1 := r.errors.size
        if ce.argSize != plan.stackSize then r := err r s!"call at {k}: plan stack size {plan.stackSize}, the callee's argument size {ce.argSize}"
        if ce.retKind != cc.retKind then r := err r s!"call at {k}: return kind {cc.retKind}, the callee's {ce.retKind}"
        if csret && ce.retSize != cc.retSize then r := err r s!"call at {k}: return size {cc.retSize}, the callee's {ce.retSize}"
        if let some cf := c.certs[o.funcName ce.codeOff]? then
          if cf.plan != some plan then r := err r s!"call at {k}: plan {plan.text}, the callee's own {(cf.plan.map (·.text)).getD "none"}"
        byEntry := r.errors.size == n1
    -- (ii) The dumped ABI of the terminator the call is alone in.
    let mut byAbi := false
    if let (some b, some bi) := (body, termOf[k]?) then
      if termCalls.getD bi 0 == 1 && fc.blocks.size == b.blocks.size then
        if let some abi := termAbi c.prog b.blocks[bi]!.term then
          match sigOf c.pe abi with
          | .error e => r := err r s!"call at {k}: the dumped ABI has no plan: {e}"
          | .ok (rk, p) =>
            let n1 := r.errors.size
            if rk != cc.retKind then r := err r s!"call at {k}: return kind {cc.retKind}, the dumped ABI's {rk}"
            if p != plan then r := err r s!"call at {k}: plan {plan.text}, the dumped ABI's {p.text}"
            if abi.ret.size != cc.retSize then r := err r s!"call at {k}: return size {cc.retSize}, the dumped ABI's {abi.ret.size}"
            byAbi := r.errors.size == n1
    let v := if r.errors.size != n0 then Verified.none else if byEntry then .entry else if byAbi then .abi else .none
    r := { r with calls := r.calls.push (cc, v) }
  -- Escape coverage.
  let (ac, aerrs) := checkAddrs d o.image.mode ((fc.locals.filter (·.size == 0)).toList.map (·.off))
  r := { r with addrs := ac, errors := r.errors ++ aerrs }
  for cc in fc.calls do
    match d.insns[cc.insn]? with
    | some (.native op _) => unless op.info.shape == .call || op.info.shape == .tailCall do r := err r s!"call entry {cc.insn} is `{op.info.mnemonic}`"
    | some _ => r := err r s!"call entry {cc.insn} is a handler call"
    | none => r := err r s!"call entry {cc.insn} past the code"
  return { r with errors := r.errors.map fun e => s!"{funcLabel o i}: {e}" }

/-- One object's report. -/
structure Report where
  funcs : Nat := 0
  certs : Nat := 0
  inDump : Nat := 0
  undecoded : Nat := 0
  sigAbi : Nat := 0
  blocks : Nat := 0
  truncated : Nat := 0
  calls : Nat := 0
  byEntry : Nat := 0
  byAbi : Nat := 0
  unverified : Nat := 0
  islands : Nat := 0
  addrs : AddrCount := {}
  dropped : Nat := 0
  notDead : Nat := 0
  /-- The dropped stores the facts-free check doesn't show dead (for comparison). -/
  notDeadPlain : Nat := 0
  errors : Array String := #[]
  deriving Inhabited

def Report.ok (r : Report) : Bool := r.errors.isEmpty

/-- The mismatch of the certificate image's function symbols `syms` against the object's
`names`, in image order (those both have: a function without a certificate or a certificate
without a function is reported on its own). -/
def orderError (cgu : String) (syms names : Array String) : Option String :=
  let inSyms : HashSet String := syms.foldl (·.insert ·) {}
  let inNames : HashSet String := names.foldl (·.insert ·) {}
  let got := syms.filter inNames.contains
  let want := names.filter inSyms.contains
  let bad := (List.range (min want.size got.size)).find? fun k => want[k]! != got[k]!
  bad.map fun k =>
    s!"certificate image `{cgu}`: its function {k} (of those the object defines) is `{got[k]!}`, the object's `{want[k]!}`"

/-- Checks the image object `o` against the dump `prog` and its certificate image in `cert`
(`Cert.imagesOf`). -/
def checkObject (prog : Program) (cert : Cert) (o : ImageObject) : Report := Id.run do
  let mut rep : Report := { funcs := o.funcs.size }
  let ims := cert.imagesOf o
  if ims.size != 1 then
    rep := { rep with errors := rep.errors.push s!"{ims.size} certificate images have the object's cgu_hash {hex16 o.image.header.cguHash}" }
  let cgu := (ims[0]?.map (·.cgu)).getD ""
  let fs := cert.functionsOf o
  let names := o.funcs.map (o.funcName ·.codeOff)
  if let some e := orderError cgu (fs.map (·.1)) names then rep := { rep with errors := rep.errors.push e }
  let c := Ctx.make prog cert o
  let count : HashMap String Nat := fs.foldl (init := {}) fun m (s, _) => m.insert s (m.getD s 0 + 1)
  let decs := decodeAll o
  let extents := Frame.incomingExtents (decs.map (·.decoded.toOption)) o.image.mode
  let inObj : HashSet String := names.foldl (·.insert ·) {}
  for (s, _) in fs do
    unless inObj.contains s do
      rep := { rep with errors := rep.errors.push s!"certificate of `{s}` (image `{cgu}`) has no image function" }
  for h : i in [0:o.funcs.size] do
    let name := o.funcName o.funcs[i].codeOff
    let n := count.getD name 0
    if n != 1 then
      rep := { rep with errors := rep.errors.push s!"{funcLabel o i}: {n} certificates" }
      if n == 0 then continue
    rep := { rep with certs := rep.certs + 1 }
    if c.inst[name]? matches some ⟨_, .body _⟩ then rep := { rep with inDump := rep.inDump + 1 }
    let some (Except.ok fi, Except.ok d) := decs[i]?.map fun x => (x.inputs, x.decoded)
      | rep := { rep with undecoded := rep.undecoded + 1, errors := rep.errors.push s!"{funcLabel o i}: not decoded" }
        continue
    let fr := checkFunc c i d c.certs[name]!
    let cnt (v : Verified) := (fr.calls.filter (·.2 == v)).size
    rep := { rep with
      errors := rep.errors ++ fr.errors, sigAbi := rep.sigAbi + (if fr.sigAbi then 1 else 0),
      blocks := rep.blocks + fr.blocks, truncated := rep.truncated + fr.truncated,
      calls := rep.calls + fr.calls.size, byEntry := rep.byEntry + cnt .entry,
      byAbi := rep.byAbi + cnt .abi, unverified := rep.unverified + cnt .none,
      islands := rep.islands + fr.islands.size,
      addrs := { addrs := rep.addrs.addrs + fr.addrs.addrs, inside := rep.addrs.inside + fr.addrs.inside,
                 atEnd := rep.addrs.atEnd + fr.addrs.atEnd, zeroSized := rep.addrs.zeroSized + fr.addrs.zeroSized,
                 args := rep.addrs.args + fr.addrs.args } }
    -- The dead-store check with the facts.
    if d.dropped.isEmpty then continue
    rep := { rep with dropped := rep.dropped + d.dropped.size }
    let bad (facts : Frame.Facts) : Nat := match Frame.droppedNotDead d fi.mode facts with
      | .ok ks => ks.length
      | .error _ => d.dropped.size
    let facts := (DecodeObj.imageFacts o extents d (c.islands[·]?)).merge (Cert.facts fr)
    rep := { rep with notDead := rep.notDead + bad facts, notDeadPlain := rep.notDeadPlain + bad {} }
  return rep

/-- For `ryo-lean dead` with a certificate: per function of `o` the facts its certificate
check gives (`Cert.facts`; none for a function without a certificate, not decoded, or whose
check fails), and the islands' templates by symbol. -/
def deadFacts (prog : Program) (cert : Cert) (o : ImageObject) :
    (Nat → Frame.Facts) × (String → Option String) :=
  let c := Ctx.make prog cert o
  let decs := decodeAll o
  let facts : Array Frame.Facts := (Array.range o.funcs.size).map fun i => Id.run do
    let some fc := c.certs[o.funcName o.funcs[i]!.codeOff]? | return {}
    let some (Except.ok d) := decs[i]?.map (·.decoded) | return {}
    let fr := checkFunc c i d fc
    return if fr.errors.isEmpty then Cert.facts fr else {}
  (fun i => facts[i]?.getD {}, (c.islands[·]?))

/-- The lines `ryo-lean check-cert` prints for one object: the summary, the dead-store totals,
then the errors. -/
def Report.render (r : Report) (path : String) : Array String :=
  #[s!"cert-check {path}: funcs {r.funcs} certs {r.certs} in-dump {r.inDump} undecoded {r.undecoded} sig-abi {r.sigAbi} blocks {r.blocks} truncated {r.truncated} calls {r.calls} by-entry {r.byEntry} by-abi {r.byAbi} unverified {r.unverified} islands {r.islands} addrs {r.addrs.addrs} by-escape {r.addrs.inside} at-end {r.addrs.atEnd} zero-sized {r.addrs.zeroSized} addr-args {r.addrs.args} errors {r.errors.size}",
    s!"dead-check {path}: dropped {r.dropped} not-shown-dead {r.notDead} (without facts {r.notDeadPlain})"]
    ++ r.errors.map ("error: " ++ ·)

/-- The certificate images no checked object has (the image map's other direction). -/
def unmatched (cert : Cert) (objs : Array ImageObject) : Array String :=
  let seen : HashSet Nat := objs.foldl (·.insert ·.image.header.cguHash) {}
  (cert.images.filter fun im => !seen.contains (cguHash im.cgu)).map fun im =>
    s!"certificate image `{im.cgu}` ({im.functions.size} functions) has no image object"

end Ryo.Check.Lower
