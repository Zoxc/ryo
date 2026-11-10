/-
Ryo.Check.Lower.Fn — a whole function's lowering (aot.md §C1, M5a): `LowersFn Γ d` collects what
the function simulation (`Ryo/Proofs/Lower/FnSim.lean`) needs of the decoded code `d` against
the MIR body and the certificate in `Γ`, and `checkFn` decides it (`checkFn_sound`).

M5a's restrictions: no scopes anywhere in the function (so no escaped locals: every local is
private), not PE, every block L0 can reach (`Reach.lean`'s `computeReach`, checked by
`reachOk`) not dead, every statement and terminator lowered by a rule of
`StmtExt.lean`/`TermExt.lean`, or a fused block's last statement and terminator together by
`Fused.lean`'s (M5b); blocks L0 cannot reach need no check;
every instruction a plain view (`PlainView`), and at each storage statement of a local no other
local that may be storage-live there with an overlapping slot (`share`: `Live.lean`'s `ShareOk`,
the backend's sharing condition; L0 allocates each local at its slot and live allocations don't
overlap). Liveness: `computeLive` with its post-fixpoint
check, a `StorageDead`'d local dead right after, and a `StorageLive`'d local storage-dead before
it (`computeStorage` over-approximates storage), its slot the size of its type.

The prologue (`Prolog.lean`) is not part of this: the simulation starts at block 0's first
statement, from a state the prologue's simulation (`SimProlog.lean`) relates.
-/
import Ryo.Check.Lower.TermExt
import Ryo.Check.Lower.StmtExt
import Ryo.Check.Lower.Live
import Ryo.Check.Lower.Fused
import Ryo.Check.Lower.Reach
import Ryo.Proofs.Lower.FnRel

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R
open Ryo.Proofs.Lower (PlainView IntsSized SlotsApart)

/-- A function's rule context: no `Escape` scope (M5a), so nothing is escaped. -/
def fnCtx (body : Body) (fc : FuncCert) (mode : Ryo.Obj.Mode) (ρ : Addrs) : TermCtx :=
  { body := body, slots := fc.locals, mode := mode, ρ := ρ, escaped := fun _ => false,
    blocks := fc.blocks, retKind := fc.retKind, sret := fc.sret }

/-- The instructions of a certificate range. -/
def rangeInsns (d : Decoded) (r : Range) : List Insn := (d.insns.extract r.1 r.2).toList

/-- Where the code after statement `i` of a block starts: statement `i + 1`'s range, or the
terminator's. -/
def nextStart (blk : BlockCert) (i : Nat) : Nat :=
  ((blk.stmts[i + 1]?).map (·.1)).getD blk.term.1

/-- One block's lowering: a fused block's last statement has no range of its own, it is lowered
with the terminator (`FusedBlock`). -/
structure BlockOk (Γ : TermCtx) (d : Decoded) (bd : BlockData) (blk : BlockCert) : Prop where
  dead : blk.dead = false
  len : blk.stmts.size + (if blk.fused then 1 else 0) = bd.stmts.length
  stmt : ∀ (i : Nat) st r, bd.stmts[i]? = some st → blk.stmts[i]? = some r →
    r.1 ≤ r.2 ∧ r.2 ≤ d.insns.size ∧ r.2 = nextStart blk i ∧
      LowerStmtX Γ.toStmtCtx st (rangeInsns d r)
  termLe : blk.term.1 ≤ blk.term.2
  termIn : blk.term.2 ≤ d.insns.size
  term : blk.fused = false → LowerTermX Γ blk.term.2 bd.term (rangeInsns d blk.term)
  fusedOk : blk.fused = true →
    FusedBlock Γ blk.term.2 blk.stmts.size bd.stmts bd.term (rangeInsns d blk.term)

