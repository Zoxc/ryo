//! Frame layout: argument block, local slots and temporaries (design/lowering.md#frame-slots).
//!
//! ```text
//! fp + 0      header (caller fp, return pc)
//! fp + H      argument block (the ABI arguments, `sig::arg_block` layout)
//! …           other locals, then the temporaries of the statement being lowered
//! fp + frame_size
//! ```
//!
//! Every local gets its own slot for now. Slot sharing between locals whose storage ranges
//! don't overlap (`StorageLive`/`StorageDead`) is a later optimization; it only changes
//! [`Frame::new`].

use rustc_index::IndexVec;
use rustc_middle::mir::{Body, Local};
use rustc_middle::ty::layout::TyAndLayout;
use ryo_bytecode::abi::{self, HEADER_SIZE};

use super::sig::AbiSig;
use super::{FnCx, NeedsNative, native};

/// A local's slot.
#[derive(Clone, Copy)]
pub struct LocalSlot<'tcx> {
    pub off: u32,
    pub layout: TyAndLayout<'tcx>,
}

pub struct Frame<'tcx> {
    pub locals: IndexVec<Local, LocalSlot<'tcx>>,
    /// End of the local slots: temporaries start here.
    locals_end: u32,
    /// Next free temporary byte.
    temp_top: u32,
    /// Highest `temp_top` reached: the end of the frame.
    high: u32,
    /// The spread `rust-call` argument (design/lowering.md#frame-slots), with the index of
    /// its first field in the argument block: the prologue assembles it.
    pub spread: Option<(Local, usize)>,
}

impl<'tcx> Frame<'tcx> {
    /// Lays out the locals of `body`, whose arguments come in the argument block of `sig`.
    pub fn new(
        body: &Body<'tcx>,
        sig: &AbiSig<'tcx>,
        layout_of_local: impl Fn(Local) -> Result<TyAndLayout<'tcx>, NeedsNative>,
    ) -> Result<Self, NeedsNative> {
        let spread = body.spread_arg;
        let n_fixed = match spread {
            Some(s) => {
                if s.as_usize() != body.arg_count {
                    return native("spread argument isn't the last argument");
                }
                body.arg_count - 1
            }
            None => body.arg_count,
        };
        // A `#[track_caller]` function's location is an extra, last ABI input that no MIR
        // local stands for (`FnCx::caller_location`).
        let n_inputs = sig.inputs.len() - usize::from(sig.caller_location);
        let mut end = HEADER_SIZE + sig.block_size;
        let mut locals = IndexVec::with_capacity(body.local_decls.len());
        for local in body.local_decls.indices() {
            let layout = layout_of_local(local)?;
            if layout.is_unsized() {
                return native("unsized local");
            }
            let align = layout.align.abi.bytes() as u32;
            if align > abi::FRAME_ALIGN {
                return native("local aligned above 16");
            }
            let size = u32::try_from(layout.size.bytes()).map_err(|_| NeedsNative("local larger than 4 GiB".into()))?;
            let i = local.as_usize();
            let off = if (1..=n_fixed).contains(&i) {
                let f = sig.fields.get(i - 1).ok_or_else(|| NeedsNative("more arguments than the ABI".into()))?;
                if f.size != size {
                    return native("argument local doesn't match the ABI");
                }
                HEADER_SIZE + f.offset
            } else {
                let off = end.next_multiple_of(align.max(1));
                end = off.checked_add(size).ok_or_else(|| NeedsNative("frame too large".into()))?;
                off
            };
            locals.push(LocalSlot { off, layout });
        }
        let spread = spread.map(|s| (s, n_fixed));
        match spread {
            Some((s, first)) => {
                let fields = locals[s].layout.fields.count();
                if first + fields != n_inputs {
                    return native("spread argument doesn't match the ABI");
                }
            }
            None if n_fixed != n_inputs => return native("argument count doesn't match the ABI"),
            None => {}
        }
        if end > (1 << 30) {
            return native("frame too large");
        }
        Ok(Frame { locals, locals_end: end, temp_top: end, high: end, spread })
    }

    /// A temporary slot, live until [`Frame::reset_temps`].
    pub fn temp(&mut self, size: u64, align: u64) -> u32 {
        let off = self.temp_top.next_multiple_of(align.clamp(1, 16) as u32);
        self.temp_top = off + size as u32;
        self.high = self.high.max(self.temp_top);
        off
    }

    /// Frees every temporary (between statements).
    pub fn reset_temps(&mut self) {
        self.temp_top = self.locals_end;
    }

    pub fn frame_size(&self) -> u32 {
        abi::frame_size(self.high)
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// A temporary of `layout`'s size and alignment.
    pub fn temp_for(&mut self, layout: TyAndLayout<'tcx>) -> u32 {
        self.frame.temp(layout.size.bytes(), layout.align.abi.bytes())
    }

    /// An 8-byte temporary (pointers, `usize`).
    pub fn temp8(&mut self) -> u32 {
        self.frame.temp(8, 8)
    }

    /// The prologue: assembles the spread `rust-call` argument from the argument block.
    pub fn prologue(&mut self, sig: &AbiSig<'tcx>) {
        let Some((local, first)) = self.frame.spread else { return };
        let slot = self.frame.locals[local];
        for i in 0..slot.layout.fields.count() {
            let f = sig.fields[first + i];
            let dst = slot.off + slot.layout.fields.offset(i).bytes() as u32;
            self.mov(dst, HEADER_SIZE + f.offset, f.size);
        }
    }
}
