//! `extern "C"` functions compiled by the VM called back from native code: a libc `qsort`
//! comparator, `pthread_create` (Windows: `CreateThread`) start routines and a `std::thread`
//! body through an `extern "C"` trampoline, a `#[no_mangle]` export called through a declared
//! `extern` block, and VM callers of all of them. A panic out of an `extern "C"` fn aborts
//! (the last thing the program does; the exit status is compared too).
use std::arch::asm;
use std::ffi::c_void;
use std::hint::black_box;

/// Keeps the function it is in native: the VM doesn't run inline asm.
macro_rules! native {
    () => {
        unsafe { asm!("", options(nomem, nostack, preserves_flags)) }
    };
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct Item {
    key: i16,
    weight: f32,
    id: u8,
}

/// A `qsort` comparator: by `key` descending, then `weight`.
extern "C" fn cmp_items(a: *const c_void, b: *const c_void) -> i32 {
    let (a, b) = unsafe { (&*(a as *const Item), &*(b as *const Item)) };
    match b.key.cmp(&a.key) {
        std::cmp::Ordering::Equal => a.weight.partial_cmp(&b.weight).unwrap() as i32,
        o => o as i32,
    }
}

/// A comparator returning a narrow signed integer (its sign-extension matters to a native
/// caller): compares bytes.
#[inline(never)]
extern "C" fn cmp_bytes(a: u8, b: u8) -> i8 {
    (a as i16 - b as i16).signum() as i8
}

unsafe extern "C" {
    fn qsort(base: *mut c_void, n: usize, size: usize, cmp: extern "C" fn(*const c_void, *const c_void) -> i32);
}

#[inline(never)]
fn sort_items() -> Vec<(i16, u8)> {
    let mut v: Vec<Item> = (0..17u8).map(|i| Item { key: (i as i16 * 7) % 5 - 2, weight: (i as f32 * 1.7) % 3.0, id: i }).collect();
    unsafe { qsort(v.as_mut_ptr().cast(), v.len(), size_of::<Item>(), black_box(cmp_items)) };
    v.iter().map(|i| (i.key, i.id)).collect()
}

/// Native code calling the narrow comparator through a pointer and through its symbol.
#[inline(never)]
fn native_cmp_bytes(f: extern "C" fn(u8, u8) -> i8) -> (i32, i32, i32) {
    native!();
    (f(black_box(1), black_box(200)) as i32, cmp_bytes(black_box(9), black_box(9)) as i32, f(black_box(250), black_box(3)) as i32)
}

// --- pthread start routines --------------------------------------------------------------

#[cfg(windows)]
#[link(name = "kernel32")]
unsafe extern "system" {
    fn CreateThread(attr: *const c_void, stack: usize, start: extern "system" fn(*mut c_void) -> u32, arg: *mut c_void, flags: u32, id: *mut u32) -> *mut c_void;
    fn WaitForSingleObject(h: *mut c_void, ms: u32) -> u32;
    fn GetExitCodeThread(h: *mut c_void, code: *mut u32) -> i32;
    fn CloseHandle(h: *mut c_void) -> i32;
}

#[cfg(windows)]
/// A `CreateThread` start routine (`extern "system"` is C on x86-64): sums the slice its
/// argument points to.
extern "system" fn sum_thread(arg: *mut c_void) -> u32 {
    let v = unsafe { &*(arg as *const Vec<u64>) };
    v.iter().sum::<u64>() as u32
}

#[cfg(windows)]
#[inline(never)]
fn pthreads() -> Vec<u64> {
    let data: Vec<Vec<u64>> = (1..5u64).map(|k| (0..100 * k).collect()).collect();
    let mut ts = Vec::new();
    for d in &data {
        let h = unsafe { CreateThread(std::ptr::null(), 0, sum_thread, d as *const Vec<u64> as *mut c_void, 0, std::ptr::null_mut()) };
        assert!(!h.is_null());
        ts.push(h);
    }
    ts.into_iter()
        .map(|h| {
            let mut code = 0;
            unsafe {
                assert_eq!(WaitForSingleObject(h, u32::MAX), 0);
                assert_ne!(GetExitCodeThread(h, &mut code), 0);
                CloseHandle(h);
            }
            u64::from(code)
        })
        .collect()
}

#[cfg(unix)]
#[allow(non_camel_case_types)]
type pthread_t = usize;

#[cfg(unix)]
unsafe extern "C" {
    fn pthread_create(t: *mut pthread_t, attr: *const c_void, start: extern "C" fn(*mut c_void) -> *mut c_void, arg: *mut c_void) -> i32;
    fn pthread_join(t: pthread_t, ret: *mut *mut c_void) -> i32;
}

#[cfg(unix)]
/// A start routine: sums the slice its argument points to, returns the sum boxed.
extern "C" fn sum_thread(arg: *mut c_void) -> *mut c_void {
    let v = unsafe { &*(arg as *const Vec<u64>) };
    Box::into_raw(Box::new(v.iter().sum::<u64>())).cast()
}

#[cfg(unix)]
#[inline(never)]
fn pthreads() -> Vec<u64> {
    let data: Vec<Vec<u64>> = (1..5u64).map(|k| (0..100 * k).collect()).collect();
    let mut ts = Vec::new();
    for d in &data {
        let mut t: pthread_t = 0;
        assert_eq!(unsafe { pthread_create(&mut t, std::ptr::null(), sum_thread, d as *const Vec<u64> as *mut c_void) }, 0);
        ts.push(t);
    }
    ts.into_iter()
        .map(|t| {
            let mut r = std::ptr::null_mut();
            assert_eq!(unsafe { pthread_join(t, &mut r) }, 0);
            *unsafe { Box::from_raw(r as *mut u64) }
        })
        .collect()
}

// --- std::thread through an extern "C" trampoline ----------------------------------------

/// A C-style callback with a context pointer, as a C library would take it.
type Callback = extern "C" fn(ctx: *mut c_void, x: f64, n: u32) -> f64;

/// The trampoline: calls the closure behind `ctx`.
extern "C" fn trampoline<F: FnMut(f64, u32) -> f64>(ctx: *mut c_void, x: f64, n: u32) -> f64 {
    let f = unsafe { &mut *(ctx as *mut F) };
    f(x, n)
}

/// Native "library" code driving a callback.
#[inline(never)]
fn drive(cb: Callback, ctx: *mut c_void) -> f64 {
    native!();
    let mut acc = 0.0;
    for n in 0..5 {
        acc += cb(ctx, black_box(acc + 0.5), n);
    }
    acc
}

/// Passes `f` to the native driver as a C callback and context.
fn with_callback<F: FnMut(f64, u32) -> f64>(f: &mut F) -> f64 {
    drive(trampoline::<F>, f as *mut F as *mut c_void)
}

#[inline(never)]
fn threads() -> Vec<f64> {
    (0..3)
        .map(|k| {
            std::thread::spawn(move || {
                let mut calls = 0u32;
                let mut f = |x: f64, n: u32| {
                    calls += 1;
                    x * (k as f64 + 1.0) + n as f64
                };
                let r = with_callback(&mut f);
                r + calls as f64
            })
        })
        .collect::<Vec<_>>()
        .into_iter()
        .map(|t| t.join().unwrap())
        .collect()
}

// --- #[no_mangle] export ------------------------------------------------------------------

#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct Big {
    a: [u32; 7],
}

