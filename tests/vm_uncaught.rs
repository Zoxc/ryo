//! A panic from VM frames on a thread the OS created (`pthread_create`, `CreateThread`), with
//! no Rust frame above its `extern "C-unwind"` entry: nothing catches it, so no drops run and
//! the process ends as natively (the exit status and stderr are compared).
use std::ffi::c_void;
use std::hint::black_box;

struct G(&'static str);

impl Drop for G {
    fn drop(&mut self) {
        println!("drop {}", self.0);
    }
}

#[inline(never)]
fn raise(n: u32) -> u32 {
    let _g = G("raise");
    if black_box(n) > 0 {
        panic!("uncaught {n}");
    }
    n
}

#[inline(never)]
fn vm_entry(n: u32) -> u32 {
    let _g = G("entry");
    raise(n) + 1
}

#[cfg(unix)]
mod os {
    use std::ffi::c_void;

    unsafe extern "C" {
        fn pthread_create(t: *mut usize, attr: *const c_void, f: extern "C-unwind" fn(*mut c_void) -> *mut c_void, arg: *mut c_void) -> i32;
        fn pthread_join(t: usize, ret: *mut *mut c_void) -> i32;
    }

    extern "C-unwind" fn start(arg: *mut c_void) -> *mut c_void {
        super::run(arg)
    }

    pub fn spawn_join(arg: *mut c_void) {
        let mut t = 0;
        unsafe {
            assert_eq!(pthread_create(&mut t, std::ptr::null(), start, arg), 0);
            assert_eq!(pthread_join(t, std::ptr::null_mut()), 0);
        }
    }
}

#[cfg(windows)]
mod os {
    use std::ffi::c_void;

    #[link(name = "kernel32")]
    unsafe extern "system" {
        fn CreateThread(
            attr: *const c_void,
            stack: usize,
            f: extern "system-unwind" fn(*mut c_void) -> u32,
            arg: *mut c_void,
            flags: u32,
            id: *mut u32,
        ) -> *mut c_void;
        fn WaitForSingleObject(h: *mut c_void, ms: u32) -> u32;
        fn CloseHandle(h: *mut c_void) -> i32;
    }

    extern "system-unwind" fn start(arg: *mut c_void) -> u32 {
        super::run(arg);
        0
    }

    pub fn spawn_join(arg: *mut c_void) {
        unsafe {
            let h = CreateThread(std::ptr::null(), 0, start, arg, 0, std::ptr::null_mut());
            assert!(!h.is_null());
            assert_eq!(WaitForSingleObject(h, u32::MAX), 0);
            CloseHandle(h);
        }
    }
}

fn run(arg: *mut c_void) -> *mut c_void {
    println!("thread: {}", vm_entry(arg as usize as u32));
    std::ptr::null_mut()
}

fn main() {
    std::panic::set_hook(Box::new(|i| println!("hook: {}", i.payload_as_str().unwrap_or(""))));
    os::spawn_join(std::ptr::null_mut());
    println!("joined");
    os::spawn_join(1 as *mut c_void);
    println!("not reached");
}
