/-
Ryo.Proofs.Lower.FnRel — the function-level relation of the lowering simulation (M5a, aot.md §C1)
and the statement rules lifted to R's `step`.

`FnRel Γ ι live f0 m0 s1` bundles, for the active L0 frame `f0` with memory `m0` and the R state
`s1`:
- `FrameRel` (memory injection, every storage-live local related to its slot at `live`);
- `Hidden`: no live L0 byte carries the provenance of a private storage-live local (the reason
  `ι` may map those allocations to none);
- the frame's locals are not aliased (D12's caller storage is M5c's);
- distinct storage-live locals have distinct provenance (distinct allocations) and disjoint
  slots: the backend shares slots only between locals that are never storage-live together,
  which the checker validates (storage conflicts), so this holds for all storage-live locals,
  not only the semantically live ones; a write to one local's slot then never touches another
  storage-live local's, dead or not;
- every R escaped frame byte is one the function's `Escape` scopes cover (`Γ.escaped`), so the
  rules' static privacy (`Γ.escaped … = false`) gives R's dynamic one.

Lifts (`lift_binop`, `lift_binopImm`, `lift_copyInt`, `lift_constInt`): from a rule's facts (`BinopRule` …, a `LowerStmt` constructor's fields for `st` and `[i]`),
`i` at `pc` with no scopes there, outside PE, `FnRel` before and a successful L0 statement, R
steps to `pc + 1` with `FnRel` at any `live'` that adds at most the destination and is true on
the operands before. Operands may be `copy` or `move` (they evaluate alike). They take
`PlainView` of the instruction (not `resume`/`unreachable`, operands fitting their kinds: a
fact about `view`'s result the checker can decide) and integer locals of non-zero size (body
well-formedness). `StorageLive`/`StorageDead` (no instruction; the scopes at the next index
do the work) are not here yet.
-/
import Ryo.Proofs.Lower.ScopeRel
import Ryo.Proofs.Lower.SimBinOp
import Ryo.Proofs.Lower.SimBinImm
import Ryo.Proofs.Lower.SimMove
import Ryo.Proofs.Lower.StepBridge
import Ryo.Proofs.Lower.L0Inv
import Ryo.Proofs.OpFacts
import Ryo.Check.Lower.Stmt

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.R
open Ryo.Check.Lower (LocalSlot StmtCtx LowerStmt binMethod binInsnOk binImmInsnOk movInsnOk
  immInsnOk intTyOk immOpsOk immOpsOk_spec offOk)

/-! ### The relation -/

/-- `a` is the allocation of a private (unmapped) storage-live local of `f0`. -/
def PrivAlloc (ι : Inj) (f0 : Spec.Frame) (a : AllocId) : Prop :=
  ∃ (l : Local) (p : ThinPointer), f0.locals[l]? = some (some p) ∧ p.prov = some a ∧ ι a = none

/-- Two slots are disjoint. -/
def SlotsApart (a b : LocalSlot) : Prop := a.off + a.size ≤ b.off ∨ b.off + b.size ≤ a.off

/-- The function-level relation (see the module comment). -/
structure FnRel (Γ : StmtCtx) (ι : Inj) (live : Local → Bool) (f0 : Spec.Frame) (m0 : Memory)
    (s1 : R.RState) : Prop where
  frame : FrameRel ι Γ.slots live f0 m0 s1
  hidden : Hidden m0 (PrivAlloc ι f0)
  unaliased : f0.aliased = []
  provNe : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f0.locals[l]? = some (some p) →
    f0.locals[l']? = some (some p') → p.prov ≠ p'.prov
  apart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' → f0.locals[l]? = some (some p) →
    f0.locals[l']? = some (some p') → Γ.slots[l]? = some sl → Γ.slots[l']? = some sl' →
    SlotsApart sl sl'
  esc : ∀ o e, s1.st.escapedAt o = some e → Γ.escaped o = true

/-- What the lifts need of an instruction's view beyond the rule (decidable on `view`'s result):
not `resume` or `unreachable` unless its control is a trap (so the traps themselves pass), and
operands fitting their kinds. -/
structure PlainView (mode : Ryo.Obj.Mode) (ρ : Addrs) (i : Insn) : Prop where
  notResume : ∀ v, view mode ρ i = some v → v.ctl ≠ some .trap → v.op ≠ .resume
  notUnreachable : ∀ v, view mode ρ i = some v → v.ctl ≠ some .trap → v.op ≠ .unreachable
  fits : ∀ v, view mode ρ i = some v →
    (v.op.info.operands.zip v.ops).all (fun p => p.2.fits p.1.kind) = true

