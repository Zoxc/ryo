#!/usr/bin/env python3
"""Compares any number of ryo builds on the `bench/` programs (compile time and run
time) and, with `--crates` (or only, with `--only-crates`), on `y bench crates`.

A build is a checkout with a built `dist/` (`./y.sh build`). Builds are given as
`--build NAME=PATH` or `--build PATH` (name: the directory name), repeated; `--worktree REV`
adds a build of commit REV from a `git worktree` at `target/compare/<REV>` in this repo
(created if missing, reused otherwise, and `./y.sh build` run there if it has no `dist/`) --
the easy way to compare commits. With no builds given, the default is `--worktree main
--build .`. The first build is the baseline: every other build gets a ratio column (its
median / the baseline's median).

    scripts/compare-branches.py [--build [NAME=]PATH]... [--worktree REV]...
                                [--samples N] [--warmup N] [--max-time S]
                                [--metric cpu|wall|cachegrind] [--no-cache-sim]
                                [--pin CPU] [--seed N] [--programs a,b] [--flags "..."]
                                [--crates [a,b|all|default]] [--only-crates]

Examples:
    scripts/compare-branches.py --programs fib --samples 4
    scripts/compare-branches.py --worktree main --build head=. --pin 3
    scripts/compare-branches.py --worktree HEAD~1 --worktree HEAD --metric wall
    scripts/compare-branches.py --worktree HEAD~1 --build head=. --metric cachegrind

Programs: each is compiled with each build's `dist/bin/rustc-ryo` (`-Ccodegen-units=1
-Zthreads=1`, as `y bench`); every build must print the same output. Samples are taken in
rounds, one sample per build per round, the build order shuffled each round (`--seed`) so
drift affects all alike; the first `--warmup` rounds are dropped, and a measurement stops
early once it has 3 samples and `--max-time` seconds are spent. Times are the child's CPU
time (user+sys, `--metric cpu`, the default; less sensitive to scheduling noise) or wall
time; `--pin CPU` runs timed commands under `taskset -c CPU`. Reported: median, min and
MAD (median absolute deviation).

`--metric cachegrind` counts instead: every command runs under `valgrind --tool=cachegrind`
with its cache simulation (children traced, their counts summed). Compiles report millions
of instructions executed; runs also report instruction-cache (I1) misses, data reads and
writes, and first-level (D1) and last-level (LL) data cache misses, each in its own table.
Runs get `RYO_JIT_SYNC=1` and `RYO_JIT_OPT=ssa` unless they are set: without a synchronous
JIT the counts depend on when the JIT thread finishes. Set `RYO_JIT=off` to count AOT code.
The counts don't depend on the machine's load, so one sample is taken (`--samples 1
--warmup 0`) and small differences are real. Valgrind's caches are a simple model, not the
machine's, so take the misses as a guide; and nothing sees branch mispredictions or
dependency chains, so a change can cut instructions without getting faster. Runs are about
100 times slower than native; `--no-cache-sim` drops the simulation and reports only
instructions, about twice as fast. Not for `--crates`.

Crates: each build's own `./y.sh bench crates --backends ryo`, crate by crate, builds in
shuffled order, with `--samples` build and run samples; their summary tables (medians) are
put side by side.

The status line ends with the overall progress of the whole run, with an ETA. A crate counts
as `2 * --samples` steps, as a program's measurements do; its steps take longer, so the ETA is
rough once crates are included.
"""

import argparse
import os
import random
import shutil
import statistics
import subprocess
import sys
import tempfile
import threading
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


# --- progress ---------------------------------------------------------------------------

