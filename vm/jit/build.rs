//! Passes the ABI tag (`RYO_ABI`, `dev` without it; design/build.md#the-abi-tag) on to the
//! crate, for its one exported symbol, `ryo_jit_start_<tag>`.

fn main() {
    println!("cargo:rerun-if-env-changed=RYO_ABI");
    println!("cargo:rustc-env=RYO_ABI={}", std::env::var("RYO_ABI").unwrap_or_else(|_| "dev".to_owned()));
}
