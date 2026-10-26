//! SIMD: the portable `simd_*` intrinsics at 16 × i8/u8 as VM instructions (`vsplat`, `veq`,
//! `vlt.s`, `vmsb`, and `and`/`or`/`xor.w128`), the SSE2 `_mm_*` functions built on them, and
//! `#[target_feature]` functions: VM code when every feature is enabled for the crate and the
//! body maps, native otherwise.
#![feature(core_intrinsics, portable_simd, link_llvm_intrinsics, abi_unadjusted, simd_ffi)]
#![allow(internal_features, improper_ctypes)]
use std::arch::x86_64::*;
use std::collections::{HashMap, HashSet};
use std::hint::black_box;
use std::intrinsics::simd;
use std::simd::prelude::*;
use std::sync::atomic::{AtomicPtr, Ordering};

fn m(x: [u8; 16]) -> __m128i {
    unsafe { std::mem::transmute(x) }
}

fn b(x: __m128i) -> [u8; 16] {
    unsafe { std::mem::transmute(x) }
}

/// Inputs: edge lanes and a pseudo-random sweep.
fn vectors() -> Vec<[u8; 16]> {
    const EDGES: [u8; 7] = [0x00, 0x01, 0x7f, 0x80, 0x81, 0xfe, 0xff];
    let mut v = Vec::new();
    for (k, &e) in EDGES.iter().enumerate() {
        let mut x = [EDGES[(k + 2) % 7]; 16];
        x[k * 2] = e;
        x[15 - k] = e;
        v.push(x);
    }
    let mut s = 0x2545_f491_4f6c_dd1du64;
    for _ in 0..24 {
        let mut x = [0; 16];
        for c in x.chunks_mut(8) {
            s ^= s << 13;
            s ^= s >> 7;
            s ^= s << 17;
            c.copy_from_slice(&s.to_le_bytes());
        }
        v.push(x);
    }
    v
}

/// A checksum of a byte array, so the output stays short.
fn h(x: &[u8]) -> u64 {
    x.iter().fold(0xcbf2_9ce4_8422_2325u64, |a, &c| (a ^ c as u64).wrapping_mul(0x100_0000_01b3))
}

#[inline(never)]
fn sse2_fns() {
    let vs = vectors();
    let mut acc = 0u64;
    for (i, &x) in vs.iter().enumerate() {
        let y = vs[(i * 5 + 3) % vs.len()];
        unsafe {
            let (a, c) = (m(x), m(y));
            let r = [
                b(_mm_cmpeq_epi8(a, c)),
                b(_mm_cmpeq_epi8(a, a)),
                b(_mm_cmpgt_epi8(a, c)),
                b(_mm_cmplt_epi8(a, c)),
                b(_mm_and_si128(a, c)),
                b(_mm_or_si128(a, c)),
                b(_mm_xor_si128(a, c)),
                b(_mm_andnot_si128(a, c)),
                b(_mm_set1_epi8(x[i % 16] as i8)),
                b(_mm_setzero_si128()),
            ];
            for v in r {
                acc = acc.rotate_left(5) ^ h(&v);
            }
            // Any bytes, not only masks.
            acc = acc.rotate_left(5) ^ _mm_movemask_epi8(a) as u32 as u64;
            acc = acc.rotate_left(5) ^ _mm_movemask_epi8(_mm_cmpgt_epi8(a, c)) as u32 as u64;
        }
    }
    println!("sse2 fns: {acc:#x}");
    let x = vs[3];
    unsafe {
        println!("movemask {:#06x} {:#06x}", _mm_movemask_epi8(m(x)), _mm_movemask_epi8(m(vs[10])));
        println!("cmpgt {:x?}", b(_mm_cmpgt_epi8(m(x), m(vs[1]))));
    }
}

#[inline(never)]
fn loads_stores() {
    let buf: Vec<u8> = (0..64u32).map(|i| (i * 37 + 11) as u8).collect();
    let mut acc = 0u64;
    for off in 0..16 {
        let v = unsafe { _mm_loadu_si128(buf.as_ptr().add(off).cast()) };
        acc = acc.rotate_left(7) ^ h(&b(v));
    }
    #[repr(align(16))]
    struct A([u8; 32]);
    let mut a = A([0; 32]);
    unsafe {
        let v = _mm_loadu_si128(buf.as_ptr().add(5).cast());
        _mm_store_si128(a.0.as_mut_ptr().add(16).cast(), v);
        let w = _mm_load_si128(a.0.as_ptr().add(16).cast());
        acc ^= h(&b(w));
    }
    println!("loads {acc:#x} {:x?}", &a.0[16..]);
}