/-- A control other than `trap` (`PlainView`'s premise). -/
theorem ctl_ne_trap {o : Option (R.Then Nat)} {t : R.Then Nat} (h : o = some t)
    (ht : t ≠ .trap := by intro h; cases h) : o ≠ some .trap := by
  rw [h]; intro e; exact ht (Option.some.inj e)

theorem LocalRel.weaken {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory} {slot : LocalSlot}
    {p : ThinPointer} {lv lv' : Bool} (h : LocalRel ι fp st m0 slot p lv)
    (hw : lv' = true → lv = true) : LocalRel ι fp st m0 slot p lv' := by
  cases h with
  | priv a x hp hι hx hl ha hpa hs hpv hb =>
    exact .priv a x hp hι hx hl ha hpa hs hpv (fun h => hb (hw h))
  | esc a x e y hp hι hx hl ha hpa hs hin hy hyl hya hys =>
    exact .esc a x e y hp hι hx hl ha hpa hs hin hy hyl hya hys

/-- An operand local, semantically live, is related at `true`. -/
theorem FnRel.opnd {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame} {m0 : Memory}
    {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {a : Local} {pa : ThinPointer}
    {sa : LocalSlot} (hpa : f.locals[a]? = some (some pa)) (hsa : Γ.slots[a]? = some sa)
    (hl : live a = true) : LocalRel ι s1.fp s1.st m0 sa pa true := by
  obtain ⟨sa', hsa', hr⟩ := hrel.frame.locals a pa hpa (by rw [hrel.unaliased]; simp)
  rw [hsa] at hsa'
  obtain rfl := Option.some.inj hsa'
  rw [hl] at hr
  exact hr

/-- A destination slot no `Escape` covers is a private local. -/
theorem FnRel.priv_dst {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {d : Local} {pd : ThinPointer}
    {sd : LocalSlot} (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd)
    (hpos : 0 < sd.size) (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false) :
    ∃ ad xd, pd.prov = some ad ∧ ι ad = none ∧ m0.get? ad = some xd ∧ xd.live = true ∧
      (xd.addr : Int) = s1.fp + sd.off ∧ pd.addr = xd.addr ∧ xd.data.size = sd.size ∧
      ∀ k < sd.size, s1.st.escapedAt (sd.off + k) = none := by
  obtain ⟨sd', hsd', hr⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
  rw [hsd] at hsd'
  obtain rfl := Option.some.inj hsd'
  cases hr with
  | priv a x hp hι hx hl ha hpa hs hpv _ => exact ⟨a, x, hp, hι, hx, hl, ha, hpa, hs, hpv⟩
  | esc a x e y _ _ _ _ _ _ _ hin _ _ _ _ =>
    exfalso
    have h1 := hrel.esc _ _ (hin 0 hpos)
    rw [hpriv 0 hpos] at h1
    cases h1

/-- After a write to the destination's slot (see `sim_binop`'s conclusion), `FnRel` at a
`live'` that adds at most the destination. -/
theorem FnRel.after {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 m0' : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {st' : OpSem.State}
    {pc' : Nat} {d : Local} {pd : ThinPointer} {sd : LocalSlot}
    (hpd : f.locals[d]? = some (some pd)) (hsd : Γ.slots[d]? = some sd)
    (hmi : MemInj ι m0' st'.mem) (hrd : LocalRel ι s1.fp st' m0' sd pd true)
    (hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m0 slot p lv → p.prov ≠ pd.prov →
      (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' m0' slot p lv)
    (hhid : Hidden m0' (PrivAlloc ι f)) (hesc : st'.escaped = s1.st.escaped)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true) :
    FnRel Γ ι live' f m0' { s1 with pc := pc', st := st' } := by
  refine ⟨⟨hmi, ?_⟩, hhid, hrel.unaliased, hrel.provNe, hrel.apart, ?_⟩
  · intro l p hp hal
    by_cases hl : l = d
    · subst hl
      have e : p = pd := Option.some.inj (Option.some.inj (hp.symm.trans hpd))
      subst e
      exact ⟨sd, hsd, hrd.weaken (fun _ => rfl)⟩
    · obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
      refine ⟨slot, hsl, (hoth slot p (live l) hr (hrel.provNe l d p pd hl hp hpd)
        (hrel.apart d l pd p sd slot (Ne.symm hl) hpd hp hsd hsl)).weaken ?_⟩
      intro h
      rcases hlive' l h with h | h
      · exact absurd h hl
      · exact h
  · intro o e he
    apply hrel.esc o e
    have h2 : st'.escapedAt o = some e := he
    show s1.st.escapedAt o = some e
    unfold OpSem.State.escapedAt at h2 ⊢
    rw [← hesc]
    exact h2

/-! ### Provenance-free stores -/

theorem encodeBits_noprov (n v : Nat) : ∀ b ∈ encodeBits n v, b.provFrag = none := by
  intro b hb
  simp only [encodeBits, List.mem_map] at hb
  obtain ⟨u, -, rfl⟩ := hb
  rfl

theorem typedStore_int_noprov {mem mem' : Memory} {p : ThinPointer} {v : Value} {t : IntType}
    {valid : ValidRange} {al : Align} (h : typedStore mem p v (.int t valid) al = .ok mem') :
    ∃ bs, mem.store p bs al = .ok mem' ∧ ∀ b ∈ bs, b.provFrag = none := by
  cases v
  all_goals first
    | exact ⟨_, typedStore_int h, encodeBits_noprov _ _⟩
    | (exfalso
       first
         | (simp [typedStore, Ty.encode, throwIllFormed, throwThe, MonadExceptOf.throw] at h; done)
         | (simp [typedStore, Ty.encode] at h; done))

/-- A successful assignment at integer type `t` to `_d`, its rvalue evaluated without changing
the state: the L0 memory after is a provenance-free store into `_d`. -/
theorem assign_int_mem {s s1 s' : Spec.State} {f : Spec.Frame} {d : Local} {pd : ThinPointer}
    {t : IntType} {valid : ValidRange} {td : Spec.Ty} {v : Value} {mem' : Memory}
    (htd : f.body.locals[d]? = some (.int t valid)) (htd' : f.body.locals[d]? = some td)
    (hst : typedStore s1.mem pd v td .one = .ok mem') (hs1 : s1 = s)
    (hs' : s' = { s1 with mem := mem' }) :
    s'.stack = s.stack ∧ ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧
      ∀ b ∈ bs, b.provFrag = none := by
  subst hs1 hs'
  have e : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  subst e
  exact ⟨rfl, typedStore_int_noprov hst⟩

theorem binop_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) {d a b : Local} {op : BinOp} {m : String}
    (hm : binMethod op = some m) {t : IntType} {valid : ValidRange}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    (htb : f.body.locals[b]? = some (.int t valid))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))))
      o s = (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧ s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd, pa, pb, td, ta, tb, va, vb, v, hpd, -, -, htd', hta', htb', hla, hlb,
    s1, hev, mem', hst, hs'⟩ := assign_binop_inv hs h
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  have e6 : tb = .int t valid := Option.some.inj (htb'.symm.trans htb)
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  subst e4 e5 e6
  obtain ⟨bsa, ua, -, -, -, rfl⟩ := typedLoad_int hla
  obtain ⟨bsb, ub, -, -, -, rfl⟩ := typedLoad_int hlb
  have hev2 := evalIntBinOp_wrap hm t (t.ofBits ua) (t.ofBits ub) (.int t valid) o s
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits ub) (.int t valid)) o s = _ at hev
  rw [hev2] at hev
  simp only [Prod.mk.injEq, Except.ok.injEq] at hev
  obtain ⟨-, hs1⟩ := hev
  exact ⟨pd, hpd, assign_int_mem htd htd hst hs1.symm hs'⟩

theorem binImm_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {op : BinOp} {m : String}
    (hm : binMethod op = some m) {t : IntType} {valid vc : ValidRange} {bits : Nat}
    (htd : f.body.locals[d]? = some (.int t valid)) (hta : f.body.locals[a]? = some (.int t valid))
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op (.copy ⟨a, []⟩) (.const (.scalar bits) (.int t vc))))) o s = (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧ s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd, pa, td, ta, va, w, hpd, -, htd', hta', hla, s1, hev, mem', hst, hs'⟩ :=
    assign_binimm_inv hs h
  have e4 : td = .int t valid := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = .int t valid := Option.some.inj (hta'.symm.trans hta)
  subst e4 e5
  obtain ⟨bsa, ua, -, -, -, rfl⟩ := typedLoad_int hla
  have hev2 := evalIntBinOp_wrap hm t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size)))
    (.int t valid) o s
  change runOn (evalIntBinOp op t (t.ofBits ua) (t.ofBits (bits % 2 ^ (8 * t.size)))
    (.int t valid)) o s = _ at hev
  rw [hev2] at hev
  simp only [Prod.mk.injEq, Except.ok.injEq] at hev
  obtain ⟨-, hs1⟩ := hev
  exact ⟨pd, hpd, assign_int_mem htd htd hst hs1.symm hs'⟩

theorem use_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) {d : Local} {oa : Operand} {t : IntType} {valid : ValidRange}
    (htd : f.body.locals[d]? = some (.int t valid))
    (hev0 : ∀ r s1, runOn (evalOperand oa) o s = (.ok r, s1) → s1 = s)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use oa))) o s = (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧ s'.stack = s.stack ∧
      ∃ bs, s.mem.store pd bs .one = .ok s'.mem ∧ ∀ b ∈ bs, b.provFrag = none := by
  obtain ⟨pd, td, r, s1, hpd, htd', hev, mem', hst, hs'⟩ := assign_use_inv hs h
  exact ⟨pd, hpd, assign_int_mem htd htd' hst (hev0 r s1 hev) hs'⟩

/-! ### Operands: `copy` and `move` -/

theorem local?_cases {oa : Operand} {a : Local} (h : oa.local? = some a) :
    oa = .copy ⟨a, []⟩ ∨ oa = .move ⟨a, []⟩ := by
  unfold Operand.local? at h
  split at h
  all_goals (try cases h)
  all_goals first | exact .inl rfl | exact .inr rfl

theorem evalOperand_move (p : MPlace) : evalOperand (.move p) = evalOperand (.copy p) := rfl

theorem eval_binop_norm {pl : MPlace} {op : BinOp} {oa ob : Operand} {a b : Local}
    (ha : oa.local? = some a) (hb : ob.local? = some b) :
    evalStatement (.assign pl (.binaryOp op oa ob)) =
      evalStatement (.assign pl (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))) := by
  rcases local?_cases ha with rfl | rfl <;> rcases local?_cases hb with rfl | rfl <;>
    first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]

