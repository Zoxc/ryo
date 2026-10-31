/-
Ryo.Proofs.Call — the shapes `call`/`call.sym`/`call.sym.ind`/`call.ptr` and
`tail_call`/`tail_call.ptr` (aot.md §C2 "Shapes", toward M3 `decode_sound`): R's step of the
instruction (`Ryo.Vm.R.Sem`: a call is an external event, `Query`, continued by `answer`; a tail
call ends the function with `Exit.tailCall`) against the canonical items `DecodeReduced.callInsn`
accepts.

**Items.** A call is `pre ++ params ++ [call] ++ resultStores k d` (`callSeq`, then
`Asm.resultStores`): `pre` is `mov rax, [rip + slot]` for `call.sym.ind` and `mov rax, [rbp + p]`
for `call.ptr`, nothing otherwise (`callHead`); `params` loads each argument register from its
slot (`paramItems`, the inverse of the decoder's `params`: `mov`/`movzx` of the register's size
into `intArg pe i`, `lea` of the slot for `ARG_ADDR`, `movss`/`movsd`/`movups`, or a 2-byte `xmm`
through `r11`); the call is `call f`, `call [rip + slot]`, `call [rax]` or `call rax`. A tail call
is `pre ++ params ++ epilogue F mode ++ [jmp]` (`tailSeq`), the jump `jmp f` or `jmp rax` (`w`:
`rex.w jmp rax`, PE's form; the decoder accepts either in any mode, `jmpRaxOf`).

**The call boundary** (`EntryAt`, the callee's entry: the state just after the `call`, or after
the tail call's `jmp`): `rip` is the callee's address (`calleeTarget`: the function's linked
address, the value in the symbol slot, the value where the slot points, or the pointer), the
argument registers relate to the query's `Regs` (`ArgRet.ArgsRel`: every argument register of
the convention, byte for byte, `Uninit` refined by anything), `rsp + 8` is the query's `sp`
(`fp - F` for a call: the return address is just below the outgoing area; `fp + 16` for a tail
call, the return address being the caller's), the bytes at `sp` relate to the query's `stack`,
and the world's live allocations relate to x86 memory (`WorldRel`, `MemRel` of a `World`).

**The environment's contract** (`CallContract`, trusted, in the style of
`Handler.HandlerContract` and `Counter.TripContract`): `Ret x x'` / `Unw x x'` relate the
callee's entry `x` (an `EntryAt` state) to a state `x'` where it returns / where unwinding out of
it lands in this frame. Every such `x'` corresponds to an R answer `a`:

- what both outcomes share (`CallEnd`): the answer gives the outgoing area's new bytes
  (`a.frame = [bs]`, `bs` related to x86's bytes at `[sp, sp + n)`), its world relates to `x'`
  (`WorldRel`) and extends the query's (`Extends`: allocations are only added, each keeping its
  address and size; liveness and contents may change), and x86 memory changed only at
  `CallMayWrite` addresses: the stack below the end of the outgoing area (`[lo, sp + n)`: the
  callee's frames and its incoming area), the query world's live allocations (memory through
  pointers, escaped frame objects included), and `Owned` (runtime-owned bytes, the heap the
  callee allocates from);
- a return (`CallReturn`): `a.result = .ret regs` with the x86 return registers related
  (`ArgRet.RetRel`: `rax`, `rdx`, `xmm0`, `xmm1`), `rip` the pushed return address, `rsp` popped,
  and the callee-saved registers kept (`Saved`: `rbx rbp r12`–`r15`, PE also `rsi rdi`);
- an unwind (`Landed`): `a.result = .unwind exc`, `rip` the landing pad the unwinder finds for
  the return address (`padOf`, the LSDA's call-site table as linked), `rax` the exception object,
  `rsp` the caller's (`x.rsp + 8`, the frame's body `rsp = fp - F`), the callee-saved registers
  restored.

The contract is only for queries the environment's R side handles (`Safe q`, a parameter: the
callee's R semantics has defined behavior on `q`). That matters because the write set is in
terms of the query: for a given x86 state, a query with a smaller world (fewer allocations; any
world relates to fewer bytes) or a shorter stack area (`n` below the callee's `arg_size`) would
claim the callee leaves alone memory it does write. With `Safe` such queries are excluded: a
callee writing an allocation its query's world doesn't have, or an incoming area larger than
the query's, has no defined R behavior on it. The theorems take `Safe q` for R's actual query
(`hsafe`): the composition discharges it from the environment's R side (the callee's own
simulation), not from this function.

On PE the callee owns 32 bytes of shadow space above its return address; the contract asks
`32 ≤ n` (the plan's stack size includes them: `Check/Lower/Plan.lean`), which the theorems take
as the hypothesis `hshadow` (for calls without a verified plan `Code.stackSize` is 0, and the
hypothesis fails: those calls aren't covered).

**Theorems.**
- `call_query`: from `RRel s x` and `MemRel s.st x`, if R's step is `.ext q s'` (the scopes, the
  argument registers, the stack area, the sret destination made `Uninit`), the items up to the
  call run to `x1` at the callee's entry related to `q` (`EntryAt`), with `RRel s' x1`,
  `MemRel s'.st x1`, the return address pushed, and the callee-saved registers kept.
- `call_return`: from such an `x1` (in terms of the waiting state), every `Ret x1 x'` gives an
  answer `a` with `R.answer c s a = .ok (.step s'')`, and the result stores from `x'` reach `x''`
  with `RRel s'' x''`, `MemRel s''.st x''`, `s''.pc = s.pc + 1`, `rip` past the stores, `rsp` the
  caller's.
- `call_sound`: the two composed (the full R step, from the state before the instruction).
- `call_unwind`: every `Unw x1 x'` gives an answer `.unwind exc` with which R lands at the call's
  landing pad (`Code.cleanupAt s.pc = some (some pad, _)`), related to `x'` at the pad's position.
- `tail_call_step`: R's step `.done fin` (`fin = exit s1 (.tailCall cal regs (fp + 16) stack)`)
  against `tailSeq`: the items reach the callee's entry related to the exit (`EntryAt`, with
  `fin.world`), memory unchanged, `rsp = fp + 8` (the caller's return address at `[rsp]`), the
  saved registers restored as `ArgRet.ret_step`'s epilogue does.

**Hypotheses** beyond the shape: `rsp = fp - F` in the body (`hsp`; `RRel` doesn't carry it; for
the tail call, as `ret_step`, only without a frame pointer and on PE, whose epilogue starts with
`add rsp, F`, with `F + 8 < 2^31`), no byte the relations read on the
stack below `rsp` (`Handler.StackApart`: initialized private bytes and live allocations) nor
where the callee may write unless it's in the outgoing area (`CallApart`: initialized private
bytes; both from `FrameSep`, `FrameSep.stackApart`/`FrameSep.callApart`), the symbol slots off the stack (`SymsApart`, for the push),
frame and stack sizes below `2^62`, and the result stores' displacements without 32-bit
overflow (`d.toInt + 16 ≤ 2^31`). `call_return` also takes a valid return kind (`hk`: `answer`
reads it; `call_sound` has it from the step) and `ResultApart` of each answer's world (`hres`):
the bytes the result stores write are private and at no live allocation's address, else the
x86 store would change an allocation's bytes R's private write leaves alone (`MemRel`). The tail
call says nothing of `rsi`/`rdi` without PE: they are argument registers there, which the loads
set (`EntryAt.args`).

**Not modeled.** Unwinding past this frame (a `continue` entry, or no landing pad): R ends with
`Exit.unwind`, x86 runs none of this function's code; relating that is the unwinder's model
(CFI), not this file's. Two-phase unwinding (`catch` entries' search phase) is the unwinder's
too: `Landed` covers the landing. That `callInsn` produces exactly these items, and the register
cache (cleared at calls), are separate.
-/
import Ryo.Proofs.ArgRet
import Ryo.Proofs.Handler
import Ryo.Proofs.ScopeMem
import Ryo.Proofs.CallLemmas

set_option linter.constructorNameAsVariable false

namespace Ryo.Proofs.Call

open Ryo.Spec Ryo.Vm Ryo.Vm.OpSem Ryo.X86 Ryo.Vm.Asm Ryo.Proofs.Inline Ryo.Proofs.Scope
open Ryo.Proofs.ArgRet (ArgsRel RetRel)
open Ryo.Proofs.Counter (CalleeSaved InStack)
open Ryo.Proofs.CallLemmas

/-! ### Items -/

/-- The load of one argument register, slot `s` and register word `w` (the forms the decoder's
`params` accepts): `lea` of the slot into the integer register for `ARG_ADDR`, `mov`/`movzx` of
the register's size, `movss`/`movsd`/`movups`, or a 2-byte `xmm` through `r11`. Integer registers
beyond the convention's (4 on PE, 6 otherwise) have no load. -/
def paramItem (pe : Bool) (s w : BitVec 32) : Option (List Item) :=
  let rn := w.toNat
  let byAddr := rn &&& Asm.argAddr != 0
  match ArgReg.of? (if byAddr then rn - Asm.argAddr else rn) false with
  | none => none
  | some a =>
    if byAddr then
      if a.xmm || a.size != 8 || (if pe then 4 else 6) ≤ a.index then none
      else some [.leaM (intArg pe a.index) (M.frame s)]
    else if a.xmm then
      if a.size == 2 then some [.ld .w false .r11 (M.frame s), .movd true a.index .r11]
      else some [.sse false a.size a.index (M.frame s)]
    else if a.index < (if pe then 4 else 6) then
      some [.ld (widthOf a.size) false (intArg pe a.index) (M.frame s)]
    else none

/-- The argument loads of a call's list of (slot, register word) pairs, in order. -/
def paramItems (pe : Bool) : List (BitVec 32) → Option (List Item)
  | [] => some []
  | [_] => none
  | s :: w :: rest => do pure ((← paramItem pe s w) ++ (← paramItems pe rest))

/-- A call's items before the argument loads, and the call: `call f`, `call [rip + slot]`,
`mov rax, [rip + slot]; …; call [rax]`, `mov rax, [rbp + p]; …; call rax`. -/
def callHead (f : Full.Opcode) : R.Opnd Nat → Option (List Item × Item)
  | .func g => if f == .call then some ([], .call (.func g)) else none
  | .sym s =>
    if f == .callSym then some ([], .callMem (.sym s))
    else if f == .callSymInd then some ([.loadRip .rax (.sym s)], .callMemRax)
    else none
  | .slot p => if f == .callPtr then some ([.ld .q false .rax (M.frame p)], .callRax) else none
  | _ => none

/-- A call's items up to and including the call (the result stores follow). -/
def callSeq (pe : Bool) (f : Full.Opcode) (fo : R.Opnd Nat) (ws : List (BitVec 32)) :
    Option (List Item) := do
  let (pre, ci) ← callHead f fo
  let ps ← paramItems pe ws
  pure (pre ++ ps ++ [ci])

/-- `tail_call.ptr`'s jump: `rex.w jmp rax` (`w`, PE's form) or `jmp rax`. -/
def jmpRaxOf : Bool → Item
  | true => .jmpRaxW
  | false => .jmpRax

/-- A tail call's items before the argument loads, and its jump: `jmp f`, or
`mov rax, [rbp + p]; …; jmp rax` (`jmpRaxOf w`). -/
def tailHead (w : Bool) (f : Full.Opcode) : R.Opnd Nat → Option (List Item × Item)
  | .func g => if f == .tailCall then some ([], .jmp (.func g)) else none
  | .slot p => if f == .tailCallPtr then some ([.ld .q false .rax (M.frame p)], jmpRaxOf w) else none
  | _ => none

/-- A tail call's items: the loads, the epilogue, the jump (`w`: `tailHead`'s). -/
def tailSeq (F : Nat) (mode : Ryo.Obj.Mode) (w : Bool) (f : Full.Opcode) (fo : R.Opnd Nat)
    (ws : List (BitVec 32)) : Option (List Item) := do
  let (pre, j) ← tailHead w f fo
  let ps ← paramItems mode.pe ws
  pure (pre ++ ps ++ (epilogue F mode ++ [j]))

/-! ### The boundary -/

/-- The callee's address as the x86 code computes it, in memory `m`. -/
def calleeTarget (ctx : Ctx) (m : Mem) : R.Callee → BitVec 64
  | .func f => ctx.addrOf (.func f)
  | .sym s => m.read64 (ctx.addrOf (.sym s))
  | .symInd s => m.read64 (m.read64 (ctx.addrOf (.sym s)))
  | .ptr p => BitVec.ofNat 64 p.addr

/-- A world's live allocations relate to x86 memory byte for byte (`MemRel` of a `World`). -/
def WorldRel (w : R.World) (x : X86.State) : Prop :=
  ∀ id a, w.mem.get? id = some a → a.live = true → ∀ i (h : i < a.data.size),
    ByteRel a.data[i] (x.mem (BitVec.ofNat 64 (a.addr + i)))

theorem worldRel_iff (s : R.RState) (x : X86.State) : WorldRel s.world x ↔ MemRel s.st x :=
  Iff.rfl

