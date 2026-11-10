/-
Ryo.Check.Lower.FnPtrCast — casts to a function's or a vtable's address (aot.md §C1, M5b): fn
item to fn pointer (`reifyFnPointer`, `closureFnPointer`) and unsizing a thin pointer to `dyn`
(`unsize (vtable g)`), and their checker.

What the backend emits (`backend/src/lower/cast.rs`):
- `ReifyFnPointer`/`ClosureFnPointer`: `fn_addr_into`, one `addr.sym $d, sym` of the instance's
  symbol (`CodeReloc::Symbol`); the operand (a fn item or a capture-less closure, zero-sized) is
  not read.
- `Unsize` of `&T`/`*T` to `&dyn Trait`: `coerce_unsized_into`'s pointer case, `mov $d, $a` (8
  bytes, the data pointer) and `unsized_info`'s `(_, Dynamic)` case, `alloc_addr_into` of the
  vtable allocation: `addr.const $d+8, k`, `k` the vtable's pool offset (no PE fixup).

L0: `fnPointer i` (D6) and `globalPtr g` (D7) are address choices; the simulation picks the
first copy (`Proofs/Lower/SimFnPtrCast.lean`: `FnInv`, `FnReusesAt`; `PoolInv`, `ReusesAt`).

Rules (`_d` a whole local, private or escaped: the lifts write it with `FnRel.write_dst`):
- `fnPtr`: `_d = cast k oa (.ptr pt valid)` with `fnCoercion k = some i`, `oa` a whole local or
  a zero-sized constant (`PureOperand`: its evaluation keeps the state), `_d : .ptr pt valid`
  thin of 8 bytes, lowered to `addr.sym $d, n` (`addrSymInsnOk`, not the `.ind` form) with
  `Γ.fnSymAt i = some n` (`StmtCtx.fnSym`: the instances' symbol slots, from the object's symbol
  table, `CertCheck`).
- `vtable`: `_d = cast (unsize (vtable g)) oa (.ptr ptd vd)`, `oa` the whole local `_a : .ptr
  pta va` (thin, an 8-byte slot), `_d : .ptr ptd vd` with vtable metadata (16 bytes), `Γ.poolAt g
  = some k`, lowered to `mov $d, $a` of 8 bytes (`movInsnOk`) and `addr.const $d+8, k`.

