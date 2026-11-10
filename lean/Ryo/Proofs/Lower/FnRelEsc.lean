/-
Ryo.Proofs.Lower.FnRelEsc — the function simulation with scopes (aot.md §C1 "Escape", "Locals",
M5b): functions whose locals escape (`_d = &_a`, `Ref.lean`), checked by `LowersFnX`
(`Check/Lower/FnX.lean`: `LowersFn` without `noScopes`/`noEsc`, plus `ScopesOk`).

## Design

**Where scopes are** (`ScopesOk`, checked; `CertCheck`'s escape coverage is not used). The
backend puts a scope before the *next* instruction. So a scope sits only at the start `k` of a
non-empty statement or terminator range (none inside a range, `stmtInner`/`termInner`), and the
list there is, in order, (1) the `End`s of the instruction-less statements of the same block
before it whose range also starts at `k` (`pendSpecs`; a `StorageDead _l` has one iff some
`Escape` covers `_l`'s slot, `endSpec`), then (2) the statement's own scopes (`ownSpec`: a
`ref`'s `Escape` of its referent's whole slot; none for other statements and terminators). A
block whose terminator has no instruction has no pending `End` (`termEmpty`).

**Pending scopes: R runs ahead virtually.** L0's `StorageDead _l` deallocates at once, while R's
`End` runs only with the next instruction, after the statements in between, which may
`StorageLive` a local sharing `_l`'s slot (slots are shared, `ShareOk`). Rather than a relation
for "dead in L0, live in R", the relation is with R's state *after the scopes the L0 statements
so far account for*: at L0's statement `i` of block `b`, R is at `s1` with `pc = pcAt blk i`
(as in M5a), and `MatchAtX` relates L0 to `s0`, the state after the first `n` scopes at `pc`
(`pend`), `n = (pendSpecs … i).length`. An instruction-less statement doesn't step R: `StorageDead
_l` with an `End` folds one more scope (`fold_take_succ`, `scope_end_rel`: L0 frees `_l`'s
allocation exactly when R frees its object), others fold none. A statement with an instruction
at `k` steps R from the real `s1`: `step` folds all scopes at `k` (= the first `n`, giving `s0`,
then the own ones, `scopes_append_ok`) and runs the instruction (`step_eq_stepBody`).

**Generalized relation** (`FnRelX`): `FnRel` (unchanged: `LocalRel` is already `priv` or `esc`,
`FnRel.esc` ties R's escaped bytes to the static `Γ.escaped`, which is now `scopeEscaped d`
instead of `false`), plus invariants of R's escaped objects that M5a got from having none:
- `objs`: every escaped object of the frame is exactly the slot (non-zero size) of a
  storage-live L0 local, and they are pairwise disjoint (`disj`): objects come only from a
  `ref`'s `Escape` of its referent's slot and go with that local's `End` (`endLive` + `ShareOk`:
  no other local in the slot is storage-live at the `End`);
- `owned`: a live L0 allocation `ι` maps into a frame object is the local whose slot the object
  is (so an `End` frees only allocations L0 just freed: `storageEnd_rel`'s `hgone`, `hapart`);
- `free`: a live R allocation is a frame object or disjoint from every local slot at `fp` (so a
  new `Escape` overlaps no live allocation; established at entry, M5c);
- `aligned`: storage-live locals' addresses are aligned to their types (an `Escape`'s
  alignment is at most the referent's, `ownSpec`, so `escape`'s alignment check passes).
The object of an escaped local `_a` relates by `LocalRel.esc`: `ι` maps `_a`'s allocation to the
object's id (added at the `Escape` by `escape_rel` with `as = [_a's allocation]`, `ι.extend`),
the object is at `fp + e.off`, `MemInj` relates the bytes. So `ι` grows along a run: `LiftOutX`,
`StmtOutX` and the run's conclusions have `∃ ι' ≥ ι` (an edit to `fn_step_sim`/`fn_sim`'s form).

**Existing families stay private-only for destinations** (their `hpriv`: no `Escape` covers the
destination, a static fact, as before). Their sources may be escaped already (`readLocal_inj`,
`readLocal_sub_inj` read `esc` locals). An escaped local is written or read otherwise only
through pointers (loads/stores, M5b's later families, over `MemInj`). Their lifts are reused
unchanged on the scope-free code `c.dropScopes` from the folded state `s0`
(`step_dropScopes`: a non-island instruction's step after its scopes doesn't read them);
`liftOutX_of_liftOut` lifts their `LiftOut` (one step, `ι` unchanged) to `LiftOutX`, using that
such a step keeps the escaped objects and the allocations' addresses and liveness
(`step_plain_keeps`).

**The scope step lemma** (`step_of_view_scopes`, generalizing `step_of_opSem`/`step_of_view`):
the instruction at `pc` with scopes before it steps to `{ s0 with pc := pc + 1, st := st' }`
where `s0` is the scopes' fold and `opSem` runs on `s0.st`. Scopes keep `pc`, `fp`
(`scopes_pc_fp`); the successor is stated from `s0` (whose `args` scopes keep too).

**Terminators** take `TermAt`, whose `scopes` is `[]` at every index of the range. With pending
`End`s at the terminator's first index (common: `StorageDead(_2); return`), the edit is to
`SimTerm.TermAt`: `scopes` only for `0 < j`, and a field `(c.scopesAt s1.pc).foldlM applyScope
s1 = .ok s0` with the lemmas (`TermAt.head`, the first step `step_eq_stepBody_nil`) taking the
first step through `step_eq_stepBody` from `s0`; every later step is unchanged.

**The `ref` lift** (`SimRef.lean`, `lift_ref`): the own `Escape` of `_a`'s slot runs on `s0`
(`scope_escape_rel`: if `_a` is private it becomes an object at `fp + sa.off`, `ι` extended by
`_a`'s allocation, `MemInj.mono`'s freshness from `Hidden`; if escaped already, `escape` is a
no-op), then `addr` writes `encodePtr p1` to `_d`'s private slot where `p1 = ⟨y.addr + (sa.off +
off - e.off), some e.id⟩ = ⟨fp + sa.off + off, some e.id⟩` relates by `PtrInj ι'` to L0's
`⟨pa.addr + off, pa.prov⟩` (`addrOf_inj`). `_d`'s bytes now carry `_a`'s provenance, which is no
longer private (`PrivAlloc ι'` excludes it), so `Hidden` holds.

What `LowersFnX` must give that `LowersFn` doesn't: `ScopesOk`, `escDef` and `stmtsX` (every
statement-range instruction falls through; no pending `End` after a non-empty range; a
`StorageDead`'s `End` at its pending index). Entry (M5c/the prologue) must establish `free`,
`aligned` and no escaped object (`objs`, `disj`, `idLt`, `addrAt` trivially). The statement
step `stmt_simX` is in `SimRef.lean`, the function level in `TermSimX.lean` and
`FnSimX.lean`.
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Proofs.Lower.StepTerm
import Ryo.Check.Lower.FnX

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Scope folds and the scope step lemma -/

theorem scopes_append_ok {l1 l2 : List R.Scope} {s s1 : R.RState}
    (h : l1.foldlM R.applyScope s = .ok s1) :
    (l1 ++ l2).foldlM R.applyScope s = l2.foldlM R.applyScope s1 := by
  rw [List.foldlM_append, h]
  all_goals rfl

/-- Folding one more scope.

Proof: `List.take_succ`, `hn` (`(scs[n]?).toList = [sc]`), `scopes_append_ok h`, then
`List.foldlM_cons`, `h1`, `List.foldlM_nil` (`simp only [..., bind, Except.bind, pure,
Except.pure]`). -/
theorem fold_take_succ {scs : List R.Scope} {n : Nat} {s s0 s0' : R.RState} {sc : R.Scope}
    (h : (scs.take n).foldlM R.applyScope s = .ok s0) (hn : scs[n]? = some sc)
    (h1 : R.applyScope s0 sc = .ok s0') :
    (scs.take (n + 1)).foldlM R.applyScope s = .ok s0' := by
  rw [List.take_succ, hn, scopes_append_ok h]
  simp only [Option.toList_some, List.foldlM_cons, List.foldlM_nil, h1]
  all_goals first | rfl | simp [bind, Except.bind, pure, Except.pure]

/-- The scope step lemma: an operation falling through, with scopes before it, steps to the next
index from the scopes' fold `s0` with `opSem`'s state on `s0`. -/
theorem step_of_view_scopes {c : R.Code} {s1 s0 : R.RState} {ch : OpSem.Choice} {i : R.Insn}
    {v : R.View} {st' : OpSem.State} (hi : c.d.insns[s1.pc]? = some i)
    (hsc : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i)
    (hv : R.view c.mode c.ρ i = some v) (hctl : v.ctl = some .next)
    (hop : opSem v.op v.ops s0.st ch = .ok (.next, st')) :
    R.step c s1 ch = .ok (.step { s0 with pc := s0.pc + 1, st := st' }) := by
  rw [step_eq_stepBody hi hsc]
  exact stepBody_of_opSem (by
      intro op ops he f hf
      subst he
      exact shapes_of_opShape (view_native_opShape hv hf (by rw [hctl]; rfl)))
    hv hctl (hpl.notResume v hv (ctl_ne_trap hctl))
      (hpl.notUnreachable v hv (ctl_ne_trap hctl)) hpe hop rfl

/-- The code without its scopes: the existing lifts (which take no scopes at `pc`) run on it
from the folded state. -/
def _root_.Ryo.Vm.R.Code.dropScopes (c : R.Code) : R.Code :=
  { c with d := { c.d with scopes := #[] } }

theorem dropScopes_scopesAt (c : R.Code) (k : Nat) : c.dropScopes.scopesAt k = [] := by
  first
    | rfl
    | simp [R.Code.scopesAt, R.Code.dropScopes]

/-- A non-island instruction's step after its scopes is the scope-free code's from the fold. -/
theorem step_dropScopes {c : R.Code} {s1 s0 : R.RState} {ch : OpSem.Choice} {i : R.Insn}
    (hi : c.d.insns[s1.pc]? = some i)
    (hsc : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hnat : ViewShape i) (hv : ∃ v, R.view c.mode c.ρ i = some v) :
    R.step c s1 ch = R.step c.dropScopes s0 ch := by
  have hpc : s0.pc = s1.pc := scopes_pc hsc
  have hi' : c.dropScopes.d.insns[s0.pc]? = some i := by rw [hpc]; exact hi
  rw [step_eq_stepBody hi hsc, step_eq_stepBody_nil hi' (dropScopes_scopesAt c _),
    stepBody_view hnat hv, stepBody_view (c := c.dropScopes) hnat hv]
  all_goals first
    | rfl
    | (unfold R.stepView R.unwindAt; rfl)

/-! ### The relation -/

/-- `FnRel` with the invariants of R's escaped objects (see the module comment). -/
structure FnRelX (Γ : StmtCtx) (ι : Inj) (live : Local → Bool) (f0 : Spec.Frame) (m0 : Memory)
    (s1 : R.RState) : Prop where
  rel : FnRel Γ ι live f0 m0 s1
  objs : ∀ e ∈ s1.st.escaped, ∃ (l : Local) (p : ThinPointer) (sl : LocalSlot),
    f0.locals[l]? = some (some p) ∧ Γ.slots[l]? = some sl ∧ e.off = sl.off ∧
      e.size = sl.size ∧ 0 < sl.size
  disj : s1.st.escaped.Pairwise fun (e e' : OpSem.EscapedObj) =>
    e.off + (e.size : Int) ≤ e'.off ∨ e'.off + (e'.size : Int) ≤ e.off
  owned : ∀ a b x (e : OpSem.EscapedObj), ι a = some b → m0.get? a = some x → x.live = true →
    e ∈ s1.st.escaped → e.id = b →
    ∃ (l : Local) (p : ThinPointer) (sl : LocalSlot), f0.locals[l]? = some (some p) ∧
      p.prov = some a ∧ Γ.slots[l]? = some sl ∧ e.off = sl.off ∧ e.size = sl.size
  free : ∀ id y, s1.st.mem.get? id = some y → y.live = true →
    (∃ e ∈ s1.st.escaped, e.id = id ∧ (y.addr : Int) = s1.fp + e.off ∧ y.data.size = e.size) ∨
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        (y.addr : Int) + y.data.size ≤ s1.fp + sl.off ∨ s1.fp + sl.off + sl.size ≤ y.addr
  aligned : ∀ (l : Local) (p : ThinPointer) (ty : Spec.Ty), f0.locals[l]? = some (some p) →
    f0.body.locals[l]? = some ty → p.addr % ty.align.bytes = 0
  /-- Objects' allocations exist (each `escape` takes a fresh id; nothing shrinks `mem`). -/
  idLt : ∀ e ∈ s1.st.escaped, e.id < s1.st.mem.allocs.size
  /-- An object's allocation is at `fp + e.off` (`escape` puts it there; addresses never move). -/
  addrAt : ∀ e ∈ s1.st.escaped, ∀ y, s1.st.mem.get? e.id = some y → (y.addr : Int) = s1.fp + e.off

/-- `DerefInv` for a larger `ι`: fewer allocations are unmapped. -/
theorem DerefInv.mono {ι ι' : Inj} {m : Memory} (h : DerefInv ι m) (hle : ι.Le ι') :
    DerefInv ι' m := by
  refine ⟨h.1.mono fun a ha => ?_, h.2, h.3⟩
  obtain ⟨hn, hx⟩ := ha
  refine ⟨?_, hx⟩
  cases hι : ι a with
  | none => rfl
  | some b =>
    rw [hle a b hι] at hn
    cases hn

/-- A store of bytes whose provenances `ι` maps keeps `DerefInv` (the `ref` store). -/
theorem DerefInv.store_mapped {ι : Inj} {m m' : Memory} {p : ThinPointer}
    {bs : List AbstractByte} {al : Align} (h : DerefInv ι m) (hsto : m.store p bs al = .ok m')
    (hbs : ∀ b ∈ bs, ∀ fr, b.provFrag = some fr → ι fr.prov ≠ none) : DerefInv ι m' := by
  obtain ⟨hmap, hld, hbl⟩ := h
  have hf : ∀ a x', m'.get? a = some x' → ∃ x, m.get? a = some x ∧ x.addr = x'.addr ∧
      (x'.live = true → x.live = true) ∧ x.data.size = x'.data.size := fun a x' hx' => by
    obtain ⟨x, hx, e1, el, es⟩ := store_get?_fwd hsto hx'
    exact ⟨x, hx, e1, fun h => el.trans h, es⟩
  have hU : ∀ a, Unmapped ι m' a → Unmapped ι m a := by
    rintro a ⟨hι, x', hx', hl', hp'⟩
    obtain ⟨x, hx, -, el, es⟩ := hf a x' hx'
    exact ⟨hι, x, hx, el hl', by omega⟩
  refine ⟨(hmap.mono hU).store_hidden hsto (fun b hb fr hfr hu => hbs b hb fr hfr hu.1), ?_,
    hbl.of_kept hf⟩
  intro i j a b x hi hj hla hlb h1 h2 h3 h4
  obtain ⟨a0, ha0, ea, el, es⟩ := hf i a hi
  obtain ⟨b0, hb0, eb, el', es'⟩ := hf j b hj
  simp only [Allocation.size] at h2 h4
  exact hld i j a0 b0 x ha0 hb0 (el hla) (el' hlb) (by omega)
    (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)

/-- What a lifted assignment gives with scopes: `ι` may grow (an `Escape`), R's step is from the
real state `s1` and lands after the folded `s0` (see the module comment). -/
def LiftOutX (Γ : StmtCtx) (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (f : Spec.Frame) (s s' : Spec.State) (s1 s0 : R.RState) : Prop :=
  ∃ ι' st', ι.Le ι' ∧ (∀ a, s.mem.allocs.size ≤ a → ι' a = ι a) ∧
    R.step c s1 ch = .ok (.step { s0 with pc := s0.pc + 1, st := st' }) ∧
    s'.stack = s.stack ∧
    FnRelX Γ ι' live' f s'.mem { s0 with pc := s0.pc + 1, st := st' } ∧
    ProvBounded s'.mem ∧ s.mem.allocs.size ≤ s'.mem.allocs.size ∧ DerefInv ι' s'.mem

/-- `MatchAt` with pending scopes: R is at `s1`, L0 is related to `s0`, `s1` after the scopes at
`pc` the statements before `f.stmt` account for. -/
structure MatchAtX (Γ : TermCtx) (c : R.Code) (ι : Inj) (s : Spec.State) (s1 s0 : R.RState)
    (f : Spec.Frame) (rest : List Spec.Frame) (blk : BlockCert) (bd : BlockData) : Prop where
  stack : s.stack = f :: rest
  body : f.body = Γ.body
  pu : f.pendingUnwind = none
  cont : f.cont = .bottom
  hblk : Γ.blocks[f.bb]? = some blk
  hbd : Γ.body.blocks[f.bb]? = some bd
  le : f.stmt ≤ bd.stmts.length
  pc : pcAt blk f.stmt = s1.pc
  pend : ((c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk f.stmt).length).foldlM
    R.applyScope s1 = .ok s0
  rel : FnRelX Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s0
  sl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true
  pb : ProvBounded s.mem
  fresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none
  dinv : DerefInv ι s.mem

def MatchEsc (Γ : TermCtx) (c : R.Code) (ι : Inj) (s : Spec.State) (s1 : R.RState) : Prop :=
  ∃ s0 f rest blk bd, MatchAtX Γ c ι s s1 s0 f rest blk bd

/-- One statement's simulation with scopes (`StmtOut` with `∃ ι' ≥ ι` and the next point's
pending fold). -/
def StmtOutX (Γ : TermCtx) (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (f : Spec.Frame)
    (rest : List Spec.Frame) (bd : BlockData) (blk : BlockCert) (s s' : Spec.State)
    (s1 : R.RState) : Prop :=
  ∃ ι' s1' s0' f', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧
    f'.body = f.body ∧ f'.bb = f.bb ∧ f'.stmt = f.stmt ∧
    f'.pendingUnwind = f.pendingUnwind ∧ f'.cont = f.cont ∧ s1'.pc = pcAt blk (f.stmt + 1) ∧
    ((c.scopesAt s1'.pc).take (pendSpecs Γ.toStmtCtx bd blk (f.stmt + 1)).length).foldlM
      R.applyScope s1' = .ok s0' ∧
    FnRelX Γ.toStmtCtx ι' ((computeLive Γ.body).get f.bb (f.stmt + 1)) f' s'.mem s0' ∧
    (∀ l p, f'.locals[l]? = some (some p) →
      (computeStorage Γ.body).get f.bb (f.stmt + 1) l = true) ∧
    ProvBounded s'.mem ∧ (∀ a, s'.mem.allocs.size ≤ a → ι' a = none) ∧ DerefInv ι' s'.mem

/-! ### Scope lists against their specs -/

/-- A matched list splits as its specs do.

Proof: induction on `ps` generalizing `scs`; `cases scs`; `specsOk` unfolds (`Bool.and_eq_true`).
-/
theorem specsOk_append {ps qs : List ScopeSpec} {scs : List R.Scope}
    (h : specsOk (ps ++ qs) scs = true) :
    scs = scs.take ps.length ++ scs.drop ps.length ∧ specsOk ps (scs.take ps.length) = true ∧
      specsOk qs (scs.drop ps.length) = true := by
  induction ps generalizing scs with
  | nil =>
    simp only [List.nil_append] at h
    refine ⟨(List.take_append_drop _ _).symm, ?_, ?_⟩
    · simp only [List.length_nil, List.take_zero, specsOk]
    · simpa only [List.length_nil, List.drop_zero] using h
  | cons p ps ih =>
    cases scs with
    | nil => simp [specsOk] at h
    | cons sc scs =>
      simp only [List.cons_append, specsOk, Bool.and_eq_true] at h
      obtain ⟨-, h2, h3⟩ := ih h.2
      refine ⟨(List.take_append_drop _ _).symm, ?_, ?_⟩
      · simp only [List.length_cons, List.take_succ_cons, specsOk, Bool.and_eq_true]
        exact ⟨h.1, h2⟩
      · simpa only [List.length_cons, List.drop_succ_cons] using h3

/-- A matched `Escape`.

Proof: `unfold specsOk ScopeSpec.ok at h`; `cases scs` (length 1); `split at h` on the kind;
`simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h`. -/
theorem specsOk_escS {o : Int} {n e : Nat} {sc : R.Scope}
    (h : ScopeSpec.ok (.escS o n e) sc = true) :
    ∃ al, sc.kind = .escape al ∧ sc.frameOffset.toInt = o ∧ sc.size = n ∧
      (Align.ofBytes al).exp ≤ e := by
  simp only [ScopeSpec.ok, Bool.and_eq_true, beq_iff_eq] at h
  obtain ⟨⟨hk, ho⟩, hn⟩ := h
  cases hkd : sc.kind with
  | escape al =>
    rw [hkd] at hk
    exact ⟨al, rfl, ho, hn, of_decide_eq_true hk⟩
  | «end» => rw [hkd] at hk; first | cases hk | simp at hk
  | lend => rw [hkd] at hk; first | cases hk | simp at hk

/-- A matched `End`. Proof: as `specsOk_escS`. -/
theorem specsOk_endS {o : Int} {n : Nat} {sc : R.Scope}
    (h : ScopeSpec.ok (.endS o n) sc = true) :
    sc.kind = .end ∧ sc.frameOffset.toInt = o ∧ sc.size = n := by
  simp only [ScopeSpec.ok, Bool.and_eq_true, beq_iff_eq] at h
  exact ⟨h.1.1, h.1.2, h.2⟩

/-! ### Steps without scope effects keep the objects -/

/-- R's allocations keep their number, addresses, liveness and sizes (what `FnRelX.free`
needs of a step without scopes; `Agree` without the kind and vtable parts). -/
def AllocsKept (m m' : Memory) : Prop :=
  m'.allocs.size = m.allocs.size ∧ ∀ id a', m'.get? id = some a' →
    ∃ a, m.get? id = some a ∧ a'.addr = a.addr ∧ a'.live = a.live ∧ a'.data.size = a.data.size

theorem AllocsKept.refl (m : Memory) : AllocsKept m m :=
  ⟨rfl, fun _ a h => ⟨a, h, rfl, rfl, rfl⟩⟩

theorem AllocsKept.trans {m1 m2 m3 : Memory} (h1 : AllocsKept m1 m2) (h2 : AllocsKept m2 m3) :
    AllocsKept m1 m3 := by
  refine ⟨h2.1.trans h1.1, fun id a3 h => ?_⟩
  obtain ⟨a2, h2', e1, e2, e3⟩ := h2.2 id a3 h
  obtain ⟨a1, h1', f1, f2, f3⟩ := h1.2 id a2 h2'
  exact ⟨a1, h1', e1.trans f1, e2.trans f2, e3.trans f3⟩

theorem AllocsKept.of_agree {m m' : Memory} (h : Ryo.Spec.Theorems.Agree m m') :
    AllocsKept m m' := by
  refine ⟨h.1.symm, fun id a' h' => ?_⟩
  rcases h.get? id with ⟨-, h2⟩ | ⟨a, b, h1, h2, ha, -, hl, hsz, -⟩
  · rw [h2] at h'; cases h'
  · rw [h2] at h'; cases h'
    exact ⟨a, h1, ha.symm, hl.symm, hsz.symm⟩

theorem AllocsKept.of_escFrom {st : OpSem.State} {off : Int} {l : List (AbstractByte × Nat)}
    {m m' : Memory} (h : Ryo.Proofs.Inline.EscFrom st off l m m') : AllocsKept m m' :=
  ⟨h.1, fun id a' ha => by
    obtain ⟨a, ha', he, hsz, -⟩ := h.2 id a' ha
    have h1 := congrArg Allocation.addr he
    have h2 := congrArg Allocation.live he
    exact ⟨a, ha', h1, h2, hsz⟩⟩

theorem store_allocsKept {st : OpSem.State} {m m' : Memory} {p : ThinPointer}
    {bs : List AbstractByte} {al : Align} (h : st.store m p bs al = .ok m') : AllocsKept m m' := by
  unfold OpSem.State.store liftOutcome at h
  split at h
  · cases h
    exact AllocsKept.of_agree (Ryo.Spec.Theorems.Memory.store_agree (by assumption))
  all_goals cases h

/-- As `OpFacts.kindSem_out`'s memory part. -/
theorem kindSem_allocsKept {k : Handlers.HandlerKind} {ps : List String} {e : OpSem.Env}
    {o : OpSem.Out}
    (h : kindSem k ps e = .ok o) : AllocsKept e.st.mem o.mem := by
  cases k <;> simp only [kindSem, bind, Except.bind, pure, Except.pure] at h <;>
    repeat'
      first
        | (simp only [reduceCtorEq] at h; done)
        | (simp [illFormed, ub] at h; done)
        | split at h
  all_goals
    injection h with h
    subst h
    first | exact AllocsKept.refl _ | exact store_allocsKept (by assumption)

theorem writeFrame_allocsKept {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') : AllocsKept st.mem st'.mem := by
  unfold OpSem.State.writeFrame at h
  cases hm : st.writeEscaped off bs with
  | error e => simp [hm, bind, Except.bind] at h
  | ok m' =>
    simp only [hm, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at h
    subst h
    exact AllocsKept.of_escFrom (Ryo.Proofs.Inline.writeEscaped_spec hm)

theorem commit_allocsKept {fp : Footprint} {val : String → Option Val} :
    ∀ (ws : List (String × List AbstractByte)) {st st' : OpSem.State},
      commit fp val st ws = .ok st' → AllocsKept st.mem st'.mem
  | [], st, st', h => by cases h; exact AllocsKept.refl _
  | w :: ws, st, st', h => by
    simp only [commit, List.foldlM_cons, bind, Except.bind] at h
    cases h1 : commitOne fp val st w with
    | error e => simp [h1] at h
    | ok st1 =>
      simp only [h1] at h
      have k1 : AllocsKept st.mem st1.mem := by
        unfold commitOne at h1
        split at h1
        · simp [illFormed] at h1
        split at h1
        · simp [illFormed] at h1
        split at h1
        · exact writeFrame_allocsKept h1
        · simp [illFormed] at h1
      exact k1.trans (commit_allocsKept ws h)

/-- As `OpFacts.opSem_out`'s memory part. -/
theorem opSem_allocsKept {op : Full.Opcode} {ops : Operands} {st st' : OpSem.State}
    {ch : OpSem.Choice} {ctl : OpSem.Control} (h : opSem op ops st ch = .ok (ctl, st')) :
    AllocsKept st.mem st'.mem := by
  unfold opSem at h
  simp only [bind, Except.bind] at h
  cases hp : prepare op ops with
  | error e => simp [hp] at h
  | ok r =>
    obtain ⟨hi, fp, val⟩ := r
    simp only [hp] at h
    cases hr : readAll fp val st with
    | error e => simp [hr] at h
    | ok reads =>
      simp only [hr] at h
      cases hk : kindSem hi.kind hi.params (mkEnv reads val st ch) with
      | error e => simp [hk] at h
      | ok o =>
        simp only [hk] at h
        cases hc : commit fp val { st with mem := o.mem } o.writes with
        | error e => simp [hc] at h
        | ok st1 =>
          simp only [hc, pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨-, rfl⟩ := h
          have k1 : AllocsKept st.mem o.mem := kindSem_allocsKept hk
          exact k1.trans (commit_allocsKept _ hc)

/-- A fall-through operation's step on the scope-free code keeps the escaped objects, every
allocation's number, address, liveness and size (`AllocsKept`), and `fp`.

Proof: `step_eq_stepBody_nil (dropScopes_scopesAt _ _)`, `stepBody_view`; `opSem` succeeds
with `.next` (any other control has no successor for `.next`), so the step is
`stepView_of_opSem`'s `{ s0 with pc := s0.pc + 1, st := st'' }`; `OpFacts.opSem_out` for
`escaped`, `opSem_allocsKept` for the allocations. -/
theorem step_plain_keeps {c : R.Code} {s0 s' : R.RState} {ch : OpSem.Choice} {i : R.Insn}
    {v : R.View} (hi : c.d.insns[s0.pc]? = some i) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hv : R.view c.mode c.ρ i = some v)
    (hctl : v.ctl = some .next) (h : R.step c.dropScopes s0 ch = .ok (.step s')) :
    s'.st.escaped = s0.st.escaped ∧ AllocsKept s0.st.mem s'.st.mem ∧ s'.fp = s0.fp := by
  have hnat : ViewShape i := fun op ops he f hf => by
    subst he
    exact shapes_of_opShape (view_native_opShape hv hf (by rw [hctl]; rfl))
  have hi' : c.dropScopes.d.insns[s0.pc]? = some i := hi
  have hv' : R.view c.dropScopes.mode c.dropScopes.ρ i = some v := hv
  have hpe' : c.dropScopes.mode.pe = false := hpe
  have hres := hpl.notResume v hv (ctl_ne_trap hctl)
  have hun := hpl.notUnreachable v hv (ctl_ne_trap hctl)
  rw [step_eq_stepBody_nil hi' (dropScopes_scopesAt c _), stepBody_view hnat ⟨v, hv'⟩] at h
  cases hop : opSem v.op v.ops s0.st ch with
  | error e =>
    exfalso
    have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
    have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
    unfold R.stepView at h
    simp [hv', hctl, h1, h2, hop, bind, Except.bind] at h
  | ok r =>
    obtain ⟨ctl, st''⟩ := r
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    have hak := opSem_allocsKept hop
    cases ctl with
    | next =>
      have hfw := stepView_of_opSem (c := c.dropScopes) (s := s0) hv' hctl hres hun hpe' hop rfl
      rw [hfw] at h
      injection h with h
      injection h with h
      subst h
      exact ⟨hesc, hak, rfl⟩
    | branch b =>
      exfalso
      have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
      have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
      unfold R.stepView at h
      cases i <;> simp [hv', hctl, h1, h2, hop, R.Then.succ, R.clearHome, hpe', bind,
        Except.bind, pure, Except.pure, illFormed, throw, throwThe, MonadExceptOf.throw] at h
    | index k =>
      exfalso
      have h1 : (v.op == Full.Opcode.resume) = false := beq_eq_false_iff_ne.mpr hres
      have h2 : (v.op == Full.Opcode.unreachable) = false := beq_eq_false_iff_ne.mpr hun
      unfold R.stepView at h
      cases i <;> simp [hv', hctl, h1, h2, hop, R.Then.succ, R.clearHome, hpe', bind,
        Except.bind, pure, Except.pure, illFormed, throw, throwThe, MonadExceptOf.throw] at h

/-- An existing family's lift, run on `c.dropScopes` from the fold `s0` of all the scopes at
`pc` (`hsc`), gives `LiftOutX` with `ι' = ι`.

Proof: the step is `step_dropScopes`; `step_plain_keeps` gives the objects, `AllocsKept` and
`fp`; L0's frame is the same `f`, so `objs`, `disj`, `aligned` carry over; `owned` from
`LiftOut`'s `MemKept` (L0's liveness only decreases); `free` from `AllocsKept`. -/
theorem liftOutX_of_liftOut {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {f : Spec.Frame} {s s' : Spec.State} {s1 s0 : R.RState}
    {i : R.Insn} {v : R.View} (hi : c.d.insns[s1.pc]? = some i)
    (hsc : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hv : R.view c.mode c.ρ i = some v)
    (hctl : v.ctl = some .next) (hX : FnRelX Γ ι live f s.mem s0)
    (hdi : DerefInv ι s.mem)
    (hl : LiftOut Γ c.dropScopes ch ι live' f s s' s0) :
    LiftOutX Γ c ch ι live' f s s' s1 s0 := by
  obtain ⟨st', hstep, hstk, hrel', hpb, hle, hk⟩ := hl
  have hnat : ViewShape i := fun op ops he f hf => by
    subst he
    exact shapes_of_opShape (view_native_opShape hv hf (by rw [hctl]; rfl))
  have hpc : s0.pc = s1.pc := scopes_pc hsc
  have hi0 : c.d.insns[s0.pc]? = some i := by rw [hpc]; exact hi
  obtain ⟨hesc, hak, -⟩ := step_plain_keeps hi0 hpe hpl hv hctl hstep
  refine ⟨ι, st', fun _ _ h => h, fun _ _ => rfl, ?_, hstk, ?_, hpb, hle, hdi.of_memKept hk⟩
  · rw [step_dropScopes hi hsc hnat ⟨v, hv⟩]
    exact hstep
  refine ⟨hrel', fun e he => ?_, ?_, fun a b x e hι hx hl he hid => ?_,
    fun id y hy hl => ?_, hX.aligned, fun e he => ?_, fun e he y hy => ?_⟩
  · first
      | (rw [hesc] at he; exact hX.objs e he)
      | exact hX.objs e (hesc ▸ he)
  · first
      | (rw [hesc]; exact hX.disj)
      | exact hesc ▸ hX.disj
  · obtain ⟨x0, h1, -, hl', -⟩ := hk.1 a x hx
    first
      | (rw [hesc] at he; exact hX.owned a b x0 e hι h1 (hl' hl) he hid)
      | exact hX.owned a b x0 e hι h1 (hl' hl) (hesc ▸ he) hid
  · obtain ⟨y0, hy0, hadd, hlv, hsz⟩ := hak.2 id y hy
    rcases hX.free id y0 hy0 (by rw [← hlv]; exact hl) with ⟨e, he, hid, hya, hys⟩ | hfr
    · refine .inl ⟨e, by first | (rw [hesc]; exact he) | exact hesc ▸ he, hid, ?_, ?_⟩
      · rw [hadd]; exact hya
      · rw [hsz]; exact hys
    · refine .inr fun l sl hsl => ?_
      rw [hadd, hsz]
      exact hfr l sl hsl
  · rw [hak.1]
    first
      | (rw [hesc] at he; exact hX.idLt e he)
      | exact hX.idLt e (hesc ▸ he)
  · obtain ⟨y0, hy0, hadd, -, -⟩ := hak.2 e.id y hy
    rw [hadd]
    first
      | (rw [hesc] at he; exact hX.addrAt e he y0 hy0)
      | exact hX.addrAt e (hesc ▸ he) y0 hy0

/-- An assignment's L0 memory keeps every allocation's address, liveness and size, given the
family's memory lemma's single store (`copy_mem`, `field_mem`, `assign_ref_inv`: the
assignment's memory is one `Memory.store`). Stated over the store rather than the whole
evaluator: every lowered family has such a lemma, and a general one would need the whole
`evalRvalue`. -/
theorem assign_agree {s s' : Spec.State} {pd : ThinPointer} {bs : List AbstractByte}
    (hsto : s.mem.store pd bs .one = .ok s'.mem) :
    Ryo.Spec.Theorems.Agree s.mem s'.mem :=
  Ryo.Spec.Theorems.Memory.store_agree hsto

/-! ### The scopes against the relation -/

/-! ### Piece 1: an `Escape` of a private slot succeeds -/

/-- No escaped object meets a private non-empty frame range. -/
theorem noObj_of_priv {st : OpSem.State} {off : Int} {n : Nat} (hn : 0 < n)
    (hsz : ∀ e ∈ st.escaped, 0 < e.size)
    (hpriv : ∀ k < n, st.escapedAt (off + k) = none) :
    ∀ e ∈ st.escaped, ¬ (e.off < off + n ∧ off < e.off + e.size) := by
  intro e he hov
  obtain ⟨h1, h2⟩ := hov
  have h3 := hsz e he
  have hk : ∃ k : Nat, k < n ∧ e.off ≤ off + k ∧ off + k < e.off + e.size := by
    by_cases hle : e.off ≤ off
    · exact ⟨0, hn, by omega, by omega⟩
    · exact ⟨(e.off - off).toNat, by omega, by omega, by omega⟩
  obtain ⟨k, hkn, hlo, hhi⟩ := hk
  have hnone := hpriv k hkn
  unfold OpSem.State.escapedAt at hnone
  have hne := List.find?_eq_none.1 hnone e he
  simp only [decide_eq_true_eq] at hne
  exact hne ⟨hlo, hhi⟩

/-- `escape` of a private non-empty range at a non-negative, aligned address that no live
allocation meets succeeds (each of its checks passes). -/
theorem escape_ok_priv {s : R.RState} {off : Int} {size al : Nat} (hpos : 0 < size)
    (hsz : ∀ e ∈ s.st.escaped, 0 < e.size)
    (hpriv : ∀ k < size, s.st.escapedAt (off + k) = none) (hge : 0 ≤ (s.fp : Int) + off)
    (hal : ((s.fp : Int) + off).toNat % (Align.ofBytes al).bytes = 0)
    (hfree : ∀ a ∈ s.st.mem.allocs, a.live = true →
      a.addr + a.size ≤ ((s.fp : Int) + off).toNat ∨ ((s.fp : Int) + off).toNat + size ≤ a.addr) :
    ∃ s', R.escape s off size al = .ok s' := by
  have hno := noObj_of_priv hpos hsz hpriv
  have hc1 : (s.st.escaped.any fun e => decide (e.off ≤ off ∧ off + size ≤ e.off + e.size)) =
      false := by
    rw [List.any_eq_false]
    intro e he hc
    simp only [decide_eq_true_eq] at hc
    exact hno e he ⟨by omega, by omega⟩
  have hc2 : (s.st.escaped.any fun e => decide (e.off < off + size ∧ off < e.off + e.size)) =
      false := by
    rw [List.any_eq_false]
    intro e he hc
    simp only [decide_eq_true_eq] at hc
    exact hno e he hc
  have hfa : R.frameAddr s.fp off = .ok ((s.fp : Int) + off).toNat := by
    unfold R.frameAddr
    rw [if_neg (by omega)]
    rfl
  have hc3 : (Align.ofBytes al).isAligned ((s.fp : Int) + off).toNat = true := by
    simp only [Align.isAligned, beq_iff_eq]
    exact hal
  have hc4 : (s.st.mem.allocs.any fun a =>
      a.live && a.overlaps ((s.fp : Int) + off).toNat size) = false := by
    rw [Array.any_eq_false']
    intro a ha hc
    simp only [Bool.and_eq_true] at hc
    obtain ⟨hl, ho⟩ := hc
    have hd := hfree a ha hl
    unfold Allocation.overlaps at ho
    split at ho
    · cases ho
    · first
        | (simp only [Bool.not_eq_true', Bool.or_eq_false_iff, decide_eq_false_iff_not] at ho
           omega)
        | (simp at ho; omega)
  have hrd : s.st.readFrame off size =
      .ok ((List.range size).map fun i : Nat => s.st.frame (off + i)) :=
    readFrame_eq_map fun i hi => by
      unfold OpSem.State.byteAt
      rw [hpriv i hi]
      all_goals rfl
  unfold R.escape
  first
    | (simp only [hc1, hc2, Bool.false_eq_true, ↓reduceIte, bind, Except.bind, hfa, hc3,
        Bool.not_true, hc4, hrd]
       exact ⟨_, rfl⟩)
    | (simp [hc1, hc2, hfa, hc3, hc4, hrd, bind, Except.bind, pure, Except.pure]; done)

/-- The `Escape` of a storage-live private local `_a`'s slot succeeds under `FnRelX`: no
object meets the slot (`noObj_of_priv`), the address is `_a`'s (`haddr`, from
`LocalRel.priv`), aligned (`aligned`, `hal` from `specsOk_escS`), and every live allocation is
a frame object (apart from the slot, `noObj_of_priv`) or apart from every slot (`free`). -/
theorem escape_ok_of_relX {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s0 : R.RState} {a : Local} {pa : ThinPointer} {sa : LocalSlot}
    {ta : Spec.Ty} {al : Nat}
    (hX : FnRelX Γ ι live f m0 s0) (hpa : f.locals[a]? = some (some pa))
    (hsa : Γ.slots[a]? = some sa) (hta : f.body.locals[a]? = some ta) (hpos : 0 < sa.size)
    (hpriv : ∀ k < sa.size, s0.st.escapedAt (sa.off + k) = none)
    (haddr : (pa.addr : Int) = s0.fp + sa.off)
    (hal : (Align.ofBytes al).exp ≤ ta.align.exp) :
    ∃ s', R.escape s0 sa.off sa.size al = .ok s' := by
  have hsz : ∀ e ∈ s0.st.escaped, 0 < e.size := fun e he => by
    obtain ⟨l, p, sl, -, -, -, hs, hp⟩ := hX.objs e he
    omega
  have hno := noObj_of_priv hpos hsz hpriv
  have hpaN : ((s0.fp : Int) + sa.off).toNat = pa.addr := by omega
  refine escape_ok_priv hpos hsz hpriv (by omega) ?_ ?_
  · rw [hpaN]
    have h0 := hX.aligned a pa ta hpa hta
    exact Nat.mod_eq_zero_of_dvd
      (Nat.dvd_trans (Nat.pow_dvd_pow 2 hal) (Nat.dvd_of_mod_eq_zero h0))
  · intro y hy hl
    obtain ⟨id, hg⟩ := Array.mem_iff_getElem?.1 hy
    rcases hX.free id y hg hl with ⟨e, he, -, hya, hys⟩ | hfr
    · have h1 := hno e he
      simp only [Allocation.size]
      omega
    · have h1 := hfr a sa hsa
      simp only [Allocation.size]
      omega

/-! ### Piece 2: the locals after an `Escape` of `_a`'s slot

The new state `st'` is `escape_rel`'s: the same frame, one more object `⟨off, size, id⟩`
(`id = st.mem.allocs.size`), the old allocations unchanged. `ι' = ι.extend [qa] id` for `_a`'s
allocation `qa`. -/

/-- Outside the new object, `escapedAt` is unchanged. -/
theorem escapedAt_append_apart {st st' : OpSem.State} {e : OpSem.EscapedObj} {o : Int}
    (hesc' : st'.escaped = st.escaped ++ [e]) (ho : ¬ (e.off ≤ o ∧ o < e.off + e.size)) :
    st'.escapedAt o = st.escapedAt o := by
  unfold OpSem.State.escapedAt
  rw [hesc', List.find?_append]
  cases hf : List.find? (fun e => decide (e.off ≤ o ∧ o < e.off + (e.size : Int))) st.escaped with
  | some e' => rfl
  | none =>
    have hd : decide (e.off ≤ o ∧ o < e.off + (e.size : Int)) = false := decide_eq_false ho
    simp only [Option.none_or, List.find?_cons, List.find?_nil, hd]

/-- `ι` extended at an allocation it doesn't map is larger. -/
theorem extend_le {ι : Inj} {qa n : AllocId} (hqa : ι qa = none) : ι.Le (ι.extend [qa] n) := by
  intro q b h
  by_cases hqq : q = qa
  · subst hqq
    rw [hqa] at h
    cases h
  · rw [escape_extend_not_mem (by simpa using hqq)]
    exact h

/-- Private allocations after the extension were private before. -/
theorem Hidden.escape {m0 : Memory} {ι : Inj} {f : Spec.Frame} {qa n : AllocId}
    (h : Hidden m0 (PrivAlloc ι f)) : Hidden m0 (PrivAlloc (ι.extend [qa] n) f) := by
  refine h.mono fun q hq => ?_
  obtain ⟨l, p, h1, h2, h3⟩ := hq
  refine ⟨l, p, h1, h2, ?_⟩
  by_cases hqq : q = qa
  · subst hqq
    rw [escape_extend_mem (by simp)] at h3
    cases h3
  · rw [escape_extend_not_mem (by simpa using hqq)] at h3
    exact h3

/-- No live L0 allocation holds `_a`'s (private) provenance. -/
theorem Hidden.of_priv {m0 : Memory} {ι : Inj} {f : Spec.Frame} {qa : AllocId}
    (h : Hidden m0 (PrivAlloc ι f)) (hq : PrivAlloc ι f qa) : Hidden m0 (· = qa) :=
  h.mono fun q e => by
    subst e
    exact hq

/-- Another local (slot apart from the new object, other provenance) keeps its relation. -/
theorem LocalRel.escape_other {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 : Memory}
    {sl : LocalSlot} {p : ThinPointer} {lv : Bool} {off : Int} {size : Nat} {qa : AllocId}
    (hr : LocalRel ι fp st m0 sl p lv) (hqa : ι qa = none)
    (hfr : st'.frame = st.frame)
    (hesc' : st'.escaped = st.escaped ++ [⟨off, size, st.mem.allocs.size⟩])
    (hmem : ∀ j, j < st.mem.allocs.size → st'.mem.get? j = st.mem.get? j)
    (hapart : sl.off + sl.size ≤ off ∨ off + size ≤ sl.off)
    (hq : p.prov ≠ some qa) (hhid : Hidden m0 (· = qa)) :
    LocalRel (ι.extend [qa] st.mem.allocs.size) fp st' m0 sl p lv := by
  have hext : ∀ q, q ≠ qa → ι.extend [qa] st.mem.allocs.size q = ι q := fun q hqq =>
    escape_extend_not_mem (by simpa using hqq)
  have hoff : ∀ k < sl.size, st'.escapedAt (sl.off + k) = st.escapedAt (sl.off + k) := by
    intro k hk
    exact escapedAt_append_apart hesc' (by first | (dsimp only; omega) | omega)
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    have haq : a ≠ qa := fun h => hq (by rw [hp, h])
    refine .priv a x hp (by rw [hext a haq]; exact hι) hx hlive haddr hpaddr hsize
      (fun k hk => by rw [hoff k hk]; exact hpriv k hk) (fun hl k hk => ?_)
    rw [hfr]
    refine ByteInj.mono (extend_le hqa) (hbytes hl k hk) (fun fr hf hn => ?_)
    have hne : fr.prov ≠ qa := hhid a x hx hlive k hk fr hf
    rw [hext _ hne]
    exact hn
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    have haq : a ≠ qa := fun h => hq (by rw [hp, h])
    obtain ⟨hlt, -⟩ := Array.getElem?_eq_some_iff.1 hy
    exact .esc a x e y hp (by rw [hext a haq]; exact hι) hx hlive haddr hpaddr hsize
      (fun k hk => by rw [hoff k hk]; exact hin k hk) (by rw [hmem _ hlt]; exact hy) hylive
      hyaddr hysize

/-- `_a` itself (private before, non-empty slot) becomes escaped into the new object. -/
theorem LocalRel.escape_self {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 : Memory}
    {sl : LocalSlot} {p : ThinPointer} {lv : Bool} {qa : AllocId} {y : Allocation}
    (hr : LocalRel ι fp st m0 sl p lv) (hp : p.prov = some qa) (hpos : 0 < sl.size)
    (hpriv : ∀ k < sl.size, st.escapedAt (sl.off + k) = none)
    (hesc' : st'.escaped = st.escaped ++ [⟨sl.off, sl.size, st.mem.allocs.size⟩])
    (hy : st'.mem.get? st.mem.allocs.size = some y) (hyl : y.live = true)
    (hya : (y.addr : Int) = fp + sl.off) (hys : y.data.size = sl.size) :
    LocalRel (ι.extend [qa] st.mem.allocs.size) fp st' m0 sl p lv := by
  cases hr with
  | priv a x hp' hι hx hlive haddr hpaddr hsize hpv hbytes =>
    have haq : a = qa := Option.some.inj (hp'.symm.trans hp)
    subst haq
    refine .esc a x ⟨sl.off, sl.size, st.mem.allocs.size⟩ y hp' (escape_extend_mem (by simp))
      hx hlive haddr hpaddr hsize (fun k hk => ?_) hy hyl hya hys
    have h0 := hpriv k hk
    unfold OpSem.State.escapedAt at h0 ⊢
    rw [hesc', List.find?_append, h0]
    first
      | (simp [hk]; done)
      | (simp; omega)
  | esc a x e y' hp' hι hx hlive haddr hpaddr hsize hin hy' hylive hyaddr hysize =>
    exact absurd ((hin 0 hpos).symm.trans (hpriv 0 hpos)) (fun h => by cases h)

/-! ### Piece 4 (start): the objects against a `StorageDead`'s slot -/

/-- Under `ShareOk`, every escaped object is exactly `_l`'s slot (and then `_l` is
storage-live in L0) or apart from it: objects are storage-live locals' slots (`objs`), and
another storage-live local's slot is disjoint from `_l`'s (`ShareOk` at the `StorageDead`,
`hst`). -/
theorem obj_slot_or_apart {Γ : TermCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s0 : R.RState} {bd : BlockData} {l : Local} {sl : LocalSlot}
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hle : f.stmt ≤ bd.stmts.length)
    (hsl : Γ.slots[l]? = some sl)
    (hst : bd.stmts[f.stmt]? = some (.storageDead l))
    (hmay : (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hshare : ShareOk Γ.body Γ.slots (computeStorage Γ.body).get)
    (hsl0 : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hrel : FnRelX Γ.toStmtCtx ι live f m0 s0) :
    ∀ e ∈ s0.st.escaped, (e.off = sl.off ∧ e.size = sl.size ∧ ∃ p, f.locals[l]? = some (some p)) ∨
      e.off + e.size ≤ sl.off ∨ sl.off + sl.size ≤ e.off := by
  intro e he
  obtain ⟨l', p, sl', hp, hsl', hoff, hsize, -⟩ := hrel.objs e he
  by_cases hl : l' = l
  · subst hl
    have hss : sl' = sl := Option.some.inj (hsl'.symm.trans hsl)
    subst hss
    exact .inl ⟨hoff, hsize, p, hp⟩
  · have hd := hshare f.bb bd hbd f.stmt l (.inr hst) l' (Ne.symm hl) (hsl0 l' p hp)
      sl sl' hsl hsl'
    right
    omega

/-- The `End`'s state before its `Uninit` write (`storageEnd`'s partition). -/
def endMid (s : R.RState) (off : Int) (size : Nat) : OpSem.State :=
  { s.st with
    mem := R.freeObjs s.st.mem
      (s.st.escaped.filter fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)),
    escaped := s.st.escaped.filter
      (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) }

/-- Step 1: an `End` succeeds when every object is inside its range or apart from it (the kept
objects then miss the range, so the `Uninit` write is private). -/
theorem storageEnd_ok_apart {s : R.RState} {off : Int} {size : Nat}
    (hap : ∀ e ∈ s.st.escaped, (off ≤ e.off ∧ e.off + e.size ≤ off + size) ∨
      e.off + e.size ≤ off ∨ off + size ≤ e.off) :
    ∃ st', R.storageEnd s off size = .ok { s with st := st' } ∧
      (endMid s off size).writeFrame off (List.replicate size .uninit) = .ok st' ∧
      ∀ i < size, (endMid s off size).escapedAt (off + i) = none := by
  have hpw : ∀ i < size, (endMid s off size).escapedAt (off + i) = none := by
    intro i hi
    unfold OpSem.State.escapedAt
    rw [List.find?_eq_none]
    intro e he hc
    simp only [endMid, List.mem_filter, Function.comp_apply, Bool.not_eq_true',
      decide_eq_false_iff_not] at he
    simp only [decide_eq_true_eq] at hc
    rcases hap e he.1 with h | h | h
    · exact he.2 h
    · omega
    · omega
  have hpw' : ∀ i < (List.replicate size AbstractByte.uninit).length,
      (endMid s off size).escapedAt (off + i) = none := by
    intro i hi
    rw [List.length_replicate] at hi
    exact hpw i hi
  obtain ⟨st', hw⟩ : ∃ st', (endMid s off size).writeFrame off
      (List.replicate size .uninit) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw']
    exact ⟨_, rfl⟩
  refine ⟨st', ?_, hw, hpw⟩
  have hw' : ({ s.st with
      mem := R.freeObjs s.st.mem
        (s.st.escaped.filter fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)),
      escaped := s.st.escaped.filter
        (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) } :
      OpSem.State).writeFrame off (List.replicate size .uninit) = .ok st' := hw
  unfold R.storageEnd
  simp only [List.partition_eq_filter_filter, bind, Except.bind]
  first
    | (rw [hw']; done)
    | (rw [hw']; rfl)
    | (simp only [hw']; done)
    | (simp only [hw']; rfl)
    | (simp [hw', pure, Except.pure])

/-- Step 2 (L0): `deallocate` kills exactly the pointer's allocation. -/
theorem dealloc_ok_at {m m' : Memory} {p : ThinPointer} {k : AllocationKind} {n : Nat}
    {al : Align} (h : m.deallocate p k n al = .ok m') {q : AllocId} (hq : p.prov = some q) :
    ∃ a, m.get? q = some a ∧ m' = { allocs := m.allocs.set! q { a with live := false } } := by
  rcases p with ⟨addr, _ | id⟩
  · cases hq
  · obtain rfl : id = q := Option.some.inj hq
    cases hg : m.get? id with
    | none =>
      exfalso
      simp only [Memory.deallocate, hg] at h
      all_goals exact absurd h (by intro e; cases e)
    | some a =>
      refine ⟨a, rfl, ?_⟩
      simp only [Memory.deallocate, hg] at h
      repeat' (split at h)
      all_goals first
        | exact (Except.ok.inj h).symm
        | exact absurd h (by intro e; cases e)

/-- After `deallocate`, the pointer's allocation is dead. -/
theorem dealloc_dead {m m' : Memory} {p : ThinPointer} {k : AllocationKind} {n : Nat}
    {al : Align} (h : m.deallocate p k n al = .ok m') {q : AllocId} (hq : p.prov = some q)
    {x : Allocation} (hx : m'.get? q = some x) : x.live = false := by
  obtain ⟨a, ha, rfl⟩ := dealloc_ok_at h hq
  rw [end_get?_set _ ha, if_pos rfl] at hx
  cases hx
  rfl

/-- A storage-live local's L0 allocation `a` (its pointer's provenance) is at its slot. -/
theorem local_alloc_at {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s0 : R.RState} (hrel : FnRel Γ ι live f m0 s0) {l : Local} {p : ThinPointer}
    {sl : LocalSlot} {a : AllocId} {x : Allocation} (hp : f.locals[l]? = some (some p))
    (hsl : Γ.slots[l]? = some sl) (hpa : p.prov = some a) (hx : m0.get? a = some x) :
    (x.addr : Int) = s0.fp + sl.off ∧ x.data.size = sl.size := by
  obtain ⟨sl', hsl', hr⟩ := hrel.frame.locals l p hp (by rw [hrel.unaliased]; simp)
  have hss : sl' = sl := Option.some.inj (hsl'.symm.trans hsl)
  subst hss
  cases hr with
  | priv a1 x1 hp1 _ hx1 _ haddr _ hsize =>
    have e1 : a1 = a := Option.some.inj (hp1.symm.trans hpa)
    subst e1
    have e2 : x1 = x := Option.some.inj (hx1.symm.trans hx)
    subst e2
    exact ⟨haddr, hsize⟩
  | esc a1 x1 e y hp1 _ hx1 _ haddr _ hsize =>
    have e1 : a1 = a := Option.some.inj (hp1.symm.trans hpa)
    subst e1
    have e2 : x1 = x := Option.some.inj (hx1.symm.trans hx)
    subst e2
    exact ⟨haddr, hsize⟩

/-- Step 3: `storageEnd_rel`'s premises for the `End` of a `StorageDead _l`, with L0's memory
`m0'` after the `StorageDead` (`hkeep`: allocations only die, addresses and sizes kept;
`hdead`: `_l`'s allocation, if `_l` was storage-live, is dead). -/
theorem end_premises {Γ : TermCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 m0' : Memory} {s0 : R.RState} {bd : BlockData} {l : Local} {sl : LocalSlot}
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hle : f.stmt ≤ bd.stmts.length)
    (hsl : Γ.slots[l]? = some sl)
    (hst : bd.stmts[f.stmt]? = some (.storageDead l))
    (hmay : (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hshare : ShareOk Γ.body Γ.slots (computeStorage Γ.body).get)
    (hsl0 : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hrel : FnRelX Γ.toStmtCtx ι live f m0 s0)
    (hkeep : ∀ q x', m0'.get? q = some x' → ∃ x, m0.get? q = some x ∧
      (x'.live = true → x.live = true) ∧ x'.addr = x.addr ∧ x'.data.size = x.data.size)
    (hdead : ∀ p, f.locals[l]? = some (some p) → ∀ q x', p.prov = some q →
      m0'.get? q = some x' → x'.live = false) :
    (∀ a b x e, ι a = some b → m0'.get? a = some x → e ∈ s0.st.escaped → e.id = b →
      sl.off ≤ e.off → e.off + e.size ≤ sl.off + sl.size → x.live = false) ∧
    (∀ a b x y e, ι a = some b → m0'.get? a = some x → x.live = true →
      s0.st.mem.get? b = some y → e ∈ s0.st.escaped → e.id = b →
      (x.addr : Int) + x.data.size ≤ s0.fp + sl.off ∨ s0.fp + sl.off + sl.size ≤ x.addr) ∧
    (∀ e y, e ∈ s0.st.escaped → s0.st.mem.get? e.id = some y →
      (y.addr : Int) = s0.fp + e.off) := by
  have hcase := obj_slot_or_apart hbd hle hsl hst hmay hshare hsl0 hrel
  refine ⟨fun a b x e hι hx he hid hc1 hc2 => ?_, fun a b x y e hι hx hl hy he hid => ?_,
    fun e y he hy => hrel.addrAt e he y hy⟩
  · cases hxl : x.live with
    | false => rfl
    | true =>
      exfalso
      obtain ⟨x0, hx0, hl0, -, -⟩ := hkeep a x hx
      obtain ⟨l2, p2, sl2, hp2, hpa2, hsl2, ho2, hs2⟩ :=
        hrel.owned a b x0 e hι hx0 (hl0 hxl) he hid
      have hpos' : 0 < e.size := by
        obtain ⟨l3, p3, sl3, -, -, -, hs3, hp3⟩ := hrel.objs e he
        omega
      rcases hcase e he with ⟨ho, hs, p, hp⟩ | h | h
      · by_cases hl2 : l2 = l
        · subst hl2
          have e1 : p2 = p := Option.some.inj (Option.some.inj (hp2.symm.trans hp))
          subst e1
          have := hdead p2 hp a x hpa2 hx
          rw [hxl] at this
          cases this
        · have hd := hshare f.bb bd hbd f.stmt l (.inr hst) l2 (Ne.symm hl2) (hsl0 l2 p2 hp2)
            sl sl2 hsl hsl2
          omega
      · omega
      · omega
  · obtain ⟨x0, hx0, hl0, hxa, hxs⟩ := hkeep a x hx
    obtain ⟨l2, p2, sl2, hp2, hpa2, hsl2, ho2, hs2⟩ :=
      hrel.owned a b x0 e hι hx0 (hl0 hl) he hid
    have hl2 : l2 ≠ l := by
      intro e1
      subst e1
      have := hdead p2 hp2 a x hpa2 hx
      rw [hl] at this
      cases this
    have hd := hshare f.bb bd hbd f.stmt l (.inr hst) l2 (Ne.symm hl2) (hsl0 l2 p2 hp2)
      sl sl2 hsl hsl2
    obtain ⟨hxaddr, hxsize⟩ := local_alloc_at hrel.rel hp2 hsl2 hpa2 hx0
    rw [hxa, hxs]
    omega

/-! ### Steps 4–5: the `End` against the relation -/

theorem end_kill_get {m : Memory} {id c : AllocId} {y : Allocation}
    (h : (end_kill m id).get? c = some y) :
    ∃ y0, m.get? c = some y0 ∧ y.addr = y0.addr ∧ y.data.size = y0.data.size ∧
      (y.live = true → y0.live = true ∧ c ≠ id) := by
  unfold end_kill at h
  cases ha : m.get? id with
  | none =>
    simp only [ha] at h
    refine ⟨y, h, rfl, rfl, fun hl => ⟨hl, fun hc => ?_⟩⟩
    rw [hc, ha] at h
    cases h
  | some a =>
    simp only [ha] at h
    rw [end_get?_set _ ha] at h
    by_cases hc : c = id
    · rw [if_pos hc] at h
      cases h
      exact ⟨a, by rw [hc]; exact ha, rfl, rfl, fun hl => by simp at hl⟩
    · rw [if_neg hc] at h
      exact ⟨y, h, rfl, rfl, fun hl => ⟨hl, hc⟩⟩

theorem freeObjs_get : ∀ (es : List EscapedObj) (m : Memory) {c : AllocId} {y : Allocation},
    (R.freeObjs m es).get? c = some y →
    ∃ y0, m.get? c = some y0 ∧ y.addr = y0.addr ∧ y.data.size = y0.data.size ∧
      (y.live = true → y0.live = true ∧ ∀ e ∈ es, e.id ≠ c)
  | [], m, c, y, h => ⟨y, h, rfl, rfl, fun hl => ⟨hl, fun e he => by cases he⟩⟩
  | e :: es, m, c, y, h => by
    rw [end_freeObjs_cons] at h
    obtain ⟨y1, h1, a1, s1, l1⟩ := freeObjs_get es (end_kill m e.id) h
    obtain ⟨y0, h0, a0, s0, l0⟩ := end_kill_get h1
    refine ⟨y0, h0, a1.trans a0, s1.trans s0, fun hl => ?_⟩
    obtain ⟨hl1, hne1⟩ := l1 hl
    obtain ⟨hl0, hne0⟩ := l0 hl1
    refine ⟨hl0, fun e' he' => ?_⟩
    rcases List.mem_cons.1 he' with rfl | he'
    · exact fun h' => hne0 h'.symm
    · exact hne1 e' he'

theorem end_kill_size (m : Memory) (id : AllocId) :
    (end_kill m id).allocs.size = m.allocs.size := by
  unfold end_kill
  split <;> simp

theorem freeObjs_size : ∀ (es : List EscapedObj) (m : Memory),
    (R.freeObjs m es).allocs.size = m.allocs.size
  | [], _ => rfl
  | e :: es, m => by rw [end_freeObjs_cons, freeObjs_size es, end_kill_size]

theorem freeObjs_get_other : ∀ (es : List EscapedObj) (m : Memory) {c : AllocId},
    (∀ e ∈ es, e.id ≠ c) → (R.freeObjs m es).get? c = m.get? c
  | [], _, _, _ => rfl
  | e :: es, m, c, h => by
    rw [end_freeObjs_cons,
      freeObjs_get_other es _ (fun e' he' => h e' (List.mem_cons_of_mem _ he'))]
    unfold end_kill
    cases ha : m.get? e.id with
    | none => rfl
    | some a =>
      show (⟨m.allocs.set! e.id { a with live := false }⟩ : Memory).get? c = m.get? c
      rw [end_get?_set _ ha, if_neg (fun hc => h e (List.mem_cons_self ..) hc.symm)]

theorem find?_filter_of {l : List EscapedObj} {p q : EscapedObj → Bool} {e : EscapedObj}
    (h : l.find? p = some e) (hq : q e = true) : (l.filter q).find? p = some e := by
  induction l with
  | nil => cases h
  | cons x xs ih =>
    simp only [List.find?_cons] at h
    cases hpx : p x with
    | true =>
      simp only [hpx, Option.some.injEq] at h
      subst h
      simp [List.filter_cons, hq, List.find?_cons, hpx]
    | false =>
      simp only [hpx] at h
      have h2 := ih h
      by_cases hqx : q x = true
      · simp [List.filter_cons, hqx, List.find?_cons, hpx, h2]
      · simp [List.filter_cons, hqx, h2]

theorem find?_of_filter {l : List EscapedObj} {p q : EscapedObj → Bool} {e : EscapedObj}
    (h : (l.filter q).find? p = some e) : e ∈ l ∧ q e = true ∧ p e = true := by
  have hm := List.mem_of_find?_eq_some h
  rw [List.mem_filter] at hm
  exact ⟨hm.1, hm.2, List.find?_some h⟩

theorem find?_filter_none {l : List EscapedObj} {p q : EscapedObj → Bool}
    (h : l.find? p = none) : (l.filter q).find? p = none :=
  List.find?_eq_none.2 fun x hx => List.find?_eq_none.1 h x (List.mem_filter.1 hx).1

/-- A storage-live local's L0 allocation is live. -/
theorem LocalRel.alloc_live {ι : Inj} {fp : Nat} {st : OpSem.State} {m0 : Memory}
    {sl : LocalSlot} {p : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 sl p lv) :
    ∃ a x, p.prov = some a ∧ m0.get? a = some x ∧ x.live = true := by
  cases hr with
  | priv a x hp _ hx hlive => exact ⟨a, x, hp, hx, hlive⟩
  | esc a x e y hp _ hx hlive => exact ⟨a, x, hp, hx, hlive⟩

/-- Step 4 (i): a local whose mapped id no freed object has keeps its relation in `endMid`. -/
theorem LocalRel.endMid {ι : Inj} {fp : Nat} {s0 : R.RState} {m0 : Memory} {sl' : LocalSlot}
    {p : ThinPointer} {lv : Bool} {off : Int} {size : Nat}
    (hr : LocalRel ι fp s0.st m0 sl' p lv)
    (hfree : ∀ q b, p.prov = some q → ι q = some b → ∀ g ∈ s0.st.escaped,
      off ≤ g.off → g.off + g.size ≤ off + size → g.id ≠ b) :
    LocalRel ι fp (endMid s0 off size) m0 sl' p lv := by
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    refine .priv a x hp hι hx hlive haddr hpaddr hsize (fun k hk => ?_) hbytes
    have h0 := hpriv k hk
    unfold OpSem.State.escapedAt at h0 ⊢
    exact find?_filter_none h0
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    have hgone : ∀ g ∈ s0.st.escaped.filter
        (fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)), g.id ≠ e.id := by
      intro g hg
      obtain ⟨hg1, hg2⟩ := List.mem_filter.1 hg
      simp only [decide_eq_true_eq] at hg2
      exact hfree a e.id hp hι g hg1 hg2.1 hg2.2
    refine .esc a x e y hp hι hx hlive haddr hpaddr hsize (fun k hk => ?_) ?_ hylive hyaddr
      hysize
    · have h0 := hin k hk
      have hm := (end_escapedAt_some h0).1
      have hnc : (not ∘ fun e => decide (off ≤ e.off ∧ e.off + e.size ≤ off + size)) e =
          true := by
        simp only [Function.comp_apply, Bool.not_eq_true', decide_eq_false_iff_not]
        intro hc
        exact hfree a e.id hp hι e hm hc.1 hc.2 rfl
      unfold OpSem.State.escapedAt at h0 ⊢
      exact find?_filter_of h0 hnc
    · show (R.freeObjs s0.st.mem _).get? e.id = some y
      rw [freeObjs_get_other _ _ hgone]
      exact hy

/-- Step 5: `FnRelX` after a `StorageDead _l` and its `End` (L0's frame `f'` and memory
`m0'`, R's state after `storageEnd`). -/
theorem end_fnRelX {Γ : TermCtx} {ι : Inj} {live live' : Local → Bool} {f f' : Spec.Frame}
    {m0 m0' : Memory} {s0 : R.RState} {bd : BlockData} {l : Local} {sl : LocalSlot}
    {st' : OpSem.State}
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hle : f.stmt ≤ bd.stmts.length)
    (hsl : Γ.slots[l]? = some sl)
    (hst : bd.stmts[f.stmt]? = some (.storageDead l))
    (hmay : (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hshare : ShareOk Γ.body Γ.slots (computeStorage Γ.body).get)
    (hsl0 : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hrel : FnRelX Γ.toStmtCtx ι live f m0 s0)
    (hfn : FnRel Γ.toStmtCtx ι live' f' m0' s0)
    (hloc : ∀ l' p', f'.locals[l']? = some (some p') → f.locals[l']? = some (some p') ∧ l' ≠ l)
    (hloc' : ∀ l' p', f.locals[l']? = some (some p') → l' ≠ l → f'.locals[l']? = some (some p'))
    (hbody' : f'.body = f.body)
    (hkeep : ∀ q x', m0'.get? q = some x' → ∃ x, m0.get? q = some x ∧
      (x'.live = true → x.live = true) ∧ x'.addr = x.addr ∧ x'.data.size = x.data.size)
    (hdead : ∀ p, f.locals[l]? = some (some p) → ∀ q x', p.prov = some q →
      m0'.get? q = some x' → x'.live = false)
    (hSE : R.storageEnd s0 sl.off sl.size = .ok { s0 with st := st' })
    (hw : (endMid s0 sl.off sl.size).writeFrame sl.off (List.replicate sl.size .uninit) =
      .ok st')
    (hpw : ∀ i < sl.size, (endMid s0 sl.off sl.size).escapedAt (sl.off + i) = none) :
    FnRelX Γ.toStmtCtx ι live' f' m0' { s0 with st := st' } := by
  have hcase := obj_slot_or_apart hbd hle hsl hst hmay hshare hsl0 hrel
  obtain ⟨hgone, hapart, hat⟩ := end_premises hbd hle hsl hst hmay hshare hsl0 hrel hkeep hdead
  have hpw' : ∀ i < (List.replicate sl.size AbstractByte.uninit).length,
      (endMid s0 sl.off sl.size).escapedAt (sl.off + i) = none := by
    intro i hi
    rw [List.length_replicate] at hi
    exact hpw i hi
  obtain ⟨hmemW, heaW, -⟩ := writeFrame_private_eq hw hpw'
  have hescW : st'.escaped = (endMid s0 sl.off sl.size).escaped :=
    (Ryo.Proofs.OpFacts.writeFrame_keeps hw).1
  have hmi := storageEnd_rel hSE hfn.frame.mem hgone hapart hat
  -- kept objects
  have hkept : ∀ e, e ∈ st'.escaped → e ∈ s0.st.escaped ∧
      ¬ (sl.off ≤ e.off ∧ e.off + e.size ≤ sl.off + sl.size) := by
    intro e he
    rw [hescW] at he
    simp only [endMid, List.mem_filter, Function.comp_apply, Bool.not_eq_true',
      decide_eq_false_iff_not] at he
    exact he
  have hmemE : st'.mem = R.freeObjs s0.st.mem (s0.st.escaped.filter
      fun e => decide (sl.off ≤ e.off ∧ e.off + e.size ≤ sl.off + sl.size)) := hmemW
  -- a storage-live local of `f'` other than `_l`: no freed object has its mapped id
  have hfreeL : ∀ (l' : Local) (p' : ThinPointer), f'.locals[l']? = some (some p') →
      ∀ q b, p'.prov = some q →
      ι q = some b → ∀ g ∈ s0.st.escaped, sl.off ≤ g.off →
        g.off + g.size ≤ sl.off + sl.size → g.id ≠ b := by
    intro l' p' hp' q b hq hb g hg hc1 hc2 hid
    obtain ⟨hp0, hne⟩ := hloc l' p' hp'
    obtain ⟨sl', hsl', hr⟩ := hrel.rel.frame.locals l' p' hp0 (by rw [hrel.rel.unaliased]; simp)
    obtain ⟨a1, x1, hp1, hx1, hl1⟩ := hr.alloc_live
    have e1 : a1 = q := Option.some.inj (hp1.symm.trans hq)
    subst e1
    obtain ⟨l3, p3, sl3, hp3, hpa3, hsl3, ho3, hs3⟩ := hrel.owned a1 b x1 g hb hx1 hl1 hg hid
    have hgpos : 0 < g.size := by
      obtain ⟨l4, p4, sl4, -, -, -, hs4, hp4⟩ := hrel.objs g hg
      omega
    have hl3 : l3 = l' := by
      by_cases hc : l3 = l'
      · exact hc
      · exact absurd (by rw [hpa3, hq]) (hrel.rel.provNe l3 l' p3 p' hc hp3 hp0)
    subst hl3
    have hss : sl3 = sl' := Option.some.inj (hsl3.symm.trans hsl')
    subst hss
    rcases hcase g hg with ⟨ho, hs, -⟩ | h | h
    · have hd := hshare f.bb bd hbd f.stmt l (.inr hst) l3 (Ne.symm hne) (hsl0 l3 p' hp0)
        sl sl3 hsl hsl3
      omega
    · omega
    · omega
  refine ⟨⟨⟨hmi, fun l' p' hp' hal' => ?_⟩, hfn.hidden, hfn.unaliased, hfn.provNe, hfn.apart,
      fun o e h => ?_⟩, fun e he => ?_, ?_, fun q b x e hq hx hl he hid => ?_,
      fun j y hy hl => ?_, fun l' p' ty hp' hty => ?_, fun e he => ?_, fun e he y hy => ?_⟩
  · -- the locals
    obtain ⟨sl', hsl', hr⟩ := hfn.frame.locals l' p' hp' hal'
    refine ⟨sl', hsl', ?_⟩
    obtain ⟨hp0, hne⟩ := hloc l' p' hp'
    have hd := hshare f.bb bd hbd f.stmt l (.inr hst) l' (Ne.symm hne) (hsl0 l' p' hp0)
      sl sl' hsl hsl'
    have hr1 := LocalRel.endMid (off := sl.off) (size := sl.size) hr (hfreeL l' p' hp')
    exact LocalRel.writeFrame_apart hr1 hw hpw' (by rw [List.length_replicate]; exact hd)
  · -- `esc`
    have h1 : (endMid s0 sl.off sl.size).escapedAt o = some e := by
      rw [← heaW]; exact h
    unfold OpSem.State.escapedAt at h1
    obtain ⟨hm, -, hpe⟩ := find?_of_filter h1
    cases hf : s0.st.escapedAt o with
    | none =>
      unfold OpSem.State.escapedAt at hf
      exact absurd hpe (List.find?_eq_none.1 hf e hm)
    | some e' => exact hfn.esc o e' hf
  · -- `objs`
    obtain ⟨he0, hnc⟩ := hkept e he
    obtain ⟨l2, p2, sl2, hp2, hsl2, ho2, hs2, hpos⟩ := hrel.objs e he0
    have hl2 : l2 ≠ l := by
      intro e1
      subst e1
      have hss : sl2 = sl := Option.some.inj (hsl2.symm.trans hsl)
      subst hss
      exact hnc ⟨by omega, by omega⟩
    exact ⟨l2, p2, sl2, hloc' l2 p2 hp2 hl2, hsl2, ho2, hs2, hpos⟩
  · -- `disj`
    show List.Pairwise _ st'.escaped
    rw [hescW]
    exact hrel.disj.filter _
  · -- `owned`
    obtain ⟨he0, -⟩ := hkept e he
    obtain ⟨x0, hx0, hl0, -, -⟩ := hkeep q x hx
    obtain ⟨l3, p3, sl3, hp3, hpa3, hsl3, ho3, hs3⟩ := hrel.owned q b x0 e hq hx0 (hl0 hl) he0 hid
    have hl3 : l3 ≠ l := by
      intro e1
      subst e1
      have := hdead p3 hp3 q x hpa3 hx
      rw [hl] at this
      cases this
    exact ⟨l3, p3, sl3, hloc' l3 p3 hp3 hl3, hpa3, hsl3, ho3, hs3⟩
  · -- `free`
    have hy' : (R.freeObjs s0.st.mem (s0.st.escaped.filter fun e =>
        decide (sl.off ≤ e.off ∧ e.off + e.size ≤ sl.off + sl.size))).get? j = some y := by
      have h2 : st'.mem.get? j = some y := hy
      rw [hmemE] at h2
      exact h2
    obtain ⟨y0, hy0, hya, hys, hyl⟩ := freeObjs_get _ _ hy'
    obtain ⟨hl0, hng⟩ := hyl hl
    rcases hrel.free j y0 hy0 hl0 with ⟨e, he, h1, h2, h3⟩ | hfr
    · refine .inl ⟨e, ?_, h1, by rw [hya]; exact h2, by rw [hys]; exact h3⟩
      show e ∈ st'.escaped
      rw [hescW]
      simp only [endMid, List.mem_filter, Function.comp_apply, Bool.not_eq_true',
        decide_eq_false_iff_not]
      refine ⟨he, fun hc => hng e ?_ h1⟩
      exact List.mem_filter.2 ⟨he, by simp only [decide_eq_true_eq]; exact hc⟩
    · refine .inr fun l2 sl2 hsl2 => ?_
      rw [hya, hys]
      exact hfr l2 sl2 hsl2
  · -- `aligned`
    rw [hbody'] at hty
    exact hrel.aligned l' p' ty (hloc l' p' hp').1 hty
  · -- `idLt`
    obtain ⟨he0, -⟩ := hkept e he
    show e.id < st'.mem.allocs.size
    rw [hmemE, freeObjs_size]
    exact hrel.idLt e he0
  · -- `addrAt`
    obtain ⟨he0, -⟩ := hkept e he
    have hy' : (R.freeObjs s0.st.mem (s0.st.escaped.filter fun e =>
        decide (sl.off ≤ e.off ∧ e.off + e.size ≤ sl.off + sl.size))).get? e.id = some y := by
      have h2 : st'.mem.get? e.id = some y := hy
      rw [hmemE] at h2
      exact h2
    obtain ⟨y0, hy0, hya, -, -⟩ := freeObjs_get _ _ hy'
    rw [hya]
    exact hrel.addrAt e he0 y0 hy0

/-- A `StorageDead _l` with an `End` of `_l`'s slot (`endSpec`): L0 frees `_l`'s allocation and
R's `End` succeeds, freeing exactly `_l`'s object (if `_l` escaped), and `FnRelX` holds after
both.

Proof: L0 by `storageDead_live`/`storageDead_dead` (as `lift_storageDead`). R: `storageEnd`
succeeds (`writeEscaped` meets only objects of live locals, which have allocations, `objs` +
`LocalRel.esc.hy`; the objects partly inside `_l`'s slot are none: `objs` + `apart` + `ShareOk`
at `(b, i)` with `hmay`, which makes every storage-live local's slot disjoint from `_l`'s). Then
`storageEnd_rel` for `MemInj`: `hgone` from `owned` (only `_l`'s allocation maps into its
object, now dead), `hapart` from `owned` + `apart`, `hat` from `objs` + `LocalRel.esc.hyaddr`.
The other locals' `LocalRel` by their slots' disjointness from `_l`'s (frame bytes and
`escapedAt` there unchanged; their objects kept). `objs`, `disj`, `owned`: `_l`'s object is
gone. `free`: freed objects are dead, others unchanged (`end_freeObjs_rel`'s addresses).
`Hidden`: as `lift_storageDead` (`Hidden.dealloc`). -/
theorem scope_end_rel {Γ : TermCtx} {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} {s0 : R.RState}
    {bd : BlockData} {l : Local} {sl : LocalSlot} {sc : R.Scope}
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbd : Γ.body.blocks[f.bb]? = some bd)
    (hst : bd.stmts[f.stmt]? = some (.storageDead l)) (hsl : Γ.slots[l]? = some sl)
    (hend : ScopeSpec.ok (.endS sl.off sl.size) sc = true)
    (hmay : (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hshare : ShareOk Γ.body Γ.slots (computeStorage Γ.body).get)
    (hsl0 : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hrel : FnRelX Γ.toStmtCtx ι live f s.mem s0)
    (hlive' : ∀ l', live' l' = true → live l' = true)
    (h : runOn (evalStatement (.storageDead l)) o s = (.ok (), s')) :
    ∃ s0' f', R.applyScope s0 sc = .ok s0' ∧ s'.stack = f' :: rest ∧ f'.body = f.body ∧
      f'.bb = f.bb ∧ f'.stmt = f.stmt ∧ FnRelX Γ.toStmtCtx ι live' f' s'.mem s0' := by
  have hle : f.stmt ≤ bd.stmts.length := by
    rcases Nat.lt_or_ge f.stmt bd.stmts.length with h' | h'
    · omega
    · simp [List.getElem?_eq_none h'] at hst
  obtain ⟨hk, ho, hn⟩ := specsOk_endS hend
  have hA : R.applyScope s0 sc = R.storageEnd s0 sl.off sl.size := by
    unfold R.applyScope
    rw [hk]
    simp only [ho, hn]
  have hcase := obj_slot_or_apart hbd hle hsl hst hmay hshare hsl0 hrel
  obtain ⟨st', hSE, hw, hpw⟩ := storageEnd_ok_apart (s := s0) (off := sl.off) (size := sl.size)
    (fun e he => by
      rcases hcase e he with ⟨h1, h2, -⟩ | h1 | h1
      · exact .inl ⟨by omega, by omega⟩
      · exact .inr (.inl h1)
      · exact .inr (.inr h1))
  obtain ⟨f', hstk, hb', hbb', hst', hfn⟩ := lift_storageDead hs hrel.rel hlive' h
  have h' : runOn (storageDead l) o s = (.ok (), s') := h
  refine ⟨{ s0 with st := st' }, f', by rw [hA]; exact hSE, hstk, hb', hbb', hst', ?_⟩
  by_cases hl : ∃ p, f.locals[l]? = some (some p)
  · obtain ⟨p, hp⟩ := hl
    obtain ⟨ty, m', -, hd, hs'⟩ :=
      storageDead_live hs hp (by rw [hrel.rel.unaliased]; rfl) h'
    have h2 : ({ f with locals := f.locals.set! l none, aliased := f.aliased.erase l } ::
        rest) = f' :: rest := by
      rw [← hstk, hs']
    have hf' := (List.cons.inj h2).1
    subst hf'
    have hmem' : s'.mem = m' := by rw [hs']
    obtain ⟨sl1, hsl1, hr1⟩ := hrel.rel.frame.locals l p hp (by rw [hrel.rel.unaliased]; simp)
    obtain ⟨q0, x0, hq0, -, -⟩ := hr1.alloc_live
    obtain ⟨a0, ha0, hm0⟩ := dealloc_ok_at hd hq0
    refine end_fnRelX hbd hle hsl hst hmay hshare hsl0 hrel hfn (fun l' p' hp' => ?_)
      (fun l' p' hp' hne => ?_) rfl (fun q x' hx' => ?_) (fun p' hp' q x' hq hx' => ?_) hSE hw hpw
    · by_cases e : l' = l
      · subst e
        exact absurd (getElem?_set!_self hp') (by simp)
      · exact ⟨by rw [← getElem?_set!_ne e]; exact hp', e⟩
    · show (f.locals.set! l none)[l']? = some (some p')
      rw [getElem?_set!_ne hne]
      exact hp'
    · rw [hmem', hm0, end_get?_set _ ha0] at hx'
      by_cases hq : q = q0
      · rw [if_pos hq] at hx'
        cases hx'
        exact ⟨a0, by rw [hq]; exact ha0, fun h3 => by simp at h3, rfl, rfl⟩
      · rw [if_neg hq] at hx'
        exact ⟨x', hx', id, rfl, rfl⟩
    · have e1 : p' = p := Option.some.inj (Option.some.inj (hp'.symm.trans hp))
      subst e1
      rw [hmem'] at hx'
      exact dealloc_dead hd hq hx'
  · have hl' : ∀ p, f.locals[l]? ≠ some (some p) := fun p hp => hl ⟨p, hp⟩
    rw [storageDead_dead hs hl'] at h'
    obtain ⟨-, hss⟩ := prod_ok_inj h'
    subst hss
    have hf' : f' = f := by
      have h2 : f :: rest = f' :: rest := by rw [← hstk, hs]
      exact (List.cons.inj h2).1.symm
    subst hf'
    refine end_fnRelX hbd hle hsl hst hmay hshare hsl0 hrel hfn (fun l' p' hp' => ⟨hp', ?_⟩)
      (fun l' p' hp' _ => hp') rfl (fun q x' hx' => ⟨x', hx', id, rfl, rfl⟩)
      (fun p hp => absurd hp (hl' p)) hSE hw hpw
    intro e
    subst e
    exact hl' p' hp'

/-- The `Escape` of a storage-live local `_a`'s whole slot (a `ref`'s own scope, `ownSpec`):
it succeeds, and afterwards `_a` is escaped (its slot inside one object) and `FnRelX` holds for
`ι'`, which extends `ι` at most by `_a`'s allocation.

Proof: by `_a`'s `LocalRel` (`FnRel.opnd` at `hla`).
- `esc`: some object `e` contains the slot (`hin`, `end_escapedAt_some`), so `escape` returns
  its state (first test); `ι' = ι`.
- `priv`: no object meets the slot (`hpriv`; `objs` + `disj` rule out a partial overlap,
  `escape`'s second test); `frameAddr` is `x.addr ≥ 0` (`haddr`); the alignment from `aligned`
  and `specsOk_escS`'s bound (`2 ^ e ∣ 2 ^ ta.align.exp`); no live allocation overlaps
  (`free`: a frame object would contradict `hpriv`); `readFrame` of private bytes succeeds. Then
  `escape_ok_new` and `escape_rel` with `as = [a]` (`has` from `hbytes` at `true`,
  `ByteInj.mono`; `hhid` from `hrel.rel.hidden`, `a` being `PrivAlloc`), `ι' = ι.extend [a] id`.
  `_a` becomes `LocalRel.esc` with the new object; other private locals keep `priv` (`ι' = ι`
  off `a`; their bytes don't carry `a`, `Hidden`); `FnRel.esc` from `hesc`; `objs` (the new
  object is `_a`'s slot), `disj` (`apart`), `owned` (only `a` maps to the new id), `free` (the
  new allocation is a frame object). -/
theorem scope_escape_rel {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s0 : R.RState} {a : Local} {pa : ThinPointer} {sa : LocalSlot}
    {ta : Spec.Ty} {sc : R.Scope}
    (hrel : FnRelX Γ ι live f m0 s0) (hpa : f.locals[a]? = some (some pa))
    (hsa : Γ.slots[a]? = some sa) (hta : f.body.locals[a]? = some ta) (hla : live a = true)
    (hpos : 0 < sa.size) (hesc : ∀ k < sa.size, Γ.escaped (sa.off + k) = true)
    (hsc : ScopeSpec.ok (.escS sa.off sa.size ta.align.exp) sc = true)
    (hfresh : ∀ q, m0.allocs.size ≤ q → ι q = none) :
    ∃ ι' s0', R.applyScope s0 sc = .ok s0' ∧ ι.Le ι' ∧
      (∀ q, pa.prov ≠ some q → ι' q = ι q) ∧
      s0'.pc = s0.pc ∧ s0'.fp = s0.fp ∧ s0'.args = s0.args ∧
      FnRelX Γ ι' live f m0 s0' ∧
      ∃ e, ∀ k < sa.size, s0'.st.escapedAt (sa.off + k) = some e := by
  obtain ⟨al, hk, ho, hn, hal⟩ := specsOk_escS hsc
  have hA : R.applyScope s0 sc = R.escape s0 sa.off sa.size al := by
    unfold R.applyScope
    rw [hk]
    simp only [ho, hn]
  have hnal : a ∉ f.aliased := by
    rw [hrel.rel.unaliased]
    simp
  obtain ⟨slot, hslot, hr⟩ := hrel.rel.frame.locals a pa hpa hnal
  have hss : slot = sa := Option.some.inj (hslot.symm.trans hsa)
  subst hss
  cases hr with
  | esc a' x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    -- Already escaped: `escape` is a no-op.
    have hany : (s0.st.escaped.any fun e =>
        decide (e.off ≤ slot.off ∧ slot.off + slot.size ≤ e.off + e.size)) = true := by
      rw [List.any_eq_true]
      obtain ⟨hm1, hl1, -⟩ := end_escapedAt_some (hin 0 hpos)
      obtain ⟨-, -, hh1⟩ := end_escapedAt_some (hin (slot.size - 1) (by omega))
      exact ⟨e, hm1, by simp only [decide_eq_true_eq]; omega⟩
    have hE : R.escape s0 slot.off slot.size al = .ok s0 := by
      unfold R.escape
      first
        | (simp only [hany, ↓reduceIte]; done)
        | (simp only [hany, ↓reduceIte]; rfl)
        | (simp [hany]; done)
    exact ⟨ι, s0, by rw [hA, hE], fun _ _ h => h, fun _ _ => rfl, rfl, rfl, rfl, hrel, e, hin⟩
  | priv a' x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    have hpaddr' : (pa.addr : Int) = s0.fp + slot.off := by omega
    obtain ⟨s0', hE⟩ := escape_ok_of_relX hrel hpa hsa hta hpos hpriv hpaddr' hal
    have hpriv0 : s0.st.escapedAt slot.off = none := by simpa using hpriv 0 hpos
    obtain ⟨bytes, A, hs0', -, -, -, -, -, -⟩ := escape_ok_new hE hpriv0 (by omega)
    have hqa : PrivAlloc ι f a' := ⟨a, pa, hpa, hp, hι⟩
    have hhidA : Hidden m0 (· = a') := Hidden.of_priv hrel.rel.hidden hqa
    have hhid : Hidden m0 (· ∈ [a']) := hhidA.mono fun q hq => by simpa using hq
    obtain ⟨hm', hesc', y, hy, hyl, hya, hys, hfr, hfp⟩ :=
      escape_rel hE hrel.rel.frame.mem hpriv (by omega) [a'] (fun q hq => by
        rw [List.mem_singleton] at hq
        subst hq
        refine ⟨hι, x, hx, hlive, by omega, by omega, fun k hk => ?_⟩
        have e1 : (x.addr : Int) - s0.fp + k = slot.off + k := by omega
        rw [e1]
        exact ByteInj.mono (extend_le hι) (hbytes hla k hk) (fun fr hf hn => by
          have hne : fr.prov ≠ q := hhidA q x hx hlive k hk fr hf
          rw [escape_extend_not_mem (by simpa using hne)]
          exact hn)) hhid
    have hget : ∀ j, s0'.st.mem.get? j =
        if j = s0.st.mem.allocs.size then some A else s0.st.mem.get? j := by
      intro j
      rw [hs0']
      show (s0.st.mem.allocs.push A)[j]? = _
      exact Array.getElem?_push
    have hmem : ∀ j, j < s0.st.mem.allocs.size → s0'.st.mem.get? j = s0.st.mem.get? j := by
      intro j hj
      rw [hget, if_neg (Nat.ne_of_lt hj)]
    have hsz' : s0'.st.mem.allocs.size = s0.st.mem.allocs.size + 1 := by
      rw [hs0']
      simp
    have hno := noObj_of_priv hpos (fun e he => by
      obtain ⟨l, p, sl, -, -, -, hs, hp'⟩ := hrel.objs e he
      omega) hpriv
    have hfrel : FrameRel (ι.extend [a'] s0.st.mem.allocs.size) Γ.slots live f m0 s0' := by
      refine ⟨hm', fun l p hp' hal' => ?_⟩
      by_cases hla' : l = a
      · rw [hla'] at hp' ⊢
        have hpp : pa = p := Option.some.inj (Option.some.inj (hpa.symm.trans hp'))
        subst hpp
        refine ⟨slot, hsa, ?_⟩
        rw [hfp]
        exact LocalRel.escape_self (.priv a' x hp hι hx hlive haddr hpaddr hsize hpriv hbytes)
          hp hpos hpriv hesc' hy hyl hya hys
      · obtain ⟨sl, hsl, hr'⟩ := hrel.rel.frame.locals l p hp' hal'
        refine ⟨sl, hsl, ?_⟩
        rw [hfp]
        have hap := hrel.rel.apart l a p pa sl slot hla' hp' hpa hsl hsa
        have hpn := hrel.rel.provNe l a p pa hla' hp' hpa
        exact LocalRel.escape_other hr' hι hfr hesc' hmem hap (by rw [← hp]; exact hpn) hhidA
    have hfnrel : FnRel Γ (ι.extend [a'] s0.st.mem.allocs.size) live f m0 s0' := by
      refine ⟨hfrel, Hidden.escape hrel.rel.hidden, hrel.rel.unaliased, hrel.rel.provNe,
        hrel.rel.apart, fun o e h => ?_⟩
      unfold OpSem.State.escapedAt at h
      rw [hesc', List.find?_append] at h
      cases hf : List.find? (fun e => decide (e.off ≤ o ∧ o < e.off + (e.size : Int)))
          s0.st.escaped with
      | some e' =>
        exact hrel.rel.esc o e' (by unfold OpSem.State.escapedAt; exact hf)
      | none =>
        rw [hf] at h
        simp only [Option.none_or] at h
        have hm := List.mem_of_find?_eq_some h
        rw [List.mem_singleton] at hm
        subst hm
        have h2 := List.find?_some h
        simp only [decide_eq_true_eq] at h2
        have hk' := hesc (o - slot.off).toNat (by first | (dsimp only at h2; omega) | omega)
        have e2 : slot.off + ((o - slot.off).toNat : Int) = o := by
          first | (dsimp only at h2; omega) | omega
        rw [e2] at hk'
        exact hk'
    refine ⟨ι.extend [a'] s0.st.mem.allocs.size, s0', by rw [hA]; exact hE, extend_le hι,
      fun q hq => escape_extend_not_mem (by
        intro hm
        rw [List.mem_singleton] at hm
        subst hm
        exact hq hp),
      by rw [hs0'], hfp, by rw [hs0'], ?_, ?_⟩
    · refine ⟨hfnrel, fun e he => ?_, ?_, fun q b x' e hq hx' hl he hid => ?_,
        fun j y' hj hl => ?_, hrel.aligned, fun e he => ?_, fun e he y' hy' => ?_⟩
      · rw [hesc', List.mem_append, List.mem_singleton] at he
        rcases he with he | rfl
        · exact hrel.objs e he
        · exact ⟨a, pa, slot, hpa, hsa, rfl, rfl, hpos⟩
      · rw [hesc', List.pairwise_append]
        refine ⟨hrel.disj, List.pairwise_singleton _ _, fun e he e' he' => ?_⟩
        rw [List.mem_singleton] at he'
        subst he'
        have h1 := hno e he
        first | (dsimp only; omega) | omega
      · rw [hesc', List.mem_append, List.mem_singleton] at he
        by_cases hqa' : q = a'
        · rw [hqa', escape_extend_mem (by simp)] at hq
          have hb : b = s0.st.mem.allocs.size := (Option.some.inj hq).symm
          rcases he with he | rfl
          · have h1 := hrel.idLt e he
            rw [hid, hb] at h1
            exact absurd h1 (Nat.lt_irrefl _)
          · exact ⟨a, pa, slot, hpa, by rw [hp, hqa'], hsa, rfl, rfl⟩
        · rw [escape_extend_not_mem (by simpa using hqa')] at hq
          rcases he with he | rfl
          · exact hrel.owned q b x' e hq hx' hl he hid
          · obtain ⟨yy, hyy, -⟩ := hrel.rel.frame.mem q b x' hx' hq
            obtain ⟨hlt, -⟩ := Array.getElem?_eq_some_iff.1 hyy
            have hb' : b = s0.st.mem.allocs.size := hid.symm
            rw [hb'] at hlt
            exact absurd hlt (Nat.lt_irrefl _)
      · by_cases hjs : j = s0.st.mem.allocs.size
        · subst hjs
          have hyy : y' = y := Option.some.inj (hj.symm.trans hy)
          subst hyy
          refine .inl ⟨⟨slot.off, slot.size, s0.st.mem.allocs.size⟩, ?_, rfl, ?_, hys⟩
          · rw [hesc']
            simp
          · rw [hfp]
            exact hya
        · rw [hget, if_neg hjs] at hj
          rcases hrel.free j y' hj hl with ⟨e, he, h1, h2, h3⟩ | hfr'
          · refine .inl ⟨e, ?_, h1, ?_, h3⟩
            · rw [hesc']
              exact List.mem_append_left _ he
            · rw [hfp]
              exact h2
          · refine .inr fun l sl hsl => ?_
            rw [hfp]
            exact hfr' l sl hsl
      · rw [hsz']
        rw [hesc', List.mem_append, List.mem_singleton] at he
        rcases he with he | rfl
        · exact Nat.lt_succ_of_lt (hrel.idLt e he)
        · exact Nat.lt_succ_self _
      · rw [hesc', List.mem_append, List.mem_singleton] at he
        rw [hfp]
        rcases he with he | rfl
        · have hlt := hrel.idLt e he
          rw [hmem _ hlt] at hy'
          exact hrel.addrAt e he y' hy'
        · have hyy : y' = y := Option.some.inj (hy'.symm.trans hy)
          rw [hyy]
          exact hya
    · refine ⟨⟨slot.off, slot.size, s0.st.mem.allocs.size⟩, fun k hk => ?_⟩
      have h0 := hpriv k hk
      unfold OpSem.State.escapedAt at h0 ⊢
      rw [hesc', List.find?_append, h0]
      first
        | (simp [hk]; done)
        | (simp; omega)

/-- A `StorageLive _l`'s slot is private in R (replaces `stmt_sim_base`'s use of `noEsc`): every
escaped object is a storage-live local's slot (`objs`), disjoint from `_l`'s by `ShareOk` at
the `StorageLive`.

Proof: `objs` gives the object's local `l'`, storage-live (`hsl0`, so maybe-live at the
`StorageLive`), `l' ≠ l` (`_l` is dead, `hdead`), so `ShareOk` makes the slots disjoint;
`end_escapedAt_some` then contradicts an `escapedAt` in `_l`'s slot. -/
theorem storageLive_privX {Γ : TermCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s0 : R.RState} {bd : BlockData} {l : Local} {sd : LocalSlot}
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hst : bd.stmts[f.stmt]? = some (.storageLive l))
    (hsd : Γ.slots[l]? = some sd) (hlt : l < Γ.body.locals.size)
    (hdead : ∀ p, f.locals[l]? ≠ some (some p))
    (hstor : StorageSound Γ.body (computeStorage Γ.body).get)
    (hshare : ShareOk Γ.body Γ.slots (computeStorage Γ.body).get)
    (hsl0 : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hrel : FnRelX Γ.toStmtCtx ι live f m0 s0) :
    ∀ k < sd.size, s0.st.escapedAt (sd.off + k) = none := by
  intro k hk
  cases he : s0.st.escapedAt (sd.off + k) with
  | none => rfl
  | some e =>
    exfalso
    obtain ⟨hmem, hlo, hhi⟩ := end_escapedAt_some he
    obtain ⟨l', p, sl', hp, hsl', hoff, hsize, -⟩ := hrel.objs e hmem
    have hne : l ≠ l' := by
      rintro rfl
      exact hdead p hp
    have hdisj := hshare f.bb bd hbd f.stmt l (.inl hst) l' hne (hsl0 l' p hp) sd sl' hsd hsl'
    omega

/-! ### One statement: sub-lemmas -/

theorem specsOk_length : ∀ (ps : List ScopeSpec) (scs : List R.Scope),
    specsOk ps scs = true → scs.length = ps.length
  | [], [], _ => rfl
  | [], _ :: _, h => by simp [specsOk] at h
  | _ :: _, [], h => by simp [specsOk] at h
  | p :: ps, sc :: scs, h => by
    simp only [specsOk, Bool.and_eq_true] at h
    simp [specsOk_length ps scs h.2]

/-- Sub-lemma 1: a lifted assignment's `StmtOutX`, when the next statement has no pending
scopes (`hpend0`; a non-empty range ends where the next one starts, `hpcNext`). -/
theorem stmtOutX_of_liftX {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {f : Spec.Frame} {rest : List Spec.Frame} {bd : BlockData} {blk : BlockCert}
    {s s' : Spec.State} {s1 s0 : R.RState} {d : Local} {rv : Rvalue}
    (hs : s.stack = f :: rest) (hstor : StorageSound Γ.body (computeStorage Γ.body).get)
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hst : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv))
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hfr : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hpc : s0.pc + 1 = pcAt blk (f.stmt + 1))
    (hpend0 : pendSpecs Γ.toStmtCtx bd blk (f.stmt + 1) = [])
    (hl : LiftOutX Γ.toStmtCtx c ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f s s' s1
      s0) :
    StmtOutX Γ c ch ι f rest bd blk s s' s1 := by
  obtain ⟨ι', st', hle, hfix, hstep, hstk, hrel, hpb, hsz, hdi⟩ := hl
  refine ⟨ι', { s0 with pc := s0.pc + 1, st := st' }, { s0 with pc := s0.pc + 1, st := st' }, f,
    hle, .cons hstep (.refl _), hstk.trans hs, rfl, rfl, rfl, rfl, rfl, hpc, ?_, hrel, ?_, hpb,
    ?_, hdi⟩
  · rw [hpend0]
    rfl
  · intro l p hp
    exact (hstor.stmt f.bb bd hbd f.stmt _ hst).1 l (hsl l p hp) (by intro e; cases e)
  · intro a ha
    rw [hfix a (Nat.le_trans hsz ha)]
    exact hfr a (Nat.le_trans hsz ha)

/-- Sub-lemma 2a: a one-instruction statement without own scopes: R's state at the statement
is `s1`, its scopes are exactly the pending ones, folded to `s0` (`MatchAtX.pend`). -/
theorem family_setup {Γ : TermCtx} {c : R.Code} {ι : Inj} {s : Spec.State} {s1 s0 : R.RState}
    {f : Spec.Frame} {rest : List Spec.Frame} {blk : BlockCert} {bd : BlockData}
    (hfn : LowersFnX Γ c.d) (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size) {i : R.Insn}
    (hR : rangeInsns c.d r = [i]) (hown : ownSpec Γ.toStmtCtx st = []) :
    c.d.insns[s1.pc]? = some i ∧ c.dropScopes.d.insns[s0.pc]? = some i ∧
      (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0 ∧ s0.pc = s1.pc ∧ s1.pc = r.1 ∧
      r.2 = r.1 + 1 := by
  obtain ⟨hc0, he⟩ := rangeInsns_single h2 hR
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hc : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0
  have hsc := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmt f.stmt st r hst hr (by omega)
  rw [hown, List.append_nil] at hsc
  have hlen := specsOk_length _ _ hsc
  have hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0 := by
    have hp := M.pend
    have ht : (c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk f.stmt).length =
        c.scopesAt s1.pc := by
      apply List.take_of_length_le
      have hl' : (c.scopesAt s1.pc).length = (pendSpecs Γ.toStmtCtx bd blk f.stmt).length := by
        rw [hpc0]
        exact hlen
      omega
    rw [ht] at hp
    exact hp
  have hpcs : s0.pc = s1.pc := scopes_pc hfold
  exact ⟨hc, by rw [hpcs]; exact hc, hfold, hpcs, hpc0, he⟩

/-- Sub-lemma 2b: a one-instruction family (no own scopes) from its scope-free lift on
`c.dropScopes` at the fold `s0`. The instruction's view falls through (`hv`, `hctl`: to come
from the family's rule or a `LowersFnX` check). -/
theorem stmtOutX_family {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {s s' : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} {d : Local} {rv : Rvalue} {r : Range} {i : R.Insn}
    {v : R.View}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    (hst : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv))
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hR : rangeInsns c.d r = [i]) (hown : ownSpec Γ.toStmtCtx (.assign ⟨d, []⟩ rv) = [])
    (hpl : PlainView c.mode c.ρ i)
    (hv : R.view c.mode c.ρ i = some v) (hctl : v.ctl = some .next)
    (hpcNext : r.2 = pcAt blk (f.stmt + 1))
    (hpend0 : pendSpecs Γ.toStmtCtx bd blk (f.stmt + 1) = [])
    (hl : LiftOut Γ.toStmtCtx c.dropScopes ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f
      s s' s0) :
    StmtOutX Γ c ch ι f rest bd blk s s' s1 := by
  obtain ⟨hc, -, hfold, hpcs, hpc0, he⟩ := family_setup hfn M hst hr h2 hR hown
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hX := liftOutX_of_liftOut hc hfold hpe hpl hv hctl M.rel M.dinv hl
  refine stmtOutX_of_liftX M.stack hfn.storage M.hbd hst M.sl M.fresh ?_ hpend0 hX
  rw [hpcs, hpc0, ← hpcNext, he]

end Ryo.Proofs.Lower
