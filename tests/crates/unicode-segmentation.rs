//! `y bench crates` workload for unicode-segmentation: grapheme, word and sentence iteration
//! over mixed-script text.
use unicode_segmentation::UnicodeSegmentation;

fn main() {
    let para = "The quick brown fox jumps over the lazy dog. Ça va? Größe! \
                Ελληνικά κείμενα εδώ. 日本語のテキストです。 e\u{301}\u{302} 👨‍👩‍👧‍👦 🇳🇴 a\r\nb. \
                Don't stop—it's 3.14, isn't it? ";
    let text = para.repeat(400);
    let (mut graphemes, mut words, mut sentences, mut bounds) = (0, 0, 0, 0);
    for _ in 0..2 {
        graphemes += text.graphemes(true).count();
        words += text.unicode_words().count();
        sentences += text.unicode_sentences().count();
        bounds += text.split_word_bounds().filter(|w| w.len() > 1).count();
    }
    println!("graphemes {graphemes}, words {words}, sentences {sentences}, bounds {bounds}");
}
