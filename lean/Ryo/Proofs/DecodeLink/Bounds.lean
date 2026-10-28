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
  | .cases _ n => .cases default n
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

/-- `wranges` doesn't see the addresses. -/
theorem wranges_erase (f : Full.Opcode) (vals : Operands) :
    wranges f (vals.map erase) = wranges f vals := by
  unfold wranges
  cases footprint f with
  | none => rfl
  | some fp =>
    simp only [Footprint.writeRanges]
    rw [show opndVal f.info (vals.map erase) = fun n => (opndVal f.info vals n).map erase from
      funext (opndVal_erase f.info vals)]
    simp only [range_erase]

theorem regAddr_erase {ρ : R.Addrs} {args : List R.Arg} {r : Nat} {ok : R.Arg → Bool} {v : Val}
    (h : R.regAddr ρ args r ok = some v) : R.regAddr anyAddrs args r ok = some (erase v) := by
  unfold R.regAddr at h ⊢
  cases ha : args[r]? with
  | none => simp [ha] at h
  | some a =>
    cases hok : ok a <;> simp [ha, hok, bind, Option.bind_eq_some_iff] at h ⊢
    obtain ⟨p, -, rfl⟩ := h
    simp [anyAddrs, erase]

theorem unpackOpnd_erase {ρ : R.Addrs} {args : List R.Arg} {k : OperandKind} {loc : Asm.Loc}
    {v : Val} (h : R.unpackOpnd ρ args k loc = some v) :
    R.unpackOpnd anyAddrs args k loc = some (erase v) := by
  by_cases h0 : loc.count = 0
  · cases k
    case list e => cases e <;> simp_all [R.unpackOpnd, pure] <;> subst h <;> rfl
    all_goals simp_all [R.unpackOpnd, pure] <;> subst h <;> rfl
  · cases k with
    | const | abs | sym =>
      simp only [R.unpackOpnd, h0, beq_iff_eq, ↓reduceIte] at h ⊢
      exact regAddr_erase h
    | list e =>
      cases e <;> simp only [R.unpackOpnd, h0, beq_iff_eq, ↓reduceIte] at h ⊢
      all_goals (try split at h) <;> simp_all [bind, pure, Option.bind_eq_some_iff, anyAddrs]
      all_goals first
        | (obtain ⟨a, -, rfl⟩ := h; rfl)
        | (cases v <;> simp_all [erase])
    | _ =>
      simp only [R.unpackOpnd, h0, beq_iff_eq, ↓reduceIte] at h ⊢
      all_goals simp_all [bind, pure, Option.bind_eq_some_iff]
      all_goals (cases v <;> simp_all [erase])

