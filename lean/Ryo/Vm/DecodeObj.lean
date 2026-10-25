/-
Ryo.Vm.DecodeObj — `decodeReduced` on the functions of an image object (`ryo-lean decode <obj>`),
printed as `scripts/lean-decode-ref` prints Rust's decoding (`ImageResolver::decode`), for
`scripts/lean-decode-diff.py --decode`.

`Ryo.Obj.funcInputs` gathers each function's inputs from the object. In an image object calls
between the image's functions carry no relocation (the writer resolves them), so the function's
code is decoded as linked code (`Fields.linked`, Rust's `decode_linked`, which the reference
uses too): the code is placed at a made-up address, its relocated fields pointed at made-up
addresses of their references, one range per kind, and the `LinkMap` maps those back, and
function starts to `Ref.func`. The side data comes from the function's instruction list
(`Ryo.Obj.List`): its dropped stores and scopes. Rust's `decode_linked` also takes the list's
branch targets and instruction entries as an index, read in one pass and checked against the
code; the Lean decoder reads the code in two passes as `decode_reduced` does, without them,
which gives the same result on a list that passes Rust's checks.
-/
import Ryo.Vm.DecodeReduced
import Ryo.Vm.Frame
import Ryo.Obj

namespace Ryo.Vm.DecodeObj

open Ryo.X86 Ryo.Vm.R Ryo.Vm.Asm

/-- The made-up address map: the text at `text`, each kind of reference in a range below it. -/
def text : Nat := 0x4000_0000
def probe : Nat := 0x0f00_0000
def handlers : Nat := 0x1000_0000
def syms : Nat := 0x1100_0000
def sites : Nat := 0x1200_0000
def consts : Nat := 0x1400_0000
def datas : Nat := 0x1800_0000
def ros : Nat := 0x1c00_0000
def record : Nat := 0x3f00_0000
/-- The size of the ranges from `consts` on. -/
def span : Nat := 0x0400_0000

def toRef : Ryo.Obj.Ref → Ref
  | .handler op => .handler op.val.toNat
  | .probe => .probe
  | .func i => .func i
  | .sym i => .sym i
  | .site i => .site i
  | .const o => .const o
  | .data o => .data o
  | .ro o => .ro o
  | .record => .record
  | .recordLoopCtr => .recordLoopCtr

/-- The made-up address of a reference, if it fits its range. -/
def addrOf (funcStarts : Array Nat) : Ref → Option Nat
  | .handler op => some (handlers + 16 * op)
  | .probe => some probe
  | .func i => funcStarts[i]?.map (text + ·)
  | .sym s => if 8 * s < 0x0100_0000 then some (syms + 8 * s) else none
  | .site s => if 8 * s < 0x0200_0000 then some (sites + 8 * s) else none
  | .const k => if k < span then some (consts + k) else none
  | .data d => if d < span then some (datas + d) else none
  | .ro o => if o < span then some (ros + o) else none
  | .record => some record
  | .recordLoopCtr => some (record + loopCtr)

/-- The inverse of `addrOf`. -/
def resolve (funcStarts : Array Nat) (a : BitVec 64) : Option Ref :=
  let a := a.toNat
  let inRange (base len : Nat) : Option Nat := if base ≤ a && a < base + len then some (a - base) else none
  if a == probe then some .probe
  else if let some d := inRange handlers 0x0100_0000 then
    if d % 16 == 0 && d / 16 < Full.count then some (.handler (d / 16)) else none
  else if let some d := inRange syms 0x0100_0000 then
    if d % 8 == 0 then some (.sym (d / 8)) else none
  else if let some d := inRange sites 0x0200_0000 then
    if d % 8 == 0 then some (.site (d / 8)) else none
  else if let some d := inRange consts span then some (.const d)
  else if let some d := inRange datas span then some (.data d)
  else if let some d := inRange ros span then some (.ro d)
  else if a ≥ text then (funcStarts.findIdx? (· == a - text)).map .func
  else none

