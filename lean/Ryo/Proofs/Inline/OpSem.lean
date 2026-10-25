/-
Ryo.Proofs.Inline.OpSem — what a successful `opSem` of an inline opcode did, per handler kind
(reduced.md Part D): the frame reads, the values decoded from them, and the frame write.

Each lemma takes an opcode by its handler (kind and parameters) and operand list, not by
number, so it covers every opcode of that form. `opSem_inv` is the common first step: a
successful `opSem` prepared the operands, read the footprint, ran the kind and committed.
-/
import Ryo.Proofs.Inline.Rel

namespace Ryo.Proofs.Inline

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem

theorem prepare_handler {op : Full.Opcode} {ops : Operands} {h : Handlers.HandlerInfo}
    {fp : Footprint} {val : String → Option Val} (hp : prepare op ops = .ok (h, fp, val)) :
    op.handler? = some h := by
  unfold prepare at hp
  cases hh : op.handler? with
  | none => simp [hh] at hp
  | some hi' =>
    cases hf : footprint op with
    | none => simp [hh, hf] at hp
    | some fp' =>
      simp only [hh, hf] at hp
      split at hp
      · cases hp
      split at hp
      · cases hp
      simp only [pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at hp
      rw [hp.1]

/-- A successful `opSem`, step by step. -/
theorem opSem_inv {op : Full.Opcode} {vals : Operands} {st st' : OpSem.State} {ch : OpSem.Choice}
    {c : Control} (hsem : opSem op vals st ch = .ok (c, st')) :
    ∃ h fp reads o, op.handler? = some h ∧ footprint op = some fp ∧
      readAll fp (opndVal op.info vals) st = .ok reads ∧
      kindSem h.kind h.params (mkEnv reads (opndVal op.info vals) st ch) = .ok o ∧
      commit fp (opndVal op.info vals) { st with mem := o.mem } o.writes = .ok st' ∧
      c = o.ctl := by
  unfold opSem at hsem
  cases hp : prepare op vals with
  | error e => simp [hp, bind, Except.bind] at hsem
  | ok x =>
    obtain ⟨hi, fp, val⟩ := x
    obtain ⟨hfp, rfl⟩ := prepare_ok hp
    have hh := prepare_handler hp
    simp only [hp, bind, Except.bind] at hsem
    cases hra : readAll fp (opndVal op.info vals) st with
    | error e => simp [hra] at hsem
    | ok reads =>
      simp only [hra] at hsem
      cases hk : kindSem hi.kind hi.params (mkEnv reads (opndVal op.info vals) st ch) with
      | error e => simp [hk] at hsem
      | ok o =>
        simp only [hk] at hsem
        cases hc : commit fp (opndVal op.info vals) { st with mem := o.mem } o.writes with
        | error e => simp [hc] at hsem
        | ok st1 =>
          simp only [hc, pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at hsem
          obtain ⟨rfl, rfl⟩ := hsem
          exact ⟨hi, fp, reads, o, hh, hfp, hra, hk, hc, rfl⟩

/-! ### Footprints of the inline kinds -/

theorem tySize_of_parse {ty : String} {n : Nat} {sg : Bool} (h : Ty.parse ty = some (.int n sg)) :
    tySize ty = some n := by
  simp [tySize, h, OpSem.Ty.size]

theorem intTy_of_parse {ty : String} {n : Nat} {sg : Bool} (h : Ty.parse ty = some (.int n sg)) :
    intTy (some ty) = .ok (n, sg) := by
  simp [OpSem.intTy, parseTy, h, bind, Except.bind, pure, Except.pure]

theorem footprint_eq {op : Full.Opcode} {h : Handlers.HandlerInfo} (hh : op.handler? = some h) :
    footprint op = footprintOf h.kind h.params := by
  simp [footprint, hh]

/-- `rd` (private to `Footprint.lean`) as a structure. -/
abbrev rdA (n : String) (k : Nat) : Access := ⟨n, .bytes k⟩

theorem fp_w {ty : String} {ps : List String} {n : Nat} (h : tySize ty = some n) :
    footprintOf .mov (ty :: ps) = some { reads := [rdA "s" n], writes := [rdA "d" n] } ∧
    footprintOf .imm (ty :: ps) = some { writes := [rdA "d" n] } ∧
    footprintOf .bin (ty :: ps) = some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" n] } ∧
    footprintOf .binop (ty :: ps) = some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" n] } ∧
    footprintOf .bin_imm (ty :: ps) = some { reads := [rdA "a" n], writes := [rdA "d" n] } ∧
    footprintOf .binop_imm (ty :: ps) = some { reads := [rdA "a" n], writes := [rdA "d" n] } ∧
    footprintOf .shift_imm (ty :: ps) = some { reads := [rdA "a" n], writes := [rdA "d" n] } ∧
    footprintOf .cmp (ty :: ps) = some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" 1] } ∧
    footprintOf .cmp_imm (ty :: ps) = some { reads := [rdA "a" n], writes := [rdA "d" 1] } ∧
    footprintOf .br_cmp (ty :: ps) =
      some { reads := [rdA "a" n, rdA "b" n], flow := .branch } ∧
    footprintOf .br_cmp_imm (ty :: ps) = some { reads := [rdA "a" n], flow := .branch } := by
  simp only [footprintOf, List.head?, Option.bind_some, h]
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem fp_addr (ps : List String) :
    footprintOf .addr ps = some { writes := [rdA "d" 8], addrs := ["s"] } := rfl

theorem fp_ptr_add (ps : List String) :
    footprintOf .ptr_add ps = some { reads := [rdA "p" 8], writes := [rdA "d" 8] } := rfl

theorem fp_ptr_index (ps : List String) :
    footprintOf .ptr_index ps = some { reads := [rdA "p" 8, rdA "i" 8], writes := [rdA "d" 8] } :=
  rfl

theorem fp_br (ps : List String) :
    footprintOf .br ps = some { reads := [rdA "s" 1], flow := .branch } := rfl

/-! ### Per kind -/

theorem ex_bind_ok {α β ε : Type} {x : Except ε α} {f : α → Except ε β} {b : β} :
    (x >>= f) = .ok b ↔ ∃ a, x = .ok a ∧ f a = .ok b := by
  cases x <;> simp [bind, Except.bind]

theorem ex_map_ok {α β ε : Type} {x : Except ε α} {f : α → β} {b : β} :
    (f <$> x) = .ok b ↔ ∃ a, x = .ok a ∧ f a = b := by
  cases x <;> simp [Functor.map, Except.map]

theorem ex_pure_ok {α ε : Type} {a b : α} : (pure a : Except ε α) = .ok b ↔ a = b := by
  simp [pure, Except.pure]

theorem ex_throw_ok {α ε : Type} {e : ε} {b : α} : (throw e : Except ε α) = .ok b ↔ False := by
  simp [throw, throwThe, MonadExceptOf.throw]

theorem ill_ok {α : Type} {m : String} {b : α} : (illFormed m : OpSem.M α) = .ok b ↔ False := by
  simp [illFormed, throw, throwThe, MonadExceptOf.throw]

theorem ex_ex_eq {α β : Type} {P : α → Prop} {f : α → β} {Q : β → Prop} :
    (∃ a, (∃ x, P x ∧ f x = a) ∧ Q a) ↔ ∃ x, P x ∧ Q (f x) :=
  ⟨fun ⟨_, ⟨x, hx, rfl⟩, hq⟩ => ⟨x, hx, hq⟩, fun ⟨x, hx, hq⟩ => ⟨_, ⟨x, hx, rfl⟩, hq⟩⟩

/-- Unfolds the frame reads, the kind's environment and the commit, once the footprint and
the operand list are known. -/
syntax "osimp" "[" Lean.Parser.Tactic.simpLemma,* "]" (Lean.Parser.Tactic.location)? : tactic
macro_rules
  | `(tactic| osimp [$ts,*] $[$loc]?) =>
    `(tactic| simp only [readAll, Access.range, opndVal, Val.slotOff, Extent.eval, Env.int, Env.bv,
      Env.imm, Env.immBv, Env.ptr, Env.slot, kindSem, mkEnv, out, commit, commitOne,
      List.zip_cons_cons, List.zip_nil_left, List.zip_nil_right, List.find?_cons, List.find?_nil,
      List.mapM_cons, List.mapM_nil, List.foldlM_cons, List.foldlM_nil, Option.map_some,
      Option.map_none, Option.bind_some, Option.bind_none, Option.bind_eq_bind, Option.pure_def,
      List.head?_cons, List.drop_one, List.tail_cons, bind_assoc, pure_bind, ex_bind_ok, ex_map_ok, ex_pure_ok,
      ex_throw_ok, ill_ok, String.reduceEq, String.reduceBEq, beq_self_eq_true,
      Bool.cond_true, Bool.cond_false, Bool.false_eq_true, ↓reduceIte, reduceCtorEq,
      Except.ok.injEq, exists_eq_left, exists_eq_left', exists_eq_right, exists_eq_right', exists_const,
      ex_ex_eq, exists_and_left, exists_and_right, and_true, true_and,
      List.cons.injEq, Prod.mk.injEq, and_false, false_and, exists_false, $ts,*] $[$loc]?)

theorem readFrame_length {st : OpSem.State} {o : Int} {n : Nat} {bs : List AbstractByte}
    (h : st.readFrame o n = .ok bs) : bs.length = n := by
  have := (mapM_ok h).1
  simpa using this

theorem commit_one {fp : Footprint} {val : String → Option Val} {st st' : OpSem.State}
    {nm : String} {bs : List AbstractByte} {off : Int} {n : Nat}
    (hw : fp.writes = [⟨nm, .bytes n⟩]) (hv : val nm = some (.slot off))
    (h : commit fp val st [(nm, bs)] = .ok st') : bs.length = n ∧ st.writeFrame off bs = .ok st' := by
  simp only [commit, List.foldlM_cons, List.foldlM_nil, commitOne, hw, List.find?_cons,
    beq_self_eq_true, Access.range, hv, Option.bind_some, Val.slotOff, Extent.eval,
    bind, Except.bind, pure, Except.pure] at h
  by_cases hn : bs.length = n
  · simp only [hn, ↓reduceIte] at h
    cases hw' : st.writeFrame off bs with
    | error e => simp [hw'] at h
    | ok s1 => simp only [hw', Except.ok.injEq] at h; exact ⟨hn, h ▸ rfl⟩
  · simp [hn, illFormed] at h

theorem commit_nil {fp : Footprint} {val : String → Option Val} {st st' : OpSem.State}
    (h : commit fp val st [] = .ok st') : st' = st := by
  simp [commit, pure, Except.pure] at h
  exact h.symm

/-- The kind's view of the state, for `addr`: only escapes and memory matter. -/
theorem addrOf_erase (st : OpSem.State) (s : Int) :
    ({ st with frame := fun _ => .uninit } : OpSem.State).addrOf s = st.addrOf s := rfl

set_option hygiene false in
/-- The first steps of each lemma: `opSem_inv`, the handler and footprint. -/
macro "oinv" hsem:term "," hh:term "," hfp:term : tactic =>
  `(tactic| (obtain ⟨h, fp, reads, o, hh', hfp', hra, hk, hc, rfl⟩ := opSem_inv $hsem
             rw [$hh:term] at hh'; cases hh'
             rw [footprint_eq $hh:term, $hfp:term] at hfp'
             cases hfp'))

/-- `mov` at `n` bytes: the source's bytes, moved. -/
theorem opSem_mov {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {d s : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.mov, [ty], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hsem : opSem op [.slot d, .slot s] st ch = .ok (c, st')) :
    ∃ bs, st.readFrame s n = .ok bs ∧ st.writeFrame d bs = .ok st' ∧ c = .next := by
  oinv hsem, hh, (fp_w (ps := []) (tySize_of_parse hty)).1
  osimp [ho] at hra
  obtain ⟨bs, hr, rfl⟩ := hra
  osimp [ho] at hk
  subst hk
  exact ⟨bs, hr, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `imm` at `n` bytes: the immediate's low bytes. -/
theorem opSem_imm {op : Full.Opcode} {r : Option String} {ty : String} {n : Nat} {sg : Bool}
    {k : OperandKind} {d : Int} {v : Nat} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.imm, [ty], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"imm", k⟩])
    (hsem : opSem op [.slot d, .imm v] st ch = .ok (c, st')) :
    st.writeFrame d (intBytes n v) = .ok st' ∧ c = .next := by
  oinv hsem, hh, (fp_w (ps := []) (tySize_of_parse hty)).2.1
  osimp [ho] at hra
  subst hra
  osimp [ho, intTy_of_parse hty] at hk
  subst hk
  exact ⟨(commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `addr`: the pointer to the slot, which must be escaped. -/
theorem opSem_addr {op : Full.Opcode} {r : Option String} {ps : List String}
    {d s : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.addr, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hsem : opSem op [.slot d, .slot s] st ch = .ok (c, st')) :
    ∃ p, st.addrOf s = .ok p ∧ st.writeFrame d (encodePtr p) = .ok st' ∧ c = .next := by
  oinv hsem, hh, fp_addr ps
  osimp [ho] at hra
  subst hra
  osimp [ho, addrOf_erase] at hk
  obtain ⟨p, hp, rfl⟩ := hk
  exact ⟨p, hp, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `ptr.add`: the pointer in `p`, offset by the immediate (wrapping), provenance kept. -/
theorem opSem_ptrAdd {op : Full.Opcode} {r : Option String} {ps : List String}
    {d p : Int} {v : Nat} {k : OperandKind} {st st' : OpSem.State} {ch : OpSem.Choice}
    {c : Control} (hh : op.handler? = some ⟨.ptr_add, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"imm", k⟩])
    (hsem : opSem op [.slot d, .slot p, .imm v] st ch = .ok (c, st')) :
    ∃ bs q, st.readFrame p 8 = .ok bs ∧ asPtr bs = .ok q ∧
      st.writeFrame d (encodePtr (q.wrappingOffset (BitVec.ofNat 64 v).toInt)) = .ok st' ∧
      c = .next := by
  oinv hsem, hh, fp_ptr_add ps
  osimp [ho] at hra
  obtain ⟨bs, hr, rfl⟩ := hra
  osimp [ho] at hk
  obtain ⟨q, hq, rfl⟩ := hk
  exact ⟨bs, q, hr, hq, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `ptr.index`: the pointer in `p`, offset by `i × stride` (wrapping), provenance kept. -/
theorem opSem_ptrIndex {op : Full.Opcode} {r : Option String} {ps : List String}
    {d p i : Int} {v : Nat} {k : OperandKind} {st st' : OpSem.State} {ch : OpSem.Choice}
    {c : Control} (hh : op.handler? = some ⟨.ptr_index, ps, r⟩)
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"p", .slot⟩, ⟨"i", .slot⟩, ⟨"stride", k⟩])
    (hsem : opSem op [.slot d, .slot p, .slot i, .imm v] st ch = .ok (c, st')) :
    ∃ bp bi q x, st.readFrame p 8 = .ok bp ∧ st.readFrame i 8 = .ok bi ∧ asPtr bp = .ok q ∧
      asNat bi = .ok x ∧
      st.writeFrame d (encodePtr (q.wrappingOffset ((x * v) % 2 ^ 64 : Nat))) = .ok st' ∧
      c = .next := by
  oinv hsem, hh, fp_ptr_index ps
  osimp [ho] at hra
  obtain ⟨bp, hp, bi, hi, rfl⟩ := hra
  osimp [ho] at hk
  obtain ⟨q, hq, x, hx, rfl⟩ := hk
  exact ⟨bp, bi, q, x, hp, hi, hq, hx, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `bin`/`binop` at `n` bytes: both operands as integers, the method's result. -/
theorem opSem_bin {op : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String}
    {ty m : String} {n : Nat} {sg : Bool} {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    {c : Control} (hkd : kd = .bin ∨ kd = .binop) (hh : op.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hsem : opSem op [.slot d, .slot a, .slot b] st ch = .ok (c, st')) :
    ∃ ba bb va vb res, st.readFrame a n = .ok ba ∧ st.readFrame b n = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      intBin m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res ∧
      st.writeFrame d (intBytes n res.toNat) = .ok st' ∧ c = .next := by
  have hfp : footprintOf kd [ty, m] =
      some { reads := [rdA "a" n, rdA "b" n], writes := [rdA "d" n] } := by
    rcases hkd with rfl | rfl
    · exact (fp_w (tySize_of_parse hty)).2.2.1
    · exact (fp_w (tySize_of_parse hty)).2.2.2.1
  oinv hsem, hh, hfp
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  have hk' : kindSem .bin [ty, m] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b]) st ch) = .ok o := by
    rcases hkd with rfl | rfl
    · exact hk
    · simpa [kindSem] using hk
  osimp [ho, intTy_of_parse hty] at hk'
  obtain ⟨va, hva, vb, hvb, res, hres, rfl⟩ := hk'
  exact ⟨ba, bb, va, vb, res, hra', hrb, hva, hvb, hres,
    (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `bin_imm`/`binop_imm`/`shift_imm` at `n` bytes: the operand as an integer, the immediate's
low bits, the method's result. -/
theorem opSem_binImm {op : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String}
    {ty m : String} {n : Nat} {sg : Bool} {k : OperandKind} {d a : Int} {v : Nat}
    {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hkd : kd = .bin_imm ∨ kd = .binop_imm ∨ kd = .shift_imm)
    (hh : op.handler? = some ⟨kd, [ty, m], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    (hsem : opSem op [.slot d, .slot a, .imm v] st ch = .ok (c, st')) :
    ∃ ba va res, st.readFrame a n = .ok ba ∧ asNat ba = .ok va ∧
      intBin m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) v) = .ok res ∧
      st.writeFrame d (intBytes n res.toNat) = .ok st' ∧ c = .next := by
  have hfp : footprintOf kd [ty, m] = some { reads := [rdA "a" n], writes := [rdA "d" n] } := by
    rcases hkd with rfl | rfl | rfl
    · exact (fp_w (tySize_of_parse hty)).2.2.2.2.1
    · exact (fp_w (tySize_of_parse hty)).2.2.2.2.2.1
    · exact (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.1
  oinv hsem, hh, hfp
  osimp [ho] at hra
  obtain ⟨ba, hra', rfl⟩ := hra
  have hk' : kindSem .bin_imm [ty, m] (mkEnv [("a", ba)]
      (opndVal op.info [.slot d, .slot a, .imm v]) st ch) = .ok o := by
    rcases hkd with rfl | rfl | rfl
    · exact hk
    · simpa [kindSem] using hk
    · simpa [kindSem] using hk
  osimp [ho, intTy_of_parse hty] at hk'
  obtain ⟨va, hva, res, hres, rfl⟩ := hk'
  exact ⟨ba, va, res, hra', hva, hres, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `cmp` at `n` bytes: the comparison, as a byte. -/
theorem opSem_cmp {op : Full.Opcode} {r : Option String} {ty o' : String} {n : Nat} {sg : Bool}
    {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.cmp, [ty, o'], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hsem : opSem op [.slot d, .slot a, .slot b] st ch = .ok (c, st')) :
    ∃ ba bb va vb res, st.readFrame a n = .ok ba ∧ st.readFrame b n = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      intCmp o' sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res ∧
      st.writeFrame d (boolByte res) = .ok st' ∧ c = .next := by
  oinv hsem, hh, (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.2.1
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, vb, hvb, res, hres, rfl⟩ := hk
  exact ⟨ba, bb, va, vb, res, hra', hrb, hva, hvb, hres,
    (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `cmp_imm` at `n` bytes: the comparison with the immediate's low bits, as a byte. -/
theorem opSem_cmpImm {op : Full.Opcode} {r : Option String} {ty o' : String} {n : Nat}
    {sg : Bool} {k : OperandKind} {d a : Int} {v : Nat} {st st' : OpSem.State}
    {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.cmp_imm, [ty, o'], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"imm", k⟩])
    (hsem : opSem op [.slot d, .slot a, .imm v] st ch = .ok (c, st')) :
    ∃ ba va res, st.readFrame a n = .ok ba ∧ asNat ba = .ok va ∧
      intCmp o' sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) v) = .ok res ∧
      st.writeFrame d (boolByte res) = .ok st' ∧ c = .next := by
  oinv hsem, hh, (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.2.2.1
  osimp [ho] at hra
  obtain ⟨ba, hra', rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, res, hres, rfl⟩ := hk
  exact ⟨ba, va, res, hra', hva, hres, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

/-- `br`: branch on the byte being non-zero; the frame unchanged. -/
theorem opSem_br {op : Full.Opcode} {r : Option String} {ps : List String} {s : Int}
    {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.br, ps, r⟩)
    (ho : op.info.operands = [⟨"s", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩])
    (hsem : opSem op [.slot s, .none, .none] st ch = .ok (c, st')) :
    ∃ bs v, st.readFrame s 1 = .ok bs ∧ asNat bs = .ok v ∧ c = .branch (v != 0) ∧ st' = st := by
  oinv hsem, hh, fp_br ps
  osimp [ho] at hra
  obtain ⟨bs, hr, rfl⟩ := hra
  osimp [ho] at hk
  obtain ⟨v, hv, rfl⟩ := hk
  exact ⟨bs, v, hr, hv, rfl, commit_nil hc⟩

/-- `br_cmp` at `n` bytes: branch on the comparison; the frame unchanged. -/
theorem opSem_brCmp {op : Full.Opcode} {r : Option String} {ty o' : String} {n : Nat} {sg : Bool}
    {a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.br_cmp, [ty, o'], r⟩) (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"a", .slot⟩, ⟨"b", .slot⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩])
    (hsem : opSem op [.slot a, .slot b, .none, .none] st ch = .ok (c, st')) :
    ∃ ba bb va vb res, st.readFrame a n = .ok ba ∧ st.readFrame b n = .ok bb ∧
      asNat ba = .ok va ∧ asNat bb = .ok vb ∧
      intCmp o' sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res ∧
      c = .branch res ∧ st' = st := by
  oinv hsem, hh, (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.2.2.2.1
  osimp [ho] at hra
  obtain ⟨ba, hra', bb, hrb, rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, vb, hvb, res, hres, rfl⟩ := hk
  exact ⟨ba, bb, va, vb, res, hra', hrb, hva, hvb, hres, rfl, commit_nil hc⟩

/-- `br_cmp_imm` at `n` bytes: branch on the comparison with the immediate; the frame
unchanged. -/
theorem opSem_brCmpImm {op : Full.Opcode} {r : Option String} {ty o' : String} {n : Nat}
    {sg : Bool} {k : OperandKind} {a : Int} {v : Nat} {st st' : OpSem.State} {ch : OpSem.Choice}
    {c : Control} (hh : op.handler? = some ⟨.br_cmp_imm, [ty, o'], r⟩)
    (hty : Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"a", .slot⟩, ⟨"imm", k⟩, ⟨"neg", .neg⟩, ⟨"t", .target⟩])
    (hsem : opSem op [.slot a, .imm v, .none, .none] st ch = .ok (c, st')) :
    ∃ ba va res, st.readFrame a n = .ok ba ∧ asNat ba = .ok va ∧
      intCmp o' sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) v) = .ok res ∧
      c = .branch res ∧ st' = st := by
  oinv hsem, hh, (fp_w (tySize_of_parse hty)).2.2.2.2.2.2.2.2.2.2
  osimp [ho] at hra
  obtain ⟨ba, hra', rfl⟩ := hra
  osimp [ho, intTy_of_parse hty] at hk
  obtain ⟨va, hva, res, hres, rfl⟩ := hk
  exact ⟨ba, va, res, hra', hva, hres, rfl, commit_nil hc⟩

theorem fp_cvt {tx ty : String} {nx ny : Nat} (hx : tySize tx = some nx) (hy : tySize ty = some ny) :
    footprintOf .cvt [tx, ty] = some { reads := [rdA "s" nx], writes := [rdA "d" ny] } := by
  simp only [footprintOf, List.head?, Option.bind_some, hx, List.drop_one, List.tail_cons, hy]
  rfl

/-- `cvt` between integer types: the source as an integer (sign-extended if signed), wrapped
to the destination's width. -/
theorem opSem_ext {op : Full.Opcode} {r : Option String} {tx ty : String} {nx ny : Nat}
    {sx sy : Bool} {d s : Int} {st st' : OpSem.State} {ch : OpSem.Choice} {c : Control}
    (hh : op.handler? = some ⟨.cvt, [tx, ty], r⟩) (htx : Ty.parse tx = some (.int nx sx))
    (hty : Ty.parse ty = some (.int ny sy))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hsem : opSem op [.slot d, .slot s] st ch = .ok (c, st')) :
    ∃ bs v, st.readFrame s nx = .ok bs ∧ asNat bs = .ok v ∧
      st.writeFrame d (intBytes ny (BitVec.ofInt (8 * ny)
        (if sx then (BitVec.ofNat (8 * nx) v).toInt else (v : Int))).toNat) = .ok st' ∧
      c = .next := by
  oinv hsem, hh, fp_cvt (tySize_of_parse htx) (tySize_of_parse hty)
  osimp [ho] at hra
  obtain ⟨bs, hr, rfl⟩ := hra
  osimp [ho, parseTy, htx, hty, convert, OpSem.Ty.size] at hk
  obtain ⟨v, hv, rfl⟩ := hk
  exact ⟨bs, v, hr, hv, (commit_one (off := d) rfl (by simp [opndVal, ho]) hc).2, rfl⟩

end Ryo.Proofs.Inline
