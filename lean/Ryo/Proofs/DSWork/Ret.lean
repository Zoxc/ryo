import Ryo.Proofs.DecodeSound
import Ryo.Proofs.NoArgCursor

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.DecodeSound

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Vm.R
open Ryo.Proofs.Inline Ryo.Proofs.Scope Ryo.Proofs.ScopeMem Ryo.Proofs.RegCache
open Ryo.Proofs.DecodeLink Ryo.Proofs.FrameBounds Ryo.Proofs.CacheMem
open Ryo.Proofs.Counter (CalleeSaved InStack TripContract)
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Call (WorldRel Saved EntryAt CallContract)
open Ryo.Proofs.Island (IslandContract)

section Insn

variable {S : Setup} {code : ByteArray} {relocs : Array Reloc} {rodata : ByteArray}
  {callSites : Array CallSite} {dropped : Array DroppedStore} {scopes : Array R.Scope}
  {mode : Ryo.Obj.Mode}

/-! #### `ret`'s items: canonical, falling through, memory kept -/

theorem ret_canon_of {i : Item} (hw : ∀ p, i.wf p = true) (ht : ∀ b e, i ≠ .tableEntry b e)
    (pos : Nat) : i.Canonical pos := ⟨ht, .inl (hw _)⟩

theorem ret_canon_list : ∀ {L : List Item}, (∀ i ∈ L, ∀ pos, i.Canonical pos) → ∀ pos, Canon L pos
  | [], _, _ => trivial
  | i :: L, h, pos => ⟨h i (by simp) pos, ret_canon_list (fun j hj => h j (by simp [hj])) _⟩

theorem ret_epilogue_canon (F : Nat) (m : Ryo.Obj.Mode) :
    ∀ i ∈ epilogue F m, ∀ pos, i.Canonical pos := by
  unfold epilogue
  split
  · intro i hi
    simp only [winEpilogue, List.mem_cons, List.not_mem_nil, or_false] at hi
    rcases hi with rfl | rfl | rfl | rfl <;>
      exact ret_canon_of (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h)
  · split
    · intro i hi; simp only [List.mem_singleton] at hi; subst hi
      exact ret_canon_of (fun _ => rfl) (fun _ _ h => by cases h)
    · intro i hi; simp only [List.mem_singleton] at hi; subst hi
      exact ret_canon_of (fun _ => rfl) (fun _ _ h => by cases h)

/-- The items of `ret`'s sequence before the final `ret`, by shape. -/
def RetShape (i : Item) : Prop :=
  (∃ w sx d m, i = .ld w sx d m) ∨ (∃ t x r, i = .movd t x r) ∨ (∃ sz x m, i = .sse false sz x m) ∨
    i = .leave ∨ i = .leaRspRbp16 ∨ (∃ r, i = .pop r) ∨ (∃ v, i = .addRsp v)

theorem ret_shape_ok (ctx : Ctx) {i : Item} (h : RetShape i) : i.FallsThrough ctx ∧ i.MemKept ctx := by
  rcases h with ⟨w, sx, d, m, rfl⟩ | ⟨t, x, r, rfl⟩ | ⟨sz, x, m, rfl⟩ | rfl | rfl | ⟨r, rfl⟩ | ⟨v, rfl⟩
  · constructor <;> intro s s' he <;> simp only [Item.exec] at he <;> split at he <;>
      (cases Switch.except_ok_inj he; rfl)
  · constructor <;> intro s s' he <;> simp only [Item.exec] at he <;> split at he <;>
      (cases Switch.except_ok_inj he; rfl)
  · constructor <;> intro s s' he <;> simp only [Item.exec] at he <;> split at he
    all_goals first
      | (cases he; done)
      | (simp at he; done)
      | (simp only [Bool.false_eq_true, ↓reduceIte] at he; cases Switch.except_ok_inj he; rfl)
  all_goals (constructor <;> intro s s' he <;> simp only [Item.exec] at he <;>
    (cases Switch.except_ok_inj he; rfl))

