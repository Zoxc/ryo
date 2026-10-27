/-
Ryo.X86.Fetch — L2 with code in memory (x86.md §B.2, aot.md §C2): the item at `rip` runs.

`execItems` (`Ryo.X86.Exec`) runs a list of items in list order, whatever `rip` they leave;
`decode_sound` needs the machine that fetches. Here code is bytes in the state's memory:

- `Item.linkedAt ctx i pos`: the bytes of item `i` at function position `pos`, as the linker
  leaves them: `Item.encode pos`, its relocated fields patched by `link` for code at
  `ctx.base + pos` against `ctx.addrOf` (each field `target - (field + 4)`).
- `ItemAt ctx m i pos`: those bytes are in `m` at `addrAt ctx pos = ctx.base + pos`;
  `CodeAt ctx m items pos`: a contiguous list, each item at the position past the previous
  one (`Item.size`, the length `Item.exec` advances `rip` by); `InCode` is the set of the
  addresses those bytes occupy. `CodeLoaded ctx m code`: the function's whole byte array (what
  the decoder reads, `Cursor.code`) is at `ctx.base`.
- `Item.Canonical pos i`: `i` is an item the encoder emits at `pos` (`Item.wf`, or its
  `Item.spFrame` form without a frame pointer) and not data (`tableEntry`); `Canon items pos`
  for a contiguous list.
- `Step ctx x x'`: some canonical item whose bytes are at `x.rip` executes (`Item.exec`)
  without a fault and leaves `x'`; `Faults ctx x f`: it faults with `f`. `Steps` is the
  reflexive-transitive closure of `Step`.
- `FetchRun ctx S items x`: running `items` from `x` (as `execItems` does) each item continues
  at the next one (`rip` advanced by its size) and leaves the bytes at `S` in place.
  `Item.FallsThrough`, `Item.MemKept` are the per-item, every-state versions
  (`fetchRun_of_forall`).
- `steps_of_run`: such a run, canonical and in memory at `rip`, is `Steps` to the state
  `execItems` gives; `steps_of_run_last`: the same with a final item that may transfer control
  anywhere (a taken branch, `jmp rax`); `faults_of_run`: a run that faults reaches a fetched
  fault.

Trust. That bytes `linkedAt ctx i pos` at `rip` mean `Item.exec ctx i` is the trusted x86
semantics (`Ryo.X86.Exec`, co-simulated on the CPU, x86.md §B.3) together with `link` (the
`R_X86_64_PC32` patching). `Step` is restricted to canonical items because other `Item`s
share bytes with them but not their meaning: `nop 0` is no bytes at all, `setcc .always` is
`seto`'s bytes, and a `tableEntry` is any 4 bytes. Even so `Step` is a relation: two items
whose linked bytes are at the same address (two `call`s whose references the linker put at
one address) each give a `Step`. Determinism: `ExecUnique ctx` (two canonical items whose
linked bytes are at the same address execute alike on every state with that memory), from
which `step_deterministic` derives that `Step ctx` is a function (`faults_not_step`: nor does a
faulting state step). `Ryo.X86.Unique` proves it given `RefsNear ctx` (`execUnique`: x86
decoding is prefix-determined, and canonical items with equal linked bytes differ only in what
the linker resolved to the same address).

Calls leave the function: `Step` executes `call` as `Item.exec` does (a push and a jump); what
runs at the target is the environment's (`Ryo.Proofs.Handler`'s `Ret` for handlers,
`Ryo/X86/Env.lean` later).
-/
import Ryo.X86.Exec

set_option linter.constructorNameAsVariable false

namespace Ryo.X86

/-! ### Code in memory -/

/-- `bs` is in `m` from address `a` on. -/
def BytesAt (m : Mem) (a : BitVec 64) (bs : List UInt8) : Prop :=
  ∀ j (h : j < bs.length), m (a + BitVec.ofNat 64 j) = bs[j]

/-- The address of function position `pos`. -/
def addrAt (ctx : Ctx) (pos : Nat) : BitVec 64 := ctx.base + BitVec.ofNat 64 pos

