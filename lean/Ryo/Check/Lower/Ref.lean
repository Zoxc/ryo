/-
Ryo.Check.Lower.Ref — the lowering rule for taking a local's address (aot.md §C1, M5b), and the
checker for where a function's scopes sit (`ScopesOk`), the facts the simulation of functions
with escaped locals needs (`Ryo/Proofs/Lower/FnRelEsc.lean`).

Rule (`LowerRef`):
- `ref`: `_d = &_a.f₁.….fₖ` or `_d = &raw const|mut _a.f₁.….fₖ` (`refPlace?`; `k ≥ 0`, the
  projections all `.field`, as `Field.lean`'s `fieldPath`, so the place is `_a`'s pointer
  offset by `off`, L0's offsets), `_d` a thin pointer local (`metaKind = .none`, 8 bytes; its
  slot may be escaped: the simulation writes it through `FnRel.write_dst`), `_d ≠ _a`, the
  offset inside `_a`'s non-empty slot or at its end (`off ≤ sa.size`; at the end, `addrOf` takes
  its at-end case, which gives `_a`'s object only when no escaped object starts there: `hend`,
  no `Escape` of the function covers that offset), lowered to one `addr` handler
  instruction (`addrInsnOk`) from slot offset `sa.off + off` to `_d`'s slot. Every offset of
  `_a`'s slot is covered by some `Escape` of the function (`hesc`): the backend
  (`place.rs` `addr_into`, `frame.rs` `escape`) escapes `_a`'s whole slot before the `addr`;
  that this `Escape` is exactly the scope before the instruction is `ScopesOk`'s
  (`ownSpec`), not the rule's.

Scope placement (`ScopesOk`, decided by `scopesCheck`). The backend places a scope "before the
next instruction": a `StorageDead` (no instruction) puts its `End` (kept by `Asm::finish` only
when it overlaps some `Escape`) before the next statement's or the terminator's first
instruction, and an `addr` puts the `Escape` of its object right before itself. So at the start
`k` of a non-empty range, the scopes are, in order, the `End`s of the instruction-less
statements before it whose range also starts at `k` (`pendSpecs`: a `StorageDead _l` whose slot
some `Escape` covers, `endSpec`), then the statement's own (`ownSpec`: a `ref` statement's
`Escape` of its referent's whole slot, alignment at most the referent type's; the same for a
read `_d = copy _a.pre[_l].post` of a local through an index, `useSpec`; none for any other
statement or terminator). `ScopesOk` requires exactly that (`specsOk`, ignoring `codeOffset`), no
scope inside a range after its first index, no pending `End` at a block's end whose terminator
has no instruction (its scopes would sit in another block), and every `StorageDead _l` with an
`End` at a point where `_l` may be storage-live (`computeStorage`), so that (by `ShareOk`) no
other local sharing `_l`'s slot is storage-live there and the `End` frees only `_l`'s object.
Nothing here relies on `CertCheck`'s escape coverage: the simulation shows `addr` defined from
these facts.
-/
import Ryo.Check.Lower.Field
import Ryo.Check.Lower.Term
import Ryo.Check.Lower.Live
import Ryo.Check.Lower.Enum

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

/-! ### The rule -/

/-- The place `&p` / `&raw p` takes the address of. -/
def refPlace? : Rvalue → Option MPlace
  | .ref _ p | .rawPtr _ p => some p
  | _ => none

/-- An instruction whose view is an `addr` handler from slot `s` to slot `d`, falling
through. -/
def addrInsnOk (Γ : StmtCtx) (i : Insn) (d s : Int) : Bool :=
  match view Γ.mode Γ.ρ i with
  | some v =>
    match v.op.handler? with
    | some ⟨kd, _, _⟩ =>
      kd == .addr && v.op.info.operands == [⟨"d", .slot⟩, ⟨"s", .slot⟩] &&
        v.ops == [.slot d, .slot s] && v.ctl == some .next
    | none => false
  | none => false

