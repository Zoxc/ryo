import Ryo.Proofs.DecodeSound
import Ryo.Proofs.NoArgCursor

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

/-! ### `argStore`'s items -/

/-- The forms of `argStore`'s items: a store of `w` bytes at frame offset `d + o` inside the
written range, an SSE store of the whole range, `movd` into `r11`, a shift of a register. -/
def ArgItemForm (d : BitVec 32) (n : Nat) (i : Item) : Prop :=
  (∃ w r o, i = .st w r ⟨.rbp, d + BitVec.ofNat 32 o⟩ ∧ o + w.bits / 8 ≤ n ∧ r.usable = true) ∨
  (∃ x, i = .sse true n x (M.frame d) ∧ (n = 4 ∨ n = 8 ∨ n = 16) ∧ x < 8) ∨
  (∃ x, i = .movd false x .r11 ∧ x < 8) ∨
  (∃ r amt, i = .shift .shr .q r amt ∧ r.usable = true)

theorem arg_intArg_usable (pe : Bool) (i : Nat) : (intArg pe i).usable = true := by
  have := ArgRet.intArg_mem pe i
  generalize intArg pe i = g at this
  simp only [List.mem_cons, List.not_mem_nil, or_false] at this
  rcases this with h | h | h | h | h | h | h <;> subst h <;> rfl

theorem arg_items_form (a : ArgReg) (d : BitVec 32) (pe : Bool)
    (hv : (a.xmm = true → (a.size = 2 ∨ a.size = 4 ∨ a.size = 8 ∨ a.size = 16) ∧ a.index < 8) ∧
      (a.xmm = false → 1 ≤ a.size ∧ a.size ≤ 8 ∧ a.index < 6)) :
    ∀ i ∈ argStore a d pe, ArgItemForm d a.size i := by
  obtain ⟨xm, n, idx⟩ := a
  have hd0 : d + BitVec.ofNat 32 0 = d := by simp
  cases xm with
  | true =>
    obtain ⟨hs, hx⟩ := hv.1 rfl
    simp only [argStore, sseStore, ↓reduceIte]
    rcases hs with rfl | hs
    · intro i hi
      simp only [beq_self_eq_true, ↓reduceIte, List.mem_cons, List.not_mem_nil, or_false] at hi
      rcases hi with rfl | rfl
      · exact .inr (.inr (.inl ⟨idx, rfl, hx⟩))
      · exact .inl ⟨.w, .r11, 0, by rw [hd0]; rfl, by simp [W.bits], rfl⟩
    · have : (n == 2) = false := by rcases hs with rfl | rfl | rfl <;> rfl
      intro i hi
      simp only [this, Bool.false_eq_true, ↓reduceIte, List.mem_cons, List.not_mem_nil,
        or_false] at hi
      subst hi
      exact .inr (.inl ⟨idx, rfl, hs, hx⟩)
  | false =>
    obtain ⟨h1, h8, -⟩ := hv.2 rfl
    simp only [argStore, Bool.false_eq_true, ↓reduceIte]
    have hu := arg_intArg_usable pe idx
    generalize intArg pe idx = r at hu
    intro i hi
    have st0 : ∀ w : W, w.bits / 8 ≤ n → ArgItemForm d n (.st w r (M.frame d)) :=
      fun w hw => .inl ⟨w, r, 0, by rw [hd0]; rfl, by omega, hu⟩
    simp only at h1 h8
    obtain _|_|_|_|_|_|_|_|_|n := n
    any_goals omega
    all_goals simp [intStore, widthOf] at hi
    all_goals first
      | (subst hi; exact st0 _ (by simp [W.bits]))
      | (rcases hi with rfl | rfl | rfl | rfl | rfl <;>
          first
            | exact st0 _ (by simp [W.bits])
            | exact .inl ⟨_, r, _, rfl, by simp [W.bits], hu⟩
            | exact .inr (.inr (.inr ⟨r, _, rfl, hu⟩)))
      | (rcases hi with rfl | rfl | rfl <;>
          first
            | exact st0 _ (by simp [W.bits])
            | exact .inl ⟨_, r, _, rfl, by simp [W.bits], hu⟩
            | exact .inr (.inr (.inr ⟨r, _, rfl, hu⟩)))

theorem arg_sub_off (b A : BitVec 64) (o w n : Nat) (hn : n ≤ (b - A).toNat) (how : o + w ≤ n) :
    w ≤ (b - (A + BitVec.ofNat 64 o)).toNat := by
  have hlt := (b - A).isLt
  have ho : o < 2 ^ 64 := by omega
  have e : b - (A + BitVec.ofNat 64 o) = (b - A) - BitVec.ofNat 64 o := by bv_omega
  rw [e, BitVec.toNat_sub, BitVec.toNat_ofNat, Nat.mod_eq_of_lt ho]
  omega

theorem arg_usable_ne_rbp {r : X86.Reg} (h : r.usable = true) : r.idx ≠ Reg.rbp.idx := by
  cases r <;> simp_all [X86.Reg.usable] <;> decide

