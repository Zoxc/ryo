/-
Ryo.Proofs.Inline.Rip — the rip-relative address sequences against `opSem`: `addr.const`
(`lea rax, [rip + k]`), `addr.sym` (`mov rax, [rip + slot]`) and `addr.sym.ind` (one more
`mov rax, [rax]`), each then `mov [fp + d], rax`.

These read what lies outside the frame, which `Rel` doesn't describe, so they take one more
hypothesis, `Globals ctx ρ st x`: the linked addresses `ctx.addrOf` of the constants, data
and symbol slots are the ones `ρ` gives the operands (the image's layout), and an 8-byte
aligned load `opSem` makes succeeds only on bytes that relate to the x86 bytes at the
pointer's address (a symbol slot holds the symbol's address, and the symbol's storage its
contents). `SoundG c` is `Sound c` with that hypothesis.
-/
import Ryo.Proofs.Inline.Basic

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm

/-- What lies outside the frame (see the module comment). -/
structure Globals (ctx : Ctx) (ρ : R.Addrs) (st : OpSem.State) (x : Ryo.X86.State) : Prop where
  /-- A constant's address is where it is linked. -/
  const : ∀ k p, ρ (.const k) = some p → BitVec.ofNat 64 p.addr = ctx.addrOf (.const k)
  /-- A data object's address is where it is linked. -/
  data : ∀ d p, ρ (.data d) = some p → BitVec.ofNat 64 p.addr = ctx.addrOf (.data d)
  /-- A symbol's slot address is where the slot is linked. -/
  sym : ∀ s p, ρ (.sym s) = some p → BitVec.ofNat 64 p.addr = ctx.addrOf (.sym s)
  /-- The bytes of an 8-byte aligned load relate to the x86 bytes at its address. -/
  mem : ∀ p bs, st.load p 8 Target.PTR_ALIGN = .ok bs →
    BytesRel bs (bytesAt x.mem (BitVec.ofNat 64 p.addr) 8)

