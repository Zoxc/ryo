/-
Ryo.Vm.R.View — the op view of R (reduced.md §C0.5, §C0.6): `unpack`, a handler's operands
from its argument registers, and `view`, an R instruction as a full opcode with the operands
`opSem` takes and its shape's control flow.

- `unpack ρ h fpArg args`: what `ryo_h_<h>` reads from `rdi … r9` by `asm::layout(h, mode)`
  (`asm::read`, `vm/bytecode/src/asm/mod.rs`), one `OpSem.Val` per operand of `h`, with the
  checks of Rust's full decoder (`handler_operands`, `asm/decode.rs`): `none` when the
  arguments don't fit the layout.
- `view mode ρ i`: a native instruction as its full opcode with its operands as `Val`s; a
  `handler h args t` as `h` with `unpack` and `t`. It mirrors Rust's `asm::decode`, which reads
  the same machine code to full instructions (`insn`, `handler_operands`, `then`), and the
  checks `encode_reduced` makes of a `handler` (`asm/reduced.rs`).

**Addresses.** `Val.addr` is a pointer with provenance, which the argument doesn't carry: the
argument names a constant, data offset, symbol slot, site cache slot or code constant, whose
address the image fixes. `view` and `unpack` take that placement as `ρ : Arg → Option
ThinPointer` (only applied to `const`/`data`/`sym`/`site`/`ro` arguments): an image's
allocations (the constant pool and statics as allocations, D7/D29) give it, and a test takes
an injective symbolic one. A native instruction's `Const`/`Abs`/`Sym`/`Site` operands go
through `ρ` too, as the argument of that address.

**Operands `opSem` doesn't get** (targets, `neg`, a call's function, word lists: a call's
arguments, an island's operands) are `Val.none`. The control flow comes back in `View.ctl`:
`some t`, the shape's `Then` (`next`, a branch with its polarity and target, the switch
table with the default last, `trap`), for an instruction `opSem` gives the meaning of (shapes
`op`, `br`, `switch`, `trap`, `lpad`); `none` for R's own instructions (`jmp`, the calls,
`tail_call*`, `ret`, `arg`, `island`), whose meaning is §C0.4's and whose targets, functions
and lists stay in the native `Insn`.

**The intended semantics of R** (no R step function exists yet): for an instruction `i` at
`pc` with `view i = some v`, `v.ctl = some t`,

```
semR i (pc, st) = do let (c, st') ← opSem v.op v.ops st ch; pure (t.succ pc c, st')
```

(`Then.succ`: the next instruction, the branch taken when the returned `bool` differs from
`neg`, the table entry of the returned index, the default last), and `view` is `none` only on
instructions that don't decode to any full instruction. A native instruction and a handler
call of the same opcode and operands have the same view, so they mean the same.

