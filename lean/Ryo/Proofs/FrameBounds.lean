/-
Ryo.Proofs.FrameBounds — the frame-offset facts the step lemmas take as hypotheses, from one
property of the decoded code, `FrameBounds c K`: every scope range, every frame write of a
native instruction, `arg`'s destination and `ret`'s source lie in the frame window `[-F, K)`
(`F` the frame size, `K` the end of what the function uses above `fp`, e.g. `16 + argSize`),
with `F` and `K` at most `2^31`.

- `FrameBounds.window`, `FrameBounds.scopesIn`, `FrameBounds.scope_size`, `FrameBounds.wrIn`:
  the hypotheses of `CacheMem`'s `_sep` steps (`Window` also needs `fp + K ≤ 2^64`: the frame
  lies in the address space, a fact of the running state, not of the code).
- `FrameBounds.arg_disp`, `FrameBounds.ret_disp`: `ArgRet`'s 32-bit displacement sums
  (`d + a.size ≤ 2^31`, `src + 16 ≤ 2^31`).
- `arg_step_fb`, `load_step_fb`, `store_step_fb`, `rip_step_fb`: the steps with those
  hypotheses replaced by `FrameBounds` (the last three through the register cache);
  `ret_step_fb_disp` is `ret_step`'s `hsrc`.

Decoded code satisfies `FrameBounds` when the bounds check accepts it (`decodeBounded`,
`Decoded.boundsOk`): `DecodeLink.Bounds.decode_frameBounds`, with `K = frameTop`, the highest
end of its frame ranges, or any larger `K ≤ 2 ^ 31` (`DecodeLink.Bounds.FrameBounds.mono`).
`fp + K ≤ 2 ^ 64` is an environment assumption (lean/docs/assumptions.md §5).
-/
import Ryo.Proofs.CacheMem
import Ryo.Proofs.ArgRet

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.FrameBounds

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
  Ryo.Proofs.Step Ryo.Proofs.RegCache Ryo.Proofs.ScopeMem Ryo.Proofs.CacheMem

/-- The decoded code's frame accesses lie in `[-F, K)` (see the module comment). -/
structure FrameBounds (c : R.Code) (K : Int) : Prop where
  F_le : (c.d.frameSize : Int) ≤ 2 ^ 31
  K_le : K ≤ 2 ^ 31
  scopes : ∀ k, ScopesIn (-(c.d.frameSize : Int)) K (c.scopesAt k)
  writes : ∀ (k : Nat) (op : Reduced.Opcode) (ops : List (R.Opnd Nat)) (f : Full.Opcode)
    (vals : Operands), c.d.insns[k]? = some (.native op ops) → op.full = some f →
    nativeVals c.ρ f ops = some vals → WrIn (-(c.d.frameSize : Int)) K f vals
  arg : ∀ (k : Nat) (op : Reduced.Opcode) (d : BitVec 32) (r : BitVec 64) (f : Full.Opcode)
    (a : ArgReg), c.d.insns[k]? = some (.native op [.slot d, .imm r]) →
    op.full = some f → f.info.shape = .arg → ArgReg.of? r.toNat true = some a →
    -(c.d.frameSize : Int) ≤ d.toInt ∧ d.toInt + a.size ≤ K
  ret : ∀ (k : Nat) (op : Reduced.Opcode) (src : BitVec 32) (kk : BitVec 64) (f : Full.Opcode),
    c.d.insns[k]? = some (.native op [.slot src, .imm kk]) →
    op.full = some f → f.info.shape = .ret →
    -(c.d.frameSize : Int) ≤ src.toInt ∧ src.toInt + 16 ≤ K

variable {c : R.Code} {K : Int}

theorem FrameBounds.window (hb : FrameBounds c K) {fp : Nat} (hfp : (fp : Int) + K ≤ 2 ^ 64) :
    Window (-(c.d.frameSize : Int)) K fp :=
  ⟨by have := hb.F_le; omega, by have := hb.K_le; omega, hfp⟩

theorem FrameBounds.scopesIn (hb : FrameBounds c K) (k : Nat) :
    ScopesIn (-(c.d.frameSize : Int)) K (c.scopesAt k) :=
  hb.scopes k

theorem FrameBounds.scope_size (hb : FrameBounds c K) (k : Nat) :
    ∀ sc ∈ c.scopesAt k, sc.size < 2 ^ 62 := fun sc hsc => by
  have := hb.scopes k sc hsc
  have := hb.F_le
  have := hb.K_le
  omega

theorem FrameBounds.wrIn (hb : FrameBounds c K) {k : Nat} {op : Reduced.Opcode}
    {ops : List (R.Opnd Nat)} {f : Full.Opcode} (hi : c.d.insns[k]? = some (.native op ops))
    (hf : op.full = some f) :
    ∀ vals, nativeVals c.ρ f ops = some vals → WrIn (-(c.d.frameSize : Int)) K f vals :=
  fun vals hv => hb.writes k op ops f vals hi hf hv

theorem FrameBounds.arg_disp (hb : FrameBounds c K) {k : Nat} {op : Reduced.Opcode}
    {d : BitVec 32} {r : BitVec 64} {f : Full.Opcode} {a : ArgReg}
    (hi : c.d.insns[k]? = some (.native op [.slot d, .imm r])) (hf : op.full = some f)
    (hsh : f.info.shape = .arg) (ha : ArgReg.of? r.toNat true = some a) :
    d.toInt + a.size ≤ 2 ^ 31 := by
  have := (hb.arg k op d r f a hi hf hsh ha).2
  have := hb.K_le
  omega

