/-
Ryo.Vm.OpSem.Sem — `opSem`: the meaning of a full opcode with a handler, per handler kind
(reduced.md Part D). The reference is `vm/rt/src/vm/interp.rs`: the body macro of each kind.

```
opSem (op : Full.Opcode) (ops : Operands) (st : State) (ch : Choice := {}) :
  Except Stop (Control × State)
```

`ops` has one `Val` per operand of `op` (`Full.Opcode.info`), the values the handler gets
from `unpack(layout op)`. It runs in three steps:

1. the frame reads of `op`'s footprint (`footprint op`) are read from `st`, at their extents;
2. the kind's semantics (`kindSem`) computes from those bytes, the operand values and the
   memory (`st` with its private frame bytes erased: it cannot read them) the control effect,
   the new memory, and a value for each frame write, by operand name;
3. `commit` writes each value at its operand's range in the footprint, checking its length.

So the frame is read and written only through the footprint (`Lemmas.lean`).

Values (§C0.3): moves, copies, loads and stores move abstract bytes (provenance fragments and
`Uninit` included); integer operations read their operands as integers (provenance dropped,
`Uninit` is UB) and write integers; pointer operands (`ptr.add`'s `p`, `memcpy`'s `dp`, a
memory operand's slot) decode as pointers (`decode_ptr`), and `ptr.add`/`ptr.index`/`addr*`
write pointers with provenance. Accesses through pointers are L0 memory accesses
(`Ryo/Spec/Mem`): unaligned except atomics and `addr.sym`'s slot reads, needing a live
allocation's provenance, or an exposed allocation for a pointer without one.

UB: reading `Uninit` as an integer or pointer; division by zero and `MIN / -1`
(`unchecked_div`/`_rem`); `memcpy` of overlapping ranges; an access through a pointer outside
a live allocation (or a store into an immutable one); `addr` of a frame offset that is neither
in nor at the end of an escaped object nor a zero-sized object (`State.addrOf`).
Shifts and rotations mask the amount (`wrapping_sh*`), so they have no UB.

Atomics are sequential (no concurrency: D17), at their natural alignment. The `.wN` forms,
like their `AtomicUN` handlers, read and write integers; the `.ptr` forms (`AtomicPtr`, which
the lowering uses for a raw pointer type) read and write pointers with their provenance. A
`.ptr` read-modify-write other than `swap` changes the address by a `usize` operand and keeps
the provenance of the pointer in memory; compare-exchange compares addresses.

Kinds not implemented: none of the handler table's; f16/f128 operations are islands.
-/
import Ryo.Vm.OpSem.Footprint
import Ryo.Vm.OpSem.Arith

namespace Ryo.Vm.OpSem

open Ryo.Spec Ryo.Vm Ryo.Vm.Handlers

/-- What a kind's semantics sees: the footprint's frame reads, the operand values, and the
state with its private frame bytes erased (memory, escaped objects, the exception). -/
structure Env where
  rd : String → M (List AbstractByte)
  val : String → Option Val
  st : State
  ch : Choice

/-- What a kind's semantics produces. -/
structure Out where
  ctl : Control := .next
  mem : Memory
  /-- Frame writes by operand name, in order. -/
  writes : List (String × List AbstractByte) := []

namespace Env

def imm (e : Env) (n : String) : M Nat :=
  match e.val n with
  | some (.imm v) => pure v
  | _ => illFormed s!"operand {n} is not an immediate"

def addr (e : Env) (n : String) : M ThinPointer :=
  match e.val n with
  | some (.addr p) => pure p
  | _ => illFormed s!"operand {n} is not an address"

def slot (e : Env) (n : String) : M Int :=
  match e.val n with
  | some (.slot o) => pure o
  | _ => illFormed s!"operand {n} is not a slot"

def int (e : Env) (n : String) : M Nat := do asNat (← e.rd n)

/-- An integer operand at width `8 × size`. -/
def bv (e : Env) (n : String) (size : Nat) : M (BitVec (8 * size)) := do
  pure (BitVec.ofNat (8 * size) (← e.int n))

def ptr (e : Env) (n : String) : M ThinPointer := do asPtr (← e.rd n)

/-- The address of the memory operand `n`: the pointer in its slot plus `k`. -/
def memPtr (e : Env) (n : String) : M ThinPointer := do
  match e.val n with
  | some (.mem _ k) => pure ((← e.ptr n).wrappingOffset k)
  | _ => illFormed s!"operand {n} is not a memory operand"

/-- An immediate as a value of the type: its low `8 × size` bits (`imm_of!`, `as $t`). -/
def immBv (e : Env) (n : String) (size : Nat) : M (BitVec (8 * size)) := do
  pure (BitVec.ofNat (8 * size) (← e.imm n))

end Env

def out (e : Env) (writes : List (String × List AbstractByte)) (ctl : Control := .next) : Out :=
  { ctl, mem := e.st.mem, writes }

def parseTy (p : Option String) : M Ty :=
  match p.bind Ty.parse with
  | some t => pure t
  | none => throw (.unsupported s!"handler type {p}")

def intTy (p : Option String) : M (Nat × Bool) := do
  match ← parseTy p with
  | .int n s => pure (n, s)
  | .float _ => throw (.unsupported s!"float type {p} where an integer is expected")

def floatTy (p : Option String) : M FloatTy := do
  match ← parseTy p with
  | .float f => pure f
  | .int .. => throw (.unsupported s!"integer type {p} where a float is expected")

def boolByte (b : Bool) : List AbstractByte := intBytes 1 (if b then 1 else 0)

/-- `switch.sparse`'s search (`sparse` in interp.rs): a linear scan up to 4 values, binary
search above (the values are sorted, unsigned); the index of `v`, or `n`. -/
def sparseIndex (vals : Array Nat) (v : Nat) : Nat :=
  let n := vals.size
  if n ≤ 4 then (vals.toList.findIdx? (· == v)).getD n
  else go n 0 n (n + 1)
where
  go (n lo hi : Nat) : Nat → Nat
    | 0 => n
    | fuel + 1 =>
      if lo < hi then
        let mid := lo + (hi - lo) / 2
        let x := vals[mid]!
        if x < v then go n (mid + 1) hi fuel
        else if x > v then go n lo mid fuel
        else mid
      else n

/-- The meaning of handler kind `k` with parameters `ps` (interp.rs's body macros). -/
def kindSem (k : HandlerKind) (ps : List String) (e : Env) : M Out := do
  let p0 := ps.head?
  let p1 := (ps.drop 1).head?
  let st := e.st
  match k with
  | .mov => pure (out e [("d", ← e.rd "s")])
  | .copy => pure (out e [("d", ← e.rd "s")])
  | .imm =>
    let (n, _) ← intTy p0
    pure (out e [("d", intBytes n (← e.imm "imm"))])
  | .konst =>
    let len ← e.imm "len"
    pure (out e [("d", ← st.load (← e.addr "k") len)])
  | .zero => pure (out e [("d", List.replicate (← e.imm "len") (.ofByte 0))])
  | .load =>
    let (n, _) ← intTy p0
    pure (out e [("d", ← st.load (← e.memPtr "m") n)])
  | .store =>
    let p ← e.memPtr "m"
    pure { mem := ← st.store st.mem p (← e.rd "s") }
  | .load_copy =>
    let len ← e.imm "len"
    pure (out e [("d", ← st.load (← e.memPtr "m") len)])
  | .store_copy =>
    let p ← e.memPtr "m"
    pure { mem := ← st.store st.mem p (← e.rd "s") }
  | .memcpy | .memmove =>
    let dp ← e.ptr "dp"
    let sp ← e.ptr "sp"
    let n ← e.int "n"
    if k == .memcpy && n > 0 && (dp.addr < sp.addr + n && sp.addr < dp.addr + n) then
      ub "memcpy of overlapping ranges"
    st.checkDeref sp n
    st.checkDeref dp n
    let bs ← st.load sp n
    pure { mem := ← st.store st.mem dp bs }
  | .memset =>
    let dp ← e.ptr "dp"
    let b ← e.int "b"
    let n ← e.int "n"
    st.checkDeref dp n
    pure { mem := ← st.store st.mem dp (List.replicate n (.ofByte (UInt8.ofNat b))) }
  | .fill =>
    let es ← e.imm "elem_size"
    let count ← e.imm "count"
    let elem ← if count == 0 then pure [] else st.load (← e.addr "k") es
    pure (out e [("d", (List.replicate count elem).flatten)])
  | .addr => pure (out e [("d", encodePtr (← st.addrOf (← e.slot "s")))])
  | .addr_sym =>
    let v ← asPtr (← st.load (← e.addr "sym") 8 Target.PTR_ALIGN)
    let v ← if p0 == some "true" then do asPtr (← st.load v 8 Target.PTR_ALIGN) else pure v
    pure (out e [("d", encodePtr v)])
  | .addr_abs => pure (out e [("d", encodePtr (← e.addr "a"))])
  | .ptr_add =>
    let p ← e.ptr "p"
    let imm ← e.imm "imm"
    pure (out e [("d", encodePtr (p.wrappingOffset (BitVec.ofNat 64 imm).toInt))])
  | .ptr_index =>
    let p ← e.ptr "p"
    let i ← e.int "i"
    let stride ← e.imm "stride"
    pure (out e [("d", encodePtr (p.wrappingOffset ((i * stride) % 2 ^ 64 : Nat)))])
  | .bin | .bin_fn | .binop | .shift =>
    let (n, s) ← intTy p0
    let some m := p1 | throw (.unsupported "integer method")
    let r ← intBin m s (← e.bv "a" n) (← e.bv "b" n)
    pure (out e [("d", intBytes n r.toNat)])
  | .bin_imm | .binop_imm | .shift_imm =>
    let (n, s) ← intTy p0
    let some m := p1 | throw (.unsupported "integer method")
    let r ← intBin m s (← e.bv "a" n) (← e.immBv "imm" n)
    pure (out e [("d", intBytes n r.toNat)])
  | .cmp =>
    let (n, s) ← intTy p0
    let some o := p1 | throw (.unsupported "comparison")
    pure (out e [("d", boolByte (← intCmp o s (← e.bv "a" n) (← e.bv "b" n)))])
  | .cmp_imm =>
    let (n, s) ← intTy p0
    let some o := p1 | throw (.unsupported "comparison")
    pure (out e [("d", boolByte (← intCmp o s (← e.bv "a" n) (← e.immBv "imm" n)))])
  | .cmp3 =>
    let (n, s) ← intTy p0
    pure (out e [("d", intBytes 1 (intCmp3 s (← e.bv "a" n) (← e.bv "b" n)).toNat)])
  | .rot =>
    let (n, _) ← intTy p0
    let some m := p1 | throw (.unsupported "rotation")
    let r ← intRot m (← e.bv "a" n) (← e.int "b")
    pure (out e [("d", intBytes n r.toNat)])
  | .count =>
    let (n, _) ← intTy p0
    let some m := p1 | throw (.unsupported "count")
    pure (out e [("d", intBytes 4 (← intCount m (← e.bv "a" n)))])
  | .un =>
    let (n, _) ← intTy p0
    let some m := p1 | throw (.unsupported "unary method")
    pure (out e [("d", intBytes n (← intUn m (← e.bv "a" n)).toNat)])
  | .ovf =>
    let (n, s) ← intTy p0
    let some m := p1 | throw (.unsupported "overflowing method")
    let (r, o) ← intOvf m s (← e.bv "a" n) (← e.bv "b" n)
    pure (out e [("d", intBytes n r.toNat), ("o", boolByte o)])
  | .fbin =>
    let f ← floatTy p0
    let some o := p1 | throw (.unsupported "float operator")
    pure (out e [("d", intBytes f.size (← floatBin e.ch o f (← e.int "a") (← e.int "b")))])
  | .fmeth =>
    let f ← floatTy p0
    let some m := p1 | throw (.unsupported "float method")
    pure (out e [("d", intBytes f.size (← floatMeth e.ch m f (← e.int "a") (← e.int "b")))])
  | .fcmp =>
    let f ← floatTy p0
    let some o := p1 | throw (.unsupported "float comparison")
    pure (out e [("d", boolByte (← floatCmp o f (← e.int "a") (← e.int "b")))])
  | .fneg =>
    let f ← floatTy p0
    pure (out e [("d", intBytes f.size (Ryo.Spec.Float.neg f (← e.int "a")))])
  | .«fun» =>
    let f ← floatTy p0
    match p1 with
    | some "abs" => pure (out e [("d", intBytes f.size (Ryo.Spec.Float.abs f (← e.int "a")))])
    | m => throw (.unsupported s!"float function {m}")
  | .cvt =>
    let x ← parseTy p0
    let y ← parseTy p1
    pure (out e [("d", intBytes y.size (← convert e.ch x y (← e.int "s")))])
  | .discr =>
    let (n, _) ← intTy p0
    let tag ← e.bv "s" n
    let rel := tag - (← e.immBv "niche_start" n)
    let vs ← e.imm "variants_start"
    let ve ← e.imm "variants_end"
    let range := (BitVec.ofNat 32 ve - BitVec.ofNat 32 vs).toNat
    let v ← if rel.toNat ≤ range then pure (BitVec.ofNat 32 vs + BitVec.ofNat 32 rel.toNat).toNat
      else e.imm "untagged"
    pure (out e [("d", intBytes 4 v)])
  | .set_discr =>
    let (n, _) ← intTy p0
    let v ← e.imm "variant"
    if v == (← e.imm "untagged") then pure (out e [("d", [])])
    else
      let rel := (BitVec.ofNat 32 v - BitVec.ofNat 32 (← e.imm "variants_start")).toNat
      let r := BitVec.ofNat (8 * n) rel + (← e.immBv "niche_start" n)
      pure (out e [("d", intBytes n r.toNat)])
  | .aload =>
    let (n, _) ← intTy p1
    let a := Align.ofBytes n
    let v ← asNat (← st.load (← e.ptr "p") n a)
    pure (out e [("d", intBytes n v)])
  | .astore =>
    let (n, _) ← intTy p1
    let s ← e.int "s"
    pure { mem := ← st.store st.mem (← e.ptr "p") (intBytes n s) (Align.ofBytes n) }
  | .armw =>
    let (n, s) ← intTy p1
    let some m := (ps.drop 2).head? | throw (.unsupported "atomic method")
    let p ← e.ptr "p"
    let a := Align.ofBytes n
    let old ← asNat (← st.load p n a)
    let x := BitVec.ofNat (8 * n) old
    let y ← e.bv "s" n
    let new ← match m with
      | "swap" => pure y
      | "fetch_add" => pure (x + y)
      | "fetch_sub" => pure (x - y)
      | "fetch_and" => pure (x &&& y)
      | "fetch_or" => pure (x ||| y)
      | "fetch_xor" => pure (x ^^^ y)
      | "fetch_nand" => pure (~~~(x &&& y))
      | "fetch_min" => pure (if BitVec.val s x ≤ BitVec.val s y then x else y)
      | "fetch_max" => pure (if BitVec.val s x ≥ BitVec.val s y then x else y)
      | _ => throw (.unsupported s!"atomic method {m}")
    let mem ← st.store st.mem p (intBytes n new.toNat) a
    pure { mem, writes := [("d", intBytes n old)] }
  | .cxchg =>
    let (n, _) ← intTy p1
    let weak := (ps.drop 2).head? == some "compare_exchange_weak"
    let p ← e.ptr "p"
    let a := Align.ofBytes n
    let expected ← e.int "old"
    let new ← e.int "new"
    let cur ← asNat (← st.load p n a)
    if e.ch.spurious && !weak then throw (.noBehavior "a strong compare-exchange failed spuriously")
    let ok := cur == expected && !e.ch.spurious
    let mem ← if ok then st.store st.mem p (intBytes n new) a else pure st.mem
    pure { mem, writes := [("d", intBytes n cur), ("o", boolByte ok)] }
  | .aload_ptr =>
    let v ← asPtr (← st.load (← e.ptr "p") 8 Target.PTR_ALIGN)
    pure (out e [("d", encodePtr v)])
  | .astore_ptr =>
    let s ← e.ptr "s"
    pure { mem := ← st.store st.mem (← e.ptr "p") (encodePtr s) Target.PTR_ALIGN }
  | .armw_ptr =>
    let some m := p0 | throw (.unsupported "atomic method")
    let p ← e.ptr "p"
    let old ← asPtr (← st.load p 8 Target.PTR_ALIGN)
    let x := BitVec.ofNat 64 old.addr
    -- `swap` stores the operand pointer; the others are on the address with a `usize`, and
    -- keep the provenance of the pointer in memory (`AtomicPtr::fetch_byte_add`, `fetch_or`).
    let new ← if m == "swap" then e.ptr "s" else do
      let y ← e.bv "s" 8
      let a ← match m with
        | "fetch_byte_add" => pure (x + y)
        | "fetch_byte_sub" => pure (x - y)
        | "fetch_and" => pure (x &&& y)
        | "fetch_or" => pure (x ||| y)
        | "fetch_xor" => pure (x ^^^ y)
        | _ => throw (.unsupported s!"atomic method {m}")
      pure { old with addr := a.toNat }
    let mem ← st.store st.mem p (encodePtr new) Target.PTR_ALIGN
    pure { mem, writes := [("d", encodePtr old)] }
  | .cxchg_ptr =>
    let weak := p0 == some "compare_exchange_weak"
    let p ← e.ptr "p"
    let expected ← e.ptr "old"
    let new ← e.ptr "new"
    let cur ← asPtr (← st.load p 8 Target.PTR_ALIGN)
    if e.ch.spurious && !weak then throw (.noBehavior "a strong compare-exchange failed spuriously")
    -- Pointers compare by address, as the machine's `cmpxchg` does.
    let ok := cur.addr == expected.addr && !e.ch.spurious
    let mem ← if ok then st.store st.mem p (encodePtr new) Target.PTR_ALIGN else pure st.mem
    pure { mem, writes := [("d", encodePtr cur), ("o", boolByte ok)] }
  | .fence | .compiler_fence => pure (out e [])
  | .br => pure (out e [] (.branch ((← e.int "s") != 0)))
  | .br_cmp =>
    let (n, s) ← intTy p0
    let some o := p1 | throw (.unsupported "comparison")
    pure (out e [] (.branch (← intCmp o s (← e.bv "a" n) (← e.bv "b" n))))
  | .br_cmp_imm =>
    let (n, s) ← intTy p0
    let some o := p1 | throw (.unsupported "comparison")
    pure (out e [] (.branch (← intCmp o s (← e.bv "a" n) (← e.immBv "imm" n))))
  | .switch_dense =>
    let (n, _) ← intTy p0
    let i := ((← e.bv "s" n) - (← e.immBv "base" n)).toNat
    let some (.targets len) := e.val "table" | illFormed "operand table is not a jump table"
    pure (out e [] (.index (if i < len then i else len)))
  | .switch_sparse =>
    let (n, _) ← intTy p0
    let some (.cases p cnt) := e.val "cases" | illFormed "operand cases is not a case list"
    let v ← e.int "s"
    let bs ← st.load p (cnt * n)
    let vals ← (List.range cnt).mapM fun i => asNat ((bs.drop (i * n)).take n)
    pure (out e [] (.index (sparseIndex vals.toArray v)))
  | .trap => throw .unreachable
  | .abort_now => throw .abort
  | .lpad => pure (out e [("x", encodePtr st.exception)])

/-- Write one of a kind's values at its operand's range in the footprint, checking its
length. -/
def commitOne (fp : Footprint) (val : String → Option Val) (st : State)
    (w : String × List AbstractByte) : M State :=
  match fp.writes.find? (·.opnd == w.1) with
  | none => illFormed s!"internal: write of {w.1} outside the footprint"
  | some a =>
    match a.range val with
    | none => illFormed s!"operand {w.1}'s range"
    | some (off, n) =>
      if w.2.length = n then st.writeFrame off w.2
      else illFormed s!"internal: {w.1} written with {w.2.length} bytes, not {n}"

/-- Write each of a kind's values, in order. -/
def commit (fp : Footprint) (val : String → Option Val) (st : State)
    (writes : List (String × List AbstractByte)) : M State :=
  writes.foldlM (commitOne fp val) st

/-- The frame bytes of each footprint read. -/
def readAll (fp : Footprint) (val : String → Option Val) (st : State) :
    M (List (String × List AbstractByte)) :=
  fp.reads.mapM fun a => do
    let some (off, n) := a.range val | illFormed s!"operand {a.opnd}'s range"
    pure (a.opnd, ← st.readFrame off n)

/-- The handler, footprint and operand values of `op` on `ops`, checking the operands. -/
def prepare (op : Full.Opcode) (ops : Operands) :
    M (HandlerInfo × Footprint × (String → Option Val)) := do
  let some h := op.handler? | throw (.unsupported s!"{op.mnemonic} has no handler kind")
  let some fp := footprint op | throw (.unsupported s!"{op.mnemonic}'s footprint")
  let info := op.info
  if ops.length != info.operands.length then
    illFormed s!"{op.mnemonic} takes {info.operands.length} operands, not {ops.length}"
  if !(info.operands.zip ops).all (fun (i, v) => v.fits i.kind) then
    illFormed s!"{op.mnemonic}: an operand doesn't fit its kind"
  pure (h, fp, opndVal info ops)

/-- The kind's view: the frame reads by name, and the state without its private bytes. -/
def mkEnv (reads : List (String × List AbstractByte)) (val : String → Option Val) (st : State)
    (ch : Choice) : Env :=
  { rd := fun n => match reads.find? (·.1 == n) with
      | some r => pure r.2
      | none => illFormed s!"internal: read of {n} outside the footprint",
    val, st := { st with frame := fun _ => .uninit }, ch }

/-- `opSem op ops st ch`: the operation of `op` (a full opcode with a handler) on operands
`ops` in state `st`, with the choices `ch`: the control effect and the next state. -/
def opSem (op : Full.Opcode) (ops : Operands) (st : State) (ch : Choice := {}) :
    M (Control × State) := do
  let (h, fp, val) ← prepare op ops
  let reads ← readAll fp val st
  let o ← kindSem h.kind h.params (mkEnv reads val st ch)
  let st' ← commit fp val { st with mem := o.mem } o.writes
  pure (o.ctl, st')

end Ryo.Vm.OpSem
