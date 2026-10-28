/-
Ryo.Proofs.Switch — the jump of a switch (aot.md §C2 "Shapes", `switch`): after the handler
returns its index in `rax` (`Ryo.Proofs.Handler`, `CtlIn (.index i)`), the decoder's tail
`table` (`Ryo.Vm.DecodeReduced`: `lea rcx, [rip + table]; movsxd rax, [rcx + rax*4];
add rax, rcx; jmp rax`, the `int3` padding, then the entries), fetched from memory
(`Ryo.X86.Fetch`), reaches the entry's target.

- `switchItems t`: the four items, `t` the table's function position (`leaTable t`).
- An entry is the item `tableEntry t e`: the 4 bytes of `e - t`, relative to the table start;
  the decoder reads one as `t + i32` (`Cursor.tableEntry`, `cursor_tableEntry_itemAt`: what it
  accepts in loaded code is that item there). The table of `n + 1` entries (`table (n + 1)` in
  `thenSeq`) is `CodeAt` of `es.map (tableEntry t)` from `t`.
- `switch_tail`: from `rax = i` with `i < es.length`, the four items in memory at `rip`, and
  the table in memory, `Steps` reach `rip = ctx.base + es[i]`, with `rax` that address,
  `rcx` the table's, the flags `add`'s, and everything else (other registers, `xmm`s,
  memory) unchanged; it is also what `execItems` gives.

One hypothesis beyond the decoder's checks: the table's and the target's positions are below
`2 ^ 31`. `movsxd` sign-extends the 32-bit entry and `add rax, rcx` adds it in 64 bits, which is
`t + (e - t) = e` only without 32-bit wraparound; a function under 2 GiB satisfies it (the
decoder computes `t + i32` in 32 bits).
-/
import Ryo.X86.Fetch
import Ryo.X86.Decode

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Switch

open Ryo.X86

/-! ### State accessors -/

section
variable (s : State)

@[simp] theorem reg_jump (a : BitVec 64) (r : Reg) : (s.jump a).reg r = s.reg r := rfl
@[simp] theorem mem_jump (a : BitVec 64) : (s.jump a).mem = s.mem := rfl
@[simp] theorem xmm_jump (a : BitVec 64) : (s.jump a).xmm = s.xmm := rfl
@[simp] theorem rip_jump (a : BitVec 64) : (s.jump a).rip = a := rfl
@[simp] theorem mem_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).mem = s.mem := rfl
@[simp] theorem xmm_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).xmm = s.xmm := rfl
@[simp] theorem rip_setReg (r : Reg) (v : BitVec 64) : (s.setReg r v).rip = s.rip := rfl
@[simp] theorem reg_setFlags (f : Flags) (r : Reg) : (s.setFlags f).reg r = s.reg r := rfl
@[simp] theorem mem_setFlags (f : Flags) : (s.setFlags f).mem = s.mem := rfl
@[simp] theorem xmm_setFlags (f : Flags) : (s.setFlags f).xmm = s.xmm := rfl
@[simp] theorem rip_setFlags (f : Flags) : (s.setFlags f).rip = s.rip := rfl

end

/-! ### The items -/

