//! Parsing ryo's `RYO_STATS` summaries (design/backend.md#debugging-switches): VM and native
//! function counts, islands by template, native functions by reason.

use super::timing::Unit;

/// `RYO_STATS` coverage of a set of units: summed totals, island instructions by template and
/// native functions by reason.
#[derive(Clone, Debug, Default, PartialEq)]
pub struct Coverage {
    pub vm: u64,
    pub native: u64,
    pub islands: u64,
    pub templates: Vec<(String, u64)>,
    pub reasons: Vec<(String, u64)>,
}

impl Coverage {
    pub fn vm_percent(&self) -> f64 {
        let all = self.vm + self.native;
        if all == 0 { 0.0 } else { 100.0 * self.vm as f64 / all as f64 }
    }
}

/// Adds the `RYO_STATS` lines of `units` (design/backend.md#debugging-switches).
pub fn coverage<'a>(units: impl IntoIterator<Item = &'a Unit>) -> Coverage {
    coverage_of_lines(units.into_iter().flat_map(|u| u.ryo.iter().map(String::as_str)))
}

/// Adds `RYO_STATS` lines, without their `ryo: ` prefix; other lines are ignored.
pub fn coverage_of_lines<'a>(lines: impl IntoIterator<Item = &'a str>) -> Coverage {
    let mut c = Coverage::default();
    let add = |list: &mut Vec<(String, u64)>, key: &str, n: u64| match list.iter_mut().find(|(k, _)| k == key) {
        Some(e) => e.1 += n,
        None => list.push((key.to_owned(), n)),
    };
    for line in lines {
        if let Some((v, rest)) = line.split_once(" VM functions, ")
            && let Some((n, rest)) = rest.split_once(" native functions, ")
            && let Some((i, _)) = rest.split_once(" islands")
        {
            c.vm += v.parse().unwrap_or(0);
            c.native += n.parse().unwrap_or(0);
            c.islands += i.parse().unwrap_or(0);
        } else if let Some(rest) = line.strip_prefix("island ")
            && let Some((t, rest)) = rest.split_once(": ")
            && let Some((n, _)) = rest.split_once(' ')
        {
            add(&mut c.templates, t, n.parse().unwrap_or(0));
        } else if let Some(rest) = line.strip_prefix("native reason: ")
            && let Some((n, why)) = rest.split_once(' ')
        {
            add(&mut c.reasons, why, n.parse().unwrap_or(0));
        }
    }
    c.templates.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    c.reasons.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    c
}
