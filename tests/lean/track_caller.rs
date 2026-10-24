//! `#[track_caller]`: caller locations through direct calls, nested track_caller functions,
//! methods and fn pointers (reify shims).
include!("common/print.rs");
use std::panic::Location;

#[track_caller]
fn here() -> &'static Location<'static> {
    Location::caller()
}

#[track_caller]
fn outer() -> &'static Location<'static> {
    here()
}

struct S;

impl S {
    #[track_caller]
    fn at(&self) -> (u32, u32) {
        let l = Location::caller();
        (l.line(), l.column())
    }
}

fn show(l: &Location) {
    out::u(l.line() as u128);
    out::str(":");
    out::u(l.column() as u128);
    out::sp();
}

fn main() {
    show(here());
    show(outer());
    let (line, col) = S.at();
    out::u(line as u128);
    out::str(":");
    out::u(col as u128);
    out::sp();
    let f: fn() -> &'static Location<'static> = here;
    show(f());
    let l = here();
    let file = l.file();
    out::b(file.ends_with("track_caller.rs"));
    out::nl();
}
