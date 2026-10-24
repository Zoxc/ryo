/-
Ryo.X86.Extra — the machine code ryo emits outside `asm::x86::Item` (x86.md §B.1), as `Item`-like
forms with encode, decode and semantics:

- the OSR code of today's JIT (`vm/bytecode/src/asm/osr.rs`, `osr_code`): the dispatcher
  (`lea r11, [rip + table]; movsxd rax, [r11 + rax*4]; add rax, r11; jmp rax`, `int3` padding,
  the table of `i32` offsets), and per loop head `ret` (not enterable) or `pop rcx`, loads and
  stores of 1/2/4/8 bytes between `rax` and `[rdx|rbp|rsp + disp32]`, `lea rdx|rsp, [_ + disp32]`,
  `mov eax, grow; call ryo_probe_stack`, `jmp rel32` to the head in the JIT code. `osrCode`
  ports `osr_code` itself, so its output can be compared with Rust's byte for byte;
- the JIT entry prefix (`vm/jit/src/install.rs`, `JIT_ENTRY_PREFIX`):
  `lea r11, [rip + code]; mov [rsp], r11; ret`;
- the registry constructor (`backend/src/objfile.rs`, `add_registry_ctor`): ELF
  `lea rdi, [rip + images]; mov esi, n; jmp ryo_vm_register`, PE
  `lea rcx, [rip + images]; mov edx, n; jmp ryo_vm_register` or `jmp [rip + __imp_…]`. Its
  `mov r32, imm32` always takes the 5-byte form, even for `n = 0` (not `setReg`'s shortest);
- the trip stubs (`encode.rs`, the counter stubs): these are `Item`s already
  (`lea r11, [rip + record]`, `mov eax, n`, `call [r11 + 8|16]`, `jmp` back), so `entryStub` and
  `headStub` are lists of items, decoded by `decodeItem`.

The references of these forms that `Ref` doesn't name (the images section, `ryo_vm_register`,
its import slot) are `XRef`s. The decoder works as `decodeItem` does: parse a candidate, then
check that it re-encodes to the bytes (outside its relocated fields) with exactly its
relocations.
-/
import Ryo.X86.Decode
import Ryo.X86.Exec

set_option linter.constructorNameAsVariable false

namespace Ryo.X86

open Lean

/-- What a relocated field of the extra forms refers to. -/
inductive XRef
  | ref (r : Ref)
  /-- The image list section the registry constructor passes (`images`). -/
  | images
  /-- `ryo_vm_register`. -/
  | vmRegister
  /-- `__imp_ryo_vm_register`, its import slot (PE, `ryo_rt` in a DLL). -/
  | vmRegisterImp
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

structure XReloc where
  pos : Nat
  to : XRef
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

