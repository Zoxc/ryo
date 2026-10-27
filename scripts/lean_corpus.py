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
IMAGE_GLOB = "*.ryo_image.rcgu.o"


def run(cmd, cwd=None, env=None, timeout=TIMEOUT):
    """(exit status or None on timeout, stdout, stderr)."""
    try:
        p = subprocess.run(cmd, cwd=cwd or ROOT, env=env, capture_output=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None, b"", b"<timeout>"
    return p.returncode, p.stdout, p.stderr


def programs(names):
    """The single-file programs (tests/lean, tests, bench) as `(dir/stem, path)`, those `names`
    picks by stem or label (all without names)."""
    srcs = sorted((ROOT / "tests" / "lean").glob("*.rs")) + sorted((ROOT / "tests").glob("*.rs")) + sorted((ROOT / "bench").glob("*.rs"))
    out = []
    for s in srcs:
        label = f"{s.parent.relative_to(ROOT)}/{s.stem}"
        if names and s.stem not in names and label not in names:
            continue
        out.append((label, s))
    return out


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


def compile_program(src, flags, out_dir, env=None):
    """Builds `src` with -Csave-temps in a fresh `out_dir`: (exit status, the reason it failed:
    stderr's last line)."""
    shutil.rmtree(out_dir, ignore_errors=True)
    out_dir.mkdir(parents=True)
    name = src.stem
    cmd = [str(RUSTC_RYO), "--edition=2024", str(src), "--crate-type", "bin", "--crate-name", name, "-o", str(out_dir / name), "-Csave-temps"]
    code, _, err = run(cmd + flags, cwd=out_dir, env=env)
    return code, (err.decode(errors="replace").strip().splitlines()[-1:] or ["build failed"])[0]


def build_all(names, variants, work, jobs, build):
    """Runs `build(src, flags, out_dir)` (a result, or None and a skip reason) for every program
    and variant, in `work/<label>`: ([(label, result)], [(label, skip reason)])."""
    built, skipped = [], []
    with concurrent.futures.ThreadPoolExecutor(jobs) as pool:
        futs = {}
        for label, src in programs(names):
            for suffix, flags in variants:
                l = label + suffix
                futs[pool.submit(build, src, flags, work / l.replace("/", "_"))] = l
        for f in concurrent.futures.as_completed(futs):
            res, why = f.result()
            if why:
                skipped.append((futs[f], why))
            else:
                built.append((futs[f], res))
    return built, skipped


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
            if m.endswith(".ryo_image.rcgu.o"):
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
