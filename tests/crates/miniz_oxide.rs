//! `y bench crates` workload for miniz_oxide: deflate and inflate generated text.
use miniz_oxide::deflate::compress_to_vec;
use miniz_oxide::inflate::decompress_to_vec;

fn main() {
    let mut data = Vec::new();
    let mut x: u32 = 12345;
    while data.len() < 400_000 {
        x = x.wrapping_mul(1103515245).wrapping_add(12345);
        let word = ["lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing"][(x >> 16) as usize % 7];
        data.extend_from_slice(word.as_bytes());
        data.push(if x % 13 == 0 { b'\n' } else { b' ' });
    }
    let mut total = 0;
    for level in [1, 6, 9] {
        let c = compress_to_vec(&data, level);
        let d = decompress_to_vec(&c).unwrap();
        assert_eq!(d, data);
        total += c.len();
        println!("level {level}: {} -> {}", data.len(), c.len());
    }
    println!("total {total}");
}
