/-
Ryo.Proofs.Lower.IntBin — the pieces of the simulation of an integer binary operation between
locals (M5a): `_d = op(copy _a, copy _b)` lowered to one handler instruction `op.wN d, a, b`.

- L0 side: running such an assignment (`runOn`) loads both locals at their integer types,
  computes `evalIntBinOp`, and stores the result (`assign_binop_inv`); integer typed loads and
  stores are `decodeBits`/`encodeBits` (`typedLoad_int`, `typedStore_int`).
- Arithmetic: for the wrapping and bitwise operators (`binMethod`), R's `intBin` on the bit
  patterns gives the bit pattern of L0's result (`intBin_wrap`), and `evalIntBinOp` neither
  fails nor changes the state (`evalIntBinOp_wrap`).
- R side: the forward direction of `opSem_bin` (`Ryo.Proofs.Inline`): if the reads, decodes,
  method and write succeed, so does `opSem` (`opSem_bin_fwd`).
-/
import Ryo.Proofs.Lower.FrameRel
import Ryo.Proofs.Inline.OpSem

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem

/-- Running an L0 computation from state `s` with oracle `o`. -/
def runOn {α : Type} (x : SemM α) (o : Spec.Oracle) (s : Spec.State) : Except Outcome α × Spec.State :=
  ((x.run).run s).run o

/-- The R method of an L0 operator the lowering maps to a `bin`/`binop` handler without a check. -/
def binMethod : BinOp → Option String
  | .add => some "wrapping_add"
  | .sub => some "wrapping_sub"
  | .mul => some "wrapping_mul"
  | .bitAnd => some "&"
  | .bitOr => some "|"
  | .bitXor => some "^"
  | _ => none

/-- L0's result of a `binMethod` operator. -/
def wrapResult (op : BinOp) (t : IntType) (a b : Int) : Int :=
  match op with
  | .add => t.bringInBounds (a + b)
  | .sub => t.bringInBounds (a - b)
  | .mul => t.bringInBounds (a * b)
  | _ => t.ofBits (bitOp op (t.toBits a) (t.toBits b))

/-! ### L0 -/

theorem size?_int (t : IntType) (valid : ValidRange) :
    (Ty.int t valid).size? = some t.size := rfl

/-- Decoding at an integer type. -/
theorem decode_int_some {t : IntType} {valid : ValidRange} {bs : List AbstractByte} {w : Value}
    (hdec : (Ty.int t valid).decode bs = some w) :
    bs.length = t.size ∧ ∃ u, decodeBits bs = some u ∧ w = .int (t.ofBits u) := by
  simp only [Ty.decode] at hdec
  by_cases hlen : bs.length = t.size
  · cases hdb : decodeBits bs with
    | none => simp [hlen, hdb] at hdec
    | some u =>
      refine ⟨hlen, u, rfl, ?_⟩
      by_cases hv : valid.contains u = true
      · simp [hlen, hdb, hv] at hdec
        subst hdec; rfl
      · simp [hlen, hdb, hv] at hdec
  · simp [hlen] at hdec

theorem typedLoad_int {mem : Memory} {p : ThinPointer} {t : IntType} {valid : ValidRange}
    {al : Align} {v : Value} (h : typedLoad mem p (.int t valid) al = .ok v) :
    ∃ bs u, mem.load p t.size al = .ok bs ∧ decodeBits bs = some u ∧ bs.length = t.size ∧
      v = .int (t.ofBits u) := by
  have hs := size?_int t valid
  cases hl : mem.load p t.size al with
  | error e =>
    simp [typedLoad, hs, hl] at h
  | ok bs =>
    cases hdec : (Ty.int t valid).decode bs with
    | none =>
      first
        | (simp [typedLoad, hs, hl, hdec, throwUb, throwThe, MonadExceptOf.throw] at h; done)
        | (simp [typedLoad, hs, hl, hdec] at h; done)
        | (simp only [typedLoad, hs, hl, hdec] at h; cases h)
    | some w =>
      obtain ⟨hlen, u, hdb, hw⟩ := decode_int_some hdec
      cases hc : checkValue mem w (.int t valid) with
      | error e => simp [typedLoad, hs, hl, hdec, hc] at h; cases h
      | ok _ =>
        simp [typedLoad, hs, hl, hdec, hc] at h
        refine ⟨bs, u, rfl, hdb, hlen, ?_⟩
        cases h
        exact hw