/-- One item of `argStore`: `rip` past it, `rbp` kept, memory kept outside the written range. -/
theorem arg_item_exec (ctx : Ctx) {d : BitVec 32} {n : Nat} {i : Item} (hf : ArgItemForm d n i)
    (hd : d.toInt + n ≤ 2 ^ 31) (hn : n ≤ 16) {y y' : X86.State} (he : i.exec ctx y = .ok y') :
    y'.rip = y.rip + BitVec.ofNat 64 i.size ∧ y'.reg .rbp = y.reg .rbp ∧
      ∀ b, n ≤ (b - fpAddr y d.toInt).toNat → y'.mem b = y.mem b := by
  have hb := toInt_bounds d
  rcases hf with ⟨w, r, o, rfl, how, hu⟩ | ⟨x, rfl, hs, hx⟩ | ⟨x, rfl, hx⟩ | ⟨r, amt, rfl, hu⟩
  · obtain ⟨z, e, hm, hr, -, hrip⟩ := ArgRet.exec_st ctx w r ⟨.rbp, d + BitVec.ofNat 32 o⟩ y
    rw [he] at e; cases e
    have hw : 1 ≤ w.bits / 8 := by cases w <;> simp [W.bits]
    refine ⟨hrip, by simp [State.reg, hr], fun b hbn => ?_⟩
    rw [hm, ArgRet.ea_off y d o (by omega) (by omega)]
    exact Mem.write_other _ _ _ _ _ (arg_sub_off b _ o _ n hbn how)
  · obtain ⟨z, e, hm, hr, -, hrip⟩ := ArgRet.exec_sse_st ctx n x (M.frame d) y hs
    rw [he] at e; cases e
    refine ⟨hrip, by simp [State.reg, hr], fun b hbn => ?_⟩
    rw [hm, ea_frame]
    exact Mem.write_other _ _ _ _ _ hbn
  · obtain ⟨z, e, hm, -, hr, -, hrip⟩ := ArgRet.exec_movd_from ctx x .r11 y
    rw [he] at e; cases e
    exact ⟨hrip, by simp only [State.reg]; exact hr _ (by decide), fun b _ => by rw [hm]⟩
  · obtain ⟨z, e, hm, -, hr, -, hrip⟩ := ArgRet.exec_shr ctx r amt y
    rw [he] at e; cases e
    exact ⟨hrip, by simp only [State.reg]; exact hr _ (arg_usable_ne_rbp hu).symm,
      fun b _ => by rw [hm]⟩

theorem arg_item_canonical {d : BitVec 32} {n : Nat} {i : Item} (hf : ArgItemForm d n i) (p : Nat) :
    i.Canonical p := by
  refine ⟨?_, .inl ?_⟩
  · rcases hf with ⟨w, r, o, rfl, -⟩ | ⟨x, rfl, -⟩ | ⟨x, rfl, -⟩ | ⟨r, amt, rfl, -⟩ <;>
      intro _ _ h <;> cases h
  · rcases hf with ⟨w, r, o, rfl, -, hu⟩ | ⟨x, rfl, hs, hx⟩ | ⟨x, rfl, hx⟩ | ⟨r, amt, rfl, hu⟩
    · simp [Item.wf, hu, Item.memWf]
    · rcases hs with rfl | rfl | rfl <;> simp [Item.wf, hx, M.frame]
    · simp [Item.wf, hx, X86.Reg.usable]
    · simp [Item.wf, hu, Sh.isShift]

theorem arg_canon {items : List Item} (h : ∀ i ∈ items, ∀ p, i.Canonical p) :
    ∀ pos, Canon items pos := by
  induction items with
  | nil => intro _; trivial
  | cons i is ih =>
    intro pos
    exact ⟨h i (by simp) pos, ih (fun j hj => h j (by simp [hj])) _⟩

theorem arg_fetchRun {ctx : Ctx} {S : BitVec 64 → Prop} (P : X86.State → Prop) :
    ∀ {items : List Item}, (∀ i ∈ items, ∀ y y', P y → i.exec ctx y = .ok y' →
      y'.rip = y.rip + BitVec.ofNat 64 i.size ∧ (∀ a, S a → y'.mem a = y.mem a) ∧ P y') →
    ∀ x, P x → FetchRun ctx S items x
  | [], _, _, _ => trivial
  | i :: is, h, x, hx => fun y hy => by
    obtain ⟨h1, h2, h3⟩ := h i (by simp) x y hx hy
    exact ⟨h1, h2, arg_fetchRun P (fun j hj => h j (by simp [hj])) y h3⟩

theorem arg_link_length (addr : BitVec 64) (addrOf : RefAddr) :
    ∀ (relocs : List X86.Reloc) (code : List UInt8), (link addr addrOf code relocs).length = code.length
  | [], _ => rfl
  | r :: rs, code => by
    simp only [link, List.foldl_cons] at *
    have := arg_link_length addr addrOf rs
    simp only [link] at this
    rw [this]; simp

theorem arg_linkedAt_length (ctx : Ctx) (i : Item) (pos : Nat) :
    (i.linkedAt ctx pos).length = i.size := by
  unfold Item.linkedAt
  simp only
  rw [arg_link_length, encode_len]

/-- The addresses of items decoded from a linked cursor are code addresses. -/
theorem arg_inCode_dec {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} (hk : LinkOk ctx m c rs) :
    ∀ {p q : Nat} {items : List Item}, Dec c p items q → Boundary rs p →
      ∀ a, InCode ctx items p a → ∃ j, j < c.code.size ∧ a = addrAt ctx j := by
  intro p q items hd
  induction hd with
  | nil => intro _ a h; exact absurd h id
  | @cons p n q i is hdi _ ih =>
    intro hb a ha
    obtain ⟨-, hsz, hle, hb'⟩ := decodeItem_itemAt (c := atPos c p) hk.fields hk.sorted hk.loaded
      hk.small hk.fp hb hdi
    rcases ha with ⟨j, hj, rfl⟩ | ha
    · rw [arg_linkedAt_length, hsz] at hj
      exact ⟨p + j, by simp at hle; omega, addrAt_add' ctx p j⟩
    · rw [hsz] at ha; exact ih hb' a ha

