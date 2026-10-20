//! Intrinsic calls (design/lowering.md#calls, `InstanceKind::Intrinsic`): the matching VM
//! instruction where one exists, otherwise the generic `call` island for safe intrinsics.
//! Unsafe intrinsics without a VM lowering or a wrapper template keep the function native.

use rustc_middle::mir::SourceInfo;
use rustc_middle::ty::{Instance, Ty};
use ryo_bytecode::insn::Opcode;

use super::call::{ArgSrc, CallCont};
use super::{FnCx, NeedsNative};

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    pub fn intrinsic_call(
        &mut self,
        callee: Instance<'tcx>,
        fty: Ty<'tcx>,
        args: &[ArgSrc<'_, 'tcx>],
        cont: CallCont<'tcx>,
        source_info: SourceInfo,
    ) -> Result<(), NeedsNative> {
        let name = self.tcx.item_name(callee.def_id());
        match name.as_str() {
            "abort" => {
                self.op(Opcode::Abort, &[]);
                Ok(())
            }
            _ => self.direct_call(fty, callee, args, cont, source_info),
        }
    }
}
