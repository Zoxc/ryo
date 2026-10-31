//! The runtime crates' identity: `ryo_rt` and the items the backend uses from it, found by
//! their diagnostic items, and the VM's own crates, which stay native.

use rustc_hir::def_id::{CrateNum, DefId};
use rustc_middle::ty::TyCtxt;
use rustc_span::Symbol;

/// The `ryo_rt` items the backend instantiates or checks (design/stubs.md, Lookup).
#[derive(Clone, Copy)]
pub struct RtItems {
    pub krate: CrateNum,
    pub c_main: DefId,
}

impl RtItems {
    /// `ryo_rt`'s item with diagnostic item name `name` (`#[rustc_diagnostic_item]`).
    pub fn item(&self, tcx: TyCtxt<'_>, name: Symbol) -> Option<DefId> {
        rt_item(tcx, self.krate, name)
    }
}

fn rt_item(tcx: TyCtxt<'_>, krate: CrateNum, name: Symbol) -> Option<DefId> {
    tcx.diagnostic_items(krate).name_to_id.get(&name).copied()
}

/// The diagnostic item name of `ryo_rt::entry::c_main`.
pub const C_MAIN_ITEM: &str = "ryo_c_main";

/// `ryo_rt`'s crate and template items, found through its diagnostic items. `None` if
/// `ryo_rt` isn't loaded (rustc wasn't run through `rustc-ryo`); a fatal error if it is
/// loaded but lacks an item (a `ryo_rt` from another source version).
pub fn rt_items(tcx: TyCtxt<'_>) -> Option<RtItems> {
    let krate = *tcx.crates(()).iter().find(|&&c| is_rt_crate(tcx, c))?;
    let get = |name: &str| {
        rt_item(tcx, krate, Symbol::intern(name))
            .unwrap_or_else(|| tcx.dcx().fatal(format!("the loaded `{RT_CRATE}` lacks the `{name}` diagnostic item; it doesn't match this backend")))
    };
    Some(RtItems { krate, c_main: get(C_MAIN_ITEM) })
}

/// The runtime crate's name.
pub const RT_CRATE: &str = "ryo_rt";

/// Whether `krate` is `ryo_rt`.
pub fn is_rt_crate(tcx: TyCtxt<'_>, krate: CrateNum) -> bool {
    tcx.crate_name(krate).as_str() == RT_CRATE
}

/// The VM's own crates: always native (`partition::vm_enabled`), their copies of other crates'
/// generics are never linked to ([`upstream_monomorphizations`](super::exports::upstream_monomorphizations)), and every final artifact
/// links a private copy of them (`dylib_dependency_formats`). (`ryo_jit` is sealed into
/// `ryo_rt`, so it is a crate only when built on its own, as with `-Zbuild-std`.)
pub const RUNTIME_CRATES: [&str; 3] = [RT_CRATE, "ryo_bytecode", "ryo_jit"];

/// Whether `krate` is one of [`RUNTIME_CRATES`].
pub fn is_runtime_crate(tcx: TyCtxt<'_>, krate: CrateNum) -> bool {
    RUNTIME_CRATES.contains(&tcx.crate_name(krate).as_str())
}
