/-
Tests of the constant-pool and vtable check (`Ryo/Check/Image/Pool.lean`) on hand-built pools
and dumps: matches (plain, through pool pointers, cycles, function and static pointers,
uninitialized bytes, offsets into an allocation, vtables) and each kind of failure (byte
mismatch, wrong relocation target, missing or extra relocation, misalignment, a static
pointer against the wrong symbol), and the "not in dump" and byte-constant classifications.
The check runs on real image objects in `scripts/lean-pool-check.py`.
-/
import RyoTest.Harness

namespace RyoTest.PoolCheck

open Ryo.Spec Ryo.Check.Image.Pool

/-- A dump with two instances: `main`, a body mentioning the globals `mention` (default: all)
as constants, and `foo` (external, as a function pointer target), and the globals `gs`. -/
def prog (gs : Array Global) (mention : Option (List Nat) := none) : Program :=
  let ms := mention.getD (List.range gs.size)
  let stmts : List Statement := ms.map fun g => .assign ⟨0, []⟩ (.use (.const (.indirect g 0) default))
  let block : BlockData := { stmts, term := .«return» }
  let body : Body := { locals := #[], argCount := 0, blocks := #[block] }
  { instances := #[{ symbol := "main", kind := .body body }, { symbol := "foo", kind := .ext }],
    globals := gs, start := 0 }

def glob (bytes : List Nat) (align : Nat := 1) (relocs : List Relocation := []) (kind : GlobalKind := .const) : Global :=
  { bytes := bytes.map (some ·.toUInt8), relocs, align := Align.ofBytes align, kind }

def pool (bytes : List Nat) (relocs : List (Nat × PRel) := []) (start : Nat := 0) : PoolView :=
  { bytes := ⟨(bytes.map (·.toUInt8)).toArray⟩, relocs := relocs.foldl (fun m (o, r) => m.insert o r) {},
    start, secAlign := 16 }

def ref (k : Nat) (use : Use := .addr) (funcs : Array String := #["main"]) : CodeRef := { k, use, funcs }

def expect (r : Report) (matched : Nat := 0) (mismatched : Nat := 0) (notInDump : Nat := 0) (bytes : Nat := 0)
    (errors : Nat := 0) (reached : Option Nat := none) : Except String Unit := do
  let got := s!"matched {r.matched} mismatched {r.mismatched} not-in-dump {r.notInDump} bytes {r.bytes} errors {r.errors.size} reached {r.reached}: {r.errors ++ r.lines}"
  check (r.matched == matched && r.mismatched == mismatched && r.notInDump == notInDump && r.bytes == bytes
    && r.errors.size == errors && reached.all (· == r.reached)) got

def z8 : List Nat := List.replicate 8 0

/-- Allocation `g0 = [1, 2, 3, 4]` (align 4) at pool 4, and `g1`, a pointer to `g0 + 1`
followed by 8 sevens, at pool 8. -/
def g0 : Global := glob [1, 2, 3, 4] 4
def g1 : Global := glob (z8 ++ List.replicate 8 7) 8 [{ offset := 0, target := .alloc 0, addend := 1 }]
def bytes01 : List Nat := [0, 0, 0, 0, 1, 2, 3, 4] ++ z8 ++ List.replicate 8 7

def positive : Except String Unit := do
  -- A plain copy, at its own offset and at an offset into it.
  expect (Ryo.Check.Image.Pool.check (prog #[g0]) (pool [0, 0, 0, 0, 1, 2, 3, 4]) #[ref 4 (.copy 4), ref 6 (.copy 2), ref 4]) (matched := 3)
  -- Through a pool pointer: `g1` demands `g0` at 4.
  expect (Ryo.Check.Image.Pool.check (prog #[g0, g1]) (pool bytes01 [(8, .pool 5)]) #[ref 8 (.copy 16)]) (matched := 1) (reached := some 1)
  -- A cycle: `g` points at itself.
  let gc := glob (z8 ++ [9]) 8 [{ offset := 0, target := .alloc 0 }]
  expect (Ryo.Check.Image.Pool.check (prog #[gc]) (pool (z8 ++ [9]) [(0, .pool 0)]) #[ref 0]) (matched := 1)
  -- A function pointer, against the instance's symbol.
  let gf := glob z8 8 [{ offset := 0, target := .fn 1 }]
  expect (Ryo.Check.Image.Pool.check (prog #[gf]) (pool z8 [(0, .sym "foo" 0)]) #[ref 0]) (matched := 1)
  -- A static pointer, against a symbol.
  let gs := glob z8 8 [{ offset := 0, target := .alloc 1, addend := 4 }]
  let st := { glob [0, 0, 0, 0] 4 (kind := .static false) with symbol := some "STATIC" }
  expect (Ryo.Check.Image.Pool.check (prog #[gs, st]) (pool z8 [(0, .sym "STATIC" 4)]) #[ref 0]) (matched := 1)
  -- Uninitialized bytes may be anything.
  let gu : Global := { bytes := [some 1, none, some 3], align := Align.ofBytes 1, kind := .const }
  expect (Ryo.Check.Image.Pool.check (prog #[gu]) (pool [1, 0xaa, 3]) #[ref 0 (.copy 3)]) (matched := 1)
  -- A type id's bytes stay: no relocation.
  let gt := glob [5, 0, 0, 0, 0, 0, 0, 0] 8 [{ offset := 0, target := .typeId, addend := 5 }]
  expect (Ryo.Check.Image.Pool.check (prog #[gt]) (pool [5, 0, 0, 0, 0, 0, 0, 0]) #[ref 0]) (matched := 1)
  -- A vtable: null drop, size 8, align 8, one method.
  let vt := glob (z8 ++ [8] ++ List.replicate 7 0 ++ [8] ++ List.replicate 7 0 ++ z8) 8
    [{ offset := 24, target := .fn 1 }] (.vtable (some "dyn T"))
  let vb := z8 ++ [8] ++ List.replicate 7 0 ++ [8] ++ List.replicate 7 0 ++ z8
  let r := Ryo.Check.Image.Pool.check (prog #[vt]) (pool vb [(24, .sym "foo" 0)]) #[ref 0]
  expect r (matched := 1)
  check (r.matchedVtables == 1) "vtable counted"

def negative : Except String Unit := do
  -- Byte mismatch.
  expect (Ryo.Check.Image.Pool.check (prog #[g0]) (pool [0, 0, 0, 0, 1, 2, 9, 4]) #[ref 4 (.copy 4)]) (mismatched := 1)
  -- Wrong relocation target: another symbol, another addend, the pool instead of a symbol.
  let gf := glob z8 8 [{ offset := 0, target := .fn 1 }]
  expect (Ryo.Check.Image.Pool.check (prog #[gf]) (pool z8 [(0, .sym "bar" 0)]) #[ref 0]) (mismatched := 1)
  expect (Ryo.Check.Image.Pool.check (prog #[gf]) (pool z8 [(0, .sym "foo" 8)]) #[ref 0]) (mismatched := 1)
  expect (Ryo.Check.Image.Pool.check (prog #[gf]) (pool z8 [(0, .pool 0)]) #[ref 0]) (mismatched := 1)
  -- A pool pointer to where the target allocation isn't.
  expect (Ryo.Check.Image.Pool.check (prog #[g0, g1]) (pool bytes01 [(8, .pool 6)]) #[ref 8 (.copy 16)]) (mismatched := 1)
  -- Missing relocation.
  expect (Ryo.Check.Image.Pool.check (prog #[g0, g1]) (pool bytes01) #[ref 8 (.copy 16)]) (mismatched := 1)
  -- A relocation where the allocation has none (and one overlapping its start).
  expect (Ryo.Check.Image.Pool.check (prog #[g0]) (pool [0, 0, 0, 0, 1, 2, 3, 4] [(4, .sym "foo" 0)]) #[ref 4 (.copy 4)]) (mismatched := 1)
  expect (Ryo.Check.Image.Pool.check (prog #[g0]) (pool (z8 ++ [1, 2, 3, 4]) [(2, .sym "foo" 0)]) #[ref 8 (.copy 4)]) (mismatched := 1)
  -- Another relocation type.
  expect (Ryo.Check.Image.Pool.check (prog #[gf]) (pool z8 [(0, .other "R_X86_64_PC32")]) #[ref 0]) (mismatched := 1)
  -- Misaligned: the pool starts at section offset 2.
  expect (Ryo.Check.Image.Pool.check (prog #[g0]) (pool [1, 2, 3, 4] (start := 2)) #[ref 0 (.copy 4)]) (mismatched := 1)
  -- A copy longer than the allocation.
  expect (Ryo.Check.Image.Pool.check (prog #[g0]) (pool [0, 0, 0, 0, 1, 2, 3, 4, 5]) #[ref 4 (.copy 5)]) (mismatched := 1)
  -- A static pointer against another symbol, or one the dump gives no symbol.
  let gs := glob z8 8 [{ offset := 0, target := .alloc 1 }]
  let st := { glob [0] 1 (kind := .static false) with symbol := some "A" }
  expect (Ryo.Check.Image.Pool.check (prog #[gs, st]) (pool z8 [(0, .sym "A" 0)]) #[ref 0]) (matched := 1)
  expect (Ryo.Check.Image.Pool.check (prog #[gs, st]) (pool z8 [(0, .sym "B" 0)]) #[ref 0]) (mismatched := 1)
  expect (Ryo.Check.Image.Pool.check (prog #[gs, glob [0] 1 (kind := .static false)]) (pool z8 [(0, .sym "A" 0)]) #[ref 0])
    (mismatched := 1)
  -- A vtable whose dumped align word isn't a power of two.
  let vt := glob (z8 ++ [8] ++ List.replicate 7 0 ++ [3] ++ List.replicate 7 0) 8 (kind := .vtable none)
  let vb := z8 ++ [8] ++ List.replicate 7 0 ++ [3] ++ List.replicate 7 0
  expect (Ryo.Check.Image.Pool.check (prog #[vt]) (pool vb) #[ref 0]) (matched := 1) (errors := 1)

def classify : Except String Unit := do
  -- A match only against a global the referencing body doesn't mention.
  let r := Ryo.Check.Image.Pool.check (prog #[g0, glob [7] 1] (some [1])) (pool [0, 0, 0, 0, 1, 2, 3, 4]) #[ref 4 (.copy 4)]
  expect r (mismatched := 1)
  -- No dumped body references it: not in the dump.
  expect (Ryo.Check.Image.Pool.check (prog #[g0]) (pool [0, 0, 0, 0, 1, 2, 9, 4]) #[ref 4 (.copy 4) #["std_fn"]]) (notInDump := 1)
  -- `fill` operands are byte constants.
  expect (Ryo.Check.Image.Pool.check (prog #[]) (pool [5, 5]) #[ref 0 (.fill 2)]) (bytes := 1)
  -- Statics are never pool copies.
  let st := glob [1, 2, 3, 4] 4 (kind := .static false)
  expect (Ryo.Check.Image.Pool.check (prog #[st]) (pool [1, 2, 3, 4]) #[ref 0 (.copy 4)]) (mismatched := 1)

def tests : List TestCase := [
  ⟨"PoolCheck/positive", fun _ => positive⟩,
  ⟨"PoolCheck/negative", fun _ => negative⟩,
  ⟨"PoolCheck/classify", fun _ => classify⟩,
]

end RyoTest.PoolCheck
