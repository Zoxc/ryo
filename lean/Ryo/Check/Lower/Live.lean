/-
Ryo.Check.Lower.Live — semantic liveness, storage liveness and the slot-layout check of the
lowering's frame map (aot.md §C1 "Locals", M5a).

- **Semantic liveness** (`computeLive`): a backward dataflow over the MIR body, per block and
  statement index (point `i` is before statement `i`, point `len` before the terminator). A
  local is live if it may be read later before a whole-local assignment (or a storage
  statement) kills it. Locals whose address may be taken or that are used other than as a whole
  (`bodyEsc`: places with projections, `&`/`&raw`/reborrows, call and drop operands) are live at
  every point.
- **Storage liveness** (`computeStorage`): a forward may-be-live dataflow: `StorageLive` gens,
  `StorageDead` kills; at entry the return place, the arguments and every local without storage
  statements are live (`initStorage`).
- **Layout** (`layoutCheck`): two distinct locals whose certificate slots overlap are never both
  semantically and storage-live at one point.

Nothing about the fixpoint computation is proved: `liveCheck`/`storageCheck` check that the
result is a post-fixpoint, and `liveCheck_sound`/`storageCheck_sound`/`layoutCheck_sound` turn
the checks into the facts the simulation uses (`LiveSound`, `StorageSound`, `LayoutOk`).
-/
import Ryo.Check.Lower.Stmt

namespace Ryo.Check.Lower

open Ryo.Spec

/-! ### Uses -/

/-- The locals a place mentions: its base and its `index` locals. -/
def placeLocals (p : MPlace) : List Local :=
  p.base :: p.proj.filterMap fun | .index l => some l | _ => none

def operandLocals : Operand → List Local
  | .copy p | .move p => placeLocals p
  | _ => []

def rvalueLocals : Rvalue → List Local
  | .use o | .«repeat» o _ | .cast _ o _ | .unaryOp _ o | .wrapUnsafeBinder o _ => operandLocals o
  | .ref _ p | .rawPtr _ p | .discriminant p | .copyForDeref p | .reborrow _ _ p => placeLocals p
  | .threadLocalRef _ => []
  | .binaryOp _ a b => operandLocals a ++ operandLocals b
  | .aggregate _ ops => ops.flatMap operandLocals

/-- A place used other than as a whole local: all its locals. -/
def placeEsc (p : MPlace) : List Local :=
  if p.proj.isEmpty then [] else placeLocals p

def operandEsc : Operand → List Local
  | .copy p | .move p => placeEsc p
  | _ => []

def rvalueEsc : Rvalue → List Local
  | .use o | .«repeat» o _ | .cast _ o _ | .unaryOp _ o | .wrapUnsafeBinder o _ => operandEsc o
  | .ref _ p | .rawPtr _ p | .reborrow _ _ p => placeLocals p
  | .discriminant p | .copyForDeref p => placeEsc p
  | .threadLocalRef _ => []
  | .binaryOp _ a b => operandEsc a ++ operandEsc b
  | .aggregate _ ops => ops.flatMap operandEsc

def stmtEsc : Statement → List Local
  | .assign p rv => placeEsc p ++ rvalueEsc rv
  | .setDiscriminant p _ => placeLocals p
  | .assume o => operandEsc o
  | .copyNonOverlapping a b c => operandLocals a ++ operandLocals b ++ operandLocals c
  | .placeMention p => placeEsc p
  | _ => []

def calleeLocals : Callee → List Local
  | .fnPtr o => operandLocals o
  | _ => []

/-- The locals a terminator reads. -/
def termReads : Terminator → List Local
  | .switchInt d _ _ => operandLocals d
  | .«return» => [0]
  | .drop p _ _ _ => placeLocals p
  | .call f args dest _ _ _ _ => calleeLocals f ++ args.flatMap operandLocals ++ placeLocals dest
  | .tailCall f args _ _ => calleeLocals f ++ args.flatMap operandLocals
  | .assert c _ msg _ _ => operandLocals c ++ msg.args.flatMap operandLocals
  | _ => []

