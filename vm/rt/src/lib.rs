//! The ryo runtime: the VM, the registry, the portal and island templates, and the panic glue.
//! See design/vm.md and design/stubs.md.

#![feature(rustc_attrs, unboxed_closures, fn_traits, tuple_trait, core_intrinsics, thread_local)]
#![allow(internal_features)]

pub mod entry;
pub mod island;
pub mod portal;
pub mod unwind;
pub mod vm;

/// The runtime ABI version. The backend checks it and errors on a mismatch.
pub const RYO_RT_ABI: u32 = 1;
