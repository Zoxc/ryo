/-
Ryo.X86.Item — the canonical machine-code elements of ryo's AOT code (x86.md §B.1, §B.2).

Mirrors `vm/bytecode/src/asm/x86.rs` (`Reg`, `Cond`, `W`, `M`, `Rm`, `Alu`, `Sh`, `Item`) and
`asm/encode.rs` (`Ref`, `Reloc`), constructor for constructor. Rust's fixed-width integers are
`BitVec`s of the same width (wrapping arithmetic as in Rust), except small enumerations (`Nop`'s
length, `Sse`'s size and the `xmm` numbers), which are `Nat`s constrained by `Item.wf`.

`Item.wf` says which items the encoder can emit: exactly those whose encoding decodes back to
them (`decodeItem (encode i) = some i`, tested in `RyoTest/X86.lean`). Rust states the same
constraints as `debug_assert`s and as the checks of its decoder.
-/
import Lean.Data.Json

set_option linter.constructorNameAsVariable false

namespace Ryo.X86

open Lean

instance (n : Nat) : ToJson (BitVec n) := ⟨fun b => toJson b.toNat⟩
/-- JSON: a number, negative ones taken modulo `2 ^ n` (so signed displacements read naturally). -/
instance (n : Nat) : FromJson (BitVec n) := ⟨fun j => do
  let i : Int ← fromJson? j
  if i < -(2 ^ n : Int) ∨ i ≥ 2 ^ n then throw s!"{i} out of range for BitVec {n}"
  pure (BitVec.ofInt n i)⟩

instance : ToJson UInt8 := ⟨fun b => toJson b.toNat⟩
instance : FromJson UInt8 := ⟨fun j => do
  let n : Nat ← fromJson? j
  if n < 256 then pure (UInt8.ofNat n) else throw s!"byte out of range: {n}"⟩

/-- The general-purpose registers the encoder uses (`x86.rs` `Reg`), by their x86 number. -/
inductive Reg
  | rax | rcx | rdx | rsp | rbp | rsi | rdi | r8 | r9 | r10 | r11
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson, Hashable

namespace Reg

def num : Reg → Nat
  | rax => 0 | rcx => 1 | rdx => 2 | rsp => 4 | rbp => 5 | rsi => 6 | rdi => 7
  | r8 => 8 | r9 => 9 | r10 => 10 | r11 => 11

/-- `Reg::from_num`. -/
def ofNum? : Nat → Option Reg
  | 0 => some rax | 1 => some rcx | 2 => some rdx | 4 => some rsp | 5 => some rbp
  | 6 => some rsi | 7 => some rdi | 8 => some r8 | 9 => some r9 | 10 => some r10
  | 11 => some r11 | _ => none

/-- The low three bits (the ModRM/opcode field). -/
def low (r : Reg) : Nat := r.num % 8
/-- Needs a REX extension bit (`r8`–`r11`). -/
def ext (r : Reg) : Bool := r.num ≥ 8

/-- Usable as a native item's register operand: not `rsp` or `rbp` (`x86.rs` `usable`). -/
def usable (r : Reg) : Bool := r != rsp && r != rbp

def all : List Reg := [rax, rcx, rdx, rsp, rbp, rsi, rdi, r8, r9, r10, r11]

theorem ofNum_num (r : Reg) : ofNum? r.num = some r := by cases r <;> rfl

end Reg

/-- The handler argument registers, in order (`sysv64`; `x86.rs` `ARGS`). -/
def argRegs : List Reg := [.rdi, .rsi, .rdx, .rcx, .r8, .r9]

/-- A branch condition (`x86.rs` `Cond`). -/
inductive Cond
  | always | z | nz | l | ge | le | g | b | ae | be | a | s | ns | o | no
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace Cond

/-- The x86 condition code (`jcc rel8` is `0x70 | cc`); `always` has none. -/
def cc? : Cond → Option Nat
  | always => none
  | b => some 0x2 | ae => some 0x3 | z => some 0x4 | nz => some 0x5 | be => some 0x6
  | a => some 0x7 | s => some 0x8 | ns => some 0x9 | l => some 0xc | ge => some 0xd
  | le => some 0xe | g => some 0xf | o => some 0x0 | no => some 0x1

def cc (c : Cond) : Nat := c.cc?.getD 0

def ofCc? : Nat → Option Cond
  | 0x0 => some o | 0x1 => some no | 0x2 => some b | 0x3 => some ae | 0x4 => some z | 0x5 => some nz | 0x6 => some be
  | 0x7 => some a | 0x8 => some s | 0x9 => some ns | 0xc => some l | 0xd => some ge
  | 0xe => some le | 0xf => some g | _ => none

/-- The opposite condition (`Cond::not`; `always` stays). -/
def not (c : Cond) : Cond := match c.cc? with
  | some n => (ofCc? (n ^^^ 1)).getD c
  | none => c

def all : List Cond := [always, z, nz, l, ge, le, g, b, ae, be, a, s, ns, o, no]

end Cond

/-- The operand size of a native instruction (`x86.rs` `W`). -/
inductive W
  | b | w | d | q
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace W

def bits : W → Nat
  | b => 8 | w => 16 | d => 32 | q => 64

/-- The length of a full-width immediate field (`Q`: 32 bits, sign-extended). -/
def immLen : W → Nat
  | b => 1 | w => 2 | d => 4 | q => 4

def all : List W := [b, w, d, q]

end W

/-- A memory operand `[base + disp]` (`x86.rs` `M`). -/
structure M where
  base : Reg
  disp : BitVec 32
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

def M.frame (disp : BitVec 32) : M := ⟨.rbp, disp⟩

/-- A register or memory operand (ModRM `r/m`). -/
inductive Rm
  | reg (r : Reg)
  | mem (m : M)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- The integer ALU operations, by their x86 `/digit`. -/
inductive Alu
  | add | or | and | sub | xor | cmp
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

def Alu.num : Alu → Nat
  | add => 0 | or => 1 | and => 4 | sub => 5 | xor => 6 | cmp => 7

def Alu.ofNum? : Nat → Option Alu
  | 0 => some .add | 1 => some .or | 4 => some .and | 5 => some .sub | 6 => some .xor
  | 7 => some .cmp | _ => none

def Alu.all : List Alu := [.add, .or, .and, .sub, .xor, .cmp]

/-- The shifts by an immediate, by their x86 `/digit`. -/
inductive Sh
  | shl | shr | sar
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

def Sh.num : Sh → Nat
  | shl => 4 | shr => 5 | sar => 7

def Sh.ofNum? : Nat → Option Sh
  | 4 => some .shl | 5 => some .shr | 7 => some .sar | _ => none

/-- What a relocated 4-byte field refers to (`encode.rs` `Ref`). Every field is PC-relative:
once linked, it holds `target - (field + 4)`. Indices are the Rust newtypes' `u32`s; a
handler is its opcode's number. -/
inductive Ref
  | handler (op : Nat)
  | probe
  | func (f : Nat)
  | sym (s : Nat)
  | site (s : Nat)
  | const (k : Nat)
  | data (d : Nat)
  | ro (off : Nat)
  /-- The function's own JIT record (its call counter is at its start). -/
  | record
  /-- The loop counter of the function's JIT record (`image::JitRecord::ctr_l`), `loopCtr`
  bytes into it. -/
  | recordLoopCtr
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson, Hashable

/-- The offset of a JIT record's loop counter (`x86::LOOP_CTR`, `image::JIT_LOOP_CTR`), which
`Ref.recordLoopCtr` names: a linked field that reaches the record plus this is that reference. -/
def loopCtr : Nat := 56

/-- A relocated field: the 4 bytes at `pos` (`encode.rs` `Reloc`, whose field is `at`). -/
structure Reloc where
  pos : Nat
  to : Ref
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- A machine-code element (`x86.rs` `Item`). Positions are byte offsets in the function. -/
inductive Item
  /-- `push rbp` -/
  | pushRbp
  /-- `push rbp; push rdi; push rsi; lea rbp, [rsp + 16]` (PE) -/
  | winPrologue
  /-- `lea rsp, [rbp - 16]; pop rsi; pop rdi; pop rbp` (PE) -/
  | winEpilogue
  /-- `sub rsp, imm` (`imm8` below 128, else `imm32`) -/
  | subRsp (v : BitVec 32)
  /-- `add rsp, imm` -/
  | addRsp (v : BitVec 32)
  /-- `reg = value`: the shortest of `xor r32, r32`, `mov r32, imm32`, `mov r64, simm32`,
  `mov r64, imm64`. -/
  | setReg (r : Reg) (v : BitVec 64)
  /-- `lea reg, [rip + disp32]`, the field relocated against `to`. -/
  | lea (r : Reg) (to : Ref)
  /-- `lea rcx, [rip + disp32]` of a jump table in the function, at this position. -/
  | leaTable (t : BitVec 32)
  /-- `mov dst, src` (64 bits). -/
  | mov (dst src : Reg)
  /-- `call rel32` -/
  | call (to : Ref)
  /-- `call [rip + disp32]` -/
  | callMem (to : Ref)
  /-- `call rax` -/
  | callRax
  /-- `inc qword [rip + disp32]`: one of the JIT record's counters counts up, the call counter
  at the record's start (the field relocated against `Ref.record`), or with `loop` the loop
  counter (`Ref.recordLoopCtr`). -/
  | ctrInc («loop» : Bool)
  /-- `call [r11 + disp8]` -/
  | callR11 (d : BitVec 8)
  /-- `mov dst, [rip + disp32]`: a symbol slot's value (any register, REX.R for `r8`–`r11`). -/
  | loadRip (dst : Reg) (to : Ref)
  /-- `call [rax]` -/
  | callMemRax
  /-- `jmp rax` -/
  | jmpRax
  /-- `jmp rel32` to another function (a tail call). -/
  | jmp (to : Ref)
  /-- A jump within the function: `jmp` or `jcc`, `rel8` or (`long`) `rel32`. -/
  | branch (cond : Cond) (target : BitVec 32) (long : Bool)
  /-- `test al, al` -/
  | testAl
  /-- `test rax, rax` -/
  | testRax
  | leave
  | ret
  | ud2
  /-- `movsxd rax, [rcx + rax*4]` -/
  | loadTableEntry
  /-- `add rax, rcx` -/
  | addRaxRcx
  /-- A padding `nop` of 1 to 9 bytes. -/
  | nop (n : Nat)
  | int3
  /-- A jump table entry: the offset of `target` from the table start `base`. -/
  | tableEntry (base target : BitVec 32)
  /-- `mov dst, [m]` (32 or 64 bits), or for `B`/`W` `movzx` (`sx`: `movsx`) `dst32, [m]`. -/
  | ld (w : W) (sx : Bool) (dst : Reg) (m : M)
  /-- `mov [m], src` at width `w`. -/
  | st (w : W) (src : Reg) (m : M)
  /-- `mov [m], imm` at width `w` (`Q`: a sign-extended `imm32`); `imm` sign-extended. -/
  | stImm (w : W) (m : M) (imm : BitVec 32)
  /-- `lea dst, [m]` (64 bits). -/
  | leaM (dst : Reg) (m : M)
  /-- `op reg, r/m` at width `w`. -/
  | alu (op : Alu) (w : W) (reg : Reg) (rm : Rm)
  /-- `op r/m, imm` at width `w`: `imm8` where it fits, else the full width (`B`: `imm8`). -/
  | aluImm (op : Alu) (w : W) (rm : Rm) (imm : BitVec 32)
  /-- `imul reg, r/m` (`D` or `Q`). -/
  | imul (w : W) (reg : Reg) (rm : Rm)
  /-- `imul reg, r/m, imm` (`D` or `Q`; `imm8` where it fits, else `imm32`). -/
  | imulImm (w : W) (reg : Reg) (rm : Rm) (imm : BitVec 32)
  /-- `shl`/`shr`/`sar reg, imm8` (`D` or `Q`). -/
  | shift (op : Sh) (w : W) (reg : Reg) (amt : BitVec 8)
  /-- `setcc byte [m]` -/
  | setcc (cond : Cond) (m : M)
  /-- `test byte [m], 0xff` -/
  | testM8 (m : M)
  /-- `setcc cl`: an overflow flag, before its store from `cl`. -/
  | setccCl (cond : Cond)
  /-- `mul r/m64`: `rdx:rax = rax * r/m`. -/
  | mulQ (rm : Rm)
  /-- An SSE load (`st` false) or store of `xmm{x}` at `[m]`: `movss` (4 bytes), `movsd` (8),
  `movups` (16). -/
  | sse (st : Bool) (size : Nat) (x : Nat) (m : M)
  /-- `movd xmm{x}, r32` (`toXmm`), or `movd r32, xmm{x}`. -/
  | movd (toXmm : Bool) (x : Nat) (r : Reg)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- Whether the signed value of `v` fits a sign-extended `n`-bit field. -/
def fitsSigned {w : Nat} (n : Nat) (v : BitVec w) : Bool :=
  (BitVec.signExtend w (v.setWidth n)) == v

/-- `x86.rs` `imm8`. -/
def imm8 (v : BitVec 32) : Bool := fitsSigned 8 v

namespace Item

/-- The item's memory operand (`Item::mem`). -/
def mem? : Item → Option M
  | ld _ _ _ m | st _ _ m | stImm _ m _ | leaM _ m | setcc _ m | sse _ _ _ m | testM8 m => some m
  | alu _ _ _ (.mem m) | aluImm _ _ (.mem m) _ | imul _ _ (.mem m) | imulImm _ _ (.mem m) _
  | mulQ (.mem m) => some m
  | _ => none

/-- The item with its memory operand mapped by `f` (`Item::map_mem`). -/
def mapMem (f : M → M) : Item → Item
  | ld w sx d m => ld w sx d (f m)
  | st w s m => st w s (f m)
  | stImm w m i => stImm w (f m) i
  | leaM d m => leaM d (f m)
  | alu o w r (.mem m) => alu o w r (.mem (f m))
  | aluImm o w (.mem m) i => aluImm o w (.mem (f m)) i
  | imul w r (.mem m) => imul w r (.mem (f m))
  | imulImm w r (.mem m) i => imulImm w r (.mem (f m)) i
  | mulQ (.mem m) => mulQ (.mem (f m))
  | setcc c m => setcc c (f m)
  | testM8 m => testM8 (f m)
  | sse s z x m => sse s z x (f m)
  | it => it

/-- The item's frame operand `[rbp + d]` as `[rsp + F + d]` (`Item::sp_frame`). -/
def spFrame (frameSize : BitVec 32) : Item → Item :=
  mapMem fun m => if m.base == .rbp then ⟨.rsp, m.disp + frameSize⟩ else m

/-- Whether the item is an element `decodeItem` reads (not padding, `int3` or a table entry). -/
def isElement : Item → Bool
  | nop _ | int3 | tableEntry _ _ => false
  | _ => true

/-- A memory operand of a native item, in the encoder's (frame-pointer) form. -/
def memWf (m : M) : Bool := m.base != .rsp

/-- A register-or-memory operand of a native item. -/
def rmWf : Rm → Bool
  | .reg r => r.usable
  | .mem m => memWf m

/-- The items the encoder emits at position `pos`, in its frame-pointer form (frame slots off
`rbp`): exactly those that decode back to themselves. -/
def wf (pos : BitVec 32) : Item → Bool
  | branch _ target false => fitsSigned 8 (target - (pos + 2))
  | nop n => 1 ≤ n && n ≤ 9
  | ld w sx dst m => dst.usable && memWf m && (w == .b || w == .w || !sx)
  | st _ src m => src.usable && memWf m
  | stImm w m imm => memWf m && (match w with
      | .b => fitsSigned 8 imm | .w => fitsSigned 16 imm | _ => true)
  | leaM dst m => dst.usable && memWf m
  | alu _ _ reg rm => reg.usable && rmWf rm
  | aluImm _ w rm imm => rmWf rm && (match w with
      | .b => fitsSigned 8 imm | .w => fitsSigned 16 imm | _ => true)
  | imul w reg rm | imulImm w reg rm _ => (w == .d || w == .q) && reg.usable && rmWf rm
  | shift _ w reg _ => (w == .d || w == .q) && reg.usable
  | setcc c m => c != .always && memWf m
  | testM8 m => memWf m
  | setccCl c => c != .always
  | mulQ rm => rmWf rm
  | sse _ size x m => (size == 4 || size == 8 || size == 16) && x < 8 && m.base == .rbp
  | movd _ x r => x < 8 && r.usable
  | _ => true

end Item

end Ryo.X86
