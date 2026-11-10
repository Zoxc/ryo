/-
Ryo.Proofs.Lower.SimPrologS — the prologue simulated for `LowerPrologS`
(`Check/Lower/PrologSpread.lean`, M5b): a spread argument, in `SimPrologI.lean`'s shapes.

- `prologI_bytes`: `prologI_sim`'s run stated over frame bytes rather than locals: after the
  prologue every `arg`'s range holds its register's bytes, and every `Indirect` input's home
  the bytes its pointer loads (`IndLoad`: the caller's side of the load).
- `ArgRelS`: the L0 side of call entry for the spread local: its allocation private, live, at
  the slot, of the slot's size, and each byte `Uninit` (padding) or one some field input puts
  there (`PieceByte`: a register piece's byte, or a copied byte), refined. L0's `createFrame`
  stores each field's value at its offset in a fresh allocation, so the caller (M5c) gives it
  from the fields' `ArgRelI`-like facts.
- `prologS_sim`, `match_entryS`, `fn_soundSp`: `prologI_sim`, `match_entryI`, `fn_soundI` with
  the fixed inputs' locals (`ArgRelI`) and the spread local (`ArgRelS`).
-/
import Ryo.Proofs.Lower.SimRetSret
import Ryo.Check.Lower.PrologSpread

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-- The caller's side of an `Indirect` input's load: `gpr idx` holds a pointer to `n` bytes of a
live allocation of `m1`, which are `bs`. -/
def IndLoad (m1 : Memory) (args : Regs) (idx n : Nat) (bs : List AbstractByte) : Prop :=
  ∃ q id y, (regBytes args (ptrArg idx)).length = 8 ∧
    decodePtr (regBytes args (ptrArg idx)) = some q ∧ q.prov = some id ∧ m1.get? id = some y ∧
    y.live = true ∧ y.addr ≤ q.addr ∧ q.addr + n ≤ y.addr + y.size ∧
    m1.load q n Align.one = .ok bs

theorem IndLoad.length {m1 : Memory} {args : Regs} {idx n : Nat} {bs : List AbstractByte}
    (h : IndLoad m1 args idx n bs) : bs.length = n := by
  obtain ⟨q, id, y, h1, h2, h3, h4, h5, h6, h7, hld⟩ := h
  exact load_length hld

/-- The prologue's run over frame bytes (see the module comment).

Proof: `prologI_sim`'s, without the locals: `writes_run_esc`, then `copies_run` (each copy's
pointer from `hind`), the `arg`s' bytes kept by the copies (`hkeep`). -/
theorem prologI_bytes {Γp : PrologICtx} {c : Code} {ch : OpSem.Choice} {is : List Insn}
    {inps : List InputI} {lw : List ArgWrite}
    (hargs : ArgsAre (is.take (allWritesI Γp inps lw).length) (allWritesI Γp inps lw))
    (hcop : CopiesAre c.mode c.ρ (is.drop (allWritesI Γp inps lw).length) (allCopies inps))
    (hdisj : (allRanges Γp inps lw).Pairwise RngDisj)
    (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {s : RState}
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧
      c.scopesAt (s.pc + j) = [])
    (hnoesc : ∀ o, s.st.escapedAt o = none)
    (hind : ∀ inp ∈ inps, ∀ ptr idx, inp.kind = .ind ptr idx → inp.slot.size ≠ 0 →
      ∃ bs, IndLoad s.st.mem s.args idx inp.slot.size bs) :
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      s'.st.mem = s.st.mem ∧ s'.st.escaped = s.st.escaped ∧ (∀ o, s'.st.escapedAt o = none) ∧
      (∀ w ∈ allWritesI Γp inps lw, ∀ (j : Nat) (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j]) ∧
      (∀ inp ∈ inps, ∀ ptr idx, inp.kind = .ind ptr idx → inp.slot.size ≠ 0 →
        ∀ bs, IndLoad s.st.mem s.args idx inp.slot.size bs →
        ∀ (k : Nat) (hk : k < bs.length), s'.st.frame (inp.slot.off + k) = bs[k]) := by
  -- the ranges
  have hd0 : ((allWritesI Γp inps lw).map ArgWrite.rng ++
      (allCopies inps).map CopyIn.rng).Pairwise RngDisj := hdisj
  obtain ⟨hdW, hdC, hdWC⟩ := List.pairwise_append.mp hd0
  have hwd : (allWritesI Γp inps lw).Pairwise WriteDisj :=
    (List.pairwise_map.mp hdW).imp fun h => h
  have hcd : (allCopies inps).Pairwise (fun a b => RngDisj a.rng b.rng) :=
    List.pairwise_map.mp hdC
  have hwc : ∀ w ∈ allWritesI Γp inps lw, ∀ cp ∈ allCopies inps, RngDisj w.rng cp.rng :=
    fun w hw cp hcp => hdWC _ (List.mem_map_of_mem hw) _ (List.mem_map_of_mem hcp)
  -- the `arg`s
  obtain ⟨n, hn⟩ : ∃ n, (allWritesI Γp inps lw).length = n := ⟨_, rfl⟩
  have hA : ArgsAre (is.take n) (allWritesI Γp inps lw) := by rw [← hn]; exact hargs
  have hC : CopiesAre c.mode c.ρ (is.drop n) (allCopies inps) := by rw [← hn]; exact hcop
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
    obtain ⟨bs, q, id, y, hpbl, hq, hqp, hy, hyl, hy1, hy2, hld⟩ := hind inp hinp _ idx hk hz
    refine ⟨regBytes s.args (ptrArg idx), q, bs, hpbl, fun k hk' => ?_, hq, ?_⟩
    · have hw : (cp.ptr, ptrArg idx) ∈ allWritesI Γp inps lw :=
        write_of_input hinp (by simp [InputI.writes, hk])
      exact hinA' _ hw k hk'
    · rw [← hsz]
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
  refine ⟨sC, hstA.trans hstC, ?_, hfpC.trans hfpA, hargsC.trans hargsA, hmemC.trans hmemA,
    hesclC.trans hesclA, hescC, ?_, ?_⟩
  · rw [hpcC, hpcA, hlenA]
    simp only [List.length_drop]
    omega
  · intro w hw j hj
    rw [hkeep w hw j (by have := regBytes_length_le s.args w.2; omega)]
    exact hinA' w hw j hj
  · intro inp hinp ptr idx hk hz bs hIL k hk'
    obtain ⟨q, id, y, hpbl, hq, hqp, hy, hyl, hy1, hy2, hld⟩ := hIL
    have hcp := copy_of_mem hinp hk hz
    have hw : (ptr, ptrArg idx) ∈ allWritesI Γp inps lw :=
      write_of_input hinp (by simp [InputI.writes, hk])
    have hl' : sA.st.load (q.wrappingOffset 0) inp.slot.size = .ok bs :=
      ind_load hmemA hpbl hq hqp hy hyl hy1 hy2 hld
    exact hinC _ hcp (regBytes s.args (ptrArg idx)) q bs hpbl
      (fun k' hk'' => hinA' _ hw k' hk'') hq hl' k hk'

/-! ### The spread local -/

/-- Frame offset `o` gets byte `b` from field input `inp` (see the module comment). -/
def PieceByte (m1 : Memory) (args : Regs) (inp : InputI) (o : Int) (b : AbstractByte) : Prop :=
  match inp.kind with
  | .regs ps => ∃ p ∈ ps, ∃ j : Nat, o = inp.slot.off + p.1 + j ∧ (regBytes args p.2)[j]? = some b
  | .ind _ idx => ∃ bs, ∃ j : Nat, IndLoad m1 args idx inp.slot.size bs ∧ o = inp.slot.off + j ∧
      bs[j]? = some b

/-- The L0 side of call entry for the spread local with storage `ptr` and slot `sl`, its fields
`fields`, and their `Indirect` loads' R side (see the module comment). -/
def ArgRelS (ι : Inj) (fp : Nat) (m0 m1 : Memory) (args : Regs) (sl : LocalSlot)
    (fields : List InputI) (ptr : ThinPointer) : Prop :=
  (∀ inp ∈ fields, ∀ ptr idx, inp.kind = .ind ptr idx → inp.slot.size ≠ 0 →
    ∃ bs, IndLoad m1 args idx inp.slot.size bs) ∧
  ∃ al x, ptr.prov = some al ∧ ι al = none ∧ m0.get? al = some x ∧ x.live = true ∧
    (x.addr : Int) = fp + sl.off ∧ ptr.addr = x.addr ∧ x.data.size = sl.size ∧
    ∀ k (hk : k < x.data.size), x.data[k] = .uninit ∨
      ∃ inp ∈ fields, ∃ b, PieceByte m1 args inp (sl.off + k) b ∧ ByteInj ι x.data[k] b

/-- `IndRel`'s load as `IndLoad`. -/
theorem IndRel.load {ι : Inj} {m1 : Memory} {args : Regs} {idx : Nat} {x : Allocation}
    (h : IndRel ι m1 args idx x) (hz : x.data.size ≠ 0) :
    ∃ bs, IndLoad m1 args idx x.data.size bs ∧ BytesInj ι x.data.toList bs := by
  obtain ⟨q, id, y, bs, hpbl, hq, hqp, hy, hyl, hy1, hy2, hld, hbi⟩ := h hz
  exact ⟨bs, ⟨q, id, y, hpbl, hq, hqp, hy, hyl, hy1, hy2, hld⟩, hbi⟩

/-- The prologue simulated with a spread argument (see the module comment).

Proof: `prologI_bytes` over `fixed ++ fields` (the `Indirect` loads from `ArgRelI`'s `IndRel`
and `ArgRelS`'s first part); a fixed input's `LocalRel` as `prologI_sim`'s; the spread local's
from `ArgRelS`: each byte `Uninit`, or a field's register byte (`prologI_bytes`'s `arg` bytes)
or copied byte (its copy bytes). -/
theorem prologS_sim {Γp : PrologSCtx} {c : Code} {ch : OpSem.Choice} {is : List Insn}
    {fixed fields : List InputI} {lw : List ArgWrite} {sl : LocalSlot}
    (hl : LowerPrologS Γp is fixed fields lw sl)
    (hmo : Γp.mode = c.mode) (hρ : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hpl : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {ι : Inj} {fp : Nat} {m0 : Memory} {s : RState}
    (hcode : ∀ (j : Nat) (hj : j < is.length), c.d.insns[s.pc + j]? = some is[j] ∧
      c.scopesAt (s.pc + j) = [])
    (hnoesc : ∀ o, s.st.escapedAt o = none)
    (qs : List ThinPointer) (hqs : fixed.length = qs.length)
    (hrel : ∀ j (h1 : j < fixed.length) (h2 : j < qs.length),
      ArgRelI ι fp m0 s.st.mem s.args fixed[j] qs[j])
    (qsp : ThinPointer) (hrels : ArgRelS ι fp m0 s.st.mem s.args sl fields qsp)
    (hmem : MemInj ι m0 s.st.mem) :
    ∃ s', StepsTo c ch s s' ∧ s'.pc = s.pc + is.length ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      MemInj ι m0 s'.st.mem ∧ (∀ o, s'.st.escapedAt o = none) ∧
      (∀ j (h1 : j < fixed.length) (h2 : j < qs.length),
        LocalRel ι fp s'.st m0 fixed[j].slot qs[j] true) ∧
      LocalRel ι fp s'.st m0 sl qsp true ∧
      (∀ w ∈ sretWrites Γp.toPrologXCtx ++ lw, ∀ (j : Nat) (hj : j < (regBytes s.args w.2).length),
        s'.st.frame (w.1 + j) = (regBytes s.args w.2)[j]) ∧ s'.st.mem = s.st.mem ∧
      s'.st.escaped = s.st.escaped := by
  obtain ⟨hindF, al, x, hp, hι, hx, hlive, haddr, hpaddr, hsize, hbyt⟩ := hrels
  have hind : ∀ inp ∈ fixed ++ fields, ∀ ptr idx, inp.kind = .ind ptr idx →
      inp.slot.size ≠ 0 → ∃ bs, IndLoad s.st.mem s.args idx inp.slot.size bs := by
    intro inp hinp ptr idx hk hz
    rcases List.mem_append.mp hinp with hf | hf
    · obtain ⟨j, hj, rfl⟩ := List.getElem_of_mem hf
      have hr := hrel j hj (by omega)
      simp only [ArgRelI, hk] at hr
      obtain ⟨-, x', -, -, -, -, -, -, hxs, hir⟩ := hr
      obtain ⟨bs, hbs, -⟩ := hir.load (by rw [hxs]; exact hz)
      rw [hxs] at hbs
      exact ⟨bs, hbs⟩
    · exact hindF inp hf ptr idx hk hz
  obtain ⟨s', hst, hpc, hfp, hargs, hmeq, hescl, hesc, hW, hI⟩ :=
    prologI_bytes (ch := ch) hl.args (by rw [← hmo, ← hρ]; exact hl.copies) hl.disj hpe hpl
      hcode hnoesc hind
  refine ⟨s', hst, hpc, hfp, hargs, by rw [hmeq]; exact hmem, hesc, ?_, ?_, ?_, hmeq, hescl⟩
  · -- the fixed inputs, as `prologI_sim`
    intro j h1 h2
    have hr := hrel j h1 h2
    have hmemj : fixed[j] ∈ fixed ++ fields := List.mem_append_left _ (List.getElem_mem h1)
    cases hkind : fixed[j].kind with
    | regs ps =>
      simp only [ArgRelI, hkind] at hr
      obtain ⟨al', x', hp', hι', hx', hlive', haddr', hpaddr', hsize', hb⟩ := hr
      refine .priv al' x' hp' hι' hx' hlive' haddr' hpaddr' hsize' (fun k _ => hesc _) ?_
      intro _ k hk
      rcases hb k hk with hu | ⟨p, hpp, hle, b, hbk, hbi⟩
      · rw [hu]; trivial
      · obtain ⟨hkl, hbe⟩ := List.getElem?_eq_some_iff.mp hbk
        have hwm :
            (fixed[j].slot.off + p.1, p.2) ∈ allWritesI Γp.toPrologICtx (fixed ++ fields) lw :=
          write_of_input hmemj (by
            simp only [InputI.writes, hkind]
            exact List.mem_map_of_mem hpp)
        have hfk := hW _ hwm (k - p.1) hkl
        dsimp only at hfk
        have e : fixed[j].slot.off + (k : Int) =
            fixed[j].slot.off + (p.1 : Int) + ((k - p.1 : Nat) : Int) := by omega
        rw [e, hfk, hbe]
        exact hbi
    | ind ptr idx =>
      simp only [ArgRelI, hkind] at hr
      obtain ⟨al', x', hp', hι', hx', hlive', haddr', hpaddr', hsize', hir⟩ := hr
      refine .priv al' x' hp' hι' hx' hlive' haddr' hpaddr' hsize' (fun k _ => hesc _) ?_
      intro _ k hk
      have hz : x'.data.size ≠ 0 := by omega
      obtain ⟨bs, hbs, hbi⟩ := hir.load hz
      have hbl : bs.length = x'.data.size := hbs.length
      rw [hsize'] at hbs
      have hc := hI _ hmemj ptr idx hkind (by rw [← hsize']; exact hz) bs hbs k (by omega)
      rw [hc]
      have := BytesInj.getElem' hbi k (by simpa using hk) (by omega)
      simpa using this
  · -- the spread local
    refine .priv al x hp hι hx hlive haddr hpaddr hsize (fun k _ => hesc _) ?_
    intro _ k hk
    rcases hbyt k hk with hu | ⟨inp, hinp, b, hpb, hbi⟩
    · rw [hu]; trivial
    · have hmemi : inp ∈ fixed ++ fields := List.mem_append_right _ hinp
      cases hkind : inp.kind with
      | regs ps =>
        simp only [PieceByte, hkind] at hpb
        obtain ⟨p, hpp, j, ho, hbj⟩ := hpb
        obtain ⟨hjl, hbe⟩ := List.getElem?_eq_some_iff.mp hbj
        have hwm : (inp.slot.off + p.1, p.2) ∈ allWritesI Γp.toPrologICtx (fixed ++ fields) lw :=
          write_of_input hmemi (by
            simp only [InputI.writes, hkind]
            exact List.mem_map_of_mem hpp)
        have hfk := hW _ hwm j hjl
        dsimp only at hfk
        rw [ho, hfk, hbe]
        exact hbi
      | ind ptr idx =>
        simp only [PieceByte, hkind] at hpb
        obtain ⟨bs, j, hIL, ho, hbj⟩ := hpb
        obtain ⟨hjl, hbe⟩ := List.getElem?_eq_some_iff.mp hbj
        have hz : inp.slot.size ≠ 0 := by
          have := hIL.length
          omega
        have hc := hI _ hmemi ptr idx hkind hz bs hIL j hjl
        rw [ho, hc, hbe]
        exact hbi
  · intro w hw j hj
    have hw' : w ∈ allWritesI Γp.toPrologICtx (fixed ++ fields) lw := by
      simp only [allWritesI, List.mem_append] at hw ⊢
      rcases hw with h | h <;> simp [h]
    exact hW w hw' j hj

/-- `match_entryI` for `LowerPrologS`: the storage-live locals at entry are the fixed inputs'
(`qs`) and the spread local (`qsp`). -/
theorem match_entryS {Γ : TermCtx} {c : Code} {ch : OpSem.Choice} {ι : Inj}
    {Γp : PrologSCtx} {is : List Insn} {fixed fields : List InputI} {lw : List ArgWrite}
    {sl : LocalSlot}
    (hpl : LowerPrologS Γp is fixed fields lw sl) (hslots : Γp.slots = Γ.slots)
    (hmo : Γp.mode = c.mode) (hρp : Γp.ρ = c.ρ) (hpe : c.mode.pe = false)
    (hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hreach : reachGet (computeReach Γ.body) 0 = true)
    (hfz : blk.fused = true → 0 < bd.stmts.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : fixed.length = qs.length) (qsp : ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      (∃ j, ∃ (h1 : j < fixed.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j]) ∨
        (l = fixed.length + 1 ∧ p = qsp))
    (hrel : ∀ j (h1 : j < fixed.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args fixed[j] qs[j])
    (hrels : ArgRelS ι s1.fp s.mem s1.st.mem s1.args sl fields qsp)
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
  obtain ⟨s', hst, hpc, hfp, hargs, hmem', hesc, hlr0, hlrs0, hw, hmeq, -⟩ :=
    prologS_sim (ch := ch) hpl hmo hρp hpe hplain hcode hnoesc qs hqs hrel qsp hrels hmem
  have hlr : ∀ j (h1 : j < fixed.length) (h2 : j < qs.length),
      LocalRel ι s'.fp s'.st s.mem fixed[j].slot qs[j] true := by
    rw [hfp]; exact hlr0
  have hlrs : LocalRel ι s'.fp s'.st s.mem sl qsp true := by rw [hfp]; exact hlrs0
  refine ⟨s', hst, Or.inl ⟨f, rest, blk, bd, ?_, by rw [hbb]; exact hreach,
    fun h => by rw [hstmt]; exact hfz h⟩, hw, hargs, hesc, hmeq⟩
  refine { stack := hs, body := hbody, pu := hpu, cont := hcont, hblk := ?_, hbd := ?_,
           le := ?_, pc := ?_, rel := ?_, sl := ?_, pb := hpb, fresh := hfresh, dinv := hdinv }
  · rw [hbb]; exact hblk
  · rw [hbb]; exact hbd
  · rw [hstmt]; exact Nat.zero_le _
  · rw [hstmt, hstart, hpc]
  · refine ⟨⟨hmem', ?_⟩, hhid, hal, hprov, hapart, ?_⟩
    · intro l p hp _
      rcases hloc l p hp with ⟨j, h1, h2, rfl, rfl⟩ | ⟨rfl, rfl⟩
      · refine ⟨fixed[j].slot, ?_, (hlr j h1 h2).weaken (fun _ => rfl)⟩
        have := inputsOkI_slot hpl.fixedOk j h1
        rw [hslots] at this
        simpa using this
      · refine ⟨sl, ?_, hlrs.weaken (fun _ => rfl)⟩
        have := hpl.slot
        rw [hslots] at this
        exact this
    · intro o e he
      rw [hesc] at he
      cases he
  · intro l p hp
    rw [hbb, hstmt]
    exact hsl l p hp

/-- `fn_soundI` with `LowerPrologS`'s entry (`match_entryS`): functions with a spread argument.
Beyond `fn_soundI`'s: the spread local's entry facts (`hloc`'s second case, `ArgRelS`). -/
theorem fn_soundSp {Γ : TermCtx} {c : Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologSCtx} {is : List Insn} {fixed fields : List InputI} {lw : List ArgWrite}
    {sl : LocalSlot}
    (hpl : LowerPrologS Γp is fixed fields lw sl) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : fixed.length = qs.length) (qsp : ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      (∃ j, ∃ (h1 : j < fixed.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j]) ∨
        (l = fixed.length + 1 ∧ p = qsp))
    (hrel : ∀ j (h1 : j < fixed.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args fixed[j] qs[j])
    (hrels : ArgRelS ι s1.fp s.mem s1.st.mem s1.args sl fields qsp)
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
  obtain ⟨s0, hst0, hm0, -, -, -, -⟩ := match_entryS (ch := ch) hpl hslots (hpm.trans hmode.symm)
    (hpρ.trans hρ.symm) hpe hplain hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hqs qsp hloc hrel hrels hmem hhid hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | hstop
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · exact .inr (.inr (hstop.pre hst0))

/-- `fn_soundS` (`SimRetSret.lean`) with `LowerPrologS`'s entry (`match_entryS`): sret returns
resolved in functions with a spread argument. -/
theorem fn_soundSpS {Γ : TermCtx} {c : Code} {ι : Inj} {o : Spec.Oracle} {ch : OpSem.Choice}
    (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ) (hinc : IncomingOk c)
    (hpick : ∀ s s1, Match Γ ι s s1 → PicksAt Γ o ch s s1.fp)
    {Γp : PrologSCtx} {is : List Insn} {fixed fields : List InputI} {lw : List ArgWrite}
    {sl : LocalSlot}
    (hpl : LowerPrologS Γp is fixed fields lw sl) (hslots : Γp.slots = Γ.slots)
    (hpm : Γp.mode = Γ.mode) (hpρ : Γp.ρ = Γ.ρ) (hpsr : Γp.sret = Γ.sret)
    {s : Spec.State} {s1 : RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData}
    (hcode : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some is[j] ∧
      c.scopesAt (s1.pc + j) = [])
    (hnoesc : ∀ o, s1.st.escapedAt o = none)
    (hblk : Γ.blocks[0]? = some blk) (hbd : Γ.body.blocks[0]? = some bd)
    (hstart : pcAt blk 0 = s1.pc + is.length)
    (hs : s.stack = f :: rest) (hbody : f.body = Γ.body) (hbb : f.bb = 0) (hstmt : f.stmt = 0)
    (hpu : f.pendingUnwind = none) (hcont : f.cont = .bottom) (hal : f.aliased = [])
    (qs : List ThinPointer) (hqs : fixed.length = qs.length) (qsp : ThinPointer)
    (hloc : ∀ l p, f.locals[l]? = some (some p) →
      (∃ j, ∃ (h1 : j < fixed.length) (h2 : j < qs.length), l = j + 1 ∧ p = qs[j]) ∨
        (l = fixed.length + 1 ∧ p = qsp))
    (hrel : ∀ j (h1 : j < fixed.length) (h2 : j < qs.length),
      ArgRelI ι s1.fp s.mem s1.st.mem s1.args fixed[j] qs[j])
    (hrels : ArgRelS ι s1.fp s.mem s1.st.mem s1.args sl fields qsp)
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
    (hsr8 : ∀ so, Γ.sret = some so → (regBytes s1.args sretReg).length = 8)
    (hsrd : ∀ so, Γ.sret = some so → SretOk Γ s1.st.mem (regBytes s1.args sretReg))
    {n : Nat} {s' : Spec.State} (hrun : L0Steps o n s s') :
    (∃ s1', StepsTo c ch s1 s1' ∧ MatchX Γ ι s' s1') ∨
      (∃ s1' v regs incoming, StepsTo c ch s1 s1' ∧ s'.final = some (.returned v) ∧
        R.step c s1' ch = .ok (.done (R.exit s1' (.ret regs incoming))) ∧
          RetValX Γ ι v regs) ∨
      (∃ s1m sa sb m v regs incoming m1, StepsTo c ch s1 s1m ∧ L0Steps o m s sa ∧
        runOn (Sem.evalTerminator .«return») o sa = (.ok (), sb) ∧ sb.final = some (.returned v) ∧
        R.step c s1m ch = .ok (.done (R.exit s1m (.ret regs incoming))) ∧
        RetSret Γ ι v (regBytes s1.args sretReg) m1 s1m.st.mem regs) ∨
      FnStop Γ c ch ι o s s' s1 := by
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hplain : ∀ (k : Nat) i, c.d.insns[k]? = some i → PlainView c.mode c.ρ i := fun k i h => by
    rw [hmode, hρ]; exact hfn.plain k i h
  obtain ⟨s0, hst0, hm0, hw0, ha0, hn0, hme0⟩ := match_entryS (ch := ch) hpl hslots
    (hpm.trans hmode.symm)
    (hpρ.trans hρ.symm) hpe hplain hcode hnoesc hblk hbd hstart
    hfn.reach.entry (fused_start hfn hfn.reach.entry hbd hblk) hs hbody hbb hstmt hpu hcont hal
    qs hqs qsp hloc hrel hrels hmem hhid hprov hapart hsl hpb hfresh hdinv
  rcases fn_sim_ret hfn hmode hρ hinc hpick hm0 hrun with
    ⟨s1', hst, hm⟩ | ⟨s1', v, regs, incoming, hst, hf, hr, hv⟩ | hstop
  · exact .inl ⟨s1', hst0.trans hst, hm⟩
  · exact .inr (.inl ⟨s1', v, regs, incoming, hst0.trans hst, hf, hr, hv⟩)
  · rcases hstop with hd | hr | ha | ⟨s1', sa, sb, m, hst, hm, hsr⟩
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inl hd))))
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inr (.inl hr)))))
    · exact .inr (.inr (.inr (FnStop.pre hst0 (.inr (.inr (.inl ha))))))
    · obtain ⟨f', rest', live, next, is', so, hs', hb', hso, hlow, hat, hrel', hl0, hc', hret⟩ :=
        hsr
      have hso' : Γp.sret = some so := hpsr.trans hso
      have hwin : (so, sretReg) ∈ sretWrites Γp.toPrologXCtx ++ lw := by
        simp [sretWrites, hso']
      have h8 := hsr8 so hso
      have hpin : PinAt s0.st so s0.args := by
        rw [ha0]
        exact PinAt.of_bytes h8 (fun j hj => hw0 _ hwin j hj)
      have hd0 : SretOk Γ s0.st.mem (regBytes s0.args sretReg) := by
        rw [ha0, hme0]; exact hsrd so hso
      obtain ⟨v, s1m, regs, incoming, hfinal, hst', hstep2, hret'⟩ :=
        sim_retSret_from (ch := ch) hfn hmode hρ hinc (hfn.pin so hso) hst hn0 hpin
          (by rw [ha0]; exact h8) hd0 hs' hb' hlow hat hrel' hl0 hc' hret
      rw [ha0] at hret'
      exact .inr (.inr (.inl ⟨s1m, sa, sb, m, v, regs, incoming, _, hst0.trans hst', hm, hret,
        hfinal, hstep2, hret'⟩))

end Ryo.Proofs.Lower
