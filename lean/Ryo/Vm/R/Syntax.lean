/-
Ryo.Vm.R.Syntax — the syntax of the reduced VM level R (reduced.md §C0.1), as the decoder
gives it.

Mirrors `vm/bytecode/src/isa/reduced.rs` (`Arg`, the reduced `Insn`), `asm/reduce.rs` (`Then`,
`Insn`: native instructions of the full set's reduced subset, and `handler h args then`),
`asm/encode.rs` (`Opnd`, `Scope`), `asm/list.rs` (`ScopeKind`) and `asm/decode.rs`
(`Decoded`); `CallSite` (`asm/lsda.rs`) is `Ryo.Vm.Asm.CallSite`:

- a native instruction is a reduced opcode (`Generated/Reduced`) with its operands by kind;
- `handler h args then` calls the handler of the full opcode `h` with the argument registers
  `args` from `rdi` on, then the control flow of `h`'s shape (`Then`);
- targets are instruction indices.

`Decoded.words` gives Rust's instruction words (`reduced::words`: word offsets, targets
relative to their instruction), and `Decoded.toText` prints a decoded function exactly as
`vm/bytecode/tests/lean_reduced_vectors.rs` prints Rust's `Decoded` (`reduced::Disasm` for the
code, then the side data), so the two can be diffed.
-/
import Ryo.Vm.Generated
import Ryo.X86.Item

namespace Ryo.Vm.R

open Ryo.X86

/-- A handler argument register's value (`reduced::Arg`). Indices are the Rust newtypes'
`u32`s. -/
inductive Arg
  | fp
  /-- The exception object of a landing pad (`rax`). -/
  | exception
  | imm (v : BitVec 64)
  /-- The address of a constant. -/
  | const (k : Nat)
  /-- The address in the data area. -/
  | data (d : Nat)
  /-- The address of a symbol slot. -/
  | sym (s : Nat)
  /-- The address of the code constant at this offset of the function's rodata. -/
  | ro (off : Nat)
deriving DecidableEq, Repr, Inhabited

/-- An instruction operand by kind (`asm::Opnd`), targets `T`. Slots and memory operands are
the `i32`s of Rust, as 32-bit vectors. -/
inductive Opnd (T : Type)
  | slot (s : BitVec 32)
  | mem (p k : BitVec 32)
  /-- `U8` … `U64`, `I64`. -/
  | imm (v : BitVec 64)
  | imm128 (v : BitVec 128)
  | const (k : Nat)
  | data (d : Nat)
  | sym (s : Nat)
  | func (f : Nat)
  | target (t : T)
  | neg (b : Bool)
  | targets (ts : List T)
  | words (ws : List (BitVec 32))
  /-- Values and targets. -/
  | cases (vals : List (BitVec 128)) (ts : List T)
deriving DecidableEq, Repr, Inhabited

namespace Opnd

/-- `Opnd::map_targets`. -/
def mapTargets {T U ε : Type} (f : T → Except ε U) : Opnd T → Except ε (Opnd U)
  | slot s => pure (slot s)
  | mem p k => pure (mem p k)
  | imm v => pure (imm v)
  | imm128 v => pure (imm128 v)
  | const k => pure (const k)
  | data d => pure (data d)
  | sym s => pure (sym s)
  | func x => pure (func x)
  | target t => target <$> f t
  | neg n => pure (neg n)
  | targets ts => targets <$> ts.mapM f
  | words w => pure (words w)
  | cases v ts => cases v <$> ts.mapM f

/-- The branch targets of an operand (`op_targets`). -/
def targetsOf {T : Type} : Opnd T → List T
  | target t => [t]
  | targets ts | cases _ ts => ts
  | _ => []

end Opnd

/-- What follows a handler call: its shape's control flow (`asm::reduce::Then`). -/
inductive Then (T : Type)
  /-- The next instruction (`op`, `lpad`). -/
  | next
  /-- A branch on the returned `bool`, taken when it is true, or with `neg` when false. -/
  | branch (neg : Bool) (target : T)
  /-- A jump through the table on the returned index, the default last (`switch`). -/
  | table (ts : List T)
  /-- The handler doesn't return (`trap`). -/
  | trap
