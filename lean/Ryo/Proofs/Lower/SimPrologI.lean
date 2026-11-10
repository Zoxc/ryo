/-
Ryo.Proofs.Lower.SimPrologI — the prologue simulated for `LowerPrologI`
(`Check/Lower/PrologInd.lean`, M5b): `Indirect` inputs, in `SimPrologX.lean`'s shapes.

- `copies_run`: R runs the `load.copy`s to their range's end; each copy's destination holds
  the bytes its pointer slot's pointer loads, when the destinations are pairwise disjoint and
  disjoint from every pointer slot; the rest of the frame, the memory, the exposure and the
  escapes unchanged.
- `ArgRelI`: the L0 side of call entry per input, with the R side of an `Indirect` one
  (`IndRel`): register inputs as `ArgRelX`; an `Indirect` input's L0 allocation private, live,
  at the slot, of the slot's size, as `ArgRelX`'s, and, when not empty, its pointer register's
  8 bytes decoding to a pointer `q` into a live allocation of R's memory containing the
  `size` bytes at `q`, whose bytes the L0 bytes refine (`BytesInj`). This is what the caller
  provides (M5c: the caller copies the argument into a temporary of its own, passes its
  address, and the temporary's bytes refine the argument value's encoding, which L0's
  `createFrame` stores in the fresh allocation).
