/-
Ryo.Proofs.DeadStore.Rel — moving between the relations (design T5; statements from T0).

- `xAgree_virt`, `xAgree_of_virt`, `rbpOk_of_xAgree`: `XAgree` on the real states is `XAgreeAt`
  on the virtual ones (equal registers give the same `rsp + F`).
- `frameInvR_jump`, `cacheInv_jump`: the ghost re-jumped after an inline sequence (`Defs`'
  module comment on `rip`).
- `frameInvR_erase`: the real machine relates to the shadow `erase s P` (`ByteRel .uninit`
  relates anything; the other `FrameInv` fields don't see frame bytes `[-F, 0)`).
- `dinv_of_agree`: after a non-inline step, re-ghost: `xh` is the real `x'` with `P'` patched to
  `s'`'s bytes, related by `BInv` since the cache there caches no slot touching `P'`.

Both `FrameInv` results go through `ds_transfer`: `FrameInv` of `s` on `y` gives it of `s2` on
`y2` when the registers agree, memory agrees off `fp + P` (`P` in `[-F, 0)`, so apart from the
code, the rodata and the link slots), `s2` has `s`'s escaped objects and allocations up to their
bytes, and the frame bytes and allocation bytes relate (given per case). `MemRel`'s bytes off
`fp + P` carry over by `ds_byte_keep` (`FrameOwn`: a window address in a live allocation is an
escaped object's own byte).

`ds_dropped_not_slot` (no dropped store writes PE's stack-argument slots `[-F + 32, frameLo)`,
from `Cert.hframe`) is used by `dinv_of_agree` for `FrameInv.slots` at a dead patched byte.
-/
import Ryo.Proofs.DeadStore.Defs
import Ryo.Proofs.Discharge.RelocsIn

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink Ryo.Proofs.RegCache
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem

variable {S : Setup}

/-! ### Real and virtual -/

theorem xAgree_virt {P : Int → Prop} {x xh : X86.State} (h : XAgree S P x xh) :
    XAgreeAt (vfp S xh) P (S.virt x) (S.virt xh) := by
  obtain ⟨hr, hx, hfl, hrip, hm⟩ := h
  have hsp : x.rsp = xh.rsp := by simp only [X86.State.rsp, X86.State.reg, hr]
  unfold XAgreeAt
  refine ⟨funext fun i => setup_virt_regs_congr S (x := xh) (y := x) (P := fun _ => True)
      (fun i _ => by rw [hr]) hsp i trivial,
    (by rw [setup_virt_xmm, setup_virt_xmm, hx]), (by rw [setup_virt_flags, setup_virt_flags, hfl]),
    (by rw [setup_virt_rip, setup_virt_rip, hrip]), ?_⟩
  rw [setup_virt_mem, setup_virt_mem]
  exact hm

theorem xAgree_of_virt {P : Int → Prop} {x xh : X86.State} (hr : x.regs = xh.regs)
    (h : XAgreeAt (vfp S xh) P (S.virt x) (S.virt xh)) : XAgree S P x xh := by
  obtain ⟨-, hx, hfl, hrip, hm⟩ := h
  rw [setup_virt_xmm, setup_virt_xmm] at hx
  rw [setup_virt_flags, setup_virt_flags] at hfl
  rw [setup_virt_rip, setup_virt_rip] at hrip
  rw [setup_virt_mem, setup_virt_mem] at hm
  unfold XAgree XAgreeAt
  exact ⟨hr, hx, hfl, hrip, hm⟩

theorem rbpOk_of_xAgree {P : Int → Prop} {x xh : X86.State} (h : XAgree S P x xh)
    (hr : RbpOk S xh) : RbpOk S x := by
  intro hs
  obtain ⟨hregs, -⟩ := h
  have : x.reg .rbp = xh.reg .rbp := by simp only [X86.State.reg, hregs]
  rw [this]
  exact hr hs

theorem frameInvR_jump {s : R.RState} {x : X86.State} (a : BitVec 64) (h : FrameInvR S s x) :
    FrameInvR S s (x.jump a) :=
  ⟨(by rw [setup_virt_jump]; exact h.1.congr rfl rfl rfl), h.2⟩

theorem cacheInv_jump {c : Asm.Cache} {x : X86.State} (a : BitVec 64)
    (h : CacheInv c (S.virt x)) : CacheInv c (S.virt (x.jump a)) := by
  rw [setup_virt_jump]
  exact (Ryo.Proofs.RegCache.inv_jump c (S.virt x) a).2 h

/-! ### Offsets and addresses -/

theorem ds_off_inj {fp : BitVec 64} {o d : Int} (ho : -2 ^ 63 ≤ o ∧ o < 2 ^ 63)
    (hd : -2 ^ 63 ≤ d ∧ d < 2 ^ 63) (h : fp + BitVec.ofInt 64 o = fp + BitVec.ofInt 64 d) :
    o = d := by
  let x : X86.State := { (default : X86.State) with regs := fun _ => fp }
  have h' : fpAddr x o = fpAddr x d := h
  apply Classical.byContradiction
  intro hne
  have h1 := fpAddr_sub_ge x o d 1 ho hd.1 (by omega) (by omega)
  rw [h'] at h1
  have h0 : (fpAddr x d - fpAddr x d).toNat = 0 := by simp
  omega

theorem ds_addr_nat (y : X86.State) (d : Nat) :
    y.reg .rbp + BitVec.ofNat 64 d = fpAddr y (d : Int) := by
  simp only [fpAddr, BitVec.ofInt_natCast]

theorem ds_addr8 (y : X86.State) (i : Nat) :
    y.reg .rbp + 8 + BitVec.ofNat 64 i = fpAddr y ((8 + i : Nat) : Int) := by
  show y.reg .rbp + BitVec.ofNat 64 8 + BitVec.ofNat 64 i = _
  rw [BitVec.add_assoc, ← BitVec.ofNat_add, ds_addr_nat]

theorem ds_read64_congr {m m' : X86.Mem} {a : BitVec 64}
    (h : ∀ i < 8, m (a + BitVec.ofNat 64 i) = m' (a + BitVec.ofNat 64 i)) :
    m.read64 a = m'.read64 a := by
  unfold X86.Mem.read64
  rw [Ryo.Proofs.RegCache.readNat_congr m m' a 8 h]

theorem ds_F_lt (H : Hyps S) : S.c.d.frameSize < 2 ^ 62 := by
  have := H.stackSizes.stack 0
  have h : S.F = S.c.d.frameSize := rfl
  omega

/-! ### Frame bytes -/

theorem ds_escapedAt_eq {st st2 : OpSem.State} (h : st2.escaped = st.escaped) {o : Int} :
    st2.escapedAt o = st.escapedAt o := by
  unfold OpSem.State.escapedAt
  rw [h]

theorem ds_escapedAt_some {st : OpSem.State} {o : Int} {e : OpSem.EscapedObj}
    (h : st.escapedAt o = some e) : e ∈ st.escaped ∧ e.off ≤ o ∧ o < e.off + e.size := by
  unfold OpSem.State.escapedAt at h
  have h1 := List.mem_of_find?_eq_some h
  have h2 := List.find?_some h
  simp only [decide_eq_true_eq] at h2
  exact ⟨h1, h2.1, h2.2⟩

theorem ds_escapedAt_of_mem {st : OpSem.State} {o : Int} {e : OpSem.EscapedObj}
    (hdisj : ∀ e ∈ st.escaped, ∀ e' ∈ st.escaped, e ≠ e' →
      e.off + e.size ≤ e'.off ∨ e'.off + e'.size ≤ e.off)
    (he : e ∈ st.escaped) (h1 : e.off ≤ o) (h2 : o < e.off + e.size) : st.escapedAt o = some e := by
  cases h : st.escapedAt o with
  | none => exact (escapedAt_none h e he ⟨h1, h2⟩).elim
  | some e' =>
    obtain ⟨hm', h1', h2'⟩ := ds_escapedAt_some h
    by_cases hne : e' = e
    · rw [hne]
    · rcases hdisj e' hm' e he hne with h3 | h3 <;> omega

theorem ds_byteAt_ok {st : OpSem.State} {o : Int} {b : AbstractByte} (h : st.byteAt o = .ok b) :
    (st.escapedAt o = none ∧ st.frame o = b) ∨
      ∃ e a, st.escapedAt o = some e ∧ st.mem.get? e.id = some a ∧ a.live = true ∧
        a.data[(o - e.off).toNat]? = some b := by
  cases he : st.escapedAt o with
  | none =>
    simp only [OpSem.State.byteAt, he] at h
    exact .inl ⟨rfl, Except.ok.inj h⟩
  | some e =>
    cases ha : st.mem.get? e.id with
    | none =>
      simp [OpSem.State.byteAt, he, ha, OpSem.illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | some a =>
      cases hl : a.live with
      | false =>
        simp [OpSem.State.byteAt, he, ha, hl, OpSem.illFormed, throw, throwThe,
          MonadExceptOf.throw] at h
      | true =>
        cases hd : a.data[(o - e.off).toNat]? with
        | none =>
          simp [OpSem.State.byteAt, he, ha, hl, hd, OpSem.illFormed, throw, throwThe,
            MonadExceptOf.throw] at h
        | some c =>
          simp [OpSem.State.byteAt, he, ha, hl, hd, pure, Except.pure] at h
          exact .inr ⟨e, a, rfl, ha, hl, (by rw [hd, h])⟩

theorem ds_byteAt_of_none {st : OpSem.State} {o : Int} (he : st.escapedAt o = none) :
    st.byteAt o = .ok (st.frame o) := by
  unfold OpSem.State.byteAt
  rw [he] <;> rfl

theorem ds_byteAt_of_some {st : OpSem.State} {o : Int} {e : OpSem.EscapedObj} {a : Allocation}
    {c : AbstractByte} (he : st.escapedAt o = some e) (ha : st.mem.get? e.id = some a)
    (hl : a.live = true) (hd : a.data[(o - e.off).toNat]? = some c) : st.byteAt o = .ok c := by
  simp [OpSem.State.byteAt, he, ha, hl, hd, pure, Except.pure]

/-! ### The erased state -/

theorem ds_eraseSt_escapedAt (P : Int → Prop) (st : OpSem.State) (o : Int) :
    (eraseSt P st).escapedAt o = st.escapedAt o := rfl

theorem ds_eraseSt_byteAt_of_some {P : Int → Prop} {st : OpSem.State} {o : Int}
    {e : OpSem.EscapedObj} (h : st.escapedAt o = some e) :
    (eraseSt P st).byteAt o = st.byteAt o := by
  unfold OpSem.State.byteAt
  rw [ds_eraseSt_escapedAt, h]
  rfl

/-- A byte of the erased state: `Uninit` at `P`, else the original's (`hpriv`: `P` private, so
`eraseSt` leaves memory alone). -/
theorem ds_erase_byteAt {P : Int → Prop} {st : OpSem.State} {o : Int} {b : AbstractByte}
    (hpriv : ∀ o, P o → st.escapedAt o = none)
    (h : (eraseSt P st).byteAt o = .ok b) :
    (P o → b = .uninit) ∧ (¬ P o → st.byteAt o = .ok b) := by
  cases he : st.escapedAt o with
  | none =>
    have he' : (eraseSt P st).escapedAt o = none := he
    rw [ds_byteAt_of_none he'] at h
    have hf := Except.ok.inj h
    refine ⟨fun hp => ?_, fun hp => ?_⟩
    · rw [← hf]; simp [eraseSt, hp]
    · rw [ds_byteAt_of_none he, ← hf]; simp [eraseSt, hp]
  | some e =>
    rw [ds_eraseSt_byteAt_of_some he] at h
    exact ⟨fun hp => absurd (hpriv o hp) (by rw [he]; simp), fun _ => h⟩

/-! ### Patching the ghost's memory -/

open Classical in
/-- `m` with the bytes at `fp + o`, `o ∈ P`, set to `st`'s initialized frame bytes there. -/
noncomputable def ds_patchMem (fp : BitVec 64) (P : Int → Prop) (st : OpSem.State) (m : X86.Mem)
    (a : BitVec 64) : UInt8 :=
  if h : ∃ o, P o ∧ a = fp + BitVec.ofInt 64 o then
    match st.byteAt (Classical.choose h) with
    | .ok (.init v _) => v
    | _ => m a
  else m a

theorem ds_patch_off {fp : BitVec 64} {P : Int → Prop} {st : OpSem.State} {m : X86.Mem}
    {a : BitVec 64} (hne : ∀ o, P o → a ≠ fp + BitVec.ofInt 64 o) : ds_patchMem fp P st m a = m a := by
  have hn : ¬ ∃ o, P o ∧ a = fp + BitVec.ofInt 64 o := by
    rintro ⟨o, ho, rfl⟩
    exact hne o ho rfl
  unfold ds_patchMem
  rw [dif_neg hn]

theorem ds_patch_at {fp : BitVec 64} {P : Int → Prop} {st : OpSem.State} {m : X86.Mem}
    (hPb : ∀ o, P o → -2 ^ 63 ≤ o ∧ o < 2 ^ 63) {o : Int} {b : AbstractByte} (ho : P o)
    (hb : st.byteAt o = .ok b) : ByteRel b (ds_patchMem fp P st m (fp + BitVec.ofInt 64 o)) := by
  have h : ∃ o', P o' ∧ fp + BitVec.ofInt 64 o = fp + BitVec.ofInt 64 o' := ⟨o, ho, rfl⟩
  unfold ds_patchMem
  rw [dif_pos h]
  have hc := Classical.choose_spec h
  have he : Classical.choose h = o := (ds_off_inj (hPb o ho) (hPb _ hc.1) hc.2).symm
  rw [he, hb]
  cases b with
  | uninit => trivial
  | init v p => exact rfl

/-! ### Moving `FrameInv` -/

/-- `m2` has `m`'s allocations, each at the same address, as live and of the same size. -/
def DsShape (m m2 : Memory) : Prop :=
  m2.allocs.size = m.allocs.size ∧ ∀ id a2, m2.get? id = some a2 →
    ∃ a, m.get? id = some a ∧ a2.addr = a.addr ∧ a2.live = a.live ∧ a2.data.size = a.data.size

/-- A live allocation's byte not erased by `P` is apart from `fp + P` (`FrameOwn`). -/
theorem ds_own_hit {s : R.RState} {y : X86.State} (hf : FrameInv S s y) {id : AllocId}
    {a : Allocation} {i : Nat} {o : Int} (hg : s.st.mem.get? id = some a) (hl : a.live = true)
    (hi : i < a.data.size) (hlo : -(S.F : Int) ≤ o) (hhi : o < S.K)
    (ho : -2 ^ 63 ≤ o ∧ o < 2 ^ 63) (heq : BitVec.ofNat 64 (a.addr + i) = fpAddr y o) :
    ∃ e ∈ s.st.escaped, e.id = id ∧ e.off + (i : Int) = o := by
  have hsp : a.addr + a.data.size ≤ 2 ^ 64 := hf.sep.space id a hg hl
  have hi64 : i < 2 ^ 64 := by omega
  have hin : (fpAddr y o - BitVec.ofNat 64 a.addr).toNat < a.size := by
    rw [← heq, BitVec.ofNat_add, BitVec.add_comm, BitVec.add_sub_cancel, BitVec.toNat_ofNat,
      Nat.mod_eq_of_lt hi64]
    exact hi
  obtain ⟨e, he, h1, h2, hid⟩ := hf.sep.own id a o hg hl hlo hhi hin
  have hlay := hf.rrel.rel.layout e he a (by rw [hid]; exact hg)
  have hesz : a.data.size = e.size := hf.rrel.wf.size e he a (by rw [hid]; exact hg)
  have hes := hf.sep.esc e he
  have h3 : fpAddr y (e.off + i) = fpAddr y o := by
    rw [fpAddr_add, ← hlay, ← BitVec.ofNat_add]
    exact heq
  exact ⟨e, he, hid, ds_off_inj (fp := y.reg .rbp) ⟨(by omega), (by omega)⟩ ho h3⟩

/-- A byte of a live allocation is not an escaped object's byte at a private offset. -/
theorem ds_priv_not_obj {s : R.RState} {y : X86.State} (hf : FrameInv S s y) {P : Int → Prop}
    (hpriv : ∀ o, P o → s.st.escapedAt o = none) {id : AllocId} {a : Allocation} {i : Nat}
    (ha : s.st.mem.get? id = some a) (hi : i < a.data.size) :
    ¬ ∃ e ∈ s.st.escaped, e.id = id ∧ P (e.off + i) := by
  rintro ⟨e, hem, hid, hp⟩
  have hesz : a.data.size = e.size := hf.rrel.wf.size e hem a (by rw [hid]; exact ha)
  have h := ds_escapedAt_of_mem (o := e.off + i) hf.rrel.wf.disj hem (by omega) (by omega)
  rw [hpriv _ hp] at h
  exact absurd h (by simp)

theorem ds_byte_keep (H : Hyps S) {s : R.RState} {y y2 : X86.State} {P : Int → Prop}
    (hf : FrameInv S s y) (hP : ∀ o, P o → -(S.c.d.frameSize : Int) ≤ o ∧ o < 0)
    (hm : ∀ a, (∀ o, P o → a ≠ fpAddr y o) → y2.mem a = y.mem a)
    {id : AllocId} {a : Allocation} {i : Nat} (ha : s.st.mem.get? id = some a) (hl : a.live = true)
    (hi : i < a.data.size) (hc : ¬ ∃ e ∈ s.st.escaped, e.id = id ∧ P (e.off + i)) :
    y2.mem (BitVec.ofNat 64 (a.addr + i)) = y.mem (BitVec.ofNat 64 (a.addr + i)) := by
  apply hm
  intro o ho heq
  apply hc
  have hF := ds_F_lt H
  have hFe : S.F = S.c.d.frameSize := rfl
  have hPo := hP o ho
  obtain ⟨e, he, hid, hoff⟩ := ds_own_hit hf ha hl hi (by omega)
    (by show o < 16 + (S.c.argSize : Int); omega) (by omega) heq
  exact ⟨e, he, hid, (by rw [hoff]; exact ho)⟩

/-- `FrameInv` moved to a state agreeing but at the frame bytes `P` (see the module comment). -/
theorem ds_transfer (H : Hyps S) {s s2 : R.RState} {y y2 : X86.State} {P : Int → Prop}
    (hf : FrameInv S s y) (hpc : s2.pc = s.pc) (hfp : s2.fp = s.fp) (hargs : s2.args = s.args)
    (hr : y2.regs = y.regs) (hx : y2.xmm = y.xmm)
    (hP : ∀ o, P o → -(S.c.d.frameSize : Int) ≤ o ∧ o < 0)
    (hm : ∀ a, (∀ o, P o → a ≠ fpAddr y o) → y2.mem a = y.mem a)
    (hesc : s2.st.escaped = s.st.escaped) (hzs : s2.st.zeroSized = s.st.zeroSized)
    (hsh : DsShape s.st.mem s2.st.mem)
    (hinit : ∀ o, s2.st.escapedAt o = none → s2.st.frame o ≠ .uninit →
      s.st.frame o ≠ .uninit ∨ P o)
    (hkeep : ∀ o, ¬ P o → ∀ b, s2.st.byteAt o = .ok b → s.st.byteAt o = .ok b)
    (hpatch : ∀ o, P o → ∀ b, s2.st.byteAt o = .ok b → ByteRel b (y2.mem (fpAddr y o)))
    (hmr : MemRel s2.st y2) (hsl : Discharge.PeStackArg.ArgSlots S.c s2.st) :
    FrameInv S s2 y2 := by
  have hF := ds_F_lt H
  have hFe : S.F = S.c.d.frameSize := rfl
  have hPb : ∀ o, P o → -2 ^ 63 ≤ o ∧ o < 2 ^ 63 := fun o ho => by
    have := hP o ho
    omega
  have hPw : ∀ o, P o → -(S.F : Int) ≤ o ∧ o < S.K := fun o ho => by
    have := hP o ho
    show _ ∧ o < 16 + (S.c.argSize : Int)
    omega
  have hrbp : y2.reg .rbp = y.reg .rbp := by simp only [X86.State.reg, hr]
  have hrsp : y2.rsp = y.rsp := by simp only [X86.State.rsp, X86.State.reg, hr]
  have hfpa : ∀ o, fpAddr y2 o = fpAddr y o := fun o => by simp only [fpAddr, hrbp]
  have hea : ∀ o, s2.st.escapedAt o = s.st.escapedAt o := fun o => ds_escapedAt_eq hesc
  have hget : ∀ id a2, s2.st.mem.get? id = some a2 → ∃ a, s.st.mem.get? id = some a ∧
      a2.addr = a.addr ∧ a2.live = a.live ∧ a2.size = a.size := fun id a2 h => by
    obtain ⟨a, ha, h1, h2, h3⟩ := hsh.2 id a2 h
    exact ⟨a, ha, h1, h2, h3⟩
  have hcode : ∀ a, ((∃ p, p < S.body.code.size ∧ a = addrAt S.ctx p) ∨
      (∃ j, j < S.ro.size ∧ a = S.ctx.addrOf (.ro j))) → y2.mem a = y.mem a := fun a ha =>
    hm a (fun o ho heq => (H.codeApart a ha).2.2.1 o (hPw o ho).1 (hPw o ho).2
      (heq.trans (hf.fpAddr_eq o)))
  have hlink : ∀ d : Nat, d < 16 → y2.mem (fpAddr y d) = y.mem (fpAddr y d) := fun d hd =>
    hm _ (fun o ho heq => by
      have h1 := ds_off_inj (fp := y.reg .rbp) ⟨(by omega), (by omega)⟩ (hPb o ho) heq
      have h2 := (hP o ho).2
      omega)
  -- `rrel`
  have hRf : ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → ∀ b, s2.st.byteAt o = .ok b →
      ByteRel b (y2.mem (fpAddr y2 o)) := by
    intro o h1 h2 b hb
    rw [hfpa o]
    by_cases hp : P o
    · exact hpatch o hp b hb
    · have hne : ∀ o', P o' → fpAddr y o ≠ fpAddr y o' := fun o' ho' heq =>
        hp (by rw [ds_off_inj (fp := y.reg .rbp) ⟨h1, h2⟩ (hPb o' ho') heq]; exact ho')
      rw [hm _ hne]
      exact hf.rrel.rel.frame o h1 h2 b (hkeep o hp b hb)
  have hlay : ∀ e ∈ s2.st.escaped, ∀ a, s2.st.mem.get? e.id = some a →
      BitVec.ofNat 64 a.addr = fpAddr y2 e.off := by
    intro e he a2 ha2
    obtain ⟨a, ha, h1, -, -⟩ := hget e.id a2 ha2
    rw [h1, hfpa]
    exact hf.rrel.rel.layout e (by rw [← hesc]; exact he) a ha
  have hzs' : ∀ p ∈ s2.st.zeroSized, BitVec.ofNat 64 p.2 = fpAddr y2 p.1 := by
    intro p hp
    rw [hfpa]
    exact hf.rrel.rel.zeroSized p (by rw [← hzs]; exact hp)
  have hrb : y2.reg .rbp = BitVec.ofNat 64 s2.fp := by
    rw [hrbp, hfp]
    exact hf.rrel.rbp
  have hwf : EscWF s2.st := EscWF.of_sizes hf.rrel.wf hesc ⟨hsh.1, fun id a2 h => by
    obtain ⟨a, ha, -, -, h3⟩ := hget id a2 h
    exact ⟨a, ha, h3⟩⟩
  -- `sep`
  have hsep : FrameSep (-(S.F : Int)) S.K s2.st y2 := by
    refine ⟨?_, ?_, ?_, ?_, ?_⟩
    · intro id a2 o hg hl hlo hhi hin
      obtain ⟨a, ha, h1, h2, h3⟩ := hget id a2 hg
      rw [hfpa, h1, h3] at hin
      obtain ⟨e, he, e1, e2, e3⟩ := hf.sep.own id a o ha (by rw [← h2]; exact hl) hlo hhi hin
      exact ⟨e, (by rw [hesc]; exact he), e1, e2, e3⟩
    · intro o he hu
      rcases hinit o he hu with h | h
      · exact hf.sep.init o (by rw [← hea]; exact he) h
      · exact hPw o h
    · intro id1 a1 id2 a2 i j g1 g2 l1 l2 hi hj heq
      obtain ⟨b1, gb1, ad1, lv1, sz1⟩ := hget id1 a1 g1
      obtain ⟨b2, gb2, ad2, lv2, sz2⟩ := hget id2 a2 g2
      rw [ad1, ad2] at heq
      rw [sz1] at hi
      rw [sz2] at hj
      exact hf.sep.dis id1 b1 id2 b2 i j gb1 gb2 (by rw [← lv1]; exact l1)
        (by rw [← lv2]; exact l2) hi hj heq
    · intro id a2 g l
      obtain ⟨a, ga, ad, lv, sz⟩ := hget id a2 g
      rw [ad, sz]
      exact hf.sep.space id a ga (by rw [← lv]; exact l)
    · intro e he
      exact hf.sep.esc e (by rw [← hesc]; exact he)
  -- `code`, `ro`
  have hc : ∀ j, j < S.body.code.size → y2.mem (addrAt S.ctx j) = y.mem (addrAt S.ctx j) :=
    fun j hj => hcode _ (.inl ⟨j, hj, rfl⟩)
  have hcodeF : LinkOkF S.ctx y2.mem S.body S.rs S.c.mode := by
    obtain ⟨hfl, hso, ⟨hl1, hl2⟩, hsm, hfpc⟩ := hf.code
    refine ⟨hfl, hso, ⟨fun j hj hr' => ?_, fun r hr' k hk => ?_⟩, hsm, hfpc⟩
    · rw [hc j hj]; exact hl1 j hj hr'
    · rw [hc _ (by have := H.relocsIn r hr'; omega)]; exact hl2 r hr' k hk
  have hroF : RoLoaded S.ctx y2.mem S.ro := by
    obtain ⟨base, h1, h2⟩ := hf.ro
    refine ⟨base, h1, fun j hj => ?_⟩
    rw [hcode _ (.inr ⟨j, hj, (h1 j).symm⟩)]
    exact h2 j hj
  -- `args`, `frame`, `esc`
  have hargsF : LeadArg S s2.pc → ArgsLive S s2.pc s2.args y2 := by
    rw [hpc, hargs]
    exact fun ha r hr' hfr => (hf.args ha r hr' hfr).congr (fun i _ => by rw [hr])
      (fun i _ => by rw [hx])
  have hfrF : FrameFacts S y2 := by
    obtain ⟨f1, f2, f3, f5⟩ := hf.frame
    refine ⟨(by rw [hrbp]; exact f1), ?_, fun h3 => ?_, (fun i hi h5 => by rw [hr]; exact f5 i hi h5)⟩
    · rw [hrbp, ← f2]
      apply ds_read64_congr
      intro i hi
      rw [ds_addr8]
      exact hlink (8 + i) (by omega)
    · rw [hrbp, ← f3 h3]
      apply ds_read64_congr
      intro i hi
      rw [ds_addr_nat]
      exact hlink i (by omega)
  have hescF : Discharge.EscFrom.EscFrom S.c (LeadArg S s2.pc) s2.pc s2.st := by
    rw [hpc]
    exact hf.esc.congr hesc
  exact
    { rrel := ⟨⟨hRf, hlay, hzs'⟩, hrb, hwf⟩
      mem := hmr
      sep := hsep
      win := by rw [hfp]; exact hf.win
      fpF := by rw [hfp]; exact hf.fpF
      rsp := by rw [hrsp, hrbp]; exact hf.rsp
      room := by rw [hrsp]; exact hf.room
      code := hcodeF
      ro := hroF
      args := hargsF
      frame := hfrF
      slots := hsl
      esc := hescF }

/-! ### The shadow -/

/-- The real machine relates to the shadow: `FrameInvR` of `erase s P` on `x`. -/
theorem frameInvR_erase (H : Hyps S) (C : Cert S) {s : R.RState} {P : Int → Prop}
    {x xh : X86.State} (hfr : FrameInvR S s xh) (ha : XAgree S P x xh) (hP : PatchOk S C s P)
    (he : EscSound S C s) : FrameInvR S (erase s P) x := by
  have hF := ds_F_lt H
  obtain ⟨hvr, hvx, -, -, hvm⟩ := xAgree_virt ha
  have hf := hfr.1
  have hpriv : ∀ o, P o → s.st.escapedAt o = none := fun o ho => (hP o ho).2.2.1
  have hP' : ∀ o, P o → -(S.c.d.frameSize : Int) ≤ o ∧ o < 0 := fun o ho => (hP o ho).1
  have hm : ∀ a, (∀ o, P o → a ≠ fpAddr (S.virt xh) o) → (S.virt x).mem a = (S.virt xh).mem a :=
    fun a hne => hvm a (fun o ho => hne o ho)
  have hst : (erase s P).st = eraseSt P s.st := rfl
  have hsh : DsShape s.st.mem (erase s P).st.mem :=
    ⟨rfl, fun id a2 h => ⟨a2, h, rfl, rfl, rfl⟩⟩
  have hinit : ∀ o, (erase s P).st.escapedAt o = none → (erase s P).st.frame o ≠ .uninit →
      s.st.frame o ≠ .uninit ∨ P o := by
    intro o _ hu
    by_cases hp : P o
    · exact .inr hp
    · left
      simpa [erase, eraseSt, hp] using hu
  have hkeep : ∀ o, ¬ P o → ∀ b, (erase s P).st.byteAt o = .ok b → s.st.byteAt o = .ok b :=
    fun o hp b hb => (ds_erase_byteAt hpriv hb).2 hp
  have hpatch : ∀ o, P o → ∀ b, (erase s P).st.byteAt o = .ok b →
      ByteRel b ((S.virt x).mem (fpAddr (S.virt xh) o)) := fun o hp b hb => by
    rw [(ds_erase_byteAt hpriv hb).1 hp]
    trivial
  have hmr : MemRel (erase s P).st (S.virt x) := by
    intro id a hg hl i hi
    have hg' : s.st.mem.get? id = some a := hg
    show ByteRel a.data[i] ((S.virt x).mem (BitVec.ofNat 64 (a.addr + i)))
    rw [ds_byte_keep H hf hP' hm hg' hl hi (ds_priv_not_obj hf hpriv hg' hi)]
    exact hf.mem id a hg' hl i hi
  have hsl : Discharge.PeStackArg.ArgSlots S.c (erase s P).st := by
    intro o h1 h2
    obtain ⟨he', hu⟩ := hf.slots o h1 h2
    refine ⟨he', ?_⟩
    by_cases hp : P o <;> simp [erase, eraseSt, hp, hu]
  exact ⟨ds_transfer H hf rfl rfl rfl hvr hvx hP' hm rfl rfl hsh hinit hkeep hpatch hmr hsl,
    rbpOk_of_xAgree ha hfr.2⟩

/-- A byte `Dropped` marks is in some dropped store's range, at or above its slot. -/
theorem ds_dropped_store {o : Int} (hd : Dropped S o) (hlo : -(S.c.d.frameSize : Int) ≤ o) :
    ∃ k ∈ S.c.d.dropped.toList, ∃ s w, Frame.droppedStore S.c.d k = some (s, w) ∧
      s.toInt ≤ o ∧ o < s.toInt + w := by
  unfold Dropped Frame.droppedBits at hd
  rw [← Array.foldl_toList, testBit_foldl_or, Nat.zero_testBit, Bool.false_or] at hd
  obtain ⟨k, hk, hb⟩ := List.any_eq_true.1 hd
  unfold Frame.droppedBitsAt at hb
  cases hs : Frame.droppedStore S.c.d k with
  | none => rw [hs] at hb; simp at hb
  | some p =>
    obtain ⟨s, w⟩ := p
    rw [hs, testBit_bitsOf] at hb
    refine ⟨k, hk, s, w, hs, ?_⟩
    simp only [Frame.range, bit, Bool.and_eq_true] at hb
    obtain ⟨h1, h2⟩ := hb
    have h1 := of_decide_eq_true h1
    have h2 := of_decide_eq_true h2
    constructor <;> omega

/-- No dropped store writes PE's stack-argument slots `[-F + 32, frameLo)`, given that each
dropped store's destination is at or above `frameLo` or ends at or below `-F + 32`. -/
theorem ds_dropped_not_slot_of
    (hslot : ∀ k ∈ S.c.d.dropped.toList, ∀ s w, Frame.droppedStore S.c.d k = some (s, w) →
      S.c.d.frameLo S.c.mode ≤ s.toInt ∨ s.toInt + w ≤ -(S.c.d.frameSize : Int) + 32)
    {o : Int} (hd : Dropped S o) (h1 : -(S.c.d.frameSize : Int) + 32 ≤ o)
    (h2 : o < S.c.d.frameLo S.c.mode) : False := by
  obtain ⟨k, hk, s, w, hs, hle, hlt⟩ := ds_dropped_store hd (by omega)
  have := hslot k hk s w hs
  omega

/-- No dropped store writes PE's stack-argument slots `[-F + 32, frameLo)`: the check put each
dropped store's destination out of them (`Cert.hframe`, `droppedInFrame_spec`). -/
theorem ds_dropped_not_slot (_H : Hyps S) (C : Cert S) {o : Int} (hd : Dropped S o)
    (h1 : -(S.c.d.frameSize : Int) + 32 ≤ o) (h2 : o < S.c.d.frameLo S.c.mode) : False :=
  ds_dropped_not_slot_of (fun k hk _ _ hs => droppedInFrame_spec (C.hframe k hk) hs) hd h1 h2

/-- `CacheInv` survives a memory change outside every slot the cache caches. -/
theorem cacheInv_mem_congr {c : Asm.Cache} {x y : X86.State} (h : CacheInv c x)
    (hr : y.regs = x.regs)
    (hm : ∀ e ∈ c.regs.toList, ∀ sl w, e.slot = some (sl, w) → ∀ j < Asm.bytes w,
      y.mem (x.ea (M.frame sl) + BitVec.ofNat 64 j) = x.mem (x.ea (M.frame sl) + BitVec.ofNat 64 j)) :
    CacheInv c y := by
  have hreg : ∀ r, y.reg r = x.reg r := fun r => by simp only [X86.State.reg, hr]
  refine ⟨h.1, fun i hi => ?_⟩
  obtain ⟨h1, h2⟩ := h.2 i hi
  have hmem : c.regs[i] ∈ c.regs.toList := by simp
  refine ⟨fun sl w hs => ?_, fun z hz => by rw [hreg]; exact h2 z hz⟩
  have hea : y.ea (M.frame sl) = x.ea (M.frame sl) := by
    simp only [X86.State.ea, M.frame, hreg]
  rw [hreg, h1 sl w hs, hea]
  exact Ryo.Proofs.RegCache.readNat_congr _ _ _ _ (fun j hj => (hm _ hmem sl w hs j hj).symm)

/-- Re-ghost after a non-inline step: R's `s'` differs from the shadow successor `t'` (related
to the real `x'`) only at `P'`, where `t'` is `Uninit`; the cache `x'` holds at its boundary
(`hpos`) caches no slot touching `P'`, so the patched ghost holds it too (`cacheInv_mem_congr`). -/
theorem binv_of_agree (H : Hyps S) (C : Cert S) {s' t' : R.RState} {x' : X86.State}
    {P' : Int → Prop} (hfr : FrameInvR S t' x')
    (hpos : ∃ c : Asm.Cache, ((x'.rip = addrAt S.ctx (S.start t'.pc) ∧ c = S.cache t'.pc) ∨
        (x'.rip = addrAt S.ctx (posOf S.r t'.pc) ∧ c = S.used t'.pc)) ∧ CacheInv c (S.virt x') ∧
      ∀ e ∈ c.regs.toList, ∀ sl w, e.slot = some (sl, w) → ∀ o, P' o →
        sl.toInt ≤ o → o < sl.toInt + Asm.bytes w → s'.st.byteAt o = .ok .uninit)
    (hag : RAgree P' s' t') (hun : ∀ o, P' o → t'.st.byteAt o = .ok .uninit)
    (hP : PatchOk S C s' P') :
    ∃ xh, BInv S s' xh ∧ XAgree S P' x' xh := by
  have hF := ds_F_lt H
  obtain ⟨hpc, hfp, hargs, hesc0, hzs0, hME, -, -, hfrm⟩ := hag
  have hesc : s'.st.escaped = t'.st.escaped := hesc0
  have hzs : s'.st.zeroSized = t'.st.zeroSized := hzs0
  have hf := hfr.1
  have hME' : s'.st.mem = t'.st.mem := hME
  have hpriv' : ∀ o, P' o → t'.st.escapedAt o = none := fun o ho =>
    (ds_escapedAt_eq hesc).symm.trans (hP o ho).2.2.1
  have hP' : ∀ o, P' o → -(S.c.d.frameSize : Int) ≤ o ∧ o < 0 := fun o ho => (hP o ho).1
  have hPb : ∀ o, P' o → -2 ^ 63 ≤ o ∧ o < 2 ^ 63 := fun o ho => by
    have := hP' o ho
    omega
  obtain ⟨xh, hxr, hxx, hxf, hxrip, hxm⟩ : ∃ xh : X86.State, xh.regs = x'.regs ∧
      xh.xmm = x'.xmm ∧ xh.flags = x'.flags ∧ xh.rip = x'.rip ∧
      xh.mem = ds_patchMem (vfp S x') P' s'.st x'.mem :=
    ⟨{ x' with mem := ds_patchMem (vfp S x') P' s'.st x'.mem }, rfl, rfl, rfl, rfl, rfl⟩
  have hvr : (S.virt xh).regs = (S.virt x').regs := funext fun i =>
    setup_virt_regs_congr S (x := x') (y := xh) (P := fun _ => True) (fun i _ => by rw [hxr])
      (by simp only [X86.State.rsp, X86.State.reg, hxr]) i trivial
  have hvx : (S.virt xh).xmm = (S.virt x').xmm := by rw [setup_virt_xmm, setup_virt_xmm, hxx]
  have hvfp : vfp S xh = vfp S x' := by
    unfold vfp
    simp only [X86.State.reg, hvr]
  have hmm : (S.virt xh).mem = ds_patchMem (vfp S x') P' s'.st x'.mem := by
    rw [setup_virt_mem, hxm]
  have hmv : ∀ a, (∀ o, P' o → a ≠ fpAddr (S.virt x') o) →
      (S.virt xh).mem a = (S.virt x').mem a := fun a hne => by
    rw [hmm, setup_virt_mem]
    exact ds_patch_off (fun o ho => hne o ho)
  have hsh : DsShape t'.st.mem s'.st.mem :=
    ⟨by rw [hME'], fun id a2 h => ⟨a2, by rw [← hME']; exact h, rfl, rfl, rfl⟩⟩
  have hframe : ∀ o, ¬ P' o → s'.st.escapedAt o = none → s'.st.frame o = t'.st.frame o := by
    intro o hp hn
    have := hfrm o hn
    simp only [eraseSt, hp, ↓reduceIte] at this
    exact this
  have hinit : ∀ o, s'.st.escapedAt o = none → s'.st.frame o ≠ .uninit →
      t'.st.frame o ≠ .uninit ∨ P' o := by
    intro o hn hu
    by_cases hp : P' o
    · exact .inr hp
    · left
      rw [← hframe o hp hn]
      exact hu
  have hkeep : ∀ o, ¬ P' o → ∀ b, s'.st.byteAt o = .ok b → t'.st.byteAt o = .ok b := by
    intro o hp b hb
    rcases ds_byteAt_ok hb with ⟨hn, hfr'⟩ | ⟨e, a2, hes, ha2, hl, hd⟩
    · have hn' : t'.st.escapedAt o = none := by rw [← ds_escapedAt_eq hesc]; exact hn
      rw [ds_byteAt_of_none hn', ← hfr', hframe o hp hn]
    · have hes' : t'.st.escapedAt o = some e := by rw [← ds_escapedAt_eq hesc]; exact hes
      exact ds_byteAt_of_some hes' (by rw [← hME']; exact ha2) hl hd
  have hpatch : ∀ o, P' o → ∀ b, s'.st.byteAt o = .ok b →
      ByteRel b ((S.virt xh).mem (fpAddr (S.virt x') o)) := fun o ho b hb => by
    rw [hmm]
    exact ds_patch_at hPb ho hb
  have hmr : MemRel s'.st (S.virt xh) := by
    intro id a hg hl i hi
    have ha1 : t'.st.mem.get? id = some a := by rw [← hME']; exact hg
    show ByteRel a.data[i] ((S.virt xh).mem (BitVec.ofNat 64 (a.addr + i)))
    rw [ds_byte_keep H hf hP' hmv ha1 hl hi (ds_priv_not_obj hf hpriv' ha1 hi)]
    exact hf.mem id a ha1 hl i hi
  have hsl : Discharge.PeStackArg.ArgSlots S.c s'.st := by
    intro o h1 h2
    obtain ⟨hn, hu⟩ := hf.slots o h1 h2
    have hn' : s'.st.escapedAt o = none := by rw [ds_escapedAt_eq hesc]; exact hn
    refine ⟨hn', ?_⟩
    by_cases hp : P' o
    · rcases (hP o hp).2.2.2 with hd | ⟨hu', -⟩
      · exact (ds_dropped_not_slot H C (hP o hp).2.1 h1 h2).elim
      · rw [ds_byteAt_of_none hn'] at hu'
        exact Except.ok.inj hu'
    · rw [hframe o hp hn']
      exact hu
  have hFI : FrameInv S s' (S.virt xh) :=
    ds_transfer H hf hpc hfp hargs hvr hvx hP' hmv hesc hzs hsh hinit hkeep hpatch hmr hsl
  have hrbpOk : RbpOk S xh := fun h => by
    rw [show xh.reg .rbp = x'.reg .rbp by simp only [X86.State.reg, hxr]]
    exact hfr.2 h
  refine ⟨xh, ⟨⟨hFI, hrbpOk⟩, ?_⟩, ?_⟩
  · rw [hpc, hxrip]
    obtain ⟨c, hcp, hci, hmiss⟩ := hpos
    have hcx : CacheInv c (S.virt xh) := by
      refine cacheInv_mem_congr hci hvr fun e he sl w hs j hj => ?_
      rw [hmm, setup_virt_mem]
      generalize hA : (S.virt x').ea (M.frame sl) + BitVec.ofNat 64 j = A
      unfold ds_patchMem
      split
      · rename_i h
        have hw : Asm.bytes w ≤ 64 := by cases w <;> decide
        have h1 := BitVec.le_toInt sl
        have h2 := @BitVec.toInt_lt 32 sl
        obtain ⟨ho, heq0⟩ := Classical.choose_spec h
        have heq : (S.virt x').ea (M.frame sl) + BitVec.ofNat 64 j = fpAddr (S.virt x') (Classical.choose h) := by
          rw [hA]; exact heq0
        rw [ea_frame, ← fpAddr_add] at heq
        have hoe := ds_off_inj (fp := (S.virt x').reg .rbp) ⟨(by omega), (by omega)⟩
          (hPb _ ho) heq
        have hun' := hmiss e he sl w hs _ ho (by omega) (by omega)
        rw [hun'] <;> rfl
      · rfl
    rcases hcp with ⟨h1, rfl⟩ | ⟨h1, rfl⟩
    · exact .inl ⟨h1, hcx⟩
    · exact .inr ⟨h1, hcx⟩
  · unfold XAgree XAgreeAt MemAgree
    refine ⟨hxr.symm, hxx.symm, hxf.symm, hxrip.symm, fun a ha => ?_⟩
    have hne : ∀ o, P' o → a ≠ vfp S x' + BitVec.ofInt 64 o := fun o ho => by
      rw [← hvfp]
      exact ha o ho
    rw [hxm, ds_patch_off hne]

/-- `binv_of_agree` as a `DInv` boundary. -/
theorem dinv_of_agree (H : Hyps S) (C : Cert S) {s' t' : R.RState} {x' : X86.State}
    {P' : Int → Prop} (hfr : FrameInvR S t' x')
    (hpos : ∃ c : Asm.Cache, ((x'.rip = addrAt S.ctx (S.start t'.pc) ∧ c = S.cache t'.pc) ∨
        (x'.rip = addrAt S.ctx (posOf S.r t'.pc) ∧ c = S.used t'.pc)) ∧ CacheInv c (S.virt x') ∧
      ∀ e ∈ c.regs.toList, ∀ sl w, e.slot = some (sl, w) → ∀ o, P' o →
        sl.toInt ≤ o → o < sl.toInt + Asm.bytes w → s'.st.byteAt o = .ok .uninit)
    (hag : RAgree P' s' t') (hun : ∀ o, P' o → t'.st.byteAt o = .ok .uninit)
    (hP : PatchOk S C s' P') (he : EscSound S C s') (hkr : KrInv S C s' P') :
    DInv S (some C) s' x' := by
  obtain ⟨xh, hb, ha⟩ := binv_of_agree H C hfr hpos hag hun hP
  exact ⟨P', xh, (And.intro hP (fun _ => he) :
      PatchOk S C s' P' ∧ (s'.pc < S.c.d.insns.size → EscSound S C s')), hb, ha,
    fun C' hC' _ => by cases hC'; exact hkr⟩

open Classical in
/-- Re-choose the ghost at bytes R holds `Uninit` that the boundary's cache doesn't cover: the
ghost takes the real machine's bytes there (`ByteRel .uninit` relates anything; no `Holds`
reads them), and they leave `P`. `Q` must lie in the frame (`InFrame`): at the link slots or
outside the frame the ghost's bytes are read by `FrameFacts`/`LinkOkF` too. -/
theorem ghost_drop_uninit (H : Hyps S) {s : R.RState} {P Q : Int → Prop} {x xh : X86.State}
    (hbi : BInv S s xh) (ha : XAgree S P x xh)
    (hq : ∀ o, Q o → InFrame S o ∧ s.st.byteAt o = .ok .uninit ∧ s.st.escapedAt o = none ∧
      ¬ CacheCovers S s.pc o) :
    ∃ xh', BInv S s xh' ∧ XAgree S (fun o => P o ∧ ¬ Q o) x xh' := by
  have hF := ds_F_lt H
  obtain ⟨⟨hf, hrbpOk⟩, hpos⟩ := hbi
  obtain ⟨hxr, hxx, hxf, hxrip, hxm⟩ := ha
  let fp := vfp S xh
  let mem' : X86.Mem := fun a => if ∃ o, Q o ∧ a = fp + BitVec.ofInt 64 o then x.mem a else xh.mem a
  let xh' : X86.State := { xh with mem := mem' }
  have hr' : xh'.regs = xh.regs := rfl
  have hvr : (S.virt xh').regs = (S.virt xh).regs := funext fun i =>
    setup_virt_regs_congr S (x := xh) (y := xh') (P := fun _ => True) (fun i _ => by rw [hr'])
      (by simp only [X86.State.rsp, X86.State.reg, hr']) i trivial
  have hvx : (S.virt xh').xmm = (S.virt xh).xmm := by rw [setup_virt_xmm, setup_virt_xmm] <;> rfl
  have hvfp : vfp S xh' = vfp S xh := by
    unfold vfp
    simp only [X86.State.reg, hvr]
  have hQ' : ∀ o, Q o → -(S.c.d.frameSize : Int) ≤ o ∧ o < 0 := fun o ho => (hq o ho).1
  have hQb : ∀ o, Q o → -2 ^ 63 ≤ o ∧ o < 2 ^ 63 := fun o ho => by
    have := hQ' o ho
    omega
  have hpriv : ∀ o, Q o → s.st.escapedAt o = none := fun o ho => (hq o ho).2.2.1
  have hm : ∀ a, (∀ o, Q o → a ≠ fpAddr (S.virt xh) o) → (S.virt xh').mem a = (S.virt xh).mem a := by
    intro a hne
    rw [setup_virt_mem, setup_virt_mem]
    have hn : ¬ ∃ o, Q o ∧ a = fp + BitVec.ofInt 64 o := by
      rintro ⟨o, ho, rfl⟩
      exact hne o ho rfl
    show (if ∃ o, Q o ∧ a = fp + BitVec.ofInt 64 o then x.mem a else xh.mem a) = xh.mem a
    rw [if_neg hn]
  have hsh : DsShape s.st.mem s.st.mem := ⟨rfl, fun id a2 h => ⟨a2, h, rfl, rfl, rfl⟩⟩
  have hpatch : ∀ o, Q o → ∀ b, s.st.byteAt o = .ok b →
      ByteRel b ((S.virt xh').mem (fpAddr (S.virt xh) o)) := fun o ho b hb => by
    have hb' := Except.ok.inj ((hq o ho).2.1.symm.trans hb)
    subst hb'
    trivial
  have hmr : MemRel s.st (S.virt xh') := by
    intro id a hg hl i hi
    show ByteRel a.data[i] ((S.virt xh').mem (BitVec.ofNat 64 (a.addr + i)))
    rw [ds_byte_keep H hf hQ' hm hg hl hi (ds_priv_not_obj hf hpriv hg hi)]
    exact hf.mem id a hg hl i hi
  have hFI : FrameInv S s (S.virt xh') :=
    ds_transfer H hf rfl rfl rfl hvr hvx hQ' hm rfl rfl hsh (fun o _ hu => .inl hu)
      (fun _ _ _ hb => hb) hpatch hmr hf.slots
  have hrbp' : RbpOk S xh' := fun h => hrbpOk h
  -- the cache: its slots miss `Q`
  have hcache : ∀ c : Asm.Cache, (c = S.cache s.pc ∨ c = S.used s.pc) →
      CacheInv c (S.virt xh) → CacheInv c (S.virt xh') := by
    intro c hc hci
    refine cacheInv_mem_congr hci hvr fun e he sl w hs j hj => hm _ fun o ho heq => ?_
    have hw : Asm.bytes w ≤ 64 := by cases w <;> decide
    have h1 := BitVec.le_toInt sl
    have h2 := @BitVec.toInt_lt 32 sl
    rw [ea_frame, ← fpAddr_add] at heq
    have hoe := ds_off_inj (fp := (S.virt xh).reg .rbp) ⟨(by omega), (by omega)⟩ (hQb o ho) heq
    exact (hq o ho).2.2.2 ⟨c, hc, e, he, sl, w, hs, (by omega), (by omega)⟩
  refine ⟨xh', ⟨⟨hFI, hrbp'⟩, ?_⟩, ?_⟩
  · rcases hpos with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact .inl ⟨h1, hcache _ (.inl rfl) h2⟩
    · exact .inr ⟨h1, hcache _ (.inr rfl) h2⟩
  · unfold XAgree XAgreeAt MemAgree
    refine ⟨hxr, hxx, hxf, hxrip, fun a hne => ?_⟩
    rw [hvfp] at hne
    show x.mem a = (if ∃ o, Q o ∧ a = fp + BitVec.ofInt 64 o then x.mem a else xh.mem a)
    by_cases hQa : ∃ o, Q o ∧ a = fp + BitVec.ofInt 64 o
    · rw [if_pos hQa]
    · rw [if_neg hQa]
      refine hxm a fun o hp heq => ?_
      by_cases hqo : Q o
      · exact hQa ⟨o, hqo, heq⟩
      · exact hne o ⟨hp, hqo⟩ heq

end Ryo.Proofs.DeadStore
