/-
Ryo.Proofs.DeadStore.Names — the operand-name facts `Frame.handler`'s exact branch needs of each
handler's footprint (`footprintNamesOk`), as Bool functions, apart from `RStep.lean` so that
`RyoTest.Tables` can evaluate them (the tables comparing `String`s aren't kernel-checked).
-/
import Ryo.Vm.OpSem.Footprint
import Ryo.Vm.Generated

namespace Ryo.Proofs.DeadStore

open Ryo.Vm

def isFrameKind : OperandKind → Bool
  | .slot | .mem => true
  | _ => false

def isImmKind : OperandKind → Bool
  | .u8 | .u16 | .u32 | .u64 | .i64 => true
  | _ => false

/-- The operands an extent's length needs (`slotVal` and `cases`, memory accesses only, name
none that could be found). -/
def extentNames : OpSem.Extent → List String
  | .bytes _ => []
  | .opnd a => [a]
  | .mul a b => [a, b]
  | .slotVal _ => ["?"]
  | .cases _ _ => ["?"]

def namedKind (op : Full.Opcode) (n : String) (p : OperandKind → Bool) : Bool :=
  op.info.operands.any fun o => o.name == n && p o.kind

/-- An extent `Frame.handler` evaluates from operand values (not `slotVal` or `cases`, which
only memory accesses use). -/
def lenExt : OpSem.Extent → Bool
  | .bytes _ | .opnd _ | .mul _ _ => true
  | _ => false

/-- Every frame access of `op`'s footprint names a slot or memory operand, its extent is one
`lenExt` accepts, naming immediates, its addresses taken slot or memory operands, and the
operand names are distinct: so the exact branch of `Frame.handler` evaluates whenever
`R.unpack` does. -/
def footprintNamesOk (op : Full.Opcode) : Bool :=
  match OpSem.footprint op with
  | none => true
  | some fp =>
    decide ((op.info.operands.map (·.name)).Nodup) &&
      (fp.reads ++ fp.writes).all (fun a => namedKind op a.opnd isFrameKind &&
        (extentNames a.extent).all (fun n => namedKind op n isImmKind) && lenExt a.extent) &&
      fp.addrs.all fun n => namedKind op n isFrameKind

/-- The names `footprintOf k _` gives its reads' and writes' operands and extents (in order),
and its addresses taken: independent of the parameters. -/
def namesOf : Handlers.HandlerKind → List (String × List String)
  | .mov => [("s", []), ("d", [])]
  | .copy => [("s", ["len"]), ("d", ["len"])]
  | .imm => [("d", [])]
  | .konst => [("d", ["len"])]
  | .zero => [("d", ["len"])]
  | .load => [("m", []), ("d", [])]
  | .store => [("m", []), ("s", [])]
  | .load_copy => [("m", []), ("d", ["len"])]
  | .store_copy => [("m", []), ("s", ["len"])]
  | .memcpy | .memmove => [("dp", []), ("sp", []), ("n", [])]
  | .memset => [("dp", []), ("b", []), ("n", [])]
  | .fill => [("d", ["elem_size", "count"])]
  | .addr | .addr_sym | .addr_const => [("d", [])]
  | .ptr_add => [("p", []), ("d", [])]
  | .ptr_index => [("p", []), ("i", []), ("d", [])]
  | .bin | .bin_fn | .binop | .shift | .fbin | .fmeth => [("a", []), ("b", []), ("d", [])]
  | .cmp | .cmp3 | .fcmp => [("a", []), ("b", []), ("d", [])]
  | .rot => [("a", []), ("b", []), ("d", [])]
  | .bin_imm | .binop_imm | .shift_imm | .un | .fneg | .«fun» => [("a", []), ("d", [])]
  | .cmp_imm | .count => [("a", []), ("d", [])]
  | .ovf => [("a", []), ("b", []), ("d", []), ("o", [])]
  | .vsplat => [("s", []), ("d", [])]
  | .vcmp => [("a", []), ("b", []), ("d", [])]
  | .vmsb => [("a", []), ("d", [])]
  | .cvt => [("s", []), ("d", [])]
  | .aload | .aload_ptr => [("p", []), ("d", [])]
  | .astore | .astore_ptr => [("p", []), ("s", [])]
  | .armw | .armw_ptr => [("p", []), ("s", []), ("d", [])]
  | .cxchg | .cxchg_ptr => [("p", []), ("old", []), ("new", []), ("d", []), ("o", [])]
  | .fence | .compiler_fence | .abort_now => []
  | .br | .switch_dense | .switch_sparse => [("s", [])]
  | .br_cmp => [("a", []), ("b", [])]
  | .br_cmp_imm => [("a", [])]
  | .lpad => [("x", [])]

def addrsOf : Handlers.HandlerKind → List String
  | .addr => ["s"]
  | _ => []

/-- `footprintNamesOk` by the names of the handler kind. -/
def namesOk (op : Full.Opcode) (L : List (String × List String)) (A : List String) : Bool :=
  decide ((op.info.operands.map (·.name)).Nodup) &&
    L.all (fun p => namedKind op p.1 isFrameKind && p.2.all fun n => namedKind op n isImmKind) &&
    A.all fun n => namedKind op n isFrameKind

def footprintNamesOk' (op : Full.Opcode) : Bool :=
  match op.handler? with
  | none => true
  | some h => namesOk op (namesOf h.kind) (addrsOf h.kind)

end Ryo.Proofs.DeadStore
