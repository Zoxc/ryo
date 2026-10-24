/-
Ryo.Spec.Mir.Builder — a small DSL to write MIR programs in Lean (tests, examples).

Ports: MiniRust `tooling/miniutil/src/build` (`ProgramBuilder`, `FunctionBuilder`, the
expression/place/type constructors), adapted to MIR: there are no nested expressions, so
helpers that need an intermediate value (`assumeEq`, `tmp`) allocate a fresh temporary local.
-/
import Ryo.Spec.Mir.Syntax
import Ryo.Spec.Lang.Representation

namespace Ryo.Spec.Build

/-! ## Types -/

def i8 : Ty := intTy .i8
def i16 : Ty := intTy .i16
def i32 : Ty := intTy .i32
def i64 : Ty := intTy .i64
def i128 : Ty := intTy .i128
def u8 : Ty := intTy .u8
def u16 : Ty := intTy .u16
def u32 : Ty := intTy .u32
def u64 : Ty := intTy .u64
def u128 : Ty := intTy .u128
def usize : Ty := intTy .usize
def isize : Ty := intTy .isize
def bool : Ty := .bool
def unit : Ty := unitTy
def f32 : Ty := .float .f32
def f64 : Ty := .float .f64

/-- A struct/tuple with explicit offsets, size and alignment. -/
def tuple (fields : List (Offset × Ty)) (size : Size) (align : Nat) : Ty :=
  .tuple fields ⟨size, Align.ofBytes align, none⟩ none

/-- A tuple with C-like layout (fields in order, each aligned). -/
def cTuple (tys : List Ty) : Ty := Id.run do
  let mut off := 0
  let mut al := Align.one
  let mut fields := []
  for t in tys do
    off := alignTo off t.align
    fields := fields ++ [(off, t)]
    off := off + t.size
    al := al.max t.align
  pure (.tuple fields ⟨alignTo off al, al, none⟩ none)

def array (elem : Ty) (n : Nat) : Ty := .array elem n
def slice (elem : Ty) : Ty := .slice elem
def str : Ty := .slice u8

def refTo (t : Ty) (mutbl := false) : Ty := refTy t mutbl
def rawTo (t : Ty) (mutbl := false) : Ty := rawPtrTy t mutbl
def boxTo (t : Ty) : Ty := .ptr (.box t.pointeeInfo) ValidRange.nonNull

/-! ## Operands and places -/

def place (l : Local) : MPlace := ⟨l, []⟩

def _root_.Ryo.Spec.MPlace.field (p : MPlace) (f : Nat) (ty : Ty) : MPlace := { p with proj := p.proj ++ [.field f ty] }
def _root_.Ryo.Spec.MPlace.deref (p : MPlace) (pointee : Ty) : MPlace := { p with proj := p.proj ++ [.deref pointee] }
def _root_.Ryo.Spec.MPlace.index (p : MPlace) (l : Local) : MPlace := { p with proj := p.proj ++ [.index l] }
def _root_.Ryo.Spec.MPlace.downcast (p : MPlace) (v : Nat) : MPlace := { p with proj := p.proj ++ [.downcast v] }
def _root_.Ryo.Spec.MPlace.proj1 (p : MPlace) (e : ProjElem) : MPlace := { p with proj := p.proj ++ [e] }

def copy (p : MPlace) : Operand := .copy p
def move (p : MPlace) : Operand := .move p
def copyL (l : Local) : Operand := .copy (place l)

def cint (t : Ty) (i : Int) : Operand :=
  match t with
  | .int it _ => .const (.scalar (it.toBits i)) t
  | _ => .const (.scalar i.toNat) t

def ci32 (i : Int) : Operand := cint i32 i
def cusize (i : Int) : Operand := cint usize i
def cu8 (i : Int) : Operand := cint u8 i
def cbool (b : Bool) : Operand := .const (.scalar (if b then 1 else 0)) .bool
def cunit : Operand := .const .zeroSized unit
/-- A pointer constant without provenance. -/
def cptr (ty : Ty) (addr : Nat) : Operand := .const (.scalar addr) ty
def cf64 (x : Float) : Operand := .const (.scalar x.toBits.toNat) f64
def cf32 (x : Float32) : Operand := .const (.scalar x.toBits.toNat) f32
def cfnDef (i : InstanceId) : Operand := .const .zeroSized (.fnDef i)
def cfnPtr (i : InstanceId) : Operand := .const (.ptr (.fn i) 0) fnPtrTy

