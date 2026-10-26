/-
Ryo.Vm.Asm — the pieces of `vm/bytecode/src/asm` the decoder shares with the encoder, ported:

- `DroppedStore` (`asm/encode.rs`; `Mode` and `CallSite` are `Ryo.Obj`'s);
- return kinds and argument registers (`ret_parts`, `ret_kind`, `ArgReg`, `param_reg`);
- the fixed sequences: `prologue`, `epilogue`, `fp_item`, `int_arg`, `ret_loads`,
  `result_stores`, `arg_store`;
- the inline sequences and the register cache (`asm/inline.rs`): `Class`, `sequence`,
  `classify`, `decodeInline`, `Cache` (`emit`, `unemit`, `update`).

Rust's `u32`/`i32` arithmetic is kept: slots and displacements are `BitVec 32`, immediates
`BitVec 64`, and sums wrap where Rust's wrap, and fail where Rust's are checked (`mov.w128`'s
high halves).
-/
import Ryo.Vm.R.Syntax
import Ryo.X86.Decode
import Ryo.Obj.Reloc

set_option linter.constructorNameAsVariable false

namespace Ryo.Vm.Asm

open Ryo.X86 Ryo.Vm.R

/-- How the machine code is generated (`asm::Mode`), and a call that may unwind
(`asm::CallSite`): the object reader's types. -/
abbrev Mode := Ryo.Obj.Mode
abbrev CallSite := Ryo.Obj.CallSite

/-- The registers inline sequences compute in (`inline::POOL`). -/
def pool : List Reg := [.rax, .rdx, .rsi, .rdi, .r8, .r9, .r10, .r11]

def poolIdx (r : Reg) : Option Nat := pool.idxOf? r

/-- A store of an inline sequence the encoder dropped (`asm::DroppedStore`): the sequence ends
at byte `at_` without it. -/
structure DroppedStore where
  at_ : Nat
  item : Item
deriving DecidableEq, Repr, Inhabited

def widthOf (size : Nat) : W :=
  match size with
  | 1 => .b
  | 2 => .w
  | 4 => .d
  | _ => .q

/-- `DroppedStore::from_parts`: `mov [fp + frameOffset], reg` of `size` bytes, the register by
its x86 number, one the inline sequences compute in. -/
def DroppedStore.ofParts? (at_ : Nat) (frameOffset : BitVec 32) (size reg : Nat) :
    Option DroppedStore := do
  if !(size == 1 || size == 2 || size == 4 || size == 8) then none
  let r ← Reg.ofNum? reg
  if !pool.contains r then none
  pure ⟨at_, .st (widthOf size) r (M.frame frameOffset)⟩

/-- `DroppedStore::parts`. -/
def DroppedStore.parts (d : DroppedStore) : BitVec 32 × Nat × Nat :=
  match d.item with
  | .st w r m => (m.disp, w.bits / 8, r.num)
  | _ => (0, 0, 0)

/-! ### Return kinds and argument registers -/

/-- `RetPart`. -/
structure RetPart where
  xmm : Bool
  size : Nat
  off : Nat
deriving DecidableEq, Repr, Inhabited

def RetPart.bits (p : RetPart) : Nat := p.size ||| (if p.xmm then 32 else 0)

/-- `ret_kind` (of at most two parts). -/
def retKind : List RetPart → Nat
  | [] => 0
  | [a] => u32 a.bits
  | a :: b :: _ => u32 (a.bits ||| (b.bits <<< 8) ||| (b.off <<< 16))

/-- `ret_parts`. -/
def retParts (k : Nat) (load : Bool) : Option (Option RetPart × Option RetPart) := do
  if k >>> 24 != 0 then none
  let part (b off : Nat) : Option (Option RetPart) :=
    if b == 0 then some none else
    let xmm := b &&& 0x20 != 0
    let size := b &&& 0x1f
    let ok := if xmm then size == 2 || size == 4 || size == 8 || size == 16
      else if load then size == 1 || size == 2 || size == 4 || size == 8
      else 1 ≤ size && size ≤ 8
    if ok then some (some ⟨xmm, size, off⟩) else none
  -- `b & !0x3f == 0`, on a byte: bits 6 and 7 clear.
  let part' (b off : Nat) : Option (Option RetPart) :=
    if b &&& 0xc0 != 0 then none else part b off
  let a ← part' (k &&& 0xff) 0
  let b ← part' (k >>> 8 &&& 0xff) (k >>> 16 &&& 0xff)
  match a, b with
  | none, some _ => none
  | none, none => if k != 0 then none else some (a, b)
  | some a', some b' => if b'.off < a'.size || b'.off + b'.size > 16 then none else some (a, b)
  | some _, none => if k >>> 16 != 0 then none else some (a, b)

/-- `part_regs`: the parts with their registers (`rax`, `rdx`; `xmm0`, `xmm1`). -/
def partRegs (k : Nat) (load : Bool) : List (RetPart × Reg × Nat) :=
  match retParts k load with
  | none => []
  | some (a, b) =>
    let ps := [a, b].filterMap id
    (ps.foldl (fun (acc, g, x) p =>
      (acc ++ [(p, (if g == 0 then Reg.rax else Reg.rdx), x)],
        if p.xmm then g else g + 1, if p.xmm then x + 1 else x)) ([], 0, 0)).1

/-- `ArgReg`. -/
structure ArgReg where
  xmm : Bool
  size : Nat
  index : Nat
deriving DecidableEq, Repr, Inhabited

def ArgReg.word (a : ArgReg) : Nat := u32 (a.size ||| (if a.xmm then 32 else 0) ||| (a.index <<< 8))

/-- `ArgReg::of`. -/
def ArgReg.of? (r : Nat) (exact : Bool) : Option ArgReg :=
  let a : ArgReg := ⟨r &&& 0x20 != 0, r &&& 0x1f, r >>> 8⟩
  let int := if exact then 1 ≤ a.size && a.size ≤ 8
    else a.size == 1 || a.size == 2 || a.size == 4 || a.size == 8
  let ok := if a.xmm then (a.size == 2 || a.size == 4 || a.size == 8 || a.size == 16) && a.index < 8
    else int && a.index < 6
  if ok && r &&& 0xc0 == 0 && a.word == r then some a else none

/-! ### Fixed sequences -/

/-- `int_arg`: `rdi rsi rdx rcx r8 r9`, PE `rcx rdx r8 r9`. -/
def intArg (pe : Bool) (i : Nat) : Reg :=
  if pe then [Reg.rcx, .rdx, .r8, .r9].getD i .rax else [Reg.rdi, .rsi, .rdx, .rcx, .r8, .r9].getD i .rax

/-- The integer argument register index of `r` (`int_index`). -/
def intIndex (r : Reg) (m : Mode) : Option Nat :=
  (List.range (if m.pe then 4 else 6)).find? fun i => intArg m.pe i == r

def frameAt (base : BitVec 32) (off : Nat) : M := M.frame (base + BitVec.ofNat 32 off)

/-- `sse_store`. -/
def sseStore (size x : Nat) (m : M) : List Item :=
  if size == 2 then [.movd false x .r11, .st .w .r11 m] else [.sse true size x m]

/-- `int_store`: in pieces of 4, 2 and 1 bytes, shifting `r` down between them, unless `size`
is 1, 2, 4 or 8. -/
def intStore (size : Nat) (r : Reg) (m : M) : List Item :=
  if size == 1 || size == 2 || size == 4 || size == 8 then [.st (widthOf size) r m] else
  ([4, 2, 1].foldl (fun (out, done, prev) c =>
    if size - done ≥ c then
      let sh : List Item := if prev != 0 then [.shift .shr .q r (BitVec.ofNat 8 (8 * prev))] else []
      (out ++ sh ++ [.st (widthOf c) r ⟨m.base, m.disp + BitVec.ofNat 32 done⟩], done + c, c)
    else (out, done, prev)) (([] : List Item), 0, 0)).1

/-- `ret_loads`. -/
def retLoads (k : Nat) (s : BitVec 32) : List Item :=
  (partRegs k true).flatMap fun (p, r, x) =>
    let m := frameAt s p.off
    if !p.xmm then [.ld (widthOf p.size) false r m]
    else if p.size == 2 then [.ld .w false .r11 m, .movd true x .r11]
    else [.sse false p.size x m]

/-- `result_stores`. -/
def resultStores (k : Nat) (d : BitVec 32) : List Item :=
  (partRegs k false).flatMap fun (p, r, x) =>
    let m := frameAt d p.off
    if p.xmm then sseStore p.size x m else intStore p.size r m

/-- `arg_store`. -/
def argStore (a : ArgReg) (d : BitVec 32) (pe : Bool) : List Item :=
  if a.xmm then sseStore a.size a.index (M.frame d) else intStore a.size (intArg pe a.index) (M.frame d)

/-- `PROBE_FROM`. -/
def probeFrom : Nat := 4096

/-- `prologue` (`u32` arithmetic wrapping). -/
def prologue (frameSize : Nat) (m : Mode) : List Item :=
  let (pre, alloc) : List Item × Nat :=
    if m.pe then ([.winPrologue], u32 (frameSize + 2 ^ 32 - 16))
    else if m.framePointer then ([.pushRbp, .mov .rbp .rsp], frameSize)
    else ([], u32 (frameSize + 8))
  let probe : List Item :=
    if frameSize ≥ probeFrom then [.setReg .rax (BitVec.ofNat 64 alloc), .call .probe] else []
  pre ++ probe ++ (if alloc != 0 then [.subRsp (BitVec.ofNat 32 alloc)] else [])

/-- `epilogue`. -/
def epilogue (frameSize : Nat) (m : Mode) : Item :=
  if m.pe then .winEpilogue
  else if m.framePointer then .leave
  else .addRsp (BitVec.ofNat 32 (frameSize + 8))

/-- `Frame::fp`: `reg = fp` as the decoder reads it (`mov reg, rbp`, or `lea reg, [rsp + F]`
read as `[rbp + 0]`). -/
def fpItem (reg : Reg) (m : Mode) : Item :=
  if m.framePointer then .mov reg .rbp else .leaM reg (M.frame 0)

/-! ### Items -/

/-- `Item::map_regs`. -/
def mapRegs (f : Reg → Reg) : Item → Item
  | .ld w sx d m => .ld w sx (f d) ⟨f m.base, m.disp⟩
  | .st w s m => .st w (f s) ⟨f m.base, m.disp⟩
  | .stImm w m i => .stImm w ⟨f m.base, m.disp⟩ i
  | .leaM d m => .leaM (f d) ⟨f m.base, m.disp⟩
  | .alu o w r rm => .alu o w (f r) (mapRm f rm)
  | .aluImm o w rm i => .aluImm o w (mapRm f rm) i
  | .imul w r rm => .imul w (f r) (mapRm f rm)
  | .imulImm w r rm i => .imulImm w (f r) (mapRm f rm) i
  | .shift o w r a => .shift o w (f r) a
  | .setcc c m => .setcc c ⟨f m.base, m.disp⟩
  | .testM8 m => .testM8 ⟨f m.base, m.disp⟩
  | .setReg r v => .setReg (f r) v
  | .mulQ rm => .mulQ (mapRm f rm)
  | .lea r to => .lea (f r) to
  | .loadRip r to => .loadRip (f r) to
  | it => it
where
  mapRm (f : Reg → Reg) : Rm → Rm
    | .reg r => .reg (f r)
    | .mem m => .mem ⟨f m.base, m.disp⟩

/-- `Item::ends_inline`. -/
def endsInline : Item → Bool
  | .st _ .rcx m => m.base != .rbp
  | .st .. | .stImm .. | .setcc .. => true
  | _ => false

/-- `Item::is_inline`. -/
def isInline : Item → Bool
  | .ld .. | .st .. | .stImm .. | .leaM .. | .alu .. | .aluImm .. | .imul .. | .imulImm ..
  | .shift .. | .setcc .. | .testM8 .. | .setccCl .. | .mulQ .. | .lea .. | .loadRip .. => true
  | .setReg r _ => r != .rsp && r != .rbp
  | _ => false

/-- `Item::imm`: the immediate, sign-extended. -/
def itemImm : Item → Option (BitVec 64)
  | .stImm _ _ i | .aluImm _ _ _ i | .imulImm _ _ _ i => some (i.signExtend 64)
  | .shift _ _ _ a => some (a.setWidth 64)
  | .setReg _ v => some v
  | _ => none

/-- `Item::frame_read`. -/
def frameRead : Item → Option (M × Nat)
  | .ld w _ _ m | .alu _ w _ (.mem m) | .aluImm _ w (.mem m) _ | .imul w _ (.mem m)
  | .imulImm w _ (.mem m) _ => if m.base == .rbp then some (m, w.bits / 8) else none
  | .testM8 m => if m.base == .rbp then some (m, 1) else none
  | .mulQ (.mem m) => if m.base == .rbp then some (m, 8) else none
  | _ => none

/-- `Item::frame_write`. -/
def frameWrite : Item → Option (M × Nat)
  | .st w _ m | .stImm w m _ => if m.base == .rbp then some (m, w.bits / 8) else none
  | .setcc _ m => if m.base == .rbp then some (m, 1) else none
  | _ => none

/-! ### Inline sequences (`asm/inline.rs`) -/

inductive Class
  | mov (w : W) | mov128 | imm (w : W) | addr
  /-- `addr.const`: `lea` of the constant (or data area) address. -/
  | addrConst
  /-- `addr.sym`: the symbol slot's value, loaded rip-relative. -/
  | addrSym
  /-- `addr.sym.ind`: the slot's value, then the import slot it points to. -/
  | addrSymInd
  | ptrAdd | ptrIndex | load (w : W) | store (w : W)
  | bin (op : Alu) (w : W) | binImm (op : Alu) (w : W) | mul (w : W) | mulImm (w : W)
  | shiftImm (sh : Sh) (w : W) | cmp (c : Cond) (w : W) | cmpImm (c : Cond) (w : W) | br
  | brCmp (c : Cond) (w : W) | brCmpImm (c : Cond) (w : W)
  /-- `add.ovf`/`sub.ovf`, signed or not: the result and its overflow flag. -/
  | ovf (op : Alu) (signed : Bool) (w : W)
  /-- `mul.ovf`, signed or not. -/
  | mulOvf (signed : Bool) (w : W)
  /-- A zero or sign (`sx`) extension, or a truncation. -/
  | ext (src dst : W) (sx : Bool)
deriving DecidableEq, Repr, Inhabited

/-- `Class::key`: the conditions dropped. -/
def Class.key : Class → Class
  | .cmp _ w => .cmp .z w
  | .cmpImm _ w => .cmpImm .z w
  | .brCmp _ w => .brCmp .z w
  | .brCmpImm _ w => .brCmpImm .z w
  | .ovf op _ w => .ovf op false w
  | .mulOvf _ w => .mulOvf false w
  | c => c

def widthName : String → Option W
  | "w8" => some .b | "w16" => some .w | "w32" => some .d | "w64" => some .q | _ => none

def aluName : String → Option Alu
  | "add" => some .add | "sub" => some .sub | "and" => some .and | "or" => some .or
  | "xor" => some .xor | _ => none

/-- `inline::class`, from the opcode's mnemonic split at its dots. -/
def classOfParts : List String → Option Class
  | ["add", "ovf", s, w] => .ovf .add (s == "s") <$> widthName w
  | ["sub", "ovf", s, w] => .ovf .sub (s == "s") <$> widthName w
  | ["mul", "ovf", s, w] => .mulOvf (s == "s") <$> widthName w
  | ["zext", a, b] => do
    let (a, b) := (← widthName a, ← widthName b)
    if a.bits < b.bits then some (.ext a b false) else none
  | ["sext", a, b] => do
    let (a, b) := (← widthName a, ← widthName b)
    if a.bits < b.bits then some (.ext a b true) else none
  | ["trunc", a, b] => do
    let (a, b) := (← widthName a, ← widthName b)
    if a.bits > b.bits then some (.ext a b false) else none
  | ["mov", "w128"] => some .mov128
  | ["mov", w] => .mov <$> widthName w
  | ["imm", w] => .imm <$> widthName w
  | ["load", w] => .load <$> widthName w
  | ["store", w] => .store <$> widthName w
  | ["addr"] => some .addr
  | ["addr", "const"] => some .addrConst
  | ["addr", "sym"] => some .addrSym
  | ["addr", "sym", "ind"] => some .addrSymInd
  | ["ptr", "add"] => some .ptrAdd
  | ["ptr", "index"] => some .ptrIndex
  | ["br"] => some .br
  | ["mul", w] => .mul <$> widthName w
  | ["eq", w] => .cmp .z <$> widthName w
  | ["ne", w] => .cmp .nz <$> widthName w
  | ["mul", "imm", w] => .mulImm <$> widthName w
  | ["shl", "imm", w] => .shiftImm .shl <$> widthName w
  | ["eq", "imm", w] => .cmpImm .z <$> widthName w
  | ["ne", "imm", w] => .cmpImm .nz <$> widthName w
  | ["shr", "s", "imm", w] => .shiftImm .sar <$> widthName w
  | ["shr", "u", "imm", w] => .shiftImm .shr <$> widthName w
  | ["br", "eq", w] => .brCmp .z <$> widthName w
  | ["br", "lt", s, w] => do
    let c ← match s with | "s" => some Cond.l | "u" => some Cond.b | _ => none
    .brCmp c <$> widthName w
  | ["br", "eq", "imm", w] => .brCmpImm .z <$> widthName w
  | ["br", o, s, "imm", w] => do
    let c ← match o, s with
      | "lt", "s" => some Cond.l | "lt", "u" => some Cond.b
      | "gt", "s" => some Cond.g | "gt", "u" => some Cond.a | _, _ => none
    .brCmpImm c <$> widthName w
  | [o, s, "imm", w] => do
    let c ← match o, s with
      | "lt", "s" => some Cond.l | "lt", "u" => some Cond.b | "le", "s" => some Cond.le
      | "le", "u" => some Cond.be | "gt", "s" => some Cond.g | "gt", "u" => some Cond.a
      | "ge", "s" => some Cond.ge | "ge", "u" => some Cond.ae | _, _ => none
    .cmpImm c <$> widthName w
  | [o, "imm", w] => do .binImm (← aluName o) <$> widthName w
  | [o, s, w] => do
    let c ← match o, s with
      | "lt", "s" => some Cond.l | "lt", "u" => some Cond.b | "le", "s" => some Cond.le
      | "le", "u" => some Cond.be | _, _ => none
    .cmp c <$> widthName w
  | [o, w] => do .bin (← aluName o) <$> widthName w
  | _ => none

/-- `inline::class`, from the opcode's mnemonic. -/
def classOfMnemonic (mn : String) : Option Class := classOfParts (mn.splitOn ".")

def classOf (op : Full.Opcode) : Option Class := classOfMnemonic op.mnemonic

/-- The opcodes with an inline form, in order, with their class. -/
def inlineOps : List (Full.Opcode × Class) :=
  Full.all.filterMap fun op => (classOf op).map (op, ·)

/-- `fits`: a sign-extended 32-bit value. -/
def fits (v : BitVec 64) : Bool := (v.setWidth 32).signExtend 64 == v

/-- `w.sext(x) as i32`. -/
def sextI32 (w : W) (x : BitVec 64) : BitVec 32 :=
  match w with
  | .b => (x.setWidth 8).signExtend 32
  | .w => (x.setWidth 16).signExtend 32
  | _ => x.setWidth 32

def R : Reg := .rax
def C : Reg := .rcx

def ld (w : W) (m : M) : Item := .ld w false R m
def st (w : W) (m : M) : Item := .st w R m
def Mrax (d : BitVec 32) : M := ⟨.rax, d⟩

/-- `flag`: an overflow flag's store to `o`, `setcc cl; mov [o], cl`. -/
def flagSeq (c : Cond) (o : M) : List Item := [.setccCl c, .st .b C o]

def cmpImmSeq (w : W) (a : M) (x : BitVec 64) : List Item :=
  if w == .q && !fits x then [ld .q a, .setReg C x, .alu .cmp w R (.reg C)]
  else [.aluImm .cmp w (.mem a) (sextI32 w x)]

/-- `inline::sequence`: the inline sequence of `op` (class `c`) with operands `ops`, and its
branch condition. `none` if `op` has no inline form for these operands (or they aren't of its
kinds). -/
def sequence {T : Type} (c : Class) (ops : List (Opnd T)) : Option (List Item × Option Cond) := do
  let slot (i : Nat) : Option M := match ops[i]? with
    | some (.slot s) => some (M.frame s)
    | _ => none
  let imm (i : Nat) : Option (BitVec 64) := match ops[i]? with
    | some (.imm v) => some v
    | _ => none
  let cond (i : Nat) (c : Cond) : Option Cond := match ops[i]? with
    | some (.neg n) => some (if n then c.not else c)
    | _ => none
  match c with
  | .mov w => pure ([ld w (← slot 1), st w (← slot 0)], none)
  | .mov128 =>
    let s1 ← slot 1
    let s0 ← slot 0
    -- The high halves, 8 bytes up (none at the top of the `i32` range).
    if s1.disp.toInt + 8 ≥ 2 ^ 31 || s0.disp.toInt + 8 ≥ 2 ^ 31 then none
    let hi (m : M) : M := M.frame (m.disp + 8)
    pure ([ld .q s1, .ld .q false C (hi s1), .st .q C (hi s0), st .q s0], none)
  | .imm w =>
    let x ← imm 1
    let s0 ← slot 0
    if w != .q || fits x then pure ([.stImm w s0 (sextI32 w x)], none)
    else pure ([.setReg R x, st .q s0], none)
  | .addr => pure ([.leaM R (← slot 1), st .q (← slot 0)], none)
  | .addrConst =>
    let to ← match (ops[1]? : Option (Opnd T)) with
      | some (.const k) => some (Ref.const k)
      | some (.data d) => some (Ref.data d)
      | _ => none
    pure ([.lea R to, st .q (← slot 0)], none)
  | .addrSym | .addrSymInd =>
    let s ← match (ops[1]? : Option (Opnd T)) with
      | some (.sym s) => some s
      | _ => none
    let ind : List Item := if c == .addrSymInd then [ld .q (Mrax 0)] else []
    pure ([.loadRip R (.sym s)] ++ ind ++ [st .q (← slot 0)], none)
  | .ptrAdd =>
    let x ← imm 2
    if !fits x then none
    pure ([ld .q (← slot 1), .leaM R (Mrax (x.setWidth 32)), st .q (← slot 0)], none)
  | .ptrIndex =>
    let s ← imm 3
    if s.toNat > 0x7fff_ffff then none
    pure ([ld .q (← slot 1), .imulImm .q C (.mem (← slot 2)) (s.setWidth 32), .alu .add .q R (.reg C),
      st .q (← slot 0)], none)
  | .load w =>
    let (p, k) ← match (ops[1]? : Option (Opnd T)) with
      | some (.mem p k) => some (p, k)
      | _ => none
    pure ([ld .q (M.frame p), ld w (Mrax k), st w (← slot 0)], none)
  | .store w =>
    let (p, k) ← match (ops[0]? : Option (Opnd T)) with
      | some (.mem p k) => some (p, k)
      | _ => none
    pure ([ld .q (M.frame p), .ld w false C (← slot 1), .st w C (Mrax k)], none)
  | .bin op w => pure ([ld w (← slot 1), .alu op w R (.mem (← slot 2)), st w (← slot 0)], none)
  | .binImm op w =>
    let x ← imm 2
    let mid : List Item := match w with
      | .q => if !fits x then [.setReg C x, .alu op w R (.reg C)]
        else [.aluImm op w (.reg R) (sextI32 w x)]
      | .b => [.aluImm op w (.reg R) (sextI32 w x)]
      | _ => [.aluImm op .d (.reg R) (x.setWidth 32)]
    pure ([ld w (← slot 1)] ++ mid ++ [st w (← slot 0)], none)
  | .mul w =>
    let s1 ← slot 1
    let s2 ← slot 2
    let body : List Item := match w with
      | .d | .q => [ld w s1, .imul w R (.mem s2)]
      | _ => [ld w s1, .ld w false C s2, .imul .d R (.reg C)]
    pure (body ++ [st w (← slot 0)], none)
  | .mulImm w =>
    let x ← imm 2
    let s1 ← slot 1
    let body : List Item := match w with
      | .q => if !fits x then [ld w s1, .setReg C x, .imul w R (.reg C)]
        else [.imulImm w R (.mem s1) (x.setWidth 32)]
      | .d => [.imulImm w R (.mem s1) (x.setWidth 32)]
      | _ => [ld w s1, .imulImm .d R (.reg R) (x.setWidth 32)]
    pure (body ++ [st w (← slot 0)], none)
  | .shiftImm sh w =>
    let x ← imm 2
    if x.toNat ≥ w.bits then none
    let sx := sh == .sar && (w == .b || w == .w)
    let sw := if w == .q then W.q else W.d
    pure ([.ld w sx R (← slot 1), .shift sh sw R (x.setWidth 8), st w (← slot 0)], none)
  | .cmp c w =>
    pure ([ld w (← slot 1), .alu .cmp w R (.mem (← slot 2)), .setcc c (← slot 0)], none)
  | .cmpImm c w => pure (cmpImmSeq w (← slot 1) (← imm 2) ++ [.setcc c (← slot 0)], none)
  | .br => pure ([.testM8 (← slot 0)], some (← cond 1 .nz))
  | .brCmp c w => pure ([ld w (← slot 0), .alu .cmp w R (.mem (← slot 1))], some (← cond 2 c))
  | .brCmpImm c w => pure (cmpImmSeq w (← slot 0) (← imm 1), some (← cond 2 c))
  -- `d, o, a, b`: the result in `rax`, the flag through `cl`, stored before the result.
  | .ovf op signed w =>
    let flag := flagSeq (if signed then .o else .b) (← slot 1)
    pure ([ld w (← slot 2), .alu op w R (.mem (← slot 3))] ++ flag ++ [st w (← slot 0)], none)
  | .mulOvf signed w =>
    let a ← slot 2
    let b ← slot 3
    let (body, c) : List Item × Cond := match signed, w with
      | true, .d | true, .q => ([ld w a, .imul w R (.mem b)], .o)
      | false, .q => ([ld w a, .mulQ (.mem b)], .b)
      | false, .d =>
        ([ld w a, .ld w false C b, .imul .q R (.reg C), .setReg C 0xffff_ffff,
          .alu .cmp .q R (.reg C)], .a)
      | _, _ =>
        let max : BitVec 32 := if w == .b then 0xff else 0xffff
        let pre := [Item.ld w signed R a, .ld w signed C b, .imul .d R (.reg C)]
        let chk : List Item := if signed
          then [.leaM C (Mrax (max / 2 + 1)), .aluImm .cmp .d (.reg C) max]
          else [.aluImm .cmp .d (.reg R) max]
        (pre ++ chk, .a)
    pure (body ++ flagSeq c (← slot 1) ++ [st w (← slot 0)], none)
  | .ext src dst sx =>
    let s ← slot 1
    let body : List Item := if sx && dst == .q then
        let n : BitVec 8 := BitVec.ofNat 8 (64 - src.bits)
        [ld src s, .shift .shl .q R n, .shift .sar .q R n]
      else [.ld src sx R s]
    pure (body ++ [st dst (← slot 0)], none)

/-- `inline::classify`: the class key of the items, ending in a branch if `br`. -/
def classify (items : List Item) (br : Bool) : Option Class :=
  let z := Cond.z
  let frame (m : M) : Bool := m.base == .rbp
  -- An overflow op: its flag, then the result's store.
  if items.any (fun | .setccCl _ => true | _ => false) then
    match items.getLast? with
    | some (.st w ..) =>
      if items.any (fun | .mulQ _ | .imul .. => true | _ => false) then some (.mulOvf false w)
      else (items.findSome? fun | .alu op .. => some op | _ => none).map (.ovf · false w)
    | _ => none
  else if br then
    match items with
    | [.testM8 _] => some .br
    | [.ld w .., .alu .cmp _ _ (.mem _)] => some (.brCmp z w)
    | [.aluImm .cmp w ..] | [.ld .., .setReg .., .alu .cmp w ..] => some (.brCmpImm z w)
    | _ => none
  else
    match items with
    | [.ld w .., .alu .cmp _ _ (.mem _), .setcc ..] => some (.cmp z w)
    | [.aluImm .cmp w .., .setcc ..] | [.ld .., .setReg .., .alu .cmp w .., .setcc ..] =>
      some (.cmpImm z w)
    | [.stImm w ..] => some (.imm w)
    | [.setReg .., .st ..] => some (.imm .q)
    | [.ld w sx _ _, .st t _ m] =>
      if frame m then (if !sx && w == t then some (.mov w) else some (.ext w t sx)) else rest items
    | [.ld w .., .shift .shl .., .shift .sar .., .st t ..] => some (.ext w t true)
    | _ => rest items
where
  rest (items : List Item) : Option Class :=
    let frame (m : M) : Bool := m.base == .rbp
    match items with
    | [.ld .., .ld _ _ .rcx a, .st _ .rcx b, .st _ _ m] =>
      if frame a && frame b && frame m then some .mov128 else rest2 items
    | _ => rest2 items
  rest2 (items : List Item) : Option Class :=
    let frame (m : M) : Bool := m.base == .rbp
    match items with
    | [.leaM .., .st ..] => some .addr
    | [.lea _ (.const _), .st ..] | [.lea _ (.data _), .st ..] => some .addrConst
    | [.loadRip _ (.sym _), .st ..] => some .addrSym
    | [.loadRip _ (.sym _), .ld .., .st ..] => some .addrSymInd
    | [.ld .., .leaM .., .st ..] => some .ptrAdd
    | [.ld .., .imulImm .., .alu .., .st ..] => some .ptrIndex
    | [.ld .., .ld _ _ _ m1, .st w _ m] =>
      if !frame m then some (.store w) else if !frame m1 then some (.load w) else rest3 items
    | _ => rest3 items
  rest3 (items : List Item) : Option Class :=
    match items with
    | [.ld .., .alu op _ _ (.mem _), .st w ..] => some (.bin op w)
    | [.ld .., .aluImm op .., .st w ..] | [.ld .., .setReg .., .alu op .., .st w ..] =>
      some (.binImm op w)
    | [.ld .., .imul _ _ (.mem _), .st w ..] | [.ld .., .ld .., .imul .., .st w ..] => some (.mul w)
    | [.imulImm .., .st w ..] | [.ld .., .imulImm .., .st w ..] | [.ld .., .setReg .., .imul .., .st w ..] =>
      some (.mulImm w)
    | [.ld .., .shift op .., .st w ..] => some (.shiftImm op w)
    | _ => none

/-- The search of `decodeInline`: the instruction, and its class. -/
def decodeInlineSearch (items : List Item) (branch : Option (Cond × Nat)) :
    Option (Full.Opcode × List (Opnd Nat) × Class) := do
  let key ← classify items branch.isSome
  let frame : List (BitVec 32) :=
    items.filterMap fun it => (it.mem?.filter (·.base == .rbp)).map (·.disp)
  let rax : Option (BitVec 32) :=
    (items.filterMap fun it => it.mem?).find? (·.base == .rax) |>.map (·.disp)
  let imm : BitVec 64 := ((items.findSome? itemImm) <|> (rax.map (·.signExtend 64))).getD 0
  let rip : Option Ref := items.findSome? fun
    | .lea _ to | .loadRip _ to => some to
    | _ => none
  for (op, cls) in inlineOps do
    if cls.key != key then continue
    let info := op.info
    let mut f := frame
    let mut ops : Array (Opnd Nat) := #[]
    for o in info.operands do
      match o.kind with
      | .slot =>
        if o.name == "d" then ops := ops.push (.slot (← frame.getLast?))
        -- An overflow flag, stored before the result.
        else if o.name == "o" then
          if frame.length < 2 then none
          ops := ops.push (.slot (← frame[frame.length - 2]?))
        else
          let s ← f.head?
          f := f.tail
          ops := ops.push (.slot s)
      | .mem =>
        let s ← f.head?
        f := f.tail
        ops := ops.push (.mem s (← rax))
      | .u8 => ops := ops.push (.imm (imm.setWidth 8 |>.setWidth 64))
      | .u16 => ops := ops.push (.imm (imm.setWidth 16 |>.setWidth 64))
      | .u32 => ops := ops.push (.imm (imm.setWidth 32 |>.setWidth 64))
      | .u64 | .i64 => ops := ops.push (.imm imm)
      | .neg => ops := ops.push (.neg false)
      | .target => ops := ops.push (.target (← branch).2)
      | .abs =>
        match ← rip with
        | .const k => ops := ops.push (.const k)
        | .data d => ops := ops.push (.data d)
        | _ => none
      | .sym =>
        match ← rip with
        | .sym s => ops := ops.push (.sym s)
        | _ => none
      | _ => none
    let negAt := info.operands.findIdx? (·.name == "neg")
    for neg in [false, true] do
      match negAt with
      | some i => ops := ops.set! i (.neg neg)
      | none => if neg then break
      if let some (v, b) := sequence cls ops.toList then
        if v == items && b == branch.map (·.1) then return (op, ops.toList, cls)
  none

/-- `inline::decode`: the instruction an inline sequence encodes, targets byte positions. The
operands come from the frame displacements in order (`d` last), the `rax` displacement, the
immediate, and the rip item's `Ref` (`addr.const`'s `Abs`, `addr.sym`'s `Sym`).

The search's result is checked again (`(op, cls)` an inline opcode and its class, whose
sequence for the operands is `items` with the branch's condition): the search can't return
anything else, but the check makes that a fact `decodeInline_spec` states without reasoning
about the search's loops. -/
def decodeInline (items : List Item) (branch : Option (Cond × Nat)) :
    Option (Full.Opcode × List (Opnd Nat)) := do
  let (op, ops, cls) ← decodeInlineSearch items branch
  if inlineOps.contains (op, cls) && sequence cls ops == some (items, branch.map (·.1)) then
    some (op, ops)
  else none

theorem decodeInline_spec {items : List Item} {branch : Option (Cond × Nat)} {op : Full.Opcode}
    {ops : List (Opnd Nat)} (h : decodeInline items branch = some (op, ops)) :
    ∃ cls, (op, cls) ∈ inlineOps ∧ sequence cls ops = some (items, branch.map (·.1)) := by
  unfold decodeInline at h
  cases hs : decodeInlineSearch items branch with
  | none => simp [hs] at h
  | some r =>
    obtain ⟨op', ops', cls⟩ := r
    simp only [hs, bind, Option.bind_some] at h
    split at h
    · rename_i hc
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      simp only [Bool.and_eq_true, List.contains_iff_mem, beq_iff_eq] at hc
      exact ⟨cls, hc.1, hc.2⟩
    · cases h

/-! ### The register cache (`inline::Cache`) -/

structure Entry where
  slot : Option (BitVec 32 × W) := none
  zx : Option W := none
  used : Nat := 0
deriving DecidableEq, Repr, Inhabited

structure Cache where
  regs : Array Entry := Array.replicate 8 {}
  tick : Nat := 0
deriving DecidableEq, Repr, Inhabited

def bytes (w : W) : Nat := w.bits / 8

/-- Whether the `n`-byte range at `a` overlaps the `m`-byte one at `b` (wrapping). -/
def overlaps (a : BitVec 32) (n : Nat) (b : BitVec 32) (m : Nat) : Bool :=
  (b - a).toNat < n || (a - b).toNat < m

/-- `read_operand`. -/
def readOperand : Item → Option (M × W)
  | .alu _ w _ (.mem m) | .aluImm .cmp w (.mem m) _ | .imul w _ (.mem m) | .imulImm w _ (.mem m) _ =>
    if m.base == .rbp then some (m, w) else none
  | .mulQ (.mem m) => if m.base == .rbp then some (m, .q) else none
  | _ => none

/-- `with_rm`. -/
def withRm (it : Item) (rm : Rm) : Item :=
  match it with
  | .alu op w r _ => .alu op w r rm
  | .aluImm op w _ i => .aluImm op w rm i
  | .imul w r _ => .imul w r rm
  | .imulImm w r _ i => .imulImm w r rm i
  | .mulQ _ => .mulQ rm
  | it => it

/-- `read_reg`. -/
def readReg : Item → Option Reg
  | .alu _ _ _ (.reg r) | .aluImm .cmp _ (.reg r) _ | .imul _ _ (.reg r) | .imulImm _ _ (.reg r) _
  | .mulQ (.reg r) => some r
  | _ => none

namespace Cache

def find (c : Cache) (m : M) (w : W) (exact : Bool) : Option Nat :=
  if m.base != .rbp then none else
  c.regs.findIdx? fun e => match e.slot with
    | some (s, sw) => s == m.disp && (if exact then sw == w else bytes sw ≥ bytes w)
    | none => false

/-- `Cache::fresh`: an empty register if there is one, the least recently used first. -/
def fresh (c : Cache) : Nat :=
  (List.range 8).foldl (fun best i =>
    let key (j : Nat) := (if c.regs[j]!.slot.isSome then 1 else 0, c.regs[j]!.used)
    let (a1, a2) := key i
    let (b1, b2) := key best
    if a1 < b1 || (a1 == b1 && a2 < b2) then i else best) 0

def setEntry (c : Cache) (i : Nat) (f : Entry → Entry) : Cache :=
  { c with regs := c.regs.modify i f }

/-- `Cache::update`. -/
def update (c : Cache) (item : Item) : Cache := Id.run do
  let mut c := c
  let write (c : Cache) (m : M) (n : Nat) : Cache :=
    { c with regs := c.regs.map fun e =>
      if m.base != .rbp || (match e.slot with
        | some (s, w) => overlaps s (bytes w) m.disp n
        | none => false) then { e with slot := none } else e }
  match item with
  | .st w _ m | .stImm w m _ => c := write c m (bytes w)
  | .setcc _ m => c := write c m 1
  | _ => pure ()
  let wide (w : W) : Option W := if w == .d || w == .q then some w else none
  let upd : Option (Reg × Option (BitVec 32 × W) × Option W) := match item with
    | .ld w sx dst m =>
      some (dst, if !sx && m.base == .rbp then some (m.disp, w) else none, some (if sx then .d else w))
    | .alu op w reg _ => if op != .cmp then some (reg, none, wide w) else none
    | .aluImm op w (.reg reg) _ => if op != .cmp then some (reg, none, wide w) else none
    | .imul w reg _ | .imulImm w reg _ _ | .shift _ w reg _ => some (reg, none, wide w)
    | .leaM dst _ | .setReg dst _ | .lea dst _ | .loadRip dst _ => some (dst, none, some .q)
    | .mulQ _ => some (.rax, none, some .q)
    | _ => none
  -- `mul` writes `rdx` too.
  if item matches .mulQ _ then
    c := c.setEntry 1 fun e => { e with slot := none, zx := none }
  match item with
  | .st w src m =>
    if let some i := poolIdx src then
      if m.base == .rbp && (match c.regs[i]!.zx with
          | some z => bytes z ≤ bytes w
          | none => false) then
        c := c.setEntry i fun e => { e with slot := some (m.disp, w) }
    return c
  | _ => pure ()
  match upd with
  | some (r, slot, zx) =>
    if let some i := poolIdx r then
      c := c.setEntry i fun e => { e with slot := slot, zx := zx }
    return c
  | none => return c

/-- `Cache::emit`: `items` (an inline sequence, on `rax`) as emitted with the cache, and the
cache after it. -/
def emit (c : Cache) (items : List Item) : List Item × Cache := Id.run do
  let mut c := { c with tick := c.tick + 1 }
  -- A `mul` (`rdx:rax`) computes in `rax`, dropping the reload only if `rax` holds it.
  let pinned := items.any fun | .mulQ _ => true | _ => false
  let (x, rest) := match items with
    | .ld w false .rax m :: tl =>
      if pinned then
        (0, if m.base == Reg.rbp && c.regs[0]!.slot == some (m.disp, w) then tl else items)
      else match c.find m w true with
      | some i => (i, tl)
      | none => (c.fresh, items)
    | _ => (if pinned then 0 else c.fresh, items)
  c := c.setEntry x fun e => { e with used := c.tick }
  let xr := pool[x]!
  let mut out : Array Item := #[]
  for it in rest do
    let mut it := mapRegs (fun r => if r == R then xr else r) it
    if let some (m, w) := readOperand it then
      if let some i := c.find m w false then
        it := withRm it (.reg pool[i]!)
        c := c.setEntry i fun e => { e with used := c.tick }
    c := c.update it
    out := out.push it
  return (out.toList, c)

/-- `Cache::unemit`: the sequences on `rax` that `emit` may have turned into `items`. -/
def unemit (c : Cache) (items : List Item) : List (List Item) := Id.run do
  let mut out : Array (List Item) := #[]
  let mut xs : List Nat := (List.range 8).filter fun i =>
    items.any fun it => mapRegs (fun r => if r == pool[i]! then .rbp else r) it != it
  if xs.isEmpty then xs := [c.fresh]
  for x in xs do
    let xr := pool[x]!
    let back (r : Reg) : Reg := if r == xr then R else if r == R then xr else r
    for reload in [false, true] do
      let mut cc := c
      let mut head : List Item := []
      if reload then
        match cc.regs[x]!.slot with
        | some (s, w) => head := [.ld w false R (M.frame s)]
        | none => continue
      let mut alts : List (List Item) := [head]
      for it in items do
        let mut opts : List Item := [mapRegs back it]
        if let some r := readReg it then
          if let some i := poolIdx r then
            if let some (s, _) := cc.regs[i]!.slot then
              let o := mapRegs back (withRm it (.mem (M.frame s)))
              if i == x then opts := opts ++ [o] else opts := [o]
        cc := cc.update it
        alts := alts.flatMap fun a => opts.map fun o => a ++ [o]
      out := out ++ alts.toArray
  return out.toList

end Cache

end Ryo.Vm.Asm