/// The intrinsics directly, on portable vectors.
#[inline(never)]
fn direct() {
    let vs = vectors();
    let mut acc = 0u64;
    for (i, &x) in vs.iter().enumerate() {
        let y = vs[(i * 3 + 1) % vs.len()];
        let (ux, uy) = (u8x16::from_array(x), u8x16::from_array(y));
        let (sx, sy) = (ux.cast::<i8>(), uy.cast::<i8>());
        unsafe {
            let eq: i8x16 = simd::simd_eq(ux, uy);
            let lt: i8x16 = simd::simd_lt(sx, sy);
            let gt: i8x16 = simd::simd_gt(sx, sy);
            // No unsigned compare in SSE2: an island.
            let ult: i8x16 = simd::simd_lt(ux, uy);
            let sp: u8x16 = simd::simd_splat(x[i % 16]);
            let and: u8x16 = simd::simd_and(ux, uy);
            let or: i8x16 = simd::simd_or(sx, sy);
            let xor: u16x8 = simd::simd_xor(u16x8::from_array(std::mem::transmute(x)), u16x8::from_array(std::mem::transmute(y)));
            let mask: u16 = simd::simd_bitmask(lt);
            let mask2: u16 = simd::simd_bitmask(eq);
            let mask3: [u8; 2] = simd::simd_bitmask(gt);
            for v in [eq, lt, gt, ult, or] {
                acc = acc.rotate_left(5) ^ h(&v.cast::<u8>().to_array());
            }
            acc = acc.rotate_left(5) ^ h(&sp.to_array()) ^ h(&and.to_array()).rotate_left(1) ^ h(&xor.to_array().map(|v| v as u8));
            acc = acc.rotate_left(5) ^ (mask as u64) << 32 ^ (mask2 as u64) << 16 ^ u16::from_le_bytes(mask3) as u64;
        }
    }
    println!("direct: {acc:#x}");
    // `simd_gt(a, b)` is `vlt.s(b, a)`.
    let a = i8x16::from_array([-128, -1, 0, 1, 127, 5, 5, -5, 0, 0, 0, 0, 0, 0, 0, 0]);
    let c = i8x16::from_array([127, 0, -1, 1, -128, 4, 6, -5, 0, 1, -1, 0, 0, 0, 0, 0]);
    let gt: i8x16 = unsafe { simd::simd_gt(a, c) };
    let lt: i8x16 = unsafe { simd::simd_lt(a, c) };
    println!("gt {:?}\nlt {:?}", gt.to_array(), lt.to_array());
    println!("portable {:?} {:#x}", u8x16::splat(black_box(7)).simd_eq(u8x16::from_array(vs[2])).to_array(), u8x16::splat(black_box(0x81)).simd_eq(u8x16::from_array(vs[4])).to_bitmask());
}

/// Vectors in slots across calls and loop iterations.
#[inline(never)]
fn live_across() -> u32 {
    let mut acc = unsafe { _mm_setzero_si128() };
    let mut n = 0u32;
    for i in 0..200u32 {
        let t = unsafe { _mm_set1_epi8(black_box(i as i8)) };
        let x = black_box(t);
        acc = unsafe { _mm_xor_si128(acc, _mm_cmpgt_epi8(x, acc)) };
        n = n.wrapping_add(unsafe { _mm_movemask_epi8(acc) } as u32);
        black_box(&acc);
    }
    n ^ unsafe { _mm_movemask_epi8(_mm_cmpeq_epi8(acc, t_of(acc))) } as u32
}

#[inline(never)]
fn t_of(x: __m128i) -> __m128i {
    unsafe { _mm_or_si128(x, _mm_set1_epi8(1)) }
}

