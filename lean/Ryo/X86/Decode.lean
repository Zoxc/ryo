/-
Ryo.X86.Decode — `decodeItem`: reads one canonical element from a function's code (x86.md §B.2).

Mirrors `Cursor` in `vm/bytecode/src/asm/x86.rs` (`item`, `base_item`, `native`, `sse`, `padding`,
`table_padding`, `table_entry`), including what its `rel32` fields refer to (`Fields`):

- `Fields.relocs`: unlinked code, with the object's relocation list (sorted by position). A field
  with a relocation is a reference; one without is a branch within the function. A relocation
  anywhere else in an item makes it invalid.
- `Fields.linked`: linked code at a known address. A field whose target lies inside the
  function, past its first byte, is a branch within it; one at the function's JIT record is
  `Ref.record`, one at its loop counter (`loopCtr` bytes in) `Ref.recordLoopCtr`; any other is resolved by the `LinkMap` (`Resolver::resolve`), which may fail.

The decoder accepts only canonical encodings. After parsing a candidate item as Rust does, it
re-encodes it and compares every byte outside the item's own relocated fields (whose bytes are
the linker's business), so `encode` inverts `decodeItem` on what it accepts by construction
(`Cursor.matchesItem`; `decodeItem_pos`: an accepted element is never empty). The converse, `decodeItem (encode i) = some (i, len)` for `Item.wf` items,
is tested over the Rust encoder's vectors and generated item sets in `RyoTest/X86.lean`.

The PE prologue and epilogue, one item each in Rust (`Item::WinPrologue`, `Item::WinEpilogue`),
are their instructions here (`Ryo.X86.Item`); `Cursor.winPiece` reads those past `push rbp`
only inside the whole sequence, so the decoder accepts what Rust's does, an instruction at a
time.

