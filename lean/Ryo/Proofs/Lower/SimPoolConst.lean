/-
Ryo.Proofs.Lower.SimPoolConst — the simulation of `LowerPoolConst` (`Check/Lower/PoolConst.lean`,
M5b): a pointer to a pool constant (`addr.const`) and a slice constant (`addr.const` and the
length's `imm.w64`), into a whole local, private or escaped.

**The pool invariant** (the global part of the L0–R relation for constants):
- `PoolPtrAt ι p q`: R's pointer `q` stands for L0's `p`: the same address (below `ADDR_LIMIT`)
  and provenances `ι` relates (`p`'s allocation mapped to `q`'s).
- `PoolInv pool ρ ι s`: for each global `g` the pool holds at offset `k` (`pool g = some k`,
  `StmtCtx.pool`), `g` is a constant or vtable of L0's program, `ρ (.const k)` is some `q`, and
  L0's first copy of `g` is a `p` with `PoolPtrAt ι p q`. L0 makes that copy at the start (D7,
  `Sem.instantiateConsts`); at the start check-pool's placements and M6's initial relation give
  `PoolInv` (open). Later copies (a fresh-copy answer elsewhere) don't matter: only the first one
  is constrained. `ι` only grows, and a non-call step keeps L0's program and first copies
  (`GlobKept`), so `PoolInv.keep` carries it.
- `ReusesAt o`: the oracle answers every `.constCopy g e` with `e > 0` by 0, the first copy (a
  daemonic choice, so the simulation makes it, as `PicksAt`'s addresses).

With both, `globalPtr g` takes L0's first copy and changes only `choiceCount`
(`globalPtr_reuse`, `PoolInv.pick`: `GlobalPick`).

**The lifts.** L0 (`poolPtr_mem`, `poolSlice_mem`): the constant decodes from `encodePtr p`
(`++ encodeBits 8 len` for a slice) at the local's type and re-encodes to the same bytes (with
the length mod `2^64`), stored into `_d`. R: `addr.const` writes `encodePtr q`
(`opSem_addrConst_fwd`, its view by `view_addrConst` under `c.ρ`), the `imm.w64` the length's
`intBytes`; two adjacent writes are one (`writeFrame_append`), and `FnRel.write_dst` relates the
destination (`encodePtr_inj`), `FnRel.after` assembles `FnRel`, `FnRelX.keep` the rest. The
stored provenance is `p`'s allocation's, which `ι` maps, so `Hidden` (not private),
`ProvBounded` (`ι` maps nothing fresh) and `DerefInv` (`store_mapped`) hold. `MemKept` doesn't
(the store brings in a provenance that may have been hidden), so the lifts give `LiftOutXN`, not
`LiftOut`, and `stmt_simX_poolConst` goes through `stmtOutX_of_liftXN`.

