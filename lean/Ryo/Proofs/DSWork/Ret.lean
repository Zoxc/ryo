import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.Discharge.SpDisp
import Ryo.Proofs.DecodeSound.NoFp
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

theorem ret_epilogue_mem {F : Nat} {m : Ryo.Obj.Mode} {i : Item} (h : i ∈ epilogue F m) :
    i = .leave ∨ i = .popRbp ∨ ∃ v, i = .addRsp v := by
  cases hpe : m.pe <;> cases hfp : m.framePointer <;> by_cases hF : F = 0 <;>
    simp [epilogue, hpe, hfp, hF] at h <;>
    first | (subst h; simp) | (rcases h with rfl | rfl <;> simp)

theorem ret_epilogue_canon (F : Nat) (m : Ryo.Obj.Mode) :
    ∀ i ∈ epilogue F m, ∀ pos, i.Canonical pos := by
  intro i hi
  rcases ret_epilogue_mem hi with rfl | rfl | ⟨v, rfl⟩ <;>
    exact ret_canon_of (fun _ => by simp [Item.wf]) (fun _ _ h => by cases h)

/-- The items of `ret`'s sequence before the final `ret`, by shape. -/
def RetShape (i : Item) : Prop :=
  (∃ w sx d m, i = .ld w sx d m) ∨ (∃ t x r, i = .movd t x r) ∨ (∃ sz x m, i = .sse false sz x m) ∨
    i = .leave ∨ i = .popRbp ∨ (∃ v, i = .addRsp v)

theorem ret_shape_ok (ctx : Ctx) {i : Item} (h : RetShape i) : i.FallsThrough ctx ∧ i.MemKept ctx := by
  rcases h with ⟨w, sx, d, m, rfl⟩ | ⟨t, x, r, rfl⟩ | ⟨sz, x, m, rfl⟩ | rfl | rfl | ⟨v, rfl⟩
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
  intro i hi
  rcases ret_epilogue_mem hi with rfl | rfl | ⟨v, rfl⟩
  · exact .inr (.inr (.inr (.inl rfl)))
  · exact .inr (.inr (.inr (.inr (.inl rfl))))
  · exact .inr (.inr (.inr (.inr (.inr ⟨_, rfl⟩))))

theorem ret_shape_ripFree (ctx : Ctx) {i : Item} (h : RetShape i) : i.RipFree ctx := by
  rcases h with ⟨w, sx, d, m, rfl⟩ | ⟨t, x, r, rfl⟩ | ⟨sz, x, m, rfl⟩ | rfl | rfl | ⟨v, rfl⟩ <;>
    intro s a
  · cases w <;> rfl
  · cases t <;> rfl
  · simp only [Item.exec]; split <;> rfl
  · rfl
  · rfl
  · rfl

theorem RetShape.ne_table {i : Item} (h : RetShape i) : ∀ b e, i ≠ .tableEntry b e := by
  rcases h with ⟨_, _, _, _, rfl⟩ | ⟨_, _, _, rfl⟩ | ⟨_, _, _, rfl⟩ | rfl | rfl | ⟨_, rfl⟩ <;>
    intro b e h <;> cases h

/-- A `RetShape` item but `leave`/`pop rbp` uses `rbp` only as a memory base. -/
theorem retShape_rbpFree {i : Item} (hs : RetShape i) (hw : ∀ p, i.wf p = true)
    (hl : i ≠ .leave) (hp : i ≠ .popRbp) : i.RbpFree := by
  rcases hs with ⟨w, sx, d, m, rfl⟩ | ⟨t, x, r, rfl⟩ | ⟨sz, x, m, rfl⟩ | rfl | rfl | ⟨v, rfl⟩
  · exact hw 0
  · exact hw 0
  · exact hw 0
  · exact absurd rfl hl
  · exact absurd rfl hp
  · exact rfl