Not covered: `addr.sym.ind` (an imported function's address, PE), struct unsizing to `dyn`
(`Box<T>` → `Box<dyn Trait>`, field by field), trait upcasts (`upcast`), wide sources.

`checkFnPtrCast` claims every fn coercion and every vtable unsizing into a whole local at a
pointer type, and is `none` otherwise.
-/
import Ryo.Check.Lower.PoolConst

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-- The instance a fn coercion takes the address of. -/
def fnCoercion : CastKind → Option InstanceId
  | .pointerCoercion (.reifyFnPointer i) => some i
  | .pointerCoercion (.closureFnPointer i) => some i
  | _ => none

/-- Operands whose evaluation keeps L0's state: a whole local, a zero-sized constant. -/
inductive PureOperand : Operand → Prop
  | copy (a : Local) : PureOperand (.copy ⟨a, []⟩)
  | move (a : Local) : PureOperand (.move ⟨a, []⟩)
  | zst (t : Ty) : PureOperand (.const .zeroSized t)

def pureOperandB : Operand → Bool
  | .copy ⟨_, []⟩ => true
  | .move ⟨_, []⟩ => true
  | .const .zeroSized _ => true
  | _ => false

theorem pureOperandB_sound {oa : Operand} (h : pureOperandB oa = true) : PureOperand oa := by
  unfold pureOperandB at h
  split at h
  · exact .copy _
  · exact .move _
  · exact .zst _
  · cases h

/-- `i` is the native `addr.sym` (not `.ind`) of symbol slot `n` into slot `d`. -/
def addrSymInsnOk (i : Insn) (d : Int) (n : Nat) : Bool :=
  match i with
  | .native op [.slot s, .sym n'] =>
    match op.full with
    | some f =>
      f.handler?.map (·.kind) == some .addr_sym && f.handler?.map (·.params) == some ["false"] &&
        f.info.operands == [⟨"d", .slot⟩, ⟨"sym", .sym⟩] && f.info.shape == .op &&
        s.toInt == d && n' == n
    | none => false
  | _ => false

theorem addrSymInsnOk_spec {i : Insn} {d : Int} {n : Nat} (h : addrSymInsnOk i d n = true) :
    ∃ op s f, i = .native op [.slot s, .sym n] ∧ op.full = some f ∧
      (∃ r, f.handler? = some ⟨.addr_sym, ["false"], r⟩) ∧
      f.info.operands = [⟨"d", .slot⟩, ⟨"sym", .sym⟩] ∧ f.info.shape = .op ∧ s.toInt = d := by
  unfold addrSymInsnOk at h
  split at h
  · rename_i op s n'
    split at h
    · rename_i f hf
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨h1, h1'⟩, h2⟩, h3⟩, h4⟩, h5⟩ := h
      subst h5
      refine ⟨op, s, f, rfl, hf, ?_, h2, h3, h4⟩
      cases hh : f.handler? with
      | none => rw [hh] at h1; cases h1
      | some hi =>
        rw [hh] at h1 h1'
        obtain ⟨kd, ps, r⟩ := hi
        simp at h1 h1'
        subst h1
        subst h1'
        exact ⟨r, rfl⟩
    · cases h
  · cases h

/-- The view of a native `addr.sym` under a placement giving symbol slot `n` the address `a`. -/
theorem view_addrSym {mode : Ryo.Obj.Mode} {ρ : Addrs} {op : Reduced.Opcode} {s : BitVec 32}
    {n : Nat} {f : Full.Opcode} {a : ThinPointer} (hf : op.full = some f)
    (ho : f.info.operands = [⟨"d", .slot⟩, ⟨"sym", .sym⟩]) (hsh : f.info.shape = .op)
    (ha : ρ (.sym n) = some a) :
    view mode ρ (.native op [.slot s, .sym n]) =
      some ⟨f, [.slot s.toInt, .addr a], some .next⟩ := by
  have hop : opShape f = true := by unfold opShape; rw [hsh] <;> rfl
  have hc : nativeCtl f [.slot s, .sym n] = some .next := by unfold nativeCtl; rw [hsh] <;> rfl
  have h2 : nativeVal ρ .sym (.sym n) = some (.addr a) := by
    show Option.map _ (ρ (.sym n)) = _
    rw [ha] <;> rfl
  have hvals : (f.info.operands.zip [Opnd.slot s, .sym n]).mapM
      (fun (i, o) => nativeVal ρ i.kind o) = some [.slot s.toInt, .addr a] := by
    rw [ho]
    simp only [List.zip_cons_cons, List.zip_nil_left, List.mapM_cons, List.mapM_nil, h2] <;> rfl
  have hlen : (f.info.operands.length != ([Opnd.slot s, .sym n] : List (Opnd Nat)).length) =
      false := by rw [ho] <;> rfl
  simp only [view, hf, Option.bind_eq_bind, Option.bind_some, hlen, hvals, hop, hc,
    Bool.false_eq_true, ↓reduceIte] <;> rfl

inductive LowerFnPtrCast (Γ : StmtCtx) :
    Statement → List Insn → Prop where
  | fnPtr {d : Local} {k : CastKind} {i : InstanceId} {oa : Operand} {n : Nat} {pt : PtrType}
      {valid : ValidRange} {sd : LocalSlot} {ins : Insn}
      (hk : fnCoercion k = some i) (hoa : PureOperand oa) (hn : Γ.fnSymAt i = some n)
      (htd : Γ.body.locals[d]? = some (.ptr pt valid)) (hmk : pt.metaKind = .none)
      (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = 8) (hoff : offOk sd.off = true)
      (hi : addrSymInsnOk ins sd.off n = true) :
      LowerFnPtrCast Γ (.assign ⟨d, []⟩ (.cast k oa (.ptr pt valid))) [ins]
  | vtable {d a : Local} {oa : Operand} {g : GlobalId} {k : Nat} {ptd pta : PtrType}
      {t : TraitName} {vd va : ValidRange} {sd sa : LocalSlot} {i1 i2 : Insn}
      (ha : oa.local? = some a) (hkg : Γ.poolAt g = some k)
      (htd : Γ.body.locals[d]? = some (.ptr ptd vd)) (hkd : ptd.metaKind = .vtablePointer t)
      (hta : Γ.body.locals[a]? = some (.ptr pta va)) (hka : pta.metaKind = .none)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 16 ∧ sa.size = 8)
      (hoff : offOk sd.off = true ∧ offOk (sd.off + 8) = true ∧ offOk sa.off = true)
      (hi1 : movInsnOk Γ i1 8 sd.off sa.off = true)
      (hi2 : addrConstInsnOk i2 (sd.off + 8) k = true) :
      LowerFnPtrCast Γ
        (.assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.vtable g))) oa (.ptr ptd vd)))
        [i1, i2]

/-! ### The checker -/

/-- `fnPtr`'s checker. -/
def checkFnPtr (Γ : StmtCtx) (d : Local) (i : InstanceId)
    (oa : Operand) (pt : PtrType) (valid : ValidRange) (is : List Insn) : Verdict :=
  match Γ.fnSymAt i, Γ.slots[d]?, is with
  | some n, some sd, [ins] =>
    if pureOperandB oa then
      if pt.metaKind = .none then
        if poolDstOk Γ d pt valid 8 sd then
          if addrSymInsnOk ins sd.off n then .ok else .unsupported "fn pointer: instruction form"
        else .unsupported "fn pointer: destination"
      else .unsupported "fn pointer: wide pointer"
    else .unsupported "fn pointer: operand"
  | none, _, _ => .unsupported "fn pointer: no symbol"
  | _, _, _ => .unsupported "fn pointer: slot or instruction count"

