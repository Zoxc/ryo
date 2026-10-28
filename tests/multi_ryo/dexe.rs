// Sibling Rust dylibs `da` and `db` (neither depends on the other) and this executable, built
// with `-Cprefer-dynamic`: each module links a private copy of the runtime, and copies of one
// ryo build with one std merge at run time (design/vm.md#several-ryo-runtimes-in-one-process).
// Prints the results and the number of `ryo-jit` threads.
fn jit_threads() -> usize {
    let Ok(dir) = std::fs::read_dir("/proc/self/task") else { return 0 };
    dir.flatten().filter(|t| std::fs::read_to_string(t.path().join("comm")).is_ok_and(|c| c.trim().starts_with("ryo-jit"))).count()
}

fn work(n: u64) -> u64 {
    (0..n).fold(0u64, |s, i| s.wrapping_add(i * 7))
}

fn main() {
    let (mut a, mut b, mut c) = (0, 0, 0);
    for _ in 0..200 {
        a += da::da_work(1000);
        b += db::db_work(100);
        c += work(100) + da::ryo_rt::rt_work(1);
    }
    println!("{a} {b} {c} {}", db::DB_COUNT.load(std::sync::atomic::Ordering::Relaxed));
    println!("jit threads: {}", jit_threads());
}