theorem eval_binopImm_norm {pl : MPlace} {op : BinOp} {oa ob : Operand} {a : Local}
    (ha : oa.local? = some a) :
    evalStatement (.assign pl (.binaryOp op oa ob)) =
      evalStatement (.assign pl (.binaryOp op (.copy ⟨a, []⟩) ob)) := by
  rcases local?_cases ha with rfl | rfl <;>
    first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]

theorem eval_use_norm {pl : MPlace} {oa : Operand} {a : Local} (ha : oa.local? = some a) :
    evalStatement (.assign pl (.use oa)) = evalStatement (.assign pl (.use (.copy ⟨a, []⟩))) := by
  rcases local?_cases ha with rfl | rfl <;>
    first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]

/-! ### The checker's instruction forms -/

theorem intTyOk_spec {ty : String} {n : Nat} (h : intTyOk ty n = true) :
    ∃ sg, OpSem.Ty.parse ty = some (.int n sg) := by
  unfold intTyOk at h
  split at h
  next n' sg hp =>
    have e : n' = n := by simpa using h
    subst e
    exact ⟨sg, hp⟩
  · cases h

theorem offOk_spec {o : Int} (h : offOk o = true) : -2 ^ 31 ≤ o ∧ o < 2 ^ 31 := by
  simpa [offOk] using h

theorem binInsnOk_spec {Γ : StmtCtx} {i : Insn} {m : String} {n : Nat} {d a b : Int}
    (h : binInsnOk Γ i m n d a b = true) :
    ∃ v kd ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨kd, [ty, m], r⟩ ∧
      (kd = .bin ∨ kd = .binop) ∧ intTyOk ty n = true ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩] ∧
      v.ops = [.slot d, .slot a, .slot b] ∧ v.ctl = some .next := by
  unfold binInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty m' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true] at h
      obtain ⟨⟨⟨⟨⟨hkd, hm⟩, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hm
      exact ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩
    · cases h
  · cases h

theorem movInsnOk_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {d s : Int}
    (h : movInsnOk Γ i n d s = true) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.mov, [ty], r⟩ ∧
      intTyOk ty n = true ∧ v.op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩] ∧
      v.ops = [.slot d, .slot s] ∧ v.ctl = some .next := by
  unfold movInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨hkd, hty⟩, ho⟩, hops⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩
    · cases h
  · cases h

