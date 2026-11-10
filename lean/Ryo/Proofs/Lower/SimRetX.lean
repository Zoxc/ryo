/-
Ryo.Proofs.Lower.SimRetX — `return` simulated for `LowerRetX` (`Check/Lower/RetX.lean`, M5b):
every register return, in `sim_ret`'s shape (`SimTerm.lean`).

The value relation generalizes `RetVal` (`FnEntry.lean`, an integer `_0`'s bits in the low bytes
of `rax`) to any `_0` (`RetValX`): the returned value `v` decodes, at `_0`'s type, from bytes
`bs0` of the type's size, and each register part of the function's return kind (`retRegs`:
its register, offset and size) holds `bs0`'s bytes at the part's offset, `ι`-refined
(`BytesInj`). `ι` enters because a returned pointer's R provenance is the renamed one. This is
the ABI's meaning of a register return (the caller reassembles the value from the parts), so
the caller's side (a later call rule) reads it back the same way. `RetValX.toRetVal`
(`FnEntry.lean`): for the `Term.lean` rule's shape it implies `RetVal`.

`lowerRetX_of_retOk`: `Term.lean`'s `ret` rule is an instance of `LowerRetX`, so a block's
`return` under `LowerTermX` (`TermExt.lean`) is always a `LowerRetX` (`LowerTermX.retX_of`),
and `fn_step_sim` (`FnStep.lean`) and `fn_step_sim_ret` (`FnEntry.lean`) simulate every
`return` with `sim_retX`, the value related by `RetValX Γ ι` (the same `ι` as `Match`'s).

The proof: `return_inv` (L0 loads `_0` at its type to `v`), `typedLoad_inv` (the load's
bytes `bs0`), `readLocal_inj` (R's frame bytes `bs1` of `_0`'s slot, `BytesInj ι bs0 bs1`), then
R's side: `retPartList_retRegs` (the registers of the parts, distinct), `readFrame_sub` (each
part's read is a slice of `bs1`), `ret_fold` (the register fold succeeds, each register's low
bytes the part's read), `stepBody_ret`; `BytesInj_slice` relates the slices.
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Proofs.Lower.IntBin
import Ryo.Check.Lower.TermExt

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.R Ryo.Check.Lower

/-- The returned value `v` related to R's return registers `regs` (see the module comment). -/
def RetValX (Γ : TermCtx) (ι : Inj) (v : Value) (regs : Regs) : Prop :=
  Γ.retKind ≠ 0 → ∀ ty, Γ.body.locals[0]? = some ty →
    ∃ bs0, ty.size? = some bs0.length ∧ ty.decode bs0 = some v ∧
      ∀ prs, retRegs Γ.retKind true = .ok prs → ∀ pr ∈ prs,
        BytesInj ι ((bs0.drop pr.1.off).take pr.1.size) ((regs.get pr.2).take pr.1.size)

/-! ### R's side of `ret` -/

/-- The parts `retPartList` gives are `retRegs`'s, with pairwise distinct registers.

Proof: unfold `retPartList` and `retRegs`; `Asm.retParts k true = some (a, b)`. Case on `a`
and `b` (`none`/`some`): the fold over `[a, b].filterMap id` gives `[]`, `[(a', gpr 0 or xmm
0)]` or two parts whose registers are `gpr 0`/`gpr 1`, `xmm 0`/`xmm 1`, `xmm 0`/`gpr 0` or
`gpr 0`/`xmm 0` (by `a'.xmm`, `b'.xmm`), distinct by `Reg`'s constructors (`decide` on the
concrete pairs, or `simp [List.nodup_cons]`). -/
theorem retPartList_retRegs {k : Nat} {ps : List Asm.RetPart} (h : retPartList k = some ps) :
    ∃ prs, retRegs k true = .ok prs ∧ prs.map Prod.fst = ps ∧ (prs.map Prod.snd).Nodup := by
  unfold retPartList at h
  cases hr : Asm.retParts k true with
  | none => simp [hr] at h
  | some ab =>
    obtain ⟨a, b⟩ := ab
    simp only [hr, Option.map_some, Option.some.injEq] at h
    subst h
    refine ⟨_, by unfold retRegs; rw [hr]; rfl, ?_⟩
    rcases a with _ | ⟨ax, asz, aoff⟩ <;> rcases b with _ | ⟨bx, bsz, boff⟩ <;>
      (try cases ax) <;> (try cases bx) <;> simp

