/-
Ryo.Proofs.Lower.CopyOps — `load.copy` and `store.copy` through a pointer in a slot, and frame
facts for a state with no escaped object (M5b: `Indirect` inputs, `PrologInd.lean`, and sret
returns, `RetSret.lean`).

- `opSem_loadCopy_fwd`/`opSem_storeCopy_fwd`: the forward direction of the two handlers on
  `[p + 0]` (as `SimDeref.lean`'s `opSem_load_fwd`/`opSem_store_fwd`, with the length an
  immediate operand, `.opnd "len"`).
- `writeFrame_noesc`, `readFrame_noesc`: with nothing escaped a frame write changes only the
  frame bytes in its range (memory, exposure, escapes kept), a frame read reads the frame bytes.
- `load_of_fits`, `load_congr`, `stLoad_ok`, `wrappingOffset_zero`: `State.load` through a
  pointer whose own allocation contains the range is memory's `load`; it depends only on memory
  and exposure.
-/
import Ryo.Proofs.Lower.SimDeref

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem

/-! ### Frame and memory facts -/

/-- A frame write with nothing escaped (see the module comment). -/
theorem writeFrame_noesc {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    (hn : ∀ o, st.escapedAt o = none) :
    ∃ st', st.writeFrame off bs = .ok st' ∧ st'.mem = st.mem ∧ st'.exposed = st.exposed ∧
      st'.escaped = st.escaped ∧
      ∀ o, st'.frame o =
        if off ≤ o ∧ o < off + bs.length then bs.getD (o - off).toNat .uninit else st.frame o := by
  unfold OpSem.State.writeFrame
  rw [writeEscaped_private' (fun i _ => hn _)]
  simp only [bind, Except.bind, pure, Except.pure]
  refine ⟨_, rfl, rfl, rfl, rfl, fun o => ?_⟩
  simp only [OpSem.State.privateIn, hn, Option.isNone_none, Bool.and_true, decide_eq_true_eq]

/-- `writeFrame_noesc` for a given write. -/
theorem writeFrame_noesc' {st st' : OpSem.State} {off : Int} {bs : List AbstractByte}
    (h : st.writeFrame off bs = .ok st') (hn : ∀ o, st.escapedAt o = none) :
    st'.mem = st.mem ∧ st'.exposed = st.exposed ∧ st'.escaped = st.escaped ∧
      ∀ o, st'.frame o =
        if off ≤ o ∧ o < off + bs.length then bs.getD (o - off).toNat .uninit else st.frame o := by
  obtain ⟨st'', h', h1, h2, h3, h4⟩ := writeFrame_noesc (off := off) (bs := bs) hn
  rw [h'] at h
  obtain rfl := Except.ok.inj h
  exact ⟨h1, h2, h3, h4⟩

/-- A frame read with nothing escaped reads the frame bytes. -/
theorem readFrame_noesc {st : OpSem.State} {off : Int} {bs : List AbstractByte}
    (hn : ∀ o, st.escapedAt o = none)
    (hb : ∀ j (hj : j < bs.length), st.frame (off + j) = bs[j]) :
    st.readFrame off bs.length = .ok bs := by
  have h := readFrame_eq_map (st := st) (off := off) (n := bs.length)
    (g := fun i => bs.getD i .uninit) (by
      intro i hi
      simp only [OpSem.State.byteAt, hn, hb i hi]
      simp [List.getD, List.getElem?_eq_getElem hi, pure, Except.pure])
  rw [h]
  congr 1
  apply List.ext_getElem
  · simp
  · intro i h1 h2
    simp [List.getD, List.getElem?_eq_getElem h2]

/-- `escapedAt` reads only the escaped objects. -/
theorem escapedAt_of_escaped {st st' : OpSem.State} (h : st'.escaped = st.escaped) (o : Int) :
    st'.escapedAt o = st.escapedAt o := by
  unfold OpSem.State.escapedAt
  rw [h]

/-- `fits` reads only memory. -/
theorem fits_congr {st st' : OpSem.State} (hm : st'.mem = st.mem) : st'.fits = st.fits := by
  funext a l i
  unfold OpSem.State.fits
  rw [hm]

/-- `State.load` reads only memory and exposure. -/
theorem load_congr {st st' : OpSem.State} (hm : st'.mem = st.mem) (hx : st'.exposed = st.exposed)
    (p : ThinPointer) (n : Nat) : st'.load p n = st.load p n := by
  have hf := fits_congr hm
  unfold OpSem.State.load OpSem.State.resolve OpSem.State.resolveExposed
  rw [hf, hm, hx]

/-- A pointer whose own allocation contains the range resolves to itself. -/
theorem load_of_fits {st : OpSem.State} {q : ThinPointer} {n : Nat} {id : AllocId}
    (hp : q.prov = some id) (hf : st.fits q.addr n id = true) :
    st.load q n = liftOutcome (st.mem.load q n Align.one) := by
  unfold OpSem.State.load OpSem.State.resolve
  rw [hp]
  dsimp only
  rw [if_pos hf]

/-- `fits` from the allocation's facts. -/
theorem fits_of {st : OpSem.State} {q : ThinPointer} {n : Nat} {id : AllocId} {y : Allocation}
    (hy : st.mem.get? id = some y) (hl : y.live = true) (h1 : y.addr ≤ q.addr)
    (h2 : q.addr + n ≤ y.addr + y.size) : st.fits q.addr n id = true := by
  unfold OpSem.State.fits
  rw [hy]
  simp [hl, h1, h2]

/-- A successful `State.load` is memory's `load` at the resolved pointer. -/
theorem stLoad_ok {st : OpSem.State} {p : ThinPointer} {n : Nat} {bs : List AbstractByte}
    (h : st.load p n = .ok bs) : st.mem.load (st.resolve p n) n Align.one = .ok bs := by
  unfold OpSem.State.load liftOutcome at h
  split at h
  · cases h; assumption
  all_goals cases h

theorem stLoad_length {st : OpSem.State} {p : ThinPointer} {n : Nat} {bs : List AbstractByte}
    (h : st.load p n = .ok bs) : bs.length = n :=
  load_length (stLoad_ok h)

theorem liftOutcome_pure {α : Type} (a : α) :
    liftOutcome (.ok a : Except Outcome α) = .ok a := rfl

/-- `wrappingOffset 0` of an address below the limit. -/
theorem wrappingOffset_zero {q : ThinPointer} (h : q.addr < Target.ADDR_LIMIT) :
    q.wrappingOffset 0 = q := by
  obtain ⟨a, pr⟩ := q
  have h0 : a < Target.ADDR_LIMIT := h
  have h1 : (a : Int) < ((Target.ADDR_LIMIT : Nat) : Int) := Int.ofNat_lt.mpr h0
  have h2 : (((a : Int) + 0) % ((Target.ADDR_LIMIT : Nat) : Int)).toNat = a := by
    rw [Int.add_zero, Int.emod_eq_of_lt (by omega) h1]
    simp
  simp only [ThinPointer.wrappingOffset, h2]

/-! ### The handlers -/

/-- The footprint of `load.copy`. -/
def loadCopyFp : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "m" 8], writes := [⟨"d", .opnd "len"⟩],
    derefs := [⟨PtrSrc.mem "m", .opnd "len", .read, false⟩] }

/-- The footprint of `store.copy`. -/
def storeCopyFp : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "m" 8, ⟨"s", .opnd "len"⟩],
    derefs := [⟨PtrSrc.mem "m", .opnd "len", .write, false⟩] }

