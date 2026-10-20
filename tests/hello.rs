fn main() {
    let words: Vec<String> = ["Hello", "world"].iter().map(|s| s.to_string()).collect();
    println!("{}!", words.join(", "));
}
