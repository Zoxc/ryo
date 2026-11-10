/-
Ryo.Proofs.Lower.SimAgg — the lift of `LowerAgg` (`Check/Lower/Agg.lean`, M5b): statements
lowered to several instructions, the fields of an aggregate (or the pieces of one copy) written
one after the other into `_d`'s private slot.

The single-instruction `LiftOut` (FnSim.lean) becomes `LiftOutN`: R runs `k` steps
(`StepsTo`) to `pc + k` with the same facts; `stmtOut_of_liftN` turns it into `StmtOut` as
`stmtOut_of_lift` does (`k` the range's length).

The simulation, in three parts:
- L0 (`agg_mem`, `aggUse_mem`, giving `AggMem`): the operands evaluate without changing the state
  (`evalField_mem`: each field's bytes are the re-encoding of the operand's value at the field
  type, below the operand local's loaded bytes or the constant's `encodeBits`, or empty for a
  zero-sized field), and the store writes `writeFields` of them at L0's offsets over
  uninitialized bytes (`aggLayout_encode`: `Ty.encodeFields` for tuples, the concatenation for
  arrays).
- R (`sim_pieces`): the instructions (`piecesOk`) run one by one; each writes only `_d`'s
  private slot, a `mov` reading a source outside it, so every source byte reads as before the
  statement (`frameByte` of the initial state) and the frame after them is `pieceFrame` of the
  pieces over the initial frame; memory and escapes are unchanged.
- The bytes (`pieceFrame_aggPieces`, by induction over the fields with `pieceFrame_src` for one
  field): R writes the same ranges in the same order as `writeFields`, each with bytes refining
  L0's (`SrcRel`, from `srcRel_of_fieldMem`), so the slot's final bytes refine L0's stored ones;
  bytes no field writes are uninitialized in L0 and refine whatever R holds.
`frameLocal_priv` and `LocalRel.frame_apart` (the analogues of `writeLocal_priv` and
`LocalRel.writeFrame_apart` for a frame changed by several writes) give `_d`'s and the other
locals' `LocalRel`; `Hidden`/`ProvBounded` follow from `writeFields_prov` (every stored
provenance is a field's, hence a loaded byte's: `le_prov`).

Hypotheses beyond `lift_copyPtr`'s: the multi-instruction forms of `hi`, `hsc`, `hpl` (every
index of the range; `stmt_sim` derives them from `rangeInsns_at`, `scopesAt_nil` and
`hfn.plain` as it does for one instruction).

All lemmas are proved.
-/
import Ryo.Proofs.Lower.SimCopy
import Ryo.Check.Lower.Agg

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### Multi-step lifts -/

/-- What a lifted assignment lowered to `k` instructions gives: R runs to `pc + k`, with
`LiftOut`'s facts there. -/
def LiftOutN (Γ : StmtCtx) (c : R.Code) (ch : OpSem.Choice) (ι : Inj) (live' : Local → Bool)
    (f : Spec.Frame) (s s' : Spec.State) (s1 : R.RState) (k : Nat) : Prop :=
  ∃ st', StepsTo c ch s1 { s1 with pc := s1.pc + k, st := st' } ∧
    s'.stack = s.stack ∧ FnRel Γ ι live' f s'.mem { s1 with pc := s1.pc + k, st := st' } ∧
    ProvBounded s'.mem ∧ s.mem.allocs.size ≤ s'.mem.allocs.size ∧ MemKept s.mem s'.mem