/-- `Sound c`, given `Globals` (see the module comment). -/
def SoundG (c : Class) : Prop :=
  ∀ (ctx : Ctx) (ρ : R.Addrs) (op : Full.Opcode) (ops : List (R.Opnd Nat)) (items : List Item)
    (br : Option Cond) (vals : Operands) (st st' : OpSem.State) (ctl : Control)
    (ch : OpSem.Choice) (x : Ryo.X86.State),
    shapeOk op c = true → sequence c ops = some (items, br) → nativeVals ρ op ops = some vals →
    opSem op vals st ch = .ok (ctl, st') → Rel st x → Globals ctx ρ st x →
    ∃ x', execItems ctx items x = .ok x' ∧ Post op ops vals items br st st' ctl x x'

theorem Sound.soundG {c : Class} (h : Sound c) : SoundG c :=
  fun ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr _ =>
    h ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr

/-! ### `opSem` -/

theorem fp_addr_const (ps : List String) :
    footprintOf .addr_const ps = some { writes := [rdA "d" 8] } := rfl

theorem fp_addr_sym (b : Bool) : ∃ de,
    footprintOf .addr_sym [toString b] = some ⟨[], [rdA "d" 8], [], de, .next⟩ := by
  cases b <;> exact ⟨_, rfl⟩

theorem some_false_beq : (some "false" == some "true") = false := rfl
theorem some_true_beq : (some "true" == some "true") = true := rfl

/-- `addr.const`: the operand's address. -/
theorem opSem_addrConst {op : Full.Opcode} {r : Option String} {ps : List String}
    {d : Int} {p : ThinPointer} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.addr_const, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .abs⟩])
    (hsem : opSem op [.slot d, .addr p] st ch = .ok (c, st')) :
    st.writeFrame d (encodePtr p) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_addr_const ps
  osimp [ho] at hra
  subst hra
  osimp [ho, Env.addr] at hk
  subst hk
  exact ⟨(commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `addr.sym`: the pointer in the slot, and with `ind` the pointer it points to. -/
theorem opSem_addrSym {op : Full.Opcode} {r : Option String} {b : Bool}
    {d : Int} {p : ThinPointer} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.addr_sym, [toString b], r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"sym", .sym⟩])
    (hsem : opSem op [.slot d, .addr p] st ch = .ok (c, st')) :
    ∃ bs v, st.load p 8 Target.PTR_ALIGN = .ok bs ∧ asPtr bs = .ok v ∧
      (if b then ∃ bs2 v2, st.load v 8 Target.PTR_ALIGN = .ok bs2 ∧ asPtr bs2 = .ok v2 ∧
          st.writeFrame d (encodePtr v2) = .ok st'
        else st.writeFrame d (encodePtr v) = .ok st') ∧ c = .next := by
  obtain ⟨de, hfp⟩ := fp_addr_sym b
  oinv hsem, hh, hfp
  osimp [ho] at hra
  subst hra
  cases b
  · osimp [ho, Env.addr, toString, some_false_beq, some_true_beq] at hk
    obtain ⟨bs, hl, v, hv, rfl⟩ := hk
    exact ⟨bs, v, hl, hv, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩
  · osimp [ho, Env.addr, toString, some_false_beq, some_true_beq] at hk
    obtain ⟨bs, hl, v, hv, bs2, hl2, v2, hv2, rfl⟩ := hk
    exact ⟨bs, v, hl, hv, ⟨bs2, v2, hl2, hv2,
      (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2⟩, rfl⟩

/-! ### The sequences -/

theorem sound_addrConst : SoundG .addrConst := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hg
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  have hcase : ∃ (to : Ref) (p : ThinPointer), v1 = .addr p ∧
      BitVec.ofNat 64 p.addr = ctx.addrOf to ∧
      sequence .addrConst [R.Opnd.slot s0, o1] = some ([.lea R to, Asm.st .q (M.frame s0)], none) := by
    cases o1 <;> simp only [R.nativeVal, Option.map_eq_some_iff] at h1 <;>
      obtain ⟨p, hρ, rfl⟩ := h1
    · exact ⟨_, p, rfl, hg.const _ p hρ, rfl⟩
    · exact ⟨_, p, rfl, hg.data _ p hρ, rfl⟩
  obtain ⟨to, p, rfl, hpv, hseq'⟩ := hcase
  rw [hseq'] at hseq
  simp only [Option.some.injEq, Prod.mk.injEq] at hseq
  obtain ⟨rfl, rfl⟩ := hseq
  obtain ⟨hwr, rfl⟩ := opSem_addrConst hh ho hsem
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .addr p]) (d := s0.toInt)
    hh (fp_addr_const []) (by simp [opndVal, ho])
  xrun
  refine post_mem hr hwr (by rw [Theorems.encodePtr_length]; rfl) (by decide) hwr'
    ?_ ?_ ?_ ?_ ?_ ?_ rfl
  · xobs
    exact bytesRel_ptr hpv
  all_goals xobs

/-- `addr.sym` (`ind` false) and `addr.sym.ind`. -/
theorem sound_addrSym' (c : Class) (b : Bool) (hcb : c = (if b then .addrSymInd else .addrSym)) :
    SoundG c := by
  intro ctx ρ op ops items br vals st st' ctl ch x hs hseq hv hsem hr hg
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  have hh' : op.handler? = some ⟨.addr_sym, [toString b], r⟩ := by
    subst hcb; cases b <;> exact hh
  have ho' : op.info.operands = [⟨"d", .slot⟩, ⟨"sym", .sym⟩] := by
    subst hcb; cases b <;> exact ho
  clear hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho' hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  cases o1 <;> simp only [R.nativeVal, Option.map_eq_some_iff, reduceCtorEq] at h1
  rename_i sy
  obtain ⟨p, hρ, rfl⟩ := h1
  obtain ⟨de, hfp⟩ := fp_addr_sym b
  have hwr' := wranges_eq (vals := [.slot s0.toInt, .addr p]) (d := s0.toInt)
    hh' hfp (by simp [opndVal, ho'])
  obtain ⟨bs, v, hl, hvp, hb, rfl⟩ := opSem_addrSym hh' ho' hsem
  have hslot := hg.sym sy p hρ
  have hva := asPtr_rel (hg.mem p bs hl) hvp
  subst hcb
  cases b
  · try simp only [Bool.false_eq_true, ↓reduceIte] at hb
    simp only [sequence, Bool.false_eq_true, ↓reduceIte, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, List.getElem?_cons_zero, List.getElem?_cons_succ, Option.some.injEq,
      Prod.mk.injEq] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    simp only [show (Class.addrSym == Class.addrSymInd) = false by decide, Bool.false_eq_true,
      ↓reduceIte, List.append_nil, List.cons_append, List.nil_append]
    xrun
    refine post_mem hr hb (by rw [Theorems.encodePtr_length]; rfl) (by decide) hwr'
      ?_ ?_ ?_ ?_ ?_ ?_ rfl
    · xobs
      apply bytesRel_ptr
      rw [hva, ← hslot, X86.Mem.read64, readNat_eq]
    all_goals xobs
  · try simp only [↓reduceIte] at hb
    obtain ⟨bs2, v2, hl2, hvp2, hw⟩ := hb
    have hva2 := asPtr_rel (hg.mem v bs2 hl2) hvp2
    simp only [sequence, ↓reduceIte, Option.pure_def, Option.bind_eq_bind,
      Option.bind_some, List.getElem?_cons_zero, List.getElem?_cons_succ, Option.some.injEq,
      Prod.mk.injEq] at hseq
    obtain ⟨rfl, rfl⟩ := hseq
    simp only [show (Class.addrSymInd == Class.addrSymInd) = true by decide, ↓reduceIte,
      List.cons_append, List.nil_append]
    xrun
    refine post_mem hr hw (by rw [Theorems.encodePtr_length]; rfl) (by decide) hwr'
      ?_ ?_ ?_ ?_ ?_ ?_ rfl
    · have hv1 : BitVec.ofNat 64 v.addr = x.mem.read64 (ctx.addrOf (.sym sy)) := by
        rw [hva, ← hslot, X86.Mem.read64, readNat_eq]
      have h2 := bytesRel_ptr (p := v2)
        (b := BitVec.ofNat 64 (leDecode (bytesAt x.mem (x.mem.read64 (ctx.addrOf (.sym sy))) 8)))
        (by rw [hva2, hv1])
      xobs
      simpa using h2
    all_goals xobs

theorem sound_addrSym : SoundG .addrSym := sound_addrSym' _ false rfl
theorem sound_addrSymInd : SoundG .addrSymInd := sound_addrSym' _ true rfl

end Ryo.Proofs.Inline
