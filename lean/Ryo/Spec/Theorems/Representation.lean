/-
Ryo.Spec.Theorems.Representation — the generic properties of the representation relation.

Ports: MiniRust `lang/representation.md` § Generic properties (the laws `encode`/`decode` must
satisfy; violating them is a spec bug).

Proved:
- `leDecode_leEncode`, `encodeBits_length`, `encodePtr_length`;
- `int_roundtrip` (`ofBits ∘ toBits` is the identity on representable integers, for the five
  integer sizes);
- `decode_encode_int`, `decode_encode_bool` (round trip at scalar
  types), `encode_length_int`, `encode_length_bool`.

Open goals (stated with `sorry`; mir-spec §A.8 step 3 tracks them here):
1. `encode_length`: for every well-formed sized type and well-formed value, the encoding has
   the type's size.
2. `decode_encode`: for every well-formed sized type and value accepted by `check_value`,
   `decode (encode v) = some v`.
3. `encode_decode_le`: if `decode bytes = some v`, then `encode v` is less defined than
   `bytes`.
4. `decode_mono`: more-defined bytes decode to a more-defined value (or the same failure).
5. `store_load`: a `typedStore` followed by a `typedLoad` at the same type and pointer
   returns the stored value.
-/
import Ryo.Spec.Lang.WellFormed

namespace Ryo.Spec.Theorems

theorem leDecode_leEncode (n v : Nat) : leDecode (leEncode n v) = v % 2 ^ (8 * n) := by
  induction n generalizing v with
  | zero => simp [leEncode, leDecode, Nat.mod_one]
  | succ n ih =>
    simp only [leEncode, leDecode, ih, UInt8.toNat_ofNat', Nat.reducePow]
    have h : 2 ^ (8 * (n + 1)) = 256 * 2 ^ (8 * n) := by
      rw [Nat.mul_succ, Nat.pow_add]; omega
    rw [h, Nat.mod_mul]
    omega

theorem encodeBits_length (size n : Nat) : (encodeBits size n).length = size := by
  simp [encodeBits, leEncode_length]

theorem encodePtr_length (p : ThinPointer) : (encodePtr p).length = 8 := by
  simp [encodePtr, Target.PTR_SIZE, leEncode_length]

theorem decodeBits_encodeBits (size n : Nat) :
    decodeBits (encodeBits size n) = some (n % 2 ^ (8 * size)) := by
  unfold decodeBits encodeBits
  have : ∀ (l : List UInt8), (l.map AbstractByte.ofByte).mapM AbstractByte.data = some l := by
    intro l
    induction l with
    | nil => rfl
    | cons b l ih => simp_all [AbstractByte.ofByte, AbstractByte.data]
  rw [this]
  simp [leDecode_leEncode]

/-- `ofBits (toBits i) = i` for representable `i` at the five integer sizes. -/
theorem int_roundtrip (t : IntType) (hwf : t.wf = true) (i : Int) (h : t.canRepresent i = true) :
    t.ofBits (t.toBits i) = i := by
  rcases t with ⟨signed, size⟩
  have hs : size = 1 ∨ size = 2 ∨ size = 4 ∨ size = 8 ∨ size = 16 := by
    simp [IntType.wf] at hwf; omega
  simp only [IntType.canRepresent, IntType.min, IntType.max, IntType.bits, Bool.and_eq_true] at h
  simp only [IntType.ofBits, IntType.toBits, IntType.modulus, IntType.bits]
  rcases hs with rfl | rfl | rfl | rfl | rfl <;> cases signed <;> simp_all <;> omega

theorem toBits_lt (t : IntType) (i : Int) : t.toBits i < 2 ^ (8 * t.size) := by
  simp only [IntType.toBits, IntType.modulus, IntType.bits]
  have hm : 0 < 2 ^ (t.size * 8) := Nat.two_pow_pos _
  have h1 := Int.emod_lt_of_pos i (b := ((2 ^ (t.size * 8) : Nat) : Int)) (by omega)
  have h2 := Int.emod_nonneg i (b := ((2 ^ (t.size * 8) : Nat) : Int)) (by omega)
  rw [Nat.mul_comm]; omega

theorem decode_encode_int (t : IntType) (r : ValidRange) (hwf : t.wf = true) (i : Int)
    (h : t.canRepresent i = true) (hr : r.contains (t.toBits i) = true) :
    ((Ty.int t r).encode (.int i)).bind (Ty.int t r).decode = some (.int i) := by
  simp [Ty.encode, h, Ty.decode, encodeBits_length, decodeBits_encodeBits,
    Nat.mod_eq_of_lt (toBits_lt t i), hr, int_roundtrip t hwf i h]

theorem decode_encode_bool (b : Bool) :
    (Ty.bool.encode (.bool b)).bind Ty.bool.decode = some (.bool b) := by
  cases b <;> rfl

theorem encode_length_int (t : IntType) (r : ValidRange) (i : Int) (bs : List AbstractByte)
    (h : (Ty.int t r).encode (.int i) = some bs) : bs.length = t.size := by
  simp only [Ty.encode] at h
  split at h
  · cases h; exact encodeBits_length _ _
  · cases h

theorem encode_length_bool (b : Bool) (bs : List AbstractByte)
    (h : Ty.bool.encode (.bool b) = some bs) : bs.length = 1 := by
  simp only [Ty.encode] at h
  cases h; rfl

/-! ## Open goals -/

theorem encode_length (t : Ty) (v : Value) (bs : List AbstractByte) (_ : t.wf = true)
    (_ : t.isSized = true) (_ : v.wfShape t = true) (_ : t.encode v = some bs) :
    bs.length = t.size := by
  sorry

theorem decode_encode (mem : Memory) (t : Ty) (v : Value) (_ : t.wf = true)
    (_ : t.isSized = true) (_ : checkValue mem v t = .ok ()) :
    (t.encode v).bind t.decode = some v := by
  sorry

theorem encode_decode_le (t : Ty) (bytes : List AbstractByte) (v : Value)
    (_ : t.wf = true) (_ : bytes.length = t.size) (_ : t.decode bytes = some v) :
    ∃ bs, t.encode v = some bs ∧ bytesLeDefined bs bytes = true := by
  sorry

theorem decode_mono (t : Ty) (b1 b2 : List AbstractByte) (_ : t.wf = true)
    (_ : bytesLeDefined b1 b2 = true) :
    Option.leDefinedBy Value.leDefined (t.decode b1) (t.decode b2) = true := by
  sorry

theorem store_load (mem mem' : Memory) (p : ThinPointer) (t : Ty) (v : Value) (al : Align)
    (_ : t.wf = true) (_ : checkValue mem v t = .ok ())
    (_ : typedStore mem p v t al = .ok mem') :
    ∃ w, typedLoad mem' p t al = .ok w ∧ Value.leDefined w v = true := by
  sorry

end Ryo.Spec.Theorems
