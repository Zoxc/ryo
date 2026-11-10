/-
Ryo.Check.Lower.StmtExt — the statement rules of all families (aot.md §C1, M5b): `LowerStmtX`
is `Stmt.lean`'s `LowerStmt` or one of the families' relations (`Copy.lean`, `IntCast.lean`,
`Unop.lean`, `Deref.lean`, `Field.lean`, `Cmp.lean`, `Agg.lean`, `Ref.lean`), and `checkStmtX`
decides it, trying `checkStmt` and then each family's checker (`checkStmtX_sound`). Every family's rule is an assignment to a
whole local; all but `Agg`'s lower it to one instruction. `checkAgg` goes first: it declines
whole-local copies of a `mov` width (Copy's), and claims split copies and aggregates. `Deref`'s
`store` rule is the one assignment to a projected place; `checkDeref` runs before `checkField`,
which reports reads through a deref as unsupported. `checkDerefSplit` (before `checkDeref`),
`checkBinFloat` and `checkFloatCast` answer `none` unless they accept, so they go first;
`checkPoolConst` (`PoolConst.lean`) goes before them all: it claims only pointers to globals and
slice constants; `checkFnPtrCast` (`FnPtrCast.lean`) right after it: fn coercions and vtable
unsizings.
-/
import Ryo.Check.Lower.Copy
import Ryo.Check.Lower.IntCast
import Ryo.Check.Lower.Unop
import Ryo.Check.Lower.Field
import Ryo.Check.Lower.Cmp
import Ryo.Check.Lower.Agg
import Ryo.Check.Lower.Wide
import Ryo.Check.Lower.Enum
import Ryo.Check.Lower.Deref
import Ryo.Check.Lower.Ref
import Ryo.Check.Lower.RefDeref
import Ryo.Check.Lower.RefDerefWide
import Ryo.Check.Lower.Intrinsic
import Ryo.Check.Lower.BinX
import Ryo.Check.Lower.Offset
import Ryo.Check.Lower.Ovf
import Ryo.Check.Lower.OvfConst
import Ryo.Check.Lower.NicheRead
import Ryo.Check.Lower.DivConst
import Ryo.Check.Lower.BinMore
import Ryo.Check.Lower.OvfMore
import Ryo.Check.Lower.BinFloatConst
import Ryo.Check.Lower.RawPtrAgg
import Ryo.Check.Lower.UnionAgg
import Ryo.Check.Lower.ZstRead
import Ryo.Check.Lower.StoreTemp
import Ryo.Check.Lower.SplitRead
import Ryo.Check.Lower.DiscrPlace
import Ryo.Check.Lower.FieldWrite
import Ryo.Check.Lower.StmtEsc
import Ryo.Check.Lower.DerefWide
import Ryo.Check.Lower.CmpFloat
import Ryo.Check.Lower.DerefZst
import Ryo.Check.Lower.RefDerefIdx
import Ryo.Check.Lower.RefDerefDown
import Ryo.Check.Lower.DerefStoreF
import Ryo.Check.Lower.IdxRead
import Ryo.Check.Lower.RefDerefWideE
import Ryo.Check.Lower.CmpX
import Ryo.Check.Lower.CmpConst
import Ryo.Check.Lower.BoolBin
import Ryo.Check.Lower.DerefCast
import Ryo.Check.Lower.CopyNO
import Ryo.Check.Lower.OffsetConst
import Ryo.Check.Lower.BinXConst
import Ryo.Check.Lower.CastMore
import Ryo.Check.Lower.DerefSplit
import Ryo.Check.Lower.FloatCast
import Ryo.Check.Lower.PoolConst
import Ryo.Check.Lower.FnPtrCast

namespace Ryo.Check.Lower

open Ryo.Spec Ryo.Vm Ryo.Vm.R

inductive LowerStmtX (Γ : StmtCtx) (st : Statement) (is : List Insn) : Prop where
  | base (h : LowerStmt Γ st is)
  | copy (h : LowerCopy Γ st is)
  | intCast (h : LowerIntCast Γ st is)
  | unop (h : LowerUnop Γ st is)
  | field (h : LowerField Γ st is)
  | cmp (h : LowerCmp Γ st is)
  | agg (h : LowerAgg Γ st is)
  | wide (h : LowerWide Γ st is)
  | enum (h : LowerEnum Γ st is)
  | deref (h : LowerDeref Γ st is)
  | ref (h : LowerRef Γ st is)
  | refDeref (h : LowerRefDeref Γ st is)
  | refDerefWide (h : LowerRefDerefWide Γ st is)
  | binX (h : LowerBinX Γ st is)
  | offset (h : LowerOffset Γ st is)
  | ovf (h : LowerOvf Γ st is)
  | ovfConst (h : LowerOvfConst Γ st is)
  | nicheRead (h : LowerNicheRead Γ st is)
  | divConst (h : LowerDivConst Γ st is)
  | binMore (h : LowerBinMore Γ st is)
  | ovfMore (h : LowerOvfMore Γ st is)
  | binFloatConst (h : LowerBinFloatConst Γ st is)
  | rawPtrAgg (h : LowerRawPtrAgg Γ st is)
  | unionAgg (h : LowerUnionAgg Γ st is)
  | zstRead (h : LowerZstRead Γ st is)
  | storeTemp (h : LowerStoreTemp Γ st is)
  | splitRead (h : LowerSplitRead Γ st is)
  | discrPlace (h : LowerDiscrPlace Γ st is)
  | fieldWrite (h : LowerFieldWrite Γ st is)
  | fieldCopyN (h : LowerFieldCopyN Γ st is)
  | stmtEsc (h : LowerStmtEsc Γ st is)
  | derefWide (h : LowerDerefWide Γ st is)
  | cmpFloat (h : LowerCmpFloat Γ st is)
  | derefZst (h : LowerDerefZst Γ st is)
  | refDerefIdx (h : LowerRefDerefIdx Γ st is)
  | refDerefDown (h : LowerRefDerefDown Γ st is)
  | derefStoreF (h : LowerDerefStoreF Γ st is)
  | idxRead (h : LowerIdxRead Γ st is)
  | refDerefWideE (h : LowerRefDerefWideE Γ st is)
  | cmpX (h : LowerCmpX Γ st is)
  | cmpConst (h : LowerCmpConst Γ st is)
  | boolBin (h : LowerBoolBin Γ st is)
  | derefCast (h : LowerDerefCast Γ st is)
  | copyNO (h : LowerCopyNO Γ st is)
  | offsetConst (h : LowerOffsetConst Γ st is)
  | binXConst (h : LowerBinXConst Γ st is)
  | intrinsic (h : LowerIntrinsic Γ st is)
  | castMore (h : LowerCastMore Γ st is)
  | derefSplit (h : LowerDerefSplit Γ st is)
  | binFloat (h : LowerBinFloat Γ st is)
  | floatCast (h : LowerFloatCast Γ st is)
  | poolConst (h : LowerPoolConst Γ st is)
  | fnPtrCast (h : LowerFnPtrCast Γ st is)

/-- The families' checkers in turn: the first that claims the statement decides it. -/
def checkFamilies (Γ : StmtCtx) (st : Statement) (is : List Insn) : Option Verdict :=
  match checkPoolConst Γ st is with
  | some v => some v
  | none =>
  match checkFnPtrCast Γ st is with
  | some v => some v
  | none =>
  match checkDerefSplit Γ st is with
  | some v => some v
  | none =>
  match checkBinFloat Γ st is with
  | some v => some v
  | none =>
  match checkFloatCast Γ st is with
  | some v => some v
  | none =>
  match checkStmtEsc Γ st is with
  | some v => some v
  | none =>
  match checkBinFloatConst Γ st is with
  | some v => some v
  | none =>
  match checkOvfMore Γ st is with
  | some v => some v
  | none =>
  match checkBinMore Γ st is with
  | some v => some v
  | none =>
  match checkDivConst Γ st is with
  | some v => some v
  | none =>
  match checkNicheRead Γ st is with
  | some v => some v
  | none =>
  match checkOvfConst Γ st is with
  | some v => some v
  | none =>
  match checkOvf Γ st is with
  | some v => some v
  | none =>
  match checkRefDerefWideE Γ st is with
  | some v => some v
  | none =>
  match checkIdxRead Γ st is with
  | some v => some v
  | none =>
  match checkDerefStoreF Γ st is with
  | some v => some v
  | none =>
  match checkRefDerefIdx Γ st is with
  | some v => some v
  | none =>
  match checkRefDerefDown Γ st is with
  | some v => some v
  | none =>
  match checkDerefZst Γ st is with
  | some v => some v
  | none =>
  match checkCmpFloat Γ st is with
  | some v => some v
  | none =>
  match checkDerefWide Γ st is with
  | some v => some v
  | none =>
  match checkZstRead Γ st is with
  | some v => some v
  | none =>
  match checkStoreTemp Γ st is with
  | some v => some v
  | none =>
  match checkSplitRead Γ st is with
  | some v => some v
  | none =>
  match checkDiscrPlace Γ st is with
  | some v => some v
  | none =>
  match checkFieldCopyN Γ st is with
  | some v => some v
  | none =>
  match checkFieldWrite Γ st is with
  | some v => some v
  | none =>
  match checkEnum Γ st is with
  | some v => some v
  | none =>
  match checkWide Γ st is with
  | some v => some v
  | none => match checkRawPtrAgg Γ st is with
  | some v => some v
  | none => match checkUnionAgg Γ st is with
  | some v => some v
  | none => match checkAgg Γ st is with
  | some v => some v
  | none => match checkCopy Γ st is with
    | some v => some v
    | none => match checkIntCast Γ st is with
      | some v => some v
      | none => match checkUnop Γ st is with
        | some v => some v
        | none => match checkDeref Γ st is with
          | some v => some v
          | none => match checkField Γ st is with
            | some v => some v
            | none => match checkRefDerefWide Γ st is with
              | some v => some v
              | none => match checkRefDeref Γ st is with
              | some v => some v
              | none => match checkRef Γ st is with
              | some v => some v
              | none => match checkIntrinsic Γ st is with
                | some v => some v
                | none => match checkCastMore Γ st is with
                  | some v => some v
                  | none => match checkBinXConst Γ st is with
                    | some v => some v
                    | none => match checkOffsetConst Γ st is with
                    | some v => some v
                    | none => match checkBinX Γ st is with
                    | some v => some v
                    | none => match checkOffset Γ st is with
                      | some v => some v
                      | none => match checkCmpConst Γ st is with
                        | some v => some v
                        | none => match checkCmpX Γ st is with
                          | some v => some v
                          | none => match checkBoolBin Γ st is with
                            | some v => some v
                            | none => match checkDerefCast Γ st is with
                              | some v => some v
                              | none => match checkCopyNO Γ st is with
                                | some v => some v
                                | none => checkCmp Γ st is

def checkStmtX (Γ : StmtCtx) (st : Statement) (is : List Insn) : Verdict :=
  match checkStmt Γ st is with
  | .ok => .ok
  | v => (checkFamilies Γ st is).getD v

theorem checkFamilies_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkFamilies Γ st is = some .ok) : LowerStmtX Γ st is := by
  unfold checkFamilies at h
  split at h
  next v hv => cases h; exact .poolConst (checkPoolConst_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .fnPtrCast (checkFnPtrCast_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .derefSplit (checkDerefSplit_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .binFloat (checkBinFloat_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .floatCast (checkFloatCast_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .stmtEsc (checkStmtEsc_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .binFloatConst (checkBinFloatConst_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .ovfMore (checkOvfMore_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .binMore (checkBinMore_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .divConst (checkDivConst_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .nicheRead (checkNicheRead_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .ovfConst (checkOvfConst_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .ovf (checkOvf_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .refDerefWideE (checkRefDerefWideE_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .idxRead (checkIdxRead_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .derefStoreF (checkDerefStoreF_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .refDerefIdx (checkRefDerefIdx_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .refDerefDown (checkRefDerefDown_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .derefZst (checkDerefZst_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .cmpFloat (checkCmpFloat_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .derefWide (checkDerefWide_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .zstRead (checkZstRead_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .storeTemp (checkStoreTemp_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .splitRead (checkSplitRead_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .discrPlace (checkDiscrPlace_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .fieldCopyN (checkFieldCopyN_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .fieldWrite (checkFieldWrite_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .enum (checkEnum_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .wide (checkWide_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .rawPtrAgg (checkRawPtrAgg_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .unionAgg (checkUnionAgg_sound hv)
  next =>
  split at h
  next v hv => cases h; exact .agg (checkAgg_sound hv)
  next =>
    split at h
    next v hv => cases h; exact .copy (checkCopy_sound hv)
    next =>
      split at h
      next v hv => cases h; exact .intCast (checkIntCast_sound hv)
      next =>
        split at h
        next v hv => cases h; exact .unop (checkUnop_sound hv)
        next =>
          split at h
          next v hv => cases h; exact .deref (checkDeref_sound hv)
          next =>
            split at h
            next v hv => cases h; exact .field (checkField_sound hv)
            next =>
              split at h
              next v hv => cases h; exact .refDerefWide (checkRefDerefWide_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .refDeref (checkRefDeref_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .ref (checkRef_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .intrinsic (checkIntrinsic_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .castMore (checkCastMore_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .binXConst (checkBinXConst_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .offsetConst (checkOffsetConst_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .binX (checkBinX_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .offset (checkOffset_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .cmpConst (checkCmpConst_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .cmpX (checkCmpX_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .boolBin (checkBoolBin_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .derefCast (checkDerefCast_sound hv)
              next =>
              split at h
              next v hv => cases h; exact .copyNO (checkCopyNO_sound hv)
              next => exact .cmp (checkCmp_sound h)

theorem checkStmtX_sound {Γ : StmtCtx} {st : Statement} {is : List Insn}
    (h : checkStmtX Γ st is = .ok) : LowerStmtX Γ st is := by
  unfold checkStmtX at h
  split at h
  next hb => exact .base (checkStmt_sound hb)
  next hne =>
    cases hf : checkFamilies Γ st is with
    | none => rw [hf] at h; simp only [Option.getD] at h; exact absurd h hne
    | some v =>
      rw [hf] at h
      simp only [Option.getD] at h
      subst h
      exact checkFamilies_sound hf

end Ryo.Check.Lower
