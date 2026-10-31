/-
Ryo.Vm.R.Islands — the island contracts' operand roles: per template (its diagnostic item
name, `rustc_diagnostic_item` in `vm/rt/src/island.rs`) and per position of the island's
`ops` list, whether the template reads the operand's slot, only writes it, or neither. This is
part of the trusted island contract (aot.md §C1 "Islands", §C6; reduced.md §C0.4): the
dead-store check (`Ryo.Vm.Frame`) takes a slot the contract says isn't read as read by no
operand of the island.

Derived from the templates' code (`vm/rt/src/island.rs`, each reads its operands through
`slot::<T>(fp, ops, i).read()` and writes its result with `slot::<R>(fp, ops, i).write(…)` or
`ptr::write`, which don't read the destination), and the backend's operand lists (the lowering
calls `FnCx::island` with the operands in this order):

- `ryo_island_call` (`call<F, Args, R>`): `[args, dest]`: reads the argument block, writes
  `R` (`lower/call.rs`, `emit_call`, `Target::Template`: `[(block, bn), (d, dn)]`).
- `ryo_island_call_cN` (`call_c0` … `call_c16`): `[args, dest, fn pointer]`: reads the fn
  pointer and the argument block, writes `R` (`emit_call`, `Target::CIsland`:
  `[(block, bn), (d, dn), (p, 8)]`).
- `ryo_island_drop_in_place` (`drop_in_place<T>`): `[ptr]`: reads the (thin or wide) pointer
  (`drop_terminator`). The pointee is memory through a pointer, not an operand.
- `ryo_island_catch_unwind` (`catch_unwind<Data>`): `[try_fn, data, catch_fn, dest]`: reads
  the three, writes the `bool` result (`lower/intrinsic.rs`, `"catch_unwind"`).
- The intrinsic wrappers (`intrinsic_wrappers!`): the `n` inputs in order, read, then the
  destination, written (`FnCx::wrapper`: `ins` then `(d, dn)`; `binop.rs`: `[a, b, dest]`;
  `cast.rs`: `[src, dest]`): `compare_bytes` (3), `raw_eq` (2), the `simd_*` wrappers (their
  arity, which nothing on the backend side records: `templates::wrapper` finds a template by
  its diagnostic item `ryo_island_<name>`, and `FnCx::simd_intrinsic` forwards the
  intrinsic's generic arguments as they are, so each wrapper's must match the intrinsic's),
  the 128-bit `mul_w128`, `div_{u,s}_w128`, `rem_{u,s}_w128`, `mul_ovf_{u,s}_w128` (2), and
  `ryo_island_as_cast` (1). The table also has `sqrtf32/64` (1), `powif32/64` (2) and
  `fmaf32/64` (3), whose templates no lowering emits now; the `volatile_*` wrappers, which
  are emitted, aren't in it (so they read every operand, which is sound).

Any other name, or an operand list of another length than the template's, reads every operand
(`roles` is `none`).
-/

namespace Ryo.Vm.R.Islands

/-- What a template does with one of its operand slots. -/
inductive Role
  /-- It reads the slot (and may write it). -/
  | read
  /-- It only writes the slot, whole (its extent: `size_of::<R>()` bytes, by a typed write
  that reads nothing, padding included as `Uninit`), when it returns: the slot's bytes before
  the island are never observed, and they are overwritten once the island falls through. -/
  | write
  /-- It doesn't access the slot. -/
  | unused
deriving DecidableEq, Repr, Inhabited

/-- The intrinsic wrappers of `vm/rt/src/island.rs` and their input counts. -/
def wrappers : List (String × Nat) :=
  [("sqrtf32", 1), ("sqrtf64", 1), ("powif32", 2), ("powif64", 2), ("fmaf32", 3), ("fmaf64", 3),
   ("compare_bytes", 3), ("raw_eq", 2),
   ("simd_add", 2), ("simd_sub", 2), ("simd_mul", 2), ("simd_div", 2), ("simd_rem", 2),
   ("simd_shl", 2), ("simd_shr", 2), ("simd_and", 2), ("simd_or", 2), ("simd_xor", 2),
   ("simd_saturating_add", 2), ("simd_saturating_sub", 2), ("simd_minimum_number_nsz", 2),
   ("simd_maximum_number_nsz", 2), ("simd_neg", 1), ("simd_fabs", 1), ("simd_bswap", 1),
   ("simd_bitreverse", 1), ("simd_ctlz", 1), ("simd_ctpop", 1), ("simd_cttz", 1),
   ("simd_ceil", 1), ("simd_floor", 1), ("simd_round", 1), ("simd_round_ties_even", 1),
   ("simd_trunc", 1), ("simd_fsqrt", 1), ("simd_fma", 3), ("simd_relaxed_fma", 3),
   ("simd_funnel_shl", 3), ("simd_funnel_shr", 3), ("simd_eq", 2), ("simd_ne", 2),
   ("simd_lt", 2), ("simd_le", 2), ("simd_gt", 2), ("simd_ge", 2), ("simd_splat", 1),
   ("simd_cast", 1), ("simd_as", 1), ("simd_bitmask", 1), ("simd_reduce_add_unordered", 1),
   ("simd_reduce_mul_unordered", 1), ("simd_reduce_add_ordered", 2),
   ("simd_reduce_mul_ordered", 2), ("simd_reduce_max", 1), ("simd_reduce_min", 1),
   ("simd_reduce_and", 1), ("simd_reduce_or", 1), ("simd_reduce_xor", 1),
   ("simd_reduce_all", 1), ("simd_reduce_any", 1), ("simd_select", 3),
   ("simd_select_bitmask", 3), ("simd_arith_offset", 2), ("simd_cast_ptr", 1),
   ("simd_expose_provenance", 1), ("simd_with_exposed_provenance", 1),
   ("mul_w128", 2), ("div_u_w128", 2), ("div_s_w128", 2), ("rem_u_w128", 2),
   ("rem_s_w128", 2), ("mul_ovf_u_w128", 2), ("mul_ovf_s_w128", 2),
   ("as_cast", 1)]

/-- The roles of template `t`'s operands, by position; `none` for a name this table doesn't
know. -/
def roles (t : String) : Option (List Role) :=
  let pre := "ryo_island_"
  if !t.startsWith pre then none
  else
    let n := (t.drop pre.length).toString
    if n == "call" then some [.read, .write]
    else if n == "drop_in_place" then some [.read]
    else if n == "catch_unwind" then some [.read, .read, .read, .write]
    else if let some k := callC? n then
      if k ≤ 16 then some [.read, .write, .read] else none
    else (wrappers.lookup n).map fun k => List.replicate k .read ++ [.write]
where
  /-- `call_cN`'s `N`. -/
  callC? (n : String) : Option Nat :=
    if n.startsWith "call_c" then
      let d := (n.drop 6).toString
      let canonical := d.length == 1 || d.front != '0'
      if !d.isEmpty && d.all Char.isDigit && canonical then d.toNat? else none
    else none

/-- Operand `i`'s role in template `t`'s `ops` list of `count` operands: `read` unless the
table knows `t` with exactly `count` operands. -/
def role (t : String) (count i : Nat) : Role :=
  match roles t with
  | some rs => if rs.length == count then rs[i]?.getD .read else .read
  | none => .read

end Ryo.Vm.R.Islands