def termEsc : Terminator → List Local
  | .switchInt d _ _ => operandEsc d
  | .drop p _ _ _ => placeLocals p
  | .call f args dest _ _ _ _ => calleeLocals f ++ args.flatMap operandLocals ++ placeLocals dest
  | .tailCall f args _ _ => calleeLocals f ++ args.flatMap operandLocals
  | .assert c _ msg _ _ => operandEsc c ++ msg.args.flatMap operandLocals
  | _ => []

def unwindSuccs : UnwindAction → List BasicBlock
  | .cleanup bb => [bb]
  | _ => []

/-- A terminator's successor blocks (unwind edges included). -/
def termSuccs : Terminator → List BasicBlock
  | .goto bb => [bb]
  | .switchInt _ cases otherwise => cases.map (·.2) ++ [otherwise]
  | .drop _ _ t u => t :: unwindSuccs u
  | .call _ _ _ t u _ _ => t.toList ++ unwindSuccs u
  | .assert _ _ _ t u => t :: unwindSuccs u
  | _ => []

/-- The locals a statement reads. -/
def stmtReads : Statement → List Local
  | .assign ⟨_, []⟩ rv => rvalueLocals rv
  | .assign p rv => placeLocals p ++ rvalueLocals rv
  | .setDiscriminant p _ => placeLocals p
  | .assume o => operandLocals o
  | .copyNonOverlapping a b c => operandLocals a ++ operandLocals b ++ operandLocals c
  | .placeMention p => placeLocals p
  | _ => []

/-- The local a statement kills for semantic liveness. -/
def stmtKill : Statement → Option Local
  | .assign ⟨d, []⟩ _ => some d
  | .storageLive l | .storageDead l => some l
  | _ => none

/-- Every local `bodyEsc` treats as live everywhere. -/
def bodyEsc (body : Body) : List Local :=
  body.blocks.toList.flatMap fun bd => bd.stmts.flatMap stmtEsc ++ termEsc bd.term

/-! ### Tables -/

/-- Per block, per point, per local a bit; `n` locals. -/
structure PointTable where
  n : Nat
  rows : Array (Array (Array Bool))
deriving Inhabited

/-- The bit of local `l` at point `i` of block `b`; `false` outside the table. -/
def PointTable.get (t : PointTable) (b i l : Nat) : Bool :=
  decide (l < t.n) && ((((t.rows[b]?).bind fun r => r[i]?).bind fun r => r[l]?).getD false)

