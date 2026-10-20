//! `y bench crates` workload for regex-syntax: parse patterns and translate them to HIR.
use regex_syntax::Parser;

fn main() {
    let patterns = [
        r"[a-zA-Z_][a-zA-Z0-9_]*",
        r"(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})",
        r"(?i)hello\s+(world|there|everyone)!?",
        r"^\p{Greek}+\s*\p{Lu}{2,5}$",
        r"(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}",
        r"\b\w+@\w+\.(com|org|net)\b",
        r"(a|b|c|d|e)*(f+g?h{3,})[^xyz]",
        r"[\p{L}&&[^\p{Ll}]]+",
    ];
    let mut props = 0usize;
    let mut len = 0usize;
    for _ in 0..40 {
        for p in &patterns {
            let hir = Parser::new().parse(p).unwrap();
            props += hir.properties().minimum_len().unwrap_or(0) + hir.properties().explicit_captures_len();
            len += format!("{hir}").len();
        }
    }
    println!("props {props}, printed {len}");
}