/-- The extra forms. Positions are byte offsets in the code the form sits in (for the OSR code,
the function's JIT code, of which it is a part). -/
inductive XItem
  /-- An `Item` (here: `call`, `jmp rax`, `ret`, `int3`, a table entry). -/
  | item (i : Item)
  /-- `pop rcx` -/
  | popRcx
  /-- `mov` of `size` (1, 2, 4, 8) bytes between `rax` and `[base + disp32]` (`base` `rdx`,
  `rbp` or `rsp`; always `disp32`): `mov al|ax|eax|rax, [m]` (`load`) or `mov [m], al|…`. -/
  | movRax (load : Bool) (size : Nat) (base : Reg) (disp : BitVec 32)
  /-- `lea dst, [base + disp32]` (`dst` `rsp` or `rdx`; always `disp32`). -/
  | leaD32 (dst base : Reg) (disp : BitVec 32)
  /-- `mov r32, imm32` (`b8+r`, whatever the value). -/
  | movImm32 (r : Reg) (imm : BitVec 32)
  /-- `lea r11, [rip + disp32]` of a position in the same code. -/
  | leaR11 (t : BitVec 32)
  /-- `movsxd rax, [r11 + rax*4]` -/
  | movsxdR11
  /-- `add rax, r11` -/
  | addRaxR11
  /-- `jmp rel32` to a position in the same code. -/
  | jmpRel (t : BitVec 32)
  /-- `mov [rsp], r11` -/
  | movRspR11
  /-- `lea r, [rip + disp32]`, relocated. -/
  | leaX (r : Reg) (to : XRef)
  /-- `jmp rel32`, relocated. -/
  | jmpX (to : XRef)
  /-- `jmp [rip + disp32]`, relocated. -/
  | jmpMemX (to : XRef)
deriving DecidableEq, Repr, Inhabited, ToJson, FromJson

namespace XItem

/-- The extra forms ryo emits, each with a unique encoding that `decodeX` reads back. -/
def wf (pos : BitVec 32) : XItem → Bool
  | item i => i.wf pos && (i matches .call _ | .jmpRax | .ret | .int3 | .tableEntry ..)
  | movRax _ size base _ => (size == 1 || size == 2 || size == 4 || size == 8) &&
      (base == .rdx || base == .rbp || base == .rsp)
  | leaD32 dst base _ => (dst == .rsp || dst == .rdx) && (base == .rdx || base == .rbp || base == .rsp)
  | _ => true

/-- `[base + disp32]` with `reg` in the ModRM's middle field (`osr.rs` `Base::modrm`). -/
def modrm32 (reg : Nat) (base : Reg) (disp : BitVec 32) : List UInt8 :=
  (if base == .rsp then [byte (0x84 ||| reg <<< 3), 0x24] else [byte (0x80 ||| reg <<< 3 ||| base.low)]) ++
    leBytes disp 4

def encode (x : XItem) (pos : BitVec 32) : List UInt8 × List XReloc :=
  let reloc (pre : List UInt8) (to : XRef) : List UInt8 × List XReloc :=
    (pre ++ [0, 0, 0, 0], [⟨pos.toNat + pre.length, to⟩])
  let rel32 (pre : List UInt8) (t : BitVec 32) : List UInt8 :=
    pre ++ leBytes (t - (pos + BitVec.ofNat 32 (pre.length + 4))) 4
  let plain (bs : List UInt8) : List UInt8 × List XReloc := (bs, [])
  match x with
  | item i => let (bs, rs) := i.encode pos; (bs, rs.map fun r => ⟨r.pos, .ref r.to⟩)
  | popRcx => plain [0x59]
  | movRax load size base disp =>
    let pre : List UInt8 := if size == 8 then [0x48] else if size == 2 then [0x66] else []
    let op : UInt8 := match size == 1, load with
      | true, true => 0x8a | true, false => 0x88 | false, true => 0x8b | false, false => 0x89
    plain (pre ++ [op] ++ modrm32 0 base disp)
  | leaD32 dst base disp => plain ([0x48, 0x8d] ++ modrm32 dst.low base disp)
  | movImm32 r imm => plain ((if r.ext then [(0x41 : UInt8)] else []) ++ [byte (0xb8 ||| r.low)] ++ leBytes imm 4)
  | leaR11 t => plain (rel32 [0x4c, 0x8d, 0x1d] t)
  | movsxdR11 => plain [0x49, 0x63, 0x04, 0x83]
  | addRaxR11 => plain [0x4c, 0x01, 0xd8]
  | jmpRel t => plain (rel32 [0xe9] t)
  | movRspR11 => plain [0x4c, 0x89, 0x1c, 0x24]
  | leaX r to =>
    reloc [byte (0x48 ||| (if r.ext then 4 else 0)), 0x8d, byte (0x05 ||| r.low <<< 3)] to
  | jmpX to => reloc [0xe9] to
  | jmpMemX to => reloc [0xff, 0x25] to

end XItem

/-- Encodes a sequence of extra forms from position `pos`. -/
def encodeXItems (items : List XItem) (pos : Nat := 0) : List UInt8 × List XReloc :=
  let (bs, rs, _) := items.foldl (fun (bs, rs, p) i =>
    let (b, r) := i.encode (BitVec.ofNat 32 p)
    (bs ++ b, rs ++ r, p + b.length)) ([], [], pos)
  (bs, rs)

/-! ### Decoding -/

/-- What the `rel32` fields of the extra forms refer to: relocations (sorted by position), or,
in linked code at `addr`, the references by address (any other target is a position in the
same code). -/
inductive XFields
  | relocs (rs : Array XReloc)
  | linked (addr : BitVec 64) (resolve : BitVec 64 → Option XRef)

instance : Inhabited XFields := ⟨.relocs #[]⟩

structure XCursor where
  code : Array UInt8
  pos : Nat
  fields : XFields
deriving Inhabited

namespace XCursor

def toCursor (c : XCursor) : Cursor :=
  { code := c.code, pos := c.pos, fields := match c.fields with
    | .relocs rs => .relocs (rs.filterMap fun r => match r.to with
        | .ref x => some ⟨r.pos, x⟩
        | _ => none)
    | .linked addr resolve => .linked addr 0 fun a => match resolve a with
        | some (.ref r) => some r
        | _ => none }

def relocsHere (c : XCursor) (len : Nat) : List XReloc :=
  match c.fields with
  | .relocs rs => rs.toList.filter fun r => c.pos ≤ r.pos && r.pos < c.pos + len
  | .linked .. => []

/-- The field `off` bytes into an item of length `len`: a reference, or a position. -/
def field (c : XCursor) (off len : Nat) : Option (XRef ⊕ BitVec 32) := do
  let d ← c.toCursor.i32At off
  match c.fields with
  | .relocs rs => match rs.toList.find? (·.pos == c.pos + off) with
    | some r => pure (.inl r.to)
    | none => pure (.inr (BitVec.ofNat 32 (c.pos + len) + d))
  | .linked addr resolve =>
    let to := addr + BitVec.ofNat 64 (c.pos + len) + d.signExtend 64
    match resolve to with
    | some r => pure (.inl r)
    | none => pure (.inr ((to - addr).setWidth 32))

def matchesX (c : XCursor) (x : XItem) : Option Nat := do
  let (bs, rs) := x.encode (BitVec.ofNat 32 c.pos)
  let here ← c.toCursor.bytes bs.length
  let inField (j : Nat) : Bool := rs.any fun r => r.pos ≤ c.pos + j && c.pos + j < r.pos + 4
  let same := (List.range bs.length).all fun j => inField j || here.getD j 0 == bs.getD j 0
  let relocsOk := match c.fields with
    | .relocs _ => c.relocsHere bs.length == rs
    | .linked .. => true
  if same && relocsOk && x.wf (BitVec.ofNat 32 c.pos) then some bs.length else none

/-- The candidate extra form at the cursor (before the canonical check). -/
def candidate (c : XCursor) : Option XItem := do
  let g := c.toCursor.get
  let b0 ← g 0
  let base (m : UInt8) (j : Nat) : Option Reg :=
    if m >>> 6 != 2 then none
    else if m &&& 7 == 2 then some .rdx
    else if m &&& 7 == 5 then some .rbp
    else if m &&& 7 == 4 && g (j + 1) == some 0x24 then some .rsp
    else none
  let disp (m : UInt8) (j : Nat) : Option (BitVec 32) :=
    c.toCursor.i32At (j + (if m &&& 7 == 4 then 2 else 1))
  let movRax (pre : Nat) (size : Nat) : Option XItem := do
    let op ← g pre
    let m ← g (pre + 1)
    if m >>> 3 &&& 7 != 0 then none
    let size := if op == 0x8a || op == 0x88 then (if size == 4 then 1 else 0) else size
    if size == 0 || !(op == 0x88 || op == 0x89 || op == 0x8a || op == 0x8b) then none
    pure (.movRax (op == 0x8a || op == 0x8b) size (← base m (pre + 1)) (← disp m (pre + 1)))
  if b0 == 0x59 then pure .popRcx
  else if b0 == 0x66 then movRax 1 2
  else if b0 == 0x88 || b0 == 0x89 || b0 == 0x8a || b0 == 0x8b then movRax 0 4
  else if b0 == 0x48 || b0 == 0x4c then do
    let op ← g 1
    if op == 0x8d then lea c b0
    else if b0 == 0x48 then movRax 1 8
    else if (← c.toCursor.bytes 3) == [0x4c, 0x01, 0xd8] then pure .addRaxR11
    else if (← c.toCursor.bytes 4) == [0x4c, 0x89, 0x1c, 0x24] then pure .movRspR11
    else none
  else if b0 == 0x49 then
    if (← c.toCursor.bytes 4) == [0x49, 0x63, 0x04, 0x83] then pure .movsxdR11 else none
  else if b0 == 0xe9 then do
    match ← c.field 1 5 with
    | .inl to => pure (.jmpX to)
    | .inr t => pure (.jmpRel t)
  else if b0 == 0xff then do
    if (← g 1) != 0x25 then none
    match ← c.field 2 6 with
    | .inl to => pure (.jmpMemX to)
    | .inr _ => none
  else do
    let (ext, op) ← if b0 == 0x41 then (fun op => (8, op)) <$> g 1 else some (0, b0)
    if 0xb8 ≤ op && op ≤ 0xbf then
      pure (.movImm32 (← Reg.ofNum? ((op &&& 7).toNat + ext)) (← c.toCursor.i32At (if ext == 8 then 2 else 1)))
    else none
where
  /-- `lea` with a `rip`-relative or a `[base + disp32]` operand (`48|4c 8d`). -/
  lea (c : XCursor) (b0 : UInt8) : Option XItem := do
    let g := c.toCursor.get
    let m ← g 2
    if m &&& 0xc7 == 0x05 then
      let r ← Reg.ofNum? ((m >>> 3 &&& 7).toNat + (if b0 == 0x4c then 8 else 0))
      match ← c.field 3 7 with
      | .inl to => pure (.leaX r to)
      | .inr t => if r == .r11 then pure (.leaR11 t) else none
    else if b0 != 0x48 || m >>> 6 != 2 then none
    else
      let base ← if m &&& 7 == 2 then some Reg.rdx else if m &&& 7 == 5 then some Reg.rbp
        else if m &&& 7 == 4 && g 3 == some 0x24 then some Reg.rsp else none
      let disp ← c.toCursor.i32At (if m &&& 7 == 4 then 4 else 3)
      pure (.leaD32 (← Reg.ofNum? (m >>> 3 &&& 7).toNat) base disp)

end XCursor

/-- Reads an extra form at the cursor, checking its encoding is canonical: the form and its
length. The forms of its own come first; otherwise an `Item` (`call`, `jmp rax`, `ret`). -/
def decodeX (c : XCursor) : Option (XItem × Nat) :=
  (do let x ← c.candidate; let n ← c.matchesX x; pure (x, n)) <|>
  (do
    let (i, _) ← decodeItem c.toCursor
    let n ← c.matchesX (.item i)
    pure (.item i, n))

/-! ### The forms' code -/

/-- An OSR entry (`osr.rs` `OsrEntry`): the head's position in the JIT code, and the moves
(`len` bytes from AOT frame offset `from` to JIT frame offset `to`). -/
structure OsrEntry where
  landing : Nat
  moves : List (Int × Int × Nat)
deriving Repr, Inhabited

def nextMultiple (n k : Nat) : Nat := (n + k - 1) / k * k

/-- The probe threshold (`encode.rs` `PROBE_FROM`). -/
def probeFrom : Nat := 4096

/-- One OSR entry's code (`osr_code`'s loop body), position-independent. -/
def osrEntryCode (fAot fJit : Nat) (fp : Bool) : Option OsrEntry → List XItem
  | none => [.item .ret]
  | some e =>
    let d32 (i : Int) : BitVec 32 := BitVec.ofInt 32 i
    let moveCode : List XItem :=
      if e.moves.isEmpty && fAot == fJit then [] else
      let (pre, base) : List XItem × Reg :=
        if fp then ([], .rbp) else ([.leaD32 .rdx .rsp (d32 fAot)], .rdx)
      let scratch := nextMultiple (e.moves.foldl (fun acc (_, _, l) => acc + nextMultiple l 8) 0) 16
      let low := max fAot fJit + scratch
      let grow := low - fAot
      let probe : List XItem :=
        if grow ≥ probeFrom then [.movImm32 .rax (BitVec.ofNat 32 grow), .item (.call .probe)] else []
      let lower : List XItem := if low != fAot then [.leaD32 .rsp base (d32 (-(low : Int)))] else []
      -- Moves of 8, 4, 2, 1 bytes: loads into the scratch area, then stores to the new homes.
      let chunks (len : Nat) : List (Nat × Nat) :=
        (go len 0 len).reverse
      let pass (load : Bool) : List XItem :=
        (e.moves.foldl (fun (acc, k) (fr, to, len) =>
          let code := (chunks len).flatMap fun (done, size) =>
            let (src, dst) : (Reg × Int) × (Reg × Int) :=
              if load then ((base, fr + done), (.rsp, k + done)) else ((.rsp, k + done), (base, to + done))
            [XItem.movRax true size src.1 (d32 src.2), .movRax false size dst.1 (d32 dst.2)]
          (acc ++ code, k + nextMultiple len 8)) (([] : List XItem), (0 : Int))).1
      let raise : List XItem := if low != fJit then [.leaD32 .rsp base (d32 (-(fJit : Int)))] else []
      pre ++ probe ++ lower ++ pass true ++ pass false ++ raise
    [.popRcx] ++ moveCode ++ [.jmpRel (BitVec.ofNat 32 e.landing)]