class Progress:
    """One live status line on stderr (`\\r` on a TTY, plain lines otherwise)."""

    def __init__(self):
        self.tty = sys.stderr.isatty()
        self.lock = threading.Lock()
        self.width = 0

    def show(self, text):
        with self.lock:
            if self.tty:
                cols = shutil.get_terminal_size((100, 20)).columns - 1
                text = text[:cols]
                sys.stderr.write("\r" + text + " " * max(0, self.width - len(text)))
                self.width = len(text)
            else:
                sys.stderr.write(text + "\n")
            sys.stderr.flush()

    def log(self, text):
        """A permanent line (the status line is redrawn by the next `show`)."""
        with self.lock:
            if self.tty and self.width:
                sys.stderr.write("\r" + " " * self.width + "\r")
                self.width = 0
            sys.stderr.write(text + "\n")
            sys.stderr.flush()


PROGRESS = Progress()


def bar(frac, n=10):
    k = max(0, min(n, round(frac * n)))
    return "█" * k + "░" * (n - k)


def fmt_secs(s):
    s = int(s)
    return f"{s // 60}m{s % 60:02d}s" if s >= 60 else f"{s}s"


class Eta:
    """Overall progress over `total` steps, with an ETA from the average step time."""

    def __init__(self, total):
        self.total, self.done, self.start = max(1, total), 0, time.monotonic()

    def step(self, n=1):
        self.done = min(self.total, self.done + n)

    def text(self):
        frac = self.done / self.total
        el = time.monotonic() - self.start
        eta = f" eta {fmt_secs(el / self.done * (self.total - self.done))}" if self.done else ""
        return f"| overall {bar(frac, 20)} {frac * 100:3.0f}%{eta}"


# --- builds -----------------------------------------------------------------------------

def git(cwd, *a, check=True):
    r = subprocess.run(["git", *a], cwd=cwd, capture_output=True, text=True)
    if check and r.returncode != 0:
        sys.exit(f"git {' '.join(a)} (in {cwd}) failed:\n{r.stderr}")
    return r.stdout.strip() if r.returncode == 0 else None


def short_rev(d):
    return git(d, "rev-parse", "--short", "HEAD", check=False)


def ensure_built(d, name):
    if (d / "dist" / "bin" / "rustc-ryo").exists():
        return
    PROGRESS.log(f"[compare] {name}: no dist/, running ./y.sh build in {d}")
    if subprocess.run(["./y.sh", "build"], cwd=d).returncode != 0:
        sys.exit(f"{name}: ./y.sh build failed in {d}")


def worktree(rev):
    commit = git(ROOT, "rev-parse", "--verify", f"{rev}^{{commit}}")
    path = ROOT / "target" / "compare" / rev.replace("/", "_")
    if not (path / ".git").exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        PROGRESS.log(f"[compare] git worktree add {path} {rev}")
        git(ROOT, "worktree", "add", "--detach", str(path), commit)
    elif git(path, "rev-parse", "HEAD") != commit:
        PROGRESS.log(f"[compare] warning: {path} is at {short_rev(path)}, not {rev} ({commit[:9]}); "
                     f"reusing it as is (remove it to recreate)")
    ensure_built(path, rev)
    return path


def resolve_builds(args):
    specs = []  # (name or None, path)
    for b in args.build:
        name, sep, path = b.partition("=")
        specs.append((name, Path(path)) if sep else (None, Path(b)))
    for rev in args.worktree:
        specs.append((rev, worktree(rev)))
    if not specs:
        specs = [("main", worktree("main")), (None, ROOT)]
    builds = {}
    for name, path in specs:
        path = path.resolve()
        if name is None:
            name = path.name
            if name in builds:
                name = f"{name}@{short_rev(path)}"
        while name in builds:
            name += "'"
        builds[name] = path
    for name, d in builds.items():
        if not (d / "dist" / "bin" / "rustc-ryo").exists():
            sys.exit(f"{name}: no {d}/dist/bin/rustc-ryo (run ./y.sh build there)")
    if len(builds) < 2:
        PROGRESS.log("[compare] note: only one build; no ratios")
    for i, (name, d) in enumerate(builds.items()):
        PROGRESS.log(f"[compare] {'baseline' if i == 0 else 'build   '} {name}: {d} ({short_rev(d) or '?'})")
    return builds


