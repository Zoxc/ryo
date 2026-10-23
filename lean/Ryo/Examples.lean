/-
Ryo.Examples — small MIR programs built with the DSL, for `ryo-lean example` and the JSON
round-trip test.
-/
import Ryo.Spec.Mir.Builder

namespace Ryo.Examples

open Ryo.Spec Ryo.Spec.Build

/-- `fn fact(n: u64) -> u64 { if n == 0 { 1 } else { n * fact(n - 1) } }`, `main` returns
`fact(10)`. -/
def factorial : Program := program do
  let fact ← declareFn "fact"
  defineFn fact <| body u64 [u64] do
    let isZero ← tmp .bool (.binaryOp .eq (copyL 1) (cint u64 0))
    let base ← newBlock
    let rec_ ← newBlock
    term (.switchInt isZero [(1, base)] rec_)
    setBlock base
    assignL 0 (.use (cint u64 1))
    ret
    setBlock rec_
    let m ← tmp u64 (.binaryOp .sub (copyL 1) (cint u64 1))
    let r ← newLocal u64
    storageLive r
    call (.inst fact) [m] (place r)
    assignL 0 (.binaryOp .mul (copyL 1) (copyL r))
    ret
  addFn "main" <| body u64 [] do
    call (.inst fact) [cint u64 10] (place 0)
    ret

/-- Heap allocation through the allocator shims, a store, a load. -/
def heap : Program := program do
  let alloc ← addExtern "__rust_alloc"
  let dealloc ← addExtern "__rust_dealloc"
  addFn "main" <| body u32 [] do
    let p ← newLocal (rawTo u32 true)
    storageLive p
    call (.inst alloc) [cusize 4, cusize 4] (place p)
    assign ((place p).deref u32) (.use (cint u32 0xdeadbeef))
    assignL 0 (.use (copy ((place p).deref u32)))
    let u ← newLocal unit
    storageLive u
    call (.inst dealloc) [copyL p, cusize 4, cusize 4] (place u)
    ret

def all : List (String × Program) := [("factorial", factorial), ("heap", heap)]

def names : List String := all.map (·.1)

def byName (n : String) : Option Program := (all.find? (·.1 == n)).map (·.2)

end Ryo.Examples