theorem binImmInsnOk_spec {Γ : StmtCtx} {i : Insn} {m : String} {n : Nat} {d a : Int} {bits : Nat}
    (h : binImmInsnOk Γ i m n d a bits = true) :
    ∃ v kd ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨kd, [ty, m], r⟩ ∧
      (kd = .bin_imm ∨ kd = .binop_imm) ∧ intTyOk ty n = true ∧
      v.op.info.operands.map (·.name) = ["d", "a", "imm"] ∧
      (v.op.info.operands.take 2).map (·.kind) = [.slot, .slot] ∧
      immOpsOk v.ops [d, a] n bits = true ∧ v.ctl = some .next := by
  unfold binImmInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty m' r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true] at h
      obtain ⟨⟨⟨⟨⟨⟨hkd, hm⟩, hty⟩, hn⟩, hk⟩, hops⟩, hctl⟩ := h
      subst hm
      exact ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩
    · cases h
  · cases h

theorem immInsnOk_spec {Γ : StmtCtx} {i : Insn} {n : Nat} {d : Int} {bits : Nat}
    (h : immInsnOk Γ i n d bits = true) :
    ∃ v ty r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.imm, [ty], r⟩ ∧
      intTyOk ty n = true ∧ v.op.info.operands.map (·.name) = ["d", "imm"] ∧
      v.op.info.operands.head?.map (·.kind) = some .slot ∧
      immOpsOk v.ops [d] n bits = true ∧ v.ctl = some .next := by
  unfold immInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ty r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨⟨⟨hkd, hty⟩, hn⟩, hk⟩, hops⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩
    · cases h
  · cases h

theorem operands3 {l : List OperandInfo}
    (hn : l.map (·.name) = ["d", "a", "imm"]) (hk : (l.take 2).map (·.kind) = [.slot, .slot]) :
    ∃ k, l = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩] := by
  rcases l with _ | ⟨⟨n1, k1⟩, _ | ⟨⟨n2, k2⟩, _ | ⟨⟨n3, k3⟩, _ | ⟨w, l⟩⟩⟩⟩ <;> simp at hn
  simp at hk
  obtain ⟨rfl, rfl, rfl⟩ := hn
  obtain ⟨rfl, rfl⟩ := hk
  exact ⟨_, rfl⟩

theorem operands2 {l : List OperandInfo}
    (hn : l.map (·.name) = ["d", "imm"]) (hk : l.head?.map (·.kind) = some .slot) :
    ∃ k, l = [⟨"d", .slot⟩, ⟨"imm", k⟩] := by
  rcases l with _ | ⟨⟨n1, k1⟩, _ | ⟨⟨n2, k2⟩, _ | ⟨w, l⟩⟩⟩ <;> simp at hn
  simp at hk
  obtain ⟨rfl, rfl⟩ := hn
  subst hk
  exact ⟨_, rfl⟩

/-- The immediate fits its operand kind (`PlainView.fits`). -/
theorem fits_last {ops : Operands} {infos : List OperandInfo} {k : OperandKind} {x : Nat}
    (hall : (infos.zip ops).all (fun p => p.2.fits p.1.kind) = true)
    (hmem : (⟨"imm", k⟩, Val.imm x) ∈ infos.zip ops) : Val.fits k (.imm x) = true := by
  have := List.all_eq_true.mp hall _ hmem
  simpa using this

/-! ### From a view to R's step -/

theorem view_native_opShape {mode : Ryo.Obj.Mode} {ρ : Addrs} {op : Reduced.Opcode}
    {ops : List (Opnd Nat)} {v : View} {f : Full.Opcode}
    (hv : view mode ρ (.native op ops) = some v) (hf : op.full = some f)
    (hc : v.ctl.isSome = true) : opShape f = true := by
  cases hs : opShape f
  · exfalso
    obtain ⟨vop, vops, vctl⟩ := v
    obtain ⟨c0, rfl⟩ := Option.isSome_iff_exists.mp hc
    simp [view, hf, hs] at hv
    obtain ⟨-, hb⟩ := hv
    revert hb
    generalize List.mapM (fun x => nativeVal ρ x.fst.kind x.snd) (f.info.operands.zip ops) = r
    cases r <;> simp
  · rfl

theorem shapes_of_opShape {f : Full.Opcode} (h : opShape f = true) :
    f.info.shape ≠ .jmp ∧ f.info.shape ≠ .arg ∧ f.info.shape ≠ .ret ∧ f.info.shape ≠ .call ∧
      f.info.shape ≠ .tailCall ∧ f.info.shape ≠ .island := by
  unfold opShape at h
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> intro he <;> simp [he] at h

