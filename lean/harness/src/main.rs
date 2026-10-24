//! Co-simulation of the Lean x86 model against the CPU (lean/docs/x86.md §B.3).
//!
//! Generates random items and inline runs with random initial states (seeded, reproducible),
//! sends them in batches to one `ryo-lean exec-item` process, which answers with each item's
//! linked bytes and the state `Item.exec` predicts; runs those bytes on the CPU from the same
//! state (`cpu.rs`) and compares all GPRs, the flags Lean defines, `xmm0`–`xmm15`, the data
//! region and where control went.
//!
//!   cargo run --release -- [--cases N] [--seed S] [--lean path/to/ryo-lean] [--show K] [-v]

mod cases;
mod cpu;
mod json;

use std::collections::BTreeMap;
use std::fmt::Write as _;
use std::io::{BufRead, BufReader, Write};
use std::process::{Command, Stdio};

use json::Json;

struct Opts {
    cases: usize,
    seed: u64,
    lean: String,
    show: usize,
    verbose: bool,
    batch: usize,
}

fn opts() -> Opts {
    let mut o = Opts {
        cases: 20_000,
        seed: 1,
        lean: concat!(env!("CARGO_MANIFEST_DIR"), "/../.lake/build/bin/ryo-lean").into(),
        show: 10,
        verbose: false,
        batch: 2000,
    };
    let args: Vec<String> = std::env::args().skip(1).collect();
    let mut i = 0;
    while i < args.len() {
        let val = |i: usize| args.get(i + 1).unwrap_or_else(|| panic!("{} needs a value", args[i])).clone();
        match args[i].as_str() {
            "--cases" => o.cases = val(i).parse().expect("--cases"),
            "--seed" => o.seed = val(i).parse().expect("--seed"),
            "--lean" => o.lean = val(i),
            "--show" => o.show = val(i).parse().expect("--show"),
            "--batch" => o.batch = val(i).parse().expect("--batch"),
            "-v" | "--verbose" => {
                o.verbose = true;
                i += 1;
                continue;
            }
            a => panic!("unknown argument {a}; usage: [--cases N] [--seed S] [--lean PATH] [--show K] [--batch B] [-v]"),
        }
        i += 2;
    }
    o
}

fn hex(bs: &[u8]) -> String {
    bs.iter().fold(String::new(), |mut s, b| {
        let _ = write!(s, "{b:02x}");
        s
    })
}

fn unhex(s: &str) -> Vec<u8> {
    (0..s.len() / 2).map(|i| u8::from_str_radix(&s[2 * i..2 * i + 2], 16).expect("hex")).collect()
}

const FLAGS: [(&str, u32); 4] = [("cf", 0), ("zf", 6), ("sf", 7), ("of", 11)];

