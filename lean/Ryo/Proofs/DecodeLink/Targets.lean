/-
Ryo.Proofs.DecodeLink.Targets — the decoder's branch targets as instruction indices (aot.md §C2,
toward M3 `decode_sound`): `reducedOf` turns each target the decoder read as a byte position
into the index of the instruction there, and `posOf r t`, the position the decoder read
instruction `t` at, maps it back.

- `posOf r t`: `r.protos[t].pos` (as `reducedOf`'s `ipos[t]!`): the placement the shape lemmas
  call `pos` (`Ryo.Proofs.Shapes`: `pos t = tgt`), here in bytes; `pos32 r t` is its 32-bit
  form, and `pos32_eq` gives `pos32 r t = tgt` from `posOf r t = tgt.toNat`.
- `rustBinarySearch_ok`: the index `rustBinarySearch` finds holds the value searched for (the
  first-pass `ipos` lookups `reducedOf`'s `index` does).
- `opndMap f`, `thenMap f`: an operand's or a `then`'s targets mapped by `f`.
- `InsnOf pos p i`: instruction `i` is proto `p` with its targets replaced by indices that
  `pos` maps back to `p`'s byte targets: a handler call `handler p.op args t'` with
  `thenMap pos t' = t`, or a native `native op ops` with `op` the reduced form of `p.op` and
  `ops.map (opndMap pos) = p.ops`.
- `reducedOf_insns`: `reducedOf r pe = .ok d` gives one instruction per proto, each `InsnOf
  (posOf r)` of it. `decodeReduced_read`: `decodeReduced` is `reducedOf` of a successful `read`.
- Reading back: `opnds_target` (a native `jmp`'s `[.target b]` is `[.target t]` with
  `pos t = b`), `thenMap_branch`, `thenMap_table`, `thenMap_next`, `thenMap_trap`, and
  `opnds_plain` (operands without targets are unchanged).

So a branch item whose target is the 32-bit position `tgt` (what `thenSeq`/`insn` record as
`tgt.toNat`) becomes an instruction index `t` with `pos32 r t = tgt`, the shape lemmas'
`hpos`. That every byte target is an instruction's position is `reducedOf`'s own check (else
`index` fails); `rustBinarySearch` returning an index past the end (impossible, not proved
here) would only mean `posOf` reads the default `0`, still equal to the target.
-/
import Ryo.Vm.DecodeReduced

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R

theorem ebind_ok {ε α β : Type} {x : Except ε α} {f : α → Except ε β} {b : β}
    (h : (x >>= f) = .ok b) : ∃ a, x = .ok a ∧ f a = .ok b := by
  cases x with
  | error e => cases h
  | ok a => exact ⟨a, rfl, h⟩

theorem forIn_push {ε α β : Type} (R : α → β → Prop) (f : α → Array β → Except ε (ForInStep (Array β)))
    (hf : ∀ a acc r, f a acc = .ok r → ∃ b, r = .yield (acc.push b) ∧ R a b) :
    ∀ (l : List α) (acc res : Array β), forIn l acc f = .ok res →
      ∃ ext, res.toList = acc.toList ++ ext ∧ ext.length = l.length ∧
        ∀ i (h1 : i < l.length) (h2 : i < ext.length), R l[i] ext[i]
  | [], acc, res, h => by
    simp only [List.forIn_nil] at h; cases h; exact ⟨[], by simp, rfl, fun i h => absurd h (by simp)⟩
  | a :: l, acc, res, h => by
    simp only [List.forIn_cons] at h
    obtain ⟨r, h1, h2⟩ := ebind_ok h
    obtain ⟨b, rfl, hb⟩ := hf a acc r h1
    obtain ⟨ext, he, hl, hr⟩ := forIn_push R f hf l _ res h2
    refine ⟨b :: ext, by simp [he], by simp [hl], fun i h1 h2 => ?_⟩
    cases i with
    | zero => exact hb
    | succ i => exact hr i (by simpa using h1) (by simpa using h2)


theorem rustBinarySearch_ok {a : Array Nat} {x i : Nat} (h : rustBinarySearch a x = .ok i) :
    a[i]! = x := by
  unfold rustBinarySearch at h
  simp only [Id.run] at h
  split at h
  · cases h
  · have key : ∀ s : Nat × Nat, ((if (a[s.2]! == x) = true then pure (Except.ok s.2)
        else pure (Except.error (if a[s.2]! < x then s.2 + 1 else s.2))) : Id (Except Nat Nat)) =
          Except.ok i → a[i]! = x := by
      intro s hs
      split at hs
      · rename_i hv; cases hs; simpa using hv
      · cases hs
    exact key _ h

/-- An operand with its targets mapped by `f`. -/
def opndMap {T U : Type} (f : T → U) : Opnd T → Opnd U
  | .slot s => .slot s
  | .mem p k => .mem p k
  | .imm v => .imm v
  | .imm128 v => .imm128 v
  | .const k => .const k
  | .data d => .data d
  | .sym s => .sym s
  | .func x => .func x
  | .target t => .target (f t)
  | .neg n => .neg n
  | .targets ts => .targets (ts.map f)
  | .words w => .words w
  | .cases v ts => .cases v (ts.map f)

/-- A `then` with its targets mapped by `f`. -/
def thenMap {T U : Type} (f : T → U) : Then T → Then U
  | .next => .next
  | .branch n t => .branch n (f t)
  | .table ts => .table (ts.map f)
  | .trap => .trap

section
variable {ε : Type} {f : Nat → Except ε Nat} {g : Nat → Nat} (hg : ∀ b i, f b = .ok i → g i = b)
include hg

theorem mapM_ok : ∀ {ts ts' : List Nat}, ts.mapM f = .ok ts' → ts'.map g = ts
  | [], ts', h => by simp only [List.mapM_nil] at h; cases h; rfl
  | t :: ts, ts', h => by
    simp only [List.mapM_cons] at h
    obtain ⟨i, h1, h⟩ := ebind_ok h
    obtain ⟨is, h2, h⟩ := ebind_ok h
    cases h
    simp [hg _ _ h1, mapM_ok h2]

theorem mapTargets_ok {o o' : Opnd Nat} (h : o.mapTargets f = .ok o') : opndMap g o' = o := by
  cases o <;> simp only [Opnd.mapTargets, pure, Except.pure, Functor.map, Except.map] at h
  all_goals first
    | (cases h; rfl)
    | (split at h
       · cases h
       · rename_i v hv; cases h
         first
           | (simp only [opndMap]; rw [hg _ _ hv])
           | (simp only [opndMap]; rw [mapM_ok hg hv]))

theorem thenMapM_ok {t t' : Then Nat} (h : t.mapM f = .ok t') : thenMap g t' = t := by
  cases t <;> simp only [Then.mapM, pure, Except.pure, Functor.map, Except.map] at h
  all_goals first
    | (cases h; rfl)
    | (split at h
       · cases h
       · rename_i v hv; cases h
         first
           | (simp only [thenMap]; rw [hg _ _ hv])
           | (simp only [thenMap]; rw [mapM_ok hg hv]))

theorem opsMapM_ok {os os' : List (Opnd Nat)} (h : os.mapM (·.mapTargets f) = .ok os') :
    os'.map (opndMap g) = os := by
  induction os generalizing os' with
  | nil => simp only [List.mapM_nil] at h; cases h; rfl
  | cons o os ih =>
    simp only [List.mapM_cons] at h
    obtain ⟨o', h1, h⟩ := ebind_ok h
    obtain ⟨os'', h2, h⟩ := ebind_ok h
    cases h
    simp [mapTargets_ok hg h1, ih h2]

end

/-- The function position of instruction `t` of a read: where the decoder read it. -/
def posOf (r : ReadResult) (t : Nat) : Nat := (r.protos.map (·.pos))[t]!

/-- Instruction `i` is proto `p` with its targets as instruction indices, `pos` mapping them
back to the byte positions the decoder read. -/
def InsnOf (pos : Nat → Nat) (p : Proto) (i : Insn) : Prop :=
  match p.handler with
  | some (args, t) => ∃ t', i = .handler p.op args t' ∧ thenMap pos t' = t
  | none => ∃ op ops, Reduced.Opcode.ofFull p.op = some op ∧ i = .native op ops ∧
      ops.map (opndMap pos) = p.ops

theorem reducedOf_insns {r : ReadResult} {pe : Bool} {d : Decoded} (h : reducedOf r pe = .ok d) :
    d.insns.size = r.protos.size ∧
      ∀ k (hk : k < r.protos.size) (hk' : k < d.insns.size), InsnOf (posOf r) r.protos[k] d.insns[k] := by
  unfold reducedOf at h
  obtain ⟨insns, h1, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  have hidx : ∀ (at_ b i : Nat), (match rustBinarySearch (r.protos.map (·.pos)) b with
      | Except.ok i => pure i
      | Except.error _ => throw { at_ := at_, what := "target isn't an instruction" } :
        Except AsmError Nat) = .ok i → posOf r i = b := by
    intro at_ b i hi
    split at hi
    · rename_i j hj; cases hi; exact rustBinarySearch_ok hj
    · cases hi
  rw [← Array.forIn_toList] at h1
  have key := forIn_push (InsnOf (posOf r)) _ ?hf r.protos.toList #[] insns h1
  case hf =>
    intro p acc res hres
    simp only at hres
    unfold InsnOf
    split at hres
    · rename_i args t ht
      obtain ⟨t', h4, h5⟩ := ebind_ok hres
      cases h5
      exact ⟨_, rfl, ht ▸ ⟨t', rfl, thenMapM_ok (hidx p.pos) h4⟩⟩
    · rename_i hn
      obtain ⟨ops, h4, h5⟩ := ebind_ok hres
      split at h5
      · rename_i op hop
        cases h5
        refine ⟨_, rfl, ?_⟩
        rw [hn]
        exact ⟨op, ops, hop, rfl, opsMapM_ok (hidx p.pos) h4⟩
      · obtain ⟨_, h6, -⟩ := ebind_ok h5
        cases h6
  obtain ⟨ext, he, hl, hr⟩ := key
  simp only [List.nil_append] at he
  have hsz : insns.size = r.protos.size := by
    rw [← Array.length_toList, he, hl, Array.length_toList]
  refine ⟨hsz, fun k hk hk' => ?_⟩
  have := hr k (by simpa using hk) (by rw [hl]; simpa using hk)
  simp only [Array.getElem_toList] at this
  have e : insns[k] = ext[k]'(by rw [hl]; simpa using hk) := by
    simp only [← Array.getElem_toList, he]
  simp only [e]; exact this

/-- `posOf` in 32 bits: the shape lemmas' `pos`. -/
def pos32 (r : ReadResult) (t : Nat) : BitVec 32 := BitVec.ofNat 32 (posOf r t)

theorem pos32_eq {r : ReadResult} {t : Nat} {tgt : BitVec 32} (h : posOf r t = tgt.toNat) :
    pos32 r t = tgt := by
  simp [pos32, h]

/-- `decodeReduced` is `reducedOf` of a successful `read`. -/
theorem decodeReduced_read {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
    {callSites : Array Asm.CallSite} {dropped : Array Asm.DroppedStore} {scopes : Array Scope}
    {mode : Ryo.Obj.Mode} {d : Decoded}
    (h : decodeReduced code relocs rodata callSites dropped scopes mode = .ok d) :
    ∃ r c', (Vm.read rodata callSites dropped.toList scopes mode).run
        { code := code.data, pos := 0, fields := .relocs relocs } = .ok (r, c') ∧
      reducedOf r mode.pe = .ok d := by
  unfold decodeReduced decodeReducedWith at h
  obtain ⟨⟨r, c'⟩, h1, h2⟩ := ebind_ok h
  exact ⟨r, c', h1, h2⟩

/-! ### Reading targets back -/

theorem opndMap_target {pos : Nat → Nat} {o : Opnd Nat} {b : Nat} (h : opndMap pos o = .target b) :
    ∃ t, o = .target t ∧ pos t = b := by
  cases o <;> simp only [opndMap, reduceCtorEq] at h
  case target t => exact ⟨t, rfl, by injection h⟩

/-- An operand without targets is its own index form. -/
theorem opndMap_plain {pos : Nat → Nat} {o o' : Opnd Nat} (h : opndMap pos o' = o)
    (hn : o.targetsOf = []) : o' = o := by
  subst h
  cases o' <;> simp_all [opndMap, Opnd.targetsOf]

theorem opnds_plain {pos : Nat → Nat} : ∀ {ops ops' : List (Opnd Nat)},
    ops'.map (opndMap pos) = ops → (∀ o ∈ ops, o.targetsOf = []) → ops' = ops
  | [], [], _, _ => rfl
  | o :: ops, o' :: ops', h, hn => by
    simp only [List.map_cons, List.cons.injEq] at h
    rw [opndMap_plain h.1 (hn o (by simp)), opnds_plain h.2 (fun x hx => hn x (by simp [hx]))]
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h

/-- A native `jmp`'s target: the index whose position the decoder read. -/
theorem opnds_target {pos : Nat → Nat} {ops : List (Opnd Nat)} {b : Nat}
    (h : ops.map (opndMap pos) = [.target b]) : ∃ t, ops = [.target t] ∧ pos t = b := by
  match ops with
  | [] => simp at h
  | [o] =>
    simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at h
    obtain ⟨t, rfl, ht⟩ := opndMap_target h
    exact ⟨t, rfl, ht⟩
  | _ :: _ :: _ => simp at h

theorem thenMap_branch {pos : Nat → Nat} {t : Then Nat} {neg : Bool} {b : Nat}
    (h : thenMap pos t = .branch neg b) : ∃ i, t = .branch neg i ∧ pos i = b := by
  cases t <;> simp only [thenMap, reduceCtorEq, Then.branch.injEq] at h
  case branch n i => exact ⟨i, by rw [h.1], h.2⟩

theorem thenMap_table {pos : Nat → Nat} {t : Then Nat} {bs : List Nat}
    (h : thenMap pos t = .table bs) : ∃ ts, t = .table ts ∧ ts.map pos = bs := by
  cases t <;> simp only [thenMap, reduceCtorEq, Then.table.injEq] at h
  case table ts => exact ⟨ts, rfl, h⟩

theorem thenMap_next {pos : Nat → Nat} {t : Then Nat} (h : thenMap pos t = .next) : t = .next := by
  cases t <;> simp_all [thenMap]

theorem thenMap_trap {pos : Nat → Nat} {t : Then Nat} (h : thenMap pos t = .trap) : t = .trap := by
  cases t <;> simp_all [thenMap]

end Ryo.Proofs.DecodeLink
