/-
Ryo.Proofs.CacheEmitRanges — the destination and flag ranges are among the footprint's write
ranges (`wranges_out` per class `wo_*`, `wranges_flag`), so every frame write of a sequence lies
in one (`sequence_writes_in`).
-/
import Ryo.Proofs.CacheEmitFrame

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

theorem tySize_tyName (sg : Bool) (w : W) : tySize (tyName sg w) = some (wbytes w) :=
  tySize_of_parse (Later.tyName_parse' sg w)

theorem fpBinFn {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .bin_fn (ty :: ps) =
      some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" n] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

theorem fpCount {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .count (ty :: ps) = some { reads := [rdA "a" n], writes := [rdA "d" 4] } := by
  simp only [footprintOf, List.head?, Option.bind_some, h] <;> rfl

theorem fpAddrSym (s : String) : ∃ de,
    footprintOf .addr_sym [s] = some ⟨[], [rdA "d" 8], [], de, .next⟩ :=
  ⟨_, rfl⟩

/-- The destination operand's value: the slot's offset. -/
theorem vals_d {ρ : R.Addrs} {f : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {rest : List OperandInfo} {s : BitVec 32} (ho : f.info.operands = ⟨"d", .slot⟩ :: rest)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    opndVal f.info vals "d" = some (.slot s.toInt) := by
  rcases ops with _ | ⟨o0, os⟩
  · simp at h0
  simp only [List.getElem?_cons_zero, Option.some.injEq] at h0
  subst h0
  unfold nativeVals at hn
  rw [ho] at hn
  split at hn
  · simp only [List.zip_cons_cons, List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.pure_def, Option.some.injEq] at hn
    obtain ⟨v0, h0', vs, -, rfl⟩ := hn
    obtain ⟨s', hs', rfl⟩ := nv_slot.1 h0'
    cases hs'
    simp [opndVal, ho]
  · cases hn

/-- The flag operand's value (`ovf`, `mul.ovf`). -/
theorem vals_o {ρ : R.Addrs} {f : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {rest : List OperandInfo} {s : BitVec 32}
    (ho : f.info.operands = ⟨"d", .slot⟩ :: ⟨"o", .slot⟩ :: rest)
    (hn : nativeVals ρ f ops = some vals) (h1 : ops[1]? = some (.slot s)) :
    opndVal f.info vals "o" = some (.slot s.toInt) := by
  rcases ops with _ | ⟨o0, _ | ⟨o1, os⟩⟩
  · simp at h1
  · simp at h1
  simp only [List.getElem?_cons_succ, List.getElem?_cons_zero, Option.some.injEq] at h1
  subst h1
  unfold nativeVals at hn
  rw [ho] at hn
  split at hn
  · simp only [List.zip_cons_cons, List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.pure_def, Option.some.injEq] at hn
    obtain ⟨v0, -, vs, ⟨v1, h1', vs', -, rfl⟩, rfl⟩ := hn
    obtain ⟨s', hs', rfl⟩ := nv_slot.1 h1'
    cases hs'
    simp [opndVal, ho]
  · cases hn

theorem wo_mov {ρ : R.Addrs} {f : Full.Opcode} (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.mov w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.mov w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (tySize_tyName _ _)).1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_mov128 {ρ : R.Addrs} {f : Full.Opcode}  {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.mov128) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.mov128)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (ps := []) (ty := "u128") (n := 16) rfl).1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_imm {ρ : R.Addrs} {f : Full.Opcode} (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.imm w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.imm w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (tySize_tyName _ _)).2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_addr {ρ : R.Addrs} {f : Full.Opcode}  {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.addr) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.addr)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fp_addr]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_addrConst {ρ : R.Addrs} {f : Full.Opcode}  {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.addrConst) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.addrConst)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fp_addr_const]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_addrSym {ρ : R.Addrs} {f : Full.Opcode}  {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.addrSym) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.addrSym)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (obtain ⟨de, hde⟩ := fpAddrSym "false"; rw [hde]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_addrSymInd {ρ : R.Addrs} {f : Full.Opcode}  {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.addrSymInd) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.addrSymInd)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (obtain ⟨de, hde⟩ := fpAddrSym "true"; rw [hde]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_ptrAdd {ρ : R.Addrs} {f : Full.Opcode}  {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.ptrAdd) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.ptrAdd)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fp_ptr_add]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_ptrIndex {ρ : R.Addrs} {f : Full.Opcode}  {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.ptrIndex) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.ptrIndex)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fp_ptr_index]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_load {ρ : R.Addrs} {f : Full.Opcode} (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.load w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.load w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_load (tySize_tyName _ _)).1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_bin {ρ : R.Addrs} {f : Full.Opcode} (op : Alu) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.bin op w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.bin op w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  cases op <;> simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (first | rw [(fp_w (tySize_tyName _ _)).2.2.1] | rw [(fp_w (tySize_tyName _ _)).2.2.2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_binImm {ρ : R.Addrs} {f : Full.Opcode} (op : Alu) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.binImm op w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.binImm op w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  cases op <;> simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (first | rw [(fp_w (tySize_tyName _ _)).2.2.2.2.1] | rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_mul {ρ : R.Addrs} {f : Full.Opcode} (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.mul w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.mul w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (tySize_tyName _ _)).2.2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_mulImm {ρ : R.Addrs} {f : Full.Opcode} (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.mulImm w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.mulImm w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (tySize_tyName _ _)).2.2.2.2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_shiftImm {ρ : R.Addrs} {f : Full.Opcode} (sh : Sh) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.shiftImm sh w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.shiftImm sh w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_cmp {ρ : R.Addrs} {f : Full.Opcode} (c : Cond) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.cmp c w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.cmp c w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_cmpImm {ρ : R.Addrs} {f : Full.Opcode} (c : Cond) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.cmpImm c w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.cmpImm c w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [(fp_w (tySize_tyName _ _)).2.2.2.2.2.2.2.2.1]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_ovf {ρ : R.Addrs} {f : Full.Opcode} (op : Alu) (sg : Bool) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.ovf op sg w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.ovf op sg w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fp_ovf (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_mulOvf {ρ : R.Addrs} {f : Full.Opcode} (sg : Bool) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.mulOvf sg w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.mulOvf sg w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fp_ovf (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_ext {ρ : R.Addrs} {f : Full.Opcode} (src : W) (dst : W) (sx : Bool) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.ext src dst sx) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.ext src dst sx)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fp_cvt (tySize_tyName _ _) (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_shiftVar {ρ : R.Addrs} {f : Full.Opcode} (sh : Sh) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.shiftVar sh w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.shiftVar sh w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  cases sh <;> simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (first | rw [Later.fp_shift (tySize_tyName _ _)] | rw [Later.fp_rot (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_div {ρ : R.Addrs} {f : Full.Opcode} (sg : Bool) (rem : Bool) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.div sg rem w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.div sg rem w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fpBinFn (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_count {ρ : R.Addrs} {f : Full.Opcode} (lz : Bool) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.count lz w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.count lz w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [fpCount (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_cmp3 {ρ : R.Addrs} {f : Full.Opcode} (sg : Bool) (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.cmp3 sg w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.cmp3 sg w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [Later.fp_cmp3 (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

theorem wo_bswap {ρ : R.Addrs} {f : Full.Opcode} (w : W) {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f (.bswap w) = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s)) :
    (s.toInt, outSize (.bswap w)) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands, aluKind, cmpParams, Bool.false_eq_true, Bool.true_eq_false,
    ↓reduceIte] at hh ho <;>
    (unfold wranges; rw [footprint_eq hh]; dsimp only) <;>
    (rw [Later.fp_un (tySize_tyName _ _)]) <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨_, List.mem_cons_self .., by simp [Access.range, vals_d ho hn h0, Val.slotOff, Extent.eval, outSize]⟩

/-- A class's destination range `(d, outSize cls)` is among the write ranges. -/
theorem wranges_out {ρ : R.Addrs} {f : Full.Opcode} {cls : Class} {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f cls = true)
    (hn : nativeVals ρ f ops = some vals) (h0 : ops[0]? = some (.slot s))
    (hpos : 0 < outSize cls) : (s.toInt, outSize cls) ∈ wranges f vals := by
  cases cls with
  | mov w => exact wo_mov w hs hn h0
  | mov128  => exact wo_mov128  hs hn h0
  | imm w => exact wo_imm w hs hn h0
  | addr  => exact wo_addr  hs hn h0
  | addrConst  => exact wo_addrConst  hs hn h0
  | addrSym  => exact wo_addrSym  hs hn h0
  | addrSymInd  => exact wo_addrSymInd  hs hn h0
  | ptrAdd  => exact wo_ptrAdd  hs hn h0
  | ptrIndex  => exact wo_ptrIndex  hs hn h0
  | load w => exact wo_load w hs hn h0
  | store w => exact absurd hpos (by simp [outSize])
  | bin op w => exact wo_bin op w hs hn h0
  | binImm op w => exact wo_binImm op w hs hn h0
  | mul w => exact wo_mul w hs hn h0
  | mulImm w => exact wo_mulImm w hs hn h0
  | shiftImm sh w => exact wo_shiftImm sh w hs hn h0
  | cmp c w => exact wo_cmp c w hs hn h0
  | cmpImm c w => exact wo_cmpImm c w hs hn h0
  | br  => exact absurd hpos (by simp [outSize])
  | brCmp c w => exact absurd hpos (by simp [outSize])
  | brCmpImm c w => exact absurd hpos (by simp [outSize])
  | ovf op sg w => exact wo_ovf op sg w hs hn h0
  | mulOvf sg w => exact wo_mulOvf sg w hs hn h0
  | ext src dst sx => exact wo_ext src dst sx hs hn h0
  | shiftVar sh w => exact wo_shiftVar sh w hs hn h0
  | div sg rem w => exact wo_div sg rem w hs hn h0
  | count lz w => exact wo_count lz w hs hn h0
  | cmp3 sg w => exact wo_cmp3 sg w hs hn h0
  | bswap w => exact wo_bswap w hs hn h0

/-- An overflow class's flag range `(o, 1)` is among the write ranges. -/
theorem wranges_flag {ρ : R.Addrs} {f : Full.Opcode} {cls : Class} {ops : List (R.Opnd Nat)}
    {vals : Operands} {s : BitVec 32} (hs : shapeOk f cls = true)
    (hn : nativeVals ρ f ops = some vals) (h1 : ops[1]? = some (.slot s))
    (hov : isOvf cls = true) : (s.toInt, 1) ∈ wranges f vals := by
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  cases cls <;> simp only [isOvf, Bool.false_eq_true] at hov <;>
    simp only [classHandler, classOperands] at hh ho <;>
    unfold wranges <;> rw [footprint_eq hh] <;> dsimp only <;>
    rw [fp_ovf (tySize_tyName _ _)] <;>
    simp only [Footprint.writeRanges, List.mem_filterMap] <;>
    exact ⟨rdA "o" 1, by simp, by simp [Access.range, vals_o ho hn h1, Val.slotOff, Extent.eval]⟩

/-- (B') Each frame write of a sequence lies in a write range of the opcode's footprint (so
`FrameBounds.writes` puts it in the window). -/
theorem sequence_writes_in {ρ : R.Addrs} {f : Full.Opcode} {cls : Class} {ops : List (R.Opnd Nat)}
    {cand : List Item} {br : Option Cond} {vals : Operands} (hs : shapeOk f cls = true)
    (hseq : sequence cls ops = some (cand, br)) (hn : nativeVals ρ f ops = some vals) :
    ∀ it ∈ cand, ∀ m n, writeOf it = some (m, n) → m.base = .rbp →
      ∃ r ∈ wranges f vals, r.1 ≤ m.disp.toInt ∧ m.disp.toInt + n ≤ r.1 + r.2 := by
  intro it hit m n hw hb
  rcases sequence_frame_writes hseq it hit m n hw hb with
    ⟨s, h0, h1, h2, hpos⟩ | ⟨s, h1, hm, hn1, hov⟩
  · exact ⟨_, wranges_out hs hn h0 hpos, h1, h2⟩
  · subst hn1
    exact ⟨_, wranges_flag hs hn h1 hov, by rw [hm]; exact Int.le_refl _, by rw [hm]; exact Int.le_refl _⟩

end Ryo.Proofs.CacheStep
