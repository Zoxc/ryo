/-
Ryo.Proofs.Inline.Exec — running the items of an inline sequence (`Ryo.X86.Exec`): simp lemmas
for the state's observables after each update, the effect of a frame load and store, and
how a store keeps the frame relation (`rel_store`).
-/
import Ryo.Proofs.Inline.Rel

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86

namespace X86S

variable (s : X86.State)

@[simp] theorem reg_jump (a : BitVec 64) (r : Reg) : (s.jump a).reg r = s.reg r := rfl
@[simp] theorem mem_jump (a : BitVec 64) : (s.jump a).mem = s.mem := rfl
@[simp] theorem flags_jump (a : BitVec 64) : (s.jump a).flags = s.flags := rfl
@[simp] theorem regs_jump (a : BitVec 64) : (s.jump a).regs = s.regs := rfl
@[simp] theorem xmm_jump (a : BitVec 64) : (s.jump a).xmm = s.xmm := rfl
@[simp] theorem rip_jump (a : BitVec 64) : (s.jump a).rip = a := rfl

@[simp] theorem reg_setFlags (f : Flags) (r : Reg) : (s.setFlags f).reg r = s.reg r := rfl
@[simp] theorem mem_setFlags (f : Flags) : (s.setFlags f).mem = s.mem := rfl
@[simp] theorem flags_setFlags (f : Flags) : (s.setFlags f).flags = f := rfl
@[simp] theorem regs_setFlags (f : Flags) : (s.setFlags f).regs = s.regs := rfl
@[simp] theorem xmm_setFlags (f : Flags) : (s.setFlags f).xmm = s.xmm := rfl
@[simp] theorem rip_setFlags (f : Flags) : (s.setFlags f).rip = s.rip := rfl

@[simp] theorem reg_setMem (a : BitVec 64) (n v : Nat) (r : Reg) :
    (s.setMem a n v).reg r = s.reg r := rfl
@[simp] theorem mem_setMem (a : BitVec 64) (n v : Nat) : (s.setMem a n v).mem = s.mem.write a n v :=
  rfl
@[simp] theorem flags_setMem (a : BitVec 64) (n v : Nat) : (s.setMem a n v).flags = s.flags := rfl
@[simp] theorem regs_setMem (a : BitVec 64) (n v : Nat) : (s.setMem a n v).regs = s.regs := rfl
@[simp] theorem xmm_setMem (a : BitVec 64) (n v : Nat) : (s.setMem a n v).xmm = s.xmm := rfl
@[simp] theorem rip_setMem (a : BitVec 64) (n v : Nat) : (s.setMem a n v).rip = s.rip := rfl

@[simp] theorem reg_setReg (r : Reg) (v : BitVec 64) (r' : Reg) :
    (s.setReg r v).reg r' = if r'.idx = r.idx then v else s.reg r' := by
  simp [State.reg, State.setReg]
@[simp] theorem mem_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).mem = s.mem := rfl
@[simp] theorem flags_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).flags = s.flags := rfl
@[simp] theorem regs_setReg (r : Reg) (v : BitVec 64) :
    (s.setReg r v).regs = fun i => if i = r.idx then v else s.regs i := rfl
@[simp] theorem xmm_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).xmm = s.xmm := rfl
@[simp] theorem rip_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).rip = s.rip := rfl

end X86S

/-- The registers' indices, decided. -/
@[simp] theorem idx_rax : Reg.idx .rax = 0 := rfl
@[simp] theorem idx_rcx : Reg.idx .rcx = 1 := rfl
@[simp] theorem idx_rbp : Reg.idx .rbp = 5 := rfl

theorem execItems_cons (ctx : Ctx) (i : Item) (is : List Item) (s : X86.State) :
    execItems ctx (i :: is) s = (i.exec ctx s >>= fun s1 => execItems ctx is s1) := by
  simp [execItems, List.foldlM_cons]

theorem execItems_nil (ctx : Ctx) (s : X86.State) : execItems ctx [] s = .ok s := rfl

theorem ex_bind_ok' {α β ε : Type} (a : α) (f : α → Except ε β) :
    ((Except.ok a : Except ε α) >>= f) = f a := rfl

/-- The effective address of a frame operand. -/
theorem ea_frame (s : X86.State) (d : BitVec 32) : s.ea (M.frame d) = fpAddr s d.toInt := rfl

/-! ### Stores into the frame -/

theorem write_at (m : X86.Mem) (a : BitVec 64) (n v i : Nat) (hn : n ≤ 2 ^ 64) (hi : i < n) :
    m.write a n v (a + BitVec.ofNat 64 i) = (leEncode n v)[i]'(by simp [leEncode_length]; omega) := by
  have h := bytesAt_write m a n v hn
  have := congrArg (fun l => l[i]?) h
  rw [List.getElem?_eq_getElem (by simp [bytesAt_length]; omega),
    List.getElem?_eq_getElem (by simp [leEncode_length]; omega), Option.some.injEq,
    getElem_bytesAt] at this
  exact this

