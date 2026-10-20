//! A nonzero exit code from `process::exit`, after output on both streams.
use std::io::Write;

fn main() {
    println!("to stdout");
    eprintln!("to stderr");
    std::io::stdout().flush().unwrap();
    std::process::exit(42);
}