where
  /-- The chunks of a move of `len` bytes: (offset, size), largest first, in reverse. -/
  go (len done : Nat) : Nat → List (Nat × Nat)
    | 0 => []
    | fuel + 1 =>
      if done ≥ len then [] else
      let left := len - done
      let size := if left ≥ 8 then 8 else if left ≥ 4 then 4 else if left ≥ 2 then 2 else 1
      go len (done + size) fuel ++ [(done, size)]

def xitemsLen (xs : List XItem) : Nat := xs.foldl (fun n x => n + (x.encode 0).1.length) 0

/-- The dispatcher and entries of one function (`osr_code`), placed `at_` bytes into its JIT
code: the forms, from position `at_`. -/
def osrCode (entries : List (Option OsrEntry)) (fAot fJit : Nat) (fp : Bool) (at_ : Nat) :
    List XItem :=
  let dispatch : List XItem := [.leaR11 0, .movsxdR11, .addRaxR11, .item .jmpRax]
  let dlen := xitemsLen dispatch
  let pad := (4 - dlen % 4) % 4
  let table := dlen + pad
  let codes := entries.map (osrEntryCode fAot fJit fp)
  let starts := (codes.foldl (fun (acc, p) c => (acc ++ [p], p + xitemsLen c))
    (([] : List Nat), table + 4 * entries.length)).1
  let pos (n : Nat) : BitVec 32 := BitVec.ofNat 32 (at_ + n)
  [.leaR11 (pos table), .movsxdR11, .addRaxR11, .item .jmpRax] ++
    List.replicate pad (.item .int3) ++
    starts.map (fun s => .item (.tableEntry (pos table) (pos s))) ++
    codes.flatten