theorem addrInsnOk_spec {Γ : StmtCtx} {i : Insn} {d s : Int} (h : addrInsnOk Γ i d s = true) :
    ∃ v ps r, view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.addr, ps, r⟩ ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩] ∧
      v.ops = [.slot d, .slot s] ∧ v.ctl = some .next := by
  unfold addrInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd ps r hh =>
      simp only [Bool.and_eq_true, beq_iff_eq] at h
      obtain ⟨⟨⟨hkd, ho⟩, hops⟩, hctl⟩ := h
      subst hkd
      exact ⟨v, ps, r, hv, hh, ho, hops, hctl⟩
    · cases h
  · cases h

/-- Whether every offset of the `n` bytes at `o` is covered by some `Escape`. -/
def escAll (Γ : StmtCtx) (o : Int) (n : Nat) : Bool :=
  (List.range n).all fun k => Γ.escaped (o + k)

theorem escAll_spec {Γ : StmtCtx} {o : Int} {n : Nat} (h : escAll Γ o n = true) :
    ∀ k < n, Γ.escaped (o + k) = true := by
  unfold escAll at h
  intro k hk
  exact List.all_eq_true.mp h k (List.mem_range.mpr hk)

inductive LowerRef (Γ : StmtCtx) : Statement → List Insn → Prop where
  | ref {d a : Local} {rv : Rvalue} {projs : List ProjElem} {ta ty : Ty} {off : Nat}
      {pt : PtrType} {valid : ValidRange} {sd sa : LocalSlot} {i : Insn}
      (hrv : refPlace? rv = some ⟨a, projs⟩) (hne : ¬ d = a)
      (hta : Γ.body.locals[a]? = some ta) (hpath : fieldPath ta projs = some (off, ty))
      (htd : Γ.body.locals[d]? = some (.ptr pt valid)) (hk : pt.metaKind = .none)
      (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
      (hsize : sd.size = 8 ∧ off ≤ sa.size ∧ 0 < sa.size)
      (hend : off = sa.size → Γ.escaped (sa.off + sa.size) = false)
      (hoff : offOk sd.off ∧ offOk sa.off ∧ offOk (sa.off + off))
      (hesc : ∀ k < sa.size, Γ.escaped (sa.off + k) = true)
      (hi : addrInsnOk Γ i sd.off (sa.off + off) = true) :
      LowerRef Γ (.assign ⟨d, []⟩ rv) [i]

/-- `ref`'s checker for `_d = &_a.projs` / `&raw _a.projs`. -/
def checkRefPlace (Γ : StmtCtx) (d a : Local) (projs : List ProjElem) (is : List Insn) :
    Verdict :=
  if d = a then .rejected "ref: destination is the referent"
  else match Γ.body.locals[a]? with
  | none => .rejected "ref: no source local"
  | some ta =>
    match fieldPath ta projs with
    | none => .unsupported ("ref " ++ projWhy projs)
    | some (off, _) =>
      match Γ.body.locals[d]? with
      | some (.ptr pt _) =>
        if pt.metaKind = .none then
          match Γ.slots[d]?, Γ.slots[a]?, is with
          | some sd, some sa, [i] =>
            if !(sd.size == 8 && (decide (off ≤ sa.size) && decide (0 < sa.size))) then
              .unsupported "ref: slot sizes or a zero-sized referent"
            else if !(offOk sd.off && (offOk sa.off && offOk (sa.off + off))) then
              .rejected "ref: offsets"
            else if !(off != sa.size || !Γ.escaped (sa.off + sa.size)) then
              .unsupported "ref: end of the referent, escaped bytes after it"
            else if !escAll Γ sa.off sa.size then .rejected "ref: referent never escaped"
            else if addrInsnOk Γ i sd.off (sa.off + off) then .ok
            else .unsupported "ref: instruction form"
          | _, _, _ => .unsupported "ref: slots or instruction count"
        else .unsupported "ref: wide pointer"
      | some _ => .unsupported "ref: destination not a pointer"
      | none => .rejected "ref: no destination local"

/-- The family's checker: `none` unless `st` is `_d = &p` or `_d = &raw p`. -/
def checkRef (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match st with
  | .assign ⟨d, []⟩ rv =>
    match refPlace? rv with
    | some p => some (checkRefPlace Γ d p.base p.proj is)
    | none => none
  | _ => none

theorem checkRefPlace_sound {Γ : StmtCtx} {d a : Local} {rv : Rvalue} {projs : List ProjElem}
    {is : List Insn} (hrv : refPlace? rv = some ⟨a, projs⟩)
    (h : checkRefPlace Γ d a projs is = .ok) : LowerRef Γ (.assign ⟨d, []⟩ rv) is := by
  unfold checkRefPlace at h
  split at h
  · cases h
  next hne =>
    split at h
    · cases h
    next ta hta =>
      split at h
      · cases h
      next off ty hpath =>
        split at h
        next pt valid htd =>
          split at h
          next hk =>
            split at h
            next sd sa i hsd hsa =>
              split at h
              · cases h
              next hsz =>
                split at h
                · cases h
                next hoff =>
                  split at h
                  · cases h
                  next hend =>
                    split at h
                    · cases h
                    next hesc =>
                      split at h
                      next hi =>
                        have hsz' : sd.size = 8 ∧ off ≤ sa.size ∧ ¬sa.size = 0 := by
                          simpa using hsz
                        exact .ref hrv hne hta hpath htd hk hsd hsa
                          ⟨hsz'.1, hsz'.2.1, Nat.pos_of_ne_zero hsz'.2.2⟩
                          (fun he => by subst he; simpa using hend)
                          (by simpa using hoff) (escAll_spec (by simpa using hesc)) hi
                      · cases h
            · cases h
          · cases h
        · cases h
        · cases h

theorem checkRef_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkRef Γ st is = some .ok) : LowerRef Γ st is := by
  unfold checkRef at h
  split at h
  next d rv =>
    split at h
    next p hp =>
      exact checkRefPlace_sound (a := p.base) (projs := p.proj) hp (Option.some.inj h)
    · cases h
  · cases h

/-! ### Scope placement -/

/-- The scopes before instruction `k` of `d` (`Code.scopesAt` on the decoded code). -/
def scopesAtD (d : Decoded) (k : Nat) : List Scope :=
  (d.scopes.toList.filter (·.1 == k)).map (·.2)

/-- The frame offsets some `Escape` of `d` covers (the function context's `escaped`; as
`CertCheck.lowerCoverage` computes it). -/
def scopeEscaped (d : Decoded) : Int → Bool := fun o =>
  d.scopes.toList.any fun p => match p.2.kind with
    | .escape _ => decide (p.2.frameOffset.toInt ≤ o ∧ o < p.2.frameOffset.toInt + p.2.size)
    | _ => false

/-- An expected scope: an `End` of `[off, off + size)`, or an `Escape` of it whose alignment
is at most `2 ^ maxExp`. -/
inductive ScopeSpec where
  | endS (off : Int) (size : Nat)
  | escS (off : Int) (size : Nat) (maxExp : Nat)
deriving DecidableEq, Repr, Inhabited

def ScopeSpec.ok : ScopeSpec → Scope → Bool
  | .endS o n, sc => sc.kind == .end && sc.frameOffset.toInt == o && sc.size == n
  | .escS o n e, sc =>
    (match sc.kind with
     | .escape al => decide ((Ryo.Spec.Align.ofBytes al).exp ≤ e)
     | _ => false) && sc.frameOffset.toInt == o && sc.size == n

/-- The scopes `scs` are the expected ones, in order. -/
def specsOk : List ScopeSpec → List Scope → Bool
  | [], [] => true
  | p :: ps, sc :: scs => p.ok sc && specsOk ps scs
  | _, _ => false

/-- Where statement `i`'s range starts (the terminator's past the last statement); `pcAt` in
the proofs. -/
def startAt (blk : BlockCert) (i : Nat) : Nat := ((blk.stmts[i]?).map (·.1)).getD blk.term.1