/-- A `RetShape` item in memory (either frame form) is one too. -/
theorem retShape_fb {fb : FForm} {i : Item} (h : RetShape i) : RetShape (FForm.item fb i) := by
  cases fb with
  | none => exact h
  | some F =>
    rcases h with ⟨w, sx, d, m, rfl⟩ | ⟨t, x, r, rfl⟩ | ⟨sz, x, m, rfl⟩ | rfl | rfl | ⟨v, rfl⟩
    · exact .inl ⟨w, sx, d, _, rfl⟩
    · exact .inr (.inl ⟨t, x, r, rfl⟩)
    · exact .inr (.inr (.inl ⟨sz, x, _, rfl⟩))
    · exact .inr (.inr (.inr (.inl rfl)))
    · exact .inr (.inr (.inr (.inr (.inl rfl))))
    · exact .inr (.inr (.inr (.inr (.inr ⟨v, rfl⟩))))

/-- `RetShape` items encodable at every position are canonical in memory (either frame form:
the `spFrame` disjunct of `Item.Canonical`). -/
theorem ret_canon_map {fb : FForm} : ∀ {L : List Item},
    (∀ i ∈ L, RetShape i ∧ ∀ p, i.wf p = true) → ∀ pos, Canon (L.map (FForm.item fb)) pos
  | [], _, _ => trivial
  | i :: L, h, pos => by
    rw [List.map_cons]
    have hi := h i (by simp)
    refine ⟨?_, ret_canon_map (fun j hj => h j (by simp [hj])) _⟩
    cases fb with
    | none => exact ⟨hi.1.ne_table, .inl (hi.2 _)⟩
    | some F => exact ⟨(retShape_fb (fb := some F) hi.1).ne_table, .inr ⟨i, F, hi.2 _, rfl⟩⟩

theorem rspKept_ld {ctx : Ctx} {w : Ryo.X86.W} {r : X86.Reg} {m : Ryo.X86.M}
    (h : (4 : Fin 16) ≠ r.idx) :
    (Item.ld w false r m).RspKept ctx := by
  intro y y' he
  obtain ⟨y'', he', -, -, hg, -, -⟩ := ArgRet.exec_ld ctx w r m y
  rw [he] at he'
  cases he'
  exact hg 4 h

theorem rspKept_movd_to {ctx : Ctx} {x : Nat} {r : X86.Reg} : (Item.movd true x r).RspKept ctx := by
  intro y y' he
  obtain ⟨y'', he', -, -, -, hg, -⟩ := ArgRet.exec_movd_to ctx x r y
  rw [he] at he'
  cases he'
  exact congrFun hg 4

theorem rspKept_sse_ld {ctx : Ctx} {size x : Nat} {m : Ryo.X86.M}
    (hs : size = 4 ∨ size = 8 ∨ size = 16) :
    (Item.sse false size x m).RspKept ctx := by
  intro y y' he
  obtain ⟨y'', he', -, -, -, hg, -⟩ := ArgRet.exec_sse_ld ctx size x m y hs
  rw [he] at he'
  cases he'
  exact congrFun hg 4

theorem load_facts {i : Item} (hs : RetShape i) (hw : ∀ p, i.wf p = true) (hl : i ≠ .leave)
    (hp : i ≠ .popRbp) (hk : ∀ ctx, i.RspKept ctx) :
    RetShape i ∧ (∀ pos, i.Canonical pos) ∧ (∀ p, i.wf p = true) ∧ i.RbpFree ∧
      ∀ ctx, i.RspKept ctx :=
  ⟨hs, ret_canon_of hw hs.ne_table, hw, retShape_rbpFree hs hw hl hp, hk⟩

