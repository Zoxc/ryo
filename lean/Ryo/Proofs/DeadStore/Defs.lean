/-
Ryo.Proofs.DeadStore.Defs — the shared definitions of the dead-store discharge (design T0):
what replaces `Hyps.deadStore` (`DeadStoreSim`) by the soundness of `Frame.droppedNotDead`.

The relation at a boundary becomes `DInv`: the real machine `x` is a *ghost* `xh` (the machine as
if the dropped stores had run) up to the frame bytes at offsets `P`, and the ghost is related to
R exactly (`BInv`). `P` holds only bytes some dropped store writes, each dead at `pc` or `Uninit`
in R and in a slot the boundary's cache covers (`PatchOk`).

**Real vs virtual state** (no-frame-pointer mode). `BInv S s xh` is `FrameInvR` (`FrameInv` of
`S.virt xh`, `rbp := rsp + F`, and `RbpOk`) plus `rip` on the real state and `CacheInv` on the
virtual one. `XAgree S P x xh` is stated on the *real* states, with the frame pointer the ghost's
virtual one (`vfp S xh`, `= fp`): registers (so `rsp`, and the real `rbp`), `xmm`, flags and `rip`
equal, memory equal off `vfp S xh + o`, `o ∈ P`. Equal registers make the virtual states agree the
same way (`xAgree_virt`, T5), so the item-level runs (on virtual states) and the relation (on real
ones) speak of the same bytes, and `RbpOk` carries over.

**`rip`** (settled): `XAgree` requires `x.rip = xh.rip`. Inline sequences run on both from the same
`rip` (the real code's position; in the no-frame-pointer form the same `FForm.virtAt fb kept`
shift, since the shift is a function of `kept` and `rip`). The ghost runs `out` (with the dropped
stores) by `execItems`, exactly as `CacheStep.inline_step_cached` does, so it ends at
`xh.rip + codeSize out`, while the real machine ends at `x.rip + codeSize kept`. The ghost at the
next boundary is therefore *re-jumped*: `xh'.jump x'.rip` (`execItems_skip`, T4). This is sound
because `FrameInvR` and `CacheInv` don't read `rip` (`frameInvR_jump`, `cacheInv_jump`, T5) and
`BInv`'s position conjunct is on `rip` alone; the items after a dropped store (an overflow op's
`setcc cl` and flag store) are `RipFree`, so the ghost's shifted `rip` doesn't change what they
compute. No ghost item semantics is needed.

**Non-inline steps** use the R shadow `erase s P` (the private bytes at `P` made `Uninit`; `P`
is private by `PatchOk`) and `RAgree P' s' t'` (equal but at `P'`, observationally).

- `Cert`: the certified flow `droppedNotDead` accepted (`Cert.ofChecked`); `Dead`, `PLive`,
  `Dropped` read it bit by bit (`bit`).
- `PatchOk`, `EscSound`, `GhostOk` (no certificate: `P` empty).
- `MemAgree`, `XAgreeAt`, `XAgree`, `vfp`; `KrAt`, `KrInv`, `KrOk`; `DInv`, `EmptyAt`.
- `eraseSt`, `erase`, `StEq`, `RAgree`.
- `InlineAt`; item level: `Writes`, `KeptW`, `DropW`, `ItemApart`, `KeptApart`, `PureStore`,
  `DroppedForm`.
- Trusted, named: `FootprintExact` (handler footprints' writes are exact), `FactsAgree` (the
  `Frame.Facts` the check used agree with the R code).
-/
import Ryo.Proofs.DecodeSound.Basic
import Ryo.Proofs.DeadStore.Esc
import Ryo.Vm.OpSem.Lemmas

namespace Ryo.Proofs.DeadStore

open Ryo.Spec Ryo.Vm Ryo.Vm.R Ryo.X86 Ryo.Proofs.DecodeSound Ryo.Proofs.DecodeLink

/-! ### The certificate -/

