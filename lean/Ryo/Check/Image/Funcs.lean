/-
Ryo.Check.Image.Funcs — the function table and the function symbols of an image object
(aot.md §C4, "Function symbols and the function table"), checked against the object and the
decoded code:

- **The table and the text.** `Image.validate`'s checks; each entry's code is 16-aligned
  (the writer's layout), non-empty, after the previous one's end and inside the text, and the
  text is the functions' code and the `int3` padding between them (fewer than 16 bytes) and
  nothing else, so `(code_off, code_len)` covers exactly the code the decoder reads. The
  decoder rejects code it can't read to the end (`decodeReduced` reads the `code_len` bytes
  exactly: trailing bytes are "code after the counter stubs" or not an instruction), so a
  successful decode is the "decoded length = `code_len`" check. The inter-function padding is
  never a decoded branch target: a `rel32` field the decoder reads as a branch lies inside the
  function, and one leaving it must be a function's first byte (`Fields.linked`, `Ref.func`),
  or the decode fails.
- **Side-table runs.** Each function's scope, call-site and dropped-store runs lie inside
  their tables (`Image.validate`) and follow each other in function order, covering the whole
  table, so every entry belongs to the function the decoder was given it for. The decoder
  uses every call site (`call site outside every call`), dropped store and scope it is given.
