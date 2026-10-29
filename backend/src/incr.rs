//! Incremental reuse of images (design/backend.md#incremental): the side data saved with
//! each CGU's image ([`CguVm::save`], encoded by [`super::persist`]), the image work product's
//! name and files, reusing the previous session's when the image's dep node is green, and
//! saving this session's.

use std::path::{Path, PathBuf};

use rustc_middle::dep_graph::{DepNode, WorkProduct, WorkProductId, WorkProductMap};
use rustc_middle::mono::MonoItem;
use rustc_middle::ty::{Instance, TyCtxt};
use rustc_session::{IncrCompSession, Session};
use rustc_span::Symbol;

use super::{link, persist};

/// What one CGU's image gives the native CGUs and the exported-symbols queries: its VM
/// functions (and whether the image defines a global symbol for each), the island instances it
/// calls, the items it refers to by symbol, and the symbol `__ryo_main` points
/// at. A function of the CGU's own items and tracked queries alone, so it is saved with the
/// image and read back when the image is reused (design/backend.md#incremental, `persist.rs`).
pub(super) struct CguVm<'tcx> {
    pub(super) vm: Vec<(Instance<'tcx>, bool)>,
    pub(super) islands: Vec<Instance<'tcx>>,
    pub(super) refs: Vec<MonoItem<'tcx>>,
    pub(super) main: Option<String>,
}

type CguVmData<'tcx> = (Vec<(Instance<'tcx>, bool)>, Vec<Instance<'tcx>>, Vec<MonoItem<'tcx>>, Option<String>);

impl<'tcx> CguVm<'tcx> {
    pub(super) fn empty() -> Self {
        CguVm { vm: Vec::new(), islands: Vec::new(), refs: Vec::new(), main: None }
    }

    /// The side data: a byte saying whether the CGU has an image object (it has VM
    /// functions), readable before the image's dep node is green, a checksum of that byte and
    /// the rest ([`CguVm::split`]), then the encoded fields.
    pub(super) fn save(&self, tcx: TyCtxt<'tcx>) -> Vec<u8> {
        let body = persist::encode(tcx, &(&self.vm, &self.islands, &self.refs, &self.main));
        let has_object = u8::from(!self.vm.is_empty());
        let mut out = vec![has_object];
        out.extend_from_slice(&side_checksum(has_object, &body));
        out.extend(body);
        out
    }

    /// Saved side data's has-object byte and encoded fields, if it is whole: its checksum
    /// matches. Checked before the image's dep node is marked green, so a corrupted file
    /// rebuilds the image rather than panicking in the decoder (`MemDecoder`'s footer check
    /// only catches truncation).
    fn split(data: &[u8]) -> Option<(bool, &[u8])> {
        let (head, body) = data.split_at_checked(SIDE_HEADER)?;
        (head[1..] == side_checksum(head[0], body)).then_some((head[0] != 0, body))
    }

    /// Decodes the encoded fields ([`CguVm::split`]'s body).
    fn load(tcx: TyCtxt<'tcx>, body: &[u8]) -> Option<Self> {
        let (vm, islands, refs, main): CguVmData<'tcx> = persist::decode(tcx, body)?;
        Some(CguVm { vm, islands, refs, main })
    }
}

/// The length of [`CguVm::save`]'s header: the has-object byte and the checksum.
const SIDE_HEADER: usize = 17;

/// The stable hash of `v`.
pub(super) fn stable_fingerprint<T: std::hash::Hash + ?Sized>(v: &T) -> rustc_data_structures::fingerprint::Fingerprint {
    let mut h = rustc_data_structures::stable_hash::StableHasher::new();
    v.hash(&mut h);
    h.finish()
}

/// [`CguVm::save`]'s checksum of the side data: its first byte and the encoded fields.
fn side_checksum(has_object: u8, body: &[u8]) -> [u8; 16] {
    stable_fingerprint(&(has_object, body)).to_le_bytes()
}

/// The work product name of CGU `cgu`'s image (its object and side data).
pub fn image_work_product_name(cgu: Symbol) -> String {
    format!("{cgu}.ryo")
}

/// The image work product's file keys (and the side data's extension): the side data
/// ([`CguVm::save`]) and the image object (none if the CGU has no VM function).
pub const WP_SIDE: &str = "ryo";
pub const WP_OBJECT: &str = "o";