/-- The flow `droppedNotDead` certified for `S`'s code (when it has dropped stores): the facts it
used, the flow, the checked post-fixpoints, the `End` check and every dropped store shown dead. -/
structure Cert (S : Setup) where
  facts : Frame.Facts
  fl : Frame.Flow
  hfl : Frame.Flow.of S.c.d S.c.mode facts = .ok fl
  hlive : fl.liveOk fl.liveIn = true
  hesc : Frame.escOk S.c.d fl.edges fl.esc = true
  hdrop : ∀ k ∈ S.c.d.dropped.toList, Frame.droppedOk S.c.d fl fl.liveIn k = true
  /-- Each dropped store writes no byte of a may-escaped object (`droppedPrivate`). -/
  hpriv : ∀ k ∈ S.c.d.dropped.toList, Frame.droppedPrivate S.c.d fl k = true
  /-- The kept-read liveness (`Flow.keptReadLive`) is a post-fixpoint. -/
  hkept : fl.keptReadOk S.c.d (fl.keptReadLive S.c.d) = true
  /-- Each dropped store's destination is at or above `frameLo` (`droppedInFrame`). -/
  hframe : ∀ k ∈ S.c.d.dropped.toList, Frame.droppedInFrame S.c.d S.c.mode k = true
  /-- No kept item reads a dropped store's bytes from memory later (`droppedUnread`). -/
  hunread : ∀ k ∈ S.c.d.dropped.toList,
    Frame.droppedUnread S.c.d fl (fl.keptReadLive S.c.d) k = true
  /-- Each dropped store's item is a store of `droppedStore`'s range, the only one its
  instruction consumed (`droppedFormOk`). -/
  hform : ∀ k ∈ S.c.d.dropped.toList, Frame.droppedFormOk S.c.d k = true

/-- The certificate from `droppedNotDead`'s acceptance (`droppedNotDead_full`). -/
noncomputable def Cert.ofChecked {S : Setup} {facts : Frame.Facts}
    (h : Frame.droppedNotDead S.c.d S.c.mode facts = .ok []) (hne : S.c.d.dropped.isEmpty = false) :
    Cert S :=
  have e := droppedNotDead_full h hne
  { facts := facts
    fl := Classical.choose e
    hfl := (Classical.choose_spec e).1
    hlive := (Classical.choose_spec e).2.1
    hesc := (Classical.choose_spec e).2.2.1
    hdrop := fun k hk => ((Classical.choose_spec e).2.2.2.2 k hk).1
    hpriv := fun k hk => ((Classical.choose_spec e).2.2.2.2 k hk).2.1
    hkept := (Classical.choose_spec e).2.2.2.1
    hframe := fun k hk => ((Classical.choose_spec e).2.2.2.2 k hk).2.2.1
    hunread := fun k hk => ((Classical.choose_spec e).2.2.2.2 k hk).2.2.2.1
    hform := fun k hk => ((Classical.choose_spec e).2.2.2.2 k hk).2.2.2.2 }

/-- Frame offset `o`'s bit in the liveness bitsets (`F + o`). -/
def bit (S : Setup) (o : Int) : Nat := (o + (S.c.d.frameSize : Int)).toNat

/-- `o` is a frame byte the liveness tracks: `[-F, 0)`. -/
def InFrame (S : Setup) (o : Int) : Prop := -(S.c.d.frameSize : Int) ≤ o ∧ o < 0

/-- The certified kept-read liveness (`Frame.Flow.keptReadLive`). -/
abbrev Cert.kr {S : Setup} (C : Cert S) : Array Nat := C.fl.keptReadLive S.c.d

/-- Every frame byte of `P` is out of the kept-read liveness into instruction `k`
(`DeadStore/KeptRead.lean`). -/
def KrAt (S : Setup) (C : Cert S) (k : Nat) (P : Int → Prop) : Prop :=
  ∀ o, P o → InFrame S o → (C.kr[k]!).testBit (bit S o) = false

/-- `KrAt` at `s.pc`. -/
def KrInv (S : Setup) (C : Cert S) (s : R.RState) (P : Int → Prop) : Prop := KrAt S C s.pc P

/-- `KrInv` for the certificate, if any, at an instruction (a state past the code, which an
instruction at the end may fall through to, takes no step: `dinsn_oob`). -/
def KrOk (S : Setup) (oc : Option (Cert S)) (s : R.RState) (P : Int → Prop) : Prop :=
  ∀ C, oc = some C → s.pc < S.c.d.insns.size → KrInv S C s P

/-- Byte `o` is dead into instruction `k` (not in the certified `liveIn`). -/
def Dead (S : Setup) (C : Cert S) (k : Nat) (o : Int) : Prop :=
  InFrame S o ∧ (C.fl.liveIn[k]!).testBit (bit S o) = false

/-- Byte `o` is precise-live into `k` (`preciseLive`: operand reads only, `End`s ignored). -/
def PLive (S : Setup) (C : Cert S) (k : Nat) (o : Int) : Prop :=
  InFrame S o ∧ (C.fl.preciseLive[k]!).testBit (bit S o) = true