`Cursor.spFrame`: without a frame pointer, frame slots are `[rsp + F + d]`, which the decoder
returns as `[rbp + d]` (the encoder's form); `[rbp + _]` is then invalid, as `[rsp + _]` is with a
frame pointer.
-/
import Ryo.X86.Encode

set_option linter.constructorNameAsVariable false

namespace Ryo.X86

/-- Linked code: the reference at an absolute address (`Resolver::resolve`): a total function,
`none` where the address is none of the references. -/
abbrev LinkMap := BitVec 64 → Option Ref

/-- What a function's `rel32` fields refer to (`x86.rs` `Fields`). -/
inductive Fields
  /-- Unlinked code: the relocations, sorted by position. -/
  | relocs (rs : Array Reloc)
  /-- Linked code at address `addr`; `record` is the function's JIT record. -/
  | linked (addr record : BitVec 64) (resolve : LinkMap)

instance : Inhabited Fields := ⟨.relocs #[]⟩

/-- A function's code being read (`x86.rs` `Cursor`). -/
structure Cursor where
  code : Array UInt8
  pos : Nat
  fields : Fields
  spFrame : Option (BitVec 32) := none
deriving Inhabited

/-- A `rel32` field: a branch within the function (its target position), or a reference. -/
inductive Field
  | local (t : BitVec 32)
  | ref (r : Ref)
  | bad
deriving DecidableEq, Repr

/-- The first index in `rs` (sorted by position) whose position is at least `p`. -/
def lowerBound (rs : Array Reloc) (p : Nat) : Nat := go 0 rs.size
where
  go (lo hi : Nat) : Nat :=
    if h : lo < hi then
      let mid := (lo + hi) / 2
      let below := match rs[mid]? with
        | some r => decide (r.pos < p)
        | none => false
      if below then go (mid + 1) hi else go lo mid
    else lo
  termination_by hi - lo

/-- The relocations of the fields starting in `[at, at + len)`. -/
def relocsIn (rs : Array Reloc) (at_ len : Nat) : List Reloc :=
  (rs.extract (lowerBound rs at_) (lowerBound rs (at_ + len))).toList

def sext8 (b : UInt8) : BitVec 32 := (BitVec.ofNat 8 b.toNat).signExtend 32

namespace Cursor

def get (c : Cursor) (i : Nat) : Option UInt8 := c.code[c.pos + i]?

def bytes (c : Cursor) (n : Nat) : Option (List UInt8) :=
  if c.pos + n ≤ c.code.size then some ((c.code.extract c.pos (c.pos + n)).toList) else none

def i32At (c : Cursor) (off : Nat) : Option (BitVec 32) := do
  let b ← c.bytes (off + 4)
  pure (BitVec.ofNat 32 (ofLeBytes (b.drop off)))

/-- The relocations of fields starting in the next `len` bytes (none in linked code). -/
def relocsHere (c : Cursor) (len : Nat) : List Reloc :=
  match c.fields with
  | .relocs rs => relocsIn rs c.pos len
  | .linked .. => []

/-- The PC-relative field `off` bytes into an item of length `len` (`Cursor::field`). -/
def field (c : Cursor) (off len : Nat) : Option Field := do
  let d ← c.i32At off
  let loc := BitVec.ofNat 32 (c.pos + len) + d
  match c.fields with
  | .relocs rs =>
    match (relocsIn rs (c.pos + off) 1).head? with
    | some r => pure (.ref r.to)
    | none => pure (.local loc)
  | .linked addr record resolve =>
    let to := addr + BitVec.ofNat 64 (c.pos + len) + d.signExtend 64
    let inside := (to - addr - 1).toNat < (BitVec.ofNat 64 c.code.size - 1).toNat
    if inside then pure (.local loc)
    else if to == record then pure (.ref .record)
    else if to == record + BitVec.ofNat 64 loopCtr then pure (.ref .recordLoopCtr)
    else pure ((resolve to).elim .bad .ref)

def fieldRef (c : Cursor) (off len : Nat) : Option Ref := do
  match ← c.field off len with
  | .ref r => pure r
  | _ => none

def «local» (c : Cursor) (off len : Nat) : Option (BitVec 32) := do
  match ← c.field off len with
  | .local t => pure t
  | _ => none

/-- Whether the next bytes are `item`'s encoding, outside its relocated fields, and the
relocations there are exactly its own (in linked code, its fields resolved to its references
when it was parsed). Returns its length. -/
def encodedAt (c : Cursor) (bs : List UInt8) (rs : List Reloc) : Bool :=
  match c.bytes bs.length with
  | none => false
  | some here =>
    let inField (j : Nat) : Bool := rs.any fun r => r.pos ≤ c.pos + j && c.pos + j < r.pos + 4
    let same := (List.range bs.length).all fun j => inField j || here.getD j 0 == bs.getD j 0
    let relocsOk := match c.fields with
      | .relocs _ => c.relocsHere bs.length == rs
      | .linked .. => true
    same && relocsOk

def matchesItem (c : Cursor) (item : Item) : Option Nat :=
  let e := item.encode (BitVec.ofNat 32 c.pos)
  if c.encodedAt e.1 e.2 && 0 < e.1.length then some e.1.length else none

/-- The item and its length, if the next bytes are its encoding; `post` maps the item (to the
encoder's frame form) or rejects it. -/
def accept (c : Cursor) (post : Item → Option Item) (i : Item) : Option (Item × Nat) :=
  match c.matchesItem i, post i with
  | some n, some j => some (j, n)
  | _, _ => none

/-- An instruction of the PE prologue or epilogue past `push rbp`, read only inside the whole
sequence: Rust reads `winPrologueBytes` and `winEpilogueBytes` as one item each
(`Item::WinPrologue`, `Item::WinEpilogue`), so it reads none of these instructions elsewhere.
The sequence is the bytes around the cursor, `k` bytes back for the instruction `k` bytes in. -/
def winPiece (c : Cursor) : Option Item :=
  let seqAt (k : Nat) (bs : List UInt8) : Bool :=
    k ≤ c.pos && { c with pos := c.pos - k }.bytes bs.length == some bs
  if seqAt 1 winPrologueBytes then some (.push .rdi)
  else if seqAt 2 winPrologueBytes then some (.push .rsi)
  else if seqAt 3 winPrologueBytes then some .leaRbpRsp16
  else if seqAt 0 winEpilogueBytes then some .leaRspRbp16
  else if seqAt 4 winEpilogueBytes then some (.pop .rsi)
  else if seqAt 5 winEpilogueBytes then some (.pop .rdi)
  else if seqAt 6 winEpilogueBytes then some (.pop .rbp)
  else none

/-- `Cursor::base_item`'s parse: the candidate item, before the canonical check. -/
def baseCandidate (c : Cursor) : Option Item := do
  let b0 ← c.get 0
  let g := c.get
  if let some i := c.winPiece then return i
  let (rex, at_) : UInt8 × Nat := if 0x40 ≤ b0 && b0 ≤ 0x4f then (b0, 1) else (0, 0)
  let (rw, rr, rx, rb) := (rex &&& 8 != 0, rex &&& 4 != 0, rex &&& 2 != 0, rex &&& 1 != 0)
  let ext (c : Bool) : Nat := if c then 8 else 0
  let op ← g at_
  match rex, op with
  | 0, 0x55 => pure .pushRbp
  -- A counter's `inc`: of the record's call counter or its loop counter.
  | 0x48, 0xff =>
    if (← g 2) != 0x05 then none
    match ← c.field 3 7 with
    | .ref .record => pure (.ctrInc false)
    | .ref .recordLoopCtr => pure (.ctrInc true)
    | _ => none
  | 0x48, 0x83 =>
    let e ← g 2
    let v ← g 3
    if v.toNat ≥ 128 then none
    if e == 0xec then pure (.subRsp (BitVec.ofNat 32 v.toNat))
    else if e == 0xc4 then pure (.addRsp (BitVec.ofNat 32 v.toNat))
    else none
  | 0x48, 0x81 =>
    let e ← g 2
    let v ← c.i32At 3
    if v.toNat < 128 then none
    if e == 0xec then pure (.subRsp v) else if e == 0xc4 then pure (.addRsp v) else none
  | 0, 0x31 | 0x45, 0x31 =>
    let m ← g (at_ + 1)
    let (r_, rm) := ((m >>> 3 &&& 7).toNat, (m &&& 7).toNat)
    if m >>> 6 != 3 || r_ != rm || rr != rb then none
    pure (.setReg (← Reg.ofNum? (rm + ext rb)) 0)
  | 0, op | 0x41, op =>
    if 0xb8 ≤ op && op ≤ 0xbf then
      let r ← Reg.ofNum? ((op &&& 7).toNat + ext rb)
      let v := (← c.i32At (at_ + 1)).setWidth 64
      if setForm v != 1 then none
      pure (.setReg r v)
    else if rex == 0 then
      baseNoRex c op
    else if op == 0xff && (← g 2) == 0x53 then pure (.callR11 (BitVec.ofNat 8 (← g 3).toNat))
    else none
  | 0x48, 0xc7 | 0x49, 0xc7 =>
    let m ← g 2
    if m &&& 0xf8 != 0xc0 then none
    let r ← Reg.ofNum? ((m &&& 7).toNat + ext rb)
    let v := (← c.i32At 3).signExtend 64
    if setForm v != 2 then none
    pure (.setReg r v)
  | 0x48, 0x8d | 0x4c, 0x8d =>
    let m ← g 2
    if m &&& 0xc7 != 0x05 then none
    let r ← Reg.ofNum? ((m >>> 3 &&& 7).toNat + ext rr)
    match ← c.field 3 7 with
    | .ref to => pure (.lea r to)
    | .local t => if r == .rcx then pure (.leaTable t) else none
    | .bad => none
  | 0x48, 0x8b | 0x4c, 0x8b =>
    let m ← g 2
    if m &&& 0xc7 != 0x05 then none
    let r ← Reg.ofNum? ((m >>> 3 &&& 7).toNat + ext rr)
    pure (.loadRip r (← c.fieldRef 3 7))
  | 0x48, 0x85 => if (← g 2) == 0xc0 then pure .testRax else none
  | 0x48, 0x63 => if (← c.bytes 4) == [0x48, 0x63, 0x04, 0x81] then pure .loadTableEntry else none
  | 0x48, 0x01 => if (← g 2) == 0xc8 then pure .addRaxRcx else none
  | _, op =>
    if rex ≥ 0x48 && rex ≤ 0x4f && op == 0x89 && rw && !rx then
      let m ← g 2
      if m >>> 6 != 3 then none
      let src ← Reg.ofNum? ((m >>> 3 &&& 7).toNat + ext rr)
      let dst ← Reg.ofNum? ((m &&& 7).toNat + ext rb)
      pure (.mov dst src)
    else if rex ≥ 0x48 && rex ≤ 0x4f && op ≥ 0xb8 && op ≤ 0xbf && (rex == 0x48 || rex == 0x49) then
      let r ← Reg.ofNum? ((op &&& 7).toNat + ext rb)
      let v ← c.bytes 10
      let v := BitVec.ofNat 64 (ofLeBytes (v.drop 2))
      if setForm v != 3 then none
      pure (.setReg r v)
    else none
where
  /-- The forms without a REX prefix (other than `push rbp`, `xor` and `mov r32, imm32`). -/
  baseNoRex (c : Cursor) (op : UInt8) : Option Item := do
    let g := c.get
    match op with
    | 0xe8 => pure (.call (← c.fieldRef 1 5))
    | 0xff =>
      match ← g 1 with
      | 0x15 => pure (.callMem (← c.fieldRef 2 6))
      | 0xd0 => pure .callRax
      | 0x10 => pure .callMemRax
      | 0xe0 => pure .jmpRax
      | _ => none
    | 0xe9 =>
      match ← c.field 1 5 with
      | .ref to => pure (.jmp to)
      | .local t => pure (.branch .always t true)
      | .bad => none
    | 0x0f =>
      let op2 ← g 1
      if 0x80 ≤ op2 && op2 ≤ 0x8f then
        pure (.branch (← Cond.ofCc? (op2 &&& 0xf).toNat) (← c.local 2 6) true)
      else if op2 == 0x0b then pure .ud2
      else none
    | 0x84 => if (← g 1) == 0xc0 then pure .testAl else none
    | 0xc9 => pure .leave
    | 0xc3 => pure .ret
    | 0x66 =>
      let (rExt, i) := if (← g 1) == 0x41 then (8, 2) else (0, 1)
      let op2 ← g (i + 1)
      let m ← g (i + 2)
      if (← g i) != 0x0f || !(op2 == 0x6e || op2 == 0x7e) || m >>> 6 != 3 then none
      let r ← Reg.ofNum? ((m &&& 7).toNat + rExt)
      if !r.usable then none
      pure (.movd (op2 == 0x6e) (m >>> 3 &&& 7).toNat r)
    | op =>
      if op == 0xeb || (0x70 ≤ op && op ≤ 0x7f) then
        let d := sext8 (← g 1)
        let cond ← if op == 0xeb then some .always else Cond.ofCc? (op &&& 0xf).toNat
        pure (.branch cond (BitVec.ofNat 32 (c.pos + 2) + d) false)
      else none

/-- `Cursor::sse`'s parse: an SSE load or store of a frame slot, the `0f` byte `pre` bytes in. -/
def sseCandidate (c : Cursor) : Option Item := do
  let g := c.get
  let (pre, size) ← match ← g 0 with
    | 0xf3 => some (1, 4)
    | 0xf2 => some (1, 8)
    | _ => some (0, 16)
  if (← g pre) != 0x0f then none
  let op2 ← g (pre + 1)
  if !(op2 == 0x10 || op2 == 0x11) then none
  let at_ := pre + 2
  let m ← g at_
  let (md, x, rm) := (m >>> 6, (m >>> 3 &&& 7).toNat, m &&& 7)
  let (base, d) ← if rm == 5 then some (Reg.rbp, at_ + 1)
    else if rm == 4 && (← g (at_ + 1)) == 0x24 then some (Reg.rsp, at_ + 2)
    else none
  let disp ← if md == 0 && base == .rsp then some 0
    else if md == 1 then sext8 <$> g d
    else if md == 2 then c.i32At d
    else none
  pure (.sse (op2 == 0x11) size x ⟨base, disp⟩)

/-- `Cursor::native`'s lenient parse of an inline sequence's instruction. -/
def nativeCandidate (c : Cursor) : Option Item := do
  let g := c.get
  let (w0, i0) : W × Nat := if (← g 0) == 0x66 then (.w, 1) else (.d, 0)
  let rexB ← g i0
  let (w, rr, rb, i) ← if 0x40 ≤ rexB && rexB ≤ 0x4f then do
      if rexB &&& 2 != 0 then none
      let w ← if rexB &&& 8 != 0 then (if w0 == .w then none else some W.q) else some w0
      some (w, ((rexB >>> 2) &&& 1).toNat * 8, (rexB &&& 1).toNat * 8, i0 + 1)
    else some (w0, 0, 0, i0)
  let op ← g i
  let i := i + 1
  -- The ModRM operand at `j`: the `reg` field, the `r/m` operand, and the next position.
  let modrm (j : Nat) : Option (Nat × Rm × Nat) := do
    let m ← g j
    let (md, reg, rm) := (m >>> 6, (m >>> 3 &&& 7).toNat + rr, (m &&& 7).toNat)
    if md == 3 then return (reg, .reg (← Reg.ofNum? (rm + rb)), j + 1)
    if rm == 5 && md == 0 then none
    let (base, j) ← if rm == 4 then do
        if rb != 0 || (← g (j + 1)) != 0x24 then none
        some (Reg.rsp, j + 1)
      else do
        let b ← Reg.ofNum? (rm + rb)
        if b == .rbp || b.usable then some (b, j) else none
    let (disp, n) ← if md == 0 then some (0, 0)
      else if md == 1 then (fun b => (sext8 b, 1)) <$> g (j + 1)
      else (fun d => (d, 4)) <$> c.i32At (j + 1)
    pure (reg, .mem ⟨base, disp⟩, j + 1 + n)
  let mem : Rm → Option M := fun | .mem m => some m | .reg _ => none
  let reg : Nat → Option Reg := fun n => (Reg.ofNum? n).filter (·.usable)
  let rmReg : Rm → Option Reg := fun | .reg r => reg r.num | .mem _ => none
  let immAt (w : W) (j : Nat) : Option (BitVec 32) := match w with
    | .b => sext8 <$> g j
    | .w => do
      let lo ← g j
      let hi ← g (j + 1)
      pure ((BitVec.ofNat 16 (lo.toNat + 256 * hi.toNat)).signExtend 32)
    | _ => c.i32At j
  let dq : W → Option W := fun w => if w == .d || w == .q then some w else none
  let byteW : W → Option W := fun w => if w == .d then some .b else none
  let dqw := w == .d || w == .q
  let item ← match op with
    | 0x0f =>
      if !dqw then none
      let op2 ← g i
      if 0xc8 ≤ op2 && op2 ≤ 0xcf then pure (.bswap w (← reg ((op2 &&& 7).toNat + rb))) else
      let (r, rm, _) ← modrm (i + 1)
      if (op2 == 0xb6 || op2 == 0xb7 || op2 == 0xbe || op2 == 0xbf) && w == .d then
        pure (.ld (if op2 &&& 1 == 0 then .b else .w) (op2 &&& 8 != 0) (← reg r) (← mem rm))
      else if op2 == 0xaf then pure (.imul w (← reg r) rm)
      else if op2 == 0xbc then pure (.bsf w (← reg r) rm)
      else if op2 == 0xbd then pure (.bsr w (← reg r) rm)
      else if 0x40 ≤ op2 && op2 ≤ 0x4f && w == .d then
        pure (.cmov (← Cond.ofCc? (op2 &&& 0xf).toNat) w (← reg r) rm)
      else if 0x90 ≤ op2 && op2 ≤ 0x9f && w == .d && r == 0 && rm == .reg .rcx then
        pure (.setccCl (← Cond.ofCc? (op2 &&& 0xf).toNat))
      else if 0x90 ≤ op2 && op2 ≤ 0x9f && w == .d && r == 0 && rm matches .reg _ then
        pure (.setccR (← Cond.ofCc? (op2 &&& 0xf).toNat) (← rmReg rm))
      else if 0x90 ≤ op2 && op2 ≤ 0x9f && w == .d && r == 0 then
        pure (.setcc (← Cond.ofCc? (op2 &&& 0xf).toNat) (← mem rm))
      else none
    | 0x8b =>
      if !dqw then none
      let (r, rm, _) ← modrm i
      pure (.ld w false (← reg r) (← mem rm))
    | 0x88 | 0x89 =>
      let w ← if op == 0x88 then byteW w else some w
      let (r, rm, _) ← modrm i
      pure (.st w (← reg r) (← mem rm))
    | 0xc6 | 0xc7 =>
      let w ← if op == 0xc6 then byteW w else some w
      let (_, rm, j) ← modrm i
      pure (.stImm w (← mem rm) (← immAt w j))
    | 0x8d =>
      if w != .q then none
      let (r, rm, _) ← modrm i
      pure (.leaM (← reg r) (← mem rm))
    | 0x80 | 0x81 | 0x83 =>
      let w ← if op == 0x80 then byteW w else some w
      let (r, rm, j) ← modrm i
      let imm ← if op == 0x81 then immAt w j else sext8 <$> g j
      pure (.aluImm (← Alu.ofNum? r) w rm imm)
    | 0x69 | 0x6b =>
      let (r, rm, j) ← modrm i
      let imm ← if op == 0x69 then c.i32At j else sext8 <$> g j
      pure (.imulImm (← dq w) (← reg r) rm imm)
    | 0xc1 =>
      let (r, rm, j) ← modrm i
      let sh ← (Sh.ofNum? r).filter (·.isShift)
      pure (.shift sh (← dq w) (← rmReg rm) (BitVec.ofNat 8 (← g j).toNat))
    | 0xd2 | 0xd3 =>
      let w ← if op == 0xd2 then byteW w else some w
      let (r, rm, _) ← modrm i
      pure (.shiftCl (← Sh.ofNum? r) w (← rmReg rm))
    | 0xf6 =>
      if w != .d then none
      let (_, rm, _) ← modrm i
      pure (.testM8 (← mem rm))
    | 0xf7 =>
      if !dqw then none
      let (r, rm, _) ← modrm i
      if w == .q && r == 4 then pure (.mulQ rm)
      else if r == 6 || r == 7 then pure (.div (r == 7) w rm)
      else none
    | 0x99 => if dqw then pure (.cdq w) else none
    | op =>
      if op < 0x40 && op &&& 6 == 2 then
        let w ← if op &&& 1 == 0 then byteW w else some w
        let (r, rm, _) ← modrm i
        pure (.alu (← Alu.ofNum? (op >>> 3).toNat) w (← reg r) rm)
      else none
  -- A register `r/m` operand must be usable too.
  match item with
  | .alu _ _ _ (.reg r) | .aluImm _ _ (.reg r) _ | .imul _ _ (.reg r) | .imulImm _ _ (.reg r) _
  | .mulQ (.reg r) | .div _ _ (.reg r) | .bsf _ _ (.reg r) | .bsr _ _ (.reg r)
  | .cmov _ _ _ (.reg r) =>
    if !r.usable then none
  | _ => pure ()
  pure item

/-- The frame slots of a native or SSE item, from the mode's form to the encoder's. -/
def fromSpFrame (c : Cursor) (item : Item) : Option Item :=
  match item.mem?.map (·.base), c.spFrame with
  | some Reg.rbp, some _ | some Reg.rsp, none => none
  | some Reg.rsp, some f => some (item.mapMem fun m => M.frame (m.disp - f))
  | _, _ => some item

end Cursor

/-- Reads the element at the cursor (not padding, `int3` or a table entry), checking that its
encoding is canonical: the item and its length (`Cursor::item`). -/
def decodeItem (c : Cursor) : Option (Item × Nat) :=
  (c.baseCandidate.bind (c.accept some)) <|> (c.sseCandidate.bind (c.accept c.fromSpFrame)) <|>
    (c.nativeCandidate.bind (c.accept c.fromSpFrame))

namespace Cursor

def advance (c : Cursor) (n : Nat) : Cursor := { c with pos := c.pos + n }

/-- Reads padding: 9-byte `nop`s, then at most one shorter one; its length (`Cursor::padding`). -/
def padding (c : Cursor) : Nat := go c 0 (c.code.size + 1)
where
  go (c : Cursor) (acc : Nat) : Nat → Nat
    | 0 => acc
    | fuel + 1 =>
      let found := (List.range 9).reverse.map (· + 1) |>.find? fun n =>
        c.bytes n == some (nops.getD n []) && c.relocsHere n == []
      match found with
      | none => acc
      | some n => if n == 9 then go (c.advance 9) (acc + 9) fuel else acc + n

/-- Reads `int3`s up to a multiple of 4: the new position (`Cursor::table_padding`). -/
def tablePadding (c : Cursor) : Option Nat := go c.pos 4
where
  go (p : Nat) : Nat → Option Nat
    | 0 => some p
    | fuel + 1 => if p % 4 == 0 then some p
      else if c.code[p]? == some 0xcc then go (p + 1) fuel else none

/-- Reads a jump table entry relative to the table start `base`: its target
(`Cursor::table_entry`). -/
def tableEntry (c : Cursor) (base : BitVec 32) : Option (BitVec 32) := do
  if c.relocsHere 4 != [] then none
  pure (base + (← c.i32At 0))

end Cursor

/-- The length `matchesItem` accepts is the item's encoded length, and positive. -/
theorem Cursor.matchesItem_len (c : Cursor) (i : Item) (n : Nat) (h : c.matchesItem i = some n) :
    (i.encode (BitVec.ofNat 32 c.pos)).1.length = n ∧ 0 < n := by
  unfold Cursor.matchesItem at h
  dsimp only at h
  split at h <;> simp_all

theorem Cursor.accept_pos (c : Cursor) (post : Item → Option Item) (i j : Item) (n : Nat)
    (h : c.accept post i = some (j, n)) : 0 < n := by
  unfold Cursor.accept at h
  split at h
  · simp only [Option.some.injEq, Prod.mk.injEq] at h
    exact h.2 ▸ (Cursor.matchesItem_len c i _ ‹_›).2
  · simp at h

theorem Option.orElse_some' {α : Type} {a b : Option α} {x : α} (h : (a <|> b) = some x) :
    a = some x ∨ b = some x := by
  cases a <;> simp_all [HOrElse.hOrElse, OrElse.orElse, Option.orElse]

/-- The decoder makes progress: an accepted element is at least one byte long. -/
theorem decodeItem_pos (c : Cursor) (i : Item) (n : Nat) (h : decodeItem c = some (i, n)) :
    0 < n := by
  unfold decodeItem at h
  rcases Option.orElse_some' h with h | h
  · obtain ⟨_, _, h⟩ := Option.bind_eq_some_iff.mp h
    exact c.accept_pos _ _ _ _ h
  · rcases Option.orElse_some' h with h | h <;>
    · obtain ⟨_, _, h⟩ := Option.bind_eq_some_iff.mp h
      exact c.accept_pos _ _ _ _ h

end Ryo.X86
