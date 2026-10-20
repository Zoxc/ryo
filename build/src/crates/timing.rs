//! Per-crate compile timings for `y bench crates` (design/build.md#bench-crates).
//!
//! Cargo's `-Zsection-timings --timings` makes it pass `--json=timings` to rustc, which then
//! emits `section_timing` JSON records on stderr: `codegen` starts in `start_codegen`, before
//! the backend's `codegen_crate`, and ends after `join_codegen`; `link` brackets linking.
//! Their timestamps are microseconds since the session started, which is about when the
//! process started. Cargo itself only keeps them rounded to 10 ms in its HTML report, so `y`
//! is also the `RUSTC_WRAPPER` ([`wrapper`]): it runs rustc, forwards its stderr to cargo
//! unchanged (cargo still sees every record), and writes the records, the wall time of the
//! rustc process and the backend's `RYO_STATS` summary to a file per invocation.

use std::ffi::OsString;
use std::fs;
use std::io::{BufRead, Write};
use std::path::Path;
use std::process::{ExitCode, Stdio};
use std::time::Instant;

/// Set to a directory, it makes `y` act as a `RUSTC_WRAPPER` logging into that directory.
pub const WRAPPER_VAR: &str = "RYO_Y_BENCH_WRAPPER";

/// `y` as `RUSTC_WRAPPER`: `y <rustc> <args>...`.
pub fn wrapper(log_dir: OsString) -> ExitCode {
    let mut args = std::env::args_os().skip(1);
    let Some(rustc) = args.next() else {
        eprintln!("error: {WRAPPER_VAR} is set, but no rustc was given");
        return ExitCode::FAILURE;
    };
    let args: Vec<OsString> = args.collect();
    let exit = |s: std::process::ExitStatus| ExitCode::from(s.code().unwrap_or(1).clamp(0, 255) as u8);
    let fail = |e: std::io::Error| {
        eprintln!("error: running {}: {e}", rustc.to_string_lossy());
        ExitCode::FAILURE
    };
    let name = args.iter().position(|a| a == "--crate-name").and_then(|i| args.get(i + 1)).cloned();
    // Cargo's target-info probe (`rustc - --crate-name ___ --print=...`) and other `--print`
    // queries aren't compilations.
    let probe = name.as_ref().is_some_and(|n| n == "___") || args.iter().any(|a| a.to_string_lossy().starts_with("--print"));
    let Some(name) = name.filter(|_| !probe) else {
        // `rustc -vV`, `--print` queries and the like.
        return match std::process::Command::new(&rustc).args(&args).status() {
            Ok(s) => exit(s),
            Err(e) => fail(e),
        };
    };
    let start = Instant::now();
    let mut child = match std::process::Command::new(&rustc).args(&args).stderr(Stdio::piped()).spawn() {
        Ok(c) => c,
        Err(e) => return fail(e),
    };
    let mut log = String::new();
    let stderr = std::io::stderr();
    for line in std::io::BufReader::new(child.stderr.take().unwrap()).split(b'\n') {
        let Ok(line) = line else { break };
        let text = String::from_utf8_lossy(&line);
        if let Some(rec) = parse_section(&text) {
            log.push_str(&format!("section {} {} {}\n", rec.name, rec.event, rec.timestamp));
        } else if let Some(rest) = text.strip_prefix("ryo: ") {
            // The backend's `RYO_STATS` output: keep the summary, not the per-function lines.
            if !rest.starts_with("vm fn ") && !(rest.starts_with("native ") && !rest.starts_with("native reason: ")) {
                log.push_str(&format!("ryo {rest}\n"));
            }
            continue;
        }
        let mut e = stderr.lock();
        let _ = e.write_all(&line);
        let _ = e.write_all(b"\n");
    }
    let status = match child.wait() {
        Ok(s) => s,
        Err(e) => return fail(e),
    };
    let wall = start.elapsed().as_micros();
    let primary = std::env::var_os("CARGO_PRIMARY_PACKAGE").is_some();
    let test = args.iter().any(|a| a == "--test");
    let kind = args.iter().position(|a| a == "--crate-type").and_then(|i| args.get(i + 1));
    let kind = kind.map_or(if test { "test".into() } else { "bin".into() }, |k| k.to_string_lossy().into_owned());
    let name = name.to_string_lossy();
    let head = format!("crate {name}\nkind {kind}\nprimary {}\nwall {wall}\nstatus {}\n", primary as u8, status.success() as u8);
    let file = Path::new(&log_dir).join(format!("{name}-{}.txt", std::process::id()));
    let _ = fs::create_dir_all(&log_dir);
    if let Err(e) = fs::write(&file, head + &log) {
        eprintln!("warning: writing {}: {e}", file.display());
    }
    exit(status)
}

