"""The corpus scaffolding shared by the scripts/lean-*-check.py and lean-decode-diff.py checkers:
the programs, their builds with dist/bin/rustc-ryo -Csave-temps, the ryo sysroot's image
objects, and the tool checks."""

import concurrent.futures
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RUSTC_RYO = ROOT / "dist" / "bin" / "rustc-ryo"
RYO_LEAN = ROOT / "lean" / ".lake" / "build" / "bin" / "ryo-lean"
TIMEOUT = 1800
IMAGE_SUFFIX = ".ryo_image.rcgu.o"
IMAGE_GLOB = "*" + IMAGE_SUFFIX


def run(cmd, cwd=None, env=None, timeout=TIMEOUT, keep_partial=False):
    """(exit status as the shell reports it (128 + n for signal n) or None on timeout, stdout,
    stderr). With `keep_partial`, a timed-out run keeps the output it wrote."""
    try:
        p = subprocess.run(cmd, cwd=cwd or ROOT, env=env, capture_output=True, timeout=timeout)
    except subprocess.TimeoutExpired as e:
        if keep_partial:
            return None, e.stdout or b"", (e.stderr or b"") + b"\n<timeout>"
        return None, b"", b"<timeout>"
    return 128 - p.returncode if p.returncode < 0 else p.returncode, p.stdout, p.stderr


def picked(names, label):
    """Whether `names` (all without names) picks the program `label` (`dir/stem`), by stem or
    label."""
    return not names or label in names or label.rsplit("/", 1)[-1] in names


def programs(names):
    """The single-file programs (tests/lean, tests, bench) as `(dir/stem, path)`, those `names`
    picks by stem or label (all without names)."""
    srcs = sorted((ROOT / "tests" / "lean").glob("*.rs")) + sorted((ROOT / "tests").glob("*.rs")) + sorted((ROOT / "bench").glob("*.rs"))
    labels = [(f"{s.parent.relative_to(ROOT)}/{s.stem}", s) for s in srcs]
    return [(label, s) for label, s in labels if picked(names, label)]


def label_dir(label):
    """The directory name `build_all` gives the build of `label` (a program label plus variant
    suffix)."""
    return label.replace("/", "_")


LABEL_FILE = "label"


def variants(opt, frame_pointer=False, codegen_units=None):
    """`(label suffix, flags)`: -O0, with `opt` -O3, with `frame_pointer` each also with frame
    pointers; with `codegen_units` every one built with -Ccodegen-units=N (rustc's default puts
    a small program in one CGU, so one image; more CGUs give one image each, cross-image
    `call.sym`s and per-image `#[inline]` copies)."""
    vs = [("", [])] + ([("-O3", ["-Copt-level=3"])] if opt else [])
    if frame_pointer:
        vs += [(v + "-fp", f + ["-Cforce-frame-pointers=yes"]) for v, f in vs]
    if codegen_units:
        vs = [(v, f + [f"-Ccodegen-units={codegen_units}"]) for v, f in vs]
    return vs


def rustc_cmd(compiler, src, exe):
    """The command line building the single-file program `src` with `compiler` into `exe`."""
    return [str(compiler), "--edition=2024", str(src), "--crate-type", "bin", "--crate-name", src.stem, "-o", str(exe)]


def compile_program(src, flags, out_dir, env=None):
    """Builds `src` with -Csave-temps in a fresh `out_dir`: (exit status, the reason it failed:
    stderr's last line)."""
    shutil.rmtree(out_dir, ignore_errors=True)
    out_dir.mkdir(parents=True)
    cmd = rustc_cmd(RUSTC_RYO, src, out_dir / src.stem) + ["-Csave-temps"]
    code, _, err = run(cmd + flags, cwd=out_dir, env=env)
    return code, (err.decode(errors="replace").strip().splitlines()[-1:] or ["build failed"])[0]


def build_all(names, variants, work, jobs, build):
    """Runs `build(src, flags, out_dir)` (a result, or None and a skip reason) for every program
    and variant, in `work/label_dir(<label>)` (with a `label` file naming the program and the
    build, for `corpus_dirs`): ([(label, result)], [(label, skip reason)])."""
    built, skipped = [], []
    with concurrent.futures.ThreadPoolExecutor(jobs) as pool:
        futs = {}
        for label, src in programs(names):
            for suffix, flags in variants:
                l = label + suffix
                futs[pool.submit(build, src, flags, work / label_dir(l))] = (label, l)
        for f in concurrent.futures.as_completed(futs):
            res, why = f.result()
            program, l = futs[f]
            d = work / label_dir(l)
            if d.is_dir():
                (d / LABEL_FILE).write_text(f"{program}\n{l}\n")
            if why:
                skipped.append((l, why))
            else:
                built.append((l, res))
    return built, skipped


def corpus_dirs(corpus, names):
    """The program builds `build_all` left in `corpus` (as --keep keeps them), as `(label, dir)`,
    those `names` picks by the same rule as `programs`. Directories without a `label` file are
    labeled and picked by their name."""
    out = []
    for d in sorted(Path(corpus).iterdir()):
        if not d.is_dir():
            continue
        f = d / LABEL_FILE
        program, label = f.read_text().split() if f.is_file() else (d.name, d.name)
        if picked(names, program):
            out.append((label, d))
    return out