/-- Decodes OSR code with `n` entries placed `at_` bytes into the JIT code, its probe calls'
fields at the offsets `probes` (`OsrCode::probes`): the forms, each canonical. -/
def decodeOsr (code : List UInt8) (n at_ : Nat) (probes : List Nat) : Option (List XItem) := do
  let arr := (List.replicate at_ (0 : UInt8) ++ code).toArray
  let rs := (probes.map fun p => (⟨at_ + p, .ref .probe⟩ : XReloc)).toArray
  let cur (p : Nat) : XCursor := { code := arr, pos := p, fields := .relocs rs }
  -- The dispatcher.
  let (d, p) ← (List.range 4).foldlM (fun (acc, p) _ => do
    let (x, k) ← decodeX (cur p)
    pure (acc ++ [x], p + k)) (([] : List XItem), at_)
  let table ← match d with
    | [.leaR11 t, .movsxdR11, .addRaxR11, .item .jmpRax] => some t.toNat
    | _ => none
  let pad := table - p
  if pad ≥ 4 || (table - at_) % 4 != 0 || (List.range pad).any (fun j => arr[p + j]? != some 0xcc) then none
  let entries ← (List.range n).mapM fun k => do
    let t ← (cur (table + 4 * k)).toCursor.tableEntry (BitVec.ofNat 32 table)
    pure (XItem.item (.tableEntry (BitVec.ofNat 32 table) t))
  let rest ← go arr.size (cur (table + 4 * n)) arr.size
  pure (d ++ List.replicate pad (.item .int3) ++ entries ++ rest)