/-- The `End` an instruction-less statement leaves for the next instruction: `StorageDead _l`
of a slot some `Escape` covers (`Asm::finish` drops the others). -/
def endSpec (Γ : StmtCtx) : Statement → List ScopeSpec
  | .storageDead l =>
    match Γ.slots[l]? with
    | some sl => if privOk Γ sl.off sl.size then [] else [.endS sl.off sl.size]
    | none => []
  | _ => []

/-- Projections `pre ++ .index l :: post`, `pre` and `post` fields: the split. -/
@[simp] def idxSplit : List ProjElem → Option (List ProjElem × Local × List ProjElem)
  | [] => none
  | .index l :: post => if post.all isFieldProj then some ([], l, post) else none
  | .field f t :: ps => (idxSplit ps).map fun (pre, l, post) => (.field f t :: pre, l, post)
  | _ :: _ => none
where
  /-- A field projection. -/
  isFieldProj : ProjElem → Bool
    | .field .. => true
    | _ => false

/-- The `Escape` before a read of `_a.pre[_l].post` (`idxSplit`): the backend takes the element's
address from `_a`'s slot (`addr`, then `ptr.index`), escaping `_a`'s whole non-empty slot first
(`frame.rs` `escape`, `Asm::escape` skips empty ones). The `fieldPath`/`downcastPath` conditions
are implied by `idxSplit` (both fail on an index); they let `simp_all` see the spec empty from
a family's path hypothesis. -/
@[simp] def idxPlaceSpec (Γ : StmtCtx) (p : MPlace) : List ScopeSpec :=
  match Γ.body.locals[p.base]? with
  | some ta =>
    if (idxSplit p.proj).isSome && (fieldPath ta p.proj).isNone &&
        (downcastPath ta p.proj).isNone then
      match Γ.slots[p.base]? with
      | some sa => if 0 < sa.size then [.escS sa.off sa.size ta.align.exp] else []
      | none => []
    else []
  | none => []

