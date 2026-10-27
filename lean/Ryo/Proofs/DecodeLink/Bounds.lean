/-
Ryo.Proofs.DecodeLink.Bounds — decoded code that the bounds check accepts satisfies
`FrameBounds` (`Ryo.Proofs.FrameBounds`), with `K` the highest end of its frame ranges
(`Decoded.frameTop`, `Ryo/Vm/DecodeReduced.lean`).

- `nativeWrites_eq`: the frame ranges the check reads with its own placement (`anyAddrs`) are
  `wranges f vals` for the values under any placement: a range's offset is a slot's and its
  length an immediate's, which `nativeVal` gives the same under every placement (`erase`
  forgets the addresses, the only values that depend on it).
- `frameBounds_of_boundsOk`: `boundsOk` gives `FrameBounds c c.d.frameTop`: each scope's range,
  native frame write, `arg` destination and `ret` source is one of `frameRanges`, which all start
  at or above `-F` and end at or below `frameTop` (`le_frameTop`).
- `decode_frameBounds`: an accepted `decodeBounded` is `decodeReducedWith`'s decoding, and it
  satisfies `FrameBounds` for `frameTop`, and so for every larger `K` up to `2 ^ 31`
  (`FrameBounds.mono`; the proofs' window is `[-F, 16 + argSize)`, so it needs
  `frameTop ≤ 16 + argSize`, a fact of the function entry, checked against the image elsewhere).

The run-time side, `fp + K ≤ 2 ^ 64` (`FrameBounds.window`), is an environment assumption
(lean/docs/assumptions.md, the frame lies in the address space).
-/
import Ryo.Proofs.FrameBounds
import Ryo.Vm.DecodeReduced

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeLink.Bounds

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.ScopeMem
  Ryo.Proofs.CacheMem Ryo.Proofs.FrameBounds

/-! ### The placement doesn't matter -/

