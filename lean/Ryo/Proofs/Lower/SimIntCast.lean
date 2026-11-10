/-
Ryo.Proofs.Lower.SimIntCast — the simulation of the integer-cast rules (`LowerIntCast`,
`Ryo.Check.Lower.IntCast`, M5b): `_d = cast intToInt (_a) (int t' _)` from a whole int-like
local `_a` (`castSrc ta = some ts`) into a whole private integer local `_d`, lowered to one
`mov` (same width) or one `cvt` handler (`zext`/`sext`/`trunc`).

- L0 side: the assignment loads `_a` at its type, reads the value as an integer (`intLike`,
  as the relation `IntLikeVal`), and stores `t'.bringInBounds i` at `_d`'s type
  (`assign_intCast_inv`). At every int-like source type, that integer is `ts.ofBits u` for
  the bits `u` of the `ts.size` bytes loaded (`castSrc_load`).
- Arithmetic: `cvt`'s result (`cvtInt`, `OpSem.convert` between integer types) on those bits
  is the bit pattern of L0's value at `t'` when the handler's source signedness is the
  source's or the cast narrows (`cvt_bytes`); at the same width, L0's value has the source's
  bits (`cast_mov_bytes`).
- R side: the forward direction of `Inline.opSem_ext` (`opSem_cvt_fwd`); the `mov` case uses
  `opSem_mov_fwd`.
- `sim_castExt`/`sim_castMov`: the statement's simulation, in `sim_copyInt`'s shape;
  `lift_intCast`: the lift to R's `step` (`LiftOut`), as `lift_copyInt` plus `memInv_store`.

Beyond the common lift hypotheses, `lift_intCast` takes `IntsSized f.body` (`LowersFn.ints`):
`_d`'s slot is not empty, so `FnRel.priv_dst` applies.
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Check.Lower.IntCast

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower

/-! ### The instruction form -/

theorem castInsnOk_spec {Γ : StmtCtx} {i : R.Insn} {n : Nat} {sg : Bool} {n' : Nat} {d s : Int}
    (h : castInsnOk Γ i n sg n' d s = true) :
    ∃ v tx ty r sx sy, R.view Γ.mode Γ.ρ i = some v ∧
      v.op.handler? = some ⟨.cvt, [tx, ty], r⟩ ∧
      OpSem.Ty.parse tx = some (.int n sx) ∧ OpSem.Ty.parse ty = some (.int n' sy) ∧
      (sx = sg ∨ n' ≤ n) ∧ v.op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩] ∧
      v.ops = [.slot d, .slot s] ∧ v.ctl = some .next := by
  unfold castInsnOk at h
  split at h
  next v hv =>
    split at h
    next kd tx ty r hh =>
      split at h
      next nx sx ny sy htx hty =>
        simp only [Bool.and_eq_true, beq_iff_eq, Bool.or_eq_true, decide_eq_true_eq] at h
        obtain ⟨⟨⟨⟨⟨⟨hkd, hnx⟩, hny⟩, hsx⟩, ho⟩, hops⟩, hctl⟩ := h
        subst hkd hnx hny
        exact ⟨v, tx, ty, r, sx, sy, hv, hh, htx, hty, hsx, ho, hops, hctl⟩
      · cases h
    · cases h
  · cases h

/-! ### L0 -/

/-- `intLike`'s result on a value, as a relation. -/
def IntLikeVal : Value → Int → Prop
  | .int j, i => i = j
  | .bool b, i => i = if b then 1 else 0
  | _, _ => False

/-- An `IntToInt` cast of a whole local (`copy` or `move`) into a whole local, run to success:
both locals are live, the source loads at its type, `intLike` reads it as `i`, and the store
writes `t'.bringInBounds i` at the destination's type; the state changes only by that store.

