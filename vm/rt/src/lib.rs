//! The ryo runtime: the VM, the registry, and the island templates. See
//! design/vm.md and design/stubs.md.

#![feature(rustc_attrs, unboxed_closures, fn_traits, tuple_trait, core_intrinsics, f16, f128, macro_metavar_expr_concat)]
// `handlers.rs`'s `fam` entries expand one member (and one ordering) per step.
#![recursion_limit = "4096"]
#![allow(internal_features)]
// Only `core`: with `--sysroot ryo`, std and alloc are ryo-built and depend on `ryo_rt`
// (design/build.md), and the runtime must not enter the VM through them (design/vm.md).
#![cfg_attr(not(test), no_std)]

// The unit tests with the `jit` feature: the JIT's `ryo_jit_start_<tag>`, which the trips
// reference (link.exe resolves the references of unused functions too).
#[cfg(all(test, feature = "jit"))]
extern crate ryo_jit;

/// Unwind directives of a naked function for Windows only (`.seh_*`: its `.pdata`/`.xdata`
/// entry, without which the unwinder takes the function for a leaf), one per argument, as a
/// template piece of `naked_asm!`; empty elsewhere.
#[cfg(windows)]
macro_rules! seh {
    ($($s:literal),*) => { concat!($($s, "\n"),*) };
}
#[cfg(not(windows))]
macro_rules! seh {
    ($($s:literal),*) => {
        ""
    };
}
/// [`seh`]'s counterpart: DWARF CFI directives, for everything but Windows.
#[cfg(not(windows))]
macro_rules! cfi {
    ($($s:literal),*) => { concat!($($s, "\n"),*) };
}
#[cfg(windows)]
macro_rules! cfi {
    ($($s:literal),*) => {
        ""
    };
}

/// `$name` with the ABI tag as a suffix, `<name>_<tag>`: the symbol names of the runtime's
/// entry points, so that two ryo builds' runtimes never share a name
/// (design/build.md#the-abi-tag, `ryo_bytecode::ABI_TAG`).
macro_rules! tagged {
    ($name:expr) => {
        concat!($name, "_", env!("RYO_ABI"))
    };
}

pub mod entry;
pub mod island;
pub mod vm;