# --- timing -----------------------------------------------------------------------------

def timed(cmd, pin, cwd=None, cachegrind=False, cache_sim=True):
    """Runs `cmd`; returns (returncode, stdout, stderr, wall, cpu) with cpu = user+sys of
    the child and its waited-for descendants, or with `cachegrind`, their counts
    (`cachegrind_counts`, in place of cpu)."""
    if cachegrind:
        cmd = ["valgrind", "--tool=cachegrind", f"--cache-sim={'yes' if cache_sim else 'no'}", "--trace-children=yes",
               "--cachegrind-out-file=/dev/null", *cmd]
    if pin is not None:
        cmd = ["taskset", "-c", str(pin), *cmd]
    with tempfile.TemporaryFile() as out, tempfile.TemporaryFile() as err:
        t = time.perf_counter()
        p = subprocess.Popen(cmd, stdout=out, stderr=err, stdin=subprocess.DEVNULL, cwd=cwd)
        _, status, ru = os.wait4(p.pid, 0)
        wall = time.perf_counter() - t
        p.returncode = os.waitstatus_to_exitcode(status)
        out.seek(0)
        err.seek(0)
        stderr = err.read().decode(errors="replace")
        cpu = ru.ru_utime + ru.ru_stime
        if cachegrind:
            cpu = cachegrind_counts(stderr)
            if not cpu["instructions"] and p.returncode == 0:
                sys.exit(f"no cachegrind summary from {' '.join(cmd)}:\n{stderr}")
        return p.returncode, out.read().decode(errors="replace"), stderr, wall, cpu


# The counts `--metric cachegrind` reports: name, the summary line, and which number on it
# (0: the total, 1: reads, 2: writes).
CACHEGRIND = [
    ("instructions", "I refs:", 0),
    ("I1 misses", "I1  misses:", 0),
    ("data reads", "D refs:", 1),
    ("data writes", "D refs:", 2),
    ("D1 misses", "D1  misses:", 0),
    ("LL misses", "LL misses:", 0),
]


def cachegrind_counts(stderr):
    """The CACHEGRIND counts of a cachegrind run's summaries (`==pid== D refs:  55,104
    (40,022 rd + 15,082 wr)`), summed over the traced processes."""
    out = {name: 0 for name, _, _ in CACHEGRIND}
    for line in stderr.splitlines():
        if not line.startswith("=="):
            continue
        for name, key, i in CACHEGRIND:
            if key in line:
                nums = [w.replace(",", "") for w in line.split(key)[1].replace("(", " ").split()]
                nums = [int(n) for n in nums if n.isdigit()]
                if len(nums) > i:
                    out[name] += nums[i]
    return out


def sample(label, names, args, rng, eta, fn):
    """Rounds of `fn(name) -> (wall, cpu)` over `names`, shuffled each round; returns
    {name: [seconds]} for the chosen metric, warmup rounds dropped."""
    res = {n: [] for n in names}
    start = time.monotonic()
    rounds = args.warmup + args.samples
    for i in range(rounds):
        if (args.max_time and i > args.warmup and min(len(v) for v in res.values()) >= 3
                and time.monotonic() - start >= args.max_time):
            eta.step((rounds - i) * len(names))
            break
        order = list(names)
        rng.shuffle(order)
        for name in order:
            phase = f"warmup {i + 1}/{args.warmup}" if i < args.warmup else f"{i - args.warmup + 1}/{args.samples}"
            PROGRESS.show(f"{label} {phase} {name:>8} {eta.text()}")
            wall, cpu = fn(name)
            eta.step()
            if i >= args.warmup:
                res[name].append(wall if args.metric == "wall" else cpu)
    return res


def mad(xs):
    m = statistics.median(xs)
    return statistics.median(abs(x - m) for x in xs)


