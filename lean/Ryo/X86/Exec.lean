/-
Ryo.X86.Exec — `Item.exec`: one item's effect on the machine state, per the Intel SDM
(x86.md §B.2).

`Item.exec ctx i s` runs `i` with `s.rip` at its first byte. `ctx` says where the code is: the
function's address (`branch` and `leaTable` targets are positions in it) and where each `Ref`
lives once linked (`RefAddr`, as in `link`). Calls and returns are plain: `call` pushes the
return address at `rsp` and jumps, `ret` pops it, whatever the target is (the environment that
gives meaning to calls out of the function is `Ryo/X86/Env.lean`, later).

Flags (SDM Vol. 2, per instruction; `none` = undefined, see `Ryo.X86.State`):
- `add`/`sub`/`cmp`: `CF` (carry/borrow), `OF` (signed overflow), `SF`, `ZF` from the result.
- `and`/`or`/`xor`/`test`: `CF = OF = 0`, `SF`, `ZF` from the result.
- `imul` (two and three operands): `CF = OF =` "the truncated product differs from the full
  one"; `SF`, `ZF` undefined.
- `shl`/`shr`/`sar` by an immediate: the count masked to 5 bits (6 for 64-bit operands). A
  masked count of 0 changes no flag (but a 32-bit operand still zero-extends: the write
  happens). Otherwise `CF` is the last bit shifted out, `SF`/`ZF` from the result, and `OF` is
  defined only for a count of 1 (`shl`: `MSB(result) xor CF`, `shr`: the operand's `MSB`,
  `sar`: 0), undefined for larger counts.
- `xor r32, r32` (`setReg r 0`) sets `ZF` and clears `CF OF SF`; the `mov` forms of `setReg`
  leave the flags alone. `sub rsp`/`add rsp` (`subRsp`/`addRsp`) set them as `sub`/`add`
  do; `inc` (`ctrInc`) as `add` of 1, but `CF`, which it keeps.
- `lea`, `mov`, `movzx`/`movsx`, `setcc`, `push`/`pop`, `call`/`ret`, `leave`, `jmp`/`jcc`,
  SSE moves: no flags.

Partial register writes: a 32-bit destination zero-extends into the 64-bit register; 8- and
16-bit destinations merge into it (the byte registers are the low bytes: the encoder gives
`sil`/`dil` a REX prefix, so `ah`–`bh` never occur). `movzx`/`movsx` (`ld` at `B`/`W`) write a
32-bit destination. SSE: `movss`/`movsd` loads zero the rest of the register, stores write 4
or 8 bytes; `movups` moves 16; `movd xmm, r32` zero-extends to 128 bits, `movd r32, xmm`
zero-extends to 64.
-/
import Ryo.X86.Encode
import Ryo.X86.State

set_option linter.constructorNameAsVariable false

namespace Ryo.X86

open Lean

/-- Why execution stopped. -/
inductive Fault
  /-- `ud2` (`#UD`). -/
  | ud
  /-- `int3` (`#BP`). -/
  | breakpoint
  /-- A `jcc`/`setcc` read a flag the SDM leaves undefined at that point. -/
  | undefinedFlag (flag : String)
  /-- Data executed: a jump table entry. -/
  | notCode
  /-- An item outside what the encoder emits (e.g. an SSE move of another size). -/
  | badItem
deriving DecidableEq, Repr, ToJson, FromJson

/-- Where the code runs: the function's address, and where its references live. -/
structure Ctx where
  base : BitVec 64
  addrOf : RefAddr

/-! ### Flag computations, at any width -/

def logicFlags {n : Nat} (r : BitVec n) : Flags :=
  { cf := some false, of := some false, zf := some (r == 0), sf := some r.msb }

/-- `a + b`: the sum and its flags. -/
def addF {n : Nat} (a b : BitVec n) : BitVec n × Flags :=
  let r := a + b
  (r, { cf := some (a.toNat + b.toNat ≥ 2 ^ n),
        of := some (a.msb == b.msb && r.msb != a.msb),
        zf := some (r == 0), sf := some r.msb })

/-- `a - b` (also `cmp a, b`): the difference and its flags. -/
def subF {n : Nat} (a b : BitVec n) : BitVec n × Flags :=
  let r := a - b
  (r, { cf := some (a.toNat < b.toNat),
        of := some (a.msb != b.msb && r.msb != a.msb),
        zf := some (r == 0), sf := some r.msb })

