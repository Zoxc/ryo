/-
# The constant-pool and vtable check (aot.md §C4)

The image's constant pool (`Header::consts`, in the read-only section) holds copies of rustc's
constant and vtable allocations (`Pool::intern` in `backend/src/rustc_api/partition.rs`), their
pointers zeroed and relocated by `R_X86_64_64` relocations: into the pool (against the
read-only section's symbol) or against a symbol (a function instance's or a static's), and raw
byte constants (`fill` operands, `Pool::bytes`). This module checks the pool against the
backend's MIR dump (`RYO_DUMP_LEAN`, `Ryo.Spec.Program`):

- **References.** Every pool offset `k` the code references: the `Ref.const k` fields of each
  function's code, with their use from the decoded instruction (`const d, k, len` copies
  `[k, k + len)`, `addr.abs d, k` takes the address `k`, `fill d, k, n, _` reads an `n`-byte
  element). `fill` operands are byte constants, not allocations (C1' checks them against the
  `Repeat` operand), so they are counted, not matched.
- **Placements.** A placement `(g, b)` says "pool offset `b` holds a copy of dumped global
  `g`" (kind `const` or `vtable`). It holds locally when `[b, b + size)` lies in the pool,
  the section offset of `b` is a multiple of `g`'s alignment (and the section's alignment
  is too), every initialized byte of `g` outside its pointers equals the pool's, and the pool
  relocations overlapping `[b, b + size)` are exactly `g`'s pointers: one `R_X86_64_64` at
  each pointer's offset, against the pool at `b' + addend` for a pointer to the constant or
  vtable `g'` (which demands the placement `(g', b')`), against the symbol of the instance the
  dump names for a function pointer, with the dumped addend, or against a symbol for a
  static's (the dump carries no static symbols: each static must map to one symbol, distinct
  statics to distinct symbols, none an instance's). Type-id pointers carry no provenance in
  the copy: their bytes are compared.
- **Matching.** A placement is valid when every placement it demands, transitively, holds
  locally: the greatest fixpoint of the local check over the demand edges (which handles
  cycles). A reference `k` is matched by a valid placement `(g, b)` covering its use
  (`b = k` first, else `b < k`, for constants at an offset into an allocation), `g` one of
  the globals the referencing functions' dumped bodies mention (any global for functions
  not in the dump). So a reported match really holds, and is against an allocation the
  code's MIR can mean (which one, C1' decides).
- **Unmatched references.** "Not in dump" when no function referencing `k` is a body
  instance of the dump (the dump covers what is reachable from `main`; std code may be
  missing), a mismatch otherwise, with the closest candidates and why each fails.
- **The section.** The pool lies in an allocated, non-executable section that is read-only
  or RELRO (`.data.rel.ro.*`, D7).
- **Vtables.** Matched vtables have the D29 layout `[drop_in_place, size, align, entries…]`
  in the dump: a function pointer or null for `drop_in_place` (rustc's `vtable_allocation`
  puts null for types without drop glue), initialized size and align, and each entry a
  function pointer, a vtable pointer (supertrait) or null (vacant).
-/
import Std.Data.HashMap
import Std.Data.HashSet
import Ryo.Spec
import Ryo.Obj
import Ryo.Vm.DecodeObj

namespace Ryo.Check.Image.Pool

open Ryo.Spec Ryo.Obj Std

/-! ## Inputs -/

