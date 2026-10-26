//! One-past-the-end pointers into escaped stack objects: compared, subtracted, stepped back
//! from (the JIT's SSA tier must keep them with their object, whatever the frame layout).
use std::hint::black_box;
use std::ptr;

#[repr(C)]
struct Tail {
    a: u32,
    b: u16,
    z: [u8; 0],
}

#[repr(C)]
struct TailUnit {
    x: u64,
    u: (),
}

#[inline(never)]
fn ranges() {
    let mut arr = [1u32, 2, 3, 4, 5];
    let mut other = [9u8; 3];
    black_box(&mut other);
    let r = arr.as_ptr_range();
    let n = unsafe { r.end.offset_from(r.start) };
    let last = unsafe { *r.end.sub(1) };
    println!("{n} {last} {}", r.end == unsafe { r.start.add(5) });
    let m = arr.as_mut_ptr_range();
    unsafe { *m.end.sub(2) = 40 };
    black_box(&mut arr);
    println!("{:?} {:?}", arr, other);
}

#[inline(never)]
fn iters() {
    let arr = [7u16, 8, 9];
    let mut it = black_box(arr.iter());
    let back = it.next_back().copied();
    let len = it.len();
    let s = arr.as_slice();
    let end = s.as_ptr().wrapping_add(s.len());
    println!("{back:?} {len} {}", end == s.as_ptr_range().end);
}

#[inline(never)]
fn zst_tail() {
    let t = Tail { a: black_box(0x1122_3344), b: black_box(0x5566), z: [] };
    let tp = &t as *const Tail as *const u8;
    let zp = ptr::addr_of!(t.z) as *const u8;
    let off = unsafe { zp.offset_from(tp) };
    let b = unsafe { (zp.sub(2) as *const u16).read_unaligned() };
    println!("{off} {b:x} {} {}", zp == unsafe { tp.add(6) }, t.a);
    let u = TailUnit { x: black_box(0xabcd), u: () };
    let up = ptr::addr_of!(u.u) as *const u8;
    let base = &u as *const TailUnit as *const u8;
    let x = unsafe { (up.sub(8) as *const u64).read() };
    println!("{} {x:x} {}", unsafe { up.offset_from(base) }, up == unsafe { base.add(8) });
}

#[inline(never)]
fn neighbors() {
    let a = [1u8, 2, 3, 4];
    let b = [5u8, 6, 7, 8];
    let ae = a.as_ptr_range().end;
    let be = b.as_ptr_range().end;
    let sa = unsafe { *ae.sub(1) } + unsafe { *ae.sub(4) };
    let sb = unsafe { *be.sub(1) } + unsafe { *be.sub(4) };
    println!("{sa} {sb} {} {}", unsafe { ae.offset_from(a.as_ptr()) }, unsafe { be.offset_from(b.as_ptr()) });
}

fn main() {
    ranges();
    iters();
    zst_tail();
    neighbors();
}
