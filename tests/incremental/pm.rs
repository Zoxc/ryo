//! A proc macro for `y test incremental`, built with `-Cincremental` at the default number of
//! codegen units (`rustc-ryo` doesn't force one for crates without VM code), as `--cfg rev1`
//! and then `--cfg rev2`, which changes one module; `-Zquery-dep-graph` checks the reuse.

#![feature(rustc_attrs)]
#![allow(internal_features)]
#![cfg_attr(rev2, rustc_partition_reused(module = "pm", cfg = "rev2"))]
#![cfg_attr(rev2, rustc_partition_codegened(module = "pm-value", cfg = "rev2"))]

extern crate proc_macro;
use proc_macro::TokenStream;

mod value {
    #[cfg(not(rev2))]
    pub fn get() -> u32 {
        41
    }
    #[cfg(rev2)]
    pub fn get() -> u32 {
        42
    }
}

#[proc_macro]
pub fn answer(_: TokenStream) -> TokenStream {
    format!("{}u32", value::get()).parse().unwrap()
}
