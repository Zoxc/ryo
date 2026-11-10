/-
Ryo.Proofs.Lower.SimCopy — the lift of `LowerCopy` (`Check/Lower/Copy.lean`, M5b): whole-local
copies at any type, transmutes and thin pointer casts, each lowered to one `mov` of `n` bytes
into a private destination.

All three rules have the same L0 effect up to the bytes stored (`MovMem`): L0 loads `n` bytes
`bs0` from `_a` and stores into `_d` bytes `bsd` less defined than them (`bytesLeDefined bsd
bs0`), while R's `mov` copies the bytes it read. Since R's read refines `bs0` (`readLocal_inj`),
it refines `bsd` too (`BytesInj.of_le`), which is what `writeLocal_priv` needs; and `bsd`
carries only provenance `bs0` carries (`le_prov`), so `Hidden` and `ProvBounded` survive the
store as for `copyPtr`. `lift_movMem` is that common part; the rules differ in how `MovMem`
follows from L0's run:
- `copyAny`: one re-encoding (`Ryo.Spec.Theorems.encode_decode_le`, needing `ty.wf`).
- `bitCast`: L0's `transmute` re-encodes at the source type and decodes at the target, and the
  store encodes at the target again: two re-encodings, each less defined.
- `ptrCast`: the cast keeps the decoded thin pointer, whose encoding at `_d`'s type is
  `encodePtr` of it, the source's re-encoding (`ptr_reenc_le`, as in `reenc_ptr`).

Hypotheses beyond `lift_copyPtr`'s: none.
-/
import Ryo.Proofs.Lower.FnSim
import Ryo.Check.Lower.Copy
import Ryo.Spec.Theorems.Monotone

namespace Ryo.Proofs.Lower

open Ryo.Spec Ryo.Spec.Sem Ryo.Vm Ryo.Vm.OpSem Ryo.Check.Lower
open Ryo.Spec.Theorems (ptrBytes ptrProvOf)

/-! ### The byte order against the memory relation -/