theorem checkFnPtr_sound {Γ : StmtCtx} {d : Local}
    {k : CastKind} {i : InstanceId} {oa : Operand} {pt : PtrType} {valid : ValidRange}
    {is : List Insn} (hk : fnCoercion k = some i)
    (h : checkFnPtr Γ d i oa pt valid is = .ok) :
    LowerFnPtrCast Γ (.assign ⟨d, []⟩ (.cast k oa (.ptr pt valid))) is := by
  unfold checkFnPtr at h
  split at h
  · rename_i n sd ins hn hsd
    split at h
    · rename_i hpo
      split at h
      · rename_i hmk
        split at h
        · rename_i hdst
          split at h
          · rename_i hi
            obtain ⟨htd, hsize, hoff⟩ := poolDstOk_spec hdst
            exact .fnPtr hk (pureOperandB_sound hpo) hn htd hmk hsd hsize hoff hi
          · cases h
        · cases h
      · cases h
    · cases h
  · cases h
  · cases h

/-- `vtable`'s slot sizes and offsets. -/
def vtableSlotsOk (sd sa : LocalSlot) : Bool :=
  sd.size == 16 && sa.size == 8 && offOk sd.off && offOk (sd.off + 8) && offOk sa.off

/-- `vtable`'s checker. -/
def checkVtable (Γ : StmtCtx) (d : Local) (oa : Operand) (g : GlobalId) (ptd : PtrType)
    (vd : ValidRange) (is : List Insn) : Verdict :=
  match oa.local? with
  | none => .unsupported "unsize vtable: operand not a whole local"
  | some a =>
    match Γ.poolAt g with
    | none => .unsupported "pool const: no placement"
    | some k =>
      match ptd.metaKind with
      | .vtablePointer t =>
        match Γ.body.locals[a]? with
        | some (.ptr pta va) =>
          match Γ.slots[d]?, Γ.slots[a]?, is with
          | some sd, some sa, [i1, i2] =>
            if pta.metaKind = .none then
              if Γ.body.locals[d]? == some (.ptr ptd vd) then
                if vtableSlotsOk sd sa then
                  if movInsnOk Γ i1 8 sd.off sa.off && addrConstInsnOk i2 (sd.off + 8) k then .ok
                  else .unsupported "unsize vtable: instruction form"
                else .rejected "unsize vtable: slots"
              else .unsupported "unsize vtable: destination type"
            else .unsupported "unsize vtable: wide source"
          | _, _, _ => .unsupported "unsize vtable: slots or instruction count"
        | _ => .unsupported "unsize vtable: source type"
      | _ => .unsupported "unsize vtable: destination metadata"

theorem checkVtable_sound {Γ : StmtCtx} {d : Local}
    {oa : Operand} {g : GlobalId} {ptd : PtrType} {vd : ValidRange} {is : List Insn}
    (h : checkVtable Γ d oa g ptd vd is = .ok) :
    LowerFnPtrCast Γ
      (.assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.vtable g))) oa (.ptr ptd vd))) is := by
  unfold checkVtable at h
  split at h
  · cases h
  · rename_i a ha
    split at h
    · cases h
    · rename_i k hk
      split at h
      · rename_i t hkd
        split at h
        · rename_i pta va hta
          split at h
          · rename_i sd sa i1 i2 hsd hsa
            split at h
            · rename_i hka
              split at h
              · rename_i htd
                split at h
                · rename_i hsl
                  split at h
                  · rename_i hi
                    simp only [Bool.and_eq_true] at hi
                    simp only [vtableSlotsOk, Bool.and_eq_true, beq_iff_eq] at hsl
                    obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := hsl
                    simp only [beq_iff_eq] at htd
                    exact .vtable ha hk htd hkd hta hka hsd hsa ⟨h1, h2⟩ ⟨h3, h4, h5⟩ hi.1 hi.2
                  · cases h
                · cases h
              · cases h
            · cases h
          · cases h
        · cases h
      · cases h

/-- The family's checker (see the module comment). -/
def checkFnPtrCast (Γ : StmtCtx) (st : Statement)
    (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ (.cast (.pointerCoercion (.reifyFnPointer i)) oa (.ptr pt valid)) =>
    some (checkFnPtr Γ d i oa pt valid is)
  | .assign ⟨d, []⟩ (.cast (.pointerCoercion (.closureFnPointer i)) oa (.ptr pt valid)) =>
    some (checkFnPtr Γ d i oa pt valid is)
  | .assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.vtable g))) oa (.ptr ptd vd)) =>
    some (checkVtable Γ d oa g ptd vd is)
  | _ => none

theorem checkFnPtrCast_sound {Γ : StmtCtx} {st : Statement}
    {is : List Insn} (h : checkFnPtrCast Γ st is = some .ok) : LowerFnPtrCast Γ st is := by
  unfold checkFnPtrCast at h
  split at h
  · exact checkFnPtr_sound rfl (Option.some.inj h)
  · exact checkFnPtr_sound rfl (Option.some.inj h)
  · exact checkVtable_sound (Option.some.inj h)
  · cases h

end Ryo.Check.Lower
