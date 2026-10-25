/-
Tests of `opSem` and the footprints (`Ryo/Vm/OpSem`): the footprint is defined for every
opcode with a handler and names operands of the right kinds, each kind's semantics writes
exactly its footprint's writes, and unit tests per kind, with UB cases and edge values.
-/
import RyoTest.Harness

namespace RyoTest.OpSem

open Ryo.Vm Ryo.Vm.OpSem
open Ryo.Spec (AbstractByte Allocation Align AllocId encodePtr ThinPointer)

def forAll {α} [ToString α] (ops : List α) (p : α → Bool) (msg : String) : Except String Unit :=
  match ops.find? (fun op => !p op) with
  | none => .ok ()
  | some op => .error s!"{msg}: {op}"

/-! ### Footprints -/

def withHandler : List Full.Opcode := Full.all.filter (·.handler?.isSome)

def footprintTotal : Except String Unit := do
  check (withHandler.length > 600) "handler table size"
  forAll withHandler (fun op => (footprint op).isSome) "no footprint"
  -- Without a Rust handler there is no footprint (calls, `ret`, `arg`, `jmp`, `island`,
  -- `resume`).
  forAll Full.all (fun op => (footprint op).isSome == op.handler?.isSome) "footprint without handler"

/-- The operand kinds a name in a footprint must have. -/
def kindOf (op : Full.Opcode) (n : String) : Option OperandKind :=
  (op.info.operands.find? (·.name == n)).map (·.kind)

def isImm : Option OperandKind → Bool
  | some .u8 | some .u16 | some .u32 | some .u64 | some .i64 | some .u128 => true
  | _ => false

def isFrame : Option OperandKind → Bool
  | some .slot | some .mem => true
  | _ => false

def isAddr : Option OperandKind → Bool
  | some .const | some .abs | some .sym | some .site => true
  | some (.list .case8) | some (.list .case16) | some (.list .case32) | some (.list .case64)
  | some (.list .case128) => true
  | _ => false

def extentOk (op : Full.Opcode) (mem : Bool) : Extent → Bool
  | .bytes n => n > 0
  | .opnd a => isImm (kindOf op a)
  | .mul a b => isImm (kindOf op a) && isImm (kindOf op b)
  | .unlessEq _ a b => isImm (kindOf op a) && isImm (kindOf op b)
  | .slotVal a => mem && kindOf op a == some .slot
  | .cases c _ => mem && isAddr (kindOf op c)

def footprintOk (op : Full.Opcode) : Bool :=
  match footprint op with
  | none => false
  | some fp =>
    let acc (a : Access) := isFrame (kindOf op a.opnd) && extentOk op false a.extent &&
      (kindOf op a.opnd != some .mem || a.extent == .bytes 8)
    let src : PtrSrc → Bool
      | .slot n => kindOf op n == some .slot
      | .mem n => kindOf op n == some .mem
      | .addr n | .loaded n => isAddr (kindOf op n)
    let flowOk := match op.info.shape, fp.flow with
      | .op, .next | .lpad, .next | .br, .branch | .switch, .table | .trap, .trap => true
      | _, _ => false
    fp.reads.all acc && fp.writes.all (fun a => acc a && kindOf op a.opnd == some .slot) &&
      fp.addrs.all (kindOf op · == some .slot) &&
      fp.derefs.all (fun d => src d.src && extentOk op true d.extent) && flowOk &&
      -- every slot operand is accessed, address-taken or a pointer source
      op.info.operands.all fun o =>
        o.kind != .slot || fp.reads.any (·.opnd == o.name) || fp.writes.any (·.opnd == o.name) ||
          fp.addrs.contains o.name

def footprintNames : Except String Unit :=
  forAll withHandler footprintOk "footprint doesn't fit the operands"

def footprintKnown : Except String Unit := do
  let fp (m : String) := (Full.Opcode.ofMnemonic? m).bind footprint
  check (fp "add.w32" == some { reads := [⟨"a", .bytes 4⟩, ⟨"b", .bytes 4⟩], writes := [⟨"d", .bytes 4⟩] })
    "add.w32"
  check ((fp "ctlz.w8").map (·.writes) == some [⟨"d", .bytes 4⟩]) "ctlz.w8 writes a u32"
  check ((fp "rotl.w64").map (·.reads) == some [⟨"a", .bytes 8⟩, ⟨"b", .bytes 4⟩]) "rotl's u32 amount"
  check ((fp "shl.w128").map (·.reads) == some [⟨"a", .bytes 16⟩, ⟨"b", .bytes 16⟩]) "shl.w128's amount"
  check ((fp "add.ovf.s.w16").map (·.writes) == some [⟨"d", .bytes 2⟩, ⟨"o", .bytes 1⟩]) "ovf"
  check ((fp "cvt.i2f.u.w16.f64").map (·.reads) == some [⟨"s", .bytes 2⟩]) "cvt reads"
  check ((fp "cvt.i2f.u.w16.f64").map (·.writes) == some [⟨"d", .bytes 8⟩]) "cvt writes"
  check ((fp "memcpy").map (·.derefs.length) == some 2) "memcpy derefs"
  check ((fp "br.lt.u.imm.w8").map (·.flow) == some .branch) "br flow"
  check ((fp "abort").map (·.flow) == some .trap) "trap flow"
  check (fp "unreachable" == none) "unreachable is a bare ud2, without a footprint"
  check ((fp "addr").map (·.addrs) == some ["s"]) "addr takes s's address"

