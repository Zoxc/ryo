/-
Ryo.Proofs.Lower.SimNicheRead — the simulation of `LowerNicheRead` (`Check/Lower/NicheRead.lean`,
M5b): `_d = discriminant(_e)` at a niche-encoded tag, lowered to `nicheProg`'s plain integer
instructions.

- The ops' meaning (`NOp.val`): each computes its destination's value from its sources' in an
  environment `E` (slot offset to value, `none` while unwritten) as `BitVec` arithmetic.
  `nop_step`: R's instruction for the op writes bytes `wb` decoding to that value to the
  destination, and nothing else (the family checkers' forms and the `_fwd` lemmas: `cmp_imm`,
  `bin_imm`, `bin`, `un`, unsigned `cvt`, `mov`).
- `prog_run`: R's run of a list of such instructions keeps `EnvAt` (each written slot holds its
  value's bytes) and `FnRel` at a liveness where no written slot meets a live local's slot
  (`FnRel.writePriv`: a private write keeps every non-live local whatever it overlaps, and the
  live ones it doesn't).
- `evalNiche`: `nicheProg`'s ops compute `nicheDiscr` (`Proofs/NicheDiscr.lean`) of the tag;
  `nicheDiscr_sound` makes that the variant index `tagToVariant` decodes, which
  `discrIdxAgree` makes L0's discriminant at `_d`'s width.
- `lift_nicheRead`: every op but the last (which writes `_d`) by `prog_run` at the liveness
  without `_d`; the last as a single-instruction lift (`writeLocal_priv`, `FnRel.after`).
-/
import Ryo.Proofs.Lower.SimNiche
import Ryo.Proofs.Lower.SimDiscrPlace
import Ryo.Proofs.Lower.SimUnop
import Ryo.Proofs.Lower.SimBinX
import Ryo.Proofs.Lower.SimIntCast
import Ryo.Proofs.Lower.SimSwitchStatic
import Ryo.Proofs.NicheDiscr
import Ryo.Check.Lower.NicheRead

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The ops' meaning -/

/-- The comparisons the decoding uses. -/
def cmpPure (o : String) {w : Nat} (x y : BitVec w) : Option Bool :=
  if o = "==" then some (x == y) else if o = "!=" then some (x != y)
  else if o = "<=" then some (x.ule y) else none

/-- The binary methods the decoding uses. -/
def binPure (m : String) {w : Nat} (x y : BitVec w) : Option (BitVec w) :=
  if m = "wrapping_add" then some (x + y) else if m = "wrapping_sub" then some (x - y)
  else if m = "&" then some (x &&& y) else if m = "^" then some (x ^^^ y) else none

/-- The unary method the decoding uses. -/
def unPure (m : String) {w : Nat} (x : BitVec w) : Option (BitVec w) :=
  if m = "wrapping_neg" then some (-x) else none

theorem cmpPure_intCmp {o : String} {s : Bool} {w : Nat} {x y : BitVec w} {b : Bool}
    (h : cmpPure o x y = some b) (hs : (o = "==" ∨ o = "!=") ∨ s = false) :
    intCmp o s x y = .ok b := by
  unfold cmpPure at h
  by_cases h1 : o = "=="
  · subst h1
    rw [if_pos rfl] at h
    cases h
    rfl
  · rw [if_neg h1] at h
    by_cases h2 : o = "!="
    · subst h2
      rw [if_pos rfl] at h
      cases h
      rfl
    · rw [if_neg h2] at h
      by_cases h3 : o = "<="
      · subst h3
        rw [if_pos rfl] at h
        cases h
        rcases hs with (e | e) | rfl
        · exact absurd e h1
        · exact absurd e h2
        · rfl
      · rw [if_neg h3] at h
        cases h

theorem binPure_intBin {m : String} {w : Nat} {x y r : BitVec w} (h : binPure m x y = some r)
    (sg : Bool) : intBin m sg x y = .ok r := by
  unfold binPure at h
  by_cases h1 : m = "wrapping_add"
  · subst h1; rw [if_pos rfl] at h; cases h; rfl
  · rw [if_neg h1] at h
    by_cases h2 : m = "wrapping_sub"
    · subst h2; rw [if_pos rfl] at h; cases h; rfl
    · rw [if_neg h2] at h
      by_cases h3 : m = "&"
      · subst h3; rw [if_pos rfl] at h; cases h; rfl
      · rw [if_neg h3] at h
        by_cases h4 : m = "^"
        · subst h4; rw [if_pos rfl] at h; cases h; rfl
        · rw [if_neg h4] at h; cases h

theorem unPure_intUn {m : String} {w : Nat} {x r : BitVec w} (h : unPure m x = some r) :
    intUn m x = .ok r := by
  unfold unPure at h
  by_cases h1 : m = "wrapping_neg"
  · subst h1; rw [if_pos rfl] at h; cases h; rfl
  · rw [if_neg h1] at h; cases h

/-- An op's destination slot and width. -/
def _root_.Ryo.Check.Lower.NOp.dst : NOp → Int × Nat
  | .cmpImm _ _ d _ _ => (d, 1)
  | .binImm _ n d _ _ => (d, n)
  | .bin _ n d _ _ => (d, n)
  | .un _ n d _ => (d, n)
  | .cvt _ ny d _ => (d, ny)
  | .mov n d _ => (d, n)

/-- An op's source slots and widths. -/
def _root_.Ryo.Check.Lower.NOp.srcs : NOp → List (Int × Nat)
  | .cmpImm _ n _ a _ => [(a, n)]
  | .binImm _ n _ a _ => [(a, n)]
  | .bin _ n _ a b => [(a, n), (b, n)]
  | .un _ n _ a => [(a, n)]
  | .cvt nx _ _ s => [(s, nx)]
  | .mov n _ s => [(s, n)]

/-- The value an op writes, from the environment's values of its sources. -/
def _root_.Ryo.Check.Lower.NOp.val (E : Int → Option Nat) : NOp → Option Nat
  | .cmpImm o n _ a imm => (E a).bind fun x =>
    (cmpPure o (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) imm)).map
      fun b => if b then 1 else 0
  | .binImm m n _ a imm => (E a).bind fun x =>
    (binPure m (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) imm)).map BitVec.toNat
  | .bin m n _ a b => (E a).bind fun x => (E b).bind fun y =>
    (binPure m (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) y)).map BitVec.toNat
  | .un m n _ a => (E a).bind fun x => (unPure m (BitVec.ofNat (8 * n) x)).map BitVec.toNat
  | .cvt nx ny _ s => (E s).map (cvtInt nx false ny)
  | .mov _ _ s => E s

/-- The environment with slot `o` set to `v`. -/
def envUpd (E : Int → Option Nat) (o : Int) (v : Nat) : Int → Option Nat :=
  fun o' => if o' = o then some v else E o'

/-- The ops run in order on the environment. -/
def evalProg : (Int → Option Nat) → List NOp → Option (Int → Option Nat)
  | E, [] => some E
  | E, op :: ops =>
    match op.val E with
    | some v => evalProg (envUpd E op.dst.1 v) ops
    | none => none

theorem evalProg_append : ∀ (E : Int → Option Nat) (l1 l2 : List NOp),
    evalProg E (l1 ++ l2) = (evalProg E l1).bind fun E1 => evalProg E1 l2
  | E, [], l2 => rfl
  | E, op :: l1, l2 => by
    simp only [List.cons_append, evalProg]
    cases op.val E with
    | none => rfl
    | some v => exact evalProg_append _ l1 l2

/-- Each written slot of `W` holds its value's bytes in R's frame. -/
def EnvAt (st : OpSem.State) (E : Int → Option Nat) (W : List (Int × Nat)) : Prop :=
  ∀ p ∈ W, ∀ x, E p.1 = some x → ∃ bs, st.readFrame p.1 p.2 = .ok bs ∧ asNat bs = .ok x ∧
    bs.length = p.2 ∧ x < 2 ^ (8 * p.2)

theorem asNat_intBytes_lt {n x : Nat} (h : x < 2 ^ (8 * n)) : asNat (intBytes n x) = .ok x := by
  have hd : decodeBits (intBytes n x) = some x := by
    show decodeBits (encodeBits n x) = some x
    rw [Ryo.Spec.Theorems.decodeBits_encodeBits, Nat.mod_eq_of_lt h]
  unfold asNat; rw [hd] <;> rfl

theorem decodeBits_of_asNat {bs : List AbstractByte} {x : Nat} (h : asNat bs = .ok x) :
    decodeBits bs = some x := by
  unfold asNat at h
  split at h
  next n hn => cases h; exact hn
  next => cases h

theorem intBytes_length (n x : Nat) : (intBytes n x).length = n :=
  Ryo.Spec.Theorems.encodeBits_length n x

/-- An unsigned `cvt`'s facts. -/
theorem cvtUOk_spec {Γ : StmtCtx} {i : R.Insn} {nx ny : Nat} {d s : Int}
    (h : cvtUOk Γ i nx ny d s = true) :
    ∃ v tx ty r sy, R.view Γ.mode Γ.ρ i = some v ∧ v.op.handler? = some ⟨.cvt, [tx, ty], r⟩ ∧
      OpSem.Ty.parse tx = some (.int nx false) ∧ OpSem.Ty.parse ty = some (.int ny sy) ∧
      v.op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩] ∧ v.ops = [.slot d, .slot s] ∧
      v.ctl = some .next := by
  unfold cvtUOk at h
  split at h
  next v hv =>
    split at h
    next kd tx ty r hh =>
      split at h
      next nx' sx ny' sy htx hty =>
        simp only [Bool.and_eq_true, beq_iff_eq] at h
        obtain ⟨⟨⟨⟨⟨⟨hkd, h1⟩, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := h
        subst hkd h1 h2 h3
        exact ⟨v, tx, ty, r, sy, hv, hh, htx, hty, h4, h5, h6⟩
      next => cases h
    next => cases h
  next => cases h