/-- A byte less defined than one that refines `b1` refines `b1`. -/
theorem ByteInj.of_le' {ι : Inj} {b' b0 b1 : AbstractByte} (hle : b'.leDefined b0 = true)
    (h : ByteInj ι b0 b1) : ByteInj ι b' b1 := by
  cases b' with
  | uninit => exact True.intro
  | init x fx =>
    cases b0 with
    | uninit => cases fx <;> simp [AbstractByte.leDefined] at hle
    | init y fy =>
      cases b1 with
      | uninit => cases fy <;> exact (h : False).elim
      | init z g =>
        cases fx with
        | none =>
          show x = z
          cases fy with
          | none =>
            have hxy : x = y := by simpa [AbstractByte.leDefined] using hle
            exact hxy.trans (h : y = z)
          | some q =>
            have hxy : x = y := by simpa [AbstractByte.leDefined] using hle
            simp only [ByteInj] at h
            exact hxy.trans h.1
        | some p =>
          cases fy with
          | none => simp [AbstractByte.leDefined] at hle
          | some q =>
            have h' : (x == y && p == q) = true := hle
            simp only [Bool.and_eq_true, beq_iff_eq] at h'
            obtain ⟨rfl, rfl⟩ := h'
            exact h

/-- `AbstractByte.leDefined` is transitive. -/
theorem byteLe_trans {a b c : AbstractByte} (h1 : a.leDefined b = true)
    (h2 : b.leDefined c = true) : a.leDefined c = true := by
  cases a with
  | uninit => rfl
  | init x fx =>
    cases b with
    | uninit => cases fx <;> simp [AbstractByte.leDefined] at h1
    | init y fy =>
      cases c with
      | uninit => cases fy <;> simp [AbstractByte.leDefined] at h2
      | init z fz =>
        cases fx <;> cases fy <;> cases fz <;> simp_all [AbstractByte.leDefined]

/-- `bytesLeDefined` is transitive. -/
theorem bytesLe_trans {a b c : List AbstractByte} (h1 : bytesLeDefined a b = true)
    (h2 : bytesLeDefined b c = true) : bytesLeDefined a c = true := by
  obtain ⟨l1, p1⟩ := (Ryo.Spec.Theorems.bytesLeDefined_iff a b).mp h1
  obtain ⟨l2, p2⟩ := (Ryo.Spec.Theorems.bytesLeDefined_iff b c).mp h2
  exact (Ryo.Spec.Theorems.bytesLeDefined_iff a c).mpr ⟨l1.trans l2, fun i h1' h2' =>
    byteLe_trans (p1 i h1' (by omega)) (p2 i (by omega) h2')⟩

/-- A less defined byte's fragment is the more defined byte's. -/
theorem provFrag_le {x y : AbstractByte} {f : ProvenanceFrag} (h : x.leDefined y = true)
    (hx : x.provFrag = some f) : y.provFrag = some f := by
  cases x <;> cases y <;> simp_all [AbstractByte.leDefined, AbstractByte.provFrag] <;>
    (rename_i f1 _ f2; cases f1 <;> cases f2 <;> simp_all)

/-- Bytes less defined than bytes that refine `bs1` refine `bs1`.

Proof: `Ryo.Spec.Theorems.bytesLeDefined_iff` (same length, pointwise `leDefined`),
`BytesInj.length`, then `BytesInj.of_getElem` with `BytesInj.getElem'`; per byte, case on the
two bytes as in `ByteInj.of_leDefined`: `uninit` refines anything; `init x none ≤ init y _`
means `x = y`, and `ByteInj ι (init y _) b1` gives `b1`'s data `y`; `init x (some p) ≤ init y
(some q)` means `x = y ∧ p = q`, so the byte is the same. -/
theorem BytesInj.of_le {ι : Inj} {bs' bs0 bs1 : List AbstractByte}
    (hle : bytesLeDefined bs' bs0 = true) (h : BytesInj ι bs0 bs1) : BytesInj ι bs' bs1 := by
  obtain ⟨hl, hp⟩ := (Ryo.Spec.Theorems.bytesLeDefined_iff bs' bs0).mp hle
  have hl1 := BytesInj.length h
  exact BytesInj_of_getElem (hl.trans hl1) fun k h0 h1 =>
    ByteInj.of_le' (hp k h0 (by omega)) (h.getElem' k (by omega) h1)

/-- Bytes less defined than `bs0` carry only provenance `bs0` carries (at the same index).

Proof: `bytesLeDefined_iff`; a byte `b = bs'[j]` with `b.provFrag = some fr` is `init x (some
fr)`, and `leDefined` with `bs0[j]` forces `bs0[j] = init x (some fr)` (`AbstractByte.leDefined`
is `false` against `uninit` or a provenance-free byte); take `j`, `fr0 = fr`. Membership to
index by `List.mem_iff_getElem`. -/
theorem le_prov {bs' bs0 : List AbstractByte} (hle : bytesLeDefined bs' bs0 = true) :
    ∀ b ∈ bs', ∀ fr, b.provFrag = some fr →
      ∃ j, ∃ hj : j < bs0.length, ∃ fr0, bs0[j].provFrag = some fr0 ∧ fr0.prov = fr.prov := by
  obtain ⟨hl, hp⟩ := (Ryo.Spec.Theorems.bytesLeDefined_iff bs' bs0).mp hle
  intro b hb fr hfr
  obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hb
  exact ⟨j, by omega, fr, provFrag_le (hp j hj (by omega)) hfr, rfl⟩

/-! ### L0's side -/

/-- A load's bytes have the loaded length. -/
theorem movLoad_length {m : Memory} {p : ThinPointer} {n : Nat} {al : Align}
    {bs : List AbstractByte} (h : m.load p n al = .ok bs) : bs.length = n := by
  by_cases hn : n = 0
  · subst hn
    rw [load_zero_inv h]
    try rfl
  · obtain ⟨id, hid, -, -, h1, h2, rfl⟩ := load_eq_ok_pos hn h
    simp only [Array.length_toList, Array.size_extract]
    omega

theorem tySize_of {t : Spec.Ty} {n : Nat} (h : t.size? = some n) : t.size = n := by
  show t.size?.getD 0 = n
  rw [h]
  try rfl

theorem runOn_pure_inv {α : Type} {a b : α} {o : Spec.Oracle} {s s' : Spec.State}
    (h : runOn (pure a : SemM α) o s = (.ok b, s')) : b = a ∧ s' = s := by
  rw [runOn_pure] at h
  obtain ⟨h1, h2⟩ := prod_ok_inj h
  exact ⟨h1.symm, h2.symm⟩

theorem runOn_illFormed_inv {α : Type} {msg : String} {b : α} {o : Spec.Oracle}
    {s s' : Spec.State} (h : runOn (throwIllFormed msg : SemM α) o s = (.ok b, s')) : False := by
  rw [runOn_throwIllFormed] at h
  exact prod_err_ok h

/-- An assignment of a cast to a local (no projections), run to success: the local is live,
the operand evaluates, the cast succeeds, and the store writes its value. -/
theorem assign_cast_inv {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d : Local} {k : CastKind}
    {op : Operand} {ty : Spec.Ty}
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k op ty))) o s = (.ok (), s')) :
    ∃ pd td r s1 w s2, f.locals[d]? = some (some pd) ∧ f.body.locals[d]? = some td ∧
      runOn (evalOperand op) o s = (.ok r, s1) ∧ runOn (evalCast k r ty) o s1 = (.ok w, s2) ∧
      ∃ mem', typedStore s2.mem pd w td .one = .ok mem' ∧ s' = { s2 with mem := mem' } := by
  have e : evalStatement (.assign ⟨d, []⟩ (.cast k op ty)) =
      (evalPlace ⟨d, []⟩ >>= fun x => match x with
        | (pl, ty') => evalRvalue (.cast k op ty) ty' >>= fun v => placeStore pl v ty') := by
    first | rfl | (unfold evalStatement; rfl) | simp only [evalStatement]
  rw [e] at h
  obtain ⟨x, s1, h1, h2⟩ := runOn_bind_ok h
  rw [runOn_evalPlace_nil] at h1
  obtain ⟨pd, td, hld, htd, hx, hs1⟩ := runOn_localPlace_ok hs h1
  subst hx
  have h2' : runOn (evalRvalue (.cast k op ty) td >>= fun v =>
      placeStore ⟨pd.widen, true⟩ v td) o s1 = (.ok (), s') := h2
  rw [hs1] at h2'
  obtain ⟨v, s2, h3, h4⟩ := runOn_bind_ok h2'
  have e2 : evalRvalue (.cast k op ty) td = (evalOperand op >>= fun r => evalCast k r ty) := by
    first | rfl | (unfold evalRvalue; rfl) | simp only [evalRvalue]
  rw [e2] at h3
  obtain ⟨r, s3, h5, h6⟩ := runOn_bind_ok h3
  obtain ⟨mem', hst, hs'⟩ := runOn_placeStore_ok h4
  exact ⟨pd, td, r, s3, v, s2, hld, htd, h5, h6, mem', hst, hs'⟩

/-- A successful `transmute`: the source encoding decodes at the target type. -/
theorem transmute_bytes {mem : Memory} {v w : Value} {t1 t2 : Spec.Ty}
    (h : transmute mem v t1 t2 = .ok w) :
    ∃ bs, t1.encode v = some bs ∧ t2.decode bs = some w := by
  cases hs1 : t1.size? with
  | none =>
    exfalso
    first
      | (simp [transmute, hs1, throwIllFormed, throwThe, MonadExceptOf.throw] at h; done)
      | (simp [transmute, hs1] at h; done)
      | (simp only [transmute, hs1] at h; cases h)
  | some n1 =>
    cases hs2 : t2.size? with
    | none =>
      exfalso
      first
        | (simp [transmute, hs1, hs2, throwIllFormed, throwThe, MonadExceptOf.throw] at h; done)
        | (simp [transmute, hs1, hs2] at h; done)
        | (simp only [transmute, hs1, hs2] at h; cases h)
    | some n2 =>
      by_cases hn : n1 = n2
      · subst hn
        cases he : t1.encode v with
        | none =>
          exfalso
          first
            | (simp [transmute, hs1, hs2, he, throwIllFormed, throwThe, MonadExceptOf.throw,
                bind, Except.bind, pure, Except.pure] at h; done)
            | (simp [transmute, hs1, hs2, he] at h; done)
        | some bs =>
          cases hd : t2.decode bs with
          | none =>
            exfalso
            first
              | (simp [transmute, hs1, hs2, he, hd, throwUb, throwThe, MonadExceptOf.throw,
                  bind, Except.bind, pure, Except.pure] at h; done)
              | (simp [transmute, hs1, hs2, he, hd] at h; done)
          | some w' =>
            refine ⟨bs, rfl, ?_⟩
            cases hc : checkValue mem w' t2 with
            | error e =>
              exfalso
              first
                | (simp [transmute, hs1, hs2, he, hd, hc, bind, Except.bind, pure,
                    Except.pure] at h; done)
                | (simp [transmute, hs1, hs2, he, hd, hc] at h; done)
            | ok u =>
              have hw : w' = w := by
                first
                  | (simp [transmute, hs1, hs2, he, hd, hc, bind, Except.bind, pure,
                      Except.pure] at h; exact h)
                  | (simp [transmute, hs1, hs2, he, hd, hc] at h; exact h)
              rw [hd, hw]
      · exfalso
        first
          | (simp [transmute, hs1, hs2, hn, throwUb, throwThe, MonadExceptOf.throw, bind,
              Except.bind, pure, Except.pure] at h; done)
          | (simp [transmute, hs1, hs2, hn] at h; done)

/-- The pointer casts `ptrToPtr`/`fnPtrToPtr` of a thin pointer, run to success, return it. -/
theorem evalCast_ptrToPtr_ok {k : CastKind} (hk : k = .ptrToPtr ∨ k = .fnPtrToPtr)
    {tp : ThinPointer} {src ty : Spec.Ty} {o : Spec.Oracle} {s s2 : Spec.State} {w : Value}
    (h : runOn (evalCast k (Value.ptr ⟨tp, none⟩, src) ty) o s = (.ok w, s2)) :
    w = .ptr ⟨tp, none⟩ ∧ s2 = s := by
  cases ty
  case ptr pt vr =>
    have e : evalCast k (Value.ptr ⟨tp, none⟩, src) (.ptr pt vr) =
        (if pt.isWide = true then (pure (Value.ptr ⟨tp, none⟩) : SemM Value)
          else pure (Value.ptr ⟨tp, none⟩)) := by
      rcases hk with rfl | rfl <;> first | rfl | simp [evalCast, ThinPointer.widen]
    rw [e, ite_self] at h
    exact runOn_pure_inv h
  all_goals
    (exfalso
     rcases hk with rfl | rfl <;>
       exact runOn_illFormed_inv (msg := "PtrToPtr: bad operands") h)

/-- A thin-pointer-keeping cast of a thin pointer, run to success, returns it. -/
theorem evalCast_thin_ok {k : CastKind} (hk : ptrCastKind k = true) {tp : ThinPointer}
    {src ty : Spec.Ty} {o : Spec.Oracle} {s s2 : Spec.State} {w : Value}
    (h : runOn (evalCast k (Value.ptr ⟨tp, none⟩, src) ty) o s = (.ok w, s2)) :
    w = .ptr ⟨tp, none⟩ ∧ s2 = s := by
  cases k <;> try (rename_i c; cases c)
  all_goals first
    | (cases hk; done)
    | (exfalso; simp [ptrCastKind] at hk; done)
    | exact runOn_pure_inv (a := Value.ptr ⟨tp, none⟩) h
    | exact evalCast_ptrToPtr_ok (.inl rfl) h
    | exact evalCast_ptrToPtr_ok (.inr rfl) h

/-- A thin pointer's encoding is less defined than the bytes it was decoded from. -/
theorem ptr_reenc_le {bs0 : List AbstractByte} {tp : ThinPointer} (hlen : bs0.length = 8)
    (hdp : decodePtr bs0 = some tp) : bytesLeDefined (encodePtr tp) bs0 = true := by
  rw [Ryo.Spec.Theorems.decodePtr_eq] at hdp
  cases hdb : decodeBits bs0 with
  | none => simp [hdb] at hdp
  | some a =>
    simp [hdb] at hdp
    subst hdp
    obtain ⟨ds, hds, hda⟩ := (Ryo.Spec.Theorems.decodeBits_iff bs0 a).mp hdb
    obtain ⟨hlds, hget⟩ := (Ryo.Spec.Theorems.mapM_data_iff bs0 ds).mp hds
    have h8 : ds.length = 8 := by omega
    have henc : encodePtr ⟨a, ptrProvOf bs0⟩ = ptrBytes ds (ptrProvOf bs0) := by
      rw [Ryo.Spec.Theorems.encodePtr_eq]
      show ptrBytes (leEncode 8 a) _ = _
      rw [← hda, ← h8, Ryo.Spec.Theorems.leEncode_leDecode]
    rw [henc]
    refine (Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mpr
      ⟨by rw [Ryo.Spec.Theorems.length_ptrBytes]; omega, fun k h0 h1 => ?_⟩
    rw [Ryo.Spec.Theorems.getElem_ptrBytes]
    have hdk := hget k h1 (by omega)
    obtain ⟨f, hf⟩ : ∃ f, bs0[k] = .init (ds[k]'(by omega)) f := by
      have key : ∀ (b : AbstractByte) (y : UInt8), b.data = some y → ∃ f, b = .init y f := by
        intro b y hby
        cases b with
        | uninit => simp [AbstractByte.data] at hby
        | init x f =>
          simp only [AbstractByte.data, Option.some.injEq] at hby
          exact ⟨f, by rw [hby]⟩
      exact key _ _ hdk
    rw [hf]
    rcases Option.eq_none_or_eq_some (ptrProvOf bs0) with hpo | ⟨q, hpo⟩
    · simp only [hpo, Option.map_none]
      cases f <;> simp [AbstractByte.leDefined]
    · simp only [hpo, Option.map_some]
      have hq := ((Ryo.Spec.Theorems.ptrProvOf_iff bs0 q).mp hpo).2 k h1
      rw [hf] at hq
      simp only [AbstractByte.provFrag] at hq
      subst hq
      exact AbstractByte.leDefined_refl _

/-- L0's effect of a statement lowered to a `mov` of `n` bytes from `_a` to `_d`: `n` bytes
`bs0` loaded from `_a`, bytes less defined than them stored into `_d`, the stack unchanged. -/
def MovMem (f : Spec.Frame) (d a : Local) (n : Nat) (s s' : Spec.State) : Prop :=
  ∃ pd pa bs0 bsd, f.locals[d]? = some (some pd) ∧ f.locals[a]? = some (some pa) ∧
    s.mem.load pa n .one = .ok bs0 ∧ bytesLeDefined bsd bs0 = true ∧
    s.mem.store pd bsd .one = .ok s'.mem ∧ s'.stack = s.stack

theorem eval_cast_norm {pl : MPlace} {k : CastKind} {oa : Operand} {ty : Spec.Ty} {a : Local}
    (ha : oa.local? = some a) :
    evalStatement (.assign pl (.cast k oa ty)) =
      evalStatement (.assign pl (.cast k (.copy ⟨a, []⟩) ty)) := by
  rcases local?_cases ha with rfl | rfl <;>
    first | rfl | simp only [evalStatement, evalRvalue, evalOperand_move]

/-- `copyAny`'s L0 side.

Proof: `eval_use_norm`, then `copy_mem` (load `bs0` of `n` bytes, decode to `v`, encode to
`bsd`, store); `bs0.length = n` from the load (`load_eq_ok_pos`, the extract's length, `n ≠ 0`;
or `load_zero_inv`); `ty.size = n` from `hn` (`Spec.Ty.size` is `size?.getD 0`);
`Ryo.Spec.Theorems.encode_decode_le ty bs0 v hwf` gives some `bs` with `ty.encode v = some bs`
and `bytesLeDefined bs bs0`, and `bs = bsd` by the two encodings. -/
theorem copyAny_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    {ty : Spec.Ty} {n : Nat} (ha : oa.local? = some a)
    (htd : f.body.locals[d]? = some ty) (hta : f.body.locals[a]? = some ty)
    (hwf : ty.wf = true) (hn : ty.size? = some n)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.use oa))) o s = (.ok (), s')) :
    MovMem f d a n s s' := by
  rw [eval_use_norm ha] at h
  obtain ⟨pd, pa, bs0, v, bsd, hpd, hpa, hlo, hd, hen, hsto, hstk⟩ := copy_mem hs hn htd hta h
  have hl : bs0.length = ty.size := (movLoad_length hlo).trans (tySize_of hn).symm
  obtain ⟨bs, hen', hle⟩ := Ryo.Spec.Theorems.encode_decode_le ty bs0 v hwf hl hd
  have e : bs = bsd := Option.some.inj (hen'.symm.trans hen)
  rw [e] at hle
  exact ⟨pd, pa, bs0, bsd, hpd, hpa, hlo, hle, hsto, hstk⟩

/-- `bitCast`'s L0 side.

Proof: `eval_cast_norm`; invert the assignment as `assign_use_inv` does (its proof carries
over with `evalRvalue (.cast k o ty) ty = evalCast k (← evalOperand o) ty`): `_d`'s pointer,
the cast's value `w`, `typedStore` of `w` at `ty`. `runOn_evalOperand_copy` gives the load at
`ta` (`typedLoad_inv`: `bs0`, `ta.decode bs0 = some v`). For a `bitCastKind`, `evalCast` is
`liftE (transmute mem v ta ty)`: both sizes `n`, `ta.encode v = some bs1`, `ty.decode bs1 =
some w` (the `checkValue` only has to succeed). `encode_decode_le ta bs0 v hwfa` gives
`bytesLeDefined bs1 bs0` (so `bs1.length = n`, by `bytesLeDefined_iff`), and
`encode_decode_le ty bs1 w hwfd` gives `bytesLeDefined bsd bs1` for the stored `bsd`
(`typedStore_inv`); compose (transitivity of `bytesLeDefined`, pointwise from
`bytesLeDefined_iff` and transitivity of `AbstractByte.leDefined` by cases). -/
theorem bitCast_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    {k : CastKind} {ty ta : Spec.Ty} {n : Nat} (hk : bitCastKind k = true)
    (ha : oa.local? = some a)
    (htd : f.body.locals[d]? = some ty) (hta : f.body.locals[a]? = some ta)
    (hwfd : ty.wf = true) (hwfa : ta.wf = true)
    (hnd : ty.size? = some n) (hna : ta.size? = some n)
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k oa ty))) o s = (.ok (), s')) :
    MovMem f d a n s s' := by
  rw [eval_cast_norm ha] at h
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  obtain ⟨pa, ta', va, hpa, hta', hla, hr, hs1⟩ := runOn_evalOperand_copy hs hev
  subst hr
  subst hs1
  have e4 : td = ty := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = ta := Option.some.inj (hta'.symm.trans hta)
  rw [e4] at hst
  rw [e5] at hla hca
  have e3 : evalCast k (va, ta) ty =
      (SemM.getMem >>= fun m => SemM.liftE (transmute m va ta ty)) := by
    cases k <;> first | rfl | (cases hk; done) | simp [bitCastKind] at hk
  rw [e3] at hca
  obtain ⟨m, s3, h7, h8⟩ := runOn_bind_ok hca
  rw [runOn_getMem] at h7
  obtain ⟨hm, hs3⟩ := prod_ok_inj h7
  subst hm
  subst hs3
  obtain ⟨htr, hs2⟩ := runOn_liftE_ok h8
  subst hs2
  subst hs'
  obtain ⟨bs1, hen1, hdec1⟩ := transmute_bytes htr
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv hna hla
  obtain ⟨bsd, hen2, hsto⟩ := typedStore_inv hst
  have hl0 : bs0.length = ta.size := (movLoad_length hlo).trans (tySize_of hna).symm
  obtain ⟨bs1', he1', hle1⟩ := Ryo.Spec.Theorems.encode_decode_le ta bs0 va hwfa hl0 hd0
  have e6 : bs1' = bs1 := Option.some.inj (he1'.symm.trans hen1)
  rw [e6] at hle1
  have hl1 : bs1.length = ty.size :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle1).1.trans
      ((movLoad_length hlo).trans (tySize_of hnd).symm)
  obtain ⟨bsd', he2', hle2⟩ := Ryo.Spec.Theorems.encode_decode_le ty bs1 w hwfd hl1 hdec1
  have e7 : bsd' = bsd := Option.some.inj (he2'.symm.trans hen2)
  rw [e7] at hle2
  exact ⟨pd, pa, bs0, bsd, hpd, hpa, hlo, bytesLe_trans hle2 hle1, hsto, rfl⟩

/-- `ptrCast`'s L0 side.

Proof: invert as in `bitCast_mem`; the load at `.ptr pta va` decodes `bs0` to `.ptr ⟨tp, none⟩`
(`decode_ptr_thin_inv`, size 8 by `size?_ptr_thin`). For each `ptrCastKind`, `evalCast` returns
`.ptr ⟨tp, none⟩` (`ptrToPtr`/`fnPtrToPtr` need `ty` to be a pointer type, else `illFormed`
contradicts `h`; either branch of `isWide` gives `⟨tp, none⟩`, as `tp.widen = ⟨tp, none⟩`;
`arrayToPointer` gives `p.thin.widen`, the same; the other two return the value). Its encoding
at `.ptr ptd vd` (`hkd`) is `encodePtr tp`, which is `bsd`; that it is less defined than `bs0`
is `reenc_ptr`'s argument with `ι = some`: each byte of `encodePtr tp` is `bs0`'s with its
provenance kept when `ptrProvOf bs0 = some q` (every byte carries `q` at its position) and
dropped otherwise (`decodePtr_eq`, `decodeBits_iff`, `encodePtr_eq`, `getElem_ptrBytes`,
`ptrProvOf_iff`), then `bytesLeDefined_iff`. -/
theorem ptrCast_mem {o : Spec.Oracle} {s s' : Spec.State} {f : Spec.Frame}
    {rest : List Spec.Frame} (hs : s.stack = f :: rest) {d a : Local} {oa : Operand}
    {k : CastKind} {ty : Spec.Ty} {ptd pta : PtrType} {vd va : ValidRange}
    (hk : ptrCastKind k = true) (ha : oa.local? = some a)
    (hkd : ptd.metaKind = .none) (hka : pta.metaKind = .none)
    (htd : f.body.locals[d]? = some (.ptr ptd vd)) (hta : f.body.locals[a]? = some (.ptr pta va))
    (h : runOn (evalStatement (.assign ⟨d, []⟩ (.cast k oa ty))) o s = (.ok (), s')) :
    MovMem f d a 8 s s' := by
  rw [eval_cast_norm ha] at h
  obtain ⟨pd, td, r, s1, w, s2, hpd, htd', hev, hca, mem', hst, hs'⟩ := assign_cast_inv hs h
  obtain ⟨pa, ta', v0, hpa, hta', hla, hr, hs1⟩ := runOn_evalOperand_copy hs hev
  subst hr
  subst hs1
  have e4 : td = .ptr ptd vd := Option.some.inj (htd'.symm.trans htd)
  have e5 : ta' = .ptr pta va := Option.some.inj (hta'.symm.trans hta)
  rw [e4] at hst
  rw [e5] at hla hca
  obtain ⟨bs0, hlo, hd0⟩ := typedLoad_inv (size?_ptr_thin hka) hla
  obtain ⟨tp, hlen0, hdp, hv⟩ := decode_ptr_thin_inv hka hd0
  subst hv
  obtain ⟨hw, hs2⟩ := evalCast_thin_ok hk hca
  subst hw
  subst hs2
  subst hs'
  obtain ⟨bsd, hen, hsto⟩ := typedStore_inv hst
  have he' : bsd = encodePtr tp := by
    simp [Spec.Ty.encode, hkd] at hen
    first | exact hen.symm | exact hen
  rw [he'] at hsto
  exact ⟨pd, pa, bs0, encodePtr tp, hpd, hpa, hlo, ptr_reenc_le hlen0 hdp, hsto, rfl⟩

/-! ### The common lift -/

/-- A `mov` of `n` bytes from `_a`'s slot to `_d`'s private slot simulates any L0 effect
`MovMem`.

Proof: as `sim_copyBytes` followed by `lift_copyPtr`, with `MovMem`'s facts in place of the
`use` inversion and `Reenc`: `movInsnOk_spec`, `intTyOk_spec` (rewrite the view with `hmode`,
`hρ`); `hrel.opnd` gives `_a`'s `LocalRel`, `hrel.priv_dst` (with `hpos`) `_d`'s private
allocation; `readLocal_inj` (after rewriting the load's size to `sa.size`) gives R's read `ba`
with `BytesInj ι bs0 ba`, so `BytesInj ι bsd ba` (`BytesInj.of_le`) and `ba.length = n`; the
frame write succeeds (`writeEscaped_private'`), `opSem_mov_fwd` is the step, `writeLocal_priv`
the new `MemInj` and `_d`'s `LocalRel`, `LocalRel.store_other` and
`LocalRel.writeFrame_apart` the other locals'. Then `step_of_view`, `hrel.after`, and for
`Hidden`/`ProvBounded` `le_prov` with `hrel.hidden.load`/`hpb.load` exactly as in
`lift_copyPtr` (`Hidden.store_hidden`, `ProvBounded.store`, `store_size`). -/
theorem lift_movMem {Γ : StmtCtx} {c : R.Code} {s1 : R.RState} {ch : OpSem.Choice} {ι : Inj}
    {live live' : Local → Bool} {s s' : Spec.State} {f : Spec.Frame}
    (hmode : Γ.mode = c.mode) (hρ : Γ.ρ = c.ρ)
    {d a : Local} {n : Nat} {sd sa : LocalSlot} {i : R.Insn}
    (hsd : Γ.slots[d]? = some sd) (hsa : Γ.slots[a]? = some sa)
    (hsize : sd.size = n ∧ sa.size = n) (hpos : 0 < n) (hoff : offOk sd.off ∧ offOk sa.off)
    (hpriv : ∀ k < sd.size, Γ.escaped (sd.off + k) = false)
    (hmi : movInsnOk Γ i n sd.off sa.off = true)
    (hi : c.d.insns[s1.pc]? = some i) (hsc : c.scopesAt s1.pc = []) (hpe : c.mode.pe = false)
    (hpl : PlainView c.mode c.ρ i) (hrel : FnRel Γ ι live f s.mem s1)
    (hpb : ProvBounded s.mem)
    (hla : live a = true) (hlive' : ∀ l, live' l = true → l = d ∨ live l = true)
    (hmm : MovMem f d a n s s') :
    LiftOut Γ c ch ι live' f s s' s1 := by
  obtain ⟨pd, pa, bs0, bsd, hpd, hpa, hlo0, hle, hsto, hstk⟩ := hmm
  obtain ⟨v, ty, r, hv, hh, hty, ho, hops, hctl⟩ := movInsnOk_spec hmi
  rw [hmode, hρ] at hv
  obtain ⟨sg, hty'⟩ := intTyOk_spec hty
  have hra := hrel.opnd hpa hsa hla
  have hpos' : 0 < sd.size := by rw [hsize.1]; exact hpos
  obtain ⟨ad, xd, hp, hι, hxd, hl, haddr, hpaddr, hsz, hpv⟩ := hrel.priv_dst hpd hsd hpos' hpriv
  have hf1 := offOk_spec hoff.1
  have hf2 := offOk_spec hoff.2
  -- R's read refines `bs0`, hence `bsd`
  have hloa : s.mem.load pa sa.size .one = .ok bs0 := by rw [hsize.2]; exact hlo0
  obtain ⟨ba, hrfa, hia⟩ := readLocal_inj hrel.frame.mem hra hloa
  rw [hsize.2] at hrfa
  have hbs := BytesInj.of_le hle hia
  have hlend : bsd.length = n :=
    ((Ryo.Spec.Theorems.bytesLeDefined_iff _ _).mp hle).1.trans (movLoad_length hlo0)
  have hlenb : ba.length = n := (BytesInj.length hbs).symm.trans hlend
  -- R's write
  have hpw : ∀ k < ba.length, s1.st.escapedAt (sd.off + k) = none := by
    intro k hk
    rw [hlenb, ← hsize.1] at hk
    exact hpv k hk
  obtain ⟨st', hwr⟩ : ∃ st', s1.st.writeFrame sd.off ba = .ok st' := by
    unfold OpSem.State.writeFrame
    rw [writeEscaped_private' hpw]
    exact ⟨_, rfl⟩
  have hop := opSem_mov_fwd (ch := ch) hh hty' ho ⟨hf1.1, hf1.2, hf2.1, hf2.2⟩ hrfa hlenb hwr
  have hlen0 : bsd.length = sd.size := by rw [hlend, hsize.1]
  obtain ⟨hmi', hrd⟩ := writeLocal_priv hrel.frame.mem ad xd hp hι hxd hl haddr hpaddr hsz hpv
    hbs hlen0 hsto hwr
  have hoth : ∀ (slot : LocalSlot) p lv, LocalRel ι s1.fp s1.st s.mem slot p lv →
      p.prov ≠ pd.prov → (sd.off + sd.size ≤ slot.off ∨ slot.off + slot.size ≤ sd.off) →
      LocalRel ι s1.fp st' s'.mem slot p lv := by
    intro slot p lv hr hne hap
    have h1 := LocalRel.store_other hr hsto (.inl (Ne.symm hne))
    exact LocalRel.writeFrame_apart h1 hwr hpw (by rw [hlenb, ← hsize.1]; exact hap)
  have hsub := le_prov hle
  -- `Hidden`: the stored provenance is the loaded bytes', which `Hidden` excludes
  have hhid := hrel.hidden.load hlo0
  have hhid' : ∀ b ∈ bsd, ∀ fr, b.provFrag = some fr → ¬ PrivAlloc ι f fr.prov := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hhid _ (List.getElem_mem hj) fr0 hf0
  -- the bound: likewise
  have hbd := hpb.load hlo0
  have hbd' : BytesBounded s.mem.allocs.size bsd := by
    intro b hb fr hfr
    obtain ⟨j, hj, fr0, hf0, he0⟩ := hsub b hb fr hfr
    rw [← he0]
    exact hbd _ (List.getElem_mem hj) fr0 hf0
  have hesc := (Ryo.Proofs.OpFacts.opSem_out hop).2.1
  exact ⟨st', step_of_view hi hsc hpe hpl hv hctl (by rw [hops]; exact hop), hstk,
    hrel.after hpd hsd hmi' hrd hoth (hrel.hidden.store_hidden hsto hhid') hesc hlive',
    hpb.store hsto hbd', Nat.le_of_eq (store_size hsto).symm,
      memKept_load hsto hlo0 hsub⟩

-- `lift_copy` (any destination) is in `SimDst.lean`.

end Ryo.Proofs.Lower
