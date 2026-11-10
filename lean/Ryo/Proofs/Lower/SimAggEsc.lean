/-
Ryo.Proofs.Lower.SimAggEsc — R's pieces of an aggregate (`SimAgg.lean`'s `sim_pieces`) into an
escaped destination (M5b): `_d`'s slot `[lo, hi)` lies in one R frame object `e` (allocation
`y`), so each piece's frame write lands in `y`'s data, not in the frame.

- `ObjInv s0 t e y lo hi V`: `t` is the state before the statement `s0` with only `e`'s
  allocation changed, and only at the slot's indices, which hold `V` (the frame view the pieces
  so far leave); frame and objects unchanged. `objInv_init` (no piece: `V = frameByte s0`,
  `byteAt_obj`), `objInv_write` (one frame write inside the slot: `writeFrame_obj_ok`,
  `wroteAt_of_escFrom`).
- The pieces' sources lie outside the slot, so they read as before (`ObjInv.byteAt_out`). A
  source in another object of the same allocation would read `y` too; `EscIdOff` (objects with
  the same allocation start at the same offset: `FnRelX.addrAt`; vacuous without escapes,
  `escIdOff_of_noEsc`) puts its index outside the slot's.
- `sim_pieceE`, `sim_piecesE`: `sim_piece`/`sim_pieces` with `ObjInv` in place of "only the
  frame changes"; the end state's object holds `pieceFrame src ps (frameByte s0)` on the slot.
- `ObjInv.wroteAt` (`WroteAt` for `MemInj.wrote`) and `LocalRel.objInv` (other locals) take the
  result to the relation (used by the escaped aggregate lift).
-/
import Ryo.Proofs.Lower.SimAgg
import Ryo.Proofs.Lower.WriteDst
import Ryo.Proofs.Lower.FnRelEsc

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Objects of one allocation -/

/-- Escaped objects of one allocation start at one offset. -/
def EscIdOff (st : OpSem.State) : Prop :=
  ∀ o1 o2 (e1 e2 : EscapedObj), st.escapedAt o1 = some e1 → st.escapedAt o2 = some e2 →
    e1.id = e2.id → e1.off = e2.off

/-- Without escapes (`LowersFn.noEsc`) no offset is in an object. -/
theorem escIdOff_of_noEsc {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1)
    (h : ∀ o, Γ.escaped o = false) : EscIdOff s1.st := by
  intro o1 o2 e1 e2 h1 _ _
  have h3 := hrel.esc o1 e1 h1
  rw [h o1] at h3
  cases h3

/-- Every object's allocation is at `fp + e.off` (`FnRelX.addrAt`), so one allocation means one
offset. -/
theorem FnRelX.escIdOff {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hX : FnRelX Γ ι live f m0 s1) : EscIdOff s1.st := by
  intro o1 o2 e1 e2 h1 h2 hid
  have hm1 := (Ryo.Proofs.Inline.escapedAt_some h1).1
  have hm2 := (Ryo.Proofs.Inline.escapedAt_some h2).1
  have hlt := hX.idLt e1 hm1
  have hg := get?_of_lt hlt
  have ha1 := hX.addrAt e1 hm1 _ hg
  have ha2 := hX.addrAt e2 hm2 _ (by rw [← hid]; exact hg)
  omega

/-- R's byte at an offset in an object with a live allocation. -/
theorem byteAt_obj {st : OpSem.State} {o : Int} {e : EscapedObj} {y : Allocation} {j : Nat}
    (he : st.escapedAt o = some e) (hy : st.mem.get? e.id = some y) (hl : y.live = true)
    (hj : (o - e.off).toNat = j) (hjs : j < y.data.size) :
    st.byteAt o = .ok y.data[j] := by
  rw [OpSem.State.byteAt, he]
  simp only [hy, hl, Bool.not_true, Bool.false_eq_true, ↓reduceIte, hj,
    Array.getElem?_eq_getElem hjs] <;> rfl

/-! ### The invariant -/