theorem ret_epilogue_shape (F : Nat) (m : Ryo.Obj.Mode) : ∀ i ∈ epilogue F m, RetShape i := by
  unfold epilogue
  split
  · intro i hi
    simp only [winEpilogue, List.mem_cons, List.not_mem_nil, or_false] at hi
    rcases hi with rfl | rfl | rfl | rfl
    · exact .inr (.inr (.inr (.inr (.inl rfl))))
    all_goals exact .inr (.inr (.inr (.inr (.inr (.inl ⟨_, rfl⟩)))))
  · split
    · intro i hi; simp only [List.mem_singleton] at hi; subst hi
      exact .inr (.inr (.inr (.inl rfl)))
    · intro i hi; simp only [List.mem_singleton] at hi; subst hi
      exact .inr (.inr (.inr (.inr (.inr (.inr ⟨_, rfl⟩)))))

theorem ret_loads_ok {k : Nat} {parts : List (RetPart × R.Reg)}
    (hp : R.retRegs k true = .ok parts) (src : BitVec 32) :
    ∀ i ∈ retLoads k src, RetShape i ∧ ∀ pos, i.Canonical pos := by
  obtain ⟨he, hq⟩ := ArgRet.retRegs_parts hp src
  rw [he]
  intro i hi
  simp only [List.mem_flatMap] at hi
  obtain ⟨⟨pt, r⟩, hqm, hi⟩ := hi
  obtain ⟨hok, hrf, -⟩ := hq _ hqm
  unfold ArgRet.RegFor at hrf
  unfold ArgRet.partOk at hok
  simp only [ArgRet.loadR, ArgRet.loadItems] at hi
  rcases hrf with ⟨hx, hr | hr⟩ | ⟨hx, hr | hr⟩ <;> subst hr <;> simp only at hx
  · simp [hx, ArgRet.retX86] at hi
    subst hi
    exact ⟨.inl ⟨_, _, _, _, rfl⟩, ret_canon_of (fun _ => by simp [Item.wf, Item.memWf, frameAt, M.frame, Reg.usable]) (fun _ _ h => by cases h)⟩
  · simp [hx, ArgRet.retX86] at hi
    subst hi
    exact ⟨.inl ⟨_, _, _, _, rfl⟩, ret_canon_of (fun _ => by simp [Item.wf, Item.memWf, frameAt, M.frame, Reg.usable]) (fun _ _ h => by cases h)⟩
  all_goals
    simp only [hx, ↓reduceIte] at hok
    by_cases h2 : pt.size = 2
    · simp [hx, h2, ArgRet.retXmm] at hi
      rcases hi with rfl | rfl
      · exact ⟨.inl ⟨_, _, _, _, rfl⟩, ret_canon_of (fun _ => by simp [Item.wf, Item.memWf, frameAt, M.frame, Reg.usable]) (fun _ _ h => by cases h)⟩
      · exact ⟨.inr (.inl ⟨_, _, _, rfl⟩), ret_canon_of (fun _ => by simp [Item.wf, Reg.usable]) (fun _ _ h => by cases h)⟩
    · simp [hx, h2, ArgRet.retXmm] at hi
      subst hi
      refine ⟨.inr (.inr (.inl ⟨_, _, _, rfl⟩)), ret_canon_of (fun _ => ?_) (fun _ _ h => by cases h)⟩
      simp only [Item.wf, frameAt, M.frame]
      rcases hok with h | h | h | h <;> simp [h] at h2 ⊢

set_option maxRecDepth 100000 in
theorem ret_ofFull {op : Reduced.Opcode}
    (h : Reduced.Opcode.ofFull .ret = some op) : op.full = some .ret := by
  have e : (Reduced.Opcode.ofFull .ret).bind Reduced.Opcode.full = some .ret := by rfl
  rw [h] at e; exact e