/-! ## Function builder -/

structure FnState where
  locals : Array Ty
  argCount : Nat
  blocks : Array (Option BlockData) := #[]
  cur : Option BasicBlock := none
  curStmts : Array Statement := #[]
  spreadArg : Option Local := none
  trackCaller : Bool := false
  abi : Option FnAbiSummary := none

abbrev FnB := StateM FnState

def newLocal (ty : Ty) : FnB Local := do
  let s ← get
  set { s with locals := s.locals.push ty }
  pure s.locals.size

/-- Reserve a new block; `cleanup` marks a cleanup block. -/
def newBlock (cleanup := false) : FnB BasicBlock := do
  let s ← get
  set { s with blocks := s.blocks.push (some { term := .unreachable, isCleanup := cleanup }) }
  pure s.blocks.size

/-- Make `bb` the block statements are appended to. -/
def setBlock (bb : BasicBlock) : FnB Unit := modify fun s => { s with cur := some bb, curStmts := #[] }

def stmt (st : Statement) : FnB Unit := modify fun s => { s with curStmts := s.curStmts.push st }

/-- End the current block with a terminator. -/
def term (t : Terminator) : FnB Unit := modify fun s =>
  match s.cur with
  | some bb =>
    let cleanup := match s.blocks[bb]? with
      | some (some bd) => bd.isCleanup
      | _ => false
    { s with blocks := s.blocks.set! bb (some { stmts := s.curStmts.toList, term := t, isCleanup := cleanup }),
             cur := none, curStmts := #[] }
  | none => s

def assign (p : MPlace) (rv : Rvalue) : FnB Unit := stmt (.assign p rv)
def assignL (l : Local) (rv : Rvalue) : FnB Unit := assign (place l) rv
def storageLive (l : Local) : FnB Unit := stmt (.storageLive l)
def storageDead (l : Local) : FnB Unit := stmt (.storageDead l)
def assume (o : Operand) : FnB Unit := stmt (.assume o)

/-- A fresh live temporary holding `rv`. -/
def tmp (ty : Ty) (rv : Rvalue) : FnB Operand := do
  let l ← newLocal ty
  storageLive l
  assignL l rv
  pure (copyL l)

/-- `assume(a == b)` via a temporary. -/
def assumeEq (a b : Operand) : FnB Unit := do
  assume (← tmp .bool (.binaryOp .eq a b))

def assumeRv (rv : Rvalue) : FnB Unit := do
  assume (← tmp .bool rv)

/-- Is the current block a cleanup block? -/
def curIsCleanup : FnB Bool := do
  let s ← get
  match s.cur with
  | some bb =>
    match s.blocks[bb]? with
    | some (some bd) => pure bd.isCleanup
    | _ => pure false
  | none => pure false

/-- `goto` a fresh block and continue there. -/
def goNext : FnB Unit := do
  let bb ← newBlock (cleanup := ← curIsCleanup)
  term (.goto bb)
  setBlock bb

/-- A call that continues in a fresh block. -/
def call (f : Callee) (args : List Operand) (dest : MPlace) (unwind : UnwindAction := .continue)
    (callerLocation : Option CallerLoc := none) : FnB Unit := do
  let next ← newBlock (cleanup := ← curIsCleanup)
  term (.call f args dest (some next) unwind callerLocation)
  setBlock next

def ret : FnB Unit := term .return

/-- Build a body: `_0 : retTy`, then the arguments. The builder starts in block 0. -/
def body (retTy : Ty) (args : List Ty) (build : FnB Unit) (trackCaller := false)
    (spread := false) : Body :=
  let s0 : FnState := { locals := #[retTy] ++ args.toArray, argCount := args.length, trackCaller,
                        spreadArg := if spread then some args.length else none }
  let go : FnB Unit := do
    let b0 ← newBlock
    setBlock b0
    build
  let ((), s) := go.run s0
  { locals := s.locals, argCount := s.argCount, spreadArg := s.spreadArg,
    trackCaller := s.trackCaller, abi := s.abi,
    blocks := s.blocks.map fun | some b => b | none => { term := .unreachable } }

/-! ## Program builder -/

structure ProgState where
  instances : Array Instance := #[]
  globals : Array Global := #[]
  langItems : LangItems := {}

abbrev ProgB := StateM ProgState

def declareFn (symbol : String) : ProgB InstanceId := do
  let s ← get
  set { s with instances := s.instances.push ⟨symbol, .ext⟩ }
  pure s.instances.size

def defineFn (i : InstanceId) (b : Body) : ProgB Unit := modify fun s =>
  { s with instances := s.instances.modify i fun inst => { inst with kind := .body b } }

def addFn (symbol : String) (b : Body) : ProgB InstanceId := do
  let i ← declareFn symbol
  defineFn i b
  pure i

def addExtern (symbol : String) : ProgB InstanceId := declareFn symbol

def addIntrinsic (name : String) (tyArgs : List (Option TyArg) := []) : ProgB InstanceId := do
  let s ← get
  set { s with instances := s.instances.push ⟨name, .intrinsic name tyArgs⟩ }
  pure s.instances.size

def addGlobal (g : Global) : ProgB GlobalId := do
  let s ← get
  set { s with globals := s.globals.push g }
  pure s.globals.size

/-- A read-only constant allocation holding the given bytes. -/
def constBytes (bytes : List UInt8) (align : Nat := 1) : ProgB GlobalId :=
  addGlobal { bytes := bytes.map some, align := Align.ofBytes align, kind := .const }

def program (build : ProgB InstanceId) : Program :=
  let (start, s) := build.run {}
  { instances := s.instances, globals := s.globals, start, langItems := s.langItems }

/-- A program with a single `fn main()` built from `build`. -/
def mainOnly (build : FnB Unit) (retTy : Ty := unit) : Program :=
  program (addFn "main" (body retTy [] build))

end Ryo.Spec.Build

namespace Ryo.Spec.Build

/-- `assume(op(a, b) == expected)` at result type `ty`. -/
def assumeBin (op : BinOp) (ty : Ty) (a b expected : Operand) : FnB Unit := do
  assumeEq (← tmp ty (.binaryOp op a b)) expected

/-- Evaluate `op(a, b)` into a fresh temporary (e.g. to provoke UB). -/
def evalBin (op : BinOp) (ty : Ty) (a b : Operand) : FnB Unit := do
  let _ ← tmp ty (.binaryOp op a b)

/-- A call to an intrinsic into a fresh temporary of type `ty`. -/
def callTmp (f : InstanceId) (ty : Ty) (args : List Operand) : FnB Operand := do
  let l ← newLocal ty
  storageLive l
  call (.inst f) args (place l)
  pure (copyL l)

end Ryo.Spec.Build

namespace Ryo.Spec.Build

/-- A call whose (unit) result is ignored. -/
def callUnit (f : Callee) (args : List Operand) (unwind : UnwindAction := .continue) : FnB Unit := do
  let l ← newLocal unit
  storageLive l
  call f args (place l) unwind

/-- Print an integer through the `ryo_test_print` shim. -/
def printI (pr : InstanceId) (o : Operand) : FnB Unit := do
  callUnit (.inst pr) [o] (unwind := if ← curIsCleanup then .unreachable else .continue)

/-- A cleanup block built by `build`; returns its index. Restores the current block. -/
def cleanupBlock (build : FnB Unit) : FnB BasicBlock := do
  let s ← get
  let saved := (s.cur, s.curStmts)
  let bb ← newBlock (cleanup := true)
  setBlock bb
  build
  modify fun s => { s with cur := saved.1, curStmts := saved.2 }
  pure bb

/-- A normal block built by `build` (not entered); restores the current block. -/
def sideBlock (build : FnB Unit) : FnB BasicBlock := do
  let s ← get
  let saved := (s.cur, s.curStmts)
  let bb ← newBlock
  setBlock bb
  build
  modify fun s => { s with cur := saved.1, curStmts := saved.2 }
  pure bb

/-- `if c { then } else { else }`, continuing in a join block. -/
def ite (c : Operand) (thn els : FnB Unit) : FnB Unit := do
  let t ← newBlock
  let e ← newBlock
  let j ← newBlock
  term (.switchInt c [(0, e)] t)
  setBlock t; thn
  if (← get).cur.isSome then term (.goto j)
  setBlock e; els
  if (← get).cur.isSome then term (.goto j)
  setBlock j

/-- A raw pointer to a local. -/
def rawOf (l : Local) (mutbl := true) : Rvalue := .rawPtr mutbl (place l)

/-- An enum variant whose fields are given (offsets within the enum). -/
def variant (discr : Int) (fields : List (Offset × Ty)) (size align : Nat) (inhabited := true) :
    Variant := ⟨discr, tuple fields size align, inhabited⟩

end Ryo.Spec.Build
