/-
Ryo.Proofs.Lower.SimFnPtrCast — the simulation of `LowerFnPtrCast` (`Check/Lower/FnPtrCast.lean`,
M5b): a function's address (`addr.sym`) and the unsizing of a thin pointer to `dyn` (a `mov`
and the vtable's `addr.const`), into a whole local, private or escaped.

**The function invariant** (`SimPoolConst.lean`'s pool invariant for functions):
- `SymAt st a q`: R's symbol slot at `a` holds the pointer `q` (`addr.sym` loads 8 bytes at
  `a` and decodes them, `opSem_addrSym_fwd`). Unlike a pool constant's address, which is the
  placement `ρ (.const k)` itself, the function's address is in R's memory.
- `FnInv syms ρ ι s st`: for each instance `i` with symbol slot `n` (`syms i = some n`),
  `ρ (.sym n)` is some `a`, `SymAt st a q`, and L0's first copy of `i`'s address
  (`State.fnCopies`) is a `p` with `PoolPtrAt ι p q` (same address, `ι` maps `p`'s function
  allocation to `q`'s). Open: at the start (the image's symbol slots and M6's initial relation:
  every reified function has a first copy in L0, mapped by `ι`), and R's half of its
  preservation (`SymsKept`).
- `SymsKept c ch`: R's steps and scope applications keep the symbol slots (open, a hypothesis of
  `fn_simX`); L0's first copies are kept by every statement and non-call terminator
  (`GlobKept.fns`, `GlobKept.lean`). `FnInv.of_steps`, `FnInv.of_fold`, `FnInv.keep` carry
  `FnInv`.
- `FnReusesAt o`: the oracle answers every `.fnAddr i e` with `e > 0` by 0 (a daemonic choice,
  as `ReusesAt`); then `fnPointer i` takes the first copy (`fnPointer_reuse`, `FnInv.pick`).