/// A hashbrown-style probe: 16 control bytes per group, match the tag, then the empty slots.
#[inline(never)]
fn probe(ctrl: &[u8], tag: u8) -> (Vec<usize>, Option<usize>) {
    let mut hits = Vec::new();
    let mut empty = None;
    let mut pos = 0;
    while pos + 16 <= ctrl.len() {
        unsafe {
            let g = _mm_loadu_si128(ctrl.as_ptr().add(pos).cast());
            let mut bits = _mm_movemask_epi8(_mm_cmpeq_epi8(g, _mm_set1_epi8(tag as i8))) as u16;
            while bits != 0 {
                hits.push(pos + bits.trailing_zeros() as usize);
                bits &= bits - 1;
            }
            let e = _mm_movemask_epi8(_mm_cmpeq_epi8(g, _mm_set1_epi8(-1))) as u16;
            if e != 0 && empty.is_none() {
                empty = Some(pos + e.trailing_zeros() as usize);
            }
            // DELETED (0x80) and EMPTY (0xFF) → EMPTY, full → DELETED.
            let special = _mm_cmpgt_epi8(_mm_setzero_si128(), g);
            let _converted = _mm_or_si128(special, _mm_set1_epi8(0x80u8 as i8));
        }
        pos += 16;
    }
    (hits, empty)
}

#[inline(never)]
fn collections() {
    let ctrl: Vec<u8> = (0..96u32).map(|i| if i % 11 == 0 { 0xff } else if i % 13 == 0 { 0x80 } else { (i * 7 % 128) as u8 }).collect();
    for tag in [0u8, 7, 21, 0x7f] {
        println!("probe {tag}: {:?}", probe(&ctrl, tag));
    }
    let mut map = HashMap::new();
    for i in 0..2000u32 {
        map.insert(i.wrapping_mul(2654435761), i);
    }
    for i in (0..2000u32).step_by(3) {
        map.remove(&i.wrapping_mul(2654435761));
    }
    // Tombstones then growth: rehash in place and resize.
    for i in 2000..2600u32 {
        map.insert(i.wrapping_mul(2654435761), i);
    }
    let mut keys: Vec<u32> = map.values().copied().collect();
    keys.sort();
    println!("map {} {} {}", map.len(), keys.iter().map(|&k| k as u64).sum::<u64>(), map.get(&7u32.wrapping_mul(2654435761)).copied().unwrap_or(0));
    let mut set: HashSet<String> = (0..300).map(|i| format!("k{i}")).collect();
    set.retain(|s| s.len() % 2 == 0);
    println!("set {} {}", set.len(), set.contains("k42"));
    let hay = "the quick brown fox jumps over the lazy dog, again and again, until the needle shows up: needle-in-a-haystack!";
    println!("contains {} {} {:?}", hay.contains("needle-in-a-hay"), hay.contains("needle-in-a-hat"), hay.find("again, until"));
    let long: Vec<u8> = (0..200u32).map(|i| (i % 120) as u8).collect();
    let mut nonascii = long.clone();
    nonascii[150] = 0xc3;
    println!("is_ascii {} {} {}", long.is_ascii(), nonascii.is_ascii(), nonascii[..150].is_ascii());
    println!("memchr {:?} {:?}", long.iter().position(|&c| c == 119), String::from_utf8_lossy(&long[..120]).find('w'));
}

// ---- #[target_feature] functions ----

/// Only mapped operations: VM code.
#[target_feature(enable = "sse2")]
fn sse2_mapped(x: &[u8; 16], tag: u8) -> u32 {
    let v = unsafe { _mm_loadu_si128(x.as_ptr().cast()) };
    (_mm_movemask_epi8(_mm_cmpeq_epi8(v, _mm_set1_epi8(tag as i8))) as u32) << 16 | _mm_movemask_epi8(v) as u32
}

/// No SIMD at all: VM code.
#[target_feature(enable = "sse2")]
fn sse2_plain(x: u32) -> u32 {
    x.wrapping_mul(31).rotate_left(3)
}

/// `simd_shuffle` has no instruction: native, not an island.
#[target_feature(enable = "sse2")]
fn sse2_shuffle(x: &[u8; 16]) -> [u8; 16] {
    b(_mm_shuffle_epi32::<0x1b>(m(*x)))
}

unsafe extern "unadjusted" {
    #[link_name = "llvm.x86.sse2.packsswb.128"]
    fn packsswb(a: i16x8, b: i16x8) -> i8x16;
}

/// An `llvm.x86.*` link: native.
#[target_feature(enable = "sse2")]
fn sse2_llvm(x: &[u8; 16]) -> [u8; 16] {
    let v = i16x8::from_array(unsafe { std::mem::transmute(*x) });
    unsafe { packsswb(v, v) }.cast::<u8>().to_array()
}