/-- Some dropped store writes byte `o` (`droppedBits`). -/
def Dropped (S : Setup) (o : Int) : Prop := (Frame.droppedBits S.c.d).testBit (bit S o) = true

/-! ### The patch set -/

/-- Frame byte `o` is in a slot some entry of the cache at boundary `k` caches (`S.cache k` or
`S.used k`, whichever `BInv` uses): the ghost must keep its value there (`Holds` reads memory). -/
def CacheCovers (S : Setup) (k : Nat) (o : Int) : Prop :=
  ∃ c : Asm.Cache, (c = S.cache k ∨ c = S.used k) ∧ ∃ e ∈ c.regs.toList, ∃ sl w,
    e.slot = some (sl, w) ∧ sl.toInt ≤ o ∧ o < sl.toInt + Asm.bytes w

/-- **To prove from `Decodes`** (the link of the checker's cache to the proof's): every frame
byte the cache at boundary `k` covers is in `Frame.coveredAt`. Route: `S.used k` is `S.cache k`
or empty (`Setup.used`); `S.cache k` is the cache after iteration `k - 1` (`Indexed`), which is
`inlineInsn`'s `after` for an inline proto (recorded as `Proto.cacheOut := cacheSlots after`,
copied to `Decoded.cacheOut` by `reducedOf`), and empty after a call or handler instruction and
during the leading `arg`s (empty at the entry, `arg` keeps it). -/
def CoveredAtSound (S : Setup) : Prop :=
  ∀ k o, k ≤ S.c.d.insns.size → CacheCovers S k o → InFrame S o →
    (Frame.coveredAt S.c.d k).testBit (bit S o) = true

/-- The bytes where the real machine may differ from the ghost at R state `s`: private frame
bytes a dropped store writes, each dead at `s.pc`, or `Uninit` in R (an `End` after the drop)
and in a slot the boundary's cache covers. An ended byte the cache doesn't cover leaves `P`: R
holds `Uninit` there, which any machine byte refines, so the ghost is re-chosen to the real
machine's byte (`ghost_drop_uninit`, T5). -/
def PatchOk (S : Setup) (C : Cert S) (s : R.RState) (P : Int → Prop) : Prop :=
  ∀ o, P o → InFrame S o ∧ Dropped S o ∧ s.st.escapedAt o = none ∧
    (Dead S C s.pc o ∨ (s.st.byteAt o = .ok .uninit ∧ CacheCovers S s.pc o))

/-- Escape soundness carried along (`Esc.lean`): R's escaped objects before `s.pc`'s scopes are
in a set the certified `esc` covers. -/
def EscSound (S : Setup) (C : Cert S) (s : R.RState) : Prop := EscPre S.c.d C.fl.esc s.pc s.st

/-- The ghost's side conditions: without a certificate (no dropped stores) nothing differs;
with one, `PatchOk` and, at an instruction, `EscSound` (a state past the code, which an inline
instruction at the end falls through to, has no `esc` entry; R's step fails there). -/
def GhostOk (S : Setup) : Option (Cert S) → R.RState → (Int → Prop) → Prop
  | none, _, P => ∀ o, ¬ P o
  | some C, s, P => PatchOk S C s P ∧ (s.pc < S.c.d.insns.size → EscSound S C s)

/-! ### Machine agreement -/

/-- Memories equal but at `fp + o`, `o ∈ P`. -/
def MemAgree (fp : BitVec 64) (P : Int → Prop) (m m' : X86.Mem) : Prop :=
  ∀ a, (∀ o, P o → a ≠ fp + BitVec.ofInt 64 o) → m a = m' a

/-- `x` is `xh` but in memory at `fp + P`: registers, `xmm`, flags and `rip` equal. -/
def XAgreeAt (fp : BitVec 64) (P : Int → Prop) (x xh : X86.State) : Prop :=
  x.regs = xh.regs ∧ x.xmm = xh.xmm ∧ x.flags = xh.flags ∧ x.rip = xh.rip ∧
    MemAgree fp P x.mem xh.mem

/-- The frame pointer of a real state: its virtual state's `rbp` (with a frame pointer, `rbp`;
without, `rsp + F`). -/
def vfp (S : Setup) (x : X86.State) : BitVec 64 := (S.virt x).reg .rbp

/-- The real `x` agrees with the real ghost `xh` but at the frame bytes `P` (see the module
comment). -/
def XAgree (S : Setup) (P : Int → Prop) (x xh : X86.State) : Prop := XAgreeAt (vfp S xh) P x xh

/-- **The new boundary relation**: `x` is a ghost related by `BInv`, up to the bytes `P`, no
byte of which the machine code reads from memory or an `Escape` copies later (`KrOk`). -/
def DInv (S : Setup) (oc : Option (Cert S)) (s : R.RState) (x : X86.State) : Prop :=
  ∃ P xh, GhostOk S oc s P ∧ BInv S s xh ∧ XAgree S P x xh ∧ KrOk S oc s P

/-- At boundary `k` with `rip` as `x`'s, the cache `BInv` uses is the empty one (after a
non-inline instruction; at a branch target). The ghost after a non-inline step needs no cache
entry. -/
def EmptyAt (S : Setup) (k : Nat) (x : X86.State) : Prop :=
  (x.rip = addrAt S.ctx (S.start k) ∧ S.cache k = { pe := S.c.mode.pe }) ∨
    (x.rip = addrAt S.ctx (posOf S.r k) ∧ S.used k = { pe := S.c.mode.pe })