theorem mapM_unpack_erase {ρ : R.Addrs} {args : List R.Arg} {locs : List Asm.Loc} :
    ∀ (l : List (OperandInfo × Nat)) (vals : Operands),
    l.mapM (fun x => R.unpackOpnd ρ args x.1.kind (locs.getD x.2 default)) = some vals →
    l.mapM (fun x => R.unpackOpnd anyAddrs args x.1.kind (locs.getD x.2 default)) =
      some (vals.map erase)
  | [], vals, h => by cases h; rfl
  | (o, i) :: l, vals, h => by
    simp only [List.mapM_cons, bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at h
    obtain ⟨v, hv, vs, hvs, rfl⟩ := h
    simp only [List.mapM_cons, unpackOpnd_erase hv, mapM_unpack_erase l vs hvs]
    rfl

/-- The operands a handler unpacks under any placement, with their addresses forgotten. -/
theorem unpack_erase {ρ : R.Addrs} {h : Full.Opcode} {mode : Ryo.Obj.Mode} {args : List R.Arg}
    {vals : Operands} (hu : R.unpack ρ h mode args = some vals) :
    R.unpack anyAddrs h mode args = some (vals.map erase) := by
  unfold R.unpack at hu ⊢
  revert hu
  cases h.layout mode.fpArg mode.pe with
  | none => intro hu; cases hu
  | some l =>
    intro hu
    simp only [Option.bind_some, bind] at hu ⊢
    by_cases h1 : (args.length != l.regs) = true
    · simp [h1] at hu
    · by_cases h2 : (mode.fpArg && args[0]? != some .fp) = true
      · simp [h2] at hu
      · by_cases h3 : (h.info.shape == .lpad && args[l.first - 1]? != some .exception) = true
        · simp [h3] at hu
        · simp only [h1, h2, h3, Bool.false_eq_true, ↓reduceIte] at hu ⊢
          generalize h.info.operands.zipIdx = L at hu ⊢
          exact mapM_unpack_erase _ _ hu

/-- The check's handler writes are `wranges` under any placement. -/
theorem handlerWrites_eq {ρ : R.Addrs} {h : Full.Opcode} {mode : Ryo.Obj.Mode} {args : List R.Arg}
    {vals : Operands} (hu : R.unpack ρ h mode args = some vals) :
    wranges h vals = handlerWrites mode h args := by
  rw [← wranges_erase h vals]
  unfold handlerWrites wranges
  rw [unpack_erase hu]
  cases footprint h <;> rfl

/-- `retRegs`' parts are `retParts`'. -/
theorem retRegs_fst {k : Nat} {parts : List (RetPart × R.Reg)}
    (h : R.retRegs k false = .ok parts) :
    ∃ a b, retParts k false = some (a, b) ∧ ∀ q ∈ parts, q.1 ∈ [a, b].filterMap id := by
  unfold R.retRegs at h
  cases hk : retParts k false with
  | none => simp [hk, illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some ab =>
    obtain ⟨a, b⟩ := ab
    simp only [hk, pure, Except.pure, Except.ok.injEq] at h
    subst h
    refine ⟨a, b, rfl, ?_⟩
    cases a with
    | none => cases b with
      | none => simp
      | some pb => cases hx : pb.xmm <;> simp [hx]
    | some pa => cases b with
      | none => cases hx : pa.xmm <;> simp [hx]
      | some pb => cases hx : pa.xmm <;> cases hy : pb.xmm <;> simp [hx, hy]

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

theorem le_frameTop {d : R.Decoded} {mode : Ryo.Obj.Mode} {r : Int × Nat} (h : r ∈ d.frameRanges mode) :
    r.1 + r.2 ≤ d.frameTop mode :=
  (le_foldl_max (d.frameRanges mode) 0).2 r h

theorem frameTop_nonneg (d : R.Decoded) (mode : Ryo.Obj.Mode) : 0 ≤ d.frameTop mode :=
  (le_foldl_max (d.frameRanges mode) 0).1

theorem mem_frameRanges_insn {d : R.Decoded} {mode : Ryo.Obj.Mode} {k : Nat} {i : R.Insn}
    {r : Int × Nat} (hi : d.insns[k]? = some i) (hr : r ∈ i.frameRanges mode) :
    r ∈ d.frameRanges mode := by
  unfold R.Decoded.frameRanges
  exact List.mem_append_right _ (List.mem_flatMap.2 ⟨i, Array.mem_toList_iff.2
    (Array.mem_of_getElem? hi), hr⟩)

theorem mem_frameRanges_scope {c : R.Code} {mode : Ryo.Obj.Mode} {k : Nat} {sc : R.Scope}
    (h : sc ∈ c.scopesAt k) : (sc.frameOffset.toInt, sc.size) ∈ c.d.frameRanges mode := by
  unfold R.Code.scopesAt at h
  obtain ⟨p, hp, rfl⟩ := List.mem_map.1 h
  unfold R.Decoded.frameRanges
  exact List.mem_append_left _ (List.mem_map.2 ⟨p, (List.mem_filter.1 hp).1, rfl⟩)

/-! ### `FrameBounds` -/

/-- What `boundsOk` says of the frame ranges, the writes and the `arg` destinations. -/
theorem boundsOk_spec {d : R.Decoded} {mode : Ryo.Obj.Mode} (h : d.boundsOk mode = true) :
    (d.frameSize : Int) ≤ 2 ^ 31 ∧ d.frameTop mode ≤ 2 ^ 31 ∧
      (∀ r ∈ d.frameRanges mode, -(d.frameSize : Int) ≤ r.1 ∧
        r.1 + r.2 ≤ d.frameTop mode) ∧
      ∀ (k : Nat) (i : R.Insn), d.insns[k]? = some i →
        (∀ r ∈ i.writeRanges mode, OffLink r) ∧
        ∀ r ∈ i.argRanges, r.1 + r.2 ≤ 0 := by
  simp only [R.Decoded.boundsOk, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true] at h
  obtain ⟨⟨⟨hF, hK⟩, hall⟩, hw⟩ := h
  have hlo : -(d.frameSize : Int) ≤ d.frameLo mode := by
    unfold R.Decoded.frameLo; omega
  refine ⟨by omega, hK, fun r hr => ⟨Int.le_trans hlo (hall r hr), le_frameTop hr⟩, fun k i hi => ?_⟩
  obtain ⟨h1, h2⟩ := hw i (Array.mem_toList_iff.2 (Array.mem_of_getElem? hi))
  exact ⟨fun r hr => offLink_iff.1 (h1 r hr), h2⟩

theorem frameRanges_native {mode : Ryo.Obj.Mode} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} (hf : op.full = some f) :
    (R.Insn.native op ops).frameRanges mode = nativeRanges f ops := by
  simp only [R.Insn.frameRanges, hf, Option.map_some, Option.getD_some]

theorem writeRanges_native {mode : Ryo.Obj.Mode} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)}
    {f : Full.Opcode} (hf : op.full = some f) :
    (R.Insn.native op ops).writeRanges mode =
      nativeWrites f ops ++ (if f.info.shape = .call then resultParts ops else []) := by
  simp only [R.Insn.writeRanges, hf, Option.map_some, Option.getD_some]