/// Inline asm: native.
#[target_feature(enable = "sse2")]
fn sse2_asm(x: u64) -> u64 {
    let r: u64;
    unsafe { std::arch::asm!("lea {0}, [{1} + 1]", out(reg) r, in(reg) x) };
    r
}

/// A feature the crate doesn't enable: native, whatever the body.
#[target_feature(enable = "avx2")]
fn avx2_sum(x: &[u8]) -> u32 {
    x.iter().map(|&c| c as u32).sum()
}

fn sum_portable(x: &[u8]) -> u32 {
    x.iter().map(|&c| c as u32).sum()
}

#[inline(never)]
fn target_features() {
    let vs = vectors();
    let mut acc = 0u32;
    for x in &vs {
        acc = acc.rotate_left(3) ^ unsafe { sse2_mapped(x, x[3]) } ^ unsafe { sse2_plain(x[0] as u32) };
    }
    println!("sse2 mapped {acc:#x}");
    println!("shuffle {:x?}", unsafe { sse2_shuffle(&vs[1]) });
    println!("packs {:x?}", unsafe { sse2_llvm(&vs[9]) });
    println!("asm {}", unsafe { sse2_asm(41) });
    let data: Vec<u8> = (0..1000u32).map(|i| i as u8).collect();
    let s = if is_x86_feature_detected!("avx2") { unsafe { avx2_sum(&data) } } else { sum_portable(&data) };
    println!("sum {s}");
}

// ---- memchr-style dispatch through an `AtomicPtr` ----

type Find = unsafe fn(&[u8], u8) -> Option<usize>;

static FIND: AtomicPtr<()> = AtomicPtr::new(detect as Find as *mut ());

unsafe fn detect(h: &[u8], n: u8) -> Option<usize> {
    let f: Find = if is_x86_feature_detected!("avx2") && std::env::var_os("VM_SIMD_NO_AVX2").is_none() { find_avx2 } else { find_sse2 };
    FIND.store(f as *mut (), Ordering::Relaxed);
    unsafe { f(h, n) }
}

#[target_feature(enable = "sse2")]
fn find_sse2(h: &[u8], n: u8) -> Option<usize> {
    let mut i = 0;
    while i + 16 <= h.len() {
        let v = unsafe { _mm_loadu_si128(h.as_ptr().add(i).cast()) };
        let bits = _mm_movemask_epi8(_mm_cmpeq_epi8(v, _mm_set1_epi8(n as i8)));
        if bits != 0 {
            return Some(i + bits.trailing_zeros() as usize);
        }
        i += 16;
    }
    h[i..].iter().position(|&c| c == n).map(|p| i + p)
}

#[target_feature(enable = "avx2")]
fn find_avx2(h: &[u8], n: u8) -> Option<usize> {
    let mut i = 0;
    while i + 32 <= h.len() {
        let v = unsafe { _mm256_loadu_si256(h.as_ptr().add(i).cast()) };
        let bits = _mm256_movemask_epi8(_mm256_cmpeq_epi8(v, _mm256_set1_epi8(n as i8)));
        if bits != 0 {
            return Some(i + bits.trailing_zeros() as usize);
        }
        i += 32;
    }
    h[i..].iter().position(|&c| c == n).map(|p| i + p)
}

#[inline(never)]
fn find(h: &[u8], n: u8) -> Option<usize> {
    let f = FIND.load(Ordering::Relaxed);
    let f: Find = unsafe { std::mem::transmute::<*mut (), Find>(f) };
    unsafe { f(h, n) }
}

#[inline(never)]
fn dispatch() {
    let h: Vec<u8> = (0..300u32).map(|i| (i * 7 % 251) as u8).collect();
    for n in [0u8, 7, 250, 249, 255] {
        let want = h.iter().position(|&c| c == n);
        // Both implementations directly, where the CPU has them, then through the pointer.
        let sse2 = unsafe { find_sse2(&h, n) };
        let avx2 = if is_x86_feature_detected!("avx2") { unsafe { find_avx2(&h, n) } } else { want };
        println!("find {n}: {:?} {} {}", find(&h, n), sse2 == want, avx2 == want);
    }
}

fn main() {
    sse2_fns();
    loads_stores();
    direct();
    println!("live {}", live_across());
    collections();
    target_features();
    dispatch();
}