theorem typedStore_int {mem mem' : Memory} {p : ThinPointer} {t : IntType} {valid : ValidRange}
    {al : Align} {i : Int} (h : typedStore mem p (.int i) (.int t valid) al = .ok mem') :
    mem.store p (encodeBits t.size (t.toBits i)) al = .ok mem' := by
  by_cases hr : t.canRepresent i = true
  · have he : (Ty.int t valid).encode (.int i) = some (encodeBits t.size (t.toBits i)) := by
      simp [Ty.encode, hr]
    simp only [typedStore, he] at h
    exact h
  · have he : (Ty.int t valid).encode (.int i) = none := by
      simp [Ty.encode, hr]
    first
      | (simp [typedStore, he, throwIllFormed, throwThe, MonadExceptOf.throw] at h; done)
      | (simp [typedStore, he] at h; done)
      | (simp only [typedStore, he] at h; cases h)

theorem modulus_eq_two_pow (t : IntType) : 2 ^ (8 * t.size) = t.modulus := by
  unfold IntType.modulus IntType.bits
  rw [Nat.mul_comm]

/-- `toBits x` is `n % modulus` when `x ≡ n`. -/
theorem toBits_of_emod_nat (t : IntType) {x : Int} {n : Nat}
    (h : x % (t.modulus : Int) = (n : Int) % (t.modulus : Int)) :
    t.toBits x = n % t.modulus := by
  unfold IntType.toBits
  rw [h, ← Int.natCast_emod]
  rfl

theorem natCast_sub_add_emod {a b M : Nat} (hb : b < M) :
    ((M - b + a : Nat) : Int) % (M : Int) = ((a : Int) - (b : Int)) % (M : Int) := by
  have h : ((M - b + a : Nat) : Int) = ((a : Int) - (b : Int)) + (M : Int) * 1 := by omega
  rw [h, Int.add_mul_emod_self_left]

/-- A `binMethod` operator on integers succeeds without changing the state. -/
theorem evalIntBinOp_wrap {op : BinOp} {m : String} (hm : binMethod op = some m) (t : IntType)
    (a b : Int) (dt : Spec.Ty) (o : Spec.Oracle) (s : Spec.State) :
    runOn (evalIntBinOp op t a b dt) o s = (.ok (.int (wrapResult op t a b)), s) := by
  cases op <;> simp [binMethod] at hm <;> rfl

/-- R's method on the bit patterns of two L0 integers gives the bit pattern of L0's result. -/
theorem intBin_wrap {op : BinOp} {m : String} (hm : binMethod op = some m) (t : IntType)
    (sg : Bool) (u w : Nat) :
    ∃ res, intBin m sg (BitVec.ofNat (8 * t.size) u) (BitVec.ofNat (8 * t.size) w) = .ok res ∧
      res.toNat = t.toBits (wrapResult op t (t.ofBits u) (t.ofBits w)) := by
  have hW := modulus_eq_two_pow t
  have hM := Ryo.Spec.Theorems.IntType.modulus_pos t
  cases op <;> simp [binMethod] at hm <;> subst hm <;> refine ⟨_, rfl, ?_⟩ <;>
    simp only [wrapResult, bitOp]
  · -- add
    rw [BitVec.toNat_add, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW,
      Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
        (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (t.ofBits u + t.ofBits w))]
    refine (toBits_of_emod_nat t ?_).symm
    rw [Int.add_emod (t.ofBits u) (t.ofBits w), Ryo.Spec.Theorems.IntType.ofBits_emod t u,
      Ryo.Spec.Theorems.IntType.ofBits_emod t w, Int.natCast_add, Int.natCast_emod u,
      Int.natCast_emod w]
  · -- sub
    rw [BitVec.toNat_sub, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW,
      Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
        (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (t.ofBits u - t.ofBits w))]
    refine (toBits_of_emod_nat t ?_).symm
    rw [natCast_sub_add_emod (Nat.mod_lt w hM), Int.sub_emod (t.ofBits u) (t.ofBits w),
      Ryo.Spec.Theorems.IntType.ofBits_emod t u, Ryo.Spec.Theorems.IntType.ofBits_emod t w,
      Int.natCast_emod u, Int.natCast_emod w]
  · -- mul
    rw [BitVec.toNat_mul, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW,
      Ryo.Spec.Theorems.IntType.toBits_eq_of_emod t
        (Ryo.Spec.Theorems.IntType.bringInBounds_emod t (t.ofBits u * t.ofBits w))]
    refine (toBits_of_emod_nat t ?_).symm
    rw [Int.mul_emod (t.ofBits u) (t.ofBits w), Ryo.Spec.Theorems.IntType.ofBits_emod t u,
      Ryo.Spec.Theorems.IntType.ofBits_emod t w, Int.natCast_mul, Int.natCast_emod u,
      Int.natCast_emod w]
  all_goals
    first
      | have hl := (BitVec.ofNat (8 * t.size) u &&& BitVec.ofNat (8 * t.size) w).isLt
        rw [BitVec.toNat_and, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW] at hl ⊢
        rw [Ryo.Spec.Theorems.IntType.toBits_ofBits, Ryo.Spec.Theorems.IntType.toBits_ofBits,
          Ryo.Spec.Theorems.IntType.toBits_ofBits]
        exact (Nat.mod_eq_of_lt hl).symm
      | have hl := (BitVec.ofNat (8 * t.size) u ||| BitVec.ofNat (8 * t.size) w).isLt
        rw [BitVec.toNat_or, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW] at hl ⊢
        rw [Ryo.Spec.Theorems.IntType.toBits_ofBits, Ryo.Spec.Theorems.IntType.toBits_ofBits,
          Ryo.Spec.Theorems.IntType.toBits_ofBits]
        exact (Nat.mod_eq_of_lt hl).symm
      | have hl := (BitVec.ofNat (8 * t.size) u ^^^ BitVec.ofNat (8 * t.size) w).isLt
        rw [BitVec.toNat_xor, BitVec.toNat_ofNat, BitVec.toNat_ofNat, hW] at hl ⊢
        rw [Ryo.Spec.Theorems.IntType.toBits_ofBits, Ryo.Spec.Theorems.IntType.toBits_ofBits,
          Ryo.Spec.Theorems.IntType.toBits_ofBits]
        exact (Nat.mod_eq_of_lt hl).symm

theorem prod_ok_inj {α : Type} {a b : α} {s s' : Spec.State}
    (h : ((Except.ok a, s) : Except Outcome α × Spec.State) = (.ok b, s')) : a = b ∧ s = s' := by
  cases h; exact ⟨rfl, rfl⟩

theorem prod_err_ok {α : Type} {e : Outcome} {b : α} {s s' : Spec.State}
    (h : ((Except.error e, s) : Except Outcome α × Spec.State) = (.ok b, s')) : False := by
  cases h

theorem runOn_pure {α : Type} (a : α) (o : Spec.Oracle) (s : Spec.State) :
    runOn (pure a : SemM α) o s = (.ok a, s) := rfl

theorem runOn_get (o : Spec.Oracle) (s : Spec.State) :
    runOn (get : SemM Spec.State) o s = (.ok s, s) := rfl

theorem runOn_bind {α β : Type} (x : SemM α) (f : α → SemM β) (o : Spec.Oracle)
    (s : Spec.State) :
    runOn (x >>= f) o s =
      (match runOn x o s with
       | (.ok a, s1) => runOn (f a) o s1
       | (.error e, s1) => (.error e, s1)) := by
  unfold runOn
  rw [ExceptT.run_bind, StateT.run_bind, ReaderT.run_bind]
  generalize ((x.run).run s).run o = r
  rcases r with ⟨_ | _, _⟩ <;> rfl

theorem runOn_bind_ok {α β : Type} {x : SemM α} {f : α → SemM β} {o : Spec.Oracle}
    {s s' : Spec.State} {b : β} (h : runOn (x >>= f) o s = (.ok b, s')) :
    ∃ a s1, runOn x o s = (.ok a, s1) ∧ runOn (f a) o s1 = (.ok b, s') := by
  rw [runOn_bind] at h
  rcases hx : runOn x o s with ⟨_ | a, s1⟩
  · rw [hx] at h; exact (prod_err_ok h).elim
  · rw [hx] at h; exact ⟨a, s1, rfl, h⟩

theorem runOn_liftE_ok {α : Type} {e : Except Outcome α} {a : α} {o : Spec.Oracle}
    {s s' : Spec.State} (h : runOn (SemM.liftE e) o s = (.ok a, s')) : e = .ok a ∧ s' = s := by
  cases e with
  | error x =>
    have h' : ((Except.error x, s) : Except Outcome α × Spec.State) = (.ok a, s') := h
    exact (prod_err_ok h').elim
  | ok y =>
    have h' : ((Except.ok y, s) : Except Outcome α × Spec.State) = (.ok a, s') := h
    obtain ⟨h1, h2⟩ := prod_ok_inj h'
    exact ⟨by rw [h1], h2.symm⟩

theorem runOn_curFrame {o : Spec.Oracle} {s : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) :
    runOn SemM.curFrame o s = (.ok f, s) := by
  have e : runOn SemM.curFrame o s = runOn (match s.stack with
      | g :: _ => pure g
      | [] => throwIllFormed "no active frame" : SemM Spec.Frame) o s := rfl
  rw [e, hs]; rfl

theorem runOn_localTy_ok {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame} {l : Local}
    {t : Spec.Ty} (h : runOn (SemM.localTy f l) o s = (.ok t, s')) :
    f.body.locals[l]? = some t ∧ s' = s := by
  unfold SemM.localTy at h
  rcases hty : f.body.locals[l]? with _ | t'
  · try rw [hty] at h
    exact (prod_err_ok h).elim
  · try rw [hty] at h
    obtain ⟨h1, h2⟩ := prod_ok_inj h
    exact ⟨by first | rw [h1] | (rw [hty, h1]), h2.symm⟩

theorem runOn_localPlace_ok {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local} {r : Place × Spec.Ty}
    (h : runOn (localPlace l) o s = (.ok r, s1)) :
    ∃ p ty, f.locals[l]? = some (some p) ∧ f.body.locals[l]? = some ty ∧
      r = (⟨p.widen, true⟩, ty) ∧ s1 = s := by
  have e : localPlace l = (SemM.curFrame >>= fun g => SemM.localTy g l >>= fun ty =>
      match g.locals[l]? with
      | some (some p) => pure (⟨p.widen, true⟩, ty)
      | _ => throwUb s!"access to a dead local _{l}") := rfl
  rw [e] at h
  obtain ⟨g, s2, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_curFrame hs] at h1
  obtain ⟨hfg, hss⟩ := prod_ok_inj h1
  rw [← hfg, ← hss] at h2
  obtain ⟨ty, s3, h3, h4⟩ := runOn_bind_ok h2
  obtain ⟨hty, hs3⟩ := runOn_localTy_ok h3
  rw [hs3] at h4
  rcases hloc : f.locals[l]? with _ | (_ | p)
  · try rw [hloc] at h4
    exact (prod_err_ok h4).elim
  · try rw [hloc] at h4
    exact (prod_err_ok h4).elim
  · try rw [hloc] at h4
    obtain ⟨hr, hs1⟩ := prod_ok_inj h4
    exact ⟨p, ty, by first | rfl | exact hloc, hty, hr.symm, hs1.symm⟩

theorem runOn_evalPlace_nil (l : Local) (o : Spec.Oracle) (s : Spec.State) :
    runOn (evalPlace ⟨l, []⟩) o s = runOn (localPlace l) o s := by
  have e : evalPlace ⟨l, []⟩ = (localPlace l >>= fun init => pure init) := rfl
  rw [e, runOn_bind]
  generalize runOn (localPlace l) o s = r
  rcases r with ⟨_ | _, _⟩ <;> rfl

theorem runOn_placeLoad_ok {o : Spec.Oracle} {s s1 : Spec.State} {pl : Place} {ty : Spec.Ty}
    {v : Value} (h : runOn (placeLoad pl ty) o s = (.ok v, s1)) :
    typedLoad s.mem pl.ptr.thin ty .one = .ok v ∧ s1 = s := by
  obtain ⟨ptr, al⟩ := pl
  cases al
  · have e : runOn (placeLoad ⟨ptr, false⟩ ty) o s =
        (.error (.ub "loading from a place based on a misaligned pointer"), s) := rfl
    rw [e] at h
    exact (prod_err_ok h).elim
  · have e : runOn (placeLoad ⟨ptr, true⟩ ty) o s =
        runOn (SemM.liftE (typedLoad s.mem ptr.thin ty .one)) o s := rfl
    rw [e] at h
    exact runOn_liftE_ok h

theorem runOn_placeStore_ok {o : Spec.Oracle} {s s' : Spec.State} {pl : Place} {ty : Spec.Ty}
    {v : Value} (h : runOn (placeStore pl v ty) o s = (.ok (), s')) :
    ∃ mem', typedStore s.mem pl.ptr.thin v ty .one = .ok mem' ∧ s' = { s with mem := mem' } := by
  obtain ⟨ptr, al⟩ := pl
  cases al
  · have e : runOn (placeStore ⟨ptr, false⟩ v ty) o s =
        (.error (.ub "storing to a place based on a misaligned pointer"), s) := rfl
    rw [e] at h
    exact (prod_err_ok h).elim
  · have e : runOn (placeStore ⟨ptr, true⟩ v ty) o s =
        runOn (SemM.liftE (typedStore s.mem ptr.thin v ty .one) >>= fun m => SemM.setMem m) o s :=
      rfl
    rw [e] at h
    obtain ⟨m', s2, h1, h2⟩ := runOn_bind_ok h
    obtain ⟨hm, hs2⟩ := runOn_liftE_ok h1
    have h2' : ((Except.ok (), { s2 with mem := m' }) : Except Outcome Unit × Spec.State) =
        (.ok (), s') := h2
    obtain ⟨-, hs'⟩ := prod_ok_inj h2'
    exact ⟨m', hm, by rw [← hs', hs2]⟩

theorem runOn_evalOperand_copy {o : Spec.Oracle} {s s1 : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {l : Local} {r : Value × Spec.Ty}
    (h : runOn (evalOperand (.copy ⟨l, []⟩)) o s = (.ok r, s1)) :
    ∃ p ty v, f.locals[l]? = some (some p) ∧ f.body.locals[l]? = some ty ∧
      typedLoad s.mem p ty .one = .ok v ∧ r = (v, ty) ∧ s1 = s := by
  have e : evalOperand (.copy ⟨l, []⟩) = (evalPlace ⟨l, []⟩ >>= fun x => match x with
      | (pl, ty) => placeLoad pl ty >>= fun v => pure (v, ty)) := rfl
  rw [e] at h
  obtain ⟨x, s2, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨p, ty, hloc, hty, hx, hs2⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (placeLoad ⟨p.widen, true⟩ ty >>= fun v => pure (v, ty)) o s2 =
      (.ok r, s1) := h2
  rw [hs2] at h2'
  obtain ⟨v, s3, h3, h4⟩ := runOn_bind_ok h2'
  obtain ⟨hv, hs3⟩ := runOn_placeLoad_ok h3
  obtain ⟨hr, hs1⟩ := prod_ok_inj h4
  exact ⟨p, ty, v, hloc, hty, hv, hr.symm, hs1.symm.trans hs3⟩

/-- An assignment of an operator on two copied locals (no projections), run to success: the
frame's three locals are live, both operands load at integer types, and the store writes the
result of `evalBinOp`. -/
theorem assign_binop_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a b : Local} {op : BinOp}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))))
      o s = (.ok (), s')) :
    ∃ pd pa pb td ta tb va vb v,
      f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
      f.locals[b]? = some (some pb) ∧
      f.body.locals[d]? = some td ∧ f.body.locals[a]? = some ta ∧ f.body.locals[b]? = some tb ∧
      typedLoad s.mem pa ta .one = .ok va ∧ typedLoad s.mem pb tb .one = .ok vb ∧
      ∃ s1, runOn (evalBinOp op (va, ta) (vb, tb) td) o s = (.ok v, s1) ∧
      ∃ mem', typedStore s1.mem pd v td .one = .ok mem' ∧ s' = { s1 with mem := mem' } := by
  have e : evalStatement (.assign ⟨d, []⟩ (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩))) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty) => evalRvalue (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩)) ty >>= fun v =>
            placeStore pl v ty) := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩)) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.binaryOp op (.copy ⟨a, []⟩) (.copy ⟨b, []⟩)) td =
      (evalOperand (.copy ⟨a, []⟩) >>= fun l => evalOperand (.copy ⟨b, []⟩) >>= fun r =>
        evalBinOp op l r td) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨la, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨pa, ta, va, hla, hta, hva, hla', hs3⟩ := runOn_evalOperand_copy hs h5
  subst hla'
  rw [hs3] at h6
  obtain ⟨lb, s4, h7, h8⟩ := runOn_bind_ok h6
  obtain ⟨pb, tb, vb, hlb, htb, hvb, hlb', hs4⟩ := runOn_evalOperand_copy hs h7
  subst hlb'
  rw [hs4] at h8
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pd, pa, pb, td, ta, tb, va, vb, v, hld, hla, hlb, htd, hta, htb, hva, hvb, s2, h8,
    mem', hst, hs'⟩

