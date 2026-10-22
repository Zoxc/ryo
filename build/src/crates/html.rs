//! The `y bench crates` report: a self-contained HTML file (inline CSS, SVG and a little JS
//! for tooltips) and a text summary.

use std::fmt::Write;

use super::stats::Summary;
use super::timing::{Coverage, Totals, Unit, coverage, totals};
use super::{Backend, Cell, Report, Step};

#[derive(Clone, Copy, PartialEq)]
enum Measure {
    Secs,
    Bytes,
}

struct Metric {
    id: &'static str,
    title: &'static str,
    what: &'static str,
    unit: Measure,
    pick: fn(&Cell) -> Vec<f64>,
    /// In the text summary.
    summary: bool,
}

fn steps(steps: &[Step], f: impl Fn(&Step) -> f64) -> Vec<f64> {
    steps.iter().map(f).collect()
}

fn sum(step: &Step, primary: Option<bool>) -> Totals {
    totals(step.units.iter().filter(|u| primary.is_none_or(|p| u.primary == p)))
}

const METRICS: &[Metric] = &[
    Metric {
        id: "build-wall",
        title: "Build: wall time",
        what: "cargo build --lib of the crate, its dependencies already built",
        unit: Measure::Secs,
        pick: |c| steps(&c.build, |s| s.wall),
        summary: true,
    },
    Metric {
        id: "build-deps-backend",
        title: "Build: dependencies, backend",
        what: "the codegen section (backend) summed over the dependencies, build scripts and proc macros (clean builds)",
        unit: Measure::Secs,
        pick: |c| steps(&c.dep_build, |s| sum(s, Some(false)).backend),
        summary: false,
    },
    Metric {
        id: "build-deps-frontend",
        title: "Build: dependencies, frontend",
        what: "process start to the codegen section, summed over the dependencies",
        unit: Measure::Secs,
        pick: |c| steps(&c.dep_build, |s| sum(s, Some(false)).frontend),
        summary: false,
    },
    Metric {
        id: "build-deps-rustc",
        title: "Build: dependencies, rustc total",
        what: "rustc wall time summed over the dependencies",
        unit: Measure::Secs,
        pick: |c| steps(&c.dep_build, |s| sum(s, Some(false)).wall),
        summary: true,
    },
    Metric {
        id: "build-leaf-backend",
        title: "Build: leaf crate, backend",
        what: "the codegen section of the benchmarked crate's library",
        unit: Measure::Secs,
        pick: |c| steps(&c.build, |s| sum(s, Some(true)).backend),
        summary: true,
    },
    Metric {
        id: "build-leaf-frontend",
        title: "Build: leaf crate, frontend",
        what: "process start to the codegen section, for the benchmarked crate's library",
        unit: Measure::Secs,
        pick: |c| steps(&c.build, |s| sum(s, Some(true)).frontend),
        summary: false,
    },
    Metric {
        id: "build-leaf-rustc",
        title: "Build: leaf crate, rustc total",
        what: "rustc wall time of the benchmarked crate's library",
        unit: Measure::Secs,
        pick: |c| steps(&c.build, |s| sum(s, Some(true)).wall),
        summary: true,
    },
    Metric {
        id: "test-build-wall",
        title: "Test build: wall time",
        what: "cargo build --tests (= cargo test --no-run), on top of the library build in the same target directory, so only dev-dependencies and the test targets",
        unit: Measure::Secs,
        pick: |c| steps(&c.test_build, |s| s.wall),
        summary: true,
    },
    Metric {
        id: "test-build-backend",
        title: "Test build: backend",
        what: "the codegen section summed over every unit of the test build",
        unit: Measure::Secs,
        pick: |c| steps(&c.test_build, |s| sum(s, None).backend),
        summary: false,
    },
    Metric {
        id: "test-build-link",
        title: "Test build: link",
        what: "the link section summed over every unit of the test build",
        unit: Measure::Secs,
        pick: |c| steps(&c.test_build, |s| sum(s, None).link),
        summary: false,
    },
    Metric {
        id: "test-run",
        title: "Test run time",
        what: "every test binary run once with RUST_TEST_THREADS=1, summed (doc tests excluded)",
        unit: Measure::Secs,
        pick: |c| c.test_run.clone(),
        summary: true,
    },
    Metric {
        id: "workload",
        title: "Workload run time",
        what: "tests/crates/<crate>.rs, built as an example against the crate",
        unit: Measure::Secs,
        pick: |c| c.workload.clone(),
        summary: true,
    },
    Metric {
        id: "size-workload",
        title: "Binary size: workload",
        what: "the workload executable (debuginfo=0, not stripped)",
        unit: Measure::Bytes,
        pick: |c| c.workload_size.map(|s| s as f64).into_iter().collect(),
        summary: true,
    },
    Metric {
        id: "size-tests",
        title: "Binary size: test binaries",
        what: "all test executables, summed",
        unit: Measure::Bytes,
        pick: |c| c.tests_size.map(|s| s as f64).into_iter().collect(),
        summary: false,
    },
];

