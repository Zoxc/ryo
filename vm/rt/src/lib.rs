//! The ryo runtime: the VM, the registry, and the island templates. See
//! design/vm.md and design/stubs.md.

#![feature(rustc_attrs, unboxed_closures, fn_traits, tuple_trait, core_intrinsics, f16, f128, macro_metavar_expr, macro_metavar_expr_concat)]
// `handlers.rs`'s `fam` entries expand one member (and one ordering) per step.
#![recursion_limit = "4096"]
#![allow(internal_features)]
// Only `core`: with `--sysroot ryo`, std and alloc are ryo-built and depend on `ryo_rt`
// (design/build.md), and the runtime must not enter the VM through them (design/vm.md).
#![cfg_attr(not(test), no_std)]

// The unit tests: the JIT's `ryo_jit_start_<tag>`, which the trips
// reference (link.exe resolves the references of unused functions too).
#[cfg(test)]
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

/// `.seh_savexmm xmm<r>, <off>` on Windows, as a template piece of `naked_asm!`; empty
/// elsewhere.
#[cfg(windows)]
macro_rules! seh_savexmm {
    ($r:literal, $off:literal) => {
        concat!(".seh_savexmm xmm", $r, ", ", $off, "\n")
    };
}
#[cfg(not(windows))]
macro_rules! seh_savexmm {
    ($r:literal, $off:literal) => {
        ""
    };
}
/// Saves `xmm<r>` to `[rsp + off]` for each `r off` (`movaps`, so 16-aligned), each with
/// its `.seh_savexmm` on Windows, as a template piece of `naked_asm!`.
macro_rules! save_xmm {
    ($($r:literal $off:literal),*) => {
        concat!($("movaps [rsp + ", $off, "], xmm", $r, "\n", seh_savexmm!($r, $off)),*)
    };
}
/// [`save_xmm`]'s restore.
macro_rules! restore_xmm {
    ($($r:literal $off:literal),*) => {
        concat!($("movaps xmm", $r, ", [rsp + ", $off, "]\n"),*)
    };
}
/// The Win64 callee-saved `xmm6`–`xmm15` at `[rsp]`..`[rsp + 160]`: `save` (with the SEH
/// directives on Windows) or `restore`.
#[cfg(any(windows, feature = "pe-test"))]
macro_rules! xmm6_15 {
    ($m:ident) => {
        $m!(6 0, 7 16, 8 32, 9 48, 10 64, 11 80, 12 96, 13 112, 14 128, 15 144)
    };
}

// `tagged!` (the ABI-tagged entry-point names), in every module.
#[macro_use(tagged)]
extern crate ryo_bytecode;

pub mod entry;
pub mod island;
pub mod vm;