theorem ofNat_eq_of_mod {w a b : Nat} (h : a % 2 ^ w = b % 2 ^ w) :
    BitVec.ofNat w a = BitVec.ofNat w b := by
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_ofNat, BitVec.toNat_ofNat, h]

/-- R's instruction for an op: it writes bytes `wb` of the op's value, and its `opSem` is that
write (see the module comment). -/
theorem nop_step {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} (hmode : Γ.mode = c.mode)
    (hρ : Γ.ρ = c.ρ) {i : R.Insn} {op : NOp} (hok : op.insnOk Γ i = true)
    (hpl : PlainView c.mode c.ρ i) {st : OpSem.State} {E : Int → Option Nat}
    (hsrc : ∀ p ∈ op.srcs, ∀ x, E p.1 = some x → ∃ bs, st.readFrame p.1 p.2 = .ok bs ∧
      asNat bs = .ok x ∧ bs.length = p.2 ∧ x < 2 ^ (8 * p.2))
    (hofs : ∀ p ∈ op.dst :: op.srcs, -2 ^ 31 ≤ p.1 ∧ p.1 < 2 ^ 31)
    {v : Nat} (hv : op.val E = some v) :
    ∃ wb, wb.length = op.dst.2 ∧ asNat wb = .ok v ∧ v < 2 ^ (8 * op.dst.2) ∧
      ∀ st', st.writeFrame op.dst.1 wb = .ok st' →
        ∃ vw, R.view c.mode c.ρ i = some vw ∧ vw.ctl = some .next ∧
          opSem vw.op vw.ops st ch = .ok (.next, st') := by
  cases op with
  | cmpImm o n d a imm =>
    simp only [NOp.insnOk] at hok
    obtain ⟨vw, ty, r, hvw, hh, hty, hn, hk, hops, hctl⟩ := cmpImmInsnOk_spec hok
    rw [hmode, hρ] at hvw
    obtain ⟨sg, hps, hsg⟩ := cmpTyOk_spec hty
    obtain ⟨y, hops', hy⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands3 hn hk
    have hops'' : vw.ops = [.slot d, .slot a, .imm y] := hops'
    have hfk : Val.fits k (.imm y) = true :=
      fits_last (hpl.fits vw hvw) (by rw [ho, hops'']; simp)
    cases hx : E a with
    | none => simp [NOp.val, hx] at hv
    | some x =>
      cases hb : cmpPure o (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) imm) with
      | none => simp [NOp.val, hx, hb] at hv
      | some b =>
        simp only [NOp.val, hx, hb, Option.bind_some, Option.map_some, Option.some.injEq] at hv
        subst hv
        obtain ⟨ba, hra, hva, -, -⟩ := hsrc (a, n) (by simp [NOp.srcs]) x hx
        have hd := hofs (d, 1) (by simp [NOp.dst])
        have ha := hofs (a, n) (by simp [NOp.srcs])
        have hye : BitVec.ofNat (8 * n) y = BitVec.ofNat (8 * n) imm := ofNat_eq_of_mod hy
        have hres : intCmp o sg (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) y) = .ok b := by
          rw [hye]
          exact cmpPure_intCmp hb (hsg.imp_right fun e => e)
        refine ⟨intBytes 1 (if b then 1 else 0), intBytes_length _ _,
          asNat_intBytes_lt (by cases b <;> decide),
          (by show (if b then 1 else 0) < 2 ^ (8 * 1); cases b <;> decide), ?_⟩
        intro st' hw
        exact ⟨vw, hvw, hctl, by
          rw [hops'']
          exact opSem_cmpImm_fwd hh hps ho ⟨hd.1, hd.2, ha.1, ha.2⟩ hfk hra hva hres hw⟩
  | binImm m n d a imm =>
    simp only [NOp.insnOk] at hok
    obtain ⟨vw, kd, ty, r, hvw, hh, hkd, hty, hn, hk, hops, hctl⟩ := binImmInsnOk_spec hok
    rw [hmode, hρ] at hvw
    obtain ⟨sg, hps⟩ := intTyOk_spec hty
    obtain ⟨y, hops', hy⟩ := immOpsOk_spec hops
    obtain ⟨k, ho⟩ := operands3 hn hk
    have hops'' : vw.ops = [.slot d, .slot a, .imm y] := hops'
    have hfk : Val.fits k (.imm y) = true :=
      fits_last (hpl.fits vw hvw) (by rw [ho, hops'']; simp)
    have hkd' : binImmKd kd = true := by rcases hkd with rfl | rfl <;> rfl
    cases hx : E a with
    | none => simp [NOp.val, hx] at hv
    | some x =>
      cases hb : binPure m (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) imm) with
      | none => simp [NOp.val, hx, hb] at hv
      | some res =>
        simp only [NOp.val, hx, hb, Option.bind_some, Option.map_some, Option.some.injEq] at hv
        subst hv
        obtain ⟨ba, hra, hva, -, -⟩ := hsrc (a, n) (by simp [NOp.srcs]) x hx
        have hd := hofs (d, n) (by simp [NOp.dst])
        have ha := hofs (a, n) (by simp [NOp.srcs])
        have hye : BitVec.ofNat (8 * n) y = BitVec.ofNat (8 * n) imm := ofNat_eq_of_mod hy
        have hres : intBin m sg (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) y) = .ok res := by
          rw [hye]; exact binPure_intBin hb sg
        refine ⟨intBytes n res.toNat, intBytes_length _ _, asNat_intBytes_lt res.isLt, res.isLt, ?_⟩
        intro st' hw
        exact ⟨vw, hvw, hctl, by
          rw [hops'']
          exact opSem_binImmX_fwd hkd' hh hps ho ⟨hd.1, hd.2, ha.1, ha.2⟩ hfk hra hva hres hw⟩
  | bin m n d a b =>
    simp only [NOp.insnOk] at hok
    obtain ⟨vw, kd, ty, r, hvw, hh, hkd, hty, ho, hops, hctl⟩ := binInsnOk_spec hok
    rw [hmode, hρ] at hvw
    obtain ⟨sg, hps⟩ := intTyOk_spec hty
    cases hx : E a with
    | none => simp [NOp.val, hx] at hv
    | some x =>
      cases hy : E b with
      | none => simp [NOp.val, hx, hy] at hv
      | some y =>
        cases hb : binPure m (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) y) with
        | none => simp [NOp.val, hx, hy, hb] at hv
        | some res =>
          simp only [NOp.val, hx, hy, hb, Option.bind_some, Option.map_some,
            Option.some.injEq] at hv
          subst hv
          obtain ⟨ba, hra, hva, -, -⟩ := hsrc (a, n) (by simp [NOp.srcs]) x hx
          obtain ⟨bb, hrb, hvb, -, -⟩ := hsrc (b, n) (by simp [NOp.srcs]) y hy
          have hd := hofs (d, n) (by simp [NOp.dst])
          have ha := hofs (a, n) (by simp [NOp.srcs])
          have hb' := hofs (b, n) (by simp [NOp.srcs])
          refine ⟨intBytes n res.toNat, intBytes_length _ _, asNat_intBytes_lt res.isLt, res.isLt,
            ?_⟩
          intro st' hw
          exact ⟨vw, hvw, hctl, by
            rw [hops]
            exact opSem_bin_fwd hkd hh hps ho ⟨hd.1, hd.2, ha.1, ha.2, hb'.1, hb'.2⟩ hra hrb hva
              hvb (binPure_intBin hb sg) hw⟩
  | un m n d a =>
    simp only [NOp.insnOk] at hok
    obtain ⟨vw, ty, r, hvw, hh, hty, ho, hops, hctl⟩ := unInsnOk_spec hok
    rw [hmode, hρ] at hvw
    obtain ⟨sg, hps⟩ := intTyOk_spec hty
    cases hx : E a with
    | none => simp [NOp.val, hx] at hv
    | some x =>
      cases hb : unPure m (BitVec.ofNat (8 * n) x) with
      | none => simp [NOp.val, hx, hb] at hv
      | some res =>
        simp only [NOp.val, hx, hb, Option.bind_some, Option.map_some, Option.some.injEq] at hv
        subst hv
        obtain ⟨ba, hra, hva, -, -⟩ := hsrc (a, n) (by simp [NOp.srcs]) x hx
        have hd := hofs (d, n) (by simp [NOp.dst])
        have ha := hofs (a, n) (by simp [NOp.srcs])
        refine ⟨intBytes n res.toNat, intBytes_length _ _, asNat_intBytes_lt res.isLt, res.isLt, ?_⟩
        intro st' hw
        exact ⟨vw, hvw, hctl, by
          rw [hops]
          exact opSem_un_fwd hh hps ho ⟨hd.1, hd.2, ha.1, ha.2⟩ hra hva (unPure_intUn hb) hw⟩
  | cvt nx ny d s =>
    simp only [NOp.insnOk] at hok
    obtain ⟨vw, tx, ty, r, sy, hvw, hh, htx, hty, ho, hops, hctl⟩ := cvtUOk_spec hok
    rw [hmode, hρ] at hvw
    cases hx : E s with
    | none => simp [NOp.val, hx] at hv
    | some x =>
      simp only [NOp.val, hx, Option.map_some, Option.some.injEq] at hv
      subst hv
      obtain ⟨ba, hra, hva, -, -⟩ := hsrc (s, nx) (by simp [NOp.srcs]) x hx
      have hd := hofs (d, ny) (by simp [NOp.dst])
      have hs' := hofs (s, nx) (by simp [NOp.srcs])
      have hlt : cvtInt nx false ny x < 2 ^ (8 * ny) := BitVec.isLt _
      refine ⟨intBytes ny (cvtInt nx false ny x), intBytes_length _ _, asNat_intBytes_lt hlt, hlt,
        ?_⟩
      intro st' hw
      exact ⟨vw, hvw, hctl, by
        rw [hops]
        exact opSem_cvt_fwd hh htx hty ho ⟨hd.1, hd.2, hs'.1, hs'.2⟩ hra hva hw⟩
  | mov n d s =>
    simp only [NOp.insnOk] at hok
    obtain ⟨vw, ty, r, hvw, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hok
    rw [hmode, hρ] at hvw
    obtain ⟨sg, hps⟩ := intTyOk_spec hty
    simp only [NOp.val] at hv
    obtain ⟨ba, hra, hva, hla, hlt⟩ := hsrc (s, n) (by simp [NOp.srcs]) v hv
    have hd := hofs (d, n) (by simp [NOp.dst])
    have hs' := hofs (s, n) (by simp [NOp.srcs])
    refine ⟨ba, hla, hva, hlt, ?_⟩
    intro st' hw
    exact ⟨vw, hvw, hctl, by
      rw [hops]
      exact opSem_mov_fwd hh hps ho ⟨hd.1, hd.2, hs'.1, hs'.2⟩ hra hla hw⟩