/-- An ALU operation: the result (`none` for `cmp`, which only sets flags) and the flags. -/
def aluF {n : Nat} (op : Alu) (a b : BitVec n) : Option (BitVec n) × Flags :=
  match op with
  | .add => let (r, f) := addF a b; (some r, f)
  | .sub => let (r, f) := subF a b; (some r, f)
  | .cmp => (none, (subF a b).2)
  | .and => let r := a &&& b; (some r, logicFlags r)
  | .or => let r := a ||| b; (some r, logicFlags r)
  | .xor => let r := a ^^^ b; (some r, logicFlags r)

/-- Signed multiplication, truncated: the product and its flags (`SF`, `ZF` undefined). -/
def imulF {n : Nat} (a b : BitVec n) : BitVec n × Flags :=
  let p := a.toInt * b.toInt
  let r := BitVec.ofInt n p
  let ovf := r.toInt != p
  (r, { cf := some ovf, of := some ovf, zf := none, sf := none })

/-- A shift by an already masked count `c`: the result and the new flags (`none`: unchanged,
for a count of 0). -/
def shiftF {n : Nat} (op : Sh) (a : BitVec n) (c : Nat) : BitVec n × Option Flags :=
  if c = 0 then (a, none) else
  let (r, cf, of) := match op with
    | .shl => let r := a <<< c
      (r, a.getLsbD (n - c), if c = 1 then some (r.msb != a.getLsbD (n - c)) else none)
    | .shr => (a >>> c, a.getLsbD (c - 1), if c = 1 then some a.msb else none)
    | .sar => (a.sshiftRight c, a.getLsbD (c - 1), if c = 1 then some false else none)
  (r, some { cf := some cf, of := of, zf := some (r == 0), sf := some r.msb })

/-- Reads a flag, faulting if it is undefined. -/
def need (name : String) : Option Bool → Except Fault Bool
  | some b => .ok b
  | none => .error (.undefinedFlag name)

/-- Whether condition `c` holds on the flags (SDM Vol. 1, Appendix B). -/
def Cond.eval (f : Flags) : Cond → Except Fault Bool
  | .always => pure true
  | .z => need "ZF" f.zf
  | .nz => (! ·) <$> need "ZF" f.zf
  | .b => need "CF" f.cf
  | .ae => (! ·) <$> need "CF" f.cf
  | .be => do pure ((← need "CF" f.cf) || (← need "ZF" f.zf))
  | .a => do pure (!(← need "CF" f.cf) && !(← need "ZF" f.zf))
  | .s => need "SF" f.sf
  | .ns => (! ·) <$> need "SF" f.sf
  | .o => need "OF" f.of
  | .no => (! ·) <$> need "OF" f.of
  | .l => do pure ((← need "SF" f.sf) != (← need "OF" f.of))
  | .ge => do pure ((← need "SF" f.sf) == (← need "OF" f.of))
  | .le => do pure ((← need "ZF" f.zf) || (← need "SF" f.sf) != (← need "OF" f.of))
  | .g => do pure (!(← need "ZF" f.zf) && (← need "SF" f.sf) == (← need "OF" f.of))

/-! ### Operands at a width -/

namespace State

/-- The effective address of `[base + disp]`. -/
def ea (s : State) (m : M) : BitVec 64 := s.reg m.base + m.disp.signExtend 64

/-- The low `w` bits of a register. -/
def regW (s : State) (w : W) (r : Reg) : BitVec w.bits := (s.reg r).setWidth w.bits

/-- Writes a `w`-bit value to a register: 8 and 16 bits merge, 32 bits zero-extend. -/
def setRegW (s : State) (w : W) (r : Reg) (v : BitVec w.bits) : State :=
  let old := s.reg r
  let v64 := v.setWidth 64
  match w with
  | .b => s.setReg r ((old &&& ~~~(0xff : BitVec 64)) ||| v64)
  | .w => s.setReg r ((old &&& ~~~(0xffff : BitVec 64)) ||| v64)
  | .d | .q => s.setReg r v64

def memW (s : State) (w : W) (a : BitVec 64) : BitVec w.bits :=
  BitVec.ofNat _ (s.mem.readNat a (w.bits / 8))

