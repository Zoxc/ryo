/-
Ryo.Proofs.DeadStore.PtrLive — discharging `KeptPtrLive` (Items.lean's pointer premise).

Among the inline classes only `load` reads memory through a non-`rbp` base: its sequence is
`ld .q rax [rbp + p]; ld w rax [rax + k]; st w rax [rbp + d]` (`Asm.sequence`), and the pointer
`ld` reads `wbytes w` bytes at the pointer in slot `p` plus `k`. A successful R step of the load
reads them from a live allocation (`OpSem.State.load`, `load_ok`); `load_ptr_live` extracts that
from `sound_load`'s proof.

Caveat on the state: the load runs after `pc`'s scopes (`AfterScopes`), so the allocation is live
in the state *after* the scopes, `s1.st`, not `s.st` (an `Escape` at `pc` creates the allocation
the pointer may point into). `keptPtrLive_of_step` is therefore stated for `s1.st`, and
`keptPtrApart_of_live` (Items.lean) should take `KeptPtrLive S.ctx s1.st kept y` with `FrameOwn`
and `P`'s privacy at `s1` (`keptPtrApart_after_scopes` below states what that needs).

- `load_ptr_live` (proved): the pointer `ld`'s bytes lie in a live allocation.
- (formerly open) `kept_ptr_reads` (the shape of the kept items' non-`rbp` reads at
  an inline `pc`: only `load`'s pointer `ld`, its base holding the slot's pointer bytes along the
  run), `sep_after_scopes` (`FrameOwn` and `P`'s privacy after the scopes),
  `keptPtrLive_of_step` (the assembly).
-/
import Ryo.Proofs.Cache
import Ryo.Proofs.Inline.Mem
import Ryo.Proofs.CacheMem
import Ryo.Proofs.DeadStore.Items
import Ryo.Proofs.DeadStore.RStep
import Ryo.Proofs.DecodeLink.Read

set_option linter.constructorNameAsVariable false
set_option linter.deprecated false

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R Ryo.Proofs.Inline Ryo.Proofs.RegCache
  Ryo.Proofs.DecodeSound Ryo.Proofs.CacheMem

/-- A successful `load` step reads the pointer `ld`'s bytes from a live allocation: with `Rel`,
the pointer is the x86 value of slot `p`'s 8 bytes, and every byte `j < wbytes w` at it plus `k`
is in the allocation. -/
theorem load_ptr_live (w : W) {ρ : R.Addrs} {op : Full.Opcode} {ops : List (R.Opnd Nat)}
    {vals : Operands} {st st' : OpSem.State} {ctl : Control} {ch : OpSem.Choice}
    {x : Ryo.X86.State} (hs : shapeOk op (.load w) = true) (hv : nativeVals ρ op ops = some vals)
    (hsem : opSem op vals st ch = .ok (ctl, st')) (hr : Rel st x) :
    ∀ pp k, ops[1]? = some (.mem pp k) → ∃ id a, st.mem.get? id = some a ∧ a.live = true ∧
      ∀ j < wbytes w, (BitVec.ofNat 64 (leDecode (bytesAt x.mem (fpAddr x pp.toInt) 8)) +
        k.signExtend 64 + BitVec.ofNat 64 j - BitVec.ofNat 64 a.addr).toNat < a.size := by
  intro pp' k' hop
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  simp only [classHandler, classOperands] at hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  obtain ⟨pp, k, rfl, rfl⟩ := nv_mem.1 h1
  simp only [List.getElem?_cons_succ, List.getElem?_cons_zero, Option.some.injEq,
    R.Opnd.mem.injEq] at hop
  obtain ⟨e1, e2⟩ := hop
  rw [← e1, ← e2]
  have hty := (tyName_parse w).1
  obtain ⟨bp, q, bs, hrp, hq, hl, _, _⟩ := opSem_load hh hty ho hsem
  have hbp := toInt_bounds pp
  have hqa := asPtr_rel (readFrame_rel hr hrp (by omega) (by omega)) hq
  have hn0 : wbytes w ≠ 0 := by cases w <;> decide
  obtain ⟨id, a, hg, hlv, ha1, ha2, _⟩ := load_ok hn0 hl
  refine ⟨id, a, hg, hlv, fun j hj => ?_⟩
  have hb : BitVec.ofNat 64 (q.wrappingOffset k.toInt).addr =
      BitVec.ofNat 64 (leDecode (bytesAt x.mem (fpAddr x pp.toInt) 8)) + k.signExtend 64 := by
    rw [wrappingOffset_bv, hqa, ← sext_eq]
  rw [← hb, ← BitVec.ofNat_add,
    show (q.wrappingOffset k.toInt).addr + j = a.addr + ((q.wrappingOffset k.toInt).addr - a.addr + j)
      by omega, ofNat_add_sub, BitVec.toNat_ofNat]
  simp only [Allocation.size] at ha2 ⊢
  exact Nat.lt_of_le_of_lt (Nat.mod_le _ _) (by omega)

/-! ### The decoder's items at `k` -/

open Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink in

/-- `reducedOf`'s `items`: the protos'. -/
theorem reducedOf_items {r : ReadResult} {pe : Bool} {d : Decoded}
    (h : reducedOf r pe = .ok d) : d.items = r.protos.map (·.items) := by
  unfold reducedOf at h
  obtain ⟨insns, -, h2⟩ := ebind_ok h
  obtain ⟨head, -, h3⟩ := ebind_ok h2
  cases h3
  rfl

section
open Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink
variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- The decoder's items at `k` are proto `k`'s. -/
theorem items_at (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k : Nat}
    (hk : k < S.r.protos.size) : S.c.d.items[k]? = some S.r.protos[k].items := by
  simp [reducedOf_items hD.reduced, hk]

/-- Iteration `k` of the decoder, with the items at `k`: an `empty` one (a dropped store first,
read by `inlineInsn` with `S.cache k`), or a `main` one whose body is a `ProtoRead` with the
cache `S.used k` (for an inline instruction, its `.inline` case: the `inlineInsn` run that
`link_inline_drop` reads). -/
theorem iter_items (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k : Nat}
    (hk : k < S.r.protos.size) :
    (∃ (d : DroppedStore) (dr : List DroppedStore) (p : Nat) (q : Proto) (c' : Cursor)
        (cache' : Cache) (dr' : List DroppedStore), S.dr k = d :: dr ∧ d.at_ = p ∧
        p = S.start k ∧ (S.r.protos[k] = { q with pos := p } ∨
          S.r.protos[k] = S.fixResume { q with pos := p }) ∧
        (inlineInsn (S.cache k) (d :: dr) true).run (atPos S.body p) =
          .ok (some (q, cache', dr'), c') ∧
        S.c.d.items[k]? = some q.items) ∨
      ∃ (fr : Vm.Frame) (p1 p2 : Nat) (counter : Option (Nat × Nat)) (q : Proto) (c' : Cursor)
        (cache' : Cache) (dr' : List DroppedStore),
        (S.r.protos[k] = { q with pos := p1, counter } ∨
          S.r.protos[k] = S.fixResume { q with pos := p1, counter }) ∧
        ProtoRead fr S.ro true S.body p2 (S.used k) (S.dr k) (S.args k) q c' cache' dr' ∧
        S.c.d.items[k]? = some q.items := by
  obtain ⟨fr, q0, p', ca', dr0', hfm, hpq, hit, -⟩ := hD.iterAt k (by simpa using hk)
  have hpq' : S.r.protos[k] = q0 ∨ S.r.protos[k] = S.fixResume q0 := by simpa using hpq
  have hit0 : S.c.d.items[k]? = some q0.items := by
    rw [items_at hD hk]
    rcases hpq' with h | h
    · rw [h]
    · rw [h, (S.fixResume_keep q0).2.2.2.2.2.2]
  clear hpq
  revert hpq' hit0
  generalize hdr : S.dr k = drk at hit
  cases hit with
  | empty hd hr =>
    intro hpq' hit0
    exact .inl ⟨_, _, _, _, _, _, _, rfl, hd, rfl, hpq', hr, hit0⟩
  | @main p1 p2 _ _ _ _ _ counter q c' hpad hctr hpr hnop =>
    intro hpq' hit0
    subst hdr
    have hp1 : posOf S.r k = p1 := by
      rw [posOf_eq hk]
      rcases hpq' with h | h
      · simp [h]
      · simp [h, (S.fixResume_keep _).2.2.1]
    have e : S.used k = (if (some S.targets).any (sortedContains · (posOf S.r k)) then
        ({ pe := fr.mode.pe } : Cache) else S.cache k) := by
      rw [hfm]; simp [Setup.used, Option.any]
    rw [← hp1, ← e] at hpr
    exact .inr ⟨fr, _, _, _, _, _, _, _, hpq', hpr, hit0⟩

end

/-! ### Only an inline read has items -/

open Ryo.Proofs.DecodeLink in
/-- `argInsn` builds its proto without items (`DecodeLink.argInsn_read`'s shape). -/
theorem argInsn_items {mode : Ryo.Obj.Mode} {c c' : Cursor} {q : Proto}
    (h : (argInsn mode).run c = .ok (some q, c')) : q.items = [] := by
  obtain ⟨_, _, rfl, -⟩ := argInsn_read h
  rfl

-- Peels a successful run `h` of a `do` block (as `DecodeLink`'s proofs do, on the hypothesis
-- only): binds (`bind_ok`), branches (`split at h`), `let`s; then closes each leaf: a `pure` of a
-- proto literal (items `[]` by default) or of `none`, or an error.
set_option hygiene false in
macro "items_walk" : tactic => `(tactic| (
  repeat' (first
    | (obtain ⟨_, _, _, h⟩ := Ryo.Proofs.DecodeLink.bind_ok h)
    | (split at h)
    | (dsimp only at h))
  all_goals first
    | exact (Ryo.Proofs.DecodeLink.err_ok h).elim
    | (obtain ⟨e, -⟩ := Ryo.Proofs.DecodeLink.pure_ok h; cases e; rfl)
    | (obtain ⟨e, -⟩ := Ryo.Proofs.DecodeLink.pure_ok h; cases e)
    | (obtain ⟨e, -⟩ := Ryo.Proofs.DecodeLink.pure_ok h; subst e; rfl)))

/-- `callInsn` builds its proto without items (`Proto.items` defaults to `[]`; only `inlineInsn`'s
exact pass sets it). -/
theorem callInsn_items {fr : Vm.Frame} {dr : List DroppedStore} {c c' : Cursor} {q : Proto}
    (h : (callInsn fr dr).run c = .ok (some q, c')) : q.items = [] := by
  unfold callInsn at h
  items_walk

theorem denseSwitch_items {fr : Vm.Frame} {c c' : Cursor} {q : Proto}
    (h : (denseSwitch fr).run c = .ok (some q, c')) : q.items = [] := by
  unfold denseSwitch at h
  items_walk

/-- From `DecodeLink.insnCore_read` (which already walks `insnCore`): every shape `InsnRead`
lists is a proto literal (items `[]`), or a dense switch's (`denseSwitch_items`). -/
theorem insnCore_items {fr : Vm.Frame} {ro : ByteArray} {c c' : Cursor} {q : Proto}
    (h : (insnCore fr ro).run c = .ok (q, c')) : q.items = [] := by
  cases Ryo.Proofs.DecodeLink.insnCore_read h with
  | dense hd => exact denseSwitch_items hd
  | _ => rfl

/-- As `callInsn_items`, for `insn` (`denseSwitch`, `insnCore`). -/
theorem insn_items {fr : Vm.Frame} {ro : ByteArray} {c c' : Cursor} {q : Proto}
    (h : (insn fr ro).run c = .ok (q, c')) : q.items = [] := by
  unfold insn at h
  obtain ⟨o, c1, h1, h2⟩ := Ryo.Proofs.DecodeLink.bind_ok h
  split at h2
  · obtain ⟨e, -⟩ := Ryo.Proofs.DecodeLink.pure_ok h2
    subst e
    exact denseSwitch_items h1
  · exact insnCore_items h2

open Ryo.Proofs.DecodeLink in
/-- A proto read with items is an inline one: its `ProtoRead` is the `.inline` case, an exact
`inlineInsn` run with the iteration's cache and dropped stores. -/
theorem protoRead_items {fr : Vm.Frame} {ro : ByteArray} {c : Cursor} {p : Nat} {cache : Cache}
    {dr : List DroppedStore} {a : Bool} {q : Proto} {c' : Cursor} {cache' : Cache}
    {dr' : List DroppedStore} (h : ProtoRead fr ro true c p cache dr a q c' cache' dr') :
    q.items = [] ∨ ∃ cur', (inlineInsn cache dr true).run cur' = .ok (some (q, cache', dr'), c') := by
  cases h with
  | arg h => exact .inl (argInsn_items h)
  | call _ h => exact .inl (callInsn_items h)
  | inline _ _ h => exact .inr ⟨_, h⟩
  | insn _ _ _ h => exact .inl (insn_items h)

section
open Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink
variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-- The decoder's items at `k` are empty, or those of an exact `inlineInsn` run (with `S.used k`
in a `main` iteration, `S.cache k` with a dropped store first in an `empty` one). -/
theorem items_inline (hD : Decodes S code relocs rodata callSites dropped scopes mode) {k : Nat}
    (hk : k < S.r.protos.size) :
    S.c.d.items[k]? = some [] ∨
      ∃ (cache : Cache) (dr : List DroppedStore) (cur c' : Cursor) (q : Proto) (cache' : Cache)
        (dr' : List DroppedStore), (cache = S.used k ∨ cache = S.cache k) ∧
        (inlineInsn cache dr true).run cur = .ok (some (q, cache', dr'), c') ∧
        S.c.d.items[k]? = some q.items := by
  rcases iter_items hD hk with ⟨d, dr, p, q, c', cache', dr', -, -, -, -, hr, hi⟩ |
      ⟨fr, p1, p2, counter, q, c', cache', dr', -, hpr, hi⟩
  · exact .inr ⟨_, _, _, _, _, _, _, .inr rfl, hr, hi⟩
  · rcases protoRead_items hpr with he | ⟨cur', hr⟩
    · exact .inl (by rw [hi, he])
    · exact .inr ⟨_, _, _, _, _, _, _, .inl rfl, hr, hi⟩


/-- `items_inline` with the cache `S.used k` in both iterations: an `empty` one (a dropped store
first) isn't at a branch target (`DHyps.emptyNotTarget`, `hnt`), so its `S.cache k` is `S.used k`
(as in `Sim.dinsn_empty`). -/
theorem items_inline_used (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hInl : ∀ f cls, (f, cls) ∈ inlineOps → Step.InlineOk f cls)
    {k : Nat} (hk : k < S.r.protos.size)
    (hnt : ∀ d dr, S.dr k = d :: dr → d.at_ = S.start k →
      sortedContains S.targets (S.start k) = false) :
    S.c.d.items[k]? = some [] ∨
      ∃ (dr : List DroppedStore) (cur c' : Cursor) (q : Proto) (cache' : Cache)
        (dr' : List DroppedStore), dr = S.dr k ∧ S.r.protos[k].op = q.op ∧
        S.r.protos[k].ops = q.ops ∧ S.r.protos[k].handler = q.handler ∧
        (inlineInsn (S.used k) dr true).run cur = .ok (some (q, cache', dr'), c') ∧
        S.c.d.items[k]? = some q.items := by
  -- An inline proto isn't a `resume`, so `fixResume` keeps it.
  have hnr : ∀ {cache cache' : Cache} {dr dr' : List DroppedStore} {cur c' : Cursor} {q : Proto},
      (inlineInsn cache dr true).run cur = .ok (some (q, cache', dr'), c') → q.op ≠ .resume := by
    intro cache cache' dr dr' cur c' q hr
    obtain ⟨-, -, cand, br, out, hdi, -⟩ := inlineInsn_read_drop hr
    obtain ⟨cls, hmem, -⟩ := decodeInline_spec hdi
    exact (hInl _ _ hmem).notResume
  rcases iter_items hD hk with ⟨d, dr, p, q, c', cache', dr', hdr, hd, hp, hpk0, hr, hi⟩ |
      ⟨fr, p1, p2, counter, q, c', cache', dr', hpk0, hpr, hi⟩
  · subst hp
    have hpk : S.r.protos[k] = { q with pos := S.start k } := by
      rcases hpk0 with h | h
      · exact h
      · rw [h]; exact S.fixResume_of_ne (fun h => hnr hr h)
    have hp1 : posOf S.r k = S.start k := by rw [posOf_eq hk, hpk]
    have hused : S.used k = S.cache k := by
      have := hnt d dr hdr hd
      simp [Setup.used, hp1, this]
    rw [← hused] at hr
    exact .inr ⟨_, _, _, _, _, _, hdr.symm, by rw [hpk], by rw [hpk], by rw [hpk], hr, hi⟩
  · rcases protoRead_items hpr with he | ⟨cur', hr⟩
    · exact .inl (by rw [hi, he])
    · have hpk2 : S.r.protos[k] = { q with pos := p1, counter } := by
        rcases hpk0 with h | h
        · exact h
        · rw [h]; exact S.fixResume_of_ne (fun h => hnr hr h)
      exact .inr ⟨_, _, _, _, _, _, rfl, by rw [hpk2], by rw [hpk2], by rw [hpk2], hr, hi⟩

/-- The R instruction at `k` of a proto without a handler (an inline one): native, its opcode the
proto's (`Opcode.full`), its operands the proto's in index form (`InsnOf`). -/
theorem native_of_proto (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    {k : Nat} (hk : k < S.r.protos.size) {q : Proto} (hop : S.r.protos[k].op = q.op)
    (hops : S.r.protos[k].ops = q.ops) (hh : S.r.protos[k].handler = none) :
    ∃ op ops, S.c.d.insns[k]? = some (.native op ops) ∧ op.full = some q.op ∧
      ops.map (opndMap (posOf S.r)) = q.ops := by
  have h1 := reducedOf_insns hD.reduced
  have hk' : k < S.c.d.insns.size := h1.1 ▸ hk
  have hi := h1.2 k hk hk'
  unfold InsnOf at hi
  simp only [hh] at hi
  obtain ⟨op, ops, hof, hin, hmap⟩ := hi
  refine ⟨op, ops, by simp [hk', hin], ?_, by rw [hmap, hops]⟩
  rw [← hop]
  exact privc_full_of hof

/-- An operand without targets (a slot, a pointer operand, a symbol) at index `i` of the proto is
the R instruction's. -/
theorem ops_plain_at {pos : Nat → Nat} {ops pops : List (R.Opnd Nat)}
    (h : ops.map (opndMap pos) = pops) {i : Nat} {o : R.Opnd Nat} (hi : pops[i]? = some o)
    (hn : o.targetsOf = []) : ops[i]? = some o := by
  subst h
  rw [List.getElem?_map] at hi
  cases h1 : ops[i]? with
  | none => rw [h1] at hi; simp at hi
  | some o' =>
    rw [h1] at hi
    simp only [Option.map_some, Option.some.injEq] at hi
    rw [opndMap_plain hi hn]
end

/-! ### The memory reads of what `emit` outputs (as `CacheStep.emit_writes`) -/

/-- `e` reads memory only as an item of `cand` does, its base renamed from `rax` to `xr`. -/
def ReadsOf (cand : List Item) (xr : X86.Reg) (e : Item) : Prop :=
  ∀ m, e.mem? = some m → 0 < readBytes e → ∃ it ∈ cand, ∃ m', it.mem? = some m' ∧
    readBytes e = readBytes it ∧ m = ⟨if (m'.base == Asm.R) = true then xr else m'.base, m'.disp⟩

theorem mem?_ren (xr : X86.Reg) (it : Item) :
    (ren xr it).mem? = it.mem?.map fun m =>
      (⟨if (m.base == Asm.R) = true then xr else m.base, m.disp⟩ : X86.M) := by
  cases it <;> (try cases ‹X86.Rm›) <;> rfl

theorem readBytes_ren (xr : X86.Reg) (it : Item) : readBytes (ren xr it) = readBytes it := by
  cases it <;> (try cases ‹X86.Rm›) <;> rfl

theorem withRm_reg (it : Item) (r : X86.Reg) :
    (withRm it (.reg r)).mem? = none ∨ withRm it (.reg r) = it := by
  cases it <;> first | (left; rfl) | (right; rfl)

theorem readsOf_ren (xr : X86.Reg) {cand : List Item} {it : Item} (hit : it ∈ cand) :
    ReadsOf cand xr (ren xr it) := by
  unfold ReadsOf
  intro m hm hb
  rw [mem?_ren] at hm
  cases hmi : it.mem? with
  | none => rw [hmi] at hm; exact nomatch hm
  | some m' =>
    rw [hmi] at hm
    simp only [Option.map_some, Option.some.injEq] at hm
    exact ⟨it, hit, m', hmi, readBytes_ren xr it, hm.symm⟩

theorem foldl_reads (xr : X86.Reg) (cand : List Item) :
    ∀ (rest : List Item) (st : Cache × Array Item),
    (∀ e ∈ st.2.toList, ReadsOf cand xr e) → (∀ it ∈ rest, it ∈ cand) →
    ∀ e ∈ (rest.foldl (emitStep xr) st).2.toList, ReadsOf cand xr e
  | [], st, h, _ => h
  | it :: rest, st, h, hs => by
    obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
    have hit : it ∈ cand := hs it (by simp)
    have he : ReadsOf cand xr e := by
      rcases hcase with ⟨rfl, _⟩ | ⟨m, w, i, _, _, rfl, _⟩
      · exact readsOf_ren xr hit
      · rcases withRm_reg (ren xr it) pool[i]! with hn | heq'
        · unfold ReadsOf; intro m' hm'; rw [hn] at hm'; exact nomatch hm'
        · rw [heq']; exact readsOf_ren xr hit
    simp only [List.foldl_cons, heq]
    refine foldl_reads xr cand rest _ ?_ (fun i hi => hs i (by simp [hi]))
    intro e' he'
    simp only [Array.toList_push, List.mem_append, List.mem_singleton] at he'
    rcases he' with he' | rfl
    · exact h e' he'
    · exact he

/-- The memory reads of what `emit` outputs: each is a read of an item of the sequence, of the
same width, its base renamed from `rax` to `emit`'s register. -/
theorem emit_reads {c : Cache} {items : List Item} (hsz : c.regs.size = 8) :
    ∀ e ∈ (c.emit items).1, ReadsOf items pool[(emitHead { c with tick := c.tick + 1 } items).1]! e := by
  rw [emit_eq]
  dsimp only
  apply foldl_reads _ items _ _ (by simp)
  rcases emitHead_cases { c with tick := c.tick + 1 } items hsz with h | ⟨w, m, tl, rfl, h, _⟩
  · rw [h]; exact fun i hi => hi
  · rw [h]; exact fun i hi => by simp [hi]

/-- `emit`'s head against the cache invariant: every item stays, or a leading reload of a slot
is dropped, and then the register `emit` picks holds that slot's bytes (`Holds`). For `load`'s
sequence, the pointer `ld`'s base register: the reload `ld .q rax [rbp + p]` kept, or `xr`
holding the 8 bytes at `rbp + p`. -/
theorem emitHead_hit_holds {c : Cache} {yh : X86.State} (hinv : CacheInv c yh)
    (items : List Item) :
    (emitHead { c with tick := c.tick + 1 } items).2 = items ∨
    ∃ w m tl, items = .ld w false .rax m :: tl ∧
      (emitHead { c with tick := c.tick + 1 } items).2 = tl ∧ m.base = .rbp ∧
      (yh.reg pool[(emitHead { c with tick := c.tick + 1 } items).1]!).toNat =
        yh.mem.readNat (yh.ea (X86.M.frame m.disp)) (bytes w) := by
  rcases emitHead_cases { c with tick := c.tick + 1 } items hinv.1 with h |
      ⟨w, m, tl, h1, h2, h3, hi, hsl⟩
  · exact .inl h
  · refine .inr ⟨w, m, tl, h1, h2, h3, ?_⟩
    have hi' : (emitHead { c with tick := c.tick + 1 } items).1 < c.regs.size := by
      rw [hinv.1]; exact hi
    have hsl' : c.regs[(emitHead { c with tick := c.tick + 1 } items).1]!.slot =
        some (m.disp, w) := hsl
    rw [getElem!_pos c.regs _ hi'] at hsl'
    exact (hinv.2 _ hi').1 _ _ hsl'

/-- The miss case's kept reload `ld .q xr [m]`: `xr` gets the 8 bytes at `m`. -/
theorem ld_q_reg {ctx : Ctx} {y y' : X86.State} {xr : X86.Reg} {m : X86.M}
    (h : (Item.ld .q false xr m).exec ctx y = .ok y') :
    (y'.reg xr).toNat = y.mem.readNat (y.ea m) 8 := by
  have h' : (Except.ok ((y.jump (y.rip + BitVec.ofNat 64 (Item.ld .q false xr m).size)).setReg xr
      ((BitVec.ofNat 64 (y.mem.readNat (y.ea m) 8)).setWidth 64)) : Except X86.Fault X86.State) =
      .ok y' := h
  obtain rfl := Except.ok.inj h'
  rw [X86.State.reg_setReg, BitVec.setWidth_eq, BitVec.toNat_ofNat]
  exact Nat.mod_eq_of_lt (Ryo.Proofs.RegCache.readNat_lt _ _ 8)

/-- `addrSymInd`'s kept `loadRip xr to`: `xr` gets the slot's 8 bytes. -/
theorem loadRip_reg {ctx : Ctx} {y y' : X86.State} {xr : X86.Reg} {to : X86.Ref}
    (h : (Item.loadRip xr to).exec ctx y = .ok y') : y'.reg xr = y.mem.read64 (ctx.addrOf to) := by
  have h' : (Except.ok ((y.jump (y.rip + BitVec.ofNat 64 (Item.loadRip xr to).size)).setReg xr
      (y.mem.read64 (ctx.addrOf to))) : Except X86.Fault X86.State) = .ok y' := h
  obtain rfl := Except.ok.inj h'
  exact X86.State.reg_setReg _ _ _

/-- One item run from `y`: `execItems [a]` is `a`'s `exec`. -/
theorem execItems_one {ctx : Ctx} {a : Item} {y y' : X86.State}
    (h : execItems ctx [a] y = .ok y') : a.exec ctx y = .ok y' := by
  rw [X86.execItems_cons] at h
  cases ha : a.exec ctx y with
  | error e =>
    rw [ha] at h
    have h' : (Except.error e : Except X86.Fault X86.State) = .ok y' := h
    exact nomatch h'
  | ok y1 =>
    rw [ha] at h
    have h' : (Except.ok y1 : Except X86.Fault X86.State) = .ok y' := h
    rw [h']

/-- The real and the ghost state read the same bytes off `fp + P`, at the same addresses. -/
theorem readNat_agree {fp : BitVec 64} {P : Int → Prop} {y yh : X86.State}
    (ha : XAgreeAt fp P y yh) (a : BitVec 64) (n : Nat)
    (h : ∀ j < n, ∀ o, P o → a + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o) :
    y.mem.readNat a n = yh.mem.readNat a n :=
  Ryo.Proofs.RegCache.readNat_congr _ _ a n fun j hj => ha.2.2.2.2 _ (h j hj)

theorem ea_agree {fp : BitVec 64} {P : Int → Prop} {y yh : X86.State}
    (ha : XAgreeAt fp P y yh) (m : X86.M) : y.ea m = yh.ea m := by
  show y.regs m.base.idx + _ = yh.regs m.base.idx + _
  rw [ha.1]

/-! ### `emit` of a sequence without cacheable operands -/

/-- Without a `readOperand` (no ALU/`mul`/`div` memory operand), `emitStep` pushes the renamed
item. -/
theorem foldl_plain (xr : X86.Reg) :
    ∀ (rest : List Item) (st : Cache × Array Item),
      (∀ it ∈ rest, readOperand (ren xr it) = none) →
      (rest.foldl (emitStep xr) st).2.toList = st.2.toList ++ rest.map (ren xr)
  | [], st, _ => by simp
  | it :: rest, st, h => by
    obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
    have he : e = ren xr it := by
      rcases hcase with ⟨rfl, _⟩ | ⟨m, w, i, hro, _, _, _⟩
      · rfl
      · rw [h it (by simp)] at hro; cases hro
    simp only [List.foldl_cons, heq]
    rw [foldl_plain xr rest _ (fun i hi => h i (by simp [hi]))]
    simp [he]

/-- `emit` of such a sequence: its head's items (all, or without a cached leading reload),
renamed to `emit`'s register. -/
theorem emit_plain {c : Cache} {items : List Item} (hsz : c.regs.size = 8)
    (h : ∀ xr, ∀ it ∈ items, readOperand (ren xr it) = none) :
    (c.emit items).1 = (emitHead { c with tick := c.tick + 1 } items).2.map
      (ren pool[(emitHead { c with tick := c.tick + 1 } items).1]!) := by
  rw [emit_eq]
  dsimp only
  rw [foldl_plain]
  · simp
  · intro it hit
    apply h
    rcases emitHead_cases { c with tick := c.tick + 1 } items hsz with he | ⟨w, m, tl, rfl, he, _⟩
    · rw [he] at hit; exact hit
    · rw [he] at hit; exact List.mem_cons_of_mem _ hit

/-! ### The two sequences with a non-`rbp` read, and their `emit` -/

-- `seq_items`'s peeling of a `sequence` hypothesis `h`, for one class.
set_option hygiene false in
macro "seq_peel" : tactic => `(tactic| (
  simp only [sequence, bind, Option.bind_eq_some_iff, pure] at h
  repeat' (first
    | (obtain ⟨_, hs, h⟩ := h
       split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
    | split at h)
  all_goals (try simp only [Option.some.injEq, Prod.mk.injEq] at h)
  all_goals (try obtain ⟨rfl, _⟩ := h)))

theorem seq_load {T : Type} {w : X86.W} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option X86.Cond} (h : sequence (.load w) ops = some (cand, br)) :
    ∃ p k d, ops[1]? = some (.mem p k) ∧
      cand = [ld .q (X86.M.frame p), ld w (Mrax k), st w (X86.M.frame d)] := by
  seq_peel
  all_goals first
    | exact ⟨_, _, _, by assumption, rfl⟩
    | (exfalso; simp_all; done)

theorem seq_addrSymInd {T : Type} {ops : List (R.Opnd T)} {cand : List Item}
    {br : Option X86.Cond} (h : sequence .addrSymInd ops = some (cand, br)) :
    ∃ sy d, ops[1]? = some (.sym sy) ∧
      cand = [.loadRip R (.sym sy), ld .q (Mrax 0), st .q (X86.M.frame d)] := by
  seq_peel
  all_goals first
    | exact ⟨_, _, by assumption, rfl⟩
    | exact ⟨_, _, by assumption, by simp⟩
    | exact ⟨_, _, by assumption, by decide⟩
    | (exfalso; simp_all; done)

/-- `emit` of `load w`'s sequence: all three items on `emit`'s register `xr` (a miss), or the
reload dropped (a hit), `xr` then holding the slot's 8 bytes. -/
theorem emit_load {c : Cache} {yh : X86.State} (hinv : CacheInv c yh) (w : X86.W)
    (p k d : BitVec 32) :
    ∃ xr : X86.Reg,
      (c.emit [ld .q (X86.M.frame p), ld w (Mrax k), st w (X86.M.frame d)]).1 =
          [.ld .q false xr (X86.M.frame p), .ld w false xr ⟨xr, k⟩, .st w xr (X86.M.frame d)] ∨
        ((c.emit [ld .q (X86.M.frame p), ld w (Mrax k), st w (X86.M.frame d)]).1 =
            [.ld w false xr ⟨xr, k⟩, .st w xr (X86.M.frame d)] ∧
          (yh.reg xr).toNat = yh.mem.readNat (yh.ea (X86.M.frame p)) 8) := by
  have hpl := emit_plain (c := c)
    (items := [ld .q (X86.M.frame p), ld w (Mrax k), st w (X86.M.frame d)]) hinv.1
    (by
      intro xr it hit
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hit
      rcases hit with rfl | rfl | rfl <;> rfl)
  refine ⟨pool[(emitHead { c with tick := c.tick + 1 }
    [ld .q (X86.M.frame p), ld w (Mrax k), st w (X86.M.frame d)]).1]!, ?_⟩
  rw [hpl]
  rcases emitHead_hit_holds hinv [ld .q (X86.M.frame p), ld w (Mrax k), st w (X86.M.frame d)] with
    he | ⟨w', m, tl, hL, he, -, hreg⟩
  · left
    rw [he]
    first | rfl | simp [ren, mapRegs, ld, st, Mrax, R]
  · right
    obtain ⟨h1, h2⟩ := List.cons.inj hL
    obtain ⟨hw, -, -, hm⟩ := Item.ld.inj h1
    subst hw hm h2
    rw [he]
    exact ⟨by first | rfl | simp [ren, mapRegs, ld, st, Mrax, R], hreg⟩

/-- `emit` of `addrSymInd`'s sequence: no reload to drop (it starts with the `loadRip`), all
three items on `emit`'s register. -/
theorem emit_addrSymInd {c : Cache} {yh : X86.State} (hinv : CacheInv c yh) (sy : Nat)
    (d : BitVec 32) :
    ∃ xr : X86.Reg,
      (c.emit [.loadRip R (.sym sy), ld .q (Mrax 0), st .q (X86.M.frame d)]).1 =
        [.loadRip xr (.sym sy), .ld .q false xr ⟨xr, 0⟩, .st .q xr (X86.M.frame d)] := by
  have hpl := emit_plain (c := c)
    (items := [.loadRip R (.sym sy), ld .q (Mrax 0), st .q (X86.M.frame d)]) hinv.1
    (by
      intro xr it hit
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hit
      rcases hit with rfl | rfl | rfl <;> rfl)
  refine ⟨pool[(emitHead { c with tick := c.tick + 1 }
    [.loadRip R (.sym sy), ld .q (Mrax 0), st .q (X86.M.frame d)]).1]!, ?_⟩
  rw [hpl]
  rcases emitHead_hit_holds hinv [.loadRip R (.sym sy), ld .q (Mrax 0), st .q (X86.M.frame d)] with
    he | ⟨w', m, tl, hL, -, -, -⟩
  · rw [he]
    first | rfl | simp [ren, mapRegs, ld, st, Mrax, R]
  · exact nomatch (List.cons.inj hL).1

/-! ### The sequences' memory reads -/

set_option hygiene false in
macro "rd_close" : tactic =>
  `(tactic| (
    seq_items
    all_goals intro m hm hb
    all_goals (try (simp only [Item.mem?, Option.some.injEq, reduceCtorEq] at hm))
    all_goals (try subst hm)
    all_goals first
      | (left; rfl)
      | (right; left; exact ⟨_, rfl⟩)
      | (right; right; rfl)
      | (simp [readBytes, Frame.itemReadBytes] at hb; done)
      | (simp at hm; done)
      | (exfalso; simp_all; done)
      | (exfalso; rename_i hx; revert hx; decide)))

theorem rd_mov {T : Type} (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.mov w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.mov w) : Class)) = .load w') ∨
        (((.mov w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_mov128 {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.mov128) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.mov128) : Class)) = .load w') ∨
        (((.mov128) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_imm {T : Type} (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.imm w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.imm w) : Class)) = .load w') ∨
        (((.imm w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_addr {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.addr) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.addr) : Class)) = .load w') ∨
        (((.addr) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_addrConst {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.addrConst) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.addrConst) : Class)) = .load w') ∨
        (((.addrConst) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_addrSym {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.addrSym) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.addrSym) : Class)) = .load w') ∨
        (((.addrSym) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_addrSymInd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.addrSymInd) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.addrSymInd) : Class)) = .load w') ∨
        (((.addrSymInd) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_ptrAdd {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.ptrAdd) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.ptrAdd) : Class)) = .load w') ∨
        (((.ptrAdd) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_ptrIndex {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.ptrIndex) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.ptrIndex) : Class)) = .load w') ∨
        (((.ptrIndex) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_load {T : Type} (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.load w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.load w) : Class)) = .load w') ∨
        (((.load w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_store {T : Type} (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.store w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.store w) : Class)) = .load w') ∨
        (((.store w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_bin {T : Type} (op : X86.Alu) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.bin op w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.bin op w) : Class)) = .load w') ∨
        (((.bin op w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_binImm {T : Type} (op : X86.Alu) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.binImm op w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.binImm op w) : Class)) = .load w') ∨
        (((.binImm op w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_mul {T : Type} (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.mul w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.mul w) : Class)) = .load w') ∨
        (((.mul w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_mulImm {T : Type} (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.mulImm w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.mulImm w) : Class)) = .load w') ∨
        (((.mulImm w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_shiftImm {T : Type} (sh : X86.Sh) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.shiftImm sh w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.shiftImm sh w) : Class)) = .load w') ∨
        (((.shiftImm sh w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_cmp {T : Type} (c : X86.Cond) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.cmp c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.cmp c w) : Class)) = .load w') ∨
        (((.cmp c w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_cmpImm {T : Type} (c : X86.Cond) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.cmpImm c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.cmpImm c w) : Class)) = .load w') ∨
        (((.cmpImm c w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_br {T : Type}  {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.br) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.br) : Class)) = .load w') ∨
        (((.br) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_brCmp {T : Type} (c : X86.Cond) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.brCmp c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.brCmp c w) : Class)) = .load w') ∨
        (((.brCmp c w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_brCmpImm {T : Type} (c : X86.Cond) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.brCmpImm c w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.brCmpImm c w) : Class)) = .load w') ∨
        (((.brCmpImm c w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_ovf {T : Type} (op : X86.Alu) (sg : Bool) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.ovf op sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.ovf op sg w) : Class)) = .load w') ∨
        (((.ovf op sg w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_mulOvf {T : Type} (sg : Bool) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.mulOvf sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.mulOvf sg w) : Class)) = .load w') ∨
        (((.mulOvf sg w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_ext {T : Type} (src : X86.W) (dst : X86.W) (sx : Bool) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.ext src dst sx) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.ext src dst sx) : Class)) = .load w') ∨
        (((.ext src dst sx) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_shiftVar {T : Type} (sh : X86.Sh) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.shiftVar sh w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.shiftVar sh w) : Class)) = .load w') ∨
        (((.shiftVar sh w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_div {T : Type} (sg : Bool) (rem : Bool) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.div sg rem w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.div sg rem w) : Class)) = .load w') ∨
        (((.div sg rem w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_count {T : Type} (lz : Bool) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.count lz w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.count lz w) : Class)) = .load w') ∨
        (((.count lz w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_cmp3 {T : Type} (sg : Bool) (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.cmp3 sg w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.cmp3 sg w) : Class)) = .load w') ∨
        (((.cmp3 sg w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

theorem rd_bswap {T : Type} (w : X86.W) {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence (.bswap w) ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w', (((.bswap w) : Class)) = .load w') ∨
        (((.bswap w) : Class)) = .addrSymInd := by
  intro it hit
  rd_close

/-- In an inline sequence, a memory read is off `rbp` but in `load`'s (its pointer `ld`) and
`addrSymInd`'s (the import slot `[rax]` the symbol slot points to, an 8-byte load in R too). -/
theorem sequence_reads_frame {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option X86.Cond} (h : sequence cls ops = some (items, br)) :
    ∀ it ∈ items, ∀ m, it.mem? = some m → 0 < readBytes it →
      m.base = .rbp ∨ (∃ w, cls = .load w) ∨ cls = .addrSymInd := by
  cases cls with
  | mov w => exact rd_mov w h
  | mov128 => exact rd_mov128 h
  | imm w => exact rd_imm w h
  | addr => exact rd_addr h
  | addrConst => exact rd_addrConst h
  | addrSym => exact rd_addrSym h
  | addrSymInd => exact rd_addrSymInd h
  | ptrAdd => exact rd_ptrAdd h
  | ptrIndex => exact rd_ptrIndex h
  | load w => exact rd_load w h
  | store w => exact rd_store w h
  | bin op w => exact rd_bin op w h
  | binImm op w => exact rd_binImm op w h
  | mul w => exact rd_mul w h
  | mulImm w => exact rd_mulImm w h
  | shiftImm sh w => exact rd_shiftImm sh w h
  | cmp c w => exact rd_cmp c w h
  | cmpImm c w => exact rd_cmpImm c w h
  | br => exact rd_br h
  | brCmp c w => exact rd_brCmp c w h
  | brCmpImm c w => exact rd_brCmpImm c w h
  | ovf op sg w => exact rd_ovf op sg w h
  | mulOvf sg w => exact rd_mulOvf sg w h
  | ext src dst sx => exact rd_ext src dst sx h
  | shiftVar sh w => exact rd_shiftVar sh w h
  | div sg rem w => exact rd_div sg rem w h
  | count lz w => exact rd_count lz w h
  | cmp3 sg w => exact rd_cmp3 sg w h
  | bswap w => exact rd_bswap w h

/-- `addrSymInd`'s second read: a successful step loads 8 bytes (checked, `st.load … 8
PTR_ALIGN`) at the pointer in the symbol slot, so, with `Globals`, every byte `j < 8` at the x86
value of the slot (`read64` at `ctx.addrOf (.sym sy)`) is in a live allocation. -/
theorem addrSymInd_ptr_live {ctx : Ctx} {ρ : R.Addrs} {op : Full.Opcode}
    {ops : List (R.Opnd Nat)} {vals : Operands} {st st' : OpSem.State} {ctl : Control}
    {ch : OpSem.Choice} {x : Ryo.X86.State} (hs : shapeOk op .addrSymInd = true)
    (hv : nativeVals ρ op ops = some vals) (hsem : opSem op vals st ch = .ok (ctl, st'))
    (hg : Globals ctx ρ st x) :
    ∀ sy, ops[1]? = some (.sym sy) → ∃ id a, st.mem.get? id = some a ∧ a.live = true ∧
      ∀ j < 8, (x.mem.read64 (ctx.addrOf (.sym sy)) + BitVec.ofNat 64 j -
        BitVec.ofNat 64 a.addr).toNat < a.size := by
  intro sy' hop
  obtain ⟨⟨r, hh⟩, ho⟩ := shapeOk_spec hs
  have hh' : op.handler? = some ⟨.addr_sym, [toString true], r⟩ := hh
  have ho' : op.info.operands = [⟨"d", .slot⟩, ⟨"sym", .sym⟩] := ho
  clear hh ho
  obtain ⟨o0, o1, v0, v1, rfl, rfl, h0, h1⟩ := nvs2 ho' hv
  obtain ⟨s0, rfl, rfl⟩ := nv_slot.1 h0
  cases o1 <;> simp only [R.nativeVal, Option.map_eq_some_iff, reduceCtorEq] at h1
  rename_i sy
  obtain ⟨p, hρ, rfl⟩ := h1
  simp only [List.getElem?_cons_succ, List.getElem?_cons_zero, Option.some.injEq,
    R.Opnd.sym.injEq] at hop
  rw [← hop]
  obtain ⟨bs, v, hl, hvp, hb, rfl⟩ := opSem_addrSym hh' ho' hsem
  have hslot := hg.sym sy p hρ
  have hva := asPtr_rel (hg.mem p bs hl) hvp
  try simp only [↓reduceIte] at hb
  obtain ⟨bs2, v2, hl2, hvp2, hw⟩ := hb
  have hv1 : BitVec.ofNat 64 v.addr = x.mem.read64 (ctx.addrOf (.sym sy)) := by
    rw [hva, ← hslot, X86.Mem.read64, readNat_eq]
  obtain ⟨id, a, hga, hlv, ha1, ha2, _⟩ := Ryo.Proofs.ScopeMem.load_ok_align (by decide) hl2
  refine ⟨id, a, hga, hlv, fun j hj => ?_⟩
  rw [← hv1, ← BitVec.ofNat_add, show v.addr + j = a.addr + (v.addr - a.addr + j) by omega,
    ofNat_add_sub, BitVec.toNat_ofNat]
  simp only [Allocation.size] at ha2 ⊢
  exact Nat.lt_of_le_of_lt (Nat.mod_le _ _) (by omega)

/-- **Open.** No `Escape` scope at `pc` overlaps `P`: an `Escape`'s range is an operand read of
`pc` (`Flow.rowOf`), so a `Dead` byte isn't in it; for the `Uninit ∧ CacheCovers` disjunct this
needs the `Escape` ranges to be in the kept-read liveness too (or a check). -/
theorem escape_scopes_miss {S : Setup} {C : Cert S} {s : R.RState} {P : Int → Prop}
    (hP : PatchOk S C s P) (hI : KrInv S C s P) (hk : s.pc < S.c.d.insns.size) :
    ∀ sc ∈ S.c.scopesAt s.pc, ∀ al, sc.kind = .escape al → ∀ o, P o →
      ¬ (sc.frameOffset.toInt ≤ o ∧ o < sc.frameOffset.toInt + sc.size) := by
  intro sc hsc al hkind o ho ⟨h1, h2⟩
  obtain ⟨hin, _, _, hdu⟩ := hP o ho
  rcases hdu with hdead | _
  · exact not_dead_of_escape C hk hsc hkind h1 h2 hdead
  · obtain ⟨hf1, hf2⟩ := hin
    unfold R.Code.scopesAt at hsc
    obtain ⟨x, hx, rfl⟩ := List.mem_map.1 hsc
    obtain ⟨hxm, hxk⟩ := List.mem_filter.1 hx
    obtain ⟨j, hj⟩ := List.mem_iff_getElem?.1 hxm
    rw [Array.getElem?_toList] at hj
    have hxk' : x.1 = s.pc := by simpa using hxk
    have hj' : S.c.d.scopes[j]? = some (s.pc, x.2) := by rw [hj, ← hxk']
    have hmem := frame_scopesAt_mem hj' hk
    have hsz : s.pc < C.fl.succ.size := by rw [flowOf_succ C.hfl, flow_succ_size]; exact hk
    have hesc := flowOf_escRead_escape C.hfl hk hmem hkind (i := bit S o)
      (by simp only [Frame.range, bit]; omega) (by simp only [Frame.range, bit]; omega)
    have hkr := keptRead_esc C.hkept hsz hesc
    have hno : (C.kr[s.pc]!).testBit (bit S o) = false := hI o ho ⟨hf1, hf2⟩
    have hc : (true : Bool) = false := hkr.symm.trans hno
    cases hc

/-- After `pc`'s scopes `FrameOwn` and `Rel` still hold on the same machine state
(`ScopeMem.sep_foldlM`), and `P`'s bytes are still private (`escFree_foldlM`,
`escape_scopes_miss`). -/
theorem sep_after_scopes {S : Setup} (H : Hyps S) {C : Cert S} {s s1 : R.RState} {P : Int → Prop}
    {yh : X86.State} (hfr : FrameInv S s yh) (hP : PatchOk S C s P) (he : EscSound S C s)
    (hI : KrInv S C s P) (hk : s.pc < S.c.d.insns.size)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1) :
    Ryo.Proofs.ScopeMem.FrameOwn (-(S.F : Int)) S.K s1.st yh ∧
      (∀ o, P o → s1.st.escapedAt o = none) ∧ Rel s1.st yh := by
  have hs1 := Ryo.Proofs.ScopeMem.sep_foldlM _ (H.frameBounds.scopesIn s.pc)
    (H.frameBounds.window hfr.win) hfr.rrel hfr.sep hsc
  refine ⟨hs1.2.own, Ryo.Proofs.ScopeMem.escFree_foldlM _ (escape_scopes_miss hP hI hk)
    (fun o ho => (hP o ho).2.2.1) hsc, hs1.1.rel⟩

/-- `KeptPtrLive` from its per-position form: each non-`rbp` read, at the state the kept items
before it leave, lands in a live allocation. -/
theorem keptPtrLive_of_reads (ctx : Ctx) (st : OpSem.State) :
    ∀ (kept : List Item) (y : X86.State),
      (∀ pre it post, kept = pre ++ it :: post → ∀ y', execItems ctx pre y = .ok y' →
        ∀ m, it.mem? = some m → m.base ≠ .rbp → ∀ j < readBytes it,
          ∃ id a, st.mem.get? id = some a ∧ a.live = true ∧
            (y'.ea m + BitVec.ofNat 64 j - BitVec.ofNat 64 a.addr).toNat < a.size) →
      KeptPtrLive ctx st kept y
  | [], _, _ => trivial
  | it :: is, y, h => by
    refine ⟨fun m hm hb j hj => h [] it is rfl y rfl m hm hb j hj, fun y' hy' => ?_⟩
    refine keptPtrLive_of_reads ctx st is y' fun pre it' post e y'' hy'' => ?_
    refine h (it :: pre) it' post (by rw [e]; rfl) y'' ?_
    rw [X86.execItems_cons, hy']
    exact hy''

section
open Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink
variable {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-! ### `kept_ptr_reads`'s pieces -/

theorem split3 {α : Type} {a b c it : α} {pre post : List α} (e : [a, b, c] = pre ++ it :: post) :
    (pre = [] ∧ it = a) ∨ (pre = [a] ∧ it = b) ∨ (pre = [a, b] ∧ it = c) :=
  match pre, e with
  | [], e => by
    simp only [List.nil_append, List.cons.injEq] at e
    exact .inl ⟨rfl, e.1.symm⟩
  | [x], e => by
    simp only [List.cons_append, List.nil_append, List.cons.injEq] at e
    exact .inr (.inl ⟨by rw [e.1], e.2.1.symm⟩)
  | [x, y], e => by
    simp only [List.cons_append, List.nil_append, List.cons.injEq] at e
    exact .inr (.inr ⟨by rw [e.1, e.2.1], e.2.2.1.symm⟩)
  | _ :: _ :: _ :: _, e => by simp at e

theorem split2 {α : Type} {a b it : α} {pre post : List α} (e : [a, b] = pre ++ it :: post) :
    (pre = [] ∧ it = a) ∨ (pre = [a] ∧ it = b) :=
  match pre, e with
  | [], e => by
    simp only [List.nil_append, List.cons.injEq] at e
    exact .inl ⟨rfl, e.1.symm⟩
  | [x], e => by
    simp only [List.cons_append, List.nil_append, List.cons.injEq] at e
    exact .inr ⟨by rw [e.1], e.2.1.symm⟩
  | _ :: _ :: _, e => by simp at e

theorem split1 {α : Type} {a it : α} {pre post : List α} (e : [a] = pre ++ it :: post) :
    pre = [] ∧ it = a :=
  match pre, e with
  | [], e => by
    simp only [List.nil_append, List.cons.injEq] at e
    exact ⟨rfl, e.1.symm⟩
  | _ :: _, e => by simp at e

theorem itm_ea_mk (y : X86.State) (r : X86.Reg) (k : BitVec 32) :
    y.ea ⟨r, k⟩ = y.reg r + k.signExtend 64 := rfl

/-- A load miss: the pointer `ld` after the kept reload `ld .q xr [rbp + p]`, whose bytes miss `P`. -/
theorem kpr_load_miss {ctx : Ctx} {P : Int → Prop} {y yh y' : X86.State} {xr : X86.Reg}
    {p k : BitVec 32} (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hrdA : ∀ j < 8, ∀ o, P o →
      yh.ea (X86.M.frame p) + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o)
    (hy : execItems ctx [.ld .q false xr (X86.M.frame p)] y = .ok y') :
    y'.ea ⟨xr, k⟩ =
      BitVec.ofNat 64 (leDecode (bytesAt yh.mem (fpAddr yh p.toInt) 8)) + k.signExtend 64 := by
  have hreg := ld_q_reg (execItems_one hy)
  have hagree : y.mem.readNat (y.ea (X86.M.frame p)) 8 =
      yh.mem.readNat (yh.ea (X86.M.frame p)) 8 := by
    rw [ea_agree ha]
    exact readNat_agree ha _ 8 hrdA
  have hv : y'.reg xr = BitVec.ofNat 64 (leDecode (bytesAt yh.mem (fpAddr yh p.toInt) 8)) := by
    apply BitVec.eq_of_toNat_eq
    rw [hreg, hagree, BitVec.toNat_ofNat, ← readNat_eq]
    exact (Nat.mod_eq_of_lt (Ryo.Proofs.RegCache.readNat_lt _ _ 8)).symm
  rw [itm_ea_mk, hv]

/-- A load hit: the pointer `ld` first, `xr` holding the slot's 8 bytes in `yh` (`emit_load`). -/
theorem kpr_load_hit {ctx : Ctx} {P : Int → Prop} {y yh y' : X86.State} {xr : X86.Reg}
    {p k : BitVec 32} (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hreg : (yh.reg xr).toNat = yh.mem.readNat (yh.ea (X86.M.frame p)) 8)
    (hy : execItems ctx [] y = .ok y') :
    y'.ea ⟨xr, k⟩ =
      BitVec.ofNat 64 (leDecode (bytesAt yh.mem (fpAddr yh p.toInt) 8)) + k.signExtend 64 := by
  have hy0 : y' = y := (Except.ok.inj hy).symm
  have hyx : y.reg xr = yh.reg xr := by
    show y.regs xr.idx = yh.regs xr.idx
    rw [ha.1]
  have hv : y.reg xr = BitVec.ofNat 64 (leDecode (bytesAt yh.mem (fpAddr yh p.toInt) 8)) := by
    rw [hyx]
    apply BitVec.eq_of_toNat_eq
    rw [hreg, BitVec.toNat_ofNat, ← readNat_eq]
    exact (Nat.mod_eq_of_lt (Ryo.Proofs.RegCache.readNat_lt _ _ 8)).symm
  rw [hy0, itm_ea_mk, hv]

/-- `addrSymInd`: the pointer `ld .q [xr]` after the kept `loadRip xr (.sym sy)`, whose slot
misses `P`. -/
theorem kpr_addrSymInd {ctx : Ctx} {P : Int → Prop} {y yh y' : X86.State} {xr : X86.Reg}
    {sy : Nat} (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hlrA : ∀ j < 8, ∀ o, P o →
      ctx.addrOf (.sym sy) + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o)
    (hy : execItems ctx [.loadRip xr (.sym sy)] y = .ok y') :
    y'.ea ⟨xr, 0⟩ = yh.mem.read64 (ctx.addrOf (.sym sy)) := by
  have hreg := loadRip_reg (execItems_one hy)
  rw [itm_ea_mk, hreg, show (0 : BitVec 32).signExtend 64 = 0#64 by decide, BitVec.add_zero]
  show BitVec.ofNat 64 (y.mem.readNat (ctx.addrOf (.sym sy)) 8) =
    BitVec.ofNat 64 (yh.mem.readNat (ctx.addrOf (.sym sy)) 8)
  rw [readNat_agree ha _ 8 hlrA]

/-- The kept items' non-`rbp` reads at inline instruction `s.pc`, run from the real virtual
state `y` (agreeing with the ghost `yh` but at `P`): a read with a non-`rbp` base and a nonzero
width is `load w`'s pointer `ld`, at the 8 bytes of slot `pp` in `yh` plus `k'`, or
`addrSymInd`'s `ld .q [xr]`, at the symbol slot's 8 bytes. The items are an exact `inlineInsn`
run's with `S.used k` (`items_inline_used`, `hnt`), `emit`'s output or it without a dropped store
(`inlineInsn_erased_dropped`, `hforms`: the trailing store); `emit_reads` and
`sequence_reads_frame` give the class, `emit_load`/`emit_addrSymInd` the items; the base register
holds the kept reload's bytes (`ld_q_reg`, `hrd`: they miss `P`), a cached copy (`emit_load`'s hit),
or the `loadRip`'s slot (`loadRip_reg`, `hlr`). -/
theorem kept_ptr_reads {S : Setup} (H : Hyps S) {P : Int → Prop}
    (hD : Decodes S code relocs rodata callSites dropped scopes mode) {s : R.RState}
    {y yh : X86.State} {kept : List Item} (hpc : s.pc < S.r.protos.size)
    (hnt : ∀ d dr, S.dr s.pc = d :: dr → d.at_ = S.start s.pc →
      sortedContains S.targets (S.start s.pc) = false)
    (hforms : ∀ d ∈ S.dr s.pc, DroppedForm d)
    (hci : CacheInv (S.used s.pc) yh)
    (hkept : S.c.d.items[s.pc]? = some kept) (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hrd : ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it, ∀ o, P o →
      yh.reg .rbp + m.disp.signExtend 64 + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o)
    (hlr : ∀ it ∈ kept, ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, P o →
      S.ctx.addrOf to + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o) :
    ∀ pre it post, kept = pre ++ it :: post → ∀ y', execItems S.ctx pre y = .ok y' →
      ∀ m, it.mem? = some m → m.base ≠ .rbp → 0 < readBytes it →
        ∃ op ops f, S.c.d.insns[s.pc]? = some (.native op ops) ∧ op.full = some f ∧
          ((∃ w pp k', shapeOk f (.load w) = true ∧ ops[1]? = some (.mem pp k') ∧
              readBytes it ≤ wbytes w ∧
              y'.ea m = BitVec.ofNat 64 (leDecode (bytesAt yh.mem (fpAddr yh pp.toInt) 8)) +
                k'.signExtend 64) ∨
            (∃ sy, shapeOk f .addrSymInd = true ∧ ops[1]? = some (.sym sy) ∧
              readBytes it ≤ 8 ∧ y'.ea m = yh.mem.read64 (S.ctx.addrOf (.sym sy)))) := by
  intro pre it post e y' hy m hm hb hrb0
  rcases items_inline_used hD H.inlineOk hpc hnt with hnil |
      ⟨dr, cur, c', q, cache', dr', hdr, hop, hops, hhd, hr, hi⟩
  · have hk0 : kept = [] := Option.some.inj (hkept.symm.trans hnil)
    subst hk0
    cases pre <;> simp at e
  have hkq : kept = q.items := Option.some.inj (hkept.symm.trans hi)
  obtain ⟨-, hh, -⟩ := inlineInsn_read_drop hr
  obtain ⟨cand, br, out, hdi, hemit, hitems⟩ := inlineInsn_erased_dropped hr
  obtain ⟨cls, hmem, hseq⟩ := decodeInline_spec hdi
  obtain ⟨op, ops, hins, hfull, hmap⟩ := native_of_proto hD hpc hop hops (hhd.trans hh)
  refine ⟨op, ops, q.op, hins, hfull, ?_⟩
  have hshape := (H.inlineOk _ _ hmem).shape
  subst hdr
  have hk2 : kept = out ∨ ∃ i, ∃ d ∈ S.dr s.pc, out[i]? = some d.item ∧ kept = out.eraseIdx i := by
    rw [hkq]; exact hitems
  have hitk : it ∈ kept := by rw [e]; exact List.mem_append_right _ (List.mem_cons_self ..)
  have hito : it ∈ out := by
    rcases hk2 with h' | ⟨i, d, -, -, h'⟩
    · rw [← h']; exact hitk
    · rw [h'] at hitk; exact List.mem_of_mem_eraseIdx hitk
  have hout1 : ((S.used s.pc).emit cand).1 = out := by rw [hemit]
  obtain ⟨it0, hit0, m', hm', hrb', hmm'⟩ :=
    emit_reads hci.1 it (by rw [hout1]; exact hito) m hm hrb0
  rcases sequence_reads_frame hseq it0 hit0 m' hm' (by rw [← hrb']; exact hrb0) with
    hrbp | ⟨w, hcls⟩ | hcls
  · exfalso
    apply hb
    rw [hmm', hrbp]
    all_goals first | rfl | simp [R]
  · -- `load w`
    subst hcls
    obtain ⟨p, k, d, hop1, hcand⟩ := seq_load hseq
    subst hcand
    obtain ⟨xr, hcase⟩ := emit_load hci w p k d
    rw [hout1] at hcase
    refine .inl ⟨w, p, k, hshape, ops_plain_at hmap hop1 rfl, ?_⟩
    rcases hcase with hmiss | ⟨hhit, hreg⟩
    · -- a miss: the kept reload, then the pointer `ld`
      subst hmiss
      have hK : kept = [.ld .q false xr (X86.M.frame p), .ld w false xr ⟨xr, k⟩,
            .st w xr (X86.M.frame d)] ∨
          kept = [.ld .q false xr (X86.M.frame p), .ld w false xr ⟨xr, k⟩] := by
        rcases hk2 with h' | ⟨i, d', hd', hx, h'⟩
        · exact .inl h'
        · obtain ⟨w', r', off, hst⟩ := hforms d' hd'
          rw [hst] at hx
          rcases i with _ | _ | _ | i
          · simp at hx
          · simp at hx
          · exact .inr (by rw [h']; rfl)
          · simp at hx
      have hrdA : ∀ j < 8, ∀ o, P o →
          yh.ea (X86.M.frame p) + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o :=
        fun j hj o ho => hrd (.ld .q false xr (X86.M.frame p))
          (by rcases hK with h' | h' <;> rw [h'] <;> exact List.mem_cons_self ..)
          (X86.M.frame p) rfl rfl j hj o ho
      rcases hK with rfl | rfl
      · rcases split3 e with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
        · simp only [Item.mem?, Option.some.injEq] at hm; subst hm; exact absurd rfl hb
        · simp only [Item.mem?, Option.some.injEq] at hm; subst hm
          exact ⟨Nat.le_of_eq (by cases w <;> rfl), kpr_load_miss ha hrdA hy⟩
        · simp [readBytes, Frame.itemReadBytes] at hrb0
      · rcases split2 e with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
        · simp only [Item.mem?, Option.some.injEq] at hm; subst hm; exact absurd rfl hb
        · simp only [Item.mem?, Option.some.injEq] at hm; subst hm
          exact ⟨Nat.le_of_eq (by cases w <;> rfl), kpr_load_miss ha hrdA hy⟩
    · -- a hit: the pointer `ld` first, `xr` the cached slot
      subst hhit
      have hK : kept = [.ld w false xr ⟨xr, k⟩, .st w xr (X86.M.frame d)] ∨
          kept = [.ld w false xr ⟨xr, k⟩] := by
        rcases hk2 with h' | ⟨i, d', hd', hx, h'⟩
        · exact .inl h'
        · obtain ⟨w', r', off, hst⟩ := hforms d' hd'
          rw [hst] at hx
          rcases i with _ | _ | i
          · simp at hx
          · exact .inr (by rw [h']; rfl)
          · simp at hx
      rcases hK with rfl | rfl
      · rcases split2 e with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
        · simp only [Item.mem?, Option.some.injEq] at hm; subst hm
          exact ⟨Nat.le_of_eq (by cases w <;> rfl), kpr_load_hit ha hreg hy⟩
        · simp [readBytes, Frame.itemReadBytes] at hrb0
      · obtain ⟨rfl, rfl⟩ := split1 e
        simp only [Item.mem?, Option.some.injEq] at hm; subst hm
        exact ⟨Nat.le_of_eq (by cases w <;> rfl), kpr_load_hit ha hreg hy⟩
  · -- `addrSymInd`
    subst hcls
    obtain ⟨sy, d, hop1, hcand⟩ := seq_addrSymInd hseq
    subst hcand
    obtain ⟨xr, hcase⟩ := emit_addrSymInd hci sy d
    rw [hout1] at hcase
    subst hcase
    refine .inr ⟨sy, hshape, ops_plain_at hmap hop1 rfl, ?_⟩
    have hK : kept = [.loadRip xr (.sym sy), .ld .q false xr ⟨xr, 0⟩, .st .q xr (X86.M.frame d)] ∨
        kept = [.loadRip xr (.sym sy), .ld .q false xr ⟨xr, 0⟩] := by
      rcases hk2 with h' | ⟨i, d', hd', hx, h'⟩
      · exact .inl h'
      · obtain ⟨w', r', off, hst⟩ := hforms d' hd'
        rw [hst] at hx
        rcases i with _ | _ | _ | i
        · simp at hx
        · simp at hx
        · exact .inr (by rw [h']; rfl)
        · simp at hx
    have hlrA : ∀ j < 8, ∀ o, P o →
        S.ctx.addrOf (.sym sy) + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o :=
      fun j hj o ho => hlr (.loadRip xr (.sym sy))
        (by rcases hK with h' | h' <;> rw [h'] <;> exact List.mem_cons_self ..) _ _ rfl j hj o ho
    rcases hK with rfl | rfl
    · rcases split3 e with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
      · simp [Item.mem?] at hm
      · simp only [Item.mem?, Option.some.injEq] at hm; subst hm
        exact ⟨Nat.le_refl _, kpr_addrSymInd ha hlrA hy⟩
      · simp [readBytes, Frame.itemReadBytes] at hrb0
    · rcases split2 e with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
      · simp [Item.mem?] at hm
      · simp only [Item.mem?, Option.some.injEq] at hm; subst hm
        exact ⟨Nat.le_refl _, kpr_addrSymInd ha hlrA hy⟩

/-- `KeptPtrLive` after the scopes, from `kept_ptr_reads` and the inline op's successful `opSem`
after the scopes (`hrun`, what `RSafe`'s step gives: `CacheMem.step_of`), with `Rel` (from
`sep_after_scopes`) and `Globals` after the scopes (`hglob`, as `CacheMem.rip_step` takes it):
`load_ptr_live`, `addrSymInd_ptr_live`. -/
theorem keptPtrLive_of_step {S : Setup} (H : Hyps S) {C : Cert S} {s s1 : R.RState}
    {P : Int → Prop} (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hnt : ∀ d dr, S.dr s.pc = d :: dr → d.at_ = S.start s.pc →
      sortedContains S.targets (S.start s.pc) = false)
    (hforms : ∀ d ∈ S.dr s.pc, DroppedForm d)
    {y yh : X86.State} {kept : List Item} (hfr : FrameInv S s yh)
    (hci : CacheInv (S.used s.pc) yh) (hP : PatchOk S C s P) (he : EscSound S C s)
    (hI : KrInv S C s P) (hk : s.pc < S.c.d.insns.size) (hpc : s.pc < S.r.protos.size)
    (hin : InlineAt S s.pc) (hkept : S.c.d.items[s.pc]? = some kept)
    (ha : XAgreeAt (yh.reg .rbp) P y yh)
    (hrd : ∀ it ∈ kept, ∀ m, it.mem? = some m → m.base = .rbp → ∀ j < readBytes it, ∀ o, P o →
      yh.reg .rbp + m.disp.signExtend 64 + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o)
    (hlr : ∀ it ∈ kept, ∀ r to, it = .loadRip r to → ∀ j < 8, ∀ o, P o →
      S.ctx.addrOf to + BitVec.ofNat 64 j ≠ yh.reg .rbp + BitVec.ofInt 64 o)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hglob : Globals S.ctx S.c.ρ s1.st yh)
    (hrun : ∀ op ops f, S.c.d.insns[s.pc]? = some (.native op ops) → op.full = some f →
      ∃ vals ch ctl st', nativeVals S.c.ρ f ops = some vals ∧
        opSem f vals s1.st ch = .ok (ctl, st')) :
    KeptPtrLive S.ctx s1.st kept y := by
  obtain ⟨-, -, hrel⟩ := sep_after_scopes H hfr hP he hI hk hsc
  refine keptPtrLive_of_reads S.ctx s1.st kept y fun pre it post e y' hy m hm hb j hj => ?_
  obtain ⟨op, ops, f, hi, hf, hcase⟩ :=
    kept_ptr_reads H hD hpc hnt hforms hci hkept ha hrd hlr pre it post e y' hy m hm hb (by omega)
  obtain ⟨vals, ch, ctl, st', hv, hsem⟩ := hrun op ops f hi hf
  rcases hcase with ⟨w, pp, k', hsh, hop, hrb, hea⟩ | ⟨sy, hsh, hop, hrb, hea⟩
  · obtain ⟨id, a, hg, hl, hlt⟩ := load_ptr_live w hsh hv hsem hrel pp k' hop
    exact ⟨id, a, hg, hl, by rw [hea]; exact hlt j (by omega)⟩
  · obtain ⟨id, a, hg, hl, hlt⟩ := addrSymInd_ptr_live hsh hv hsem hglob sy hop
    exact ⟨id, a, hg, hl, by rw [hea]; exact hlt j (by omega)⟩

end

/-- `keptPtrApart_of_live` with the allocations after the scopes (the form `keptPtrLive_of_step`
gives). -/
theorem keptPtrApart_after_scopes {S : Setup} (H : Hyps S) {C : Cert S} {s s1 : R.RState} {P : Int → Prop}
    {y yh : X86.State} {kept : List Item} (hfr : FrameInv S s yh) (hP : PatchOk S C s P)
    (he : EscSound S C s) (hI : KrInv S C s P) (hk : s.pc < S.c.d.insns.size)
    (hsc : (S.c.scopesAt s.pc).foldlM R.applyScope s = .ok s1)
    (hlive : KeptPtrLive S.ctx s1.st kept y) :
    KeptPtrApart S.ctx (yh.reg .rbp) P kept y := by
  obtain ⟨hown, hpriv, _⟩ := sep_after_scopes H hfr hP he hI hk hsc
  refine keptPtrApart_of_own S.ctx rfl hown (fun o ho => ?_) kept y hlive
  obtain ⟨⟨h1, h2⟩, _, _, _⟩ := hP o ho
  refine ⟨h1, ?_, hpriv o ho⟩
  first
    | omega
    | (show o < 16 + (S.c.argSize : Int); omega)
    | (unfold Setup.K; omega)
    | (simp only [Setup.K]; omega)

end Ryo.Proofs.DeadStore