/-- See the module comment. -/
structure ObjInv (s0 t : OpSem.State) (e : EscapedObj) (y : Allocation) (lo hi : Int)
    (V : Int → AbstractByte) : Prop where
  esc : t.escaped = s0.escaped
  frame : t.frame = s0.frame
  other : ∀ id, id ≠ e.id → t.mem.get? id = s0.mem.get? id
  obj : ∃ yt, t.mem.get? e.id = some yt ∧ yt = { y with data := yt.data } ∧
    yt.data.size = y.data.size ∧
    (∀ j : Nat, ((j : Int) + e.off < lo ∨ hi ≤ (j : Int) + e.off) → yt.data[j]? = y.data[j]?) ∧
    (∀ j : Nat, lo ≤ (j : Int) + e.off → (j : Int) + e.off < hi →
      yt.data[j]? = some (V (e.off + (j : Int))))

/-- Before the first piece: the slot holds R's bytes there. -/
theorem objInv_init {s0 : OpSem.State} {e : EscapedObj} {y : Allocation} {lo hi : Int}
    (hlh : ∀ o, lo ≤ o → o < hi → s0.escapedAt o = some e) (hy : s0.mem.get? e.id = some y)
    (hyl : y.live = true) (hys : y.data.size = e.size) :
    ObjInv s0 s0 e y lo hi (frameByte s0) := by
  refine ⟨rfl, rfl, fun _ _ => rfl, ⟨y, hy, rfl, rfl, fun _ _ => rfl, fun j h1 h2 => ?_⟩⟩
  have he := hlh _ h1 h2
  obtain ⟨-, -, h4⟩ := Ryo.Proofs.Inline.escapedAt_some he
  have hjs : j < y.data.size := by omega
  have hb := byteAt_obj (o := (j : Int) + e.off) (j := j) he hy hyl (by omega) hjs
  rw [Array.getElem?_eq_getElem hjs]
  unfold frameByte
  rw [show e.off + (j : Int) = (j : Int) + e.off by omega, hb]

/-- Outside the slot R reads as before the statement. -/
theorem ObjInv.byteAt_out {s0 t : OpSem.State} {e : EscapedObj} {y : Allocation} {lo hi : Int}
    {V : Int → AbstractByte} (I : ObjInv s0 t e y lo hi V) (hy : s0.mem.get? e.id = some y)
    (hio : ∀ o (e2 : EscapedObj), s0.escapedAt o = some e2 → e2.id = e.id → e2.off = e.off)
    {o : Int} (ho : o < lo ∨ hi ≤ o) : t.byteAt o = s0.byteAt o := by
  have hea : t.escapedAt o = s0.escapedAt o := by
    unfold OpSem.State.escapedAt; rw [I.esc]
  unfold OpSem.State.byteAt
  rw [hea]
  cases he : s0.escapedAt o with
  | none => simp only [I.frame]
  | some e2 =>
    by_cases hid : e2.id = e.id
    · obtain ⟨yt, hyt, hyte, -, hout, -⟩ := I.obj
      have hoff := hio o e2 he hid
      obtain ⟨-, h1, -⟩ := Ryo.Proofs.Inline.escapedAt_some he
      have hl : yt.live = y.live := by
        have := congrArg Allocation.live hyte
        exact this
      have hj : yt.data[(o - e2.off).toNat]? = y.data[(o - e2.off).toNat]? :=
        hout _ (by omega)
      dsimp only
      rw [hid, hyt, hy]
      simp only [hl, hj]
    · simp only [I.other _ hid]

