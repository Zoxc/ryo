//! Source locations for backtraces (design/vm.md#source-locations): with `-Cdebuginfo`, each
//! statement's and terminator's `SourceInfo` becomes the location run of the calls it lowers
//! to ([`Asm::set_loc`]): its span's file, line and column, preceded by one element per scope
//! rustc's MIR inliner folded in (the inlined function's name with the span in it), as
//! cg_llvm's inlined-subroutine debuginfo would describe the same code.

use rustc_data_structures::fx::FxHashMap;
use rustc_middle::mir::{SourceInfo, SourceScope};
use rustc_middle::ty::TyCtxt;
use rustc_span::{Pos, Span};
use ryo_bytecode::image::SrcLoc;

use super::FnCx;

/// A function's location runs, by `(span, scope)`.
pub struct Locs {
    /// `-Cdebuginfo` is at least line tables.
    on: bool,
    pub runs: Vec<Vec<SrcLoc>>,
    ids: FxHashMap<(Span, SourceScope), u32>,
}

impl Locs {
    pub fn new(tcx: TyCtxt<'_>) -> Locs {
        Locs { on: tcx.sess.opts.debuginfo != rustc_session::config::DebugInfo::None, runs: Vec::new(), ids: FxHashMap::default() }
    }
}

impl<'a, 'tcx> FnCx<'a, 'tcx> {
    /// Makes `si` the location of the instructions emitted from here on.
    pub(super) fn set_loc(&mut self, si: SourceInfo) {
        if !self.locs.on {
            return;
        }
        let key = (si.span, si.scope);
        let tag = match self.locs.ids.get(&key) {
            Some(&t) => t,
            None => {
                let run = self.loc_run(si);
                let t = self.locs.runs.len() as u32;
                self.locs.runs.push(run);
                self.locs.ids.insert(key, t);
                t
            }
        };
        self.asm.set_loc(tag);
    }

    /// The run of `si`, innermost first.
    fn loc_run(&self, si: SourceInfo) -> Vec<SrcLoc> {
        let scopes = &self.body.source_scopes;
        let mut run = Vec::new();
        let (mut span, mut scope) = (si.span, si.scope);
        loop {
            let data = &scopes[scope];
            let inlined = if data.inlined.is_some() { Some(scope) } else { data.inlined_parent_scope };
            match inlined {
                Some(s) => {
                    let (callee, call_span) = scopes[s].inlined.expect("an inlined scope");
                    // Its symbol name, as cg_llvm's linkage name on the inlined subprogram
                    // (without a `LocalCopy` suffix): the symbolizer demangles it.
                    let name = crate::original_symbol_name(self.tcx, self.mono(callee)).name.to_owned();
                    run.push(self.src_loc(span, Some(name)));
                    span = call_span;
                    match scopes[s].parent_scope {
                        Some(p) => scope = p,
                        None => break,
                    }
                }
                None => {
                    run.push(self.src_loc(span, None));
                    break;
                }
            }
        }
        run
    }

    /// `span`'s location, its macro expansions collapsed to their call site in the body as
    /// cg_ssa does (`walk_chain_collapsed`).
    fn src_loc(&self, span: Span, inlined: Option<String>) -> SrcLoc {
        let span = rustc_span::hygiene::walk_chain_collapsed(span, self.body.span);
        let pos = span.lo();
        // As cg_llvm's `lookup_debug_loc`: 1-based lines, byte columns, no column on MSVC.
        let (sf, line, col) = match self.tcx.sess.source_map().lookup_line(pos) {
            Ok(rustc_span::SourceFileAndLine { sf, line }) => {
                let col = (sf.relative_position(pos) - sf.lines()[line]).to_u32() + 1;
                let col = if self.tcx.sess.target.is_like_msvc { 0 } else { col };
                (sf, line as u32 + 1, col)
            }
            Err(sf) => (sf, 0, 0),
        };
        // As cg_llvm's `file_metadata`: the embeddable name, which DWARF joins to its
        // working directory where it is relative.
        let file = match &sf.name {
            rustc_span::FileName::Real(r) => {
                let (dir, name) = r.embeddable_name(rustc_span::RemapPathScopeComponents::DEBUGINFO);
                dir.join(name).to_string_lossy().into_owned()
            }
            other => other.prefer_remapped_unconditionally().to_string(),
        };
        SrcLoc { file, line, col, inlined }
    }
}