theorem PointTable.lt_of_get {t : PointTable} {b i l : Nat} (h : t.get b i l = true) : l < t.n := by
  unfold PointTable.get at h
  simp only [Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.1

def row0 (n : Nat) : Array Bool := Array.replicate n false

def setAll (r : Array Bool) (ls : List Local) (v : Bool) : Array Bool :=
  ls.foldl (fun r l => r.setIfInBounds l v) r

def rowUnion (n : Nat) (a b : Array Bool) : Array Bool :=
  (Array.range n).map fun l => (a[l]?.getD false) || (b[l]?.getD false)

def iterateFix {α : Type} [BEq α] (f : α → α) : Nat → α → α
  | 0, x => x
  | k + 1, x => let y := f x; if y == x then x else iterateFix f k y

/-! ### Semantic liveness -/

def liveTransfer (n : Nat) (esc : Array Bool) (st : Statement) (after : Array Bool) : Array Bool :=
  let killed := match stmtKill st with
    | some d => after.setIfInBounds d false
    | none => after
  rowUnion n esc (setAll killed (stmtReads st) true)

def liveBlockRows (n : Nat) (esc : Array Bool) (entry : BasicBlock → Array Bool)
    (bd : BlockData) : Array (Array Bool) :=
  let out := (termSuccs bd.term).foldl (fun r s => rowUnion n r (entry s))
    (setAll esc (termReads bd.term) true)
  (bd.stmts.foldr (fun st (acc : List (Array Bool)) =>
    match acc with
    | after :: _ => liveTransfer n esc st after :: acc
    | [] => []) [out]).toArray

def liveStep (body : Body) (esc : Array Bool) (t : Array (Array (Array Bool))) :
    Array (Array (Array Bool)) :=
  let n := body.locals.size
  let entry := fun s => ((t[s]?).bind fun r => r[0]?).getD esc
  body.blocks.map (liveBlockRows n esc entry)

def computeLive (body : Body) : PointTable :=
  let n := body.locals.size
  let esc := setAll (row0 n) (bodyEsc body) true
  let init := body.blocks.map fun bd => Array.replicate (bd.stmts.length + 1) esc
  { n, rows := iterateFix (liveStep body esc) (body.blocks.size + 2) init }

/-- What the simulation uses of semantic liveness `lv` (block, point, local). -/
structure LiveSound (body : Body) (lv : BasicBlock → Nat → Local → Bool) : Prop where
  stmt : ∀ b bd, body.blocks[b]? = some bd → ∀ i st, bd.stmts[i]? = some st →
    (∀ l, lv b (i + 1) l = true → stmtKill st ≠ some l → lv b i l = true) ∧
    (∀ l ∈ stmtReads st, lv b i l = true)
  term : ∀ b bd, body.blocks[b]? = some bd →
    (∀ l ∈ termReads bd.term, lv b bd.stmts.length l = true) ∧
    (∀ s ∈ termSuccs bd.term, ∀ l, lv s 0 l = true → lv b bd.stmts.length l = true)
  esc : ∀ b bd, body.blocks[b]? = some bd → ∀ i ≤ bd.stmts.length, ∀ l ∈ bodyEsc body,
    lv b i l = true

def liveStmtOk (t : PointTable) (b i : Nat) (st : Statement) : Bool :=
  (List.range t.n).all (fun l => !t.get b (i + 1) l || stmtKill st == some l || t.get b i l) &&
    (stmtReads st).all (t.get b i)

def liveTermOk (t : PointTable) (b len : Nat) (term : Terminator) : Bool :=
  (termReads term).all (t.get b len) &&
    (termSuccs term).all fun s => (List.range t.n).all fun l => !t.get s 0 l || t.get b len l

def liveEscOk (t : PointTable) (escL : List Local) (b len : Nat) : Bool :=
  (List.range (len + 1)).all fun i => escL.all (t.get b i)

def liveBlockOk (t : PointTable) (escL : List Local) (b : Nat) (bd : BlockData) : Bool :=
  (List.range bd.stmts.length).all (fun i => match bd.stmts[i]? with
    | some st => liveStmtOk t b i st
    | none => true) &&
    liveTermOk t b bd.stmts.length bd.term && liveEscOk t escL b bd.stmts.length

/-- `t` is a post-fixpoint of the liveness equations (see `LiveSound`). -/
def liveCheck (body : Body) (t : PointTable) : Bool :=
  (List.range body.blocks.size).all fun b => match body.blocks[b]? with
    | some bd => liveBlockOk t (bodyEsc body) b bd
    | none => true

theorem liveCheck_block {body : Body} {t : PointTable} (h : liveCheck body t = true)
    {b : Nat} {bd : BlockData} (hb : body.blocks[b]? = some bd) :
    liveBlockOk t (bodyEsc body) b bd = true := by
  have hlt : b < body.blocks.size := (Array.getElem?_eq_some_iff.mp hb).1
  have := List.all_eq_true.mp h b (List.mem_range.mpr hlt)
  simp only [hb] at this
  exact this

theorem liveCheck_sound {body : Body} {t : PointTable} (h : liveCheck body t = true) :
    LiveSound body t.get where
  stmt := by
    intro b bd hb i st hi
    have hB := liveCheck_block h hb
    unfold liveBlockOk at hB
    simp only [Bool.and_eq_true] at hB
    obtain ⟨⟨hS, -⟩, -⟩ := hB
    have hlt : i < bd.stmts.length := (List.getElem?_eq_some_iff.mp hi).1
    have hst := List.all_eq_true.mp hS i (List.mem_range.mpr hlt)
    simp only [hi] at hst
    change liveStmtOk t b i st = true at hst
    unfold liveStmtOk at hst
    simp only [Bool.and_eq_true] at hst
    obtain ⟨h1, h2⟩ := hst
    refine ⟨fun l hl hk => ?_, fun l hl => List.all_eq_true.mp h2 l hl⟩
    have := List.all_eq_true.mp h1 l (List.mem_range.mpr (PointTable.lt_of_get hl))
    simp only [hl, Bool.not_true, Bool.false_or, Bool.or_eq_true, beq_iff_eq] at this
    rcases this with h' | h'
    · exact absurd h' hk
    · exact h'
  term := by
    intro b bd hb
    have hB := liveCheck_block h hb
    unfold liveBlockOk at hB
    simp only [Bool.and_eq_true] at hB
    obtain ⟨⟨-, hT⟩, -⟩ := hB
    unfold liveTermOk at hT
    simp only [Bool.and_eq_true] at hT
    obtain ⟨h1, h2⟩ := hT
    refine ⟨fun l hl => List.all_eq_true.mp h1 l hl, fun s hs l hl => ?_⟩
    have := List.all_eq_true.mp (List.all_eq_true.mp h2 s hs) l
      (List.mem_range.mpr (PointTable.lt_of_get hl))
    simp only [hl, Bool.not_true, Bool.false_or] at this
    exact this
  esc := by
    intro b bd hb i hi l hl
    have hB := liveCheck_block h hb
    unfold liveBlockOk at hB
    simp only [Bool.and_eq_true] at hB
    obtain ⟨-, hE⟩ := hB
    unfold liveEscOk at hE
    exact List.all_eq_true.mp (List.all_eq_true.mp hE i (List.mem_range.mpr (Nat.lt_succ_of_le hi))) l hl

/-- For an assignment to a whole local `d` (the `LowerStmt` rules): every local live after it
but `d` is live before it, and so is every local the rvalue reads. -/
theorem LiveSound.assign {body : Body} {lv : BasicBlock → Nat → Local → Bool}
    (h : LiveSound body lv) {b : BasicBlock} {bd : BlockData} (hb : body.blocks[b]? = some bd)
    {i : Nat} {d : Local} {rv : Rvalue} (hi : bd.stmts[i]? = some (.assign ⟨d, []⟩ rv)) :
    (∀ l, lv b (i + 1) l = true → l ≠ d → lv b i l = true) ∧
      (∀ l ∈ rvalueLocals rv, lv b i l = true) := by
  obtain ⟨h1, h2⟩ := h.stmt b bd hb i _ hi
  refine ⟨fun l hl hne => h1 l hl ?_, fun l hl => h2 l hl⟩
  have hk : stmtKill (.assign ⟨d, []⟩ rv) = some d := rfl
  rw [hk]
  exact fun e => hne (Option.some.inj e).symm

/-- A whole-local operand's local is among the rvalue's reads (binop operands). -/
theorem operand_local_mem {o : Operand} {l : Local} (h : o.local? = some l) :
    l ∈ operandLocals o := by
  unfold Operand.local? at h
  split at h <;> simp_all [operandLocals, placeLocals]

/-! ### Storage liveness -/

/-- The locals some storage statement of the body mentions. -/
def storageMentioned (body : Body) : List Local :=
  body.blocks.toList.flatMap fun bd => bd.stmts.filterMap fun
    | .storageLive l | .storageDead l => some l
    | _ => none

/-- Storage-live at function entry (over-approximated): the return place, the arguments and
the locals without storage statements. -/
def initStorage (body : Body) (l : Local) : Bool :=
  decide (l ≤ body.argCount) || !((storageMentioned body).contains l)

def storageGen : Statement → Option Local
  | .storageLive l => some l
  | _ => none

def storageKill : Statement → Option Local
  | .storageDead l => some l
  | _ => none

def storageTransfer (st : Statement) (r : Array Bool) : Array Bool :=
  match st with
  | .storageLive l => r.setIfInBounds l true
  | .storageDead l => r.setIfInBounds l false
  | _ => r

def storageBlockRows (entryRow : Array Bool) (bd : BlockData) : Array (Array Bool) :=
  bd.stmts.foldl (fun (acc : Array (Array Bool)) st =>
    acc.push (storageTransfer st (acc.back?.getD entryRow))) #[entryRow]

def storageStep (body : Body) (t : Array (Array (Array Bool))) : Array (Array (Array Bool)) :=
  let n := body.locals.size
  let initRow := (Array.range n).map (initStorage body)
  let entries0 := (Array.replicate body.blocks.size (row0 n)).setIfInBounds 0 initRow
  let entries := (List.range body.blocks.size).foldl (fun es b =>
    match body.blocks[b]?, t[b]? with
    | some bd, some rows =>
      (termSuccs bd.term).foldl (fun es s => es.modify s fun r =>
        rowUnion n r (rows.back?.getD (row0 n))) es
    | _, _ => es) entries0
  body.blocks.zipIdx.map fun (bd, b) =>
    storageBlockRows (entries[b]?.getD (row0 n)) bd

def computeStorage (body : Body) : PointTable :=
  let n := body.locals.size
  let init := body.blocks.map fun bd => Array.replicate (bd.stmts.length + 1) (row0 n)
  { n, rows := iterateFix (storageStep body) (body.blocks.size + 2) init }

/-- What the simulation uses of storage liveness `sl` (block, point, local): it
over-approximates the locals with storage. -/
structure StorageSound (body : Body) (sl : BasicBlock → Nat → Local → Bool) : Prop where
  entry : ∀ l, l < body.locals.size → initStorage body l = true → sl 0 0 l = true
  stmt : ∀ b bd, body.blocks[b]? = some bd → ∀ i st, bd.stmts[i]? = some st →
    (∀ l, sl b i l = true → storageKill st ≠ some l → sl b (i + 1) l = true) ∧
    (∀ l, storageGen st = some l → l < body.locals.size → sl b (i + 1) l = true)
  term : ∀ b bd, body.blocks[b]? = some bd →
    ∀ s ∈ termSuccs bd.term, ∀ l, sl b bd.stmts.length l = true → sl s 0 l = true

def storageStmtOk (n : Nat) (t : PointTable) (b i : Nat) (st : Statement) : Bool :=
  (List.range t.n).all (fun l => !t.get b i l || storageKill st == some l || t.get b (i + 1) l) &&
    (match storageGen st with
     | some l => !decide (l < n) || t.get b (i + 1) l
     | none => true)

def storageBlockOk (n : Nat) (t : PointTable) (b : Nat) (bd : BlockData) : Bool :=
  (List.range bd.stmts.length).all (fun i => match bd.stmts[i]? with
    | some st => storageStmtOk n t b i st
    | none => true) &&
    (termSuccs bd.term).all fun s => (List.range t.n).all fun l =>
      !t.get b bd.stmts.length l || t.get s 0 l

/-- `t` is a post-fixpoint of the storage equations (see `StorageSound`). -/
def storageCheck (body : Body) (t : PointTable) : Bool :=
  (List.range body.locals.size).all (fun l => !initStorage body l || t.get 0 0 l) &&
  (List.range body.blocks.size).all fun b => match body.blocks[b]? with
    | some bd => storageBlockOk body.locals.size t b bd
    | none => true

theorem storageCheck_sound {body : Body} {t : PointTable} (h : storageCheck body t = true) :
    StorageSound body t.get := by
  unfold storageCheck at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨hE, hB⟩ := h
  have hblk : ∀ {b bd}, body.blocks[b]? = some bd → storageBlockOk body.locals.size t b bd = true := by
    intro b bd hb
    have hlt : b < body.blocks.size := (Array.getElem?_eq_some_iff.mp hb).1
    have := List.all_eq_true.mp hB b (List.mem_range.mpr hlt)
    simp only [hb] at this
    exact this
  refine ⟨?_, ?_, ?_⟩
  · intro l hl hi
    have := List.all_eq_true.mp hE l (List.mem_range.mpr hl)
    simp only [hi, Bool.not_true, Bool.false_or] at this
    exact this
  · intro b bd hb i st hi
    have hb' := hblk hb
    unfold storageBlockOk at hb'
    simp only [Bool.and_eq_true] at hb'
    obtain ⟨hS, -⟩ := hb'
    have hlt : i < bd.stmts.length := (List.getElem?_eq_some_iff.mp hi).1
    have hst := List.all_eq_true.mp hS i (List.mem_range.mpr hlt)
    simp only [hi] at hst
    change storageStmtOk body.locals.size t b i st = true at hst
    unfold storageStmtOk at hst
    simp only [Bool.and_eq_true] at hst
    obtain ⟨h1, h2⟩ := hst
    refine ⟨fun l hl hk => ?_, fun l hg hn => ?_⟩
    · have := List.all_eq_true.mp h1 l (List.mem_range.mpr (PointTable.lt_of_get hl))
      simp only [hl, Bool.not_true, Bool.false_or, Bool.or_eq_true, beq_iff_eq] at this
      rcases this with h' | h'
      · exact absurd h' hk
      · exact h'
    · simp only [hg] at h2
      simpa [hn] using h2
  · intro b bd hb s hs l hl
    have hb' := hblk hb
    unfold storageBlockOk at hb'
    simp only [Bool.and_eq_true] at hb'
    obtain ⟨-, hT⟩ := hb'
    have := List.all_eq_true.mp (List.all_eq_true.mp hT s hs) l
      (List.mem_range.mpr (PointTable.lt_of_get hl))
    simp only [hl, Bool.not_true, Bool.false_or] at this
    exact this

/-! ### Slot layout -/

/-- Whether two slots share a byte. -/
def slotsOverlap (a b : LocalSlot) : Bool :=
  !(decide (a.off + a.size ≤ b.off) || decide (b.off + b.size ≤ a.off))

/-- The pairs of distinct locals below `n` whose slots overlap. -/
def overlapPairs (slots : Array LocalSlot) (n : Nat) : List (Local × Local) :=
  (List.range n).flatMap fun l => (List.range n).filterMap fun l' =>
    match slots[l]?, slots[l']? with
    | some s, some s' => if l ≠ l' ∧ slotsOverlap s s' = true then some (l, l') else none
    | _, _ => none

/-- Distinct locals that are both semantically and storage-live at a point have disjoint
slots. -/
def LayoutOk (body : Body) (slots : Array LocalSlot) (lv sl : BasicBlock → Nat → Local → Bool) :
    Prop :=
  ∀ b bd, body.blocks[b]? = some bd → ∀ i ≤ bd.stmts.length, ∀ l l', l ≠ l' →
    lv b i l = true → lv b i l' = true → sl b i l = true → sl b i l' = true →
    ∀ s s', slots[l]? = some s → slots[l']? = some s' →
      s.off + s.size ≤ s'.off ∨ s'.off + s'.size ≤ s.off