Not checked here, as `asm::decode_reduced` doesn't either: that a handler call isn't of
operands the opcode inlines (`asm::decode`'s "handler call of an inlined instruction").
-/
import Ryo.Vm.R.Syntax
import Ryo.Vm.OpSem.Basic
import Ryo.Obj.Reloc

namespace Ryo.Vm.R

open Ryo.Spec Ryo.Vm.OpSem

/-- Where the addressed things of handler arguments are (see the module comment). -/
abbrev Addrs := Arg → Option ThinPointer

/-- A 32-bit word as the `i32` Rust reads. -/
def int32 (w : Nat) : Int := (BitVec.ofNat 32 w).toInt

/-- Register `r`'s value if it is an immediate. -/
def regImm (args : List Arg) (r : Nat) : Option Nat :=
  match args[r]? with
  | some (.imm v) => some v.toNat
  | _ => none

/-- Register `r`'s address if it is `ρ` of an argument `ok` accepts. -/
def regAddr (ρ : Addrs) (args : List Arg) (r : Nat) (ok : Arg → Bool) : Option Val := do
  let a ← args[r]?
  if !ok a then none
  return .addr (← ρ a)

/-- The operand of kind `k` at `loc` (`asm::read`, with `handler_operands`' checks): a 32-bit
operand from its half of a shared register, or from a register whose other bits are zero; a
64-bit one from a register; `Mem`, `U128` and case lists from two (`p` and the zero-extended
32-bit `k`; low and high; the values' address and count). -/
def unpackOpnd (ρ : Addrs) (args : List Arg) (k : OperandKind) (loc : Asm.Loc) : Option Val := do
  if loc.count == 0 then
    -- What the handler doesn't receive (`kind_regs` 0).
    match k with
    | .target | .neg | .func | .handler | .list .arg => return .none
    | _ => none
  let r := loc.reg
  -- `narrow`: the operand's bits, nothing above `bits`.
  let narrow (bits : Nat) : Option Nat := do
    let v ← regImm args r
    let v := if loc.shared then (v >>> loc.shift) % 2 ^ 32 else v
    if v < 2 ^ bits then some v else none
  match k with
  | .slot => return .slot (int32 (← narrow 32))
  | .u8 => return .imm (← narrow 8)
  | .u16 => return .imm (← narrow 16)
  | .u32 => return .imm (← narrow 32)
  | .u64 | .i64 => return .imm (← regImm args r)
  | .u128 => return .imm ((← regImm args r) + (← regImm args (r + 1)) * 2 ^ 64)
  | .mem =>
    let p ← narrow 32
    let x ← regImm args (r + 1)
    if x ≥ 2 ^ 32 then none
    return .mem (int32 p) (int32 x)
  | .const => regAddr ρ args r fun | .const _ => true | _ => false
  | .abs => regAddr ρ args r fun | .const _ | .data _ => true | _ => false
  | .sym => regAddr ρ args r fun | .sym _ => true | _ => false
  | .site => regAddr ρ args r fun | .site _ => true | _ => false
  | .list .target => return .targets (← regImm args r)
  | .list .case8 | .list .case16 | .list .case32 | .list .case64 | .list .case128 =>
    match args[r]?, regImm args (r + 1) with
    | some (.ro o), some n => return .cases (← ρ (.ro o)) n
    | _, _ => none
  | _ => none

/-- `unpack(layout h)`: the operands handler `h` reads from its argument registers `args`
(`rdi` on), one `Val` per operand of `h`. `fp` is `args[0]` with `fpArg` (else the handler
reads `rbp`), `lpad`'s exception object the register before its operands; each operand
register holds an immediate or an address (`Arg.fp` and `Arg.exception` nowhere else), as
`h`'s layout gives it. `none` for an opcode without a handler, a wrong register count, or
a register that doesn't fit its operand. -/
def unpack (ρ : Addrs) (h : Full.Opcode) (fpArg : Bool) (args : List Arg) : Option Operands := do
  let l ← h.layout fpArg
  if args.length != l.regs then none
  if fpArg && args[0]? != some .fp then none
  if h.info.shape == .lpad && args[l.first - 1]? != some .exception then none
  h.info.operands.zipIdx.mapM fun (o, i) => unpackOpnd ρ args o.kind (l.locs.getD i default)

/-- A native operand of kind `k` as the `Val` the handler of its opcode would get. -/
def nativeVal (ρ : Addrs) : OperandKind → Opnd Nat → Option Val
  | .slot, .slot s => some (.slot s.toInt)
  | .mem, .mem p x => some (.mem p.toInt x.toInt)
  | .u8, .imm v => if v.toNat < 2 ^ 8 then some (.imm v.toNat) else none
  | .u16, .imm v => if v.toNat < 2 ^ 16 then some (.imm v.toNat) else none
  | .u32, .imm v => if v.toNat < 2 ^ 32 then some (.imm v.toNat) else none
  | .u64, .imm v | .i64, .imm v => some (.imm v.toNat)
  | .u128, .imm128 v => some (.imm v.toNat)
  | .const, .const n | .abs, .const n => (ρ (.const n)).map .addr
  | .abs, .data d => (ρ (.data d)).map .addr
  | .sym, .sym s => (ρ (.sym s)).map .addr
  | .site, .site s => (ρ (.site s)).map .addr
  | .func, .func _ | .target, .target _ | .neg, .neg _ => some .none
  | .list .target, .targets ts => some (.targets ts.length)
  | .list .word, .words _ => some .none
  | _, _ => none

/-- The view of an instruction: the full opcode, the operands `opSem` takes, and the shape's
control flow (`none` for R's own instructions). -/
structure View where
  op : Full.Opcode
  ops : Operands
  ctl : Option (Then Nat)
deriving Repr, DecidableEq, Inhabited

/-- Whether `op` is one `opSem` gives the meaning of, by shape (the handler shapes). -/
def opShape (op : Full.Opcode) : Bool :=
  match op.info.shape with
  | .op | .br | .switch | .trap | .lpad => true
  | _ => false

/-- A native instruction's control flow, from its operands (`asm::decode`'s `then` puts
`neg`, `t`, the lists' targets and `default` there): `none` if they aren't there. -/
def nativeCtl (op : Full.Opcode) (ops : List (Opnd Nat)) : Option (Then Nat) := do
  let named (n : String) : Option (Opnd Nat) :=
    ((op.info.operands.zip ops).find? (·.1.name == n)).map (·.2)
  match op.info.shape with
  | .op | .lpad => pure .next
  | .trap => pure .trap
  | .br =>
    let (some (.neg n), some (.target t)) := (named "neg", named "t") | none
    pure (.branch n t)
  | .switch =>
    let some (.target d) := named "default" | none
    pure (.table (ops.flatMap (fun | .targets ts | .cases _ ts => ts | _ => []) ++ [d]))
  | _ => none

/-- The number of cases of a switch's operands: its target or case lists' lengths. -/
def caseCount (ops : Operands) : Nat :=
  (ops.map fun | .targets n | .cases _ n => n | _ => 0).sum

/-- `view`: a native instruction as its full opcode and operands; `handler h args t` as `h`
with `unpack` and `t`, which must be `h`'s shape's (`encode_reduced`'s check: a branch for
`br`, a table with an entry per case and the default for `switch`, `trap`, else `next`). -/
def view (mode : Ryo.Obj.Mode) (ρ : Addrs) : Insn → Option View
  | .native op ops => do
    let f ← op.full
    let infos := f.info.operands
    if infos.length != ops.length then none
    let vals ← (infos.zip ops).mapM fun (i, o) => nativeVal ρ i.kind o
    let ctl ← if opShape f then some <$> nativeCtl f ops else pure Option.none
    pure ⟨f, vals, ctl⟩
  | .handler h args t => do
    if !h.hasHandler then none
    let vals ← unpack ρ h mode.fpArg args
    let ok := match h.info.shape, t with
      | .op, .next | .lpad, .next | .trap, .trap | .br, .branch .. => true
      | .switch, .table ts => ts.length == caseCount vals + 1
      | _, _ => false
    if !ok then none
    pure ⟨h, vals, some t⟩

/-- The instruction after one at `pc` whose operation gave `c`, by its shape's control flow
(`none` after a `trap`, or a control effect of the wrong form): `next`, the branch target when
the returned `bool` isn't `neg`, the table's entry `i` (the default last). -/
def Then.succ (t : Then Nat) (pc : Nat) (c : Control) : Option Nat :=
  match t, c with
  | .next, .next => some (pc + 1)
  | .branch neg x, .branch b => some (if b != neg then x else pc + 1)
  | .table ts, .index i => ts[i]?
  | _, _ => none

end Ryo.Vm.R
