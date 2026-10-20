//! `y bench crates` workload for memchr: byte searches and substring search over a buffer.
use memchr::{memchr_iter, memchr3_iter, memmem, memrchr};

fn main() {
    let mut hay = Vec::new();
    let mut x: u32 = 99;
    while hay.len() < 2_000_000 {
        x = x.wrapping_mul(1103515245).wrapping_add(12345);
        hay.push(b'a' + ((x >> 16) % 26) as u8);
        if x % 997 == 0 {
            hay.extend_from_slice(b"needle in a haystack\n");
        }
    }
    let mut total = 0usize;
    for _ in 0..5 {
        total += memchr_iter(b'z', &hay).count();
        total += memchr3_iter(b'q', b'x', b'j', &hay).count();
        total += memmem::find_iter(&hay, b"needle").count();
        total += memmem::find_iter(&hay, b"haystack!").count();
        total += memrchr(b'\n', &hay).unwrap_or(0);
    }
    println!("total {total}");
}