fn fmt_value(v: f64, unit: Measure) -> String {
    match unit {
        Measure::Secs if v < 1.0 => format!("{:.0} ms", v * 1e3),
        Measure::Secs if v < 10.0 => format!("{v:.2} s"),
        Measure::Secs => format!("{v:.1} s"),
        Measure::Bytes if v >= 1e6 => format!("{:.2} MB", v / 1e6),
        Measure::Bytes => format!("{:.0} kB", v / 1e3),
    }
}

fn esc(s: &str) -> String {
    s.replace('&', "&amp;").replace('<', "&lt;").replace('>', "&gt;").replace('"', "&quot;")
}

/// Whether a cell has a problem the tables must show.
/// Whether a cell has a problem the tables must show, for a metric of kind `kind`
/// ([`metric_kind`]): the build's, the tests' or the workload's failures.
fn cell_state(cell: &Cell, kind: &str) -> Option<String> {
    if cell.build_failed {
        return Some("build failed".into());
    }
    let prefix = match kind {
        "workload" => "workload:",
        "test" => "test:",
        _ => return None,
    };
    match cell.errors.iter().filter(|e| e.starts_with(prefix)).count() {
        0 => None,
        n => Some(format!("{n} {kind} failure(s)")),
    }
}

fn metric_kind(id: &str) -> &'static str {
    match id {
        "workload" | "size-workload" => "workload",
        "test-run" | "size-tests" => "test",
        _ => "build",
    }
}

