/-
# What a function's code refers to: the decoder's inputs (aot.md §C2, §C3)

Mirrors of the Rust types `asm::decode_reduced(code, relocs, rodata, call_sites, dropped,
scopes, mode)` takes (`vm/bytecode/src/asm/encode.rs`, `asm/mod.rs`): `Mode`, `Ref`, `Reloc`,
`CallSite`, `Scope`, `DroppedStore`, and `FuncInputs`, one function's inputs as
`Ryo.Obj.Image` gathers them from an image object.

**Function references.** In an image object, the writer resolves calls between the image's
functions itself (`ImageWriter::finish_encoded`): their `rel32` fields hold the displacement
and carry no relocation, so there is no `Ref.func` relocation to read. `FuncInputs.field`
classifies a field the way the decoder must: a relocated field is its `Ref`; an unrelocated
one whose target lies inside the function, past its first byte, is a branch within it
(`Fields::Relocs`' `Field::Local`); one to a function's first byte (in particular the
function's own, which is never a branch target) is `Ref.func` of that function (as
`Fields::Linked` resolves it); anything else is bad.

**Code constants.** `Ref.ro o` and `rodata` are the whole image's code constants
(`Header::code_consts`), not the function's own part: the image doesn't record where each
function's part starts. This is the convention of the linked decoder
(`ImageResolver::code_consts`), so `Arg::Ro` offsets in decoded code are image offsets.
-/
import Ryo.Vm.Generated

namespace Ryo.Obj

open Ryo.Vm

/-- `asm::Mode`: how the machine code was generated (`Header::mode`'s bits, `MODE_*`). -/
structure Mode where
  fpArg : Bool
  framePointer : Bool
  alignLoops : Bool
  pe : Bool
  counters : Bool
  deriving Repr, DecidableEq, Inhabited

def MODE_FP_ARG : Nat := 1
def MODE_FRAME_POINTER : Nat := 2
def MODE_ALIGN_LOOPS : Nat := 4
def MODE_PE : Nat := 8
def MODE_COUNTERS : Nat := 16

/-- `Image::mode_of`. -/
def Mode.ofBits (m : Nat) : Mode :=
  { fpArg := m &&& MODE_FP_ARG != 0, framePointer := m &&& MODE_FRAME_POINTER != 0,
    alignLoops := m &&& MODE_ALIGN_LOOPS != 0, pe := m &&& MODE_PE != 0,
    counters := m &&& MODE_COUNTERS != 0 }

/-- `Mode::valid`: the combinations the encoder supports. -/
def Mode.valid (m : Mode) : Bool := m.framePointer || (m.fpArg && !m.pe)

instance : ToString Mode where
  toString m :=
    let b (x : Bool) := if x then "1" else "0"
    s!"fp_arg={b m.fpArg} frame_pointer={b m.framePointer} align_loops={b m.alignLoops} pe={b m.pe} counters={b m.counters}"

/-- `asm::Ref`: what a relocated 4-byte field of the code refers to. Every field is
PC-relative: once linked, it holds `target - (field + 4)`. Indices are those of `full::Func`,
`Sym`, `Site`, `Const` (pool byte offset) and `Data` (fixup-area byte offset). -/
inductive Ref where
  /-- The handler `ryo_h_<op>`. -/
  | handler (op : Full.Opcode)
  /-- `ryo_probe_stack`. -/
  | probe
  /-- A function of the image (call and tail-call targets). Never a relocation in an image
  object: see the module comment. -/
  | func (i : Nat)
  /-- A symbol slot. -/
  | sym (i : Nat)
  /-- A site cache slot. -/
  | site (i : Nat)
  /-- A constant pool offset. -/
  | const (off : Nat)
  /-- A data (fixup) area offset. -/
  | data (off : Nat)
  /-- A code-constant offset (see the module comment for its base). -/
  | ro (off : Nat)
  /-- The function's own JIT record. -/
  | record
  /-- The counter of the function's JIT record, from the field of `sub qword [rip + x],
  imm8`, which the immediate follows: the target is the record's address less one. -/
  | recordCtr
  deriving Repr, DecidableEq, Inhabited

/-- The stable text form shared with the Rust reference printer
(`scripts/lean-decode-ref`): `handler <Name>`, `probe`, `func <i>`, `sym <i>`, `site <i>`,
`const <off>`, `data <off>`, `ro <off>`, `rec`, `recctr`. -/
def Ref.render : Ref → String
  | .handler op => s!"handler {op.info.name}"
  | .probe => "probe"
  | .func i => s!"func {i}"
  | .sym i => s!"sym {i}"
  | .site i => s!"site {i}"
  | .const o => s!"const {o}"
  | .data o => s!"data {o}"
  | .ro o => s!"ro {o}"
  | .record => "rec"
  | .recordCtr => "recctr"

instance : ToString Ref := ⟨Ref.render⟩

/-- `asm::Reloc`: the relocated field of 4 bytes at `pos` (a byte offset in the function). -/
structure Reloc where
  pos : Nat
  to : Ref
  deriving Repr, DecidableEq, Inhabited

/-- `asm::CallSite`: a call that may unwind, with its landing pad (`none`: unwinding
continues in the caller), and whether the pad catches. -/
structure CallSite where
  start : Nat
  len : Nat
  pad : Option Nat
  catches : Bool
  deriving Repr, DecidableEq, Inhabited

/-- `asm::ScopeKind`. -/
inductive ScopeKind where
  | escape (align : Nat)
  | «end»
  | lend
  deriving Repr, DecidableEq, Inhabited

/-- `asm::Scope`: where a frame object escapes, its storage ends, or an island takes it as an
operand. -/
structure Scope where
  codeOffset : Nat
  frameOffset : Int
  size : Nat
  kind : ScopeKind
  deriving Repr, DecidableEq, Inhabited

/-- `asm::DroppedStore` by its parts (`DroppedStore::from_parts`): the store
`mov [fp + frameOffset], reg` of `size` bytes the encoder dropped at `pos`. `reg` is an x86
register number of the inline sequences' pool (`rax`, `rdx`, `rsi`, `rdi`, `r8`–`r11`). -/
structure DroppedStore where
  pos : Nat
  frameOffset : Int
  size : Nat
  reg : Nat
  deriving Repr, DecidableEq, Inhabited

/-- `DroppedStore::from_parts`' check: a size of 1, 2, 4 or 8 and a pool register. -/
def DroppedStore.valid (d : DroppedStore) : Bool :=
  [1, 2, 4, 8].contains d.size && [0, 2, 6, 7, 8, 9, 10, 11].contains d.reg

/-- A `rel32` field as the decoder sees it (`asm::x86::Field`). -/
inductive Field where
  /-- A branch within the function: the target's byte offset. -/
  | «local» (target : Nat)
  | ref (r : Ref)
  | bad
  deriving Repr, DecidableEq, Inhabited

/-- One VM function's decoder inputs, read from the image object. -/
structure FuncInputs where
  /-- The function's index in the image (`full::Func`). -/
  index : Nat
  name : String
  /-- Byte offset of the code in the text section (`FuncEntry::code_off`). -/
  codeOff : Nat
  code : ByteArray
  /-- The relocated fields of the code, sorted by position (no `Ref.func`: see the module
  comment). -/
  relocs : Array Reloc
  /-- The image's code constants. -/
  rodata : ByteArray
  callSites : Array CallSite
  dropped : Array DroppedStore
  scopes : Array Scope
  mode : Mode
  /-- Every function's `code_off`, in function order (sorted): for `Ref.func`. -/
  funcStarts : Array Nat

/-- The relocation of the field at byte `pos` of the function, if any. -/
def FuncInputs.relocAt? (f : FuncInputs) (pos : Nat) : Option Reloc :=
  -- Binary search over the sorted relocations.
  let rec go (lo hi : Nat) (fuel : Nat) : Option Reloc :=
    match fuel with
    | 0 => none
    | fuel + 1 =>
      if lo < hi then
        let mid := (lo + hi) / 2
        let r := f.relocs[mid]!
        if r.pos == pos then some r
        else if r.pos < pos then go (mid + 1) hi fuel
        else go lo mid fuel
      else none
  go 0 f.relocs.size (f.relocs.size + 1)

/-- The function whose code starts at text offset `off`. -/
def FuncInputs.funcAt? (f : FuncInputs) (off : Nat) : Option Nat :=
  let rec go (lo hi : Nat) (fuel : Nat) : Option Nat :=
    match fuel with
    | 0 => none
    | fuel + 1 =>
      if lo < hi then
        let mid := (lo + hi) / 2
        let s := f.funcStarts[mid]!
        if s == off then some mid
        else if s < off then go (mid + 1) hi fuel
        else go lo mid fuel
      else none
  go 0 f.funcStarts.size (f.funcStarts.size + 1)

/-- The `rel32` field `off` bytes into an item of length `len` at byte `pos` of the
function, holding the displacement `d`: what it refers to (see the module comment). -/
def FuncInputs.field (f : FuncInputs) (pos off len : Nat) (d : Int) : Field :=
  match f.relocAt? (pos + off) with
  | some r => .ref r.to
  | none =>
    let t : Int := (pos + len : Nat) + d
    if 0 < t && t < f.code.size then .local t.toNat
    else
      let abs : Int := (f.codeOff : Int) + t
      if abs < 0 then .bad
      else match f.funcAt? abs.toNat with
        | some i => .ref (.func i)
        | none => .bad

end Ryo.Obj