theorem ret_retRegs_noNB (k : Nat) (load : Bool) : NoNB (R.retRegs k load) := by
  unfold R.retRegs
  split
  · exact noNB_pure _
  · exact noNB_ill _

/-- `ret`'s R step never stops with `noBehavior`. -/
theorem ret_step_noNB {c : R.Code} {s : R.RState} {op : Reduced.Opcode} {src : BitVec 32}
    {k : BitVec 64} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot src, .imm k])) (hf : op.full = some f)
    (hsh : f.info.shape = .ret) (m : String) : R.step c s {} ≠ .error (.noBehavior m) := by
  intro he
  unfold R.step at he
  simp only [hi, bind, Except.bind] at he
  cases hsc : (c.scopesAt s.pc).foldlM R.applyScope s with
  | error e' => simp only [hsc] at he; cases he; exact noNB_scopes _ _ m hsc
  | ok s1 =>
    simp only [hsc, hf, hsh] at he
    cases hp : R.retRegs k.toNat true with
    | error e' => simp only [hp] at he; cases he; exact ret_retRegs_noNB _ _ m hp
    | ok parts =>
      simp only [hp] at he
      split at he
      · rename_i e' hg
        cases he
        exact noNB_foldlM _ (fun b pr => by
          obtain ⟨p, r⟩ := pr
          exact noNB_bind (noNB_readFrame _ _ _) fun _ _ => noNB_pure _) _ _ m hg
      · split at he
        · rename_i e' hin
          cases he
          exact noNB_readFrame _ _ _ m hin
        · cases he

