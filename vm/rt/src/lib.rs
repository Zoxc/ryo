//! The ryo runtime: the VM, the registry, and the island templates. See
//! design/vm.md and design/stubs.md.

#![feature(rustc_attrs, unboxed_closures, fn_traits, tuple_trait, core_intrinsics, f16, f128)]
#![cfg_attr(feature = "jit", feature(thread_local))]
#![allow(internal_features)]
// Only `core`: with `--sysroot ryo`, std and alloc are ryo-built and depend on `ryo_rt`
// (design/build.md), and the runtime must not enter the VM through them (design/vm.md).
#![cfg_attr(not(test), no_std)]

// The JIT thread (design/vm.md, "JIT"), which uses std: linked for its `ryo_jit_start`,
// which the trips call. `y build` enables it for the native sysroot only.
#[cfg(all(feature = "jit", target_os = "linux"))]
extern crate ryo_jit;

pub mod entry;
pub mod island;
pub mod vm;

/// The runtime ABI version. The backend checks it and errors on a mismatch.
#[rustc_diagnostic_item = "ryo_rt_abi"]
pub const RYO_RT_ABI: u32 = 6;
