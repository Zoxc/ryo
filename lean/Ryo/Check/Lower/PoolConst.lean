/-
Ryo.Check.Lower.PoolConst — statement rules for constants the backend loads from the constant
pool (aot.md §C1, M5b) and their checker.

`LowerPoolConst Γ st is`, for `_d = const c` into a whole local `_d` (private or escaped: the
lifts write it with `FnRel.write_dst`) whose type is the constant's:
- `ptr`: `c = ptr (alloc g) 0` at a thin pointer type, lowered to one `addr.const $d, k`;
- `slice`: `c = slice g len` at a slice-like pointer type (`metaKind = .elementCount`), lowered
  to `addr.const $d, k` and `imm.w64 $d+8, len` (the backend's `constant.rs`).
In both, `k` is the pool offset of `g`'s copy, `Γ.poolAt g = some k` (check-pool's placement).

**The pool invariant.** The rules only say which pool offset R takes the address of. That
L0's pointer to `g` relates to it is `PoolInv` (`Ryo/Proofs/Lower/SimPoolConst.lean`): for each
`g` with `Γ.poolAt g = some k`, `g` is a constant or vtable of the program, L0's first copy of `g`
(`State.constCopies`) is at the address of `ρ (.const k)` with a provenance `ι` maps to that
pointer's. L0 makes that copy before the start function runs (D7, `instantiateConsts`), and the
simulation picks it at every evaluation (`ReusesAt`, a daemonic choice); check-pool and M6
discharge `PoolInv` at the start, and every non-call step keeps it.

The instruction checks don't use `Γ.ρ`: `addrConstInsnOk` is about the native instruction
(opcode, slot, pool offset), and `view_addrConst` gives its view under any placement that
gives `k` an address. (`CertCheck` runs the checkers with `ρ` giving none.)

