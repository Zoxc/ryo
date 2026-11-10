/-
Ryo.Proofs.Lower.FnSim — the function-level simulation L0 → R of M5a (aot.md §C1): for a
function `LowersFn` accepts (`Check/Lower/Fn.lean`: no scopes, so every local is private; the
rules of `Stmt.lean`/`Term.lean`; liveness and slot-layout checks), every L0 step from related
states is matched by R steps to related states, or by R's `ret` when L0 returns.

`Match Γ c ι s s1`: L0's active frame `f` is the function's (bottom) frame at block `f.bb`,
point `f.stmt`; R's `pc` is where that point's code starts (`pcAt`: the statement's range, or
the terminator's); `FnRel` holds at the semantic liveness of that point; every storage-live
local is storage-live in `computeStorage`'s over-approximation; and L0's memory is
provenance-bounded (`ProvBounded`, which makes a fresh allocation's id hidden) with `ι` mapping
no id at or past its end (so `ι` never maps a fresh allocation).

Trusted inputs, stated as hypotheses:
- `PicksAt`: L0's daemonic address choice for a `StorageLive` is the local's slot (`fp + off`):
  the simulation picks it (aot.md §C1 "Locals"); and a NaN payload L0's oracle picks is the one
  R's choice resolves to (`NanPicks`).
- `IncomingOk`: R's incoming-argument read at `ret` succeeds (R's side of `sim_ret`).

`fn_step_sim` is one L0 step; `fn_sim` composes them over an L0 run. Open: `sim_ret` (SimTerm).
-/
import Ryo.Check.Lower.Fn
import Ryo.Proofs.Lower.SimTerm
import Ryo.Proofs.Lower.SimPtr
import Ryo.Proofs.Lower.SimBool
import Ryo.Proofs.Lower.ProvBound
import Ryo.Proofs.Provenance
import Ryo.Proofs.Lower.AllocsBelow

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Spec.Theorems (ptrProvOf)
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### Small facts -/

theorem runOn_throwIllFormed {α : Type} (msg : String) (o : Spec.Oracle) (s : Spec.State) :
    runOn (throwIllFormed msg : SemM α) o s = (.error (.illFormed msg), s) := rfl

/-- A successful step starts before the end of the run. -/
theorem step_final_none {o : Spec.Oracle} {s s' : Spec.State}
    (h : runOn Sem.step o s = (.ok (), s')) : s.final = none := by
  cases hf : s.final with
  | none => rfl
  | some x =>
    exfalso
    unfold Sem.step at h
    simp only [runOn_bind, runOn_get, hf, Option.isSome_some, ↓reduceIte,
      runOn_throwIllFormed] at h
    exact prod_err_ok h

theorem scopesAt_nil {c : R.Code} (h : c.d.scopes.size = 0) (k : Nat) : c.scopesAt k = [] := by
  have e : c.d.scopes = #[] := Array.eq_empty_of_size_eq_zero h
  simp [R.Code.scopesAt, e]

theorem rangeInsns_length {d : R.Decoded} {r : Range} (h2 : r.2 ≤ d.insns.size) :
    (rangeInsns d r).length = r.2 - r.1 := by
  unfold rangeInsns
  simp only [Array.length_toList, Array.size_extract]
  omega

theorem rangeInsns_at {d : R.Decoded} {r : Range} (h2 : r.2 ≤ d.insns.size) :
    ∀ j (hj : j < (rangeInsns d r).length),
      d.insns[r.1 + j]? = some ((rangeInsns d r)[j]'hj) := by
  intro j hj
  have hl := rangeInsns_length (r := r) h2
  have hlt : r.1 + j < d.insns.size := by omega
  rw [Array.getElem?_eq_getElem hlt]
  simp [rangeInsns]

theorem rangeInsns_single {d : R.Decoded} {r : Range} {i : R.Insn} (h2 : r.2 ≤ d.insns.size)
    (h : rangeInsns d r = [i]) : d.insns[r.1]? = some i ∧ r.2 = r.1 + 1 := by
  have hl := rangeInsns_length (r := r) h2
  rw [h] at hl
  have hat := rangeInsns_at (r := r) h2 0 (by rw [h]; simp)
  simp only [Nat.add_zero] at hat
  refine ⟨?_, ?_⟩
  · rw [hat]; simp [h]
  · simp at hl; omega

theorem rangeInsns_nil {d : R.Decoded} {r : Range} (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ d.insns.size)
    (h : rangeInsns d r = []) : r.2 = r.1 := by
  have hl := rangeInsns_length (r := r) h2
  rw [h] at hl
  simp at hl
  omega

/-- The R index of point `i` of a block: statement `i`'s range, or the terminator's. -/
def pcAt (blk : BlockCert) (i : Nat) : Nat := ((blk.stmts[i]?).map (·.1)).getD blk.term.1

theorem pcAt_some {blk : BlockCert} {i : Nat} {r : Range} (h : blk.stmts[i]? = some r) :
    pcAt blk i = r.1 := by
  simp [pcAt, h]

theorem pcAt_none {blk : BlockCert} {i : Nat} (h : blk.stmts[i]? = none) :
    pcAt blk i = blk.term.1 := by
  simp [pcAt, h]

theorem nextStart_eq (blk : BlockCert) (i : Nat) : nextStart blk i = pcAt blk (i + 1) := rfl

theorem termAt_of {c : R.Code} {s1 : R.RState} {r : Range} (h2 : r.2 ≤ c.d.insns.size)
    (hsc : c.d.scopes.size = 0) (hpe : c.mode.pe = false) (hpc : s1.pc = r.1) (h1 : r.1 ≤ r.2) :
    TermAt c s1 r.2 (rangeInsns c.d r) where
  code j hj := by rw [hpc]; exact rangeInsns_at h2 j hj
  scopes j _ := scopesAt_nil hsc _
  hnext := by rw [rangeInsns_length h2, hpc]; omega
  pe := hpe

theorem store_size {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (h : m.store p bs al = .ok m') : m'.allocs.size = m.allocs.size := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with ⟨_, _, rfl⟩ | ⟨id, hid, _, _, _, _, _, _, _, rfl⟩
  · rfl
  · simp

theorem dealloc_size {m m' : Memory} {p : ThinPointer} {k : AllocationKind} {n : Nat}
    {al : Align} (h : m.deallocate p k n al = .ok m') : m'.allocs.size = m.allocs.size := by
  obtain ⟨id, a, _, rfl⟩ := dealloc_ok_aux h
  simp

/-! ### The relation -/

/-- `a` is a live, non-empty L0 allocation `ι` drops. -/
def Unmapped (ι : Inj) (m : Memory) (a : AllocId) : Prop :=
  ι a = none ∧ ∃ x, m.get? a = some x ∧ x.live = true ∧ 0 < x.data.size

/-- The deref rules' memory invariant (`SimDeref`): no live byte carries the provenance of a
live, non-empty allocation `ι` drops, L0's live allocations don't overlap, and they end below
`ADDR_LIMIT` (`AllocsBelow`, for the split deref store). A structure, so `.1`/`.2` stay the
first two. -/
structure DerefInv (ι : Inj) (m : Memory) : Prop where
  hid : Hidden m (Unmapped ι m)
  ld : LiveDisjoint m
  below : AllocsBelow m

/-- See the module comment. -/
structure MatchAt (Γ : TermCtx) (ι : Inj) (s : Spec.State) (s1 : R.RState) (f : Spec.Frame)
    (rest : List Spec.Frame) (blk : BlockCert) (bd : BlockData) : Prop where
  stack : s.stack = f :: rest
  body : f.body = Γ.body
  pu : f.pendingUnwind = none
  cont : f.cont = .bottom
  hblk : Γ.blocks[f.bb]? = some blk
  hbd : Γ.body.blocks[f.bb]? = some bd
  le : f.stmt ≤ bd.stmts.length
  pc : pcAt blk f.stmt = s1.pc
  rel : FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s1
  sl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true
  pb : ProvBounded s.mem
  fresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none
  dinv : DerefInv ι s.mem

def Match (Γ : TermCtx) (ι : Inj) (s : Spec.State) (s1 : R.RState) : Prop :=
  ∃ f rest blk bd, MatchAt Γ ι s s1 f rest blk bd

/-- The oracle answers a NaN choice at `s` with what R's choice `ch` resolves it to
(`SimBinFloat`, `SimFloatCast`; see the module comment). -/
def NanPicks (o : Spec.Oracle) (s : Spec.State) (ch : OpSem.Choice) : Prop :=
  ∀ (f : FloatTy) (cs : List Nat),
    cs.contains (o.answer s.choiceCount (Ryo.Spec.Choice.nanBits f cs) s) = true →
      resolveNaN ch (.nan cs) = .ok (o.answer s.choiceCount (Ryo.Spec.Choice.nanBits f cs) s)

/-- L0's daemonic choices at `s` are the ones R makes: a `StorageLive`'s address is the local's
slot at `fp`, and a NaN's payload is what R's choice `ch` resolves it to (`NanPicks`; see the
module comment). -/
def PicksAt (Γ : TermCtx) (o : Spec.Oracle) (ch : OpSem.Choice) (s : Spec.State) (fp : Nat) :
    Prop :=
  (∀ f rest bd l sd ty p m' s2, s.stack = f :: rest → f.body.blocks[f.bb]? = some bd →
    bd.stmts[f.stmt]? = some (.storageLive l) → Γ.slots[l]? = some sd →
    f.body.locals[l]? = some ty →
    runOn (s.mem.allocate .stack sd.size ty.align : SemM (ThinPointer × Memory)) o s =
      (.ok (p, m'), s2) → (p.addr : Int) = fp + sd.off) ∧
  NanPicks o s ch

/-- R's incoming-argument read succeeds (see the module comment). -/
def IncomingOk (c : R.Code) : Prop := ∀ st : OpSem.State, ∃ bs, st.readFrame 16 c.argSize = .ok bs

/-! ### Statements -/

/-- `m'` is `m` after a memory change that keeps each allocation's address and size, makes
none live, and brings in no provenance a `Hidden` predicate excludes (stores of bytes loaded
from `m` or provenance-free, deallocations): what the deref rules' invariant (`DerefInv`,
SimDeref) needs of a step. -/
def MemKept (m m' : Memory) : Prop :=
  (∀ a x', m'.get? a = some x' → ∃ x, m.get? a = some x ∧ x.addr = x'.addr ∧
    (x'.live = true → x.live = true) ∧ x.data.size = x'.data.size) ∧
  ∀ A : AllocId → Prop, Hidden m A → Hidden m' A

/-- After a store, each allocation was there before, at the same address, size and liveness. -/
theorem store_get?_fwd {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (h : m.store p bs al = .ok m') {a : AllocId} {x' : Allocation} (hx : m'.get? a = some x') :
    ∃ x, m.get? a = some x ∧ x.addr = x'.addr ∧ x.live = x'.live ∧
      x.data.size = x'.data.size := by
  obtain ⟨hsz, hag⟩ := Ryo.Spec.Theorems.Memory.store_agree h
  obtain ⟨hlt', rfl⟩ := Array.getElem?_eq_some_iff.mp (show m'.allocs[a]? = some x' from hx)
  have hlt : a < m.allocs.size := by
    first
      | (have hs' := store_size h; omega)
      | (rw [hsz]; exact hlt')
      | exact hsz ▸ hlt'
  obtain ⟨e1, -, e3, e4, -⟩ := hag a hlt hlt'
  exact ⟨m.allocs[a], get?_of_lt hlt, e1, e3, e4⟩

theorem MemKept.refl (m : Memory) : MemKept m m :=
  ⟨fun _ x' hx => ⟨x', hx, rfl, fun h => h, rfl⟩, fun _ h => h⟩

theorem MemKept.trans {m1 m2 m3 : Memory} (h1 : MemKept m1 m2) (h2 : MemKept m2 m3) :
    MemKept m1 m3 := by
  refine ⟨fun a x3 hx3 => ?_, fun A hA => h2.2 A (h1.2 A hA)⟩
  obtain ⟨x2, hx2, e2, l2, s2⟩ := h2.1 a x3 hx3
  obtain ⟨x1, hx1, e1, l1, s1⟩ := h1.1 a x2 hx2
  exact ⟨x1, hx1, e1.trans e2, fun h => l1 (l2 h), s1.trans s2⟩

/-- What a lifted assignment gives (`lift_*` plus the memory invariants). -/
def LiftOut (Γ : StmtCtx) (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (f : Spec.Frame) (s s' : Spec.State) (s1 : R.RState) : Prop :=
  ∃ st', R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
    s'.stack = s.stack ∧ FnRel Γ ι live' f s'.mem { s1 with pc := s1.pc + 1, st := st' } ∧
    ProvBounded s'.mem ∧ s.mem.allocs.size ≤ s'.mem.allocs.size ∧ MemKept s.mem s'.mem


/-! ### Memory facts of the bool and pointer rules -/

/-- An array written with bytes none of whose provenance satisfies `A` keeps the property. -/
private theorem hid_arr' {A : AllocId → Prop} {d arr : Array AbstractByte}
    {bs : List AbstractByte} {o : Nat}
    (hold : ∀ i (h : i < d.size) f, d[i].provFrag = some f → ¬ A f.prov)
    (hbs : ∀ b ∈ bs, ∀ f, b.provFrag = some f → ¬ A f.prov)
    (hg : ∀ j, arr[j]? = if o + 0 ≤ j ∧ j < o + 0 + bs.length ∧ j < d.size then
      bs[j - o - 0]? else d[j]?) :
    ∀ i (h : i < arr.size) f, arr[i].provFrag = some f → ¬ A f.prov := by
  intro i hi f hf
  have e := hg i
  rw [Array.getElem?_eq_getElem hi] at e
  split at e
  · rename_i c
    have hk : i - o - 0 < bs.length := by omega
    rw [List.getElem?_eq_getElem hk] at e
    rw [Option.some.inj e] at hf
    exact hbs _ (List.getElem_mem hk) f hf
  · obtain ⟨hi', he⟩ := Array.getElem?_eq_some_iff.mp e.symm
    rw [← he] at hf
    exact hold i hi' f hf

/-- A store of bytes carrying no provenance `A` holds keeps `Hidden`. -/
theorem Hidden.store_hidden {m0 m0' : Memory} {A : AllocId → Prop} (hh : Hidden m0 A)
    {p : ThinPointer} {bs : List AbstractByte} {al : Align} (h : m0.store p bs al = .ok m0')
    (hbs : ∀ b ∈ bs, ∀ f, b.provFrag = some f → ¬ A f.prov) : Hidden m0' A := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with
    ⟨_, _, rfl⟩ | ⟨k, hid, _, _, _, _, _, _, _, rfl⟩
  · exact hh
  · intro a x hx hlv
    by_cases hak : a = k
    · subst hak
      simp only [Memory.get?, Array.getElem?_set_self, Option.some.injEq] at hx
      subst hx
      exact hid_arr' (hh a _ (Array.getElem?_eq_getElem hid) hlv) hbs
        (Ryo.Spec.Theorems.foldl_set_getElem bs 0 (p.addr - m0.allocs[a].addr)
          m0.allocs[a].data)
    · simp only [Memory.get?] at hx
      rw [Array.getElem?_set_ne hid (Ne.symm hak)] at hx
      exact hh a x hx hlv

/-- Bytes loaded under `Hidden` carry none of its provenance. -/
theorem Hidden.load {m : Memory} {A : AllocId → Prop} (hh : Hidden m A) {p : ThinPointer}
    {n : Nat} {al : Align} {bs : List AbstractByte} (hl : m.load p n al = .ok bs) :
    ∀ b ∈ bs, ∀ f, b.provFrag = some f → ¬ A f.prov := by
  by_cases hn : n = 0
  · subst hn
    rw [load_zero_inv hl]
    intro b hb
    cases hb
  · obtain ⟨id, hid, -, hlive, -, -, rfl⟩ := load_eq_ok_pos hn hl
    intro b hb f hf
    rw [Array.mem_toList_iff] at hb
    obtain ⟨j, hj, rfl⟩ := Array.mem_iff_getElem.mp hb
    rw [Array.getElem_extract] at hf
    exact hh id _ (Array.getElem?_eq_getElem hid) hlive _ _ f hf


/-- A store whose bytes carry no provenance a `Hidden` predicate of `m` excludes. -/
theorem memKept_store {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (hsto : m.store p bs al = .ok m')
    (hbs : ∀ A : AllocId → Prop, Hidden m A → ∀ b ∈ bs, ∀ fr, b.provFrag = some fr →
      ¬ A fr.prov) :
    MemKept m m' := by
  refine ⟨fun a x' hx' => ?_, fun A hA => hA.store_hidden hsto (hbs A hA)⟩
  obtain ⟨x, hx, e1, el, es⟩ := store_get?_fwd hsto hx'
  exact ⟨x, hx, e1, fun h => el.trans h, es⟩

/-- A store of provenance-free bytes. -/
theorem memKept_noprov {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (hsto : m.store p bs al = .ok m') (hnp : ∀ b ∈ bs, b.provFrag = none) : MemKept m m' :=
  memKept_store hsto fun _ _ b hb fr hfr => by rw [hnp b hb] at hfr; cases hfr

/-- A store of bytes whose provenance is that of bytes loaded from `m` (`bytesLeDefined_prov`'s
shape). -/
theorem memKept_load {m m' : Memory} {p q : ThinPointer} {bsd bs0 : List AbstractByte}
    {al al' : Align} {n : Nat} (hsto : m.store p bsd al = .ok m')
    (hlo : m.load q n al' = .ok bs0)
    (hsub : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr →
      ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov) :
    MemKept m m' := by
  refine memKept_store hsto fun A hA b hb fr hfr => ?_
  obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
  rw [← he0]
  exact hA.load hlo _ (List.getElem_mem hj) fr0 hf0

/-- The memory invariants after a provenance-free store. -/
theorem memInv_store {s s' : Spec.State} (hpb : ProvBounded s.mem) {pd : ThinPointer}
    {bs : List AbstractByte} (hsto : s.mem.store pd bs .one = .ok s'.mem)
    (hnp : ∀ b ∈ bs, b.provFrag = none) :
    ProvBounded s'.mem ∧ s.mem.allocs.size ≤ s'.mem.allocs.size ∧ MemKept s.mem s'.mem :=
  ⟨hpb.store_noprov hsto hnp, Nat.le_of_eq (store_size hsto).symm, memKept_noprov hsto hnp⟩

/-- `DerefInv` survives any memory change `MemKept` covers (stores of loaded or
provenance-free bytes, deallocations). -/
theorem DerefInv.of_memKept {ι : Inj} {m m' : Memory} (h : DerefInv ι m) (hk : MemKept m m') :
    DerefInv ι m' := by
  obtain ⟨hmap, hld, hbl⟩ := h
  obtain ⟨hf, hh⟩ := hk
  have hU : ∀ a, Unmapped ι m' a → Unmapped ι m a := by
    rintro a ⟨hι, x', hx', hl', hp'⟩
    obtain ⟨x, hx, -, el, es⟩ := hf a x' hx'
    exact ⟨hι, x, hx, el hl', by omega⟩
  refine ⟨(hh _ hmap).mono hU, ?_, hbl.of_kept hf⟩
  intro i j a b x hi hj hla hlb h1 h2 h3 h4
  obtain ⟨a0, ha0, ea, el, es⟩ := hf i a hi
  obtain ⟨b0, hb0, eb, el', es'⟩ := hf j b hj
  simp only [Allocation.size] at h2 h4
  exact hld i j a0 b0 x ha0 hb0 (el hla) (el' hlb) (by omega)
    (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)

/-- A deallocation only kills an allocation. -/
theorem memKept_dealloc {m m' : Memory} {p : ThinPointer} {k : AllocationKind} {n : Nat}
    {al : Align} (hd : m.deallocate p k n al = .ok m') : MemKept m m' := by
  refine ⟨fun c x' hx' => ?_, fun A hA => hA.dealloc hd⟩
  obtain ⟨id, a0, hg, rfl⟩ := dealloc_ok_aux hd
  have hid : id < m.allocs.size := by
    unfold Memory.get? at hg
    exact (Array.getElem?_eq_some_iff.mp hg).1
  unfold Memory.get? at hx'
  simp only [Array.set!, Array.getElem?_setIfInBounds] at hx'
  by_cases hc : id = c
  · subst hc
    simp [hid] at hx'
    refine ⟨a0, hg, ?_, ?_, ?_⟩ <;>
      first
        | (subst hx'; simp)
        | (rw [← hx']; simp)
        | (rw [hx']; simp)
        | (subst hx'; rfl)
  · rw [if_neg hc] at hx'
    exact ⟨x', hx', rfl, fun h => h, rfl⟩

/-- `DerefInv` after a fresh allocation (`Memory.allocate`: `Uninit` bytes at an address no live
allocation overlaps, `addrOk`); no byte carries its id (`ProvBounded`). -/
theorem DerefInv.push {ι : Inj} {m : Memory} (h : DerefInv ι m) (hpb : ProvBounded m)
    {a : Allocation} {size : Nat} {al : Align} (hdata : a.data = Array.replicate size .uninit)
    (hok : m.addrOk a.addr size al = true) : DerefInv ι { allocs := m.allocs.push a } := by
  obtain ⟨hmap, hld, hbl⟩ := h
  have hget : ∀ c, ({ allocs := m.allocs.push a } : Memory).get? c =
      if c = m.allocs.size then some a else m.get? c := by
    intro c
    show (m.allocs.push a)[c]? = _
    first
      | (rw [Array.getElem?_push]; done)
      | (rw [Array.getElem?_push]; rfl)
      | (by_cases hc : c = m.allocs.size <;> simp [Array.getElem?_push, Memory.get?, hc])
  have hasz : a.data.size = size := by rw [hdata]; simp
  have hnew : ∀ i (hi : i < a.data.size), a.data[i].provFrag = none := by
    obtain ⟨d, _, _, _, _, _, _⟩ := a
    simp only at hdata
    subst hdata
    intro i hi
    simp [AbstractByte.provFrag]
  -- no live allocation of `m` meets `a`'s range
  have hno : ∀ j y z, m.get? j = some y → y.live = true → y.addr ≤ z →
      z < y.addr + y.data.size → a.addr ≤ z → z < a.addr + size → False := by
    intro j y z hy hyl h1 h2 h3 h4
    obtain ⟨hjlt, hyj⟩ := Array.getElem?_eq_some_iff.mp (show m.allocs[j]? = some y from hy)
    have hys : y.data.size ≠ 0 := by omega
    have hs0 : size ≠ 0 := by omega
    have hov : (y.live && y.overlaps a.addr size) = true := by
      rw [hyl, Bool.true_and]
      unfold Allocation.overlaps
      first
        | (simp [Allocation.size, hys, hs0]; exact ⟨decide_eq_false (by omega), by omega⟩)
        | (simp [Allocation.size, hys, hs0]; omega)
        | (simp [Allocation.size, hys, hs0, decide_eq_false_iff_not]; omega)
    have hany : (m.allocs.any fun b => b.live && b.overlaps a.addr size) = true :=
      Array.any_eq_true.mpr ⟨j, hjlt, by rw [hyj]; exact hov⟩
    unfold Memory.addrOk at hok
    rw [hany] at hok
    simp at hok
  refine ⟨?_, ?_, hbl.push hdata hok⟩
  · intro c x hx hlv i hi fr hfr hU
    rw [hget] at hx
    split at hx
    · obtain rfl := Option.some.inj hx
      rw [hnew i hi] at hfr
      cases hfr
    · have hlt := hpb c x hx i hi fr hfr
      obtain ⟨hι, y, hy, hyl, hyp⟩ := hU
      rw [hget, if_neg (Nat.ne_of_lt hlt)] at hy
      exact hmap c x hx hlv i hi fr hfr ⟨hι, y, hy, hyl, hyp⟩
  · intro i j x y z hi hj hxl hyl h1 h2 h3 h4
    simp only [Allocation.size] at h2 h4
    rw [hget] at hi hj
    split at hi <;> split at hj
    · next e1 e2 => exact e1.trans e2.symm
    · obtain rfl := Option.some.inj hi
      exact (hno j y z hj hyl h3 h4 h1 (by rw [← hasz]; exact h2)).elim
    · obtain rfl := Option.some.inj hj
      exact (hno i x z hi hxl h1 h2 h3 (by rw [← hasz]; exact h4)).elim
    · exact hld i j x y z hi hj hxl hyl h1 (by simp only [Allocation.size]; exact h2) h3
        (by simp only [Allocation.size]; exact h4)

/-- A whole-local copy at `ty` of `n` bytes in L0: the source's bytes loaded and decoded, the
value re-encoded and stored into the destination. -/
theorem copy_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame}
    (hs : s.stack = f :: rest) {d a : Local} {ty : Spec.Ty} {n : Nat} (hn : ty.size? = some n)
    (htd : f.body.locals[d]? = some ty) (hta : f.body.locals[a]? = some ty)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.copy ⟨a, []⟩)))) o s = (.ok (), s')) :
    ∃ pd pa bs0 v bsd, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      s.mem.load pa n .one = .ok bs0 ∧ ty.decode bs0 = some v ∧ ty.encode v = some bsd ∧
      s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack := by
  obtain ⟨pd, td, rv, s1, hpd, htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  obtain ⟨pa, ta, va, hpa, hta', hla, hrv, hs1⟩ := runOn_evalOperand_copy hs hev
  have e4 : td = ty := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta = ty := Option.some.inj (hta'.symm.trans hta)
  subst e4 e5
  subst hrv
  rw [hs1] at hst
  obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv hn hla
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  exact ⟨pd, pa, bs0, va, bsd, hpd, hpa, hlo, hd, hen, hsto, by rw [hs1]⟩

/-- A bool constant's store in L0: `encodeBits 1 bits` into the destination. -/
theorem constBool_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {bits : Nat}
    (htd : f.body.locals[d]? = some .bool)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.const (.scalar bits) .bool)))) o s =
      (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧ s'.stack = s.stack ∧
      s.mem.store pd (encodeBits 1 bits) .one = .ok s'.mem := by
  obtain ⟨pd', td, rv, s1, hpd', htd', hev, mem', hst, rfl⟩ := assign_use_inv hs h
  have e4 : td = .bool := Option.some.inj (htd'.symm.trans htd)
  subst e4
  have e3 : evalOperand (.const (.scalar bits) .bool) =
      (evalConst (.scalar bits) .bool >>= fun w => pure (w, Spec.Ty.bool)) := by
    first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
  rw [e3] at hev
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨hrv, hs1⟩ := prod_ok_inj h2
  subst rv
  subst s1
  have e5 : evalConst (.scalar bits) Spec.Ty.bool = decodeConst (encodeBits 1 bits) .bool := rfl
  rw [e5] at h1
  obtain ⟨hdec, hs2⟩ := runOn_decodeConst_ok h1
  subst s2
  rw [encodeBits_one] at hdec
  obtain ⟨x, f', heq, hen⟩ := decode_bool_inv hdec
  have hx : x = UInt8.ofNat (bits % 256) ∧ f' = none := by
    injection heq with h1 _
    injection h1 with h3 h4
    exact ⟨h3.symm, h4.symm⟩
  obtain ⟨rfl, rfl⟩ := hx
  obtain ⟨bsd, hen', hsto⟩ := typedStore_inv hst
  have hbsd : bsd = encodeBits 1 bits := by
    have := hen.symm.trans hen'
    rw [encodeBits_one]
    exact (Option.some.inj this).symm
  subst hbsd
  exact ⟨pd', hpd', rfl, hsto⟩

/-- A thin pointer's re-encoding carries only provenance its decoded bytes carry. -/
theorem ptr_reenc_prov {pt : PtrType} {valid : ValidRange} (hk : pt.metaKind = .none)
    {bs0 bsd : List AbstractByte} {v : Value} (hd : (Spec.Ty.ptr pt valid).decode bs0 = some v)
    (he : (Spec.Ty.ptr pt valid).encode v = some bsd) :
    ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr →
      ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
  obtain ⟨tp, -, hdp, rfl⟩ := decode_ptr_thin_inv hk hd
  have he' : bsd = encodePtr tp := by
    simp [Spec.Ty.encode, hk] at he
    first | exact he.symm | exact he
  subst he'
  rw [Ryo.Spec.Theorems.decodePtr_eq] at hdp
  cases hdb : decodeBits bs0 with
  | none => simp [hdb] at hdp
  | some a =>
    simp [hdb] at hdp
    subst hdp
    intro b hb fr hfr
    rw [Ryo.Spec.Theorems.encodePtr_eq] at hb
    obtain ⟨k, hk'⟩ := List.mem_iff_getElem?.mp hb
    simp only [Ryo.Spec.Theorems.getElem?_ptrBytes] at hk'
    rcases Option.eq_none_or_eq_some (ptrProvOf bs0) with hpo | ⟨q, hpo⟩
    · rw [hpo] at hk'
      obtain ⟨x, -, rfl⟩ := Option.map_eq_some_iff.mp hk'
      simp [AbstractByte.provFrag] at hfr
    · rw [hpo] at hk'
      obtain ⟨x, -, rfl⟩ := Option.map_eq_some_iff.mp hk'
      simp only [Option.map_some, AbstractByte.provFrag, Option.some.injEq] at hfr
      obtain ⟨hne, hall⟩ := (Ryo.Spec.Theorems.ptrProvOf_iff bs0 q).mp hpo
      have h0 : 0 < bs0.length := by
        cases bs0 with
        | nil => exact absurd rfl hne
        | cons _ _ => simp
      exact ⟨0, h0, _, hall 0 h0, by rw [← hfr]⟩

theorem size?_bool : Spec.Ty.bool.size? = some 1 := by
  first | rfl | decide | simp [Spec.Ty.size?, Spec.Ty.layout, LayoutStrategy.size?]

/-- `copyBool`'s lift: a `mov` of 1 byte between private bool locals (`sim_copyBytes` with
`reenc_bool`; the stored byte carries no provenance). -/
theorem lift_copyBool {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d a : Local} {oa : Operand} {sd sa : LocalSlot} {i : R.Insn}
    (ha : oa.local? = some a)
    (htd : Γ.body.locals[d]? = some .bool) (hta : Γ.body.locals[a]? = some .bool)
    (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
    (hsize : sd.size = 1 ∧ sa.size = 1) (hoff : offOk sd.off ∧ offOk sa.off)
    (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
    (hmi : movInsnOk Γ i 1 sd.off sa.off = true)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : live a = true) (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use oa))) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  rw [eval_use_norm ha] at h
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  rw [hbody] at htd hta
  obtain ⟨pd, _, _, _, hpd, _, hev, -⟩ := assign_use_inv hs h
  obtain ⟨pa, _, _, hpa, -⟩ := runOn_evalOperand_copy hs hev
  have hra := hrel.opnd hpa hsa hlo
  have hpos : 0 < sd.size := by rw [hsize.1]; exact Nat.one_pos
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos hpriv
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  obtain ⟨st', hop, hmi', hrd, hoth⟩ := sim_copyBytes (ch := ch) hs size?_bool (reenc_bool ι)
    htd hta hsize.1 hsize.2 hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv
    hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ h
  obtain ⟨pd', pa', bs0, w, bsd, hpd', -, -, hd, hen, hsto, hstk⟩ := copy_mem hs size?_bool htd hta h
  obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  obtain ⟨x, f0, -, hx⟩ := decode_bool_inv hd
  have hbsd : bsd = [.init x none] := Option.some.inj (hen.symm.trans hx)
  have hnp : ∀ b ∈ bsd, b.provFrag = none := by
    rw [hbsd]
    intro b hb
    simp only [List.mem_singleton] at hb
    subst hb
    rfl
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
    hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩

/-- `copyPtr`'s lift: a `mov` of 8 bytes between private thin-pointer locals (`sim_copyBytes`
with `reenc_ptr`; the stored bytes carry only the loaded bytes' provenance, so `Hidden` and the
bound carry over). -/
theorem lift_copyPtr {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d a : Local} {oa : Operand} {pt : PtrType} {valid : ValidRange} {sd sa : LocalSlot}
    {i : R.Insn} (hk : pt.metaKind = .none) (ha : oa.local? = some a)
    (htd : Γ.body.locals[d]? = some (.ptr pt valid)) (hta : Γ.body.locals[a]? = some (.ptr pt valid))
    (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
    (hsize : sd.size = 8 ∧ sa.size = 8) (hoff : offOk sd.off ∧ offOk sa.off)
    (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
    (hmi : movInsnOk Γ i 8 sd.off sa.off = true)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : live a = true) (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use oa))) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  rw [eval_use_norm ha] at h
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  rw [hbody] at htd hta
  obtain ⟨pd, _, _, _, hpd, _, hev, -⟩ := assign_use_inv hs h
  obtain ⟨pa, _, _, hpa, -⟩ := runOn_evalOperand_copy hs hev
  have hra := hrel.opnd hpa hsa hlo
  have hpos : 0 < sd.size := by rw [hsize.1]; decide
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos hpriv
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  obtain ⟨st', hop, hmi', hrd, hoth⟩ := sim_copyBytes (ch := ch) hs (size?_ptr_thin hk)
    (reenc_ptr ι hk) htd hta hsize.1 hsize.2 hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr
    hpaddr hsz hpv hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ h
  obtain ⟨pd', pa', bs0, w, bsd, hpd', -, hlo0, hd, hen, hsto, hstk⟩ :=
    copy_mem hs (size?_ptr_thin hk) htd hta h
  obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have hsub := ptr_reenc_prov hk hd hen
  -- `Hidden`: the stored provenance is the loaded bytes', which `Hidden` excludes
  have hhid := hrel.hidden.load hlo0
  have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hhid _ (List.getElem_mem hj) fr0 hf0
  -- the bound: likewise
  have hbd := hpb.load hlo0
  have hbd' : BytesBounded s.mem.allocs.size bsd := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hbd _ (List.getElem_mem hj) fr0 hf0
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
    hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

/-- `constBool`'s lift: an `imm` of 1 byte into a private bool local (`sim_constBool`). -/
theorem lift_constBool {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {bits : Nat} {sd : LocalSlot} {i : R.Insn}
    (htd : Γ.body.locals[d]? = some .bool) (hsd : Γ.slots[d]? = some sd) (hsize : sd.size = 1)
    (hoff : offOk sd.off) (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
    (hii : immInsnOk Γ i 1 sd.off bits = true)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use (.const (.scalar bits) .bool)))) o s =
      (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
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
  have hpos : 0 < sd.size := by rw [hsize]; exact Nat.one_pos
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos hpriv
  have hf1 := offOk_spec hoff
  obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_constBool (ch := ch) hs htd hsize hpd hrel.frame.mem
    ad xd hp hι hxd hl haddr hpaddr hsz hpv hh hty' ho ⟨hf1.1, hf1.2⟩ hfk hx h
  obtain ⟨pd', hpd', hstk, hsto⟩ := constBool_mem hs htd h
  obtain rfl : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have hnp := encodeBits_noprov 1 bits
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  obtain ⟨hpb', hle⟩ := memInv_store hpb hsto hnp
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops'']; exact hop), hstk,
    hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto hnp) hesc hlive', hpb', hle⟩

/-- What one statement's simulation gives: R steps to the statement's range end, and the
relation at the next point for the frame the statement leaves (`f'`, before `stmt` advances). -/
def StmtOut (Γ : TermCtx) (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (f : Spec.Frame)
    (rest : List Spec.Frame) (r : Range) (s s' : Spec.State) (s1 : R.RState) : Prop :=
  ∃ s1' f', StepsTo c ch s1 s1' ∧ s'.stack = f' :: rest ∧ f'.body = f.body ∧ f'.bb = f.bb ∧
    f'.stmt = f.stmt ∧ f'.pendingUnwind = f.pendingUnwind ∧ f'.cont = f.cont ∧
    s1'.pc = r.2 ∧
    FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f' s'.mem s1' ∧
    (∀ l p, f'.locals[l]? = some (some p) →
      (computeStorage Γ.body).get f.bb (f.stmt + 1) l = true) ∧
    ProvBounded s'.mem ∧ (∀ a, s'.mem.allocs.size ≤ a → ι a = none) ∧ DerefInv ι s'.mem

/-- An assignment's `StmtOut` from its `LiftOut`. -/
theorem stmtOut_of_lift {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {f : Spec.Frame} {rest : List Spec.Frame} {r : Range} {s s' : Spec.State} {s1 : R.RState}
    {bd : BlockData} {d : Local} {rv : Rvalue}
    (hs : s.stack = f :: rest) (hstor : StorageSound Γ.body (computeStorage Γ.body).get)
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hst : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv))
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hfr : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hpc : s1.pc + 1 = r.2)
    (hl : LiftOut Γ.toStmtCtx c ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f s s' s1) :
    StmtOut Γ c ch ι f rest r s s' s1 := by
  obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := hl
  refine ⟨_, f, .cons hstep (.refl _), hstk.trans hs, rfl, rfl, rfl, rfl, rfl, hpc, hrel,
    ?_, hpb, ?_, hdi.of_memKept hk⟩
  · intro l p hp
    exact (hstor.stmt f.bb bd hbd f.stmt _ hst).1 l (hsl l p hp) (by intro e; cases e)
  · intro a ha
    exact hfr a (Nat.le_trans hle ha)

/-- The liveness facts an assignment's lift takes. -/
theorem assign_live {Γ : TermCtx} {f : Spec.Frame} {bd : BlockData} {d : Local} {rv : Rvalue}
    (hlv : LiveSound Γ.body (computeLive Γ.body).get) (hbd : Γ.body.blocks[f.bb]? = some bd)
    (hst : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv)) :
    (∀ l, (computeLive Γ.body).get f.bb (f.stmt + 1) l = true → l = d ∨
      (computeLive Γ.body).get f.bb f.stmt l = true) ∧
    (∀ l ∈ rvalueLocals rv, (computeLive Γ.body).get f.bb f.stmt l = true) := by
  obtain ⟨h1, h2⟩ := hlv.assign hbd hst
  refine ⟨fun l hl => ?_, h2⟩
  by_cases e : l = d
  · exact .inl e
  · exact .inr (h1 l hl e)

/-- One statement of `LowerStmt`, from `MatchAt` before it. -/
theorem stmt_sim_base {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    (hpick : PicksAt Γ o ch s s1.fp)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (hlow : LowerStmt Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hsc : c.scopesAt s1.pc = [] := scopesAt_nil hfn.noScopes _
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hbody : Γ.toStmtCtx.body = f.body := M.body.symm
  have hmode' : Γ.toStmtCtx.mode = c.mode := hmode.symm
  have hρ' : Γ.toStmtCtx.ρ = c.ρ := hρ.symm
  have hwf : IntsSized f.body := by rw [M.body]; exact hfn.ints
  -- the single instruction of an assignment's range
  have single : ∀ i, rangeInsns c.d r = [i] →
      c.d.insns[s1.pc]? = some i ∧ s1.pc + 1 = r.2 ∧ PlainView c.mode c.ρ i := by
    intro i hri
    obtain ⟨hc, he⟩ := rangeInsns_single h2 hri
    refine ⟨by rw [hpc0]; exact hc, by rw [hpc0, he], ?_⟩
    rw [hmode, hρ]; exact hfn.plain _ _ hc
  generalize hR : rangeInsns c.d r = is at hlow
  cases hlow with
  | binop hm ha hb htd hta htb hsd hsa hsb hsize hoff hpriv hi =>
    obtain ⟨hc, hpc, hpl⟩ := single _ hR
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_binop (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, _, _, _, _, _, _, _, hm, ha, hb, htd, hta, htb, hsd, hsa, hsb, hsize, hoff, hpriv, hi⟩
      hc hsc hpe hpl M.rel
      (fun x hx => hl2 x (by
        rcases hx with hx | hx
        · exact List.mem_append_left _ (operand_local_mem hx)
        · exact List.mem_append_right _ (operand_local_mem hx)))
      hl1 hev
    have hev' := hev
    rw [eval_binop_norm ha hb] at hev'
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := binop_mem M.stack hm (by rw [← hbody]; exact htd)
      (by rw [← hbody]; exact hta) (by rw [← hbody]; exact htb) hev'
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | binopImm hm ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hc, hpc, hpl⟩ := single _ hR
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_binopImm (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, _, _, _, hm, ha, htd, hta, hsd, hsa, hsize, hoff, hpriv, hi⟩
      hc hsc hpe hpl M.rel (fun x hx => hl2 x (List.mem_append_left _ (operand_local_mem hx)))
      hl1 hev
    have hev' := hev
    rw [eval_binopImm_norm ha] at hev'
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := binImm_mem M.stack hm (by rw [← hbody]; exact htd)
      (by rw [← hbody]; exact hta) hev'
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | copyInt ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hc, hpc, hpl⟩ := single _ hR
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_copyInt (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, _, _, _, _, ha, htd, hta, hsd, hsa, hsize, hoff, hpriv, hi⟩
      hc hsc hpe hpl M.rel (fun x hx => hl2 x (operand_local_mem hx)) hl1 hev
    have hev' := hev
    rw [eval_use_norm ha] at hev'
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := use_mem M.stack (by rw [← hbody]; exact htd)
      (fun _ _ hr => by
        obtain ⟨_, _, _, _, _, _, _, he⟩ := runOn_evalOperand_copy M.stack hr
        exact he) hev'
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | constInt htd hsd hsize hoff hpriv hi =>
    obtain ⟨hc, hpc, hpl⟩ := single _ hR
    obtain ⟨hl1, -⟩ := assign_live hfn.live M.hbd hst
    obtain ⟨st', hstep, hstk, hrel⟩ := lift_constInt (ch := ch) M.stack hbody hwf hmode' hρ'
      ⟨_, htd, hsd, hsize, hoff, hpriv, hi⟩ hc hsc hpe hpl M.rel hl1 hev
    obtain ⟨_, _, _, bs, hsto, hnp⟩ := use_mem M.stack (by rw [← hbody]; exact htd)
      (fun _ _ hr => (runOn_evalOperand_const_scalar_int hr).2) hev
    obtain ⟨hpb, hle⟩ := memInv_store M.pb hsto hnp
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      ⟨st', hstep, hstk, hrel, hpb, hle⟩
  | copyBool ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hc, hpc, hpl⟩ := single _ hR
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      (lift_copyBool M.stack hbody hmode' hρ' ha htd hta hsd hsa hsize hoff hpriv hi hc hsc
        hpe hpl M.rel M.pb (hl2 _ (operand_local_mem ha)) hl1 hev)
  | copyPtr hk ha htd hta hsd hsa hsize hoff hpriv hi =>
    obtain ⟨hc, hpc, hpl⟩ := single _ hR
    obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      (lift_copyPtr M.stack hbody hmode' hρ' hk ha htd hta hsd hsa hsize hoff hpriv hi hc hsc
        hpe hpl M.rel M.pb (hl2 _ (operand_local_mem ha)) hl1 hev)
  | constBool htd hsd hsize hoff hpriv hi =>
    obtain ⟨hc, hpc, hpl⟩ := single _ hR
    obtain ⟨hl1, -⟩ := assign_live hfn.live M.hbd hst
    exact stmtOut_of_lift M.stack hfn.storage M.hbd hst M.sl M.fresh M.dinv hpc
      (lift_constBool M.stack hbody hmode' hρ' htd hsd hsize hoff hpriv hi hc hsc hpe hpl
        M.rel M.pb hl1 hev)
  | storageLive l =>
    have hpc : s1.pc = r.2 := by rw [hpc0, rangeInsns_nil h1 h2 hR]
    obtain ⟨hdead, sd, hsd, hsz⟩ := hfn.fresh f.bb bd f.stmt l M.hbd hst
    -- `l` is storage-dead before (the storage table over-approximates)
    have hl : ∀ p, f.locals[l]? ≠ some (some p) := by
      intro p hp
      have := M.sl l p hp
      rw [hdead] at this
      cases this
    have hpriv : ∀ k < sd.size, s1.st.escapedAt (sd.off + k) = none := by
      intro k _
      cases he : s1.st.escapedAt (sd.off + k) with
      | none => rfl
      | some e =>
        have := M.rel.esc _ e he
        rw [hfn.noEsc] at this
        cases this
    have happ : ∀ l' (p' : ThinPointer) sl', l' ≠ l → f.locals[l']? = some (some p') →
        Γ.toStmtCtx.slots[l']? = some sl' → SlotsApart sd sl' ∧ SlotsApart sl' sd :=
      fun l' p' sl' hne hp' hsl' => by
        have hd := hfn.share.2 f.bb bd M.hbd f.stmt l (.inl hst) l' (Ne.symm hne)
          (M.sl l' p' hp') sd sl' hsd hsl'
        exact ⟨hd, hd.symm⟩
    have hbd' : f.body.blocks[f.bb]? = some bd := by rw [M.body]; exact M.hbd
    have hlive' : ∀ l', (computeLive Γ.body).get f.bb (f.stmt + 1) l' = true →
        l' = l ∨ (computeLive Γ.body).get f.bb f.stmt l' = true := by
      intro l' hl'
      by_cases e : l' = l
      · exact .inl e
      · exact .inr ((hfn.live.stmt f.bb bd M.hbd f.stmt _ hst).1 l' hl'
          (by intro h; exact e (Option.some.inj h).symm))
    obtain ⟨f', hs', hb', hbb', hst', hrel'⟩ := lift_storageLive M.stack M.rel hl hsd
      (fun ty hty => hsz ty (by rw [← M.body]; exact hty))
      (fun ty p m' s2 hty hal => hpick.1 f rest bd l sd ty p m' s2 M.stack hbd' hst hsd hty hal)
      hpriv happ M.pb.hidden (M.fresh _ (Nat.le_refl _)) hlive' hev
    -- the new frame and memory, from the inversion
    obtain ⟨ty, size, p, m', s2, hty, hsz', hal, hs2, hs1x⟩ :=
      storageLive_dead M.stack hl (show runOn (storageLive l) o s = _ from hev)
    subst hs1x
    obtain ⟨e, -⟩ := List.cons.inj hs'
    subst e
    obtain ⟨a, hda, hpa, -, -, -, -, hm', hok, -⟩ := runOn_allocate_ok hal
    refine ⟨s1, _, .refl _, rfl, rfl, rfl, rfl, rfl, rfl, hpc, hrel', ?_, ?_, ?_, ?_⟩
    · intro l' p' hp'
      by_cases e : l' = l
      · rw [e]
        have hlt : l < f.body.locals.size := (Array.getElem?_eq_some_iff.mp hty).1
        rw [M.body] at hlt
        exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).2 l rfl hlt
      · have hp'' : (f.locals.set! l (some p))[l']? = some (some p') := hp'
        rw [getElem?_set!_ne e] at hp''
        exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l' (M.sl l' p' hp'')
          (by intro e'; cases e')
    · exact M.pb.allocate hal
    · intro x hx
      apply M.fresh
      have hx' : m'.allocs.size ≤ x := hx
      rw [hm', Array.size_push] at hx'
      exact Nat.le_of_succ_le hx'
    · show DerefInv ι m'
      rw [hm']
      exact M.dinv.push M.pb hda (by rw [hpa]; exact hok)
  | storageDead l =>
    have hpc : s1.pc = r.2 := by rw [hpc0, rangeInsns_nil h1 h2 hR]
    have hdead := hfn.deadAfter f.bb bd f.stmt l M.hbd hst
    have hlive' : ∀ l', (computeLive Γ.body).get f.bb (f.stmt + 1) l' = true →
        (computeLive Γ.body).get f.bb f.stmt l' = true := by
      intro l' hl'
      by_cases e : l' = l
      · subst e; rw [hdead] at hl'; cases hl'
      · exact (hfn.live.stmt f.bb bd M.hbd f.stmt _ hst).1 l' hl'
          (by intro h; exact e (Option.some.inj h).symm)
    obtain ⟨f', hs', hb', hbb', hst', hrel'⟩ := lift_storageDead M.stack M.rel hlive' hev
    -- the new frame and memory, from the inversion
    have hev' : runOn (storageDead l) o s = (.ok (), s1x) := hev
    by_cases hlv : ∃ p, f.locals[l]? = some (some p)
    · obtain ⟨p, hp⟩ := hlv
      obtain ⟨ty, m', -, hd, hs1x⟩ := storageDead_live M.stack hp
        (by rw [M.rel.unaliased]; rfl) hev'
      subst hs1x
      obtain ⟨e, -⟩ := List.cons.inj hs'
      subst e
      refine ⟨s1, _, .refl _, rfl, rfl, rfl, rfl, rfl, rfl, hpc, hrel', ?_, M.pb.dealloc hd, ?_,
        M.dinv.of_memKept (memKept_dealloc hd)⟩
      · intro l' p' hp'
        by_cases e : l' = l
        · have hp'' : (f.locals.set! l none)[l']? = some (some p') := hp'
          rw [e] at hp''
          exact absurd (getElem?_set!_self hp'') (by simp)
        · have hp'' : (f.locals.set! l none)[l']? = some (some p') := hp'
          rw [getElem?_set!_ne e] at hp''
          exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l' (M.sl l' p' hp'')
            (by intro h; exact e (Option.some.inj h).symm)
      · intro x hx
        apply M.fresh
        have hx' : m'.allocs.size ≤ x := hx
        rw [dealloc_size hd] at hx'
        exact hx'
    · have hl' : ∀ p, f.locals[l]? ≠ some (some p) := fun p hp => hlv ⟨p, hp⟩
      rw [storageDead_dead M.stack hl'] at hev'
      obtain ⟨-, rfl⟩ := prod_ok_inj hev'
      rw [M.stack] at hs'
      obtain ⟨e, -⟩ := List.cons.inj hs'
      subst e
      refine ⟨s1, f, .refl _, M.stack, rfl, rfl, rfl, rfl, rfl, hpc, hrel', ?_, M.pb, M.fresh,
        M.dinv⟩
      intro l' p' hp'
      exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l' (M.sl l' p' hp')
        (by
          intro h
          have e : l' = l := (Option.some.inj h).symm
          subst e
          exact hl' p' hp')

/-! ### Terminators -/

/-- A non-`return` terminator a rule lowers moves the frame to one of its successors. -/
theorem term_next {Γ : TermCtx} {next : Nat} {term : Terminator} {is : List R.Insn}
    (hlow : LowerTerm Γ next term is) (hnr : term ≠ .return) {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (h : runOn (evalTerminator term) o s = (.ok (), s')) :
    ∃ b', b' ∈ termSuccs term ∧ s'.stack = { f with bb := b', stmt := 0 } :: rest ∧
      s'.mem = s.mem := by
  have hsw : ∀ {d : Operand} {l : Local} {cs : List (Nat × BasicBlock)} {ow : BasicBlock},
      d.local? = some l →
      runOn (evalTerminator (.switchInt d cs ow)) o s = (.ok (), s') →
      ∃ b', b' ∈ termSuccs (.switchInt d cs ow) ∧
        s'.stack = { f with bb := b', stmt := 0 } :: rest ∧ s'.mem = s.mem := by
    intro d l cs ow hd h
    obtain ⟨_, _, _, bits, _, _, _, _, rfl⟩ := switchInt_inv hs hd h
    refine ⟨_, ?_, rfl, rfl⟩
    simp only [termSuccs, List.mem_append, List.mem_map, List.mem_singleton]
    cases hf : cs.find? (·.1 == bits) with
    | none => exact .inr rfl
    | some x => exact .inl ⟨x, List.mem_of_find?_eq_some hf, rfl⟩
  cases hlow
  case goto =>
    rw [goto_inv hs h]
    exact ⟨_, List.mem_singleton.mpr rfl, rfl, rfl⟩
  case ret => exact absurd rfl hnr
  case switchNone hd _ => exact hsw hd h
  case switchBool => exact hsw (by assumption) h
  case switchInt => exact hsw (by assumption) h

end Ryo.Proofs.Lower