/-- The callee's entry, related to a call or tail call to `cal` with argument registers `regs`
and stack arguments `stack` at `sp`, the world `w` (see the module comment). -/
structure EntryAt (ctx : Ctx) (pe : Bool) (cal : R.Callee) (regs : R.Regs) (sp : Nat)
    (stack : List AbstractByte) (w : R.World) (x : X86.State) : Prop where
  target : x.rip = calleeTarget ctx x.mem cal
  args : ArgsRel pe regs x
  rsp : x.rsp + 8 = BitVec.ofNat 64 sp
  stack : BytesRel stack (bytesAt x.mem (BitVec.ofNat 64 sp) stack.length)
  world : WorldRel w x

/-- The callee-saved registers: `rbx rbp r12`–`r15`, PE also `rsi rdi`. -/
def Saved (pe : Bool) (i : Fin 16) : Prop := CalleeSaved i ∨ (pe = true ∧ (i = 6 ∨ i = 7))

theorem saved_of_calleeSaved {pe : Bool} {i : Fin 16} (h : CalleeSaved i) : Saved pe i := Or.inl h

/-- `m'` extends `m`: allocations are only added, each keeping its address and size. -/
structure Extends (m m' : Memory) : Prop where
  size : m.allocs.size ≤ m'.allocs.size
  keep : ∀ id a, m.get? id = some a → ∃ a', m'.get? id = some a' ∧ a'.addr = a.addr ∧
    a'.size = a.size

theorem Extends.refl (m : Memory) : Extends m m :=
  ⟨Nat.le_refl _, fun _ a h => ⟨a, h, rfl, rfl⟩⟩

/-- `b` is in a live allocation of `w`. -/
def InAlloc (w : R.World) (b : BitVec 64) : Prop :=
  ∃ id al, w.mem.get? id = some al ∧ al.live = true ∧ (b - BitVec.ofNat 64 al.addr).toNat < al.size

/-- Where a callee may write (see the module comment): the stack below the end of the outgoing
area `[sp, sp + n)`, the live allocations of the query's world, runtime-owned bytes. -/
def CallMayWrite (Owned : BitVec 64 → Prop) (lo : BitVec 64) (sp n : Nat) (w : R.World)
    (b : BitVec 64) : Prop :=
  InStack lo (BitVec.ofNat 64 (sp + n)) b ∨ InAlloc w b ∨ Owned b

/-- What a callee's return and an unwind out of it share (see the module comment). `x` is the
callee's entry, `x'` where it comes back, `w` the query's world, `n` the outgoing area's size. -/
structure CallEnd (Owned : BitVec 64 → Prop) (lo : BitVec 64) (sp n : Nat) (w : R.World)
    (x x' : X86.State) (a : R.Answer) : Prop where
  frame : ∃ bs, a.frame = [bs] ∧ BytesRel bs (bytesAt x'.mem (BitVec.ofNat 64 sp) n)
  world : WorldRel a.world x'
  grows : Extends w.mem a.world.mem
  mem : ∀ b, ¬ CallMayWrite Owned lo sp n w b → x'.mem b = x.mem b

/-- A callee's return related to the answer `a`. -/
structure CallReturn (pe : Bool) (Owned : BitVec 64 → Prop) (lo : BitVec 64) (sp n : Nat)
    (w : R.World) (x x' : X86.State) (a : R.Answer) : Prop
    extends CallEnd Owned lo sp n w x x' a where
  regs : ∃ regs, a.result = .ret regs ∧ RetRel regs x'
  rip : x'.rip = x.mem.read64 x.rsp
  rsp : x'.rsp = x.rsp + 8
  saved : ∀ i, Saved pe i → x'.regs i = x.regs i

/-- Unwinding out of the callee (entered at `x`) landed at `x'` in this frame with exception
object `exc`: at the landing pad `padOf` gives for the return address, the exception object in
`rax`, `rsp` the frame's `sp0`, the callee-saved registers restored. -/
structure Landed (pe : Bool) (padOf : BitVec 64 → Option (BitVec 64)) (sp0 : BitVec 64)
    (x x' : X86.State) (exc : ThinPointer) : Prop where
  rip : padOf (x.mem.read64 x.rsp) = some x'.rip
  rax : x'.reg .rax = BitVec.ofNat 64 exc.addr
  rsp : x'.rsp = sp0
  saved : ∀ i, Saved pe i → x'.regs i = x.regs i

/-- The environment's contract for calls (trusted; see the module comment). -/
structure CallContract (ctx : Ctx) (pe : Bool) (Owned : BitVec 64 → Prop) (lo : BitVec 64)
    (padOf : BitVec 64 → Option (BitVec 64)) (Safe : R.Query → Prop)
    (Ret Unw : X86.State → X86.State → Prop) : Prop where
  ret : ∀ cal regs sp stack w x x', EntryAt ctx pe cal regs sp stack w x →
    Safe ⟨.call cal regs sp stack, w⟩ → (pe = true → 32 ≤ stack.length) → Ret x x' →
    ∃ a, CallReturn pe Owned lo sp stack.length w x x' a
  unwind : ∀ cal regs sp stack w x x', EntryAt ctx pe cal regs sp stack w x →
    Safe ⟨.call cal regs sp stack, w⟩ → (pe = true → 32 ≤ stack.length) → Unw x x' →
    ∃ a exc, a.result = .unwind exc ∧ CallEnd Owned lo sp stack.length w x x' a ∧
      Landed pe padOf (x.rsp + 8) x x' exc

/-! ### Hypotheses about the layout -/

/-- No initialized private frame byte outside the outgoing area `[-F, -F + n)` is where the
callee may write (`CallMayWrite` for the stack area at `sp`, the state's world). Only
initialized ones: an `Uninit` byte relates to any x86 byte, and over all private bytes this
would fail as soon as a live allocation lies outside the escaped objects (every address is
`fp + o` for some private `o`). From `FrameSep` by `FrameSep.callApart`. -/
def CallApart (Owned : BitVec 64 → Prop) (lo : BitVec 64) (F n sp : Nat) (st : OpSem.State)
    (x : X86.State) : Prop :=
  ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → st.escapedAt o = none → st.frame o ≠ .uninit →
    ¬ (-(F : Int) ≤ o ∧ o < -(F : Int) + n) →
    ¬ CallMayWrite Owned lo sp n ⟨st.mem, st.exposed⟩ (fpAddr x o)

/-- The symbol slots, and what `call.sym.ind` reads through them, are off the stack below `sp`
(where the call pushes its return address). -/
def SymsApart (ctx : Ctx) (lo sp : BitVec 64) (m : Mem) : Prop :=
  ∀ s, ∀ a ∈ [ctx.addrOf (.sym s), m.read64 (ctx.addrOf (.sym s))], ∀ i < 8,
    ¬ InStack lo sp (a + BitVec.ofNat 64 i)

/-! ### Small facts -/

set_option maxRecDepth 100000 in
theorem call_shapes : Full.Opcode.call.info.shape = .call ∧ Full.Opcode.callSym.info.shape = .call ∧
    Full.Opcode.callSymInd.info.shape = .call ∧ Full.Opcode.callPtr.info.shape = .call := by
  decide

set_option maxRecDepth 100000 in
theorem tailCall_shapes : Full.Opcode.tailCall.info.shape = .tailCall ∧
    Full.Opcode.tailCallPtr.info.shape = .tailCall := by
  decide

theorem paramItems_nil (pe : Bool) : paramItems pe [] = some [] := rfl

theorem exec_call (ctx : Ctx) (to : Ref) (x : X86.State) :
    (Item.call to).exec ctx x = .ok
      (((x.jump (x.rip + BitVec.ofNat 64 (Item.call to).size)).push
        (x.rip + BitVec.ofNat 64 (Item.call to).size)).jump (ctx.addrOf to)) := rfl

theorem exec_callMem (ctx : Ctx) (to : Ref) (x : X86.State) :
    (Item.callMem to).exec ctx x = .ok
      (((x.jump (x.rip + BitVec.ofNat 64 (Item.callMem to).size)).push
        (x.rip + BitVec.ofNat 64 (Item.callMem to).size)).jump (x.mem.read64 (ctx.addrOf to))) :=
  rfl

theorem exec_callRax (ctx : Ctx) (x : X86.State) :
    Item.callRax.exec ctx x = .ok
      (((x.jump (x.rip + BitVec.ofNat 64 Item.callRax.size)).push
        (x.rip + BitVec.ofNat 64 Item.callRax.size)).jump (x.reg .rax)) := rfl

theorem exec_callMemRax (ctx : Ctx) (x : X86.State) :
    Item.callMemRax.exec ctx x = .ok
      (((x.jump (x.rip + BitVec.ofNat 64 Item.callMemRax.size)).push
        (x.rip + BitVec.ofNat 64 Item.callMemRax.size)).jump (x.mem.read64 (x.reg .rax))) := rfl

theorem exec_jmp (ctx : Ctx) (to : Ref) (x : X86.State) :
    (Item.jmp to).exec ctx x = .ok (x.jump (ctx.addrOf to)) := rfl

theorem exec_jmpRax (ctx : Ctx) (x : X86.State) :
    Item.jmpRax.exec ctx x = .ok (x.jump (x.reg .rax)) := rfl

theorem exec_jmpRaxW (ctx : Ctx) (x : X86.State) :
    Item.jmpRaxW.exec ctx x = .ok (x.jump (x.reg .rax)) := rfl

theorem exec_jmpRaxOf (ctx : Ctx) (w : Bool) (x : X86.State) :
    (jmpRaxOf w).exec ctx x = .ok (x.jump (x.reg .rax)) := by
  cases w
  · exact exec_jmpRax ctx x
  · exact exec_jmpRaxW ctx x

/-- The epilogue alone (a tail call's: no `ret`): `rsp = fp + 8`, where the caller's return
address is; the saved `rbp` restored as in `ArgRet.exec_epilogue`; nothing else changed but
the flags. -/
theorem exec_epilogue_only (ctx : Ctx) (F : Nat) (m : Ryo.Obj.Mode) (y : X86.State)
    (hsp : m.pe = true ∨ m.framePointer = false →
      y.rsp = y.reg .rbp - BitVec.ofNat 64 F ∧ F + 8 < 2 ^ 31) :
    ∃ y', execItems ctx (epilogue F m) y = .ok y' ∧ y'.mem = y.mem ∧ y'.xmm = y.xmm ∧
      y'.rsp = y.reg .rbp + 8 ∧
      (∀ i : Fin 16, i ≠ 4 → i ≠ 5 → y'.regs i = y.regs i) ∧
      (m.pe = true ∨ m.framePointer = true → y'.reg .rbp = y.mem.read64 (y.reg .rbp)) ∧
      (m.pe = false → m.framePointer = false → y'.reg .rbp = y.reg .rbp) := by
  have ea : ∀ a b : BitVec 64, (addF a b).1 = a + b := fun _ _ => rfl
  unfold epilogue
  cases hpe : m.pe <;> cases hfp : m.framePointer <;>
    simp only [hpe, hfp, Bool.false_eq_true, ↓reduceIte, true_or, or_true, or_false,
      false_implies, forall_const, true_implies] at hsp ⊢
  -- PE: `add rsp, F` (for `F > 0`) and `pop rbp`, from `rsp = fp - F`.
  case true.false | true.true =>
    obtain ⟨hr, hF⟩ := hsp
    simp only [State.rsp, State.reg, ArgRet.idx_rsp, idx_rbp] at hr
    by_cases hF0 : F = 0
    · subst hF0
      simp only [bne_self_eq_false, Bool.false_eq_true, ↓reduceIte, List.nil_append,
        execItems_cons, execItems_nil, Item.exec, pure, Except.pure, ex_bind_ok']
      refine ⟨_, rfl, ?_⟩
      simp (config := { decide := true }) [State.pop, State.rsp, State.reg, State.setReg, State.jump]
      simp only [BitVec.ofNat_eq_ofNat, BitVec.sub_zero] at hr
      simp only [hr, idx_rbp]
      and_intros
      all_goals first
        | (intro i h4 h5; simp [h4, h5])
        | (congr 1; bv_omega)
        | bv_omega
    · have hne : (F != 0) = true := by simpa using hF0
      simp only [hne, ↓reduceIte, List.cons_append, List.singleton_append, List.nil_append,
        execItems_cons, execItems_nil, Item.exec, pure, Except.pure, ex_bind_ok']
      refine ⟨_, rfl, ?_⟩
      simp (config := { decide := true }) [State.pop, State.rsp, State.reg, State.setReg,
        State.setFlags, State.jump]
      simp only [ea, idx_rbp]
      rw [hr, ArgRet.signExtend_ofNat_small _ (by omega)]
      and_intros
      all_goals first
        | (intro i h4 h5; simp [h4, h5])
        | (congr 1; bv_omega)
        | bv_omega
  all_goals
    simp only [execItems_cons, execItems_nil, Item.exec, pure, Except.pure, ex_bind_ok']
    refine ⟨_, rfl, ?_⟩
    simp (config := { decide := true }) [State.pop, State.rsp, State.reg, State.setReg,
      State.setFlags, State.jump]
    try simp only [ea]
  case false.false =>
    obtain ⟨hr, hF⟩ := hsp
    simp only [State.rsp, State.reg, ArgRet.idx_rsp, idx_rbp] at hr
    rw [hr, ArgRet.signExtend_ofNat_small _ (by omega), BitVec.ofNat_add]
    and_intros
    · bv_omega
    · intro i h4 h5; simp [h4]
  all_goals
    and_intros <;>
    first
      | exact True.intro
      | (intro i h4 h5; simp [h4, h5])
      | bv_omega
      | (congr 1; bv_omega)

/-- A live allocation after `freeObjs` was there before, the same. -/
theorem freeObjs_live : ∀ (es : List EscapedObj) (m : Memory) (id : AllocId) (a : Allocation),
    (R.freeObjs m es).get? id = some a → a.live = true → m.get? id = some a
  | [], _, _, _, h, _ => h
  | e :: es, m, id, a, h, hl => by
    have ih := freeObjs_live es _ id a h hl
    cases hb : m.get? e.id with
    | none => simpa [hb] using ih
    | some b =>
      simp only [hb] at ih
      rw [get?_set hb] at ih
      split at ih
      · cases ih; simp at hl
      · exact ih

/-- `R.exit` frees the escaped objects: fewer live allocations, so the world still relates. -/
theorem worldRel_exit {s : R.RState} {x : X86.State} (e : R.Exit) (hm : MemRel s.st x) :
    WorldRel (R.exit s e).world x := fun id a ha hl i hi =>
  hm id a (freeObjs_live _ _ id a ha hl) hl i hi

/-! ### Proof lemmas -/

theorem rel_exc {st : OpSem.State} {x : X86.State} (e : ThinPointer) (h : Rel st x) :
    Rel { st with exception := e } x :=
  ⟨fun o h1 h2 b hb => h.frame o h1 h2 b hb, h.layout, h.zeroSized⟩

theorem writeRanges_one (st : OpSem.State) (off : Int) (n : Nat) (bs : List AbstractByte)
    (hl : bs.length = n) : R.writeRanges st [(off, n)] [bs] = st.writeFrame off bs := by
  unfold R.writeRanges
  simp [hl, List.foldlM_cons, bind, Except.bind]
  cases st.writeFrame off bs <;> rfl

theorem fpAddr_neg {x : X86.State} {fp F : Nat} (hb : x.reg .rbp = BitVec.ofNat 64 fp)
    (hfp : F ≤ fp) : fpAddr x (-(F : Int)) = BitVec.ofNat 64 (fp - F) := by
  rw [fpAddr, hb, ← ofNat_frameAddr fp (-(F : Int)) (by omega)]
  congr 1; omega

/-- After a call (its return or an unwind out of it): the answer's world and outgoing-area bytes
written, the frame relates to `x'` (see `CallEnd`). -/
theorem answer_rel {Owned : BitVec 64 → Prop} {lo : BitVec 64} {F n : Nat} {s : R.RState}
    {x1 x' : X86.State} {a : R.Answer}
    (hr : RRel s x1) (hce : CallEnd Owned lo (s.fp - F) n s.world x1 x' a)
    (hap : CallApart Owned lo F n (s.fp - F) s.st x1)
    (hrbp : x'.reg .rbp = x1.reg .rbp) (hfp : F ≤ s.fp) (hb : F + n < 2 ^ 62) :
    ∃ st1, R.writeRanges (s.withWorld a.world).st [(-(F : Int), n)] a.frame = .ok st1 ∧
      Rel st1 x' ∧ EscWF st1 ∧ MemRel st1 x' ∧
      st1.escaped = s.st.escaped ∧ st1.zeroSized = s.st.zeroSized ∧
      st1.exposed = a.world.exposed ∧ EscOnly s.st a.world.mem st1.mem := by
  obtain ⟨bs, hfr, hbs⟩ := hce.frame
  have hlen : bs.length = n := by rw [hbs.length, bytesAt_length]
  rw [hfr, writeRanges_one _ _ _ _ hlen]
  generalize hst0 : (s.withWorld a.world).st = st0
  have he0 : st0.escaped = s.st.escaped := by rw [← hst0]; rfl
  have hm0 : st0.mem = a.world.mem := by rw [← hst0]; rfl
  have hea : ∀ o, st0.escapedAt o = s.st.escapedAt o := by
    intro o; unfold OpSem.State.escapedAt; rw [he0]
  have hsize : s.st.mem.allocs.size ≤ a.world.mem.allocs.size := hce.grows.size
  have hids : ∀ e ∈ st0.escaped, e.id < st0.mem.allocs.size := by
    intro e he; rw [he0] at he; rw [hm0]; exact Nat.lt_of_lt_of_le (hr.wf.idLt e he) hsize
  obtain ⟨st1, hw⟩ := writeFrame_ok (-(F : Int)) bs hids
  have hfpx : ∀ o, fpAddr x' o = fpAddr x1 o := fun o => by simp [fpAddr, hrbp]
  have hlay : Layout st0 x' := by
    intro e he al hal
    rw [he0] at he; rw [hm0] at hal
    obtain ⟨al0, hal0⟩ : ∃ al0, s.st.mem.get? e.id = some al0 :=
      Option.isSome_iff_exists.1 (get?_isSome.2 (hr.wf.idLt e he))
    obtain ⟨a', ha', haddr, -⟩ := hce.grows.keep e.id al0 hal0
    rw [ha'] at hal; cases hal
    rw [haddr, hfpx]; exact hr.rel.layout e he al0 hal0
  have hzs : ∀ p ∈ st0.zeroSized, BitVec.ofNat 64 p.2 = fpAddr x' p.1 := by
    intro p hp
    have : st0.zeroSized = s.st.zeroSized := by rw [← hst0]; rfl
    rw [this] at hp; rw [hfpx]; exact hr.rel.zeroSized p hp
  have hwr : WorldRel a.world x' := hce.world
  have hfr' : ∀ o : Int, -2 ^ 63 ≤ o → o < 2 ^ 63 → ¬ (-(F : Int) ≤ o ∧ o < -(F : Int) + bs.length) →
      ∀ b, st0.byteAt o = .ok b → ByteRel b (x'.mem (fpAddr x' o)) := by
    intro o h1 h2 hout b hb'
    unfold OpSem.State.byteAt at hb'
    cases hf : st0.escapedAt o with
    | none =>
      rw [hf] at hb'
      simp only [pure, Except.pure, Except.ok.injEq] at hb'
      have hf' : s.st.escapedAt o = none := by rw [← hea]; exact hf
      have hfr0 : st0.frame o = s.st.frame o := by rw [← hst0]; rfl
      have hb0 : s.st.byteAt o = .ok b := by
        unfold OpSem.State.byteAt; rw [hf', ← hb', hfr0]; rfl
      by_cases hu : s.st.frame o = .uninit
      · rw [← hb', hfr0, hu]; trivial
      rw [hfpx, hce.mem _ (hap o h1 h2 hf' hu (by rw [hlen] at hout; exact hout))]
      exact hr.rel.frame o h1 h2 b hb0
    | some e =>
      rw [hf] at hb'
      simp only at hb'
      split at hb'
      · rename_i al hal
        split at hb'
        · cases hb'
        · rename_i hlv
          split at hb'
          · rename_i b' hb2
            cases hb'
            have hl : al.live = true := by simpa using hlv
            obtain ⟨hj, hjb⟩ := Array.getElem?_eq_some_iff.1 hb2
            rw [hm0] at hal
            have := hwr e.id al hal hl _ hj
            rw [hjb] at this
            rw [← addr_of_hit hlay hf (by rw [hm0]; exact hal)]
            exact this
          · cases hb'
      · cases hb'
  have hbs' : BytesRel bs (bytesAt x'.mem (fpAddr x' (-(F : Int))) bs.length) := by
    rw [fpAddr_neg (by rw [hrbp]; exact hr.rbp) hfp, hlen]; exact hbs
  obtain ⟨hrel, hsame⟩ := rel_writeFrame_in hfr' hlay hzs hw (by omega) (by omega) hbs'
  have hmr : MemRel st1 x' := by
    refine memRel_writeRel (by rw [← hst0]; exact hwr) hlay hw fun i hi => ?_
    have := hbs'.getElem i hi (by rw [bytesAt_length]; exact hi)
    rw [getElem_bytesAt, ← fpAddr_add] at this
    exact this
  obtain ⟨hs1, hs2, hs3, hs4, hs5⟩ := hsame
  refine ⟨st1, hw, hrel, ⟨fun e he => ?_, fun e he e' he' hid => ?_⟩, hmr, hs1.trans he0, ?_,
    ?_, ?_⟩
  · rw [hs1, he0] at he; rw [hs2.1, hm0]; exact Nat.lt_of_lt_of_le (hr.wf.idLt e he) hsize
  · rw [hs1, he0] at he he'; exact hr.wf.idInj e he e' he' hid
  · rw [hs5, ← hst0]; rfl
  · rw [hs3, ← hst0]; rfl
  · rw [← hm0]; exact hs2.of_escaped (by rw [he0])


theorem _root_.Ryo.Proofs.CallLemmas.RangeApart.of_escOnly {st st' st'' : OpSem.State} {x : X86.State} {D : Int} {n : Nat}
    (h : RangeApart st x D n) (he : st'.escaped = st.escaped) (hm : EscOnly st'' st.mem st'.mem) :
    RangeApart st' x D n := by
  intro i hi
  have hea : st'.escapedAt (D + i) = st.escapedAt (D + i) := by
    unfold OpSem.State.escapedAt; rw [he]
  refine ⟨by rw [hea]; exact (h i hi).1, fun id al hg hl => ?_⟩
  obtain ⟨a0, ha0, hae, hsz, -⟩ := hm.2 id al hg
  have hl0 : a0.live = true := by rw [hae] at hl; exact hl
  have := (h i hi).2 id a0 ha0 hl0
  have haddr : al.addr = a0.addr := by rw [hae]
  have hs : al.size = a0.size := hsz
  rw [haddr, hs]; exact this

/-- The bytes the result stores write (the parts of return kind `k`, at `d`) are private and at
no live allocation's address. -/
def ResultApart (k : Nat) (d : BitVec 32) (st : OpSem.State) (x : X86.State) : Prop :=
  ∀ parts, R.retRegs k false = .ok parts → ∀ q ∈ parts,
    CallLemmas.RangeApart st x (d.toInt + q.1.off) q.1.size

theorem saved_ne {pe : Bool} {i : Fin 16} (h : Saved pe i) : i ≠ 0 ∧ i ≠ 2 ∧ i ≠ 11 ∧ i ≠ 4 := by
  rcases h with h | ⟨-, h | h⟩
  · rcases h with rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  · subst h; decide
  · subst h; decide

theorem argRegs_cons {st : OpSem.State} {s w : BitVec 32} {rest : List (BitVec 32)} {regs : R.Regs}
    (h : R.argRegs st (s :: w :: rest) = .ok regs) :
    ∃ rs a bs, R.argRegs st rest = .ok rs ∧
      ArgReg.of? (if (w.toNat &&& argAddr != 0) = true then w.toNat - argAddr else w.toNat) false
        = some a ∧
      (rs.vals.any fun x => x.fst == R.Reg.ofArgReg a) = false ∧
      (((w.toNat &&& argAddr != 0) = true ∧ a.xmm = false ∧ a.size = 8 ∧
          ∃ p, st.addrOf s.toInt = .ok p ∧ bs = encodePtr p) ∨
        ((w.toNat &&& argAddr != 0) = false ∧ st.readFrame s.toInt a.size = .ok bs)) ∧
      regs = ⟨(R.Reg.ofArgReg a, R.zext bs (R.Reg.ofArgReg a).width) :: rs.vals⟩ := by
  unfold R.argRegs at h
  simp only [bind, Except.bind] at h
  cases hrs : R.argRegs st rest with
  | error e => simp [hrs] at h
  | ok rs =>
  simp only [hrs] at h
  cases ha : ArgReg.of? (if (w.toNat &&& argAddr != 0) = true then w.toNat - argAddr else w.toNat) false with
  | none =>
    simp only [ha] at h
    simp [illFormed, throw, throwThe, MonadExceptOf.throw] at h
  | some a =>
  simp only [ha] at h
  by_cases hdup : (rs.vals.any fun x => x.fst == R.Reg.ofArgReg a) = true
  · simp [hdup, illFormed, throw, throwThe, MonadExceptOf.throw] at h
  simp only [hdup, Bool.false_eq_true, ↓reduceIte] at h
  by_cases hb : (w.toNat &&& argAddr != 0) = true
  · simp only [hb, ↓reduceIte] at h
    by_cases hx : (a.xmm || a.size != 8) = true
    · simp [hx, illFormed, throw, throwThe, MonadExceptOf.throw] at h
    simp only [hx, Bool.false_eq_true, ↓reduceIte] at h
    cases hp : st.addrOf s.toInt with
    | error e => simp [hp] at h
    | ok p =>
      simp only [hp, pure, Except.pure, Except.ok.injEq] at h
      simp only [Bool.or_eq_true, bne_iff_ne, ne_eq, not_or, Bool.not_eq_true, Decidable.not_not] at hx
      exact ⟨rs, a, _, rfl, rfl, Bool.eq_false_iff.2 hdup, .inl ⟨hb, hx.1, hx.2, p, rfl, rfl⟩, h.symm⟩
  · simp only [hb, Bool.false_eq_true, ↓reduceIte] at h
    cases hp : st.readFrame s.toInt a.size with
    | error e => simp [hp] at h
    | ok bs =>
      simp only [hp, pure, Except.pure, Except.ok.injEq] at h
      exact ⟨rs, a, bs, rfl, rfl, Bool.eq_false_iff.2 hdup, .inr ⟨Bool.eq_false_iff.2 hb, hp⟩, h.symm⟩


/-- What `ArgReg.of? r false` checks: an `xmm` of 2, 4, 8 or 16 bytes and index below 8, or an
integer register of 1, 2, 4 or 8 bytes and index below 6. -/
theorem argReg_of_false {r : Nat} {a : ArgReg} (h : ArgReg.of? r false = some a) :
    (a.xmm = true → (a.size = 2 ∨ a.size = 4 ∨ a.size = 8 ∨ a.size = 16) ∧ a.index < 8) ∧
    (a.xmm = false → (a.size = 1 ∨ a.size = 2 ∨ a.size = 4 ∨ a.size = 8) ∧ a.index < 6) := by
  unfold ArgReg.of? at h
  simp only [Option.ite_none_right_eq_some, Option.some.injEq] at h
  obtain ⟨hok, rfl⟩ := h
  simp only [Bool.and_eq_true, beq_iff_eq] at hok
  obtain ⟨⟨hok, -⟩, -⟩ := hok
  simp only
  generalize (r &&& 32 != 0) = xb at hok ⊢
  generalize r &&& 31 = sz at hok ⊢
  generalize r >>> 8 = ix at hok ⊢
  cases xb <;> simp at hok ⊢ <;> omega

/-- The integer argument registers of the convention. -/
abbrev conv (pe : Bool) : Nat := if pe then 4 else 6

theorem intArg_ne11 (pe : Bool) (j : Nat) : (intArg pe j).idx ≠ 11 := by
  have := ArgRet.intArg_mem pe j
  generalize intArg pe j = g at this
  simp only [List.mem_cons, List.not_mem_nil, or_false] at this
  rcases this with h | h | h | h | h | h | h <;> subst h <;> decide

theorem intArg_inj {pe : Bool} {j j' : Nat} (hj : j < conv pe) (hj' : j' < conv pe)
    (h : (intArg pe j).idx = (intArg pe j').idx) : j = j' := by
  revert h
  cases pe <;> simp only [conv, Bool.false_eq_true, ↓reduceIte] at hj hj'
  · rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 ∨ j = 5) with
      rfl | rfl | rfl | rfl | rfl | rfl <;>
    rcases (by omega : j' = 0 ∨ j' = 1 ∨ j' = 2 ∨ j' = 3 ∨ j' = 4 ∨ j' = 5) with
      rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  · rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3) with rfl | rfl | rfl | rfl <;>
    rcases (by omega : j' = 0 ∨ j' = 1 ∨ j' = 2 ∨ j' = 3) with rfl | rfl | rfl | rfl <;> decide

theorem intArg_keep {pe : Bool} {j : Nat} (hj : j < conv pe) :
    ∀ i : Fin 16, (i = 0 ∨ i = 4 ∨ i = 5 ∨ Saved pe i) → i ≠ (intArg pe j).idx := by
  simp only [Saved, Counter.CalleeSaved]
  cases pe <;> simp only [conv, Bool.false_eq_true, ↓reduceIte] at hj
  · rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 ∨ j = 5) with
      rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  · rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3) with rfl | rfl | rfl | rfl <;> decide

theorem xmmIdx_inj {i j : Nat} (hi : i < 16) (hj : j < 16) (h : ArgRet.xmmIdx i = ArgRet.xmmIdx j) :
    i = j := by
  simp only [ArgRet.xmmIdx, Fin.mk.injEq] at h
  omega

theorem exec_leaM (ctx : Ctx) (r : Reg) (m : M) (y : X86.State) :
    ∃ y', (Item.leaM r m).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧ y'.reg r = y.ea m ∧
      (∀ i, i ≠ r.idx → y'.regs i = y.regs i) ∧ y'.xmm = y.xmm ∧
      y'.rip = y.rip + BitVec.ofNat 64 (Item.leaM r m).size := by
  refine ⟨_, rfl, rfl, ?_, ?_, rfl, rfl⟩
  · simp [State.reg, State.setReg, State.ea, State.jump]
  · intro i hi; simp [State.setReg, State.jump, hi]

/-- `paramItem`'s cases. -/
theorem paramItem_cases {pe : Bool} {s w : BitVec 32} {its : List Item} {a : ArgReg}
    (h : paramItem pe s w = some its)
    (ha : ArgReg.of? (if (w.toNat &&& argAddr != 0) = true then w.toNat - argAddr else w.toNat)
      false = some a) :
    ((w.toNat &&& argAddr != 0) = true ∧ a.xmm = false ∧ a.index < conv pe ∧
        its = [.leaM (intArg pe a.index) (M.frame s)]) ∨
      ((w.toNat &&& argAddr != 0) = false ∧ a.xmm = true ∧ a.size = 2 ∧
        its = [.ld .w false .r11 (M.frame s), .movd true a.index .r11]) ∨
      ((w.toNat &&& argAddr != 0) = false ∧ a.xmm = true ∧ a.size ≠ 2 ∧
        its = [.sse false a.size a.index (M.frame s)]) ∨
      ((w.toNat &&& argAddr != 0) = false ∧ a.xmm = false ∧ a.index < conv pe ∧
        its = [.ld (widthOf a.size) false (intArg pe a.index) (M.frame s)]) := by
  unfold paramItem at h
  dsimp only at h
  rw [ha] at h
  dsimp only at h
  by_cases hb : (w.toNat &&& argAddr != 0) = true
  · simp only [hb, ↓reduceIte] at h
    by_cases hc : (a.xmm || a.size != 8 || decide (conv pe ≤ a.index)) = true
    · simp only [conv] at hc; simp [hc] at h
    · simp only [conv] at hc
      simp only [hc, Bool.false_eq_true, ↓reduceIte, Option.some.injEq] at h
      simp only [Bool.or_eq_true, bne_iff_ne, ne_eq, decide_eq_true_eq, not_or,
        Bool.not_eq_true, Decidable.not_not, Nat.not_le] at hc
      exact .inl ⟨hb, hc.1.1, by simp only [conv]; omega, h.symm⟩
  · have hb' : (w.toNat &&& argAddr != 0) = false := Bool.eq_false_iff.2 hb
    simp only [hb', Bool.false_eq_true, ↓reduceIte] at h
    cases hx : a.xmm
    · simp only [hx, Bool.false_eq_true, ↓reduceIte] at h
      by_cases hc : a.index < conv pe
      · simp only [conv] at hc
        simp only [hc, ↓reduceIte, Option.some.injEq] at h
        exact .inr (.inr (.inr ⟨hb', rfl, by simp only [conv]; omega, h.symm⟩))
      · simp only [conv] at hc; simp [hc] at h
    · simp only [hx, ↓reduceIte] at h
      by_cases h2 : a.size = 2
      · simp only [h2, beq_self_eq_true, ↓reduceIte, Option.some.injEq] at h
        exact .inr (.inl ⟨hb', rfl, h2, h.symm⟩)
      · have : (a.size == 2) = false := by simpa using h2
        simp only [this, Bool.false_eq_true, ↓reduceIte, Option.some.injEq] at h
        exact .inr (.inr (.inl ⟨hb', rfl, h2, h.symm⟩))


open Ryo.Proofs.ArgRet in
/-- One argument register's load against `argRegs`' entry for it. -/
theorem param_one (ctx : Ctx) {pe : Bool} {st : OpSem.State} {x0 y : X86.State} {s w : BitVec 32}
    {its : List Item} {a : ArgReg} {bs : List AbstractByte}
    (hr : Rel st x0) (hym : y.mem = x0.mem) (hyb : y.reg .rbp = x0.reg .rbp)
    (hp : paramItem pe s w = some its)
    (ha : ArgReg.of? (if (w.toNat &&& argAddr != 0) = true then w.toNat - argAddr else w.toNat)
      false = some a)
    (hbs : ((w.toNat &&& argAddr != 0) = true ∧ a.xmm = false ∧ a.size = 8 ∧
          ∃ p, st.addrOf s.toInt = .ok p ∧ bs = encodePtr p) ∨
        ((w.toNat &&& argAddr != 0) = false ∧ st.readFrame s.toInt a.size = .ok bs)) :
    ∃ y1, execItems ctx its y = .ok y1 ∧ y1.mem = y.mem ∧
      y1.rip = y.rip + BitVec.ofNat 64 (its.map Item.size).sum ∧
      (∀ i : Fin 16, (∀ j < conv pe, i ≠ (intArg pe j).idx) → i ≠ 11 → y1.regs i = y.regs i) ∧
      BytesRel (R.zext bs (R.Reg.ofArgReg a).width) (argBytes pe y1 (R.Reg.ofArgReg a)) ∧
      (∀ r, IsArg pe r → r ≠ R.Reg.ofArgReg a → argBytes pe y1 r = argBytes pe y r) := by
  have hspec := argReg_of_false ha
  have hsb := toInt_bounds s
  have hfp : fpAddr y s.toInt = fpAddr x0 s.toInt := by simp [fpAddr, hyb]
  rcases paramItem_cases hp ha with ⟨hb, hx, hix, rfl⟩ | ⟨hb, hx, h2, rfl⟩ | ⟨hb, hx, h2, rfl⟩ |
    ⟨hb, hx, hix, rfl⟩
  · -- by address
    obtain ⟨-, -, h8, p, hp', rfl⟩ : (w.toNat &&& argAddr != 0) = true ∧ a.xmm = false ∧
        a.size = 8 ∧ ∃ p, st.addrOf s.toInt = .ok p ∧ bs = encodePtr p := by
      rcases hbs with h | ⟨h, -⟩
      · exact h
      · rw [hb] at h; cases h
    obtain ⟨y1, e1, m1, r1, rs1, x1, p1⟩ := exec_leaM ctx (intArg pe a.index) (M.frame s) y
    have hreg : R.Reg.ofArgReg a = .gpr a.index := by simp [R.Reg.ofArgReg, hx]
    refine ⟨y1, by rw [execItems_cons_ok e1]; rfl, m1, by rw [p1]; simp, ?_, ?_, ?_⟩
    · intro i hi _; exact rs1 i (hi a.index hix)
    · rw [hreg]
      have hl : (encodePtr p).length = 8 := by
        rw [(BytesRel.encodePtr p).length, leEncode_length]
      simp only [R.Reg.width, argBytes, R.zext, hl, Nat.sub_self, List.replicate_zero,
        List.append_nil]
      rw [r1, ea_frame, hfp, ← Inline.addrOf_rel hr hp', BitVec.toNat_ofNat]
      rw [show (2 : Nat) ^ 64 = 2 ^ (8 * 8) by rfl, Theorems.leEncode_mod]
      exact BytesRel.encodePtr p
    · intro r hr' hne
      cases r with
      | gpr i' =>
        have hi' : i' ≠ a.index := fun h => hne (by rw [hreg, h])
        simp only [argBytes, State.reg]
        rw [rs1 _ (fun h => hi' (intArg_inj hr' hix h))]
      | xmm i' => simp [argBytes, x1]
  · -- a 2-byte xmm through r11
    obtain hrd : st.readFrame s.toInt a.size = .ok bs := by
      rcases hbs with ⟨h, -⟩ | ⟨-, h⟩
      · rw [hb] at h; cases h
      · exact h
    obtain ⟨y1, e1, m1, r1, rs1, x1, p1⟩ := exec_ld ctx .w .r11 (M.frame s) y
    obtain ⟨y2, e2, m2, r2, rs2, x2, p2⟩ := exec_movd_to ctx a.index .r11 y1
    have hreg : R.Reg.ofArgReg a = .xmm a.index := by simp [R.Reg.ofArgReg, hx]
    have hix : a.index < 8 := (hspec.1 hx).2
    refine ⟨y2, by rw [execItems_cons_ok e1, execItems_cons_ok e2]; rfl, by rw [m2, m1],
      by rw [p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add], ?_, ?_, ?_⟩
    · intro i _ h11; rw [x2, rs1 i h11]
    · rw [hreg]
      have hbr := readFrame_rel hr hrd (by omega) (by omega)
      have hlt := Theorems.leDecode_lt (bytesAt x0.mem (fpAddr x0 s.toInt) a.size)
      rw [bytesAt_length, h2] at hlt
      simp only [R.Reg.width, argBytes]
      rw [r2, r1, ea_frame, hfp, hym, show W.w.bits / 8 = 2 from rfl, readNat_eq, ← h2,
        setWidth_ofNat_128 _ (by rw [h2]; exact hlt), BitVec.toNat_ofNat,
        show (2 : Nat) ^ 128 = 2 ^ (8 * 16) by rfl, Theorems.leEncode_mod]
      exact bytesRel_zext hbr (by rw [bytesAt_length]; omega)
    · intro r hr' hne
      cases r with
      | gpr i' =>
        simp only [argBytes, State.reg]
        rw [x2, rs1 _ (intArg_ne11 pe i')]
      | xmm i' =>
        have hi' : i' ≠ a.index := fun h => hne (by rw [hreg, h])
        have hi8 : i' < 8 := by simp only [IsArg] at hr'; split at hr' <;> omega
        simp only [argBytes]
        rw [rs2 _ (fun h => hi' (xmmIdx_inj (by omega) (by omega) h)), x1]
  · -- movss / movsd / movups
    obtain hrd : st.readFrame s.toInt a.size = .ok bs := by
      rcases hbs with ⟨h, -⟩ | ⟨-, h⟩
      · rw [hb] at h; cases h
      · exact h
    have hs : a.size = 4 ∨ a.size = 8 ∨ a.size = 16 := by
      have := (hspec.1 hx).1; omega
    obtain ⟨y1, e1, m1, r1, x1, rs1, p1⟩ := exec_sse_ld ctx a.size a.index (M.frame s) y hs
    have hreg : R.Reg.ofArgReg a = .xmm a.index := by simp [R.Reg.ofArgReg, hx]
    have hix : a.index < 8 := (hspec.1 hx).2
    refine ⟨y1, by rw [execItems_cons_ok e1]; rfl, m1, by rw [p1]; simp, ?_, ?_, ?_⟩
    · intro i _ _; rw [rs1]
    · rw [hreg]
      have hbr := readFrame_rel hr hrd (by omega) (by omega)
      simp only [R.Reg.width, argBytes]
      rw [r1, ea_frame, hfp, hym, readNat_eq, BitVec.toNat_ofNat,
        show (2 : Nat) ^ 128 = 2 ^ (8 * 16) by rfl, Theorems.leEncode_mod]
      exact bytesRel_zext hbr (by rw [bytesAt_length]; omega)
    · intro r hr' hne
      cases r with
      | gpr i' => simp only [argBytes, State.reg]; rw [rs1]
      | xmm i' =>
        have hi' : i' ≠ a.index := fun h => hne (by rw [hreg, h])
        have hi8 : i' < 8 := by simp only [IsArg] at hr'; split at hr' <;> omega
        simp only [argBytes]
        rw [x1 _ (fun h => hi' (xmmIdx_inj (by omega) (by omega) h))]
  · -- mov / movzx
    obtain hrd : st.readFrame s.toInt a.size = .ok bs := by
      rcases hbs with ⟨h, -⟩ | ⟨-, h⟩
      · rw [hb] at h; cases h
      · exact h
    have hs := (hspec.2 hx).1
    obtain ⟨y1, e1, m1, r1, rs1, x1, p1⟩ :=
      exec_ld ctx (widthOf a.size) (intArg pe a.index) (M.frame s) y
    have hreg : R.Reg.ofArgReg a = .gpr a.index := by simp [R.Reg.ofArgReg, hx]
    have hw : (widthOf a.size).bits / 8 = a.size := by
      rcases hs with h | h | h | h <;> rw [h] <;> rfl
    refine ⟨y1, by rw [execItems_cons_ok e1]; rfl, m1, by rw [p1]; simp, ?_, ?_, ?_⟩
    · intro i hi _; exact rs1 i (hi a.index hix)
    · rw [hreg]
      have hbr := readFrame_rel hr hrd (by omega) (by omega)
      simp only [R.Reg.width, argBytes]
      rw [r1, ea_frame, hfp, hym, hw, readNat_eq, BitVec.toNat_ofNat,
        show (2 : Nat) ^ 64 = 2 ^ (8 * 8) by rfl, Theorems.leEncode_mod]
      exact bytesRel_zext hbr (by rw [bytesAt_length]; omega)
    · intro r hr' hne
      cases r with
      | gpr i' =>
        have hi' : i' ≠ a.index := fun h => hne (by rw [hreg, h])
        simp only [argBytes, State.reg]
        rw [rs1 _ (fun h => hi' (intArg_inj hr' hix h))]
      | xmm i' => simp [argBytes, x1]

open Ryo.Proofs.ArgRet in
theorem regs_get_cons (r r' : R.Reg) (b : List AbstractByte) (vals : List (R.Reg × List AbstractByte)) :
    R.Regs.get ⟨(r, b) :: vals⟩ r' = if r = r' then b else R.Regs.get ⟨vals⟩ r' := by
  unfold R.Regs.get
  simp only [List.find?_cons]
  by_cases h : r = r'
  · simp [h]
  · have : (r == r') = false := by simpa using h
    simp only [this, h, ↓reduceIte]

open Ryo.Proofs.ArgRet in
theorem argBytes_length (pe : Bool) (y : X86.State) (r : R.Reg) :
    (argBytes pe y r).length = r.width := by
  cases r <;> simp [argBytes, R.Reg.width, leEncode_length]

open Ryo.Proofs.ArgRet in
/-- The argument loads against `argRegs`: memory unchanged, among the integer registers only the
convention's argument registers and `r11` changed, each listed register relating, the others
kept. The loads also write the `xmm` argument registers (`movss`/`movsd`/`movups`,
`movd xmm, r11`), which this doesn't state. -/
theorem exec_params (ctx : Ctx) (pe : Bool) {st : OpSem.State} {x0 : X86.State} (hr : Rel st x0) :
    ∀ (ws : List (BitVec 32)) (regs : R.Regs) (its : List Item) (y : X86.State),
      R.argRegs st ws = .ok regs → paramItems pe ws = some its → y.mem = x0.mem →
      y.reg .rbp = x0.reg .rbp →
      ∃ y', execItems ctx its y = .ok y' ∧ y'.mem = y.mem ∧
        y'.rip = y.rip + BitVec.ofNat 64 (its.map Item.size).sum ∧
        (∀ i : Fin 16, (∀ j < conv pe, i ≠ (intArg pe j).idx) → i ≠ 11 → y'.regs i = y.regs i) ∧
        (∀ r, IsArg pe r → (regs.vals.find? (·.1 == r)).isSome → RegRel pe regs y' r) ∧
        (∀ r, IsArg pe r → regs.vals.find? (·.1 == r) = none → argBytes pe y' r = argBytes pe y r)
  | [], regs, its, y, h, hp, _, _ => by
    simp only [R.argRegs, pure, Except.pure, Except.ok.injEq] at h
    simp only [paramItems, Option.some.injEq] at hp
    subst h hp
    exact ⟨y, rfl, rfl, by simp, fun _ _ _ => rfl, fun r _ h => by simp at h, fun _ _ _ => rfl⟩
  | [_], regs, its, y, _, hp, _, _ => by simp [paramItems] at hp
  | s :: w :: rest, regs, its, y, h, hp, hym, hyb => by
    obtain ⟨rs, a, bs, hrs, ha, hdup, hbs, rfl⟩ := argRegs_cons h
    simp only [paramItems, Option.bind_eq_bind, Option.pure_def] at hp
    cases h1 : paramItem pe s w with
    | none => simp [h1] at hp
    | some its1 =>
    cases h2 : paramItems pe rest with
    | none => simp [h1, h2] at hp
    | some its2 =>
    simp only [h1, h2, Option.bind_some, Option.some.injEq] at hp
    subst hp
    obtain ⟨y1, e1, m1, p1, rs1, hrel1, ho1⟩ := param_one ctx hr hym hyb h1 ha hbs
    have hk5 : y1.regs 5 = y.regs 5 :=
      rs1 5 (fun j hj => intArg_keep hj 5 (by simp)) (by decide)
    obtain ⟨y2, e2, m2, p2, rs2, hrel2, ho2⟩ := exec_params ctx pe hr rest rs its2 y1 hrs
      h2 (m1.trans hym) (by simp only [State.reg] at hyb ⊢; rw [show Reg.rbp.idx = 5 from rfl] at hyb ⊢; rw [hk5]; exact hyb)
    have hnone : rs.vals.find? (·.1 == R.Reg.ofArgReg a) = none := by
      rw [List.find?_eq_none]
      intro q hq hq'
      have := List.any_eq_false.1 hdup q hq
      exact this hq'
    refine ⟨y2, by rw [ArgRet.execItems_append, e1]; exact e2, m2.trans m1,
      by rw [p2, p1]; simp [BitVec.add_assoc, BitVec.ofNat_add],
      fun i hi h11 => by rw [rs2 i hi h11, rs1 i hi h11], ?_, ?_⟩
    · intro r hr' hs'
      unfold RegRel
      rw [regs_get_cons]
      by_cases hrr : R.Reg.ofArgReg a = r
      · subst hrr
        simp only [↓reduceIte]
        rw [ho2 _ hr' hnone]; exact hrel1
      · simp only [hrr, ↓reduceIte]
        have : (rs.vals.find? (·.1 == r)).isSome := by
          simpa [List.find?_cons, hrr] using hs'
        exact hrel2 r hr' this
    · intro r hr' hn
      have hrr : R.Reg.ofArgReg a ≠ r := by
        intro h; subst h; simp at hn
      have hn' : rs.vals.find? (·.1 == r) = none := by
        simpa [List.find?_cons, hrr] using hn
      rw [ho2 r hr' hn', ho1 r hr' (Ne.symm hrr)]

open Ryo.Proofs.ArgRet in
theorem argsRel_of {pe : Bool} {regs : R.Regs} {y : X86.State}
    (h : ∀ r, IsArg pe r → (regs.vals.find? (·.1 == r)).isSome → RegRel pe regs y r) :
    ArgsRel pe regs y := by
  intro r hr
  cases hf : regs.vals.find? (·.1 == r) with
  | some q => exact h r hr (by simp [hf])
  | none =>
    unfold RegRel R.Regs.get
    rw [hf]
    simp only
    have := BytesRel.uninit (argBytes pe y r)
    rwa [argBytes_length] at this

theorem exec_loadRip (ctx : Ctx) (r : Reg) (to : Ref) (y : X86.State) :
    ∃ y', (Item.loadRip r to).exec ctx y = .ok y' ∧ y'.mem = y.mem ∧
      y'.reg r = y.mem.read64 (ctx.addrOf to) ∧
      (∀ i, i ≠ r.idx → y'.regs i = y.regs i) ∧ y'.xmm = y.xmm ∧
      y'.rip = y.rip + BitVec.ofNat 64 (Item.loadRip r to).size := by
  refine ⟨_, rfl, rfl, ?_, ?_, rfl, rfl⟩
  · simp [State.reg, State.setReg, State.jump]
  · intro i hi; simp [State.setReg, State.jump, hi]

/-- A call's head (the item before the loads, if any) and its call: the target the call jumps
to is the callee's address, in any memory that agrees with `x`'s off the stack below `sp`. -/
theorem head_exec (ctx : Ctx) {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item} {ci : Item}
    {st : OpSem.State} {x : X86.State} {cal : R.Callee}
    (hh : callHead f fo = some (pre, ci)) (hc : R.callee st f fo = .ok cal) (hr : Rel st x) :
    ∃ y0, execItems ctx pre x = .ok y0 ∧ y0.mem = x.mem ∧
      (∀ i : Fin 16, i ≠ 0 → y0.regs i = x.regs i) ∧ y0.xmm = x.xmm ∧
      y0.rip = x.rip + BitVec.ofNat 64 (pre.map Item.size).sum ∧
      ∀ y : X86.State, y.mem = x.mem → y.reg .rax = y0.reg .rax → ∃ tgt,
        ci.exec ctx y = .ok (((y.jump (y.rip + BitVec.ofNat 64 ci.size)).push
          (y.rip + BitVec.ofNat 64 ci.size)).jump tgt) ∧
        ∀ (lo sp : BitVec 64) (m' : Mem), (∀ b, ¬ InStack lo sp b → m' b = x.mem b) →
          SymsApart ctx lo sp x.mem → tgt = calleeTarget ctx m' cal := by
  have hsym : ∀ (lo sp : BitVec 64) (m' : Mem), (∀ b, ¬ InStack lo sp b → m' b = x.mem b) →
      SymsApart ctx lo sp x.mem → ∀ s, ∀ a ∈ [ctx.addrOf (.sym s), x.mem.read64 (ctx.addrOf (.sym s))],
        m'.read64 a = x.mem.read64 a := by
    intro lo sp m' hm' hs s a ha
    exact read64_congr fun i hi => hm' _ (hs s a ha i hi)
  cases fo with
  | func g =>
    simp only [callHead] at hh
    split at hh
    · rename_i hfc
      simp only [Option.some.injEq, Prod.mk.injEq] at hh
      obtain ⟨rfl, rfl⟩ := hh
      have : cal = .func g := by
        simp only [R.callee, beq_iff_eq] at hc hfc
        simp [hfc, pure, Except.pure] at hc; exact hc.symm
      subst this
      refine ⟨x, rfl, rfl, fun _ _ => rfl, rfl, by simp, fun y _ _ => ⟨_, rfl, ?_⟩⟩
      intros; rfl
    · cases hh
  | sym s =>
    simp only [callHead] at hh
    split at hh
    · rename_i hfc
      simp only [Option.some.injEq, Prod.mk.injEq] at hh
      obtain ⟨rfl, rfl⟩ := hh
      have : cal = .sym s := by
        simp only [R.callee] at hc
        simp [hfc, pure, Except.pure] at hc; exact hc.symm
      subst this
      refine ⟨x, rfl, rfl, fun _ _ => rfl, rfl, by simp, fun y hy _ => ⟨_, rfl, ?_⟩⟩
      intro lo sp m' hm' hs
      simp only [calleeTarget, State.jump]
      rw [hy, hsym lo sp m' hm' hs s _ (by simp)]
    · split at hh
      · rename_i hfc hfi
        simp only [Option.some.injEq, Prod.mk.injEq] at hh
        obtain ⟨rfl, rfl⟩ := hh
        have : cal = .symInd s := by
          simp only [R.callee] at hc
          simp [hfc, hfi, pure, Except.pure] at hc; exact hc.symm
        subst this
        obtain ⟨y0, e0, m0, r0, rs0, x0, p0⟩ := exec_loadRip ctx .rax (.sym s) x
        refine ⟨y0, by rw [ArgRet.execItems_cons_ok e0]; rfl, m0, fun i hi => rs0 i hi, x0,
          by rw [p0]; simp, fun y hy hra => ⟨_, rfl, ?_⟩⟩
        intro lo sp m' hm' hs
        show y.mem.read64 (y.reg .rax) = m'.read64 (m'.read64 (ctx.addrOf (.sym s)))
        rw [hy, hra, r0, hsym lo sp m' hm' hs s (ctx.addrOf (.sym s)) (by simp),
          hsym lo sp m' hm' hs s (x.mem.read64 (ctx.addrOf (.sym s))) (by simp)]
      · cases hh
  | slot p =>
    simp only [callHead] at hh
    split at hh
    · rename_i hfc
      simp only [Option.some.injEq, Prod.mk.injEq] at hh
      obtain ⟨rfl, rfl⟩ := hh
      simp only [beq_iff_eq] at hfc
      subst hfc
      simp only [R.callee, bind, Except.bind] at hc
      cases hrd : st.readFrame p.toInt 8 with
      | error e => simp [hrd] at hc
      | ok bs =>
      simp only [hrd] at hc
      cases hpt : asPtr bs with
      | error e => simp [hpt] at hc
      | ok ptr =>
      simp only [hpt, pure, Except.pure] at hc
      simp at hc
      subst hc
      have hb := toInt_bounds p
      have hpa := asPtr_rel (readFrame_rel hr hrd (by omega) (by omega)) hpt
      obtain ⟨y0, e0, m0, r0, rs0, x0, p0⟩ := ArgRet.exec_ld ctx .q .rax (M.frame p) x
      refine ⟨y0, by rw [ArgRet.execItems_cons_ok e0]; rfl, m0, fun i hi => rs0 i hi, x0,
        by rw [p0]; simp, fun y hy hra => ⟨_, rfl, ?_⟩⟩
      intro lo sp m' _ _
      show y.reg .rax = BitVec.ofNat 64 ptr.addr
      rw [hra, r0, ea_frame, show W.q.bits / 8 = 8 from rfl, readNat_eq, hpa]
    · cases hh
  | _ => simp [callHead] at hh

theorem rbp_sub_eq {x : X86.State} {F : Nat} :
    x.reg .rbp - BitVec.ofNat 64 F = fpAddr x (-(F : Int)) := by
  simp only [fpAddr, BitVec.ofInt_neg, BitVec.ofInt_natCast, BitVec.sub_eq_add_neg]

/-- The push of the return address keeps the relations, given `StackApart`. -/
theorem rel_push {st : OpSem.State} {x x1 : X86.State} {lo : BitVec 64} (hr : Rel st x)
    (hm : MemRel st x) (hap : Handler.StackApart lo st x)
    (hmem : ∀ b, ¬ InStack lo x.rsp b → x1.mem b = x.mem b) (hb : x1.reg .rbp = x.reg .rbp) :
    Rel st x1 ∧ MemRel st x1 :=
  hap.rel hr hm hb hmem

/-- A tail call's head and its jump: the jump goes to the callee's address. -/
theorem tailHead_exec (ctx : Ctx) {w : Bool} {f : Full.Opcode} {fo : R.Opnd Nat} {pre : List Item}
    {j : Item} {st : OpSem.State} {x : X86.State} {cal : R.Callee}
    (hh : tailHead w f fo = some (pre, j)) (hc : R.callee st f fo = .ok cal) (hr : Rel st x) :
    ∃ y0, execItems ctx pre x = .ok y0 ∧ y0.mem = x.mem ∧
      (∀ i : Fin 16, i ≠ 0 → y0.regs i = x.regs i) ∧ y0.xmm = x.xmm ∧
      y0.rip = x.rip + BitVec.ofNat 64 (pre.map Item.size).sum ∧
      ∀ y : X86.State, y.reg .rax = y0.reg .rax → ∀ m : Mem,
        j.exec ctx y = .ok (y.jump (calleeTarget ctx m cal)) := by
  cases fo with
  | func g =>
    simp only [tailHead] at hh
    split at hh
    · rename_i hfc
      simp only [Option.some.injEq, Prod.mk.injEq] at hh
      obtain ⟨rfl, rfl⟩ := hh
      have : cal = .func g := by
        simp only [R.callee, beq_iff_eq] at hc hfc
        simp [hfc, pure, Except.pure] at hc; exact hc.symm
      subst this
      exact ⟨x, rfl, rfl, fun _ _ => rfl, rfl, by simp, fun y _ m => rfl⟩
    · cases hh
  | slot p =>
    simp only [tailHead] at hh
    split at hh
    · rename_i hfc
      simp only [Option.some.injEq, Prod.mk.injEq] at hh
      obtain ⟨rfl, rfl⟩ := hh
      simp only [beq_iff_eq] at hfc
      subst hfc
      simp only [R.callee, bind, Except.bind] at hc
      cases hrd : st.readFrame p.toInt 8 with
      | error e => simp [hrd] at hc
      | ok bs =>
      simp only [hrd] at hc
      cases hpt : asPtr bs with
      | error e => simp [hpt] at hc
      | ok ptr =>
      simp only [hpt, pure, Except.pure] at hc
      simp at hc
      subst hc
      have hb := toInt_bounds p
      have hpa := asPtr_rel (readFrame_rel hr hrd (by omega) (by omega)) hpt
      obtain ⟨y0, e0, m0, r0, rs0, x0, p0⟩ := ArgRet.exec_ld ctx .q .rax (M.frame p) x
      refine ⟨y0, by rw [ArgRet.execItems_cons_ok e0]; rfl, m0, fun i hi => rs0 i hi, x0,
        by rw [p0]; simp, fun y hra m => ?_⟩
      rw [exec_jmpRaxOf, hra, r0, ea_frame, show W.q.bits / 8 = 8 from rfl, readNat_eq, ← hpa]
      rfl
    · cases hh
  | _ => simp [tailHead] at hh

theorem intArg_epi {pe : Bool} {j : Nat} (hj : j < conv pe) :
    (intArg pe j).idx ≠ 4 ∧ (intArg pe j).idx ≠ 5 ∧
      (pe = true → (intArg pe j).idx ≠ 6 ∧ (intArg pe j).idx ≠ 7) := by
  cases pe <;> simp only [conv, Bool.false_eq_true, ↓reduceIte] at hj
  · rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 ∨ j = 4 ∨ j = 5) with
      rfl | rfl | rfl | rfl | rfl | rfl <;> decide
  · rcases (by omega : j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3) with rfl | rfl | rfl | rfl <;> decide

theorem callApart_congr {Owned : BitVec 64 → Prop} {lo : BitVec 64} {F n sp : Nat}
    {st : OpSem.State} {x x' : X86.State} (h : CallApart Owned lo F n sp st x)
    (hb : x'.reg .rbp = x.reg .rbp) : CallApart Owned lo F n sp st x' := by
  intro o h1 h2 h3 h4 h5
  have : fpAddr x' o = fpAddr x o := by simp [fpAddr, hb]
  rw [this]; exact h o h1 h2 h3 h4 h5

/-- `CallApart` from the frame separation over the window `[-F, K)`: an initialized private
byte lies in the window (`FrameSep.init`), above the outgoing area's end `fp - F + n` when
outside the area, so not on the stack below it; in no live allocation (`FrameApart`); and not
runtime-owned (`hown`: the window holds no runtime-owned byte, an environment fact). -/
theorem FrameSep.callApart {Owned : BitVec 64 → Prop} {lo : BitVec 64} {F n fp : Nat} {K : Int}
    {st : OpSem.State} {x : X86.State} (hs : ScopeMem.FrameSep (-(F : Int)) K st x)
    (hw : ScopeMem.Window (-(F : Int)) K fp) (hK : 0 ≤ K) (hb : x.reg .rbp = BitVec.ofNat 64 fp)
    (hF : F ≤ fp) (hown : ∀ o, -(F : Int) ≤ o → o < K → ¬ Owned (fpAddr x o)) :
    CallApart Owned lo F n (fp - F) st x := by
  intro o h1 h2 he hu hout hmw
  obtain ⟨i1, i2⟩ := hs.init o he hu
  have htop := hw.top
  rcases hmw with hst | ⟨id, al, hg, hl, hin⟩ | how
  · simp only [InStack, fpAddr, hb, BitVec.toNat_add, BitVec.toNat_ofInt, BitVec.toNat_ofNat] at hst
    omega
  · exact hs.frameApart id al o hg hl he hu h1 h2 hin
  · exact hown o i1 i2 how

/-! ### Calls -/

/-- A call reaches its callee's entry related to R's query (see the module comment). -/
theorem call_query (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat}
    {k : BitVec 64} {ws : List (BitVec 32)} {items : List Item} {q : R.Query} {lo : BitVec 64}
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call)
    (hs : callSeq c.mode.pe f fo ws = some items)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsp : x.rsp = x.reg .rbp - BitVec.ofNat 64 c.d.frameSize)
    (hb : c.d.frameSize + c.stackSize s.pc < 2 ^ 62)
    (hlo : lo.toNat + 8 ≤ x.rsp.toNat) (hsym : SymsApart ctx lo x.rsp x.mem)
    (h : R.step c s ch = .ok (.ext q s'))
    (hap : Handler.StackApart lo s'.st x) :
    ∃ cal regs stack x1,
      q = ⟨.call cal regs (s.fp - c.d.frameSize) stack, s'.world⟩ ∧
      execItems ctx items x = .ok x1 ∧
      EntryAt ctx c.mode.pe cal regs (s.fp - c.d.frameSize) stack s'.world x1 ∧
      stack.length = c.stackSize s.pc ∧ c.d.frameSize ≤ s.fp ∧
      RRel s' x1 ∧ MemRel s'.st x1 ∧ s'.pc = s.pc ∧ s'.fp = s.fp ∧ s'.args = s.args ∧
      x1.rsp = x.rsp - 8 ∧
      x1.mem.read64 x1.rsp = x.rip + BitVec.ofNat 64 (items.map Item.size).sum ∧
      (∀ i, Saved c.mode.pe i → x1.regs i = x.regs i) ∧
      (∀ b, ¬ InStack lo x.rsp b → x1.mem b = x.mem b) := by
  obtain ⟨s1, parts, cal, regs, stack, hsc, -, hc, ha, hF, hrd, hsret, hpc', hfp', hargs', hq⟩ :=
    CallLemmas.step_call hi hf hsh h
  have hk := scopes_keeps _ hsc
  obtain ⟨hr1, hm1⟩ := ScopeMem.memRel_foldlM _ hsz hr hm hsc
  rw [hk.pc] at hrd
  have hS : Rel s'.st x ∧ EscWF s'.st ∧ MemRel s'.st x := by
    rcases hsret with heq | ⟨n, dst, hw⟩
    · rw [heq]; exact ⟨hr1.rel, hr1.wf, hm1⟩
    · obtain ⟨hrel, hsame⟩ := rel_writeUninit hr1.rel hw
      exact ⟨hrel, escWF_of_sameButWrites hr1.wf hsame, ScopeMem.memRel_writeUninit hm1 hw⟩
  obtain ⟨hrel', hwf', hm'⟩ := hS
  -- the items
  simp only [callSeq, Option.bind_eq_bind, Option.pure_def] at hs
  cases hh : callHead f fo with
  | none => simp [hh] at hs
  | some pc =>
  obtain ⟨pre, ci⟩ := pc
  cases hps : paramItems c.mode.pe ws with
  | none => simp [hh, hps] at hs
  | some ps =>
  simp only [hh, hps, Option.bind_some, Option.some.injEq] at hs
  subst hs
  obtain ⟨y0, e0, m0, rs0, x0, p0, hci⟩ := head_exec ctx hh hc hr1.rel
  have hy0b : y0.reg .rbp = x.reg .rbp := rs0 5 (by decide)
  obtain ⟨y, e1, m1, p1, rs1, hlist, -⟩ := exec_params ctx c.mode.pe hr1.rel ws regs ps y0 ha hps
    m0 hy0b
  have hkeep : ∀ i : Fin 16, (i = 0 ∨ i = 4 ∨ i = 5 ∨ Saved c.mode.pe i) → y.regs i = y0.regs i := by
    intro i hi
    exact rs1 i (fun j hj => intArg_keep hj i hi) (by
      rcases hi with rfl | rfl | rfl | hs
      · decide
      · decide
      · decide
      · intro h11; subst h11; have := saved_ne hs; exact this.2.2.1 rfl)
  have hyrax : y.reg .rax = y0.reg .rax := hkeep 0 (by simp)
  have hymem : y.mem = x.mem := m1.trans m0
  obtain ⟨tgt, eci, htgt⟩ := hci y hymem hyrax
  have hyrsp : y.rsp = x.rsp := by
    show y.regs 4 = x.regs 4; rw [hkeep 4 (by simp), rs0 4 (by decide)]
  have hyrbp : y.reg .rbp = x.reg .rbp := by
    show y.regs 5 = x.regs 5; rw [hkeep 5 (by simp), rs0 5 (by decide)]
  generalize hnext : y.rip + BitVec.ofNat 64 ci.size = next at eci
  generalize hx1 : ((y.jump next).push next).jump tgt = x1 at eci
  have hx1mem : x1.mem = y.mem.write (x.rsp - 8) 8 next.toNat := by
    rw [← hx1, ← hyrsp]; rfl
  have hx1rsp : x1.rsp = x.rsp - 8 := by
    rw [← hx1, ← hyrsp]; simp [State.jump, State.push, State.setMem, State.setReg, State.rsp, State.reg]
  have hx1regs : ∀ i : Fin 16, i ≠ 4 → x1.regs i = y.regs i := by
    intro i hi; rw [← hx1]; simp [State.jump, State.push, State.setMem, State.setReg, hi]
  have hx1xmm : x1.xmm = y.xmm := by rw [← hx1]; rfl
  have hx1rip : x1.rip = tgt := by rw [← hx1]; rfl
  have hmem : ∀ b, ¬ InStack lo x.rsp b → x1.mem b = x.mem b := by
    intro b hb'
    rw [hx1mem, X86.Mem.write_other _ _ _ _ _ (push_other lo x.rsp b hlo hb'), hymem]
  have hx1rbp : x1.reg .rbp = x.reg .rbp := by
    show x1.regs 5 = x.regs 5; rw [hx1regs 5 (by decide)]; exact hyrbp
  obtain ⟨hrelx1, hmx1⟩ := rel_push hrel' hm' hap hmem hx1rbp
  have hsp' : x.rsp = BitVec.ofNat 64 (s.fp - c.d.frameSize) := by
    rw [hsp, rbp_sub_eq, fpAddr_neg hr.rbp (by rw [← hk.fp]; exact hF)]
  have hstl : stack.length = c.stackSize s.pc := by
    have := (mapM_ok hrd).1; simpa using this
  have hbF := hb
  refine ⟨cal, regs, stack, x1, by rw [hq, hk.fp], ?_, ⟨?_, ?_, ?_, ?_, hmx1⟩, hstl,
    by rw [← hk.fp]; exact hF, ⟨hrelx1, by rw [hx1rbp, hfp', hk.fp]; exact hr.rbp, hwf'⟩, hmx1,
    by rw [hpc', hk.pc], by rw [hfp', hk.fp], by rw [hargs', hk.args], hx1rsp, ?_, ?_, hmem⟩
  · rw [ArgRet.execItems_append, ArgRet.execItems_append, e0]
    show (execItems ctx ps y0 >>= fun s1 => execItems ctx [ci] s1) = _
    rw [e1]
    show execItems ctx [ci] y = _
    rw [ArgRet.execItems_cons_ok eci]; rfl
  · rw [hx1rip]; exact htgt lo x.rsp x1.mem hmem hsym
  · refine ArgRet.ArgsRel.congr (argsRel_of hlist) (fun i hi => ?_) (fun i _ => by rw [hx1xmm])
    exact hx1regs _ (fun h => intArg_keep hi 4 (by simp) h.symm)
  · rw [hx1rsp, ← hsp']; exact BitVec.sub_add_cancel _ _
  · have hbr := readFrame_rel hr1.rel hrd (by omega) (by omega)
    rw [hstl]
    have hfpx : fpAddr x (-(c.d.frameSize : Int)) = BitVec.ofNat 64 (s.fp - c.d.frameSize) := by
      rw [← rbp_sub_eq, ← hsp, hsp']
    rw [hfpx] at hbr
    rw [bytesAt_congr (m := x.mem)]
    · exact hbr
    · intro i hi
      rw [hx1mem, ← hsp', X86.Mem.write_other _ _ _ _ _ (above_push _ _ (by omega)), hymem]
  · rw [hx1rsp, hx1mem, ← hnext, read64_write_self]
    rw [p1, p0]
    simp [BitVec.add_assoc, BitVec.ofNat_add]
  · intro i hi
    have := saved_ne hi
    rw [hx1regs i this.2.2.2, hkeep i (by simp [hi]), rs0 i this.1]

/-- A callee's return, from its entry `x1` related to the waiting state `s`'s query (as
`call_query` gives it), continues per `R.answer` through the result stores (see the module
comment). -/
theorem call_return (ctx : Ctx) {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)} {cal : R.Callee} {regs : R.Regs} {stack : List AbstractByte}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)}
    {Safe : R.Query → Prop} {Ret Unw : X86.State → X86.State → Prop}
    (hC : CallContract ctx c.mode.pe Owned lo padOf Safe Ret Unw)
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call)
    (he : EntryAt ctx c.mode.pe cal regs (s.fp - c.d.frameSize) stack s.world x1)
    (hlen : stack.length = c.stackSize s.pc) (hfp : c.d.frameSize ≤ s.fp)
    (hr : RRel s x1) (hm : MemRel s.st x1)
    (hb : c.d.frameSize + c.stackSize s.pc < 2 ^ 62) (hd : d.toInt + 16 ≤ 2 ^ 31)
    (hshadow : c.mode.pe = true → 32 ≤ c.stackSize s.pc)
    (hsafe : Safe ⟨.call cal regs (s.fp - c.d.frameSize) stack, s.world⟩)
    (hap : CallApart Owned lo c.d.frameSize (c.stackSize s.pc) (s.fp - c.d.frameSize) s.st x1)
    (hk : ∃ parts, R.retRegs k.toNat false = .ok parts)
    (hres : ∀ a, CallReturn c.mode.pe Owned lo (s.fp - c.d.frameSize) (c.stackSize s.pc)
      s.world x1 x' a → ResultApart k.toNat d (s.withWorld a.world).st x')
    (hR : Ret x1 x') :
    ∃ a s'' x'', CallReturn c.mode.pe Owned lo (s.fp - c.d.frameSize) (c.stackSize s.pc)
        s.world x1 x' a ∧
      R.answer c s a = .ok (.step s'') ∧
      execItems ctx (resultStores k.toNat d) x' = .ok x'' ∧
      RRel s'' x'' ∧ MemRel s''.st x'' ∧ s''.pc = s.pc + 1 ∧ s''.fp = s.fp ∧
      s''.args = s.args ∧
      x''.rip = x1.mem.read64 x1.rsp +
        BitVec.ofNat 64 ((resultStores k.toNat d).map Item.size).sum ∧
      x''.rsp = x1.rsp + 8 ∧ (∀ i, Saved c.mode.pe i → x''.regs i = x1.regs i) := by
  obtain ⟨a, hcr⟩ := hC.ret cal regs (s.fp - c.d.frameSize) stack s.world x1 x' he hsafe
    (by rw [hlen]; exact hshadow) hR
  rw [hlen] at hcr
  have hrbp : x'.reg .rbp = x1.reg .rbp :=
    hcr.saved 5 (saved_of_calleeSaved (by simp [CalleeSaved]))
  obtain ⟨st1, hw, hrel, hwf, hmr, he1, -, -, heo⟩ := answer_rel hr hcr.toCallEnd hap hrbp hfp hb
  obtain ⟨regsR, hresR, hRet⟩ := hcr.regs
  obtain ⟨parts, hp⟩ := hk
  obtain ⟨hstores, hpq, hnd⟩ := retRegsS_parts hp d
  have hra : ∀ q ∈ parts, CallLemmas.RangeApart st1 x' (d.toInt + q.1.off) q.1.size :=
    fun q hq => (hres a hcr parts hp q hq).of_escOnly (by rw [he1]; rfl) heo
  obtain ⟨st2, x'', hfold, hx, hrel2, hmr2, g1, g2, -, -, -, rs2, p2⟩ :=
    exec_stores ctx d regsR hd parts st1 x' hpq hnd hrel hmr hra (fun q hq => by
      apply hRet
      obtain ⟨_, hfor, _⟩ := hpq q hq
      rcases hfor with ⟨_, h | h⟩ | ⟨_, h | h⟩ <;> rw [h] <;> simp [ArgRet.retRegList])
  have hrbp2 : x''.reg .rbp = x'.reg .rbp := rs2 5 (by decide) (by decide) (by decide)
  refine ⟨a, ⟨s.pc + 1, s.fp, st2, s.args⟩, x'', hcr, answer_ret hi hf hsh hresR hw hp hfold,
    by rw [hstores]; exact hx, ⟨hrel2, by rw [hrbp2, hrbp]; exact hr.rbp, ?_⟩, hmr2, rfl, rfl, rfl,
    by rw [p2, hcr.rip, hstores], ?_, fun i hi' => ?_⟩
  · exact ⟨fun e he' => by rw [g1] at he'; rw [g2]; exact hwf.idLt e he',
      fun e he' e' he'' hid => by rw [g1] at he' he''; exact hwf.idInj e he' e' he'' hid⟩
  · show x''.regs 4 = _
    rw [rs2 4 (by decide) (by decide) (by decide)]; exact hcr.rsp
  · obtain ⟨h0, h2, h11, -⟩ := saved_ne hi'
    rw [rs2 i h0 h2 h11]; exact hcr.saved i hi'

/-- The full R step of a call that returns: `call_query` then `call_return`. -/
theorem call_sound (ctx : Ctx) {c : R.Code} {s s' : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat}
    {k : BitVec 64} {ws : List (BitVec 32)} {items : List Item} {q : R.Query}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)}
    {Safe : R.Query → Prop} {Ret Unw : X86.State → X86.State → Prop}
    (hC : CallContract ctx c.mode.pe Owned lo padOf Safe Ret Unw)
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call)
    (hs : callSeq c.mode.pe f fo ws = some items)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsp : x.rsp = x.reg .rbp - BitVec.ofNat 64 c.d.frameSize)
    (hb : c.d.frameSize + c.stackSize s.pc < 2 ^ 62) (hd : d.toInt + 16 ≤ 2 ^ 31)
    (hshadow : c.mode.pe = true → 32 ≤ c.stackSize s.pc)
    (hlo : lo.toNat + 8 ≤ x.rsp.toNat) (hsym : SymsApart ctx lo x.rsp x.mem)
    (h : R.step c s ch = .ok (.ext q s')) (hsafe : Safe q)
    (hap : Handler.StackApart lo s'.st x)
    (hca : CallApart Owned lo c.d.frameSize (c.stackSize s.pc) (s.fp - c.d.frameSize) s'.st x)
    (hres : ∀ x1 x' a, CallReturn c.mode.pe Owned lo (s.fp - c.d.frameSize) (c.stackSize s.pc)
      s'.world x1 x' a → ResultApart k.toNat d (s'.withWorld a.world).st x') :
    ∃ cal regs stack x1,
      q = ⟨.call cal regs (s.fp - c.d.frameSize) stack, s'.world⟩ ∧
      execItems ctx items x = .ok x1 ∧
      EntryAt ctx c.mode.pe cal regs (s.fp - c.d.frameSize) stack s'.world x1 ∧
      ∀ x', Ret x1 x' → ∃ a s'' x'',
        CallReturn c.mode.pe Owned lo (s.fp - c.d.frameSize) (c.stackSize s.pc) s'.world x1 x' a ∧
        R.answer c s' a = .ok (.step s'') ∧
        execItems ctx (resultStores k.toNat d) x' = .ok x'' ∧
        RRel s'' x'' ∧ MemRel s''.st x'' ∧ s''.pc = s.pc + 1 ∧
        x''.rip = x.rip + BitVec.ofNat 64 ((items ++ resultStores k.toNat d).map Item.size).sum ∧
        x''.rsp = x.rsp ∧ (∀ i, Saved c.mode.pe i → x''.regs i = x.regs i) := by
  obtain ⟨cal, regs, stack, x1, hq, hx, he, hstl, hF, hr', hm', hpc, hfp, -, hrsp, hret, hsaved,
    -⟩ := call_query ctx hi hf hsh hs hr hm hsz hsp hb hlo hsym h hap
  obtain ⟨-, parts, -, -, -, -, hp, -⟩ := CallLemmas.step_call hi hf hsh h
  refine ⟨cal, regs, stack, x1, hq, hx, he, fun x' hR => ?_⟩
  have hx1b : x1.reg .rbp = x.reg .rbp := by
    have := hsaved 5 (saved_of_calleeSaved (by simp [CalleeSaved])); exact this
  rw [← hfp] at he hca hres ⊢
  rw [← hpc] at hi hb hshadow hstl hca hres ⊢
  obtain ⟨a, s'', x'', hcr, hans, hx'', hr'', hm'', hpc'', -, -, hrip, hrsp'', hsv⟩ :=
    call_return ctx hC hi hf hsh he hstl (by rw [hfp]; exact hF) hr' hm' hb hd hshadow
      (by rw [hfp, ← hq]; exact hsafe) (callApart_congr hca hx1b) ⟨parts, hp⟩ (hres x1 x') hR
  refine ⟨a, s'', x'', hcr, hans, hx'', hr'', hm'', by rw [hpc'', hpc], ?_, ?_, ?_⟩
  · rw [hrip, hret, List.map_append, List.sum_append, BitVec.ofNat_add, BitVec.add_assoc]
  · rw [hrsp'', hrsp]; exact BitVec.sub_add_cancel _ _
  · intro i hi'; rw [hsv i hi', hsaved i hi']

/-- Unwinding out of a callee into the call's landing pad `pad` (`pos pad` its position):
R's `answer` with the contract's `.unwind exc` lands at `pad` with the exception object, related
to the x86 state the unwinder lands in. -/
theorem call_unwind (ctx : Ctx) {c : R.Code} {s : R.RState} {x1 x' : X86.State}
    {op : Reduced.Opcode} {f : Full.Opcode} {d : BitVec 32} {fo : R.Opnd Nat} {k : BitVec 64}
    {ws : List (BitVec 32)} {cal : R.Callee} {regs : R.Regs} {stack : List AbstractByte}
    {Owned : BitVec 64 → Prop} {lo : BitVec 64} {padOf : BitVec 64 → Option (BitVec 64)}
    {Safe : R.Query → Prop} {Ret Unw : X86.State → X86.State → Prop} {pad : Nat}
    {cat : Bool}
    (pos : Nat → BitVec 32)
    (hC : CallContract ctx c.mode.pe Owned lo padOf Safe Ret Unw)
    (hi : c.d.insns[s.pc]? = some (.native op [.slot d, fo, .imm k, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .call)
    (he : EntryAt ctx c.mode.pe cal regs (s.fp - c.d.frameSize) stack s.world x1)
    (hlen : stack.length = c.stackSize s.pc) (hfp : c.d.frameSize ≤ s.fp)
    (hr : RRel s x1) (hm : MemRel s.st x1)
    (hb : c.d.frameSize + c.stackSize s.pc < 2 ^ 62)
    (hshadow : c.mode.pe = true → 32 ≤ c.stackSize s.pc)
    (hsafe : Safe ⟨.call cal regs (s.fp - c.d.frameSize) stack, s.world⟩)
    (hap : CallApart Owned lo c.d.frameSize (c.stackSize s.pc) (s.fp - c.d.frameSize) s.st x1)
    (hpad : c.cleanupAt s.pc = some (some pad, cat))
    (hpos : padOf (x1.mem.read64 x1.rsp) = some (ctx.base + (pos pad).setWidth 64))
    (hU : Unw x1 x') :
    ∃ a exc s'', a.result = .unwind exc ∧
      CallEnd Owned lo (s.fp - c.d.frameSize) (c.stackSize s.pc) s.world x1 x' a ∧
      R.answer c s a = .ok (.step s'') ∧ s''.pc = pad ∧ s''.st.exception = exc ∧
      RRel s'' x' ∧ MemRel s''.st x' ∧ s''.fp = s.fp ∧ s''.args = s.args ∧
      x'.rip = ctx.base + (pos pad).setWidth 64 ∧ x'.reg .rax = BitVec.ofNat 64 exc.addr ∧
      x'.rsp = x1.rsp + 8 ∧ (∀ i, Saved c.mode.pe i → x'.regs i = x1.regs i) := by
  obtain ⟨a, exc, hres, hce, hland⟩ := hC.unwind cal regs (s.fp - c.d.frameSize) stack s.world
    x1 x' he hsafe (by rw [hlen]; exact hshadow) hU
  rw [hlen] at hce
  have hrbp : x'.reg .rbp = x1.reg .rbp :=
    hland.saved 5 (saved_of_calleeSaved (by simp [CalleeSaved]))
  obtain ⟨st1, hw, hrel, hwf, hmr, -, -, -, -⟩ := answer_rel hr hce hap hrbp hfp hb
  refine ⟨a, exc, _, hres, hce, answer_unwind hi hf hsh hres hw hpad, rfl, rfl,
    ⟨rel_exc exc hrel, by rw [hrbp]; exact hr.rbp, ⟨hwf.idLt, hwf.idInj⟩⟩, hmr, rfl, rfl,
    Option.some.inj (hland.rip.symm.trans hpos), hland.rax, hland.rsp, hland.saved⟩

/-! ### Tail calls -/

/-- A tail call: the loads, the epilogue and the jump reach the callee's entry related to R's
`Exit.tailCall` (see the module comment). Without a frame pointer and on PE (whose epilogue is
`add rsp, F; pop rbp`) `hsp` gives `rsp = fp - F` and `F + 8 < 2^31`. -/
theorem tail_call_step (ctx : Ctx) {c : R.Code} {s : R.RState} {x : X86.State}
    {ch : OpSem.Choice} {op : Reduced.Opcode} {w : Bool} {f : Full.Opcode} {fo : R.Opnd Nat}
    {ws : List (BitVec 32)} {items : List Item} {fin : R.Final}
    (hi : c.d.insns[s.pc]? = some (.native op [fo, .words ws]))
    (hf : op.full = some f) (hsh : f.info.shape = .tailCall)
    (hs : tailSeq c.d.frameSize c.mode w f fo ws = some items)
    (hr : RRel s x) (hm : MemRel s.st x) (hsz : ∀ sc ∈ c.scopesAt s.pc, sc.size < 2 ^ 62)
    (hsp : c.mode.pe = true ∨ c.mode.framePointer = false →
      x.rsp = x.reg .rbp - BitVec.ofNat 64 c.d.frameSize ∧ c.d.frameSize + 8 < 2 ^ 31)
    (hn : 16 + c.stackSize s.pc ≤ 2 ^ 63)
    (h : R.step c s ch = .ok (.done fin)) :
    ∃ s1 cal regs stack x', fin = R.exit s1 (.tailCall cal regs (s.fp + 16) stack) ∧
      RRel s1 x ∧ MemRel s1.st x ∧ s1.fp = s.fp ∧ stack.length = c.stackSize s.pc ∧
      execItems ctx items x = .ok x' ∧
      EntryAt ctx c.mode.pe cal regs (s.fp + 16) stack fin.world x' ∧
      x'.mem = x.mem ∧ x'.rsp = x.reg .rbp + 8 ∧
      (c.mode.pe = true ∨ c.mode.framePointer = true → x'.reg .rbp = x.mem.read64 (x.reg .rbp)) ∧
      (c.mode.pe = false → c.mode.framePointer = false → x'.reg .rbp = x.reg .rbp) ∧
      (∀ i, Saved c.mode.pe i → i ≠ 5 → x'.regs i = x.regs i) := by
  obtain ⟨s1, cal, regs, stack, hsc, hc, ha, hrd, hfin⟩ := CallLemmas.step_tailCall hi hf hsh h
  have hk := scopes_keeps _ hsc
  obtain ⟨hr1, hm1⟩ := ScopeMem.memRel_foldlM _ hsz hr hm hsc
  rw [hk.pc] at hrd
  simp only [tailSeq, Option.bind_eq_bind, Option.pure_def] at hs
  cases hh : tailHead w f fo with
  | none => simp [hh] at hs
  | some pc =>
  obtain ⟨pre, j⟩ := pc
  cases hps : paramItems c.mode.pe ws with
  | none => simp [hh, hps] at hs
  | some ps =>
  simp only [hh, hps, Option.bind_some, Option.some.injEq] at hs
  subst hs
  obtain ⟨y0, e0, m0, rs0, x0, p0, hj⟩ := tailHead_exec ctx hh hc hr1.rel
  have hy0b : y0.reg .rbp = x.reg .rbp := rs0 5 (by decide)
  obtain ⟨y, e1, m1, p1, rs1, hlist, -⟩ := exec_params ctx c.mode.pe hr1.rel ws regs ps y0 ha hps
    m0 hy0b
  have hkeep : ∀ i : Fin 16, (i = 0 ∨ i = 4 ∨ i = 5 ∨ Saved c.mode.pe i) → y.regs i = y0.regs i := by
    intro i hi
    exact rs1 i (fun j hj => intArg_keep hj i hi) (by
      rcases hi with rfl | rfl | rfl | hs
      · decide
      · decide
      · decide
      · intro h11; subst h11; have := saved_ne hs; exact this.2.2.1 rfl)
  have hymem : y.mem = x.mem := m1.trans m0
  have hyrsp : y.rsp = x.rsp := by
    show y.regs 4 = x.regs 4; rw [hkeep 4 (by simp), rs0 4 (by decide)]
  have hyrbp : y.reg .rbp = x.reg .rbp := by
    show y.regs 5 = x.regs 5; rw [hkeep 5 (by simp), rs0 5 (by decide)]
  obtain ⟨y', ex, mx, xx, rspx, regsx, rbpx, rbpx2⟩ :=
    exec_epilogue_only ctx c.d.frameSize c.mode y (fun h1 => by
      rw [hyrsp, hyrbp]; exact hsp h1)
  have hyrax' : y'.reg .rax = y0.reg .rax := by
    show y'.regs 0 = y0.regs 0
    rw [regsx 0 (by decide) (by decide), hkeep 0 (by simp)]
  generalize hx' : y'.jump (calleeTarget ctx y'.mem cal) = x'
  have ej := hj y' hyrax' y'.mem
  rw [hx'] at ej
  have hx'mem : x'.mem = x.mem := by rw [← hx']; exact mx.trans hymem
  have hx'regs : x'.regs = y'.regs := by rw [← hx']; rfl
  have hx'xmm : x'.xmm = y'.xmm := by rw [← hx']; rfl
  have hstl : stack.length = c.stackSize s.pc := by
    have := (mapM_ok hrd).1; simpa using this
  have hfp16 : fpAddr x 16 = BitVec.ofNat 64 (s.fp + 16) := by
    simp only [fpAddr, hr.rbp]
    rw [BitVec.ofNat_add]; rfl
  refine ⟨s1, cal, regs, stack, x', hfin.trans (by rw [hk.fp]), hr1, hm1, hk.fp, hstl, ?_,
    ⟨?_, ?_, ?_, ?_, ?_⟩, hx'mem, ?_, ?_, ?_, ?_⟩
  · rw [ArgRet.execItems_append, ArgRet.execItems_append, e0]
    show (execItems ctx ps y0 >>= fun s1 => execItems ctx (epilogue c.d.frameSize c.mode ++ [j]) s1) = _
    rw [e1]
    show execItems ctx (epilogue c.d.frameSize c.mode ++ [j]) y = _
    rw [ArgRet.execItems_append, ex]
    show execItems ctx [j] y' = _
    rw [ArgRet.execItems_cons_ok ej]; rfl
  · rw [← hx']; rfl
  · refine ArgRet.ArgsRel.congr (argsRel_of hlist) (fun i hi => ?_) (fun i _ => by rw [hx'xmm, xx])
    rw [hx'regs]
    obtain ⟨h4, h5, -⟩ := intArg_epi hi
    exact regsx _ h4 h5
  · show x'.regs 4 + 8 = _
    rw [hx'regs]
    show y'.rsp + 8 = _
    rw [rspx, hyrbp, hr.rbp, BitVec.add_assoc, BitVec.ofNat_add]; rfl
  · rw [hx'mem]
    have hbr := readFrame_rel hr1.rel hrd (by omega) (by omega)
    rw [hfp16] at hbr
    rw [hstl]; exact hbr
  · rw [hfin]
    refine worldRel_exit _ ?_
    intro id al hg hl i hi
    rw [hx'mem]; exact hm1 id al hg hl i hi
  · show x'.regs 4 = _
    rw [hx'regs]; show y'.rsp = _; rw [rspx, hyrbp]
  · intro hm'
    show x'.regs 5 = _
    rw [hx'regs]; show y'.reg .rbp = _; rw [rbpx hm', hyrbp, hymem]
  · intro h1 h2
    show x'.regs 5 = _
    rw [hx'regs]; show y'.reg .rbp = _; rw [rbpx2 h1 h2, hyrbp]
  · intro i hs h5
    have := saved_ne hs
    rw [hx'regs]
    have h4 : i ≠ 4 := this.2.2.2
    rw [regsx i h4 h5, hkeep i (by simp [hs]), rs0 i this.1]

end Ryo.Proofs.Call
