/-
Ryo.Check.Lower.Reach — the blocks L0 can reach from block 0 (aot.md §C1, M5b), so that the
function simulation needs no rule for the others: the certificate's `dead` blocks
(`BlockCert.dead`: not `mir::traversal::mono_reachable`, lowered as a lone `unreachable` with
no statement ranges) among them.

`monoSuccs term` over-approximates the blocks L0 continues at after `term`: `termSuccs`, except
for a `SwitchInt` whose operand is a constant or a runtime check (`staticBits`), which goes to
the one target of its value, as `Body::try_const_mono_switchint` does for `mono_reachable` (its
second pattern, a switch on a local the block's last statement assigns a constant, doesn't
occur in the corpus: all of its static switches are on a constant or `RuntimeChecks` operand).
`staticBits` is L0's `switchBits` of the operand's value: a `bool` constant's byte (L0's decode
fails unless it is 0 or 1), an integer constant's bits below `2 ^ (8 n)` (`evalConst` decodes
them at the type), a runtime check's recorded value (D23).

`computeReach` iterates to a fixpoint; it is untrusted: `reachCheck` checks the result contains
block 0 and is closed under `monoSuccs` (`ReachSound`, `reachCheck_sound`), which is what the
simulation uses (`Proofs/Lower/SimReach.lean`: L0's every block entered from block 0 is in it).
Nothing here trusts the certificate's `dead`: a `dead` block `reachCheck`'s set contains needs
its lowering checked like any other (and fails, being a lone `unreachable`).
-/
import Ryo.Check.Lower.Switch
import Ryo.Check.Lower.Live

namespace Ryo.Check.Lower

open Ryo.Spec

/-- The value L0's `switchBits` gives a `SwitchInt` operand known statically (see the module
comment). -/
def staticBits : Operand → Option Nat
  | .const (.scalar bits) .bool => some (bits % 256)
  | .const (.scalar bits) (.int t _) => if 0 < t.size then some (bits % 2 ^ (8 * t.size)) else none
  | .runtimeChecks _ b => some (if b then 1 else 0)
  | _ => none

/-- The blocks L0 can continue at after terminator `term` (see the module comment). -/
def monoSuccs : Terminator → List BasicBlock
  | .switchInt d cases otherwise =>
    match staticBits d with
    | some bits => [caseTarget cases otherwise bits]
    | none => cases.map (·.2) ++ [otherwise]
  | t => termSuccs t

theorem monoSuccs_of_termSuccs {term : Terminator} {b : BasicBlock} (h : b ∈ termSuccs term)
    (hns : ∀ d cases otherwise, term = .switchInt d cases otherwise → staticBits d = none) :
    b ∈ monoSuccs term := by
  cases term
  case switchInt d cases otherwise =>
    have hn := hns d cases otherwise rfl
    simp only [monoSuccs, hn]
    exact h
  all_goals first | exact h | (simp only [monoSuccs]; exact h)

/-- Membership in a reach table (out of range: not reached). -/
def reachGet (r : Array Bool) (b : Nat) : Bool := r[b]?.getD false

/-- The reach table's soundness: block 0 is in it, and it is closed under `monoSuccs`. -/
structure ReachSound (body : Body) (r : Nat → Bool) : Prop where
  entry : r 0 = true
  closed : ∀ b bd, body.blocks[b]? = some bd → r b = true → ∀ b' ∈ monoSuccs bd.term,
    r b' = true

/-- One round: every block reached so far adds its `monoSuccs`. -/
def reachStep (body : Body) (r : Array Bool) : Array Bool :=
  (List.range body.blocks.size).foldl (fun r b =>
    if reachGet r b then
      match body.blocks[b]? with
      | some bd => (monoSuccs bd.term).foldl (fun r b' => r.setIfInBounds b' true) r
      | none => r
    else r) r

/-- Rounds until nothing changes (at most `fuel`). -/
def reachFix (body : Body) : Nat → Array Bool → Array Bool
  | 0, r => r
  | k + 1, r =>
    let r' := reachStep body r
    if r' == r then r else reachFix body k r'

/-- The reach table (untrusted: `reachCheck` checks it). -/
def computeReach (body : Body) : Array Bool :=
  reachFix body (body.blocks.size + 1)
    ((Array.replicate body.blocks.size false).setIfInBounds 0 true)

/-- `ReachSound`'s check. -/
def reachCheck (body : Body) (r : Array Bool) : Bool :=
  reachGet r 0 && (List.range body.blocks.size).all fun b =>
    !reachGet r b || match body.blocks[b]? with
      | some bd => (monoSuccs bd.term).all (reachGet r)
      | none => true

theorem reachCheck_sound {body : Body} {r : Array Bool} (h : reachCheck body r = true) :
    ReachSound body (reachGet r) := by
  unfold reachCheck at h
  simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range] at h
  obtain ⟨h0, hall⟩ := h
  refine ⟨h0, ?_⟩
  intro b bd hb hr b' hb'
  have hlt : b < body.blocks.size := (Array.getElem?_eq_some_iff.mp hb).1
  have hx := hall b hlt
  rw [hb, hr] at hx
  simp only [Bool.not_true, Bool.false_or, List.all_eq_true] at hx
  exact hx b' hb'

/-- `reachCheck` at `computeReach`, for `checkFn`. -/
def reachOk (body : Body) : Bool := reachCheck body (computeReach body)

theorem reachOk_sound {body : Body} (h : reachOk body = true) :
    ReachSound body (reachGet (computeReach body)) :=
  reachCheck_sound h

end Ryo.Check.Lower
