//! The JIT's statistics (`RYO_JIT_STATS`, design/jit.md#statistics): counters that only the
//! JIT thread writes, so a bump is a `Relaxed` load and store, no read-modify-write; other
//! threads (the exit report, tests) read them with `Relaxed` loads, without a lock. A record's
//! counters are stored before its state leaves `Queued` (`JitRecord::publish`'s or
//! `JitRecord::fail`'s `SeqCst` store), so a `RYO_JIT_SYNC` waiter sees them; not the timing
//! counters (`timed`, `compile_ns`, `compile_max_ns`) and `largest_batch`, stored after the
//! compile or batch, so a snapshot then can be one record behind on those.
//!
//! Read at exit, while the JIT thread may be mid-compile, the counters are a snapshot of
//! independent values: the summary doesn't print sums that must balance.

use core::sync::atomic::AtomicU64;
use core::sync::atomic::Ordering::Relaxed;
use std::io::{self, Write};
use std::sync::OnceLock;
use std::time::{Duration, Instant};

/// Why the JIT thread failed a record. The reasons but `Other` are counted on their own.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Fail {
    /// The image has no `rust_eh_personality` slot.
    NoPersonality,
    /// The compile panicked.
    Panicked,
    /// The region filled up twice ([`crate::install`]'s retry).
    RegionFull,
    /// The SSA pipeline's checkers found a bug.
    SsaCheck,
    /// Anything else, for this reason.
    Other(&'static str),
}

const FAIL_SLOTS: usize = 5;

impl Fail {
    /// The reasons counted on their own, in slot order; "other" is the last slot.
    const COUNTED: [Fail; FAIL_SLOTS - 1] = [Fail::NoPersonality, Fail::Panicked, Fail::RegionFull, Fail::SsaCheck];

    /// Its slot in [`Stats::failed`].
    const fn slot(self) -> usize {
        match self {
            Fail::NoPersonality => 0,
            Fail::Panicked => 1,
            Fail::RegionFull => 2,
            Fail::SsaCheck => 3,
            Fail::Other(_) => FAIL_SLOTS - 1,
        }
    }

    /// Its name in the summary.
    fn label(self) -> &'static str {
        match self {
            Fail::NoPersonality => "no personality slot",
            Fail::Panicked => "panicked",
            Fail::RegionFull => "region full",
            Fail::SsaCheck => "ssa check failed",
            Fail::Other(_) => "other",
        }
    }

    /// The reason, as `RYO_JIT_LOG` prints it.
    pub(crate) fn message(self) -> &'static str {
        match self {
            Fail::NoPersonality => "no personality slot",
            Fail::Panicked => "panicked",
            Fail::RegionFull => "region full",
            Fail::SsaCheck => "the SSA pipeline's checkers failed",
            Fail::Other(why) => why,
        }
    }
}

impl From<&'static str> for Fail {
    fn from(why: &'static str) -> Fail {
        Fail::Other(why)
    }
}

