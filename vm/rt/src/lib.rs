//! The ryo runtime: the VM, the registry, and the island templates. See
//! design/vm.md and design/stubs.md.

#![feature(rustc_attrs, unboxed_closures, fn_traits, tuple_trait, core_intrinsics, f16, f128)]
#![allow(internal_features)]
// Only `core`: with `--sysroot ryo`, std and alloc are ryo-built and depend on `ryo_rt`
// (design/build.md), and the runtime must not enter the VM through them (design/vm.md).
#![cfg_attr(not(test), no_std)]

pub mod entry;
pub mod island;
pub mod vm;