theorem step_of_view {c : Code} {s1 : R.RState} {ch : OpSem.Choice} {i : Insn} {v : View}
    {st' : OpSem.State} (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = [])
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i) (hv : view c.mode c.ρ i = some v)
    (hctl : v.ctl = some .next) (hop : opSem v.op v.ops s1.st ch = .ok (.next, st')) :
    step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) :=
  step_of_opSem hi hsc hv hctl (hpl.notResume v hv (ctl_ne_trap hctl))
      (hpl.notUnreachable v hv (ctl_ne_trap hctl)) hpe
    (fun op ops he f hf => by
      subst he
      exact shapes_of_opShape (view_native_opShape hv hf (by rw [hctl]; rfl))) hop

/-! ### The rules' facts

Each lift takes its rule's facts as one proposition (the fields of its `LowerStmt` constructor),
so the dispatch over `LowerStmt` (one `cases`, robust to new constructors there) builds them. -/

/-- `LowerStmt.binop`'s facts. -/
def BinopRule (Γ : StmtCtx) (d : Local) (op : BinOp) (oa ob : Operand) (i : Insn) : Prop :=
  ∃ (m : String) (a b : Local) (t : IntType) (valid : ValidRange) (sd sa sb : LocalSlot),
    binMethod op = some m ∧ oa.local? = some a ∧ ob.local? = some b ∧
    Γ.body.locals[d]? = some (.int t valid) ∧ Γ.body.locals[a]? = some (.int t valid) ∧
    Γ.body.locals[b]? = some (.int t valid) ∧
    Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧ Γ.slots[b]? = some sb ∧
    (sd.size = t.size ∧ sa.size = t.size ∧ sb.size = t.size) ∧
    (offOk sd.off ∧ offOk sa.off ∧ offOk sb.off) ∧
    (∀ k < sd.size, Γ.escaped (sd.off + k) = false) ∧
    binInsnOk Γ i m t.size sd.off sa.off sb.off = true

/-- `LowerStmt.binopImm`'s facts. -/
def BinopImmRule (Γ : StmtCtx) (d : Local) (op : BinOp) (oa : Operand) (bits : Nat)
    (t : IntType) (valid : ValidRange) (i : Insn) : Prop :=
  ∃ (m : String) (a : Local) (sd sa : LocalSlot), binMethod op = some m ∧ oa.local? = some a ∧
    Γ.body.locals[d]? = some (.int t valid) ∧ Γ.body.locals[a]? = some (.int t valid) ∧
    Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧
    (sd.size = t.size ∧ sa.size = t.size) ∧ (offOk sd.off ∧ offOk sa.off) ∧
    (∀ k < sd.size, Γ.escaped (sd.off + k) = false) ∧
    binImmInsnOk Γ i m t.size sd.off sa.off bits = true

/-- `LowerStmt.copyInt`'s facts. -/
def CopyIntRule (Γ : StmtCtx) (d : Local) (oa : Operand) (i : Insn) : Prop :=
  ∃ (a : Local) (t : IntType) (valid : ValidRange) (sd sa : LocalSlot), oa.local? = some a ∧
    Γ.body.locals[d]? = some (.int t valid) ∧ Γ.body.locals[a]? = some (.int t valid) ∧
    Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧
    (sd.size = t.size ∧ sa.size = t.size) ∧ (offOk sd.off ∧ offOk sa.off) ∧
    (∀ k < sd.size, Γ.escaped (sd.off + k) = false) ∧
    movInsnOk Γ i t.size sd.off sa.off = true

/-- `LowerStmt.constInt`'s facts. -/
def ConstIntRule (Γ : StmtCtx) (d : Local) (bits : Nat) (t : IntType) (valid : ValidRange)
    (i : Insn) : Prop :=
  ∃ sd : LocalSlot, Γ.body.locals[d]? = some (.int t valid) ∧ Γ.slots[d]? = some sd ∧
    sd.size = t.size ∧ offOk sd.off ∧ (∀ k < sd.size, Γ.escaped (sd.off + k) = false) ∧
    immInsnOk Γ i t.size sd.off bits = true

/-! ### The lifts -/

/-- Integer locals have non-zero size (body well-formedness, `IntType.wf`). -/
abbrev IntsSized (b : Spec.Body) : Prop := ∀ (l : Local) (t : IntType) (valid : ValidRange), b.locals[l]? = some (Spec.Ty.int t valid) → 0 < t.size

theorem lift_binop {Γ : StmtCtx} {c : Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {op : BinOp} {oa ob : Operand} {i : Insn}
    (hlow : BinopRule Γ d op oa ob i)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hlo : ∀ a, oa.local? = some a ∨ ob.local? = some a → live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op oa ob))) o s = (.ok (), s')) :
    ∃ st', step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
      s'.stack = s.stack ∧ FnRel Γ ι live' f s'.mem { s1 with pc := s1.pc + 1, st := st' } := by
  obtain ⟨m, a, b, t, valid, sd, sa, sb, hm, ha, hb, htd, hta, htb, hsd, hsa, hsb, hsize, hoff,
    hpriv, hbi⟩ := hlow
  have hla := hlo a (.inl ha)
  have hlb := hlo b (.inr hb)
  rw [eval_binop_norm ha hb] at h
  obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, ho, hops, hctl⟩ := binInsnOk_spec hbi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  rw [hbody] at htd hta htb
  obtain ⟨pd, pa, pb, _, _, _, _, _, _, hpd, hpa, hpb, -⟩ := assign_binop_inv hs h
  have hra := hrel.opnd hpa hsa hla
  have hrb := hrel.opnd hpb hsb hlb
  have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf d t valid htd
  obtain ⟨ad, xd, hp, hι, hx, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos hpriv
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2.1
  have hf3 := offOk_spec hoff.2.2
  obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_binop (ch := ch) hs hm htd hta htb hsize.1 hsize.2.1
    hsize.2.2 hpd hpa hpb hrel.frame.mem hra hrb ad xd hp hι hx hl haddr hpaddr hsz hpv hkd hh
    hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hf3.1, hf3.2⟩ h
  obtain ⟨pd', hpd', hstk, bs, hsto, hnp⟩ := binop_mem hs hm htd hta htb h
  obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  refine ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk, ?_⟩
  exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'

theorem lift_binopImm {Γ : StmtCtx} {c : Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {op : BinOp} {oa : Operand} {bits : Nat} {t : IntType} {valid : ValidRange}
    {i : Insn}
    (hlow : BinopImmRule Γ d op oa bits t valid i)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hlo : ∀ a, oa.local? = some a → live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.binaryOp op oa (.const (.scalar bits) (.int t valid))))) o s = (.ok (), s')) :
    ∃ st', step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
      s'.stack = s.stack ∧ FnRel Γ ι live' f s'.mem { s1 with pc := s1.pc + 1, st := st' } := by
  obtain ⟨m, a, sd, sa, hm, ha, htd, hta, hsd, hsa, hsize, hoff, hpriv, hbi⟩ := hlow
  have hla := hlo a ha
  rw [eval_binopImm_norm ha] at h
  obtain ⟨v, kd, ty, r, hv, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmInsnOk_spec hbi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
  obtain ⟨k, ho⟩ := operands3 hn hk
  have hops'' : v.ops = [.slot sd.off, .slot sa.off, .imm x] := hops'
  have hfk : Val.fits k (.imm x) = true :=
    fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
  rw [hbody] at htd hta
  obtain ⟨pd, pa, _, _, _, _, hpd, hpa, -⟩ := assign_binimm_inv hs h
  have hra := hrel.opnd hpa hsa hla
  have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf d t valid htd
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos hpriv
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_binImm (ch := ch) hs hm htd hta hsize.1 hsize.2
    hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hkd hh hty' ho
    ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hfk hx h
  obtain ⟨pd', hpd', hstk, bs, hsto, hnp⟩ := binImm_mem hs hm htd hta h
  obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  refine ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk, ?_⟩
  exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'