Not covered: `indirect` constants (`const $d, k, len`, a copy of the pool bytes), constants at
an offset, statics (`addr.sym`, whose R pointer is the slot's provenance-less value), function
pointers.
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- `i` is the native `addr.const` of pool offset `k` into slot `d`. -/
def addrConstInsnOk (i : Insn) (d : Int) (k : Nat) : Bool :=
  match i with
  | .native op [.slot s, .const k'] =>
    match op.full with
    | some f =>
      f.handler?.map (·.kind) == some .addr_const &&
        f.info.operands == [⟨"d", .slot⟩, ⟨"a", .abs⟩] && f.info.shape == .op &&
        s.toInt == d && k' == k
    | none => false
  | _ => false

theorem addrConstInsnOk_spec {i : Insn} {d : Int} {k : Nat} (h : addrConstInsnOk i d k = true) :
    ∃ op s f, i = .native op [.slot s, .const k] ∧ op.full = some f ∧
      (∃ ps r, f.handler? = some ⟨.addr_const, ps, r⟩) ∧
      f.info.operands = [⟨"d", .slot⟩, ⟨"a", .abs⟩] ∧ f.info.shape = .op ∧ s.toInt = d := by
  unfold addrConstInsnOk at h
  split at h
  · rename_i op s k'
    split at h
    · rename_i f hf
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := h
      subst h5
      refine ⟨op, s, f, rfl, hf, ?_, h2, h3, h4⟩
      cases hh : f.handler? with
      | none => rw [hh] at h1; cases h1
      | some hi =>
        rw [hh] at h1
        obtain ⟨kd, ps, r⟩ := hi
        simp at h1
        subst h1
        exact ⟨ps, r, rfl⟩
    · cases h
  · cases h

/-- The view of a native `addr.const` under a placement giving `k` the address `q`. -/
theorem view_addrConst {mode : Ryo.Obj.Mode} {ρ : Addrs} {op : Reduced.Opcode} {s : BitVec 32}
    {k : Nat} {f : Full.Opcode} {q : ThinPointer} (hf : op.full = some f)
    (ho : f.info.operands = [⟨"d", .slot⟩, ⟨"a", .abs⟩]) (hsh : f.info.shape = .op)
    (hq : ρ (.const k) = some q) :
    view mode ρ (.native op [.slot s, .const k]) =
      some ⟨f, [.slot s.toInt, .addr q], some .next⟩ := by
  have hop : opShape f = true := by unfold opShape; rw [hsh] <;> rfl
  have hc : nativeCtl f [.slot s, .const k] = some .next := by unfold nativeCtl; rw [hsh] <;> rfl
  have h2 : nativeVal ρ .abs (.const k) = some (.addr q) := by
    show Option.map _ (ρ (.const k)) = _
    rw [hq] <;> rfl
  have hvals : (f.info.operands.zip [Opnd.slot s, .const k]).mapM
      (fun (i, o) => nativeVal ρ i.kind o) = some [.slot s.toInt, .addr q] := by
    rw [ho]
    simp only [List.zip_cons_cons, List.zip_nil_left, List.mapM_cons, List.mapM_nil, h2] <;> rfl
  have hlen : (f.info.operands.length != ([Opnd.slot s, .const k] : List (Opnd Nat)).length) =
      false := by rw [ho] <;> rfl
  simp only [view, hf, Option.bind_eq_bind, Option.bind_some, hlen, hvals, hop, hc,
    Bool.false_eq_true, ↓reduceIte] <;> rfl

inductive LowerPoolConst (Γ : StmtCtx) : Statement → List Insn → Prop where
  | ptr {d : Local} {g : GlobalId} {k : Nat} {pt : PtrType} {valid : ValidRange}
      {sd : LocalSlot} {i : Insn}
      (hk : Γ.poolAt g = some k) (htd : Γ.body.locals[d]? = some (.ptr pt valid))
      (hmk : pt.metaKind = .none) (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = 8)
      (hoff : offOk sd.off = true) (hi : addrConstInsnOk i sd.off k = true) :
      LowerPoolConst Γ (.assign ⟨d, []⟩ (.use (.const (.ptr (.alloc g) 0) (.ptr pt valid)))) [i]
  | slice {d : Local} {g : GlobalId} {len k : Nat} {pt : PtrType} {valid : ValidRange}
      {sd : LocalSlot} {i1 i2 : Insn}
      (hk : Γ.poolAt g = some k) (htd : Γ.body.locals[d]? = some (.ptr pt valid))
      (hmk : pt.metaKind = .elementCount) (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = 16)
      (hoff : offOk sd.off = true ∧ offOk (sd.off + 8) = true)
      (hi1 : addrConstInsnOk i1 sd.off k = true)
      (hi2 : immInsnOk Γ i2 8 (sd.off + 8) len = true) :
      LowerPoolConst Γ (.assign ⟨d, []⟩ (.use (.const (.slice g len) (.ptr pt valid)))) [i1, i2]

/-- `ptr`'s facts but the instruction, as one `Bool`. -/
def poolDstOk (Γ : StmtCtx) (d : Local) (pt : PtrType) (valid : ValidRange) (n : Nat)
    (sd : LocalSlot) : Bool :=
  Γ.body.locals[d]? == some (.ptr pt valid) && sd.size == n && offOk sd.off

theorem poolDstOk_spec {Γ : StmtCtx} {d : Local} {pt : PtrType} {valid : ValidRange} {n : Nat}
    {sd : LocalSlot} (h : poolDstOk Γ d pt valid n sd = true) :
    Γ.body.locals[d]? = some (.ptr pt valid) ∧ sd.size = n ∧ offOk sd.off = true := by
  unfold poolDstOk at h
  simp only [Bool.and_eq_true, beq_iff_eq] at h
  exact ⟨h.1.1, h.1.2, h.2⟩

/-- `ptr`'s checker. -/
def checkPoolPtr (Γ : StmtCtx) (d : Local) (g : GlobalId) (pt : PtrType) (valid : ValidRange)
    (is : List Insn) : Verdict :=
  match Γ.poolAt g, Γ.slots[d]?, is with
  | some k, some sd, [i] =>
    if pt.metaKind = .none then
      if poolDstOk Γ d pt valid 8 sd then
        if addrConstInsnOk i sd.off k then .ok else .unsupported "pool ptr: instruction form"
      else .unsupported "pool ptr: destination"
    else .unsupported "pool ptr: wide pointer"
  | none, _, _ => .unsupported "pool const: no placement"
  | _, _, _ => .unsupported "pool ptr: slot or instruction count"

/-- `slice`'s checker. -/
def checkPoolSlice (Γ : StmtCtx) (d : Local) (g : GlobalId) (len : Nat) (pt : PtrType)
    (valid : ValidRange) (is : List Insn) : Verdict :=
  match Γ.poolAt g, Γ.slots[d]?, is with
  | some k, some sd, [i1, i2] =>
    if pt.metaKind = .elementCount then
      if poolDstOk Γ d pt valid 16 sd && offOk (sd.off + 8) then
        if addrConstInsnOk i1 sd.off k && immInsnOk Γ i2 8 (sd.off + 8) len then .ok
        else .unsupported "pool slice: instruction form"
      else .unsupported "pool slice: destination"
    else .unsupported "pool slice: metadata kind"
  | none, _, _ => .unsupported "pool const: no placement"
  | _, _, _ => .unsupported "pool slice: slot or instruction count"

/-- The family's checker: `none` unless the statement is `_d = const c` with `c` a pointer to a
global at offset 0 or a slice constant, at a pointer type. -/
def checkPoolConst (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.use (.const (.ptr (.alloc g) 0) (.ptr pt valid))) =>
    some (checkPoolPtr Γ d g pt valid is)
  | .assign ⟨d, []⟩ (.use (.const (.slice g len) (.ptr pt valid))) =>
    some (checkPoolSlice Γ d g len pt valid is)
  | _ => none

theorem checkPoolPtr_sound {Γ : StmtCtx} {d : Local} {g : GlobalId} {pt : PtrType}
    {valid : ValidRange} {is : List Insn} (h : checkPoolPtr Γ d g pt valid is = .ok) :
    LowerPoolConst Γ (.assign ⟨d, []⟩ (.use (.const (.ptr (.alloc g) 0) (.ptr pt valid)))) is := by
  unfold checkPoolPtr at h
  split at h
  · rename_i k sd i hk hsd
    split at h
    · rename_i hmk
      split at h
      · rename_i hdst
        split at h
        · rename_i hi
          obtain ⟨htd, hsize, hoff⟩ := poolDstOk_spec hdst
          exact .ptr hk htd hmk hsd hsize hoff hi
        · cases h
      · cases h
    · cases h
  · cases h
  · cases h

theorem checkPoolSlice_sound {Γ : StmtCtx} {d : Local} {g : GlobalId} {len : Nat}
    {pt : PtrType} {valid : ValidRange} {is : List Insn}
    (h : checkPoolSlice Γ d g len pt valid is = .ok) :
    LowerPoolConst Γ (.assign ⟨d, []⟩ (.use (.const (.slice g len) (.ptr pt valid)))) is := by
  unfold checkPoolSlice at h
  split at h
  · rename_i k sd i1 i2 hk hsd
    split at h
    · rename_i hmk
      split at h
      · rename_i hdst
        split at h
        · rename_i hi
          simp only [Bool.and_eq_true] at hdst hi
          obtain ⟨htd, hsize, hoff⟩ := poolDstOk_spec hdst.1
          exact .slice hk htd hmk hsd hsize ⟨hoff, hdst.2⟩ hi.1 hi.2
        · cases h
      · cases h
    · cases h
  · cases h
  · cases h

theorem checkPoolConst_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkPoolConst Γ st is = some .ok) : LowerPoolConst Γ st is := by
  unfold checkPoolConst at h
  split at h
  · exact checkPoolPtr_sound (Option.some.inj h)
  · exact checkPoolSlice_sound (Option.some.inj h)
  · cases h

end Ryo.Check.Lower
