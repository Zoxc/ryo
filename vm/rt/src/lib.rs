//! The ryo runtime: the VM, the registry, the portal and island templates, and the panic glue.
//! See design/vm.md and design/stubs.md.

#![feature(rustc_attrs, unboxed_closures, fn_traits, tuple_trait, core_intrinsics, thread_local)]
#![allow(internal_features)]
// The dispatch strategy (build.rs): tail-call handlers or `#[loop_match]`. Both features are
// `incomplete`, which is why the plain `match` stays built and tested (design/vm.md).
#![cfg_attr(ryo_dispatch_tail, feature(explicit_tail_calls, rust_preserve_none_cc))]
#![cfg_attr(ryo_dispatch_loop_match, feature(loop_match))]
#![cfg_attr(any(ryo_dispatch_tail, ryo_dispatch_loop_match), allow(incomplete_features))]

pub mod entry;
pub mod island;
pub mod portal;
pub mod unwind;
pub mod vm;

/// The runtime ABI version. The backend checks it and errors on a mismatch.
pub const RYO_RT_ABI: u32 = 1;