/-- The bytes of item `i` at function position `pos`, linked: `Item.encode pos` (whose
relocations are at function positions) with its fields patched for code at `addrAt ctx pos`. -/
def Item.linkedAt (ctx : Ctx) (i : Item) (pos : Nat) : List UInt8 :=
  let p := BitVec.ofNat 32 pos
  let (bs, rs) := i.encode p
  link (addrAt ctx pos) ctx.addrOf bs (rs.map fun r => { r with pos := r.pos - p.toNat })

/-- Item `i`, at function position `pos`, is in memory `m`. -/
def ItemAt (ctx : Ctx) (m : Mem) (i : Item) (pos : Nat) : Prop :=
  BytesAt m (addrAt ctx pos) (i.linkedAt ctx pos)

/-- The total size of a list of items. -/
def codeSize (items : List Item) : Nat := (items.map Item.size).sum

/-- `items` are in memory `m`, contiguous from function position `pos`. -/
def CodeAt (ctx : Ctx) (m : Mem) : List Item → Nat → Prop
  | [], _ => True
  | i :: is, pos => ItemAt ctx m i pos ∧ CodeAt ctx m is (pos + i.size)

/-- The addresses the bytes of `items` from position `pos` occupy. -/
def InCode (ctx : Ctx) : List Item → Nat → BitVec 64 → Prop
  | [], _, _ => False
  | i :: is, pos, a =>
    (∃ j, j < (i.linkedAt ctx pos).length ∧ a = addrAt ctx pos + BitVec.ofNat 64 j) ∨
      InCode ctx is (pos + i.size) a

/-- An item the encoder emits at function position `pos` (`Item.wf`, or its frame operand
moved to `rsp` without a frame pointer, `Item.spFrame`), and not data (`tableEntry`): the items
whose bytes `Step` executes. -/
def Item.Canonical (pos : Nat) (i : Item) : Prop :=
  (∀ b e, i ≠ .tableEntry b e) ∧
    (i.wf (BitVec.ofNat 32 pos) = true ∨
      ∃ (j : Item) (f : BitVec 32), j.wf (BitVec.ofNat 32 pos) = true ∧ i = j.spFrame f)

/-- Every item of `items`, contiguous from `pos`, is canonical at its position. -/
def Canon : List Item → Nat → Prop
  | [], _ => True
  | i :: is, pos => i.Canonical pos ∧ Canon is (pos + i.size)

/-- The function's code (the decoder's `Cursor.code`) is in memory `m` at `ctx.base`. -/
def CodeLoaded (ctx : Ctx) (m : Mem) (code : Array UInt8) : Prop :=
  BytesAt m ctx.base code.toList

/-! ### The fetching step -/