macro_rules! stats {
    ($($(#[$doc:meta])* $f:ident,)*) => {
        /// The counters.
        pub(crate) struct Stats {
            $($(#[$doc])* pub(crate) $f: AtomicU64,)*
            /// Failed records, by reason ([`Fail::slot`]).
            failed: [AtomicU64; FAIL_SLOTS],
        }

        /// A copy of [`Stats`], each counter loaded on its own.
        #[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
        pub struct Snapshot {
            $($(#[$doc])* pub $f: u64,)*
            /// Failed records, by reason ([`Fail::slot`]).
            pub failed: [u64; FAIL_SLOTS],
        }

        impl Stats {
            const fn new() -> Stats {
                Stats { $($f: AtomicU64::new(0),)* failed: [const { AtomicU64::new(0) }; FAIL_SLOTS] }
            }

            /// Every counter, each with a `Relaxed` load.
            pub(crate) fn load_all(&self) -> Snapshot {
                Snapshot { $($f: self.$f.load(Relaxed),)* failed: core::array::from_fn(|i| self.failed[i].load(Relaxed)) }
            }
        }
    };
}

stats! {
    /// Records taken from the queue.
    queued,
    /// Batches taken, and the largest.
    batches,
    largest_batch,
    /// Records published, by tier, and their code's bytes by tier.
    compiled,
    ssa,
    reencode,
    code_ssa,
    code_reencode,
    /// Why functions were re-encoded: the SSA pipeline doesn't handle them, they were over
    /// `RYO_JIT_SSA_LIMIT`, `RYO_JIT_OPT=reencode`.
    ssa_unsupported,
    ssa_limit,
    opt_reencode,
    /// Calls the SSA pipeline made direct, and calls it inlined.
    devirt,
    inlined,
    /// Code regions mapped, and compiles retried in a new one.
    regions,
    region_retries,
    /// Compiles timed (`JitSettings::count`), their total and longest time in nanoseconds.
    timed,
    compile_ns,
    compile_max_ns,
}

/// The JIT's counters.
pub(crate) static STATS: Stats = Stats::new();

/// When the JIT started (its thread was spawned).
pub(crate) static STARTED_AT: OnceLock<Instant> = OnceLock::new();

/// Adds `n` to `c`. Only the JIT thread writes counters, so no update is lost.
pub(crate) fn add(c: &AtomicU64, n: u64) {
    c.store(c.load(Relaxed).wrapping_add(n), Relaxed);
}

/// Raises `c` to `n`.
pub(crate) fn max(c: &AtomicU64, n: u64) {
    if n > c.load(Relaxed) {
        c.store(n, Relaxed);
    }
}

impl Stats {
    /// Counts a record that failed for `why`.
    pub(crate) fn fail(&self, why: Fail) {
        add(&self.failed[why.slot()], 1);
    }
}

impl Snapshot {
    pub fn failed_total(&self) -> u64 {
        self.failed.iter().sum()
    }

    /// Records the SSA pipeline's checkers failed.
    pub fn ssa_check_failed(&self) -> u64 {
        self.failed[Fail::SsaCheck.slot()]
    }
}

fn mib(bytes: u64) -> f64 {
    bytes as f64 / (1024.0 * 1024.0)
}

/// The level 2 progress line, `since` the JIT started.
pub(crate) fn progress(s: &Snapshot, since: Duration, w: &mut impl Write) -> io::Result<()> {
    writeln!(
        w,
        "[ryo] jit stats: +{}s compiled {} (ssa {}, reencode {}), failed {}, code {:.1} MiB",
        since.as_secs(),
        s.compiled,
        s.ssa,
        s.reencode,
        s.failed_total(),
        mib(s.code_ssa + s.code_reencode)
    )
}

/// The exit summary of process `pid`, `since` the JIT started.
pub(crate) fn summary(s: &Snapshot, pid: u32, since: Duration, w: &mut impl Write) -> io::Result<()> {
    const P: &str = "[ryo] jit stats:";
    writeln!(w, "{P} summary, pid {pid}, {:.2}s since the JIT started", since.as_secs_f64())?;
    writeln!(w, "{P}   queued    {:>4} records in {} batches (largest {})", s.queued, s.batches, s.largest_batch)?;
    writeln!(
        w,
        "{P}   compiled  {:>4}: ssa {}, reencode {} (ssa unsupported {}, ssa-limit {}, RYO_JIT_OPT=reencode {})",
        s.compiled, s.ssa, s.reencode, s.ssa_unsupported, s.ssa_limit, s.opt_reencode
    )?;
    write!(w, "{P}   failed    {:>4}:", s.failed_total())?;
    for f in Fail::COUNTED {
        write!(w, " {} {},", f.label(), s.failed[f.slot()])?;
    }
    writeln!(w, " {} {}", Fail::Other("").label(), s.failed[Fail::Other("").slot()])?;
    let in_flight = s.queued.saturating_sub(s.compiled).saturating_sub(s.failed_total());
    writeln!(w, "{P}   in flight {in_flight:>4} (taken, not yet reported; approximate at exit)")?;
    writeln!(w, "{P}   ssa: devirt {}, inlined {} calls", s.devirt, s.inlined)?;
    writeln!(
        w,
        "{P}   code   {:.1} MiB (ssa {:.1}, reencode {:.1}) in {} regions; region-full retries {}",
        mib(s.code_ssa + s.code_reencode),
        mib(s.code_ssa),
        mib(s.code_reencode),
        s.regions,
        s.region_retries
    )?;
    let ms = |ns: u64| ns as f64 / 1e6;
    writeln!(
        w,
        "{P}   time   compile {:.2}s (mean {:.1}ms, max {:.0}ms)",
        s.compile_ns as f64 / 1e9,
        ms(s.compile_ns.checked_div(s.timed).unwrap_or(0)),
        ms(s.compile_max_ns)
    )
}

/// Formats the counters and the time since the JIT started with `f` into an `N`-byte buffer
/// on the stack, and writes it to stderr with one `write`. It only loads the counters: no
/// lock, no allocation, no waiting for the JIT thread.
fn write_snapshot<const N: usize>(f: impl FnOnce(&Snapshot, Duration, &mut io::Cursor<[u8; N]>) -> io::Result<()>) {
    let since = STARTED_AT.get().map_or(Duration::ZERO, |t| t.elapsed());
    let mut buf = io::Cursor::new([0u8; N]);
    let _ = f(&STATS.load_all(), since, &mut buf);
    let n = buf.position() as usize;
    crate::sys::write_stderr(&buf.get_ref()[..n]);
}

/// `RYO_JIT_STATS=2`'s progress line.
#[cold]
pub(crate) fn write_progress() {
    write_snapshot::<256>(|s, since, w| progress(s, since, w));
}

/// The exit report (`ryo_jit_start` returns it to the runtime, whose `atexit` handler calls
/// it): the summary.
pub(crate) extern "C" fn report() {
    write_snapshot::<2048>(|s, since, w| summary(s, std::process::id(), since, w));
}

#[cfg(test)]
mod tests {
    use super::*;

    fn text(f: impl FnOnce(&mut Vec<u8>) -> io::Result<()>) -> String {
        let mut v = Vec::new();
        f(&mut v).unwrap();
        String::from_utf8(v).unwrap()
    }

    #[test]
    fn summary_text() {
        let mut failed = [0; FAIL_SLOTS];
        failed[0] = 9;
        failed[1] = 1;
        failed[FAIL_SLOTS - 1] = 2;
        let s = Snapshot {
            queued: 1203,
            batches: 97,
            largest_batch: 143,
            compiled: 1171,
            ssa: 1102,
            reencode: 69,
            code_ssa: 2202010,
            code_reencode: 209715,
            ssa_unsupported: 61,
            opt_reencode: 8,
            devirt: 5,
            inlined: 40,
            regions: 3,
            region_retries: 2,
            timed: 1183,
            compile_ns: 1_210_000_000,
            compile_max_ns: 38_000_000,
            failed,
            ..Snapshot::default()
        };
        assert_eq!(
            text(|w| summary(&s, 41213, Duration::from_millis(2840), w)),
            "\
[ryo] jit stats: summary, pid 41213, 2.84s since the JIT started
[ryo] jit stats:   queued    1203 records in 97 batches (largest 143)
[ryo] jit stats:   compiled  1171: ssa 1102, reencode 69 (ssa unsupported 61, ssa-limit 0, RYO_JIT_OPT=reencode 8)
[ryo] jit stats:   failed      12: no personality slot 9, panicked 1, region full 0, ssa check failed 0, other 2
[ryo] jit stats:   in flight   20 (taken, not yet reported; approximate at exit)
[ryo] jit stats:   ssa: devirt 5, inlined 40 calls
[ryo] jit stats:   code   2.3 MiB (ssa 2.1, reencode 0.2) in 3 regions; region-full retries 2
[ryo] jit stats:   time   compile 1.21s (mean 1.0ms, max 38ms)
"
        );
        assert_eq!(
            text(|w| progress(&s, Duration::from_secs(60), w)),
            "[ryo] jit stats: +60s compiled 1171 (ssa 1102, reencode 69), failed 12, code 2.3 MiB\n"
        );
        // The summary fits the report's buffer.
        assert!(text(|w| summary(&s, u32::MAX, Duration::from_secs(1 << 40), w)).len() < 1024);
    }

    #[test]
    fn inconsistent_read() {
        // Read mid-compile: more reported than taken.
        let s = Snapshot { queued: 3, compiled: 3, failed: [1, 0, 0, 0, 0], ..Snapshot::default() };
        assert!(text(|w| summary(&s, 1, Duration::ZERO, w)).contains("in flight    0 "));
    }

    #[test]
    fn failure_reasons() {
        let st = Stats::new();
        for why in [Fail::Panicked, Fail::Panicked, Fail::RegionFull, Fail::SsaCheck, Fail::Other("no such function")] {
            st.fail(why);
        }
        assert_eq!(st.load_all().failed, [0, 2, 1, 1, 1]);
    }
}