# --- programs ---------------------------------------------------------------------------

def program_list(args):
    bench = ROOT / "bench"
    programs = args.programs.split(",") if args.programs else sorted(f.stem for f in bench.glob("*.rs"))
    for prog in programs:
        if not (bench / f"{prog}.rs").exists():
            sys.exit(f"no {bench}/{prog}.rs")
    return programs


def programs_(args, builds, rng, programs, eta):
    bench = ROOT / "bench"
    flags = ["-Ccodegen-units=1", "-Zthreads=1", *args.flags.split()]
    names = list(builds)
    out = Path(tempfile.mkdtemp(prefix="ryo-compare-"))
    rows = []
    for prog in programs:
        src = bench / f"{prog}.rs"
        exes = {n: out / f"{prog}-{n}" for n in names}

        def compile_(name):
            cmd = [str(builds[name] / "dist" / "bin" / "rustc-ryo"), "--edition=2024", str(src),
                   "-o", str(exes[name]), *flags]
            rc, _, err, wall, cpu = timed(cmd, args.pin, cachegrind=args.metric == "cachegrind", cache_sim=args.cache_sim)
            if rc != 0:
                PROGRESS.log("")
                sys.exit(f"{prog} [{name}]: compile failed:\n{err}")
            return wall, cpu

        outputs = {}

        def run(name):
            rc, stdout, err, wall, cpu = timed([str(exes[name])], args.pin, cachegrind=args.metric == "cachegrind", cache_sim=args.cache_sim)
            if rc != 0:
                PROGRESS.log("")
                sys.exit(f"{prog} [{name}]: exit {rc}\n{err}")
            outputs.setdefault(name, stdout)
            if outputs[name] != stdout:
                sys.exit(f"{prog} [{name}]: output changed between runs")
            return wall, cpu

        # Compiling is sampled first; the last compile's executable is the one run.
        compile_t = sample(f"[programs] {prog:8} compile", names, args, rng, eta, compile_)
        run_t = sample(f"[programs] {prog:8} run    ", names, args, rng, eta, run)
        base = names[0]
        for n in names[1:]:
            if outputs[n] != outputs[base]:
                PROGRESS.log("")
                sys.exit(f"{prog}: outputs differ:\n{base}:\n{outputs[base]}\n{n}:\n{outputs[n]}")
        rows.append((prog, compile_t, run_t))
        PROGRESS.log(f"[compare] {prog} done")

    # Seconds as ms, or counts as millions (one table per count).
    if args.metric == "cachegrind":
        counts = [name for name, _, _ in CACHEGRIND] if args.cache_sim else ["instructions"]
        tables = [("compile", 1, "instructions")] + [("run", 2, name) for name in counts]
    else:
        tables = [("compile time", 1, None), ("run time", 2, None)]
    for title, pick, count in tables:
        if count is not None:
            scale, unit, title = 1e-6, "M", f"{title} {count}"
            get = lambda xs: [x[count] for x in xs]
        else:
            scale, unit = 1e3, "ms"
            get = lambda xs: xs

        def cell(xs):
            if count is not None:
                v = statistics.median(xs) * scale
                return f"{v:.3f}" if v < 100 else f"{v:.1f}"
            return f"{statistics.median(xs) * scale:.1f} ({min(xs) * scale:.1f}, ±{mad(xs) * scale:.1f})"

        cells = [[cell(get(row[pick][n])) for n in names] for row in rows]
        w = max([len(n) for n in names] + [len(c) for r in cells for c in r])
        rw = max([7] + [len(f"{n}/{names[0]}") for n in names[1:]])
        if count is not None:
            print(f"\n{title} (cachegrind, millions)")
        else:
            print(f"\n{title} ({args.metric}, {unit}: median (min, ±MAD)), up to {args.samples} samples")
        print(f"{'program':10} " + " ".join(f"{n:>{w}}" for n in names)
              + "".join(f" {n + '/' + names[0]:>{rw}}" for n in names[1:]))
        for row, cs in zip(rows, cells):
            t = row[pick]
            b = statistics.median(get(t[names[0]]))
            ratios = "".join(f" {statistics.median(get(t[n])) / b if b else float('nan'):>{rw}.3f}" for n in names[1:])
            print(f"{row[0]:10} " + " ".join(f"{c:>{w}}" for c in cs) + ratios)