/-- A relocation in the pool, by what it points at. -/
inductive PRel where
  /-- `R_X86_64_64` into the pool, at this pool offset (`S + A` less the pool's start). -/
  | pool (t : Int)
  /-- `R_X86_64_64` against a named symbol. -/
  | sym (name : String) (addend : Int)
  /-- Anything else (another type, another section). -/
  | other (what : String)
  deriving Repr, DecidableEq, Inhabited

instance : ToString PRel where
  toString
    | .pool t => s!"pool {t}"
    | .sym n a => s!"`{n}`{if a == 0 then "" else s!" + {a}"}"
    | .other w => w

/-- The pool as the check sees it. -/
structure PoolView where
  bytes : ByteArray
  /-- The relocations, by pool offset. -/
  relocs : HashMap Nat PRel := {}
  /-- The pool's offset in its section, and the section's alignment. -/
  start : Nat := 0
  secAlign : Nat := 16

/-- How code uses a referenced pool offset. -/
inductive Use where
  /-- `const`: copies `len` bytes. -/
  | copy (len : Nat)
  /-- `addr.abs`: takes the address. -/
  | addr
  /-- `fill`: an `n`-byte element (a byte constant). -/
  | fill (n : Nat)
  /-- Unknown (the function didn't decode, or another instruction). -/
  | unknown
  deriving Repr, DecidableEq, Hashable, Inhabited

instance : ToString Use where
  toString
    | .copy n => s!"const {n}"
    | .addr => "addr.abs"
    | .fill n => s!"fill {n}"
    | .unknown => "unknown use"

/-- A pool offset the code references, its use, and the referencing functions' symbols. -/
structure CodeRef where
  k : Nat
  use : Use
  funcs : Array String
  deriving Inhabited

/-! ## The dump side -/

/-- A dumped global, prepared. -/
structure G where
  bytes : Array (Option UInt8)
  relocs : HashMap Nat Relocation
  align : Nat
  kind : GlobalKind
  /-- The first initialized byte outside the pointers, a cheap first filter. -/
  probe : Option (Nat × UInt8) := none
  deriving Inhabited

def G.size (g : G) : Nat := g.bytes.size

def G.pooled (g : G) : Bool := g.kind matches .const | .vtable _

/-- The globals a MIR body mentions: constants' allocations (`ptr`, `slice`, `indirect`),
`Unsize` vtables and thread-local statics, read off its JSON form (where each is the field
`alloc` or `g` of those constructors). -/
partial def globalsIn (j : Lean.Json) (acc : Array Nat) : Array Nat :=
  match j with
  | .obj kvs => kvs.foldl (init := acc) fun acc k v =>
    let acc := match k, v with
      | "alloc", .num _ => match v.getNat? with | .ok g => acc.push g | .error _ => acc
      | "alloc", .obj _ | "vtable", .obj _ | "threadLocalRef", .obj _ =>
        match v.getObjValAs? Nat "g" with | .ok g => acc.push g | .error _ => acc
      | _, _ => acc
    globalsIn v acc
  | .arr a => a.foldl (fun acc v => globalsIn v acc) acc
  | _ => acc

structure Ctx where
  prog : Program
  globals : Array G
  pool : PoolView
  /-- The dump's body instances by symbol, with the globals each body mentions. -/
  bodies : HashMap String (Array Nat)
  /-- All instances' symbols. -/
  symbols : HashSet String

def Ctx.make (prog : Program) (pool : PoolView) : Ctx :=
  let globals := prog.globals.map fun g =>
    let bytes := g.bytes.toArray
    let ptr (j : Nat) := g.relocs.any fun r => !(r.target matches .typeId) && r.offset ≤ j && j < r.offset + 8
    let probe := (List.range bytes.size).findSome? fun j =>
      match bytes[j]! with
      | some v => if ptr j then none else some (j, v)
      | none => none
    { bytes, relocs := g.relocs.foldl (fun m r => m.insert r.offset r) {},
      align := g.align.bytes, kind := g.kind, probe }
  let bodies := prog.instances.foldl (init := {}) fun s i =>
    match i.kind with
    | .body b => s.insert i.symbol (globalsIn (Lean.toJson b) #[])
    | _ => s
  let symbols := prog.instances.foldl (init := {}) fun s i => s.insert i.symbol
  { prog, globals, pool, bodies, symbols }

/-- A placement: global `g` at pool offset `b`. -/
abbrev Node := Nat × Nat

/-- A static pointer's symbol, to be checked for consistency. -/
abbrev Binding := Nat × String

private def hex2 (b : UInt8) : String :=
  let s := String.ofList (Nat.toDigits 16 b.toNat)
  if s.length < 2 then "0" ++ s else s

def kindName : GlobalKind → String
  | .const => "const"
  | .vtable _ => "vtable"
  | .static _ => "static"
  | .threadLocal => "thread local"

/-- The local check of placement `(gi, b)`: the placements it demands and the static
bindings it makes, or why it fails. -/
def localCheck (c : Ctx) (n : Node) : Except String (Array Node × Array Binding) := do
  let (gi, b) := n
  let some g := c.globals[gi]? | throw s!"no global {gi}"
  unless g.pooled do throw s!"g{gi} is a {kindName g.kind}, not a pool allocation"
  let P := c.pool
  if b + g.size > P.bytes.size then throw s!"g{gi} ({g.size} bytes) at {b} ends past the pool ({P.bytes.size} bytes)"
  if g.align == 0 || (P.start + b) % g.align != 0 || P.secAlign % g.align != 0 then
    throw s!"misaligned: g{gi} needs align {g.align}; pool offset {b} is section offset {P.start + b}, section align {P.secAlign}"
  -- Pointer fields (with provenance in the copy): offset → relocation.
  let mut demands : Array Node := #[]
  let mut binds : Array Binding := #[]
  let mut covered : HashSet Nat := {}
  for (off, r) in g.relocs.toList do
    if off + 8 > g.size then throw s!"g{gi}: pointer at {off} past its end"
    if r.target matches .typeId then continue
    for j in [0:8] do covered := covered.insert (off + j)
    let at_ := b + off
    let some pr := P.relocs[at_]? | throw s!"g{gi} at {b}: no relocation at offset {off} (pool {at_}) for its pointer to {repr r.target} + {r.addend}"
    match r.target, pr with
    | .fn i, .sym name a =>
      let want := c.prog.symbol i
      unless name == want && a == r.addend do
        throw s!"g{gi} at {b}: offset {off} relocated against {pr}, expected instance {i} `{want}` + {r.addend}"
    | .alloc t, .pool tgt =>
      let some tg := c.globals[t]? | throw s!"g{gi}: pointer to missing global {t}"
      if tg.pooled then
        let b' := tgt - r.addend
        if b' < 0 then throw s!"g{gi} at {b}: offset {off} points at pool {tgt}, before g{t}'s copy could start (addend {r.addend})"
        demands := demands.push (t, b'.toNat)
      else throw s!"g{gi} at {b}: offset {off} points into the pool, expected the {kindName tg.kind} g{t}'s symbol"
    | .alloc t, .sym name a =>
      let some tg := c.globals[t]? | throw s!"g{gi}: pointer to missing global {t}"
      if tg.pooled then throw s!"g{gi} at {b}: offset {off} relocated against {pr}, expected pool copy of {kindName tg.kind} g{t}"
      unless a == r.addend do throw s!"g{gi} at {b}: offset {off} relocated against {pr}, expected addend {r.addend}"
      binds := binds.push (t, name)
    | t, pr => throw s!"g{gi} at {b}: offset {off} relocated as {pr}, expected a pointer to {repr t} + {r.addend}"
  -- No other relocation overlaps the copy (one starting up to 7 bytes before it would).
  for p in [b - (if g.size == 0 then 0 else min b 7) : b + g.size] do
    if let some pr := P.relocs[p]? then
      let ok := p ≥ b && (g.relocs[p - b]?.any fun r => !(r.target matches .typeId))
      unless ok do throw s!"g{gi} at {b}: relocation {pr} at pool {p} where the allocation has no pointer"
  -- Bytes.
  for h : j in [0:g.size] do
    if covered.contains j then continue
    if let some v := g.bytes[j] then
      let w := P.bytes[b + j]!
      if v != w then throw s!"g{gi} at {b}: byte {j} (pool {b + j}) is 0x{hex2 w}, expected 0x{hex2 v}"
  return (demands, binds)

/-! ## The fixpoint -/

structure St where
  local_ : HashMap Node (Except String (Array Node × Array Binding)) := {}
  /-- Placements known valid (their whole demand closure holds locally). -/
  valid : HashSet Node := {}
  /-- Placements known invalid, with why. -/
  invalid : HashMap Node String := {}

abbrev M := StateM St

def localOf (c : Ctx) (n : Node) : M (Except String (Array Node × Array Binding)) := do
  if let some r := (← get).local_[n]? then return r
  let r := localCheck c n
  modify fun s => { s with local_ := s.local_.insert n r }
  return r

/-- Whether placement `root` is valid: every placement reachable over demand edges holds
locally. On success, the reachable placements and their static bindings. -/
def validate (c : Ctx) (root : Node) (fuel : Nat := 100000) :
    M (Except String (Array Node × Array Binding)) := do
  if let some e := (← get).invalid[root]? then return .error e
  let mut seen : HashSet Node := {}
  let mut work : Array (Node × List Node) := #[(root, [])]
  let mut nodes : Array Node := #[]
  let mut binds : Array Binding := #[]
  let mut fuel := fuel
  while h : work.size > 0 do
    let (n, path) := work.back
    work := work.pop
    if seen.contains n then continue
    seen := seen.insert n
    nodes := nodes.push n
    if fuel == 0 then
      modify fun s => { s with invalid := s.invalid.insert root "too many placements" }
      return .error "too many placements"
    fuel := fuel - 1
    if (← get).valid.contains n then continue
    match ← localOf c n with
    | .error e =>
      let via := path.reverse.map (fun (g, b) => s!"g{g} at {b}")
      let msg := if via.isEmpty then e else s!"{e} (demanded via {" -> ".intercalate via})"
      modify fun s => { s with invalid := s.invalid.insert root msg }
      return .error msg
    | .ok (ds, bs) =>
      binds := binds ++ bs
      for d in ds do work := work.push (d, n :: path)
  -- Bindings of already-valid nodes reached: recollect them (cached locally).
  let mut allBinds : Array Binding := #[]
  for n in nodes do
    if let .ok (_, bs) ← localOf c n then allBinds := allBinds ++ bs
  modify fun s => { s with valid := nodes.foldl (·.insert ·) s.valid }
  return .ok (nodes, allBinds)

/-! ## References -/

/-- Whether placement `(g, b)` covers a use at `k`. -/
def covers (g : G) (b k : Nat) : Use → Bool
  | .copy n => b ≤ k && k + n ≤ b + g.size
  | _ => b ≤ k && k ≤ b + g.size

/-- The verdict on one reference. -/
inductive Verdict where
  | matched (g b : Nat) (nodes : Array Node) (binds : Array Binding)
  | bytes
  | notInDump
  | mismatch (details : Array String)
  deriving Inhabited

/-- Candidate placements for `k`: exact (`b = k`) or interior (`b < k`), cheap filters
first (kind, size, alignment, the first initialized byte). -/
def candidates (c : Ctx) (gs : Array Nat) (k : Nat) (u : Use) (exact : Bool) : Array Node := Id.run do
  let P := c.pool
  let mut out := #[]
  for gi in gs do
    let some g := c.globals[gi]? | continue
    if !g.pooled || g.align == 0 then continue
    let lo := if exact then k else k - min k g.size
    let hi := if exact then k + 1 else k
    let mut b := lo + (g.align - (P.start + lo) % g.align) % g.align
    while b < hi do
      if covers g b k u && b + g.size ≤ P.bytes.size then
        let firstOk := match g.probe with
          | some (j, v) => P.bytes[b + j]! == v
          | none => true
        if firstOk then out := out.push (gi, b)
      b := b + g.align
  return out

/-- How many initialized bytes of `g` at `b` agree with the pool (for ranking candidates). -/
def agreement (c : Ctx) (n : Node) : Nat := Id.run do
  let (gi, b) := n
  let some g := c.globals[gi]? | return 0
  let mut s := 0
  for h : j in [0:g.size] do
    if let some v := g.bytes[j] then
      if b + j < c.pool.bytes.size && c.pool.bytes[b + j]! == v then s := s + 1
  return s

def checkRef (c : Ctx) (r : CodeRef) : M Verdict := do
  if r.use matches .fill _ then return .bytes
  let all := Array.range c.globals.size
  -- The globals the referencing functions' bodies mention, if any is in the dump.
  let inDump := r.funcs.filterMap (c.bodies[·]?)
  let mentioned := inDump.foldl (· ++ ·) #[]
  let mentioned := mentioned.foldl (fun (a : Array Nat) g => if a.contains g then a else a.push g) #[]
  let gs := if inDump.isEmpty then all else mentioned
  let first (gs : Array Nat) : M (Option Verdict) := do
    for exact in [true, false] do
      for n in candidates c gs r.k r.use exact do
        if let .ok (nodes, binds) ← validate c n then return some (.matched n.1 n.2 nodes binds)
    return none
  if let some v ← first gs then return v
  if inDump.isEmpty then return .notInDump
  -- Diagnose: the exact-offset placements of the mentioned globals covering the use, closest
  -- first, and any other global that would match.
  let mut details := #[]
  if let some (.matched g b _ _) ← first all then
    details := details.push s!"matches g{g} at {b}, which the referencing bodies don't mention (they mention {mentioned.toList.map (s!"g{·}")})"
  let mut cands : Array Node := #[]
  for gi in mentioned do
    let some g := c.globals[gi]? | continue
    if g.pooled && covers g r.k r.k r.use then cands := cands.push (gi, r.k)
  let ranked := (cands.map fun n => (n, agreement c n)).qsort (fun a b => a.2 > b.2)
  for (n, _) in ranked.toList.take 3 do
    match ← validate c n with
    | .error e => details := details.push e
    | .ok _ => pure ()
  if details.isEmpty then details := #[s!"no dumped const or vtable allocation fits ({r.use})"]
  return .mismatch details

/-- The dump-side D29 shape of vtable `g`, or what's wrong with it. -/
def vtableShape (c : Ctx) (gi : Nat) : Option String := Id.run do
  let some g := c.globals[gi]? | return some "missing"
  if g.size < 24 || g.size % 8 != 0 then return some s!"size {g.size}"
  let zero (o : Nat) := (List.range 8).all fun j => g.bytes[o + j]! == some 0
  let init (o : Nat) := (List.range 8).all fun j => (g.bytes[o + j]!).isSome
  for o in [0:g.size:8] do
    match g.relocs[o]? with
    | some r =>
      if o == 8 || o == 16 then return some s!"pointer in the size/align word at {o}"
      match r.target with
      | .fn _ => pure ()
      | .alloc t =>
        if o == 0 || !(c.globals[t]?.any fun t => t.kind matches .vtable _) then
          return some s!"word {o / 8} points at g{t}, not a function or vtable"
      | .typeId => return some s!"type id at word {o / 8}"
    | none =>
      if o == 8 || o == 16 then
        if !init o then return some s!"uninitialized size/align word at {o}"
      else if !zero o then return some s!"word {o / 8} neither a pointer nor null"
  -- `align` is a power of two.
  let a := (List.range 8).foldr (fun j acc => acc * 256 + ((g.bytes[16 + j]!).getD 0).toNat) 0
  if a == 0 || a &&& (a - 1) != 0 then return some s!"align {a}"
  return none

/-! ## The whole check -/

structure Report where
  refs : Nat := 0
  matched : Nat := 0
  matchedVtables : Nat := 0
  bytes : Nat := 0
  notInDump : Nat := 0
  mismatched : Nat := 0
  /-- Placements reached through pool relocations (beyond the references' own). -/
  reached : Nat := 0
  lines : Array String := #[]
  notInDumpLines : Array String := #[]
  /-- Object-level problems (the section, static symbol bindings, vtable shapes). -/
  errors : Array String := #[]
  deriving Inhabited

def Report.ok (r : Report) : Bool := r.mismatched == 0 && r.errors.isEmpty

/-- Checks the references `refs` against the dump `prog`. -/
def check (prog : Program) (pool : PoolView) (refs : Array CodeRef) : Report := Id.run do
  let c := Ctx.make prog pool
  let mut rep : Report := { refs := refs.size }
  let mut st : St := {}
  let mut roots : HashSet Node := {}
  let mut all : HashSet Node := {}
  let mut binds : Array Binding := #[]
  let mut vtables : HashSet Nat := {}
  for r in refs do
    let (v, st') := (checkRef c r).run st
    st := st'
    let from_ := ", ".intercalate (r.funcs.toList.take 3) ++ (if r.funcs.size > 3 then s!", +{r.funcs.size - 3}" else "")
    match v with
    | .matched g b nodes bs =>
      rep := { rep with matched := rep.matched + 1 }
      if c.globals[g]!.kind matches .vtable _ then rep := { rep with matchedVtables := rep.matchedVtables + 1 }
      roots := roots.insert (g, b)
      for n in nodes do
        all := all.insert n
        if c.globals[n.1]!.kind matches .vtable _ then vtables := vtables.insert n.1
      binds := binds ++ bs
    | .bytes => rep := { rep with bytes := rep.bytes + 1 }
    | .notInDump =>
      rep := { rep with notInDump := rep.notInDump + 1,
                        notInDumpLines := rep.notInDumpLines.push s!"not in dump: pool {r.k} ({r.use}) from {from_}" }
    | .mismatch ds =>
      rep := { rep with mismatched := rep.mismatched + 1,
                        lines := rep.lines.push s!"mismatch: pool {r.k} ({r.use}) from {from_}" ++ ds.map ("  " ++ ·) }
  rep := { rep with reached := (all.toList.filter (!roots.contains ·)).length }
  -- Statics: one symbol each, distinct, none an instance's.
  let mut byG : HashMap Nat String := {}
  let mut byName : HashMap String Nat := {}
  for (g, n) in binds do
    match byG[g]? with
    | some n' => if n != n' then rep := { rep with errors := rep.errors.push s!"static g{g} relocated against both `{n'}` and `{n}`" }
    | none => byG := byG.insert g n
    match byName[n]? with
    | some g' => if g != g' then rep := { rep with errors := rep.errors.push s!"statics g{g'} and g{g} both relocated against `{n}`" }
    | none => byName := byName.insert n g
    if c.symbols.contains n then rep := { rep with errors := rep.errors.push s!"static g{g} relocated against instance symbol `{n}`" }
  for g in vtables.toList do
    if let some e := vtableShape c g then rep := { rep with errors := rep.errors.push s!"vtable g{g}: not the D29 layout: {e}" }
  -- Dedup error lines.
  rep := { rep with errors := rep.errors.foldl (fun a e => if a.contains e then a else a.push e) #[] }
  return rep

/-! ## From the image object -/

/-- The pool of an image object: its bytes, its `R_X86_64_64` relocations by pool offset,
and its placement in the read-only section. -/
def poolOf (o : ImageObject) : PoolView := Id.run do
  let h := o.image.header
  let start := o.roBase + h.consts.off
  let bytes := o.image.bytes.extract h.consts.off (h.consts.off + h.consts.count)
  let mut relocs : HashMap Nat PRel := {}
  for r in o.roRelocs do
    if r.offset < start || r.offset ≥ start + h.consts.count then continue
    let pr : PRel :=
      match o.elf.symbol? r.sym with
      | none => .other s!"relocation against symbol index {r.sym}"
      | some s =>
        if r.type != .abs64 then .other s!"{r.type.name} against `{o.elf.symbolName s}` + {r.addend}"
        else if s.type == Elf.STT_SECTION then
          if s.shndx == o.ro.index then .pool ((s.value : Int) + r.addend - start)
          else .other s!"R_X86_64_64 against section `{o.elf.symbolName s}` + {r.addend}"
        else .sym (o.elf.symbolName s) r.addend
    relocs := relocs.insert (r.offset - start) pr
  return { bytes, relocs, start, secAlign := o.ro.addralign }

/-- Why the pool's section isn't read-only or RELRO, if it isn't. -/
def sectionProblem (o : ImageObject) : Option String :=
  let s := o.ro
  if s.flags &&& Elf.SHF_ALLOC == 0 then some s!"pool section `{s.name}` isn't allocated"
  else if s.flags &&& Elf.SHF_EXECINSTR != 0 then some s!"pool section `{s.name}` is executable"
  else if s.flags &&& Elf.SHF_WRITE != 0 && !s.name.startsWith ".data.rel.ro" then
    some s!"pool section `{s.name}` is writable and not RELRO (.data.rel.ro.*)"
  else none

/-- The pool references of the code: each function's `Ref.const` fields, with their use from
the decoded instructions. -/
def codeRefs (o : ImageObject) : Array CodeRef := Id.run do
  let mut m : HashMap (Nat × Use) (Array String) := {}
  let mut order : Array (Nat × Use) := #[]
  for h : i in [0:o.funcs.size] do
    let name := o.funcName o.funcs[i].codeOff
    let .ok fi := o.funcInputs i | continue
    let ks := fi.relocs.filterMap fun r => match r.to with | .const k => some k | _ => none
    if ks.isEmpty then continue
    let mut uses : Array (Nat × Use) := #[]
    if let .ok (some (.ok d)) := Ryo.Vm.DecodeObj.decodeFunc fi then
      for insn in d.insns do
        match insn with
        | .handler op args _ =>
          let mn := op.mnemonic
          let rec scan : List Ryo.Vm.R.Arg → Array (Nat × Use) → Array (Nat × Use)
            | .const k :: rest, acc =>
              let next := match rest with | .imm v :: _ => some v.toNat | _ => none
              let u := if mn == "const" then (next.map Use.copy).getD .unknown
                else if mn == "fill" then (next.map Use.fill).getD .unknown
                else if mn == "addr.abs" then .addr else .unknown
              scan rest (acc.push (k, u))
            | _ :: rest, acc => scan rest acc
            | [], acc => acc
          uses := scan args uses
        | .native op ops =>
          let mn := op.mnemonic
          let rec scanN : List (Ryo.Vm.R.Opnd Nat) → Array (Nat × Use) → Array (Nat × Use)
            | .const k :: rest, acc =>
              let next := match rest with | .imm v :: _ => some v.toNat | _ => none
              let u := if mn == "const" then (next.map Use.copy).getD .unknown
                else if mn == "fill" then (next.map Use.fill).getD .unknown
                else if mn == "addr.abs" then .addr else .unknown
              scanN rest (acc.push (k, u))
            | _ :: rest, acc => scanN rest acc
            | [], acc => acc
          uses := scanN ops uses
    -- Fields the decoding didn't account for (or all, if it failed): unknown use.
    for k in ks do
      unless uses.any (·.1 == k) do uses := uses.push (k, .unknown)
    for key in uses do
      match m[key]? with
      | some fs => unless fs.contains name do m := m.insert key (fs.push name)
      | none => m := m.insert key #[name]; order := order.push key
  return order.map fun key => { k := key.1, use := key.2, funcs := m[key]!.toList.toArray }

/-- The whole check on one image object. -/
def checkObject (prog : Program) (o : ImageObject) : Report :=
  let rep := check prog (poolOf o) (codeRefs o)
  match sectionProblem o with
  | some e => { rep with errors := rep.errors.push e }
  | none => rep

/-- The lines `ryo-lean check-pool` prints for one object. -/
def Report.render (r : Report) (path : String) (verbose : Bool := false) : Array String :=
  #[s!"pool-check {path}: refs {r.refs} matched {r.matched} (vtables {r.matchedVtables}) reached {r.reached} bytes {r.bytes} not-in-dump {r.notInDump} mismatched {r.mismatched} errors {r.errors.size}"]
    ++ r.errors.map ("error: " ++ ·) ++ r.lines ++ (if verbose then r.notInDumpLines else #[])

end Ryo.Check.Image.Pool
