//! Lowerings of ops with constant operands into inline ops: exact division by constants
//! (`ptr_offset_from`, `exact_div`), division by 1 and -1, small unsigned division by
//! constants, constant rotates, constant-length copies and sets, `bswap` of a byte.
#![feature(core_intrinsics)]
#![allow(internal_features)]
use std::hint::black_box;
use std::intrinsics;

#[inline(never)]
fn offsets() {
    let a = [0u32; 10];
    let b = [[0u8; 24]; 5];
    let c = [0u128; 4];
    let p = &a[7] as *const u32;
    let q = &b[4] as *const [u8; 24];
    let r = &c[3] as *const u128;
    unsafe {
        println!("{} {}", p.offset_from(a.as_ptr()), a.as_ptr().offset_from(p));
        println!("{} {}", q.offset_from(b.as_ptr()), b.as_ptr().offset_from(q));
        println!("{} {}", q.offset_from_unsigned(b.as_ptr()), r.offset_from_unsigned(c.as_ptr()));
        let s = &a[1..black_box(9)];
        println!("{}", s.iter().len());
    }
    let xs: [i64; 6] = black_box([0, 24, -24, 48 * 1001, i64::MIN + 8, -7 * 3]);
    for x in xs {
        // Only exact quotients: `exact_div` is UB otherwise.
        unsafe {
            print!("{} {} ", intrinsics::exact_div(x, 1), intrinsics::exact_div(x, -1));
            if x % 8 == 0 {
                print!("{} ", intrinsics::exact_div(x, 8));
            }
            if x % 3 == 0 {
                print!("{} {} ", intrinsics::exact_div(x, 3), intrinsics::exact_div(x, -3));
            }
            if x % 24 == 0 {
                print!("{} ", intrinsics::exact_div(x, -24));
            }
            if (x as u64) % 24 == 0 {
                print!("{} ", intrinsics::exact_div(x as u64, 24));
            }
        }
    }
    println!();
    let ys: [i8; 4] = black_box([-128, 0, 64, -42]);
    for y in ys {
        unsafe {
            print!("{} ", intrinsics::exact_div(y, 2));
            if y % -128 == 0 {
                print!("{} ", intrinsics::exact_div(y, -128));
            }
            if y % 21 == 0 {
                print!("{} ", intrinsics::exact_div(y, 21));
            }
            if (y as u8) % 21 == 0 {
                print!("{} ", intrinsics::exact_div(y as u8, 21));
            }
        }
    }
    println!();
}

#[inline(never)]
fn by_one() {
    let xs: [i32; 4] = black_box([i32::MIN + 1, -5, 0, i32::MAX]);
    for x in xs {
        print!("{} {} {} {} ", x / 1, x % 1, x / -1, x % -1);
        let u = x as u16;
        print!("{} {} ", u / 1, u % 1);
    }
    println!();
}

#[inline(never)]
fn small_div() {
    let xs: [u32; 6] = black_box([0, 1, 999, 1000, 123_456_789, u32::MAX]);
    for x in xs {
        print!("{} {} {} {} {} {} ", x / 1000, x % 1000, x / 5003, x % 5003, x / 7, x % 7);
        print!("{} {} ", x / 0xffff_fffe, x % 0x8000_0001);
        let h = x as u16;
        print!("{} {} {} ", h / 3, h % 10, h / 65535);
        let b = x as u8;
        print!("{} {} {} ", b / 3, b % 7, b / 255);
    }
    println!();
}

#[inline(never)]
fn rotates() {
    let x: u64 = black_box(0x0123_4567_89ab_cdef);
    println!("{:x} {:x} {:x} {:x} {:x}", x.rotate_left(13), x.rotate_right(17), x.rotate_left(0), x.rotate_left(64), x.rotate_right(100));
    let y: u32 = black_box(0xdead_beef);
    println!("{:x} {:x} {:x}", y.rotate_left(7), y.rotate_right(31), y.rotate_left(33));
    let z: u16 = black_box(0xbeef);
    let b: u8 = black_box(0xa5);
    println!("{:x} {:x} {:x} {:x}", z.rotate_left(8), z.rotate_right(3), b.rotate_left(1), b.rotate_right(9));
    let n = black_box(5);
    println!("{:x}", x.rotate_left(n));
    println!("{:x} {:x}", b.swap_bytes(), (black_box(-3i8)).swap_bytes());
}

#[derive(Clone, Copy, Debug)]
struct Pair {
    a: u32,
    b: u16,
    c: u8,
}

#[inline(never)]
fn copies() {
    let mut v: [u32; 8] = black_box([1, 2, 3, 4, 5, 6, 7, 8]);
    unsafe {
        let p = v.as_mut_ptr();
        std::ptr::copy_nonoverlapping(p.add(1), p.add(6), 1);
        std::ptr::copy_nonoverlapping(p, p.add(4), 2);
        std::ptr::copy(p, p.add(1), 4);
        std::ptr::copy(p.add(3), p.add(2), 3);
        std::ptr::copy_nonoverlapping(p, p, 0);
    }
    println!("{v:?}");
    let mut bytes = [0u8; 40];
    let k = black_box(0x5a);
    unsafe {
        let p = bytes.as_mut_ptr();
        std::ptr::write_bytes(p, 0xc3, 13);
        std::ptr::write_bytes(p.add(13), k, 27);
        std::ptr::write_bytes(p.add(20), 0, 3);
        std::ptr::copy(p, p.add(3), 30);
    }
    println!("{bytes:?}");
    let mut ps = black_box([Pair { a: 1, b: 2, c: 3 }, Pair { a: 4, b: 5, c: 6 }]);
    ps.swap(0, 1);
    let (x, y) = ps.split_at_mut(1);
    std::mem::swap(&mut x[0], &mut y[0]);
    println!("{ps:?}");
    let mut big = black_box([[7u64; 6]; 2]);
    big[0][2] = 9;
    big.swap(0, 1);
    println!("{big:?}");
    let mut arr = black_box([0u8; 64]);
    arr[3..].fill(9);
    let mut w = [1u16; 20];
    w.fill(black_box(0x0102));
    println!("{arr:?} {w:?}");
}

fn main() {
    offsets();
    by_one();
    small_div();
    rotates();
    copies();
}
