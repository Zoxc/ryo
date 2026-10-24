/-
Ryo.Proofs.Inline.Basic — the statement of the inline-sequence theorems (`Sound`, `Post`; see
`Ryo/Proofs/Inline.lean`) and what their proofs share: the operands of a native instruction,
the end of a sequence (`post_mem`: a frame store, `post_branch`: flags only), the tactics that
run the items (`xrun`) and compute their observables (`xobs`), and the value lemmas (pointers,
flags, the two halves of `mov.w128`).
-/
import Ryo.Proofs.Inline.OpSem
import Ryo.Proofs.Inline.Exec
import Ryo.Proofs.Inline.Shape
import Ryo.Vm.R.View
import Ryo.Vm.OpSem.Lemmas

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm


/-! ### The statement -/

/-- The values `opSem` takes for native operands (`view`'s, for a native instruction). -/
def nativeVals (ρ : R.Addrs) (op : Full.Opcode) (ops : List (R.Opnd Nat)) : Option Operands :=
  if op.info.operands.length = ops.length then
    (op.info.operands.zip ops).mapM fun (i, o) => R.nativeVal ρ i.kind o
  else none

/-- The frame ranges `opSem op vals` writes (its footprint's). -/
def wranges (op : Full.Opcode) (vals : Operands) : List (Int × Nat) :=
  match footprint op with
  | some fp => fp.writeRanges (opndVal op.info vals)
  | none => []

/-- The written frame bytes are private (not in an escaped object). -/
def Private (op : Full.Opcode) (vals : Operands) (st : OpSem.State) : Prop :=
  ∀ r ∈ wranges op vals, ∀ o, inRange o r = true → st.escapedAt o = none

/-- What running an inline sequence gives (see the module comment). -/
structure Post (op : Full.Opcode) (ops : List (R.Opnd Nat)) (vals : Operands) (items : List Item)
    (br : Option Cond) (st st' : OpSem.State) (ctl : Control) (x x' : Ryo.X86.State) : Prop where
  rel : Rel st' x'
  same : st'.SameButFrame st
  regs : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x'.regs i = x.regs i
  xmm : x'.xmm = x.xmm
  rip : x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum
  memOut : ∀ a, (∀ r ∈ wranges op vals, r.2 ≤ (a - fpAddr x r.1).toNat) → x'.mem a = x.mem a
  ctl : match br with
    | none => ctl = .next
    | some cond => ∃ b, ctl = .branch b ∧
      ∀ neg t, R.nativeCtl op ops = some (.branch neg t) → cond.eval x'.flags = .ok (b != neg)

/-- The inline sequence of class `c` implements `opSem` (see the module comment). -/
def Sound (c : Class) : Prop :=
  ∀ (ctx : Ctx) (ρ : R.Addrs) (op : Full.Opcode) (ops : List (R.Opnd Nat)) (items : List Item)
    (br : Option Cond) (vals : Operands) (st st' : OpSem.State) (ctl : Control)
    (ch : OpSem.Choice) (x : Ryo.X86.State),
    shapeOk op c = true → sequence c ops = some (items, br) → nativeVals ρ op ops = some vals →
    opSem op vals st ch = .ok (ctl, st') → Rel st x → Private op vals st →
    ∃ x', execItems ctx items x = .ok x' ∧ Post op ops vals items br st st' ctl x x'

/-! ### Operands -/

theorem nvs2 {ρ : R.Addrs} {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {i0 i1 : OperandInfo} (ho : op.info.operands = [i0, i1]) (hv : nativeVals ρ op ops = some vals) :
    ∃ o0 o1 v0 v1, ops = [o0, o1] ∧ vals = [v0, v1] ∧ R.nativeVal ρ i0.kind o0 = some v0 ∧
      R.nativeVal ρ i1.kind o1 = some v1 := by
  simp only [nativeVals, ho] at hv
  rcases ops with _ | ⟨o0, _ | ⟨o1, _ | _⟩⟩ <;> simp at hv
  simp only [Option.bind_eq_some_iff, Option.some.injEq] at hv
  obtain ⟨v0, h0, _, ⟨v1, h1, rfl⟩, rfl⟩ := hv
  exact ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩

theorem nvs3 {ρ : R.Addrs} {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {i0 i1 i2 : OperandInfo} (ho : op.info.operands = [i0, i1, i2])
    (hv : nativeVals ρ op ops = some vals) :
    ∃ o0 o1 o2 v0 v1 v2, ops = [o0, o1, o2] ∧ vals = [v0, v1, v2] ∧
      R.nativeVal ρ i0.kind o0 = some v0 ∧ R.nativeVal ρ i1.kind o1 = some v1 ∧
      R.nativeVal ρ i2.kind o2 = some v2 := by
  simp only [nativeVals, ho] at hv
  rcases ops with _ | ⟨o0, _ | ⟨o1, _ | ⟨o2, _ | _⟩⟩⟩ <;> simp at hv
  simp only [Option.bind_eq_some_iff, Option.some.injEq] at hv
  obtain ⟨v0, h0, _, ⟨v1, h1, _, ⟨v2, h2, rfl⟩, rfl⟩, rfl⟩ := hv
  exact ⟨o0, o1, o2, v0, v1, v2, rfl, rfl, h0, h1, h2⟩

theorem nvs4 {ρ : R.Addrs} {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {i0 i1 i2 i3 : OperandInfo} (ho : op.info.operands = [i0, i1, i2, i3])
    (hv : nativeVals ρ op ops = some vals) :
    ∃ o0 o1 o2 o3 v0 v1 v2 v3, ops = [o0, o1, o2, o3] ∧ vals = [v0, v1, v2, v3] ∧
      R.nativeVal ρ i0.kind o0 = some v0 ∧ R.nativeVal ρ i1.kind o1 = some v1 ∧
      R.nativeVal ρ i2.kind o2 = some v2 ∧ R.nativeVal ρ i3.kind o3 = some v3 := by
  simp only [nativeVals, ho] at hv
  rcases ops with _ | ⟨o0, _ | ⟨o1, _ | ⟨o2, _ | ⟨o3, _ | _⟩⟩⟩⟩ <;> simp at hv
  simp only [Option.bind_eq_some_iff, Option.some.injEq] at hv
  obtain ⟨v0, h0, _, ⟨v1, h1, _, ⟨v2, h2, _, ⟨v3, h3, rfl⟩, rfl⟩, rfl⟩, rfl⟩ := hv
  exact ⟨o0, o1, o2, o3, v0, v1, v2, v3, rfl, rfl, h0, h1, h2, h3⟩

theorem nv_slot {ρ : R.Addrs} {o : R.Opnd Nat} {v : Val} :
    R.nativeVal ρ .slot o = some v ↔ ∃ s, o = .slot s ∧ v = .slot s.toInt := by
  cases o <;> simp [R.nativeVal, eq_comm]

theorem nv_neg {ρ : R.Addrs} {o : R.Opnd Nat} {v : Val} :
    R.nativeVal ρ .neg o = some v ↔ ∃ b, o = .neg b ∧ v = .none := by
  cases o <;> simp [R.nativeVal, eq_comm]

theorem nv_target {ρ : R.Addrs} {o : R.Opnd Nat} {v : Val} :
    R.nativeVal ρ .target o = some v ↔ ∃ t, o = .target t ∧ v = .none := by
  cases o <;> simp [R.nativeVal, eq_comm]

/-- An immediate of kind `k`: below `2 ^ bits k`. -/
def immBits : OperandKind → Nat
  | .u8 => 8 | .u16 => 16 | .u32 => 32 | _ => 64

theorem nv_imm {ρ : R.Addrs} {k : OperandKind} (hk : k = .u8 ∨ k = .u16 ∨ k = .u32 ∨ k = .u64 ∨ k = .i64)
    {o : R.Opnd Nat} {v : Val} :
    R.nativeVal ρ k o = some v → ∃ i : BitVec 64, o = .imm i ∧ v = .imm i.toNat ∧
      i.toNat < 2 ^ immBits k := by
  rcases hk with rfl | rfl | rfl | rfl | rfl <;> cases o <;>
    simp [R.nativeVal, immBits, eq_comm] <;> (try split) <;> simp_all <;>
    exact fun _ => BitVec.isLt _

theorem toInt_bounds (s : BitVec 32) : -2 ^ 31 ≤ s.toInt ∧ s.toInt < 2 ^ 31 :=
  ⟨by have := BitVec.le_toInt s; simpa using this, by have := @BitVec.toInt_lt 32 s; simpa using this⟩

/-! ### Reading and writing the frame, at a width -/

theorem memW_eq (s : Ryo.X86.State) (w : W) (a : BitVec 64) :
    s.memW w a = BitVec.ofNat w.bits (leDecode (bytesAt s.mem a (w.bits / 8))) := by
  simp [State.memW, readNat_eq]

/-- A frame read at `o` of `n` bytes, decoded as an integer: the x86 bytes' value. -/
theorem read_int {st : OpSem.State} {x : Ryo.X86.State} (hr : Rel st x) {s : BitVec 32} {n : Nat}
    (hn : n ≤ 16) {bs : List AbstractByte} {v : Nat} (h : st.readFrame s.toInt n = .ok bs)
    (hv : asNat bs = .ok v) : v = leDecode (bytesAt x.mem (fpAddr x s.toInt) n) := by
  have := toInt_bounds s
  exact asNat_rel (readFrame_rel hr h (by omega) (by omega)) hv

theorem bytesRel_int {n R V : Nat} (h : R % 2 ^ (8 * n) = V % 2 ^ (8 * n)) :
    BytesRel (intBytes n R) (leEncode n V) := by
  rw [← Theorems.leEncode_mod n V, ← h, Theorems.leEncode_mod]
  exact BytesRel.ofBytes _

@[simp] theorem fits_iff (v : BitVec 64) : fits v = true ↔ (v.setWidth 32).signExtend 64 = v := by
  simp [fits]

/-- A width's bytes, reducible so that `8 * wbytes .b` is `8` to instances. -/
abbrev wbytes : W → Nat
  | .b => 1
  | .w => 2
  | .d => 4
  | .q => 8

theorem wbytes_eq (w : W) : wbytes w = w.bits / 8 := by cases w <;> rfl

theorem sext_eq (d : BitVec 32) : d.signExtend 64 = BitVec.ofInt 64 d.toInt := rfl

theorem rbp_sext (s : Ryo.X86.State) (d : BitVec 32) :
    s.reg .rbp + d.signExtend 64 = fpAddr s d.toInt := rfl

theorem bytesRel_val {bs : List AbstractByte} {xs : List UInt8} {n V : Nat} (h : BytesRel bs xs)
    (hl : xs.length = n) (hv : V % 2 ^ (8 * n) = leDecode xs % 2 ^ (8 * n)) :
    BytesRel bs (leEncode n V) := by
  rw [← Theorems.leEncode_mod, hv, Theorems.leEncode_mod, ← hl, Theorems.leEncode_leDecode]
  exact h

theorem wranges_eq {op : Full.Opcode} {vals : Operands} {h : Handlers.HandlerInfo}
    {nm : String} {n : Nat} {d : Int} {rs : List Access} {ad : List String} {de : List Deref}
    {fl : Flow} (hh : op.handler? = some h)
    (hf : footprintOf h.kind h.params = some ⟨rs, [⟨nm, .bytes n⟩], ad, de, fl⟩)
    (hv : opndVal op.info vals nm = some (.slot d)) : wranges op vals = [(d, n)] := by
  unfold wranges
  rw [footprint_eq hh, hf]
  simp only [Footprint.writeRanges, List.filterMap_cons, List.filterMap_nil, Access.range, hv,
    Option.bind_eq_bind, Option.bind_some, Val.slotOff, Extent.eval, Option.pure_def]

theorem private_range {op : Full.Opcode} {vals : Operands} {st : OpSem.State} {d : Int} {n : Nat}
    (hp : Private op vals st) (hwr : wranges op vals = [(d, n)]) :
    ∀ i < n, st.escapedAt (d + i) = none := by
  intro i hi
  apply hp (d, n) (by simp [hwr])
  simp [inRange]; omega

/-- The relation is about memory and `rbp` only. -/
theorem rel_congr {st : OpSem.State} {x x' : Ryo.X86.State} (hr : Rel st x)
    (hb : x'.reg .rbp = x.reg .rbp) (hm : x'.mem = x.mem) : Rel st x' := by
  have hfp : ∀ o, fpAddr x' o = fpAddr x o := fun o => by simp [fpAddr, hb]
  exact ⟨fun o h1 h2 b hb' => by rw [hfp, hm]; exact hr.frame o h1 h2 b hb',
    fun e he a ha => by rw [hfp]; exact hr.layout e he a ha⟩

/-- The end of a sequence that stores the `n` bytes of `V` into the frame at `d`, from a state
`y` that only changed `rax`, `rcx`, the flags and `rip`. -/
theorem post_mem {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {items : List Item} {st st' : OpSem.State} {ctl : Control} {x y : Ryo.X86.State} {n V : Nat}
    {d : BitVec 32} {bs : List AbstractByte} {a : BitVec 64}
    (hr : Rel st x) (hw : st.writeFrame d.toInt bs = .ok st') (hlen : bs.length = n) (hn : n ≤ 16)
    (hwr : wranges op vals = [(d.toInt, n)]) (hp : Private op vals st)
    (hx : BytesRel bs (leEncode n V))
    (hyb : y.reg .rbp = x.reg .rbp) (hym : y.mem = x.mem)
    (hyr : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → y.regs i = x.regs i) (hyx : y.xmm = x.xmm)
    (hrip : a = x.rip + BitVec.ofNat 64 (items.map Item.size).sum) (hctl : ctl = .next) :
    Post op ops vals items none st st' ctl x ((y.jump a).setMem ((y.jump a).ea (M.frame d)) n V) := by
  have hb := toInt_bounds d
  have hm : ((y.jump a).setMem ((y.jump a).ea (M.frame d)) n V).mem =
      x.mem.write (fpAddr x d.toInt) bs.length V := by
    simp only [X86S.mem_setMem, X86S.mem_jump, hym, ea_frame, hlen]
    simp [fpAddr, hyb]
  obtain ⟨hrel, h1, h2, h3, h4⟩ := rel_store hr hw (by rw [hlen]; exact private_range hp hwr)
    (by omega) (by omega) (by rw [hlen]; exact hx) (by simpa using hyb) hm
  refine ⟨hrel, ⟨h2, h1, h3, h4⟩, fun i h0 h1 => ?_, ?_, ?_, fun a' ha => ?_, hctl⟩
  · simpa using hyr i h0 h1
  · simpa using hyx
  · simpa using hrip
  · rw [hm]
    apply X86.Mem.write_other
    have := ha (d.toInt, n) (by simp [hwr])
    simpa [hlen] using this

/-- The end of a sequence that only sets flags (a branch): `x'` changed `rax`, `rcx`, the flags
and `rip`. -/
theorem post_branch {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {items : List Item} {st : OpSem.State} {ctl : Control} {x x' : Ryo.X86.State} {cond : Cond}
    (hr : Rel st x) (hyb : x'.reg .rbp = x.reg .rbp) (hym : x'.mem = x.mem)
    (hyr : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → x'.regs i = x.regs i) (hyx : x'.xmm = x.xmm)
    (hrip : x'.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum)
    (hctl : ∃ b, ctl = .branch b ∧
      ∀ neg t, R.nativeCtl op ops = some (.branch neg t) → cond.eval x'.flags = .ok (b != neg)) :
    Post op ops vals items (some cond) st st ctl x x' :=
  ⟨rel_congr hr hyb hym, ⟨rfl, rfl, rfl, rfl⟩, hyr, hyx, hrip, fun a _ => by rw [hym], hctl⟩

/-- Steps through the items of a sequence. -/
macro "xrun" : tactic =>
  `(tactic| (simp only [execItems_cons, execItems_nil, ld, Asm.st, R, C, Mrax, exec_setReg,
               exec_shift]
             simp only [Item.exec, ex_bind_ok', pure, Except.pure, Except.ok.injEq,
               exists_eq_left', State.setMemW, Cond.eval, need, aluF, subF_eq, logicFlags,
               Functor.map, Except.map, bind, Except.bind, X86S.flags_jump, X86S.flags_setFlags,
               X86S.flags_setReg, X86S.flags_setMem]))

/-- The observables of an intermediate state. -/
macro "xobs" : tactic =>
  `(tactic| simp (config := { contextual := true }) [State.setRegW, State.setMemW, State.setRmW,
    State.regW, State.rmW, State.ea, M.frame, Item.size, aluF, addF, subF, logicFlags,
    BitVec.ofNat_add, BitVec.add_assoc, W.bits, memW_eq, rbp_sext, BitVec.ofNat_toNat, sextI32,
    wbytes])

theorem bytesRel_bv {n : Nat} {a b : BitVec (8 * n)} (h : a = b) :
    BytesRel (intBytes n a.toNat) (leEncode n b.toNat) := by
  subst h; exact BytesRel.ofBytes _

theorem tyName_parse (w : W) :
    Ty.parse (tyName false w) = some (.int (wbytes w) false) ∧
    Ty.parse (tyName true w) = some (.int (wbytes w) true) := by
  cases w <;> exact ⟨rfl, rfl⟩

theorem shl_nat {w : Nat} (a : BitVec w) (i : BitVec 64) : a <<< i.toNat = a <<< i := rfl
theorem shr_nat {w : Nat} (a : BitVec w) (i : BitVec 64) : a >>> i.toNat = a >>> i := rfl
theorem sar_nat {w : Nat} (a : BitVec w) (i : BitVec 64) : a.sshiftRight i.toNat = a.sshiftRight' i :=
  rfl

theorem bytesRel_imm {n v : Nat} {b : BitVec (8 * n)} (h : BitVec.ofNat (8 * n) v = b) :
    BytesRel (intBytes n v) (leEncode n b.toNat) := by
  apply bytesRel_int
  subst h; simp

theorem bytesRel_bool {res b : Bool} (h : res = b) :
    BytesRel (boolByte res) (leEncode 1 (if b then 1 else 0)) := by
  subst h; cases res <;> exact BytesRel.ofBytes _


/-- A native branch's polarity is its `neg` operand. -/
theorem nativeCtl_neg {op : Full.Opcode} {ops : List (R.Opnd Nat)} {neg : Bool} {t : Nat}
    (h : R.nativeCtl op ops = some (.branch neg t)) :
    ((op.info.operands.zip ops).find? (·.1.name == "neg")).map (·.2) = some (.neg neg) := by
  unfold R.nativeCtl at h
  split at h
  · simp [pure] at h
  · simp [pure] at h
  · simp [pure] at h
  · dsimp only at h
    split at h
    · rename_i n t' hn
      simp only [Option.pure_def, Option.some.injEq, R.Then.branch.injEq] at h
      obtain ⟨rfl, -⟩ := h
      simp only [Prod.mk.injEq] at hn
      exact hn.1
    · simp at h
  · dsimp only at h
    split at h <;> simp [pure] at h
  · simp at h

theorem ofNat_beq_zero {n L : Nat} (h : L < 2 ^ n) : (BitVec.ofNat n L == 0#n) = (L == 0) := by
  by_cases hL : L = 0
  · subst hL; simp
  · have : BitVec.ofNat n L ≠ 0#n := by
      intro h'
      have := congrArg BitVec.toNat h'
      simp [Nat.mod_eq_of_lt h] at this
      exact hL this
    rw [beq_eq_false_iff_ne.2 this, beq_eq_false_iff_ne.2 hL]

theorem br_zf {L : Nat} (h : L < 2 ^ 8) : (BitVec.ofNat 8 L == 0#8) = !(L != 0) := by
  rw [ofNat_beq_zero h]; simp [bne]

/-! ### Pointers -/

/-- `addr`'s pointer is the slot's address (the object is at `rbp + off`, `Rel.layout`). -/
theorem addrOf_rel {st : OpSem.State} {x : Ryo.X86.State} (hr : Rel st x) {s : Int}
    {p : ThinPointer} (h : st.addrOf s = .ok p) : BitVec.ofNat 64 p.addr = fpAddr x s := by
  unfold OpSem.State.addrOf at h
  cases he : st.escapedAt s with
  | none => simp [he, ub, throw, throwThe, MonadExceptOf.throw] at h
  | some e =>
    simp only [he] at h
    cases ha : st.mem.get? e.id with
    | none => simp [ha, illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | some a =>
      simp only [ha, pure, Except.pure, Except.ok.injEq] at h
      subst h
      have hmem := List.mem_of_find?_eq_some he
      have hin := List.find?_some he
      simp only [decide_eq_true_eq] at hin
      have hl := hr.layout e hmem a ha
      simp only
      rw [BitVec.ofNat_add, hl, ← fpAddr_add]
      congr 1
      omega

theorem bytesRel_ptr {p : ThinPointer} {b : BitVec 64} (h : BitVec.ofNat 64 p.addr = b) :
    BytesRel (encodePtr p) (leEncode 8 b.toNat) := by
  have := BytesRel.encodePtr p
  rw [← Theorems.leEncode_mod] at this
  subst h
  simpa using this

theorem wrappingOffset_bv (p : ThinPointer) (k : Int) :
    BitVec.ofNat 64 (p.wrappingOffset k).addr = BitVec.ofNat 64 p.addr + BitVec.ofInt 64 k := by
  simp only [ThinPointer.wrappingOffset, Target.ADDR_LIMIT]
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, BitVec.toNat_add, BitVec.toNat_ofInt]
  omega

theorem ptrIndex_addr (q : ThinPointer) (Lp Li : Nat) (i : BitVec 64) (hqa : q.addr = Lp) :
    BitVec.ofNat 64 (q.wrappingOffset ((Li * i.toNat % 2 ^ 64 : Nat) : Int)).addr =
      BitVec.ofNat 64 Lp + BitVec.ofNat 64 Li * i := by
  rw [wrappingOffset_bv, hqa, BitVec.ofInt_natCast]
  congr 1
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_ofNat, BitVec.toNat_mul, BitVec.toNat_ofNat, Nat.mod_mod, Nat.mul_mod,
    Nat.mod_eq_of_lt i.isLt]

/-! ### `mov.w128`: two 8-byte halves -/

theorem write2_at (m : X86.Mem) (a : BitVec 64) (lo hi i : Nat) (hi16 : i < 16) :
    (m.write (a + 8) 8 hi).write a 8 lo (a + BitVec.ofNat 64 i) =
      (leEncode 8 lo ++ leEncode 8 hi)[i]'(by simp [leEncode_length]; omega) := by
  by_cases h8 : i < 8
  · rw [write_at _ _ _ _ _ (by decide) h8, List.getElem_append_left (by simp [leEncode_length]; omega)]
  · rw [X86.Mem.write_other]
    · have : a + BitVec.ofNat 64 i = (a + 8) + BitVec.ofNat 64 (i - 8) := by
        rw [BitVec.add_assoc]; congr 1
        apply BitVec.eq_of_toNat_eq; simp; omega
      rw [this, write_at _ _ _ _ _ (by decide) (by omega),
        List.getElem_append_right (by simp [leEncode_length]; omega)]
      simp [leEncode_length]
    · have : a + BitVec.ofNat 64 i - a = BitVec.ofNat 64 i := by
        generalize BitVec.ofNat 64 i = c; bv_decide
      rw [this]; simp; omega

theorem write2_out (m : X86.Mem) (a b : BitVec 64) (lo hi : Nat) (hb : 16 ≤ (b - a).toNat) :
    (m.write (a + 8) 8 hi).write a 8 lo b = m b := by
  rw [X86.Mem.write_other _ _ _ _ _ (by omega), X86.Mem.write_other]
  have : b - (a + 8) = (b - a) - 8 := by bv_decide
  have h8 : (8 : BitVec 64).toNat = 8 := rfl
  rw [this, BitVec.toNat_sub_of_le]
  · rw [h8]; omega
  · rw [BitVec.le_def, h8]; omega

theorem bytesRel_halves {bs : List AbstractByte} {xs1 xs2 : List UInt8} {LO HI : Nat}
    (h : BytesRel bs (xs1 ++ xs2)) (h1 : xs1.length = 8) (h2 : xs2.length = 8)
    (hl : LO % 2 ^ 64 = leDecode xs1 % 2 ^ 64) (hh : HI % 2 ^ 64 = leDecode xs2 % 2 ^ 64) :
    BytesRel bs (leEncode 8 LO ++ leEncode 8 HI) := by
  rw [← Theorems.leEncode_mod 8 LO, ← Theorems.leEncode_mod 8 HI]
  simp only [show 8 * 8 = 64 from rfl] at *
  have e1 : leEncode 8 (leDecode xs1) = xs1 := by rw [← h1]; exact Theorems.leEncode_leDecode xs1
  have e2 : leEncode 8 (leDecode xs2) = xs2 := by rw [← h2]; exact Theorems.leEncode_leDecode xs2
  rw [hl, hh, Theorems.leEncode_mod, Theorems.leEncode_mod, e1, e2]
  exact h

theorem fpAddr_add8 (x : Ryo.X86.State) (d : BitVec 32) (hd8 : d.toInt + 8 < 2 ^ 31) :
    fpAddr x (d + 8).toInt = fpAddr x d.toInt + 8 := by
  have hb := toInt_bounds d
  have hd8' : (d + 8).toInt = d.toInt + 8 := by
    rw [BitVec.toInt_add_of_not_saddOverflow]
    · rfl
    · simp [BitVec.saddOverflow]; omega
  rw [hd8', show d.toInt + 8 = d.toInt + ((8 : Nat) : Int) from rfl, fpAddr_add]; rfl

/-- The end of `mov.w128`: the high half stored at `d + 8`, then the low half at `d`, from a
state `y` that only changed `rax`, `rcx`, the flags and `rip`. -/
theorem post_mov128 {op : Full.Opcode} {ops : List (R.Opnd Nat)} {vals : Operands}
    {items : List Item} {st st' : OpSem.State} {ctl : Control} {x y : Ryo.X86.State}
    {n1 n2 LO HI : Nat} {d : BitVec 32} {bs : List AbstractByte} {a1 a2 : BitVec 64}
    (hr : Rel st x) (hw : st.writeFrame d.toInt bs = .ok st') (hlen : bs.length = 16)
    (hd8 : d.toInt + 8 < 2 ^ 31) (hn1 : n1 = 8) (hn2 : n2 = 8)
    (hwr : wranges op vals = [(d.toInt, 16)]) (hp : Private op vals st)
    (hx : BytesRel bs (leEncode 8 LO ++ leEncode 8 HI))
    (hyb : y.reg .rbp = x.reg .rbp) (hym : y.mem = x.mem)
    (hyr : ∀ i : Fin 16, i ≠ 0 → i ≠ 1 → y.regs i = x.regs i) (hyx : y.xmm = x.xmm)
    (hrip : a2 = x.rip + BitVec.ofNat 64 (items.map Item.size).sum) (hctl : ctl = .next) :
    let y2 := (y.jump a1).setMem ((y.jump a1).ea ⟨.rbp, d + 8⟩) n1 HI
    Post op ops vals items none st st' ctl x ((y2.jump a2).setMem ((y2.jump a2).ea ⟨.rbp, d⟩) n2 LO) := by
  intro y2
  subst hn1 hn2
  have hb := toInt_bounds d
  have hd8' : (d + 8).toInt = d.toInt + 8 := by
    rw [BitVec.toInt_add_of_not_saddOverflow]
    · rfl
    · simp [BitVec.saddOverflow]; omega
  have hfa : fpAddr x (d + 8).toInt = fpAddr x d.toInt + 8 := by
    rw [hd8', show d.toInt + 8 = d.toInt + ((8 : Nat) : Int) from rfl, fpAddr_add]; rfl
  have hm : ((y2.jump a2).setMem ((y2.jump a2).ea ⟨.rbp, d⟩) 8 LO).mem =
      (x.mem.write (fpAddr x d.toInt + 8) 8 HI).write (fpAddr x d.toInt) 8 LO := by
    simp only [y2, X86S.mem_setMem, X86S.mem_jump, hym, State.ea, X86S.reg_setMem, X86S.reg_jump,
      hyb, rbp_sext, hfa]
  have hxs : (leEncode 8 LO ++ leEncode 8 HI).length = 16 := by simp [leEncode_length]
  obtain ⟨hrel, h1, h2, h3, h4⟩ := rel_writeFrame
    (x' := (y2.jump a2).setMem ((y2.jump a2).ea ⟨.rbp, d⟩) 8 LO) hr hw
    (by rw [hlen]; exact private_range hp hwr) (by omega) (by omega) hx
    (by simpa [y2] using hyb)
    (fun i hi => by rw [hm]; exact write2_at _ _ _ _ _ (by rw [hxs] at hi; exact hi))
    (fun a ha => by rw [hm]; exact write2_out _ _ _ _ _ (by rw [hxs] at ha; exact ha))
  refine ⟨hrel, ⟨h2, h1, h3, h4⟩, fun i h0 h1 => ?_, ?_, ?_, fun a' ha => ?_, hctl⟩
  · simpa [y2] using hyr i h0 h1
  · simpa [y2] using hyx
  · simpa [y2] using hrip
  · rw [hm]
    apply write2_out
    have := ha (d.toInt, 16) (by simp [hwr])
    simpa using this

end Ryo.Proofs.Inline