theorem FrameBounds.ret_disp (hb : FrameBounds c K) {k : Nat} {op : Reduced.Opcode}
    {src : BitVec 32} {kk : BitVec 64} {f : Full.Opcode}
    (hi : c.d.insns[k]? = some (.native op [.slot src, .imm kk])) (hf : op.full = some f)
    (hsh : f.info.shape = .ret) : src.toInt + 16 ≤ 2 ^ 31 := by
  have := (hb.ret k op src kk f hi hf hsh).2
  have := hb.K_le
  omega

/-! ### The steps -/

/-- `arg_step` with its displacement bound from `FrameBounds`. -/
theorem arg_step_fb (ctx : Ctx) {s s' : R.RState} {x : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {d : BitVec 32} {r : BitVec 64} {f : Full.Opcode} {a : ArgReg}
    (hb : FrameBounds c K) (hr : RRel s x)
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, .imm r]))
    (hf : op.full = some f) (hsh : f.info.shape = .arg) (ha : ArgReg.of? r.toNat true = some a)
    (harg : ArgRet.RegRel c.mode.pe s.args x (.ofArgReg a))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (argStore a d c.mode.pe) x = .ok x' ∧ RRel s' x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((argStore a d c.mode.pe).map Item.size).sum ∧
      s'.pc = s.pc + 1 ∧ s'.fp = s.fp ∧ s'.args = s.args ∧ x'.xmm = x.xmm ∧
      (∀ i : Fin 16, (∀ g ∈ ArgRet.argClobbers a c.mode.pe, i ≠ g.idx) → x'.regs i = x.regs i) :=
  ArgRet.arg_step ctx hr hi hf hsh ha (hb.arg_disp hi hf hsh ha) harg h

/-- `ret_step`'s displacement bound from `FrameBounds` (the rest of its statement as there). -/
theorem ret_step_fb_disp (hb : FrameBounds c K) {s : R.RState} {op : Reduced.Opcode}
    {src : BitVec 32} {kk : BitVec 64} {f : Full.Opcode}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot src, .imm kk])) (hf : op.full = some f)
    (hsh : f.info.shape = .ret) : src.toInt + 16 ≤ 2 ^ 31 :=
  hb.ret_disp hi hf hsh

/-- `load_step_sep_cached` with the frame-offset facts from `FrameBounds`. -/
theorem load_step_fb (ctx : Ctx) {s s' : R.RState} {x : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {w : W}
    {cand : List Item} {br : Option Cond} {cache : Cache} (hb : FrameBounds c K)
    (hfp : (s.fp : Int) + K ≤ 2 ^ 64) (hinv : CacheInv cache x) (hr : RRel s x)
    (hm : MemRel s.st x) (hs : FrameSep (-(c.d.frameSize : Int)) K s.st x)
    (hpriv : ∀ vals, nativeVals c.ρ f ops = some vals → AfterScopes c s (Private f vals))
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.load w)) (hseq : sequence (.load w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      FrameSep (-(c.d.frameSize : Int)) K s'.st x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' :=
  load_step_sep_cached ctx hinv hr hm hs (hb.window hfp) (hb.scopesIn s.pc) (hb.scope_size s.pc)
    hpriv (hb.wrIn hi hf) hi hf hok hseq h

/-- `store_step_sep_cached` with the frame-offset facts from `FrameBounds`. -/
theorem store_step_fb (ctx : Ctx) {s s' : R.RState} {x : X86.State} {ch : OpSem.Choice}
    {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode} {w : W}
    {cand : List Item} {br : Option Cond} {cache : Cache} (hb : FrameBounds c K)
    (hfp : (s.fp : Int) + K ≤ 2 ^ 64) (hinv : CacheInv cache x) (hr : RRel s x)
    (hm : MemRel s.st x) (hs : FrameSep (-(c.d.frameSize : Int)) K s.st x)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f (.store w)) (hseq : sequence (.store w) ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧ MemRel s'.st x' ∧
      FrameSep (-(c.d.frameSize : Int)) K s'.st x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' :=
  store_step_sep_cached ctx hinv hr hm hs (hb.window hfp) (hb.scopesIn s.pc)
    (hb.scope_size s.pc) hi hf hok hseq h

/-- `rip_step_sep_cached` with the frame-offset facts from `FrameBounds`. -/
theorem rip_step_fb (ctx : Ctx) {s s' : R.RState} {x x0 : X86.State} {st0 : OpSem.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {ops : List (R.Opnd Nat)} {f : Full.Opcode}
    {cls : Class} {cand : List Item} {br : Option Cond} {cache : Cache}
    (hc : ripAddr cls = true) (hb : FrameBounds c K) (hfp : (s.fp : Int) + K ≤ 2 ^ 64)
    (hinv : CacheInv cache x) (hr : RRel s x) (hm : MemRel s.st x)
    (hg : Globals ctx c.ρ st0 x0) (hs : FrameSep (-(c.d.frameSize : Int)) K s.st x)
    (hi : c.d.insns[s.pc]? = some (.native op ops)) (hf : op.full = some f)
    (hok : InlineOk f cls) (hseq : sequence cls ops = some (cand, br))
    (h : R.step c s ch = .ok (.step s')) :
    ∃ x', execItems ctx (cache.emit cand).1 x = .ok x' ∧ RRel s' x' ∧
      FrameSep (-(c.d.frameSize : Int)) K s'.st x' ∧ CacheInv (cache.emit cand).2 x' ∧
      x'.rip = x.rip + BitVec.ofNat 64 ((cache.emit cand).1.map Item.size).sum ∧
      BrOk f ops s s' br x' :=
  rip_step_sep_cached ctx hc hinv hr hm hg hs (hb.window hfp) (hb.scopesIn s.pc)
    (hb.scope_size s.pc) (hb.wrIn hi hf) hi hf hok hseq h

end Ryo.Proofs.FrameBounds
