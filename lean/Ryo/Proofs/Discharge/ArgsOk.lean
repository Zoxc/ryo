/-
Ryo.Proofs.Discharge.ArgsOk — what the decoder's acceptance gives of `ArgsOk` (the leading
`arg`s).

- `argsOk_proto`: a proto of the leading run whose op is `arg` was read by `argInsn` (an inline
  sequence, a call, a handler call, a dense switch, `ret`, `jmp`, … is never an `arg`), so its
  operands are `[.slot d, .imm (word a)]` with `ArgReg.of?` giving back `a`, below 4 on PE.
- `argsOk_conv`: every leading `arg` reads a convention register, from that and `isArg_of`.
- `ArgsOk`'s other fields, `distinct` and `untargeted`, stay `Hyps` fields: the decoder does not
  check them.

The inline case uses `InlineOk` of the inline opcodes (`Hyps.inlineOk`, a closed fact,
`inlineOps_ok`), passed as `hInl`, as `DSWork/Arg.lean`'s `arg_inline_ne` does.

**Not checked by the decoder** (neither in `DecodeReduced.lean`'s `argInsn`/`instructions` nor
in Rust's `vm/bytecode/src/asm/decode.rs`, `arg` and the `protos.iter().all(|p| p.op ==
Opcode::Arg)` attempt in the instruction loop):
- `distinct`: `argInsn` accepts any convention register; nothing compares it with the leading
  `arg`s before it, so two `arg`s may read the same register.
- `untargeted`: no check that a branch target (`Proto.targets`, the sorted `targets` of the first
  pass) is not the position of a leading `arg` (e.g. a `jmp` back to the body's first
  instruction when it is an `arg`).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.ArgPeBound

set_option linter.constructorNameAsVariable false
set_option linter.unusedSimpArgs false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.DecodeLink

section

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

set_option maxRecDepth 100000 in
theorem argsOk_beq_call : (Full.Opcode.arg == Full.Opcode.call) = false := by decide
set_option maxRecDepth 100000 in
theorem argsOk_beq_callSym : (Full.Opcode.arg == Full.Opcode.callSym) = false := by decide
set_option maxRecDepth 100000 in
theorem argsOk_beq_callSymInd : (Full.Opcode.arg == Full.Opcode.callSymInd) = false := by decide
set_option maxRecDepth 100000 in
theorem argsOk_beq_callPtr : (Full.Opcode.arg == Full.Opcode.callPtr) = false := by decide
set_option maxRecDepth 100000 in
theorem argsOk_beq_tailCall : (Full.Opcode.arg == Full.Opcode.tailCall) = false := by decide
set_option maxRecDepth 100000 in
theorem argsOk_beq_tailCallPtr : (Full.Opcode.arg == Full.Opcode.tailCallPtr) = false := by
  decide
set_option maxRecDepth 100000 in
theorem argsOk_arg_noHandler : Full.Opcode.arg.hasHandler = false := by decide
set_option maxRecDepth 100000 in
theorem argsOk_arg_shape : Full.Opcode.arg.info.shape = .arg := by decide
set_option maxRecDepth 100000 in
theorem argsOk_dense_ne (w : W) : denseOp w ≠ Full.Opcode.arg := by cases w <;> decide

theorem argsOk_callHead {fo : R.Opnd Nat} {r : List Item × Item}
    (h : Call.callHead .arg fo = some r) : False := by
  cases fo <;> simp [Call.callHead, argsOk_beq_call, argsOk_beq_callSym, argsOk_beq_callSymInd,
    argsOk_beq_callPtr] at h

theorem argsOk_tailHead {w : Bool} {fo : R.Opnd Nat} {r : List Item × Item}
    (h : Call.tailHead w .arg fo = some r) : False := by
  cases fo <;> simp [Call.tailHead, argsOk_beq_tailCall, argsOk_beq_tailCallPtr] at h

set_option maxRecDepth 100000 in
/-- An inline sequence isn't an `arg` (`arg_inline_ne` with `InlineOk` as a hypothesis). -/
theorem argsOk_inline_ne (hInl : ∀ f cls, (f, cls) ∈ inlineOps → Step.InlineOk f cls)
    {cache cache' : Cache} {dr dr' : List DroppedStore} {c c' : Cursor} {q : Proto}
    (h : (inlineInsn cache dr true).run c = .ok (some (q, cache', dr'), c')) :
    q.op ≠ .arg := by
  intro hq
  obtain ⟨-, -, cand, br, out, hd, -⟩ := inlineInsn_read_drop h
  obtain ⟨cls, hm, -⟩ := decodeInline_spec hd
  rw [hq] at hm
  have h1 := (hInl _ _ hm).opShape
  have h2 : R.opShape .arg = false := by unfold R.opShape; rw [argsOk_arg_shape]
  rw [h2] at h1
  cases h1

/-- A call isn't an `arg`. -/
theorem argsOk_call_ne {fr : Vm.Frame} {dr : List DroppedStore} {c c' : Cursor} {q : Proto}
    (h : (callInsn fr dr).run c = .ok (some q, c')) : q.op ≠ .arg := by
  intro hq
  cases callInsn_read h with
  | call hh =>
    dsimp only [callProto] at hq
    subst hq
    exact argsOk_callHead hh
  | tail hh =>
    dsimp only at hq
    subst hq
    exact argsOk_tailHead hh

/-- `insn` never reads an `arg`. -/
theorem argsOk_insn_ne {fr : Vm.Frame} {ro : ByteArray} {c c' : Cursor} {q : Proto}
    (h : (insn fr ro).run c = .ok (q, c')) : q.op ≠ .arg := by
  intro hq
  unfold insn at h
  obtain ⟨r, c1, h1, h2⟩ := bind_ok h
  cases r with
  | some p =>
    obtain ⟨rfl, rfl⟩ := pure_ok h2
    obtain ⟨w, hw, -⟩ := denseSwitch_some h1
    exact argsOk_dense_ne w (hw.symm.trans hq)
  | none =>
    cases insnCore_read h2 with
    | handler _ _ _ hh =>
      dsimp only at hq
      subst hq
      rw [argsOk_arg_noHandler] at hh
      cases hh
    | ret _ => first | cases hq | simp at hq
    | unreachable _ => first | cases hq | simp at hq
    | jmp _ => first | cases hq | simp at hq
    | island _ _ => first | cases hq | simp at hq
    | resume _ _ _ => first | cases hq | simp at hq
    | dense hd =>
      obtain ⟨w, hw, -⟩ := denseSwitch_some hd
      exact argsOk_dense_ne w (hw.symm.trans hq)

/-- A proto whose op is `arg` was read by `argInsn`: its operands are the slot and the word of
a register `ArgReg.of?` gives back, below 4 on PE. -/
theorem argsOk_proto (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hInl : ∀ f cls, (f, cls) ∈ inlineOps → Step.InlineOk f cls)
    {j : Nat} (hj : j < S.r.protos.toList.length) (hop : S.r.protos.toList[j].op = .arg) :
    ∃ (a : ArgReg) (d : BitVec 32),
      S.r.protos.toList[j].ops = [.slot d, .imm (BitVec.ofNat 64 a.word)] ∧
      S.r.protos.toList[j].handler = none ∧
      ArgReg.of? (BitVec.ofNat 64 a.word).toNat true = some a ∧ (S.c.mode.pe → a.index < 4) := by
  have it := hD.iters j hj
  generalize S.r.protos.toList[j] = pr at hop it ⊢
  generalize S.cache (j + 1) = c1 at it
  generalize S.cache j = c0 at it
  generalize S.args j = a0 at it
  generalize S.start j = s0 at it
  generalize S.start (j + 1) = s1 at it
  generalize S.dr j = d0 at it
  generalize S.dr (j + 1) = d1 at it
  cases it with
  | empty _ hin =>
    exact absurd (by simpa using hop) (argsOk_inline_ne hInl hin)
  | @main _ _ _ _ _ _ _ _ q _ _ _ hpr _ =>
    have hq : q.op = .arg := hop
    cases hpr with
    | arg h =>
      obtain ⟨a, d, hq, hs, hi, hofs, -, -, hpe⟩ := argInsn_bounds h
      subst hq
      have hw : (BitVec.ofNat 64 a.word).toNat = a.word := by
        rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by have := word_lt a; omega)
      obtain ⟨b, hb⟩ := Option.isSome_iff_exists.mp hofs
      refine ⟨a, d, rfl, rfl, ?_, hpe⟩
      rw [hw, hb, of_word_eq hs hi hb]
    | call _ h => exact (argsOk_call_ne h hq).elim
    | inline _ _ hin =>
      have hin' : (inlineInsn _ _ true).run _ = .ok (some (q, _, _), _) := hin
      exact (argsOk_inline_ne hInl hin' hq).elim
    | insn _ _ _ h => exact (argsOk_insn_ne h hq).elim

/-- A leading `arg` reads an argument register of the convention. -/
theorem argsOk_conv (hD : Decodes S code relocs rodata callSites dropped scopes mode)
    (hInl : ∀ f cls, (f, cls) ∈ inlineOps → Step.InlineOk f cls) :
    ∀ j r, LeadArg S j → ArgRegAt S j r → ArgRet.IsArg S.c.mode.pe r := by
  rintro j r ⟨hj, ha⟩ ⟨op, d, w, f, a, hi, -, -, hof, rfl⟩
  have hjl : j < S.r.protos.toList.length := by simpa using hj
  rw [hD.argsSucc j hjl, Bool.and_eq_true] at ha
  have hop : S.r.protos.toList[j].op = .arg := by simpa using ha.2
  obtain ⟨a', d', hops, hh, hof', hpe⟩ := argsOk_proto hD hInl hjl hop
  have e : S.r.protos.toList[j] = S.r.protos[j] := by simp
  rw [e] at hops hh
  obtain ⟨hk', hij⟩ := Array.getElem?_eq_some_iff.mp hi
  have hio := (reducedOf_insns hD.reduced).2 j hj hk'
  rw [hij] at hio
  simp only [InsnOf, hh] at hio
  obtain ⟨op', ops', -, he, hm⟩ := hio
  cases he
  rw [hops] at hm
  simp only [List.map_cons, List.map_nil, opndMap, List.cons.injEq, Opnd.slot.injEq,
    Opnd.imm.injEq, and_true] at hm
  rw [hm.2, hof'] at hof
  cases hof
  exact isArg_of hof' hpe

end

end Ryo.Proofs.DecodeSound