/-- The own scopes of `_d = use o`: `idxPlaceSpec` of a non-local place operand. -/
@[simp] def useSpec (Γ : StmtCtx) (o : Operand) : List ScopeSpec :=
  if o.local?.isSome then []
  else match operandPlace? o with
    | some p => idxPlaceSpec Γ p
    | none => []

/-- No index projection in `o`'s place: no own scope. -/
theorem useSpec_of_noIdx {Γ : StmtCtx} {o : Operand}
    (h : ∀ p, operandPlace? o = some p → idxSplit p.proj = none) : useSpec Γ o = [] := by
  unfold useSpec
  split
  · rfl
  · split
    next p hp =>
      unfold idxPlaceSpec
      split
      · simp [h p hp]
      · rfl
    · rfl

/-- An `Agg.lean` field operand (a whole local or a constant) has no own scope. -/
theorem useSpec_aggField {Γ : StmtCtx} {sd : LocalSlot} {op : Operand} {off : Nat} {t : Ty}
    {src : AggSrc} (h : AggField Γ sd op off t src) : useSpec Γ op = [] := by
  apply useSpec_of_noIdx
  intro p hp
  cases h with
  | slot ha =>
    cases op with
    | copy q =>
      obtain ⟨a, ps⟩ := q
      cases ps with
      | nil => simp [operandPlace?] at hp; subst hp; rfl
      | cons x xs => simp [Operand.local?] at ha
    | move q =>
      obtain ⟨a, ps⟩ := q
      cases ps with
      | nil => simp [operandPlace?] at hp; subst hp; rfl
      | cons x xs => simp [Operand.local?] at ha
    | const c ty => simp [operandPlace?] at hp
    | runtimeChecks k b => simp [operandPlace?] at hp
  | imm => simp [operandPlace?] at hp
  | zst _ _ _ hop =>
    cases op with
    | copy q =>
      obtain ⟨a, ps⟩ := q
      cases ps with
      | nil => simp [operandPlace?] at hp; subst hp; rfl
      | cons x xs => simp [zstOperand] at hop
    | move q =>
      obtain ⟨a, ps⟩ := q
      cases ps with
      | nil => simp [operandPlace?] at hp; subst hp; rfl
      | cons x xs => simp [zstOperand] at hop
    | const c ty => simp [operandPlace?] at hp
    | runtimeChecks k b => simp [operandPlace?] at hp