Proof: as `assign_binop_inv` (`runOn_evalPlace_nil`, `runOn_localPlace_ok`, `runOn_bind_ok`,
`runOn_placeStore_ok`), after rewriting `move` to `copy` (`local?_cases`, `evalOperand_move`).
`evalRvalue (.cast k o ty) _ = evalOperand o >>= fun v => evalCast k v ty` (by `rfl` or
`unfold evalRvalue`); `runOn_evalOperand_copy` gives the load. `evalCast .intToInt (v, ta)
(.int t' vc)` is `intLike v >>= fun i => pure (.int (t'.bringInBounds i))`: case on `v`
(`intLike`'s non-`int`/`bool` arms throw: `prod_err_ok`). -/
theorem assign_intCast_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    (ha : oa.local? = some a) {t' : IntType} {vc : ValidRange}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast .intToInt oa (.int t' vc)))) o s =
      (.ok (), s')) :
    ∃ pd pa td ta va i, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      f.body.locals[d]? = some td ∧ f.body.locals[a]? = some ta ∧
      typedLoad s.mem pa ta .one = .ok va ∧ IntLikeVal va i ∧
      ∃ mem', typedStore s.mem pd (.int (t'.bringInBounds i)) td .one = .ok mem' ∧
        s' = { s with mem := mem' } := by
  rcases local?_cases ha with rfl | rfl
  all_goals
    have hn : evalStatement (.assign ⟨d, []⟩ (.cast .intToInt (.move ⟨a, []⟩) (.int t' vc))) =
        evalStatement (.assign ⟨d, []⟩ (.cast .intToInt (.copy ⟨a, []⟩) (.int t' vc))) := by
      first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]
    try rw [hn] at h
    clear hn
    have e : evalStatement (.assign ⟨d, []⟩ (.cast .intToInt (.copy ⟨a, []⟩) (.int t' vc))) =
        (evalPlace ⟨d, []⟩ >>= fun x => match x with
          | (pl, ty) => evalRvalue (.cast .intToInt (.copy ⟨a, []⟩) (.int t' vc)) ty >>=
              fun v => placeStore pl v ty) := by
      first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
    rw [e] at h
    obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
    rw [runOn_evalPlace_nil] at h1
    obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
    subst hx
    have h2' : runOn (evalRvalue (.cast .intToInt (.copy ⟨a, []⟩) (.int t' vc)) td >>= fun v =>
        placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
    rw [hs1] at h2'
    obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
    have e2 : evalRvalue (.cast .intToInt (.copy ⟨a, []⟩) (.int t' vc)) td =
        (evalOperand (.copy ⟨a, []⟩) >>= fun r => evalCast .intToInt r (.int t' vc)) := by
      first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
    rw [e2] at h3
    obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
    obtain ⟨pa, ta, va, hla, hta, hva, hr, hs3⟩ := runOn_evalOperand_copy hs h5
    subst r
    subst s3
    have e3 : evalCast .intToInt (va, ta) (.int t' vc) =
        (intLike va >>= fun i => pure (.int (t'.bringInBounds i))) := by
      first | rfl | (unfold evalCast; rfl) | simp only [evalCast]
    rw [e3] at h6
    obtain ⟨i, s4, h7, h8⟩ := runOn_bind_ok h6
    rw [runOn_pure] at h8
    obtain ⟨hv, hs42⟩ := prod_ok_inj h8
    subst v
    have hil : IntLikeVal va i ∧ s4 = s := by
      cases va
      all_goals first
        | (obtain ⟨h1, h2⟩ := prod_ok_inj h7; exact ⟨h1.symm, h2.symm⟩)
        | exact (prod_err_ok h7).elim
        | cases h7
        | (simp [runOn, intLike, throwIllFormed] at h7; done)
    rw [← hs42, hil.2] at h4
    obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
    exact ⟨pd, pa, td, ta, va, i, hld, hla, htd, hta, hva, hil.1, mem', hst, hs'⟩

/-- A load at an int-like type read as an integer: `ts.ofBits` of the bits of the `ts.size`
bytes loaded.

Proof: by cases on `ta` (`castSrc`). `int t`: `typedLoad_int`. `bool`: `typedLoad_inv` with
`size?_bool`, `decode_bool_inv` (the byte is `.init 0 _` or `.init 1 _`: unfold `Ty.decode`
and split as `decode_bool_inv` does), `decodeBits [.init x f] = some x.toNat` (`decodeBits_iff`
or by `simp [decodeBits]`), and `IntType.u8.ofBits 0 = 0`, `ofBits 1 = 1` (`decide`/`rfl`).
`char`: `typedLoad_inv` (`Spec.Ty.char.size? = some 4`, by `rfl`), unfold `Ty.decode`: the
value is `.int n` with `decodeBits bs = some n`, `bs.length = 4`; `u32.ofBits n = n` since
`n < 2 ^ 32` (`Ryo.Spec.Theorems.decodeBits_length`, `Nat.mod_eq_of_lt`). -/
theorem castSrc_load {mem : Memory} {p : ThinPointer} {ta : Spec.Ty} {ts : IntType}
    {va : Value} {i : Int} (hts : castSrc ta = some ts) (hl : typedLoad mem p ta .one = .ok va)
    (hi : IntLikeVal va i) :
    ∃ bs u, mem.load p ts.size .one = .ok bs ∧ decodeBits bs = some u ∧
      bs.length = ts.size ∧ i = ts.ofBits u := by
  cases ta
  case int t valid =>
    have e : t = ts := Option.some.inj (hts : some t = some ts)
    subst e
    obtain ⟨bs, u, hl', hd, hlen, rfl⟩ := typedLoad_int hl
    exact ⟨bs, u, hl', hd, hlen, hi⟩
  case bool =>
    have e : ts = IntType.u8 := (Option.some.inj (hts : some IntType.u8 = some ts)).symm
    subst e
    obtain ⟨bs, hl', hd⟩ := typedLoad_inv size?_bool hl
    obtain ⟨x, f0, rfl, -⟩ := decode_bool_inv hd
    by_cases h0 : x = 0
    · subst h0
      have hdf : Spec.Ty.bool.decode [.init 0 f0] = some (.bool false) := by
        first | rfl | simp [Spec.Ty.decode]
      have hv : va = .bool false := Option.some.inj (hd.symm.trans hdf)
      subst hv
      have hi0 : i = 0 := by simpa [IntLikeVal] using hi
      refine ⟨_, 0, hl', ?_, rfl, ?_⟩
      · first | rfl | simp [decodeBits, AbstractByte.data]
      · rw [hi0]; first | rfl | decide
    · by_cases h1 : x = 1
      · subst h1
        have hdt : Spec.Ty.bool.decode [.init 1 f0] = some (.bool true) := by
          first | rfl | simp [Spec.Ty.decode]
        have hv : va = .bool true := Option.some.inj (hd.symm.trans hdt)
        subst hv
        have hi1 : i = 1 := by simpa [IntLikeVal] using hi
        refine ⟨_, 1, hl', ?_, rfl, ?_⟩
        · first | rfl | simp [decodeBits, AbstractByte.data]
        · rw [hi1]; first | rfl | decide
      · exfalso
        have hn : Spec.Ty.bool.decode [.init x f0] = none := by
          first
            | (simp only [Spec.Ty.decode]; split <;> simp_all)
            | simp [Spec.Ty.decode, h0, h1]
        rw [hn] at hd
        cases hd
  case char =>
    have e : ts = IntType.u32 := (Option.some.inj (hts : some IntType.u32 = some ts)).symm
    subst e
    obtain ⟨bs, hl', hd⟩ := typedLoad_inv (n := 4) (by first | rfl | decide) hl
    have hlen : bs.length = 4 := by
      by_cases hne : bs.length = 4
      · exact hne
      · simp [Spec.Ty.decode, hne] at hd
    cases hdb : decodeBits bs with
    | none => simp [Spec.Ty.decode, hlen, hdb] at hd
    | some n =>
      have hv : va = .int n := by
        by_cases hu : isUnicodeScalar n = true
        · simp [Spec.Ty.decode, hlen, hdb, hu] at hd
          first | exact hd.symm | exact hd
        · simp [Spec.Ty.decode, hlen, hdb, hu] at hd
      subst hv
      have hn := Ryo.Spec.Theorems.decodeBits_length hdb
      rw [hlen] at hn
      refine ⟨bs, n, hl', hdb, hlen, ?_⟩
      have hi' : i = (n : Int) := hi
      rw [hi']
      have hm : n % IntType.u32.modulus = n := Nat.mod_eq_of_lt (by exact hn)
      have hs : IntType.u32.signed = false := rfl
      simp [IntType.ofBits, hs, hm]
  all_goals first | (simp [castSrc] at hts; done) | cases hts

/-! ### Arithmetic -/

/-- `cvt`'s result between integer types (`OpSem.convert` of `.int nx sx` to `.int ny _`). -/
def cvtInt (nx : Nat) (sx : Bool) (ny v : Nat) : Nat :=
  (BitVec.ofInt (8 * ny) (if sx then (BitVec.ofNat (8 * nx) v).toInt else (v : Int))).toNat

/-- `ofBits` of bits already below the modulus. -/
theorem ofBits_lt (t : IntType) {u : Nat} (hu : u < 2 ^ (8 * t.size)) :
    t.ofBits u = if t.signed && u ≥ 2 ^ (t.size * 8 - 1) then (u : Int) - (2 ^ (8 * t.size) : Nat)
      else (u : Int) := by
  first
    | (unfold IntType.ofBits IntType.bits; rw [← modulus_eq_two_pow, Nat.mod_eq_of_lt hu]; done)
    | (unfold IntType.ofBits IntType.bits; rw [← modulus_eq_two_pow, Nat.mod_eq_of_lt hu]; rfl)
    | (simp only [IntType.ofBits, IntType.bits, ← modulus_eq_two_pow, Nat.mod_eq_of_lt hu]; done)

/-- Below `2 ^ (8 n)`, `2 u` is below it iff `u` is below half of it. -/
theorem two_mul_lt_iff {n u : Nat} (hu : u < 2 ^ (8 * n)) :
    2 * u < 2 ^ (8 * n) ↔ ¬ u ≥ 2 ^ (n * 8 - 1) := by
  cases n with
  | zero =>
    have h1 : 2 ^ (8 * 0) = 1 := rfl
    rw [h1] at hu
    have hu0 : u = 0 := by omega
    subst hu0
    decide
  | succ k =>
    have he : 8 * (k + 1) = ((k + 1) * 8 - 1) + 1 := by omega
    rw [he, Nat.pow_add, Nat.pow_one]
    constructor <;> intro h <;> omega

/-- `cvt`'s bytes are those L0 stores: the cast value's bit pattern at `t'`, provided the
handler's source signedness is the source's or the cast narrows.

Proof: `intBytes` is `encodeBits` (`rfl`); show the values equal. Right side:
`t'.toBits (t'.bringInBounds x) = t'.toBits x` (`IntType.toBits_eq_of_emod` with
`IntType.bringInBounds_emod`), i.e. `(x % 2 ^ (8 t'.size)).toNat` (`modulus_eq_two_pow`). Left
side: `BitVec.toNat_ofInt` gives `(y % 2 ^ (8 t'.size)).toNat` for the handler's integer `y`.
It remains `y ≡ ts.ofBits u (mod 2 ^ (8 t'.size))`: unfold `IntType.ofBits` (with
`Nat.mod_eq_of_lt hu`) and `BitVec.toInt` (`BitVec.toNat_ofNat`, `Nat.mod_eq_of_lt hu`); when
`sx = ts.signed` both are the same `if` (the conditions `2 * u < 2 ^ w` and
`¬ u ≥ 2 ^ (w - 1)` agree for `w = 8 ts.size > 0`; `ts.size = 0` forces `u = 0`); otherwise they
differ by `2 ^ (8 ts.size)`, a multiple of `2 ^ (8 t'.size)` since `t'.size ≤ ts.size`
(`Nat.pow_dvd_pow`, `Int.emod_emod_of_dvd`/`Int.add_mul_emod_self`). `omega` needs the
`Size` facts `dsimp only [Size]`'d first. -/
theorem cvt_bytes (ts t' : IntType) (sx : Bool) {u : Nat} (hu : u < 2 ^ (8 * ts.size))
    (hsx : sx = ts.signed ∨ t'.size ≤ ts.size) :
    intBytes t'.size (cvtInt ts.size sx t'.size u) =
      encodeBits t'.size (t'.toBits (t'.bringInBounds (ts.ofBits u))) := by
  have key : ∀ (t : IntType) (y : Int), (BitVec.ofInt (8 * t.size) y).toNat = t.toBits y := by
    intro t y
    rw [BitVec.toNat_ofInt]
    unfold IntType.toBits
    rw [← modulus_eq_two_pow]
  unfold cvtInt intBytes
  rw [key]
  congr 1
  apply Ryo.Spec.Theorems.IntType.toBits_eq_of_emod
  rw [Ryo.Spec.Theorems.IntType.bringInBounds_emod]
  rcases hsx with rfl | hle
  · congr 1
    rw [ofBits_lt ts hu, BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hu]
    cases hsg : ts.signed
    · first | rfl | simp
    · by_cases h2 : 2 * u < 2 ^ (8 * ts.size)
      · have h3 : ¬ u ≥ 2 ^ (ts.size * 8 - 1) := (two_mul_lt_iff hu).mp h2
        have h4 : ¬ ((true && decide (u ≥ 2 ^ (ts.size * 8 - 1))) = true) := by simpa using h3
        rw [if_pos (rfl : true = true), if_pos h2, if_neg h4]
      · have h3 : u ≥ 2 ^ (ts.size * 8 - 1) :=
          Classical.byContradiction fun h => h2 ((two_mul_lt_iff hu).mpr h)
        have h4 : (true && decide (u ≥ 2 ^ (ts.size * 8 - 1))) = true := by simpa using h3
        rw [if_pos (rfl : true = true), if_neg h2, if_pos h4]
  · have hdvd : (t'.modulus : Int) ∣ (ts.modulus : Int) := by
      rw [← modulus_eq_two_pow, ← modulus_eq_two_pow]
      exact Int.natCast_dvd_natCast.mpr (Nat.pow_dvd_pow 2 (Nat.mul_le_mul_left 8 hle))
    have hy : (if sx = true then (BitVec.ofNat (8 * ts.size) u).toInt else (u : Int)) %
        (ts.modulus : Int) = (u : Int) % ts.modulus := by
      split
      · rw [BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hu]
        split
        · rfl
        · rw [← modulus_eq_two_pow, Int.sub_emod, Int.emod_self, Int.sub_zero, Int.emod_emod]
      · rfl
    rw [← Int.emod_emod_of_dvd
      (if sx = true then (BitVec.ofNat (8 * ts.size) u).toInt else (u : Int)) hdvd, hy,
      ← Int.emod_emod_of_dvd (ts.ofBits u) hdvd,
      Ryo.Spec.Theorems.IntType.ofBits_emod]

/-- At the same width, L0's stored bytes are the bits loaded.

Proof: `t'.toBits (t'.bringInBounds x) = t'.toBits x` (as in `cvt_bytes`); `t'.toBits` and
`ts.toBits` agree (they only use the size: unfold `IntType.toBits`, `IntType.modulus`,
`IntType.bits`, rewrite `hw`), and `ts.toBits (ts.ofBits u) = u % ts.modulus`
(`IntType.toBits_ofBits`); then `modulus_eq_two_pow` and `encodeBits_mod`. -/
theorem cast_mov_bytes (ts t' : IntType) (hw : ts.size = t'.size) (u : Nat) :
    encodeBits t'.size (t'.toBits (t'.bringInBounds (ts.ofBits u))) = encodeBits t'.size u := by
  rw [Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t'
    (Ryo.Spec.Theorems.IntType.bringInBounds_emod t' (ts.ofBits u))]
  have hm : t'.modulus = ts.modulus := by
    unfold IntType.modulus IntType.bits
    rw [hw]
  have ht : t'.toBits (ts.ofBits u) = ts.toBits (ts.ofBits u) := by
    unfold IntType.toBits
    rw [hm]
  rw [ht, Ryo.Spec.Theorems.IntType.toBits_ofBits, ← modulus_eq_two_pow, hw, encodeBits_mod]

/-! ### R -/

/-- The footprint of a `cvt` handler from `nx` to `ny` bytes. -/
def cvtFp (nx ny : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "s" nx], writes := [Ryo.Proofs.Inline.rdA "d" ny] }

/-- The forward direction of `Inline.opSem_ext`.

Proof: as `opSem_mov_fwd`, with the footprint `Inline.fp_cvt (tySize_of_parse htx)
(tySize_of_parse hty)` (`{ reads := [rdA "s" nx], writes := [rdA "d" ny] }`), and `kindSem
.cvt [tx, ty]` computed by `simp [kindSem, parseTy, htx, hty, convert, OpSem.Ty.size, mkEnv,
Env.int, hv, out, bind, Except.bind, pure, Except.pure]`; the commit's length check by
`Ryo.Spec.Theorems.encodeBits_length`. -/
theorem opSem_cvt_fwd {op : Full.Opcode} {r : Option String} {tx ty : String} {nx ny : Nat}
    {sx sy : Bool} {d s : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hh : op.handler? = some ⟨.cvt, [tx, ty], r⟩) (htx : OpSem.Ty.parse tx = some (.int nx sx))
    (hty : OpSem.Ty.parse ty = some (.int ny sy))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ s ∧ s < 2 ^ 31)
    {bs : List AbstractByte} {v : Nat} (hr : st.readFrame s nx = .ok bs) (hv : asNat bs = .ok v)
    (hw : st.writeFrame d (intBytes ny (cvtInt nx sx ny v)) = .ok st') :
    opSem op [.slot d, .slot s] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, hs1, hs2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfs := slot_fits hs1 hs2
  have hfp : footprint op = some (cvtFp nx ny) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    exact Ryo.Proofs.Inline.fp_cvt (Ryo.Proofs.Inline.tySize_of_parse htx)
      (Ryo.Proofs.Inline.tySize_of_parse hty)
  have hprep : prepare op [.slot d, .slot s] =
      .ok (⟨.cvt, [tx, ty], r⟩, (cvtFp nx ny), opndVal op.info [.slot d, .slot s]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfs])]
    rfl
  have hvs : opndVal op.info [.slot d, .slot s] "s" = some (.slot s) := by
    simp [opndVal, ho]
  have hvd : opndVal op.info [.slot d, .slot s] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (cvtFp nx ny) (opndVal op.info [.slot d, .slot s]) st = .ok [("s", bs)] := by
    simp only [readAll, cvtFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hvs, Val.slotOff, Extent.eval, hr,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem .cvt [tx, ty] (mkEnv [("s", bs)] (opndVal op.info [.slot d, .slot s]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes ny (cvtInt nx sx ny v))] } := by
    simp [kindSem, parseTy, htx, hty, convert, OpSem.Ty.size, mkEnv, Env.int, hv, out, cvtInt,
      bind, Except.bind, pure, Except.pure]
  have hlen : (intBytes ny (cvtInt nx sx ny v)).length = ny :=
    Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (cvtFp nx ny) (opndVal op.info [.slot d, .slot s]) st
      [("d", intBytes ny (cvtInt nx sx ny v))] = .ok st' := by
    simp only [commit, cvtFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd, Val.slotOff, Extent.eval, hlen,
      hw, bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | (rw [hc]; done)
    | (rw [hst, hc]; done)
    | (erw [hc]; done)
    | (rw [hc]; rfl)
    | (erw [hc]; rfl)

/-! ### The simulations -/

/-- `castExt`'s simulation: a `cvt` from `_a`'s slot to `_d`'s.

Proof: as `sim_copyInt`: `assign_intCast_inv` (unify the locals and types with `htd`/`hta`),
`castSrc_load` for the source's bytes `bs` and bits `u`, `typedStore_int` for the store of
`encodeBits t'.size (t'.toBits (t'.bringInBounds (ts.ofBits u)))`; `readLocal_inj` (at
`sa.size = ts.size`) and `decodeBits_inj` for R's bytes `ba` and `asNat ba = .ok u`; R's write
of `intBytes t'.size (cvtInt ts.size sx t'.size u)` (`writeEscaped_private'`), `cvt_bytes`
(with `hu` from `Ryo.Spec.Theorems.decodeBits_length`) to make it L0's bytes, `opSem_cvt_fwd`;
then `writeLocal_priv` (`encodeBits_inj`), `LocalRel.store_other`,
`LocalRel.writeFrame_apart`. -/
theorem sim_castExt {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {oa : Operand} (ha : oa.local? = some a) {ta : Spec.Ty} {ts t' : IntType}
    {vd vc : ValidRange}
    (htd : f.body.locals[d]? = some (.int t' vd)) (hta : f.body.locals[a]? = some ta)
    (hts : castSrc ta = some ts)
    {sd sa : LocalSlot} (hsd : sd.size = t'.size) (hsa : sa.size = ts.size)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true)
    -- `_d` private
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    -- the instruction
    {opc : Full.Opcode} {r : Option String} {tx ty : String} {sx sy : Bool}
    (hh : opc.handler? = some ⟨.cvt, [tx, ty], r⟩)
    (htx : OpSem.Ty.parse tx = some (.int ts.size sx))
    (hty : OpSem.Ty.parse ty = some (.int t'.size sy))
    (hsx : sx = ts.signed ∨ t'.size ≤ ts.size)
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast .intToInt oa (.int t' vc)))) o s =
      (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', pa', td, ta', va, i, hpd', hpa', htd', hta', hla, hil, mem', hst, rfl⟩ :=
    assign_intCast_inv hs ha h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .int t' vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = ta := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  -- the load: the source's bits
  obtain ⟨bsa, ua, hloa, hda, hlena, rfl⟩ := castSrc_load hts hla hil
  -- the store: the cast value's bit pattern
  have hsto := typedStore_int hst
  -- R's read
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa] at hrfa
  have hda' := decodeBits_inj hia hda
  have hva : asNat ba = .ok ua := by unfold asNat; rw [hda']; rfl
  have hu : ua < 2 ^ (8 * ts.size) := by
    have h0 := Ryo.Spec.Theorems.decodeBits_length hda
    rw [hlena] at h0
    exact h0
  -- R's write
  have hlenw : (intBytes t'.size (cvtInt ts.size sx t'.size ua)).length = t'.size :=
    Ryo.Spec.Theorems.encodeBits_length _ _
  have hpw : ∀ k < (intBytes t'.size (cvtInt ts.size sx t'.size ua)).length,
      st.escapedAt (sd.off + k) = none := by
    intro k hk
    rw [hlenw, ← hsd] at hk
    exact hprivd k hk
  obtain ⟨st', hwr⟩ : ∃ st',
      st.writeFrame sd.off (intBytes t'.size (cvtInt ts.size sx t'.size ua)) = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_cvt_fwd (ch := ch) hh htx hty ho hfits hrfa hva hwr
  have hwr' := hwr
  rw [cvt_bytes ts t' sx hu hsx] at hwr'
  have hbs := encodeBits_inj ι t'.size (t'.toBits (t'.bringInBounds (ts.ofBits ua)))
  have hlen0 : (encodeBits t'.size (t'.toBits (t'.bringInBounds (ts.ofBits ua)))).length =
      sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr'
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlenw, ← hsd]; exact hap)

/-- `castMov`'s simulation: a `mov` of `t'.size` bytes from `_a`'s slot to `_d`'s.

Proof: as `sim_copyInt`, with `assign_intCast_inv` and `castSrc_load` for the L0 side and
`cast_mov_bytes` (so L0 stores `encodeBits t'.size u`); R moves the bytes `ba` it read
(`opSem_mov_fwd`), which L0's refine (`bytesInj_encodeBits_of_decode`). -/
theorem sim_castMov {ι : Inj} {fp : Nat} {st : OpSem.State} {o : Spec.Oracle}
    {s s' : Spec.State} {f : Spec.Frame} {rest : List Spec.Frame} (hs : s.stack = f :: rest)
    {d a : Local} {oa : Operand} (ha : oa.local? = some a) {ta : Spec.Ty} {ts t' : IntType}
    {vd vc : ValidRange}
    (htd : f.body.locals[d]? = some (.int t' vd)) (hta : f.body.locals[a]? = some ta)
    (hts : castSrc ta = some ts) (hw : ts.size = t'.size)
    {sd sa : LocalSlot} (hsd : sd.size = t'.size) (hsa : sa.size = ts.size)
    {pd pa : ThinPointer} (hpd : f.locals[d]? = some (some pd))
    (hpa : f.locals[a]? = some (some pa))
    (hmem : MemInj ι s.mem st.mem)
    (hra : LocalRel ι fp st s.mem sa pa true)
    -- `_d` private
    (ad : AllocId) (xd : Allocation) (hpdp : pd.prov = some ad) (hιd : ι ad = none)
    (hxd : s.mem.get? ad = some xd) (hlived : xd.live = true)
    (haddrd : (xd.addr : Int) = fp + sd.off) (hpaddrd : pd.addr = xd.addr)
    (hsized : xd.data.size = sd.size)
    (hprivd : ∀ k < sd.size, st.escapedAt (sd.off + k) = none)
    -- the instruction
    {opc : Full.Opcode} {r : Option String} {ty : String} {sg : Bool}
    (hh : opc.handler? = some ⟨.mov, [ty], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int t'.size sg))
    (ho : opc.info.operands = [⟨"d", .slot⟩, ⟨"s", .slot⟩])
    (hfits : -2 ^ 31 ≤ sd.off ∧ sd.off < 2 ^ 31 ∧ -2 ^ 31 ≤ sa.off ∧ sa.off < 2 ^ 31)
    {ch : OpSem.Choice}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast .intToInt oa (.int t' vc)))) o s =
      (.ok (), s')) :
    ∃ st', opSem opc [.slot sd.off, .slot sa.off] st ch = .ok (.next, st') ∧
      MemInj ι s'.mem st'.mem ∧ LocalRel ι fp st' s'.mem sd pd true ∧
      ∀ (slot : LocalSlot) p lv, LocalRel ι fp st s.mem slot p lv → p.prov ≠ pd.prov →
        (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
        LocalRel ι fp st' s'.mem slot p lv := by
  obtain ⟨pd', pa', td, ta', va, i, hpd', hpa', htd', hta', hla, hil, mem', hst, rfl⟩ :=
    assign_intCast_inv hs ha h
  have e1 : pd' = pd := Option.some.inj (Option.some.inj (hpd'.symm.trans hpd))
  have e2 : pa' = pa := Option.some.inj (Option.some.inj (hpa'.symm.trans hpa))
  have e4 : td = .int t' vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = ta := Option.some.inj (hta'.symm.trans hta)
  subst e1 e2 e4 e5
  -- the load: the source's bits
  obtain ⟨bsa, ua, hloa, hda, hlena, rfl⟩ := castSrc_load hts hla hil
  -- the store: the same bits
  have hsto := typedStore_int hst
  rw [cast_mov_bytes ts t' hw ua] at hsto
  -- R's read
  rw [← hsa] at hloa
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hmem hra hloa
  rw [hsa, hw] at hrfa
  have hda' := decodeBits_inj hia hda
  have hlenb : ba.length = t'.size := ((BytesInj.length hia).symm.trans hlena).trans hw
  -- R's write
  have hpw : ∀ k < ba.length, st.escapedAt (sd.off + k) = none := by
    intro k hk
    rw [hlenb, ← hsd] at hk
    exact hprivd k hk
  obtain ⟨st', hwr⟩ : ∃ st', st.writeFrame sd.off ba = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_mov_fwd (ch := ch) hh hty ho hfits hrfa hlenb hwr
  have hbs : BytesInj ι (encodeBits t'.size ua) ba := bytesInj_encodeBits_of_decode hda' hlenb
  have hlen0 : (encodeBits t'.size ua).length = sd.size := by
    rw [Ryo.Spec.Theorems.encodeBits_length, hsd]
  obtain ⟨hmi, hrd⟩ := writeLocal_priv hmem ad xd hpdp hιd hxd hlived haddrd hpaddrd hsized
    hprivd hbs hlen0 hsto hwr
  refine ⟨st', hop, hmi, hrd, ?_⟩
  intro slot p lv hr hne hap
  have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
  exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlenb, ← hsd]; exact hap)

/-! ### The lift -/

/-- `LowerIntCast`'s lift (`hwf`: `LowersFn.ints`).

Proof: `cases hlow`; in each case, as `lift_copyInt`: `castInsnOk_spec`/`movInsnOk_spec` and
`intTyOk_spec` for the instruction (rewrite `hmode`, `hρ` into the view), `hbody` into the
local types, `assign_intCast_inv` for `pd`/`pa`, `hlo a (operand_local_mem ha)` (`rvalueLocals`
of a cast is its operand's `operandLocals`, by `rfl`) with `FnRel.opnd`,
`IntsSized` for `0 < sd.size` and `FnRel.priv_dst`, `offOk_spec`, then `sim_castExt`/
`sim_castMov`. The L0 store is provenance-free (`assign_intCast_inv`, `typedStore_int_noprov`
at `_d`'s integer type), so `memInv_store` and `Hidden.store_noprov` give the invariants;
`Ryo.Proofs.OpFacts.opSem_out` the escapes; `step_of_view` R's step; `FnRel.after` the relation. -/
theorem lift_intCast {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) (hbody : Γ.body = f.body)
    (hwf : IntsSized f.body)
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d : Local} {rv : Rvalue} {i : R.Insn}
    (hlow : LowerIntCast Γ (.assign ⟨d, []⟩ rv) [i])
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hlo : ∀ l ∈ rvalueLocals rv, live l = true)
    (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ rv)) o s = (.ok (), s')) :
    LiftOut Γ c ch ι live' f s s' s1 := by
  cases hlow with
  | @castMov _ _ _ _ _ _ _ _ sd sa _ ha htd hta hts hw hsd hsa hsize hoff hpriv hmi0 =>
    obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi0
    rw [hmode, hρ] at hv
    obtain ⟨sg, hty'⟩ := intTyOk_spec hty
    rw [hbody] at htd hta
    have hla := hlo _ (operand_local_mem ha)
    obtain ⟨pd, pa, td, _, _, _, hpd, hpa, htd', -, -, -, mem', hst, hs'⟩ :=
      assign_intCast_inv hs ha h
    have hra := hrel.opnd hpa hsa hla
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf _ _ _ htd
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_castMov (ch := ch) hs ha htd hta hts hw hsize.1
      hsize.2 hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hh hty' ho
      ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ h
    have e4 := Option.some.inj (htd'.symm.trans htd)
    subst e4
    obtain ⟨bs, hsto, hnp⟩ := typedStore_int_noprov hst
    have hsto' : s.mem.store pd bs .one = .ok s'.mem := by rw [hs']; exact hsto
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto' hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop),
      by subst hs'; rfl,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto' hnp) hesc hlive', hpb', hle⟩
  | @castExt _ _ _ _ _ _ _ _ sd sa _ ha htd hta hts hsd hsa hsize hoff hpriv hci =>
    obtain ⟨v, tx, ty, r, sx, sy, hv, hh, htx, hty, hsx, ho, hops, hctl⟩ := castInsnOk_spec hci
    rw [hmode, hρ] at hv
    rw [hbody] at htd hta
    have hla := hlo _ (operand_local_mem ha)
    obtain ⟨pd, pa, td, _, _, _, hpd, hpa, htd', -, -, -, mem', hst, hs'⟩ :=
      assign_intCast_inv hs ha h
    have hra := hrel.opnd hpa hsa hla
    have hpos : 0 < sd.size := by rw [hsize.1]; exact hwf _ _ _ htd
    obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ :=
      hrel.priv_dst hpd hsd hpos hpriv
    have hf1 := offOk_spec hoff.1
    have hf2 := offOk_spec hoff.2
    obtain ⟨st', hop, hmi, hrd, hoth⟩ := sim_castExt (ch := ch) hs ha htd hta hts hsize.1
      hsize.2 hpd hpa hrel.frame.mem hra ad xd hp hι hxd hl haddr hpaddr hsz hpv hh htx hty hsx
      ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ h
    have e4 := Option.some.inj (htd'.symm.trans htd)
    subst e4
    obtain ⟨bs, hsto, hnp⟩ := typedStore_int_noprov hst
    have hsto' : s.mem.store pd bs .one = .ok s'.mem := by rw [hs']; exact hsto
    have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
    obtain ⟨hpb', hle⟩ := memInv_store hpb hsto' hnp
    exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop),
      by subst hs'; rfl,
      hrel.after hpd hsd hmi hrd hoth (hrel.hidden.store_noprov hsto' hnp) hesc hlive', hpb', hle⟩

end Ryo.Proofs.Lower
