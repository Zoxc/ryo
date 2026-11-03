/-
Ryo.Vm.ArgsLeadCheck — a Lean-only check of the leading `arg`s (`argsLeadCheck`, run by
`Frame.decodeChecked`).

The decoder reads `arg`s only at the start of the body (the leading run) and checks neither
that two of them read different registers nor that no branch targets one. The check reruns
`read` and accepts if (`argsLeadOk`)

- the registers of the leading run (`leadRun`, `argRegOf`: R's register of an `arg d, w`) are
  pairwise distinct (`regsDistinct`; an operand list that isn't an `arg`'s gives `none`, which
  is rejected if it occurs twice), and
- no target of any instruction is the position of a leading `arg`.

`Ryo.Proofs.DecodeSound.Hyps.argsUntargeted` (`DecodeSound/Basic.lean`) and
`Ryo.Proofs.Discharge.ArgsOk`'s `argsOk_distinct` turn its success into `ArgsOk`.
-/
import Ryo.Vm.DecodeReduced

namespace Ryo.Vm

open Ryo.X86 Ryo.Vm.R Ryo.Vm.Asm DM

/-- The leading run of `arg`s. -/
def leadRun : List Proto → List Proto
  | [] => []
  | q :: qs => if q.op == .arg then q :: leadRun qs else []

/-- The register an `arg d, w` reads, as the class and index `R.Reg.ofArgReg` distinguishes
(`R` imports `Frame`, which runs this check, so `R.Reg` itself isn't available); `none` for
other operands. -/
def argRegOf (q : Proto) : Option (Bool × Nat) :=
  match q.ops with
  | [.slot _, .imm w] => (ArgReg.of? w.toNat true).map fun a => (a.xmm, a.index)
  | _ => none

/-- No two entries are equal. -/
def regsDistinct : List (Option (Bool × Nat)) → Bool
  | [] => true
  | r :: rs => rs.all (· != r) && regsDistinct rs

/-- The leading `arg`s read distinct registers and no target is the position of one. -/
def argsLeadOk (protos : Array Proto) : Bool :=
  let lead := leadRun protos.toList
  regsDistinct (lead.map argRegOf) &&
    protos.toList.all fun q => q.targets.all fun t => !(lead.any (·.pos == t))

/-- `argsLeadOk` on `read`'s instructions. -/
def argsLeadCheck (code : ByteArray) (relocs : Array Reloc) (rodata : ByteArray)
    (callSites : Array CallSite) (dropped : Array DroppedStore) (scopes : Array Scope)
    (mode : Mode) : Bool :=
  match (read rodata callSites dropped.toList scopes mode).run
      ({ code := code.data, pos := 0, fields := .relocs relocs } : Cursor) with
  | .error _ => false
  | .ok (r, _) => argsLeadOk r.protos

/-! ### List facts (used by the proofs) -/

theorem mem_of_getElem?_some {α : Type} : ∀ {l : List α} {n : Nat} {a : α}, l[n]? = some a →
    a ∈ l
  | [], _, _, h => by simp at h
  | x :: xs, 0, a, h => by
    simp only [List.getElem?_cons_zero, Option.some.injEq] at h
    simp [h]
  | x :: xs, n + 1, a, h => by
    simp only [List.getElem?_cons_succ] at h
    exact List.mem_cons_of_mem _ (mem_of_getElem?_some h)

/-- Up to an index `k` where every instruction is an `arg`, the leading run is the list. -/
theorem leadRun_getElem? : ∀ (l : List Proto) (k : Nat),
    (∀ i (hi : i < l.length), i ≤ k → l[i].op = .arg) → ∀ i, i ≤ k → (leadRun l)[i]? = l[i]?
  | [], _, _, i, _ => by simp [leadRun]
  | q :: qs, k, h, i, hi => by
    have hq : q.op = .arg := h 0 (by simp) (Nat.zero_le _)
    have e : leadRun (q :: qs) = q :: leadRun qs := by simp [leadRun, hq]
    rw [e]
    cases i with
    | zero => simp
    | succ i =>
      cases k with
      | zero => omega
      | succ k =>
        simp only [List.getElem?_cons_succ]
        exact leadRun_getElem? qs k
          (fun j hj hjk => h (j + 1) (by simp only [List.length_cons]; omega) (by omega))
          i (by omega)

/-- `regsDistinct`: no value at two indices. -/
theorem regsDistinct_spec : ∀ {l : List (Option (Bool × Nat))} {j k : Nat}
    {a : Option (Bool × Nat)},
    regsDistinct l = true → j < k → l[j]? = some a → l[k]? = some a → False
  | [], _, _, _, _, _, hj, _ => by simp at hj
  | x :: xs, j, k, a, h, hjk, hj, hk => by
    simp only [regsDistinct, Bool.and_eq_true] at h
    cases j with
    | zero =>
      cases k with
      | zero => omega
      | succ k =>
        simp only [List.getElem?_cons_zero, Option.some.injEq] at hj
        simp only [List.getElem?_cons_succ] at hk
        subst hj
        have := List.all_eq_true.1 h.1 _ (mem_of_getElem?_some hk)
        simp at this
    | succ j =>
      cases k with
      | zero => omega
      | succ k =>
        simp only [List.getElem?_cons_succ] at hj hk
        exact regsDistinct_spec h.2 (by omega) hj hk

end Ryo.Vm