/-! ### The R shadow -/

open Classical in
/-- The private frame bytes at `P` made `Uninit`. Memory is untouched: `PatchOk` keeps `P`
private (an `Escape` is a read of its bytes in `Flow.rowOf`, a dropped store writes no
may-escaped byte, `droppedPrivate`), so `SameButFrame` holds and query worlds are equal. -/
noncomputable def eraseSt (P : Int → Prop) (st : OpSem.State) : OpSem.State :=
  { st with frame := fun o => if P o then .uninit else st.frame o }

noncomputable def erase (s : R.RState) (P : Int → Prop) : R.RState := { s with st := eraseSt P s.st }

/-- Observationally equal OpSem states: everything but the private frame bytes at escaped
offsets (which nothing reads). -/
def StEq (a b : OpSem.State) : Prop :=
  a.escaped = b.escaped ∧ a.zeroSized = b.zeroSized ∧ a.mem = b.mem ∧ a.exposed = b.exposed ∧
    a.exception = b.exception ∧ ∀ o, a.escapedAt o = none → a.frame o = b.frame o

/-- `s` and `t` equal but at the frame bytes `P` (wherever stored). -/
def RAgree (P : Int → Prop) (s t : R.RState) : Prop :=
  s.pc = t.pc ∧ s.fp = t.fp ∧ s.args = t.args ∧ StEq (eraseSt P s.st) (eraseSt P t.st)

/-- Instruction `k` is an inline one (`Frame.effects` takes it by its items). -/
def InlineAt (S : Setup) (k : Nat) : Prop :=
  ∃ op ops, S.c.d.insns[k]? = some (.native op ops) ∧ (op.full.bind Asm.classOf).isSome = true

/-! ### Items -/

/-- Item `it` writes frame byte `o` (`frameWrite`: an `rbp`-based store). -/
def Writes (it : Item) (o : Int) : Prop :=
  ∃ m n, Asm.frameWrite it = some (m, n) ∧ m.disp.toInt ≤ o ∧ o < m.disp.toInt + n

def KeptW (kept : List Item) (o : Int) : Prop := ∃ it ∈ kept, Writes it o

def DropW (ds : List Asm.DroppedStore) (o : Int) : Prop := ∃ d ∈ ds, Writes d.item o

/-- The bytes item `it` reads through its memory operand (0: none, or a store / `lea`): the
checker's `Frame.itemReadBytes`. -/
abbrev readBytes (it : Item) : Nat := Frame.itemReadBytes it

/-- From `y`, the bytes item `it` reads through its memory operand (if any) miss `fp + P`. -/
def ItemApart (fp : BitVec 64) (P : Int → Prop) (it : Item) (y : X86.State) : Prop :=
  ∀ m, it.mem? = some m →
    ∀ j < readBytes it, ∀ o, P o → y.ea m + BitVec.ofNat 64 j ≠ fp + BitVec.ofInt 64 o

/-- `ItemApart` along the run of `items` from `y`. -/
def KeptApart (ctx : Ctx) (fp : BitVec 64) (P : Int → Prop) : List Item → X86.State → Prop
  | [], _ => True
  | it :: is, y => ItemApart fp P it y ∧ ∀ y', it.exec ctx y = .ok y' → KeptApart ctx fp P is y'