def sysroot_images(names, out_dir):
    """The ryo sysroot's rlibs' image objects (one per CGU with VM code), extracted to
    `out_dir/<crate>/`, as `(sysroot/<crate>, path)` in member order, those `names` picks."""
    out = []
    for rlib in sorted((ROOT / "dist" / "sysroot-ryo" / "lib" / "rustlib").glob("*/lib/*.rlib")):
        crate = re.sub(r"^lib|-[0-9a-f]+$", "", rlib.stem)
        if names and crate not in names and f"sysroot/{crate}" not in names:
            continue
        _, members, _ = run(["ar", "t", str(rlib)])
        for m in members.decode().split():
            if m.endswith(IMAGE_SUFFIX):
                d = out_dir / crate
                d.mkdir(parents=True, exist_ok=True)
                code, data, _ = run(["ar", "p", str(rlib), m])
                if code == 0:
                    (d / m).write_bytes(data)
                    out.append((f"sysroot/{crate}", d / m))
    return out


def add_common_args(ap):
    ap.add_argument("names", nargs="*")
    ap.add_argument("--ryo-lean", default=str(RYO_LEAN))
    ap.add_argument("--opt", action="store_true")
    ap.add_argument("--keep")
    ap.add_argument("--codegen-units", type=int, metavar="N", help="build the programs with -Ccodegen-units=N")
    ap.add_argument("-j", type=int, default=os.cpu_count() or 4)


def require(ryo_lean, rustc_ryo=True):
    if rustc_ryo and not RUSTC_RYO.exists():
        sys.exit(f"{RUSTC_RYO} not found; run ./y.sh build")
    if not Path(ryo_lean).exists():
        sys.exit(f"{ryo_lean} not found; build it with `lake build` in lean/, or pass --ryo-lean")


def work_dir(keep, prefix):
    """`keep`, or a fresh temporary directory."""
    work = Path(keep) if keep else Path(tempfile.mkdtemp(prefix=prefix))
    work.mkdir(parents=True, exist_ok=True)
    return work


def pool_map(jobs, fn, items):
    """`fn(*args)` for every `args` in `items`, run on `jobs` threads, in `items`' order."""
    with concurrent.futures.ThreadPoolExecutor(jobs) as pool:
        return list(pool.map(lambda args: fn(*args), items))


def check_all(jobs, check, items):
    """Runs `check(*args)` (rows, report lines, skip reason) for every `(label, args)` in `items`
    on `jobs` threads: (rows sorted by label and object, report lines, [(label, skip reason)])."""
    rows, reports, skipped = [], [], []
    for (label, _), (r, rep, why) in zip(items, pool_map(jobs, check, [args for _, args in items])):
        if why:
            skipped.append((label, why))
        rows += r
        reports += rep
    rows.sort(key=lambda r: (r[0], r[1]))
    return rows, reports, skipped


def parse_rows(text, label, tool, line, fields, folds=()):
    """A `ryo-lean check-*` output as (rows, report lines). Each `line` match starts a row
    `(label, object, {field: value})` from its groups after the object; each `(regex, fold)` in
    `folds` matching a line calls `fold(label, match, current row or None, rows)`, which returns the
    new current row; other `<tool> <object>:` lines are unreadable objects (`(label, object,
    None)`), and the rest are reported under the current row's object."""
    rows, report, cur = [], [], None
    for l in text.splitlines():
        m = line.match(l)
        if m:
            cur = (label, Path(m.group(1)).name, dict(zip(fields, map(int, m.groups()[1:]))))
            rows.append(cur)
            continue
        for regex, fold in folds:
            m = regex.match(l)
            if m:
                cur = fold(label, m, cur, rows)
                break
        else:
            if l.startswith(f"{tool} "):
                rows.append((label, l.split(":", 1)[0].removeprefix(f"{tool} "), None))
                report.append(f"=== {label}: {l}")
            elif cur is not None and l.strip():
                report.append(f"{label} {cur[1]}: {l}")
    return rows, report


def print_rows(head, widths, rows, skipped=(), reports=()):
    """Prints a table: the header `head` (the label column's name, then one per column), the
    `rows` of string cells `(label, cell...)` right-aligned to `widths` (0: unpadded), the
    skipped programs (`-` cells and the reason in the last column), then each report after a
    blank line."""
    w = max([len(r[0]) for r in rows] + [len(l) for l, _ in skipped] + [len(head[0])])

    def line(label, cells):
        print(f"{label:<{w}}  " + "  ".join(f"{c:>{wd}}" for c, wd in zip(cells, widths)))

    line(head[0], head[1:])
    for r in rows:
        line(r[0], r[1:])
    for label, why in sorted(skipped):
        line(label, ["-"] * (len(widths) - 1) + [f"skipped: {why}"])
    for rep in reports:
        print()
        print(rep)


def print_table(rows, cols, width, is_bad, skipped, reports, note=lambda vals: ""):
    """Prints `rows` (from `parse_rows`) as a table of `cols` with a total row, then the skipped
    programs and the report lines: (totals, number of bad rows: unreadable or `is_bad(vals)`)."""
    tot = dict.fromkeys(cols, 0)
    bad = 0
    out = []
    for label, obj, vals in rows:
        if vals is None:
            out.append((label, f"unreadable object {obj}"))
            bad += 1
            continue
        cells = [str(vals.get(c, "-")) for c in cols]
        out.append((label, *cells[:-1], f"{cells[-1]:>{width}}" + note(vals)))
        for c in cols:
            tot[c] += vals.get(c, 0)
        if is_bad(vals):
            bad += 1
    out.append(("total", *(str(tot[c]) for c in cols)))
    widths = [width] * len(cols)
    print_rows(["program", *cols], widths, out, skipped, ["\n".join(reports)] if reports else [])
    return tot, bad


def finish(work, keep, bad):
    """Removes `work` (if any) unless `keep`, and exits nonzero if `bad`."""
    if work and not keep:
        shutil.rmtree(work, ignore_errors=True)
    sys.exit(1 if bad else 0)