/-- A store of the `n` bytes of `V` at frame offset `d`, against an `opSem` write of bytes
that relate to them, keeps the relation. -/
theorem rel_store {st st' : OpSem.State} {x x' : X86.State} {d : Int} {bs : List AbstractByte}
    {V : Nat} (hr : Rel st x) (hw : st.writeFrame d bs = .ok st')
    (hp : ∀ i < bs.length, st.escapedAt (d + i) = none) (hd : -2 ^ 63 ≤ d)
    (hdn : d + bs.length ≤ 2 ^ 63) (hx : BytesRel bs (leEncode bs.length V))
    (hrbp : x'.reg .rbp = x.reg .rbp) (hmem : x'.mem = x.mem.write (fpAddr x d) bs.length V) :
    Rel st' x' ∧ st'.mem = st.mem ∧ st'.escaped = st.escaped ∧ st'.exposed = st.exposed ∧
      st'.exception = st.exception := by
  have hn : bs.length ≤ 2 ^ 64 := by omega
  refine rel_writeFrame hr hw hp hd hdn hx hrbp (fun i hi => ?_) (fun a ha => ?_)
  · rw [hmem]
    simp only [leEncode_length] at hi
    exact write_at _ _ _ _ _ hn hi
  · rw [hmem]
    simp only [leEncode_length] at ha
    exact X86.Mem.write_other _ _ _ _ _ ha

theorem setForm_zero {v : BitVec 64} (h : (setForm v == 0) = true) : v = 0 := by
  unfold setForm at h
  split at h
  · simpa using ‹(v == 0) = true›
  · split at h <;> (try split at h) <;> simp at h

/-- `setReg`: the register gets the value (by `xor` for zero, which also sets flags). -/
theorem exec_setReg (ctx : Ctx) (r : Reg) (v : BitVec 64) (s : X86.State) :
    (Item.setReg r v).exec ctx s =
      .ok (((s.jump (s.rip + BitVec.ofNat 64 (Item.setReg r v).size)).setReg r v).setFlags
        (if setForm v == 0 then logicFlags (0 : BitVec 32) else s.flags)) := by
  simp only [Item.exec]
  split
  · rename_i h
    rw [setForm_zero h]
    simp [pure, Except.pure]
  · simp only [pure, Except.pure, Except.ok.injEq]
    rfl

/-- The truncated product of `imul`. -/
@[simp] theorem imulF_fst {n : Nat} (a b : BitVec n) : (imulF a b).1 = a * b := by
  simp [imulF, BitVec.ofInt_mul]

/-- Sets the flags if there are new ones (a shift by a masked count of 0 keeps them). -/
def setFlags? (s : X86.State) : Option Flags → X86.State
  | some f => s.setFlags f
  | none => s

@[simp] theorem reg_setFlags? (s : X86.State) (o : Option Flags) (r : Reg) :
    (setFlags? s o).reg r = s.reg r := by cases o <;> rfl
@[simp] theorem mem_setFlags? (s : X86.State) (o : Option Flags) : (setFlags? s o).mem = s.mem := by
  cases o <;> rfl
@[simp] theorem regs_setFlags? (s : X86.State) (o : Option Flags) :
    (setFlags? s o).regs = s.regs := by cases o <;> rfl
@[simp] theorem xmm_setFlags? (s : X86.State) (o : Option Flags) : (setFlags? s o).xmm = s.xmm := by
  cases o <;> rfl
@[simp] theorem rip_setFlags? (s : X86.State) (o : Option Flags) : (setFlags? s o).rip = s.rip := by
  cases o <;> rfl

theorem exec_shift (ctx : Ctx) (op : Sh) (w : W) (r : Reg) (amt : BitVec 8) (s : X86.State) :
    (Item.shift op w r amt).exec ctx s =
      let s0 := s.jump (s.rip + BitVec.ofNat 64 (Item.shift op w r amt).size)
      let c := amt.toNat % (if w == .q then 64 else 32)
      .ok (setFlags? (s0.setRegW w r (shiftF op (s0.regW w r) c).1) (shiftF op (s0.regW w r) c).2) := by
  simp only [Item.exec]
  split
  next f h => simp only [setFlags?, pure, Except.pure, Except.ok.injEq]; rw [h]
  next h => simp only [setFlags?, pure, Except.pure, Except.ok.injEq]; rw [h]

@[simp] theorem shiftF_fst {n : Nat} (op : Sh) (a : BitVec n) (c : Nat) :
    (shiftF op a c).1 = match op with
      | .shl => a <<< c
      | .shr => a >>> c
      | .sar => a.sshiftRight c := by
  unfold shiftF
  by_cases h : c = 0
  · subst h; cases op <;> simp
  · cases op <;> simp [h]

theorem toNat_lt_iff {n : Nat} (a b : BitVec n) : a.toNat < b.toNat ↔ a < b := BitVec.lt_def.symm

/-- `sub`/`cmp`'s flags, with the borrow as an unsigned comparison. -/
theorem subF_eq {n : Nat} (a b : BitVec n) : subF a b = (a - b,
    { cf := some (a.ult b), of := some (a.msb != b.msb && (a - b).msb != a.msb),
      zf := some (a - b == 0), sf := some (a - b).msb }) := by
  simp [subF, BitVec.ult]

end Ryo.Proofs.Inline