/-! ### R -/

/-- A slot operand in the `i32` range fits `.slot`. -/
theorem slot_fits {o : Int} (h1 : -2 ^ 31 ≤ o) (h2 : o < 2 ^ 31) :
    Val.fits .slot (.slot o) = true := by
  simp only [Val.fits, Bool.and_eq_true, decide_eq_true_eq]
  exact ⟨h1, h2⟩

/-- The footprint of a `bin`/`binop` handler at `n` bytes. -/
def binFp (n : Nat) : Footprint :=
  { reads := [Ryo.Proofs.Inline.rdA "a" n, Ryo.Proofs.Inline.rdA "b" n],
    writes := [Ryo.Proofs.Inline.rdA "d" n] }

/-- The forward direction of `Inline.opSem_bin`. -/
theorem opSem_bin_fwd {op : Full.Opcode} {kd : Handlers.HandlerKind} {r : Option String}
    {ty m : String} {n : Nat} {sg : Bool} {d a b : Int} {st st' : OpSem.State} {ch : OpSem.Choice}
    (hkd : kd = .bin ∨ kd = .binop) (hh : op.handler? = some ⟨kd, [ty, m], r⟩)
    (hty : OpSem.Ty.parse ty = some (.int n sg))
    (ho : op.info.operands = [⟨"d", .slot⟩, ⟨"a", .slot⟩, ⟨"b", .slot⟩])
    (hfits : -2 ^ 31 ≤ d ∧ d < 2 ^ 31 ∧ -2 ^ 31 ≤ a ∧ a < 2 ^ 31 ∧ -2 ^ 31 ≤ b ∧ b < 2 ^ 31)
    {ba bb : List AbstractByte} {va vb : Nat} {res : BitVec (8 * n)}
    (hra : st.readFrame a n = .ok ba) (hrb : st.readFrame b n = .ok bb)
    (hva : asNat ba = .ok va) (hvb : asNat bb = .ok vb)
    (hres : intBin m sg (BitVec.ofNat (8 * n) va) (BitVec.ofNat (8 * n) vb) = .ok res)
    (hw : st.writeFrame d (intBytes n res.toNat) = .ok st') :
    opSem op [.slot d, .slot a, .slot b] st ch = .ok (.next, st') := by
  obtain ⟨hd1, hd2, ha1, ha2, hb1, hb2⟩ := hfits
  have hfd := slot_fits hd1 hd2
  have hfa := slot_fits ha1 ha2
  have hfb := slot_fits hb1 hb2
  have hfp : footprint op = some (binFp n) := by
    rw [Ryo.Proofs.Inline.footprint_eq hh]
    rcases hkd with rfl | rfl
    · exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.1
    · exact (Ryo.Proofs.Inline.fp_w (Ryo.Proofs.Inline.tySize_of_parse hty)).2.2.2.1
  have hprep : prepare op [.slot d, .slot a, .slot b] =
      .ok (⟨kd, [ty, m], r⟩, (binFp n),
        opndVal op.info [.slot d, .slot a, .slot b]) := by
    unfold prepare
    simp only [hh, hfp]
    rw [if_neg (by simp [ho]), if_neg (by simp [ho, hfd, hfa, hfb])]
    rfl
  have hva' : opndVal op.info [.slot d, .slot a, .slot b] "a" = some (.slot a) := by
    simp [opndVal, ho]
  have hvb' : opndVal op.info [.slot d, .slot a, .slot b] "b" = some (.slot b) := by
    simp [opndVal, ho]
  have hvd' : opndVal op.info [.slot d, .slot a, .slot b] "d" = some (.slot d) := by
    simp [opndVal, ho]
  have hrd : readAll (binFp n) (opndVal op.info [.slot d, .slot a, .slot b]) st =
      .ok [("a", ba), ("b", bb)] := by
    simp only [readAll, binFp, List.mapM_cons, List.mapM_nil]
    simp [Access.range, Ryo.Proofs.Inline.rdA, hva', hvb', Val.slotOff, Extent.eval, hra, hrb,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hk : kindSem kd [ty, m] (mkEnv [("a", ba), ("b", bb)]
      (opndVal op.info [.slot d, .slot a, .slot b]) st ch) =
      .ok { ctl := .next, mem := st.mem, writes := [("d", intBytes n res.toNat)] } := by
    rcases hkd with rfl | rfl <;>
      simp [kindSem, Ryo.Proofs.Inline.intTy_of_parse hty, mkEnv, Env.bv, Env.int, out, hva, hvb,
        hres, bind, Except.bind, pure, Except.pure]
  have hlen : (intBytes n res.toNat).length = n := Ryo.Spec.Theorems.encodeBits_length _ _
  have hc : commit (binFp n) (opndVal op.info [.slot d, .slot a, .slot b]) st
      [("d", intBytes n res.toNat)] = .ok st' := by
    simp only [commit, binFp, List.foldlM_cons, List.foldlM_nil]
    simp [commitOne, Ryo.Proofs.Inline.rdA, Access.range, hvd', Val.slotOff, Extent.eval, hlen, hw,
      bind, Except.bind, pure, Except.pure, Option.bind]
  have hst : ({ st with mem := st.mem } : OpSem.State) = st := rfl
  simp only [opSem, hprep, hrd, hk, bind, Except.bind, pure, Except.pure]
  first
    | rw [hc]
    | rw [hst, hc]
    | erw [hc]

end Ryo.Proofs.Lower