The function simulation (`FnSimX.lean`) carries `PoolInv` beside `MatchEscR` (`fn_simX`'s
premise, `fn_step_simX`'s outcome): a statement keeps it by `stmt_globKept`, a jump by
`term_globKept` or `JumpOutX`'s `GlobKept`; `fn_soundEsc*` assume it, and `ReusesAt`, at entry.
-/
import Ryo.Proofs.Lower.SimIdxRead
import Ryo.Proofs.Lower.SimRefDerefWideE
import Ryo.Proofs.Lower.CopyOps
import Ryo.Check.Lower.PoolConst
import Ryo.Proofs.Lower.GlobKept

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The invariant -/

/-- R's pointer `q` stands for L0's `p` (see the module comment). -/
def PoolPtrAt (ι : Inj) (p q : ThinPointer) : Prop :=
  p.addr = q.addr ∧ p.addr < Target.ADDR_LIMIT ∧
    ∃ a b, p.prov = some a ∧ q.prov = some b ∧ ι a = some b

/-- The pool invariant (see the module comment). -/
def PoolInv (pool : GlobalId → Option Nat) (ρ : R.Addrs) (ι : Inj) (s : Spec.State) : Prop :=
  ∀ g k, pool g = some k → ∃ gl q p ps, s.prog.globals[g]? = some gl ∧
    (gl.kind = .const ∨ ∃ t, gl.kind = .vtable t) ∧ ρ (.const k) = some q ∧
    s.constCopies.getD g [] = p :: ps ∧ PoolPtrAt ι p q

/-- The simulation's answer to a copy choice: the first copy (see the module comment). -/
def ReusesAt (o : Spec.Oracle) : Prop :=
  ∀ n g e s, 0 < e → o.answer n (.constCopy g e) s = (0 : Nat)

/-- What the lifts take: `globalPtr g` returns a pointer `q` stands for, changing only the
choice count. -/
def GlobalPick (ι : Inj) (o : Spec.Oracle) (s : Spec.State) (g : GlobalId) (q : ThinPointer) :
    Prop :=
  ∃ p, runOn (globalPtr g) o s = (.ok p, { s with choiceCount := s.choiceCount + 1 }) ∧
    PoolPtrAt ι p q

theorem PoolPtrAt.mono {ι ι' : Inj} {p q : ThinPointer} (h : PoolPtrAt ι p q) (hle : ι.Le ι') :
    PoolPtrAt ι' p q := by
  obtain ⟨h1, h2, a, b, ha, hb, hι⟩ := h
  exact ⟨h1, h2, a, b, ha, hb, hle a b hι⟩

theorem PoolInv.keep {pool : GlobalId → Option Nat} {ρ : R.Addrs} {ι ι' : Inj}
    {s s' : Spec.State} (h : PoolInv pool ρ ι s) (hle : ι.Le ι') (hk : GlobKept s s') :
    PoolInv pool ρ ι' s' := by
  intro g k hg
  obtain ⟨gl, q, p, ps, hgl, hkind, hq, hc, hpq⟩ := h g k hg
  obtain ⟨ps', hc'⟩ := hk.2 g p ps hc
  exact ⟨gl, q, p, ps', by rw [hk.1]; exact hgl, hkind, hq, hc', hpq.mono hle⟩

/-! ### L0: the first copy -/

theorem runOn_prog (o : Spec.Oracle) (s : Spec.State) :
    runOn SemM.prog o s = (.ok s.prog, s) := rfl

/-- `globalPtr g` with a first copy and the answer 0: that copy, one choice counted.

Proof: `globalPtr` is `globalPtrF` at fuel `globals.size + 1`, whose body looks `g` up
(`global?`, `hgl`), reads the state, takes the constant branch (`hk`), asks
`.constCopy g (ps.length + 1)` (`runOn_choose`, answered 0 by `ho`) and returns entry 0. -/
theorem runOn_choose_copy (g : GlobalId) (n : Nat) (o : Spec.Oracle) (s : Spec.State) :
    runOn (choose (Choice.constCopy g n) : SemM Nat) o s =
      (.ok (o.answer s.choiceCount (.constCopy g n) s),
        { s with choiceCount := s.choiceCount + 1 }) := rfl

theorem globalPtr_eq (g : GlobalId) :
    globalPtr g = (SemM.prog >>= fun P => globalPtrF (P.globals.size + 1) g) := rfl

theorem globalPtr_reuse {o : Spec.Oracle} {s : Spec.State} {g : GlobalId} {gl : Global}
    {p : ThinPointer} {ps : List ThinPointer} (hgl : s.prog.globals[g]? = some gl)
    (hk : gl.kind = .const ∨ ∃ t, gl.kind = .vtable t)
    (hc : s.constCopies.getD g [] = p :: ps)
    (ho : ∀ e, 0 < e → o.answer s.choiceCount (.constCopy g e) s = (0 : Nat)) :
    runOn (globalPtr g) o s = (.ok p, { s with choiceCount := s.choiceCount + 1 }) := by
  have hpos : 0 < (s.constCopies.getD g []).length := by rw [hc]; simp
  have ho' := ho _ hpos
  have hc' : s.constCopies[g]?.getD [] = p :: ps := by
    rw [← hc]
    first | simp | rfl | simp [Array.getD_eq_getD_getElem?]
  rw [globalPtr_eq, runOn_bind, runOn_prog]
  rcases hk with hk | ⟨t, hk⟩
  all_goals
    simp only [globalPtrF, global?, runOn_bind, runOn_prog, runOn_get, runOn_pure,
      runOn_choose_copy, hgl, hk, ho', hc, hc', List.getElem?_cons_zero]
  all_goals (try rw [runOn_choose])
  all_goals (try simp only [ho', List.getElem?_cons_zero, runOn_pure])
  all_goals (try rfl)

/-- `PoolInv` and `ReusesAt` give a pool global's `GlobalPick` at its pool address. -/
theorem PoolInv.pick {pool : GlobalId → Option Nat} {ρ : R.Addrs} {ι : Inj} {s : Spec.State}
    {o : Spec.Oracle} (h : PoolInv pool ρ ι s) (hre : ReusesAt o) {g : GlobalId} {k : Nat}
    (hg : pool g = some k) : ∃ q, ρ (.const k) = some q ∧ GlobalPick ι o s g q := by
  obtain ⟨gl, q, p, ps, hgl, hkind, hq, hc, hpq⟩ := h g k hg
  exact ⟨q, hq, p, globalPtr_reuse hgl hkind hc (fun e he => hre _ _ _ _ he), hpq⟩

/-! ### L0: the statements -/

/-- A slice-like pointer decodes from 16 bytes: the data pointer from the first 8, the length
from the last 8. -/
theorem decode_ptr_slice_inv {pt : PtrType} {valid : ValidRange}
    (hk : pt.metaKind = .elementCount) {bs : List AbstractByte} {v : Value}
    (hd : (Spec.Ty.ptr pt valid).decode bs = some v) :
    ∃ tp n, bs.length = 16 ∧ decodePtr (bs.take 8) = some tp ∧ decodeBits (bs.drop 8) = some n ∧
      v = .ptr ⟨tp, some (.elementCount n)⟩ := by
  simp only [Spec.Ty.decode, hk] at hd
  by_cases hl : bs.length = 16
  · cases hdp : decodePtr (bs.take 8) with
    | none => simp [hl, hdp] at hd
    | some tp =>
      by_cases hv : valid.contains tp.addr = true
      · cases hn : decodeBits (bs.drop 8) with
        | none => simp [hl, hdp, hv, hn] at hd
        | some n =>
          simp [hl, hdp, hv, hn] at hd
          exact ⟨tp, n, hl, rfl, rfl, hd.symm⟩
      · simp [hl, hdp, hv] at hd
  · simp [hl] at hd

/-- `_d = const (ptr (alloc g) 0)` at a thin pointer type, with `globalPtr g` picking `p`: one
store of `encodePtr p` into `_d`.

Proof: `assign_use_inv`; the operand is `evalConst`, which resolves the reference
(`resolveRef`: `globalPtr g` then `wrappingOffset 0`, the identity below `ADDR_LIMIT`) and
decodes `encodePtr p` (`runOn_decodeConst_ok`: the state stays `sc`); `decode_ptr_thin_inv`
and `decodePtr_encodePtr` give the value `p`, whose encoding is `encodePtr p`
(`typedStore_inv`, `Ty.encode`). -/
theorem poolPtr_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {g : GlobalId}
    {pt : PtrType} {valid : ValidRange} (htd : f.body.locals[d]? = some (.ptr pt valid))
    (hk : pt.metaKind = .none) {p : ThinPointer}
    (hgp : runOn (globalPtr g) o s = (.ok p, { s with choiceCount := s.choiceCount + 1 }))
    (hlt : p.addr < Target.ADDR_LIMIT)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.use (.const (.ptr (.alloc g) 0) (.ptr pt valid))))) o s = (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧ s.mem.store pd (encodePtr p) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  obtain ⟨pd, td, r, s1, hpd, htd', hev, mem', hst, hs'⟩ := assign_use_inv hs h
  have e4 : td = .ptr pt valid := Option.some.inj (htd'.symm.trans htd)
  subst e4
  have e3 : evalOperand (.const (.ptr (.alloc g) 0) (.ptr pt valid)) =
      (evalConst (.ptr (.alloc g) 0) (.ptr pt valid) >>= fun w =>
        pure (w, Spec.Ty.ptr pt valid)) := by
    first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
  rw [e3] at hev
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨hr, hs12⟩ := prod_ok_inj h2
  subst hr
  subst hs12
  have e5 : evalConst (.ptr (.alloc g) 0) (.ptr pt valid) =
      (resolveRef (.alloc g) 0 >>= fun q => decodeConst (encodePtr q) (.ptr pt valid)) := by
    first | rfl | (unfold evalConst; rfl) | simp only [evalConst]
  rw [e5] at h1
  obtain ⟨q, s3, h3, h4⟩ := runOn_bind_ok h1
  have e6 : resolveRef (.alloc g) 0 = (globalPtr g >>= fun p => pure (p.wrappingOffset 0)) := by
    first | rfl | (unfold resolveRef; rfl) | simp only [resolveRef]
  rw [e6] at h3
  obtain ⟨p', s4, h5, h6⟩ := runOn_bind_ok h3
  rw [hgp] at h5
  obtain ⟨e7, e8⟩ := prod_ok_inj h5
  subst e8
  rw [← e7, runOn_pure] at h6
  obtain ⟨hq, hs3⟩ := prod_ok_inj h6
  subst hs3
  rw [← hq, wrappingOffset_zero hlt] at h4
  obtain ⟨hdec, hs2⟩ := runOn_decodeConst_ok h4
  subst hs2
  obtain ⟨tp, -, hdp, hw⟩ := decode_ptr_thin_inv hk hdec
  rw [Ryo.Spec.Theorems.decodePtr_encodePtr _ hlt] at hdp
  have htp : p = tp := Option.some.inj hdp
  obtain ⟨bs, hen, hsto⟩ := typedStore_inv hst
  have hbs : bs = encodePtr p := by
    simp [hw, ← htp, Spec.Ty.encode, hk] at hen
    first | exact hen.symm | exact hen
  subst hbs
  subst hs'
  exact ⟨pd, hpd, hsto, rfl⟩

/-- `_d = const (slice g len)` at a slice-like pointer type, with `globalPtr g` picking `p`: one
store of `encodePtr p ++ encodeBits 8 (len mod 2^64)` into `_d` (as `poolPtr_mem`: `evalConst`
takes `globalPtr g` and decodes `encodePtr p ++ encodeBits 8 len`; `decode_ptr_slice_inv`,
`decodePtr_encodePtr`, `decodeBits_encodeBits`). -/
theorem poolSlice_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {g : GlobalId} {len : Nat}
    {pt : PtrType} {valid : ValidRange} (htd : f.body.locals[d]? = some (.ptr pt valid))
    (hk : pt.metaKind = .elementCount) {p : ThinPointer}
    (hgp : runOn (globalPtr g) o s = (.ok p, { s with choiceCount := s.choiceCount + 1 }))
    (hlt : p.addr < Target.ADDR_LIMIT)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.use (.const (.slice g len) (.ptr pt valid))))) o s = (.ok (), s')) :
    ∃ pd, f.locals[d]? = some (some pd) ∧
      s.mem.store pd (encodePtr p ++ encodeBits 8 (len % 2 ^ (8 * 8))) .one = .ok s'.mem ∧
      s'.stack = s.stack := by
  obtain ⟨pd, td, r, s1, hpd, htd', hev, mem', hst, hs'⟩ := assign_use_inv hs h
  have e4 : td = .ptr pt valid := Option.some.inj (htd'.symm.trans htd)
  subst e4
  have e3 : evalOperand (.const (.slice g len) (.ptr pt valid)) =
      (evalConst (.slice g len) (.ptr pt valid) >>= fun w =>
        pure (w, Spec.Ty.ptr pt valid)) := by
    first | rfl | (unfold evalOperand; rfl) | simp only [evalOperand]
  rw [e3] at hev
  obtain ⟨w, s2, h1, h2⟩ := runOn_bind_ok hev
  obtain ⟨hr, hs12⟩ := prod_ok_inj h2
  subst hr
  subst hs12
  have e5 : evalConst (.slice g len) (.ptr pt valid) =
      (globalPtr g >>= fun q =>
        decodeConst (encodePtr q ++ encodeBits 8 len) (.ptr pt valid)) := by
    first | rfl | (unfold evalConst; rfl) | simp only [evalConst]
  rw [e5] at h1
  obtain ⟨q, s3, h3, h4⟩ := runOn_bind_ok h1
  rw [hgp] at h3
  obtain ⟨e7, e8⟩ := prod_ok_inj h3
  subst e8
  rw [← e7] at h4
  obtain ⟨hdec, hs2⟩ := runOn_decodeConst_ok h4
  subst hs2
  obtain ⟨tp, n, -, hdp, hdn, hw⟩ := decode_ptr_slice_inv hk hdec
  rw [List.take_left' (Ryo.Spec.Theorems.encodePtr_length _),
    Ryo.Spec.Theorems.decodePtr_encodePtr _ hlt] at hdp
  have htp : p = tp := Option.some.inj hdp
  rw [List.drop_left' (Ryo.Spec.Theorems.encodePtr_length _),
    Ryo.Spec.Theorems.decodeBits_encodeBits] at hdn
  have hn : len % 2 ^ (8 * 8) = n := Option.some.inj hdn
  obtain ⟨bs, hen, hsto⟩ := typedStore_inv hst
  have hbs : bs = encodePtr p ++ encodeBits 8 (len % 2 ^ (8 * 8)) := by
    simp [hw, ← htp, ← hn, Spec.Ty.encode, hk] at hen
    first | exact hen.symm | exact hen
  subst hbs
  subst hs'
  exact ⟨pd, hpd, hsto, rfl⟩

/-! ### R: `addr.const` -/

/-- The forward direction of `addr.const` (as `opSem_addr_fwd`): its footprint writes `d`'s 8
bytes, its kind's semantics is `encodePtr` of the address operand. -/
theorem opSem_addrConst_fwd {op : Full.Opcode} {r : Option String} {ps : List String}
    {d : Int} {q : ThinPointer} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.addr_const, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .abs⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31)
    (hw : st.writeFrame d (encodePtr q) = .ok st') :
    opSem op [.slot d, .addr q] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa : Val.fits .abs (.addr q) = true := rfl
  have hfp : footprint op = some { writes := [Ryo.Proofs.Inline.rdA "d" 8] } := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    rfl
  have hprep : prepare op [.slot d, .addr q] =
      .ok (⟨.addr_const, ps, r⟩, { writes := [Ryo.Proofs.Inline.rdA "d" 8] },
        opndVal op.info [.slot d, .addr q]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa])]
    rfl
  have hva : opndVal op.info [.slot d, .addr q] "a" = some (.addr q) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .addr q] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll { writes := [Ryo.Proofs.Inline.rdA "d" 8] }
      (opndVal op.info [.slot d, .addr q]) st = .ok [] := rfl
  have hk : kindSem .addr_const ps (mkEnv [] (opndVal op.info [.slot d, .addr q]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", encodePtr q)] } := by
    simp [kindSem, mkEnv, out, Env.addr, hva, bind, Except.bind, pure, Except.pure]
  have hc : commit { writes := [Ryo.Proofs.Inline.rdA "d" 8] }
      (opndVal op.info [.slot d, .addr q]) st [("d", encodePtr q)] = .ok st' := by
    simp only [commit, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval,
      Ryo.Spec.Theorems.encodePtr_length, hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-! ### The lifts -/

/-- `encodeBits` relates to itself (it carries no provenance). -/
theorem encodeBits_inj_refl (ι : Inj) (n v : Nat) : BytesInj ι (encodeBits n v) (encodeBits n v) :=
  BytesInj.of_getElem rfl fun _ h0 _ => encodeBits_inj_self (List.getElem_mem h0)

/-- The R bytes written by a pool pointer relate to L0's (`PoolPtrAt` gives `PtrInj`). -/
theorem PoolPtrAt.ptrInj {ι : Inj} {p q : ThinPointer} (h : PoolPtrAt ι p q) : PtrInj ι p q := by
  obtain ⟨h1, -, a, b, ha, hb, hι⟩ := h
  refine ⟨h1, ?_⟩
  rw [ha, hb]
  simp [ProvInj, hι]

/-- The facts about L0's stored bytes the lifts need: every provenance in them is `a`, which `ι`
maps (to `b`), and `a` is an allocation of L0's memory. -/
theorem stored_prov {ι : Inj} {m : Memory} {bs : List AbstractByte} {a b : AllocId}
    (hbs : ∀ x ∈ bs, ∀ fr, x.provFrag = some fr → fr.prov = a) (hι : ι a = some b)
    (hfresh : ∀ a', m.allocs.size ≤ a' → ι a' = none) {f : Spec.Frame} :
    (∀ x ∈ bs, ∀ fr, x.provFrag = some fr → ¬ PrivAlloc ι f fr.prov) ∧
      BytesBounded m.allocs.size bs ∧ (∀ x ∈ bs, ∀ fr, x.provFrag = some fr → ι fr.prov ≠ none) := by
  have hlt : a < m.allocs.size := by
    rcases Nat.lt_or_ge a m.allocs.size with h | h
    · exact h
    · have := hfresh a h
      rw [hι] at this
      cases this
  refine ⟨fun x hx fr hf hpr => ?_, fun x hx fr hf => by rw [hbs x hx fr hf]; exact hlt,
    fun x hx fr hf => by rw [hbs x hx fr hf, hι]; simp⟩
  obtain ⟨-, -, -, -, hn⟩ := hpr
  rw [hbs x hx fr hf, hι] at hn
  cases hn

/-- The allocations after a store, against before: there, and live only if live before. -/
theorem store_agree_live {m m' : Memory} {p : ThinPointer} {bs : List AbstractByte} {al : Align}
    (hsto : m.store p bs al = .ok m') :
    ∀ q x1, m'.get? q = some x1 → ∃ x0, m.get? q = some x0 ∧ (x1.live = true → x0.live = true) := by
  intro q x1 hx1
  obtain ⟨x0, hx0, -, hl, -⟩ := store_get?_fwd hsto hx1
  exact ⟨x0, hx0, fun h => hl.trans h⟩

/-- `ptr`'s lift: from `FnRelX` at the fold `s0` of the scopes at `pc`, `addr.const` into `_d`
(see the module comment). -/
theorem lift_poolPtr {Γ : StmtCtx} {c : R.Code} {s1 s0 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    {d : Local} {g : GlobalId} {pt : PtrType} {valid : ValidRange} {i : R.Insn}
    (hlow : LowerPoolConst Γ
      (.assign ⟨d, []⟩ (.use (.const (.ptr (.alloc g) 0) (.ptr pt valid)))) [i])
    (hi : c.d.insns[s1.pc]? = some i)
    (hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hpe : c.mode.pe = false) (hpl : PlainView c.mode c.ρ i)
    (hX : FnRelX Γ ι live f s.mem s0) (hpb : ProvBounded s.mem)
    (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hpool : PoolInv Γ.poolAt c.ρ ι s) (hre : ReusesAt o)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.use (.const (.ptr (.alloc g) 0) (.ptr pt valid))))) o s = (.ok (), s')) :
    LiftOutXN Γ c ch ι live' f s s' s1 s0 1 := by
  cases hlow with
  | @ptr _ _ k _ _ sd _ hk htdΓ hmk hsd hsize hoff hiok =>
    obtain ⟨q, hq, p, hrun, hpq⟩ := hpool.pick hre hk
    obtain ⟨op, sl, fo, rfl, hfull, ⟨ps, r, hh⟩, ho, hsh, hsl⟩ := addrConstInsnOk_spec hiok
    have hv := view_addrConst (mode := c.mode) (s := sl) hfull ho hsh hq
    rw [hsl] at hv
    have htd : f.body.locals[d]? = some (.ptr pt valid) := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, hpd, hsto, hstk⟩ := poolPtr_mem hs htd hmk hrun hpq.2.1 h
    have hpi := hpq.ptrInj
    obtain ⟨-, -, a, b, hpa, -, hιa⟩ := hpq
    have hpos : 0 < sd.size := by omega
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hX.rel.write_dst hdi.ld hpd hsd hpos
      (encodePtr_inj hpi) (by rw [Ryo.Spec.Theorems.encodePtr_length, hsize]) hsto
    have hf1 := offOk_spec hoff
    have hop := opSem_addrConst_fwd (ch := ch) hh ho ⟨hf1.1, hf1.2⟩ hwr
    have hstep := step_of_view_scopes hi hfold hpe hpl hv rfl hop
    have hbprov : ∀ x ∈ encodePtr p, ∀ fr, x.provFrag = some fr → fr.prov = a :=
      fun x hx fr hf => Option.some.inj ((encodePtr_prov hx hf).symm.trans hpa)
    obtain ⟨hnp, hbd, hmap⟩ := stored_prov (f := f) hbprov hιa hfresh
    have hhid : Hidden s'.mem (PrivAlloc ι f) := hX.rel.hidden.store_hidden hsto hnp
    have hfn := hX.rel.after hpd hsd hmi hrd hoth hhid hesc hlive' (pc' := s0.pc + 1)
    refine ⟨ι, st', fun _ _ e => e, fun _ _ => rfl, .cons hstep (.refl _), hstk, ?_,
      hpb.store hsto hbd, Nat.le_of_eq (store_size hsto).symm, hdi.store_mapped hsto hmap⟩
    exact hX.keep hfn hesc rfl (writeFrame_allocsKept hwr) (store_agree_live hsto)

/-- `slice`'s lift: `addr.const` into `_d`'s first 8 bytes, then the length's `imm.w64` into the
last 8 (see the module comment). -/
theorem lift_poolSlice {Γ : StmtCtx} {c : R.Code} {s1 s0 : R.RState} {ch : OpSem.Choice}
    {ι : Inj} {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State}
    {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {g : GlobalId} {len : Nat} {pt : PtrType} {valid : ValidRange} {i1 i2 : R.Insn}
    (hlow : LowerPoolConst Γ
      (.assign ⟨d, []⟩ (.use (.const (.slice g len) (.ptr pt valid)))) [i1, i2])
    (hi1 : c.d.insns[s1.pc]? = some i1) (hi2 : c.d.insns[s0.pc + 1]? = some i2)
    (hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0)
    (hsc2 : c.scopesAt (s0.pc + 1) = [])
    (hpe : c.mode.pe = false) (hpl1 : PlainView c.mode c.ρ i1) (hpl2 : PlainView c.mode c.ρ i2)
    (hX : FnRelX Γ ι live f s.mem s0) (hpb : ProvBounded s.mem)
    (hfresh : ∀ a, s.mem.allocs.size ≤ a → ι a = none) (hdi : DerefInv ι s.mem)
    (hpool : PoolInv Γ.poolAt c.ρ ι s) (hre : ReusesAt o)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩
      (.use (.const (.slice g len) (.ptr pt valid))))) o s = (.ok (), s')) :
    LiftOutXN Γ c ch ι live' f s s' s1 s0 2 := by
  cases hlow with
  | @slice _ _ _ k _ _ sd _ _ hk htdΓ hmk hsd hsize hoff hiok1 hiok2 =>
    obtain ⟨q, hq, p, hrun, hpq⟩ := hpool.pick hre hk
    have htd : f.body.locals[d]? = some (.ptr pt valid) := by rw [← hbody]; exact htdΓ
    obtain ⟨pd, hpd, hsto, hstk⟩ := poolSlice_mem hs htd hmk hrun hpq.2.1 h
    have hpi := hpq.ptrInj
    obtain ⟨-, -, a, b, hpa, -, hιa⟩ := hpq
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    -- R may write `_d`'s slot: its escaped bytes have allocations
    have hok : ∀ k : Nat, k < 16 → ∀ e, s0.st.escapedAt (sd.off + k) = some e →
        e.id < s0.st.mem.allocs.size := by
      intro k hk e he
      obtain ⟨sd', hsd', hrd⟩ := hX.rel.frame.locals d pd hpd (by rw [hX.rel.unaliased]; simp)
      rw [hsd] at hsd'
      obtain rfl := Option.some.inj hsd'
      cases hrd with
      | priv a' x hp hι hx hlive haddr hpaddr hsz hpriv _ =>
        rw [hpriv k (by omega)] at he
        cases he
      | esc a' x e' y hp hι hx hlive haddr hpaddr hsz hin hy =>
        rw [hin k (by omega)] at he
        cases he
        unfold Memory.get? at hy
        exact (Array.getElem?_eq_some_iff.mp hy).1
    -- step 1: `addr.const d, k`
    obtain ⟨op, sl, fo, rfl, hfull, ⟨ps, r, hh⟩, ho, hsh, hsl⟩ := addrConstInsnOk_spec hiok1
    have hv1 := view_addrConst (mode := c.mode) (s := sl) hfull ho hsh hq
    rw [hsl] at hv1
    have hlen8 : (encodePtr q).length = 8 := Ryo.Spec.Theorems.encodePtr_length _
    obtain ⟨st1, hw1⟩ := writeFrame_ok_of (st := s0.st) (off := sd.off) (bs := encodePtr q)
      (fun k hk e he => hok k (by rw [hlen8] at hk; omega) e he)
    have hop1 := opSem_addrConst_fwd (ch := ch) hh ho ⟨hf1.1, hf1.2⟩ hw1
    have hstep1 := step_of_view_scopes hi1 hfold hpe hpl1 hv1 rfl hop1
    obtain ⟨hef1, hesc1, -⟩ := writeFrame_split hw1
    -- step 2: `imm.w64 d + 8, len`
    obtain ⟨v2, ty2, r2, hv2, hh2, hty2, hn2, hk2, hops2, hctl2⟩ := immInsnOk_spec hiok2
    rw [hmode, hρ] at hv2
    obtain ⟨sg2, hty2'⟩ := intTyOk_spec hty2
    obtain ⟨x, hops2', hx⟩ := immOpsOk_spec hops2
    obtain ⟨kk, ho2⟩ := operands2 hn2 hk2
    have hops2'' : v2.ops = [.slot (sd.off + 8), .imm x] := hops2'
    have hfk : Val.fits kk (.imm x) = true :=
      fits_last (hpl2.fits v2 hv2) (by rw [ho2, hops2'']; simp)
    have hlenI : (intBytes 8 x).length = 8 := Ryo.Spec.Theorems.encodeBits_length _ _
    have hok2 : ∀ k < (intBytes 8 x).length, ∀ e, st1.escapedAt (sd.off + 8 + k) = some e →
        e.id < st1.mem.allocs.size := by
      intro k hk e he
      rw [escapedAt_congr hesc1] at he
      rw [hef1.1]
      exact hok (8 + k) (by rw [hlenI] at hk; omega) e
        (by rw [show sd.off + ((8 + k : Nat) : Int) = sd.off + 8 + k by push_cast; omega]
            exact he)
    obtain ⟨st2, hw2⟩ := writeFrame_ok_of hok2
    have hop2 := opSem_imm_fwd (ch := ch) hh2 hty2' ho2 ⟨hf2.1, hf2.2⟩ hfk hw2
    have hstep2 := step_of_view (s1 := { s0 with pc := s0.pc + 1, st := st1 }) hi2 hsc2 hpe
      hpl2 hv2 hctl2 (by rw [hops2'']; exact hop2)
    -- the two writes are one: `FnRel.write_dst`
    have hw12 : s0.st.writeFrame sd.off (encodePtr q ++ intBytes 8 x) = .ok st2 :=
      writeFrame_append hw1 (by rw [hlen8]; exact hw2)
    have hbits : intBytes 8 x = encodeBits 8 (len % 2 ^ (8 * 8)) := by
      show encodeBits 8 x = _
      rw [← encodeBits_mod 8 x, hx]
    have hinj : BytesInj ι (encodePtr p ++ encodeBits 8 (len % 2 ^ (8 * 8)))
        (encodePtr q ++ intBytes 8 x) := by
      rw [hbits]
      exact (encodePtr_inj hpi).append (encodeBits_inj_refl ι _ _)
    have hpos : 0 < sd.size := by omega
    obtain ⟨st', hwr, hesc, hmi, hrd, hoth⟩ := hX.rel.write_dst hdi.ld hpd hsd hpos hinj
      (by rw [List.length_append, Ryo.Spec.Theorems.encodePtr_length,
        Ryo.Spec.Theorems.encodeBits_length, hsize]) hsto
    rw [hw12] at hwr
    obtain rfl : st2 = st' := Except.ok.inj hwr
    -- the relation
    have hbprov : ∀ y ∈ encodePtr p ++ encodeBits 8 (len % 2 ^ (8 * 8)), ∀ fr,
        y.provFrag = some fr → fr.prov = a := by
      intro y hy fr hf
      rcases List.mem_append.mp hy with hy | hy
      · exact Option.some.inj ((encodePtr_prov hy hf).symm.trans hpa)
      · rw [encodeBits_noprov _ _ y hy] at hf
        cases hf
    obtain ⟨hnp, hbd, hmap⟩ := stored_prov (f := f) hbprov hιa hfresh
    have hhid : Hidden s'.mem (PrivAlloc ι f) := hX.rel.hidden.store_hidden hsto hnp
    have hfn := hX.rel.after hpd hsd hmi hrd hoth hhid hesc hlive' (pc' := s0.pc + 2)
    refine ⟨ι, st2, fun _ _ e => e, fun _ _ => rfl, .cons hstep1 (.cons hstep2 (.refl _)), hstk,
      ?_, hpb.store hsto hbd, Nat.le_of_eq (store_size hsto).symm, hdi.store_mapped hsto hmap⟩
    exact hX.keep hfn hesc rfl (writeFrame_allocsKept hw12) (store_agree_live hsto)

/-! ### One statement with scopes -/

/-- The pool-constant statements have no own scope. -/
theorem ownSpec_poolConst {Γ : StmtCtx} {st : Statement} {is : List R.Insn}
    (h : LowerPoolConst Γ st is) : ownSpec Γ st = [] := by
  cases h <;> simp [ownSpec, refPlace?, useSpec, Operand.local?, operandPlace?]

/-- `LowerPoolConst` under pending scopes: `stmt_simX`'s case, given the pool invariant and the
copy choice (see the module comment). -/
theorem stmt_simX_poolConst {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFnX Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 s0 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAtX Γ c ι s s1 s0 f rest blk bd)
    (hpool : PoolInv Γ.poolAt c.ρ ι s) (hre : ReusesAt o)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h2 : r.2 ≤ c.d.insns.size)
    (hnext : r.2 = nextStart blk f.stmt)
    (hlow : LowerPoolConst Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOutX Γ c ch ι f rest bd blk s s1x s1 := by
  have hown := ownSpec_poolConst hlow
  have hlen := rangeInsns_length (r := r) h2
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hlt : r.1 < r.2 := by
    have : 0 < (rangeInsns c.d r).length := by
      have hl0 := hlow
      generalize rangeInsns c.d r = is at hl0 ⊢
      cases hl0 <;> simp
    omega
  -- the scopes at `pc` are the pending ones (no own scope): their fold is `s0`
  have hsc := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmt f.stmt st r hst hr hlt
  rw [hown, List.append_nil] at hsc
  have hlenS := specsOk_length _ _ hsc
  have hfold : (c.scopesAt s1.pc).foldlM R.applyScope s1 = .ok s0 := by
    have hp := M.pend
    have ht : (c.scopesAt s1.pc).take (pendSpecs Γ.toStmtCtx bd blk f.stmt).length =
        c.scopesAt s1.pc := by
      apply List.take_of_length_le
      have hl' : (c.scopesAt s1.pc).length = (pendSpecs Γ.toStmtCtx bd blk f.stmt).length := by
        rw [hpc0]
        exact hlenS
      omega
    rw [ht] at hp
    exact hp
  have hpcs : s0.pc = s1.pc := scopes_pc hfold
  have hsx := hfn.stmtsX f.bb bd blk M.hbd M.hblk
  have hpend0 := hsx.pend0 f.stmt r hr hlt
  have hpcNext : r.2 = pcAt blk (f.stmt + 1) := hnext.trans (nextStart_eq blk f.stmt)
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hlow0 := hlow
  generalize hR : rangeInsns c.d r = is at hlow0
  cases hlow0 with
  | @ptr _ _ _ _ _ _ i hk htd hmk hsd hsize hoff hiok =>
    rw [hR] at hlow
    obtain ⟨hl1, -⟩ := assign_live hfn.live M.hbd hst
    obtain ⟨hc0', he⟩ := rangeInsns_single h2 hR
    have hc0 : c.d.insns[s1.pc]? = some i := by rw [hpc0]; exact hc0'
    have hpl0 : PlainView c.mode c.ρ i := by rw [hmode, hρ]; exact hfn.plain _ _ hc0
    refine stmtOutX_of_liftXN (k := 1) M.stack hfn.storage M.hbd hst M.sl M.fresh
      (by rw [hpcs, hpc0, ← hpcNext, he]) hpend0 ?_
    exact lift_poolPtr M.stack M.body.symm hlow hc0 hfold hpe hpl0 M.rel M.pb M.fresh M.dinv
      hpool hre hl1 hev
  | @slice _ _ _ _ _ _ _ i1 i2 hk htd hmk hsd hsize hoff hiok1 hiok2 =>
    rw [hR] at hlow
    obtain ⟨hl1, -⟩ := assign_live hfn.live M.hbd hst
    have hl2 := hlen
    rw [hR] at hl2
    simp only [List.length_cons, List.length_nil] at hl2
    have hat := rangeInsns_at (r := r) h2
    have hget : ∀ j, j < 2 → c.d.insns[r.1 + j]? = [i1, i2][j]? := by
      intro j hj
      have hj' : j < (rangeInsns c.d r).length := by rw [hR]; simpa using hj
      rw [hat j hj', ← List.getElem?_eq_getElem hj', hR]
    have hc0 : c.d.insns[s1.pc]? = some i1 := by
      rw [hpc0]; simpa using hget 0 (by decide)
    have hc1 : c.d.insns[s0.pc + 1]? = some i2 := by
      rw [hpcs, hpc0]; simpa using hget 1 (by decide)
    have hin := (hfn.scopes f.bb bd blk M.hbd M.hblk).stmtInner f.stmt r hr
    have hsc2 : c.scopesAt (s0.pc + 1) = [] := by
      have := hin (r.1 + 1) (by omega) (by omega)
      rw [hpcs, hpc0]; exact this
    have hpl0 : PlainView c.mode c.ρ i1 := by rw [hmode, hρ]; exact hfn.plain _ _ hc0
    have hpl1 : PlainView c.mode c.ρ i2 := by rw [hmode, hρ]; exact hfn.plain _ _ hc1
    refine stmtOutX_of_liftXN (k := 2) M.stack hfn.storage M.hbd hst M.sl M.fresh
      (by rw [hpcs, hpc0, ← hpcNext]; omega) hpend0 ?_
    exact lift_poolSlice M.stack M.body.symm hmode.symm hρ.symm hlow hc0 hc1 hfold hsc2 hpe
      hpl0 hpl1 M.rel M.pb M.fresh M.dinv hpool hre hl1 hev

end Ryo.Proofs.Lower
