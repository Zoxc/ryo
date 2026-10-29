//! The `RYO_STATS` coverage summary and the `RYO_DUMP_NATIVE` text
//! (design/backend.md#debugging-switches).

use std::collections::BTreeMap;

use rustc_hir::def_id::LOCAL_CRATE;
use rustc_middle::ty::{Instance, TyCtxt};

use super::lower::{CodeReloc, NeedsNative};
use super::partition::{Fresh, path};

/// Island and native-function tallies of the images built this session, shared by
/// `RYO_STATS` and `RYO_DUMP_NATIVE`.
struct Coverage<'a, 'tcx> {
    n_vm: usize,
    /// Each VM function with islands, with its island instructions by template name
    /// (by name: `Symbol`'s order is the interner's, which varies between compilations).
    with_islands: Vec<(Instance<'tcx>, BTreeMap<String, usize>)>,
    /// Island instructions in all functions.
    total: usize,
    /// Per template: its instructions, and the functions using it; by count, then name.
    templates: Vec<(String, (usize, usize))>,
    /// Native functions per reason; by count, then reason.
    reasons: Vec<(&'a str, usize)>,
}

/// Sorts `v` by `count` descending, then by key.
fn by_count_desc<K: Ord, V>(v: &mut [(K, V)], count: impl Fn(&V) -> usize) {
    v.sort_by(|a, b| count(&b.1).cmp(&count(&a.1)).then_with(|| a.0.cmp(&b.0)));
}

fn coverage<'a, 'tcx>(fresh: &[Fresh<'tcx>], failed: &'a [(Instance<'tcx>, NeedsNative)]) -> Coverage<'a, 'tcx> {
    let mut n_vm = 0;
    let mut with_islands = Vec::new();
    let mut templates: BTreeMap<String, (usize, usize)> = BTreeMap::new();
    for v in fresh.iter().flat_map(|f| f.vm.iter()) {
        n_vm += 1;
        let mut by: BTreeMap<String, usize> = BTreeMap::new();
        for r in &v.lowered.relocs {
            if let CodeReloc::Island { template, .. } = *r {
                *by.entry(template.to_string()).or_default() += 1;
            }
        }
        if !by.is_empty() {
            for (t, &n) in &by {
                let e = templates.entry(t.clone()).or_default();
                e.0 += n;
                e.1 += 1;
            }
            with_islands.push((v.instance, by));
        }
    }
    let total = templates.values().map(|t| t.0).sum();
    let mut templates: Vec<_> = templates.into_iter().collect();
    by_count_desc(&mut templates, |t| t.0);
    let mut reasons: BTreeMap<&str, usize> = BTreeMap::new();
    for (_, why) in failed {
        *reasons.entry(why.0.as_str()).or_default() += 1;
    }
    let mut reasons: Vec<_> = reasons.into_iter().collect();
    by_count_desc(&mut reasons, |&n| n);
    Coverage { n_vm, with_islands, total, templates, reasons }
}

/// The coverage summary of `RYO_STATS` (design/backend.md#debugging-switches): island
/// instructions per function and by template, and the native functions by reason, of the
/// images built this session.
pub(super) fn print_coverage<'tcx>(fresh: &[Fresh<'tcx>], failed: &[(Instance<'tcx>, NeedsNative)]) {
    let c = coverage(fresh, failed);
    let (total, n_vm) = (c.total, c.n_vm);
    let per_fn = if n_vm == 0 { 0.0 } else { total as f64 / n_vm as f64 };
    eprintln!("ryo: {total} island instructions in {} of {n_vm} VM functions ({per_fn:.2} per function)", c.with_islands.len());
    for (t, (n, fns)) in c.templates {
        eprintln!("ryo: island {t}: {n} in {fns} functions");
    }
    for (why, n) in c.reasons {
        eprintln!("ryo: native reason: {n} {why}");
    }
}

/// The `RYO_DUMP_NATIVE` text (design/backend.md#debugging-switches): a summary (native
/// functions by reason, island instructions by template), then each function that stays
/// native with its reason, each VM function also kept native (`keep_native`), and each VM
/// function with islands with its island instructions by template. Every line names the
/// function's crate (`[local]` for the crate being compiled) and its instance path, sorted,
/// so the text is deterministic.
pub(super) fn native_text<'tcx>(
    tcx: TyCtxt<'tcx>,
    fresh: &[Fresh<'tcx>],
    failed: &[(Instance<'tcx>, NeedsNative)],
    kept: &[Instance<'tcx>],
) -> String {
    use std::fmt::Write;
    let name = |i: Instance<'tcx>| {
        let k = i.def_id().krate;
        let krate = if k == LOCAL_CRATE { "local".to_owned() } else { tcx.crate_name(k).to_string() };
        format!("[{krate}] {}", path(i))
    };
    let c = coverage(fresh, failed);
    let mut natives: Vec<(String, &str)> = failed.iter().map(|(i, w)| (name(*i), w.0.as_str())).collect();
    natives.sort();
    let mut kept: Vec<String> = kept.iter().map(|i| name(*i)).collect();
    kept.sort();
    kept.dedup();
    let mut with: Vec<(String, BTreeMap<String, usize>)> = c.with_islands.into_iter().map(|(i, by)| (name(i), by)).collect();
    with.sort_by(|a, b| a.0.cmp(&b.0));
    let mut out = String::new();
    writeln!(out, "# {} native functions, by reason", natives.len()).unwrap();
    for (why, n) in c.reasons {
        writeln!(out, "{n:5} {why}").unwrap();
    }
    writeln!(out, "\n# {} island instructions in {} of {} VM functions, by template (instructions, functions)", c.total, with.len(), c.n_vm).unwrap();
    for (t, (n, fns)) in c.templates {
        writeln!(out, "{n:5} {fns:5} {t}").unwrap();
    }
    writeln!(out, "\n# native functions: [crate] instance: reason").unwrap();
    for (f, why) in &natives {
        writeln!(out, "{f}: {why}").unwrap();
    }
    writeln!(out, "\n# VM functions also kept native (local copies native code of their CGU references)").unwrap();
    for f in &kept {
        writeln!(out, "{f}").unwrap();
    }
    writeln!(out, "\n# VM functions with islands: [crate] instance: template x count, ...").unwrap();
    for (f, by) in &with {
        let list: Vec<String> = by.iter().map(|(t, n)| format!("{t} x{n}")).collect();
        writeln!(out, "{f}: {}", list.join(", ")).unwrap();
    }
    out
}