fn request(c: &cases::Case, func: u64, data: u64) -> String {
    let refs: Vec<String> = c.refs.iter().map(|(r, a)| format!("[{r},{a}]")).collect();
    let regs: Vec<String> = c.regs.iter().map(|r| r.to_string()).collect();
    let xmm: Vec<String> = c.xmm.iter().map(|r| r.to_string()).collect();
    let flags: Vec<String> = FLAGS.iter().map(|(n, b)| format!(r#""{n}":{}"#, c.rflags >> b & 1 == 1)).collect();
    format!(
        r#"{{"items":[{}],"pos":{},"base":{func},"refs":[{}],"state":{{"regs":[{}],"rip":{},"flags":{{{}}},"xmm":[{}],"mem":[[{data},"{}"]]}}}}"#,
        c.items.join(","),
        cpu::POS,
        refs.join(","),
        regs.join(","),
        func + cpu::POS as u64,
        flags.join(","),
        xmm.join(","),
        hex(&c.mem)
    )
}

#[derive(Default)]
struct Stats {
    cases: usize,
    mismatches: usize,
    skipped: usize,
}

/// Compares Lean's prediction with the CPU's outcome: the differences.
fn compare(state: &Json, out: &cpu::Outcome) -> Result<Vec<String>, String> {
    let mut d = Vec::new();
    let regs = state.get("regs").and_then(Json::arr).ok_or("no regs")?;
    for (i, r) in regs.iter().enumerate() {
        let want = r.u64().ok_or("bad reg")?;
        if want != out.regs[i] {
            d.push(format!("r{i}: lean {want:#x}, cpu {:#x}", out.regs[i]));
        }
    }
    let rip = state.get("rip").and_then(Json::u64).ok_or("no rip")?;
    if rip != out.rip {
        d.push(format!("rip: lean {rip:#x}, cpu {:#x}", out.rip));
    }
    let flags = state.get("flags").ok_or("no flags")?;
    for (n, b) in FLAGS {
        if let Some(want) = flags.get(n).and_then(Json::opt_bool) {
            let got = out.rflags >> b & 1 == 1;
            if want != got {
                d.push(format!("{n}: lean {want}, cpu {got}"));
            }
        }
    }
    let xmm = state.get("xmm").and_then(Json::arr).ok_or("no xmm")?;
    for (i, x) in xmm.iter().enumerate() {
        let want = x.u128().ok_or("bad xmm")?;
        if want != out.xmm[i] {
            d.push(format!("xmm{i}: lean {want:#x}, cpu {:#x}", out.xmm[i]));
        }
    }
    let mem = state.get("mem").and_then(Json::arr).and_then(|m| m.first()).and_then(Json::arr).ok_or("no mem")?;
    let want = unhex(mem.get(1).and_then(Json::str).ok_or("bad mem")?);
    for (i, (w, g)) in want.iter().zip(&out.mem).enumerate() {
        if w != g {
            d.push(format!("data+{i:#x}: lean {w:#04x}, cpu {g:#04x}"));
        }
    }
    Ok(d)
}

fn main() {
    let o = opts();
    let mut cpu = cpu::Cpu::new();
    let func = cpu.addr(cpu::FUNC);
    let data = cpu.addr(cpu::DATA);
    let mut child = Command::new(&o.lean)
        .arg("exec-item")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .unwrap_or_else(|e| panic!("cannot run {} ({e}); run `lake build` in lean/ first", o.lean));
    let mut stdin = Some(child.stdin.take().unwrap());
    let mut stdout = BufReader::new(child.stdout.take().unwrap());
    let mut rng = cases::Rng::new(o.seed);
    let mut stats: BTreeMap<String, Stats> = BTreeMap::new();
    let mut shown = 0;
    let mut errors = 0;
    let mut done = 0;
    while done < o.cases {
        let n = o.batch.min(o.cases - done);
        // Half single straight-line items, a quarter other items, a quarter inline runs.
        let cases: Vec<cases::Case> = (0..n).map(|i| cases::case(&mut rng, func, data, [0, 0, 1, 2][(done + i) % 4])).collect();
        let reqs: Vec<String> = cases.iter().map(|c| request(c, func, data)).collect();
        let mut w = stdin.take().unwrap();
        let writer = std::thread::spawn(move || {
            for r in &reqs {
                w.write_all(r.as_bytes()).unwrap();
                w.write_all(b"\n").unwrap();
            }
            w.flush().unwrap();
            w
        });
        for c in &cases {
            let mut line = String::new();
            stdout.read_line(&mut line).expect("read from ryo-lean");
            if line.is_empty() {
                panic!("ryo-lean exited");
            }
            let resp = json::parse(&line).unwrap_or_else(|e| panic!("bad response {e}: {line}"));
            let st = stats.entry(c.form.clone()).or_default();
            st.cases += 1;
            if let Some(e) = resp.get("error") {
                errors += 1;
                eprintln!("ryo-lean error {e:?} on {}", request(c, func, data));
                continue;
            }
            let bytes = unhex(resp.get("bytes").and_then(Json::str).expect("bytes"));
            if let Some(f) = resp.get("fault") {
                // Only inline runs may fault: a flag `imul` left undefined read by `setcc`.
                if c.form.starts_with("run") && format!("{f:?}").contains("undefinedFlag") {
                    st.skipped += 1;
                } else {
                    st.mismatches += 1;
                    eprintln!("unexpected fault {f:?} on {}", request(c, func, data));
                }
                continue;
            }
            if o.verbose {
                eprintln!("{} {}", c.form, c.items.join(" "));
            }
            let out = match cpu.run(&bytes, &c.pads, c.regs, c.rflags, c.xmm, &c.mem) {
                Ok(out) => out,
                Err(e) => {
                    if o.verbose {
                        eprintln!("skipped: {e}");
                    }
                    st.skipped += 1;
                    continue;
                }
            };
            let diffs = compare(resp.get("state").expect("state"), &out).unwrap_or_else(|e| panic!("bad state {e}: {line}"));
            if !diffs.is_empty() {
                st.mismatches += 1;
                if shown < o.show {
                    shown += 1;
                    println!(
                        "MISMATCH {}: {}\n  bytes {}\n  {}\n  request {}",
                        c.form,
                        c.items.join(" "),
                        hex(&bytes),
                        diffs.join("\n  "),
                        request(c, func, data)
                    );
                }
            }
        }
        stdin = Some(writer.join().unwrap());
        done += n;
    }
    drop(stdin);
    let _ = child.wait();
    let mut total = Stats::default();
    println!("{:<22} {:>8} {:>8} {:>10}", "form", "cases", "skipped", "mismatches");
    for (f, s) in &stats {
        println!("{f:<22} {:>8} {:>8} {:>10}", s.cases, s.skipped, s.mismatches);
        total.cases += s.cases;
        total.skipped += s.skipped;
        total.mismatches += s.mismatches;
    }
    println!("{:<22} {:>8} {:>8} {:>10}", "total", total.cases, total.skipped, total.mismatches);
    println!("seed {}, {} forms, {} ryo-lean errors", o.seed, stats.len(), errors);
    if total.mismatches > 0 || errors > 0 {
        std::process::exit(1);
    }
}