/-- A byte of the written range `[R + D, R + D + n)` (`D ∈ [-F, -n]`) is on the stack between
`R - F` and `R + 8`. -/
theorem arg_inStack {R b lo sp0 : BitVec 64} {fp F n : Nat} {D : Int} (hR : R.toNat = fp)
    (hfp : fp + 16 ≤ 2 ^ 64) (hF : F ≤ fp) (hlo : lo.toNat + 64 ≤ (R - BitVec.ofNat 64 F).toNat)
    (hsp : sp0 = R + 8) (hD1 : -(F : Int) ≤ D) (hD2 : D + n ≤ 0)
    (hb : (b - (R + BitVec.ofInt 64 D)).toNat < n) : InStack lo sp0 b := by
  have hRF : (R - BitVec.ofNat 64 F).toNat = fp - F := by
    rw [BitVec.toNat_sub, BitVec.toNat_ofNat, hR]
    have : F % 2 ^ 64 = F := Nat.mod_eq_of_lt (by omega)
    rw [this]; omega
  have hE : R + BitVec.ofInt 64 D = BitVec.ofNat 64 (fp - (-D).toNat) := by
    apply BitVec.eq_of_toNat_eq
    simp only [BitVec.toNat_add, BitVec.toNat_ofInt, BitVec.toNat_ofNat, hR]
    have h1 : (fp - (-D).toNat) % 2 ^ 64 = fp - (-D).toNat := Nat.mod_eq_of_lt (by omega)
    rw [h1]
    have : (D % (2 ^ 64 : Nat) : Int).toNat = 2 ^ 64 - (-D).toNat ∨ D = 0 := by omega
    rcases this with h | h
    · rw [h]; omega
    · subst h; simp; omega
  rw [hE] at hb
  generalize ht : (b - BitVec.ofNat 64 (fp - (-D).toNat)).toNat = t at hb
  have hbt : b.toNat = fp - (-D).toNat + t := by
    have := congrArg BitVec.toNat (BitVec.sub_add_cancel b (BitVec.ofNat 64 (fp - (-D).toNat))).symm
    rw [this, BitVec.toNat_add, ht, BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega : fp - (-D).toNat < 2 ^ 64)]
    rw [Nat.mod_eq_of_lt (by omega)]; omega
  have hsp' : sp0.toNat = fp + 8 := by
    rw [hsp, BitVec.toNat_add, hR]; simp; omega
  unfold InStack
  omega

/-- A byte at `R + c + i` (`i < 8`) is outside the written range `[R + D, R + D + n)` when
`D + n ≤ c`. -/
theorem arg_far {R : BitVec 64} {n : Nat} {D c : Int} (hD : -2 ^ 31 ≤ D) (hc : -16 ≤ c ∧ c ≤ 8)
    (h : D + n ≤ c) (i : Nat) (hi : i < 8) :
    n ≤ (R + BitVec.ofInt 64 c + BitVec.ofNat 64 i - (R + BitVec.ofInt 64 D)).toNat := by
  have e : ∀ A B C : BitVec 64, R + A + B - (R + C) = A + B - C := by intros; bv_omega
  rw [e, BitVec.toNat_sub, BitVec.toNat_add, BitVec.toNat_ofInt, BitVec.toNat_ofInt,
    BitVec.toNat_ofNat]
  omega

/-! ### R's side -/

/-- R errors that are not `noBehavior`. -/
def arg_NoNB {α : Type} (m : M α) : Prop := ∀ msg, m ≠ .error (.noBehavior msg)

theorem arg_noNB_bind {α β : Type} {m : M α} {f : α → M β} (h : arg_NoNB m)
    (hf : ∀ a, m = .ok a → arg_NoNB (f a)) : arg_NoNB (m >>= f) := by
  intro msg he
  cases hm : m with
  | error e => rw [hm] at he; cases he; exact h msg hm
  | ok a => rw [hm] at he; exact hf a hm msg he

theorem arg_noNB_pure {α : Type} (a : α) : arg_NoNB (pure a : M α) := by
  intro msg h; cases h

theorem arg_noNB_mapM {α β : Type} (f : α → M β) (hf : ∀ a, arg_NoNB (f a)) :
    ∀ l : List α, arg_NoNB (l.mapM f)
  | [] => by intro msg h; cases h
  | a :: l => by
    rw [List.mapM_cons]
    refine arg_noNB_bind (hf a) fun b _ => arg_noNB_bind (arg_noNB_mapM f hf l)
      fun bs _ => arg_noNB_pure _

theorem arg_noNB_foldlM {α β : Type} (f : β → α → M β) (hf : ∀ b a, arg_NoNB (f b a)) :
    ∀ (l : List α) (b : β), arg_NoNB (l.foldlM f b)
  | [], b => by intro msg h; cases h
  | a :: l, b => by
    rw [List.foldlM_cons]
    exact arg_noNB_bind (hf b a) fun b' _ => arg_noNB_foldlM f hf l b'