deriving DecidableEq, Repr, Inhabited

namespace Then

def mapM {T U : Type} {m : Type → Type} [Monad m] (f : T → m U) : Then T → m (Then U)
  | next => pure next
  | branch n t => branch n <$> f t
  | table ts => table <$> ts.mapM f
  | trap => pure trap

def targets {T : Type} : Then T → List T
  | branch _ t => [t]
  | table ts => ts
  | _ => []

end Then

/-- A reduced instruction (`asm::reduce::Insn`), targets instruction indices: a native one
(an opcode of the reduced set other than `handler`), or a handler call. -/
inductive Insn
  | native (op : Reduced.Opcode) (ops : List (Opnd Nat))
  | handler (h : Full.Opcode) (args : List Arg) (then_ : Then Nat)
deriving DecidableEq, Repr, Inhabited

/-- How a scope changes which frame bytes pointers reach (`asm::ScopeKind`). -/
inductive ScopeKind
  | escape (align : Nat)
  | «end»
  /-- An island operand's extent: the next instruction, an island, takes the object as an
  operand (reads and writes it during the call; not an escape). -/
  | lend
deriving DecidableEq, Repr, Inhabited

/-- An escape, a storage end or an island operand (`asm::Scope`): `codeOffset` a byte offset in machine code, or a
word offset in decoded code; `frameOffset` the signed offset from `fp`. -/
structure Scope where
  codeOffset : Nat
  frameOffset : BitVec 32
  size : Nat
  kind : ScopeKind
deriving DecidableEq, Repr, Inhabited

/-- `image::CONTINUE` and `image::CATCH`. -/
def continueTarget : Nat := 0xffff_ffff
def catchBit : Nat := 0x8000_0000

/-- A cleanup entry (`image::CleanupEntry`): word offsets, `target` `CONTINUE` or a landing
pad's offset with `CATCH` for a catch. -/
structure CleanupEntry where
  offset : Nat
  target : Nat
deriving DecidableEq, Repr, Inhabited

/-- A function decoded from machine code (`asm::Decoded`), its instructions in R form: targets,
landing pads, scope positions, dropped stores and loop heads by instruction index. -/
structure Decoded where
  insns : Array Insn
  frameSize : Nat
  /-- (instruction, landing pad or `none` to continue, catch), by instruction. -/
  cleanup : Array (Nat × Option Nat × Bool)
  /-- Each before the instruction of this index (the count for the end), in order. -/
  scopes : Array (Nat × Scope)
  /-- The inline instructions whose store the encoder dropped. -/
  dropped : Array Nat
  /-- The loop heads (targets of branches at or after them), in order. -/
  heads : Array Nat
  /-- The machine items of each inline instruction as the code has them (after the register
  cache, without a dropped store), empty for the others: what the L2 code reads and writes
  of the frame, which the dead-store check needs. Not part of Rust's `Decoded`. -/
  items : Array (List Ryo.X86.Item) := #[]
deriving Repr, Inhabited

/-! ### Words (`reduced::words`) -/

def u32 (n : Nat) : Nat := n % 2 ^ 32

/-- The instruction-word length of an operand of kind `k` (`word_len`). -/
def opndWords (k : OperandKind) (o : Opnd Nat) : Nat :=
  match k, o with
  | .list e, .targets t => 1 + t.length * e.words
  | .list e, .words t => 1 + t.length * e.words
  | .list e, .cases _ t => 1 + t.length * e.words
  | k, _ => k.words.getD 0

def Insn.wordLen : Insn → Nat
  | .native op ops => 1 + ((op.info.operands.zip ops).map fun (i, o) => opndWords i.kind o).sum
  | .handler _ args t =>
    let n := match t with
      | .branch .. => 1
      | .table ts => ts.length
      | _ => 0
    5 + 3 * args.length + n

/-- The word offset of each instruction, and the end. -/
def Decoded.wordPos (d : Decoded) : Array Nat :=
  d.insns.foldl (fun acc i => acc.push (acc.back!.add i.wordLen)) #[0]