theorem frameBounds_of_boundsOk {c : R.Code} (h : c.d.boundsOk c.mode = true) :
    FrameBounds c (c.d.frameTop c.mode) := by
  obtain ⟨hF, hK, hin, hlk⟩ := boundsOk_spec h
  refine ⟨hF, hK, fun k sc hsc => hin _ (mem_frameRanges_scope hsc), ?_, ?_, ?_, ?_, ?_, ?_, ?_,
    ?_, ?_⟩
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
  · intro k h args t vals hi hu r hr
    rw [handlerWrites_eq hu] at hr
    exact hin r (mem_frameRanges_insn hi hr)
  · intro k op d fo kk ws f hi hf hsh
    refine hin (d.toInt, 16) (mem_frameRanges_insn hi ?_)
    rw [frameRanges_native hf, nativeRanges, ite_eq_right (by rw [hsh]; decide),
      ite_eq_right (by rw [hsh]; decide), ite_eq_left hsh, resultRange]
    exact List.mem_append_right _ (List.mem_singleton_self _)
  · intro k op ops f vals hi hf hv r hr
    rw [nativeWrites_eq hv] at hr
    refine (hlk k _ hi).1 r ?_
    rw [writeRanges_native hf]
    exact List.mem_append_left _ hr
  · intro k h args t vals hi hu r hr
    rw [handlerWrites_eq hu] at hr
    exact (hlk k _ hi).1 r hr
  · intro k op d fo kk ws f hi hf hsh parts hp q hq
    refine (hlk k _ hi).1 _ ?_
    rw [writeRanges_native hf, ite_eq_left hsh]
    refine List.mem_append_right _ ?_
    obtain ⟨a, b, hab, hmem⟩ := retRegs_fst hp
    simp only [resultParts, hab]
    exact List.mem_map.2 ⟨q.1, hmem q hq, rfl⟩
  · intro k op d r f a hi hf hsh ha
    refine (hlk k _ hi).2 (d.toInt, a.size) ?_
    simp only [R.Insn.argRanges, hf, Option.map_some, Option.getD_some, ite_eq_left hsh, argRange, ha]
    exact List.mem_singleton_self _

/-- `FrameBounds` for a larger end (up to `2 ^ 31`). -/
theorem FrameBounds.mono {c : R.Code} {K K' : Int} (hb : FrameBounds c K) (hk : K ≤ K')
    (hk' : K' ≤ 2 ^ 31) : FrameBounds c K' := by
  refine ⟨hb.F_le, hk', fun k sc hsc => ?_, fun k op ops f vals hi hf hv r hr => ?_,
    fun k op d r f a hi hf hsh ha => ?_, fun k op src kk f hi hf hsh => ?_,
    fun k h args t vals hi hu r hr => ?_, fun k op d fo kk ws f hi hf hsh => ?_,
    hb.writesOff, hb.handlerOff, hb.resultOff, hb.argBelow⟩
  · have := hb.scopes k sc hsc; omega
  · have := hb.writes k op ops f vals hi hf hv r hr; omega
  · have := hb.arg k op d r f a hi hf hsh ha; omega
  · have := hb.ret k op src kk f hi hf hsh; omega
  · have := hb.handler k h args t vals hi hu r hr; omega
  · have := hb.result k op d fo kk ws f hi hf hsh; omega

theorem decodeBounded_ok {code : ByteArray} {fields : Ryo.X86.Fields} {rodata : ByteArray}
    {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
    {mode : Mode} {d : R.Decoded}
    (h : decodeBounded code fields rodata callSites dropped scopes mode = .ok d) :
    decodeReducedWith code fields rodata callSites dropped scopes mode = .ok d ∧
      d.boundsOk mode = true := by
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
    {c : R.Code} (hc : c.d = d) (hm : c.mode = mode) :
    decodeReducedWith code fields rodata callSites dropped scopes mode = .ok d ∧
      FrameBounds c (d.frameTop mode) := by
  obtain ⟨hd, hb⟩ := decodeBounded_ok h
  subst hc
  subst hm
  exact ⟨hd, frameBounds_of_boundsOk hb⟩

end Ryo.Proofs.DecodeLink.Bounds