- **Symbols.** Each `STT_FUNC` symbol (global or local) of the text is at an entry's
  `code_off` with `st_size = code_len`, each entry has exactly one, and the text has no other
  symbols but its section symbol. Whether the name is the dump's `tcx.symbol_name` of the
  instance needs the dump (C1'): not checked here.
- **Signature fields** (`FuncEntry` docs, `asm::RET_SRET`), as far as the code alone decides:
  every `ret` loads the return kind `ret_kind` says (`load_kind`: integer parts widened to
  1/2/4/8 bytes; an sret function returns the pointer as one 8-byte part, from the slot its
  `arg` of the first integer register stored); a valid register kind's parts fit in
  `ret_size`, which is at most 16 (0 for kind 0); a call of an image function collects the
  callee's `ret_kind` (0 for sret); a tail call's callee has the caller's `ret_kind` and at
  most its `arg_size` (the callee's stack arguments go over the caller's incoming ones);
  `arg_size` is a multiple of 16 and every
  frame access in the incoming argument area (from `fp + 16` on) starts inside its
  `arg_size` bytes (frame accesses as `Ryo.Vm.Frame.effects` gives them). That `arg_size` is
  the `ArgPlan`'s stack size and `ret_kind` its return kind needs the dump's signature (C1'):
  not checked here.
-/
import Ryo.Check.Image.Common
import Ryo.Vm.Frame

namespace Ryo.Check.Image

open Ryo.Obj Ryo.Vm Ryo.Vm.R

/-! ## The table, the text and the side-table runs -/

def checkTable (o : ImageObject) : Array String := Id.run do
  let h := o.image.header
  let mut out : Array String := #[]
  match o.image.validate with
  | .ok () => pure ()
  | .error e => out := out.push s!"Image::validate: {e}"
  let tb := o.textBytes
  let mut prevEnd := 0
  for hi : i in [0:o.funcs.size] do
    let f := o.funcs[i]
    let l := funcLabel o i
    if f.codeOff % 16 != 0 then out := out.push s!"{l}: code_off {f.codeOff} isn't 16-aligned"
    if f.codeLen == 0 then out := out.push s!"{l}: code_len 0"
    if f.codeOff < prevEnd then
      out := out.push s!"{l}: code_off {f.codeOff} overlaps the previous function (ends at {prevEnd})"
    else
      let gap := f.codeOff - prevEnd
      if gap ≥ 16 then out := out.push s!"{l}: {gap} bytes before it in the text that no function covers"
      if !allBytes tb prevEnd gap 0xcc then
        out := out.push s!"{l}: the padding [{prevEnd}, {f.codeOff}) before it isn't int3s"
    if f.codeOff + f.codeLen > h.textSize then
      out := out.push s!"{l}: [{f.codeOff}, {f.codeOff + f.codeLen}) past the text's {h.textSize} bytes"
    prevEnd := max prevEnd (f.codeOff + f.codeLen)
  if prevEnd < h.textSize then
    out := out.push s!"text: [{prevEnd}, {h.textSize}) after the last function"
  if o.text.size != o.textBase + h.textSize then
    out := out.push s!"text: section `{o.text.name}` has {o.text.size} bytes, the image's text ends at {o.textBase + h.textSize}"
  -- The runs, in function order, covering each table.
  let runs : List (String × (FuncEntry → Span) × Span) :=
    [("scope", (·.scopes), h.scopes), ("call-site", (·.callSites), h.callSites),
     ("dropped-store", (·.dropped), h.dropped)]
  for (what, get, table) in runs do
    let mut next := 0
    for hi : i in [0:o.funcs.size] do
      let s := get o.funcs[i]
      if s.off != next then
        out := out.push s!"{funcLabel o i}: {what} run {s} doesn't follow the previous function's (at {next})"
      if s.off + s.count > table.count then
        out := out.push s!"{funcLabel o i}: {what} run {s} past the table's {table.count} entries"
      next := s.off + s.count
    if next != table.count then
      out := out.push s!"{what} table: {table.count} entries, the functions' runs end at {next}"
  return out

/-! ## Symbols -/

def checkSymbols (o : ImageObject) : Array String := Id.run do
  let mut out : Array String := #[]
  let byOff : Std.HashMap Nat Nat :=
    (Array.range o.funcs.size).foldl (fun m i => m.insert o.funcs[i]!.codeOff i) {}
  let mut count := Array.replicate o.funcs.size 0
  for s in o.elf.symbols do
    if s.shndx != o.text.index || s.index == 0 then continue
    if s.type == Elf.STT_SECTION then continue
    if s.type != Elf.STT_FUNC then
      out := out.push s!"symbol `{s.name}` of type {s.type} in the text"
      continue
    let some i := (if s.value ≥ o.textBase then byOff[s.value - o.textBase]? else none)
      | out := out.push s!"symbol `{s.name}` at text offset {s.value} isn't at a function's code_off"
    count := count.modify i (· + 1)
    let f := o.funcs[i]!
    if s.size != f.codeLen then
      out := out.push s!"symbol `{s.name}` (func {i}): st_size {s.size}, code_len {f.codeLen}"
  for i in [0:o.funcs.size] do
    if count[i]! == 0 then out := out.push s!"func {i} at {o.funcs[i]!.codeOff}: no function symbol"
    else if count[i]! > 1 then out := out.push s!"{funcLabel o i}: {count[i]!} function symbols"
  return out

/-! ## Signature fields against the code -/

/-- `load_kind` (`lower/call.rs`): a return kind with its integer parts widened to the load
width `ret` uses; `none` for an invalid kind. -/
def loadKind (k : Nat) : Option Nat := do
  let (a, b) ← Asm.retParts k false
  let widen (p : Asm.RetPart) : Asm.RetPart :=
    if p.xmm then p else { p with size := if p.size ≤ 1 then 1 else if p.size ≤ 2 then 2 else if p.size ≤ 4 then 4 else 8 }
  pure (Asm.retKind ([a, b].filterMap id |>.map widen))

/-- The kind `ret` loads in a function of return kind `k` (`FunctionLowering::ret`). -/
def retLoadKind (k : Nat) : Option Nat :=
  if k == 0 then some 0 else if k == RET_SRET then some 8 else loadKind k

/-- The kind a call of a function of return kind `k` collects (sret: 0, the address being an
argument). -/
def callKind (k : Nat) : Nat := if k == RET_SRET then 0 else k

private def immOf : Opnd Nat → Option Nat
  | .imm v => some v.toNat
  | _ => none

def checkSignature (o : ImageObject) (i : Nat) (d : Decoded) : Array String := Id.run do
  let f := o.funcs[i]!
  let l := funcLabel o i
  let mut out : Array String := #[]
  let retK := retLoadKind f.retKind
  if retK.isNone then out := out.push s!"{l}: ret_kind {hex f.retKind} isn't a return kind"
  if f.retKind != 0 && f.retKind != RET_SRET then
    if let some (a, b) := Asm.retParts f.retKind false then
      let hi := ([a, b].filterMap id).foldl (fun x p => max x (p.off + p.size)) 0
      if hi > f.retSize then
        out := out.push s!"{l}: ret_kind {hex f.retKind}'s parts end at {hi}, past ret_size {f.retSize}"
  if f.retKind == 0 && f.retSize != 0 then
    out := out.push s!"{l}: ret_kind 0 (nothing returned) with ret_size {f.retSize}"
  if f.retKind != 0 && f.retKind != RET_SRET && f.retSize > 16 then
    out := out.push s!"{l}: ret_kind {hex f.retKind} returns in registers, ret_size {f.retSize} > 16"
  if f.argSize % 16 != 0 then out := out.push s!"{l}: arg_size {f.argSize} isn't a multiple of 16"
  -- The slots the first integer argument register is stored to (an sret function's pointer).
  let argSlots := d.insns.toList.filterMap fun
    | .native op [.slot s, .imm w] => if op.info.mnemonic == "arg" && w.toNat == 8 then some s else none
    | _ => none
  let mode := o.image.mode
  for h : k in [0:d.insns.size] do
    let insn := d.insns[k]
    match insn with
    | .native op ops =>
      let m := op.info.mnemonic
      if m == "ret" then
        match ops with
        | [.slot s, .imm kv] =>
          if let some want := retK then
            if kv.toNat != want then
              out := out.push s!"{l}: insn {k}: ret of kind {hex kv.toNat}, ret_kind {hex f.retKind} loads {hex want}"
          if f.retKind == RET_SRET && !argSlots.contains s then
            out := out.push s!"{l}: insn {k}: sret ret from slot {s.toInt}, which no arg of the first integer register stores"
        | _ => out := out.push s!"{l}: insn {k}: ret operands"
      else if m == "call" then
        match ops with
        | [_, .func g, kv, _] =>
          match o.funcs[g]?, immOf kv with
          | some callee, some kn =>
            if kn != callKind callee.retKind then
              out := out.push s!"{l}: insn {k}: call of func {g} collects kind {hex kn}, its ret_kind is {hex callee.retKind}"
          | _, _ => out := out.push s!"{l}: insn {k}: call of func {g} (no such function)"
        | _ => out := out.push s!"{l}: insn {k}: call operands"
      else if m == "tail_call" then
        match ops with
        | [.func g, _] =>
          match o.funcs[g]? with
          | some callee =>
            if callee.retKind != f.retKind then
              out := out.push s!"{l}: insn {k}: tail call of func {g} of ret_kind {hex callee.retKind}, own {hex f.retKind}"
            if callee.argSize > f.argSize then
              out := out.push s!"{l}: insn {k}: tail call of func {g} with arg_size {callee.argSize} > own {f.argSize}"
          | none => out := out.push s!"{l}: insn {k}: tail call of func {g} (no such function)"
        | _ => out := out.push s!"{l}: insn {k}: tail_call operands"
    | .handler .. => pure ()
    -- Accesses of the incoming argument area.
    match Frame.effects insn (d.items[k]?.getD []) mode (Frame.lendsAt d k) with
    | .error e => out := out.push s!"{l}: insn {k}: frame effects: {e}"
    | .ok e =>
      for (off, _) in e.opnds do
        let v := off.toInt
        if v ≥ 16 && v ≥ 16 + f.argSize then
          out := out.push s!"{l}: insn {k}: frame access at fp + {v}, past the incoming area of arg_size {f.argSize}"
  return out

/-- The function-table and symbol checks, the decoding of each function (a failure is a
mismatch), and the signature fields of each decoded one. -/
def checkFuncs (o : ImageObject) (ds : Array FuncDecoding) : Array String := Id.run do
  let mut out := checkTable o ++ checkSymbols o
  for h : i in [0:ds.size] do
    match ds[i].decoded with
    | .ok d => out := out ++ checkSignature o i d
    | .error e => out := out.push s!"{funcLabel o i}: decode: {e}"
  return out

end Ryo.Check.Image