# --- crates -----------------------------------------------------------------------------

# `y bench crates` crate lists (build/src/crates/mod.rs).
DEFAULT_CRATES = ["miniz_oxide", "hashbrown", "regex-syntax"]
ALL_CRATES = ["semver", "smallvec", "miniz_oxide", "memchr", "hashbrown", "rand", "regex-syntax",
              "unicode-segmentation", "serde_json"]


def parse_tables(text):
    """`y bench crates`' text summary: {table title: {crate: value}} for the `ryo` column."""
    tables, title, cols = {}, None, None
    for line in text.splitlines():
        if not line.strip():
            title = None
            continue
        if title is None:
            if "(median" in line:
                title = line.split(" (median")[0]
                cols = None
            continue
        f = line.split()
        if cols is None:
            cols = f[1:]  # header: `crate llvm ryo`
            continue
        if "ryo" in cols:
            # Values are `<number> <unit>` plus an optional `*`/`!` marker.
            vals = " ".join(f[1:]).replace("*", "").replace("!", "").split()
            pairs = [" ".join(vals[i:i + 2]) for i in range(0, len(vals), 2)]
            if len(pairs) == len(cols):
                tables.setdefault(title, {})[f[0]] = pairs[cols.index("ryo")]
    return tables


def to_number(v):
    n, unit = v.split()
    scale = {"ms": 1e-3, "s": 1, "µs": 1e-6, "us": 1e-6, "B": 1, "kB": 1e3, "MB": 1e6, "GB": 1e9}
    return float(n) * scale.get(unit, 1)


def run_streaming(cmd, cwd, label):
    """Runs `cmd`, showing its stderr lines in the progress line; returns (rc, stdout, stderr tail)."""
    p = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                         stdin=subprocess.DEVNULL, text=True, bufsize=1)
    tail = []

    def pump():
        for line in p.stderr:
            line = line.rstrip()
            tail.append(line)
            del tail[:-40]
            if line:
                PROGRESS.show(f"{label} {line}")

    t = threading.Thread(target=pump, daemon=True)
    t.start()
    stdout = p.stdout.read()
    p.wait()
    t.join()
    return p.returncode, stdout, "\n".join(tail)


def crate_list(args):
    return {"default": DEFAULT_CRATES, "all": ALL_CRATES}.get(args.crates) or args.crates.split(",")


def crates_(args, builds, rng, names, eta):
    results = {k: {} for k in builds}
    for krate in names:
        order = list(builds)
        rng.shuffle(order)
        for name in order:
            label = f"[crates] {krate} [{name}] {eta.text()} |"
            PROGRESS.show(label)
            cmd = ["./y.sh", "bench", "crates", "--backends", "ryo", "--crates", krate,
                   "--build-samples", str(args.samples), "--run-samples", str(args.samples),
                   "--out", str(Path(tempfile.mkdtemp(prefix="ryo-compare-")) / "report.html")]
            if args.pin is not None:
                cmd = ["taskset", "-c", str(args.pin), *cmd]
            rc, stdout, err = run_streaming(cmd, builds[name], label)
            eta.step(2 * args.samples)
            if rc != 0:
                PROGRESS.log(f"{krate} [{name}]: y bench crates failed:\n{stdout[-2000:]}{err[-2000:]}")
                continue
            for title, vals in parse_tables(stdout).items():
                results[name].setdefault(title, {}).update(vals)
        PROGRESS.log(f"[compare] crates: {krate} done")
    print_crates(results, names, list(builds), args.samples)