theorem arg_noNB_byteAt (st : OpSem.State) (o : Int) : arg_NoNB (st.byteAt o) := by
  intro msg h
  unfold OpSem.State.byteAt at h
  repeat' split at h
  all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h

theorem arg_noNB_readFrame (st : OpSem.State) (o : Int) (n : Nat) :
    arg_NoNB (st.readFrame o n) :=
  arg_noNB_mapM _ (fun _ => arg_noNB_byteAt _ _) _

theorem arg_noNB_writeFrame (st : OpSem.State) (o : Int) (bs : List AbstractByte) :
    arg_NoNB (st.writeFrame o bs) := by
  unfold OpSem.State.writeFrame
  refine arg_noNB_bind ?_ fun _ _ => arg_noNB_pure _
  unfold OpSem.State.writeEscaped
  refine arg_noNB_foldlM _ (fun mem bi => ?_) _ _
  intro msg h
  repeat' split at h
  all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h

theorem arg_noNB_applyScope (s : R.RState) (sc : R.Scope) :
    arg_NoNB (R.applyScope s sc) := by
  unfold R.applyScope
  split
  · unfold R.escape
    intro msg h
    have hr := arg_noNB_readFrame s.st
    simp only [arg_NoNB] at hr
    simp only [R.frameAddr, bind, Except.bind, pure, Except.pure] at h
    repeat' split at h
    all_goals first | cases h | simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h | skip
    all_goals (repeat' split at *) <;> simp_all [illFormed, throw, throwThe, MonadExceptOf.throw]
  · unfold R.storageEnd
    refine arg_noNB_bind (arg_noNB_writeFrame _ _ _) fun _ _ => arg_noNB_pure _
  · exact arg_noNB_pure _

theorem arg_noNB_scopes (l : List R.Scope) (s : R.RState) :
    arg_NoNB (l.foldlM R.applyScope s) :=
  arg_noNB_foldlM _ arg_noNB_applyScope l s

theorem arg_step_scopes_err {c : R.Code} {s : R.RState} {ch : OpSem.Choice} {i : Insn}
    {e : Stop} (hi : c.d.insns[s.pc]? = some i)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .error e) : R.step c s ch = .error e := by
  unfold R.step
  simp [hi, hsc, bind, Except.bind]

theorem arg_rstep {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice} {op : Reduced.Opcode}
    {d : BitVec 32} {r : BitVec 64} {f : Full.Opcode} {a : ArgReg} {st' : OpSem.State}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (ha : ArgReg.of? r.toNat true = some a)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hw : s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) = .ok st') :
    R.step c s ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf, hsh, ha, hw, pure, Except.pure]

set_option maxRecDepth 100000 in
theorem arg_ofFull {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull .arg = some op) : op.full = some .arg := by
  have e : (Reduced.Opcode.ofFull .arg).bind Reduced.Opcode.full = some .arg := by rfl
  rw [h] at e; exact e

set_option maxRecDepth 100000 in
theorem arg_shape : Full.Opcode.arg.info.shape = .arg := by decide

/-! ### The incoming registers along the leading `arg`s -/

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- A leading `arg`'s register is still related (`ArgsOk.conv`, `ArgsOk.distinct`). -/
theorem arg_regRel (H : Hyps S) {k : Nat} {r : R.Reg} {args : R.Regs} {x : X86.State}
    (hl : ArgsLive S k args x) (hk : LeadArg S k) (hr : ArgRegAt S k r) :
    ArgRet.RegRel S.c.mode.pe args x r :=
  hl r (H.argsOk.conv k r hk hr) (fun j hj hj' => H.argsOk.distinct j k r hj hk hj' hr)