theorem mem0_fits {p : Int} (h1 : -2 ^ 31 ≤ p) (h2 : p < 2 ^ 31) :
    Val.fits .mem (.mem p 0) = true := by
  simp only [Val.fits, Bool.and_eq_true, decide_eq_true_eq]
  first
    | exact ⟨⟨⟨h1, h2⟩, by decide⟩, by decide⟩
    | exact ⟨h1, h2, by decide, by decide⟩
    | omega

theorem u32_fits {n : Nat} (h : n < 2 ^ 32) : Val.fits .u32 (.imm n) = true := by
  simpa [Val.fits] using h

/-- The forward direction of `load.copy d, [p + 0], n`.

Proof: as `opSem_load_fwd`: the footprint is `loadCopyFp` (`footprintOf .load_copy`, whatever
the parameters), `prepare` succeeds (the operands fit), `readAll` reads `m`'s 8 bytes `bp`,
`kindSem .load_copy` reads the length immediate, decodes `bp` (`hq`) and loads at
`q.wrappingOffset 0` from the frame-erased state (the same `load`), and `commit` writes `bs`
at `d` (`hlen`, `hw`). -/
theorem opSem_loadCopy_fwd {op : Full.Opcode} {ps : List String} {r : Option String}
    {d p : Int} {n : Nat} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.load_copy, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"m", .mem⟩, ⟨"len", .u32⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ p ∧ p < 2 ^ 31 ∧ n < 2 ^ 32)
    {bp : List AbstractByte} (hrp : st.readFrame p 8 = .ok bp) {q : ThinPointer}
    (hq : decodePtr bp = some q) {bs : List AbstractByte}
    (hl : st.load (q.wrappingOffset 0) n = .ok bs) (hlen : bs.length = n)
    (hw : st.writeFrame d bs = .ok st') :
    opSem op [.slot d, .mem p 0, .imm n] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, hp1, hp2, hn⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfm := mem0_fits hp1 hp2
  have hfn := u32_fits hn
  have hfp : footprint op = some loadCopyFp := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    first | rfl | (simp only [footprintOf]; rfl)
  have hprep : prepare op [.slot d, .mem p 0, .imm n] =
      .ok (⟨.load_copy, ps, r⟩, loadCopyFp, opndVal op.info [.slot d, .mem p 0, .imm n]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfm, hfn])]
    rfl
  have hvm : opndVal op.info [.slot d, .mem p 0, .imm n] "m" = some (.mem p 0) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .mem p 0, .imm n] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hvl : opndVal op.info [.slot d, .mem p 0, .imm n] "len" = some (.imm n) := by
    simp [opndVal, ho]
  have hrd : readAll loadCopyFp (opndVal op.info [.slot d, .mem p 0, .imm n]) st =
      .ok [("m", bp)] := by
    simp only [readAll, loadCopyFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvm, Val.slotOff, Extent.eval, hrp,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hl' : OpSem.State.load { st with frame := fun _ => .uninit } (q.wrappingOffset 0) n =
      .ok bs := hl
  have hk : kindSem .load_copy ps
      (mkEnv [("m", bp)] (opndVal op.info [.slot d, .mem p 0, .imm n]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", bs)] } := by
    simp [kindSem, mkEnv, Env.imm, Env.memPtr, Env.ptr, asPtr, hq, hvm, hvl, hl', hl, out,
      bind, Except.bind, pure, Except.pure]
  have hc : commit loadCopyFp (opndVal op.info [.slot d, .mem p 0, .imm n]) st [("d", bs)] =
      .ok st' := by
    simp only [commit, loadCopyFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Access.range, hvd, hvl, Val.slotOff, Extent.eval, hlen, hw, bind,
      Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-- The forward direction of `store.copy [p + 0], s, n`.

Proof: as `opSem_store_fwd`, with `storeCopyFp` (reads `m`'s 8 bytes and `s`'s `n`, no frame
writes); `kindSem .store_copy` stores `s`'s bytes at `q.wrappingOffset 0` into `st.mem`
(`hst`), and `commit` of no writes returns `{ st with mem := mem' }`. -/
theorem opSem_storeCopy_fwd {op : Full.Opcode} {ps : List String} {r : Option String}
    {p s : Int} {n : Nat} {st : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.store_copy, ps, r⟩)
    (ho : op.info.operands = [⟨"m", .mem⟩, ⟨"s", .slot⟩, ⟨"len", .u32⟩])
    (hfits : -2 ^ 31 ≤ p ∧ p < 2 ^ 31 ∧ -2 ^ 31 ≤ s ∧ s < 2 ^ 31 ∧ n < 2 ^ 32)
    {bp : List AbstractByte} (hrp : st.readFrame p 8 = .ok bp) {q : ThinPointer}
    (hq : decodePtr bp = some q) {bs : List AbstractByte} (hrs : st.readFrame s n = .ok bs)
    {mem' : Memory} (hst : st.store st.mem (q.wrappingOffset 0) bs = .ok mem') :
    opSem op [.mem p 0, .slot s, .imm n] st ch = .ok (.next, { st with mem := mem' }) := by
  obtain ⟨hp1, hp2, hs1, hs2, hn⟩ := hfits
  have hfs := slot_fits hs1 hs2
  have hfm := mem0_fits hp1 hp2
  have hfn := u32_fits hn
  have hfp : footprint op = some storeCopyFp := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    first | rfl | (simp only [footprintOf]; rfl)
  have hprep : prepare op [.mem p 0, .slot s, .imm n] =
      .ok (⟨.store_copy, ps, r⟩, storeCopyFp, opndVal op.info [.mem p 0, .slot s, .imm n]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfs, hfm, hfn])]
    rfl
  have hvm : opndVal op.info [.mem p 0, .slot s, .imm n] "m" = some (.mem p 0) := by
    simp [opndVal, ho]
  have hvs : opndVal op.info [.mem p 0, .slot s, .imm n] "s" = some (.slot s) := by
    simp [opndVal, ho]
  have hvl : opndVal op.info [.mem p 0, .slot s, .imm n] "len" = some (.imm n) := by
    simp [opndVal, ho]
  have hrd : readAll storeCopyFp (opndVal op.info [.mem p 0, .slot s, .imm n]) st =
      .ok [("m", bp), ("s", bs)] := by
    simp only [readAll, storeCopyFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvm, hvs, hvl, Val.slotOff, Extent.eval, hrp,
      hrs, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst' : OpSem.State.store { st with frame := fun _ => .uninit } st.mem
      (q.wrappingOffset 0) bs = .ok mem' := hst
  have hk : kindSem .store_copy ps
      (mkEnv [("m", bp), ("s", bs)] (opndVal op.info [.mem p 0, .slot s, .imm n]) st ch) =
      .ok { mem := mem' } := by
    simp [kindSem, mkEnv, Env.memPtr, Env.ptr, asPtr, hq, hvm, hst', hst, bind, Except.bind,
      pure, Except.pure]
  have hc : commit storeCopyFp (opndVal op.info [.mem p 0, .slot s, .imm n])
      { st with mem := mem' } [] = .ok { st with mem := mem' } := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  all_goals first
    | rfl
    | (rw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)
    | simp [hc]

end Ryo.Proofs.Lower
