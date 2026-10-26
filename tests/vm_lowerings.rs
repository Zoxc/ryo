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

/// Division, remainder, shifts by a variable and the unsigned 64-bit overflowing `mul` at
/// every width, with other values live across them: the SSA tier's fixed registers
/// (`rax`/`rdx`, `cl`).
#[inline(never)]
fn fixed_regs() {
    macro_rules! ops {
        ($($t:ty),*) => {$({
            let xs: [$t; 6] = black_box([<$t>::MAX, <$t>::MIN, 7, 100, 3, 0 as $t]);
            let ys: [$t; 5] = black_box([1, 2, 3, 9, <$t>::MAX]);
            let mut acc: $t = 0;
            for (k, &x) in xs.iter().enumerate() {
                for &y in &ys {
                    let (a, b, c) = (x ^ acc, y.wrapping_add(k as $t), acc.wrapping_mul(3));
                    let q = if b != 0 && !(b == (0 as $t).wrapping_sub(1) && a == <$t>::MIN) { a / b } else { 0 };
                    let r = if b != 0 && !(b == (0 as $t).wrapping_sub(1) && a == <$t>::MIN) { a % b } else { 0 };
                    let s = y as u32;
                    let l = a.wrapping_shl(s) ^ a.wrapping_shr(s ^ 5) ^ c.wrapping_shl(k as u32);
                    acc = acc.wrapping_add(q ^ r ^ l ^ a ^ b ^ c);
                }
            }
            print!("{} ", acc);
        })*};
    }
    ops!(u8, i8, u16, i16, u32, i32, u64, i64, usize);
    let xs: [u64; 4] = black_box([3, u64::MAX, 1 << 40, 12345]);
    let mut acc = 0u64;
    for &x in &xs {
        for &y in &xs {
            let keep = x ^ y;
            let (p, o) = x.overflowing_mul(y);
            acc = acc.wrapping_add(p ^ keep ^ o as u64);
        }
    }
    println!("{acc}");
}

#[inline(never)]
fn wide(a: u32, b: u16, c: u8) -> u64 {
    a as u64 * 3 + b as u64 * 5 + c as u64
}

/// Narrow values whose upper bits the SSA tier knows are zero (4-byte ops, narrow loads,
/// zero extensions) as call arguments, return values and widened, and ones it doesn't
/// (sign-extending shifts, block parameters).
#[inline(never)]
fn known_zero() -> u32 {
    let xs: [u32; 4] = black_box([u32::MAX, 7, 1 << 31, 0x8000_0001]);
    let bs: [u8; 3] = black_box([0xff, 0x80, 1]);
    let mut acc = 0u64;
    let mut last = 0u32;
    for (k, &x) in xs.iter().enumerate() {
        let y = x.wrapping_add(x);
        let b = bs[k % 3];
        let s = (b as i8 >> 1) as u8;
        acc = acc.wrapping_add(wide(y, (y >> 3) as u16, s)).wrapping_add(y as u64).wrapping_add(b as u64);
        acc ^= wide(last, b as u16, (x as u8).wrapping_mul(3)) << 7;
        last = if y > 9 { y } else { x };
    }
    println!("{acc}");
    last.wrapping_mul(5)
}

/// Compares against 0 at each width, signed and not (`test`), and three-operand adds and
/// subtractions (`lea`, which must leave 32-bit results zero-extended).
#[inline(never)]
fn forms() {
    macro_rules! zero {
        ($($t:ty),*) => {$({
            let xs: [$t; 4] = black_box([0, 1, <$t>::MAX, <$t>::MIN]);
            let mut n = 0u32;
            for &x in &xs {
                n = n.wrapping_mul(2).wrapping_add((x < 0 as $t) as u32);
                n = n.wrapping_mul(2).wrapping_add((x > 0 as $t) as u32);
                n = n.wrapping_mul(2).wrapping_add((x <= 0 as $t) as u32);
                n = n.wrapping_mul(2).wrapping_add((x == 0 as $t) as u32);
                let y = x.wrapping_add(5);
                let z = x.wrapping_sub(7);
                n = n.wrapping_mul(3) ^ (y as u64).wrapping_add(z as u64).wrapping_add(x as u64) as u32;
                if (y as u64) >> 40 != 0 && size_of::<$t>() < 8 { n = n.wrapping_add(1000) }
            }
            print!("{n} ");
        })*};
    }
    zero!(u8, i8, u16, i16, u32, i32, u64, i64);
    println!();
}

/// Leaves: no frame (the stack arguments read from `rsp`), and a frame without the 16-byte
/// alignment (one pushed register, spills).
#[inline(never)]
fn leaf_args(a: u64, b: u64, c: u64, d: u64, e: u64, f: u64, g: u64, h: u32) -> u64 {
    a ^ b.wrapping_mul(3) ^ c << 2 ^ d >> 1 ^ e ^ f.wrapping_add(g) ^ h as u64
}

#[inline(never)]
fn leaf_heavy(xs: &[u64; 16]) -> u64 {
    let v: [u64; 16] = core::array::from_fn(|k| xs[k].wrapping_mul(k as u64 + 1));
    let mut acc = 0u64;
    for k in 0..16 {
        acc = acc.rotate_left(5) ^ v[k] ^ v[15 - k].wrapping_add(v[(k * 7) % 16]);
    }
    acc ^ v.iter().fold(0, |s, &x| s ^ x)
}

#[inline(never)]
fn bump(xs: &mut [u64; 4], k: usize) -> u64 {
    xs[k % 4] = xs[k % 4].wrapping_mul(31).wrapping_add(k as u64);
    xs[(k + 1) % 4]
}

/// Addresses of locals and statics live across calls: recomputed after each call
/// (rematerialized), not kept in callee-saved registers.
#[inline(never)]
fn remat() -> u64 {
    static S: [u8; 3] = [9, 8, 7];
    let mut xs = [1u64, 2, 3, 4];
    let mut acc = 0;
    for k in 0..black_box(10) {
        acc ^= bump(&mut xs, k);
        acc = acc.wrapping_add(black_box(&S)[k % 3] as u64);
        acc ^= bump(&mut xs, k + 2) << 1;
    }
    acc ^ xs.iter().sum::<u64>()
}

fn main() {
    println!("{}", remat());
    println!("{} {}", leaf_args(1, 2, 3, 4, 5, 6, black_box(7), black_box(8)), leaf_heavy(&black_box(core::array::from_fn(|k| k as u64 * 0x9e37_79b9))));
    offsets();
    forms();
    fixed_regs();
    println!("{}", known_zero());
    by_one();
    small_div();
    rotates();
    copies();
}
