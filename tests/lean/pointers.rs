//! References and raw pointers: pointer arithmetic, offset_from, read/write, copy,
//! copy_nonoverlapping, write_bytes, transmute, unions.
#![allow(unnecessary_transmutes)]
include!("common/print.rs");
use std::hint::black_box;
use std::mem::{self, MaybeUninit};
use std::ptr;

union IntOrFloat {
    i: u32,
    f: f32,
}

#[repr(C)]
union Bytes {
    w: u64,
    b: [u8; 8],
    h: (u16, u16, u32),
}

fn bump(x: &mut i32, by: i32) {
    *x += by;
}

fn longest<'a>(a: &'a [u8], b: &'a [u8]) -> &'a [u8] {
    if a.len() >= b.len() { a } else { b }
}

fn main() {
    let mut v = black_box(10);
    bump(&mut v, 5);
    let r = &mut v;
    *r *= 2;
    let rr = &r;
    out::i(**rr as i128);
    out::sp();
    out::u(longest(b"abc", b"de").len() as u128);
    out::nl();
    let mut a = [1u16, 2, 3, 4, 5, 6];
    let p = a.as_mut_ptr();
    unsafe {
        *p.add(2) = 30;
        let q = p.add(5);
        out::i(q.offset_from(p) as i128);
        out::sp();
        out::u(*q.sub(1) as u128);
        out::sp();
        ptr::write(p, 100);
        out::u(ptr::read(p) as u128);
        out::sp();
        ptr::copy(p, p.add(1), 3);
        ptr::copy_nonoverlapping(p.add(4), p, 2);
        ptr::write_bytes(p.add(5), 0xab, 1);
        ptr::swap(p.add(3), p.add(4));
    }
    out::us(&a.map(|x| x as u128));
    let x = black_box(0x3f80_0000u32);
    let f: f32 = unsafe { mem::transmute::<u32, f32>(x) };
    out::hex(f.to_bits() as u128);
    out::sp();
    let arr: [u8; 4] = unsafe { mem::transmute(black_box(0x01020304u32)) };
    out::u(arr[0] as u128);
    out::sp();
    let back: u64 = unsafe { mem::transmute([1u16, 2, 3, 4]) };
    out::hex(back as u128);
    out::nl();
    let mut u = IntOrFloat { i: 0x4049_0fdb };
    let pi = unsafe { u.f };
    u.f = 2.0;
    out::hex(pi.to_bits() as u128);
    out::sp();
    out::hex(unsafe { u.i } as u128);
    out::sp();
    let mut bu = Bytes { w: black_box(0x1122_3344_5566_7788) };
    unsafe {
        bu.b[0] = 0xff;
        out::hex(bu.w as u128);
        out::sp();
        out::hex(bu.h.1 as u128);
        out::sp();
        bu.h.2 = 0;
        out::hex(bu.w as u128);
    }
    out::nl();
    let mut mu = MaybeUninit::<[u32; 3]>::uninit();
    let base = mu.as_mut_ptr() as *mut u32;
    for i in 0..3 {
        unsafe { base.add(i).write(i as u32 * 7) };
    }
    let init = unsafe { mu.assume_init() };
    out::us(&init.map(|x| x as u128));
    let s = black_box("hello world");
    let bytes = s.as_bytes();
    let mid = unsafe { std::slice::from_raw_parts(bytes.as_ptr().add(6), 5) };
    out::bytes(mid);
    out::sp();
    let fat: *const [u8] = mid;
    out::u(unsafe { fat.len() } as u128);
    out::sp();
    let addr = bytes.as_ptr().addr();
    let back = bytes.as_ptr().with_addr(addr + 4);
    out::u(unsafe { *back } as u128);
    out::sp();
    let exposed = bytes.as_ptr().expose_provenance();
    let p2 = ptr::with_exposed_provenance::<u8>(exposed + 1);
    out::u(unsafe { *p2 } as u128);
    out::sp();
    out::b(ptr::eq(bytes.as_ptr(), &bytes[0]));
    out::sp();
    let null: *const u8 = ptr::null();
    out::b(null.is_null());
    out::nl();
}