/// Exported under its own name; `byval` argument, sret return.
#[unsafe(no_mangle)]
pub extern "C" fn ryo_c_abi_def_export(x: u16, big: Big, f: f32) -> Big {
    let mut b = big;
    b.a.reverse();
    b.a[0] = b.a[0].wrapping_add(x as u32);
    b.a[6] = (b.a[6] as f32 * f) as u32;
    b
}

mod imported {
    #[repr(C)]
    #[derive(Debug, Clone, Copy)]
    pub struct Big {
        pub a: [u32; 7],
    }
    unsafe extern "C" {
        /// The same function, through its symbol.
        pub fn ryo_c_abi_def_export(x: u16, big: Big, f: f32) -> Big;
    }
}

#[inline(never)]
fn export_calls() -> (Big, imported::Big, imported::Big) {
    let big = Big { a: [1, 2, 3, 4, 5, 6, 7] };
    let direct = ryo_c_abi_def_export(black_box(10), big, black_box(2.5));
    let via = unsafe { imported::ryo_c_abi_def_export(black_box(20), imported::Big { a: big.a }, black_box(0.5)) };
    let native = native_export_call();
    (direct, via, native)
}

#[inline(never)]
fn native_export_call() -> imported::Big {
    native!();
    unsafe { imported::ryo_c_abi_def_export(black_box(30), imported::Big { a: [9; 7] }, black_box(1.0)) }
}

// --- panics -------------------------------------------------------------------------------

/// A panic inside: caught inside, so nothing escapes.
extern "C" fn catches(x: u32) -> u32 {
    std::panic::catch_unwind(|| {
        if x > 1 {
            panic!("caught {x}");
        }
        x
    })
    .unwrap_or(99)
}

/// A panic escaping an `extern "C"` fn: `panic_cannot_unwind`, which aborts.
#[inline(never)]
extern "C" fn escapes(x: u32) -> u32 {
    if x > 2 {
        panic!("escapes {x}");
    }
    x
}

fn main() {
    // The default hook forces a backtrace for non-unwinding panics, and VM frames differ.
    std::panic::set_hook(Box::new(|i| println!("hook: {} at line {}", i.payload_as_str().unwrap_or(""), i.location().unwrap().line())));
    println!("qsort: {:?}", sort_items());
    println!("cmp_bytes: {:?} {}", native_cmp_bytes(black_box(cmp_bytes)), cmp_bytes(black_box(3), black_box(4)));
    println!("pthreads: {:?}", pthreads());
    println!("threads: {:?}", threads());
    println!("export: {:?}", export_calls());
    println!("catches: {} {}", catches(black_box(1)), catches(black_box(5)));
    println!("escapes: {}", escapes(black_box(1)));
    println!("escapes: {}", escapes(black_box(5)));
}