/-- A read inside a successful frame read is its slice.

Proof: `OpSem.State.readFrame` is `(List.range n).mapM (byteAt (off + ·))`; from `h`, every
`byteAt (off + i)` for `i < n` succeeds with `bs[i]` (`Ryo.Proofs.Inline.mapM_ok`, as
`Ryo.Proofs.Inline.readFrame_length` uses it); then `readFrame_eq_map` (`FrameRel.lean`) with
`g i := bs[j + i]` and `off + j + i = off + (j + i)` (`omega`), and `(bs.drop j).take m` is
that map (`List.ext_getElem`). -/
theorem readFrame_sub {st : OpSem.State} {off : Int} {n : Nat} {bs : List AbstractByte}
    (h : st.readFrame off n = .ok bs) {j m : Nat} (hjm : j + m ≤ n) :
    st.readFrame (off + j) m = .ok ((bs.drop j).take m) := by
  have hl := Ryo.Proofs.Inline.readFrame_length h
  have hm := (Ryo.Proofs.Inline.mapM_ok h).2
  have hr : st.readFrame (off + j) m =
      .ok ((List.range m).map fun i => bs.getD (j + i) .uninit) := by
    apply readFrame_eq_map
    intro i hi
    have h1 : j + i < (List.range n).length := by simp; omega
    have h2 : j + i < bs.length := by omega
    have := hm (j + i) h1 h2
    have he : off + (j : Int) + (i : Int) = off + ((j + i : Nat) : Int) := by omega
    rw [he]
    simpa [List.getD, List.getElem?_eq_getElem h2] using this
  rw [hr]
  congr 1
  apply List.ext_getElem
  · simp <;> omega
  · intro i h1 h2
    have h3 : j + i < bs.length := by simp at h2; omega
    simp [List.getD, List.getElem?_eq_getElem h3]

/-- `Regs.set` then `Regs.get` of the same register. -/
theorem regs_get_set_self (rs : Regs) (r : Reg) (bs : List AbstractByte) :
    (rs.set r bs).get r = bs := by
  have h : ∀ l : List (Reg × List AbstractByte),
      (l.filter (·.1 != r) ++ [(r, bs)]).find? (·.1 == r) = some (r, bs) := by
    intro l
    induction l with
    | nil => simp
    | cons x l ih =>
      by_cases hx : x.1 = r
      · simpa [List.filter_cons, hx] using ih
      · simpa [List.filter_cons, hx, List.find?_cons] using ih
  simp only [Regs.get, Regs.set, h]