def layoutCheck (body : Body) (slots : Array LocalSlot) (lv sl : PointTable) : Bool :=
  let ps := overlapPairs slots lv.n
  (List.range body.blocks.size).all fun b => match body.blocks[b]? with
    | some bd => (List.range (bd.stmts.length + 1)).all fun i => ps.all fun p =>
        !(lv.get b i p.1 && lv.get b i p.2 && sl.get b i p.1 && sl.get b i p.2)
    | none => true

theorem layoutCheck_sound {body : Body} {slots : Array LocalSlot} {lv sl : PointTable}
    (h : layoutCheck body slots lv sl = true) : LayoutOk body slots lv.get sl.get := by
  intro b bd hb i hi l l' hne h1 h2 h3 h4 s s' hs hs'
  have hlt : b < body.blocks.size := (Array.getElem?_eq_some_iff.mp hb).1
  have hB := List.all_eq_true.mp h b (List.mem_range.mpr hlt)
  simp only [hb] at hB
  have hI := List.all_eq_true.mp hB i (List.mem_range.mpr (Nat.lt_succ_of_le hi))
  by_cases hov : slotsOverlap s s' = true
  · have hmem : (l, l') ∈ overlapPairs slots lv.n := by
      unfold overlapPairs
      apply List.mem_flatMap.mpr
      refine ⟨l, List.mem_range.mpr (PointTable.lt_of_get h1), ?_⟩
      apply List.mem_filterMap.mpr
      refine ⟨l', List.mem_range.mpr (PointTable.lt_of_get h2), ?_⟩
      simp [hs, hs', hne, hov]
    have := List.all_eq_true.mp hI _ hmem
    simp [h1, h2, h3, h4] at this
  · simp only [slotsOverlap, Bool.not_eq_true, Bool.not_eq_false', Bool.or_eq_true,
      decide_eq_true_eq] at hov
    exact hov

/-- Distinct locals that are both storage-live at a point have disjoint slots: L0 allocates
them at their slots (the simulation's address choice), and live allocations don't overlap.
Slots may still be shared by locals never storage-live together. -/
def ShareOk (body : Body) (slots : Array LocalSlot) (sl : BasicBlock → Nat → Local → Bool) :
    Prop :=
  ∀ b bd, body.blocks[b]? = some bd → ∀ i ≤ bd.stmts.length, ∀ l l', l ≠ l' →
    sl b i l = true → sl b i l' = true →
    ∀ s s', slots[l]? = some s → slots[l']? = some s' →
      s.off + s.size ≤ s'.off ∨ s'.off + s'.size ≤ s.off

/-- `ShareOk` over the overlapping pairs, and the frame map no longer than the locals. -/
def shareCheck (body : Body) (slots : Array LocalSlot) (sl : PointTable) : Bool :=
  let ps := overlapPairs slots sl.n
  decide (slots.size ≤ body.locals.size) &&
  (List.range body.blocks.size).all fun b => match body.blocks[b]? with
    | some bd => (List.range (bd.stmts.length + 1)).all fun i => ps.all fun p =>
        !(sl.get b i p.1 && sl.get b i p.2)
    | none => true

theorem shareCheck_sound {body : Body} {slots : Array LocalSlot} {sl : PointTable}
    (h : shareCheck body slots sl = true) :
    slots.size ≤ body.locals.size ∧ ShareOk body slots sl.get := by
  unfold shareCheck at h
  simp only [Bool.and_eq_true, decide_eq_true_eq] at h
  refine ⟨h.1, ?_⟩
  intro b bd hb i hi l l' hne h3 h4 s s' hs hs'
  have hlt : b < body.blocks.size := (Array.getElem?_eq_some_iff.mp hb).1
  have hB := List.all_eq_true.mp h.2 b (List.mem_range.mpr hlt)
  simp only [hb] at hB
  have hI := List.all_eq_true.mp hB i (List.mem_range.mpr (Nat.lt_succ_of_le hi))
  by_cases hov : slotsOverlap s s' = true
  · have hmem : (l, l') ∈ overlapPairs slots sl.n := by
      unfold overlapPairs
      apply List.mem_flatMap.mpr
      refine ⟨l, List.mem_range.mpr (PointTable.lt_of_get h3), ?_⟩
      apply List.mem_filterMap.mpr
      refine ⟨l', List.mem_range.mpr (PointTable.lt_of_get h4), ?_⟩
      simp [hs, hs', hne, hov]
    have := List.all_eq_true.mp hI _ hmem
    simp [h3, h4] at this
  · simp only [slotsOverlap, Bool.not_eq_true, Bool.not_eq_false', Bool.or_eq_true,
      decide_eq_true_eq] at hov
    exact hov

/-! ### Running the checks -/

/-- Compute both liveness tables and run the three checks on a body and its frame map. -/
def runLiveChecks (body : Body) (slots : Array LocalSlot) : Verdict :=
  let lv := computeLive body
  let sl := computeStorage body
  if !liveCheck body lv then .rejected "liveness: not a post-fixpoint"
  else if !storageCheck body sl then .rejected "storage liveness: not a post-fixpoint"
  else if !layoutCheck body slots lv sl then .rejected "layout: overlapping slots live together"
  else .ok

/-- What `runLiveChecks … = .ok` gives the simulation. -/
theorem runLiveChecks_sound {body : Body} {slots : Array LocalSlot}
    (h : runLiveChecks body slots = .ok) :
    LiveSound body (computeLive body).get ∧ StorageSound body (computeStorage body).get ∧
      LayoutOk body slots (computeLive body).get (computeStorage body).get := by
  have e1 : liveCheck body (computeLive body) = true := by
    cases hc : liveCheck body (computeLive body) <;> simp_all [runLiveChecks]
  have e2 : storageCheck body (computeStorage body) = true := by
    cases hc : storageCheck body (computeStorage body) <;> simp_all [runLiveChecks]
  have e3 : layoutCheck body slots (computeLive body) (computeStorage body) = true := by
    cases hc : layoutCheck body slots (computeLive body) (computeStorage body) <;>
      simp_all [runLiveChecks]
  exact ⟨liveCheck_sound e1, storageCheck_sound e2, layoutCheck_sound e3⟩

end Ryo.Check.Lower
