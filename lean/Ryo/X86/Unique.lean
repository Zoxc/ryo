import Ryo.X86.Fetch

/-
Ryo.X86.Unique — when canonical items at one address execute alike (`ExecUnique`,
`Ryo.X86.Fetch`).

`execUnique`: `ExecUnique ctx` holds given one hypothesis on the context, and so `Step ctx` is a
function (`step_deterministic_of_refsNear`, by `step_deterministic`):

- `RefsNear ctx`: every reference (`ctx.addrOf r`) lies in the 4 GiB from the function's address
  up, `[ctx.base, ctx.base + 2^32)`. A linked `rel32` field holds only the low 32 bits of
  `target - (field + 4)`, while `Item.exec` takes a reference's full address and an in-function
  target (`branch`, `leaTable`) as `ctx.base + t` with `t` unsigned 32-bit. So `jmp r` and the
  long `jmp` of `branch .always t true` (`t` the low 32 bits of `ctx.addrOf r - ctx.base`) have
  the same bytes, as `lea rcx, r` and `leaTable t` do, and execute alike exactly when
  `ctx.addrOf r = ctx.base + t`. The hypothesis is the weakest on `ctx` that works:
  `refsNear_of_execUnique` derives it back (`execUnique_iff_refsNear`). (It is not the linker's
  guarantee, a target within ±2 GiB of each field: that one bounds `target - field`, this one
  the target's offset from the function's start, which the model's unsigned in-function targets
  need.)

That needs every item to be one instruction, as every item is (the PE prologue and epilogue are
`push rbp; mov rbp, rsp; sub rsp, F` and `add rsp, F; pop rbp`): an item whose bytes were a
prefix of another's would step from the same state to a different one.

