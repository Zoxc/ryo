/-
Ryo.Proofs.Lower.SimDerefSplit — the simulation of `LowerDerefSplit`
(`Check/Lower/DerefSplit.lean`, M5b): `(*_p).f₁.….fₖ = copy/move _a` lowered to one `store` per
piece of `_a`'s `n` bytes through `_p`.

- L0 (`derefStore_mem`, as `lift_derefStore`): one store of the re-encoding `bsd` of `_a`'s
  bytes at `q + off`. `store_append` splits a store of `xs ++ ys` into a store of `xs` and one
  of `ys` right after it (the stored-to allocation's data: `foldl_set_append`), so L0's store is
  the pieces' stores in turn, each from an intermediate L0 memory.
- R, per piece (`sim_storePieceR`, `SimStoreTemp.sim_derefStoreBytes` with R's pointer given):
  the pointer read from `_p`'s slot, the piece's bytes from `_a`'s, the store through the image
  allocation (`store_inj`), keeping `MemInj` and every `LocalRel`. `_p`'s and `_a`'s slots are
  private, so the earlier pieces' memory stores leave what the later ones read
  (`readFrame_mem_priv`, `byteAt_mem_priv`); `LiveDisjoint` survives each L0 piece store
  (`liveDisjoint_store`). `sim_storePieces` runs them all.
- R offsets the pointer by each piece's offset with a wrapping add; it agrees with L0's address
  because the stored range lies in a live L0 allocation, which ends below `ADDR_LIMIT`
  (`AllocsBelow`, a hypothesis of the lift: see `AllocsBelow.lean`).
- The stored provenance is `_a`'s loaded bytes' (`bytesLeDefined_prov`), which keeps `Hidden`,
  the provenance bound and `MemKept` (as `lift_derefStore`).
-/
import Ryo.Proofs.Lower.SimDeref
import Ryo.Proofs.Lower.SimAgg
import Ryo.Proofs.Lower.AllocsBelow
import Ryo.Check.Lower.DerefSplit

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Proofs.Provenance (LiveDisjoint)

/-! ### L0: a store in two parts -/

theorem align_one_ok (x : Nat) : Align.one.isAligned x = true := by
  simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]

theorem store_nil_one (m : Memory) (P : ThinPointer) : m.store P [] .one = .ok m := by
  have hal := align_one_ok P.addr
  first
    | (simp [Memory.store, hal, Memory.checkPtr]; done)
    | (simp [Memory.store, hal, Memory.checkPtr] <;> rfl)

/-- The data written by a store of `xs ++ ys` is that of `xs`, then `ys` right after it. -/
theorem foldl_set_append (xs ys : List AbstractByte) (off : Nat) (d : Array AbstractByte) :
    ((xs ++ ys).zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) d =
      (ys.zipIdx).foldl (fun d (b, i) => d.set! (off + xs.length + i) b)
        ((xs.zipIdx).foldl (fun d (b, i) => d.set! (off + i) b) d) := by
  apply Array.ext_getElem?
  intro j
  rw [Ryo.Spec.Theorems.foldl_set_getElem, Ryo.Spec.Theorems.foldl_set_getElem,
    Ryo.Spec.Theorems.foldl_set_getElem, Ryo.Spec.Theorems.foldl_set_size]
  simp only [Nat.add_zero, Nat.sub_zero, List.length_append]
  by_cases c1 : off ≤ j ∧ j < off + (xs.length + ys.length) ∧ j < d.size
  · rw [if_pos c1]
    by_cases c2 : off + xs.length ≤ j ∧ j < off + xs.length + ys.length ∧ j < d.size
    · have e : (xs ++ ys)[j - off]? = ys[j - off - xs.length]? :=
        List.getElem?_append_right (by omega)
      rw [if_pos c2, e, Nat.sub_sub]
    · rw [if_neg c2]
      have c3 : off ≤ j ∧ j < off + xs.length ∧ j < d.size := by omega
      have e : (xs ++ ys)[j - off]? = xs[j - off]? := List.getElem?_append_left (by omega)
      rw [if_pos c3, e]
  · rw [if_neg c1]
    have c2 : ¬(off + xs.length ≤ j ∧ j < off + xs.length + ys.length ∧ j < d.size) := by
      omega
    have c3 : ¬(off ≤ j ∧ j < off + xs.length ∧ j < d.size) := by omega
    rw [if_neg c2, if_neg c3]

/-- A store of non-empty bytes: the stored-to allocation and the memory after, pointwise. -/
theorem store_get?_eq {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (h : m.store p bs al = .ok m') (hne : bs ≠ []) :
    ∃ id, ∃ hid : id < m.allocs.size, p.prov = some id ∧ m.allocs[id].live = true ∧
      m.allocs[id].addr ≤ p.addr ∧
      p.addr + bs.length ≤ m.allocs[id].addr + m.allocs[id].data.size ∧
      m.allocs[id].mutable = true ∧
      ∀ j, m'.get? j = if id = j then some { m.allocs[id] with
        data := (bs.zipIdx).foldl (fun d (b, i) => d.set! (p.addr - m.allocs[id].addr + i) b)
          m.allocs[id].data } else m.get? j := by
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h with
    ⟨_, hl, -⟩ | ⟨id, hid, _, _, hprov, hlv, h1, h2, hm, rfl⟩
  · exact absurd (List.eq_nil_of_length_eq_zero hl) hne
  · refine ⟨id, hid, hprov, hlv, h1, h2, hm, fun j => ?_⟩
    unfold Memory.get?
    first
      | (rw [Array.getElem?_set]; done)
      | (rw [Array.getElem?_set]; rfl)
      | simp [Array.getElem?_set]

/-- A store of `xs ++ ys` is a store of `xs`, then one of `ys` right after it. -/
theorem store_append {m m' : Memory} {pa : Nat} {pp : Option AllocId}
    {xs ys : List AbstractByte} (h : m.store ⟨pa, pp⟩ (xs ++ ys) .one = .ok m') :
    ∃ m1, m.store ⟨pa, pp⟩ xs .one = .ok m1 ∧
      m1.store ⟨pa + xs.length, pp⟩ ys .one = .ok m' := by
  by_cases hx : xs = []
  · subst hx
    refine ⟨m, store_nil_one m _, ?_⟩
    simpa using h
  by_cases hy : ys = []
  · subst hy
    exact ⟨m', by simpa using h, store_nil_one m' _⟩
  have hne : xs ++ ys ≠ [] := by
    intro e
    apply hx
    cases xs with
    | nil => rfl
    | cons _ _ => cases e
  obtain ⟨id, hid, hprov, hlv, h1, h2, hm, hch⟩ := store_get?_eq h hne
  have h1' : m.allocs[id].addr ≤ pa := h1
  have h2' : pa + (xs.length + ys.length) ≤ m.allocs[id].addr + m.allocs[id].data.size := by
    have h2'' := h2
    simp only [List.length_append] at h2''
    exact h2''
  have hxl : xs.length ≠ 0 := fun e => hx (List.eq_nil_of_length_eq_zero e)
  have hyl : ys.length ≠ 0 := fun e => hy (List.eq_nil_of_length_eq_zero e)
  -- the first part
  obtain ⟨m1, hs1⟩ := store_ok_exists (mem := m) (q := ⟨pa, pp⟩) (bytes := xs) (al := .one)
    hid (align_one_ok pa) hxl hprov hlv h1
    (show pa + xs.length ≤ m.allocs[id].addr + m.allocs[id].data.size by omega) hm
  obtain ⟨id1, hid1, hprov1, -, -, -, -, hch1⟩ := store_get?_eq hs1 hx
  have e1 : id1 = id := Option.some.inj (hprov1.symm.trans hprov)
  subst id1
  refine ⟨m1, hs1, ?_⟩
  obtain ⟨hidm1, hm1e⟩ := Array.getElem?_eq_some_iff.mp
    (show m1.allocs[id]? = some _ from (hch1 id).trans (if_pos rfl))
  have hlv1 : (m1.allocs[id]'hidm1).live = true := by rw [hm1e]; exact hlv
  have haddr1 : (m1.allocs[id]'hidm1).addr = m.allocs[id].addr := by
    first | (rw [hm1e]; done) | (rw [hm1e]; rfl)
  have hsz1 : (m1.allocs[id]'hidm1).data.size = m.allocs[id].data.size := by
    rw [hm1e]; exact Ryo.Spec.Theorems.foldl_set_size _ _ _ _
  have hmut1 : (m1.allocs[id]'hidm1).mutable = true := by rw [hm1e]; exact hm
  -- the second part
  obtain ⟨m2, hs2⟩ := store_ok_exists (mem := m1) (q := ⟨pa + xs.length, pp⟩) (bytes := ys)
    (al := .one) hidm1 (align_one_ok _) hyl hprov hlv1
    (by rw [haddr1]; show m.allocs[id].addr ≤ pa + xs.length; omega)
    (by
      rw [haddr1, hsz1]
      show pa + xs.length + ys.length ≤ m.allocs[id].addr + m.allocs[id].data.size
      omega)
    hmut1
  obtain ⟨id2, hid2, hprov2, -, -, -, -, hch2⟩ := store_get?_eq hs2 hy
  have e2 : id2 = id := Option.some.inj (hprov2.symm.trans hprov)
  subst id2
  -- both parts write what the whole does
  have hF : (ys.zipIdx).foldl (fun d (b, i) => d.set! (pa + xs.length - m.allocs[id].addr + i) b)
      ((xs.zipIdx).foldl (fun d (b, i) => d.set! (pa - m.allocs[id].addr + i) b)
        m.allocs[id].data) =
      ((xs ++ ys).zipIdx).foldl (fun d (b, i) => d.set! (pa - m.allocs[id].addr + i) b)
        m.allocs[id].data := by
    have hoff : pa + xs.length - m.allocs[id].addr = pa - m.allocs[id].addr + xs.length := by
      omega
    rw [hoff]
    exact (foldl_set_append xs ys (pa - m.allocs[id].addr) m.allocs[id].data).symm
  have hm2 : m2 = m' := by
    have hall : m2.allocs = m'.allocs := by
      apply Array.ext_getElem?
      intro j
      show m2.get? j = m'.get? j
      rw [hch2 j, hch j]
      by_cases hj : id = j
      · rw [← hj, if_pos rfl, if_pos rfl, hm1e]
        exact congrArg (fun d => some ({ m.allocs[id] with data := d } : Allocation)) hF
      · rw [if_neg hj, if_neg hj, hch1 j, if_neg hj]
    obtain ⟨a2⟩ := m2
    obtain ⟨a'⟩ := m'
    exact congrArg Memory.mk hall
  rw [← hm2]
  exact hs2

/-- A store keeps L0's live allocations disjoint (it changes no address, size or liveness). -/
theorem liveDisjoint_store {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte}
    {al : Align} (hld : LiveDisjoint m) (h : m.store p bs al = .ok m') : LiveDisjoint m' := by
  intro i j a b x hi hj hla hlb h1 h2 h3 h4
  obtain ⟨a0, ha0, ea, el, es⟩ := store_get?_fwd h hi
  obtain ⟨b0, hb0, eb, el', es'⟩ := store_get?_fwd h hj
  simp only [Allocation.size] at h2 h4
  exact hld i j a0 b0 x ha0 hb0 (el.trans hla) (el'.trans hlb) (by omega)
    (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)

/-! ### R: private frame bytes under memory stores -/

theorem mapM_congr_memE {α β ε : Type} {f g : α → Except ε β} :
    ∀ (l : List α), (∀ x ∈ l, f x = g x) → l.mapM f = l.mapM g
  | [], _ => rfl
  | x :: l, h => by
    rw [List.mapM_cons, List.mapM_cons, h x (List.mem_cons_self ..),
      mapM_congr_memE l (fun y hy => h y (List.mem_cons_of_mem _ hy))]

/-- A private frame byte does not depend on memory. -/
theorem byteAt_mem_priv {st : OpSem.State} {mem' : Memory} {o : Int}
    (h : st.escapedAt o = none) :
    ({ st with mem := mem' } : OpSem.State).byteAt o = st.byteAt o := by
  have h' : ({ st with mem := mem' } : OpSem.State).escapedAt o = none := h
  unfold OpSem.State.byteAt
  first
    | (rw [h', h]; done)
    | (rw [h', h]; rfl)
    | simp only [h, h']
    | simp [h, h']

/-- Private frame bytes do not depend on memory. -/
theorem readFrame_mem_priv {st : OpSem.State} {mem' : Memory} {off : Int} {n : Nat}
    (h : ∀ i < n, st.escapedAt (off + i) = none) :
    ({ st with mem := mem' } : OpSem.State).readFrame off n = st.readFrame off n := by
  unfold OpSem.State.readFrame
  exact mapM_congr_memE _ (fun i hi => byteAt_mem_priv (h i (List.mem_range.mp hi)))

/-! ### R: one piece -/

/-- One piece: R's `store` of `ba` (read from frame slot `S`) through the pointer `q1` read from
frame slot `P`, offset by `off`, against L0's store of `bsd` at `q + off` (as
`SimStoreTemp.sim_derefStoreBytes`, R's pointer given). -/
theorem sim_storePieceR {ι : Inj} {fp : Nat} {st : OpSem.State} {m m1 : Memory}
    {q q1 : ThinPointer} {a0 b0 : AllocId} (hqa : q.prov = some a0) (hb0 : ι a0 = some b0)
    (hpq : PtrInj ι q q1) {off n : Nat} (hlim : q.addr + off < Target.ADDR_LIMIT)
    {bsd ba : List AbstractByte} (hbs : BytesInj ι bsd ba) (hlend : bsd.length = n)
    (hpos : 0 < n)
    (hsto : m.store ⟨q.addr + off, q.prov⟩ bsd .one = .ok m1)
    (hld : LiveDisjoint m) (hmem : MemInj ι m st.mem)
    {P S : Int} {bp1 : List AbstractByte} (hrfp : st.readFrame P 8 = .ok bp1)
    (hq1 : decodePtr bp1 = some q1) (hrfa : st.readFrame S n = .ok ba)
    {opc : Full.Opcode} {r : Option String} {tyN : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.store, [tyN], r⟩)
    (hty : OpSem.Ty.parse tyN = some (.int n sg))
    (ho : opc.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ P ∧ P < 2 ^ 31 ∧ -2 ^ 31 ≤ (off : Int) ∧ (off : Int) < 2 ^ 31 ∧
      -2 ^ 31 ≤ S ∧ S < 2 ^ 31)
    {ch : OpSem.Choice} :
    ∃ mem', opSem opc [.mem P (off : Int), .slot S] st ch =
        .ok (.next, { st with mem := mem' }) ∧
      MemInj ι m1 mem' ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st m slot p lv →
        LocalRel ι fp { st with mem := mem' } m1 slot p lv := by
  have hlenba : ba.length = bsd.length := (BytesInj.length hbs).symm
  have hN : bsd.length ≠ 0 := by omega
  have hwo : (q1.wrappingOffset (off : Int)).addr = q.addr + off :=
    wrappingOffset_addr hpq.1 hlim
  have hpi : PtrInj ι ⟨q.addr + off, q.prov⟩ (q1.wrappingOffset (off : Int)) := by
    unfold PtrInj
    exact ⟨hwo.symm, hpq.2⟩
  -- the stored-to allocation
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
    ⟨_, hl0, -⟩ | ⟨id, hid, _, _, hprov, hlv, h1, h2, -, -⟩
  · exact absurd hl0 hN
  have h1n : m.allocs[id].addr ≤ q.addr + off := h1
  have h2n : q.addr + off + bsd.length ≤ m.allocs[id].addr + m.allocs[id].data.size := h2
  have hia0 : id = a0 := Option.some.inj (hprov.symm.trans hqa)
  have hbid : ι id = some b0 := by rw [hia0]; exact hb0
  -- R's store resolves to `b0`
  have hc := (Ryo.Spec.Theorems.Memory.checkPtr_eq_ok (mem := m)
    (p := ⟨q.addr + off, q.prov⟩) (len := ba.length)
    (r := some (id, (⟨q.addr + off, q.prov⟩ : ThinPointer).addr - m.allocs[id].addr))).mpr
    (.inr ⟨id, hid, by omega, hprov, hlv, h1, by rw [hlenba]; exact h2, rfl⟩)
  have hres := resolve_inj_of_checkPtr (st := st) hmem hpi hprov hbid (by omega) hc
  have hal : Align.one.isAligned (⟨q.addr + off, q.prov⟩ : ThinPointer).addr = true := by
    simp [Align.isAligned, Align.one, Align.bytes, Nat.mod_one]
  -- the other L0 allocations in `b0` are apart from the stored range (`LiveDisjoint`)
  have hdisj : ∀ a' x', m.get? a' = some x' → x'.live = true → ι a' = some b0 → a' ≠ a0 →
      x'.size = 0 ∨ x'.addr + x'.size ≤ (⟨q.addr + off, q.prov⟩ : ThinPointer).addr ∨
      (⟨q.addr + off, q.prov⟩ : ThinPointer).addr + bsd.length ≤ x'.addr := by
    intro a' x' hx' hl' _ hne
    show x'.size = 0 ∨ x'.addr + x'.size ≤ q.addr + off ∨ q.addr + off + bsd.length ≤ x'.addr
    simp only [Allocation.size]
    by_cases g0 : x'.data.size = 0
    · exact .inl g0
    by_cases g1 : x'.addr + x'.data.size ≤ q.addr + off
    · exact .inr (.inl g1)
    by_cases g2 : q.addr + off + bsd.length ≤ x'.addr
    · exact .inr (.inr g2)
    exfalso
    apply hne
    rw [← hia0]
    rcases Nat.le_total x'.addr (q.addr + off) with hle' | hle'
    · exact hld a' id x' m.allocs[id] (q.addr + off) hx' (get?_of_lt hid) hl' hlv hle'
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
    · exact hld a' id x' m.allocs[id] x'.addr hx' (get?_of_lt hid) hl' hlv (Nat.le_refl _)
        (by simp only [Allocation.size]; omega) (by omega) (by simp only [Allocation.size]; omega)
  obtain ⟨m1', hst1, hmi⟩ := store_inj (p := ⟨q.addr + off, q.prov⟩) hmem hqa hb0 hbs hal hsto
    hdisj
  have hPeq : ({ q1.wrappingOffset (off : Int) with prov := some b0 } : ThinPointer) =
      { (⟨q.addr + off, q.prov⟩ : ThinPointer) with prov := some b0 } := by
    show (⟨(q1.wrappingOffset (off : Int)).addr, some b0⟩ : ThinPointer) = ⟨q.addr + off, some b0⟩
    rw [hwo]
  have hRst : st.store st.mem (q1.wrappingOffset (off : Int)) ba = .ok m1' := by
    unfold OpSem.State.store
    rw [Ryo.Proofs.Inline.liftOutcome_ok, hres, hPeq]
    exact hst1
  have hop := opSem_store_fwd (ch := ch) hh hty ho hfits hrfp hq1 hrfa hRst
  refine ⟨m1', hop, hmi, ?_⟩
  intro slot p lv hr
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpriv hbytes =>
    -- `a` is unmapped, so it is not the stored-to allocation
    have hne : (⟨q.addr + off, q.prov⟩ : ThinPointer).prov ≠ some a := by
      show q.prov ≠ some a
      rw [hqa]
      intro he
      have e : a0 = a := Option.some.inj he
      rw [e, hι] at hb0
      cases hb0
    have hx' : m1.get? a = some x := by
      rw [get?_store_other hsto (.inl hne)]
      exact hx
    exact .priv a x hp hι hx' hlive haddr hpaddr hsize hpriv hbytes
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    obtain ⟨x', hx', ea, el, es⟩ := store_get?_bwd hsto hx
    obtain ⟨y', hy', eya, eyl, eys⟩ := store_get?_bwd hst1 hy
    exact .esc a x' e y' hp hι hx' (el.trans hlive) (by rw [ea]; exact haddr)
      (by rw [ea]; exact hpaddr) (by rw [es]; exact hsize) hin hy' (eyl.trans hylive)
      (by rw [eya]; exact hyaddr) (by rw [eys]; exact hysize)

/-! ### R: all the pieces -/

/-- The pieces of widths `ws` from offset `o`, against L0's store of the remaining bytes `bs` at
`q + K + o`: R's stores in turn, each against L0's store of its part (`store_append`). The
pointer slot `P` and the source bytes at `S + o + i` (`g (o + i)`, refining `bs[i]`) are
private, so the stores leave them. -/
theorem sim_storePieces {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} (hmode : Γ.mode = c.mode)
    (hρ : Γ.ρ = c.ρ) {ι : Inj} {q q1 : ThinPointer} {a0 b0 : AllocId} (hqa : q.prov = some a0)
    (hb0 : ι a0 = some b0) (hpq : PtrInj ι q q1) {P S : Int} {K : Nat}
    {bp1 : List AbstractByte} (hq1 : decodePtr bp1 = some q1) {g : Nat → AbstractByte}
    (hP : -2 ^ 31 ≤ P ∧ P < 2 ^ 31) :
    ∀ (ws : List Nat) (is : List R.Insn) (o : Nat) (bs : List AbstractByte) (m mEnd : Memory)
      (s1 : R.RState),
    storePiecesOk Γ P K S o is ws = true →
    (∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj)) →
    (∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) → c.mode.pe = false →
    (∀ i ∈ is, PlainView c.mode c.ρ i) →
    bs.length = ws.sum →
    q.addr + K + o + bs.length ≤ Target.ADDR_LIMIT →
    (K : Int) + (o : Int) + (bs.length : Int) < 2 ^ 31 → -2 ^ 31 ≤ S →
    S + (o : Int) + (bs.length : Int) < 2 ^ 31 →
    s1.st.readFrame P 8 = .ok bp1 → (∀ i : Nat, i < 8 → s1.st.escapedAt (P + (i : Int)) = none) →
    (∀ i (h : i < bs.length), s1.st.byteAt (S + (o : Int) + (i : Int)) = .ok (g (o + i)) ∧
      ByteInj ι bs[i] (g (o + i))) →
    (∀ i < bs.length, s1.st.escapedAt (S + (o : Int) + (i : Int)) = none) →
    MemInj ι m s1.st.mem → LiveDisjoint m →
    m.store ⟨q.addr + K + o, q.prov⟩ bs .one = .ok mEnd →
    ∃ mem', StepsTo c ch s1 { s1 with pc := s1.pc + is.length, st := { s1.st with mem := mem' } } ∧
      MemInj ι mEnd mem' ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st m slot p lv →
        LocalRel ι s1.fp { s1.st with mem := mem' } mEnd slot p lv := by
  intro ws
  induction ws with
  | nil =>
    intro is o bs m mEnd s1 hok _ _ _ _ hlen _ _ _ _ _ _ _ _ hmem _ hsto
    cases is with
    | cons _ _ => simp [storePiecesOk] at hok
    | nil =>
      have hbs : bs = [] := List.eq_nil_of_length_eq_zero (by simpa using hlen)
      subst hbs
      rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
        ⟨_, _, rfl⟩ | ⟨_, _, _, hl, _⟩
      · exact ⟨s1.st.mem, .refl _, hmem, fun _ _ _ hr => hr⟩
      · exact (hl rfl).elim
  | cons w ws ih =>
    intro is o bs m mEnd s1 hok hi hsc hpe hpl hlen hlim hK hS0 hS hrfp hPe hbyte hSe hmem hld
      hsto
    cases is with
    | nil => simp [storePiecesOk] at hok
    | cons i is =>
      simp only [storePiecesOk, Bool.and_eq_true, decide_eq_true_eq] at hok
      obtain ⟨⟨hw0, hii⟩, hrest⟩ := hok
      -- L0: the piece's store, then the rest
      have hlen' : bs.length = w + ws.sum := by rw [hlen, List.sum_cons]
      have htl : (bs.take w).length = w := by rw [List.length_take]; omega
      have hdl : (bs.drop w).length = ws.sum := by rw [List.length_drop]; omega
      have hsto' : m.store ⟨q.addr + K + o, q.prov⟩ (bs.take w ++ bs.drop w) .one = .ok mEnd := by
        rw [List.take_append_drop]; exact hsto
      obtain ⟨m1, hs1, hs2⟩ := store_append hsto'
      rw [htl] at hs2
      have hs1' : m.store ⟨q.addr + (K + o), q.prov⟩ (bs.take w) .one = .ok m1 := by
        rw [show q.addr + (K + o) = q.addr + K + o by omega]; exact hs1
      have hs2' : m1.store ⟨q.addr + K + (o + w), q.prov⟩ (bs.drop w) .one = .ok mEnd := by
        rw [show q.addr + K + (o + w) = q.addr + K + o + w by omega]; exact hs2
      -- R: the piece's instruction and bytes
      obtain ⟨v, tyN, r, hv, hh, hty, ho, hops, hctl⟩ := storeInsnOk_spec hii
      rw [hmode, hρ] at hv
      obtain ⟨sg, hty'⟩ := intTyOk_spec hty
      have hrfa : s1.st.readFrame (S + (o : Int)) w =
          .ok ((List.range w).map (fun k => g (o + k))) :=
        readFrame_eq_map (fun k hk => (hbyte k (by omega)).1)
      have hbw : BytesInj ι (bs.take w) ((List.range w).map (fun k => g (o + k))) := by
        apply BytesInj.of_getElem (by rw [htl, List.length_map, List.length_range])
        intro k h0 h1
        have hk : k < bs.length := by omega
        first
          | (simp only [List.getElem_take, List.getElem_map, List.getElem_range]
             exact (hbyte k hk).2)
          | (have hb2 := (hbyte k hk).2
             simpa using hb2)
      have hlimw : q.addr + (K + o) < Target.ADDR_LIMIT := by omega
      have hfits : -2 ^ 31 ≤ P ∧ P < 2 ^ 31 ∧ -2 ^ 31 ≤ ((K + o : Nat) : Int) ∧
          ((K + o : Nat) : Int) < 2 ^ 31 ∧ -2 ^ 31 ≤ S + (o : Int) ∧ S + (o : Int) < 2 ^ 31 :=
        ⟨hP.1, hP.2, by omega, by omega, by omega, by omega⟩
      obtain ⟨mem1, hop, hmi1, hloc1⟩ := sim_storePieceR (fp := s1.fp) (ch := ch) hqa hb0 hpq
        hlimw hbw htl hw0 hs1' hld hmem hrfp hq1 hrfa hh hty' ho hfits
      have e : ((K + o : Nat) : Int) = (K : Int) + (o : Int) := by omega
      have hstep : R.step c s1 ch =
          .ok (.step { s1 with pc := s1.pc + 1, st := { s1.st with mem := mem1 } }) :=
        step_of_view (hi 0 (by simp)) (hsc 0 (by simp)) hpe (hpl i (List.mem_cons_self ..)) hv
          hctl (by rw [hops, ← e]; exact hop)
      -- the rest
      obtain ⟨mem', hsteps, hmi', hloc'⟩ :=
        ih is (o + w) (bs.drop w) m1 mEnd
          { s1 with pc := s1.pc + 1, st := { s1.st with mem := mem1 } } hrest
          (fun j hj => by
            have := hi (j + 1) (by simp; omega)
            rw [show s1.pc + (j + 1) = s1.pc + 1 + j by omega] at this
            simpa using this)
          (fun j hj => by
            have := hsc (j + 1) (by simp; omega)
            rw [show s1.pc + (j + 1) = s1.pc + 1 + j by omega] at this
            simpa using this)
          hpe (fun i' hi' => hpl i' (List.mem_cons_of_mem _ hi')) hdl (by omega) (by omega) hS0
          (by omega)
          (by
            show ({ s1.st with mem := mem1 } : OpSem.State).readFrame P 8 = .ok bp1
            rw [readFrame_mem_priv hPe]
            exact hrfp)
          (fun k hk => hPe k hk)
          (fun k hk => by
            have hk2 : w + k < bs.length := by omega
            obtain ⟨hb1, hb2⟩ := hbyte (w + k) hk2
            have e2 : S + ((o + w : Nat) : Int) + (k : Int) =
                S + (o : Int) + ((w + k : Nat) : Int) := by omega
            have e3 : o + w + k = o + (w + k) := by omega
            refine ⟨?_, ?_⟩
            · show ({ s1.st with mem := mem1 } : OpSem.State).byteAt
                (S + ((o + w : Nat) : Int) + (k : Int)) = .ok (g (o + w + k))
              rw [e2, e3, byteAt_mem_priv (hSe (w + k) hk2)]
              exact hb1
            · first
                | (simp only [List.getElem_drop]; rw [e3]; exact hb2)
                | (simpa [List.getElem_drop, e3] using hb2))
          (fun k hk => by
            show s1.st.escapedAt (S + ((o + w : Nat) : Int) + (k : Int)) = none
            rw [show S + ((o + w : Nat) : Int) + (k : Int) = S + (o : Int) + ((w + k : Nat) : Int)
              by omega]
            exact hSe (w + k) (by omega))
          hmi1 (liveDisjoint_store hld hs1) hs2'
      refine ⟨mem', ?_, hmi', fun slot p lv hr => hloc' slot p lv (hloc1 slot p lv hr)⟩
      have hsteps' : StepsTo c ch { s1 with pc := s1.pc + 1, st := { s1.st with mem := mem1 } }
          { s1 with pc := s1.pc + 1 + is.length, st := { s1.st with mem := mem' } } := hsteps
      rw [show s1.pc + 1 + is.length = s1.pc + (i :: is).length by
        simp only [List.length_cons]; omega] at hsteps'
      exact .cons hstep hsteps'

/-! ### The lift -/

/-- `LowerDerefSplit`'s lift: the pieces of `_a`'s `n` bytes stored through `_p`. Takes, beyond
`lift_derefStore`'s hypotheses, `AllocsBelow` (see the module comment). -/
theorem lift_derefSplit {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {pl : MPlace} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerDerefSplit Γ (.assign pl rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem) (hmap : Hidden s.mem (Unmapped ι s.mem))
    (hld : LiveDisjoint s.mem) (hbelow : AllocsBelow s.mem)
    (hlo : ∀ l ∈ stmtReads (.assign pl rv), live l = true)
    (hlive' : ∀ l, live' l = true → live l = true)
    (h : runOn (evalStatement (.assign pl rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | @store p a oa pointee ty fields pt valid off n sp sa ws is ha htp hk hpath hta hn hpos hwf
      hsp hsa hsize hoff hprivp hpriva hws his =>
    rw [eval_use_norm ha] at h
    rw [hbody] at htp hta
    obtain ⟨pp, pa, bp, q, bsa, w, bsd, hpp, hpa, hlp, hq, hlim, hla, hd, hen, hsto, hstk⟩ :=
      derefStore_mem hs htp hk hpath hta hn h
    -- `_p` and `_a` are read, so live
    have hmemp : p ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) := by
      show p ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.use oa)
      simp [placeLocals]
    have hmema : a ∈ stmtReads (.assign ⟨p, .deref pointee :: fields⟩ (.use oa)) := by
      show a ∈ placeLocals ⟨p, .deref pointee :: fields⟩ ++ rvalueLocals (.use oa)
      rcases local?_cases ha with rfl | rfl <;>
        simp [placeLocals, rvalueLocals, operandLocals]
    have hrp := hrel.opnd hpp hsp (hlo _ hmemp)
    have hra := hrel.opnd hpa hsa (hlo _ hmema)
    have hbl : bsa.length = n := load_length hla
    have hle := reenc_wf hwf hn hbl hd hen
    have hlbd : bsd.length = n := (BytesInj.of_leDefined hle).length.trans hbl
    have hne : bsd ≠ [] := by
      intro he
      rw [he, List.length_nil] at hlbd
      omega
    obtain ⟨a0, b0, hqa, hb0⟩ := deref_store_target_mapped hmap hlp hq hne hsto
    -- R's pointer
    obtain ⟨bp1, hrfp, hbp⟩ := readLocal_inj hrel.frame.mem hrp
      (show s.mem.load pp sp.size .one = .ok bp by rw [hsize.2]; exact hlp)
    rw [hsize.2] at hrfp
    obtain ⟨q1, hq1, hpq⟩ := decodePtr_inj hbp hq
    -- R's source bytes, one by one
    obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra
      (show s.mem.load pa sa.size .one = .ok bsa by rw [hsize.1]; exact hla)
    rw [hsize.1] at hrfa
    obtain ⟨hbs, -⟩ := BytesInj.of_le_trans hle hia
    have hbal : ba.length = n := by rw [← BytesInj.length hbs, hlbd]
    have hrfa' := hrfa
    unfold OpSem.State.readFrame at hrfa'
    obtain ⟨hlen1, hall⟩ := aggMapM_ok hrfa'
    have hbyte : ∀ i (h : i < n), s1.st.byteAt (sa.off + (i : Int)) = .ok (ba[i]'(by omega)) := by
      intro i hi'
      have := hall i (by simp; omega) (by omega)
      simpa using this
    have hg : ∀ i (h : i < n), (ba[i]?).getD .uninit = ba[i]'(by omega) := by
      intro i hi'
      simp [List.getElem?_eq_getElem (show i < ba.length by omega)]
    -- `_p`'s and `_a`'s slots are private
    have hescp : ∀ i : Nat, i < 8 → s1.st.escapedAt (sp.off + (i : Int)) = none := by
      intro i hi'
      cases he : s1.st.escapedAt (sp.off + (i : Int)) with
      | none => rfl
      | some e =>
        exfalso
        have h3 := hrel.esc _ e he
        have h4 := hprivp i (by rw [hsize.2]; exact hi')
        rw [h3] at h4
        cases h4
    have hesca : ∀ i < n, s1.st.escapedAt (sa.off + (i : Int)) = none := by
      intro i hi'
      cases he : s1.st.escapedAt (sa.off + (i : Int)) with
      | none => rfl
      | some e =>
        exfalso
        have h3 := hrel.esc _ e he
        have h4 := hpriva i (by rw [hsize.1]; exact hi')
        rw [h3] at h4
        cases h4
    -- the stored range ends below `ADDR_LIMIT`
    rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with
      ⟨_, hl0, -⟩ | ⟨id, hid, _, _, _, hlv, _, h2, -, -⟩
    · exact absurd hl0 (by omega)
    have hb := hbelow id s.mem.allocs[id] (get?_of_lt hid) hlv
    have h2' : q.addr + off + bsd.length ≤ s.mem.allocs[id].addr + s.mem.allocs[id].data.size :=
      h2
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2.1
    have hf3 := offOk_spec hoff.2.2.1
    have hf5 := offOk_spec hoff.2.2.2.2
    have hsto0 : s.mem.store ⟨q.addr + off + 0, q.prov⟩ bsd .one = .ok s'.mem := hsto
    obtain ⟨mem', hsteps, hmi', hloc⟩ := sim_storePieces (ch := ch) hmode hρ hqa hb0 hpq
      (P := sp.off) (S := sa.off) (K := off) hq1 (g := fun i => (ba[i]?).getD .uninit)
      ⟨hf1.1, hf1.2⟩ ws is 0 bsd s.mem s'.mem s1 his hi hsc hpe hpl (by rw [hlbd, hws])
      (by omega) (by omega) hf2.1 (by omega) hrfp hescp
      (fun i hi' => by
        have hin : i < n := by omega
        have e : sa.off + ((0 : Nat) : Int) + (i : Int) = sa.off + (i : Int) := by omega
        refine ⟨?_, ?_⟩
        · show s1.st.byteAt (sa.off + ((0 : Nat) : Int) + (i : Int)) =
            .ok ((ba[0 + i]?).getD .uninit)
          rw [e, Nat.zero_add, hg i hin]
          exact hbyte i hin
        · show ByteInj ι bsd[i] ((ba[0 + i]?).getD .uninit)
          rw [Nat.zero_add, hg i hin]
          exact hbs.getElem' i hi' (by omega))
      (fun i hi' => by
        rw [show sa.off + ((0 : Nat) : Int) + (i : Int) = sa.off + (i : Int) by omega]
        exact hesca i (by omega))
      hrel.frame.mem hld hsto0
    -- `Hidden` and the bound: the stored provenance is `_a`'s loaded bytes'
    have hsub := bytesLeDefined_prov hle
    have hhid := hrel.hidden.load hla
    have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
      intro b hb' fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb' fr hfr
      rw [← he0]
      exact hhid _ (List.getElem_mem hj) fr0 hf0
    have hbd := hpb.load hla
    have hbd' : BytesBounded s.mem.allocs.size bsd := by
      intro b hb' fr hfr
      obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb' fr hfr
      rw [← he0]
      exact hbd _ (List.getElem_mem hj) fr0 hf0
    exact ⟨{ s1.st with mem := mem' }, hsteps, hstk,
      hrel.after_store hmi' hloc (hrel.hidden.store_hidden hsto hhid') hlive',
      hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm, memKept_load hsto hla hsub⟩

/-- `LowerDerefSplit` in a scope-free function: `stmt_sim`'s case (as `stmt_sim_storeTemp`),
given `AllocsBelow`. -/
theorem stmt_sim_derefSplit {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerDerefSplit Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) (hbelow : AllocsBelow s.mem) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨b, x, xs, rv, rfl⟩ : ∃ b x xs rv, st = .assign ⟨b, x :: xs⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h <;> exact ⟨_, _, _, _, rfl⟩
  have hkill : stmtKill (.assign ⟨b, x :: xs⟩ rv) = none := rfl
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hlen := rangeInsns_length (r := r) h2
  have hi : ∀ j (hj : j < (rangeInsns c.d r).length),
      c.d.insns[s1.pc + j]? = some ((rangeInsns c.d r)[j]'hj) := by
    rw [hpc0]; exact rangeInsns_at h2
  have hsc : ∀ j, j < (rangeInsns c.d r).length → c.scopesAt (s1.pc + j) = [] :=
    fun _ _ => scopesAt_nil hfn.noScopes _
  have hpl : ∀ i ∈ rangeInsns c.d r, PlainView c.mode c.ρ i := by
    intro i hmem
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hmem
    rw [hmode, hρ]
    exact hfn.plain _ _ (hi j hj)
  obtain ⟨hlv1, hlv2⟩ := hfn.live.stmt f.bb bd M.hbd f.stmt _ hst
  obtain ⟨st', hsteps, hstk, hrel, hpb, hle, hk⟩ := lift_derefSplit (ch := ch) M.stack
    M.body.symm hmode.symm hρ.symm h hi hsc hpe hpl M.rel M.pb M.dinv.1 M.dinv.2 hbelow hlv2
    (fun l hl => hlv1 l hl (by rw [hkill]; intro e; cases e)) hev
  refine ⟨_, f, hsteps, hstk.trans M.stack, rfl, rfl, rfl, rfl, rfl,
    (by show s1.pc + (rangeInsns c.d r).length = r.2; rw [hpc0, hlen]; omega), hrel, ?_, hpb,
    ?_, M.dinv.of_memKept hk⟩
  · intro l p hp
    exact (hfn.storage.stmt f.bb bd M.hbd f.stmt _ hst).1 l (M.sl l p hp) (by intro e; cases e)
  · intro a ha
    exact M.fresh a (Nat.le_trans hle ha)

end Ryo.Proofs.Lower