/-- The function's lowering (see the module comment). -/
structure LowersFn (Γ : TermCtx) (d : Decoded) : Prop where
  noScopes : d.scopes.size = 0
  notPe : Γ.mode.pe = false
  noEsc : ∀ o, Γ.escaped o = false
  /-- No pool placements: the pool-constant rules (`PoolConst.lean`) are for `LowersFnX`, whose
  simulation carries the pool invariant. -/
  noPool : Γ.pool = []
  /-- No function symbol slots: the fn pointer rule (`FnPtrCast.lean`) is for `LowersFnX`, whose
  simulation carries the function invariant. -/
  noFnSym : Γ.fnSym = []
  blocksSize : Γ.blocks.size = Γ.body.blocks.size
  reach : ReachSound Γ.body (reachGet (computeReach Γ.body))
  block : ∀ (b : Nat) bd blk, reachGet (computeReach Γ.body) b = true →
    Γ.body.blocks[b]? = some bd → Γ.blocks[b]? = some blk → BlockOk Γ d bd blk
  plain : ∀ (k : Nat) i, d.insns[k]? = some i → PlainView Γ.mode Γ.ρ i
  ints : IntsSized Γ.body
  live : LiveSound Γ.body (computeLive Γ.body).get
  storage : StorageSound Γ.body (computeStorage Γ.body).get
  share : Γ.slots.size ≤ Γ.body.locals.size ∧ ShareOk Γ.body Γ.slots (computeStorage Γ.body).get
  deadAfter : ∀ (b : Nat) bd (i : Nat) (l : Local), Γ.body.blocks[b]? = some bd → bd.stmts[i]? = some (.storageDead l) →
    (computeLive Γ.body).get b (i + 1) l = false
  fresh : ∀ (b : Nat) bd (i : Nat) (l : Local), Γ.body.blocks[b]? = some bd → bd.stmts[i]? = some (.storageLive l) →
    (computeStorage Γ.body).get b i l = false ∧ ∃ sd, Γ.slots[l]? = some sd ∧
      ∀ ty, Γ.body.locals[l]? = some ty → ty.size? = some sd.size
  /-- Every `resume`'s cleanup entry continues unwinding (`TermMore.lean`'s `resumesCheck`). -/
  resumes : ∀ (k : Nat) i, d.insns[k]? = some i → isResume Γ.mode Γ.ρ i = true →
    contAt d k = true
  /-- The sret slot is never overwritten (`RetSret.lean`'s `pinCheck`). -/
  pin : ∀ so, Γ.sret = some so → pinCheck Γ.mode Γ.ρ so d = true

/-! ### The checker -/

/-- `LowersFn.pin`'s check. -/
def sretPinCheck (Γ : TermCtx) (d : Decoded) : Bool :=
  match Γ.sret with
  | some so => pinCheck Γ.mode Γ.ρ so d
  | none => true

theorem sretPinCheck_sound {Γ : TermCtx} {d : Decoded} (h : sretPinCheck Γ d = true) :
    ∀ so, Γ.sret = some so → pinCheck Γ.mode Γ.ρ so d = true := by
  intro so hso
  unfold sretPinCheck at h
  rw [hso] at h
  exact h

def plainOk (mode : Ryo.Obj.Mode) (ρ : Addrs) (i : Insn) : Bool :=
  match view mode ρ i with
  | some v =>
    (v.ctl == some .trap || (v.op != Full.Opcode.resume && v.op != Full.Opcode.unreachable)) &&
      (v.op.info.operands.zip v.ops).all (fun p => p.2.fits p.1.kind)
  | none => true

theorem plainOk_spec {mode : Ryo.Obj.Mode} {ρ : Addrs} {i : Insn} (h : plainOk mode ρ i = true) :
    PlainView mode ρ i := by
  unfold plainOk at h
  refine ⟨?_, ?_, ?_⟩ <;> intro v hv <;> rw [hv] at h <;>
    simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq, bne_iff_ne, ne_eq] at h
  · intro hc
    rcases h.1 with h1 | h1
    · exact absurd h1 hc
    · exact h1.1
  · intro hc
    rcases h.1 with h1 | h1
    · exact absurd h1 hc
    · exact h1.2
  · exact h.2

/-- The terminator's check: with the fused statement for a fused block. -/
def blockTermCheck (Γ : TermCtx) (d : Decoded) (bd : BlockData) (blk : BlockCert) : Bool :=
  if blk.fused then
    checkFusedBlock Γ blk.term.2 blk.stmts.size bd.stmts bd.term (rangeInsns d blk.term) == .ok
  else checkTermX Γ blk.term.2 bd.term (rangeInsns d blk.term) == .ok

theorem blockTermCheck_sound {Γ : TermCtx} {d : Decoded} {bd : BlockData} {blk : BlockCert}
    (h : blockTermCheck Γ d bd blk = true) :
    (blk.fused = false → LowerTermX Γ blk.term.2 bd.term (rangeInsns d blk.term)) ∧
    (blk.fused = true →
      FusedBlock Γ blk.term.2 blk.stmts.size bd.stmts bd.term (rangeInsns d blk.term)) := by
  unfold blockTermCheck at h
  cases hf : blk.fused
  · rw [hf] at h
    simp only [Bool.false_eq_true, eq_self_iff_true, if_true, if_false, ↓reduceIte,
      beq_iff_eq] at h
    exact ⟨fun _ => checkTermX_sound h, fun e => by cases e⟩
  · rw [hf] at h
    simp only [Bool.false_eq_true, eq_self_iff_true, if_true, if_false, ↓reduceIte,
      beq_iff_eq] at h
    exact ⟨fun e => (by cases e), fun _ => checkFusedBlock_sound h⟩

