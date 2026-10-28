/-
Ryo.X86.Encode — `Item.encode`: the canonical bytes of an item (x86.md §B.2).

Mirrors `Item::write` in `vm/bytecode/src/asm/x86.rs`, byte for byte: immediates and
displacements in their shortest form, REX only where needed (`W` for 64 bits, `R`/`B` for
`r8`–`r11`, a bare `0x40` for a byte operand in `sil`/`dil`), the operand-size prefix for 16 bits.

Relocated fields are named, not resolved, as in Rust: `encode` writes them as zeros and returns
a `Reloc` per field (its absolute position and the `Ref`). `link` patches them for code at a
known address, given where each `Ref` lives. Branches within the function (`branch`,
`leaTable`) are PC-relative fields computed from the item's position.
-/
import Ryo.X86.Item

set_option linter.constructorNameAsVariable false

namespace Ryo.X86

/-- The little-endian bytes of `v`, `n` of them. -/
def leBytes {w : Nat} (v : BitVec w) (n : Nat) : List UInt8 :=
  (List.range n).map fun i => UInt8.ofNat (v.toNat >>> (8 * i))

/-- The value of little-endian bytes. -/
def ofLeBytes (bs : List UInt8) : Nat :=
  bs.foldr (fun b acc => b.toNat + 256 * acc) 0

def byte (n : Nat) : UInt8 := UInt8.ofNat n