/-- A statement's own scopes, before its first instruction: a `ref`'s `Escape` of its
referent's whole slot, and a read through an index of a local's (`useSpec`). -/
def ownSpec (Γ : StmtCtx) : Statement → List ScopeSpec
  | .assign ⟨_, []⟩ rv =>
    match refPlace? rv with
    | some p =>
      match Γ.slots[p.base]?, Γ.body.locals[p.base]? with
      | some sa, some ta =>
        if (fieldPath ta p.proj).isSome then [.escS sa.off sa.size ta.align.exp] else []
      | _, _ => []
    | none =>
      match rv with
      | .use o => useSpec Γ o
      | _ => []
  | _ => []

/-- The `End`s pending at statement `i` (or the terminator, `i = bd.stmts.length`): those of
the statements before it in the block whose range starts where `i`'s does (all empty). -/
def pendSpecs (Γ : StmtCtx) (bd : BlockData) (blk : BlockCert) (i : Nat) : List ScopeSpec :=
  (List.range i).flatMap fun j =>
    if startAt blk j = startAt blk i then
      match bd.stmts[j]? with
      | some st => endSpec Γ st
      | none => []
    else []

/-- One block's scope placement (see the module comment). -/
structure BlockScopesOk (Γ : TermCtx) (d : Decoded) (b : Nat) (bd : BlockData)
    (blk : BlockCert) : Prop where
  stmt : ∀ (i : Nat) st r, bd.stmts[i]? = some st → blk.stmts[i]? = some r → r.1 < r.2 →
    specsOk (pendSpecs Γ.toStmtCtx bd blk i ++ ownSpec Γ.toStmtCtx st) (scopesAtD d r.1) = true
  stmtInner : ∀ (i : Nat) r, blk.stmts[i]? = some r → ∀ j, r.1 < j → j < r.2 →
    scopesAtD d j = []
  term : blk.term.1 < blk.term.2 →
    specsOk (pendSpecs Γ.toStmtCtx bd blk bd.stmts.length) (scopesAtD d blk.term.1) = true
  termEmpty : blk.term.2 ≤ blk.term.1 → pendSpecs Γ.toStmtCtx bd blk bd.stmts.length = []
  termInner : ∀ j, blk.term.1 < j → j < blk.term.2 → scopesAtD d j = []
  endLive : ∀ (i : Nat) l sl, bd.stmts[i]? = some (.storageDead l) → Γ.slots[l]? = some sl →
    privOk Γ.toStmtCtx sl.off sl.size = false → (computeStorage Γ.body).get b i l = true

/-- The function's scope placement. -/
def ScopesOk (Γ : TermCtx) (d : Decoded) : Prop :=
  ∀ (b : Nat) bd blk, Γ.body.blocks[b]? = some bd → Γ.blocks[b]? = some blk →
    BlockScopesOk Γ d b bd blk

/-! ### The checker -/

/-- No scope inside range `r` after its first index. -/
def innerOk (d : Decoded) (r : Range) : Bool :=
  (List.range (r.2 - r.1 - 1)).all fun j => decide (scopesAtD d (r.1 + 1 + j) = [])

theorem innerOk_spec {d : Decoded} {r : Range} (h : innerOk d r = true) :
    ∀ j, r.1 < j → j < r.2 → scopesAtD d j = [] := by
  intro j h1 h2
  unfold innerOk at h
  have hj : decide (scopesAtD d (r.1 + 1 + (j - r.1 - 1)) = []) = true :=
    List.all_eq_true.mp h (j - r.1 - 1) (List.mem_range.mpr (by omega))
  have e : r.1 + 1 + (j - r.1 - 1) = j := by omega
  rw [e] at hj
  simpa using hj