def blockCheck (Γ : TermCtx) (d : Decoded) (bd : BlockData) (blk : BlockCert) : Bool :=
  !blk.dead && blk.stmts.size + (if blk.fused then 1 else 0) == bd.stmts.length &&
    (List.range blk.stmts.size).all (fun i => match bd.stmts[i]?, blk.stmts[i]? with
      | some st, some r => decide (r.1 ≤ r.2) && decide (r.2 ≤ d.insns.size) &&
          r.2 == nextStart blk i && checkStmtX Γ.toStmtCtx st (rangeInsns d r) == .ok
      | _, _ => false) &&
    decide (blk.term.1 ≤ blk.term.2) && decide (blk.term.2 ≤ d.insns.size) &&
    blockTermCheck Γ d bd blk

theorem blockCheck_sound {Γ : TermCtx} {d : Decoded} {bd : BlockData} {blk : BlockCert}
    (h : blockCheck Γ d bd blk = true) : BlockOk Γ d bd blk := by
  unfold blockCheck at h
  simp only [Bool.and_eq_true, Bool.not_eq_true', beq_iff_eq, decide_eq_true_eq,
    List.all_eq_true, List.mem_range] at h
  obtain ⟨⟨⟨⟨⟨hd, hl⟩, hs⟩, h1⟩, h2⟩, ht⟩ := h
  refine ⟨hd, hl, ?_, h1, h2, (blockTermCheck_sound ht).1, (blockTermCheck_sound ht).2⟩
  intro i st r hst hr
  have hi : i < blk.stmts.size := (Array.getElem?_eq_some_iff.mp hr).1
  have := hs i hi
  rw [hst, hr] at this
  simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at this
  obtain ⟨⟨⟨a, b⟩, c⟩, e⟩ := this
  exact ⟨a, b, c, checkStmtX_sound e⟩

/-- Every block L0 can reach (`computeReach`) checks. -/
def blocksCheck (Γ : TermCtx) (d : Decoded) : Bool :=
  (List.range Γ.body.blocks.size).all fun b =>
    !reachGet (computeReach Γ.body) b || match Γ.body.blocks[b]?, Γ.blocks[b]? with
      | some bd, some blk => blockCheck Γ d bd blk
      | _, _ => false

theorem blocksCheck_sound {Γ : TermCtx} {d : Decoded} (h : blocksCheck Γ d = true) :
    ∀ (b : Nat) bd blk, reachGet (computeReach Γ.body) b = true →
      Γ.body.blocks[b]? = some bd → Γ.blocks[b]? = some blk → BlockOk Γ d bd blk := by
  intro b bd blk hr hb hk
  unfold blocksCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have := h b (Array.getElem?_eq_some_iff.mp hb).1
  rw [hb, hk, hr] at this
  simp only [Bool.not_true, Bool.false_or] at this
  exact blockCheck_sound this

def plainsCheck (Γ : TermCtx) (d : Decoded) : Bool :=
  (List.range d.insns.size).all fun k => match d.insns[k]? with
    | some i => plainOk Γ.mode Γ.ρ i
    | none => true

theorem plainsCheck_sound {Γ : TermCtx} {d : Decoded} (h : plainsCheck Γ d = true) :
    ∀ (k : Nat) i, d.insns[k]? = some i → PlainView Γ.mode Γ.ρ i := by
  intro k i hk
  unfold plainsCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have := h k (Array.getElem?_eq_some_iff.mp hk).1
  rw [hk] at this
  exact plainOk_spec this

def intsCheck (body : Body) : Bool :=
  (List.range body.locals.size).all fun l => match body.locals[l]? with
    | some (Spec.Ty.int t _) => decide (0 < t.size)
    | _ => true

theorem intsCheck_sound {body : Body} (h : intsCheck body = true) : IntsSized body := by
  intro l t valid hl
  unfold intsCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have := h l (Array.getElem?_eq_some_iff.mp hl).1
  rw [hl] at this
  simpa using this

/-- The storage statements' checks (`LowersFn.deadAfter`, `fresh`). -/
def storageStmtsCheck (body : Body) (slots : Array LocalSlot) (lv sl : PointTable) : Bool :=
  (List.range body.blocks.size).all fun b => match body.blocks[b]? with
    | some bd => (List.range bd.stmts.length).all fun i => match bd.stmts[i]? with
      | some (.storageDead l) => !(lv.get b (i + 1) l)
      | some (.storageLive l) => !(sl.get b i l) && (match slots[l]?, body.locals[l]? with
          | some sd, some ty => ty.size? == some sd.size
          | some _, none => true
          | none, _ => false)
      | _ => true
    | none => true

