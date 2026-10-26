//! Regression tests for what building std with ryo found (`--sysroot ryo`): a constructor
//! that runs VM code before `main`, functions taking unsized arguments, `extern_weak` statics,
//! and foreign LLVM intrinsics called from local copies of `#[inline]` functions.
#![feature(unsized_fn_params, linkage)]
#![allow(internal_features)]

use std::sync::atomic::{AtomicU32, Ordering};

static FROM_CTOR: AtomicU32 = AtomicU32::new(0);

/// Run by the C runtime before `main`, with the priority of std's own argument initializer
/// (`.init_array.00099`; on Mach-O, which has no priorities, an ordinary initializer): it enters the VM, so the image registry's constructor must have run
/// already, whatever the link order.
#[used]
#[cfg_attr(not(any(windows, target_vendor = "apple")), unsafe(link_section = ".init_array.00099"))]
#[cfg_attr(windows, unsafe(link_section = ".CRT$XCU"))]
#[cfg_attr(target_vendor = "apple", unsafe(link_section = "__DATA,__mod_init_func,mod_init_funcs"))]
static CTOR: extern "C" fn() = ctor;

extern "C" fn ctor() {
    FROM_CTOR.store(ctor_value(6), Ordering::Relaxed);
}

fn ctor_value(n: u32) -> u32 {
    (1..=n).product()
}

/// Taking or passing an unsized argument by value keeps a function native: its argument block
/// has no layout.
trait Total {
    fn total(self) -> u32;
}

impl Total for [u8] {
    fn total(self) -> u32 {
        let s: &[u8] = &self;
        s.iter().map(|&b| u32::from(b)).sum()
    }
}

fn unsized_arg(b: Box<[u8]>) -> u32 {
    (*b).total() + 1
}

#[cfg(not(windows))]
mod weak {
    unsafe extern "C" {
        #[linkage = "extern_weak"]
        static ryo_test_no_such_symbol: Option<unsafe extern "C" fn() -> i32>;
        #[linkage = "extern_weak"]
        static getpid: Option<unsafe extern "C" fn() -> i32>;
    }

    /// The statics hold the symbols' addresses, null if undefined (std's `weak!`).
    pub fn weak_statics() -> (bool, bool) {
        unsafe { (ryo_test_no_such_symbol.is_none(), getpid.is_some()) }
    }
}

#[cfg(windows)]
mod weak {
    pub fn weak_statics() -> (bool, bool) {
        (true, true)
    }
}

/// `_xgetbv` is `#[inline]` in core, so it is a local copy here, calling the LLVM intrinsic
/// `llvm.x86.xgetbv`, whose name must stay as is.
fn xgetbv_x87() -> u64 {
    #[cfg(target_arch = "x86_64")]
    if std::arch::is_x86_feature_detected!("xsave") {
        // SAFETY: `xsave` is available, and with it XCR0, whose bit 0 (x87 state) is always 1.
        return unsafe { xcr0() } & 1;
    }
    1
}

#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "xsave")]
unsafe fn xcr0() -> u64 {
    unsafe { std::arch::x86_64::_xgetbv(0) }
}

fn main() {
    println!("ctor: {}", FROM_CTOR.load(Ordering::Relaxed));
    println!("unsized: {}", unsized_arg(vec![1, 2, 3, 250].into_boxed_slice()));
    println!("weak: {:?}", weak::weak_statics());
    println!("xgetbv: {}", xgetbv_x87());
}