def setMemW (s : State) (w : W) (a : BitVec 64) (v : BitVec w.bits) : State :=
  s.setMem a (w.bits / 8) v.toNat

def rmW (s : State) (w : W) : Rm → BitVec w.bits
  | .reg r => s.regW w r
  | .mem m => s.memW w (s.ea m)

def setRmW (s : State) (w : W) (rm : Rm) (v : BitVec w.bits) : State :=
  match rm with
  | .reg r => s.setRegW w r v
  | .mem m => s.setMemW w (s.ea m) v

def setFlags (s : State) (f : Flags) : State := { s with flags := f }

def jump (s : State) (a : BitVec 64) : State := { s with rip := a }

end State

/-- The item's length, as executed (its encoding's; independent of the position). -/
def Item.size (i : Item) : Nat := i.len

/-- One item's effect, `s.rip` at its first byte (SDM Vol. 2). -/
def Item.exec (ctx : Ctx) (i : Item) (s : State) : Except Fault State :=
  let next := s.rip + BitVec.ofNat 64 i.size
  let s0 := s.jump next
  let inFn (t : BitVec 32) : BitVec 64 := ctx.base + t.setWidth 64
  match i with
  | .pushRbp => pure (s0.push (s0.reg .rbp))
  | .winPrologue =>
    let s1 := ((s0.push (s0.reg .rbp)).push (s0.reg .rdi))
    let s2 := s1.push (s1.reg .rsi)
    pure (s2.setReg .rbp (s2.rsp + 16))
  | .winEpilogue =>
    let s1 := s0.setReg .rsp (s0.reg .rbp - 16)
    let (rsi, s2) := s1.pop
    let (rdi, s3) := (s2.setReg .rsi rsi).pop
    let (rbp, s4) := (s3.setReg .rdi rdi).pop
    pure (s4.setReg .rbp rbp)
  | .subRsp v =>
    let (r, f) := subF s0.rsp (v.signExtend 64)
    pure ((s0.setReg .rsp r).setFlags f)
  | .addRsp v =>
    let (r, f) := addF s0.rsp (v.signExtend 64)
    pure ((s0.setReg .rsp r).setFlags f)
  | .setReg r v =>
    if setForm v == 0 then pure ((s0.setReg r 0).setFlags (logicFlags (0 : BitVec 32)))
    else pure (s0.setReg r v)
  | .lea r to => pure (s0.setReg r (ctx.addrOf to))
  | .leaTable t => pure (s0.setReg .rcx (inFn t))
  | .mov dst src => pure (s0.setReg dst (s0.reg src))
  | .call to => pure ((s0.push next).jump (ctx.addrOf to))
  | .callMem to =>
    let target := s0.mem.read64 (ctx.addrOf to)
    pure ((s0.push next).jump target)
  | .callRax => pure ((s0.push next).jump (s0.reg .rax))
  | .ctrInc lp =>
    let a := ctx.addrOf (if lp then .recordLoopCtr else .record)
    let (r, f) := addF (s0.mem.read64 a) 1
    pure ((s0.setMem a 8 r.toNat).setFlags { f with cf := s0.flags.cf })
  | .callR11 d =>
    let target := s0.mem.read64 (s0.reg .r11 + d.signExtend 64)
    pure ((s0.push next).jump target)
  | .loadRip r to => pure (s0.setReg r (s0.mem.read64 (ctx.addrOf to)))
  | .callMemRax =>
    let target := s0.mem.read64 (s0.reg .rax)
    pure ((s0.push next).jump target)
  | .jmpRax => pure (s0.jump (s0.reg .rax))
  | .jmp to => pure (s0.jump (ctx.addrOf to))
  | .branch cond target _ => do
    if ← cond.eval s0.flags then pure (s0.jump (inFn target)) else pure s0
  | .testAl => pure (s0.setFlags (logicFlags (s0.regW .b .rax)))
  | .testRax => pure (s0.setFlags (logicFlags (s0.reg .rax)))
  | .leave =>
    let (rbp, s1) := (s0.setReg .rsp (s0.reg .rbp)).pop
    pure (s1.setReg .rbp rbp)
  | .ret => let (a, s1) := s0.pop; pure (s1.jump a)
  | .ud2 => throw .ud
  | .loadTableEntry =>
    let a := s0.reg .rcx + (s0.reg .rax <<< 2)
    pure (s0.setReg .rax ((s0.memW .d a).signExtend 64))
  | .addRaxRcx =>
    let (r, f) := addF (s0.reg .rax) (s0.reg .rcx)
    pure ((s0.setReg .rax r).setFlags f)
  | .nop _ => pure s0
  | .int3 => throw .breakpoint
  | .tableEntry .. => throw .notCode
  | .ld w sx dst m =>
    let a := s0.ea m
    match w with
    | .b => let v := s0.memW .b a
      pure (s0.setReg dst ((if sx then v.signExtend 32 else v.setWidth 32).setWidth 64))
    | .w => let v := s0.memW .w a
      pure (s0.setReg dst ((if sx then v.signExtend 32 else v.setWidth 32).setWidth 64))
    | .d => pure (s0.setRegW .d dst (s0.memW .d a))
    | .q => pure (s0.setRegW .q dst (s0.memW .q a))
  | .st w src m => pure (s0.setMemW w (s0.ea m) (s0.regW w src))
  | .stImm w m imm => pure (s0.setMemW w (s0.ea m) (imm.signExtend w.bits))
  | .leaM dst m => pure (s0.setReg dst (s0.ea m))
  | .alu op w reg rm =>
    let (r, f) := aluF op (s0.regW w reg) (s0.rmW w rm)
    let s1 := s0.setFlags f
    pure (match r with | some v => s1.setRegW w reg v | none => s1)
  | .aluImm op w rm imm =>
    let (r, f) := aluF op (s0.rmW w rm) (imm.signExtend w.bits)
    let s1 := s0.setFlags f
    pure (match r with | some v => s1.setRmW w rm v | none => s1)
  | .imul w reg rm =>
    let (r, f) := imulF (s0.regW w reg) (s0.rmW w rm)
    pure ((s0.setRegW w reg r).setFlags f)
  | .imulImm w reg rm imm =>
    let (r, f) := imulF (s0.rmW w rm) (imm.signExtend w.bits)
    pure ((s0.setRegW w reg r).setFlags f)
  | .shift op w reg amt =>
    let c := amt.toNat % (if w == .q then 64 else 32)
    let (r, f) := shiftF op (s0.regW w reg) c
    let s1 := s0.setRegW w reg r
    pure (match f with | some f => s1.setFlags f | none => s1)
  | .setcc cond m => do
    let b ← cond.eval s0.flags
    pure (s0.setMem (s0.ea m) 1 (if b then 1 else 0))
  | .testM8 m => pure (s0.setFlags (logicFlags (s0.memW .b (s0.ea m))))
  | .setccCl cond => do
    let b ← cond.eval s0.flags
    pure (s0.setRegW .b .rcx (if b then 1 else 0))
  | .mulQ rm =>
    let p := (s0.reg .rax).toNat * (s0.rmW .q rm).toNat
    let ovf := p ≥ 2 ^ 64
    let s1 := (s0.setReg .rax (BitVec.ofNat 64 p)).setReg .rdx (BitVec.ofNat 64 (p / 2 ^ 64))
    pure (s1.setFlags { cf := some ovf, of := some ovf, zf := none, sf := none })
  | .sse isSt size x m =>
    let a := s0.ea m
    let xi : Fin 16 := ⟨x % 16, Nat.mod_lt _ (by decide)⟩
    if size != 4 && size != 8 && size != 16 then throw .badItem
    else if isSt then pure (s0.setMem a size (s0.xmm xi).toNat)
    else pure (s0.setXmm xi (BitVec.ofNat 128 (s0.mem.readNat a size)))
  | .movd toXmm x r =>
    let xi : Fin 16 := ⟨x % 16, Nat.mod_lt _ (by decide)⟩
    if toXmm then pure (s0.setXmm xi ((s0.reg r).setWidth 32 |>.setWidth 128))
    else pure (s0.setReg r ((s0.xmm xi).setWidth 32 |>.setWidth 64))

/-- Runs a list of items in order, each from the state the previous one left (straight-line
code, for tests: a jump doesn't change which item runs next). -/
def execItems (ctx : Ctx) (items : List Item) (s : State) : Except Fault State :=
  items.foldlM (fun s i => i.exec ctx s) s

end Ryo.X86