- `prologI_sim`, `match_entryI`, `fn_soundI`: `prologX_sim`, `match_entryX`, `fn_soundX`
  (`SimPrologX.lean`) for `LowerPrologI`: the `arg`s by `writes_run`, then the copies by
  `copies_run`; the copies' destinations are disjoint from every `arg`'s range, so the register
  bytes survive them. `hqs`: every input has its L0 storage (`qs` as long as the inputs; the
  `Indirect` inputs' copies run whatever L0 does).

No escape relation is needed: an `Indirect` input is copied into a private local, and the
caller's memory it is copied from is only read.
-/
import Ryo.Proofs.Lower.SimPrologX
import Ryo.Proofs.Lower.FnSimX
import Ryo.Proofs.Lower.CopyOps
import Ryo.Check.Lower.PrologInd

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

theorem argsAre_length : ∀ {is : List Insn} {ws : List ArgWrite}, ArgsAre is ws →
    is.length = ws.length
  | _, _, .nil => rfl
  | _, _, .cons _ h => by simp only [List.length_cons, argsAre_length h]

/-- Running the copies: see the module comment.

Proof: by induction on `CopiesAre`. The head: its pointer slot holds `pb`
(`readFrame_noesc`), `opSem_loadCopy_fwd` with `writeFrame_noesc`'s write and `step_of_view`;
the write changes only the head's destination, which misses every later pointer slot (`hdp`)
and every later destination (`hdd`), and keeps memory and exposure (so the later loads,
`load_congr`). The head's destination bytes are the loaded ones; the later writes miss them. -/
theorem copies_run {c : Code} {ch : OpSem.Choice} (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i) :
    ∀ {is : List Insn} {cs : List CopyIn}, CopiesAre c.mode c.ρ is cs →
    ∀ (s : RState),
    (∀ (j : Nat) (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧ c.scopesAt (s.pc + j) = []) →
    (∀ o, s.st.escapedAt o = none) →
    cs.Pairwise (fun a b => RngDisj a.rng b.rng) →
    (∀ a ∈ cs, ∀ b ∈ cs, RngDisj a.rng (b.ptr, 8)) →
    (∀ cp ∈ cs, ∃ pb q bs, pb.length = 8 ∧
      (∀ (j : Nat) (hj : j < pb.length), s.st.frame (cp.ptr + j) = pb[j]) ∧
      decodePtr pb = some q ∧ s.st.load (q.wrappingOffset 0) cp.size = .ok bs) →
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      s'.st.mem = s.st.mem ∧ s'.st.exposed = s.st.exposed ∧ (∀ o, s'.st.escapedAt o = none) ∧
      (∀ o, (∀ cp ∈ cs, ¬ (cp.dst ≤ o ∧ o < cp.dst + cp.size)) → s'.st.frame o = s.st.frame o) ∧
      (∀ cp ∈ cs, ∀ pb q bs, pb.length = 8 →
        (∀ (j : Nat) (hj : j < pb.length), s.st.frame (cp.ptr + j) = pb[j]) →
        decodePtr pb = some q → s.st.load (q.wrappingOffset 0) cp.size = .ok bs →
        ∀ (j : Nat) (hj : j < bs.length), s'.st.frame (cp.dst + j) = bs[j]) ∧
      s'.st.escaped = s.st.escaped
  | _, _, .nil, s, _, hn, _, _, _ =>
    ⟨s, .refl s, by simp, rfl, rfl, rfl, rfl, hn, fun _ _ => rfl, fun cp hcp => by simp at hcp,
      rfl⟩
  | _, _, .cons (i := i) (is := is) (cp := cp) (cs := cs) hok hrest, s, hcode, hn, hdd, hdp,
      hld => by
    obtain ⟨v, ps, r, hv, hh, ho, hops, hctl, hd1, hp1, hn32⟩ := loadCopyOk_spec hok
    obtain ⟨pb, q, bs, hpl8, hpb, hq, hl⟩ := hld cp (List.mem_cons_self ..)
    have hrp : s.st.readFrame cp.ptr 8 = .ok pb := by
      have := readFrame_noesc hn hpb
      rw [hpl8] at this
      exact this
    have hlen : bs.length = cp.size := stLoad_length hl
    obtain ⟨st', hw, hm1, hx1, he1, hfr1⟩ := writeFrame_noesc (off := cp.dst) (bs := bs) hn
    have hf1 := offOk_spec hd1
    have hf2 := offOk_spec hp1
    have hop := opSem_loadCopy_fwd (ch := ch) hh ho ⟨hf1.1, hf1.2, hf2.1, hf2.2, hn32⟩ hrp hq hl
      hlen hw
    have h0 := hcode 0 (by simp)
    simp only [Nat.add_zero, List.getElem_cons_zero] at h0
    have hstep := step_of_view (ch := ch) h0.1 h0.2 hpe (hpl _ _ h0.1) hv hctl
      (by rw [hops]; exact hop)
    let s1 : RState := { s with pc := s.pc + 1, st := st' }
    have hn1 : ∀ o, s1.st.escapedAt o = none := fun o => by
      show st'.escapedAt o = none
      rw [escapedAt_of_escaped he1]
      exact hn o
    have hcode1 : ∀ (j : Nat) (hj : j < is.length),
        c.d.insns[s1.pc + j]? = some is[j] ∧ c.scopesAt (s1.pc + j) = [] := by
      intro j hj
      have := hcode (j + 1) (by simp; omega)
      have e : s1.pc + j = s.pc + (j + 1) := by show s.pc + 1 + j = _; omega
      rw [e]
      simpa using this
    have hout1 : ∀ o, ¬ (cp.dst ≤ o ∧ o < cp.dst + cp.size) → st'.frame o = s.st.frame o := by
      intro o ho
      have hc : ¬ (cp.dst ≤ o ∧ o < cp.dst + (bs.length : Int)) := by rw [hlen]; exact ho
      rw [hfr1 o, if_neg hc]
    have hin1 : ∀ (j : Nat) (hj : j < bs.length), st'.frame (cp.dst + j) = bs[j] := by
      intro j hj
      have hc : cp.dst ≤ cp.dst + (j : Int) ∧ cp.dst + (j : Int) < cp.dst + (bs.length : Int) := by
        omega
      rw [hfr1, if_pos hc]
      have e : (cp.dst + (j : Int) - cp.dst).toNat = j := by omega
      rw [e, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hj, Option.getD_some]
    have hld1 : ∀ b ∈ cs, ∃ pb q bs, pb.length = 8 ∧
        (∀ (j : Nat) (hj : j < pb.length), s1.st.frame (b.ptr + j) = pb[j]) ∧
        decodePtr pb = some q ∧ s1.st.load (q.wrappingOffset 0) b.size = .ok bs := by
      intro b hb
      obtain ⟨pb', q', bs', h1, h2, h3, h4⟩ := hld b (List.mem_cons_of_mem _ hb)
      refine ⟨pb', q', bs', h1, fun j hj => ?_, h3, ?_⟩
      · show st'.frame (b.ptr + j) = pb'[j]
        have hd := hdp cp (List.mem_cons_self ..) b (List.mem_cons_of_mem _ hb)
        have hd' : cp.dst + (cp.size : Int) ≤ b.ptr ∨ b.ptr + ((8 : Nat) : Int) ≤ cp.dst := hd
        rw [hout1 (b.ptr + j) (by omega)]
        exact h2 j hj
      · show st'.load _ _ = _
        rw [load_congr hm1 hx1]
        exact h4
    obtain ⟨s', hst, hpc, hfp, hargs, hmem, hexp, hesc, hout, hin, hescl⟩ :=
      copies_run hpe hpl hrest s1 hcode1 hn1 (List.pairwise_cons.mp hdd).2
        (fun a ha b hb => hdp a (List.mem_cons_of_mem _ ha) b (List.mem_cons_of_mem _ hb)) hld1
    refine ⟨s', .cons hstep hst, ?_, hfp, hargs, hmem.trans hm1, hexp.trans hx1, hesc, ?_, ?_,
      hescl.trans he1⟩
    · rw [hpc]
      show s.pc + 1 + is.length = s.pc + (i :: is).length
      simp only [List.length_cons]
      omega
    · intro o ho
      rw [hout o (fun b hb => ho b (List.mem_cons_of_mem _ hb))]
      exact hout1 o (ho cp (List.mem_cons_self ..))
    · intro b hb pb' q' bs' h1 h2 h3 h4 j hj
      rcases List.mem_cons.mp hb with he | hb'
      · -- the head: its destination isn't written later
        rw [he] at h2 h4 ⊢
        have epb : pb' = pb := List.ext_getElem (h1.trans hpl8.symm)
          (fun k hk1 hk2 => (h2 k hk1).symm.trans (hpb k hk2))
        rw [epb, hq] at h3
        have eq := Option.some.inj h3
        rw [← eq, hl] at h4
        have eb := Except.ok.inj h4
        subst eb
        have hno : ∀ b ∈ cs, ¬ (b.dst ≤ cp.dst + j ∧ cp.dst + j < b.dst + b.size) := by
          intro b hb hc
          have hd := (List.pairwise_cons.mp hdd).1 b hb
          have hd' : cp.dst + (cp.size : Int) ≤ b.dst ∨ b.dst + (b.size : Int) ≤ cp.dst := hd
          omega
        rw [hout _ hno]
        exact hin1 j hj
      · refine hin b hb' pb' q' bs' h1 (fun k hk => ?_) h3 ?_ j hj
        · show st'.frame (b.ptr + k) = pb'[k]
          have hd := hdp cp (List.mem_cons_self ..) b hb
          have hd' : cp.dst + (cp.size : Int) ≤ b.ptr ∨ b.ptr + ((8 : Nat) : Int) ≤ cp.dst := hd
          rw [hout1 (b.ptr + k) (by omega)]
          exact h2 k hk
        · show st'.load _ _ = _
          rw [load_congr hm1 hx1]
          exact h4

/-! ### The relation at entry -/

/-- The R side of an `Indirect` input with L0 allocation `x` (see the module comment). -/
def IndRel (ι : Inj) (m1 : Memory) (args : Regs) (idx : Nat) (x : Allocation) : Prop :=
  x.data.size ≠ 0 → ∃ q id y bs, (regBytes args (ptrArg idx)).length = 8 ∧
    decodePtr (regBytes args (ptrArg idx)) = some q ∧ q.prov = some id ∧ m1.get? id = some y ∧
    y.live = true ∧ y.addr ≤ q.addr ∧ q.addr + x.data.size ≤ y.addr + y.size ∧
    m1.load q x.data.size Align.one = .ok bs ∧ BytesInj ι x.data.toList bs

/-- The L0 side of call entry for input `inp` with storage `ptr`, and an `Indirect` input's R
side in R's memory `m1` (see the module comment). -/
def ArgRelI (ι : Inj) (fp : Nat) (m0 m1 : Memory) (args : Regs) (inp : InputI)
    (ptr : ThinPointer) : Prop :=
  match inp.kind with
  | .regs ps => ArgRelX ι fp m0 args ⟨inp.slot, ps⟩ ptr
  | .ind _ idx => ∃ al x, ptr.prov = some al ∧ ι al = none ∧ m0.get? al = some x ∧
      x.live = true ∧ (x.addr : Int) = fp + inp.slot.off ∧ ptr.addr = x.addr ∧
      x.data.size = inp.slot.size ∧ IndRel ι m1 args idx x

theorem inputsOkI_get {Γp : PrologICtx} : ∀ {k : Nat} {inps : List InputI},
    InputsOkI Γp k inps → ∀ j (h : j < inps.length), InputOkI Γp (k + j) inps[j]
  | _, _, .nil _, j, h => by simp at h
  | _, _, .cons (k := k) (inp := inp) (inps := inps) hok hrest, j, h => by
    cases j with
    | zero => first | exact hok | simpa using hok
    | succ j =>
      have h' : j < inps.length := by simp at h; omega
      have := inputsOkI_get hrest j h'
      have e : k + (j + 1) = k + 1 + j := by omega
      rw [e]
      first | exact this | simpa using this

/-- Input `j`'s home is local `k + j + 1`'s slot. -/
theorem inputsOkI_slot {Γp : PrologICtx} {k : Nat} {inps : List InputI}
    (h : InputsOkI Γp k inps) (j : Nat) (hj : j < inps.length) :
    Γp.slots[k + j + 1]? = some inps[j].slot :=
  (inputsOkI_get h j hj).slot_eq

theorem copyIn_mem {inps : List InputI} {cp : CopyIn} (h : cp ∈ allCopies inps) :
    ∃ inp ∈ inps, ∃ idx, inp.kind = .ind cp.ptr idx ∧ inp.slot.off = cp.dst ∧
      inp.slot.size = cp.size ∧ inp.slot.size ≠ 0 := by
  simp only [allCopies, List.mem_flatMap] at h
  obtain ⟨⟨slot, kind⟩, hinp, hc⟩ := h
  cases kind with
  | regs ps => simp [InputI.copies] at hc
  | ind ptr idx =>
    by_cases hz : slot.size = 0
    · simp [InputI.copies, hz] at hc
    · simp only [InputI.copies, hz, ↓reduceIte, List.mem_singleton] at hc
      subst hc
      exact ⟨_, hinp, idx, rfl, rfl, rfl, hz⟩

theorem copy_of_mem {inps : List InputI} {inp : InputI} (h : inp ∈ inps) {ptr : Int}
    {idx : Nat} (hk : inp.kind = .ind ptr idx) (hz : inp.slot.size ≠ 0) :
    (⟨inp.slot.off, ptr, inp.slot.size⟩ : CopyIn) ∈ allCopies inps := by
  simp only [allCopies, List.mem_flatMap]
  refine ⟨inp, h, ?_⟩
  simp [InputI.copies, hk, hz]

theorem write_of_input {Γp : PrologICtx} {inps : List InputI} {lw : List ArgWrite}
    {inp : InputI} (h : inp ∈ inps) {w : ArgWrite} (hw : w ∈ inp.writes) :
    w ∈ allWritesI Γp inps lw := by
  simp only [allWritesI, List.mem_append, List.mem_flatMap]
  first
    | exact Or.inl (Or.inr ⟨inp, h, hw⟩)
    | exact Or.inr (Or.inl ⟨inp, h, hw⟩)

/-- An `Indirect` input's load at a state with the entry's memory. -/
theorem ind_load {st : OpSem.State} {m1 : Memory} (hm : st.mem = m1) {q : ThinPointer}
    {id : AllocId} {y : Allocation} {n : Nat} {bs : List AbstractByte} {pb : List AbstractByte}
    (hpbl : pb.length = 8) (hq : decodePtr pb = some q) (hqp : q.prov = some id)
    (hy : m1.get? id = some y) (hyl : y.live = true) (hy1 : y.addr ≤ q.addr)
    (hy2 : q.addr + n ≤ y.addr + y.size) (hld : m1.load q n Align.one = .ok bs) :
    st.load (q.wrappingOffset 0) n = .ok bs := by
  rw [wrappingOffset_zero (decodePtr_addr_lt hq hpbl),
    load_of_fits (st := st) hqp (fits_of (st := st) (by rw [hm]; exact hy) hyl hy1 hy2), hm, hld]
  all_goals first | rfl | exact liftOutcome_pure _

/-! ### The prologue -/

/-- The prologue simulated: see the module comment.

Proof: split `is` at the `arg`s' count (`argsAre_length`); `writes_run` for the `arg`s
(pairwise disjoint: `hl.disj`'s first part, `List.pairwise_map`), then `copies_run` for the
copies: each copy's pointer slot holds its register's bytes (`writes_run`'s last conjunct)
and the pointer loads the caller's bytes (`IndRel`, `ind_load`; the memory is the entry's).
Each input's `LocalRel.priv`: register pieces as `prologX_sim`, their bytes kept by the
copies (`hkeep`: the copies' destinations miss every `arg`'s range); an `Indirect` input's
bytes are its copy's (`copies_run`'s last conjunct), refined by `IndRel`'s `BytesInj`. -/
theorem prologI_sim {Γp : PrologICtx} {c : Code} {ch : OpSem.Choice} {is : List Insn}
    {inps : List InputI} {lw : List ArgWrite} (hl : LowerPrologI Γp is inps lw)
    (hmo : Γp.mode = c.mode) (hρ : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {ι : Inj} {fp : Nat} {m0 : Memory} {s : RState}
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧
      c.scopesAt (s.pc + j) = [])
    (hnoesc : ∀ o, s.st.escapedAt o = none)
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelI ι fp m0 s.st.mem s.args inps[j] qs[j])
    (hmem : MemInj ι m0 s.st.mem) :
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      MemInj ι m0 s'.st.mem ∧ (∀ o, s'.st.escapedAt o = none) ∧
      (∀ j (h1 : j < inps.length) (h2 : j < qs.length),
        LocalRel ι fp s'.st m0 inps[j].slot qs[j] true) ∧
      (∀ w ∈ sretWrites Γp.toPrologXCtx ++ lw, ∀ (j : Nat) (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j]) ∧ s'.st.mem = s.st.mem ∧
      s'.st.escaped = s.st.escaped := by
  -- the ranges
  have hd0 : ((allWritesI Γp inps lw).map ArgWrite.rng ++
      (allCopies inps).map CopyIn.rng).Pairwise RngDisj := hl.disj
  obtain ⟨hdW, hdC, hdWC⟩ := List.pairwise_append.mp hd0
  have hwd : (allWritesI Γp inps lw).Pairwise WriteDisj :=
    (List.pairwise_map.mp hdW).imp fun h => h
  have hcd : (allCopies inps).Pairwise (fun a b => RngDisj a.rng b.rng) :=
    List.pairwise_map.mp hdC
  have hwc : ∀ w ∈ allWritesI Γp inps lw, ∀ cp ∈ allCopies inps, RngDisj w.rng cp.rng :=
    fun w hw cp hcp => hdWC _ (List.mem_map_of_mem hw) _ (List.mem_map_of_mem hcp)
  -- the `arg`s
  obtain ⟨n, hn⟩ : ∃ n, (allWritesI Γp inps lw).length = n := ⟨_, rfl⟩
  have hA : ArgsAre (is.take n) (allWritesI Γp inps lw) := by rw [← hn]; exact hl.args
  have hC : CopiesAre c.mode c.ρ (is.drop n) (allCopies inps) := by
    rw [← hn, ← hmo, ← hρ]; exact hl.copies
  have hlenA : (is.take n).length = n := by rw [argsAre_length hA, hn]
  have hle : n ≤ is.length := by rw [List.length_take] at hlenA; omega
  have hcodeA : ∀ (j : Nat) (hj : j < (is.take n).length),
      c.d.insns[s.pc + j]? = some (is.take n)[j] ∧ c.scopesAt (s.pc + j) = [] := by
    intro j hj
    have hj' : j < is.length := by rw [hlenA] at hj; omega
    obtain ⟨h1, h2⟩ := hcode j hj'
    refine ⟨?_, h2⟩
    rw [h1]
    simp
  obtain ⟨sA, hstA, hpcA, hfpA, hargsA, hmemA, hesclA, hescA, -, hinA⟩ :=
    writes_run_esc (ch := ch) hA s hcodeA (fun _ _ _ _ => hnoesc _)
  have hinA' := hinA hwd
  have hnA : ∀ o, sA.st.escapedAt o = none := fun o => by rw [hescA]; exact hnoesc o
  -- the copies
  have hcodeC : ∀ (j : Nat) (hj : j < (is.drop n).length),
      c.d.insns[sA.pc + j]? = some (is.drop n)[j] ∧ c.scopesAt (sA.pc + j) = [] := by
    intro j hj
    have hj' : n + j < is.length := by simp at hj; omega
    obtain ⟨h1, h2⟩ := hcode (n + j) hj'
    have e : sA.pc + j = s.pc + (n + j) := by rw [hpcA, hlenA]; omega
    rw [e]
    refine ⟨?_, h2⟩
    rw [h1]
    simp
  have hldC : ∀ cp ∈ allCopies inps, ∃ pb q bs, pb.length = 8 ∧
      (∀ (j : Nat) (hj : j < pb.length), sA.st.frame (cp.ptr + j) = pb[j]) ∧
      decodePtr pb = some q ∧ sA.st.load (q.wrappingOffset 0) cp.size = .ok bs := by
    intro cp hcp
    obtain ⟨inp, hinp, idx, hk, -, hsz, hz⟩ := copyIn_mem hcp
    obtain ⟨j, hj, rfl⟩ := List.getElem_of_mem hinp
    have hr := hrel j hj (by omega)
    simp only [ArgRelI, hk] at hr
    obtain ⟨al, x, -, -, -, -, -, -, hxs, hind⟩ := hr
    obtain ⟨q, id, y, bs, hpbl, hq, hqp, hy, hyl, hy1, hy2, hld, -⟩ :=
      hind (by rw [hxs]; exact hz)
    have hcs : cp.size = x.data.size := by rw [hxs, hsz]
    refine ⟨regBytes s.args (ptrArg idx), q, bs, hpbl, fun k hk' => ?_, hq, ?_⟩
    · have hw : (cp.ptr, ptrArg idx) ∈ allWritesI Γp inps lw :=
        write_of_input (List.getElem_mem hj) (by simp [InputI.writes, hk])
      exact hinA' _ hw k hk'
    · rw [hcs]
      exact ind_load hmemA hpbl hq hqp hy hyl hy1 hy2 hld
  have hdp : ∀ a ∈ allCopies inps, ∀ b ∈ allCopies inps, RngDisj a.rng (b.ptr, 8) := by
    intro a ha b hb
    obtain ⟨inp, hinp, idx, hk, -, -, -⟩ := copyIn_mem hb
    have hw : (b.ptr, ptrArg idx) ∈ allWritesI Γp inps lw :=
      write_of_input hinp (by simp [InputI.writes, hk])
    have hd := hwc _ hw a ha
    have hd' : b.ptr + ((ptrArg idx).size : Int) ≤ a.dst ∨ a.dst + (a.size : Int) ≤ b.ptr := hd
    have h8 : (ptrArg idx).size = 8 := rfl
    rw [h8] at hd'
    show a.dst + (a.size : Int) ≤ b.ptr ∨ b.ptr + ((8 : Nat) : Int) ≤ a.dst
    omega
  obtain ⟨sC, hstC, hpcC, hfpC, hargsC, hmemC, -, hescC, houtC, hinC, hesclC⟩ :=
    copies_run (ch := ch) hpe hpl hC sA hcodeC hnA hcd hdp hldC
  -- the `arg`s' bytes survive the copies
  have hkeep : ∀ w ∈ allWritesI Γp inps lw, ∀ j < w.2.size,
      sC.st.frame (w.1 + j) = sA.st.frame (w.1 + j) := by
    intro w hw j hj
    apply houtC
    intro cp hcp hc
    have hd := hwc w hw cp hcp
    have hd' : w.1 + (w.2.size : Int) ≤ cp.dst ∨ cp.dst + (cp.size : Int) ≤ w.1 := hd
    omega
  refine ⟨sC, hstA.trans hstC, ?_, hfpC.trans hfpA, hargsC.trans hargsA, ?_, hescC, ?_, ?_,
    hmemC.trans hmemA, hesclC.trans hesclA⟩
  · rw [hpcC, hpcA, hlenA]
    simp only [List.length_drop]
    omega
  · rw [hmemC, hmemA]; exact hmem
  · intro j h1 h2
    have hr := hrel j h1 h2
    have hmemj : inps[j] ∈ inps := List.getElem_mem h1
    cases hkind : inps[j].kind with
    | regs ps =>
      simp only [ArgRelI, hkind] at hr
      obtain ⟨al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hb⟩ := hr
      refine .priv al x hp hι hx hlive haddr hpaddr hsize (fun k _ => hescC _) ?_
      intro _ k hk
      rcases hb k hk with hu | ⟨p, hp', hle, b, hbk, hbi⟩
      · rw [hu]; trivial
      · obtain ⟨hkl, hbe⟩ := List.getElem?_eq_some_iff.mp hbk
        have hwm : (inps[j].slot.off + p.1, p.2) ∈ allWritesI Γp inps lw :=
          write_of_input hmemj (by
            simp only [InputI.writes, hkind]
            exact List.mem_map_of_mem hp')
        have hfk := hinA' _ hwm (k - p.1) hkl
        have hkp := hkeep _ hwm (k - p.1) (by
          show k - p.1 < p.2.size
          have := regBytes_length_le s.args p.2
          omega)
        dsimp only at hfk hkp
        have e : inps[j].slot.off + (k : Int) =
            inps[j].slot.off + (p.1 : Int) + ((k - p.1 : Nat) : Int) := by omega
        rw [e, hkp, hfk, hbe]
        exact hbi
    | ind ptr idx =>
      simp only [ArgRelI, hkind] at hr
      obtain ⟨al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hind⟩ := hr
      refine .priv al x hp hι hx hlive haddr hpaddr hsize (fun k _ => hescC _) ?_
      intro _ k hk
      have hz : inps[j].slot.size ≠ 0 := by omega
      obtain ⟨q, id, y, bs, hpbl, hq, hqp, hy, hyl, hy1, hy2, hld, hbi⟩ := hind (by omega)
      have hcp := copy_of_mem hmemj hkind hz
      have hw : (ptr, ptrArg idx) ∈ allWritesI Γp inps lw :=
        write_of_input hmemj (by simp [InputI.writes, hkind])
      have hl' : sA.st.load (q.wrappingOffset 0) inps[j].slot.size = .ok bs := by
        rw [← hsize]
        exact ind_load hmemA hpbl hq hqp hy hyl hy1 hy2 hld
      have hbl : bs.length = x.data.size := load_length hld
      have hc := hinC _ hcp (regBytes s.args (ptrArg idx)) q bs hpbl
        (fun k' hk' => hinA' _ hw k' hk') hq hl' k (by omega)
      have hc' : sC.st.frame (inps[j].slot.off + k) = bs[k]'(by omega) := hc
      rw [hc']
      have := BytesInj.getElem' hbi k (by simpa using hk) (by omega)
      simpa using this
  · intro w hw j hj
    have hw' : w ∈ allWritesI Γp inps lw := by
      simp only [allWritesI, List.mem_append] at hw ⊢
      rcases hw with h | h <;> simp [h]
    rw [hkeep w hw' j (by have := regBytes_length_le s.args w.2; omega)]
    exact hinA' w hw' j hj

/-- `match_entryX` for `LowerPrologI` (see the module comment).

Proof: `match_entryX`'s, with `prologI_sim` in place of `prologX_sim` and `inputsOkI_slot` in
place of `inputsOk_slot`. -/
theorem match_entryI {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {Γp : PrologICtx} {is : List Insn} {inps : List InputI} {lw : List ArgWrite}
    (hpl : LowerPrologI Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hmo : Γp.mode = c.mode) (hρp : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    -- R at the prologue
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hreach : reachGet (computeReach Γ.body) 0 = true)
    (hfz : blk.fused = true → 0 < bd.stmts.length)
    -- L0's entry frame (`callBody`)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem) :
    ∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s s1' ∧
      (∀ w ∈ sretWrites Γp.toPrologXCtx ++ lw, ∀ (j : Nat) (hj : j < (regBytes s1.args w.2).length),
        s1'.st.frame (w.1 + j) = (regBytes s1.args w.2)[j]) ∧
      s1'.args = s1.args ∧ (∀ o, s1'.st.escapedAt o = none) ∧ s1'.st.mem = s1.st.mem := by
  obtain ⟨s', hst, hpc, hfp, hargs, hmem', hesc, hlr0, hw, hmeq, -⟩ :=
    prologI_sim (ch := ch) hpl hmo hρp hpe hplain hcode hnoesc qs hqs hrel hmem
  have hlr : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem inps[j].slot qs[j] true := by
    rw [hfp]; exact hlr0
  refine ⟨s', hst, Or.inl ⟨f, rest, blk, bd, ?_, by rw [hbb]; exact hreach,
    fun h => by rw [hstmt]; exact hfz h⟩, hw, hargs, hesc, hmeq⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, rel := ?_, sl := ?_, pb := hpb, fresh := hfresh, dinv := hdinv }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · refine ⟨⟨?_, ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · exact hmem'
    · intro l p hp _
      obtain ⟨j, h1, h2, rfl, rfl⟩ := hloc l p hp
      refine ⟨inps[j].slot, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
      have := inputsOkI_slot hpl.inputs j h1
      rw [hslots] at this
      simpa using this
    · intro o e he
      rw [hesc] at he
      cases he
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-- `fn_soundX` with `LowerPrologI`'s entry (`match_entryI`): the function theorem from entry
for every prologue `prologIVerdict` accepts. Beyond `fn_soundX`'s: the prologue's context has
the function's mode and placement (`hpm`, `hpρ`), every input has its L0 storage (`hqs`), and
`hrel` is `ArgRelI` (an `Indirect` input's bytes in R's memory, the caller's side, M5c). -/
theorem fn_soundI {Γ : TermCtx} {c : Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologICtx} {is : List Insn} {inps : List InputI} {lw : List ArgWrite}
    (hpl : LowerPrologI Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧
          RetValX Γ ι v regs) ∨
      FnStop Γ c ch ι o s s' s1 := by
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s0, hst0, hm0, -, -, -, -⟩ := match_entryI (ch := ch) hpl hslots (hpm.trans hmode.symm)
    (hpρ.trans hρ.symm) hpe hplain hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hqs hloc hrel hmem hhid hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | hstop
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr (hstop.pre hst0))

/-! ### Functions with scopes -/

/-- `match_entryEsc` (`FnSimX.lean`) for `LowerPrologI`: the prologue by `prologI_sim`, which
keeps the (empty) list of escaped objects. -/
theorem match_entryEscI {Γ : TermCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {Γp : PrologICtx} {is : List R.Insn} {inps : List InputI} {lw : List ArgWrite}
    (hpl : LowerPrologI Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoobj : s1.st.escaped = [])
    (hfree : ∀ id y, s1.st.mem.get? id = some y → y.live = true →
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        (y.addr : Int) + y.data.size ≤ s1.fp + sl.off ∨ s1.fp + sl.off + sl.size ≤ y.addr)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    (haligned : ∀ (l : Local) (p : ThinPointer) (ty : Spec.Ty), f.locals[l]? = some (some p) →
      f.body.locals[l]? = some ty → p.addr % ty.align.bytes = 0) :
    ∃ s1', StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι s s1' ∧
      (∀ w ∈ sretWrites Γp.toPrologXCtx ++ lw, ∀ (j : Nat) (hj : j < (regBytes s1.args w.2).length),
        s1'.st.frame (w.1 + j) = (regBytes s1.args w.2)[j]) ∧
      s1'.args = s1.args ∧ s1'.st.mem = s1.st.mem ∧ s1'.st.escaped = [] := by
  have hnoesc : ∀ o, s1.st.escapedAt o = none := fun o => by
    unfold OpSem.State.escapedAt
    rw [hnoobj]
    rfl
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s', hst, hpc, hfp, hargs, hmi, hescAt, hlr0, hw, hmeq, hesc'⟩ :=
    prologI_sim (ch := ch) hpl (hpm.trans hmode.symm) (hpρ.trans hρ.symm) hpe hplain hcode
      hnoesc qs hqs hrel hmem
  have hnoobj' : s'.st.escaped = [] := by rw [hesc', hnoobj]
  have hlr : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem inps[j].slot qs[j] true := by
    rw [hfp]; exact hlr0
  have hfnrel : FnRel Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s' := by
    refine ⟨⟨hmi, ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · intro l p hp _
      obtain ⟨j, h1, h2, rfl, rfl⟩ := hloc l p hp
      refine ⟨inps[j].slot, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
      have := inputsOkI_slot hpl.inputs j h1
      rw [hslots] at this
      simpa using this
    · intro o e he
      rw [hescAt] at he
      cases he
  have hX : FnRelX Γ.toStmtCtx ι ((computeLive Γ.body).get f.bb f.stmt) f s.mem s' := by
    refine ⟨hfnrel, fun e he => ?_, ?_, fun a b x e _ _ _ he _ => ?_, fun id y hy hl => ?_,
      haligned, fun e he => ?_, fun e he _ _ => ?_⟩
    · rw [hnoobj'] at he; simp at he
    · rw [hnoobj']; exact List.Pairwise.nil
    · rw [hnoobj'] at he; simp at he
    · refine .inr fun l sl hsl => ?_
      rw [hmeq] at hy
      rw [hfp]
      exact hfree id y hy hl l sl hsl
    · rw [hnoobj'] at he; simp at he
    · rw [hnoobj'] at he; simp at he
  refine ⟨s', hst, ⟨s', f, rest, blk, bd, ?_, by rw [hbb]; exact hfn.reach.entry⟩, hw, hargs,
    hmeq, hnoobj'⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, pend := ?_, rel := hX, sl := ?_, pb := hpb, fresh := hfresh,
           dinv := hdinv }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · rw [hstmt, pendSpecs_zero]
    all_goals first | rfl | simp [pure, Except.pure]
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-- `fn_soundEsc` (`FnSimX.lean`) with `LowerPrologI`'s entry (`match_entryEscI`): functions
with scopes and `Indirect` inputs. Beyond `fn_soundEsc`'s hypotheses: `fn_soundI`'s `hpm`,
`hpρ`, `hqs` and `ArgRelI`. -/
theorem fn_soundEscI {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ ι s s1, MatchEsc Γ c ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologICtx} {is : List R.Insn} {inps : List InputI} {lw : List ArgWrite}
    (hpl : LowerPrologI Γp is inps lw) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ)
    {s : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoobj : s1.st.escaped = [])
    (hfree : ∀ id y, s1.st.mem.get? id = some y → y.live = true →
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        (y.addr : Int) + y.data.size ≤ s1.fp + sl.off ∨ s1.fp + sl.off + sl.size ≤ y.addr)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : inps.length = qs.length)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      ∃ j, ∃ (h1 : j < inps.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j])
    (hrel : ∀ j (h1 : j < inps.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args inps[j] qs[j])
    (hmem : MemInj ι s.mem s1.st.mem)
    (hhid : Hidden s.mem (PrivAlloc ι f))
    (hprov : ∀ (l l' : Local) (p p' : ThinPointer), l ≠ l' → f.locals[l]? = some (some p) →
      f.locals[l']? = some (some p') → p.prov ≠ p'.prov)
    (hapart : ∀ (l l' : Local) (p p' : ThinPointer) (sl sl' : LocalSlot), l ≠ l' →
      f.locals[l]? = some (some p) → f.locals[l']? = some (some p') → Γ.slots[l]? = some sl →
      Γ.slots[l']? = some sl' → SlotsApart sl sl')
    (hsl : ∀ l p, f.locals[l]? = some (some p) → (computeStorage Γ.body).get 0 0 l = true)
    (hpb : ProvBounded s.mem) (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none)
    (hdinv : DerefInv ι s.mem)
    (haligned : ∀ (l : Local) (p : ThinPointer) (ty : Spec.Ty), f.locals[l]? = some (some p) →
      f.body.locals[l]? = some ty → p.addr % ty.align.bytes = 0)
    (hre : ReusesAt o) (hpool : PoolInv Γ.poolAt c.ρ ι s)
    (hfre : FnReusesAt o) (hsk : SymsKept c ch)
    (hfinv : FnInv Γ.fnSymAt c.ρ ι s s1.st)
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ MatchEscR Γ c ι' s' s1') ∨
      (∃ ι' s1' s0 v regs incoming, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧
        s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s0 (.ret regs incoming))) ∧ RetValX Γ ι' v regs) ∨
      (∃ s1', StepsTo c ch s1 s1' ∧ DeadAt Γ s') ∨
      (∃ ι' s1', ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ UnwindsX c ch ι' s' s1') ∨
      (∃ ι' s1' sa sb m, ι.Le ι' ∧ StepsTo c ch s1 s1' ∧ L0Steps o m s sa ∧
        StoppedX Γ c ch ι' o sa sb s1') := by
  obtain ⟨s0, hst0, hm0, -, -, -, -⟩ := match_entryEscI (ch := ch) hfn hmode hρ hpl hslots hpm hpρ
    hcode
    hnoobj hfree hblk hbd hstart hs hbody hbb hstmt hpu hcont hal qs hqs hloc hrel hmem hhid
    hprov hapart hsl hpb hfresh hdinv haligned
  rcases fn_simX hfn hmode hρ hinc hpick hre hfre hsk hm0 hpool
      (hfinv.of_steps hsk hst0) hrun with
    ⟨ι', s1', hle, hst, hm⟩ | ⟨ι', s1', s0', v, regs, incoming, hle, hst, hf, hr, hv⟩ |
    ⟨s1', hst, hd⟩ | ⟨ι', s1', hle, hst, hu⟩ | ⟨ι', s1', sa, sb, m, hle, hst, hsa, hsx⟩
  · exact .inl ⟨ι', s1', hle, hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨ι', s1', s0', v, regs, incoming, hle, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr (.inl ⟨s1', hst0.trans hst, hd⟩))
  · exact .inr (.inr (.inr (.inl ⟨ι', s1', hle, hst0.trans hst, hu⟩)))
  · exact .inr (.inr (.inr (.inr ⟨ι', s1', sa, sb, m, hle, hst0.trans hst, hsa, hsx⟩)))

end Ryo.Proofs.Lower
