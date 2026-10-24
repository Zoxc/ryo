//! Dynamically sized types: structs with slice and `dyn` tails, `Box<[T]>`, `Box<dyn Trait>`
//! in structs, `size_of_val`/`align_of_val`, trait upcasting, `Any` downcasts (type ids).
//! (`Rc<[T]>` and `Rc<dyn Trait>` need `alloc::rc::rc_inner_layout_for_value_layout`, a
//! non-generic std function without MIR.)
include!("common/print.rs");
use std::any::Any;
use std::hint::black_box;
use std::mem;

struct Header<T: ?Sized> {
    tag: u8,
    len: u16,
    data: T,
}

trait Base {
    fn id(&self) -> u32;
}

trait Derived: Base {
    fn twice(&self) -> u32 {
        self.id() * 2
    }
}

struct Thing(u32, u64);

impl Base for Thing {
    fn id(&self) -> u32 {
        self.0
    }
}

impl Derived for Thing {}

fn total(h: &Header<[u32]>) -> u32 {
    h.data.iter().sum::<u32>() + h.tag as u32 + h.len as u32
}

fn as_base(d: &dyn Derived) -> &dyn Base {
    d
}

fn describe(x: &dyn Any) -> u32 {
    if let Some(i) = x.downcast_ref::<u32>() {
        *i
    } else if let Some(s) = x.downcast_ref::<&str>() {
        s.len() as u32 + 1000
    } else {
        7
    }
}

fn main() {
    let h: Header<[u32; 4]> = Header { tag: 1, len: 2, data: [10, 20, 30, black_box(40)] };
    let d: &Header<[u32]> = &h;
    out::us(&[total(d) as u128, d.data.len() as u128, mem::size_of_val(d) as u128, mem::align_of_val(d) as u128]);
    let bx: Box<Header<dyn Derived>> = Box::new(Header { tag: 3, len: 4, data: Thing(black_box(21), 5) });
    out::us(&[bx.data.twice() as u128, bx.tag as u128, mem::size_of_val(&*bx) as u128, mem::align_of_val(&bx.data) as u128]);
    let b: &dyn Base = as_base(&bx.data);
    out::u(b.id() as u128);
    out::nl();
    let bs16: Box<[u16]> = Box::new([5u16, 6, 7]);
    let v16 = bs16.into_vec();
    out::us(&[v16.iter().map(|&x| x as u128).sum(), v16.len() as u128]);
    struct Holder {
        inner: Box<dyn Derived>,
        extra: [u8; 3],
    }
    let hd = Holder { inner: Box::new(Thing(9, 9)), extra: [1, 2, 3] };
    out::us(&[hd.inner.twice() as u128, hd.extra[2] as u128, mem::size_of_val(&*hd.inner) as u128]);
    let items: [&dyn Any; 3] = [&5u32, &"hello", &1.5f64];
    for it in items {
        out::u(describe(it) as u128);
        out::sp();
    }
    let bs: Box<str> = "boxed str".into();
    out::str(&bs);
    out::sp();
    let s: &str = &bs[6..];
    out::str(s);
    out::nl();
}