def print_crates(results, crates, names, samples):
    base = names[0]
    titles = [t for t in results[base] if all(t in results[n] for n in names)]
    for title in titles:
        rw = max([7] + [len(f"{n}/{base}") for n in names[1:]])
        w = max([10] + [len(n) for n in names])
        print(f"\ncrates: {title} (median, {samples} samples)")
        print(f"{'crate':20} " + " ".join(f"{n:>{w}}" for n in names)
              + "".join(f" {n + '/' + base:>{rw}}" for n in names[1:]))
        for krate in crates:
            vals = [results[n][title].get(krate) for n in names]
            if any(v is None for v in vals):
                continue
            b = to_number(vals[0])
            ratios = "".join(f" {to_number(v) / b if b else float('nan'):>{rw}.3f}" for v in vals[1:])
            print(f"{krate:20} " + " ".join(f"{v:>{w}}" for v in vals) + ratios)


# --- main -------------------------------------------------------------------------------

def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--build", action="append", default=[], metavar="[NAME=]PATH",
                   help="a checkout with a built dist/ (repeatable; the first build is the baseline)")
    p.add_argument("--worktree", action="append", default=[], metavar="REV",
                   help="add commit REV as a build, from a git worktree at target/compare/REV (repeatable)")
    p.add_argument("--samples", type=int, default=8, help="timed samples per measurement (default 8)")
    p.add_argument("--warmup", type=int, default=1, help="dropped rounds before sampling (default 1)")
    p.add_argument("--max-time", type=float, default=0,
                   help="stop a measurement early once it has 3 samples and this many seconds are spent")
    p.add_argument("--metric", choices=["cpu", "wall", "cachegrind"], default="cpu",
                   help="report child CPU time (user+sys, default), wall time, or instructions "
                        "executed under cachegrind (one sample)")
    p.add_argument("--no-cache-sim", dest="cache_sim", action="store_false",
                   help="with --metric cachegrind, count instructions only (no cache simulation; faster)")
    p.add_argument("--pin", metavar="CPU", help="run timed commands under `taskset -c CPU`")
    p.add_argument("--seed", type=int, default=0, help="seed for the per-round build order shuffle")
    p.add_argument("--programs", default="", help="comma-separated names in bench/ (default: all)")
    p.add_argument("--flags", default="", help="extra rustc flags for all builds")
    p.add_argument("--crates", nargs="?", const="default", default=None,
                   help="also compare `y bench crates` (a,b | all | default, as y's --crates)")
    p.add_argument("--only-crates", action="store_true", help="only the crates comparison")
    args = p.parse_args()
    if args.only_crates and args.crates is None:
        args.crates = "default"
    if args.metric == "cachegrind":
        if args.crates is not None:
            sys.exit("--metric cachegrind doesn't apply to --crates")
        if not shutil.which("valgrind"):
            sys.exit("--metric cachegrind needs valgrind")
        # Instruction counts are deterministic, once the JIT compiles on the running thread
        # (with a background JIT thread they depend on when it finishes).
        args.samples, args.warmup = 1, 0
        os.environ.setdefault("RYO_JIT_SYNC", "1")
        os.environ.setdefault("RYO_JIT_OPT", "ssa")
    if args.samples < 1:
        sys.exit("--samples must be at least 1")

    builds = resolve_builds(args)
    rng = random.Random(args.seed)
    programs = [] if args.only_crates else program_list(args)
    crates = [] if args.crates is None else crate_list(args)
    n = len(builds)
    eta = Eta(len(programs) * 2 * (args.warmup + args.samples) * n + len(crates) * 2 * args.samples * n)
    if programs:
        programs_(args, builds, rng, programs, eta)
    if crates:
        crates_(args, builds, rng, crates, eta)


if __name__ == "__main__":
    main()