**The lifts.** `lift_fnPtr` is `lift_poolPtr` with `addr.sym` (L0, `fnPtr_mem`: the operand
keeps the state, `PureOperand`, and the cast is `fnPointer i`, stored as `encodePtr p`).
`lift_unsizeVtable`: L0 (`unsizeVtable_mem`) loads `_a`'s 8 bytes `bs0` (a thin pointer `tp`),
takes the vtable's first copy `pv` (`globalPtr g`, `PoolInv.pick`) and stores `encodePtr tp ++
encodePtr pv`; R's `mov` copies `_a`'s 8 slot bytes `ba` (`readLocal_inj`, `BytesInj ι bs0 ba`,
so `encodePtr tp` below `bs0` relates to `ba`), `addr.const` writes `encodePtr q` after it, the two
writes are one (`writeFrame_append`) and `FnRel.write_dst` relates `_d`. The stored provenances
are `bs0`'s (loaded: not private, not unmapped) or `pv`'s (mapped), so `Hidden`, `ProvBounded`
and `DerefInv` (`DerefInv.store_notUnmapped`) hold; the lifts give `LiftOutXN`.
`stmt_simX_fnPtrCast` is `stmt_simX`'s case, given both invariants and both oracle conditions.
-/
import Ryo.Proofs.Lower.SimPoolConst
import Ryo.Proofs.Lower.SimAgg
import Ryo.Proofs.Lower.SimCopy
import Ryo.Check.Lower.FnPtrCast

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The invariant -/

/-- R's symbol slot at `a` holds the pointer `q` (see the module comment). -/
def SymAt (st : OpSem.State) (a q : ThinPointer) : Prop :=
  ∃ bs, st.load a 8 Target.PTR_ALIGN = .ok bs ∧ decodePtr bs = some q

/-- The function invariant (see the module comment). -/
def FnInv (syms : InstanceId → Option Nat) (ρ : R.Addrs) (ι : Inj) (s : Spec.State)
    (st : OpSem.State) : Prop :=
  ∀ i n, syms i = some n → ∃ a q p ps, ρ (.sym n) = some a ∧ SymAt st a q ∧
    s.fnCopies.getD i [] = p :: ps ∧ PoolPtrAt ι p q

/-- The simulation's answer to a function address choice: the first copy. -/
def FnReusesAt (o : Spec.Oracle) : Prop :=
  ∀ n i e s, 0 < e → o.answer n (.fnAddr i e) s = (0 : Nat)

/-- What the lift takes: `fnPointer i` returns a pointer `q` stands for, changing only the
choice count. -/
def FnPick (ι : Inj) (o : Spec.Oracle) (s : Spec.State) (i : InstanceId) (q : ThinPointer) :
    Prop :=
  ∃ p, runOn (fnPointer i) o s = (.ok p, { s with choiceCount := s.choiceCount + 1 }) ∧
    PoolPtrAt ι p q

theorem FnInv.keep {syms : InstanceId → Option Nat} {ρ : R.Addrs} {ι ι' : Inj}
    {s s' : Spec.State} {st st' : OpSem.State} (h : FnInv syms ρ ι s st) (hle : ι.Le ι')
    (hk : ∀ i p ps, s.fnCopies.getD i [] = p :: ps → ∃ ps', s'.fnCopies.getD i [] = p :: ps')
    (hR : ∀ a q, SymAt st a q → SymAt st' a q) : FnInv syms ρ ι' s' st' := by
  intro i n hn
  obtain ⟨a, q, p, ps, ha, hsym, hc, hpq⟩ := h i n hn
  obtain ⟨ps', hc'⟩ := hk i p ps hc
  exact ⟨a, q, p, ps', ha, hR a q hsym, hc', hpq.mono hle⟩

/-- R keeps every symbol slot's pointer across its steps and scope applications; `fn_simX`
takes it as a hypothesis. Open: a step (`R.step`'s `.step` outcomes; calls are `.ext`) changes
memory through its handler's `opSem` (a store into an immutable allocation fails,
`Provenance.store_immutable`, but every handler kind's memory effect would need the same),
through `writeFrame` into escaped objects (written in place) and through its scopes (`Escape`
allocates, `End` frees escaped objects); besides the per-kind lemma, a proof needs that no
escaped object's allocation is a symbol slot's (an invariant on `escaped`). -/
def SymsKept (c : R.Code) (ch : OpSem.Choice) : Prop :=
  (∀ s s', R.step c s ch = .ok (.step s') → ∀ a q, SymAt s.st a q → SymAt s'.st a q) ∧
  ∀ s sc s', R.applyScope s sc = .ok s' → ∀ a q, SymAt s.st a q → SymAt s'.st a q

theorem SymsKept.steps {c : R.Code} {ch : OpSem.Choice} (hk : SymsKept c ch) {s s' : R.RState}
    (h : StepsTo c ch s s') : ∀ a q, SymAt s.st a q → SymAt s'.st a q := by
  induction h with
  | refl => exact fun _ _ h => h
  | cons hs _ ih => exact fun a q h => ih a q (hk.1 _ _ hs a q h)

theorem SymsKept.fold {c : R.Code} {ch : OpSem.Choice} (hk : SymsKept c ch) :
    ∀ (scs : List R.Scope) (s s' : R.RState), scs.foldlM R.applyScope s = .ok s' →
      ∀ a q, SymAt s.st a q → SymAt s'.st a q
  | [], s, s', h, a, q, hs => by
    have e : s = s' := by
      simp only [List.foldlM_nil] at h
      first | exact Except.ok.inj h | (cases h; rfl)
    subst e
    exact hs
  | sc :: scs, s, s', h, a, q, hs => by
    simp only [List.foldlM_cons] at h
    cases hsc : R.applyScope s sc with
    | error e =>
      rw [hsc] at h
      first | cases h | simp [bind, Except.bind] at h
    | ok s2 =>
      rw [hsc] at h
      exact SymsKept.fold hk scs s2 s' h a q (hk.2 s sc s2 hsc a q hs)

/-- `FnInv` along R's steps (same L0 state). -/
theorem FnInv.of_steps {fs : InstanceId → Option Nat} {ρ : R.Addrs} {ι : Inj} {s : Spec.State}
    {c : R.Code} {ch : OpSem.Choice} {s1 s1' : R.RState} (h : FnInv fs ρ ι s s1.st)
    (hk : SymsKept c ch) (hst : StepsTo c ch s1 s1') : FnInv fs ρ ι s s1'.st :=
  h.keep (fun _ _ e => e) (fun _ p ps hc => ⟨ps, hc⟩) (hk.steps hst)

/-- `FnInv` along a scope fold (same L0 state). -/
theorem FnInv.of_fold {fs : InstanceId → Option Nat} {ρ : R.Addrs} {ι : Inj} {s : Spec.State}
    {c : R.Code} {ch : OpSem.Choice} {s1 s0 : R.RState} {scs : List R.Scope}
    (h : FnInv fs ρ ι s s1.st) (hk : SymsKept c ch) (hf : scs.foldlM R.applyScope s1 = .ok s0) :
    FnInv fs ρ ι s s0.st :=
  h.keep (fun _ _ e => e) (fun _ p ps hc => ⟨ps, hc⟩) (hk.fold scs s1 s0 hf)

/-! ### L0: the first copy of a function's address -/

/-- `fnPointer i` with a first copy and the answer 0: that copy, one choice counted.

Proof: as `globalPtr_reuse`: `fnPointer` reads the state, asks `.fnAddr i (ps.length + 1)`
(`runOn_choose`, answered 0) and returns entry 0. -/
theorem fnPointer_reuse {o : Spec.Oracle} {s : Spec.State} {i : InstanceId}
    {p : ThinPointer} {ps : List ThinPointer} (hc : s.fnCopies.getD i [] = p :: ps)
    (ho : ∀ e, 0 < e → o.answer s.choiceCount (.fnAddr i e) s = (0 : Nat)) :
    runOn (fnPointer i) o s = (.ok p, { s with choiceCount := s.choiceCount + 1 }) := by
  have hpos : 0 < (s.fnCopies.getD i []).length := by rw [hc]; simp
  have ho1 := ho _ hpos
  have ho2 : o.answer s.choiceCount (.fnAddr i (ps.length + 1)) s = (0 : Nat) :=
    ho _ (by omega)
  have ho3 : o.answer s.choiceCount (.fnAddr i (p :: ps).length) s = (0 : Nat) :=
    ho _ (by simp)
  have hc' : s.fnCopies[i]?.getD [] = p :: ps := by
    rw [← hc]
    first | simp | rfl | simp [Array.getD_eq_getD_getElem?]
  unfold fnPointer
  simp only [runOn_bind, runOn_get, runOn_choose, ho1, hc, hc', List.length_cons, ho2, ho3,
    List.getElem?_cons_zero, runOn_pure]
  all_goals (try rw [runOn_choose])
  all_goals (try simp only [ho1, ho2, ho3, List.getElem?_cons_zero, runOn_pure])
  all_goals (try rfl)

/-- `FnInv` and `FnReusesAt` give a function's `FnPick` at its symbol slot. -/
theorem FnInv.pick {syms : InstanceId → Option Nat} {ρ : R.Addrs} {ι : Inj} {s : Spec.State}
    {st : OpSem.State} {o : Spec.Oracle} (h : FnInv syms ρ ι s st) (hre : FnReusesAt o)
    {i : InstanceId} {n : Nat} (hn : syms i = some n) :
    ∃ a q, ρ (.sym n) = some a ∧ SymAt st a q ∧ FnPick ι o s i q := by
  obtain ⟨a, q, p, ps, ha, hsym, hc, hpq⟩ := h i n hn
  exact ⟨a, q, ha, hsym, p, fnPointer_reuse hc (fun e he => hre _ _ _ _ he), hpq⟩

/-! ### L0: the statements -/

/-- A `PureOperand` evaluates without changing the state. -/
theorem pureOperand_state {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {oa : Operand} (hoa : PureOperand oa)
    {r : Value × Spec.Ty} (h : runOn (evalOperand oa) o s = (.ok r, s1)) : s1 = s := by
  cases hoa with
  | copy a =>
    obtain ⟨_, _, _, _, _, _, _, hs1⟩ := runOn_evalOperand_copy hs h
    exact hs1
  | move a =>
    rw [evalOperand_move] at h
    obtain ⟨_, _, _, _, _, _, _, hs1⟩ := runOn_evalOperand_copy hs h
    exact hs1
  | zst t =>
    exact (runOn_evalOperand_const_dec (bytes := []) h rfl).2.2

/-- A fn coercion is `fnPointer i`, widened. -/
theorem evalCast_fn_eq {k : CastKind} {i : InstanceId} (hk : fnCoercion k = some i) (v : Value)
    (t ty : Spec.Ty) :
    evalCast k (v, t) ty = (fnPointer i >>= fun p => pure (Value.ptr p.widen)) := by
  cases k
  all_goals try (simp [fnCoercion] at hk; done)
  rename_i c
  cases c
  all_goals try (simp [fnCoercion] at hk; done)
  all_goals
    simp only [fnCoercion, Option.some.injEq] at hk
    subst hk
    first | rfl | simp [evalCast]

/-- `_d = cast k oa (.ptr pt valid)` for a fn coercion, with `fnPointer i` picking `p`: one store
of `encodePtr p` into `_d`.

Proof: `assign_cast_inv`; the operand keeps the state (`pureOperand_state`); the cast is
`fnPointer i` (`evalCast_fn_eq`, `hfp`) widened, whose encoding at the thin pointer type is
`encodePtr p` (`typedStore_inv`, `Spec.Ty.encode`). -/
theorem fnPtr_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {k : CastKind}
    {i : InstanceId} (hk : fnCoercion k = some i) {oa : Operand} (hoa : PureOperand oa)
    {pt : PtrType} {valid : ValidRange} (htd : f.body.locals[d]? = some (.ptr pt valid))
    (hmk : pt.metaKind = .none) {p : ThinPointer}
    (hfp : runOn (fnPointer i) o s = (.ok p, { s with choiceCount := s.choiceCount + 1 }))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k oa (.ptr pt valid)))) o s =
      (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧ s.mem.store pd (encodePtr p) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  have hs1 : s1 = s := pureOperand_state hs hoa hev
  subst hs1
  have e4 : td = .ptr pt valid := Option.some.inj (htd'.symm.trans htd)
  subst e4
  obtain ⟨rv, rt⟩ := r
  rw [evalCast_fn_eq hk] at hca
  obtain ⟨p', s4, h5, h6⟩ := runOn_bind_ok hca
  rw [hfp] at h5
  obtain ⟨e7, e8⟩ := prod_ok_inj h5
  subst e8
  rw [← e7] at h6
  obtain ⟨hw, hs2⟩ := runOn_pure_inv h6
  subst hw
  subst hs2
  obtain ⟨bs, hen, hsto⟩ := typedStore_inv hst
  have hbs : bs = encodePtr p := by
    simp [Spec.Ty.encode, hmk, ThinPointer.widen] at hen
    first | exact hen.symm | exact hen
  subst hbs
  subst hs'
  exact ⟨pd, hpd, hsto, rfl⟩

/-- `unsizeValue` of a pointer to a vtable: `globalPtr g` attached. -/
theorem unsizeValue_vtable_ptr (g : GlobalId) (fuel : Nat) (p : Pointer) (pa pd : PtrType)
    (va vd : ValidRange) :
    unsizeValue (.vtable g) (fuel + 1) (.ptr p) (.ptr pa va) (.ptr pd vd) =
      (globalPtr g >>= fun vt => pure (Value.ptr ⟨p.thin, some (.vtablePointer vt)⟩)) := by
  first
    | rfl
    | (rw [unsizeValue]; rfl)
    | simp [unsizeValue]

theorem evalCast_unsizeVtable_eq (g : GlobalId) (tp : ThinPointer) (pta ptd : PtrType)
    (va vd : ValidRange) :
    evalCast (.pointerCoercion (.unsize (.vtable g))) (Value.ptr ⟨tp, none⟩, Spec.Ty.ptr pta va)
      (.ptr ptd vd) =
      (globalPtr g >>= fun vt => pure (Value.ptr ⟨tp, some (.vtablePointer vt)⟩)) := by
  have e : evalCast (.pointerCoercion (.unsize (.vtable g))) (Value.ptr ⟨tp, none⟩,
      Spec.Ty.ptr pta va) (.ptr ptd vd) =
      unsizeValue (.vtable g) 64 (.ptr ⟨tp, none⟩) (.ptr pta va) (.ptr ptd vd) := by
    first | rfl | simp [evalCast]
  rw [e]
  exact unsizeValue_vtable_ptr g 63 ⟨tp, none⟩ pta ptd va vd

/-- `_d = cast (unsize (vtable g)) _a (.ptr ptd vd)`, with `globalPtr g` picking `pv`: `_a`'s 8
bytes `bs0` decode to `tp`, and the store into `_d` is `encodePtr tp ++ encodePtr pv`.

Proof: as `unsizeLen_mem`, with `evalCast_unsizeVtable_eq` and `hgp` for the cast (its state
`{ s with choiceCount := … }`, same memory and stack). -/
theorem unsizeVtable_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    {g : GlobalId} {ptd pta : PtrType} {vd va : ValidRange} {t : TraitName}
    (ha : oa.local? = some a) (hkd : ptd.metaKind = .vtablePointer t)
    (hka : pta.metaKind = .none)
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hta : f.body.locals[a]? = some (.ptr pta va))
    {pv : ThinPointer}
    (hgp : runOn (globalPtr g) o s = (.ok pv, { s with choiceCount := s.choiceCount + 1 }))
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.cast (.pointerCoercion (.unsize (.vtable g))) oa (.ptr ptd vd)))) o s = (.ok (), s')) :
    ∃ pd pa bs0 tp, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load pa 8 .one = .ok bs0 ∧ bs0.length = 8 ∧ decodePtr bs0 = some tp ∧
      s.mem.store pd (encodePtr tp ++ encodePtr pv) .one = .ok s'.mem ∧ s'.stack = s.stack := by
  rw [eval_cast_norm ha] at h
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  obtain ⟨pa, ta', v0, hpa, hta', hla, hr, hs1⟩ := runOn_evalOperand_copy hs hev
  subst r
  subst s1
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = .ptr pta va := Option.some.inj (hta'.symm.trans hta)
  rw [e4] at hst
  rw [e5] at hla hca
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv (size?_ptr_thin hka) hla
  obtain ⟨tp, hlen0, hdp, hv⟩ := decode_ptr_thin_inv hka hd0
  subst v0
  rw [evalCast_unsizeVtable_eq] at hca
  obtain ⟨pv', s4, h5, h6⟩ := runOn_bind_ok hca
  rw [hgp] at h5
  obtain ⟨e7, e8⟩ := prod_ok_inj h5
  subst e8
  rw [← e7] at h6
  obtain ⟨hw, hs2⟩ := runOn_pure_inv h6
  subst hw
  subst hs2
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have he' : bsd = encodePtr tp ++ encodePtr pv := by
    simp [Spec.Ty.encode, hkd] at hen
    first | exact hen.symm | exact hen
  subst he'
  subst hs'
  exact ⟨pd, pa, bs0, tp, hpd, hpa, hlo, hlen0, hdp, hsto, rfl⟩

/-! ### R: `addr.sym` -/

/-- `addr.sym`'s footprint (`footprintOf`): `d`'s 8 bytes written, the symbol slot read. -/
abbrev addrSymFp : Footprint :=
  { writes := [Ryo.Proofs.Inline.rdA "d" 8],
    derefs := [⟨.addr "sym", .bytes 8, .read, true⟩] }

/-- The forward direction of `addr.sym` (as `opSem_addrConst_fwd`): it loads the symbol slot's 8
bytes (`SymAt`) and writes their pointer's encoding to `d`. -/
theorem opSem_addrSym_fwd {op : Full.Opcode} {r : Option String}
    {d : Int} {a q : ThinPointer} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.addr_sym, ["false"], r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"sym", .sym⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31) (hsym : SymAt st a q)
    (hw : st.writeFrame d (encodePtr q) = .ok st') :
    opSem op [.slot d, .addr a] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2⟩ := hfits
  obtain ⟨bs, hld, hdec⟩ := hsym
  have hfd := slot_fits hd1 hd2
  have hfa : Val.fits .sym (.addr a) = true := rfl
  have hfp : footprint op = some addrSymFp := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    first
      | rfl
      | (simp [footprintOf, addrSymFp]; done)
      | (simp [footprintOf, addrSymFp]; decide)
  have hprep : prepare op [.slot d, .addr a] =
      .ok (⟨.addr_sym, ["false"], r⟩, addrSymFp, opndVal op.info [.slot d, .addr a]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa])]
    rfl
  have hva : opndVal op.info [.slot d, .addr a] "sym" = some (.addr a) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .addr a] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll addrSymFp
      (opndVal op.info [.slot d, .addr a]) st = .ok [] := rfl
  -- the kind reads memory only: the frame-less state loads what `st` does
  have hld' : ({ st with frame := fun _ => .uninit } : OpSem.State).load a 8 Target.PTR_ALIGN =
      .ok bs := hld
  have hap : asPtr bs = .ok q := by unfold asPtr; rw [hdec]; rfl
  have hne : ((some "false" : Option String) == some "true") = false := by
    first | rfl | decide | simp
  have hk : kindSem .addr_sym ["false"] (mkEnv [] (opndVal op.info [.slot d, .addr a]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", encodePtr q)] } := by
    simp [kindSem, mkEnv, out, Env.addr, hva, hld', hap, hne, bind, Except.bind, pure,
      Except.pure]
  have hc : commit addrSymFp
      (opndVal op.info [.slot d, .addr a]) st [("d", encodePtr q)] = .ok st' := by
    simp only [commit, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, addrSymFp, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff,
      Extent.eval, Ryo.Spec.Theorems.encodePtr_length, hw, bind, Except.bind, pure, Except.pure,
      Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-! ### The lifts -/

/-- `DerefInv` after a store of bytes none of whose provenances is unmapped
(`DerefInv.store_mapped`'s proof with the weaker hypothesis). -/
theorem DerefInv.store_notUnmapped {ι : Inj} {m m' : Memory} {p : ThinPointer}
    {bs : List AbstractByte} {al : Align} (h : DerefInv ι m) (hsto : m.store p bs al = .ok m')
    (hbs : ∀ b ∈ bs, ∀ fr, b.provFrag = some fr → ¬ Unmapped ι m fr.prov) : DerefInv ι m' := by
  obtain ⟨hmap, hld, hbl⟩ := h
  have hf : ∀ a x', m'.get? a = some x' → ∃ x, m.get? a = some x ∧ x.addr = x'.addr ∧
      (x'.live = true → x.live = true) ∧ x.data.size = x'.data.size := fun a x' hx' => by
    obtain ⟨x, hx, e1, el, es⟩ := store_get?_fwd hsto hx'
    exact ⟨x, hx, e1, fun h => el.trans h, es⟩
  have hU : ∀ a, Unmapped ι m' a → Unmapped ι m a := by
    rintro a ⟨hι, x', hx', hl', hp'⟩
    obtain ⟨x, hx, -, el, es⟩ := hf a x' hx'
    exact ⟨hι, x, hx, el hl', by omega⟩
  refine ⟨(hmap.mono hU).store_hidden hsto (fun b hb fr hfr hu => hbs b hb fr hfr (hU _ hu)), ?_,
    hbl.of_kept hf⟩
  intro i j a b x hi hj hla hlb h1 h2 h3 h4
  obtain ⟨a0, ha0, ea, el, es⟩ := hf i a hi
  obtain ⟨b0, hb0, eb, el', es'⟩ := hf j b hj
  simp only [Allocation.size] at h2 h4
  exact hld i j a0 b0 x ha0 hb0 (el hla) (el' hlb) (by omega)
    (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)

/-- `fnPtr`'s facts, by name. -/
theorem fnPtr_inv {Γ : StmtCtx} {d : Local} {k : CastKind}
    {i : InstanceId} {oa : Operand} {ty : Spec.Ty} {is : List R.Insn}
    (h : LowerFnPtrCast Γ (.assign ⟨d, []⟩ (.cast k oa ty)) is) (hk : fnCoercion k = some i) :
    ∃ n pt valid sd ins, is = [ins] ∧ ty = .ptr pt valid ∧ PureOperand oa ∧ Γ.fnSymAt i = some n ∧
      Γ.body.locals[d]? = some (.ptr pt valid) ∧ pt.metaKind = .none ∧ Γ.slots[d]? = some sd ∧
      sd.size = 8 ∧ offOk sd.off = true ∧ addrSymInsnOk ins sd.off n = true := by
  cases h with
  | fnPtr hk' hoa hn htd hmk hsd hsize hoff hi =>
    rw [hk] at hk'
    cases hk'
    exact ⟨_, _, _, _, _, rfl, rfl, hoa, hn, htd, hmk, hsd, hsize, hoff, hi⟩
  | vtable => simp [fnCoercion] at hk

/-- `vtable`'s facts, by name. -/
theorem vtable_inv {Γ : StmtCtx} {d : Local} {oa : Operand}
    {g : GlobalId} {ptd : PtrType} {vd : ValidRange} {is : List R.Insn}
    (h : LowerFnPtrCast Γ
      (.assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.vtable g))) oa (.ptr ptd vd))) is) :
    ∃ a kc pta t va sd sa i1 i2, is = [i1, i2] ∧ oa.local? = some a ∧ Γ.poolAt g = some kc ∧
      Γ.body.locals[d]? = some (.ptr ptd vd) ∧ ptd.metaKind = .vtablePointer t ∧
      Γ.body.locals[a]? = some (.ptr pta va) ∧ pta.metaKind = .none ∧
      Γ.slots[d]? = some sd ∧ Γ.slots[a]? = some sa ∧ (sd.size = 16 ∧ sa.size = 8) ∧
      (offOk sd.off = true ∧ offOk (sd.off + 8) = true ∧ offOk sa.off = true) ∧
      movInsnOk Γ i1 8 sd.off sa.off = true ∧ addrConstInsnOk i2 (sd.off + 8) kc = true := by
  cases h with
  | fnPtr hk => simp [fnCoercion] at hk
  | vtable ha hkg htd hkd hta hka hsd hsa hsize hoff hi1 hi2 =>
    exact ⟨_, _, _, _, _, _, _, _, _, rfl, ha, hkg, htd, hkd, hta, hka, hsd, hsa, hsize, hoff,
      hi1, hi2⟩

/-- `fnPtr`'s lift: from `FnRelX` at the fold `s0` of the scopes at `pc`, `addr.sym` into `_d`
(`lift_poolPtr`'s proof with `FnInv.pick` and `opSem_addrSym_fwd`). -/
theorem lift_fnPtr {Γ : StmtCtx} {c : R.Code}
    {s1 s0 : R.RState} {ch : OpSem.Choice} {ι : Inj} {live live' : Local → Bool}
    {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {k : CastKind} {i : InstanceId} {oa : Operand} {ty : Spec.Ty} {ins : R.Insn}
    (hlow : LowerFnPtrCast Γ (.assign ⟨d, []⟩ (.cast k oa ty)) [ins])
    (hk : fnCoercion k = some i)
    (hi : c.d.insns[s1.pc]? = some ins)
    (hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ ins)
    (hX : FnRelX Γ ι live f s.mem s0) (hpb : ProvBounded s.mem)
    (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hfinv : FnInv Γ.fnSymAt c.ρ ι s s0.st) (hre : FnReusesAt o)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k oa ty))) o s = (.ok (), s')) :
    LiftOutXN Γ c ch ι live' f s s' s1 s0 1 := by
  obtain ⟨n, pt, valid, sd, ins', his, hty, hoa, hn, htdΓ, hmk, hsd, hsize, hoff, hiok⟩ :=
    fnPtr_inv hlow hk
  injection his with e1 e1'
  subst e1
  subst hty
  obtain ⟨a, q, ha, hsym, p, hrun, hpq⟩ := hfinv.pick hre hn
  obtain ⟨op, sl, fo, rfl, hfull, ⟨r, hh⟩, ho, hsh, hsl⟩ := addrSymInsnOk_spec hiok
  have hv := view_addrSym (mode := c.mode) (s := sl) hfull ho hsh ha
  rw [hsl] at hv
  have htd : f.body.locals[d]? = some (.ptr pt valid) := by rw [← hbody]; exact htdΓ
  obtain ⟨pd, hpd, hsto, hstk⟩ := fnPtr_mem hs hk hoa htd hmk hrun h
  have hpi := hpq.ptrInj
  obtain ⟨-, -, a', b, hpa, -, hιa⟩ := hpq
  have hpos : 0 < sd.size := by omega
  obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hX.rel.write_dst hdi.ld hpd hsd hpos
    (encodePtr_inj hpi) (by rw [Ryo.Spec.Theorems.encodePtr_length, hsize]) hsto
  have hf1 := offOk_spec hoff
  have hop := opSem_addrSym_fwd (ch := ch) hh ho ⟨hf1.1, hf1.2⟩ hsym hwr
  have hstep := step_of_view_scopes hi hfold hpe hpl hv rfl hop
  have hbprov : ∀ x ∈ encodePtr p, ∀ fr, x.provFrag = some fr → fr.prov = a' :=
    fun x hx fr hf => Option.some.inj ((encodePtr_prov hx hf).symm.trans hpa)
  obtain ⟨hnp, hbd, hmap⟩ := stored_prov (f := f) hbprov hιa hfresh
  have hhid : Hidden s'.mem (PrivAlloc ι f) := hX.rel.hidden.store_hidden hsto hnp
  have hfn := hX.rel.after hpd hsd hmi hrd hoth hhid hesc hlive' (pc' := s0.pc + 1)
  refine ⟨ι, st', fun _ _ e => e, fun _ _ => rfl, .cons hstep (.refl _), hstk, ?_,
    hpb.store hsto hbd, Nat.le_of_eq (store_size hsto).symm, hdi.store_mapped hsto hmap⟩
  exact hX.keep hfn hesc rfl (writeFrame_allocsKept hwr) (store_agree_live hsto)

/-- `vtable`'s lift: `mov` of `_a`'s 8 bytes into `_d`'s first 8, then the vtable's
`addr.const` into the last 8 (see the module comment). -/
theorem lift_unsizeVtable {Γ : StmtCtx} {c : R.Code}
    {s1 s0 : R.RState} {ch : OpSem.Choice} {ι : Inj} {live live' : Local → Bool}
    {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {oa : Operand} {g : GlobalId} {ptd : PtrType} {vd : ValidRange}
    {i1 i2 : R.Insn}
    (hlow : LowerFnPtrCast Γ
      (.assign ⟨d, []⟩ (.cast (.pointerCoercion (.unsize (.vtable g))) oa (.ptr ptd vd)))
      [i1, i2])
    (hi1 : c.d.insns[s1.pc]? = some i1) (hi2 : c.d.insns[s0.pc + 1]? = some i2)
    (hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hsc2 : c.scopesAt (s0.pc + 1) = [])
    (hpe : c.mode.pe = false) (hpl1 : PlainView c.mode c.ρ i1) (hpl2 : PlainView c.mode c.ρ i2)
    (hX : FnRelX Γ ι live f s.mem s0) (hpb : ProvBounded s.mem)
    (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hpool : PoolInv Γ.poolAt c.ρ ι s) (hre : ReusesAt o)
    (hlo : ∀ l ∈ operandLocals oa, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.cast (.pointerCoercion (.unsize (.vtable g))) oa (.ptr ptd vd)))) o s = (.ok (), s')) :
    LiftOutXN Γ c ch ι live' f s s' s1 s0 2 := by
  obtain ⟨a, kc, pta, t, va, sd, sa, i1', i2', his, ha, hkg, htdΓ, hkd, htaΓ, hka, hsd, hsa,
    hsize, hoff, hmi1, hmi2⟩ := vtable_inv hlow
  injection his with e1 e2
  injection e2 with e2 e2'
  subst e1
  subst e2
  obtain ⟨hsz16, hsa8⟩ := hsize
  obtain ⟨q, hq, pv, hrun, hpq⟩ := hpool.pick hre hkg
  have htd : f.body.locals[d]? = some (.ptr ptd vd) := by rw [← hbody]; exact htdΓ
  have hta : f.body.locals[a]? = some (.ptr pta va) := by rw [← hbody]; exact htaΓ
  obtain ⟨pd, pa, bs0, tp, hpd, hpa, hlo0, hlen0, hdp, hsto, hstk⟩ :=
    unsizeVtable_mem hs ha hkd hka htd hta hrun h
  have hpi := hpq.ptrInj
  obtain ⟨-, -, av, bv, hpav, -, hιav⟩ := hpq
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2.1
  have hf3 := offOk_spec hoff.2.2
  -- R reads `_a`'s 8 bytes, which relate to `bs0`, hence to `encodePtr tp`
  have hla : live a = true := hlo a (operand_local_mem ha)
  have hra := hX.rel.opnd hpa hsa hla
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj (al := .one) (bs0 := bs0) hX.rel.frame.mem hra
    (by rw [hsa8]; exact hlo0)
  rw [hsa8] at hrfa
  have hle0 := ptr_reenc_le hlen0 hdp
  have hbt : BytesInj ι (encodePtr tp) ba := BytesInj.of_le hle0 hia
  have hlenb : ba.length = 8 := by
    have := BytesInj.length hbt
    rw [Ryo.Spec.Theorems.encodePtr_length] at this
    omega
  -- R may write `_d`'s slot: its escaped bytes have allocations
  have hok : ∀ k : Nat, k < 16 → ∀ e, s0.st.escapedAt (sd.off + k) = some e →
      e.id < s0.st.mem.allocs.size := by
    intro k hk e he
    obtain ⟨sd', hsd', hrd⟩ := hX.rel.frame.locals d pd hpd (by rw [hX.rel.unaliased]; simp)
    rw [hsd] at hsd'
    obtain rfl := Option.some.inj hsd'
    cases hrd with
    | priv a' x hp hι hx hlive haddr hpaddr hsz hpriv _ =>
      rw [hpriv k (by omega)] at he
      cases he
    | esc a' x e' y hp hι hx hlive haddr hpaddr hsz hin hy =>
      rw [hin k (by omega)] at he
      cases he
      unfold Memory.get? at hy
      exact (Array.getElem?_eq_some_iff.mp hy).1
  -- step 1: `mov d, a`
  obtain ⟨v1, ty1, r1, hv1, hh1, hty1, ho1, hops1, hctl1⟩ := movInsnOk_spec hmi1
  rw [hmode, hρ] at hv1
  obtain ⟨sg1, hty1'⟩ := intTyOk_spec hty1
  obtain ⟨st1, hw1⟩ := writeFrame_ok_of (st := s0.st) (off := sd.off) (bs := ba)
    (fun k hk e he => hok k (by rw [hlenb] at hk; omega) e he)
  have hop1 := opSem_mov_fwd (ch := ch) hh1 hty1' ho1 ⟨hf1.1, hf1.2, hf3.1, hf3.2⟩ hrfa hlenb hw1
  have hstep1 := step_of_view_scopes hi1 hfold hpe hpl1 hv1 hctl1 (by rw [hops1]; exact hop1)
  obtain ⟨hef1, hesc1, -⟩ := writeFrame_split hw1
  -- step 2: `addr.const d + 8, k`
  obtain ⟨op2, sl2, fo2, rfl, hfull2, ⟨ps2, r2, hh2⟩, ho2, hsh2, hsl2⟩ :=
    addrConstInsnOk_spec hmi2
  have hv2 := view_addrConst (mode := c.mode) (s := sl2) hfull2 ho2 hsh2 hq
  rw [hsl2] at hv2
  have hlen8 : (encodePtr q).length = 8 := Ryo.Spec.Theorems.encodePtr_length _
  have hok2 : ∀ k < (encodePtr q).length, ∀ e, st1.escapedAt (sd.off + 8 + k) = some e →
      e.id < st1.mem.allocs.size := by
    intro k hk e he
    rw [escapedAt_congr hesc1] at he
    rw [hef1.1]
    exact hok (8 + k) (by rw [hlen8] at hk; omega) e
      (by rw [show sd.off + ((8 + k : Nat) : Int) = sd.off + 8 + k by push_cast; omega]
          exact he)
  obtain ⟨st2, hw2⟩ := writeFrame_ok_of hok2
  have hop2 := opSem_addrConst_fwd (ch := ch) hh2 ho2 ⟨hf2.1, hf2.2⟩ hw2
  have hstep2 := step_of_view (s1 := { s0 with pc := s0.pc + 1, st := st1 }) hi2 hsc2 hpe
    hpl2 hv2 rfl hop2
  -- the two writes are one: `FnRel.write_dst`
  have hw12 : s0.st.writeFrame sd.off (ba ++ encodePtr q) = .ok st2 :=
    writeFrame_append hw1 (by rw [hlenb]; exact hw2)
  have hinj : BytesInj ι (encodePtr tp ++ encodePtr pv) (ba ++ encodePtr q) :=
    hbt.append (encodePtr_inj hpi)
  have hpos : 0 < sd.size := by omega
  obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hX.rel.write_dst hdi.ld hpd hsd hpos hinj
    (by rw [List.length_append, Ryo.Spec.Theorems.encodePtr_length,
      Ryo.Spec.Theorems.encodePtr_length, hsz16]) hsto
  rw [hw12] at hwr
  obtain rfl : st2 = st' := Except.ok.inj hwr
  -- the stored provenances: `bs0`'s (loaded) or `pv`'s (mapped)
  have hsub := le_prov hle0
  have hhidA := hX.rel.hidden.load hlo0
  have hbdA := hpb.load hlo0
  have hunA := hdi.hid.load hlo0
  obtain ⟨hnpV, hbdV, hmapV⟩ := stored_prov (f := f) (bs := encodePtr pv)
    (fun x hx fr hf => Option.some.inj ((encodePtr_prov hx hf).symm.trans hpav)) hιav hfresh
  have hnp : ∀ b ∈ encodePtr tp ++ encodePtr pv, ∀ fr, b.provFrag = some fr →
      ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    rcases List.mem_append.mp hb with hb | hb
    · obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hhidA _ (List.getElem_mem hj) fr0 hf0
    · exact hnpV b hb fr hfr
  have hbd : BytesBounded s.mem.allocs.size (encodePtr tp ++ encodePtr pv) := by
    intro b hb fr hfr
    rcases List.mem_append.mp hb with hb | hb
    · obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hbdA _ (List.getElem_mem hj) fr0 hf0
    · exact hbdV b hb fr hfr
  have hun : ∀ b ∈ encodePtr tp ++ encodePtr pv, ∀ fr, b.provFrag = some fr →
      ¬ Unmapped ι s.mem fr.prov := by
    intro b hb fr hfr
    rcases List.mem_append.mp hb with hb | hb
    · obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
      rw [← he0]
      exact hunA _ (List.getElem_mem hj) fr0 hf0
    · intro hu
      exact hmapV b hb fr hfr hu.1
  have hhid : Hidden s'.mem (PrivAlloc ι f) := hX.rel.hidden.store_hidden hsto hnp
  have hfn := hX.rel.after hpd hsd hmi hrd hoth hhid hesc hlive' (pc' := s0.pc + 2)
  refine ⟨ι, st2, fun _ _ e => e, fun _ _ => rfl, .cons hstep1 (.cons hstep2 (.refl _)), hstk,
    ?_, hpb.store hsto hbd, Nat.le_of_eq (store_size hsto).symm, hdi.store_notUnmapped hsto hun⟩
  exact hX.keep hfn hesc rfl (writeFrame_allocsKept hw12) (store_agree_live hsto)

/-! ### One statement with scopes -/

/-- The family's statements have no own scope. -/
theorem ownSpec_fnPtrCast {Γ : StmtCtx} {st : Statement}
    {is : List R.Insn} (h : LowerFnPtrCast Γ st is) : ownSpec Γ st = [] := by
  cases h <;> simp [ownSpec, refPlace?]

/-- `LowerFnPtrCast` under pending scopes: `stmt_simX`'s case, given the pool and function
invariants and both copy choices (see the module comment; the proof is
`stmt_simX_poolConst`'s). -/
theorem stmt_simX_fnPtrCast {Γ : TermCtx} {c : R.Code}
    {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    (hpool : PoolInv Γ.poolAt c.ρ ι s) (hre : ReusesAt o)
    (hfinv : FnInv Γ.fnSymAt c.ρ ι s s0.st) (hfre : FnReusesAt o)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hlow : LowerFnPtrCast Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have hown := ownSpec_fnPtrCast hlow
  have hlen := rangeInsns_length (r := r) h2
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hlt : r.1 < r.2 := by
    have : 0 < (rangeInsns c.d r).length := by
      have hl0 := hlow
      generalize rangeInsns c.d r = is at hl0 ⊢
      cases hl0 <;> simp
    omega
  -- the scopes at `pc` are the pending ones (no own scope): their fold is `s0`
  have hsc := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmt f.stmt st r hst hr hlt
  rw [hown, List.append_nil] at hsc
  have hlenS := specsOk_length _ _ hsc
  have hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0 := by
    have hp := M.pend
    have ht : (c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk f.stmt).length =
        c.scopesAt s1.pc := by
      apply List.take_of_length_le
      have hl' : (c.scopesAt s1.pc).length = (pendSpecs Γ.toStmtCtx bd blk f.stmt).length := by
        rw [hpc0]
        exact hlenS
      omega
    rw [ht] at hp
    exact hp
  have hpcs : s0.pc = s1.pc := scopes_pc hfold
  have hsx := hfn.stmtsX f.bb bd blk M.hbd M.hblk
  have hpend0 := hsx.pend0 f.stmt r hr hlt
  have hpcNext : r.2 = pcAt blk (f.stmt + 1) := hnext.trans (nextStart_eq blk f.stmt)
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hlow0 := hlow
  generalize hR : rangeInsns c.d r = is at hlow0
  cases hlow0 with
  | @fnPtr d k i oa n pt valid sd ins hk hoa hn htd hmk hsd hsize hoff hiok =>
    rw [hR] at hlow
    obtain ⟨hl1, -⟩ := assign_live hfn.live M.hbd hst
    obtain ⟨hc0', he⟩ := rangeInsns_single h2 hR
    have hc0 : c.d.insns[s1.pc]? = some ins := by rw [hpc0]; exact hc0'
    have hpl0 : PlainView c.mode c.ρ ins := by rw [hmode, hρ]; exact hfn.plain _ _ hc0
    refine stmtOutX_of_liftXN (k := 1) M.stack hfn.storage M.hbd hst M.sl M.fresh
      (by rw [hpcs, hpc0, ← hpcNext, he]) hpend0 ?_
    exact lift_fnPtr M.stack M.body.symm hlow hk hc0 hfold hpe hpl0 M.rel M.pb M.fresh M.dinv
      hfinv hfre hl1 hev
  | @vtable d a oa g kc ptd pta t vd va sd sa i1 i2 ha hkg htd hkd hta hka hsd hsa hsize hoff
      hiok1 hiok2 =>
    rw [hR] at hlow
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    have hl2' := hlen
    rw [hR] at hl2'
    simp only [List.length_cons, List.length_nil] at hl2'
    have hat := rangeInsns_at (r := r) h2
    have hget : ∀ j, j < 2 → c.d.insns[r.1 + j]? = [i1, i2][j]? := by
      intro j hj
      have hj' : j < (rangeInsns c.d r).length := by rw [hR]; simpa using hj
      rw [hat j hj', ← List.getElem?_eq_getElem hj', hR]
    have hc0 : c.d.insns[s1.pc]? = some i1 := by
      rw [hpc0]; simpa using hget 0 (by decide)
    have hc1 : c.d.insns[s0.pc + 1]? = some i2 := by
      rw [hpcs, hpc0]; simpa using hget 1 (by decide)
    have hin := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmtInner f.stmt r hr
    have hsc2 : c.scopesAt (s0.pc + 1) = [] := by
      have := hin (r.1 + 1) (by omega) (by omega)
      rw [hpcs, hpc0]; exact this
    have hpl0 : PlainView c.mode c.ρ i1 := by rw [hmode, hρ]; exact hfn.plain _ _ hc0
    have hpl1 : PlainView c.mode c.ρ i2 := by rw [hmode, hρ]; exact hfn.plain _ _ hc1
    refine stmtOutX_of_liftXN (k := 2) M.stack hfn.storage M.hbd hst M.sl M.fresh
      (by rw [hpcs, hpc0, ← hpcNext]; omega) hpend0 ?_
    exact lift_unsizeVtable M.stack M.body.symm hmode.symm hρ.symm hlow hc0 hc1 hfold hsc2 hpe
      hpl0 hpl1 M.rel M.pb M.fresh M.dinv hpool hre hl2 hl1 hev

end Ryo.Proofs.Lower
