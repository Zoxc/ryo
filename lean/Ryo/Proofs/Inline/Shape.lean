/-
Ryo.Proofs.Inline.Shape — the opcodes of each inline class, by their handler and operands.

`shapeOk op c`: `op`'s handler kind and parameters and its operand list are the ones the
proofs of class `c` take (`classHandler`, `classOperands`). The proofs are over every opcode
of that shape; that each opcode of `Asm.inlineOps` has its class's shape is `inlineOps_shape`
(`RyoProofs/InlineOps.lean`, outside the default build since it takes minutes), and is
checked quickly by `RyoTest/Inline.lean`.
-/
import Ryo.Vm.Asm
import Ryo.Vm.OpSem

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Vm Ryo.Vm.Asm Ryo.X86

/-- The handler type of a width, signed or not (`u8`, `i8`, …). -/
def tyName (signed : Bool) : W → String
  | .b => if signed then "i8" else "u8"
  | .w => if signed then "i16" else "u16"
  | .d => if signed then "i32" else "u32"
  | .q => if signed then "i64" else "u64"

/-- The immediate operand's kind at a width. -/
def immKind : W → OperandKind
  | .b => .u8
  | .w => .u16
  | .d => .u32
  | .q => .u64

def aluMethod : Alu → String
  | .add => "wrapping_add"
  | .sub => "wrapping_sub"
  | .and => "&"
  | .or => "|"
  | .xor => "^"
  | .cmp => ""

/-- `add`/`sub` are `bin` handlers, the bit operations `binop` ones. -/
def aluKind (imm : Bool) : Alu → Handlers.HandlerKind
  | .add | .sub => if imm then .bin_imm else .bin
  | _ => if imm then .binop_imm else .binop

def shMethod : Sh → String
  | .shl => "wrapping_shl"
  | _ => "wrapping_shr"

/-- A condition's comparison operator and signedness. -/
def condOp : Cond → String × Bool
  | .z => ("==", false)
  | .nz => ("!=", false)
  | .l => ("<", true)
  | .b => ("<", false)
  | .le => ("<=", true)
  | .be => ("<=", false)
  | .g => (">", true)
  | .a => (">", false)
  | .ge => (">=", true)
  | .ae => (">=", false)
  | _ => ("", false)

def cmpParams (c : Cond) (w : W) : List String := [tyName (condOp c).2 w, (condOp c).1]

/-- The handler kind and parameters of the opcodes of a class. -/
def classHandler : Class → Handlers.HandlerKind × List String
  | .mov w => (.mov, [tyName false w])
  | .mov128 => (.mov, ["u128"])
  | .imm w => (.imm, [tyName false w])
  | .addr => (.addr, [])
  | .addrConst => (.addr_const, [])
  | .addrSym => (.addr_sym, ["false"])
  | .addrSymInd => (.addr_sym, ["true"])
  | .ptrAdd => (.ptr_add, [])
  | .ptrIndex => (.ptr_index, [])
  | .load w => (.load, [tyName false w])
  | .store w => (.store, [tyName false w])
  | .bin op w => (aluKind false op, [tyName false w, aluMethod op])
  | .binImm op w => (aluKind true op, [tyName false w, aluMethod op])
  | .mul w => (.bin, [tyName false w, "wrapping_mul"])
  | .mulImm w => (.bin_imm, [tyName false w, "wrapping_mul"])
  | .shiftImm sh w => (.shift_imm, [tyName (sh == .sar) w, shMethod sh])
  | .cmp c w => (.cmp, cmpParams c w)
  | .cmpImm c w => (.cmp_imm, cmpParams c w)
  | .br => (.br, [])
  | .brCmp c w => (.br_cmp, cmpParams c w)
  | .brCmpImm c w => (.br_cmp_imm, cmpParams c w)
  | .ovf op sg w => (.ovf, [tyName sg w, if op == .add then "overflowing_add" else "overflowing_sub"])
  | .mulOvf sg w => (.ovf, [tyName sg w, "overflowing_mul"])
  | .ext a b sx => (.cvt, [tyName sx a, tyName sx b])

/-- The operands of the opcodes of a class. -/
def classOperands : Class → List OperandInfo
  | .mov _ | .mov128 | .addr | .ext .. => [⟨"d", .slot⟩, ⟨"s", .slot⟩]
  | .addrConst => [⟨"d", .slot⟩, ⟨"a", .abs⟩]
  | .addrSym | .addrSymInd => [⟨"d", .slot⟩, ⟨"sym", .sym⟩]
  | .imm w => [⟨"d", .slot⟩, ⟨"imm", (immKind w)⟩]
  | .ptrAdd => [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"imm", .i64⟩]
  | .ptrIndex => [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"i", .slot⟩, ⟨"stride", .u32⟩]
  | .load _ => [⟨"d", .slot⟩, ⟨"m", .mem⟩]
  | .store _ => [⟨"m", .mem⟩, ⟨"s", .slot⟩]
  | .bin .. | .mul _ | .cmp .. => [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩]
  | .binImm _ w | .mulImm w | .shiftImm _ w | .cmpImm _ w =>
    [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", (immKind w)⟩]
  | .br => [⟨"s", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩]
  | .brCmp .. => [⟨"a", .slot⟩, ⟨"b", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩]
  | .brCmpImm _ w => [⟨"a", .slot⟩, ⟨"imm", (immKind w)⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩]
  | .ovf .. | .mulOvf .. => [⟨"d", .slot⟩, ⟨"o", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩]

/-- `op` is of the shape the proofs of class `c` take. -/
def shapeOk (op : Full.Opcode) (c : Class) : Bool :=
  (op.handler?.map fun h => (h.kind, h.params)) == some (classHandler c) && op.info.operands == classOperands c

theorem shapeOk_spec {op : Full.Opcode} {c : Class} (h : shapeOk op c = true) :
    (∃ r, op.handler? = some ⟨(classHandler c).1, (classHandler c).2, r⟩) ∧
      op.info.operands = classOperands c := by
  simp only [shapeOk, Bool.and_eq_true, beq_iff_eq] at h
  obtain ⟨h1, h2⟩ := h
  refine ⟨?_, h2⟩
  cases hh : op.handler? with
  | none => simp [hh] at h1
  | some hi =>
    simp only [hh, Option.map_some, Option.some.injEq] at h1
    exact ⟨hi.ret, by rw [← h1]⟩

end Ryo.Proofs.Inline