The proof is a decoder (`Uniq.dec`, a proof device: not `Ryo.X86.Decode`'s `decodeItem`, whose
round trip stays tested). It reads a byte list from the item's address and function position and
returns a `Uniq.Key`: the item itself, or, for a `rel32` reference field, the kind of item and
the low 32 bits of the target. `Uniq.dec_linked`: for an item `Uniq.Ok` at its position (which
`Item.Canonical` implies: `Uniq.ok_of_canonical`), `dec` of its linked bytes followed by anything
returns `Uniq.keyOf` of it and the rest. So of two canonical items at one address (one's bytes a
prefix of the other's, `Uniq.prefix_of_bytesAt`) the keys agree, and under `RefsNear` the key
determines `Item.exec` (`Uniq.exec_key`).

The decoder lemmas go by item family (`Uniq.fam_*`): prefixes (`0x66`, REX, through
`Uniq.rexOf_spec`: the REX bits are the operands' extension bits), opcode, ModRM/SIB/displacement
(`Uniq.decModrm_rm`, for every register and memory operand), immediate (`Uniq.rd8n`,
`Uniq.rd16_le`, `Uniq.rd32_le`: the shortest forms the encoder picks give back the value).
-/

set_option linter.unusedSimpArgs false
set_option linter.constructorNameAsVariable false

namespace Ryo.X86
namespace Uniq

/-! ### The decoder

Bytes as `Nat`s. Fields: `rd8`, `rd16` (both sign-extended to 32 bits), `rd32`, `rd64`, little-endian. -/

def rd8 : List Nat → Option (BitVec 32 × List Nat)
  | a :: r => some ((BitVec.ofNat 8 a).signExtend 32, r)
  | [] => none
def rd16 : List Nat → Option (BitVec 32 × List Nat)
  | a :: b :: r => some ((BitVec.ofNat 16 (a + 256 * b)).signExtend 32, r)
  | _ => none
def rd32 : List Nat → Option (BitVec 32 × List Nat)
  | a :: b :: c :: d :: r => some (BitVec.ofNat 32 (a + 256 * (b + 256 * (c + 256 * d))), r)
  | _ => none
def rd64 : List Nat → Option (BitVec 64 × List Nat)
  | a :: b :: c :: d :: e :: f :: g :: h :: r => some (BitVec.ofNat 64
      (a + 256 * (b + 256 * (c + 256 * (d + 256 * (e + 256 * (f + 256 * (g + 256 * h))))))), r)
  | _ => none

theorem rd32_le {w : Nat} (v : BitVec w) (r : List Nat) :
    rd32 ((leBytes v 4).map UInt8.toNat ++ r) = some (v.setWidth 32, r) := by
  simp only [leBytes, List.range_succ, List.range_zero, List.nil_append, List.map_append,
    List.map_cons, List.map_nil, List.cons_append, List.nil_append, rd32, Option.some.injEq,
    Prod.mk.injEq, and_true]
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, BitVec.toNat_setWidth, UInt8.toNat_ofNat', Nat.shiftRight_eq_div_pow, Nat.reducePow, Nat.reduceMul, Nat.div_one]
  omega

theorem rd64_le (v : BitVec 64) (r : List Nat) :
    rd64 ((leBytes v 8).map UInt8.toNat ++ r) = some (v, r) := by
  simp only [leBytes, List.range_succ, List.range_zero, List.nil_append, List.map_append,
    List.map_cons, List.map_nil, List.cons_append, List.nil_append, rd64, Option.some.injEq,
    Prod.mk.injEq, and_true]
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, UInt8.toNat_ofNat', Nat.shiftRight_eq_div_pow, Nat.reducePow, Nat.reduceMul, Nat.div_one]
  have := v.isLt
  omega

theorem rd16_le (v : BitVec 32) (h : fitsSigned 16 v = true) (r : List Nat) :
    rd16 ((leBytes v 2).map UInt8.toNat ++ r) = some (v, r) := by
  simp only [leBytes, List.range_succ, List.range_zero, List.nil_append, List.map_append,
    List.map_cons, List.map_nil, List.cons_append, List.nil_append, rd16, Option.some.injEq,
    Prod.mk.injEq, and_true]
  simp only [fitsSigned, beq_iff_eq] at h
  conv => rhs; rw [← h]
  congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, BitVec.toNat_setWidth, UInt8.toNat_ofNat', Nat.shiftRight_eq_div_pow, Nat.reducePow, Nat.reduceMul, Nat.div_one]
  omega

theorem rd8_byte (v : BitVec 32) (h : fitsSigned 8 v = true) (r : List Nat) :
    rd8 ((byte v.toNat).toNat :: r) = some (v, r) := by
  simp only [rd8, byte, UInt8.toNat_ofNat', Nat.reducePow, Option.some.injEq, Prod.mk.injEq, and_true]
  simp only [fitsSigned, beq_iff_eq] at h
  conv => rhs; rw [← h]
  congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, BitVec.toNat_setWidth]
  omega

inductive Opnd
  | reg (r : Reg)
  | mem (m : M)
  | rip (d : BitVec 32)

def regOf (lo : Nat) (x : Bool) : Option Reg := Reg.ofNum? (lo + if x then 8 else 0)

theorem regOf_reg (r : Reg) : regOf r.low r.ext = some r := by cases r <;> rfl

def decModrm (x : Bool) : List Nat → Option (Nat × Opnd × List Nat)
  | [] => none
  | mr :: r =>
    if mr / 64 = 3 then (regOf (mr % 8) x).map fun b => (mr / 8 % 8, .reg b, r)
    else if mr / 64 = 0 ∧ mr % 8 = 5 then (rd32 r).map fun (d, r) => (mr / 8 % 8, .rip d, r)
    else do
      let r ← if mr % 8 = 4 then (match r with | 0x24 :: r => some r | _ => none) else some r
      let b ← regOf (mr % 8) x
      if mr / 64 = 0 then pure (mr / 8 % 8, .mem ⟨b, 0⟩, r)
      else if mr / 64 = 1 then do let (d, r) ← rd8 r; pure (mr / 8 % 8, .mem ⟨b, d⟩, r)
      else do let (d, r) ← rd32 r; pure (mr / 8 % 8, .mem ⟨b, d⟩, r)

def rmExt : Rm → Bool
  | .reg r => r.ext
  | .mem m => m.base.ext

def opnd : Rm → Opnd
  | .reg r => .reg r
  | .mem m => .mem m

theorem lor_c0 : ∀ g < 8, ∀ lo < 8, 0xc0 ||| g <<< 3 ||| lo = 192 + 8 * g + lo := by decide
theorem lor_80 : ∀ g < 8, ∀ lo < 8, 0x80 ||| g <<< 3 ||| lo = 128 + 8 * g + lo := by decide
theorem lor_40 : ∀ g < 8, ∀ lo < 8, 0x40 ||| g <<< 3 ||| lo = 64 + 8 * g + lo := by decide
theorem lor_00 : ∀ g < 8, ∀ lo < 8, g <<< 3 ||| lo = 8 * g + lo := by decide

theorem low_lt (r : Reg) : r.low < 8 := Nat.mod_lt _ (by decide)

theorem decModrm_rm (rm : Rm) (g : Nat) (hg : g < 8) (r : List Nat) :
    decModrm (rmExt rm) ((rm.write g).map UInt8.toNat ++ r) = some (g, opnd rm, r) := by
  rcases rm with b | ⟨b, d⟩
  · simp only [Rm.write, List.map, byte, UInt8.toNat_ofNat', lor_c0 g hg _ (low_lt b),
      List.cons_append, List.nil_append, decModrm]
    have hl := low_lt b
    have h1 : (192 + 8 * g + b.low) % 2 ^ 8 / 64 = 3 := by simp only [Nat.reducePow]; omega
    have h2 : (192 + 8 * g + b.low) % 2 ^ 8 % 8 = b.low := by simp only [Nat.reducePow]; omega
    have h3 : (192 + 8 * g + b.low) % 2 ^ 8 / 8 % 8 = g := by simp only [Nat.reducePow]; omega
    simp [h1, h2, h3, rmExt, regOf_reg, opnd]
  · have hl := low_lt b
    have h4 : b.low = 4 ↔ b = .rsp := by cases b <;> decide
    have h5 : b.low = 5 ↔ b = .rbp := by cases b <;> decide
    have hsib : ∀ r : List Nat, (if (b == Reg.rsp) = true then [(36 : UInt8)] else []).map UInt8.toNat ++ r =
        if b.low = 4 then 36 :: r else r := by
      intro r
      by_cases hb : b = .rsp
      · subst hb; rfl
      · have : b.low ≠ 4 := fun h => hb (h4.1 h)
        simp [hb, this]
    simp only [Rm.write, M.write]
    by_cases h0 : (b != Reg.rbp && d == 0) = true
    · rw [ite_eq_left h0]
      simp only [Bool.and_eq_true, bne_iff_ne, ne_eq, beq_iff_eq] at h0
      obtain ⟨hb, rfl⟩ := h0
      simp only [List.map_append, List.append_assoc, hsib, List.map, byte, UInt8.toNat_ofNat',
        Nat.reducePow, lor_00 g hg _ hl, List.cons_append, List.nil_append, decModrm]
      have e1 : (8 * g + b.low) % 256 / 64 = 0 := by omega
      have e2 : (8 * g + b.low) % 256 % 8 = b.low := by omega
      have e3 : (8 * g + b.low) % 256 / 8 % 8 = g := by omega
      have e5 : b.low ≠ 5 := fun h => hb (h5.1 h)
      simp only [e1, e2, e3, e5]
      by_cases hs : b = .rsp
      · subst hs; simp [regOf, Reg.ofNum?, rmExt, opnd, Reg.low, Reg.num, Reg.ext]
      · have : b.low ≠ 4 := fun h => hs (h4.1 h)
        simp [this, regOf_reg, rmExt, opnd]
    rw [ite_eq_right h0]
    have hbase : ¬ (b ≠ .rbp ∧ d = 0) := by simpa using h0
    by_cases h1 : imm8 d = true
    · rw [ite_eq_left h1]
      simp only [List.map_append, List.append_assoc, hsib, List.map, byte, UInt8.toNat_ofNat',
        Nat.reducePow, lor_40 g hg _ hl, List.cons_append, List.nil_append, decModrm]
      have e1 : (64 + 8 * g + b.low) % 256 / 64 = 1 := by omega
      have e2 : (64 + 8 * g + b.low) % 256 % 8 = b.low := by omega
      have e3 : (64 + 8 * g + b.low) % 256 / 8 % 8 = g := by omega
      simp only [e1, e2, e3]
      have := rd8_byte d h1 r
      simp only [byte, UInt8.toNat_ofNat', Nat.reducePow] at this
      by_cases hs : b = .rsp
      · subst hs; simp [regOf, Reg.ofNum?, rmExt, opnd, Reg.low, Reg.num, Reg.ext, this]
      · have : b.low ≠ 4 := fun h => hs (h4.1 h)
        simp [this, regOf_reg, rmExt, opnd, *]
    · rw [ite_eq_right h1]
      simp only [List.map_append, List.append_assoc, hsib, List.map, byte, UInt8.toNat_ofNat',
        Nat.reducePow, lor_80 g hg _ hl, List.cons_append, List.nil_append, decModrm]
      have e1 : (128 + 8 * g + b.low) % 256 / 64 = 2 := by omega
      have e2 : (128 + 8 * g + b.low) % 256 % 8 = b.low := by omega
      have e3 : (128 + 8 * g + b.low) % 256 / 8 % 8 = g := by omega
      simp only [e1, e2, e3]
      by_cases hs : b = .rsp
      · subst hs; simp [regOf, Reg.ofNum?, rmExt, opnd, Reg.low, Reg.num, Reg.ext, rd32_le]
      · have : b.low ≠ 4 := fun h => hs (h4.1 h)
        simp [this, regOf_reg, rmExt, opnd, rd32_le]

def Opnd.rm? : Opnd → Option Rm
  | .reg r => some (.reg r)
  | .mem m => some (.mem m)
  | .rip _ => none

def Opnd.mem? : Opnd → Option M
  | .mem m => some m
  | _ => none

def Opnd.reg? : Opnd → Option Reg
  | .reg r => some r
  | _ => none

theorem opnd_rm (rm : Rm) : (opnd rm).rm? = some rm := by cases rm <;> rfl

def low32 (x : BitVec 64) : BitVec 32 := x.setWidth 32

/-- What a `rel32` reference field gives: the kind of item. -/
inductive RefK
  | call | callMem | jmp | ctrInc
  | lea (r : Reg)
  | loadRip (r : Reg)

/-- What the bytes of a canonical item determine. -/
inductive Key
  | item (i : Item)
  | ref (k : RefK) (t : BitVec 32)

def rdB : List Nat → Option (BitVec 8 × List Nat)
  | a :: r => some (BitVec.ofNat 8 a, r)
  | [] => none

def rdW : W → List Nat → Option (BitVec 32 × List Nat)
  | .b => rd8
  | .w => rd16
  | _ => rd32

/-- `aluImm sub/add` of `rsp` at 64 bits is `subRsp`/`addRsp`. -/
def fixRsp : Item → Item
  | .aluImm op w rm v =>
    if w = .q ∧ rm = .reg .rsp then
      if op = .sub then .subRsp v else if op = .add then .addRsp v else .aluImm op w rm v
    else .aluImm op w rm v
  | i => i

/-- A native item after its prefixes (`pl` bytes of them; `rex` 0 for none). -/
def native (a : BitVec 64) (pl : Nat) (p66 : Bool) (rex : Nat) : List Nat → Option (Key × List Nat)
  | [] => none
  | op :: r =>
    let bW := rex / 8 % 2 == 1
    let R := rex / 4 % 2 == 1
    let X := rex % 2 == 1
    let wd : X86.W := if bW then .q else if p66 then .w else .d
    let tgt (d : BitVec 32) : BitVec 32 := d + low32 (a + BitVec.ofNat 64 (pl + 6))
    if op = 0x63 then
      match r with
      | 0x04 :: 0x81 :: r => some (.item .loadTableEntry, r)
      | _ => none
    else if op = 0x99 then some (.item (.cdq wd), r)
    else if 0xb8 ≤ op ∧ op < 0xc0 then do
      let d ← regOf (op - 0xb8) X
      if bW then do let (v, r) ← rd64 r; pure (.item (.setReg d v), r)
      else do let (v, r) ← rd32 r; pure (.item (.setReg d (v.setWidth 64)), r)
    else if op = 0x0f then
      match r with
      | [] => none
      | op2 :: r =>
        if 0xc8 ≤ op2 ∧ op2 < 0xd0 then do
          let d ← regOf (op2 - 0xc8) X
          pure (.item (.bswap wd d), r)
        else do
        let (g, o, r) ← decModrm X r
        if op2 = 0xaf ∨ op2 = 0xbc ∨ op2 = 0xbd then do
          let reg ← regOf g R
          let rm ← o.rm?
          pure (.item (if op2 = 0xaf then .imul wd reg rm else if op2 = 0xbc then .bsf wd reg rm
            else .bsr wd reg rm), r)
        else if 0x40 ≤ op2 ∧ op2 < 0x50 then do
          let c ← Cond.ofCc? (op2 - 0x40)
          let reg ← regOf g R
          let rm ← o.rm?
          pure (.item (.cmov c wd reg rm), r)
        else if 0x90 ≤ op2 ∧ op2 < 0xa0 then do
          let c ← Cond.ofCc? (op2 - 0x90)
          match o with
          | .reg d => pure (.item (if d = .rcx then .setccCl c else .setccR c d), r)
          | .mem m => pure (.item (.setcc c m), r)
          | .rip _ => none
        else do
          let reg ← regOf g R
          let m ← o.mem?
          pure (.item (.ld (if op2 = 0xb6 ∨ op2 = 0xbe then .b else .w)
            (op2 == 0xbe || op2 == 0xbf) reg m), r)
    else do
      let (g, o, r) ← decModrm X r
      if op < 0x40 ∧ (op % 8 = 2 ∨ op % 8 = 3) then do
        let aop ← Alu.ofNum? (op / 8)
        let reg ← regOf g R
        let rm ← o.rm?
        pure (.item (.alu aop (if op % 8 = 2 then .b else wd) reg rm), r)
      else if op = 0x31 then do
        let d ← o.reg?
        pure (.item (.setReg d 0), r)
      else if op = 0x01 then pure (.item .addRaxRcx, r)
      else if op = 0x84 then pure (.item .testAl, r)
      else if op = 0x85 then pure (.item .testRax, r)
      else if op = 0x88 then do
        let reg ← regOf g R
        let m ← o.mem?
        pure (.item (.st .b reg m), r)
      else if op = 0x89 then do
        let reg ← regOf g R
        match o with
        | .reg d => pure (.item (.mov d reg), r)
        | .mem m => pure (.item (.st wd reg m), r)
        | .rip _ => none
      else if op = 0x8b then do
        let reg ← regOf g R
        match o with
        | .mem m => pure (.item (.ld wd false reg m), r)
        | .rip d => pure (.ref (.loadRip reg) (tgt d), r)
        | .reg _ => none
      else if op = 0x8d then do
        let reg ← regOf g R
        match o with
        | .mem m =>
          if reg = .rsp ∨ reg = .rbp then none
          else pure (.item (.leaM reg m), r)
        | .rip d => pure (.ref (.lea reg) (tgt d), r)
        | .reg _ => none
      else if op = 0xc6 then do
        let m ← o.mem?
        let (v, r) ← rd8 r
        pure (.item (.stImm .b m v), r)
      else if op = 0xc7 then
        match o with
        | .mem m => do let (v, r) ← rdW wd r; pure (.item (.stImm wd m v), r)
        | .reg d => do let (v, r) ← rd32 r; pure (.item (.setReg d (v.signExtend 64)), r)
        | .rip _ => none
      else if op = 0x80 ∨ op = 0x81 ∨ op = 0x83 then do
        let aop ← Alu.ofNum? g
        let rm ← o.rm?
        let w := if op = 0x80 then .b else wd
        let (v, r) ← if op = 0x81 then rdW w r else rd8 r
        pure (.item (fixRsp (.aluImm aop w rm v)), r)
      else if op = 0x69 ∨ op = 0x6b then do
        let reg ← regOf g R
        let rm ← o.rm?
        let (v, r) ← if op = 0x69 then rd32 r else rd8 r
        pure (.item (.imulImm wd reg rm v), r)
      else if op = 0xc1 then do
        let sh ← Sh.ofNum? g
        let reg ← o.reg?
        let (amt, r) ← rdB r
        pure (.item (.shift sh wd reg amt), r)
      else if op = 0xd2 ∨ op = 0xd3 then do
        let sh ← Sh.ofNum? g
        let reg ← o.reg?
        pure (.item (.shiftCl sh (if op = 0xd2 then .b else wd) reg), r)
      else if op = 0xf6 then do
        let m ← o.mem?
        match r with
        | 0xff :: r => pure (.item (.testM8 m), r)
        | _ => none
      else if op = 0xf7 then do
        let rm ← o.rm?
        pure (.item (if g = 6 ∨ g = 7 then .div (g == 7) wd rm else .mulQ rm), r)
      else if op = 0xff then
        match o with
        | .reg b =>
          if g = 2 then pure (.item .callRax, r)
          else if b = .r11 then pure (.item .jmpR11, r)
          else if bW then pure (.item .jmpRaxW, r) else pure (.item .jmpRax, r)
        | .mem m =>
          if m.base = .rax then pure (.item .callMemRax, r)
          else pure (.item (.callR11 (m.disp.setWidth 8)), r)
        | .rip d => if g = 2 then pure (.ref .callMem (tgt d), r) else pure (.ref .ctrInc (tgt d), r)
      else none

def movdDec (x : Bool) (op : Nat) (r : List Nat) : Option (Key × List Nat) := do
  let (g, o, r) ← decModrm x r
  let d ← o.reg?
  pure (.item (.movd (op = 0x6e) g d), r)

def dec66 (a : BitVec 64) : List Nat → Option (Key × List Nat)
  | [] => none
  | b :: r =>
    if b = 0x90 then some (.item (.nop 2), r)
    else if b = 0x0f then
      match r with
      | 0x1f :: 0x44 :: _ :: _ :: r => some (.item (.nop 6), r)
      | 0x1f :: 0x84 :: _ :: _ :: _ :: _ :: _ :: r => some (.item (.nop 9), r)
      | op :: r => if op = 0x6e ∨ op = 0x7e then movdDec false op r else none
      | [] => none
    else if b = 0x41 then
      match r with
      | 0x0f :: op :: r => movdDec true op r
      | _ => native a 2 true b r
    else if 0x40 ≤ b ∧ b < 0x50 then native a 2 true b r
    else native a 1 true 0 (b :: r)

def dec0f (a : BitVec 64) (p : BitVec 32) : List Nat → Option (Key × List Nat)
  | [] => none
  | op :: r =>
    if op = 0x1f then
      match r with
      | 0x00 :: r => some (.item (.nop 3), r)
      | 0x40 :: _ :: r => some (.item (.nop 4), r)
      | 0x44 :: _ :: _ :: r => some (.item (.nop 5), r)
      | 0x80 :: _ :: _ :: _ :: _ :: r => some (.item (.nop 7), r)
      | 0x84 :: _ :: _ :: _ :: _ :: _ :: r => some (.item (.nop 8), r)
      | _ => none
    else if op = 0x0b then some (.item .ud2, r)
    else if 0x80 ≤ op ∧ op < 0x90 then do
      let c ← Cond.ofCc? (op - 0x80)
      let (d, r) ← rd32 r
      pure (.item (.branch c (d + (p + 6)) true), r)
    else if op = 0x10 ∨ op = 0x11 then do
      let (g, o, r) ← decModrm false r
      let m ← o.mem?
      pure (.item (.sse (op == 0x11) 16 g m), r)
    else native a 0 false 0 (0x0f :: op :: r)

/-- Reads one canonical item at address `a`, function position `p`. -/
def dec (a : BitVec 64) (p : BitVec 32) : List Nat → Option (Key × List Nat)
  | [] => none
  | b :: r =>
    if 0x40 ≤ b ∧ b < 0x50 then native a 1 false b r
    else if b = 0x66 then dec66 a r
    else if b = 0x55 then some (.item .pushRbp, r)
    else if b = 0x5d then some (.item .popRbp, r)
    else if b = 0x90 then some (.item (.nop 1), r)
    else if b = 0xcc then some (.item .int3, r)
    else if b = 0xc9 then some (.item .leave, r)
    else if b = 0xc3 then some (.item .ret, r)
    else if b = 0xe8 then (rd32 r).map fun (d, r) => (.ref .call (d + low32 (a + 5)), r)
    else if b = 0xe9 then (rd32 r).map fun (d, r) => (.ref .jmp (d + low32 (a + 5)), r)
    else if b = 0xeb then (rd8 r).map fun (d, r) => (.item (.branch .always (d + (p + 2)) false), r)
    else if 0x70 ≤ b ∧ b < 0x80 then do
      let c ← Cond.ofCc? (b - 0x70)
      let (d, r) ← rd8 r
      pure (.item (.branch c (d + (p + 2)) false), r)
    else if b = 0xf3 ∨ b = 0xf2 then
      match r with
      | 0x0f :: op :: r => do
        let (g, o, r) ← decModrm false r
        let m ← o.mem?
        pure (.item (.sse (op == 0x11) (if b = 0xf3 then 4 else 8) g m), r)
      | _ => none
    else if b = 0x0f then dec0f a p r
    else native a 0 false 0 (b :: r)

/-! ### Linked bytes -/

theorem linkedAt_plain (ctx : Ctx) (i : Item) (pos : Nat)
    (h : (i.encode (BitVec.ofNat 32 pos)).2 = []) :
    i.linkedAt ctx pos = (i.encode (BitVec.ofNat 32 pos)).1 := by
  unfold Item.linkedAt
  rcases hE : i.encode (BitVec.ofNat 32 pos) with ⟨bs, rs⟩
  rw [hE] at h; subst h; simp only [hE]; rfl

theorem link_one (addr : BitVec 64) (f : RefAddr) (pre : List UInt8) (to : Ref) :
    link addr f (pre ++ [0, 0, 0, 0]) [⟨pre.length, to⟩] =
      pre ++ leBytes (f to - (addr + BitVec.ofNat 64 (pre.length + 4))) 4 := by
  simp only [link, List.foldl_cons, List.foldl_nil]
  apply List.ext_getElem
  · simp [leBytes]
  · intro j h1 h2
    simp only [List.getElem_map, List.getElem_range]
    simp only [List.length_append, List.length_cons, List.length_nil, List.length_map,
      List.length_range] at h1
    by_cases hj : j < pre.length
    · rw [ite_eq_right (by omega), List.getElem_append_left hj, List.getD_eq_getElem?_getD,
        List.getElem?_append_left hj, List.getElem?_eq_getElem hj]
      rfl
    · rw [ite_eq_left (by omega), List.getElem_append_right (by omega)]
      simp only [List.getD_eq_getElem?_getD]
      rw [List.getElem?_eq_getElem (by simp [leBytes]; omega)]
      rfl

theorem linkedAt_ref (ctx : Ctx) (i : Item) (pos : Nat) (pre : List UInt8) (to : Ref)
    (h : i.encode (BitVec.ofNat 32 pos) =
      (pre ++ [0, 0, 0, 0], [⟨(BitVec.ofNat 32 pos).toNat + pre.length, to⟩])) :
    i.linkedAt ctx pos =
      pre ++ leBytes (ctx.addrOf to - (addrAt ctx pos + BitVec.ofNat 64 (pre.length + 4))) 4 := by
  unfold Item.linkedAt
  simp only [h, List.map_cons, List.map_nil, Nat.add_sub_cancel_left]
  exact link_one _ _ _ _

/-! ### Keys -/

/-- What `dec` returns for item `i`: a reference field's target as its low 32 bits, a long
`jmp` and `leaTable` as references to their in-function targets. -/
def keyOf (ctx : Ctx) : Item → Key
  | .call to => .ref .call (low32 (ctx.addrOf to))
  | .callMem to => .ref .callMem (low32 (ctx.addrOf to))
  | .jmp to => .ref .jmp (low32 (ctx.addrOf to))
  | .ctrInc lp => .ref .ctrInc (low32 (ctx.addrOf (if lp then .recordLoopCtr else .record)))
  | .lea r to => .ref (.lea r) (low32 (ctx.addrOf to))
  | .loadRip r to => .ref (.loadRip r) (low32 (ctx.addrOf to))
  | .leaTable t => .ref (.lea .rcx) (t + low32 ctx.base)
  | .branch c t l =>
    if c = .always ∧ l = true then .ref .jmp (t + low32 ctx.base) else .item (.branch c t l)
  | i => .item i

/-- What `dec` needs of an item at position `pos`. -/
def Ok (pos : BitVec 32) : Item → Prop
  | .tableEntry .. => False
  | .branch _ t l => l = false → fitsSigned 8 (t - (pos + 2)) = true
  | .nop n => 1 ≤ n ∧ n ≤ 9
  | .ld w sx _ _ => w = .b ∨ w = .w ∨ sx = false
  | .stImm w _ imm => (w = .b → fitsSigned 8 imm = true) ∧ (w = .w → fitsSigned 16 imm = true)
  | .leaM dst _ => dst ≠ .rsp ∧ dst ≠ .rbp
  | .aluImm _ w rm imm =>
    rm ≠ .reg .rsp ∧ (w = .b → fitsSigned 8 imm = true) ∧ (w = .w → fitsSigned 16 imm = true)
  | .imul w _ _ | .imulImm w _ _ _ | .shift _ w _ _ => w = .d ∨ w = .q
  | .setcc c _ | .setccCl c => c ≠ .always
  | .div _ w _ | .cdq w | .bsf w _ _ | .bsr w _ _ | .bswap w _ => w = .d ∨ w = .q
  | .cmov c w _ _ => c ≠ .always ∧ (w = .d ∨ w = .q)
  | .setccR c r => c ≠ .always ∧ r ≠ .rcx
  | .sse _ size x m => (size = 4 ∨ size = 8 ∨ size = 16) ∧ x < 8 ∧ (m.base = .rbp ∨ m.base = .rsp)
  | .movd _ x _ => x < 8
  | _ => True

abbrev decAt (ctx : Ctx) (pos : Nat) := dec (addrAt ctx pos) (BitVec.ofNat 32 pos)

theorem fam_nop (ctx : Ctx) (pos : Nat) (rest : List Nat) (n : Nat) (h : Ok (BitVec.ofNat 32 pos) (.nop n)) :
    decAt ctx pos (((Item.nop n).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.nop n), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  obtain ⟨h1, h2⟩ := h
  match n, h1, h2 with
  | 1, _, _ | 2, _, _ | 3, _, _ | 4, _, _ | 5, _, _ | 6, _, _ | 7, _, _ | 8, _, _ | 9, _, _ =>
    simp [decAt, Item.encode, dec, dec0f, dec66, keyOf, nops]

theorem fam_setccCl (ctx : Ctx) (pos : Nat) (rest : List Nat) (c : Cond) (h : Ok (BitVec.ofNat 32 pos) (.setccCl c)) :
    decAt ctx pos (((Item.setccCl c).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.setccCl c), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  cases c <;> simp_all [decAt, Item.encode, dec, dec0f, keyOf, Cond.cc, Cond.cc?, native, decModrm, Cond.ofCc?, Ok, byte, regOf, Reg.ofNum?]

theorem low32_sub (x y : BitVec 64) : (x - y).setWidth 32 + low32 y = low32 x := by
  simp only [low32]; bv_omega

theorem fam_call (ctx : Ctx) (pos : Nat) (rest : List Nat) (to : Ref) :
    decAt ctx pos (((Item.call to).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.call to), rest) := by
  rw [linkedAt_ref ctx _ pos [0xe8] to rfl]
  simp [decAt, dec, keyOf, rd32_le, low32_sub]

/-! ### Prefixes -/

/-- `Item.rex?` from its parts. -/
def rexOf (w : Bool) (reg : Option Reg) (rm : Rm) (isByte : Bool) : Option UInt8 :=
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

def RexOk (w R X : Bool) (pre : List UInt8) (k pl : Nat) : Prop :=
  pre.map UInt8.toNat = (if pl = 1 then [k] else []) ∧ (pl = 0 → k = 0) ∧
    (pl = 1 → 0x40 ≤ k ∧ k < 0x50) ∧ pl ≤ 1 ∧
    (k / 8 % 2 == 1) = w ∧ (k / 4 % 2 == 1) = R ∧ (k % 2 == 1) = X

/-- `rexOf` through the bits it reads. -/
def rexB (w : Bool) (hasR rE rS : Bool) (isReg bE bS : Bool) (isByte : Bool) : Option UInt8 :=
    let b := fun (c : Bool) => if c then 1 else 0
    let (rexR, needR) := if hasR then (b rE <<< 2, isByte && !rE && rS) else (0, false)
    let (rexB, needB) := if isReg then (b bE, isByte && !bE && bS) else (b bE, false)
    let rex := 0x40 ||| (b w <<< 3) ||| rexR ||| rexB
    if rex != 0x40 || needR || needB then some (byte rex) else none

theorem rexB_spec : ∀ w hasR rE rS isReg bE bS isByte : Bool,
    RexOk w (hasR && rE) bE (((rexB w hasR rE rS isReg bE bS isByte).map ([·])).getD [])
      (((rexB w hasR rE rS isReg bE bS isByte).map UInt8.toNat).getD 0)
      (((rexB w hasR rE rS isReg bE bS isByte).map fun _ => 1).getD 0) := by
  unfold RexOk rexB; decide

def rexK (w : Bool) (reg : Option Reg) (rm : Rm) (isB : Bool) : Nat :=
  ((rexOf w reg rm isB).map UInt8.toNat).getD 0

def rexPl (w : Bool) (reg : Option Reg) (rm : Rm) (isB : Bool) : Nat :=
  ((rexOf w reg rm isB).map fun _ => 1).getD 0

theorem rexOf_spec (w : Bool) (reg : Option Reg) (rm : Rm) (isB : Bool) :
    RexOk w ((reg.map Reg.ext).getD false) (rmExt rm) (((rexOf w reg rm isB).map ([·])).getD [])
      (rexK w reg rm isB) (rexPl w reg rm isB) := by
  rcases reg with _ | r <;> rcases rm with r2 | m
  · exact rexB_spec w false false false true r2.ext (r2.low ≥ 4) isB
  · exact rexB_spec w false false false false m.base.ext false isB
  · exact rexB_spec w true r.ext (r.low ≥ 4) true r2.ext (r2.low ≥ 4) isB
  · exact rexB_spec w true r.ext (r.low ≥ 4) false m.base.ext false isB

theorem dec_rex (a : BitVec 64) (p : BitVec 32) (k : Nat) (t : List Nat) (h1 : 0x40 ≤ k) (h2 : k < 0x50) :
    dec a p (k :: t) = native a 1 false k t := by
  simp [dec, h1, h2]

theorem dec_66rex (a : BitVec 64) (p : BitVec 32) (k op : Nat) (t : List Nat) (h1 : 0x40 ≤ k) (h2 : k < 0x50)
    (hop : op ≠ 0x0f) :
    dec a p (0x66 :: k :: op :: t) = native a 2 true k (op :: t) := by
  have : k ≠ 0x90 := by omega
  have : k ≠ 0x0f := by omega
  by_cases h41 : k = 0x41
  · subst h41; simp [dec, dec66, hop]
  · simp [dec, dec66, h1, h2, h41, *]

def ops66 : List Nat := [0x89, 0xc7, 0x81, 0x83, 0x02, 0x03, 0x0a, 0x0b, 0x22, 0x23, 0x2a, 0x2b, 0x32,
  0x33, 0x3a, 0x3b, 0xd3]

theorem dec_66 (a : BitVec 64) (p : BitVec 32) (op : Nat) (t : List Nat) (hop : op ∈ ops66) :
    dec a p (0x66 :: op :: t) = native a 1 true 0 (op :: t) := by
  simp only [ops66, List.mem_cons, List.not_mem_nil, or_false] at hop
  rcases hop with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> simp [dec, dec66]

def ops0 : List Nat := [0x88, 0x89, 0x8b, 0x8d, 0xc6, 0xc7, 0x80, 0x81, 0x83, 0x69, 0x6b, 0xc1, 0xf6,
  0xf7, 0x02, 0x03, 0x0a, 0x0b, 0x22, 0x23, 0x2a, 0x2b, 0x32, 0x33, 0x3a, 0x3b, 0xd2, 0xd3, 0x99]

theorem dec_0 (a : BitVec 64) (p : BitVec 32) (op : Nat) (t : List Nat) (hop : op ∈ ops0) :
    dec a p (op :: t) = native a 0 false 0 (op :: t) := by
  simp only [ops0, List.mem_cons, List.not_mem_nil, or_false] at hop
  rcases hop with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;>
    simp [dec]

def ops0f : List Nat := [0xb6, 0xb7, 0xbe, 0xbf, 0xaf, 0xbc, 0xbd] ++
  (List.range 16).map (0x90 + ·) ++ (List.range 16).map (0x40 + ·) ++ (List.range 8).map (0xc8 + ·)

theorem dec_0f (a : BitVec 64) (p : BitVec 32) (op : Nat) (t : List Nat) (hop : op ∈ ops0f) :
    dec a p (0x0f :: op :: t) = native a 0 false 0 (0x0f :: op :: t) := by
  have key : ∀ o ∈ ops0f, o ≠ 0x1f ∧ o ≠ 0x0b ∧ ¬(0x80 ≤ o ∧ o < 0x90) ∧ o ≠ 0x10 ∧ o ≠ 0x11 := by
    decide
  have h1 := key op hop
  simp [dec, dec0f, h1]

theorem dec_nat0 {w R X : Bool} {pre : List UInt8} {k pl : Nat} (hR : RexOk w R X pre k pl)
    (a : BitVec 64) (p : BitVec 32) (op : Nat) (t : List Nat) (hop : op ∈ ops0) :
    dec a p (pre.map UInt8.toNat ++ op :: t) = native a pl false k (op :: t) := by
  obtain ⟨hpre, h0, h1, hpl, -⟩ := hR
  rw [hpre]
  rcases (by omega : pl = 0 ∨ pl = 1) with rfl | rfl
  · rw [h0 rfl]; exact dec_0 a p op t hop
  · obtain ⟨h1, h2⟩ := h1 rfl
    exact dec_rex a p k _ h1 h2

theorem dec_nat0f {w R X : Bool} {pre : List UInt8} {k pl : Nat} (hR : RexOk w R X pre k pl)
    (a : BitVec 64) (p : BitVec 32) (op : Nat) (t : List Nat) (hop : op ∈ ops0f) :
    dec a p (pre.map UInt8.toNat ++ 0x0f :: op :: t) = native a pl false k (0x0f :: op :: t) := by
  obtain ⟨hpre, h0, h1, hpl, -⟩ := hR
  rw [hpre]
  rcases (by omega : pl = 0 ∨ pl = 1) with rfl | rfl
  · rw [h0 rfl]; exact dec_0f a p op t hop
  · obtain ⟨h1, h2⟩ := h1 rfl
    exact dec_rex a p k _ h1 h2

theorem dec_nat66 {w R X : Bool} {pre : List UInt8} {k pl : Nat} (hR : RexOk w R X pre k pl)
    (a : BitVec 64) (p : BitVec 32) (op : Nat) (t : List Nat) (hop : op ∈ ops66) :
    dec a p (0x66 :: (pre.map UInt8.toNat ++ op :: t)) = native a (pl + 1) true k (op :: t) := by
  obtain ⟨hpre, h0, h1, hpl, -⟩ := hR
  rw [hpre]
  rcases (by omega : pl = 0 ∨ pl = 1) with rfl | rfl
  · rw [h0 rfl]; exact dec_66 a p op t hop
  · obtain ⟨h1, h2⟩ := h1 rfl
    have : op ≠ 0x0f := by
      simp only [ops66, List.mem_cons, List.not_mem_nil, or_false] at hop; omega
    exact dec_66rex a p k op t h1 h2 this

theorem decModrm_rm' (rm : Rm) (r : Reg) (rest : List Nat) :
    decModrm (rmExt rm) ((rm.write r.low).map UInt8.toNat ++ rest) = some (r.low, opnd rm, rest) :=
  decModrm_rm rm r.low (low_lt r) rest

/-! ### Native items -/

theorem rd8n (v : BitVec 32) (h : fitsSigned 8 v = true) (r : List Nat) :
    rd8 (v.toNat % 256 :: r) = some (v, r) := by
  have := rd8_byte v h r
  simpa [byte] using this

theorem rd8_le1 (v : BitVec 32) (h : fitsSigned 8 v = true) (r : List Nat) :
    rd8 ((leBytes v 1).map UInt8.toNat ++ r) = some (v, r) := by
  simpa [leBytes] using rd8n v h r

theorem rdBn (v : BitVec 8) (r : List Nat) : rdB (v.toNat % 256 :: r) = some (v, r) := by
  simp only [rdB, Option.some.injEq, Prod.mk.injEq, and_true]
  apply BitVec.eq_of_toNat_eq; simp; omega

theorem decModrm_m (m : M) (g : Nat) (hg : g < 8) (rest : List Nat) :
    decModrm m.base.ext ((m.write g).map UInt8.toNat ++ rest) = some (g, .mem m, rest) :=
  decModrm_rm (.mem m) g hg rest

theorem decModrm_m' (m : M) (r : Reg) (rest : List Nat) :
    decModrm m.base.ext ((m.write r.low).map UInt8.toNat ++ rest) = some (r.low, .mem m, rest) :=
  decModrm_rm (.mem m) r.low (low_lt r) rest

theorem rmExt_mem (m : M) : rmExt (.mem m) = m.base.ext := rfl

theorem fits8_imm8 (v : BitVec 32) : fitsSigned 8 v = imm8 v := rfl

theorem alu_num_lt (op : Alu) : op.num < 8 := by cases op <;> decide
theorem sh_num_lt (op : Sh) : op.num < 8 := by cases op <;> decide

theorem fixRsp_ne (op : Alu) (w : W) (rm : Rm) (v : BitVec 32) (h : rm ≠ .reg .rsp) :
    fixRsp (.aluImm op w rm v) = .aluImm op w rm v := by
  simp [fixRsp, h]

set_option hygiene false in
/-- Puts the prefixes of a native item in `RexOk` form: `rexsetup w reg rm isB` after
`have e : i.rex? = rexOf w reg rm isB := rfl`. -/
macro "rexsetup" w:term:max reg:term:max rm:term:max isB:term:max : tactic => `(tactic| (
  rw [linkedAt_plain _ _ _ rfl]
  have hR := rexOf_spec $w $reg $rm $isB
  generalize rexK $w $reg $rm $isB = k at hR
  generalize rexPl $w $reg $rm $isB = pl at hR
  simp only [Item.encode, Item.prefixes, e]
  generalize ((rexOf $w $reg $rm $isB).map ([·])).getD [] = pre at hR ⊢
  have hX := hR.2.2.2.2.2.2
  have hRr := hR.2.2.2.2.2.1
  have hW := hR.2.2.2.2.1
  simp only [Option.map, Option.getD, rmExt_mem] at hRr hX))

macro "prep" loc:(Lean.Parser.Tactic.location)? : tactic => `(tactic| simp only [Item.w16, List.map_append, List.append_assoc,
  List.map_cons, List.map_nil, List.cons_append, List.singleton_append, List.nil_append, byte,
  UInt8.toNat_ofNat', Nat.reduceShiftLeft, Nat.reduceOr, Nat.reduceMod, Nat.reducePow, Alu.num,
  Sh.num, ite_true, ite_false, beq_self_eq_true, reduceCtorEq, decAt, UInt8.reduceToNat,
  beq_iff_eq, ↓reduceIte, Bool.false_eq_true, W.imm, W.immLen, Bool.true_eq_false,
  Bool.or_false, Bool.or_true, Bool.false_or, Bool.true_or] $[$loc]?)

set_option hygiene false in
macro "pre_dec" : tactic => `(tactic| first
  | rw [dec_nat0 hR _ _ _ _ (by decide)]
  | rw [dec_nat0f hR _ _ _ _ (by decide)]
  | rw [dec_nat66 hR _ _ _ _ (by decide)])

theorem fam_ld (ctx : Ctx) (pos : Nat) (rest : List Nat) (w : W) (sx : Bool) (dst : Reg) (m : M)
    (h : Ok (BitVec.ofNat 32 pos) (.ld w sx dst m)) :
    decAt ctx pos (((Item.ld w sx dst m).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.ld w sx dst m), rest) := by
  have e : (Item.ld w sx dst m).rex? = rexOf (w == .q) (some dst) (.mem m) false := rfl
  rexsetup (w == .q) (some dst) (.mem m) false
  simp only [Ok] at h
  cases w <;> cases sx <;> simp at h <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_m', regOf_reg, keyOf, Opnd.mem?]

theorem fam_st (ctx : Ctx) (pos : Nat) (rest : List Nat) (w : W) (src : Reg) (m : M) :
    decAt ctx pos (((Item.st w src m).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.st w src m), rest) := by
  have e : (Item.st w src m).rex? = rexOf (w == .q) (some src) (.mem m) (w == .b) := rfl
  rexsetup (w == .q) (some src) (.mem m) (w == .b)
  cases w <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_m', regOf_reg, keyOf, Opnd.mem?]

theorem fam_stImm (ctx : Ctx) (pos : Nat) (rest : List Nat) (w : W) (m : M) (imm : BitVec 32)
    (h : Ok (BitVec.ofNat 32 pos) (.stImm w m imm)) :
    decAt ctx pos (((Item.stImm w m imm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.stImm w m imm), rest) := by
  have e : (Item.stImm w m imm).rex? = rexOf (w == .q) none (.mem m) false := rfl
  rexsetup (w == .q) none (.mem m) false
  simp only [Ok] at h
  cases w <;> simp at h <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_m _ 0 (by decide), regOf_reg, keyOf, Opnd.mem?, rdW,
      rd8_le1, rd16_le, rd32_le, h]

theorem fam_leaM (ctx : Ctx) (pos : Nat) (rest : List Nat) (dst : Reg) (m : M)
    (h : Ok (BitVec.ofNat 32 pos) (.leaM dst m)) :
    decAt ctx pos (((Item.leaM dst m).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.leaM dst m), rest) := by
  have e : (Item.leaM dst m).rex? = rexOf true (some dst) (.mem m) false := rfl
  rexsetup true (some dst) (.mem m) false
  simp only [Ok] at h
  prep; pre_dec
  simp [native, hX, hRr, hW, decModrm_m', regOf_reg, keyOf, Opnd.mem?, h]

theorem fam_aluImm (ctx : Ctx) (pos : Nat) (rest : List Nat) (op : Alu) (w : W) (rm : Rm)
    (imm : BitVec 32) (h : Ok (BitVec.ofNat 32 pos) (.aluImm op w rm imm)) :
    decAt ctx pos (((Item.aluImm op w rm imm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.aluImm op w rm imm), rest) := by
  have e : (Item.aluImm op w rm imm).rex? = rexOf (w == .q) none rm (w == .b) := rfl
  rexsetup (w == .q) none rm (w == .b)
  simp only [Ok] at h
  obtain ⟨hrsp, h8, h16⟩ := h
  by_cases hi : imm8 imm = true <;>
  cases w <;> simp [fits8_imm8] at h8 h16 <;> simp only [hi] <;> prep <;> pre_dec <;>
    cases op <;>
    simp [native, hX, hW, decModrm_rm, regOf_reg, keyOf, rdW, rd8n, rd16_le, rd32_le, fixRsp_ne,
      opnd_rm, Alu.ofNum?, Alu.num, fits8_imm8, h8, h16, hi, hrsp]

theorem fam_imul (ctx : Ctx) (pos : Nat) (rest : List Nat) (w : W) (reg : Reg) (rm : Rm)
    (h : Ok (BitVec.ofNat 32 pos) (.imul w reg rm)) :
    decAt ctx pos (((Item.imul w reg rm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.imul w reg rm), rest) := by
  have e : (Item.imul w reg rm).rex? = rexOf (w == .q) (some reg) rm false := rfl
  rexsetup (w == .q) (some reg) rm false
  simp only [Ok] at h
  cases w <;> simp at h <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_rm', regOf_reg, keyOf, opnd_rm]

theorem fam_imulImm (ctx : Ctx) (pos : Nat) (rest : List Nat) (w : W) (reg : Reg) (rm : Rm)
    (imm : BitVec 32) (h : Ok (BitVec.ofNat 32 pos) (.imulImm w reg rm imm)) :
    decAt ctx pos (((Item.imulImm w reg rm imm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.imulImm w reg rm imm), rest) := by
  have e : (Item.imulImm w reg rm imm).rex? = rexOf (w == .q) (some reg) rm false := rfl
  rexsetup (w == .q) (some reg) rm false
  simp only [Ok] at h
  by_cases hi : imm8 imm = true <;>
  cases w <;> simp at h <;> simp only [hi] <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_rm', regOf_reg, keyOf, opnd_rm, rd8n, rd32_le, fits8_imm8, hi]

theorem fam_shift (ctx : Ctx) (pos : Nat) (rest : List Nat) (op : Sh) (w : W) (reg : Reg)
    (amt : BitVec 8) (h : Ok (BitVec.ofNat 32 pos) (.shift op w reg amt)) :
    decAt ctx pos (((Item.shift op w reg amt).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.shift op w reg amt), rest) := by
  have e : (Item.shift op w reg amt).rex? = rexOf (w == .q) none (.reg reg) false := rfl
  rexsetup (w == .q) none (.reg reg) false
  simp only [Ok] at h
  have hd := decModrm_rm (.reg reg) op.num (sh_num_lt op) (amt.toNat % 256 :: rest)
  simp only [Rm.write, rmExt, opnd] at hd hX
  cases w <;> simp at h <;> prep <;> pre_dec <;> cases op <;>
  · prep at hd
    simp [native, hX, hd, regOf_reg, keyOf, rdBn, Sh.ofNum?, Opnd.reg?]
    all_goals (simp only [show ∀ a b : W, (a == b) = decide (a = b) from fun _ _ => rfl] at hW
               simp at hW; omega)

theorem fam_setcc (ctx : Ctx) (pos : Nat) (rest : List Nat) (c : Cond) (m : M)
    (h : Ok (BitVec.ofNat 32 pos) (.setcc c m)) :
    decAt ctx pos (((Item.setcc c m).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.setcc c m), rest) := by
  have e : (Item.setcc c m).rex? = rexOf false none (.mem m) false := rfl
  rexsetup false none (.mem m) false
  simp only [Ok] at h
  cases c <;> simp at h <;> simp only [Cond.cc, Cond.cc?, Option.getD] <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_m _ 0 (by decide), keyOf, Cond.ofCc?]

theorem fam_testM8 (ctx : Ctx) (pos : Nat) (rest : List Nat) (m : M) :
    decAt ctx pos (((Item.testM8 m).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.testM8 m), rest) := by
  have e : (Item.testM8 m).rex? = rexOf false none (.mem m) false := rfl
  rexsetup false none (.mem m) false
  prep; pre_dec
  simp [native, hX, hRr, hW, decModrm_m _ 0 (by decide), keyOf, Opnd.mem?]

theorem fam_mulQ (ctx : Ctx) (pos : Nat) (rest : List Nat) (rm : Rm) :
    decAt ctx pos (((Item.mulQ rm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.mulQ rm), rest) := by
  have e : (Item.mulQ rm).rex? = rexOf true none rm false := rfl
  rexsetup true none rm false
  prep; pre_dec
  simp [native, hX, hRr, hW, decModrm_rm rm 4 (by decide), keyOf, opnd_rm]

theorem fam_alu (ctx : Ctx) (pos : Nat) (rest : List Nat) (op : Alu) (w : W) (reg : Reg) (rm : Rm) :
    decAt ctx pos (((Item.alu op w reg rm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.alu op w reg rm), rest) := by
  have e : (Item.alu op w reg rm).rex? = rexOf (w == .q) (some reg) rm (w == .b) := rfl
  rexsetup (w == .q) (some reg) rm (w == .b)
  cases w <;> cases op <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_rm', regOf_reg, opnd_rm, Alu.ofNum?, keyOf]

theorem fam_shiftCl (ctx : Ctx) (pos : Nat) (rest : List Nat) (op : Sh) (w : W) (reg : Reg) :
    decAt ctx pos (((Item.shiftCl op w reg).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.shiftCl op w reg), rest) := by
  have e : (Item.shiftCl op w reg).rex? = rexOf (w == .q) none (.reg reg) (w == .b) := rfl
  rexsetup (w == .q) none (.reg reg) (w == .b)
  have hd := decModrm_rm (.reg reg) op.num (sh_num_lt op) rest
  simp only [Rm.write, rmExt, opnd] at hd hX
  cases w <;> prep <;> pre_dec <;> cases op <;>
  · prep at hd
    simp [native, hX, hd, regOf_reg, keyOf, Sh.ofNum?, Opnd.reg?]
    all_goals (simp only [show ∀ a b : W, (a == b) = decide (a = b) from fun _ _ => rfl] at hW
               simp at hW; omega)

theorem fam_div (ctx : Ctx) (pos : Nat) (rest : List Nat) (sg : Bool) (w : W) (rm : Rm)
    (h : Ok (BitVec.ofNat 32 pos) (.div sg w rm)) :
    decAt ctx pos (((Item.div sg w rm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.div sg w rm), rest) := by
  have e : (Item.div sg w rm).rex? = rexOf (w == .q) none rm false := rfl
  rexsetup (w == .q) none rm false
  simp only [Ok] at h
  cases sg <;> cases w <;> simp at h <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_rm rm 6 (by decide), decModrm_rm rm 7 (by decide), keyOf,
      opnd_rm]

theorem fam_bsf (ctx : Ctx) (pos : Nat) (rest : List Nat) (lz : Bool) (w : W) (reg : Reg) (rm : Rm)
    (h : Ok (BitVec.ofNat 32 pos) (if lz then .bsr w reg rm else .bsf w reg rm)) :
    decAt ctx pos (((if lz then Item.bsr w reg rm else .bsf w reg rm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (if lz then .bsr w reg rm else .bsf w reg rm), rest) := by
  have e : (if lz then Item.bsr w reg rm else .bsf w reg rm).rex? = rexOf (w == .q) (some reg) rm false := by
    cases lz <;> rfl
  rw [linkedAt_plain _ _ _ (by cases lz <;> rfl)]
  have hR := rexOf_spec (w == .q) (some reg) rm false
  generalize rexK (w == .q) (some reg) rm false = k at hR
  generalize rexPl (w == .q) (some reg) rm false = pl at hR
  have he : ∀ i : Item, i = (if lz then Item.bsr w reg rm else .bsf w reg rm) →
      (i.encode (BitVec.ofNat 32 pos)).1 = i.prefixes ++ [0x0f, if lz then 0xbd else 0xbc] ++ rm.write reg.low := by
    intro i hi; subst hi; cases lz <;> rfl
  rw [he _ rfl]
  simp only [Item.prefixes, e]
  generalize ((rexOf (w == .q) (some reg) rm false).map ([·])).getD [] = pre at hR ⊢
  have hX := hR.2.2.2.2.2.2
  have hRr := hR.2.2.2.2.2.1
  have hW := hR.2.2.2.2.1
  simp only [Option.map, Option.getD, rmExt_mem] at hRr hX
  simp only [Ok] at h
  cases lz <;> cases w <;> simp at h <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_rm', regOf_reg, keyOf, opnd_rm]

theorem fam_cmov (ctx : Ctx) (pos : Nat) (rest : List Nat) (c : Cond) (w : W) (reg : Reg) (rm : Rm)
    (h : Ok (BitVec.ofNat 32 pos) (.cmov c w reg rm)) :
    decAt ctx pos (((Item.cmov c w reg rm).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.cmov c w reg rm), rest) := by
  have e : (Item.cmov c w reg rm).rex? = rexOf (w == .q) (some reg) rm false := rfl
  rexsetup (w == .q) (some reg) rm false
  simp only [Ok] at h
  obtain ⟨hc, hw⟩ := h
  rcases hw with rfl | rfl <;> cases c <;> simp at hc <;>
    simp only [Cond.cc, Cond.cc?, Option.getD] <;> prep <;> pre_dec <;>
    simp [native, hX, hRr, hW, decModrm_rm', regOf_reg, keyOf, opnd_rm, Cond.ofCc?]

theorem fam_setccR (ctx : Ctx) (pos : Nat) (rest : List Nat) (c : Cond) (r : Reg)
    (h : Ok (BitVec.ofNat 32 pos) (.setccR c r)) :
    decAt ctx pos (((Item.setccR c r).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.setccR c r), rest) := by
  have e : (Item.setccR c r).rex? = rexOf false none (.reg r) true := rfl
  rexsetup false none (.reg r) true
  simp only [Ok] at h
  obtain ⟨hc, hr⟩ := h
  have hd := decModrm_rm (.reg r) 0 (by decide) rest
  simp only [Rm.write, rmExt, opnd] at hd hX
  cases c <;> simp at hc <;> simp only [Cond.cc, Cond.cc?, Option.getD] <;> prep <;> pre_dec <;>
  · prep at hd
    simp [native, hX, hd, keyOf, Cond.ofCc?, hr]

theorem fam_cdq (ctx : Ctx) (pos : Nat) (rest : List Nat) (w : W)
    (h : Ok (BitVec.ofNat 32 pos) (.cdq w)) :
    decAt ctx pos (((Item.cdq w).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.cdq w), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  simp only [Ok] at h
  rcases h with rfl | rfl <;> simp [decAt, Item.encode, dec, native, keyOf]

theorem fam_bswap (ctx : Ctx) (pos : Nat) (rest : List Nat) (w : W) (r : Reg)
    (h : Ok (BitVec.ofNat 32 pos) (.bswap w r)) :
    decAt ctx pos (((Item.bswap w r).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.bswap w r), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  simp only [Ok] at h
  rcases h with rfl | rfl <;> cases r <;>
    simp [decAt, Item.encode, Item.prefixes, Item.rex?, Item.w16, dec, dec0f, native, regOf,
      Reg.ofNum?, keyOf, byte, Reg.low, Reg.num, Reg.ext]

/-! ### Other items -/

macro "fixed" : tactic => `(tactic| (
  rw [linkedAt_plain _ _ _ rfl]
  simp [decAt, Item.encode, dec, dec0f, dec66, native, decModrm, regOf, Reg.ofNum?, keyOf,
    Opnd.mem?, Opnd.rm?, Opnd.reg?, rd8, rd32, Reg.ext, Reg.low, Reg.num, byte]))

theorem fam_fixed (ctx : Ctx) (pos : Nat) (rest : List Nat) (i : Item)
    (hi : i = .pushRbp ∨ i = .popRbp ∨ i = .jmpR11 ∨ i = .callRax ∨ i = .callMemRax ∨
      i = .jmpRax ∨ i = .jmpRaxW ∨ i = .testAl ∨ i = .testRax ∨ i = .leave ∨ i = .ret ∨
      i = .ud2 ∨ i = .loadTableEntry ∨ i = .addRaxRcx ∨ i = .int3) :
    decAt ctx pos ((i.linkedAt ctx pos).map UInt8.toNat ++ rest) = some (keyOf ctx i, rest) := by
  rcases hi with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl <;> fixed

theorem fam_callR11 (ctx : Ctx) (pos : Nat) (rest : List Nat) (d : BitVec 8) :
    decAt ctx pos (((Item.callR11 d).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.callR11 d), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  simp [decAt, Item.encode, dec, native, decModrm, regOf, Reg.ofNum?, keyOf, rd8, byte]
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_setWidth, BitVec.toNat_signExtend]
  have := d.isLt
  split <;> simp <;> omega

theorem setForm_spec (v : BitVec 64) :
    (setForm v = 0 → v = 0) ∧ (setForm v = 1 → (v.setWidth 32).setWidth 64 = v) ∧
      (setForm v = 2 → (v.setWidth 32).signExtend 64 = v) := by
  unfold setForm
  refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩
  · split at h
    · rename_i hh; simpa using hh
    · split at h <;> (try split at h) <;> simp at h
  · split at h; · simp at h
    split at h
    · apply BitVec.eq_of_toNat_eq
      simp only [BitVec.toNat_setWidth]
      omega
    · split at h <;> simp at h
  · split at h; · simp at h
    split at h; · simp at h
    split at h
    · rename_i hh; simpa [fitsSigned] using hh
    · simp at h

theorem fam_setReg (ctx : Ctx) (pos : Nat) (rest : List Nat) (r : Reg) (v : BitVec 64) :
    decAt ctx pos (((Item.setReg r v).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.setReg r v), rest) := by
  rw [linkedAt_plain _ _ _ (by simp only [Item.encode]; split <;> rfl)]
  obtain ⟨h0, h1, h2⟩ := setForm_spec v
  simp only [Item.encode]
  rcases hf : setForm v with _ | _ | _ | n
  · rw [h0 hf]
    cases r <;> simp only [Reg.ext, Reg.low, Reg.num, byte] <;> simp [decAt, dec, native, decModrm, regOf, Reg.ofNum?, keyOf, byte, Opnd.reg?]
  · cases r <;> simp only [Reg.ext, Reg.low, Reg.num, byte] <;> simp [decAt, dec, native, decModrm, regOf, Reg.ofNum?, keyOf, byte, rd32_le, h1 hf]
  · cases r <;> simp only [Reg.ext, Reg.low, Reg.num, byte] <;> simp [decAt, dec, native, decModrm, regOf, Reg.ofNum?, keyOf, byte, rd32_le, h2 hf]
  · cases r <;> simp only [Reg.ext, Reg.low, Reg.num, byte] <;> simp [decAt, dec, native, decModrm, regOf, Reg.ofNum?, keyOf, byte, rd64_le]

theorem fam_subRsp (ctx : Ctx) (pos : Nat) (rest : List Nat) (v : BitVec 32) (sub : Bool) :
    decAt ctx pos ((((if sub then Item.subRsp v else .addRsp v)).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (if sub then Item.subRsp v else .addRsp v), rest) := by
  rw [linkedAt_plain _ _ _ (by cases sub <;> simp [Item.encode] <;> split <;> rfl)]
  by_cases hv : v.toNat < 128
  · have h8 : fitsSigned 8 v = true := by
      simp only [fitsSigned, beq_iff_eq]
      apply BitVec.eq_of_toNat_eq
      rw [BitVec.toNat_signExtend]
      simp [BitVec.msb_eq_decide]
      rw [ite_eq_right (by omega)]
      omega
    cases sub <;> simp [decAt, Item.encode, hv, dec, native, decModrm, regOf, Reg.ofNum?, keyOf,
      byte, rd8n, h8, Alu.ofNum?, Opnd.rm?, fixRsp]
  · cases sub <;> simp [decAt, Item.encode, hv, dec, native, decModrm, regOf, Reg.ofNum?, keyOf,
      byte, rdW, rd32_le, Alu.ofNum?, Opnd.rm?, fixRsp]

theorem fam_mov (ctx : Ctx) (pos : Nat) (rest : List Nat) (d r : Reg) :
    decAt ctx pos (((Item.mov d r).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.mov d r), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  cases d <;> cases r <;> simp only [Item.encode, Reg.ext, Reg.low, Reg.num, byte] <;>
    simp [decAt, dec, native, decModrm, regOf, Reg.ofNum?, keyOf]

theorem fam_jmp (ctx : Ctx) (pos : Nat) (rest : List Nat) (to : Ref) :
    decAt ctx pos (((Item.jmp to).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.jmp to), rest) := by
  rw [linkedAt_ref ctx _ pos [0xe9] to rfl]
  simp [decAt, dec, keyOf, rd32_le, low32_sub]

theorem fam_callMem (ctx : Ctx) (pos : Nat) (rest : List Nat) (to : Ref) :
    decAt ctx pos (((Item.callMem to).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.callMem to), rest) := by
  rw [linkedAt_ref ctx _ pos [0xff, 0x15] to rfl]
  simp [decAt, dec, native, decModrm, keyOf, rd32_le, low32_sub]

theorem fam_ctrInc (ctx : Ctx) (pos : Nat) (rest : List Nat) (lp : Bool) :
    decAt ctx pos (((Item.ctrInc lp).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.ctrInc lp), rest) := by
  rw [linkedAt_ref ctx _ pos [0x48, 0xff, 0x05] _ rfl]
  simp [decAt, dec, native, decModrm, keyOf, rd32_le, low32_sub]

theorem fam_loadRip (ctx : Ctx) (pos : Nat) (rest : List Nat) (r : Reg) (to : Ref) :
    decAt ctx pos (((Item.loadRip r to).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.loadRip r to), rest) := by
  rw [linkedAt_ref ctx _ pos [byte (0x48 ||| (if r.ext then 1 else 0) <<< 2), 0x8b,
    byte (0x05 ||| r.low <<< 3)] to rfl]
  cases r <;> simp only [Reg.ext, Reg.low, Reg.num, byte] <;>
    simp [decAt, dec, keyOf, rd32_le, low32_sub, native, decModrm, regOf, Reg.ofNum?]

theorem fam_lea (ctx : Ctx) (pos : Nat) (rest : List Nat) (r : Reg) (to : Ref) :
    decAt ctx pos (((Item.lea r to).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.lea r to), rest) := by
  rw [linkedAt_ref ctx _ pos [byte (0x48 ||| (if r.ext then 1 else 0) <<< 2), 0x8d,
    byte (0x05 ||| r.low <<< 3)] to rfl]
  cases r <;> simp only [Reg.ext, Reg.low, Reg.num, byte] <;>
    simp [decAt, dec, keyOf, rd32_le, low32_sub, native, decModrm, regOf, Reg.ofNum?]

theorem low32_ofNat (n : Nat) : low32 (BitVec.ofNat 64 n) = BitVec.ofNat 32 n := by
  apply BitVec.eq_of_toNat_eq
  simp only [low32, BitVec.toNat_setWidth, BitVec.toNat_ofNat]
  exact Nat.mod_mod_of_dvd n (by decide)

theorem rel_target (base : BitVec 64) (pos n : Nat) (t : BitVec 32) :
    (t - (BitVec.ofNat 32 pos + BitVec.ofNat 32 n)) +
      low32 (base + BitVec.ofNat 64 pos + BitVec.ofNat 64 n) = t + low32 base := by
  rw [← low32_ofNat pos, ← low32_ofNat n]
  simp only [low32]
  generalize BitVec.ofNat 64 pos = P
  generalize BitVec.ofNat 64 n = N
  bv_omega

theorem fam_leaTable (ctx : Ctx) (pos : Nat) (rest : List Nat) (t : BitVec 32) :
    decAt ctx pos (((Item.leaTable t).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.leaTable t), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  have := rel_target ctx.base pos 7 t
  simp [decAt, Item.encode, dec, native, decModrm, regOf, Reg.ofNum?, keyOf, rd32_le, addrAt]
  exact this

theorem fam_branch (ctx : Ctx) (pos : Nat) (rest : List Nat) (c : Cond) (t : BitVec 32) (l : Bool)
    (h : Ok (BitVec.ofNat 32 pos) (.branch c t l)) :
    decAt ctx pos (((Item.branch c t l).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.branch c t l), rest) := by
  rw [linkedAt_plain _ _ _ (by simp only [Item.encode]; split <;> (try split) <;> rfl)]
  simp only [Ok] at h
  cases l
  · have h8 := h rfl
    simp only [Item.encode, Bool.false_eq_true, ↓reduceIte]
    generalize hd : t - (BitVec.ofNat 32 pos + 2) = d at h8 ⊢
    have ht : d + (BitVec.ofNat 32 pos + 2) = t := by rw [← hd]; exact BitVec.sub_add_cancel _ _
    cases c <;> simp [decAt, dec, keyOf, Cond.cc, Cond.cc?, Cond.ofCc?, byte, rd8n d h8] <;> exact ht
  · have := rel_target ctx.base pos 5 t
    cases c <;> simp [decAt, Item.encode, dec, dec0f, keyOf, Cond.cc, Cond.cc?, Cond.ofCc?, byte,
      rd32_le, addrAt, this, BitVec.sub_add_cancel]

theorem fam_sse (ctx : Ctx) (pos : Nat) (rest : List Nat) (st : Bool) (size x : Nat) (m : M)
    (h : Ok (BitVec.ofNat 32 pos) (.sse st size x m)) :
    decAt ctx pos (((Item.sse st size x m).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.sse st size x m), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  simp only [Ok] at h
  obtain ⟨hs, hx, hb⟩ := h
  have hd := decModrm_m m x hx rest
  have he : m.base.ext = false := by rcases hb with hb | hb <;> rw [hb] <;> rfl
  rw [he] at hd
  rcases hs with rfl | rfl | rfl <;> cases st <;>
    simp [decAt, Item.encode, dec, dec0f, keyOf, hd, Opnd.mem?]

theorem fam_movd (ctx : Ctx) (pos : Nat) (rest : List Nat) (toX : Bool) (x : Nat) (r : Reg)
    (h : Ok (BitVec.ofNat 32 pos) (.movd toX x r)) :
    decAt ctx pos (((Item.movd toX x r).linkedAt ctx pos).map UInt8.toNat ++ rest) =
      some (keyOf ctx (.movd toX x r), rest) := by
  rw [linkedAt_plain _ _ _ rfl]
  simp only [Ok] at h
  have hd := decModrm_rm (.reg r) x h rest
  simp only [Rm.write, rmExt, opnd, List.map_cons, List.map_nil, List.cons_append,
    List.nil_append] at hd
  cases he : r.ext <;> rw [he] at hd <;> cases toX <;>
    simp [decAt, Item.encode, dec, dec66, keyOf, hd, he, movdDec, Opnd.reg?]

/-! ### Every canonical item decodes -/

theorem ok_of_wf (p : BitVec 32) (i : Item) (hw : i.wf p = true)
    (ht : ∀ b e, i ≠ .tableEntry b e) : Ok p i := by
  cases i
  case branch c t l => cases l <;> simp_all [Item.wf, Ok]
  case stImm w m imm => cases w <;> simp_all [Item.wf, Ok]
  case aluImm op w rm imm =>
    cases w <;> rcases rm with r | m <;> simp_all [Item.wf, Ok, Item.rmWf, Item.memWf, Reg.usable]
  case imul w reg rm => cases w <;> simp_all [Item.wf, Ok]
  case imulImm w reg rm imm => cases w <;> simp_all [Item.wf, Ok]
  case shift op w reg amt => cases w <;> simp_all [Item.wf, Ok]
  case bswap w reg => cases w <;> simp_all [Item.wf, Ok]
  all_goals simp_all [Item.wf, Ok, Item.rmWf, Item.memWf, Reg.usable, or_assoc]

theorem ok_of_spFrame (p : BitVec 32) (j : Item) (f : BitVec 32) (hw : j.wf p = true)
    (ht : ∀ b e, j ≠ .tableEntry b e) : Ok p (j.spFrame f) := by
  have := ok_of_wf p j hw ht
  cases j
  case aluImm op w rm imm =>
    rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case sse st size x m =>
    simp_all [Item.spFrame, Item.mapMem, Ok, Item.wf]
  case alu op w reg rm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case imul w reg rm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case imulImm w reg rm imm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case mulQ rm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case div sg w rm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case bsf w reg rm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case bsr w reg rm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  case cmov c w reg rm => rcases rm with r | m <;> simp_all [Item.spFrame, Item.mapMem, Ok]
  all_goals simp_all [Item.spFrame, Item.mapMem, Ok]

theorem dec_linked (ctx : Ctx) (pos : Nat) (rest : List Nat) (i : Item)
    (h : Ok (BitVec.ofNat 32 pos) i) :
    decAt ctx pos ((i.linkedAt ctx pos).map UInt8.toNat ++ rest) = some (keyOf ctx i, rest) := by
  cases i
  case tableEntry => exact h.elim
  case subRsp v => simpa using fam_subRsp ctx pos rest v true
  case addRsp v => simpa using fam_subRsp ctx pos rest v false
  case setReg r v => exact fam_setReg ctx pos rest r v
  case lea r to => exact fam_lea ctx pos rest r to
  case leaTable t => exact fam_leaTable ctx pos rest t
  case mov d r => exact fam_mov ctx pos rest d r
  case call to => exact fam_call ctx pos rest to
  case callMem to => exact fam_callMem ctx pos rest to
  case ctrInc lp => exact fam_ctrInc ctx pos rest lp
  case callR11 d => exact fam_callR11 ctx pos rest d
  case loadRip r to => exact fam_loadRip ctx pos rest r to
  case jmp to => exact fam_jmp ctx pos rest to
  case branch c t l => exact fam_branch ctx pos rest c t l h
  case nop n => exact fam_nop ctx pos rest n h
  case ld w sx d m => exact fam_ld ctx pos rest w sx d m h
  case st w r m => exact fam_st ctx pos rest w r m
  case stImm w m imm => exact fam_stImm ctx pos rest w m imm h
  case leaM d m => exact fam_leaM ctx pos rest d m h
  case alu op w r rm => exact fam_alu ctx pos rest op w r rm
  case aluImm op w rm imm => exact fam_aluImm ctx pos rest op w rm imm h
  case imul w r rm => exact fam_imul ctx pos rest w r rm h
  case imulImm w r rm imm => exact fam_imulImm ctx pos rest w r rm imm h
  case shift op w r amt => exact fam_shift ctx pos rest op w r amt h
  case setcc c m => exact fam_setcc ctx pos rest c m h
  case testM8 m => exact fam_testM8 ctx pos rest m
  case setccCl c => exact fam_setccCl ctx pos rest c h
  case mulQ rm => exact fam_mulQ ctx pos rest rm
  case shiftCl op w r => exact fam_shiftCl ctx pos rest op w r
  case div sg w rm => exact fam_div ctx pos rest sg w rm h
  case cdq w => exact fam_cdq ctx pos rest w h
  case bsf w r rm => exact fam_bsf ctx pos rest false w r rm h
  case bsr w r rm => exact fam_bsf ctx pos rest true w r rm h
  case cmov c w r rm => exact fam_cmov ctx pos rest c w r rm h
  case setccR c r => exact fam_setccR ctx pos rest c r h
  case bswap w r => exact fam_bswap ctx pos rest w r h
  case sse st size x m => exact fam_sse ctx pos rest st size x m h
  case movd t x r => exact fam_movd ctx pos rest t x r h
  all_goals exact fam_fixed ctx pos rest _ (by simp)

end Uniq

/-! ### Keys determine execution -/

/-- Every reference lies in the 4 GiB from the function's address up: what makes a linked
`rel32` field, which keeps 32 bits of the offset, determine the address `Item.exec` uses (see
the module comment). -/
def RefsNear (ctx : Ctx) : Prop := ∀ r, (ctx.addrOf r - ctx.base).toNat < 2 ^ 32

namespace Uniq

def ctxA (ctx : Ctx) (t : BitVec 32) : Ctx :=
  { ctx with addrOf := fun _ => ctx.base + (t - low32 ctx.base).setWidth 64 }

def rep : RefK → Item
  | .call => .call .probe
  | .callMem => .callMem .probe
  | .jmp => .jmp .probe
  | .ctrInc => .ctrInc false
  | .lea r => .lea r .probe
  | .loadRip r => .loadRip r .probe

def execKey (ctx : Ctx) : Key → State → Except Fault State
  | .item i => i.exec ctx
  | .ref k t => (rep k).exec (ctxA ctx t)

theorem near (x y : BitVec 64) (h : (x - y).toNat < 2 ^ 32) :
    x = y + (low32 x - low32 y).setWidth 64 := by
  have : x - y < 0x100000000#64 := by rw [BitVec.lt_def]; simpa using h
  simp only [low32]
  bv_omega

theorem exec_key (ctx : Ctx) (H : RefsNear ctx) (i : Item) (s : State) :
    i.exec ctx s = execKey ctx (keyOf ctx i) s := by
  have hA : ∀ r, ctx.addrOf r = ctx.base + (low32 (ctx.addrOf r) - low32 ctx.base).setWidth 64 :=
    fun r => near _ _ (H r)
  have hT : ∀ t : BitVec 32, ctx.base + t.setWidth 64 = (ctxA ctx (t + low32 ctx.base)).addrOf .probe := by
    intro t; simp [ctxA, BitVec.add_sub_cancel]
  cases i
  case branch c t l =>
    cases c <;> cases l <;> simp [keyOf, execKey]
    simp only [Item.exec, rep, Cond.eval, ctxA]
    conv => lhs; rw [show ctx.base + t.setWidth 64 = ctx.base + (t + low32 ctx.base - low32 ctx.base).setWidth 64 by simp [BitVec.add_sub_cancel]]
    rfl
  all_goals simp only [keyOf, execKey, rep]
  case lea r to =>
    simp only [Item.exec, ctxA]
    conv => lhs; rw [hA to]
    rfl
  case call to =>
    simp only [Item.exec, ctxA]
    conv => lhs; rw [hA to]
    rfl
  case callMem to =>
    simp only [Item.exec, ctxA]
    conv => lhs; rw [hA to]
    rfl
  case jmp to =>
    simp only [Item.exec, ctxA]
    conv => lhs; rw [hA to]
    rfl
  case loadRip r to =>
    simp only [Item.exec, ctxA]
    conv => lhs; rw [hA to]
    rfl
  case ctrInc lp =>
    simp only [Item.exec, ctxA]
    conv => lhs; rw [hA (if lp then .recordLoopCtr else .record)]
    cases lp <;> rfl
  case leaTable t =>
    simp only [Item.exec]
    conv => lhs; rw [hT t]
    rfl

end Uniq

/-! ### `ExecUnique` -/

namespace Uniq

theorem ok_of_canonical (p : Nat) (i : Item) (hc : i.Canonical p) : Ok (BitVec.ofNat 32 p) i := by
  obtain ⟨ht, hw | ⟨j, f, hw, rfl⟩⟩ := hc
  · exact ok_of_wf _ i hw ht
  · have hjt : ∀ b e, j ≠ .tableEntry b e := by rintro b e rfl; exact ht b e rfl
    exact ok_of_spFrame _ j f hw hjt

theorem canonical_congr {p q : Nat} (h : BitVec.ofNat 32 p = BitVec.ofNat 32 q) (i : Item) :
    i.Canonical p ↔ i.Canonical q := by
  simp only [Item.Canonical, h]

theorem linkedAt_congr (ctx : Ctx) {p q : Nat} (h1 : addrAt ctx p = addrAt ctx q)
    (h2 : BitVec.ofNat 32 p = BitVec.ofNat 32 q) (i : Item) : i.linkedAt ctx p = i.linkedAt ctx q := by
  unfold Item.linkedAt; rw [h1, h2]

theorem prefix_of_bytesAt {m : Mem} {a : BitVec 64} {l1 l2 : List UInt8} (h1 : BytesAt m a l1)
    (h2 : BytesAt m a l2) (hl : l1.length ≤ l2.length) : l2 = l1 ++ l2.drop l1.length := by
  apply List.ext_getElem
  · simp; omega
  · intro k hk _
    by_cases hk1 : k < l1.length
    · rw [List.getElem_append_left hk1, ← h1 k hk1, ← h2 k hk]
    · rw [List.getElem_append_right (by omega)]
      simp only [List.getElem_drop]
      congr 1; omega

theorem key_eq (ctx : Ctx) (m : Mem) (i j : Item) (p : Nat) (hi : Ok (BitVec.ofNat 32 p) i)
    (hj : Ok (BitVec.ofNat 32 p) j) (hbi : ItemAt ctx m i p) (hbj : ItemAt ctx m j p) :
    keyOf ctx i = keyOf ctx j := by
  have key : ∀ i j : Item, Ok (BitVec.ofNat 32 p) i → Ok (BitVec.ofNat 32 p) j → ItemAt ctx m i p →
      ItemAt ctx m j p → (i.linkedAt ctx p).length ≤ (j.linkedAt ctx p).length →
      keyOf ctx i = keyOf ctx j := by
    intro i j hi hj hbi hbj hl
    have he := prefix_of_bytesAt hbi hbj hl
    have d1 := dec_linked ctx p ((j.linkedAt ctx p |>.drop (i.linkedAt ctx p).length).map UInt8.toNat) i hi
    have d2 := dec_linked ctx p [] j hj
    rw [List.append_nil, he, List.map_append, d1] at d2
    simp only [Option.some.injEq, Prod.mk.injEq] at d2
    exact d2.1
  rcases Nat.le_total (i.linkedAt ctx p).length (j.linkedAt ctx p).length with hl | hl
  · exact key i j hi hj hbi hbj hl
  · exact (key j i hj hi hbj hbi hl).symm

end Uniq

/-- Canonical items whose linked bytes are at the same address execute alike, given
`RefsNear`. -/
theorem execUnique (ctx : Ctx) (H : RefsNear ctx) : ExecUnique ctx := by
  intro x i j p q ci cj hi hj ha
  have h32 : BitVec.ofNat 32 p = BitVec.ofNat 32 q := by
    have : BitVec.ofNat 64 p = BitVec.ofNat 64 q := by
      simpa [addrAt] using ha
    rw [← Uniq.low32_ofNat, ← Uniq.low32_ofNat, this]
  rw [(Uniq.canonical_congr h32 j).symm] at cj
  unfold ItemAt at hj
  rw [← Uniq.linkedAt_congr ctx ha h32, ← ha] at hj
  have hk := Uniq.key_eq ctx x.mem i j p (Uniq.ok_of_canonical p i ci)
    (Uniq.ok_of_canonical p j cj) hi hj
  rw [Uniq.exec_key ctx H i, Uniq.exec_key ctx H j, hk]

namespace Uniq

theorem leBytes_setWidth (v : BitVec 64) : leBytes v 4 = leBytes (v.setWidth 32) 4 := by
  simp only [leBytes, List.range_succ, List.range_zero, List.nil_append, List.map_cons,
    List.map_nil, List.map_append, BitVec.toNat_setWidth, List.cons.injEq, and_true]
  simp only [List.append_assoc, List.singleton_append, List.cons_append, List.nil_append,
    List.cons.injEq, and_true]
  refine ⟨?_, ?_, ?_, ?_⟩ <;> apply UInt8.toNat.inj <;>
    simp only [UInt8.toNat_ofNat', Nat.shiftRight_eq_div_pow] <;> omega

end Uniq

/-- `RefsNear` is needed: a reference `r` farther away gives `jmp r` the bytes of a long
`branch .always`, which jumps elsewhere. -/
theorem refsNear_of_execUnique (ctx : Ctx) (h : ExecUnique ctx) : RefsNear ctx := by
  intro r
  apply Classical.byContradiction
  intro hr
  let t : BitVec 32 := Uniq.low32 (ctx.addrOf r - ctx.base)
  have hl : (Item.jmp r).linkedAt ctx 0 = (Item.branch .always t true).linkedAt ctx 0 := by
    rw [Uniq.linkedAt_ref ctx _ 0 [0xe9] r rfl, Uniq.linkedAt_plain _ _ _ rfl]
    simp only [Item.encode, List.length_cons, List.length_nil]
    rw [Uniq.leBytes_setWidth]
    congr 2
    simp only [t, Uniq.low32, addrAt]
    bv_omega
  let L := (Item.jmp r).linkedAt ctx 0
  let x : State := { (default : State) with
    rip := addrAt ctx 0
    mem := fun a => L.getD (a - addrAt ctx 0).toNat 0 }
  have hL : L.length = 5 := by
    simp only [L]; rw [Uniq.linkedAt_ref ctx _ 0 [0xe9] r rfl]; simp [leBytes]
  have hm : ItemAt ctx x.mem (.jmp r) 0 := by
    intro j hj
    simp only [x]
    rw [show addrAt ctx 0 + BitVec.ofNat 64 j - addrAt ctx 0 = BitVec.ofNat 64 j by bv_omega,
      BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by have : j < 5 := hL ▸ hj; omega)]
    simp [L, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hj]
  have hm' : ItemAt ctx x.mem (.branch .always t true) 0 := by
    unfold ItemAt; rw [← hl]; exact hm
  have he := h x _ _ 0 0 ⟨by intros; simp, .inl rfl⟩ ⟨by intros; simp, .inl rfl⟩ hm hm' rfl
  have h1 := congrArg (fun r => match r with | .ok s => s.rip | .error _ => 0) he
  simp only [Item.exec, pure, Except.pure, Cond.eval, State.jump, bind, Except.bind] at h1
  simp only [t, Uniq.low32] at h1
  simp [x] at h1
  apply hr
  have : ctx.addrOf r - ctx.base < 0x100000000#64 := by bv_omega
  rw [BitVec.lt_def] at this
  simpa using this

/-- `ExecUnique` holds exactly when every reference is near (`RefsNear`). -/
theorem execUnique_iff_refsNear (ctx : Ctx) : ExecUnique ctx ↔ RefsNear ctx :=
  ⟨refsNear_of_execUnique ctx, execUnique ctx⟩

/-- `Step` is deterministic, given `RefsNear`. -/
theorem step_deterministic_of_refsNear {ctx : Ctx} (H : RefsNear ctx) : StepDeterministic ctx :=
  step_deterministic (execUnique ctx H)

end Ryo.X86