const CSS: &str = r#"
:root { --bg:#fcfcfb; --fg:#0b0b0b; --fg2:#52514e; --grid:#e4e3df; --b0:#2a78d6; --b1:#eb6834; --b2:#1baf7a;
  --s0:#eda100; --s1:#e87ba4; --s2:#008300; --s3:#6250d6; --warn-bg:#fff4d6; --bad-bg:#fde3e2; --bad:#b3261e; }
@media (prefers-color-scheme: dark) { :root { --bg:#1a1a19; --fg:#f0efec; --fg2:#c3c2b7; --grid:#3a3936;
  --b0:#3987e5; --b1:#d95926; --b2:#199e70; --s0:#c98500; --s1:#d55181; --s2:#008300; --s3:#9085e9;
  --warn-bg:#4a3b10; --bad-bg:#4d1d1b; --bad:#ff8a80; } }
body { background:var(--bg); color:var(--fg); font:14px/1.45 system-ui, sans-serif; margin:2em auto; max-width:1100px; padding:0 1em; }
h1 { font-size:1.6em; } h2 { margin-top:2em; border-bottom:1px solid var(--grid); padding-bottom:.2em; } h3 { margin-bottom:.2em; }
.muted { color:var(--fg2); }
table { border-collapse:collapse; margin:.5em 0 1em; font-variant-numeric:tabular-nums; }
th, td { padding:3px 10px; border-bottom:1px solid var(--grid); text-align:right; vertical-align:top; }
th:first-child, td:first-child { text-align:left; }
table.hdr td { text-align:left; } table.hdr td:first-child { color:var(--fg2); white-space:nowrap; }
td.noisy { background:var(--warn-bg); } td.bad { background:var(--bad-bg); color:var(--bad); }
.sub { color:var(--fg2); font-size:.85em; }
svg text { fill:var(--fg); font:12px system-ui, sans-serif; } svg .axis { fill:var(--fg2); font-size:11px; }
svg .grid { stroke:var(--grid); } svg .ref { stroke:var(--fg2); stroke-dasharray:3 3; }
.legend span { display:inline-block; margin-right:1.2em; } .sw { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:4px; vertical-align:-1px; }
#tip { position:fixed; pointer-events:none; background:var(--bg); color:var(--fg); border:1px solid var(--grid);
  border-radius:4px; padding:6px 8px; font-size:12px; box-shadow:0 2px 8px rgba(0,0,0,.2); display:none; white-space:pre; z-index:9; }
details { margin:.5em 0; } summary { cursor:pointer; color:var(--fg2); }
.fail { color:var(--bad); }
"#;

const JS: &str = r#"
const tip = document.getElementById('tip');
document.querySelectorAll('[data-tip]').forEach(el => {
  el.addEventListener('mousemove', e => { tip.textContent = el.dataset.tip; tip.style.display = 'block';
    tip.style.left = Math.min(e.clientX + 14, innerWidth - tip.offsetWidth - 8) + 'px'; tip.style.top = (e.clientY + 14) + 'px'; });
  el.addEventListener('mouseleave', () => { tip.style.display = 'none'; });
});
"#;

fn backend_color(i: usize) -> String {
    format!("var(--b{})", i.min(2))
}

fn tip_text(crate_name: &str, backend: Backend, s: &Summary, unit: Measure, llvm: Option<&Summary>) -> String {
    let mut t = format!(
        "{crate_name} · {}\nmedian {}\nmin {}  max {}\nstddev {} ({:.1}%)  n={}",
        backend.name(),
        fmt_value(s.median, unit),
        fmt_value(s.min, unit),
        fmt_value(s.max, unit),
        fmt_value(s.stddev, unit),
        if s.median > 0.0 { 100.0 * s.stddev / s.median } else { 0.0 },
        s.n
    );
    if let Some(l) = llvm.filter(|l| l.median > 0.0) {
        let _ = write!(t, "\n{:.2}× llvm", s.median / l.median);
    }
    if s.noisy() {
        t.push_str("\nnoisy (stddev > 3% of median)");
    }
    t
}

/// A dot plot of each backend's median relative to LLVM's, per crate, on a log axis, with
/// whiskers at ± one standard deviation. Absolute values are in the tooltips and the table.
fn ratio_chart(r: &Report, m: &Metric, data: &[Vec<Option<Summary>>]) -> String {
    let Some(llvm) = r.backends.iter().position(|&b| b == Backend::Llvm) else { return String::new() };
    let mut ratios: Vec<f64> = vec![1.0];
    for row in data {
        let Some(base) = row[llvm].as_ref().filter(|s| s.median > 0.0) else { continue };
        for s in row.iter().flatten() {
            ratios.push((s.median - s.stddev).max(s.median * 0.5) / base.median);
            ratios.push((s.median + s.stddev) / base.median);
        }
    }
    let lo = ratios.iter().copied().fold(f64::INFINITY, f64::min).max(1e-3);
    let hi = ratios.iter().copied().fold(0.0, f64::max).max(1.0);
    let ticks: Vec<f64> = [0.1, 0.2, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0, 1000.0]
        .into_iter()
        .filter(|t| *t >= lo / 1.5 && *t <= hi * 1.5)
        .collect();
    let (lo, hi) = (lo.min(ticks[0]).min(0.8), hi.max(*ticks.last().unwrap()).max(1.25));
    let (left, width, row_h, band) = (170.0, 820.0, 16.0, 8.0);
    let nb = r.backends.len() as f64;
    let group_h = nb * row_h + band;
    let height = 30.0 + data.len() as f64 * group_h;
    let x = |v: f64| left + (v.ln() - lo.ln()) / (hi.ln() - lo.ln()) * (width - left - 20.0);
    let mut s = format!(r#"<svg viewBox="0 0 {width} {height}" width="100%" role="img" aria-label="{} relative to LLVM">"#, esc(m.title));
    for t in &ticks {
        let tx = x(*t);
        let class = if *t == 1.0 { "ref" } else { "grid" };
        let _ = write!(
            s,
            r#"<line class="{class}" x1="{tx:.1}" x2="{tx:.1}" y1="18" y2="{:.1}"/><text class="axis" x="{tx:.1}" y="12" text-anchor="middle">{t}×</text>"#,
            height - 4.0
        );
    }
    for (ci, row) in data.iter().enumerate() {
        let gy = 24.0 + ci as f64 * group_h;
        let name = r.crates[ci].krate.name;
        let _ = write!(s, r#"<text x="0" y="{:.1}">{name}</text>"#, gy + nb * row_h / 2.0 + 4.0);
        let base = row[llvm].as_ref().filter(|s| s.median > 0.0);
        for (bi, cell) in row.iter().enumerate() {
            let cy = gy + bi as f64 * row_h + row_h / 2.0;
            let color = backend_color(bi);
            let backend = r.backends[bi];
            match (cell, base) {
                (Some(v), Some(b)) => {
                    let (x0, x1, xm) =
                        (x(((v.median - v.stddev).max(v.median * 0.5)) / b.median), x((v.median + v.stddev) / b.median), x(v.median / b.median));
                    let tip = esc(&tip_text(name, backend, v, m.unit, Some(b)));
                    let _ = write!(
                        s,
                        r#"<g data-tip="{tip}"><rect x="{:.1}" y="{:.1}" width="{:.1}" height="{row_h}" fill="transparent"/><line x1="{x0:.1}" x2="{x1:.1}" y1="{cy:.1}" y2="{cy:.1}" stroke="{color}" stroke-width="2"/><line x1="{x0:.1}" x2="{x0:.1}" y1="{:.1}" y2="{:.1}" stroke="{color}" stroke-width="2"/><line x1="{x1:.1}" x2="{x1:.1}" y1="{:.1}" y2="{:.1}" stroke="{color}" stroke-width="2"/><circle cx="{xm:.1}" cy="{cy:.1}" r="5" fill="{color}" stroke="var(--bg)" stroke-width="2"/><text class="axis" x="{:.1}" y="{:.1}">{}</text></g>"#,
                        left - 10.0,
                        cy - row_h / 2.0,
                        width - left,
                        cy - 4.0,
                        cy + 4.0,
                        cy - 4.0,
                        cy + 4.0,
                        x1.max(xm + 6.0) + 6.0,
                        cy + 4.0,
                        fmt_value(v.median, m.unit)
                    );
                }
                _ => {
                    let what = if cell.is_some() { "no LLVM baseline" } else { "failed / no data" };
                    let _ = write!(s, r#"<text class="axis" x="{left}" y="{:.1}" fill="var(--bad)">{} {what}</text>"#, cy + 4.0, backend.name());
                }
            }
        }
    }
    s.push_str("</svg>");
    s
}

/// Per crate and backend, a stacked bar of the summed rustc time of `cargo build --lib` and
/// `cargo build --tests`: frontend, backend, link, other (medians over samples).
fn breakdown_chart(r: &Report) -> String {
    const PARTS: [&str; 4] = ["frontend", "backend", "link", "other"];
    let med = |steps: &[Step], f: &dyn Fn(&Totals) -> f64| {
        Summary::of(&steps.iter().map(|s| f(&sum(s, None))).collect::<Vec<_>>()).map_or(0.0, |s| s.median)
    };
    let mut rows: Vec<(String, usize, [f64; 4])> = Vec::new();
    for c in &r.crates {
        for (bi, cell) in c.cells.iter().enumerate() {
            let all: Vec<Step> = cell
                .build
                .iter()
                .zip(&cell.test_build)
                .map(|(a, b)| Step { wall: a.wall + b.wall, units: a.units.iter().chain(&b.units).cloned().collect() })
                .collect();
            let parts = [med(&all, &|t| t.frontend), med(&all, &|t| t.backend), med(&all, &|t| t.link), med(&all, &|t| t.other)];
            rows.push((format!("{} · {}", c.krate.name, r.backends[bi].name()), bi, parts));
        }
    }
    let max = rows.iter().map(|r| r.2.iter().sum::<f64>()).fold(0.0, f64::max).max(1e-9);
    let (left, width, bar, gap) = (200.0, 820.0, 12.0, 4.0);
    let nb = r.backends.len().max(1);
    let height = 10.0 + rows.len() as f64 * (bar + gap) + (rows.len() / nb) as f64 * 8.0;
    let scale = (width - left - 70.0) / max;
    let mut s = format!(r#"<svg viewBox="0 0 {width} {height}" width="100%" role="img" aria-label="compile time breakdown">"#);
    let mut y = 6.0;
    for (i, (label, _bi, parts)) in rows.iter().enumerate() {
        if i > 0 && i % nb == 0 {
            y += 8.0;
        }
        let _ = write!(s, r#"<text x="0" y="{:.1}">{}</text>"#, y + bar - 2.0, esc(label));
        let mut x = left;
        let total: f64 = parts.iter().sum();
        let tip = esc(&format!(
            "{label}\nfrontend {}\nbackend {}\nlink {}\nother {}\ntotal {}",
            fmt_value(parts[0], Measure::Secs),
            fmt_value(parts[1], Measure::Secs),
            fmt_value(parts[2], Measure::Secs),
            fmt_value(parts[3], Measure::Secs),
            fmt_value(total, Measure::Secs)
        ));
        let _ = write!(s, r#"<g data-tip="{tip}">"#);
        for (pi, p) in parts.iter().enumerate() {
            let w = p * scale;
            if w > 0.0 {
                let _ = write!(
                    s,
                    r#"<rect x="{x:.1}" y="{y:.1}" width="{:.1}" height="{bar}" fill="var(--s{pi})" stroke="var(--bg)" stroke-width="1"/>"#,
                    w.max(0.5)
                );
            }
            x += w;
        }
        let _ = write!(s, r#"<text class="axis" x="{:.1}" y="{:.1}">{}</text></g>"#, x + 6.0, y + bar - 2.0, fmt_value(total, Measure::Secs));
        y += bar + gap;
    }
    s.push_str("</svg><div class=\"legend\">");
    for (i, p) in PARTS.iter().enumerate() {
        let _ = write!(s, r#"<span><i class="sw" style="background:var(--s{i})"></i>{p}</span>"#);
    }
    s.push_str("</div>");
    s
}

fn metric_data(r: &Report, m: &Metric) -> Vec<Vec<Option<Summary>>> {
    r.crates.iter().map(|c| c.cells.iter().map(|cell| Summary::of(&(m.pick)(cell))).collect()).collect()
}

fn metric_table(r: &Report, m: &Metric, data: &[Vec<Option<Summary>>]) -> String {
    let llvm = r.backends.iter().position(|&b| b == Backend::Llvm);
    let mut s = String::from("<table><tr><th>crate</th>");
    for b in &r.backends {
        let _ = write!(s, "<th>{}</th>", b.name());
    }
    s.push_str("</tr>");
    for (ci, row) in data.iter().enumerate() {
        let c = &r.crates[ci];
        let _ = write!(s, "<tr><td>{}</td>", c.krate.name);
        for (bi, cell) in row.iter().enumerate() {
            let state = cell_state(&c.cells[bi], metric_kind(m.id));
            match cell {
                Some(v) => {
                    let ratio = llvm
                        .and_then(|l| row[l].as_ref())
                        .filter(|l| l.median > 0.0 && Some(bi) != llvm)
                        .map(|l| format!(" ({:.2}×)", v.median / l.median))
                        .unwrap_or_default();
                    let class = if state.is_some() {
                        " class=\"bad\""
                    } else if v.noisy() {
                        " class=\"noisy\""
                    } else {
                        ""
                    };
                    let detail = if m.unit == Measure::Bytes {
                        String::new()
                    } else {
                        format!(
                            "<br><span class=\"sub\">± {} · min {} · n={}{}</span>",
                            fmt_value(v.stddev, m.unit),
                            fmt_value(v.min, m.unit),
                            v.n,
                            if v.noisy() { " · noisy" } else { "" }
                        )
                    };
                    let st = state.map(|s| format!("<br><span class=\"sub\">{s}</span>")).unwrap_or_default();
                    let _ = write!(s, "<td{class}>{}{ratio}{detail}{st}</td>", fmt_value(v.median, m.unit));
                }
                None => {
                    let _ = write!(s, "<td class=\"bad\">{}</td>", state.unwrap_or_else(|| "no data".into()));
                }
            }
        }
        s.push_str("</tr>");
    }
    s.push_str("</table>");
    s
}

fn coverage_row(name: &str, c: &Coverage) -> String {
    format!("<tr><td>{name}</td><td>{}</td><td>{}</td><td>{:.1}%</td><td>{}</td></tr>", c.vm, c.native, c.vm_percent(), c.islands)
}

/// Coverage from ryo's warm-up builds (`RYO_STATS=1`): the crate's library, its dependencies,
/// and the test targets.
fn coverage_section(r: &Report) -> String {
    let Some(ryo) = r.backends.iter().position(|&b| b == Backend::Ryo) else { return String::new() };
    let mut s = String::from(
        "<h2 id=\"coverage\">ryo coverage (-Zryo-stats)</h2><p class=\"muted\">From ryo's warm-up build \
         (RYO_STATS=1, not timed). VM and native functions are mono items ryo compiled; native items \
         instantiated in the prebuilt LLVM std are not counted. Islands: distinct island instances.</p>\
         <table><tr><th>crate</th><th>units</th><th>VM fns</th><th>native fns</th><th>VM %</th><th>islands</th></tr>",
    );
    let mut all: Vec<&Unit> = Vec::new();
    for c in &r.crates {
        let cell = &c.cells[ryo];
        let [build, tests, ..] = cell.warmup.as_slice() else {
            let _ = write!(s, "<tr><td>{}</td><td colspan=5 class=\"bad\">no data</td></tr>", c.krate.name);
            continue;
        };
        let leaf: Vec<&Unit> = build.units.iter().filter(|u| u.primary).collect();
        let deps: Vec<&Unit> = build.units.iter().filter(|u| !u.primary).collect();
        let test: Vec<&Unit> = tests.units.iter().filter(|u| u.primary).collect();
        all.extend(build.units.iter().chain(&tests.units));
        for (what, units) in [("library", &leaf), ("dependencies", &deps), ("test targets", &test)] {
            let cov = coverage(units.iter().copied());
            let row = coverage_row(&format!("{} {what}", c.krate.name), &cov);
            let _ = write!(s, "{}", row.replacen("</td>", &format!("</td><td>{}</td>", units.len()), 1));
        }
    }
    s.push_str("</table>");
    let cov = coverage(all.iter().copied());
    let _ = write!(
        s,
        "<p>All crates (build and test build units): <b>{} VM</b>, {} native functions ({:.1}% VM), {} islands.</p>",
        cov.vm,
        cov.native,
        cov.vm_percent(),
        cov.islands
    );
    s.push_str("<details><summary>native functions by reason</summary><table><tr><th>reason</th><th>functions</th></tr>");
    for (why, n) in &cov.reasons {
        let _ = write!(s, "<tr><td>{}</td><td>{n}</td></tr>", esc(why));
    }
    s.push_str("</table></details><details><summary>island instructions by template</summary><table><tr><th>template</th><th>instructions</th></tr>");
    for (t, n) in cov.templates.iter().take(60) {
        let _ = write!(s, "<tr><td>{}</td><td>{n}</td></tr>", esc(t));
    }
    s.push_str("</table></details>");
    s
}

/// Per-unit medians (rustc wall and backend) of every crate's build and test build.
fn unit_details(r: &Report) -> String {
    let mut s = String::from(
        "<h2 id=\"units\">Per-unit compile times</h2><p class=\"muted\">Median rustc wall time / backend (codegen section) per rustc invocation; ★ marks units of the benchmarked package.</p>",
    );
    for c in &r.crates {
        let mut keys: Vec<(String, String, bool, usize)> = Vec::new();
        for cell in &c.cells {
            for (si, steps) in [&cell.build, &cell.test_build].into_iter().enumerate() {
                for u in steps.first().map_or(&[][..], |s| &s.units) {
                    let k = (u.krate.clone(), u.kind.clone(), u.primary, si);
                    if !keys.contains(&k) {
                        keys.push(k);
                    }
                }
            }
        }
        let _ = write!(s, "<details><summary>{} ({} units)</summary><table><tr><th>unit</th><th>step</th>", c.krate.name, keys.len());
        for b in &r.backends {
            let _ = write!(s, "<th>{}</th>", b.name());
        }
        s.push_str("</tr>");
        for (krate, kind, primary, si) in &keys {
            let _ = write!(
                s,
                "<tr><td>{}{krate} <span class=\"sub\">{kind}</span></td><td>{}</td>",
                if *primary { "★ " } else { "" },
                ["build", "tests"][*si]
            );
            for cell in &c.cells {
                let steps = [&cell.build, &cell.test_build][*si];
                let pick = |f: fn(&Unit) -> f64| {
                    let v: Vec<f64> = steps
                        .iter()
                        .filter_map(|st| st.units.iter().find(|u| &u.krate == krate && &u.kind == kind && u.primary == *primary))
                        .map(f)
                        .collect();
                    Summary::of(&v).map(|s| s.median)
                };
                match (pick(|u| u.wall), pick(|u| u.backend)) {
                    (Some(w), Some(b)) => {
                        let _ = write!(s, "<td>{} <span class=\"sub\">/ {}</span></td>", fmt_value(w, Measure::Secs), fmt_value(b, Measure::Secs));
                    }
                    _ => s.push_str("<td>-</td>"),
                }
            }
            s.push_str("</tr>");
        }
        s.push_str("</table></details>");
    }
    s
}

fn tests_section(r: &Report) -> String {
    let mut s = String::from("<h2 id=\"tests\">Test results and failures</h2><table><tr><th>crate</th>");
    for b in &r.backends {
        let _ = write!(s, "<th>{}</th>", b.name());
    }
    s.push_str("</tr>");
    let mut problems = String::new();
    for c in &r.crates {
        let _ = write!(s, "<tr><td>{} {}</td>", c.krate.name, c.krate.version);
        for (bi, cell) in c.cells.iter().enumerate() {
            match &cell.tests {
                Some(t) => {
                    let class = if t.failures.is_empty() { "" } else { " class=\"bad\"" };
                    let _ = write!(
                        s,
                        "<td{class}>{} passed, {} failed, {} ignored<br><span class=\"sub\">{} binaries</span></td>",
                        t.passed, t.failed, t.ignored, t.binaries
                    );
                }
                None => s.push_str("<td class=\"bad\">not run</td>"),
            }
            for e in &cell.errors {
                let _ = write!(problems, "<li><b>{} [{}]</b>: <pre>{}</pre></li>", c.krate.name, r.backends[bi].name(), esc(e));
            }
        }
        s.push_str("</tr>");
    }
    s.push_str("</table>");
    if problems.is_empty() {
        s.push_str("<p>No build, test or workload failures, and every workload printed the same output with every backend.</p>");
    } else {
        let _ = write!(s, "<h3 class=\"fail\">Failures</h3><ul>{problems}</ul>");
    }
    s
}

pub fn render(r: &Report) -> String {
    let mut s = String::from("<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>ryo crate benchmarks</title><style>");
    s.push_str(CSS);
    s.push_str("</style></head><body><div id=\"tip\"></div><h1>ryo crate benchmarks: LLVM vs Cranelift vs ryo</h1>");
    s.push_str("<table class=\"hdr\">");
    for (k, v) in &r.header {
        let _ = write!(s, "<tr><td>{}</td><td>{}</td></tr>", esc(k), esc(v));
    }
    let _ = write!(s, "<tr><td>bench time</td><td>{:.1} min</td></tr></table>", r.total_time / 60.0);
    s.push_str("<h2>Crates</h2><table><tr><th>crate</th><th>version</th><th>why</th></tr>");
    for c in &r.crates {
        let args = if c.krate.test_args.is_empty() { String::new() } else { format!(" (test binaries run with `{}`)", c.krate.test_args.join(" ")) };
        let _ = write!(s, "<tr><td>{}</td><td>{}</td><td>{}{}</td></tr>", c.krate.name, c.krate.version, esc(c.krate.why), esc(&args));
    }
    s.push_str("</table><p class=\"legend\">");
    for (i, b) in r.backends.iter().enumerate() {
        let _ = write!(s, "<span><i class=\"sw\" style=\"background:{}\"></i>{}</span>", backend_color(i), b.name());
    }
    s.push_str("</p><p class=\"muted\">Charts: each backend's median relative to LLVM's (log axis, dashed line = 1×), whiskers ± one standard deviation, absolute median as the label; hover for details. Tables: median (ratio to LLVM), ± stddev, min, n. Yellow cells are noisy (stddev &gt; 3% of median), red cells failed.</p>");
    s.push_str(&tests_section(r));
    s.push_str("<h2>Compile time breakdown</h2><p class=\"muted\">rustc time summed over all units of the library and test builds (medians): frontend = process start to codegen start, backend = codegen section, link = link section, other = the rest of the rustc process.</p>");
    s.push_str(&breakdown_chart(r));
    for m in METRICS {
        let data = metric_data(r, m);
        let _ = write!(s, "<h2 id=\"{}\">{}</h2><p class=\"muted\">{}</p>", m.id, m.title, esc(m.what));
        s.push_str(&ratio_chart(r, m, &data));
        s.push_str(&metric_table(r, m, &data));
    }
    s.push_str(&coverage_section(r));
    s.push_str(&unit_details(r));
    s.push_str("<script>");
    s.push_str(JS);
    s.push_str("</script></body></html>\n");
    s
}

/// Medians per metric (`*` marks noisy cells) and the failures.
pub fn text_summary(r: &Report) -> String {
    let mut out = String::new();
    for m in METRICS.iter().filter(|m| m.summary) {
        let data = metric_data(r, m);
        let mut lines: Vec<Vec<String>> = vec![std::iter::once("crate".to_owned()).chain(r.backends.iter().map(|b| b.name().to_owned())).collect()];
        for (ci, row) in data.iter().enumerate() {
            let mut line = vec![r.crates[ci].krate.name.to_owned()];
            for (bi, cell) in row.iter().enumerate() {
                let bad = cell_state(&r.crates[ci].cells[bi], metric_kind(m.id)).is_some();
                line.push(match cell {
                    Some(v) => format!("{}{}{}", fmt_value(v.median, m.unit), if v.noisy() { "*" } else { "" }, if bad { " !" } else { "" }),
                    None => "failed".to_owned(),
                });
            }
            lines.push(line);
        }
        let widths: Vec<usize> = (0..lines[0].len()).map(|i| lines.iter().map(|l| l[i].chars().count()).max().unwrap()).collect();
        let _ = writeln!(out, "\n{} (median; * noisy, ! failures)", m.title);
        for line in &lines {
            let mut t = String::new();
            for (i, c) in line.iter().enumerate() {
                let pad = " ".repeat(widths[i] - c.chars().count());
                if i == 0 { t.push_str(&format!("{c}{pad}")) } else { t.push_str(&format!("  {pad}{c}")) }
            }
            let _ = writeln!(out, "{}", t.trim_end());
        }
    }
    if let Some(ryo) = r.backends.iter().position(|&b| b == Backend::Ryo) {
        let all: Vec<&Unit> = r.crates.iter().flat_map(|c| c.cells[ryo].warmup.iter().take(2)).flat_map(|s| &s.units).collect();
        let cov = coverage(all.iter().copied());
        let _ =
            writeln!(out, "\nryo coverage: {} VM, {} native functions ({:.1}% VM), {} islands", cov.vm, cov.native, cov.vm_percent(), cov.islands);
    }
    for c in &r.crates {
        for (bi, cell) in c.cells.iter().enumerate() {
            for e in &cell.errors {
                let first = e.lines().take(3).collect::<Vec<_>>().join(" | ");
                let _ = writeln!(out, "FAILURE {} [{}]: {first}", c.krate.name, r.backends[bi].name());
            }
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::crates::{CRATES, CrateResult, TestOutcome};

    fn step(wall: f64) -> Step {
        let u = |name: &str, primary| Unit {
            krate: name.into(),
            kind: "lib".into(),
            primary,
            ok: true,
            wall,
            frontend: wall / 2.0,
            backend: wall / 4.0,
            link: 0.0,
            ryo: vec!["3 VM functions, 1 native functions, 2 islands, 1 native items".into()],
        };
        Step { wall: wall * 2.0, units: vec![u("dep", false), u("leaf", true)] }
    }

    #[test]
    fn report() {
        let cell = |f: f64, failed: bool| Cell {
            build: vec![step(1.0 * f), step(1.1 * f)],
            test_build: vec![step(2.0 * f)],
            warmup: vec![step(1.0), step(1.0), step(1.0)],
            test_run: vec![0.5 * f, 0.6 * f],
            workload: vec![0.1 * f],
            tests: Some(TestOutcome {
                binaries: 1,
                passed: 3,
                failed: failed as u64,
                failures: if failed { vec!["t: x".into()] } else { vec![] },
                ..TestOutcome::default()
            }),
            errors: if failed { vec!["test: t: x".into()] } else { vec![] },
            workload_size: Some(1_500_000),
            ..Cell::default()
        };
        let r = Report {
            backends: vec![Backend::Llvm, Backend::Clif, Backend::Ryo],
            crates: vec![CrateResult { krate: &CRATES[0], cells: vec![cell(1.0, false), cell(0.5, false), cell(3.0, true)] }],
            header: vec![("date".into(), "today <now>".into())],
            total_time: 60.0,
        };
        let html = render(&r);
        assert!(html.contains("today &lt;now&gt;"));
        assert!(html.contains("<svg") && html.contains("</html>"));
        assert!(html.contains("(3.00×)"), "ratio to llvm");
        assert!(html.contains("class=\"fail\""));
        assert!(!html.contains("http"), "self-contained");
        let text = text_summary(&r);
        assert!(text.contains("Build: wall time"));
        assert!(text.contains("FAILURE semver [ryo]: test: t: x"));
        // Build wall medians: 2.1 s for llvm, noisy (2.0 and 2.2).
        assert!(text.contains("2.10 s*"), "{text}");
        assert!(text.contains("ryo coverage: 12 VM, 4 native"), "{text}");
    }

    #[test]
    fn failure_kinds() {
        let cell = Cell { errors: vec!["workload: output differs".into()], ..Cell::default() };
        assert_eq!(cell_state(&cell, metric_kind("workload")).as_deref(), Some("1 workload failure(s)"));
        assert_eq!(cell_state(&cell, metric_kind("size-workload")).as_deref(), Some("1 workload failure(s)"));
        assert_eq!(cell_state(&cell, metric_kind("test-run")), None);
        assert_eq!(cell_state(&cell, metric_kind("build-wall")), None);
        let cell = Cell { build_failed: true, ..Cell::default() };
        assert_eq!(cell_state(&cell, metric_kind("build-wall")).as_deref(), Some("build failed"));
    }

    #[test]
    fn values() {
        assert_eq!(fmt_value(0.0123, Measure::Secs), "12 ms");
        assert_eq!(fmt_value(1.234, Measure::Secs), "1.23 s");
        assert_eq!(fmt_value(12.34, Measure::Secs), "12.3 s");
        assert_eq!(fmt_value(2_500_000.0, Measure::Bytes), "2.50 MB");
        assert_eq!(fmt_value(900.0, Measure::Bytes), "1 kB");
    }
}
