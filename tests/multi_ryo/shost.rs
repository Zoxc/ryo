// Loads the dylib `argv[1]` (`splugin.rs`), which links its own copy of `shared.rs` as this
// executable does, and runs both copies hot. Prints the results.
use std::ffi::{c_char, c_int, c_void};

unsafe extern "C" {
    fn dlopen(file: *const c_char, mode: c_int) -> *mut c_void;
    fn dlsym(handle: *mut c_void, name: *const c_char) -> *mut c_void;
    fn dlerror() -> *const c_char;
}

fn main() {
    let path = std::ffi::CString::new(std::env::args().nth(1).unwrap()).unwrap();
    let run: extern "C" fn(u64) -> u64 = unsafe {
        let h = dlopen(path.as_ptr(), 0x2);
        assert!(!h.is_null(), "dlopen: {:?}", std::ffi::CStr::from_ptr(dlerror()));
        let f = dlsym(h, c"splugin_run".as_ptr());
        assert!(!f.is_null());
        std::mem::transmute(f)
    };
    let (mut a, mut b) = (0u64, 0u64);
    for _ in 0..200 {
        a = a.wrapping_add(shared::shared_work(1000));
        b = b.wrapping_add(run(1000));
    }
    println!("{a} {b}");
}