def Arg.words : Arg → List Nat
  | .fp => [0, 0, 0]
  | .exception => [1, 0, 0]
  | .imm v => [2, v.toNat % 2 ^ 32, v.toNat / 2 ^ 32]
  | .const k => [3, u32 k, 0]
  | .data d => [4, u32 d, 0]
  | .sym s => [5, u32 s, 0]
  | .ro o => [6, u32 o, 0]

/-- An operand's words (`push_words`), its targets already relative. -/
def opndToWords (k : OperandKind) : Opnd Nat → List Nat
  | .slot s => [s.toNat]
  | .mem a b => [a.toNat, b.toNat]
  | .imm v => match k with
    | .u64 | .i64 => [v.toNat % 2 ^ 32, v.toNat / 2 ^ 32]
    | _ => [v.toNat % 2 ^ 32]
  | .imm128 v => (List.range 4).map fun j => v.toNat / 2 ^ (32 * j) % 2 ^ 32
  | .const x | .sym x | .func x => [u32 x]
  | .data d => [u32 d ||| 0x8000_0000]
  | .target t => [u32 t]
  | .neg n => [if n then 1 else 0]
  | .targets ts => ts.length :: ts.map u32
  | .words ws => ws.length :: ws.map (·.toNat)
  | .cases vals ts =>
    let e := match k with | .list e => e | _ => .case8
    ts.length :: ((vals.zip ts).flatMap fun (v, t) =>
      (List.range (e.words - 1)).map (fun j => v.toNat / 2 ^ (32 * j) % 2 ^ 32) ++ [u32 t])

/-- `t` relative to the instruction at word `at` (wrapping, as Rust's `u32`s). -/
def rel (wpos : Array Nat) (at_ t : Nat) : Nat := u32 (wpos[t]! + 2 ^ 32 - wpos[at_]!)

/-- The reduced instruction words (`reduced::words`). -/
def Decoded.words (d : Decoded) : Array Nat := Id.run do
  let wpos := d.wordPos
  let mut out : Array Nat := #[]
  for h : k in [0:d.insns.size] do
    match d.insns[k] with
    | .native op ops =>
      let ops := ops.map fun o => match o.mapTargets (ε := Unit) (fun t => .ok (rel wpos k t)) with
        | .ok o => o
        | .error _ => o
      out := out.push op.val.toNat
      for (i, o) in op.info.operands.zip ops do
        out := out ++ (opndToWords i.kind o).toArray
    | .handler h args t =>
      let (neg, ts) := match t with
        | .branch n x => (n, [x])
        | .table ts => (false, ts)
        | _ => (false, [])
      out := out.push (Reduced.Opcode.ofMnemonic? "handler").get!.val.toNat
      out := out.push h.val.toNat
      out := out.push args.length
      for a in args do out := out ++ a.words.toArray
      out := out.push (if neg then 1 else 0)
      out := out.push ts.length
      for x in ts do out := out.push (rel wpos k x)
  return out

/-- The cleanup entries at word offsets (`Decoded::cleanup`). -/
def Decoded.cleanupEntries (d : Decoded) : Array CleanupEntry :=
  let wpos := d.wordPos
  d.cleanup.map fun (i, pad, isCatch) =>
    { offset := wpos[i]!,
      target := match pad with
        | none => continueTarget
        | some p => wpos[p]! ||| (if isCatch then catchBit else 0) }

/-! ### Text (`reduced::Disasm` and the side data) -/

def hexNat (n : Nat) : String := String.ofList (Nat.toDigits 16 n)

def signed32 (v : BitVec 32) : String := toString v.toInt

/-- `full::Slot`'s display. -/
def slotText (s : BitVec 32) : String := "$" ++ signed32 s

/-- `full::Target`'s display (`@{:+}` of the relative `i32`). -/
def targetText (t : Nat) : String :=
  let i := (BitVec.ofNat 32 t).toInt
  if i ≥ 0 then s!"@+{i}" else s!"@{i}"

def Arg.text : Arg → String
  | .fp => "fp"
  | .exception => "exc"
  | .imm v => "0x" ++ hexNat v.toNat
  | .const k => s!"k{k}"
  | .data d => s!"data{d}"
  | .sym s => s!"sym{s}"
  | .ro o => s!"ro{o}"

def listText (xs : List String) : String := "[" ++ ", ".intercalate xs ++ "]"

/-- A listed operand's display (`Insn`'s `Display`), targets relative words. -/
def opndText (k : OperandKind) : Opnd Nat → String
  | .slot s => slotText s
  | .mem p x => if x.toInt < 0 then s!"[{slotText p} - {(-x.toInt).toNat}]"
    else s!"[{slotText p} + {x.toNat}]"
  | .imm v => match k with
    | .i64 => toString v.toInt
    | .u64 => toString v.toNat
    | _ => toString (v.toNat % 2 ^ 32)
  | .imm128 v => toString v.toNat
  | .const x => s!"k{x}"
  | .data x => s!"data{x}"
  | .sym x => s!"sym{x}"
  | .func x => s!"fn{x}"
  | .target t => targetText t
  | .neg _ => ""
  | .targets ts => listText (ts.map targetText)
  | .words ws => listText (ws.map fun w => toString w.toNat)
  | .cases vals ts => listText ((vals.zip ts).map fun (v, t) => s!"{v.toNat} => {targetText t}")

