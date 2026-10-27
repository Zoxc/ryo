/-
Ryo.Proofs.DecodeLink.Links — the decoder-to-shape links (aot.md §C2, toward M3
`decode_sound`): when the decoder accepts an instruction at position `p`, the code bytes at `p`
are `CodeAt` of the item list the instruction's shape lemma runs, with the operands it takes.

**Hypotheses** (`LinkOk ctx m c rs`): the cursor reads an object's code with its relocations
(`Fields.relocs`, sorted), in the frame-pointer form (`spFrame = none`), the code below `2 ^ 32`
bytes, and memory holds the code linked at `ctx.base` (`RelocLoaded`); and the instruction
starts at a relocation `Boundary` (each link gives the boundary after it). Targets are byte
positions here (`tgt.toNat`); `Ryo.Proofs.DecodeLink.Targets` turns them into instruction
indices with `pos32 r t = tgt`.

- `link_handler`: `handler h args then` at `c.pos`: `setupItems mode args` and `call h` there
  (`h` the opcode `ofNat? n` gives, with a handler: `Shapes.handler_step_op`'s items), then
  `ThenAt`: nothing (`op`/`lpad`), `test al, al; jz/jnz tgt` with `then = branch neg tgt`
  (`handler_step_br`), `ud2` (`handler_step_trap`), or `Switch.switchItems tb` with the entries
  at `tb` (`switch_tail`), the `then` table their targets (`tableEntry_itemAt`,
  `entries_codeAt`: the entries in memory given a boundary at `tb`, i.e. no relocation starting
  in the `int3` padding, which the decoder doesn't check). Not for a dense switch whose index
  computation stands in for the call (`denseSwitch`, a hypothesis): its link is still to do.
- `link_jmp`, `link_unreachable`, `link_ret`, `link_island`: `jmp tgt` (`jmp_step`), `ud2`
  (`unreachable_step`), `retLoads k.toNat src ++ epilogue F mode ++ [ret]` with `F` the frame size
  (`ret_step`), `islandPre` and the rodata operand words (`island_sound`).
- `link_arg`: `argStore a d pe` with `r = word a`, `ArgReg.of? r` defined; `of_word_eq`: its
  result is `a` when `a.size < 32` and `a.index < 2 ^ 24` (what `ArgRet.arg_step` needs);
  `DecodeLink.Arg` proves the bounds of `argInsn`'s `a` (`link_arg_exact`).
-/
import Ryo.Proofs.DecodeLink.Read
set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

/-- What the links assume of the code being read and the memory: the cursor reads an object's
code with its sorted relocations, in the frame-pointer form, below `2 ^ 32` bytes, and memory
holds that code linked (`RelocLoaded`). -/
structure LinkOk (ctx : Ctx) (m : Mem) (c : Cursor) (rs : Array Reloc) : Prop where
  fields : c.fields = .relocs rs
  sorted : Sorted rs
  loaded : RelocLoaded ctx m c.code rs
  small : c.code.size < 2 ^ 32
  fp : c.spFrame = none

theorem LinkOk.dec {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} (hk : LinkOk ctx m c rs)
    {p q : Nat} {items : List Item} (hd : Dec c p items q) (hb : Boundary rs p) :
    CodeAt ctx m items p ∧ q = p + codeSize items ∧ Boundary rs q :=
  codeAt_of_dec hk.fields hk.sorted hk.loaded hk.small hk.fp hd hb

/-- A jump table entry `Cursor.tableEntry` accepts is the item `tableEntry base e` in memory. -/
theorem tableEntry_itemAt {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) {base e : BitVec 32} (hb : Boundary rs c.pos)
    (h : c.tableEntry base = some e) :
    ItemAt ctx m (.tableEntry base e) c.pos ∧ Boundary rs (c.pos + 4) := by
  have hr : c.relocsHere 4 = [] := by
    by_cases h1 : c.relocsHere 4 = []
    · exact h1
    · simp [Cursor.tableEntry, h1] at h
  have hr' : relocsIn rs c.pos 4 = [] := by simpa [Cursor.relocsHere, hk.fields] using hr
  have hle : c.pos + 4 ≤ c.code.size := by
    by_cases h2 : c.pos + 4 ≤ c.code.size
    · exact h2
    · simp [Cursor.tableEntry, Cursor.i32At, Cursor.bytes, hr, h2] at h
  have none_in : ∀ r ∈ rs.toList, ¬ (c.pos ≤ r.pos ∧ r.pos < c.pos + 4) := by
    intro r hr0 hin
    have := (mem_relocsIn hk.sorted c.pos 4 r).mpr ⟨hr0, hin⟩
    rw [hr'] at this; cases this
  let m' : Mem := fun a =>
    if h : (a - ctx.base).toNat < c.code.size then c.code[(a - ctx.base).toNat] else m a
  have hsub : ∀ j, j < c.code.size → (ctx.base + BitVec.ofNat 64 j - ctx.base).toNat = j := by
    intro j hj
    rw [show ctx.base + BitVec.ofNat 64 j - ctx.base = BitVec.ofNat 64 j by bv_omega, BitVec.toNat_ofNat]
    exact Nat.mod_eq_of_lt (by have := hk.small; omega)
  have hl : CodeLoaded ctx m' c.code := by
    intro j hj
    simp only [Array.length_toList] at hj
    simp only [m', hsub j hj, hj, dite_true, Array.getElem_toList]
  have hi := Switch.cursor_tableEntry_itemAt hl h
  refine ⟨?_, ?_⟩
  · intro j hj
    have hj4 : j < 4 := by simpa [Switch.linkedAt_tableEntry, leBytes] using hj
    rw [← hi j hj, addrAt_add']
    simp only [m', addrAt]
    rw [hsub _ (by omega), dite_eq_left_of_eq_true (eq_true (by omega))]
    rw [← hk.loaded.1 (c.pos + j) (by omega)]
    · rfl
    · rintro r hr0 ⟨h1, h2⟩
      by_cases h0 : r.pos < c.pos
      · have := hb r hr0 h0; omega
      · exact none_in r hr0 ⟨by omega, by omega⟩
  · intro r hr0 hlt
    by_cases h0 : r.pos < c.pos
    · have := hb r hr0 h0; omega
    · exact absurd ⟨by omega, hlt⟩ (none_in r hr0)

/-- The entries `table` read are in memory from the table's start, given a boundary there. -/
theorem entries_codeAt {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc}
    (hk : LinkOk ctx m c rs) {tb : BitVec 32} :
    ∀ {es : List (BitVec 32)} {q : Nat},
      (∀ i (hi : i < es.length), (atPos c (q + 4 * i)).tableEntry tb = some es[i]) →
      Boundary rs q → CodeAt ctx m (es.map (Item.tableEntry tb)) q
  | [], _, _, _ => trivial
  | e :: es, q, h, hb => by
    have hk' : LinkOk ctx m (atPos c q) rs := ⟨hk.fields, hk.sorted, hk.loaded, hk.small, hk.fp⟩
    obtain ⟨hi, hb'⟩ := tableEntry_itemAt hk' hb (by simpa using h 0 (by simp))
    refine ⟨hi, ?_⟩
    rw [Switch.tableEntry_size]
    exact entries_codeAt hk (fun i hi => by
      have := h (i + 1) (by simpa using hi)
      simpa [Nat.mul_succ, Nat.add_assoc, Nat.add_comm 4] using this) hb'

end Ryo.Proofs.DecodeLink
namespace Ryo.Proofs.DecodeLink

open Ryo.X86 Ryo.Vm Ryo.Vm.R Ryo.Vm.Asm

theorem LinkOk.atPos {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} (hk : LinkOk ctx m c rs)
    (p : Nat) : LinkOk ctx m (atPos c p) rs := ⟨hk.fields, hk.sorted, hk.loaded, hk.small, hk.fp⟩

/-- The control flow after a handler call in memory from `p`, as `thenSeq` read it (`t` with
byte-position targets; `c'` the cursor after it). -/
inductive ThenAt (ctx : Ctx) (m : Mem) (rs : Array Reloc) (op : Full.Opcode) :
    Then Nat → Nat → Cursor → Prop
  | next {p : Nat} {c' : Cursor} : op.info.shape = .op ∨ op.info.shape = .lpad → c'.pos = p →
      ThenAt ctx m rs op .next p c'
  | br {p : Nat} {c' : Cursor} {neg : Bool} {tgt : BitVec 32} {long : Bool} :
      op.info.shape = .br →
      CodeAt ctx m [.testAl, .branch (if neg then .z else .nz) tgt long] p →
      c'.pos = p + codeSize [.testAl, .branch (if neg then .z else .nz) tgt long] →
      Boundary rs c'.pos → ThenAt ctx m rs op (.branch neg tgt.toNat) p c'
  | switch {p : Nat} {c' : Cursor} {tb : BitVec 32} {es : List (BitVec 32)} :
      op.info.shape = .switch → CodeAt ctx m (Switch.switchItems tb) p →
      (Boundary rs tb.toNat → CodeAt ctx m (es.map (Item.tableEntry tb)) tb.toNat) →
      c'.pos = tb.toNat + 4 * es.length → ThenAt ctx m rs op (.table (es.map (·.toNat))) p c'
  | trap {p : Nat} {c' : Cursor} : op.info.shape = .trap → CodeAt ctx m [.ud2] p →
      c'.pos = p + codeSize [.ud2] → Boundary rs c'.pos → ThenAt ctx m rs op .trap p c'

theorem thenAt_of_read {ctx : Ctx} {m : Mem} {c : Cursor} {rs : Array Reloc} (hk : LinkOk ctx m c rs)
    {op : Full.Opcode} {nn : Nat} {t : Then Nat} {c' : Cursor} (hb : Boundary rs c.pos)
    (h : ThenRead op nn c t c') : ThenAt ctx m rs op t c.pos c' := by
  cases h with
  | next hs => exact .next hs rfl
  | br hs hc hd he =>
    rename_i cond tgt long
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    have e : cond = (if (cond == Cond.z) = true then Cond.z else Cond.nz) := by
      rcases hc with rfl | rfl <;> rfl
    rw [e] at hca hq
    exact .br hs hca hq hb'
  | switch hs ht =>
    obtain ⟨tb, pE, es, hd, rfl, hes, rfl⟩ := table_read ht
    obtain ⟨hca, -, -⟩ := hk.dec hd hb
    exact .switch hs hca (fun hb' => entries_codeAt hk hes hb') rfl
  | trap hs hd he =>
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    exact .trap hs hca hq hb'

set_option maxRecDepth 100000 in
theorem noHandler : Full.Opcode.jmp.hasHandler = false ∧ Full.Opcode.ret.hasHandler = false ∧
    Full.Opcode.unreachable.hasHandler = false ∧ Full.Opcode.island.hasHandler = false := by
  decide

/-- A handler call the decoder read at `c.pos` (`insn`): `setupItems` of its arguments and
`call h` there (`Shapes.handler_step_op`/`_br`/`_trap`'s items, `h = q.op` with
`ofNat? n = some h`), then its shape's control flow (`ThenAt`). -/
theorem link_handler {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Frame}
    {ro : ByteArray} {q : Proto} {args : List Arg} {t : Then Nat} (hk : LinkOk ctx m c rs)
    (hb : Boundary rs c.pos) (h : (insn fr ro).run c = .ok (q, c'))
    (hh : q.handler = some (args, t)) (hnd : ∀ c'', (denseSwitch fr).run c ≠ .ok (some q, c''))
    (hrg : fr.region = false) :
    ∃ n items, Full.Opcode.ofNat? n = some q.op ∧ q.op.hasHandler = true ∧
      Handler.setupItems fr.mode args = some items ∧
      CodeAt ctx m (items ++ [.call (.handler n)]) c.pos ∧
      ThenAt ctx m rs q.op t (c.pos + codeSize (items ++ [.call (.handler n)])) c' := by
  cases insn_read h with
  | handler hd hi hn hhh hs ht =>
    rename_i items hat n len nn op args' t' sites
    simp only [Option.some.injEq, Prod.mk.injEq] at hh
    obtain ⟨rfl, rfl⟩ := hh
    have hd' : Dec c c.pos (items ++ [.call (.handler n)]) (hat + len) :=
      hd.append (Dec.single hi)
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd' hb
    refine ⟨n, items, hn, hhh, hs, hca, ?_⟩
    rw [← hq]
    exact thenAt_of_read (hk.atPos _) hb' (thenSeq_read ht)
  | ret => cases hh
  | unreachable => cases hh
  | jmp => cases hh
  | island => cases hh
  | resume h1 => rw [hrg] at h1; cases h1
  | dense hd => exact (hnd _ hd).elim

/-- `jmp`: the item `jmp tgt` (`Shapes.jmp_step`), the operand its target's position. -/
theorem link_jmp {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Frame}
    {ro : ByteArray} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (insn fr ro).run c = .ok (q, c')) (hop : q.op = .jmp) :
    ∃ tgt long, q.ops = [.target tgt.toNat] ∧ q.handler = none ∧
      CodeAt ctx m [.branch .always tgt long] c.pos ∧
      c'.pos = c.pos + codeSize [.branch .always tgt long] ∧ Boundary rs c'.pos := by
  cases insn_read h with
  | @handler _ _ _ _ _ op _ _ _ _ _ _ hn hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | dense hd =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hd
    rw [hw] at hop; cases w <;> exact absurd hop (by decide)
  | @jmp tgt long len hi =>
    obtain ⟨hca, hq, hb'⟩ := hk.dec (Dec.single hi) hb
    exact ⟨tgt, long, rfl, rfl, hca, hq, hb'⟩

/-- `unreachable`: a bare `ud2` (`Shapes.unreachable_step`), no operands. -/
theorem link_unreachable {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Frame}
    {ro : ByteArray} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (insn fr ro).run c = .ok (q, c')) (hop : q.op = .unreachable) :
    q.ops = [] ∧ q.handler = none ∧ CodeAt ctx m [.ud2] c.pos ∧
      c'.pos = c.pos + codeSize [.ud2] ∧ Boundary rs c'.pos := by
  cases insn_read h with
  | @handler _ _ _ _ _ op _ _ _ _ _ _ hn hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | ret => simp only at hop; exact absurd hop (by decide)
  | jmp => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | dense hd =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hd
    rw [hw] at hop; cases w <;> exact absurd hop (by decide)
  | unreachable hi =>
    obtain ⟨hca, hq, hb'⟩ := hk.dec (Dec.single hi) hb
    exact ⟨rfl, rfl, hca, hq, hb'⟩

/-- `ret src, k`: the return value loads, the epilogue of the frame and `ret` (`ArgRet.ret_step`'s
items `retLoads k.toNat src ++ epilogue F mode ++ [ret]`, `F` the frame size). -/
theorem link_ret {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Frame}
    {ro : ByteArray} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (insn fr ro).run c = .ok (q, c')) (hop : q.op = .ret) :
    ∃ (src : BitVec 32) (k : BitVec 64), q.ops = [.slot src, .imm k] ∧ q.handler = none ∧
      CodeAt ctx m (retLoads k.toNat src ++ (epilogue fr.size fr.mode ++ [.ret])) c.pos ∧
      c'.pos = c.pos + codeSize (retLoads k.toNat src ++ (epilogue fr.size fr.mode ++ [.ret])) ∧
      Boundary rs c'.pos := by
  cases insn_read h with
  | @handler _ _ _ _ _ op _ _ _ _ _ _ hn hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | jmp => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | dense hd =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hd
    rw [hw] at hop; cases w <;> exact absurd hop (by decide)
  | @ret s k c'' hr =>
    obtain ⟨hd, -, hk32⟩ := retSeq_read hr
    have hkk : (BitVec.ofNat 64 k).toNat = k := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    refine ⟨s, BitVec.ofNat 64 k, rfl, rfl, ?_⟩
    rw [hkk]
    exact ⟨hca, hq, hb'⟩

/-- `island isl, ops`: `islandPre` (`Island.island_sound`'s items), the
operand words the array at rodata offset `o` holds. -/
theorem link_island {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {fr : Frame}
    {ro : ByteArray} {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (insn fr ro).run c = .ok (q, c')) (hop : q.op = .island) :
    ∃ isl o ws, q.ops = [.sym isl, .words ws] ∧ q.handler = none ∧ opsArray ro o = some ws ∧
      CodeAt ctx m (Island.islandPre fr.mode isl o) c.pos ∧
      c'.pos = c.pos + codeSize (Island.islandPre fr.mode isl o) ∧
      Boundary rs c'.pos := by
  cases insn_read h with
  | @handler _ _ _ _ _ op _ _ _ _ _ _ hn hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | jmp => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | ret => simp only at hop; exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | dense hd =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hd
    rw [hw] at hop; cases w <;> exact absurd hop (by decide)
  | @island isl o site ws c'' hi hws =>
    obtain ⟨hd, -⟩ := islandCall_read hi
    obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
    exact ⟨isl, o, ws, rfl, rfl, hws, hca, hq, hb'⟩

/-! ### `arg` -/

/-- `arg d, r`: the stores `argStore a d pe` of the argument register, `r` the word of `a`, which
`ArgReg.of?` accepts (`ArgRet.arg_step` takes `ArgReg.of? r.toNat true = some a'` and the items
`argStore a' d pe`: `of_word_eq` gives `a' = a` when `a`'s size is below 32 and its index
below `2 ^ 24`). -/
theorem link_arg {ctx : Ctx} {m : Mem} {c c' : Cursor} {rs : Array Reloc} {mode : Mode}
    {q : Proto} (hk : LinkOk ctx m c rs) (hb : Boundary rs c.pos)
    (h : (argInsn mode).run c = .ok (some q, c')) :
    ∃ (a : ArgReg) (d : BitVec 32), q.op = .arg ∧
      q.ops = [.slot d, .imm (BitVec.ofNat 64 a.word)] ∧ q.handler = none ∧
      (BitVec.ofNat 64 a.word).toNat = a.word ∧ (ArgReg.of? a.word true).isSome ∧
      CodeAt ctx m (argStore a d mode.pe) c.pos ∧
      c'.pos = c.pos + codeSize (argStore a d mode.pe) ∧ Boundary rs c'.pos := by
  obtain ⟨a, d, rfl, hof, hd, -⟩ := argInsn_read h
  obtain ⟨hca, hq, hb'⟩ := hk.dec hd hb
  refine ⟨a, d, rfl, rfl, rfl, ?_, hof, hca, hq, hb'⟩
  rw [BitVec.toNat_ofNat]
  apply Nat.mod_eq_of_lt
  have : a.word < 2 ^ 32 := Nat.mod_lt _ (by decide)
  omega

theorem low_parts : ∀ x : Bool, ∀ s : Fin 32,
    let L := s.val ||| (if x then 32 else 0)
    L < 64 ∧ L % 32 = s.val ∧ (L &&& 32 != 0) = x := by decide

theorem shl8_and32 (i : Nat) : i <<< 8 &&& 32 = 0 := by
  apply Nat.eq_of_testBit_eq; intro j
  simp only [Nat.testBit_and, Nat.testBit_shiftLeft, Nat.zero_testBit]
  by_cases hj : j = 5
  · subst hj; simp
  · rw [show (32 : Nat) = 2 ^ 5 by rfl, Nat.testBit_two_pow]; simp [Ne.symm hj]

theorem word_parts (x : Bool) (s i : Nat) (hs : s < 32) (hi : i < 2 ^ 24) :
    Ryo.Vm.R.u32 (s ||| (if x then 32 else 0) ||| (i <<< 8)) &&& 0x1f = s ∧
    (Ryo.Vm.R.u32 (s ||| (if x then 32 else 0) ||| (i <<< 8)) &&& 0x20 != 0) = x ∧
    Ryo.Vm.R.u32 (s ||| (if x then 32 else 0) ||| (i <<< 8)) >>> 8 = i := by
  obtain ⟨hL, hm, hb⟩ := low_parts x ⟨s, hs⟩
  simp only at hL hm hb
  generalize s ||| (if x then 32 else 0) = L at hL hm hb ⊢
  have e : L ||| i <<< 8 = i <<< 8 + L := by
    rw [Nat.or_comm, Nat.shiftLeft_add_eq_or_of_lt (by omega)]
  have hw : Ryo.Vm.R.u32 (L ||| i <<< 8) = i <<< 8 + L := by
    simp only [Ryo.Vm.R.u32, e]
    apply Nat.mod_eq_of_lt; rw [Nat.shiftLeft_eq]; omega
  rw [hw]
  refine ⟨?_, ?_, ?_⟩
  · rw [show (0x1f : Nat) = 2 ^ 5 - 1 by rfl, Nat.and_two_pow_sub_one_eq_mod, Nat.shiftLeft_eq]; omega
  · rw [Nat.shiftLeft_add_eq_or_of_lt (by omega), Nat.and_or_distrib_right, shl8_and32]
    simpa using hb
  · rw [Nat.shiftRight_eq_div_pow, Nat.shiftLeft_eq]; omega

theorem ite_some_eq {α : Type} {p : Prop} [Decidable p] {a b : α}
    (h : (if p then some a else none) = some b) : b = a := by
  split at h
  · exact (Option.some.inj h).symm
  · cases h

theorem of_word_eq {a b : ArgReg} (hs : a.size < 32) (hi : a.index < 2 ^ 24)
    (h : ArgReg.of? a.word true = some b) : b = a := by
  obtain ⟨h1, h2, h3⟩ := word_parts a.xmm a.size a.index hs hi
  have hb : b = ⟨a.word &&& 0x20 != 0, a.word &&& 0x1f, a.word >>> 8⟩ := by
    dsimp only [ArgReg.of?] at h
    exact ite_some_eq h
  subst hb
  obtain ⟨x, s, i⟩ := a
  simp only [ArgReg.word] at h1 h2 h3 ⊢
  rw [h1, h2, h3]

end Ryo.Proofs.DecodeLink