theorem ret_loads_ok {k : Nat} {parts : List (RetPart × R.Reg)}
    (hp : R.retRegs k true = .ok parts) (src : BitVec 32) :
    ∀ i ∈ retLoads k src, RetShape i ∧ (∀ pos, i.Canonical pos) ∧ (∀ p, i.wf p = true) ∧
      i.RbpFree ∧ ∀ ctx, i.RspKept ctx := by
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
    exact load_facts (.inl ⟨_, _, _, _, rfl⟩)
      (fun _ => by simp [Item.wf, Item.memWf, frameAt, M.frame, Reg.usable])
      (by intro h; cases h) (by intro h; cases h) (fun _ => rspKept_ld (by decide))
  · simp [hx, ArgRet.retX86] at hi
    subst hi
    exact load_facts (.inl ⟨_, _, _, _, rfl⟩)
      (fun _ => by simp [Item.wf, Item.memWf, frameAt, M.frame, Reg.usable])
      (by intro h; cases h) (by intro h; cases h) (fun _ => rspKept_ld (by decide))
  all_goals
    simp only [hx, ↓reduceIte] at hok
    by_cases h2 : pt.size = 2
    · simp [hx, h2, ArgRet.retXmm] at hi
      rcases hi with rfl | rfl
      · exact load_facts (.inl ⟨_, _, _, _, rfl⟩)
          (fun _ => by simp [Item.wf, Item.memWf, frameAt, M.frame, Reg.usable])
          (by intro h; cases h) (by intro h; cases h) (fun _ => rspKept_ld (by decide))
      · exact load_facts (.inr (.inl ⟨_, _, _, rfl⟩)) (fun _ => by simp [Item.wf, Reg.usable])
          (by intro h; cases h) (by intro h; cases h) (fun _ => rspKept_movd_to)
    · simp [hx, h2, ArgRet.retXmm] at hi
      subst hi
      refine load_facts (.inr (.inr (.inl ⟨_, _, _, rfl⟩))) (fun _ => ?_)
        (by intro h; cases h) (by intro h; cases h) (fun _ => rspKept_sse_ld (by omega))
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
/-- `bodySim_ret`, in both frame forms. Proof: `noArg_insn`; `InsnRead.ret` and `LinkOkF.dec`
give `retLoads k src ++ epilogue F mode ++ [ret]` in memory at `p` in the body's frame form.
`ArgRet.ret_step` runs on the virtual state the loads run from (`FForm.virtAt`; `RRel` and
`FrameInv.rsp` carry over, `rip` aside; `F + 8 < 2 ^ 31` on PE from `H.peFrame`, without a frame
pointer from `nf_frame8`) and gives `.done (exit s1 (.ret regs incoming))` with `RetRel`. The
machine fetches the loads by `steps_of_run_fb` (each load canonical in either form,
`ret_canon_map`, keeps `rsp`, `rspKept_*`, and its frame operand doesn't wrap, `H.spDisp`), then
the epilogue and `ret`: with a frame pointer on the real (= virtual) state by `steps_of_run_last`;
without one the epilogue is `add rsp, F + 8` (not PE, `nf_pe_of_nofp`), which with `ret` has no
memory operand and doesn't touch `rbp`, so it runs on the real state, the virtual run's with the
real `rbp` (`nf_execItems_commute`). `ExitRel` on that real state: `WorldRel` from `MemRel`, `rip`
the return address and `rsp = x0.rsp + 8` and the callee-saved registers from `FrameFacts` of the
virtual state (`retAddr`, `rbp`, `saved`; `rbp` itself: with a frame pointer the saved one,
`savedRbp`, without one the entry's, `RbpOk`), the incoming area from `Rel` over
`[16, 16 + argSize)` (`H.argSizeK`, in the window). R's step is safe: no error but `noBehavior`
(`RSafe`), the scopes never stop so (`noNB_scopes`). -/
theorem bodySim_retB (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .ret) :
    BodySimBE S k p := by
  have hF8 : S.c.mode.pe = true → S.F + 8 < 2 ^ 31 := H.peFrame
  intro s x hs hfr hrip _ hsafe
  obtain ⟨hf, hrb⟩ := hfr
  have hcur := noArg_insn hn hr
  subst hcur
  obtain ⟨i, p1, ctr, hi, hio, -⟩ := protoFacts_insnOf hP
  have hb := hP.bound
  cases hr with
  | handler _ _ _ hhh =>
    simp only at hop; subst hop
    simp [noHandler] at hhh
  | jmp => simp only at hop; exact absurd hop (by decide)
  | dense hd =>
    obtain ⟨w, hw, -⟩ := denseSwitch_some hd
    rw [hw] at hop; cases w <;> exact absurd hop (by decide)
  | resume => simp only at hop; exact absurd hop (by decide)
  | unreachable => simp only at hop; exact absurd hop (by decide)
  | island => simp only at hop; exact absurd hop (by decide)
  | @ret src kk c'' hret =>
    obtain ⟨hd, -, hk32⟩ := retSeq_read hret
    have hd' := Dec.at_iff.mp hd
    obtain ⟨hca, -, -⟩ := hf.code.dec hd' hb
    rw [show S.fr.epilogue = epilogue S.r.frameSize S.c.mode from rfl] at hca hd'
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
      have hl := ret_loads_ok hp src
      have eF : S.F = S.r.frameSize := reducedOf_frameSize hD.reduced
      -- The virtual state the loads run from.
      obtain ⟨xa, hxa0⟩ : ∃ xa, xa = FForm.virtAt S.body.spFrame (retLoads kk src) x := ⟨_, rfl⟩
      obtain ⟨ja, hxa⟩ := nf_virtAt_jump S (retLoads kk src) x
      rw [← hxa0] at hxa
      have hra : RRel s xa := by rw [hxa]; exact nf_rrel_jump hf.rrel ja
      have hspa : xa.rsp = xa.reg .rbp - BitVec.ofNat 64 S.F := by rw [hxa]; exact hf.rsp
      have hxam : xa.mem = x.mem := by rw [hxa]; exact nf_virt_mem S x
      obtain ⟨s1, regs, incoming, x', -, -, -, hfin, -, hbytes, hex, hret, hmem, hrsp, hrip', hrbp,
          -, hregs⟩ :=
        ArgRet.ret_step S.ctx S.r.frameSize hra hi hf' hsh
          (ret_step_fb_disp H.frameBounds hi hf' hsh) (fun h1 => by
            refine ⟨eF ▸ hspa, eF ▸ ?_⟩
            rcases h1 with h1 | h1
            · exact hF8 h1
            · exact nf_frame8 H h1) hst
      rw [hkk] at hex
      have hm0 := (memRel_foldlM _ (H.frameBounds.scope_size _) hf.rrel hf.mem hsc0).2
      rw [X86.execItems_append] at hex
      cases hy : execItems S.ctx (retLoads kk src) xa with
      | error e => rw [hy] at hex; cases hex
      | ok y =>
        rw [hy] at hex
        have hex2 : execItems S.ctx (epilogue S.r.frameSize S.c.mode ++ [.ret]) y = .ok x' := hex
        -- The loads, fetched in the body's frame form.
        have hhca := hca
        rw [List.map_append, codeAt_append, nf_virt_mem] at hhca
        obtain ⟨hcL, hcE⟩ := hhca
        obtain ⟨hs1, hy1, hmy⟩ := steps_of_run_fb (ctx := S.ctx) (fb := S.body.spFrame)
          (S := fun _ => True) (items := retLoads kk src) (pos := p) (x := x) (xv' := y)
          (fun i hi => (hl i hi).2.2.2.1)
          (fun F hF i hi => H.spDisp F hF S.body rfl hF _ _ _ hd' i (List.mem_append_left _ hi))
          (fun i hi => ret_shape_ripFree S.ctx (hl i hi).1)
          (fun i hi => (hl i hi).2.2.2.2 S.ctx)
          (ret_canon_map (fun i hi => ⟨(hl i hi).1, (hl i hi).2.2.1⟩) p)
          hcL hrip (fun _ _ => trivial)
          (fetchRun_of_forall (fun i hi => ret_shape_ok S.ctx (hl i hi).1) _)
          (by rw [← hxa0]; exact hy)
        have hym : y.mem = x.mem := funext fun a => hmy a trivial
        -- The epilogue and `ret`, on the real state.
        have hs2 : Steps S.ctx (FForm.real S.body.spFrame (x.reg .rbp) y)
            (FForm.real S.body.spFrame (x.reg .rbp) x') := by
          cases hfp : S.c.mode.framePointer
          · have hspF := nf_spFrame_of_nofp hD hfp
            have hpe := nf_pe_of_nofp hD hfp
            have hE : epilogue S.r.frameSize S.c.mode =
                [.addRsp (BitVec.ofNat 32 (S.r.frameSize + 8))] := by
              simp [epilogue, hpe, hfp]
            have hnm : ∀ i ∈ epilogue S.r.frameSize S.c.mode ++ [.ret], i.mem? = none := by
              rw [hE]; exact nf_noMem_cons rfl (nf_noMem_cons rfl nf_noMem_nil)
            have hrf : ∀ i ∈ epilogue S.r.frameSize S.c.mode ++ [.ret], i.RbpFree := by
              rw [hE]; intro i hi
              rcases List.mem_cons.mp hi with rfl | hi
              · exact rfl
              · rcases List.mem_cons.mp hi with rfl | hi
                · exact rfl
                · cases hi
            rw [fb_map_noMem _ hnm] at hcE
            have hex3 : execItems S.ctx (epilogue S.r.frameSize S.c.mode ++ [.ret])
                (y.setReg .rbp (x.reg .rbp)) = .ok (x'.setReg .rbp (x.reg .rbp)) := by
              (rw [nf_execItems_commute hrf hnm y (x.reg .rbp), hex2]) <;> rfl
            rw [hE] at hex3 hcE
            rw [hspF]
            show Steps S.ctx (y.setReg .rbp (x.reg .rbp)) (x'.setReg .rbp (x.reg .rbp))
            refine steps_of_run_last (S := fun _ => True) (x := y.setReg .rbp (x.reg .rbp))
              (items := [.addRsp (BitVec.ofNat 32 (S.r.frameSize + 8))]) (j := .ret) ?_ ?_ hy1
              (fun _ _ => trivial) ?_ hex3
            · exact ret_canon_list (fun i hi pos => by
                rcases List.mem_cons.mp hi with rfl | hi
                · exact ret_canon_of (fun _ => rfl) (fun _ _ h => by cases h) pos
                · rcases List.mem_cons.mp hi with rfl | hi
                  · exact ret_canon_of (fun _ => rfl) (fun _ _ h => by cases h) pos
                  · cases hi) _
            · rw [show (y.setReg .rbp (x.reg .rbp)).mem = x.mem from hym]; exact hcE
            · refine fetchRun_of_forall (fun i hi => ret_shape_ok S.ctx ?_) _
              rcases List.mem_cons.mp hi with rfl | hi
              · exact .inr (.inr (.inr (.inr (.inr ⟨_, rfl⟩))))
              · cases hi
          · have hspn := hD.spFrame_of_fp hfp
            simp only [hspn, FForm.real_none, FForm.map_item_none] at hcE hy1 ⊢
            refine steps_of_run_last (S := fun _ => True) (x := y)
              (items := epilogue S.r.frameSize S.c.mode) (j := .ret) ?_ ?_ hy1
              (fun _ _ => trivial) ?_ hex2
            · exact ret_canon_list (fun i hi => by
                rcases List.mem_append.mp hi with hi | hi
                · exact ret_epilogue_canon _ _ i hi
                · simp only [List.mem_singleton] at hi; subst hi
                  exact ret_canon_of (fun _ => rfl) (fun _ _ h => by cases h)) _
            · rw [hym]; exact hcE
            · exact fetchRun_of_forall
                (fun i hi => ret_shape_ok S.ctx (ret_epilogue_shape _ _ i hi)) _
        -- `ExitRel` on the real state.
        have hm0' : MemRel s0.st (FForm.real S.body.spFrame (x.reg .rbp) x') := by
          refine nf_memRel_of_mem hm0 ?_
          rw [nf_real_mem, hmem, hxam, nf_virt_mem]
        have hw : WorldRel (R.exit s0 (.ret regs0 inc0)).world
            (FForm.real S.body.spFrame (x.reg .rbp) x') :=
          Ryo.Proofs.Call.worldRel_exit _ hm0'
        rw [hfin] at hw hst
        refine Reach.steps hs1 (Reach.steps hs2 (.done (.inr ⟨_, .step hst, hw, ?_⟩)))
        have hbr := hf.frame
        have e16 : fpAddr xa 16 = S.x0.rsp + 8 := by
          rw [hxa]
          show fpAddr (S.virt x) 16 = _
          rw [hf.fpAddr_eq 16]
          unfold Setup.winAddr
          rw [show BitVec.ofInt 64 16 = 16 from rfl]
          bv_omega
        refine ⟨fun r hr' => ?_, ?_, ?_, ?_, ?_⟩
        · rw [ArgRet.retBytes_congr (y := x')
            (nf_real_regs S.body.spFrame (x.reg .rbp) x' (i := 0) (by decide))
            (nf_real_regs S.body.spFrame (x.reg .rbp) x' (i := 2) (by decide))
            (nf_real_xmm S.body.spFrame (x.reg .rbp) x')]
          exact hret r hr'
        · rw [nf_real_rip, hrip', hxa]; exact hbr.retAddr
        · rw [nf_real_rsp, hrsp, hxa]; exact hbr.rbp
        · intro i hsv
          by_cases h5 : i = 5
          · subst h5
            cases hfp : S.c.mode.framePointer
            · have hspF := nf_spFrame_of_nofp hD hfp
              have hv := hrb (by simp [Setup.fb, hspF])
              rw [hspF]
              show (x'.setReg .rbp (x.reg .rbp)).reg .rbp = S.x0.reg .rbp
              rw [State.reg_setReg]; exact hv
            · have hspn := hD.spFrame_of_fp hfp
              rw [hspn]
              show x'.reg .rbp = S.x0.reg .rbp
              rw [hrbp (.inr hfp), hxa]
              exact hbr.savedRbp hfp
          · have hne : i ≠ 0 ∧ i ≠ 2 ∧ i ≠ 11 ∧ i ≠ 4 := by
              rcases hsv with hcs | ⟨-, h67⟩
              · unfold CalleeSaved at hcs
                rcases hcs with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
              · rcases h67 with rfl | rfl <;> decide
            rw [nf_real_regs _ _ _ h5, hregs i hne.1 hne.2.1 hne.2.2.1 hne.2.2.2 h5, hxa]
            exact hbr.saved i hsv h5
        · rw [nf_real_mem, hmem, ← e16]
          exact hbytes (by have := H.argSizeK; have := H.frameBounds.K_le; omega)

theorem bodySim_ret (hD : Decodes S code relocs rodata callSites dropped scopes mode) (H : Hyps S)
    {k p : Nat} {a : Bool} {q : Proto} {cur c' : Cursor}
    (hP : ProtoFacts S k p q c' { pe := S.fr.mode.pe }) (hn : NoArg S.fr S.body p a cur)
    (hr : InsnRead S.fr S.ro cur q c') (hop : q.op = .ret) :
    BodySim S k p (S.used k) :=
  (bodySim_retB hD H hP hn hr hop).toB.used

end Insn

end Ryo.Proofs.DecodeSound