/-- One instruction's disassembly, at instruction index `k`. -/
def insnText (wpos : Array Nat) (k : Nat) : Insn → String
  | .native op ops =>
    let ops := ops.map fun o => match o.mapTargets (ε := Unit) (fun t => .ok (rel wpos k t)) with
      | .ok o => o
      | .error _ => o
    let pairs := op.info.operands.zip ops
    let suffix := String.join (pairs.map fun (_, o) => match o with
      | .neg true => "!"
      | _ => "")
    let listed := pairs.filterMap fun (i, o) => match i.kind with
      | .neg => none
      | k => some (opndText k o)
    op.mnemonic ++ suffix ++ (if listed.isEmpty then "" else " " ++ ", ".intercalate listed)
  | .handler h args t =>
    let (neg, ts) := match t with
      | .branch n x => (n, [x])
      | .table ts => (false, ts)
      | _ => (false, [])
    s!"handler{if neg then "!" else ""} {h.mnemonic}, {listText (args.map Arg.text)}, " ++
      listText (ts.map fun x => targetText (rel wpos k x))

/-- `{at:6}`: right-aligned in 6 columns. -/
def pad6 (n : Nat) : String :=
  let s := toString n
  String.ofList (List.replicate (6 - s.length) ' ') ++ s

def ScopeKind.text : ScopeKind → String
  | .escape a => s!"escape {a}"
  | .end => "end"
  | .lend => "lend"

def natList (xs : List Nat) : String := listText (xs.map toString)

/-- The text of a decoded function: the frame size, the code as `reduced::Disasm` prints it,
the cleanup entries, scopes, dropped stores and loop heads (word offsets). -/
def Decoded.toText (d : Decoded) : String := Id.run do
  let wpos := d.wordPos
  let mut s := s!"frame {d.frameSize}\n"
  for h : k in [0:d.insns.size] do
    s := s ++ s!"{pad6 wpos[k]!}: {insnText wpos k d.insns[k]}\n"
  for e in d.cleanupEntries do
    if e.target == continueTarget then
      s := s ++ s!"cleanup {e.offset} continue\n"
    else
      let c := if e.target &&& catchBit != 0 then " catch" else ""
      s := s ++ s!"cleanup {e.offset} -> {e.target &&& (catchBit - 1)}{c}\n"
  for (i, sc) in d.scopes do
    s := s ++ s!"scope {wpos[i]!} {signed32 sc.frameOffset} {sc.size} {sc.kind.text}\n"
  s := s ++ s!"dropped {natList (d.dropped.toList.map fun i => wpos[i]!)}\n"
  s := s ++ s!"heads {natList (d.heads.toList.map fun i => wpos[i]!)}\n"
  return s

end Ryo.Vm.R