/-! ### States and runs -/

def frameOf (runs : List (Int × List AbstractByte)) (o : Int) : AbstractByte :=
  match runs.find? fun (b, bs) => decide (b ≤ o ∧ o < b + bs.length) with
  | some (b, bs) => bs.getD (o - b).toNat .uninit
  | none => .uninit

def bytes (bs : List Nat) : List AbstractByte := bs.map fun b => .ofByte (UInt8.ofNat b)

def le (n v : Nat) : List AbstractByte := intBytes n v

def mkAlloc (addr : Nat) (data : List AbstractByte) (mutable := true) : Allocation :=
  { data := data.toArray, addr, align := Align.one, kind := .heap, mutable,
    vtableRo := by intro h; cases h }

def stOf (runs : List (Int × List AbstractByte)) (allocs : List Allocation := [])
    (escaped : List EscapedObj := []) (exposed : List AllocId := []) : State :=
  { frame := frameOf runs, mem := { allocs := allocs.toArray }, escaped, exposed }

def opOf (m : String) : Except String Full.Opcode :=
  match Full.Opcode.ofMnemonic? m with
  | some op => .ok op
  | none => .error s!"no opcode {m}"

def run (m : String) (ops : Operands) (st : State) (ch : Choice := {}) :
    Except String (M (Control × State)) := do
  pure (opSem (← opOf m) ops st ch)

def S (o : Int) : Val := .slot o
def I (v : Nat) : Val := .imm v

def showBytes (bs : List AbstractByte) : String := toString (repr bs)