/// The previous session's image work product of CGU `cgu` and its side data, if they are whole
/// and the image's dep node `node` could be marked green.
pub(super) fn try_reuse<'tcx>(tcx: TyCtxt<'tcx>, cgu: Symbol, node: &DepNode) -> Option<(WorkProduct, CguVm<'tcx>)> {
    let wp = image_work_product_name(cgu);
    let prev = tcx.dep_graph.previous_work_product(&WorkProductId::from_cgu_name(&wp))?;
    let incr = tcx.incr_comp_session?;
    let side = std::fs::read(rustc_incremental::in_incr_comp_dir_sess(incr, prev.saved_files.get(WP_SIDE)?)).ok()?;
    // A work product saved without its object (rustc only warns when a file fails to copy
    // into the cache) can't be reused; the side data says whether it had one.
    let (has_object, body) = CguVm::split(&side)?;
    if has_object && !prev.saved_files.contains_key(WP_OBJECT) {
        return None;
    }
    tcx.dep_graph.try_mark_green(tcx, node)?;
    let vm = CguVm::load(tcx, body).unwrap_or_else(|| tcx.dcx().fatal(format!("ryo: the saved image of `{cgu}` is unreadable")));
    Some((prev, vm))
}

/// How an image's work product is saved.
pub(super) enum ImageSave {
    /// Written this session, with its side data at this path.
    Fresh(PathBuf),
    /// The previous session's work product, and the cached object it was copied from.
    Reused(WorkProduct, Option<PathBuf>),
}

/// Places the previous session's image object `wp` at `image_path`, as cg_ssa reuses a CGU's
/// (`execute_copy_from_cache_work_item`).
pub(super) fn place_reused_image(tcx: TyCtxt<'_>, wp: &WorkProduct, image_path: &Path) -> ImageSave {
    let incr = tcx.incr_comp_session.expect("a reused image without an incremental session");
    let from = wp.saved_files.get(WP_OBJECT).map(|f| rustc_incremental::in_incr_comp_dir_sess(incr, f));
    if let Some(from) = &from {
        let _ = std::fs::remove_file(image_path);
        link::link_or_copy(tcx.sess, from, image_path);
    }
    ImageSave::Reused(wp.clone(), from)
}

/// Saves CGU `cgu`'s image work product (its object at `object`, if it has one) into
/// `work_products`: this session's copied into the incremental cache, or the previous
/// session's kept. Returns the cached object a reused image was copied from.
pub(super) fn save_work_product(
    sess: &Session,
    incr: Option<&IncrCompSession>,
    cgu: Symbol,
    object: Option<&Path>,
    save: ImageSave,
    work_products: &mut WorkProductMap,
) -> Option<PathBuf> {
    let wp_name = image_work_product_name(cgu);
    match save {
        ImageSave::Fresh(side) => {
            if let Some(incr) = incr {
                let mut files = vec![(WP_SIDE, side.as_path())];
                files.extend(object.map(|p| (WP_OBJECT, p)));
                let (id, wp) = rustc_incremental::copy_cgu_workproduct_to_incr_comp_cache_dir(sess, incr, &wp_name, &files, &[]);
                work_products.insert(id, wp);
            }
            if !sess.opts.cg.save_temps {
                let _ = std::fs::remove_file(&side);
            }
            None
        }
        ImageSave::Reused(wp, from) => {
            work_products.insert(WorkProductId::from_cgu_name(&wp_name), wp);
            from
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The checksum covers the has-object byte, which gates reuse, as well as the fields.
    #[test]
    fn side_checksum_covers_every_byte() {
        let body = [1u8, 2, 3, 4];
        let mut data = vec![1u8];
        data.extend_from_slice(&side_checksum(1, &body));
        data.extend_from_slice(&body);
        assert_eq!(CguVm::split(&data), Some((true, &body[..])));
        for i in [0, 1, SIDE_HEADER, data.len() - 1] {
            let mut bad = data.clone();
            bad[i] ^= 1;
            assert!(CguVm::split(&bad).is_none(), "byte {i}");
        }
        assert!(CguVm::split(&data[..10]).is_none());
    }
}
