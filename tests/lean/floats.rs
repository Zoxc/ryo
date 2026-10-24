//! f32/f64 arithmetic, conversions, NaN and signed zeros (printed as bits).
include!("common/print.rs");
use std::hint::black_box;

fn b64(x: f64) {
    out::hex(x.to_bits() as u128);
}

/// NaN results of arithmetic have an unspecified sign (RFC 3514): print it as `nan`.
fn n64(x: f64) {
    if x.is_nan() {
        out::str("nan:");
        out::hex((x.to_bits() & !(1 << 63)) as u128);
    } else {
        b64(x);
    }
}

fn b32(x: f32) {
    out::hex(x.to_bits() as u128);
}

fn main() {
    let f: f64 = black_box(2.5);
    let g: f64 = black_box(-0.1);
    for x in [f + g, f - g, f * g, f / g, f % g, -f, g * g * g] {
        b64(x);
        out::sp();
    }
    out::nl();
    let a: f32 = black_box(1.1);
    let b: f32 = black_box(3.0e-3);
    for x in [a + b, a - b, a * b, a / b, a % b, a * a * a * a] {
        b32(x);
        out::sp();
    }
    out::nl();
    // special values
    let inf = black_box(f64::INFINITY);
    let zero = black_box(0.0f64);
    n64(inf - inf);
    out::sp();
    n64(zero / zero);
    out::sp();
    b64(-zero);
    out::sp();
    b64(1.0 / -zero);
    out::sp();
    b64(f64::MAX * 2.0);
    out::sp();
    b64(f64::MIN_POSITIVE / black_box(3.0));
    out::nl();
    let nan = black_box(f64::NAN);
    out::b(nan == nan);
    out::sp();
    out::b(nan < 1.0);
    out::sp();
    out::b(nan.is_nan());
    out::sp();
    out::b(zero == -zero);
    out::sp();
    out::b(black_box(0.1f64) + 0.2 == 0.3);
    out::sp();
    out::b(inf > f64::MAX);
    out::nl();
    // std helpers on intrinsics
    b64(f.sqrt());
    out::sp();
    b64(f.powi(5));
    out::sp();
    b64(g.abs());
    out::sp();
    b64(f.mul_add(g, 1.0));
    out::sp();
    b64(f.copysign(g));
    out::sp();
    b64(f.max(g));
    out::sp();
    b64(f.min(nan));
    out::sp();
    b32(a.sqrt());
    out::sp();
    b32(b.max(a));
    out::nl();
    // rounding via casts
    out::is(&[(f * 3.0) as i128, (g * 1000.0) as i128, (a * 100.0) as i128]);
    let mut s = 0.0f64;
    let mut k = 1.0f64;
    for _ in 0..black_box(30) {
        s += 1.0 / k;
        k *= 2.0;
    }
    b64(s);
    out::sp();
    b64(f64::from_bits(black_box(0x400921fb54442d18)));
    out::sp();
    b32(black_box(16777217u32) as f32);
    out::sp();
    b64(black_box(i64::MIN) as f64);
    out::nl();
}
