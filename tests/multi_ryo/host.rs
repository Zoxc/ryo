// Loads the cdylib `argv[1]` (`plugin.rs`) with `RTLD_LOCAL` or, with `argv[2] == "global"`,
// `RTLD_GLOBAL`, and runs its function and one of its own, both hot. Prints the results and
// the number of `ryo-jit` threads.
use std::ffi::{CString, c_char, c_int, c_void};

unsafe extern "C" {
    fn dlopen(file: *const c_char, mode: c_int) -> *mut c_void;
    fn dlsym(handle: *mut c_void, name: *const c_char) -> *mut c_void;
    fn dlerror() -> *const c_char;
}

fn jit_threads() -> usize {
    let Ok(dir) = std::fs::read_dir("/proc/self/task") else { return 0 };
    dir.flatten().filter(|t| std::fs::read_to_string(t.path().join("comm")).is_ok_and(|c| c.trim().starts_with("ryo-jit"))).count()
}

fn work(n: u64) -> u64 {
    (0..n).fold(0u64, |s, i| s ^ (i * 3))
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let mode = if args.get(2).is_some_and(|m| m == "global") { 0x2 | 0x100 } else { 0x2 };
    let path = CString::new(args[1].as_str()).unwrap();
    let run: extern "C" fn(u64) -> u64 = unsafe {
        let h = dlopen(path.as_ptr(), mode);
        assert!(!h.is_null(), "dlopen: {:?}", std::ffi::CStr::from_ptr(dlerror()));
        let f = dlsym(h, c"plugin_run".as_ptr());
        assert!(!f.is_null());
        std::mem::transmute(f)
    };
    let (mut p, mut h) = (0u64, 0u64);
    for _ in 0..200 {
        p = p.wrapping_add(run(1000));
        h = h.wrapping_add(work(1000));
    }
    println!("{p} {h}");
    println!("jit threads: {}", jit_threads());
}