/-- Function `f`'s decoder inputs, its code linked at the made-up addresses: the arguments of
`decodeReducedWith` after the code; `none` for inputs the reference can't decode either (a
malformed instruction list). -/
def funcArgs (f : Ryo.Obj.FuncInputs) :
    Except String (Option (ByteArray × Fields × Array DroppedStore × Array Scope)) := do
  let addr := text + f.codeOff
  let mut code := f.code
  for r in f.relocs do
    let to := toRef r.to
    let some t := addrOf f.funcStarts to | throw s!"reference {repr to} past the made-up address map"
    let d := BitVec.ofInt 32 ((t : Int) - (addr + r.pos + 4 : Nat))
    for k in [0:4] do
      if r.pos + k < code.size then
        code := code.set! (r.pos + k) (UInt8.ofNat ((d.toNat >>> (8 * k)) % 256))
  let kind (k : Ryo.Obj.ScopeKind) : ScopeKind := match k with
    | .escape a => .escape a
    | .end => .end
    | .lend => .lend
  let scopes := f.scopes.map fun s => Scope.mk s.codeOffset (BitVec.ofInt 32 s.frameOffset) s.size (kind s.kind)
  let some dropped := f.dropped.mapM fun d => DroppedStore.ofParts? d.pos (BitVec.ofInt 32 d.frameOffset) d.size d.reg
    | return none
  let fields := Fields.linked (BitVec.ofNat 64 addr) (BitVec.ofNat 64 record) (resolve f.funcStarts)
  return some (code, fields, dropped, scopes)

/-- Function `f`'s decoding (`decodeReducedWith`, trusting the dropped stores as Rust does);
`none` as for `funcArgs`. -/
def decodeFunc (f : Ryo.Obj.FuncInputs) : Except String (Option (Except AsmError Decoded)) := do
  let some (code, fields, dropped, scopes) ← funcArgs f | return none
  return some (decodeReducedWith code fields f.rodata f.callSites dropped scopes f.mode)

/-- Function `f`'s checked decoding (`Frame.decodeChecked`, given `facts`); `none` as for
`funcArgs`. -/
def decodeFuncChecked (f : Ryo.Obj.FuncInputs) (facts : Frame.Facts := {}) :
    Except String (Option (Except String Decoded)) := do
  let some (code, fields, dropped, scopes) ← funcArgs f | return none
  return some (Frame.decodeChecked code fields f.rodata f.callSites dropped scopes f.mode facts)

/-- Each function of the image decoded (`decodeFunc`), `none` where it isn't. -/
def decodeAll (o : Ryo.Obj.ImageObject) : Array (Option (Ryo.Obj.FuncInputs × Decoded)) :=
  (Array.range o.funcs.size).map fun i => do
    let fi ← (o.funcInputs i).toOption
    let .ok (some (.ok d)) := decodeFunc fi | none
    pure (fi, d)

/-- What the image itself says of decoded function `d`'s calls of image functions
(`call` of `Ref.func g`), for the dead-store check (`Frame.Facts`):

- `stackArgs`: `g`'s `arg_size`, if `g`'s own code accesses its incoming area only within
  it, tail calls included (`extents`, from `Frame.incomingExtents`). The callee's stack
  arguments are that area: what the call reads of the caller's frame besides the argument
  list is in its first `arg_size` bytes.
- no `sretSize`: an sret callee's `ret_size` isn't checked against its return type by any
  image check (C1''s to do), and making more bytes `Uninit` than L0's destination has would be
  unsound. The certificate check gives it for calls whose ABI the dump has.
- `islandTemplate`: an island's template by its symbol slot's name, as `islands` maps it
  (the C1' certificate's islands; none by default). -/
def imageFacts (o : Ryo.Obj.ImageObject) (extents : Array (Option Nat)) (d : Decoded)
    (islands : String → Option String := fun _ => none) : Frame.Facts :=
  let callee (k : Nat) : Option (Nat × Ryo.Obj.FuncEntry) := match d.insns[k]? with
    | some (.native op (_ :: .func g :: _)) =>
      if op.info.mnemonic == "call" then (o.funcs[g]?).map (g, ·) else none
    | _ => none
  { stackArgs := fun k => do
      let (g, c) ← callee k
      let b ← extents[g]?.join
      if b ≤ c.argSize then some c.argSize else none
    islandTemplate := fun k => match d.insns[k]? with
      | some (.native op (.sym s :: _)) =>
        if op.info.shape == .island then (o.slotName s).toOption.bind islands else none
      | _ => none }