where
  go (size : Nat) (c : XCursor) : Nat → Option (List XItem)
    | 0 => none
    | fuel + 1 =>
      if c.pos ≥ size then some [] else do
      let (x, k) ← decodeX c
      let rest ← go size { c with pos := c.pos + k } fuel
      pure (x :: rest)

/-- The JIT entry prefix (`JIT_ENTRY_PREFIX` bytes before a JIT function's code, which starts
at position 12): `lea r11, [rip + code]; mov [rsp], r11; ret`. -/
def jitEntryPrefix : List XItem := [.leaR11 12, .movRspR11, .item .ret]

/-- The registry constructor (`add_registry_ctor`): `n` images, ELF or PE, `ryo_vm_register`
through its import slot (PE, `register_import`). -/
def registryCtor (n : BitVec 32) (pe registerImport : Bool) : List XItem :=
  if pe then
    [.leaX .rcx .images, .movImm32 .rdx n,
      if registerImport then .jmpMemX .vmRegisterImp else .jmpX .vmRegister]
  else [.leaX .rdi .images, .movImm32 .rsi n, .jmpX .vmRegister]

/-- A function's entry counter stub (`encode.rs`): the record into `r11`, `call [r11 + 8]`
(`JIT_ENTRY_SLOT`), `jmp` back after the check. -/
def entryStub (back : BitVec 32) (long : Bool) : List Item :=
  [.lea .r11 .record, .callR11 8, .branch .always back long]

