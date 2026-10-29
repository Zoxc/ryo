//! The `RYO_STATS` coverage summary and the `RYO_DUMP_NATIVE` text
//! (design/backend.md#debugging-switches).

use rustc_data_structures::fx::{FxHashSet, FxIndexMap};
use rustc_hir::def_id::LOCAL_CRATE;
use rustc_middle::ty::{Instance, TyCtxt};
use rustc_span::Symbol;

use super::lower::{CodeReloc, NeedsNative};
use super::partition::{Fresh, path};

/// The coverage summary of `RYO_STATS` (design/backend.md#debugging-switches): island
/// instructions per function and by template, and the native functions by reason, of the
/// images built this session.
pub(super) fn print_coverage(fresh: &[Fresh<'_>], failed: &[(Instance<'_>, NeedsNative)]) {
    let mut by_template: FxIndexMap<Symbol, (usize, usize)> = FxIndexMap::default();
    let mut with_islands = 0;
    let mut total = 0;
    let mut n_vm = 0;
    for v in fresh.iter().flat_map(|f| f.vm.iter()) {
        n_vm += 1;
        let mut n = 0;
        let mut seen = FxHashSet::default();
        for r in &v.lowered.relocs {
            if let CodeReloc::Island { template, .. } = *r {
                n += 1;
                let e = by_template.entry(template).or_default();
                e.0 += 1;
                e.1 += usize::from(seen.insert(template));
            }
        }
        total += n;
        with_islands += usize::from(n > 0);
    }
    let per_fn = if n_vm == 0 { 0.0 } else { total as f64 / n_vm as f64 };
    eprintln!("ryo: {total} island instructions in {with_islands} of {n_vm} VM functions ({per_fn:.2} per function)");
    let mut templates: Vec<_> = by_template.into_iter().collect();
    templates.sort_by(|a, b| b.1.0.cmp(&a.1.0).then_with(|| a.0.as_str().cmp(b.0.as_str())));
    for (t, (n, fns)) in templates {
        eprintln!("ryo: island {t}: {n} in {fns} functions");
    }
    let mut reasons: FxIndexMap<&str, usize> = FxIndexMap::default();
    for (_, why) in failed {
        *reasons.entry(why.0.as_str()).or_default() += 1;
    }
    let mut reasons: Vec<_> = reasons.into_iter().collect();
    reasons.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(b.0)));
    for (why, n) in reasons {
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
    use std::collections::BTreeMap;
    use std::fmt::Write;
    let name = |i: Instance<'tcx>| {
        let k = i.def_id().krate;
        let krate = if k == LOCAL_CRATE { "local".to_owned() } else { tcx.crate_name(k).to_string() };
        format!("[{krate}] {}", path(i))
    };
    let mut natives: Vec<(String, &str)> = failed.iter().map(|(i, w)| (name(*i), w.0.as_str())).collect();
    natives.sort();
    let mut reasons: BTreeMap<&str, usize> = BTreeMap::new();
    for (_, why) in &natives {
        *reasons.entry(why).or_default() += 1;
    }
    let mut kept: Vec<String> = kept.iter().map(|i| name(*i)).collect();
    kept.sort();
    kept.dedup();
    let mut n_vm = 0;
    let mut with: Vec<(String, BTreeMap<String, usize>)> = Vec::new();
    let mut templates: BTreeMap<&str, (usize, usize)> = BTreeMap::new();
    for v in fresh.iter().flat_map(|f| f.vm.iter()) {
        n_vm += 1;
        // By name: `Symbol`'s order is the interner's, which varies between compilations.
        let mut by: BTreeMap<String, usize> = BTreeMap::new();
        for r in &v.lowered.relocs {
            if let CodeReloc::Island { template, .. } = *r {
                *by.entry(template.to_string()).or_default() += 1;
            }
        }
        if !by.is_empty() {
            with.push((name(v.instance), by));
        }
    }
    with.sort_by(|a, b| a.0.cmp(&b.0));
    for (_, by) in &with {
        for (t, n) in by {
            let e = templates.entry(t.as_str()).or_default();
            e.0 += n;
            e.1 += 1;
        }
    }
    let mut out = String::new();
    writeln!(out, "# {} native functions, by reason", natives.len()).unwrap();
    let mut rs: Vec<_> = reasons.into_iter().collect();
    rs.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(b.0)));
    for (why, n) in rs {
        writeln!(out, "{n:5} {why}").unwrap();
    }
    let total: usize = templates.values().map(|t| t.0).sum();
    writeln!(out, "\n# {total} island instructions in {} of {n_vm} VM functions, by template (instructions, functions)", with.len()).unwrap();
    let mut ts: Vec<_> = templates.into_iter().collect();
    ts.sort_by(|a, b| b.1.0.cmp(&a.1.0).then_with(|| a.0.cmp(b.0)));
    for (t, (n, fns)) in ts {
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