/-- `m` succeeds, with `n` bytes at `off` equal to `expect`. -/
def expectBytes (m : String) (ops : Operands) (st : State) (off : Int) (expect : List AbstractByte)
    (ch : Choice := {}) (ctl : Control := .next) : Except String Unit := do
  match ← run m ops st ch with
  | .ok (c, st') =>
    check (c == ctl) s!"{m}: control {repr c}, expected {repr ctl}"
    match st'.readFrame off expect.length with
    | .ok bs => check (bs == expect) s!"{m}: got {showBytes bs}, expected {showBytes expect}"
    | .error e => .error s!"{m}: reading the result: {e}"
  | .error e => .error s!"{m}: {e}"

def expectInt (m : String) (ops : Operands) (st : State) (off : Int) (n v : Nat)
    (ch : Choice := {}) : Except String Unit :=
  expectBytes m ops st off (le n v) ch

def expectControl (m : String) (ops : Operands) (st : State) (ctl : Control) :
    Except String Unit := do
  match ← run m ops st with
  | .ok (c, _) => check (c == ctl) s!"{m}: control {repr c}, expected {repr ctl}"
  | .error e => .error s!"{m}: {e}"

def expectStop (m : String) (ops : Operands) (st : State) (p : Stop → Bool) (what : String)
    (ch : Choice := {}) : Except String Unit := do
  match ← run m ops st ch with
  | .ok _ => .error s!"{m}: expected {what}, succeeded"
  | .error e => check (p e) s!"{m}: expected {what}, got {e}"

def isUb : Stop → Bool
  | .ub _ => true
  | _ => false

def expectUb (m : String) (ops : Operands) (st : State) (ch : Choice := {}) : Except String Unit :=
  expectStop m ops st isUb "UB" ch

/-- Three 16-byte slots at -16 (`d`), -32 (`a`), -48 (`b`) holding `a` and `b` at width `n`. -/
def ab (n a b : Nat) : State := stOf [(-32, le n a), (-48, le n b)]

def bin3 (m : String) (n a b r : Nat) : Except String Unit :=
  expectInt m [S (-16), S (-32), S (-48)] (ab n a b) (-16) n r

def m8 (i : Int) : Nat := (BitVec.ofInt 8 i).toNat
def m32 (i : Int) : Nat := (BitVec.ofInt 32 i).toNat

/-! ### Data movement -/

def prov (id : AllocId) (addr : Nat) : List AbstractByte := encodePtr ⟨addr, some id⟩

def movement : Except String Unit := do
  -- `mov` keeps provenance and `Uninit`.
  let p := prov 3 0x1000
  expectBytes "mov.w64" [S (-8), S (-16)] (stOf [(-16, p)]) (-8) p
  expectBytes "mov.w32" [S (-8), S (-16)] (stOf [(-16, [.uninit, .ofByte 1, .uninit, .ofByte 2])])
    (-8) [.uninit, .ofByte 1, .uninit, .ofByte 2]
  -- `copy` is a `memmove`.
  expectBytes "copy" [S (-6), S (-8), I 4] (stOf [(-8, bytes [1, 2, 3, 4])]) (-6) (bytes [1, 2, 3, 4])
  expectInt "imm.w16" [S (-8), I 0xbeef] (stOf []) (-8) 2 0xbeef
  expectInt "imm.w128" [S (-16), I (2 ^ 127 + 5)] (stOf []) (-16) 16 (2 ^ 127 + 5)
  expectBytes "zero" [S (-8), I 3] (stOf [(-8, bytes [9, 9, 9, 9])]) (-8) (bytes [0, 0, 0, 9])
  -- Through memory: a pointer with provenance into allocation 0 at 0x1000.
  let mem := [mkAlloc 0x1000 (bytes [1, 2, 3, 4, 5, 6, 7, 8])]
  let st := stOf [(-16, prov 0 0x1000)] mem
  expectInt "load.w32" [S (-8), .mem (-16) 2] st (-8) 4 0x06050403
  expectUb "load.w32" [S (-8), .mem (-16) 6] st
  -- A pointer without provenance: the exposed allocation containing the range, else UB.
  let raw := stOf [(-16, le 8 0x1000)] mem
  expectUb "load.w8" [S (-8), .mem (-16) 0] raw
  expectInt "load.w8" [S (-8), .mem (-16) 7] { raw with exposed := [0] } (-8) 1 8
  -- An uninitialized pointer is UB.
  expectUb "load.w8" [S (-8), .mem (-16) 0] (stOf [] mem)
  -- `store` into an immutable allocation is UB.
  expectUb "store.w8" [.mem (-16) 0, S (-8)]
    (stOf [(-16, prov 0 0x1000), (-8, bytes [1])] [mkAlloc 0x1000 (bytes [0]) false])
  match ← run "store.w16" [.mem (-16) 1, S (-8)] (stOf [(-16, prov 0 0x1000), (-8, bytes [0xaa, 0xbb])] mem) with
  | .ok (_, st') =>
    check (st'.mem.allocs[0]!.data.toList.take 4 == bytes [1, 0xaa, 0xbb, 4]) "store.w16's bytes"
  | .error e => .error s!"store.w16: {e}"
  expectBytes "load.copy" [S (-8), .mem (-16) 4, I 4] st (-8) (bytes [5, 6, 7, 8])
  expectBytes "const" [S (-8), .addr ⟨0x1001, some 0⟩, I 3] st (-8) (bytes [2, 3, 4])
  expectBytes "fill" [S (-24), .addr ⟨0x1000, some 0⟩, I 2, I 3] st (-24) (bytes [1, 2, 1, 2, 1, 2])
  -- memcpy/memmove/memset take pointers and the length in slots.
  let mst := stOf [(-8, prov 0 0x1000), (-16, prov 0 0x1002), (-24, le 8 4)] mem
  expectUb "memcpy" [S (-8), S (-16), S (-24)] mst
  match ← run "memmove" [S (-8), S (-16), S (-24)] mst with
  | .ok (_, st') => check (st'.mem.allocs[0]!.data.toList == bytes [3, 4, 5, 6, 5, 6, 7, 8]) "memmove"
  | .error e => .error s!"memmove: {e}"
  match ← run "memset" [S (-8), S (-32), S (-24)] { mst with frame := frameOf [(-8, prov 0 0x1000), (-32, bytes [7]), (-24, le 8 4)] } with
  | .ok (_, st') => check (st'.mem.allocs[0]!.data.toList == bytes [7, 7, 7, 7, 5, 6, 7, 8]) "memset"
  | .error e => .error s!"memset: {e}"
  -- A length of 0 dereferences nothing.
  expectControl "memcpy" [S (-8), S (-16), S (-24)] (stOf [(-8, le 8 0), (-16, le 8 0), (-24, le 8 0)]) .next

/-! ### Addresses and frame objects -/

def addresses : Except String Unit := do
  -- `addr` of a private object is UB; of an escaped one, a pointer with its provenance.
  expectUb "addr" [S (-8), S (-32)] (stOf [])
  let esc := stOf [] [mkAlloc 0x5000 (bytes [0, 0, 0, 0, 0, 0, 0, 0])] [⟨-32, 8, 0⟩]
  expectBytes "addr" [S (-8), S (-28)] esc (-8) (prov 0 0x5004)
  -- At the object's end: the allocation's end, with its provenance; past it, UB.
  expectBytes "addr" [S (-8), S (-24)] esc (-8) (prov 0 0x5008)
  expectUb "addr" [S (-8), S (-20)] esc
  -- A zero-sized object: its address, without provenance.
  expectBytes "addr" [S (-8), S (-40)] { esc with zeroSized := [(-40, 0x7000)] } (-8) (le 8 0x7000)
  expectUb "addr" [S (-8), S (-40)] esc
  -- A frame write into an escaped object writes its allocation, and is seen through it.
  match ← run "imm.w8" [S (-30), I 0x77] esc with
  | .ok (_, st') =>
    check (st'.mem.allocs[0]!.data[2]! == .ofByte 0x77) "escaped frame write"
    check (st'.frame (-30) == .uninit) "escaped bytes aren't private"
  | .error e => .error s!"imm.w8: {e}"
  let p := prov 3 0x1000
  expectBytes "addr.const" [S (-8), .addr ⟨0x1000, some 3⟩] (stOf []) (-8) p
  -- `addr.sym` reads the symbol slot; `.ind` once more through it.
  let syms := [mkAlloc 0x2000 (prov 1 0x3000), mkAlloc 0x3000 (prov 2 0x4000), mkAlloc 0x4000 []]
  expectBytes "addr.sym" [S (-8), .addr ⟨0x2000, some 0⟩] (stOf [] syms) (-8) (prov 1 0x3000)
  expectBytes "addr.sym.ind" [S (-8), .addr ⟨0x2000, some 0⟩] (stOf [] syms) (-8) (prov 2 0x4000)
  -- `ptr.add`/`ptr.index` keep provenance and wrap.
  expectBytes "ptr.add" [S (-8), S (-16), I (2 ^ 64 - 8)] (stOf [(-16, p)]) (-8) (prov 3 0xff8)
  expectBytes "ptr.index" [S (-8), S (-16), S (-24), I 12] (stOf [(-16, p), (-24, le 8 3)]) (-8)
    (prov 3 (0x1000 + 36))
  -- `ptr.index`'s index is an integer: its provenance is dropped, `Uninit` is UB.
  expectBytes "ptr.index" [S (-8), S (-16), S (-24), I 1] (stOf [(-16, p), (-24, prov 5 2)]) (-8)
    (prov 3 0x1002)
  expectUb "ptr.index" [S (-8), S (-16), S (-24), I 1] (stOf [(-16, p)])
  expectBytes "lpad" [S (-8)] { stOf [] with exception := ⟨0x1234, some 9⟩ } (-8) (prov 9 0x1234)

/-! ### Integer arithmetic -/

def integers : Except String Unit := do
  bin3 "add.w8" 1 200 100 44
  bin3 "sub.w32" 4 0 1 0xffffffff
  bin3 "mul.w64" 8 (2 ^ 63 + 3) 2 6
  bin3 "add.w128" 16 (2 ^ 128 - 1) 2 1
  bin3 "div.s.w32" 4 (m32 (-7)) 2 (m32 (-3))
  bin3 "rem.s.w32" 4 (m32 (-7)) 2 (m32 (-1))
  bin3 "rem.s.w32" 4 7 (m32 (-2)) 1
  bin3 "div.u.w32" 4 (m32 (-7)) 2 0x7ffffffc
  bin3 "div.s.w8" 1 (m8 (-128)) 1 (m8 (-128))
  expectUb "div.u.w64" [S (-16), S (-32), S (-48)] (ab 8 5 0)
  expectUb "rem.u.w16" [S (-16), S (-32), S (-48)] (ab 2 5 0)
  expectUb "div.s.w8" [S (-16), S (-32), S (-48)] (ab 1 (m8 (-128)) (m8 (-1)))
  expectUb "rem.s.w64" [S (-16), S (-32), S (-48)] (ab 8 (2 ^ 63) (2 ^ 64 - 1))
  bin3 "div.s.w8" 1 (m8 (-127)) (m8 (-1)) 127
  bin3 "and.w16" 2 0xff0f 0x0ff0 0x0f00
  bin3 "xor.w8" 1 0xff 0x0f 0xf0
  -- Shift amounts are masked to the width.
  bin3 "shl.w8" 1 1 9 2
  bin3 "shl.w32" 4 1 31 0x80000000
  bin3 "shl.w32" 4 1 32 1
  bin3 "shr.s.w8" 1 0x80 7 0xff
  bin3 "shr.s.w8" 1 0x80 (m8 (-1)) 0xff
  bin3 "shr.u.w8" 1 0x80 8 0x80
  bin3 "shr.u.w128" 16 (2 ^ 127) 127 1
  bin3 "shr.s.w128" 16 (2 ^ 127) 128 (2 ^ 127)
  -- `rot` takes a `u32` amount.
  expectInt "rotl.w8" [S (-16), S (-32), S (-48)] (stOf [(-32, le 1 0x81), (-48, le 4 9)]) (-16) 1 0x03
  expectInt "rotr.w64" [S (-16), S (-32), S (-48)] (stOf [(-32, le 8 1), (-48, le 4 65)]) (-16) 8 (2 ^ 63)
  -- Compares write a `bool`.
  let cmp (m : String) (n a b r : Nat) :=
    expectInt m [S (-16), S (-32), S (-48)] (ab n a b) (-16) 1 r
  cmp "eq.w32" 4 5 5 1
  cmp "ne.w32" 4 5 5 0
  cmp "lt.s.w8" 1 (m8 (-1)) 0 1
  cmp "lt.u.w8" 1 (m8 (-1)) 0 0
  cmp "le.s.w64" 8 (2 ^ 63) (2 ^ 63) 1
  cmp "cmp3.s.w16" 2 (2 ^ 16 - 1) 1 0xff
  cmp "cmp3.u.w16" 2 (2 ^ 16 - 1) 1 1
  cmp "cmp3.u.w16" 2 7 7 0
  let imm2 (m : String) (n a imm r : Nat) :=
    expectInt m [S (-16), S (-32), I imm] (stOf [(-32, le n a)]) (-16) n r
  imm2 "add.imm.w8" 1 250 10 4
  imm2 "shl.imm.w16" 2 1 17 2
  imm2 "shr.s.imm.w32" 4 0x80000000 31 0xffffffff
  let cimm (m : String) (n a imm r : Nat) :=
    expectInt m [S (-16), S (-32), I imm] (stOf [(-32, le n a)]) (-16) 1 r
  cimm "gt.s.imm.w8" 1 1 (m8 (-1)) 1
  cimm "gt.u.imm.w8" 1 1 (m8 (-1)) 0
  cimm "ge.u.imm.w128" 16 5 5 1
  -- Unary operations; counts write a `u32`.
  let un (m : String) (n a : Nat) (rn r : Nat) :=
    expectInt m [S (-16), S (-32)] (stOf [(-32, le n a), (-16, bytes [9, 9, 9, 9])]) (-16) rn r
  un "neg.w8" 1 1 1 0xff
  un "neg.w8" 1 0x80 1 0x80
  un "not.w16" 2 0 2 0xffff
  un "ctpop.w64" 8 (2 ^ 64 - 1) 4 64
  un "ctlz.w8" 1 0 4 8
  un "ctlz.w32" 4 1 4 31
  un "cttz.w128" 16 0 4 128
  un "cttz.w16" 2 0x100 4 8
  un "bswap.w32" 4 0x11223344 4 0x44332211
  un "bitreverse.w8" 1 0x01 1 0x80
  un "bitreverse.w16" 2 0x0003 2 0xc000
  -- Integer operands: `Uninit` is UB; provenance is dropped.
  expectUb "add.w32" [S (-16), S (-32), S (-48)] (stOf [(-32, le 4 1)])
  expectBytes "add.w64" [S (-16), S (-32), S (-48)] (stOf [(-32, prov 1 0x1000), (-48, le 8 8)])
    (-16) (le 8 0x1008)

def overflow : Except String Unit := do
  let ovf (m : String) (n a b r o : Nat) : Except String Unit := do
    let st := stOf [(-32, le n a), (-48, le n b)]
    expectInt m [S (-16), S (-64), S (-32), S (-48)] st (-16) n r
    expectInt m [S (-16), S (-64), S (-32), S (-48)] st (-64) 1 o
  ovf "add.ovf.s.w8" 1 127 1 0x80 1
  ovf "add.ovf.u.w8" 1 255 1 0 1
  ovf "add.ovf.u.w8" 1 254 1 255 0
  ovf "sub.ovf.s.w32" 4 0x80000000 1 0x7fffffff 1
  ovf "sub.ovf.u.w16" 2 0 1 0xffff 1
  ovf "mul.ovf.s.w32" 4 0x10000 0x8000 0x80000000 1
  ovf "mul.ovf.s.w32" 4 (m32 (-0x10000)) 0x8000 0x80000000 0
  ovf "mul.ovf.u.w64" 8 (2 ^ 32) (2 ^ 32) 0 1
  ovf "add.ovf.s.w128" 16 (2 ^ 127 - 1) 1 (2 ^ 127) 1

def conversions : Except String Unit := do
  let cvt (m : String) (nx v ny r : Nat) :=
    expectInt m [S (-16), S (-32)] (stOf [(-32, le nx v)]) (-16) ny r
  cvt "zext.w8.w32" 1 0x80 4 0x80
  cvt "sext.w8.w32" 1 0x80 4 0xffffff80
  cvt "sext.w16.w128" 2 0xffff 16 (2 ^ 128 - 1)
  cvt "trunc.w64.w8" 8 0x1234 1 0x34
  cvt "trunc.w128.w64" 16 (2 ^ 64 + 5) 8 5

def enums : Except String Unit := do
  -- `Option<bool>`: tag values 0/1 are `Some` (untagged, variant 1), 2 is `None` (variant 0).
  let discr (tag v : Nat) :=
    expectInt "discr.niche.w8" [S (-16), S (-32), I 2, I 0, I 0, I 1] (stOf [(-32, le 1 tag)]) (-16) 4 v
  discr 2 0
  discr 0 1
  discr 1 1
  discr 255 1
  -- A niche range wrapping at the tag width: niche start 254, variants 3..5.
  let discr2 (tag v : Nat) :=
    expectInt "discr.niche.w8" [S (-16), S (-32), I 254, I 3, I 5, I 0] (stOf [(-32, le 1 tag)]) (-16) 4 v
  discr2 254 3
  discr2 255 4
  discr2 0 5
  discr2 1 0
  expectInt "set_discr.niche.w8" [S (-16), I 0, I 2, I 0, I 1] (stOf []) (-16) 1 2
  -- The untagged variant writes nothing.
  expectBytes "set_discr.niche.w8" [S (-16), I 1, I 2, I 0, I 1] (stOf [(-16, bytes [9])]) (-16) (bytes [9])
  expectInt "set_discr.niche.w128" [S (-16), I 4, I (2 ^ 128 - 1), I 3, I 0] (stOf []) (-16) 16 0
  expectUb "discr.niche.w8" [S (-16), S (-32), I 2, I 0, I 0, I 1] (stOf [])

def control : Except String Unit := do
  expectControl "br" [S (-8), .none, .none] (stOf [(-8, bytes [2])]) (.branch true)
  expectControl "br" [S (-8), .none, .none] (stOf [(-8, bytes [0])]) (.branch false)
  expectUb "br" [S (-8), .none, .none] (stOf [])
  expectControl "br.lt.s.w32" [S (-8), S (-16), .none, .none] (stOf [(-8, le 4 (m32 (-1))), (-16, le 4 0)])
    (.branch true)
  expectControl "br.lt.u.imm.w8" [S (-8), I 3, .none, .none] (stOf [(-8, le 1 3)]) (.branch false)
  expectControl "br.gt.s.imm.w128" [S (-8), I (2 ^ 128 - 1), .none, .none] (stOf [(-8, le 16 0)])
    (.branch true)
  let dense (s : Nat) (i : Nat) :=
    expectControl "switch.dense.w8" [S (-8), I 3, .none, .targets 4] (stOf [(-8, le 1 s)]) (.index i)
  dense 5 2
  dense 3 0
  dense 7 4
  dense 2 4
  -- Sparse: the values in memory, sorted; a binary search above 4.
  let vals := [1, 5, 9, 200, 300, 1000]
  let tbl := mkAlloc 0x6000 (vals.flatMap (le 2 ·))
  let sparse (s i : Nat) (n := vals.length) :=
    expectControl "switch.sparse.w16" [S (-8), .none, .cases ⟨0x6000, some 0⟩ n]
      (stOf [(-8, le 2 s)] [tbl]) (.index i)
  sparse 1 0
  sparse 300 4
  sparse 1000 5
  sparse 6 6
  sparse 9 2 (n := 3)
  sparse 200 3 (n := 3)
  expectStop "abort" [] (stOf []) (· == .abort) "abort"
  expectControl "fence.seqcst" [] (stOf []) .next

def atomics : Except String Unit := do
  let mem := [mkAlloc 0x1000 (le 8 10)]
  let st (s : Nat) := stOf [(-8, prov 0 0x1000), (-16, le 8 s)] mem
  let after (m : String) (s : Nat) (old new : Nat) : Except String Unit := do
    match ← run m [S (-24), S (-8), S (-16)] (st s) with
    | .ok (_, st') =>
      check (st'.mem.allocs[0]!.data.toList == le 8 new) s!"{m}: memory"
      check ((st'.readFrame (-24) 8).toOption == some (le 8 old)) s!"{m}: old value"
    | .error e => .error s!"{m}: {e}"
  after "atomic.xchg.w64.seqcst" 3 10 3
  after "atomic.add.w64.relaxed" 3 10 13
  after "atomic.sub.w64.acqrel" 11 10 (2 ^ 64 - 1)
  after "atomic.nand.w64.seqcst" 6 10 (2 ^ 64 - 1 - 2)
  after "atomic.min.w64.seqcst" (2 ^ 64 - 1) 10 (2 ^ 64 - 1)
  after "atomic.umin.w64.seqcst" (2 ^ 64 - 1) 10 10
  expectInt "atomic.load.w32.acquire" [S (-24), S (-8)] (st 0) (-24) 4 10
  -- Misaligned atomics are UB.
  expectUb "atomic.load.w32.acquire" [S (-24), S (-8)] (stOf [(-8, prov 0 0x1002)] mem)
  -- Compare-exchange: `d` the old value, `o` success.
  let cx (m : String) (expected : Nat) (ok : Nat) (ch : Choice := {}) : Except String Unit := do
    let s := stOf [(-8, prov 0 0x1000), (-16, le 4 expected), (-40, le 4 99)] mem
    match ← run m [S (-24), S (-32), S (-8), S (-16), S (-40)] s ch with
    | .ok (_, st') =>
      check ((st'.readFrame (-24) 4).toOption == some (le 4 10)) s!"{m}: old value"
      check ((st'.readFrame (-32) 1).toOption == some (le 1 ok)) s!"{m}: flag"
      check ((st'.mem.allocs[0]!.data.toList.take 4) == le 4 (if ok == 1 then 99 else 10)) s!"{m}: memory"
    | .error e => .error s!"{m}: {e}"
  cx "atomic.cxchg.w32.seqcst.seqcst" 10 1
  cx "atomic.cxchg.w32.seqcst.seqcst" 11 0
  cx "atomic.cxchg.weak.w32.acqrel.acquire" 10 0 { spurious := true }
  expectStop "atomic.cxchg.w32.seqcst.seqcst" [S (-24), S (-32), S (-8), S (-16), S (-40)]
    (stOf [(-8, prov 0 0x1000), (-16, le 4 10), (-40, le 4 99)] mem)
    (fun | .noBehavior _ => true | _ => false) "no behavior" { spurious := true }
  -- Atomics read and write integers: a stored pointer's provenance is dropped.
  match ← run "atomic.load.w64.seqcst" [S (-24), S (-8)] (stOf [(-8, prov 0 0x1000)] [mkAlloc 0x1000 (prov 1 0x2000)]) with
  | .ok (_, st') => check ((st'.readFrame (-24) 8).toOption == some (le 8 0x2000)) "atomic.load drops provenance"
  | .error e => .error s!"atomic.load.w64.seqcst: {e}"
  -- The `.ptr` forms read and write pointers: provenance is kept.
  let pm := [mkAlloc 0x1000 (prov 1 0x2000)]
  let q := prov 2 0x3000
  expectBytes "atomic.load.ptr.acquire" [S (-24), S (-8)] (stOf [(-8, prov 0 0x1000)] pm) (-24) (prov 1 0x2000)
  let ptrAfter (m : String) (s : List AbstractByte) (new : List AbstractByte) : Except String Unit := do
    match ← run m [S (-24), S (-8), S (-16)] (stOf [(-8, prov 0 0x1000), (-16, s)] pm) with
    | .ok (_, st') =>
      check (st'.mem.allocs[0]!.data.toList == new) s!"{m}: memory"
      check ((st'.readFrame (-24) 8).toOption == some (prov 1 0x2000)) s!"{m}: old value"
    | .error e => .error s!"{m}: {e}"
  ptrAfter "atomic.xchg.ptr.seqcst" q q
  -- The others change the address by an integer, keeping the provenance in memory.
  ptrAfter "atomic.add.ptr.relaxed" (prov 2 8) (prov 1 0x2008)
  ptrAfter "atomic.sub.ptr.release" (le 8 0x10) (prov 1 0x1ff0)
  ptrAfter "atomic.or.ptr.seqcst" (le 8 1) (prov 1 0x2001)
  ptrAfter "atomic.and.ptr.acqrel" (le 8 (2 ^ 64 - 0x1000)) (prov 1 0x2000)
  ptrAfter "atomic.xor.ptr.acquire" (le 8 0x2000) (prov 1 0)
  match ← run "atomic.store.ptr.release" [S (-8), S (-16)] (stOf [(-8, prov 0 0x1000), (-16, q)] pm) with
  | .ok (_, st') => check (st'.mem.allocs[0]!.data.toList == q) "atomic.store.ptr keeps provenance"
  | .error e => .error s!"atomic.store.ptr.release: {e}"
  -- Compare-exchange compares addresses: an expected value without provenance matches.
  let pcx (m : String) (expected : Nat) (ok : Nat) : Except String Unit := do
    let s := stOf [(-8, prov 0 0x1000), (-16, le 8 expected), (-40, q)] pm
    match ← run m [S (-24), S (-32), S (-8), S (-16), S (-40)] s with
    | .ok (_, st') =>
      check ((st'.readFrame (-24) 8).toOption == some (prov 1 0x2000)) s!"{m}: old value"
      check ((st'.readFrame (-32) 1).toOption == some (le 1 ok)) s!"{m}: flag"
      check (st'.mem.allocs[0]!.data.toList == if ok == 1 then q else prov 1 0x2000) s!"{m}: memory"
    | .error e => .error s!"{m}: {e}"
  pcx "atomic.cxchg.ptr.acqrel.acquire" 0x2000 1
  pcx "atomic.cxchg.weak.ptr.seqcst.relaxed" 0x2001 0

def f64 (x : Float) : Nat := x.toBits.toNat
def f32 (x : Float32) : Nat := x.toBits.toNat

def floats : Except String Unit := do
  let fb (m : String) (n a b r : Nat) (ch : Choice := {}) :=
    expectInt m [S (-16), S (-32), S (-48)] (ab n a b) (-16) n r ch
  fb "fadd.f64" 8 (f64 1.5) (f64 2.25) (f64 3.75)
  fb "fmul.f32" 4 (f32 3.0) (f32 0.5) (f32 1.5)
  fb "fdiv.f64" 8 (f64 1.0) (f64 0.0) (f64 (1.0 / 0.0))
  fb "fsub.f64" 8 (f64 0.1) (f64 0.3) (f64 (0.1 - 0.3))
  fb "frem.f64" 8 (f64 7.5) (f64 2.0) (f64 1.5)
  fb "frem.f64" 8 (f64 (-7.5)) (f64 2.0) (f64 (-1.5))
  -- 0/0: a NaN, the choice checked against the allowed ones.
  let qnanNeg := 0xfff8000000000000
  fb "fdiv.f64" 8 (f64 0.0) (f64 0.0) qnanNeg { nan := some qnanNeg }
  expectStop "fdiv.f64" [S (-16), S (-32), S (-48)] (ab 8 (f64 0.0) (f64 0.0))
    (fun | .noBehavior _ => true | _ => false) "no behavior" { nan := some (f64 1.0) }
  -- min/max ignore a NaN operand; zeros of opposite sign are a choice.
  fb "fmin.f64" 8 (f64 (0.0 / 0.0)) (f64 2.0) (f64 2.0)
  fb "fmax.f32" 4 (f32 1.0) (f32 2.0) (f32 2.0)
  fb "fmin.f64" 8 (f64 0.0) (f64 (-0.0)) (f64 (-0.0)) { pickY := true }
  fb "fmin.f64" 8 (f64 0.0) (f64 (-0.0)) (f64 0.0)
  fb "copysign.f64" 8 (f64 1.0) (f64 (-0.0)) (f64 (-1.0))
  let fc (m : String) (n a b r : Nat) :=
    expectInt m [S (-16), S (-32), S (-48)] (ab n a b) (-16) 1 r
  fc "feq.f64" 8 (f64 0.0) (f64 (-0.0)) 1
  fc "fne.f64" 8 (f64 (0.0 / 0.0)) (f64 (0.0 / 0.0)) 1
  fc "feq.f64" 8 (f64 (0.0 / 0.0)) (f64 (0.0 / 0.0)) 0
  fc "flt.f32" 4 (f32 1.0) (f32 2.0) 1
  fc "fle.f32" 4 (f32 (0.0 / 0.0)) (f32 2.0) 0
  let f1 (m : String) (nx a ny r : Nat) :=
    expectInt m [S (-16), S (-32)] (stOf [(-32, le nx a)]) (-16) ny r
  f1 "fneg.f64" 8 (f64 1.0) 8 (f64 (-1.0))
  f1 "fabs.f32" 4 (f32 (-2.0)) 4 (f32 2.0)
  f1 "cvt.f2i.sat.s.f64.w8" 8 (f64 300.0) 1 127
  f1 "cvt.f2i.sat.s.f64.w8" 8 (f64 (-300.0)) 1 0x80
  f1 "cvt.f2i.sat.u.f32.w32" 4 (f32 (-1.0)) 4 0
  f1 "cvt.f2i.sat.s.f64.w64" 8 (f64 (0.0 / 0.0)) 8 0
  f1 "cvt.f2i.sat.s.f64.w32" 8 (f64 (-2.7)) 4 (m32 (-2))
  f1 "cvt.i2f.s.w32.f64" 4 (m32 (-3)) 8 (f64 (-3.0))
  f1 "cvt.i2f.u.w128.f32" 16 (2 ^ 128 - 1) 4 (f32 (1.0 / 0.0))
  f1 "cvt.i2f.u.w64.f32" 8 (2 ^ 64 - 1) 4 (f32 18446744073709551615.0)
  f1 "cvt.f2f.f64.f32" 8 (f64 0.1) 4 (f32 0.1)
  f1 "cvt.f2f.f32.f64" 4 (f32 0.5) 8 (f64 0.5)
  -- Uninitialized float operands are UB.
  expectUb "fadd.f32" [S (-16), S (-32), S (-48)] (stOf [(-32, le 4 0)])

/-! ### Exactness: each kind writes all its footprint's writes -/

/-- Generic operands for `op`: distinct slots 32 bytes apart, small immediates, addresses of
allocation 1. Every slot holds a pointer to allocation 0 at a distinct offset. -/
def genericOps (op : Full.Opcode) : Operands :=
  (op.info.operands.zipIdx).map fun (o, i) => match o.kind with
    | .slot => .slot (-32 * ((i : Int) + 1))
    | .mem => .mem (-32 * ((i : Int) + 1)) 0
    | .u8 | .u16 | .u32 | .u64 | .i64 | .u128 => .imm 2
    | .const | .abs | .sym | .site => .addr ⟨0x10000, some 1⟩
    | .list .target => .targets 3
    | .list _ => .cases ⟨0x10000, some 1⟩ 2
    | _ => .none

def genericState : State :=
  let ptrs : List (Int × List AbstractByte) := (List.range 8).map fun (i : Nat) =>
    (-32 * ((i : Int) + 1), prov 0 (0x1000 + 0x40 * (i + 1)) ++ le 8 0)
  { frame := frameOf ptrs,
    mem := { allocs := #[mkAlloc 0x1000 (le 0x400 0), mkAlloc 0x10000 (prov 0 0x1000 ++ le 24 0)] } }

/-- The names `kindSem` writes, if it succeeds on the generic operands. -/
def writtenNames (op : Full.Opcode) : Option (List String) :=
  match prepare op (genericOps op) with
  | .error _ => none
  | .ok (h, fp, val) =>
    match readAll fp val genericState with
    | .error _ => none
    | .ok reads =>
      match kindSem h.kind h.params (mkEnv reads val genericState {}) with
      | .ok o => some (o.writes.map (·.1))
      | .error _ => none

def exactWrites : Except String Unit := do
  let ran := withHandler.filter fun op => (writtenNames op).isSome
  -- Everything runs on the generic operands but `abort`, `addr` (of a private object) and
  -- the `mem*` (whose length slot holds a pointer, out of bounds); the unit tests run those.
  let failed := (withHandler.filter fun op => (writtenNames op).isNone).map (·.mnemonic)
  check (failed == ["memcpy", "memmove", "memset", "addr", "abort"])
    s!"opcodes that fail on generic operands: {failed}"
  forAll ran (fun op => writtenNames op == (footprint op).map (·.writes.map (·.opnd)))
    "the writes differ from the footprint's"
  -- And opSem as a whole succeeds where kindSem does (the lengths match the footprint).
  forAll ran (fun op => (opSem op (genericOps op) genericState).toBool) "opSem fails"

def tests : List TestCase := [
  ⟨"OpSem/footprint-total", fun _ => footprintTotal⟩,
  ⟨"OpSem/footprint-names", fun _ => footprintNames⟩,
  ⟨"OpSem/footprint-known", fun _ => footprintKnown⟩,
  ⟨"OpSem/exact-writes", fun _ => exactWrites⟩,
  ⟨"OpSem/movement", fun _ => movement⟩,
  ⟨"OpSem/addresses", fun _ => addresses⟩,
  ⟨"OpSem/integers", fun _ => integers⟩,
  ⟨"OpSem/overflow", fun _ => overflow⟩,
  ⟨"OpSem/conversions", fun _ => conversions⟩,
  ⟨"OpSem/enums", fun _ => enums⟩,
  ⟨"OpSem/control", fun _ => control⟩,
  ⟨"OpSem/atomics", fun _ => atomics⟩,
  ⟨"OpSem/floats", fun _ => floats⟩,
]

end RyoTest.OpSem