/-- A loop head's counter stub: the record into `r11`, the head's index into `eax`,
`call [r11 + 16]` (`JIT_OSR_SLOT`), `jmp` back. -/
def headStub (head : BitVec 64) (back : BitVec 32) (long : Bool) : List Item :=
  [.lea .r11 .record, .setReg .rax head, .callR11 16, .branch .always back long]

/-! ### Semantics -/

/-- Where the extra forms run: the address of position 0 of their code, and where their
references live. -/
structure XCtx where
  base : BitVec 64
  addrOf : XRef → BitVec 64

def XCtx.toCtx (c : XCtx) : Ctx := { base := c.base, addrOf := fun r => c.addrOf (.ref r) }

/-- One extra form's effect, `s.rip` at its first byte. -/
def XItem.exec (ctx : XCtx) (x : XItem) (s : State) : Except Fault State :=
  let next := s.rip + BitVec.ofNat 64 (x.encode 0).1.length
  let s0 := s.jump next
  match x with
  | .item i => i.exec ctx.toCtx s
  | .popRcx => let (v, s1) := s0.pop; pure (s1.setReg .rcx v)
  | .movRax load size base disp =>
    let a := s0.reg base + disp.signExtend 64
    let w : W := if size == 1 then .b else if size == 2 then .w else if size == 4 then .d else .q
    if load then pure (s0.setRegW w .rax (s0.memW w a)) else pure (s0.setMemW w a (s0.regW w .rax))
  | .leaD32 dst base disp => pure (s0.setReg dst (s0.reg base + disp.signExtend 64))
  | .movImm32 r imm => pure (s0.setReg r (imm.setWidth 64))
  | .leaR11 t => pure (s0.setReg .r11 (ctx.base + t.setWidth 64))
  | .movsxdR11 =>
    let a := s0.reg .r11 + (s0.reg .rax <<< 2)
    pure (s0.setReg .rax ((s0.memW .d a).signExtend 64))
  | .addRaxR11 =>
    let (r, f) := addF (s0.reg .rax) (s0.reg .r11)
    pure ((s0.setReg .rax r).setFlags f)
  | .jmpRel t => pure (s0.jump (ctx.base + t.setWidth 64))
  | .movRspR11 => pure (s0.setMem s0.rsp 8 (s0.reg .r11).toNat)
  | .leaX r to => pure (s0.setReg r (ctx.addrOf to))
  | .jmpX to => pure (s0.jump (ctx.addrOf to))
  | .jmpMemX to => pure (s0.jump (s0.mem.read64 (ctx.addrOf to)))

end Ryo.X86