/-- After `arg` at `k` (register `a`, a convention register), the registers no `arg` up to `k`
read stay related. Proof idea: `r ≠ .ofArgReg a`, so `ArgsLive` at `k` gives `RegRel r` at `x`;
`RegRel.congr` with `hregs`: `argClobbers a pe` is `[]`, `[r11]` (no argument register) or
`[intArg pe a.index]`, which is not `intArg pe i` for another `i` below 6 (PE 4) (`intArg`
injective there, by `decide` over the indices); the `xmm`s are kept. -/
theorem arg_argsLive_succ {k : Nat} {a : ArgReg} {args : R.Regs} {x x' : X86.State}
    (hl : ArgsLive S k args x) (ha : ArgRegAt S k (.ofArgReg a))
    (hconv : ArgRet.IsArg S.c.mode.pe (.ofArgReg a))
    (hregs : ∀ i : Fin 16, (∀ g ∈ ArgRet.argClobbers a S.c.mode.pe, i ≠ g.idx) → x'.regs i = x.regs i)
    (hxm : x'.xmm = x.xmm) : ArgsLive S (k + 1) args x' := by
  intro r hr hn
  have hne : r ≠ .ofArgReg a := fun e => hn k (Nat.lt_succ_self k) (e ▸ ha)
  refine (hl r hr (fun j hj => hn j (by omega))).congr ?_ (fun i _ => by rw [hxm])
  intro i e
  subst e
  apply hregs
  intro g hg
  obtain ⟨xm, n, idx⟩ := a
  cases xm <;> simp only [ArgRet.argClobbers, Bool.false_eq_true, ↓reduceIte] at hg <;>
    split at hg <;> simp only [List.mem_singleton, List.not_mem_nil] at hg <;> subst hg
  · have hne' : i ≠ idx := fun e => hne (by subst e; rfl)
    simp only [ArgRet.IsArg, R.Reg.ofArgReg, Bool.false_eq_true, ↓reduceIte] at hconv hr
    cases hpe : S.c.mode.pe <;> simp only [hpe, Bool.false_eq_true, ↓reduceIte] at hconv hr <;>
      obtain _|_|_|_|_|_|_ := i <;> obtain _|_|_|_|_|_|_ := idx <;>
        first | omega | decide | (simp at hne'; done)
  · simp only [ArgRet.IsArg] at hr
    cases hpe : S.c.mode.pe <;> simp only [hpe, Bool.false_eq_true, ↓reduceIte] at hr <;>
      obtain _|_|_|_|_|_|_ := i <;> first | omega | decide

set_option maxRecDepth 100000 in
/-- An inline sequence isn't an `arg`. -/
theorem arg_inline_ne (H : Hyps S) {cache cache' : Cache} {dropped dr' : List DroppedStore}
    {c c' : Cursor} {q : Proto}
    (h : (inlineInsn cache dropped true).run c = .ok (some (q, cache', dr'), c')) :
    q.op ≠ .arg := by
  intro hq
  obtain ⟨-, -, cand, br, out, hd, -⟩ := inlineInsn_read_drop h
  obtain ⟨cls, hm, -⟩ := decodeInline_spec hd
  rw [hq] at hm
  have h1 := (H.inlineOk _ _ hm).opShape
  have h2 : R.opShape .arg = false := by unfold R.opShape; rw [arg_shape]
  rw [h2] at h1
  cases h1

set_option maxRecDepth 100000 in
/-- The decoder's cache is empty at a leading `arg`: it starts empty, and an `arg` leaves it. -/
theorem arg_cache_empty (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) : ∀ k, k ≤ S.r.protos.size → S.args k = true → S.cache k = { pe := S.c.mode.pe }
  | 0, _, _ => by rw [hD.cache0, hD.modeEq]
  | k + 1, hk, ha => by
    have hk' : k < S.r.protos.toList.length := by simp; omega
    rw [hD.argsSucc k hk', Bool.and_eq_true] at ha
    obtain ⟨hak, hop⟩ := ha
    have ih := arg_cache_empty hD H k (by omega) hak
    have it := hD.iters k hk'
    generalize S.r.protos.toList[k] = pr at hop it
    generalize S.cache (k + 1) = c1 at it ⊢
    generalize S.cache k = c0 at it ih
    subst ih
    generalize S.args k = a0 at it
    generalize S.start k = s0 at it
    generalize S.start (k + 1) = s1 at it
    generalize S.dr k = d0 at it
    generalize S.dr (k + 1) = d1 at it
    cases it with
    | empty _ hin =>
      exact absurd (by simpa using hop) (arg_inline_ne H hin)
    | main _ _ hpr _ =>
      rw [show S.fr.mode.pe = S.c.mode.pe from rfl, ite_self] at hpr
      cases hpr with
      | arg _ => rfl
      | call _ _ => rfl
      | inline _ _ hin => exact absurd (by simpa using hop) (arg_inline_ne H hin)
      | insn _ _ _ _ => rfl

theorem arg_used_empty (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (H : Hyps S) {k : Nat} (hk : k < S.r.protos.size) (ha : S.args k = true) : S.used k = { pe := S.c.mode.pe } := by
  unfold Setup.used
  split
  · rfl
  · exact arg_cache_empty hD H k (by omega) ha

theorem arg_step_write_err {c : R.Code} {s s1 : R.RState} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {d : BitVec 32} {r : BitVec 64} {f : Full.Opcode} {a : ArgReg}
    {e : Stop}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (ha : ArgReg.of? r.toNat true = some a)
    (hsc : (c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hw : s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) = .error e) :
    R.step c s ch = .error e := by
  unfold R.step
  simp only [hi, bind, Except.bind, hsc, hf, hsh, ha, hw]

/-- A frame write to private bytes leaves memory and the escaped objects alone. -/
theorem arg_writeFrame_priv {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (hp : ∀ i < bs.length, st.escapedAt (off + i) = none) (h : st.writeFrame off bs = .ok st') :
    st'.mem = st.mem ∧ st'.escaped = st.escaped := by
  have hesc := writeFrame_escaped h
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    refine ⟨?_, hesc⟩
    unfold OpSem.State.writeEscaped at hm
    refine foldlM_inv (fun m => m = st.mem) (fun bi : AbstractByte × Nat => bi.2 < bs.length) _
      ?_ _ st.mem m' rfl ?_ hm
    · rintro m0 ⟨b, i⟩ m1 rfl hi hst
      simp only at hi hst
      rw [hp i hi] at hst
      cases hst; rfl
    · rintro ⟨b, i⟩ hbi
      rw [List.mk_mem_zipIdx_iff_getElem?, List.getElem?_eq_some_iff] at hbi
      exact hbi.1

/-- A byte of the written range `[fp + d, fp + d + n)` is the frame byte `d + t`, `t < n`. -/
theorem arg_in_range {x : X86.State} {d : Int} {n : Nat} {b : BitVec 64}
    (h : (b - fpAddr x d).toNat < n) : ∃ t < n, b = fpAddr x (d + t) :=
  ⟨_, h, by rw [fpAddr_add, bv_add_sub_toNat]⟩

/-- Clobbered registers are not `rsp`, `rbp` or callee-saved. -/
theorem arg_clobbers_ok (a : ArgReg) (pe : Bool) :
    ∀ g ∈ ArgRet.argClobbers a pe, g.idx ≠ 4 ∧ g.idx ≠ 5 ∧ ¬ Counter.CalleeSaved g.idx := by
  intro g hg
  have key : g = .r11 ∨ g ∈ [Reg.rax, .rcx, .rdx, .r8, .r9, .rdi, .rsi] := by
    unfold ArgRet.argClobbers at hg
    split at hg
    · split at hg
      · simp at hg; exact .inl hg
      · simp at hg
    · split at hg
      · simp at hg
      · simp only [List.mem_singleton] at hg; subst hg; exact .inr (ArgRet.intArg_mem _ _)
  simp only [List.mem_cons, List.not_mem_nil, or_false] at key
  rcases key with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Counter.CalleeSaved] <;> decide

/-- On PE the clobbered registers are not `rsi`/`rdi` (Win64 callee-saved). -/
theorem arg_clobbers_pe (a : ArgReg) : ∀ g ∈ ArgRet.argClobbers a true, g.idx ≠ 6 ∧ g.idx ≠ 7 := by
  intro g hg
  have key : g = .r11 ∨ g = .rax ∨ g ∈ [Reg.rcx, .rdx, .r8, .r9] := by
    unfold ArgRet.argClobbers at hg
    split at hg
    · split at hg
      · simp at hg; exact .inl hg
      · simp at hg
    · split at hg
      · simp at hg
      · simp only [List.mem_singleton] at hg; subst hg
        right; unfold intArg; simp only [↓reduceIte]; exact ArgRet.getD_mem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at key
  rcases key with rfl | rfl | rfl | rfl | rfl | rfl <;> decide

/-- `bodySim_arg`. The destination lies below the link slots (`FrameBounds.argBelow`) and the
decoder's cache is empty at the instruction (`hce`). Proof idea: `argInsn_bounds`/`LinkOk.dec`
give the items `argStore a d pe` in memory at `p` (canonical, fetched as `Steps`, none writing
the code: `CodeApart`); `FrameBounds.arg_step_fb` with `arg_regRel` gives `RRel`; `ArgPrivate`
makes the write private, so R's memory and escaped objects are unchanged (`MemRel`: no live
allocation holds a written byte, `FrameOwn`; `FrameSep` with `frameInit_writeFrame`); the link
slots, the code and the rodata are outside the written range; `arg_argsLive_succ` the
registers at `k + 1` (none callee-saved, nor PE's `rsi`/`rdi`: `arg_clobbers_ok`,
`arg_clobbers_pe`); `rip` at `S.start (k + 1)` with the cache empty. -/
theorem bodySim_arg' (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {q : Proto} {c' : Cursor} (ha : S.args k = true)
    (hP : ProtoFacts S k p q c' (S.used k))
    (hr : (argInsn S.fr.mode).run (atPos S.body p) = .ok (some q, c')) :
    BodySim S k p (S.used k) := by
  have hce := arg_used_empty hD H hP.lt ha
  intro s x hs hf hrip _ hsafe
  obtain ⟨a, d, hq, hs32, hi24, hofs, hdec, -⟩ := argInsn_bounds hr
  have hL := bs_linkOk_at hf.code p
  obtain ⟨hca, hc'pos, -⟩ := hL.dec hdec hP.bound
  have hof : ArgReg.of? (BitVec.ofNat 64 a.word).toNat true = some a := by
    have hw : (BitVec.ofNat 64 a.word).toNat = a.word := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by have := word_lt a; omega)
    rw [hw]
    obtain ⟨b, hb⟩ := Option.isSome_iff_exists.mp hofs
    rw [hb, of_word_eq hs32 hi24 hb]
  have hargsk := hP.args
  have hcache := hP.cache
  subst hq
  have hstop : S.start (k + 1) = c'.pos := by
    have hn := hP.nop
    generalize S.start (k + 1) = e at hn ⊢
    generalize c'.pos = e0 at hn ⊢
    cases hn with
    | none _ => rfl
    | nop h _ _ => simp [nopAfter] at h
  obtain ⟨i, p1, ctr, hi, hio, hlt, hpk⟩ := protoFacts_insnOf hP
  simp only [InsnOf] at hio
  obtain ⟨op, ops, hofull, rfl, hops⟩ := hio
  have hops' : ops = [.slot d, .imm (BitVec.ofNat 64 a.word)] :=
    opnds_plain hops (by intro o ho; simp at ho; rcases ho with rfl | rfl <;> rfl)
  subst hops'
  have hf' := arg_ofFull hofull
  have hik := hi
  rw [← hs] at hi
  have hv := ArgRet.argReg_of_spec hof
  have hfb := H.frameBounds.arg k op d _ .arg a hik hf' arg_shape hof
  have hlk := H.frameBounds.argBelow k op d _ .arg a hik hf' arg_shape hof
  have hdisp := H.frameBounds.arg_disp hik hf' arg_shape hof
  have hn16 : a.size ≤ 16 := by
    cases hx : a.xmm
    · have := (hv.2 hx).2.1; omega
    · rcases (hv.1 hx).1 with h | h | h | h <;> omega
  cases hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s with
  | error e =>
    exfalso
    obtain ⟨m, rfl⟩ := hsafe.1 {} e (step_scopes_err hi hsc)
    exact noNB_scopes _ _ m hsc
  | ok s1 =>
  cases hw : s1.st.writeFrame d.toInt ((s1.args.get (.ofArgReg a)).take a.size) with
  | error e =>
    exfalso
    obtain ⟨m, rfl⟩ := hsafe.1 {} e (arg_step_write_err hi hf' arg_shape hof hsc hw)
    exact arg_noNB_writeFrame _ _ _ m hw
  | ok st' =>
  have hstep := arg_rstep (ch := {}) hi hf' arg_shape hof hsc hw
  have hlead : LeadArg S k := ⟨hlt, by rw [hargsk, ha]; rfl⟩
  have hRA : ArgRegAt S k (.ofArgReg a) := ⟨op, d, _, .arg, a, hik, hf', arg_shape, hof, rfl⟩
  have hlive : ArgsLive S k s.args x := hs ▸ hf.args (hs ▸ hlead)
  have harg := arg_regRel H hlive hlead hRA
  obtain ⟨x', hx, hr', hrip', hpc, hfp, hargs, hxm, hregs⟩ :=
    arg_step_fb S.ctx H.frameBounds hf.rrel hi hf' arg_shape hof harg hstep
  obtain ⟨x2, hx2, hm2, -⟩ := ArgRet.exec_argStore S.ctx a d S.c.mode.pe x
    ⟨fun h => (hv.1 h).1, fun h => ⟨(hv.2 h).1, (hv.2 h).2.1⟩⟩ hdisp
  rw [hx] at hx2
  cases hx2
  have hrbp : x'.reg .rbp = x.reg .rbp :=
    hregs 5 (fun g hg h => (arg_clobbers_ok a _ g hg).2.1 h.symm)
  have hrsp : x'.rsp = x.rsp :=
    hregs 4 (fun g hg h => (arg_clobbers_ok a _ g hg).1 h.symm)
  have hfar : ∀ b, a.size ≤ (b - fpAddr x d.toInt).toNat → x'.mem b = x.mem b := fun b hb => by
    rw [hm2]; exact Mem.write_other _ _ _ _ _ hb
  have hFd : -(S.F : Int) ≤ d.toInt := hfb.1
  have hKd : d.toInt + a.size ≤ S.K := hfb.2
  have hwinApart : ∀ b, (∀ o : Int, -(S.F : Int) ≤ o → o < S.K → b ≠ S.winAddr o) →
      x'.mem b = x.mem b := by
    intro b hb
    apply hfar
    apply Classical.byContradiction
    intro hlt
    obtain ⟨t, ht, rfl⟩ := arg_in_range (Nat.lt_of_not_le hlt)
    exact hb (d.toInt + t) (by omega) (by omega) (hf.fpAddr_eq _)
  have hcode : ∀ j, j < S.body.code.size → x'.mem (addrAt S.ctx j) = x.mem (addrAt S.ctx j) :=
    fun j hj => hwinApart _ (H.codeApart _ (.inl ⟨j, hj, rfl⟩)).2.2.1
  have hLk' : LinkOk S.ctx x'.mem S.body S.rs := by
    obtain ⟨hfl, hso, ⟨hl1, hl2⟩, hsm, hfp0⟩ := hf.code
    refine ⟨hfl, hso, ⟨fun j hj hr => ?_, fun r hr kk hkk => ?_⟩, hsm, hfp0⟩
    · rw [hcode j hj]; exact hl1 j hj hr
    · rw [hcode _ (by have := H.relocsIn r hr; omega)]; exact hl2 r hr kk hkk
  have hro' : RoLoaded S.ctx x'.mem S.ro := by
    obtain ⟨base, h1, h2⟩ := hf.ro
    refine ⟨base, h1, fun j hj => ?_⟩
    rw [hwinApart _ (H.codeApart (base + BitVec.ofNat 64 j) (.inr ⟨j, hj, (h1 j).symm⟩)).2.2.1]
    exact h2 j hj
  -- fetching
  have hform := arg_items_form a d S.c.mode.pe hv
  have hcan : Canon (argStore a d S.c.mode.pe) p :=
    arg_canon (fun i hi pos => arg_item_canonical (hform i hi) pos) p
  have hInCode : ∀ b, InCode S.ctx (argStore a d S.c.mode.pe) p b →
      a.size ≤ (b - fpAddr x d.toInt).toNat := by
    intro b hb
    obtain ⟨j, hj, rfl⟩ := arg_inCode_dec hL hdec hP.bound b hb
    apply Classical.byContradiction
    intro hlt
    obtain ⟨t, ht, he⟩ := arg_in_range (Nat.lt_of_not_le hlt)
    exact (H.codeApart _ (.inl ⟨j, hj, rfl⟩)).2.2.1 (d.toInt + t) (by omega) (by omega)
      (he.trans (hf.fpAddr_eq _))
  have hrun : FetchRun S.ctx (InCode S.ctx (argStore a d S.c.mode.pe) p)
      (argStore a d S.c.mode.pe) x :=
    arg_fetchRun (fun y => y.reg .rbp = x.reg .rbp) (fun i hi y y' hy he => by
      obtain ⟨h1, h2, h3⟩ := arg_item_exec S.ctx (hform i hi) hdisp hn16 he
      refine ⟨h1, fun b hb => h3 b ?_, h2.trans hy⟩
      have e : fpAddr y d.toInt = fpAddr x d.toInt := by simp [fpAddr, hy]
      rw [e]; exact hInCode b hb) x rfl
  obtain ⟨hsteps, hripE, -⟩ := steps_of_run hcan hca hrip (fun _ h => h) hrun hx
  -- R's state after the scopes and the write
  have hk1 := scopes_keeps _ hsc
  obtain ⟨-, hsep1⟩ := sep_foldlM _ (H.frameBounds.scopesIn s.pc) (H.frameBounds.window hf.win)
    hf.rrel hf.sep hsc
  have hm1 := (memRel_foldlM _ (H.frameBounds.scope_size _) hf.rrel hf.mem hsc).2
  have hpriv := H.argPrivate s x s1 op d _ .arg a hf hi hf' arg_shape hof hsc
  have hlen : ((s1.args.get (.ofArgReg a)).take a.size).length ≤ a.size := List.length_take_le _ _
  obtain ⟨hmemEq, hescEq⟩ := arg_writeFrame_priv (fun i hi => hpriv i (by omega)) hw
  have hsub : ∀ u v : BitVec 64, u + v - u = v := by intros; bv_omega
  have hmem' : MemRel st' x' := by
    intro id al hg hl i hi
    rw [hmemEq] at hg
    have hr0 := hm1 id al hg hl i hi
    rw [hfar]
    · exact hr0
    apply Classical.byContradiction
    intro hlt
    obtain ⟨t, ht, he⟩ := arg_in_range (Nat.lt_of_not_le hlt)
    have hsp := hsep1.space id al hg hl
    obtain ⟨e, hemem, h1, h2, -⟩ := hsep1.own id al (d.toInt + t) hg hl (by omega) (by omega) (by
      rw [← he, BitVec.ofNat_add, hsub, BitVec.toNat_ofNat]
      simp only [Allocation.size] at *
      omega)
    have := hpriv t ht
    rw [OpSem.State.escapedAt, List.find?_eq_none] at this
    exact this e hemem (by simp; omega)
  have hsep' : FrameSep (-(S.F : Int)) S.K st' x' := by
    refine FrameSep.congr hrbp ⟨?_, frameInit_writeFrame hsep1.init hw hFd (by omega), ?_, ?_⟩
    · intro id al o hg hl h1 h2 hin
      rw [hmemEq] at hg
      rw [hescEq]
      exact hsep1.own id al o hg hl h1 h2 hin
    · intro id1 a1 id2 a2 i j h1 h2
      rw [hmemEq] at h1 h2
      exact hsep1.dis id1 a1 id2 a2 i j h1 h2
    · intro id al hg
      rw [hmemEq] at hg
      exact hsep1.space id al hg
  -- the link slots
  have hread : ∀ c : Int, -16 ≤ c ∧ c ≤ 8 → d.toInt + a.size ≤ c →
      Mem.read64 x'.mem (fpAddr x c) = Mem.read64 x.mem (fpAddr x c) := by
    intro c hc hle
    have hrd : Mem.readNat x'.mem (fpAddr x c) 8 = Mem.readNat x.mem (fpAddr x c) 8 :=
      readNat_congr _ _ _ _ (fun i hi => hfar _ (by
        have := arg_far (R := x.reg .rbp) (n := a.size) (D := d.toInt)
          (by have := toInt_bounds d; omega) hc hle i hi
        simpa [fpAddr] using this))
    simp only [Mem.read64, hrd]
  obtain ⟨f1, f2, f3, f4⟩ := hf.frame
  have hframe' : FrameFacts S x' := by
    have e8 : x.reg .rbp + 8 = fpAddr x 8 := rfl
    have e0 : x.reg .rbp = fpAddr x 0 := by simp [fpAddr]
    refine ⟨by rw [hrbp]; exact f1, ?_, ?_, fun i hi h5 => ?_⟩
    · rw [hrbp, e8, hread 8 (by omega) (by omega), ← e8]; exact f2
    · rw [hrbp, e0, hread 0 (by omega) (by omega), ← e0]; exact f3
    · rcases hi with hcs | ⟨hpe, h67⟩
      · rw [hregs i (fun g hg h => (arg_clobbers_ok a _ g hg).2.2 (h ▸ hcs))]
        exact f4 i (.inl hcs) h5
      · rw [hregs i (fun g hg h => by
          rw [hpe] at hg
          have := arg_clobbers_pe a g hg
          rcases h67 with rfl | rfl <;>
            first | exact this.1 h | exact this.1 h.symm | exact this.2 h | exact this.2 h.symm)]
        exact f4 i (.inr ⟨hpe, h67⟩) h5
  have hconv := H.argsOk.conv k _ hlead hRA
  refine Reach.steps hsteps (.done (.inl ⟨_, .step hstep, ⟨⟨hr', hmem', hsep', hk1.fp ▸ hf.win,
    hk1.fp ▸ hf.fpF, by rw [hrsp, hrbp]; exact hf.rsp, by rw [hrsp]; exact hf.room, hLk', hro',
    fun _ => ?_, hframe'⟩, .inl ⟨?_, ?_⟩⟩⟩))
  · show ArgsLive S (s1.pc + 1) s1.args x'
    rw [hk1.pc, hk1.args, hs]
    exact arg_argsLive_succ hlive hRA hconv hregs hxm
  · show x'.rip = addrAt S.ctx (S.start (s1.pc + 1))
    rw [hk1.pc, hs, hstop, hc'pos]
    exact hripE
  · show CacheInv (S.cache (s1.pc + 1)) x'
    rw [hk1.pc, hs, hcache, hce]
    exact CacheInv.emptyPe _ _

end Insn

end Ryo.Proofs.DecodeSound