/-- The standard multi-byte `nop`s (Intel SDM), by length (`x86.rs` `NOPS`). -/
def nops : List (List UInt8) := [
  [],
  [0x90],
  [0x66, 0x90],
  [0x0f, 0x1f, 0x00],
  [0x0f, 0x1f, 0x40, 0x00],
  [0x0f, 0x1f, 0x44, 0x00, 0x00],
  [0x66, 0x0f, 0x1f, 0x44, 0x00, 0x00],
  [0x0f, 0x1f, 0x80, 0x00, 0x00, 0x00, 0x00],
  [0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
  [0x66, 0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00]]

/-- The padding items for `n` bytes: 9-byte `nop`s, then the remainder (`x86.rs` `padding`). -/
def padding (n : Nat) : List Item :=
  List.replicate (n / 9) (.nop 9) ++ (if n % 9 != 0 then [.nop (n % 9)] else [])

/-- The shortest form of `reg = v`: 0 `xor`, 1 `mov r32`, 2 `mov r64, simm32`, 3 `movabs`. -/
def setForm (v : BitVec 64) : Nat :=
  if v == 0 then 0
  else if v.toNat < 2 ^ 32 then 1
  else if fitsSigned 32 v then 2
  else 3

namespace M

/-- The encoded length of the ModRM, SIB and displacement. -/
def len (m : M) : Nat :=
  1 + (if m.base == .rsp then 1 else 0) +
    (if m.base != .rbp && m.disp == 0 then 0 else if imm8 m.disp then 1 else 4)

/-- The ModRM byte (`reg` in its middle field), the SIB byte of `rsp`, and the displacement. -/
def write (m : M) (reg : Nat) : List UInt8 :=
  let rm := m.base.low
  let sib : List UInt8 := if m.base == .rsp then [0x24] else []
  if m.base != .rbp && m.disp == 0 then
    [byte (reg <<< 3 ||| rm)] ++ sib
  else if imm8 m.disp then
    [byte (0x40 ||| reg <<< 3 ||| rm)] ++ sib ++ [byte m.disp.toNat]
  else
    [byte (0x80 ||| reg <<< 3 ||| rm)] ++ sib ++ leBytes m.disp 4

end M

namespace Rm

def len : Rm → Nat
  | .reg _ => 1
  | .mem m => m.len

def write (rm : Rm) (reg : Nat) : List UInt8 :=
  match rm with
  | .reg r => [byte (0xc0 ||| reg <<< 3 ||| r.low)]
  | .mem m => m.write reg

end Rm

/-- A full-width immediate field (`W::imm`; `Q`: 32 bits). -/
def W.imm (w : W) (imm : BitVec 32) : List UInt8 := leBytes imm w.immLen

namespace Item

/-- The REX prefix of a native item, if it needs one (`Item::rex`). -/
def rex? (i : Item) : Option UInt8 :=
  let parts : Option (Bool × Option Reg × Rm × Bool) := match i with
    | ld w _ dst m => some (w == .q, some dst, .mem m, false)
    | st w src m => some (w == .q, some src, .mem m, w == .b)
    | stImm w m _ => some (w == .q, none, .mem m, false)
    | leaM dst m => some (true, some dst, .mem m, false)
    | alu _ w reg rm => some (w == .q, some reg, rm, w == .b)
    | aluImm _ w rm _ => some (w == .q, none, rm, w == .b)
    | imul w reg rm | imulImm w reg rm _ => some (w == .q, some reg, rm, false)
    | shift _ w reg _ => some (w == .q, none, .reg reg, false)
    | setcc _ m | testM8 m => some (false, none, .mem m, false)
    | mulQ rm => some (true, none, rm, false)
    | shiftCl _ w reg => some (w == .q, none, .reg reg, w == .b)
    | bswap w reg => some (w == .q, none, .reg reg, false)
    | setccR _ reg => some (false, none, .reg reg, true)
    | bsf w reg rm | bsr w reg rm | cmov _ w reg rm => some (w == .q, some reg, rm, false)
    | div _ w rm => some (w == .q, none, rm, false)
    | _ => none
  parts.bind fun (w, reg, rm, isByte) =>
    let sil (r : Reg) : Bool := isByte && !r.ext && r.low ≥ 4
    let b := fun (c : Bool) => if c then 1 else 0
    let (rexR, needR) := match reg with
      | some r => (b r.ext <<< 2, sil r)
      | none => (0, false)
    let (rexB, needB) := match rm with
      | .reg r => (b r.ext, sil r)
      | .mem m => (b m.base.ext, false)
    let rex := 0x40 ||| (b w <<< 3) ||| rexR ||| rexB
    if rex != 0x40 || needR || needB then some (byte rex) else none

/-- Whether the item takes the operand-size prefix `0x66`. -/
def w16 : Item → Bool
  | st .w _ _ | stImm .w _ _ | alu _ .w _ _ | aluImm _ .w _ _ | shiftCl _ .w _ => true
  | _ => false

/-- A native item's prefixes: `0x66` for 16 bits, then REX (`Item::prefixes`). -/
def prefixes (i : Item) : List UInt8 :=
  (if i.w16 then [0x66] else []) ++ (i.rex?.map ([·])).getD []

/-- The encoded bytes (relocated fields as zeros) and the relocations, at position `pos`
(`Item::write`). -/
def encode (i : Item) (pos : BitVec 32) : List UInt8 × List Reloc :=
  -- A field relocated against `to`, `off` bytes into the item.
  let reloc (pre : List UInt8) (to : Ref) (post : List UInt8 := []) : List UInt8 × List Reloc :=
    (pre ++ [0, 0, 0, 0] ++ post, [⟨pos.toNat + pre.length, to⟩])
  -- A field holding the offset of `target` from the field's end.
  let rel32 (pre : List UInt8) (target : BitVec 32) : List UInt8 :=
    pre ++ leBytes (target - (pos + BitVec.ofNat 32 (pre.length + 4))) 4
  let plain (bs : List UInt8) : List UInt8 × List Reloc := (bs, [])
  match i with
  | pushRbp => plain [0x55]
  | popRbp => plain [0x5d]
  | subRsp v | addRsp v =>
    let ext : UInt8 := if i matches subRsp _ then 0xec else 0xc4
    if v.toNat < 128 then plain [0x48, 0x83, ext, byte v.toNat]
    else plain ([0x48, 0x81, ext] ++ leBytes v 4)
  | setReg r v =>
    let b := fun (c : Bool) => if c then 1 else 0
    match setForm v with
    | 0 => plain ((if r.ext then [(0x45 : UInt8)] else []) ++ [0x31, byte (0xc0 ||| r.low <<< 3 ||| r.low)])
    | 1 => plain ((if r.ext then [(0x41 : UInt8)] else []) ++ [byte (0xb8 ||| r.low)] ++ leBytes v 4)
    | 2 => plain ([byte (0x48 ||| b r.ext), 0xc7, byte (0xc0 ||| r.low)] ++ leBytes v 4)
    | _ => plain ([byte (0x48 ||| b r.ext), byte (0xb8 ||| r.low)] ++ leBytes v 8)
  | lea r to =>
    let b := fun (c : Bool) => if c then 1 else 0
    reloc [byte (0x48 ||| b r.ext <<< 2), 0x8d, byte (0x05 ||| r.low <<< 3)] to
  | leaTable t => plain (rel32 [0x48, 0x8d, 0x0d] t)
  | mov dst src =>
    let b := fun (c : Bool) => if c then 1 else 0
    plain [byte (0x48 ||| b src.ext <<< 2 ||| b dst.ext), 0x89,
      byte (0xc0 ||| src.low <<< 3 ||| dst.low)]
  | call to => reloc [0xe8] to
  | callMem to => reloc [0xff, 0x15] to
  | callRax => plain [0xff, 0xd0]
  | ctrInc lp => reloc [0x48, 0xff, 0x05] (if lp then .recordLoopCtr else .record)
  | callR11 d => plain [0x41, 0xff, 0x53, byte d.toNat]
  | callMemRax => plain [0xff, 0x10]
  | loadRip r to =>
    let b := fun (c : Bool) => if c then 1 else 0
    reloc [byte (0x48 ||| b r.ext <<< 2), 0x8b, byte (0x05 ||| r.low <<< 3)] to
  | jmpRax => plain [0xff, 0xe0]
  | jmpRaxW => plain [0x48, 0xff, 0xe0]
  | jmpR11 => plain [0x41, 0xff, 0xe3]
  | jmp to => reloc [0xe9] to
  | branch cond target long =>
    if long then
      match cond with
      | .always => plain (rel32 [0xe9] target)
      | c => plain (rel32 [0x0f, byte (0x80 ||| c.cc)] target)
    else
      let op : UInt8 := match cond with
        | .always => 0xeb
        | c => byte (0x70 ||| c.cc)
      plain [op, byte (target - (pos + 2)).toNat]
  | testAl => plain [0x84, 0xc0]
  | testRax => plain [0x48, 0x85, 0xc0]
  | leave => plain [0xc9]
  | ret => plain [0xc3]
  | ud2 => plain [0x0f, 0x0b]
  | loadTableEntry => plain [0x48, 0x63, 0x04, 0x81]
  | addRaxRcx => plain [0x48, 0x01, 0xc8]
  | nop n => plain (nops.getD n [])
  | int3 => plain [0xcc]
  | tableEntry base target => plain (leBytes (target - base) 4)
  | ld w sx dst m =>
    let op : List UInt8 := match w with
      | .b => [0x0f, if sx then 0xbe else 0xb6]
      | .w => [0x0f, if sx then 0xbf else 0xb7]
      | _ => [0x8b]
    plain (i.prefixes ++ op ++ m.write dst.low)
  | st w src m => plain (i.prefixes ++ [if w == .b then 0x88 else 0x89] ++ m.write src.low)
  | stImm w m imm =>
    plain (i.prefixes ++ [if w == .b then 0xc6 else 0xc7] ++ m.write 0 ++ w.imm imm)
  | leaM dst m => plain (i.prefixes ++ [0x8d] ++ m.write dst.low)
  | alu op w reg rm =>
    plain (i.prefixes ++ [byte (op.num <<< 3 ||| (if w == .b then 2 else 3))] ++ rm.write reg.low)
  | aluImm op w rm imm =>
    let short := w == .b || imm8 imm
    let opc : UInt8 := if w == .b then 0x80 else if short then 0x83 else 0x81
    plain (i.prefixes ++ [opc] ++ rm.write op.num ++
      (if short then [byte imm.toNat] else w.imm imm))
  | imul _ reg rm => plain (i.prefixes ++ [0x0f, 0xaf] ++ rm.write reg.low)
  | imulImm _ reg rm imm =>
    plain (i.prefixes ++ [if imm8 imm then 0x6b else 0x69] ++ rm.write reg.low ++
      (if imm8 imm then [byte imm.toNat] else leBytes imm 4))
  | shift op _ reg amt =>
    plain (i.prefixes ++ [0xc1, byte (0xc0 ||| op.num <<< 3 ||| reg.low), byte amt.toNat])
  | setcc cond m => plain (i.prefixes ++ [0x0f, byte (0x90 ||| cond.cc)] ++ m.write 0)
  | testM8 m => plain (i.prefixes ++ [0xf6] ++ m.write 0 ++ [0xff])
  | setccCl cond => plain [0x0f, byte (0x90 ||| cond.cc), 0xc1]
  | mulQ rm => plain (i.prefixes ++ [0xf7] ++ rm.write 4)
  | shiftCl op w reg =>
    plain (i.prefixes ++ [if w == .b then 0xd2 else 0xd3, byte (0xc0 ||| op.num <<< 3 ||| reg.low)])
  | div signed _ rm => plain (i.prefixes ++ [0xf7] ++ rm.write (if signed then 7 else 6))
  | cdq w => plain ((if w == .q then [0x48] else []) ++ [0x99])
  | bsf _ reg rm => plain (i.prefixes ++ [0x0f, 0xbc] ++ rm.write reg.low)
  | bsr _ reg rm => plain (i.prefixes ++ [0x0f, 0xbd] ++ rm.write reg.low)
  | cmov cond _ reg rm => plain (i.prefixes ++ [0x0f, byte (0x40 ||| cond.cc)] ++ rm.write reg.low)
  | setccR cond reg => plain (i.prefixes ++ [0x0f, byte (0x90 ||| cond.cc), byte (0xc0 ||| reg.low)])
  | bswap _ reg => plain (i.prefixes ++ [0x0f, byte (0xc8 ||| reg.low)])
  | sse isSt size x m =>
    let pre : List UInt8 := if size == 4 then [0xf3] else if size == 8 then [0xf2] else []
    plain (pre ++ [0x0f, if isSt then 0x11 else 0x10] ++ m.write x)
  | movd toXmm x r =>
    plain ([(0x66 : UInt8)] ++ (if r.ext then [(0x41 : UInt8)] else []) ++
      [0x0f, if toXmm then 0x6e else 0x7e, byte (0xc0 ||| x <<< 3 ||| r.low)])

/-- The bytes alone. -/
def bytes (i : Item) (pos : BitVec 32) : List UInt8 := (i.encode pos).1

/-- The encoded length (`Item::len`, here by definition). -/
def len (i : Item) : Nat := (i.encode 0).1.length

end Item

/-- Where the relocated fields of a function's code point once linked: the address of each
`Ref` (`Ref.recordLoopCtr`: the record's address plus `loopCtr`). -/
abbrev RefAddr := Ref → BitVec 64

/-- Patches the relocated fields of `code`, which starts at address `addr`: each field holds
`target - (field + 4)` (`R_X86_64_PC32` with addend `-4`). -/
def link (addr : BitVec 64) (addrOf : RefAddr) (code : List UInt8) (relocs : List Reloc) :
    List UInt8 :=
  relocs.foldl (fun c r =>
    let d := addrOf r.to - (addr + BitVec.ofNat 64 (r.pos + 4))
    let f := leBytes d 4
    (List.range c.length).map fun j =>
      if r.pos ≤ j ∧ j < r.pos + 4 then f.getD (j - r.pos) 0 else c.getD j 0) code

/-- Encodes a sequence of items from position `pos`: the bytes and relocations. -/
def encodeItems (items : List Item) (pos : Nat := 0) : List UInt8 × List Reloc :=
  let (bs, rs, _) := items.foldl (fun (bs, rs, p) i =>
    let (b, r) := i.encode (BitVec.ofNat 32 p)
    (bs ++ b, rs ++ r, p + b.length)) ([], [], pos)
  (bs, rs)

end Ryo.X86