/// One `section_timing` record of rustc's `--json=timings`.
#[derive(Debug, PartialEq)]
pub struct Section<'a> {
    pub name: &'a str,
    pub event: &'a str,
    pub timestamp: u64,
}

/// Parses `{"$message_type":"section_timing","name":"codegen","event":"start","timestamp":N}`
/// (rustc_errors/src/json.rs). A minimal scan, since `y` has no dependencies.
pub fn parse_section(line: &str) -> Option<Section<'_>> {
    let line = line.trim();
    if !line.starts_with('{') || !line.contains(r#""$message_type":"section_timing""#) {
        return None;
    }
    let string = |key: &str| {
        let pat = format!("\"{key}\":\"");
        let rest = &line[line.find(&pat)? + pat.len()..];
        Some(&rest[..rest.find('"')?])
    };
    let pat = "\"timestamp\":";
    let rest = &line[line.find(pat)? + pat.len()..];
    let end = rest.find(|c: char| !c.is_ascii_digit()).unwrap_or(rest.len());
    Some(Section { name: string("name")?, event: string("event")?, timestamp: rest[..end].parse().ok()? })
}

/// One rustc invocation, in seconds.
#[derive(Clone, Debug, PartialEq)]
pub struct Unit {
    pub krate: String,
    pub kind: String,
    /// A unit of the benchmarked package itself (cargo's `CARGO_PRIMARY_PACKAGE`), rather than
    /// a dependency.
    pub primary: bool,
    pub ok: bool,
    /// Wall time of the rustc process, as the wrapper measured it.
    pub wall: f64,
    /// Process start to `codegen` start, as cargo's `-Zsection-timings` counts `frontend`.
    pub frontend: f64,
    /// The `codegen` section: the codegen backend.
    pub backend: f64,
    /// The `link` section.
    pub link: f64,
    /// `RYO_STATS` summary lines (without the `ryo: ` prefix).
    pub ryo: Vec<String>,
}

impl Unit {
    /// Everything else: process startup and exit, and work between the sections.
    pub fn other(&self) -> f64 {
        (self.wall - self.frontend - self.backend - self.link).max(0.0)
    }
}

/// Parses a log file written by [`wrapper`].
pub fn parse_unit(text: &str) -> Option<Unit> {
    let mut u = Unit {
        krate: String::new(),
        kind: String::new(),
        primary: false,
        ok: false,
        wall: 0.0,
        frontend: 0.0,
        backend: 0.0,
        link: 0.0,
        ryo: Vec::new(),
    };
    let mut wall = None;
    let (mut cg_start, mut cg_end, mut link_start, mut link_end) = (None, None, None, None);
    let us = |s: &str| s.parse::<u64>().ok();
    for line in text.lines() {
        let (key, rest) = line.split_once(' ').unwrap_or((line, ""));
        match key {
            "crate" => u.krate = rest.to_owned(),
            "kind" => u.kind = rest.to_owned(),
            "primary" => u.primary = rest == "1",
            "status" => u.ok = rest == "1",
            "wall" => wall = us(rest),
            "ryo" => u.ryo.push(rest.to_owned()),
            "section" => {
                let f: Vec<&str> = rest.split(' ').collect();
                let [name, event, ts] = f[..] else { continue };
                let slot = match (name, event) {
                    ("codegen", "start") => &mut cg_start,
                    ("codegen", "end") => &mut cg_end,
                    ("link", "start") => &mut link_start,
                    ("link", "end") => &mut link_end,
                    _ => continue,
                };
                *slot = us(ts);
            }
            _ => {}
        }
    }
    let secs = |us: u64| us as f64 * 1e-6;
    u.wall = secs(wall?);
    u.frontend = cg_start.map_or(u.wall, secs).min(u.wall);
    if let (Some(s), Some(e)) = (cg_start, cg_end) {
        u.backend = secs(e.saturating_sub(s));
    }
    if let (Some(s), Some(e)) = (link_start, link_end) {
        u.link = secs(e.saturating_sub(s));
    }
    if u.krate.is_empty() { None } else { Some(u) }
}