/-- One function's lines, as `lean-decode-ref decode` prints them. -/
def funcLines (d : Decoded) : Array String := Id.run do
  let wpos := d.wordPos
  let mut out := #[s!"  frame {d.frameSize}"]
  for h : k in [0:d.insns.size] do
    out := out.push s!"  {pad6 wpos[k]!}: {insnText wpos k d.insns[k]}"
  for e in d.cleanupEntries do
    out := out.push (if e.target == continueTarget then s!"  cleanup {e.offset} -> continue"
      else if e.target &&& catchBit != 0 then s!"  cleanup {e.offset} -> {e.target &&& (catchBit - 1)} catch"
      else s!"  cleanup {e.offset} -> {e.target}")
  for (i, sc) in d.scopes do
    out := out.push s!"  scope {wpos[i]!} {signed32 sc.frameOffset} {sc.size} {sc.kind.text}"
  for i in d.dropped do out := out.push s!"  dropped {wpos[i]!}"
  for i in d.heads do out := out.push s!"  head {wpos[i]!}"
  return out

/-- `ryo-lean decode <obj>`'s lines: each function of the image object, decoded. -/
def objLines (o : Ryo.Obj.ImageObject) : Array String := Id.run do
  let mut out : Array String := #[]
  for h : i in [0:o.funcs.size] do
    let f := o.funcs[i]
    out := out.push s!"func {i} {o.funcName f.codeOff}"
    match o.funcInputs i with
    | .error e =>
      out := out.push (if (e.splitOn "malformed instruction list").length > 1 then "  error: malformed instruction list"
        else s!"  error: {e}")
    | .ok fi =>
      match decodeFunc fi with
      | .error e => out := out.push s!"  error: {e}"
      | .ok none => out := out.push "  error: malformed instruction list"
      | .ok (some (.error e)) => out := out.push s!"  error: {e.what} at {e.at_}"
      | .ok (some (.ok d)) => out := out ++ funcLines d
  return out

/-- `ryo-lean dead <obj>`'s lines: per function with dropped stores that the checked decoding
(`Frame.decodeChecked`) rejects, its verdict, the stores `Frame.droppedNotDead` doesn't show
dead, and the function's text; then the totals. The check is given the image's facts
(`imageFacts`, with the island templates `islands` maps symbol names to) merged with
`extra i` for function `i` (facts checked elsewhere, e.g. against the C1' certificate). -/
def deadLines (o : Ryo.Obj.ImageObject) (extra : Nat → Frame.Facts := fun _ => {})
    (islands : String → Option String := fun _ => none) : Array String := Id.run do
  let mut out : Array String := #[]
  let mut total := 0
  let mut bad := 0
  let decoded := decodeAll o
  let extents := Frame.incomingExtents (decoded.map (·.map (·.2))) o.image.mode
  for h : i in [0:o.funcs.size] do
    let f := o.funcs[i]
    let some (fi, d) := decoded[i]! | continue
    if d.dropped.isEmpty then continue
    total := total + d.dropped.size
    let facts := (imageFacts o extents d islands).merge (extra i)
    let .ok (some r) := decodeFuncChecked fi facts | continue
    let .error e := r | continue
    let wpos := d.wordPos
    match Frame.droppedNotDead d fi.mode facts with
    | .ok ks =>
      bad := bad + ks.length
      let why := ks.map fun k => match Frame.firstReader d fi.mode k facts with
        | .ok (some (j, by_)) => s!"{wpos[k]!} read at {wpos[j]!}" ++ match by_ with
          | .operand => ""
          | .pointer => " through a pointer"
          | .stack => " (stack arguments)"
          | .everything => " (reads everything)"
        | _ => s!"{wpos[k]!}"
      out := out.push s!"func {i} {o.funcName f.codeOff}: {e}: {", ".intercalate why}"
    | .error _ =>
      bad := bad + d.dropped.size
      out := out.push s!"func {i} {o.funcName f.codeOff}: {e}"
    out := out ++ funcLines d
  out := out.push s!"total dropped {total}, not shown dead {bad}"
  return out

end Ryo.Vm.DecodeObj