/-- A value with its address forgotten (`anyAddrs`'s). -/
def erase : Val → Val
  | .addr _ => .addr default
  | v => v

theorem nativeVal_erase {ρ : R.Addrs} {k : OperandKind} {o : R.Opnd Nat} {v : Val}
    (h : R.nativeVal ρ k o = some v) : R.nativeVal anyAddrs k o = some (erase v) := by
  unfold R.nativeVal at h ⊢
  split at h <;> simp_all [erase, anyAddrs] <;>
    (obtain ⟨_, -, rfl⟩ := h; rfl)

theorem mapM_erase {ρ : R.Addrs} : ∀ (l : List (OperandInfo × R.Opnd Nat)) (vals : Operands),
    l.mapM (fun (i, o) => R.nativeVal ρ i.kind o) = some vals →
    l.mapM (fun (i, o) => R.nativeVal anyAddrs i.kind o) = some (vals.map erase)
  | [], vals, h => by cases h; rfl
  | (i, o) :: l, vals, h => by
    simp only [List.mapM_cons, bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at h
    obtain ⟨v, hv, vs, hvs, rfl⟩ := h
    simp [List.mapM_cons, nativeVal_erase hv, mapM_erase l vs hvs]

theorem find_zip_erase (p : OperandInfo → Bool) : ∀ (l1 : List OperandInfo) (l2 : Operands),
    ((l1.zip (l2.map erase)).find? (fun q => p q.1)).map (·.2) =
      (((l1.zip l2).find? (fun q => p q.1)).map (·.2)).map erase
  | [], _ => rfl
  | _ :: _, [] => rfl
  | a :: l1, v :: l2 => by
    simp only [List.map_cons, List.zip_cons_cons, List.find?_cons]
    cases p a
    · exact find_zip_erase p l1 l2
    · rfl

theorem opndVal_erase (info : OpInfo) (vals : Operands) (n : String) :
    opndVal info (vals.map erase) n = (opndVal info vals n).map erase :=
  find_zip_erase (fun i => i.name == n) info.operands vals

theorem eval_erase (val : String → Option Val) (e : Extent) :
    e.eval (fun n => (val n).map erase) = e.eval val := by
  cases e with
  | bytes => rfl
  | opnd x =>
    simp only [Extent.eval]
    cases val x with
    | none => rfl
    | some v => cases v <;> rfl
  | mul x y =>
    simp only [Extent.eval]
    cases val x with
    | none => cases val y <;> rfl
    | some v => cases val y with
      | none => cases v <;> rfl
      | some w => cases v <;> cases w <;> rfl
  | slotVal => rfl
  | cases c n =>
    simp only [Extent.eval]
    cases val c with
    | none => rfl
    | some v => cases v <;> rfl

theorem range_erase (val : String → Option Val) (a : Access) :
    a.range (fun n => (val n).map erase) = a.range val := by
  unfold Access.range
  rw [eval_erase]
  show ((val a.opnd).map erase |>.bind Val.slotOff) >>= _ = _
  cases val a.opnd with
  | none => rfl
  | some v => cases v <;> rfl

/-- The check's write ranges are `wranges` under any placement. -/
theorem nativeWrites_eq {ρ : R.Addrs} {f : Full.Opcode} {ops : List (R.Opnd Nat)}
    {vals : Operands} (h : nativeVals ρ f ops = some vals) : wranges f vals = nativeWrites f ops := by
  unfold nativeVals at h
  split at h
  · rename_i hlen
    unfold nativeWrites wranges
    rw [ite_eq_left hlen, mapM_erase _ _ h]
    simp only
    cases footprint f with
    | none => rfl
    | some fp =>
      simp only [Footprint.writeRanges]
      rw [show opndVal f.info (vals.map erase) = fun n => (opndVal f.info vals n).map erase from
        funext (opndVal_erase f.info vals)]
      simp only [range_erase]
  · cases h

/-! ### Membership in the frame ranges -/

/-- `frameTop`'s step. -/
def topStep (t : Int) (r : Int × Nat) : Int := max t (r.1 + (r.2 : Int))

theorem le_foldl_max : ∀ (l : List (Int × Nat)) (t : Int),
    t ≤ l.foldl topStep t ∧ ∀ r ∈ l, r.1 + (r.2 : Int) ≤ l.foldl topStep t
  | [], t => ⟨Int.le_refl t, fun _ h => by cases h⟩
  | r :: l, t => by
    obtain ⟨h1, h2⟩ := le_foldl_max l (topStep t r)
    have : t ≤ topStep t r ∧ r.1 + (r.2 : Int) ≤ topStep t r := by unfold topStep; omega
    refine ⟨by simp only [List.foldl_cons]; omega, fun q hq => ?_⟩
    simp only [List.foldl_cons]
    rcases List.mem_cons.1 hq with rfl | hq
    · omega
    · exact h2 q hq

theorem le_frameTop {d : R.Decoded} {r : Int × Nat} (h : r ∈ d.frameRanges) :
    r.1 + r.2 ≤ d.frameTop :=
  (le_foldl_max d.frameRanges 0).2 r h

theorem frameTop_nonneg (d : R.Decoded) : 0 ≤ d.frameTop :=
  (le_foldl_max d.frameRanges 0).1

theorem mem_frameRanges_insn {d : R.Decoded} {k : Nat} {i : R.Insn} {r : Int × Nat}
    (hi : d.insns[k]? = some i) (hr : r ∈ i.frameRanges) : r ∈ d.frameRanges := by
  unfold R.Decoded.frameRanges
  exact List.mem_append_right _ (List.mem_flatMap.2 ⟨i, Array.mem_toList_iff.2
    (Array.mem_of_getElem? hi), hr⟩)

theorem mem_frameRanges_scope {c : R.Code} {k : Nat} {sc : R.Scope} (h : sc ∈ c.scopesAt k) :
    (sc.frameOffset.toInt, sc.size) ∈ c.d.frameRanges := by
  unfold R.Code.scopesAt at h
  obtain ⟨p, hp, rfl⟩ := List.mem_map.1 h
  unfold R.Decoded.frameRanges
  exact List.mem_append_left _ (List.mem_map.2 ⟨p, (List.mem_filter.1 hp).1, rfl⟩)

/-! ### `FrameBounds` -/

/-- What `boundsOk` says of the frame ranges. -/
theorem boundsOk_spec {d : R.Decoded} (h : d.boundsOk = true) :
    (d.frameSize : Int) ≤ 2 ^ 31 ∧ d.frameTop ≤ 2 ^ 31 ∧
      ∀ r ∈ d.frameRanges, -(d.frameSize : Int) ≤ r.1 ∧ r.1 + r.2 ≤ d.frameTop := by
  simp only [R.Decoded.boundsOk, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true] at h
  obtain ⟨⟨hF, hK⟩, hall⟩ := h
  exact ⟨by omega, hK, fun r hr => ⟨hall r hr, le_frameTop hr⟩⟩

theorem frameRanges_native {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    (hf : op.full = some f) : (R.Insn.native op ops).frameRanges = nativeRanges f ops := by
  simp only [R.Insn.frameRanges, hf, Option.map_some, Option.getD_some]

theorem frameBounds_of_boundsOk {c : R.Code} (h : c.d.boundsOk = true) :
    FrameBounds c c.d.frameTop := by
  obtain ⟨hF, hK, hin⟩ := boundsOk_spec h
  refine ⟨hF, hK, fun k sc hsc => hin _ (mem_frameRanges_scope hsc), ?_, ?_, ?_⟩
  · intro k op ops f vals hi hf hv r hr
    rw [nativeWrites_eq hv] at hr
    refine hin r (mem_frameRanges_insn hi ?_)
    rw [frameRanges_native hf, nativeRanges]
    exact List.mem_append_left _ hr
  · intro k op d r f a hi hf hsh ha
    refine hin (d.toInt, a.size) (mem_frameRanges_insn hi ?_)
    rw [frameRanges_native hf, nativeRanges, ite_eq_left hsh, argRange]
    simp only [ha]
    exact List.mem_append_right _ (List.mem_singleton_self _)
  · intro k op src kk f hi hf hsh
    refine hin (src.toInt, 16) (mem_frameRanges_insn hi ?_)
    rw [frameRanges_native hf, nativeRanges, ite_eq_right (by rw [hsh]; decide), ite_eq_left hsh, retRange]
    exact List.mem_append_right _ (List.mem_singleton_self _)

/-- `FrameBounds` for a larger end (up to `2 ^ 31`). -/
theorem FrameBounds.mono {c : R.Code} {K K' : Int} (hb : FrameBounds c K) (hk : K ≤ K')
    (hk' : K' ≤ 2 ^ 31) : FrameBounds c K' := by
  refine ⟨hb.F_le, hk', fun k sc hsc => ?_, fun k op ops f vals hi hf hv r hr => ?_,
    fun k op d r f a hi hf hsh ha => ?_, fun k op src kk f hi hf hsh => ?_⟩
  · have := hb.scopes k sc hsc; omega
  · have := hb.writes k op ops f vals hi hf hv r hr; omega
  · have := hb.arg k op d r f a hi hf hsh ha; omega
  · have := hb.ret k op src kk f hi hf hsh; omega

theorem decodeBounded_ok {code : ByteArray} {fields : Ryo.X86.Fields} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Mode} {d : R.Decoded}
    (h : decodeBounded code fields rodata callSites dropped scopes mode = .ok d) :
    decodeReducedWith code fields rodata callSites dropped scopes mode = .ok d ∧
      d.boundsOk = true := by
  unfold decodeBounded at h
  cases hd : decodeReducedWith code fields rodata callSites dropped scopes mode with
  | error e => simp [hd, bind, Except.bind] at h
  | ok d' =>
    simp only [hd, bind, Except.bind] at h
    split at h
    · cases h; exact ⟨rfl, by assumption⟩
    · cases h

/-- An accepted bounded decoding: `decodeReducedWith`'s, and `FrameBounds` for `frameTop` of
every code whose decoding it is. -/
theorem decode_frameBounds {code : ByteArray} {fields : Ryo.X86.Fields} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Mode} {d : R.Decoded}
    (h : decodeBounded code fields rodata callSites dropped scopes mode = .ok d)
    {c : R.Code} (hc : c.d = d) :
    decodeReducedWith code fields rodata callSites dropped scopes mode = .ok d ∧
      FrameBounds c d.frameTop := by
  obtain ⟨hd, hb⟩ := decodeBounded_ok h
  subst hc
  exact ⟨hd, frameBounds_of_boundsOk hb⟩

end Ryo.Proofs.DecodeLink.Bounds