/-- The switch's jump: `lea rcx, [rip + t]; movsxd rax, [rcx + rax*4]; add rax, rcx;
jmp rax`. -/
def switchItems (t : BitVec 32) : List Item :=
  [.leaTable t, .loadTableEntry, .addRaxRcx, .jmpRax]

theorem except_ok_inj {ε α : Type} {a b : α} (h : (Except.ok a : Except ε α) = .ok b) : a = b := by
  cases h; rfl

theorem leaTable_straight (ctx : Ctx) (t : BitVec 32) :
    (Item.leaTable t).FallsThrough ctx ∧ (Item.leaTable t).MemKept ctx :=
  ⟨fun _ _ h => by cases except_ok_inj h; rfl, fun _ _ h => by cases except_ok_inj h; rfl⟩

theorem loadTableEntry_straight (ctx : Ctx) :
    Item.loadTableEntry.FallsThrough ctx ∧ Item.loadTableEntry.MemKept ctx :=
  ⟨fun _ _ h => by cases except_ok_inj h; rfl, fun _ _ h => by cases except_ok_inj h; rfl⟩

theorem addRaxRcx_straight (ctx : Ctx) :
    Item.addRaxRcx.FallsThrough ctx ∧ Item.addRaxRcx.MemKept ctx :=
  ⟨fun _ _ h => by cases except_ok_inj h; rfl, fun _ _ h => by cases except_ok_inj h; rfl⟩

/-! ### The table -/

theorem tableEntry_size (t e : BitVec 32) : (Item.tableEntry t e).size = 4 := by
  simp [Item.size, Item.len, Item.encode, leBytes]

theorem linkedAt_tableEntry (ctx : Ctx) (t e : BitVec 32) (p : Nat) :
    (Item.tableEntry t e).linkedAt ctx p = leBytes (e - t) 4 := by
  simp [Item.linkedAt, Item.encode, link]

/-- Entry `i` of a table in memory from position `p` is at `p + 4 * i`. -/
theorem entry_at {ctx : Ctx} {m : Mem} {t : BitVec 32} :
    ∀ {es : List (BitVec 32)} {p i : Nat}, CodeAt ctx m (es.map (Item.tableEntry t)) p →
      (hi : i < es.length) → ItemAt ctx m (.tableEntry t es[i]) (p + 4 * i)
  | _ :: _, _, 0, h, _ => by simpa using h.1
  | e :: es, p, i + 1, h, hi => by
    have := entry_at (es := es) (i := i) h.2 (by simpa using hi)
    rw [tableEntry_size] at this
    simpa [Nat.mul_succ, Nat.add_assoc, Nat.add_comm 4] using this

/-- Four little-endian bytes in memory, read back. -/
theorem readNat_leBytes4 (m : Mem) (a : BitVec 64) (v : BitVec 32)
    (h : BytesAt m a (leBytes v 4)) : m.readNat a 4 = v.toNat := by
  have h0 := h 0 (by simp [leBytes])
  have h1 := h 1 (by simp [leBytes])
  have h2 := h 2 (by simp [leBytes])
  have h3 := h 3 (by simp [leBytes])
  simp only [leBytes, List.getElem_map, List.getElem_range] at h0 h1 h2 h3
  simp only [Mem.readNat, List.range_succ, List.range_zero, List.nil_append, List.foldr_cons,
    List.foldr_nil, List.cons_append]
  rw [h0, h1, h2, h3]
  simp only [Nat.shiftRight_eq_div_pow, UInt8.toNat_ofNat', Nat.mul_zero, Nat.pow_zero,
    Nat.div_one]
  have := v.isLt
  omega

/-- The decoder's entry, `t + i32`, is the item `tableEntry t e` there: four bytes that are the
little-endian `e - t`. -/
theorem leBytes_ofLeBytes4 (L : List UInt8) (hL : L.length = 4) :
    leBytes (BitVec.ofNat 32 (ofLeBytes L)) 4 = L := by
  match L, hL with
  | [a, b, c, d], _ =>
    have ha := a.toNat_lt
    have hb := b.toNat_lt
    have hc := c.toNat_lt
    have hd := d.toNat_lt
    simp only [leBytes, ofLeBytes, List.range_succ, List.range_zero, List.nil_append,
      List.map_cons, List.map_nil, List.cons_append, List.foldr_cons,
      List.foldr_nil, BitVec.toNat_ofNat, Nat.shiftRight_eq_div_pow, List.cons.injEq,
      and_true]
    refine ⟨?_, ?_, ?_, ?_⟩ <;> apply UInt8.toNat.inj <;>
      simp only [UInt8.toNat_ofNat'] <;> omega

/-- What `Cursor.tableEntry` accepts, in code loaded at `ctx.base`, is the item
`tableEntry base e` at the cursor's position. -/
theorem cursor_tableEntry_itemAt {ctx : Ctx} {m : Mem} {c : Cursor} {base e : BitVec 32}
    (hl : CodeLoaded ctx m c.code) (h : c.tableEntry base = some e) :
    ItemAt ctx m (.tableEntry base e) c.pos := by
  simp only [Cursor.tableEntry, Cursor.i32At, Cursor.bytes] at h
  split at h
  · cases h
  · split at h
    · rename_i hle
      change some (base + BitVec.ofNat 32
        (ofLeBytes (c.code.extract c.pos (c.pos + 4)).toList)) = some e at h
      cases h
      have hlen : (c.code.extract c.pos (c.pos + 4)).toList.length = 4 := by
        simp only [Array.length_toList, Array.size_extract]; omega
      have hsub : ∀ a v : BitVec 32, a + v - a = v := fun a v => by
        apply BitVec.eq_of_toNat_eq
        simp only [BitVec.toNat_sub, BitVec.toNat_add]
        have := a.isLt; have := v.isLt
        omega
      simp only [ItemAt, linkedAt_tableEntry, hsub, leBytes_ofLeBytes4 _ hlen]
      intro j hj
      have hj4 : j < 4 := hlen ▸ hj
      have := hl (c.pos + j) (by simp only [Array.length_toList]; omega)
      simp only [addrAt, BitVec.add_assoc, ← BitVec.ofNat_add]
      rw [this]
      simp only [Array.getElem_toList, Array.getElem_extract]
    · simp at h

/-! ### The jump -/

theorem sext_sub_add (e t : BitVec 32) (he : e.toNat < 2 ^ 31) (ht : t.toNat < 2 ^ 31) :
    (e - t).signExtend 64 + t.setWidth 64 = e.setWidth 64 := by
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_add, BitVec.toNat_signExtend]
  simp only [BitVec.toNat_setWidth, BitVec.toNat_sub, BitVec.msb_eq_decide]
  split <;> rename_i h <;> simp at h <;> omega

theorem table_addr (b : BitVec 64) (t : BitVec 32) (i : Nat) :
    b + t.setWidth 64 + (BitVec.ofNat 64 i <<< 2) = addrAt ⟨b, fun _ => 0, false⟩ (t.toNat + 4 * i) := by
  apply BitVec.eq_of_toNat_eq
  simp [addrAt, BitVec.toNat_add, BitVec.toNat_shiftLeft, BitVec.toNat_setWidth,
    Nat.shiftLeft_eq]
  omega

/-- The switch's jump, run as `execItems`: `rip` and `rax` are the entry's target. -/
theorem exec_switch {ctx : Ctx} {t : BitVec 32} {es : List (BitVec 32)} {i : Nat}
    {x : State} (ht : CodeAt ctx x.mem (es.map (Item.tableEntry t)) t.toNat)
    (hi : i < es.length) (hrax : x.reg .rax = BitVec.ofNat 64 i)
    (htb : t.toNat < 2 ^ 31) (heb : es[i].toNat < 2 ^ 31) :
    ∃ x', execItems ctx (switchItems t) x = .ok x' ∧
      x'.rip = addrAt ctx es[i].toNat ∧ x'.reg .rax = addrAt ctx es[i].toNat ∧
      x'.reg .rcx = addrAt ctx t.toNat ∧ x'.mem = x.mem ∧ x'.xmm = x.xmm ∧
      ∀ r : Reg, r.idx ≠ Reg.rax.idx → r.idx ≠ Reg.rcx.idx → x'.reg r = x.reg r := by
  have he := entry_at ht hi
  simp only [ItemAt, linkedAt_tableEntry] at he
  have hr := readNat_leBytes4 _ _ _ he
  have hrc : Reg.rax.idx ≠ Reg.rcx.idx := by decide
  have hcr : Reg.rcx.idx ≠ Reg.rax.idx := by decide
  have hA' : ∀ n, addrAt ⟨ctx.base, fun _ => 0, false⟩ n = addrAt ctx n := fun _ => rfl
  have htarget : BitVec.signExtend 64 (BitVec.ofNat 32 (es[i] - t).toNat) +
      (ctx.base + BitVec.setWidth 64 t) = addrAt ctx es[i].toNat := by
    rw [BitVec.ofNat_toNat, BitVec.setWidth_eq, BitVec.add_comm ctx.base, ← BitVec.add_assoc,
      sext_sub_add _ _ heb htb, BitVec.add_comm]
    show ctx.base + _ = ctx.base + _
    apply congrArg
    apply BitVec.eq_of_toNat_eq
    simp
  refine ⟨_, rfl, ?_⟩
  simp only [State.memW, W.bits, Nat.reduceDiv, mem_jump, mem_setReg, mem_setFlags,
    reg_jump, reg_setFlags, State.reg_setReg, State.reg_setReg_other _ _ _ _ hrc,
    State.reg_setReg_other _ _ _ _ hcr, hrax, table_addr, hA', hr, htarget, rip_jump,
    xmm_jump, xmm_setReg, xmm_setFlags]
  refine ⟨trivial, trivial, ?_, trivial, trivial, fun r h1 h2 => ?_⟩
  · show ctx.base + _ = ctx.base + _
    apply congrArg
    apply BitVec.eq_of_toNat_eq
    simp
  simp only [reg_jump, State.reg_setReg_other _ _ _ _ h1,
    State.reg_setReg_other _ _ _ _ h2]

/-- The switch's tail (see the module comment): from `rax = i`, the jump and the table in
memory, fetching reaches entry `i`'s target. -/
theorem switch_tail {ctx : Ctx} {pos : Nat} {t : BitVec 32} {es : List (BitVec 32)} {i : Nat}
    {x : State} (hc : CodeAt ctx x.mem (switchItems t) pos) (hrip : x.rip = addrAt ctx pos)
    (ht : CodeAt ctx x.mem (es.map (Item.tableEntry t)) t.toNat)
    (hi : i < es.length) (hrax : x.reg .rax = BitVec.ofNat 64 i)
    (htb : t.toNat < 2 ^ 31) (heb : es[i].toNat < 2 ^ 31) :
    ∃ x', Steps ctx x x' ∧ execItems ctx (switchItems t) x = .ok x' ∧
      x'.rip = addrAt ctx es[i].toNat ∧ x'.reg .rax = addrAt ctx es[i].toNat ∧
      x'.reg .rcx = addrAt ctx t.toNat ∧ x'.mem = x.mem ∧ x'.xmm = x.xmm ∧
      ∀ r : Reg, r.idx ≠ Reg.rax.idx → r.idx ≠ Reg.rcx.idx → x'.reg r = x.reg r := by
  obtain ⟨x', he, hrest⟩ := exec_switch ht hi hrax htb heb
  refine ⟨x', ?_, he, hrest⟩
  have hrun : FetchRun ctx (InCode ctx (switchItems t) pos)
      [.leaTable t, .loadTableEntry, .addRaxRcx] x := by
    refine fetchRun_of_forall (fun j hj => ?_) x
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
    rcases hj with rfl | rfl | rfl
    · exact leaTable_straight ctx t
    · exact loadTableEntry_straight ctx
    · exact addRaxRcx_straight ctx
  have hcan : Canon (switchItems t) pos := by
    have c : ∀ (i : Item) (p : Nat), i.wf (BitVec.ofNat 32 p) = true →
        (∀ b e, i ≠ .tableEntry b e) → i.Canonical p := fun _ _ hw ht => ⟨ht, .inl hw⟩
    refine ⟨c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, c _ _ rfl ?_, trivial⟩ <;>
      intro _ _ h <;> cases h
  exact steps_of_run_last (items := [.leaTable t, .loadTableEntry, .addRaxRcx]) (j := .jmpRax)
    hcan hc hrip (fun _ h => h) hrun he

end Ryo.Proofs.Switch
