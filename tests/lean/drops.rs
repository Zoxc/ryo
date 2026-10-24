//! Drop impls and drop order: locals, fields, temporaries, moves, `mem::forget`,
//! `ManuallyDrop`, early returns, `Vec` elements, `Option::take`.
include!("common/print.rs");
use std::hint::black_box;
use std::mem::{self, ManuallyDrop};

static mut LOG: [u8; 64] = [0; 64];
static mut LEN: usize = 0;

fn log(c: u8) {
    unsafe {
        LOG[LEN] = c;
        LEN += 1;
    }
}

struct D(u8);

impl Drop for D {
    fn drop(&mut self) {
        log(self.0);
    }
}

struct Pair {
    _a: D,
    _b: D,
}

struct Outer {
    _p: Pair,
    _c: D,
}

fn early(x: bool) -> u8 {
    let _g = D(b'g');
    if x {
        return 1;
    }
    let _h = D(b'h');
    2
}

fn make(c: u8) -> D {
    D(c)
}

fn main() {
    {
        let _x = D(b'x');
        let _y = D(b'y');
    }
    log(b'|');
    {
        let _o = Outer { _p: Pair { _a: D(b'a'), _b: D(b'b') }, _c: D(b'c') };
    }
    log(b'|');
    {
        let a = D(b'm');
        let b = a;
        log(b'.');
        drop(b);
        log(b'.');
    }
    log(b'|');
    mem::forget(D(b'F'));
    let mut md = ManuallyDrop::new(D(b'M'));
    log(b'.');
    unsafe { ManuallyDrop::drop(&mut md) };
    log(b'|');
    early(black_box(true));
    early(black_box(false));
    log(b'|');
    make(b't');
    let _kept = make(b'k');
    log(b'|');
    {
        let v = vec![D(b'1'), D(b'2'), D(b'3')];
        let mut v = v;
        v.remove(1);
        log(b'.');
    }
    log(b'|');
    let mut o = Some(D(b'o'));
    let t = o.take();
    log(b'.');
    drop(t);
    log(b'.');
    o = Some(D(b'p'));
    log(b'.');
    o = None;
    log(b'|');
    out::b(o.is_none());
    let b: Box<[D]> = vec![D(b'B'), D(b'C')].into_boxed_slice();
    drop(b);
    log(b'|');
    unsafe {
        let n = LEN;
        let p = &raw const LOG;
        out::bytes(&(&*p)[..n]);
    }
    out::nl();
}