theorem storageStmtsCheck_dead {body : Body} {slots : Array LocalSlot} {lv sl : PointTable}
    (h : storageStmtsCheck body slots lv sl = true) :
    ∀ (b : Nat) bd (i : Nat) (l : Local), body.blocks[b]? = some bd → bd.stmts[i]? = some (.storageDead l) →
      lv.get b (i + 1) l = false := by
  intro b bd i l hb hi
  unfold storageStmtsCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have h1 := h b (Array.getElem?_eq_some_iff.mp hb).1
  rw [hb] at h1
  simp only [List.all_eq_true, List.mem_range] at h1
  have h2 := h1 i (List.getElem?_eq_some_iff.mp hi).1
  rw [hi] at h2
  simpa using h2

theorem storageStmtsCheck_live {body : Body} {slots : Array LocalSlot} {lv sl : PointTable}
    (h : storageStmtsCheck body slots lv sl = true) :
    ∀ (b : Nat) bd (i : Nat) (l : Local), body.blocks[b]? = some bd → bd.stmts[i]? = some (.storageLive l) →
      sl.get b i l = false ∧ ∃ sd, slots[l]? = some sd ∧
        ∀ ty, body.locals[l]? = some ty → ty.size? = some sd.size := by
  intro b bd i l hb hi
  unfold storageStmtsCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have h1 := h b (Array.getElem?_eq_some_iff.mp hb).1
  rw [hb] at h1
  simp only [List.all_eq_true, List.mem_range] at h1
  have h2 := h1 i (List.getElem?_eq_some_iff.mp hi).1
  rw [hi] at h2
  simp only [Bool.and_eq_true, Bool.not_eq_true'] at h2
  obtain ⟨hs, hm⟩ := h2
  refine ⟨hs, ?_⟩
  revert hm
  cases hsl : slots[l]? with
  | none => intro hm; cases hm
  | some sd =>
    cases hty : body.locals[l]? with
    | none => intro _; exact ⟨sd, rfl, fun ty e => by cases e⟩
    | some ty =>
      intro hm
      simp only [beq_iff_eq] at hm
      exact ⟨sd, rfl, fun ty' e => by cases e; exact hm⟩

/-- The function's checker. -/
def checkFn (Γ : TermCtx) (d : Decoded) : Bool :=
  d.scopes.size == 0 && !Γ.mode.pe &&
    Γ.blocks.size == Γ.body.blocks.size && blocksCheck Γ d && plainsCheck Γ d &&
    intsCheck Γ.body && liveCheck Γ.body (computeLive Γ.body) &&
    storageCheck Γ.body (computeStorage Γ.body) &&
    shareCheck Γ.body Γ.slots (computeStorage Γ.body) &&
    storageStmtsCheck Γ.body Γ.slots (computeLive Γ.body) (computeStorage Γ.body) &&
    reachOk Γ.body && resumesCheck Γ d && sretPinCheck Γ d

/-- `checkFn` at `fnCtx` (whose `escaped` is constantly false). -/
theorem checkFn_sound {body : Body} {fc : FuncCert} {mode : Ryo.Obj.Mode} {ρ : Addrs}
    {d : Decoded} (h : checkFn (fnCtx body fc mode ρ) d = true) :
    LowersFn (fnCtx body fc mode ρ) d := by
  unfold checkFn at h
  simp only [Bool.and_eq_true, beq_iff_eq, Bool.not_eq_true'] at h
  obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨hsc, hpe⟩, hbs⟩, hb⟩, hp⟩, hi⟩, hl⟩, hs⟩, ha⟩, hst⟩, hre⟩, hrs⟩, hpin⟩ :=
    h
  exact { noScopes := hsc, notPe := hpe, noEsc := fun _ => rfl, noPool := rfl, noFnSym := rfl, blocksSize := hbs,
          reach := reachOk_sound hre, block := blocksCheck_sound hb, plain := plainsCheck_sound hp,
          ints := intsCheck_sound hi, live := liveCheck_sound hl,
          storage := storageCheck_sound hs, share := shareCheck_sound ha,
          deadAfter := storageStmtsCheck_dead hst, fresh := storageStmtsCheck_live hst,
          resumes := resumesCheck_sound hrs, pin := sretPinCheck_sound hpin }

/-- The coverage verdict of a whole function (`CertCheck`'s `functions` count). -/
def fnVerdict (body : Body) (fc : FuncCert) (d : Decoded) (mode : Ryo.Obj.Mode) (ρ : Addrs) :
    Verdict :=
  if checkFn (fnCtx body fc mode ρ) d then .ok else .unsupported "function"

end Ryo.Check.Lower