/-! ### Runs of ops -/

theorem mapM_congr_mem {α β : Type} {f g : α → OpSem.M β} :
    ∀ (l : List α), (∀ x ∈ l, f x = g x) → l.mapM f = l.mapM g
  | [], _ => rfl
  | x :: l, h => by
    rw [List.mapM_cons, List.mapM_cons, h x (List.mem_cons_self ..),
      mapM_congr_mem l (fun y hy => h y (List.mem_cons_of_mem _ hy))]

/-- A private frame write leaves a read of bytes it doesn't meet. -/
theorem readFrame_write_apart {st st' : OpSem.State} {a : Int} {bs : List AbstractByte}
    (hw : st.writeFrame a bs = .ok st') (hp : ∀ k < bs.length, st.escapedAt (a + k) = none)
    {o : Int} {n : Nat} (hap : a + bs.length ≤ o ∨ o + n ≤ a) :
    st'.readFrame o n = st.readFrame o n := by
  obtain ⟨hmem, hea, hfr⟩ := writeFrame_private_eq hw hp
  unfold OpSem.State.readFrame
  apply mapM_congr_mem
  intro i hi
  have hi' := List.mem_range.mp hi
  have hnp : st.privateIn a bs.length (o + i) = false := by
    simp only [OpSem.State.privateIn, Bool.and_eq_false_iff, decide_eq_false_iff_not]
    left
    omega
  unfold OpSem.State.byteAt
  rw [hea, hmem, hfr, hnp] <;> rfl

/-- `FnRel` after a private frame write that meets no live local's slot: the non-live ones owe no
bytes, whatever the write overlaps. -/
theorem FnRel.writePriv {Γ : StmtCtx} {ι : Inj} {live : Local → Bool} {f : Spec.Frame}
    {m0 : Memory} {s1 : R.RState} (hrel : FnRel Γ ι live f m0 s1) {a : Int}
    {bs : List AbstractByte} {st' : OpSem.State} (hwr : s1.st.writeFrame a bs = .ok st')
    (hpw : ∀ k < bs.length, s1.st.escapedAt (a + k) = none)
    (hap : ∀ (l : Local) (q : ThinPointer) (sl : LocalSlot), f.locals[l]? = some (some q) →
      Γ.slots[l]? = some sl → live l = true → a + bs.length ≤ sl.off ∨ sl.off + sl.size ≤ a)
    (pc' : Nat) : FnRel Γ ι live f m0 { s1 with pc := pc', st := st' } := by
  obtain ⟨hmem, hea, -⟩ := writeFrame_private_eq hwr hpw
  refine ⟨⟨?_, ?_⟩, hrel.hidden, hrel.unaliased, hrel.provNe, hrel.apart, ?_⟩
  · show MemInj ι m0 st'.mem
    rw [hmem]
    exact hrel.frame.mem
  · intro l q hq hal
    obtain ⟨slot, hsl, hr⟩ := hrel.frame.locals l q hq hal
    refine ⟨slot, hsl, ?_⟩
    cases hlv : live l
    · rw [hlv] at hr
      cases hr with
      | priv a' x hp hι hx hlive haddr hpaddr hsize hpv _ =>
        exact .priv a' x hp hι hx hlive haddr hpaddr hsize (fun k hk => (hea _).trans (hpv k hk))
          (fun h => by cases h)
      | esc a' x e y hp hι hx hlive haddr hpaddr hsize hin hy hylive hyaddr hysize =>
        exact .esc a' x e y hp hι hx hlive haddr hpaddr hsize
          (fun k hk => (hea _).trans (hin k hk)) (by rw [hmem]; exact hy) hylive hyaddr hysize
    · rw [hlv] at hr
      exact LocalRel.writeFrame_apart hr hwr hpw (hap l q slot hq hsl hlv)
  · intro o e he
    apply hrel.esc o e
    have h2 : st'.escapedAt o = some e := he
    rw [hea] at h2
    exact h2

/-- R's run of instructions that are ops (see the module comment): each op's destination is in
`DW` (private, apart from every other slot of `W` and from every live local's slot), its sources
in `W`. -/
theorem prog_run {Γ : StmtCtx} {c : R.Code} {ch : OpSem.Choice} {ι : Inj} {live : Local → Bool}
    {f : Spec.Frame} {m0 : Memory} (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {W DW : List (Int × Nat)} (hpos : ∀ p ∈ W, 0 < p.2)
    (hofs : ∀ p ∈ W, -2 ^ 31 ≤ p.1 ∧ p.1 < 2 ^ 31) (hDW : ∀ q ∈ DW, q ∈ W)
    (hap : ∀ q ∈ DW, ∀ p ∈ W, p ≠ q → q.1 + q.2 ≤ p.1 ∨ p.1 + p.2 ≤ q.1)
    (hpriv : ∀ q ∈ DW, ∀ k < q.2, Γ.escaped (q.1 + k) = false)
    (hlv : ∀ q ∈ DW, ∀ (l : Local) (p : ThinPointer) (sl : LocalSlot),
      f.locals[l]? = some (some p) → Γ.slots[l]? = some sl → live l = true →
      q.1 + q.2 ≤ sl.off ∨ sl.off + sl.size ≤ q.1) :
    ∀ {is : List R.Insn} {ops : List NOp} {s1 : R.RState} {E E' : Int → Option Nat},
      progOk Γ is ops = true →
      (∀ op ∈ ops, op.dst ∈ DW ∧ ∀ p ∈ op.srcs, p ∈ W) →
      evalProg E ops = some E' →
      (∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj)) →
      (∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) → c.mode.pe = false →
      (∀ i ∈ is, PlainView c.mode c.ρ i) →
      FnRel Γ ι live f m0 s1 → EnvAt s1.st E W →
      ∃ st', StepsTo c ch s1 { s1 with pc := s1.pc + is.length, st := st' } ∧
        FnRel Γ ι live f m0 { s1 with pc := s1.pc + is.length, st := st' } ∧ EnvAt st' E' W := by
  intro is
  induction is with
  | nil =>
    intro ops s1 E E' hp hops hev _ _ _ _ hrel henv
    cases ops with
    | cons _ _ => simp [progOk] at hp
    | nil =>
      simp only [evalProg, Option.some.injEq] at hev
      subst hev
      have e : ({ s1 with pc := s1.pc + ([] : List R.Insn).length, st := s1.st } : R.RState) =
          s1 := rfl
      refine ⟨s1.st, ?_, ?_, henv⟩
      · rw [e]; exact .refl _
      · rw [e]; exact hrel
  | cons i is ih =>
    intro ops s1 E E' hp hops hev hi hsc hpe hpl hrel henv
    cases ops with
    | nil => simp [progOk] at hp
    | cons op ops =>
      simp only [progOk, Bool.and_eq_true] at hp
      obtain ⟨hok, hp⟩ := hp
      cases hv : op.val E with
      | none => simp [evalProg, hv] at hev
      | some v =>
        simp only [evalProg, hv] at hev
        obtain ⟨hdst, hsrcs⟩ := hops op (List.mem_cons_self ..)
        have hpli := hpl i (List.mem_cons_self ..)
        obtain ⟨wb, hlen, hwa, hwlt, hwr⟩ := nop_step (ch := ch) hmode hρ hok hpli
          (st := s1.st) (E := E) (fun p hp x hx => henv p (hsrcs p hp) x hx)
          (fun p hp => by
            rcases List.mem_cons.mp hp with rfl | hp
            · exact hofs _ (hDW _ hdst)
            · exact hofs _ (hsrcs p hp)) hv
        have hpw : ∀ k < wb.length, s1.st.escapedAt (op.dst.1 + k) = none := by
          intro k hk
          rw [hlen] at hk
          cases he : s1.st.escapedAt (op.dst.1 + k) with
          | none => rfl
          | some e =>
            have h1 := hrel.esc _ _ he
            rw [hpriv _ hdst k hk] at h1
            cases h1
        obtain ⟨st1, hw1⟩ : ∃ st1, s1.st.writeFrame op.dst.1 wb = .ok st1 := by
          unfold OpSem.State.writeFrame
          rw [writeEscaped_private' hpw]
          exact ⟨_, rfl⟩
        obtain ⟨vw, hvw, hctl, hop⟩ := hwr st1 hw1
        have hi0 : c.d.insns[s1.pc]? = some i := hi 0 (by simp)
        have hsc0 : c.scopesAt s1.pc = [] := hsc 0 (by simp)
        have hstep : R.step c s1 ch = .ok (.step { s1 with pc := s1.pc + 1, st := st1 }) :=
          step_of_view hi0 hsc0 hpe hpli hvw hctl hop
        have hrel1 : FnRel Γ ι live f m0 { s1 with pc := s1.pc + 1, st := st1 } :=
          hrel.writePriv hw1 hpw (fun l p sl hl hsl hlive => by
            rw [hlen]; exact hlv _ hdst l p sl hl hsl hlive) (s1.pc + 1)
        have henv1 : EnvAt st1 (envUpd E op.dst.1 v) W := by
          intro p hpW x hx
          by_cases hpd : p = op.dst
          · subst hpd
            simp [envUpd] at hx
            subst hx
            have hrb := readFrame_written hw1 hpw
            rw [hlen] at hrb
            exact ⟨wb, hrb, hwa, hlen, hwlt⟩
          · have hne1 : p.1 ≠ op.dst.1 := by
              intro e
              have h1 := hap _ hdst p hpW hpd
              have h2 := hpos p hpW
              have h3 := hpos _ (hDW _ hdst)
              omega
            simp only [envUpd, if_neg hne1] at hx
            obtain ⟨bs, hrf, hbv, hbl, hblt⟩ := henv p hpW x hx
            refine ⟨bs, ?_, hbv, hbl, hblt⟩
            rw [readFrame_write_apart hw1 hpw (by rw [hlen]; exact hap _ hdst p hpW hpd)]
            exact hrf
        obtain ⟨st', hst', hrel', henv'⟩ := @ih ops { s1 with pc := s1.pc + 1, st := st1 } _ _
          hp (fun o ho => hops o (List.mem_cons_of_mem _ ho)) hev
          (fun j hj => by
            have h := hi (j + 1) (by simp only [List.length_cons]; omega)
            have e2 : s1.pc + 1 + j = s1.pc + (j + 1) := by omega
            show c.d.insns[s1.pc + 1 + j]? = _
            rw [e2, h]
            rfl)
          (fun j hj => by
            have h := hsc (j + 1) (by simp only [List.length_cons]; omega)
            have e2 : s1.pc + 1 + j = s1.pc + (j + 1) := by omega
            show c.scopesAt (s1.pc + 1 + j) = []
            rw [e2]; exact h)
          hpe (fun j hj => hpl j (List.mem_cons_of_mem _ hj)) hrel1 henv1
        have e : s1.pc + 1 + is.length = s1.pc + (i :: is).length := by
          simp only [List.length_cons]; omega
        refine ⟨st', ?_, ?_, henv'⟩
        · have h2 : StepsTo c ch s1 { s1 with pc := s1.pc + 1 + is.length, st := st' } :=
            .cons hstep hst'
          rw [e] at h2
          exact h2
        · have h3 : FnRel Γ ι live f m0 { s1 with pc := s1.pc + 1 + is.length, st := st' } :=
            hrel'
          rw [e] at h3
          exact h3

/-! ### `nicheProg` computes `nicheDiscr` -/

section
open Ryo.Proofs.NicheDiscr

theorem envUpd_self (E : Int → Option Nat) (o : Int) (v : Nat) : envUpd E o v o = some v := by
  simp [envUpd]

theorem envUpd_ne {E : Int → Option Nat} {o o' : Int} {v : Nat} (h : o' ≠ o) :
    envUpd E o v o' = E o' := by
  simp [envUpd, h]

theorem evalProg_cons {E : Int → Option Nat} {op : NOp} {ops : List NOp} {v : Nat} {o : Int}
    (h : op.val E = some v) (hd : op.dst.1 = o) :
    evalProg E (op :: ops) = evalProg (envUpd E o v) ops := by
  simp only [evalProg, h, hd]

theorem ofNat_toNat_self {w : Nat} (x : BitVec w) : BitVec.ofNat w x.toNat = x := by
  rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]

theorem castOp_dst (d s : Int) (nx ny : Nat) : (castOp d s nx ny).dst = (d, ny) := by
  unfold castOp
  split <;> simp_all [NOp.dst]

theorem castOp_srcs (d s : Int) (nx ny : Nat) : (castOp d s nx ny).srcs = [(s, nx)] := by
  unfold castOp
  split <;> rfl

/-- A cast of `x` (below `2 ^ (8 nx)`): its value at the destination's width. -/
theorem cast_val {E : Int → Option Nat} {d s : Int} {nx ny x : Nat} (hs : E s = some x)
    (hx : x < 2 ^ (8 * nx)) : (castOp d s nx ny).val E = some (BitVec.ofNat (8 * ny) x).toNat := by
  unfold castOp
  split
  · next h =>
    subst h
    simp only [NOp.val, hs, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hx]
  · simp only [NOp.val, hs, Option.map_some, cvtInt, Bool.false_eq_true, ↓reduceIte,
      BitVec.ofInt_natCast]

theorem val_cmpImm {E : Int → Option Nat} {o : String} {n : Nat} {d a : Int} {imm x : Nat}
    (h : E a = some x) : (NOp.cmpImm o n d a imm).val E =
      (cmpPure o (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) imm)).map
        fun b => if b then 1 else 0 := by
  simp only [NOp.val, h, Option.bind_some]

theorem val_binImm {E : Int → Option Nat} {m : String} {n : Nat} {d a : Int} {imm x : Nat}
    (h : E a = some x) : (NOp.binImm m n d a imm).val E =
      (binPure m (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) imm)).map BitVec.toNat := by
  simp only [NOp.val, h, Option.bind_some]

theorem val_bin {E : Int → Option Nat} {m : String} {n : Nat} {d a b : Int} {x y : Nat}
    (ha : E a = some x) (hb : E b = some y) : (NOp.bin m n d a b).val E =
      (binPure m (BitVec.ofNat (8 * n) x) (BitVec.ofNat (8 * n) y)).map BitVec.toNat := by
  simp only [NOp.val, ha, hb, Option.bind_some]

theorem val_un {E : Int → Option Nat} {m : String} {n : Nat} {d a : Int} {x : Nat}
    (h : E a = some x) :
    (NOp.un m n d a).val E = (unPure m (BitVec.ofNat (8 * n) x)).map BitVec.toNat := by
  simp only [NOp.val, h, Option.bind_some]

theorem cmpPure_eq {w : Nat} (x y : BitVec w) : cmpPure "==" x y = some (x == y) := by
  simp [cmpPure]
theorem cmpPure_ne {w : Nat} (x y : BitVec w) : cmpPure "!=" x y = some (x != y) := by
  simp [cmpPure]
theorem cmpPure_le {w : Nat} (x y : BitVec w) : cmpPure "<=" x y = some (x.ule y) := by
  simp [cmpPure]
theorem binPure_add {w : Nat} (x y : BitVec w) : binPure "wrapping_add" x y = some (x + y) := by
  simp [binPure]
theorem binPure_sub {w : Nat} (x y : BitVec w) : binPure "wrapping_sub" x y = some (x - y) := by
  simp [binPure]
theorem binPure_and {w : Nat} (x y : BitVec w) : binPure "&" x y = some (x &&& y) := by
  simp [binPure]
theorem binPure_xor {w : Nat} (x y : BitVec w) : binPure "^" x y = some (x ^^^ y) := by
  simp [binPure]
theorem unPure_neg {w : Nat} (x : BitVec w) : unPure "wrapping_neg" x = some (-x) := by
  simp [unPure]

/-- `if b then 1 else 0` as a byte's value. -/
theorem boolNat_toNat (c : Bool) :
    (if c then (1 : BitVec 8) else 0).toNat = if c then 1 else 0 := by
  cases c <;> rfl

theorem boolNat_lt (c : Bool) : (if c then 1 else 0 : Nat) < 2 ^ (8 * 1) := by
  cases c <;> decide

/-- The one-niche-variant decoding (`lo = hi`). -/
theorem evalNicheA (tw dw untagged lo ns : Nat) (t d b r m : Int) (u : Nat) :
    ∃ E', evalProg (fun o => if o = t then some u else none)
        (nicheProg tw dw untagged lo lo ns t d b r m) = some E' ∧
      E' d = some (nicheDiscr (8 * tw) (8 * dw) untagged lo lo ns
        (BitVec.ofNat (8 * tw) u)).toNat := by
  have hE0 : (fun o => if o = t then some u else none : Int → Option Nat) t = some u := by simp
  generalize (fun o => if o = t then some u else none : Int → Option Nat) = E0 at hE0 ⊢
  -- the compare
  generalize hc : ((BitVec.ofNat (8 * tw) u == BitVec.ofNat (8 * tw) ns) !=
    decide (untagged = lo + 1)) = c
  have hv1 : (NOp.cmpImm (if untagged = lo + 1 then "!=" else "==") tw b t ns).val E0 =
      some (if c then 1 else 0) := by
    rw [val_cmpImm hE0]
    by_cases hne : untagged = lo + 1
    · rw [if_pos hne, cmpPure_ne]
      rw [decide_eq_true hne] at hc
      subst hc
      simp only [bne, Option.map_some]
      cases (BitVec.ofNat (8 * tw) u == BitVec.ofNat (8 * tw) ns) <;> rfl
    · rw [if_neg hne, cmpPure_eq]
      rw [decide_eq_false hne] at hc
      subst hc
      simp only [bne, Option.map_some]
      cases (BitVec.ofNat (8 * tw) u == BitVec.ofNat (8 * tw) ns) <;> rfl
  have hv2 : (castOp d b 1 dw).val (envUpd E0 b (if c then 1 else 0)) =
      some (BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat :=
    cast_val (envUpd_self _ _ _) (boolNat_lt c)
  -- `nicheDiscr`'s value
  have hnd : ∀ X : BitVec (8 * dw),
      ((if c then (1 : BitVec 8) else 0).setWidth (8 * dw) = X) →
      nicheDiscr (8 * tw) (8 * dw) untagged lo lo ns (BitVec.ofNat (8 * tw) u) =
        if lo + 1 = untagged ∨ untagged + 1 = lo then
          X + BitVec.ofNat (8 * dw) (if untagged = lo + 1 then lo else untagged)
        else ((-X) &&& (BitVec.ofNat (8 * dw) lo ^^^ BitVec.ofNat (8 * dw) untagged)) ^^^
          BitVec.ofNat (8 * dw) untagged := by
    intro X hX
    unfold nicheDiscr
    simp only [if_pos (rfl : lo = lo), ite_true]
    rw [← hX, ← hc]
  have hX : (if c then (1 : BitVec 8) else 0).setWidth (8 * dw) =
      BitVec.ofNat (8 * dw) (if c then 1 else 0) := by
    rw [← BitVec.ofNat_toNat, boolNat_toNat]
  have hn := hnd _ hX
  unfold nicheProg
  rw [if_pos (rfl : lo = lo)]
  dsimp only
  rw [List.cons_append, List.cons_append, List.nil_append, evalProg_cons (o := b) hv1 rfl,
    evalProg_cons (o := d) hv2 (by rw [castOp_dst])]
  by_cases hadj : lo + 1 = untagged ∨ untagged + 1 = lo
  · rw [if_pos hadj] at hn ⊢
    by_cases h0 : (if untagged = lo + 1 then lo else untagged) = 0
    · rw [if_pos h0]
      refine ⟨_, rfl, ?_⟩
      rw [envUpd_self, hn, h0]
      simp
    · rw [if_neg h0]
      have hv3 : (NOp.binImm "wrapping_add" dw d d (if untagged = lo + 1 then lo else untagged)).val
          (envUpd (envUpd E0 b (if c then 1 else 0)) d
            (BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat) =
          some (BitVec.ofNat (8 * dw) (if c then 1 else 0) +
            BitVec.ofNat (8 * dw) (if untagged = lo + 1 then lo else untagged)).toNat := by
        rw [val_binImm (envUpd_self _ _ _), ofNat_toNat_self, binPure_add] <;> rfl
      rw [evalProg_cons (o := d) hv3 rfl]
      refine ⟨_, rfl, ?_⟩
      rw [envUpd_self, hn]
  · rw [if_neg hadj] at hn ⊢
    have hv3 : (NOp.un "wrapping_neg" dw d d).val
        (envUpd (envUpd E0 b (if c then 1 else 0)) d
          (BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat) =
        some (-BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat := by
      rw [val_un (envUpd_self _ _ _), ofNat_toNat_self, unPure_neg] <;> rfl
    rw [evalProg_cons (o := d) hv3 rfl]
    have hv4 : (NOp.binImm "&" dw d d (lo ^^^ untagged)).val
        (envUpd (envUpd (envUpd E0 b (if c then 1 else 0)) d
          (BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat) d
          (-BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat) =
        some ((-BitVec.ofNat (8 * dw) (if c then 1 else 0)) &&&
          (BitVec.ofNat (8 * dw) lo ^^^ BitVec.ofNat (8 * dw) untagged)).toNat := by
      rw [val_binImm (envUpd_self _ _ _), ofNat_toNat_self, binPure_and, BitVec.ofNat_xor] <;> rfl
    rw [evalProg_cons (o := d) hv4 rfl]
    have hv5 : (NOp.binImm "^" dw d d untagged).val
        (envUpd (envUpd (envUpd (envUpd E0 b (if c then 1 else 0)) d
          (BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat) d
          (-BitVec.ofNat (8 * dw) (if c then 1 else 0)).toNat) d
          ((-BitVec.ofNat (8 * dw) (if c then 1 else 0)) &&&
            (BitVec.ofNat (8 * dw) lo ^^^ BitVec.ofNat (8 * dw) untagged)).toNat) =
        some (((-BitVec.ofNat (8 * dw) (if c then 1 else 0)) &&&
          (BitVec.ofNat (8 * dw) lo ^^^ BitVec.ofNat (8 * dw) untagged)) ^^^
            BitVec.ofNat (8 * dw) untagged).toNat := by
      rw [val_binImm (envUpd_self _ _ _), ofNat_toNat_self, binPure_xor] <;> rfl
    rw [evalProg_cons (o := d) hv5 rfl]
    refine ⟨_, rfl, ?_⟩
    rw [envUpd_self, hn]

/-- The general decoding (`lo ≠ hi`). -/
theorem evalNicheC {tw dw untagged lo hi ns : Nat} {t d b r m : Int} (u : Nat)
    (hlh : lo ≠ hi) (hrb : r ≠ b) (hbd : b ≠ d) (hdm : d ≠ m) :
    ∃ E', evalProg (fun o => if o = t then some u else none)
        (nicheProg tw dw untagged lo hi ns t d b r m) = some E' ∧
      E' d = some (nicheDiscr (8 * tw) (8 * dw) untagged lo hi ns
        (BitVec.ofNat (8 * tw) u)).toNat := by
  have hE0 : (fun o => if o = t then some u else none : Int → Option Nat) t = some u := by simp
  generalize (fun o => if o = t then some u else none : Int → Option Nat) = E0 at hE0 ⊢
  generalize hR : BitVec.ofNat (8 * tw) u - BitVec.ofNat (8 * tw) ns = R
  generalize hK : BitVec.ofNat (8 * tw) (hi - lo) = K
  generalize hU : BitVec.ofNat (8 * dw) untagged = U
  generalize hcb : R.ule K = cb
  -- the ops' values
  have hv1 : (NOp.binImm "wrapping_sub" tw r t ns).val E0 = some R.toNat := by
    rw [val_binImm hE0, binPure_sub, hR] <;> rfl
  generalize E1def : envUpd E0 r R.toNat = E1
  have hE1r : E1 r = some R.toNat := by rw [← E1def]; exact envUpd_self _ _ _
  have hv2 : (NOp.cmpImm "<=" tw b r (hi - lo)).val E1 = some (if cb then 1 else 0) := by
    rw [val_cmpImm hE1r, ofNat_toNat_self, cmpPure_le, hK, hcb] <;> rfl
  generalize E2def : envUpd E1 b (if cb then 1 else 0) = E2
  have hE2r : E2 r = some R.toNat := by rw [← E2def, envUpd_ne hrb]; exact hE1r
  have hE2b : E2 b = some (if cb then 1 else 0) := by rw [← E2def]; exact envUpd_self _ _ _
  have hv3 : (castOp d r tw dw).val E2 = some (BitVec.ofNat (8 * dw) R.toNat).toNat :=
    cast_val hE2r R.isLt
  generalize E3def : envUpd E2 d (BitVec.ofNat (8 * dw) R.toNat).toNat = E3
  generalize hD : BitVec.ofNat (8 * dw) R.toNat + BitVec.ofNat (8 * dw) lo = D
  -- after the optional add: `_d` holds `D`, `b` the compare
  obtain ⟨E4, hE4, hE4d, hE4b⟩ : ∃ E4, evalProg E3 (if lo = 0 then [] else
      [NOp.binImm "wrapping_add" dw d d lo]) = some E4 ∧ E4 d = some D.toNat ∧
      E4 b = some (if cb then 1 else 0) := by
    have hE3b : E3 b = some (if cb then 1 else 0) := by rw [← E3def, envUpd_ne hbd]; exact hE2b
    by_cases h0 : lo = 0
    · rw [if_pos h0]
      refine ⟨E3, rfl, ?_, hE3b⟩
      rw [← E3def, envUpd_self, ← hD, h0]
      simp
    · rw [if_neg h0]
      have hv4 : (NOp.binImm "wrapping_add" dw d d lo).val E3 = some D.toNat := by
        rw [val_binImm (by rw [← E3def]; exact envUpd_self _ _ _), ofNat_toNat_self, binPure_add,
          hD] <;> rfl
      refine ⟨envUpd E3 d D.toNat, by rw [evalProg_cons (o := d) hv4 rfl] <;> rfl, envUpd_self _ _ _, ?_⟩
      rw [envUpd_ne hbd]; exact hE3b
  -- the blend
  have hv5 : (castOp m b 1 dw).val E4 = some (BitVec.ofNat (8 * dw) (if cb then 1 else 0)).toNat :=
    cast_val hE4b (boolNat_lt cb)
  generalize hM : -BitVec.ofNat (8 * dw) (if cb then 1 else 0) = M
  generalize E5def : envUpd E4 m (BitVec.ofNat (8 * dw) (if cb then 1 else 0)).toNat = E5
  have hv6 : (NOp.un "wrapping_neg" dw m m).val E5 = some M.toNat := by
    rw [val_un (by rw [← E5def]; exact envUpd_self _ _ _), ofNat_toNat_self, unPure_neg, hM] <;> rfl
  generalize E6def : envUpd E5 m M.toNat = E6
  have hE6d : E6 d = some D.toNat := by
    rw [← E6def, envUpd_ne hdm, ← E5def, envUpd_ne hdm]; exact hE4d
  have hv7 : (NOp.binImm "^" dw d d untagged).val E6 = some (D ^^^ U).toNat := by
    rw [val_binImm hE6d, ofNat_toNat_self, binPure_xor, hU] <;> rfl
  generalize E7def : envUpd E6 d (D ^^^ U).toNat = E7
  have hv8 : (NOp.bin "&" dw d d m).val E7 = some ((D ^^^ U) &&& M).toNat := by
    rw [val_bin (by rw [← E7def]; exact envUpd_self _ _ _)
      (by rw [← E7def, envUpd_ne (Ne.symm hdm), ← E6def]; exact envUpd_self _ _ _),
      ofNat_toNat_self, ofNat_toNat_self, binPure_and] <;> rfl
  generalize E8def : envUpd E7 d ((D ^^^ U) &&& M).toNat = E8
  have hv9 : (NOp.binImm "^" dw d d untagged).val E8 = some (((D ^^^ U) &&& M) ^^^ U).toNat := by
    rw [val_binImm (by rw [← E8def]; exact envUpd_self _ _ _), ofNat_toNat_self, binPure_xor, hU] <;> rfl
  -- `nicheDiscr`'s value
  have hnd : nicheDiscr (8 * tw) (8 * dw) untagged lo hi ns (BitVec.ofNat (8 * tw) u) =
      ((D ^^^ U) &&& M) ^^^ U := by
    unfold nicheDiscr
    simp only [if_neg hlh]
    rw [hR, hK, hU, ← hD, ← hM]
    have hb : (if R ≤ K then (1 : BitVec 8) else 0).setWidth (8 * dw) =
        BitVec.ofNat (8 * dw) (if cb then 1 else 0) := by
      rw [← BitVec.ofNat_toNat, ← hcb, BitVec.ule_eq_decide_le]
      congr 1
      by_cases h : R ≤ K
      · rw [if_pos h, decide_eq_true h] <;> rfl
      · rw [if_neg h, decide_eq_false h] <;> rfl
    rw [hb, ← BitVec.ofNat_toNat]
  -- the run
  unfold nicheProg
  rw [if_neg hlh]
  simp only [List.cons_append, List.nil_append, List.append_assoc]
  rw [evalProg_cons (o := r) hv1 rfl, E1def, evalProg_cons (o := b) hv2 rfl, E2def,
    evalProg_cons (o := d) hv3 (by rw [castOp_dst]), E3def, evalProg_append, hE4,
    Option.bind_some, evalProg_cons (o := m) hv5 (by rw [castOp_dst]), E5def,
    evalProg_cons (o := m) hv6 rfl, E6def, evalProg_cons (o := d) hv7 rfl, E7def,
    evalProg_cons (o := d) hv8 rfl, E8def, evalProg_cons (o := d) hv9 rfl]
  refine ⟨_, rfl, ?_⟩
  rw [envUpd_self, hnd]

end

/-! ### The rule's facts -/

theorem stepsTo_append {c : R.Code} {ch : OpSem.Choice} {a b e : R.RState}
    (h1 : StepsTo c ch a b) (h2 : StepsTo c ch b e) : StepsTo c ch a e := by
  induction h1 with
  | refl => exact h2
  | cons hs _ ih => exact .cons hs (ih h2)

theorem rangesApart_spec : ∀ {l : List (Int × Nat)}, rangesApart l = true →
    ∀ p ∈ l, ∀ q ∈ l, p ≠ q → p.1 + p.2 ≤ q.1 ∨ q.1 + q.2 ≤ p.1
  | [], _ => by intro p hp; cases hp
  | (a, n) :: rest, h => by
    simp only [rangesApart, Bool.and_eq_true, List.all_eq_true, Bool.or_eq_true,
      decide_eq_true_eq] at h
    obtain ⟨hall, hr⟩ := h
    intro p hp q hq hpq
    rcases List.mem_cons.mp hp with rfl | hp' <;> rcases List.mem_cons.mp hq with rfl | hq'
    · exact absurd rfl hpq
    · exact hall q hq'
    · exact (hall p hp').symm
    · exact rangesApart_spec hr p hp' q hq' hpq

theorem nicheTemps_pos {tw dw lo hi : Nat} {b r m : Int} (htw : 0 < tw) (hdw : 0 < dw) :
    ∀ p ∈ nicheTemps tw dw lo hi b r m, 0 < p.2 := by
  intro p hp
  unfold nicheTemps at hp
  split at hp
  · simp only [List.mem_singleton] at hp
    subst hp
    exact Nat.one_pos
  · simp only [List.mem_cons, List.mem_nil_iff, or_false] at hp
    rcases hp with rfl | rfl | rfl
    · exact Nat.one_pos
    · exact htw
    · exact hdw

/-- `nicheProg` ends with an op writing `_d`. -/
theorem nicheProg_last (tw dw untagged lo hi ns : Nat) (t d b r m : Int) :
    ∃ init last, nicheProg tw dw untagged lo hi ns t d b r m = init ++ [last] ∧
      last.dst = (d, dw) := by
  unfold nicheProg
  by_cases hlh : lo = hi
  · rw [if_pos hlh]
    dsimp only
    by_cases hadj : lo + 1 = untagged ∨ untagged + 1 = lo
    · rw [if_pos hadj]
      by_cases h0 : (if untagged = lo + 1 then lo else untagged) = 0
      · rw [if_pos h0]
        exact ⟨[_], castOp d b 1 dw, rfl, castOp_dst d b 1 dw⟩
      · rw [if_neg h0]
        exact ⟨[_, _], _, rfl, rfl⟩
    · rw [if_neg hadj]
      exact ⟨[_, _, _, _], _, rfl, rfl⟩
  · rw [if_neg hlh]
    by_cases h0 : lo = 0
    · rw [if_pos h0]
      exact ⟨[_, _, _, _, _, _, _], _, rfl, rfl⟩
    · rw [if_neg h0]
      exact ⟨[_, _, _, _, _, _, _, _], _, rfl, rfl⟩

/-- `nicheProg`'s ops write `_d` or a temporary and read the tag, `_d` or a temporary. -/
theorem nicheProg_mem (tw dw untagged lo hi ns : Nat) (t d b r m : Int) :
    ∀ op ∈ nicheProg tw dw untagged lo hi ns t d b r m,
      op.dst ∈ (d, dw) :: nicheTemps tw dw lo hi b r m ∧
      ∀ p ∈ op.srcs, p ∈ (t, tw) :: (d, dw) :: nicheTemps tw dw lo hi b r m := by
  intro op hop
  unfold nicheProg at hop
  unfold nicheTemps
  by_cases hlh : lo = hi
  · rw [if_pos hlh] at hop ⊢
    dsimp only at hop
    simp only [List.mem_append] at hop
    rcases hop with h | h
    · simp only [List.mem_cons, List.mem_nil_iff, or_false] at h
      rcases h with rfl | rfl <;> first | (simp [castOp_dst, castOp_srcs]; done) | (simp [NOp.dst, NOp.srcs]; done)
    · have h' : op = .binImm "wrapping_add" dw d d (if untagged = lo + 1 then lo else untagged) ∨
          op = .un "wrapping_neg" dw d d ∨ op = .binImm "&" dw d d (lo ^^^ untagged) ∨
          op = .binImm "^" dw d d untagged := by
        split at h <;> (try split at h) <;> simp_all
      rcases h' with rfl | rfl | rfl | rfl <;> simp [NOp.dst, NOp.srcs]
  · rw [if_neg hlh] at hop ⊢
    simp only [List.mem_append] at hop
    rcases hop with (h | h) | h
    · simp only [List.mem_cons, List.mem_nil_iff, or_false] at h
      rcases h with rfl | rfl | rfl <;> first | (simp [castOp_dst, castOp_srcs]; done) | (simp [NOp.dst, NOp.srcs]; done)
    · have h' : op = .binImm "wrapping_add" dw d d lo := by
        split at h <;> simp_all
      subst h'
      simp [NOp.dst, NOp.srcs]
    · simp only [List.mem_cons, List.mem_nil_iff, or_false] at h
      rcases h with rfl | rfl | rfl | rfl | rfl <;>
        first | (simp [castOp_dst, castOp_srcs]; done) | (simp [NOp.dst, NOp.srcs]; done)

theorem progOk_append_one {Γ : StmtCtx} {op : NOp} :
    ∀ {is : List R.Insn} {ops : List NOp}, progOk Γ is (ops ++ [op]) = true →
      ∃ is1 i, is = is1 ++ [i] ∧ progOk Γ is1 ops = true ∧ op.insnOk Γ i = true
  | [], [], h => by simp [progOk] at h
  | [], _ :: _, h => by simp [progOk] at h
  | [i], [], h => by
    simp only [List.nil_append, progOk, Bool.and_true] at h
    exact ⟨[], i, rfl, rfl, h⟩
  | _ :: _ :: _, [], h => by simp [progOk] at h
  | i :: is, o :: ops, h => by
    simp only [List.cons_append, progOk, Bool.and_eq_true] at h
    obtain ⟨h1, h2⟩ := h
    obtain ⟨is1, i', rfl, h3, h4⟩ := progOk_append_one h2
    exact ⟨i :: is1, i', rfl, by simp only [progOk, h1, h3, Bool.and_self], h4⟩

/-! ### The lift -/

/-- `LowerNicheRead`'s lift (see the module comment).

Proof: the rule's facts (`nicheReadOk`); L0's statement by `discrField_assign_inv` and
`readDiscr_multiple_inv`, R's tag bytes as in `sim_fusedNiche` (`SimNiche.lean`); the program's
value by `evalNicheA`/`evalNicheC`, L0's by `nicheDiscr_sound` and `discrIdxAgree`; the ops but
the last by `prog_run` at the liveness without `_d`, the last (writing `_d`, `nicheProg_last`) by
`nop_step`, `writeLocal_priv` and `FnRel.after`. -/
theorem lift_nicheRead {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {is : List R.Insn}
    (hlow : LowerNicheRead Γ (.assign ⟨d, []⟩ rv) is)
    (hins : ∀ j (hj : j < is.length), c.d.insns[s1.pc + j]? = some (is[j]'hj))
    (hsc : ∀ j, j < is.length → c.scopesAt (s1.pc + j) = []) (hpeR : c.mode.pe = false)
    (hpl : ∀ i ∈ is, PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOutN Γ c ch ι live' f s s' s1 is.length := by
  cases hlow with
  | mk d e projs ta off vs discrTy tag esz eal t vd sd se untagged lo hi ns b r m is hta htd hsd
      hse hpath henc hok =>
  simp only [nicheReadOk, Bool.and_eq_true, bne_iff_ne, ne_eq, beq_iff_eq,
    decide_eq_true_eq] at hok
  obtain ⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨⟨hne, hszd⟩, htpos⟩, htagpos⟩, hin⟩, hoffd⟩, hoffe⟩, hofft⟩, hbound⟩,
    hprivd⟩, htemps⟩, hrange⟩, hagree⟩, hprog⟩ := hok
  -- the sizes at `Nat` (for `omega`: `Size`/`Offset` are abbreviations)
  have hszdN : @Eq Nat sd.size t.size := hszd
  have htposN : @LT.lt Nat _ 0 t.size := htpos
  have htagposN : @LT.lt Nat _ 0 tag.tag.size := htagpos
  have hinN : @LE.le Nat _ (@HAdd.hAdd Nat Nat Nat _ (@HAdd.hAdd Nat Nat Nat _ off tag.offset)
    tag.tag.size) se.size := hin
  unfold tempsOk at htemps
  rw [Bool.and_eq_true] at htemps
  obtain ⟨htall, htra⟩ := htemps
  have htall' : ∀ p ∈ nicheTemps tag.tag.size t.size lo hi b r m,
      offOk p.1 = true ∧ privOk Γ p.1 p.2 = true ∧ tempApart Γ.slots p.1 p.2 = true := by
    intro p hp
    have := List.all_eq_true.mp htall p hp
    simp only [Bool.and_eq_true] at this
    exact ⟨this.1.1, this.1.2, this.2⟩
  -- L0
  rw [hbody] at hta htd
  obtain ⟨pd, pe, idx, hpd, hpe, hrd, hsto, hstk⟩ := discrField_assign_inv hs hta hpath htd h
  obtain ⟨bs, u, hld, hdb, htv⟩ := readDiscr_multiple_inv hrd
  -- R's tag bytes
  have hle : live e = true := hlo e (by simp [rvalueLocals, placeLocals])
  have hre := hrel.opnd hpe hse hle
  have hn0 : tag.tag.size ≠ 0 := Nat.pos_iff_ne_zero.mp htagpos
  obtain ⟨id, hid, hpid, -, hlo', -⟩ := load_eq_ok_pos hn0 hld
  have hle2 : pe.addr ≤
      ((⟨pe.addr + off, pe.prov⟩ : ThinPointer).wrappingOffset tag.offset).addr :=
    start_le (q := (⟨pe.addr + off, pe.prov⟩ : ThinPointer).wrappingOffset tag.offset) hre rfl
      hid hpid hlo'
  rw [wrappingOffset_eq2 hbound hle2] at hld
  obtain ⟨ba, hrf, hia⟩ := readLocal_sub_inj hrel.frame.mem hre hin hld
  have hda := decodeBits_inj hia hdb
  have hva : asNat ba = .ok u := by unfold asNat; rw [hda] <;> rfl
  have hlenba : ba.length = tag.tag.size := (BytesInj.length hia).symm.trans (load_length hld)
  have hlt : u < 2 ^ (8 * tag.tag.size) := by
    have h0 := Ryo.Spec.Theorems.decodeBits_length hdb
    rw [load_length hld] at h0
    exact h0
  -- the slots
  have hpos : 0 < sd.size := by rw [hszd]; exact htpos
  have hprivD : ∀ k < sd.size, Γ.escaped (sd.off + k) = false := privOk_spec hprivd
  have hapED : SlotsApart se sd := hrel.apart e d pe pd se sd (Ne.symm hne) hpe hpd hse hsd
  have hT : ∀ p ∈ nicheTemps tag.tag.size t.size lo hi b r m,
      ∀ (l : Local) (sl : LocalSlot), Γ.slots[l]? = some sl →
        p.1 + p.2 ≤ sl.off ∨ sl.off + sl.size ≤ p.1 :=
    fun p hp l sl hsl => tempApart_spec (htall' p hp).2.2 hsl
  have htpos' := nicheTemps_pos (b := b) (r := r) (m := m) (lo := lo) (hi := hi) htagpos htpos
  -- the run's slot lists
  generalize hW : (se.off + ((off + tag.offset : Nat) : Int), tag.tag.size) :: (sd.off, t.size) ::
    nicheTemps tag.tag.size t.size lo hi b r m = W
  generalize hDW : (sd.off, t.size) :: nicheTemps tag.tag.size t.size lo hi b r m = DW
  have hWDW : W = (se.off + ((off + tag.offset : Nat) : Int), tag.tag.size) :: DW := by rw [← hW, ← hDW]
  have hWpos : ∀ p ∈ W, 0 < p.2 := by
    intro p hp
    rw [← hW] at hp
    rcases List.mem_cons.mp hp with rfl | hp
    · exact htagpos
    rcases List.mem_cons.mp hp with rfl | hp
    · exact htpos
    · exact htpos' p hp
  have hWofs : ∀ p ∈ W, -2 ^ 31 ≤ p.1 ∧ p.1 < 2 ^ 31 := by
    intro p hp
    rw [← hW] at hp
    rcases List.mem_cons.mp hp with rfl | hp
    · exact offOk_spec hofft
    rcases List.mem_cons.mp hp with rfl | hp
    · exact offOk_spec hoffd
    · exact offOk_spec (htall' p hp).1
  have hDWW : ∀ q ∈ DW, q ∈ W := fun q hq => by rw [hWDW]; exact List.mem_cons_of_mem _ hq
  have hap : ∀ q ∈ DW, ∀ p ∈ W, p ≠ q → q.1 + q.2 ≤ p.1 ∨ p.1 + p.2 ≤ q.1 := by
    intro q hq p hp hpq
    rw [← hDW] at hq
    rw [← hW] at hp
    unfold SlotsApart at hapED
    rcases List.mem_cons.mp hq with rfl | hq
    · -- `_d`
      rcases List.mem_cons.mp hp with rfl | hp
      · dsimp only; omega
      rcases List.mem_cons.mp hp with rfl | hp
      · exact absurd rfl hpq
      · have := hT p hp d sd hsd
        dsimp only; omega
    · -- a temporary
      rcases List.mem_cons.mp hp with rfl | hp
      · have := hT q hq e se hse
        dsimp only; omega
      rcases List.mem_cons.mp hp with rfl | hp
      · have := hT q hq d sd hsd
        dsimp only; omega
      · exact rangesApart_spec htra q hq p hp (Ne.symm hpq)
  have hDWpriv : ∀ q ∈ DW, ∀ k < q.2, Γ.escaped (q.1 + k) = false := by
    intro q hq k hk
    rw [← hDW] at hq
    rcases List.mem_cons.mp hq with rfl | hq
    · exact hprivD k (by rw [hszd]; exact hk)
    · exact privOk_spec (htall' q hq).2.1 k hk
  -- the liveness without `_d`
  have hrel0 : FnRel Γ ι (fun l => live l && !(l == d)) f s.mem s1 :=
    hrel.weaken fun l hl => by simp only [Bool.and_eq_true] at hl; exact hl.1
  have hDWlv : ∀ q ∈ DW, ∀ (l : Local) (p : ThinPointer) (sl : LocalSlot),
      f.locals[l]? = some (some p) → Γ.slots[l]? = some sl →
      (live l && !(l == d)) = true → q.1 + q.2 ≤ sl.off ∨ sl.off + sl.size ≤ q.1 := by
    intro q hq l p sl hl hsl hlv
    rw [← hDW] at hq
    rcases List.mem_cons.mp hq with rfl | hq
    · have hld' : l ≠ d := by
        intro e'; subst e'; simp at hlv
      have := hrel.apart d l pd p sd sl (Ne.symm hld') hpd hl hsd hsl
      unfold SlotsApart at this
      dsimp only; omega
    · exact hT q hq l sl hsl
  -- the value
  have hbits : tag.tag.bits = 8 * tag.tag.size := by unfold IntType.bits; omega
  have hmodu : u < tag.tag.modulus := by rw [← modulus_eq_two_pow]; exact hlt
  have hsound := Ryo.Proofs.NicheDiscr.nicheDiscr_sound (dw := 8 * t.size) henc hmodu hrange htv
  rw [hbits] at hsound
  obtain ⟨E', hev, hE'd⟩ : ∃ E', evalProg (fun o => if o = se.off + ((off + tag.offset : Nat) : Int) then some u else none)
      (nicheProg tag.tag.size t.size untagged lo hi ns (se.off + ((off + tag.offset : Nat) : Int)) sd.off b r m) =
        some E' ∧
      E' sd.off = some (Ryo.Proofs.NicheDiscr.nicheDiscr (8 * tag.tag.size) (8 * t.size)
        untagged lo hi ns (BitVec.ofNat (8 * tag.tag.size) u)).toNat := by
    by_cases hlh : lo = hi
    · subst hlh
      exact evalNicheA _ _ _ _ _ _ _ _ _ _ _
    · have hb1 : (b, 1) ∈ nicheTemps tag.tag.size t.size lo hi b r m := by
        simp [nicheTemps, hlh]
      have hr1 : (r, tag.tag.size) ∈ nicheTemps tag.tag.size t.size lo hi b r m := by
        simp [nicheTemps, hlh]
      have hm1 : (m, t.size) ∈ nicheTemps tag.tag.size t.size lo hi b r m := by
        simp [nicheTemps, hlh]
      have hra' := htra
      simp only [nicheTemps, if_neg hlh, rangesApart, List.all_cons, List.all_nil, Bool.and_true,
        Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq] at hra'
      have hrb : r ≠ b := by
        intro e'
        omega
      have hbd : b ≠ sd.off := by
        intro e'
        have := hT _ hb1 d sd hsd
        dsimp only at this; omega
      have hdm : sd.off ≠ m := by
        intro e'
        have := hT _ hm1 d sd hsd
        dsimp only at this; omega
      exact evalNicheC u hlh hrb hbd hdm
  rw [hsound, BitVec.toNat_ofNat] at hE'd
  -- the program's last op
  obtain ⟨init, last, hsplit, hlastd⟩ :=
    nicheProg_last tag.tag.size t.size untagged lo hi ns (se.off + ((off + tag.offset : Nat) : Int)) sd.off b r m
  have hmem := nicheProg_mem tag.tag.size t.size untagged lo hi ns (se.off + ((off + tag.offset : Nat) : Int)) sd.off
    b r m
  rw [hsplit] at hprog hev hmem
  rw [hW, hDW] at hmem
  rw [evalProg_append] at hev
  obtain ⟨E1, hev1, hevL⟩ : ∃ E1, evalProg (fun o => if o = se.off + ((off + tag.offset : Nat) : Int) then some u
      else none) init = some E1 ∧ evalProg E1 [last] = some E' := by
    cases h1 : evalProg (fun o => if o = se.off + ((off + tag.offset : Nat) : Int) then some u else none) init with
    | none => rw [h1] at hev; cases hev
    | some E1 => rw [h1] at hev; exact ⟨E1, rfl, hev⟩
  obtain ⟨v, hvL, hE'⟩ : ∃ v, last.val E1 = some v ∧ E' = envUpd E1 last.dst.1 v := by
    cases hv : last.val E1 with
    | none => simp [evalProg, hv] at hevL
    | some v =>
      simp only [evalProg, hv, Option.some.injEq] at hevL
      exact ⟨v, rfl, hevL.symm⟩
  have hvV : v = idx % 2 ^ (8 * t.size) := by
    rw [hE', hlastd] at hE'd
    simp only [envUpd_self, Option.some.injEq] at hE'd
    exact hE'd
  obtain ⟨is1, iL, rfl, hp1, hokL⟩ := progOk_append_one hprog
  -- the ops but the last
  have hE0 : EnvAt s1.st (fun o => if o = se.off + ((off + tag.offset : Nat) : Int) then some u else none) W := by
    intro ⟨p1, p2⟩ hp x hx
    by_cases hpt : (p1, p2) = (se.off + ((off + tag.offset : Nat) : Int), tag.tag.size)
    · rw [hpt] at hx ⊢
      simp at hx
      subst hx
      exact ⟨ba, hrf, hva, hlenba, hlt⟩
    · exfalso
      have hq1 : p1 = se.off + ((off + tag.offset : Nat) : Int) := by
        by_cases hne' : p1 = se.off + ((off + tag.offset : Nat) : Int)
        · exact hne'
        · exfalso
          first
            | (simp only [if_neg hne'] at hx; cases hx)
            | simp only [if_neg hne'] at hx
            | (rw [if_neg hne'] at hx; cases hx)
      rw [hWDW] at hp
      rcases List.mem_cons.mp hp with hp' | hpD
      · exact hpt hp'
      · have hmemT : (se.off + ((off + tag.offset : Nat) : Int), tag.tag.size) ∈ W := by
          rw [hWDW]; exact List.mem_cons_self ..
        have h3 := hap (p1, p2) hpD (se.off + ((off + tag.offset : Nat) : Int), tag.tag.size) hmemT
          (fun e' => hpt e'.symm)
        have h2 : 0 < p2 := hWpos (p1, p2) (hDWW _ hpD)
        simp only at h3
        rw [hq1] at h3
        omega
  obtain ⟨st1, hst1, hrel1, henv1⟩ := prog_run (ch := ch)
    (live := fun l => live l && !(l == d)) hmode hρ hWpos hWofs hDWW hap hDWpriv
    hDWlv hp1 (fun op hop => hmem op (List.mem_append_left _ hop)) hev1
    (fun j hj => by
      have := hins j (by simp only [List.length_append, List.length_singleton]; omega)
      rw [this]
      first | simp [hj] | simp [List.getElem_append, hj])
    (fun j hj => hsc j (by simp only [List.length_append, List.length_singleton]; omega)) hpeR
    (fun i hi' => hpl i (List.mem_append_left _ hi')) hrel0 hE0
  -- the last op: `_d`'s write
  obtain ⟨hdstL, hsrcL⟩ := hmem last (List.mem_append_right _ (List.mem_singleton_self _))
  obtain ⟨wb, hlen, hwa, hwlt, hwr⟩ := nop_step (ch := ch) hmode hρ hokL
    (hpl iL (List.mem_append_right _ (List.mem_singleton_self _))) (st := st1) (E := E1)
    (fun p hp x hx => henv1 p (hsrcL p hp) x hx)
    (fun p hp => by
      rcases List.mem_cons.mp hp with rfl | hp
      · exact hWofs _ (hDWW _ hdstL)
      · exact hWofs _ (hsrcL p hp)) hvL
  rw [hlastd] at hlen hwr hwlt
  have hpw : ∀ k < wb.length, st1.escapedAt (sd.off + k) = none := by
    intro k hk
    rw [hlen] at hk
    cases he' : st1.escapedAt (sd.off + k) with
    | none => rfl
    | some e'' =>
      have h1 := hrel1.esc _ _ he'
      rw [hprivD k (by rw [hszd]; exact hk)] at h1
      cases h1
  obtain ⟨st2, hw2⟩ : ∃ st2, st1.writeFrame sd.off wb = .ok st2 := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  obtain ⟨vw, hvw, hctl, hop⟩ := hwr st2 hw2
  have hiL : c.d.insns[s1.pc + is1.length]? = some iL := by
    have := hins is1.length (by simp)
    rw [this]
    simp
  have hscL : c.scopesAt (s1.pc + is1.length) = [] := hsc _ (by simp)
  have hstepL : R.step c { s1 with pc := s1.pc + is1.length, st := st1 } ch =
      .ok (.step { s1 with pc := s1.pc + is1.length + 1, st := st2 }) :=
    step_of_view hiL hscL hpeR (hpl iL (List.mem_append_right _ (List.mem_singleton_self _)))
      hvw hctl hop
  -- `_d` related
  obtain ⟨ad, xd, hpdp, hιd, hxd, hlived, haddrd, hpaddrd, hsized, hprivd'⟩ :=
    hrel1.priv_dst hpd hsd hpos hprivD
  have hX : t.toBits (t.bringInBounds (discrTy.bringInBounds ((vs[idx]?.map (·.discr)).getD 0))) %
      2 ^ (8 * t.size) = idx % 2 ^ (8 * t.size) := by
    have hmemI : idx ∈ untagged :: List.range (lo + (hi - lo) + 1) := by
      rcases niche_idx henc htv with h1 | h1
      · rw [h1]; exact List.mem_cons_self ..
      · exact List.mem_cons_of_mem _ (List.mem_range.mpr h1)
    have := List.all_eq_true.mp hagree idx hmemI
    simpa using this
  have hbs : BytesInj ι (encodeBits t.size (t.toBits (t.bringInBounds (discrTy.bringInBounds
      ((vs[idx]?.map (·.discr)).getD 0))))) wb := by
    rw [← encodeBits_mod, hX, ← hvV]
    exact bytesInj_encodeBits_of_decode (decodeBits_of_asNat hwa) hlen
  have hlen0 : (encodeBits t.size (t.toBits (t.bringInBounds (discrTy.bringInBounds
      ((vs[idx]?.map (·.discr)).getD 0))))).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hszd]
  obtain ⟨hmi, hrd'⟩ := writeLocal_priv hrel1.frame.mem ad xd hpdp hιd hxd hlived haddrd hpaddrd
    hsized hprivd' hbs hlen0 hsto hw2
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  have hrelF := hrel1.after (pc' := s1.pc + is1.length + 1) hpd hsd hmi hrd'
    (fun slot p lv hr hne' hap' => by
      have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne'))
      exact LocalRel.writeFrame_apart h1 hw2 hpw (by rw [hlen, ← hszd]; exact hap'))
    (hrel1.hidden.store_noprov hsto (encodeBits_noprov _ _)) hesc
    (live' := live') (fun l hl => by
      rcases hlive' l hl with h1 | h1
      · exact .inl h1
      · by_cases hld : l = d
        · exact .inl hld
        · right
          simp [h1, hld])
  obtain ⟨hpb', hle', hk'⟩ := memInv_store hpb hsto (encodeBits_noprov _ _)
  have e2 : s1.pc + is1.length + 1 = s1.pc + (is1 ++ [iL]).length := by
    simp only [List.length_append, List.length_singleton]; omega
  have hsteps : StepsTo c ch s1 { s1 with pc := s1.pc + is1.length + 1, st := st2 } :=
    stepsTo_append hst1 (.cons hstepL (.refl _))
  have hrelF' : FnRel Γ ι live' f s'.mem { s1 with pc := s1.pc + is1.length + 1, st := st2 } :=
    hrelF
  rw [e2] at hsteps hrelF'
  exact ⟨st2, hsteps, hstk, hrelF', hpb', hle', hk'⟩

/-- The statement's `StmtOut` (`stmt_sim`'s case), as `stmt_sim_enum`'s `agg`. -/
theorem stmt_sim_nicheRead {Γ : TermCtx} {c : R.Code} {ι : Inj} {o : Spec.Oracle}
    {ch : OpSem.Choice} (hfn : LowersFn Γ c.d) (hmode : c.mode = Γ.mode) (hρ : c.ρ = Γ.ρ)
    {s s1x : Spec.State} {s1 : R.RState} {f : Spec.Frame} {rest : List Spec.Frame}
    {blk : BlockCert} {bd : BlockData} (M : MatchAt Γ ι s s1 f rest blk bd)
    {st : Statement} (hst : bd.stmts[f.stmt]? = some st) {r : Range}
    (hr : blk.stmts[f.stmt]? = some r) (h1 : r.1 ≤ r.2) (h2 : r.2 ≤ c.d.insns.size)
    (h : LowerNicheRead Γ.toStmtCtx st (rangeInsns c.d r))
    (hev : runOn (evalStatement st) o s = (.ok (), s1x)) :
    StmtOut Γ c ch ι f rest r s s1x s1 := by
  obtain ⟨d, rv, rfl⟩ : ∃ d rv, st = .assign ⟨d, []⟩ rv := by
    generalize rangeInsns c.d r = is at h
    cases h
    exact ⟨_, _, rfl⟩
  have hpc0 : s1.pc = r.1 := by rw [← M.pc, pcAt_some hr]
  have hpe : c.mode.pe = false := by rw [hmode]; exact hfn.notPe
  have hlen := rangeInsns_length (r := r) h2
  have hi : ∀ j (hj : j < (rangeInsns c.d r).length),
      c.d.insns[s1.pc + j]? = some ((rangeInsns c.d r)[j]'hj) := by
    rw [hpc0]; exact rangeInsns_at h2
  have hsc' : ∀ j, j < (rangeInsns c.d r).length → c.scopesAt (s1.pc + j) = [] :=
    fun _ _ => scopesAt_nil hfn.noScopes _
  have hpl : ∀ i ∈ rangeInsns c.d r, PlainView c.mode c.ρ i := by
    intro i hmem
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hmem
    rw [hmode, hρ]
    exact hfn.plain _ _ (hi j hj)
  obtain ⟨hl1, hl2⟩ := assign_live hfn.live M.hbd hst
  refine stmtOut_of_liftN (k := (rangeInsns c.d r).length) M.stack hfn.storage M.hbd hst M.sl
    M.fresh M.dinv (by rw [hpc0, hlen]; omega) ?_
  exact lift_nicheRead M.stack M.body.symm hmode.symm hρ.symm h hi hsc' hpe hpl M.rel M.pb hl2
    hl1 hev

end Ryo.Proofs.Lower