theorem lift_copyInt {Γ : StmtCtx} {c : Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {oa : Operand} {i : Insn}
    (hlow : CopyIntRule Γ d oa i)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hlo : ∀ a, oa.local? = some a → live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use oa))) o s = (.ok (), s')) :
    ∃ st', step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
      s'.stack = s.stack ∧ FnRel Γ ι live' f s'.mem { s1 with pc := s1.pc + 1, st := st' } := by
  obtain ⟨a, t, valid, sd, sa, ha, htd, hta, hsd, hsa, hsize, hoff, hpriv, hmi0⟩ := hlow
  have hla := hlo a ha
  rw [eval_use_norm ha] at h
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi0
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  rw [hbody] at htd hta
  obtain ⟨pd, _, _, _, hpd, _, hev, -⟩ := assign_use_inv hs h
  obtain ⟨pa, _, _, hpa, -⟩ := runOn_evalOperand_copy hs hev
  have hra := hrel.opnd hpa hsa hla
  have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf d t valid htd
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos hpriv
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_copyInt (ch := ch) hs htd hta hsize.1 hsize.2
    hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hh hty' ho
    ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ h
  obtain ⟨pd', hpd', hstk, bs, hsto, hnp⟩ := use_mem hs htd
    (fun r s1 hr => by
      obtain ⟨_, _, _, _, _, _, _, h1⟩ := runOn_evalOperand_copy hs hr
      exact h1) h
  obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  refine ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk, ?_⟩
  exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'

theorem lift_constInt {Γ : StmtCtx} {c : Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {bits : Nat} {t : IntType} {valid : ValidRange} {i : Insn}
    (hlow : ConstIntRule Γ d bits t valid i)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.const (.scalar bits) (.int t valid)))))
      o s = (.ok (), s')) :
    ∃ st', step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
      s'.stack = s.stack ∧ FnRel Γ ι live' f s'.mem { s1 with pc := s1.pc + 1, st := st' } := by
  obtain ⟨sd, htd, hsd, hsize, hoff, hpriv, hii⟩ := hlow
  obtain ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ := immInsnOk_spec hii
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
  obtain ⟨k, ho⟩ := operands2 hn hk
  have hops'' : v.ops = [.slot sd.off, .imm x] := hops'
  have hfk : Val.fits k (.imm x) = true :=
    fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
  rw [hbody] at htd
  obtain ⟨pd, _, _, _, hpd, -⟩ := assign_use_inv hs h
  have hpos : 0 < sd.size := by rw [hsize]; exact hwf d t valid htd
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos hpriv
  have hf1 := offOk_spec hoff
  obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_constInt (ch := ch) hs htd hsize hpd hrel.frame.mem
    ad xd hp hι hxd hl haddr hpaddr hsz hpv hh hty' ho ⟨hf1.1, hf1.2⟩ hfk hx h
  obtain ⟨pd', hpd', hstk, bs, hsto, hnp⟩ := use_mem hs htd
    (fun r s1 hr => (runOn_evalOperand_const_scalar_int hr).2) h
  obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  refine ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk, ?_⟩
  exact hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive'

/-! ### Storage statements

They lower to no instruction: R's state is unchanged here, and the `Escape`/`End` scopes at the
next index (`ScopeRel`: `escape_rel`, `storageEnd_rel`) do R's part. -/

theorem getElem?_set!_ne {α : Type} {a : Array α} {i j : Nat} {v : α} (h : j ≠ i) :
    (a.set! i v)[j]? = a[j]? := by
  simp [Array.set!, Ne.symm h]

theorem getElem?_set!_self {α : Type} {a : Array α} {i : Nat} {v w : α}
    (h : (a.set! i v)[i]? = some w) : w = v := by
  simp [Array.set!, Array.getElem?_setIfInBounds] at h
  first | exact h.2.symm | exact h.symm | (obtain ⟨_, rfl⟩ := h; rfl)