set_option maxRecDepth 100000 in
/-- `bodySim_ret`. Proof idea: `noArg_insn`; `InsnRead.ret` and `link_ret` give
`retLoads k src ++ epilogue F mode ++ [ret]` in memory at `p` (canonical: `call_epilogue_canon`
as in `DSWork/Call.lean`), fetched as `Steps`; `ArgRet.ret_step` (`FrameBounds.ret_step_fb_disp`,
`H.fp`) gives `.done (exit s1 (.ret regs incoming))` with `RetRel`; `ExitRel`: `WorldRel` from
`MemRel`, `rip` the return address and `rsp = x0.rsp + 8` and the callee-saved registers from
`FrameFacts` (`retAddr`, `rbp`, `savedRbp`, `savedPe`, `saved`), the incoming area from
`Rel` over `[16, 16 + argSize)` (`H.argSizeK`, in the window). R's step is safe: no error but
`noBehavior` (`RSafe`), the scopes never stop so (`noNB_scopes`). -/
theorem bodySim_ret' (_hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' {}) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .ret) :
    BodySim S k p (S.used k) := by
  intro s x hs hf hrip _ hsafe
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, -⟩ := protoFacts_insnOf hP
  have hb := hP.bound
  cases hr with
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | jmp => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | @ret src kk c'' hret =>
    obtain ⟨hd, -, hk32⟩ := retSeq_read hret
    have hd' := Dec.at_iff.mp hd
    obtain ⟨hca, -, -⟩ := hf.code.dec hd' hb
    simp only [InsnOf] at hio
    obtain ⟨op, ops, hof, rfl, hops⟩ := hio
    have hops' := opnds_plain hops (by simp [Opnd.targetsOf])
    subst hops'
    have hf' := ret_ofFull hof
    have hsh : Full.Opcode.ret.info.shape = .ret := by decide
    have hkk : (BitVec.ofNat 64 kk).toNat = kk := by
      rw [BitVec.toNat_ofNat]; exact Nat.mod_eq_of_lt (by omega)
    rw [← hs] at hi
    cases hst : R.step S.c s {} with
    | error e =>
      exfalso
      obtain ⟨m, rfl⟩ := hsafe.1 {} e hst
      exact ret_step_noNB hi hf' hsh m hst
    | ok o =>
      obtain ⟨s0, parts, regs0, inc0, hsc0, hp, -, -, ho⟩ := ArgRet.step_ret hi hf' hsh hst
      subst ho
      rw [hkk] at hp
      obtain ⟨s1, regs, incoming, x', -, -, -, hfin, -, hbytes, hex, hret, hmem, hrsp, hrip', hrbp,
          -, hpe, -, hregs⟩ :=
        ArgRet.ret_step S.ctx S.r.frameSize hf.rrel hi hf' hsh
          (ret_step_fb_disp H.frameBounds hi hf' hsh) (fun _ h2 => absurd H.fp (by simp [h2])) hst
      rw [hkk] at hex
      have hm0 := (memRel_foldlM _ (H.frameBounds.scope_size _) hf.rrel hf.mem hsc0).2
      have hm0' : MemRel s0.st x' := by unfold MemRel; rw [hmem]; exact hm0
      have hw : WorldRel (R.exit s0 (.ret regs0 inc0)).world x' := Ryo.Proofs.Call.worldRel_exit _ hm0'
      rw [hfin] at hw hst
      have hl := ret_loads_ok hp src
      have hsteps : Steps S.ctx x x' := by
        refine steps_of_run_last (S := fun _ => True)
          (items := retLoads kk src ++ epilogue S.r.frameSize S.c.mode) (j := .ret) ?_ ?_ hrip
          (fun _ _ => trivial) ?_ ?_
        · rw [List.append_assoc]
          refine ret_canon_list (fun i hi => ?_) p
          rcases List.mem_append.mp hi with hi | hi
          · exact (hl i hi).2
          · rcases List.mem_append.mp hi with hi | hi
            · exact ret_epilogue_canon _ _ i hi
            · simp only [List.mem_singleton] at hi; subst hi
              exact ret_canon_of (fun _ => rfl) (fun _ _ h => by cases h)
        · rw [List.append_assoc]; exact hca
        · refine fetchRun_of_forall (fun i hi => ret_shape_ok S.ctx ?_) x
          rcases List.mem_append.mp hi with hi | hi
          · exact (hl i hi).1
          · exact ret_epilogue_shape _ _ i hi
        · rw [List.append_assoc]; exact hex
      refine Reach.steps hsteps (.done (.inr ⟨_, .step hst, hw, ?_⟩))
      have hbr := hf.frame
      have e16 : fpAddr x 16 = S.x0.rsp + 8 := by
        rw [hf.fpAddr_eq 16]
        unfold Setup.winAddr
        rw [show BitVec.ofInt 64 16 = 16 from rfl]
        bv_omega
      refine ⟨hret, ?_, ?_, ?_, ?_⟩
      · rw [hrip', hbr.retAddr]
      · rw [hrsp, hbr.rbp]
      · intro i hsv
        rcases hsv with hcs | ⟨hpe', h67⟩
        · by_cases h5 : i = 5
          · subst h5
            exact (hrbp (.inr H.fp)).trans hbr.savedRbp
          · have hne : i ≠ 0 ∧ i ≠ 2 ∧ i ≠ 11 ∧ i ≠ 4 ∧ i ≠ 6 ∧ i ≠ 7 := by
              unfold CalleeSaved at hcs
              rcases hcs with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
            rw [hregs i hne.1 hne.2.1 hne.2.2.1 hne.2.2.2.1 h5 hne.2.2.2.2.1 hne.2.2.2.2.2]
            exact hbr.saved i hcs h5
        · obtain ⟨a1, a2⟩ := hpe hpe'
          obtain ⟨b1, b2⟩ := hbr.savedPe hpe'
          rcases h67 with rfl | rfl
          · exact a1.trans b1
          · exact a2.trans b2
      · rw [hmem, ← e16]
        exact hbytes (by have := H.argSizeK; have := H.frameBounds.K_le; omega)

end Insn

end Ryo.Proofs.DecodeSound
