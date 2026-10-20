//! Selects the VM dispatch strategy (design/vm.md, "Dispatch") from the cargo features and
//! sets one of the cfgs `ryo_dispatch_tail` (the default), `ryo_dispatch_loop_match` or
//! `ryo_dispatch_match`. If several features are on, `dispatch-match` wins over
//! `dispatch-loop-match`.

fn main() {
    for s in ["tail", "loop_match", "match"] {
        println!("cargo::rustc-check-cfg=cfg(ryo_dispatch_{s})");
    }
    let on = |f: &str| std::env::var_os(format!("CARGO_FEATURE_{f}")).is_some();
    let s = if on("DISPATCH_MATCH") {
        "match"
    } else if on("DISPATCH_LOOP_MATCH") {
        "loop_match"
    } else {
        "tail"
    };
    println!("cargo::rustc-cfg=ryo_dispatch_{s}");
}