/-- `Regs.set` leaves the other registers. -/
theorem regs_get_set_ne (rs : Regs) {r r' : Reg} (bs : List AbstractByte) (hne : r' ≠ r) :
    (rs.set r bs).get r' = rs.get r' := by
  have hne' : r ≠ r' := fun h => hne h.symm
  have h : ∀ l : List (Reg × List AbstractByte),
      (l.filter (·.1 != r) ++ [(r, bs)]).find? (·.1 == r') = l.find? (·.1 == r') := by
    intro l
    induction l with
    | nil => simp [hne']
    | cons x l ih =>
      by_cases hx : x.1 = r
      · have hx' : x.1 ≠ r' := by rw [hx]; exact hne'
        rw [List.filter_cons_of_neg (by simp [hx]),
          List.find?_cons_of_neg (by simp [hx'])]
        exact ih
      · rw [List.filter_cons_of_pos (by simp [hx]), List.cons_append]
        by_cases hx' : x.1 = r'
        · rw [List.find?_cons_of_pos (by simp [hx']), List.find?_cons_of_pos (by simp [hx'])]
        · rw [List.find?_cons_of_neg (by simp [hx']), List.find?_cons_of_neg (by simp [hx'])]
          exact ih
  simp only [Regs.get, Regs.set, h]

/-- `ret_fold` from any initial register file: each part's register holds its read,
zero-extended; the registers of no part are unchanged. -/
theorem ret_fold_gen {st : OpSem.State} {src : Int} :
    ∀ (prs : List (Asm.RetPart × Reg)) (init : Regs), (prs.map Prod.snd).Nodup →
    (∀ pr ∈ prs, ∃ bs, st.readFrame (src + pr.1.off) pr.1.size = .ok bs) →
    ∃ regs, prs.foldlM (m := OpSem.M) (init := init) (fun rs (p, r) => do
        pure (rs.set r (zext (← st.readFrame (src + p.off) p.size) r.width))) = .ok regs ∧
      (∀ pr ∈ prs, ∀ bs, st.readFrame (src + pr.1.off) pr.1.size = .ok bs →
        regs.get pr.2 = zext bs pr.2.width) ∧
      (∀ r, r ∉ prs.map Prod.snd → regs.get r = init.get r)
  | [], init, _, _ => ⟨init, rfl, by simp, fun _ _ => rfl⟩
  | (p, r) :: tl, init, hnd, hrd => by
    obtain ⟨bs, hbs⟩ := hrd (p, r) (List.mem_cons_self ..)
    have hnd' : r ∉ tl.map Prod.snd ∧ (tl.map Prod.snd).Nodup := by
      simpa [List.nodup_cons] using hnd
    obtain ⟨regs, hf, hget, hoth⟩ := ret_fold_gen tl (init.set r (zext bs r.width)) hnd'.2
      (fun pr hpr => hrd pr (List.mem_cons_of_mem _ hpr))
    refine ⟨regs, ?_, ?_, ?_⟩
    · simp only [List.foldlM_cons, hbs, bind, Except.bind, pure, Except.pure]
      first | exact hf | simpa using hf
    · intro pr hpr bs' hbs'
      rcases List.mem_cons.mp hpr with rfl | hpr
      · obtain rfl : bs' = bs := Except.ok.inj (hbs'.symm.trans hbs)
        show regs.get r = zext bs' r.width
        rw [hoth r hnd'.1, regs_get_set_self]
      · exact hget pr hpr bs' hbs'
    · intro r' hr'
      have hne : r' ≠ r := fun he => hr' (by rw [he]; exact List.mem_cons_self ..)
      have hr'' : r' ∉ tl.map Prod.snd := fun hm => hr' (List.mem_cons_of_mem _ hm)
      rw [hoth r' hr'', regs_get_set_ne _ _ hne]

/-- `ret`'s register fold (as `step` and `stepBody_ret` write it) succeeds when every part's
read does, and each register's low `size` bytes are its part's read.

Proof: generalize `{}` to any `init` and induct on `prs`; each step `Regs.set r`; for a part
`(p, r)`, the later sets are of other registers (`hnd`), and `Regs.get` after `Regs.set` of
another register is unchanged (`Regs.get`/`Regs.set` unfold to `find?` over a `filter ++ [_]`:
`List.find?_append`, `List.find?_filter`), after its own is the new bytes (`regs_get_set`'s
argument, `SimTerm.lean`); `(zext bs w).take bs.length = bs` (`zext`, `List.take_left'`) with
`Ryo.Proofs.Inline.readFrame_length`. -/
theorem ret_fold {st : OpSem.State} {src : Int} {prs : List (Asm.RetPart × Reg)}
    (hnd : (prs.map Prod.snd).Nodup)
    (hrd : ∀ pr ∈ prs, ∃ bs, st.readFrame (src + pr.1.off) pr.1.size = .ok bs) :
    ∃ regs, prs.foldlM (m := OpSem.M) (init := ({} : Regs)) (fun rs (p, r) => do
        pure (rs.set r (zext (← st.readFrame (src + p.off) p.size) r.width))) = .ok regs ∧
      ∀ pr ∈ prs, ∀ bs, st.readFrame (src + pr.1.off) pr.1.size = .ok bs →
        (regs.get pr.2).take pr.1.size = bs := by
  obtain ⟨regs, hf, hget, -⟩ := ret_fold_gen prs {} hnd hrd
  refine ⟨regs, hf, fun pr hpr bs hbs => ?_⟩
  rw [hget pr hpr bs hbs]
  have hlen := Ryo.Proofs.Inline.readFrame_length hbs
  unfold zext
  rw [← hlen]
  simp

theorem BytesInj_drop {ι : Inj} :
    ∀ {bs0 bs1 : List AbstractByte}, BytesInj ι bs0 bs1 → ∀ j,
      BytesInj ι (bs0.drop j) (bs1.drop j)
  | [], [], _, j => by simp [BytesInj]
  | _ :: _, _ :: _, h, 0 => h
  | _ :: _, _ :: _, h, j + 1 => by
    simp only [BytesInj] at h
    simpa using BytesInj_drop h.2 j
  | [], _ :: _, h, _ => by simp [BytesInj] at h
  | _ :: _, [], h, _ => by simp [BytesInj] at h

theorem BytesInj_take {ι : Inj} :
    ∀ {bs0 bs1 : List AbstractByte}, BytesInj ι bs0 bs1 → ∀ m,
      BytesInj ι (bs0.take m) (bs1.take m)
  | [], [], _, m => by simp [BytesInj]
  | _ :: _, _ :: _, _, 0 => by simp [BytesInj]
  | _ :: _, _ :: _, h, m + 1 => by
    simp only [BytesInj] at h
    simp only [List.take_succ_cons, BytesInj]
    exact ⟨h.1, BytesInj_take h.2 m⟩
  | [], _ :: _, h, _ => by simp [BytesInj] at h
  | _ :: _, [], h, _ => by simp [BytesInj] at h

/-- Slices of related byte lists are related.

Proof: induction on `bs0` against `bs1` (`BytesInj`'s equations), `j` and `m` alongside:
`drop` peels pairs, `take` keeps pairs, `BytesInj ι [] []` at the ends. -/
theorem BytesInj_slice {ι : Inj} {bs0 bs1 : List AbstractByte} (h : BytesInj ι bs0 bs1)
    (j m : Nat) : BytesInj ι ((bs0.drop j).take m) ((bs1.drop j).take m) := by
  exact BytesInj_take (BytesInj_drop h j) m

/-! ### The simulation -/

/-- `return` under `LowerRetX`: L0 ends the run with `_0`'s value `v` (at the bottom frame), and
R's `ret` ends the function with return registers related to `v` by `RetValX`.

Proof: `cases hlow`. `zero`: as `sim_ret`'s `k = 0` case (`retRegs_zero`, `stepBody_ret` with
the empty fold; `RetValX` holds vacuously as `Γ.retKind = 0`). `reg`: `retOps_spec` for the
instruction (`op`, `f`, `sw`, `kw` with `sw.toInt = src`, `kw.toNat = k`), `hat.head` and
`step_eq_stepBody_nil`; `return_inv hs h` (`p`, `ty'`, `v`, the final state); `ty' = ty` from
`hbody`, `hty`; `typedLoad_inv hsize` gives `bs0` with `s.mem.load p s0.size .one = .ok bs0`
and `ty.decode bs0 = some v`, `bs0.length = s0.size` (`Memory.load`'s length, or from
`readLocal_inj`'s `BytesInj` and `Ryo.Proofs.Inline.readFrame_length`); `hrel.opnd hp hsl hlive` and
`readLocal_inj hrel.frame.mem` give `bs1` read from `s0.off` with `BytesInj ι bs0 bs1`. Then
`retPartList_retRegs hps` (`prs`), `ret_fold` with `src := sw.toInt` (each part's read is
`readFrame_sub` of `bs1`, `hoff`, `hfit`), `stepBody_ret`, and `RetValX` from
`ret_fold`'s register bytes and `BytesInj_slice`. -/
theorem sim_retX {Γ : TermCtx} {c : Code} {s1 : RState} {ch : OpSem.Choice} {ι : Inj}
    {live : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {next : Nat} {i : Insn} (hlow : LowerRetX Γ .«return» [i]) (hat : TermAt c s1 next [i])
    (hrel : FnRel Γ.toStmtCtx ι live f s.mem s1) (hlive : live 0 = true)
    (hcont : f.cont = .bottom)
    (hinc : ∃ bs, s1.st.readFrame 16 c.argSize = .ok bs)
    (h : runOn (evalTerminator .«return») o s = (.ok (), s')) :
    ∃ v regs incoming, s'.final = some (.returned v) ∧
      R.step c s1 ch = .ok (.done (exit s1 (.ret regs incoming))) ∧ RetValX Γ ι v regs := by
  obtain ⟨hi, hs0⟩ := hat.head
  obtain ⟨incoming, hinc'⟩ := hinc
  obtain ⟨p, ty', v, g, s2, hp, hty', hload, -, -, hfin⟩ := return_inv hs h
  have hfinal : s'.final = some (.returned v) := by rw [hfin hcont]
  rw [step_eq_stepBody_nil hi hs0]
  cases hlow with
  | zero hro hk h0 =>
    obtain ⟨op, fo, sw, kw, rfl, hf, hsh, -, hkw⟩ := retOps_spec hro
    have hparts : retRegs kw.toNat true = .ok [] := by rw [hkw, h0]; exact retRegs_zero
    refine ⟨v, {}, incoming, hfinal, stepBody_ret hf hsh hparts rfl hinc', ?_⟩
    intro hne
    exact absurd (hk.symm.trans h0) hne
  | @reg _ _ _ ty s0 ps hro hk hty hsl hsize hoff hps hfit =>
    obtain ⟨op, fo, sw, kw, rfl, hf, hsh, hsrc, hkw⟩ := retOps_spec hro
    rw [← hbody, hty] at hty'
    obtain rfl := Option.some.inj hty'
    obtain ⟨bs0, hld, hdec⟩ := typedLoad_inv hsize hload
    have hr := hrel.opnd hp hsl hlive
    obtain ⟨bs1, hrf, hbi⟩ := readLocal_inj hrel.frame.mem hr hld
    have hlen0 : bs0.length = s0.size :=
      (BytesInj.length hbi).trans (Ryo.Proofs.Inline.readFrame_length hrf)
    obtain ⟨prs, hrr, hmap, hnd⟩ := retPartList_retRegs hps
    have hpart : ∀ pr ∈ prs, pr.1.off + pr.1.size ≤ s0.size := fun pr hpr =>
      hfit pr.1 (by rw [← hmap]; exact List.mem_map.mpr ⟨pr, hpr, rfl⟩)
    have hsub : ∀ pr ∈ prs, s1.st.readFrame (sw.toInt + pr.1.off) pr.1.size =
        .ok ((bs1.drop pr.1.off).take pr.1.size) := by
      intro pr hpr
      rw [hsrc, ← hoff]
      exact readFrame_sub hrf (hpart pr hpr)
    obtain ⟨regs, hfold, hregs⟩ := ret_fold (st := s1.st) (src := sw.toInt) hnd
      (fun pr hpr => ⟨_, hsub pr hpr⟩)
    have hparts : retRegs kw.toNat true = .ok prs := by rw [hkw]; exact hrr
    refine ⟨v, regs, incoming, hfinal, stepBody_ret hf hsh hparts hfold hinc', ?_⟩
    intro _ ty2 hty2
    rw [hty] at hty2
    obtain rfl := Option.some.inj hty2
    refine ⟨bs0, by rw [hsize, hlen0], hdec, ?_⟩
    intro prs' hprs' pr hpr
    rw [← hk, hrr] at hprs'
    obtain rfl := Except.ok.inj hprs'
    rw [hregs pr hpr _ (hsub pr hpr)]
    exact BytesInj_slice hbi _ _

/-- `Term.lean`'s `ret` rule is an instance of `LowerRetX`. -/
theorem lowerRetX_of_retOk {Γ : TermCtx} {i : Insn} (h : retOk Γ i = true) :
    LowerRetX Γ .«return» [i] := by
  obtain ⟨src, k, hro, hk, hcase⟩ := retOk_spec h
  rcases hcase with h0 | ⟨t, valid, s0, hl0, hsl0, hrp, hsz, hoff⟩
  · exact .zero hro hk h0
  · refine .reg (ps := [⟨false, t.size, 0⟩]) hro hk hl0 hsl0 (by rw [size?_int, hsz]) hoff
      (by simp [retPartList, hrp]) ?_
    intro p hp
    simp only [List.mem_singleton] at hp
    subst hp
    simp [hsz]

/-- A `return`'s `LowerTermX` is a `LowerRetX`. -/
theorem _root_.Ryo.Check.Lower.LowerTermX.retX_of
    {Γ : TermCtx} {next : Nat} {is : List Insn}
    (h : LowerTermX Γ next .«return» is) : LowerRetX Γ .«return» is := by
  rcases h with h | h | h
  · cases h with
    | ret hok => exact lowerRetX_of_retOk hok
  · cases h
  · exact h

end Ryo.Proofs.Lower
