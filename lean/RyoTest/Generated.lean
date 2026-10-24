/-
Sanity checks of the generated tables (`Ryo/Vm/Generated`): sizes, a few known entries, and
the relations between the full and reduced sets, the layouts and the handler table.
-/
import RyoTest.Harness

namespace RyoTest.Generated

open Ryo.Vm

/-- Fails with `msg` and the first opcode of `ops` where `p` doesn't hold. -/
def forAll {α} [ToString α] (ops : List α) (p : α → Bool) (msg : String) : Except String Unit :=
  match ops.find? (fun op => !p op) with
  | none => .ok ()
  | some op => .error s!"{msg}: {op}"

def sizes : Except String Unit := do
  check (Full.opInfos.size == Full.count) "Full.opInfos size"
  check (Reduced.opInfos.size == Reduced.count) "Reduced.opInfos size"
  check (Reduced.toFullTable.size == Reduced.count) "Reduced.toFullTable size"
  check (Reduced.ofFullTable.size == Full.count) "Reduced.ofFullTable size"
  check (Asm.asmInfos.size == Full.count) "Asm.asmInfos size"
  check (Handlers.handlers.size == Full.count) "Handlers.handlers size"
  check (Full.count > 800 && Reduced.count > 100 && Reduced.count < Full.count) "opcode counts"
  check (formatVersion > 0) "formatVersion"

def known : Except String Unit := do
  let add := Full.Opcode.addW32.info
  check (add.name == "AddW32" && add.mnemonic == "add.w32" && add.shape == .op) "add.w32's info"
  check (add.operands.map (·.name) == ["d", "a", "b"]) "add.w32's operands"
  check (add.operands.all (·.kind == .slot) && add.fixedLen == some 4) "add.w32's kinds and length"
  check (Full.Opcode.ofMnemonic? "ret" == some Full.Opcode.ret) "ret by mnemonic"
  check (Full.Opcode.mnemonic ⟨0⟩ == "mov.w8") "opcode 0"
  check (Full.Opcode.switchDenseW8.info.fixedLen == none) "switch.dense has a list"
  check (Full.Opcode.island.info.shape == .island && !Full.Opcode.island.hasHandler) "island"
  -- `add.w32`: one register per slot, after `fp` with `fp_arg`.
  let locs (r : List Nat) := r.map fun r => Asm.Loc.mk r 0 1 false
  check (Full.Opcode.addW32.layout false == some ⟨locs [0, 1, 2], 0, 3⟩) "add.w32's layout (rbp)"
  check (Full.Opcode.addW32.layout true == some ⟨locs [1, 2, 3], 1, 4⟩) "add.w32's layout (fp_arg)"
  -- `lpad` takes the exception object before its operands.
  check ((Full.Opcode.lpad.layout true).map (·.first) == some 2) "lpad's first register"
  let h := Full.Opcode.divSW32.handler?
  check (h == some ⟨.bin_fn, ["i32", "unchecked_div"], none⟩) "div.s.w32's handler"
  check ((Full.Opcode.brEqW8.handler?).bind (·.ret) == some "bool") "br.eq.w8 returns bool"
  check (Full.Opcode.resume.hasHandler && Full.Opcode.resume.handler? == none) "resume is assembly"

def reducedSet : Except String Unit := do
  -- Every reduced opcode but `handler` is the full one of the same mnemonic, shape and
  -- operands, in the full list's order.
  forAll Reduced.all (fun op => match op.full with
    | none => op == Reduced.Opcode.handler
    | some f => f.info.mnemonic == op.info.mnemonic && f.info.shape == op.info.shape &&
        f.info.operands == op.info.operands && f.info.name == op.info.name &&
        Reduced.Opcode.ofFull f == some op) "reduced opcode without its full one"
  let fulls := Reduced.all.filterMap (·.full)
  check (fulls.zip fulls.tail |>.all fun (a, b) => a.val < b.val) "reduced set out of the full order"
  -- They are exactly the full opcodes that run as native code.
  forAll Full.all (fun f => (Reduced.Opcode.ofFull f).isSome == (f.hasInline || !f.hasHandler))
    "reduced membership"
  forAll Full.all (fun f => match Reduced.Opcode.ofFull f with
    | some r => r.full == some f
    | none => true) "ofFull/full round trip"

def layouts : Except String Unit := do
  forAll Full.all (fun op => (op.layout false).isSome == op.hasHandler &&
    (op.layout true).isSome == op.hasHandler) "layout without a handler or the reverse"
  forAll Full.all (fun op => [false, true].all fun fpArg => match op.layout fpArg with
    | none => true
    | some l => l.locs.length == op.info.operands.length && l.regs ≤ Asm.argRegs &&
        l.first == (if fpArg then 1 else 0) + (if op.info.shape == .lpad then 1 else 0) &&
        l.locs.all fun loc => loc.count == 0 || loc.reg + loc.count ≤ l.regs) "layout shape"
  -- Every opcode with a handler but `resume` has an entry in handlers.rs.
  forAll Full.all (fun op => op.handler?.isSome == (op.hasHandler && op != Full.Opcode.resume))
    "handler table"

def tests : List TestCase := [
  ⟨"Generated/sizes", fun _ => sizes⟩,
  ⟨"Generated/known", fun _ => known⟩,
  ⟨"Generated/reduced", fun _ => reducedSet⟩,
  ⟨"Generated/layouts", fun _ => layouts⟩,
]

end RyoTest.Generated
