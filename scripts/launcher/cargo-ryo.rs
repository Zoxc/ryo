//! The `cargo-ryo` launcher (`launcher.rs`).

#[path = "../launcher.rs"]
mod launcher;

fn main() {
    launcher::run("cargo-ryo")
}
