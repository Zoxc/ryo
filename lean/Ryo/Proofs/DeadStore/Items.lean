/-
Ryo.Proofs.DeadStore.Items — the x86 ghost for inline sequences (design T4; statements from T0).

The ghost runs `out` (the dropped stores included) by `execItems`, as
`CacheStep.inline_step_cached` does; the real machine runs `kept` (`SkipAt`, the code in memory).
Both run on virtual states (`XAgreeAt` with the virtual frame pointer, `Rel.xAgree_virt`), from
the same `rip`. The ghost after is re-jumped to the real `rip` (`Defs`' module comment).

- `skipAt_split`: the dropped stores consumed are a prefix of `dr`.
- `pureStore_of_form`: a `DroppedForm` store is a `PureStore`.
- `execItems_skip`: the kept run exists and agrees with the ghost's but at
  `(P ∪ DropW ds) \ KeptW kept`.
- `keptApart_of_live` (hard half): the kept items of an inline instruction read no byte of a
  patch set, from the liveness (`gen` holds their frame reads) and, for pointer items, escape
  soundness and the frame's separation.
-/
import Ryo.Proofs.DeadStore.Defs
import Ryo.Proofs.DecodeLink.Drop
import Ryo.Proofs.CacheEmitWrites

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink
  Ryo.Proofs.RegCache

variable {S : Setup}

theorem skipAt_split {p : Nat} {dr dr' : List Asm.DroppedStore} {out kept : List Item}
    (h : SkipAt p dr out kept dr') : ∃ ds, dr = ds ++ dr' := by
  induction h with
  | nil p dr => exact ⟨[], rfl⟩
  | keep _ ih => exact ih
  | drop _ _ ih =>
    obtain ⟨ds, h⟩ := ih
    subst h
    exact ⟨_ :: ds, rfl⟩

/-- `fp + d + j` as a frame offset. -/
theorem addr_off (fp : BitVec 64) (d : BitVec 32) (j : Nat) :
    fp + d.signExtend 64 + BitVec.ofNat 64 j = fp + BitVec.ofInt 64 (d.toInt + (j : Int)) := by
  rw [BitVec.ofInt_add, BitVec.ofInt_natCast, BitVec.add_assoc]
  rfl

/-- A frame write is `rbp`-based. -/
theorem frameWrite_base {it : Item} {m : X86.M} {n : Nat} (h : Asm.frameWrite it = some (m, n)) :
    m.base = .rbp := by
  unfold Asm.frameWrite at h
  split at h
  all_goals first
    | (split at h <;> simp_all)
    | simp_all

theorem xAgreeAt_mono {fp : BitVec 64} {Q Q' : Int → Prop} {x y : X86.State}
    (h : XAgreeAt fp Q x y) (hq : ∀ o, Q o → Q' o) : XAgreeAt fp Q' x y := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := h
  exact ⟨h1, h2, h3, h4, fun a ha => h5 a (fun o ho => ha o (hq o ho))⟩

theorem itemApart_mono {fp : BitVec 64} {P Q : Int → Prop} {it : Item} {y : X86.State}
    (h : ItemApart fp P it y) (hq : ∀ o, Q o → P o) : ItemApart fp Q it y :=
  fun m hm j hj o ho => h m hm j hj o (hq o ho)

theorem pureStore_of_form (ctx : Ctx) {d : Asm.DroppedStore} (h : DroppedForm d) :
    PureStore ctx d.item := by
  obtain ⟨w, r, off, he⟩ := h
  rw [he]
  refine ⟨X86.M.frame off, w.bits / 8,
    (by first | rfl | decide | simp [Asm.frameWrite, X86.M.frame]), ?_⟩
  intro y y' hy
  have hy' : Except.ok ((y.jump (y.rip + BitVec.ofNat 64 (Item.st w r (X86.M.frame off)).size)).setMemW
      w (y.ea (X86.M.frame off)) (y.regW w r)) = (Except.ok y' : Except X86.Fault X86.State) := hy
  simp only [Except.ok.injEq] at hy'
  subst hy'
  refine ⟨rfl, rfl, rfl, ?_⟩
  intro a ha
  show X86.Mem.write y.mem (y.ea (X86.M.frame off)) (w.bits / 8) (y.regW w r).toNat a = y.mem a
  refine X86.Mem.write_other _ _ _ _ _ ?_
  refine Nat.le_of_not_lt fun hlt => ha _ hlt ?_
  first
    | bv_omega
    | (rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]; simp)

/-- An item reading no memory: its memory operand (if any) is a pure frame store's, and it is no
`rip`-relative load (the items after a dropped store: `setcc cl`, the flag store). -/
def NoRead (it : Item) : Prop :=
  (∀ m, it.mem? = some m → readBytes it = 0) ∧
    ∀ r to, it ≠ .loadRip r to

/-! ### `item_agree`'s helpers -/

/-- The `cacheSafe` items writing memory. -/
def itmWr : Item → Bool
  | .st .. | .stImm .. | .setcc .. => true
  | _ => false

theorem itm_bytes_le (w : X86.W) : w.bits / 8 ≤ 8 := by cases w <;> decide

theorem itm_memW_jump (s : X86.State) (a : BitVec 64) (w : X86.W) (b : BitVec 64) :
    (s.jump a).memW w b = s.memW w b := rfl
theorem itm_ea_jump (s : X86.State) (a : BitVec 64) (m : X86.M) : (s.jump a).ea m = s.ea m := rfl
theorem itm_rmW_jump (s : X86.State) (a : BitVec 64) (w : X86.W) (rm : X86.Rm) :
    (s.jump a).rmW w rm = s.rmW w rm := by cases rm <;> rfl
theorem itm_regW_jump (s : X86.State) (a : BitVec 64) (w : X86.W) (r : X86.Reg) :
    (s.jump a).regW w r = s.regW w r := rfl
theorem itm_reg_jump (s : X86.State) (a : BitVec 64) (r : X86.Reg) : (s.jump a).reg r = s.reg r := rfl
theorem itm_flags_jump (s : X86.State) (a : BitVec 64) : (s.jump a).flags = s.flags := rfl
theorem itm_mem_jump (s : X86.State) (a : BitVec 64) : (s.jump a).mem = s.mem := rfl
theorem itm_ea_wm (s : X86.State) (m : X86.Mem) (mm : X86.M) :
    ({ s with mem := m } : X86.State).ea mm = s.ea mm := rfl
theorem itm_regW_wm (s : X86.State) (m : X86.Mem) (w : X86.W) (r : X86.Reg) :
    ({ s with mem := m } : X86.State).regW w r = s.regW w r := rfl
theorem itm_reg_wm (s : X86.State) (m : X86.Mem) (r : X86.Reg) :
    ({ s with mem := m } : X86.State).reg r = s.reg r := rfl

theorem itm_wm_jump (s : X86.State) (m : X86.Mem) (a : BitVec 64) :
    ({ s with mem := m } : X86.State).jump a = { s.jump a with mem := m } := rfl
theorem itm_wm_setReg (s : X86.State) (m : X86.Mem) (r : X86.Reg) (v : BitVec 64) :
    ({ s with mem := m } : X86.State).setReg r v = { s.setReg r v with mem := m } := rfl
theorem itm_wm_setRegW (s : X86.State) (m : X86.Mem) (w : X86.W) (r : X86.Reg)
    (v : BitVec w.bits) :
    ({ s with mem := m } : X86.State).setRegW w r v = { s.setRegW w r v with mem := m } := by
  cases w <;> rfl
theorem itm_wm_setFlags (s : X86.State) (m : X86.Mem) (f : Flags) :
    ({ s with mem := m } : X86.State).setFlags f = { s.setFlags f with mem := m } := rfl
theorem itm_wm_flags (s : X86.State) (m : X86.Mem) :
    ({ s with mem := m } : X86.State).flags = s.flags := rfl
theorem itm_wm_mem (s : X86.State) (m : X86.Mem) :
    ({ s with mem := m } : X86.State).mem = m := rfl

theorem itm_ea_lit (s : X86.State) (a : BitVec 64) (f : Flags) (x : Fin 16 → BitVec 128)
    (m : X86.Mem) (mm : X86.M) :
    ({ regs := s.regs, rip := a, flags := f, xmm := x, mem := m } : X86.State).ea mm = s.ea mm := rfl
theorem itm_reg_lit (s : X86.State) (a : BitVec 64) (f : Flags) (x : Fin 16 → BitVec 128)
    (m : X86.Mem) (r : X86.Reg) :
    ({ regs := s.regs, rip := a, flags := f, xmm := x, mem := m } : X86.State).reg r = s.reg r := rfl
theorem itm_regW_lit (s : X86.State) (a : BitVec 64) (f : Flags) (x : Fin 16 → BitVec 128)
    (m : X86.Mem) (w : X86.W) (r : X86.Reg) :
    ({ regs := s.regs, rip := a, flags := f, xmm := x, mem := m } : X86.State).regW w r =
      s.regW w r := rfl

/-! Per item constructor (each its own heartbeat budget), as `CacheStep.exec_swap`: split the
run on `s` (`h`) only, then normalize the other run with the splits' equations. -/

theorem itmx_setReg {ctx : Ctx} (r : X86.Reg) (v : BitVec 64) (hs : cacheSafe (Item.setReg r v) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.setReg r v).mem? = some mm' → ∀ j < readBytes (Item.setReg r v),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.setReg r v) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.setReg r v).exec ctx s = .ok z) :
    (Item.setReg r v).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_lea {ctx : Ctx} (r : X86.Reg) (to : X86.Ref) (hs : cacheSafe (Item.lea r to) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.lea r to).mem? = some mm' → ∀ j < readBytes (Item.lea r to),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.lea r to) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.lea r to).exec ctx s = .ok z) :
    (Item.lea r to).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_loadRip {ctx : Ctx} (r : X86.Reg) (to : X86.Ref) (hs : cacheSafe (Item.loadRip r to) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.loadRip r to).mem? = some mm' → ∀ j < readBytes (Item.loadRip r to),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.loadRip r to) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.loadRip r to).exec ctx s = .ok z) :
    (Item.loadRip r to).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_ld {ctx : Ctx} (w : X86.W) (sx : Bool) (dst : X86.Reg) (mm : X86.M) (hs : cacheSafe (Item.ld w sx dst mm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.ld w sx dst mm).mem? = some mm' → ∀ j < readBytes (Item.ld w sx dst mm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.ld w sx dst mm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.ld w sx dst mm).exec ctx s = .ok z) :
    (Item.ld w sx dst mm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_leaM {ctx : Ctx} (dst : X86.Reg) (mm : X86.M) (hs : cacheSafe (Item.leaM dst mm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.leaM dst mm).mem? = some mm' → ∀ j < readBytes (Item.leaM dst mm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.leaM dst mm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.leaM dst mm).exec ctx s = .ok z) :
    (Item.leaM dst mm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_alu {ctx : Ctx} (op : X86.Alu) (w : X86.W) (reg : X86.Reg) (rm : X86.Rm) (hs : cacheSafe (Item.alu op w reg rm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.alu op w reg rm).mem? = some mm' → ∀ j < readBytes (Item.alu op w reg rm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.alu op w reg rm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.alu op w reg rm).exec ctx s = .ok z) :
    (Item.alu op w reg rm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_aluImm {ctx : Ctx} (op : X86.Alu) (w : X86.W) (rm : X86.Rm) (imm : BitVec 32) (hs : cacheSafe (Item.aluImm op w rm imm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.aluImm op w rm imm).mem? = some mm' → ∀ j < readBytes (Item.aluImm op w rm imm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.aluImm op w rm imm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.aluImm op w rm imm).exec ctx s = .ok z) :
    (Item.aluImm op w rm imm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_imul {ctx : Ctx} (w : X86.W) (reg : X86.Reg) (rm : X86.Rm) (hs : cacheSafe (Item.imul w reg rm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.imul w reg rm).mem? = some mm' → ∀ j < readBytes (Item.imul w reg rm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.imul w reg rm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.imul w reg rm).exec ctx s = .ok z) :
    (Item.imul w reg rm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_imulImm {ctx : Ctx} (w : X86.W) (reg : X86.Reg) (rm : X86.Rm) (imm : BitVec 32) (hs : cacheSafe (Item.imulImm w reg rm imm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.imulImm w reg rm imm).mem? = some mm' → ∀ j < readBytes (Item.imulImm w reg rm imm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.imulImm w reg rm imm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.imulImm w reg rm imm).exec ctx s = .ok z) :
    (Item.imulImm w reg rm imm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_shift {ctx : Ctx} (op : X86.Sh) (w : X86.W) (reg : X86.Reg) (amt : BitVec 8) (hs : cacheSafe (Item.shift op w reg amt) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.shift op w reg amt).mem? = some mm' → ∀ j < readBytes (Item.shift op w reg amt),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.shift op w reg amt) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.shift op w reg amt).exec ctx s = .ok z) :
    (Item.shift op w reg amt).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_testM8 {ctx : Ctx} (mm : X86.M) (hs : cacheSafe (Item.testM8 mm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.testM8 mm).mem? = some mm' → ∀ j < readBytes (Item.testM8 mm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.testM8 mm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.testM8 mm).exec ctx s = .ok z) :
    (Item.testM8 mm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_setccCl {ctx : Ctx} (cond : X86.Cond) (hs : cacheSafe (Item.setccCl cond) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.setccCl cond).mem? = some mm' → ∀ j < readBytes (Item.setccCl cond),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.setccCl cond) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.setccCl cond).exec ctx s = .ok z) :
    (Item.setccCl cond).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  all_goals (try (simp only [Bool.false_eq_true, ↓reduceIte]; rfl))
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_mulQ {ctx : Ctx} (rm : X86.Rm) (hs : cacheSafe (Item.mulQ rm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.mulQ rm).mem? = some mm' → ∀ j < readBytes (Item.mulQ rm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.mulQ rm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.mulQ rm).exec ctx s = .ok z) :
    (Item.mulQ rm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  all_goals (try rfl)
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_shiftCl {ctx : Ctx} (op : X86.Sh) (w : X86.W) (reg : X86.Reg) (hs : cacheSafe (Item.shiftCl op w reg) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.shiftCl op w reg).mem? = some mm' → ∀ j < readBytes (Item.shiftCl op w reg),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.shiftCl op w reg) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.shiftCl op w reg).exec ctx s = .ok z) :
    (Item.shiftCl op w reg).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_div {ctx : Ctx} (sg : Bool) (w : X86.W) (rm : X86.Rm) (hs : cacheSafe (Item.div sg w rm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.div sg w rm).mem? = some mm' → ∀ j < readBytes (Item.div sg w rm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.div sg w rm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.div sg w rm).exec ctx s = .ok z) :
    (Item.div sg w rm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_cdq {ctx : Ctx} (w : X86.W) (hs : cacheSafe (Item.cdq w) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.cdq w).mem? = some mm' → ∀ j < readBytes (Item.cdq w),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.cdq w) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.cdq w).exec ctx s = .ok z) :
    (Item.cdq w).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

/-- `bsf`/`bsr`'s result pushed through the memory replacement. -/
theorem itm_bs_push (c : Bool) (t : X86.State) (m : X86.Mem) (n : BitVec 64) (w : X86.W)
    (reg : X86.Reg) (A : BitVec 64) (B : BitVec w.bits) (f : Flags) :
    (if c then (({ t with mem := m } : X86.State).jump n).setReg reg A
      else (({ t with mem := m } : X86.State).jump n).setRegW w reg B).setFlags f =
    { ((if c then (t.jump n).setReg reg A else (t.jump n).setRegW w reg B).setFlags f) with
      mem := m } := by
  cases c <;> cases w <;> rfl

/-- The memory operand's value is the same on `s` and on `s` with memory `m`. -/
theorem itm_rmW_wm {s : X86.State} {m : X86.Mem} {it : Item} (w : X86.W) (rm : X86.Rm)
    (hb : ∀ mm, rm = .mem mm → w.bits / 8 ≤ readBytes it ∧ it.mem? = some mm)
    (hRd : ∀ mm', it.mem? = some mm' → ∀ j < readBytes it,
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j)) :
    ({ s with mem := m } : X86.State).rmW w rm = s.rmW w rm := by
  cases rm with
  | reg r => rfl
  | mem mm =>
    obtain ⟨hle, hmm⟩ := hb mm rfl
    show BitVec.ofNat _ (m.readNat (s.ea mm) (w.bits / 8)) =
      BitVec.ofNat _ (s.mem.readNat (s.ea mm) (w.bits / 8))
    rw [Ryo.Proofs.RegCache.readNat_congr m s.mem (s.ea mm) (w.bits / 8)
      (fun j hj => hRd mm hmm j (Nat.lt_of_lt_of_le hj hle))]

theorem itmx_bsf {ctx : Ctx} (w : X86.W) (reg : X86.Reg) (rm : X86.Rm) (hs : cacheSafe (Item.bsf w reg rm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.bsf w reg rm).mem? = some mm' → ∀ j < readBytes (Item.bsf w reg rm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.bsf w reg rm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.bsf w reg rm).exec ctx s = .ok z) :
    (Item.bsf w reg rm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  have hV := itm_rmW_wm (s := s) (m := m) (it := Item.bsf w reg rm) w rm
    (fun mm e => by subst e; exact ⟨Nat.le_refl _, rfl⟩) hRd
  have e1 : (Item.bsf w reg rm).exec ctx s = .ok ((if s.rmW w rm == 0 then
      (s.jump (s.rip + BitVec.ofNat 64 (Item.bsf w reg rm).size)).setReg reg (ctx.bsZero w (s.reg reg))
    else (s.jump (s.rip + BitVec.ofNat 64 (Item.bsf w reg rm).size)).setRegW w reg
      (BitVec.ofNat _ (lowestSet (s.rmW w rm)))).setFlags { zf := some (s.rmW w rm == 0) }) := rfl
  have e2 : (Item.bsf w reg rm).exec ctx { s with mem := m } = .ok ((if
      ({ s with mem := m } : X86.State).rmW w rm == 0 then
      (({ s with mem := m } : X86.State).jump (s.rip + BitVec.ofNat 64 (Item.bsf w reg rm).size)).setReg
        reg (ctx.bsZero w (s.reg reg))
    else (({ s with mem := m } : X86.State).jump (s.rip + BitVec.ofNat 64
        (Item.bsf w reg rm).size)).setRegW w reg
      (BitVec.ofNat _ (lowestSet (({ s with mem := m } : X86.State).rmW w rm)))).setFlags
      { zf := some (({ s with mem := m } : X86.State).rmW w rm == 0) }) := rfl
  rw [hV] at e2
  rw [e1] at h
  obtain rfl := Except.ok.inj h
  rw [e2, itm_bs_push]

theorem itmx_bsr {ctx : Ctx} (w : X86.W) (reg : X86.Reg) (rm : X86.Rm) (hs : cacheSafe (Item.bsr w reg rm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.bsr w reg rm).mem? = some mm' → ∀ j < readBytes (Item.bsr w reg rm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.bsr w reg rm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.bsr w reg rm).exec ctx s = .ok z) :
    (Item.bsr w reg rm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  have hV := itm_rmW_wm (s := s) (m := m) (it := Item.bsr w reg rm) w rm
    (fun mm e => by subst e; exact ⟨Nat.le_refl _, rfl⟩) hRd
  have e1 : (Item.bsr w reg rm).exec ctx s = .ok ((if s.rmW w rm == 0 then
      (s.jump (s.rip + BitVec.ofNat 64 (Item.bsr w reg rm).size)).setReg reg (ctx.bsZero w (s.reg reg))
    else (s.jump (s.rip + BitVec.ofNat 64 (Item.bsr w reg rm).size)).setRegW w reg
      (BitVec.ofNat _ (highestSet (s.rmW w rm)))).setFlags { zf := some (s.rmW w rm == 0) }) := rfl
  have e2 : (Item.bsr w reg rm).exec ctx { s with mem := m } = .ok ((if
      ({ s with mem := m } : X86.State).rmW w rm == 0 then
      (({ s with mem := m } : X86.State).jump (s.rip + BitVec.ofNat 64 (Item.bsr w reg rm).size)).setReg
        reg (ctx.bsZero w (s.reg reg))
    else (({ s with mem := m } : X86.State).jump (s.rip + BitVec.ofNat 64
        (Item.bsr w reg rm).size)).setRegW w reg
      (BitVec.ofNat _ (highestSet (({ s with mem := m } : X86.State).rmW w rm)))).setFlags
      { zf := some (({ s with mem := m } : X86.State).rmW w rm == 0) }) := rfl
  rw [hV] at e2
  rw [e1] at h
  obtain rfl := Except.ok.inj h
  rw [e2, itm_bs_push]

theorem itmx_cmov {ctx : Ctx} (cond : X86.Cond) (w : X86.W) (reg : X86.Reg) (rm : X86.Rm) (hs : cacheSafe (Item.cmov cond w reg rm) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.cmov cond w reg rm).mem? = some mm' → ∀ j < readBytes (Item.cmov cond w reg rm),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.cmov cond w reg rm) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.cmov cond w reg rm).exec ctx s = .ok z) :
    (Item.cmov cond w reg rm).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_setccR {ctx : Ctx} (cond : X86.Cond) (reg : X86.Reg) (hs : cacheSafe (Item.setccR cond reg) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.setccR cond reg).mem? = some mm' → ∀ j < readBytes (Item.setccR cond reg),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.setccR cond reg) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.setccR cond reg).exec ctx s = .ok z) :
    (Item.setccR cond reg).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  all_goals (try (simp only [Bool.false_eq_true, ↓reduceIte]; rfl))
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

theorem itmx_bswap {ctx : Ctx} (w : X86.W) (reg : X86.Reg) (hs : cacheSafe (Item.bswap w reg) = true) {s z : X86.State}
    (m : X86.Mem)
    (hRd : ∀ mm', (Item.bswap w reg).mem? = some mm' → ∀ j < readBytes (Item.bswap w reg),
      m (s.ea mm' + BitVec.ofNat 64 j) = s.mem (s.ea mm' + BitVec.ofNat 64 j))
    (hL : ∀ r' to', (Item.bswap w reg) = .loadRip r' to' → m.read64 (ctx.addrOf to') = s.mem.read64 (ctx.addrOf to'))
    (h : (Item.bswap w reg).exec ctx s = .ok z) :
    (Item.bswap w reg).exec ctx { s with mem := m } = .ok { z with mem := m } := by
  try (simp only [cacheSafe, reduceCtorEq, Bool.false_eq_true] at hs)
  all_goals (try (cases ‹X86.Rm›))
  all_goals (try (simp only [beq_iff_eq] at hs; subst hs))
  all_goals (try (simp only [readBytes, Item.mem?, Option.some.injEq, forall_eq, forall_eq',
    reduceCtorEq, false_implies, implies_true] at hRd))
  all_goals (try (simp only [Item.loadRip.injEq, and_imp, forall_eq, forall_eq', reduceCtorEq,
    false_implies, implies_true] at hL))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, itm_ea_jump, itm_reg_jump, itm_regW_jump, itm_flags_jump, itm_mem_jump] at h
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals (try (
    have hrn := fun (k : Nat) (hk : k ≤ _) =>
      Ryo.Proofs.RegCache.readNat_congr m s.mem _ k (fun j hj => hRd j (Nat.lt_of_lt_of_le hj hk))))
  all_goals simp only [Item.exec, bind, Except.bind, pure, Except.pure, X86.State.rmW,
    X86.State.memW, X86.State.setRmW, itm_wm_jump, itm_wm_setReg, itm_wm_setRegW, itm_wm_setFlags,
    itm_wm_flags, itm_wm_mem, itm_ea_wm, itm_regW_wm, itm_reg_wm, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump]
  all_goals (try (simp only [aluF, subF, reduceCtorEq] at *; done))
  -- The splits' equations (inaccessible) and `hrn` rewrite the other run's discriminants/reads.
  all_goals (try simp_all only [itm_ea_lit, itm_reg_lit, itm_regW_lit, itm_ea_jump, itm_reg_jump,
    itm_regW_jump, itm_flags_jump, itm_mem_jump, Frame.itemReadBytes, X86.W.bits, Nat.reduceDiv,
    Nat.le_refl])
  -- Both sides the same structure: unfold the setters, compare fields.
  all_goals first
    | (simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW, X86.State.jump,
        Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and]; done)
    | (cases ‹X86.W› <;> simp only [X86.State.setFlags, X86.State.setReg, X86.State.setRegW,
        X86.State.jump, Except.ok.injEq, X86.State.mk.injEq, and_self, and_true, true_and] <;> done)
    | (with_reducible rfl)
    | (cases ‹X86.W› <;> rfl)
    | (simp only [ite_true, ↓reduceIte]; first | rfl | (cases ‹X86.W› <;> rfl))
    | (split <;> (first | rfl | (cases ‹X86.W› <;> rfl) | (simp_all; done)))
    | skip
  -- `shiftCl` past the width: the flags through `Option.map` (as in `exec_swap`).
  all_goals (try (
    obtain ⟨a, ha1, ha2⟩ := ‹∃ a, _ = some a ∧ _›
    subst ha2
    simp only [ha1, Option.map_some]))

/-- A `cacheSafe` item writing no memory, run on `s` with memory `m` agreeing with `s`'s on what
it reads, runs as on `s` with the memory replaced. -/
theorem itm_exec_withMem {ctx : Ctx} {it : Item} (hs : cacheSafe it = true)
    (hw : itmWr it = false) {s z : X86.State} (m : X86.Mem)
    (hRd : ∀ mm, it.mem? = some mm → ∀ j < readBytes it,
      m (s.ea mm + BitVec.ofNat 64 j) = s.mem (s.ea mm + BitVec.ofNat 64 j))
    (hL : ∀ r to, it = .loadRip r to → m.read64 (ctx.addrOf to) = s.mem.read64 (ctx.addrOf to))
    (h : it.exec ctx s = .ok z) :
    it.exec ctx { s with mem := m } = .ok { z with mem := m } := by
  cases it
  case setReg r v => exact itmx_setReg r v hs m hRd hL h
  case lea r to => exact itmx_lea r to hs m hRd hL h
  case loadRip r to => exact itmx_loadRip r to hs m hRd hL h
  case ld w sx dst mm => exact itmx_ld w sx dst mm hs m hRd hL h
  case leaM dst mm => exact itmx_leaM dst mm hs m hRd hL h
  case alu op w reg rm => exact itmx_alu op w reg rm hs m hRd hL h
  case aluImm op w rm imm => exact itmx_aluImm op w rm imm hs m hRd hL h
  case imul w reg rm => exact itmx_imul w reg rm hs m hRd hL h
  case imulImm w reg rm imm => exact itmx_imulImm w reg rm imm hs m hRd hL h
  case shift op w reg amt => exact itmx_shift op w reg amt hs m hRd hL h
  case testM8 mm => exact itmx_testM8 mm hs m hRd hL h
  case setccCl cond => exact itmx_setccCl cond hs m hRd hL h
  case mulQ rm => exact itmx_mulQ rm hs m hRd hL h
  case shiftCl op w reg => exact itmx_shiftCl op w reg hs m hRd hL h
  case div sg w rm => exact itmx_div sg w rm hs m hRd hL h
  case cdq w => exact itmx_cdq w hs m hRd hL h
  case bsf w reg rm => exact itmx_bsf w reg rm hs m hRd hL h
  case bsr w reg rm => exact itmx_bsr w reg rm hs m hRd hL h
  case cmov cond w reg rm => exact itmx_cmov cond w reg rm hs m hRd hL h
  case setccR cond reg => exact itmx_setccR cond reg hs m hRd hL h
  case bswap w reg => exact itmx_bswap w reg hs m hRd hL h
  all_goals simp only [cacheSafe, itmWr, reduceCtorEq, Bool.false_eq_true] at hs hw

theorem itm_frameWrite_none {it : Item} (hs : cacheSafe it = true) (hw : itmWr it = false) :
    Asm.frameWrite it = none := by
  cases it <;> simp only [cacheSafe, itmWr, reduceCtorEq, Bool.false_eq_true] at hs hw <;>
    first
    | rfl
    | (cases ‹X86.Rm› <;> first | rfl | simp_all [Asm.frameWrite])

/-- Writing the same bytes into two memories agreeing but at `fp + Q` makes them agree but at
`fp + Q'`, if every byte of `Q` not in `Q'` is written. -/
theorem itm_memAgree_write {fp : BitVec 64} {Q Q' : Int → Prop} {m m' : X86.Mem}
    (h : MemAgree fp Q m m') {a : BitVec 64} {n : Nat} (v : Nat) (hn : n ≤ 8)
    (hc : ∀ o, Q o → ¬ Q' o → ∃ j < n, fp + BitVec.ofInt 64 o = a + BitVec.ofNat 64 j) :
    MemAgree fp Q' (m.write a n v) (m'.write a n v) := by
  intro y hy
  show (if (y - a).toNat < n then UInt8.ofNat (v >>> (8 * (y - a).toNat)) else m y) =
    (if (y - a).toNat < n then UInt8.ofNat (v >>> (8 * (y - a).toNat)) else m' y)
  by_cases hlt : (y - a).toNat < n
  · rw [if_pos hlt, if_pos hlt]
  · rw [if_neg hlt, if_neg hlt]
    refine h y fun o ho he => ?_
    by_cases hq : Q' o
    · exact hy o hq he
    · obtain ⟨j, hj, e⟩ := hc o ho hq
      apply hlt
      rw [he, e, BitVec.add_comm, BitVec.add_sub_cancel]
      have hj' : (BitVec.ofNat 64 j).toNat = j := by
        rw [BitVec.toNat_ofNat]
        exact Nat.mod_eq_of_lt (Nat.lt_of_lt_of_le hj (Nat.le_trans hn (by decide)))
      rw [hj']
      exact hj

theorem itm_fw_eq {it : Item} {mm : X86.M} {n : Nat}
    (hf' : Asm.frameWrite it = if mm.base == .rbp then some (mm, n) else none) :
    ∀ m' n', Asm.frameWrite it = some (m', n') → m' = mm ∧ n' = n := by
  intro m' n' hf
  rw [hf'] at hf
  split at hf
  · have e := Option.some.inj hf
    exact ⟨(congrArg Prod.fst e).symm, (congrArg Prod.snd e).symm⟩
  · exact nomatch hf

/-- A byte of `Q` an `rbp`-based store `it` writes is at its address plus `j < n`. -/
theorem itm_cover {fp : BitVec 64} {Q : Int → Prop} {it : Item} {g : X86.State}
    (hrbp : g.reg .rbp = fp) {mm : X86.M} {n : Nat}
    (hfw : ∀ m' n', Asm.frameWrite it = some (m', n') → m' = mm ∧ n' = n) :
    ∀ o, Q o → ¬ (Q o ∧ ¬ Writes it o) →
      ∃ j < n, fp + BitVec.ofInt 64 o = g.ea mm + BitVec.ofNat 64 j := by
  intro o ho hq
  have hW : Writes it o := Classical.byContradiction fun hn => hq ⟨ho, hn⟩
  obtain ⟨m', n', hf, hlo, hhi⟩ := hW
  have hb := frameWrite_base hf
  obtain ⟨e1, e2⟩ := hfw m' n' hf
  rw [← e1, ← e2]
  have h0 : (((o - m'.disp.toInt).toNat : Nat) : Int) = o - m'.disp.toInt :=
    Int.toNat_of_nonneg (by omega)
  refine ⟨(o - m'.disp.toInt).toNat, by omega, ?_⟩
  have e : m'.disp.toInt + (((o - m'.disp.toInt).toNat : Nat) : Int) = o := by omega
  show fp + BitVec.ofInt 64 o =
    g.reg m'.base + m'.disp.signExtend 64 + BitVec.ofNat 64 (o - m'.disp.toInt).toNat
  rw [hb, hrbp, addr_off, e]


/-- **Open (DS-T4, item level).** A `cacheSafe` item run on a state agreeing with the ghost's
but at `fp + Q`, reading no byte there (its memory operand, `ItemApart`; a `loadRip`'s slot),
runs alike, agreeing but at `Q` less what it writes (it writes the same bytes in both), and
keeps `rbp`. Per item case: the reads are equal (`readNat` over agreeing bytes), so the results
are the same function of equal inputs. -/
theorem item_agree {ctx : Ctx} {it : Item} (hs : cacheSafe it = true) {fp : BitVec 64}
    {Q : Int → Prop} {x g g' : X86.State} (hrbp : g.reg .rbp = fp) (ha : XAgreeAt fp Q x g)
    (hap : ItemApart fp Q it x)
    (hlr : ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, Q o →
      ctx.addrOf to + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o)
    (h : it.exec ctx g = .ok g') :
    ∃ x', it.exec ctx x = .ok x' ∧ XAgreeAt fp (fun o => Q o ∧ ¬ Writes it o) x' g' ∧
      g'.reg .rbp = fp := by
  have hrbp' : g'.reg .rbp = fp := (Ryo.Proofs.CacheStep.exec_rbp hs h).trans hrbp
  obtain ⟨h1, h2, h3, h4, hm⟩ := ha
  have hx : x = { g with mem := x.mem } := by
    first
      | (rw [← h1, ← h2, ← h3, ← h4]; done)
      | (rw [← h1, ← h2, ← h3, ← h4]; rfl)
      | (cases x; cases g; simp_all)
  obtain ⟨xm, rfl⟩ : ∃ xm, x = { g with mem := xm } := ⟨_, hx⟩
  have hm' : MemAgree fp Q xm g.mem := hm
  cases hwr : itmWr it
  · -- No memory write: the run is the ghost's with the memory replaced.
    have hex := itm_exec_withMem hs hwr xm
      (fun mm hmm j hj => hm' _ (fun o ho => hap mm hmm j hj o ho))
      (fun r to e => by
        show BitVec.ofNat 64 (xm.readNat (ctx.addrOf to) 8) =
          BitVec.ofNat 64 (g.mem.readNat (ctx.addrOf to) 8)
        rw [Ryo.Proofs.RegCache.readNat_congr xm g.mem (ctx.addrOf to) 8
          (fun i hi => hm' _ (fun o ho => hlr r to e i hi o ho))]) h
    have e0 : Item.exec ctx it g = .ok { g' with mem := g.mem } :=
      itm_exec_withMem hs hwr g.mem (fun _ _ _ _ => rfl) (fun _ _ _ => rfl) h
    rw [h] at e0
    have e2 : g' = { g' with mem := g.mem } := Except.ok.inj e0
    have hgm : g'.mem = g.mem := by
      have e3 := congrArg X86.State.mem e2
      exact e3
    refine ⟨{ g' with mem := xm }, hex, ⟨rfl, rfl, rfl, rfl, ?_⟩, hrbp'⟩
    intro a ha'
    show xm a = g'.mem a
    rw [hgm]
    exact hm' a (fun o ho => ha' o ⟨ho, fun hW => by
      obtain ⟨_, _, hf, _⟩ := hW
      rw [itm_frameWrite_none hs hwr] at hf
      exact nomatch hf⟩)
  · -- A store: both write the same bytes.
    cases it <;> simp only [itmWr, reduceCtorEq, Bool.false_eq_true] at hwr
    case st w src mm =>
      have hge : Item.exec ctx (.st w src mm) g = .ok ((g.jump (g.rip + BitVec.ofNat 64
          (Item.st w src mm).size)).setMemW w (g.ea mm) (g.regW w src)) := rfl
      rw [hge] at h
      obtain rfl := Except.ok.inj h
      refine ⟨(({ g with mem := xm } : X86.State).jump (g.rip + BitVec.ofNat 64
          (Item.st w src mm).size)).setMemW w (g.ea mm) (g.regW w src), rfl,
        ⟨rfl, rfl, rfl, rfl, ?_⟩, hrbp'⟩
      show MemAgree fp _ (xm.write (g.ea mm) (w.bits / 8) (g.regW w src).toNat)
        (g.mem.write (g.ea mm) (w.bits / 8) (g.regW w src).toNat)
      have hc := itm_cover (Q := Q) (it := .st w src mm) (g := g) (mm := mm) (n := w.bits / 8)
        hrbp (itm_fw_eq rfl)
      exact itm_memAgree_write hm' _ (itm_bytes_le w) hc
    case stImm w mm imm =>
      have hge : Item.exec ctx (.stImm w mm imm) g = .ok ((g.jump (g.rip + BitVec.ofNat 64
          (Item.stImm w mm imm).size)).setMemW w (g.ea mm) (imm.signExtend w.bits)) := rfl
      rw [hge] at h
      obtain rfl := Except.ok.inj h
      refine ⟨(({ g with mem := xm } : X86.State).jump (g.rip + BitVec.ofNat 64
          (Item.stImm w mm imm).size)).setMemW w (g.ea mm) (imm.signExtend w.bits), rfl,
        ⟨rfl, rfl, rfl, rfl, ?_⟩, hrbp'⟩
      show MemAgree fp _ (xm.write (g.ea mm) (w.bits / 8) (imm.signExtend w.bits).toNat)
        (g.mem.write (g.ea mm) (w.bits / 8) (imm.signExtend w.bits).toNat)
      have hc := itm_cover (Q := Q) (it := .stImm w mm imm) (g := g) (mm := mm)
        (n := w.bits / 8) hrbp (itm_fw_eq rfl)
      exact itm_memAgree_write hm' _ (itm_bytes_le w) hc
    case setcc cond mm =>
      have hge : Item.exec ctx (.setcc cond mm) g = (Cond.eval g.flags cond).bind (fun b =>
          Except.ok ((g.jump (g.rip + BitVec.ofNat 64 (Item.setcc cond mm).size)).setMem
            (g.ea mm) 1 (if b then 1 else 0))) := rfl
      have hxe : Item.exec ctx (.setcc cond mm) { g with mem := xm } =
          (Cond.eval g.flags cond).bind (fun b =>
          Except.ok ((({ g with mem := xm } : X86.State).jump (g.rip + BitVec.ofNat 64
            (Item.setcc cond mm).size)).setMem (g.ea mm) 1 (if b then 1 else 0))) := rfl
      rw [hge] at h
      cases hc : Cond.eval g.flags cond with
      | error e =>
        rw [hc] at h
        exact nomatch (h : (Except.error e : Except X86.Fault X86.State) = .ok g')
      | ok b =>
        rw [hc] at h hxe
        obtain rfl := Except.ok.inj (h : (Except.ok ((g.jump (g.rip + BitVec.ofNat 64
          (Item.setcc cond mm).size)).setMem (g.ea mm) 1 (if b then 1 else 0)) :
          Except X86.Fault X86.State) = .ok g')
        refine ⟨_, hxe, ⟨rfl, rfl, rfl, rfl, ?_⟩, hrbp'⟩
        show MemAgree fp _ (xm.write (g.ea mm) 1 (if b then 1 else 0))
          (g.mem.write (g.ea mm) 1 (if b then 1 else 0))
        have hcv := itm_cover (Q := Q) (it := .setcc cond mm) (g := g) (mm := mm) (n := 1)
          hrbp (itm_fw_eq rfl)
        exact itm_memAgree_write hm' _ (by decide) hcv


/-- `Skip`'s remainder is a suffix of what it started with. -/
theorem skip_suffix {dr dr' : List Asm.DroppedStore} {out kept : List Item}
    (hs : Skip dr out kept dr') : ∃ ds, dr = ds ++ dr' := by
  induction hs with
  | nil dr => exact ⟨[], rfl⟩
  | keep _ ih => exact ih
  | @drop d dr dr' is ks _ ih =>
    obtain ⟨ds, e⟩ := ih
    exact ⟨d :: ds, by rw [e]; rfl⟩

/-- A `Skip` that consumes nothing keeps everything. -/
theorem skip_none {dr dr' : List Asm.DroppedStore} {out kept : List Item}
    (hs : Skip dr out kept dr') : dr = dr' → kept = out := by
  induction hs with
  | nil _ => intro _; rfl
  | @keep dr dr' i is ks _ ih => intro e; rw [ih e]
  | @drop d dr dr' is ks hrest _ =>
    intro e
    exfalso
    obtain ⟨ds, e2⟩ := skip_suffix hrest
    have h1 := congrArg List.length e
    have h2 := congrArg List.length e2
    simp only [List.length_cons, List.length_append] at h1 h2
    omega

/-- A `Skip` that consumes one store erases one occurrence of its item. -/
theorem skip_one {dr dr' : List Asm.DroppedStore} {out kept : List Item}
    (hs : Skip dr out kept dr') :
    ∀ d0, dr = d0 :: dr' → ∃ j, out[j]? = some d0.item ∧ kept = out.eraseIdx j := by
  induction hs with
  | nil dr =>
    intro d0 e
    have h1 := congrArg List.length e
    simp only [List.length_cons] at h1
    omega
  | @keep dr dr' i is ks _ ih =>
    intro d0 e
    obtain ⟨j, hj, hk⟩ := ih d0 e
    exact ⟨j + 1, by simpa using hj, by rw [hk]; rfl⟩
  | @drop d dr dr' is ks hrest _ =>
    intro d0 e
    simp only [List.cons.injEq] at e
    obtain ⟨rfl, rfl⟩ := e
    exact ⟨0, rfl, skip_none hrest rfl⟩

/-- A store `Skip` consumed (`ds`, the part of `dr` before `dr'`) is in `out`. -/
theorem skip_consumed_mem {dr dr' : List Asm.DroppedStore} {out kept : List Item}
    (hs : Skip dr out kept dr') :
    ∀ ds, dr = ds ++ dr' → ∀ d ∈ ds, ∃ pre post, out = pre ++ d.item :: post := by
  induction hs with
  | nil dr =>
    intro ds e d hd
    have hl := congrArg List.length e
    rw [List.length_append] at hl
    cases ds with
    | nil => cases hd
    | cons a l => simp only [List.length_cons] at hl; omega
  | @keep dr dr' i is ks _ ih =>
    intro ds e d hd
    obtain ⟨pre, post, e'⟩ := ih ds e d hd
    exact ⟨i :: pre, post, by rw [e']; rfl⟩
  | @drop d0 dr dr' is ks _ ih =>
    intro ds e d hd
    cases ds with
    | nil =>
      cases hd
    | cons a l =>
      simp only [List.cons_append, List.cons.injEq] at e
      obtain ⟨rfl, e⟩ := e
      rcases List.mem_cons.1 hd with rfl | hd'
      · exact ⟨[], is, rfl⟩
      · obtain ⟨pre, post, e'⟩ := ih l e d hd'
        exact ⟨d0.item :: pre, post, by rw [e']; rfl⟩

/-- `execItems_skip`'s induction: `Q` the current patch set, the ghost `xh` jumped to the real
`rip`; before the first drop `rip`s are equal and `Q ⊆ P`, after one every item left is
`RipFree` and reads no memory. -/
theorem skip_gen_free (ctx : Ctx) {fp : BitVec 64} {P : Int → Prop}
    {dr dr' : List Asm.DroppedStore} {out kept : List Item} (hs : Skip dr out kept dr') :
    (∀ it ∈ kept, cacheSafe it = true) →
    (∀ d ∈ dr, PureStore ctx d.item) →
    (∀ ds, dr = ds ++ dr' → ∀ (pre : List Item) (d : Asm.DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ post, it.RipFree ctx ∧ NoRead it) →
    (∀ ds, dr = ds ++ dr' → ∀ (pre : List Item) (d : Asm.DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ pre, ∀ o, Writes it o → ¬ Writes d.item o) →
    (∀ it ∈ kept, ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, P o →
      ctx.addrOf to + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o) →
    ∀ {Q : Int → Prop} {x xh xh' : X86.State}, xh.reg .rbp = fp →
      XAgreeAt fp Q x (xh.jump x.rip) →
      ((x.rip = xh.rip ∧ (∀ o, Q o → P o) ∧ KeptApart ctx fp P kept x) ∨
        ∀ it ∈ out, it.RipFree ctx ∧ NoRead it) →
      execItems ctx out xh = .ok xh' →
      ∃ ds x', dr = ds ++ dr' ∧ execItems ctx kept x = .ok x' ∧
        XAgreeAt fp (fun o => (Q o ∨ DropW ds o) ∧ ¬ KeptW kept o) x' (xh'.jump x'.rip) := by
  induction hs with
  | nil dr =>
    intro _ _ _ _ _ Q x xh xh' _ ha _ hx
    simp only [execItems_nil, Except.ok.injEq] at hx
    subst hx
    refine ⟨[], x, rfl, rfl, xAgreeAt_mono ha ?_⟩
    intro o ho
    refine ⟨Or.inl ho, fun hk => ?_⟩
    obtain ⟨_, hit, _⟩ := hk
    simp at hit
  | @keep dr dr' i is ks hrest ih =>
    intro hcs hd hrf hdisj hlr Q x xh xh' hrbp ha hmode hx
    rw [execItems_cons] at hx
    cases hxi : i.exec ctx xh with
    | error e =>
      rw [hxi] at hx
      first | cases hx | simp [bind, Except.bind] at hx
    | ok xh1 =>
      rw [hxi] at hx
      change execItems ctx is xh1 = .ok xh' at hx
      have hcsi : cacheSafe i = true := hcs i (List.mem_cons.mpr (Or.inl rfl))
      -- The real step and the invariant after it.
      obtain ⟨x1, hx1, ha1, hrbp1, hmode1⟩ : ∃ x1, i.exec ctx x = .ok x1 ∧
          XAgreeAt fp (fun o => Q o ∧ ¬ Writes i o) x1 (xh1.jump x1.rip) ∧
          xh1.reg .rbp = fp ∧
          ((x1.rip = xh1.rip ∧ (∀ o, (Q o ∧ ¬ Writes i o) → P o) ∧ KeptApart ctx fp P ks x1) ∨
            ∀ it ∈ is, it.RipFree ctx ∧ NoRead it) := by
        rcases hmode with ⟨hrip, hQP, hk⟩ | hall
        · have e : xh.jump x.rip = xh := by rw [hrip]; rfl
          rw [e] at ha
          obtain ⟨hap, hk'⟩ := hk
          obtain ⟨x1, hx1, ha1, hrbp1⟩ := item_agree hcsi hrbp ha (itemApart_mono hap hQP)
            (fun r to e j hj o ho => hlr i (List.mem_cons.mpr (Or.inl rfl)) r to e j hj o (hQP o ho))
            hxi
          have e1 : xh1.jump x1.rip = xh1 := by rw [ha1.2.2.2.1]; rfl
          refine ⟨x1, hx1, by rw [e1]; exact ha1, hrbp1, Or.inl ⟨ha1.2.2.2.1, ?_, hk' x1 hx1⟩⟩
          exact fun o h => hQP o h.1
        · obtain ⟨hri, hnr⟩ := hall i (List.mem_cons.mpr (Or.inl rfl))
          have hg : i.exec ctx (xh.jump x.rip) =
              .ok (xh1.jump (x.rip + BitVec.ofNat 64 i.size)) := by
            rw [hri xh x.rip, hxi]
            rfl
          obtain ⟨x1, hx1, ha1, hrbp1⟩ := item_agree (g := xh.jump x.rip) hcsi hrbp ha
            (fun m hm j hj => absurd hj (by rw [hnr.1 m hm]; exact Nat.not_lt_zero j)) (fun r to e => absurd e (hnr.2 r to)) hg
          have e1 : xh1.jump x1.rip = xh1.jump (x.rip + BitVec.ofNat 64 i.size) :=
            congrArg xh1.jump ha1.2.2.2.1
          refine ⟨x1, hx1, by rw [e1]; exact ha1, hrbp1, Or.inr ?_⟩
          exact fun it h => hall it (List.mem_cons.mpr (Or.inr h))
      obtain ⟨ds, x', hdr, hks, ha'⟩ := ih
        (fun it h => hcs it (List.mem_cons.mpr (Or.inr h))) hd
        (fun ds e0 pre d post e hdm => hrf ds e0 (i :: pre) d post (by rw [e]; rfl) hdm)
        (fun ds e0 pre d post e hdm it hit o hw =>
          hdisj ds e0 (i :: pre) d post (by rw [e]; rfl) hdm it (List.mem_cons.mpr (Or.inr hit)) o hw)
        (fun it h => hlr it (List.mem_cons.mpr (Or.inr h))) hrbp1 ha1 hmode1 hx
      refine ⟨ds, x', hdr, ?_, xAgreeAt_mono ha' ?_⟩
      · rw [execItems_cons, hx1]
        exact hks
      · intro o ho
        obtain ⟨h1, h2⟩ := ho
        have hw : ¬ Writes i o := by
          rcases h1 with h1 | h1
          · exact h1.2
          · -- a dropped store of the rest: `i` comes before it in `out`
            obtain ⟨d', hd', hwd⟩ := h1
            obtain ⟨pre', post', e'⟩ := skip_consumed_mem hrest ds hdr d' hd'
            exact fun hw => hdisj ds hdr (i :: pre') d' post' (by rw [e']; rfl) hd' i
              (List.mem_cons_self ..) o hw hwd
        refine ⟨h1.imp And.left id, ?_⟩
        intro hk
        obtain ⟨it, hit, hwi⟩ := hk
        rcases List.mem_cons.mp hit with rfl | hit'
        · exact hw hwi
        · exact h2 ⟨it, hit', hwi⟩
  | @drop d dr dr' is ks hrest ih =>
    intro hcs hd hrf hdisj hlr Q x xh xh' hrbp ha _ hx
    rw [execItems_cons] at hx
    cases hxi : d.item.exec ctx xh with
    | error e =>
      rw [hxi] at hx
      first | cases hx | simp [bind, Except.bind] at hx
    | ok xh1 =>
      rw [hxi] at hx
      change execItems ctx is xh1 = .ok xh' at hx
      obtain ⟨m, n, hfw, hps⟩ := hd d (List.mem_cons.mpr (Or.inl rfl))
      obtain ⟨hregs, hxmm, hflags, hmem⟩ := hps xh xh1 hxi
      have hb := frameWrite_base hfw
      have hrbp1 : xh1.reg .rbp = fp := by
        unfold X86.State.reg
        rw [hregs]
        exact hrbp
      obtain ⟨a1, a2, a3, _, a5⟩ := ha
      have ha1 : XAgreeAt fp (fun o => Q o ∨ Writes d.item o) x (xh1.jump x.rip) := by
        refine ⟨a1.trans hregs.symm, a2.trans hxmm.symm, a3.trans hflags.symm, rfl, ?_⟩
        intro a hav
        have e1 : x.mem a = xh.mem a := a5 a (fun o ho => hav o (Or.inl ho))
        refine e1.trans (hmem a ?_).symm
        intro j hj heq
        apply hav (m.disp.toInt + (j : Int)) (Or.inr ⟨m, n, hfw, by omega, by omega⟩)
        rw [heq, ← addr_off]
        show xh.reg m.base + m.disp.signExtend 64 + BitVec.ofNat 64 j = _
        rw [hb, hrbp]
      obtain ⟨ds0, e0⟩ := skip_suffix hrest
      obtain ⟨ds, x', hdr, hks, ha'⟩ := ih hcs
        (fun d' h => hd d' (List.mem_cons.mpr (Or.inr h)))
        (fun ds1 e1 pre d' post e hdm =>
          hrf (d :: ds1) (by rw [e1]; rfl) (d.item :: pre) d' post (by rw [e]; rfl)
            (List.mem_cons.mpr (Or.inr hdm)))
        (fun ds1 e1 pre d' post e hdm it hit o hw =>
          hdisj (d :: ds1) (by rw [e1]; rfl) (d.item :: pre) d' post (by rw [e]; rfl)
            (List.mem_cons.mpr (Or.inr hdm)) it (List.mem_cons.mpr (Or.inr hit)) o hw)
        hlr hrbp1 ha1
        (Or.inr (fun it h => hrf (d :: ds0) (by rw [e0]; rfl) [] d is rfl
          (List.mem_cons.mpr (Or.inl rfl)) it h)) hx
      refine ⟨d :: ds, x', by rw [hdr]; rfl, hks, xAgreeAt_mono ha' ?_⟩
      intro o ho
      obtain ⟨h1, h2⟩ := ho
      refine ⟨?_, h2⟩
      rcases h1 with (h | h) | h
      · exact Or.inl h
      · exact Or.inr ⟨d, List.mem_cons.mpr (Or.inl rfl), h⟩
      · obtain ⟨d', hd', hw⟩ := h
        exact Or.inr ⟨d', List.mem_cons.mpr (Or.inr hd'), hw⟩

/-- The kept run against the ghost's. Hypotheses: the kept items are `cacheSafe` (what the
cache emits); the dropped stores are pure stores; the items after a dropped one are `RipFree`
and read no memory (fact 6: an overflow op's `setcc cl` and flag store; the ghost's `rip` is
ahead there, and the dropped bytes differ); the items before a dropped store write
none of its bytes (a later kept store may: the byte then agrees again); a kept `loadRip` reads no byte of `P` (an image slot,
not the frame); the kept items touch no byte of `P` along the real run (`KeptApart`). -/
theorem execItems_skip_free (ctx : Ctx) {dr dr' : List Asm.DroppedStore}
    {out kept : List Item} (hs : Skip dr out kept dr')
    (hcs : ∀ it ∈ kept, cacheSafe it = true)
    (hd : ∀ d ∈ dr, PureStore ctx d.item)
    (hrf : ∀ ds, dr = ds ++ dr' → ∀ (pre : List Item) (d : Asm.DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ post, it.RipFree ctx ∧ NoRead it)
    (hdisj : (∀ ds, dr = ds ++ dr' → ∀ (pre : List Item) (d : Asm.DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ pre, ∀ o, Writes it o → ¬ Writes d.item o))
    {fp : BitVec 64} {P : Int → Prop}
    (hlr : ∀ it ∈ kept, ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, P o →
      ctx.addrOf to + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o)
    {x xh xh' : X86.State} (hrbp : xh.reg .rbp = fp)
    (ha : XAgreeAt fp P x xh) (hk : KeptApart ctx fp P kept x)
    (hxh : execItems ctx out xh = .ok xh') :
    ∃ ds x', dr = ds ++ dr' ∧ execItems ctx kept x = .ok x' ∧
      XAgreeAt fp (fun o => (P o ∨ DropW ds o) ∧ ¬ KeptW kept o) x' (xh'.jump x'.rip) := by
  have e : xh.jump x.rip = xh := by rw [ha.2.2.2.1]; rfl
  exact skip_gen_free ctx hs hcs hd hrf hdisj hlr hrbp (by rw [e]; exact ha)
    (Or.inl ⟨ha.2.2.2.1, fun _ h => h, hk⟩) hxh

/-- `execItems_skip_free` from a `SkipAt` read. -/
theorem execItems_skip (ctx : Ctx) {p : Nat} {dr dr' : List Asm.DroppedStore}
    {out kept : List Item} (hs : SkipAt p dr out kept dr')
    (hcs : ∀ it ∈ kept, cacheSafe it = true)
    (hd : ∀ d ∈ dr, PureStore ctx d.item)
    (hrf : ∀ ds, dr = ds ++ dr' → ∀ (pre : List Item) (d : Asm.DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ post, it.RipFree ctx ∧ NoRead it)
    (hdisj : (∀ ds, dr = ds ++ dr' → ∀ (pre : List Item) (d : Asm.DroppedStore) (post : List Item),
      out = pre ++ d.item :: post → d ∈ ds → ∀ it ∈ pre, ∀ o, Writes it o → ¬ Writes d.item o))
    {fp : BitVec 64} {P : Int → Prop}
    (hlr : ∀ it ∈ kept, ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, P o →
      ctx.addrOf to + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o)
    {x xh xh' : X86.State} (hrbp : xh.reg .rbp = fp)
    (ha : XAgreeAt fp P x xh) (hk : KeptApart ctx fp P kept x)
    (hxh : execItems ctx out xh = .ok xh') :
    ∃ ds x', dr = ds ++ dr' ∧ execItems ctx kept x = .ok x' ∧
      XAgreeAt fp (fun o => (P o ∨ DropW ds o) ∧ ¬ KeptW kept o) x' (xh'.jump x'.rip) :=
  execItems_skip_free ctx hs.toSkip hcs hd hrf hdisj hlr hrbp ha hk hxh

/-- `KeptApart` for the memory operands not based on `rbp` only (pointer accesses). -/
def KeptPtrApart (ctx : Ctx) (fp : BitVec 64) (P : Int → Prop) : List Item → X86.State → Prop
  | [], _ => True
  | it :: is, y => (∀ m, it.mem? = some m → m.base ≠ .rbp →
      ∀ j < readBytes it, ∀ o, P o → y.ea m + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o) ∧
    ∀ y', it.exec ctx y = .ok y' → KeptPtrApart ctx fp P is y'

/-- The frame half of `KeptApart`: `cacheSafe` items keep `rbp = fp`, so an `rbp`-based read is at
`fp + disp + j`, which `hrd` puts off `P`. -/
theorem keptApart_of_ptr (ctx : Ctx) {fp : BitVec 64} {P : Int → Prop} :
    ∀ (kept : List Item) (y : X86.State), (∀ it ∈ kept, cacheSafe it = true) →
      y.reg .rbp = fp →
      (∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it, ∀ o, P o →
        fp + m.disp.signExtend 64 + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o) →
      KeptPtrApart ctx fp P kept y → KeptApart ctx fp P kept y
  | [], _, _, _, _, _ => trivial
  | it :: is, y, hcs, hy, hrd, hp => by
    refine ⟨?_, fun y' hy' => keptApart_of_ptr ctx is y'
      (fun i hi => hcs i (List.mem_cons.mpr (Or.inr hi)))
      ((Ryo.Proofs.CacheStep.exec_rbp (hcs it (List.mem_cons.mpr (Or.inl rfl))) hy').trans hy)
      (fun i hi => hrd i (List.mem_cons.mpr (Or.inr hi))) (hp.2 y' hy')⟩
    intro m hm j hj o ho
    by_cases hb : m.base = .rbp
    · have e : y.ea m = fp + m.disp.signExtend 64 := by
        show y.reg m.base + m.disp.signExtend 64 = _
        rw [hb, hy]
      rw [e]
      exact hrd it (List.mem_cons.mpr (Or.inl rfl)) m hm hb j hj o ho
    · exact hp.1 m hm hb j hj o ho

/-- `fp + a = fp + b` in range: `a = b` (as `Rel.ds_off_inj`). -/
theorem itm_off_inj {fp : BitVec 64} {o d : Int} (ho : -2 ^ 63 ≤ o ∧ o < 2 ^ 63)
    (hd : -2 ^ 63 ≤ d ∧ d < 2 ^ 63) (h : fp + BitVec.ofInt 64 o = fp + BitVec.ofInt 64 d) :
    o = d := by
  let x : X86.State := { (default : X86.State) with regs := fun _ => fp }
  have h' : Ryo.Proofs.Inline.fpAddr x o = Ryo.Proofs.Inline.fpAddr x d := h
  apply Classical.byContradiction
  intro hne
  have h1 := Ryo.Proofs.Inline.fpAddr_sub_ge x o d 1 ho hd.1 (by omega) (by omega)
  rw [h'] at h1
  have h0 : (Ryo.Proofs.Inline.fpAddr x d - Ryo.Proofs.Inline.fpAddr x d).toNat = 0 := by simp
  omega

/-- `keptReads_apart`'s offset form gives `keptApart_of_live`'s address form `hrd`. -/
theorem itm_hrd_of_off {fp : BitVec 64} {P : Int → Prop} {kept : List Item}
    (hP : ∀ o, P o → -(2 : Int) ^ 62 ≤ o ∧ o < 0)
    (hrb : ∀ it ∈ kept, readBytes it ≤ 2 ^ 32)
    (hoff : ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it,
      ¬ P (m.disp.toInt + j)) :
    ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it, ∀ o, P o →
      fp + m.disp.signExtend 64 + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o := by
  intro it hit m hm hb j hj o ho heq
  apply hoff it hit m hm hb j hj
  have hb1 : m.disp.toInt < 2147483648 := by
    first
      | (have := BitVec.toInt_lt (x := m.disp); first | omega | (simp at this; omega))
      | (have := @BitVec.toInt_lt _ m.disp; first | omega | (simp at this; omega))
      | (have := m.disp.toInt_lt; first | omega | (simp at this; omega))
  have hb2 : -2147483648 ≤ m.disp.toInt := by
    first
      | (have := BitVec.le_toInt (x := m.disp); first | omega | (simp at this; omega))
      | (have := @BitVec.le_toInt _ m.disp; first | omega | (simp at this; omega))
      | (have := m.disp.le_toInt; first | omega | (simp at this; omega))
  have hj' := hrb it hit
  have hpo := hP o ho
  rw [addr_off] at heq
  have e := itm_off_inj (fp := fp) (o := m.disp.toInt + (j : Int)) (d := o)
    (by omega) (by omega) heq
  rw [e]
  exact ho

/-- **Premise (DS-T4b).** Along the run of `kept` from `y`, each memory read not based on `rbp`
lands in a live allocation of `st` (what a successful R step of the inline op gives, through
`MemRel`/`RRel`: the pointer register holds R's pointer, which is dereferenceable). -/
def KeptPtrLive (ctx : Ctx) (st : OpSem.State) : List Item → X86.State → Prop
  | [], _ => True
  | it :: is, y => (∀ m, it.mem? = some m → m.base ≠ .rbp → ∀ j < readBytes it,
      ∃ id a, st.mem.get? id = some a ∧ a.live = true ∧
        (y.ea m + BitVec.ofNat 64 j - BitVec.ofNat 64 a.addr).toNat < a.size) ∧
    ∀ y', it.exec ctx y = .ok y' → KeptPtrLive ctx st is y'

/-- Reads in live allocations miss a private frame set in the window (`FrameOwn`: a frame byte
in a live allocation is an escaped object's). -/
theorem keptPtrApart_of_own (ctx : Ctx) {fp : BitVec 64} {P : Int → Prop} {st : OpSem.State}
    {yh : X86.State} {lo hi : Int} (hfp : yh.reg .rbp = fp)
    (hown : Ryo.Proofs.ScopeMem.FrameOwn lo hi st yh)
    (hP : ∀ o, P o → lo ≤ o ∧ o < hi ∧ st.escapedAt o = none) :
    ∀ (kept : List Item) (y : X86.State), KeptPtrLive ctx st kept y →
      KeptPtrApart ctx fp P kept y
  | [], _, _ => trivial
  | it :: is, y, hl => by
    refine ⟨fun m hm hb j hj o ho heq => ?_, fun y' hy' =>
      keptPtrApart_of_own ctx hfp hown hP is y' (hl.2 y' hy')⟩
    obtain ⟨id, a, hg, hlv, hlt⟩ := hl.1 m hm hb j hj
    obtain ⟨hlo, hhi, hesc⟩ := hP o ho
    rw [heq] at hlt
    have hlt' : (Ryo.Proofs.Inline.fpAddr yh o - BitVec.ofNat 64 a.addr).toNat < a.size := by
      show (yh.reg .rbp + BitVec.ofInt 64 o - BitVec.ofNat 64 a.addr).toNat < a.size
      rw [hfp]
      exact hlt
    obtain ⟨e, he, h3, h4, _⟩ := hown id a o hg hlv hlo hhi hlt'
    exact Ryo.Proofs.ScopeMem.escapedAt_none hesc e he ⟨h3, h4⟩

/-- The pointer half: from the premise `hlive` (`KeptPtrLive`), `P`'s privacy (`PatchOk`) and
`FrameSep.own`. -/
theorem keptPtrApart_of_live (H : Hyps S) (C : Cert S) {s : R.RState} {P : Int → Prop}
    {y yh : X86.State} {kept : List Item} (hfr : FrameInv S s yh)
    (hci : CacheInv (S.used s.pc) yh) (hP : PatchOk S C s P) (he : EscSound S C s)
    (hsafe : RSafe S.Safe S.c s) (hin : InlineAt S s.pc)
    (hkept : S.c.d.items[s.pc]? = some kept) (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hlive : KeptPtrLive S.ctx s.st kept y) :
    KeptPtrApart S.ctx (yh.reg .rbp) P kept y := by
  refine keptPtrApart_of_own S.ctx rfl hfr.sep.own (fun o ho => ?_) kept y hlive
  obtain ⟨⟨h1, h2⟩, _, hesc, _⟩ := hP o ho
  refine ⟨h1, ?_, hesc⟩
  first
    | omega
    | (show o < 16 + (S.c.argSize : Int); omega)
    | (unfold Setup.K; omega)
    | (simp only [Setup.K]; omega)

/-- The kept items of inline instruction `s.pc` (`d.items`, what `inlineEffects` reads) touch no
byte of a patch set, run from a virtual state `y` agreeing with the ghost's `yh`. `hcs`: the kept
items are `cacheSafe` (what the cache emits). `hrd` is the checker's fact (DS case 1: a kept
`rbp`-based read misses `P`, so no cache miss reads a dropped byte the cache still covers), in
address form: `fp + disp + j` is no `fp + o`, `o ∈ P`. -/
theorem keptApart_of_live (H : Hyps S) (C : Cert S) {s : R.RState} {P : Int → Prop}
    {y yh : X86.State} {kept : List Item} (hfr : FrameInv S s yh)
    (hci : CacheInv (S.used s.pc) yh) (hP : PatchOk S C s P) (he : EscSound S C s)
    (hsafe : RSafe S.Safe S.c s) (hin : InlineAt S s.pc)
    (hkept : S.c.d.items[s.pc]? = some kept) (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hcs : ∀ it ∈ kept, cacheSafe it = true)
    (hrd : ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it, ∀ o, P o →
      yh.reg .rbp + m.disp.signExtend 64 + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o)
    (hlive : KeptPtrLive S.ctx s.st kept y) :
    KeptApart S.ctx (yh.reg .rbp) P kept y := by
  have hy : y.reg .rbp = yh.reg .rbp := by
    show y.regs _ = yh.regs _
    rw [ha.1]
  exact keptApart_of_ptr S.ctx kept y hcs hy hrd
    (keptPtrApart_of_live H C hfr hci hP he hsafe hin hkept ha hlive)

end Ryo.Proofs.DeadStore