/-- A one-instruction lift is a one-step `LiftOutN`. -/
theorem liftOutN_of_lift {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {live' : Local → Bool} {f : Spec.Frame} {s s' : Spec.State} {s1 : R.RState}
    (hl : LiftOut Γ c ch ι live' f s s' s1) : LiftOutN Γ c ch ι live' f s s' s1 1 := by
  obtain ⟨st', hstep, hstk, hrel, hpb, hle, hk⟩ := hl
  exact ⟨st', .cons hstep (.refl _), hstk, hrel, hpb, hle, hk⟩

/-- An assignment's `StmtOut` from its `LiftOutN` over the statement's range (`s1.pc + k`
its end). -/
theorem stmtOut_of_liftN {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    {f : Spec.Frame} {rest : List Spec.Frame} {r : Range} {s s' : Spec.State} {s1 : R.RState}
    {bd : BlockData} {d : Local} {rv : Rvalue} {k : Nat}
    (hs : s.stack = f :: rest) (hstor : StorageSound Γ.body (computeStorage Γ.body).get)
    (hbd : Γ.body.blocks[f.bb]? = some bd) (hst : bd.stmts[f.stmt]? = some (.assign ⟨d, []⟩ rv))
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get f.bb f.stmt l = true)
    (hfr : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hpc : s1.pc + k = r.2)
    (hl : LiftOutN Γ.toStmtCtx c ch ι ((computeLive Γ.body).get f.bb (f.stmt + 1)) f s s' s1 k) :
    StmtOut Γ c ch ι f rest r s s' s1 := by
  obtain ⟨st', hsteps, hstk, hrel, hpb, hle, hk⟩ := hl
  refine ⟨_, f, hsteps, hstk.trans hs, rfl, rfl, rfl, rfl, rfl, hpc, hrel, ?_, hpb, ?_,
    hdi.of_memKept hk⟩
  · intro l p hp
    exact (hstor.stmt f.bb bd hbd f.stmt _ hst).1 l (hsl l p hp) (by intro e; cases e)
  · intro a ha
    exact hfr a (Nat.le_trans hle ha)

/-! ### R: running the pieces -/

/-- A piece's destination lies in `[lo, hi)`, a `mov`'s source outside it, its offsets in the
32-bit range. -/
def _root_.Ryo.Check.Lower.AggPiece.Within (lo hi : Int) : AggPiece → Prop
  | .mov d s w => lo ≤ d ∧ d + w ≤ hi ∧ (s + w ≤ lo ∨ hi ≤ s) ∧
      -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ s ∧ s < 2 ^ 31
  | .imm d w _ => lo ≤ d ∧ d + w ≤ hi ∧ -2 ^ 31 ≤ d ∧ d < 2 ^ 31

/-- The frame after the pieces, a `mov`'s bytes read through `src` (the bytes before the
statement: no source is written), an `imm`'s the constant's `encodeBits`. -/
def pieceFrame (src : Int → AbstractByte) :
    List AggPiece → (Int → AbstractByte) → Int → AbstractByte
  | [], fr => fr
  | .mov d s w :: ps, fr =>
    pieceFrame src ps fun o => if d ≤ o ∧ o < d + w then src (s + (o - d)) else fr o
  | .imm d w bits :: ps, fr =>
    pieceFrame src ps fun o =>
      if d ≤ o ∧ o < d + w then (encodeBits w bits).getD (o - d).toNat .uninit else fr o

theorem pieceFrame_append (src : Int → AbstractByte) (ps qs : List AggPiece) :
    ∀ fr, pieceFrame src (ps ++ qs) fr = pieceFrame src qs (pieceFrame src ps fr) := by
  induction ps with
  | nil => intro fr; rfl
  | cons p ps ih =>
    intro fr
    cases p with
    | mov d s w => simp only [List.cons_append, pieceFrame]; exact ih _
    | imm d w bits => simp only [List.cons_append, pieceFrame]; exact ih _

/-- Pieces within `[lo, hi)` leave the frame outside it alone.

Proof: induction on `ps` generalizing `fr`; each step's `if` is false outside `[lo, hi)`
(`AggPiece.Within`, `omega`), and the IH (at the updated frame) rewrites the rest. -/
theorem pieceFrame_outside {src : Int → AbstractByte} {lo hi : Int} :
    ∀ {ps : List AggPiece} {fr : Int → AbstractByte} {o : Int}, (∀ p ∈ ps, p.Within lo hi) →
      (o < lo ∨ hi ≤ o) → pieceFrame src ps fr o = fr o := by
  intro ps
  induction ps with
  | nil => intro fr o _ _; rfl
  | cons p ps ih =>
    intro fr o hw ho
    have hp := hw p (List.mem_cons_self ..)
    have hps : ∀ q ∈ ps, q.Within lo hi := fun q hq => hw q (List.mem_cons_of_mem _ hq)
    cases p with
    | mov d s w =>
      simp only [AggPiece.Within] at hp
      simp only [pieceFrame]
      rw [ih hps ho, if_neg (by omega)]
    | imm d w bits =>
      simp only [AggPiece.Within] at hp
      simp only [pieceFrame]
      rw [ih hps ho, if_neg (by omega)]

/-- The byte R reads at frame offset `o` (`uninit` if the read fails). -/
def frameByte (st : OpSem.State) (o : Int) : AbstractByte :=
  match st.byteAt o with
  | .ok b => b
  | .error _ => .uninit

/-- A frame write to private bytes: memory unchanged, the frame updated. -/
def privFrame (st : OpSem.State) (off : Int) (bs : List AbstractByte) : Int → AbstractByte :=
  fun o => if st.privateIn off bs.length o = true then bs.getD (o - off).toNat .uninit
    else st.frame o

/-- The state after such a write. -/
def privState (st : OpSem.State) (off : Int) (bs : List AbstractByte) : OpSem.State :=
  { st with frame := privFrame st off bs }

theorem writeFrame_priv_ok {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    (hp : ∀ i < bs.length, st.escapedAt (off + i) = none) :
    st.writeFrame off bs = .ok (privState st off bs) := by
  unfold OpSem.State.writeFrame
  rw [writeEscaped_private' hp]
  rfl

/-- The frame such a write leaves, over a range that is private. -/
theorem privFrame_eq {st : OpSem.State} {off : Int} {bs : List AbstractByte} {n : Nat}
    {g : Int → AbstractByte} (hbl : bs.length = n)
    (hp : ∀ o, off ≤ o → o < off + n → st.escapedAt o = none)
    (hg : ∀ o, off ≤ o → o < off + n → bs.getD (o - off).toNat .uninit = g o) :
    privFrame st off bs = fun o => if off ≤ o ∧ o < off + n then g o else st.frame o := by
  funext o
  unfold privFrame
  by_cases ho : off ≤ o ∧ o < off + n
  · have hpi : st.privateIn off bs.length o = true := by
      first
        | simp only [OpSem.State.privateIn, hbl, hp o ho.1 ho.2, decide_eq_true ho,
            Option.isNone_none, Bool.and_self]
        | (simp [OpSem.State.privateIn, hbl, hp o ho.1 ho.2]; omega)
    rw [if_pos hpi, if_pos ho]
    exact hg o ho.1 ho.2
  · have hpi : st.privateIn off bs.length o = false := by
      first
        | simp only [OpSem.State.privateIn, hbl, decide_eq_false ho, Bool.false_and]
        | (simp [OpSem.State.privateIn, hbl]; omega)
    rw [if_neg (by rw [hpi]; decide), if_neg ho]

/-- `byteAt` reads only memory, escapes and the frame at the offset. -/
theorem byteAt_congr {t u : OpSem.State} {o : Int} (hm : t.mem = u.mem)
    (he : t.escaped = u.escaped) (hf : t.frame o = u.frame o) : t.byteAt o = u.byteAt o := by
  simp only [OpSem.State.byteAt, OpSem.State.escapedAt, hm, he, hf]

/-- One piece: R's step, private to `[lo, hi)`.

Proof: `pieceOk` is `movInsnOk`/`immInsnOk`; their `_spec`s give the handler, `opSem_mov_fwd`
(the read by `readFrame_eq_map`) or `opSem_imm_fwd` (`intBytes w x = encodeBits w bits`) the
step, `writeFrame_priv_ok` and `privFrame_eq` the frame. -/
theorem sim_piece {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} (hmode : Γ.mode = c.mode)
    (hρ : Γ.ρ = c.ρ) {lo hi : Int} {src : Int → AbstractByte} {p : AggPiece} {i : R.Insn}
    {s1 : R.RState} (hok : pieceOk Γ i p = true) (hins : c.d.insns[s1.pc]? = some i)
    (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i)
    (hw : p.Within lo hi) (hesc : ∀ o, lo ≤ o → o < hi → s1.st.escapedAt o = none)
    (hsrc : ∀ d s w, p = .mov d s w → ∀ k < w, s1.st.byteAt (s + k) = .ok (src (s + k))) :
    ∃ st', R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st' }) ∧
      st'.mem = s1.st.mem ∧ st'.escaped = s1.st.escaped ∧
      st'.frame = pieceFrame src [p] s1.st.frame := by
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
    have hpv : ∀ k < ((List.range w).map fun k : Nat => src (s + k)).length,
        s1.st.escapedAt (d + k) = none := by
      intro k hk
      rw [hbl] at hk
      exact hesc _ (by omega) (by omega)
    have hwr := writeFrame_priv_ok hpv
    generalize hbs : (List.range w).map (fun k : Nat => src (s + k)) = bs at hrd hbl hpv hwr
    refine ⟨privState s1.st d bs,
      step_of_view hins hsc hpe hpl hv hctl (by
      rw [hops]; exact opSem_mov_fwd hh hty' ho ⟨hd1, hd2, hs1, hs2⟩ hrd hbl hwr), rfl, rfl, ?_⟩
    show privFrame _ _ _ = _
    rw [privFrame_eq (n := w) (g := fun o => src (s + (o - d))) hbl
      (fun o h1 h2 => hesc o (by omega) (by omega))]
    · rfl
    · intro o h1 h2
      have hk : (o - d).toNat < w := by omega
      rw [← hbs, List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_range hk]
      show src (s + ((o - d).toNat : Int)) = src (s + (o - d))
      rw [Int.toNat_of_nonneg (by omega)]
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
    have hpv : ∀ k < (encodeBits w bits).length, s1.st.escapedAt (d + k) = none := by
      intro k hk
      rw [hbl] at hk
      exact hesc _ (by omega) (by omega)
    have hwr := writeFrame_priv_ok hpv
    rw [← hbe] at hwr
    refine ⟨privState s1.st d (intBytes w x),
      step_of_view hins hsc hpe hpl hv hctl (by
      rw [hops'']; exact opSem_imm_fwd hh hty' ho ⟨hd1, hd2⟩ hfk hwr), rfl, rfl, ?_⟩
    show privFrame _ _ _ = _
    rw [privFrame_eq (n := w) (g := fun o => (encodeBits w bits).getD (o - d).toNat .uninit)
      ((congrArg List.length hbe).trans hbl) (fun o h1 h2 => hesc o (by omega) (by omega))]
    · rfl
    · intro o _ _
      rw [hbe]

/-- R runs the instructions of a piece list: `is.length` steps, each falling through; only the
frame changes, to `pieceFrame` of the pieces over the initial frame.

Proof: induction on `ps` (with `is`, `piecesOk` pairs them) generalizing `s1` and the frame
the remaining pieces start from, stated for an intermediate state `t` with `t.mem = s1.st.mem`,
`t.escaped = s1.st.escaped` and `t.frame` agreeing with `s1.st.frame` outside `[lo, hi)`. Per
piece: `pieceOk` is `movInsnOk`/`immInsnOk`; their `_spec`s and `intTyOk_spec` give the handler.
A `mov d s w`: its source `[s, s + w)` is outside `[lo, hi)` (`Within`), so `t.byteAt (s + i)`
is `s1.st.byteAt (s + i)` (`byteAt` reads the frame where nothing is escaped, else memory and
escapes, all unchanged) `= .ok (src (s + i))` (`hsrc`): `readFrame_eq_map` gives the read,
`writeEscaped_private'` (destination private: `hesc`) the write, `opSem_mov_fwd` the handler
step and `writeFrame_private_eq` the new frame, which is `pieceFrame`'s update
(`OpSem.State.privateIn` holds exactly on `[d, d + w)`; `List.getD` of the mapped range is
`src (s + (o - d))`). An `imm d w bits`: `immOpsOk_spec`, `operands2`, `fits_last` with
`hpl` for the immediate `x`, `opSem_imm_fwd`; `intBytes w x = encodeBits w bits` by
`x % 2 ^ (8 * w) = bits % 2 ^ (8 * w)` and `encodeBits_mod`. Each step is `step_of_view` (the
view's ops as in `lift_constBool`); chain them with `StepsTo.cons`, the pcs by `omega` and the
states by `RState` eta. -/
theorem sim_pieces {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} (hmode : Γ.mode = c.mode)
    (hρ : Γ.ρ = c.ρ) {lo hi : Int} {src : Int → AbstractByte} :
    ∀ {ps : List AggPiece} {is : List R.Insn} {s1 : R.RState},
    piecesOk Γ is ps = true →
    (∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj)) →
    (∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) → c.mode.pe = false →
    (∀ i ∈ is, PlainView c.mode c.ρ i) →
    (∀ p ∈ ps, p.Within lo hi) →
    (∀ o, lo ≤ o → o < hi → s1.st.escapedAt o = none) →
    (∀ p ∈ ps, ∀ d s w, p = .mov d s w → ∀ i < w, s1.st.byteAt (s + i) = .ok (src (s + i))) →
    ∃ st', StepsTo c ch s1 { s1 with pc := s1.pc + is.length, st := st' } ∧
      st'.mem = s1.st.mem ∧ st'.escaped = s1.st.escaped ∧
      st'.frame = pieceFrame src ps s1.st.frame := by
  intro ps
  induction ps with
  | nil =>
    intro is s1 hok _ _ _ _ _ _ _
    cases is with
    | nil => exact ⟨s1.st, .refl _, rfl, rfl, rfl⟩
    | cons _ _ => simp [piecesOk] at hok
  | cons p ps ih =>
    intro is s1 hok hi hsc hpe hpl hw hesc hsrc
    cases is with
    | nil => simp [piecesOk] at hok
    | cons i is =>
      simp only [piecesOk, Bool.and_eq_true] at hok
      have hw0 := hw p (List.mem_cons_self ..)
      obtain ⟨st1, hstep, hm1, he1, hf1⟩ := sim_piece (ch := ch) hmode hρ hok.1
        (hi 0 (by simp)) (hsc 0 (by simp)) hpe
        (hpl i (List.mem_cons_self ..)) hw0 hesc
        (fun d s w he k hk => hsrc p (List.mem_cons_self ..) d s w he k hk)
      have hea : ∀ o, st1.escapedAt o = s1.st.escapedAt o := fun o => by
        unfold OpSem.State.escapedAt; rw [he1]
      obtain ⟨st', hsteps, hm', he', hf'⟩ :=
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
        (fun q hq => hw q (List.mem_cons_of_mem _ hq))
        (fun o h1 h2 => (hea o).trans (hesc o h1 h2))
        (fun q hq d s w he k hk => by
          have hq' := hw q (List.mem_cons_of_mem _ hq)
          subst he
          simp only [AggPiece.Within] at hq'
          have hfo : st1.frame (s + k) = s1.st.frame (s + k) := by
            rw [hf1]
            exact pieceFrame_outside (fun q' hr => by
              simp only [List.mem_singleton] at hr; subst hr; exact hw0) (by omega)
          show st1.byteAt (s + k) = _
          rw [byteAt_congr hm1 he1 hfo]
          exact hsrc _ (List.mem_cons_of_mem _ hq) d s w rfl k hk)
      refine ⟨st', ?_, hm'.trans hm1, he'.trans he1, ?_⟩
      · have hsteps' : StepsTo c ch { s1 with pc := s1.pc + 1, st := st1 }
            { s1 with pc := s1.pc + 1 + is.length, st := st' } := hsteps
        rw [show s1.pc + 1 + is.length = s1.pc + (i :: is).length by
          simp only [List.length_cons]; omega] at hsteps'
        exact .cons hstep hsteps'
      · rw [hf']
        show pieceFrame src ps st1.frame = _
        rw [hf1]
        exact (pieceFrame_append src [p] ps _).symm

/-- The pieces `movPieces d s o ws` are `mov`s at `d + o'`, `s + o'` inside `[o, o + ws.sum)`. -/
theorem movPieces_mem {d s : Int} : ∀ {ws : List Nat} {o : Nat} {p : AggPiece},
    p ∈ movPieces d s o ws →
      ∃ (o' w : Nat), p = .mov (d + o') (s + o') w ∧ o ≤ o' ∧ o' + w ≤ o + ws.sum := by
  intro ws
  induction ws with
  | nil => intro o p h; simp [movPieces] at h
  | cons w ws ih =>
    intro o p h
    simp only [movPieces, List.mem_cons] at h
    rcases h with rfl | h
    · exact ⟨o, w, rfl, Nat.le_refl _, by rw [List.sum_cons]; omega⟩
    · obtain ⟨o', w', rfl, h1, h2⟩ := ih h
      exact ⟨o', w', rfl, by omega, by rw [List.sum_cons]; omega⟩

/-- The frame after `movPieces d s o ws`: bytes `[d + o, d + o + ws.sum)` read through `src`. -/
theorem pieceFrame_movPieces {src : Int → AbstractByte} {d s : Int} :
    ∀ {ws : List Nat} {o : Nat} {fr : Int → AbstractByte} {x : Int},
    pieceFrame src (movPieces d s o ws) fr x =
      if d + o ≤ x ∧ x < d + o + ws.sum then src (s + (x - d)) else fr x := by
  intro ws
  induction ws with
  | nil =>
    intro o fr x
    simp only [movPieces, pieceFrame]
    split
    next h =>
      exfalso
      have h2 := h.2
      rw [List.sum_nil] at h2
      omega
    · rfl
  | cons w ws ih =>
    intro o fr x
    have hs : (w :: ws).sum = w + ws.sum := List.sum_cons
    simp only [movPieces, pieceFrame]
    rw [ih]
    repeat' split
    all_goals first | rfl | (exfalso; omega) | (congr 1; omega)

/-- The pieces of fields `AggFields` accepts lie in `_d`'s slot, their sources outside it.

Proof: induction on `hf`; `List.mem_append` splits `aggPieces`. A `.slot a sa.off ws` field's
`movPieces (sd.off + off) sa.off 0 ws`: by induction on `ws` generalizing `o` with `o + ws.sum
= n` (`hws`), each piece is `.mov (sd.off + off + o) (sa.off + o) w` with `o + w ≤ n`, so
(`hin : off + n ≤ sd.size`, `hap`, `offOk_spec` of `hoff` and of the field's `hoff`) every
inequality of `Within` is `omega`. An `.imm` field is one piece of `n` bytes at
`sd.off + off`, likewise; a `.zst` field has none. -/
theorem aggPieces_within {Γ : StmtCtx} {sd : LocalSlot} {ops : List Operand}
    {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc} (hf : AggFields Γ sd ops fields srcs)
    (hoff : offOk sd.off ∧ offOk (sd.off + sd.size)) :
    ∀ p ∈ aggPieces sd.off fields srcs, p.Within sd.off (sd.off + sd.size) := by
  induction hf with
  | nil => intro p hp; simp [aggPieces] at hp
  | cons h hs ih =>
    intro p hp
    simp only [aggPieces, List.mem_append] at hp
    rcases hp with hp | hp
    · have hd1 := offOk_spec hoff.1
      have hd2 := offOk_spec hoff.2
      cases h with
      | slot ha hta hwf hn hpos hsa hsz hin hws hoff' hap =>
        simp only [srcPieces] at hp
        obtain ⟨o', w, rfl, -, h2⟩ := movPieces_mem hp
        have hs1 := offOk_spec hoff'.1
        have hs2 := offOk_spec hoff'.2
        simp only [AggPiece.Within]
        omega
      | imm hwf hn hpos hin =>
        simp only [srcPieces, List.mem_singleton] at hp
        subst hp
        simp only [AggPiece.Within]
        omega
      | zst hwf hn hin hop => simp [srcPieces] at hp
    · exact ih p hp

theorem aggPieces_single (dOff : Int) (t : Spec.Ty) (src : AggSrc) :
    aggPieces dOff [(0, t)] [src] = srcPieces dOff src := by
  first | simp [aggPieces] | (rw [aggPieces]; simp [aggPieces])

/-! ### The bytes -/

theorem writeAt_getElem_out {acc eb : List AbstractByte} {off k : Nat}
    (hin : off + eb.length ≤ acc.length) (h : k < (writeAt acc off eb).length)
    (hk : k < acc.length) (ho : ¬(off ≤ k ∧ k < off + eb.length)) :
    (writeAt acc off eb)[k] = acc[k] := by
  have hg := Ryo.Spec.Theorems.getElem?_writeAt acc eb off k hin
  rw [List.getElem?_eq_getElem h] at hg
  by_cases h1 : k < off
  · rw [if_pos h1, List.getElem?_eq_getElem hk] at hg
    exact Option.some.inj hg
  · rw [if_neg h1, if_neg (by omega), List.getElem?_eq_getElem hk] at hg
    exact Option.some.inj hg

theorem writeAt_getElem_in {acc eb : List AbstractByte} {off k : Nat}
    (hin : off + eb.length ≤ acc.length) (h : k < (writeAt acc off eb).length)
    (hk : off ≤ k ∧ k < off + eb.length) :
    (writeAt acc off eb)[k] = eb[k - off]'(by omega) := by
  have hg := Ryo.Spec.Theorems.getElem?_writeAt acc eb off k hin
  rw [List.getElem?_eq_getElem h, if_neg (by omega), if_pos (by omega),
    List.getElem?_eq_getElem (by omega : k - off < eb.length)] at hg
  exact Option.some.inj hg

/-- `encodeBits`'s bytes carry no provenance, so each relates to itself. -/
theorem encodeBits_inj_self {ι : Inj} {n v : Nat} {e : AbstractByte} (he : e ∈ encodeBits n v) :
    ByteInj ι e e := by
  simp only [encodeBits, List.mem_map] at he
  obtain ⟨u, -, rfl⟩ := he
  first | exact (rfl : u = u) | simp [AbstractByte.ofByte, ByteInj]

/-- `writeAt` each `(offset, bytes)` in order. -/
def writeFields (acc : List AbstractByte) : List (Nat × List AbstractByte) → List AbstractByte
  | [] => acc
  | (off, b) :: fs => writeFields (writeAt acc off b) fs

/-- One field's L0 bytes `eb` against what R's pieces for it write: the source bytes `src`
reads (`.slot`), the constant's bytes (`.imm`), nothing (`.zst`). -/
def SrcRel (ι : Inj) (src : Int → AbstractByte) : AggSrc → List AbstractByte → Prop
  | .slot _ s ws, eb => eb.length = ws.sum ∧ ∀ i (h : i < eb.length), ByteInj ι eb[i] (src (s + i))
  | .imm n bits, eb => eb.length = n ∧ bytesLeDefined eb (encodeBits n bits) = true
  | .zst, eb => eb = []

/-- One field: writing its L0 bytes at `off` into `acc` and running its pieces at
`base + off` over `fr` keep `acc` and `fr` related on `acc`'s range (`base` `_d`'s slot).

Proof: `writeAt acc off eb` is `acc.take off ++ eb ++ acc.drop (off + eb.length)`, of length
`acc.length` (`hin`); index `k` is `acc[k]` for `k < off` or `off + eb.length ≤ k`, else
`eb[k - off]`. On the pieces' side (`srcPieces`), by cases on `sr`: `.zst` has no pieces; an
`.imm` piece writes `(encodeBits n bits).getD (k - off)` at `base + k` for `off ≤ k < off + n`,
and `ByteInj ι eb[k - off]` of it from the `bytesLeDefined` (via `BytesInj.of_le` with
`ByteInj ι b b` for the provenance-free `encodeBits` bytes, `encodeBits_noprov`); a `.slot`'s
`movPieces (base + off) s 0 ws` write `src (s + (k - off))` at `base + k` exactly for
`off ≤ k < off + ws.sum` (induction on `ws` generalizing `o` and `fr`: each piece covers
`[o, o + w)`, later pieces don't touch it, `pieceFrame_outside`-style), which `SrcRel` relates.
Outside the field's range `pieceFrame` leaves `fr` (as in `pieceFrame_outside`): `hacc`. -/
theorem pieceFrame_src {ι : Inj} {src fr : Int → AbstractByte} {base : Int} {off : Nat}
    {sr : AggSrc} {eb acc : List AbstractByte} (hrel : SrcRel ι src sr eb)
    (hin : off + eb.length ≤ acc.length)
    (hacc : ∀ k (h : k < acc.length), ByteInj ι acc[k] (fr (base + k))) :
    (writeAt acc off eb).length = acc.length ∧
      ∀ k (h : k < (writeAt acc off eb).length), ByteInj ι (writeAt acc off eb)[k]
        (pieceFrame src (srcPieces (base + off) sr) fr (base + k)) := by
  have hlen := Ryo.Spec.Theorems.writeAt_length acc eb off hin
  refine ⟨hlen, fun k h => ?_⟩
  have hk : k < acc.length := hlen ▸ h
  by_cases hr : off ≤ k ∧ k < off + eb.length
  · rw [writeAt_getElem_in hin h hr]
    cases sr with
    | slot a s ws =>
      obtain ⟨hl, hb⟩ := hrel
      simp only [srcPieces]
      rw [pieceFrame_movPieces, if_pos (by omega)]
      have e : s + (base + (k : Int) - (base + (off : Int))) = s + ((k - off : Nat) : Int) := by
        omega
      rw [e]
      exact hb _ _
    | imm n bits =>
      obtain ⟨hl, hle⟩ := hrel
      obtain ⟨hl', hp⟩ := (Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle
      have hel := Ryo.Spec.Theorems.encodeBits_length n bits
      simp only [srcPieces, pieceFrame]
      rw [if_pos (by omega)]
      have ht : (base + (k : Int) - (base + (off : Int))).toNat = k - off := by omega
      have h2 : k - off < (encodeBits n bits).length := by omega
      rw [ht, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h2, Option.getD_some]
      exact ByteInj.of_le' (hp (k - off) (by omega) h2)
        (encodeBits_inj_self (List.getElem_mem h2))
    | zst =>
      simp only [SrcRel] at hrel
      subst hrel
      exfalso
      have h1 := hr.1
      have h2 := hr.2
      rw [List.length_nil] at h2
      omega
  · rw [writeAt_getElem_out hin h hk hr]
    have hfr : pieceFrame src (srcPieces (base + off) sr) fr (base + k) = fr (base + k) := by
      cases sr with
      | slot a s ws =>
        obtain ⟨hl, -⟩ := hrel
        simp only [srcPieces]
        rw [pieceFrame_movPieces, if_neg (by omega)]
      | imm n bits =>
        obtain ⟨hl, -⟩ := hrel
        simp only [srcPieces, pieceFrame]
        rw [if_neg (by omega)]
      | zst => rfl
    rw [hfr]
    exact hacc k hk

/-- All fields: `writeFields` of L0's field bytes against R's pieces of all fields (the
composition).

Proof: induction on `fields` generalizing `srcs ebs acc fr`; the empty case is `hacc`. For
`(off, t) :: fields` with `src :: srcs`, `eb :: ebs`: `aggPieces` is `srcPieces (base + off)
src ++ aggPieces base fields srcs`, so `pieceFrame_append` runs the first field's pieces first;
`pieceFrame_src` (with index 0 of `hsr`, `hin`) gives the relation for `writeAt acc off eb` and
the frame after them, which is the IH's `acc` and `fr` (the lengths stay, so `hin` carries
over; `List.map_cons`, `List.zip_cons_cons`, `writeFields`). -/
theorem pieceFrame_aggPieces {ι : Inj} {src : Int → AbstractByte} {base : Int} :
    ∀ {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc} {ebs : List (List AbstractByte)}
      {acc : List AbstractByte} {fr : Int → AbstractByte},
    fields.length = srcs.length → srcs.length = ebs.length →
    (∀ j (h1 : j < srcs.length) (h2 : j < ebs.length), SrcRel ι src srcs[j] ebs[j]) →
    (∀ j (h1 : j < fields.length) (h2 : j < ebs.length),
      fields[j].1 + ebs[j].length ≤ acc.length) →
    (∀ k (h : k < acc.length), ByteInj ι acc[k] (fr (base + k))) →
    (writeFields acc ((fields.map (·.1)).zip ebs)).length = acc.length ∧
      ∀ k (h : k < (writeFields acc ((fields.map (·.1)).zip ebs)).length),
        ByteInj ι (writeFields acc ((fields.map (·.1)).zip ebs))[k]
          (pieceFrame src (aggPieces base fields srcs) fr (base + k)) := by
  intro fields
  induction fields with
  | nil =>
    intro srcs ebs acc fr _ _ _ _ hacc
    exact ⟨rfl, fun k h => hacc k h⟩
  | cons fd fields ih =>
    intro srcs ebs acc fr hl1 hl2 hsr hin hacc
    obtain ⟨off, t⟩ := fd
    rcases srcs with _ | ⟨sr, srcs⟩
    · simp at hl1
    rcases ebs with _ | ⟨eb, ebs⟩
    · simp at hl2
    obtain ⟨hl0, hb0⟩ : (writeAt acc off eb).length = acc.length ∧
        ∀ k (h : k < (writeAt acc off eb).length), ByteInj ι (writeAt acc off eb)[k]
          (pieceFrame src (srcPieces (base + off) sr) fr (base + k)) :=
      pieceFrame_src (ι := ι) (src := src) (fr := fr) (base := base)
        (hsr 0 (by simp) (by simp)) (hin 0 (by simp) (by simp)) hacc
    have hih := ih (srcs := srcs) (ebs := ebs) (acc := writeAt acc off eb)
      (fr := pieceFrame src (srcPieces (base + off) sr) fr)
      (by simpa using hl1) (by simpa using hl2)
      (fun j h1 h2 => hsr (j + 1) (by simpa using h1) (by simpa using h2))
      (fun j h1 h2 => by rw [hl0]; exact hin (j + 1) (by simpa using h1) (by simpa using h2))
      hb0
    have e1 : (((off, t) :: fields).map (·.1)).zip (eb :: ebs) =
        (off, eb) :: ((fields.map (·.1)).zip ebs) := rfl
    have e2 : aggPieces base ((off, t) :: fields) (sr :: srcs) =
        srcPieces (base + off) sr ++ aggPieces base fields srcs := rfl
    rw [e1, e2, pieceFrame_append]
    exact ⟨hih.1.trans hl0, hih.2⟩

/-- A byte with provenance in `writeFields acc l` comes from `acc` or one of the written lists.

Proof: induction on `l` generalizing `acc`; a byte of `writeAt acc off b` is in `acc.take off`
or `acc.drop _` (so in `acc`: `List.mem_of_mem_take`, `List.mem_of_mem_drop`) or in `b`
(`List.mem_append`). -/
theorem writeFields_prov :
    ∀ {l : List (Nat × List AbstractByte)} {acc : List AbstractByte} {b : AbstractByte}
      {fr : ProvenanceFrag}, b ∈ writeFields acc l → b.provFrag = some fr →
      b ∈ acc ∨ ∃ e ∈ l, b ∈ e.2 := by
  intro l
  induction l with
  | nil => intro acc b fr hb _; exact .inl hb
  | cons e l ih =>
    intro acc b fr hb hfr
    obtain ⟨off, eb⟩ := e
    simp only [writeFields] at hb
    rcases ih hb hfr with h | ⟨e', he, hb'⟩
    · simp only [writeAt, List.mem_append] at h
      rcases h with (h | h) | h
      · exact .inl (List.mem_of_mem_take h)
      · exact .inr ⟨(off, eb), List.mem_cons_self .., h⟩
      · exact .inl (List.mem_of_mem_drop h)
    · exact .inr ⟨e', List.mem_cons_of_mem _ he, hb'⟩

/-! ### L0: the operands and the store -/

/-- L0's bytes for one field and where they come from: below `n` bytes loaded from the operand
local (`.slot`), below the constant's bytes (`.imm`), none (`.zst`). -/
def FieldMem (f : Spec.Frame) (m : Memory) : AggSrc → List AbstractByte → Prop
  | .slot a _ ws, eb => ∃ pa bs0, f.locals[a]? = some (some pa) ∧
      m.load pa ws.sum .one = .ok bs0 ∧ bytesLeDefined eb bs0 = true
  | .imm n bits, eb => bytesLeDefined eb (encodeBits n bits) = true
  | .zst, eb => eb = []

/-- L0's effect of a statement lowered to field writes into `_d` (`N` its size): the fields'
bytes `ebs` (`FieldMem`, inside `N`), `writeFields` of them at the fields' offsets over `N`
uninitialized bytes stored into `_d`, the stack unchanged. -/
def AggMem (f : Spec.Frame) (d : Local) (N : Nat) (fields : List (Nat × Spec.Ty))
    (srcs : List AggSrc) (s s' : Spec.State) : Prop :=
  ∃ pd ebs, f.locals[d]? = some (some pd) ∧ srcs.length = ebs.length ∧
    fields.length = ebs.length ∧
    (∀ j (h1 : j < srcs.length) (h2 : j < ebs.length), FieldMem f s.mem srcs[j] ebs[j]) ∧
    (∀ j (h1 : j < fields.length) (h2 : j < ebs.length), fields[j].1 + ebs[j].length ≤ N) ∧
    s.mem.store pd (writeFields (List.replicate N .uninit) ((fields.map (·.1)).zip ebs)) .one =
      .ok s'.mem ∧
    s'.stack = s.stack

/-- A constant operand whose `evalConst` decodes `bytes`: the value decodes, the state stays. -/
theorem runOn_evalOperand_const_dec {o : Spec.Oracle} {s s1 : Spec.State}
    {c : ConstOperand} {t : Spec.Ty} {r : Value × Spec.Ty} {bytes : List AbstractByte}
    (h : runOn (evalOperand (.const c t)) o s = (.ok r, s1))
    (hc : evalConst c t = decodeConst bytes t) :
    t.decode bytes = some r.1 ∧ r.2 = t ∧ s1 = s := by
  have e : evalOperand (.const c t) = (evalConst c t >>= fun v => pure (v, t)) := by
    first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
  rw [e, hc] at h
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok h
  obtain ⟨hr, hs1⟩ := runOn_pure_inv h2
  obtain ⟨hd, hs2⟩ := runOn_decodeConst_ok h1
  subst hr
  exact ⟨hd, rfl, hs1.trans hs2⟩

/-- A decoded value re-encodes below its bytes, at the type's size. -/
theorem enc_of_dec {t : Spec.Ty} {bs : List AbstractByte} {v : Value} (hwf : t.wf = true)
    (hl : bs.length = t.size) (hd : t.decode bs = some v) :
    ∃ eb, t.encode v = some eb ∧ bytesLeDefined eb bs = true ∧ eb.length = t.size := by
  obtain ⟨eb, he, hle⟩ := Ryo.Spec.Theorems.encode_decode_le t bs v hwf hl hd
  exact ⟨eb, he, hle, ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans hl⟩

/-- One operand of a field `AggField` accepts, evaluated: the state unchanged, and the
re-encoding of its value at the field type is the field's `FieldMem` bytes, of the type's size.

Proof: by cases on `hf` (rewrite `Γ.body` with `hbody`). `slot`: `local?_cases ha`,
`evalOperand_move`, `runOn_evalOperand_copy hs` (pointer `pa`, the load at `t`, `s1 = s`);
`typedLoad_inv hn` gives `bs0` of `n` bytes (`= ws.sum` by `hws`) with `t.decode bs0 = some v`;
`Ryo.Spec.Theorems.encode_decode_le t bs0 v hwf` the re-encoding `eb ≤ bs0` (its length by
`bytesLeDefined_iff`). `imm`: `evalOperand (.const c t)` is `evalConst c t >>= pure (·, t)`;
`runOn_decodeConst_ok` gives `t.decode (encodeBits t.size bits) = some v` and `s1 = s`
(`t.size = n` from `hn`, `encodeBits_length`); `encode_decode_le` as before. `zst`: unfold
`zstOperand` in `hop` (a whole local: as `slot` with a 0-byte load, `load_zero_inv`-style; a
`zeroSized`/`scalar` constant: `decodeConst` of `[]`, `encodeBits 0 _ = []`); the re-encoding
is below `[]`, so it is `[]`. -/
theorem evalField_mem {Γ : StmtCtx} {sd : LocalSlot} {o : Spec.Oracle} {s s1 : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) {op : Operand} {off : Nat} {t : Spec.Ty} {src : AggSrc}
    (hf : AggField Γ sd op off t src) {r : Value × Spec.Ty}
    (h : runOn (evalOperand op) o s = (.ok r, s1)) :
    s1 = s ∧ ∃ eb, t.encode r.1 = some eb ∧ FieldMem f s.mem src eb ∧ eb.length = t.size := by
  cases hf with
  | @slot _ a _ n _ sa ws ha hta hwf hn hpos hsa hsz hin hws hoff hap =>
    have h' : runOn (evalOperand (.copy ⟨a, []⟩)) o s = (.ok r, s1) := by
      rcases local?_cases ha with rfl | rfl
      · exact h
      · rw [evalOperand_move] at h; exact h
    obtain ⟨p, ty', v, hp, hty', hld, hr, hs1⟩ := runOn_evalOperand_copy hs h'
    rw [hbody] at hta
    obtain rfl : ty' = _ := Option.some.inj (hty'.symm.trans hta)
    subst hr
    obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv hn hld
    have hl := (movLoad_length hlo).trans (tySize_of hn).symm
    obtain ⟨eb, he, hle, hel⟩ := enc_of_dec hwf hl hd
    refine ⟨hs1, eb, he, ?_, hel⟩
    simp only [FieldMem]
    exact ⟨p, bs0, hp, by rw [hws]; exact hlo, hle⟩
  | @imm bits _ n _ hwf hn hpos hin =>
    obtain ⟨hd, -, hs1⟩ := runOn_evalOperand_const_dec h rfl
    have hl := Ryo.Spec.Theorems.encodeBits_length t.size bits
    obtain ⟨eb, he, hle, hel⟩ := enc_of_dec hwf hl hd
    refine ⟨hs1, eb, he, ?_, hel⟩
    simp only [FieldMem]
    rw [← tySize_of hn]
    exact hle
  | zst hwf hn hin hop =>
    have h0 := tySize_of hn
    have key : ∃ bs, t.decode bs = some r.1 ∧ bs.length = t.size ∧ s1 = s := by
      unfold zstOperand at hop
      split at hop
      next t' =>
        obtain rfl : t' = t := of_decide_eq_true hop
        obtain ⟨hd, -, hs1⟩ := runOn_evalOperand_const_dec (bytes := []) h rfl
        exact ⟨[], hd, by simp [h0], hs1⟩
      next b t' =>
        obtain rfl : t' = t := of_decide_eq_true hop
        obtain ⟨hd, -, hs1⟩ := runOn_evalOperand_const_dec h rfl
        exact ⟨_, hd, Ryo.Spec.Theorems.encodeBits_length _ _, hs1⟩
      next a =>
        have hta : f.body.locals[a]? = some t := by rw [← hbody]; exact of_decide_eq_true hop
        obtain ⟨p, ty', v, hp, hty', hld, hr, hs1⟩ := runOn_evalOperand_copy hs h
        obtain rfl : ty' = t := Option.some.inj (hty'.symm.trans hta)
        subst hr
        obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv hn hld
        exact ⟨bs0, hd, (movLoad_length hlo).trans h0.symm, hs1⟩
      next a =>
        have hta : f.body.locals[a]? = some t := by rw [← hbody]; exact of_decide_eq_true hop
        rw [evalOperand_move] at h
        obtain ⟨p, ty', v, hp, hty', hld, hr, hs1⟩ := runOn_evalOperand_copy hs h
        obtain rfl : ty' = t := Option.some.inj (hty'.symm.trans hta)
        subst hr
        obtain ⟨bs0, hlo, hd⟩ := typedLoad_inv hn hld
        exact ⟨bs0, hd, (movLoad_length hlo).trans h0.symm, hs1⟩
      · cases hop
    obtain ⟨bs, hd, hl, hs1⟩ := key
    obtain ⟨eb, he, hle, hel⟩ := enc_of_dec hwf hl hd
    refine ⟨hs1, eb, he, ?_, hel⟩
    simp only [FieldMem]
    exact List.eq_nil_of_length_eq_zero (hel.trans h0)

/-- `Ty.encodeFields` as `writeFields` of the fields' encodings. -/
theorem encodeFields_writeFields : ∀ {fs : List (Nat × Spec.Ty)} {vs : List Value}
    {acc bs : List AbstractByte}, Spec.Ty.encodeFields fs vs acc = some bs →
    ∃ ebs : List (List AbstractByte), ebs.length = fs.length ∧ vs.length = fs.length ∧
      (∀ j (h1 : j < fs.length) (h2 : j < vs.length) (h3 : j < ebs.length),
        fs[j].2.encode vs[j] = some ebs[j]) ∧
      bs = writeFields acc ((fs.map (·.1)).zip ebs) := by
  intro fs
  induction fs with
  | nil =>
    intro vs acc bs h
    cases vs with
    | nil =>
      simp only [Spec.Ty.encodeFields, Option.some.injEq] at h
      exact ⟨[], rfl, rfl, fun j h1 _ _ => by simp at h1, h.symm⟩
    | cons _ _ => simp [Spec.Ty.encodeFields] at h
  | cons fd fs ih =>
    intro vs acc bs h
    obtain ⟨off, t⟩ := fd
    cases vs with
    | nil => simp [Spec.Ty.encodeFields] at h
    | cons v vs =>
      simp only [Spec.Ty.encodeFields, Option.bind_eq_bind] at h
      cases he : t.encode v with
      | none => simp [he] at h
      | some eb =>
        simp only [he, Option.bind_some] at h
        obtain ⟨ebs, hl1, hl2, hall, hbs⟩ := ih h
        refine ⟨eb :: ebs, by simp [hl1], by simp [hl2], ?_, hbs⟩
        intro j h1 h2 h3
        cases j with
        | zero => exact he
        | succ j =>
          exact hall j (by simpa using h1) (by simpa using h2) (by simpa using h3)

/-- Parts of `m` bytes written at `k * m, (k + 1) * m, …`: the concatenation after the prefix. -/
theorem writeFields_flatten {m : Nat} : ∀ (parts : List (List AbstractByte)) (k : Nat)
    (acc : List AbstractByte), (∀ p ∈ parts, p.length = m) →
    acc.length = k * m + parts.length * m →
    writeFields acc (((List.range' k parts.length).map (· * m)).zip parts) =
      acc.take (k * m) ++ parts.flatten
  | [], k, acc, _, hl => by
    simp only [List.length_nil, Nat.zero_mul, Nat.add_zero] at hl
    show acc = acc.take (k * m) ++ []
    rw [List.take_of_length_le (Nat.le_of_eq hl), List.append_nil]
  | p :: ps, k, acc, hp, hl => by
    have hpm := hp p (List.mem_cons_self ..)
    have hps : ∀ q ∈ ps, q.length = m := fun q hq => hp q (List.mem_cons_of_mem _ hq)
    simp only [List.length_cons, Nat.succ_mul] at hl
    have hw : (writeAt acc (k * m) p).length = acc.length :=
      Ryo.Spec.Theorems.writeAt_length acc p (k * m) (by omega)
    have e1 : ((List.range' k (p :: ps).length).map (· * m)).zip (p :: ps) =
        (k * m, p) :: ((List.range' (k + 1) ps.length).map (· * m)).zip ps := by
      first | rfl | simp [List.range'_succ]
    rw [e1]
    show writeFields (writeAt acc (k * m) p) _ = _
    rw [writeFields_flatten ps (k + 1) _ hps (by rw [hw, Nat.succ_mul]; omega)]
    have hA : (acc.take (k * m)).length = k * m := by simp; omega
    have e2 : (writeAt acc (k * m) p).take ((k + 1) * m) = acc.take (k * m) ++ p := by
      unfold writeAt
      exact List.take_left' (by simp only [List.length_append, hA, hpm, Nat.succ_mul])
    rw [e2, List.flatten_cons, List.append_assoc]

/-- A sized type's layout. -/
theorem layout_of_size {t : Spec.Ty} {m : Nat} (h : t.size? = some m) :
    ∃ a, t.layout = .sized m a := by
  unfold Spec.Ty.size? at h
  cases hl : t.layout with
  | sized s a =>
    rw [hl] at h
    obtain rfl : s = m := by simpa [LayoutStrategy.size?] using h
    exact ⟨a, rfl⟩
  | _ => rw [hl] at h; simp [LayoutStrategy.size?] at h

/-- L0's encoding of `.tuple vs` at a type `aggLayout` covers: each field's encoding written at
its offset over `N` uninitialized bytes (the field bytes "at offsets", padding uninit).

Proof: unfold `aggLayout` (`split at hlay`). A tuple `.tuple fields head none`: `Ty.encode` is
`Ty.encodeFields fields vs (List.replicate head.headSizeAndAlign.1 .uninit)` and `N` is
`head.headSizeAndAlign.1` (`Ty.size?`, `Ty.layout`); then by induction on `fields`
generalizing `vs` and the accumulator, `encodeFields` succeeding means equal lengths and each
`t.encode v = some b`, and its result is `writeFields` of them (`Ty.encodeFields`,
`writeFields`). An array `.array elem n` with `elem.size? = some m`: `N = m * n`, `vs.length =
n`, `vs.mapM elem.encode = some parts` (each part of length `m` by
`Ryo.Spec.Theorems.encode_length` with `hwf` at `elem`, sized by `m`), and `parts.flatten` is
`writeFields (List.replicate (m * n) .uninit)` of `(i * m, parts[i])` (induction on `n`: write
`i`'s part over uninit bytes `[i * m, (i + 1) * m)`). -/
theorem aggLayout_encode {ty : Spec.Ty} {fields : List (Nat × Spec.Ty)} {N : Nat}
    {vs : List Value} {bs : List AbstractByte}
    (hlay : aggLayout ty = some fields) (hN : ty.size? = some N)
    (hwf : ∀ p ∈ fields, p.2.wf = true) (he : ty.encode (.tuple vs) = some bs) :
    ∃ ebs, ebs.length = fields.length ∧ vs.length = fields.length ∧
      (∀ j (h1 : j < fields.length) (h2 : j < vs.length) (h3 : j < ebs.length),
        fields[j].2.encode vs[j] = some ebs[j]) ∧
      bs = writeFields (List.replicate N .uninit) ((fields.map (·.1)).zip ebs) := by
  unfold aggLayout at hlay
  split at hlay
  next fs head =>
    obtain rfl := Option.some.inj hlay
    have hN' : (Spec.Ty.tuple fs head none).size? = some head.headSizeAndAlign.1 := by
      first | rfl | simp [Spec.Ty.size?, Spec.Ty.layout, LayoutStrategy.size?]
    rw [hN'] at hN
    obtain rfl := Option.some.inj hN
    have he' : Spec.Ty.encodeFields fs vs
        (List.replicate head.headSizeAndAlign.1 .uninit) = some bs := by
      first | exact he | simpa only [Spec.Ty.encode] using he
    exact encodeFields_writeFields he'
  next elem n =>
    split at hlay
    next m hm =>
      obtain rfl := Option.some.inj hlay
      obtain ⟨a, hla⟩ := layout_of_size hm
      have hl2 : (Spec.Ty.array elem n).layout = .sized (m * n) a := by
        conv => lhs; unfold Spec.Ty.layout
        rw [hla]
      have hNm : m * n = N := by
        unfold Spec.Ty.size? at hN
        rw [hl2] at hN
        simpa [LayoutStrategy.size?] using hN
      have hes : elem.isSized = true := by
        unfold Spec.Ty.isSized; rw [hla]; rfl
      simp only [Spec.Ty.encode, bne_iff_ne, ne_eq, Option.bind_eq_bind, Option.pure_def] at he
      split at he
      · simp at he
      · rename_i hlen
        simp at hlen
        cases hp : vs.mapM elem.encode with
        | none => simp [hp] at he
        | some parts =>
          simp [hp] at he
          subst he
          obtain ⟨hpl, hpe⟩ := (Ryo.Spec.Theorems.mapM_option_iff _ _ _).1 hp
          have hplen : parts.length = n := hpl.trans hlen
          have hpm : ∀ q ∈ parts, q.length = m := by
            intro q hq
            obtain ⟨i, hi, rfl⟩ := List.getElem_of_mem hq
            have hwe : elem.wf = true :=
              hwf (i * m, elem) (List.mem_map.mpr ⟨i, List.mem_range.mpr (by omega), rfl⟩)
            exact (Ryo.Spec.Theorems.encode_length elem vs[i] _ hwe hes
              (hpe i (by omega) hi)).trans (tySize_of hm)
          refine ⟨parts, by simp [hplen], by simp [hlen], ?_, ?_⟩
          · intro j h1 h2 h3
            rw [List.getElem_map]
            exact hpe j h2 h3
          · have hf1 : ((List.range n).map fun i => (i * m, elem)).map (·.1) =
                (List.range' 0 parts.length).map (· * m) := by
              rw [hplen, ← List.range_eq_range']
              simp [List.map_map, Function.comp_def]
            rw [hf1, writeFields_flatten parts 0 _ hpm (by simp [← hNm, hplen, Nat.mul_comm])]
            simp
    next => simp at hlay
  next => simp at hlay

/-- A field's bytes fit in `_d`'s slot. -/
theorem AggField.bound {Γ : StmtCtx} {sd : LocalSlot} {op : Operand} {off : Nat} {t : Spec.Ty}
    {src : AggSrc} (hf : AggField Γ sd op off t src) : off + t.size ≤ sd.size := by
  cases hf with
  | slot ha hta hwf hn hpos hsa hsz hin => rw [tySize_of hn]; omega
  | imm hwf hn hpos hin => rw [tySize_of hn]; omega
  | zst hwf hn hin hop => rw [tySize_of hn]; omega

theorem AggFields.wf {Γ : StmtCtx} {sd : LocalSlot} {ops : List Operand}
    {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc} (hf : AggFields Γ sd ops fields srcs) :
    ∀ p ∈ fields, p.2.wf = true := by
  induction hf with
  | nil => intro p hp; cases hp
  | cons h hs ih =>
    intro p hp
    rcases List.mem_cons.mp hp with rfl | hp
    · cases h with
      | slot ha hta hwf => exact hwf
      | imm hwf => exact hwf
      | zst hwf => exact hwf
    · exact ih p hp

/-- The operands of `AggFields`, evaluated in order: the state unchanged, each value's field
encoding with its `FieldMem` and bound. -/
theorem aggFields_mapM {Γ : StmtCtx} {sd : LocalSlot} {o : Spec.Oracle} {s : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    (hbody : Γ.body = f.body) :
    ∀ {ops : List Operand} {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc},
    AggFields Γ sd ops fields srcs → ∀ {vals : List Value} {s1 : Spec.State},
    runOn (ops.mapM fun o => do pure (← evalOperand o).1) o s = (.ok vals, s1) →
    s1 = s ∧ ∃ ebs : List (List AbstractByte), ebs.length = fields.length ∧
      vals.length = fields.length ∧ srcs.length = ebs.length ∧
      (∀ j (h1 : j < fields.length) (h2 : j < vals.length) (h3 : j < ebs.length),
        fields[j].2.encode vals[j] = some ebs[j]) ∧
      (∀ j (h1 : j < srcs.length) (h2 : j < ebs.length), FieldMem f s.mem srcs[j] ebs[j]) ∧
      (∀ j (h1 : j < fields.length) (h2 : j < ebs.length),
        fields[j].1 + ebs[j].length ≤ sd.size) := by
  intro ops fields srcs hf
  induction hf with
  | nil =>
    intro vals s1 h
    rw [List.mapM_nil] at h
    obtain ⟨hv, hs1⟩ := runOn_pure_inv h
    subst hv
    refine ⟨hs1, [], rfl, rfl, rfl, ?_, ?_, ?_⟩ <;> intro j h1 <;> simp at h1
  | cons hfd hfs ih =>
    intro vals s1 h
    rw [List.mapM_cons] at h
    obtain ⟨a, s2, h1, h2⟩ := runOn_bind_ok h
    obtain ⟨as, s3, h3, h4⟩ := runOn_bind_ok h2
    obtain ⟨hv, hs1⟩ := runOn_pure_inv h4
    obtain ⟨r, s4, h5, h6⟩ := runOn_bind_ok h1
    obtain ⟨ha, hs2⟩ := runOn_pure_inv h6
    obtain ⟨hs4, eb, he, hfm, hel⟩ := evalField_mem hs hbody hfd h5
    have hs2' : s2 = s := hs2.trans hs4
    rw [hs2'] at h3
    obtain ⟨hs3, ebs, hl1, hl2, hl3, hall, hfms, hbds⟩ := ih h3
    subst hv ha
    have hb := AggField.bound hfd
    refine ⟨hs1.trans hs3, eb :: ebs, by simp [hl1], by simp [hl2], by simp [hl3], ?_, ?_, ?_⟩
    · intro j h1 h2 h3
      cases j with
      | zero => exact he
      | succ j =>
        exact hall j (by simpa using h1) (by simpa using h2) (by simpa using h3)
    · intro j h1 h2
      cases j with
      | zero => exact hfm
      | succ j => exact hfms j (by simpa using h1) (by simpa using h2)
    · intro j h1 h2
      cases j with
      | zero => show _ + eb.length ≤ sd.size; rw [hel]; exact hb
      | succ j => exact hbds j (by simpa using h1) (by simpa using h2)

/-- `agg`'s L0 side.

Proof: invert the assignment as `assign_use_inv` does (its proof carries over, the rvalue's run
being `ops.mapM (fun o => do pure (← evalOperand o).1) >>= ...`): `_d`'s pointer `pd`, the
values `vals` with the state `s1`, the store of the rvalue's value at `ty`. For `k ≠ rawPtr`
and `ty` a tuple or array (`aggLayout`), `evalRvalue`'s value is `.tuple vals` (`cases k`; for
`adt` the destination match takes its last branch). By induction over `hf` against the
`mapM` (`List.mapM_cons`, `runOn_bind_ok`), `evalField_mem` gives `s1 = s`, each value's
field encoding `eb_j` and `FieldMem`; `typedStore_inv` gives the encoding of `.tuple vals` at
`ty`, which `aggLayout_encode` (`hwf` from `hf`'s fields) writes as `writeFields` of the
fields' encodings: they are the `eb_j` (two encodings of one value). The bounds come from
`AggField`'s `hin` and `eb_j.length = t_j.size`. -/
theorem agg_mem {Γ : StmtCtx} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {k : AggregateKind} {ops : List Operand} {ty : Spec.Ty}
    {fields : List (Nat × Spec.Ty)} {sd : LocalSlot} {srcs : List AggSrc}
    (hk : k ≠ .rawPtr) (htd : Γ.body.locals[d]? = some ty)
    (hlay : aggLayout ty = some fields) (hsz : ty.size? = some sd.size)
    (hf : AggFields Γ sd ops fields srcs)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.aggregate k ops))) o s = (.ok (), s')) :
    AggMem f d sd.size fields srcs s s' := by
  have e : evalStatement (.assign ⟨d, []⟩ (.aggregate k ops)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.aggregate k ops) ty' >>= fun v => placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd', hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.aggregate k ops) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  rw [hbody] at htd
  obtain rfl : td = ty := Option.some.inj (htd'.symm.trans htd)
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  have e2 : evalRvalue (.aggregate k ops) td =
      (ops.mapM (fun o => do pure (← evalOperand o).1) >>= fun vals =>
        pure (Value.tuple vals)) := by
    have hshape : (∃ fs hd, td = .tuple fs hd none) ∨ (∃ e n, td = .array e n) := by
      unfold aggLayout at hlay
      split at hlay
      · exact .inl ⟨_, _, rfl⟩
      · exact .inr ⟨_, _, rfl⟩
      · simp at hlay
    rcases hshape with ⟨fs, hd, rfl⟩ | ⟨el, n, rfl⟩ <;> cases k <;>
      first
        | exact absurd rfl hk
        | rfl
        | (simp only [evalRvalue]; done)
        | (unfold evalRvalue; rfl)
  rw [e2] at h3
  obtain ⟨vals, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨hv, hs3⟩ := runOn_pure_inv h6
  obtain ⟨hs5, ebs, hl1, hl2, hl3, hall, hfms, hbds⟩ := aggFields_mapM hs hbody hf h5
  subst hv
  have hst' : typedStore s2.mem pd (.tuple vals) td .one = .ok mem' := hst
  rw [hs3, hs5] at hst'
  obtain ⟨bs, he, hsto⟩ := typedStore_inv hst'
  obtain ⟨ebs', hl1', hl2', hall', hbs⟩ := aggLayout_encode hlay hsz (AggFields.wf hf) he
  have hee : ebs' = ebs := by
    apply List.ext_getElem (by omega)
    intro j h1 h2
    exact Option.some.inj ((hall' j (by omega) (by omega) h1).symm.trans
      (hall j (by omega) (by omega) h2))
  subst hee
  refine ⟨pd, ebs', hld, hl3, hl1.symm, hfms, ?_, ?_, ?_⟩
  · intro j h1 h2
    exact hbds j h1 h2
  · rw [← hbs, hsto, hs']
  · rw [hs']
    show s2.stack = s.stack
    rw [hs3, hs5]

/-- `useAny`'s L0 side: one field at offset 0.

Proof: `assign_use_inv hs h` (pointer, `td = ty` by `hbody`/`htd`, the operand run, the
store); `evalField_mem hs hbody hf` (`s1 = s`, the operand's re-encoding `eb` with
`FieldMem`, `eb.length = ty.size = sd.size`); `typedStore_inv` stores `ty.encode r.1 = some
eb`, and `writeFields (List.replicate sd.size .uninit) [(0, eb)] = eb` (`writeAt` at 0 of a
list of the same length: `List.take_zero`, `List.drop_eq_nil_of_le`). -/
theorem aggUse_mem {Γ : StmtCtx} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {op : Operand} {ty : Spec.Ty} {sd : LocalSlot} {src : AggSrc}
    (htd : Γ.body.locals[d]? = some ty) (hsz : ty.size? = some sd.size)
    (hf : AggField Γ sd op 0 ty src)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use op))) o s = (.ok (), s')) :
    AggMem f d sd.size [(0, ty)] [src] s s' := by
  obtain ⟨pd, td, r, s1, hpd, htd', hev, mem', hst, hs'⟩ := assign_use_inv hs h
  rw [hbody] at htd
  obtain rfl : td = ty := Option.some.inj (htd'.symm.trans htd)
  obtain ⟨hs1, eb, he, hfm, hel⟩ := evalField_mem hs hbody hf hev
  rw [hs1] at hst hs'
  obtain ⟨bs, he', hsto⟩ := typedStore_inv hst
  obtain rfl : bs = eb := Option.some.inj (he'.symm.trans he)
  have hbl : bs.length = sd.size := hel.trans (tySize_of hsz)
  have hw : writeFields (List.replicate sd.size AbstractByte.uninit) [(0, bs)] = bs := by
    show writeAt _ 0 bs = bs
    simp [writeAt, hbl]
  refine ⟨pd, [bs], hpd, rfl, rfl, ?_, ?_, ?_, ?_⟩
  · intro j h1 h2
    cases j with
    | zero => exact hfm
    | succ j => simp at h1
  · intro j h1 h2
    cases j with
    | zero => show 0 + bs.length ≤ sd.size; omega
    | succ j => simp at h1
  · show s.mem.store pd (writeFields (List.replicate sd.size .uninit) [(0, bs)]) .one = _
    rw [hw, hsto, hs']
  · rw [hs']

/-! ### L0 against R: the sources -/

/-- A successful `mapM` in `Except` succeeds at each element (`Inline/Rel.lean`'s `mapM_ok`). -/
theorem aggMapM_ok {α β ε : Type} {f : α → Except ε β} :
    ∀ {l : List α} {bs : List β}, l.mapM f = .ok bs →
      bs.length = l.length ∧ ∀ i (h1 : i < l.length) (h2 : i < bs.length), f l[i] = .ok bs[i]
  | [], bs, h => by
    simp only [List.mapM_nil, pure, Except.pure, Except.ok.injEq] at h
    subst h; simp
  | x :: l, bs, h => by
    simp only [List.mapM_cons, bind, Except.bind] at h
    cases hx : f x with
    | error e => simp [hx] at h
    | ok b =>
      simp only [hx] at h
      cases hl : l.mapM f with
      | error e => simp [hl] at h
      | ok bs' =>
        simp only [hl, pure, Except.pure, Except.ok.injEq] at h
        subst h
        obtain ⟨hlen, hall⟩ := aggMapM_ok hl
        refine ⟨by simp [hlen], fun i h1 h2 => ?_⟩
        cases i with
        | zero => simpa using hx
        | succ i => simpa using hall i (by simpa using h1) (by simpa using h2)

/-- A field's L0 bytes against what R reads for it (`frameByte` of R's state before the
statement), and R's reads of a `.slot` source succeed.

Proof: by cases on `hf` (and `hfm`). `slot`: `hrel.opnd hpa hsa (hla ..)` gives `_a`'s
`LocalRel` at `true`; the load is of `sa.size` bytes (`hsz`, `hws`), so `readLocal_inj`
gives `s1.st.readFrame sa.off sa.size = .ok bs1` with `BytesInj ι bs0 bs1`; `readFrame` is
`(List.range n).mapM (byteAt ∘ (sa.off + ·))`, so each `byteAt (sa.off + i)` is
`.ok bs1[i]` (induction over the `mapM`, `List.mapM_cons`) and `frameByte` is `bs1[i]`;
`BytesInj.of_le hle` relates `eb` to `bs1`, pointwise by `BytesInj.getElem'`; lengths by
`BytesInj.length`. `imm`: the length from `bytesLeDefined` (`bytesLeDefined_iff`) and
`encodeBits_length`. `zst`: `hfm`. -/
theorem srcRel_of_fieldMem {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {sd : LocalSlot}
    {op : Operand} {off : Nat} {t : Spec.Ty} {src : AggSrc} {eb : List AbstractByte}
    (hf : AggField Γ sd op off t src) (hfm : FieldMem f m0 src eb)
    (hla : ∀ a s ws, src = .slot a s ws → live a = true) :
    SrcRel ι (frameByte s1.st) src eb ∧
      ∀ a s ws, src = .slot a s ws →
        ∀ i < ws.sum, s1.st.byteAt (s + i) = .ok (frameByte s1.st (s + i)) := by
  cases hf with
  | @slot _ a _ n _ sa ws ha hta hwf hn hpos hsa hsz hin hws hoff hap =>
    obtain ⟨pa, bs0, hpa, hld, hle⟩ := hfm
    have hlr := hrel.opnd hpa hsa (hla _ _ _ rfl)
    obtain ⟨bs1, hrd, hbi⟩ := readLocal_inj (al := .one) (bs0 := bs0) hrel.frame.mem hlr
      (by rw [hsz, ← hws]; exact hld)
    unfold OpSem.State.readFrame at hrd
    obtain ⟨hlen1, hall⟩ := aggMapM_ok hrd
    have hl1 : bs1.length = n := by rw [← hsz]; simpa using hlen1
    have hbyte : ∀ i (h : i < n), s1.st.byteAt (sa.off + i) = .ok (bs1[i]'(by omega)) := by
      intro i h
      have := hall i (by simp; omega) (by omega)
      simpa using this
    have hfb : ∀ i (h : i < n), frameByte s1.st (sa.off + i) = bs1[i]'(by omega) := by
      intro i h
      simp only [frameByte, hbyte i h]
    have hbe := BytesInj.of_le hle hbi
    have hel := BytesInj.length hbe
    refine ⟨?_, ?_⟩
    · simp only [SrcRel]
      refine ⟨by omega, fun i h => ?_⟩
      rw [hfb i (by omega)]
      exact hbe.getElem' i h (by omega)
    · intro a' s' ws' he i hi
      cases he
      rw [hfb i (by omega)]
      exact hbyte i (by omega)
  | imm hwf hn hpos hin =>
    simp only [FieldMem] at hfm
    refine ⟨?_, fun a s ws he => by cases he⟩
    simp only [SrcRel]
    exact ⟨((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hfm).1.trans
      (Ryo.Spec.Theorems.encodeBits_length _ _), hfm⟩
  | zst hwf hn hin hop =>
    simp only [FieldMem] at hfm
    refine ⟨?_, fun a s ws he => by cases he⟩
    simp only [SrcRel]
    exact hfm

/-- The operand locals of `.slot` fields are the rvalue's (`hlo` makes them live).

Proof: induction on `hf`; `List.mem_cons` splits the source; a `.slot` field's `ha :
op.local? = some a` puts `a` in `operandLocals op` (`local?_cases`, `placeLocals`), which is in
`(op :: ops).flatMap operandLocals` (`List.mem_flatMap`). -/
theorem aggFields_slot_mem {Γ : StmtCtx} {sd : LocalSlot} {ops : List Operand}
    {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc} (hf : AggFields Γ sd ops fields srcs) :
    ∀ src ∈ srcs, ∀ a s ws, src = .slot a s ws → a ∈ ops.flatMap operandLocals := by
  induction hf with
  | nil => intro src h; cases h
  | cons h hs ih =>
    intro src hsrc a s ws he
    rcases List.mem_cons.mp hsrc with rfl | hm
    · cases h with
      | slot ha =>
        cases he
        rcases local?_cases ha with rfl | rfl <;>
          simp [List.flatMap_cons, operandLocals, placeLocals]
      | imm => cases he
      | zst => cases he
    · have := ih src hm a s ws he
      simp only [List.flatMap_cons, List.mem_append]
      exact .inr this

/-! ### R's frame after the pieces against L0's memory -/

/-- `writeLocal_priv` for a frame changed by several private writes: memory and escapes
unchanged, the slot's bytes refining what L0 stored there.

Proof: as `writeLocal_priv`, with the hypotheses in place of `writeFrame_private_eq`'s facts
(`escapedAt` reads only `escaped`): `Memory.store_eq_ok` (the empty store leaves `m0`; else only
the unmapped allocation `a` changes, so `MemInj` holds by `hm`), the new allocation's data is
`bs0` (`fold_getElem0`), related to `st'.frame (slot.off + k)` by `hrel`. -/
theorem frameLocal_priv {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 m0' : Memory}
    {slot : LocalSlot} {p : ThinPointer} (hm : MemInj ι m0 st.mem)
    (a : AllocId) (x : Allocation) (hp : p.prov = some a) (hι : ι a = none)
    (hx : m0.get? a = some x) (hlive : x.live = true)
    (haddr : (x.addr : Int) = fp + slot.off) (hpaddr : p.addr = x.addr)
    (hsize : x.data.size = slot.size)
    (hpriv : ∀ k < slot.size, st.escapedAt (slot.off + k) = none)
    {bs0 : List AbstractByte} (hlen : bs0.length = slot.size)
    (hbs : ∀ k (h : k < bs0.length), ByteInj ι bs0[k] (st'.frame (slot.off + k)))
    {al : Align} (h0 : m0.store p bs0 al = .ok m0')
    (hmem : st'.mem = st.mem) (hesc : st'.escaped = st.escaped) :
    MemInj ι m0' st'.mem ∧ LocalRel ι fp st' m0' slot p true := by
  have hea : ∀ o, st'.escapedAt o = st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]
  have hpriv' : ∀ k < slot.size, st'.escapedAt (slot.off + k) = none :=
    fun k hk => (hea _).trans (hpriv k hk)
  rcases Ryo.Spec.Theorems.Memory.store_eq_ok h0 with
    ⟨-, hz, rfl⟩ | ⟨id, hid, -, -, hpid, -, -, -, -, hm0'⟩
  · refine ⟨by rw [hmem]; exact hm,
      .priv a x hp hι hx hlive haddr hpaddr hsize hpriv' ?_⟩
    intro _ k hk
    exfalso
    omega
  · have hai : a = id := Option.some.inj (hp.symm.trans hpid)
    cases hai
    have hxa : m0.allocs[a] = x := by
      simp only [Memory.get?, Array.getElem?_eq_getElem hid, Option.some.injEq] at hx
      exact hx
    subst hxa
    -- MemInj: only the unmapped allocation `a` changed.
    have hmi : MemInj ι m0' st'.mem := by
      rw [hmem]
      intro a' b x' hg hb
      have hne : a ≠ a' := fun e => by subst e; rw [hι] at hb; cases hb
      have hg' : m0.get? a' = some x' := by
        subst hm0'
        simpa [Memory.get?, Array.getElem?_set, hne] using hg
      exact hm a' b x' hg' hb
    refine ⟨hmi, ?_⟩
    have ha' : a < m0'.allocs.size := by subst hm0'; simpa using hid
    have hcomp : m0'.allocs[a] = { m0.allocs[a] with
        data := (bs0.zipIdx).foldl (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b)
          m0.allocs[a].data } := by
      subst hm0'; simp
    have hdata : m0'.allocs[a].data =
        (bs0.zipIdx).foldl (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b)
          m0.allocs[a].data := by rw [hcomp]
    have hsz' : m0'.allocs[a].data.size = slot.size := by
      rw [hdata]
      exact (Ryo.Spec.Theorems.foldl_set_size bs0 0 (p.addr - m0.allocs[a].addr)
        m0.allocs[a].data).trans hsize
    refine .priv a m0'.allocs[a] hp hι ?_ (by rw [hcomp]; exact hlive)
      (by rw [hcomp]; exact haddr) (by rw [hcomp]; exact hpaddr) hsz' hpriv' ?_
    · show m0'.allocs[a]? = _
      exact Array.getElem?_eq_getElem ha'
    · intro _ k hk
      have hk2 : k < ((bs0.zipIdx).foldl
          (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b) m0.allocs[a].data).size :=
        hdata ▸ hk
      obtain ⟨hk0, hF⟩ := fold_getElem0 (bs := bs0) (d := m0.allocs[a].data)
        (off := p.addr - m0.allocs[a].addr) (by omega) (by omega) hk2
      have hdk : m0'.allocs[a].data[k] = bs0[k] := by
        have : ∀ (D : Array AbstractByte), D = (bs0.zipIdx).foldl
            (fun d (b, i) => d.set! (p.addr - m0.allocs[a].addr + i) b) m0.allocs[a].data →
            ∀ (h : k < D.size), D[k] = bs0[k] := by
          intro D hD _; subst hD; exact hF
        exact this _ hdata hk
      rw [hdk]
      exact hbs k hk0

/-- `LocalRel.writeFrame_apart` for a frame changed only inside `[lo, hi)`.

Proof: as `LocalRel.writeFrame_apart`: `priv` keeps its allocation and its bytes (the frame
outside `[lo, hi)` is unchanged, `hfr` with `hapart`), escapes are the same (`hesc`); `esc`
needs only the memory (`hmem`) and the escapes. -/
theorem LocalRel.frame_apart {ι : Inj} {fp : Nat} {st st' : OpSem.State} {m0 : Memory}
    {slot : LocalSlot} {p : ThinPointer} {lv : Bool} (hr : LocalRel ι fp st m0 slot p lv)
    {lo hi : Int} (hmem : st'.mem = st.mem) (hesc : st'.escaped = st.escaped)
    (hfr : ∀ o, (o < lo ∨ hi ≤ o) → st'.frame o = st.frame o)
    (hapart : hi ≤ slot.off ∨ slot.off + slot.size ≤ lo) :
    LocalRel ι fp st' m0 slot p lv := by
  have hea : ∀ o, st'.escapedAt o = st.escapedAt o := fun o => by
    unfold OpSem.State.escapedAt; rw [hesc]
  cases hr with
  | priv a x hp hι hx hlive haddr hpaddr hsize hpv hbytes =>
    refine .priv a x hp hι hx hlive haddr hpaddr hsize
      (fun k hk => (hea _).trans (hpv k hk)) ?_
    intro hl k hk
    rw [hfr _ (by omega)]
    exact hbytes hl k hk
  | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
    exact .esc a x e y hp hι hx hlive haddr hpaddr hsize
      (fun k hk => (hea _).trans (hin k hk)) (by rw [hmem]; exact hy) hylive hyaddr hysize

/-! ### The simulation -/

theorem AggFields.length {Γ : StmtCtx} {sd : LocalSlot} {ops : List Operand}
    {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc} (hf : AggFields Γ sd ops fields srcs) :
    fields.length = srcs.length := by
  induction hf with
  | nil => rfl
  | cons h hs ih => simp [ih]

theorem AggFields.get {Γ : StmtCtx} {sd : LocalSlot} {ops : List Operand}
    {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc} (hf : AggFields Γ sd ops fields srcs) :
    ∀ j (h1 : j < fields.length) (h2 : j < srcs.length),
      ∃ op, AggField Γ sd op fields[j].1 fields[j].2 srcs[j] := by
  induction hf with
  | nil => intro j h1; simp at h1
  | cons h hs ih =>
    intro j h1 h2
    cases j with
    | zero => exact ⟨_, h⟩
    | succ j => exact ih j (by simpa using h1) (by simpa using h2)

/-- A `mov` piece reads inside a `.slot` source's range. -/
theorem aggPieces_mov_src (dOff : Int) : ∀ (fields : List (Nat × Spec.Ty)) (srcs : List AggSrc)
    (p : AggPiece), p ∈ aggPieces dOff fields srcs → ∀ d s' w, p = .mov d s' w →
    ∃ src ∈ srcs, ∃ a s ws, src = .slot a s ws ∧ ∃ o' : Nat, s' = s + o' ∧ o' + w ≤ ws.sum
  | [], _, p, hp => by simp [aggPieces] at hp
  | _ :: _, [], p, hp => by simp [aggPieces] at hp
  | (off, t) :: fs, src :: srcs, p, hp => by
    intro d s' w he
    simp only [aggPieces, List.mem_append] at hp
    rcases hp with hp | hp
    · cases src with
      | slot a s ws =>
        simp only [srcPieces] at hp
        obtain ⟨o', w', rfl, -, h2⟩ := movPieces_mem hp
        cases he
        exact ⟨_, List.mem_cons_self .., a, s, ws, rfl, o', rfl, by omega⟩
      | imm n bits =>
        simp only [srcPieces, List.mem_singleton] at hp
        subst hp
        cases he
      | zst => simp [srcPieces] at hp
    · obtain ⟨src', hm, rest⟩ := aggPieces_mov_src dOff fs srcs p hp d s' w he
      exact ⟨src', List.mem_cons_of_mem _ hm, rest⟩

/-- Every stored byte with provenance carries a loaded byte's provenance. -/
theorem aggStored_prov {f : Spec.Frame} {m : Memory} {N : Nat} {fields : List (Nat × Spec.Ty)}
    {srcs : List AggSrc} {ebs : List (List AbstractByte)} (hl : srcs.length = ebs.length)
    (hfm : ∀ j (h1 : j < srcs.length) (h2 : j < ebs.length), FieldMem f m srcs[j] ebs[j]) :
    ∀ b ∈ writeFields (List.replicate N .uninit) ((fields.map (·.1)).zip ebs), ∀ fr,
      b.provFrag = some fr → ∃ pa n bs0, m.load pa n .one = .ok bs0 ∧
        ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
  intro b hb fr hfr
  rcases writeFields_prov hb hfr with hb' | ⟨e, he, hbe⟩
  · rw [List.mem_replicate] at hb'
    rw [hb'.2] at hfr
    simp [AbstractByte.provFrag] at hfr
  · obtain ⟨j, hj, hej⟩ := List.getElem_of_mem he
    have hj2 : j < ebs.length := by simp at hj; omega
    have hee : e.2 = ebs[j] := by rw [← hej]; simp
    rw [hee] at hbe
    have hm := hfm j (by omega) hj2
    cases hsj : srcs[j]'(by omega) with
    | slot a s ws =>
      rw [hsj] at hm
      obtain ⟨pa, bs0, -, hld, hle⟩ := hm
      exact ⟨pa, _, bs0, hld, le_prov hle b hbe fr hfr⟩
    | imm n bits =>
      rw [hsj] at hm
      exfalso
      obtain ⟨k, hk, fr0, hf0, -⟩ := le_prov hm b hbe fr hfr
      rw [encodeBits_noprov n bits _ (List.getElem_mem hk)] at hf0
      cases hf0
    | zst =>
      rw [hsj] at hm
      simp only [FieldMem] at hm
      rw [hm] at hbe
      cases hbe

/-- The common lift: field writes `AggFields` accepts, run by R, simulate any L0 effect
`AggMem` (with the same fields and sources).

Proof: `hmm` gives `pd`, `ebs`, the store `hsto`, the stack. Destination: if `sd.size = 0`,
every field is `.zst` (the others need `0 < n ≤ sd.size`), so `aggPieces` is `[]`, `is = []`
(`piecesOk`), R takes no step (`StepsTo.refl`, `RState` eta), the store is of `[]` bytes
(`Memory.store_eq_ok`: `s'.mem = s.mem`) and `_d`'s `LocalRel` at `true` is its old one (a
`priv` one's bytes are vacuous at size 0). Else `hrel.priv_dst` gives `_d`'s private allocation.
Sources: per field, `srcRel_of_fieldMem` (the live locals from `hla`) with `src := frameByte
s1.st`. R: `sim_pieces` with `lo, hi = sd.off, sd.off + sd.size` (`aggPieces_within`; the
slot private by `hpriv` and `hrel.esc`; the `mov` sources' reads from `srcRel_of_fieldMem`,
the pieces of field `j` being `.mov`s only of `.slot` sources). Bytes:
`pieceFrame_aggPieces` with `acc = List.replicate sd.size .uninit` (`BytesInj.uninit`
pointwise) relates the stored bytes to R's final frame on the slot; `frameLocal_priv` gives
`MemInj` and `_d`'s `LocalRel`; for the other locals `LocalRel.store_other` (`hrel.provNe`) and
`LocalRel.frame_apart` (`hrel.apart`, `pieceFrame_outside`). `hrel.after` with `pc' = s1.pc +
is.length` (escapes unchanged) is the relation. `Hidden`/`ProvBounded`: by `writeFields_prov`
each stored byte with provenance is in some `ebs[j]`, which is a `.slot` field's (the others
are `encodeBits`, provenance-free, or empty), below its loaded `bs0` (`le_prov`), so
`hrel.hidden.load` and `hpb.load` of that load give `Hidden.store_hidden` and
`ProvBounded.store`; `store_size` the allocation count. -/
theorem lift_aggMem {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {ops : List Operand} {fields : List (Nat × Spec.Ty)} {srcs : List AggSrc}
    {sd : LocalSlot} {is : List R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hoff : offOk sd.off ∧ offOk (sd.off + sd.size))
    (hpriv : ∀ j < sd.size, Γ.escaped (sd.off + j) = false)
    (hf : AggFields Γ sd ops fields srcs)
    (hpo : piecesOk Γ is (aggPieces sd.off fields srcs) = true)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hla : ∀ src ∈ srcs, ∀ a so ws, src = .slot a so ws → live a = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmm : AggMem f d sd.size fields srcs s s') :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  obtain ⟨pd, ebs, hpd, hl1, hl2, hfm, hbd, hsto, hstk⟩ := hmm
  have hfl := AggFields.length hf
  have hwithin := aggPieces_within hf hoff
  have hesc' : ∀ o, sd.off ≤ o → o < sd.off + sd.size → s1.st.escapedAt o = none := by
    intro o h1 h2
    cases he : s1.st.escapedAt o with
    | none => rfl
    | some e =>
      exfalso
      have h3 := hrel.esc o e he
      have h4 := hpriv (o - sd.off).toNat (by omega)
      rw [show sd.off + ((o - sd.off).toNat : Int) = o by omega, h3] at h4
      cases h4
  have hsrc1 : ∀ j (h1 : j < srcs.length) (h2 : j < ebs.length),
      SrcRel ι (frameByte s1.st) srcs[j] ebs[j] ∧
        ∀ a s ws, srcs[j] = .slot a s ws →
          ∀ i < ws.sum, s1.st.byteAt (s + i) = .ok (frameByte s1.st (s + i)) := by
    intro j h1 h2
    obtain ⟨op, hfj⟩ := AggFields.get hf j (by omega) h1
    exact srcRel_of_fieldMem hrel hfj (hfm j h1 h2)
      (fun a s ws he => hla _ (List.getElem_mem h1) a s ws he)
  have hsrcs : ∀ p ∈ aggPieces sd.off fields srcs, ∀ d' s'' w, p = .mov d' s'' w →
      ∀ i < w, s1.st.byteAt (s'' + i) = .ok (frameByte s1.st (s'' + i)) := by
    intro p hp d' s'' w he i hi'
    obtain ⟨src, hsm, a, so, ws, rfl, o', rfl, how⟩ :=
      aggPieces_mov_src sd.off fields srcs p hp d' s'' w he
    obtain ⟨j, hj, hjs⟩ := List.getElem_of_mem hsm
    have := (hsrc1 j hj (by omega)).2 a so ws hjs (o' + i) (by omega)
    rw [show so + ((o' + i : Nat) : Int) = so + o' + i by omega] at this
    exact this
  obtain ⟨st', hsteps, hmem, hesc, hfr'⟩ :=
    sim_pieces (ch := ch) (src := frameByte s1.st) hmode hρ hpo hi hsc hpe hpl hwithin hesc' hsrcs
  obtain ⟨hLlen, hLrel⟩ := pieceFrame_aggPieces (ι := ι) (src := frameByte s1.st) (base := sd.off)
    (acc := List.replicate sd.size .uninit) (fr := s1.st.frame) (by omega) hl1
    (fun j h1 h2 => (hsrc1 j h1 h2).1)
    (fun j h1 h2 => by rw [List.length_replicate]; exact hbd j h1 h2)
    (fun k h => by simp only [List.getElem_replicate]; exact True.intro)
  rw [List.length_replicate] at hLlen
  have hbsL : ∀ k (h : k < (writeFields (List.replicate sd.size .uninit)
      ((fields.map (·.1)).zip ebs)).length),
      ByteInj ι (writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs))[k]
        (st'.frame (sd.off + k)) := by
    intro k h
    rw [hfr']
    exact hLrel k h
  have hfro : ∀ o, (o < sd.off ∨ sd.off + sd.size ≤ o) → st'.frame o = s1.st.frame o := by
    intro o ho
    rw [hfr']
    exact pieceFrame_outside hwithin ho
  -- `_d`'s relation after the statement
  obtain ⟨sd', hsd', hrd0⟩ := hrel.frame.locals d pd hpd (by rw [hrel.unaliased]; simp)
  rw [hsd] at hsd'
  obtain rfl := Option.some.inj hsd'
  have hdst : MemInj ι s'.mem st'.mem ∧ LocalRel ι s1.fp st' s'.mem sd pd true := by
    cases hrd0 with
    | priv a x hp hι hx hlive haddr hpaddr hsize hpv _ =>
      exact frameLocal_priv hrel.frame.mem a x hp hι hx hlive haddr hpaddr hsize hpv hLlen hbsL
        hsto hmem hesc
    | esc a x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
      have hz : sd.size = 0 := by
        by_cases hne : sd.size = 0
        · exact hne
        · exfalso
          have h3 := hrel.esc _ _ (hin 0 (by omega))
          rw [hpriv 0 (by omega)] at h3
          cases h3
      have hm' : s'.mem = s.mem := by
        rcases Ryo.Spec.Theorems.Memory.store_eq_ok hsto with ⟨-, -, h⟩ | ⟨_, _, _, hne, _⟩
        · exact h
        · exact absurd (hLlen.trans hz) hne
      have hea : ∀ o, st'.escapedAt o = s1.st.escapedAt o := fun o => by
        unfold OpSem.State.escapedAt; rw [hesc]
      rw [hm']
      exact ⟨by rw [hmem]; exact hrel.frame.mem,
        .esc a x e y hp hι hx hlive haddr hpaddr hsize (fun k hk => (hea _).trans (hin k hk))
          (by rw [hmem]; exact hy) hylive hyaddr hysize⟩
  obtain ⟨hmi, hrd⟩ := hdst
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne hap
    exact (hr.frame_apart hmem hesc hfro hap).store_other hsto (.inl (Ne.symm hne))
  have hprov := aggStored_prov (N := sd.size) (fields := fields) hl1 hfm
  have hhid' : ∀ b ∈ writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs),
      ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hrel.hidden.load hld _ (List.getElem_mem hj) fr0 hf0
  have hbd' : BytesBounded s.mem.allocs.size
      (writeFields (List.replicate sd.size .uninit) ((fields.map (·.1)).zip ebs)) := by
    intro b hb fr hfr
    obtain ⟨pa, n, bs0, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
    rw [← he0]
    exact hpb.load hld _ (List.getElem_mem hj) fr0 hf0
  exact ⟨st', hsteps, hstk,
    hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
    memKept_store hsto fun A hA b hb fr hfr => by
      obtain ⟨pa, n, bs0, hld, j, hj, fr0, hf0, he0⟩ := hprov b hb fr hfr
      rw [← he0]
      exact hA.load hld _ (List.getElem_mem hj) fr0 hf0⟩

/-- `LowerAgg`'s lift: R runs the statement's `is.length` instructions.

Proof: `cases hlow`. `agg`: `agg_mem hs hbody hk htd hlay hsz hf h`, the live sources from
`aggFields_slot_mem hf` and `hlo` (`rvalueLocals (.aggregate k ops)` is
`ops.flatMap operandLocals`), then `lift_aggMem`. `useAny`: `aggUse_mem`, `AggFields.cons hf
.nil` for the one field, `aggPieces_single` to rewrite `hi`'s pieces (`rvalueLocals (.use op)`
is `operandLocals op`), then `lift_aggMem`. -/
theorem lift_agg {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerAgg Γ (.assign ⟨d, []⟩ rv) is)
    (hi : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpe : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | agg hk htd hlay hsz hsd hoff hpriv hf hpo =>
    have hmm := agg_mem hs hbody hk htd hlay hsz hf h
    refine lift_aggMem hmode hρ hsd hoff hpriv hf hpo hi hsc hpe hpl hrel hpb ?_ hlive' hmm
    intro src hsrc a so ws he
    apply hlo
    have := aggFields_slot_mem hf src hsrc a so ws he
    simpa [rvalueLocals] using this
  | useAny htd hsz hsd hoff hpriv hf hpo =>
    have hmm := aggUse_mem hs hbody htd hsz hf h
    have hf' := AggFields.cons hf AggFields.nil
    refine lift_aggMem hmode hρ hsd hoff hpriv hf' (by rw [aggPieces_single]; exact hpo)
      hi hsc hpe hpl hrel hpb ?_ hlive' hmm
    intro src' hsrc a so ws he
    apply hlo
    have := aggFields_slot_mem hf' src' hsrc a so ws he
    simpa [rvalueLocals] using this

end Ryo.Proofs.Lower
