/-
Ryo.Proofs.CacheStep — one R step of an inline instruction against its sequence as the register
cache emits it (aot.md §C2 "Register cache", "Inline steps"; milestone M3 `decode_sound`):
`inline_stepC` (`Ryo/Proofs/Step.lean`, the sequence on `rax`) composed with `emit_sound`
(`Ryo/Proofs/Cache.lean`, the renamed sequence against `emit`'s output).

- `sequence_ok`/`sequence_cacheSafe`: every item of `sequence cls ops` is `cacheSafe` and names
  no register but `rax`, `rcx` and `rbp` (`onlyARB`), given that `cls` isn't a sign extension
  from 64 bits (whose `movsx` at 64 bits `update` doesn't track; no inline opcode is one,
  `inlineOps_ext`).
- `exec_swap`/`execItems_swap`: renaming is a register swap. With `rax` and `xr` swapped in the
  state (`swapS`) and the items (`swapR`), a `cacheSafe` sequence without `mulQ` (whose `rax`
  and `rdx` are fixed) runs as before, but for `rip` (a renamed item may be longer). On the
  sequences' registers `emit`'s renaming `ren xr` is that swap (`ren_eq_swap`, as `xr` is a pool
  register, neither `rcx` nor `rbp`); with a `mulQ`, `emit` keeps `rax` (`emitHead_mulQ`) and
  the renaming is the identity (`ren_rax`).
- `emit_safe`, `execItems_rip`: what `emit` outputs is `cacheSafe`, so it ends `rip` past itself
  (which `emit_sound`, "but for `rip`", doesn't say).
- `inline_step_cached`: from `CacheInv cache x` and `RRel s x`, for the R instruction
  `.native op ops` at `s.pc` (`op.full = some f`) of a `SoundC` class `cls` with
  `sequence cls ops = some (cand, br)`, a step to `s'` is matched by running
  `(cache.emit cand).1` from `x` to an `x'` with `RRel s' x'`, `CacheInv (cache.emit cand).2 x'`,
  `rip` past the emitted items, and `inline_stepC`'s fall-through/branch conclusion on `x'`'s
  flags. The proof runs `inline_stepC` on `swapS xr x` (`RRel` sees only memory and `rbp`), and
  swaps back.
- Opcode tables: `kindOk`, `inlineOk_of`, `not_ext64` reduce `InlineOk` and the extension fact to
  `Full.all.all kindOk = true` and `shapeOk`; `RyoProofs/InlineOk.lean` proves the former
  (`all_kindOk`, a slow `decide`), giving `inlineOps_ok`, `inlineOps_ext` and
  `inline_step_cached_ops` (the step for `(f, cls) ∈ inlineOps`). `soundC_of`: the `SoundC`
  classes are those of `inline_soundC` (all but `load`, `store` and the rip-relative addresses,
  which have only `Sound` with `Private`/`SoundG` with `Globals`).

Left as hypotheses: `SoundC cls` (so `load`, `store`, `addrConst`, `addrSym`, `addrSymInd` are
not covered); the link from the decoder's candidate to R's operands: `inlineInsn` accepts `cand`
when `decodeInline cand branch = some (f, ops₀)` (so `decodeInline_spec` gives `cls` with
`(f, cls) ∈ inlineOps` and `sequence cls ops₀ = some (cand, branch.map (·.1))`), but R's `ops`
are `ops₀` with targets mapped to instruction indices (`reducedOf`), and that `sequence` ignores
targets is not proved here, nor that `Reduced.Opcode.ofFull f = some op` gives
`op.full = some f`; the dropped-store case (the machine code is `out` without a dropped store,
`inlineInsn`'s `eraseIdx`) is not covered.
-/
import Ryo.Proofs.Cache
import Ryo.Proofs.Step

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.CacheStep

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache

/-- The registers the inline sequences name. -/
def okReg (r : Reg) : Bool := r == .rax || r == .rcx || r == .rbp
def okRm : Rm → Bool
  | .reg r => okReg r
  | .mem m => okReg m.base

def onlyARB : Item → Bool
  | .ld _ _ d m | .st _ d m | .leaM d m => okReg d && okReg m.base
  | .stImm _ m _ | .setcc _ m | .testM8 m => okReg m.base
  | .alu _ _ r rm | .imul _ r rm | .imulImm _ r rm _ => okReg r && okRm rm
  | .aluImm _ _ rm _ | .mulQ rm => okRm rm
  | .shift _ _ r _ | .setReg r _ | .lea r _ | .loadRip r _ => okReg r
  | .setccCl _ => true
  | _ => false

/-- The items of the inline sequences: tracked by `update`, on `rax`, `rcx` and `rbp` only. -/
def seqItemOk (it : Item) : Bool := cacheSafe it && onlyARB it

set_option maxHeartbeats 1000000 in
/-- The items of an inline sequence are `cacheSafe` and name only `rax`, `rcx` and `rbp`. -/
theorem sequence_ok {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hext : ∀ b, cls ≠ .ext .q b true) (h : sequence cls ops = some (items, br)) :
    ∀ it ∈ items, seqItemOk it = true := by
  intro it hit
  cases cls <;> simp only [sequence, bind, Option.bind_eq_some_iff, pure] at h
  all_goals (repeat' (first
    | (obtain ⟨_, hs, h⟩ := h
       split at hs <;> (try simp only [Option.some.injEq, reduceCtorEq] at hs) <;> (try subst hs))
    | split at h)) <;>
    (try simp only [Option.some.injEq, Prod.mk.injEq] at h) <;>
    (try obtain ⟨rfl, _⟩ := h) <;>
    (repeat' (first
      | (obtain rfl | hit := hit)
      | subst hit
      | split at hit
      | (simp only [List.mem_cons, List.mem_append, List.not_mem_nil,
          or_false, or_assoc, ld, st, R, C, M.frame, Mrax, flagSeq, cmpImmSeq] at hit))) <;>
    simp [seqItemOk, cacheSafe, onlyARB, okReg, okRm] <;>
    (try (cases ‹W› <;> simp_all))
  all_goals exact Classical.or_iff_not_imp_right.2 fun h => hext (Classical.not_not.1 h)

/-- Every item of an inline sequence is one `update` tracks. -/
theorem sequence_cacheSafe {T : Type} {cls : Class} {ops : List (R.Opnd T)} {items : List Item}
    {br : Option Cond} (hext : ∀ b, cls ≠ .ext .q b true) (h : sequence cls ops = some (items, br)) :
    ∀ it ∈ items, cacheSafe it = true := fun it hit => by
  have := sequence_ok hext h it hit
  simp only [seqItemOk, Bool.and_eq_true] at this
  exact this.1

/-! ### Renaming `rax` -/

/-- `rax` and `xr` swapped. -/
def swapR (xr : Reg) (r : Reg) : Reg := if r = .rax then xr else if r = xr then .rax else r

def swapI (xr : Reg) (i : Fin 16) : Fin 16 :=
  if i = Reg.rax.idx then xr.idx else if i = xr.idx then Reg.rax.idx else i

/-- The state with `rax` and `xr` swapped. -/
def swapS (xr : Reg) (x : X86.State) : X86.State := { x with regs := fun i => x.regs (swapI xr i) }

theorem swapI_swapI (xr : Reg) (i : Fin 16) : swapI xr (swapI xr i) = i := by
  unfold swapI
  generalize Reg.rax.idx = a
  generalize xr.idx = b
  by_cases h1 : i = a <;> by_cases h2 : i = b <;> by_cases h3 : b = a <;> simp_all

theorem swapI_idx (xr r : Reg) : swapI xr r.idx = (swapR xr r).idx := by
  unfold swapI swapR
  by_cases h1 : r = .rax
  · subst h1; simp
  · have h1' : r.idx ≠ Reg.rax.idx := fun e => h1 (idx_inj e)
    by_cases h2 : r = xr
    · subst h2; simp [h1]
    · have h2' : r.idx ≠ xr.idx := fun e => h2 (idx_inj e)
      simp only [h1, h1', h2, h2', ↓reduceIte]

theorem swapR_swapR (xr r : Reg) : swapR xr (swapR xr r) = r := by
  apply idx_inj; rw [← swapI_idx, ← swapI_idx, swapI_swapI]

@[simp] theorem swapS_swapS (xr : Reg) (x : X86.State) : swapS xr (swapS xr x) = x := by
  simp only [swapS, swapI_swapI]

@[simp] theorem reg_swapS (xr r : Reg) (x : X86.State) : (swapS xr x).reg (swapR xr r) = x.reg r := by
  simp only [swapS, X86.State.reg, swapI_idx, swapR_swapR]

@[simp] theorem rip_swapS (xr : Reg) (x : X86.State) : (swapS xr x).rip = x.rip := rfl
@[simp] theorem flags_swapS (xr : Reg) (x : X86.State) : (swapS xr x).flags = x.flags := rfl
@[simp] theorem mem_swapS (xr : Reg) (x : X86.State) : (swapS xr x).mem = x.mem := rfl
@[simp] theorem swapS_jump (xr : Reg) (x : X86.State) (a : BitVec 64) :
    swapS xr (x.jump a) = (swapS xr x).jump a := rfl
@[simp] theorem swapS_setFlags (xr : Reg) (x : X86.State) (f : Flags) :
    swapS xr (x.setFlags f) = (swapS xr x).setFlags f := rfl
@[simp] theorem swapS_setMem (xr : Reg) (x : X86.State) (a : BitVec 64) (n v : Nat) :
    swapS xr (x.setMem a n v) = (swapS xr x).setMem a n v := rfl
@[simp] theorem swapS_setMemW (xr : Reg) (x : X86.State) (w : W) (a : BitVec 64) (v : BitVec w.bits) :
    swapS xr (x.setMemW w a v) = (swapS xr x).setMemW w a v := rfl

@[simp] theorem swapS_setReg (xr r : Reg) (x : X86.State) (v : BitVec 64) :
    swapS xr (x.setReg r v) = (swapS xr x).setReg (swapR xr r) v := by
  simp only [swapS, X86.State.setReg, ← swapI_idx, X86.State.mk.injEq, and_true]
  funext i
  have : (swapI xr i = r.idx) ↔ (i = swapI xr r.idx) :=
    ⟨fun h => by rw [← h, swapI_swapI], fun h => by rw [h, swapI_swapI]⟩
  by_cases h : i = swapI xr r.idx
  · simp only [show (swapI xr i = r.idx) = True from eq_true (this.2 h),
      show (i = swapI xr r.idx) = True from eq_true h, ↓reduceIte]
  · simp only [show (swapI xr i = r.idx) = False from eq_false (mt this.1 h),
      show (i = swapI xr r.idx) = False from eq_false h, ↓reduceIte]

@[simp] theorem regW_swapS (xr r : Reg) (x : X86.State) (w : W) :
    (swapS xr x).regW w (swapR xr r) = x.regW w r := by simp [X86.State.regW]

@[simp] theorem swapS_setRegW (xr r : Reg) (x : X86.State) (w : W) (v : BitVec w.bits) :
    swapS xr (x.setRegW w r v) = (swapS xr x).setRegW w (swapR xr r) v := by
  cases w <;> simp [X86.State.setRegW]

theorem ea_swapS (xr : Reg) (x : X86.State) (m : M) :
    (swapS xr x).ea ⟨swapR xr m.base, m.disp⟩ = x.ea m := by simp [X86.State.ea]

@[simp] theorem ea_swapS' (xr b : Reg) (d : BitVec 32) (x : X86.State) :
    (swapS xr x).ea ⟨swapR xr b, d⟩ = x.ea ⟨b, d⟩ := ea_swapS xr x ⟨b, d⟩

@[simp] theorem memW_swapS (xr : Reg) (x : X86.State) (w : W) (a : BitVec 64) :
    (swapS xr x).memW w a = x.memW w a := rfl

@[simp] theorem rmW_swapS (xr : Reg) (x : X86.State) (w : W) (rm : Rm) :
    (swapS xr x).rmW w (mapRegs.mapRm (swapR xr) rm) = x.rmW w rm := by
  cases rm <;> simp [X86.State.rmW, mapRegs.mapRm]

@[simp] theorem swapS_setRmW (xr : Reg) (x : X86.State) (w : W) (rm : Rm) (v : BitVec w.bits) :
    swapS xr (x.setRmW w rm v) = (swapS xr x).setRmW w (mapRegs.mapRm (swapR xr) rm) v := by
  cases rm <;> simp [X86.State.setRmW, mapRegs.mapRm]

@[simp] theorem jump_setReg (x : X86.State) (a : BitVec 64) (r : Reg) (v : BitVec 64) :
    (x.jump a).setReg r v = (x.setReg r v).jump a := rfl
@[simp] theorem jump_setFlags (x : X86.State) (a : BitVec 64) (f : Flags) :
    (x.jump a).setFlags f = (x.setFlags f).jump a := rfl
@[simp] theorem jump_setMem (x : X86.State) (a b : BitVec 64) (n v : Nat) :
    (x.jump a).setMem b n v = (x.setMem b n v).jump a := rfl
@[simp] theorem jump_setMemW (x : X86.State) (a b : BitVec 64) (w : W) (v : BitVec w.bits) :
    (x.jump a).setMemW w b v = (x.setMemW w b v).jump a := rfl
@[simp] theorem jump_setRegW (x : X86.State) (a : BitVec 64) (w : W) (r : Reg) (v : BitVec w.bits) :
    (x.jump a).setRegW w r v = (x.setRegW w r v).jump a := by cases w <;> rfl
@[simp] theorem jump_setRmW (x : X86.State) (a : BitVec 64) (w : W) (rm : Rm) (v : BitVec w.bits) :
    (x.jump a).setRmW w rm v = (x.setRmW w rm v).jump a := by
  cases rm <;> simp [X86.State.setRmW] <;> rfl
@[simp] theorem reg_jump (x : X86.State) (a : BitVec 64) (r : Reg) : (x.jump a).reg r = x.reg r := rfl
@[simp] theorem mem_jump (x : X86.State) (a : BitVec 64) : (x.jump a).mem = x.mem := rfl

def isMulQ : Item → Bool
  | .mulQ _ => true
  | _ => false

/-- A tracked item other than `mulQ` (whose `rax` and `rdx` are fixed) runs on the swapped
state as it does on the state, but for `rip` (the renamed item may have another length). -/
theorem exec_swap (ctx : Ctx) {xr : Reg} (hc : xr ≠ .rcx) {it : Item} (hs : cacheSafe it = true)
    (hm : isMulQ it = false) {y z : X86.State} (h : it.exec ctx y = .ok z) :
    (mapRegs (swapR xr) it).exec ctx (swapS xr y) =
      .ok ((swapS xr z).jump (y.rip + BitVec.ofNat 64 (mapRegs (swapR xr) it).size)) := by
  have hrcx : swapR xr .rcx = .rcx := by simp [swapR, Ne.symm hc]
  cases it <;> simp only [cacheSafe, isMulQ, reduceCtorEq] at hs hm <;>
    simp only [Item.exec, mapRegs, bind, Except.bind, pure, Except.pure, jump_setReg, jump_setFlags,
      jump_setMem, jump_setMemW, jump_setRegW, jump_setRmW, mem_jump, regW_jump, ea_jump,
      rmW_jump, memW_jump, flags_jump, rip_swapS] at h ⊢
  all_goals (repeat' split at h)
  all_goals (first | (simp only [reduceCtorEq] at h; done) | (simp only [Except.ok.injEq] at h; subst h))
  all_goals simp only [swapS_jump, swapS_setReg, swapS_setFlags, swapS_setMemW, swapS_setMem,
    swapS_setRegW, swapS_setRmW, jump_jump, regW_swapS, ea_swapS', rmW_swapS, memW_swapS,
    flags_swapS, mem_swapS, hrcx]
  all_goals (try simp_all)

/-! ### The opcode tables -/

/-- The handler kinds of the inline classes (`classHandler`). -/
def inlineKind : Handlers.HandlerKind → Bool
  | .mov | .imm | .addr | .addr_const | .addr_sym | .ptr_add | .ptr_index | .load | .store
  | .bin | .binop | .bin_imm | .binop_imm | .shift_imm | .cmp | .cmp_imm | .br | .br_cmp
  | .br_cmp_imm | .ovf | .cvt => true
  | _ => false

/-- The parameters of a `cvt` handler from `i64` to a signed integer. -/
def sext64 (ps : List String) : Bool :=
  ps == ["i64", "i8"] || ps == ["i64", "i16"] || ps == ["i64", "i32"] || ps == ["i64", "i64"]

/-- What every opcode with a handler of an inline kind satisfies (`all_kindOk`, in
`RyoProofs/InlineOk.lean`). -/
def kindOk (f : Full.Opcode) : Bool :=
  match f.handler? with
  | some h => !inlineKind h.kind ||
      (R.opShape f && f != .resume && f != .unreachable && !(h.kind == .cvt && sext64 h.params))
  | none => true

theorem mem_all {f : Full.Opcode} {cls : Class} (h : (f, cls) ∈ inlineOps) : f ∈ Full.all := by
  simp only [inlineOps, List.mem_filterMap, Option.map_eq_some_iff, Prod.mk.injEq] at h
  obtain ⟨a, ha, _, _, rfl, _⟩ := h
  exact ha

theorem inlineKind_class (cls : Class) : inlineKind (classHandler cls).1 = true := by
  cases cls <;> simp only [classHandler] <;> first | rfl | (rename_i op _; cases op <;> rfl)

theorem kindOk_shape {f : Full.Opcode} {cls : Class} (hk : kindOk f = true)
    (hs : shapeOk f cls = true) :
    R.opShape f = true ∧ f ≠ .resume ∧ f ≠ .unreachable ∧
      ¬((classHandler cls).1 = .cvt ∧ sext64 (classHandler cls).2 = true) := by
  obtain ⟨⟨r, hh⟩, _⟩ := shapeOk_spec hs
  unfold kindOk at hk
  rw [hh] at hk
  simp only [inlineKind_class, Bool.not_true, Bool.false_or, Bool.and_eq_true, bne_iff_ne, ne_eq,
    Bool.not_eq_true', Bool.and_eq_false_iff] at hk
  refine ⟨hk.1.1.1, hk.1.1.2, hk.1.2, ?_⟩
  rintro ⟨h1, h2⟩
  rcases hk.2 with h | h
  · simp [h1] at h
  · simp [h] at h2

/-- What `inline_step` needs of an inline opcode, given `shapeOk` (`inlineOps_shape`) and
`all_kindOk`. -/
theorem inlineOk_of {f : Full.Opcode} {cls : Class} (hall : Full.all.all kindOk = true)
    (h : (f, cls) ∈ inlineOps) (hs : shapeOk f cls = true) : InlineOk f cls := by
  have hk : kindOk f = true := List.all_eq_true.1 hall f (mem_all h)
  obtain ⟨h1, h2, h3, _⟩ := kindOk_shape hk hs
  exact ⟨hs, h1, h2, h3⟩

/-- No inline opcode sign-extends from 64 bits. -/
theorem not_ext64 {f : Full.Opcode} {cls : Class} (hall : Full.all.all kindOk = true)
    (h : (f, cls) ∈ inlineOps) (hs : shapeOk f cls = true) : ∀ b, cls ≠ .ext .q b true := by
  have hk : kindOk f = true := List.all_eq_true.1 hall f (mem_all h)
  obtain ⟨_, _, _, h4⟩ := kindOk_shape hk hs
  rintro b rfl
  exact h4 ⟨rfl, by cases b <;> decide⟩

/-- The classes with `SoundC` (all but `load`, `store` and the rip-relative addresses, which
have `SoundG`). -/
theorem soundC_of (cls : Class) (h : frameOnly cls = true ∨ ovfClass cls = true) : SoundC cls :=
  inline_soundC cls h

theorem cacheSafe_mapRegs {g : Reg → Reg} (hg : ∀ r : Reg, r ≠ .rbp → g r ≠ .rbp) {it : Item}
    (hs : cacheSafe it = true) : cacheSafe (mapRegs g it) = true := by
  cases it <;> simp only [cacheSafe, bne_iff_ne, ne_eq, Bool.and_eq_true] at hs <;>
    simp only [mapRegs, cacheSafe, bne_iff_ne, ne_eq, Bool.and_eq_true] <;>
    first
    | trivial
    | exact hg _ hs
    | exact ⟨hg _ hs.1, hs.2⟩
    | (rename_i rm _; cases rm <;> simp only [mapRegs.mapRm, bne_iff_ne, ne_eq] at hs ⊢ <;>
        first | exact hg _ hs | exact hs)

theorem swapR_ne_rbp {xr : Reg} (hb : xr ≠ .rbp) (r : Reg) (hr : r ≠ .rbp) : swapR xr r ≠ .rbp := by
  unfold swapR; split
  · exact hb
  · split
    · decide
    · exact hr

/-- The sequence's items, renamed, run from the swapped state (moved to any `rip`) to the
swapped final state, but for `rip`. -/
theorem execItems_swap (ctx : Ctx) {xr : Reg} (hc : xr ≠ .rcx) (hb : xr ≠ .rbp) :
    ∀ (items : List Item) (y z : X86.State) (a : BitVec 64),
      (∀ it ∈ items, cacheSafe it = true ∧ isMulQ it = false) → execItems ctx items y = .ok z →
      ∃ z', execItems ctx (items.map (mapRegs (swapR xr))) ((swapS xr y).jump a) = .ok z' ∧
        z' = (swapS xr z).jump z'.rip
  | [], y, z, a, _, h => by
    simp only [execItems_nil', Except.ok.injEq] at h
    subst h
    exact ⟨_, rfl, rfl⟩
  | it :: rest, y, z, a, hs, h => by
    rw [execItems_cons'] at h
    cases hy : it.exec ctx y with
    | error e => rw [hy] at h; exact nomatch h
    | ok y1 =>
      rw [hy] at h
      have h1 := hs it (by simp)
      have hsafe := cacheSafe_mapRegs (swapR_ne_rbp hb) h1.1
      have hx := exec_swap ctx hc h1.1 h1.2 hy
      obtain ⟨z', hz', he⟩ := execItems_swap ctx hc hb rest y1 z
        (a + BitVec.ofNat 64 (mapRegs (swapR xr) it).size) (fun i hi => hs i (by simp [hi])) h
      refine ⟨z', ?_, he⟩
      rw [List.map_cons, execItems_cons', exec_jump hsafe, hx]
      exact hz'

theorem mapRegs_congr {f g : Reg → Reg} (hfg : ∀ r, okReg r = true → f r = g r) {it : Item}
    (h : onlyARB it = true) : mapRegs f it = mapRegs g it := by
  have hm : ∀ rm : Rm, okRm rm = true → mapRegs.mapRm f rm = mapRegs.mapRm g rm := by
    intro rm hrm; cases rm <;> simp only [okRm] at hrm <;> simp [mapRegs.mapRm, hfg _ hrm]
  cases it <;> simp only [onlyARB, Bool.and_eq_true] at h <;> simp only [mapRegs] <;>
    first
    | rfl
    | simp [hfg _ h]
    | simp [hfg _ h.1, hfg _ h.2]
    | simp [hm _ h]
    | simp [hfg _ h.1, hm _ h.2]

/-- On the sequences' registers (`rax`, `rcx`, `rbp`), `emit`'s renaming is the swap. -/
theorem ren_eq_swap {xr : Reg} (hc : xr ≠ .rcx) (hb : xr ≠ .rbp) {it : Item}
    (h : onlyARB it = true) : ren xr it = mapRegs (swapR xr) it := by
  apply mapRegs_congr _ h
  intro r hr
  cases r <;> simp only [okReg] at hr <;> first | (exact absurd hr (by decide)) | skip
  all_goals simp [R, swapR, Ne.symm hc, Ne.symm hb]

theorem mapRegs_id (it : Item) : mapRegs id it = it := by
  cases it <;> first | rfl | (cases ‹Rm› <;> rfl)

theorem ren_rax (it : Item) : ren .rax it = it := by
  have : (fun r => if (r == R) = true then Reg.rax else r) = id := by
    funext r; by_cases h : r = .rax <;> simp [h, R]
  simp only [ren, this, mapRegs_id]

theorem pool_ne_rcx (i : Nat) : pool[i]! ≠ .rcx := by
  by_cases hi : i < 8
  · intro e
    have : ∀ j < 8, pool[j]! ≠ .rcx := by decide
    exact this i hi e
  · rw [getElem!_neg pool i (by simp [pool]; omega)]; decide

/-- With a `mul` (`rdx:rax`) the sequence stays on `rax`. -/
theorem emitHead_mulQ (c : Cache) (items : List Item) (h : ∃ it ∈ items, isMulQ it = true) :
    (emitHead c items).1 = 0 := by
  obtain ⟨it, hit, hq⟩ := h
  unfold emitHead
  dsimp only
  split <;> split
  all_goals first
    | rfl
    | (rename_i hn; exfalso; apply hn
       exact List.any_eq_true.2 ⟨it, hit, by cases it <;> simp_all [isMulQ]⟩)

/-- Items that don't read `rip` end `rip` past themselves. -/
theorem execItems_rip (ctx : Ctx) : ∀ (items : List Item) (x y : X86.State),
    (∀ it ∈ items, cacheSafe it = true) → execItems ctx items x = .ok y →
      y.rip = x.rip + BitVec.ofNat 64 (items.map Item.size).sum
  | [], x, y, _, h => by
    simp only [execItems_nil', Except.ok.injEq] at h
    subst h; simp
  | it :: rest, x, y, hs, h => by
    rw [execItems_cons'] at h
    cases hy : it.exec ctx x with
    | error e => rw [hy] at h; exact nomatch h
    | ok x1 =>
      rw [hy] at h
      have hj := exec_jump (ctx := ctx) (hs it (by simp)) x x.rip
      rw [jump_rip, hy] at hj
      have h1 : x1.rip = x.rip + BitVec.ofNat 64 it.size := by
        simp only [Except.map, Except.ok.injEq] at hj
        rw [hj]; rfl
      rw [execItems_rip ctx rest x1 y (fun i hi => hs i (by simp [hi])) h, h1]
      simp only [List.map_cons, List.sum_cons, BitVec.ofNat_add, BitVec.add_assoc]

theorem foldl_safe (xr : Reg) (hb : xr ≠ .rbp) : ∀ (rest : List Item) (st : Cache × Array Item),
    (∀ e ∈ st.2.toList, cacheSafe e = true) → (∀ it ∈ rest, cacheSafe it = true) →
      ∀ e ∈ (rest.foldl (emitStep xr) st).2.toList, cacheSafe e = true
  | [], st, h, _ => h
  | it :: rest, st, h, hs => by
    obtain ⟨e, c', heq, hcase⟩ := emitStep_cases xr st it
    have hsafe := cacheSafe_ren hb (hs it (by simp))
    have he : cacheSafe e = true := by
      rcases hcase with ⟨rfl, _⟩ | ⟨m, w, i, _, _, rfl, _⟩
      · exact hsafe
      · exact cacheSafe_withRm hsafe i
    simp only [List.foldl_cons, heq]
    refine foldl_safe xr hb rest _ ?_ (fun i hi => hs i (by simp [hi]))
    intro e' he'
    simp only [Array.toList_push, List.mem_append, List.mem_singleton] at he'
    rcases he' with he' | rfl
    · exact h e' he'
    · exact he

/-- What `emit` emits doesn't read `rip`. -/
theorem emit_safe {c : Cache} {items : List Item} (hsz : c.regs.size = 8)
    (hs : ∀ it ∈ items, cacheSafe it = true) : ∀ e ∈ (c.emit items).1, cacheSafe e = true := by
  rw [emit_eq]
  dsimp only
  apply foldl_safe _ (pool_ne_rbp' _) _ _ (by simp)
  rcases emitHead_cases { c with tick := c.tick + 1 } items hsz with h | ⟨w, m, tl, rfl, h, _⟩
  · rw [h]; exact hs
  · rw [h]; exact fun i hi => hs i (by simp [hi])

theorem rrel_congr {s : R.RState} {x y : X86.State} (hr : RRel s x) (hb : y.reg .rbp = x.reg .rbp)
    (hm : y.mem = x.mem) : RRel s y :=
  ⟨rel_congr hr.rel hb hm, by rw [hb]; exact hr.rbp, hr.wf⟩

/-! ### The cached step -/

/-- One R step of an inline instruction against its sequence as the register cache emits it
(see the module comment). -/
theorem inline_step_cached (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {cls : Class} {cand : List Item} {br : Option Cond} {cache : Cache} (hsound : SoundC cls)
    (hinv : CacheInv cache x) (hr : RRel s x) (hi : c.d.insns[s.pc]? = some (.native op ops))
    (hf : op.full = some f) (hok : InlineOk f cls) (hext : ∀ b, cls ≠ .ext .q b true)
    (hseq : sequence cls ops = some (cand, br)) (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧
      CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      match br with
      | none => s'.pc = s.pc + 1
      | some cond => ∃ neg t b, R.nativeCtl f ops = some (.branch neg t) ∧
          cond.eval x'.flags = .ok b ∧ s'.pc = if b then t else s.pc + 1 := by
  have hok' := sequence_ok hext hseq
  have hsafe : ∀ it ∈ cand, cacheSafe it = true := fun it hit => by
    have := hok' it hit; simp only [seqItemOk, Bool.and_eq_true] at this; exact this.1
  -- The register `emit` puts the sequence in.
  generalize hxr : pool[(emitHead { cache with tick := cache.tick + 1 } cand).1]! = xr
  have hb : xr ≠ .rbp := hxr ▸ pool_ne_rbp' _
  have hc : xr ≠ .rcx := hxr ▸ pool_ne_rcx _
  -- The sequence on the state with `rax` and `xr` swapped, and the renamed one on `x`.
  have hr0 : RRel s (swapS xr x) := rrel_congr hr (by
    have := reg_swapS xr .rbp x
    rwa [show swapR xr .rbp = .rbp by simp [swapR, Ne.symm hb]] at this) rfl
  obtain ⟨x1, hx1, hr1, hrip1, _, hbr⟩ :=
    inline_stepC ctx hsound hr0 hi hf hok hseq h
  have hren : ∃ z, execItems ctx (cand.map (ren xr)) x = .ok z ∧
      z.reg .rbp = x1.reg .rbp ∧ z.mem = x1.mem ∧ z.flags = x1.flags := by
    by_cases hq : ∃ it ∈ cand, isMulQ it = true
    · -- A `mul`: `xr` is `rax`, the swap and the renaming do nothing.
      have hx : xr = .rax := by rw [← hxr, emitHead_mulQ _ _ hq]; rfl
      subst hx
      have hs0 : swapS .rax x = x := by
        cases x; simp only [swapS, X86.State.mk.injEq, and_true]
        funext i; simp only [swapI]; split <;> simp_all
      rw [hs0] at hx1
      refine ⟨x1, ?_, rfl, rfl, rfl⟩
      rw [List.map_congr_left (fun it _ => ren_rax it), List.map_id']
      exact hx1
    · have hm : ∀ it ∈ cand, cacheSafe it = true ∧ isMulQ it = false := fun it hit =>
        ⟨hsafe it hit, by cases e : isMulQ it; rfl; exact absurd ⟨it, hit, e⟩ hq⟩
      obtain ⟨z, hz, hze⟩ := execItems_swap ctx hc hb cand (swapS xr x) x1 x.rip hm hx1
      rw [swapS_swapS, jump_rip] at hz
      refine ⟨z, ?_, ?_, ?_, ?_⟩
      · rw [List.map_congr_left (fun it hit => ren_eq_swap hc hb (by
          have := hok' it hit; simp only [seqItemOk, Bool.and_eq_true] at this; exact this.2))]
        exact hz
      · rw [hze]
        show (swapS xr x1).reg .rbp = _
        have := reg_swapS xr .rbp x1
        rwa [show swapR xr .rbp = .rbp by simp [swapR, Ne.symm hb]] at this
      · rw [hze]; rfl
      · rw [hze]; rfl
  obtain ⟨z, hz, hzb, hzm, hzf⟩ := hren
  obtain ⟨y, hy, hyz, hcy⟩ := emit_sound hinv hsafe (hxr ▸ hz)
  have hyb : y.reg .rbp = x1.reg .rbp := by rw [hyz]; exact hzb
  have hym : y.mem = x1.mem := by rw [hyz]; exact hzm
  have hyf : y.flags = x1.flags := by rw [hyz]; exact hzf
  refine ⟨y, hy, rrel_congr hr1 hyb hym, hcy,
    execItems_rip ctx _ x y (emit_safe hinv.1 hsafe) hy, ?_⟩
  cases br with
  | none => exact hbr
  | some cond =>
    obtain ⟨neg, t, b, h1, h2, h3⟩ := hbr
    exact ⟨neg, t, b, h1, hyf ▸ h2, h3⟩

end Ryo.Proofs.CacheStep