/-- One step: a canonical item whose linked bytes are at `rip` executes without a fault. -/
inductive Step (ctx : Ctx) : State → State → Prop
  | exec {x x' : State} (i : Item) (pos : Nat) : i.Canonical pos → ItemAt ctx x.mem i pos →
      x.rip = addrAt ctx pos → i.exec ctx x = .ok x' → Step ctx x x'

/-- A canonical item whose linked bytes are at `rip` faults with `f`. -/
def Faults (ctx : Ctx) (x : State) (f : Fault) : Prop :=
  ∃ i pos, i.Canonical pos ∧ ItemAt ctx x.mem i pos ∧ x.rip = addrAt ctx pos ∧ i.exec ctx x = .error f

/-- Zero or more steps. -/
inductive Steps (ctx : Ctx) : State → State → Prop
  | refl (x : State) : Steps ctx x x
  | step {x y z : State} : Step ctx x y → Steps ctx y z → Steps ctx x z

/-- Determinism of decoding, as a hypothesis (see the module comment): two canonical items
whose linked bytes are at the same address execute alike from every state with that memory. -/
def ExecUnique (ctx : Ctx) : Prop :=
  ∀ (x : State) (i j : Item) (p q : Nat), i.Canonical p → j.Canonical q →
    ItemAt ctx x.mem i p → ItemAt ctx x.mem j q →
    addrAt ctx p = addrAt ctx q → i.exec ctx x = j.exec ctx x

/-- `Step ctx` is a function. -/
def StepDeterministic (ctx : Ctx) : Prop :=
  ∀ x y z, Step ctx x y → Step ctx x z → y = z

theorem step_deterministic {ctx : Ctx} (h : ExecUnique ctx) : StepDeterministic ctx := by
  intro x y z hy hz
  cases hy with
  | exec i p ci hi hr he =>
    cases hz with
    | exec j q cj hj hr' he' =>
      have := h x i j p q ci cj hi hj (hr ▸ hr')
      rw [this, he'] at he
      cases he
      rfl

/-- Under `ExecUnique`, a state that faults doesn't step. -/
theorem faults_not_step {ctx : Ctx} (h : ExecUnique ctx) {x y : State} {f : Fault}
    (hf : Faults ctx x f) (hs : Step ctx x y) : False := by
  obtain ⟨i, p, ci, hi, hr, he⟩ := hf
  cases hs with
  | exec j q cj hj hr' he' =>
    rw [h x i j p q ci cj hi hj (hr ▸ hr'), he'] at he
    cases he

namespace Steps

theorem single {ctx : Ctx} {x y : State} (h : Step ctx x y) : Steps ctx x y :=
  .step h (.refl y)

theorem trans {ctx : Ctx} {x y z : State} (h1 : Steps ctx x y) (h2 : Steps ctx y z) :
    Steps ctx x z := by
  induction h1 with
  | refl => exact h2
  | step h _ ih => exact .step h (ih h2)

theorem tail {ctx : Ctx} {x y z : State} (h1 : Steps ctx x y) (h2 : Step ctx y z) :
    Steps ctx x z :=
  h1.trans (single h2)

end Steps

/-! ### Straight-line runs -/

/-- Every successful execution of `i` continues at the next item. -/
def Item.FallsThrough (ctx : Ctx) (i : Item) : Prop :=
  ∀ s s', i.exec ctx s = .ok s' → s'.rip = s.rip + BitVec.ofNat 64 i.size

/-- No successful execution of `i` changes memory. -/
def Item.MemKept (ctx : Ctx) (i : Item) : Prop :=
  ∀ s s', i.exec ctx s = .ok s' → s'.mem = s.mem

/-- Running `items` from `x` in order, each item that succeeds continues at the next one and
keeps the bytes at the addresses `S` (the code). -/
def FetchRun (ctx : Ctx) (S : BitVec 64 → Prop) : List Item → State → Prop
  | [], _ => True
  | i :: is, x => ∀ y, i.exec ctx x = .ok y →
      y.rip = x.rip + BitVec.ofNat 64 i.size ∧ (∀ a, S a → y.mem a = x.mem a) ∧
        FetchRun ctx S is y

theorem fetchRun_of_forall {ctx : Ctx} {S : BitVec 64 → Prop} {items : List Item}
    (h : ∀ i ∈ items, i.FallsThrough ctx ∧ i.MemKept ctx) (x : State) :
    FetchRun ctx S items x := by
  induction items generalizing x with
  | nil => trivial
  | cons i is ih =>
    intro y hy
    obtain ⟨hf, hm⟩ := h i (by simp)
    exact ⟨hf x y hy, fun a _ => by rw [hm x y hy],
      ih (fun j hj => h j (by simp [hj])) y⟩

theorem addrAt_add (ctx : Ctx) (p n : Nat) :
    addrAt ctx (p + n) = addrAt ctx p + BitVec.ofNat 64 n := by
  simp [addrAt, BitVec.ofNat_add, BitVec.add_assoc]

theorem codeSize_nil : codeSize [] = 0 := rfl

theorem codeSize_cons (i : Item) (is : List Item) :
    codeSize (i :: is) = i.size + codeSize is := by
  simp [codeSize]

theorem codeSize_append (a b : List Item) : codeSize (a ++ b) = codeSize a + codeSize b := by
  simp [codeSize]

theorem codeAt_append {ctx : Ctx} {m : Mem} (a b : List Item) (pos : Nat) :
    CodeAt ctx m (a ++ b) pos ↔ CodeAt ctx m a pos ∧ CodeAt ctx m b (pos + codeSize a) := by
  induction a generalizing pos with
  | nil => simp [CodeAt, codeSize_nil]
  | cons i is ih =>
    simp only [List.cons_append, CodeAt, ih, codeSize_cons, Nat.add_assoc, and_assoc]

theorem canon_append (a b : List Item) (pos : Nat) :
    Canon (a ++ b) pos ↔ Canon a pos ∧ Canon b (pos + codeSize a) := by
  induction a generalizing pos with
  | nil => simp [Canon, codeSize_nil]
  | cons i is ih =>
    simp only [List.cons_append, Canon, ih, codeSize_cons, Nat.add_assoc, and_assoc]

theorem inCode_append {ctx : Ctx} (a b : List Item) (pos : Nat) (x : BitVec 64) :
    InCode ctx (a ++ b) pos x ↔ InCode ctx a pos x ∨ InCode ctx b (pos + codeSize a) x := by
  induction a generalizing pos with
  | nil => simp [InCode, codeSize_nil]
  | cons i is ih =>
    simp only [List.cons_append, InCode, ih, codeSize_cons, Nat.add_assoc, or_assoc]

/-- Code stays in memory where memory keeps its bytes. -/
theorem codeAt_of_agree {ctx : Ctx} {m m' : Mem} {items : List Item} {pos : Nat}
    (h : CodeAt ctx m items pos) (ha : ∀ a, InCode ctx items pos a → m' a = m a) :
    CodeAt ctx m' items pos := by
  induction items generalizing pos with
  | nil => trivial
  | cons i is ih =>
    refine ⟨fun j hj => ?_, ih h.2 fun a hin => ha a (.inr hin)⟩
    rw [ha _ (.inl ⟨j, hj, rfl⟩)]
    exact h.1 j hj

theorem execItems_nil (ctx : Ctx) (x : State) : execItems ctx [] x = .ok x := rfl

theorem execItems_cons (ctx : Ctx) (i : Item) (is : List Item) (x : State) :
    execItems ctx (i :: is) x = (i.exec ctx x >>= execItems ctx is) := by
  simp only [execItems, List.foldlM_cons]; rfl

theorem execItems_append (ctx : Ctx) (a b : List Item) (x : State) :
    execItems ctx (a ++ b) x = (execItems ctx a x >>= execItems ctx b) := by
  simp only [execItems, List.foldlM_append]; rfl

theorem except_bind_ok {ε α β : Type} {m : Except ε α} {f : α → Except ε β} {b : β}
    (h : (m >>= f) = .ok b) : ∃ a, m = .ok a ∧ f a = .ok b := by
  cases m with
  | error e => cases h
  | ok a => exact ⟨a, rfl, h⟩

theorem except_bind_error {ε α β : Type} {m : Except ε α} {f : α → Except ε β} {e : ε}
    (h : (m >>= f) = .error e) : m = .error e ∨ ∃ a, m = .ok a ∧ f a = .error e := by
  cases m with
  | error e' => cases h; exact .inl rfl
  | ok a => exact .inr ⟨a, rfl, h⟩

/-- A straight-line run, its code in memory from `rip` on, is fetched: `Steps` to the state
`execItems` gives, `rip` past the code, the bytes at `S` kept. -/
theorem steps_of_run {ctx : Ctx} {S : BitVec 64 → Prop} {items : List Item} {pos : Nat}
    {x x' : State} (hcan : Canon items pos) (hc : CodeAt ctx x.mem items pos)
    (hrip : x.rip = addrAt ctx pos) (hS : ∀ a, InCode ctx items pos a → S a)
    (hrun : FetchRun ctx S items x) (he : execItems ctx items x = .ok x') :
    Steps ctx x x' ∧ x'.rip = addrAt ctx (pos + codeSize items) ∧
      ∀ a, S a → x'.mem a = x.mem a := by
  induction items generalizing x pos with
  | nil =>
    cases he
    exact ⟨.refl _, by simp [hrip, codeSize_nil], fun _ _ => rfl⟩
  | cons i is ih =>
    rw [execItems_cons] at he
    obtain ⟨y, hy, hrest⟩ := except_bind_ok he
    obtain ⟨hyr, hym, hrun'⟩ := hrun y hy
    have hc' : CodeAt ctx y.mem is (pos + i.size) :=
      codeAt_of_agree hc.2 fun a hin => hym a (hS a (.inr hin))
    have hyrip : y.rip = addrAt ctx (pos + i.size) := by rw [hyr, hrip, addrAt_add]
    obtain ⟨hs, hr, hm⟩ := ih hcan.2 hc' hyrip (fun a hin => hS a (.inr hin)) hrun' hrest
    refine ⟨.step (.exec i pos hcan.1 hc.1 hrip hy) hs, ?_, fun a ha => (hm a ha).trans (hym a ha)⟩
    rw [hr, codeSize_cons, Nat.add_assoc]

/-- A straight-line run and a final item that may transfer control anywhere (a taken branch,
`jmp rax`, a call): `Steps` to the state `execItems` gives. -/
theorem steps_of_run_last {ctx : Ctx} {S : BitVec 64 → Prop} {items : List Item} {j : Item}
    {pos : Nat} {x x' : State} (hcan : Canon (items ++ [j]) pos)
    (hc : CodeAt ctx x.mem (items ++ [j]) pos)
    (hrip : x.rip = addrAt ctx pos) (hS : ∀ a, InCode ctx (items ++ [j]) pos a → S a)
    (hrun : FetchRun ctx S items x) (he : execItems ctx (items ++ [j]) x = .ok x') :
    Steps ctx x x' := by
  rw [codeAt_append] at hc
  rw [canon_append] at hcan
  rw [execItems_append] at he
  obtain ⟨y, hy, hj⟩ := except_bind_ok he
  obtain ⟨hs, hr, hm⟩ :=
    steps_of_run hcan.1 hc.1 hrip (fun a hin => hS a ((inCode_append _ _ _ _).2 (.inl hin))) hrun hy
  have hcj : CodeAt ctx y.mem [j] (pos + codeSize items) :=
    codeAt_of_agree hc.2 fun a hin => hm a (hS a ((inCode_append _ _ _ _).2 (.inr hin)))
  rw [execItems_cons] at hj
  obtain ⟨z, hz, hnil⟩ := except_bind_ok hj
  cases hnil
  exact hs.tail (.exec j _ hcan.2.1 hcj.1 hr hz)

/-- A straight-line run that faults reaches, by fetching, a state whose item faults. -/
theorem faults_of_run {ctx : Ctx} {S : BitVec 64 → Prop} {items : List Item} {pos : Nat}
    {x : State} {f : Fault} (hcan : Canon items pos) (hc : CodeAt ctx x.mem items pos)
    (hrip : x.rip = addrAt ctx pos)
    (hS : ∀ a, InCode ctx items pos a → S a) (hrun : FetchRun ctx S items x)
    (he : execItems ctx items x = .error f) :
    ∃ y, Steps ctx x y ∧ Faults ctx y f := by
  induction items generalizing x pos with
  | nil => cases he
  | cons i is ih =>
    rw [execItems_cons] at he
    rcases except_bind_error he with hi | ⟨y, hy, hrest⟩
    · exact ⟨x, .refl x, i, pos, hcan.1, hc.1, hrip, hi⟩
    · obtain ⟨hyr, hym, hrun'⟩ := hrun y hy
      have hc' : CodeAt ctx y.mem is (pos + i.size) :=
        codeAt_of_agree hc.2 fun a hin => hym a (hS a (.inr hin))
      have hyrip : y.rip = addrAt ctx (pos + i.size) := by rw [hyr, hrip, addrAt_add]
      obtain ⟨z, hs, hf⟩ := ih hcan.2 hc' hyrip (fun a hin => hS a (.inr hin)) hrun' hrest
      exact ⟨z, .step (.exec i pos hcan.1 hc.1 hrip hy) hs, hf⟩

end Ryo.X86