/// Reads every unit logged in `dir`, sorted by crate name.
pub fn read_units(dir: &Path) -> Result<Vec<Unit>, String> {
    let mut units = Vec::new();
    let Ok(entries) = fs::read_dir(dir) else { return Ok(units) };
    for e in entries.flatten() {
        let text = fs::read_to_string(e.path()).map_err(|err| format!("{}: {err}", e.path().display()))?;
        units.push(parse_unit(&text).ok_or_else(|| format!("{}: bad timing log", e.path().display()))?);
    }
    units.sort_by(|a, b| (&a.krate, &a.kind).cmp(&(&b.krate, &b.kind)));
    Ok(units)
}

/// Sums over a set of units, in seconds.
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct Totals {
    pub wall: f64,
    pub frontend: f64,
    pub backend: f64,
    pub link: f64,
    pub other: f64,
    pub units: usize,
}

pub fn totals<'a>(units: impl IntoIterator<Item = &'a Unit>) -> Totals {
    let mut t = Totals::default();
    for u in units {
        t.wall += u.wall;
        t.frontend += u.frontend;
        t.backend += u.backend;
        t.link += u.link;
        t.other += u.other();
        t.units += 1;
    }
    t
}

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
    let mut c = Coverage::default();
    let add = |list: &mut Vec<(String, u64)>, key: &str, n: u64| match list.iter_mut().find(|(k, _)| k == key) {
        Some(e) => e.1 += n,
        None => list.push((key.to_owned(), n)),
    };
    for u in units {
        for line in &u.ryo {
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
    }
    c.templates.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    c.reasons.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    c
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn section_records() {
        let l = r#"{"$message_type":"section_timing","name":"codegen","event":"start","timestamp":26345}"#;
        assert_eq!(parse_section(l), Some(Section { name: "codegen", event: "start", timestamp: 26345 }));
        let l = r#"{"$message_type":"section_timing","name":"link","event":"end","timestamp":7}  "#;
        assert_eq!(parse_section(l), Some(Section { name: "link", event: "end", timestamp: 7 }));
        assert_eq!(parse_section(r#"{"$message_type":"diagnostic","message":"x"}"#), None);
        assert_eq!(parse_section("warning: unused variable"), None);
        assert_eq!(parse_section(r#"{"$message_type":"section_timing","name":"link"}"#), None);
    }

    #[test]
    fn unit_log() {
        let log = "crate foo\nkind lib\nprimary 1\nwall 1000000\nstatus 1\n\
                   section codegen start 400000\nsection codegen end 700000\n\
                   section link start 750000\nsection link end 850000\n\
                   ryo 10 VM functions, 30 native functions, 5 islands, 40 native items\n\
                   ryo island call: 7 in 3 functions\nryo native reason: 30 not instantiated\n";
        let u = parse_unit(log).unwrap();
        assert_eq!((u.krate.as_str(), u.kind.as_str(), u.primary, u.ok), ("foo", "lib", true, true));
        let close = |a: f64, b: f64| (a - b).abs() < 1e-9;
        assert!(close(u.wall, 1.0) && close(u.frontend, 0.4) && close(u.backend, 0.3) && close(u.link, 0.1));
        assert!(close(u.other(), 0.2));
        let c = coverage([&u, &u]);
        assert_eq!((c.vm, c.native, c.islands), (20, 60, 10));
        assert_eq!(c.templates, vec![("call".to_owned(), 14)]);
        assert_eq!(c.reasons, vec![("not instantiated".to_owned(), 60)]);
        assert!(close(c.vm_percent(), 25.0));
        let t = totals([&u, &u]);
        assert!(close(t.backend, 0.6) && t.units == 2);

        // No codegen section (e.g. a failed build): all of it is frontend.
        let u = parse_unit("crate bar\nkind bin\nprimary 0\nwall 5000\nstatus 0\n").unwrap();
        assert!(close(u.frontend, 0.005) && u.backend == 0.0 && !u.ok && !u.primary);
        assert_eq!(parse_unit("kind lib\nwall 5\n"), None);
        assert_eq!(parse_unit("crate x\n"), None);
    }
}