def blockScopesCheck (Γ : TermCtx) (d : Decoded) (b : Nat) (bd : BlockData) (blk : BlockCert) :
    Bool :=
  (List.range blk.stmts.size).all (fun i => match blk.stmts[i]? with
    | some r =>
      (decide (r.2 ≤ r.1) || (match bd.stmts[i]? with
        | some st =>
          specsOk (pendSpecs Γ.toStmtCtx bd blk i ++ ownSpec Γ.toStmtCtx st) (scopesAtD d r.1)
        | none => false)) && innerOk d r
    | none => true) &&
  (decide (blk.term.2 ≤ blk.term.1) ||
    specsOk (pendSpecs Γ.toStmtCtx bd blk bd.stmts.length) (scopesAtD d blk.term.1)) &&
  (decide (blk.term.1 < blk.term.2) ||
    decide (pendSpecs Γ.toStmtCtx bd blk bd.stmts.length = [])) &&
  innerOk d blk.term &&
  (List.range bd.stmts.length).all (fun i => match bd.stmts[i]? with
    | some (.storageDead l) =>
      match Γ.slots[l]? with
      | some sl => privOk Γ.toStmtCtx sl.off sl.size || (computeStorage Γ.body).get b i l
      | none => true
    | _ => true)

theorem blockScopesCheck_sound {Γ : TermCtx} {d : Decoded} {b : Nat} {bd : BlockData}
    {blk : BlockCert} (h : blockScopesCheck Γ d b bd blk = true) :
    BlockScopesOk Γ d b bd blk := by
  unfold blockScopesCheck at h
  simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range] at h
  obtain ⟨⟨⟨⟨hs, ht⟩, hte⟩, hti⟩, hsd⟩ := h
  refine ⟨?_, ?_, ?_, ?_, innerOk_spec hti, ?_⟩
  · intro i st r hst hr hlt
    have hi : i < blk.stmts.size := (Array.getElem?_eq_some_iff.mp hr).1
    have hc := hs i hi
    rw [hr, hst] at hc
    simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq] at hc
    rcases hc.1 with h1 | h1
    · omega
    · exact h1
  · intro i r hr j h1 h2
    have hi : i < blk.stmts.size := (Array.getElem?_eq_some_iff.mp hr).1
    have hc := hs i hi
    rw [hr] at hc
    simp only [Bool.and_eq_true] at hc
    exact innerOk_spec hc.2 j h1 h2
  · intro hlt
    simp only [Bool.or_eq_true, decide_eq_true_eq] at ht
    rcases ht with h1 | h1
    · omega
    · exact h1
  · intro hle
    simp only [Bool.or_eq_true, decide_eq_true_eq] at hte
    rcases hte with h1 | h1
    · omega
    · exact h1
  · intro i l sl hst hsl hpv
    have hi : i < bd.stmts.length := (List.getElem?_eq_some_iff.mp hst).1
    have hc := hsd i hi
    rw [hst] at hc
    simpa [hsl, hpv] using hc

def scopesCheck (Γ : TermCtx) (d : Decoded) : Bool :=
  (List.range Γ.body.blocks.size).all fun b => match Γ.body.blocks[b]?, Γ.blocks[b]? with
    | some bd, some blk => blockScopesCheck Γ d b bd blk
    | _, _ => false

theorem scopesCheck_sound {Γ : TermCtx} {d : Decoded} (h : scopesCheck Γ d = true) :
    ScopesOk Γ d := by
  intro b bd blk hb hk
  unfold scopesCheck at h
  simp only [List.all_eq_true, List.mem_range] at h
  have hc := h b (Array.getElem?_eq_some_iff.mp hb).1
  rw [hb, hk] at hc
  exact blockScopesCheck_sound hc

end Ryo.Check.Lower