/-- `it` is a store of `n` bytes at `m` changing nothing else but `rip`. -/
def PureStore (ctx : Ctx) (it : Item) : Prop :=
  ∃ m n, Asm.frameWrite it = some (m, n) ∧ ∀ y y', it.exec ctx y = .ok y' →
    y'.regs = y.regs ∧ y'.xmm = y.xmm ∧ y'.flags = y.flags ∧
    ∀ a, (∀ j < n, a ≠ y.ea m + BitVec.ofNat 64 j) → y'.mem a = y.mem a

/-- A dropped store as `DroppedStore.ofParts?` builds it: `mov [rbp + off], r`. -/
def DroppedForm (d : Asm.DroppedStore) : Prop :=
  ∃ w r off, d.item = Item.st w r (X86.M.frame off)

/-! ### Trusted, named -/

/-- **Trusted** (tested: `RyoTest/OpSem.lean`, `vm/rt/tests/lean_opsem.rs`): a handler writes
every byte of its footprint's write ranges, as a function of its reads. With
`OpSem.opSem_reads_footprint` (equal wherever written) it gives equal on all write ranges: what
`Flow`'s `kill` assumes. -/
def FootprintExact : Prop :=
  ∀ (op : Full.Opcode) (ops : OpSem.Operands) (st1 st2 : OpSem.State) (ch : OpSem.Choice)
    (fp : OpSem.Footprint) (r1 r2 : OpSem.Control × OpSem.State),
    OpSem.footprint op = some fp → st1.SameButFrame st2 →
    (∀ o, (∃ r ∈ fp.readRanges (OpSem.opndVal op.info ops), OpSem.inRange o r = true) →
      st1.frame o = st2.frame o) →
    OpSem.opSem op ops st1 ch = .ok r1 → OpSem.opSem op ops st2 ch = .ok r2 →
    ∀ o, (∃ r ∈ fp.writeRanges (OpSem.opndVal op.info ops), OpSem.inRange o r = true) →
      r1.2.frame o = r2.2.frame o

/-- **Trusted** (or derived where `c` is built in Lean from the same image): the `Frame.Facts`
the check used agree with the R code. `noStack` is C1's call check (the argument list is the
register plan). -/
structure FactsAgree (facts : Frame.Facts) (c : R.Code) : Prop where
  stack : ∀ k m, facts.stackArgs k = some m → c.stackSize k ≤ m
  noStack : ∀ k op ops, c.d.insns[k]? = some (.native op ops) →
    Frame.mayHaveStackArgs c.mode.pe (Frame.callArgs ops) = false → c.stackSize k = 0
  sret : ∀ k m, facts.sretSize k = some m → c.sretSize k = some m
  island : ∀ k t, facts.islandTemplate k = some t → c.islandTemplate k = some t

/-! ### Small facts -/

theorem escSound_entry {S : Setup} (C : Cert S) {s : R.RState} (hpc : s.pc = 0)
    (hn : 0 < S.c.d.insns.size) (he : s.st.escaped = []) : EscSound S C s := by
  unfold EscSound
  rw [hpc]
  exact escPre_entry C.hesc hn he

theorem xAgree_refl (S : Setup) (P : Int → Prop) (x : X86.State) : XAgree S P x x := by
  unfold XAgree XAgreeAt MemAgree
  exact ⟨rfl, rfl, rfl, rfl, fun _ _ => rfl⟩

/-- A boundary of `BInv` is one of `DInv` (`P` empty). -/
theorem dinv_of_binv {S : Setup} {oc : Option (Cert S)} {s : R.RState} {x : X86.State}
    (h : BInv S s x) (he : ∀ C, oc = some C → EscSound S C s) : DInv S oc s x := by
  unfold DInv
  refine ⟨fun _ => False, x, ?_, h, xAgree_refl S _ x, ?_⟩
  rotate_left
  · intro C _ _ o ho
    exact (ho : False).elim
  cases oc with
  | none => exact fun _ ho => ho
  | some C => exact And.intro (fun _ ho => (ho : False).elim) (fun _ => he C rfl)

/-- At the entry (`pc = 0`, nothing escaped): `DInv` from `BInv`. -/
theorem dinv_of_binv_entry {S : Setup} {oc : Option (Cert S)} {s : R.RState} {x : X86.State}
    (h : BInv S s x) (hpc : s.pc = 0) (hn : 0 < S.c.d.insns.size) (he : s.st.escaped = []) :
    DInv S oc s x :=
  dinv_of_binv h fun C _ => escSound_entry C hpc hn he

end Ryo.Proofs.DeadStore