/-- One frame write inside the slot (`lo ≤ d`, `d + bs.length ≤ hi`): the slot's view becomes
`bs` over `[d, d + bs.length)`. -/
theorem objInv_write {s0 t : OpSem.State} {e : EscapedObj} {y : Allocation} {lo hi : Int}
    {V : Int → AbstractByte} (I : ObjInv s0 t e y lo hi V) (hlt : lo < hi)
    (hlh : ∀ o, lo ≤ o → o < hi → s0.escapedAt o = some e) (hys : y.data.size = e.size)
    {d : Int} {bs : List AbstractByte} (h1 : lo ≤ d) (h2 : d + bs.length ≤ hi) :
    ∃ t', t.writeFrame d bs = .ok t' ∧ ObjInv s0 t' e y lo hi (fun o =>
      if d ≤ o ∧ o < d + bs.length then bs.getD (o - d).toNat .uninit else V o) := by
  have hea : ∀ o, t.escapedAt o = s0.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [I.esc]
  have hin : ∀ k < bs.length, t.escapedAt (d + k) = some e := fun k hk =>
    (hea _).trans (hlh _ (by omega) (by omega))
  have hlo := (Ryo.Proofs.Inline.escapedAt_some (hlh lo (Int.le_refl _) hlt)).2.1
  have hhi := (Ryo.Proofs.Inline.escapedAt_some (hlh (hi - 1) (by omega) (by omega))).2.2
  obtain ⟨yt, hyt, hyte, hsz, hout, hinside⟩ := I.obj
  obtain ⟨t', hwr⟩ := writeFrame_obj_ok hin hyt
  obtain ⟨hef, hesc, hfr⟩ := writeFrame_split hwr
  have hw : WroteAt t.mem t'.mem e.id (yt.addr + (d - e.off).toNat) bs :=
    wroteAt_of_escFrom hef hin hyt (by omega) (by omega)
  have hpe : yt.addr + (d - e.off).toNat - yt.addr = (d - e.off).toNat := by omega
  refine ⟨t', hwr, ⟨hesc.trans I.esc, ?_, ?_, ?_⟩⟩
  · funext o
    have hnp : ¬ (t.privateIn d bs.length o = true) := by
      simp only [OpSem.State.privateIn, Bool.and_eq_true, decide_eq_true_eq]
      rintro ⟨⟨g1, g2⟩, g3⟩
      have hk := hin (o - d).toNat (by omega)
      rw [show d + ((o - d).toNat : Int) = o by omega] at hk
      rw [hk] at g3
      exact absurd g3 (by simp)
    rw [hfr o, if_neg hnp]
    exact congrFun I.frame o
  · intro id hid
    rw [← I.other id hid]
    cases hz : t.mem.get? id with
    | some z =>
      obtain ⟨z', hz', hne, -⟩ := hw id z hz
      rw [hz', hne hid]
    | none =>
      have hge : t.mem.allocs.size ≤ id :=
        Array.getElem?_eq_none_iff.mp (show t.mem.allocs[id]? = none from hz)
      show t'.mem.allocs[id]? = none
      exact Array.getElem?_eq_none (by rw [hef.1]; exact hge)
  · obtain ⟨y', hy', -, hyb⟩ := hw e.id yt hyt
    obtain ⟨arr, rfl, hasz, hg⟩ := hyb rfl
    refine ⟨{ yt with data := arr }, hy', ?_, hasz.trans hsz, fun j hj => ?_, fun j g1 g2 => ?_⟩
    · show ({ yt with data := arr } : Allocation) = { y with data := arr }
      rw [hyte]
    · show arr[j]? = _
      rw [hg j, hpe, if_neg (by omega)]
      exact hout j hj
    · show arr[j]? = _
      by_cases hc : d ≤ e.off + (j : Int) ∧ e.off + (j : Int) < d + bs.length
      · have hk : j - (d - e.off).toNat - 0 < bs.length := by omega
        rw [hg j, hpe, if_pos (by omega), List.getElem?_eq_getElem hk, if_pos hc,
          List.getD_eq_getElem?_getD,
          show (e.off + (j : Int) - d).toNat = j - (d - e.off).toNat - 0 by omega,
          List.getElem?_eq_getElem hk, Option.getD_some]
      · rw [hg j, hpe, if_neg (by omega), if_neg hc]
        exact hinside j g1 g2

/-! ### Running the pieces -/

/-- One piece into the escaped slot (`sim_piece`'s escaped counterpart). -/
theorem sim_pieceE {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} (hmode : Γ.mode = c.mode)
    (hρ : Γ.ρ = c.ρ) {lo hi : Int} {src : Int → AbstractByte} {p : AggPiece} {i : R.Insn}
    {s1 : R.RState} {s0 : OpSem.State} {e : EscapedObj} {y : Allocation}
    {V : Int → AbstractByte}
    (hok : pieceOk Γ i p = true) (hins : c.d.insns[s1.pc]? = some i)
    (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i)
    (hw : p.Within lo hi) (hlt : lo < hi)
    (hlh : ∀ o, lo ≤ o → o < hi → s0.escapedAt o = some e) (hys : y.data.size = e.size)
    (I : ObjInv s0 s1.st e y lo hi V)
    (hsrc : ∀ d s w, p = .mov d s w → ∀ k < w, s1.st.byteAt (s + k) = .ok (src (s + k))) :
    ∃ st', R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
      ObjInv s0 st' e y lo hi (pieceFrame src [p] V) := by
  cases p with
  | mov d s w =>
    simp only [AggPiece.Within] at hw
    obtain ⟨hw1, hw2, hw3, hd1, hd2, hs1, hs2⟩ := hw
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ :=
      movInsnOk_spec (by simp only [pieceOk] at hok; exact hok)
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    have hrd := readFrame_eq_map (st := s1.st) (off := s) (n := w)
      (g := fun k => src (s + k)) (fun k hk => hsrc d s w rfl k hk)
    have hbl : ((List.range w).map fun k : Nat => src (s + k)).length = w := by simp
    generalize hbs : (List.range w).map (fun k : Nat => src (s + k)) = bs at hrd hbl
    obtain ⟨st', hwr, I'⟩ := objInv_write (bs := bs) I hlt hlh hys hw1 (by rw [hbl]; exact hw2)
    refine ⟨st', step_of_view hins hsc hpe hpl hv hctl (by
      rw [hops]; exact opSem_mov_fwd hh hty' ho ⟨hd1, hd2, hs1, hs2⟩ hrd hbl hwr), ?_⟩
    have hV : (fun o => if d ≤ o ∧ o < d + (bs.length : Int) then
        bs.getD (o - d).toNat .uninit else V o) = pieceFrame src [.mov d s w] V := by
      funext o
      show _ = (if d ≤ o ∧ o < d + (w : Int) then src (s + (o - d)) else V o)
      rw [hbl]
      by_cases ho : d ≤ o ∧ o < d + (w : Int)
      · rw [if_pos ho, if_pos ho]
        have hk : (o - d).toNat < w := by omega
        rw [← hbs, List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_range hk]
        show src (s + ((o - d).toNat : Int)) = src (s + (o - d))
        rw [Int.toNat_of_nonneg (by omega)]
      · rw [if_neg ho, if_neg ho]
    rw [← hV]
    exact I'
  | imm d w bits =>
    simp only [AggPiece.Within] at hw
    obtain ⟨hw1, hw2, hd1, hd2⟩ := hw
    obtain ⟨v, ty, r, hv, hh, hty, hn, hk, hops, hctl⟩ :=
      immInsnOk_spec (by simp only [pieceOk] at hok; exact hok)
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    obtain ⟨x, hops', hx⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands2 hn hk
    have hops'' : v.ops = [.slot d, .imm x] := hops'
    have hfk : Val.fits k (.imm x) = true :=
      fits_last (hpl.fits v hv) (by rw [ho, hops'']; simp)
    have hbe : intBytes w x = encodeBits w bits := by
      unfold intBytes
      rw [← encodeBits_mod w x, hx, encodeBits_mod]
    have hbl : (encodeBits w bits).length = w := Ryo.Spec.Theorems.encodeBits_length _ _
    obtain ⟨st', hwr, I'⟩ := objInv_write (bs := encodeBits w bits) I hlt hlh hys hw1
      (by rw [hbl]; exact hw2)
    rw [← hbe] at hwr
    refine ⟨st', step_of_view hins hsc hpe hpl hv hctl (by
      rw [hops'']; exact opSem_imm_fwd hh hty' ho ⟨hd1, hd2⟩ hfk hwr), ?_⟩
    have hV : (fun o => if d ≤ o ∧ o < d + ((encodeBits w bits).length : Int) then
        (encodeBits w bits).getD (o - d).toNat .uninit else V o) =
        pieceFrame src [.imm d w bits] V := by
      rw [hbl]; rfl
    rw [← hV]
    exact I'

/-- The pieces into the escaped slot (`sim_pieces`' escaped counterpart): `is.length` steps; the
object's slot ends up holding `pieceFrame src ps V`, the rest of the state as before. Sources
are read through `s0` (`hsrc`) and outside the slot (`ObjInv.byteAt_out`). -/
theorem sim_piecesE {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} (hmode : Γ.mode = c.mode)
    (hρ : Γ.ρ = c.ρ) {lo hi : Int} {src : Int → AbstractByte} {s0 : OpSem.State}
    {e : EscapedObj} {y : Allocation} (hlt : lo < hi)
    (hlh : ∀ o, lo ≤ o → o < hi → s0.escapedAt o = some e) (hy : s0.mem.get? e.id = some y)
    (hys : y.data.size = e.size)
    (hio : ∀ o (e2 : EscapedObj), s0.escapedAt o = some e2 → e2.id = e.id → e2.off = e.off) :
    ∀ {ps : List AggPiece} {is : List R.Insn} {s1 : R.RState} {V : Int → AbstractByte},
    piecesOk Γ is ps = true →
    (∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj)) →
    (∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) → c.mode.pe = false →
    (∀ i ∈ is, PlainView c.mode c.ρ i) →
    (∀ p ∈ ps, p.Within lo hi) →
    ObjInv s0 s1.st e y lo hi V →
    (∀ p ∈ ps, ∀ d s w, p = .mov d s w → ∀ i < w, s0.byteAt (s + i) = .ok (src (s + i))) →
    ∃ st', StepsTo c ch s1 { s1 with pc := s1.pc + is.length, st := st' } ∧
      ObjInv s0 st' e y lo hi (pieceFrame src ps V) := by
  intro ps
  induction ps with
  | nil =>
    intro is s1 V hok _ _ _ _ _ I _
    cases is with
    | nil => exact ⟨s1.st, .refl _, I⟩
    | cons _ _ => simp [piecesOk] at hok
  | cons p ps ih =>
    intro is s1 V hok hi hsc hpe hpl hw I hsrc
    cases is with
    | nil => simp [piecesOk] at hok
    | cons i is =>
      simp only [piecesOk, Bool.and_eq_true] at hok
      have hw0 := hw p (List.mem_cons_self ..)
      obtain ⟨st1, hstep, I1⟩ := sim_pieceE (ch := ch) (src := src) hmode hρ hok.1
        (hi 0 (by simp)) (hsc 0 (by simp)) hpe (hpl i (List.mem_cons_self ..)) hw0 hlt hlh hys I
        (fun d s w he k hk => by
          subst he
          simp only [AggPiece.Within] at hw0
          rw [I.byteAt_out hy hio (by omega)]
          exact hsrc _ (List.mem_cons_self ..) d s w rfl k hk)
      obtain ⟨st', hsteps, I'⟩ :=
        ih (s1 := { s1 with pc := s1.pc + 1, st := st1 }) hok.2
        (fun j hj => by
          have := hi (j + 1) (by simp; omega)
          rw [show s1.pc + (j + 1) = s1.pc + 1 + j by omega] at this
          simpa using this)
        (fun j hj => by
          have := hsc (j + 1) (by simp; omega)
          rw [show s1.pc + (j + 1) = s1.pc + 1 + j by omega] at this
          simpa using this)
        hpe (fun i' hi' => hpl i' (List.mem_cons_of_mem _ hi'))
        (fun q hq => hw q (List.mem_cons_of_mem _ hq)) I1
        (fun q hq => hsrc q (List.mem_cons_of_mem _ hq))
      refine ⟨st', ?_, ?_⟩
      · have hsteps' : StepsTo c ch { s1 with pc := s1.pc + 1, st := st1 }
            { s1 with pc := s1.pc + 1 + is.length, st := st' } := hsteps
        rw [show s1.pc + 1 + is.length = s1.pc + (i :: is).length by
          simp only [List.length_cons]; omega] at hsteps'
        exact .cons hstep hsteps'
      · rw [show pieceFrame src (p :: ps) V = pieceFrame src ps (pieceFrame src [p] V) from
          pieceFrame_append src [p] ps V]
        exact I'

/-! ### From the invariant to the relation -/

/-- The object's allocation after the pieces, as `MemInj.wrote` takes it: `y` with the slot's
`n` bytes `V (lo + k)` at `pa` (`_d`'s address). -/
theorem ObjInv.wroteAt {s0 t : OpSem.State} {e : EscapedObj} {y : Allocation} {lo hi : Int}
    {V : Int → AbstractByte} (I : ObjInv s0 t e y lo hi V) (hy : s0.mem.get? e.id = some y)
    {pa n : Nat} (hpa : (pa : Int) - y.addr = lo - e.off) (hya : y.addr ≤ pa)
    (hn : hi = lo + n) (hsz : lo + n ≤ e.off + y.data.size) :
    WroteAt s0.mem t.mem e.id pa ((List.range n).map fun k : Nat => V (lo + (k : Int))) := by
  intro id z hz
  by_cases hid : id = e.id
  · rw [hid] at hz ⊢
    have e1 : z = y := Option.some.inj (hz.symm.trans hy)
    rw [e1]
    obtain ⟨yt, hyt, hyte, hsz', hout, hinside⟩ := I.obj
    refine ⟨yt, hyt, fun hne => absurd rfl hne, fun _ => ⟨yt.data, hyte, hsz', fun j => ?_⟩⟩
    by_cases hc : lo ≤ (j : Int) + e.off ∧ (j : Int) + e.off < hi
    · have hk : j - (pa - y.addr) - 0 < n := by omega
      rw [if_pos (by simp only [List.length_map, List.length_range]; omega),
        List.getElem?_map, List.getElem?_range hk, hinside j hc.1 hc.2]
      show some (V (e.off + (j : Int))) = some (V (lo + ((j - (pa - y.addr) - 0 : Nat) : Int)))
      congr 2
      omega
    · rw [if_neg (by simp only [List.length_map, List.length_range]; omega)]
      exact hout j (by omega)
  · exact ⟨z, by rw [I.other id hid]; exact hz, fun _ => rfl, fun h => absurd h hid⟩

/-- A local of the state before the pieces stays related (the frame and objects are the same,
allocations keep address, liveness and size). -/
theorem LocalRel.objInv {ι : Inj} {fp : Nat} {s0 t : OpSem.State} {m0 : Memory}
    {slot : LocalSlot} {p : ThinPointer} {lv : Bool} (hr : LocalRel ι fp s0 m0 slot p lv)
    {e : EscapedObj} {y : Allocation} {lo hi : Int} {V : Int → AbstractByte}
    (I : ObjInv s0 t e y lo hi V) (hy : s0.mem.get? e.id = some y) :
    LocalRel ι fp t m0 slot p lv := by
  have hea : ∀ o, t.escapedAt o = s0.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [I.esc]
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpv hbytes =>
    refine .priv a x hp hι hx hlive haddr hpaddr hsize
      (fun k hk => (hea _).trans (hpv k hk)) ?_
    rw [I.frame]
    exact hbytes
  | esc a x e' y' hp hι hx hlive haddr hpaddr hsize hin hy' hylive hyaddr hysize =>
    by_cases hid : e'.id = e.id
    · obtain ⟨yt, hyt, hyte, hsz, -, -⟩ := I.obj
      rw [hid] at hy'
      have e1 : y' = y := Option.some.inj (hy'.symm.trans hy)
      rw [e1] at hylive hyaddr hysize
      have hl : yt.live = y.live := by
        have := congrArg Allocation.live hyte
        exact this
      have ha : yt.addr = y.addr := by
        have := congrArg Allocation.addr hyte
        exact this
      exact .esc a x e' yt hp hι hx hlive haddr hpaddr hsize
        (fun k hk => (hea _).trans (hin k hk)) (by rw [hid]; exact hyt)
        (by rw [hl]; exact hylive) (by rw [ha]; exact hyaddr) (by rw [hsz]; exact hysize)
    · exact .esc a x e' y' hp hι hx hlive haddr hpaddr hsize
        (fun k hk => (hea _).trans (hin k hk)) (by rw [I.other _ hid]; exact hy') hylive hyaddr
        hysize

end Ryo.Proofs.Lower