/-- A local's relation only looks at its own L0 allocation. -/
theorem LocalRel.mem_congr {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 slot p lv)
    (hg : ∀ a, p.prov = some a → m0'.get? a = m0.get? a) : LocalRel ι fp st m0' slot p lv := by
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    exact .priv a x hp hι (by rw [hg a hp]; exact hx) hlive haddr hpaddr hsize hpriv hbytes
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    exact .esc a x e y hp hι (by rw [hg a hp]; exact hx) hlive haddr hpaddr hsize hin hy hylive
      hyaddr hysize

/-- A related local's allocation exists. -/
theorem LocalRel.prov_lt {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory}
    {slot : LocalSlot} {p : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 slot p lv) :
    ∃ a, p.prov = some a ∧ a < m0.allocs.size := by
  cases hr with
  | priv a x hp _ hx =>
    exact ⟨a, hp, (Array.getElem?_eq_some_iff.mp (show m0.allocs[a]? = some x from hx)).1⟩
  | esc a x e y hp _ hx =>
    exact ⟨a, hp, (Array.getElem?_eq_some_iff.mp (show m0.allocs[a]? = some x from hx)).1⟩

/-- Deallocating leaves the other allocations. -/
theorem dealloc_get?_other {m m' : Memory} {p : ThinPointer} {k : AllocationKind} {n : Nat}
    {al : Align} (h : m.deallocate p k n al = .ok m') {c : AllocId} (hc : p.prov ≠ some c) :
    m'.get? c = m.get? c := by
  rcases p with ⟨addr, _ | id⟩
  · exact absurd h (by intro e; cases e)
  have hne : id ≠ c := fun e => hc (by rw [e])
  cases hg : m.get? id with
  | none =>
    exfalso
    simp only [Memory.deallocate, hg] at h
    all_goals exact absurd h (by intro e; cases e)
  | some a =>
    simp only [Memory.deallocate, hg] at h
    repeat' (split at h)
    all_goals first
      | (have e := (Except.ok.inj h).symm
         subst e
         simp [Memory.get?, Array.set!, hne])
      | exact absurd h (by intro e; cases e)

/-- Weakening the liveness. -/
theorem FnRel.weaken {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1)
    (hw : ∀ l, live' l = true → live l = true) : FnRel Γ ι live' f m0 s1 := by
  refine ⟨⟨hrel.frame.mem, ?_⟩, hrel.hidden, hrel.unaliased, hrel.provNe, hrel.apart, hrel.esc⟩
  intro l p hp hal
  obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l p hp hal
  exact ⟨slot, hsl, hr.weaken (hw l)⟩

/-- `StorageDead _l`: the L0 frame drops `_l` (if live) and its allocation; `FnRel` holds for
the new frame at any weaker liveness, with R unchanged. -/
theorem lift_storageDead {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} {s1 : R.RState}
    (hs : s.stack = f :: rest) (hrel : FnRel Γ ι live f s.mem s1) {l : Local}
    (hlive' : ∀ l', live' l' = true → live l' = true)
    (h : runOn (evalStatement (.storageDead l)) o s = (.ok (), s')) :
    ∃ f', s'.stack = f' :: rest ∧ f'.body = f.body ∧ f'.bb = f.bb ∧ f'.stmt = f.stmt ∧
      FnRel Γ ι live' f' s'.mem s1 := by
  have h' : runOn (storageDead l) o s = (.ok (), s') := h
  by_cases hl : ∃ p, f.locals[l]? = some (some p)
  · obtain ⟨p, hp⟩ := hl
    obtain ⟨ty, m', -, hd, rfl⟩ := storageDead_live hs hp (by rw [hrel.unaliased]; rfl) h'
    refine ⟨_, rfl, rfl, rfl, rfl, ?_⟩
    have hloc : ∀ (l' : Local) (p' : ThinPointer), (f.locals.set! l none)[l']? = some (some p') →
        f.locals[l']? = some (some p') ∧ l' ≠ l := by
      intro l' p' hp'
      by_cases e : l' = l
      · subst e
        exact absurd (getElem?_set!_self hp') (by simp)
      · exact ⟨by rw [← getElem?_set!_ne e]; exact hp', e⟩
    refine ⟨⟨hrel.frame.mem.dealloc_left hd, ?_⟩, ?_, ?_, ?_, ?_, hrel.esc⟩
    · intro l' p' hp' _
      obtain ⟨hp0, hne⟩ := hloc l' p' hp'
      obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l' p' hp0 (by rw [hrel.unaliased]; simp)
      refine ⟨slot, hsl, (hr.mem_congr fun a ha => dealloc_get?_other hd ?_).weaken (hlive' l')⟩
      rw [← ha]
      exact (hrel.provNe l' l p' p hne hp0 hp).symm
    · refine (hrel.hidden.dealloc hd).mono ?_
      rintro a ⟨l', p', hp', hpa, hι⟩
      exact ⟨l', p', (hloc l' p' hp').1, hpa, hι⟩
    · show f.aliased.erase l = []
      rw [hrel.unaliased]; rfl
    · intro l1 l2 p1 p2 hne h1 h2
      exact hrel.provNe l1 l2 p1 p2 hne (hloc l1 p1 h1).1 (hloc l2 p2 h2).1
    · intro l1 l2 p1 p2 sl1 sl2 hne h1 h2
      exact hrel.apart l1 l2 p1 p2 sl1 sl2 hne (hloc l1 p1 h1).1 (hloc l2 p2 h2).1
  · have hl' : ∀ p, f.locals[l]? ≠ some (some p) := fun p hp => hl ⟨p, hp⟩
    rw [storageDead_dead hs hl'] at h'
    obtain ⟨-, rfl⟩ := prod_ok_inj h'
    exact ⟨f, hs, rfl, rfl, rfl, hrel.weaken hlive'⟩

/-- `StorageLive _l` of a storage-dead local, private in R: given that L0's (daemonic) address
choice is `_l`'s slot, that the slot is disjoint from the other storage-live locals' (the
checker's storage conflicts), that no L0 byte carries the fresh allocation's provenance and
`ι` doesn't map it, `FnRel` holds for the new frame, with R unchanged. -/
theorem lift_storageLive {Γ : StmtCtx} {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} {s1 : R.RState}
    (hs : s.stack = f :: rest) (hrel : FnRel Γ ι live f s.mem s1) {l : Local}
    (hl : ∀ p, f.locals[l]? ≠ some (some p)) {sd : LocalSlot} (hsd : Γ.slots[l]? = some sd)
    (hsz : ∀ ty, f.body.locals[l]? = some ty → ty.size? = some sd.size)
    (hpick : ∀ ty (p : ThinPointer) m' s2, f.body.locals[l]? = some ty →
      runOn (s.mem.allocate .stack sd.size ty.align : SemM (ThinPointer × Memory)) o s =
        (.ok (p, m'), s2) → (p.addr : Int) = s1.fp + sd.off)
    (hpriv : ∀ k < sd.size, s1.st.escapedAt (sd.off + k) = none)
    (happ : ∀ l' (p' : ThinPointer) sl', l' ≠ l → f.locals[l']? = some (some p') →
      Γ.slots[l']? = some sl' → SlotsApart sd sl' ∧ SlotsApart sl' sd)
    (hfresh : Hidden s.mem (· = s.mem.allocs.size)) (hιn : ι s.mem.allocs.size = none)
    (hlive' : ∀ l', live' l' = true → l' = l ∨ live l' = true)
    (h : runOn (evalStatement (.storageLive l)) o s = (.ok (), s')) :
    ∃ f', s'.stack = f' :: rest ∧ f'.body = f.body ∧ f'.bb = f.bb ∧ f'.stmt = f.stmt ∧
      FnRel Γ ι live' f' s'.mem s1 := by
  have h' : runOn (storageLive l) o s = (.ok (), s') := h
  obtain ⟨ty, size, p, m', s2, hty, hsz', hal, hs2, rfl⟩ := storageLive_dead hs hl h'
  have hsize : size = sd.size := by
    rw [hsz ty hty] at hsz'
    exact (Option.some.inj hsz').symm
  subst hsize
  have hpaddr := hpick ty p m' s2 hty hal
  obtain ⟨a, hda, hadr, -, -, hlv, hpp, rfl, -, -⟩ := runOn_allocate_ok hal
  refine ⟨_, rfl, rfl, rfl, rfl, ?_⟩
  have hgetN : ({ allocs := s.mem.allocs.push a } : Memory).get? s.mem.allocs.size = some a := by
    simp [Memory.get?]
  have hgetlt : ∀ b, b < s.mem.allocs.size →
      ({ allocs := s.mem.allocs.push a } : Memory).get? b = s.mem.get? b := by
    intro b hb
    simp [Memory.get?, Array.getElem?_push, Nat.ne_of_lt hb]
  have hloc : ∀ (l' : Local) (p' : ThinPointer), (f.locals.set! l (some p))[l']? =
      some (some p') → (l' = l ∧ p' = p) ∨ (l' ≠ l ∧ f.locals[l']? = some (some p')) := by
    intro l' p' hp'
    by_cases e : l' = l
    · subst e
      exact .inl ⟨rfl, Option.some.inj (getElem?_set!_self hp')⟩
    · exact .inr ⟨e, by rw [← getElem?_set!_ne e]; exact hp'⟩
  -- old locals' allocations are below the fresh one
  have hold : ∀ (l' : Local) (p' : ThinPointer), f.locals[l']? = some (some p') → ∃ b, p'.prov = some b ∧
      b < s.mem.allocs.size := by
    intro l' p' hp'
    obtain ⟨slot, -, hr⟩ := hrel.frame.locals l' p' hp' (by rw [hrel.unaliased]; simp)
    exact hr.prov_lt
  refine ⟨⟨hrel.frame.mem.push_left a hιn, ?_⟩, ?_, hrel.unaliased, ?_, ?_, hrel.esc⟩
  · intro l' p' hp' _
    rcases hloc l' p' hp' with ⟨rfl, rfl⟩ | ⟨hne, hp0⟩
    · refine ⟨sd, hsd, .priv _ a hpp hιn hgetN hlv (by rw [hadr]; exact hpaddr) hadr.symm
        (by rw [hda]; simp) hpriv ?_⟩
      intro _ k hk
      have : a.data[k] = .uninit := by simp [hda]
      rw [this]
      trivial
    · obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l' p' hp0 (by rw [hrel.unaliased]; simp)
      obtain ⟨b, hb, hlt⟩ := hold l' p' hp0
      refine ⟨slot, hsl, (hr.mem_congr fun c hc => ?_).weaken ?_⟩
      · rw [hb] at hc
        cases hc
        exact hgetlt b hlt
      · intro h1
        rcases hlive' l' h1 with h1 | h1
        · exact absurd h1 hne
        · exact h1
  · intro b x hx hxl i hi fr hf hA
    obtain ⟨l', p', hp', hpa, hι⟩ := hA
    by_cases hbN : b = s.mem.allocs.size
    · subst hbN
      rw [hgetN] at hx
      cases hx
      have : a.data[i] = .uninit := by simp [hda]
      rw [this] at hf
      cases hf
    · have hblt : b < s.mem.allocs.size := by
        have := (Array.getElem?_eq_some_iff.mp (show (s.mem.allocs.push a)[b]? = some x from hx)).1
        simp at this
        exact Nat.lt_of_le_of_ne (Nat.le_of_lt_succ this) hbN
      rw [hgetlt b hblt] at hx
      rcases hloc l' p' hp' with ⟨rfl, rfl⟩ | ⟨-, hp0⟩
      · rw [hpp] at hpa
        exact hfresh b x hx hxl i hi fr hf (Option.some.inj hpa).symm
      · exact hrel.hidden b x hx hxl i hi fr hf ⟨l', p', hp0, hpa, hι⟩
  · intro l1 l2 p1 p2 hne h1 h2
    rcases hloc l1 p1 h1 with ⟨rfl, rfl⟩ | ⟨_, h1'⟩ <;>
      rcases hloc l2 p2 h2 with ⟨rfl, rfl⟩ | ⟨_, h2'⟩
    · exact absurd rfl hne
    · obtain ⟨b, hb, hlt⟩ := hold l2 p2 h2'
      rw [hpp, hb]
      intro e
      cases e
      exact absurd hlt (Nat.lt_irrefl _)
    · obtain ⟨b, hb, hlt⟩ := hold l1 p1 h1'
      rw [hpp, hb]
      intro e
      cases e
      exact absurd hlt (Nat.lt_irrefl _)
    · exact hrel.provNe l1 l2 p1 p2 hne h1' h2'
  · intro l1 l2 p1 p2 sl1 sl2 hne h1 h2 hs1 hs2
    rcases hloc l1 p1 h1 with ⟨rfl, rfl⟩ | ⟨_, h1'⟩ <;>
      rcases hloc l2 p2 h2 with ⟨rfl, rfl⟩ | ⟨_, h2'⟩
    · exact absurd rfl hne
    · rw [hsd] at hs1
      obtain rfl := Option.some.inj hs1
      exact (happ l2 p2 sl2 (Ne.symm hne) h2' hs2).1
    · rw [hsd] at hs2
      obtain rfl := Option.some.inj hs2
      exact (happ l1 p1 sl1 hne h1' hs1).2
    · exact hrel.apart l1 l2 p1 p2 sl1 sl2 hne h1' h2' hs1 hs2

end Ryo.Proofs.Lower
